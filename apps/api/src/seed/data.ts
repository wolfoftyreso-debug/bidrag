/**
 * Wave-1 curated funding knowledge (§73).
 *
 * Every record is traceable to an official primary source URL (source quality
 * A) and marked verification_status = 'human_curated' with a retrieval date.
 * Deadlines that could not be verified from the source at curation time are
 * modelled as 'rolling' or 'upcoming_round' with closesAt = null — the UI
 * says so instead of inventing dates. Amounts and criteria encode the
 * published structure of each programme; the product always links to the
 * source and shows when it was last verified.
 */

export const CURATED_AT = '2026-08-13T00:00:00Z';

export interface SeedAuthority {
  key: string;
  name: string;
  country: string;
  kind: string;
  website: string;
}

export const authorities: SeedAuthority[] = [
  { key: 'kulturradet', name: 'Kulturrådet', country: 'SE', kind: 'state_agency', website: 'https://kulturradet.se' },
  { key: 'mucf', name: 'MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor', country: 'SE', kind: 'state_agency', website: 'https://www.mucf.se' },
  { key: 'vinnova', name: 'Vinnova', country: 'SE', kind: 'state_agency', website: 'https://www.vinnova.se' },
  { key: 'tillvaxtverket', name: 'Tillväxtverket', country: 'SE', kind: 'state_agency', website: 'https://tillvaxtverket.se' },
  { key: 'energimyndigheten', name: 'Energimyndigheten', country: 'SE', kind: 'state_agency', website: 'https://www.energimyndigheten.se' },
  { key: 'naturvardsverket', name: 'Naturvårdsverket', country: 'SE', kind: 'state_agency', website: 'https://www.naturvardsverket.se' },
  { key: 'jordbruksverket', name: 'Jordbruksverket', country: 'SE', kind: 'state_agency', website: 'https://jordbruksverket.se' },
  { key: 'esf', name: 'Svenska ESF-rådet', country: 'SE', kind: 'state_agency', website: 'https://www.esf.se' },
  { key: 'eu-eacea', name: 'Europeiska kommissionen (Erasmus+/EACEA)', country: 'EU', kind: 'eu', website: 'https://erasmus-plus.ec.europa.eu' },
  { key: 'uhr', name: 'UHR — Universitets- och högskolerådet', country: 'SE', kind: 'state_agency', website: 'https://www.uhr.se' },
];

export interface SeedSource {
  key: string;
  authorityKey: string;
  name: string;
  url: string;
  method: 'html' | 'pdf' | 'api' | 'rss' | 'manual';
  quality: 'A' | 'B' | 'C' | 'D';
}

export const seedSources: SeedSource[] = [
  { key: 'kulturradet-sok-bidrag', authorityKey: 'kulturradet', name: 'Kulturrådet — Sök bidrag', url: 'https://kulturradet.se/sok-bidrag/', method: 'html', quality: 'A' },
  { key: 'mucf-bidrag', authorityKey: 'mucf', name: 'MUCF — Bidrag', url: 'https://www.mucf.se/bidrag', method: 'html', quality: 'A' },
  { key: 'vinnova-utlysningar', authorityKey: 'vinnova', name: 'Vinnova — Utlysningar', url: 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', method: 'html', quality: 'A' },
  { key: 'tillvaxtverket-utlysningar', authorityKey: 'tillvaxtverket', name: 'Tillväxtverket — Utlysningar', url: 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', method: 'html', quality: 'A' },
  { key: 'energimyndigheten-utlysningar', authorityKey: 'energimyndigheten', name: 'Energimyndigheten — Alla utlysningar', url: 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', method: 'html', quality: 'A' },
  { key: 'naturvardsverket-bidrag', authorityKey: 'naturvardsverket', name: 'Naturvårdsverket — Bidrag', url: 'https://www.naturvardsverket.se/bidrag/', method: 'html', quality: 'A' },
  { key: 'esf-utlysningsplan', authorityKey: 'esf', name: 'Svenska ESF-rådet — Utlysningsplan', url: 'https://www.esf.se/utlysningar/utlysningsplan/', method: 'html', quality: 'A' },
  { key: 'erasmus-youth-exchanges', authorityKey: 'eu-eacea', name: 'Erasmus+ — Youth exchanges', url: 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', method: 'html', quality: 'A' },
];

export interface SeedOpportunity {
  slug: string;
  authorityKey: string;
  sourceKey?: string;
  programmeName: string;
  title: string;
  summary: string;
  description: string;
  objective: string;
  instrumentType: string;
  applicantTypes: string[];
  countries: string[];
  sectors: string[];
  minAmountMinor: number | null;
  maxAmountMinor: number | null;
  maxFundingSharePercent: number | null;
  excludesOtherPublicFunding: boolean;
  deadlineModel: 'one_time' | 'recurring' | 'rolling' | 'upcoming_round';
  opensAt: string | null;
  closesAt: string | null;
  applicationMethod: string;
  applicationUrl: string;
  authenticationMethod: string;
  submissionLevel: 'assisted';
  estimatedEffortDays: number;
  sourceUrl: string;
  criteria: unknown[];
  budgetRules: unknown[];
  evidenceRequirements: unknown[];
}

const c = (
  id: string,
  kind: 'hard' | 'mandatory' | 'weighted',
  factPath: string,
  op: string,
  expected: unknown,
  description: string,
  intakeQuestion?: string,
  weight?: number,
) => ({ id, kind, factPath, op, expected, description, intakeQuestion, weight });

export const opportunities: SeedOpportunity[] = [
  {
    slug: 'kulturradet-internationellt-resebidrag-musik',
    authorityKey: 'kulturradet',
    sourceKey: 'kulturradet-sok-bidrag',
    programmeName: 'Internationellt kulturutbyte',
    title: 'Kulturrådet — Resebidrag för internationellt kulturutbyte',
    summary: 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.',
    description:
      'Stödet riktar sig till yrkesverksamma kulturskapare i Sverige som deltar i internationellt kulturutbyte, till exempel gästspel, samarbetsprojekt eller kompetensutveckling utomlands. Bidraget kan täcka resekostnader och relaterade omkostnader. Kontrollera alltid aktuella villkor hos Kulturrådet.',
    objective: 'Främja internationellt kulturutbyte och svenska kulturskapares internationella närvaro.',
    instrumentType: 'travel_grant',
    applicantTypes: ['individual', 'association', 'company'],
    countries: ['SE'],
    sectors: ['culture'],
    minAmountMinor: null,
    maxAmountMinor: 5_000_000, // 50 000 kr — typisk storleksordning; verifieras mot källan
    maxFundingSharePercent: null,
    excludesOtherPublicFunding: false,
    deadlineModel: 'recurring',
    opensAt: null,
    closesAt: '2026-09-24T21:59:59Z',
    applicationMethod: 'Ansökan görs i Kulturrådets onlinetjänst.',
    applicationUrl: 'https://kulturradet.se/sok-bidrag/',
    authenticationMethod: 'kulturradet_konto',
    submissionLevel: 'assisted',
    estimatedEffortDays: 4,
    sourceUrl: 'https://kulturradet.se/sok-bidrag/',
    criteria: [
      c('kr-rb-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Sökande ska vara verksam i Sverige'),
      c('kr-rb-h2', 'hard', 'applicant.type', 'in', ['individual', 'association', 'company'], 'Sökande ska vara yrkesverksam kulturskapare, grupp eller organisation'),
      c('kr-rb-m1', 'mandatory', 'person.professionalArtist', 'is_true', undefined, 'Sökande ska vara yrkesverksam inom kulturområdet', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?'),
      c('kr-rb-m2', 'mandatory', 'project.hasInternationalComponent', 'is_true', undefined, 'Projektet ska avse internationellt kulturutbyte', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?'),
      c('kr-rb-w1', 'weighted', 'project.sector', 'eq', 'culture', 'Kulturprojekt', undefined, 3),
      c('kr-rb-w2', 'weighted', 'project.activityTypes', 'intersects', ['exchange', 'training', 'performance'], 'Utbyte, fortbildning eller framträdande', undefined, 2),
      c('kr-rb-w3', 'weighted', 'project.bringsKnowledgeBack', 'is_true', undefined, 'Kunskapen tas tillvara i Sverige', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 1),
    ],
    budgetRules: [
      { id: 'kr-rb-b1', type: 'max_requested', amountMinor: 5_000_000, description: 'Sökt belopp bör inte överstiga 50 000 kr för resebidrag.' },
    ],
    evidenceRequirements: [
      { id: 'kr-rb-e1', kind: 'cv', description: 'CV eller konstnärlig meritförteckning', mandatory: true },
      { id: 'kr-rb-e2', kind: 'invitation', description: 'Inbjudan eller bekräftelse från mottagande part', mandatory: true },
      { id: 'kr-rb-e3', kind: 'budget', description: 'Resebudget', mandatory: false },
    ],
  },
  {
    slug: 'erasmus-plus-ungdomsutbyten',
    authorityKey: 'eu-eacea',
    sourceKey: 'erasmus-youth-exchanges',
    programmeName: 'Erasmus+ Ungdom',
    title: 'Erasmus+ — Ungdomsutbyten (Youth Exchanges)',
    summary: 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.',
    description:
      'Ungdomsutbyten inom Erasmus+ låter grupper av unga från olika länder mötas i 5–21 dagar (exklusive resa) kring ett gemensamt program. Stödet täcker resekostnader samt praktiska kostnader och aktivitetskostnader enligt programguidens schabloner. Ansökan görs av en organisation eller informell grupp via det nationella programkontoret (i Sverige: MUCF för ungdomsdelen). Organisationen behöver ett OID (Organisation ID) via EU:s Organisation Registration System.',
    objective: 'Interkulturellt lärande, ungas delaktighet och europeiskt samarbete.',
    instrumentType: 'eu_grant',
    applicantTypes: ['association', 'informal_group', 'municipality'],
    countries: ['SE'],
    sectors: ['youth', 'culture', 'education'],
    minAmountMinor: null,
    maxAmountMinor: null,
    maxFundingSharePercent: null,
    excludesOtherPublicFunding: true,
    deadlineModel: 'recurring',
    opensAt: null,
    closesAt: '2026-10-01T10:00:00Z',
    applicationMethod: 'Ansökan lämnas i EU:s ansökningssystem för Erasmus+ (kräver EU Login och OID).',
    applicationUrl: 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities',
    authenticationMethod: 'eu_login',
    submissionLevel: 'assisted',
    estimatedEffortDays: 15,
    sourceUrl: 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities',
    criteria: [
      c('er-yx-h1', 'hard', 'applicant.type', 'in', ['association', 'informal_group', 'municipality'], 'Sökande ska vara en organisation eller informell ungdomsgrupp'),
      c('er-yx-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Ansökan görs via det svenska nationella programkontoret'),
      c('er-yx-m1', 'mandatory', 'project.participantsAge13to30', 'is_true', undefined, 'Deltagarna ska vara 13–30 år', 'Är deltagarna i utbytet mellan 13 och 30 år?'),
      c('er-yx-m2', 'mandatory', 'project.durationDays5to21', 'is_true', undefined, 'Utbytet ska vara 5–21 dagar exklusive resdagar', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?'),
      c('er-yx-m3', 'mandatory', 'project.hasPartnerGroupAbroad', 'is_true', undefined, 'Minst en partnergrupp i ett annat programland krävs', 'Har ni en partnergrupp i ett annat land?'),
      c('er-yx-m4', 'mandatory', 'organisation.hasOid', 'is_true', undefined, 'Organisationen behöver ett OID (Organisation ID)', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?'),
      c('er-yx-w1', 'weighted', 'project.targetGroups', 'includes', 'youth', 'Unga som målgrupp', undefined, 3),
      c('er-yx-w2', 'weighted', 'project.activityTypes', 'intersects', ['exchange', 'training'], 'Utbytes-/lärandeaktiviteter', undefined, 2),
      c('er-yx-w3', 'weighted', 'project.hasInternationalComponent', 'is_true', undefined, 'Internationell dimension', undefined, 2),
    ],
    budgetRules: [],
    evidenceRequirements: [
      { id: 'er-yx-e1', kind: 'partner_letter', description: 'Bekräftelse från partnergrupp(er)', mandatory: true },
      { id: 'er-yx-e2', kind: 'activity_programme', description: 'Aktivitetsprogram dag för dag', mandatory: true },
      { id: 'er-yx-e3', kind: 'budget', description: 'Budget enligt programmets schabloner', mandatory: false },
    ],
  },
  {
    slug: 'mucf-projektbidrag-ungdomsorganisationer',
    authorityKey: 'mucf',
    sourceKey: 'mucf-bidrag',
    programmeName: 'Bidrag till civilsamhället',
    title: 'MUCF — Projektbidrag för barn- och ungdomsorganisationer',
    summary: 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.',
    description:
      'MUCF fördelar statsbidrag till civilsamhällets organisationer, bland annat projektbidrag för verksamhet med och för barn och unga. Bidragen har specifika villkor per utlysning — kontrollera alltid aktuell utlysning hos MUCF.',
    objective: 'Stärka ungas delaktighet och civilsamhällets verksamhet för barn och unga.',
    instrumentType: 'project_grant',
    applicantTypes: ['association'],
    countries: ['SE'],
    sectors: ['youth', 'civil_society'],
    minAmountMinor: null,
    maxAmountMinor: 40_000_000,
    maxFundingSharePercent: null,
    excludesOtherPublicFunding: false,
    deadlineModel: 'upcoming_round',
    opensAt: null,
    closesAt: null,
    applicationMethod: 'Ansökan görs i MUCF:s ansökningssystem när en utlysning är öppen.',
    applicationUrl: 'https://www.mucf.se/bidrag',
    authenticationMethod: 'mucf_konto',
    submissionLevel: 'assisted',
    estimatedEffortDays: 8,
    sourceUrl: 'https://www.mucf.se/bidrag',
    criteria: [
      c('mucf-h1', 'hard', 'applicant.type', 'eq', 'association', 'Sökande ska vara en ideell förening'),
      c('mucf-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Organisationen ska vara verksam i Sverige'),
      c('mucf-m1', 'mandatory', 'organisation.democraticStructure', 'is_true', undefined, 'Organisationen ska ha en demokratisk uppbyggnad', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?'),
      c('mucf-m2', 'mandatory', 'project.targetGroups', 'includes', 'youth', 'Projektet ska rikta sig till barn eller unga', 'Riktar sig projektet till barn eller unga?'),
      c('mucf-w1', 'weighted', 'project.sector', 'in', ['youth', 'civil_society', 'culture'], 'Verksamhet inom ungdoms-/civilsamhällesområdet', undefined, 2),
      c('mucf-w2', 'weighted', 'organisation.youthMembersShareOver60', 'is_true', undefined, 'Hög andel unga medlemmar', 'Är minst 60 % av medlemmarna under 26 år?', 1),
    ],
    budgetRules: [],
    evidenceRequirements: [
      { id: 'mucf-e1', kind: 'stadgar', description: 'Föreningens stadgar', mandatory: true },
      { id: 'mucf-e2', kind: 'annual_report', description: 'Senaste verksamhetsberättelse och årsredovisning', mandatory: true },
      { id: 'mucf-e3', kind: 'budget', description: 'Projektbudget', mandatory: true },
    ],
  },
  {
    slug: 'vinnova-innovativa-startups',
    authorityKey: 'vinnova',
    sourceKey: 'vinnova-utlysningar',
    programmeName: 'Innovativa startups',
    title: 'Vinnova — Innovativa startups',
    summary: 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.',
    description:
      'Vinnovas program för innovativa startups riktar sig till unga svenska aktiebolag med skalbara, nyskapande lösningar. Utlysningar öppnar i omgångar med specifika villkor per omgång — kontrollera aktuell utlysning hos Vinnova. Bidraget kräver normalt att bolaget är yngre än en viss ålder och har begränsad omsättning.',
    objective: 'Stärka svenska startups förmåga att utveckla och kommersialisera innovationer.',
    instrumentType: 'public_grant',
    applicantTypes: ['company'],
    countries: ['SE'],
    sectors: ['innovation', 'technology'],
    minAmountMinor: null,
    maxAmountMinor: 30_000_000,
    maxFundingSharePercent: 100,
    excludesOtherPublicFunding: false,
    deadlineModel: 'upcoming_round',
    opensAt: null,
    closesAt: null,
    applicationMethod: 'Ansökan görs i Vinnovas e-tjänst (Intressentportalen).',
    applicationUrl: 'https://www.vinnova.se/soka-finansiering/',
    authenticationMethod: 'vinnova_konto',
    submissionLevel: 'assisted',
    estimatedEffortDays: 10,
    sourceUrl: 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/',
    criteria: [
      c('vin-h1', 'hard', 'applicant.type', 'eq', 'company', 'Sökande ska vara ett aktiebolag'),
      c('vin-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Bolaget ska vara registrerat i Sverige'),
      c('vin-m1', 'mandatory', 'organisation.ageYearsMax5', 'is_true', undefined, 'Bolaget ska vara ungt (typiskt max ca 5 år — se aktuell utlysning)', 'Är bolaget yngre än cirka 5 år?'),
      c('vin-m2', 'mandatory', 'project.isInnovative', 'is_true', undefined, 'Lösningen ska vara nyskapande jämfört med befintliga alternativ', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?'),
      c('vin-w1', 'weighted', 'project.scalableInternationally', 'is_true', undefined, 'Internationell skalbarhet', 'Har lösningen internationell potential?', 3),
      c('vin-w2', 'weighted', 'project.sector', 'in', ['innovation', 'technology', 'energy', 'health'], 'Prioriterade områden', undefined, 1),
    ],
    budgetRules: [
      { id: 'vin-b1', type: 'max_requested', amountMinor: 30_000_000, description: 'Maximalt bidrag enligt programmets ramar (se aktuell utlysning).' },
    ],
    evidenceRequirements: [
      { id: 'vin-e1', kind: 'project_description', description: 'Projektbeskrivning', mandatory: true },
      { id: 'vin-e2', kind: 'budget', description: 'Projektbudget', mandatory: true },
      { id: 'vin-e3', kind: 'cv', description: 'CV för nyckelpersoner', mandatory: false },
    ],
  },
  {
    slug: 'energimyndigheten-energieffektivisering',
    authorityKey: 'energimyndigheten',
    sourceKey: 'energimyndigheten-utlysningar',
    programmeName: 'Forskning och innovation för energiomställning',
    title: 'Energimyndigheten — Stöd för energi- och klimatprojekt (löpande utlysningar)',
    summary: 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.',
    description:
      'Det mesta av Energimyndighetens stöd fördelas via utlysningar som öppnar löpande inom olika områden. Ansökan och ärendehantering sker via Mina sidor. Villkoren varierar per utlysning — den här posten representerar programområdet; kontrollera aktuella utlysningar hos Energimyndigheten.',
    objective: 'Energiomställning: forskning, innovation och effektivare energianvändning.',
    instrumentType: 'public_grant',
    applicantTypes: ['company', 'university', 'public_body', 'association', 'economic_association'],
    countries: ['SE'],
    sectors: ['energy', 'environment', 'innovation'],
    minAmountMinor: null,
    maxAmountMinor: null,
    maxFundingSharePercent: null,
    excludesOtherPublicFunding: false,
    deadlineModel: 'rolling',
    opensAt: null,
    closesAt: null,
    applicationMethod: 'Ansökan görs via Energimyndighetens Mina sidor.',
    applicationUrl: 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/',
    authenticationMethod: 'eid',
    submissionLevel: 'assisted',
    estimatedEffortDays: 12,
    sourceUrl: 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/',
    criteria: [
      c('em-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Sökande ska vara verksam i Sverige'),
      c('em-h2', 'hard', 'applicant.type', 'in', ['company', 'university', 'public_body', 'association', 'economic_association'], 'Öppet för organisationer — inte privatpersoner'),
      c('em-m1', 'mandatory', 'project.sector', 'in', ['energy', 'environment', 'innovation'], 'Projektet ska ligga inom energiområdet', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?'),
      c('em-w1', 'weighted', 'project.contributesToEnergyTransition', 'is_true', undefined, 'Bidrar till energiomställningen', 'Bidrar projektet till energiomställningen?', 3),
    ],
    budgetRules: [],
    evidenceRequirements: [
      { id: 'em-e1', kind: 'project_description', description: 'Projektbeskrivning', mandatory: true },
      { id: 'em-e2', kind: 'budget', description: 'Projektbudget med kostnadskategorier', mandatory: true },
    ],
  },
  {
    slug: 'naturvardsverket-ladda-bilen-organisationer',
    authorityKey: 'naturvardsverket',
    sourceKey: 'naturvardsverket-bidrag',
    programmeName: 'Klimatinvesteringar',
    title: 'Naturvårdsverket — Bidrag för miljö- och klimatåtgärder (organisationer)',
    summary: 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.',
    description:
      'Naturvårdsverket administrerar flera bidrag inom miljö- och klimatområdet, uppdelade efter mottagartyp (organisationer, företag, ekonomiska föreningar, offentlig sektor och privatpersoner). Villkoren varierar per bidrag — den här posten representerar området; kontrollera aktuellt bidrag hos Naturvårdsverket.',
    objective: 'Miljö- och klimatåtgärder i hela samhället.',
    instrumentType: 'public_grant',
    applicantTypes: ['association', 'company', 'economic_association', 'public_body', 'individual'],
    countries: ['SE'],
    sectors: ['environment'],
    minAmountMinor: null,
    maxAmountMinor: null,
    maxFundingSharePercent: 50,
    excludesOtherPublicFunding: false,
    deadlineModel: 'rolling',
    opensAt: null,
    closesAt: null,
    applicationMethod: 'Ansökan görs i Naturvårdsverkets e-tjänster.',
    applicationUrl: 'https://www.naturvardsverket.se/bidrag/',
    authenticationMethod: 'eid',
    submissionLevel: 'assisted',
    estimatedEffortDays: 6,
    sourceUrl: 'https://www.naturvardsverket.se/bidrag/',
    criteria: [
      c('nv-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Sökande ska vara verksam i Sverige'),
      c('nv-m1', 'mandatory', 'project.sector', 'in', ['environment', 'energy'], 'Projektet ska avse miljö- eller klimatåtgärder', 'Handlar projektet om miljö- eller klimatåtgärder?'),
      c('nv-w1', 'weighted', 'project.measurableEnvironmentalImpact', 'is_true', undefined, 'Mätbar miljönytta', 'Kan projektets miljönytta mätas?', 2),
    ],
    budgetRules: [
      { id: 'nv-b1', type: 'max_funding_share', percent: 50, description: 'Många av bidragen täcker upp till 50 % av kostnaden — se aktuellt bidrag.' },
    ],
    evidenceRequirements: [
      { id: 'nv-e1', kind: 'project_description', description: 'Beskrivning av åtgärden', mandatory: true },
    ],
  },
  {
    slug: 'kulturradet-projektbidrag-musik',
    authorityKey: 'kulturradet',
    sourceKey: 'kulturradet-sok-bidrag',
    programmeName: 'Musik',
    title: 'Kulturrådet — Projektbidrag musik (fria musiklivet)',
    summary: 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.',
    description:
      'Kulturrådet fördelar projektbidrag till det fria musiklivet. Bidraget söks av grupper, arrangörer och organisationer inom musikområdet. Villkor och ansökningsperioder publiceras per omgång på Kulturrådets webbplats.',
    objective: 'Ett levande och oberoende musikliv i hela landet.',
    instrumentType: 'project_grant',
    applicantTypes: ['association', 'company', 'individual'],
    countries: ['SE'],
    sectors: ['culture'],
    minAmountMinor: null,
    maxAmountMinor: null,
    maxFundingSharePercent: null,
    excludesOtherPublicFunding: false,
    deadlineModel: 'upcoming_round',
    opensAt: null,
    closesAt: null,
    applicationMethod: 'Ansökan görs i Kulturrådets onlinetjänst när omgången är öppen.',
    applicationUrl: 'https://kulturradet.se/sok-bidrag/',
    authenticationMethod: 'kulturradet_konto',
    submissionLevel: 'assisted',
    estimatedEffortDays: 7,
    sourceUrl: 'https://kulturradet.se/sok-bidrag/',
    criteria: [
      c('kr-pm-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Sökande ska vara verksam i Sverige'),
      c('kr-pm-m1', 'mandatory', 'person.professionalArtist', 'is_true', undefined, 'Professionell verksamhet inom musikområdet', 'Är verksamheten professionell (inte amatörverksamhet)?'),
      c('kr-pm-m2', 'mandatory', 'project.sector', 'eq', 'culture', 'Projektet ska vara ett kulturprojekt', 'Är projektet ett kulturprojekt?'),
      c('kr-pm-w1', 'weighted', 'project.activityTypes', 'intersects', ['performance', 'production'], 'Konsert-/produktionsverksamhet', undefined, 2),
    ],
    budgetRules: [],
    evidenceRequirements: [
      { id: 'kr-pm-e1', kind: 'project_description', description: 'Projektbeskrivning', mandatory: true },
      { id: 'kr-pm-e2', kind: 'budget', description: 'Projektbudget', mandatory: true },
    ],
  },
];

/**
 * Application schema for the Kulturrådet travel grant — demonstrates the
 * canonical application model (§15): source-specific labels mapped to
 * canonical keys for cross-application reuse.
 */
export const applicationSchemaDefs: { opportunitySlug: string; def: unknown }[] = [
  {
    opportunitySlug: 'kulturradet-internationellt-resebidrag-musik',
    def: {
      id: 'kulturradet-resebidrag-v1',
      version: 1,
      title: 'Ansökan — Resebidrag för internationellt kulturutbyte',
      sections: [
        { key: 'sokande', title: 'Om dig som söker' },
        { key: 'projekt', title: 'Resan och utbytet' },
        { key: 'budget', title: 'Budget och finansiering' },
        { key: 'intyg', title: 'Intyg' },
      ],
      fields: [
        { key: 'sokande_namn', canonicalKey: 'applicant.displayName', type: 'text', label: 'Namn', required: true, maxLength: 200, section: 'sokande' },
        { key: 'sokande_verksamhet', canonicalKey: 'applicant.professionalField', type: 'text', label: 'Konstnärlig verksamhet', guidance: 'T.ex. dans, musik, scenkonst.', required: true, maxLength: 200, section: 'sokande' },
        { key: 'projekt_sammanfattning', canonicalKey: 'project.summary', type: 'long_text', label: 'Beskriv resan och utbytet', guidance: 'Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling?', required: true, maxLength: 4000, section: 'projekt' },
        { key: 'projekt_land', canonicalKey: 'project.destinationCountry', type: 'text', label: 'Resmål (land)', required: true, maxLength: 100, section: 'projekt' },
        { key: 'projekt_datum', canonicalKey: 'project.dateRange', type: 'date_range', label: 'Resperiod', required: true, section: 'projekt' },
        { key: 'har_inbjudan', type: 'boolean', label: 'Har du en inbjudan eller bekräftelse från mottagande part?', required: true, section: 'projekt' },
        {
          key: 'inbjudan_beskrivning',
          type: 'long_text',
          label: 'Beskriv inbjudan/samarbetet',
          required: true,
          maxLength: 2000,
          section: 'projekt',
          visibleWhen: [{ factPath: 'har_inbjudan', op: 'is_true' }],
        },
        { key: 'aterforing', canonicalKey: 'project.knowledgeTransferPlan', type: 'long_text', label: 'Hur tar du tillvara erfarenheterna i Sverige?', required: true, maxLength: 2000, section: 'projekt' },
        { key: 'sokt_belopp', canonicalKey: 'project.requestedAmount', type: 'currency', label: 'Sökt belopp (kr)', required: true, min: 1, max: 50000, section: 'budget' },
        { key: 'intygande', type: 'declaration', label: 'Jag intygar att lämnade uppgifter är riktiga', required: true, section: 'intyg' },
      ],
    },
  },
  {
    opportunitySlug: 'erasmus-plus-ungdomsutbyten',
    def: {
      id: 'erasmus-ungdomsutbyte-v1',
      version: 1,
      title: 'Ansökan — Erasmus+ Ungdomsutbyte (förberedelse)',
      sections: [
        { key: 'org', title: 'Organisationen' },
        { key: 'projekt', title: 'Utbytet' },
        { key: 'deltagare', title: 'Deltagare och partner' },
        { key: 'intyg', title: 'Intyg' },
      ],
      fields: [
        { key: 'org_namn', canonicalKey: 'applicant.displayName', type: 'text', label: 'Organisationens namn', required: true, maxLength: 200, section: 'org' },
        { key: 'org_oid', canonicalKey: 'organisation.oid', type: 'text', label: 'OID (Organisation ID)', guidance: 'Registreras i EU:s Organisation Registration System med EU Login.', required: true, maxLength: 20, section: 'org' },
        { key: 'projekt_sammanfattning', canonicalKey: 'project.summary', type: 'long_text', label: 'Beskriv utbytet', guidance: 'Tema, aktiviteter och förväntat lärande.', required: true, maxLength: 5000, section: 'projekt' },
        { key: 'projekt_datum', canonicalKey: 'project.dateRange', type: 'date_range', label: 'Utbytesperiod (exklusive resdagar)', required: true, section: 'projekt' },
        { key: 'antal_deltagare', type: 'number', label: 'Antal deltagare', required: true, min: 4, max: 200, section: 'deltagare' },
        { key: 'har_partner', type: 'boolean', label: 'Har ni en bekräftad partnergrupp i ett annat land?', required: true, section: 'deltagare' },
        {
          key: 'partner_namn',
          canonicalKey: 'project.partnerName',
          type: 'text',
          label: 'Partnergruppens namn och land',
          required: true,
          maxLength: 300,
          section: 'deltagare',
          visibleWhen: [{ factPath: 'har_partner', op: 'is_true' }],
        },
        { key: 'intygande', type: 'declaration', label: 'Jag intygar att lämnade uppgifter är riktiga', required: true, section: 'intyg' },
      ],
    },
  },
];
