# SEO_TEAM_PLAN — teamstruktur, arbetssätt och 15-dagarsplan

Datum: 2026-08-21 (masterprompt 2 §28–29, §32.8–32.9). OBS ärlighet: idag
utförs arbetet av EN agent med subagenter — planen nedan är den beställda
organisationsmodellen för 30 personer, användbar som struktur redan nu
(agentroller) och som rekryteringsplan senare.

## Fördelning (30 personer → 6 arbetsströmmar)

| Ström | Roller | Antal | Första leverans | QA-ägare |
|---|---|---|---|---|
| Program | programansvarig + SEO-strategisk ledare | 2 | beslutslogg + tiers | programansvarig |
| Data & keywords | keyword-/dataanalytiker 3 + teknisk SEO/data engineering 3 | 6 | GSC-inkoppling, volymdata in i keywords.json, rank tracking | teknisk SEO-lead |
| SERP & konkurrens | SERP-/konkurrentanalytiker | 6 | SERP_OWNERSHIP-databas för Tier 1–2 (svensk geo-SERP, inte USA-proxy) | SEO-strateg |
| Språk & innehåll | lingvister/content strategists 3 + bidragsresearch/faktagranskning 4 + QA-/huvudredaktör 1 | 8 | Tier 1-guiderna (12 st) med källgranskning | huvudredaktör |
| Användare & design | användar-/personaforskare 3 + UX-/servicedesigners 3 | 6 | intervjurunda 1 (PER-001, -009, -011, -012) + navigationstest (§25) | forskningsledare |
| Livscykel & integritet | lifecycle/CRM-strateg 1 + integritets-/policyansvarig 1 | 2 | kanalmatris-granskningen (AMBER-listan) + consent-flöden | integritetsansvarig |

## Arbetsobjekt-ID:n (§29) — implementerade konventioner

ENT-#### (answer entities — idag: seedens sluggar är kanoniska ID:n) ·
QRY-###### (queries — seo/questions-*.json) · PER-### (personor —
seo/personas.json, PER-001…PER-012 finns) · SERP-###### (SERP-analyser) ·
SRC-###### (källor — seedens sources är grunden) · CNT-#### (content nodes —
our_target_url i keywords.json). Gemensamma format = de maskinläsbara
filerna i seo/; versionshistorik = git; ägare per objekt sätts när teamet
finns.

## Kvalitetsgrindar (§31 — gäller från dag ett, även för agenten)

Ingen Tier 1-leverans godkänns med: påhittad volym · omärkt hypotes ·
stereotyp-persona · inaktuell SERP-analys · ignorerade myndighetsstyrkor ·
intent-duplicering · sida för en ordvariation · fakta utan primärkälla ·
myndighetsimitation · känslig remarketing · osamtyckt spårning · saknat
användarvärde.

## 15-dagarsplan (§32.9)

| Dag | Aktivitet | Leverans | Beslutspunkt/risk |
|---|---|---|---|
| 1–2 | Deploy + GSC-verifiering + sitemap-inskick | Live publik yta; GSC-konto | BESLUT: användaren kör docs/DEPLOY-AGENT.md (blockerar allt mätarbete) |
| 2–3 | Svensk geo-SERP-verifiering av Tier 1 (google.se, inte USA-proxy) | uppdaterad SERP_OWNERSHIP | Risk: avvikelser mot USA-indexet — dokumentera diffar |
| 3–7 | Tier 1-guiderna: 12 redaktionella sidor (answer-first, källor, YMYL-språk) enligt frågematrisen | /guider/-lagret | GRIND: huvudredaktörs-QA + faktagranskning mot primärkällor före indexering |
| 5–8 | Intervjurunda 1: 4 personor (PER-001, -009, -011, -012), 3–5 intervjuer per persona | evidensuppgradering HYPOTHESIS→styrkta profiler | BESLUT: rekryteringsväg (får ej rapporteras genomförd innan den är det) |
| 8–10 | Navigationstestet §25: tre ingångar + "Vad har förändrats i din situation?" | testresultat + val av huvudnavigation | Produktbeslut |
| 10–12 | Deadlinehubb-MVP (datum finns i seeden: MUCF/Boverket-mönstret) | /bidrag/deadlines-prototyp | GRIND: endast verifierade datum visas |
| 12–14 | GSC-loop v1: första riktiga queries in i keywords.json (VERIFIED) | volymkolumnerna börjar fyllas | Först nu får prioritering väga volym |
| 15 | Fasrapport + beslut om Tier 2 | uppdaterad SEO_STRATEGY | BESLUT: skala eller korrigera |

## Beslut som krävs av användaren innan nästa fas

1. Deployn (dag 1 — allt mätarbete är blockerat utan den).
2. GSC + ev. volymkälla (Keyword Planner/tredjeparts-API) — vem skaffar access.
3. Intervjurekrytering (kanal, ersättning, etik) — innan personor får kallas evidensbaserade.
4. AMBER-kanaler: om någon alls ska övervägas → juridisk + plattformspolicygranskning först.
5. Navigationstestets ramar (om det ska köras med riktiga användare eller först som intern prototyp).
