/**
 * Adaptive intake (§8): starts from intent, asks only questions that
 * materially change the result, creates profile + project, computes matches.
 */
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiError, post } from '../api';

const INTENT_EXAMPLES = [
  'Jag vill ta min dansgrupp till Jamaica för att träna dancehall och ta hem kunskapen till Sverige.',
  'Vi är en idrottsförening som behöver rusta upp vår anläggning.',
  'Jag vill starta ett företag och utveckla en ny produkt.',
  'Vi vill genomföra ett ungdomsutbyte med en grupp i ett annat land.',
  'Jag är konstnär och vill arbeta utomlands en period.',
];

const APPLICANT_TYPES = [
  { value: 'individual', label: 'Privatperson / enskild utövare' },
  { value: 'association', label: 'Ideell förening' },
  { value: 'company', label: 'Företag' },
  { value: 'informal_group', label: 'Informell grupp (t.ex. kompisgäng, dansgrupp)' },
  { value: 'economic_association', label: 'Ekonomisk förening' },
  { value: 'public_body', label: 'Offentlig aktör' },
];

const SECTORS = [
  { value: 'culture', label: 'Kultur (dans, musik, konst, scen)' },
  { value: 'youth', label: 'Barn och unga' },
  { value: 'innovation', label: 'Innovation / teknik' },
  { value: 'energy', label: 'Energi' },
  { value: 'environment', label: 'Miljö och klimat' },
  { value: 'education', label: 'Utbildning' },
  { value: 'civil_society', label: 'Civilsamhälle' },
  { value: 'sports', label: 'Idrott' },
];

const ACTIVITY_TYPES = [
  { value: 'exchange', label: 'Utbyte / resa' },
  { value: 'training', label: 'Utbildning / fortbildning' },
  { value: 'performance', label: 'Föreställning / konsert' },
  { value: 'production', label: 'Produktion / skapande' },
  { value: 'investment', label: 'Investering / utrustning' },
  { value: 'development', label: 'Utvecklingsprojekt' },
];

export default function OnboardingPage() {
  const navigate = useNavigate();
  const [step, setStep] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const [intent, setIntent] = useState('');
  const [applicantType, setApplicantType] = useState('individual');
  const [municipality, setMunicipality] = useState('');
  const [professionalArtist, setProfessionalArtist] = useState<boolean | null>(null);
  const [sector, setSector] = useState('culture');
  const [activityTypes, setActivityTypes] = useState<string[]>([]);
  const [international, setInternational] = useState<boolean | null>(null);
  const [bringsKnowledgeBack, setBringsKnowledgeBack] = useState<boolean | null>(null);
  const [targetsYouth, setTargetsYouth] = useState<boolean | null>(null);
  const [budget, setBudget] = useState('');

  const finish = async () => {
    setBusy(true);
    setError(null);
    try {
      const { profile } = await post<{ profile: { id: string } }>('/v1/profiles', {
        kind: applicantType === 'individual' ? 'person' : 'organisation',
        displayName: applicantType === 'individual' ? 'Min profil' : 'Vår organisation',
        applicantType,
        country: 'SE',
        municipality: municipality || null,
        facts: {
          ...(professionalArtist !== null ? { 'person.professionalArtist': professionalArtist } : {}),
        },
      });

      const targetGroups = [...(targetsYouth ? ['youth'] : []), 'professionals'];
      // Word-boundary truncation for a readable project title.
      const words = intent.trim().split(/\s+/);
      let title = '';
      for (const w of words) {
        if ((title + ' ' + w).trim().length > 60) { title = title.trim() + '…'; break; }
        title = `${title} ${w}`;
      }
      const { project } = await post<{ project: { id: string } }>('/v1/projects', {
        profileId: profile.id,
        title: title.trim() || 'Mitt projekt',
        intent,
        totalBudgetMinor: budget ? Math.round(Number(budget) * 100) : null,
        facts: {
          'project.sector': sector,
          'project.activityTypes': activityTypes,
          'project.targetGroups': targetGroups,
          ...(international !== null ? { 'project.hasInternationalComponent': international } : {}),
          ...(bringsKnowledgeBack !== null ? { 'project.bringsKnowledgeBack': bringsKnowledgeBack } : {}),
        },
      });

      await post(`/v1/projects/${project.id}/matches`, {});
      navigate(`/projekt/${project.id}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Något gick fel.');
      setBusy(false);
    }
  };

  const steps = 4;

  return (
    <div style={{ maxWidth: 640 }}>
      <div className="progress-steps">
        {Array.from({ length: steps }, (_, i) => (
          <span key={i} className={i <= step ? 'done' : ''} />
        ))}
      </div>

      {step === 0 && (
        <div className="card">
          <h1>Vad vill du åstadkomma?</h1>
          <p className="guidance">Beskriv med egna ord — du behöver inte kunna namnet på något bidrag.</p>
          <textarea value={intent} onChange={(e) => setIntent(e.target.value)} placeholder={INTENT_EXAMPLES[0]} />
          <p className="guidance">Exempel:</p>
          <ul className="guidance">
            {INTENT_EXAMPLES.slice(1, 4).map((ex) => (
              <li key={ex} style={{ cursor: 'pointer' }} onClick={() => setIntent(ex)}>{ex}</li>
            ))}
          </ul>
          <button disabled={intent.trim().length < 10} onClick={() => setStep(1)}>Fortsätt</button>
        </div>
      )}

      {step === 1 && (
        <div className="card">
          <h2>Vem söker?</h2>
          <label>Jag söker som</label>
          <select value={applicantType} onChange={(e) => setApplicantType(e.target.value)}>
            {APPLICANT_TYPES.map((t) => (
              <option key={t.value} value={t.value}>{t.label}</option>
            ))}
          </select>
          <label>Kommun (frivilligt)</label>
          <input value={municipality} onChange={(e) => setMunicipality(e.target.value)} placeholder="t.ex. Stockholm" />
          {(applicantType === 'individual' || applicantType === 'informal_group') && (
            <>
              <label>Är du yrkesverksam inom kulturområdet?</label>
              <p className="guidance">Det avgör om du kan söka kulturbidrag för yrkesverksamma.</p>
              <div style={{ display: 'flex', gap: '0.5rem' }}>
                <button className={professionalArtist === true ? '' : 'secondary'} onClick={() => setProfessionalArtist(true)}>Ja</button>
                <button className={professionalArtist === false ? '' : 'secondary'} onClick={() => setProfessionalArtist(false)}>Nej</button>
              </div>
            </>
          )}
          <div style={{ marginTop: '1.25rem', display: 'flex', gap: '0.75rem' }}>
            <button className="secondary" onClick={() => setStep(0)}>Tillbaka</button>
            <button onClick={() => setStep(2)}>Fortsätt</button>
          </div>
        </div>
      )}

      {step === 2 && (
        <div className="card">
          <h2>Om projektet</h2>
          <label>Vilket område ligger projektet närmast?</label>
          <select value={sector} onChange={(e) => setSector(e.target.value)}>
            {SECTORS.map((s) => (
              <option key={s.value} value={s.value}>{s.label}</option>
            ))}
          </select>
          <label>Vad ska ni göra? (välj allt som stämmer)</label>
          {ACTIVITY_TYPES.map((a) => (
            <div className="checkbox-row" key={a.value}>
              <input
                type="checkbox"
                id={`act-${a.value}`}
                checked={activityTypes.includes(a.value)}
                onChange={(e) =>
                  setActivityTypes(e.target.checked ? [...activityTypes, a.value] : activityTypes.filter((x) => x !== a.value))
                }
              />
              <label htmlFor={`act-${a.value}`}>{a.label}</label>
            </div>
          ))}
          <div style={{ marginTop: '1.25rem', display: 'flex', gap: '0.75rem' }}>
            <button className="secondary" onClick={() => setStep(1)}>Tillbaka</button>
            <button onClick={() => setStep(3)}>Fortsätt</button>
          </div>
        </div>
      )}

      {step === 3 && (
        <div className="card">
          <h2>Nästan klart</h2>
          <label>Har projektet en internationell del (resa, utbyte, partner utomlands)?</label>
          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <button className={international === true ? '' : 'secondary'} onClick={() => setInternational(true)}>Ja</button>
            <button className={international === false ? '' : 'secondary'} onClick={() => setInternational(false)}>Nej</button>
          </div>
          {international && (
            <>
              <label>Kommer erfarenheterna att användas i er verksamhet i Sverige?</label>
              <div style={{ display: 'flex', gap: '0.5rem' }}>
                <button className={bringsKnowledgeBack === true ? '' : 'secondary'} onClick={() => setBringsKnowledgeBack(true)}>Ja</button>
                <button className={bringsKnowledgeBack === false ? '' : 'secondary'} onClick={() => setBringsKnowledgeBack(false)}>Nej</button>
              </div>
            </>
          )}
          <label>Riktar sig projektet till barn eller unga?</label>
          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <button className={targetsYouth === true ? '' : 'secondary'} onClick={() => setTargetsYouth(true)}>Ja</button>
            <button className={targetsYouth === false ? '' : 'secondary'} onClick={() => setTargetsYouth(false)}>Nej</button>
          </div>
          <label>Ungefärlig totalbudget (kr, frivilligt)</label>
          <input type="number" min={0} value={budget} onChange={(e) => setBudget(e.target.value)} placeholder="t.ex. 100000" />
          {error && <div className="alert error">{error}</div>}
          <div style={{ marginTop: '1.25rem', display: 'flex', gap: '0.75rem' }}>
            <button className="secondary" onClick={() => setStep(2)}>Tillbaka</button>
            <button disabled={busy} onClick={finish}>{busy ? 'Söker stöd…' : 'Visa vad jag kan söka'}</button>
          </div>
        </div>
      )}
    </div>
  );
}
