/**
 * Minimal, beroendefri PDF-skrivare för textdokument. Standardtypsnittet
 * Helvetica med WinAnsi-kodning täcker svenska tecken (åäöÅÄÖé m.fl.), så
 * ingen fontinbäddning behövs. Deterministisk utdata: samma text ⇒ samma PDF.
 * Avsiktligt enkel — rubrik + löpande stycken med radbrytning och sidbrytning.
 */

const PAGE_W = 595.28; // A4 pt
const PAGE_H = 841.89;
const MARGIN = 56;
const LINE_H = 14;
const FONT_SIZE = 10.5;
const TITLE_SIZE = 15;

/** WinAnsi (CP1252)-kodning av de tecken vi använder; okända tecken ersätts. */
function winAnsi(s: string): string {
  let out = '';
  for (const ch of s) {
    const code = ch.codePointAt(0)!;
    if (code === 0x2013 || code === 0x2014) out = out + '\\226'; // – —
    else if (code === 0x2019 || code === 0x2018) out = out + "'";
    else if (code === 0x201d || code === 0x201c) out = out + '"';
    else if (code > 255) out = out + '?';
    else if (ch === '(' || ch === ')' || ch === '\\') out = out + '\\' + ch;
    else if (code > 127) out = out + '\\' + code.toString(8).padStart(3, '0');
    else out = out + ch;
  }
  return out;
}

function wrap(text: string, maxChars: number): string[] {
  const out: string[] = [];
  for (const raw of text.split('\n')) {
    if (raw.length <= maxChars) { out.push(raw); continue; }
    let line = '';
    for (const word of raw.split(' ')) {
      if ((line + ' ' + word).trim().length > maxChars) { out.push(line.trim()); line = word; }
      else line = line ? `${line} ${word}` : word;
    }
    if (line.trim()) out.push(line.trim());
  }
  return out;
}

/** Bygger en flersidig PDF av titel + textrader. */
export function textToPdf(title: string, body: string): Buffer {
  const maxChars = 92;
  const lines = wrap(body, maxChars);
  const linesPerPage = Math.floor((PAGE_H - 2 * MARGIN - 30) / LINE_H);
  const pages: string[][] = [];
  for (let i = 0; i < lines.length; i += linesPerPage) pages.push(lines.slice(i, i + linesPerPage));
  if (pages.length === 0) pages.push([]);

  const objects: string[] = [];
  const pageIds: number[] = [];
  // obj 1 = katalog, obj 2 = pages, obj 3 = font; sidor och innehåll därefter.
  const FONT_ID = 3;
  let nextId = 4;

  const contents: { id: number; stream: string }[] = [];
  for (const [pi, pageLines] of pages.entries()) {
    const contentId = nextId++;
    const pageId = nextId++;
    pageIds.push(pageId);
    let y = PAGE_H - MARGIN;
    const parts: string[] = ['BT', `/F1 ${TITLE_SIZE} Tf`, `${MARGIN} ${y.toFixed(2)} Td`];
    if (pi === 0) {
      parts.push(`(${winAnsi(title)}) Tj`);
      y -= LINE_H * 2;
      parts.push(`0 ${(-LINE_H * 2).toFixed(2)} Td`);
    }
    parts.push(`/F1 ${FONT_SIZE} Tf`);
    for (const line of pageLines) {
      parts.push(`(${winAnsi(line)}) Tj`, `0 ${-LINE_H} Td`);
    }
    parts.push('ET');
    const stream = parts.join('\n');
    contents.push({ id: contentId, stream });
    objects[pageId] = `<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${PAGE_W} ${PAGE_H}] /Resources << /Font << /F1 ${FONT_ID} 0 R >> >> /Contents ${contentId} 0 R >>`;
  }

  objects[1] = '<< /Type /Catalog /Pages 2 0 R >>';
  objects[2] = `<< /Type /Pages /Kids [${pageIds.map((id) => `${id} 0 R`).join(' ')}] /Count ${pageIds.length} >>`;
  objects[FONT_ID] = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>';

  const chunks: string[] = ['%PDF-1.4\n'];
  const offsets: number[] = [];
  let pos = chunks[0]!.length;
  const totalObjects = nextId - 1;
  for (let id = 1; id <= totalObjects; id++) {
    offsets[id] = pos;
    const content = contents.find((c) => c.id === id);
    const body_ = content
      ? `${id} 0 obj\n<< /Length ${content.stream.length} >>\nstream\n${content.stream}\nendstream\nendobj\n`
      : `${id} 0 obj\n${objects[id]}\nendobj\n`;
    chunks.push(body_);
    pos += body_.length;
  }
  const xrefPos = pos;
  let xref = `xref\n0 ${totalObjects + 1}\n0000000000 65535 f \n`;
  for (let id = 1; id <= totalObjects; id++) xref += `${String(offsets[id]).padStart(10, '0')} 00000 n \n`;
  chunks.push(xref, `trailer\n<< /Size ${totalObjects + 1} /Root 1 0 R >>\nstartxref\n${xrefPos}\n%%EOF\n`);
  return Buffer.from(chunks.join(''), 'latin1');
}
