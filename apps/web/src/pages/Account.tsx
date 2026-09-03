/**
 * Konto & data: GDPR-självservice (export/radering) och organisationens
 * medlemmar och inbjudningar (§26).
 */
import { Fragment, useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiError, api, downloadFile, formatDate, get, post, setActiveTenant } from '../api';
import { useSession } from '../App';
import { useLabels, useT } from '../i18n';

/** Rollkoderna som kan väljas vid inbjudan (ägare kan inte bjudas in). */
const INVITABLE_ROLES = ['applicant', 'contributor', 'reviewer', 'finance', 'administrator', 'data_curator'];

export default function AccountPage() {
  const t = useT();
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
      // OBS: bekräftelseordet RADERA är en API-kontrakt-konstant — det
      // översätts aldrig (servern kräver exakt detta ord).
      await api('DELETE', '/v1/tenant', { confirm: confirmText });
      await post('/v1/auth/logout');
      await reload();
      navigate('/');
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('acc.eraseError'));
      setBusy(false);
    }
  };

  return (
    <div style={{ maxWidth: 640 }}>
      <h1>{t('acc.title')}</h1>
      <p className="meta-line">{session?.user.email}</p>

      <PurchasesCard />

      <RecoveryCodesCard />

      <div className="card">
        <h2>{t('acc.exportTitle')}</h2>
        <p>{t('acc.exportBody')}</p>
        <p>
          <button className="secondary" onClick={() => void downloadFile('/v1/tenant/export', 'bidrag-export.json')}>
            {t('acc.exportButton')}
          </button>
        </p>
      </div>

      <TeamCard />

      <CreateOrgCard />

      <div className="card" style={{ borderColor: 'var(--danger)' }}>
        <h2>{t('acc.deleteTitle')}</h2>
        <p>{t('acc.deleteBody')}</p>
        {!isOwner && <div className="alert warning">{t('acc.ownerOnly')}</div>}
        <label htmlFor="confirm">{t('acc.writePre')} <strong>RADERA</strong> {t('acc.writePost')}</label>
        <input id="confirm" value={confirmText} onChange={(e) => setConfirmText(e.target.value)} disabled={!isOwner} />
        {error && <div className="alert error">{error}</div>}
        <button
          style={{ marginTop: '0.8rem', background: 'var(--danger)', borderColor: 'var(--danger)' }}
          disabled={busy || !isOwner || confirmText !== 'RADERA'}
          onClick={erase}
        >
          {busy ? t('acc.deleting') : t('acc.deleteButton')}
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

/**
 * Mina köp: kvittot är en förstaklassfunktion i kontot — alltid åtkomligt
 * efter inloggning, ingen e-post inblandad. Servern kontrollerar ägarskap.
 */
function PurchasesCard() {
  const t = useT();
  const labels = useLabels();
  const [purchases, setPurchases] = useState<Purchase[]>([]);
  const [openReceipt, setOpenReceipt] = useState<{ paymentId: string; document: string } | null>(null);
  const [loaded, setLoaded] = useState(false);
  // Kvittot ska gå att spara och mejla — inte bara läsa på skärmen.
  const [emailPrompt, setEmailPrompt] = useState(false);
  const [emailAddr, setEmailAddr] = useState('');
  const [emailMsg, setEmailMsg] = useState<string | null>(null);

  const emailOutcomeText = (outcome: string, sentTo?: string | null) =>
    outcome === 'sent'
      ? sentTo ? t('acc.emailSentTo', { adress: sentTo }) : t('acc.emailSent')
      : outcome === 'skipped'
        ? t('acc.emailSkipped')
        : t('acc.emailFailed');

  const sendReceipt = async (paymentId: string) => {
    setEmailMsg(null);
    try {
      const r = await post<{ emailOutcome: string }>(`/v1/payments/${paymentId}/resend-receipt`);
      setEmailPrompt(false);
      setEmailMsg(emailOutcomeText(r.emailOutcome));
    } catch (err) {
      if (err instanceof ApiError && err.status === 422) {
        setEmailPrompt(true); // ingen adress på kvittot ännu — fråga efter en
      } else {
        setEmailMsg(t('acc.emailFailedShort'));
      }
    }
  };

  const sendReceiptTo = async (paymentId: string) => {
    setEmailMsg(null);
    try {
      const r = await post<{ emailOutcome: string }>(`/v1/payments/${paymentId}/receipt-email`, { email: emailAddr });
      setEmailPrompt(false);
      setEmailMsg(emailOutcomeText(r.emailOutcome, emailAddr));
    } catch {
      setEmailMsg(t('acc.emailSaveError'));
    }
  };

  useEffect(() => {
    get<{ purchases: Purchase[] }>('/v1/purchases')
      .then(({ purchases }) => setPurchases(purchases))
      .finally(() => setLoaded(true));
  }, []);

  const showReceipt = async (paymentId: string) => {
    setEmailPrompt(false);
    setEmailMsg(null);
    if (openReceipt?.paymentId === paymentId) return setOpenReceipt(null);
    const { document } = await get<{ document: string }>(`/v1/payments/${paymentId}/receipt`);
    setOpenReceipt({ paymentId, document });
  };

  if (!loaded || purchases.length === 0) return null;

  return (
    <div className="card">
      <h2>{t('m.myPurchases')}</h2>
      <p className="guidance">{t('acc.purchasesGuidance')}</p>
      <div style={{ overflowX: 'auto' }}>
        <table className="data">
          <thead><tr><th>{t('acc.thDate')}</th><th>{t('acc.thFor')}</th><th>{t('acc.thAmount')}</th><th>{t('dash.thStatus')}</th><th>{t('acc.thReceipt')}</th></tr></thead>
          <tbody>
            {purchases.map((p) => (
              <Fragment key={p.paymentId}>
                <tr>
                  <td>{formatDate(p.confirmedAt ?? p.createdAt)}</td>
                  <td>{labels.kind(p.kind)}{p.projectTitle ? ` — ${p.projectTitle}` : ''}</td>
                  <td style={{ fontVariantNumeric: 'tabular-nums' }}>{(p.amountMinor / 100).toLocaleString('sv-SE')} kr</td>
                  <td>
                    <span className={`badge ${labels.pay(p.state).tone}`}>{labels.pay(p.state).label}</span>
                    {p.refundStatus === 'refunded' && <span className="badge info"> {t('acc.refunded')}</span>}
                  </td>
                  <td>
                    {p.receiptNumber ? (
                      <button className="secondary" style={{ padding: '0.15rem 0.6rem', fontSize: '0.8rem' }} onClick={() => showReceipt(p.paymentId)}>
                        {openReceipt?.paymentId === p.paymentId ? t('acc.hide') : p.receiptNumber}
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
                      <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.5rem', flexWrap: 'wrap', alignItems: 'center' }}>
                        <button
                          className="secondary"
                          style={{ padding: '0.25rem 0.7rem', fontSize: '0.85rem' }}
                          onClick={() => downloadFile(`/v1/payments/${p.paymentId}/receipt.pdf`, `kvitto-${p.receiptNumber}.pdf`)}
                        >
                          {t('acc.downloadReceipt')}
                        </button>
                        <button
                          className="secondary"
                          style={{ padding: '0.25rem 0.7rem', fontSize: '0.85rem' }}
                          onClick={() => sendReceipt(p.paymentId)}
                        >
                          {t('acc.emailReceipt')}
                        </button>
                      </div>
                      {emailPrompt && (
                        <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.5rem', flexWrap: 'wrap', alignItems: 'center' }}>
                          <label htmlFor="receipt-email" className="meta-line" style={{ margin: 0 }}>{t('acc.emailPrompt')}</label>
                          <input
                            id="receipt-email"
                            type="email"
                            value={emailAddr}
                            placeholder={t('acc.emailPlaceholder')}
                            onChange={(e) => setEmailAddr(e.target.value)}
                            style={{ maxWidth: '16rem' }}
                          />
                          <button className="secondary" style={{ padding: '0.25rem 0.7rem', fontSize: '0.85rem' }} disabled={!emailAddr.includes('@')} onClick={() => sendReceiptTo(p.paymentId)}>
                            {t('acc.send')}
                          </button>
                        </div>
                      )}
                      {emailMsg && <p className="meta-line" style={{ marginTop: '0.5rem' }}>{emailMsg}</p>}
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
  const t = useT();
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
      setError(err instanceof ApiError ? err.message : t('acc.rcError'));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="card">
      <h2>{t('acc.rcTitle')}</h2>
      <p className="guidance">{t('acc.rcGuidance')}</p>
      {status && status.total > 0 && !codes && (
        <p>
          {t('acc.rcRemaining', { remaining: status.remaining, total: status.total })}
          {status.remaining <= 2 && ` ${t('acc.rcCreateSoon')}`}
        </p>
      )}
      {codes && (
        <div className="alert warning">
          <p style={{ marginTop: 0 }}>
            <strong>{t('acc.rcSaveNow')}</strong> {t('acc.rcOldInvalid')}
          </p>
          <pre style={{ background: 'var(--bg)', padding: '0.8rem', borderRadius: 8, fontSize: '0.95rem', letterSpacing: '0.04em', margin: 0 }}>
            {codes.join('\n')}
          </pre>
          <p style={{ marginBottom: 0 }}>
            <button className="secondary" onClick={() => void navigator.clipboard.writeText(codes.join('\n'))}>
              {t('acc.rcCopyAll')}
            </button>
          </p>
        </div>
      )}
      {error && <div className="alert error">{error}</div>}
      <button className="secondary" disabled={busy} onClick={generate}>
        {busy ? t('acc.rcCreating') : status && status.total > 0 ? t('acc.rcNew') : t('acc.rcCreate')}
      </button>
    </div>
  );
}

function TeamCard() {
  const t = useT();
  const labels = useLabels();
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
      setError(err instanceof ApiError ? err.message : t('acc.inviteError'));
    }
  };

  return (
    <div className="card">
      <h2>{t('acc.members')}</h2>
      <table className="data">
        <thead><tr><th>{t('acc.thName')}</th><th>{t('login.email')}</th><th>{t('acc.role')}</th></tr></thead>
        <tbody>
          {members.map((m) => (
            <tr key={m.userId}>
              <td>{m.displayName}</td>
              <td>{m.email}</td>
              <td><span className="badge">{labels.role(m.role)}</span></td>
            </tr>
          ))}
        </tbody>
      </table>
      {canInvite && (
        <>
          <h3>{t('acc.inviteTitle')}</h3>
          <form
            style={{ display: 'flex', gap: '0.5rem', alignItems: 'end', flexWrap: 'wrap' }}
            onSubmit={(e) => {
              e.preventDefault();
              void invite(e.currentTarget);
            }}
          >
            <div style={{ flex: 2, minWidth: 220 }}>
              <label htmlFor="f-email">{t('login.email')}</label>
              <input id="f-email" name="email" type="email" required maxLength={320} />
            </div>
            <div style={{ minWidth: 160 }}>
              <label htmlFor="f-role">{t('acc.role')}</label>
              <select id="f-role" name="role" defaultValue="contributor">
                {INVITABLE_ROLES.map((r) => <option key={r} value={r}>{labels.role(r)}</option>)}
              </select>
            </div>
            <button type="submit" className="secondary">{t('acc.inviteButton')}</button>
          </form>
          {error && <div className="alert error">{error}</div>}
          {inviteUrl && (
            <div className="alert success">
              {t('acc.inviteCreated')}{' '}
              <code style={{ wordBreak: 'break-all' }}>{inviteUrl}</code>
            </div>
          )}
          {invitesList.length > 0 && (
            <>
              <h3>{t('acc.pendingInvites')}</h3>
              {invitesList.map((i) => (
                <div className="explain-item" key={i.id}>
                  <span className="explain-icon">✉</span>
                  <span>
                    {i.email} — {labels.role(i.role)} <span className="meta-line">{t('acc.validUntil', { datum: formatDate(i.expiresAt) })}</span>{' '}
                    <button className="subtle" onClick={() => void api('DELETE', `/v1/tenant/invites/${i.id}`).then(load)}>{t('acc.revoke')}</button>
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
  const t = useT();
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
      <h2>{t('acc.orgTitle')}</h2>
      <p className="guidance">{t('acc.orgGuidance')}</p>
      <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'end', flexWrap: 'wrap' }}>
        <div style={{ flex: 1, minWidth: 220 }}>
          <label>{t('acc.orgName')}</label>
          <input value={name} onChange={(e) => setName(e.target.value)} maxLength={200} placeholder={t('acc.orgPlaceholder')} />
        </div>
        <button className="secondary" disabled={busy || name.trim().length < 2} onClick={create}>{t('acc.create')}</button>
      </div>
    </div>
  );
}
