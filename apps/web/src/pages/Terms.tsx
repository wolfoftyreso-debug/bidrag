/**
 * Köpvillkor och ångerrätt (distansavtalslagen 2005:59) + återbetalningspolicy.
 * Sidan är förhandsinformationen som lagen kräver före köp — köp-ytorna länkar
 * hit, och själva samtycket ges med kryssrutan vid varje köp (hård gate i API:t).
 * OBS: texterna är AI-skrivna och ska granskas av jurist före publik lansering
 * (dokumenterat i LIMITATIONS §12).
 */
import { Link } from 'react-router-dom';

export default function TermsPage() {
  return (
    <div style={{ maxWidth: 680 }}>
      <h1>Köpvillkor</h1>
      <p className="guidance">Gäller köp på Bidragskoll.se. Säljare: Landvex AB, org.nr 559141-7042, Antennvägen 2, 135 48 Tyresö.</p>

      <div className="card">
        <h2>Vad du köper</h2>
        <p>
          <strong>Att upptäcka vilka stöd du kan ha rätt till är gratis</strong> — du ser matchningarna, varför de
          matchar, grundvillkoren och länken till den officiella ansökan utan att betala. Resultaten är inte låsta.
        </p>
        <p>
          <strong>Förberedd ansökan (19 kr per ansökan):</strong> det du kan köpa är att systemet förbereder en
          ansökan åt dig, med alla dokument som behövs för den. Ingen prenumeration, inga dolda kostnader. Att
          ansöka själv direkt hos myndigheten är alltid gratis.
        </p>
        <p className="meta-line">
          Analysen är en vägledning och inte ett myndighetsbeslut. Slutligt beslut fattas alltid av den myndighet
          eller organisation som prövar ansökan. Kunskapsbasen är AI-sammanställd från officiella källor och ännu
          inte granskad av människa — kontrollera alltid aktuella villkor hos källan, som alltid länkas.
        </p>
      </div>

      <div className="card">
        <h2>Ångerrätt</h2>
        <p>
          Vid distansköp har du normalt 14 dagars ångerrätt. Båda tjänsterna är digitalt innehåll som levereras
          omedelbart. När du kryssar i samtycket vid köpet godkänner du att leveransen påbörjas direkt och
          bekräftar att ångerrätten därmed upphör — det är därför kryssrutan är obligatorisk, och tidpunkten
          för ditt samtycke anges på kvittot.
        </p>
        <p>Utan samtycke genomförs inget köp.</p>
      </div>

      <div className="card">
        <h2>Återbetalning och reklamation</h2>
        <p>
          Om tjänsten inte levererats (till exempel en betalning som bekräftats utan att den förberedda ansökan
          skapats) återbetalas hela beloppet. Reklamationer hanteras enligt konsumentköplagen — kontakta oss så utreder
          vi; ditt kvitto under <Link to="/konto">Konto &amp; data → Mina köp</Link> är underlaget, och
          återbetalningsstatus anges på kvittot.
        </p>
        <p className="meta-line">
          Återbetalningar hanteras i dag manuellt av operatören. Är du inte nöjd med hanteringen kan du vända
          dig till Allmänna reklamationsnämnden (ARN) eller EU:s tvistlösningsplattform.
        </p>
      </div>

      <div className="card">
        <h2>Personuppgifter</h2>
        <p>
          Hur vi behandlar personuppgifter — inklusive de känsliga uppgifter du själv väljer att lämna —
          beskrivs under <Link to="/konto">Konto &amp; data</Link>. Vi frågar aldrig efter personnummer för
          att visa vad du kan söka, och du kan exportera eller radera dina uppgifter när som helst.
        </p>
      </div>

      <p className="meta-line">Kvitton med momsspecifikation sparas alltid på ditt konto och kan laddas ner som PDF.</p>
    </div>
  );
}
