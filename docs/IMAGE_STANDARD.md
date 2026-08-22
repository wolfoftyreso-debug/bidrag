# IMAGE STANDARD — Bidragskoll.se

Bilder läggs aldrig in för att "SEO behöver bilder". Varje bild fyller ett av
syftena: förklaring, orientering, mänsklig kontext, statistik, illustration,
process, jämförelse. Förbjudet: generiska stockbilder (leende familjer,
handslag, mynt, människor som pekar på laptops).

## Nuläge (Audit 01)

Publika ytan har **medvetet noll innehållsbilder** (rena, snabba svarssidor).
Bidragskolls egen bildvärld är illustrationsbiblioteket i
`design/illustrationer/` (22 geometriska figurer; regler i design/README:
max 3 färger ur paletten, kontur 2,5px i --primary-deep, varm markrad, inga
ansikten/gradienter, aldrig ren dekor, en figur per skärm, storlekar
24/72/96–120px). Appens illustrationer är dekorativa med korrekt tom
alt/aria-hidden. OG-bilden är varumärkesbyggd (1200×630, designsystemets
typografi — inte en maskinbanner).

## Standard för varje framtida publicerad bild

1. **Filnamn**: beskrivande kebab-case — `bostadsbidrag-inkomst-exempel.webp`,
   aldrig `IMG_84739.jpg`.
2. **Format**: WebP/AVIF för foto/diagram, SVG för illustrationer/figurer.
3. **Dimensioner**: width/height-attribut alltid satta (CLS-skydd);
   responsiva srcset-storlekar när bilden är innehållsbärande.
4. **Laddning**: `loading="lazy"` under vikningen; aldrig på LCP-bilden.
5. **Alt-text**: beskriver bildens funktion och innehåll för den som inte ser
   den — aldrig keyword-stuffing; dekorativa bilder får `alt=""`.
6. **Caption/credit/källa**: när bilden bär data (diagram/statistik) ska
   källa och analysdatum stå i bildtexten, inte bara i metadata.
7. **Metadata i filen** (title/creator/copyright/source/datum) bevaras eller
   sätts där relevant — men ersätter aldrig korrekt HTML, alt, captions,
   structured data eller sidkontext.
8. **Diagram** följer även dataviz-reglerna i innehållsmotorn: metod +
   avgränsning + källa på sidan.

## Automatiserad kontroll

När den första innehållsbilden införs byggs mediakontrollen in i seocheck:
filnamnsmönster, format, width/height, alt-närvaro (tom alt tillåten endast
med data-decorative), vikt (tak per bildtyp), och att OG-bilder håller
1200×630. Tills dess vaktar seocheck redan OG-bildens närvaro på varje sida.
Regeln är absolut: **en bild som inte klarar kontrollen publiceras inte.**
