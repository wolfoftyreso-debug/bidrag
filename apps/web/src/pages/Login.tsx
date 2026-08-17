import { useState } from 'react';
import { ApiError, post } from '../api';

export default function LoginPage({ onLogin }: { onLogin: () => Promise<void> }) {
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
        setInfo('Om adressen finns hos oss har vi skickat en återställningslänk. Kolla din inkorg (länken gäller i 60 minuter).');
        return;
      }
      if (mode === 'code') {
        await post('/v1/auth/recover-with-code', { email, code: recoveryCode, password });
        setMode('login');
        setPassword('');
        setRecoveryCode('');
        setInfo('Lösenordet är bytt och koden är förbrukad. Logga in med ditt nya lösenord.');
        return;
      }
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
      <h1 style={{ color: 'var(--primary-dark)' }}>Bidragskoll.se</h1>
      <p className="meta-line" style={{ marginBottom: '1.5rem' }}>
        Berätta vad du behöver hjälp med — vi tar reda på vad du kan ha rätt till, och hjälper dig hela vägen till ansökan.
      </p>
      <div className="card">
        <h2>{mode === 'login' ? 'Logga in' : mode === 'register' ? 'Skapa konto' : 'Återställ lösenord'}</h2>
        {mode === 'forgot' && (
          <p className="guidance">Ange din e-postadress så skickar vi en länk för att välja ett nytt lösenord.</p>
        )}
        {mode === 'code' && (
          <p className="guidance">
            Ange en av dina sparade återställningskoder och välj ett nytt lösenord. Koden fungerar bara en gång.
          </p>
        )}
        <form onSubmit={submit}>
          {mode === 'register' && (
            <>
              <label htmlFor="name">Namn</label>
              <input id="name" value={displayName} onChange={(e) => setDisplayName(e.target.value)} required maxLength={120} />
            </>
          )}
          <label htmlFor="email">E-post</label>
          <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="email" />
          {mode === 'code' && (
            <>
              <label htmlFor="recovery-code">Återställningskod</label>
              <input
                id="recovery-code"
                value={recoveryCode}
                onChange={(e) => setRecoveryCode(e.target.value)}
                required
                minLength={10}
                maxLength={40}
                placeholder="t.ex. K7Q2M-8XJ4P-R9T3V"
                autoComplete="one-time-code"
                style={{ letterSpacing: '0.05em' }}
              />
            </>
          )}
          {mode !== 'forgot' && (
            <>
              <label htmlFor="password">{mode === 'code' ? 'Nytt lösenord' : 'Lösenord'}</label>
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
          {(mode === 'register' || mode === 'code') && <p className="guidance">Minst 10 tecken.</p>}
          {error && <div className="alert error">{error}</div>}
          {info && <div className="alert success">{info}</div>}
          <div style={{ marginTop: '1.1rem', display: 'flex', gap: '0.75rem', alignItems: 'center', flexWrap: 'wrap' }}>
            <button type="submit" disabled={busy}>
              {mode === 'login' ? 'Logga in' : mode === 'register' ? 'Skapa konto' : mode === 'code' ? 'Byt lösenord' : 'Skicka återställningslänk'}
            </button>
            <button type="button" className="subtle" onClick={() => { setMode(mode === 'login' ? 'register' : 'login'); setError(null); setInfo(null); }}>
              {mode === 'login' ? 'Ny här? Skapa konto' : 'Har du redan konto? Logga in'}
            </button>
            {mode === 'login' && (
              <button type="button" className="subtle" onClick={() => { setMode('forgot'); setError(null); setInfo(null); }}>
                Glömt lösenord?
              </button>
            )}
            {mode === 'forgot' && (
              <button type="button" className="subtle" onClick={() => { setMode('code'); setError(null); setInfo(null); }}>
                Har du en återställningskod?
              </button>
            )}
            {mode === 'code' && (
              <button type="button" className="subtle" onClick={() => { setMode('forgot'); setError(null); setInfo(null); }}>
                Skicka länk via e-post i stället
              </button>
            )}
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
