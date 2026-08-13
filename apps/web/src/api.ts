/** API client — same-origin /v1, cookies for auth, one 401-refresh retry. */

export class ApiError extends Error {
  constructor(
    public status: number,
    public body: { error?: string; message?: string; validation?: unknown },
  ) {
    super(body.message ?? body.error ?? `HTTP ${status}`);
  }
}

let refreshing: Promise<boolean> | null = null;

async function tryRefresh(): Promise<boolean> {
  refreshing ??= fetch('/v1/auth/refresh', { method: 'POST', credentials: 'include' })
    .then((r) => r.ok)
    .catch(() => false)
    .finally(() => {
      setTimeout(() => (refreshing = null), 0);
    });
  return refreshing;
}

/** Aktiv tenant väljs i sidofältet och skickas som header på varje anrop. */
export function getActiveTenant(): string | null {
  return localStorage.getItem('bidrag_tenant');
}
export function setActiveTenant(tenantId: string | null): void {
  if (tenantId) localStorage.setItem('bidrag_tenant', tenantId);
  else localStorage.removeItem('bidrag_tenant');
}

export async function api<T = unknown>(
  method: 'GET' | 'POST' | 'PATCH' | 'DELETE',
  path: string,
  body?: unknown,
  opts: { retry?: boolean } = {},
): Promise<T> {
  const headers: Record<string, string> = {};
  if (body !== undefined && !(body instanceof FormData)) headers['Content-Type'] = 'application/json';
  const tenant = getActiveTenant();
  if (tenant) headers['X-Tenant-Id'] = tenant;
  const init: RequestInit = {
    method,
    credentials: 'include',
    headers,
    body: body === undefined ? undefined : body instanceof FormData ? body : JSON.stringify(body),
  };
  const res = await fetch(path, init);
  if (res.status === 401 && opts.retry !== false && !path.startsWith('/v1/auth/')) {
    if (await tryRefresh()) return api(method, path, body, { retry: false });
  }
  const json = res.status === 204 ? {} : await res.json().catch(() => ({}));
  if (!res.ok) throw new ApiError(res.status, json as never);
  return json as T;
}

/** Ladda ner en fil via fetch så att tenant-headern följer med. */
export async function downloadFile(path: string, filename: string): Promise<void> {
  const tenant = getActiveTenant();
  const res = await fetch(path, {
    credentials: 'include',
    headers: tenant ? { 'X-Tenant-Id': tenant } : {},
  });
  if (!res.ok) throw new ApiError(res.status, await res.json().catch(() => ({})));
  const blob = await res.blob();
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

export const get = <T>(path: string) => api<T>('GET', path);
export const post = <T>(path: string, body?: unknown) => api<T>('POST', path, body);
export const patch = <T>(path: string, body?: unknown) => api<T>('PATCH', path, body);
export const del = <T>(path: string) => api<T>('DELETE', path);

export function formatSek(minor: number | null | undefined): string {
  if (minor === null || minor === undefined) return '—';
  return `${(minor / 100).toLocaleString('sv-SE')} kr`;
}

export function formatDate(iso: string | null | undefined): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('sv-SE', { year: 'numeric', month: 'short', day: 'numeric' });
}

export const INSTRUMENT_LABELS: Record<string, string> = {
  public_grant: 'Statligt bidrag',
  eu_grant: 'EU-bidrag',
  scholarship: 'Stipendium',
  stipend: 'Stipendium',
  travel_grant: 'Resebidrag',
  project_grant: 'Projektbidrag',
  mobility_grant: 'Mobilitetsbidrag',
  prize: 'Pris',
  reimbursement: 'Ersättning',
  loan: 'Lån',
  guarantee: 'Garanti',
  equity: 'Ägarkapital',
  sponsorship: 'Sponsring',
  procurement: 'Upphandling',
  social_benefit: 'Socialt stöd',
  educational_support: 'Studiestöd',
  other: 'Övrigt',
};

export const STATE_LABELS: Record<string, { label: string; tone: 'info' | 'success' | 'warning' | 'danger' | '' }> = {
  DISCOVERED: { label: 'Upptäckt', tone: '' },
  MATCHED: { label: 'Matchad', tone: '' },
  SELECTED: { label: 'Vald', tone: 'info' },
  PREPARING: { label: 'Förbereds', tone: 'info' },
  READY_FOR_REVIEW: { label: 'Klar för granskning', tone: 'info' },
  READY_TO_SUBMIT: { label: 'Klar att skicka in', tone: 'warning' },
  SUBMITTING: { label: 'Skickas in…', tone: 'warning' },
  SUBMITTED: { label: 'Inlämnad', tone: 'success' },
  ACKNOWLEDGED: { label: 'Mottagen av myndigheten', tone: 'success' },
  UNDER_REVIEW: { label: 'Under handläggning', tone: 'info' },
  ACTION_REQUIRED: { label: 'Åtgärd krävs', tone: 'danger' },
  DECISION_RECEIVED: { label: 'Beslut mottaget', tone: 'info' },
  AWARDED: { label: 'Beviljad', tone: 'success' },
  REJECTED: { label: 'Avslagen', tone: 'danger' },
  WITHDRAWN: { label: 'Återkallad', tone: '' },
  CLOSED: { label: 'Avslutad', tone: '' },
};

export const ELIGIBILITY_LABELS: Record<string, { label: string; tone: string }> = {
  eligible: { label: 'Uppfyller kända krav', tone: 'success' },
  unknown: { label: 'Uppgifter saknas', tone: 'warning' },
  excluded: { label: 'Uppfyller inte kraven', tone: 'danger' },
};
