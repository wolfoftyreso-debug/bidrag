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

function returnPath(paymentId: string | null): string {
  if (!paymentId) return '/projekt';
  try { return sessionStorage.getItem(`bidrag_return_${paymentId}`) ?? '/projekt'; } catch { return '/projekt'; }
}

export function PaymentSuccessPage() {
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
            <h1>Bekräftar din betalning…</h1>
            <p className="guidance">Vi väntar på bekräftelsen från betalsystemet. Det tar oftast bara någon sekund — stäng inte sidan.</p>
            <p className="meta-line" aria-live="polite">Väntar…</p>
          </>
        )}
        {state === 'confirmed' && (
          <>
            <h1>Betalningen är klar</h1>
            <p className="guidance">Din ansökan är upplåst. Vi tar dig tillbaka…</p>
          </>
        )}
        {state === 'failed' && (
          <>
            <h1>Betalningen gick inte igenom</h1>
            <p className="guidance">Ingen ansökan skapades och inget drogs. Du kan försöka igen.</p>
            <Link className="btn" to={returnPath(paymentId)}>Tillbaka</Link>
          </>
        )}
        {state === 'error' && (
          <>
            <h1>Vi kunde inte bekräfta ännu</h1>
            <p className="guidance">Om du slutförde betalningen dyker den upp under Mina köp så snart den bekräftats. Kontakta oss om den inte gör det.</p>
            <Link className="btn" to="/konto">Mina köp</Link>
          </>
        )}
      </div>
    </div>
  );
}

export function PaymentCancelledPage() {
  const [params] = useSearchParams();
  const paymentId = params.get('payment');
  return (
    <div className="auth-page">
      <div className="card" style={{ maxWidth: 560, margin: '2rem auto', textAlign: 'center' }}>
        <h1>Betalningen avbröts</h1>
        <p className="guidance">Ingen betalning genomfördes och inget drogs. Du kan förbereda ansökan när du vill — eller ansöka själv direkt hos myndigheten, det är alltid gratis.</p>
        <Link className="btn" to={returnPath(paymentId)}>Tillbaka</Link>
      </div>
    </div>
  );
}
