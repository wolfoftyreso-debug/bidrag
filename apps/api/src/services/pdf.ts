/**
 * Minimal, beroendefri PDF-skrivare för textdokument. Standardtypsnitten
 * Helvetica/Helvetica-Bold med WinAnsi-kodning täcker svenska tecken
 * (åäöÅÄÖé m.fl.), så ingen fontinbäddning behövs. Deterministisk utdata:
 * samma text ⇒ samma PDF.
 *
 * Typografin är breddbaserad, inte teckenräknad: varje rad mäts mot
 * Helveticas faktiska teckenbredder (AFM), så en rad med breda versaler
 * bryts tidigare än en med smala gemener och ingen rad kan rinna utanför
 * marginalen. Överlånga ord (referensnummer, webbadresser) hårdbryts på
 * breddgränsen i stället för att sticka ut.
 *
 * Dokumentstruktur känns igen ur texten (samma konvention som
 * renderDocument i @bidrag/core): VERSALRUBRIKER sätts i fetstil med luft
 * omkring, metaraderna (Avser/Till/Datum) tonas ned, ett ensamt "—" blir
 * en avdelarlinje och raderna efter den (disclaimern) sätts små och grå.
 * Varje sida får sidfoten "Sida X av Y".
 */

const PAGE_W = 595.28; // A4 pt
const PAGE_H = 841.89;
const MARGIN = 56;
const LINE_H = 14;
const FONT_SIZE = 10.5;
const TITLE_SIZE = 16;
const HEADING_SIZE = 11;
const SMALL_SIZE = 8.5;
const CONTENT_W = PAGE_W - 2 * MARGIN;

/** WinAnsi (CP1252)-kodning av de tecken vi använder; okända tecken ersätts. */
function winAnsi(s: string): string {
  let out = '';
  for (const ch of s) {
    const code = ch.codePointAt(0)!;
    if (code === 0x2013 || code === 0x2014) out = out + '\\226'; // – —
    else if (code === 0x2019 || code === 0x2018) out = out + "'";
    else if (code === 0x201d || code === 0x201c) out = out + '"';
    else if (code === 0x201a) out = out + ',';
    else if (code === 0x201e) out = out + '"';
    else if (code === 0x2212) out = out + '-'; // matematiskt minus → bindestreck
    else if (code === 0x2026) out = out + '...';
    else if (code === 0x2022) out = out + '\\267'; // punktlista → mittpunkt
    else if (code > 255) out = out + '?';
    else if (ch === '(' || ch === ')' || ch === '\\') out = out + '\\' + ch;
    else if (code > 127) out = out + '\\' + code.toString(8).padStart(3, '0');
    else out = out + ch;
  }
  return out;
}

/**
 * Teckenbredder (tusendelar av teckenstorleken) ur Helveticas AFM-metrik.
 * Latin-1-tecken utanför tabellen ärver basbokstavens bredd (å→a, Ä→A …).
 */
const W_REG: Record<string, number> = {
  ' ': 278, '!': 278, '"': 355, '#': 556, '$': 556, '%': 889, '&': 667, "'": 191,
  '(': 333, ')': 333, '*': 389, '+': 584, ',': 278, '-': 333, '.': 278, '/': 278,
  '0': 556, '1': 556, '2': 556, '3': 556, '4': 556, '5': 556, '6': 556, '7': 556, '8': 556, '9': 556,
  ':': 278, ';': 278, '<': 584, '=': 584, '>': 584, '?': 556, '@': 1015,
  A: 667, B: 667, C: 722, D: 722, E: 667, F: 611, G: 778, H: 722, I: 278, J: 500, K: 667, L: 556,
  M: 833, N: 722, O: 778, P: 667, Q: 778, R: 722, S: 667, T: 611, U: 722, V: 667, W: 944, X: 667, Y: 667, Z: 611,
  '[': 278, '\\': 278, ']': 278, '^': 469, _: 556, '`': 333,
  a: 556, b: 556, c: 500, d: 556, e: 556, f: 278, g: 556, h: 556, i: 222, j: 222, k: 500, l: 222,
  m: 833, n: 556, o: 556, p: 556, q: 556, r: 333, s: 500, t: 278, u: 556, v: 500, w: 722, x: 500, y: 500, z: 500,
  '{': 334, '|': 260, '}': 334, '~': 584, '–': 556, '—': 556, '\u00A0': 278,
};
const W_BOLD: Record<string, number> = {
  ' ': 278, '!': 333, '"': 474, '#': 556, '$': 556, '%': 889, '&': 722, "'": 238,
  '(': 333, ')': 333, '*': 389, '+': 584, ',': 278, '-': 333, '.': 278, '/': 278,
  '0': 556, '1': 556, '2': 556, '3': 556, '4': 556, '5': 556, '6': 556, '7': 556, '8': 556, '9': 556,
  ':': 333, ';': 333, '<': 584, '=': 584, '>': 584, '?': 611, '@': 975,
  A: 722, B: 722, C: 722, D: 722, E: 667, F: 611, G: 778, H: 722, I: 278, J: 556, K: 722, L: 611,
  M: 833, N: 722, O: 778, P: 667, Q: 778, R: 722, S: 667, T: 611, U: 722, V: 667, W: 944, X: 667, Y: 667, Z: 611,
  '[': 333, '\\': 278, ']': 333, '^': 584, _: 556, '`': 333,
  a: 556, b: 611, c: 556, d: 611, e: 556, f: 333, g: 611, h: 611, i: 278, j: 278, k: 556, l: 278,
  m: 889, n: 611, o: 611, p: 611, q: 611, r: 389, s: 556, t: 333, u: 611, v: 556, w: 778, x: 556, y: 556, z: 500,
  '{': 389, '|': 280, '}': 389, '~': 584, '–': 556, '—': 556, '\u00A0': 278,
};
/** Accenttecken → basbokstav för breddslagning. */
const BASE: Record<string, string> = {
  å: 'a', ä: 'a', à: 'a', á: 'a', â: 'a', ã: 'a', ö: 'o', ò: 'o', ó: 'o', ô: 'o', õ: 'o', ø: 'o',
  é: 'e', è: 'e', ê: 'e', ë: 'e', í: 'i', ì: 'i', î: 'i', ï: 'i', ú: 'u', ù: 'u', û: 'u', ü: 'u',
  ý: 'y', ÿ: 'y', ñ: 'n', ç: 'c', æ: 'a', ß: 's',
  Å: 'A', Ä: 'A', À: 'A', Á: 'A', Â: 'A', Ã: 'A', Ö: 'O', Ò: 'O', Ó: 'O', Ô: 'O', Õ: 'O', Ø: 'O',
  É: 'E', È: 'E', Ê: 'E', Ë: 'E', Í: 'I', Ì: 'I', Î: 'I', Ï: 'I', Ú: 'U', Ù: 'U', Û: 'U', Ü: 'U',
  Ý: 'Y', Ñ: 'N', Ç: 'C', Æ: 'A',
};

function charWidth(ch: string, bold: boolean): number {
  const table = bold ? W_BOLD : W_REG;
  const direct = table[ch];
  if (direct !== undefined) return direct;
  const base = BASE[ch];
  if (base) return table[base] ?? 556;
  return 556;
}

/** Textbredd i pt vid given storlek. Exporterad för tester. */
export function textWidth(s: string, size: number, bold = false): number {
  let units = 0;
  for (const ch of s) units += charWidth(ch, bold);
  return (units * size) / 1000;
}

/** Hårdbryter ett ord som ensamt är bredare än maxbredden. */
function breakLongWord(word: string, size: number, bold: boolean, maxW: number): string[] {
  const parts: string[] = [];
  let cur = '';
  for (const ch of word) {
    if (textWidth(cur + ch, size, bold) > maxW && cur) {
      parts.push(cur);
      cur = ch;
    } else {
      cur += ch;
    }
  }
  if (cur) parts.push(cur);
  return parts;
}

/** Breddbaserad radbrytning på ordgränser; överlånga ord hårdbryts. Exporterad för tester. */
export function wrapToWidth(text: string, size: number, bold: boolean, maxW: number): string[] {
  const out: string[] = [];
  for (const raw of text.split('\n')) {
    if (textWidth(raw, size, bold) <= maxW) { out.push(raw); continue; }
    let line = '';
    for (const word of raw.split(' ')) {
      const candidate = line ? `${line} ${word}` : word;
      if (textWidth(candidate, size, bold) <= maxW) { line = candidate; continue; }
      if (line) out.push(line);
      if (textWidth(word, size, bold) <= maxW) { line = word; continue; }
      const parts = breakLongWord(word, size, bold, maxW);
      for (const p of parts.slice(0, -1)) out.push(p);
      line = parts[parts.length - 1] ?? '';
    }
    if (line) out.push(line);
  }
  return out.length > 0 ? out : [''];
}

interface Line {
  text: string;
  size: number;
  bold: boolean;
  /** 0 = svart; 0.45 = nedtonad. */
  gray: number;
  /** Extra luft (pt) före raden. */
  spaceBefore: number;
  /** Radhöjd (pt). */
  height: number;
  /** Ritas som horisontell linje i stället för text. */
  rule?: boolean;
  /** Rubrik — får inte bli ensam sist på en sida. */
  heading?: boolean;
}

/** En rad är rubrik om den är kort, innehåller bokstäver och helt saknar gemener. */
function isHeadingLine(s: string): boolean {
  const t = s.trim();
  if (!t || t.length > 64) return false;
  if (!/[A-ZÅÄÖÉ]/.test(t)) return false;
  return t === t.toUpperCase();
}

function layout(title: string, body: string): Line[] {
  const lines: Line[] = [];
  for (const piece of wrapToWidth(title, TITLE_SIZE, true, CONTENT_W)) {
    lines.push({ text: piece, size: TITLE_SIZE, bold: true, gray: 0, spaceBefore: 0, height: TITLE_SIZE + 5 });
  }
  lines.push({ text: '', size: FONT_SIZE, bold: false, gray: 0, spaceBefore: 0, height: 6, rule: true });

  const rawLines = body.split('\n');
  let start = 0;
  // renderDocument inleder texten med titeln i versaler — den är redan satt.
  if (rawLines[0]?.trim().toUpperCase() === title.trim().toUpperCase()) start = 1;

  let afterDivider = false;
  let prevBlank = false;
  let firstContent = true;
  for (let i = start; i < rawLines.length; i++) {
    const raw = rawLines[i]!;
    const t = raw.trim();
    if (t === '') { prevBlank = true; continue; }

    if (t === '—' || t === '-' || /^[—-]{2,}$/.test(t)) {
      lines.push({ text: '', size: FONT_SIZE, bold: false, gray: 0.6, spaceBefore: 8, height: 8, rule: true });
      afterDivider = true;
      prevBlank = false;
      continue;
    }

    const meta = !afterDivider && /^(Avser|Till|Datum):\s/.test(t);
    const heading = !afterDivider && !meta && isHeadingLine(t);
    const size = afterDivider ? SMALL_SIZE : heading ? HEADING_SIZE : FONT_SIZE;
    const bold = heading;
    const gray = afterDivider || meta ? 0.45 : 0;
    const height = afterDivider ? SMALL_SIZE + 3 : heading ? HEADING_SIZE + 5 : LINE_H;
    let spaceBefore = 0;
    if (!firstContent) {
      if (heading) spaceBefore = 10;
      else if (prevBlank) spaceBefore = 6;
    }

    const wrapped = wrapToWidth(t, size, bold, CONTENT_W);
    for (const [wi, piece] of wrapped.entries()) {
      lines.push({ text: piece, size, bold, gray, spaceBefore: wi === 0 ? spaceBefore : 0, height, heading });
    }
    prevBlank = false;
    firstContent = false;
  }
  return lines;
}

/** Delar upp raderna i sidor; en rubrik lämnas aldrig ensam sist på en sida. */
function paginate(lines: Line[]): Line[][] {
  const limit = PAGE_H - 2 * MARGIN - 18; // sidfoten bor i nederkantsmarginalen
  const pages: Line[][] = [];
  let page: Line[] = [];
  let used = 0;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]!;
    const h = line.height + (page.length === 0 ? 0 : line.spaceBefore);
    if (used + h > limit && page.length > 0) {
      // Rubrikföräldralösa: flytta en avslutande rubrik till nästa sida.
      const carried: Line[] = [];
      if (page.length > 1 && page[page.length - 1]!.heading) carried.unshift(page.pop()!);
      pages.push(page);
      page = [...carried];
      used = carried.reduce((s, l) => s + l.height, 0);
    }
    page.push(line);
    used += line.height + (page.length === 1 ? 0 : line.spaceBefore);
  }
  if (page.length > 0 || pages.length === 0) pages.push(page);

  // Änkekontroll: 1–2 rader får aldrig bilda en egen sista sida. De ryms i
  // praktiken alltid i nederkantsmarginalen på föregående sida (sidfoten
  // ligger på fast höjd och krockar inte), och en nästan tom sida är ett
  // sämre dokument än några punkter kortare marginal.
  if (pages.length > 1) {
    const last = pages[pages.length - 1]!;
    const lastHeight = last.reduce((s, l, i) => s + l.height + (i === 0 ? 0 : l.spaceBefore), 0);
    if (last.length <= 2 && lastHeight <= 2 * LINE_H + 10) {
      pages[pages.length - 2] = [...pages[pages.length - 2]!, ...last];
      pages.pop();
    }
  }
  return pages;
}

/** Bygger en flersidig PDF av titel + strukturerad brödtext. */
export function textToPdf(title: string, body: string): Buffer {
  const pages = paginate(layout(title, body));

  const objects: string[] = [];
  const pageIds: number[] = [];
  // obj 1 = katalog, obj 2 = pages, obj 3+4 = typsnitt; sidor och innehåll därefter.
  const FONT_REG = 3;
  const FONT_BOLD = 4;
  let nextId = 5;

  const contents: { id: number; stream: string }[] = [];
  for (const [pi, pageLines] of pages.entries()) {
    const contentId = nextId++;
    const pageId = nextId++;
    pageIds.push(pageId);
    const parts: string[] = [];
    let y = PAGE_H - MARGIN;
    for (const [li, line] of pageLines.entries()) {
      if (li > 0) y -= line.spaceBefore;
      y -= line.height;
      if (line.rule) {
        const ry = (y + line.height / 2).toFixed(2);
        parts.push('q', '0.75 w', '0.65 G', `${MARGIN} ${ry} m ${(PAGE_W - MARGIN).toFixed(2)} ${ry} l S`, 'Q');
        continue;
      }
      if (line.text === '') continue;
      parts.push(
        'BT',
        `/${line.bold ? 'F2' : 'F1'} ${line.size} Tf`,
        `${line.gray.toFixed(2)} g`,
        `1 0 0 1 ${MARGIN} ${y.toFixed(2)} Tm`,
        `(${winAnsi(line.text)}) Tj`,
        'ET',
      );
    }
    // Sidfot: "Sida X av Y" högerställd i nederkantsmarginalen.
    const footer = `Sida ${pi + 1} av ${pages.length}`;
    const fw = textWidth(footer, SMALL_SIZE, false);
    parts.push(
      'BT',
      `/F1 ${SMALL_SIZE} Tf`,
      '0.45 g',
      `1 0 0 1 ${(PAGE_W - MARGIN - fw).toFixed(2)} ${(MARGIN - 24).toFixed(2)} Tm`,
      `(${winAnsi(footer)}) Tj`,
      'ET',
    );
    const stream = parts.join('\n');
    contents.push({ id: contentId, stream });
    objects[pageId] = `<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${PAGE_W} ${PAGE_H}] /Resources << /Font << /F1 ${FONT_REG} 0 R /F2 ${FONT_BOLD} 0 R >> >> /Contents ${contentId} 0 R >>`;
  }

  objects[1] = '<< /Type /Catalog /Pages 2 0 R >>';
  objects[2] = `<< /Type /Pages /Kids [${pageIds.map((id) => `${id} 0 R`).join(' ')}] /Count ${pageIds.length} >>`;
  objects[FONT_REG] = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>';
  objects[FONT_BOLD] = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>';

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
