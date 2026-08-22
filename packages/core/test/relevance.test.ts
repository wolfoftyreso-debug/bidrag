/**
 * Relevanspolicyn (F-RELEVANS): spårdetektering och synlighetsfiltret.
 * Regressionen som vaktas särskilt: personspårets sektordeklaration
 * (project.sector = 'personal') får ALDRIG flippa spåret till 'project' —
 * det var exakt så personstöden försvann ur webbens rapport en gång.
 */
import { describe, expect, it } from 'vitest';
import {
  BUSINESS_RELEVANT_SLUGS,
  PERSONAL_SECTOR,
  detectTrack,
  businessRelevantSlugs,
  relevantForTrack,
} from '../src/relevance.js';

const rows = [
  { slug: 'kommun-forsorjningsstod', instrumentType: 'social_benefit', eligibilityStatus: 'unknown' },
  { slug: 'csn-studiemedel', instrumentType: 'educational_support', eligibilityStatus: 'eligible' },
  { slug: 'leader-lokalt-ledd-utveckling', instrumentType: 'eu_grant', eligibilityStatus: 'unknown' },
  { slug: 'kulturradet-projektbidrag-musik', instrumentType: 'project_grant', eligibilityStatus: 'eligible' },
  { slug: 'af-stod-start-naringsverksamhet', instrumentType: 'public_grant', eligibilityStatus: 'unknown' },
];

describe('detectTrack', () => {
  it('sektordeklarationen "personal" ger personspåret — trots att nyckeln är project.*', () => {
    expect(detectTrack({ 'project.sector': PERSONAL_SECTOR, 'person.lowHouseholdIncome': true })).toBe('personal');
    expect(detectTrack({ 'project.sector': PERSONAL_SECTOR })).toBe('personal');
  });
  it('riktiga projektfakta ger projektspåret', () => {
    expect(detectTrack({ 'project.sector': 'culture' })).toBe('project');
    expect(detectTrack({ 'organisation.democraticStructure': true })).toBe('project');
    expect(detectTrack({ 'project.sector': 'culture', 'project.activityTypes': ['project'] })).toBe('project');
  });
  it('egenföretagaren i personspåret: personfakta + verksamhetssektor ger personspåret', () => {
    expect(detectTrack({ 'person.selfEmployed': true, 'project.sector': 'agriculture' })).toBe('personal');
    expect(detectTrack({ 'person.selfEmployed': true, 'project.sector': 'other' })).toBe('personal');
    // Följdfrågesvar på project.*-fakta får inte flippa spåret.
    expect(detectTrack({
      'person.selfEmployed': true, 'project.sector': 'agriculture', 'project.startingOrTakingOverFarm': true,
    })).toBe('personal');
  });
  it('personfakta ger personspåret; tomt ger all', () => {
    expect(detectTrack({ 'person.registeredUnemployed': true })).toBe('personal');
    expect(detectTrack({})).toBe('all');
  });
});

describe('relevantForTrack', () => {
  it('personspåret: personliga instrument + allt eligible — men inte projektbrus som "behöver utredas"', () => {
    const visible = relevantForTrack(rows, 'personal').map((r) => r.slug);
    expect(visible).toContain('kommun-forsorjningsstod');
    expect(visible).toContain('csn-studiemedel');
    expect(visible).toContain('kulturradet-projektbidrag-musik'); // eligible visas alltid
    expect(visible).not.toContain('leader-lokalt-ledd-utveckling'); // eu_grant unknown = brus
    expect(visible).not.toContain('af-stod-start-naringsverksamhet');
  });
  it('egenföretagare i personspåret ser de utlovade företagsstöden', () => {
    const visible = relevantForTrack(rows, 'personal', { selfEmployed: true }).map((r) => r.slug);
    expect(visible).toContain('af-stod-start-naringsverksamhet');
    expect(BUSINESS_RELEVANT_SLUGS.has('af-stod-start-naringsverksamhet')).toBe(true);
  });
  it('F-BRANSCH: deklarerad sektor öppnar branschstöden — utan deklaration förblir basmängden', () => {
    const rows = [
      { slug: 'kulturradet-projektbidrag-musik', instrumentType: 'project_grant', eligibilityStatus: 'unknown' },
      { slug: 'naturvardsverket-klimatklivet', instrumentType: 'public_grant', eligibilityStatus: 'unknown' },
      { slug: 'af-stod-start-naringsverksamhet', instrumentType: 'public_grant', eligibilityStatus: 'unknown' },
    ];
    const culture = relevantForTrack(rows, 'personal', { selfEmployed: true, sector: 'culture' }).map((r) => r.slug);
    expect(culture).toContain('kulturradet-projektbidrag-musik');
    expect(culture).not.toContain('naturvardsverket-klimatklivet');
    const other = relevantForTrack(rows, 'personal', { selfEmployed: true, sector: 'other' }).map((r) => r.slug);
    expect(other).toEqual(['af-stod-start-naringsverksamhet']);
    expect(businessRelevantSlugs('environment').has('naturvardsverket-klimatklivet')).toBe(true);
    expect(businessRelevantSlugs(undefined)).toBe(BUSINESS_RELEVANT_SLUGS);
  });

  it('projektspåret: döljer personliga instrument som inte är eligible', () => {
    const visible = relevantForTrack(rows, 'project').map((r) => r.slug);
    expect(visible).not.toContain('kommun-forsorjningsstod');
    expect(visible).toContain('csn-studiemedel'); // eligible visas alltid
    expect(visible).toContain('leader-lokalt-ledd-utveckling');
  });
  it('all: inget filtreras', () => {
    expect(relevantForTrack(rows, 'all')).toHaveLength(rows.length);
  });
});
