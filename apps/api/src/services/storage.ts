/**
 * Objektlagring bakom en smal driver-gräns. Två drivrutiner:
 *
 *  - disk (default): befintligt beteende — filer under UPLOAD_DIR, utanför
 *    webbroten, med opaka namn. Rätt för lokal utveckling, test och
 *    containerdrift med persistent volym.
 *  - supabase: Supabase Storage via service-rollnyckeln (enbart server-side —
 *    nyckeln når aldrig webbläsaren). Krävs på Vercel, där funktioner saknar
 *    beständigt filsystem. Bucketen ska vara PRIVAT; nedladdning går alltid
 *    genom API:ts tenantkontroll, aldrig via publika bucket-URL:er.
 *
 * Sökvägsmodellen (tenantId/uuid.ext) är gemensam så att en flytt mellan
 * drivrutiner är ren datakopiering.
 */
import { mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { eq, like } from 'drizzle-orm';
import { config } from '../config.ts';
import { db } from '../db/client.ts';
import { storageObjects } from '../db/schema.ts';

export interface StorageDriver {
  readonly id: 'disk' | 'supabase' | 'postgres';
  put(relPath: string, content: Buffer): Promise<void>;
  get(relPath: string): Promise<Buffer>;
  remove(relPath: string): Promise<void>;
  /** Bästa möjliga prefix-radering (GDPR-radering av en hel tenant). */
  removePrefix(prefix: string): Promise<void>;
}

const diskDriver: StorageDriver = {
  id: 'disk',
  async put(relPath, content) {
    const abs = path.join(config.uploadDir, relPath);
    await mkdir(path.dirname(abs), { recursive: true });
    await writeFile(abs, content);
  },
  async get(relPath) {
    return readFile(path.join(config.uploadDir, relPath));
  },
  async remove(relPath) {
    await rm(path.join(config.uploadDir, relPath), { force: true }).catch(() => undefined);
  },
  async removePrefix(prefix) {
    await rm(path.join(config.uploadDir, prefix), { recursive: true, force: true }).catch(() => undefined);
  },
};

/** Supabase Storage REST — inga extra beroenden, bara fetch + service-nyckel. */
function supabaseHeaders(): Record<string, string> {
  return {
    Authorization: `Bearer ${config.supabaseServiceRoleKey}`,
    apikey: config.supabaseServiceRoleKey!,
  };
}

function objectUrl(relPath: string): string {
  const encoded = relPath.split('/').map(encodeURIComponent).join('/');
  return `${config.supabaseUrl}/storage/v1/object/${config.supabaseStorageBucket}/${encoded}`;
}

const supabaseDriver: StorageDriver = {
  id: 'supabase',
  async put(relPath, content) {
    const res = await fetch(objectUrl(relPath), {
      method: 'POST',
      headers: { ...supabaseHeaders(), 'Content-Type': 'application/octet-stream', 'x-upsert': 'false' },
      body: new Uint8Array(content),
      signal: AbortSignal.timeout(30_000),
    });
    if (!res.ok) throw new Error(`storage put failed: ${res.status} ${(await res.text()).slice(0, 200)}`);
  },
  async get(relPath) {
    const res = await fetch(objectUrl(relPath), { headers: supabaseHeaders(), signal: AbortSignal.timeout(30_000) });
    if (!res.ok) throw new Error(`storage get failed: ${res.status}`);
    return Buffer.from(await res.arrayBuffer());
  },
  async remove(relPath) {
    await fetch(objectUrl(relPath), { method: 'DELETE', headers: supabaseHeaders(), signal: AbortSignal.timeout(30_000) }).catch(
      () => undefined,
    );
  },
  async removePrefix(prefix) {
    // Storage-API:t saknar prefix-delete: lista (paginerat) och radera batchvis.
    for (let page = 0; page < 100; page++) {
      const res = await fetch(`${config.supabaseUrl}/storage/v1/object/list/${config.supabaseStorageBucket}`, {
        method: 'POST',
        headers: { ...supabaseHeaders(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ prefix, limit: 100 }),
        signal: AbortSignal.timeout(30_000),
      });
      if (!res.ok) return;
      const items = (await res.json()) as { name: string }[];
      if (items.length === 0) return;
      await fetch(`${config.supabaseUrl}/storage/v1/object/${config.supabaseStorageBucket}`, {
        method: 'DELETE',
        headers: { ...supabaseHeaders(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ prefixes: items.map((i) => `${prefix}/${i.name}`) }),
        signal: AbortSignal.timeout(30_000),
      }).catch(() => undefined);
    }
  },
};

/**
 * Postgres/Neon-lagring: filerna bor INNE i databasen (bytea). Fullständigt
 * privat — ingen publik URL existerar; åtkomst går alltid genom API:ts
 * tenantkontroll. Rätt för Vercel + Neon "in-house": ingen extern objektlagring,
 * ingen serverless-diskflyktighet, inget tredjepartsberoende. Sökvägens första
 * segment (tenantId/…) lagras för index och GDPR-radering.
 */
const uuidRe = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
function tenantOf(relPath: string): string | null {
  const seg = relPath.split('/')[0] ?? '';
  return uuidRe.test(seg) ? seg : null;
}

const postgresDriver: StorageDriver = {
  id: 'postgres',
  async put(relPath, content) {
    await db
      .insert(storageObjects)
      .values({ path: relPath, tenantId: tenantOf(relPath), content, contentType: 'application/octet-stream' })
      .onConflictDoUpdate({ target: storageObjects.path, set: { content, createdAt: new Date() } });
  },
  async get(relPath) {
    const [row] = await db
      .select({ content: storageObjects.content })
      .from(storageObjects)
      .where(eq(storageObjects.path, relPath))
      .limit(1);
    if (!row) throw new Error(`storage get failed: not found ${relPath}`);
    return row.content;
  },
  async remove(relPath) {
    await db.delete(storageObjects).where(eq(storageObjects.path, relPath));
  },
  async removePrefix(prefix) {
    // Radera hela tenantens objekt (path = tenantId/uuid.ext). Prefixet är ett
    // uuid — inga LIKE-jokrar att escapa. Träffar exakt den tenantens filer.
    if (!prefix) return;
    await db.delete(storageObjects).where(like(storageObjects.path, `${prefix}%`));
  },
};

export function getStorage(): StorageDriver {
  if (config.storageDriver === 'postgres') return postgresDriver;
  if (config.storageDriver === 'supabase') {
    if (!config.supabaseUrl || !config.supabaseServiceRoleKey) {
      // Ärligt fel vid uppstart av anropet — aldrig tyst fallback till en
      // disk som inte överlever nästa funktionsanrop.
      throw new Error('STORAGE_DRIVER=supabase kräver SUPABASE_URL och SUPABASE_SERVICE_ROLE_KEY.');
    }
    return supabaseDriver;
  }
  return diskDriver;
}
