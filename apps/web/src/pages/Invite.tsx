/** Acceptera en inbjudan till en organisation. */
import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ApiError, get, post, setActiveTenant } from '../api';
import { useSession } from '../App';
import { useLabels, useT } from '../i18n';

export default function InvitePage() {
  const t = useT();
  const labels = useLabels();
  const { token } = useParams();
  const navigate = useNavigate();
  const { reload } = useSession();
  const [invite, setInvite] = useState<{ email: string; role: string; tenantName: string } | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!token) return;
    get<{ invite: { email: string; role: string; tenantName: string } }>(`/v1/invites/${token}`)
      .then((d) => setInvite(d.invite))
      .catch((err) => setError(err instanceof ApiError ? err.message : t('inv.loadError')));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token]);

  const accept = async () => {
    setBusy(true);
    setError(null);
    try {
      const { tenant } = await post<{ tenant: { id: string } }>(`/v1/invites/${token}/accept`);
      setActiveTenant(tenant.id);
      await reload();
      navigate('/');
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('inv.acceptError'));
      setBusy(false);
    }
  };

  return (
    <div style={{ maxWidth: 520 }}>
      <h1>{t('inv.title')}</h1>
      {error && <div className="alert error">{error}</div>}
      {invite && (
        <div className="card">
          <p>
            {t('inv.invitedPre')} <strong>{invite.tenantName}</strong> {t('inv.as')}{' '}
            <strong>{labels.role(invite.role)}</strong>.
          </p>
          <p className="guidance">{t('inv.addressedTo', { email: invite.email })}</p>
          <button disabled={busy} onClick={accept}>{busy ? t('inv.accepting') : t('inv.accept')}</button>
        </div>
      )}
    </div>
  );
}
