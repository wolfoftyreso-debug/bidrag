/**
 * Dokumentstudion: krediter härleds ur bekräftade köp (aldrig klientpåståenden),
 * paket i stället för styckdebitering, deterministisk generering, nedladdning
 * som PDF/text, tenant-isolering — och att dokumentköp ALDRIG låser upp analysen.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer, unlockProject, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let projectId: string;
let documentId: string;

const behovsAnswers = {
  fullName: 'Anna Ek',
  whoFor: 'barn',
  childName: 'Vera, 9 år',
  needWhat: 'Avgift och utrustning för fotboll under höstterminen.',
  needWhy: 'Utan stödet kan Vera inte fortsätta i laget tillsammans med sina klasskamrater.',
};

async function buyPack(pack: string): Promise<void> {
  const res = await api(app, user, 'POST', `/v1/projects/${projectId}/document-pack`, { pack, immediateDeliveryConsent: true });
  expect(res.statusCode).toBe(201);
  const { paymentId } = res.json() as { paymentId: string };
  const confirm = await api(app, user, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
  expect(confirm.statusCode).toBe(200);
}

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Dokumentskaparen');
  const profileRes = await api(app, user, 'POST', '/v1/profiles', {
    kind: 'person', displayName: 'D', applicantType: 'individual', country: 'SE',
    facts: { 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true },
  });
  const profile = (profileRes.json() as { profile: { id: string } }).profile;
  const projectRes = await api(app, user, 'POST', '/v1/projects', { profileId: profile.id, title: 'Dokumenttest', intent: 'test' });
  projectId = (projectRes.json() as { project: { id: string } }).project.id;
  await unlockProject(app, user, projectId);
  await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});
});

afterAll(async () => {
  await app.close();
});

describe('dokumentstudion', () => {
  it('exposes prices, the template catalogue and prefilled answers from the intake', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/document-credits`);
    const body = res.json() as {
      remaining: number;
      prices: { application: number };
      templates: { key: string; questions: unknown[] }[];
      prefill: Record<string, Record<string, unknown>>;
    };
    expect(body.remaining).toBe(0);
    expect(body.prices).toEqual({ application: 1900 });
    expect(body.templates.map((t) => t.key)).toContain('behovsbeskrivning');
    // Färdigifyllt: det systemet redan vet mappas in — inget gissas.
    expect(body.prefill['ansokan-ekonomiskt-stod']!.fullName).toBe('Dokumentskaparen');
    expect(body.prefill['ansokan-ekonomiskt-stod']!.hasChildren).toBe(true);
    expect(body.prefill['ansokan-ekonomiskt-stod']).not.toHaveProperty('address');
  });

  it('refuses generation without credits — 402, never a free document', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
      templateKey: 'behovsbeskrivning', answers: behovsAnswers,
    });
    expect(res.statusCode).toBe(402);
  });

  it('a confirmed purchase (19 kr) yields all-documents credits and a correct receipt', async () => {
    await buyPack('application');
    const credits = await api(app, user, 'GET', `/v1/projects/${projectId}/document-credits`);
    expect((credits.json() as { remaining: number }).remaining).toBe(99);

    // Kvittot: 19,00 = 15,20 netto + 3,80 moms; produkttexten beskriver paketet.
    const purchases = await api(app, user, 'GET', '/v1/purchases');
    const docPurchase = (purchases.json() as { purchases: { kind: string; amountMinor: number; paymentId: string }[] }).purchases
      .find((p) => p.kind === 'document_pack')!;
    expect(docPurchase.amountMinor).toBe(1900);
    const receipt = await api(app, user, 'GET', `/v1/payments/${docPurchase.paymentId}/receipt`);
    const { receipt: r, document } = receipt.json() as { receipt: { vatAmountMinor: number; amountNetMinor: number }; document: string };
    expect(r.amountNetMinor).toBe(1520);
    expect(r.vatAmountMinor).toBe(380);
    expect(document).toContain('Förberedd ansökan — alla dokument för en ansökan');
  });

  it('generates a document deterministically with the opportunity as recipient', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
      templateKey: 'behovsbeskrivning', answers: behovsAnswers, opportunitySlug: 'majblomman-bidrag-barn',
    });
    expect(res.statusCode).toBe(201);
    const body = res.json() as { document: { id: string; content: string; title: string }; creditsRemaining: number };
    documentId = body.document.id;
    expect(body.creditsRemaining).toBe(98);
    expect(body.document.content).toContain('BESKRIVNING AV BEHOV');
    expect(body.document.content).toContain('Majblommans Riksförbund');
    expect(body.document.content).toContain('Vera, 9 år');
    expect(body.document.content).not.toContain('Bidragskoll.se'); // sökandens handling — ingen verktygsattribution
    // Sakligt språk ⇒ ödmjukhetsprotokollet tiger (§12).
    expect((res.json() as { languageFindings: unknown[] }).languageFindings).toEqual([]);
  });

  it('missing required answers → 422 with the exact missing fields, no credit consumed', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
      templateKey: 'ansokan-ekonomiskt-stod', answers: { fullName: 'Anna Ek' },
    });
    expect(res.statusCode).toBe(422);
    const missing = (res.json() as { missing: { key: string }[] }).missing.map((m) => m.key);
    expect(missing).toContain('whatFor');
    const credits = await api(app, user, 'GET', `/v1/projects/${projectId}/document-credits`);
    expect((credits.json() as { remaining: number }).remaining).toBe(98);
  });

  it('downloads as a real PDF and as editable text', async () => {
    const pdf = await api(app, user, 'GET', `/v1/generated-documents/${documentId}/download?format=pdf`);
    expect(pdf.statusCode).toBe(200);
    expect(pdf.headers['content-type']).toContain('application/pdf');
    expect(pdf.rawPayload.subarray(0, 5).toString('latin1')).toBe('%PDF-');
    const text = await api(app, user, 'GET', `/v1/generated-documents/${documentId}/download?format=text`);
    expect(text.body).toContain('Vera, 9 år');
  });

  it('credits are consumed per document, derived from confirmed purchases only', async () => {
    for (let i = 0; i < 2; i++) {
      const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
        templateKey: 'sarskilda-omstandigheter',
        answers: {
          fullName: 'Anna Ek',
          circumstance: `Situation ${i}`,
          impact: i === 0 ? 'Vi garanterar att situationen påverkar ekonomin.' : 'Påverkar ekonomin.',
        },
      });
      expect(res.statusCode).toBe(201); // flaggan blockerar aldrig
      if (i === 0) {
        // Ödmjukhetsprotokollet §12: "garanterar" flaggas rådgivande, texten är orörd.
        const { document, languageFindings } = res.json() as {
          document: { content: string };
          languageFindings: { kind: string; term: string; fieldKey: string }[];
        };
        expect(languageFindings).toHaveLength(1);
        expect(languageFindings[0]).toMatchObject({ kind: 'SUPERLATIVE', fieldKey: 'impact' });
        expect(document.content).toContain('Vi garanterar att situationen påverkar ekonomin.');
      }
    }
    const credits = await api(app, user, 'GET', `/v1/projects/${projectId}/document-credits`);
    expect((credits.json() as { remaining: number }).remaining).toBe(96);
    const list = await api(app, user, 'GET', `/v1/projects/${projectId}/generated-documents`);
    expect((list.json() as { documents: unknown[] }).documents).toHaveLength(3);
  });

  it('a document purchase NEVER unlocks the analysis (kind separation)', async () => {
    const other = await registerUser(app, 'Separationstestaren');
    const profileRes = await api(app, other, 'POST', '/v1/profiles', {
      kind: 'person', displayName: 'S', applicantType: 'individual', country: 'SE',
      facts: { 'person.hasChildrenAtHome': true },
    });
    const profile = (profileRes.json() as { profile: { id: string } }).profile;
    const projectRes = await api(app, other, 'POST', '/v1/projects', { profileId: profile.id, title: 'Sep', intent: 'test' });
    const pid = (projectRes.json() as { project: { id: string } }).project.id;
    await api(app, other, 'POST', `/v1/projects/${pid}/matches`, {});

    const pack = await api(app, other, 'POST', `/v1/projects/${pid}/document-pack`, { pack: 'application', immediateDeliveryConsent: true });
    const { paymentId } = pack.json() as { paymentId: string };
    await api(app, other, 'POST', `/v1/payments/${paymentId}/mock-confirm`);

    const matches = await api(app, other, 'GET', `/v1/projects/${pid}/matches`);
    expect((matches.json() as { locked?: boolean }).locked).toBe(true); // analysen är fortfarande låst
    const credits = await api(app, other, 'GET', `/v1/projects/${pid}/document-credits`);
    expect((credits.json() as { remaining: number }).remaining).toBe(99); // men krediterna finns
  });

  it('tenant isolation: foreign documents do not exist', async () => {
    const other = await registerUser(app, 'Utomstående');
    const list = await api(app, other, 'GET', `/v1/projects/${projectId}/generated-documents`);
    expect(list.statusCode).toBe(404);
    const dl = await api(app, other, 'GET', `/v1/generated-documents/${documentId}/download`);
    expect(dl.statusCode).toBe(404);
  });
});
