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
  app.log.info(`Bidragskoll.se API listening on ${config.host}:${config.port} (worker: ${enableWorker})`);

  const shutdown = async (signal: string) => {
    app.log.info(`Received ${signal}, shutting down`);
    await app.close();
    if (boss) await boss.stop();
    process.exit(0);
  };
  process.on('SIGTERM', () => void shutdown('SIGTERM'));
  process.on('SIGINT', () => void shutdown('SIGINT'));

  // Last-resort guards: log with full context; for truly unknown state, exit
  // non-zero so the orchestrator restarts a clean process.
  process.on('unhandledRejection', (reason) => {
    app.log.error({ err: reason }, 'unhandled promise rejection');
  });
  process.on('uncaughtException', (err) => {
    app.log.fatal({ err }, 'uncaught exception — exiting for clean restart');
    process.exit(1);
  });
}

main().catch((err) => {
  console.error('Fatal startup error:', err);
  process.exit(1);
});
