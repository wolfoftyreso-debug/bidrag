# TRUST CENTER SPEC — Bidragskoll.se

Radikal transparens som produktyta (§43–44). Status: **spec — byggs som
statiska sidor i genseo** (utanför /bidrag/, kräver seocheck-utökning för ny
sidgrupp + sitemap-post). Prioritet H2 i PERFECTION_BACKLOG.

## Sidstruktur

`/om/` — navet, med undersidor (eller sektioner tills innehållet motiverar
egna URL:er):

1. **Vilka vi är** — juridisk enhet, kontakt (ur ENTITY_MASTER_RECORD),
   vad Bidragskoll är och uttryckligen **inte** är: ingen myndighet, fattar
   inga beslut, lovar inga pengar, ändrar inga regler. Manifestet (§54) i
   kortform.
2. **Hur tjänsten finansieras** — prismodellen ordagrant: gratis upptäckt,
   39 kr analysupplåsning, 19 kr per förberedd ansökan; att ansöka själv hos
   myndigheten är alltid gratis; inga annonser, ingen försäljning av
   användardata, inga provisionsländer till långivare.
3. **Hur informationen tas fram** — källmetodiken: varje stöd byggs från
   officiell källa med käll-URL + "senast kontrollerad"; kureringsstämpeln
   ("AI-sammanställd från officiell källa — ej granskad av människa") och vad
   den betyder; källbevakningen (automatisk kontroll var 6:e timme, diff →
   granskning); evidensnivåerna A–D för framtida erfarenhetsinnehåll.
4. **Hur fel hanteras (rättelsepolicyn, §44)** — publikt löfte: fel rättas
   skyndsamt; betydande korrigeringar dokumenteras synligt på berörd sida med
   datum; timestamp uppdateras ALDRIG utan verklig kontroll; beroende sidor
   kontrolleras vid varje rättelse. + "Rapportera ett fel"-väg (feedback H1).
5. **Personuppgifter** — vad som samlas in, varför, art. 9-hanteringen
   (hälsofrågan är frivillig, avböjande respekteras permanent), självservice
   (export/radering), ingen remarketing på känsliga kategorier (RED-listan är
   policy, inte bara juridik).
6. **Press** (§26) — logotyper (favicon.svg + ordbild), 60-sekundersfakta,
   metodikbeskrivning, kontakt, senaste rapporter/datasets när F3 landar,
   citatbara verifierade siffror (ur OFFICIAL_STATISTICS-lagret, alltid med
   källa och årtal).

## Regler

- Allt innehåll ur befintliga sanningskällor (villkor, LIMITATIONS,
  ACTIVATION, atlasen) — Trust Center får aldrig påstå mer än systemet gör.
- Samma gate som övriga publika ytan (SEO_RELEASE_GATE) + JSON-LD
  Organization på /om/ blir schemats kanoniska hem (sameAs läggs här när
  kontona finns).
- Sidorna länkas från footern på varje publik sida och från appens villkor.
- Kända begränsningar döljs inte: LIMITATIONS-punkterna som rör användare
  (t.ex. mänsklig granskning pågår) redovisas i klartext.
