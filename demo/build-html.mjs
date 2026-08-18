import { readFileSync, writeFileSync } from 'node:fs';
const bundle = readFileSync(process.argv[2], 'utf8');
const css = readFileSync(new URL('./demo.css', import.meta.url), 'utf8');
const html = `<title>Bidragskoll.se Demo</title>
<style>${css}</style>
<div id="root"></div>
<script>${bundle.replace(/<\/script>/gi, '<\\/script>')}</script>
`;
writeFileSync(new URL('./demo.html', import.meta.url), html);
console.log('demo.html:', html.length, 'bytes');
