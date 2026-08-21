/**
 * Ångerrättssamtycket (distansavtalslagen 2005:59) — obligatoriskt före varje
 * köp av digitalt innehåll som levereras direkt. Servern avvisar köp utan
 * samtycket (400 consent_required), så kryssrutan är ingen kosmetika: den är
 * klientsidan av en hård gate, och tidpunkten fryses på betalningen och kvittot.
 */
import { Link } from 'react-router-dom';

export function PurchaseConsent({ checked, onChange, idSuffix = '' }: {
  checked: boolean;
  onChange: (v: boolean) => void;
  idSuffix?: string;
}) {
  const id = `angerratt-samtycke${idSuffix}`;
  return (
    <div className="checkbox-row" style={{ margin: '0.9rem 0 0.6rem' }}>
      <input id={id} type="checkbox" checked={checked} onChange={(e) => onChange(e.target.checked)} />
      <label htmlFor={id} style={{ fontWeight: 500 }}>
        Jag samtycker till att tjänsten levereras direkt och bekräftar att ångerrätten
        därmed upphör.{' '}
        <span className="meta-line" style={{ display: 'inline' }}>
          (Digitalt innehåll som levereras omedelbart undantas från 14 dagars ångerrätt
          enligt distansavtalslagen — <Link to="/villkor">läs köpvillkoren</Link>.)
        </span>
      </label>
    </div>
  );
}
