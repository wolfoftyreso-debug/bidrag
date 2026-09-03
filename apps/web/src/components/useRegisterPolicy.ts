/** Publik registreringspolicy (sluten beta, BETA_READINESS B7). Cachas per sidladdning. */
import { useEffect, useState } from 'react';
import { get } from '../api';

export interface RegisterPolicy { inviteRequired: boolean; beta: boolean }
let cached: RegisterPolicy | null = null;

export function useRegisterPolicy(): RegisterPolicy {
  const [policy, setPolicy] = useState<RegisterPolicy>(cached ?? { inviteRequired: false, beta: false });
  useEffect(() => {
    if (cached) return;
    get<RegisterPolicy>('/v1/auth/register-policy')
      .then((p) => { cached = p; setPolicy(p); })
      .catch(() => { /* okänd policy = öppen registrering; API:t vägrar ändå utan kod */ });
  }, []);
  return policy;
}
