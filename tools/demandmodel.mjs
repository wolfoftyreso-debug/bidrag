/**
 * Launch & Demand Intelligence: deterministisk scenariomodell
 * (docs/LAUNCH_DEMAND_INTELLIGENCE.md).
 *
 * Läser:
 *   seo/demand-parametrar.json   — scenarier (INPUT) + hypotesparametrar
 *   seo/intents-100.json         — de 25 klustren (prio, myndighet)
 *   seo/serp-sprint01.json       — feasibility per kluster
 *   seo/kunskapsgraf.json        — intent→stöd-kanter (besvaras_av)
 *   apps/api/src/seed/data.ts    — stöd (deadlineModel, submissionLevel,
 *                                  authenticationMethod), myndigheter
 *
 * Skriver: artifacts/demand-model.json + läsbar summering på stdout.
 *
 * SANNINGSREGEL: scenariovolymerna är INPUT, aldrig prognos. Alla härledda
 * tal ärver hypotesstatus från parametrarna och märks SCENARIO-OUTPUT.
 * Modellen svarar på "vad blir kritiskt VID volym X", inte "vilken volym får vi".
 *
 *   node --experimental-strip-types tools/demandmodel.mjs           # skriv
 *   node --experimental-strip-types tools/demandmodel.mjs --check   # kör + sanity, skriv inget
 *
 * Deterministisk: inga klockdatum, sorterad utdata.
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const CHECK = process.argv.includes('--check');

const P = JSON.parse(readFileSync(join(ROOT, 'seo', 'demand-parametrar.json'), 'utf8'));
const intents = JSON.parse(readFileSync(join(ROOT, 'seo', 'intents-100.json'), 'utf8')).intents;
const serp = JSON.parse(readFileSync(join(ROOT, 'seo', 'serp-sprint01.json'), 'utf8'));
const kgraf = JSON.parse(readFileSync(join(ROOT, 'seo', 'kunskapsgraf.json'), 'utf8'));
const { opportunities, authorities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));

// ── Sanningsmodellen: stöd + myndigheter ur seeden ──────────────────────────
const stod = new Map(opportunities.map((o) => [o.slug, {
  slug: o.slug,
  authority: o.authorityKey,
  deadlineModel: o.deadlineModel ?? 'rolling',
  submissionLevel: o.submissionLevel ?? null,
  authentication: o.authenticationMethod ?? null,
  hasApplicationUrl: Boolean(o.applicationUrl),
}]));
const authorityNames = new Map(authorities.map((a) => [a.key, a.name]));

// ── Kluster→stöd-mappning ───────────────────────────────────────────────────
// Primärt ur kunskapsgrafen (intent besvaras_av stöd). För tvärgående kluster
// utan enskilt stöd: explicit korg härledd ur blueprint-dokumenten
// (docs/SEO_BLUEPRINTS_SPRINT01.md). Kluster vars stöd INTE finns i
// kunskapsbasen får tom korg och flaggas som kunskapsbas-gap — det är ett
// fynd, inget som får maskeras med närmaste granne.
const graphMap = new Map(); // cluster_id -> [slug]
const intentNodes = new Map(kgraf.nodes.filter((n) => n.type === 'intent').map((n) => [n.id, n]));
for (const e of kgraf.edges.filter((e) => e.rel === 'besvaras_av')) {
  const cid = intentNodes.get(e.from)?.cluster_id;
  if (cid == null) continue;
  const slug = e.to.replace(/^stod:/, '');
  if (!graphMap.has(cid)) graphMap.set(cid, []);
  graphMap.get(cid).push(slug);
}
const BASKETS = {
  2:  ['fk-bostadsbidrag-barnfamiljer', 'fk-bostadsbidrag-unga', 'pm-bostadstillagg'], // avgöraren (B4)
  6:  ['csn-studiemedel', 'csn-omstallningsstudiestod'],                               // studiestödsväljaren (B7)
  10: ['af-lonebidrag'],                                                               // lönebidrag (kurerad — gapet stängt)
  11: ['af-nystartsjobb'],                                                             // nystartsjobb (kurerad — gapet stängt)
  12: ['af-lonebidrag', 'af-nystartsjobb'],                                            // anställa med stöd-väljaren (klusterhubb /bidrag/lonebidrag/)
  16: ['fk-bostadsbidrag-barnfamiljer', 'fk-bostadsbidrag-unga', 'kommun-forsorjningsstod', 'pm-bostadstillagg'], // hyres-akuten (B2)
  17: null,                                                                            // samlingsvyn (B1): fördelas över alla privatpersonsstöd
  18: ['fk-bostadsbidrag-barnfamiljer', 'fk-underhallsstod', 'fk-omvardnadsbidrag', 'region-glasogonbidrag-barn', 'kommun-skolskjuts', 'majblomman-ekonomiskt-stod'], // barnfamilj (B5)
  19: ['af-etableringsersattning', 'kommun-forsorjningsstod', 'fk-bostadsbidrag-unga', 'csn-omstallningsstudiestod'], // arbetslös-tidslinjen (B9-angränsande)
  21: ['majblomman-ekonomiskt-stod', 'lansstyrelsen-bygdemedel', 'sparbanksstiftelserna-projektbidrag', 'radiohjalpen-projektbidrag'], // stipendier & fonder (uppskjuten till F2 — närmaste seedade)
  23: ['tillvaxtverket-affarsutvecklingscheckar', 'tillvaxtverket-regionalt-investeringsstod', 'esf-projektstod', 'vinnova-planeringsbidrag-eu'], // eu-bidrag företag (B8-angränsande)
};
const individualSlugs = kgraf.edges
  .filter((e) => e.rel === 'riktar_sig_till' && e.to === 'malgrupp:privatpersoner')
  .map((e) => e.from.replace(/^stod:/, ''))
  .filter((s) => stod.has(s))
  .sort();

function clusterSlugs(cid) {
  if (graphMap.has(cid)) return graphMap.get(cid);
  const basket = BASKETS[cid];
  if (basket === null) return individualSlugs;
  if (basket) return basket.filter((s) => stod.has(s));
  return [];
}

// ── Klustervikter ───────────────────────────────────────────────────────────
const feasByCluster = new Map(serp.kluster.map((k) => [k.cluster_id, k.first_place_feasibility]));
const clusters = intents
  .filter((i) => i.typ === 'kluster')
  .map((i) => {
    const feas = feasByCluster.get(i.cluster_id) ?? 'ANGRIP-RUNT';
    const weight = P.klusterfordelning.priovikt.varden[String(i.prio)]
      * P.klusterfordelning.feasibilitymultiplikator.varden[feas];
    return { cluster_id: i.cluster_id, amne: i.amne, prio: i.prio, feasibility: feas, weight, slugs: clusterSlugs(i.cluster_id) };
  })
  .sort((a, b) => a.cluster_id - b.cluster_id);
const totalWeight = clusters.reduce((s, c) => s + c.weight, 0);

// ── Tratt + spik + teknik per scenario ──────────────────────────────────────
const T = P.tratt;
const S = P.spik;
const TEK = P.teknik;
const round = (x) => (x >= 100 ? Math.round(x) : Math.round(x * 10) / 10);

const scenarios = P.scenarier.sessioner_per_manad.map((sessions) => {
  const perCluster = clusters.map((c) => {
    const s = sessions * (c.weight / totalWeight);
    const started = s * T.andel_startar_genomgang.varde;
    const completed = started * T.andel_slutfor_genomgang.varde;
    const matched = completed * T.andel_minst_en_verifierad_match.varde;
    const outbound = matched * T.andel_klick_ut_till_myndighet.varde;
    const prepStarted = matched * T.andel_paborjar_forberedelse.varde;
    const analysisUnlocks = matched * T.andel_kop_analys.varde;
    return { ...c, sessions: s, started, completed, matched, outbound, prepStarted, analysisUnlocks };
  });

  // Utgående klick per myndighet: klustrets outbound fördelas jämnt över
  // klustrets stöd; kluster utan stöd i kunskapsbasen ackumuleras som gap.
  const perAuthority = new Map();
  let unroutedOutbound = 0;
  const gapClusters = [];
  for (const c of perCluster) {
    if (c.slugs.length === 0) {
      unroutedOutbound += c.outbound;
      if (c.outbound > 0) gapClusters.push(c.cluster_id);
      continue;
    }
    const per = c.outbound / c.slugs.length;
    for (const slug of c.slugs) {
      const st = stod.get(slug);
      if (!st) continue;
      const cur = perAuthority.get(st.authority) ?? { outbound: 0, peakDay: 0, stod: new Set() };
      cur.outbound += per;
      cur.peakDay += per * S.dygnsandel_toppdag.varde * S.deadline_multiplikator.varden[st.deadlineModel];
      cur.stod.add(slug);
      perAuthority.set(st.authority, cur);
    }
  }
  const authorities_ = [...perAuthority.entries()]
    .map(([key, v]) => ({
      authority: key,
      name: authorityNames.get(key) ?? key,
      outboundPerMonth: round(v.outbound),
      peakDayOutbound: round(v.peakDay),
      viaStod: [...v.stod].sort(),
    }))
    .sort((a, b) => b.outboundPerMonth - a.outboundPerMonth);

  // Total tratt
  const sum = (f) => perCluster.reduce((s, c) => s + f(c), 0);
  const funnel = {
    sessioner: sessions,
    genomgangar_startade: round(sum((c) => c.started)),
    genomgangar_slutforda: round(sum((c) => c.completed)),
    med_minst_en_match: round(sum((c) => c.matched)),
    klick_ut_till_myndighet: round(sum((c) => c.outbound)),
    forberedelser_paborjade_BLOCKERAT_UTAN_SWISH: round(sum((c) => c.prepStarted)),
    analysupplasningar_BLOCKERAT_UTAN_SWISH: round(sum((c) => c.analysisUnlocks)),
  };

  // Teknisk last. Publika ytan = statisk (0 serverless, VERIFIED).
  const apiCallsMonth = funnel.genomgangar_startade * TEK.api_anrop_per_genomgang.varde;
  const peakDaySessions = sessions * S.dygnsandel_toppdag.varde;
  const peakHourSessions = peakDaySessions * S.timandel_topptimme.varde;
  const peakHourStarts = peakHourSessions * T.andel_startar_genomgang.varde;
  const peakHourApiCalls = peakHourStarts * TEK.api_anrop_per_genomgang.varde;
  const tech = {
    serverless_anrop_per_manad: Math.round(apiCallsMonth),
    genomsnitt_api_rps: round(apiCallsMonth / (30 * 24 * 3600) * 1000) / 1000,
    topptimme_api_rps: round(peakHourApiCalls / 3600 * 100) / 100,
    topptimme_db_fragor_per_sekund: round(peakHourApiCalls / 3600 * TEK.db_fragor_per_api_anrop.varde * 100) / 100,
    topptimme_nya_genomgangar_per_minut: round(peakHourStarts / 60 * 10) / 10,
    cdn_sidvisningar_per_manad_statisk_yta: sessions,
  };

  // Kritiska trösklar — verified gränser + DATA_UNAVAILABLE-uppslag
  const flags = [];
  const regPerMin = tech.topptimme_nya_genomgangar_per_minut; // ≈ registreringar/min i topptimmen
  flags.push({
    yta: 'kunskapsbas-gap',
    niva: gapClusters.length ? 'CRITICAL' : 'OK',
    detalj: gapClusters.length
      ? `Kluster ${gapClusters.join(', ')} (lönebidrag/nystartsjobb/anställa med stöd) saknar stöd i kunskapsbasen — ${round(unroutedOutbound)} utgående klick/mån i detta scenario kan inte routas till någon produktyta. SEO-sidor för dessa kluster vore återvändsgränder tills stöden kureras.`
      : 'Alla kluster har stöd i kunskapsbasen.',
  });
  flags.push({
    yta: 'betalvägen',
    niva: 'BLOCKERAT',
    detalj: `${funnel.forberedelser_paborjade_BLOCKERAT_UTAN_SWISH + funnel.analysupplasningar_BLOCKERAT_UTAN_SWISH} betalintentioner/mån möter ärlig 503 tills Swish Handel-avtalet finns (docs/ACTIVATION.md). Blockerad efterfrågan, inte intäkt.`,
  });
  flags.push({
    yta: 'rate limit registrering (10/min/IP, VERIFIED)',
    niva: regPerMin > 10 ? 'OBS' : 'OK',
    detalj: regPerMin > 10
      ? `~${regPerMin} nya genomgångar/min i topptimmen totalt. Per-IP-gränsen binder inte legitim trafik (olika IP), men delade IP:n (skol-/företagsnät, CGNAT) kan slå i taket. In-memory-storen skyddar dessutom svagare vid serverless scale-out.`
      : `~${regPerMin} nya genomgångar/min i topptimmen — långt under gränsen även för delade IP:n.`,
  });
  flags.push({
    yta: 'Vercel serverless',
    niva: tech.topptimme_api_rps > 50 ? 'SLÅ-UPP' : 'OK',
    detalj: `${tech.serverless_anrop_per_manad.toLocaleString('sv-SE')} anrop/mån, topptimme ~${tech.topptimme_api_rps} RPS. Kontots samtidighets-/invocation-tak: DATA_UNAVAILABLE — ${tech.topptimme_api_rps > 50 ? 'MÅSTE slås upp mot vald plan före lansering i denna skala.' : 'ingen åtgärd vid denna volym.'}`,
  });
  flags.push({
    yta: 'Supabase/Postgres',
    niva: tech.topptimme_db_fragor_per_sekund > 100 ? 'SLÅ-UPP' : 'OK',
    detalj: `Topptimme ~${tech.topptimme_db_fragor_per_sekund} frågor/s genom pooler. Poolstorlek/compute-nivå: DATA_UNAVAILABLE — ${tech.topptimme_db_fragor_per_sekund > 100 ? 'dimensioneras mot vald Supabase-plan före lansering i denna skala.' : 'ingen åtgärd vid denna volym.'}`,
  });

  return {
    sessioner_per_manad: sessions,
    tratt: funnel,
    kluster: perCluster.map((c) => ({
      cluster_id: c.cluster_id,
      amne: c.amne,
      prio: c.prio,
      feasibility: c.feasibility,
      andel_av_trafiken: Math.round((c.weight / totalWeight) * 1000) / 10,
      sessioner: round(c.sessions),
      klick_ut: round(c.outbound),
      stod_i_kunskapsbasen: c.slugs.length,
    })),
    myndigheter: authorities_,
    ej_routbara_klick_kunskapsbas_gap: round(unroutedOutbound),
    teknisk_last: tech,
    kritiska_trosklar: flags,
  };
});

// ── Utdata ──────────────────────────────────────────────────────────────────
const out = {
  _kontrakt: 'Genererad av tools/demandmodel.mjs ur seo/demand-parametrar.json + intents/SERP/kunskapsgraf + seeden. ALLA volymer är SCENARIO-OUTPUT: härledda ur scenarioinputs och HYPOTHESIS-parametrar, aldrig prognoser. Får inte citeras som förväntad trafik. Regenereras vid varje körning; kalibreras om med fältdata efter deploy (docs/LAUNCH_DEMAND_INTELLIGENCE.md §7).',
  parametrar_version: P.version,
  klustervikter: clusters.map((c) => ({ cluster_id: c.cluster_id, amne: c.amne, prio: c.prio, feasibility: c.feasibility, vikt: Math.round(c.weight * 100) / 100 })),
  scenarier: scenarios,
};

// Sanity (kör alltid; --check kör bara denna del)
const errs = [];
if (clusters.length !== 25) errs.push(`25 kluster förväntade, fick ${clusters.length}`);
if (!(totalWeight > 0)) errs.push('total klustervikt är 0');
for (const sc of scenarios) {
  if (sc.tratt.genomgangar_startade > sc.sessioner_per_manad) errs.push('tratten expanderar (startade > sessioner)');
  if (sc.tratt.klick_ut_till_myndighet > sc.tratt.med_minst_en_match) errs.push('tratten expanderar (klick ut > matchade)');
  const routed = sc.myndigheter.reduce((s, a) => s + a.outboundPerMonth, 0);
  const total = sc.tratt.klick_ut_till_myndighet;
  if (Math.abs(routed + sc.ej_routbara_klick_kunskapsbas_gap - total) > total * 0.02 + 1) {
    errs.push(`klickrouting tappar volym i scenario ${sc.sessioner_per_manad}`);
  }
}
for (const s of individualSlugs) if (!stod.has(s)) errs.push(`privatpersonsstöd ${s} saknas i seeden`);
if (errs.length) {
  console.error('demandmodel: SANITY FAIL\n - ' + errs.join('\n - '));
  process.exit(1);
}

if (!CHECK) {
  mkdirSync(join(ROOT, 'artifacts'), { recursive: true });
  writeFileSync(join(ROOT, 'artifacts', 'demand-model.json'), JSON.stringify(out, null, 2) + '\n');
}

// Läsbar summering
console.log('LAUNCH & DEMAND INTELLIGENCE — scenariomodell (INPUT, aldrig prognos)');
for (const sc of scenarios) {
  console.log(`\n■ ${sc.sessioner_per_manad.toLocaleString('sv-SE')} sessioner/mån`);
  console.log(`  tratt: ${sc.tratt.genomgangar_startade} startade → ${sc.tratt.med_minst_en_match} matchade → ${sc.tratt.klick_ut_till_myndighet} klick ut → ${sc.tratt.forberedelser_paborjade_BLOCKERAT_UTAN_SWISH} förberedelser (blockerat utan Swish)`);
  console.log(`  topp-3 myndigheter (klick ut/mån): ${sc.myndigheter.slice(0, 3).map((a) => `${a.name} ${a.outboundPerMonth}`).join(' · ')}`);
  console.log(`  teknik: topptimme ~${sc.teknisk_last.topptimme_api_rps} API-RPS, ~${sc.teknisk_last.topptimme_db_fragor_per_sekund} db-frågor/s; statisk yta ${sc.teknisk_last.cdn_sidvisningar_per_manad_statisk_yta.toLocaleString('sv-SE')} CDN-visningar`);
  for (const f of sc.kritiska_trosklar.filter((f) => f.niva !== 'OK')) console.log(`  [${f.niva}] ${f.yta}: ${f.detalj}`);
}
console.log(CHECK ? '\ndemandmodel --check: OK (inget skrivet)' : '\n→ artifacts/demand-model.json');
