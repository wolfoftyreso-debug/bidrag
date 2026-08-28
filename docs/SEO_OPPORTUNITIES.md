# SEO Opportunity-backlog — ur uppmätt data

Källa: Semrush (databas `se`, hämtad 2026-08-28, snapshot `seo/volumes-semrush-se.json`).
**157 av 332 rötter i keyword-universumet bär nu verklig volym/KD** (join i
`seo/keywords.json`, stämplat `semrush:se:2026-08-28`); 137 med volym > 0.
Inget nedan är gissat — varje siffra är en mätning; varje "SAKNAS" är kontrollerad
mot entity-sidorna. Prioritering: volym × låg KD × produktrelevans × sidtyp som
SERP:en faktiskt belönar.

## Strategiska bevis ur SERP-datan (phrase_organic, 2026-08-28)

1. **Icke-myndigheter kan ranka.** På `bostadsbidrag` (22 200/mån) rankar
   Lendos kommersiella guide topp-10 bredvid Försäkringskassan, norden.org,
   Pensionsmyndigheten och Hyresgästföreningen. ANGRIP-RUNT är alltså belagd
   strategi, inte hopp.
2. **Verktyg rankar.** Försäkringskassans *räkna-på-bostadsbidrag*-kalkylator
   ligger topp-3, och `räkna ut bostadsbidrag` har 1 300 sök/mån (KD 43).
   Free-tool-SEO (§16) är den starkaste obyggda tillgången — motorn i
   `packages/core` ÄR kalkylatorn; en publik, indexerbar förenklad
   behörighetskontroll per stöd är produkt-som-SEO.
3. **§29-regeln är trippelbelagd.** `vilka bidrag kan jag få` och
   `har jag rätt till bidrag`: 0 volym OCH ingen SERP-data. Mallfraser är inte
   självständiga sökresultat — flaggskeppssidan behåller sin roll som
   konverteringsyta, inte volymfångare.

## P1 — Uppmätt efterfrågan där kunskapsbasen SAKNAR stödet (produktlucka, inte sidlucka)

Sidor får inte byggas före kurering (doktrin: inga sidor utan verklig data i KB).
Detta uppgraderar kureringskön från känd hypotes till uppmätt efterfrågan:

| Term | Volym/mån | KD | Status i KB |
|---|---|---|---|
| a-kassa | 60 500 | 59 | saknas (ekosystem: a-kassorna; hög KD — långsiktig) |
| barnbidrag | 18 100 | 32 | saknas |
| högkostnadsskydd | 14 800 | 28 | saknas |
| aktivitetsstöd | 12 100 | **23** | saknas — bästa kvoten volym/KD i hela mätningen; PAA-frågor klara i snapshotet |
| föräldrapenning | 12 100 | 36 | saknas |
| sjukpenning | 12 100 | 27 | saknas |
| tandvårdsbidrag | 9 900 | 30 | saknas |
| garantipension | 6 600 | 26 | saknas |
| omvårdnadsbidrag | 6 600 | 26 | saknas |
| sjukersättning | 6 600 | 28 | saknas |
| elstöd | 5 400 | 27 | saknas |
| underhållsbidrag | 5 400 | **19** | saknas (skiljesida mot underhållsstöd — jfr-frågan finns i PAA-datan) |
| nystartsjobb | 4 400 | 34 | saknas — **bekräftar kluster 10–12-luckan** (CLAUDE.md prio 3) |
| starta eget bidrag | 4 400 | 28 | saknas |
| flerbarnstillägg | 3 600 | 28 | saknas |
| merkostnadsersättning | 3 600 | 25 | saknas |
| lönebidrag | 2 400 | **23** | saknas — kluster 10–12 |
| socialbidrag | 2 900 | 33 | synonym till försörjningsstöd — redirect/samma sida, ej egen |

## P2 — Stödet FINNS i KB; ytan behöver stärkas eller mappas

| Term | Volym/mån | KD | Målsida |
|---|---|---|---|
| ekonomiskt bistånd | 27 100 | 34 | entity finns (försörjningsstöd) — huvudtermen ska ägas av klustersidan; PAA-frågor klara |
| bostadsbidrag (huvudterm) | 22 200 | 44 | två entity-sidor (unga/barnfamiljer) — klusterhubb ska äga huvudtermen; 15 PAA-frågor klara |
| bostadstillägg | 8 100 | 31 | `/bidrag/pm-bostadstillagg/` — PAA-frågor klara |
| närståendepenning | 5 400 | **20** | `/bidrag/fk-narstaendepenning/` — mappa + FAQ |
| omställningsstudiestöd | 5 400 | 25 | `/bidrag/csn-omstallningsstudiestod/` |
| underhållsstöd | 3 600 | 26 | `/bidrag/fk-underhallsstod/` — PAA klara ("vad är underhållsstöd" 480/mån KD 16) |
| återvandringsbidrag | 3 600 | 30 | entity finns (återvandring) — mappa roten |
| existensminimum | 2 400 | **18** | begreppssida i ekonomisk-utsatthet-klustret |
| inackorderingstillägg | 1 600 | **19** | `/bidrag/csn-inackorderingstillagg/`-familjen |
| studiestartsstöd | 1 600 | **19** | entity finns — mappa |
| äldreförsörjningsstöd | 1 600 | 30 | `/bidrag/pm-aldreforsorjningsstod/` |
| klimatklivet | 1 600 | 28 | `/bidrag/naturvardsverket-klimatklivet/` |
| lok-stöd | 1 300 | **20** | entity finns — mappa |
| bidrag glasögon barn | 1 000 | 22 | `/bidrag/region-glasogonbidrag-barn/` (1 900 för `glasögonbidrag barn`) |
| vab ersättning | 1 000 | **16** | lägsta KD av alla ≥1 000-termer |
| etableringsersättning | 1 000 | 23 | `/bidrag/af-etableringsersattning/` |

## P3 — Verktyg (produkt-som-SEO, §16)

- `räkna ut bostadsbidrag` 1 300/mån (KD 43) + FK-kalkylatorn topp-3 = bygg
  publik förenklad kontroll per storstöd när klustersidorna byggs
  (`CONTENT_ENGINE.md` F1:s interaktiva behörighetskontroll — nu uppmätt).
- `csn fribelopp` 2 900 (KD 43) + `csn hur mycket` 390 — räknarintent i studier-klustret.

## Ordningsföljd (kopplat till befintlig plan)

1. **Kurera P1-stöden i kunskapsbasen** (störst: aktivitetsstöd, tandvårdsbidrag,
   sjukpenning/sjukersättning, föräldrapenning/barnbidrag/flerbarnstillägg,
   underhållsbidrag, garantipension, omvårdnadsbidrag/merkostnadsersättning,
   lönebidrag/nystartsjobb) — detta ÄR kluster-arbetets datagrund (CLAUDE.md prio 3).
2. **Mappa P2-rötterna** till sina entity-sidor (`our_target_url`) och lyft in
   PAA-frågorna ur snapshotet som svarsobjekt/FAQ på respektive sida.
3. **Klusterhubbar** för huvudtermerna (bostadsbidrag, ekonomiskt bistånd) enligt
   `SEO_ANSWER_CLUSTERS.md` — hubben äger huvudtermen, entity-sidorna specifika.
4. **Verktygsytan** (P3) byggs in i klustersidorna, inte som separata gimmickar.

Gaten (`GATE0_REPORT.md`) är oförändrad tills klustersidorna finns — detta
dokument gör kön datastyrd i stället för bedömd.
