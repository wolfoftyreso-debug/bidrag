/**
 * Konto & data (GDPR-självservice, §29): exportera all data eller radera
 * kontot permanent. Radering kräver skriftlig bekräftelse och ägar-roll.
 */
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiError, api, post } from '../api';
import { useSession } from '../App';

export default function AccountPage() {
  const { session, reload } = useSession();
  const navigate = useNavigate();
  const [confirmText, setConfirmText] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const isOwner = session?.activeTenant.role === 'owner';

  const erase = async () => {
    setBusy(true);
    setError(null);
    try {
      await api('DELETE', '/v1/tenant', { confirm: confirmText });
      await post('/v1/auth/logout');
      await reload();
      navigate('/');
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Raderingen misslyckades.');
      setBusy(false);
    }
  };

  return (
    <div style={{ maxWidth: 640 }}>
      <h1>Konto och data</h1>
      <p className="meta-line">{session?.user.email}</p>

      <div className="card">
        <h2>Hämta ut din data</h2>
        <p>
          Ladda ner allt vi har om dig — profil, projekt, matchningar, ansökningar, korrespondens och dokumentlista — som en
          JSON-fil. Kvitton och krypterade identifierare listas via revisionsspåret.
        </p>
        <p><a className="btn secondary" href="/v1/tenant/export">Ladda ner min data (JSON)</a></p>
      </div>

      <div className="card" style={{ borderColor: 'var(--danger)' }}>
        <h2>Radera kontot permanent</h2>
        <p>
          All din data raderas: profil, projekt, ansökningar, uppladdade dokument och notiser. Detta kan inte ångras.
          Ansökningar du redan lämnat in hos myndigheter påverkas inte — de finns hos respektive myndighet.
        </p>
        {!isOwner && <div className="alert warning">Endast kontots ägare kan radera det.</div>}
        <label htmlFor="confirm">Skriv <strong>RADERA</strong> för att bekräfta</label>
        <input id="confirm" value={confirmText} onChange={(e) => setConfirmText(e.target.value)} disabled={!isOwner} />
        {error && <div className="alert error">{error}</div>}
        <button
          style={{ marginTop: '0.8rem', background: 'var(--danger)', borderColor: 'var(--danger)' }}
          disabled={busy || !isOwner || confirmText !== 'RADERA'}
          onClick={erase}
        >
          {busy ? 'Raderar…' : 'Radera kontot och all data'}
        </button>
      </div>
    </div>
  );
}
