/**
 * Append-only audit trail (§45). Every consequential action calls this.
 */
import { db } from './db/client.ts';
import { auditEvents } from './db/schema.ts';

export interface AuditInput {
  tenantId?: string | null;
  actorType: 'user' | 'system' | 'job';
  actorUserId?: string | null;
  action: string;
  entityType: string;
  entityId?: string | null;
  before?: unknown;
  after?: unknown;
  correlationId?: string | null;
}

export async function audit(event: AuditInput): Promise<void> {
  await db.insert(auditEvents).values({
    tenantId: event.tenantId ?? null,
    actorType: event.actorType,
    actorUserId: event.actorUserId ?? null,
    action: event.action,
    entityType: event.entityType,
    entityId: event.entityId ?? null,
    before: event.before ?? null,
    after: event.after ?? null,
    correlationId: event.correlationId ?? null,
  });
}
