# DOCTRINE AUDIT — nulägesrevision mot produktdoktrinen

Revisionsdatum: 2026-08-25. Doktrin: `docs/PRODUCT_DOCTRINE.md`.
Metod: källkodsläsning med bevis (fil:rad) — inga antaganden godtas som
nulägesbeskrivning. Den strukturella delen av denna revision är permanent kod
i `tools/doctrine.mjs` (körs av `npm run verify`); dokumentet nedan är den
mänskliga genomgången yta för yta.

Dom i en mening: **Bidragskoll börjar redan vid lager 1.** Intaget, frågemotorn,
teasern och betalningsordningen håller doktrinens bärande invariant (§2). Två
genuina luckor kvarstår, båda i utkanten (SEO-lagret och en transparensparitet)
— ingen i kärnflödet.

Skala: **KONFORM** · **NOT** (konform men värt att notera) · **LUCKA** (bör
byggas) · **BROTT** (bugg — får inte finnas).

---

## Yta 1 — Routes & skal · KONFORM

`apps/web/src/App.tsx` — det inloggade skalet leder med Översikt/Projekt/
Ansökningar/Sök; ingen route kräver att användaren namnger ett bidrag för att
komma in. 404-sidan (`App.tsx:157`) erbjuder "Till din översikt" + "Se alla
stöd" — situations- och upptäcktsvägar, inte en sökruta för bidragsnamn.

## Yta 2 — Onboarding · KONFORM (kärnbeviset)

Första förgreningen är situationsbaserad, i vanlig svenska, utan ett enda
bidragsnamn:

- Webb: `apps/web/src/pages/Onboarding.tsx:483` "Vad behöver du hjälp med?" →
  `:487` "Jag har svårt att få ekonomin att gå ihop" · `:492` "Jag söker pengar
  till ett projekt eller en verksamhet".
- Demo: `demo/main.tsx:980` samma fråga → `:981–982` samma två val, med
  guidance "…många stöd är sådana man inte vet att de finns".

Efterföljande frågor fortsätter situations-först: "Bor du själv eller
tillsammans med någon?" (`:987`), "Har du barn som bor hos dig?" (`:994`), "Har
du någon gång haft svårt att betala för en skolutflykt…" (`:1012`), "Behöver
något av dina barn glasögon?" (`:1022`). Systemet härleder stöd internt —
användaren möter aldrig stödformer, myndighetsbegrepp eller finansiärsval.
Personnummer efterfrågas aldrig (`:1032` "vi behöver inget personnummer").

## Yta 3 — Frågemotor · KONFORM

Öppna följdfrågor sorteras efter informationsvärde (hur många stöd de avgör) —
F-INFOVÄRDE, redan byggt. Relevansen är deterministisk: ett stöd vars domän
inte bekräftats för personens situation får aldrig föreslås (F-RELEVANS,
bevakas av `tools/audit-relevans.mjs`). Motorn får härleda och gissa relevans
men aldrig kräva att användaren själv känner till stödet — exakt doktrin §2.

## Yta 4 — Resultat & teaser · KONFORM

Värde före betalning: `apps/web/src/pages/Matches.tsx:61` — teasern visar antal
per sannolikhetsnivå och kategori **före** upplåsning och "aldrig namn eller
källor". Paywallen (`:274`, `AnalysisPaywall`) kommer **efter** att användaren
sett att relevanta stöd finns. Det är doktrin §4 i kod: att-det-finns är
gratis; vilka + källa + förberedelse är det betalda värdet.

## Yta 5 — Betalning · KONFORM

"Ansök själv — gratis ↗" är synlig i resultatvyn (`Matches.tsx:427`) och
villkoren säger uttryckligen att ansöka själv direkt hos myndigheten alltid är
gratis (`Terms.tsx:24`; demo `main.tsx:735`). Betalningen köper förberedelse
och analys, aldrig tillgången till att veta att stödet finns. Ingen
dokumentuppladdning krävs innan värde visats (dokument hör till lager 3, efter
analys).

## Yta 6 — SEO-ytan · NOT + LUCKA

**NOT (konform):** entity-sidorna (`/bidrag/<stöd>/`) landar med bidragets namn
— korrekt, det fångar namn-/kategorisökningar (lager 2–3). Avgörande: varje
sådan sida routar tillbaka in i upptäcktsmotorn — `tools/genseo.mjs:295` "Låt
Bidragskoll utreda din situation". Artikeln informerar; motorn avgör
relevansen. Konform.

**LUCKA (bygg):** lagret *före* namnsökningarna — situations- och
behovssökningar ("stöd för ensamstående", "har jag rätt till något bidrag",
"stöd när man ska anställa") — är tunt. Idag finns 4 målgruppshubbar
(`genseo.mjs:47` `HUBS`) och inga `/situationer/`-sidor. Det är precis den
försvarbara vallgraven i doktrin §7 som ännu inte är byggd som indexerbar yta.
→ åtgärdas i `docs/SEO_SITUATION_ONTOLOGY.md` (ontologi + gap-map klar; sidorna
byggs i innehållsmotorns F0→F1, se `docs/CONTENT_ENGINE.md`).

## Yta 7 — Transparensparitet · LUCKA (mindre)

Demon har en "Varför ställs frågan?"-knapp vid varje fråga (`demo/main.tsx`,
2 förekomster) som förklarar varför systemet frågar — en stark
förtroendeaffordans som stödjer §2 (användaren ser att frågan är begriplig och
motiverad). Webbappens `Onboarding.tsx` saknar den (0 förekomster). Den betalda
produkten bör inte vara mindre transparent än demon. Liten, men värd en egen
post i `docs/PERFECTION_BACKLOG.md`.

---

## Sammanfattande dom

| Yta | Dom |
|---|---|
| Routes & skal | KONFORM |
| Onboarding | KONFORM |
| Frågemotor | KONFORM |
| Resultat & teaser | KONFORM |
| Betalning | KONFORM |
| SEO-ytan | NOT (entity) + LUCKA (situationslager) |
| Transparensparitet | LUCKA (mindre) |

**Inga BROTT i kärnflödet.** Doktrinen är inte en ambition för Bidragskoll —
den är den byggda produkten. De två luckorna är expansion (situations-SEO) och
polering (info-knapp i webben), inte reparation. Strukturella brott fångas
fortsättningsvis automatiskt av `tools/doctrine.mjs` i verify.
