import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    env: {
      NODE_ENV: 'test',
      DATABASE_URL: process.env.TEST_DATABASE_URL ?? 'postgres://postgres@localhost:5432/bidrag_test',
      AUTH_SECRET: 'test-secret-test-secret-test-secret-1234',
      FIELD_ENCRYPTION_KEY: '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f',
      UPLOAD_DIR: './test-uploads',
      PAYMENTS_MOCK_ENABLED: 'true',
      CRON_SECRET: 'test-cron-secret',
      // E-postkanal "konfigurerad" (leveransen misslyckas ofarligt) så att
      // återställningsflödet kan testas; fail-closed testas genom att
      // variabeln tas bort i det testet (emailConfigured läser lazily).
      SMTP_URL: 'smtp://127.0.0.1:1',
      LOG_LEVEL: 'silent',
    },
    fileParallelism: false,
    testTimeout: 30000,
    hookTimeout: 60000,
  },
});
