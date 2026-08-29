/** Exports the curated knowledge base as JSON for the in-browser demo. */
import { writeFile } from 'node:fs/promises';
import { applicationSchemaDefs, authorities, opportunities } from './data.ts';

const authorityName = new Map(authorities.map((a) => [a.key, a.name]));
// Stödets EGET ansökningsschema följer med (F-SPECIFIK): demons förberedelse
// ska visa myndighetens riktiga fält och vägledning, inte en generisk mall.
const schemaBySlug = new Map(applicationSchemaDefs.map((s) => [s.opportunitySlug, s.def]));

const out = opportunities.map((o) => ({
  slug: o.slug,
  title: o.title,
  authority: authorityName.get(o.authorityKey) ?? o.authorityKey,
  summary: o.summary,
  instrumentType: o.instrumentType,
  applicantTypes: o.applicantTypes,
  maxAmountMinor: o.maxAmountMinor,
  amountNote: o.amountNote ?? null,
  amountSourceUrl: o.amountSourceUrl ?? null,
  deadlineModel: o.deadlineModel,
  closesAt: o.closesAt,
  applicationUrl: o.applicationUrl,
  applicationMethod: o.applicationMethod,
  sourceUrl: o.sourceUrl,
  estimatedEffortDays: o.estimatedEffortDays,
  criteria: o.criteria,
  evidenceRequirements: o.evidenceRequirements,
  applicationSchema: schemaBySlug.get(o.slug) ?? null,
}));

await writeFile(process.argv[2] ?? '/tmp/demo-opportunities.json', JSON.stringify(out));
console.log(`Exported ${out.length} opportunities.`);
