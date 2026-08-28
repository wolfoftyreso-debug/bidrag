import { createContext, useContext, useEffect, useState } from 'react';
import { Link, NavLink, Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import { get, getActiveTenant, post, setActiveTenant } from './api';
import { LanguagePicker, TranslationNotice, useT } from './i18n';
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
import { PaymentSuccessPage, PaymentCancelledPage } from './pages/PaymentReturn';


/** F-SCROLL: varje ruttbyte börjar i toppen — annars ärvs scrolläget från förra sidan. */
function ScrollToTop() {
  const { pathname } = useLocation();
  useEffect(() => { window.scrollTo(0, 0); }, [pathname]);
  return null;
}

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
  const t = useT();
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

  if (loading) return <div className="auth-page"><p>{t('app.loading')}</p></div>;

  return (
    <SessionContext.Provider value={{ session, reload }}>
      {session ? (
        <Shell />
      ) : (
        <>
          <ScrollToTop />
          <Routes>
            <Route path="/aterstall/:token" element={<ResetPasswordPage />} />
            <Route path="/villkor" element={<div className="auth-page"><TermsPage /></div>} />
            <Route path="*" element={<LoginPage onLogin={reload} />} />
          </Routes>
        </>
      )}
    </SessionContext.Provider>
  );
}

function Shell() {
  const t = useT();
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
        <div className="brand"><img className="brand-mark" src="/logo-mark.svg" alt="" aria-hidden="true" />Bidragskoll</div>
        {(session?.tenants.length ?? 0) > 1 && (
          <select
            aria-label={t('nav.activeOrg')}
            value={getActiveTenant() ?? session?.activeTenant.id}
            onChange={(e) => void switchTenant(e.target.value)}
            style={{ marginBottom: '0.6rem', fontSize: '0.85rem' }}
          >
            {session?.tenants.map((tn) => (
              <option key={tn.tenantId} value={tn.tenantId}>{tn.kind === 'personal' ? t('nav.personal') : tn.name}</option>
            ))}
          </select>
        )}
        <NavLink to="/" end>{t('nav.overview')}</NavLink>
        <NavLink to="/projekt">{t('nav.projects')}</NavLink>
        <NavLink to="/ansokningar">{t('nav.applications')}</NavLink>
        <NavLink to="/kalender">{t('nav.calendar')}</NavLink>
        <NavLink to="/sok">{t('nav.search')}</NavLink>
        <NavLink to="/dokument">{t('nav.documents')}</NavLink>
        <NavLink to="/inkorg">{t('nav.inbox')}</NavLink>
        {isCurator && <NavLink to="/admin">{t('nav.admin')}</NavLink>}
        <div className="spacer" />
        <LanguagePicker compact />
        <NavLink to="/konto" className="meta-line">{t('nav.account')}</NavLink>
        <div className="meta-line" style={{ padding: '0 0.6rem' }}>{session?.user.email}</div>
        <button className="subtle" onClick={logout} style={{ textAlign: 'start' }}>{t('nav.logout')}</button>
      </nav>
      <main className="main">
        <ScrollToTop />
        <TranslationNotice alsoSwedishContent />
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
          <Route path="/betalning/klar" element={<PaymentSuccessPage />} />
          <Route path="/betalning/avbruten" element={<PaymentCancelledPage />} />
          <Route path="/inbjudan/:token" element={<InvitePage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </main>
    </div>
  );
}

/** §40 i perfektionsdoktrinen: även fel ska kännas genomarbetade — lugnt
 * språk, vägar vidare, aldrig en tyst omdirigering. */
function NotFoundPage() {
  const t = useT();
  return (
    <div className="card" style={{ maxWidth: '34rem', margin: '3rem auto' }}>
      <p className="meta-line" style={{ textTransform: 'uppercase', letterSpacing: '0.06em', fontWeight: 600 }}>{t('notFound.tag')}</p>
      <h1>{t('notFound.title')}</h1>
      <p className="guidance">{t('notFound.body')}</p>
      <p style={{ display: 'flex', gap: '0.6rem', flexWrap: 'wrap', marginTop: '1rem' }}>
        <Link className="btn" to="/">{t('notFound.toOverview')}</Link>
        <a className="btn secondary" href="/bidrag/">{t('notFound.seeAll')}</a>
      </p>
    </div>
  );
}
