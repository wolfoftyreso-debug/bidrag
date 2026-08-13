/**
 * Field-level encryption for sensitive external identifiers (AES-256-GCM).
 * Format: v1$iv$ciphertext$tag (base64url).
 */
import { createCipheriv, createDecipheriv, randomBytes } from 'node:crypto';
import { config } from '../config.ts';

function key(): Buffer {
  const k = Buffer.from(config.fieldEncryptionKey, 'hex');
  if (k.length !== 32) throw new Error('FIELD_ENCRYPTION_KEY must be 32 bytes hex');
  return k;
}

export function encryptField(plaintext: string): string {
  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', key(), iv);
  const ct = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
  const tag = cipher.getAuthTag();
  return `v1$${iv.toString('base64url')}$${ct.toString('base64url')}$${tag.toString('base64url')}`;
}

export function decryptField(stored: string): string {
  const [v, ivB64, ctB64, tagB64] = stored.split('$');
  if (v !== 'v1' || !ivB64 || !ctB64 || !tagB64) throw new Error('Invalid encrypted field format');
  const decipher = createDecipheriv('aes-256-gcm', key(), Buffer.from(ivB64, 'base64url'));
  decipher.setAuthTag(Buffer.from(tagB64, 'base64url'));
  return Buffer.concat([decipher.update(Buffer.from(ctB64, 'base64url')), decipher.final()]).toString('utf8');
}
