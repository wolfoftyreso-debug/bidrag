/**
 * I18N-runtime — fas A av flerspråksprogrammet (docs/I18N_PROGRAM.md).
 *
 * Principer:
 *  - Svenska (sv) är källspråket och default; alla nycklar definieras i sv.ts
 *    och övriga språk måste ha exakt samma nyckelmängd (tools/i18ncheck.mjs
 *    vaktar i verify — ett språk kan aldrig tyst halka efter).
 *  - Språkvalet sparas per webbläsare (localStorage) och sätter lang/dir på
 *    dokumentroten — arabiska, dari och persiska renderas höger-till-vänster.
 *  - Officiella namn på stöd och myndigheter översätts ALDRIG — användaren
 *    möter dem på svenska hos myndigheten, så de visas på svenska med
 *    förklaring på valt språk. Ansökningar/dokument förbereds på svenska.
 *  - Alla översättningar utom svenskan är AI-gjorda och etiketteras ärligt i
 *    gränssnittet tills mänsklig granskning är gjord (samma ärlighetsdoktrin
 *    som ai_curated-stämpeln i kunskapsbasen).
 */
import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { sv } from './locales/sv';
import { en } from './locales/en';
import { so } from './locales/so';
import { ar } from './locales/ar';
import { prs } from './locales/prs';
import { es } from './locales/es';
import { fr } from './locales/fr';
import { fa } from './locales/fa';
import { ru } from './locales/ru';
import { ti } from './locales/ti';
import { uk } from './locales/uk';

export type MessageKey = keyof typeof sv;
export type Locale = 'sv' | 'so' | 'ar' | 'prs' | 'en' | 'es' | 'fr' | 'fa' | 'ru' | 'ti' | 'uk';

/** Samma språkpalett som informationsverige.se — nativt namn först (så att
 * den som inte läser svenska hittar sitt språk), svenskt namn som förklaring. */
export const LOCALES: { code: Locale; native: string; swedish: string; dir: 'ltr' | 'rtl' }[] = [
  { code: 'so', native: 'Af Soomaali', swedish: 'Somaliska', dir: 'ltr' },
  { code: 'ar', native: 'العربية', swedish: 'Arabiska', dir: 'rtl' },
  { code: 'prs', native: 'دری', swedish: 'Dari', dir: 'rtl' },
  { code: 'en', native: 'English', swedish: 'Engelska', dir: 'ltr' },
  { code: 'es', native: 'Español', swedish: 'Spanska', dir: 'ltr' },
  { code: 'fr', native: 'Français', swedish: 'Franska', dir: 'ltr' },
  { code: 'fa', native: 'فارسی', swedish: 'Persiska', dir: 'rtl' },
  { code: 'ru', native: 'Русский', swedish: 'Ryska', dir: 'ltr' },
  { code: 'sv', native: 'Svenska', swedish: 'Svenska', dir: 'ltr' },
  { code: 'ti', native: 'ትግርኛ', swedish: 'Tigrinja', dir: 'ltr' },
  { code: 'uk', native: 'Українська', swedish: 'Ukrainska', dir: 'ltr' },
];

const MESSAGES: Record<Locale, Record<MessageKey, string>> = { sv, en, so, ar, prs, es, fr, fa, ru, ti, uk };

const STORAGE_KEY = 'bidrag.sprak.v1';

function loadLocale(): Locale {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved && LOCALES.some((l) => l.code === saved)) return saved as Locale;
  } catch {
    /* privat läge — kör default */
  }
  return 'sv';
}

const I18nContext = createContext<{ locale: Locale; setLocale: (l: Locale) => void }>({
  locale: 'sv',
  setLocale: () => {},
});

export function I18nProvider({ children }: { children: React.ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>(loadLocale);

  const setLocale = (l: Locale) => {
    setLocaleState(l);
    try {
      localStorage.setItem(STORAGE_KEY, l);
    } catch {
      /* ofarligt — valet gäller tills fliken stängs */
    }
  };

  // lang + dir på dokumentroten: skärmläsare läser rätt språk, RTL-språk får
  // spegelvänd layout (styles.css använder logiska egenskaper).
  useEffect(() => {
    const def = LOCALES.find((l) => l.code === locale)!;
    document.documentElement.lang = locale === 'prs' ? 'fa-AF' : locale;
    document.documentElement.dir = def.dir;
  }, [locale]);

  const value = useMemo(() => ({ locale, setLocale }), [locale]);
  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n() {
  return useContext(I18nContext);
}

/** t('nyckel') eller t('nyckel', { datum: '3 maj' }) — {platshållare} byts ut.
 * Saknad nyckel faller tillbaka till svenskan (ska aldrig hända: i18ncheck
 * fäller bygget), aldrig till en rå nyckelsträng mot användaren. */
export function useT() {
  const { locale } = useI18n();
  return useMemo(() => {
    const dict = MESSAGES[locale];
    return (key: MessageKey, vars?: Record<string, string | number>) => {
      let msg = dict[key] ?? sv[key];
      if (vars) for (const [k, v] of Object.entries(vars)) msg = msg.replaceAll(`{${k}}`, String(v));
      return msg;
    };
  }, [locale]);
}

/** Tonerna är språkoberoende — bara etiketten översätts. Källa: api.ts:s
 * ursprungliga kartor; nycklarna label.state/elig/instr.* i språkfilerna. */
const STATE_TONES: Record<string, 'info' | 'success' | 'warning' | 'danger' | ''> = {
  DISCOVERED: '', MATCHED: '', SELECTED: 'info', PREPARING: 'info', READY_FOR_REVIEW: 'info',
  READY_TO_SUBMIT: 'warning', SUBMITTING: 'warning', SUBMITTED: 'success', ACKNOWLEDGED: 'success',
  UNDER_REVIEW: 'info', ACTION_REQUIRED: 'danger', DECISION_RECEIVED: 'info', AWARDED: 'success',
  REJECTED: 'danger', WITHDRAWN: '', CLOSED: '',
};
const ELIG_TONES: Record<string, string> = { eligible: 'success', unknown: 'warning', excluded: 'danger' };

/** Lokaliserade etikettuppslag för tillstånd/behörighet/stödform/kurering.
 * Okänd nyckel → rå kod (ärligt hellre än fel etikett). */
export function useLabels() {
  const t = useT();
  return useMemo(() => {
    const has = (key: string): key is MessageKey => key in sv;
    return {
      state: (s: string) => ({ label: has(`label.state.${s}`) ? t(`label.state.${s}` as MessageKey) : s, tone: STATE_TONES[s] ?? '' }),
      elig: (s: string) => ({ label: has(`label.elig.${s}`) ? t(`label.elig.${s}` as MessageKey) : s, tone: ELIG_TONES[s] ?? '' }),
      instr: (s: string) => (has(`label.instr.${s}`) ? t(`label.instr.${s}` as MessageKey) : s),
      verif: (s: string) => (has(`label.verif.${s}`) ? t(`label.verif.${s}` as MessageKey) : s),
      msg: (s: string) => ({
        label: has(`label.msg.${s}`) ? t(`label.msg.${s}` as MessageKey) : s,
        tone: MSG_TONES[s] ?? '',
      }),
      role: (s: string) => (has(`label.role.${s}`) ? t(`label.role.${s}` as MessageKey) : s),
      doc: (s: string) => (has(`label.doc.${s}`) ? t(`label.doc.${s}` as MessageKey) : s),
    };
  }, [t]);
}

const MSG_TONES: Record<string, string> = {
  award: 'success', rejection: 'danger', decision: 'info', clarification_request: 'warning',
  missing_document: 'warning', deadline_extension: 'info', payment_notice: 'success',
  reporting_request: 'warning', acknowledgement: '', other: '',
};

/** BCP 47-tagg för datumformatering i valt språk (Intl/toLocaleDateString). */
export function useDateLocale(): string {
  const { locale } = useI18n();
  return locale === 'sv' ? 'sv-SE' : locale === 'prs' ? 'fa-AF' : locale;
}

/** Språkväljare — används på inloggningssidan och i sidomenyn. */
export function LanguagePicker({ compact }: { compact?: boolean }) {
  const { locale, setLocale } = useI18n();
  const t = useT();
  return (
    <select
      aria-label={t('nav.language')}
      value={locale}
      onChange={(e) => setLocale(e.target.value as Locale)}
      style={compact ? { fontSize: '0.85rem', marginBottom: '0.6rem' } : undefined}
    >
      {LOCALES.map((l) => (
        <option key={l.code} value={l.code}>
          {l.code === 'sv' ? l.native : `${l.native} — ${l.swedish}`}
        </option>
      ))}
    </select>
  );
}

/** Ärlighetsnotisen (I18N_PROGRAM §ärlighet): visas på varje sida när ett
 * annat språk än svenska är valt. Två delar: (1) översättningen är AI-gjord
 * och ogranskad, (2) vissa ytor är fortfarande på svenska. */
export function TranslationNotice({ alsoSwedishContent }: { alsoSwedishContent?: boolean }) {
  const { locale } = useI18n();
  const t = useT();
  if (locale === 'sv') return null;
  return (
    <div className="alert info" role="note" style={{ fontSize: '0.85rem' }}>
      {t('banner.aiTranslated')}
      {alsoSwedishContent ? ` ${t('banner.swedishContent')}` : ''}
    </div>
  );
}
