/**
 * Portabel Playwright-start. Verifieringsskripten kördes ursprungligen i en
 * sandlåda med hårdkodade sökvägar; här löses både modulen och webbläsaren
 * ut ur miljön så att skripten fungerar var som helst (lokalt, CI, Codex).
 *
 *   CHROMIUM_PATH       — explicit sökväg till en chromium/headless_shell-binär
 *   PLAYWRIGHT_BROWSERS_PATH — katalog där Playwright lagt sina webbläsare
 *   (inget satt)        — Playwright letar själv upp sin installerade webbläsare
 */
import { existsSync, readdirSync } from 'node:fs';
import { join } from 'node:path';

/** Hitta en chromium-binär utan att anta någon specifik versionskatalog. */
export function findChromium() {
  if (process.env.CHROMIUM_PATH && existsSync(process.env.CHROMIUM_PATH)) {
    return process.env.CHROMIUM_PATH;
  }
  const roots = [process.env.PLAYWRIGHT_BROWSERS_PATH, '/opt/pw-browsers'].filter(Boolean);
  for (const root of roots) {
    if (!existsSync(root)) continue;
    for (const dir of readdirSync(root)) {
      if (!dir.startsWith('chromium')) continue;
      for (const rel of ['chrome-linux/headless_shell', 'chrome-linux/chrome', 'chrome-mac/Chromium.app/Contents/MacOS/Chromium']) {
        const candidate = join(root, dir, rel);
        if (existsSync(candidate)) return candidate;
      }
    }
  }
  return null; // Playwright får själv välja sin installerade webbläsare
}

/** Starta chromium med rätt binär för miljön. */
export async function launchChromium(options = {}) {
  const { chromium } = await import('playwright');
  const executablePath = findChromium();
  return chromium.launch({ ...(executablePath ? { executablePath } : {}), ...options });
}

/** Repots rot, oavsett var skriptet ligger eller startas ifrån. */
export const repoRoot = new URL('../../', import.meta.url).pathname.replace(/\/$/, '');

/**
 * Katalog för körningsartefakter (skärmdumpar, byggd demo, körresultat).
 * Ligger utanför versionshanteringen; sätt ARTIFACTS_DIR för att styra om den.
 */
export const artifactsDir = process.env.ARTIFACTS_DIR ?? `${repoRoot}/artifacts`;
