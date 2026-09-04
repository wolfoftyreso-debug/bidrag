/**
 * Webbläsardelen av behörighetskontrollen (bundlas av tools/genseo.mjs via
 * esbuild → /assets/precheck.js). Progressiv förbättring: utan JS står den
 * statiska frågelistan kvar i sidan; med JS ersätts den av en fråga i taget
 * (produktprincip: en fråga per skärm), sedan resultat per stöd ur cores
 * riktiga motor. Inget sparas, inget skickas — allt räknas lokalt.
 *
 * Språk: docs/LANGUAGE_GUIDE.md — "ser ut att kunna", aldrig "berättigad";
 * beslutsraden och gratisvägen på resultatvyn.
 */
import { evaluatePrecheck } from './logic.mjs';

const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

function mount(root, data) {
  const answers = {};
  let index = 0;
  let showResults = false;

  const el = (html) => {
    root.innerHTML = html;
    root.querySelector('[data-focus]')?.focus();
  };

  function questionView() {
    const q = data.questions[index];
    const n = index + 1;
    const m = data.questions.length;
    const answered = answers[q.id];
    const birth = q.type === 'birthYear';
    return `
<p class="eyebrow">Fråga ${n} av ${m}</p>
<h3 class="precheck-q" data-focus tabindex="-1">${esc(q.text)}</h3>
${birth
    ? `<form class="precheck-form" data-act="year"><label class="precheck-label" for="precheck-year">Födelseår</label>
<input id="precheck-year" class="precheck-input" type="number" inputmode="numeric" min="1900" max="${new Date().getFullYear()}" placeholder="t.ex. 1979" value="${answered ?? ''}" required>
<div class="precheck-row"><button type="submit" class="precheck-btn primary">Nästa</button><button type="button" class="precheck-btn" data-act="skip">Vet inte</button></div>
<p class="precheck-note">Året avgör vilka åldersgränser som gäller — vi behöver inget personnummer.</p></form>`
    : `<div class="precheck-row">
<button type="button" class="precheck-btn primary${answered === true ? ' valt' : ''}" data-act="yes">Ja</button>
<button type="button" class="precheck-btn primary${answered === false ? ' valt' : ''}" data-act="no">Nej</button>
<button type="button" class="precheck-btn" data-act="skip">Vet inte</button></div>`}
<div class="precheck-nav">${index > 0 ? '<button type="button" class="precheck-link" data-act="back">← Tillbaka</button>' : ''}<span class="precheck-note">Inget sparas eller skickas.</span></div>`;
  }

  function resultsView() {
    const results = evaluatePrecheck(data, answers);
    const label = { ja: 'ser ut att kunna gälla dig', utred: 'behöver utredas', nej: 'uppfyller inte de publicerade kraven' };
    const cls = { ja: 'ja', utred: 'utred', nej: 'nej' };
    const cards = results.map((r) => `
<div class="precheck-res ${cls[r.status]}">
<div class="precheck-res-head"><strong>${esc(r.title)}</strong><span class="precheck-badge ${cls[r.status]}">${label[r.status]}</span></div>
${r.reasons.length ? `<ul class="precheck-skal">${r.reasons.map((e) => `<li class="${e.outcome}">${e.outcome === 'pass' ? '✓' : '✗'} ${esc(e.description)}</li>`).join('')}</ul>` : ''}
${r.status === 'utred' && r.missing.length ? `<p class="precheck-note">För att veta säkert: ${r.missing.map(esc).join(' · ')}</p>` : ''}
${r.preconditions.length ? `<p class="precheck-note">Förutsätter: ${r.preconditions.map(esc).join(' · ')}.</p>` : ''}
<p class="precheck-links"><a href="${esc(r.applicationUrl || r.sourceUrl)}" rel="noopener">Ansök själv hos ${esc(r.authority)} — gratis ↗</a> · <a href="/bidrag/${esc(r.slug)}/">Se stödet</a></p>
</div>`).join('');
    const svar = data.questions.map((q, i) => {
      const v = answers[q.id];
      const txt = v === undefined ? 'inget svar' : q.type === 'birthYear' ? String(v) : v ? 'Ja' : 'Nej';
      return `<li>${esc(q.text)} — <strong>${esc(txt)}</strong> <button type="button" class="precheck-link" data-act="goto" data-i="${i}">Ändra</button></li>`;
    }).join('');
    return `
<p class="eyebrow">Utifrån dina svar</p>
<h3 class="precheck-q" data-focus tabindex="-1">Det här ser du ut att kunna ha rätt till</h3>
${cards}
<div class="honest">Det här är en bedömning utifrån publicerade villkor, inte ett beslut. Slutligt beslut fattas alltid av myndigheten. Att ansöka själv direkt hos myndigheten är alltid gratis.</div>
<p><a class="bigcta" href="/">Gå igenom hela din situation — gratis</a></p>
<details class="precheck-svar"><summary>Dina svar (${data.questions.length}) — granska eller ändra</summary><ol>${svar}</ol></details>
<p><button type="button" class="precheck-link" data-act="restart">Börja om</button></p>`;
  }

  function render() {
    el(showResults || index >= data.questions.length ? resultsView() : questionView());
  }

  root.addEventListener('click', (ev) => {
    const b = ev.target.closest('[data-act]');
    if (!b || b.tagName === 'FORM') return;
    const q = data.questions[index];
    switch (b.dataset.act) {
      case 'yes': answers[q.id] = true; index += 1; break;
      case 'no': answers[q.id] = false; index += 1; break;
      case 'skip': answers[q.id] = undefined; index += 1; break;
      case 'back': index = Math.max(0, index - 1); showResults = false; break;
      case 'goto': index = Number(b.dataset.i); showResults = false; break;
      case 'restart': for (const k of Object.keys(answers)) delete answers[k]; index = 0; showResults = false; break;
      default: return;
    }
    if (index >= data.questions.length) showResults = true;
    render();
  });
  root.addEventListener('submit', (ev) => {
    const f = ev.target.closest('form[data-act="year"]');
    if (!f) return;
    ev.preventDefault();
    const y = Number(f.querySelector('input').value);
    if (!Number.isFinite(y) || y < 1900 || y > new Date().getFullYear()) return;
    answers[data.questions[index].id] = y;
    index += 1;
    if (index >= data.questions.length) showResults = true;
    render();
  });

  render();
}

const root = document.getElementById('precheck');
const dataEl = document.getElementById('precheck-data');
if (root && dataEl) {
  try {
    const data = JSON.parse(dataEl.textContent);
    if (data.questions?.length) {
      root.classList.add('precheck-live');
      mount(root, data);
    }
  } catch {
    /* fallbacken (statisk frågelista) står kvar */
  }
}
