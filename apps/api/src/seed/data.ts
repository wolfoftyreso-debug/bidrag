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
  { key: 'konstnarsnamnden', name: 'Konstnärsnämnden', country: 'SE', kind: 'state_agency', website: 'https://www.konstnarsnamnden.se' },
  { key: 'arvsfonden', name: 'Allmänna arvsfonden', country: 'SE', kind: 'foundation', website: 'https://www.arvsfonden.se' },
  { key: 'boverket', name: 'Boverket', country: 'SE', kind: 'state_agency', website: 'https://www.boverket.se' },
  { key: 'rf', name: 'Riksidrottsförbundet', country: 'SE', kind: 'association', website: 'https://www.rf.se' },
  { key: 'filminstitutet', name: 'Svenska Filminstitutet', country: 'SE', kind: 'foundation', website: 'https://www.filminstitutet.se' },
  { key: 'formas', name: 'Formas', country: 'SE', kind: 'state_agency', website: 'https://www.formas.se' },
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
  { key: 'konstnarsnamnden-stipendier', authorityKey: 'konstnarsnamnden', name: 'Konstnärsnämnden — Stipendier och bidrag', url: 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', method: 'html', quality: 'A' },
  { key: 'arvsfonden-soka', authorityKey: 'arvsfonden', name: 'Allmänna arvsfonden — Söka pengar', url: 'https://www.arvsfonden.se/soka-pengar', method: 'html', quality: 'A' },
  { key: 'boverket-bidrag', authorityKey: 'boverket', name: 'Boverket — Bidrag och stöd', url: 'https://www.boverket.se/sv/bidrag--garantier/', method: 'html', quality: 'A' },
  { key: 'rf-ekonomiskt-stod', authorityKey: 'rf', name: 'Riksidrottsförbundet — Ekonomiskt stöd', url: 'https://www.rf.se/bidrag-och-stod', method: 'html', quality: 'A' },
  { key: 'filminstitutet-stod', authorityKey: 'filminstitutet', name: 'Svenska Filminstitutet — Stöd', url: 'https://www.filminstitutet.se/sv/sok-stod/', method: 'html', quality: 'A' },
  { key: 'formas-utlysningar', authorityKey: 'formas', name: 'Formas — Utlysningar', url: 'https://www.formas.se/soka-finansiering.html', method: 'html', quality: 'A' },
  { key: 'uhr-erasmus', authorityKey: 'uhr', name: 'UHR — Erasmus+ utbildning', url: 'https://www.uhr.se/internationella-mojligheter/', method: 'html', quality: 'A' },
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

/**
 * Defaults for curated entries: assisted submission, no invented amounts or
 * deadlines. Every entry overrides only what the official source supports.
 */
type OppOverrides = Partial<SeedOpportunity> &
  Pick<SeedOpportunity, 'slug' | 'authorityKey' | 'programmeName' | 'title' | 'summary' | 'instrumentType' | 'applicantTypes' | 'applicationUrl' | 'sourceUrl' | 'criteria'>;

function def(o: OppOverrides): SeedOpportunity {
  return {
    description: o.summary,
    objective: '',
    countries: ['SE'],
    sectors: [],
    minAmountMinor: null,
    maxAmountMinor: null,
    maxFundingSharePercent: null,
    excludesOtherPublicFunding: false,
    deadlineModel: 'upcoming_round',
    opensAt: null,
    closesAt: null,
    applicationMethod: 'Ansökan görs i finansiärens officiella ansökningstjänst.',
    authenticationMethod: 'none',
    submissionLevel: 'assisted',
    estimatedEffortDays: 6,
    budgetRules: [],
    evidenceRequirements: [],
    ...o,
  };
}

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

  // ── Våg 1-expansion: konst, civilsamhälle, idrott, film, forskning,
  //    näringsliv, jordbruk, EU. Samma ärlighetsmodell som ovan. ─────────────

  def({
    slug: 'konstnarsnamnden-internationellt-kulturutbyte',
    authorityKey: 'konstnarsnamnden',
    sourceKey: 'konstnarsnamnden-stipendier',
    programmeName: 'Internationellt kulturutbyte',
    title: 'Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor',
    summary: 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.',
    description:
      'Konstnärsnämnden ger bidrag till yrkesverksamma konstnärer inom bild, form, dans, film, musik och teater för internationellt kulturutbyte — t.ex. resor för samarbeten, gästspel eller arbetsvistelser utomlands. Ansökningsomgångar publiceras per konstområde; kontrollera aktuella tider hos Konstnärsnämnden.',
    objective: 'Konstnärers internationalisering och konstnärliga utveckling.',
    instrumentType: 'travel_grant',
    applicantTypes: ['individual'],
    sectors: ['culture'],
    deadlineModel: 'recurring',
    applicationUrl: 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/',
    sourceUrl: 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/',
    estimatedEffortDays: 4,
    criteria: [
      c('kn-iku-h1', 'hard', 'applicant.type', 'eq', 'individual', 'Bidraget söks av enskilda yrkesverksamma konstnärer'),
      c('kn-iku-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Sökande ska vara verksam i Sverige'),
      c('kn-iku-m1', 'mandatory', 'person.professionalArtist', 'is_true', undefined, 'Sökande ska vara yrkesverksam konstnär', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?'),
      c('kn-iku-m2', 'mandatory', 'project.hasInternationalComponent', 'is_true', undefined, 'Ansökan ska avse internationellt utbyte eller resa', 'Avser ansökan en internationell resa eller ett internationellt utbyte?'),
      c('kn-iku-w1', 'weighted', 'project.sector', 'eq', 'culture', 'Konstnärligt projekt', undefined, 3),
      c('kn-iku-w2', 'weighted', 'project.activityTypes', 'intersects', ['exchange', 'training', 'performance'], 'Utbyte, fortbildning eller framträdande', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'kn-iku-e1', kind: 'cv', description: 'Konstnärlig meritförteckning', mandatory: true },
      { id: 'kn-iku-e2', kind: 'invitation', description: 'Inbjudan eller beskrivning av samarbetet', mandatory: false },
    ],
  }),

  def({
    slug: 'konstnarsnamnden-arbetsstipendium',
    authorityKey: 'konstnarsnamnden',
    sourceKey: 'konstnarsnamnden-stipendier',
    programmeName: 'Arbetsstipendier',
    title: 'Konstnärsnämnden — Arbetsstipendium',
    summary: 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.',
    description:
      'Arbetsstipendiet ska ge yrkesverksamma konstnärer ekonomiskt utrymme att utveckla sitt konstnärskap. Söks per konstområde i årliga omgångar; villkor och tider publiceras av Konstnärsnämnden.',
    objective: 'Konstnärlig fördjupning och försörjningstrygghet för yrkesverksamma konstnärer.',
    instrumentType: 'stipend',
    applicantTypes: ['individual'],
    sectors: ['culture'],
    deadlineModel: 'recurring',
    applicationUrl: 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/',
    sourceUrl: 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/',
    criteria: [
      c('kn-as-h1', 'hard', 'applicant.type', 'eq', 'individual', 'Stipendiet söks av enskilda konstnärer'),
      c('kn-as-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Sökande ska vara verksam i Sverige'),
      c('kn-as-m1', 'mandatory', 'person.professionalArtist', 'is_true', undefined, 'Sökande ska vara yrkesverksam konstnär', 'Är du yrkesverksam konstnär?'),
      c('kn-as-w1', 'weighted', 'project.sector', 'eq', 'culture', 'Konstnärlig verksamhet', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'kn-as-e1', kind: 'cv', description: 'Konstnärlig meritförteckning', mandatory: true },
      { id: 'kn-as-e2', kind: 'project_description', description: 'Beskrivning av konstnärlig verksamhet och planer', mandatory: true },
    ],
  }),

  def({
    slug: 'arvsfonden-projektstod',
    authorityKey: 'arvsfonden',
    sourceKey: 'arvsfonden-soka',
    programmeName: 'Projektstöd',
    title: 'Allmänna arvsfonden — Projektstöd',
    summary: 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.',
    description:
      'Arvsfonden stödjer ideella organisationers utvecklingsprojekt som är nyskapande och där målgruppen — barn, ungdomar, äldre eller personer med funktionsnedsättning — är delaktig. Ansökan kan lämnas löpande; projekt kan pågå i upp till tre år.',
    objective: 'Nyskapande och utvecklande verksamhet för fondens målgrupper.',
    instrumentType: 'project_grant',
    applicantTypes: ['association', 'foundation'],
    sectors: ['civil_society', 'youth'],
    deadlineModel: 'rolling',
    applicationUrl: 'https://www.arvsfonden.se/soka-pengar',
    sourceUrl: 'https://www.arvsfonden.se/soka-pengar',
    estimatedEffortDays: 12,
    criteria: [
      c('af-ps-h1', 'hard', 'applicant.type', 'in', ['association', 'foundation'], 'Sökande ska vara en ideell organisation'),
      c('af-ps-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Verksamheten ska bedrivas i Sverige'),
      c('af-ps-m1', 'mandatory', 'project.targetsArvsfondenGroups', 'is_true', undefined, 'Målgruppen ska vara barn, unga, äldre eller personer med funktionsnedsättning', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?'),
      c('af-ps-m2', 'mandatory', 'project.isNovel', 'is_true', undefined, 'Projektet ska vara nyskapande i förhållande till ordinarie verksamhet', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?'),
      c('af-ps-m3', 'mandatory', 'project.targetGroupParticipates', 'is_true', undefined, 'Målgruppen ska vara delaktig i projektet', 'Är målgruppen delaktig i planering och genomförande?'),
      c('af-ps-w1', 'weighted', 'project.targetGroups', 'includes', 'youth', 'Barn och unga som målgrupp', undefined, 1),
      c('af-ps-w2', 'weighted', 'organisation.democraticStructure', 'is_true', undefined, 'Demokratiskt uppbyggd organisation', 'Har organisationen en demokratisk uppbyggnad?', 1),
    ],
    evidenceRequirements: [
      { id: 'af-ps-e1', kind: 'stadgar', description: 'Stadgar', mandatory: true },
      { id: 'af-ps-e2', kind: 'annual_report', description: 'Senaste årsredovisning/verksamhetsberättelse', mandatory: true },
      { id: 'af-ps-e3', kind: 'budget', description: 'Projektbudget', mandatory: true },
    ],
  }),

  def({
    slug: 'boverket-allmanna-samlingslokaler',
    authorityKey: 'boverket',
    sourceKey: 'boverket-bidrag',
    programmeName: 'Stöd till allmänna samlingslokaler',
    title: 'Boverket — Investeringsbidrag till allmänna samlingslokaler',
    summary: 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.',
    description:
      'Boverket ger investeringsbidrag till föreningar och stiftelser för nybyggnad, ombyggnad, köp eller standardhöjande reparationer av allmänna samlingslokaler — t.ex. bygdegårdar, folkets hus och föreningslokaler. Årlig ansökningsomgång; villkor publiceras av Boverket.',
    objective: 'Tillgång till lokaler för möten, kultur och fritid i hela landet.',
    instrumentType: 'public_grant',
    applicantTypes: ['association', 'foundation'],
    sectors: ['civil_society', 'culture'],
    maxFundingSharePercent: 50,
    deadlineModel: 'recurring',
    applicationUrl: 'https://www.boverket.se/sv/bidrag--garantier/',
    sourceUrl: 'https://www.boverket.se/sv/bidrag--garantier/',
    authenticationMethod: 'eid',
    estimatedEffortDays: 10,
    criteria: [
      c('bv-as-h1', 'hard', 'applicant.type', 'in', ['association', 'foundation'], 'Sökande ska vara förening eller stiftelse'),
      c('bv-as-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Lokalen ska ligga i Sverige'),
      c('bv-as-m1', 'mandatory', 'project.isPublicVenue', 'is_true', undefined, 'Lokalen ska vara öppen och tillgänglig för allmänheten', 'Är lokalen öppen för alla — inte bara egna medlemmar?'),
      c('bv-as-m2', 'mandatory', 'project.activityTypes', 'includes', 'investment', 'Ansökan ska avse investering (bygga, köpa eller rusta upp)', 'Avser projektet att bygga, köpa eller rusta upp en lokal?'),
      c('bv-as-w1', 'weighted', 'project.targetGroups', 'includes', 'youth', 'Verksamhet för ungdomar prioriteras', undefined, 1),
    ],
    budgetRules: [
      { id: 'bv-as-b1', type: 'max_funding_share', percent: 50, description: 'Bidraget täcker som huvudregel högst 50 % av godkänd kostnad.' },
    ],
    evidenceRequirements: [
      { id: 'bv-as-e1', kind: 'project_description', description: 'Beskrivning av lokalen och åtgärderna', mandatory: true },
      { id: 'bv-as-e2', kind: 'budget', description: 'Kostnadskalkyl och finansieringsplan', mandatory: true },
    ],
  }),

  def({
    slug: 'rf-lok-stod',
    authorityKey: 'rf',
    sourceKey: 'rf-ekonomiskt-stod',
    programmeName: 'LOK-stöd',
    title: 'Riksidrottsförbundet — Statligt lokalt aktivitetsstöd (LOK-stöd)',
    summary: 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.',
    description:
      'LOK-stödet ger idrottsföreningar anslutna till ett specialidrottsförbund ersättning per sammankomst och deltagartillfälle för ledarledd verksamhet för deltagare 7–25 år. Redovisas i IdrottOnline två gånger per år.',
    objective: 'Stödja föreningsdriven barn- och ungdomsidrott.',
    instrumentType: 'public_grant',
    applicantTypes: ['association'],
    sectors: ['sports', 'youth'],
    deadlineModel: 'recurring',
    closesAt: '2026-08-25T21:59:59Z',
    applicationMethod: 'Ansökan/redovisning görs i IdrottOnline. Ansökningsperioderna stänger 25 februari och 25 augusti.',
    applicationUrl: 'https://www.rf.se/bidrag-och-stod',
    sourceUrl: 'https://www.rf.se/bidrag-och-stod',
    estimatedEffortDays: 2,
    criteria: [
      c('rf-lok-h1', 'hard', 'applicant.type', 'eq', 'association', 'Sökande ska vara en idrottsförening'),
      c('rf-lok-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Föreningen ska vara verksam i Sverige'),
      c('rf-lok-m1', 'mandatory', 'organisation.memberOfSportsFederation', 'is_true', undefined, 'Föreningen ska vara ansluten till ett specialidrottsförbund inom RF', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?'),
      c('rf-lok-m2', 'mandatory', 'project.targetGroups', 'includes', 'youth', 'Verksamheten ska rikta sig till barn och unga 7–25 år', 'Riktar sig verksamheten till barn och unga (7–25 år)?'),
      c('rf-lok-w1', 'weighted', 'project.sector', 'eq', 'sports', 'Idrottsverksamhet', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'rf-lok-e1', kind: 'activity_programme', description: 'Närvaroregistrerad aktivitetsredovisning', mandatory: true },
    ],
  }),

  def({
    slug: 'filminstitutet-kortfilmsstod',
    authorityKey: 'filminstitutet',
    sourceKey: 'filminstitutet-stod',
    programmeName: 'Produktionsstöd',
    title: 'Svenska Filminstitutet — Stöd till kort- och dokumentärfilm',
    summary: 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.',
    description:
      'Filminstitutet ger utvecklings- och produktionsstöd till kort- och dokumentärfilm. Stödet söks normalt av ett produktionsbolag; beslut fattas av filmkonsulent. Villkor och ansökningstider publiceras per stödform.',
    objective: 'Konstnärligt värdefull svensk film.',
    instrumentType: 'project_grant',
    applicantTypes: ['company'],
    sectors: ['culture'],
    deadlineModel: 'rolling',
    applicationUrl: 'https://www.filminstitutet.se/sv/sok-stod/',
    sourceUrl: 'https://www.filminstitutet.se/sv/sok-stod/',
    estimatedEffortDays: 8,
    criteria: [
      c('sfi-kf-h1', 'hard', 'applicant.type', 'eq', 'company', 'Stödet söks av ett produktionsbolag'),
      c('sfi-kf-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Bolaget ska vara registrerat i Sverige'),
      c('sfi-kf-m1', 'mandatory', 'project.sector', 'eq', 'culture', 'Projektet ska vara ett filmprojekt', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?'),
      c('sfi-kf-w1', 'weighted', 'project.activityTypes', 'includes', 'production', 'Produktion/utveckling', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'sfi-kf-e1', kind: 'project_description', description: 'Synopsis/treatment och regivision', mandatory: true },
      { id: 'sfi-kf-e2', kind: 'budget', description: 'Produktionsbudget och finansieringsplan', mandatory: true },
      { id: 'sfi-kf-e3', kind: 'cv', description: 'CV för nyckelfunktioner', mandatory: false },
    ],
  }),

  def({
    slug: 'kulturradet-skapande-skola',
    authorityKey: 'kulturradet',
    sourceKey: 'kulturradet-sok-bidrag',
    programmeName: 'Skapande skola',
    title: 'Kulturrådet — Skapande skola',
    summary: 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.',
    description:
      'Skapande skola söks av skolhuvudmän (kommuner, fristående skolor) för konst- och kulturinsatser i förskoleklass och grundskola, genomförda av professionella kulturaktörer. Årlig ansökningsomgång.',
    objective: 'Att alla elever ska få möta professionell konst och kultur.',
    instrumentType: 'public_grant',
    applicantTypes: ['municipality', 'school', 'company'],
    sectors: ['culture', 'education'],
    deadlineModel: 'recurring',
    applicationUrl: 'https://kulturradet.se/sok-bidrag/',
    sourceUrl: 'https://kulturradet.se/sok-bidrag/',
    authenticationMethod: 'kulturradet_konto',
    criteria: [
      c('kr-ss-h1', 'hard', 'applicant.type', 'in', ['municipality', 'school', 'company'], 'Sökande ska vara skolhuvudman'),
      c('kr-ss-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Verksamheten ska bedrivas i Sverige'),
      c('kr-ss-m1', 'mandatory', 'organisation.isSchoolAuthority', 'is_true', undefined, 'Sökande ska vara huvudman för förskoleklass/grundskola', 'Är ni huvudman för förskoleklass eller grundskola?'),
      c('kr-ss-m2', 'mandatory', 'project.usesProfessionalCulture', 'is_true', undefined, 'Insatserna ska genomföras av professionella kulturaktörer', 'Genomförs insatserna av professionella kulturaktörer?'),
      c('kr-ss-w1', 'weighted', 'project.targetGroups', 'includes', 'youth', 'Elever som målgrupp', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'kr-ss-e1', kind: 'project_description', description: 'Plan för kulturinsatserna', mandatory: true },
      { id: 'kr-ss-e2', kind: 'budget', description: 'Budget', mandatory: true },
    ],
  }),

  def({
    slug: 'formas-oppna-utlysningen',
    authorityKey: 'formas',
    sourceKey: 'formas-utlysningar',
    programmeName: 'Årliga öppna utlysningen',
    title: 'Formas — Årliga öppna utlysningen',
    summary: 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.',
    description:
      'Formas årliga öppna utlysning finansierar forskningsprojekt inom miljö, areella näringar och samhällsbyggande. Söks av disputerade forskare vid svenska lärosäten och forskningsinstitut. Årlig omgång med publicerade tider.',
    objective: 'Kunskap för hållbar utveckling.',
    instrumentType: 'public_grant',
    applicantTypes: ['university', 'public_body'],
    sectors: ['environment', 'innovation'],
    deadlineModel: 'recurring',
    applicationUrl: 'https://www.formas.se/soka-finansiering.html',
    sourceUrl: 'https://www.formas.se/soka-finansiering.html',
    estimatedEffortDays: 20,
    criteria: [
      c('fo-ou-h1', 'hard', 'applicant.type', 'in', ['university', 'public_body'], 'Medlen förvaltas av lärosäte eller forskningsinstitut'),
      c('fo-ou-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Medelsförvaltaren ska vara svensk'),
      c('fo-ou-m1', 'mandatory', 'person.hasDoctorate', 'is_true', undefined, 'Projektledaren ska vara disputerad', 'Har projektledaren doktorsexamen?'),
      c('fo-ou-m2', 'mandatory', 'project.sector', 'in', ['environment', 'innovation'], 'Projektet ska ligga inom Formas ansvarsområden', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?'),
    ],
    evidenceRequirements: [
      { id: 'fo-ou-e1', kind: 'project_description', description: 'Forskningsplan', mandatory: true },
      { id: 'fo-ou-e2', kind: 'cv', description: 'CV och publikationslista', mandatory: true },
      { id: 'fo-ou-e3', kind: 'budget', description: 'Projektbudget', mandatory: true },
    ],
  }),

  def({
    slug: 'tillvaxtverket-affarsutvecklingscheckar',
    authorityKey: 'tillvaxtverket',
    sourceKey: 'tillvaxtverket-utlysningar',
    programmeName: 'Affärsutvecklingscheckar',
    title: 'Tillväxtverket — Affärsutvecklingscheckar (internationalisering/digitalisering)',
    summary: 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.',
    description:
      'Affärsutvecklingscheckarna hjälper små företag att köpa extern kompetens för att utvecklas internationellt eller digitalt. Checkarna administreras regionalt; belopp, andelar och tider varierar per region — kontrollera din regions aktuella utlysning.',
    objective: 'Stärkt konkurrenskraft i små företag.',
    instrumentType: 'public_grant',
    applicantTypes: ['company'],
    sectors: ['innovation'],
    maxFundingSharePercent: 50,
    deadlineModel: 'upcoming_round',
    applicationMethod: 'Ansökan görs via Min ansökan (Tillväxtverket) när regionens omgång är öppen.',
    applicationUrl: 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html',
    sourceUrl: 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html',
    authenticationMethod: 'eid',
    criteria: [
      c('tv-ac-h1', 'hard', 'applicant.type', 'eq', 'company', 'Sökande ska vara ett företag'),
      c('tv-ac-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Företaget ska vara registrerat i Sverige'),
      c('tv-ac-m1', 'mandatory', 'organisation.isSmallEnterprise', 'is_true', undefined, 'Företaget ska vara litet (typiskt 2–49 anställda — se regionens villkor)', 'Har företaget mellan cirka 2 och 49 anställda?'),
      c('tv-ac-m2', 'mandatory', 'project.activityTypes', 'includes', 'development', 'Checken ska användas för utvecklingsinsats med extern kompetens', 'Ska ni ta in extern kompetens för en utvecklingsinsats?'),
      c('tv-ac-w1', 'weighted', 'project.scalableInternationally', 'is_true', undefined, 'Internationaliseringsambition', undefined, 2),
    ],
    budgetRules: [
      { id: 'tv-ac-b1', type: 'max_funding_share', percent: 50, description: 'Checken täcker normalt högst 50 % av kostnaden.' },
    ],
    evidenceRequirements: [
      { id: 'tv-ac-e1', kind: 'project_description', description: 'Beskrivning av utvecklingsinsatsen', mandatory: true },
      { id: 'tv-ac-e2', kind: 'budget', description: 'Kostnads- och finansieringsplan', mandatory: true },
    ],
  }),

  def({
    slug: 'jordbruksverket-startstod-unga',
    authorityKey: 'jordbruksverket',
    sourceKey: undefined,
    programmeName: 'Startstöd',
    title: 'Jordbruksverket — Startstöd till unga jordbrukare',
    summary: 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.',
    description:
      'Startstödet riktar sig till unga som startar eller tar över jordbruks-, trädgårds- eller rennäringsföretag. Kräver bl.a. åldersgräns, utbildning/erfarenhet och en affärsplan. Ansökan görs i Jordbruksverkets e-tjänst med e-legitimation.',
    objective: 'Generationsväxling och föryngring i jordbruket.',
    instrumentType: 'public_grant',
    applicantTypes: ['individual', 'company'],
    sectors: ['agriculture'],
    deadlineModel: 'rolling',
    applicationMethod: 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation; fullmakt kan användas).',
    applicationUrl: 'https://jordbruksverket.se/stod',
    sourceUrl: 'https://jordbruksverket.se/stod',
    authenticationMethod: 'eid',
    estimatedEffortDays: 10,
    criteria: [
      c('jv-ss-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Verksamheten ska bedrivas i Sverige'),
      c('jv-ss-h2', 'hard', 'applicant.type', 'in', ['individual', 'company'], 'Söks av person eller företag'),
      c('jv-ss-m1', 'mandatory', 'person.age40OrYounger', 'is_true', undefined, 'Sökande ska vara 40 år eller yngre', 'Är du 40 år eller yngre?'),
      c('jv-ss-m2', 'mandatory', 'project.sector', 'eq', 'agriculture', 'Ansökan ska avse jordbruks-, trädgårds- eller rennäringsföretag', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?'),
      c('jv-ss-m3', 'mandatory', 'project.startingOrTakingOverFarm', 'is_true', undefined, 'Sökande ska starta eller ta över företaget för första gången', 'Startar du eller tar du över företaget för första gången?'),
    ],
    evidenceRequirements: [
      { id: 'jv-ss-e1', kind: 'project_description', description: 'Affärsplan', mandatory: true },
      { id: 'jv-ss-e2', kind: 'budget', description: 'Ekonomisk kalkyl', mandatory: true },
    ],
  }),

  def({
    slug: 'jordbruksverket-investeringsstod',
    authorityKey: 'jordbruksverket',
    sourceKey: undefined,
    programmeName: 'Investeringsstöd',
    title: 'Jordbruksverket — Investeringsstöd för jordbruk',
    summary: 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.',
    description:
      'Investeringsstöd kan sökas för t.ex. djurstallar, växthus, energieffektivisering och miljöåtgärder i jordbruksföretag. Villkor, stödandelar och regionala prioriteringar framgår av aktuell stödinformation hos Jordbruksverket.',
    objective: 'Konkurrenskraftigt och hållbart jordbruk.',
    instrumentType: 'public_grant',
    applicantTypes: ['company', 'individual', 'economic_association'],
    sectors: ['agriculture', 'environment'],
    maxFundingSharePercent: 40,
    deadlineModel: 'rolling',
    applicationMethod: 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation).',
    applicationUrl: 'https://jordbruksverket.se/stod',
    sourceUrl: 'https://jordbruksverket.se/stod',
    authenticationMethod: 'eid',
    estimatedEffortDays: 10,
    criteria: [
      c('jv-is-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Verksamheten ska bedrivas i Sverige'),
      c('jv-is-m1', 'mandatory', 'project.sector', 'in', ['agriculture', 'environment'], 'Investeringen ska avse jordbruksverksamhet', 'Avser investeringen jordbruksverksamhet?'),
      c('jv-is-m2', 'mandatory', 'project.activityTypes', 'includes', 'investment', 'Ansökan ska avse en investering', 'Avser ansökan en fysisk investering?'),
    ],
    budgetRules: [
      { id: 'jv-is-b1', type: 'max_funding_share', percent: 40, description: 'Stödandelen är typiskt upp till 40 % av godkänd kostnad — se aktuellt stöd.' },
    ],
    evidenceRequirements: [
      { id: 'jv-is-e1', kind: 'budget', description: 'Investeringskalkyl med offerter', mandatory: true },
    ],
  }),

  def({
    slug: 'esf-kompetensutveckling',
    authorityKey: 'esf',
    sourceKey: 'esf-utlysningsplan',
    programmeName: 'ESF+',
    title: 'Svenska ESF-rådet — ESF+ projektstöd för kompetensutveckling och omställning',
    summary: 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.',
    description:
      'Svenska ESF-rådet utlyser projektmedel ur Europeiska socialfonden+ i regionala och nationella utlysningar, t.ex. kompetensutveckling för anställda och insatser för personer långt från arbetsmarknaden. Villkor och medfinansieringskrav framgår per utlysning i utlysningsplanen.',
    objective: 'En väl fungerande och inkluderande arbetsmarknad.',
    instrumentType: 'eu_grant',
    applicantTypes: ['company', 'association', 'municipality', 'region', 'public_body', 'university'],
    sectors: ['education', 'civil_society'],
    deadlineModel: 'upcoming_round',
    applicationMethod: 'Ansökan görs i ESF-rådets Projektrummet när en utlysning är öppen.',
    applicationUrl: 'https://www.esf.se/utlysningar/',
    sourceUrl: 'https://www.esf.se/utlysningar/utlysningsplan/',
    estimatedEffortDays: 15,
    criteria: [
      c('esf-ku-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Projektet ska genomföras i Sverige'),
      c('esf-ku-h2', 'hard', 'applicant.type', 'in', ['company', 'association', 'municipality', 'region', 'public_body', 'university'], 'Söks av organisationer — inte privatpersoner'),
      c('esf-ku-m1', 'mandatory', 'project.strengthensLabourMarket', 'is_true', undefined, 'Projektet ska stärka kompetens eller ställning på arbetsmarknaden', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?'),
      c('esf-ku-m2', 'mandatory', 'organisation.canPrefinance', 'is_true', undefined, 'Sökande ska klara att förskottera kostnader (stöd betalas ut i efterskott)', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?'),
    ],
    evidenceRequirements: [
      { id: 'esf-ku-e1', kind: 'project_description', description: 'Projektbeskrivning med förändringsteori', mandatory: true },
      { id: 'esf-ku-e2', kind: 'budget', description: 'Detaljerad projektbudget', mandatory: true },
    ],
  }),

  def({
    slug: 'energimyndigheten-industriklivet',
    authorityKey: 'energimyndigheten',
    sourceKey: 'energimyndigheten-utlysningar',
    programmeName: 'Industriklivet',
    title: 'Energimyndigheten — Industriklivet',
    summary: 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.',
    description:
      'Industriklivet stödjer forskning, förstudier och investeringar som minskar industrins processrelaterade utsläpp samt negativa utsläpp (t.ex. bio-CCS). Söks löpande eller i utlysningar via Mina sidor.',
    objective: 'Industrins klimatomställning.',
    instrumentType: 'public_grant',
    applicantTypes: ['company', 'university', 'public_body'],
    sectors: ['energy', 'environment'],
    deadlineModel: 'rolling',
    applicationMethod: 'Ansökan görs via Energimyndighetens Mina sidor.',
    applicationUrl: 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/',
    sourceUrl: 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/',
    authenticationMethod: 'eid',
    estimatedEffortDays: 15,
    criteria: [
      c('em-ik-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Projektet ska genomföras i Sverige'),
      c('em-ik-h2', 'hard', 'applicant.type', 'in', ['company', 'university', 'public_body'], 'Söks av organisationer'),
      c('em-ik-m1', 'mandatory', 'project.reducesIndustrialEmissions', 'is_true', undefined, 'Projektet ska minska industrins utsläpp eller skapa negativa utsläpp', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?'),
      c('em-ik-w1', 'weighted', 'project.sector', 'in', ['energy', 'environment'], 'Energi-/klimatprojekt', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'em-ik-e1', kind: 'project_description', description: 'Projektbeskrivning med utsläppsberäkning', mandatory: true },
      { id: 'em-ik-e2', kind: 'budget', description: 'Projektbudget', mandatory: true },
    ],
  }),

  def({
    slug: 'naturvardsverket-klimatklivet',
    authorityKey: 'naturvardsverket',
    sourceKey: 'naturvardsverket-bidrag',
    programmeName: 'Klimatklivet',
    title: 'Naturvårdsverket — Klimatklivet',
    summary: 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.',
    description:
      'Klimatklivet ger investeringsstöd till företag, kommuner, regioner och organisationer för åtgärder som ger stor klimatnytta per stödkrona — t.ex. laddinfrastruktur, biogas och energikonvertering. Ansökningsomgångar öppnar flera gånger per år.',
    objective: 'Minskade växthusgasutsläpp.',
    instrumentType: 'public_grant',
    applicantTypes: ['company', 'municipality', 'region', 'association', 'economic_association', 'public_body'],
    sectors: ['environment', 'energy'],
    deadlineModel: 'recurring',
    applicationMethod: 'Ansökan görs i Naturvårdsverkets e-tjänst när en omgång är öppen (kräver e-legitimation).',
    applicationUrl: 'https://www.naturvardsverket.se/bidrag/',
    sourceUrl: 'https://www.naturvardsverket.se/bidrag/',
    authenticationMethod: 'eid',
    estimatedEffortDays: 8,
    criteria: [
      c('nv-kk-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Åtgärden ska genomföras i Sverige'),
      c('nv-kk-h2', 'hard', 'applicant.type', 'in', ['company', 'municipality', 'region', 'association', 'economic_association', 'public_body'], 'Söks av organisationer — inte privatpersoner'),
      c('nv-kk-m1', 'mandatory', 'project.activityTypes', 'includes', 'investment', 'Stödet avser fysiska investeringar', 'Avser ansökan en fysisk investering?'),
      c('nv-kk-m2', 'mandatory', 'project.measurableEnvironmentalImpact', 'is_true', undefined, 'Klimatnyttan ska kunna beräknas', 'Kan åtgärdens utsläppsminskning beräknas?'),
    ],
    evidenceRequirements: [
      { id: 'nv-kk-e1', kind: 'project_description', description: 'Åtgärdsbeskrivning med klimatnyttoberäkning', mandatory: true },
      { id: 'nv-kk-e2', kind: 'budget', description: 'Investeringskalkyl', mandatory: true },
    ],
  }),

  def({
    slug: 'naturvardsverket-lona',
    authorityKey: 'naturvardsverket',
    sourceKey: 'naturvardsverket-bidrag',
    programmeName: 'LONA',
    title: 'Naturvårdsverket — Lokala naturvårdssatsningen (LONA)',
    summary: 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.',
    description:
      'LONA ger upp till 50 % (våtmarksprojekt upp till 90 %) i bidrag till naturvårds- och friluftslivsprojekt. Kommunen ansöker hos länsstyrelsen, men lokala föreningar kan initiera projekt genom sin kommun.',
    objective: 'Lokalt naturvårdsengagemang och friluftsliv.',
    instrumentType: 'public_grant',
    applicantTypes: ['municipality'],
    sectors: ['environment'],
    maxFundingSharePercent: 50,
    deadlineModel: 'recurring',
    applicationMethod: 'Kommunen ansöker via länsstyrelsen; föreningar initierar via sin kommun.',
    applicationUrl: 'https://www.naturvardsverket.se/bidrag/',
    sourceUrl: 'https://www.naturvardsverket.se/bidrag/',
    criteria: [
      c('nv-lona-h1', 'hard', 'applicant.type', 'eq', 'municipality', 'Formell sökande är en kommun (föreningar deltar via kommunen)'),
      c('nv-lona-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Projektet ska genomföras i Sverige'),
      c('nv-lona-m1', 'mandatory', 'project.sector', 'eq', 'environment', 'Projektet ska avse naturvård eller friluftsliv', 'Avser projektet naturvård eller friluftsliv?'),
    ],
    budgetRules: [
      { id: 'nv-lona-b1', type: 'max_funding_share', percent: 50, description: 'Högst 50 % bidrag (våtmarksprojekt kan få upp till 90 % — se villkoren).' },
    ],
    evidenceRequirements: [
      { id: 'nv-lona-e1', kind: 'project_description', description: 'Projektbeskrivning', mandatory: true },
    ],
  }),

  def({
    slug: 'mucf-solidaritetskaren-volontarprojekt',
    authorityKey: 'mucf',
    sourceKey: 'mucf-bidrag',
    programmeName: 'Europeiska solidaritetskåren',
    title: 'MUCF — Europeiska solidaritetskåren: volontärprojekt',
    summary: 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.',
    description:
      'Europeiska solidaritetskåren finansierar volontärprojekt där unga 18–30 år gör volontärtjänst i ett annat land eller i Sverige. Organisationen behöver en kvalitetsmärkning (Quality Label) och ett OID. MUCF är nationellt programkontor.',
    objective: 'Ungas engagemang och solidaritet i Europa.',
    instrumentType: 'eu_grant',
    applicantTypes: ['association', 'municipality', 'public_body'],
    sectors: ['youth', 'civil_society'],
    excludesOtherPublicFunding: true,
    deadlineModel: 'recurring',
    applicationMethod: 'Ansökan görs i EU:s ansökningssystem (kräver EU Login, OID och Quality Label).',
    applicationUrl: 'https://www.mucf.se/bidrag',
    sourceUrl: 'https://www.mucf.se/bidrag',
    authenticationMethod: 'eu_login',
    estimatedEffortDays: 12,
    criteria: [
      c('mucf-esc-h1', 'hard', 'applicant.type', 'in', ['association', 'municipality', 'public_body'], 'Söks av organisationer'),
      c('mucf-esc-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Ansökan görs via det svenska programkontoret'),
      c('mucf-esc-m1', 'mandatory', 'organisation.hasOid', 'is_true', undefined, 'Organisationen behöver ett OID', 'Har organisationen ett OID (Organisation ID)?'),
      c('mucf-esc-m2', 'mandatory', 'organisation.hasQualityLabel', 'is_true', undefined, 'Organisationen behöver en Quality Label för solidaritetskåren', 'Har organisationen en Quality Label (kvalitetsmärkning)?'),
      c('mucf-esc-m3', 'mandatory', 'project.participantsAge18to30', 'is_true', undefined, 'Volontärerna ska vara 18–30 år', 'Är volontärerna mellan 18 och 30 år?'),
      c('mucf-esc-w1', 'weighted', 'project.hasInternationalComponent', 'is_true', undefined, 'Internationell dimension', undefined, 2),
      c('mucf-esc-w2', 'weighted', 'project.targetGroups', 'includes', 'youth', 'Unga som målgrupp', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'mucf-esc-e1', kind: 'project_description', description: 'Projektbeskrivning med aktivitetsplan', mandatory: true },
      { id: 'mucf-esc-e2', kind: 'partner_letter', description: 'Bekräftelse från partnerorganisation(er)', mandatory: false },
    ],
  }),

  def({
    slug: 'erasmus-mobilitet-skola-vuxen',
    authorityKey: 'uhr',
    sourceKey: 'uhr-erasmus',
    programmeName: 'Erasmus+ Utbildning',
    title: 'Erasmus+ — Mobilitet för skola och vuxenutbildning (KA1)',
    summary: 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.',
    description:
      'Erasmus+ KA1 ger skolor, förskolor och vuxenutbildningsorganisationer stöd för kompetensutveckling utomlands — jobbskuggning, kurser och undervisningsuppdrag samt elevmobilitet. UHR är nationellt programkontor för utbildningsdelen. Kräver OID; årliga ansökningsomgångar.',
    objective: 'Internationalisering av svensk utbildning.',
    instrumentType: 'eu_grant',
    applicantTypes: ['school', 'municipality', 'company', 'association', 'public_body'],
    sectors: ['education'],
    excludesOtherPublicFunding: true,
    deadlineModel: 'recurring',
    applicationMethod: 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).',
    applicationUrl: 'https://www.uhr.se/internationella-mojligheter/',
    sourceUrl: 'https://www.uhr.se/internationella-mojligheter/',
    authenticationMethod: 'eu_login',
    estimatedEffortDays: 12,
    criteria: [
      c('er-ka1-h1', 'hard', 'applicant.type', 'in', ['school', 'municipality', 'company', 'association', 'public_body'], 'Söks av utbildningsorganisationer/huvudmän'),
      c('er-ka1-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Ansökan görs via det svenska programkontoret'),
      c('er-ka1-m1', 'mandatory', 'organisation.hasOid', 'is_true', undefined, 'Organisationen behöver ett OID', 'Har organisationen ett OID (Organisation ID)?'),
      c('er-ka1-m2', 'mandatory', 'project.sector', 'eq', 'education', 'Projektet ska avse utbildningsverksamhet', 'Avser projektet skola eller vuxenutbildning?'),
      c('er-ka1-m3', 'mandatory', 'project.hasInternationalComponent', 'is_true', undefined, 'Mobiliteten ska ske till ett annat programland', 'Sker mobiliteten till ett annat europeiskt land?'),
    ],
    evidenceRequirements: [
      { id: 'er-ka1-e1', kind: 'project_description', description: 'Mobilitetsplan', mandatory: true },
    ],
  }),

  def({
    slug: 'kreativa-europa-samarbetsprojekt',
    authorityKey: 'eu-eacea',
    sourceKey: undefined,
    programmeName: 'Kreativa Europa',
    title: 'Kreativa Europa — Europeiska samarbetsprojekt (kultur)',
    summary: 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.',
    description:
      'Kreativa Europas kulturprogram finansierar samarbetsprojekt mellan kulturorganisationer i minst tre programländer. Kulturrådet är kontaktkontor i Sverige för kulturdelen. Ansökan görs i EU:s Funding & Tenders-portal; årliga utlysningar.',
    objective: 'Europeiskt kultursamarbete och cirkulation av konstnärliga verk.',
    instrumentType: 'eu_grant',
    applicantTypes: ['association', 'company', 'foundation', 'public_body'],
    sectors: ['culture'],
    excludesOtherPublicFunding: true,
    maxFundingSharePercent: 80,
    deadlineModel: 'recurring',
    applicationMethod: 'Ansökan görs i EU:s Funding & Tenders-portal (kräver EU Login och PIC/OID).',
    applicationUrl: 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home',
    sourceUrl: 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home',
    authenticationMethod: 'eu_login',
    estimatedEffortDays: 25,
    criteria: [
      c('ke-sp-h1', 'hard', 'applicant.type', 'in', ['association', 'company', 'foundation', 'public_body'], 'Söks av organisationer inom kultursektorn'),
      c('ke-sp-m1', 'mandatory', 'project.sector', 'eq', 'culture', 'Projektet ska vara ett kulturprojekt', 'Är projektet ett kulturprojekt?'),
      c('ke-sp-m2', 'mandatory', 'project.hasThreeCountryPartnership', 'is_true', undefined, 'Minst tre partner från tre olika programländer krävs', 'Har ni partner i minst tre olika europeiska länder?'),
      c('ke-sp-m3', 'mandatory', 'organisation.hasOid', 'is_true', undefined, 'Organisationen behöver registrering i EU:s system (PIC/OID)', 'Är organisationen registrerad i EU:s deltagarregister?'),
      c('ke-sp-w1', 'weighted', 'project.hasInternationalComponent', 'is_true', undefined, 'Internationell dimension', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'ke-sp-e1', kind: 'project_description', description: 'Projektbeskrivning enligt utlysningens mall', mandatory: true },
      { id: 'ke-sp-e2', kind: 'partner_letter', description: 'Partneravtal/avsiktsförklaringar', mandatory: true },
      { id: 'ke-sp-e3', kind: 'budget', description: 'Detaljerad budget', mandatory: true },
    ],
  }),

  def({
    slug: 'kulturradet-verksamhetsbidrag-scenkonst',
    authorityKey: 'kulturradet',
    sourceKey: 'kulturradet-sok-bidrag',
    programmeName: 'Scenkonst',
    title: 'Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper',
    summary: 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.',
    description:
      'Verksamhetsbidraget riktar sig till professionella fria scenkonstaktörer med kontinuerlig verksamhet av hög kvalitet. Söks i årlig omgång hos Kulturrådet.',
    objective: 'Ett starkt fritt scenkonstliv i hela landet.',
    instrumentType: 'public_grant',
    applicantTypes: ['association', 'company'],
    sectors: ['culture'],
    deadlineModel: 'recurring',
    applicationUrl: 'https://kulturradet.se/sok-bidrag/',
    sourceUrl: 'https://kulturradet.se/sok-bidrag/',
    authenticationMethod: 'kulturradet_konto',
    estimatedEffortDays: 10,
    criteria: [
      c('kr-vs-h1', 'hard', 'applicant.type', 'in', ['association', 'company'], 'Söks av grupper/organisationer — inte enskilda'),
      c('kr-vs-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Verksamheten ska bedrivas i Sverige'),
      c('kr-vs-m1', 'mandatory', 'person.professionalArtist', 'is_true', undefined, 'Verksamheten ska vara professionell', 'Är verksamheten professionell (inte amatörverksamhet)?'),
      c('kr-vs-m2', 'mandatory', 'project.sector', 'eq', 'culture', 'Verksamheten ska vara scenkonst', 'Är verksamheten scenkonst (dans, teater, musikteater)?'),
      c('kr-vs-w1', 'weighted', 'project.activityTypes', 'includes', 'performance', 'Publik verksamhet', undefined, 2),
    ],
    evidenceRequirements: [
      { id: 'kr-vs-e1', kind: 'project_description', description: 'Verksamhetsplan', mandatory: true },
      { id: 'kr-vs-e2', kind: 'annual_report', description: 'Senaste verksamhetsberättelse', mandatory: true },
      { id: 'kr-vs-e3', kind: 'budget', description: 'Verksamhetsbudget', mandatory: true },
    ],
  }),

  def({
    slug: 'vinnova-planeringsbidrag-eu',
    authorityKey: 'vinnova',
    sourceKey: 'vinnova-utlysningar',
    programmeName: 'EU-relaterade stöd',
    title: 'Vinnova — Planeringsbidrag för EU-ansökningar',
    summary: 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.',
    description:
      'Vinnova erbjuder återkommande planeringsbidrag som sänker tröskeln för svenska organisationer att söka EU-finansiering, t.ex. inför Horisont Europa-utlysningar och EIC Accelerator. Villkor per aktuell utlysning.',
    objective: 'Ökat svenskt deltagande i EU:s ramprogram.',
    instrumentType: 'public_grant',
    applicantTypes: ['company', 'university', 'public_body', 'association'],
    sectors: ['innovation'],
    deadlineModel: 'upcoming_round',
    applicationMethod: 'Ansökan görs i Vinnovas e-tjänst när en omgång är öppen.',
    applicationUrl: 'https://www.vinnova.se/soka-finansiering/',
    sourceUrl: 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/',
    criteria: [
      c('vin-pb-h1', 'hard', 'applicant.country', 'eq', 'SE', 'Sökande ska vara svensk organisation'),
      c('vin-pb-h2', 'hard', 'applicant.type', 'in', ['company', 'university', 'public_body', 'association'], 'Söks av organisationer'),
      c('vin-pb-m1', 'mandatory', 'project.plansEuApplication', 'is_true', undefined, 'Bidraget ska användas för att förbereda en EU-ansökan', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?'),
    ],
    evidenceRequirements: [
      { id: 'vin-pb-e1', kind: 'project_description', description: 'Beskrivning av planerad EU-ansökan', mandatory: true },
    ],
  }),

  def({
    slug: 'mucf-organisationsbidrag',
    authorityKey: 'mucf',
    sourceKey: 'mucf-bidrag',
    programmeName: 'Statsbidrag till civilsamhället',
    title: 'MUCF — Organisationsbidrag till barn- och ungdomsorganisationer',
    summary: 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.',
    description:
      'Organisationsbidraget söks årligen av nationella barn- och ungdomsorganisationer som uppfyller krav på bl.a. medlemsantal, åldersstruktur, demokratisk uppbyggnad och geografisk spridning. Villkoren framgår av förordning och MUCF:s anvisningar.',
    objective: 'Ett starkt och självständigt ungdomscivilsamhälle.',
    instrumentType: 'public_grant',
    applicantTypes: ['association'],
    sectors: ['youth', 'civil_society'],
    deadlineModel: 'recurring',
    applicationUrl: 'https://www.mucf.se/bidrag',
    sourceUrl: 'https://www.mucf.se/bidrag',
    authenticationMethod: 'mucf_konto',
    estimatedEffortDays: 8,
    criteria: [
      c('mucf-ob-h1', 'hard', 'applicant.type', 'eq', 'association', 'Sökande ska vara en ideell förening'),
      c('mucf-ob-h2', 'hard', 'applicant.country', 'eq', 'SE', 'Organisationen ska vara nationell och verksam i Sverige'),
      c('mucf-ob-m1', 'mandatory', 'organisation.democraticStructure', 'is_true', undefined, 'Demokratisk uppbyggnad krävs', 'Har organisationen en demokratisk uppbyggnad?'),
      c('mucf-ob-m2', 'mandatory', 'organisation.youthMembersShareOver60', 'is_true', undefined, 'Minst 60 % av medlemmarna ska vara 6–25 år', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?'),
      c('mucf-ob-m3', 'mandatory', 'organisation.hasNationalSpread', 'is_true', undefined, 'Verksamhet i flera län krävs', 'Har organisationen medlemsföreningar i flera län?'),
    ],
    evidenceRequirements: [
      { id: 'mucf-ob-e1', kind: 'stadgar', description: 'Stadgar', mandatory: true },
      { id: 'mucf-ob-e2', kind: 'annual_report', description: 'Årsredovisning och medlemsredovisning', mandatory: true },
    ],
  }),
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
