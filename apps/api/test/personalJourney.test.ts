/**
 * Rights-investigation journey: "Jag har svårt att få ekonomin att gå ihop."
 * A single parent with low income and housing costs should surface housing
 * allowance and maintenance support as likely entitlements, child-free youth
 * benefits and pensioner benefits as excluded, and försörjningsstöd as
 * needing investigation — never phrased as a decision.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let projectId: string;

interface MatchRow {
  slug: string;
  eligibilityStatus: string;
  instrumentType: string;
  score: number;
  result: { missingFacts: { question: string }[]; confidence: string };
}

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Ensamstående förälder');

  // Situation: ensamstående förälder, 29–65 år, arbetslös, inkomst 15–25 tkr,
  // betalar hyra, separerad, andra föräldern betalar inte underhåll.
  const profileRes = await api(app, user, 'POST', '/v1/profiles', {
    kind: 'person',
    displayName: 'Min situation',
    applicantType: 'individual',
    country: 'SE',
    municipality: 'Norrköping',
    facts: {
      'person.householdType': 'alone',
      'person.hasChildrenAtHome': true,
      'person.separatedParent': true,
      'person.otherParentNotPaying': true,
      'person.ageBand': '29-65',
      'person.ageUnder29': false,
      'person.age66Plus': false,
      'person.employmentStatus': 'unemployed',
      'person.receivesPension': false,
      'person.monthlyIncomeBand': '15-25',
      'person.lowHouseholdIncome': true,
      'person.paysHousingCost': true,
      'person.housingCostMonthly': 8500,
    },
  });
  const profile = (profileRes.json() as { profile: { id: string } }).profile;

  const projectRes = await api(app, user, 'POST', '/v1/projects', {
    profileId: profile.id,
    title: 'Min ekonomiska situation',
    intent: 'Jag har svårt att få ekonomin att gå ihop.',
  });
  projectId = (projectRes.json() as { project: { id: string } }).project.id;
  await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});
});

afterAll(async () => {
  await app.close();
});

function bySlug(matches: MatchRow[], slug: string): MatchRow {
  const m = matches.find((x) => x.slug === slug);
  expect(m, slug).toBeDefined();
  return m!;
}

describe('personlig rättighetsutredning', () => {
  let matches: MatchRow[];

  it('surfaces likely entitlements from the situation alone', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    matches = (res.json() as { matches: MatchRow[] }).matches;

    // Bostadsbidrag för barnfamiljer: alla kända krav uppfyllda.
    const bostadsbidrag = bySlug(matches, 'fk-bostadsbidrag-barnfamiljer');
    expect(bostadsbidrag.eligibilityStatus).toBe('eligible');
    expect(bostadsbidrag.result.confidence).toBe('high');

    // Underhållsstöd: separerad, barnet bor hos föräldern, underhåll uteblir.
    const underhall = bySlug(matches, 'fk-underhallsstod');
    expect(underhall.eligibilityStatus).toBe('eligible');
  });

  it('excludes benefits whose hard/mandatory conditions fail', () => {
    // 29–65 år → varken ungdoms- eller pensionärsstöd.
    expect(bySlug(matches, 'fk-bostadsbidrag-unga').eligibilityStatus).toBe('excluded');
    expect(bySlug(matches, 'pm-aldreforsorjningsstod').eligibilityStatus).toBe('excluded');
    expect(bySlug(matches, 'fk-aktivitetsersattning').eligibilityStatus).toBe('excluded');
  });

  it('marks försörjningsstöd as needing investigation with follow-up questions', () => {
    // Inkomst 15–25 tkr: inte uppenbart otillräcklig — okänt, med frågor.
    const fs = bySlug(matches, 'kommun-forsorjningsstod');
    expect(fs.eligibilityStatus).toBe('unknown');
    expect(fs.result.missingFacts.length).toBeGreaterThan(0);
  });

  it('keeps personal benefits separate from project grants (instrument types)', () => {
    for (const slug of ['fk-bostadsbidrag-barnfamiljer', 'fk-underhallsstod', 'kommun-forsorjningsstod']) {
      expect(['social_benefit', 'educational_support']).toContain(bySlug(matches, slug).instrumentType);
    }
    // Projektbidrag är korrekt uteslutna eller irrelevanta för det personliga
    // spåret — t.ex. kräver Kulturrådets resebidrag konstnärlig yrkesverksamhet.
    const kultur = bySlug(matches, 'kulturradet-internationellt-resebidrag-musik');
    expect(kultur.eligibilityStatus).not.toBe('eligible');
  });

  it('answering a follow-up upgrades the assessment deterministically', async () => {
    // Användaren svarar på försörjningsstödets frågor via faktauppdatering.
    await api(app, user, 'PATCH', `/v1/projects/${projectId}`, {
      facts: {
        'person.incomeInsufficientForBasicNeeds': true,
        'person.limitedSavings': true,
      },
    });
    await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const updated = (res.json() as { matches: MatchRow[] }).matches;
    expect(bySlug(updated, 'kommun-forsorjningsstod').eligibilityStatus).toBe('eligible');
  });
});
