/**
 * Nytt lösenord via återställningslänken (mailet). Token är engångs och
 * går ut efter 60 minuter; efter bytet loggas alla sessioner ut och
 * användaren loggar in på nytt.
 */
import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ApiError, post } from '../api';

export default function ResetPasswordPage() {
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
      setError('Lösenorden matchar inte.');
      return;
    }
    setBusy(true);
    try {
      await post('/v1/auth/reset-password', { token, password });
      setDone(true);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Något gick fel. Försök igen.');
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
            <h2>Lösenordet är bytt ✓</h2>
            <p className="guidance">Av säkerhetsskäl är alla tidigare inloggningar utloggade. Logga in med ditt nya lösenord.</p>
            <p><Link className="btn" to="/">Till inloggningen</Link></p>
          </>
        ) : (
          <>
            <h2>Välj nytt lösenord</h2>
            <form onSubmit={submit}>
              <label htmlFor="pw">Nytt lösenord</label>
              <input id="pw" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required minLength={10} autoComplete="new-password" />
              <p className="guidance">Minst 10 tecken.</p>
              <label htmlFor="pw2">Upprepa lösenordet</label>
              <input id="pw2" type="password" value={confirm} onChange={(e) => setConfirm(e.target.value)} required minLength={10} autoComplete="new-password" />
              {error && <div className="alert error">{error}</div>}
              <button type="submit" disabled={busy} style={{ marginTop: '1rem' }}>
                {busy ? 'Byter…' : 'Byt lösenord'}
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}
