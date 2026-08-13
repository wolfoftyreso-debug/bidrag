import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { registerUser, testServer, type TestUser } from './helpers.ts';
import { checkUpload } from '../src/services/uploads.ts';
import { isPrivateAddress } from '../src/services/ingestion.ts';

let app: FastifyInstance;
let user: TestUser;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app);
});
afterAll(async () => {
  await app.close();
});

describe('upload security (§28) — hostile input', () => {
  it('rejects disallowed content types', () => {
    expect(checkUpload('evil.exe', 'application/x-msdownload', Buffer.from('MZ')).ok).toBe(false);
    expect(checkUpload('page.html', 'text/html', Buffer.from('<html>')).ok).toBe(false);
    expect(checkUpload('script.svg', 'image/svg+xml', Buffer.from('<svg>')).ok).toBe(false);
  });

  it('rejects extension/content-type mismatch', () => {
    expect(checkUpload('cv.exe', 'application/pdf', Buffer.from('%PDF-1.4')).ok).toBe(false);
  });

  it('rejects content that fails magic-byte verification (polyglot defence)', () => {
    expect(checkUpload('cv.pdf', 'application/pdf', Buffer.from('<html>not a pdf')).ok).toBe(false);
    expect(checkUpload('img.png', 'image/png', Buffer.from('GIF89a')).ok).toBe(false);
  });

  it('accepts a valid PDF', () => {
    expect(checkUpload('cv.pdf', 'application/pdf', Buffer.from('%PDF-1.7 ...')).ok).toBe(true);
  });

  it('rejects empty files', () => {
    expect(checkUpload('tom.txt', 'text/plain', Buffer.alloc(0)).ok).toBe(false);
  });

  it('rejects malformed multipart upload over the API', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/v1/documents',
      headers: { cookie: user.cookie, 'content-type': 'application/json' },
      payload: { file: 'not-a-file' },
    });
    expect([400, 406, 415, 422]).toContain(res.statusCode);
  });
});

describe('SSRF guard (§28) — ingestion never reaches private networks', () => {
  it('blocks private and reserved ranges', () => {
    for (const addr of ['127.0.0.1', '10.0.0.5', '172.16.1.1', '192.168.1.1', '169.254.169.254', '0.0.0.0', '100.64.0.1', '224.0.0.1', '::1', 'fd00::1', 'fe80::1']) {
      expect(isPrivateAddress(addr), addr).toBe(true);
    }
  });

  it('allows public addresses', () => {
    for (const addr of ['93.184.216.34', '151.101.1.69', '8.8.8.8']) {
      expect(isPrivateAddress(addr), addr).toBe(false);
    }
  });
});
