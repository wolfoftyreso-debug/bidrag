/**
 * Konto & data: GDPR-självservice (export/radering) och organisationens
 * medlemmar och inbjudningar (§26).
 */
import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiError, api, downloadFile, formatDate, get, post, setActiveTenant } from '../api';
import { useSession } from '../App';

const ROLE_LABELS: Record<string, string> = {
  owner: 'ägare',
  applicant: 'sökande',
  contributor: 'medarbetare',
  reviewer: 'granskare',
  finance: 'ekonomi',
  administrator: 'administratör',
  data_curator: 'datakurator',
};

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
        <p>
          <button className="secondary" onClick={() => void downloadFile('/v1/tenant/export', 'bidrag-export.json')}>
            Ladda ner min data (JSON)
          </button>
        </p>
      </div>

      <TeamCard />

      <CreateOrgCard />

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

function TeamCard() {
  const { session } = useSession();
  const canInvite = session?.activeTenant.role === 'owner' || session?.activeTenant.role === 'administrator';
  const [members, setMembers] = useState<{ userId: string; email: string; displayName: string; role: string }[]>([]);
  const [invitesList, setInvitesList] = useState<{ id: string; email: string; role: string; expiresAt: string }[]>([]);
  const [inviteUrl, setInviteUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(() => {
    get<{ members: typeof members }>('/v1/tenant/members').then((d) => setMembers(d.members)).catch(() => {});
    if (canInvite) {
      get<{ invites: typeof invitesList }>('/v1/tenant/invites').then((d) => setInvitesList(d.invites)).catch(() => {});
    }
  }, [canInvite]);
  useEffect(load, [load]);

  const invite = async (form: HTMLFormElement) => {
    const fd = new FormData(form);
    setError(null);
    setInviteUrl(null);
    try {
      const res = await post<{ inviteUrl: string }>('/v1/tenant/invites', {
        email: String(fd.get('email')),
        role: String(fd.get('role')),
      });
      setInviteUrl(res.inviteUrl);
      form.reset();
      load();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Inbjudan kunde inte skapas.');
    }
  };

  return (
    <div className="card">
      <h2>Medlemmar</h2>
      <table className="data">
        <thead><tr><th>Namn</th><th>E-post</th><th>Roll</th></tr></thead>
        <tbody>
          {members.map((m) => (
            <tr key={m.userId}>
              <td>{m.displayName}</td>
              <td>{m.email}</td>
              <td><span className="badge">{ROLE_LABELS[m.role] ?? m.role}</span></td>
            </tr>
          ))}
        </tbody>
      </table>
      {canInvite && (
        <>
          <h3>Bjud in medlem</h3>
          <form
            style={{ display: 'flex', gap: '0.5rem', alignItems: 'end', flexWrap: 'wrap' }}
            onSubmit={(e) => {
              e.preventDefault();
              void invite(e.currentTarget);
            }}
          >
            <div style={{ flex: 2, minWidth: 220 }}>
              <label>E-post</label>
              <input name="email" type="email" required maxLength={320} />
            </div>
            <div style={{ minWidth: 160 }}>
              <label>Roll</label>
              <select name="role" defaultValue="contributor">
                {Object.entries(ROLE_LABELS).filter(([r]) => r !== 'owner').map(([r, l]) => <option key={r} value={r}>{l}</option>)}
              </select>
            </div>
            <button type="submit" className="secondary">Bjud in</button>
          </form>
          {error && <div className="alert error">{error}</div>}
          {inviteUrl && (
            <div className="alert success">
              Inbjudan skapad — länken har mejlats om e-post är konfigurerad. Du kan också dela den direkt:{' '}
              <code style={{ wordBreak: 'break-all' }}>{inviteUrl}</code>
            </div>
          )}
          {invitesList.length > 0 && (
            <>
              <h3>Väntande inbjudningar</h3>
              {invitesList.map((i) => (
                <div className="explain-item" key={i.id}>
                  <span className="explain-icon">✉</span>
                  <span>
                    {i.email} — {ROLE_LABELS[i.role] ?? i.role} <span className="meta-line">(giltig till {formatDate(i.expiresAt)})</span>{' '}
                    <button className="subtle" onClick={() => void api('DELETE', `/v1/tenant/invites/${i.id}`).then(load)}>Återkalla</button>
                  </span>
                </div>
              ))}
            </>
          )}
        </>
      )}
    </div>
  );
}

function CreateOrgCard() {
  const { reload } = useSession();
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [busy, setBusy] = useState(false);

  const create = async () => {
    setBusy(true);
    try {
      const { tenant } = await post<{ tenant: { id: string } }>('/v1/tenants', { name });
      setActiveTenant(tenant.id);
      await reload();
      navigate('/');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="card">
      <h2>Skapa organisation</h2>
      <p className="guidance">
        En organisation har egna projekt, ansökningar och dokument, och kan ha flera medlemmar med olika roller. Du blir
        ägare.
      </p>
      <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'end', flexWrap: 'wrap' }}>
        <div style={{ flex: 1, minWidth: 220 }}>
          <label>Organisationens namn</label>
          <input value={name} onChange={(e) => setName(e.target.value)} maxLength={200} placeholder="t.ex. Kulturföreningen Rytm" />
        </div>
        <button className="secondary" disabled={busy || name.trim().length < 2} onClick={create}>Skapa</button>
      </div>
    </div>
  );
}
