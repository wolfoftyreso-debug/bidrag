# Produktdefinition — V1

## V1 gör en enda sak

1. Användaren öppnar tjänsten.
2. Fotograferar en runsten.
3. Skickar bilden.
4. Får resultatet.

Resultatet innehåller minst:

- identifierad inskrift (om systemet kan identifiera den),
- runisk läsning/translitterering,
- modern svensk översättning,
- confidence/grad av säkerhet,
- markering av osäkra eller skadade delar,
- källa för den historiska tolkningen.

## Uttryckligen INTE i V1

- Ingen social funktion.
- Ingen konto-/communityfunktion.
- Ingen avancerad forskningsportal (backend ska dock stödja research mode).
- Ingen karta som huvudfunktion.
- Ingen generell kulturhistorisk chatbot.

## Tekniskt mål

Systemet optimeras inte för att generera plausibel text utan för:

> **korrekt observerad text + korrekt runologisk tolkning + verifierbar översättning.**

## Mobil UX (tre lägen)

1. **Ta bild** — kameran öppnas direkt.
2. **Analyserar** — enkel progress: "Läser inskriften...".
3. **Resultat** —

   ```
   U 489
   "..."
   På modern svenska:
   "..."
   Säkerhet: 94 %
   3 runor är osäkra.
   ```

Användaren ska inte behöva förstå runologi.

## Osäkerhet är en förstaklassfunktion

Resultatet ska kunna säga "Systemet är osäkert på 3 runor". Användaren kan
trycka på en osäker runa och se kandidater:

```
Rune 14
Candidate A: ᚢ — 61 %
Candidate B: ᚦ — 29 %
Damaged/unknown — 10 %
```

Systemet ska hellre säga "Otillräcklig bildkvalitet" än skapa en falskt säker
översättning.

## Vetenskaplig säkerhetsregel

Systemet får aldrig presentera en maskinell tolkning som vetenskapligt
etablerad när källorna är oense. Varje resultat klassas som:

`Established | Probable | Uncertain | Alternative readings | Insufficient evidence`

## Geolocation

GPS är valfri men värdefull: `GPS → nearby known stones → candidate ranking`.
Systemet ska fungera fullt ut utan GPS.

## Field mode (efter MVP)

Appen ska kunna instruera aktivt: "Flytta kameran närmare", "För mycket
motljus", "Få med hela inskriften", "Försök från sidan". Med användarens
uttryckliga samtycke blir fältbilder träningskandidater — men
användargenererade bilder betraktas aldrig automatiskt som ground truth.

## V1 Definition of Done

V1 är klar när systemet kan:

- [ ] ta emot ett mobilfoto,
- [ ] upptäcka en runinskrift,
- [ ] identifiera känd sten när möjligt,
- [ ] läsa runor,
- [ ] producera translitterering,
- [ ] matcha mot canonical corpus,
- [ ] producera svensk översättning,
- [ ] visa confidence,
- [ ] visa osäkra delar,
- [ ] visa källor,
- [ ] köras i Kubernetes,
- [ ] vara reproducerbart från Git,
- [ ] klara RUNEBENCH-GOLD med dokumenterade resultat.
