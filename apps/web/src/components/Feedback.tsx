/**
 * Betans lärkanal (docs/reports/BETA_READINESS_2026-09-03.md B1, §45):
 * "Verkar något fel? Var detta begripligt?" — diskret, hopfälld, på
 * analysen, stödsidan och arbetsytan. Kategorin gör att faktafel kan gå
 * rakt till kuratorn. Skickar aldrig något förrän användaren trycker.
 */
import { useState } from 'react';
import { ApiError, post } from '../api';
import { useI18n, useT } from '../i18n';

const CATEGORIES = ['facts', 'language', 'navigation', 'missing', 'technical', 'other'] as const;

export function Feedback({ page, opportunitySlug }: { page: string; opportunitySlug?: string }) {
  const t = useT();
  const { locale } = useI18n();
  const [open, setOpen] = useState(false);
  const [category, setCategory] = useState<(typeof CATEGORIES)[number]>('facts');
  const [message, setMessage] = useState('');
  const [state, setState] = useState<'idle' | 'busy' | 'sent' | 'error'>('idle');

  const send = async () => {
    setState('busy');
    try {
      await post('/v1/feedback', { category, page, opportunitySlug, message, locale });
      setState('sent');
      setMessage('');
    } catch (err) {
      setState(err instanceof ApiError ? 'error' : 'error');
    }
  };

  return (
    <details
      className="feedback"
      open={open}
      onToggle={(e) => {
        const isOpen = (e.currentTarget as HTMLDetailsElement).open;
        setOpen(isOpen);
        if (isOpen) void post('/v1/events', { name: 'feedback_oppnad', props: { page } }).catch(() => {});
      }}
    >
      <summary>{t('fb.summary')}</summary>
      {state === 'sent' ? (
        <p className="alert success" role="status">{t('fb.sent')}</p>
      ) : (
        <div className="feedback-form">
          <label htmlFor={`fb-cat-${page}`}>{t('fb.category')}</label>
          <select id={`fb-cat-${page}`} value={category} onChange={(e) => setCategory(e.target.value as (typeof CATEGORIES)[number])}>
            {CATEGORIES.map((c) => <option key={c} value={c}>{t(`fb.cat.${c}` as 'fb.cat.facts')}</option>)}
          </select>
          <label htmlFor={`fb-msg-${page}`}>{t('fb.title')}</label>
          <textarea id={`fb-msg-${page}`} rows={3} maxLength={4000} value={message} onChange={(e) => setMessage(e.target.value)} placeholder={t('fb.placeholder')} />
          <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center', flexWrap: 'wrap' }}>
            <button className="secondary" disabled={state === 'busy' || message.trim().length < 3} onClick={send}>{t('fb.send')}</button>
            {state === 'error' && <span className="alert error" role="alert">{t('fb.error')}</span>}
          </div>
        </div>
      )}
    </details>
  );
}
