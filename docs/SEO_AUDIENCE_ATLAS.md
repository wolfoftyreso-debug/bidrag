# SEO Audience Atlas — den verkställande målgruppsbedömningen

Status: **FÖRSTA KÖRNINGEN** (masterprompt 2 §32) · 2026-08-22
Evidensklasser genomgående: **VERIFIED** (officiell källa läst i denna session),
**INFERRED** (härledd ur verifierade data), **HYPOTHESIS** (rimlig, obevisad),
**DATA_REQUIRED** (kan inte avgöras utan data vi saknar).

Syskondokument: `seo/personas.json` (12 profiler), `seo/search-language-grammar.json`
(113 mönster), `docs/SEO_AUTHORITY_MAP.md` (20 källor), `docs/SEO_ANSWER_CLUSTERS.md`,
`docs/SEO_RETENTION_STRATEGY.md`, `docs/SEO_DATA_ACCESS_MATRIX.md`, `docs/SEO_TEAM_PLAN.md`.

Grundregel (repets regel 1): ingenting i detta dokument är påhittat. Varje siffra
bär källa och årtal; det vi inte vet står under "Det vi antar" eller är märkt
DATA_REQUIRED.

---

## 1. De fyra målgruppsledarna

Modellen: fyra "ledare" — breda behovssituationer som var och en leder ett kluster
av personas, frågespråk och innehållsnoder. Prioritering sker per ledare, inte per
bidragsnamn (behov före bidragsnamn, masterprompt 2 §6).

### Ledare A — Hushållet där pengarna inte räcker
*Personas: PER-001, PER-002, PER-003, PER-007, PER-008, PER-009, PER-010*

**Det vi VET (VERIFIED):**
- 137 200 hushåll fick bostadsbidrag 2025 (Försäkringskassan).
- Av de ca 114 000 barnfamiljerna med bostadsbidrag var ca 76 000 (54 % av samtliga
  bidragshushåll) ensamstående kvinnor med barn (Försäkringskassan, 2025).
- Ca 247 000 **personer, inklusive barn**, levde i hushåll med ekonomiskt bistånd
  någon gång under 2025 (Socialstyrelsen). Obs: personer, inte hushåll.
- 350 176 personer var inskrivna arbetslösa hos Arbetsförmedlingen (juli 2026).

**Det vi ANTAR (INFERRED/HYPOTHESIS):**
- INFERRED: mörkertalet är stort — myndigheternas egna kalkylatorer är bra men
  öar; ingen samlad "vilka stöd kan JAG få"-ingång finns (docs/SEO_AUTHORITY_MAP.md,
  tvärmönster 1). Det är exakt Bidragskolls lucka.
- HYPOTHESIS: sökspråket är symtomdrivet ("pengarna räcker inte", "hjälp med hyran")
  snarare än bidragsnamnsdrivet, i högre grad än för andra ledare. Beläggs delvis av
  SERP-materialet (`docs/SEO_SERP_RESEARCH.md`), kräver querydata (DATA_REQUIRED).
- Integritetsrisken är högst här (RED-listan i `docs/SEO_RETENTION_STRATEGY.md` är
  absolut: ingen remarketing, inga målgrupper, inga lookalikes på denna ledare).

### Ledare B — Studier och omställning mitt i livet
*Personas: PER-004, PER-005*

**Det vi VET (VERIFIED):**
- 987 500 personer fick studiestöd från CSN under 2025 (CSN).
- SCB/ULF **2023**: 57 % av befolkningen 16–84 år hade använt e-legitimation mot
  offentlig sektor senaste året; 24 % avstod från digitala myndighetstjänster av
  minst ett skäl. (Årtalet är 2023 — cite aldrig som färskare.)

**Det vi ANTAR:**
- INFERRED: kombinationsfrågorna ("studiemedel + bostadsbidrag samtidigt?",
  "omställningsstudiestöd + a-kassa?") är underbetjänade eftersom varje myndighet
  bara svarar för sin ö — kombinationsinnehåll är Bidragskolls starkaste innehållstyp
  för ledare B (`docs/SEO_ANSWER_CLUSTERS.md`).
- HYPOTHESIS: omskolaren (PER-004) googlar på kvällar/helger från mobil, i
  planeringsläge snarare än akut läge — annat tonläge, längre innehåll fungerar.

### Ledare C — Livshändelsen som ändrar allt
*Personas: PER-002, PER-006, PER-007, PER-008, PER-010 (överlappar A/B per definition)*

Separation, uppsägning, sjukskrivning, barns diagnos, flytt till Sverige. Ledaren
är händelsedriven, inte tillståndsdriven — det syns i frågespråket ("nyseparerad
vad har jag rätt till", "blivit uppsagd vad göra").

**Det vi VET (VERIFIED):** delmängderna ovan (arbetslöshets- och biståndssiffrorna).
**Det vi ANTAR:** HYPOTHESIS: händelsequeries har lägst konkurrens och högst
intentionsvärde eftersom myndigheterna organiserar per förmån, inte per händelse
(tvärmönster 2 i authority map). Onboarding-frågan "Vad har förändrats i din
situation?" är produktens spegel av denna ledare. DATA_REQUIRED: volymer.

### Ledare D — Organisationen som söker finansiering
*Personas: PER-011, PER-012*

**Det vi VET (VERIFIED):**
- 54 723 jordbruksföretag 2025 (Jordbruksverket).
- Ideella sektorn: ca 159 300 ideella föreningar (SCB **2019** — äldsta siffran i
  atlasen; NOT_CONFIRMED om nyare finns; cite alltid med årtal).

**Det vi ANTAR:**
- INFERRED: B2B-spåret har lägst integritetsrisk (organisationsdata, inte känsliga
  personkategorier) → enda ledaren där GREEN/AMBER-retargeting alls kan övervägas
  (`docs/SEO_RETENTION_STRATEGY.md`).
- HYPOTHESIS: kommersiell konkurrens (konsulter, Almi-ekosystemet) är hårdast här;
  organisk lucka finns i "kan vår förening/vårt AB söka X"-frågor där 6 av 12
  granskade org-källor inte tar individansökningar alls (authority map).

---

## 2. Audience Priority Score (§14-modellen)

Poängmodell per ledare/persona-kluster. Fem faktorer, 0–5, viktade:

| Faktor | Vikt | Vad den mäter |
|---|---|---|
| Behovsintensitet | ×3 | Hur akut/avgörande behovet är för användaren |
| Räckvidd | ×2 | Verifierad populationsstorlek (siffrorna i §1) |
| Underbetjäning | ×3 | Hur dåligt existerande källor besvarar behovet (authority map) |
| Produktpassning | ×2 | Hur väl motorn + 72 stöd faktiskt hjälper i dag |
| Integritetsbörda | ×(−2) | Känslighetskategori — hög börda SÄNKER priot för betald aktivering (aldrig för organiskt innehåll) |

**Poängen är en beslutshjälp, inte data**: faktorvärdena nedan är INFERRED/HYPOTHESIS
utom Räckvidd (VERIFIED). Räkneexempel, första körningen:

| Ledare | Behov | Räckvidd | Underbetj. | Passning | Integritet | Summa |
|---|---|---|---|---|---|---|
| A — Hushållet | 5 | 4 | 4 | 5 | 5 | 15+8+12+10−10 = **35** |
| C — Livshändelsen | 5 | 3 | 5 | 4 | 4 | 15+6+15+8−8 = **36** |
| B — Studier/omställning | 4 | 4 | 4 | 4 | 2 | 12+8+12+8−4 = **36** |
| D — Organisationen | 3 | 2 | 3 | 4 | 0 | 9+4+9+8−0 = **30** |

Tolkning (medvetet jämn): **innehållsordning C → B → A → D** för nyproduktion
(händelse- och kombinationssidor först — störst lucka), medan **A förblir etisk
förstaprioritet i produkt/UX** (störst behovsintensitet, absolut RED-skydd).
D är lönsam nisch, inte kärna. Omräknas när querydata finns (DATA_REQUIRED).

---

## 3. Personasammanfattning

12 hypotesprofiler i `seo/personas.json` (schema §10, alla fält). Samtliga är
**HYPOTHESIS** tills tre evidenstyper stödjer dem (§12: querydata + officiell
statistik + intervju/test) — endast räckviddspåståendena ovan är VERIFIED.
Namnen är pedagogiska etiketter, inte demografiska påståenden; inga individdata.

| Persona | Ledare | Integritetsrisk |
|---|---|---|
| PER-001 Ensamstående förälder med varierande arbetstid | A | HÖG |
| PER-002 Nyseparerad förälder | A/C | HÖG |
| PER-003 Ung vuxen i första egna boendet | A | MEDEL |
| PER-004 Mitt-i-livet-omskolaren | B | MEDEL |
| PER-005 Studerande förälder | B | MEDEL–HÖG |
| PER-006 Nyligen arbetslös tjänsteman | C | HÖG |
| PER-007 Förälder till barn med funktionsnedsättning | A/C | MYCKET HÖG (art. 9) |
| PER-008 Sjukskriven med inkomsttapp | A/C | MYCKET HÖG (hälsa) |
| PER-009 Pensionär med låg pension | A | HÖG |
| PER-010 Ny i Sverige under etablering | A/C | MYCKET HÖG |
| PER-011 Småföretagaren som ska anställa | D | LÅG–MEDEL |
| PER-012 Föreningskassören | D | LÅG |

Konsekvens av riskkolumnen: för MYCKET HÖG-personas gäller RED-listan utan
undantag — deras behov betjänas med organiskt innehåll, e-post de själva bett om,
och produktens egna ytor. Aldrig betald aktivering, aldrig segmentexport.

## 4. Digital förmåga och språk (tvärgående)

- VERIFIED: 57 % e-legitimationsanvändning / 24 % avstår-siffran (SCB/ULF 2023)
  säger att en betydande minoritet inte nås av "logga in och se"-lösningar —
  Bidragskolls publika, inloggningsfria svarssidor är därför inte bara SEO utan
  tillgänglighetspolitik.
- HYPOTHESIS: PER-010 (och delar av PER-009) behöver klarspråk + lättläst variant;
  flerspråkigt innehåll är RECOMMENDED men **inte** i första körningen (§32 —
  ingen massproduktion).

## 5. Användarforskningsplan (§15) — innan hypoteserna får bli sanningar

1. **Search Console-data efter deploy** (första riktiga querykällan): 90 dagars
   insamling → validera/underkänn frågespråksgrammatiken familj för familj.
   Kostnad 0. DATA_REQUIRED tills GSC är verifierat.
2. **5–8 användarintervjuer per ledare A och C** (rekrytering via ideella partners,
   ersättning, aldrig ur produktens egna känsliga data): validera behovstillstånd,
   trösklar, språk. Personas uppdateras med `evidence_sources`.
3. **Användningstest av tre huvudingångar** (masterprompt 2 §25): "berätta din
   situation", "vad har förändrats", "sök på stöd" — mäts på fullföljandegrad
   i onboarding, inte på klick.
4. **Innehållstest**: 3 händelsesidor (ledare C) publiceras först och mäts i GSC
   (visningar/klick/position) innan klustret skalas — `docs/SEO_EXPERIMENTS.md`.
5. Etikregel för all forskning: deltagare är aldrig produktanvändare rekryterade
   via deras känsliga status; samtycke skriftligt; rådata raderas efter analys.

## 6. Beslut som krävs (av produktägaren)

1. **Godkänn prioritetsordningen C → B → A → D för innehållsproduktion** (eller
   justera vikterna i §2 — modellen är transparent och omräkningsbar).
2. **Bekräfta RED-listan som produktpolicy** (docs/SEO_RETENTION_STRATEGY.md) —
   den utesluter hela kategorier av betald tillväxt; det är ett affärsbeslut,
   inte bara ett juridiskt.
3. **GSC-verifiering direkt efter deploy** (docs/SEO_BASELINE.md-loopen startar där).
4. **Budget/nej till intervjustudien i §5.2** — utan den förblir personas
   HYPOTHESIS och atlasen får inte citeras som kundinsikt.
5. **Flerspråksfrågan** (§4): beslut om lättläst/engelska/fler språk hör till
   nästa körning, inte denna.

---

*Uppdateringsregel: när en siffra i §1 blir äldre än 18 månader eller en ny årgång
publiceras — uppdatera med källa + årtal eller märk NOT_CONFIRMED. Dokumentet får
aldrig citeras utan evidensklassen intill påståendet.*
