# PERFECTION BASELINE — Audit 01 (2026-08-22)

Doktrinen: **PERFECTION IS THE PRODUCT** — perfektion = frånvaro av friktion,
inkonsekvens och slarv, i alla lager samtidigt. Detta dokument är
nollmätningen; varje ny audit skriver en ny daterad sektion ovanpå.
Underlag: `tools/seoaudit.mjs`, `docs/SEO_REVISION_01.md`, uicheck12/13,
demons kontroller, WCAG-passet B1 (motförhöret), färsk brand-SERP.

## Gradering (18 områden)

| Område | Betyg | Motivering + fynd |
|---|---|---|
| Brand | ~~CRITICAL~~ → **MEDIUM** | Var: ingen favicon någonstans (default-ikon i flik/SERP), ingen OG-bild. **Åtgärdat i denna audit** (C1, C2). Kvar: entity footprint (C4) och namnförväxlingen bidragskalkyl/Bidragskollen (SEO_REVISION_01 R7). |
| Design | **EXCELLENT** | Bläck-systemet med design/ som källa, komponentbibliotek, illustrationsregler, CTA-hierarki. LOW: skeleton-/empty-/error-states ännu inte systematiserade som komponenter (DESIGN_CONSTITUTION §Status). |
| UX | **HIGH** (fynd) | UX-konstitutionen uppfylls i huvudflödena (en fråga/skärm, feedback, tillbaka-väg, källor synliga). HIGH: användarfeedback-mekanism saknas helt (§45); publik intern sökning saknas (§41 — planerad i B1). 404 var tyst hem-teleport — **åtgärdat** (C3). |
| Språk | **MEDIUM** | Klarspråk + bedömningsspråket vaktas i dokumentmotorn (GENERIC_CONTENT-detektorn), men ingen central guide fanns. **LANGUAGE_GUIDE.md + seo/terminologi.json (20 termer) skapade i denna audit.** Kvar: automatisk termkonsekvenskontroll av publika ytan (§37). |
| Accessibility | **MEDIUM** | B1-passet gjort (fokusföljning, ringar, reduced motion, art. 9-flödet); Bläck höjde textkontrasten (~6,5:1); chevron-regressionens fix visade att gaten fungerar. Kvar: full WCAG 2.2 AA-genomgång med hjälpmedel (docs/LIMITATIONS.md, planerad). |
| Image SEO | **LOW** (fynd) | Publika ytan har medvetet inga innehållsbilder (inget att fela på); appens illustrationer är dekorativa med korrekt tom alt. OG-bild nu kvalitetsbyggd. IMAGE_STANDARD.md styr framtida bilder; automatisk mediakontroll byggs när första innehållsbilden införs. |
| Teknisk SEO | **EXCELLENT** | 0 orphans, djup ≤2, unika titlar/desc, lang=sv, ren HTML utan JS. Soft-404-hålet (hela okända /bidrag/* gav 200) — **åtgärdat** (C3): äkta 404.html + noindex + rewrite-exkludering + seocheck-vakt. MEDIUM kvar: render-blockerande fonter (R6 — mäts i fält efter deploy). |
| Sitemap | **EXCELLENT** | 1:1 mot genererade sidor, validerad i verify/CI; 404 exkluderad. Sitemap-index per innehållstyp införs när situationssidorna landar (backlog LOW). |
| Canonical | **EXCELLENT** | Policy nu skriven (SEO_RELEASE_GATE §Canonical): trailing slash konsekvent, en kanonisk form per sida, verifieras av seocheck. https/apex-beslutet exekveras vid deploy. |
| Schema | **EXCELLENT** | Centraliserad i genseo: Organization/WebSite/BreadcrumbList/WebPage, valideras i QA-crawlen; inga falska ratings/FAQ/författare. MEDIUM backlog: typad schemagenerator som modul när fler sidtyper byggs (§17). |
| Social metadata | ~~CRITICAL~~ → **EXCELLENT** | Var: og:image/twitter saknades överallt; webbappen saknade all OG. **Åtgärdat** (C2): varumärkes-OG 1200×630 (ej maskinbanner), twitter:card, og:locale, per sida; seocheck failar utan. MEDIUM backlog: dynamiska per-sida-OG-bilder (§11). |
| Performance | **EXCELLENT** (lokalt) | 8–16 kB HTML, inga tredjepartsskript, preconnect+swap på fonter. Fältdata (LCP/INP/CLS) = DATA_UNAVAILABLE till deploy; interna mål i SEO_RELEASE_GATE. |
| Entity footprint | **CRITICAL (C4 — kräver användaren)** | Inget existerar: inga sociala konton, ingen registerpost synlig, brand-SERP ägs av namngrannen + bidragskalkyl-förväxlingen. ENTITY_FOOTPRINT.md skapad med ENTITY_MASTER_RECORD; kontona kan bara användaren öppna. |
| Trust | **HIGH** (fynd) | Villkor/ångerrätt/GDPR-självservice finns i appen; ärlighetsstämpeln unik. HIGH: publik Trust Center-sektion saknas (spec klar: TRUST_CENTER_SPEC.md); rättelsepolicy saknas (ingår i specen). |
| Content quality | **HIGH** (fynd) | = SEO_REVISION_01 R2/R3: fakta-arken starka men 12/20 moduler saknas och 8/13 ETTA-MÖJLIG-kluster utan sida. Åtgärdsväg fastlagd (F0 → B1–B10); ingen ändring av den domen här. |
| Internal linking | **EXCELLENT** | Median 8 länkar/sida, naturliga ankartexter, kunskapsgrafen som källa framåt. |
| Source quality | **EXCELLENT** | Varje stöd: officiell käll-URL + CURATED_AT + kureringsstämpel; source-fetch snapshot/diff kör var 6:e timme. MEDIUM backlog: fullt source object (§34: effective date, sektion, versionshistorik publikt). |
| Update mechanisms | **MEDIUM** | Motorn finns (source-fetch-diff, curator-reminders, stale-match-recalc) men §35-kedjan diff→berörda publika sidor→review-task→publicerad ändringshistorik är inte sluten — det är F0-modul 16 + gransknings-kön. |

## CRITICAL-läget efter Audit 01

| # | Fynd | Status |
|---|---|---|
| C1 | Ingen favicon/brand assets någonstans | **ÅTGÄRDAT**: eget märke (guldbock på indigo — "koll"), favicon.svg/.ico, apple-touch, PWA-ikoner 192/512, webmanifest, theme-color; i webbapp + alla 77 publika sidor |
| C2 | Social metadata saknades (og:image, twitter, webbappens hela OG) | **ÅTGÄRDAT**: varumärkes-OG-bild + komplett OG/twitter överallt; seocheck failar bygget utan |
| C3 | Soft-404: alla okända URL:er gav 200 + SPA (indexeringsgift) och appens 404 var tyst redirect | **ÅTGÄRDAT**: genseo emitterar hjälpsam 404.html (noindex, §40-språk), vercel-rewriten exkluderar den statiska ytan, SPA fick riktig 404-vy |
| C4 | Entity footprint obefintlig | **SPEC KLAR — kräver användaren** (konton, register); ENTITY_FOOTPRINT.md |
| C5 | Ej deployad (SEO_REVISION_01 R1) | **Användarens steg** — allt mätarbete blockerat tills dess |

HIGH-fynden och all vidare prioritering: `docs/PERFECTION_BACKLOG.md`.

## Nästa audit

Audit 02 körs efter: deployn + F0 + B1–B5. Då tillkommer fältdata (CWV, GSC),
brand-SERP-omkontroll (§28) och Perfection Score per Tier 1-sida (§47 —
tröskel 95, ett felaktigt belopp = FAIL oavsett totalpoäng).
