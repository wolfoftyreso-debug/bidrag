/**
 * Konto & data: GDPR-självservice (export/radering) och organisationens
 * medlemmar och inbjudningar (§26).
 */
import { Fragment, useCallback, useEffect, useState } from 'react';
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

      <PurchasesCard />

      <RecoveryCodesCard />

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

interface Purchase {
  paymentId: string;
  kind: string;
  state: string;
  amountMinor: number;
  currency: string;
  provider: string;
  projectTitle: string | null;
  createdAt: string;
  confirmedAt: string | null;
  receiptNumber: string | null;
  refundStatus: string | null;
}

const PAYMENT_STATE_LABELS: Record<string, { label: string; tone: string }> = {
  confirmed: { label: 'Betald', tone: 'success' },
  pending: { label: 'Ej slutförd', tone: 'warning' },
  failed: { label: 'Misslyckad', tone: 'danger' },
  cancelled: { label: 'Avbruten', tone: '' },
};

/**
 * Mina köp: kvittot är en förstaklassfunktion i kontot — alltid åtkomligt
 * efter inloggning, ingen e-post inblandad. Servern kontrollerar ägarskap.
 */
function PurchasesCard() {
  const [purchases, setPurchases] = useState<Purchase[]>([]);
  const [openReceipt, setOpenReceipt] = useState<{ paymentId: string; document: string } | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    get<{ purchases: Purchase[] }>('/v1/purchases')
      .then(({ purchases }) => setPurchases(purchases))
      .finally(() => setLoaded(true));
  }, []);

  const showReceipt = async (paymentId: string) => {
    if (openReceipt?.paymentId === paymentId) return setOpenReceipt(null);
    const { document } = await get<{ document: string }>(`/v1/payments/${paymentId}/receipt`);
    setOpenReceipt({ paymentId, document });
  };

  if (!loaded || purchases.length === 0) return null;

  return (
    <div className="card">
      <h2>Mina köp</h2>
      <p className="guidance">Dina betalningar och kvitton — kvittot är alltid tillgängligt här.</p>
      <div style={{ overflowX: 'auto' }}>
        <table className="data">
          <thead><tr><th>Datum</th><th>Avser</th><th>Belopp</th><th>Status</th><th>Kvitto</th></tr></thead>
          <tbody>
            {purchases.map((p) => (
              <Fragment key={p.paymentId}>
                <tr>
                  <td>{formatDate(p.confirmedAt ?? p.createdAt)}</td>
                  <td>{p.kind === 'document_pack' ? 'Dokumentförberedelse' : 'Bidragsanalys'}{p.projectTitle ? ` — ${p.projectTitle}` : ''}</td>
                  <td style={{ fontVariantNumeric: 'tabular-nums' }}>{(p.amountMinor / 100).toLocaleString('sv-SE')} kr</td>
                  <td>
                    <span className={`badge ${PAYMENT_STATE_LABELS[p.state]?.tone ?? ''}`}>
                      {PAYMENT_STATE_LABELS[p.state]?.label ?? p.state}
                    </span>
                    {p.refundStatus === 'refunded' && <span className="badge info"> återbetald</span>}
                  </td>
                  <td>
                    {p.receiptNumber ? (
                      <button className="secondary" style={{ padding: '0.15rem 0.6rem', fontSize: '0.8rem' }} onClick={() => showReceipt(p.paymentId)}>
                        {openReceipt?.paymentId === p.paymentId ? 'Dölj' : p.receiptNumber}
                      </button>
                    ) : (
                      <span className="meta-line">—</span>
                    )}
                  </td>
                </tr>
                {openReceipt?.paymentId === p.paymentId && (
                  <tr>
                    <td colSpan={5}>
                      <pre style={{ background: 'var(--bg)', padding: '0.8rem', borderRadius: 8, overflowX: 'auto', fontSize: '0.8rem', margin: 0 }}>{openReceipt.document}</pre>
                    </td>
                  </tr>
                )}
              </Fragment>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

/**
 * Återställningskoder: den kanal-lösa vägen tillbaka in i kontot om
 * lösenordet glöms. Koderna visas EN gång — servern sparar bara hashar.
 */
function RecoveryCodesCard() {
  const [status, setStatus] = useState<{ total: number; remaining: number } | null>(null);
  const [codes, setCodes] = useState<string[] | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    get<{ total: number; remaining: number }>('/v1/auth/recovery-codes').then(setStatus).catch(() => {});
  }, []);

  const generate = async () => {
    setBusy(true);
    setError(null);
    try {
      const res = await post<{ codes: string[] }>('/v1/auth/recovery-codes');
      setCodes(res.codes);
      setStatus({ total: res.codes.length, remaining: res.codes.length });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Koderna kunde inte skapas. Försök igen.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="card">
      <h2>Återställningskoder</h2>
      <p className="guidance">
        Med en återställningskod kan du välja ett nytt lösenord om du glömmer ditt — utan e-post. Varje kod fungerar en
        gång. Förvara dem säkert, t.ex. i en lösenordshanterare.
      </p>
      {status && status.total > 0 && !codes && (
        <p>
          Du har <strong>{status.remaining} av {status.total}</strong> koder kvar.
          {status.remaining <= 2 && ' Skapa nya snart — gamla koder slutar gälla när du gör det.'}
        </p>
      )}
      {codes && (
        <div className="alert warning">
          <p style={{ marginTop: 0 }}>
            <strong>Spara koderna nu — de visas bara den här gången.</strong> Gamla koder har slutat gälla.
          </p>
          <pre style={{ background: 'var(--bg)', padding: '0.8rem', borderRadius: 8, fontSize: '0.95rem', letterSpacing: '0.04em', margin: 0 }}>
            {codes.join('\n')}
          </pre>
          <p style={{ marginBottom: 0 }}>
            <button className="secondary" onClick={() => void navigator.clipboard.writeText(codes.join('\n'))}>
              Kopiera alla
            </button>
          </p>
        </div>
      )}
      {error && <div className="alert error">{error}</div>}
      <button className="secondary" disabled={busy} onClick={generate}>
        {busy ? 'Skapar…' : status && status.total > 0 ? 'Skapa nya koder' : 'Skapa återställningskoder'}
      </button>
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
