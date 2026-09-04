# SEO Opportunity-backlog — ur uppmätt data

Källa: Semrush (databas `se`, snapshot `seo/volumes-semrush-se.json`; första
körningen 2026-08-28, full genomgång av hela universumet 2026-09-03 —
`docs/reports/SEMRUSH_2026-09-03.md`).
**185 av 350 rötter i keyword-universumet bär verklig volym/KD** (join i
`seo/keywords.json`, stämplat `semrush:se:2026-09-03`); 160 med volym > 0.
De 165 utan rad är `DATA_UNAVAILABLE` — Semrush saknar termen, vilket inte
är noll sökningar. Inget nedan är gissat — varje siffra är en mätning; varje
"SAKNAS" är kontrollerad mot entity-sidorna. Prioritering: volym × låg KD ×
produktrelevans × sidtyp som SERP:en faktiskt belönar.

## Uppdatering 2026-09-03 — vad hela genomgången ändrade

- **P1-luckorna är stängda i kunskapsbasen** (kureringspass 2026-08-28,
  72→84 stöd); tabellen nedan står kvar som historik över den uppmätta
  efterfrågan som drev kureringen.
- **Ny största lucka: försörjningsstöd nationellt.** SERP:en (18 100/mån) är
  8 kommuner + kunskapsguiden + Socialstyrelsens provberäkning — ingen
  nationell konsumentguide. Hubben `/bidrag/ekonomiskt-bistand/` finns;
  behörighetskontroll + kommunväljare saknas (rapportens §8.1).
- **Frågeset fästa** på fk-barnbidrag (4 500 frågesök/mån, KD 18–25),
  fk-sjukersattning (880 + 590 om villkoren) och csn-studiemedel.
- **Bevis för verktygs-SEO (P3) blev empiriskt:** foraldrakalkylatorn.se
  0 → 2 660 besök/mån på sex månader med 47 ref-domäner.
- **Myndighetsprefixade termer är navigational** (försäkringskassan
  föräldrapenning 2 900, intent 2) — GREY, jagas inte. Undantag:
  `försäkringskassan underhållsstöd` 1 900 med informationsintent.
- Fullständig prioriteringslista: rapportens §8.

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
| sjukersättning | 6 600 | 28 | saknas |
| elstöd | 5 400 | 27 | saknas |
| underhållsbidrag | 5 400 | **19** | saknas (skiljesida mot underhållsstöd — jfr-frågan finns i PAA-datan) |
| nystartsjobb | 4 400 | 34 | saknas — **bekräftar kluster 10–12-luckan** (CLAUDE.md prio 3) |
| flerbarnstillägg | 3 600 | 28 | saknas |
| lönebidrag | 2 400 | **23** | saknas — kluster 10–12 |
| socialbidrag | 2 900 | 33 | synonym till försörjningsstöd — redirect/samma sida, ej egen |

## P2 — Stödet FINNS i KB; ytan behöver stärkas eller mappas

**Status 2026-08-28: GENOMFÖRD.** 17 rötter mappade till sina entity-sidor
(roots-manual `target` → `our_target_url` i keyword-databasen), och de verkliga
PAA-frågorna renderas nu som ärlig FAQ (synligt + FAQPage-JSON-LD) på
försörjningsstöd/ekonomiskt bistånd, bostadstillägg, underhållsstöd och
aktivitetsstöd — deterministiska svar ur seeden, en fråga per svarskategori,
aldrig påhittade belopp/tider. Synonymfrågan socialbidrag↔försörjningsstöd
besvaras på försörjningsstödssidan. Huvudtermen bostadsbidrag lämnas medvetet
till klusterhubben (§3 nedan).

| Term | Volym/mån | KD | Målsida |
|---|---|---|---|
| omvårdnadsbidrag | 6 600 | 26 | `/bidrag/fk-omvardnadsbidrag/` — fanns redan i KB (probefel i första versionen) |
| starta eget bidrag | 4 400 | 28 | `/bidrag/af-stod-start-naringsverksamhet/` — fanns redan i KB |
| merkostnadsersättning | 3 600 | 25 | `/bidrag/fk-merkostnadsersattning/` — fanns redan i KB |
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
| vab ersättning | 1 000 | **16** | `/bidrag/fk-tillfallig-foraldrapenning/` — **kurerad 2026-08-28** + rot mappad |
| etableringsersättning | 1 000 | 23 | `/bidrag/af-etableringsersattning/` |

## P3 — Verktyg (produkt-som-SEO, §16)

**Status 2026-09-04: FÖRSTA VERKTYGET LEVERERAT.** Behörighetskontrollen
(`tools/precheck/`) körs på alla fyra klusterhubbar — cores motor i
webbläsaren, seedens frågor ordagrant, resultat per stöd. Kvar i P3:
räknarintenten (`räkna ut bostadsbidrag` 1 300/mån, `csn fribelopp` 2 900)
som kräver kurerade beräkningsregler i faktalagret, inte bara villkor.

- `räkna ut bostadsbidrag` 1 300/mån (KD 43) + FK-kalkylatorn topp-3 = bygg
  publik förenklad kontroll per storstöd när klustersidorna byggs
  (`CONTENT_ENGINE.md` F1:s interaktiva behörighetskontroll — nu uppmätt).
- `csn fribelopp` 2 900 (KD 43) + `csn hur mycket` 390 — räknarintent i studier-klustret.

## Ordningsföljd (kopplat till befintlig plan)

1. **Kurera P1-stöden i kunskapsbasen** (störst: aktivitetsstöd, tandvårdsbidrag,
   sjukpenning/sjukersättning, föräldrapenning/barnbidrag/flerbarnstillägg,
   garantipension, lönebidrag/nystartsjobb — **kurerade 2026-08-28**, 72→84 stöd) — detta ÄR kluster-arbetets datagrund (CLAUDE.md prio 3).
2. **Mappa P2-rötterna** till sina entity-sidor (`our_target_url`) och lyft in
   PAA-frågorna ur snapshotet som svarsobjekt/FAQ på respektive sida.
3. **Klusterhubbar** — **byggda 2026-08-28**: `/bidrag/bostadsbidrag/` (22 200/mån)
   och `/bidrag/ekonomiskt-bistand/` (27 100/mån) enligt `SEO_ANSWER_CLUSTERS.md`
   kluster 1+3 (seo/kluster.json → genseo klusterPage). Hubben äger huvudtermen
   och dess PAA-set; entity-sidorna det specifika; tier1-noder + rötter ompekade.
4. **Verktygsytan** (P3) byggs in i klustersidorna, inte som separata gimmickar.

Gaten (`GATE0_REPORT.md`) är oförändrad tills klustersidorna finns — detta
dokument gör kön datastyrd i stället för bedömd.
