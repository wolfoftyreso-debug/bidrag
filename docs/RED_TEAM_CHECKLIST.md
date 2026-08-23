# RED TEAM CHECKLIST — månatlig attack på Bidragskoll

Uppdrag (§50): försök bevisa att Bidragskoll är dåligt. Försvara ingenting.
Alla legitima fynd → PERFECTION_BACKLOG med allvarsgrad. Historik: två
red team-pass är redan körda (masterrevisionen + motförhöret) och gav bl.a.
F-EGEN, F-RELEVANS-metodiken och a11y-passet — metoden fungerar.

## Angreppsytor (gå igenom alla, varje gång)

**Sanning & fakta**
- [ ] Slumpa 10 stöd: stämmer varje belopp/villkor/deadline mot den länkade
      officiella källan JUST NU? (Ett fel = CRITICAL, oavsett allt annat.)
- [ ] Finns avslutade stöd som ser aktiva ut? Gamla belopp? Datum som
      uppdaterats utan verklig kontroll?
- [ ] Kan någon formulering läsas som löfte/beslut/garanti? ("ser ut att
      kunna" får aldrig glida till "har rätt till".)

**Relevans & bedömning**
- [ ] Bygg 5 nya elaka personor (ovanliga kombinationer) — läcker irrelevanta
      stöd? Döljs relevanta? (tools/audit-relevans.mjs + manuell genomklickning.)
- [ ] Svara "vill inte svara" på hälsofrågan — dyker den upp igen någonstans?

**UX & språk**
- [ ] Kör hela flödet på mobilvy 320px — overflow, klippta knappar, oläsbara
      tabeller?
- [ ] Tab-navigera hela köpflödet utan mus. Skärmläsarpass på intaget.
- [ ] Finns någon återvändsgränd (§42)? Någon sida som slutar i "läs mer hos
      myndigheten" utan nästa steg?
- [ ] Läs 5 sidor högt: kanslisvenska? Oförklarad term? (mot terminologi.json)

**Förtroende**
- [ ] Försök hitta något som känns säljande före hjälpsamt. Countdown?
      Förkryssat? Otydligt pris? Dold gratisväg?
- [ ] Är blur-masken verkligen informationslös? Läcker teasern något namn?
- [ ] Stämmer Trust Center-påståendena mot vad systemet faktiskt gör?

**SEO & teknik**
- [ ] Hitta en query i query-universumet där vår bästa sida är sämre än
      rank 1–3 (§51-benchmarken) — dokumentera exakt varför.
- [ ] Soft-404? Dubbletttitlar? Trasiga interna/externa länkar? Schema-fel?
      (seocheck + seoaudit + stickprov förbi verktygen.)
- [ ] Konkurrentsvep: har namngrannen, foraldrakalkylatorn, hejaolika,
      lånesajterna byggt något bättre sedan sist?

**Bedrägeri & attacker (stående svit + nya försök)**
- [ ] Kör `apps/api/test/adversarial.test.ts` — den stående sviten (pris/belopp,
      consent, gratisväg, replay, kredit-race A1, cross-tenant, mass-assignment,
      rolleskalering, mock-gate). Lägg till ett nytt attackscenario varje pass.
- [ ] Nya bedrägerivägar: kan något köp ge mer än det betalda? Nya race/TOCTOU
      i kredit-/tillståndsförbrukning? (samtidighetstest, inte bara sekventiellt.)

**Säkerhet & integritet (stickprov)**
- [ ] Försök nå annan användares data (tenant-isolation testas i sviten —
      försök förbi den). Ligger något känsligt i URL:er/loggar?
- [ ] RED-listan: syns någon känslig kategori i något som liknar spårning?

## Regler

Fynd rapporteras med reproduktionssteg + allvarsgrad, aldrig med lösning
inbakad (lösningen ägs av backloggen). Inga fabricerade fynd — red team
lyder under samma sanningsregler som alla andra. Passet avslutas med att
föregående månads fynd verifieras som faktiskt åtgärdade.
