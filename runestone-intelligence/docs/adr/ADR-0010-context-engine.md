# ADR-0010: Context Engine — berätta mer än det som står skrivet

**Status:** Accepted · **Datum:** 2026-08-16

## Kontext

Produktmålet är mervärde vid runstensbesöket: turisten och den historiskt
intresserade ska få veta **så mycket som går att veta** om varje sten och
dess skapare — period, ristare, stil, skrift, seder, kristnandet — inte
bara översättningen. Risken är uppenbar: "berätta mer" får aldrig glida
över i påhittade fakta om den enskilda stenen.

## Beslut

### 1. Kontext levereras som källstatus-märkta block

Varje block bär `kind` + `source`:

| Kind | Betyder | Källa |
|---|---|---|
| `established` | Belagt om **just denna sten** | Corpusfält: carver, style, dating, region (`corpus:<fält>`) |
| `interpreted` | Härlett ur inskriftens innehåll | L2 (`interpretation:people` m.m.) |
| `general_background` | Sann om **epoken/seden**, inte ett påstående om stenen | Versionerat bibliotek (`library:<id>@v1`) |

UI:t kan därmed alltid skilja "om den här stenen" från "om tiden den
restes i" — formuleringar som "brukar dateras" hör till bakgrund,
aldrig till belagda fakta.

### 2. Biblioteket är kuraterat, versionerat och försiktigt

`GENERAL_LIBRARY`/`STYLE_LIBRARY` i `knowledge/context.py` innehåller
endast okontroversiell standardkunskap (minnesseden, yngre futharken,
kristnandet, brobyggande som from gärning, stilgruppernas grova
dateringar). Utökningar går genom review som all annan kod; blocken
citerar biblioteksversionen.

### 3. Villkorade block styrs av evidens

Kristnande-blocket visas bara när inskriften faktiskt bär bön/kors
(L2-handling `prayer_offered`); bro-blocket bara vid `bridge_built`;
ristarblocket skiftar mellan belagd ristare (corpus) och
anonymitets-bakgrund. Kontext följer stenen, inte en mall.

### 4. Berättelsen komponeras känsla-först

`compose_story`: L3-renderingen först, sedan människorna (interpreted),
sedan det belagda, sist tidsbilden. LLM-fördjupningen körs senare under
`CONTEXT_SPEC` med samma hårda regler (inga fria fakta om enskild sten;
osäkerhet löses med ärlig formulering) — och skriver aldrig `established`-
block själv.

## Konsekvenser

- API-svaret får `context` (blocken) + `story` (komponerad text); okänd
  sten får aldrig `established`-block (testfäst).
- Kuraterat kontextinnehåll blir en ny, försvarbar datatillgång
  (utöver corpus): berättelselagret per sten.
- Framtida per-sten-fördjupningar (t.ex. historiska händelser en inskrift
  refererar) läggs som `established`-block med källcitat i corpus — aldrig
  i det generella biblioteket.
