/** Exports the curated knowledge base as JSON for the in-browser demo. */
import { writeFile } from 'node:fs/promises';
import { authorities, opportunities } from './data.ts';

const authorityName = new Map(authorities.map((a) => [a.key, a.name]));

const out = opportunities.map((o) => ({
  slug: o.slug,
  title: o.title,
  authority: authorityName.get(o.authorityKey) ?? o.authorityKey,
  summary: o.summary,
  instrumentType: o.instrumentType,
  applicantTypes: o.applicantTypes,
  maxAmountMinor: o.maxAmountMinor,
  deadlineModel: o.deadlineModel,
  closesAt: o.closesAt,
  applicationUrl: o.applicationUrl,
  applicationMethod: o.applicationMethod,
  sourceUrl: o.sourceUrl,
  estimatedEffortDays: o.estimatedEffortDays,
  criteria: o.criteria,
  evidenceRequirements: o.evidenceRequirements,
}));

await writeFile(process.argv[2] ?? '/tmp/demo-opportunities.json', JSON.stringify(out));
console.log(`Exported ${out.length} opportunities.`);
