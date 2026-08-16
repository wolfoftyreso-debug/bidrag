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
      // §28: FACT → IMPACT → MITIGATION → EVIDENCE — det som kan styrkas
      // väger tyngre, och en öppen redovisning slår alltid en dold brist.
      { key: 'evidenceNote', label: 'Vilket underlag styrker det du beskriver?', type: 'textarea', guidance: 'T.ex. läkarintyg, beslut, uppsägning, avtal — sådant du kan bifoga eller visa om handläggaren frågar.' },
    ],
    sections: [
      { title: 'Avser', lines: ['{{fullName}}'] },
      { title: 'Omständighet', lines: ['{{circumstance}}', 'Gäller sedan: {{since}}'] },
      { title: 'Påverkan', lines: ['{{impact}}'] },
      { title: 'Egna åtgärder', lines: ['{{steps}}'] },
      { title: 'Underlag som styrker beskrivningen', lines: ['{{evidenceNote}}'] },
    ],
  },
  {
    /**
     * Interventionslogiken (§13) som mall: PROBLEM → ORSAK → MÅL → AKTIVITET
     * → RESULTAT → EFFEKT → LÅNGSIKTIGHET, med mätbara indikatorer (§14),
     * organisation/kapacitet (§16) och konkurrensposition (§22). Frågorna
     * kräver mekanism — "bidrar positivt" räcker aldrig — och dokumentet
     * skriver bara det användaren faktiskt svarat.
     */
    key: 'projektbeskrivning',
    title: 'Projektbeskrivning',
    recipientLabel: 'Bilaga till ansökan',
    description: 'Den logiska kedjan finansiärer letar efter: problem, orsak, mål, aktiviteter, mätbara resultat och vad som består efteråt.',
    questions: [
      { key: 'fullName', label: 'Sökandens namn (person eller organisation)', type: 'text', required: true },
      { key: 'projectTitle', label: 'Projektets namn', type: 'text', required: true },
      { key: 'problem', label: 'Vilket problem eller behov utgår projektet från?', type: 'textarea', required: true, guidance: 'Konkret och sakligt: vad är läget i dag, för vem, och hur vet ni det?' },
      { key: 'cause', label: 'Vad beror problemet på?', type: 'textarea', guidance: 'Orsaken avgör om era aktiviteter är rätt valda — en utbildning löser kompetensbrist, inte pengabrist.' },
      { key: 'goal', label: 'Vad ska vara annorlunda när projektet är klart?', type: 'textarea', required: true, guidance: 'Formulera som en förändring, inte en aktivitet: "fler unga i föreningen" — inte "vi genomför workshops".' },
      { key: 'activities', label: 'Vad ska ni göra — och hur leder det till målet?', type: 'textarea', required: true, guidance: 'Beskriv mekanismen: aktivitet → vad den förändrar → hur det når målet. "Bidrar positivt" räcker inte.' },
      { key: 'hasIndicator', label: 'Kan förändringen mätas med en indikator?', type: 'boolean', required: true, guidance: 'En mätbar indikator gör ansökan betydligt starkare — men hitta inte på en som inte går att följa upp.' },
      { key: 'indicator', label: 'Vilken indikator?', type: 'text', required: true, showIf: { key: 'hasIndicator', equals: true }, guidance: 'T.ex. "antal aktiva medlemmar 13–20 år".' },
      { key: 'baseline', label: 'Nuläge (baseline)?', type: 'text', required: true, showIf: { key: 'hasIndicator', equals: true }, guidance: 'Utan nuläge går förändringen inte att visa.' },
      { key: 'target', label: 'Målvärde — och när ska det vara nått?', type: 'text', required: true, showIf: { key: 'hasIndicator', equals: true } },
      { key: 'measurement', label: 'Hur och av vem mäts det?', type: 'text', required: true, showIf: { key: 'hasIndicator', equals: true }, guidance: 'Datakälla och ansvarig — t.ex. "medlemsregistret, följs upp av kassören varje kvartal".' },
      { key: 'organisation', label: 'Vem gör vad i projektet?', type: 'textarea', required: true, guidance: 'Roller, kompetens och ungefärlig tid — det som visar att ni faktiskt kan genomföra det.' },
      { key: 'capacityGaps', label: 'Vilka funktioner eller kompetenser saknas i dag — och hur löser ni det?', type: 'textarea', guidance: 'En öppet redovisad lucka med en plan är starkare än en dold.' },
      { key: 'longTerm', label: 'Vad händer efter projektets slut?', type: 'textarea', required: true, guidance: '"Resultaten lever vidare" räcker inte: vem tar över, vem betalar, vad består konkret?' },
      { key: 'whyUs', label: 'Varför just ni — och varför nu?', type: 'textarea', guidance: 'Det som skiljer er från liknande projekt. Hitta inte på fördelar — det ni faktiskt har räcker.' },
    ],
    sections: [
      { title: 'Projekt', lines: ['{{projectTitle}}', 'Sökande: {{fullName}}'] },
      { title: 'Problem och behov', lines: ['{{problem}}', 'Bakomliggande orsak: {{cause}}'] },
      { title: 'Mål', lines: ['{{goal}}'] },
      {
        title: 'Indikator och uppföljning',
        showIf: { key: 'hasIndicator', equals: true },
        lines: ['Indikator: {{indicator}}', 'Nuläge: {{baseline}}', 'Mål: {{target}}', 'Mätning: {{measurement}}'],
      },
      { title: 'Genomförande', lines: ['{{activities}}'] },
      { title: 'Organisation och kapacitet', lines: ['{{organisation}}', 'Identifierade luckor och hur de hanteras: {{capacityGaps}}'] },
      { title: 'Efter projektet', lines: ['{{longTerm}}'] },
      { title: 'Varför vi, varför nu', lines: ['{{whyUs}}'] },
    ],
  },
];

export function getTemplate(key: string): DocumentTemplate | undefined {
  return DOCUMENT_TEMPLATES.find((t) => t.key === key);
}

/**
 * Förifyllnad: alla bidragsdokument ska kunna skapas färdigifyllda med det
 * systemet redan vet från intaget — användaren ska aldrig svara på samma
 * fråga två gånger. Bara fakta vi FAKTISKT har mappas; inget gissas
 * (inkomstband blir t.ex. aldrig ett påhittat kronbelopp). Användaren ser,
 * kontrollerar och kan ändra allt innan dokumentet genereras.
 */
export interface PrefillContext {
  /** Användarens registrerade namn. */
  displayName?: string | null;
  /** Profilens kommun. */
  municipality?: string | null;
  /** Sammanslagna profil- och projektfakta (person.* m.fl.). */
  facts: Record<string, unknown>;
}

export function prefillAnswers(templateKey: string, ctx: PrefillContext): Record<string, unknown> {
  const f = ctx.facts;
  const out: Record<string, unknown> = {};
  const put = (key: string, v: unknown) => {
    if (v !== undefined && v !== null && v !== '') out[key] = v;
  };

  // Gemensamt för alla mallar som frågar efter namn/kommun.
  put('fullName', ctx.displayName?.trim());
  put('municipality', ctx.municipality?.trim());

  const household = f['person.householdType'];
  const hasChildren = f['person.hasChildrenAtHome'];
  const housingCost = f['person.housingCostMonthly'];
  const limitedSavings = f['person.limitedSavings'];

  if (templateKey === 'ansokan-ekonomiskt-stod') {
    // "Med andra vuxna" säger inte hur många — då förifylls inget.
    if (household === 'alone') put('householdAdults', 1);
    if (household === 'partner') put('householdAdults', 2);
    if (typeof hasChildren === 'boolean') put('hasChildren', hasChildren);
  }
  if (templateKey === 'bilaga-ekonomisk-situation') {
    if (typeof housingCost === 'number' && housingCost > 0) put('costHousing', housingCost);
    // Intagets "begränsat sparande" är samma sakfråga som bilagans
    // tillgångsfråga, speglad: begränsat sparande ⇒ inga användbara medel.
    if (typeof limitedSavings === 'boolean') put('savings', !limitedSavings);
  }
  return out;
}
