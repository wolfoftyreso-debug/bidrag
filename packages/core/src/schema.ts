/**
 * Canonical application schema engine (§15, §33).
 *
 * Application forms are data, not hand-coded pages. A schema defines fields,
 * sections, conditional visibility and validation. Canonical field keys
 * (e.g. "project.summary") let validated answers be reused across
 * applications via versioned mappings.
 */

import type { CanonicalFieldType } from './types.js';
import { evaluateCriterion, type CriterionDef } from './criteria.js';

export interface FieldCondition {
  /** Field key (within the same application) or fact path the condition reads. */
  factPath: string;
  op: CriterionDef['op'];
  expected?: CriterionDef['expected'];
}

export interface ApplicationFieldDef {
  key: string;                       // schema-local key, e.g. "b7_partner_description"
  canonicalKey?: string;             // canonical reuse key, e.g. "project.summary"
  type: CanonicalFieldType;
  label: string;                     // source-specific wording (Swedish-first)
  guidance?: string;                 // plain-language help text
  required: boolean;
  maxLength?: number;
  minLength?: number;
  min?: number;
  max?: number;
  options?: { value: string; label: string }[];
  /** Show this field only when all conditions hold. */
  visibleWhen?: FieldCondition[];
  /** Evidence kinds that must be attached to this field (attachment types). */
  acceptedEvidenceKinds?: string[];
  section: string;
}

export interface ApplicationSchemaDef {
  id: string;
  version: number;
  title: string;
  sections: { key: string; title: string; description?: string }[];
  fields: ApplicationFieldDef[];
}

export type AnswerValue = string | number | boolean | string[] | null;
export type Answers = Record<string, AnswerValue | undefined>;

export interface FieldValidationIssue {
  fieldKey: string;
  message: string;
}

export function isFieldVisible(field: ApplicationFieldDef, answers: Answers): boolean {
  if (!field.visibleWhen || field.visibleWhen.length === 0) return true;
  return field.visibleWhen.every((cond) => {
    const r = evaluateCriterion(
      {
        id: `_cond_${field.key}`,
        kind: 'hard',
        factPath: cond.factPath,
        op: cond.op,
        expected: cond.expected,
        description: '',
      },
      answers as never,
    );
    return r.outcome === 'pass';
  });
}

export function visibleFields(schema: ApplicationSchemaDef, answers: Answers): ApplicationFieldDef[] {
  return schema.fields.filter((f) => isFieldVisible(f, answers));
}

function isEmpty(v: AnswerValue | undefined): boolean {
  return v === undefined || v === null || v === '' || (Array.isArray(v) && v.length === 0);
}

export function validateAnswers(schema: ApplicationSchemaDef, answers: Answers): FieldValidationIssue[] {
  const issues: FieldValidationIssue[] = [];

  for (const field of visibleFields(schema, answers)) {
    const value = answers[field.key];

    if (field.required && isEmpty(value)) {
      issues.push({ fieldKey: field.key, message: `"${field.label}" är obligatorisk.` });
      continue;
    }
    if (isEmpty(value)) continue;

    switch (field.type) {
      case 'text':
      case 'long_text':
      case 'rich_text': {
        if (typeof value !== 'string') {
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara text.` });
          break;
        }
        if (field.maxLength !== undefined && value.length > field.maxLength)
          issues.push({ fieldKey: field.key, message: `"${field.label}" får vara högst ${field.maxLength} tecken (nu ${value.length}).` });
        if (field.minLength !== undefined && value.length < field.minLength)
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara minst ${field.minLength} tecken.` });
        break;
      }
      case 'number':
      case 'currency':
      case 'percentage': {
        if (typeof value !== 'number' || Number.isNaN(value)) {
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara ett tal.` });
          break;
        }
        if (field.min !== undefined && value < field.min)
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara minst ${field.min}.` });
        if (field.max !== undefined && value > field.max)
          issues.push({ fieldKey: field.key, message: `"${field.label}" får vara högst ${field.max}.` });
        if (field.type === 'percentage' && (value < 0 || value > 100))
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara mellan 0 och 100.` });
        break;
      }
      case 'date': {
        if (typeof value !== 'string' || Number.isNaN(Date.parse(value)))
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara ett giltigt datum.` });
        break;
      }
      case 'date_range': {
        if (!Array.isArray(value) || value.length !== 2 || value.some((d) => typeof d !== 'string' || Number.isNaN(Date.parse(d)))) {
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara ett giltigt datumintervall.` });
        } else if (Date.parse(value[0] as string) > Date.parse(value[1] as string)) {
          issues.push({ fieldKey: field.key, message: `"${field.label}": startdatum måste vara före slutdatum.` });
        }
        break;
      }
      case 'select': {
        if (field.options && !field.options.some((o) => o.value === value))
          issues.push({ fieldKey: field.key, message: `"${field.label}" har ett ogiltigt val.` });
        break;
      }
      case 'multiselect': {
        if (!Array.isArray(value)) {
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste vara en lista.` });
        } else if (field.options) {
          const valid = new Set(field.options.map((o) => o.value));
          if ((value as string[]).some((v) => !valid.has(v)))
            issues.push({ fieldKey: field.key, message: `"${field.label}" innehåller ogiltiga val.` });
        }
        break;
      }
      case 'boolean':
      case 'consent':
      case 'declaration': {
        if (typeof value !== 'boolean')
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste besvaras ja/nej.` });
        if ((field.type === 'consent' || field.type === 'declaration') && field.required && value !== true)
          issues.push({ fieldKey: field.key, message: `"${field.label}" måste bekräftas.` });
        break;
      }
      // person/organisation/partner/address/budget_line/attachment/table/signature
      // are stored as structured references and validated by their own services.
      default:
        break;
    }
  }

  return issues;
}

/**
 * Prefill answers from canonical values: for every field with a canonicalKey
 * that has a stored canonical answer, use it unless the user already answered.
 * Prefills are traceable — the caller records provenance per field.
 */
export function prefillFromCanonical(
  schema: ApplicationSchemaDef,
  existing: Answers,
  canonical: Record<string, AnswerValue>,
): { answers: Answers; prefilledKeys: string[] } {
  const answers: Answers = { ...existing };
  const prefilledKeys: string[] = [];
  for (const field of schema.fields) {
    if (!field.canonicalKey) continue;
    if (!isEmpty(answers[field.key])) continue;
    const canonicalValue = canonical[field.canonicalKey];
    if (canonicalValue !== undefined && !isEmpty(canonicalValue)) {
      answers[field.key] = canonicalValue;
      prefilledKeys.push(field.key);
    }
  }
  return { answers, prefilledKeys };
}
