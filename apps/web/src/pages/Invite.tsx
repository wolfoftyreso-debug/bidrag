/** Acceptera en inbjudan till en organisation. */
import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ApiError, get, post, setActiveTenant } from '../api';
import { useSession } from '../App';

const ROLE_LABELS: Record<string, string> = {
  applicant: 'sökande',
  contributor: 'medarbetare',
  reviewer: 'granskare',
  finance: 'ekonomi',
  administrator: 'administratör',
  data_curator: 'datakurator',
};

export default function InvitePage() {
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
      .catch((err) => setError(err instanceof ApiError ? err.message : 'Inbjudan kunde inte hämtas.'));
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
      setError(err instanceof ApiError ? err.message : 'Kunde inte acceptera inbjudan.');
      setBusy(false);
    }
  };

  return (
    <div style={{ maxWidth: 520 }}>
      <h1>Inbjudan</h1>
      {error && <div className="alert error">{error}</div>}
      {invite && (
        <div className="card">
          <p>
            Du har bjudits in till <strong>{invite.tenantName}</strong> som{' '}
            <strong>{ROLE_LABELS[invite.role] ?? invite.role}</strong>.
          </p>
          <p className="guidance">Inbjudan är ställd till {invite.email} — du måste vara inloggad med den adressen.</p>
          <button disabled={busy} onClick={accept}>{busy ? 'Accepterar…' : 'Acceptera inbjudan'}</button>
        </div>
      )}
    </div>
  );
}
