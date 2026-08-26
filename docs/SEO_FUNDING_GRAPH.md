# SEO-3/4 — Bidragsgrafen + Own the Answer (Release A)

Bidragskoll ska inte bara ranka på sökord — SEO-sidorna ska vara **vyer över
kunskapsgrafen**, inte fristående AI-artiklar. Samma verifierade data driver
produktmatchning, SEO-yta och maskinförståelse.

## 1. Entitetsmodellen (grafen)

Grafen genereras ur sanningsmodellen (`apps/api/src/seed/data.ts`) till
`seo/kunskapsgraf.json` (`tools/genkgraf.mjs`). Kärnentiteter som redan är
förstklassiga objekt med relationer:

| Entitet | Källa | Relationer |
|---|---|---|
| **Stöd** (funding) | seed opportunities | ges_av → finansiär · riktar_sig_till → målgrupp · kräver/väger_in → kriterium · relaterad → stöd |
| **Finansiär** (provider) | seed authorities | — |
| **Målgrupp** (applicant) | applicantTypes | privatperson, företag, förening, ekonomisk förening … |
| **Kriterium** (eligibility rule) | criteria (factPath, op) | — |
| **Sektor/behov** (activity/need proxy) | sectors | energi, miljö, innovation, kultur, ungdom, idrott, jordbruk … |
| **Intention** (search intent) | `seo/search-intents.json` | besvaras_av → stöd (via filter) |
| **Deadline** | deadlineModel/opensAt/closesAt | förstklassig datatyp, driver `/bidragsstatus/` |
| **Källa** (provenance) | sourceUrl + lastVerifiedAt | varje stöd länkar sin officiella primärkälla |

Applicant, situation, aktivitet, geografi och kostnadskategori som **egna
nodtyper** (utöver dagens sektor-proxy) hör till Release B — se §Deferred.

## 2. Query Pages — vyer över grafen ("own the answer", SEO-4)

En **intention = en stark sida**, inte ett sökord = en artikel. Registret
`seo/search-intents.json` definierar varje intention med ett `filter` som
resolveras mot grafen till **verkliga aktiva stöd**. Sidan byggs i ordningen
**svar → verktyg (CTA) → datavy → förklaring → FAQ** — aldrig artikel → artikel
→ CTA. Genereras av `tools/genseo.mjs`, länkas från målgruppshubbarna
("Vanliga sökningar") och tillbaka in i katalogen.

## 3. Indexability-motorn (SEO-3/§5)

Bara för att en kombination finns i databasen ska den inte indexeras. Varje
kandidat får en dom utifrån **verklig datatäckning** — vi har ingen verifierad
sökvolym (`search_volume: null`), så vi påstår aldrig efterfrågan vi inte mätt:

- **INDEX** (≥3 matchande stöd) — self-canonical + i sitemap.
- **NOINDEX_FOLLOW** (1–2 stöd) — genereras för människor, `robots noindex,follow`, utanför sitemap.
- **DO_NOT_GENERATE** (0 stöd) — skapas inte.

Aktivitetsintentioner (anställa, köpa maskiner, investering enskild firma)
landar korrekt i DO_NOT_GENERATE tills kunskapsbasen kurerats för aktiviteterna
(matchar den kända KB-luckan i `docs/LAUNCH_DEMAND_INTELLIGENCE.md` §8, kluster
10–12). Motorn vägrar ärligt en tom sida — data-driven SEO, inte spam.

Delad motor: `tools/lib/intents.mjs` (genseo + rapporten). Full domtabell:
`docs/SEO_QUERY_PAGES.md` (`tools/indexability.mjs`, `--check` i verify).

## 4. Kontrollrapport SEO-3 (aktuell dom)

**Knowledge Graph:** 5 nodtyper (stöd, finansiär, målgrupp, kriterium, intention)
+ deadline/källa som attribut · 72 stöd, 35 finansiärer, 100 kriterier ·
relationer utan källa: 0 (varje stöd bär sourceUrl).

**Query Pages:** 13 kandidater → **9 INDEX · 1 NOINDEX_FOLLOW · 3 DO_NOT_GENERATE**
(se `docs/SEO_QUERY_PAGES.md`). SEO-ytan 79 → 90 sidor.

**Search Intent:** 13 intentioner, var och en äger ett kluster query_variants;
ingen påhittad sökvolym; ingen kannibalisering (Query Pages är materiellt mer
specifika än målgruppshubbarna).

**Data Assets:** `/bidragsstatus/` (levande datavy ur seeden) **byggd**.
Bidragskalender, Bidragsindex, förändringshistorik, källproveniens-graf: Release B.

## 5. Own-the-answer-principer (SEO-4, bindande)

- **Query → Answer → Tool → Data → Explanation** på varje viktig sökintention.
- **Verktyget är innehållet** — vi vinner på Time To Answer, inte på ordmängd.
- **Öppna, citerbara sidor** — publik bidragskunskap utan konto/betalning/
  JS-beroende för kärninnehållet (Open Grant Pages). Personlig kontroll kan
  kräva konto när det faktiskt behövs.
- **Prata inte om AI** — "Vi hittade fyra möjligheter", inte "vår AI analyserade
  24 000 möjligheter". Tekniken är intern; resultatet är produkten.

## 6. Deferred (Release B/C — kräver extern data/produktarbete)

Byggs inte med påhittad data. Kräver GSC/SERP-verktyg, licensierade org-nr-
källor eller produktfunktioner i appen:

- **Situations- & aktivitetsnoder** som egna entiteter (anställa, investera,
  energieffektivisera) + kurering av stöd för dessa → öppnar de DO_NOT_GENERATE-
  intentionerna.
- **Fler datatillgångar:** `/bidragskalender/`, `/nya-bidrag/` (funding feed ur
  verkliga DB-händelser), `/bidragsindex/`, förändringshistorik per stöd,
  proveniens-graf (claim → source snapshot → fetched_at → reviewer).
- **SERP Intelligence** (lagrad SERP per query), **Content Gap Engine**
  (oss vs Grantigo vs SERP), **SEO Control Center** + nattlig opportunity queue —
  alla kräver GSC/SERP-data (`seo/serp-*.json` finns som grund).
- **"Why this / Why not" + "Similar grants"** i matchningen — produktfunktioner
  i appen (core/api), inte statisk SEO.
- **Org-nummer → första bidragsbilden** — kräver licensierad/officiell datakälla;
  bygg aldrig på gissad företagsdata.
- **`semantictest --llm` i CI** som schemalagd regression.
