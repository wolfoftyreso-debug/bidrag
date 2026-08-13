import { describe, expect, it } from 'vitest';
import { validateAnswers, visibleFields, prefillFromCanonical, type ApplicationSchemaDef } from '../src/schema.js';

const schema: ApplicationSchemaDef = {
  id: 'test-schema',
  version: 1,
  title: 'Testansökan',
  sections: [{ key: 'a', title: 'Projektet' }],
  fields: [
    { key: 'summary', canonicalKey: 'project.summary', type: 'long_text', label: 'Projektbeskrivning', required: true, maxLength: 2000, section: 'a' },
    { key: 'has_partner', type: 'boolean', label: 'Har ni en internationell partner?', required: true, section: 'a' },
    {
      key: 'partner_name',
      type: 'text',
      label: 'Partnerns namn',
      required: true,
      section: 'a',
      visibleWhen: [{ factPath: 'has_partner', op: 'is_true' }],
    },
    { key: 'amount', type: 'currency', label: 'Sökt belopp', required: true, min: 1, section: 'a' },
    { key: 'declaration', type: 'declaration', label: 'Jag intygar att uppgifterna är riktiga', required: true, section: 'a' },
  ],
};

describe('application schema engine', () => {
  it('hides conditional fields until the condition holds (question B7 pattern)', () => {
    expect(visibleFields(schema, {}).map((f) => f.key)).not.toContain('partner_name');
    expect(visibleFields(schema, { has_partner: true }).map((f) => f.key)).toContain('partner_name');
  });

  it('does not require hidden fields', () => {
    const issues = validateAnswers(schema, {
      summary: 'Ett dansutbyte med Jamaica.',
      has_partner: false,
      amount: 40000,
      declaration: true,
    });
    expect(issues).toEqual([]);
  });

  it('requires visible conditional fields', () => {
    const issues = validateAnswers(schema, {
      summary: 'x',
      has_partner: true,
      amount: 40000,
      declaration: true,
    });
    expect(issues.map((i) => i.fieldKey)).toEqual(['partner_name']);
  });

  it('enforces max length and declaration confirmation', () => {
    const issues = validateAnswers(schema, {
      summary: 'y'.repeat(2001),
      has_partner: false,
      amount: 40000,
      declaration: false,
    });
    expect(issues.some((i) => i.fieldKey === 'summary' && i.message.includes('2000'))).toBe(true);
    expect(issues.some((i) => i.fieldKey === 'declaration')).toBe(true);
  });

  it('prefills from canonical answers without overwriting user input', () => {
    const { answers, prefilledKeys } = prefillFromCanonical(
      schema,
      { amount: 1234 },
      { 'project.summary': 'Kanoniskt svar om dansutbytet.' },
    );
    expect(answers['summary']).toBe('Kanoniskt svar om dansutbytet.');
    expect(prefilledKeys).toEqual(['summary']);
    expect(answers['amount']).toBe(1234);

    const second = prefillFromCanonical(schema, { summary: 'Eget svar' }, { 'project.summary': 'Kanoniskt' });
    expect(second.answers['summary']).toBe('Eget svar');
    expect(second.prefilledKeys).toEqual([]);
  });
});
