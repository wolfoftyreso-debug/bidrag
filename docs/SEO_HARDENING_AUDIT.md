# SEO Hardening Audit — verifiera verkligheten, inte påståendena

Oberoende adversarial revision efter SEO-buildprompten + ticketbackloggen. Regel:
anta inte att något fungerar för att en tidigare agent säger det — verifiera mot
den faktiskt genererade ytan och koden. `CLAIMED_NOT_VERIFIED` = fel tills motsatsen
bevisats. Fynd åtgärdas, testas om, bevisas.

Ref: `artifacts/seo-site` (126 sidor, 105 indexerbara), `apps/web/index.html`,
seeden. Gate efter passet: `npm run verify` 19/19.

## Domar per revisionspunkt

| § | Dimension | Dom | Evidens |
|---|---|---|---|
| 2 | Adversarial Googlebot (no-JS) | **FYND → ÅTGÄRDAT** | `index.html` hade 0 H1/0 länkar/0 text i `<body>` utan JS. Fix: crawlbar `<noscript>`-fallback med H1 + svar + 8 interna länkar in i statiska ytan. |
| 3 | Indexeringssimulation | VERIFIED | varje URL har explicit INDEX/NOINDEX; sitemap = 105 (NOINDEX exkluderade), canonicals self-referential (`seocheck`) |
| 4 | Kannibalisering | **FYND → ÅTGÄRDAT** | detektorn gav falska 0.5-träffar från titelboilerplate ("– villkor, belopp och ansökan", "– stöd och bidrag"). Fix: jämför distinkt titelsegment + H1. Resultat: **0 reella risker** på 105 sidor. |
| 5–9 | Informationsdensitet / 5-sek / zero-knowledge / TTA / progressive eligibility | VERIFIED (statisk yta) | Query/flaggskepp/entity-sidor leder med svar → CTA → data; en-fråga-per-skärm i appen; doctrine.mjs gatear "värde före betalning" |
| 10 | Negativa svar | VERIFIED (motor) | matchmotorn ger uteslutning med skäl (`packages/core`); "Uppfyller inte kraven" i demo/webb |
| 11 | Databassanning | VERIFIED | `seo-dataqa`: 72/72 stöd har källa; inga dubbletter; giltig finansiär |
| 12 | Relativa datum | VERIFIED + polish | `Calendar.tsx` filtrerar passerade deadlines FÖRE nedräkning (ingen stale "5 dagar kvar"); grammatikfix "1 dag/0 = sista dagen idag" |
| 13 | Officiella länkar | VERIFIED | `sourceUrl` (information) och `applicationUrl` (ansökan) är SEPARATA fält per stöd; `seo-dataqa` kräver båda giltiga; kanaldetaljer i `APPLICATION_CHANNELS.md` |
| 14 | Transparens | VERIFIED | sidfot på varje sida: "oberoende … inte en myndighet … källa … senast kontrollerad", synlig utan att läsa villkor |
| 15 | Structured data vs verklighet | VERIFIED | inga fabricerade `AggregateRating`/`Review`; FAQPage-svaren renderas synligt (Snabbsvar); Organization/adress/org.nr = verkliga publika uppgifter; index.html-offers nu backade av synlig `<noscript>`-pristext |
| 16 | AI entity stress | PARTIAL | `semantictest` offline PASS (10/10 kärnpåståenden); full `--llm`-körning mot flera modeller = BLOCKED_EXTERNAL (kräver `ANTHROPIC_API_KEY`) |
| 17–20 | Konkurrent-red-team / bäst-i-test / prisjämförelse | N/A (ej byggt) | jämförelsehubben finns inte ännu (EPIC G TODO); ingen egenbias/UNKNOWN-som-fakta att åtgärda förrän den byggs — grund i `SEO_COMPETITORS.md` |
| 21–25 | Search Console-gap / snippets / PAA / länkprofil | BLOCKED_EXTERNAL | kräver GSC/DataForSEO/Ahrefs (EPIC B/K) |
| 26–28 | Partnerwidgets / YouTube / SAGA | N/A (ej byggt) | EPIC I/J — BLOCKED_EXTERNAL / produktarbete |
| 29 | Programmatic spamrisk | VERIFIED | Indexability-motorn: aktiviteter utan stöd → DO_NOT_GENERATE, tunna → NOINDEX_FOLLOW; "vore sidan användbar utan Google?" ja för INDEX-sidorna (verklig bidragsdata) |

## Åtgärdade fynd (denna audit)

1. **F1 — Homepage osynlig för crawler (§2, allvarligast).** `/` (SPA) hade
   ingen crawlbar kärna utan JS, och renderar dessutom inloggning för utloggade.
   Fix: `<noscript>`-fallback i `apps/web/index.html` med H1 "Se vilka bidrag du
   kan få", gratis-modellen och 8 interna länkar in i den statiska ytan
   (`/vilka-bidrag-kan-jag-fa/`, hubbar, katalog, finansiärer, status).
2. **F2 — Kannibaliseringsdetektorn brusig (§4).** Jämförde titelboilerplate →
   falska träffar. Fix: `tools/seo-cannibalization.mjs` jämför nu distinkt
   titelsegment (före "–"/"|") + H1. 0 reella risker.
3. **F3 — Grammatik i deadline-nedräkning (§12).** "1 dagar kvar" → "1 dag kvar"
   / "sista dagen idag". Kärninvarianten (ingen stale-open) var redan korrekt.

## Kvarstående fynd → uppföljningsticket (ej åtgärdat i detta pass)

- **F4 — Utloggad `/` renderar inloggning, inte produktens svar (§2, djupare).**
  `<noscript>` täcker no-JS-crawlers/AI, men en JS-renderande crawler ser
  `LoginPage`. Riktig fix = publik landningssida (målgruppsval + svar) som
  utloggad startvy, med inloggning sekundär. Produkt/UX-ändring i auth-flödet →
  eget ticket (SEO-049 fördjupning). Flaggat i `SEO_PROGRAM.md`.

## Inga falska "det fungerar"

Punkter som kräver externa datakällor (GSC/Semrush/Ahrefs/DataForSEO) eller
obyggda features (jämförelsehub, widgets, YouTube/SAGA) är märkta N/A eller
BLOCKED_EXTERNAL — inte "PASS". Ingen audit-punkt lämnas i "vet inte".
