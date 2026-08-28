# ENTITY FOOTPRINT — Bidragskoll.se

Mål (§18–19, §27–28): Bidragskoll ska existera konsekvent över internet, och
en användare som googlar "Bidragskoll" ska möta ett extremt tydligt varumärke.
Nuläge (Audit 01): **CRITICAL C4** — ingenting existerar; brand-SERP:en ägs av
namngrannen Bidragskollen (RobIsr/Mindful Innovations-appen) och dränks i
"bidragskalkyl" (redovisningstermen). Verifierat 2026-08-22.

## ENTITY_MASTER_RECORD (sanningskällan — fylls i av användaren där ⬜)

| Fält | Värde |
|---|---|
| Varumärkesform | **Bidragskoll.se** (fullform i titlar/OG); "Bidragskoll" i löpande text |
| Domän (kanonisk) | https://bidragskoll.se |
| Tagline | "Berätta din situation — se vilka stöd du ser ut att kunna ha rätt till." |
| Beskrivning (60 s-versionen) | Svensk konsumenttjänst som gör ekonomiskt stöd begripligt: gratis genomgång av din situation mot en kurerad kunskapsbas med källa och kontrolldatum; analys 39 kr; att ansöka själv hos myndigheten är alltid gratis. Fattar inga myndighetsbeslut. |
| Logotyp/märke | Taklinje + bock på rundad signalblå ruta (`apps/web/public/logo-mark.svg` = enda källan, `tools/genbrand.mjs` härleder favicon/app-ikoner/OG); ordbild i Source Serif 4 |
| Färger | #232c58 / #3d4a8c / #d9b96a / #f7f5f0 (design/bidragskoll.css) |
| Juridisk enhet | ⬜ (Landvex AB enligt betalytan — bekräfta + orgnr) |
| Kontakt-e-post | ⬜ |
| Officiella konton | ⬜ (se aktiveringsordning) |

Alla ytor (webb, OG, konton, register, presskit) hämtar från detta record —
samma namn, beskrivning, logotyp, domän och kontaktuppgifter överallt.

## Aktiveringsordning (efter deploy; kräver användaren)

1. **Google Search Console** — verifiering + sitemap (dag 1).
2. **LinkedIn-företagssida** — första kontot: komplett profil, rätt namn/URL/
   beskrivning/märke, och ett verkligt första inlägg (folkbildningsformatet,
   §20). **Regel: inga döda konton — ett konto öppnas först när det har en
   publiceringsplan.**
3. **En andra kanal** vald efter målgruppsatlasen (Facebook för ledare A är
   trolig kandidat) — samma krav.
4. Registerytor: korrekt bolagsinformation där den redan förekommer
   (allabolag-typ-sajter speglar Bolagsverket — kontrollera att uppgifterna
   stämmer, skapa inget falskt lokalt Google-företag).
5. `sameAs` läggs in i Organization-schemat i genseo **först när URL:erna
   finns på riktigt** — aldrig platshållare.

## Sociala konton som bildande institution (§20)

Formatet är folkbildning, inte "fem tips 💸": *"Du frågar: kan man få
bostadsbidrag om man arbetar?"* → kort svar → förklaring → exempel →
officiell källa → länk till guiden. Allt innehåll följer LANGUAGE_GUIDE
(provokation uppåt, aldrig nedåt) och bär källa.

## Brand-SERP-bevakning (§28)

Efter deploy, återkommande (in i baseline-loopen): sök "Bidragskoll",
"Bidragskoll.se", "bidragskollen" + vanliga felstavningar; dokumentera
resultat, sitelinks, favicon-visning, sammanblandningar. Målet: egen entitet
skild från både namngrannen och redovisningstermen. Mention-motorn (§25)
aktiveras när omnämnanden börjar finnas: klassificera länkad/olänkad/ton,
och erbjud artigt korrekt käll-URL vid olänkade journalistiska omnämnanden —
ingen aggressiv länkbegäran.

## Pressytan (§26)

Byggs med Trust Center (spec: TRUST_CENTER_SPEC.md): logotyper, fakta,
metodik, kontakt, senaste rapporter, citatbara siffror — journalisten ska
förstå Bidragskoll på 60 sekunder.
