import { createContext, useContext, useEffect, useState } from 'react';
import { NavLink, Navigate, Route, Routes, useNavigate } from 'react-router-dom';
import { get, getActiveTenant, post, setActiveTenant } from './api';
import TermsPage from './pages/Terms';
import LoginPage from './pages/Login';
import ResetPasswordPage from './pages/ResetPassword';
import DocumentStudioPage from './pages/DocumentStudio';
import OnboardingPage from './pages/Onboarding';
import CalendarPage from './pages/Calendar';
import InvitePage from './pages/Invite';
import DashboardPage from './pages/Dashboard';
import MatchesPage from './pages/Matches';
import OpportunityPage from './pages/Opportunity';
import ApplicationsPage from './pages/Applications';
import ApplicationPage from './pages/Application';
import DocumentsPage from './pages/Documents';
import InboxPage from './pages/Inbox';
import AdminPage from './pages/Admin';
import RuleEditorPage from './pages/RuleEditor';
import AccountPage from './pages/Account';
import SearchPage from './pages/Search';

export interface Session {
  user: { id: string; email: string };
  activeTenant: { id: string; role: string };
  tenants: { tenantId: string; role: string; name: string; kind: string }[];
}

const SessionContext = createContext<{ session: Session | null; reload: () => Promise<void> }>({
  session: null,
  reload: async () => {},
});

export const useSession = () => useContext(SessionContext);

export default function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  const reload = async () => {
    try {
      const me = await get<Session>('/v1/auth/me');
      setSession(me);
    } catch {
      setSession(null);
    }
  };

  useEffect(() => {
    reload().finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="auth-page"><p>Laddar…</p></div>;

  return (
    <SessionContext.Provider value={{ session, reload }}>
      {session ? (
        <Shell />
      ) : (
        <Routes>
          <Route path="/aterstall/:token" element={<ResetPasswordPage />} />
          <Route path="/villkor" element={<div className="auth-page"><TermsPage /></div>} />
          <Route path="*" element={<LoginPage onLogin={reload} />} />
        </Routes>
      )}
    </SessionContext.Provider>
  );
}

function Shell() {
  const { session, reload } = useSession();
  const navigate = useNavigate();
  const isCurator = session?.activeTenant.role === 'administrator' || session?.activeTenant.role === 'data_curator';

  const logout = async () => {
    setActiveTenant(null);
    await post('/v1/auth/logout');
    await reload();
    navigate('/');
  };

  const switchTenant = async (tenantId: string) => {
    setActiveTenant(tenantId);
    await reload();
    navigate('/');
  };

  return (
    <div className="app-shell">
      <nav className="sidebar">
        <div className="brand">Bidragskoll.se</div>
        {(session?.tenants.length ?? 0) > 1 && (
          <select
            aria-label="Aktiv organisation"
            value={getActiveTenant() ?? session?.activeTenant.id}
            onChange={(e) => void switchTenant(e.target.value)}
            style={{ marginBottom: '0.6rem', fontSize: '0.85rem' }}
          >
            {session?.tenants.map((t) => (
              <option key={t.tenantId} value={t.tenantId}>{t.kind === 'personal' ? 'Personligt' : t.name}</option>
            ))}
          </select>
        )}
        <NavLink to="/" end>Översikt</NavLink>
        <NavLink to="/projekt">Projekt &amp; matchningar</NavLink>
        <NavLink to="/ansokningar">Mina ansökningar</NavLink>
        <NavLink to="/kalender">Kalender</NavLink>
        <NavLink to="/sok">Sök stöd</NavLink>
        <NavLink to="/dokument">Dokument</NavLink>
        <NavLink to="/inkorg">Inkorg</NavLink>
        {isCurator && <NavLink to="/admin">Administration</NavLink>}
        <div className="spacer" />
        <NavLink to="/konto" className="meta-line">Konto &amp; data</NavLink>
        <div className="meta-line" style={{ padding: '0 0.6rem' }}>{session?.user.email}</div>
        <button className="subtle" onClick={logout} style={{ textAlign: 'left' }}>Logga ut</button>
      </nav>
      <main className="main">
        <Routes>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/kom-igang" element={<OnboardingPage />} />
          <Route path="/projekt" element={<MatchesPage />} />
          <Route path="/projekt/:projectId" element={<MatchesPage />} />
          <Route path="/stod/:id" element={<OpportunityPage />} />
          <Route path="/ansokningar" element={<ApplicationsPage />} />
          <Route path="/ansokningar/:id" element={<ApplicationPage />} />
          <Route path="/sok" element={<SearchPage />} />
          <Route path="/dokument" element={<DocumentsPage />} />
          <Route path="/dokument/:projectId" element={<DocumentStudioPage />} />
          <Route path="/inkorg" element={<InboxPage />} />
          <Route path="/admin" element={<AdminPage />} />
          <Route path="/admin/regler/:id" element={<RuleEditorPage />} />
          <Route path="/konto" element={<AccountPage />} />
          <Route path="/villkor" element={<TermsPage />} />
          <Route path="/kalender" element={<CalendarPage />} />
          <Route path="/inbjudan/:token" element={<InvitePage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </div>
  );
}
