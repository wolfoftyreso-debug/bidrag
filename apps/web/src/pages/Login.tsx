import { useState } from 'react';
import { ApiError, post } from '../api';

export default function LoginPage({ onLogin }: { onLogin: () => Promise<void> }) {
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setBusy(true);
    try {
      if (mode === 'register') {
        await post('/v1/auth/register', { email, password, displayName });
      } else {
        await post('/v1/auth/login', { email, password });
      }
      await onLogin();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Något gick fel. Försök igen.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="auth-page">
      <h1 style={{ color: 'var(--primary-dark)' }}>Bidrag.se</h1>
      <p className="meta-line" style={{ marginBottom: '1.5rem' }}>
        Berätta vad du behöver hjälp med — vi tar reda på vad du kan ha rätt till, och hjälper dig hela vägen till ansökan.
      </p>
      <div className="card">
        <h2>{mode === 'login' ? 'Logga in' : 'Skapa konto'}</h2>
        <form onSubmit={submit}>
          {mode === 'register' && (
            <>
              <label htmlFor="name">Namn</label>
              <input id="name" value={displayName} onChange={(e) => setDisplayName(e.target.value)} required maxLength={120} />
            </>
          )}
          <label htmlFor="email">E-post</label>
          <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
          <label htmlFor="password">Lösenord</label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            minLength={10}
            autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
          />
          {mode === 'register' && <p className="guidance">Minst 10 tecken.</p>}
          {error && <div className="alert error">{error}</div>}
          <div style={{ marginTop: '1.1rem', display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
            <button type="submit" disabled={busy}>
              {mode === 'login' ? 'Logga in' : 'Skapa konto'}
            </button>
            <button type="button" className="subtle" onClick={() => setMode(mode === 'login' ? 'register' : 'login')}>
              {mode === 'login' ? 'Ny här? Skapa konto' : 'Har du redan konto? Logga in'}
            </button>
          </div>
        </form>
      </div>
      <p className="meta-line">
        Vi frågar aldrig efter personnummer för att visa vad du kan söka, och vi lagrar aldrig inloggningsuppgifter till
        myndigheters e-tjänster.
      </p>
    </div>
  );
}
