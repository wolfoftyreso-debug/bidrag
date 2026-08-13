# Privacy & GDPR

## Design principles (§25, §29)

- **Data minimisation**: matching runs on age bands, municipality, applicant
  type, sector and project facts — not identity numbers. Personnummer is
  never requested for discovery and is not a profile key anywhere in the
  schema; internal opaque UUIDs identify everything.
- **Progressive identification**: external identifiers (OID, org.nr) are
  collected only when a specific submission channel requires them, stored
  separately and encrypted (AES-256-GCM).
- **Purpose limitation**: applicant facts exist to compute funding matches and
  prepare applications; the public knowledge graph contains no personal data.
- **No special-category data** is required by the default matching model, and
  no seed criterion asks for any.

## Article 22 posture (no automated decisions)

The product produces **explainable recommendations and eligibility
assessments**, not decisions with legal effect. Every match shows its score
breakdown, the rule version, the source URL and the verification date, and is
worded as an assessment ("systemet bedömer…"), never as the funder's decision.
Users can always see *why* ("Varför sa systemet så här?") and can contest by
correcting their facts — recomputation is deterministic.

## Data inventory (personal data)

| Store | Data | Basis (to be confirmed by DPO) |
|---|---|---|
| users | email, display name, password hash | contract |
| applicant_profiles | applicant type, geography, professional facts | contract |
| projects / cases / answers / documents | user-authored application content | contract |
| external_identifiers | OID/org.nr, encrypted | contract/legal obligation |
| correspondence_events | authority messages the user registers | contract |
| audit_events | actor, action, before/after | legitimate interest (security) |

## Retention & rights

- Deleting a tenant cascades through all tenant-owned tables (enforced by
  `ON DELETE CASCADE` foreign keys from `tenants`).
- Export: all tenant data is reachable through the documented `/v1` API.
- A self-service export/erasure endpoint and a retention scheduler are open
  items — see LIMITATIONS.md — and must exist before public launch.

## DPIA

Per IMY guidance, a DPIA is required before production if processing is
likely to be high-risk. This build's assessment inputs: no special-category
data required, no automated legal-effect decisions, encryption at rest for
sensitive identifiers, tenant isolation tested. The DPIA itself is an
organisational step that must be completed by the operator before launch;
the LIMITATIONS register tracks it.
