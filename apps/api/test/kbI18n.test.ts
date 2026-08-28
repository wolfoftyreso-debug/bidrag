/**
 * I18N fas B — kunskapsbasens texter på användarens språk.
 *
 * Kontraktet som testas:
 *  1. Accept-Language med en produktspråkkod ger översatt summary i
 *     opportunitylistan och översatta intakefrågor i regelversionens kriterier.
 *  2. Svenska (eller okänt språk) ger den svenska källtexten oförändrad.
 *  3. Fallbacken är ÄRLIG: mekanismen är exakt träff på källtexten — en text
 *     utan översättning levereras på svenska i stället för att gissas.
 *  4. Officiella namn (titeln) översätts aldrig.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { KB_TRANSLATIONS } from '../src/seed/i18n/index.ts';
import { clearKbI18nCache } from '../src/services/kbI18n.ts';
import { registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;

const SLUG = 'fk-barnbidrag';

beforeAll(async () => {
  app = await testServer();
  clearKbI18nCache(); // läs den nyseedade tabellen, inte en tidigare cache
  user = await registerUser(app, 'Språktest');
});
afterAll(async () => {
  await app.close();
});

async function fetchList(acceptLanguage?: string) {
  const res = await app.inject({
    method: 'GET',
    url: '/v1/funding-opportunities?q=barnbidrag&limit=50',
    headers: { cookie: user.cookie, ...(acceptLanguage ? { 'accept-language': acceptLanguage } : {}) },
  });
  expect(res.statusCode).toBe(200);
  return (res.json() as { opportunities: { slug: string; title: string; summary: string }[] }).opportunities;
}

describe('I18N fas B: kunskapsbasens texter per Accept-Language', () => {
  it('levererar summary på somaliska när Accept-Language: so — titeln förblir svensk', async () => {
    const svRow = (await fetchList()).find((o) => o.slug === SLUG);
    expect(svRow).toBeTruthy();
    const soRow = (await fetchList('so')).find((o) => o.slug === SLUG);
    expect(soRow).toBeTruthy();
    const expected = KB_TRANSLATIONS.so[svRow!.summary];
    expect(expected).toBeTruthy();
    expect(soRow!.summary).toBe(expected);
    expect(soRow!.summary).not.toBe(svRow!.summary);
    // Officiella namn översätts aldrig — titeln är identisk.
    expect(soRow!.title).toBe(svRow!.title);
  });

  it('faller ärligt tillbaka till svenska för okänt språk', async () => {
    const svRow = (await fetchList()).find((o) => o.slug === SLUG)!;
    const deRow = (await fetchList('de')).find((o) => o.slug === SLUG)!;
    expect(deRow.summary).toBe(svRow.summary);
  });

  it('översätter kriteriernas intakefrågor i detaljvyn (ar)', async () => {
    const res = await app.inject({
      method: 'GET',
      url: `/v1/funding-opportunities/${SLUG}`,
      headers: { cookie: user.cookie, 'accept-language': 'ar' },
    });
    expect(res.statusCode).toBe(200);
    const { ruleVersion } = res.json() as {
      ruleVersion: { criteria: { intakeQuestion?: string }[] } | null;
    };
    expect(ruleVersion).toBeTruthy();
    const withQuestion = ruleVersion!.criteria.filter((c) => typeof c.intakeQuestion === 'string');
    expect(withQuestion.length).toBeGreaterThan(0);
    const arValues = new Set(Object.values(KB_TRANSLATIONS.ar));
    for (const c of withQuestion) {
      // Frågan ska vara den arabiska översättningen av någon svensk källtext.
      expect(arValues.has(c.intakeQuestion!)).toBe(true);
    }
  });

  it('parser för Accept-Language tål webbläsarlistor (uk-UA,uk;q=0.9)', async () => {
    const svRow = (await fetchList()).find((o) => o.slug === SLUG)!;
    const ukRow = (await fetchList('uk-UA,uk;q=0.9,en;q=0.8')).find((o) => o.slug === SLUG)!;
    expect(ukRow.summary).toBe(KB_TRANSLATIONS.uk[svRow.summary]);
  });
});
