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
  const res = await api(app, user, 'POST', `/v1/projects/${projectId}/document-pack`, { pack });
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
  it('exposes prices and the template catalogue', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/document-credits`);
    const body = res.json() as { remaining: number; prices: { single: number; pack3: number; all: number }; templates: { key: string; questions: unknown[] }[] };
    expect(body.remaining).toBe(0);
    expect(body.prices).toEqual({ single: 1900, pack3: 4900, all: 7900 });
    expect(body.templates.map((t) => t.key)).toContain('behovsbeskrivning');
  });

  it('refuses generation without credits — 402, never a free document', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
      templateKey: 'behovsbeskrivning', answers: behovsAnswers,
    });
    expect(res.statusCode).toBe(402);
  });

  it('a confirmed pack purchase yields credits and a correct receipt', async () => {
    await buyPack('pack3');
    const credits = await api(app, user, 'GET', `/v1/projects/${projectId}/document-credits`);
    expect((credits.json() as { remaining: number }).remaining).toBe(3);

    // Kvittot: 49,00 = 39,20 netto + 9,80 moms; produkttexten beskriver paketet.
    const purchases = await api(app, user, 'GET', '/v1/purchases');
    const docPurchase = (purchases.json() as { purchases: { kind: string; amountMinor: number; paymentId: string }[] }).purchases
      .find((p) => p.kind === 'document_pack')!;
    expect(docPurchase.amountMinor).toBe(4900);
    const receipt = await api(app, user, 'GET', `/v1/payments/${docPurchase.paymentId}/receipt`);
    const { receipt: r, document } = receipt.json() as { receipt: { vatAmountMinor: number; amountNetMinor: number }; document: string };
    expect(r.amountNetMinor).toBe(3920);
    expect(r.vatAmountMinor).toBe(980);
    expect(document).toContain('Dokumentförberedelse — upp till 3 dokument');
  });

  it('generates a document deterministically with the opportunity as recipient', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
      templateKey: 'behovsbeskrivning', answers: behovsAnswers, opportunitySlug: 'majblomman-bidrag-barn',
    });
    expect(res.statusCode).toBe(201);
    const body = res.json() as { document: { id: string; content: string; title: string }; creditsRemaining: number };
    documentId = body.document.id;
    expect(body.creditsRemaining).toBe(2);
    expect(body.document.content).toContain('BESKRIVNING AV BEHOV');
    expect(body.document.content).toContain('Majblommans Riksförbund');
    expect(body.document.content).toContain('Vera, 9 år');
    expect(body.document.content).toContain('Slutlig bedömning görs alltid av mottagande myndighet');
  });

  it('missing required answers → 422 with the exact missing fields, no credit consumed', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
      templateKey: 'ansokan-ekonomiskt-stod', answers: { fullName: 'Anna Ek' },
    });
    expect(res.statusCode).toBe(422);
    const missing = (res.json() as { missing: { key: string }[] }).missing.map((m) => m.key);
    expect(missing).toContain('whatFor');
    const credits = await api(app, user, 'GET', `/v1/projects/${projectId}/document-credits`);
    expect((credits.json() as { remaining: number }).remaining).toBe(2);
  });

  it('downloads as a real PDF and as editable text', async () => {
    const pdf = await api(app, user, 'GET', `/v1/generated-documents/${documentId}/download?format=pdf`);
    expect(pdf.statusCode).toBe(200);
    expect(pdf.headers['content-type']).toContain('application/pdf');
    expect(pdf.rawPayload.subarray(0, 5).toString('latin1')).toBe('%PDF-');
    const text = await api(app, user, 'GET', `/v1/generated-documents/${documentId}/download?format=text`);
    expect(text.body).toContain('Vera, 9 år');
  });

  it('credits run out honestly: pack of 3 → three documents, then 402', async () => {
    for (let i = 0; i < 2; i++) {
      const res = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
        templateKey: 'sarskilda-omstandigheter',
        answers: { fullName: 'Anna Ek', circumstance: `Situation ${i}`, impact: 'Påverkar ekonomin.' },
      });
      expect(res.statusCode).toBe(201);
    }
    const fourth = await api(app, user, 'POST', `/v1/projects/${projectId}/generated-documents`, {
      templateKey: 'behovsbeskrivning', answers: behovsAnswers,
    });
    expect(fourth.statusCode).toBe(402);
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

    const pack = await api(app, other, 'POST', `/v1/projects/${pid}/document-pack`, { pack: 'single' });
    const { paymentId } = pack.json() as { paymentId: string };
    await api(app, other, 'POST', `/v1/payments/${paymentId}/mock-confirm`);

    const matches = await api(app, other, 'GET', `/v1/projects/${pid}/matches`);
    expect((matches.json() as { locked?: boolean }).locked).toBe(true); // analysen är fortfarande låst
    const credits = await api(app, other, 'GET', `/v1/projects/${pid}/document-credits`);
    expect((credits.json() as { remaining: number }).remaining).toBe(1); // men krediten finns
  });

  it('tenant isolation: foreign documents do not exist', async () => {
    const other = await registerUser(app, 'Utomstående');
    const list = await api(app, other, 'GET', `/v1/projects/${projectId}/generated-documents`);
    expect(list.statusCode).toBe(404);
    const dl = await api(app, other, 'GET', `/v1/generated-documents/${documentId}/download`);
    expect(dl.statusCode).toBe(404);
  });
});
