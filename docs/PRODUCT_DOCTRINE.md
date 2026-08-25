# PRODUCT DOCTRINE — Bidragskoll.se

> Detta är ett **styrdokument**, inte en vision. Principerna nedan är låsta och
> försvaras av kod: `tools/doctrine.mjs` körs i `npm run verify` och fäller
> bygget om en användarvänd yta börjar bryta mot den bärande invarianten.
> Ändra aldrig doktrinen utan att samtidigt uppdatera kontrollen — och
> tvärtom.

Status: LÅST 2026-08-25. Revideras efter varje större produkt- eller
positioneringsändring. Nulägesdom mot doktrinen: `docs/DOCTRINE_AUDIT.md`.

---

## 1. Positioneringen (en mening)

**Bidragskoll är inte en sökmotor där du själv måste veta vad du söker. Det är
en upptäcktsmotor som tar reda på vad du kan ha rätt till.**

Direkt tilltal:

> Du behöver inte veta vilket bidrag du söker. Berätta vem du är, så
> kontrollerar vi vad som kan vara aktuellt.

Produktmässigt:

> Från situation till möjlighet — inte från bidragsnamn till ansökan.

## 2. Den bärande invarianten (det som är kod)

**Användaren ska aldrig behöva känna till stödet — dess namn, dess kategori,
dess myndighet eller dess stödform — för att få värde ur systemet.**

Detta är inte en känsla. Det är ett testbart krav, och det är vad
`tools/doctrine.mjs` verifierar. Konsekvenser:

- Intaget frågar aldrig efter myndighetsbegrepp när svaret kan härledas ur
  vanlig svenska. "Vad vill ni genomföra?" — inte "Vilken stödberättigande
  insats avser projektet?".
- Ingen skärm ber användaren välja eller namnge ett bidrag som inträdesbiljett.
- Systemet översätter internt vardagssvenska → stödtyp, kostnadsslag,
  statsstödsregler, målgrupp och behörighetskriterier. Användaren ser aldrig
  översättningen som ett krav på sig.

## 3. De fyra lagren — och var vi börjar

En komplett bidragsresa har fyra lager. Konkurrenter som är projekt-/
ansökningsdrivna börjar typiskt vid **lager 2–3** och förutsätter att
användaren redan har ett projekt, ett syfte och ibland ett underlag att bifoga.
Det gör dem relevanta främst för redan bidragsvana. **Bidragskoll börjar vid
lager 1.**

| Lager | Fråga | Vår hållning |
|---|---|---|
| **1. Upptäckt** | Vilka stöd kan över huvud taget vara relevanta för mig? | **Här börjar vi.** Berätta vem du är. |
| 2. Kvalificering | Uppfyller jag villkoren, och vad saknas för att avgöra det? | Motorn utreder; öppna frågor sorteras efter informationsvärde. |
| 3. Ansökningsförberedelse | Vilka uppgifter, dokument och formuleringar behöver jag? | Systemet förbereder — 19 kr/ansökan, alla dokument ingår. |
| 4. Genomförande | Hur ansöker jag, följer ärendet och hanterar nästa steg? | Kalender, deadlines, "ansök själv gratis"-väg alltid synlig. |

Användaren vet inte vad hen inte vet: inte vad stödet heter, vilken myndighet
som hanterar det, vilken stödform som gäller, vilka egenskaper i situationen som
är relevanta, eller vilka möjligheter hen borde fråga efter. **Att lösa det är
hela poängen.**

## 4. Ordningen — värde före underlag

Första värdet ska komma **innan** dokumentuppladdning och **innan** betalning.
Ingen ska behöva leta fram affärsplan, årsredovisning, projektbeskrivning eller
andra underlag innan systemet visat att det sannolikt finns något relevant.

Rätt ordning:

1. Lätt profilering (situation, vanlig svenska).
2. Preliminära relevanta möjligheter (teaser: att de finns, hur många, på
   vilken nivå — aldrig namn/källa före upplåsning).
3. Några intelligenta följdfrågor (sorterade efter hur många stöd de avgör).
4. Prioriterad analys (39 kr upplåsning).
5. **Först därefter** eventuella dokument (19 kr/ansökan).

Dokument används för att **fördjupa och verifiera**, aldrig som inträdesbiljett.

## 5. Frågor användaren förstår

Bidragskoll frågar aldrig efter myndighetsbegrepp när systemet kan härleda
svaret från vanlig svenska.

| Dålig fråga (förbjuden i intag) | Bra fråga |
|---|---|
| "Vilken typ av stödberättigande insats avser projektet?" | "Vad vill ni genomföra?" |
| "Ange stödform" | "Vad kommer pengarna främst att användas till?" |
| "Vilket bidrag söker du?" | "Har ni redan börjat köpa in eller beställa något?" |
| "Välj finansiär" | "Vilka kommer att få nytta av satsningen?" |

Systemet mappar internt svaren till stödtyp, kostnadsslag, statsstödsregler,
målgrupp och behörighetskriterier.

## 6. Var doktrinen ska genomsyra

Startsidan · onboardingflödet · annonser · SEO-sidor · resultatkort ·
betalningssteget · jämförelsesidor · produktdemonstrationer. En yta som bryter
mot §2 är en bugg, inte en smaksak.

## 7. SEO-konsekvensen — situation före bidragsnamn

Vi konkurrerar självklart om namn-/kategorisökningar ("projektbidrag",
"bostadsbidrag", "skriva bidragsansökan"), men vår försvarbara vallgrav är
**lagret före** dessa sökningar — där användaren beskriver sig själv, inte ett
bidrag:

- vilka bidrag kan jag få · har jag rätt till något bidrag · bidrag jag inte
  visste fanns
- stöd för ensamstående · ekonomiskt stöd vid låg inkomst · bidrag när man är
  sjukskriven · stöd för barnfamiljer
- stöd för nystartat företag · stöd för företag som vill anställa · stöd för att
  köpa maskiner · stöd för energieffektivisering
- bidrag för idrottsföreningar · vilka stöd kan vår förening söka · hjälp att
  hitta rätt bidrag

Ontologin organiseras därför kring **vem användaren är, vilken situation hen är
i, vad hen vill uppnå, vilken förändring som inträffat, vilka resurser/
begränsningar som finns, och vilken kombination av villkor som skapar
behörighet** — inte enbart kring bidragsnamn och myndigheter. Detaljerad
struktur och gap-map: `docs/SEO_SITUATION_ONTOLOGY.md`. Artikeln informerar;
motorn avgör relevansen.

## 8. Testkriteriet (acceptans)

> En testperson **utan** förkunskap om svenska stöd ska kunna få minst tre
> förklarade kandidater **utan att ange ett bidragsnamn**.

Detta är den mänskliga motsvarigheten till §2. Körs i praktiken av
`tools/simulate30.mjs` (personor utan bidragskunskap) och bevakas strukturellt
av `tools/doctrine.mjs`.

## 9. Förhållande till övriga doktriner

- **Perfektionsdoktrinen** (`docs/PERFECTION_BASELINE.md`) — frånvaro av
  friktion. Denna doktrin är dess produktstrategiska rot: den största
  friktionen är att kräva förkunskap.
- **Perfect Application Constitution** (`docs/APPLICATION-INTELLIGENCE.md`) —
  styr lager 3 (kvaliteten i det förberedda). Denna doktrin skyddar lager 1.
- **Språkguiden** (`docs/LANGUAGE_GUIDE.md`) — vardagssvenska; §5 här är dess
  produktkrav.
- **SEO Release Gate** (`docs/SEO_RELEASE_GATE.md`) — §7 här styr ontologin
  gaten mäter.
