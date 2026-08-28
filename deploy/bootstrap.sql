--
-- PostgreSQL database dump
--


-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: drizzle; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA drizzle;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __drizzle_migrations; Type: TABLE; Schema: drizzle; Owner: -
--

CREATE TABLE drizzle.__drizzle_migrations (
    id integer NOT NULL,
    hash text NOT NULL,
    created_at bigint
);


--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE; Schema: drizzle; Owner: -
--

CREATE SEQUENCE drizzle.__drizzle_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: drizzle; Owner: -
--

ALTER SEQUENCE drizzle.__drizzle_migrations_id_seq OWNED BY drizzle.__drizzle_migrations.id;


--
-- Name: applicant_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applicant_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    kind text NOT NULL,
    display_name text NOT NULL,
    applicant_type text NOT NULL,
    country text DEFAULT 'SE'::text NOT NULL,
    region text,
    municipality text,
    facts jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: application_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_cases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    project_id uuid NOT NULL,
    opportunity_id uuid NOT NULL,
    rule_version_id uuid NOT NULL,
    schema_id uuid,
    state text DEFAULT 'SELECTED'::text NOT NULL,
    answers jsonb DEFAULT '{}'::jsonb NOT NULL,
    answer_provenance jsonb DEFAULT '{}'::jsonb NOT NULL,
    financing jsonb,
    opportunity_snapshot jsonb NOT NULL,
    submitted_snapshot jsonb,
    deadline_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: application_schemas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_schemas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    opportunity_id uuid NOT NULL,
    version integer NOT NULL,
    def jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    actor_type text NOT NULL,
    actor_user_id uuid,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid,
    before jsonb,
    after jsonb,
    correlation_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: budget_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_lines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid NOT NULL,
    category text NOT NULL,
    description text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    unit_cost_minor integer NOT NULL,
    currency text DEFAULT 'SEK'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    activity text
);


--
-- Name: canonical_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.canonical_answers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    canonical_key text NOT NULL,
    value jsonb NOT NULL,
    source_case_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: case_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid NOT NULL,
    document_id uuid NOT NULL,
    field_key text,
    role text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: correspondence_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.correspondence_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid,
    source text NOT NULL,
    direction text NOT NULL,
    sender text DEFAULT ''::text NOT NULL,
    recipient text DEFAULT ''::text NOT NULL,
    subject text DEFAULT ''::text NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    message_type text DEFAULT 'other'::text NOT NULL,
    confidence text DEFAULT 'low'::text NOT NULL,
    matched_by text DEFAULT 'unmatched'::text NOT NULL,
    document_id uuid,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: decisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decisions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid NOT NULL,
    outcome text NOT NULL,
    amount_minor integer,
    reference text DEFAULT ''::text NOT NULL,
    decided_at timestamp with time zone NOT NULL,
    document_id uuid,
    note text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    filename text NOT NULL,
    content_type text NOT NULL,
    size_bytes integer NOT NULL,
    sha256 text NOT NULL,
    storage_path text NOT NULL,
    kind text DEFAULT 'other'::text NOT NULL,
    scan_status text DEFAULT 'pending'::text NOT NULL,
    uploaded_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: external_identifiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_identifiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    kind text NOT NULL,
    value_encrypted text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: funding_authorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_authorities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    country text NOT NULL,
    kind text NOT NULL,
    website text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: funding_opportunities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_opportunities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    authority_id uuid NOT NULL,
    programme_id uuid,
    slug text NOT NULL,
    title text NOT NULL,
    summary text DEFAULT ''::text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    objective text DEFAULT ''::text NOT NULL,
    instrument_type text NOT NULL,
    applicant_types jsonb DEFAULT '[]'::jsonb NOT NULL,
    countries jsonb DEFAULT '[]'::jsonb NOT NULL,
    sectors jsonb DEFAULT '[]'::jsonb NOT NULL,
    min_amount_minor integer,
    max_amount_minor integer,
    currency text DEFAULT 'SEK'::text NOT NULL,
    max_funding_share_percent integer,
    excludes_other_public_funding boolean DEFAULT false NOT NULL,
    incompatible_with jsonb DEFAULT '[]'::jsonb NOT NULL,
    deadline_model text NOT NULL,
    opens_at timestamp with time zone,
    closes_at timestamp with time zone,
    decision_expected_at timestamp with time zone,
    application_method text DEFAULT ''::text NOT NULL,
    application_url text,
    authentication_method text,
    submission_level text DEFAULT 'assisted'::text NOT NULL,
    estimated_effort_days integer DEFAULT 5 NOT NULL,
    reporting_obligations text DEFAULT ''::text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    current_rule_version_id uuid,
    source_id uuid,
    source_url text NOT NULL,
    source_quality text NOT NULL,
    verification_status text NOT NULL,
    last_verified_at timestamp with time zone,
    next_review_at timestamp with time zone,
    version integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: funding_programmes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_programmes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    authority_id uuid NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: funding_stacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_stacks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    project_id uuid NOT NULL,
    plan jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: generated_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.generated_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    project_id uuid NOT NULL,
    opportunity_slug text,
    opportunity_title text NOT NULL,
    template_key text NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    answers jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    email text NOT NULL,
    role text NOT NULL,
    token_hash text NOT NULL,
    invited_by uuid NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    project_id uuid NOT NULL,
    opportunity_id uuid NOT NULL,
    rule_version_id uuid NOT NULL,
    reference_date timestamp with time zone NOT NULL,
    eligibility_status text NOT NULL,
    score integer NOT NULL,
    result jsonb NOT NULL,
    stale boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    role text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    kind text NOT NULL,
    title text NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    ref_type text,
    ref_id uuid,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: payment_milestones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_milestones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid NOT NULL,
    title text NOT NULL,
    amount_minor integer,
    due_at timestamp with time zone,
    status text DEFAULT 'planned'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    project_id uuid NOT NULL,
    kind text DEFAULT 'analysis_unlock'::text NOT NULL,
    amount_minor integer NOT NULL,
    currency text DEFAULT 'SEK'::text NOT NULL,
    provider text NOT NULL,
    state text DEFAULT 'pending'::text NOT NULL,
    provider_reference text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    confirmed_at timestamp with time zone,
    receipt_email text,
    provider_token text,
    credits integer,
    withdrawal_consent_at timestamp with time zone
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    title text NOT NULL,
    intent text DEFAULT ''::text NOT NULL,
    facts jsonb DEFAULT '{}'::jsonb NOT NULL,
    total_budget_minor integer,
    currency text DEFAULT 'SEK'::text NOT NULL,
    starts_on timestamp with time zone,
    ends_on timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: receipt_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.receipt_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receipts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    payment_id uuid,
    payment_ref text NOT NULL,
    receipt_number text NOT NULL,
    product_description text NOT NULL,
    amount_gross_minor integer NOT NULL,
    amount_net_minor integer NOT NULL,
    vat_amount_minor integer NOT NULL,
    vat_rate_bps integer NOT NULL,
    currency text DEFAULT 'SEK'::text NOT NULL,
    payment_method text NOT NULL,
    payment_status text DEFAULT 'confirmed'::text NOT NULL,
    refund_status text DEFAULT 'none'::text NOT NULL,
    seller_name text NOT NULL,
    seller_org_number text,
    seller_vat_number text,
    email text,
    email_status text DEFAULT 'pending'::text NOT NULL,
    email_sent_at timestamp with time zone,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    seller_address text,
    withdrawal_consent_at timestamp with time zone
);


--
-- Name: recovery_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recovery_codes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    code_hash text NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reminders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid,
    kind text NOT NULL,
    due_at timestamp with time zone NOT NULL,
    sent_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: reporting_requirements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reporting_requirements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid NOT NULL,
    title text NOT NULL,
    due_at timestamp with time zone,
    status text DEFAULT 'pending'::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: review_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kind text NOT NULL,
    ref_type text NOT NULL,
    ref_id uuid,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    note text,
    resolved_by uuid,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: rule_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rule_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    opportunity_id uuid NOT NULL,
    version integer NOT NULL,
    criteria jsonb DEFAULT '[]'::jsonb NOT NULL,
    budget_rules jsonb DEFAULT '[]'::jsonb NOT NULL,
    evidence_requirements jsonb DEFAULT '[]'::jsonb NOT NULL,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_to timestamp with time zone,
    change_note text DEFAULT ''::text NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: source_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_snapshots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_id uuid NOT NULL,
    fetched_at timestamp with time zone DEFAULT now() NOT NULL,
    http_status integer,
    content_type text,
    content_hash text NOT NULL,
    content text,
    storage_path text,
    change_status text NOT NULL,
    diff_summary text
);


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    authority_id uuid,
    name text NOT NULL,
    url text NOT NULL,
    method text NOT NULL,
    quality text NOT NULL,
    schedule_cron text,
    active boolean DEFAULT true NOT NULL,
    parser_version text DEFAULT 'none'::text NOT NULL,
    last_fetch_at timestamp with time zone,
    last_success_at timestamp with time zone,
    last_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: storage_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storage_objects (
    path text NOT NULL,
    tenant_id uuid,
    content_type text DEFAULT 'application/octet-stream'::text NOT NULL,
    content bytea NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: submission_receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submission_receipts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    submission_id uuid NOT NULL,
    kind text NOT NULL,
    reference text DEFAULT ''::text NOT NULL,
    document_id uuid,
    note text DEFAULT ''::text NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    case_id uuid NOT NULL,
    attempt integer DEFAULT 1 NOT NULL,
    level text NOT NULL,
    state text NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    payload_hash text NOT NULL,
    destination text NOT NULL,
    error text
);


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    kind text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    display_name text NOT NULL,
    locale text DEFAULT 'sv-SE'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: __drizzle_migrations id; Type: DEFAULT; Schema: drizzle; Owner: -
--

ALTER TABLE ONLY drizzle.__drizzle_migrations ALTER COLUMN id SET DEFAULT nextval('drizzle.__drizzle_migrations_id_seq'::regclass);


--
-- Data for Name: __drizzle_migrations; Type: TABLE DATA; Schema: drizzle; Owner: -
--

INSERT INTO drizzle.__drizzle_migrations VALUES
	(1, '246d495b6c9654260f6075a2cbf6f26d964c468b62cbd5546614ec6c8b05bf68', 1786639848289),
	(2, 'dbfec98fd3b867fce6b6808eaa5066d5c67d78e0dcbaf12fb391543f07a42f98', 1786647238941),
	(3, 'd8c4ec049bdc4e6bc0379fc22480b156e65dbf203cdc53cff12ecdc0bd3ca885', 1786656849178),
	(4, '48cfd7a475b574bbbbbd9e1e9f36374f49cb305d12fcd6a784331d746eab09b8', 1786866082168),
	(5, '9967f4564b6f1f3e2cf2660a918092691adfa74d2fd1b60f09094fc0dae509ae', 1786867256173),
	(6, '705df3c9aa3018761113ea5253753688266f00b9b0baf9d42cdebd4fcea3fde0', 1786867257173),
	(7, '4da87169d804a77fb8d7c30a6cbd3e356e3cb7d20a70307a043a30fecc624e97', 1786870208032),
	(8, '42725f629f8ed012eb800f9a52c8adcf775bf24d9e78fb11c4bfbf81bc605836', 1786880994676),
	(9, 'a31a6ea35c314cc394bb2cc95509873d3b565a124a9080911379d2b67f6e018d', 1786891947515),
	(10, '2df0ae98847b7f68c992c1be713e7a05f910101f8b95d786dfd46591f13ead6e', 1786894755471),
	(11, '75e264fb61028ea91adedb82984292a39635a4994699edc826de98e5ca7ebae4', 1786925913697),
	(12, '74244bfc65928183510de39bdb80530e02a2161cf78d978bd0cb062d262f095a', 1787322138243),
	(13, '31f90f534f293eb9e9d33cdf0a5eacfcc80918e49cf34fbb74e9c9b87a34ebf8', 1787898198122);


--
-- Data for Name: applicant_profiles; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: application_cases; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: application_schemas; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.application_schemas VALUES
	('aeb66a63-bd93-475f-bbb6-187b1895e61c', 'f0450019-d08e-4c9e-91e3-6dd85bf9faba', 1, '{"id": "kulturradet-resebidrag-v1", "title": "Ansökan — Resebidrag för internationellt kulturutbyte", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "sokande_verksamhet", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "guidance": "T.ex. dans, musik, scenkonst.", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv resan och utbytet", "section": "projekt", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_land", "type": "text", "label": "Resmål (land)", "section": "projekt", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "projekt_datum", "type": "date_range", "label": "Resperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Har du en inbjudan eller bekräftelse från mottagande part?", "section": "projekt", "required": true}, {"key": "inbjudan_beskrivning", "type": "long_text", "label": "Beskriv inbjudan/samarbetet", "section": "projekt", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_inbjudan"}]}, {"key": "aterforing", "type": "long_text", "label": "Hur tar du tillvara erfarenheterna i Sverige?", "section": "projekt", "required": true, "maxLength": 2000, "canonicalKey": "project.knowledgeTransferPlan"}, {"key": "sokt_belopp", "max": 50000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig som söker"}, {"key": "projekt", "title": "Resan och utbytet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.886762+00'),
	('098f2d91-5c9e-4ea4-a36d-5fc7e9abedd6', '1874eee9-afc9-4037-86b4-4ad5d0855398', 1, '{"id": "erasmus-ungdomsutbyte-v1", "title": "Ansökan — Erasmus+ Ungdomsutbyte (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System med EU Login.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv utbytet", "section": "projekt", "guidance": "Tema, aktiviteter och förväntat lärande.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Utbytesperiod (exklusive resdagar)", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "antal_deltagare", "max": 200, "min": 4, "type": "number", "label": "Antal deltagare", "section": "deltagare", "required": true}, {"key": "har_partner", "type": "boolean", "label": "Har ni en bekräftad partnergrupp i ett annat land?", "section": "deltagare", "required": true}, {"key": "partner_namn", "type": "text", "label": "Partnergruppens namn och land", "section": "deltagare", "required": true, "maxLength": 300, "visibleWhen": [{"op": "is_true", "factPath": "har_partner"}], "canonicalKey": "project.partnerName"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Utbytet"}, {"key": "deltagare", "title": "Deltagare och partner"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.889258+00'),
	('ec142d51-5bf7-42d1-9632-80c4f588300b', 'e0ec6da9-da13-4a74-9a33-5cc324a28e79', 1, '{"id": "nordisk-kulturfond-projektstod-v1", "title": "Ansökan — Nordisk kulturfond, projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller organisation)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_titel", "type": "text", "label": "Projektets titel", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska ni göra, varför, och vad är den konstnärliga/kulturella idén?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "nordiska_lander", "type": "multiselect", "label": "Vilka nordiska länder deltar aktivt i projektet?", "options": [{"label": "Sverige", "value": "SE"}, {"label": "Danmark", "value": "DK"}, {"label": "Norge", "value": "NO"}, {"label": "Finland", "value": "FI"}, {"label": "Island", "value": "IS"}, {"label": "Grönland", "value": "GL"}, {"label": "Färöarna", "value": "FO"}, {"label": "Åland", "value": "AX"}], "section": "norden", "guidance": "Fonden kräver samarbete mellan flera nordiska länder — ange de länder som har en aktiv roll.", "required": true}, {"key": "nordisk_dimension", "type": "long_text", "label": "Vad tillför det nordiska samarbetet projektet?", "section": "norden", "guidance": "Konkret: vad händer i samarbetet som inte hade hänt nationellt?", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig/er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "norden", "title": "Nordisk dimension"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.891616+00'),
	('95128341-6b35-4c8b-8975-2940efd0f1c9', 'afd80f55-618e-4062-8f8f-daeb93f66780', 1, '{"id": "mucf-projektbidrag-v1", "title": "Ansökan — MUCF projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_syfte", "type": "long_text", "label": "Syfte och genomförande", "section": "projekt", "guidance": "Vilket problem adresserar projektet, vad ska ni göra, och hur vet ni att det fungerat?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka unga når projektet, och hur är de delaktiga?", "section": "malgrupp", "guidance": "Ungas egen delaktighet i planering och genomförande väger tungt i bedömningen.", "required": true, "maxLength": 3000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.894006+00'),
	('526a7482-b109-4055-a4b1-cdccc4c389c8', 'c485b4d4-3d50-4c35-875a-ce9002efa611', 1, '{"id": "kommun-forsorjningsstod-v1", "title": "Ansökan — Försörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "hushall_vuxna", "max": 10, "min": 1, "type": "number", "label": "Antal vuxna i hushållet", "section": "hushall", "required": true, "canonicalKey": "person.householdAdults"}, {"key": "hushall_barn", "max": 15, "min": 0, "type": "number", "label": "Antal barn som bor hemma", "section": "hushall", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "inkomst_manad", "min": 0, "type": "currency", "label": "Hushållets inkomster per månad (kr)", "section": "ekonomi", "guidance": "Räkna ihop lön, ersättningar och bidrag före skatt. Ungefärligt räcker i förberedelsen — kommunen begär exakta underlag.", "required": true, "canonicalKey": "person.monthlyHouseholdIncome"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har hushållet sparade medel eller tillgångar som kan användas till försörjningen?", "section": "ekonomi", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna", "section": "ekonomi", "guidance": "T.ex. sparkonto, bil, värdepapper. Kommunen prövar alltid tillgångar först — att redovisa dem öppet undviker kompletteringar.", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "behov_beskrivning", "type": "long_text", "label": "Beskriv din situation och vad du behöver stöd till", "section": "behov", "guidance": "Konkret: vad har hänt, vad räcker inte pengarna till, och vad gör du själv för att förändra situationen?", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hushall", "title": "Hushållet"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "behov", "title": "Din situation"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.896664+00'),
	('5231a7f5-3ae1-4f99-b965-fb6b9d080984', 'c45af3be-f486-48fc-b149-9477b15c967d', 1, '{"id": "fk-bostadsbidrag-barnfamiljer-v1", "title": "Ansökan — Bostadsbidrag till barnfamiljer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hemma (helt eller växelvis)", "section": "sokande", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 500, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "guidance": "Bidraget beräknas delvis på ytan — siffran står i hyresavtalet.", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Hushållets beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bostadsbidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav. Ta i lite uppåt hellre än neråt.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.898618+00'),
	('e396066a-710e-4d92-878d-b57aa100f282', '9c5c0677-c887-460e-9403-d38a6cd49c3b', 1, '{"id": "majblomman-bidrag-barn-v1", "title": "Ansökan — Majblomman, bidrag till barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "behov_vad", "type": "long_text", "label": "Vad söker ni bidrag för?", "section": "behov", "guidance": "Något konkret som gör skillnad för barnet: en fritidsaktivitet, kläder, utrustning, en cykel. Majblomman ger till barnet, inte till hushållets löpande utgifter.", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "max": 20000, "min": 1, "type": "currency", "label": "Ungefärligt belopp (kr)", "section": "behov", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "situation", "type": "long_text", "label": "Beskriv kort familjens situation", "section": "behov", "guidance": "Varför räcker pengarna inte till det här just nu? Kortfattat räcker.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet"}, {"key": "behov", "title": "Vad ni söker för"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.901252+00'),
	('ff605a08-4c0c-40e0-a8db-09f33ad5c2d7', '1c1b1a91-8462-451d-91c2-77de891b1132', 1, '{"id": "af-stod-start-naringsverksamhet-v1", "title": "Ansökan — Stöd till start av näringsverksamhet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?", "section": "sokande", "guidance": "Stödet förutsätter inskrivning — beslutet fattas av din handläggare.", "required": true}, {"key": "affarside", "type": "long_text", "label": "Beskriv affärsidén", "section": "verksamhet", "guidance": "Vad ska du sälja, till vem, och varför finns det efterfrågan? Konkreta belägg (kundkontakter, erfarenhet, marknadskännedom) väger tyngre än visioner.", "required": true, "maxLength": 4000}, {"key": "verksamhet_start", "type": "date", "label": "Planerad start", "section": "plan", "required": true}, {"key": "har_affarsplan", "type": "boolean", "label": "Har du en skriftlig affärsplan?", "section": "plan", "required": true}, {"key": "forsorjning", "type": "long_text", "label": "Hur försörjer du dig under uppstarten?", "section": "plan", "guidance": "Aktivitetsstödet är tidsbegränsat — visa att kalkylen håller tills verksamheten bär sig.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Affärsidén"}, {"key": "plan", "title": "Planen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.903205+00'),
	('dda707ef-43e0-4dcd-b205-5b08c4899464', 'c15864b2-a0ca-48d2-9a0e-c34dc36dbe88', 1, '{"id": "kulturradet-projektbidrag-musik-v1", "title": "Ansökan — Kulturrådet, projektbidrag musik (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "guidance": "Tio siffror. Kontrollsiffran valideras — ett felskrivet nummer är en vanlig avslagsorsak på formalia.", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska genomföras, av vem, för vilken publik — och vad skiljer det från er ordinarie verksamhet?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ovrig_finansiering", "type": "long_text", "label": "Beskriv övrig finansiering", "section": "budget", "guidance": "Egna medel, andra bidrag, intäkter. Lämna tomt om allt söks här.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.904989+00'),
	('cabef984-b35d-4f8a-a987-46b587d54f54', 'f8588186-bfbf-4d9f-9bb9-324af29ce3a3', 1, '{"id": "fk-bostadsbidrag-unga-v1", "title": "Ansökan — Bostadsbidrag för unga (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 300, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Din beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.907749+00'),
	('c38ad56d-083c-445b-b709-f09769224d58', '108084ff-abea-4a87-a4dc-f97ae3a27245', 1, '{"id": "fk-underhallsstod-v1", "title": "Ansökan — Underhållsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hos dig", "section": "barnen", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "underhall_idag", "type": "long_text", "label": "Hur fungerar underhållet i dag?", "section": "underhall", "guidance": "Betalar den andra föräldern inget, för lite eller oregelbundet? Konkret — det avgör vilken väg Försäkringskassan tar.", "required": true, "maxLength": 2000}, {"key": "har_avtal", "type": "boolean", "label": "Finns avtal eller dom om underhållsbidrag?", "section": "underhall", "required": true}, {"key": "avtal_beskrivning", "type": "long_text", "label": "Beskriv avtalet/domen kort", "section": "underhall", "guidance": "Belopp och datum räcker — dokumentet kan bifogas hos Försäkringskassan.", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_avtal"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnen", "title": "Barnen"}, {"key": "underhall", "title": "Underhållet i dag"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.91009+00'),
	('e57c3784-23b6-40f5-a9f9-b5ec5c5e7407', '7e5a1725-9d8f-4c48-8552-30fdca51f679', 1, '{"id": "pm-bostadstillagg-v1", "title": "Ansökan — Bostadstillägg för pensionärer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Allmän pension, tjänstepension och eventuell utländsk pension — sammanlagt.", "required": true}, {"key": "har_kapital", "type": "boolean", "label": "Har du sparade medel eller tillgångar över ungefär 100 000 kr?", "section": "ekonomi", "guidance": "Kapital påverkar bostadstilläggets storlek — att redovisa det öppet undviker återkrav.", "required": true}, {"key": "kapital_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_kapital"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.912141+00'),
	('cd4d2556-a4bf-4964-b4a4-337920d2f876', 'e72d6913-57e1-43df-9f01-bbc5cb984f37', 1, '{"id": "region-glasogonbidrag-barn-v1", "title": "Ansökan — Glasögonbidrag för barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 19, "min": 8, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "har_ordination", "type": "boolean", "label": "Finns ordination eller recept från optiker/ögonläkare?", "section": "barnet", "guidance": "Ordinationen är regionens underlag — utan den kan bidraget inte betalas ut.", "required": true}, {"key": "kostnad", "max": 10000, "min": 1, "type": "currency", "label": "Kostnad för glasögon eller linser (kr)", "section": "barnet", "guidance": "Bidragets tak varierar mellan regioner — hela kostnaden ersätts inte alltid.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och synbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.914414+00'),
	('33578306-512b-493d-ad61-f67feb490b65', '3e9fc384-cb77-47cc-83e1-8fa1ac5d46da', 1, '{"id": "kommun-skolskjuts-v1", "title": "Ansökan — Skolskjuts (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skolans namn", "section": "eleven", "required": true, "maxLength": 200}, {"key": "arskurs", "type": "text", "label": "Årskurs", "section": "eleven", "guidance": "Kommunens avståndsgräns skiljer sig ofta per årskurs.", "required": true, "maxLength": 20}, {"key": "avstand_km", "max": 200, "min": 0, "type": "number", "label": "Avstånd hem–skola (km)", "section": "eleven", "required": true}, {"key": "skal", "type": "long_text", "label": "Varför behövs skolskjuts?", "section": "eleven", "guidance": "Konkret: avståndet, en trafikfarlig passage, funktionsnedsättning eller växelvis boende. Kommunen prövar mot sina riktlinjer.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och skolvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.916215+00'),
	('4d7b4367-96f4-4d2f-b292-3898a34f41b2', '41d02985-29ac-4f32-9f8a-d09322a8cdbc', 1, '{"id": "arvsfonden-projektstod-v1", "title": "Ansökan — Arvsfonden projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad är nyskapande jämfört med er ordinarie verksamhet? Arvsfonden finansierar inte mer av det ni redan gör.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "malgrupp_delaktighet", "type": "long_text", "label": "Hur är målgruppen delaktig i planering och genomförande?", "section": "malgrupp", "guidance": "Delaktigheten är ett skarpt krav — beskriv mekanismen, inte avsikten: vem ur målgruppen gör vad?", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "overlevnad", "type": "long_text", "label": "Hur lever verksamheten vidare efter projektet?", "section": "budget", "guidance": "Arvsfonden kräver en överlevnadsplan: vem tar över, vem betalar, vad består?", "required": true, "maxLength": 2000}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och överlevnad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.91879+00'),
	('c5329b7d-2b2c-4901-8305-f95876237b8c', 'babd9fea-fa8f-4936-b290-124358e4b5cc', 1, '{"id": "csn-studiemedel-v1", "title": "Ansökan — Studiemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "utbildning", "type": "text", "label": "Utbildning och skola", "section": "studier", "guidance": "T.ex. \"Sjuksköterskeprogrammet, Umeå universitet\".", "required": true, "maxLength": 300}, {"key": "studietakt", "type": "select", "label": "Studietakt", "options": [{"label": "Heltid (100 %)", "value": "100"}, {"label": "75 %", "value": "75"}, {"label": "Halvtid (50 %)", "value": "50"}], "section": "studier", "required": true}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod du söker för", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "vill_lana", "type": "boolean", "label": "Vill du även ta studielån (utöver bidraget)?", "section": "ekonomi", "guidance": "Lånedelen är frivillig och kan väljas per vecka — det går att ångra sig senare.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "ekonomi", "title": "Bidrag och lån"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.921561+00'),
	('e019af93-e8db-4531-9c0f-fc39742aeefb', '22206727-625a-48d8-859b-16410fa4c5a5', 1, '{"id": "fk-aktivitetsersattning-v1", "title": "Ansökan — Aktivitetsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "nedsattning_beskrivning", "type": "long_text", "label": "Beskriv hur arbetsförmågan är nedsatt", "section": "halsa", "guidance": "Med egna ord: vad klarar du inte i dag som ett arbete kräver? Försäkringskassan gör alltid den medicinska prövningen — din beskrivning ska stämma med läkarintyget, inte ersätta det.", "required": true, "maxLength": 4000}, {"key": "har_lakarintyg", "type": "boolean", "label": "Finns ett aktuellt läkarintyg eller läkarutlåtande?", "section": "halsa", "guidance": "Läkarutlåtandet är det centrala underlaget — ansökan utan det leder nästan alltid till komplettering.", "required": true}, {"key": "pagaende_insatser", "type": "long_text", "label": "Pågående vård eller insatser", "section": "halsa", "guidance": "T.ex. behandling, rehabilitering, daglig verksamhet. Lämna tomt om inget pågår.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "halsa", "title": "Arbetsförmågan"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.924708+00'),
	('2f22e80d-3031-4a59-bbd9-bb32417e4f0c', 'b691194a-5662-4b92-ae67-d269520b3ba5', 1, '{"id": "pm-aldreforsorjningsstod-v1", "title": "Ansökan — Äldreförsörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Alla pensioner sammanlagt — även utländsk pension räknas.", "required": true}, {"key": "ovriga_inkomster", "min": 0, "type": "currency", "label": "Övriga inkomster per månad (kr)", "section": "ekonomi", "required": false}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har du sparade medel eller tillgångar?", "section": "ekonomi", "guidance": "Tillgångar påverkar prövningen — öppen redovisning undviker återkrav.", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.927537+00'),
	('7e8b6f79-8700-4884-8849-ba7bd74cbc5b', 'd4a55c7f-be0c-4096-b0ed-78e72d1a4b6c', 1, '{"id": "kommun-elevresor-gymnasiet-v1", "title": "Ansökan — Elevresor gymnasiet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (elev eller vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Gymnasieskolans namn och ort", "section": "eleven", "required": true, "maxLength": 200}, {"key": "avstand_km", "max": 300, "min": 0, "type": "number", "label": "Resväg hem–skola (km)", "section": "eleven", "guidance": "Gränsen är normalt sex kilometer närmaste väg.", "required": true}, {"key": "har_studiehjalp", "type": "boolean", "label": "Har eleven studiehjälp från CSN?", "section": "eleven", "guidance": "Elevresestödet förutsätter studiehjälp — den kommer automatiskt för de flesta gymnasieelever under 20.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och resvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.930029+00'),
	('be5283e4-dc78-4b90-8ba3-486b316d98b3', 'adf1bd42-188c-4d57-ae52-9ddf6c4ac159', 1, '{"id": "kommun-bostadsanpassningsbidrag-v1", "title": "Ansökan — Bostadsanpassningsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen och hur den påverkar boendet", "section": "behov", "guidance": "Konkret ur vardagen: trösklar, trappor, badrum. Intyg från arbetsterapeut eller läkare styrker behovet.", "required": true, "maxLength": 3000}, {"key": "anpassning", "type": "long_text", "label": "Vilken anpassning söker du bidrag för?", "section": "behov", "guidance": "T.ex. ramp vid entrén, borttagna trösklar, dörrautomatik, anpassat badrum.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "behov", "guidance": "Offert från entreprenör räcker — kommunen kan begära fler.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "har_intyg", "type": "boolean", "label": "Finns intyg från arbetsterapeut, läkare eller annan sakkunnig?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Behovet och anpassningen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.932067+00'),
	('d595cc79-d82a-4509-bcf5-99b32f7c903d', '9cc5adbb-8a6b-4245-a813-6f134a5dcf1d', 1, '{"id": "csn-omstallningsstudiestod-v1", "title": "Ansökan — Omställningsstudiestöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "arbetsliv_ar", "max": 50, "min": 0, "type": "number", "label": "Ungefär hur många år har du arbetat (minst 16 h/vecka)?", "section": "arbetsliv", "guidance": "Kravet är i genomsnitt minst 16 timmar i veckan under minst 8 år.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du planerar", "section": "studier", "required": true, "maxLength": 300}, {"key": "starkning_beskrivning", "type": "long_text", "label": "Hur stärker utbildningen din ställning på arbetsmarknaden?", "section": "studier", "guidance": "Det här är prövningens kärna: koppla utbildningen till faktisk efterfrågan — en bransch som rekryterar, en roll din arbetsgivare behöver. Söktrycket är högt och generiska motiveringar sållas bort.", "required": true, "maxLength": 4000}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "arbetsliv", "title": "Ditt arbetsliv"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.93514+00'),
	('f2c2e46e-7a37-41b8-b414-8d68638a69c3', '634296e2-be34-4ea2-8d68-eebe59871c70', 1, '{"id": "vinnova-innovativa-startups-v1", "title": "Ansökan — Vinnova Innovativa startups (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Bolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "losning_beskrivning", "type": "long_text", "label": "Beskriv lösningen och vad som är nyskapande", "section": "losning", "guidance": "Vad finns i dag, och vad gör er lösning väsentligt bättre? Vinnova jämför mot faktiska alternativ — belägg väger tyngre än vision.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "kundbevis", "type": "long_text", "label": "Vilka belägg finns för efterfrågan?", "section": "marknad", "guidance": "Kunddialoger, piloter, avsiktsförklaringar, betalande användare — det ni faktiskt har.", "required": true, "maxLength": 3000}, {"key": "team_beskrivning", "type": "long_text", "label": "Teamet och dess förmåga att genomföra", "section": "marknad", "guidance": "Roller, relevant erfarenhet och hur mycket tid nyckelpersonerna lägger.", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "budget", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "max": 300000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Bolaget"}, {"key": "losning", "title": "Lösningen"}, {"key": "marknad", "title": "Marknad och team"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.937962+00'),
	('8bf185b8-168e-4c30-b474-269586a80944', 'e56d4968-2a0b-4341-a023-687c65252a21', 1, '{"id": "tillvaxtverket-affarsutvecklingscheckar-v1", "title": "Ansökan — Affärsutvecklingscheck (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_anstallda", "max": 500, "min": 0, "type": "number", "label": "Antal anställda", "section": "foretag", "guidance": "Checkarna riktar sig typiskt till företag med 2–49 anställda — regionens villkor styr.", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv utvecklingsinsatsen", "section": "insats", "guidance": "Vad ska den externa kompetensen göra, och vad ska vara annorlunda i företaget efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "extern_leverantor", "type": "text", "label": "Extern leverantör/konsult (om känd)", "section": "insats", "required": false, "maxLength": 200}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "guidance": "Checken täcker normalt högst hälften av kostnaden — resten är egen insats.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "insats", "title": "Utvecklingsinsatsen"}, {"key": "budget", "title": "Kostnad och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.94057+00'),
	('ba00446c-fd94-439b-ac7d-7e50a6fcc87f', '472c46ce-e481-4a4c-8d30-b71afae838e0', 1, '{"id": "tillvaxtverket-regionalt-investeringsstod-v1", "title": "Ansökan — Regionalt investeringsstöd (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsort", "type": "text", "label": "Verksamhetsort (kommun)", "section": "foretag", "guidance": "Orten avgör stödområdestillhörigheten (A/B) och därmed stödnivån.", "required": true, "maxLength": 100}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Byggnader, maskiner eller inventarier — och hur investeringen ökar sysselsättningen eller konkurrenskraften på orten.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjas före ansökan", "section": "investering", "guidance": "En påbörjad investering diskvalificerar hela ansökan — beställ inget förrän ansökan är inne.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "investering", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "investering", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.942927+00'),
	('5f7d2971-5eb1-4bd9-9d77-9f69f20e67e5', 'b89d0a79-5729-402b-b155-12550695a9df', 1, '{"id": "jordbruksverket-startstod-unga-v1", "title": "Ansökan — Startstöd unga jordbrukare (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten", "section": "foretaget", "guidance": "Inriktning (växtodling, djurhållning, trädgård, rennäring), omfattning och om du startar nytt eller tar över.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "overtagande_datum", "type": "date", "label": "Datum för start eller övertagande", "section": "foretaget", "required": true}, {"key": "utbildning_erfarenhet", "type": "long_text", "label": "Din utbildning och erfarenhet inom området", "section": "plan", "guidance": "Naturbruksutbildning, kurser eller praktisk erfarenhet — kravet kan uppfyllas på flera sätt.", "required": true, "maxLength": 2000}, {"key": "har_affarsplan", "type": "boolean", "label": "Finns en skriftlig affärsplan?", "section": "plan", "guidance": "Affärsplanen är obligatorisk bilaga hos Jordbruksverket.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "foretaget", "title": "Företaget du startar eller tar över"}, {"key": "plan", "title": "Affärsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.944726+00'),
	('a0892865-cb04-4938-ad9e-e96b1bdead97', '027e6a6f-7636-4707-8c71-f27e0457b548', 1, '{"id": "jordbruksverket-investeringsstod-v1", "title": "Ansökan — Investeringsstöd jordbruk (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller företag)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Vad ska byggas eller köpas, och hur stärker det verksamheten (produktion, djurvälfärd, miljö, energi)?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad investeringskostnad (kr)", "section": "investering", "guidance": "Offerter styrker kalkylen — stödandelen räknas på faktiska kostnader.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjats före ansökan", "section": "investering", "required": true}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.946928+00'),
	('b88ab5f0-966b-447c-aebf-8c2ef67fcf70', '8294092e-7e66-4495-9f4d-3ed205c9a65e', 1, '{"id": "rf-lok-stod-v1", "title": "Ansökan — LOK-stöd (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "forbund", "type": "text", "label": "Specialidrottsförbund", "section": "forening", "guidance": "T.ex. Svenska Fotbollförbundet — anslutningen är ett krav.", "required": true, "maxLength": 200}, {"key": "antal_aktiviteter", "max": 10000, "min": 1, "type": "number", "label": "Ungefärligt antal gruppaktiviteter per termin (deltagare 7–25 år)", "section": "verksamhet", "guidance": "LOK-stödet räknas per genomförd gruppaktivitet och deltagare — närvaroregistrering i IdrottOnline är underlaget.", "required": true}, {"key": "registrerar_narvaro", "type": "boolean", "label": "Registrerar föreningen närvaro digitalt (t.ex. IdrottOnline)?", "section": "verksamhet", "guidance": "Utan närvaroregistrering kan stödet inte betalas ut — börja registrera innan perioden ansöks.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Föreningen"}, {"key": "verksamhet", "title": "Aktiviteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.949329+00'),
	('60e80f3a-f5fa-4163-bd4b-3745200f1cab', '3290e2a0-539a-44c9-80be-82402afd2e32', 1, '{"id": "kulturradet-skapande-skola-v1", "title": "Ansökan — Skapande skola (förberedelse)", "fields": [{"key": "huvudman_namn", "type": "text", "label": "Huvudmannens namn", "section": "huvudman", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "huvudman", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_elever", "max": 100000, "min": 1, "type": "number", "label": "Antal elever som omfattas", "section": "insatser", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv kulturinsatserna", "section": "insatser", "guidance": "Vilka professionella kulturaktörer, vilka konstformer, och hur eleverna är delaktiga — inte bara publik.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "lasar_period", "type": "date_range", "label": "Period (läsår)", "section": "insatser", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "huvudman", "title": "Huvudmannen"}, {"key": "insatser", "title": "Kulturinsatserna"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.951457+00'),
	('01ec54c1-1941-4eb1-9033-54c9e375c9aa', 'd112235c-577c-497b-9af8-b703f59dc6c8', 1, '{"id": "konstnarsnamnden-internationellt-kulturutbyte-v1", "title": "Ansökan — Internationellt kulturutbyte (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "utbyte_beskrivning", "type": "long_text", "label": "Beskriv utbytet", "section": "utbyte", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling just nu?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utbyte_period", "type": "date_range", "label": "Period", "section": "utbyte", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Finns en inbjudan eller bekräftelse från mottagande part?", "section": "utbyte", "guidance": "Inbjudan väger tungt — utan den bedöms utbytet som oplanerat.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "utbyte", "title": "Utbytet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.953748+00'),
	('3da80095-1172-43cf-b6fc-86886cd0ed14', '805dba6f-8a84-474f-b1ef-00e78cc32b42', 1, '{"id": "filminstitutet-kortfilmsstod-v1", "title": "Ansökan — Kortfilmsstöd (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Produktionsbolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "film_titel", "type": "text", "label": "Filmens arbetstitel", "section": "film", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "synopsis", "type": "long_text", "label": "Synopsis och konstnärlig vision", "section": "film", "guidance": "Berättelsen, formen och varför den här filmen behöver göras — konsulenten läser hundratals, det specifika bär.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "regissor", "type": "text", "label": "Regissör och tidigare verk", "section": "film", "required": true, "maxLength": 300}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Produktionsbolaget"}, {"key": "film", "title": "Filmen"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.956042+00'),
	('07267f93-c254-42aa-8616-794c3655878a', '6b3d5f61-1792-4df1-b070-3aed89eb08ed', 1, '{"id": "musikverket-projektbidrag-v1", "title": "Ansökan — Musikverket projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv musikprojektet", "section": "projekt", "guidance": "Vad ska göras, av vilka, och vad tillför det musiklivet utöver er egen verksamhet?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "medverkande", "type": "long_text", "label": "Medverkande musiker/aktörer", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.958652+00'),
	('eaacc64f-34ae-4874-9b95-ea52971e41cd', '29dcb82a-e2f5-43d4-852c-c1d867708146', 1, '{"id": "postkodstiftelsen-projektstod-v1", "title": "Ansökan — Postkodstiftelsen projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Ett avgränsat projekt med tydlig början och slut — stiftelsen finansierar inte löpande verksamhet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "forvantad_effekt", "type": "long_text", "label": "Vilken förändring ska projektet åstadkomma?", "section": "projekt", "guidance": "Formulera som förändring för målgruppen, inte som aktiviteter.", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.960933+00'),
	('4e0104fa-80c9-4e3c-8bf8-9bd36ed968a8', '611827d1-2a2f-4337-b7cc-36a338cddc1c', 1, '{"id": "mucf-organisationsbidrag-v1", "title": "Ansökan — MUCF organisationsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_medlemmar", "max": 1000000, "min": 1, "type": "number", "label": "Totalt antal medlemmar", "section": "medlemmar", "required": true}, {"key": "andel_unga", "max": 100, "min": 0, "type": "percentage", "label": "Andel medlemmar 6–25 år (%)", "section": "medlemmar", "guidance": "Kravet är minst 60 % — medlemsregistret är underlaget och MUCF granskar det.", "required": true}, {"key": "antal_medlemsforeningar", "max": 10000, "min": 1, "type": "number", "label": "Antal medlemsföreningar/lokalavdelningar", "section": "medlemmar", "guidance": "Nationell spridning krävs — normalt verksamhet i minst fem län.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "medlemmar", "title": "Medlemmar och struktur"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.963264+00'),
	('1059c7f9-853d-4730-a64c-8b13fa443c30', 'f42356cc-af7f-43f5-b6d3-65f346ebaf23', 1, '{"id": "kreativa-europa-samarbetsprojekt-v1", "title": "Ansökan — Kreativa Europa samarbetsprojekt (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partnerskap_beskrivning", "type": "long_text", "label": "Partnerskapet (organisationer och länder)", "section": "projekt", "guidance": "Minst tre organisationer från tre olika länder krävs — ange samtliga med land.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och dess europeiska dimension", "section": "projekt", "guidance": "Vad tillför samarbetet som inte hade hänt nationellt? EU-mervärdet är ett bedömningskriterium, inte en formalitet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.985878+00'),
	('e9fb1c18-7f28-48ec-ab4d-ae550618c912', '92d405ee-d097-49dc-ab8e-c62faebe66a6', 1, '{"id": "boverket-allmanna-samlingslokaler-v1", "title": "Ansökan — Stöd till allmänna samlingslokaler (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Föreningens/stiftelsens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "lokal_beskrivning", "type": "long_text", "label": "Beskriv lokalen och hur den används av allmänheten", "section": "lokal", "guidance": "Öppenheten är kravet: vilka utomstående grupper använder lokalen i dag, och hur bokar de?", "required": true, "maxLength": 3000}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Vad ska byggas, köpas eller rustas upp?", "section": "lokal", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "budget", "guidance": "Stödet täcker högst halva kostnaden — resten är egen finansiering.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "lokal", "title": "Lokalen och åtgärden"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.965335+00'),
	('3817e055-a98d-4b57-85a0-f02a036cb7ac', 'd45235a4-5975-44c4-93ed-a7ca2df70085', 1, '{"id": "naturvardsverket-ladda-bilen-v1", "title": "Ansökan — Ladda bilen (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_laddpunkter", "max": 1000, "min": 1, "type": "number", "label": "Antal laddpunkter", "section": "laddning", "required": true}, {"key": "plats_beskrivning", "type": "long_text", "label": "Var installeras laddpunkterna, och vilka använder dem?", "section": "laddning", "guidance": "Stödet gäller laddning för boende eller anställda — inte publika laddstationer.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "laddning", "guidance": "Bidraget är högst halva kostnaden per laddpunkt, med takbelopp.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "laddning", "title": "Laddpunkterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.967643+00'),
	('35102990-b563-4e99-9281-17865b26c0f6', 'df148f5f-dfdb-415c-86f6-2c63d1fe4f01', 1, '{"id": "raa-kulturarvsbidrag-v1", "title": "Ansökan — Kulturarvsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv kulturarvsinsatsen", "section": "projekt", "guidance": "Vad ska bevaras, användas eller utvecklas — och hur blir det tillgängligt för fler?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.969831+00'),
	('ff1b4256-cde9-478c-8667-59453599f1ca', '70a9b78d-5186-47cc-b281-ab71b789453b', 1, '{"id": "lansstyrelsen-bygdemedel-v1", "title": "Ansökan — Bygdemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Föreningens/kommunens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "bygd_beskrivning", "type": "long_text", "label": "Vilken bygd gäller det, och hur berörs den av vatten- eller vindkraft?", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Allmännyttan är kravet: vem i bygden får glädje av investeringen, utöver den egna föreningen?", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.972391+00'),
	('de4384ea-04da-4521-9c13-431c4b99003f', 'e7cfd942-b468-489d-8f64-bae97ef6f4ce', 1, '{"id": "csn-utlandsstudier-v1", "title": "Ansökan — Studiemedel för utlandsstudier (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "studie_land", "type": "text", "label": "Studieland", "section": "studier", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "utbildning", "type": "text", "label": "Utbildning och lärosäte", "section": "studier", "guidance": "Kontrollera att utbildningen är godkänd för studiemedel i CSN:s tjänst INNAN du tackar ja till platsen.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "terminsavgift", "min": 0, "type": "currency", "label": "Terminsavgift om sådan finns (kr)", "section": "studier", "guidance": "Merkostnadslån kan täcka undervisningsavgifter — lämna tomt om avgift saknas.", "required": false}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna utomlands"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.020374+00'),
	('86a0a46f-a6a7-4903-869e-dae276c18597', 'd956dd79-a84d-41d1-96f4-8c5a8060eaf4', 1, '{"id": "kulturradet-verksamhetsbidrag-scenkonst-v1", "title": "Ansökan — Verksamhetsbidrag scenkonst (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Gruppens/organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten kommande år", "section": "verksamhet", "guidance": "Repertoar, produktioner, spelplatser och publik — verksamhetsbidraget bedöms på helheten, inte enskilda projekt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "antal_forestallningar", "max": 2000, "min": 1, "type": "number", "label": "Planerat antal föreställningar per år", "section": "verksamhet", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Gruppen/organisationen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.974981+00'),
	('24b0a75a-165f-49d6-8823-c3e407b3eb28', '51049cca-418a-4a92-8045-1f9d9f534642', 1, '{"id": "konstnarsnamnden-arbetsstipendium-v1", "title": "Ansökan — Arbetsstipendium (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstområde", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv din konstnärliga verksamhet och dina planer", "section": "verksamhet", "guidance": "Stipendiet bedöms på konstnärlig kvalitet och aktivitet — konkreta verk, uppdrag och planer väger tyngre än ambitioner.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "meriter", "type": "long_text", "label": "Viktigaste verk och uppdrag (senaste åren)", "section": "verksamhet", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Din konstnärliga verksamhet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.977118+00'),
	('88103d1f-2e91-4e23-aabd-41ec6f269bf6', 'cd410d27-411f-4959-ab88-af4bd10df01c', 1, '{"id": "konstnarsnamnden-kulturbryggan-v1", "title": "Ansökan — Kulturbryggan (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vad som är nyskapande", "section": "projekt", "guidance": "Kulturbryggan finansierar det oprövade — beskriv vad som skiljer projektet från befintlig praxis, inte bara att det är nytt för er.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "ovriga_finansiarer", "type": "long_text", "label": "Övriga finansiärer (sökta eller beviljade)", "section": "projekt", "guidance": "Kulturbryggan ser gärna fler finansieringskällor — redovisa öppet vad som är sökt respektive beviljat.", "required": false, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.979309+00'),
	('715d552c-3de5-48dc-a449-b1dec83076ae', '259307c5-971f-49ed-bb4c-fbfb5da04092', 1, '{"id": "erasmus-mobilitet-skola-vuxen-v1", "title": "Ansökan — Erasmus+ mobilitet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System — utan OID kan ansökan inte lämnas in.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "mobilitet_beskrivning", "type": "long_text", "label": "Beskriv mobiliteterna och deras syfte", "section": "mobilitet", "guidance": "Vilka åker, vart, och hur tas lärdomarna om hand i organisationen efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_deltagare", "max": 500, "min": 1, "type": "number", "label": "Antal deltagare", "section": "mobilitet", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "mobilitet", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "mobilitet", "title": "Mobiliteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.9814+00'),
	('cc273503-65df-48e8-a32e-c03051f88e38', '52d29ddf-4657-4c28-a11a-54f03e30c815', 1, '{"id": "erasmus-ka2-smaskaliga-partnerskap-v1", "title": "Ansökan — Erasmus+ småskaliga partnerskap (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "partnerskap", "guidance": "Minst en partner i ett annat programland krävs.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv samarbetet", "section": "partnerskap", "guidance": "Småskaliga partnerskap är instegsformatet — enklare aktiviteter, lägre budget, men samma krav på tydligt syfte.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "partnerskap", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "partnerskap", "title": "Partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.983623+00'),
	('d34225c6-ad26-4afa-97ef-a34b58d5efbc', 'b2190d47-1e0d-43e0-a5a4-b8a81ea3bf28', 1, '{"id": "vinnova-planeringsbidrag-eu-v1", "title": "Ansökan — Planeringsbidrag EU-ansökan (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "eu_utlysning", "type": "text", "label": "Vilken EU-utlysning avser ni att söka?", "section": "eu", "guidance": "Program och utlysningsnamn — planeringsbidraget kräver ett konkret mål.", "required": true, "maxLength": 300}, {"key": "planering_beskrivning", "type": "long_text", "label": "Vad ska planeringsarbetet omfatta?", "section": "eu", "guidance": "Konsortiebyggande, ansökningsskrivning, resor — det bidraget faktiskt får användas till.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "eu", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "eu", "title": "EU-ansökan som planeras"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.988184+00'),
	('259f28dd-beef-471d-9e48-491aec98ac57', '7c8849f1-c71d-47c4-9d5a-8a88fd90ca1b', 1, '{"id": "mucf-solidaritetskaren-v1", "title": "Ansökan — Europeiska solidaritetskåren (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "har_kvalitetsmarkning", "type": "boolean", "label": "Har organisationen giltig Quality Label?", "section": "org", "guidance": "Kvalitetsmärkningen söks separat och måste finnas innan volontärprojekt kan beviljas.", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv volontärprojektet", "section": "volontar", "guidance": "Vad gör volontärerna, vilket stöd får de, och vilken nytta skapar projektet lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_volontarer", "max": 100, "min": 1, "type": "number", "label": "Antal volontärer", "section": "volontar", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "volontar", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "volontar", "title": "Volontärprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.990777+00'),
	('8e836a21-f56b-4d16-a207-da9a37d3045a', 'b058fe01-d6a6-4ab9-8d5c-ee52b1ad4d57', 1, '{"id": "esf-kompetensutveckling-v1", "title": "Ansökan — ESF kompetensutveckling (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka anställda/deltagare omfattas, och vad behöver de?", "section": "insats", "guidance": "ESF bedömer kopplingen till arbetsmarknadens behov — konkret kompetensgap, inte allmän utbildning.", "required": true, "maxLength": 4000}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv insatserna", "section": "insats", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kan_forfinansiera", "type": "boolean", "label": "Kan organisationen förfinansiera kostnaderna?", "section": "ekonomi", "guidance": "ESF betalar ut i efterskott mot redovisning — likviditeten måste bära projektet under tiden.", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "insats", "required": true, "canonicalKey": "project.dateRange"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "ekonomi", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "insats", "title": "Kompetensinsatsen"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.993285+00'),
	('e479df25-b994-4fbf-9a09-f619ae813fce', 'ba23f3f6-01d4-4f65-a19b-0d845c8d9f09', 1, '{"id": "si-creative-force-v1", "title": "Ansökan — Creative Force (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "projekt", "guidance": "Ett etablerat partnerskap i mållandet är kärnan i programmet.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Hur stärker projektet demokrati, yttrandefrihet eller mänskliga rättigheter genom kultur eller media? Mekanismen bedöms, inte avsikten.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnern"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.995875+00'),
	('84f7d0b7-90a7-463b-9498-178c6fa2c7fa', '9abe0ec7-4906-4df3-a304-b2d9e3b89128', 1, '{"id": "radiohjalpen-projektbidrag-v1", "title": "Ansökan — Radiohjälpens projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "niokonto", "type": "text", "label": "90-kontonummer", "section": "sokande", "guidance": "T.ex. 90 1234-5. Kontot kontrolleras mot Svensk Insamlingskontroll.", "required": true, "maxLength": 20}, {"key": "fond", "type": "select", "label": "Vilken utlysning/fond söker ni ur?", "options": [{"label": "Världens Barn", "value": "varldens_barn"}, {"label": "Musikhjälpen", "value": "musikhjalpen"}, {"label": "Victoriafonden", "value": "victoriafonden"}, {"label": "Annan aktuell utlysning", "value": "other"}], "section": "projekt", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.056076+00'),
	('adfe5697-5546-4aab-965f-b088ef50be00', '158ef93d-29f8-4450-a2d2-894ca61e7722', 1, '{"id": "vr-projektbidrag-v1", "title": "Ansökan — Vetenskapsrådet projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "har_doktorsexamen", "type": "boolean", "label": "Har du doktorsexamen?", "section": "sokande", "guidance": "Behörighetskrav — examensår kan påverka vilka bidragsformer som är öppna.", "required": true}, {"key": "larosate", "type": "text", "label": "Medelsförvaltande lärosäte", "section": "sokande", "guidance": "Bidraget förvaltas av ett svenskt lärosäte — det ska bekräfta åtagandet.", "required": true, "maxLength": 200}, {"key": "forskningsplan", "type": "long_text", "label": "Forskningsplanens kärna", "section": "forskning", "guidance": "Frågeställning, metod och förväntade resultat — sakkunniggranskningen bedömer originalitet och genomförbarhet.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "forskning", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "forskning", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Forskaren"}, {"key": "forskning", "title": "Forskningsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:43.997998+00');
INSERT INTO public.application_schemas VALUES
	('0fd69575-1125-48e8-ac37-0516aab0ee26', '379dedc4-d5f1-4cbf-8de1-553159cd4f3d', 1, '{"id": "energimyndigheten-energieffektivisering-v1", "title": "Ansökan — Stöd till energieffektivisering (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv energiåtgärden", "section": "atgard", "guidance": "Vilken energianvändning minskas, med vilken teknik, och vad är beräknad besparing i kWh?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "besparing_kwh", "max": 100000000, "min": 1, "type": "number", "label": "Beräknad energibesparing (kWh/år)", "section": "atgard", "guidance": "En energikartläggning eller leverantörsberäkning styrker siffran.", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "atgard", "title": "Åtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.000745+00'),
	('b0ad174d-7bed-4709-95db-9ff1597414f2', 'cccd491e-c09b-44f1-9b2c-7cc2ff793563', 1, '{"id": "energimyndigheten-industriklivet-v1", "title": "Ansökan — Industriklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och utsläppsminskningen", "section": "projekt", "guidance": "Industriklivet finansierar åtgärder mot processutsläpp — kvantifiera minskningen i CO2-ekvivalenter och beskriv teknikens mognadsgrad.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 100000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "projekt", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.003017+00'),
	('3beb4f65-6ffb-4e74-ab94-e3bcf7290f90', '47050bfe-fe63-44b9-9d0d-a3ad22c31e4b', 1, '{"id": "naturvardsverket-klimatklivet-v1", "title": "Ansökan — Klimatklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Sökandens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv åtgärden", "section": "atgard", "guidance": "Klimatklivet rangordnar på klimatnytta per investerad krona — utsläppsminskningen ska vara beräknad och beräkningen redovisbar.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 10000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "atgard", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Investeringskostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att åtgärden inte påbörjats före ansökan", "section": "atgard", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Sökande"}, {"key": "atgard", "title": "Klimatåtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.005291+00'),
	('4e13890b-96fc-4bd1-9782-2ebc7632f974', '20b995ab-dcc3-4ff1-98aa-d37ca9033a98', 1, '{"id": "naturvardsverket-lona-v1", "title": "Ansökan — LONA lokala naturvårdssatsningen (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "guidance": "LONA söks via kommunen — föreningar deltar som initiativtagare.", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommun", "type": "text", "label": "Kommun som står bakom ansökan", "section": "sokande", "required": true, "maxLength": 100}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv naturvårdsinsatsen", "section": "projekt", "guidance": "Vad görs, var, och vilken naturvårds- eller friluftsnytta skapas lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "guidance": "LONA täcker högst halva kostnaden.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Naturvårdsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.007586+00'),
	('0c6517b7-0342-4c5f-9e0a-cdc21a0b5545', 'b13c4d37-8afa-4d0f-a101-db60e7c57e23', 1, '{"id": "kulturradet-inkopsstod-bibliotek-v1", "title": "Ansökan — Inköpsstöd till folkbibliotek (förberedelse)", "fields": [{"key": "kommun_namn", "type": "text", "label": "Kommunens namn", "section": "kommun", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "kommun", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "inkop_beskrivning", "type": "long_text", "label": "Hur ska stödet användas?", "section": "inkop", "guidance": "Inköp av litteratur för barn och unga prioriteras; stödet får inte ersätta kommunens egen medieanslag — egeninsatsen ska bestå.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "eget_anslag", "min": 0, "type": "currency", "label": "Kommunens eget medieanslag i år (kr)", "section": "inkop", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "inkop", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "kommun", "title": "Kommunen"}, {"key": "inkop", "title": "Inköpen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.010101+00'),
	('6147e046-b5de-4e82-a138-e8cda4d1718a', 'e47f4f7e-960b-4ca1-8433-17d893b598b6', 1, '{"id": "kulturradet-litteraturstod-v1", "title": "Ansökan — Litteraturstöd (förberedelse)", "fields": [{"key": "forlag_namn", "type": "text", "label": "Förlagets namn", "section": "forlag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forlag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "titel", "type": "text", "label": "Titel och författare", "section": "titel", "required": true, "maxLength": 300, "canonicalKey": "project.title"}, {"key": "titel_beskrivning", "type": "long_text", "label": "Beskriv utgivningen", "section": "titel", "guidance": "Litteraturstödet söks efter utgivning och bedöms på kvalitet — beskriv verket sakligt, inte säljande.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "upplaga", "max": 1000000, "min": 1, "type": "number", "label": "Upplaga (exemplar)", "section": "titel", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forlag", "title": "Förlaget"}, {"key": "titel", "title": "Titeln"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.012915+00'),
	('34875e3a-15a2-4c17-a426-1e76db4c45b3', '42115092-8860-4bfc-a937-69b8903a9171', 1, '{"id": "migrationsverket-atervandringsbidrag-v1", "title": "Ansökan — Stöd vid frivillig återvandring (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "ursprungsland", "type": "text", "label": "Land du planerar att återvandra till", "section": "atervandring", "required": true, "maxLength": 100}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet som återvandrar", "section": "atervandring", "required": true}, {"key": "planerad_utresa", "type": "date", "label": "Planerad utresa", "section": "atervandring", "required": true}, {"key": "situation_beskrivning", "type": "long_text", "label": "Beskriv din plan för återetableringen", "section": "atervandring", "guidance": "Boende, försörjning och nätverk i ursprungslandet. OBS: beslutet är oåterkalleligt i bidragshänseende — uppehållstillståndet återkallas normalt. Ta det lugnt med beslutet och kontrollera aktuella belopp hos Migrationsverket.", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "atervandring", "title": "Återvandringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.015315+00'),
	('0a37374b-d324-4b30-b582-e7a97d73249d', '408124bd-81fd-4bc2-8d89-0784b9e4cebf', 1, '{"id": "af-eures-targeted-mobility-v1", "title": "Ansökan — EURES Targeted Mobility (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "mal_land", "type": "text", "label": "Land där jobbet finns", "section": "jobbet", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "jobb_status", "type": "select", "label": "Var i processen är du?", "options": [{"label": "Kallad till intervju", "value": "interview"}, {"label": "Har jobberbjudande", "value": "offer"}, {"label": "Söker aktivt", "value": "searching"}], "section": "jobbet", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Vilket stöd behöver du?", "section": "jobbet", "guidance": "Intervjuresa, flyttkostnad, språkkurs eller erkännande av examen — beloppen är schabloner per insats. EURES-rådgivaren bekräftar vad som gäller din programperiod.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "jobbet", "title": "Jobbet och flytten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.017643+00'),
	('90070b04-03f5-4b0f-8570-f038827903ec', '976d0e20-afcc-4377-99a4-cd023e0befdd', 1, '{"id": "fk-omvardnadsbidrag-v1", "title": "Ansökan — Omvårdnadsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv barnets funktionsnedsättning", "section": "barnet", "guidance": "Diagnos eller svårigheter i vardagen — läkarutlåtandet bär den medicinska bedömningen, din beskrivning bär vardagen.", "required": true, "maxLength": 3000}, {"key": "omvardnadsbehov", "type": "long_text", "label": "Vilken extra omvårdnad och tillsyn behöver barnet?", "section": "barnet", "guidance": "Jämför med barn i samma ålder: vad kräver mer tid, närvaro eller passning — dygnet runt-perspektivet räknas.", "required": true, "maxLength": 4000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om barnets funktionsnedsättning?", "section": "barnet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och behoven"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.022929+00'),
	('a9179cb1-4be7-4688-8889-e47f89786e80', '597a859b-ce74-471b-ba79-d62c4fc2e620', 1, '{"id": "fk-merkostnadsersattning-v1", "title": "Ansökan — Merkostnadsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "galler_barn", "type": "boolean", "label": "Gäller ansökan ett barn du är vårdnadshavare för?", "section": "sokande", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen", "section": "sokande", "required": true, "maxLength": 3000}, {"key": "merkostnader_ar", "min": 0, "type": "currency", "label": "Uppskattade merkostnader per år (kr)", "section": "kostnader", "guidance": "Räkna bara kostnader du inte skulle ha utan funktionsnedsättningen — och dra av eventuella bidrag som redan täcker dem.", "required": true}, {"key": "merkostnader_beskrivning", "type": "long_text", "label": "Specificera merkostnaderna", "section": "kostnader", "guidance": "Post för post: vad, hur ofta, ungefär vad det kostar per år. Kvitton och intyg stärker.", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "kostnader", "title": "Merkostnaderna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.02539+00'),
	('3664e4ab-8e67-4903-9775-80707746d576', 'c4e32053-e869-4d3b-8b5b-04f04df1b881', 1, '{"id": "fk-bilstod-v1", "title": "Ansökan — Bilstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "forflyttning", "type": "long_text", "label": "Beskriv svårigheterna att förflytta dig eller resa kollektivt", "section": "behov", "guidance": "Konkret: vad går inte, vad krävs för att det ska gå, och hur varaktigt är det?", "required": true, "maxLength": 4000}, {"key": "har_korkort", "type": "boolean", "label": "Har du (eller den som ska köra) körkort?", "section": "behov", "required": true}, {"key": "behov_anpassning", "type": "long_text", "label": "Behöver bilen anpassas — i så fall hur?", "section": "behov", "guidance": "T.ex. handreglage, ramp eller lyft. Lämna tomt om du inte vet ännu — behovet utreds.", "required": false, "maxLength": 2000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om funktionsnedsättningen?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Förflyttningsbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.027843+00'),
	('077f6a55-c0f0-4b4a-8a2e-c553655d1d01', 'daff24a1-b151-4351-8ec9-e5224d7c4f7d', 1, '{"id": "fk-narstaendepenning-v1", "title": "Ansökan — Närståendepenning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "relation", "type": "text", "label": "Din relation till den som är sjuk", "section": "varden", "guidance": "T.ex. förälder, barn, syskon, vän — närstående är den som står den sjuke nära.", "required": true, "maxLength": 200}, {"key": "vard_period", "type": "date_range", "label": "Period du avstår från arbete", "section": "varden", "required": true, "canonicalKey": "project.dateRange"}, {"key": "omfattning", "type": "select", "label": "Omfattning", "options": [{"label": "Hel dag", "value": "full"}, {"label": "Tre fjärdedelar", "value": "three_quarters"}, {"label": "Halv dag", "value": "half"}, {"label": "En fjärdedel", "value": "quarter"}], "section": "varden", "required": true}, {"key": "har_samtycke", "type": "boolean", "label": "Har den sjuke samtyckt till ansökan?", "section": "varden", "guidance": "Samtycke krävs när det är möjligt att lämna.", "required": true}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om den närståendes tillstånd?", "section": "varden", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "varden", "title": "Vården och tiden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.030325+00'),
	('4bcd380a-95da-4886-8287-600deea686cf', '5f582c0c-7448-41df-b77f-cf44696d0d02', 1, '{"id": "af-etableringsersattning-v1", "title": "Ansökan — Etableringsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "uppehallstillstand_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år fick du uppehållstillstånd?", "section": "sokande", "required": true}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven hos Arbetsförmedlingen?", "section": "etablering", "guidance": "Etableringsprogrammet förutsätter inskrivning — börja där om du inte redan är inskriven.", "required": true}, {"key": "har_barn_hemma", "type": "boolean", "label": "Har du barn som bor hos dig?", "section": "etablering", "guidance": "Med barn hemma kan etableringstillägg bli aktuellt hos Försäkringskassan.", "required": true}, {"key": "bor_ensam", "type": "boolean", "label": "Bor du ensam i egen bostad?", "section": "etablering", "guidance": "Den som bor ensam kan ha rätt till bostadsersättning.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "etablering", "title": "Etableringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.032739+00'),
	('c03c6126-e81f-41bf-89e5-cba138451e2c', '658fac41-629c-4902-b5e2-4c201e230864', 1, '{"id": "csn-hemutrustningslan-v1", "title": "Ansökan — Hemutrustningslån (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommunmottagande_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år togs du emot i en kommun?", "section": "sokande", "guidance": "Lånet söks inom två år från det första kommunmottagandet.", "required": true}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet", "section": "hemmet", "required": true}, {"key": "bostad_typ", "type": "select", "label": "Är bostaden möblerad eller omöblerad?", "options": [{"label": "Omöblerad", "value": "unfurnished"}, {"label": "Möblerad", "value": "furnished"}], "section": "hemmet", "guidance": "Lånebeloppet skiljer sig — omöblerad bostad ger högre lån.", "required": true}, {"key": "aterbetalning_medveten", "type": "boolean", "label": "Jag är medveten om att detta är ett lån som ska betalas tillbaka", "section": "hemmet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hemmet", "title": "Hemmet och behovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.035476+00'),
	('93e09964-2de2-4ecd-815f-a511c772e4d5', '91771ac6-ec58-4d1e-a0ea-041dd9f3e02d', 1, '{"id": "csn-studiestartsstod-v1", "title": "Ansökan — Studiestartsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "tidigare_utbildning", "type": "select", "label": "Din senast avslutade utbildning", "options": [{"label": "Grundskola eller kortare", "value": "grundskola"}, {"label": "Påbörjat men inte slutfört gymnasium", "value": "gymnasium_ej_klart"}, {"label": "Slutfört gymnasium", "value": "gymnasium"}], "section": "sokande", "required": true}, {"key": "kommun_kontaktad", "type": "boolean", "label": "Har du kontaktat hemkommunen om studiestartsstödet?", "section": "studier", "guidance": "Kommunen bedömer om du tillhör målgruppen innan CSN kan bevilja.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du vill gå", "section": "studier", "guidance": "Grundskole- eller gymnasienivå, t.ex. komvux.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.037939+00'),
	('5b17bc1f-f1f0-4a29-af77-1a6be763d400', '833b544b-024d-4a38-a847-fc7d6bccf87f', 1, '{"id": "csn-inackorderingstillagg-v1", "title": "Ansökan — Inackorderingstillägg (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Elevens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skola och ort", "section": "boendet", "required": true, "maxLength": 300}, {"key": "skoltyp", "type": "select", "label": "Vilken typ av skola?", "options": [{"label": "Fristående gymnasieskola", "value": "independent"}, {"label": "Folkhögskola", "value": "folk_high"}, {"label": "Kommunal gymnasieskola", "value": "municipal"}], "section": "boendet", "guidance": "Fristående skola och folkhögskola → CSN. Kommunal skola → hemkommunen.", "required": true}, {"key": "resvag", "type": "long_text", "label": "Beskriv resvägen mellan hemmet och skolan", "section": "boendet", "guidance": "Avstånd och restid — varför daglig pendling inte fungerar.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om eleven"}, {"key": "boendet", "title": "Skolan och boendet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.040791+00'),
	('862d745a-fb8d-4cef-9fe1-aa004fbc0572', '127cd502-3a44-4e5c-b6ac-705177a82fb2', 1, '{"id": "kommun-foreningsbidrag-v1", "title": "Ansökan — Kommunalt föreningsbidrag (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "medlemsantal", "max": 1000000, "min": 1, "type": "number", "label": "Antal medlemmar", "section": "forening", "required": true}, {"key": "bidragstyp", "type": "select", "label": "Vilket bidrag söker ni?", "options": [{"label": "Aktivitetsstöd (per deltagartillfälle)", "value": "activity"}, {"label": "Lokalbidrag", "value": "venue"}, {"label": "Startbidrag för ny förening", "value": "start"}, {"label": "Annat/vet inte ännu", "value": "other"}], "section": "verksamhet", "required": true}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten i kommunen", "section": "verksamhet", "guidance": "Vad ni gör, hur ofta, för vilka — särskilt barn- och ungdomsverksamhet.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Om föreningen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.043343+00'),
	('0026fd75-b64c-4f30-b900-d4bc0982041b', 'fd4a9197-c27b-4ee7-afda-35d979f2098e', 1, '{"id": "region-kulturstod-v1", "title": "Ansökan — Regionalt kulturstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "regional_forankring", "type": "long_text", "label": "Beskriv er förankring i regionen", "section": "sokande", "guidance": "Säte, verksamhetsort, publik och samarbeten i regionen.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.046041+00'),
	('55da646e-23de-48b4-a14a-407ba58b8d28', 'da0b2f8a-cd17-4b6c-bd60-d74d341e3867', 1, '{"id": "sparbanksstiftelsen-projektstod-v1", "title": "Ansökan — Sparbanksstiftelsens projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsomrade", "type": "text", "label": "Ort/område där projektet genomförs", "section": "projekt", "guidance": "Stiftelsen stödjer bara projekt i den egna sparbankens verksamhetsområde.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vem det kommer till del", "section": "projekt", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.048741+00'),
	('96400614-0931-4ed3-85d1-605ccd513fdb', '602e8c20-26ef-42ef-b464-943e26285d97', 1, '{"id": "leader-lokalt-ledd-utveckling-v1", "title": "Ansökan — Leader-projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "leaderomrade", "type": "text", "label": "Vilket leaderområde tillhör ni?", "section": "projekt", "guidance": "Osäker? Sök på \"leaderområde\" + din kommun — kansliet hjälper till.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Koppla till leaderområdets utvecklingsstrategi — lokal förankring och samarbete väger tungt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "likviditet", "type": "long_text", "label": "Hur klarar ni likviditeten tills stödet betalas ut?", "section": "budget", "guidance": "Leaderstöd betalas ut i efterhand mot redovisade kostnader.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.051241+00'),
	('85e0cbc0-30f4-4c3b-8d1f-5ae14a9674a8', '51fc07c0-1ded-4386-8f99-03d11629b0be', 1, '{"id": "forte-projektbidrag-v1", "title": "Ansökan — Forte projektbidrag (förberedelse)", "fields": [{"key": "projektledare", "type": "text", "label": "Projektledarens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "medelsforvaltare", "type": "text", "label": "Medelsförvaltare (lärosäte)", "section": "sokande", "required": true, "maxLength": 300}, {"key": "disputationsar", "max": 2100, "min": 1950, "type": "number", "label": "Projektledarens disputationsår", "section": "sokande", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv forskningsprojektet", "section": "projekt", "guidance": "Frågeställning, metod och relevans för hälsa, arbetsliv eller välfärd — sakligt och prövbart.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Projektledare och medelsförvaltare"}, {"key": "projekt", "title": "Forskningsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 16:47:44.053702+00');


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: budget_lines; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: canonical_answers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: case_documents; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: correspondence_events; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: decisions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: external_identifiers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: funding_authorities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_authorities VALUES
	('65cab2d3-8ed7-4f3d-b411-e992ee767527', 'Kulturrådet', 'SE', 'state_agency', 'https://kulturradet.se', '2026-08-28 16:47:43.093523+00'),
	('0ded917d-009b-42d5-a18f-e242792290b2', 'MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor', 'SE', 'state_agency', 'https://www.mucf.se', '2026-08-28 16:47:43.098253+00'),
	('038dc199-d889-4fc3-bcce-bb5d5828489b', 'Vinnova', 'SE', 'state_agency', 'https://www.vinnova.se', '2026-08-28 16:47:43.100903+00'),
	('2af8212e-c128-4afd-b6a5-1bb58f570480', 'Tillväxtverket', 'SE', 'state_agency', 'https://tillvaxtverket.se', '2026-08-28 16:47:43.103524+00'),
	('54d7945e-c5de-4cdc-a17c-03e74eacb119', 'Energimyndigheten', 'SE', 'state_agency', 'https://www.energimyndigheten.se', '2026-08-28 16:47:43.105998+00'),
	('8454639d-e196-4bc6-8906-115581d8abf9', 'Naturvårdsverket', 'SE', 'state_agency', 'https://www.naturvardsverket.se', '2026-08-28 16:47:43.108383+00'),
	('48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', 'Jordbruksverket', 'SE', 'state_agency', 'https://jordbruksverket.se', '2026-08-28 16:47:43.110425+00'),
	('2e4a8215-55b6-4bae-9c7b-5173033498fd', 'Svenska ESF-rådet', 'SE', 'state_agency', 'https://www.esf.se', '2026-08-28 16:47:43.111945+00'),
	('5b109bb1-21c2-4c94-b827-a9b7fb5cb271', 'Europeiska kommissionen (Erasmus+/EACEA)', 'EU', 'eu', 'https://erasmus-plus.ec.europa.eu', '2026-08-28 16:47:43.114268+00'),
	('20fe6a7f-8008-448a-82de-cbeab6ce4453', 'UHR — Universitets- och högskolerådet', 'SE', 'state_agency', 'https://www.uhr.se', '2026-08-28 16:47:43.116189+00'),
	('9e528334-1289-461e-b22b-dde99ab62b73', 'Konstnärsnämnden', 'SE', 'state_agency', 'https://www.konstnarsnamnden.se', '2026-08-28 16:47:43.118092+00'),
	('23c3bf91-72e5-4f73-bc64-9ab786ee6225', 'Allmänna arvsfonden', 'SE', 'foundation', 'https://www.arvsfonden.se', '2026-08-28 16:47:43.119728+00'),
	('731a7e6f-0225-4328-bf69-72d344cbbd8a', 'Boverket', 'SE', 'state_agency', 'https://www.boverket.se', '2026-08-28 16:47:43.12203+00'),
	('035aa2c1-5589-481d-9e83-6c0a9c2ac3ef', 'Riksidrottsförbundet', 'SE', 'association', 'https://www.rf.se', '2026-08-28 16:47:43.1238+00'),
	('1951f314-9107-4859-85a5-3e1ffc1c9eb2', 'Svenska Filminstitutet', 'SE', 'foundation', 'https://www.filminstitutet.se', '2026-08-28 16:47:43.125428+00'),
	('b40fc693-72c5-4db6-b526-3d90e5c71542', 'Formas', 'SE', 'state_agency', 'https://www.formas.se', '2026-08-28 16:47:43.127087+00'),
	('e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Försäkringskassan', 'SE', 'state_agency', 'https://www.forsakringskassan.se', '2026-08-28 16:47:43.129148+00'),
	('f3e64d78-4014-4cc8-8738-3f1add544dcd', 'CSN — Centrala studiestödsnämnden', 'SE', 'state_agency', 'https://www.csn.se', '2026-08-28 16:47:43.131164+00'),
	('97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'Pensionsmyndigheten', 'SE', 'state_agency', 'https://www.pensionsmyndigheten.se', '2026-08-28 16:47:43.132679+00'),
	('b19978da-e163-485b-bd60-e9abde43de1a', 'Socialtjänsten i din kommun', 'SE', 'municipality', 'https://www.socialstyrelsen.se', '2026-08-28 16:47:43.134145+00'),
	('3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'Arbetsförmedlingen', 'SE', 'state_agency', 'https://arbetsformedlingen.se', '2026-08-28 16:47:43.136195+00'),
	('a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'Din kommun', 'SE', 'municipality', NULL, '2026-08-28 16:47:43.138076+00'),
	('e86450a5-3347-4eb3-99c3-02a88fe076c3', 'Riksantikvarieämbetet', 'SE', 'state_agency', 'https://www.raa.se', '2026-08-28 16:47:43.139903+00'),
	('2cd0f3a7-8580-4aad-aa3a-f13ea4ae6c26', 'Svenska institutet', 'SE', 'state_agency', 'https://si.se', '2026-08-28 16:47:43.14195+00'),
	('a0d58015-0790-41cb-911c-41318d27d722', 'Nordisk kulturfond', 'DK', 'foundation', 'https://www.nordiskkulturfond.org', '2026-08-28 16:47:43.143749+00'),
	('83bc1100-03b7-42e8-b09e-c5738e28c0c2', 'Vetenskapsrådet', 'SE', 'state_agency', 'https://www.vr.se', '2026-08-28 16:47:43.145276+00'),
	('fb49244f-7aae-42f9-8036-d3d6cb09b1c5', 'Svenska Postkodstiftelsen', 'SE', 'foundation', 'https://postkodstiftelsen.se', '2026-08-28 16:47:43.146821+00'),
	('ddddeb50-a0b4-43cf-8f80-ace23e32c364', 'Statens musikverk', 'SE', 'state_agency', 'https://musikverket.se', '2026-08-28 16:47:43.148443+00'),
	('269cc233-2da3-475a-aae0-c92d7484743a', 'Länsstyrelsen i ditt län', 'SE', 'region', 'https://www.lansstyrelsen.se', '2026-08-28 16:47:43.150041+00'),
	('92c3e316-3ea3-4605-96d8-ac921962531b', 'Din region', 'SE', 'region', 'https://www.1177.se', '2026-08-28 16:47:43.152086+00'),
	('739ddcb9-3861-4824-a21c-ab9f8444b694', 'Majblommans Riksförbund', 'SE', 'foundation', 'https://majblomman.se', '2026-08-28 16:47:43.153893+00'),
	('5eb8a5d0-d180-4378-b961-ec973438d851', 'Migrationsverket', 'SE', 'state_agency', 'https://www.migrationsverket.se', '2026-08-28 16:47:43.155516+00'),
	('941d14c3-80a3-47c5-b090-5f80d2dfb3ee', 'Forte — Forskningsrådet för hälsa, arbetsliv och välfärd', 'SE', 'state_agency', 'https://forte.se', '2026-08-28 16:47:43.157214+00'),
	('ce150a61-c7fa-4a55-a4ea-7404acaf806b', 'Sparbanksstiftelsen i ditt område', 'SE', 'foundation', 'https://www.sparbankerna.se', '2026-08-28 16:47:43.158883+00'),
	('52156ca5-09a4-4f2a-bc70-e9a02eea9e16', 'Radiohjälpen', 'SE', 'foundation', 'https://www.radiohjalpen.se', '2026-08-28 16:47:43.160838+00'),
	('d434f635-0d4d-4ba7-9e71-11227556b027', 'Din a-kassa', 'SE', 'association', 'https://www.sverigesakassor.se', '2026-08-28 16:47:43.16331+00');


--
-- Data for Name: funding_opportunities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_opportunities VALUES
	('f0450019-d08e-4c9e-91e3-6dd85bf9faba', '65cab2d3-8ed7-4f3d-b411-e992ee767527', 'fe2f3397-ede6-4fc6-a7ef-9ea3c8952a57', 'kulturradet-internationellt-resebidrag-musik', 'Kulturrådet — Resebidrag för internationellt kulturutbyte', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Stödet riktar sig till yrkesverksamma kulturskapare i Sverige som deltar i internationellt kulturutbyte, till exempel gästspel, samarbetsprojekt eller kompetensutveckling utomlands. Bidraget kan täcka resekostnader och relaterade omkostnader. Kontrollera alltid aktuella villkor hos Kulturrådet.', 'Främja internationellt kulturutbyte och svenska kulturskapares internationella närvaro.', 'travel_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-09-24 21:59:59+00', NULL, 'Ansökan görs i Kulturrådets onlinetjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', '183e874e-1074-4273-8fbe-d55bb5e2ded2', 'f829d377-d561-41dc-bdad-54c4bbfdad42', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.25082+00', '2026-08-28 16:47:43.25082+00'),
	('1874eee9-afc9-4037-86b4-4ad5d0855398', '5b109bb1-21c2-4c94-b827-a9b7fb5cb271', 'a83b3071-7c48-4c74-aba9-7caef932bf90', 'erasmus-plus-ungdomsutbyten', 'Erasmus+ — Ungdomsutbyten (Youth Exchanges)', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Ungdomsutbyten inom Erasmus+ låter grupper av unga från olika länder mötas i 5–21 dagar (exklusive resa) kring ett gemensamt program. Stödet täcker resekostnader samt praktiska kostnader och aktivitetskostnader enligt programguidens schabloner. Ansökan görs av en organisation eller informell grupp via det nationella programkontoret (i Sverige: MUCF för ungdomsdelen). Organisationen behöver ett OID (Organisation ID) via EU:s Organisation Registration System.', 'Interkulturellt lärande, ungas delaktighet och europeiskt samarbete.', 'eu_grant', '["association", "informal_group", "municipality"]', '["SE"]', '["youth", "culture", "education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, '2026-10-01 10:00:00+00', NULL, 'Ansökan lämnas i EU:s ansökningssystem för Erasmus+ (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'eu_login', 'assisted', 15, '', 'published', '56f181a0-75b2-4975-acfc-82030d967243', '452c57c6-8983-4ae0-a334-76f33bb4f0e2', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.261525+00', '2026-08-28 16:47:43.261525+00'),
	('afd80f55-618e-4062-8f8f-daeb93f66780', '0ded917d-009b-42d5-a18f-e242792290b2', 'a2f95f69-b93e-47e3-8752-074fc90e5925', 'mucf-projektbidrag-ungdomsorganisationer', 'MUCF — Projektbidrag för barn- och ungdomsorganisationer', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'MUCF fördelar statsbidrag till civilsamhällets organisationer, bland annat projektbidrag för verksamhet med och för barn och unga. Bidragen har specifika villkor per utlysning — kontrollera alltid aktuell utlysning hos MUCF.', 'Stärka ungas delaktighet och civilsamhällets verksamhet för barn och unga.', 'project_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i MUCF:s ansökningssystem när en utlysning är öppen.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', 'd9ec385b-9fb7-49b0-865e-81994c101f26', 'dafb453c-1945-40e8-b7f9-0aa1f567d087', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.270339+00', '2026-08-28 16:47:43.270339+00'),
	('634296e2-be34-4ea2-8d68-eebe59871c70', '038dc199-d889-4fc3-bcce-bb5d5828489b', '46555705-846e-4c93-aef5-df98e2ec56dc', 'vinnova-innovativa-startups', 'Vinnova — Innovativa startups', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Vinnovas program för innovativa startups riktar sig till unga svenska aktiebolag med skalbara, nyskapande lösningar. Utlysningar öppnar i omgångar med specifika villkor per omgång — kontrollera aktuell utlysning hos Vinnova. Bidraget kräver normalt att bolaget är yngre än en viss ålder och har begränsad omsättning.', 'Stärka svenska startups förmåga att utveckla och kommersialisera innovationer.', 'public_grant', '["company"]', '["SE"]', '["innovation", "technology"]', NULL, 30000000, 'SEK', 100, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst (Intressentportalen).', 'https://www.vinnova.se/soka-finansiering/', 'vinnova_konto', 'assisted', 10, '', 'published', '7c7d8804-dc9c-4389-b1e3-6286adf87d4b', 'ea88f28a-0118-4f1f-b2cd-6dbf0fcafb27', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.278939+00', '2026-08-28 16:47:43.278939+00'),
	('379dedc4-d5f1-4cbf-8de1-553159cd4f3d', '54d7945e-c5de-4cdc-a17c-03e74eacb119', '771214c1-749d-427a-8ff4-a21b3ecd4d21', 'energimyndigheten-energieffektivisering', 'Energimyndigheten — Stöd för energi- och klimatprojekt (löpande utlysningar)', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Det mesta av Energimyndighetens stöd fördelas via utlysningar som öppnar löpande inom olika områden. Ansökan och ärendehantering sker via Mina sidor. Villkoren varierar per utlysning — den här posten representerar programområdet; kontrollera aktuella utlysningar hos Energimyndigheten.', 'Energiomställning: forskning, innovation och effektivare energianvändning.', 'public_grant', '["company", "university", "public_body", "association", "economic_association"]', '["SE"]', '["energy", "environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 12, '', 'published', '4070e188-b5b5-4cc3-9194-286ea840a61f', 'a3c5e9c5-897e-46f7-bbc9-f5dd695ad8dd', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.286396+00', '2026-08-28 16:47:43.286396+00'),
	('d45235a4-5975-44c4-93ed-a7ca2df70085', '8454639d-e196-4bc6-8906-115581d8abf9', '99662e89-df5d-47c4-8e36-84cbe351d0f2', 'naturvardsverket-ladda-bilen-organisationer', 'Naturvårdsverket — Bidrag för miljö- och klimatåtgärder (organisationer)', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket administrerar flera bidrag inom miljö- och klimatområdet, uppdelade efter mottagartyp (organisationer, företag, ekonomiska föreningar, offentlig sektor och privatpersoner). Villkoren varierar per bidrag — den här posten representerar området; kontrollera aktuellt bidrag hos Naturvårdsverket.', 'Miljö- och klimatåtgärder i hela samhället.', 'public_grant', '["association", "company", "economic_association", "public_body", "individual"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänster.', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 6, '', 'published', '10bba9ef-adfe-414d-9d6c-5ccec0d90112', '878725ca-49df-431e-9ba7-270171aabfd8', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.296077+00', '2026-08-28 16:47:43.296077+00'),
	('c15864b2-a0ca-48d2-9a0e-c34dc36dbe88', '65cab2d3-8ed7-4f3d-b411-e992ee767527', '31eb01be-d53a-491e-83cf-c7f164e6e089', 'kulturradet-projektbidrag-musik', 'Kulturrådet — Projektbidrag musik (fria musiklivet)', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Kulturrådet fördelar projektbidrag till det fria musiklivet. Bidraget söks av grupper, arrangörer och organisationer inom musikområdet. Villkor och ansökningsperioder publiceras per omgång på Kulturrådets webbplats.', 'Ett levande och oberoende musikliv i hela landet.', 'project_grant', '["association", "company", "individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Kulturrådets onlinetjänst när omgången är öppen.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 7, '', 'published', 'd092f792-2a38-4952-8b10-7c890802fa56', 'f829d377-d561-41dc-bdad-54c4bbfdad42', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.306356+00', '2026-08-28 16:47:43.306356+00'),
	('d112235c-577c-497b-9af8-b703f59dc6c8', '9e528334-1289-461e-b22b-dde99ab62b73', 'e6ca2e7a-b788-4072-b928-81abdfc60b51', 'konstnarsnamnden-internationellt-kulturutbyte', 'Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Konstnärsnämnden ger bidrag till yrkesverksamma konstnärer inom bild, form, dans, film, musik och teater för internationellt kulturutbyte — t.ex. resor för samarbeten, gästspel eller arbetsvistelser utomlands. Ansökningsomgångar publiceras per konstområde; kontrollera aktuella tider hos Konstnärsnämnden.', 'Konstnärers internationalisering och konstnärliga utveckling.', 'travel_grant', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 4, '', 'published', 'a8f36063-cf29-4a8d-8e68-23f8107060b5', '2faad5bd-34a0-434d-a858-a7329d65b8ab', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.314467+00', '2026-08-28 16:47:43.314467+00'),
	('51049cca-418a-4a92-8045-1f9d9f534642', '9e528334-1289-461e-b22b-dde99ab62b73', '3e26a1b6-1e8d-47db-a54f-dbea4fc0798c', 'konstnarsnamnden-arbetsstipendium', 'Konstnärsnämnden — Arbetsstipendium', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Arbetsstipendiet ska ge yrkesverksamma konstnärer ekonomiskt utrymme att utveckla sitt konstnärskap. Söks per konstområde i årliga omgångar; villkor och tider publiceras av Konstnärsnämnden.', 'Konstnärlig fördjupning och försörjningstrygghet för yrkesverksamma konstnärer.', 'stipend', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 6, '', 'published', 'c8595a90-6fd4-44b5-9212-46a63c113d6d', '2faad5bd-34a0-434d-a858-a7329d65b8ab', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.320921+00', '2026-08-28 16:47:43.320921+00'),
	('41d02985-29ac-4f32-9f8a-d09322a8cdbc', '23c3bf91-72e5-4f73-bc64-9ab786ee6225', '0c882fd8-ec12-4901-a8f7-c904f2101e7b', 'arvsfonden-projektstod', 'Allmänna arvsfonden — Projektstöd', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Arvsfonden stödjer ideella organisationers utvecklingsprojekt som är nyskapande och där målgruppen — barn, ungdomar, äldre eller personer med funktionsnedsättning — är delaktig. Ansökan kan lämnas löpande; projekt kan pågå i upp till tre år.', 'Nyskapande och utvecklande verksamhet för fondens målgrupper.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.arvsfonden.se/soka-pengar', 'none', 'assisted', 12, '', 'published', '135fca02-adbf-4ed9-abdb-c17dd9b0306b', '44710950-a58e-4545-bba6-ce9a9a4c8b7d', 'https://www.arvsfonden.se/soka-pengar', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.328536+00', '2026-08-28 16:47:43.328536+00'),
	('92d405ee-d097-49dc-ab8e-c62faebe66a6', '731a7e6f-0225-4328-bf69-72d344cbbd8a', 'ef295822-8134-49b1-b31c-4f70c20502ff', 'boverket-allmanna-samlingslokaler', 'Boverket — Investeringsbidrag till allmänna samlingslokaler', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Boverket ger investeringsbidrag till föreningar och stiftelser för nybyggnad, ombyggnad, köp eller standardhöjande reparationer av allmänna samlingslokaler — t.ex. bygdegårdar, folkets hus och föreningslokaler. Årlig ansökningsomgång; villkor publiceras av Boverket.', 'Tillgång till lokaler för möten, kultur och fritid i hela landet.', 'public_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "culture"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.boverket.se/sv/bidrag--garantier/', 'eid', 'assisted', 10, '', 'published', 'ee5f5ad3-1daf-4a8b-8d59-1fac9581b3b2', 'c569efc1-8a04-48fd-9aa9-bd8098574acb', 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.337217+00', '2026-08-28 16:47:43.337217+00'),
	('8294092e-7e66-4495-9f4d-3ed205c9a65e', '035aa2c1-5589-481d-9e83-6c0a9c2ac3ef', '02a81d1a-9b6f-4a35-b54c-ffc421cc4214', 'rf-lok-stod', 'Riksidrottsförbundet — Statligt lokalt aktivitetsstöd (LOK-stöd)', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'LOK-stödet ger idrottsföreningar anslutna till ett specialidrottsförbund ersättning per sammankomst och deltagartillfälle för ledarledd verksamhet för deltagare 7–25 år. Redovisas i IdrottOnline två gånger per år.', 'Stödja föreningsdriven barn- och ungdomsidrott.', 'public_grant', '["association"]', '["SE"]', '["sports", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-08-25 21:59:59+00', NULL, 'Ansökan/redovisning görs i IdrottOnline. Ansökningsperioderna stänger 25 februari och 25 augusti.', 'https://www.rf.se/bidrag-och-stod', 'none', 'assisted', 2, '', 'published', '01e9a645-1a71-4a58-a397-c02e89f48d6b', '1ba19e0d-5b70-499b-b3eb-826f4c53bbc1', 'https://www.rf.se/bidrag-och-stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.346153+00', '2026-08-28 16:47:43.346153+00'),
	('805dba6f-8a84-474f-b1ef-00e78cc32b42', '1951f314-9107-4859-85a5-3e1ffc1c9eb2', '86385eea-1c2c-4c52-b95b-5767b7776ac3', 'filminstitutet-kortfilmsstod', 'Svenska Filminstitutet — Stöd till kort- och dokumentärfilm', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Filminstitutet ger utvecklings- och produktionsstöd till kort- och dokumentärfilm. Stödet söks normalt av ett produktionsbolag; beslut fattas av filmkonsulent. Villkor och ansökningstider publiceras per stödform.', 'Konstnärligt värdefull svensk film.', 'project_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.filminstitutet.se/sv/sok-stod/', 'none', 'assisted', 8, '', 'published', '03cf67dc-9f61-4365-b592-4a3faaf5fa16', 'accbbb60-a6c4-4a9e-8d66-573c47a08fbc', 'https://www.filminstitutet.se/sv/sok-stod/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.355366+00', '2026-08-28 16:47:43.355366+00'),
	('3290e2a0-539a-44c9-80be-82402afd2e32', '65cab2d3-8ed7-4f3d-b411-e992ee767527', '9c659da9-8f29-4130-b79a-7aed207c8a67', 'kulturradet-skapande-skola', 'Kulturrådet — Skapande skola', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Skapande skola söks av skolhuvudmän (kommuner, fristående skolor) för konst- och kulturinsatser i förskoleklass och grundskola, genomförda av professionella kulturaktörer. Årlig ansökningsomgång.', 'Att alla elever ska få möta professionell konst och kultur.', 'public_grant', '["municipality", "school", "company"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 6, '', 'published', '66756fd2-d9c5-4cdd-bbd8-a93996fca724', 'f829d377-d561-41dc-bdad-54c4bbfdad42', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.36386+00', '2026-08-28 16:47:43.36386+00'),
	('da1946b5-a2e0-44b1-8e2d-a4494b931069', 'b40fc693-72c5-4db6-b526-3d90e5c71542', '43fdcb9a-936c-4df8-bd12-485cda62a5af', 'formas-oppna-utlysningen', 'Formas — Årliga öppna utlysningen', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Formas årliga öppna utlysning finansierar forskningsprojekt inom miljö, areella näringar och samhällsbyggande. Söks av disputerade forskare vid svenska lärosäten och forskningsinstitut. Årlig omgång med publicerade tider.', 'Kunskap för hållbar utveckling.', 'public_grant', '["university", "public_body"]', '["SE"]', '["environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.formas.se/soka-finansiering.html', 'none', 'assisted', 20, '', 'published', '0f06cdcd-4471-4ebc-b91e-c579b6a65d4c', 'c73c00b5-fb6d-477d-9edf-50d03c255b50', 'https://www.formas.se/soka-finansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.371368+00', '2026-08-28 16:47:43.371368+00'),
	('e56d4968-2a0b-4341-a023-687c65252a21', '2af8212e-c128-4afd-b6a5-1bb58f570480', '4f84fa2f-b3b8-45f7-8963-59f34d115a49', 'tillvaxtverket-affarsutvecklingscheckar', 'Tillväxtverket — Affärsutvecklingscheckar (internationalisering/digitalisering)', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Affärsutvecklingscheckarna hjälper små företag att köpa extern kompetens för att utvecklas internationellt eller digitalt. Checkarna administreras regionalt; belopp, andelar och tider varierar per region — kontrollera din regions aktuella utlysning.', 'Stärkt konkurrenskraft i små företag.', 'public_grant', '["company"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', 50, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) när regionens omgång är öppen.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 6, '', 'published', 'ae230a2d-9e4f-40a9-a4b4-aa73863f1dc9', '010560b3-b6a8-43e5-891a-1dd6a84a5a90', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.379491+00', '2026-08-28 16:47:43.379491+00'),
	('b89d0a79-5729-402b-b155-12550695a9df', '48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', 'd14a4669-808a-4d9e-b7d3-13dca757c8b4', 'jordbruksverket-startstod-unga', 'Jordbruksverket — Startstöd till unga jordbrukare', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Startstödet riktar sig till unga som startar eller tar över jordbruks-, trädgårds- eller rennäringsföretag. Kräver bl.a. åldersgräns, utbildning/erfarenhet och en affärsplan. Ansökan görs i Jordbruksverkets e-tjänst med e-legitimation.', 'Generationsväxling och föryngring i jordbruket.', 'public_grant', '["individual", "company"]', '["SE"]', '["agriculture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation; fullmakt kan användas).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', '65792f62-e4ec-4820-b069-eae665e38d37', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.388737+00', '2026-08-28 16:47:43.388737+00'),
	('027e6a6f-7636-4707-8c71-f27e0457b548', '48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', '2f5b3222-e391-49d0-82c6-dfe8c1511693', 'jordbruksverket-investeringsstod', 'Jordbruksverket — Investeringsstöd för jordbruk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Investeringsstöd kan sökas för t.ex. djurstallar, växthus, energieffektivisering och miljöåtgärder i jordbruksföretag. Villkor, stödandelar och regionala prioriteringar framgår av aktuell stödinformation hos Jordbruksverket.', 'Konkurrenskraftigt och hållbart jordbruk.', 'public_grant', '["company", "individual", "economic_association"]', '["SE"]', '["agriculture", "environment"]', NULL, NULL, 'SEK', 40, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', 'cddaa3dc-642f-4aa5-ac5b-55954532b2c5', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.396896+00', '2026-08-28 16:47:43.396896+00'),
	('b058fe01-d6a6-4ab9-8d5c-ee52b1ad4d57', '2e4a8215-55b6-4bae-9c7b-5173033498fd', '60ba73c4-c4bb-4401-8b79-48a9c4d8a734', 'esf-kompetensutveckling', 'Svenska ESF-rådet — ESF+ projektstöd för kompetensutveckling och omställning', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Svenska ESF-rådet utlyser projektmedel ur Europeiska socialfonden+ i regionala och nationella utlysningar, t.ex. kompetensutveckling för anställda och insatser för personer långt från arbetsmarknaden. Villkor och medfinansieringskrav framgår per utlysning i utlysningsplanen.', 'En väl fungerande och inkluderande arbetsmarknad.', 'eu_grant', '["company", "association", "municipality", "region", "public_body", "university"]', '["SE"]', '["education", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i ESF-rådets Projektrummet när en utlysning är öppen.', 'https://www.esf.se/utlysningar/', 'none', 'assisted', 15, '', 'published', 'fe8b7e43-f655-4cfb-bf9b-50720896199d', 'c693105c-87f6-4682-bc70-944b3fef850b', 'https://www.esf.se/utlysningar/utlysningsplan/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.40544+00', '2026-08-28 16:47:43.40544+00'),
	('cccd491e-c09b-44f1-9b2c-7cc2ff793563', '54d7945e-c5de-4cdc-a17c-03e74eacb119', '2e0214c5-bc98-4daf-ba7a-ddc1efb03665', 'energimyndigheten-industriklivet', 'Energimyndigheten — Industriklivet', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Industriklivet stödjer forskning, förstudier och investeringar som minskar industrins processrelaterade utsläpp samt negativa utsläpp (t.ex. bio-CCS). Söks löpande eller i utlysningar via Mina sidor.', 'Industrins klimatomställning.', 'public_grant', '["company", "university", "public_body"]', '["SE"]', '["energy", "environment"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 15, '', 'published', 'd74a05df-4698-450a-9ed5-1e3104e401c6', 'a3c5e9c5-897e-46f7-bbc9-f5dd695ad8dd', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.412945+00', '2026-08-28 16:47:43.412945+00'),
	('47050bfe-fe63-44b9-9d0d-a3ad22c31e4b', '8454639d-e196-4bc6-8906-115581d8abf9', '35295335-afcd-4564-b0f2-c559f3c2cb76', 'naturvardsverket-klimatklivet', 'Naturvårdsverket — Klimatklivet', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Klimatklivet ger investeringsstöd till företag, kommuner, regioner och organisationer för åtgärder som ger stor klimatnytta per stödkrona — t.ex. laddinfrastruktur, biogas och energikonvertering. Ansökningsomgångar öppnar flera gånger per år.', 'Minskade växthusgasutsläpp.', 'public_grant', '["company", "municipality", "region", "association", "economic_association", "public_body"]', '["SE"]', '["environment", "energy"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänst när en omgång är öppen (kräver e-legitimation).', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 8, '', 'published', '4b106d63-5df1-45f8-b078-cc1357d7c3d3', '878725ca-49df-431e-9ba7-270171aabfd8', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.421103+00', '2026-08-28 16:47:43.421103+00'),
	('20b995ab-dcc3-4ff1-98aa-d37ca9033a98', '8454639d-e196-4bc6-8906-115581d8abf9', '1b381737-5231-42e7-ac32-446f3a1a604a', 'naturvardsverket-lona', 'Naturvårdsverket — Lokala naturvårdssatsningen (LONA)', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'LONA ger upp till 50 % (våtmarksprojekt upp till 90 %) i bidrag till naturvårds- och friluftslivsprojekt. Kommunen ansöker hos länsstyrelsen, men lokala föreningar kan initiera projekt genom sin kommun.', 'Lokalt naturvårdsengagemang och friluftsliv.', 'public_grant', '["municipality"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Kommunen ansöker via länsstyrelsen; föreningar initierar via sin kommun.', 'https://www.naturvardsverket.se/bidrag/', 'none', 'assisted', 6, '', 'published', 'd825651c-ba5d-4b2c-82a1-3d85d1ca1771', '878725ca-49df-431e-9ba7-270171aabfd8', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.428826+00', '2026-08-28 16:47:43.428826+00'),
	('7c8849f1-c71d-47c4-9d5a-8a88fd90ca1b', '0ded917d-009b-42d5-a18f-e242792290b2', '0e491e0f-1e5b-4276-aa3e-f88eed6711f7', 'mucf-solidaritetskaren-volontarprojekt', 'MUCF — Europeiska solidaritetskåren: volontärprojekt', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Europeiska solidaritetskåren finansierar volontärprojekt där unga 18–30 år gör volontärtjänst i ett annat land eller i Sverige. Organisationen behöver en kvalitetsmärkning (Quality Label) och ett OID. MUCF är nationellt programkontor.', 'Ungas engagemang och solidaritet i Europa.', 'eu_grant', '["association", "municipality", "public_body"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login, OID och Quality Label).', 'https://www.mucf.se/bidrag', 'eu_login', 'assisted', 12, '', 'published', '041c356b-7ccc-4b52-a39d-c4e6762a54ba', 'dafb453c-1945-40e8-b7f9-0aa1f567d087', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.437325+00', '2026-08-28 16:47:43.437325+00'),
	('259307c5-971f-49ed-bb4c-fbfb5da04092', '20fe6a7f-8008-448a-82de-cbeab6ce4453', '9a6a3f23-489a-4332-b423-963e41b45038', 'erasmus-mobilitet-skola-vuxen', 'Erasmus+ — Mobilitet för skola och vuxenutbildning (KA1)', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Erasmus+ KA1 ger skolor, förskolor och vuxenutbildningsorganisationer stöd för kompetensutveckling utomlands — jobbskuggning, kurser och undervisningsuppdrag samt elevmobilitet. UHR är nationellt programkontor för utbildningsdelen. Kräver OID; årliga ansökningsomgångar.', 'Internationalisering av svensk utbildning.', 'eu_grant', '["school", "municipality", "company", "association", "public_body"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://www.uhr.se/internationella-mojligheter/', 'eu_login', 'assisted', 12, '', 'published', '1936a8d2-cec1-4c17-b040-0da71a58e6a5', 'db93de02-be04-4784-a1e0-ad82d2209be1', 'https://www.uhr.se/internationella-mojligheter/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.445321+00', '2026-08-28 16:47:43.445321+00'),
	('f42356cc-af7f-43f5-b6d3-65f346ebaf23', '5b109bb1-21c2-4c94-b827-a9b7fb5cb271', '28510ab2-6b62-4d7e-9013-2a2a43a58a37', 'kreativa-europa-samarbetsprojekt', 'Kreativa Europa — Europeiska samarbetsprojekt (kultur)', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Kreativa Europas kulturprogram finansierar samarbetsprojekt mellan kulturorganisationer i minst tre programländer. Kulturrådet är kontaktkontor i Sverige för kulturdelen. Ansökan görs i EU:s Funding & Tenders-portal; årliga utlysningar.', 'Europeiskt kultursamarbete och cirkulation av konstnärliga verk.', 'eu_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', 80, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s Funding & Tenders-portal (kräver EU Login och PIC/OID).', 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'eu_login', 'assisted', 25, '', 'published', '6aafcb2e-b9e8-4f17-a5ff-defd41e2f2f9', NULL, 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.453322+00', '2026-08-28 16:47:43.453322+00'),
	('d956dd79-a84d-41d1-96f4-8c5a8060eaf4', '65cab2d3-8ed7-4f3d-b411-e992ee767527', '8bd87d05-5309-4acb-a72b-388e00f5a89a', 'kulturradet-verksamhetsbidrag-scenkonst', 'Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Verksamhetsbidraget riktar sig till professionella fria scenkonstaktörer med kontinuerlig verksamhet av hög kvalitet. Söks i årlig omgång hos Kulturrådet.', 'Ett starkt fritt scenkonstliv i hela landet.', 'public_grant', '["association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 10, '', 'published', 'b8c1e898-e113-4fbf-9cbe-eaf684e91c71', 'f829d377-d561-41dc-bdad-54c4bbfdad42', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.461065+00', '2026-08-28 16:47:43.461065+00'),
	('b2190d47-1e0d-43e0-a5a4-b8a81ea3bf28', '038dc199-d889-4fc3-bcce-bb5d5828489b', '797019fc-ec2e-480e-8d79-ca614e7fe369', 'vinnova-planeringsbidrag-eu', 'Vinnova — Planeringsbidrag för EU-ansökningar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Vinnova erbjuder återkommande planeringsbidrag som sänker tröskeln för svenska organisationer att söka EU-finansiering, t.ex. inför Horisont Europa-utlysningar och EIC Accelerator. Villkor per aktuell utlysning.', 'Ökat svenskt deltagande i EU:s ramprogram.', 'public_grant', '["company", "university", "public_body", "association"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst när en omgång är öppen.', 'https://www.vinnova.se/soka-finansiering/', 'none', 'assisted', 6, '', 'published', 'ee6fb7ab-26c4-426b-b14c-133cbb7af1a0', 'ea88f28a-0118-4f1f-b2cd-6dbf0fcafb27', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.468673+00', '2026-08-28 16:47:43.468673+00'),
	('611827d1-2a2f-4337-b7cc-36a338cddc1c', '0ded917d-009b-42d5-a18f-e242792290b2', 'f8108597-9614-48e6-874a-8b6d52352736', 'mucf-organisationsbidrag', 'MUCF — Organisationsbidrag till barn- och ungdomsorganisationer', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Organisationsbidraget söks årligen av nationella barn- och ungdomsorganisationer som uppfyller krav på bl.a. medlemsantal, åldersstruktur, demokratisk uppbyggnad och geografisk spridning. Villkoren framgår av förordning och MUCF:s anvisningar.', 'Ett starkt och självständigt ungdomscivilsamhälle.', 'public_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', 'ebfc802b-a39d-40b6-9839-459d81f4c21f', 'dafb453c-1945-40e8-b7f9-0aa1f567d087', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.475833+00', '2026-08-28 16:47:43.475833+00'),
	('c45af3be-f486-48fc-b149-9477b15c967d', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9303dc84-5c57-465d-8b1a-89247490924f', 'fk-bostadsbidrag-barnfamiljer', 'Försäkringskassan — Bostadsbidrag till barnfamiljer', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Bostadsbidrag kan lämnas till barnfamiljer med lägre inkomster som betalar för sitt boende. Beloppet beror på inkomst, boendekostnad, bostadens storlek och antal barn. Ansökan görs hos Försäkringskassan; bidraget är preliminärt och stäms av mot taxerad inkomst i efterhand.', 'Ekonomisk trygghet i boendet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '6f2fdf23-7414-4394-967a-6bdae8e3f1b7', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.483016+00', '2026-08-28 16:47:43.483016+00'),
	('108084ff-abea-4a87-a4dc-f97ae3a27245', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9748d32c-c017-4304-9a54-7d453fd4f1ec', 'fk-underhallsstod', 'Försäkringskassan — Underhållsstöd', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Underhållsstöd kan lämnas när föräldrar inte bor ihop, barnet bor varaktigt hos dig och den andra föräldern inte betalar underhållsbidrag eller betalar mindre än stödets nivå. Ansökan görs hos Försäkringskassan.', 'Barnets försörjning när underhåll uteblir.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'ae276987-6cec-4a47-a152-78ab12042e60', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.552796+00', '2026-08-28 16:47:43.552796+00'),
	('7e5a1725-9d8f-4c48-8552-30fdca51f679', '97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'c1f8f383-0b86-43b0-a127-f1fb17bb2cc1', 'pm-bostadstillagg', 'Pensionsmyndigheten — Bostadstillägg för pensionärer', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Bostadstillägg kan lämnas till den som tar ut hel allmän pension och har låga inkomster i förhållande till sin boendekostnad. Många som har rätt till tillägget söker det aldrig — det är värt att kontrollera. Ansökan görs hos Pensionsmyndigheten.', 'Ekonomisk trygghet i boendet för pensionärer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Pensionsmyndighetens webbplats (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', 'b5c59e0d-534c-48d8-8a1f-09a0f0228618', '859b11f9-48f5-462c-8d17-4fa4e96490bc', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.56054+00', '2026-08-28 16:47:43.56054+00'),
	('b691194a-5662-4b92-ae67-d269520b3ba5', '97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'f4071887-6148-4891-9bf5-6805f96530e0', 'pm-aldreforsorjningsstod', 'Pensionsmyndigheten — Äldreförsörjningsstöd', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Äldreförsörjningsstöd kan lämnas från riktåldern för pension (67 år från 2026) till den som inte får sina grundläggande behov tillgodosedda genom pension och andra inkomster. Prövas tillsammans med bostadstillägg. Ansökan görs hos Pensionsmyndigheten.', 'Skälig levnadsnivå för äldre.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Pensionsmyndigheten (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '88252518-5c37-4a41-9f5a-d95c72b56088', '859b11f9-48f5-462c-8d17-4fa4e96490bc', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.568548+00', '2026-08-28 16:47:43.568548+00'),
	('1c1b1a91-8462-451d-91c2-77de891b1132', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', '6ba25293-14ce-4c54-868a-d43c3274d747', 'af-stod-start-naringsverksamhet', 'Arbetsförmedlingen — Stöd till start av näringsverksamhet', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Den som är inskriven som arbetssökande och bedöms ha goda förutsättningar att driva företag kan få stöd (aktivitetsstöd) under verksamhetens uppstartsfas. Beslut fattas av Arbetsförmedlingen efter prövning av affärsplanen.', 'Väg från arbetslöshet till egen försörjning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Arbetsförmedlingen — kontakta din handläggare.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 5, '', 'published', '297cced3-229c-40e7-88e7-e0788b03d6b3', '41f72dfd-557c-4ed1-ad62-e3d82f0fe611', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.576691+00', '2026-08-28 16:47:43.576691+00'),
	('e72d6913-57e1-43df-9f01-bbc5cb984f37', '92c3e316-3ea3-4605-96d8-ac921962531b', '64373393-8894-4580-9827-e359266f87cc', 'region-glasogonbidrag-barn', 'Din region — Glasögonbidrag för barn och unga (8–19 år)', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Alla regioner är enligt lag (2016:35) skyldiga att ge bidrag för glasögon eller kontaktlinser till barn och unga 8–19 år som behöver synhjälpmedel. Lagen fastställer inget nationellt belopp — nivån bestäms per region och varierar. Ansökan sker oftast via optikern eller direkt till regionen — rutinerna skiljer sig, kontrollera din regions sidor och aktuellt belopp via 1177.', 'Alla barn ska ha råd med de synhjälpmedel de behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Vanligen via optikern eller regionens e-tjänst — se din regions rutin på 1177.se.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', '91367da5-eb94-462c-a915-859dcb92a480', '2c0e3ba2-095a-48af-a3aa-8e732d7d16c0', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.491628+00', '2026-08-28 16:47:43.491628+00'),
	('9c5c0677-c887-460e-9403-d38a6cd49c3b', '739ddcb9-3861-4824-a21c-ab9f8444b694', '0590f51c-e8de-4b94-b63f-b57045fdb9a3', 'majblomman-bidrag-barn', 'Majblomman — Bidrag till barn i familjer där pengarna inte räcker', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Majblommans lokalföreningar ger bidrag till barn upp till 18 år i familjer med knapp ekonomi. Det kan gälla en fritidsaktivitet, en cykel, kläder, en klassresa eller något annat konkret som barnet behöver. Ansökan görs till den lokala majblommeföreningen där barnet bor och kan göras av vårdnadshavare eller via t.ex. skolsköterska.', 'Alla barn ska kunna delta i sådant som andra barn tar för givet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan till din lokala majblommeförening via majblomman.se.', 'https://majblomman.se/', 'none', 'assisted', 1, '', 'published', '1606ae54-dcba-4804-828d-b2929eecb2ae', 'f84c6fe9-956b-4481-bd52-4de6df8d382e', 'https://majblomman.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.499155+00', '2026-08-28 16:47:43.499155+00'),
	('3e9fc384-cb77-47cc-83e1-8fa1ac5d46da', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', '9390f49d-b383-4a7f-bc9c-4c141f778fc1', 'kommun-skolskjuts', 'Din kommun — Skolskjuts i grundskolan', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Elever i grundskolan har enligt skollagen (10 kap. 32 §) rätt till kostnadsfri skolskjuts från hemkommunen om det behövs på grund av färdvägens längd, trafikförhållanden, funktionsnedsättning eller någon annan särskild omständighet. Kommunerna har egna avståndsgränser och rutiner — ansökan görs hos barnets hemkommun.', 'Alla barn ska kunna ta sig till skolan utan kostnad när vägen är lång eller osäker.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos barnets hemkommun (e-tjänst eller blankett).', 'https://www.skolverket.se/', 'none', 'assisted', 1, '', 'published', '36deee5f-3ae3-46ec-a7d5-c6101a33ea5c', '2130fbf0-58c8-456a-9b11-13dcf448063d', 'https://www.skolverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.507349+00', '2026-08-28 16:47:43.507349+00'),
	('6b3d5f61-1792-4df1-b070-3aed89eb08ed', 'ddddeb50-a0b4-43cf-8f80-ace23e32c364', '93607834-064f-4515-ba2c-72c2b3c1d345', 'musikverket-projektbidrag', 'Statens musikverk — Projektbidrag till musiklivet', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Musikverket fördelar projektbidrag till professionella samarbetsprojekt i det fria musiklivet, med särskilt fokus på förnyelse och jämställdhet. Utlysningsomgångar publiceras på musikverket.se.', 'Ett vitalt fritt musikliv.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://musikverket.se/', 'none', 'assisted', 6, '', 'published', '35a9dacb-4cb9-418e-9a60-75aa0ce4eee0', 'd400be3a-853f-4b67-90e2-aa987f39cdb3', 'https://musikverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.646228+00', '2026-08-28 16:47:43.646228+00'),
	('52d29ddf-4657-4c28-a11a-54f03e30c815', '5b109bb1-21c2-4c94-b827-a9b7fb5cb271', 'c419f4c1-4e40-4753-b00b-6b5d68d8ddad', 'erasmus-ka2-smaskaliga-partnerskap', 'Erasmus+ — Småskaliga partnerskap (KA2)', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Småskaliga partnerskap är utformade för att sänka tröskeln för organisationer som är nya i Erasmus+: färre krav, schablonbelopp (typiskt 30 000 eller 60 000 euro) och minst en partner i ett annat programland.', 'Bredda deltagandet i europeiskt samarbete.', 'eu_grant', '["association", "municipality", "school", "public_body"]', '["SE"]', '["education", "youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/', 'eu_login', 'assisted', 10, '', 'published', '9c525c28-5abd-4197-8a53-0b69aa85addc', NULL, 'https://erasmus-plus.ec.europa.eu/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.652372+00', '2026-08-28 16:47:43.652372+00'),
	('472c46ce-e481-4a4c-8d30-b71afae838e0', '2af8212e-c128-4afd-b6a5-1bb58f570480', 'b1838f75-5f8f-4eca-b7c7-910839f379e3', 'tillvaxtverket-regionalt-investeringsstod', 'Tillväxtverket — Regionalt investeringsstöd', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Regionalt investeringsstöd kan delfinansiera större investeringar i stödområde A och B. Stödandel beror på område och företagsstorlek. Söks via Min ansökan.', 'Hållbar tillväxt i regioner med geografiska lägesnackdelar.', 'public_grant', '["company"]', '["SE"]', '[]', NULL, NULL, 'SEK', 35, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) innan investeringen påbörjas.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 12, '', 'published', 'cefaa1d0-3018-46e2-adfa-0c1e4a6f9d71', '010560b3-b6a8-43e5-891a-1dd6a84a5a90', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.660234+00', '2026-08-28 16:47:43.660234+00'),
	('b13c4d37-8afa-4d0f-a101-db60e7c57e23', '65cab2d3-8ed7-4f3d-b411-e992ee767527', '7de38bdc-b695-4b1c-89a5-c9a9dfee9400', 'kulturradet-inkopsstod-bibliotek', 'Kulturrådet — Inköpsstöd till folk- och skolbibliotek', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Inköpsstödet söks av kommuner för att stärka bibliotekens utbud av litteratur för barn och unga. Årlig omgång.', 'Läsfrämjande och tillgång till litteratur.', 'public_grant', '["municipality"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 3, '', 'published', '3867be9d-d906-4ed4-97df-b20d0eac4782', 'f829d377-d561-41dc-bdad-54c4bbfdad42', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.668021+00', '2026-08-28 16:47:43.668021+00'),
	('e47f4f7e-960b-4ca1-8433-17d893b598b6', '65cab2d3-8ed7-4f3d-b411-e992ee767527', '7de38bdc-b695-4b1c-89a5-c9a9dfee9400', 'kulturradet-litteraturstod', 'Kulturrådet — Litteraturstöd (efterhandsstöd till utgivning)', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Litteraturstödet är ett efterhandsstöd som förlag söker för utgiven kvalitetslitteratur inom olika kategorier. Beslut fattas av arbetsgrupper med litterär expertis.', 'Bredd och kvalitet i svensk bokutgivning.', 'public_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', 'd08c2d56-a15f-405c-9b71-638655bda9d2', 'f829d377-d561-41dc-bdad-54c4bbfdad42', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.673566+00', '2026-08-28 16:47:43.673566+00'),
	('d4a55c7f-be0c-4096-b0ed-78e72d1a4b6c', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'e3888daa-bf8f-4672-b44d-d94759936620', 'kommun-elevresor-gymnasiet', 'Din kommun — Stöd för elevresor på gymnasiet', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Enligt lag (1991:1110) ska hemkommunen ansvara för kostnader för dagliga resor mellan bostaden och gymnasieskolan för elever med studiehjälp, om färdvägen är minst sex kilometer. Stödet ges oftast som busskort/resekort och söks hos hemkommunen.', 'Gymnasieelever ska kunna ta sig till skolan oavsett var de bor.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos elevens hemkommun, vanligen inför varje läsår.', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'none', 'assisted', 1, '', 'published', '1761a961-9059-4354-9284-a544365b146b', '759ec253-3e9c-4727-9d8e-4e4bae1b5a7b', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.51501+00', '2026-08-28 16:47:43.51501+00'),
	('f8588186-bfbf-4d9f-9bb9-324af29ce3a3', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9303dc84-5c57-465d-8b1a-89247490924f', 'fk-bostadsbidrag-unga', 'Försäkringskassan — Bostadsbidrag för unga (18–28 år)', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Unga mellan 18 och 28 år utan barn kan få bostadsbidrag om inkomsten är låg och boendekostnaden tillräckligt hög. Ansökan görs hos Försäkringskassan.', 'Ekonomisk trygghet i boendet för unga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'a3563f3a-d075-47ee-a823-98e78286d6b9', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.520489+00', '2026-08-28 16:47:43.520489+00'),
	('c485b4d4-3d50-4c35-875a-ce9002efa611', 'b19978da-e163-485b-bd60-e9abde43de1a', '6dcdb903-ce71-43f3-b3e9-9ab064fa9758', 'kommun-forsorjningsstod', 'Socialtjänsten — Försörjningsstöd (ekonomiskt bistånd)', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Försörjningsstöd kan beviljas av socialtjänsten i din kommun när du inte kan försörja dig själv och saknar tillgångar som kan täcka behoven. Stödet prövas individuellt utifrån hela hushållets ekonomi, och du förväntas först ha sökt andra ersättningar du kan ha rätt till. Ansökan görs hos din kommun.', 'Skälig levnadsnivå enligt socialtjänstlagen.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos socialtjänsten i din kommun — ofta via kommunens e-tjänst eller ett bokat besök.', 'https://www.socialstyrelsen.se/', 'none', 'assisted', 2, '', 'published', 'aff84572-b5c6-4e05-8c67-cb4d4562fec6', 'c768c72b-e535-4458-a8f7-0503ce0cfde0', 'https://www.socialstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.527284+00', '2026-08-28 16:47:43.527284+00'),
	('babd9fea-fa8f-4936-b290-124358e4b5cc', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'dcacc780-35c0-4682-981c-4dbbb3dbb787', 'csn-studiemedel', 'CSN — Studiemedel (bidrag och studielån)', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Studiemedel består av en bidragsdel och en frivillig lånedel för studier i Sverige eller utomlands. Kraven gäller bl.a. studiernas omfattning, tidigare studieresultat och ålder. Ansökan görs hos CSN.', 'Ekonomiska möjligheter att studera.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Mina sidor hos CSN (kräver e-legitimation).', 'https://www.csn.se/', 'eid', 'assisted', 1, '', 'published', '111bea21-c920-4e23-8a14-2993f8156fe1', '0afd3980-2de3-4551-9b4c-7b8bcd7faa64', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.534472+00', '2026-08-28 16:47:43.534472+00'),
	('22206727-625a-48d8-859b-16410fa4c5a5', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'f6ab0e84-9602-4181-abd4-8a9a07464dd8', 'fk-aktivitetsersattning', 'Försäkringskassan — Aktivitetsersättning vid nedsatt arbetsförmåga', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Aktivitetsersättning kan lämnas till den som är 19–29 år och har arbetsförmågan nedsatt med minst en fjärdedel under minst ett år. Läkarutlåtande krävs. Ansökan görs hos Försäkringskassan; beslutet fattas efter medicinsk utredning.', 'Ekonomisk trygghet vid långvarigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan tillsammans med läkarutlåtande.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '60971a5d-9e4c-49a9-9ba0-143c624f1327', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.544112+00', '2026-08-28 16:47:43.544112+00'),
	('9cc5adbb-8a6b-4245-a813-6f134a5dcf1d', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'faa1120a-659c-4ca0-ab5d-c8f1b8bde272', 'csn-omstallningsstudiestod', 'CSN — Omställningsstudiestöd', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Omställningsstudiestödet riktar sig till dig som arbetat länge och vill studera för att bli mer attraktiv på arbetsmarknaden. Kräver bl.a. etablering på arbetsmarknaden (arbetade år) och att utbildningen stärker din framtida ställning. Söktrycket är högt och handläggningstiderna kan vara långa.', 'Omställning och kompetensutveckling mitt i arbetslivet.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN; omställningsorganisationen kan komplettera med kollektivavtalat stöd.', 'https://www.csn.se/', 'eid', 'assisted', 3, '', 'published', 'dbb48703-bebb-40b2-b578-5baf67cddd72', '0afd3980-2de3-4551-9b4c-7b8bcd7faa64', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.584328+00', '2026-08-28 16:47:43.584328+00'),
	('adf1bd42-188c-4d57-ae52-9ddf6c4ac159', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', '803df75c-31a5-4c9c-991a-1aa956df0141', 'kommun-bostadsanpassningsbidrag', 'Din kommun — Bostadsanpassningsbidrag', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Bostadsanpassningsbidraget är ett kommunalt bidrag enligt lag för den som har en bestående funktionsnedsättning och behöver anpassa sin permanentbostad. Intyg från t.ex. arbetsterapeut krävs. Ansökan görs hos kommunen.', 'Självständigt liv i egen bostad.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos din kommun, ofta via e-tjänst eller blankett, med intyg.', 'https://www.boverket.se/sv/bidrag--garantier/', 'none', 'assisted', 3, '', 'published', '325f7cf9-3ccc-490f-b792-44709b0ef73f', NULL, 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.593788+00', '2026-08-28 16:47:43.593788+00'),
	('cd410d27-411f-4959-ab88-af4bd10df01c', '9e528334-1289-461e-b22b-dde99ab62b73', '671834f0-d904-4bac-96ce-a06310211ee4', 'konstnarsnamnden-kulturbryggan', 'Konstnärsnämnden — Kulturbryggan', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Kulturbryggan är Konstnärsnämndens stöd till kulturprojekt som är nyskapande i förhållande till etablerade uttryck och strukturer. Söks i utlysningsomgångar av både enskilda och organisationer.', 'Förnyelse och experiment i kulturlivet.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 8, '', 'published', '0473ef56-37e0-48a6-befa-1869e569dfc6', '2faad5bd-34a0-434d-a858-a7329d65b8ab', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.601629+00', '2026-08-28 16:47:43.601629+00'),
	('df148f5f-dfdb-415c-86f6-2c63d1fe4f01', 'e86450a5-3347-4eb3-99c3-02a88fe076c3', 'c2907a3c-6547-496f-9f3b-08334fdd097e', 'raa-kulturarvsbidrag', 'Riksantikvarieämbetet — Bidrag till kulturarvsarbete', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Riksantikvarieämbetet fördelar årligen bidrag till ideellt kulturarvsarbete — t.ex. hembygdsrörelsen och arbetslivsmuseer. Årlig ansökningsomgång.', 'Ett levande och tillgängligt kulturarv.', 'public_grant', '["association", "foundation"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.raa.se/', 'none', 'assisted', 6, '', 'published', 'bfac0fb4-7424-47f9-a45e-d1bf0600e76f', '2e6ec0fd-fae7-4365-bd00-1d494491daa4', 'https://www.raa.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.60922+00', '2026-08-28 16:47:43.60922+00');
INSERT INTO public.funding_opportunities VALUES
	('ba23f3f6-01d4-4f65-a19b-0d845c8d9f09', '2cd0f3a7-8580-4aad-aa3a-f13ea4ae6c26', 'f041652b-771e-4214-9bd2-47bd4923647a', 'si-creative-force', 'Svenska institutet — Creative Force', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Creative Force ger stöd till svenska organisationers samarbetsprojekt med partner i vissa länder, där kultur eller media används som verktyg för demokrati, jämlikhet och yttrandefrihet. Länderlista och villkor per utlysning.', 'Demokrati och yttrandefrihet genom kultur och media.', 'project_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://si.se/', 'none', 'assisted', 10, '', 'published', 'a8ef5f70-c604-452d-a0ed-0a903ba84238', 'bbcf86ac-a0b6-4ef2-82b0-2b12cf7f8a0d', 'https://si.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.616709+00', '2026-08-28 16:47:43.616709+00'),
	('e0ec6da9-da13-4a74-9a33-5cc324a28e79', 'a0d58015-0790-41cb-911c-41318d27d722', '4dd4a8bb-9d45-4b5a-a4c4-eff1607b4f81', 'nordisk-kulturfond-projektstod', 'Nordisk kulturfond — Projektstöd', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Nordisk kulturfond stödjer projekt som utvecklar konst- och kulturlivet i Norden och involverar flera nordiska länder. Flera ansökningsfrister per år.', 'Ett dynamiskt nordiskt konst- och kulturliv.', 'project_grant', '["individual", "association", "company", "public_body"]', '["SE", "DK", "NO", "FI", "IS"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.nordiskkulturfond.org/', 'none', 'assisted', 8, '', 'published', 'c569c037-84cb-4e6e-8bd1-57615c8c7247', 'a28a95a6-80ed-4f43-bcd9-84df55b10b02', 'https://www.nordiskkulturfond.org/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.624866+00', '2026-08-28 16:47:43.624866+00'),
	('158ef93d-29f8-4450-a2d2-894ca61e7722', '83bc1100-03b7-42e8-b09e-c5738e28c0c2', '2f7d4309-4d38-40d8-bfc3-ba8404e1d52c', 'vr-projektbidrag', 'Vetenskapsrådet — Projektbidrag (fri forskning)', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Vetenskapsrådets projektbidrag söks av disputerade forskare via svenska lärosäten i årliga utlysningar per ämnesområde.', 'Forskning av högsta vetenskapliga kvalitet.', 'public_grant', '["university"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.vr.se/', 'none', 'assisted', 20, '', 'published', '1e94b2a6-bb2b-40e8-b956-2776b5180c40', 'e6107c19-ebfa-470e-ad61-86b372740d66', 'https://www.vr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.631944+00', '2026-08-28 16:47:43.631944+00'),
	('29dcb82a-e2f5-43d4-852c-c1d867708146', 'fb49244f-7aae-42f9-8036-d3d6cb09b1c5', '096a8bf8-c820-48fa-82f2-4d5adfcaa629', 'postkodstiftelsen-projektstod', 'Svenska Postkodstiftelsen — Projektstöd', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Postkodstiftelsen stödjer ideella organisationer med projekt inom bl.a. mänskliga rättigheter, miljö och kultur. Ansökan kan lämnas löpande via stiftelsens webbplats.', 'Positiv förändring för människor och miljö.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "environment", "culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://postkodstiftelsen.se/', 'none', 'assisted', 8, '', 'published', 'c1173908-5143-4ffa-906b-11200367f433', 'e813a35c-5fce-4384-b612-b0d119c7ec89', 'https://postkodstiftelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.638922+00', '2026-08-28 16:47:43.638922+00'),
	('70a9b78d-5186-47cc-b281-ab71b789453b', '269cc233-2da3-475a-aae0-c92d7484743a', '0885374e-aad6-4945-9fe6-35085c0ca5d7', 'lansstyrelsen-bygdemedel', 'Länsstyrelsen — Bygdemedel', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Bygdemedel är ersättningar från vattenkraft (och i vissa län vindkraft) som återförs till berörda bygder. Föreningar och kommuner kan söka för t.ex. samlingslokaler, leder och bygdeutveckling. Villkor varierar per län.', 'Lokal utveckling i berörda bygder.', 'public_grant', '["association", "municipality"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos länsstyrelsen i ditt län, ofta via e-tjänst.', 'https://www.lansstyrelsen.se/', 'eid', 'assisted', 6, '', 'published', '55effc30-4b09-4973-bc68-b2b37a016589', '10143241-df4e-4418-ab5e-8cf89dd802fb', 'https://www.lansstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.67958+00', '2026-08-28 16:47:43.67958+00'),
	('42115092-8860-4bfc-a937-69b8903a9171', '5eb8a5d0-d180-4378-b961-ec973438d851', '53596bfa-e60f-446c-81ef-70ec67c85d8c', 'migrationsverket-atervandringsbidrag', 'Migrationsverket — Stöd vid frivillig återvandring', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Den som har uppehållstillstånd som flykting eller skyddsbehövande (samt vissa anhöriga) och frivilligt vill återvandra permanent kan ansöka om bidrag till resa och återetablering. Schablonbeloppen är beslutade att höjas väsentligt från 2026 — kontrollera aktuella belopp och villkor hos Migrationsverket innan beslut. Beslutet att återvandra är oåterkalleligt i bidragshänseende: uppehållstillståndet återkallas normalt.', 'Möjliggöra frivillig, värdig återvandring för den som själv vill.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Migrationsverket före utresan.', 'https://www.migrationsverket.se/', 'none', 'assisted', 3, '', 'published', '361e4ad1-761c-4ef6-9241-885e67163836', 'f0680383-cee7-4560-b62e-174eca39a431', 'https://www.migrationsverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.686334+00', '2026-08-28 16:47:43.686334+00'),
	('408124bd-81fd-4bc2-8d89-0784b9e4cebf', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', '92fb36d0-71c8-4130-993c-a12c28dff814', 'af-eures-targeted-mobility', 'EURES — Targeted Mobility Scheme (jobb i annat EU-land)', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU:s riktade rörlighetsprogram hjälper arbetssökande från 18 år att ta anställning i ett annat EU-/EES-land. Stödet kan omfatta bidrag till intervjuresa, flytt, språkkurs och erkännande av kvalifikationer — beloppen är schabloner per insats och land och varierar per programperiod. Vägen in är EURES-rådgivarna hos Arbetsförmedlingen.', 'Rörlighet på den europeiska arbetsmarknaden.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta en EURES-rådgivare via Arbetsförmedlingen — ansökan görs innan flytten/resan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '9f86ca47-a944-4a10-a925-ddff0a1fa196', '41f72dfd-557c-4ed1-ad62-e3d82f0fe611', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.693731+00', '2026-08-28 16:47:43.693731+00'),
	('e7cfd942-b468-489d-8f64-bae97ef6f4ce', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'dcacc780-35c0-4682-981c-4dbbb3dbb787', 'csn-utlandsstudier', 'CSN — Studiemedel för utlandsstudier', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Studiemedel kan tas med till studier utomlands på utbildningar som uppfyller CSN:s krav. Utöver ordinarie bidrag och lån finns merkostnadslån för undervisningsavgifter, resor och försäkring. Utbildningen och skolan ska vara godkänd — kontrollera i CSN:s tjänst innan du tackar ja till en plats.', 'Göra utlandsstudier möjliga oavsett privatekonomi.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN med e-legitimation.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', 'ca53125f-87f1-4abe-9cef-49ed6f841089', '0afd3980-2de3-4551-9b4c-7b8bcd7faa64', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.700068+00', '2026-08-28 16:47:43.700068+00'),
	('976d0e20-afcc-4377-99a4-cd023e0befdd', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'e4d4b02c-f6c0-4f7f-8de1-29097e92e7f2', 'fk-omvardnadsbidrag', 'Försäkringskassan — Omvårdnadsbidrag för barn med funktionsnedsättning', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Omvårdnadsbidrag kan lämnas till vårdnadshavare för barn med funktionsnedsättning som behöver mer omvårdnad och tillsyn än jämnåriga. Bidraget finns i fyra nivåer utifrån barnets sammanlagda behov och kan lämnas till och med juni det år barnet fyller 19. Ansökan görs hos Försäkringskassan; ett läkarutlåtande om barnets funktionsnedsättning behövs.', 'Ge föräldrar ekonomiskt utrymme för den extra omvårdnad barnet behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); läkarutlåtande bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', 'be7bc715-0774-41fc-9612-b11b3497739f', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.706728+00', '2026-08-28 16:47:43.706728+00'),
	('597a859b-ce74-471b-ba79-d62c4fc2e620', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '80e458d9-5bf3-49e3-b3c8-ef5181a85b94', 'fk-merkostnadsersattning', 'Försäkringskassan — Merkostnadsersättning vid funktionsnedsättning', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Merkostnadsersättning kan lämnas när en varaktig funktionsnedsättning medför merkostnader — t.ex. slitage, hjälpmedel, resor eller särskild kost. Ersättningen finns i fem nivåer och kräver att merkostnaderna når upp till en lägsta nivå per år (knuten till prisbasbeloppet). Både vuxna med funktionsnedsättning och vårdnadshavare för barn kan ansöka hos Försäkringskassan.', 'Utjämna de extra kostnader en funktionsnedsättning medför.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); merkostnaderna specificeras.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', '46ecf2a5-a0d5-4b0e-9784-c0131a2dac97', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.714504+00', '2026-08-28 16:47:43.714504+00'),
	('c4e32053-e869-4d3b-8b5b-04f04df1b881', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9824f38d-5eed-491f-b7f5-a9f216da9c2d', 'fk-bilstod', 'Försäkringskassan — Bilstöd vid funktionsnedsättning', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Bilstöd kan lämnas till den som har en varaktig funktionsnedsättning med stora svårigheter att förflytta sig på egen hand eller att använda allmänna kommunikationer — och till föräldrar till barn med sådan funktionsnedsättning. Stödet består av flera delar: grundbidrag, inkomstprövat anskaffningsbidrag och anpassningsbidrag för särskild utrustning. Nytt bilstöd kan normalt beviljas först efter nio år.', 'Göra det möjligt att förflytta sig självständigt när kollektivtrafik inte fungerar.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande om funktionsnedsättningen och körkortsuppgifter behövs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '4c46110d-9a01-4984-baf8-11bf8f21ce69', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.721135+00', '2026-08-28 16:47:43.721135+00'),
	('185f4fb0-1fba-40a0-908a-978aea1978a1', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9748d32c-c017-4304-9a54-7d453fd4f1ec', 'fk-foraldrapenning', 'Försäkringskassan — Föräldrapenning', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Föräldrapenning kan tas ut av föräldrar (och i vissa fall andra vårdnadshavare) för tid med barnet, från graviditet tills barnet fyllt tolv år, med flest dagar under de första åren. Ersättningens nivå beror på din inkomst och vilken typ av dagar du tar ut; nivåer och regler framgår hos Försäkringskassan. Ansökan görs i efterhand för de dagar du varit ledig.', 'Möjliggöra föräldraledighet med ersättning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'e8e7d64d-3e89-49ff-9264-a4eb51dafa54', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.814756+00', '2026-08-28 16:47:43.814756+00'),
	('daff24a1-b151-4351-8ec9-e5224d7c4f7d', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '44cdc8e8-98da-465e-b1e5-37f343620f5b', 'fk-narstaendepenning', 'Försäkringskassan — Närståendepenning', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Närståendepenning kan lämnas när du avstår från förvärvsarbete för att vårda eller vara nära en närstående med en sjukdom som innebär ett påtagligt hot mot livet. Ersättningen kan betalas i upp till 100 dagar per person som vårdas (dagarna kan delas mellan flera närstående). Läkarutlåtande om den sjukes tillstånd och den sjukes samtycke krävs.', 'Ingen ska behöva välja mellan sin försörjning och att finnas hos en svårt sjuk anhörig.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarutlåtande och den sjukes samtycke bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '4fcbe456-c821-4743-9ffa-da179e18bedc', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.727+00', '2026-08-28 16:47:43.727+00'),
	('5f582c0c-7448-41df-b77f-cf44696d0d02', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'cf0f5a1e-2966-4b84-9d3c-44c25317f757', 'af-etableringsersattning', 'Arbetsförmedlingen — Etableringsersättning för nyanlända', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Den som nyligen fått uppehållstillstånd (som skyddsbehövande eller vissa anhöriga) och är 20–66 år kan delta i Arbetsförmedlingens etableringsprogram och få etableringsersättning under tiden. Den som har barn eller bor ensam i egen bostad kan även få etableringstillägg respektive bostadsersättning. Arbetsförmedlingen beslutar om programmet; Försäkringskassan beslutar om och betalar ut ersättningen.', 'Försörjning under de första årens etablering i arbets- och samhällslivet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen; ersättningen ansöks sedan hos Försäkringskassan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '54552a36-7632-42ae-83f7-73a781f8f4bc', '41f72dfd-557c-4ed1-ad62-e3d82f0fe611', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.733373+00', '2026-08-28 16:47:43.733373+00'),
	('658fac41-629c-4902-b5e2-4c201e230864', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', '9987b7a6-bf27-4b06-aed8-097ff0a769bf', 'csn-hemutrustningslan', 'CSN — Hemutrustningslån för nyanlända', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Hemutrustningslån kan lämnas till flyktingar och vissa anhöriga som tagits emot i en kommun och behöver utrusta ett första hem i Sverige. Lånet söks hos CSN inom två år från det första kommunmottagandet, har låg ränta och betalas tillbaka enligt en plan som tar hänsyn till inkomst. Det är ett lån — inte ett bidrag — och ska betalas tillbaka.', 'Ett fungerande hem från start, utan att behöva vända sig till dyra krediter.', 'loan', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos CSN; kommunmottagandet styr vilka som kan söka.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', 'dd7ece44-c5e1-46ba-821d-dbc30d2afee0', '0afd3980-2de3-4551-9b4c-7b8bcd7faa64', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.740283+00', '2026-08-28 16:47:43.740283+00'),
	('91771ac6-ec58-4d1e-a0ea-041dd9f3e02d', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', '1426f55b-089d-43dc-b05c-232bc53c4da3', 'csn-studiestartsstod', 'CSN — Studiestartsstöd för arbetslösa med kort utbildning', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Studiestartsstöd är ett rent bidrag (ingen lånedel) för den som är 25–60 år, har varit arbetslös, har kort tidigare utbildning och behöver studera på grundskole- eller gymnasienivå för att stärka sina chanser till jobb. Stödet kan lämnas i upp till 50 veckor. Hemkommunen bedömer om du tillhör målgruppen; ansökan görs sedan hos CSN.', 'Sänka tröskeln till studier för den som behöver dem mest.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta hemkommunen (målgruppsbedömning) och ansök därefter hos CSN.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '49c28c9b-bca6-4465-bf44-d229596f662c', '0afd3980-2de3-4551-9b4c-7b8bcd7faa64', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.747351+00', '2026-08-28 16:47:43.747351+00'),
	('833b544b-024d-4a38-a847-fc7d6bccf87f', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'aabbe483-1158-487d-8230-d33b4eb7aece', 'csn-inackorderingstillagg', 'CSN — Inackorderingstillägg för gymnasieelever som bor på studieorten', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Elever på fristående gymnasieskolor och folkhögskolor som måste inackordera sig på studieorten på grund av lång eller besvärlig resväg kan få inackorderingstillägg från CSN. Går eleven på en kommunal gymnasieskola är det i stället hemkommunen som ger stöd till inackordering — kontrollera med kommunen. Tillägget söks för varje läsår.', 'Gymnasievalet ska inte begränsas av var i landet utbildningen finns.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos CSN (fristående skola/folkhögskola) eller hos hemkommunen (kommunal skola), inför varje läsår.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', '9c57c5dc-f500-4b28-bb8d-7f44e6d907d4', '0afd3980-2de3-4551-9b4c-7b8bcd7faa64', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.754607+00', '2026-08-28 16:47:43.754607+00'),
	('127cd502-3a44-4e5c-b6ac-705177a82fb2', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'f006896e-b118-483c-8575-6f6394384aec', 'kommun-foreningsbidrag', 'Din kommun — Föreningsbidrag (aktivitets-, lokal- och startbidrag)', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'I stort sett alla kommuner ger bidrag till lokala föreningar — vanligast är aktivitetsstöd per deltagartillfälle för barn- och ungdomsverksamhet, bidrag till lokalhyra och startbidrag för nya föreningar. Regler, belopp och ansökningstider skiljer sig åt mellan kommuner; ansökan görs hos kultur- och fritidsförvaltningen i den kommun där föreningen är verksam.', 'Ett levande lokalt föreningsliv med låga trösklar för deltagande.', 'public_grant', '["association"]', '["SE"]', '["civil_society", "sports", "culture", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos kommunens kultur- och fritidsförvaltning — rutiner och tider varierar per kommun.', 'https://www.skr.se/', 'none', 'assisted', 2, '', 'published', 'f2358d86-2b16-48e5-b004-b8671cf99533', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.763097+00', '2026-08-28 16:47:43.763097+00'),
	('fd4a9197-c27b-4ee7-afda-35d979f2098e', '92c3e316-3ea3-4605-96d8-ac921962531b', '6bdf461e-daff-41fb-90bf-3bb493ec9a8a', 'region-kulturstod', 'Din region — Regionala kulturstöd och projektbidrag', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Alla regioner fördelar egna kulturstöd — projektbidrag, arrangörsstöd och stipendier — inom kultursamverkansmodellen. Stöden riktar sig till kulturaktörer med förankring i regionen och söks direkt hos regionens kulturförvaltning. Utlysningar, belopp och tider varierar per region; kontrollera din regions kultursidor.', 'Ett professionellt och tillgängligt kulturliv i hela regionen.', 'public_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos regionens kulturförvaltning — utlysningar publiceras på regionens webbplats.', 'https://www.skr.se/', 'none', 'assisted', 4, '', 'published', '4c4a56b5-4643-408e-90cb-7cd9dc63f754', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.769684+00', '2026-08-28 16:47:43.769684+00'),
	('da0b2f8a-cd17-4b6c-bd60-d74d341e3867', 'ce150a61-c7fa-4a55-a4ea-7404acaf806b', '49d91e5c-dc2c-4f9c-9a7e-3c086fbb526c', 'sparbanksstiftelsen-projektstod', 'Sparbanksstiftelsen i ditt område — Bidrag till lokala projekt', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Sparbanksstiftelserna förvaltar sparbanksrörelsens överskott och delar ut bidrag till projekt som utvecklar det lokala samhället — ofta inom idrott, kultur, utbildning, forskning och näringslivsutveckling. Varje stiftelse beslutar självständigt och stödjer bara projekt i den egna sparbankens verksamhetsområde. Hitta stiftelsen där ni verkar och sök enligt dess rutiner.', 'Lokal utveckling där sparbanken verkar.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "sports", "culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos den sparbanksstiftelse vars område ni verkar i — rutiner varierar per stiftelse.', 'https://www.sparbankerna.se/', 'none', 'assisted', 3, '', 'published', 'fbab902a-60db-4fab-afc5-750d75747bd6', '75fdf4fb-df1d-4c0d-826d-176612520cc0', 'https://www.sparbankerna.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.778119+00', '2026-08-28 16:47:43.778119+00'),
	('602e8c20-26ef-42ef-b464-943e26285d97', '48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', '6c700471-cc1d-4889-97ee-39a981b62bf9', 'leader-lokalt-ledd-utveckling', 'Leader — Projektstöd för lokalt ledd utveckling på landsbygden', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Genom Leader finansieras lokala utvecklingsprojekt på landsbygden med medel från EU och svenska staten. Sverige är indelat i ett fyrtiotal leaderområden med egna utvecklingsstrategier; projektidén söks hos leaderområdets kansli, prioriteras av den lokala LAG-styrelsen och beslutas formellt av Jordbruksverket. Föreningar, företag, kommuner och andra lokala aktörer kan söka.', 'Utveckling av landsbygden utifrån lokala behov och idéer.', 'eu_grant', '["association", "company", "municipality"]', '["SE"]', '["rural", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta ditt leaderområdes kansli; ansökan lämnas i Jordbruksverkets e-tjänst.', 'https://jordbruksverket.se/', 'none', 'assisted', 8, '', 'published', '1ca2a1b4-67ce-4a63-ad75-4d688ae4624e', '543634dc-b143-427e-a062-5871354631b2', 'https://jordbruksverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.785872+00', '2026-08-28 16:47:43.785872+00'),
	('51fc07c0-1ded-4386-8f99-03d11629b0be', '941d14c3-80a3-47c5-b090-5f80d2dfb3ee', '7e1ed609-62d7-42e0-be79-119e5b6c3384', 'forte-projektbidrag', 'Forte — Projektbidrag för forskning om hälsa, arbetsliv och välfärd', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Forte är det statliga forskningsrådet för hälsa, arbetsliv och välfärd och utlyser projektbidrag, postdokbidrag och programstöd inom sina områden. Bidragen söks av disputerade forskare och förvaltas av ett svenskt lärosäte eller annan godkänd medelsförvaltare. Årliga öppna utlysningar publiceras på forte.se.', 'Kunskap som förbättrar människors hälsa, arbetsliv och välfärd.', 'public_grant', '["university"]', '["SE"]', '["research"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan i Fortes ansökningssystem Prisma, via medelsförvaltaren.', 'https://forte.se/', 'none', 'assisted', 15, '', 'published', '45902229-90a8-4d9a-885b-326053b8c0fc', '65a92248-85b2-4b93-972d-acedc89e5fe4', 'https://forte.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.792209+00', '2026-08-28 16:47:43.792209+00'),
	('9abe0ec7-4906-4df3-a304-b2d9e3b89128', '52156ca5-09a4-4f2a-bc70-e9a02eea9e16', 'd529c0e2-24b3-45a9-80c0-b6c6de6cedb6', 'radiohjalpen-projektbidrag', 'Radiohjälpen — Projektbidrag ur insamlingskampanjerna', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Radiohjälpen fördelar insamlade medel till projekt som drivs av svenska ideella organisationer med 90-konto: internationella humanitära insatser och utvecklingsprojekt (t.ex. Världens Barn, Musikhjälpen) samt nationella insatser för barn och unga med funktionsnedsättning eller kronisk sjukdom (Victoriafonden — där kan även t.ex. kuratorer söka aktivitets- och lägerbidrag för enskilda barn). Utlysningar och villkor finns på radiohjalpen.se.', 'Insamlade medel ska nå fram genom seriösa organisationer.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan enligt respektive utlysning på radiohjalpen.se.', 'https://www.radiohjalpen.se/', 'none', 'assisted', 6, '', 'published', 'c4f332b7-c6bf-468c-bf6b-30b147d6cfc6', '56ffc194-b39e-4484-923b-c9688862c6c3', 'https://www.radiohjalpen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.798513+00', '2026-08-28 16:47:43.798513+00'),
	('652cedfe-d4d6-4ddb-9b05-591f9b242d85', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9748d32c-c017-4304-9a54-7d453fd4f1ec', 'fk-barnbidrag', 'Försäkringskassan — Barnbidrag', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Barnbidrag lämnas för barn som bor i Sverige, normalt utan ansökan — det betalas ut automatiskt från månaden efter födseln eller flytten till Sverige. Ansökan behövs i vissa fall, till exempel när barnet flyttar hit eller vid ändrad utbetalningsmottagare. Beloppet per barn och månad framgår hos Försäkringskassan. Från och med det andra barnet lämnas även flerbarnstillägg (egen post).', 'Ekonomisk grundtrygghet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt; ansökan i särskilda fall på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '9f7fa308-2850-4760-a3dc-35bc3704c57f', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.803174+00', '2026-08-28 16:47:43.803174+00'),
	('81cee800-ca0d-49c5-99cf-b427d825f169', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9748d32c-c017-4304-9a54-7d453fd4f1ec', 'fk-flerbarnstillagg', 'Försäkringskassan — Flerbarnstillägg', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Flerbarnstillägg lämnas automatiskt till den som får barnbidrag för två eller fler barn — ingen separat ansökan behövs i normalfallet. Tillägget ökar med antalet barn; nivåerna framgår hos Försäkringskassan. Den som har barn över 16 år som studerar kan i vissa fall behöva anmäla för fortsatt flerbarnstillägg.', 'Förstärkt stöd till familjer med flera barn.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt tillsammans med barnbidraget.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'f3abcacd-b0c1-4a0b-a67e-49e5aa6c93a1', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.809022+00', '2026-08-28 16:47:43.809022+00'),
	('685ea7e3-f383-43c2-a141-e51527089429', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '9748d32c-c017-4304-9a54-7d453fd4f1ec', 'fk-tillfallig-foraldrapenning', 'Försäkringskassan — Tillfällig föräldrapenning (vab)', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Tillfällig föräldrapenning — i dagligt tal vab — kan lämnas när du avstår från arbete för att vårda ett sjukt barn som är under 12 år (i vissa fall äldre). Ersättningen baseras på din inkomst; nivå och antal dagar framgår hos Försäkringskassan. Anmäl första dagen och ansök i efterhand; läkarintyg krävs från åttonde dagen.', 'Göra det möjligt att vårda sjukt barn utan att förlora hela inkomsten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Anmäl och ansök på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '233f8c3a-07e9-4696-b41c-d2ab14604c92', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.820451+00', '2026-08-28 16:47:43.820451+00'),
	('a437dd6c-d28b-4140-b3ae-da8fb7ac47a1', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'c44b42f3-937d-457c-ba3b-1dba40ea75b1', 'fk-sjukpenning', 'Försäkringskassan — Sjukpenning', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Sjukpenning kan lämnas när sjukdom sätter ned din arbetsförmåga med minst en fjärdedel. Anställda får normalt sjuklön från arbetsgivaren de första två veckorna; därefter kan sjukpenning från Försäkringskassan ta vid. Egenföretagare och arbetslösa ansöker direkt. Läkarintyg krävs efter en tid; nivåer och regler framgår hos Försäkringskassan.', 'Försörjning när arbetsförmågan är nedsatt av sjukdom.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarintyg bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '9371605c-6535-4054-b13b-4ac3e95e08c6', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.828216+00', '2026-08-28 16:47:43.828216+00'),
	('d175bd2f-e19c-49ae-8b6a-dd143eaf42ec', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'c44b42f3-937d-457c-ba3b-1dba40ea75b1', 'fk-sjukersattning', 'Försäkringskassan — Sjukersättning', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Sjukersättning kan lämnas till den som troligen aldrig kommer att kunna arbeta heltid på grund av sjukdom, skada eller funktionsnedsättning. Arbetsförmågan ska vara stadigvarande nedsatt med minst en fjärdedel i förhållande till hela arbetsmarknaden. Ersättningen kan vara inkomstrelaterad eller på garantinivå; regler och nivåer framgår hos Försäkringskassan.', 'Långsiktig försörjning vid varaktigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande krävs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '9e5129ca-11ba-4cf6-85b3-f1cd8682951c', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.834353+00', '2026-08-28 16:47:43.834353+00'),
	('28766ff2-b66a-47c8-bb9c-f3cdcf4e25a5', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '54c402e7-3bf2-4c53-8d1d-023ee5888a75', 'fk-aktivitetsstod', 'Försäkringskassan — Aktivitetsstöd', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Aktivitetsstöd lämnas till den som deltar i ett program hos Arbetsförmedlingen, till exempel jobb- och utvecklingsgarantin eller arbetsmarknadsutbildning. Arbetsförmedlingen anvisar programmet; Försäkringskassan beslutar om och betalar ut ersättningen, som bland annat beror på om du uppfyller villkoren för a-kassa. Yngre deltagare kan i stället få utvecklingsersättning.', 'Försörjning under program som stärker vägen till arbete.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Programmet anvisas av Arbetsförmedlingen; ersättningen ansöks månadsvis hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '8bc1ad86-3af1-42e1-9ad7-9de5eddc6d04', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.84212+00', '2026-08-28 16:47:43.84212+00'),
	('783ec11e-1526-4b41-9736-b7711321ed1a', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', '1803591a-0533-4f74-b60c-7176bd08edde', 'fk-tandvardsbidrag', 'Försäkringskassan — Allmänt tandvårdsbidrag (ATB)', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Det allmänna tandvårdsbidraget gäller alla från det år de fyller 24 och används automatiskt som avdrag när du besöker en ansluten tandläkare eller tandhygienist — ingen ansökan behövs. Beloppet beror på ålder och kan sparas ett år; nivåerna framgår hos Försäkringskassan. Den med särskilda behov kan därutöver ha rätt till särskilt tandvårdsbidrag.', 'Sänka tröskeln till regelbunden tandvård.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — säg till hos tandvården att du vill använda bidraget.', 'https://www.forsakringskassan.se/privatperson', 'none', 'assisted', 1, '', 'published', '057c916f-2476-4255-bd40-0f41df3a8a48', '58e04980-ec0f-417b-abaa-baaac302d786', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.849212+00', '2026-08-28 16:47:43.849212+00'),
	('4ea30ea4-e71b-4804-a0f8-2480c73f0a14', '97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'edf43923-366d-41e4-af42-0c6e5fb61175', 'pm-garantipension', 'Pensionsmyndigheten — Garantipension', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Garantipension är ett grundskydd i den allmänna pensionen för den som haft låg eller ingen inkomstgrundad pension. Den betalas normalt ut automatiskt när du ansöker om allmän pension från riktåldern — ingen separat ansökan behövs om du bor i Sverige. Nivån beror på inkomstpensionens storlek, civilstånd och försäkringstid; detaljerna framgår hos Pensionsmyndigheten.', 'Lägsta rimliga pensionsnivå oavsett tidigare inkomster.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingår i ansökan om allmän pension hos Pensionsmyndigheten; prövas automatiskt.', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '0d248f63-d4b6-443a-8f85-3d38c9939296', '859b11f9-48f5-462c-8d17-4fa4e96490bc', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.855507+00', '2026-08-28 16:47:43.855507+00'),
	('820353b3-2aa9-4fd2-ae80-e721161abe42', '92c3e316-3ea3-4605-96d8-ac921962531b', '180a4baf-a304-40c0-82cf-aadce7b7b3f1', 'region-hogkostnadsskydd-vard', 'Din region — Högkostnadsskydd för sjukvård', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Högkostnadsskyddet innebär att du under en period på tolv månader aldrig betalar mer än ett takbelopp i patientavgifter för öppen sjukvård; därefter får du frikort för resten av perioden. Registreringen sker normalt automatiskt i regionens system när du betalar. Takbeloppet fastställs årligen — se 1177 för aktuell nivå. Motsvarande skydd finns för läkemedel och sjukresor.', 'Skydda mot höga sammanlagda vårdkostnader.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — registreras normalt automatiskt i regionens system; spara kvitton vid besök i annan region.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', '18ec81a6-478c-4948-8ca6-e6f2bc6cd3f8', '2c0e3ba2-095a-48af-a3aa-8e732d7d16c0', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.862363+00', '2026-08-28 16:47:43.862363+00'),
	('7c26a054-1e5e-4a99-9c86-2de17bd7ce8f', 'd434f635-0d4d-4ba7-9e71-11227556b027', '31c21f26-986d-4ec3-95da-d71ba541cba2', 'akassa-arbetsloshetsersattning', 'Din a-kassa — Arbetslöshetsersättning (a-kassa)', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Arbetslöshetsersättning lämnas av a-kassorna till den som är arbetslös, inskriven hos Arbetsförmedlingen, aktivt söker arbete och uppfyller arbetsvillkoret. Medlemmar som uppfyllt medlemsvillkoret kan få inkomstbaserad ersättning; den som inte är medlem kan ha rätt till grundbelopp via Alfa-kassan. Vilken a-kassa som passar beror på bransch; villkor och nivåer framgår hos din a-kassa och Sveriges a-kassor.', 'Inkomsttrygghet under omställning mellan arbeten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen första arbetslösa dagen; ansök sedan hos din a-kassa (Mina sidor).', 'https://www.sverigesakassor.se/', 'eid', 'assisted', 1, '', 'published', 'e3b772f3-a09d-4674-b9e9-0c6d855003e2', 'ed812804-18fe-4d86-a2b5-996083bbd0f5', 'https://www.sverigesakassor.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.87001+00', '2026-08-28 16:47:43.87001+00'),
	('a0f3f498-2aea-41a5-9864-f2b40848a27d', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'fa3a1d82-807f-40d8-983b-365cc004c5cc', 'af-nystartsjobb', 'Arbetsförmedlingen — Nystartsjobb', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Nystartsjobb ger arbetsgivare ett bidrag motsvarande en del av lönekostnaden vid anställning av personer som varit arbetslösa en längre tid, är nyanlända eller av andra skäl varit borta från arbetslivet. Stödets storlek och längd beror på den anställdas situation; villkoren framgår hos Arbetsförmedlingen. Anställningen ska ha marknadsmässiga villkor och beslut ska finnas innan den påbörjas.', 'Sänka tröskeln in på arbetsmarknaden för dem som stått utanför.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', 'f9eba37d-0bea-47d5-9fb5-fc43dbb68eca', '41f72dfd-557c-4ed1-ad62-e3d82f0fe611', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.875949+00', '2026-08-28 16:47:43.875949+00'),
	('08969a43-228c-421f-b5e1-43abd2f8b016', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'fa3a1d82-807f-40d8-983b-365cc004c5cc', 'af-lonebidrag', 'Arbetsförmedlingen — Lönebidrag vid nedsatt arbetsförmåga', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Lönebidrag kan lämnas till arbetsgivare som anställer (eller behåller) en person vars arbetsförmåga är nedsatt av funktionsnedsättning eller ohälsa. Bidraget kompenserar en del av lönekostnaden och kan kombineras med anpassning av arbetet; det finns i flera former (utveckling, trygghet, anställning). Nivå och längd bedöms individuellt av Arbetsförmedlingen.', 'Göra det möjligt att anställa utifrån förmåga, inte hinder.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '7b4ed6ca-3251-4168-b7e5-97ec2dad49f4', '41f72dfd-557c-4ed1-ad62-e3d82f0fe611', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 16:47:43.881229+00', '2026-08-28 16:47:43.881229+00');


--
-- Data for Name: funding_programmes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_programmes VALUES
	('fe2f3397-ede6-4fc6-a7ef-9ea3c8952a57', '65cab2d3-8ed7-4f3d-b411-e992ee767527', 'Internationellt kulturutbyte', '', '2026-08-28 16:47:43.247311+00'),
	('a83b3071-7c48-4c74-aba9-7caef932bf90', '5b109bb1-21c2-4c94-b827-a9b7fb5cb271', 'Erasmus+ Ungdom', '', '2026-08-28 16:47:43.259088+00'),
	('a2f95f69-b93e-47e3-8752-074fc90e5925', '0ded917d-009b-42d5-a18f-e242792290b2', 'Bidrag till civilsamhället', '', '2026-08-28 16:47:43.267769+00'),
	('46555705-846e-4c93-aef5-df98e2ec56dc', '038dc199-d889-4fc3-bcce-bb5d5828489b', 'Innovativa startups', '', '2026-08-28 16:47:43.276299+00'),
	('771214c1-749d-427a-8ff4-a21b3ecd4d21', '54d7945e-c5de-4cdc-a17c-03e74eacb119', 'Forskning och innovation för energiomställning', '', '2026-08-28 16:47:43.284319+00'),
	('99662e89-df5d-47c4-8e36-84cbe351d0f2', '8454639d-e196-4bc6-8906-115581d8abf9', 'Klimatinvesteringar', '', '2026-08-28 16:47:43.29244+00'),
	('31eb01be-d53a-491e-83cf-c7f164e6e089', '65cab2d3-8ed7-4f3d-b411-e992ee767527', 'Musik', '', '2026-08-28 16:47:43.303743+00'),
	('e6ca2e7a-b788-4072-b928-81abdfc60b51', '9e528334-1289-461e-b22b-dde99ab62b73', 'Internationellt kulturutbyte', '', '2026-08-28 16:47:43.312128+00'),
	('3e26a1b6-1e8d-47db-a54f-dbea4fc0798c', '9e528334-1289-461e-b22b-dde99ab62b73', 'Arbetsstipendier', '', '2026-08-28 16:47:43.318876+00'),
	('0c882fd8-ec12-4901-a8f7-c904f2101e7b', '23c3bf91-72e5-4f73-bc64-9ab786ee6225', 'Projektstöd', '', '2026-08-28 16:47:43.326171+00'),
	('ef295822-8134-49b1-b31c-4f70c20502ff', '731a7e6f-0225-4328-bf69-72d344cbbd8a', 'Stöd till allmänna samlingslokaler', '', '2026-08-28 16:47:43.334735+00'),
	('02a81d1a-9b6f-4a35-b54c-ffc421cc4214', '035aa2c1-5589-481d-9e83-6c0a9c2ac3ef', 'LOK-stöd', '', '2026-08-28 16:47:43.343349+00'),
	('86385eea-1c2c-4c52-b95b-5767b7776ac3', '1951f314-9107-4859-85a5-3e1ffc1c9eb2', 'Produktionsstöd', '', '2026-08-28 16:47:43.352347+00'),
	('9c659da9-8f29-4130-b79a-7aed207c8a67', '65cab2d3-8ed7-4f3d-b411-e992ee767527', 'Skapande skola', '', '2026-08-28 16:47:43.36144+00'),
	('43fdcb9a-936c-4df8-bd12-485cda62a5af', 'b40fc693-72c5-4db6-b526-3d90e5c71542', 'Årliga öppna utlysningen', '', '2026-08-28 16:47:43.368922+00'),
	('4f84fa2f-b3b8-45f7-8963-59f34d115a49', '2af8212e-c128-4afd-b6a5-1bb58f570480', 'Affärsutvecklingscheckar', '', '2026-08-28 16:47:43.377009+00'),
	('d14a4669-808a-4d9e-b7d3-13dca757c8b4', '48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', 'Startstöd', '', '2026-08-28 16:47:43.385989+00'),
	('2f5b3222-e391-49d0-82c6-dfe8c1511693', '48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', 'Investeringsstöd', '', '2026-08-28 16:47:43.394734+00'),
	('60ba73c4-c4bb-4401-8b79-48a9c4d8a734', '2e4a8215-55b6-4bae-9c7b-5173033498fd', 'ESF+', '', '2026-08-28 16:47:43.402673+00'),
	('2e0214c5-bc98-4daf-ba7a-ddc1efb03665', '54d7945e-c5de-4cdc-a17c-03e74eacb119', 'Industriklivet', '', '2026-08-28 16:47:43.410956+00'),
	('35295335-afcd-4564-b0f2-c559f3c2cb76', '8454639d-e196-4bc6-8906-115581d8abf9', 'Klimatklivet', '', '2026-08-28 16:47:43.418661+00'),
	('1b381737-5231-42e7-ac32-446f3a1a604a', '8454639d-e196-4bc6-8906-115581d8abf9', 'LONA', '', '2026-08-28 16:47:43.426798+00'),
	('0e491e0f-1e5b-4276-aa3e-f88eed6711f7', '0ded917d-009b-42d5-a18f-e242792290b2', 'Europeiska solidaritetskåren', '', '2026-08-28 16:47:43.434375+00'),
	('9a6a3f23-489a-4332-b423-963e41b45038', '20fe6a7f-8008-448a-82de-cbeab6ce4453', 'Erasmus+ Utbildning', '', '2026-08-28 16:47:43.44302+00'),
	('28510ab2-6b62-4d7e-9013-2a2a43a58a37', '5b109bb1-21c2-4c94-b827-a9b7fb5cb271', 'Kreativa Europa', '', '2026-08-28 16:47:43.450739+00'),
	('8bd87d05-5309-4acb-a72b-388e00f5a89a', '65cab2d3-8ed7-4f3d-b411-e992ee767527', 'Scenkonst', '', '2026-08-28 16:47:43.458729+00'),
	('797019fc-ec2e-480e-8d79-ca614e7fe369', '038dc199-d889-4fc3-bcce-bb5d5828489b', 'EU-relaterade stöd', '', '2026-08-28 16:47:43.466677+00'),
	('f8108597-9614-48e6-874a-8b6d52352736', '0ded917d-009b-42d5-a18f-e242792290b2', 'Statsbidrag till civilsamhället', '', '2026-08-28 16:47:43.473608+00'),
	('9303dc84-5c57-465d-8b1a-89247490924f', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Bostadsbidrag', '', '2026-08-28 16:47:43.480695+00'),
	('64373393-8894-4580-9827-e359266f87cc', '92c3e316-3ea3-4605-96d8-ac921962531b', 'Glasögonbidrag', '', '2026-08-28 16:47:43.488988+00'),
	('0590f51c-e8de-4b94-b63f-b57045fdb9a3', '739ddcb9-3861-4824-a21c-ab9f8444b694', 'Majblommans bidrag', '', '2026-08-28 16:47:43.49688+00'),
	('9390f49d-b383-4a7f-bc9c-4c141f778fc1', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'Skolskjuts', '', '2026-08-28 16:47:43.505097+00'),
	('e3888daa-bf8f-4672-b44d-d94759936620', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'Elevresor', '', '2026-08-28 16:47:43.512772+00'),
	('6dcdb903-ce71-43f3-b3e9-9ab064fa9758', 'b19978da-e163-485b-bd60-e9abde43de1a', 'Ekonomiskt bistånd', '', '2026-08-28 16:47:43.525308+00'),
	('dcacc780-35c0-4682-981c-4dbbb3dbb787', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'Studiemedel', '', '2026-08-28 16:47:43.532203+00'),
	('f6ab0e84-9602-4181-abd4-8a9a07464dd8', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Sjuk- och aktivitetsersättning', '', '2026-08-28 16:47:43.541488+00'),
	('9748d32c-c017-4304-9a54-7d453fd4f1ec', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Stöd till barnfamiljer', '', '2026-08-28 16:47:43.550104+00'),
	('c1f8f383-0b86-43b0-a127-f1fb17bb2cc1', '97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'Bostadstillägg', '', '2026-08-28 16:47:43.558155+00'),
	('f4071887-6148-4891-9bf5-6805f96530e0', '97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'Äldreförsörjningsstöd', '', '2026-08-28 16:47:43.566248+00'),
	('6ba25293-14ce-4c54-868a-d43c3274d747', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'Arbetsmarknadsprogram', '', '2026-08-28 16:47:43.574114+00'),
	('faa1120a-659c-4ca0-ab5d-c8f1b8bde272', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'Omställningsstudiestöd', '', '2026-08-28 16:47:43.582085+00'),
	('803df75c-31a5-4c9c-991a-1aa956df0141', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'Bostadsanpassning', '', '2026-08-28 16:47:43.591037+00'),
	('671834f0-d904-4bac-96ce-a06310211ee4', '9e528334-1289-461e-b22b-dde99ab62b73', 'Kulturbryggan', '', '2026-08-28 16:47:43.599147+00'),
	('c2907a3c-6547-496f-9f3b-08334fdd097e', 'e86450a5-3347-4eb3-99c3-02a88fe076c3', 'Bidrag till kulturarvsarbete', '', '2026-08-28 16:47:43.607025+00'),
	('f041652b-771e-4214-9bd2-47bd4923647a', '2cd0f3a7-8580-4aad-aa3a-f13ea4ae6c26', 'Creative Force', '', '2026-08-28 16:47:43.61459+00'),
	('4dd4a8bb-9d45-4b5a-a4c4-eff1607b4f81', 'a0d58015-0790-41cb-911c-41318d27d722', 'Projektstöd', '', '2026-08-28 16:47:43.622313+00'),
	('2f7d4309-4d38-40d8-bfc3-ba8404e1d52c', '83bc1100-03b7-42e8-b09e-c5738e28c0c2', 'Projektbidrag', '', '2026-08-28 16:47:43.629662+00'),
	('096a8bf8-c820-48fa-82f2-4d5adfcaa629', 'fb49244f-7aae-42f9-8036-d3d6cb09b1c5', 'Projektstöd', '', '2026-08-28 16:47:43.637103+00'),
	('93607834-064f-4515-ba2c-72c2b3c1d345', 'ddddeb50-a0b4-43cf-8f80-ace23e32c364', 'Musiksamarbeten', '', '2026-08-28 16:47:43.644118+00'),
	('c419f4c1-4e40-4753-b00b-6b5d68d8ddad', '5b109bb1-21c2-4c94-b827-a9b7fb5cb271', 'Erasmus+ Partnerskap', '', '2026-08-28 16:47:43.650251+00');
INSERT INTO public.funding_programmes VALUES
	('b1838f75-5f8f-4eca-b7c7-910839f379e3', '2af8212e-c128-4afd-b6a5-1bb58f570480', 'Regionala företagsstöd', '', '2026-08-28 16:47:43.657759+00'),
	('7de38bdc-b695-4b1c-89a5-c9a9dfee9400', '65cab2d3-8ed7-4f3d-b411-e992ee767527', 'Litteratur och bibliotek', '', '2026-08-28 16:47:43.665545+00'),
	('0885374e-aad6-4945-9fe6-35085c0ca5d7', '269cc233-2da3-475a-aae0-c92d7484743a', 'Bygdemedel', '', '2026-08-28 16:47:43.677888+00'),
	('53596bfa-e60f-446c-81ef-70ec67c85d8c', '5eb8a5d0-d180-4378-b961-ec973438d851', 'Frivillig återvandring', '', '2026-08-28 16:47:43.684154+00'),
	('92fb36d0-71c8-4130-993c-a12c28dff814', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'EURES', '', '2026-08-28 16:47:43.69166+00'),
	('e4d4b02c-f6c0-4f7f-8de1-29097e92e7f2', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Omvårdnadsbidrag', '', '2026-08-28 16:47:43.704603+00'),
	('80e458d9-5bf3-49e3-b3c8-ef5181a85b94', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Merkostnadsersättning', '', '2026-08-28 16:47:43.712339+00'),
	('9824f38d-5eed-491f-b7f5-a9f216da9c2d', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Bilstöd', '', '2026-08-28 16:47:43.719387+00'),
	('44cdc8e8-98da-465e-b1e5-37f343620f5b', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Närståendepenning', '', '2026-08-28 16:47:43.724908+00'),
	('cf0f5a1e-2966-4b84-9d3c-44c25317f757', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'Etableringsprogrammet', '', '2026-08-28 16:47:43.731666+00'),
	('9987b7a6-bf27-4b06-aed8-097ff0a769bf', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'Hemutrustningslån', '', '2026-08-28 16:47:43.738386+00'),
	('1426f55b-089d-43dc-b05c-232bc53c4da3', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'Studiestartsstöd', '', '2026-08-28 16:47:43.745373+00'),
	('aabbe483-1158-487d-8230-d33b4eb7aece', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'Inackorderingstillägg', '', '2026-08-28 16:47:43.752672+00'),
	('f006896e-b118-483c-8575-6f6394384aec', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'Föreningsbidrag', '', '2026-08-28 16:47:43.760884+00'),
	('6bdf461e-daff-41fb-90bf-3bb493ec9a8a', '92c3e316-3ea3-4605-96d8-ac921962531b', 'Regionalt kulturstöd', '', '2026-08-28 16:47:43.76768+00'),
	('49d91e5c-dc2c-4f9c-9a7e-3c086fbb526c', 'ce150a61-c7fa-4a55-a4ea-7404acaf806b', 'Projektstöd', '', '2026-08-28 16:47:43.775615+00'),
	('6c700471-cc1d-4889-97ee-39a981b62bf9', '48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', 'Leader — lokalt ledd utveckling', '', '2026-08-28 16:47:43.783338+00'),
	('7e1ed609-62d7-42e0-be79-119e5b6c3384', '941d14c3-80a3-47c5-b090-5f80d2dfb3ee', 'Projektbidrag', '', '2026-08-28 16:47:43.79035+00'),
	('d529c0e2-24b3-45a9-80c0-b6c6de6cedb6', '52156ca5-09a4-4f2a-bc70-e9a02eea9e16', 'Projektbidrag', '', '2026-08-28 16:47:43.796609+00'),
	('c44b42f3-937d-457c-ba3b-1dba40ea75b1', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Vid sjukdom', '', '2026-08-28 16:47:43.825617+00'),
	('54c402e7-3bf2-4c53-8d1d-023ee5888a75', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Vid arbetslöshet', '', '2026-08-28 16:47:43.840094+00'),
	('1803591a-0533-4f74-b60c-7176bd08edde', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Tandvårdsstöd', '', '2026-08-28 16:47:43.84736+00'),
	('edf43923-366d-41e4-af42-0c6e5fb61175', '97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'Grundskydd för pensionärer', '', '2026-08-28 16:47:43.853749+00'),
	('180a4baf-a304-40c0-82cf-aadce7b7b3f1', '92c3e316-3ea3-4605-96d8-ac921962531b', 'Patientavgifter', '', '2026-08-28 16:47:43.860209+00'),
	('31c21f26-986d-4ec3-95da-d71ba541cba2', 'd434f635-0d4d-4ba7-9e71-11227556b027', 'Arbetslöshetsförsäkringen', '', '2026-08-28 16:47:43.867552+00'),
	('fa3a1d82-807f-40d8-983b-365cc004c5cc', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'Anställningsstöd', '', '2026-08-28 16:47:43.874131+00');


--
-- Data for Name: funding_stacks; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: generated_documents; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: memberships; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: payment_milestones; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: receipts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: recovery_codes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: reminders; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: reporting_requirements; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: review_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rule_versions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rule_versions VALUES
	('183e874e-1074-4273-8fbe-d55bb5e2ded2', 'f0450019-d08e-4c9e-91e3-6dd85bf9faba', 1, '[{"id": "kr-rb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-rb-h2", "op": "in", "kind": "hard", "expected": ["individual", "association", "company"], "factPath": "applicant.type", "description": "Sökande ska vara yrkesverksam kulturskapare, grupp eller organisation"}, {"id": "kr-rb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam inom kulturområdet", "evidenceKinds": ["cv"], "intakeQuestion": "Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?"}, {"id": "kr-rb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska avse internationellt kulturutbyte", "evidenceKinds": ["invitation"], "intakeQuestion": "Innehåller projektet en internationell resa eller ett internationellt utbyte?"}, {"id": "kr-rb-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Kulturprojekt"}, {"id": "kr-rb-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}, {"id": "kr-rb-w3", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "project.bringsKnowledgeBack", "description": "Kunskapen tas tillvara i Sverige", "intakeQuestion": "Kommer erfarenheterna att användas i din verksamhet i Sverige?"}]', '[{"id": "kr-rb-b1", "type": "max_requested", "amountMinor": 5000000, "description": "Sökt belopp bör inte överstiga 50 000 kr för resebidrag."}]', '[{"id": "kr-rb-e1", "kind": "cv", "mandatory": true, "description": "CV eller konstnärlig meritförteckning"}, {"id": "kr-rb-e2", "kind": "invitation", "mandatory": true, "description": "Inbjudan eller bekräftelse från mottagande part"}, {"id": "kr-rb-e3", "kind": "budget", "mandatory": false, "description": "Resebudget"}]', '2026-08-28 16:47:43.254633+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.254633+00'),
	('56f181a0-75b2-4975-acfc-82030d967243', '1874eee9-afc9-4037-86b4-4ad5d0855398', 1, '[{"id": "er-yx-h1", "op": "in", "kind": "hard", "expected": ["association", "informal_group", "municipality"], "factPath": "applicant.type", "description": "Sökande ska vara en organisation eller informell ungdomsgrupp"}, {"id": "er-yx-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska nationella programkontoret"}, {"id": "er-yx-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge13to30", "description": "Deltagarna ska vara 13–30 år", "intakeQuestion": "Är deltagarna i utbytet mellan 13 och 30 år?"}, {"id": "er-yx-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.durationDays5to21", "description": "Utbytet ska vara 5–21 dagar exklusive resdagar", "intakeQuestion": "Pågår utbytet 5–21 dagar (exklusive resdagar)?"}, {"id": "er-yx-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partnergrupp i ett annat programland krävs", "intakeQuestion": "Har ni en partnergrupp i ett annat land?"}, {"id": "er-yx-m4", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID (Organisation ID)", "intakeQuestion": "Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?"}, {"id": "er-yx-w1", "op": "includes", "kind": "weighted", "weight": 3, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}, {"id": "er-yx-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training"], "factPath": "project.activityTypes", "description": "Utbytes-/lärandeaktiviteter"}, {"id": "er-yx-w3", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "er-yx-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från partnergrupp(er)"}, {"id": "er-yx-e2", "kind": "activity_programme", "mandatory": true, "description": "Aktivitetsprogram dag för dag"}, {"id": "er-yx-e3", "kind": "budget", "mandatory": false, "description": "Budget enligt programmets schabloner"}]', '2026-08-28 16:47:43.264145+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.264145+00'),
	('d9ec385b-9fb7-49b0-865e-81994c101f26', 'afd80f55-618e-4062-8f8f-daeb93f66780', 1, '[{"id": "mucf-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara verksam i Sverige"}, {"id": "mucf-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska ha en demokratisk uppbyggnad", "intakeQuestion": "Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?"}, {"id": "mucf-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Projektet ska rikta sig till barn eller unga", "intakeQuestion": "Riktar sig projektet till barn eller unga?"}, {"id": "mucf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["youth", "civil_society", "culture"], "factPath": "project.sector", "description": "Verksamhet inom ungdoms-/civilsamhällesområdet"}, {"id": "mucf-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.youthMembersShareOver60", "description": "Hög andel unga medlemmar", "intakeQuestion": "Är minst 60 % av medlemmarna under 26 år?"}]', '[]', '[{"id": "mucf-e1", "kind": "stadgar", "mandatory": true, "description": "Föreningens stadgar"}, {"id": "mucf-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse och årsredovisning"}, {"id": "mucf-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 16:47:43.272775+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.272775+00'),
	('7c7d8804-dc9c-4389-b1e3-6286adf87d4b', '634296e2-be34-4ea2-8d68-eebe59871c70', 1, '[{"id": "vin-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett aktiebolag"}, {"id": "vin-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "vin-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.ageYearsMax5", "description": "Bolaget ska vara ungt (typiskt max ca 5 år — se aktuell utlysning)", "intakeQuestion": "Är bolaget yngre än cirka 5 år?"}, {"id": "vin-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isInnovative", "description": "Lösningen ska vara nyskapande jämfört med befintliga alternativ", "intakeQuestion": "Är er lösning väsentligt nyskapande jämfört med vad som redan finns?"}, {"id": "vin-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.scalableInternationally", "description": "Internationell skalbarhet", "intakeQuestion": "Har lösningen internationell potential?"}, {"id": "vin-w2", "op": "in", "kind": "weighted", "weight": 1, "expected": ["innovation", "technology", "energy", "health"], "factPath": "project.sector", "description": "Prioriterade områden"}]', '[{"id": "vin-b1", "type": "max_requested", "amountMinor": 30000000, "description": "Maximalt bidrag enligt programmets ramar (se aktuell utlysning)."}]', '[{"id": "vin-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "vin-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}, {"id": "vin-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelpersoner"}]', '2026-08-28 16:47:43.281176+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.281176+00'),
	('88252518-5c37-4a41-9f5a-d95c72b56088', 'b691194a-5662-4b92-ae67-d269520b3ba5', 1, '[{"id": "pm-afs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "pm-afs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-afs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Du ska ha uppnått riktåldern för pension (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}, {"id": "pm-afs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.veryLowOrNoPension", "description": "Pension och inkomster ska inte räcka till en skälig levnadsnivå", "intakeQuestion": "Har du svårt att klara dig på din pension och dina övriga inkomster?"}]', '[]', '[]', '2026-08-28 16:47:43.571007+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.571007+00'),
	('4070e188-b5b5-4cc3-9194-286ea840a61f', '379dedc4-d5f1-4cbf-8de1-553159cd4f3d', 1, '[{"id": "em-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "em-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association", "economic_association"], "factPath": "applicant.type", "description": "Öppet för organisationer — inte privatpersoner"}, {"id": "em-m1", "op": "in", "kind": "mandatory", "expected": ["energy", "environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom energiområdet", "intakeQuestion": "Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?"}, {"id": "em-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.contributesToEnergyTransition", "description": "Bidrar till energiomställningen", "intakeQuestion": "Bidrar projektet till energiomställningen?"}]', '[]', '[{"id": "em-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "em-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget med kostnadskategorier"}]', '2026-08-28 16:47:43.289037+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.289037+00'),
	('10bba9ef-adfe-414d-9d6c-5ccec0d90112', 'd45235a4-5975-44c4-93ed-a7ca2df70085', 1, '[{"id": "nv-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "nv-m1", "op": "in", "kind": "mandatory", "expected": ["environment", "energy"], "factPath": "project.sector", "description": "Projektet ska avse miljö- eller klimatåtgärder", "intakeQuestion": "Handlar projektet om miljö- eller klimatåtgärder?"}, {"id": "nv-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.measurableEnvironmentalImpact", "description": "Mätbar miljönytta", "intakeQuestion": "Kan projektets miljönytta mätas?"}]', '[{"id": "nv-b1", "type": "max_funding_share", "percent": 50, "description": "Många av bidragen täcker upp till 50 % av kostnaden — se aktuellt bidrag."}]', '[{"id": "nv-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av åtgärden"}]', '2026-08-28 16:47:43.299614+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.299614+00'),
	('d092f792-2a38-4952-8b10-7c890802fa56', 'c15864b2-a0ca-48d2-9a0e-c34dc36dbe88', 1, '[{"id": "kr-pm-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-pm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell verksamhet inom musikområdet", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-pm-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kr-pm-w1", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["performance", "production"], "factPath": "project.activityTypes", "description": "Konsert-/produktionsverksamhet"}]', '[]', '[{"id": "kr-pm-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kr-pm-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 16:47:43.308808+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.308808+00'),
	('a8f36063-cf29-4a8d-8e68-23f8107060b5', 'd112235c-577c-497b-9af8-b703f59dc6c8', 1, '[{"id": "kn-iku-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av enskilda yrkesverksamma konstnärer"}, {"id": "kn-iku-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-iku-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?"}, {"id": "kn-iku-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Ansökan ska avse internationellt utbyte eller resa", "evidenceKinds": ["invitation"], "intakeQuestion": "Avser ansökan en internationell resa eller ett internationellt utbyte?"}, {"id": "kn-iku-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Konstnärligt projekt"}, {"id": "kn-iku-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}]', '[]', '[{"id": "kn-iku-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-iku-e2", "kind": "invitation", "mandatory": false, "description": "Inbjudan eller beskrivning av samarbetet"}]', '2026-08-28 16:47:43.316512+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.316512+00'),
	('c8595a90-6fd4-44b5-9212-46a63c113d6d', '51049cca-418a-4a92-8045-1f9d9f534642', 1, '[{"id": "kn-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stipendiet söks av enskilda konstnärer"}, {"id": "kn-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär?"}, {"id": "kn-as-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "culture", "factPath": "project.sector", "description": "Konstnärlig verksamhet"}]', '[]', '[{"id": "kn-as-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-as-e2", "kind": "project_description", "mandatory": true, "description": "Beskrivning av konstnärlig verksamhet och planer"}]', '2026-08-28 16:47:43.32301+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.32301+00'),
	('135fca02-adbf-4ed9-abdb-c17dd9b0306b', '41d02985-29ac-4f32-9f8a-d09322a8cdbc', 1, '[{"id": "af-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara en ideell organisation"}, {"id": "af-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "af-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.targetsArvsfondenGroups", "description": "Målgruppen ska vara barn, unga, äldre eller personer med funktionsnedsättning", "intakeQuestion": "Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?"}, {"id": "af-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande i förhållande till ordinarie verksamhet", "intakeQuestion": "Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?"}, {"id": "af-ps-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.targetGroupParticipates", "description": "Målgruppen ska vara delaktig i projektet", "intakeQuestion": "Är målgruppen delaktig i planering och genomförande?"}, {"id": "af-ps-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga som målgrupp"}, {"id": "af-ps-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.democraticStructure", "description": "Demokratiskt uppbyggd organisation", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}]', '[]', '[{"id": "af-ps-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "af-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning/verksamhetsberättelse"}, {"id": "af-ps-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 16:47:43.33117+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.33117+00'),
	('ee5f5ad3-1daf-4a8b-8d59-1fac9581b3b2', '92d405ee-d097-49dc-ab8e-c62faebe66a6', 1, '[{"id": "bv-as-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara förening eller stiftelse"}, {"id": "bv-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Lokalen ska ligga i Sverige"}, {"id": "bv-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.isPublicVenue", "description": "Lokalen ska vara öppen och tillgänglig för allmänheten", "intakeQuestion": "Är lokalen öppen för alla — inte bara egna medlemmar?"}, {"id": "bv-as-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse investering (bygga, köpa eller rusta upp)", "intakeQuestion": "Avser projektet att bygga, köpa eller rusta upp en lokal?"}, {"id": "bv-as-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamhet för ungdomar prioriteras"}]', '[{"id": "bv-as-b1", "type": "max_funding_share", "percent": 50, "description": "Bidraget täcker som huvudregel högst 50 % av godkänd kostnad."}]', '[{"id": "bv-as-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av lokalen och åtgärderna"}, {"id": "bv-as-e2", "kind": "budget", "mandatory": true, "description": "Kostnadskalkyl och finansieringsplan"}]', '2026-08-28 16:47:43.339732+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.339732+00'),
	('01e9a645-1a71-4a58-a397-c02e89f48d6b', '8294092e-7e66-4495-9f4d-3ed205c9a65e', 1, '[{"id": "rf-lok-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en idrottsförening"}, {"id": "rf-lok-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "rf-lok-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.memberOfSportsFederation", "description": "Föreningen ska vara ansluten till ett specialidrottsförbund inom RF", "intakeQuestion": "Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?"}, {"id": "rf-lok-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamheten ska rikta sig till barn och unga 7–25 år", "intakeQuestion": "Riktar sig verksamheten till barn och unga (7–25 år)?"}, {"id": "rf-lok-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "sports", "factPath": "project.sector", "description": "Idrottsverksamhet"}]', '[]', '[{"id": "rf-lok-e1", "kind": "activity_programme", "mandatory": true, "description": "Närvaroregistrerad aktivitetsredovisning"}]', '2026-08-28 16:47:43.349025+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.349025+00'),
	('03cf67dc-9f61-4365-b592-4a3faaf5fa16', '805dba6f-8a84-474f-b1ef-00e78cc32b42', 1, '[{"id": "sfi-kf-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Stödet söks av ett produktionsbolag"}, {"id": "sfi-kf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "sfi-kf-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett filmprojekt", "intakeQuestion": "Är projektet ett filmprojekt (kort- eller dokumentärfilm)?"}, {"id": "sfi-kf-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "production", "factPath": "project.activityTypes", "description": "Produktion/utveckling"}]', '[]', '[{"id": "sfi-kf-e1", "kind": "project_description", "mandatory": true, "description": "Synopsis/treatment och regivision"}, {"id": "sfi-kf-e2", "kind": "budget", "mandatory": true, "description": "Produktionsbudget och finansieringsplan"}, {"id": "sfi-kf-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelfunktioner"}]', '2026-08-28 16:47:43.3585+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.3585+00'),
	('66756fd2-d9c5-4cdd-bbd8-a93996fca724', '3290e2a0-539a-44c9-80be-82402afd2e32', 1, '[{"id": "kr-ss-h1", "op": "in", "kind": "hard", "expected": ["municipality", "school", "company"], "factPath": "applicant.type", "description": "Sökande ska vara skolhuvudman"}, {"id": "kr-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSchoolAuthority", "description": "Sökande ska vara huvudman för förskoleklass/grundskola", "intakeQuestion": "Är ni huvudman för förskoleklass eller grundskola?"}, {"id": "kr-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.usesProfessionalCulture", "description": "Insatserna ska genomföras av professionella kulturaktörer", "intakeQuestion": "Genomförs insatserna av professionella kulturaktörer?"}, {"id": "kr-ss-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Elever som målgrupp"}]', '[]', '[{"id": "kr-ss-e1", "kind": "project_description", "mandatory": true, "description": "Plan för kulturinsatserna"}, {"id": "kr-ss-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 16:47:43.366138+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.366138+00'),
	('0f06cdcd-4471-4ebc-b91e-c579b6a65d4c', 'da1946b5-a2e0-44b1-8e2d-a4494b931069', 1, '[{"id": "fo-ou-h1", "op": "in", "kind": "hard", "expected": ["university", "public_body"], "factPath": "applicant.type", "description": "Medlen förvaltas av lärosäte eller forskningsinstitut"}, {"id": "fo-ou-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Medelsförvaltaren ska vara svensk"}, {"id": "fo-ou-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "fo-ou-m2", "op": "in", "kind": "mandatory", "expected": ["environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom Formas ansvarsområden", "intakeQuestion": "Ligger projektet inom miljö, areella näringar eller samhällsbyggande?"}]', '[]', '[{"id": "fo-ou-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "fo-ou-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}, {"id": "fo-ou-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 16:47:43.373724+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.373724+00'),
	('e8e7d64d-3e89-49ff-9264-a4eb51dafa54', '185f4fb0-1fba-40a0-908a-978aea1978a1', 1, '[{"id": "fk-fp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-fp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha (eller vänta) barn som du avstår arbete för att ta hand om", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 16:47:43.816952+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.816952+00'),
	('ae230a2d-9e4f-40a9-a4b4-aa73863f1dc9', 'e56d4968-2a0b-4341-a023-687c65252a21', 1, '[{"id": "tv-ac-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett företag"}, {"id": "tv-ac-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Företaget ska vara registrerat i Sverige"}, {"id": "tv-ac-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSmallEnterprise", "description": "Företaget ska vara litet (typiskt 2–49 anställda — se regionens villkor)", "intakeQuestion": "Har företaget mellan cirka 2 och 49 anställda?"}, {"id": "tv-ac-m2", "op": "includes", "kind": "mandatory", "expected": "development", "factPath": "project.activityTypes", "description": "Checken ska användas för utvecklingsinsats med extern kompetens", "intakeQuestion": "Ska ni ta in extern kompetens för en utvecklingsinsats?"}, {"id": "tv-ac-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.scalableInternationally", "description": "Internationaliseringsambition"}]', '[{"id": "tv-ac-b1", "type": "max_funding_share", "percent": 50, "description": "Checken täcker normalt högst 50 % av kostnaden."}]', '[{"id": "tv-ac-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av utvecklingsinsatsen"}, {"id": "tv-ac-e2", "kind": "budget", "mandatory": true, "description": "Kostnads- och finansieringsplan"}]', '2026-08-28 16:47:43.381941+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.381941+00'),
	('65792f62-e4ec-4820-b069-eae665e38d37', 'b89d0a79-5729-402b-b155-12550695a9df', 1, '[{"id": "jv-ss-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-ss-h2", "op": "in", "kind": "hard", "expected": ["individual", "company"], "factPath": "applicant.type", "description": "Söks av person eller företag"}, {"id": "jv-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age40OrYounger", "description": "Sökande ska vara 40 år eller yngre", "intakeQuestion": "Är du 40 år eller yngre?"}, {"id": "jv-ss-m2", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Ansökan ska avse jordbruks-, trädgårds- eller rennäringsföretag", "intakeQuestion": "Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?"}, {"id": "jv-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.startingOrTakingOverFarm", "description": "Sökande ska starta eller ta över företaget för första gången", "intakeQuestion": "Startar du eller tar du över företaget för första gången?"}]', '[]', '[{"id": "jv-ss-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}, {"id": "jv-ss-e2", "kind": "budget", "mandatory": true, "description": "Ekonomisk kalkyl"}]', '2026-08-28 16:47:43.391666+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.391666+00'),
	('cddaa3dc-642f-4aa5-ac5b-55954532b2c5', '027e6a6f-7636-4707-8c71-f27e0457b548', 1, '[{"id": "jv-is-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-is-m1", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Investeringen ska avse jordbruksverksamhet", "intakeQuestion": "Avser investeringen jordbruksverksamhet?"}, {"id": "jv-is-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en fysisk investering?"}]', '[{"id": "jv-is-b1", "type": "max_funding_share", "percent": 40, "description": "Stödandelen är typiskt upp till 40 % av godkänd kostnad — se aktuellt stöd."}]', '[{"id": "jv-is-e1", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl med offerter"}]', '2026-08-28 16:47:43.399472+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.399472+00'),
	('fe8b7e43-f655-4cfb-bf9b-50720896199d', 'b058fe01-d6a6-4ab9-8d5c-ee52b1ad4d57', 1, '[{"id": "esf-ku-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "esf-ku-h2", "op": "in", "kind": "hard", "expected": ["company", "association", "municipality", "region", "public_body", "university"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "esf-ku-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensLabourMarket", "description": "Projektet ska stärka kompetens eller ställning på arbetsmarknaden", "intakeQuestion": "Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?"}, {"id": "esf-ku-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Sökande ska klara att förskottera kostnader (stöd betalas ut i efterskott)", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[{"id": "esf-ku-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med förändringsteori"}, {"id": "esf-ku-e2", "kind": "budget", "mandatory": true, "description": "Detaljerad projektbudget"}]', '2026-08-28 16:47:43.407875+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.407875+00'),
	('d74a05df-4698-450a-9ed5-1e3104e401c6', 'cccd491e-c09b-44f1-9b2c-7cc2ff793563', 1, '[{"id": "em-ik-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "em-ik-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "em-ik-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.reducesIndustrialEmissions", "description": "Projektet ska minska industrins utsläpp eller skapa negativa utsläpp", "intakeQuestion": "Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?"}, {"id": "em-ik-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["energy", "environment"], "factPath": "project.sector", "description": "Energi-/klimatprojekt"}]', '[]', '[{"id": "em-ik-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med utsläppsberäkning"}, {"id": "em-ik-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 16:47:43.415606+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.415606+00'),
	('b5c59e0d-534c-48d8-8a1f-09a0f0228618', '7e5a1725-9d8f-4c48-8552-30fdca51f679', 1, '[{"id": "pm-bt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget söks av privatpersoner"}, {"id": "pm-bt-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-bt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.receivesPension", "description": "Du ska ta ut hel allmän pension", "intakeQuestion": "Tar du ut hel allmän pension?"}, {"id": "pm-bt-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Inkomsterna ska vara låga i förhållande till boendekostnaden", "intakeQuestion": "Är hushållets inkomster låga i förhållande till boendekostnaden?"}, {"id": "pm-bt-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 16:47:43.563254+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.563254+00'),
	('4b106d63-5df1-45f8-b078-cc1357d7c3d3', '47050bfe-fe63-44b9-9d0d-a3ad22c31e4b', 1, '[{"id": "nv-kk-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Åtgärden ska genomföras i Sverige"}, {"id": "nv-kk-h2", "op": "in", "kind": "hard", "expected": ["company", "municipality", "region", "association", "economic_association", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "nv-kk-m1", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Stödet avser fysiska investeringar", "intakeQuestion": "Avser ansökan en fysisk investering?"}, {"id": "nv-kk-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.measurableEnvironmentalImpact", "description": "Klimatnyttan ska kunna beräknas", "intakeQuestion": "Kan åtgärdens utsläppsminskning beräknas?"}]', '[]', '[{"id": "nv-kk-e1", "kind": "project_description", "mandatory": true, "description": "Åtgärdsbeskrivning med klimatnyttoberäkning"}, {"id": "nv-kk-e2", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl"}]', '2026-08-28 16:47:43.423756+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.423756+00'),
	('d825651c-ba5d-4b2c-82a1-3d85d1ca1771', '20b995ab-dcc3-4ff1-98aa-d37ca9033a98', 1, '[{"id": "nv-lona-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Formell sökande är en kommun (föreningar deltar via kommunen)"}, {"id": "nv-lona-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "nv-lona-m1", "op": "eq", "kind": "mandatory", "expected": "environment", "factPath": "project.sector", "description": "Projektet ska avse naturvård eller friluftsliv", "intakeQuestion": "Avser projektet naturvård eller friluftsliv?"}]', '[{"id": "nv-lona-b1", "type": "max_funding_share", "percent": 50, "description": "Högst 50 % bidrag (våtmarksprojekt kan få upp till 90 % — se villkoren)."}]', '[{"id": "nv-lona-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 16:47:43.43107+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.43107+00'),
	('041c356b-7ccc-4b52-a39d-c4e6762a54ba', '7c8849f1-c71d-47c4-9d5a-8a88fd90ca1b', 1, '[{"id": "mucf-esc-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "mucf-esc-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "mucf-esc-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "mucf-esc-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasQualityLabel", "description": "Organisationen behöver en Quality Label för solidaritetskåren", "intakeQuestion": "Har organisationen en Quality Label (kvalitetsmärkning)?"}, {"id": "mucf-esc-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge18to30", "description": "Volontärerna ska vara 18–30 år", "intakeQuestion": "Är volontärerna mellan 18 och 30 år?"}, {"id": "mucf-esc-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}, {"id": "mucf-esc-w2", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}]', '[]', '[{"id": "mucf-esc-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med aktivitetsplan"}, {"id": "mucf-esc-e2", "kind": "partner_letter", "mandatory": false, "description": "Bekräftelse från partnerorganisation(er)"}]', '2026-08-28 16:47:43.440291+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.440291+00'),
	('1936a8d2-cec1-4c17-b040-0da71a58e6a5', '259307c5-971f-49ed-bb4c-fbfb5da04092', 1, '[{"id": "er-ka1-h1", "op": "in", "kind": "hard", "expected": ["school", "municipality", "company", "association", "public_body"], "factPath": "applicant.type", "description": "Söks av utbildningsorganisationer/huvudmän"}, {"id": "er-ka1-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "er-ka1-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "er-ka1-m2", "op": "eq", "kind": "mandatory", "expected": "education", "factPath": "project.sector", "description": "Projektet ska avse utbildningsverksamhet", "intakeQuestion": "Avser projektet skola eller vuxenutbildning?"}, {"id": "er-ka1-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Mobiliteten ska ske till ett annat programland", "intakeQuestion": "Sker mobiliteten till ett annat europeiskt land?"}]', '[]', '[{"id": "er-ka1-e1", "kind": "project_description", "mandatory": true, "description": "Mobilitetsplan"}]', '2026-08-28 16:47:43.447632+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.447632+00'),
	('6aafcb2e-b9e8-4f17-a5ff-defd41e2f2f9', 'f42356cc-af7f-43f5-b6d3-65f346ebaf23', 1, '[{"id": "ke-sp-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer inom kultursektorn"}, {"id": "ke-sp-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "ke-sp-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasThreeCountryPartnership", "description": "Minst tre partner från tre olika programländer krävs", "intakeQuestion": "Har ni partner i minst tre olika europeiska länder?"}, {"id": "ke-sp-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver registrering i EU:s system (PIC/OID)", "intakeQuestion": "Är organisationen registrerad i EU:s deltagarregister?"}, {"id": "ke-sp-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "ke-sp-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning enligt utlysningens mall"}, {"id": "ke-sp-e2", "kind": "partner_letter", "mandatory": true, "description": "Partneravtal/avsiktsförklaringar"}, {"id": "ke-sp-e3", "kind": "budget", "mandatory": true, "description": "Detaljerad budget"}]', '2026-08-28 16:47:43.455751+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.455751+00'),
	('233f8c3a-07e9-4696-b41c-d2ab14604c92', '685ea7e3-f383-43c2-a141-e51527089429', 1, '[{"id": "fk-tfp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-tfp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (normalt under 12 år) som du vårdar när det är sjukt", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 16:47:43.82259+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.82259+00'),
	('b8c1e898-e113-4fbf-9cbe-eaf684e91c71', 'd956dd79-a84d-41d1-96f4-8c5a8060eaf4', 1, '[{"id": "kr-vs-h1", "op": "in", "kind": "hard", "expected": ["association", "company"], "factPath": "applicant.type", "description": "Söks av grupper/organisationer — inte enskilda"}, {"id": "kr-vs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-vs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Verksamheten ska vara professionell", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-vs-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Verksamheten ska vara scenkonst", "intakeQuestion": "Är verksamheten scenkonst (dans, teater, musikteater)?"}, {"id": "kr-vs-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "performance", "factPath": "project.activityTypes", "description": "Publik verksamhet"}]', '[]', '[{"id": "kr-vs-e1", "kind": "project_description", "mandatory": true, "description": "Verksamhetsplan"}, {"id": "kr-vs-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse"}, {"id": "kr-vs-e3", "kind": "budget", "mandatory": true, "description": "Verksamhetsbudget"}]', '2026-08-28 16:47:43.463711+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.463711+00'),
	('ee6fb7ab-26c4-426b-b14c-133cbb7af1a0', 'b2190d47-1e0d-43e0-a5a4-b8a81ea3bf28', 1, '[{"id": "vin-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara svensk organisation"}, {"id": "vin-pb-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "vin-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansEuApplication", "description": "Bidraget ska användas för att förbereda en EU-ansökan", "intakeQuestion": "Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?"}]', '[]', '[{"id": "vin-pb-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av planerad EU-ansökan"}]', '2026-08-28 16:47:43.470755+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.470755+00'),
	('ebfc802b-a39d-40b6-9839-459d81f4c21f', '611827d1-2a2f-4337-b7cc-36a338cddc1c', 1, '[{"id": "mucf-ob-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-ob-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara nationell och verksam i Sverige"}, {"id": "mucf-ob-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Demokratisk uppbyggnad krävs", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}, {"id": "mucf-ob-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.youthMembersShareOver60", "description": "Minst 60 % av medlemmarna ska vara 6–25 år", "intakeQuestion": "Är minst 60 % av medlemmarna mellan 6 och 25 år?"}, {"id": "mucf-ob-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasNationalSpread", "description": "Verksamhet i flera län krävs", "intakeQuestion": "Har organisationen medlemsföreningar i flera län?"}]', '[]', '[{"id": "mucf-ob-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "mucf-ob-e2", "kind": "annual_report", "mandatory": true, "description": "Årsredovisning och medlemsredovisning"}]', '2026-08-28 16:47:43.478021+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.478021+00'),
	('6f2fdf23-7414-4394-967a-6bdae8e3f1b7', 'c45af3be-f486-48fc-b149-9477b15c967d', 1, '[{"id": "fk-bbf-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbf-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig (helt eller växelvis)", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-bbf-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Hushållets inkomst ska vara under inkomstgränsen", "intakeQuestion": "Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbf-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 16:47:43.485502+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.485502+00'),
	('91367da5-eb94-462c-a915-859dcb92a480', 'e72d6913-57e1-43df-9f01-bbc5cb984f37', 1, '[{"id": "reg-glas-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare"}, {"id": "reg-glas-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska vara folkbokfört i Sverige"}, {"id": "reg-glas-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "reg-glas-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childNeedsGlasses", "description": "Barnet (8–19 år) behöver glasögon eller kontaktlinser", "intakeQuestion": "Behöver något av dina barn i åldern 8–19 år glasögon eller linser?"}]', '[]', '[]', '2026-08-28 16:47:43.494071+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.494071+00'),
	('1606ae54-dcba-4804-828d-b2929eecb2ae', '9c5c0677-c887-460e-9403-d38a6cd49c3b', 1, '[{"id": "maj-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare eller t.ex. skolsköterska"}, {"id": "maj-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "maj-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (upp till 18 år) som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "maj-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childCostsStrain", "description": "Ekonomin räcker inte till sådant barnet behöver eller förväntas delta i", "intakeQuestion": "Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?"}, {"id": "maj-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "person.lowHouseholdIncome", "description": "Låg hushållsinkomst stärker ansökan"}]', '[]', '[]', '2026-08-28 16:47:43.501457+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.501457+00'),
	('36deee5f-3ae3-46ec-a7d5-c6101a33ea5c', '3e9fc384-cb77-47cc-83e1-8fa1ac5d46da', 1, '[{"id": "skjuts-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av vårdnadshavare"}, {"id": "skjuts-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "skjuts-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "skjuts-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInCompulsorySchool", "description": "Barnet går i grundskolan", "intakeQuestion": "Går något av dina barn i grundskolan?"}, {"id": "skjuts-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childSchoolDistanceQualifies", "description": "Färdvägen kvalificerar (längd, trafik eller funktionsnedsättning — kommunens bedömning)", "intakeQuestion": "Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?"}]', '[]', '[]', '2026-08-28 16:47:43.509669+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.509669+00'),
	('1761a961-9059-4354-9284-a544365b146b', 'd4a55c7f-be0c-4096-b0ed-78e72d1a4b6c', 1, '[{"id": "elevres-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "elevres-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "elevres-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "elevres-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Barnet går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "elevres-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childGymnasiumLongTravel", "description": "Färdvägen till skolan är minst sex kilometer", "intakeQuestion": "Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?"}]', '[]', '[]', '2026-08-28 16:47:43.517387+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.517387+00'),
	('a3563f3a-d075-47ee-a823-98e78286d6b9', 'f8588186-bfbf-4d9f-9bb9-324af29ce3a3', 1, '[{"id": "fk-bbu-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbu-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbu-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara mellan 18 och 28 år", "intakeQuestion": "Är du mellan 18 och 28 år?"}, {"id": "fk-bbu-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Din inkomst ska vara låg", "intakeQuestion": "Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbu-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 16:47:43.522657+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.522657+00'),
	('aff84572-b5c6-4e05-8c67-cb4d4562fec6', 'c485b4d4-3d50-4c35-875a-ce9002efa611', 1, '[{"id": "kfs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "kfs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "kfs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.incomeInsufficientForBasicNeeds", "description": "Inkomsterna ska inte räcka till det mest nödvändiga", "intakeQuestion": "Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?"}, {"id": "kfs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.limitedSavings", "description": "Du ska sakna sparande eller tillgångar som kan täcka behoven", "intakeQuestion": "Saknar du sparpengar eller tillgångar som kan täcka utgifterna?"}]', '[]', '[]', '2026-08-28 16:47:43.529357+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.529357+00'),
	('111bea21-c920-4e23-8a14-2993f8156fe1', 'babd9fea-fa8f-4936-b290-124358e4b5cc', 1, '[{"id": "csn-sm-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-sm-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. det år du fyller 60"}, {"id": "csn-sm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}]', '[]', '[]', '2026-08-28 16:47:43.537631+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.537631+00'),
	('60971a5d-9e4c-49a9-9ba0-143c624f1327', '22206727-625a-48d8-859b-16410fa4c5a5', 1, '[{"id": "fk-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-ae-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara 19–29 år", "intakeQuestion": "Är du mellan 19 och 29 år?"}, {"id": "fk-ae-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.reducedWorkCapacityLongTerm", "description": "Arbetsförmågan ska vara nedsatt i minst ett år", "intakeQuestion": "Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?"}]', '[]', '[{"id": "fk-ae-e1", "kind": "medical_certificate", "mandatory": true, "description": "Läkarutlåtande om arbetsförmåga"}]', '2026-08-28 16:47:43.546417+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.546417+00'),
	('ae276987-6cec-4a47-a152-78ab12042e60', '108084ff-abea-4a87-a4dc-f97ae3a27245', 1, '[{"id": "fk-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Barnet ska bo hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}, {"id": "fk-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.separatedParent", "description": "Föräldrarna ska inte bo tillsammans", "intakeQuestion": "Bor du och barnets andra förälder på skilda håll?"}, {"id": "fk-us-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.otherParentNotPaying", "description": "Den andra föräldern betalar inte underhåll (eller för lite)", "intakeQuestion": "Betalar den andra föräldern inget eller mindre än fullt underhåll?"}]', '[]', '[]', '2026-08-28 16:47:43.555071+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.555071+00'),
	('297cced3-229c-40e7-88e7-e0788b03d6b3', '1c1b1a91-8462-451d-91c2-77de891b1132', 1, '[{"id": "af-ssn-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "af-ssn-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara inskriven hos Arbetsförmedlingen i Sverige"}, {"id": "af-ssn-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven som arbetssökande", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "af-ssn-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansToStartBusiness", "description": "Du ska planera att starta företag", "intakeQuestion": "Planerar du att starta eget företag?"}]', '[]', '[{"id": "af-ssn-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}]', '2026-08-28 16:47:43.579319+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.579319+00'),
	('dbb48703-bebb-40b2-b578-5baf67cddd72', '9cc5adbb-8a6b-4245-a813-6f134a5dcf1d', 1, '[{"id": "csn-oss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-oss-h2", "op": "is_false", "kind": "hard", "factPath": "person.age62Plus", "description": "Stödet kan sökas längst t.o.m. det år du fyller 62"}, {"id": "csn-oss-h3", "op": "is_false", "kind": "hard", "factPath": "person.receivesPension", "description": "Stödet riktar sig till yrkesverksamma, inte pensionärer"}, {"id": "csn-oss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.establishedInLabourMarket", "description": "Du ska ha arbetat i genomsnitt minst 16 h/vecka i minst 8 år", "intakeQuestion": "Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?"}, {"id": "csn-oss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska planera studier som stärker din ställning på arbetsmarknaden", "intakeQuestion": "Planerar du studier som stärker din ställning på arbetsmarknaden?"}]', '[]', '[]', '2026-08-28 16:47:43.586968+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.586968+00'),
	('325f7cf9-3ccc-490f-b792-44709b0ef73f', 'adf1bd42-188c-4d57-ae52-9ddf6c4ac159', 1, '[{"id": "kom-bab-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "kom-bab-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bostaden ska ligga i Sverige"}, {"id": "kom-bab-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i hushållet har en funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "kom-bab-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du eller någon i hushållet ska ha en bestående funktionsnedsättning", "intakeQuestion": "Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?"}, {"id": "kom-bab-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.needsHomeAdaptation", "description": "Bostaden ska behöva anpassas", "intakeQuestion": "Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?"}]', '[]', '[{"id": "kom-bab-e1", "kind": "medical_certificate", "mandatory": true, "description": "Intyg från arbetsterapeut, läkare eller motsvarande"}]', '2026-08-28 16:47:43.596326+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.596326+00'),
	('0473ef56-37e0-48a6-befa-1869e569dfc6', 'cd410d27-411f-4959-ab88-af4bd10df01c', 1, '[{"id": "kn-kb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kn-kb-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kn-kb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande", "intakeQuestion": "Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?"}]', '[]', '[{"id": "kn-kb-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kn-kb-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 16:47:43.603888+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.603888+00'),
	('bfac0fb4-7424-47f9-a45e-d1bf0600e76f', 'df148f5f-dfdb-415c-86f6-2c63d1fe4f01', 1, '[{"id": "raa-ka-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "raa-ka-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "raa-ka-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsCulturalHeritage", "description": "Projektet ska avse kulturarv", "intakeQuestion": "Handlar projektet om att bevara eller tillgängliggöra kulturarv?"}]', '[]', '[]', '2026-08-28 16:47:43.611535+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.611535+00'),
	('a8ef5f70-c604-452d-a0ed-0a903ba84238', 'ba23f3f6-01d4-4f65-a19b-0d845c8d9f09', 1, '[{"id": "si-cf-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "si-cf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande organisation ska vara svensk"}, {"id": "si-cf-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska genomföras med internationell partner", "intakeQuestion": "Har projektet en partner i ett annat land?"}, {"id": "si-cf-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensDemocracy", "description": "Projektet ska stärka demokrati, jämlikhet eller yttrandefrihet", "intakeQuestion": "Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?"}, {"id": "si-cf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["culture", "civil_society"], "factPath": "project.sector", "description": "Kultur/media som verktyg"}]', '[]', '[{"id": "si-cf-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från internationell partner"}, {"id": "si-cf-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 16:47:43.618892+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.618892+00'),
	('9371605c-6535-4054-b13b-4ac3e95e08c6', 'a437dd6c-d28b-4140-b3ae-da8fb7ac47a1', 1, '[{"id": "fk-sp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-sp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.sickReducedWorkCapacity", "description": "Sjukdomen ska sätta ned din arbetsförmåga med minst en fjärdedel", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?"}]', '[]', '[]', '2026-08-28 16:47:43.830807+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.830807+00'),
	('c569c037-84cb-4e6e-8bd1-57615c8c7247', 'e0ec6da9-da13-4a74-9a33-5cc324a28e79', 1, '[{"id": "nkf-ps-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett konst- eller kulturprojekt", "intakeQuestion": "Är projektet ett konst- eller kulturprojekt?"}, {"id": "nkf-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasNordicDimension", "description": "Projektet ska ha nordisk dimension (samarbete i flera nordiska länder)", "intakeQuestion": "Samarbetar ni med partner i minst två andra nordiska länder?"}, {"id": "nkf-ps-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Gränsöverskridande samarbete"}]', '[]', '[{"id": "nkf-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "nkf-ps-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 16:47:43.627091+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.627091+00');
INSERT INTO public.rule_versions VALUES
	('1e94b2a6-bb2b-40e8-b956-2776b5180c40', '158ef93d-29f8-4450-a2d2-894ca61e7722', 1, '[{"id": "vr-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte"}, {"id": "vr-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}]', '[]', '[{"id": "vr-pb-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "vr-pb-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}]', '2026-08-28 16:47:43.63427+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.63427+00'),
	('c1173908-5143-4ffa-906b-11200367f433', '29dcb82a-e2f5-43d4-852c-c1d867708146', 1, '[{"id": "pk-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "pk-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska vara etablerad och välskött", "intakeQuestion": "Har organisationen ordnad ekonomi och demokratisk struktur?"}, {"id": "pk-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Stödet ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[{"id": "pk-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "pk-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning"}]', '2026-08-28 16:47:43.640986+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.640986+00'),
	('35a9dacb-4cb9-418e-9a60-75aa0ce4eee0', '6b3d5f61-1792-4df1-b070-3aed89eb08ed', 1, '[{"id": "mv-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "mv-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell musikverksamhet", "intakeQuestion": "Är verksamheten professionell?"}, {"id": "mv-pb-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Musikprojekt", "intakeQuestion": "Är projektet ett musikprojekt?"}]', '[]', '[]', '2026-08-28 16:47:43.648207+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.648207+00'),
	('9c525c28-5abd-4197-8a53-0b69aa85addc', '52d29ddf-4657-4c28-a11a-54f03e30c815', 1, '[{"id": "er-ka2-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "school", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "er-ka2-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID?"}, {"id": "er-ka2-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partner i ett annat programland", "intakeQuestion": "Har ni en partnerorganisation i ett annat europeiskt land?"}, {"id": "er-ka2-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.newToEuFunding", "description": "Nykomlingar i Erasmus+ prioriteras", "intakeQuestion": "Är det här ert första EU-projekt?"}]', '[]', '[{"id": "er-ka2-e1", "kind": "partner_letter", "mandatory": true, "description": "Partnerbekräftelse"}, {"id": "er-ka2-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 16:47:43.654527+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.654527+00'),
	('cefaa1d0-3018-46e2-adfa-0c1e4a6f9d71', '472c46ce-e481-4a4c-8d30-b71afae838e0', 1, '[{"id": "tv-ris-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av företag"}, {"id": "tv-ris-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "tv-ris-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.inSupportArea", "description": "Verksamhetsorten ska ligga i stödområde A eller B", "intakeQuestion": "Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?"}, {"id": "tv-ris-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en investering i byggnader eller maskiner?"}, {"id": "tv-ris-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.notStartedYet", "description": "Investeringen får inte vara påbörjad före ansökan", "intakeQuestion": "Kommer investeringen att påbörjas först efter att ni skickat in ansökan?"}]', '[{"id": "tv-ris-b1", "type": "max_funding_share", "percent": 35, "description": "Stödandelen är högst 35 % beroende på område och företagsstorlek."}]', '[]', '2026-08-28 16:47:43.662542+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.662542+00'),
	('3867be9d-d906-4ed4-97df-b20d0eac4782', 'b13c4d37-8afa-4d0f-a101-db60e7c57e23', 1, '[{"id": "kr-ib-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Söks av kommuner"}, {"id": "kr-ib-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsLibraries", "description": "Medlen ska användas till litteraturinköp för folk- eller skolbibliotek", "intakeQuestion": "Avser ansökan litteraturinköp till folk- eller skolbibliotek?"}, {"id": "kr-ib-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga prioriteras"}]', '[]', '[]', '2026-08-28 16:47:43.67061+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.67061+00'),
	('d08c2d56-a15f-405c-9b71-638655bda9d2', 'e47f4f7e-960b-4ca1-8433-17d893b598b6', 1, '[{"id": "kr-ls-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av förlag"}, {"id": "kr-ls-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isPublisher", "description": "Sökande ska vara ett förlag med professionell utgivning", "intakeQuestion": "Är ni ett förlag med professionell utgivning?"}, {"id": "kr-ls-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsPublishedBook", "description": "Stödet söks för redan utgiven titel", "intakeQuestion": "Avser ansökan en redan utgiven titel?"}]', '[]', '[]', '2026-08-28 16:47:43.675332+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.675332+00'),
	('55effc30-4b09-4973-bc68-b2b37a016589', '70a9b78d-5186-47cc-b281-ab71b789453b', 1, '[{"id": "ls-bm-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality"], "factPath": "applicant.type", "description": "Söks av föreningar och kommuner"}, {"id": "ls-bm-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "ls-bm-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inAffectedArea", "description": "Projektet ska ligga i en bygd berörd av vatten- eller vindkraft", "intakeQuestion": "Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?"}, {"id": "ls-bm-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsCommunity", "description": "Projektet ska vara till allmän nytta för bygden", "intakeQuestion": "Är projektet till nytta för bygden i stort (inte enskilda)?"}]', '[]', '[]', '2026-08-28 16:47:43.681399+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.681399+00'),
	('361e4ad1-761c-4ef6-9241-885e67163836', '42115092-8860-4bfc-a937-69b8903a9171', 1, '[{"id": "mv-av-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "mv-av-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "mv-av-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.planningReturnMigration", "description": "Du ska frivilligt planera att flytta tillbaka till ditt ursprungsland permanent", "intakeQuestion": "Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?"}, {"id": "mv-av-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.protectionBasedResidence", "description": "Du ska ha uppehållstillstånd som flykting eller skyddsbehövande (eller vara nära anhörig till någon som har det)", "intakeQuestion": "Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?"}]', '[]', '[]', '2026-08-28 16:47:43.688568+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.688568+00'),
	('9f86ca47-a944-4a10-a925-ddff0a1fa196', '408124bd-81fd-4bc2-8d89-0784b9e4cebf', 1, '[{"id": "eures-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "eures-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara bosatt i ett EU-land (här: Sverige)"}, {"id": "eures-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "eures-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.seekingJobInOtherEuCountry", "description": "Du ska söka eller ha fått jobb i ett annat EU-/EES-land", "intakeQuestion": "Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?"}]', '[]', '[]', '2026-08-28 16:47:43.696512+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.696512+00'),
	('ca53125f-87f1-4abe-9cef-49ed6f841089', 'e7cfd942-b468-489d-8f64-bae97ef6f4ce', 1, '[{"id": "csn-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-us-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. ca 60 års ålder"}, {"id": "csn-us-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "csn-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}, {"id": "csn-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansStudyAbroad", "description": "Studierna ska bedrivas utomlands", "intakeQuestion": "Planerar du att studera utomlands?"}]', '[]', '[]', '2026-08-28 16:47:43.702099+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.702099+00'),
	('be7bc715-0774-41fc-9612-b11b3497739f', '976d0e20-afcc-4377-99a4-cd023e0befdd', 1, '[{"id": "fk-ov-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av vårdnadshavare"}, {"id": "fk-ov-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-ov-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-ov-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-ov-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childHasDisability", "description": "Barnet ska ha en funktionsnedsättning som ger behov av mer omvårdnad och tillsyn än jämnåriga", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?"}]', '[]', '[]', '2026-08-28 16:47:43.70903+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.70903+00'),
	('46ecf2a5-a0d5-4b0e-9784-c0131a2dac97', '597a859b-ce74-471b-ba79-d62c4fc2e620', 1, '[{"id": "fk-mk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-mk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-mk-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-mk-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du (eller ditt barn) ska ha en varaktig funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-mk-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityExtraCosts", "description": "Funktionsnedsättningen ska medföra merkostnader över lägstanivån", "intakeQuestion": "Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?"}]', '[]', '[]', '2026-08-28 16:47:43.716709+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.716709+00'),
	('4c46110d-9a01-4984-baf8-11bf8f21ce69', 'c4e32053-e869-4d3b-8b5b-04f04df1b881', 1, '[{"id": "fk-bs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-bs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-bs-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-bs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Funktionsnedsättningen ska vara varaktig", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-bs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityTravelDifficulty", "description": "Det ska vara mycket svårt att förflytta sig på egen hand eller använda allmänna kommunikationer", "intakeQuestion": "Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?"}]', '[]', '[]', '2026-08-28 16:47:43.722813+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.722813+00'),
	('4fcbe456-c821-4743-9ffa-da179e18bedc', 'daff24a1-b151-4351-8ec9-e5224d7c4f7d', 1, '[{"id": "fk-np-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-np-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-np-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.caringForSeriouslyIllRelative", "description": "Du ska avstå från förvärvsarbete för att vårda eller vara nära en närstående vars sjukdom är ett påtagligt hot mot livet", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?"}]', '[]', '[]', '2026-08-28 16:47:43.729077+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.729077+00'),
	('54552a36-7632-42ae-83f7-73a781f8f4bc', '5f582c0c-7448-41df-b77f-cf44696d0d02', 1, '[{"id": "af-ee-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "af-ee-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "af-ee-h3", "op": "is_false", "kind": "hard", "factPath": "person.age66Plus", "description": "Programmet gäller till och med 66 års ålder"}, {"id": "af-ee-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Du ska nyligen ha fått uppehållstillstånd som skyddsbehövande eller anhörig", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "af-ee-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och delta i etableringsprogrammet", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-28 16:47:43.735215+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.735215+00'),
	('dd7ece44-c5e1-46ba-821d-dbc30d2afee0', '658fac41-629c-4902-b5e2-4c201e230864', 1, '[{"id": "csn-hl-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Lånet söks av privatpersoner"}, {"id": "csn-hl-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara mottagen i en svensk kommun"}, {"id": "csn-hl-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Lånet gäller flyktingar och vissa anhöriga under de första åren i Sverige", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "csn-hl-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.settlingFirstHomeInSweden", "description": "Du ska hålla på att skaffa och utrusta ett första hem i Sverige", "intakeQuestion": "Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?"}]', '[]', '[]', '2026-08-28 16:47:43.742495+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.742495+00'),
	('49c28c9b-bca6-4465-bf44-d229596f662c', '91771ac6-ec58-4d1e-a0ea-041dd9f3e02d', 1, '[{"id": "csn-ss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "csn-ss-h3", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Stödet gäller till och med 60 års ålder"}, {"id": "csn-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara arbetslös och anmäld hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "csn-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.age25to60", "description": "Du ska vara mellan 25 och 60 år", "intakeQuestion": "Är du mellan 25 och 60 år?"}, {"id": "csn-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.shortPriorEducation", "description": "Du ska ha kort tidigare utbildning och behöva studier på grundskole- eller gymnasienivå", "intakeQuestion": "Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?"}]', '[]', '[]', '2026-08-28 16:47:43.749512+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.749512+00'),
	('9c57c5dc-f500-4b28-bb8d-7f44e6d907d4', '833b544b-024d-4a38-a847-fc7d6bccf87f', 1, '[{"id": "csn-it-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "csn-it-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "csn-it-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "csn-it-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Eleven går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "csn-it-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childLivesAwayForStudies", "description": "Eleven behöver bo på studieorten på grund av lång eller besvärlig resväg", "intakeQuestion": "Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?"}]', '[]', '[]', '2026-08-28 16:47:43.757416+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.757416+00'),
	('f2358d86-2b16-48e5-b004-b8671cf99533', '127cd502-3a44-4e5c-b6ac-705177a82fb2', 1, '[{"id": "kmn-fb-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Bidragen söks av ideella föreningar"}, {"id": "kmn-fb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "kmn-fb-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Föreningen ska vara demokratiskt uppbyggd med stadgar och styrelse", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har föreningen antagna stadgar och en vald styrelse?"}, {"id": "kmn-fb-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.activeInMunicipality", "description": "Föreningen ska bedriva regelbunden verksamhet i kommunen", "intakeQuestion": "Bedriver föreningen regelbunden verksamhet i kommunen?"}, {"id": "kmn-fb-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.hasYouthActivities", "description": "Barn- och ungdomsverksamhet prioriteras i de flesta kommuner", "intakeQuestion": "Har föreningen regelbunden verksamhet för barn eller unga?"}]', '[]', '[]', '2026-08-28 16:47:43.765125+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.765125+00'),
	('4c4a56b5-4643-408e-90cb-7cd9dc63f754', 'fd4a9197-c27b-4ee7-afda-35d979f2098e', 1, '[{"id": "reg-ks-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "reg-ks-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Stöden gäller kulturverksamhet", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "reg-ks-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.regionalConnection", "description": "Sökanden ska ha säte eller huvudsaklig verksamhet i regionen", "intakeQuestion": "Har ni säte eller huvudsaklig verksamhet i den region där ni söker?"}]', '[]', '[]', '2026-08-28 16:47:43.772045+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.772045+00'),
	('fbab902a-60db-4fab-afc5-750d75747bd6', 'da0b2f8a-cd17-4b6c-bd60-d74d341e3867', 1, '[{"id": "spb-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks i regel av ideella organisationer"}, {"id": "spb-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "spb-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.localSparbankPresence", "description": "Det ska finnas en sparbank/sparbanksstiftelse i ert verksamhetsområde", "intakeQuestion": "Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?"}, {"id": "spb-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska komma det lokala samhället till del", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}]', '[]', '[]', '2026-08-28 16:47:43.780399+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.780399+00'),
	('1ca2a1b4-67ce-4a63-ad75-4d688ae4624e', '602e8c20-26ef-42ef-b464-943e26285d97', 1, '[{"id": "leader-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "leader-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inRuralLeaderArea", "description": "Projektet ska genomföras inom ett leaderområde (större delen av landsbygden och många tätorter omfattas)", "intakeQuestion": "Genomförs projektet på landsbygden eller i en mindre tätort?"}, {"id": "leader-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska bidra till bygdens utveckling enligt områdets strategi", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}, {"id": "leader-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Stödet betalas ut i efterhand — ni behöver kunna ligga ute med kostnader", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[]', '2026-08-28 16:47:43.787921+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.787921+00'),
	('45902229-90a8-4d9a-885b-326053b8c0fc', '51fc07c0-1ded-4386-8f99-03d11629b0be', 1, '[{"id": "forte-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte eller godkänd medelsförvaltare"}, {"id": "forte-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "forte-pb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.withinForteAreas", "description": "Projektet ska ligga inom hälsa, arbetsliv eller välfärd", "intakeQuestion": "Handlar projektet om hälsa, arbetsliv eller välfärd?"}]', '[]', '[]', '2026-08-28 16:47:43.794161+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.794161+00'),
	('c4f332b7-c6bf-468c-bf6b-30b147d6cfc6', '9abe0ec7-4906-4df3-a304-b2d9e3b89128', 1, '[{"id": "rh-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks av ideella organisationer"}, {"id": "rh-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara svensk"}, {"id": "rh-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.has90Account", "description": "Organisationen ska ha 90-konto (Svensk Insamlingskontroll)", "intakeQuestion": "Har organisationen ett 90-konto?"}, {"id": "rh-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Bidrag ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[]', '2026-08-28 16:47:43.800448+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.800448+00'),
	('9f7fa308-2850-4760-a3dc-35bc3704c57f', '652cedfe-d4d6-4ddb-9b05-591f9b242d85', 1, '[{"id": "fk-bb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-bb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-bb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn under 16 år som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 16:47:43.805499+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.805499+00'),
	('f3abcacd-b0c1-4a0b-a67e-49e5aa6c93a1', '81cee800-ca0d-49c5-99cf-b427d825f169', 1, '[{"id": "fk-fbt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget gäller privatpersoner"}, {"id": "fk-fbt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Gäller från och med det andra barnet du får barnbidrag för", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 16:47:43.811264+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.811264+00'),
	('9e5129ca-11ba-4cf6-85b3-f1cd8682951c', 'd175bd2f-e19c-49ae-8b6a-dd143eaf42ec', 1, '[{"id": "fk-se-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-se-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Ersättningen är aktuell vid varaktig sjukdom eller funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-se-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Arbetsförmågan ska vara stadigvarande nedsatt av sjukdom eller funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}]', '[]', '[]', '2026-08-28 16:47:43.836556+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.836556+00'),
	('8bc1ad86-3af1-42e1-9ad7-9de5eddc6d04', '28766ff2-b66a-47c8-bb9c-f3cdcf4e25a5', 1, '[{"id": "fk-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "fk-as-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.inAfProgram", "description": "Du ska delta i ett arbetsmarknadspolitiskt program", "intakeQuestion": "Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?"}]', '[]', '[]', '2026-08-28 16:47:43.844172+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.844172+00'),
	('057c916f-2476-4255-bd40-0f41df3a8a48', '783ec11e-1526-4b41-9736-b7711321ed1a', 1, '[{"id": "fk-atb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-atb-h2", "op": "is_true", "kind": "hard", "factPath": "person.age24Plus", "description": "Bidraget gäller från och med det år du fyller 24"}]', '[]', '[]', '2026-08-28 16:47:43.851147+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.851147+00'),
	('0d248f63-d4b6-443a-8f85-3d38c9939296', '4ea30ea4-e71b-4804-a0f8-2480c73f0a14', 1, '[{"id": "pm-gp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Gäller privatpersoner"}, {"id": "pm-gp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Garantipension lämnas från riktåldern (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}]', '[]', '[]', '2026-08-28 16:47:43.857421+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.857421+00'),
	('18ec81a6-478c-4948-8ca6-e6f2bc6cd3f8', '820353b3-2aa9-4fd2-ae80-e721161abe42', 1, '[{"id": "reg-hk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Skyddet gäller privatpersoner"}, {"id": "reg-hk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller vård i Sverige"}]', '[]', '[]', '2026-08-28 16:47:43.86466+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.86466+00'),
	('e3b772f3-a09d-4674-b9e9-0c6d855003e2', '7c26a054-1e5e-4a99-9c86-2de17bd7ce8f', 1, '[{"id": "ak-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "ak-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och aktivt söka arbete", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-28 16:47:43.871905+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.871905+00'),
	('f9eba37d-0bea-47d5-9fb5-fc43dbb68eca', 'a0f3f498-2aea-41a5-9864-f2b40848a27d', 1, '[{"id": "af-nj-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-nj-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateAwayFromWork", "description": "Den som anställs ska ha varit borta från arbetslivet en längre tid eller vara nyanländ", "intakeQuestion": "Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?"}]', '[]', '[]', '2026-08-28 16:47:43.878643+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.878643+00'),
	('7b4ed6ca-3251-4168-b7e5-97ec2dad49f4', '08969a43-228c-421f-b5e1-43abd2f8b016', 1, '[{"id": "af-lb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa eller behålla en medarbetare", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-lb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateReducedWorkCapacity", "description": "Den anställda ska ha nedsatt arbetsförmåga på grund av funktionsnedsättning eller ohälsa", "intakeQuestion": "Gäller anställningen en person med nedsatt arbetsförmåga?"}]', '[]', '[]', '2026-08-28 16:47:43.883164+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 16:47:43.883164+00');


--
-- Data for Name: source_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sources VALUES
	('f829d377-d561-41dc-bdad-54c4bbfdad42', '65cab2d3-8ed7-4f3d-b411-e992ee767527', 'Kulturrådet — Sök bidrag', 'https://kulturradet.se/sok-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.165969+00'),
	('dafb453c-1945-40e8-b7f9-0aa1f567d087', '0ded917d-009b-42d5-a18f-e242792290b2', 'MUCF — Bidrag', 'https://www.mucf.se/bidrag', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.169016+00'),
	('ea88f28a-0118-4f1f-b2cd-6dbf0fcafb27', '038dc199-d889-4fc3-bcce-bb5d5828489b', 'Vinnova — Utlysningar', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.171361+00'),
	('010560b3-b6a8-43e5-891a-1dd6a84a5a90', '2af8212e-c128-4afd-b6a5-1bb58f570480', 'Tillväxtverket — Utlysningar', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.173863+00'),
	('a3c5e9c5-897e-46f7-bbc9-f5dd695ad8dd', '54d7945e-c5de-4cdc-a17c-03e74eacb119', 'Energimyndigheten — Alla utlysningar', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.17648+00'),
	('878725ca-49df-431e-9ba7-270171aabfd8', '8454639d-e196-4bc6-8906-115581d8abf9', 'Naturvårdsverket — Bidrag', 'https://www.naturvardsverket.se/bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.178237+00'),
	('c693105c-87f6-4682-bc70-944b3fef850b', '2e4a8215-55b6-4bae-9c7b-5173033498fd', 'Svenska ESF-rådet — Utlysningsplan', 'https://www.esf.se/utlysningar/utlysningsplan/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.18026+00'),
	('452c57c6-8983-4ae0-a334-76f33bb4f0e2', '5b109bb1-21c2-4c94-b827-a9b7fb5cb271', 'Erasmus+ — Youth exchanges', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.182317+00'),
	('2faad5bd-34a0-434d-a858-a7329d65b8ab', '9e528334-1289-461e-b22b-dde99ab62b73', 'Konstnärsnämnden — Stipendier och bidrag', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.184223+00'),
	('44710950-a58e-4545-bba6-ce9a9a4c8b7d', '23c3bf91-72e5-4f73-bc64-9ab786ee6225', 'Allmänna arvsfonden — Söka pengar', 'https://www.arvsfonden.se/soka-pengar', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.186624+00'),
	('c569efc1-8a04-48fd-9aa9-bd8098574acb', '731a7e6f-0225-4328-bf69-72d344cbbd8a', 'Boverket — Bidrag och stöd', 'https://www.boverket.se/sv/bidrag--garantier/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.189136+00'),
	('1ba19e0d-5b70-499b-b3eb-826f4c53bbc1', '035aa2c1-5589-481d-9e83-6c0a9c2ac3ef', 'Riksidrottsförbundet — Ekonomiskt stöd', 'https://www.rf.se/bidrag-och-stod', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.191424+00'),
	('accbbb60-a6c4-4a9e-8d66-573c47a08fbc', '1951f314-9107-4859-85a5-3e1ffc1c9eb2', 'Svenska Filminstitutet — Stöd', 'https://www.filminstitutet.se/sv/sok-stod/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.19362+00'),
	('c73c00b5-fb6d-477d-9edf-50d03c255b50', 'b40fc693-72c5-4db6-b526-3d90e5c71542', 'Formas — Utlysningar', 'https://www.formas.se/soka-finansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.19563+00'),
	('db93de02-be04-4784-a1e0-ad82d2209be1', '20fe6a7f-8008-448a-82de-cbeab6ce4453', 'UHR — Erasmus+ utbildning', 'https://www.uhr.se/internationella-mojligheter/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.197427+00'),
	('58e04980-ec0f-417b-abaa-baaac302d786', 'e479031c-e478-4d79-b3cd-a5213fbb0a2a', 'Försäkringskassan — Privatperson', 'https://www.forsakringskassan.se/privatperson', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.199134+00'),
	('0afd3980-2de3-4551-9b4c-7b8bcd7faa64', 'f3e64d78-4014-4cc8-8738-3f1add544dcd', 'CSN — Studiemedel', 'https://www.csn.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.200952+00'),
	('859b11f9-48f5-462c-8d17-4fa4e96490bc', '97fdbe52-bccd-4e2d-9407-2621c9fc1877', 'Pensionsmyndigheten — Stöd och bidrag', 'https://www.pensionsmyndigheten.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.203022+00'),
	('c768c72b-e535-4458-a8f7-0503ce0cfde0', 'b19978da-e163-485b-bd60-e9abde43de1a', 'Socialstyrelsen — Ekonomiskt bistånd', 'https://www.socialstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.204591+00'),
	('2c0e3ba2-095a-48af-a3aa-8e732d7d16c0', '92c3e316-3ea3-4605-96d8-ac921962531b', '1177 — Bidrag för glasögon till barn och unga', 'https://www.1177.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.206955+00'),
	('f84c6fe9-956b-4481-bd52-4de6df8d382e', '739ddcb9-3861-4824-a21c-ab9f8444b694', 'Majblomman — Ansök om bidrag', 'https://majblomman.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.209522+00'),
	('2130fbf0-58c8-456a-9b11-13dcf448063d', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'Skolverket — Skolskjuts', 'https://www.skolverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.211592+00'),
	('759ec253-3e9c-4727-9d8e-4e4bae1b5a7b', 'a8e7b4ef-1dec-4f57-82c3-ec28947b00dd', 'Lag (1991:1110) om kommunernas skyldighet att svara för vissa elevresor', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.213466+00'),
	('41f72dfd-557c-4ed1-ad62-e3d82f0fe611', '3f20ab14-1077-4bf5-9950-cfc30b0cc84a', 'Arbetsförmedlingen — Stöd och bidrag', 'https://arbetsformedlingen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.215195+00'),
	('ed812804-18fe-4d86-a2b5-996083bbd0f5', 'd434f635-0d4d-4ba7-9e71-11227556b027', 'Sveriges a-kassor — Så fungerar a-kassan', 'https://www.sverigesakassor.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.217156+00'),
	('f0680383-cee7-4560-b62e-174eca39a431', '5eb8a5d0-d180-4378-b961-ec973438d851', 'Migrationsverket — Återvandring', 'https://www.migrationsverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.219961+00'),
	('2e6ec0fd-fae7-4365-bd00-1d494491daa4', 'e86450a5-3347-4eb3-99c3-02a88fe076c3', 'Riksantikvarieämbetet — Bidrag', 'https://www.raa.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.22234+00'),
	('bbcf86ac-a0b6-4ef2-82b0-2b12cf7f8a0d', '2cd0f3a7-8580-4aad-aa3a-f13ea4ae6c26', 'Svenska institutet — Utlysningar', 'https://si.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.224711+00'),
	('a28a95a6-80ed-4f43-bcd9-84df55b10b02', 'a0d58015-0790-41cb-911c-41318d27d722', 'Nordisk kulturfond — Støtte', 'https://www.nordiskkulturfond.org/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.227+00'),
	('e6107c19-ebfa-470e-ad61-86b372740d66', '83bc1100-03b7-42e8-b09e-c5738e28c0c2', 'Vetenskapsrådet — Utlysningar', 'https://www.vr.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.229292+00'),
	('e813a35c-5fce-4384-b612-b0d119c7ec89', 'fb49244f-7aae-42f9-8036-d3d6cb09b1c5', 'Postkodstiftelsen — Ansök om stöd', 'https://postkodstiftelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.231566+00'),
	('d400be3a-853f-4b67-90e2-aa987f39cdb3', 'ddddeb50-a0b4-43cf-8f80-ace23e32c364', 'Musikverket — Bidrag', 'https://musikverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.233522+00'),
	('10143241-df4e-4418-ab5e-8cf89dd802fb', '269cc233-2da3-475a-aae0-c92d7484743a', 'Länsstyrelserna — Stöd och bidrag', 'https://www.lansstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.235446+00'),
	('65a92248-85b2-4b93-972d-acedc89e5fe4', '941d14c3-80a3-47c5-b090-5f80d2dfb3ee', 'Forte — Utlysningar', 'https://forte.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.237713+00'),
	('75fdf4fb-df1d-4c0d-826d-176612520cc0', 'ce150a61-c7fa-4a55-a4ea-7404acaf806b', 'Sparbankernas Riksförbund — Sparbanksstiftelser', 'https://www.sparbankerna.se/', 'html', 'B', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.241087+00'),
	('56ffc194-b39e-4484-923b-c9688862c6c3', '52156ca5-09a4-4f2a-bc70-e9a02eea9e16', 'Radiohjälpen — Söka bidrag', 'https://www.radiohjalpen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.243476+00'),
	('543634dc-b143-427e-a062-5871354631b2', '48dd66f5-af08-4a60-88a2-b5bbc72ad8e3', 'Jordbruksverket — Stöd', 'https://jordbruksverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 16:47:43.245299+00');


--
-- Data for Name: storage_objects; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: submission_receipts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE SET; Schema: drizzle; Owner: -
--

SELECT pg_catalog.setval('drizzle.__drizzle_migrations_id_seq', 13, true);


--
-- Name: receipt_number_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.receipt_number_seq', 1, false);


--
-- Name: __drizzle_migrations __drizzle_migrations_pkey; Type: CONSTRAINT; Schema: drizzle; Owner: -
--

ALTER TABLE ONLY drizzle.__drizzle_migrations
    ADD CONSTRAINT __drizzle_migrations_pkey PRIMARY KEY (id);


--
-- Name: applicant_profiles applicant_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applicant_profiles
    ADD CONSTRAINT applicant_profiles_pkey PRIMARY KEY (id);


--
-- Name: application_cases application_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_cases
    ADD CONSTRAINT application_cases_pkey PRIMARY KEY (id);


--
-- Name: application_schemas application_schemas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_schemas
    ADD CONSTRAINT application_schemas_pkey PRIMARY KEY (id);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- Name: budget_lines budget_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_lines
    ADD CONSTRAINT budget_lines_pkey PRIMARY KEY (id);


--
-- Name: canonical_answers canonical_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.canonical_answers
    ADD CONSTRAINT canonical_answers_pkey PRIMARY KEY (id);


--
-- Name: case_documents case_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_pkey PRIMARY KEY (id);


--
-- Name: correspondence_events correspondence_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correspondence_events
    ADD CONSTRAINT correspondence_events_pkey PRIMARY KEY (id);


--
-- Name: decisions decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT decisions_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: external_identifiers external_identifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_identifiers
    ADD CONSTRAINT external_identifiers_pkey PRIMARY KEY (id);


--
-- Name: funding_authorities funding_authorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_authorities
    ADD CONSTRAINT funding_authorities_pkey PRIMARY KEY (id);


--
-- Name: funding_opportunities funding_opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_opportunities
    ADD CONSTRAINT funding_opportunities_pkey PRIMARY KEY (id);


--
-- Name: funding_opportunities funding_opportunities_slug_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_opportunities
    ADD CONSTRAINT funding_opportunities_slug_unique UNIQUE (slug);


--
-- Name: funding_programmes funding_programmes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_programmes
    ADD CONSTRAINT funding_programmes_pkey PRIMARY KEY (id);


--
-- Name: funding_stacks funding_stacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_stacks
    ADD CONSTRAINT funding_stacks_pkey PRIMARY KEY (id);


--
-- Name: generated_documents generated_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_pkey PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: invites invites_token_hash_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_token_hash_unique UNIQUE (token_hash);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_token_hash_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_token_hash_unique UNIQUE (token_hash);


--
-- Name: payment_milestones payment_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_milestones
    ADD CONSTRAINT payment_milestones_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: receipts receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: recovery_codes recovery_codes_code_hash_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recovery_codes
    ADD CONSTRAINT recovery_codes_code_hash_unique UNIQUE (code_hash);


--
-- Name: recovery_codes recovery_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recovery_codes
    ADD CONSTRAINT recovery_codes_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_hash_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_unique UNIQUE (token_hash);


--
-- Name: reminders reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: reporting_requirements reporting_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporting_requirements
    ADD CONSTRAINT reporting_requirements_pkey PRIMARY KEY (id);


--
-- Name: review_items review_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_items
    ADD CONSTRAINT review_items_pkey PRIMARY KEY (id);


--
-- Name: rule_versions rule_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_versions
    ADD CONSTRAINT rule_versions_pkey PRIMARY KEY (id);


--
-- Name: source_snapshots source_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_snapshots
    ADD CONSTRAINT source_snapshots_pkey PRIMARY KEY (id);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: storage_objects storage_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_pkey PRIMARY KEY (path);


--
-- Name: submission_receipts submission_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_receipts
    ADD CONSTRAINT submission_receipts_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: app_schemas_opp_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX app_schemas_opp_version_idx ON public.application_schemas USING btree (opportunity_id, version);


--
-- Name: audit_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_entity_idx ON public.audit_events USING btree (entity_type, entity_id);


--
-- Name: audit_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_tenant_idx ON public.audit_events USING btree (tenant_id, created_at);


--
-- Name: budget_lines_case_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX budget_lines_case_idx ON public.budget_lines USING btree (case_id);


--
-- Name: canonical_answers_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX canonical_answers_key_idx ON public.canonical_answers USING btree (tenant_id, canonical_key);


--
-- Name: case_documents_case_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX case_documents_case_idx ON public.case_documents USING btree (case_id);


--
-- Name: cases_state_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cases_state_idx ON public.application_cases USING btree (state);


--
-- Name: cases_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cases_tenant_idx ON public.application_cases USING btree (tenant_id);


--
-- Name: correspondence_case_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX correspondence_case_idx ON public.correspondence_events USING btree (case_id);


--
-- Name: correspondence_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX correspondence_tenant_idx ON public.correspondence_events USING btree (tenant_id);


--
-- Name: documents_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_tenant_idx ON public.documents USING btree (tenant_id);


--
-- Name: extid_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX extid_tenant_idx ON public.external_identifiers USING btree (tenant_id);


--
-- Name: generated_documents_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX generated_documents_tenant_idx ON public.generated_documents USING btree (tenant_id, project_id);


--
-- Name: invites_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invites_tenant_idx ON public.invites USING btree (tenant_id);


--
-- Name: matches_project_opp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX matches_project_opp_idx ON public.matches USING btree (project_id, opportunity_id);


--
-- Name: matches_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX matches_tenant_idx ON public.matches USING btree (tenant_id);


--
-- Name: memberships_user_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX memberships_user_tenant_idx ON public.memberships USING btree (user_id, tenant_id);


--
-- Name: notifications_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_tenant_idx ON public.notifications USING btree (tenant_id, created_at);


--
-- Name: opps_closes_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX opps_closes_idx ON public.funding_opportunities USING btree (closes_at);


--
-- Name: opps_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX opps_status_idx ON public.funding_opportunities USING btree (status);


--
-- Name: password_reset_tokens_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX password_reset_tokens_user_idx ON public.password_reset_tokens USING btree (user_id);


--
-- Name: payments_project_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_project_idx ON public.payments USING btree (project_id, state);


--
-- Name: payments_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_tenant_idx ON public.payments USING btree (tenant_id);


--
-- Name: profiles_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profiles_tenant_idx ON public.applicant_profiles USING btree (tenant_id);


--
-- Name: projects_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX projects_tenant_idx ON public.projects USING btree (tenant_id);


--
-- Name: receipts_number_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX receipts_number_uq ON public.receipts USING btree (receipt_number);


--
-- Name: receipts_payment_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX receipts_payment_uq ON public.receipts USING btree (payment_id);


--
-- Name: receipts_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX receipts_tenant_idx ON public.receipts USING btree (tenant_id);


--
-- Name: recovery_codes_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recovery_codes_user_idx ON public.recovery_codes USING btree (user_id);


--
-- Name: refresh_tokens_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX refresh_tokens_user_idx ON public.refresh_tokens USING btree (user_id);


--
-- Name: reminders_case_kind_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX reminders_case_kind_idx ON public.reminders USING btree (case_id, kind);


--
-- Name: review_items_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX review_items_status_idx ON public.review_items USING btree (status, created_at);


--
-- Name: rule_versions_opp_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rule_versions_opp_version_idx ON public.rule_versions USING btree (opportunity_id, version);


--
-- Name: snapshots_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snapshots_source_idx ON public.source_snapshots USING btree (source_id, fetched_at);


--
-- Name: storage_objects_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX storage_objects_tenant_idx ON public.storage_objects USING btree (tenant_id);


--
-- Name: submission_receipts_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submission_receipts_tenant_idx ON public.submission_receipts USING btree (tenant_id);


--
-- Name: submissions_case_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX submissions_case_idx ON public.submissions USING btree (case_id);


--
-- Name: applicant_profiles applicant_profiles_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applicant_profiles
    ADD CONSTRAINT applicant_profiles_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: application_cases application_cases_opportunity_id_funding_opportunities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_cases
    ADD CONSTRAINT application_cases_opportunity_id_funding_opportunities_id_fk FOREIGN KEY (opportunity_id) REFERENCES public.funding_opportunities(id);


--
-- Name: application_cases application_cases_project_id_projects_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_cases
    ADD CONSTRAINT application_cases_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: application_cases application_cases_rule_version_id_rule_versions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_cases
    ADD CONSTRAINT application_cases_rule_version_id_rule_versions_id_fk FOREIGN KEY (rule_version_id) REFERENCES public.rule_versions(id);


--
-- Name: application_cases application_cases_schema_id_application_schemas_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_cases
    ADD CONSTRAINT application_cases_schema_id_application_schemas_id_fk FOREIGN KEY (schema_id) REFERENCES public.application_schemas(id);


--
-- Name: application_cases application_cases_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_cases
    ADD CONSTRAINT application_cases_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: application_schemas application_schemas_opportunity_id_funding_opportunities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_schemas
    ADD CONSTRAINT application_schemas_opportunity_id_funding_opportunities_id_fk FOREIGN KEY (opportunity_id) REFERENCES public.funding_opportunities(id) ON DELETE CASCADE;


--
-- Name: budget_lines budget_lines_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_lines
    ADD CONSTRAINT budget_lines_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE CASCADE;


--
-- Name: budget_lines budget_lines_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_lines
    ADD CONSTRAINT budget_lines_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: canonical_answers canonical_answers_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.canonical_answers
    ADD CONSTRAINT canonical_answers_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: case_documents case_documents_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE CASCADE;


--
-- Name: case_documents case_documents_document_id_documents_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_document_id_documents_id_fk FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: case_documents case_documents_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_documents
    ADD CONSTRAINT case_documents_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: correspondence_events correspondence_events_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correspondence_events
    ADD CONSTRAINT correspondence_events_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE SET NULL;


--
-- Name: correspondence_events correspondence_events_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correspondence_events
    ADD CONSTRAINT correspondence_events_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: decisions decisions_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT decisions_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE CASCADE;


--
-- Name: decisions decisions_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT decisions_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: documents documents_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: external_identifiers external_identifiers_profile_id_applicant_profiles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_identifiers
    ADD CONSTRAINT external_identifiers_profile_id_applicant_profiles_id_fk FOREIGN KEY (profile_id) REFERENCES public.applicant_profiles(id) ON DELETE CASCADE;


--
-- Name: external_identifiers external_identifiers_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_identifiers
    ADD CONSTRAINT external_identifiers_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: funding_opportunities funding_opportunities_authority_id_funding_authorities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_opportunities
    ADD CONSTRAINT funding_opportunities_authority_id_funding_authorities_id_fk FOREIGN KEY (authority_id) REFERENCES public.funding_authorities(id);


--
-- Name: funding_opportunities funding_opportunities_programme_id_funding_programmes_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_opportunities
    ADD CONSTRAINT funding_opportunities_programme_id_funding_programmes_id_fk FOREIGN KEY (programme_id) REFERENCES public.funding_programmes(id);


--
-- Name: funding_programmes funding_programmes_authority_id_funding_authorities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_programmes
    ADD CONSTRAINT funding_programmes_authority_id_funding_authorities_id_fk FOREIGN KEY (authority_id) REFERENCES public.funding_authorities(id);


--
-- Name: funding_stacks funding_stacks_project_id_projects_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_stacks
    ADD CONSTRAINT funding_stacks_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: funding_stacks funding_stacks_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_stacks
    ADD CONSTRAINT funding_stacks_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: generated_documents generated_documents_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: generated_documents generated_documents_project_id_projects_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: generated_documents generated_documents_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generated_documents
    ADD CONSTRAINT generated_documents_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: invites invites_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: matches matches_opportunity_id_funding_opportunities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_opportunity_id_funding_opportunities_id_fk FOREIGN KEY (opportunity_id) REFERENCES public.funding_opportunities(id) ON DELETE CASCADE;


--
-- Name: matches matches_project_id_projects_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: matches matches_rule_version_id_rule_versions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_rule_version_id_rule_versions_id_fk FOREIGN KEY (rule_version_id) REFERENCES public.rule_versions(id);


--
-- Name: matches matches_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: password_reset_tokens password_reset_tokens_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payment_milestones payment_milestones_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_milestones
    ADD CONSTRAINT payment_milestones_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE CASCADE;


--
-- Name: payment_milestones payment_milestones_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_milestones
    ADD CONSTRAINT payment_milestones_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: payments payments_project_id_projects_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_project_id_projects_id_fk FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: payments payments_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: projects projects_profile_id_applicant_profiles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_profile_id_applicant_profiles_id_fk FOREIGN KEY (profile_id) REFERENCES public.applicant_profiles(id) ON DELETE CASCADE;


--
-- Name: projects projects_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: receipts receipts_payment_id_payments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_payment_id_payments_id_fk FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE SET NULL;


--
-- Name: recovery_codes recovery_codes_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recovery_codes
    ADD CONSTRAINT recovery_codes_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reminders reminders_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT reminders_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE CASCADE;


--
-- Name: reminders reminders_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reminders
    ADD CONSTRAINT reminders_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: reporting_requirements reporting_requirements_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporting_requirements
    ADD CONSTRAINT reporting_requirements_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE CASCADE;


--
-- Name: reporting_requirements reporting_requirements_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporting_requirements
    ADD CONSTRAINT reporting_requirements_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: rule_versions rule_versions_opportunity_id_funding_opportunities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_versions
    ADD CONSTRAINT rule_versions_opportunity_id_funding_opportunities_id_fk FOREIGN KEY (opportunity_id) REFERENCES public.funding_opportunities(id) ON DELETE CASCADE;


--
-- Name: source_snapshots source_snapshots_source_id_sources_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_snapshots
    ADD CONSTRAINT source_snapshots_source_id_sources_id_fk FOREIGN KEY (source_id) REFERENCES public.sources(id) ON DELETE CASCADE;


--
-- Name: sources sources_authority_id_funding_authorities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_authority_id_funding_authorities_id_fk FOREIGN KEY (authority_id) REFERENCES public.funding_authorities(id);


--
-- Name: submission_receipts submission_receipts_submission_id_submissions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_receipts
    ADD CONSTRAINT submission_receipts_submission_id_submissions_id_fk FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON DELETE CASCADE;


--
-- Name: submission_receipts submission_receipts_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submission_receipts
    ADD CONSTRAINT submission_receipts_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_case_id_application_cases_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_case_id_application_cases_id_fk FOREIGN KEY (case_id) REFERENCES public.application_cases(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_tenant_id_tenants_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_tenant_id_tenants_id_fk FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: applicant_profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.applicant_profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: application_cases; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.application_cases ENABLE ROW LEVEL SECURITY;

--
-- Name: application_schemas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.application_schemas ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;

--
-- Name: budget_lines; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.budget_lines ENABLE ROW LEVEL SECURITY;

--
-- Name: canonical_answers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.canonical_answers ENABLE ROW LEVEL SECURITY;

--
-- Name: case_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.case_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: correspondence_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.correspondence_events ENABLE ROW LEVEL SECURITY;

--
-- Name: decisions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.decisions ENABLE ROW LEVEL SECURITY;

--
-- Name: documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

--
-- Name: external_identifiers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.external_identifiers ENABLE ROW LEVEL SECURITY;

--
-- Name: funding_authorities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funding_authorities ENABLE ROW LEVEL SECURITY;

--
-- Name: funding_opportunities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funding_opportunities ENABLE ROW LEVEL SECURITY;

--
-- Name: funding_programmes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funding_programmes ENABLE ROW LEVEL SECURITY;

--
-- Name: funding_stacks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funding_stacks ENABLE ROW LEVEL SECURITY;

--
-- Name: generated_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.generated_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: invites; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.invites ENABLE ROW LEVEL SECURITY;

--
-- Name: matches; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

--
-- Name: memberships; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: password_reset_tokens; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.password_reset_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: payment_milestones; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payment_milestones ENABLE ROW LEVEL SECURITY;

--
-- Name: payments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- Name: projects; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

--
-- Name: receipts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.receipts ENABLE ROW LEVEL SECURITY;

--
-- Name: recovery_codes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.recovery_codes ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: reminders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

--
-- Name: reporting_requirements; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reporting_requirements ENABLE ROW LEVEL SECURITY;

--
-- Name: review_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.review_items ENABLE ROW LEVEL SECURITY;

--
-- Name: rule_versions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.rule_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: source_snapshots; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.source_snapshots ENABLE ROW LEVEL SECURITY;

--
-- Name: sources; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sources ENABLE ROW LEVEL SECURITY;

--
-- Name: storage_objects; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.storage_objects ENABLE ROW LEVEL SECURITY;

--
-- Name: submission_receipts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.submission_receipts ENABLE ROW LEVEL SECURITY;

--
-- Name: submissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

--
-- Name: tenants; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--


