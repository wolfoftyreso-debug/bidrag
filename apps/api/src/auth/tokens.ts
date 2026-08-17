import { SignJWT, jwtVerify } from 'jose';
import { createHash, randomBytes } from 'node:crypto';
import { config } from '../config.ts';

const secret = new TextEncoder().encode(config.authSecret);

export interface AccessTokenClaims {
  sub: string; // user id
  email: string;
}

export async function signAccessToken(claims: AccessTokenClaims): Promise<string> {
  return new SignJWT({ email: claims.email })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(claims.sub)
    .setIssuedAt()
    .setIssuer('bidragskoll.se')
    .setExpirationTime(`${config.accessTokenTtlSeconds}s`)
    .sign(secret);
}

export async function verifyAccessToken(token: string): Promise<AccessTokenClaims | null> {
  try {
    const { payload } = await jwtVerify(token, secret, { issuer: 'bidragskoll.se' });
    if (!payload.sub) return null;
    return { sub: payload.sub, email: String(payload.email ?? '') };
  } catch {
    return null;
  }
}

export function generateRefreshToken(): { token: string; tokenHash: string } {
  const token = randomBytes(32).toString('base64url');
  return { token, tokenHash: hashRefreshToken(token) };
}

export function hashRefreshToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

/**
 * Återställningskoder: 3 grupper à 5 tecken ur ett 30-teckensalfabet utan
 * förväxlingsbara tecken (I/L/O/U/0/1) ≈ 73 bitar entropi — utom räckhåll
 * för offlineattack mot SHA-256-hashen. Jämförelse sker alltid på
 * normaliserad form, så "k7q2m 8xj4p r9t3v" matchar "K7Q2M-8XJ4P-R9T3V".
 */
const RECOVERY_ALPHABET = 'ABCDEFGHJKMNPQRSTVWXYZ23456789';

export function normalizeRecoveryCode(input: string): string {
  return input.toUpperCase().replace(/[^A-Z2-9]/g, '');
}

export function hashRecoveryCode(input: string): string {
  return createHash('sha256').update(normalizeRecoveryCode(input)).digest('hex');
}

export function generateRecoveryCode(): { code: string; codeHash: string } {
  const bytes = randomBytes(15);
  let s = '';
  for (const b of bytes) s += RECOVERY_ALPHABET[b % RECOVERY_ALPHABET.length];
  const code = `${s.slice(0, 5)}-${s.slice(5, 10)}-${s.slice(10, 15)}`;
  return { code, codeHash: hashRecoveryCode(code) };
}
