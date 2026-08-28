import { useState } from 'react';
import { ApiError, post } from '../api';
import { LanguagePicker, TranslationNotice, useT } from '../i18n';

export default function LoginPage({ onLogin }: { onLogin: () => Promise<void> }) {
  const t = useT();
  const [mode, setMode] = useState<'login' | 'register' | 'forgot' | 'code'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [recoveryCode, setRecoveryCode] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setInfo(null);
    setBusy(true);
    try {
      if (mode === 'forgot') {
        await post('/v1/auth/request-password-reset', { email });
        setInfo(t('login.info.resetSent'));
        return;
      }
      if (mode === 'code') {
        await post('/v1/auth/recover-with-code', { email, code: recoveryCode, password });
        setMode('login');
        setPassword('');
        setRecoveryCode('');
        setInfo(t('login.info.passwordChanged'));
        return;
      }
      if (mode === 'register') {
        await post('/v1/auth/register', { email, password, displayName });
      } else {
        await post('/v1/auth/login', { email, password });
      }
      await onLogin();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('login.error.generic'));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="auth-page">
      <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '0.6rem' }}>
        <LanguagePicker compact />
      </div>
      <h1 style={{ color: 'var(--primary-dark)' }}>Bidragskoll.se</h1>
      <p className="meta-line" style={{ marginBottom: '1.5rem' }}>{t('login.tagline')}</p>
      <TranslationNotice />
      <div className="card">
        <h2>{mode === 'login' ? t('login.title.login') : mode === 'register' ? t('login.title.register') : t('login.title.reset')}</h2>
        {mode === 'forgot' && <p className="guidance">{t('login.forgotGuidance')}</p>}
        {mode === 'code' && <p className="guidance">{t('login.codeGuidance')}</p>}
        <form onSubmit={submit}>
          {mode === 'register' && (
            <>
              <label htmlFor="name">{t('login.name')}</label>
              <input id="name" value={displayName} onChange={(e) => setDisplayName(e.target.value)} required maxLength={120} />
            </>
          )}
          <label htmlFor="email">{t('login.email')}</label>
          <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
          {mode === 'code' && (
            <>
              <label htmlFor="recovery-code">{t('login.recoveryCode')}</label>
              <input
                id="recovery-code"
                value={recoveryCode}
                onChange={(e) => setRecoveryCode(e.target.value)}
                required
                minLength={10}
                maxLength={40}
                placeholder={t('login.recoveryPlaceholder')}
                autoComplete="one-time-code"
                style={{ letterSpacing: '0.05em' }}
              />
            </>
          )}
          {mode !== 'forgot' && (
            <>
              <label htmlFor="password">{mode === 'code' ? t('login.newPassword') : t('login.password')}</label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                minLength={10}
                autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
              />
            </>
          )}
          {(mode === 'register' || mode === 'code') && <p className="guidance">{t('login.minChars')}</p>}
          {error && <div className="alert error">{error}</div>}
          {info && <div className="alert success">{info}</div>}
          <div style={{ marginTop: '1.1rem', display: 'flex', gap: '0.75rem', alignItems: 'center', flexWrap: 'wrap' }}>
            <button type="submit" disabled={busy}>
              {mode === 'login' ? t('login.submit.login') : mode === 'register' ? t('login.submit.register') : mode === 'code' ? t('login.submit.code') : t('login.submit.forgot')}
            </button>
            <button type="button" className="subtle" onClick={() => { setMode(mode === 'login' ? 'register' : 'login'); setError(null); setInfo(null); }}>
              {mode === 'login' ? t('login.switch.toRegister') : t('login.switch.toLogin')}
            </button>
            {mode === 'login' && (
              <button type="button" className="subtle" onClick={() => { setMode('forgot'); setError(null); setInfo(null); }}>
                {t('login.forgot')}
              </button>
            )}
            {mode === 'forgot' && (
              <button type="button" className="subtle" onClick={() => { setMode('code'); setError(null); setInfo(null); }}>
                {t('login.haveCode')}
              </button>
            )}
            {mode === 'code' && (
              <button type="button" className="subtle" onClick={() => { setMode('forgot'); setError(null); setInfo(null); }}>
                {t('login.sendLinkInstead')}
              </button>
            )}
          </div>
        </form>
      </div>
      <p className="meta-line">{t('login.privacyNote')}</p>
    </div>
  );
}
