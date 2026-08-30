/**
 * Situationslagret (docs/SEO_SITUATION_ONTOLOGY.md): resolver + domsmotor.
 *
 * En situationsnod är INTE en handskriven länklista. Noden deklarerar en
 * FAKTAPROFIL — samma faktavägar som kunskapsbasens kriterier använder — och
 * MOTORN avgör vilka stöd situationen faktiskt för framåt. Samma criteria-DSL
 * som produkten kör (packages/core), så en situationssida kan aldrig påstå en
 * koppling som motorn inte gör.
 *
 * Ankarregeln (medvetet strängare än "matchar filtret"):
 *   - inget hårt eller obligatoriskt kriterium får FALLERA på profilen, och
 *   - minst ett obligatoriskt/viktat kriterium måste PASSERA.
 * Hårda kriterier (sökandetyp, land) räknas alltså inte som träff i sig — de
 * gäller alla i målgruppen och skulle annars dra in hela hubben.
 *
 * Profilen får bara innehålla fakta som är DEFINITIONSMÄSSIGT sanna för
 * situationen. "Förälder med barn hemma" vet vi; "låg inkomst" vet vi inte —
 * det är en fråga motorn ställer, inte något sidan får anta.
 */
import { readFileSync } from 'node:fs';
import { evaluateAll } from '../../packages/core/src/criteria.ts';

export function loadSituations(root) {
  return JSON.parse(readFileSync(`${root}/seo/situationer.json`, 'utf8')).situationer;
}

/**
 * Resolvera en situation mot kunskapsbasen.
 * Returnerar stöden sorterade efter hur starkt situationen för dem framåt
 * (antal passerade kriterier), därefter stabilt på slug. Varje träff bär
 * kriteriebeskrivningarna som ORSAK — seedens egen text, inte ny copy.
 */
export function resolveSituation(sit, opportunities) {
  const traffar = [];
  for (const o of opportunities) {
    const res = evaluateAll(o.criteria ?? [], sit.fakta);
    const fallerar = res.some((r) => r.outcome === 'fail' && (r.criterion.kind === 'hard' || r.criterion.kind === 'mandatory'));
    if (fallerar) continue;
    const pass = res.filter((r) => r.outcome === 'pass' && r.criterion.kind !== 'hard');
    if (!pass.length) continue;
    traffar.push({ opportunity: o, skal: pass.map((r) => r.criterion.description), styrka: pass.length });
  }
  traffar.sort((a, b) => b.styrka - a.styrka || a.opportunity.slug.localeCompare(b.opportunity.slug));
  return traffar;
}

/**
 * Samma indexerbarhetsdoktrin som Query Pages (tools/lib/intents.mjs §29):
 * ≥3 stöd → INDEX, 1–2 → NOINDEX_FOLLOW (användbar men inte ett självständigt
 * sökresultat), 0 → DO_NOT_GENERATE. Kurering före sida — en situationsnod utan
 * kurerade stöd bakom sig blir en tunn sida och genereras aldrig.
 */
export function situationVerdict(traffar) {
  const count = traffar.length;
  if (count === 0) return { verdict: 'DO_NOT_GENERATE', count, reasons: ['inget kurerat stöd förs framåt av situationen'] };
  if (count < 3) return { verdict: 'NOINDEX_FOLLOW', count, reasons: [`endast ${count} stöd — för tunt för att tävla i Google, men användbart för människor`] };
  return { verdict: 'INDEX', count, reasons: [`${count} stöd förs framåt av situationen`, 'varje stöd har officiell källa'] };
}

/**
 * Nära-dubbletter: två situationsnoder som resolverar till EXAKT samma
 * stöduppsättning är samma sida med olika rubrik. Returnerar par som krockar.
 */
export function duplicateSituations(resolved) {
  const bySignature = new Map();
  const krockar = [];
  for (const r of resolved) {
    const sig = r.traffar.map((t) => t.opportunity.slug).sort().join(',');
    if (bySignature.has(sig)) krockar.push([bySignature.get(sig), r.sit.slug]);
    else bySignature.set(sig, r.sit.slug);
  }
  return krockar;
}

/**
 * Situationens egna frågor, hämtade UR SEEDEN — aldrig nyskriven copy.
 * För varje faktaväg i profilen väljs den intagsfråga vars kriterium faktiskt
 * PASSERAR på profilen, så sidan aldrig visar en fråga vars ja-svar är något
 * annat än det profilen påstår. Deterministisk ordning: profilens ordning,
 * första träffen sorterat på slug.
 */
export function situationFragor(sit, opportunities) {
  const sorterade = [...opportunities].sort((a, b) => a.slug.localeCompare(b.slug));
  const fragor = [];
  for (const path of Object.keys(sit.fakta)) {
    if (path.startsWith('applicant.')) continue; // målgruppen, inte situationen
    let hittad = null;
    for (const o of sorterade) {
      for (const r of evaluateAll(o.criteria ?? [], sit.fakta)) {
        if (r.criterion.factPath !== path || r.outcome !== 'pass' || !r.criterion.intakeQuestion) continue;
        hittad = r.criterion.intakeQuestion;
        break;
      }
      if (hittad) break;
    }
    if (hittad) fragor.push(hittad);
  }
  return fragor;
}

/**
 * Frågornas proveniens. En situationssida får bara visa intagsfrågor som står
 * ORDAGRANT i seeden OCH vars kriterium faktiskt passerar på profilen — annars
 * kan sidan ställa en fråga vars ja-svar betyder något annat än profilen
 * påstår. Kastar vid avvikelse; anropas av generatorn före första sidan.
 */
export function validateSituationQuestions(sit, opportunities) {
  const tillatna = new Set();
  for (const o of opportunities) {
    for (const r of evaluateAll(o.criteria ?? [], sit.fakta)) {
      if (r.outcome !== 'pass' || !r.criterion.intakeQuestion) continue;
      if (r.criterion.factPath.startsWith('applicant.')) continue;
      tillatna.add(r.criterion.intakeQuestion);
    }
  }
  const okanda = (sit.fragor ?? []).filter((q) => !tillatna.has(q));
  if (okanda.length) {
    throw new Error(`situation "${sit.slug}": fråga finns inte ordagrant i seeden för profilens faktavägar: ${okanda.join(' / ')}`);
  }
  // Varje egen faktaväg ska ha en fråga — annars döljer sidan ett antagande.
  const utanFraga = Object.keys(sit.fakta).filter((p) => !p.startsWith('applicant.')).length - (sit.fragor ?? []).length;
  if (utanFraga !== 0) {
    throw new Error(`situation "${sit.slug}": ${Object.keys(sit.fakta).filter((p) => !p.startsWith('applicant.')).length} faktavägar men ${(sit.fragor ?? []).length} frågor — varje antagande ska synas som fråga`);
  }
}
