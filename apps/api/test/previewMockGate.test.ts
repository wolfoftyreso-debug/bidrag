/**
 * Miljögrinden för betalningsmocken (docs/LIMITATIONS.md §10): mock tillåts i
 * utveckling/test och i Vercel Preview, aldrig i skarp produktion. Grinden
 * ligger SAMLAD i config.paymentsMockEnabled — regressionen som testet vaktar
 * mot är en extra NODE_ENV-vakt i adaptern som neutraliserar preview-
 * undantaget (så att preview-köp gav 503 trots korrekt satt flagga).
 *
 * config läser miljön vid modul-load, därför provas varje läge i en egen
 * nodprocess i stället för att mutera process.env i testprocessen.
 */
import { execFileSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import { describe, expect, it } from 'vitest';

const providersUrl = pathToFileURL(
  new URL('../src/services/paymentProviders.ts', import.meta.url).pathname,
).href;

function activeProviderIn(env: Record<string, string>): string {
  const script = `
    const { activeProvider } = await import(${JSON.stringify(providersUrl)});
    process.stdout.write(activeProvider()?.id ?? 'none');
  `;
  return execFileSync(
    process.execPath,
    ['--experimental-strip-types', '--no-warnings', '--input-type=module', '-e', script],
    {
      env: {
        PATH: process.env.PATH ?? '',
        NODE_OPTIONS: '',
        // Grundkrav så att config kan konstrueras i produktionsläge.
        DATABASE_URL: 'postgres://postgres@localhost:5432/unused',
        AUTH_SECRET: 'preview-gate-test-secret-32-chars!!',
        FIELD_ENCRYPTION_KEY: '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f',
        ...env,
      },
      encoding: 'utf8',
    },
  ).trim();
}

describe('betalningsmockens miljögrind (alla fem lägen)', () => {
  it('utveckling + flagga: mock är aktiv provider', () => {
    expect(activeProviderIn({ NODE_ENV: 'development', PAYMENTS_MOCK_ENABLED: 'true' })).toBe('mock');
  });

  it('utveckling utan flagga: ingen provider', () => {
    expect(activeProviderIn({ NODE_ENV: 'development' })).toBe('none');
  });

  it('skarp produktion + flagga (inget VERCEL_ENV): aldrig mock', () => {
    expect(activeProviderIn({ NODE_ENV: 'production', PAYMENTS_MOCK_ENABLED: 'true' })).toBe('none');
  });

  it('Vercel Preview (NODE_ENV=production, VERCEL_ENV=preview) + flagga: mock fungerar', () => {
    expect(
      activeProviderIn({ NODE_ENV: 'production', VERCEL_ENV: 'preview', PAYMENTS_MOCK_ENABLED: 'true' }),
    ).toBe('mock');
  });

  it('Vercel Production (VERCEL_ENV=production) + flagga: aldrig mock', () => {
    expect(
      activeProviderIn({ NODE_ENV: 'production', VERCEL_ENV: 'production', PAYMENTS_MOCK_ENABLED: 'true' }),
    ).toBe('none');
  });
});
