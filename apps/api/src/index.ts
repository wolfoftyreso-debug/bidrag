import { buildServer } from './server.ts';
import { config } from './config.ts';
import { runMigrations } from './db/migrate.ts';
import { startWorker } from './jobs/worker.ts';

async function main() {
  await runMigrations();
  const app = await buildServer();

  const enableWorker = process.env.ENABLE_WORKER !== 'false';
  const boss = enableWorker ? await startWorker() : null;

  await app.listen({ port: config.port, host: config.host });
  app.log.info(`Bidrag.se API listening on ${config.host}:${config.port} (worker: ${enableWorker})`);

  const shutdown = async (signal: string) => {
    app.log.info(`Received ${signal}, shutting down`);
    await app.close();
    if (boss) await boss.stop();
    process.exit(0);
  };
  process.on('SIGTERM', () => void shutdown('SIGTERM'));
  process.on('SIGINT', () => void shutdown('SIGINT'));
}

main().catch((err) => {
  console.error('Fatal startup error:', err);
  process.exit(1);
});
