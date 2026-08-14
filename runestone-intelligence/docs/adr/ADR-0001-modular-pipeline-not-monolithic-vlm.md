# ADR-0001: Modulär pipeline, inte en monolitisk multimodal modell

**Status:** Accepted · **Datum:** 2026-08-14

## Kontext

Generella multimodala modeller (VLM) kan producera plausibla svar direkt från
en bild, men produktmålet är *korrekt observerad text + korrekt runologisk
tolkning + verifierbar översättning* — inte plausibel text. Ett direkt hopp
`IMAGE → free-form answer` gör fel odiagnostiserbara och tolkningar
overifierbara.

## Beslut

Systemet byggs som en modulär pipeline med strukturerad evidens mellan varje
steg: image quality → detection → rectification → rune vision → runsekvens →
translitterering → normalisering → retrieval → verification → översättning →
confidence. Varje modul har egen output, egen confidence och egna metrics.

En Gemma/VLM-komponent används som baseline och potentiell
språk-/tolkningskomponent — aldrig som enda runläsare.

## Konsekvenser

- Fel kan lokaliseras till ett steg (diagnostiserbarhet).
- Varje steg kan tränas, utvärderas och bytas separat (fem loss-nivåer:
  character, sequence, transliteration, linguistic, translation).
- Mer initial komplexitet än en wrapper — accepterat, det är projektets kärna.
- Grindregel: om specialiserad modell inte slår generell baseline på rätt
  uppgift byggs ingen ytterligare komplexitet förrän orsaken är identifierad.
