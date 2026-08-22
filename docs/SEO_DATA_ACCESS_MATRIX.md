# SEO_DATA_ACCESS_MATRIX — datakällor: läge, ägare, värde

Datum: 2026-08-21 (masterprompt 2 §32.5).

| Källa | Status | Vem låser upp | Ger | Vikt |
|---|---|---|---|---|
| Google SERP via WebSearch | TILLGÄNGLIG (USA-index-brasklapp) | — | SERP-ägarskap, frågeformuleringar, konkurrens | Hög (enda live-källan idag) |
| Myndighetssidor via WebFetch | DELVIS (proxyn blockerar vissa domäner) | — | IA, nomenklatur, sidmallar | Hög |
| Officiell statistik (FK/Soc/CSN/SCB/AF/SJV) | TILLGÄNGLIG via SERP-belagda citat | — | målgruppsstorlekar (VERIFIED-tabellen i SEO_AUDIENCE_ATLAS.md) | Hög |
| Kunskapsbasens entiteter (seed) | TILLGÄNGLIG | — | 72 stöd, officiell nomenklatur, villkor | Hög |
| Google Search Console | DATA_UNAVAILABLE | Användaren: deploya + verifiera domänen | riktiga queries, positioner, CTR | KRITISK efter lansering |
| Google Ads Keyword Planner | DATA_UNAVAILABLE | Användaren: annonskonto | volymintervall | Hög |
| Semrush/Ahrefs/DataForSEO | DATA_UNAVAILABLE | Användaren: konto/API-nyckel | volymer, konkurrenters keywords, backlinks | Hög |
| Bing Webmaster Tools | DATA_UNAVAILABLE | Användaren: verifiering efter deploy | Bing-queries | Låg–medel |
| Google autocomplete/PAA direkt | DATA_UNAVAILABLE (proxy) | ev. DataForSEO-API | frågeskörd i skala | Medel (WebSearch ger delvis) |
| Intern sökdata | FINNS EJ ÄNNU | efter lansering: logga onsite-sök (anonymt) | verkligt användarspråk | Hög på sikt |
| Supportfrågor | FINNS EJ ÄNNU | efter lansering | luckor och missförstånd | Medel |
| Användarintervjuer/tester | EJ GENOMFÖRDA | användaren beslutar rekrytering (plan: SEO_AUDIENCE_ATLAS §Forskningsplan) | behovsvalidering av personor | KRITISK för Tier 1-personor |
| Myndigheters FAQ-strukturer | TILLGÄNGLIG (SERP-belagd) | — | frågemönster | Medel |

Regel: varje datapunkt i seo/-filerna bär källmärkning (VERIFIED /
SERP_OBSERVED / OFFICIAL_STATISTICS / SYNTHETIC_HYPOTHESIS / INFERRED /
DATA_UNAVAILABLE). Exakta sökvolymer förekommer ingenstans förrän en
volymkälla i tabellen är upplåst.
