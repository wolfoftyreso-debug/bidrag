# Connected Toolchain — utilization report

Directive: enumerate the connectors actually available in the session, judge each
one's *practical* value for **this** product (Bidragskoll.se — svensk B2C
bidragsupptäckt, Vercel + Supabase, **Swish** som betalning, Resend som
e-post, SEO-tung), and **use** the ones that earn it rather than hand the
operator manual steps. Relevance is decided per product, not by presence.

Snapshot: 2026-08-28. All data below was fetched live from the named connector.

## Tool plan

| Tool | Relevant? | What it can verify/improve | Action taken |
|---|---|---|---|
| **Semrush** | **JA — hög** | Verkliga svenska sökvolymer/intent för bidragstermerna — stänger det dokumenterade `search_volume: null`-gapet; svårighetsgrad; frågeformuleringar | **Använt** — `phrase_these` + `phrase_questions` (databas `se`); källmärkt snapshot committad |
| **Vercel** | **JA** | Auktoritativ deploy/runtime: finns projektet? konfig, loggar, previews | **Använt** (läs) — team + projektlista |
| **Resend** | **JA** | Transaktionell e-post är en verklig produktyta — inspektera domäner/mallar innan antaganden | **Använt** (läs) — domän- och malllista |
| **Stripe** | **NEJ** | Betalning = **Swish Handel** (arkitektoniskt bundet i `apps/api`) | Verifierat tomt — inget Bidragskoll-relaterat |
| **Gmail** | Villkorat | Verifiera *mottaget* testmejl (leverans/format) — bara om vi skickar ett | Ej utlöst (inget skarpt mejl att verifiera ännu) |
| **Mobbin** | Låg | Kunde benchmarka onboarding/checkout, men produkten är byggd | Ej använt denna pass |
| **Apollo.io** | **NEJ** | B2C-konsumentprodukt; Apollo = B2B-prospektering + **drar krediter** | Ej använt (skulle spendera krediter utan syfte) |
| **Anthropic Economic Index** | **NEJ** | Claude-användningsdata, inte svensk bidrags-/arbetsmarknadsdata | Ej använt |
| **Drive / Calendar / Slack / Gemini / Scholar** | **NEJ** | Ingen aktuell yta i en svensk bidragsupptäcktsapp | Ej använt |

## USED AND VERIFIED

### Semrush — verkliga svenska sökvolymer (det stora fyndet)
`seo/keywords.json`:s ärlighetskontrakt sa uttryckligen att volym/CPC/difficulty
är `null` / `DATA_UNAVAILABLE` **"tills verklig källa finns (GSC/Keyword Planner/
Semrush/Ahrefs/DataForSEO) — fabricera aldrig."** Den källan finns nu.

- **`phrase_these`** (databas `se`) på 25 kärntermer → verklig volym, CPC,
  konkurrens, svårighetsgrad (KD), intent. Sparat källmärkt i
  `seo/volumes-semrush-se.json` (source, database, `hamtad`-datum).
- **`phrase_questions`** för `bostadsbidrag` och `försörjningsstöd` → verkliga
  People-Also-Ask-formuleringar (vem kan få / vem har rätt till / hur mycket /
  vad krävs) — underlag för svarsobjekten/FAQPage. Även sparat i snapshotet.
- **`tools/seokeywords.mjs`** joinar nu in volym/CPC/difficulty ur snapshotet på
  normaliserad nyckel och stämplar `volume_source = semrush:se:2026-08-28`.
  **16 rötter** fick verklig volym vid denna körning. Determinismen behålls
  (datumet ligger i data, inte i väggklockan); fabrikation är fortfarande omöjlig
  — generatorn kopierar bara det snapshotet innehåller. Curerad `intent` rörs ej.

**Uppmätt efterfrågan (databas se, Semrush 2026-08-28):**

| Term | Volym/mån | KD | Not |
|---|---|---|---|
| ekonomiskt bistånd | 27 100 | 34 | joinad root |
| bostadsbidrag | 22 200 | 44 | head-term (ej egen root — se nedan) |
| försörjningsstöd | 18 100 | 31 | head-term (ej egen root — se nedan) |
| aktivitetsstöd | 12 100 | 23 | joinad root · låg KD |
| bidrag | 12 100 | 35 | joinad root |
| tandvårdsbidrag | 9 900 | 30 | joinad root |
| bostadstillägg | 8 100 | 31 | joinad root |
| studiebidrag | 5 400 | 37 | joinad root |
| csn bidrag | 4 400 | 45 | head-term |
| underhållsstöd | 3 600 | 26 | joinad root · låg KD |
| glasögonbidrag barn | 1 900 | 24 | head-term · låg KD |
| arvsfonden | 1 300 | 28 | head-term |
| etableringsersättning | 1 000 | 23 | joinad root · låg KD |

**Intent:** nästan alla kärntermer klassas **informationell (1)** — bekräftar
"own the answer"-strategin (svarssida före verktyg), inte kommersiella
landningssidor.

**Belägg för §29-indexregeln:** den konversationella long-tailen
`vad har jag rätt till för bidrag` har **0 uppmätt volym**. Det är verkligt
belägg för att mall-swap-sidan inte förtjänar att vara ett självständigt
sökresultat — precis vad indexerbarhetsmotorn redan säger. Vi gissade rätt, och
nu är det uppmätt.

**Prioritering (låg KD × verklig volym = vinnbart först):** underhållsstöd (26/
3 600), glasögonbidrag barn (24/1 900), etableringsersättning (23/1 000),
aktivitetsstöd (23/12 100), arvsfonden (28/1 300). Höga men svårare:
ekonomiskt bistånd (34/27 100), bostadsbidrag (44/22 200).

**Medveten avgränsning (ingen tyst IA-ombyggnad):** de rena head-termerna
(`bostadsbidrag`, `försörjningsstöd`, `csn bidrag`, `arvsfonden`, `söka bidrag`,
`glasögonbidrag barn`, `projektbidrag`) finns i dag bara som delar av längre
entity-/manuella rötter, inte som egna rötter. Att tvångsmappa en head-terms
volym på en mer specifik sida vore oärligt (fel sida får huvudefterfrågan), så
joinen hoppar dem korrekt. Deras uppmätta volym finns bevarad med full proveniens
i `seo/volumes-semrush-se.json`. Att lyfta in dem som egna kategori-rötter är ett
**medvetet kureringsbeslut** (roots-manual + hub-sida + kannibaliseringskoll),
inte en sidoeffekt av ett volymjoin — spåras som uppföljning.

### Vercel — deployläge
- Team: `wolfoftyreso-debug's projects` (slug `hypbit`, Pro).
- Projekt: piotrr, personal-phone, kansli, tyra-temp, tora, britt,
  quixzoom-landing, quixzoom-v2, evasvensson-site.
- **Inget `bidragskoll`/`bidrag`-projekt finns.** Produkten är **inte deployad
  än** — stämmer med den öppna uppgiften "Deployn själv". Live preview/loggar/
  runtime-verifiering är därför **BLOCKED** tills projektet skapas (görs via
  `docs/DEPLOY-AGENT.md` + Supabase; att skapa det är en setup-/kommersiell
  åtgärd, inte något jag gör tyst).

### Resend — e-postläge
- 12 domäner på kontot. **Ingen `bidragskoll.se`-avsändardomän finns.** Närmast
  är `landvex.se` (den juridiska personen Landvex AB bakom produkten) — och den
  har **status `failed`** (ej verifierad). Verkligt deploy-beredskapsgap för
  transaktionell e-post: avsändardomänen för Bidragskoll är inte uppsatt.
- **Inga mallar** i Resend — konsistent: appen renderar sin egen e-post-HTML och
  skickar rå via adaptern; inga Resend-hostade mallar förväntas.

## AVAILABLE BUT NOT NEEDED
- **Stripe** — kontot `Sommarliden Holding` (**livemode**) är orelaterat till
  Bidragskoll. Betalning är Swish Handel, bundet i koden. Verifierat, inte rört.
- **Apollo.io** — B2C-produkt; Apollo är B2B-prospektering och drar krediter.
  Ingen läsning gjord (skulle spendera krediter utan produktsyfte).
- **Anthropic Economic Index** — mäter Claude-användning, inte svensk bidrags-
  eller arbetsmarknadsdata; ingen produktrelevans.
- **Mobbin** — produkten är byggd; UX-benchmark är lågt marginalvärde nu.
- **Gmail / Drive / Calendar / Slack / Gemini / Scholar Gateway** — ingen aktuell
  yta i denna produkt.

## BLOCKED
- **Vercel runtime-/deploy-verifiering** — inget projekt finns; kräver att
  deployn körs (`docs/DEPLOY-AGENT.md`, Supabase). Setup-/kommersiell åtgärd.
- **Resend skarp avsändarverifiering** — `bidragskoll.se`-domän saknas och
  `landvex.se` är `failed`; DNS-/domänverifiering är en operatörsåtgärd på
  riktig domän. Ej gissad.
- **Gmail leveransverifiering** — beror på att ett skarpt mejl faktiskt skickas
  från en verifierad domän; blockerat av raden ovan.

## Vad detta INTE gjorde (medvetet)
Inga skrivningar mot någon extern tjänst: inga Stripe-produkter, inga Vercel-env/
projekt, inga skickade mejl, inga Apollo-krediter. Alla connector-anrop var
läsningar utom det som skrevs i **repot** (källmärkt Semrush-snapshot + joinad
keyword-databas). Skarpa domän-/deploy-/betalningsåtgärder kräver operatörens
beslut och riktiga credentials och är listade som BLOCKED, inte bortförklarade.
