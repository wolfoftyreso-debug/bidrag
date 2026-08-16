/**
 * Generiska dokumentmallar (§produktsteg 3). Samma fyra mallar bär de flesta
 * personliga ansökningar: själva ansökan, ekonomisk bilaga, behovsbeskrivning
 * och särskilda omständigheter. Nya stödtyper = nya mallar, inte ny kod.
 *
 * Frågorna följer produktens ton: konkreta, respektfulla, en i taget i UI:t.
 * Dokumenten skriver aldrig något användaren inte har svarat — tomma fält
 * utelämnas i stället för att gissas.
 */
import type { DocumentTemplate } from './documents.js';

const personalBasics = [
  { key: 'fullName', label: 'Ditt fullständiga namn', type: 'text' as const, required: true },
  { key: 'address', label: 'Adress', type: 'text' as const, required: true },
  { key: 'postalCity', label: 'Postnummer och ort', type: 'text' as const, required: true },
  { key: 'phone', label: 'Telefonnummer', type: 'text' as const },
  { key: 'municipality', label: 'Kommun', type: 'text' as const, required: true },
];

export const DOCUMENT_TEMPLATES: DocumentTemplate[] = [
  {
    key: 'ansokan-ekonomiskt-stod',
    title: 'Ansökan om ekonomiskt stöd',
    recipientLabel: 'Myndigheten/organisationen som handlägger stödet',
    description: 'Själva ansökningsdokumentet: vem du är, vad du söker och en kort motivering.',
    questions: [
      ...personalBasics,
      { key: 'householdAdults', label: 'Hur många vuxna finns i hushållet?', type: 'number', required: true },
      { key: 'hasChildren', label: 'Har du barn som bor hos dig?', type: 'boolean', required: true },
      { key: 'childrenCount', label: 'Hur många barn?', type: 'number', showIf: { key: 'hasChildren', equals: true } },
      { key: 'childrenAges', label: 'Barnens åldrar (t.ex. 6 och 9 år)', type: 'text', showIf: { key: 'hasChildren', equals: true } },
      { key: 'whatFor', label: 'Vad söker du stöd för?', type: 'textarea', required: true, guidance: 'Beskriv konkret: t.ex. hyra för mars, vinterkläder till barnen, en fritidsaktivitet.' },
      { key: 'whyNeeded', label: 'Varför behövs stödet just nu?', type: 'textarea', required: true, guidance: 'Kort och sakligt — vad har hänt och varför räcker inte ekonomin?' },
    ],
    sections: [
      { title: 'Sökande', lines: ['{{fullName}}', '{{address}}, {{postalCity}}', 'Telefon: {{phone}}', 'Kommun: {{municipality}}'] },
      {
        title: 'Hushåll',
        lines: ['Antal vuxna i hushållet: {{householdAdults}}', 'Barn som bor i hushållet: {{childrenCount}} ({{childrenAges}})'],
      },
      { title: 'Ansökan avser', lines: ['{{whatFor}}'] },
      { title: 'Motivering', lines: ['{{whyNeeded}}'] },
    ],
  },
  {
    key: 'bilaga-ekonomisk-situation',
    title: 'Bilaga — beskrivning av ekonomisk situation',
    recipientLabel: 'Bilaga till ansökan',
    description: 'En strukturerad bild av hushållets inkomster och utgifter — den bilaga handläggare oftast frågar efter.',
    questions: [
      { key: 'fullName', label: 'Ditt fullständiga namn', type: 'text', required: true },
      { key: 'incomeWork', label: 'Inkomst från arbete per månad (kr, efter skatt)', type: 'number', guidance: 'Lämna tomt om du inte har arbetsinkomst.' },
      { key: 'incomeBenefits', label: 'Ersättningar och bidrag per månad (kr)', type: 'number', guidance: 'T.ex. a-kassa, sjukpenning, bostadsbidrag, barnbidrag — sammanlagt.' },
      { key: 'incomeOther', label: 'Övriga inkomster per månad (kr)', type: 'number' },
      { key: 'costHousing', label: 'Boendekostnad per månad (kr)', type: 'number', required: true },
      { key: 'costChildren', label: 'Kostnader för barn per månad (kr)', type: 'number', guidance: 'Förskoleavgift, fritids, aktiviteter, kläder.' },
      { key: 'costDebts', label: 'Skulder/avbetalningar per månad (kr)', type: 'number' },
      { key: 'costOther', label: 'Övriga fasta utgifter per månad (kr)', type: 'number' },
      { key: 'savings', label: 'Har hushållet sparade pengar eller tillgångar som kan användas?', type: 'boolean', required: true },
      { key: 'savingsNote', label: 'Beskriv kort (belopp/typ)', type: 'text', showIf: { key: 'savings', equals: true } },
      { key: 'situationNote', label: 'Något mer om er ekonomiska situation?', type: 'textarea', guidance: 'T.ex. inkomst som varierar, nyligen ändrade förhållanden.' },
    ],
    sections: [
      { title: 'Avser', lines: ['{{fullName}}'] },
      {
        title: 'Inkomster per månad',
        lines: ['Arbete: {{incomeWork}} kr', 'Ersättningar och bidrag: {{incomeBenefits}} kr', 'Övrigt: {{incomeOther}} kr'],
      },
      {
        title: 'Utgifter per månad',
        lines: ['Boende: {{costHousing}} kr', 'Barn: {{costChildren}} kr', 'Skulder/avbetalningar: {{costDebts}} kr', 'Övriga fasta utgifter: {{costOther}} kr'],
      },
      { title: 'Tillgångar', lines: ['Sparade medel/tillgångar: {{savings}}', '{{savingsNote}}'] },
      { title: 'Kommentar', lines: ['{{situationNote}}'] },
    ],
  },
  {
    key: 'behovsbeskrivning',
    title: 'Beskrivning av behov',
    recipientLabel: 'Bilaga till ansökan',
    description: 'Förklarar konkret vad behovet är, vem det gäller och vad det betyder i vardagen.',
    questions: [
      { key: 'fullName', label: 'Ditt fullständiga namn', type: 'text', required: true },
      { key: 'whoFor', label: 'Vem gäller behovet?', type: 'select', required: true, options: [
        { value: 'mig', label: 'Mig själv' },
        { value: 'barn', label: 'Mitt barn' },
        { value: 'familjen', label: 'Hela familjen' },
      ] },
      { key: 'childName', label: 'Barnets förnamn och ålder', type: 'text', showIf: { key: 'whoFor', equals: 'barn' } },
      { key: 'needWhat', label: 'Vad är behovet?', type: 'textarea', required: true, guidance: 'T.ex. "glasögon", "avgift och utrustning för fotboll", "kostnad för klassresa i maj".' },
      { key: 'needWhy', label: 'Vad händer om behovet inte kan tillgodoses?', type: 'textarea', required: true, guidance: 'Beskriv sakligt vad det betyder i vardagen — t.ex. att barnet inte kan delta med sin klass.' },
      { key: 'needCost', label: 'Ungefärlig kostnad (kr)', type: 'number' },
      { key: 'needWhen', label: 'När behövs det?', type: 'text', guidance: 'T.ex. "före terminsstart", "senast i maj".' },
    ],
    sections: [
      { title: 'Avser', lines: ['{{fullName}}', 'Behovet gäller: {{whoFor}} {{childName}}'] },
      { title: 'Behovet', lines: ['{{needWhat}}', 'Ungefärlig kostnad: {{needCost}} kr', 'Tidpunkt: {{needWhen}}'] },
      { title: 'Konsekvens om behovet inte tillgodoses', lines: ['{{needWhy}}'] },
    ],
  },
  {
    key: 'sarskilda-omstandigheter',
    title: 'Förklaring av särskilda omständigheter',
    recipientLabel: 'Bilaga till ansökan',
    description: 'När något i er situation behöver förklaras: sjukdom, separation, varierande inkomst, oförutsedda händelser.',
    questions: [
      { key: 'fullName', label: 'Ditt fullständiga namn', type: 'text', required: true },
      { key: 'circumstance', label: 'Vilken omständighet vill du förklara?', type: 'textarea', required: true, guidance: 'T.ex. sjukskrivning, separation, en oväntad utgift, inkomst som förändrats.' },
      { key: 'since', label: 'Sedan när gäller detta?', type: 'text' },
      { key: 'impact', label: 'Hur påverkar det er ekonomi och vardag?', type: 'textarea', required: true },
      { key: 'steps', label: 'Vad har du själv gjort eller planerar att göra?', type: 'textarea', guidance: 'T.ex. sökt arbete, kontaktat hyresvärd, ansökt om andra ersättningar.' },
    ],
    sections: [
      { title: 'Avser', lines: ['{{fullName}}'] },
      { title: 'Omständighet', lines: ['{{circumstance}}', 'Gäller sedan: {{since}}'] },
      { title: 'Påverkan', lines: ['{{impact}}'] },
      { title: 'Egna åtgärder', lines: ['{{steps}}'] },
    ],
  },
];

export function getTemplate(key: string): DocumentTemplate | undefined {
  return DOCUMENT_TEMPLATES.find((t) => t.key === key);
}
