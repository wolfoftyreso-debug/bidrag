/**
 * Nytt lösenord via återställningslänken (mailet). Token är engångs och
 * går ut efter 60 minuter; efter bytet loggas alla sessioner ut och
 * användaren loggar in på nytt.
 */
import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ApiError, post } from '../api';
import { useT } from '../i18n';

export default function ResetPasswordPage() {
  const t = useT();
  const { token } = useParams();
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const [busy, setBusy] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (password !== confirm) {
      setError(t('rp.mismatch'));
      return;
    }
    setBusy(true);
    try {
      await post('/v1/auth/reset-password', { token, password });
      setDone(true);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('login.error.generic'));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="auth-page">
      <h1 style={{ color: 'var(--primary-dark)' }}>Bidragskoll.se</h1>
      <div className="card">
        {done ? (
          <>
            <h2>{t('rp.doneTitle')}</h2>
            <p className="guidance">{t('rp.doneBody')}</p>
            <p><Link className="btn" to="/">{t('rp.toLogin')}</Link></p>
          </>
        ) : (
          <>
            <h2>{t('rp.title')}</h2>
            <form onSubmit={submit}>
              <label htmlFor="pw">{t('login.newPassword')}</label>
              <input id="pw" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required minLength={10} autoComplete="new-password" />
              <p className="guidance">{t('login.minChars')}</p>
              <label htmlFor="pw2">{t('rp.repeat')}</label>
              <input id="pw2" type="password" value={confirm} onChange={(e) => setConfirm(e.target.value)} required minLength={10} autoComplete="new-password" />
              {error && <div className="alert error">{error}</div>}
              <button type="submit" disabled={busy} style={{ marginTop: '1rem' }}>
                {busy ? t('rp.changing') : t('login.submit.code')}
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}
