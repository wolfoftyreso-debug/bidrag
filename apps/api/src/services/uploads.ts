/**
 * Upload handling (§28): uploaded documents are hostile input.
 *  - content-type + extension allowlist
 *  - magic-byte verification for common types
 *  - size limits (enforced by @fastify/multipart)
 *  - sha256 for integrity/dedup
 *  - files stored outside the web root with opaque names
 *  - malware scanning via ClamAV when deployed; otherwise files are marked
 *    'scan_unavailable' — visible, never silently assumed clean.
 */
import { createHash } from 'node:crypto';
import net from 'node:net';
import { config } from '../config.ts';

export const ALLOWED_UPLOADS: Record<string, { extensions: string[]; magic?: (buf: Buffer) => boolean }> = {
  'application/pdf': { extensions: ['.pdf'], magic: (b) => b.subarray(0, 5).toString('latin1') === '%PDF-' },
  'image/png': { extensions: ['.png'], magic: (b) => b.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) },
  'image/jpeg': { extensions: ['.jpg', '.jpeg'], magic: (b) => b[0] === 0xff && b[1] === 0xd8 },
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document': {
    extensions: ['.docx'],
    magic: (b) => b[0] === 0x50 && b[1] === 0x4b, // zip container
  },
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': {
    extensions: ['.xlsx'],
    magic: (b) => b[0] === 0x50 && b[1] === 0x4b,
  },
  'text/plain': { extensions: ['.txt'] },
};

export interface UploadCheckResult {
  ok: boolean;
  reason?: string;
}

export function checkUpload(filename: string, contentType: string, content: Buffer): UploadCheckResult {
  const rule = ALLOWED_UPLOADS[contentType];
  if (!rule) return { ok: false, reason: `Filtypen ${contentType} tillåts inte.` };
  const lower = filename.toLowerCase();
  if (!rule.extensions.some((ext) => lower.endsWith(ext))) {
    return { ok: false, reason: 'Filändelsen matchar inte filtypen.' };
  }
  if (rule.magic && !rule.magic(content)) {
    return { ok: false, reason: 'Filens innehåll matchar inte den angivna filtypen.' };
  }
  if (content.length === 0) return { ok: false, reason: 'Filen är tom.' };
  return { ok: true };
}

export function sha256(content: Buffer): string {
  return createHash('sha256').update(content).digest('hex');
}

/**
 * ClamAV INSTREAM scan when CLAMAV_ADDRESS is configured.
 * Returns 'clean' | 'blocked' | 'scan_unavailable'.
 */
export async function scanBuffer(content: Buffer): Promise<'clean' | 'blocked' | 'scan_unavailable'> {
  if (!config.clamavAddress) return 'scan_unavailable';
  const [host, portStr] = config.clamavAddress.split(':');
  const port = Number(portStr ?? 3310);
  return new Promise((resolve) => {
    const socket = net.connect({ host, port, timeout: 15_000 });
    let response = '';
    socket.on('connect', () => {
      socket.write('zINSTREAM\0');
      const size = Buffer.alloc(4);
      size.writeUInt32BE(content.length);
      socket.write(size);
      socket.write(content);
      socket.write(Buffer.from([0, 0, 0, 0]));
    });
    socket.on('data', (d) => {
      response += d.toString();
    });
    socket.on('end', () => {
      if (response.includes('OK')) resolve('clean');
      else if (response.includes('FOUND')) resolve('blocked');
      else resolve('scan_unavailable');
    });
    socket.on('error', () => resolve('scan_unavailable'));
    socket.on('timeout', () => {
      socket.destroy();
      resolve('scan_unavailable');
    });
  });
}
