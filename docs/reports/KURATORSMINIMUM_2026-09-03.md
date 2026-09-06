# Kuratorsminimum före beta — vilka stöd en människa måste granska först

Beta-villkor A7 (`docs/reports/BETA_READINESS_2026-09-03.md`): alla 84 stöd
är `ai_curated`. Dagens pass (KURERING_2026-09-03) hittade ett stöd som
varit avskaffat i fyra år och en text som blev fel två dagar tidigare. Innan
riktiga användare får en bedömning måste de stöd de faktiskt kommer att se
vara kontrollerade av en människa mot myndighetens levande sida.

Arbetet görs i admin-kuratorsflödet (`/admin` → stödet → granska → lyft till
`human_verified`). Per stöd: öppna källsidan, kontrollera villkor, belopp,
ansökningssätt, underlag och att stödet fortfarande finns. Rätta i seeden
(`apps/api/src/seed/data.ts`) om något avviker; en ny regelversion skapas
av kuratorsflödet.

## Lista A — de 25 mest synliga stöden (motorsimuleringen, 11 000 personor)

Rangordnade efter hur ofta stödet visas som "kan ha rätt till" eller
"behöver utredas". Det är dessa betaanvändarna möter först.

| # | Stöd | Synlighet | Källsida att granska mot |
|---|---|---|---|
| 1 | region-hogkostnadsskydd-vard | 1831/2000 privatpersoner | 1177.se (regionalt — välj regionen betaanvändarna bor i) |
| 2 | fk-tandvardsbidrag | 1792/2000 | forsakringskassan.se/privatperson (stödets egen sida saknas — leta upp "tandvårdsbidrag") |
| 3 | vinnova-planeringsbidrag-eu | 1029/2400 org. | vinnova.se utlysningar |
| 4 | kulturradet-internationellt-resebidrag-musik | 885/4000 | kulturradet.se/sok-bidrag |
| 5 | fk-flerbarnstillagg | 809/2000 | barnbidrag-och-flerbarnstillagg-sa-funkar-det ✔ specifik |
| 6 | fk-foraldrapenning | 809/2000 | forsakringskassan.se/privatperson/foralder (leta upp) |
| 7 | fk-tillfallig-foraldrapenning | 809/2000 | vab-for-barn-under-12-ar ✔ |
| 8 | fk-barnbidrag | 748/2000 | ✔ specifik |
| 9 | pm-garantipension | 734/2000 | pensionsmyndigheten.se |
| 10 | energimyndigheten-energieffektivisering | 656/2600 | energimyndigheten.se utlysningar |
| 11 | fk-sjukpenning | 652/2000 | sjukskriven-nar-du-ar-anstalld ✔ |
| 12 | konstnarsnamnden-arbetsstipendium | 614/2000 | konstnarsnamnden.se |
| 13 | fk-narstaendepenning | 600/2000 | stodja-en-svart-sjuk-narstaende ✔ |
| 14 | energimyndigheten-industriklivet | 581/1400 | energimyndigheten.se |
| 15 | naturvardsverket-ladda-bilen-organisationer | 553/4400 | naturvardsverket.se |
| 16 | raa-kulturarvsbidrag | 519/1200 | bidrag-till-kulturarvsarbete ✔ |
| 17 | konstnarsnamnden-internationellt-kulturutbyte | 505/2000 | konstnarsnamnden.se |
| 18 | esf-kompetensutveckling | 495/2800 | esf.se |
| 19 | csn-studiemedel | 460/2000 | studiemedel.html ✔ |
| 20 | si-creative-force | 418/2400 | si.se |
| 21 | akassa-arbetsloshetsersattning | 417/2000 | checklista-for-arbetslosa ✔ (villkoren ändrades 1 okt 2025 — kontrollera inkomstvillkoret) |
| 22 | af-lonebidrag | 400/2000 | ✔ specifik |
| 23 | af-nystartsjobb | 364/2000 | ✔ specifik |
| 24 | erasmus-ka2-smaskaliga-partnerskap | 309/1600 | erasmus-plus.ec.europa.eu |
| 25 | kulturradet-skapande-skola | 270/1400 | kulturradet.se/sok-bidrag |

## Lista B — 32 stöd vars källa fortfarande är en startsida (M25)

I dag fick 26 stöd sin specifika källsida. Dessa 32 har det inte: källbevakningen
kan inte upptäcka att de ändras eller försvinner. Kuratorn hittar stödets
egen sida hos myndigheten och sätter `sourceUrl` (och `applicationUrl`) till
den. Prioritet: de som också står i lista A (markerade ★).

kulturradet-internationellt-resebidrag-musik ★ · kulturradet-projektbidrag-musik ·
kulturradet-skapande-skola ★ · jordbruksverket-startstod-unga ·
jordbruksverket-investeringsstod · kulturradet-verksamhetsbidrag-scenkonst ·
region-glasogonbidrag-barn · kommun-skolskjuts · fk-aktivitetsersattning ·
af-stod-start-naringsverksamhet · si-creative-force ★ · nordisk-kulturfond-projektstod ·
vr-projektbidrag · postkodstiftelsen-projektstod · musikverket-projektbidrag ·
erasmus-ka2-smaskaliga-partnerskap ★ · kulturradet-inkopsstod-bibliotek ·
kulturradet-litteraturstod · af-eures-targeted-mobility · csn-utlandsstudier ·
fk-omvardnadsbidrag · fk-bilstod · csn-studiestartsstod · kommun-foreningsbidrag ·
region-kulturstod · sparbanksstiftelsen-projektstod · radiohjalpen-projektbidrag ·
fk-foraldrapenning ★ · fk-aktivitetsstod · fk-tandvardsbidrag ★ · pm-garantipension ★ ·
region-hogkostnadsskydd-vard ★

## Arbetsgång per stöd (10–20 min) — protokollet är kod sedan 2026-09-05

Granskningskön i `/admin` (”Granskningskö — stöd efter granskningsbehov”)
ligger i just den här ordningen: förfallna först, sedan efter hur ofta
stödet visats för riktiga användare de senaste 30 dagarna. ”Granska” öppnar
protokollet, och stämpeln ”verifierad mot källa” kan bara sättas när alla
fem punkter är ikryssade (API:t vägrar annars med 400 `checklist_incomplete`):

1. **Källan finns kvar** — ”Kontrollera källan nu” hämtar sidan i samma stund
   (HTTP-status, ändrad/oförändrad sedan senaste snapshot). Öppna sidan.
   Finns stödet kvar? (Hemutrustningslånet fanns inte.)
2. **Villkoren stämmer** — kriterietexterna mot sidans "Vem kan få".
3. **Beloppet stämmer** — `amountNote` mot sidans belopp, exakt, med datum.
4. **Ansökningssätt och underlag stämmer** — mot "Så ansöker du".
5. **Källadressen är stödets egen sida** — rätta `sourceUrl`/`applicationUrl`
   direkt i protokollet (lista B-flaggan ”startsida” visas i kön).

Anteckningen (vad som jämfördes, avvikelser) sparas med granskarens namn och
datum som granskningsärende och i revisionsspåret, och visas i kön. Avviker
seeden: rätta i `apps/api/src/seed/data.ts` (regelversion via kuratorsflödet).

Minimum före första inbjudan: lista A komplett. Före öppen beta: alla 84.
