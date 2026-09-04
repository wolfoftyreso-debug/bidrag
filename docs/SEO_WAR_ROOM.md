# SEO WAR ROOM — evidensbok för SERP-dominansprogrammet

Datum: 2026-08-28 · Metod: allt nedan är UPPMÄTT med verkliga verktyg
(Semrush regional databas `se`, Vercel-API, DNS-uppslag) — inga uppskattade
volymer, positioner eller backlinks. Namnregel: varumärket heter **Bidragskoll**
(domän bidragskoll.se); "Bidragskollen" är en annan aktör (namngranne).

Uppdraget (masterprompt 2026-08-28): Bidragskoll.se ska bli Sveriges
dominerande discovery-lager för bidrag och stöd — myndigheterna är
originalkällorna, Bidragskoll är discovery + normalisering + matchning +
jämförelse + förklaring + bevakning. Detta dokument är exekveringens
evidensbok; implementationerna ligger i koden (se §6).

## 1. Capability map (connectors som faktiskt använts/finns)

| Verktyg | Ger | Används till |
|---|---|---|
| Semrush MCP | volym, KD, intent, SERP-topp-20, konkurrenters keywords/trafik, PAA-frågor | hela search intelligence-lagret (§2–4); datat skrivs källmärkt in i `seo/volumes-semrush-se.json` |
| Vercel MCP | projekt-/deploy-/domänstatus, hämtning av produktions-HTML | verifiering av deployad yta (§5) — repo ≠ produktion antas aldrig |
| WebFetch/WebSearch | myndighetskällor, SERP-korsverifiering | kurering och källkontroll (bidragskoll.se är egress-blockerad; Vercel-vägen används) |
| GitHub MCP | repo-operationer | pushar till båda remotes |
| Firecrawl | crawl/sök | reserv för konkurrentinnehåll |
| Apollo | kontaktdata för outreach | **VILAR: offsite är fryst tills GATE 0 är grön** (`docs/ZERO_COMPROMISE_GATE.md`) — används först i Authority Desk-fasen |
| Mobbin | UX-mönster för search/discovery/onboarding | nästa UX-pass på appens intag (ej i denna körning) |
| Stripe/Resend/Sentry/Figma m.fl. | — | utanför detta programs scope |

## 2. Nollmätning — det ärliga läget

- **bidragskoll.se har 0 rankande sökord i Semrush** (`domain_rank` → NOTHING FOUND). Vi är osynliga i Google idag.
- **Domänen är inte kopplad till Vercel-projektet.** DNS: bidragskoll.se → 194.9.94.85/86 (parkering — inte Vercel). Vercel-projektet `bidragskoll` (team hypbit) serverar produktion enbart på `bidragskoll.vercel.app`, och Vercel sätter automatiskt `x-robots-tag: noindex` på *.vercel.app-domäner.
- Konsekvens: **hela den publika ytan (146 genererade sidor) är avsiktligt oindexerbar tills domänen kopplas.** Det är rätt beteende (fel domän ska inte indexeras) men gör domänkopplingen till blockerare #1 för ALL SEO.

**OPERATÖRSÅTGÄRD #1 (låser upp allt):** peka bidragskoll.se på Vercel
(A-post 76.76.21.21 eller CNAME cname.vercel-dns.com hos registraren) och lägg
till domänen i Vercel-projektet `bidragskoll` (Settings → Domains). Därefter:
GSC-verifiering + skicka in sitemap.xml (`docs/SEO_BASELINE.md`-loopen).

## 3. Uppmätt efterfrågan (Semrush se, hämtad 2026-08-28)

Seed-termerna ur masterprompten, verkliga månadsvolymer:

| Term | Volym | KD | Kommentar |
|---|---|---|---|
| bidrag | 12 100 | 35 | huvudterm; SERP:en är blandad (se §4) |
| starta eget bidrag | 4 400 | 28 | störst vinnbara möjlighet — nu byggd klusterhubb |
| lönebidrag | 2 400 | 23 | kunskapsbasen bär stödet (af-lonebidrag) — klusterhubb byggd i detta pass |
| stipendier | 720 | 34 | eget framtida kluster |
| bidrag arbetslös | 320 | 34 | situationssida finns (query pages) |
| ekonomiskt stöd / eu bidrag / bidrag solceller / investeringsstöd / söka stipendier | 260 | 30/15/31/23/35 | |
| söka bidrag / sök bidrag / bidrag att söka | 210 ×3 | 35–36 | svag SERP (§4) |
| föreningsbidrag / energibidrag | 210 | 18/24 | förening = bevisat vinnbar (§4) |
| bidrag förening | 110 | 18 | del av föreningsklustret |
| bidrag företag | 90 | 28 | |

Nollresultat (ingen mätbar volym i se-databasen): "hitta bidrag", "aktuella
bidrag", "nya bidrag", "öppna bidrag", "vilka bidrag kan jag få", "vilka bidrag
finns", "bidrag 2026", "bidrag låg inkomst", "anställa med bidrag". Slutsats:
**discovery-huvudtermerna bär liten uppmätt volym — efterfrågan bor i de
specifika termerna.** Vår discovery-positionering vinns via specifika inflöden
+ intern länkning till utredningen, inte via tomma "hitta bidrag"-fraser.
(Nollvolym ≠ noll sökningar — men vi bygger aldrig på antaganden.)

Alla rader ovan är införda källmärkta i `seo/volumes-semrush-se.json`
(semrush:se:2026-08-28), inklusive PAA-frågeset för "starta eget bidrag" och
"bidrag förening".

## 4. SERP-analys — var privata aktörer redan vinner

**PRIVATE-DOMAIN-PROVEN SERPs** (Google belönar redan privata aggregatorer):

- **"bidrag" (12 100):** topp-20 innehåller bidragsstiftelsen.se (#8, #19),
  hittabidrag.se (#9), allabidrag.se (#13), nyheter24 (#3), marcusoscarsson
  (#10), driva-eget (#14) — sex privata resultat. Myndigheter: FK (#1),
  Boverket (#4), CSN (#5), informationsverige (#6), Socialstyrelsens
  statsbidragsportal (#7). SERP:en är alltså INTE myndighetslåst.
- **"starta eget bidrag" (4 400):** #3–#10 domineras av privata innehållssajter
  (Företagarna, Sparbanken Tanum, Länsförsäkringar, TRS, Spiris,
  Småföretagarna, driva-eget, Fortnox). Endast #1–#2 är myndighetsnära
  (Arbetsförmedlingen, verksamt.se). Termen är ett namnförhållande-case:
  officiellt namn ≠ sökterm — exakt Bidragskolls normaliseringsroll.
- **"söka bidrag" (210):** svag, splittrad SERP — svenskbidragsformedling (#3),
  FVO (#4), funktionshindersguiden (#6), bidragsstiftelsen (#11),
  Wikimedia-lista (#12). Mycket vinnbar.
- **"föreningsbidrag"/"bidrag förening" (210+110, KD 18):**
  svenskbidragsformedling.se äger klustret med EN sida (#1 på 12+ varianter,
  se §5). Kommunerna tar lokal intent; den nationella översikten är öppen.

Myndighetsdominansen förklaras inte av "domänauktoritet" i sig utan av att de
äger originaldatat för NAMNGIVNA stöd. För tvärgående discovery-frågor har de
strukturellt sämre sidor (informationsverige #6 på "bidrag" är en generisk
social-service-sida). Det territoriet är öppet.

## 5. Konkurrentlandskap (uppmätt)

> Ögonblicksbild 2026-08-28. Full genomgång med 15 domäner, backlinks och
> tillväxthistorik: `docs/reports/SEMRUSH_2026-09-03.md` §4 och
> `docs/SEO_COMPETITORS.md` §B2 (aktuell tabell).

| Domän | Organiska sökord | Organisk trafik/mån | Läge |
|---|---|---|---|
| svenskbidragsformedling.se | 315 | ~705 | starkast privat; ~all trafik från EN sida (/soka-bidrag-till-forening/) — beviset att en aggregeringssida kan äga ett helt kluster |
| allabidrag.se | 14 | ~44 | rankar #13 på "bidrag" trots minimal yta |
| hittabidrag.se | 12 | ~22 | rankar #9 på "bidrag" trots 12 sökord totalt |
| bidragskollen.app (namngrannen) | 135 | ~10 | försumbar trafik; entity-separationen kvarstår viktig |
| bidragskoll.se (vi) | 0 | 0 | ej indexerbar förrän domänen kopplas (§2) |

Nyckelinsikt: de "konkurrenter" som rankar är SMÅ. SERP:en belönar dem för att
intentionen (hitta stöd över myndighetsgränser) är underbetjänad — med 146
riktiga datasidor ur en levande kunskapsbas går territoriet att ta.

informationsverige.se (studieobjekt, §7 i masterprompten): rankar på "bidrag"
med en bred social-service-sida — styrkan är institutionell auktoritet +
flerspråkighet + stabil IA, inte sidkvalitet för frågan. Vårt svar är redan
i bygget: 11-språksprogrammet (`docs/I18N_PROGRAM.md`, hreflang i fas C),
stabila permanenta URL:er, breadcrumbs, källmärkning per sida.

## 6. Implementerat i denna körning (kod, inte rekommendationer)

1. **Klusterhubb `/bidrag/starta-eget-bidrag/`** (4 400/mån, KD 28,
   privat-bevisad SERP): äger vardagstermen, förklarar namnförhållandet till
   det officiella stödet, väljare till tre verkliga startvägar i
   kunskapsbasen, FAQ ur verkliga PAA-frågor. Roten "starta eget bidrag" i
   `seo/roots-manual.json` riktas till hubben.
2. **Föreningshubben `/bidrag/foreningar/` bär klustrets sökspråk**: titel
   "Bidrag till förening – stöd för ideella föreningar", lead med
   "ideell förening", FAQ (3 frågor, varav 2 verkliga PAA) + FAQPage-markup.
3. **`/oppna-bidrag/` (TIME-intent)**: myndighetsövergripande vy beräknad ur
   kunskapsbasens deadlinemodell — 46 löpande öppna, "stänger snart"-sektion
   (satta deadlines), 39 i omgångar. Äkta information gain: ingen myndighet
   har denna tvärvy.
4. **Bidragsstatus förstärkt** med "närmast satta deadlines" + länk till
   /oppna-bidrag/ (§16 Bidragsläget — endast reproducerbara mått).
5. **Varumärkesrättning**: bidragskoll-seo-mcp (f.d. felnamnet
   "bidragskollen-seo-mcp") + två "Bidragskollen"-fraser om oss själva i
   SEO_CONTROL_PLANE. Kvarvarande "Bidragskollen"-förekomster i repo avser
   namngrannen (korrekt).
6. **Mätdata ingest**: 14 nya källmärkta volymrader + 2 PAA-frågeset i
   `seo/volumes-semrush-se.json`.

## 7. Medvetet INTE byggt (ärlighet före URL:er)

- **/nya-bidrag/**: kunskapsbasen spårar inte per-stöd-nyhet (inget addedAt;
  CURATED_AT är global). En "nya bidrag"-sida vore idag antingen tom eller
  vilseledande ("nytt i vår bas" ≠ "nytt bidrag i Sverige"). Låses upp av
  freshness-motorn: per-stöd `addedAt`/`changedAt` ur källdiff-flödet.
- **/bidrag-som-stanger-snart/** som egen URL: bara 2 framtida satta deadlines
  i basen — för tunt för en egen sida. Finns som sektion på /oppna-bidrag/
  och /bidragsstatus/; egen URL när basen bär fler daterade omgångar.
- **Geo-sidor (/bidrag/lan/, /bidrag/kommun/)**: kunskapsbasen har inte
  kommunspecifika data ännu — doorway-risk. Kräver kurerat geo-lager först.

## 8. Nästa drag i prioritetsordning (data avgör)

1. **OPERATÖR: domänkoppling** (§2) → GSC → sitemap → baseline-loopen.
2. ~~Kurera lönebidrag/nystartsjobb~~ **KLART i detta pass**: båda stöden
   fanns redan kurerade (af-lonebidrag, af-nystartsjobb) — efterfrågemodellens
   CRITICAL-larm byggde på en inaktuell korgmappning, nu rättad; klusterhubb
   /bidrag/lonebidrag/ byggd (2 400/mån KD 23, "vad är lönebidrag" 110/mån
   KD 18) med anställa med stöd-väljaren (kluster 10–12 stängda).
3. **"Fonder att söka"-rymden**: "stiftelser och fonder att söka pengar ur"
   1 000/mån + "fonder att söka" 880/mån — svag privat SERP (bevisad av
   svenskbidragsformedlings #12 utan egen sida). Kräver kurerat
   stiftelse-/fondlager i kunskapsbasen — kureringspass före sidor.
4. **Freshness-motorn** (§15 i masterprompten): per-stöd addedAt/changedAt +
   change_summary ur källdiff-flödet → låser upp /nya-bidrag/ och
   ändringshistorik på entity-sidor.
5. **Fri-verktygsytan** (backlog §4: "räkna ut bostadsbidrag" 1 300/mån) —
   interaktiv behörighetskontroll per kluster.
6. **Offsite förblir fryst** tills GATE 0 är grön; därefter Authority Desk
   (Apollo används först då).

Uppdateringsregel: varje ny mätning skrivs källmärkt till seo/-registret;
detta dokument uppdateras per pass med dom + bevis, aldrig med antaganden.
