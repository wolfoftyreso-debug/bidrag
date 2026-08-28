/**
 * Postgres/Neon-lagringsdrivern (STORAGE_DRIVER=postgres): filerna bor i
 * databasen, fullständigt privata. Verifierar put/get/remove/removePrefix mot
 * riktig Postgres — inklusive att removePrefix bara raderar rätt tenants filer
 * (GDPR-radering) och att get på saknad nyckel felar ärligt.
 */
import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { config } from '../src/config.ts';
import { getStorage } from '../src/services/storage.ts';
import { testServer } from './helpers.ts';

let app: Awaited<ReturnType<typeof testServer>>;
const prevDriver = config.storageDriver;

beforeAll(async () => {
  app = await testServer(); // migrerar + kopplar db
  config.storageDriver = 'postgres';
});

afterAll(async () => {
  config.storageDriver = prevDriver;
  await app?.close();
});

describe('Postgres storage driver', () => {
  it('put → get returnerar exakt samma bytes', async () => {
    const storage = getStorage();
    expect(storage.id).toBe('postgres');
    const tenant = randomUUID();
    const path = `${tenant}/${randomUUID()}.pdf`;
    const content = Buffer.from('Hej — bytes med å ä ö och \x00\x01\x02', 'utf8');
    await storage.put(path, content);
    const got = await storage.get(path);
    expect(Buffer.compare(got, content)).toBe(0);
  });

  it('put på samma nyckel skriver över (upsert)', async () => {
    const storage = getStorage();
    const path = `${randomUUID()}/${randomUUID()}.txt`;
    await storage.put(path, Buffer.from('v1'));
    await storage.put(path, Buffer.from('v2'));
    expect((await storage.get(path)).toString()).toBe('v2');
  });

  it('remove tar bort objektet; get felar sedan ärligt', async () => {
    const storage = getStorage();
    const path = `${randomUUID()}/${randomUUID()}.txt`;
    await storage.put(path, Buffer.from('x'));
    await storage.remove(path);
    await expect(storage.get(path)).rejects.toThrow();
  });

  it('removePrefix raderar bara den egna tenantens filer (GDPR)', async () => {
    const storage = getStorage();
    const tenantA = randomUUID();
    const tenantB = randomUUID();
    const a1 = `${tenantA}/${randomUUID()}.pdf`;
    const a2 = `${tenantA}/${randomUUID()}.pdf`;
    const b1 = `${tenantB}/${randomUUID()}.pdf`;
    await storage.put(a1, Buffer.from('a1'));
    await storage.put(a2, Buffer.from('a2'));
    await storage.put(b1, Buffer.from('b1'));

    await storage.removePrefix(tenantA);

    await expect(storage.get(a1)).rejects.toThrow();
    await expect(storage.get(a2)).rejects.toThrow();
    expect((await storage.get(b1)).toString()).toBe('b1'); // annan tenant orörd
  });
});
