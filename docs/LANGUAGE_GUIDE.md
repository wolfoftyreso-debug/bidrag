# BIDRAGSKOLL LANGUAGE GUIDE

Språket optimeras lika hårt som SEO. Termkällan är `seo/terminologi.json`
(§36 — en benämning per begrepp, deprecated-listor, källor); denna guide är
reglerna runt den. Dokumentmotorns GENERIC_CONTENT-detektor och
ödmjukhetsprotokollet (Perfect Application Constitution) gäller oförändrat.

## 1. Rösten

Bidragskoll är **den extremt pålästa personen bredvid dig som kan hela
systemet men aldrig får dig att känna dig dum.** Inte överlägsen,
moraliserande, politisk, byråkratisk eller desperat säljande — men inte
heller rädd, urvattnad eller anonym. Vi vågar säga: *"Det här är onödigt
svårt. Vi gör det begripligt."*

## 2. Grundprincipen: vardagsspråk + officiell term

Skriv: **"Du kan behöva visa vad du tjänar."**
Inte: "Sökanden ska inkomma med underlag som styrker den aktuella
förvärvsinkomsten."
Men behåll alltid den officiella termen där den behövs:
**"Myndigheten kallar detta *förvärvsinkomst*."**
Varje myndighetsterm som används ska vara förklarad (terminologi.json) —
ingen oförklarad jargong någonsin.

## 3. Hårda skrivregler

- **Du-tilltal.** Korta meningar (riktvärde ≤ 20 ord; en tanke per mening).
- **Belopp**: alltid "12 345 kr" (hårt mellanslag som tusentalsavgränsare,
  "kr" — aldrig "SEK", ":-" eller "kronor" i tabeller). Belopp skrivs ENDAST
  när de kommer ur faktalagret med källa — aldrig ur minnet.
- **Datum**: "12 mars 2026" i löptext, "2026-03-12" i tabeller/metadata.
  Aldrig "12/3".
- **Osäkerhet** uttrycks alltid, aldrig döljs: "ser ut att kunna", "beror på",
  "kommunen bedömer", "vi behöver en uppgift till". Förbjudet: "garanterat",
  "du får", "chans att beviljas" (utan publicerad statistik), "berättigad".
- **Beslut**: "Slutligt beslut fattas alltid av myndigheten" — ordagrant,
  på varje yta där en bedömning visas.
- **CTA:er** är verb + vad som händer: "Förbered ansökan — 19 kr",
  "Starta genomgången", "Till Försäkringskassans ansökan". Aldrig "Klicka
  här", "Läs mer" som ensam ankartext.
- **Felmeddelanden**: lugnt språk, vad hände, vad du kan göra, ingen teknisk
  dump. 404-mönstret: "Vi hittar inte sidan — men vi kan fortfarande hjälpa
  dig." Fel är också produkt (§40).
- **Gratisvägen**: "Att ansöka själv direkt hos myndigheten är alltid gratis"
  — intill varje köpknapp, ordagrant eller likvärdigt.

## 4. Förbjudet

Skam eller brådska som säljmedel · moraliserande om bidragstagande ·
myndighetshån (provokation riktas **uppåt mot systemet, aldrig nedåt mot
människan** — §21) · "AI-genererat"-ursäkter i användartext (ärlighets-
stämpeln är saklig, inte ursäktande) · emoji-säljspråk ("💸") · utropstecken
i sakinnehåll · kanslisvenska när vardagssvenska räcker.

## 5. Kontrollerad provokation (§21–22, institutionell friktion)

Vi får synliggöra systemets absurditeter så konkret att systemägare känner
sig träffade — men läsaren ska aldrig kunna kalla oss oseriösa. Varje
provokativ formulering ska bäras av data, metodik, skärmdumpar och källor.
Tillåtna mönster: "Det ska inte krävas fyra myndighetswebbplatser för att
förstå vilket stöd som gäller." Otillåtet: fabricerade misslyckanden,
konflikt för engagemangets skull, hån mot tjänstemän eller bidragstagare.

## 6. Begreppsbildning (Bidragskolls egna ord)

Vi bygger ett eget språk i samhällsdebatten: *bidragsgapet*, *stöddjungeln*,
*missade stöd*, *sökfriktion*, *bidragsblindhet*, *stödkartan*. Regel: ett
begrepp används publikt först när det har (1) en definition i
terminologi.json, (2) en egen datapunkt bakom sig, (3) redovisad metodik.
Begreppen aktiveras med F3-rapporterna (backlog L4) — vi definierar samtalet,
vi lånar det inte.

## 7. Kvalitetskontroll

**Språkvakten är kod:** `npm run lang:check` (`tools/langcheck.mjs`, i verify
och CI sedan 2026-09-04, backlog M5 stängd) kontrollerar all användarvänd
text — webbens svenska källsträngar och tio översättningar, kunskapsbasen,
demon, den genererade publika ytan och `seo/publik-i18n.json` — mot §3–§4
och terminologiregistret: förbjudna löftesord (med tillåten negation och
villkorsform), kr-/datumformat, "Klicka här"/"Läs mer", utropstecken, dubbla
mellanslag, stavningskonsekvens (i dag, i stället, mejl), beslutsraden och
gratisvägen på varje yta som visar en bedömning, deprecated-termer som
huvudterm, "SEK" i engelska texter, blandade siffersystem i fa/prs/ar, och
att sidrubrik = navigationsetikett i varje språk. Stavning och grammatik i
löptext kontrolleras fortfarande redaktionellt — senaste fullständiga
genomgång: `docs/reports/SPRAK_2026-09-04.md`. Små språkfel är
förtroendefel (§37).

Tre ordval som revisionen låste (2026-09-04): matchningens märken är
**"stämmer väl med kraven" / "kan stämma" / "behöver utredas"** — aldrig
"hög sannolikhet" (läses som sannolikhet att beviljas); kontosidan heter
**"Konto & data"** överallt; varumärket i löptext är **Bidragskoll**
("Bidragskoll.se" bara som adress).
