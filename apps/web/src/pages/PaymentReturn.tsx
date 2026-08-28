/**
 * Returvy efter Stripe Checkout. Stripe redirectar hit med ?payment=<id>.
 * Success: polla betalningsstatus tills webhooken/verifieringen bekräftat, och
 * navigera sedan tillbaka dit användaren var (sparad i sessionStorage vid
 * köpstart). Cancel: ärligt "ingen betalning genomfördes", ingen dragning.
 *
 * Betalningen bekräftas ALDRIG av att webbläsaren nådde den här sidan — bara
 * den signerade webhooken eller serververifieringen bekräftar (backend). Sidan
 * speglar bara den verifierade statusen.
 */
import { useEffect, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { get } from '../api';
import { useT } from '../i18n';

function returnPath(paymentId: string | null): string {
  if (!paymentId) return '/projekt';
  try { return sessionStorage.getItem(`bidrag_return_${paymentId}`) ?? '/projekt'; } catch { return '/projekt'; }
}

export function PaymentSuccessPage() {
  const t = useT();
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const paymentId = params.get('payment');
  const [state, setState] = useState<'pending' | 'confirmed' | 'failed' | 'error'>('pending');

  useEffect(() => {
    if (!paymentId) { setState('error'); return; }
    let tries = 0;
    let active = true;
    const back = returnPath(paymentId);
    const poll = async () => {
      const res = await get<{ state: string }>(`/v1/payments/${paymentId}/status`).catch(() => null);
      if (!active) return;
      if (res?.state === 'confirmed') {
        setState('confirmed');
        try { sessionStorage.removeItem(`bidrag_return_${paymentId}`); } catch { /* ignore */ }
        setTimeout(() => navigate(back), 1200);
        return;
      }
      if (res?.state === 'failed') { setState('failed'); return; }
      if (++tries > 40) { setState('error'); return; } // ~100 s, sedan visa manuell väg
      setTimeout(poll, 2500);
    };
    poll();
    return () => { active = false; };
  }, [paymentId, navigate]);

  return (
    <div className="auth-page">
      <div className="card" style={{ maxWidth: 560, margin: '2rem auto', textAlign: 'center' }}>
        {state === 'pending' && (
          <>
            <h1>{t('pay.confirmingTitle')}</h1>
            <p className="guidance">{t('pay.confirmingBody')}</p>
            <p className="meta-line" aria-live="polite">{t('pay.waiting')}</p>
          </>
        )}
        {state === 'confirmed' && (
          <>
            <h1>{t('pay.doneTitle')}</h1>
            <p className="guidance">{t('pay.doneBody')}</p>
          </>
        )}
        {state === 'failed' && (
          <>
            <h1>{t('pay.failedTitle')}</h1>
            <p className="guidance">{t('pay.failedBody')}</p>
            <Link className="btn" to={returnPath(paymentId)}>{t('pay.back')}</Link>
          </>
        )}
        {state === 'error' && (
          <>
            <h1>{t('pay.errorTitle')}</h1>
            <p className="guidance">{t('pay.errorBody')}</p>
            <Link className="btn" to="/konto">{t('m.myPurchases')}</Link>
          </>
        )}
      </div>
    </div>
  );
}

export function PaymentCancelledPage() {
  const t = useT();
  const [params] = useSearchParams();
  const paymentId = params.get('payment');
  return (
    <div className="auth-page">
      <div className="card" style={{ maxWidth: 560, margin: '2rem auto', textAlign: 'center' }}>
        <h1>{t('pay.cancelTitle')}</h1>
        <p className="guidance">{t('pay.cancelBody')}</p>
        <Link className="btn" to={returnPath(paymentId)}>{t('pay.back')}</Link>
      </div>
    </div>
  );
}
