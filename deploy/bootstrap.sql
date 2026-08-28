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
-- Name: kb_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kb_translations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    locale text NOT NULL,
    source_text text NOT NULL,
    translated_text text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
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
	(13, '31f90f534f293eb9e9d33cdf0a5eacfcc80918e49cf34fbb74e9c9b87a34ebf8', 1787898198122),
	(14, 'c1e078548250c737bc1986e92754cccad137e8c0c6a4c9fe72cd7aec517aee40', 1787936414108);


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
	('e55d779c-0b07-406a-88a6-38ccefd297b8', 'bd265af5-d31d-47ef-b64d-ae35aa93362a', 1, '{"id": "kulturradet-resebidrag-v1", "title": "Ansökan — Resebidrag för internationellt kulturutbyte", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "sokande_verksamhet", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "guidance": "T.ex. dans, musik, scenkonst.", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv resan och utbytet", "section": "projekt", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_land", "type": "text", "label": "Resmål (land)", "section": "projekt", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "projekt_datum", "type": "date_range", "label": "Resperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Har du en inbjudan eller bekräftelse från mottagande part?", "section": "projekt", "required": true}, {"key": "inbjudan_beskrivning", "type": "long_text", "label": "Beskriv inbjudan/samarbetet", "section": "projekt", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_inbjudan"}]}, {"key": "aterforing", "type": "long_text", "label": "Hur tar du tillvara erfarenheterna i Sverige?", "section": "projekt", "required": true, "maxLength": 2000, "canonicalKey": "project.knowledgeTransferPlan"}, {"key": "sokt_belopp", "max": 50000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig som söker"}, {"key": "projekt", "title": "Resan och utbytet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.606631+00'),
	('c2608588-c806-4315-900f-850002d2bee1', '7de4b8a9-195b-4254-b82b-11d5969f2e97', 1, '{"id": "erasmus-ungdomsutbyte-v1", "title": "Ansökan — Erasmus+ Ungdomsutbyte (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System med EU Login.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv utbytet", "section": "projekt", "guidance": "Tema, aktiviteter och förväntat lärande.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Utbytesperiod (exklusive resdagar)", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "antal_deltagare", "max": 200, "min": 4, "type": "number", "label": "Antal deltagare", "section": "deltagare", "required": true}, {"key": "har_partner", "type": "boolean", "label": "Har ni en bekräftad partnergrupp i ett annat land?", "section": "deltagare", "required": true}, {"key": "partner_namn", "type": "text", "label": "Partnergruppens namn och land", "section": "deltagare", "required": true, "maxLength": 300, "visibleWhen": [{"op": "is_true", "factPath": "har_partner"}], "canonicalKey": "project.partnerName"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Utbytet"}, {"key": "deltagare", "title": "Deltagare och partner"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.608639+00'),
	('3c449095-eac3-472c-9389-e9cbe35becb2', '527c67ea-1c17-4a82-a849-d7873ad60d80', 1, '{"id": "nordisk-kulturfond-projektstod-v1", "title": "Ansökan — Nordisk kulturfond, projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller organisation)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_titel", "type": "text", "label": "Projektets titel", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska ni göra, varför, och vad är den konstnärliga/kulturella idén?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "nordiska_lander", "type": "multiselect", "label": "Vilka nordiska länder deltar aktivt i projektet?", "options": [{"label": "Sverige", "value": "SE"}, {"label": "Danmark", "value": "DK"}, {"label": "Norge", "value": "NO"}, {"label": "Finland", "value": "FI"}, {"label": "Island", "value": "IS"}, {"label": "Grönland", "value": "GL"}, {"label": "Färöarna", "value": "FO"}, {"label": "Åland", "value": "AX"}], "section": "norden", "guidance": "Fonden kräver samarbete mellan flera nordiska länder — ange de länder som har en aktiv roll.", "required": true}, {"key": "nordisk_dimension", "type": "long_text", "label": "Vad tillför det nordiska samarbetet projektet?", "section": "norden", "guidance": "Konkret: vad händer i samarbetet som inte hade hänt nationellt?", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig/er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "norden", "title": "Nordisk dimension"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.610089+00'),
	('4b0654a8-4189-4edd-a220-be8b5d1e523f', 'af44e2ea-2fdf-483f-8220-8e0cd6284d42', 1, '{"id": "mucf-projektbidrag-v1", "title": "Ansökan — MUCF projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_syfte", "type": "long_text", "label": "Syfte och genomförande", "section": "projekt", "guidance": "Vilket problem adresserar projektet, vad ska ni göra, och hur vet ni att det fungerat?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka unga når projektet, och hur är de delaktiga?", "section": "malgrupp", "guidance": "Ungas egen delaktighet i planering och genomförande väger tungt i bedömningen.", "required": true, "maxLength": 3000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.611522+00'),
	('a37430f7-edc5-48a4-9a30-66b6735905fb', '297dd869-5f82-44dc-b2e5-2a5cb22620cf', 1, '{"id": "kommun-forsorjningsstod-v1", "title": "Ansökan — Försörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "hushall_vuxna", "max": 10, "min": 1, "type": "number", "label": "Antal vuxna i hushållet", "section": "hushall", "required": true, "canonicalKey": "person.householdAdults"}, {"key": "hushall_barn", "max": 15, "min": 0, "type": "number", "label": "Antal barn som bor hemma", "section": "hushall", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "inkomst_manad", "min": 0, "type": "currency", "label": "Hushållets inkomster per månad (kr)", "section": "ekonomi", "guidance": "Räkna ihop lön, ersättningar och bidrag före skatt. Ungefärligt räcker i förberedelsen — kommunen begär exakta underlag.", "required": true, "canonicalKey": "person.monthlyHouseholdIncome"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har hushållet sparade medel eller tillgångar som kan användas till försörjningen?", "section": "ekonomi", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna", "section": "ekonomi", "guidance": "T.ex. sparkonto, bil, värdepapper. Kommunen prövar alltid tillgångar först — att redovisa dem öppet undviker kompletteringar.", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "behov_beskrivning", "type": "long_text", "label": "Beskriv din situation och vad du behöver stöd till", "section": "behov", "guidance": "Konkret: vad har hänt, vad räcker inte pengarna till, och vad gör du själv för att förändra situationen?", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hushall", "title": "Hushållet"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "behov", "title": "Din situation"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.612817+00'),
	('ac54b927-2bd7-4675-968d-c75544376d45', 'fc5cf270-6d44-4083-ad1c-bfe5b9daa605', 1, '{"id": "fk-bostadsbidrag-barnfamiljer-v1", "title": "Ansökan — Bostadsbidrag till barnfamiljer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hemma (helt eller växelvis)", "section": "sokande", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 500, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "guidance": "Bidraget beräknas delvis på ytan — siffran står i hyresavtalet.", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Hushållets beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bostadsbidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav. Ta i lite uppåt hellre än neråt.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.614189+00'),
	('7424328e-3dd7-4ade-96e0-7e91db7174d3', 'eccf68ab-be6b-47aa-8496-3f8eb94f5d4b', 1, '{"id": "majblomman-bidrag-barn-v1", "title": "Ansökan — Majblomman, bidrag till barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "behov_vad", "type": "long_text", "label": "Vad söker ni bidrag för?", "section": "behov", "guidance": "Något konkret som gör skillnad för barnet: en fritidsaktivitet, kläder, utrustning, en cykel. Majblomman ger till barnet, inte till hushållets löpande utgifter.", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "max": 20000, "min": 1, "type": "currency", "label": "Ungefärligt belopp (kr)", "section": "behov", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "situation", "type": "long_text", "label": "Beskriv kort familjens situation", "section": "behov", "guidance": "Varför räcker pengarna inte till det här just nu? Kortfattat räcker.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet"}, {"key": "behov", "title": "Vad ni söker för"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.615863+00'),
	('beaa17aa-ad4b-4028-a6db-3d7eacde9ea9', 'a0ee3771-36b8-4bcd-b9f8-d98ec242eb47', 1, '{"id": "af-stod-start-naringsverksamhet-v1", "title": "Ansökan — Stöd till start av näringsverksamhet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?", "section": "sokande", "guidance": "Stödet förutsätter inskrivning — beslutet fattas av din handläggare.", "required": true}, {"key": "affarside", "type": "long_text", "label": "Beskriv affärsidén", "section": "verksamhet", "guidance": "Vad ska du sälja, till vem, och varför finns det efterfrågan? Konkreta belägg (kundkontakter, erfarenhet, marknadskännedom) väger tyngre än visioner.", "required": true, "maxLength": 4000}, {"key": "verksamhet_start", "type": "date", "label": "Planerad start", "section": "plan", "required": true}, {"key": "har_affarsplan", "type": "boolean", "label": "Har du en skriftlig affärsplan?", "section": "plan", "required": true}, {"key": "forsorjning", "type": "long_text", "label": "Hur försörjer du dig under uppstarten?", "section": "plan", "guidance": "Aktivitetsstödet är tidsbegränsat — visa att kalkylen håller tills verksamheten bär sig.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Affärsidén"}, {"key": "plan", "title": "Planen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.617273+00'),
	('59ee228c-4158-4005-8176-3f13c17dfea9', 'ca268aa9-7310-4769-ba9a-36aa0deb1e23', 1, '{"id": "kulturradet-projektbidrag-musik-v1", "title": "Ansökan — Kulturrådet, projektbidrag musik (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "guidance": "Tio siffror. Kontrollsiffran valideras — ett felskrivet nummer är en vanlig avslagsorsak på formalia.", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska genomföras, av vem, för vilken publik — och vad skiljer det från er ordinarie verksamhet?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ovrig_finansiering", "type": "long_text", "label": "Beskriv övrig finansiering", "section": "budget", "guidance": "Egna medel, andra bidrag, intäkter. Lämna tomt om allt söks här.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.618511+00'),
	('7d4c3143-8406-4d73-81a4-3a5fa6c10092', '772fc254-a2b1-43fd-bec2-ace7ae231536', 1, '{"id": "fk-bostadsbidrag-unga-v1", "title": "Ansökan — Bostadsbidrag för unga (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 300, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Din beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.62053+00'),
	('f6fafaa5-54af-425a-95cd-53be92aab7ab', '2a2922ce-9a4d-4f6e-8a9f-94b69f4f08ec', 1, '{"id": "fk-underhallsstod-v1", "title": "Ansökan — Underhållsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hos dig", "section": "barnen", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "underhall_idag", "type": "long_text", "label": "Hur fungerar underhållet i dag?", "section": "underhall", "guidance": "Betalar den andra föräldern inget, för lite eller oregelbundet? Konkret — det avgör vilken väg Försäkringskassan tar.", "required": true, "maxLength": 2000}, {"key": "har_avtal", "type": "boolean", "label": "Finns avtal eller dom om underhållsbidrag?", "section": "underhall", "required": true}, {"key": "avtal_beskrivning", "type": "long_text", "label": "Beskriv avtalet/domen kort", "section": "underhall", "guidance": "Belopp och datum räcker — dokumentet kan bifogas hos Försäkringskassan.", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_avtal"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnen", "title": "Barnen"}, {"key": "underhall", "title": "Underhållet i dag"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.622069+00'),
	('32b4d90d-da4e-4adb-af49-a3f26bdd72c8', 'df7edb7e-d12a-4f36-bed7-b4a07c6cec51', 1, '{"id": "pm-bostadstillagg-v1", "title": "Ansökan — Bostadstillägg för pensionärer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Allmän pension, tjänstepension och eventuell utländsk pension — sammanlagt.", "required": true}, {"key": "har_kapital", "type": "boolean", "label": "Har du sparade medel eller tillgångar över ungefär 100 000 kr?", "section": "ekonomi", "guidance": "Kapital påverkar bostadstilläggets storlek — att redovisa det öppet undviker återkrav.", "required": true}, {"key": "kapital_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_kapital"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.623235+00'),
	('d233f8ce-df79-4cf8-a445-e8aad7200823', 'ffcaad8d-9445-421f-a38f-f75d58a5efe7', 1, '{"id": "region-glasogonbidrag-barn-v1", "title": "Ansökan — Glasögonbidrag för barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 19, "min": 8, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "har_ordination", "type": "boolean", "label": "Finns ordination eller recept från optiker/ögonläkare?", "section": "barnet", "guidance": "Ordinationen är regionens underlag — utan den kan bidraget inte betalas ut.", "required": true}, {"key": "kostnad", "max": 10000, "min": 1, "type": "currency", "label": "Kostnad för glasögon eller linser (kr)", "section": "barnet", "guidance": "Bidragets tak varierar mellan regioner — hela kostnaden ersätts inte alltid.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och synbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.624416+00'),
	('b4968581-d27a-488c-b857-98c770672f35', '41c414ba-6af3-4006-8650-ee358bba77fc', 1, '{"id": "kommun-skolskjuts-v1", "title": "Ansökan — Skolskjuts (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skolans namn", "section": "eleven", "required": true, "maxLength": 200}, {"key": "arskurs", "type": "text", "label": "Årskurs", "section": "eleven", "guidance": "Kommunens avståndsgräns skiljer sig ofta per årskurs.", "required": true, "maxLength": 20}, {"key": "avstand_km", "max": 200, "min": 0, "type": "number", "label": "Avstånd hem–skola (km)", "section": "eleven", "required": true}, {"key": "skal", "type": "long_text", "label": "Varför behövs skolskjuts?", "section": "eleven", "guidance": "Konkret: avståndet, en trafikfarlig passage, funktionsnedsättning eller växelvis boende. Kommunen prövar mot sina riktlinjer.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och skolvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.625864+00'),
	('80c82f21-8e42-4caa-88dc-1fedcbd911e7', 'b5dc8e07-05f0-4313-b71b-3d8b1f8fd1cd', 1, '{"id": "arvsfonden-projektstod-v1", "title": "Ansökan — Arvsfonden projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad är nyskapande jämfört med er ordinarie verksamhet? Arvsfonden finansierar inte mer av det ni redan gör.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "malgrupp_delaktighet", "type": "long_text", "label": "Hur är målgruppen delaktig i planering och genomförande?", "section": "malgrupp", "guidance": "Delaktigheten är ett skarpt krav — beskriv mekanismen, inte avsikten: vem ur målgruppen gör vad?", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "overlevnad", "type": "long_text", "label": "Hur lever verksamheten vidare efter projektet?", "section": "budget", "guidance": "Arvsfonden kräver en överlevnadsplan: vem tar över, vem betalar, vad består?", "required": true, "maxLength": 2000}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och överlevnad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.627189+00'),
	('b8f647f8-7611-487d-a9f0-6a0a34df3f05', '22685532-2f89-4f86-bb85-10eadedd5ffa', 1, '{"id": "csn-studiemedel-v1", "title": "Ansökan — Studiemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "utbildning", "type": "text", "label": "Utbildning och skola", "section": "studier", "guidance": "T.ex. \"Sjuksköterskeprogrammet, Umeå universitet\".", "required": true, "maxLength": 300}, {"key": "studietakt", "type": "select", "label": "Studietakt", "options": [{"label": "Heltid (100 %)", "value": "100"}, {"label": "75 %", "value": "75"}, {"label": "Halvtid (50 %)", "value": "50"}], "section": "studier", "required": true}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod du söker för", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "vill_lana", "type": "boolean", "label": "Vill du även ta studielån (utöver bidraget)?", "section": "ekonomi", "guidance": "Lånedelen är frivillig och kan väljas per vecka — det går att ångra sig senare.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "ekonomi", "title": "Bidrag och lån"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.628622+00'),
	('86871fd0-543f-41ab-9633-b81b0af1ead5', '05e2a219-0224-4e9a-a4fc-a490e50c2362', 1, '{"id": "fk-aktivitetsersattning-v1", "title": "Ansökan — Aktivitetsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "nedsattning_beskrivning", "type": "long_text", "label": "Beskriv hur arbetsförmågan är nedsatt", "section": "halsa", "guidance": "Med egna ord: vad klarar du inte i dag som ett arbete kräver? Försäkringskassan gör alltid den medicinska prövningen — din beskrivning ska stämma med läkarintyget, inte ersätta det.", "required": true, "maxLength": 4000}, {"key": "har_lakarintyg", "type": "boolean", "label": "Finns ett aktuellt läkarintyg eller läkarutlåtande?", "section": "halsa", "guidance": "Läkarutlåtandet är det centrala underlaget — ansökan utan det leder nästan alltid till komplettering.", "required": true}, {"key": "pagaende_insatser", "type": "long_text", "label": "Pågående vård eller insatser", "section": "halsa", "guidance": "T.ex. behandling, rehabilitering, daglig verksamhet. Lämna tomt om inget pågår.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "halsa", "title": "Arbetsförmågan"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.629812+00'),
	('f73756c9-1941-4f56-8ddb-b9164e51e1ba', 'b20a46a6-bffc-4d54-8ff8-d86276fcf5fc', 1, '{"id": "pm-aldreforsorjningsstod-v1", "title": "Ansökan — Äldreförsörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Alla pensioner sammanlagt — även utländsk pension räknas.", "required": true}, {"key": "ovriga_inkomster", "min": 0, "type": "currency", "label": "Övriga inkomster per månad (kr)", "section": "ekonomi", "required": false}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har du sparade medel eller tillgångar?", "section": "ekonomi", "guidance": "Tillgångar påverkar prövningen — öppen redovisning undviker återkrav.", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.631001+00'),
	('54e52ebb-63bf-45d7-a4e3-42a2782582f2', 'a0ff68b8-ffae-4bc7-8609-b47c16d79a8a', 1, '{"id": "kommun-elevresor-gymnasiet-v1", "title": "Ansökan — Elevresor gymnasiet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (elev eller vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Gymnasieskolans namn och ort", "section": "eleven", "required": true, "maxLength": 200}, {"key": "avstand_km", "max": 300, "min": 0, "type": "number", "label": "Resväg hem–skola (km)", "section": "eleven", "guidance": "Gränsen är normalt sex kilometer närmaste väg.", "required": true}, {"key": "har_studiehjalp", "type": "boolean", "label": "Har eleven studiehjälp från CSN?", "section": "eleven", "guidance": "Elevresestödet förutsätter studiehjälp — den kommer automatiskt för de flesta gymnasieelever under 20.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och resvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.632403+00'),
	('e0380223-b1df-4b85-98a4-1f90315ee52b', 'ba6fcb93-6a60-4adf-a37d-d53718fa3afd', 1, '{"id": "kommun-bostadsanpassningsbidrag-v1", "title": "Ansökan — Bostadsanpassningsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen och hur den påverkar boendet", "section": "behov", "guidance": "Konkret ur vardagen: trösklar, trappor, badrum. Intyg från arbetsterapeut eller läkare styrker behovet.", "required": true, "maxLength": 3000}, {"key": "anpassning", "type": "long_text", "label": "Vilken anpassning söker du bidrag för?", "section": "behov", "guidance": "T.ex. ramp vid entrén, borttagna trösklar, dörrautomatik, anpassat badrum.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "behov", "guidance": "Offert från entreprenör räcker — kommunen kan begära fler.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "har_intyg", "type": "boolean", "label": "Finns intyg från arbetsterapeut, läkare eller annan sakkunnig?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Behovet och anpassningen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.633765+00'),
	('24078c51-91c2-435f-8467-0533af861416', 'b229c4b1-da17-4783-ad8c-527c6c2db2b4', 1, '{"id": "csn-omstallningsstudiestod-v1", "title": "Ansökan — Omställningsstudiestöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "arbetsliv_ar", "max": 50, "min": 0, "type": "number", "label": "Ungefär hur många år har du arbetat (minst 16 h/vecka)?", "section": "arbetsliv", "guidance": "Kravet är i genomsnitt minst 16 timmar i veckan under minst 8 år.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du planerar", "section": "studier", "required": true, "maxLength": 300}, {"key": "starkning_beskrivning", "type": "long_text", "label": "Hur stärker utbildningen din ställning på arbetsmarknaden?", "section": "studier", "guidance": "Det här är prövningens kärna: koppla utbildningen till faktisk efterfrågan — en bransch som rekryterar, en roll din arbetsgivare behöver. Söktrycket är högt och generiska motiveringar sållas bort.", "required": true, "maxLength": 4000}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "arbetsliv", "title": "Ditt arbetsliv"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.634948+00'),
	('6d8230f1-fb10-4719-a034-8b51b3840654', 'db95c200-883b-4831-8ae4-32d0920f47df', 1, '{"id": "vinnova-innovativa-startups-v1", "title": "Ansökan — Vinnova Innovativa startups (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Bolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "losning_beskrivning", "type": "long_text", "label": "Beskriv lösningen och vad som är nyskapande", "section": "losning", "guidance": "Vad finns i dag, och vad gör er lösning väsentligt bättre? Vinnova jämför mot faktiska alternativ — belägg väger tyngre än vision.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "kundbevis", "type": "long_text", "label": "Vilka belägg finns för efterfrågan?", "section": "marknad", "guidance": "Kunddialoger, piloter, avsiktsförklaringar, betalande användare — det ni faktiskt har.", "required": true, "maxLength": 3000}, {"key": "team_beskrivning", "type": "long_text", "label": "Teamet och dess förmåga att genomföra", "section": "marknad", "guidance": "Roller, relevant erfarenhet och hur mycket tid nyckelpersonerna lägger.", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "budget", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "max": 300000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Bolaget"}, {"key": "losning", "title": "Lösningen"}, {"key": "marknad", "title": "Marknad och team"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.637113+00'),
	('0ef64bb6-9656-4c0f-bed2-efd32359406d', 'c27ea324-63d0-4d09-bb82-ece7b5b489da', 1, '{"id": "tillvaxtverket-affarsutvecklingscheckar-v1", "title": "Ansökan — Affärsutvecklingscheck (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_anstallda", "max": 500, "min": 0, "type": "number", "label": "Antal anställda", "section": "foretag", "guidance": "Checkarna riktar sig typiskt till företag med 2–49 anställda — regionens villkor styr.", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv utvecklingsinsatsen", "section": "insats", "guidance": "Vad ska den externa kompetensen göra, och vad ska vara annorlunda i företaget efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "extern_leverantor", "type": "text", "label": "Extern leverantör/konsult (om känd)", "section": "insats", "required": false, "maxLength": 200}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "guidance": "Checken täcker normalt högst hälften av kostnaden — resten är egen insats.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "insats", "title": "Utvecklingsinsatsen"}, {"key": "budget", "title": "Kostnad och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.638852+00'),
	('5e5e2694-6b22-48ac-be49-4fa67eff471b', '5f815fab-d207-4dcb-afc2-067cd1b19845', 1, '{"id": "tillvaxtverket-regionalt-investeringsstod-v1", "title": "Ansökan — Regionalt investeringsstöd (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsort", "type": "text", "label": "Verksamhetsort (kommun)", "section": "foretag", "guidance": "Orten avgör stödområdestillhörigheten (A/B) och därmed stödnivån.", "required": true, "maxLength": 100}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Byggnader, maskiner eller inventarier — och hur investeringen ökar sysselsättningen eller konkurrenskraften på orten.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjas före ansökan", "section": "investering", "guidance": "En påbörjad investering diskvalificerar hela ansökan — beställ inget förrän ansökan är inne.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "investering", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "investering", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.640651+00'),
	('4a33abdd-c8ee-4025-8bf9-a8306342f10e', '5f0a8992-a4cc-439b-8f1d-a633a7a927cf', 1, '{"id": "jordbruksverket-startstod-unga-v1", "title": "Ansökan — Startstöd unga jordbrukare (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten", "section": "foretaget", "guidance": "Inriktning (växtodling, djurhållning, trädgård, rennäring), omfattning och om du startar nytt eller tar över.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "overtagande_datum", "type": "date", "label": "Datum för start eller övertagande", "section": "foretaget", "required": true}, {"key": "utbildning_erfarenhet", "type": "long_text", "label": "Din utbildning och erfarenhet inom området", "section": "plan", "guidance": "Naturbruksutbildning, kurser eller praktisk erfarenhet — kravet kan uppfyllas på flera sätt.", "required": true, "maxLength": 2000}, {"key": "har_affarsplan", "type": "boolean", "label": "Finns en skriftlig affärsplan?", "section": "plan", "guidance": "Affärsplanen är obligatorisk bilaga hos Jordbruksverket.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "foretaget", "title": "Företaget du startar eller tar över"}, {"key": "plan", "title": "Affärsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.642209+00'),
	('1411e146-a4ba-4756-b569-de00186cd6f3', 'f8d08a0c-0441-4056-b78c-c9cd4bf46fa5', 1, '{"id": "jordbruksverket-investeringsstod-v1", "title": "Ansökan — Investeringsstöd jordbruk (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller företag)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Vad ska byggas eller köpas, och hur stärker det verksamheten (produktion, djurvälfärd, miljö, energi)?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad investeringskostnad (kr)", "section": "investering", "guidance": "Offerter styrker kalkylen — stödandelen räknas på faktiska kostnader.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjats före ansökan", "section": "investering", "required": true}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.643501+00'),
	('ca1b9b54-b146-48a6-9327-89febaeaf5d3', '2d9fbfd5-ae38-441d-89ac-aa02ae23f34b', 1, '{"id": "rf-lok-stod-v1", "title": "Ansökan — LOK-stöd (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "forbund", "type": "text", "label": "Specialidrottsförbund", "section": "forening", "guidance": "T.ex. Svenska Fotbollförbundet — anslutningen är ett krav.", "required": true, "maxLength": 200}, {"key": "antal_aktiviteter", "max": 10000, "min": 1, "type": "number", "label": "Ungefärligt antal gruppaktiviteter per termin (deltagare 7–25 år)", "section": "verksamhet", "guidance": "LOK-stödet räknas per genomförd gruppaktivitet och deltagare — närvaroregistrering i IdrottOnline är underlaget.", "required": true}, {"key": "registrerar_narvaro", "type": "boolean", "label": "Registrerar föreningen närvaro digitalt (t.ex. IdrottOnline)?", "section": "verksamhet", "guidance": "Utan närvaroregistrering kan stödet inte betalas ut — börja registrera innan perioden ansöks.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Föreningen"}, {"key": "verksamhet", "title": "Aktiviteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.644863+00'),
	('a4de6ebc-7a0a-42cd-86f1-eb59c17ab7cc', '9b083b0a-67aa-4540-bd3e-0676600e1de9', 1, '{"id": "kulturradet-skapande-skola-v1", "title": "Ansökan — Skapande skola (förberedelse)", "fields": [{"key": "huvudman_namn", "type": "text", "label": "Huvudmannens namn", "section": "huvudman", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "huvudman", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_elever", "max": 100000, "min": 1, "type": "number", "label": "Antal elever som omfattas", "section": "insatser", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv kulturinsatserna", "section": "insatser", "guidance": "Vilka professionella kulturaktörer, vilka konstformer, och hur eleverna är delaktiga — inte bara publik.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "lasar_period", "type": "date_range", "label": "Period (läsår)", "section": "insatser", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "huvudman", "title": "Huvudmannen"}, {"key": "insatser", "title": "Kulturinsatserna"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.64635+00'),
	('2c5ed51b-2136-4bfa-9670-4537eb7d6227', '68ad80de-f7af-44ed-bad3-55f51c8b3377', 1, '{"id": "konstnarsnamnden-internationellt-kulturutbyte-v1", "title": "Ansökan — Internationellt kulturutbyte (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "utbyte_beskrivning", "type": "long_text", "label": "Beskriv utbytet", "section": "utbyte", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling just nu?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utbyte_period", "type": "date_range", "label": "Period", "section": "utbyte", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Finns en inbjudan eller bekräftelse från mottagande part?", "section": "utbyte", "guidance": "Inbjudan väger tungt — utan den bedöms utbytet som oplanerat.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "utbyte", "title": "Utbytet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.647725+00'),
	('8489e4fe-03db-497c-8ec0-cb646c7658f9', 'c7c974ed-19c6-4236-932e-c313ddaff86a', 1, '{"id": "filminstitutet-kortfilmsstod-v1", "title": "Ansökan — Kortfilmsstöd (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Produktionsbolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "film_titel", "type": "text", "label": "Filmens arbetstitel", "section": "film", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "synopsis", "type": "long_text", "label": "Synopsis och konstnärlig vision", "section": "film", "guidance": "Berättelsen, formen och varför den här filmen behöver göras — konsulenten läser hundratals, det specifika bär.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "regissor", "type": "text", "label": "Regissör och tidigare verk", "section": "film", "required": true, "maxLength": 300}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Produktionsbolaget"}, {"key": "film", "title": "Filmen"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.649091+00'),
	('be49183f-e7a3-4505-9eba-7db08e3a7e48', '8604efc7-3a5a-4d59-a5cf-c891177ae55c', 1, '{"id": "musikverket-projektbidrag-v1", "title": "Ansökan — Musikverket projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv musikprojektet", "section": "projekt", "guidance": "Vad ska göras, av vilka, och vad tillför det musiklivet utöver er egen verksamhet?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "medverkande", "type": "long_text", "label": "Medverkande musiker/aktörer", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.650335+00'),
	('22dcfa80-43d9-4694-bc1c-e20d3f94ac68', 'a2a2b258-0466-4347-a8c0-429a5f25878f', 1, '{"id": "postkodstiftelsen-projektstod-v1", "title": "Ansökan — Postkodstiftelsen projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Ett avgränsat projekt med tydlig början och slut — stiftelsen finansierar inte löpande verksamhet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "forvantad_effekt", "type": "long_text", "label": "Vilken förändring ska projektet åstadkomma?", "section": "projekt", "guidance": "Formulera som förändring för målgruppen, inte som aktiviteter.", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.65165+00'),
	('8e1394fc-18fe-4312-88f2-40b163f6bb69', 'a6f2e8dc-c1db-4d01-8d6a-2bc9b8b9dc0c', 1, '{"id": "mucf-organisationsbidrag-v1", "title": "Ansökan — MUCF organisationsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_medlemmar", "max": 1000000, "min": 1, "type": "number", "label": "Totalt antal medlemmar", "section": "medlemmar", "required": true}, {"key": "andel_unga", "max": 100, "min": 0, "type": "percentage", "label": "Andel medlemmar 6–25 år (%)", "section": "medlemmar", "guidance": "Kravet är minst 60 % — medlemsregistret är underlaget och MUCF granskar det.", "required": true}, {"key": "antal_medlemsforeningar", "max": 10000, "min": 1, "type": "number", "label": "Antal medlemsföreningar/lokalavdelningar", "section": "medlemmar", "guidance": "Nationell spridning krävs — normalt verksamhet i minst fem län.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "medlemmar", "title": "Medlemmar och struktur"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.653153+00'),
	('a2193ea3-45e6-4f81-b11d-9d5dc0766502', '47c90689-76cb-4190-a2ba-077827aff474', 1, '{"id": "kreativa-europa-samarbetsprojekt-v1", "title": "Ansökan — Kreativa Europa samarbetsprojekt (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partnerskap_beskrivning", "type": "long_text", "label": "Partnerskapet (organisationer och länder)", "section": "projekt", "guidance": "Minst tre organisationer från tre olika länder krävs — ange samtliga med land.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och dess europeiska dimension", "section": "projekt", "guidance": "Vad tillför samarbetet som inte hade hänt nationellt? EU-mervärdet är ett bedömningskriterium, inte en formalitet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.666523+00'),
	('bbe59adf-c8ba-4b0f-8808-9df1b5e0b2de', '8ae331d3-fc63-4bbb-82a1-cb5088109734', 1, '{"id": "boverket-allmanna-samlingslokaler-v1", "title": "Ansökan — Stöd till allmänna samlingslokaler (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Föreningens/stiftelsens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "lokal_beskrivning", "type": "long_text", "label": "Beskriv lokalen och hur den används av allmänheten", "section": "lokal", "guidance": "Öppenheten är kravet: vilka utomstående grupper använder lokalen i dag, och hur bokar de?", "required": true, "maxLength": 3000}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Vad ska byggas, köpas eller rustas upp?", "section": "lokal", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "budget", "guidance": "Stödet täcker högst halva kostnaden — resten är egen finansiering.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "lokal", "title": "Lokalen och åtgärden"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.654477+00'),
	('5a7d9b2a-5ece-497b-973a-403dd66d695f', 'ceb42f7b-50cf-412b-b657-c17fb34a1670', 1, '{"id": "naturvardsverket-ladda-bilen-v1", "title": "Ansökan — Ladda bilen (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_laddpunkter", "max": 1000, "min": 1, "type": "number", "label": "Antal laddpunkter", "section": "laddning", "required": true}, {"key": "plats_beskrivning", "type": "long_text", "label": "Var installeras laddpunkterna, och vilka använder dem?", "section": "laddning", "guidance": "Stödet gäller laddning för boende eller anställda — inte publika laddstationer.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "laddning", "guidance": "Bidraget är högst halva kostnaden per laddpunkt, med takbelopp.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "laddning", "title": "Laddpunkterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.655779+00'),
	('467388d5-74bf-4a2a-9e04-c809ac6bda21', 'e1feccd1-97a2-4cb1-948a-19fadfd3a7f0', 1, '{"id": "raa-kulturarvsbidrag-v1", "title": "Ansökan — Kulturarvsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv kulturarvsinsatsen", "section": "projekt", "guidance": "Vad ska bevaras, användas eller utvecklas — och hur blir det tillgängligt för fler?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.65712+00'),
	('3475c29c-8e5c-41e4-a7a7-59215c55fa39', 'a02f598a-09c8-4129-8315-6d1ebd533849', 1, '{"id": "lansstyrelsen-bygdemedel-v1", "title": "Ansökan — Bygdemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Föreningens/kommunens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "bygd_beskrivning", "type": "long_text", "label": "Vilken bygd gäller det, och hur berörs den av vatten- eller vindkraft?", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Allmännyttan är kravet: vem i bygden får glädje av investeringen, utöver den egna föreningen?", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.658308+00'),
	('ee91e977-e075-4563-a64b-498b87919fa1', 'e9b3b976-f814-4785-8c7f-efccf761b102', 1, '{"id": "csn-utlandsstudier-v1", "title": "Ansökan — Studiemedel för utlandsstudier (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "studie_land", "type": "text", "label": "Studieland", "section": "studier", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "utbildning", "type": "text", "label": "Utbildning och lärosäte", "section": "studier", "guidance": "Kontrollera att utbildningen är godkänd för studiemedel i CSN:s tjänst INNAN du tackar ja till platsen.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "terminsavgift", "min": 0, "type": "currency", "label": "Terminsavgift om sådan finns (kr)", "section": "studier", "guidance": "Merkostnadslån kan täcka undervisningsavgifter — lämna tomt om avgift saknas.", "required": false}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna utomlands"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.684806+00'),
	('81a5a7ba-96b2-40da-a31d-2258df3c2a6a', '3174c73f-fa02-42c7-98ca-7cfbd9b1a49f', 1, '{"id": "kulturradet-verksamhetsbidrag-scenkonst-v1", "title": "Ansökan — Verksamhetsbidrag scenkonst (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Gruppens/organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten kommande år", "section": "verksamhet", "guidance": "Repertoar, produktioner, spelplatser och publik — verksamhetsbidraget bedöms på helheten, inte enskilda projekt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "antal_forestallningar", "max": 2000, "min": 1, "type": "number", "label": "Planerat antal föreställningar per år", "section": "verksamhet", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Gruppen/organisationen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.659791+00'),
	('62b9446c-ae4f-4236-9fe9-4c64c6a9f36f', 'd67f3673-e33d-456c-a45b-976af2fb0880', 1, '{"id": "konstnarsnamnden-arbetsstipendium-v1", "title": "Ansökan — Arbetsstipendium (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstområde", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv din konstnärliga verksamhet och dina planer", "section": "verksamhet", "guidance": "Stipendiet bedöms på konstnärlig kvalitet och aktivitet — konkreta verk, uppdrag och planer väger tyngre än ambitioner.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "meriter", "type": "long_text", "label": "Viktigaste verk och uppdrag (senaste åren)", "section": "verksamhet", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Din konstnärliga verksamhet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.661367+00'),
	('3ee1705b-4eb6-4324-8bbb-619b8b04c066', '3be8b47f-055c-472e-901e-f52f0158f9af', 1, '{"id": "konstnarsnamnden-kulturbryggan-v1", "title": "Ansökan — Kulturbryggan (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vad som är nyskapande", "section": "projekt", "guidance": "Kulturbryggan finansierar det oprövade — beskriv vad som skiljer projektet från befintlig praxis, inte bara att det är nytt för er.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "ovriga_finansiarer", "type": "long_text", "label": "Övriga finansiärer (sökta eller beviljade)", "section": "projekt", "guidance": "Kulturbryggan ser gärna fler finansieringskällor — redovisa öppet vad som är sökt respektive beviljat.", "required": false, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.662519+00'),
	('83d49291-1584-490e-b43a-b925b629df19', 'f3562a14-d093-4de5-9114-2fc93393517f', 1, '{"id": "erasmus-mobilitet-skola-vuxen-v1", "title": "Ansökan — Erasmus+ mobilitet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System — utan OID kan ansökan inte lämnas in.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "mobilitet_beskrivning", "type": "long_text", "label": "Beskriv mobiliteterna och deras syfte", "section": "mobilitet", "guidance": "Vilka åker, vart, och hur tas lärdomarna om hand i organisationen efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_deltagare", "max": 500, "min": 1, "type": "number", "label": "Antal deltagare", "section": "mobilitet", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "mobilitet", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "mobilitet", "title": "Mobiliteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.663777+00'),
	('4180e58f-cd57-4303-88fb-ed8c9956961c', 'f556dd02-23ba-44f5-9628-d1975855f2fd', 1, '{"id": "erasmus-ka2-smaskaliga-partnerskap-v1", "title": "Ansökan — Erasmus+ småskaliga partnerskap (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "partnerskap", "guidance": "Minst en partner i ett annat programland krävs.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv samarbetet", "section": "partnerskap", "guidance": "Småskaliga partnerskap är instegsformatet — enklare aktiviteter, lägre budget, men samma krav på tydligt syfte.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "partnerskap", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "partnerskap", "title": "Partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.665268+00'),
	('6ff68b47-0390-414a-8f8f-42f61ae09ee6', '1aae92ae-585c-4746-8ad1-e3b5e1caff85', 1, '{"id": "vinnova-planeringsbidrag-eu-v1", "title": "Ansökan — Planeringsbidrag EU-ansökan (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "eu_utlysning", "type": "text", "label": "Vilken EU-utlysning avser ni att söka?", "section": "eu", "guidance": "Program och utlysningsnamn — planeringsbidraget kräver ett konkret mål.", "required": true, "maxLength": 300}, {"key": "planering_beskrivning", "type": "long_text", "label": "Vad ska planeringsarbetet omfatta?", "section": "eu", "guidance": "Konsortiebyggande, ansökningsskrivning, resor — det bidraget faktiskt får användas till.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "eu", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "eu", "title": "EU-ansökan som planeras"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.667859+00'),
	('9625bb3e-dd3c-4c58-a2b1-b4870e57f743', '13e01367-6210-4cf6-aecc-89f98fc1bf3a', 1, '{"id": "mucf-solidaritetskaren-v1", "title": "Ansökan — Europeiska solidaritetskåren (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "har_kvalitetsmarkning", "type": "boolean", "label": "Har organisationen giltig Quality Label?", "section": "org", "guidance": "Kvalitetsmärkningen söks separat och måste finnas innan volontärprojekt kan beviljas.", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv volontärprojektet", "section": "volontar", "guidance": "Vad gör volontärerna, vilket stöd får de, och vilken nytta skapar projektet lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_volontarer", "max": 100, "min": 1, "type": "number", "label": "Antal volontärer", "section": "volontar", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "volontar", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "volontar", "title": "Volontärprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.669204+00'),
	('785dc0cb-f0a7-4e18-a776-2c903b3a73e9', 'e7025e12-9ea0-4cf0-ba68-c23b1b9e8cf7', 1, '{"id": "esf-kompetensutveckling-v1", "title": "Ansökan — ESF kompetensutveckling (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka anställda/deltagare omfattas, och vad behöver de?", "section": "insats", "guidance": "ESF bedömer kopplingen till arbetsmarknadens behov — konkret kompetensgap, inte allmän utbildning.", "required": true, "maxLength": 4000}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv insatserna", "section": "insats", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kan_forfinansiera", "type": "boolean", "label": "Kan organisationen förfinansiera kostnaderna?", "section": "ekonomi", "guidance": "ESF betalar ut i efterskott mot redovisning — likviditeten måste bära projektet under tiden.", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "insats", "required": true, "canonicalKey": "project.dateRange"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "ekonomi", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "insats", "title": "Kompetensinsatsen"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.670458+00'),
	('f9ed9525-c16f-424c-9c8c-18cff50e31ee', '7232f6a3-7855-4491-8882-b561314bf0ff', 1, '{"id": "si-creative-force-v1", "title": "Ansökan — Creative Force (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "projekt", "guidance": "Ett etablerat partnerskap i mållandet är kärnan i programmet.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Hur stärker projektet demokrati, yttrandefrihet eller mänskliga rättigheter genom kultur eller media? Mekanismen bedöms, inte avsikten.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnern"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.671947+00'),
	('29dcb92c-0b50-43a6-9336-ab48666dd69f', 'ce5b2ae0-9e39-408a-84d8-9de9317c749e', 1, '{"id": "radiohjalpen-projektbidrag-v1", "title": "Ansökan — Radiohjälpens projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "niokonto", "type": "text", "label": "90-kontonummer", "section": "sokande", "guidance": "T.ex. 90 1234-5. Kontot kontrolleras mot Svensk Insamlingskontroll.", "required": true, "maxLength": 20}, {"key": "fond", "type": "select", "label": "Vilken utlysning/fond söker ni ur?", "options": [{"label": "Världens Barn", "value": "varldens_barn"}, {"label": "Musikhjälpen", "value": "musikhjalpen"}, {"label": "Victoriafonden", "value": "victoriafonden"}, {"label": "Annan aktuell utlysning", "value": "other"}], "section": "projekt", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.701989+00'),
	('e8e5eb31-4cfc-4779-aaf8-4f9d872225e6', '7df24286-ffcc-47d3-8736-331afe557653', 1, '{"id": "vr-projektbidrag-v1", "title": "Ansökan — Vetenskapsrådet projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "har_doktorsexamen", "type": "boolean", "label": "Har du doktorsexamen?", "section": "sokande", "guidance": "Behörighetskrav — examensår kan påverka vilka bidragsformer som är öppna.", "required": true}, {"key": "larosate", "type": "text", "label": "Medelsförvaltande lärosäte", "section": "sokande", "guidance": "Bidraget förvaltas av ett svenskt lärosäte — det ska bekräfta åtagandet.", "required": true, "maxLength": 200}, {"key": "forskningsplan", "type": "long_text", "label": "Forskningsplanens kärna", "section": "forskning", "guidance": "Frågeställning, metod och förväntade resultat — sakkunniggranskningen bedömer originalitet och genomförbarhet.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "forskning", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "forskning", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Forskaren"}, {"key": "forskning", "title": "Forskningsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.673169+00');
INSERT INTO public.application_schemas VALUES
	('be58545f-d13a-4800-9e7c-f0731794026d', 'dc3ad4d7-8317-48e5-bf45-124fa60aba6b', 1, '{"id": "energimyndigheten-energieffektivisering-v1", "title": "Ansökan — Stöd till energieffektivisering (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv energiåtgärden", "section": "atgard", "guidance": "Vilken energianvändning minskas, med vilken teknik, och vad är beräknad besparing i kWh?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "besparing_kwh", "max": 100000000, "min": 1, "type": "number", "label": "Beräknad energibesparing (kWh/år)", "section": "atgard", "guidance": "En energikartläggning eller leverantörsberäkning styrker siffran.", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "atgard", "title": "Åtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.674353+00'),
	('97447348-1960-43fc-8892-0b14850c6b2e', '1bcfc883-6093-466a-bf78-5a177218d0b4', 1, '{"id": "energimyndigheten-industriklivet-v1", "title": "Ansökan — Industriklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och utsläppsminskningen", "section": "projekt", "guidance": "Industriklivet finansierar åtgärder mot processutsläpp — kvantifiera minskningen i CO2-ekvivalenter och beskriv teknikens mognadsgrad.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 100000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "projekt", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.675592+00'),
	('a903b6d9-3954-46e3-abed-f79a6d4a9a2e', '8ba650c8-c0e3-415f-bec5-21d25efa64a5', 1, '{"id": "naturvardsverket-klimatklivet-v1", "title": "Ansökan — Klimatklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Sökandens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv åtgärden", "section": "atgard", "guidance": "Klimatklivet rangordnar på klimatnytta per investerad krona — utsläppsminskningen ska vara beräknad och beräkningen redovisbar.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 10000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "atgard", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Investeringskostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att åtgärden inte påbörjats före ansökan", "section": "atgard", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Sökande"}, {"key": "atgard", "title": "Klimatåtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.6768+00'),
	('23982ac7-eff3-44e8-9305-75f1a089415e', 'eed373fb-4bfa-4f65-9437-9152403b4266', 1, '{"id": "naturvardsverket-lona-v1", "title": "Ansökan — LONA lokala naturvårdssatsningen (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "guidance": "LONA söks via kommunen — föreningar deltar som initiativtagare.", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommun", "type": "text", "label": "Kommun som står bakom ansökan", "section": "sokande", "required": true, "maxLength": 100}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv naturvårdsinsatsen", "section": "projekt", "guidance": "Vad görs, var, och vilken naturvårds- eller friluftsnytta skapas lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "guidance": "LONA täcker högst halva kostnaden.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Naturvårdsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.67808+00'),
	('ac27d9f5-bfde-469b-903d-35357f5d6763', 'b17fbe89-6a8c-443c-8481-e75be0561798', 1, '{"id": "kulturradet-inkopsstod-bibliotek-v1", "title": "Ansökan — Inköpsstöd till folkbibliotek (förberedelse)", "fields": [{"key": "kommun_namn", "type": "text", "label": "Kommunens namn", "section": "kommun", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "kommun", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "inkop_beskrivning", "type": "long_text", "label": "Hur ska stödet användas?", "section": "inkop", "guidance": "Inköp av litteratur för barn och unga prioriteras; stödet får inte ersätta kommunens egen medieanslag — egeninsatsen ska bestå.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "eget_anslag", "min": 0, "type": "currency", "label": "Kommunens eget medieanslag i år (kr)", "section": "inkop", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "inkop", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "kommun", "title": "Kommunen"}, {"key": "inkop", "title": "Inköpen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.679412+00'),
	('924507c8-de68-4386-a2eb-159fc672863c', '649b98f4-5f25-47c6-a7b0-b89f0f7d8920', 1, '{"id": "kulturradet-litteraturstod-v1", "title": "Ansökan — Litteraturstöd (förberedelse)", "fields": [{"key": "forlag_namn", "type": "text", "label": "Förlagets namn", "section": "forlag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forlag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "titel", "type": "text", "label": "Titel och författare", "section": "titel", "required": true, "maxLength": 300, "canonicalKey": "project.title"}, {"key": "titel_beskrivning", "type": "long_text", "label": "Beskriv utgivningen", "section": "titel", "guidance": "Litteraturstödet söks efter utgivning och bedöms på kvalitet — beskriv verket sakligt, inte säljande.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "upplaga", "max": 1000000, "min": 1, "type": "number", "label": "Upplaga (exemplar)", "section": "titel", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forlag", "title": "Förlaget"}, {"key": "titel", "title": "Titeln"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.680722+00'),
	('e41aa520-d71f-4352-ab21-c61f384b3e44', '48f5a3c2-7682-456d-aac6-90f3c3b2b7c0', 1, '{"id": "migrationsverket-atervandringsbidrag-v1", "title": "Ansökan — Stöd vid frivillig återvandring (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "ursprungsland", "type": "text", "label": "Land du planerar att återvandra till", "section": "atervandring", "required": true, "maxLength": 100}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet som återvandrar", "section": "atervandring", "required": true}, {"key": "planerad_utresa", "type": "date", "label": "Planerad utresa", "section": "atervandring", "required": true}, {"key": "situation_beskrivning", "type": "long_text", "label": "Beskriv din plan för återetableringen", "section": "atervandring", "guidance": "Boende, försörjning och nätverk i ursprungslandet. OBS: beslutet är oåterkalleligt i bidragshänseende — uppehållstillståndet återkallas normalt. Ta det lugnt med beslutet och kontrollera aktuella belopp hos Migrationsverket.", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "atervandring", "title": "Återvandringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.682176+00'),
	('866dd815-2f27-46e6-aed6-daa9e5c7f964', '6420b212-cc32-4590-ba27-a768d9824dae', 1, '{"id": "af-eures-targeted-mobility-v1", "title": "Ansökan — EURES Targeted Mobility (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "mal_land", "type": "text", "label": "Land där jobbet finns", "section": "jobbet", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "jobb_status", "type": "select", "label": "Var i processen är du?", "options": [{"label": "Kallad till intervju", "value": "interview"}, {"label": "Har jobberbjudande", "value": "offer"}, {"label": "Söker aktivt", "value": "searching"}], "section": "jobbet", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Vilket stöd behöver du?", "section": "jobbet", "guidance": "Intervjuresa, flyttkostnad, språkkurs eller erkännande av examen — beloppen är schabloner per insats. EURES-rådgivaren bekräftar vad som gäller din programperiod.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "jobbet", "title": "Jobbet och flytten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.683542+00'),
	('496abb10-5246-4fe5-8b4d-57e1117b3cb7', '4e5edd9a-5515-4838-8bd6-bddb852f6b48', 1, '{"id": "fk-omvardnadsbidrag-v1", "title": "Ansökan — Omvårdnadsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv barnets funktionsnedsättning", "section": "barnet", "guidance": "Diagnos eller svårigheter i vardagen — läkarutlåtandet bär den medicinska bedömningen, din beskrivning bär vardagen.", "required": true, "maxLength": 3000}, {"key": "omvardnadsbehov", "type": "long_text", "label": "Vilken extra omvårdnad och tillsyn behöver barnet?", "section": "barnet", "guidance": "Jämför med barn i samma ålder: vad kräver mer tid, närvaro eller passning — dygnet runt-perspektivet räknas.", "required": true, "maxLength": 4000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om barnets funktionsnedsättning?", "section": "barnet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och behoven"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.686074+00'),
	('6c36a115-6599-4b8b-b065-ecaac8cd430b', '8377bf76-b7f9-4bed-a818-32689e0d11fd', 1, '{"id": "fk-merkostnadsersattning-v1", "title": "Ansökan — Merkostnadsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "galler_barn", "type": "boolean", "label": "Gäller ansökan ett barn du är vårdnadshavare för?", "section": "sokande", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen", "section": "sokande", "required": true, "maxLength": 3000}, {"key": "merkostnader_ar", "min": 0, "type": "currency", "label": "Uppskattade merkostnader per år (kr)", "section": "kostnader", "guidance": "Räkna bara kostnader du inte skulle ha utan funktionsnedsättningen — och dra av eventuella bidrag som redan täcker dem.", "required": true}, {"key": "merkostnader_beskrivning", "type": "long_text", "label": "Specificera merkostnaderna", "section": "kostnader", "guidance": "Post för post: vad, hur ofta, ungefär vad det kostar per år. Kvitton och intyg stärker.", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "kostnader", "title": "Merkostnaderna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.687175+00'),
	('410c4c76-30fd-4a37-b0aa-d014a99e43ba', 'a19bf016-211f-4861-8b46-b2da65c57d7c', 1, '{"id": "fk-bilstod-v1", "title": "Ansökan — Bilstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "forflyttning", "type": "long_text", "label": "Beskriv svårigheterna att förflytta dig eller resa kollektivt", "section": "behov", "guidance": "Konkret: vad går inte, vad krävs för att det ska gå, och hur varaktigt är det?", "required": true, "maxLength": 4000}, {"key": "har_korkort", "type": "boolean", "label": "Har du (eller den som ska köra) körkort?", "section": "behov", "required": true}, {"key": "behov_anpassning", "type": "long_text", "label": "Behöver bilen anpassas — i så fall hur?", "section": "behov", "guidance": "T.ex. handreglage, ramp eller lyft. Lämna tomt om du inte vet ännu — behovet utreds.", "required": false, "maxLength": 2000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om funktionsnedsättningen?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Förflyttningsbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.688545+00'),
	('08e44df1-bf9a-4cbf-b7ba-ff26b51abaa4', 'f4c46b41-fd43-494e-9d7d-21d576bc30de', 1, '{"id": "fk-narstaendepenning-v1", "title": "Ansökan — Närståendepenning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "relation", "type": "text", "label": "Din relation till den som är sjuk", "section": "varden", "guidance": "T.ex. förälder, barn, syskon, vän — närstående är den som står den sjuke nära.", "required": true, "maxLength": 200}, {"key": "vard_period", "type": "date_range", "label": "Period du avstår från arbete", "section": "varden", "required": true, "canonicalKey": "project.dateRange"}, {"key": "omfattning", "type": "select", "label": "Omfattning", "options": [{"label": "Hel dag", "value": "full"}, {"label": "Tre fjärdedelar", "value": "three_quarters"}, {"label": "Halv dag", "value": "half"}, {"label": "En fjärdedel", "value": "quarter"}], "section": "varden", "required": true}, {"key": "har_samtycke", "type": "boolean", "label": "Har den sjuke samtyckt till ansökan?", "section": "varden", "guidance": "Samtycke krävs när det är möjligt att lämna.", "required": true}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om den närståendes tillstånd?", "section": "varden", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "varden", "title": "Vården och tiden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.689797+00'),
	('dce8aef2-b7a6-4cea-8038-cc50dd0b1aaa', '02d3c6b1-ba09-49bc-9c92-913e9c8eca86', 1, '{"id": "af-etableringsersattning-v1", "title": "Ansökan — Etableringsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "uppehallstillstand_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år fick du uppehållstillstånd?", "section": "sokande", "required": true}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven hos Arbetsförmedlingen?", "section": "etablering", "guidance": "Etableringsprogrammet förutsätter inskrivning — börja där om du inte redan är inskriven.", "required": true}, {"key": "har_barn_hemma", "type": "boolean", "label": "Har du barn som bor hos dig?", "section": "etablering", "guidance": "Med barn hemma kan etableringstillägg bli aktuellt hos Försäkringskassan.", "required": true}, {"key": "bor_ensam", "type": "boolean", "label": "Bor du ensam i egen bostad?", "section": "etablering", "guidance": "Den som bor ensam kan ha rätt till bostadsersättning.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "etablering", "title": "Etableringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.691136+00'),
	('fc14707c-7872-4143-8ada-4f8eb0991e3c', '7d56e2e5-be39-4a81-a96e-48fa4f599d8a', 1, '{"id": "csn-hemutrustningslan-v1", "title": "Ansökan — Hemutrustningslån (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommunmottagande_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år togs du emot i en kommun?", "section": "sokande", "guidance": "Lånet söks inom två år från det första kommunmottagandet.", "required": true}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet", "section": "hemmet", "required": true}, {"key": "bostad_typ", "type": "select", "label": "Är bostaden möblerad eller omöblerad?", "options": [{"label": "Omöblerad", "value": "unfurnished"}, {"label": "Möblerad", "value": "furnished"}], "section": "hemmet", "guidance": "Lånebeloppet skiljer sig — omöblerad bostad ger högre lån.", "required": true}, {"key": "aterbetalning_medveten", "type": "boolean", "label": "Jag är medveten om att detta är ett lån som ska betalas tillbaka", "section": "hemmet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hemmet", "title": "Hemmet och behovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.692437+00'),
	('a13357f7-32ef-40c4-a290-e5fd830398b5', '7cdbb754-c472-4d4a-8377-ef5bbbb6d62f', 1, '{"id": "csn-studiestartsstod-v1", "title": "Ansökan — Studiestartsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "tidigare_utbildning", "type": "select", "label": "Din senast avslutade utbildning", "options": [{"label": "Grundskola eller kortare", "value": "grundskola"}, {"label": "Påbörjat men inte slutfört gymnasium", "value": "gymnasium_ej_klart"}, {"label": "Slutfört gymnasium", "value": "gymnasium"}], "section": "sokande", "required": true}, {"key": "kommun_kontaktad", "type": "boolean", "label": "Har du kontaktat hemkommunen om studiestartsstödet?", "section": "studier", "guidance": "Kommunen bedömer om du tillhör målgruppen innan CSN kan bevilja.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du vill gå", "section": "studier", "guidance": "Grundskole- eller gymnasienivå, t.ex. komvux.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.693723+00'),
	('5b7deeb8-45df-45d3-a378-3d4c9eb496f2', 'd424bb27-1491-44a6-8fa7-c99108c6f89e', 1, '{"id": "csn-inackorderingstillagg-v1", "title": "Ansökan — Inackorderingstillägg (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Elevens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skola och ort", "section": "boendet", "required": true, "maxLength": 300}, {"key": "skoltyp", "type": "select", "label": "Vilken typ av skola?", "options": [{"label": "Fristående gymnasieskola", "value": "independent"}, {"label": "Folkhögskola", "value": "folk_high"}, {"label": "Kommunal gymnasieskola", "value": "municipal"}], "section": "boendet", "guidance": "Fristående skola och folkhögskola → CSN. Kommunal skola → hemkommunen.", "required": true}, {"key": "resvag", "type": "long_text", "label": "Beskriv resvägen mellan hemmet och skolan", "section": "boendet", "guidance": "Avstånd och restid — varför daglig pendling inte fungerar.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om eleven"}, {"key": "boendet", "title": "Skolan och boendet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.694802+00'),
	('0061bd7a-e0d6-4a4f-ac26-4877f1e0b938', '146e1dad-6a01-4db9-8a1c-a255842d6cd6', 1, '{"id": "kommun-foreningsbidrag-v1", "title": "Ansökan — Kommunalt föreningsbidrag (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "medlemsantal", "max": 1000000, "min": 1, "type": "number", "label": "Antal medlemmar", "section": "forening", "required": true}, {"key": "bidragstyp", "type": "select", "label": "Vilket bidrag söker ni?", "options": [{"label": "Aktivitetsstöd (per deltagartillfälle)", "value": "activity"}, {"label": "Lokalbidrag", "value": "venue"}, {"label": "Startbidrag för ny förening", "value": "start"}, {"label": "Annat/vet inte ännu", "value": "other"}], "section": "verksamhet", "required": true}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten i kommunen", "section": "verksamhet", "guidance": "Vad ni gör, hur ofta, för vilka — särskilt barn- och ungdomsverksamhet.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Om föreningen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.695934+00'),
	('eb6dfa76-f734-449a-80fa-bd248948f33a', 'ef5d306b-f30d-48dd-908d-6a43e751ed94', 1, '{"id": "region-kulturstod-v1", "title": "Ansökan — Regionalt kulturstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "regional_forankring", "type": "long_text", "label": "Beskriv er förankring i regionen", "section": "sokande", "guidance": "Säte, verksamhetsort, publik och samarbeten i regionen.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.697141+00'),
	('5ffc2560-c76f-44f9-b47a-cf1171e68836', '63cecab0-051b-4fa9-b4f3-e6213bc29ae6', 1, '{"id": "sparbanksstiftelsen-projektstod-v1", "title": "Ansökan — Sparbanksstiftelsens projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsomrade", "type": "text", "label": "Ort/område där projektet genomförs", "section": "projekt", "guidance": "Stiftelsen stödjer bara projekt i den egna sparbankens verksamhetsområde.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vem det kommer till del", "section": "projekt", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.6985+00'),
	('9e9e9e9c-b327-4de5-91b4-ee37283654c6', 'b2dc12b1-327d-4fae-b797-695f6914b21b', 1, '{"id": "leader-lokalt-ledd-utveckling-v1", "title": "Ansökan — Leader-projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "leaderomrade", "type": "text", "label": "Vilket leaderområde tillhör ni?", "section": "projekt", "guidance": "Osäker? Sök på \"leaderområde\" + din kommun — kansliet hjälper till.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Koppla till leaderområdets utvecklingsstrategi — lokal förankring och samarbete väger tungt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "likviditet", "type": "long_text", "label": "Hur klarar ni likviditeten tills stödet betalas ut?", "section": "budget", "guidance": "Leaderstöd betalas ut i efterhand mot redovisade kostnader.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.699643+00'),
	('920f84f6-b41f-4a2e-ae0d-3414d3820314', 'f881cabb-599c-4f1d-ae72-a82823c5c7ed', 1, '{"id": "forte-projektbidrag-v1", "title": "Ansökan — Forte projektbidrag (förberedelse)", "fields": [{"key": "projektledare", "type": "text", "label": "Projektledarens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "medelsforvaltare", "type": "text", "label": "Medelsförvaltare (lärosäte)", "section": "sokande", "required": true, "maxLength": 300}, {"key": "disputationsar", "max": 2100, "min": 1950, "type": "number", "label": "Projektledarens disputationsår", "section": "sokande", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv forskningsprojektet", "section": "projekt", "guidance": "Frågeställning, metod och relevans för hälsa, arbetsliv eller välfärd — sakligt och prövbart.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Projektledare och medelsförvaltare"}, {"key": "projekt", "title": "Forskningsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 19:05:47.700856+00');


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
	('2161428e-0588-46cc-b1b2-93c4fdeccf93', 'Kulturrådet', 'SE', 'state_agency', 'https://kulturradet.se', '2026-08-28 19:05:47.057719+00'),
	('64a93432-3fdd-4fb4-b6b8-ec17e6f31535', 'MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor', 'SE', 'state_agency', 'https://www.mucf.se', '2026-08-28 19:05:47.061054+00'),
	('683e4116-b793-4d36-9499-703f0a8f15c3', 'Vinnova', 'SE', 'state_agency', 'https://www.vinnova.se', '2026-08-28 19:05:47.063198+00'),
	('08248302-d932-4084-a794-f2d8ed80e057', 'Tillväxtverket', 'SE', 'state_agency', 'https://tillvaxtverket.se', '2026-08-28 19:05:47.064953+00'),
	('6e4cedc0-be21-481f-b811-9b4115bec533', 'Energimyndigheten', 'SE', 'state_agency', 'https://www.energimyndigheten.se', '2026-08-28 19:05:47.067234+00'),
	('13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', 'Naturvårdsverket', 'SE', 'state_agency', 'https://www.naturvardsverket.se', '2026-08-28 19:05:47.068843+00'),
	('b2e0436a-46a5-4353-840c-daecf935e86a', 'Jordbruksverket', 'SE', 'state_agency', 'https://jordbruksverket.se', '2026-08-28 19:05:47.070216+00'),
	('1eed7774-bfb5-4636-b097-a6ecbf93b734', 'Svenska ESF-rådet', 'SE', 'state_agency', 'https://www.esf.se', '2026-08-28 19:05:47.071645+00'),
	('13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', 'Europeiska kommissionen (Erasmus+/EACEA)', 'EU', 'eu', 'https://erasmus-plus.ec.europa.eu', '2026-08-28 19:05:47.073145+00'),
	('afded389-82d6-46aa-9b9e-7c62d0d2afbb', 'UHR — Universitets- och högskolerådet', 'SE', 'state_agency', 'https://www.uhr.se', '2026-08-28 19:05:47.074611+00'),
	('7aadc7e1-b039-4488-83bc-b5eaf129c863', 'Konstnärsnämnden', 'SE', 'state_agency', 'https://www.konstnarsnamnden.se', '2026-08-28 19:05:47.075871+00'),
	('31e8e2f5-52a5-4682-9ca6-cdb2c77ffe18', 'Allmänna arvsfonden', 'SE', 'foundation', 'https://www.arvsfonden.se', '2026-08-28 19:05:47.077201+00'),
	('54851904-35b4-4dfc-9140-1daceb1ef85f', 'Boverket', 'SE', 'state_agency', 'https://www.boverket.se', '2026-08-28 19:05:47.078306+00'),
	('70576e97-1033-4edc-a69c-bfa1190af574', 'Riksidrottsförbundet', 'SE', 'association', 'https://www.rf.se', '2026-08-28 19:05:47.079359+00'),
	('1784f0ae-7080-4e92-b714-37ae106ce213', 'Svenska Filminstitutet', 'SE', 'foundation', 'https://www.filminstitutet.se', '2026-08-28 19:05:47.080447+00'),
	('e89c9252-43be-40a8-a1c5-8977f0997df4', 'Formas', 'SE', 'state_agency', 'https://www.formas.se', '2026-08-28 19:05:47.081521+00'),
	('1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Försäkringskassan', 'SE', 'state_agency', 'https://www.forsakringskassan.se', '2026-08-28 19:05:47.082526+00'),
	('8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'CSN — Centrala studiestödsnämnden', 'SE', 'state_agency', 'https://www.csn.se', '2026-08-28 19:05:47.083602+00'),
	('6b993806-e6f5-43e3-b37e-542c6b2952bc', 'Pensionsmyndigheten', 'SE', 'state_agency', 'https://www.pensionsmyndigheten.se', '2026-08-28 19:05:47.084907+00'),
	('96346af8-c105-4f07-a823-ab8648762e19', 'Socialtjänsten i din kommun', 'SE', 'municipality', 'https://www.socialstyrelsen.se', '2026-08-28 19:05:47.086161+00'),
	('dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'Arbetsförmedlingen', 'SE', 'state_agency', 'https://arbetsformedlingen.se', '2026-08-28 19:05:47.087371+00'),
	('114e913f-a8a0-48a0-97df-33ebfee16ea8', 'Din kommun', 'SE', 'municipality', NULL, '2026-08-28 19:05:47.088633+00'),
	('289fbe84-3d6a-4d62-ae45-9e2f284a0761', 'Riksantikvarieämbetet', 'SE', 'state_agency', 'https://www.raa.se', '2026-08-28 19:05:47.089829+00'),
	('471d5586-a07e-4256-8a02-4923cc1b9b19', 'Svenska institutet', 'SE', 'state_agency', 'https://si.se', '2026-08-28 19:05:47.090962+00'),
	('d8174b27-1934-450d-909e-74445d1cdf5d', 'Nordisk kulturfond', 'DK', 'foundation', 'https://www.nordiskkulturfond.org', '2026-08-28 19:05:47.092321+00'),
	('e4ccb9a5-dc99-4045-8368-14f3110e7ee0', 'Vetenskapsrådet', 'SE', 'state_agency', 'https://www.vr.se', '2026-08-28 19:05:47.093603+00'),
	('1180e0a9-e60d-40d5-a4bb-8c0658834f19', 'Svenska Postkodstiftelsen', 'SE', 'foundation', 'https://postkodstiftelsen.se', '2026-08-28 19:05:47.094706+00'),
	('5c2016b6-f733-4a4f-9f06-1bacb2cda675', 'Statens musikverk', 'SE', 'state_agency', 'https://musikverket.se', '2026-08-28 19:05:47.095876+00'),
	('cb2c2570-e8f4-4bc3-86fb-c1985027fdb6', 'Länsstyrelsen i ditt län', 'SE', 'region', 'https://www.lansstyrelsen.se', '2026-08-28 19:05:47.097603+00'),
	('4a35ddab-675d-42d2-9775-a483285ec84e', 'Din region', 'SE', 'region', 'https://www.1177.se', '2026-08-28 19:05:47.098781+00'),
	('6b8aaecc-daad-4dd2-b30e-35ac2f695e82', 'Majblommans Riksförbund', 'SE', 'foundation', 'https://majblomman.se', '2026-08-28 19:05:47.09999+00'),
	('7cd7f6c5-33de-49cf-9959-ecfdf7406b3d', 'Migrationsverket', 'SE', 'state_agency', 'https://www.migrationsverket.se', '2026-08-28 19:05:47.101255+00'),
	('0b29c47b-a9ee-422e-b3cf-70cc3d40d453', 'Forte — Forskningsrådet för hälsa, arbetsliv och välfärd', 'SE', 'state_agency', 'https://forte.se', '2026-08-28 19:05:47.102438+00'),
	('f8ad8f1e-4686-4fa9-bd93-8104df989a2d', 'Sparbanksstiftelsen i ditt område', 'SE', 'foundation', 'https://www.sparbankerna.se', '2026-08-28 19:05:47.103631+00'),
	('5bb1059c-7173-484a-a36c-9d907d2b60ac', 'Radiohjälpen', 'SE', 'foundation', 'https://www.radiohjalpen.se', '2026-08-28 19:05:47.104897+00'),
	('335178e6-1b98-4482-a282-2b6788dd7622', 'Din a-kassa', 'SE', 'association', 'https://www.sverigesakassor.se', '2026-08-28 19:05:47.106662+00');


--
-- Data for Name: funding_opportunities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_opportunities VALUES
	('bd265af5-d31d-47ef-b64d-ae35aa93362a', '2161428e-0588-46cc-b1b2-93c4fdeccf93', '22cd4506-0053-4daf-a022-a6eddccc1723', 'kulturradet-internationellt-resebidrag-musik', 'Kulturrådet — Resebidrag för internationellt kulturutbyte', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Stödet riktar sig till yrkesverksamma kulturskapare i Sverige som deltar i internationellt kulturutbyte, till exempel gästspel, samarbetsprojekt eller kompetensutveckling utomlands. Bidraget kan täcka resekostnader och relaterade omkostnader. Kontrollera alltid aktuella villkor hos Kulturrådet.', 'Främja internationellt kulturutbyte och svenska kulturskapares internationella närvaro.', 'travel_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-09-24 21:59:59+00', NULL, 'Ansökan görs i Kulturrådets onlinetjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', '6fc16817-ff85-4696-bd8d-eacea52402cf', 'be4aa506-118b-4c76-9be2-e99b1484b03d', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.168604+00', '2026-08-28 19:05:47.168604+00'),
	('7de4b8a9-195b-4254-b82b-11d5969f2e97', '13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', 'b892dd64-5aba-4ab4-8654-4ccaaedcbf97', 'erasmus-plus-ungdomsutbyten', 'Erasmus+ — Ungdomsutbyten (Youth Exchanges)', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Ungdomsutbyten inom Erasmus+ låter grupper av unga från olika länder mötas i 5–21 dagar (exklusive resa) kring ett gemensamt program. Stödet täcker resekostnader samt praktiska kostnader och aktivitetskostnader enligt programguidens schabloner. Ansökan görs av en organisation eller informell grupp via det nationella programkontoret (i Sverige: MUCF för ungdomsdelen). Organisationen behöver ett OID (Organisation ID) via EU:s Organisation Registration System.', 'Interkulturellt lärande, ungas delaktighet och europeiskt samarbete.', 'eu_grant', '["association", "informal_group", "municipality"]', '["SE"]', '["youth", "culture", "education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, '2026-10-01 10:00:00+00', NULL, 'Ansökan lämnas i EU:s ansökningssystem för Erasmus+ (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'eu_login', 'assisted', 15, '', 'published', '7888917f-1645-4e04-a6c2-64dca560b859', 'c3461f54-92f2-42ef-85f9-61dab97f2664', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.177428+00', '2026-08-28 19:05:47.177428+00'),
	('af44e2ea-2fdf-483f-8220-8e0cd6284d42', '64a93432-3fdd-4fb4-b6b8-ec17e6f31535', '6f404808-e918-4d50-927a-014529b3c8c3', 'mucf-projektbidrag-ungdomsorganisationer', 'MUCF — Projektbidrag för barn- och ungdomsorganisationer', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'MUCF fördelar statsbidrag till civilsamhällets organisationer, bland annat projektbidrag för verksamhet med och för barn och unga. Bidragen har specifika villkor per utlysning — kontrollera alltid aktuell utlysning hos MUCF.', 'Stärka ungas delaktighet och civilsamhällets verksamhet för barn och unga.', 'project_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i MUCF:s ansökningssystem när en utlysning är öppen.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', '814cecd0-3b11-43f7-b5a5-7259f5ec28a0', '424f27c6-b6b9-4c43-a492-bfc953e7b3a4', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.183478+00', '2026-08-28 19:05:47.183478+00'),
	('db95c200-883b-4831-8ae4-32d0920f47df', '683e4116-b793-4d36-9499-703f0a8f15c3', '038d86c9-6e42-47af-b9d2-ac87f2b3c095', 'vinnova-innovativa-startups', 'Vinnova — Innovativa startups', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Vinnovas program för innovativa startups riktar sig till unga svenska aktiebolag med skalbara, nyskapande lösningar. Utlysningar öppnar i omgångar med specifika villkor per omgång — kontrollera aktuell utlysning hos Vinnova. Bidraget kräver normalt att bolaget är yngre än en viss ålder och har begränsad omsättning.', 'Stärka svenska startups förmåga att utveckla och kommersialisera innovationer.', 'public_grant', '["company"]', '["SE"]', '["innovation", "technology"]', NULL, 30000000, 'SEK', 100, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst (Intressentportalen).', 'https://www.vinnova.se/soka-finansiering/', 'vinnova_konto', 'assisted', 10, '', 'published', '224af18f-dd5e-460d-ba78-9e0b7f1d415d', '3193dbf3-67b8-4c00-893f-0526f32d5dbf', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.189567+00', '2026-08-28 19:05:47.189567+00'),
	('dc3ad4d7-8317-48e5-bf45-124fa60aba6b', '6e4cedc0-be21-481f-b811-9b4115bec533', '61f9d8b8-e09f-4ee2-a043-60f6f960427f', 'energimyndigheten-energieffektivisering', 'Energimyndigheten — Stöd för energi- och klimatprojekt (löpande utlysningar)', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Det mesta av Energimyndighetens stöd fördelas via utlysningar som öppnar löpande inom olika områden. Ansökan och ärendehantering sker via Mina sidor. Villkoren varierar per utlysning — den här posten representerar programområdet; kontrollera aktuella utlysningar hos Energimyndigheten.', 'Energiomställning: forskning, innovation och effektivare energianvändning.', 'public_grant', '["company", "university", "public_body", "association", "economic_association"]', '["SE"]', '["energy", "environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 12, '', 'published', 'c477fe27-47a6-4f34-a1e9-2a79ac6caece', 'c0684838-2412-4109-998e-42deeed44275', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.195451+00', '2026-08-28 19:05:47.195451+00'),
	('ceb42f7b-50cf-412b-b657-c17fb34a1670', '13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', '6d745e26-c06a-4b60-bff8-10e7df0f465d', 'naturvardsverket-ladda-bilen-organisationer', 'Naturvårdsverket — Bidrag för miljö- och klimatåtgärder (organisationer)', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket administrerar flera bidrag inom miljö- och klimatområdet, uppdelade efter mottagartyp (organisationer, företag, ekonomiska föreningar, offentlig sektor och privatpersoner). Villkoren varierar per bidrag — den här posten representerar området; kontrollera aktuellt bidrag hos Naturvårdsverket.', 'Miljö- och klimatåtgärder i hela samhället.', 'public_grant', '["association", "company", "economic_association", "public_body", "individual"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänster.', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 6, '', 'published', 'cae9796b-1c1b-4df6-a6eb-ee0c0c60afcd', 'a5a5d737-1389-4cf6-930a-1bf6d09c3d48', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.202633+00', '2026-08-28 19:05:47.202633+00'),
	('ca268aa9-7310-4769-ba9a-36aa0deb1e23', '2161428e-0588-46cc-b1b2-93c4fdeccf93', '26c86284-acd2-4ddf-9720-d962c0487aae', 'kulturradet-projektbidrag-musik', 'Kulturrådet — Projektbidrag musik (fria musiklivet)', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Kulturrådet fördelar projektbidrag till det fria musiklivet. Bidraget söks av grupper, arrangörer och organisationer inom musikområdet. Villkor och ansökningsperioder publiceras per omgång på Kulturrådets webbplats.', 'Ett levande och oberoende musikliv i hela landet.', 'project_grant', '["association", "company", "individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Kulturrådets onlinetjänst när omgången är öppen.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 7, '', 'published', '1376db7c-290a-4412-b54d-e1442edde20e', 'be4aa506-118b-4c76-9be2-e99b1484b03d', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.210169+00', '2026-08-28 19:05:47.210169+00'),
	('68ad80de-f7af-44ed-bad3-55f51c8b3377', '7aadc7e1-b039-4488-83bc-b5eaf129c863', '62cfe78b-a0b7-47f9-aff5-aff9946fda44', 'konstnarsnamnden-internationellt-kulturutbyte', 'Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Konstnärsnämnden ger bidrag till yrkesverksamma konstnärer inom bild, form, dans, film, musik och teater för internationellt kulturutbyte — t.ex. resor för samarbeten, gästspel eller arbetsvistelser utomlands. Ansökningsomgångar publiceras per konstområde; kontrollera aktuella tider hos Konstnärsnämnden.', 'Konstnärers internationalisering och konstnärliga utveckling.', 'travel_grant', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 4, '', 'published', '183c3313-bcf8-4000-a54a-e1d0689efceb', '1b168247-5d70-4cd4-89ac-e8904fb05df8', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.21721+00', '2026-08-28 19:05:47.21721+00'),
	('d67f3673-e33d-456c-a45b-976af2fb0880', '7aadc7e1-b039-4488-83bc-b5eaf129c863', '100593e9-0455-4c99-9084-3e997ffdceb6', 'konstnarsnamnden-arbetsstipendium', 'Konstnärsnämnden — Arbetsstipendium', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Arbetsstipendiet ska ge yrkesverksamma konstnärer ekonomiskt utrymme att utveckla sitt konstnärskap. Söks per konstområde i årliga omgångar; villkor och tider publiceras av Konstnärsnämnden.', 'Konstnärlig fördjupning och försörjningstrygghet för yrkesverksamma konstnärer.', 'stipend', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 6, '', 'published', '3e6da4c3-46a2-45da-b0cd-9aabde1f646f', '1b168247-5d70-4cd4-89ac-e8904fb05df8', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.222666+00', '2026-08-28 19:05:47.222666+00'),
	('b5dc8e07-05f0-4313-b71b-3d8b1f8fd1cd', '31e8e2f5-52a5-4682-9ca6-cdb2c77ffe18', 'f05d2785-3a7a-45d3-900b-6884464e066a', 'arvsfonden-projektstod', 'Allmänna arvsfonden — Projektstöd', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Arvsfonden stödjer ideella organisationers utvecklingsprojekt som är nyskapande och där målgruppen — barn, ungdomar, äldre eller personer med funktionsnedsättning — är delaktig. Ansökan kan lämnas löpande; projekt kan pågå i upp till tre år.', 'Nyskapande och utvecklande verksamhet för fondens målgrupper.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.arvsfonden.se/soka-pengar', 'none', 'assisted', 12, '', 'published', '9b1159aa-056a-4050-90df-e61c1a6bdaeb', '9bbc1204-2894-4776-a08f-603080d7598f', 'https://www.arvsfonden.se/soka-pengar', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.228205+00', '2026-08-28 19:05:47.228205+00'),
	('8ae331d3-fc63-4bbb-82a1-cb5088109734', '54851904-35b4-4dfc-9140-1daceb1ef85f', '7f5daa4d-1faa-40df-a351-b75a0fbb7412', 'boverket-allmanna-samlingslokaler', 'Boverket — Investeringsbidrag till allmänna samlingslokaler', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Boverket ger investeringsbidrag till föreningar och stiftelser för nybyggnad, ombyggnad, köp eller standardhöjande reparationer av allmänna samlingslokaler — t.ex. bygdegårdar, folkets hus och föreningslokaler. Årlig ansökningsomgång; villkor publiceras av Boverket.', 'Tillgång till lokaler för möten, kultur och fritid i hela landet.', 'public_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "culture"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.boverket.se/sv/bidrag--garantier/', 'eid', 'assisted', 10, '', 'published', 'fe091ab4-d199-4fb0-ad58-89f7916fc58e', '5974e338-d649-4513-9b87-b1a24bb77ba9', 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.234071+00', '2026-08-28 19:05:47.234071+00'),
	('2d9fbfd5-ae38-441d-89ac-aa02ae23f34b', '70576e97-1033-4edc-a69c-bfa1190af574', '1dcfe040-4b5e-45a4-a457-2b36bcd2b7a0', 'rf-lok-stod', 'Riksidrottsförbundet — Statligt lokalt aktivitetsstöd (LOK-stöd)', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'LOK-stödet ger idrottsföreningar anslutna till ett specialidrottsförbund ersättning per sammankomst och deltagartillfälle för ledarledd verksamhet för deltagare 7–25 år. Redovisas i IdrottOnline två gånger per år.', 'Stödja föreningsdriven barn- och ungdomsidrott.', 'public_grant', '["association"]', '["SE"]', '["sports", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-08-25 21:59:59+00', NULL, 'Ansökan/redovisning görs i IdrottOnline. Ansökningsperioderna stänger 25 februari och 25 augusti.', 'https://www.rf.se/bidrag-och-stod', 'none', 'assisted', 2, '', 'published', '75bb0ad8-9bbd-4399-850d-a8b02240bac3', 'fe246359-cd7a-4b9c-9fe2-692affa52366', 'https://www.rf.se/bidrag-och-stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.239777+00', '2026-08-28 19:05:47.239777+00'),
	('c7c974ed-19c6-4236-932e-c313ddaff86a', '1784f0ae-7080-4e92-b714-37ae106ce213', 'aefc254b-0026-4241-b358-5c2b9490a9ce', 'filminstitutet-kortfilmsstod', 'Svenska Filminstitutet — Stöd till kort- och dokumentärfilm', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Filminstitutet ger utvecklings- och produktionsstöd till kort- och dokumentärfilm. Stödet söks normalt av ett produktionsbolag; beslut fattas av filmkonsulent. Villkor och ansökningstider publiceras per stödform.', 'Konstnärligt värdefull svensk film.', 'project_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.filminstitutet.se/sv/sok-stod/', 'none', 'assisted', 8, '', 'published', 'f814b2ac-f4e5-4d34-9534-3edd34304888', 'c4f2f986-e144-4468-80dc-fc5e904255b8', 'https://www.filminstitutet.se/sv/sok-stod/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.245402+00', '2026-08-28 19:05:47.245402+00'),
	('9b083b0a-67aa-4540-bd3e-0676600e1de9', '2161428e-0588-46cc-b1b2-93c4fdeccf93', '79033582-18b0-4c54-97c1-74adf0d944c7', 'kulturradet-skapande-skola', 'Kulturrådet — Skapande skola', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Skapande skola söks av skolhuvudmän (kommuner, fristående skolor) för konst- och kulturinsatser i förskoleklass och grundskola, genomförda av professionella kulturaktörer. Årlig ansökningsomgång.', 'Att alla elever ska få möta professionell konst och kultur.', 'public_grant', '["municipality", "school", "company"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 6, '', 'published', '7b14ad1c-b414-4e41-80d6-1fba8d32f387', 'be4aa506-118b-4c76-9be2-e99b1484b03d', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.250653+00', '2026-08-28 19:05:47.250653+00'),
	('83578d3a-2a6d-4262-ba0f-4a122d9bdf95', 'e89c9252-43be-40a8-a1c5-8977f0997df4', '3d66703c-0b74-4260-a268-5c3075333f99', 'formas-oppna-utlysningen', 'Formas — Årliga öppna utlysningen', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Formas årliga öppna utlysning finansierar forskningsprojekt inom miljö, areella näringar och samhällsbyggande. Söks av disputerade forskare vid svenska lärosäten och forskningsinstitut. Årlig omgång med publicerade tider.', 'Kunskap för hållbar utveckling.', 'public_grant', '["university", "public_body"]', '["SE"]', '["environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.formas.se/soka-finansiering.html', 'none', 'assisted', 20, '', 'published', 'c04f7fdc-b59c-4a53-953b-1f12d18f176a', '66399e93-991b-41bd-bd5b-940d943a2ebb', 'https://www.formas.se/soka-finansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.255874+00', '2026-08-28 19:05:47.255874+00'),
	('c27ea324-63d0-4d09-bb82-ece7b5b489da', '08248302-d932-4084-a794-f2d8ed80e057', '59b37f6f-fbcc-433f-9b63-ad2c0fb04ee7', 'tillvaxtverket-affarsutvecklingscheckar', 'Tillväxtverket — Affärsutvecklingscheckar (internationalisering/digitalisering)', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Affärsutvecklingscheckarna hjälper små företag att köpa extern kompetens för att utvecklas internationellt eller digitalt. Checkarna administreras regionalt; belopp, andelar och tider varierar per region — kontrollera din regions aktuella utlysning.', 'Stärkt konkurrenskraft i små företag.', 'public_grant', '["company"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', 50, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) när regionens omgång är öppen.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 6, '', 'published', 'c85564f3-bb46-4224-9997-4affca685161', 'f8b3dd5c-2b4b-4250-9424-bf147f6a2ff5', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.261952+00', '2026-08-28 19:05:47.261952+00'),
	('5f0a8992-a4cc-439b-8f1d-a633a7a927cf', 'b2e0436a-46a5-4353-840c-daecf935e86a', '40f5a0f4-6869-4cc8-84b0-21c167cb4020', 'jordbruksverket-startstod-unga', 'Jordbruksverket — Startstöd till unga jordbrukare', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Startstödet riktar sig till unga som startar eller tar över jordbruks-, trädgårds- eller rennäringsföretag. Kräver bl.a. åldersgräns, utbildning/erfarenhet och en affärsplan. Ansökan görs i Jordbruksverkets e-tjänst med e-legitimation.', 'Generationsväxling och föryngring i jordbruket.', 'public_grant', '["individual", "company"]', '["SE"]', '["agriculture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation; fullmakt kan användas).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', '766e45b5-d01b-4aca-88ab-dc9aac1ef014', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.267572+00', '2026-08-28 19:05:47.267572+00'),
	('f8d08a0c-0441-4056-b78c-c9cd4bf46fa5', 'b2e0436a-46a5-4353-840c-daecf935e86a', '69380d7b-97d5-46fe-ae2f-a642192d90ff', 'jordbruksverket-investeringsstod', 'Jordbruksverket — Investeringsstöd för jordbruk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Investeringsstöd kan sökas för t.ex. djurstallar, växthus, energieffektivisering och miljöåtgärder i jordbruksföretag. Villkor, stödandelar och regionala prioriteringar framgår av aktuell stödinformation hos Jordbruksverket.', 'Konkurrenskraftigt och hållbart jordbruk.', 'public_grant', '["company", "individual", "economic_association"]', '["SE"]', '["agriculture", "environment"]', NULL, NULL, 'SEK', 40, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', '3483791e-9cd1-4a5f-af50-c49044d1033b', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.272575+00', '2026-08-28 19:05:47.272575+00'),
	('e7025e12-9ea0-4cf0-ba68-c23b1b9e8cf7', '1eed7774-bfb5-4636-b097-a6ecbf93b734', 'eca45477-1041-4011-a35d-6fb1200c8595', 'esf-kompetensutveckling', 'Svenska ESF-rådet — ESF+ projektstöd för kompetensutveckling och omställning', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Svenska ESF-rådet utlyser projektmedel ur Europeiska socialfonden+ i regionala och nationella utlysningar, t.ex. kompetensutveckling för anställda och insatser för personer långt från arbetsmarknaden. Villkor och medfinansieringskrav framgår per utlysning i utlysningsplanen.', 'En väl fungerande och inkluderande arbetsmarknad.', 'eu_grant', '["company", "association", "municipality", "region", "public_body", "university"]', '["SE"]', '["education", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i ESF-rådets Projektrummet när en utlysning är öppen.', 'https://www.esf.se/utlysningar/', 'none', 'assisted', 15, '', 'published', 'b6f411f6-fc9a-4b61-9221-9b3013ca891a', '98a8b717-b60c-4286-938f-1d9cbfea367c', 'https://www.esf.se/utlysningar/utlysningsplan/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.277889+00', '2026-08-28 19:05:47.277889+00'),
	('1bcfc883-6093-466a-bf78-5a177218d0b4', '6e4cedc0-be21-481f-b811-9b4115bec533', '8aace6af-ea04-4fc6-a9dc-2aceb49302a3', 'energimyndigheten-industriklivet', 'Energimyndigheten — Industriklivet', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Industriklivet stödjer forskning, förstudier och investeringar som minskar industrins processrelaterade utsläpp samt negativa utsläpp (t.ex. bio-CCS). Söks löpande eller i utlysningar via Mina sidor.', 'Industrins klimatomställning.', 'public_grant', '["company", "university", "public_body"]', '["SE"]', '["energy", "environment"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 15, '', 'published', 'f40fd884-1c28-4521-a3a6-7b9913e8751b', 'c0684838-2412-4109-998e-42deeed44275', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.283334+00', '2026-08-28 19:05:47.283334+00'),
	('8ba650c8-c0e3-415f-bec5-21d25efa64a5', '13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', 'e365e766-f69f-4128-b7a5-9a70d26035ca', 'naturvardsverket-klimatklivet', 'Naturvårdsverket — Klimatklivet', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Klimatklivet ger investeringsstöd till företag, kommuner, regioner och organisationer för åtgärder som ger stor klimatnytta per stödkrona — t.ex. laddinfrastruktur, biogas och energikonvertering. Ansökningsomgångar öppnar flera gånger per år.', 'Minskade växthusgasutsläpp.', 'public_grant', '["company", "municipality", "region", "association", "economic_association", "public_body"]', '["SE"]', '["environment", "energy"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänst när en omgång är öppen (kräver e-legitimation).', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 8, '', 'published', '70be0db9-1554-4ec0-951d-444e8ce1d421', 'a5a5d737-1389-4cf6-930a-1bf6d09c3d48', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.28861+00', '2026-08-28 19:05:47.28861+00'),
	('eed373fb-4bfa-4f65-9437-9152403b4266', '13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', 'ecdbaa77-c0bf-4333-8207-7b4f13ff8b66', 'naturvardsverket-lona', 'Naturvårdsverket — Lokala naturvårdssatsningen (LONA)', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'LONA ger upp till 50 % (våtmarksprojekt upp till 90 %) i bidrag till naturvårds- och friluftslivsprojekt. Kommunen ansöker hos länsstyrelsen, men lokala föreningar kan initiera projekt genom sin kommun.', 'Lokalt naturvårdsengagemang och friluftsliv.', 'public_grant', '["municipality"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Kommunen ansöker via länsstyrelsen; föreningar initierar via sin kommun.', 'https://www.naturvardsverket.se/bidrag/', 'none', 'assisted', 6, '', 'published', '85aa27a3-fabf-4e39-a4a1-4d399b4fb486', 'a5a5d737-1389-4cf6-930a-1bf6d09c3d48', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.293979+00', '2026-08-28 19:05:47.293979+00'),
	('13e01367-6210-4cf6-aecc-89f98fc1bf3a', '64a93432-3fdd-4fb4-b6b8-ec17e6f31535', '5d752450-cff3-46f8-bc2b-efe0ae7f0173', 'mucf-solidaritetskaren-volontarprojekt', 'MUCF — Europeiska solidaritetskåren: volontärprojekt', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Europeiska solidaritetskåren finansierar volontärprojekt där unga 18–30 år gör volontärtjänst i ett annat land eller i Sverige. Organisationen behöver en kvalitetsmärkning (Quality Label) och ett OID. MUCF är nationellt programkontor.', 'Ungas engagemang och solidaritet i Europa.', 'eu_grant', '["association", "municipality", "public_body"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login, OID och Quality Label).', 'https://www.mucf.se/bidrag', 'eu_login', 'assisted', 12, '', 'published', 'fcce3646-2be5-4ef6-8b1c-6d9ecffe6298', '424f27c6-b6b9-4c43-a492-bfc953e7b3a4', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.299004+00', '2026-08-28 19:05:47.299004+00'),
	('f3562a14-d093-4de5-9114-2fc93393517f', 'afded389-82d6-46aa-9b9e-7c62d0d2afbb', '4779960d-fa4c-48ed-a20b-666c13bd001f', 'erasmus-mobilitet-skola-vuxen', 'Erasmus+ — Mobilitet för skola och vuxenutbildning (KA1)', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Erasmus+ KA1 ger skolor, förskolor och vuxenutbildningsorganisationer stöd för kompetensutveckling utomlands — jobbskuggning, kurser och undervisningsuppdrag samt elevmobilitet. UHR är nationellt programkontor för utbildningsdelen. Kräver OID; årliga ansökningsomgångar.', 'Internationalisering av svensk utbildning.', 'eu_grant', '["school", "municipality", "company", "association", "public_body"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://www.uhr.se/internationella-mojligheter/', 'eu_login', 'assisted', 12, '', 'published', 'd22e9911-71b0-444d-b6bd-b15c38df3839', 'e44bafc3-24db-4bd7-bff1-a41a8b817b72', 'https://www.uhr.se/internationella-mojligheter/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.304487+00', '2026-08-28 19:05:47.304487+00'),
	('47c90689-76cb-4190-a2ba-077827aff474', '13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', 'e8969c74-ca1e-44fb-811f-fa467fd94993', 'kreativa-europa-samarbetsprojekt', 'Kreativa Europa — Europeiska samarbetsprojekt (kultur)', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Kreativa Europas kulturprogram finansierar samarbetsprojekt mellan kulturorganisationer i minst tre programländer. Kulturrådet är kontaktkontor i Sverige för kulturdelen. Ansökan görs i EU:s Funding & Tenders-portal; årliga utlysningar.', 'Europeiskt kultursamarbete och cirkulation av konstnärliga verk.', 'eu_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', 80, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s Funding & Tenders-portal (kräver EU Login och PIC/OID).', 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'eu_login', 'assisted', 25, '', 'published', 'cdce65d6-4d4d-4e34-993b-9ddb200ea7f4', NULL, 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.310609+00', '2026-08-28 19:05:47.310609+00'),
	('3174c73f-fa02-42c7-98ca-7cfbd9b1a49f', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'b79a308f-f86a-4096-9584-5013750c045a', 'kulturradet-verksamhetsbidrag-scenkonst', 'Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Verksamhetsbidraget riktar sig till professionella fria scenkonstaktörer med kontinuerlig verksamhet av hög kvalitet. Söks i årlig omgång hos Kulturrådet.', 'Ett starkt fritt scenkonstliv i hela landet.', 'public_grant', '["association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 10, '', 'published', 'fb2a3b7c-be7d-49e9-9710-36a64fcb0679', 'be4aa506-118b-4c76-9be2-e99b1484b03d', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.318057+00', '2026-08-28 19:05:47.318057+00'),
	('1aae92ae-585c-4746-8ad1-e3b5e1caff85', '683e4116-b793-4d36-9499-703f0a8f15c3', 'd8ba5ee1-9c98-41bf-9cb8-c9530282c9db', 'vinnova-planeringsbidrag-eu', 'Vinnova — Planeringsbidrag för EU-ansökningar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Vinnova erbjuder återkommande planeringsbidrag som sänker tröskeln för svenska organisationer att söka EU-finansiering, t.ex. inför Horisont Europa-utlysningar och EIC Accelerator. Villkor per aktuell utlysning.', 'Ökat svenskt deltagande i EU:s ramprogram.', 'public_grant', '["company", "university", "public_body", "association"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst när en omgång är öppen.', 'https://www.vinnova.se/soka-finansiering/', 'none', 'assisted', 6, '', 'published', '4887e198-66c9-488a-a1ac-2eb4097b12c3', '3193dbf3-67b8-4c00-893f-0526f32d5dbf', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.324416+00', '2026-08-28 19:05:47.324416+00'),
	('a6f2e8dc-c1db-4d01-8d6a-2bc9b8b9dc0c', '64a93432-3fdd-4fb4-b6b8-ec17e6f31535', '4c62c4c5-0238-4349-89a0-eb9142031465', 'mucf-organisationsbidrag', 'MUCF — Organisationsbidrag till barn- och ungdomsorganisationer', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Organisationsbidraget söks årligen av nationella barn- och ungdomsorganisationer som uppfyller krav på bl.a. medlemsantal, åldersstruktur, demokratisk uppbyggnad och geografisk spridning. Villkoren framgår av förordning och MUCF:s anvisningar.', 'Ett starkt och självständigt ungdomscivilsamhälle.', 'public_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', 'd4572ef7-1397-40ff-9000-558dd7b573d4', '424f27c6-b6b9-4c43-a492-bfc953e7b3a4', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.329898+00', '2026-08-28 19:05:47.329898+00'),
	('fc5cf270-6d44-4083-ad1c-bfe5b9daa605', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'e8208264-134a-4aa1-b7bb-00bd1d562c6b', 'fk-bostadsbidrag-barnfamiljer', 'Försäkringskassan — Bostadsbidrag till barnfamiljer', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Bostadsbidrag kan lämnas till barnfamiljer med lägre inkomster som betalar för sitt boende. Beloppet beror på inkomst, boendekostnad, bostadens storlek och antal barn. Ansökan görs hos Försäkringskassan; bidraget är preliminärt och stäms av mot taxerad inkomst i efterhand.', 'Ekonomisk trygghet i boendet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '5e127516-d0fc-4c83-98a1-fc19f3662f26', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.334647+00', '2026-08-28 19:05:47.334647+00'),
	('2a2922ce-9a4d-4f6e-8a9f-94b69f4f08ec', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'a2a15cf5-7ee4-4299-927e-cd9d9f8fa074', 'fk-underhallsstod', 'Försäkringskassan — Underhållsstöd', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Underhållsstöd kan lämnas när föräldrar inte bor ihop, barnet bor varaktigt hos dig och den andra föräldern inte betalar underhållsbidrag eller betalar mindre än stödets nivå. Ansökan görs hos Försäkringskassan.', 'Barnets försörjning när underhåll uteblir.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'a8c76cfb-7bc9-4221-b5ee-cb546b95d914', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.379567+00', '2026-08-28 19:05:47.379567+00'),
	('df7edb7e-d12a-4f36-bed7-b4a07c6cec51', '6b993806-e6f5-43e3-b37e-542c6b2952bc', 'd7f11477-3517-4776-9f9c-ecbc50b32b78', 'pm-bostadstillagg', 'Pensionsmyndigheten — Bostadstillägg för pensionärer', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Bostadstillägg kan lämnas till den som tar ut hel allmän pension och har låga inkomster i förhållande till sin boendekostnad. Många som har rätt till tillägget söker det aldrig — det är värt att kontrollera. Ansökan görs hos Pensionsmyndigheten.', 'Ekonomisk trygghet i boendet för pensionärer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Pensionsmyndighetens webbplats (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '9e3c2e61-7f51-4dcc-8613-60cc30ba2feb', 'e3e530ee-2207-485f-9ce7-a2c703e61d8c', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.384838+00', '2026-08-28 19:05:47.384838+00'),
	('b20a46a6-bffc-4d54-8ff8-d86276fcf5fc', '6b993806-e6f5-43e3-b37e-542c6b2952bc', '8a8f843f-8d92-4d11-80e5-b7fb668addbd', 'pm-aldreforsorjningsstod', 'Pensionsmyndigheten — Äldreförsörjningsstöd', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Äldreförsörjningsstöd kan lämnas från riktåldern för pension (67 år från 2026) till den som inte får sina grundläggande behov tillgodosedda genom pension och andra inkomster. Prövas tillsammans med bostadstillägg. Ansökan görs hos Pensionsmyndigheten.', 'Skälig levnadsnivå för äldre.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Pensionsmyndigheten (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '18d3ccce-a1e1-4cfe-9ada-32ec2d8734ff', 'e3e530ee-2207-485f-9ce7-a2c703e61d8c', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.389626+00', '2026-08-28 19:05:47.389626+00'),
	('a0ee3771-36b8-4bcd-b9f8-d98ec242eb47', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'dd514924-2371-422b-80aa-86ad4a89fe8f', 'af-stod-start-naringsverksamhet', 'Arbetsförmedlingen — Stöd till start av näringsverksamhet', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Den som är inskriven som arbetssökande och bedöms ha goda förutsättningar att driva företag kan få stöd (aktivitetsstöd) under verksamhetens uppstartsfas. Beslut fattas av Arbetsförmedlingen efter prövning av affärsplanen.', 'Väg från arbetslöshet till egen försörjning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Arbetsförmedlingen — kontakta din handläggare.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 5, '', 'published', '09bd5a8c-6180-460f-b637-738e5f389341', '068d3eb2-4c99-4221-818a-332737f04718', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.394329+00', '2026-08-28 19:05:47.394329+00'),
	('ffcaad8d-9445-421f-a38f-f75d58a5efe7', '4a35ddab-675d-42d2-9775-a483285ec84e', '3e1eae60-7da4-4ca8-8adc-bc54fe49bed4', 'region-glasogonbidrag-barn', 'Din region — Glasögonbidrag för barn och unga (8–19 år)', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Alla regioner är enligt lag (2016:35) skyldiga att ge bidrag för glasögon eller kontaktlinser till barn och unga 8–19 år som behöver synhjälpmedel. Lagen fastställer inget nationellt belopp — nivån bestäms per region och varierar. Ansökan sker oftast via optikern eller direkt till regionen — rutinerna skiljer sig, kontrollera din regions sidor och aktuellt belopp via 1177.', 'Alla barn ska ha råd med de synhjälpmedel de behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Vanligen via optikern eller regionens e-tjänst — se din regions rutin på 1177.se.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', '168e5b0c-2d19-4a3b-aeef-4a4d0368e78a', '57d7ab75-fce9-45b6-b3d4-eea6b05f948d', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.340274+00', '2026-08-28 19:05:47.340274+00'),
	('eccf68ab-be6b-47aa-8496-3f8eb94f5d4b', '6b8aaecc-daad-4dd2-b30e-35ac2f695e82', '51d2f25a-ceb9-4f10-9d40-d04e5ba221f4', 'majblomman-bidrag-barn', 'Majblomman — Bidrag till barn i familjer där pengarna inte räcker', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Majblommans lokalföreningar ger bidrag till barn upp till 18 år i familjer med knapp ekonomi. Det kan gälla en fritidsaktivitet, en cykel, kläder, en klassresa eller något annat konkret som barnet behöver. Ansökan görs till den lokala majblommeföreningen där barnet bor och kan göras av vårdnadshavare eller via t.ex. skolsköterska.', 'Alla barn ska kunna delta i sådant som andra barn tar för givet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan till din lokala majblommeförening via majblomman.se.', 'https://majblomman.se/', 'none', 'assisted', 1, '', 'published', '89c4f083-37a6-4dfb-81ba-dbbdcec825e8', '91a1b59c-fa58-453f-98f0-e74ba5fcef44', 'https://majblomman.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.345126+00', '2026-08-28 19:05:47.345126+00'),
	('41c414ba-6af3-4006-8650-ee358bba77fc', '114e913f-a8a0-48a0-97df-33ebfee16ea8', '459c5d00-a3eb-4db7-af72-c4ae24e7b809', 'kommun-skolskjuts', 'Din kommun — Skolskjuts i grundskolan', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Elever i grundskolan har enligt skollagen (10 kap. 32 §) rätt till kostnadsfri skolskjuts från hemkommunen om det behövs på grund av färdvägens längd, trafikförhållanden, funktionsnedsättning eller någon annan särskild omständighet. Kommunerna har egna avståndsgränser och rutiner — ansökan görs hos barnets hemkommun.', 'Alla barn ska kunna ta sig till skolan utan kostnad när vägen är lång eller osäker.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos barnets hemkommun (e-tjänst eller blankett).', 'https://www.skolverket.se/', 'none', 'assisted', 1, '', 'published', '6a5d16ed-77a4-48b3-80f8-884bc3ff9300', 'd375f390-715e-4bf8-8b50-0f010c4dfd52', 'https://www.skolverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.34999+00', '2026-08-28 19:05:47.34999+00'),
	('8604efc7-3a5a-4d59-a5cf-c891177ae55c', '5c2016b6-f733-4a4f-9f06-1bacb2cda675', 'fcecaae5-16ce-4fc4-acb9-efdc931a3dd8', 'musikverket-projektbidrag', 'Statens musikverk — Projektbidrag till musiklivet', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Musikverket fördelar projektbidrag till professionella samarbetsprojekt i det fria musiklivet, med särskilt fokus på förnyelse och jämställdhet. Utlysningsomgångar publiceras på musikverket.se.', 'Ett vitalt fritt musikliv.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://musikverket.se/', 'none', 'assisted', 6, '', 'published', '02b0bf53-bda1-4a29-8e13-191e718d17c3', 'e2f419fc-cedb-463f-9aac-ea45fd02e07a', 'https://musikverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.439063+00', '2026-08-28 19:05:47.439063+00'),
	('f556dd02-23ba-44f5-9628-d1975855f2fd', '13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', '5ad76025-c5b8-4bf7-922a-4e33bde026a6', 'erasmus-ka2-smaskaliga-partnerskap', 'Erasmus+ — Småskaliga partnerskap (KA2)', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Småskaliga partnerskap är utformade för att sänka tröskeln för organisationer som är nya i Erasmus+: färre krav, schablonbelopp (typiskt 30 000 eller 60 000 euro) och minst en partner i ett annat programland.', 'Bredda deltagandet i europeiskt samarbete.', 'eu_grant', '["association", "municipality", "school", "public_body"]', '["SE"]', '["education", "youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/', 'eu_login', 'assisted', 10, '', 'published', '585d8380-b181-4906-9771-2921a429dbf7', NULL, 'https://erasmus-plus.ec.europa.eu/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.443742+00', '2026-08-28 19:05:47.443742+00'),
	('5f815fab-d207-4dcb-afc2-067cd1b19845', '08248302-d932-4084-a794-f2d8ed80e057', '42ba6669-1fae-4860-9658-a9ff8286c631', 'tillvaxtverket-regionalt-investeringsstod', 'Tillväxtverket — Regionalt investeringsstöd', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Regionalt investeringsstöd kan delfinansiera större investeringar i stödområde A och B. Stödandel beror på område och företagsstorlek. Söks via Min ansökan.', 'Hållbar tillväxt i regioner med geografiska lägesnackdelar.', 'public_grant', '["company"]', '["SE"]', '[]', NULL, NULL, 'SEK', 35, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) innan investeringen påbörjas.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 12, '', 'published', 'd4222bd5-88b6-494e-b0bd-b0f678c4d938', 'f8b3dd5c-2b4b-4250-9424-bf147f6a2ff5', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.44869+00', '2026-08-28 19:05:47.44869+00'),
	('b17fbe89-6a8c-443c-8481-e75be0561798', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'dfbc44b4-5ea6-4781-9533-306bbfbf9a7e', 'kulturradet-inkopsstod-bibliotek', 'Kulturrådet — Inköpsstöd till folk- och skolbibliotek', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Inköpsstödet söks av kommuner för att stärka bibliotekens utbud av litteratur för barn och unga. Årlig omgång.', 'Läsfrämjande och tillgång till litteratur.', 'public_grant', '["municipality"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 3, '', 'published', '02309fa3-d42e-4921-a9ed-a115a5dc07fa', 'be4aa506-118b-4c76-9be2-e99b1484b03d', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.453797+00', '2026-08-28 19:05:47.453797+00'),
	('649b98f4-5f25-47c6-a7b0-b89f0f7d8920', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'dfbc44b4-5ea6-4781-9533-306bbfbf9a7e', 'kulturradet-litteraturstod', 'Kulturrådet — Litteraturstöd (efterhandsstöd till utgivning)', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Litteraturstödet är ett efterhandsstöd som förlag söker för utgiven kvalitetslitteratur inom olika kategorier. Beslut fattas av arbetsgrupper med litterär expertis.', 'Bredd och kvalitet i svensk bokutgivning.', 'public_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', '4f3f36ca-bf03-4200-a28e-1dbeebdcaeb5', 'be4aa506-118b-4c76-9be2-e99b1484b03d', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.457474+00', '2026-08-28 19:05:47.457474+00'),
	('a0ff68b8-ffae-4bc7-8609-b47c16d79a8a', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'ad8fbcbc-6c92-4459-ba75-fa5b1653a266', 'kommun-elevresor-gymnasiet', 'Din kommun — Stöd för elevresor på gymnasiet', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Enligt lag (1991:1110) ska hemkommunen ansvara för kostnader för dagliga resor mellan bostaden och gymnasieskolan för elever med studiehjälp, om färdvägen är minst sex kilometer. Stödet ges oftast som busskort/resekort och söks hos hemkommunen.', 'Gymnasieelever ska kunna ta sig till skolan oavsett var de bor.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos elevens hemkommun, vanligen inför varje läsår.', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'none', 'assisted', 1, '', 'published', '347c1c46-7309-4541-b620-740a12a0ff41', '0e980ead-f1ac-4bc9-a5ac-1dc83ac6c78e', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.355298+00', '2026-08-28 19:05:47.355298+00'),
	('772fc254-a2b1-43fd-bec2-ace7ae231536', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'e8208264-134a-4aa1-b7bb-00bd1d562c6b', 'fk-bostadsbidrag-unga', 'Försäkringskassan — Bostadsbidrag för unga (18–28 år)', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Unga mellan 18 och 28 år utan barn kan få bostadsbidrag om inkomsten är låg och boendekostnaden tillräckligt hög. Ansökan görs hos Försäkringskassan.', 'Ekonomisk trygghet i boendet för unga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '6904e44a-45ae-48e0-8c9c-ae7e96c131fa', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.359553+00', '2026-08-28 19:05:47.359553+00'),
	('297dd869-5f82-44dc-b2e5-2a5cb22620cf', '96346af8-c105-4f07-a823-ab8648762e19', '6887f2b7-02e1-4ab4-9764-77ddde220a59', 'kommun-forsorjningsstod', 'Socialtjänsten — Försörjningsstöd (ekonomiskt bistånd)', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Försörjningsstöd kan beviljas av socialtjänsten i din kommun när du inte kan försörja dig själv och saknar tillgångar som kan täcka behoven. Stödet prövas individuellt utifrån hela hushållets ekonomi, och du förväntas först ha sökt andra ersättningar du kan ha rätt till. Ansökan görs hos din kommun.', 'Skälig levnadsnivå enligt socialtjänstlagen.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos socialtjänsten i din kommun — ofta via kommunens e-tjänst eller ett bokat besök.', 'https://www.socialstyrelsen.se/', 'none', 'assisted', 2, '', 'published', 'c90f2ab4-fac7-4d7b-af9a-0a690249b366', '8781626c-d968-474c-9055-4e45a6e68156', 'https://www.socialstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.364541+00', '2026-08-28 19:05:47.364541+00'),
	('22685532-2f89-4f86-bb85-10eadedd5ffa', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', '9e6222e2-06cb-42af-b4b3-5cfe6ae5d3fe', 'csn-studiemedel', 'CSN — Studiemedel (bidrag och studielån)', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Studiemedel består av en bidragsdel och en frivillig lånedel för studier i Sverige eller utomlands. Kraven gäller bl.a. studiernas omfattning, tidigare studieresultat och ålder. Ansökan görs hos CSN.', 'Ekonomiska möjligheter att studera.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Mina sidor hos CSN (kräver e-legitimation).', 'https://www.csn.se/', 'eid', 'assisted', 1, '', 'published', '86b55dd3-e3f4-4e18-94bd-95fd96a6d9c0', '6db4f68f-bce5-408a-877a-1fe62bf13efb', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.369764+00', '2026-08-28 19:05:47.369764+00'),
	('05e2a219-0224-4e9a-a4fc-a490e50c2362', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'a48981c3-4fe4-486a-aacd-97c46ba2fb36', 'fk-aktivitetsersattning', 'Försäkringskassan — Aktivitetsersättning vid nedsatt arbetsförmåga', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Aktivitetsersättning kan lämnas till den som är 19–29 år och har arbetsförmågan nedsatt med minst en fjärdedel under minst ett år. Läkarutlåtande krävs. Ansökan görs hos Försäkringskassan; beslutet fattas efter medicinsk utredning.', 'Ekonomisk trygghet vid långvarigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan tillsammans med läkarutlåtande.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', 'f99f99be-fed9-4662-9414-6e75c499e9c3', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.37471+00', '2026-08-28 19:05:47.37471+00'),
	('b229c4b1-da17-4783-ad8c-527c6c2db2b4', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'c2c60f6f-edbd-45fd-aa00-b9523eb594f0', 'csn-omstallningsstudiestod', 'CSN — Omställningsstudiestöd', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Omställningsstudiestödet riktar sig till dig som arbetat länge och vill studera för att bli mer attraktiv på arbetsmarknaden. Kräver bl.a. etablering på arbetsmarknaden (arbetade år) och att utbildningen stärker din framtida ställning. Söktrycket är högt och handläggningstiderna kan vara långa.', 'Omställning och kompetensutveckling mitt i arbetslivet.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN; omställningsorganisationen kan komplettera med kollektivavtalat stöd.', 'https://www.csn.se/', 'eid', 'assisted', 3, '', 'published', 'a40526df-622c-41f8-8d1e-1afdcc3803d2', '6db4f68f-bce5-408a-877a-1fe62bf13efb', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.399134+00', '2026-08-28 19:05:47.399134+00'),
	('ba6fcb93-6a60-4adf-a37d-d53718fa3afd', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'cfce66c9-513b-4074-89ab-bde1422c7fa8', 'kommun-bostadsanpassningsbidrag', 'Din kommun — Bostadsanpassningsbidrag', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Bostadsanpassningsbidraget är ett kommunalt bidrag enligt lag för den som har en bestående funktionsnedsättning och behöver anpassa sin permanentbostad. Intyg från t.ex. arbetsterapeut krävs. Ansökan görs hos kommunen.', 'Självständigt liv i egen bostad.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos din kommun, ofta via e-tjänst eller blankett, med intyg.', 'https://www.boverket.se/sv/bidrag--garantier/', 'none', 'assisted', 3, '', 'published', 'fa5772ba-f4dd-49d5-94a8-123efdbf375f', NULL, 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.404153+00', '2026-08-28 19:05:47.404153+00'),
	('3be8b47f-055c-472e-901e-f52f0158f9af', '7aadc7e1-b039-4488-83bc-b5eaf129c863', 'bdf07111-602b-4280-a5e3-1231b7b1caab', 'konstnarsnamnden-kulturbryggan', 'Konstnärsnämnden — Kulturbryggan', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Kulturbryggan är Konstnärsnämndens stöd till kulturprojekt som är nyskapande i förhållande till etablerade uttryck och strukturer. Söks i utlysningsomgångar av både enskilda och organisationer.', 'Förnyelse och experiment i kulturlivet.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 8, '', 'published', '599e0cb7-da6a-4c72-9be2-dd4c608bb282', '1b168247-5d70-4cd4-89ac-e8904fb05df8', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.409041+00', '2026-08-28 19:05:47.409041+00'),
	('e1feccd1-97a2-4cb1-948a-19fadfd3a7f0', '289fbe84-3d6a-4d62-ae45-9e2f284a0761', '9a6556a6-33bd-4f8f-85dc-052f0d8071b3', 'raa-kulturarvsbidrag', 'Riksantikvarieämbetet — Bidrag till kulturarvsarbete', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Riksantikvarieämbetet fördelar årligen bidrag till ideellt kulturarvsarbete — t.ex. hembygdsrörelsen och arbetslivsmuseer. Årlig ansökningsomgång.', 'Ett levande och tillgängligt kulturarv.', 'public_grant', '["association", "foundation"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.raa.se/', 'none', 'assisted', 6, '', 'published', 'df85b44d-a82d-4ca5-ade8-1ae091c5f757', 'dcdc5241-7ff0-421a-915f-c91df09b61b5', 'https://www.raa.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.414465+00', '2026-08-28 19:05:47.414465+00');
INSERT INTO public.funding_opportunities VALUES
	('7232f6a3-7855-4491-8882-b561314bf0ff', '471d5586-a07e-4256-8a02-4923cc1b9b19', '4bcbc97c-2e45-4490-8c3d-22a649a25b73', 'si-creative-force', 'Svenska institutet — Creative Force', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Creative Force ger stöd till svenska organisationers samarbetsprojekt med partner i vissa länder, där kultur eller media används som verktyg för demokrati, jämlikhet och yttrandefrihet. Länderlista och villkor per utlysning.', 'Demokrati och yttrandefrihet genom kultur och media.', 'project_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://si.se/', 'none', 'assisted', 10, '', 'published', '32ab05cc-1e8c-4cc7-bedb-264a830f279a', 'f23f1ea2-8b7a-4142-95a2-350bcace4981', 'https://si.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.419651+00', '2026-08-28 19:05:47.419651+00'),
	('527c67ea-1c17-4a82-a849-d7873ad60d80', 'd8174b27-1934-450d-909e-74445d1cdf5d', 'a1c482e2-0f89-46af-bbba-cb52bd53ba5c', 'nordisk-kulturfond-projektstod', 'Nordisk kulturfond — Projektstöd', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Nordisk kulturfond stödjer projekt som utvecklar konst- och kulturlivet i Norden och involverar flera nordiska länder. Flera ansökningsfrister per år.', 'Ett dynamiskt nordiskt konst- och kulturliv.', 'project_grant', '["individual", "association", "company", "public_body"]', '["SE", "DK", "NO", "FI", "IS"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.nordiskkulturfond.org/', 'none', 'assisted', 8, '', 'published', 'f8c329e2-7bd3-42d4-843e-d08130e8627b', 'bc0277a9-8ee7-4cb0-8e6b-b7d17ee04bbb', 'https://www.nordiskkulturfond.org/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.425366+00', '2026-08-28 19:05:47.425366+00'),
	('7df24286-ffcc-47d3-8736-331afe557653', 'e4ccb9a5-dc99-4045-8368-14f3110e7ee0', '55b6f048-f331-4c6e-8b6a-afe665549083', 'vr-projektbidrag', 'Vetenskapsrådet — Projektbidrag (fri forskning)', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Vetenskapsrådets projektbidrag söks av disputerade forskare via svenska lärosäten i årliga utlysningar per ämnesområde.', 'Forskning av högsta vetenskapliga kvalitet.', 'public_grant', '["university"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.vr.se/', 'none', 'assisted', 20, '', 'published', '153e4e51-91d9-4d6c-bd7a-6b97a640653c', 'cac5da47-63af-4655-a176-dbb79f13859e', 'https://www.vr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.430033+00', '2026-08-28 19:05:47.430033+00'),
	('a2a2b258-0466-4347-a8c0-429a5f25878f', '1180e0a9-e60d-40d5-a4bb-8c0658834f19', '81ca3b88-e99a-4a39-9da9-516ab18c23a7', 'postkodstiftelsen-projektstod', 'Svenska Postkodstiftelsen — Projektstöd', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Postkodstiftelsen stödjer ideella organisationer med projekt inom bl.a. mänskliga rättigheter, miljö och kultur. Ansökan kan lämnas löpande via stiftelsens webbplats.', 'Positiv förändring för människor och miljö.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "environment", "culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://postkodstiftelsen.se/', 'none', 'assisted', 8, '', 'published', '0a8ec684-0b20-48d0-b7e9-1e1738233aef', '783d53df-b2fd-463c-b02f-16022a80b1f9', 'https://postkodstiftelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.434248+00', '2026-08-28 19:05:47.434248+00'),
	('a02f598a-09c8-4129-8315-6d1ebd533849', 'cb2c2570-e8f4-4bc3-86fb-c1985027fdb6', '3f5b96cd-6ad2-4a95-a4b1-fa0e59c88d73', 'lansstyrelsen-bygdemedel', 'Länsstyrelsen — Bygdemedel', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Bygdemedel är ersättningar från vattenkraft (och i vissa län vindkraft) som återförs till berörda bygder. Föreningar och kommuner kan söka för t.ex. samlingslokaler, leder och bygdeutveckling. Villkor varierar per län.', 'Lokal utveckling i berörda bygder.', 'public_grant', '["association", "municipality"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos länsstyrelsen i ditt län, ofta via e-tjänst.', 'https://www.lansstyrelsen.se/', 'eid', 'assisted', 6, '', 'published', '3b810cca-f5c6-4892-8b89-851b603b2462', '1cd93aab-8ba0-4a9c-afcd-b11ae1ffcad2', 'https://www.lansstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.461888+00', '2026-08-28 19:05:47.461888+00'),
	('48f5a3c2-7682-456d-aac6-90f3c3b2b7c0', '7cd7f6c5-33de-49cf-9959-ecfdf7406b3d', 'becf17d8-91bb-4d4c-8114-28342b6280fe', 'migrationsverket-atervandringsbidrag', 'Migrationsverket — Stöd vid frivillig återvandring', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Den som har uppehållstillstånd som flykting eller skyddsbehövande (samt vissa anhöriga) och frivilligt vill återvandra permanent kan ansöka om bidrag till resa och återetablering. Schablonbeloppen är beslutade att höjas väsentligt från 2026 — kontrollera aktuella belopp och villkor hos Migrationsverket innan beslut. Beslutet att återvandra är oåterkalleligt i bidragshänseende: uppehållstillståndet återkallas normalt.', 'Möjliggöra frivillig, värdig återvandring för den som själv vill.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Migrationsverket före utresan.', 'https://www.migrationsverket.se/', 'none', 'assisted', 3, '', 'published', '53ecd377-e3ce-4ff4-ae9b-8f75766eba60', 'a0dab6ca-6ef7-4f88-a1ea-c8e6bf7856c2', 'https://www.migrationsverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.466693+00', '2026-08-28 19:05:47.466693+00'),
	('6420b212-cc32-4590-ba27-a768d9824dae', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', '9b3b26e5-626c-4400-a722-f610c1f38614', 'af-eures-targeted-mobility', 'EURES — Targeted Mobility Scheme (jobb i annat EU-land)', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU:s riktade rörlighetsprogram hjälper arbetssökande från 18 år att ta anställning i ett annat EU-/EES-land. Stödet kan omfatta bidrag till intervjuresa, flytt, språkkurs och erkännande av kvalifikationer — beloppen är schabloner per insats och land och varierar per programperiod. Vägen in är EURES-rådgivarna hos Arbetsförmedlingen.', 'Rörlighet på den europeiska arbetsmarknaden.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta en EURES-rådgivare via Arbetsförmedlingen — ansökan görs innan flytten/resan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '9bfd4984-0a5f-4d60-a9d2-83fb0df92047', '068d3eb2-4c99-4221-818a-332737f04718', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.471471+00', '2026-08-28 19:05:47.471471+00'),
	('e9b3b976-f814-4785-8c7f-efccf761b102', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', '9e6222e2-06cb-42af-b4b3-5cfe6ae5d3fe', 'csn-utlandsstudier', 'CSN — Studiemedel för utlandsstudier', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Studiemedel kan tas med till studier utomlands på utbildningar som uppfyller CSN:s krav. Utöver ordinarie bidrag och lån finns merkostnadslån för undervisningsavgifter, resor och försäkring. Utbildningen och skolan ska vara godkänd — kontrollera i CSN:s tjänst innan du tackar ja till en plats.', 'Göra utlandsstudier möjliga oavsett privatekonomi.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN med e-legitimation.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '446e4fe2-d3eb-4372-83c5-4781037ddde6', '6db4f68f-bce5-408a-877a-1fe62bf13efb', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.475343+00', '2026-08-28 19:05:47.475343+00'),
	('4e5edd9a-5515-4838-8bd6-bddb852f6b48', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'e5cbced7-eb49-469f-b81c-b30451f3bca6', 'fk-omvardnadsbidrag', 'Försäkringskassan — Omvårdnadsbidrag för barn med funktionsnedsättning', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Omvårdnadsbidrag kan lämnas till vårdnadshavare för barn med funktionsnedsättning som behöver mer omvårdnad och tillsyn än jämnåriga. Bidraget finns i fyra nivåer utifrån barnets sammanlagda behov och kan lämnas till och med juni det år barnet fyller 19. Ansökan görs hos Försäkringskassan; ett läkarutlåtande om barnets funktionsnedsättning behövs.', 'Ge föräldrar ekonomiskt utrymme för den extra omvårdnad barnet behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); läkarutlåtande bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', '63a04bbb-f0ba-4b9d-9690-77f736db2864', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.482377+00', '2026-08-28 19:05:47.482377+00'),
	('8377bf76-b7f9-4bed-a818-32689e0d11fd', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', '260700a8-b5cb-44db-9c5b-5ebbc6bf62c6', 'fk-merkostnadsersattning', 'Försäkringskassan — Merkostnadsersättning vid funktionsnedsättning', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Merkostnadsersättning kan lämnas när en varaktig funktionsnedsättning medför merkostnader — t.ex. slitage, hjälpmedel, resor eller särskild kost. Ersättningen finns i fem nivåer och kräver att merkostnaderna når upp till en lägsta nivå per år (knuten till prisbasbeloppet). Både vuxna med funktionsnedsättning och vårdnadshavare för barn kan ansöka hos Försäkringskassan.', 'Utjämna de extra kostnader en funktionsnedsättning medför.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); merkostnaderna specificeras.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', '47b42e2e-8674-435d-9879-e1a47b130da1', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.487424+00', '2026-08-28 19:05:47.487424+00'),
	('a19bf016-211f-4861-8b46-b2da65c57d7c', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', '6d5dc1f1-263a-4a60-ae13-94c9359e09f4', 'fk-bilstod', 'Försäkringskassan — Bilstöd vid funktionsnedsättning', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Bilstöd kan lämnas till den som har en varaktig funktionsnedsättning med stora svårigheter att förflytta sig på egen hand eller att använda allmänna kommunikationer — och till föräldrar till barn med sådan funktionsnedsättning. Stödet består av flera delar: grundbidrag, inkomstprövat anskaffningsbidrag och anpassningsbidrag för särskild utrustning. Nytt bilstöd kan normalt beviljas först efter nio år.', 'Göra det möjligt att förflytta sig självständigt när kollektivtrafik inte fungerar.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande om funktionsnedsättningen och körkortsuppgifter behövs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', 'd7871927-9355-4d5a-a958-5eb0d5bcdc50', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.492153+00', '2026-08-28 19:05:47.492153+00'),
	('d8df3387-7585-4e66-a5b4-6a9e88af9204', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'a2a15cf5-7ee4-4299-927e-cd9d9f8fa074', 'fk-foraldrapenning', 'Försäkringskassan — Föräldrapenning', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Föräldrapenning kan tas ut av föräldrar (och i vissa fall andra vårdnadshavare) för tid med barnet, från graviditet tills barnet fyllt tolv år, med flest dagar under de första åren. Ersättningens nivå beror på din inkomst och vilken typ av dagar du tar ut; nivåer och regler framgår hos Försäkringskassan. Ansökan görs i efterhand för de dagar du varit ledig.', 'Möjliggöra föräldraledighet med ersättning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '161a5cbe-1fa3-4937-8aca-168e41aa0854', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.557817+00', '2026-08-28 19:05:47.557817+00'),
	('f4c46b41-fd43-494e-9d7d-21d576bc30de', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'd44d6c1e-83fa-46ee-8bea-70c8eb847043', 'fk-narstaendepenning', 'Försäkringskassan — Närståendepenning', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Närståendepenning kan lämnas när du avstår från förvärvsarbete för att vårda eller vara nära en närstående med en sjukdom som innebär ett påtagligt hot mot livet. Ersättningen kan betalas i upp till 100 dagar per person som vårdas (dagarna kan delas mellan flera närstående). Läkarutlåtande om den sjukes tillstånd och den sjukes samtycke krävs.', 'Ingen ska behöva välja mellan sin försörjning och att finnas hos en svårt sjuk anhörig.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarutlåtande och den sjukes samtycke bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'c0433c20-bf31-488e-851c-338eb504055d', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.496779+00', '2026-08-28 19:05:47.496779+00'),
	('02d3c6b1-ba09-49bc-9c92-913e9c8eca86', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'b0a1dbe4-7b95-4642-a7ba-6ca5aa003956', 'af-etableringsersattning', 'Arbetsförmedlingen — Etableringsersättning för nyanlända', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Den som nyligen fått uppehållstillstånd (som skyddsbehövande eller vissa anhöriga) och är 20–66 år kan delta i Arbetsförmedlingens etableringsprogram och få etableringsersättning under tiden. Den som har barn eller bor ensam i egen bostad kan även få etableringstillägg respektive bostadsersättning. Arbetsförmedlingen beslutar om programmet; Försäkringskassan beslutar om och betalar ut ersättningen.', 'Försörjning under de första årens etablering i arbets- och samhällslivet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen; ersättningen ansöks sedan hos Försäkringskassan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '66498a87-608c-4384-a11a-67c5411d4e1e', '068d3eb2-4c99-4221-818a-332737f04718', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.50147+00', '2026-08-28 19:05:47.50147+00'),
	('7d56e2e5-be39-4a81-a96e-48fa4f599d8a', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', '033a0ffa-a964-4f6b-8624-b2e787b414ca', 'csn-hemutrustningslan', 'CSN — Hemutrustningslån för nyanlända', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Hemutrustningslån kan lämnas till flyktingar och vissa anhöriga som tagits emot i en kommun och behöver utrusta ett första hem i Sverige. Lånet söks hos CSN inom två år från det första kommunmottagandet, har låg ränta och betalas tillbaka enligt en plan som tar hänsyn till inkomst. Det är ett lån — inte ett bidrag — och ska betalas tillbaka.', 'Ett fungerande hem från start, utan att behöva vända sig till dyra krediter.', 'loan', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos CSN; kommunmottagandet styr vilka som kan söka.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', 'ef8cf74e-e184-4e44-aacf-25ea60ba108b', '6db4f68f-bce5-408a-877a-1fe62bf13efb', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.506339+00', '2026-08-28 19:05:47.506339+00'),
	('7cdbb754-c472-4d4a-8377-ef5bbbb6d62f', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'bfa3dc10-8e42-4480-840d-cde746875590', 'csn-studiestartsstod', 'CSN — Studiestartsstöd för arbetslösa med kort utbildning', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Studiestartsstöd är ett rent bidrag (ingen lånedel) för den som är 25–60 år, har varit arbetslös, har kort tidigare utbildning och behöver studera på grundskole- eller gymnasienivå för att stärka sina chanser till jobb. Stödet kan lämnas i upp till 50 veckor. Hemkommunen bedömer om du tillhör målgruppen; ansökan görs sedan hos CSN.', 'Sänka tröskeln till studier för den som behöver dem mest.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta hemkommunen (målgruppsbedömning) och ansök därefter hos CSN.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '5c36b35d-7e95-45a6-95e5-da5ecf53737f', '6db4f68f-bce5-408a-877a-1fe62bf13efb', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.511796+00', '2026-08-28 19:05:47.511796+00'),
	('d424bb27-1491-44a6-8fa7-c99108c6f89e', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'd9208846-350a-4a86-bfd3-6dfb228542b5', 'csn-inackorderingstillagg', 'CSN — Inackorderingstillägg för gymnasieelever som bor på studieorten', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Elever på fristående gymnasieskolor och folkhögskolor som måste inackordera sig på studieorten på grund av lång eller besvärlig resväg kan få inackorderingstillägg från CSN. Går eleven på en kommunal gymnasieskola är det i stället hemkommunen som ger stöd till inackordering — kontrollera med kommunen. Tillägget söks för varje läsår.', 'Gymnasievalet ska inte begränsas av var i landet utbildningen finns.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos CSN (fristående skola/folkhögskola) eller hos hemkommunen (kommunal skola), inför varje läsår.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', '0c4b6ff4-f018-4807-9de6-bdc457fd56d4', '6db4f68f-bce5-408a-877a-1fe62bf13efb', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.516514+00', '2026-08-28 19:05:47.516514+00'),
	('146e1dad-6a01-4db9-8a1c-a255842d6cd6', '114e913f-a8a0-48a0-97df-33ebfee16ea8', '949dd6d5-dc8a-47af-a78e-7e09e637dbcb', 'kommun-foreningsbidrag', 'Din kommun — Föreningsbidrag (aktivitets-, lokal- och startbidrag)', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'I stort sett alla kommuner ger bidrag till lokala föreningar — vanligast är aktivitetsstöd per deltagartillfälle för barn- och ungdomsverksamhet, bidrag till lokalhyra och startbidrag för nya föreningar. Regler, belopp och ansökningstider skiljer sig åt mellan kommuner; ansökan görs hos kultur- och fritidsförvaltningen i den kommun där föreningen är verksam.', 'Ett levande lokalt föreningsliv med låga trösklar för deltagande.', 'public_grant', '["association"]', '["SE"]', '["civil_society", "sports", "culture", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos kommunens kultur- och fritidsförvaltning — rutiner och tider varierar per kommun.', 'https://www.skr.se/', 'none', 'assisted', 2, '', 'published', '47abc58f-b930-4d69-bca7-d1a460bd763f', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.523422+00', '2026-08-28 19:05:47.523422+00'),
	('ef5d306b-f30d-48dd-908d-6a43e751ed94', '4a35ddab-675d-42d2-9775-a483285ec84e', '5b322d11-259b-43fb-a29a-768b3b0b1561', 'region-kulturstod', 'Din region — Regionala kulturstöd och projektbidrag', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Alla regioner fördelar egna kulturstöd — projektbidrag, arrangörsstöd och stipendier — inom kultursamverkansmodellen. Stöden riktar sig till kulturaktörer med förankring i regionen och söks direkt hos regionens kulturförvaltning. Utlysningar, belopp och tider varierar per region; kontrollera din regions kultursidor.', 'Ett professionellt och tillgängligt kulturliv i hela regionen.', 'public_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos regionens kulturförvaltning — utlysningar publiceras på regionens webbplats.', 'https://www.skr.se/', 'none', 'assisted', 4, '', 'published', 'f6633cdf-0cc9-498f-8706-21f77eaa18d8', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.528579+00', '2026-08-28 19:05:47.528579+00'),
	('63cecab0-051b-4fa9-b4f3-e6213bc29ae6', 'f8ad8f1e-4686-4fa9-bd93-8104df989a2d', '40f700cc-0aee-44bd-b41e-30f1a9eb86c3', 'sparbanksstiftelsen-projektstod', 'Sparbanksstiftelsen i ditt område — Bidrag till lokala projekt', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Sparbanksstiftelserna förvaltar sparbanksrörelsens överskott och delar ut bidrag till projekt som utvecklar det lokala samhället — ofta inom idrott, kultur, utbildning, forskning och näringslivsutveckling. Varje stiftelse beslutar självständigt och stödjer bara projekt i den egna sparbankens verksamhetsområde. Hitta stiftelsen där ni verkar och sök enligt dess rutiner.', 'Lokal utveckling där sparbanken verkar.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "sports", "culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos den sparbanksstiftelse vars område ni verkar i — rutiner varierar per stiftelse.', 'https://www.sparbankerna.se/', 'none', 'assisted', 3, '', 'published', 'f0c377b3-2e85-43e9-b2ee-63cf43deb523', '6c16471e-5766-42a9-af6f-73332ef21709', 'https://www.sparbankerna.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.532879+00', '2026-08-28 19:05:47.532879+00'),
	('b2dc12b1-327d-4fae-b797-695f6914b21b', 'b2e0436a-46a5-4353-840c-daecf935e86a', '862527a8-e069-4308-a580-886e60422366', 'leader-lokalt-ledd-utveckling', 'Leader — Projektstöd för lokalt ledd utveckling på landsbygden', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Genom Leader finansieras lokala utvecklingsprojekt på landsbygden med medel från EU och svenska staten. Sverige är indelat i ett fyrtiotal leaderområden med egna utvecklingsstrategier; projektidén söks hos leaderområdets kansli, prioriteras av den lokala LAG-styrelsen och beslutas formellt av Jordbruksverket. Föreningar, företag, kommuner och andra lokala aktörer kan söka.', 'Utveckling av landsbygden utifrån lokala behov och idéer.', 'eu_grant', '["association", "company", "municipality"]', '["SE"]', '["rural", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta ditt leaderområdes kansli; ansökan lämnas i Jordbruksverkets e-tjänst.', 'https://jordbruksverket.se/', 'none', 'assisted', 8, '', 'published', '8da6016a-7e3b-4e1c-8479-bb7c47618ca8', '47bec89a-463d-4940-9157-5943f5b129a5', 'https://jordbruksverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.538235+00', '2026-08-28 19:05:47.538235+00'),
	('f881cabb-599c-4f1d-ae72-a82823c5c7ed', '0b29c47b-a9ee-422e-b3cf-70cc3d40d453', '437138bd-bdc2-4874-ad5e-6c6b7ec9aa3c', 'forte-projektbidrag', 'Forte — Projektbidrag för forskning om hälsa, arbetsliv och välfärd', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Forte är det statliga forskningsrådet för hälsa, arbetsliv och välfärd och utlyser projektbidrag, postdokbidrag och programstöd inom sina områden. Bidragen söks av disputerade forskare och förvaltas av ett svenskt lärosäte eller annan godkänd medelsförvaltare. Årliga öppna utlysningar publiceras på forte.se.', 'Kunskap som förbättrar människors hälsa, arbetsliv och välfärd.', 'public_grant', '["university"]', '["SE"]', '["research"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan i Fortes ansökningssystem Prisma, via medelsförvaltaren.', 'https://forte.se/', 'none', 'assisted', 15, '', 'published', '056c4841-dad6-439e-9522-c9ef2d934682', 'd35472d5-d164-40f8-97ed-3b1c2dd79420', 'https://forte.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.542579+00', '2026-08-28 19:05:47.542579+00'),
	('ce5b2ae0-9e39-408a-84d8-9de9317c749e', '5bb1059c-7173-484a-a36c-9d907d2b60ac', 'c635cb10-fb9b-416d-9249-17391e6a44cc', 'radiohjalpen-projektbidrag', 'Radiohjälpen — Projektbidrag ur insamlingskampanjerna', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Radiohjälpen fördelar insamlade medel till projekt som drivs av svenska ideella organisationer med 90-konto: internationella humanitära insatser och utvecklingsprojekt (t.ex. Världens Barn, Musikhjälpen) samt nationella insatser för barn och unga med funktionsnedsättning eller kronisk sjukdom (Victoriafonden — där kan även t.ex. kuratorer söka aktivitets- och lägerbidrag för enskilda barn). Utlysningar och villkor finns på radiohjalpen.se.', 'Insamlade medel ska nå fram genom seriösa organisationer.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan enligt respektive utlysning på radiohjalpen.se.', 'https://www.radiohjalpen.se/', 'none', 'assisted', 6, '', 'published', 'f61f4264-cc09-4859-b7a8-3b180fbd8504', 'ce053fcd-125a-4314-acaf-967c4cbe6724', 'https://www.radiohjalpen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.546889+00', '2026-08-28 19:05:47.546889+00'),
	('b5aec0b5-f575-4334-bc05-9c5704b775a0', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'a2a15cf5-7ee4-4299-927e-cd9d9f8fa074', 'fk-barnbidrag', 'Försäkringskassan — Barnbidrag', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Barnbidrag lämnas för barn som bor i Sverige, normalt utan ansökan — det betalas ut automatiskt från månaden efter födseln eller flytten till Sverige. Ansökan behövs i vissa fall, till exempel när barnet flyttar hit eller vid ändrad utbetalningsmottagare. Beloppet per barn och månad framgår hos Försäkringskassan. Från och med det andra barnet lämnas även flerbarnstillägg (egen post).', 'Ekonomisk grundtrygghet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt; ansökan i särskilda fall på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'be984a30-4573-4e6b-8d25-b0fb1b01e81b', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.550591+00', '2026-08-28 19:05:47.550591+00'),
	('34ea1fd5-5df2-46cc-8c7d-3435f8cc4956', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'a2a15cf5-7ee4-4299-927e-cd9d9f8fa074', 'fk-flerbarnstillagg', 'Försäkringskassan — Flerbarnstillägg', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Flerbarnstillägg lämnas automatiskt till den som får barnbidrag för två eller fler barn — ingen separat ansökan behövs i normalfallet. Tillägget ökar med antalet barn; nivåerna framgår hos Försäkringskassan. Den som har barn över 16 år som studerar kan i vissa fall behöva anmäla för fortsatt flerbarnstillägg.', 'Förstärkt stöd till familjer med flera barn.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt tillsammans med barnbidraget.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '17ce5d33-dd63-4e70-903b-a4ff4c033226', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.554343+00', '2026-08-28 19:05:47.554343+00'),
	('25486d77-0a0c-49fa-b6a4-a61c70878cba', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'a2a15cf5-7ee4-4299-927e-cd9d9f8fa074', 'fk-tillfallig-foraldrapenning', 'Försäkringskassan — Tillfällig föräldrapenning (vab)', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Tillfällig föräldrapenning — i dagligt tal vab — kan lämnas när du avstår från arbete för att vårda ett sjukt barn som är under 12 år (i vissa fall äldre). Ersättningen baseras på din inkomst; nivå och antal dagar framgår hos Försäkringskassan. Anmäl första dagen och ansök i efterhand; läkarintyg krävs från åttonde dagen.', 'Göra det möjligt att vårda sjukt barn utan att förlora hela inkomsten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Anmäl och ansök på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '03e26c1d-bf64-48b3-b6e6-451520cc3980', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.56185+00', '2026-08-28 19:05:47.56185+00'),
	('66bc3ff8-31bc-4582-a1b4-4a6d2ba38fb6', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'e8ae15eb-8330-445b-a5b2-0afb19f799eb', 'fk-sjukpenning', 'Försäkringskassan — Sjukpenning', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Sjukpenning kan lämnas när sjukdom sätter ned din arbetsförmåga med minst en fjärdedel. Anställda får normalt sjuklön från arbetsgivaren de första två veckorna; därefter kan sjukpenning från Försäkringskassan ta vid. Egenföretagare och arbetslösa ansöker direkt. Läkarintyg krävs efter en tid; nivåer och regler framgår hos Försäkringskassan.', 'Försörjning när arbetsförmågan är nedsatt av sjukdom.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarintyg bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '71b0de7f-8a3c-4476-bb74-c2e8627e4f65', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.566478+00', '2026-08-28 19:05:47.566478+00'),
	('0d351ab4-1e5b-4ad9-bc7e-30f8c3fc65fb', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'e8ae15eb-8330-445b-a5b2-0afb19f799eb', 'fk-sjukersattning', 'Försäkringskassan — Sjukersättning', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Sjukersättning kan lämnas till den som troligen aldrig kommer att kunna arbeta heltid på grund av sjukdom, skada eller funktionsnedsättning. Arbetsförmågan ska vara stadigvarande nedsatt med minst en fjärdedel i förhållande till hela arbetsmarknaden. Ersättningen kan vara inkomstrelaterad eller på garantinivå; regler och nivåer framgår hos Försäkringskassan.', 'Långsiktig försörjning vid varaktigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande krävs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '4a803baa-a9bb-4c5c-9804-9acf7c17c397', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.570038+00', '2026-08-28 19:05:47.570038+00'),
	('3dd9afb6-fa2a-4b2f-812f-53324f1ae5e8', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', '7895bc53-f9b1-4888-8ab3-d7e5d6b1790f', 'fk-aktivitetsstod', 'Försäkringskassan — Aktivitetsstöd', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Aktivitetsstöd lämnas till den som deltar i ett program hos Arbetsförmedlingen, till exempel jobb- och utvecklingsgarantin eller arbetsmarknadsutbildning. Arbetsförmedlingen anvisar programmet; Försäkringskassan beslutar om och betalar ut ersättningen, som bland annat beror på om du uppfyller villkoren för a-kassa. Yngre deltagare kan i stället få utvecklingsersättning.', 'Försörjning under program som stärker vägen till arbete.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Programmet anvisas av Arbetsförmedlingen; ersättningen ansöks månadsvis hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '08586b52-ea04-4394-a169-de1c94637961', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.575542+00', '2026-08-28 19:05:47.575542+00'),
	('35cc84cc-06bc-45a0-8fb5-e7cf6339ec18', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'bf947079-c93c-4fee-b9a7-58bf9fd8b703', 'fk-tandvardsbidrag', 'Försäkringskassan — Allmänt tandvårdsbidrag (ATB)', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Det allmänna tandvårdsbidraget gäller alla från det år de fyller 24 och används automatiskt som avdrag när du besöker en ansluten tandläkare eller tandhygienist — ingen ansökan behövs. Beloppet beror på ålder och kan sparas ett år; nivåerna framgår hos Försäkringskassan. Den med särskilda behov kan därutöver ha rätt till särskilt tandvårdsbidrag.', 'Sänka tröskeln till regelbunden tandvård.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — säg till hos tandvården att du vill använda bidraget.', 'https://www.forsakringskassan.se/privatperson', 'none', 'assisted', 1, '', 'published', '86bb7fc4-0814-43ee-ba69-d1a847d14a73', '8609bbf3-3599-45f8-8910-763c6c6676c6', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.580567+00', '2026-08-28 19:05:47.580567+00'),
	('7d9b99ba-2513-4c32-934d-360cd9764d94', '6b993806-e6f5-43e3-b37e-542c6b2952bc', 'b3595c40-5242-4cf8-9adf-f091e37e286f', 'pm-garantipension', 'Pensionsmyndigheten — Garantipension', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Garantipension är ett grundskydd i den allmänna pensionen för den som haft låg eller ingen inkomstgrundad pension. Den betalas normalt ut automatiskt när du ansöker om allmän pension från riktåldern — ingen separat ansökan behövs om du bor i Sverige. Nivån beror på inkomstpensionens storlek, civilstånd och försäkringstid; detaljerna framgår hos Pensionsmyndigheten.', 'Lägsta rimliga pensionsnivå oavsett tidigare inkomster.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingår i ansökan om allmän pension hos Pensionsmyndigheten; prövas automatiskt.', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '147d9193-f593-4849-aee8-c4514f95f9af', 'e3e530ee-2207-485f-9ce7-a2c703e61d8c', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.585467+00', '2026-08-28 19:05:47.585467+00'),
	('1b659cdd-5078-4c5f-b2ff-d94de9db5cc4', '4a35ddab-675d-42d2-9775-a483285ec84e', 'fbfa5d26-a30d-4b25-8531-813a9a5f1d59', 'region-hogkostnadsskydd-vard', 'Din region — Högkostnadsskydd för sjukvård', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Högkostnadsskyddet innebär att du under en period på tolv månader aldrig betalar mer än ett takbelopp i patientavgifter för öppen sjukvård; därefter får du frikort för resten av perioden. Registreringen sker normalt automatiskt i regionens system när du betalar. Takbeloppet fastställs årligen — se 1177 för aktuell nivå. Motsvarande skydd finns för läkemedel och sjukresor.', 'Skydda mot höga sammanlagda vårdkostnader.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — registreras normalt automatiskt i regionens system; spara kvitton vid besök i annan region.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', 'fd4bd609-5220-457c-a2bf-db2b215d1845', '57d7ab75-fce9-45b6-b3d4-eea6b05f948d', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.590299+00', '2026-08-28 19:05:47.590299+00'),
	('4ea32df9-b3ca-43e5-9a93-9a0fca6ef0da', '335178e6-1b98-4482-a282-2b6788dd7622', '5d1641ca-3f7c-4748-94ac-98d595d4a9ac', 'akassa-arbetsloshetsersattning', 'Din a-kassa — Arbetslöshetsersättning (a-kassa)', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Arbetslöshetsersättning lämnas av a-kassorna till den som är arbetslös, inskriven hos Arbetsförmedlingen, aktivt söker arbete och uppfyller arbetsvillkoret. Medlemmar som uppfyllt medlemsvillkoret kan få inkomstbaserad ersättning; den som inte är medlem kan ha rätt till grundbelopp via Alfa-kassan. Vilken a-kassa som passar beror på bransch; villkor och nivåer framgår hos din a-kassa och Sveriges a-kassor.', 'Inkomsttrygghet under omställning mellan arbeten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen första arbetslösa dagen; ansök sedan hos din a-kassa (Mina sidor).', 'https://www.sverigesakassor.se/', 'eid', 'assisted', 1, '', 'published', '8337d231-13c4-42e7-945a-42d8899a0fdc', '70c94c7b-0319-4c35-8ab5-b56f32ab2f6f', 'https://www.sverigesakassor.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.594589+00', '2026-08-28 19:05:47.594589+00'),
	('a46ebfdb-d00c-468f-8146-2278e08cd193', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'a8c7c837-be6a-4595-b86c-c5e81123e03c', 'af-nystartsjobb', 'Arbetsförmedlingen — Nystartsjobb', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Nystartsjobb ger arbetsgivare ett bidrag motsvarande en del av lönekostnaden vid anställning av personer som varit arbetslösa en längre tid, är nyanlända eller av andra skäl varit borta från arbetslivet. Stödets storlek och längd beror på den anställdas situation; villkoren framgår hos Arbetsförmedlingen. Anställningen ska ha marknadsmässiga villkor och beslut ska finnas innan den påbörjas.', 'Sänka tröskeln in på arbetsmarknaden för dem som stått utanför.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '3ebf9e84-44f2-4b92-9d7b-9357388f9f60', '068d3eb2-4c99-4221-818a-332737f04718', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.599028+00', '2026-08-28 19:05:47.599028+00'),
	('eb79360d-f0ac-465c-a1e6-04c65986d83e', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'a8c7c837-be6a-4595-b86c-c5e81123e03c', 'af-lonebidrag', 'Arbetsförmedlingen — Lönebidrag vid nedsatt arbetsförmåga', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Lönebidrag kan lämnas till arbetsgivare som anställer (eller behåller) en person vars arbetsförmåga är nedsatt av funktionsnedsättning eller ohälsa. Bidraget kompenserar en del av lönekostnaden och kan kombineras med anpassning av arbetet; det finns i flera former (utveckling, trygghet, anställning). Nivå och längd bedöms individuellt av Arbetsförmedlingen.', 'Göra det möjligt att anställa utifrån förmåga, inte hinder.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '934d9111-559b-4c26-b196-ae66ced51774', '068d3eb2-4c99-4221-818a-332737f04718', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 19:05:47.602609+00', '2026-08-28 19:05:47.602609+00');


--
-- Data for Name: funding_programmes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_programmes VALUES
	('22cd4506-0053-4daf-a022-a6eddccc1723', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'Internationellt kulturutbyte', '', '2026-08-28 19:05:47.165427+00'),
	('b892dd64-5aba-4ab4-8654-4ccaaedcbf97', '13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', 'Erasmus+ Ungdom', '', '2026-08-28 19:05:47.175418+00'),
	('6f404808-e918-4d50-927a-014529b3c8c3', '64a93432-3fdd-4fb4-b6b8-ec17e6f31535', 'Bidrag till civilsamhället', '', '2026-08-28 19:05:47.181613+00'),
	('038d86c9-6e42-47af-b9d2-ac87f2b3c095', '683e4116-b793-4d36-9499-703f0a8f15c3', 'Innovativa startups', '', '2026-08-28 19:05:47.187628+00'),
	('61f9d8b8-e09f-4ee2-a043-60f6f960427f', '6e4cedc0-be21-481f-b811-9b4115bec533', 'Forskning och innovation för energiomställning', '', '2026-08-28 19:05:47.193713+00'),
	('6d745e26-c06a-4b60-bff8-10e7df0f465d', '13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', 'Klimatinvesteringar', '', '2026-08-28 19:05:47.199536+00'),
	('26c86284-acd2-4ddf-9720-d962c0487aae', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'Musik', '', '2026-08-28 19:05:47.20778+00'),
	('62cfe78b-a0b7-47f9-aff5-aff9946fda44', '7aadc7e1-b039-4488-83bc-b5eaf129c863', 'Internationellt kulturutbyte', '', '2026-08-28 19:05:47.215369+00'),
	('100593e9-0455-4c99-9084-3e997ffdceb6', '7aadc7e1-b039-4488-83bc-b5eaf129c863', 'Arbetsstipendier', '', '2026-08-28 19:05:47.221035+00'),
	('f05d2785-3a7a-45d3-900b-6884464e066a', '31e8e2f5-52a5-4682-9ca6-cdb2c77ffe18', 'Projektstöd', '', '2026-08-28 19:05:47.226483+00'),
	('7f5daa4d-1faa-40df-a351-b75a0fbb7412', '54851904-35b4-4dfc-9140-1daceb1ef85f', 'Stöd till allmänna samlingslokaler', '', '2026-08-28 19:05:47.232227+00'),
	('1dcfe040-4b5e-45a4-a457-2b36bcd2b7a0', '70576e97-1033-4edc-a69c-bfa1190af574', 'LOK-stöd', '', '2026-08-28 19:05:47.237977+00'),
	('aefc254b-0026-4241-b358-5c2b9490a9ce', '1784f0ae-7080-4e92-b714-37ae106ce213', 'Produktionsstöd', '', '2026-08-28 19:05:47.243404+00'),
	('79033582-18b0-4c54-97c1-74adf0d944c7', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'Skapande skola', '', '2026-08-28 19:05:47.248983+00'),
	('3d66703c-0b74-4260-a268-5c3075333f99', 'e89c9252-43be-40a8-a1c5-8977f0997df4', 'Årliga öppna utlysningen', '', '2026-08-28 19:05:47.25413+00'),
	('59b37f6f-fbcc-433f-9b63-ad2c0fb04ee7', '08248302-d932-4084-a794-f2d8ed80e057', 'Affärsutvecklingscheckar', '', '2026-08-28 19:05:47.260139+00'),
	('40f5a0f4-6869-4cc8-84b0-21c167cb4020', 'b2e0436a-46a5-4353-840c-daecf935e86a', 'Startstöd', '', '2026-08-28 19:05:47.265819+00'),
	('69380d7b-97d5-46fe-ae2f-a642192d90ff', 'b2e0436a-46a5-4353-840c-daecf935e86a', 'Investeringsstöd', '', '2026-08-28 19:05:47.270914+00'),
	('eca45477-1041-4011-a35d-6fb1200c8595', '1eed7774-bfb5-4636-b097-a6ecbf93b734', 'ESF+', '', '2026-08-28 19:05:47.276193+00'),
	('8aace6af-ea04-4fc6-a9dc-2aceb49302a3', '6e4cedc0-be21-481f-b811-9b4115bec533', 'Industriklivet', '', '2026-08-28 19:05:47.281498+00'),
	('e365e766-f69f-4128-b7a5-9a70d26035ca', '13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', 'Klimatklivet', '', '2026-08-28 19:05:47.286726+00'),
	('ecdbaa77-c0bf-4333-8207-7b4f13ff8b66', '13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', 'LONA', '', '2026-08-28 19:05:47.292339+00'),
	('5d752450-cff3-46f8-bc2b-efe0ae7f0173', '64a93432-3fdd-4fb4-b6b8-ec17e6f31535', 'Europeiska solidaritetskåren', '', '2026-08-28 19:05:47.297354+00'),
	('4779960d-fa4c-48ed-a20b-666c13bd001f', 'afded389-82d6-46aa-9b9e-7c62d0d2afbb', 'Erasmus+ Utbildning', '', '2026-08-28 19:05:47.302744+00'),
	('e8969c74-ca1e-44fb-811f-fa467fd94993', '13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', 'Kreativa Europa', '', '2026-08-28 19:05:47.308497+00'),
	('b79a308f-f86a-4096-9584-5013750c045a', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'Scenkonst', '', '2026-08-28 19:05:47.316317+00'),
	('d8ba5ee1-9c98-41bf-9cb8-c9530282c9db', '683e4116-b793-4d36-9499-703f0a8f15c3', 'EU-relaterade stöd', '', '2026-08-28 19:05:47.322168+00'),
	('4c62c4c5-0238-4349-89a0-eb9142031465', '64a93432-3fdd-4fb4-b6b8-ec17e6f31535', 'Statsbidrag till civilsamhället', '', '2026-08-28 19:05:47.328284+00'),
	('e8208264-134a-4aa1-b7bb-00bd1d562c6b', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Bostadsbidrag', '', '2026-08-28 19:05:47.333144+00'),
	('3e1eae60-7da4-4ca8-8adc-bc54fe49bed4', '4a35ddab-675d-42d2-9775-a483285ec84e', 'Glasögonbidrag', '', '2026-08-28 19:05:47.338447+00'),
	('51d2f25a-ceb9-4f10-9d40-d04e5ba221f4', '6b8aaecc-daad-4dd2-b30e-35ac2f695e82', 'Majblommans bidrag', '', '2026-08-28 19:05:47.34366+00'),
	('459c5d00-a3eb-4db7-af72-c4ae24e7b809', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'Skolskjuts', '', '2026-08-28 19:05:47.348369+00'),
	('ad8fbcbc-6c92-4459-ba75-fa5b1653a266', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'Elevresor', '', '2026-08-28 19:05:47.353641+00'),
	('6887f2b7-02e1-4ab4-9764-77ddde220a59', '96346af8-c105-4f07-a823-ab8648762e19', 'Ekonomiskt bistånd', '', '2026-08-28 19:05:47.363026+00'),
	('9e6222e2-06cb-42af-b4b3-5cfe6ae5d3fe', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'Studiemedel', '', '2026-08-28 19:05:47.368049+00'),
	('a48981c3-4fe4-486a-aacd-97c46ba2fb36', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Sjuk- och aktivitetsersättning', '', '2026-08-28 19:05:47.373061+00'),
	('a2a15cf5-7ee4-4299-927e-cd9d9f8fa074', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Stöd till barnfamiljer', '', '2026-08-28 19:05:47.378015+00'),
	('d7f11477-3517-4776-9f9c-ecbc50b32b78', '6b993806-e6f5-43e3-b37e-542c6b2952bc', 'Bostadstillägg', '', '2026-08-28 19:05:47.382989+00'),
	('8a8f843f-8d92-4d11-80e5-b7fb668addbd', '6b993806-e6f5-43e3-b37e-542c6b2952bc', 'Äldreförsörjningsstöd', '', '2026-08-28 19:05:47.388193+00'),
	('dd514924-2371-422b-80aa-86ad4a89fe8f', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'Arbetsmarknadsprogram', '', '2026-08-28 19:05:47.392639+00'),
	('c2c60f6f-edbd-45fd-aa00-b9523eb594f0', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'Omställningsstudiestöd', '', '2026-08-28 19:05:47.397703+00'),
	('cfce66c9-513b-4074-89ab-bde1422c7fa8', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'Bostadsanpassning', '', '2026-08-28 19:05:47.402451+00'),
	('bdf07111-602b-4280-a5e3-1231b7b1caab', '7aadc7e1-b039-4488-83bc-b5eaf129c863', 'Kulturbryggan', '', '2026-08-28 19:05:47.407378+00'),
	('9a6556a6-33bd-4f8f-85dc-052f0d8071b3', '289fbe84-3d6a-4d62-ae45-9e2f284a0761', 'Bidrag till kulturarvsarbete', '', '2026-08-28 19:05:47.412901+00'),
	('4bcbc97c-2e45-4490-8c3d-22a649a25b73', '471d5586-a07e-4256-8a02-4923cc1b9b19', 'Creative Force', '', '2026-08-28 19:05:47.418098+00'),
	('a1c482e2-0f89-46af-bbba-cb52bd53ba5c', 'd8174b27-1934-450d-909e-74445d1cdf5d', 'Projektstöd', '', '2026-08-28 19:05:47.423362+00'),
	('55b6f048-f331-4c6e-8b6a-afe665549083', 'e4ccb9a5-dc99-4045-8368-14f3110e7ee0', 'Projektbidrag', '', '2026-08-28 19:05:47.428629+00'),
	('81ca3b88-e99a-4a39-9da9-516ab18c23a7', '1180e0a9-e60d-40d5-a4bb-8c0658834f19', 'Projektstöd', '', '2026-08-28 19:05:47.432867+00'),
	('fcecaae5-16ce-4fc4-acb9-efdc931a3dd8', '5c2016b6-f733-4a4f-9f06-1bacb2cda675', 'Musiksamarbeten', '', '2026-08-28 19:05:47.437596+00'),
	('5ad76025-c5b8-4bf7-922a-4e33bde026a6', '13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', 'Erasmus+ Partnerskap', '', '2026-08-28 19:05:47.442321+00');
INSERT INTO public.funding_programmes VALUES
	('42ba6669-1fae-4860-9658-a9ff8286c631', '08248302-d932-4084-a794-f2d8ed80e057', 'Regionala företagsstöd', '', '2026-08-28 19:05:47.447149+00'),
	('dfbc44b4-5ea6-4781-9533-306bbfbf9a7e', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'Litteratur och bibliotek', '', '2026-08-28 19:05:47.45219+00'),
	('3f5b96cd-6ad2-4a95-a4b1-fa0e59c88d73', 'cb2c2570-e8f4-4bc3-86fb-c1985027fdb6', 'Bygdemedel', '', '2026-08-28 19:05:47.46038+00'),
	('becf17d8-91bb-4d4c-8114-28342b6280fe', '7cd7f6c5-33de-49cf-9959-ecfdf7406b3d', 'Frivillig återvandring', '', '2026-08-28 19:05:47.465277+00'),
	('9b3b26e5-626c-4400-a722-f610c1f38614', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'EURES', '', '2026-08-28 19:05:47.469892+00'),
	('e5cbced7-eb49-469f-b81c-b30451f3bca6', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Omvårdnadsbidrag', '', '2026-08-28 19:05:47.478789+00'),
	('260700a8-b5cb-44db-9c5b-5ebbc6bf62c6', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Merkostnadsersättning', '', '2026-08-28 19:05:47.486069+00'),
	('6d5dc1f1-263a-4a60-ae13-94c9359e09f4', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Bilstöd', '', '2026-08-28 19:05:47.490678+00'),
	('d44d6c1e-83fa-46ee-8bea-70c8eb847043', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Närståendepenning', '', '2026-08-28 19:05:47.495279+00'),
	('b0a1dbe4-7b95-4642-a7ba-6ca5aa003956', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'Etableringsprogrammet', '', '2026-08-28 19:05:47.500058+00'),
	('033a0ffa-a964-4f6b-8624-b2e787b414ca', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'Hemutrustningslån', '', '2026-08-28 19:05:47.504904+00'),
	('bfa3dc10-8e42-4480-840d-cde746875590', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'Studiestartsstöd', '', '2026-08-28 19:05:47.510089+00'),
	('d9208846-350a-4a86-bfd3-6dfb228542b5', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'Inackorderingstillägg', '', '2026-08-28 19:05:47.51498+00'),
	('949dd6d5-dc8a-47af-a78e-7e09e637dbcb', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'Föreningsbidrag', '', '2026-08-28 19:05:47.521978+00'),
	('5b322d11-259b-43fb-a29a-768b3b0b1561', '4a35ddab-675d-42d2-9775-a483285ec84e', 'Regionalt kulturstöd', '', '2026-08-28 19:05:47.526571+00'),
	('40f700cc-0aee-44bd-b41e-30f1a9eb86c3', 'f8ad8f1e-4686-4fa9-bd93-8104df989a2d', 'Projektstöd', '', '2026-08-28 19:05:47.531485+00'),
	('862527a8-e069-4308-a580-886e60422366', 'b2e0436a-46a5-4353-840c-daecf935e86a', 'Leader — lokalt ledd utveckling', '', '2026-08-28 19:05:47.53659+00'),
	('437138bd-bdc2-4874-ad5e-6c6b7ec9aa3c', '0b29c47b-a9ee-422e-b3cf-70cc3d40d453', 'Projektbidrag', '', '2026-08-28 19:05:47.541293+00'),
	('c635cb10-fb9b-416d-9249-17391e6a44cc', '5bb1059c-7173-484a-a36c-9d907d2b60ac', 'Projektbidrag', '', '2026-08-28 19:05:47.545521+00'),
	('e8ae15eb-8330-445b-a5b2-0afb19f799eb', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Vid sjukdom', '', '2026-08-28 19:05:47.565114+00'),
	('7895bc53-f9b1-4888-8ab3-d7e5d6b1790f', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Vid arbetslöshet', '', '2026-08-28 19:05:47.573604+00'),
	('bf947079-c93c-4fee-b9a7-58bf9fd8b703', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Tandvårdsstöd', '', '2026-08-28 19:05:47.578954+00'),
	('b3595c40-5242-4cf8-9adf-f091e37e286f', '6b993806-e6f5-43e3-b37e-542c6b2952bc', 'Grundskydd för pensionärer', '', '2026-08-28 19:05:47.583988+00'),
	('fbfa5d26-a30d-4b25-8531-813a9a5f1d59', '4a35ddab-675d-42d2-9775-a483285ec84e', 'Patientavgifter', '', '2026-08-28 19:05:47.588624+00'),
	('5d1641ca-3f7c-4748-94ac-98d595d4a9ac', '335178e6-1b98-4482-a282-2b6788dd7622', 'Arbetslöshetsförsäkringen', '', '2026-08-28 19:05:47.593273+00'),
	('a8c7c837-be6a-4595-b86c-c5e81123e03c', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'Anställningsstöd', '', '2026-08-28 19:05:47.597567+00');


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
-- Data for Name: kb_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.kb_translations VALUES
	('60f11359-543a-49c3-b26d-b1949b0f3e88', 'en', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Activity support for sports clubs running leader-led activities for children and young people aged 7–25.', '2026-08-28 19:05:47.707476+00'),
	('0b76161c-f009-4e82-b2b3-e6c2f4fcd1dc', 'en', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'An automatic supplement to the child allowance (barnbidrag) from the second child onwards.', '2026-08-28 19:05:47.707476+00'),
	('4625ea32-caf1-459e-b2e6-50515f69e58c', 'en', 'Avser ansökan en fysisk investering?', 'Does the application concern a physical investment?', '2026-08-28 19:05:47.707476+00'),
	('58b814d5-d36c-42bc-bbea-fad75dcc5940', 'en', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Does the application concern an international trip or exchange?', '2026-08-28 19:05:47.707476+00'),
	('c310e072-c029-4ef2-ab04-01937769c556', 'en', 'Avser ansökan en investering i byggnader eller maskiner?', 'Does the application concern an investment in buildings or machinery?', '2026-08-28 19:05:47.707476+00'),
	('ddf6ad27-c1e3-4c3d-a9c1-c17593008ba3', 'en', 'Avser ansökan en redan utgiven titel?', 'Does the application concern an already published title?', '2026-08-28 19:05:47.707476+00'),
	('30ca5d13-9eda-4929-801a-e0ceee1a3d72', 'en', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Does the application concern an agricultural, horticultural or reindeer husbandry business?', '2026-08-28 19:05:47.707476+00'),
	('89bec592-5543-4c93-ae64-f2d5fa534cb7', 'en', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Does the application concern purchasing literature for public or school libraries?', '2026-08-28 19:05:47.707476+00'),
	('40aff41e-d5ac-465b-b0ad-377f0fa64a41', 'en', 'Avser investeringen jordbruksverksamhet?', 'Does the investment concern agricultural activities?', '2026-08-28 19:05:47.707476+00'),
	('b9fab939-75c2-45b6-806b-388d207ad1e8', 'en', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Does the project involve building, buying or renovating premises?', '2026-08-28 19:05:47.707476+00'),
	('736d24a0-5e0d-4123-8e44-19fa9ebc35b3', 'en', 'Avser projektet naturvård eller friluftsliv?', 'Does the project concern nature conservation or outdoor recreation?', '2026-08-28 19:05:47.707476+00'),
	('ff541207-cbd9-404d-b17d-1487cc967f80', 'en', 'Avser projektet skola eller vuxenutbildning?', 'Does the project concern school or adult education?', '2026-08-28 19:05:47.707476+00'),
	('48613c78-6b57-4941-aec9-4d0e08d746df', 'en', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Are you refraining from work to care for or be close to a relative who is so seriously ill that the illness is a threat to their life?', '2026-08-28 19:05:47.707476+00'),
	('5b000766-ed0d-48d6-ba10-b65830e5205c', 'en', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Does the association run regular activities in the municipality?', '2026-08-28 19:05:47.707476+00'),
	('68bf5a8d-5d72-47ae-8cfb-43796788288a', 'en', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Do you consider your ability to work to be reduced for at least a year due to illness or disability?', '2026-08-28 19:05:47.707476+00'),
	('51a512df-85d9-44a2-9074-bd1891181c90', 'en', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Means-tested support for you who have a low pension or none and need help reaching a reasonable standard of living.', '2026-08-28 19:05:47.707476+00'),
	('85451cb5-f238-4e9e-ad09-0e611b338af0', 'en', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Does the child need to live in the town of study (lodging) because the journey is too long?', '2026-08-28 19:05:47.707476+00'),
	('13bfc3ff-7b1d-4c29-89f3-fabc5e37d2f5', 'en', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Does the home need to be adapted (e.g. a ramp, door opener, bathroom)?', '2026-08-28 19:05:47.707476+00'),
	('65b4080f-f90d-44b9-a8aa-0068e8d56b35', 'en', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Does any of your children aged 8–19 need glasses or contact lenses?', '2026-08-28 19:05:47.707476+00'),
	('f534ec1e-51f4-4162-9917-31b27e76a325', 'en', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Does the other parent pay nothing, or less than full maintenance?', '2026-08-28 19:05:47.707476+00'),
	('239b6b8c-c501-42f0-b246-bc7068a8171f', 'en', 'Betalar du hyra eller andra boendekostnader?', 'Do you pay rent or other housing costs?', '2026-08-28 19:05:47.707476+00'),
	('80d66d47-3df8-4721-836d-a1d284e5f651', 'en', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'A grant for adapting your home in case of disability — e.g. ramps, door openers or bathroom adaptations.', '2026-08-28 19:05:47.707476+00'),
	('fd0ba6fd-ec86-47cd-a13f-1ab61acd0a97', 'en', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Grants for building, buying or renovating public assembly halls.', '2026-08-28 19:05:47.707476+00'),
	('956bf8d0-62d9-40ad-8641-2125cc0cb7f6', 'en', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'A grant for buying or adapting a car when a lasting disability makes it very difficult to get around or travel by public transport.', '2026-08-28 19:05:47.707476+00'),
	('ca9b0831-3eb5-4f25-a394-b3116202d0dd', 'en', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Grants for international travel and exchanges for professionals in the cultural sector.', '2026-08-28 19:05:47.707476+00'),
	('b3703566-9433-4e64-95f7-746fd787b0b8', 'en', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Grants for professional artists'' international exchanges, travel and working stays.', '2026-08-28 19:05:47.707476+00'),
	('4e55390b-dfee-45ad-acc8-f4ae2edb4bf8', 'en', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'A grant and optional loan for studies at upper secondary or post-secondary level.', '2026-08-28 19:05:47.707476+00'),
	('54754551-95f2-4fe4-b6b3-96b1d7cddff7', 'en', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Grants and loans for studies abroad, with extra supplementary loans for e.g. tuition fees and travel.', '2026-08-28 19:05:47.707476+00'),
	('25d3bbb9-98d7-44db-bdaa-31eef06ed3fe', 'en', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'A grant that helps Swedish actors prepare applications for EU programmes such as Horisont Europa.', '2026-08-28 19:05:47.707476+00'),
	('8eb3c180-764c-4d17-9576-05365a6aeaf2', 'en', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'A grant for employers who hire people with reduced work capacity.', '2026-08-28 19:05:47.707476+00'),
	('fa70eb75-b059-40bf-98f3-44cbd51046e5', 'en', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'A grant towards lodging and journeys home when an upper secondary pupil has to live in the town of study because of a long journey.', '2026-08-28 19:05:47.707476+00'),
	('7f1a4c5a-64e6-42f5-8b0e-8f4c788e773a', 'en', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Grants for non-profit organisations'' work to preserve, use and develop cultural heritage.', '2026-08-28 19:05:47.707476+00'),
	('362b5d2c-fbe0-40a2-ac76-6da6a966a9b5', 'en', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Grants for municipal and local nature conservation projects, including wetlands and outdoor recreation.', '2026-08-28 19:05:47.707476+00'),
	('785227d3-cedf-46ea-a057-ad1ee85ff2d4', 'en', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Grants to municipalities for purchasing literature for public and school libraries.', '2026-08-28 19:05:47.707476+00'),
	('e0c1b246-34d6-433c-ba85-09ea065ce79a', 'en', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Grants to school authorities for pupils'' encounters with professional culture in compulsory school.', '2026-08-28 19:05:47.707476+00'),
	('95852c51-fcda-4712-a001-b33d031ef540', 'en', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'EU social fund money for projects that strengthen skills, transition and inclusion in the labour market.', '2026-08-28 19:05:47.707476+00'),
	('c54b6061-e620-4ba9-9215-5cdaff1f220a', 'en', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Grants for things your child needs but the family finances cannot cover: leisure activities, clothes, school outings, glasses, holiday activities and more.', '2026-08-28 19:05:47.707476+00'),
	('3d2045e4-4c39-4a73-9851-fd81fc282bdf', 'en', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Grants from funds such as Världens Barn, Musikhjälpen and Victoriafonden — applied for by Swedish non-profit organisations with a 90-konto.', '2026-08-28 19:05:47.707476+00'),
	('e70312d8-034d-45de-b400-9aa5a5d83bcc', 'en', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Grants from hydropower and wind power funds for projects that develop the local community.', '2026-08-28 19:05:47.707476+00'),
	('ada17bb7-ecc8-4e46-a8ad-b35445afd5fc', 'en', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'A grant with no loan component for unemployed people aged 25–60 with short previous education who need to study at compulsory or upper secondary level.', '2026-08-28 19:05:47.707476+00'),
	('e61b711f-016a-4415-8ecb-807a8f75a6c6', 'en', 'Bidrar projektet till energiomställningen?', 'Does the project contribute to the energy transition?', '2026-08-28 19:05:47.707476+00'),
	('f308a5e9-f58c-46d2-9e32-b6e2a016f838', 'en', 'Bor du och barnets andra förälder på skilda håll?', 'Do you and the child''s other parent live apart?', '2026-08-28 19:05:47.707476+00'),
	('90218e2a-2712-4d4f-909e-21d1943a1027', 'en', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Vouchers for small companies to bring in external expertise for internationalisation or digitalisation.', '2026-08-28 19:05:47.707476+00'),
	('a86a6ee5-9c22-489b-a27d-54f61c81634d', 'en', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Are you taking part in a programme at Arbetsförmedlingen (e.g. jobb- och utvecklingsgarantin)?', '2026-08-28 19:05:47.707476+00'),
	('75a9d297-3191-4924-a2db-676dbb7bab6d', 'en', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Retrospective support to publishers for publishing quality literature.', '2026-08-28 19:05:47.707476+00'),
	('f060fcd6-4639-44ac-83da-c17173faff8d', 'en', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Financial support for those with a protection-related residence permit who voluntarily want to move back to their country of origin permanently.', '2026-08-28 19:05:47.707476+00'),
	('d55d42f8-a65b-480e-97d1-253aeebe26f9', 'en', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Financial support for employers who hire someone who has been away from working life for a long time.', '2026-08-28 19:05:47.707476+00'),
	('5131a692-4deb-4cc1-9054-a8c62e200165', 'en', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Financial support during the start-up phase for jobseekers starting their own business.', '2026-08-28 19:05:47.707476+00'),
	('d35ee128-882f-4b75-b819-f7325fd2e103', 'en', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten continuously opens calls within energy research, innovation and energy efficiency.', '2026-08-28 19:05:47.707476+00'),
	('79a82e22-a85e-4415-9bf1-2eafb8dc2743', 'en', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Compensation for taking time off work or studies to care for a child.', '2026-08-28 19:05:47.707476+00');
INSERT INTO public.kb_translations VALUES
	('6bdba53c-b11d-4d73-88d4-17232bbb7eff', 'en', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Compensation for those who are new in Sweden and take part in the establishment programme at Arbetsförmedlingen; paid out by Försäkringskassan.', '2026-08-28 19:05:47.707476+00'),
	('dfe0303c-06e2-46eb-a80c-7f91053468c5', 'en', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Compensation for part of the housing cost for young people without children on low incomes.', '2026-08-28 19:05:47.707476+00'),
	('df005165-a441-4435-a828-1336200acca4', 'en', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Compensation for the extra costs that a lasting disability brings — for adults, or for parents of children with disabilities.', '2026-08-28 19:05:47.707476+00'),
	('132d7258-7a25-43ce-88ba-e520434101a5', 'en', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Compensation for young people (19–29) who cannot work full-time for at least a year due to illness or disability.', '2026-08-28 19:05:47.707476+00'),
	('637d666d-eb6f-4208-82e7-9178047ce0db', 'en', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Compensation when your ability to work is permanently reduced — previously known as förtidspension (early retirement pension).', '2026-08-28 19:05:47.707476+00'),
	('a992ad3d-9847-4be2-a1ff-a79a3a159253', 'en', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Compensation when you refrain from work to be close to a seriously ill relative.', '2026-08-28 19:05:47.707476+00'),
	('bf653cbe-6ac0-4bbe-8ae0-42d77d9d24ae', 'en', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Compensation when you take part in a labour market programme at Arbetsförmedlingen.', '2026-08-28 19:05:47.707476+00'),
	('37f220bd-b18e-46cc-af55-fd60501979bb', 'en', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Compensation when you cannot work as usual due to illness.', '2026-08-28 19:05:47.707476+00'),
	('d32f8ada-e263-489a-8a67-6c1aa60c2f86', 'en', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Compensation when you stay home from work to care for a sick child.', '2026-08-28 19:05:47.707476+00'),
	('3ad57ac0-43f2-4187-9625-fdad00a30704', 'en', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Compensation covering part of the housing cost for households with children and lower incomes.', '2026-08-28 19:05:47.707476+00'),
	('189f643f-b2cf-4c2e-9d6c-e76991874fe5', 'en', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Compensation for parents whose children, due to disability, need more care and supervision than children of the same age.', '2026-08-28 19:05:47.707476+00'),
	('33e1a2bd-1922-4b54-9eab-05d3fb24d846', 'en', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Compensation during unemployment — income-based for members, a basic amount for others.', '2026-08-28 19:05:47.707476+00'),
	('12e878fd-b058-449c-aa27-9f98671541a2', 'en', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Some fifty savings bank foundations award grants to local projects in sports, culture, education and community development — within the savings bank''s area of operation.', '2026-08-28 19:05:47.707476+00'),
	('7b0fae08-af9c-487a-be3f-610721c4a4f0', 'en', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'EU-funded project support applied for through your local Leader area — for associations, companies and municipalities developing rural areas.', '2026-08-28 19:05:47.707476+00'),
	('a79f51f6-e31b-4432-a86f-571664f52846', 'en', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU-funded support for jobseekers taking a job in another EU/EEA country: compensation for interview travel, moving costs and language courses.', '2026-08-28 19:05:47.707476+00'),
	('3170b031-faa8-46ca-a34f-757cbe0e1d4a', 'en', 'Är volontärerna mellan 18 och 30 år?', 'Are the volunteers between 18 and 30 years old?', '2026-08-28 19:05:47.711758+00'),
	('dc0272e3-8530-4982-94dc-528544c4f2ff', 'en', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'EU support for group exchanges for young people aged 13–30, lasting 5–21 days excluding travel days.', '2026-08-28 19:05:47.707476+00'),
	('ef7f1db8-df72-4536-92f3-5cabadae8343', 'en', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'EU support for cultural organisations'' cooperation projects with partners in several European countries.', '2026-08-28 19:05:47.707476+00'),
	('30de3dac-863b-4996-b6cc-0c2ba32eb631', 'en', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'EU support for organisations receiving or sending young volunteers aged 18–30.', '2026-08-28 19:05:47.707476+00'),
	('da1e9a79-a486-49f2-8e08-b60062e6b053', 'en', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'EU support for staff and pupil mobility in schools and adult education.', '2026-08-28 19:05:47.707476+00'),
	('2c4a782d-bc90-4951-a4ea-7c77204a4808', 'en', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'EU support with lump sums for smaller organisations'' first European cooperation projects.', '2026-08-28 19:05:47.707476+00'),
	('f71c6302-d91a-4813-baa1-43b2ac5c98a5', 'en', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Funding for young companies developing innovative products or services with international potential.', '2026-08-28 19:05:47.707476+00'),
	('51691495-39ae-4147-a580-7b0d100234e7', 'en', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Is there a savings bank (and thus a savings bank foundation) where you operate?', '2026-08-28 19:05:47.707476+00'),
	('58730418-40fc-42ec-a9f3-04faca8216ae', 'en', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Multi-year operating grants for professional independent groups in dance, theatre and musical theatre.', '2026-08-28 19:05:47.707476+00'),
	('0af8f546-3fb8-41e0-a50d-ddcc4778adfa', 'en', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Research grants within Forte''s areas of responsibility: health, working life and welfare. Applied for by researchers with a doctorate at Swedish higher education institutions.', '2026-08-28 19:05:47.707476+00'),
	('1736b941-386b-4394-9b27-a1df1e0e8052', 'en', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Research funding for free basic research in all scientific fields.', '2026-08-28 19:05:47.707476+00'),
	('67b0f606-7434-4ea9-bdfa-b1caf53d64d6', 'en', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Research funding within the environment, agricultural sciences and spatial planning.', '2026-08-28 19:05:47.707476+00'),
	('c8c60b0d-a04c-4ee9-9df1-35fb5ec9e158', 'en', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Are you thinking about moving abroad (for work, studies or return migration)?', '2026-08-28 19:05:47.707476+00'),
	('ede6f814-204c-4d92-8f9e-bcd55fc987fc', 'en', 'Genomförs insatserna av professionella kulturaktörer?', 'Are the activities carried out by professional cultural actors?', '2026-08-28 19:05:47.707476+00'),
	('02a70c67-703c-4493-ae1b-24efef51f1d5', 'en', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Is the project carried out in a rural area or a smaller town?', '2026-08-28 19:05:47.707476+00'),
	('fa5f2b95-4f58-4aab-90ef-14644f2002a5', 'en', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Basic protection for those who have had little or no earned income during their life.', '2026-08-28 19:05:47.707476+00'),
	('bcf89fab-3d0c-4b4d-8fa4-55814542acfa', 'en', 'Går något av dina barn i grundskolan?', 'Is any of your children in compulsory school?', '2026-08-28 19:05:47.707476+00'),
	('a224a5d4-9eba-4aab-87e2-ef9e8a03d32b', 'en', 'Går något av dina barn på gymnasiet?', 'Is any of your children in upper secondary school?', '2026-08-28 19:05:47.707476+00'),
	('655c5105-0862-4b9f-8294-c0ad4c232260', 'en', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Does the employment concern a person with reduced work capacity?', '2026-08-28 19:05:47.707476+00'),
	('0b703485-fba8-4935-b8d6-af4289700851', 'en', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Does the employment concern someone who has been unemployed for a long time or is new in Sweden?', '2026-08-28 19:05:47.707476+00'),
	('63eac34c-0fbc-4fda-bedd-096a3feb3f71', 'en', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Is the project about preserving or making cultural heritage accessible?', '2026-08-28 19:05:47.707476+00'),
	('5fe3fb7f-43ad-46b8-af59-5f3db0f34a64', 'en', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Is the project about energy, energy efficiency or energy-related innovation?', '2026-08-28 19:05:47.707476+00'),
	('f02c7b1f-1904-403d-86af-9c19515d8971', 'en', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Is the project about health, working life or welfare?', '2026-08-28 19:05:47.707476+00'),
	('01b0262d-2f72-4e6d-b29c-60671dd07591', 'en', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Is the project about skills development or labour market measures?', '2026-08-28 19:05:47.707476+00'),
	('83b2c035-a292-4802-bb76-e640ffada721', 'en', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Is the project about environmental or climate measures?', '2026-08-28 19:05:47.707476+00'),
	('b0c3b9a8-b097-4a09-8c4e-92cd10ef8a16', 'en', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Does the child have a long, traffic-hazardous or otherwise difficult route to school?', '2026-08-28 19:05:47.707476+00'),
	('e3f18bdd-aacd-4272-8d45-a64203b62356', 'en', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Have you worked at least 16 hours a week for a total of at least 8 years?', '2026-08-28 19:05:47.707476+00'),
	('01579bc5-0f6b-46c1-8da8-791826878062', 'en', 'Har du barn som bor hos dig, helt eller växelvis?', 'Do you have children living with you, full-time or alternately?', '2026-08-28 19:05:47.707476+00'),
	('9db01543-9035-45fb-b23d-baa85ebb5958', 'en', 'Har du barn som bor hos dig?', 'Do you have children living with you?', '2026-08-28 19:05:47.707476+00'),
	('0026c52c-e0a2-4739-89d1-800c5ed2cfdd', 'en', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Do you or your child have a disability expected to last at least a year?', '2026-08-28 19:05:47.707476+00'),
	('171f4384-0a5b-4660-aee7-ac18417e903a', 'en', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Do you or anyone in the household have a lasting disability that affects your housing?', '2026-08-28 19:05:47.707476+00'),
	('1ca3e84c-6208-441e-999a-79f97e57ca7c', 'en', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Do you or a close relative have a disability or a long-term or serious illness?', '2026-08-28 19:05:47.707476+00'),
	('c95754fb-0ec8-41ca-b862-4c091ab4c149', 'en', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Do you have an illness or injury that currently reduces your ability to work?', '2026-08-28 19:05:47.707476+00'),
	('247b238c-c1d3-44fd-b006-11c69f138894', 'en', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Have you ever found it hard to pay for a school outing, class trip or leisure activity your child is expected to take part in?', '2026-08-28 19:05:47.707476+00'),
	('f92d45c0-cc3a-4b49-bb7d-93309f0be771', 'en', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Do you find it hard to manage on your pension and your other income?', '2026-08-28 19:05:47.707476+00');
INSERT INTO public.kb_translations VALUES
	('d2e456cd-ea84-4ac2-bac2-d59b46169b8a', 'en', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Have you been granted a residence permit in Sweden in recent years, e.g. as a person in need of protection or as a family member?', '2026-08-28 19:05:47.707476+00'),
	('02335bcb-c9e6-4fc0-a789-a64656d073d9', 'en', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Do you have a residence permit in Sweden as a refugee or person in need of protection (or are you a close family member of someone who has)?', '2026-08-28 19:05:47.707476+00'),
	('697354e6-0ff2-42a4-851e-c07d17f5dbef', 'en', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Have you reached the target age for pension (67 in 2026)?', '2026-08-28 19:05:47.707476+00'),
	('1c25ef4c-891e-493b-b5b8-14ff58c7af8c', 'en', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Does your organisation have an OID (Organisation ID) registered in the EU''s Organisation Registration System?', '2026-08-28 19:05:47.707476+00'),
	('6487b2c9-45a0-49de-a306-2b0591ec0095', 'en', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Has the disability led to extra costs — e.g. aids, travel, special diet or wear and tear?', '2026-08-28 19:05:47.707476+00'),
	('089c7d63-4c30-422e-aaf4-c6b59781d6d8', 'en', 'Har föreningen antagna stadgar och en vald styrelse?', 'Does the association have adopted statutes and an elected board?', '2026-08-28 19:05:47.707476+00'),
	('d6919932-f7c6-455c-bd16-8a1b6c539a8c', 'en', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Does the association have a democratic structure (statutes, annual meeting, board)?', '2026-08-28 19:05:47.707476+00'),
	('6cd989c2-8ad1-4ca3-bc7a-39f6ebbd9c21', 'en', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Does the association run regular activities for children or young people?', '2026-08-28 19:05:47.707476+00'),
	('cb97ebb7-0494-4b50-8797-0f586a5c5535', 'en', 'Har företaget mellan cirka 2 och 49 anställda?', 'Does the company have between roughly 2 and 49 employees?', '2026-08-28 19:05:47.707476+00'),
	('d042e250-a9d5-46f1-80a2-a468f9bdf9f5', 'en', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Does the household struggle to cover the costs of food, housing and the bare necessities?', '2026-08-28 19:05:47.707476+00'),
	('10b8a761-45ef-4a2f-83d1-84fd11c813fc', 'en', 'Har lösningen internationell potential?', 'Does the solution have international potential?', '2026-08-28 19:05:47.707476+00'),
	('70316d25-0e41-423a-ab25-ddb0c737c324', 'en', 'Har ni en partnergrupp i ett annat land?', 'Do you have a partner group in another country?', '2026-08-28 19:05:47.707476+00'),
	('56701042-f6bf-434a-809f-debd835f62d4', 'en', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Do you have a partner organisation in another European country?', '2026-08-28 19:05:47.707476+00'),
	('457380a6-850c-46df-9ed5-41e7ec04537f', 'en', 'Har ni partner i minst tre olika europeiska länder?', 'Do you have partners in at least three different European countries?', '2026-08-28 19:05:47.707476+00'),
	('648ecf61-82ac-4d1f-ba02-43f59e4b0777', 'en', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Is your registered office or main activity in the region where you are applying?', '2026-08-28 19:05:47.707476+00'),
	('59816cc1-3195-4a9e-9404-6ab62fc0a38d', 'en', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Does any of your children have a disability that means the child needs more care or supervision than other children of the same age?', '2026-08-28 19:05:47.707476+00'),
	('b6a2298b-541f-4271-b61b-8231ebaef134', 'en', 'Har organisationen en demokratisk uppbyggnad?', 'Does the organisation have a democratic structure?', '2026-08-28 19:05:47.707476+00'),
	('29c73c6b-7172-4897-8c4b-57e28e62ac75', 'en', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Does the organisation have a Quality Label?', '2026-08-28 19:05:47.707476+00'),
	('3680c65f-3a8b-42db-bb8e-0d0bee788ed3', 'en', 'Har organisationen ett 90-konto?', 'Does the organisation have a 90-konto?', '2026-08-28 19:05:47.707476+00'),
	('8f99abdb-fb57-40c1-965e-954d515cb42e', 'en', 'Har organisationen ett OID (Organisation ID)?', 'Does the organisation have an OID (Organisation ID)?', '2026-08-28 19:05:47.707476+00'),
	('02456807-5c15-4e84-8a5b-2c7a95cae36e', 'en', 'Har organisationen ett OID?', 'Does the organisation have an OID?', '2026-08-28 19:05:47.707476+00'),
	('78415bf1-cea6-43b0-9df4-e0fd50b612fb', 'en', 'Har organisationen medlemsföreningar i flera län?', 'Does the organisation have member associations in several counties?', '2026-08-28 19:05:47.707476+00'),
	('67c8d878-8370-432a-a12e-301778a7437b', 'en', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Does the organisation have sound finances and a democratic structure?', '2026-08-28 19:05:47.707476+00'),
	('0bebda6b-5c7e-47b9-8dee-14860a23fa33', 'en', 'Har projektet en partner i ett annat land?', 'Does the project have a partner in another country?', '2026-08-28 19:05:47.707476+00'),
	('157cdf9e-b1ab-4ecb-9ee4-a0c7b2b87672', 'en', 'Har projektledaren doktorsexamen?', 'Does the project leader have a doctoral degree?', '2026-08-28 19:05:47.707476+00'),
	('a0de2742-9fcf-4633-baf1-024c3ebade2f', 'en', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Your home municipality must provide daily travel between home and upper secondary school when the route is at least six kilometres (e.g. a bus pass).', '2026-08-28 19:05:47.707476+00'),
	('bbc543b0-1518-4cad-b083-46b2a106b389', 'en', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Are you in the process of getting or equipping your first own home in Sweden?', '2026-08-28 19:05:47.707476+00'),
	('5da30078-21c2-4477-b3d5-52861a08bb59', 'en', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Does the project include an international trip or exchange?', '2026-08-28 19:05:47.707476+00'),
	('c32321de-dc7d-48ce-aa6b-f2d6996b9735', 'en', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Investment support for companies in designated support areas, for buildings, machinery and training.', '2026-08-28 19:05:47.707476+00'),
	('48253aae-9b5f-48b1-9721-c363addab175', 'en', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Investment support for measures that reduce greenhouse gas emissions.', '2026-08-28 19:05:47.707476+00'),
	('e99392ee-ec97-48d3-8085-1721a7f99f3c', 'en', 'Kan projektets miljönytta mätas?', 'Can the project''s environmental benefit be measured?', '2026-08-28 19:05:47.707476+00'),
	('efc3cf52-3445-43f6-907a-49bf426cb4cc', 'en', 'Kan åtgärdens utsläppsminskning beräknas?', 'Can the measure''s emission reduction be calculated?', '2026-08-28 19:05:47.707476+00'),
	('ac1971f5-33d4-40be-8c6a-60c7482ef3e9', 'en', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Can the organisation carry the costs until the support is paid out?', '2026-08-28 19:05:47.707476+00'),
	('ae5f75d0-5122-4548-8cba-5e9da9bb4906', 'en', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Will the experience be used in your activities in Sweden?', '2026-08-28 19:05:47.707476+00'),
	('be81c9ca-5c5b-4bf2-8023-bf0d7597640f', 'en', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Will the investment start only after you have submitted the application?', '2026-08-28 19:05:47.707476+00'),
	('7be25cb0-d8d4-4e96-bb22-6aaf77fc36a6', 'en', 'Kommer projektet människor i ert närområde till del?', 'Does the project benefit people in your local area?', '2026-08-28 19:05:47.707476+00'),
	('0171fd6d-a9ed-4fb1-ad74-734d79cc5ed3', 'en', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'The municipality''s last financial safety net when income does not cover the bare necessities.', '2026-08-28 19:05:47.707476+00'),
	('3f0ae970-75d2-429b-bc34-14b368102868', 'en', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'The municipalities'' own support for the local association scene: activity support per session, premises grants, start-up grants and more.', '2026-08-28 19:05:47.707476+00'),
	('9848df8c-520a-4926-acda-a5ab669d9269', 'en', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Free school transport for compulsory school pupils in case of long distance, traffic-hazardous routes or disability — a right under the Education Act.', '2026-08-28 19:05:47.707476+00'),
	('f5056984-596b-4692-954a-03e92e928f04', 'en', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'A statutory grant towards glasses or contact lenses for children and young people; amounts and routines vary by region — check your region''s level.', '2026-08-28 19:05:47.707476+00'),
	('88fd1d4b-e91c-48e1-a61c-5b3bf5161bd6', 'en', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Is the project located in an area affected by hydropower or wind power?', '2026-08-28 19:05:47.707476+00'),
	('983e9038-bf79-4dac-a58c-e8bfca5eb93f', 'en', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Is the project within the environment, agricultural sciences or spatial planning?', '2026-08-28 19:05:47.707476+00'),
	('09c7ebea-b211-4d98-8a91-1928962af05e', 'en', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Is your place of business in support area A or B (large parts of Norrland and inner Svealand)?', '2026-08-28 19:05:47.707476+00'),
	('f0c36860-772b-49be-815f-58b2ed0f0f74', 'en', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'A loan for buying the essentials for a first home in Sweden — furniture, household goods and other basic equipment.', '2026-08-28 19:05:47.707476+00'),
	('bf36d06e-905b-451e-90eb-78e2f874f68f', 'en', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Does the project reduce industrial process emissions or create negative emissions?', '2026-08-28 19:05:47.707476+00'),
	('dbf5c8cb-4298-4ff4-ba49-98540cf1bcbc', 'en', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'A monthly allowance for children living in Sweden, from birth until age 16.', '2026-08-28 19:05:47.707476+00'),
	('e88a1a49-9e6c-4f85-842b-01353061156c', 'en', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket offers grants to organisations, companies, associations, the public sector and private individuals in the environmental field.', '2026-08-28 19:05:47.707476+00'),
	('bd3f33df-401b-49b7-9790-30946200a37c', 'en', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Are you planning to voluntarily move back to your country of origin permanently?', '2026-08-28 19:05:47.707476+00'),
	('96a8a008-3ec4-4707-a9d5-77c933003eec', 'en', 'Planerar du att starta eget företag?', 'Are you planning to start your own business?', '2026-08-28 19:05:47.707476+00'),
	('150d2010-e284-43e8-a7c0-a94420bac101', 'en', 'Planerar du att studera utomlands?', 'Are you planning to study abroad?', '2026-08-28 19:05:47.707476+00');
INSERT INTO public.kb_translations VALUES
	('c3da17cb-5c86-49fa-81e6-ee671a5ca2b8', 'en', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Are you planning studies that strengthen your position in the labour market?', '2026-08-28 19:05:47.707476+00'),
	('543dc2ec-2123-4ccb-8658-d18c2f5722e0', 'en', 'Planerar ni att anställa?', 'Are you planning to hire?', '2026-08-28 19:05:47.707476+00'),
	('14f1a41a-0a7e-486b-af59-654a8303e561', 'en', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Are you planning to apply to an EU programme (e.g. Horisont Europa)?', '2026-08-28 19:05:47.707476+00'),
	('dd4344f9-dd76-4f28-bdb9-ecf113f7fdaf', 'en', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Production and development support for short films and documentaries.', '2026-08-28 19:05:47.707476+00'),
	('0788759f-da59-4885-ae93-f698e1feae80', 'en', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Project grants for the independent music scene for concerts, production and development.', '2026-08-28 19:05:47.707476+00'),
	('d5f866a3-721c-4ff7-a0e8-dcbe1372a2f3', 'en', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Project grants for non-profit organisations working with and for children and young people.', '2026-08-28 19:05:47.707476+00'),
	('0257e3d0-6b60-40a1-a08e-59cce4a24274', 'en', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Does the project explore new artistic expressions, methods or collaborations?', '2026-08-28 19:05:47.707476+00'),
	('cf3d3aaa-8cd8-4b02-9d24-c38fef00ec36', 'en', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Does the exchange last 5–21 days (excluding travel days)?', '2026-08-28 19:05:47.707476+00'),
	('0759d742-61b8-42c6-aa6c-f04c1d33dc95', 'en', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'The regions'' own project and operating support for cultural life, alongside Kulturrådet''s national grants.', '2026-08-28 19:05:47.707476+00'),
	('83488e7f-9e4d-4bca-b600-39a07f91f409', 'en', 'Riktar sig projektet till barn eller unga?', 'Is the project aimed at children or young people?', '2026-08-28 19:05:47.707476+00'),
	('045fa4c8-945a-4840-bb5a-1960f8407663', 'en', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Is the project aimed at children, young people, the elderly or people with disabilities?', '2026-08-28 19:05:47.707476+00'),
	('2d3616b7-9141-4d74-9dbf-77157f27530d', 'en', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Are the activities aimed at children and young people (7–25)?', '2026-08-28 19:05:47.707476+00'),
	('d4fd3771-47b7-48ca-ba31-433a7294ca8d', 'en', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Do you lack savings or assets that could cover the expenses?', '2026-08-28 19:05:47.707476+00'),
	('04555319-7aa3-4350-9db3-3d850fed892b', 'en', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Are you cooperating with partners in at least two other Nordic countries?', '2026-08-28 19:05:47.707476+00'),
	('ee983905-6ddf-44bb-a214-c94543bcc90d', 'en', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Will you bring in external expertise for a development initiative?', '2026-08-28 19:05:47.707476+00'),
	('4b69256d-f87c-44d9-8809-12d787042b85', 'en', 'Sker mobiliteten till ett annat europeiskt land?', 'Is the mobility to another European country?', '2026-08-28 19:05:47.707476+00'),
	('003460a1-7f00-41a6-9182-adaf8c392c36', 'en', 'Startar du eller tar du över företaget för första gången?', 'Are you starting or taking over the business for the first time?', '2026-08-28 19:05:47.707476+00'),
	('7fdf773c-e1c4-4ef6-8784-83fe35a967f0', 'en', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Start-up support for those aged 40 or younger who start or take over an agricultural business.', '2026-08-28 19:05:47.707476+00'),
	('fad5fecf-545c-42bd-8aca-9771f4e5c27d', 'en', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'A scholarship that lets professional artists concentrate on their artistic work.', '2026-08-28 19:05:47.707476+00'),
	('8636de58-4dd3-449a-907d-03ba80579bc7', 'en', 'Studerar du, eller planerar du att börja studera?', 'Are you studying, or planning to start studying?', '2026-08-28 19:05:47.707476+00'),
	('5a413a27-4618-48e0-a462-6455e68557db', 'en', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Study support for working adults who want to educate themselves to strengthen their position in the labour market.', '2026-08-28 19:05:47.707476+00'),
	('a9ff59eb-9da8-47de-a0cb-50d32351ea02', 'en', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Support for investments that increase competitiveness or reduce environmental impact in agricultural businesses.', '2026-08-28 19:05:47.707476+00'),
	('a995e007-48bf-486d-8ce3-937cc9c16a00', 'en', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Support when a child lives with you and the other parent does not pay maintenance.', '2026-08-28 19:05:47.707476+00'),
	('2b92d921-dcc9-4d5d-8609-5b3b31a472fa', 'en', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Support for non-profit organisations'' projects for people, the environment and a better world.', '2026-08-28 19:05:47.707476+00'),
	('45f63147-2217-40c1-b000-cc688422a407', 'en', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Support for industry''s transition towards zero greenhouse gas emissions.', '2026-08-28 19:05:47.707476+00'),
	('f3d5d9e6-d777-467a-bfc5-0e74a57f9931', 'en', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Support for arts and culture projects with a Nordic dimension and cross-border cooperation.', '2026-08-28 19:05:47.707476+00'),
	('bfb580b2-c50b-4293-95a9-240c84839ed3', 'en', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Support for innovative cultural projects exploring new artistic expressions, methods or collaborations.', '2026-08-28 19:05:47.707476+00'),
	('f67b7314-6266-4911-81c8-62a2e1f6dbbc', 'en', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Support for innovative projects for children, young people, the elderly and people with disabilities.', '2026-08-28 19:05:47.707476+00'),
	('93d860bc-920d-4672-92cb-36a8aef70dff', 'en', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Support for cooperation projects in the independent music scene.', '2026-08-28 19:05:47.707476+00'),
	('6950208a-299d-423c-ae84-51f5f22f99d6', 'es', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', '¿Le cuesta arreglárselas con su pensión y sus demás ingresos?', '2026-08-28 19:05:47.717202+00'),
	('1e336104-2845-4c42-89e4-72918b3e1c15', 'en', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Support for cooperation projects in culture and media that strengthen democracy and freedom of expression internationally.', '2026-08-28 19:05:47.707476+00'),
	('35bb6a74-a3fd-4d1a-b00b-9e16cb4a08d4', 'en', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Does the project aim to strengthen democracy, equality or freedom of expression?', '2026-08-28 19:05:47.707476+00'),
	('0d26db14-d263-4934-8d91-86a9e6803999', 'en', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Are you looking for a job, or have you received a job offer, in another EU or EEA country?', '2026-08-28 19:05:47.707476+00'),
	('1064c117-1916-426e-87a6-7b96e2347216', 'en', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'A cap on what you need to pay in patient fees over a twelve-month period — after that, a frikort (free pass).', '2026-08-28 19:05:47.707476+00'),
	('17239237-5e89-464e-967d-3eee6593b497', 'en', 'Tar du ut hel allmän pension?', 'Are you drawing your full public pension?', '2026-08-28 19:05:47.707476+00'),
	('470efcb1-4d89-4c11-be7e-8715e890e28a', 'en', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'A supplement covering part of the housing cost for those with a pension and low income.', '2026-08-28 19:05:47.707476+00'),
	('f9597891-0717-49f1-b0ad-bf852e2eb1b0', 'en', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'An annual organisation grant for national child and youth organisations.', '2026-08-28 19:05:47.707476+00'),
	('f212e4ac-77c8-4ca7-8a94-9e182013b398', 'en', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'An annual allowance deducted directly at the dentist or dental hygienist.', '2026-08-28 19:05:47.707476+00'),
	('1ba9f365-86c5-42e8-8059-0c11a00d4c5b', 'en', 'Är bolaget yngre än cirka 5 år?', 'Is the company younger than about 5 years?', '2026-08-28 19:05:47.707476+00'),
	('815fa67a-2ffe-43e2-b44f-b636254e38d3', 'en', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Are the exchange participants between 13 and 30 years old?', '2026-08-28 19:05:47.707476+00'),
	('e8da9293-bcf2-4def-97a9-78cc2bc69399', 'en', 'Är det här ert första EU-projekt?', 'Is this your first EU project?', '2026-08-28 19:05:47.707476+00'),
	('b6ba0ae6-43c0-4147-93cf-aa2370462012', 'en', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Is it very difficult for you (or your child) to get around on your own or to travel by bus and train?', '2026-08-28 19:05:47.707476+00'),
	('9adc68e7-4e69-47b9-bc03-cad2c8f4c1f6', 'en', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Is your income lower than about SEK 25,000 a month before tax?', '2026-08-28 19:05:47.707476+00'),
	('0910128c-ce61-4c8d-abfb-4804a401d19c', 'en', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Is your most recently completed education compulsory school, or an upper secondary programme you did not finish?', '2026-08-28 19:05:47.707476+00'),
	('abeb205c-f4b4-411e-87be-28a30432bd9a', 'en', 'Är du 40 år eller yngre?', 'Are you 40 or younger?', '2026-08-28 19:05:47.707476+00'),
	('f8219843-599a-48db-bcb6-788537778f36', 'en', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Are you registered as a jobseeker with Arbetsförmedlingen?', '2026-08-28 19:05:47.707476+00'),
	('054df266-9558-45aa-8627-8fec6dc42178', 'en', 'Är du mellan 18 och 28 år?', 'Are you between 18 and 28?', '2026-08-28 19:05:47.707476+00'),
	('3eaa173b-1b84-405c-bd2f-f321dbefd40a', 'en', 'Är du mellan 19 och 29 år?', 'Are you between 19 and 29?', '2026-08-28 19:05:47.707476+00'),
	('47453330-8676-43a3-8b0e-87f8fbec428c', 'en', 'Är du mellan 25 och 60 år?', 'Are you between 25 and 60?', '2026-08-28 19:05:47.707476+00'),
	('d9f589f1-633a-4d36-8599-37221f8cb7ab', 'en', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Are you professionally active in the cultural sector (e.g. dance, music, performing arts)?', '2026-08-28 19:05:47.707476+00');
INSERT INTO public.kb_translations VALUES
	('d6aa3e2b-cdba-45dc-9f72-bf6bf3544239', 'en', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Are you a professional artist (not an amateur or in basic training)?', '2026-08-28 19:05:47.707476+00'),
	('14ec004b-5edc-437a-a134-4df075a627d4', 'en', 'Är du yrkesverksam konstnär?', 'Are you a professional artist?', '2026-08-28 19:05:47.707476+00'),
	('8d0c97de-1689-4508-bc21-14f2d55ca5cd', 'en', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Is your solution substantially innovative compared with what already exists?', '2026-08-28 19:05:47.711758+00'),
	('f35586cb-1e08-43b1-bbe7-ae4329aee1af', 'en', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Is the club affiliated to a specialised sports federation within Riksidrottsförbundet?', '2026-08-28 19:05:47.711758+00'),
	('3dad739c-cfef-49de-9cf3-3a527913c062', 'en', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Is the household''s income low in relation to the housing cost?', '2026-08-28 19:05:47.711758+00'),
	('4a0508eb-86d0-40b2-954b-ef8ef79af713', 'en', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Is the household''s combined income lower than about SEK 25,000 a month before tax?', '2026-08-28 19:05:47.711758+00'),
	('539d3ccf-9a56-48c7-b77a-b28626b789e5', 'en', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Is the initiative a defined project (not regular operations)?', '2026-08-28 19:05:47.711758+00'),
	('a3448632-26b3-45a2-8038-6a96fd9deb20', 'en', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Is the venue open to everyone — not just your own members?', '2026-08-28 19:05:47.711758+00'),
	('ddf23fe0-1bba-48aa-9f63-d68da8e42cc7', 'en', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Are at least 60% of the members between 6 and 25 years old?', '2026-08-28 19:05:47.711758+00'),
	('a09fa9e1-5349-4e37-9045-de0b84681fcf', 'en', 'Är minst 60 % av medlemmarna under 26 år?', 'Are at least 60% of the members under 26?', '2026-08-28 19:05:47.711758+00'),
	('21e69534-3c98-4c1f-8b91-ac3e36506c02', 'en', 'Är målgruppen delaktig i planering och genomförande?', 'Is the target group involved in planning and implementation?', '2026-08-28 19:05:47.711758+00'),
	('dafdc2b1-699d-41be-9b4d-c745acd7d6fb', 'en', 'Är ni ett förlag med professionell utgivning?', 'Are you a publisher with professional publishing?', '2026-08-28 19:05:47.711758+00'),
	('454566f4-8e25-48b2-99dc-2ec8fb16e7f8', 'en', 'Är ni huvudman för förskoleklass eller grundskola?', 'Are you the authority responsible for a preschool class or compulsory school?', '2026-08-28 19:05:47.711758+00'),
	('c1960349-af50-41ef-9191-06750a9b7ea1', 'en', 'Är organisationen registrerad i EU:s deltagarregister?', 'Is the organisation registered in the EU''s participant register?', '2026-08-28 19:05:47.711758+00'),
	('65c7b8a7-95dc-42c7-845c-43a8109e3dd8', 'en', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Is the project a film project (short film or documentary)?', '2026-08-28 19:05:47.711758+00'),
	('f8381b5a-5a77-41f0-8b01-ec46897b09f4', 'en', 'Är projektet ett konst- eller kulturprojekt?', 'Is the project an arts or culture project?', '2026-08-28 19:05:47.711758+00'),
	('34ba00ee-5142-47bb-8289-c454e86a06bf', 'en', 'Är projektet ett kulturprojekt?', 'Is the project a culture project?', '2026-08-28 19:05:47.711758+00'),
	('838bee18-b411-446f-b2c6-94bed8d87bdc', 'en', 'Är projektet ett musikprojekt?', 'Is the project a music project?', '2026-08-28 19:05:47.711758+00'),
	('e1e8b87d-eac1-4d6d-90e3-fcb333c380d6', 'en', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Is the project innovative — something you do not already do in regular operations?', '2026-08-28 19:05:47.711758+00'),
	('cf4b0ee9-fc02-4731-8fb0-22b189275559', 'en', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Does the project benefit the community at large (not individuals)?', '2026-08-28 19:05:47.711758+00'),
	('bed47ec0-6350-4bca-94a2-b3ce317277a3', 'en', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Is the journey between home and upper secondary school at least six kilometres?', '2026-08-28 19:05:47.711758+00'),
	('3c375b13-dbdf-4518-991a-3bc4a24d15d4', 'en', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Are the activities professional (not amateur)?', '2026-08-28 19:05:47.711758+00'),
	('c8ebe477-7011-4a0c-bd1f-0e3376f9c7ca', 'en', 'Är verksamheten professionell?', 'Are the activities professional?', '2026-08-28 19:05:47.711758+00'),
	('3179f14c-b01c-466a-9452-bd321f1b5ea1', 'en', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Are the activities performing arts (dance, theatre, musical theatre)?', '2026-08-28 19:05:47.711758+00'),
	('d26284af-0649-4d65-b1b8-656e778ea0fe', 'es', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Apoyo a actividades para clubes deportivos con actividades dirigidas por monitores para niños y jóvenes de 7 a 25 años.', '2026-08-28 19:05:47.717202+00'),
	('30b7636e-a296-4bc5-b2d4-04ef39d93354', 'es', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Suplemento automático a la asignación por hijo (barnbidrag) a partir del segundo hijo.', '2026-08-28 19:05:47.717202+00'),
	('20520b44-aa8a-485c-9117-8c2fa4a8cfb7', 'es', 'Avser ansökan en fysisk investering?', '¿La solicitud se refiere a una inversión física?', '2026-08-28 19:05:47.717202+00'),
	('c752da61-d62f-48b9-a3d6-d2cbbdcac5ff', 'es', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', '¿La solicitud se refiere a un viaje o intercambio internacional?', '2026-08-28 19:05:47.717202+00'),
	('ac60040e-3ff0-4b69-a487-d588315e4de7', 'es', 'Avser ansökan en investering i byggnader eller maskiner?', '¿La solicitud se refiere a una inversión en edificios o maquinaria?', '2026-08-28 19:05:47.717202+00'),
	('ac1371bc-71bc-4464-ad77-ec7549abda46', 'es', 'Avser ansökan en redan utgiven titel?', '¿La solicitud se refiere a un título ya publicado?', '2026-08-28 19:05:47.717202+00'),
	('4dfb4a31-e841-488f-96f7-345b66f6900b', 'es', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', '¿La solicitud se refiere a una empresa agrícola, hortícola o de cría de renos?', '2026-08-28 19:05:47.717202+00'),
	('997d4c94-a9d2-416d-b800-9eba2e0ceaa1', 'es', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', '¿La solicitud se refiere a la compra de literatura para bibliotecas públicas o escolares?', '2026-08-28 19:05:47.717202+00'),
	('0b80f402-c47f-4899-ad47-611ae76b01c1', 'es', 'Avser investeringen jordbruksverksamhet?', '¿La inversión se refiere a una actividad agrícola?', '2026-08-28 19:05:47.717202+00'),
	('6f3b7090-2392-46f3-9145-66823201e843', 'es', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', '¿El proyecto consiste en construir, comprar o renovar un local?', '2026-08-28 19:05:47.717202+00'),
	('8f08261a-fead-453c-b6ae-9054df366bcc', 'es', 'Avser projektet naturvård eller friluftsliv?', '¿El proyecto se refiere a la conservación de la naturaleza o a actividades al aire libre?', '2026-08-28 19:05:47.717202+00'),
	('9f8da6fd-4efc-4e19-8d7f-79d961a0b3c5', 'es', 'Avser projektet skola eller vuxenutbildning?', '¿El proyecto se refiere a la escuela o a la educación de adultos?', '2026-08-28 19:05:47.717202+00'),
	('3439fcff-5b9c-4bf8-a2f1-cb2b09d60a37', 'es', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', '¿Deja usted de trabajar para cuidar o estar cerca de un familiar tan gravemente enfermo que la enfermedad es una amenaza para su vida?', '2026-08-28 19:05:47.717202+00'),
	('180beec5-65f0-449c-a9d7-cdecf7164db9', 'es', 'Bedriver föreningen regelbunden verksamhet i kommunen?', '¿La asociación desarrolla actividades regulares en el municipio?', '2026-08-28 19:05:47.717202+00'),
	('2270fbf7-cdeb-4665-840b-4929f12e1fcd', 'es', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', '¿Considera que su capacidad de trabajo está reducida durante al menos un año por enfermedad o discapacidad?', '2026-08-28 19:05:47.717202+00'),
	('45d9ccce-893c-4c3b-8ba7-4a144917ec0c', 'es', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Apoyo sujeto a comprobación de recursos para quien tiene una pensión baja o nula y necesita ayuda para alcanzar un nivel de vida razonable.', '2026-08-28 19:05:47.717202+00'),
	('c169e12d-2fab-4d56-b771-4a108f3e4682', 'es', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', '¿El menor necesita vivir en la localidad de estudios (alojamiento) porque el trayecto es demasiado largo?', '2026-08-28 19:05:47.717202+00'),
	('bf3c770b-91b5-45b1-b7c1-d1f28b7b65f8', 'es', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', '¿La vivienda necesita adaptarse (p. ej. rampa, abridor de puertas, baño)?', '2026-08-28 19:05:47.717202+00'),
	('e341d122-9369-43dc-93bd-7d2470698f90', 'es', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', '¿Alguno de sus hijos de 8 a 19 años necesita gafas o lentillas?', '2026-08-28 19:05:47.717202+00'),
	('7ee04a0d-835e-4e48-b1fb-f93e358030e9', 'es', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', '¿El otro progenitor no paga nada o paga menos que la pensión alimenticia completa?', '2026-08-28 19:05:47.717202+00'),
	('469535c2-9676-4f06-af28-0fdac159e7a3', 'es', 'Betalar du hyra eller andra boendekostnader?', '¿Paga usted alquiler u otros gastos de vivienda?', '2026-08-28 19:05:47.717202+00'),
	('31ba4f6d-33bc-44fd-99b8-abee8f727192', 'es', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Subvención para adaptar la vivienda en caso de discapacidad — p. ej. rampas, abridores de puertas o adaptación del baño.', '2026-08-28 19:05:47.717202+00'),
	('81f08fbe-b8e0-43ae-a943-f3954e16ebbf', 'es', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Subvenciones para construir, comprar o renovar locales públicos de reunión.', '2026-08-28 19:05:47.717202+00'),
	('1b133dab-1aba-40a3-bb7b-0e1cb3383353', 'es', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Subvención para comprar o adaptar un coche cuando una discapacidad permanente hace muy difícil desplazarse o usar el transporte público.', '2026-08-28 19:05:47.717202+00'),
	('355badaf-f080-47d0-8394-13a8b92bcdeb', 'es', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Subvenciones para viajes e intercambios internacionales de profesionales del sector cultural.', '2026-08-28 19:05:47.717202+00'),
	('1ef50171-a16f-4ede-b995-bf97aeb81df7', 'es', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Subvenciones para intercambios internacionales, viajes y estancias de trabajo de artistas profesionales.', '2026-08-28 19:05:47.717202+00');
INSERT INTO public.kb_translations VALUES
	('c499e857-f765-46fc-91b8-e59e308daff8', 'es', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Beca y préstamo voluntario para estudios de nivel secundario superior o postsecundario.', '2026-08-28 19:05:47.717202+00'),
	('720d98c1-c747-43c6-bf91-00a0c2fc3485', 'es', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Becas y préstamos para estudiar en el extranjero, con préstamos adicionales para p. ej. tasas académicas y viajes.', '2026-08-28 19:05:47.717202+00'),
	('d9fb48cb-6d1b-4ba0-8adb-367fd3e67970', 'es', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Subvención que ayuda a actores suecos a preparar solicitudes para programas de la UE como Horisont Europa.', '2026-08-28 19:05:47.717202+00'),
	('c9a4645a-157a-4d9e-9bd6-a8994fd4da82', 'es', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Subvención para empleadores que contratan a personas con capacidad de trabajo reducida.', '2026-08-28 19:05:47.717202+00'),
	('cfa8f377-b3b7-42da-8002-5808a8b0f51a', 'es', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Subvención para alojamiento y viajes a casa cuando un estudiante de secundaria superior debe vivir en la localidad de estudios por la distancia.', '2026-08-28 19:05:47.717202+00'),
	('cc14ce2f-85da-465c-98fd-dfd395004bc3', 'es', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Subvenciones para el trabajo de organizaciones sin ánimo de lucro por conservar, usar y desarrollar el patrimonio cultural.', '2026-08-28 19:05:47.717202+00'),
	('ca3fff54-fac1-4983-8cd3-df259bb0ec29', 'es', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Subvenciones para proyectos municipales y locales de conservación de la naturaleza, incluidos humedales y actividades al aire libre.', '2026-08-28 19:05:47.717202+00'),
	('3371789e-c0db-4bc3-a9dc-a5c6b8a4128d', 'es', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Subvenciones a municipios para la compra de literatura para bibliotecas públicas y escolares.', '2026-08-28 19:05:47.717202+00'),
	('d803d6be-8002-4775-baeb-c515e96df45c', 'es', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Apoyo a la transición de la industria hacia cero emisiones de gases de efecto invernadero.', '2026-08-28 19:05:47.717202+00'),
	('5ffa2a47-50c2-41a8-8261-03c618436423', 'es', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Subvenciones a titulares de escuelas para el encuentro de los alumnos con la cultura profesional en la escuela obligatoria.', '2026-08-28 19:05:47.717202+00'),
	('ca5b6b03-df6a-4f23-9297-afeeeed9df58', 'es', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Ayuda para lo que su hijo necesita pero la economía familiar no alcanza a cubrir: actividades de ocio, ropa, excursiones escolares, gafas, actividades vacacionales y más.', '2026-08-28 19:05:47.717202+00'),
	('7a372ef1-1e8a-4d9b-98e0-47033c0b1ed8', 'es', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Ayudas de fondos como Världens Barn, Musikhjälpen y Victoriafonden — solicitadas por organizaciones suecas sin ánimo de lucro con 90-konto.', '2026-08-28 19:05:47.717202+00'),
	('65f976dd-8f42-4973-baa6-9911942689b7', 'es', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Ayudas de los fondos de energía hidroeléctrica y eólica para proyectos que desarrollan la comarca.', '2026-08-28 19:05:47.717202+00'),
	('e31c1929-a230-4204-a648-6f948b2c173e', 'es', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Beca sin componente de préstamo para desempleados de 25 a 60 años con estudios previos cortos que necesitan estudiar a nivel de primaria o secundaria.', '2026-08-28 19:05:47.717202+00'),
	('3b2c34e5-45b9-4fc7-9f9e-a2f0aea4c7c0', 'es', 'Bidrar projektet till energiomställningen?', '¿El proyecto contribuye a la transición energética?', '2026-08-28 19:05:47.717202+00'),
	('c825b2ef-4d06-497a-a8ea-28fcd7e496fb', 'es', 'Bor du och barnets andra förälder på skilda håll?', '¿Usted y el otro progenitor del menor viven separados?', '2026-08-28 19:05:47.717202+00'),
	('0d344a9b-18c6-4d0b-acb7-35fede598966', 'es', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Cheques para pequeñas empresas para incorporar competencias externas en internacionalización o digitalización.', '2026-08-28 19:05:47.717202+00'),
	('af961f18-d51b-4498-baba-69fb5832696b', 'es', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', '¿Participa usted en un programa de Arbetsförmedlingen (p. ej. jobb- och utvecklingsgarantin)?', '2026-08-28 19:05:47.717202+00'),
	('d4056983-d40d-466b-8cde-b2777c2f700d', 'es', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Apoyo a posteriori a editoriales por la publicación de literatura de calidad.', '2026-08-28 19:05:47.717202+00'),
	('d78b17ab-6cf4-4cbb-93be-9e72fdf557f0', 'es', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Apoyo económico para quien tiene un permiso de residencia por protección y desea voluntariamente regresar de forma permanente a su país de origen.', '2026-08-28 19:05:47.717202+00'),
	('a7989bb3-64a1-4f7c-8c41-d104c438b7c0', 'es', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Apoyo económico a empleadores que contratan a alguien que ha estado mucho tiempo fuera de la vida laboral.', '2026-08-28 19:05:47.717202+00'),
	('74f303f5-1d2c-434e-a052-6cb44729864b', 'es', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Apoyo económico durante la fase inicial para demandantes de empleo que crean su propia empresa.', '2026-08-28 19:05:47.717202+00'),
	('10798e50-73d0-4c24-95d8-efd62cbe3f97', 'es', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten abre continuamente convocatorias en investigación energética, innovación y eficiencia energética.', '2026-08-28 19:05:47.717202+00'),
	('e5da0d27-ed3d-4ff0-ab7f-2692c69a564f', 'es', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Prestación por ausentarse del trabajo o de los estudios para cuidar de un hijo.', '2026-08-28 19:05:47.717202+00'),
	('f4cf18e5-8230-4a14-8d86-ca267cff1bff', 'es', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Prestación para quien es nuevo en Suecia y participa en el programa de establecimiento de Arbetsförmedlingen; la paga Försäkringskassan.', '2026-08-28 19:05:47.717202+00'),
	('e8209dee-0e0a-4bd3-ba47-fe55ccc36eb4', 'es', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Prestación que cubre parte del gasto de vivienda para jóvenes sin hijos con ingresos bajos.', '2026-08-28 19:05:47.717202+00'),
	('cded569a-9138-41c0-b0b2-295d184b4516', 'es', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Prestación por los gastos adicionales que conlleva una discapacidad permanente — para adultos o para padres de niños con discapacidad.', '2026-08-28 19:05:47.717202+00'),
	('3e0063e8-dbbc-46fe-8b68-2cc8d15363e5', 'es', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Prestación para jóvenes (19–29 años) que no pueden trabajar a tiempo completo durante al menos un año por enfermedad o discapacidad.', '2026-08-28 19:05:47.717202+00'),
	('c510756c-ce3c-403c-81d3-e905890ef9b3', 'es', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Prestación cuando la capacidad de trabajo está reducida de forma permanente — lo que antes se llamaba förtidspension (jubilación anticipada).', '2026-08-28 19:05:47.717202+00'),
	('7eecfec4-2fbc-4801-b0d1-01b8289a45d2', 'es', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Prestación cuando usted deja de trabajar para estar cerca de un familiar gravemente enfermo.', '2026-08-28 19:05:47.717202+00'),
	('6bd6610f-5b7d-4b9f-8c2f-301e7d947784', 'es', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Prestación cuando participa en un programa de política laboral de Arbetsförmedlingen.', '2026-08-28 19:05:47.717202+00'),
	('2bdf29bc-ae03-4bb5-aac7-faa0f46f9b87', 'es', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Prestación cuando no puede trabajar con normalidad por enfermedad.', '2026-08-28 19:05:47.717202+00'),
	('997b6a0d-d103-4912-a74c-241f0617387d', 'es', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Prestación cuando se queda en casa sin ir al trabajo para cuidar de un hijo enfermo.', '2026-08-28 19:05:47.717202+00'),
	('77e94fa2-e3ad-4539-adad-8d989a4196ce', 'es', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Prestación que cubre parte del gasto de vivienda para hogares con hijos e ingresos más bajos.', '2026-08-28 19:05:47.717202+00'),
	('7565a58e-c500-44c0-8a55-a893121e0284', 'es', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Prestación para padres cuyos hijos, por discapacidad, necesitan más cuidado y supervisión que otros niños de la misma edad.', '2026-08-28 19:05:47.717202+00'),
	('0ed98562-be82-42ce-ba7b-5b74dcf17d3d', 'es', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Prestación por desempleo — basada en los ingresos para afiliados, importe básico para los demás.', '2026-08-28 19:05:47.717202+00'),
	('23c70474-9d2e-4736-9142-7e23ceb502bd', 'es', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Una cincuentena de fundaciones de cajas de ahorros conceden ayudas a proyectos locales de deporte, cultura, educación y desarrollo comunitario — en la zona de actividad de la caja.', '2026-08-28 19:05:47.717202+00'),
	('45bdae09-ffab-4fed-939e-86dcc64b4470', 'es', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Apoyo a proyectos financiado por la UE que se solicita en su zona Leader local — para asociaciones, empresas y municipios que desarrollan el medio rural.', '2026-08-28 19:05:47.717202+00'),
	('708077cd-37c7-4e68-8fa4-021989aa0b20', 'es', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Apoyo financiado por la UE para demandantes de empleo que aceptan un trabajo en otro país UE/EEE: compensación por viaje de entrevista, gastos de mudanza y curso de idiomas.', '2026-08-28 19:05:47.717202+00'),
	('05234ead-f7cf-4668-b98c-16c754fcd50d', 'es', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Fondos del Fondo Social Europeo para proyectos que refuerzan las competencias, la transición y la inclusión en el mercado laboral.', '2026-08-28 19:05:47.717202+00'),
	('c294bffa-4454-43b9-aa64-291273181051', 'es', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Apoyo de la UE para intercambios de grupos de jóvenes de 13 a 30 años, de 5 a 21 días sin contar los días de viaje.', '2026-08-28 19:05:47.717202+00'),
	('13bfe21d-a40d-4f4a-8e9f-cd0c8d6ca367', 'es', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Apoyo de la UE para proyectos de cooperación de organizaciones culturales con socios en varios países europeos.', '2026-08-28 19:05:47.717202+00'),
	('edde3839-6493-4fc7-8501-e56548c66124', 'es', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Apoyo de la UE para organizaciones que reciben o envían jóvenes voluntarios de 18 a 30 años.', '2026-08-28 19:05:47.717202+00'),
	('9893f046-fe3c-4973-a30b-f80d662f51f3', 'es', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Apoyo de la UE para la movilidad de personal y alumnado en la escuela y la educación de adultos.', '2026-08-28 19:05:47.717202+00'),
	('1432ae35-2e21-46f2-9818-6cc5c3dbb89f', 'es', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Apoyo de la UE con importes a tanto alzado para los primeros proyectos europeos de cooperación de organizaciones pequeñas.', '2026-08-28 19:05:47.717202+00'),
	('a5092576-c087-47ac-b1a7-cc1fa0efe7f1', 'es', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Financiación para empresas jóvenes que desarrollan productos o servicios innovadores con potencial internacional.', '2026-08-28 19:05:47.717202+00'),
	('ab067c5b-78f5-49fe-bcca-8405447cf8fb', 'es', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', '¿Hay una caja de ahorros (y por tanto una fundación de caja de ahorros) donde desarrollan su actividad?', '2026-08-28 19:05:47.717202+00'),
	('a24fa147-8e74-4ed5-8b76-fcafe279d1b8', 'es', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Subvenciones de funcionamiento plurianuales para grupos profesionales independientes de danza, teatro y teatro musical.', '2026-08-28 19:05:47.717202+00'),
	('d84100b9-a8f7-4f62-b850-bfbce6a971b5', 'es', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Ayudas a la investigación en los ámbitos de Forte: salud, vida laboral y bienestar. Las solicitan investigadores doctorados de universidades suecas.', '2026-08-28 19:05:47.717202+00'),
	('569f66b7-4dc1-403b-8a06-252c31a3ee56', 'es', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Fondos de investigación para investigación básica libre en todos los campos científicos.', '2026-08-28 19:05:47.717202+00');
INSERT INTO public.kb_translations VALUES
	('8c903b1d-4e8b-4115-9016-0428dc522144', 'es', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Fondos de investigación en medio ambiente, ciencias agrarias y urbanismo.', '2026-08-28 19:05:47.717202+00'),
	('cb0e3f49-ca34-42c4-9271-dcf0deee4d9a', 'es', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', '¿Está pensando en mudarse al extranjero (por trabajo, estudios o retorno)?', '2026-08-28 19:05:47.717202+00'),
	('7f8115b1-04c3-454e-a81b-fef3851ec857', 'es', 'Genomförs insatserna av professionella kulturaktörer?', '¿Las actividades las realizan agentes culturales profesionales?', '2026-08-28 19:05:47.717202+00'),
	('79d78b2e-716d-421a-9afa-e87e3b5dbb93', 'es', 'Genomförs projektet på landsbygden eller i en mindre tätort?', '¿El proyecto se realiza en el medio rural o en una localidad pequeña?', '2026-08-28 19:05:47.717202+00'),
	('a9cd59e4-6ba2-4a77-abaf-8ea3d2dba5c2', 'es', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Protección básica para quien ha tenido pocos o ningún ingreso laboral durante su vida.', '2026-08-28 19:05:47.717202+00'),
	('81cd0937-95d9-4e9c-9e15-e4437d148b08', 'es', 'Går något av dina barn i grundskolan?', '¿Alguno de sus hijos va a la escuela obligatoria?', '2026-08-28 19:05:47.717202+00'),
	('a23888d8-0edd-4544-bced-21f0b950444c', 'es', 'Går något av dina barn på gymnasiet?', '¿Alguno de sus hijos va al instituto (gymnasiet)?', '2026-08-28 19:05:47.717202+00'),
	('e65ece16-a0e0-4645-b840-fde6744c423b', 'es', 'Gäller anställningen en person med nedsatt arbetsförmåga?', '¿La contratación se refiere a una persona con capacidad de trabajo reducida?', '2026-08-28 19:05:47.717202+00'),
	('ae87d208-d1aa-4ffe-b62e-675eac42bbc4', 'es', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', '¿La contratación se refiere a alguien que lleva mucho tiempo en paro o es nuevo en Suecia?', '2026-08-28 19:05:47.717202+00'),
	('49c020e6-77ea-4273-9154-a40cbb91e885', 'es', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', '¿El proyecto trata de conservar o hacer accesible el patrimonio cultural?', '2026-08-28 19:05:47.717202+00'),
	('99a86d43-5cfd-4f70-87e1-bd772a06d4e2', 'es', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', '¿El proyecto trata de energía, eficiencia energética o innovación energética?', '2026-08-28 19:05:47.717202+00'),
	('b6429417-e063-458b-ac40-1057a266c083', 'es', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', '¿El proyecto trata de salud, vida laboral o bienestar?', '2026-08-28 19:05:47.717202+00'),
	('a2055a1e-a5e9-46be-9769-aae50b60fe3d', 'es', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', '¿El proyecto trata de desarrollo de competencias o medidas de empleo?', '2026-08-28 19:05:47.717202+00'),
	('0da66abd-531b-4f1d-9fb8-dba389fc1c2e', 'es', 'Handlar projektet om miljö- eller klimatåtgärder?', '¿El proyecto trata de medidas medioambientales o climáticas?', '2026-08-28 19:05:47.717202+00'),
	('28f51d5b-aea3-42cf-916f-c81ce07e8b38', 'es', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', '¿El menor tiene un camino a la escuela largo, peligroso por el tráfico o difícil por otros motivos?', '2026-08-28 19:05:47.717202+00'),
	('772f889b-49bd-4bde-9aa7-7a7b70927949', 'es', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', '¿Ha trabajado al menos 16 horas semanales durante un total de al menos 8 años?', '2026-08-28 19:05:47.717202+00'),
	('6f4dc9d1-7e87-4c8c-84f3-9756fd5d830c', 'es', 'Har du barn som bor hos dig, helt eller växelvis?', '¿Tiene hijos que viven con usted, todo el tiempo o en alternancia?', '2026-08-28 19:05:47.717202+00'),
	('b484b764-836d-445a-bc3b-c2b0bf78f290', 'es', 'Har du barn som bor hos dig?', '¿Tiene hijos que viven con usted?', '2026-08-28 19:05:47.717202+00'),
	('8b27635e-d823-48f1-b679-54167f319387', 'es', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', '¿Usted o su hijo tienen una discapacidad que se espera dure al menos un año?', '2026-08-28 19:05:47.717202+00'),
	('92d475f8-d340-4356-92ab-9ece8027b0a4', 'es', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', '¿Usted o alguien del hogar tiene una discapacidad permanente que afecta a la vivienda?', '2026-08-28 19:05:47.717202+00'),
	('13ec9afe-15a2-48f6-b05d-77c320349e19', 'es', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', '¿Usted o un familiar cercano tiene una discapacidad o una enfermedad prolongada o grave?', '2026-08-28 19:05:47.717202+00'),
	('41b26ff6-f4f3-4d6b-b766-3bbd6fa77c5e', 'es', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', '¿Tiene una enfermedad o lesión que ahora mismo reduce su capacidad de trabajo?', '2026-08-28 19:05:47.717202+00'),
	('38138ad1-7a3a-4045-af85-a65d6772b645', 'es', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', '¿Alguna vez le ha costado pagar una excursión escolar, un viaje de clase o una actividad de ocio en la que se espera que participe su hijo?', '2026-08-28 19:05:47.717202+00'),
	('daedd626-ad62-4398-bc42-2aa755f4937e', 'es', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', '¿Ha obtenido en los últimos años un permiso de residencia en Suecia, p. ej. como persona necesitada de protección o como familiar?', '2026-08-28 19:05:47.717202+00'),
	('97bc7480-218d-4221-aa42-2244e747ce7b', 'es', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', '¿Tiene permiso de residencia en Suecia como refugiado o persona necesitada de protección (o es familiar cercano de alguien que lo tiene)?', '2026-08-28 19:05:47.717202+00'),
	('d5acbc6a-42c2-4715-8141-95e7c8d9040e', 'es', 'Har du uppnått riktåldern för pension (67 år 2026)?', '¿Ha alcanzado la edad de referencia de jubilación (67 años en 2026)?', '2026-08-28 19:05:47.717202+00'),
	('a4708216-260b-4e93-ab9b-9e78b4e4ec92', 'es', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', '¿Su organización tiene un OID (Organisation ID) registrado en el Organisation Registration System de la UE?', '2026-08-28 19:05:47.717202+00'),
	('9cf3bf14-d983-4900-9fd0-db7be132a3a5', 'es', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', '¿La discapacidad ha supuesto gastos adicionales — p. ej. ayudas técnicas, viajes, dieta especial o desgaste?', '2026-08-28 19:05:47.717202+00'),
	('123ceb03-694b-4162-99a4-999a64ac73fc', 'es', 'Har föreningen antagna stadgar och en vald styrelse?', '¿La asociación tiene estatutos aprobados y una junta directiva elegida?', '2026-08-28 19:05:47.717202+00'),
	('9a9c6c81-c1ae-47b2-8e5f-9b35c98265d1', 'es', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', '¿La asociación tiene una estructura democrática (estatutos, asamblea anual, junta)?', '2026-08-28 19:05:47.717202+00'),
	('49add499-37ae-47f0-b118-eb4fac1d4be9', 'es', 'Har föreningen regelbunden verksamhet för barn eller unga?', '¿La asociación desarrolla actividades regulares para niños o jóvenes?', '2026-08-28 19:05:47.717202+00'),
	('3f140334-054c-417e-9e03-1b69b433d865', 'es', 'Har företaget mellan cirka 2 och 49 anställda?', '¿La empresa tiene entre aproximadamente 2 y 49 empleados?', '2026-08-28 19:05:47.717202+00'),
	('a6bb6ad1-ae68-4f81-a78b-e7fdc65b5023', 'es', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', '¿Al hogar le cuesta cubrir los gastos de comida, vivienda y lo más necesario?', '2026-08-28 19:05:47.717202+00'),
	('49be5e4b-4c81-4fbb-be22-dde09ee32796', 'es', 'Har lösningen internationell potential?', '¿La solución tiene potencial internacional?', '2026-08-28 19:05:47.717202+00'),
	('2bdf0870-b4a9-4b02-8e17-25d04efb464f', 'es', 'Har ni en partnergrupp i ett annat land?', '¿Tienen un grupo socio en otro país?', '2026-08-28 19:05:47.717202+00'),
	('8705beb8-801f-436c-b8cf-76038374677a', 'es', 'Har ni en partnerorganisation i ett annat europeiskt land?', '¿Tienen una organización socia en otro país europeo?', '2026-08-28 19:05:47.717202+00'),
	('677a5264-d716-4c64-867f-a03c14f31cb4', 'es', 'Har ni partner i minst tre olika europeiska länder?', '¿Tienen socios en al menos tres países europeos distintos?', '2026-08-28 19:05:47.717202+00'),
	('7155fb38-0f22-4b8f-a912-fdb9fb693760', 'es', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', '¿Tienen su sede o actividad principal en la región donde solicitan?', '2026-08-28 19:05:47.717202+00'),
	('64b27bf0-87e3-416a-b00c-7f8b546fe2fc', 'es', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', '¿Alguno de sus hijos tiene una discapacidad por la que necesita más cuidado o supervisión que otros niños de la misma edad?', '2026-08-28 19:05:47.717202+00'),
	('3c9f938f-8344-476c-8514-89043bea7496', 'es', 'Har organisationen en demokratisk uppbyggnad?', '¿La organización tiene una estructura democrática?', '2026-08-28 19:05:47.717202+00'),
	('2b936323-7247-4865-883e-b7238c1635fc', 'es', 'Har organisationen en Quality Label (kvalitetsmärkning)?', '¿La organización tiene una Quality Label (sello de calidad)?', '2026-08-28 19:05:47.717202+00'),
	('edc45d69-6131-4436-93ab-77d540b5651d', 'es', 'Har organisationen ett 90-konto?', '¿La organización tiene un 90-konto?', '2026-08-28 19:05:47.717202+00'),
	('4cd08da0-5cc2-4a0f-9f95-c826488ca3d2', 'es', 'Har organisationen ett OID (Organisation ID)?', '¿La organización tiene un OID (Organisation ID)?', '2026-08-28 19:05:47.717202+00'),
	('3509a723-7c49-4efc-b030-877b74e1077a', 'es', 'Har organisationen ett OID?', '¿La organización tiene un OID?', '2026-08-28 19:05:47.717202+00'),
	('bf89aa3f-f158-45fd-a35e-4d04985bb7d7', 'es', 'Har organisationen medlemsföreningar i flera län?', '¿La organización tiene asociaciones miembro en varias provincias?', '2026-08-28 19:05:47.717202+00'),
	('9811e4e0-6ef6-487b-ac76-919b7f5e34cc', 'es', 'Har organisationen ordnad ekonomi och demokratisk struktur?', '¿La organización tiene una economía ordenada y una estructura democrática?', '2026-08-28 19:05:47.717202+00'),
	('6161a1e7-b439-49d6-94d5-2d72e7a27a49', 'es', 'Har projektet en partner i ett annat land?', '¿El proyecto tiene un socio en otro país?', '2026-08-28 19:05:47.717202+00'),
	('bf343141-9de1-44d7-9de9-4bc461f8c3c2', 'es', 'Har projektledaren doktorsexamen?', '¿La persona que lidera el proyecto tiene un doctorado?', '2026-08-28 19:05:47.717202+00'),
	('de1727b0-fdfe-425d-80c9-1cc154104c15', 'es', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'El municipio de residencia debe garantizar los desplazamientos diarios entre la vivienda y el instituto cuando el trayecto es de al menos seis kilómetros (p. ej. abono de autobús).', '2026-08-28 19:05:47.717202+00'),
	('e19064a6-246b-431e-8918-a6723d9b0131', 'es', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', '¿Está consiguiendo o equipando su primera vivienda propia en Suecia?', '2026-08-28 19:05:47.717202+00');
INSERT INTO public.kb_translations VALUES
	('12855f08-038b-4538-9454-052dfb319f40', 'es', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', '¿El proyecto incluye un viaje o intercambio internacional?', '2026-08-28 19:05:47.717202+00'),
	('4282a8d9-7068-485a-b865-6fa36cddc606', 'es', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Apoyo a la inversión para empresas en zonas de ayuda, para edificios, maquinaria y formación.', '2026-08-28 19:05:47.717202+00'),
	('cb584c43-b508-4654-b0d8-c47b5d922021', 'es', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Apoyo a inversiones en medidas que reducen las emisiones de gases de efecto invernadero.', '2026-08-28 19:05:47.717202+00'),
	('6b684491-9041-4df9-b18c-3d645e8b5a73', 'es', 'Kan projektets miljönytta mätas?', '¿Se puede medir el beneficio medioambiental del proyecto?', '2026-08-28 19:05:47.717202+00'),
	('1856fc22-7535-423d-8a70-0b12df280cca', 'es', 'Kan åtgärdens utsläppsminskning beräknas?', '¿Se puede calcular la reducción de emisiones de la medida?', '2026-08-28 19:05:47.717202+00'),
	('222d146b-db9b-478d-9eaf-b219e3189a2e', 'es', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', '¿La organización puede adelantar los gastos hasta que se abone la ayuda?', '2026-08-28 19:05:47.717202+00'),
	('60f450a5-145b-4643-b159-7137826067e2', 'es', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', '¿Las experiencias se utilizarán en su actividad en Suecia?', '2026-08-28 19:05:47.717202+00'),
	('c7b18c71-c032-4a77-b4cc-9f20c6ef4a74', 'es', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', '¿La inversión comenzará solo después de presentar la solicitud?', '2026-08-28 19:05:47.717202+00'),
	('bac32322-cb8c-4179-8f78-59b86cb32f41', 'es', 'Kommer projektet människor i ert närområde till del?', '¿El proyecto beneficia a las personas de su entorno?', '2026-08-28 19:05:47.717202+00'),
	('90eb6d1e-9864-471f-9a1b-002ec3487743', 'es', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'La última red de seguridad económica del municipio cuando los ingresos no alcanzan para lo más necesario.', '2026-08-28 19:05:47.717202+00'),
	('9aedf4cb-4129-42d6-80b3-fa3c5233a8fa', 'es', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Los apoyos propios de los municipios al tejido asociativo local: ayuda por actividad, ayuda para locales, ayuda inicial y más.', '2026-08-28 19:05:47.717202+00'),
	('c3db042b-006d-4888-92e2-7a623d5d0c0b', 'es', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Apoyo a proyectos de arte y cultura con dimensión nórdica y cooperación transfronteriza.', '2026-08-28 19:05:47.717202+00'),
	('197eaf33-c542-41c8-ace6-a82d55763aa9', 'es', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Transporte escolar gratuito para alumnos de la escuela obligatoria por distancia larga, camino peligroso o discapacidad — un derecho según la ley escolar.', '2026-08-28 19:05:47.717202+00'),
	('6194a4d2-8438-448d-bc32-e3ad7023f790', 'es', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Ayuda legal para gafas o lentillas para niños y jóvenes; los importes y trámites varían por región — compruebe el nivel de su región.', '2026-08-28 19:05:47.717202+00'),
	('8b07d550-98d0-48aa-83ad-eb8145fd60a4', 'es', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', '¿El proyecto está en una comarca afectada por la energía hidroeléctrica o eólica?', '2026-08-28 19:05:47.717202+00'),
	('c834fbf9-d181-437f-949e-ca2f9d5b1060', 'es', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', '¿El proyecto está dentro de medio ambiente, ciencias agrarias o urbanismo?', '2026-08-28 19:05:47.717202+00'),
	('1c6a2e8d-18a2-413a-b2e7-de8db7b8a7b4', 'es', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', '¿El lugar de actividad está en la zona de ayuda A o B (gran parte de Norrland y el interior de Svealand)?', '2026-08-28 19:05:47.717202+00'),
	('08164fc5-7884-4a86-b9f3-0d8c53c84011', 'es', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Préstamo para comprar lo más necesario para un primer hogar en Suecia — muebles, utensilios y otro equipamiento básico.', '2026-08-28 19:05:47.717202+00'),
	('9b3de462-ceb0-4633-934c-e54eec58f420', 'es', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', '¿El proyecto reduce las emisiones de proceso de la industria o crea emisiones negativas?', '2026-08-28 19:05:47.717202+00'),
	('0d7ea573-70c7-4924-89bc-217b55bf36ce', 'es', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Asignación mensual para niños que viven en Suecia, desde el nacimiento hasta los 16 años.', '2026-08-28 19:05:47.717202+00'),
	('ffe6c776-e25c-4a86-a3c9-0e6ae7552362', 'es', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket ofrece ayudas a organizaciones, empresas, asociaciones, sector público y particulares en el ámbito medioambiental.', '2026-08-28 19:05:47.717202+00'),
	('7ebcf6f2-c2b2-4c3c-9715-ef003acdf998', 'es', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', '¿Planea regresar voluntariamente y de forma permanente a su país de origen?', '2026-08-28 19:05:47.717202+00'),
	('7309371c-2533-43e7-a8ca-7938a14e5d79', 'es', 'Planerar du att starta eget företag?', '¿Planea crear su propia empresa?', '2026-08-28 19:05:47.717202+00'),
	('e9421a14-2f7c-4742-9155-71a634b66f87', 'es', 'Planerar du att studera utomlands?', '¿Planea estudiar en el extranjero?', '2026-08-28 19:05:47.717202+00'),
	('5cd7dd7a-f4d3-4e28-a138-d47d4a88346f', 'es', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', '¿Planea estudios que refuercen su posición en el mercado laboral?', '2026-08-28 19:05:47.717202+00'),
	('8bfc2777-7327-484f-9103-9709e14660b4', 'es', 'Planerar ni att anställa?', '¿Planean contratar?', '2026-08-28 19:05:47.717202+00'),
	('cb1da945-fff5-453a-aeb3-8ab251564e54', 'es', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', '¿Planean solicitar un programa de la UE (p. ej. Horisont Europa)?', '2026-08-28 19:05:47.717202+00'),
	('26bcea20-85f7-4e94-a0fb-476f80e0bd70', 'es', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Apoyo a la producción y el desarrollo de cortometrajes y documentales.', '2026-08-28 19:05:47.717202+00'),
	('267f86c4-3146-40af-97d4-bc06c9de7025', 'es', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Ayudas a proyectos de la escena musical independiente para conciertos, producción y desarrollo.', '2026-08-28 19:05:47.717202+00'),
	('c7f70bc2-cf15-492a-bb4b-9c78554e5989', 'es', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Ayudas a proyectos de organizaciones sin ánimo de lucro que trabajan con y para niños y jóvenes.', '2026-08-28 19:05:47.717202+00'),
	('f2819684-ab82-4e0d-ab01-f6fa79565849', 'es', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', '¿El proyecto explora nuevas expresiones, métodos o colaboraciones artísticas?', '2026-08-28 19:05:47.717202+00'),
	('9f890fe3-b858-4666-a6ee-7f4e317d69a3', 'es', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', '¿El intercambio dura de 5 a 21 días (sin contar los días de viaje)?', '2026-08-28 19:05:47.717202+00'),
	('9f875680-2fd5-4554-a0f3-f7362d183d82', 'es', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Los apoyos propios de las regiones a proyectos y actividades culturales, junto a las ayudas nacionales de Kulturrådet.', '2026-08-28 19:05:47.717202+00'),
	('a6456c9c-d087-48b6-8ba2-dd50552bd5d5', 'es', 'Riktar sig projektet till barn eller unga?', '¿El proyecto se dirige a niños o jóvenes?', '2026-08-28 19:05:47.717202+00'),
	('d3f77ec0-5633-46c4-84e5-9a5b6a5d5bea', 'es', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', '¿El proyecto se dirige a niños, jóvenes, mayores o personas con discapacidad?', '2026-08-28 19:05:47.717202+00'),
	('85267def-5a5f-4837-a39c-2c7b85da9615', 'es', 'Riktar sig verksamheten till barn och unga (7–25 år)?', '¿La actividad se dirige a niños y jóvenes (7–25 años)?', '2026-08-28 19:05:47.717202+00'),
	('89834e5d-b2d7-4f0c-a393-4d2871315cc0', 'es', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', '¿Carece de ahorros o bienes que puedan cubrir los gastos?', '2026-08-28 19:05:47.717202+00'),
	('9cf3a67d-8d32-4254-a2af-eb053d1cb556', 'es', 'Samarbetar ni med partner i minst två andra nordiska länder?', '¿Colaboran con socios en al menos otros dos países nórdicos?', '2026-08-28 19:05:47.717202+00'),
	('35a1debc-4cee-40a1-ad08-4c0474c4e710', 'es', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', '¿Van a incorporar competencias externas para una acción de desarrollo?', '2026-08-28 19:05:47.717202+00'),
	('17bd3be2-5b93-4876-bd0b-b6e182d57565', 'es', 'Sker mobiliteten till ett annat europeiskt land?', '¿La movilidad es hacia otro país europeo?', '2026-08-28 19:05:47.717202+00'),
	('0e9a226d-05d8-4147-81c7-c54789435b67', 'es', 'Startar du eller tar du över företaget för första gången?', '¿Crea o asume la empresa por primera vez?', '2026-08-28 19:05:47.717202+00'),
	('97cc8dae-1591-4fb3-89b8-2c49b3856caf', 'es', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Ayuda inicial para quien tiene 40 años o menos y crea o asume una empresa agrícola.', '2026-08-28 19:05:47.717202+00'),
	('9bab9e74-9fe8-463e-acd0-db7d274afa8c', 'es', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Beca que permite a artistas profesionales concentrarse en su trabajo artístico.', '2026-08-28 19:05:47.717202+00'),
	('2ccccd37-6e2a-43b4-a4fe-f223312b0d9d', 'es', 'Studerar du, eller planerar du att börja studera?', '¿Estudia, o planea empezar a estudiar?', '2026-08-28 19:05:47.717202+00'),
	('86c365f3-b13c-49a5-87a8-f4b855efe4fb', 'es', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Apoyo al estudio para adultos en activo que quieren formarse para reforzar su posición en el mercado laboral.', '2026-08-28 19:05:47.717202+00'),
	('c616f549-c111-4805-929a-383bdb79fb2b', 'es', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Apoyo a inversiones que aumentan la competitividad o reducen el impacto ambiental en empresas agrícolas.', '2026-08-28 19:05:47.717202+00'),
	('da68a76f-135d-41a0-b0d7-384024bd148c', 'es', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Apoyo cuando un hijo vive con usted y el otro progenitor no paga la pensión alimenticia.', '2026-08-28 19:05:47.717202+00'),
	('fd158ff8-33b0-471a-8c07-0b72db1c2ba4', 'es', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Apoyo a proyectos de organizaciones sin ánimo de lucro por las personas, el medio ambiente y un mundo mejor.', '2026-08-28 19:05:47.717202+00'),
	('1693cf0b-d997-4a71-9ce1-2a85aecd9c63', 'es', 'Är projektet till nytta för bygden i stort (inte enskilda)?', '¿El proyecto beneficia a la comarca en su conjunto (no a particulares)?', '2026-08-28 19:05:47.720879+00'),
	('676864b9-c30a-450c-8ea8-5b3977127068', 'es', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Apoyo a proyectos culturales innovadores que exploran nuevas expresiones, métodos o colaboraciones artísticas.', '2026-08-28 19:05:47.717202+00');
INSERT INTO public.kb_translations VALUES
	('a64e6eac-b15f-46f0-bd27-e4e16a142d28', 'es', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Apoyo a proyectos innovadores para niños, jóvenes, mayores y personas con discapacidad.', '2026-08-28 19:05:47.717202+00'),
	('74065dca-7741-4ba1-b155-928764f2f614', 'es', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Apoyo a proyectos de cooperación en la escena musical independiente.', '2026-08-28 19:05:47.717202+00'),
	('703a09a5-07dd-4c31-b0df-ea0a9a61d291', 'es', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Apoyo a proyectos de cooperación en cultura y medios que refuerzan la democracia y la libertad de expresión a nivel internacional.', '2026-08-28 19:05:47.717202+00'),
	('3dc0b737-f2db-4b3a-bf04-89d259cfdc20', 'es', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', '¿El proyecto busca reforzar la democracia, la igualdad o la libertad de expresión?', '2026-08-28 19:05:47.717202+00'),
	('bcca1755-b9e3-451a-b939-4a928d255141', 'es', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', '¿Busca trabajo, o ha recibido una oferta de trabajo, en otro país de la UE o del EEE?', '2026-08-28 19:05:47.717202+00'),
	('8969f055-52bc-47ee-89bd-75701df7f8f6', 'es', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Tope de lo que debe pagar en tasas sanitarias durante un periodo de doce meses — después, frikort (tarjeta gratuita).', '2026-08-28 19:05:47.717202+00'),
	('2c9e48f1-28dc-4d03-978a-0831f14f31e6', 'es', 'Tar du ut hel allmän pension?', '¿Cobra la pensión pública completa?', '2026-08-28 19:05:47.717202+00'),
	('5bb00a9d-2efb-4f1f-bb33-355cce10ee0f', 'es', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Suplemento que cubre parte del gasto de vivienda para quien tiene pensión e ingresos bajos.', '2026-08-28 19:05:47.717202+00'),
	('15555a76-229a-4e6e-a75b-21856e22996d', 'es', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Subvención anual de organización para organizaciones nacionales de infancia y juventud.', '2026-08-28 19:05:47.717202+00'),
	('8bb0955c-de2f-4b22-84cd-9ee4f3840a1d', 'es', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Saldo anual que se descuenta directamente en el dentista o el higienista dental.', '2026-08-28 19:05:47.717202+00'),
	('803a28f3-6fc3-4d77-8cce-4f6d7aefd2aa', 'es', 'Är bolaget yngre än cirka 5 år?', '¿La empresa tiene menos de unos 5 años?', '2026-08-28 19:05:47.717202+00'),
	('3cd20ee1-ac17-4ec7-8aba-fff48d52c8c2', 'es', 'Är deltagarna i utbytet mellan 13 och 30 år?', '¿Los participantes del intercambio tienen entre 13 y 30 años?', '2026-08-28 19:05:47.717202+00'),
	('bbfb317c-762a-4f97-aad8-766d28ae5fcf', 'es', 'Är det här ert första EU-projekt?', '¿Es este su primer proyecto de la UE?', '2026-08-28 19:05:47.717202+00'),
	('f804de50-cde9-4dde-bacf-d65f1daa25c2', 'es', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', '¿Le resulta muy difícil (a usted o a su hijo) desplazarse por su cuenta o viajar en autobús y tren?', '2026-08-28 19:05:47.717202+00'),
	('1730502e-c965-42e0-9785-a37d3c117966', 'es', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', '¿Sus ingresos son inferiores a unas 25 000 kr al mes antes de impuestos?', '2026-08-28 19:05:47.717202+00'),
	('ff092925-ae98-47b1-8ac5-191d20f2ab2d', 'es', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', '¿Su última formación terminada es la escuela obligatoria, o un instituto que no completó?', '2026-08-28 19:05:47.717202+00'),
	('e988f7e6-126d-45e1-994c-7c814fe72c3c', 'es', 'Är du 40 år eller yngre?', '¿Tiene 40 años o menos?', '2026-08-28 19:05:47.717202+00'),
	('8a88ff03-0308-4bce-925d-e2aa273f1fb5', 'es', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', '¿Está inscrito como demandante de empleo en Arbetsförmedlingen?', '2026-08-28 19:05:47.717202+00'),
	('00a63689-d2f6-4919-a771-0e3a70d0ece4', 'es', 'Är du mellan 18 och 28 år?', '¿Tiene entre 18 y 28 años?', '2026-08-28 19:05:47.717202+00'),
	('6a41e6f0-9368-4ea8-8d85-02f0d948fad3', 'es', 'Är du mellan 19 och 29 år?', '¿Tiene entre 19 y 29 años?', '2026-08-28 19:05:47.717202+00'),
	('3641fe3d-8989-43bf-b9df-42e236cb1b45', 'es', 'Är du mellan 25 och 60 år?', '¿Tiene entre 25 y 60 años?', '2026-08-28 19:05:47.717202+00'),
	('c1e632e3-88e1-4670-a5a9-6ed078b2e5c8', 'es', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', '¿Trabaja profesionalmente en el sector cultural (p. ej. danza, música, artes escénicas)?', '2026-08-28 19:05:47.717202+00'),
	('bb9836df-f937-4d76-9b83-d40d404327fa', 'es', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', '¿Es artista profesional (no aficionado ni en formación básica)?', '2026-08-28 19:05:47.717202+00'),
	('95d8af1c-f2fd-4d10-a3a5-89a8ddb2b67f', 'es', 'Är du yrkesverksam konstnär?', '¿Es artista profesional?', '2026-08-28 19:05:47.717202+00'),
	('2696f451-8b3e-4695-9d64-7b5c5ed36a53', 'es', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', '¿Su solución es sustancialmente innovadora en comparación con lo que ya existe?', '2026-08-28 19:05:47.720879+00'),
	('39a079f2-7e03-446a-9cae-1e0fdf282be3', 'es', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', '¿El club está afiliado a una federación deportiva especializada dentro de Riksidrottsförbundet?', '2026-08-28 19:05:47.720879+00'),
	('c522c100-c00b-405c-a9da-4a53efcfee1f', 'es', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', '¿Los ingresos del hogar son bajos en relación con el gasto de vivienda?', '2026-08-28 19:05:47.720879+00'),
	('aa70cf07-f1dd-4eeb-85fb-131a43533168', 'es', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', '¿Los ingresos conjuntos del hogar son inferiores a unas 25 000 kr al mes antes de impuestos?', '2026-08-28 19:05:47.720879+00'),
	('4ac43489-76b0-4725-9d09-a687b2eeb20c', 'es', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', '¿La acción es un proyecto delimitado (no la actividad ordinaria)?', '2026-08-28 19:05:47.720879+00'),
	('f3bb42ac-c7bb-47e9-8b33-3293a5265220', 'es', 'Är lokalen öppen för alla — inte bara egna medlemmar?', '¿El local está abierto a todos — no solo a los propios socios?', '2026-08-28 19:05:47.720879+00'),
	('270d2c54-5c22-4935-8912-32abc0f2c1aa', 'es', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', '¿Al menos el 60 % de los miembros tienen entre 6 y 25 años?', '2026-08-28 19:05:47.720879+00'),
	('bc363b14-cde0-463b-90a2-ef7996e5d5cf', 'es', 'Är minst 60 % av medlemmarna under 26 år?', '¿Al menos el 60 % de los miembros tienen menos de 26 años?', '2026-08-28 19:05:47.720879+00'),
	('b3afd0de-4333-4c42-82b5-047157e9315a', 'es', 'Är målgruppen delaktig i planering och genomförande?', '¿El grupo destinatario participa en la planificación y la ejecución?', '2026-08-28 19:05:47.720879+00'),
	('adabb0fa-82f1-4610-98d9-bde890760286', 'es', 'Är ni ett förlag med professionell utgivning?', '¿Son una editorial con publicación profesional?', '2026-08-28 19:05:47.720879+00'),
	('7becfe90-c01d-42cf-8ced-a46bc99f9a02', 'es', 'Är ni huvudman för förskoleklass eller grundskola?', '¿Son titulares de una clase de preescolar o de una escuela obligatoria?', '2026-08-28 19:05:47.720879+00'),
	('016cbffa-bff8-4d61-8f5a-8d55a7c60325', 'es', 'Är organisationen registrerad i EU:s deltagarregister?', '¿La organización está registrada en el registro de participantes de la UE?', '2026-08-28 19:05:47.720879+00'),
	('7b457d8e-7b2a-4eef-9ab3-20d09853e153', 'es', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', '¿El proyecto es un proyecto de cine (cortometraje o documental)?', '2026-08-28 19:05:47.720879+00'),
	('d672fa69-772d-4f6f-831e-3773f52887ef', 'es', 'Är projektet ett konst- eller kulturprojekt?', '¿El proyecto es un proyecto de arte o cultura?', '2026-08-28 19:05:47.720879+00'),
	('d9963331-ea19-4114-81cd-8d02324b0136', 'es', 'Är projektet ett kulturprojekt?', '¿El proyecto es un proyecto cultural?', '2026-08-28 19:05:47.720879+00'),
	('ee436808-465d-4305-99ed-4d07ca4a77f7', 'es', 'Är projektet ett musikprojekt?', '¿El proyecto es un proyecto musical?', '2026-08-28 19:05:47.720879+00'),
	('00b3f45a-db00-4789-813c-6127aa00e04b', 'es', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', '¿El proyecto es innovador — algo que no hacen ya en su actividad ordinaria?', '2026-08-28 19:05:47.720879+00'),
	('62ae2bf2-ba6e-4106-93a9-05bf05209c76', 'es', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', '¿El trayecto entre la vivienda y el instituto es de al menos seis kilómetros?', '2026-08-28 19:05:47.720879+00'),
	('cd3bef33-e8d5-45eb-b530-25ef54fdede2', 'es', 'Är verksamheten professionell (inte amatörverksamhet)?', '¿La actividad es profesional (no de aficionados)?', '2026-08-28 19:05:47.720879+00'),
	('032b316a-6413-42c6-8bf0-1933fb93de73', 'es', 'Är verksamheten professionell?', '¿La actividad es profesional?', '2026-08-28 19:05:47.720879+00'),
	('8d17c947-77b8-45e5-88fe-e753a8a59a65', 'es', 'Är verksamheten scenkonst (dans, teater, musikteater)?', '¿La actividad es de artes escénicas (danza, teatro, teatro musical)?', '2026-08-28 19:05:47.720879+00'),
	('58bce9e0-0625-4b52-8210-f700f562ccae', 'es', 'Är volontärerna mellan 18 och 30 år?', '¿Los voluntarios tienen entre 18 y 30 años?', '2026-08-28 19:05:47.720879+00'),
	('6660c02a-bccd-44ba-96f4-a3a46377482d', 'fr', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Aide aux activités pour les clubs sportifs proposant des activités encadrées pour les enfants et les jeunes de 7 à 25 ans.', '2026-08-28 19:05:47.72619+00'),
	('3c137677-9a2b-4e5e-9a34-5eea35ce0879', 'fr', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Complément automatique à l''allocation pour enfant (barnbidrag) à partir du deuxième enfant.', '2026-08-28 19:05:47.72619+00'),
	('b86f7c38-eeb9-4bba-a6e1-7571bb31f34f', 'fr', 'Avser ansökan en fysisk investering?', 'La demande concerne-t-elle un investissement physique ?', '2026-08-28 19:05:47.72619+00'),
	('265743d5-80a7-40e6-b9ce-dfa6cae8d712', 'fr', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'La demande concerne-t-elle un voyage ou un échange international ?', '2026-08-28 19:05:47.72619+00');
INSERT INTO public.kb_translations VALUES
	('08b4b25f-35fe-4916-be5d-efe32bd2873b', 'fr', 'Avser ansökan en investering i byggnader eller maskiner?', 'La demande concerne-t-elle un investissement dans des bâtiments ou des machines ?', '2026-08-28 19:05:47.72619+00'),
	('06259f57-4709-4d0c-88d5-64040e47afc2', 'fr', 'Avser ansökan en redan utgiven titel?', 'La demande concerne-t-elle un titre déjà publié ?', '2026-08-28 19:05:47.72619+00'),
	('b7293865-a88b-4b34-b8ad-e6f84b79d31c', 'fr', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'La demande concerne-t-elle une entreprise agricole, horticole ou d''élevage de rennes ?', '2026-08-28 19:05:47.72619+00'),
	('49bbd559-0d62-4bca-aa75-6bd01d68a00f', 'fr', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'La demande concerne-t-elle l''achat de littérature pour des bibliothèques publiques ou scolaires ?', '2026-08-28 19:05:47.72619+00'),
	('bec9487c-6039-47b5-bf8d-5edd2c7bdd7d', 'fr', 'Avser investeringen jordbruksverksamhet?', 'L''investissement concerne-t-il une activité agricole ?', '2026-08-28 19:05:47.72619+00'),
	('caaac831-599f-49a6-add9-f9be8eb2911e', 'fr', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Le projet consiste-t-il à construire, acheter ou rénover un local ?', '2026-08-28 19:05:47.72619+00'),
	('1e0d9b58-28cb-4913-81b1-d8aac509dde2', 'fr', 'Avser projektet naturvård eller friluftsliv?', 'Le projet concerne-t-il la protection de la nature ou les activités de plein air ?', '2026-08-28 19:05:47.72619+00'),
	('fab61609-830b-4b98-a67a-a8f9fef3d5ed', 'fr', 'Avser projektet skola eller vuxenutbildning?', 'Le projet concerne-t-il l''école ou la formation des adultes ?', '2026-08-28 19:05:47.72619+00'),
	('1f514b1d-07b6-4ba2-a7c9-6abad9664d99', 'fr', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Renoncez-vous à travailler pour soigner ou être auprès d''un proche si gravement malade que la maladie menace sa vie ?', '2026-08-28 19:05:47.72619+00'),
	('2942725d-06b0-4cea-9174-057ef102deb9', 'fr', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'L''association mène-t-elle des activités régulières dans la commune ?', '2026-08-28 19:05:47.72619+00'),
	('893d4aee-3b32-4035-a443-4a49b40dc953', 'fr', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Estimez-vous que votre capacité de travail est réduite pendant au moins un an en raison d''une maladie ou d''un handicap ?', '2026-08-28 19:05:47.72619+00'),
	('10d0e038-0aea-48ea-90be-026e19529065', 'fr', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Aide soumise à conditions de ressources pour ceux qui ont une pension faible ou nulle et ont besoin d''aide pour atteindre un niveau de vie raisonnable.', '2026-08-28 19:05:47.72619+00'),
	('65ca7e43-170b-46ad-baec-63e60875c7f0', 'fr', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'L''enfant doit-il habiter sur le lieu d''études (hébergement) parce que le trajet est trop long ?', '2026-08-28 19:05:47.72619+00'),
	('5d9e80b4-b814-4dd9-8008-fcece82b44bd', 'fr', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Le logement doit-il être adapté (p. ex. rampe, ouvre-porte, salle de bain) ?', '2026-08-28 19:05:47.72619+00'),
	('ff2a6a24-0f49-4040-849d-0071ece220f8', 'fr', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'L''un de vos enfants de 8 à 19 ans a-t-il besoin de lunettes ou de lentilles ?', '2026-08-28 19:05:47.72619+00'),
	('1572ae78-d16c-40d7-b6bc-22fba08d5a37', 'fr', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'L''autre parent ne paie-t-il rien, ou moins que la pension alimentaire complète ?', '2026-08-28 19:05:47.72619+00'),
	('02eedef7-f9d4-43c4-818d-3adb22d2e3a0', 'fr', 'Betalar du hyra eller andra boendekostnader?', 'Payez-vous un loyer ou d''autres frais de logement ?', '2026-08-28 19:05:47.72619+00'),
	('3b95e497-b990-492f-b55b-a8772d3918c8', 'fr', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Aide pour adapter le logement en cas de handicap — p. ex. rampes, ouvre-portes ou aménagement de la salle de bain.', '2026-08-28 19:05:47.72619+00'),
	('153f75e8-2932-494f-bbac-541c7144a5bb', 'fr', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Aides pour construire, acheter ou rénover des salles de réunion publiques.', '2026-08-28 19:05:47.72619+00'),
	('95ac2b82-7275-488a-ad1e-fd30019cdfe5', 'fr', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Aide pour acheter ou adapter une voiture lorsqu''un handicap durable rend très difficile de se déplacer ou de prendre les transports en commun.', '2026-08-28 19:05:47.72619+00'),
	('6c0cb2bb-6cf2-469f-97fc-9e403e30f31a', 'fr', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Aides aux voyages et échanges internationaux pour les professionnels du secteur culturel.', '2026-08-28 19:05:47.72619+00'),
	('a4625ec3-5156-4f03-9d87-70915afd827c', 'fr', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Aides aux échanges internationaux, voyages et séjours de travail des artistes professionnels.', '2026-08-28 19:05:47.72619+00'),
	('d7c90d2f-ebaf-48ba-b631-57431333ad9f', 'fr', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Bourse et prêt facultatif pour des études de niveau secondaire supérieur ou post-secondaire.', '2026-08-28 19:05:47.72619+00'),
	('ce39a89a-3531-4b03-a137-e8c4c2fa511a', 'fr', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Bourses et prêts pour étudier à l''étranger, avec des prêts complémentaires pour p. ex. les frais de scolarité et les voyages.', '2026-08-28 19:05:47.72619+00'),
	('ebc5864c-b462-4961-8f20-bc16bc4034fb', 'fr', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Aide qui accompagne les acteurs suédois dans la préparation de candidatures aux programmes de l''UE comme Horisont Europa.', '2026-08-28 19:05:47.72619+00'),
	('fcc87606-daa8-48ff-9d3c-0e602e823db5', 'fr', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Aide aux employeurs qui embauchent des personnes à capacité de travail réduite.', '2026-08-28 19:05:47.72619+00'),
	('08df598b-0814-436c-ae36-09761a6d06be', 'fr', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Aide au logement et aux voyages de retour lorsqu''un lycéen doit habiter sur le lieu d''études en raison d''un long trajet.', '2026-08-28 19:05:47.72619+00'),
	('3931cc3e-e026-4532-b632-7bbc688cb2fd', 'uk', 'Är projektet ett musikprojekt?', 'Це музичний проєкт?', '2026-08-28 19:05:47.782235+00'),
	('d262c04c-c033-4819-b016-f1d13b083977', 'fr', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Aides au travail des organisations à but non lucratif pour préserver, utiliser et développer le patrimoine culturel.', '2026-08-28 19:05:47.72619+00'),
	('dc4d3bcf-bcab-4e18-bf5f-03f95be9f858', 'fr', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Aides aux projets communaux et locaux de protection de la nature, y compris les zones humides et les activités de plein air.', '2026-08-28 19:05:47.72619+00'),
	('604a50ee-124b-4724-bed5-a9783e15b595', 'fr', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Aides aux communes pour l''achat de littérature destinée aux bibliothèques publiques et scolaires.', '2026-08-28 19:05:47.72619+00'),
	('dafbfc1d-dba6-415b-ae14-ab9d1c77ce10', 'fr', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Aides aux responsables d''écoles pour la rencontre des élèves avec la culture professionnelle à l''école obligatoire.', '2026-08-28 19:05:47.72619+00'),
	('71aadcb8-949b-48b5-a2a8-67461e6ef51b', 'fr', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Aide pour ce dont votre enfant a besoin mais que le budget familial ne permet pas : loisirs, vêtements, sorties scolaires, lunettes, activités de vacances et plus.', '2026-08-28 19:05:47.72619+00'),
	('18bfe515-dd67-4b98-b481-b7254e7fa9bd', 'fr', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Aides issues notamment de Världens Barn, Musikhjälpen et Victoriafonden — demandées par des organisations suédoises à but non lucratif titulaires d''un 90-konto.', '2026-08-28 19:05:47.72619+00'),
	('9c64fbb6-230a-4d61-bd1c-92e92f04ec2b', 'fr', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Aides issues des fonds hydroélectriques et éoliens pour des projets qui développent le territoire.', '2026-08-28 19:05:47.72619+00'),
	('f36c8310-e251-4880-b5ae-ab5889fc317b', 'fr', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Bourse sans part de prêt pour les demandeurs d''emploi de 25 à 60 ans ayant une scolarité courte et devant étudier au niveau du collège ou du lycée.', '2026-08-28 19:05:47.72619+00'),
	('50eb3d92-e1bc-469d-8440-44622b17fe04', 'fr', 'Bidrar projektet till energiomställningen?', 'Le projet contribue-t-il à la transition énergétique ?', '2026-08-28 19:05:47.72619+00'),
	('05546a19-87d9-41da-9aa1-513ecef006e0', 'fr', 'Bor du och barnets andra förälder på skilda håll?', 'Vous et l''autre parent de l''enfant vivez-vous séparément ?', '2026-08-28 19:05:47.72619+00'),
	('9b3b86ae-5c6a-4a0b-9f66-916f1897b38c', 'fr', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Chèques pour les petites entreprises afin de faire appel à des compétences externes pour l''internationalisation ou la numérisation.', '2026-08-28 19:05:47.72619+00'),
	('ce1c3a75-70df-4796-a10b-b444eeb424b0', 'fr', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Participez-vous à un programme d''Arbetsförmedlingen (p. ex. jobb- och utvecklingsgarantin) ?', '2026-08-28 19:05:47.72619+00'),
	('1fdb5af4-a9c1-4ff1-9b27-160dd8bcd0b2', 'fr', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Soutien a posteriori aux maisons d''édition pour la publication de littérature de qualité.', '2026-08-28 19:05:47.72619+00'),
	('539fa940-7dbe-4bf0-9057-ee6a00fd2ae0', 'fr', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Aide financière pour ceux qui ont un permis de séjour lié à la protection et souhaitent volontairement retourner définitivement dans leur pays d''origine.', '2026-08-28 19:05:47.72619+00'),
	('e4869d2c-155e-403c-9e56-60a850a953dd', 'fr', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Aide financière aux employeurs qui embauchent une personne longtemps éloignée de la vie professionnelle.', '2026-08-28 19:05:47.72619+00'),
	('5a309c76-2f94-4e03-8f24-693ddd18fa5f', 'fr', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Aide financière pendant la phase de démarrage pour les demandeurs d''emploi qui créent leur entreprise.', '2026-08-28 19:05:47.72619+00'),
	('2c69e6df-d740-453b-8532-32a177c4cf03', 'fr', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten ouvre en continu des appels à projets en recherche énergétique, innovation et efficacité énergétique.', '2026-08-28 19:05:47.72619+00'),
	('ec87546d-a3e2-4594-8a30-8c3a3c8ab1a7', 'fr', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Indemnité pour s''absenter du travail ou des études afin de s''occuper d''un enfant.', '2026-08-28 19:05:47.72619+00'),
	('ac40aba0-4dfd-4d29-a9a5-a67475056b99', 'fr', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Indemnité pour ceux qui sont nouveaux en Suède et participent au programme d''établissement d''Arbetsförmedlingen ; versée par Försäkringskassan.', '2026-08-28 19:05:47.72619+00'),
	('89be6bc6-b803-444e-89a2-b39de4458392', 'fr', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Indemnité couvrant une partie du coût du logement pour les jeunes sans enfants à faibles revenus.', '2026-08-28 19:05:47.72619+00'),
	('17128260-b306-4717-ba35-0881a1d222d9', 'fr', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Indemnité pour les surcoûts qu''entraîne un handicap durable — pour les adultes, ou pour les parents d''enfants handicapés.', '2026-08-28 19:05:47.72619+00'),
	('53650a12-53d6-4e98-a10c-7d1d04fdb235', 'fr', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Indemnité pour les jeunes (19–29 ans) qui ne peuvent pas travailler à plein temps pendant au moins un an pour cause de maladie ou de handicap.', '2026-08-28 19:05:47.72619+00');
INSERT INTO public.kb_translations VALUES
	('7f778be6-733b-47f3-84df-ec3ac47caa3b', 'fr', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Indemnité lorsque la capacité de travail est durablement réduite — anciennement appelée förtidspension (retraite anticipée).', '2026-08-28 19:05:47.72619+00'),
	('4f5a3ed5-5581-4183-b6de-164bbd4e956b', 'fr', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Indemnité lorsque vous renoncez à travailler pour être auprès d''un proche gravement malade.', '2026-08-28 19:05:47.72619+00'),
	('689fb64d-5cac-4fe4-9956-292a1508fe1b', 'fr', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Indemnité lorsque vous participez à un programme de politique de l''emploi d''Arbetsförmedlingen.', '2026-08-28 19:05:47.72619+00'),
	('5d362aa3-e49f-4400-8637-38584cd78324', 'fr', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Indemnité lorsque vous ne pouvez pas travailler normalement pour cause de maladie.', '2026-08-28 19:05:47.72619+00'),
	('85f9c9a3-6b7e-4bec-86e8-740b0981943d', 'fr', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Indemnité lorsque vous restez à la maison pour vous occuper d''un enfant malade.', '2026-08-28 19:05:47.72619+00'),
	('e3fa308d-84b8-4b93-8467-60c56148e4c2', 'fr', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Indemnité couvrant une partie du coût du logement pour les ménages avec enfants et revenus modestes.', '2026-08-28 19:05:47.72619+00'),
	('6e4f7f0e-a085-4732-8a4e-a7197a69b5ea', 'fr', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Indemnité pour les parents dont l''enfant, en raison d''un handicap, a besoin de plus de soins et de surveillance que les enfants du même âge.', '2026-08-28 19:05:47.72619+00'),
	('367f39c4-0ce8-4b90-abc4-b86e2401160e', 'fr', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Indemnité en cas de chômage — basée sur le revenu pour les membres, montant de base pour les autres.', '2026-08-28 19:05:47.72619+00'),
	('0ece2370-cbcf-4a72-be3a-4363d7033cfb', 'fr', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Une cinquantaine de fondations de caisses d''épargne accordent des aides à des projets locaux de sport, culture, éducation et développement local — dans la zone d''activité de la caisse.', '2026-08-28 19:05:47.72619+00'),
	('2a74da44-413a-48c9-a110-7883b6066262', 'fr', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Aide aux projets financée par l''UE, demandée auprès de votre zone Leader locale — pour les associations, entreprises et communes qui développent les zones rurales.', '2026-08-28 19:05:47.72619+00'),
	('6a8af00a-1f40-4a51-b568-a885a30e9adb', 'fr', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Aide financée par l''UE pour les demandeurs d''emploi qui prennent un poste dans un autre pays UE/EEE : remboursement du voyage d''entretien, des frais de déménagement et d''un cours de langue.', '2026-08-28 19:05:47.72619+00'),
	('037857d2-4d58-418c-8b73-bcd94abc8d7d', 'fr', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Fonds du Fonds social européen pour des projets renforçant les compétences, la reconversion et l''inclusion sur le marché du travail.', '2026-08-28 19:05:47.72619+00'),
	('ede0acfd-1849-483c-9165-ec56f1f34ef8', 'fr', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Aide de l''UE pour des échanges de groupes de jeunes de 13 à 30 ans, de 5 à 21 jours hors jours de voyage.', '2026-08-28 19:05:47.72619+00'),
	('ca7b8214-7050-40f6-aec2-98c769d94525', 'fr', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Aide de l''UE pour les projets de coopération d''organisations culturelles avec des partenaires dans plusieurs pays européens.', '2026-08-28 19:05:47.72619+00'),
	('d6d2da77-84ae-469a-aee2-426aa037f9ef', 'fr', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Aide de l''UE pour les organisations qui accueillent ou envoient de jeunes volontaires de 18 à 30 ans.', '2026-08-28 19:05:47.72619+00'),
	('0a1b0288-3d22-4943-ae3a-d21092295e7c', 'fr', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Aide de l''UE pour la mobilité du personnel et des élèves dans l''école et la formation des adultes.', '2026-08-28 19:05:47.72619+00'),
	('6b13497c-64b4-4d61-8efc-4c395e683d62', 'fr', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Aide de l''UE avec des montants forfaitaires pour les premiers projets européens de coopération des petites organisations.', '2026-08-28 19:05:47.72619+00'),
	('f1c1e868-bb99-436c-936a-4e8af0de65b0', 'fr', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Financement pour les jeunes entreprises développant des produits ou services innovants à potentiel international.', '2026-08-28 19:05:47.72619+00'),
	('196af8f8-5e34-4c48-9ef7-41af1a1fa1b5', 'fr', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Y a-t-il une caisse d''épargne (et donc une fondation de caisse d''épargne) là où vous exercez votre activité ?', '2026-08-28 19:05:47.72619+00'),
	('5e451bb6-760b-4b45-902d-4d535c0949a2', 'fr', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Aides de fonctionnement pluriannuelles pour les compagnies professionnelles indépendantes de danse, théâtre et théâtre musical.', '2026-08-28 19:05:47.72619+00'),
	('6611aae5-5eb1-49d6-89de-6af0da56e36f', 'fr', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Aides à la recherche dans les domaines de Forte : santé, vie professionnelle et protection sociale. Demandées par des chercheurs titulaires d''un doctorat dans les universités suédoises.', '2026-08-28 19:05:47.72619+00'),
	('b09e2f52-0b41-4437-9194-e1caabe19223', 'fr', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Financement de la recherche fondamentale libre dans tous les domaines scientifiques.', '2026-08-28 19:05:47.72619+00'),
	('a9a67e68-65f8-40d3-886e-a1f38b62b306', 'fr', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Financement de la recherche en environnement, sciences agricoles et aménagement du territoire.', '2026-08-28 19:05:47.72619+00'),
	('a4de18fd-3625-4f74-a194-d5a481f88717', 'fr', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Envisagez-vous de vous installer à l''étranger (travail, études ou retour au pays) ?', '2026-08-28 19:05:47.72619+00'),
	('147394cd-5f4f-4323-82bb-5fafad3477ab', 'fr', 'Genomförs insatserna av professionella kulturaktörer?', 'Les activités sont-elles menées par des acteurs culturels professionnels ?', '2026-08-28 19:05:47.72619+00'),
	('99bb5a42-b655-4cad-800e-62ef16a4c2a6', 'fr', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Le projet se déroule-t-il en zone rurale ou dans une petite localité ?', '2026-08-28 19:05:47.72619+00'),
	('ef883fb6-9e92-43d8-a63d-18a0bd8caf09', 'fr', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Protection de base pour ceux qui ont eu peu ou pas de revenus du travail au cours de leur vie.', '2026-08-28 19:05:47.72619+00'),
	('8b617061-977a-4fd3-a8d4-08386b8d3d61', 'fr', 'Går något av dina barn i grundskolan?', 'L''un de vos enfants est-il à l''école obligatoire ?', '2026-08-28 19:05:47.72619+00'),
	('519e0d75-4008-4b74-af08-03e939a63470', 'fr', 'Går något av dina barn på gymnasiet?', 'L''un de vos enfants est-il au lycée ?', '2026-08-28 19:05:47.72619+00'),
	('951abb14-4752-4de7-b6db-7c6980074811', 'fr', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'L''embauche concerne-t-elle une personne à capacité de travail réduite ?', '2026-08-28 19:05:47.72619+00'),
	('b34dfda7-9b3d-42a2-b1ec-717badd76e7b', 'fr', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'L''embauche concerne-t-elle une personne longtemps au chômage ou nouvelle en Suède ?', '2026-08-28 19:05:47.72619+00'),
	('c0e7dfb6-8216-4e1f-b0e6-3c47db93634b', 'fr', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Le projet vise-t-il à préserver ou à rendre accessible le patrimoine culturel ?', '2026-08-28 19:05:47.72619+00'),
	('82404609-d756-4b2a-acb2-eee8143d16f4', 'fr', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Le projet porte-t-il sur l''énergie, l''efficacité énergétique ou l''innovation énergétique ?', '2026-08-28 19:05:47.72619+00'),
	('0048f5f2-a14b-40b6-8e4d-e97e83551c7c', 'fr', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Le projet porte-t-il sur la santé, la vie professionnelle ou la protection sociale ?', '2026-08-28 19:05:47.72619+00'),
	('b7720bae-c769-4a27-b768-c50c61a6588d', 'fr', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Le projet porte-t-il sur le développement des compétences ou des mesures pour l''emploi ?', '2026-08-28 19:05:47.72619+00'),
	('ac5073a0-18c8-472b-8d13-179594197998', 'fr', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Le projet porte-t-il sur des mesures environnementales ou climatiques ?', '2026-08-28 19:05:47.72619+00'),
	('c839e20a-3cb2-4794-bf12-0861129cdfd7', 'fr', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'L''enfant a-t-il un chemin vers l''école long, dangereux à cause de la circulation ou difficile d''une autre manière ?', '2026-08-28 19:05:47.72619+00'),
	('d35bdb86-1d94-4c16-9313-2b16cd1e354f', 'fr', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Avez-vous travaillé au moins 16 heures par semaine pendant au moins 8 ans au total ?', '2026-08-28 19:05:47.72619+00'),
	('8e7ac046-0d03-4add-8240-edd0cb4c489e', 'fr', 'Har du barn som bor hos dig, helt eller växelvis?', 'Avez-vous des enfants qui vivent chez vous, à plein temps ou en alternance ?', '2026-08-28 19:05:47.72619+00'),
	('05b0a8f4-2056-4fad-811d-69962b914b91', 'fr', 'Har du barn som bor hos dig?', 'Avez-vous des enfants qui vivent chez vous ?', '2026-08-28 19:05:47.72619+00'),
	('1cc8963a-0e0f-49b6-b28c-f6be9b0c7123', 'fr', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Vous ou votre enfant avez-vous un handicap censé durer au moins un an ?', '2026-08-28 19:05:47.72619+00'),
	('1a1ad8e0-b6b4-42dd-94c0-eb2cf9f809f3', 'fr', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Vous ou quelqu''un du ménage avez-vous un handicap durable qui affecte le logement ?', '2026-08-28 19:05:47.72619+00'),
	('18e1bfa6-880e-4e1e-94f3-45accad11433', 'fr', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Vous ou un proche avez-vous un handicap ou une maladie de longue durée ou grave ?', '2026-08-28 19:05:47.72619+00'),
	('1a17bb31-d085-471b-b3a5-431a64a01551', 'fr', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Avez-vous une maladie ou une blessure qui réduit actuellement votre capacité de travail ?', '2026-08-28 19:05:47.72619+00'),
	('4356ffcf-415d-43d0-a71a-aa0acf938a0c', 'fr', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Avez-vous déjà eu du mal à payer une sortie scolaire, un voyage de classe ou une activité de loisir à laquelle votre enfant est censé participer ?', '2026-08-28 19:05:47.72619+00'),
	('bbd11e81-82ab-4bdc-961a-cc90d3642485', 'fr', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Avez-vous du mal à vivre de votre pension et de vos autres revenus ?', '2026-08-28 19:05:47.72619+00'),
	('dbe9e222-736a-40f0-b3a5-2a12d505f0c6', 'fr', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Avez-vous obtenu ces dernières années un permis de séjour en Suède, p. ex. comme personne à protéger ou comme membre de famille ?', '2026-08-28 19:05:47.72619+00'),
	('db3cc62d-ebaf-4a20-86c3-993f668191c8', 'fr', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Avez-vous un permis de séjour en Suède comme réfugié ou personne à protéger (ou êtes-vous un proche de quelqu''un qui en a un) ?', '2026-08-28 19:05:47.72619+00'),
	('566c0169-ca8b-4517-bf86-351567b4c26f', 'fr', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Avez-vous atteint l''âge de référence de la retraite (67 ans en 2026) ?', '2026-08-28 19:05:47.72619+00'),
	('94b7ed02-fe36-404c-9b99-dbd4979041b0', 'fr', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Votre organisation a-t-elle un OID (Organisation ID) enregistré dans l''Organisation Registration System de l''UE ?', '2026-08-28 19:05:47.72619+00');
INSERT INTO public.kb_translations VALUES
	('c1568f46-48d3-42b7-9565-8318885897f2', 'fr', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Le handicap a-t-il entraîné des surcoûts — p. ex. aides techniques, déplacements, régime particulier ou usure ?', '2026-08-28 19:05:47.72619+00'),
	('64c1b56a-5c2b-45ff-9f5a-71804b005e72', 'fr', 'Har föreningen antagna stadgar och en vald styrelse?', 'L''association a-t-elle des statuts adoptés et un conseil d''administration élu ?', '2026-08-28 19:05:47.72619+00'),
	('d04f6c51-2058-4d04-96b9-2c6df5f0eb44', 'fr', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'L''association a-t-elle une structure démocratique (statuts, assemblée annuelle, conseil) ?', '2026-08-28 19:05:47.72619+00'),
	('dfcfb235-3a7f-460c-9140-2e4fa4557616', 'fr', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'L''association mène-t-elle des activités régulières pour les enfants ou les jeunes ?', '2026-08-28 19:05:47.72619+00'),
	('271afe53-e04e-4587-bd02-99a1d1e9ee6f', 'fr', 'Har företaget mellan cirka 2 och 49 anställda?', 'L''entreprise compte-t-elle entre environ 2 et 49 salariés ?', '2026-08-28 19:05:47.72619+00'),
	('4ae6c799-b083-4c8e-9040-78bdc434e244', 'fr', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Le ménage a-t-il du mal à couvrir les dépenses de nourriture, de logement et de première nécessité ?', '2026-08-28 19:05:47.72619+00'),
	('ffdb3b46-3b5a-4a15-9a08-1637c546cb5d', 'fr', 'Har lösningen internationell potential?', 'La solution a-t-elle un potentiel international ?', '2026-08-28 19:05:47.72619+00'),
	('bd1e8bf6-0306-48f5-ae2a-628557dcb447', 'fr', 'Har ni en partnergrupp i ett annat land?', 'Avez-vous un groupe partenaire dans un autre pays ?', '2026-08-28 19:05:47.72619+00'),
	('154203b8-25b3-489d-8942-c89a83d85666', 'fr', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Avez-vous une organisation partenaire dans un autre pays européen ?', '2026-08-28 19:05:47.72619+00'),
	('d5dc829b-9a3e-457e-b4a0-18044e001cf8', 'fr', 'Har ni partner i minst tre olika europeiska länder?', 'Avez-vous des partenaires dans au moins trois pays européens différents ?', '2026-08-28 19:05:47.72619+00'),
	('d4ab503f-c87d-421b-a236-2e6d3373dfcc', 'fr', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Votre siège ou votre activité principale se trouve-t-il dans la région où vous déposez la demande ?', '2026-08-28 19:05:47.72619+00'),
	('822ddd0c-0e8c-41ba-b4af-4a5044fc3333', 'fr', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'L''un de vos enfants a-t-il un handicap qui fait qu''il a besoin de plus de soins ou de surveillance que les autres enfants du même âge ?', '2026-08-28 19:05:47.72619+00'),
	('d8cfd71e-3e90-4fbf-96cc-48edc44eff14', 'fr', 'Har organisationen en demokratisk uppbyggnad?', 'L''organisation a-t-elle une structure démocratique ?', '2026-08-28 19:05:47.72619+00'),
	('b78f27a7-2b39-4118-b106-fba27d51b908', 'fr', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'L''organisation a-t-elle un Quality Label (label de qualité) ?', '2026-08-28 19:05:47.72619+00'),
	('11717f8d-068a-4158-ba69-3804a1d8ad55', 'fr', 'Har organisationen ett 90-konto?', 'L''organisation a-t-elle un 90-konto ?', '2026-08-28 19:05:47.72619+00'),
	('cba24d28-c747-42b6-bf44-f393e09ae24a', 'fr', 'Har organisationen ett OID (Organisation ID)?', 'L''organisation a-t-elle un OID (Organisation ID) ?', '2026-08-28 19:05:47.72619+00'),
	('348f1ead-2819-48f3-a559-9a7eea3b84d3', 'fr', 'Har organisationen ett OID?', 'L''organisation a-t-elle un OID ?', '2026-08-28 19:05:47.72619+00'),
	('dffd3831-2eac-4bea-bcf8-6ed205782f95', 'fr', 'Har organisationen medlemsföreningar i flera län?', 'L''organisation a-t-elle des associations membres dans plusieurs départements ?', '2026-08-28 19:05:47.72619+00'),
	('7ffe48c9-4bf9-4dce-8270-e446045c9733', 'fr', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'L''organisation a-t-elle des finances saines et une structure démocratique ?', '2026-08-28 19:05:47.72619+00'),
	('2041ab9b-0525-47c9-b869-20472cbd4988', 'fr', 'Har projektet en partner i ett annat land?', 'Le projet a-t-il un partenaire dans un autre pays ?', '2026-08-28 19:05:47.72619+00'),
	('ce075700-bef1-4c10-a0e6-f178242231e0', 'fr', 'Har projektledaren doktorsexamen?', 'Le responsable du projet est-il titulaire d''un doctorat ?', '2026-08-28 19:05:47.72619+00'),
	('edc8e853-32c9-4551-bfe7-0fe14fdcf6a0', 'fr', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Votre commune de résidence doit assurer les trajets quotidiens entre le domicile et le lycée lorsque le trajet fait au moins six kilomètres (p. ex. carte de bus).', '2026-08-28 19:05:47.72619+00'),
	('191ccd70-e955-4d2b-9122-07b77722e6ac', 'fr', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Êtes-vous en train d''acquérir ou d''équiper votre premier logement en Suède ?', '2026-08-28 19:05:47.72619+00'),
	('d1ec84cb-db1c-466d-9ec6-4fdc7512d2ba', 'fr', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Le projet comprend-il un voyage ou un échange international ?', '2026-08-28 19:05:47.72619+00'),
	('6521d176-ae12-46e4-b0f5-af27afa16236', 'fr', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Aide à l''investissement pour les entreprises des zones aidées : bâtiments, machines et formation.', '2026-08-28 19:05:47.72619+00'),
	('eded62a4-8dc3-4ccd-8475-8aea1f4d7b98', 'fr', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Aide à l''investissement pour des mesures réduisant les émissions de gaz à effet de serre.', '2026-08-28 19:05:47.72619+00'),
	('5f3a03a9-b5ef-4aac-a16e-bbcf1117d279', 'fr', 'Kan projektets miljönytta mätas?', 'Le bénéfice environnemental du projet peut-il être mesuré ?', '2026-08-28 19:05:47.72619+00'),
	('01634e3c-e6ba-4a05-9aca-10040a6e8b3b', 'fr', 'Kan åtgärdens utsläppsminskning beräknas?', 'La réduction d''émissions de la mesure peut-elle être calculée ?', '2026-08-28 19:05:47.72619+00'),
	('dbc6950d-d7fc-4c94-86a6-bcecff4894da', 'fr', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'L''organisation peut-elle avancer les coûts jusqu''au versement de l''aide ?', '2026-08-28 19:05:47.72619+00'),
	('f54a1db5-bb49-44ce-9b8d-ad9a3d0ee71f', 'fr', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Les enseignements seront-ils utilisés dans votre activité en Suède ?', '2026-08-28 19:05:47.72619+00'),
	('47de33ce-e7dd-4b4b-a6bf-dd9fa58f1723', 'fr', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'L''investissement ne commencera-t-il qu''après l''envoi de la demande ?', '2026-08-28 19:05:47.72619+00'),
	('70ededc7-2ad2-4f7c-a287-4b761d0f6c2a', 'fr', 'Kommer projektet människor i ert närområde till del?', 'Le projet profite-t-il aux habitants de votre territoire ?', '2026-08-28 19:05:47.72619+00'),
	('1e9e09e1-841a-4514-b2d6-57c09e15cc4d', 'fr', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Le dernier filet de sécurité économique de la commune lorsque les revenus ne couvrent pas le strict nécessaire.', '2026-08-28 19:05:47.72619+00'),
	('224ce98d-bb87-4c2c-bbe9-375c36252a7a', 'fr', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Les aides propres des communes à la vie associative locale : aide à l''activité par séance, aide aux locaux, aide au démarrage et plus.', '2026-08-28 19:05:47.72619+00'),
	('418763f2-c0bb-4de1-9b20-863a07746c33', 'fr', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Transport scolaire gratuit pour les élèves de l''école obligatoire en cas de longue distance, de trajet dangereux ou de handicap — un droit selon la loi scolaire.', '2026-08-28 19:05:47.72619+00'),
	('3bd01138-924e-4fd6-a11c-165e4a51a7ce', 'fr', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Aide légale pour des lunettes ou lentilles pour enfants et jeunes ; montants et démarches varient selon la région — vérifiez le niveau de votre région.', '2026-08-28 19:05:47.72619+00'),
	('3177c169-7cac-421c-ba29-31dbc53c8c44', 'fr', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Le projet se situe-t-il dans un territoire concerné par l''hydroélectricité ou l''éolien ?', '2026-08-28 19:05:47.72619+00'),
	('411802dc-630e-4ca2-a462-b2aab0996fa5', 'fr', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Le projet relève-t-il de l''environnement, des sciences agricoles ou de l''aménagement du territoire ?', '2026-08-28 19:05:47.72619+00'),
	('2054e044-c2df-451c-9a8b-e64afbaeeb93', 'fr', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Le lieu d''activité est-il en zone d''aide A ou B (grande partie du Norrland et du Svealand intérieur) ?', '2026-08-28 19:05:47.72619+00'),
	('c1ae3910-be97-4a3f-8a72-627f8671f701', 'fr', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Prêt pour acheter le strict nécessaire d''un premier foyer en Suède — meubles, ustensiles et autre équipement de base.', '2026-08-28 19:05:47.72619+00'),
	('5e650181-aa8d-4471-989d-d8d026cf186b', 'fr', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Le projet réduit-il les émissions de procédés industriels ou crée-t-il des émissions négatives ?', '2026-08-28 19:05:47.72619+00'),
	('89c5cf88-aac5-476b-9b4f-d35ab4f03e9a', 'fr', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Allocation mensuelle pour les enfants vivant en Suède, de la naissance à 16 ans.', '2026-08-28 19:05:47.72619+00'),
	('cca7ed86-96c8-4b5e-99db-8fe1e7abe4da', 'fr', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket propose des aides aux organisations, entreprises, associations, au secteur public et aux particuliers dans le domaine de l''environnement.', '2026-08-28 19:05:47.72619+00'),
	('6ff0ef09-36e8-4aba-9ccc-27de42e4a74d', 'fr', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Envisagez-vous de retourner volontairement et définitivement dans votre pays d''origine ?', '2026-08-28 19:05:47.72619+00'),
	('21fcfcd0-0168-44a6-82e7-ad1038bc0ce8', 'fr', 'Planerar du att starta eget företag?', 'Envisagez-vous de créer votre propre entreprise ?', '2026-08-28 19:05:47.72619+00'),
	('7807cb92-4731-4091-9984-084db4aec25c', 'fr', 'Planerar du att studera utomlands?', 'Envisagez-vous d''étudier à l''étranger ?', '2026-08-28 19:05:47.72619+00'),
	('d1a77c8c-9512-4f0d-90aa-f2ede3ab0d81', 'fr', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Envisagez-vous des études qui renforcent votre position sur le marché du travail ?', '2026-08-28 19:05:47.72619+00'),
	('2c5d7580-5356-4e71-a56b-51d88e77ce3a', 'fr', 'Planerar ni att anställa?', 'Envisagez-vous d''embaucher ?', '2026-08-28 19:05:47.72619+00'),
	('29b645ad-8815-4c91-b7f9-df1572252907', 'fr', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Envisagez-vous de candidater à un programme de l''UE (p. ex. Horisont Europa) ?', '2026-08-28 19:05:47.72619+00'),
	('7e3242fe-c793-4e9d-8a76-6bb62ce6978e', 'fr', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Aide à la production et au développement de courts métrages et de documentaires.', '2026-08-28 19:05:47.72619+00');
INSERT INTO public.kb_translations VALUES
	('e35dafd3-e8b7-4a92-a87d-129164c9e14f', 'fr', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Aides aux projets de la scène musicale indépendante : concerts, production et développement.', '2026-08-28 19:05:47.72619+00'),
	('5771f225-ae0e-4c21-8033-f2ceb542e976', 'fr', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Aides aux projets d''organisations à but non lucratif travaillant avec et pour les enfants et les jeunes.', '2026-08-28 19:05:47.72619+00'),
	('369ffdf1-f856-4014-8f5b-bd6d198eb1bd', 'fr', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Le projet explore-t-il de nouvelles expressions, méthodes ou collaborations artistiques ?', '2026-08-28 19:05:47.72619+00'),
	('aa303990-7e84-4b16-b80d-66397bf4e924', 'fr', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'L''échange dure-t-il de 5 à 21 jours (hors jours de voyage) ?', '2026-08-28 19:05:47.72619+00'),
	('333a0186-e47f-4b8a-9f3f-c79419752d54', 'fr', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Les aides propres des régions aux projets et activités culturels, à côté des aides nationales de Kulturrådet.', '2026-08-28 19:05:47.72619+00'),
	('9b8348cc-f9f2-44d7-a554-427030b608df', 'fr', 'Riktar sig projektet till barn eller unga?', 'Le projet s''adresse-t-il aux enfants ou aux jeunes ?', '2026-08-28 19:05:47.72619+00'),
	('4a36ee65-4055-48bd-ae3e-6d50ea7b1bee', 'fr', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Le projet s''adresse-t-il aux enfants, aux jeunes, aux personnes âgées ou aux personnes handicapées ?', '2026-08-28 19:05:47.72619+00'),
	('6aa1b8b9-8815-41de-bdb0-c98d9f6ce40e', 'fr', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'L''activité s''adresse-t-elle aux enfants et aux jeunes (7–25 ans) ?', '2026-08-28 19:05:47.72619+00'),
	('9e14a247-2e7e-4e9d-a15e-4ff3fd341040', 'fr', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Manquez-vous d''économies ou de biens pouvant couvrir les dépenses ?', '2026-08-28 19:05:47.72619+00'),
	('b59b4d0a-cc38-4c8f-86cc-05e28c109f46', 'fr', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Coopérez-vous avec des partenaires dans au moins deux autres pays nordiques ?', '2026-08-28 19:05:47.72619+00'),
	('54223e5a-4897-425f-a1dd-b36544824677', 'fr', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Allez-vous faire appel à des compétences externes pour une action de développement ?', '2026-08-28 19:05:47.72619+00'),
	('573c68d1-c778-4b28-97bb-2a2ca8916cc8', 'fr', 'Sker mobiliteten till ett annat europeiskt land?', 'La mobilité se fait-elle vers un autre pays européen ?', '2026-08-28 19:05:47.72619+00'),
	('00e81a73-0e9d-4ff6-a04d-b8fc80251455', 'fr', 'Startar du eller tar du över företaget för första gången?', 'Créez-vous ou reprenez-vous l''entreprise pour la première fois ?', '2026-08-28 19:05:47.72619+00'),
	('801cab29-f29b-4720-a1bd-a08c18e16499', 'fr', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Aide au démarrage pour ceux de 40 ans ou moins qui créent ou reprennent une exploitation agricole.', '2026-08-28 19:05:47.72619+00'),
	('9b20c596-e79c-44f6-9d55-7a80d3d22037', 'fr', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Bourse permettant aux artistes professionnels de se concentrer sur leur travail artistique.', '2026-08-28 19:05:47.72619+00'),
	('13b1cb8b-d6a8-4049-9305-32a82cb8a334', 'fr', 'Studerar du, eller planerar du att börja studera?', 'Étudiez-vous, ou prévoyez-vous de commencer des études ?', '2026-08-28 19:05:47.72619+00'),
	('63da0cb4-2ec1-4f94-8d0e-cbeb5a043ac8', 'fr', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Aide aux études pour les adultes en activité qui veulent se former afin de renforcer leur position sur le marché du travail.', '2026-08-28 19:05:47.72619+00'),
	('b5b41127-07d1-4204-9ebb-cb7b2a2b37cb', 'fr', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Aide aux investissements qui renforcent la compétitivité ou réduisent l''impact environnemental des exploitations agricoles.', '2026-08-28 19:05:47.72619+00'),
	('cfdd479a-4062-4129-aec6-abe94a72690a', 'fr', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Aide lorsqu''un enfant vit chez vous et que l''autre parent ne paie pas de pension alimentaire.', '2026-08-28 19:05:47.72619+00'),
	('d7db93e0-dffa-4cac-82a7-4694fa4cb819', 'fr', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Aide aux projets des organisations à but non lucratif pour les personnes, l''environnement et un monde meilleur.', '2026-08-28 19:05:47.72619+00'),
	('2cfdfd80-8e36-4434-a030-f5ca20d9c2a6', 'fr', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Aide à la transition de l''industrie vers zéro émission de gaz à effet de serre.', '2026-08-28 19:05:47.72619+00'),
	('54de213d-a0d5-409b-9b50-7836bb55db15', 'fr', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Aide aux projets artistiques et culturels à dimension nordique et à coopération transfrontalière.', '2026-08-28 19:05:47.72619+00'),
	('c5296982-9c81-4a4a-9649-2d7b5fe80bc5', 'fr', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Aide aux projets culturels novateurs explorant de nouvelles expressions, méthodes ou collaborations artistiques.', '2026-08-28 19:05:47.72619+00'),
	('94ff36ce-101c-4339-bf84-a747ee7ff9b2', 'fr', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Aide aux projets novateurs pour les enfants, les jeunes, les personnes âgées et les personnes handicapées.', '2026-08-28 19:05:47.72619+00'),
	('d29ce21c-e7e7-4d74-b1d0-30437bcc13a0', 'fr', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Aide aux projets de coopération de la scène musicale indépendante.', '2026-08-28 19:05:47.72619+00'),
	('b2078c1f-a40c-4941-9424-4b7e03b462cf', 'fr', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Aide aux projets de coopération dans la culture et les médias qui renforcent la démocratie et la liberté d''expression à l''international.', '2026-08-28 19:05:47.72619+00'),
	('a659e74c-4d09-4d79-a14d-3fbf3887bcc1', 'fr', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Le projet vise-t-il à renforcer la démocratie, l''égalité ou la liberté d''expression ?', '2026-08-28 19:05:47.72619+00'),
	('05774a36-e548-449a-b7fe-ee514ba519e9', 'fr', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Cherchez-vous un emploi, ou avez-vous reçu une offre d''emploi, dans un autre pays de l''UE ou de l''EEE ?', '2026-08-28 19:05:47.72619+00'),
	('322de11f-29a6-46b9-8b49-0e417f1d1c85', 'fr', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Plafond de ce que vous payez en frais de patient sur une période de douze mois — ensuite, frikort (carte de gratuité).', '2026-08-28 19:05:47.72619+00'),
	('834ace7f-c94b-4298-ad93-7bdc782c1229', 'fr', 'Tar du ut hel allmän pension?', 'Percevez-vous la totalité de votre pension publique ?', '2026-08-28 19:05:47.72619+00'),
	('acb788a7-b9f0-4504-8b3c-4410c8603315', 'fr', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Complément couvrant une partie du coût du logement pour ceux qui ont une pension et de faibles revenus.', '2026-08-28 19:05:47.72619+00'),
	('ec5fa849-e4d7-43ef-b11c-aa378298c8b5', 'fr', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Subvention annuelle d''organisation pour les organisations nationales d''enfance et de jeunesse.', '2026-08-28 19:05:47.72619+00'),
	('999409c9-1880-4b1f-be0b-d8c7f1b75a35', 'fr', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Avoir annuel déduit directement chez le dentiste ou l''hygiéniste dentaire.', '2026-08-28 19:05:47.72619+00'),
	('6fdea4b5-a402-4172-a4e8-7f075b65dce7', 'fr', 'Är bolaget yngre än cirka 5 år?', 'L''entreprise a-t-elle moins d''environ 5 ans ?', '2026-08-28 19:05:47.72619+00'),
	('ce9951dd-7e93-4d93-901c-1ff94221040b', 'fr', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Les participants à l''échange ont-ils entre 13 et 30 ans ?', '2026-08-28 19:05:47.72619+00'),
	('6ada6337-31b7-4e96-8a0f-b356d732fc53', 'fr', 'Är det här ert första EU-projekt?', 'Est-ce votre premier projet UE ?', '2026-08-28 19:05:47.72619+00'),
	('cc2b64aa-622c-4061-b841-8b544fa12aaa', 'fr', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Est-il très difficile pour vous (ou votre enfant) de vous déplacer seul ou de voyager en bus et en train ?', '2026-08-28 19:05:47.72619+00'),
	('e1a79b76-f00d-4e01-9867-d63024bf47dc', 'fr', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Vos revenus sont-ils inférieurs à environ 25 000 kr par mois avant impôt ?', '2026-08-28 19:05:47.72619+00'),
	('be667659-1fc2-470b-bb6f-76f6acf258db', 'fr', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Votre dernière formation achevée est-elle l''école obligatoire, ou un lycée que vous n''avez pas terminé ?', '2026-08-28 19:05:47.72619+00'),
	('399864a0-4364-4b89-bb55-fe8a56e4dee5', 'fr', 'Är du 40 år eller yngre?', 'Avez-vous 40 ans ou moins ?', '2026-08-28 19:05:47.72619+00'),
	('abb1a060-1d69-40c2-ac49-af425e5adf6c', 'fr', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Êtes-vous inscrit comme demandeur d''emploi auprès d''Arbetsförmedlingen ?', '2026-08-28 19:05:47.72619+00'),
	('81a6964b-1c88-4d58-86b4-49ec2ed5280a', 'fr', 'Är du mellan 18 och 28 år?', 'Avez-vous entre 18 et 28 ans ?', '2026-08-28 19:05:47.72619+00'),
	('e0942804-777d-4deb-badb-2581c7700f6b', 'fr', 'Är du mellan 19 och 29 år?', 'Avez-vous entre 19 et 29 ans ?', '2026-08-28 19:05:47.72619+00'),
	('0fedff67-2f0d-46af-9100-e1ece1ac45fc', 'fr', 'Är du mellan 25 och 60 år?', 'Avez-vous entre 25 et 60 ans ?', '2026-08-28 19:05:47.72619+00'),
	('4f996cf9-7897-4343-9d92-9dd66d979fb8', 'fr', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Exercez-vous professionnellement dans le secteur culturel (p. ex. danse, musique, arts de la scène) ?', '2026-08-28 19:05:47.72619+00'),
	('12cb681a-76c3-4bf3-bcb0-3a30cc1b48f5', 'fr', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Êtes-vous un artiste professionnel (ni amateur ni en formation initiale) ?', '2026-08-28 19:05:47.72619+00'),
	('dc34a674-20f6-4ce7-ab9a-3c681c025077', 'fr', 'Är du yrkesverksam konstnär?', 'Êtes-vous un artiste professionnel ?', '2026-08-28 19:05:47.72619+00'),
	('3fc3a588-a0f5-4095-82c3-e21f5ee83670', 'fr', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Votre solution est-elle substantiellement novatrice par rapport à ce qui existe déjà ?', '2026-08-28 19:05:47.730589+00'),
	('4af7b485-1230-4596-9575-d41748655c2d', 'fr', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Le club est-il affilié à une fédération sportive spécialisée au sein de Riksidrottsförbundet ?', '2026-08-28 19:05:47.730589+00'),
	('abb2d428-cdf1-4651-93eb-137df40c3ceb', 'fr', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Les revenus du ménage sont-ils faibles par rapport au coût du logement ?', '2026-08-28 19:05:47.730589+00');
INSERT INTO public.kb_translations VALUES
	('e49d50f0-c4c5-4865-9431-d75cb9330fbb', 'fr', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Les revenus cumulés du ménage sont-ils inférieurs à environ 25 000 kr par mois avant impôt ?', '2026-08-28 19:05:47.730589+00'),
	('b129018e-fcf0-4a46-9fab-d0ec8d7e901c', 'fr', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'L''action est-elle un projet délimité (pas l''activité ordinaire) ?', '2026-08-28 19:05:47.730589+00'),
	('f15e6dc6-2f89-45ab-9a60-26485939aab2', 'fr', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Le local est-il ouvert à tous — pas seulement à vos propres membres ?', '2026-08-28 19:05:47.730589+00'),
	('d0fc3981-aa57-49b2-9e80-d2a99b78fb4f', 'fr', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Au moins 60 % des membres ont-ils entre 6 et 25 ans ?', '2026-08-28 19:05:47.730589+00'),
	('6eef60f1-f3ed-4cc4-bc91-b1c87fa6b6c5', 'fr', 'Är minst 60 % av medlemmarna under 26 år?', 'Au moins 60 % des membres ont-ils moins de 26 ans ?', '2026-08-28 19:05:47.730589+00'),
	('3d3c5ca0-f61a-4b7d-8d9e-844df89d12a6', 'fr', 'Är målgruppen delaktig i planering och genomförande?', 'Le groupe cible participe-t-il à la planification et à la mise en œuvre ?', '2026-08-28 19:05:47.730589+00'),
	('cc5dbb09-3738-4ec8-9888-3ed04ece0982', 'fr', 'Är ni ett förlag med professionell utgivning?', 'Êtes-vous une maison d''édition avec une publication professionnelle ?', '2026-08-28 19:05:47.730589+00'),
	('045aacdc-8486-467f-b077-a6883680f4b0', 'fr', 'Är ni huvudman för förskoleklass eller grundskola?', 'Êtes-vous responsable d''une classe préscolaire ou d''une école obligatoire ?', '2026-08-28 19:05:47.730589+00'),
	('3bd86f7b-3773-42d7-bd98-840621a4dc91', 'fr', 'Är organisationen registrerad i EU:s deltagarregister?', 'L''organisation est-elle enregistrée dans le registre des participants de l''UE ?', '2026-08-28 19:05:47.730589+00'),
	('01b1173f-2144-42a7-8824-614728a5e890', 'fr', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Le projet est-il un projet de cinéma (court métrage ou documentaire) ?', '2026-08-28 19:05:47.730589+00'),
	('956f86d5-f061-41f2-9ac9-25d417b0e75a', 'fr', 'Är projektet ett konst- eller kulturprojekt?', 'Le projet est-il un projet artistique ou culturel ?', '2026-08-28 19:05:47.730589+00'),
	('b8958cca-c4b6-4da8-a4aa-0adf627872e8', 'fr', 'Är projektet ett kulturprojekt?', 'Le projet est-il un projet culturel ?', '2026-08-28 19:05:47.730589+00'),
	('b9be05f9-0ab1-4e7b-8978-11bd922872ad', 'fr', 'Är projektet ett musikprojekt?', 'Le projet est-il un projet musical ?', '2026-08-28 19:05:47.730589+00'),
	('d5d5da73-64ff-41e0-b95f-b900dc917b36', 'fr', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Le projet est-il novateur — quelque chose que vous ne faites pas déjà dans votre activité ordinaire ?', '2026-08-28 19:05:47.730589+00'),
	('eb92c038-d04a-41fe-a0a6-1edac2d171e9', 'fr', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Le projet profite-t-il au territoire dans son ensemble (pas à des particuliers) ?', '2026-08-28 19:05:47.730589+00'),
	('469319b0-c103-47f4-8e7e-487089fd8a7d', 'fr', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Le trajet entre le domicile et le lycée fait-il au moins six kilomètres ?', '2026-08-28 19:05:47.730589+00'),
	('fa04621a-f193-49fb-922a-6b0abb603a38', 'fr', 'Är verksamheten professionell (inte amatörverksamhet)?', 'L''activité est-elle professionnelle (pas amateur) ?', '2026-08-28 19:05:47.730589+00'),
	('3d49eab5-2d6a-4638-af0c-51bcbe717f57', 'fr', 'Är verksamheten professionell?', 'L''activité est-elle professionnelle ?', '2026-08-28 19:05:47.730589+00'),
	('45ca03d0-0437-4088-8af9-ddce980f91e6', 'fr', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'L''activité relève-t-elle des arts de la scène (danse, théâtre, théâtre musical) ?', '2026-08-28 19:05:47.730589+00'),
	('7071a48c-418c-4954-8e87-c682dc9de77d', 'fr', 'Är volontärerna mellan 18 och 30 år?', 'Les volontaires ont-ils entre 18 et 30 ans ?', '2026-08-28 19:05:47.730589+00'),
	('534577ef-71b6-4061-88da-9d24b8582018', 'ar', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'دعم أنشطة للأندية الرياضية التي تقدم أنشطة بقيادة مدربين للأطفال والشباب من 7 إلى 25 عامًا.', '2026-08-28 19:05:47.73637+00'),
	('821b4ec9-b1d0-414a-95cf-b5a01088e2de', 'ar', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'إضافة تلقائية إلى علاوة الأطفال (barnbidrag) اعتبارًا من الطفل الثاني.', '2026-08-28 19:05:47.73637+00'),
	('595e0bf2-e6cd-4531-80c1-21b1966908ea', 'ar', 'Avser ansökan en fysisk investering?', 'هل يتعلق الطلب باستثمار مادي؟', '2026-08-28 19:05:47.73637+00'),
	('57748fcc-d3d6-48d3-ad38-b5da28f90783', 'ar', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'هل يتعلق الطلب برحلة أو تبادل دولي؟', '2026-08-28 19:05:47.73637+00'),
	('fa884f67-f34d-4923-9851-2e0201c68cb2', 'ar', 'Avser ansökan en investering i byggnader eller maskiner?', 'هل يتعلق الطلب باستثمار في مبانٍ أو آلات؟', '2026-08-28 19:05:47.73637+00'),
	('c843621c-92bd-4883-95b5-5e2f0fe2fc23', 'ar', 'Avser ansökan en redan utgiven titel?', 'هل يتعلق الطلب بعنوان منشور بالفعل؟', '2026-08-28 19:05:47.73637+00'),
	('9bd8f0b2-91fb-42e4-9375-0796a9235dda', 'ar', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'هل يتعلق الطلب بمنشأة زراعية أو بستانية أو لتربية الرنة؟', '2026-08-28 19:05:47.73637+00'),
	('732ae696-4e6c-4e3b-a646-c8445a605133', 'ar', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'هل يتعلق الطلب بشراء كتب للمكتبات العامة أو المدرسية؟', '2026-08-28 19:05:47.73637+00'),
	('77b8ad3f-f355-42b1-ab98-8fe5e8cd4183', 'ar', 'Avser investeringen jordbruksverksamhet?', 'هل يتعلق الاستثمار بنشاط زراعي؟', '2026-08-28 19:05:47.73637+00'),
	('d116beef-bd76-45c7-ba8c-d18d0660a248', 'ar', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'هل يهدف المشروع إلى بناء أو شراء أو ترميم مقر؟', '2026-08-28 19:05:47.73637+00'),
	('3c015f14-e194-4bb9-862e-15fc4ff909e9', 'ar', 'Avser projektet naturvård eller friluftsliv?', 'هل يتعلق المشروع بحماية الطبيعة أو الأنشطة في الهواء الطلق؟', '2026-08-28 19:05:47.73637+00'),
	('01b4f805-1ff8-4eac-a6fa-b326243a5061', 'ar', 'Avser projektet skola eller vuxenutbildning?', 'هل يتعلق المشروع بالمدرسة أو تعليم الكبار؟', '2026-08-28 19:05:47.73637+00'),
	('dc068357-5e47-4ec0-ac27-7cb2412ca022', 'ar', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'هل تمتنع عن العمل لرعاية قريب أو البقاء بجانبه لأنه مريض بشدة لدرجة أن المرض يهدد حياته؟', '2026-08-28 19:05:47.73637+00'),
	('472b3673-a222-4ff8-a8b1-ec51b4e1f892', 'ar', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'هل تمارس الجمعية نشاطًا منتظمًا في البلدية؟', '2026-08-28 19:05:47.73637+00'),
	('5bb6a196-9557-45c3-9d6e-6a996e63febb', 'ar', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'هل تقدّر أن قدرتك على العمل منخفضة لمدة سنة على الأقل بسبب مرض أو إعاقة؟', '2026-08-28 19:05:47.73637+00'),
	('722ee4d5-65d4-48a2-bc6a-e9f1734191ab', 'ar', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'دعم خاضع لتقييم الحاجة لمن لديه معاش منخفض أو لا معاش له ويحتاج إلى مساعدة للوصول إلى مستوى معيشة معقول.', '2026-08-28 19:05:47.73637+00'),
	('4696a0f3-e0a3-4772-a513-6026cee88df5', 'ar', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'هل يحتاج الطفل إلى السكن في بلدة الدراسة (إقامة) لأن الطريق طويل جدًا؟', '2026-08-28 19:05:47.73637+00'),
	('51673d1c-0936-46fc-a456-dd0553003669', 'ar', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'هل يحتاج المسكن إلى تكييف (مثل منحدر أو فاتح أبواب أو حمّام)؟', '2026-08-28 19:05:47.73637+00'),
	('3a251ab0-1ba0-4875-80ea-14c8ba687969', 'ar', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'هل يحتاج أحد أطفالك بين 8 و19 عامًا إلى نظارات أو عدسات؟', '2026-08-28 19:05:47.73637+00'),
	('68d5597c-614e-434d-aa51-d30aee8d5759', 'ar', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'هل لا يدفع الوالد الآخر شيئًا أو يدفع أقل من النفقة الكاملة؟', '2026-08-28 19:05:47.73637+00'),
	('7832e25f-41ea-4049-a94a-4ea81fe701be', 'ar', 'Betalar du hyra eller andra boendekostnader?', 'هل تدفع إيجارًا أو تكاليف سكن أخرى؟', '2026-08-28 19:05:47.73637+00'),
	('1c93f4e8-039b-4a46-9a41-ea13d8d77760', 'ar', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'إعانة لتكييف المسكن عند وجود إعاقة — مثل المنحدرات أو فاتحات الأبواب أو تكييف الحمّام.', '2026-08-28 19:05:47.73637+00'),
	('b92d07f0-8e5f-40af-a142-fc883d9d393a', 'ar', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'إعانات لبناء أو شراء أو ترميم قاعات الاجتماعات العامة.', '2026-08-28 19:05:47.73637+00'),
	('34dfcef9-07d0-45a3-98ca-427ea2875093', 'ar', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'إعانة لشراء سيارة أو تكييفها عندما تجعل إعاقة دائمة التنقل أو استخدام المواصلات العامة صعبًا جدًا.', '2026-08-28 19:05:47.73637+00'),
	('1632e012-6a12-4676-a7a6-db84bd6cca93', 'ar', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'إعانات للسفر والتبادل الدولي للعاملين المحترفين في المجال الثقافي.', '2026-08-28 19:05:47.73637+00'),
	('881206c7-ab79-4912-9d9a-66608ae0b93f', 'ar', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'إعانات لتبادلات الفنانين المحترفين الدولية وسفرهم وإقاماتهم للعمل.', '2026-08-28 19:05:47.73637+00'),
	('cf8bae30-9a2e-4b9b-b2e6-51a347f5e83d', 'ar', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'إعانة وقرض اختياري للدراسة في المرحلة الثانوية أو ما بعد الثانوية.', '2026-08-28 19:05:47.73637+00'),
	('9aa06e19-1b7c-4f38-8f73-0930de2813ad', 'ar', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'إعانات وقروض للدراسة في الخارج، مع قروض إضافية لتغطية مثل رسوم الدراسة والسفر.', '2026-08-28 19:05:47.73637+00'),
	('05b527e8-a187-4f19-b24e-d4b231516888', 'ar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'إعانة تساعد الجهات السويدية على إعداد طلبات لبرامج الاتحاد الأوروبي مثل Horisont Europa.', '2026-08-28 19:05:47.73637+00'),
	('22b39620-e77b-4d7a-b15a-3d0533ca7ecd', 'ar', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'إعانة لأصحاب العمل الذين يوظفون أشخاصًا ذوي قدرة منخفضة على العمل.', '2026-08-28 19:05:47.73637+00');
INSERT INTO public.kb_translations VALUES
	('5be6b1d7-d779-46aa-8507-bf0a9aa755d6', 'ar', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'إعانة للسكن ورحلات العودة إلى المنزل عندما يضطر طالب ثانوي للسكن في بلدة الدراسة بسبب طول الطريق.', '2026-08-28 19:05:47.73637+00'),
	('28db3e68-5f92-4b92-8776-e9a3e422ae59', 'ar', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'إعانات لعمل المنظمات غير الربحية في الحفاظ على التراث الثقافي واستخدامه وتطويره.', '2026-08-28 19:05:47.73637+00'),
	('2b3a0b30-4a6c-4a6f-8b6b-75f230222db7', 'ar', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'إعانات لمشاريع حماية الطبيعة البلدية والمحلية، بما في ذلك الأراضي الرطبة والأنشطة في الهواء الطلق.', '2026-08-28 19:05:47.73637+00'),
	('dc5040c9-b3e6-4ee4-8c35-dbe58c37e40e', 'ar', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'إعانات للبلديات لشراء الكتب للمكتبات العامة والمدرسية.', '2026-08-28 19:05:47.73637+00'),
	('f6e3f329-d241-4b3a-b968-b93ef925b3fe', 'ar', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'إعانات للجهات المسؤولة عن المدارس ليلتقي تلاميذ المرحلة الأساسية بالثقافة الاحترافية.', '2026-08-28 19:05:47.73637+00'),
	('da052117-0dd7-4556-83fb-7fe8a28a72a5', 'ar', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'إعانة لما يحتاجه طفلك ولا تكفي ميزانية الأسرة لتغطيته: أنشطة ترفيهية، ملابس، رحلات مدرسية، نظارات، أنشطة العطل وغيرها.', '2026-08-28 19:05:47.73637+00'),
	('6846d871-316d-40d4-806f-8e2417e11404', 'ar', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'إعانات من صناديق مثل Världens Barn وMusikhjälpen وVictoriafonden — تطلبها منظمات سويدية غير ربحية لديها 90-konto.', '2026-08-28 19:05:47.73637+00'),
	('b0b51bb6-6a8a-42b7-8ceb-d63ca86dff25', 'ar', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'إعانات من أموال الطاقة الكهرومائية وطاقة الرياح لمشاريع تنمّي المنطقة.', '2026-08-28 19:05:47.73637+00'),
	('20cbd6f4-93b5-479d-8b38-881df5f6f368', 'ar', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'إعانة دون جزء قرضي للعاطلين عن العمل بين 25 و60 عامًا ذوي التعليم القصير الذين يحتاجون إلى الدراسة في مستوى المدرسة الأساسية أو الثانوية.', '2026-08-28 19:05:47.73637+00'),
	('c25d1ae9-66e9-4309-819e-aabc0028c0fe', 'ar', 'Bidrar projektet till energiomställningen?', 'هل يساهم المشروع في التحول الطاقي؟', '2026-08-28 19:05:47.73637+00'),
	('abf20e20-f2e5-4cdf-a389-5147710b023d', 'ar', 'Bor du och barnets andra förälder på skilda håll?', 'هل تعيش أنت والوالد الآخر للطفل منفصلين؟', '2026-08-28 19:05:47.73637+00'),
	('5aba7cd4-cbfe-4282-8c40-8a5f28d373e4', 'ar', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'شيكات للشركات الصغيرة لجلب خبرات خارجية في التدويل أو الرقمنة.', '2026-08-28 19:05:47.73637+00'),
	('b1cc0c0a-d126-48ea-864c-e9506e2a21c0', 'ar', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'هل تشارك في برنامج لدى Arbetsförmedlingen (مثل jobb- och utvecklingsgarantin)؟', '2026-08-28 19:05:47.73637+00'),
	('7ce455e4-0966-4e49-aafb-936ca50147c6', 'ar', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'دعم لاحق لدور النشر مقابل نشر أدب ذي جودة.', '2026-08-28 19:05:47.73637+00'),
	('47d17d9a-200f-4783-8520-0e6aec94f702', 'ar', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'دعم اقتصادي لمن لديه تصريح إقامة مرتبط بالحماية ويرغب طوعًا في العودة نهائيًا إلى بلده الأصلي.', '2026-08-28 19:05:47.73637+00'),
	('350461bf-2e2b-4bd4-9753-3b7c4dcbd936', 'ar', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'دعم اقتصادي لأصحاب العمل الذين يوظفون شخصًا غاب طويلًا عن الحياة العملية.', '2026-08-28 19:05:47.73637+00'),
	('8e1e3ffa-f716-462d-a843-3da0f5fec846', 'ar', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'دعم اقتصادي خلال مرحلة البدء للباحثين عن عمل الذين يؤسسون شركتهم الخاصة.', '2026-08-28 19:05:47.73637+00'),
	('7bd4c1a6-5195-4e8d-ad0d-0c7702b03754', 'ar', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'تفتح Energimyndigheten باستمرار دعوات في أبحاث الطاقة والابتكار وكفاءة الطاقة.', '2026-08-28 19:05:47.73637+00'),
	('cbec1caf-0412-461b-99bd-47ba53af7fe9', 'ar', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'تعويض عن التغيب عن العمل أو الدراسة لرعاية طفل.', '2026-08-28 19:05:47.73637+00'),
	('2f52fa13-3637-4fc2-8dcc-a42279ebf426', 'ar', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'تعويض لمن هو جديد في السويد ويشارك في برنامج التأسيس لدى Arbetsförmedlingen؛ تدفعه Försäkringskassan.', '2026-08-28 19:05:47.73637+00'),
	('1124c656-85ce-4e70-afe6-41a28d755310', 'ar', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'تعويض يغطي جزءًا من تكلفة السكن للشباب دون أطفال ذوي الدخل المنخفض.', '2026-08-28 19:05:47.73637+00'),
	('6248ec82-cfe1-490d-ba5f-eee0f66b9992', 'ar', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'تعويض عن التكاليف الإضافية التي تسببها إعاقة دائمة — للبالغين أو لأهل الأطفال ذوي الإعاقة.', '2026-08-28 19:05:47.73637+00'),
	('f2f03fe1-077d-4baf-b4ff-69174ce19d1a', 'ar', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'تعويض للشباب (19–29 عامًا) الذين لا يستطيعون العمل بدوام كامل لمدة سنة على الأقل بسبب مرض أو إعاقة.', '2026-08-28 19:05:47.73637+00'),
	('54439e3a-a4b4-45c8-97a5-e7d9d6da2dc2', 'ar', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'تعويض عندما تكون القدرة على العمل منخفضة بشكل دائم — ما كان يسمى سابقًا förtidspension (التقاعد المبكر).', '2026-08-28 19:05:47.73637+00'),
	('6853da4b-6c43-4cbb-b9e9-bff62922b388', 'ar', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'تعويض عندما تمتنع عن العمل لتكون بجانب قريب مريض بشدة.', '2026-08-28 19:05:47.73637+00'),
	('a222f6f5-00f5-4d46-9109-b25890c9d24a', 'ar', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'تعويض عند مشاركتك في برنامج لسياسة سوق العمل لدى Arbetsförmedlingen.', '2026-08-28 19:05:47.73637+00'),
	('a0e30cb7-c4bb-4749-8a1e-4c7b172404da', 'ar', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'تعويض عندما لا تستطيع العمل كالمعتاد بسبب المرض.', '2026-08-28 19:05:47.73637+00'),
	('6f043f94-040b-4a79-9979-3478563fe31f', 'ar', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'تعويض عندما تبقى في المنزل عن العمل لرعاية طفل مريض.', '2026-08-28 19:05:47.73637+00'),
	('e781c143-5566-4444-b9a0-a739810d2cc0', 'ar', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'تعويض يغطي جزءًا من تكلفة السكن للأسر التي لديها أطفال ودخل أقل.', '2026-08-28 19:05:47.73637+00'),
	('045ef105-6444-41f2-b8ac-7c721f758827', 'ar', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'تعويض للوالدين الذين يحتاج أطفالهم بسبب الإعاقة إلى رعاية وإشراف أكثر من أطفال في نفس العمر.', '2026-08-28 19:05:47.73637+00'),
	('6a055620-4b93-4614-b500-2c76cace10a2', 'ar', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'تعويض عند البطالة — على أساس الدخل للأعضاء، ومبلغ أساسي لغيرهم.', '2026-08-28 19:05:47.73637+00'),
	('89e5da0f-a935-4000-aa60-db3b56763b48', 'ar', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'نحو خمسين مؤسسة لبنوك الادخار تمنح إعانات لمشاريع محلية في الرياضة والثقافة والتعليم وتنمية المجتمع — في منطقة نشاط البنك.', '2026-08-28 19:05:47.73637+00'),
	('bda175f3-cd79-4b96-9bf3-b7c8472a5ded', 'ar', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'دعم مشاريع ممول من الاتحاد الأوروبي يُطلب لدى منطقة Leader المحلية — للجمعيات والشركات والبلديات التي تنمّي الريف.', '2026-08-28 19:05:47.73637+00'),
	('6d18ea22-aa2b-4283-a260-60062e678173', 'ar', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'دعم ممول من الاتحاد الأوروبي للباحثين عن عمل الذين يقبلون وظيفة في بلد آخر من الاتحاد الأوروبي/المنطقة الاقتصادية الأوروبية: تعويض عن سفر المقابلة وتكاليف الانتقال ودورة لغة.', '2026-08-28 19:05:47.73637+00'),
	('7bfe739f-c78d-4969-820b-d1905aa674ec', 'ar', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'أموال من الصندوق الاجتماعي الأوروبي لمشاريع تعزز الكفاءات والتحول والإدماج في سوق العمل.', '2026-08-28 19:05:47.73637+00'),
	('ef535118-fe5f-49e6-a52a-b250b310aeda', 'ar', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'دعم من الاتحاد الأوروبي لتبادلات جماعية للشباب من 13 إلى 30 عامًا، لمدة 5 إلى 21 يومًا دون أيام السفر.', '2026-08-28 19:05:47.73637+00'),
	('be561343-2b66-4674-8a94-ea7b060bac80', 'ar', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'دعم من الاتحاد الأوروبي لمشاريع تعاون المنظمات الثقافية مع شركاء في عدة بلدان أوروبية.', '2026-08-28 19:05:47.73637+00'),
	('26b4b1b4-6fbe-47b4-8f5f-136ec81d2091', 'ar', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'دعم من الاتحاد الأوروبي للمنظمات التي تستقبل أو ترسل متطوعين شبابًا من 18 إلى 30 عامًا.', '2026-08-28 19:05:47.73637+00'),
	('08e7d8b8-1c4a-4475-9df6-ac6a40e6d80d', 'ar', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'دعم من الاتحاد الأوروبي لتنقل العاملين والتلاميذ في المدرسة وتعليم الكبار.', '2026-08-28 19:05:47.73637+00'),
	('f36b9001-246e-4a0c-b39d-2c41356e3686', 'ar', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'دعم من الاتحاد الأوروبي بمبالغ مقطوعة لأول مشاريع تعاون أوروبية للمنظمات الصغيرة.', '2026-08-28 19:05:47.73637+00'),
	('e129c993-cc26-4217-990d-0d440f1f38a6', 'ar', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تمويل للشركات الفتية التي تطور منتجات أو خدمات مبتكرة ذات إمكانات دولية.', '2026-08-28 19:05:47.73637+00'),
	('17574acc-5d37-4630-a33a-4a51439d4b02', 'ar', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'هل يوجد بنك ادخار (وبالتالي مؤسسة بنك ادخار) حيث تمارسون نشاطكم؟', '2026-08-28 19:05:47.73637+00'),
	('e1287c41-928a-4dfc-bb8e-642182a4c305', 'prs', 'Kan projektets miljönytta mätas?', 'آیا فایده محیط‌زیستی پروژه قابل اندازه‌گیری است؟', '2026-08-28 19:05:47.755665+00'),
	('ee4c16a6-5b7f-4385-975b-169acd7069ab', 'ar', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'إعانات تشغيل متعددة السنوات للفرق المستقلة المحترفة في الرقص والمسرح والمسرح الموسيقي.', '2026-08-28 19:05:47.73637+00'),
	('3213d0af-5b52-4e30-8605-2251fa4330ee', 'ar', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'إعانات بحثية في مجالات Forte: الصحة والحياة العملية والرفاه. يطلبها باحثون حاصلون على الدكتوراه في الجامعات السويدية.', '2026-08-28 19:05:47.73637+00'),
	('2da07e9b-6669-4283-96c2-c13522b3a4f8', 'ar', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'تمويل بحثي للبحث الأساسي الحر في جميع المجالات العلمية.', '2026-08-28 19:05:47.73637+00'),
	('502b7e2b-a41c-49d1-aa70-60ee3c3fc26f', 'ar', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'تمويل بحثي في البيئة والعلوم الزراعية والتخطيط العمراني.', '2026-08-28 19:05:47.73637+00'),
	('eda92878-4551-4a74-9554-f1e2d3921d15', 'ar', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'هل تفكر في الانتقال إلى الخارج (للعمل أو الدراسة أو العودة إلى الوطن)؟', '2026-08-28 19:05:47.73637+00'),
	('e45ce858-4e79-49be-ac05-5ae8da4b3914', 'ar', 'Genomförs insatserna av professionella kulturaktörer?', 'هل ينفذ الأنشطة فاعلون ثقافيون محترفون؟', '2026-08-28 19:05:47.73637+00'),
	('23eaefbd-2393-4ad1-ad44-4528f6a83d9c', 'ar', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'هل يُنفذ المشروع في الريف أو في بلدة صغيرة؟', '2026-08-28 19:05:47.73637+00');
INSERT INTO public.kb_translations VALUES
	('92ec1ffc-76b1-4284-8982-2a1e29e2e60c', 'ar', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حماية أساسية لمن كان دخله من العمل قليلًا أو معدومًا خلال حياته.', '2026-08-28 19:05:47.73637+00'),
	('3bb2d494-6829-45a1-8999-d3d371b6a6cc', 'ar', 'Går något av dina barn i grundskolan?', 'هل يذهب أحد أطفالك إلى المدرسة الأساسية؟', '2026-08-28 19:05:47.73637+00'),
	('6585899d-445b-44ed-924b-25c5bfdb9280', 'ar', 'Går något av dina barn på gymnasiet?', 'هل يدرس أحد أطفالك في الثانوية؟', '2026-08-28 19:05:47.73637+00'),
	('d47f5f35-07c5-4d96-80fe-5872815b4eee', 'ar', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'هل يتعلق التوظيف بشخص ذي قدرة منخفضة على العمل؟', '2026-08-28 19:05:47.73637+00'),
	('57f667cb-6c2b-4de9-95b9-bed9e6e1eb1e', 'ar', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'هل يتعلق التوظيف بشخص كان عاطلًا طويلًا أو جديدًا في السويد؟', '2026-08-28 19:05:47.73637+00'),
	('966f26c5-656b-44cd-9d84-00e16a2baa35', 'ar', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'هل يدور المشروع حول الحفاظ على التراث الثقافي أو إتاحته؟', '2026-08-28 19:05:47.73637+00'),
	('5d73f007-cdc6-43ca-a806-36b55a4ed4a1', 'ar', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'هل يدور المشروع حول الطاقة أو كفاءة الطاقة أو الابتكار المتعلق بالطاقة؟', '2026-08-28 19:05:47.73637+00'),
	('acd79afb-8228-42ce-b99e-cb2c89629a49', 'ar', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'هل يدور المشروع حول الصحة أو الحياة العملية أو الرفاه؟', '2026-08-28 19:05:47.73637+00'),
	('b8433770-d2fa-4f2c-97cf-5907f03f9cdb', 'ar', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'هل يدور المشروع حول تطوير الكفاءات أو تدابير سوق العمل؟', '2026-08-28 19:05:47.73637+00'),
	('a17cd2e3-95c2-42dd-83ad-4662be45d324', 'ar', 'Handlar projektet om miljö- eller klimatåtgärder?', 'هل يدور المشروع حول تدابير بيئية أو مناخية؟', '2026-08-28 19:05:47.73637+00'),
	('94c621e8-f40e-4f76-82a7-2de83d843ef6', 'ar', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'هل طريق الطفل إلى المدرسة طويل أو خطر بسبب حركة المرور أو صعب لأسباب أخرى؟', '2026-08-28 19:05:47.73637+00'),
	('505d4bbe-22e5-40ab-95de-9d30218f9ad4', 'ar', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'هل عملت 16 ساعة أسبوعيًا على الأقل لمدة إجمالية لا تقل عن 8 سنوات؟', '2026-08-28 19:05:47.73637+00'),
	('94875213-bbf3-4728-925c-dfe2093dc35f', 'ar', 'Har du barn som bor hos dig, helt eller växelvis?', 'هل لديك أطفال يعيشون معك، كليًا أو بالتناوب؟', '2026-08-28 19:05:47.73637+00'),
	('95050410-9475-49a3-9696-8205e7132a15', 'ar', 'Har du barn som bor hos dig?', 'هل لديك أطفال يعيشون معك؟', '2026-08-28 19:05:47.73637+00'),
	('2bb42928-70e3-4523-8541-8854e45431d0', 'ar', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'هل لديك أو لدى طفلك إعاقة يُتوقع أن تستمر سنة على الأقل؟', '2026-08-28 19:05:47.73637+00'),
	('2fbfd91a-7b02-4790-be58-7ed05ded7cb2', 'ar', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'هل لديك أو لدى أحد في الأسرة إعاقة دائمة تؤثر على السكن؟', '2026-08-28 19:05:47.73637+00'),
	('502d3b17-e98b-46b3-be8a-0dad82261ff3', 'ar', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'هل لديك أو لدى قريب مقرب إعاقة أو مرض طويل الأمد أو خطير؟', '2026-08-28 19:05:47.73637+00'),
	('4df4893a-cf92-4466-904a-6f55990f7070', 'ar', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'هل لديك مرض أو إصابة تحدّ حاليًا من قدرتك على العمل؟', '2026-08-28 19:05:47.73637+00'),
	('f834eb18-4284-4334-9858-3613e7adba0a', 'ar', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'هل واجهت يومًا صعوبة في دفع تكلفة رحلة مدرسية أو رحلة صف أو نشاط ترفيهي يُتوقع أن يشارك فيه طفلك؟', '2026-08-28 19:05:47.73637+00'),
	('c787a0dc-b242-4c52-93ff-3622be7dd715', 'ar', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'هل يصعب عليك تدبير أمورك بمعاشك ودخلك الآخر؟', '2026-08-28 19:05:47.73637+00'),
	('d8642c37-b2c1-497d-b262-74ad29519272', 'ar', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'هل حصلت في السنوات الأخيرة على تصريح إقامة في السويد، مثلًا كشخص بحاجة إلى حماية أو كقريب؟', '2026-08-28 19:05:47.73637+00'),
	('da2b3a5f-7104-43f5-a154-60b41874ccf9', 'ar', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'هل لديك تصريح إقامة في السويد كلاجئ أو شخص بحاجة إلى حماية (أو أنت قريب مقرب لشخص لديه ذلك)؟', '2026-08-28 19:05:47.73637+00'),
	('612acb2c-9ad0-455e-809f-a9d8e78ea632', 'ar', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'هل بلغت السن المرجعية للتقاعد (67 عامًا في 2026)؟', '2026-08-28 19:05:47.73637+00'),
	('ca58a13b-844b-43d2-bed8-0f493dce2bbf', 'ar', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'هل لدى منظمتكم OID (Organisation ID) مسجل في Organisation Registration System التابع للاتحاد الأوروبي؟', '2026-08-28 19:05:47.73637+00'),
	('7e1054e7-ff73-4f44-8dba-f80a6053df29', 'ar', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'هل تسببت الإعاقة في تكاليف إضافية — مثل الوسائل المساعدة أو التنقل أو نظام غذائي خاص أو الاستهلاك؟', '2026-08-28 19:05:47.73637+00'),
	('8ec2d009-2acc-4358-a06a-e6f0abf25a02', 'ar', 'Har föreningen antagna stadgar och en vald styrelse?', 'هل لدى الجمعية نظام أساسي معتمد ومجلس إدارة منتخب؟', '2026-08-28 19:05:47.73637+00'),
	('91e3e869-e8ab-4aa1-9afb-136c994a0508', 'ar', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'هل لدى الجمعية بنية ديمقراطية (نظام أساسي، اجتماع سنوي، مجلس إدارة)؟', '2026-08-28 19:05:47.73637+00'),
	('dfef7c66-8412-420d-9674-44b88a6280fc', 'ar', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'هل تمارس الجمعية نشاطًا منتظمًا للأطفال أو الشباب؟', '2026-08-28 19:05:47.73637+00'),
	('6cdc9bfd-6749-4fb6-b0f9-538f20bc76ff', 'ar', 'Har företaget mellan cirka 2 och 49 anställda?', 'هل لدى الشركة ما بين حوالي 2 و49 موظفًا؟', '2026-08-28 19:05:47.73637+00'),
	('07620d15-6ab0-412b-8c13-e65069aea467', 'ar', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'هل تجد الأسرة صعوبة في تغطية تكاليف الطعام والسكن وأبسط الضروريات؟', '2026-08-28 19:05:47.73637+00'),
	('d6c794cb-a976-4f19-ad97-7c82ddec93bc', 'ar', 'Har lösningen internationell potential?', 'هل للحل إمكانات دولية؟', '2026-08-28 19:05:47.73637+00'),
	('bd6080e1-78e1-4caa-ac74-7b03ebd38612', 'ar', 'Har ni en partnergrupp i ett annat land?', 'هل لديكم مجموعة شريكة في بلد آخر؟', '2026-08-28 19:05:47.73637+00'),
	('e0bfd48a-c10b-4bbc-8740-7e7067d10e30', 'ar', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'هل لديكم منظمة شريكة في بلد أوروبي آخر؟', '2026-08-28 19:05:47.73637+00'),
	('143ad443-cfe5-4b1c-994f-281817d9ff2d', 'ar', 'Har ni partner i minst tre olika europeiska länder?', 'هل لديكم شركاء في ثلاثة بلدان أوروبية مختلفة على الأقل؟', '2026-08-28 19:05:47.73637+00'),
	('c705950d-318e-41db-85e6-99c12458ebc9', 'ar', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'هل مقركم أو نشاطكم الرئيسي في المنطقة التي تقدمون فيها الطلب؟', '2026-08-28 19:05:47.73637+00'),
	('eddf720f-3a97-4569-b6cf-dd01ee48deff', 'ar', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'هل لدى أحد أطفالك إعاقة تجعله يحتاج إلى رعاية أو إشراف أكثر من أطفال آخرين في نفس العمر؟', '2026-08-28 19:05:47.73637+00'),
	('3354b77d-27ce-48e5-a41e-46c7e54efefc', 'ar', 'Har organisationen en demokratisk uppbyggnad?', 'هل لدى المنظمة بنية ديمقراطية؟', '2026-08-28 19:05:47.73637+00'),
	('a49e65b7-c467-44d0-b81b-1ae85b40646e', 'ar', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'هل لدى المنظمة Quality Label (علامة الجودة)؟', '2026-08-28 19:05:47.73637+00'),
	('d695dd58-068e-4a8e-a7dd-ae8578ca5d1e', 'ar', 'Har organisationen ett 90-konto?', 'هل لدى المنظمة 90-konto؟', '2026-08-28 19:05:47.73637+00'),
	('32b24ab9-22b1-4e49-9380-3e4fbbc15dd4', 'ar', 'Har organisationen ett OID (Organisation ID)?', 'هل لدى المنظمة OID (Organisation ID)؟', '2026-08-28 19:05:47.73637+00'),
	('9295478d-3daf-48d4-8903-65b31ebbb155', 'ar', 'Har organisationen ett OID?', 'هل لدى المنظمة OID؟', '2026-08-28 19:05:47.73637+00'),
	('1241fcfa-20ca-4973-9b1e-cca379a4e97a', 'ar', 'Har organisationen medlemsföreningar i flera län?', 'هل لدى المنظمة جمعيات أعضاء في عدة محافظات؟', '2026-08-28 19:05:47.73637+00'),
	('7a1aead2-b673-4dd1-ae4c-6141887681d8', 'ar', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'هل لدى المنظمة مالية منظمة وبنية ديمقراطية؟', '2026-08-28 19:05:47.73637+00'),
	('a784ec6f-0d63-44e9-bff6-b5881f872ec3', 'ar', 'Har projektet en partner i ett annat land?', 'هل للمشروع شريك في بلد آخر؟', '2026-08-28 19:05:47.73637+00'),
	('9776e898-1c73-49d1-b296-504d664ae63c', 'ar', 'Har projektledaren doktorsexamen?', 'هل قائد المشروع حاصل على الدكتوراه؟', '2026-08-28 19:05:47.73637+00'),
	('76a84f60-902e-4505-bbb3-0c770d9634e9', 'ar', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'على بلدية السكن توفير التنقل اليومي بين المنزل والمدرسة الثانوية عندما يبلغ الطريق ستة كيلومترات على الأقل (مثل بطاقة حافلة).', '2026-08-28 19:05:47.73637+00'),
	('d0febe14-4782-4e66-b932-fb50da855a14', 'ar', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'هل أنت بصدد الحصول على أول مسكن خاص بك في السويد أو تجهيزه؟', '2026-08-28 19:05:47.73637+00'),
	('5ff96a3b-45e1-4e59-9672-f8b5ef6228d2', 'ar', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'هل يتضمن المشروع رحلة أو تبادلًا دوليًا؟', '2026-08-28 19:05:47.73637+00'),
	('efda66da-b9c5-4bdb-a82c-8ef6cba6d87a', 'ar', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'دعم استثماري للشركات في مناطق الدعم للمباني والآلات والتدريب.', '2026-08-28 19:05:47.73637+00'),
	('dfd74696-c904-4953-ad2a-0675548229d4', 'ar', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'دعم استثماري لتدابير تخفض انبعاثات غازات الدفيئة.', '2026-08-28 19:05:47.73637+00');
INSERT INTO public.kb_translations VALUES
	('83de9497-0ab9-4ae4-9084-b1b2fa9d98eb', 'ar', 'Kan projektets miljönytta mätas?', 'هل يمكن قياس الفائدة البيئية للمشروع؟', '2026-08-28 19:05:47.73637+00'),
	('9cd6ad1e-f35c-44c7-92f2-0b26a4e39891', 'ar', 'Kan åtgärdens utsläppsminskning beräknas?', 'هل يمكن حساب خفض الانبعاثات الناتج عن التدبير؟', '2026-08-28 19:05:47.73637+00'),
	('18c28581-abd6-46a1-9c14-b167d8f26635', 'ar', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'هل تستطيع المنظمة تحمّل التكاليف حتى صرف الدعم؟', '2026-08-28 19:05:47.73637+00'),
	('b72a20d0-de80-4028-a684-550fea7f0f52', 'ar', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'هل ستُستخدم الخبرات في نشاطك في السويد؟', '2026-08-28 19:05:47.73637+00'),
	('af8dc07c-923b-430e-9155-ae5ec7b2b673', 'ar', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'هل سيبدأ الاستثمار فقط بعد إرسال الطلب؟', '2026-08-28 19:05:47.73637+00'),
	('7ed21e48-bcf5-49c8-bc3e-6d9e3a8c03a1', 'ar', 'Kommer projektet människor i ert närområde till del?', 'هل يعود المشروع بالفائدة على الناس في منطقتكم؟', '2026-08-28 19:05:47.73637+00'),
	('7445e2f3-2161-4869-b28e-3b393f3fe676', 'ar', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'شبكة الأمان الاقتصادية الأخيرة للبلدية عندما لا يكفي الدخل لأبسط الضروريات.', '2026-08-28 19:05:47.73637+00'),
	('e925d003-69a3-4e93-b480-72f42495407b', 'ar', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'دعم البلديات الخاص للحياة الجمعوية المحلية: دعم النشاط عن كل جلسة، دعم المقرات، دعم البدء وغير ذلك.', '2026-08-28 19:05:47.73637+00'),
	('e3b68b0b-0850-49ca-a909-54e452e27831', 'ar', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'نقل مدرسي مجاني لتلاميذ المدرسة الأساسية عند بعد المسافة أو خطورة الطريق أو الإعاقة — حق بموجب قانون المدرسة.', '2026-08-28 19:05:47.73637+00'),
	('e392bdcd-5155-4f72-814a-94cc03cca514', 'ar', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'إعانة قانونية للنظارات أو العدسات للأطفال والشباب؛ تختلف المبالغ والإجراءات حسب المنطقة — تحقق من مستوى منطقتك.', '2026-08-28 19:05:47.73637+00'),
	('63c815dd-ead6-41a0-b8d9-9f0336935c38', 'ar', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'دعم لتحول الصناعة نحو انبعاثات صفرية من غازات الدفيئة.', '2026-08-28 19:05:47.73637+00'),
	('ad055b55-b84e-4210-877e-c5257324f006', 'ar', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'هل يقع المشروع في منطقة معنية بالطاقة الكهرومائية أو طاقة الرياح؟', '2026-08-28 19:05:47.73637+00'),
	('241e9069-5917-43b5-9596-16ad523371b6', 'ar', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'هل يقع المشروع ضمن البيئة أو العلوم الزراعية أو التخطيط العمراني؟', '2026-08-28 19:05:47.73637+00'),
	('fb966e08-cadf-457e-90e4-d889239f8d4b', 'ar', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'هل يقع مكان النشاط في منطقة الدعم A أو B (أجزاء كبيرة من نورلاند وسفيالاند الداخلية)؟', '2026-08-28 19:05:47.73637+00'),
	('a576e2d9-9e76-4901-9ae8-73096ec6de2f', 'ar', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'قرض لشراء أبسط الضروريات لأول منزل في السويد — أثاث وأدوات منزلية وتجهيزات أساسية أخرى.', '2026-08-28 19:05:47.73637+00'),
	('a53fd91b-4962-4fab-a099-44f520ded841', 'ar', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'هل يخفض المشروع انبعاثات العمليات الصناعية أو ينشئ انبعاثات سالبة؟', '2026-08-28 19:05:47.73637+00'),
	('ad819eb0-839d-4d65-9f8a-004d98927a60', 'ar', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'علاوة شهرية للأطفال المقيمين في السويد، من الولادة حتى سن 16.', '2026-08-28 19:05:47.73637+00'),
	('4128a776-24c5-44ae-8b8b-85524a96d3f6', 'ar', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'تقدم Naturvårdsverket إعانات للمنظمات والشركات والجمعيات والقطاع العام والأفراد في مجال البيئة.', '2026-08-28 19:05:47.73637+00'),
	('e77d07ad-0b3a-4d3b-80c9-ab11f43beeaa', 'ar', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'هل تخطط للعودة طوعًا ونهائيًا إلى بلدك الأصلي؟', '2026-08-28 19:05:47.73637+00'),
	('aa0089d2-4604-43ce-aee0-7d7b83984974', 'ar', 'Planerar du att starta eget företag?', 'هل تخطط لتأسيس شركتك الخاصة؟', '2026-08-28 19:05:47.73637+00'),
	('ca544824-9e64-425b-a669-241a5059e509', 'ar', 'Planerar du att studera utomlands?', 'هل تخطط للدراسة في الخارج؟', '2026-08-28 19:05:47.73637+00'),
	('dd812dfc-d3d0-4c9f-9c3b-3314234aed2f', 'ar', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'هل تخطط لدراسة تقوي وضعك في سوق العمل؟', '2026-08-28 19:05:47.73637+00'),
	('1ac85b8e-feee-47d7-ae52-3f2a92a56917', 'ar', 'Planerar ni att anställa?', 'هل تخططون للتوظيف؟', '2026-08-28 19:05:47.73637+00'),
	('8a79b85f-345b-472d-9fe3-c51e6992af9e', 'ar', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'هل تخططون للتقدم إلى برنامج للاتحاد الأوروبي (مثل Horisont Europa)؟', '2026-08-28 19:05:47.73637+00'),
	('693b3094-b371-4007-935b-9a59c604657b', 'ar', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'دعم إنتاج وتطوير الأفلام القصيرة والوثائقية.', '2026-08-28 19:05:47.73637+00'),
	('f4df4465-00b4-4a6e-b3da-5c40d2b9217a', 'ar', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'إعانات مشاريع للمشهد الموسيقي الحر للحفلات والإنتاج والتطوير.', '2026-08-28 19:05:47.73637+00'),
	('f8caa632-be15-47de-97e3-f08dc446972f', 'ar', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'إعانات مشاريع للمنظمات غير الربحية العاملة مع الأطفال والشباب ولأجلهم.', '2026-08-28 19:05:47.73637+00'),
	('9b6019dc-8c7b-4f4c-91d8-320dd1a41fb9', 'ar', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'هل يجرب المشروع تعبيرات أو أساليب أو تعاونات فنية جديدة؟', '2026-08-28 19:05:47.73637+00'),
	('00e407bd-45ba-4421-96a3-d3468e3de887', 'ar', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'هل يستمر التبادل من 5 إلى 21 يومًا (دون أيام السفر)؟', '2026-08-28 19:05:47.73637+00'),
	('b3169792-78d8-4ddf-8649-4f679531b36e', 'ar', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'دعم المناطق الخاص لمشاريع وأنشطة الحياة الثقافية، إلى جانب إعانات Kulturrådet الوطنية.', '2026-08-28 19:05:47.73637+00'),
	('c9068dee-7b6d-4702-b7a8-242976c5cfc4', 'ar', 'Riktar sig projektet till barn eller unga?', 'هل يستهدف المشروع الأطفال أو الشباب؟', '2026-08-28 19:05:47.73637+00'),
	('7f3890c0-68ff-401e-a551-98ed5c354d36', 'ar', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'هل يستهدف المشروع الأطفال أو الشباب أو كبار السن أو ذوي الإعاقة؟', '2026-08-28 19:05:47.73637+00'),
	('1d33c1b9-e24d-4540-aa49-c3eb74f20792', 'ar', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'هل يستهدف النشاط الأطفال والشباب (7–25 عامًا)؟', '2026-08-28 19:05:47.73637+00'),
	('452f0f7d-9ced-494a-98d9-ac1e69a4a559', 'ar', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'هل تفتقر إلى مدخرات أو أصول يمكن أن تغطي النفقات؟', '2026-08-28 19:05:47.73637+00'),
	('3e279c95-450d-4471-86f9-a868888b4b63', 'ar', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'هل تتعاونون مع شركاء في بلدين شماليين آخرين على الأقل؟', '2026-08-28 19:05:47.73637+00'),
	('1587408f-0da9-44c4-a6e0-d93b6f00e29d', 'ar', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'هل ستجلبون خبرات خارجية لإجراء تطويري؟', '2026-08-28 19:05:47.73637+00'),
	('8b5f19c5-5d50-46da-bb55-f2558dca72d3', 'ar', 'Sker mobiliteten till ett annat europeiskt land?', 'هل التنقل إلى بلد أوروبي آخر؟', '2026-08-28 19:05:47.73637+00'),
	('51b4adc2-baaa-40ba-89d7-bed93cd9b50c', 'ar', 'Startar du eller tar du över företaget för första gången?', 'هل تؤسس الشركة أو تتولاها لأول مرة؟', '2026-08-28 19:05:47.73637+00'),
	('319e4eaf-8b24-48f5-b601-8dbf09c16c51', 'ar', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'دعم بدء لمن هو في سن 40 أو أقل ويؤسس منشأة زراعية أو يتولاها.', '2026-08-28 19:05:47.73637+00'),
	('8ad2ef43-9e08-4c07-8739-dba15c352170', 'ar', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'منحة تتيح للفنانين المحترفين التركيز على عملهم الفني.', '2026-08-28 19:05:47.73637+00'),
	('2244ca29-38dd-48e1-888d-f75d7014a491', 'ar', 'Studerar du, eller planerar du att börja studera?', 'هل تدرس، أو تخطط لبدء الدراسة؟', '2026-08-28 19:05:47.73637+00'),
	('326d4772-a690-439b-92df-ed3a4efaf8d1', 'ar', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'دعم دراسي للبالغين العاملين الراغبين في التعلم لتقوية وضعهم في سوق العمل.', '2026-08-28 19:05:47.73637+00'),
	('5ec4dedd-f3b2-4488-b528-175a63665ef2', 'ar', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'دعم للاستثمارات التي تزيد القدرة التنافسية أو تقلل الأثر البيئي في المنشآت الزراعية.', '2026-08-28 19:05:47.73637+00'),
	('7247cead-28ed-4fba-8bf8-593a09e63664', 'ar', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'دعم عندما يعيش طفل معك ولا يدفع الوالد الآخر النفقة.', '2026-08-28 19:05:47.73637+00'),
	('883ee798-fcf0-4dc8-9db8-644743ecd217', 'ar', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'دعم لمشاريع المنظمات غير الربحية من أجل الناس والبيئة وعالم أفضل.', '2026-08-28 19:05:47.73637+00'),
	('2fb8feae-b05a-4f89-9a16-a681a41b4e68', 'ar', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'دعم لمشاريع الفنون والثقافة ذات البعد الشمالي والتعاون عبر الحدود.', '2026-08-28 19:05:47.73637+00'),
	('e89068ed-b9f8-49a5-bb1e-c2e188e15f67', 'ar', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'دعم للمشاريع الثقافية المبتكرة التي تجرب تعبيرات أو أساليب أو تعاونات فنية جديدة.', '2026-08-28 19:05:47.73637+00'),
	('d3383bed-76a0-43c6-a5f1-6ef353299b30', 'ar', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'دعم للمشاريع المبتكرة للأطفال والشباب وكبار السن وذوي الإعاقة.', '2026-08-28 19:05:47.73637+00'),
	('33c358ef-b5b8-40fe-ac47-6be52156a9bf', 'ar', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'دعم لمشاريع التعاون في المشهد الموسيقي الحر.', '2026-08-28 19:05:47.73637+00'),
	('b62caa5d-d348-42ea-8f50-53064caa49a0', 'ar', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'دعم لمشاريع التعاون في الثقافة والإعلام التي تعزز الديمقراطية وحرية التعبير دوليًا.', '2026-08-28 19:05:47.73637+00');
INSERT INTO public.kb_translations VALUES
	('429468b6-7242-4748-8e6a-219047d0cff6', 'ar', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'هل يهدف المشروع إلى تعزيز الديمقراطية أو المساواة أو حرية التعبير؟', '2026-08-28 19:05:47.73637+00'),
	('0d667e9e-c2e4-40bc-80f1-7b6e71ad5a2d', 'ar', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'هل تبحث عن عمل، أو حصلت على عرض عمل، في بلد آخر من الاتحاد الأوروبي أو المنطقة الاقتصادية الأوروبية؟', '2026-08-28 19:05:47.73637+00'),
	('82b82c48-66fc-4a68-bf9f-b08b5b6acea7', 'ar', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقف لما تدفعه من رسوم المرضى خلال فترة اثني عشر شهرًا — بعد ذلك frikort (بطاقة مجانية).', '2026-08-28 19:05:47.73637+00'),
	('f336a20e-cf83-4352-bed6-1224a03eeb89', 'ar', 'Tar du ut hel allmän pension?', 'هل تتقاضى معاشك العام كاملًا؟', '2026-08-28 19:05:47.73637+00'),
	('ae618580-9c67-459b-95ba-059b77cf9f32', 'ar', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'إضافة تغطي جزءًا من تكلفة السكن لمن لديه معاش ودخل منخفض.', '2026-08-28 19:05:47.73637+00'),
	('9e683ac4-160e-494c-a717-dabc34f356a7', 'ar', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'إعانة تنظيمية سنوية للمنظمات الوطنية للأطفال والشباب.', '2026-08-28 19:05:47.73637+00'),
	('8194ff26-9397-4822-ac06-59e5278230de', 'ar', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'رصيد سنوي يُخصم مباشرة عند طبيب الأسنان أو أخصائي صحة الأسنان.', '2026-08-28 19:05:47.73637+00'),
	('cfa0a005-9d89-4f96-8b71-5c75bc3fe061', 'ar', 'Är bolaget yngre än cirka 5 år?', 'هل عمر الشركة أقل من حوالي 5 سنوات؟', '2026-08-28 19:05:47.73637+00'),
	('6b7cc2b0-ff7e-40da-86e7-9a0dba7c1573', 'ar', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'هل أعمار المشاركين في التبادل بين 13 و30 عامًا؟', '2026-08-28 19:05:47.73637+00'),
	('cbd6cba4-5e99-49ab-b1d4-6272bae0d800', 'ar', 'Är det här ert första EU-projekt?', 'هل هذا أول مشروع اتحاد أوروبي لكم؟', '2026-08-28 19:05:47.73637+00'),
	('86f25e02-2df7-4e12-87e6-91c64003c929', 'ar', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'هل من الصعب جدًا عليك (أو على طفلك) التنقل بمفردك أو السفر بالحافلة والقطار؟', '2026-08-28 19:05:47.73637+00'),
	('1abbdcd4-2257-4053-a368-923512fffc95', 'ar', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'هل دخلك أقل من حوالي 25 000 كرونة شهريًا قبل الضريبة؟', '2026-08-28 19:05:47.73637+00'),
	('369d0b84-4a7f-45ce-a9f9-6a21e87ffdbc', 'ar', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'هل آخر تعليم أنهيته هو المدرسة الأساسية، أو ثانوية لم تكملها؟', '2026-08-28 19:05:47.73637+00'),
	('e0366117-ce45-4c81-8a82-30b64f0fe012', 'ar', 'Är du 40 år eller yngre?', 'هل عمرك 40 عامًا أو أقل؟', '2026-08-28 19:05:47.73637+00'),
	('547dc8ab-96e5-4e04-944f-fa9a7e889c3b', 'ar', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'هل أنت مسجل كباحث عن عمل لدى Arbetsförmedlingen؟', '2026-08-28 19:05:47.73637+00'),
	('9d3df5cc-581b-47e5-93ab-58bc82fe7ca9', 'ar', 'Är du mellan 18 och 28 år?', 'هل عمرك بين 18 و28 عامًا؟', '2026-08-28 19:05:47.73637+00'),
	('e8070f15-99ea-480b-85e2-14c9f3eafbcb', 'ar', 'Är du mellan 19 och 29 år?', 'هل عمرك بين 19 و29 عامًا؟', '2026-08-28 19:05:47.73637+00'),
	('8a062eb0-11b4-40e3-a872-77f15e2656a5', 'ar', 'Är du mellan 25 och 60 år?', 'هل عمرك بين 25 و60 عامًا؟', '2026-08-28 19:05:47.73637+00'),
	('5e8f0a01-f3a7-479d-a6ad-81f9cd81630a', 'ar', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'هل تعمل باحتراف في المجال الثقافي (مثل الرقص أو الموسيقى أو الفنون الأدائية)؟', '2026-08-28 19:05:47.73637+00'),
	('107d9541-a514-4d02-a0af-1655f1e0b923', 'ar', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'هل أنت فنان محترف (لست هاويًا ولست في التدريب الأساسي)؟', '2026-08-28 19:05:47.73637+00'),
	('8a915f06-6230-4202-a36d-b25fd990b913', 'ar', 'Är du yrkesverksam konstnär?', 'هل أنت فنان محترف؟', '2026-08-28 19:05:47.73637+00'),
	('8f5894f0-719e-4336-b126-41b5438c285a', 'ar', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'هل حلكم مبتكر جوهريًا مقارنة بما هو موجود بالفعل؟', '2026-08-28 19:05:47.740377+00'),
	('aef66884-ac99-4502-8641-64c242578ec9', 'ar', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'هل النادي منتسب إلى اتحاد رياضي متخصص ضمن Riksidrottsförbundet؟', '2026-08-28 19:05:47.740377+00'),
	('39efb425-6309-4336-889d-d3bd2b0f5d31', 'ar', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'هل دخل الأسرة منخفض مقارنة بتكلفة السكن؟', '2026-08-28 19:05:47.740377+00'),
	('a2637d98-54de-4fb2-81ec-b2feeae4eed6', 'ar', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'هل الدخل الإجمالي للأسرة أقل من حوالي 25 000 كرونة شهريًا قبل الضريبة؟', '2026-08-28 19:05:47.740377+00'),
	('9439cea4-5c3a-4091-8e7d-b08dd34643d9', 'ar', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'هل الإجراء مشروع محدد (وليس النشاط الاعتيادي)؟', '2026-08-28 19:05:47.740377+00'),
	('c675a2f1-2a51-4f9e-a9be-8c859d215340', 'ar', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'هل المقر مفتوح للجميع — وليس لأعضائكم فقط؟', '2026-08-28 19:05:47.740377+00'),
	('054c18e2-b482-4a7f-a7d6-975f9f912c03', 'ar', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'هل 60٪ على الأقل من الأعضاء بين 6 و25 عامًا؟', '2026-08-28 19:05:47.740377+00'),
	('19c4a1f0-133c-45a9-8b38-b5a81347268c', 'ar', 'Är minst 60 % av medlemmarna under 26 år?', 'هل 60٪ على الأقل من الأعضاء دون 26 عامًا؟', '2026-08-28 19:05:47.740377+00'),
	('ccc16395-6faf-41b2-ac4e-0ce588ba53b9', 'ar', 'Är målgruppen delaktig i planering och genomförande?', 'هل تشارك الفئة المستهدفة في التخطيط والتنفيذ؟', '2026-08-28 19:05:47.740377+00'),
	('8d9d08ed-65c4-43dc-83b9-b9a11bd87406', 'ar', 'Är ni ett förlag med professionell utgivning?', 'هل أنتم دار نشر ذات نشر احترافي؟', '2026-08-28 19:05:47.740377+00'),
	('117e6470-42c0-47c5-b3d1-2ed2be88f566', 'ar', 'Är ni huvudman för förskoleklass eller grundskola?', 'هل أنتم الجهة المسؤولة عن صف تمهيدي أو مدرسة أساسية؟', '2026-08-28 19:05:47.740377+00'),
	('d523c8e4-30a5-4e79-aec9-71e1c9861d73', 'ar', 'Är organisationen registrerad i EU:s deltagarregister?', 'هل المنظمة مسجلة في سجل المشاركين للاتحاد الأوروبي؟', '2026-08-28 19:05:47.740377+00'),
	('fa35a7df-1156-4f42-af7c-5c05ac14a2d1', 'ar', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'هل المشروع مشروع سينمائي (فيلم قصير أو وثائقي)؟', '2026-08-28 19:05:47.740377+00'),
	('9352d109-2119-4e5d-ad15-dc9ab531761d', 'ar', 'Är projektet ett konst- eller kulturprojekt?', 'هل المشروع مشروع فني أو ثقافي؟', '2026-08-28 19:05:47.740377+00'),
	('9a6a4389-8765-460c-a934-19b27e11ce51', 'ar', 'Är projektet ett kulturprojekt?', 'هل المشروع مشروع ثقافي؟', '2026-08-28 19:05:47.740377+00'),
	('a73bf7f1-53a3-41c5-9b23-89cc2ba4a08e', 'ar', 'Är projektet ett musikprojekt?', 'هل المشروع مشروع موسيقي؟', '2026-08-28 19:05:47.740377+00'),
	('947f031e-54e0-47b0-b15e-de68aefa26b8', 'ar', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'هل المشروع مبتكر — شيء لا تفعلونه بالفعل في نشاطكم الاعتيادي؟', '2026-08-28 19:05:47.740377+00'),
	('ffb9e38d-c5df-48bf-99dd-863cd7274406', 'ar', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'هل يفيد المشروع المنطقة ككل (وليس أفرادًا)؟', '2026-08-28 19:05:47.740377+00'),
	('a75c2132-fdbd-4255-aa5a-951e18f36486', 'ar', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'هل الطريق بين المنزل والمدرسة الثانوية ستة كيلومترات على الأقل؟', '2026-08-28 19:05:47.740377+00'),
	('83169dc4-c252-4609-a070-46a07bf751ff', 'ar', 'Är verksamheten professionell (inte amatörverksamhet)?', 'هل النشاط احترافي (وليس هاويًا)؟', '2026-08-28 19:05:47.740377+00'),
	('3a1f6dbd-5b6d-46c5-b2cb-e8de527f08ed', 'ar', 'Är verksamheten professionell?', 'هل النشاط احترافي؟', '2026-08-28 19:05:47.740377+00'),
	('a3ff55ad-c6ab-4591-8523-6afb92900e32', 'ar', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'هل النشاط فنون أدائية (رقص، مسرح، مسرح موسيقي)؟', '2026-08-28 19:05:47.740377+00'),
	('97ca8841-843d-45f3-a322-7bd19587350e', 'ar', 'Är volontärerna mellan 18 och 30 år?', 'هل أعمار المتطوعين بين 18 و30 عامًا؟', '2026-08-28 19:05:47.740377+00'),
	('2a4f2aea-983d-49d4-8e51-588f33eb3946', 'fa', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'حمایت از فعالیت باشگاه‌های ورزشی که فعالیت‌های زیر نظر مربی برای کودکان و جوانان ۷ تا ۲۵ ساله برگزار می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('5878de84-c380-43af-8379-2038b45968ba', 'fa', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'افزودنی خودکار به کمک‌هزینه فرزند (barnbidrag) از فرزند دوم به بعد.', '2026-08-28 19:05:47.746225+00'),
	('a758c267-a89a-4531-8ade-76f90f0235a3', 'fa', 'Avser ansökan en fysisk investering?', 'آیا درخواست مربوط به یک سرمایه‌گذاری فیزیکی است؟', '2026-08-28 19:05:47.746225+00'),
	('7596d153-3ef1-4dfc-bc07-944ec7db436e', 'fa', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'آیا درخواست مربوط به یک سفر یا تبادل بین‌المللی است؟', '2026-08-28 19:05:47.746225+00'),
	('2a741bde-3ac1-4249-93e9-e843e0141fc0', 'fa', 'Avser ansökan en investering i byggnader eller maskiner?', 'آیا درخواست مربوط به سرمایه‌گذاری در ساختمان یا ماشین‌آلات است؟', '2026-08-28 19:05:47.746225+00'),
	('3a56b8be-5be6-4cb7-81e4-3ea8f9bdb500', 'fa', 'Avser ansökan en redan utgiven titel?', 'آیا درخواست مربوط به اثری است که قبلاً منتشر شده است؟', '2026-08-28 19:05:47.746225+00');
INSERT INTO public.kb_translations VALUES
	('6a291583-ba89-4956-995d-fc5407176b9e', 'fa', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'آیا درخواست مربوط به یک بنگاه کشاورزی، باغبانی یا پرورش گوزن شمالی است؟', '2026-08-28 19:05:47.746225+00'),
	('2431959a-8668-4e85-b269-d677ebffc95b', 'fa', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'آیا درخواست مربوط به خرید کتاب برای کتابخانه‌های عمومی یا مدرسه‌ای است؟', '2026-08-28 19:05:47.746225+00'),
	('a601a44b-d454-47ee-892f-020006e64e2e', 'fa', 'Avser investeringen jordbruksverksamhet?', 'آیا سرمایه‌گذاری مربوط به فعالیت کشاورزی است؟', '2026-08-28 19:05:47.746225+00'),
	('3c3b3d9f-e284-49fd-b6d6-4ce5bcacf384', 'fa', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'آیا پروژه شامل ساختن، خریدن یا بازسازی یک محل است؟', '2026-08-28 19:05:47.746225+00'),
	('170e009f-acab-4e6a-b413-ba494ab5018c', 'fa', 'Avser projektet naturvård eller friluftsliv?', 'آیا پروژه مربوط به حفاظت از طبیعت یا تفریح در فضای باز است؟', '2026-08-28 19:05:47.746225+00'),
	('b48d0c99-f684-4349-9ab5-ce94b514e4f8', 'fa', 'Avser projektet skola eller vuxenutbildning?', 'آیا پروژه مربوط به مدرسه یا آموزش بزرگسالان است؟', '2026-08-28 19:05:47.746225+00'),
	('3e4a721b-8ca6-4e69-a085-a61a65ffe19e', 'fa', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'آیا از کار صرف‌نظر می‌کنید تا از یکی از نزدیکان که چنان بیمار است که بیماری جانش را تهدید می‌کند مراقبت کنید یا در کنارش باشید؟', '2026-08-28 19:05:47.746225+00'),
	('604d7e79-90b5-447d-86dd-dd88ac4a2ee6', 'fa', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'آیا انجمن در شهرداری فعالیت منظم دارد؟', '2026-08-28 19:05:47.746225+00'),
	('6567d7b0-f0a5-4ce1-9490-5aedac1e2d7e', 'fa', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'آیا ارزیابی شما این است که توان کاری‌تان به دلیل بیماری یا معلولیت دست‌کم یک سال کاهش یافته است؟', '2026-08-28 19:05:47.746225+00'),
	('e3ad47ec-7673-4c2e-a274-d5a2538961cf', 'fa', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'حمایت نیازسنجی‌شده برای کسی که مستمری کم دارد یا ندارد و برای رسیدن به سطح زندگی معقول به کمک نیاز دارد.', '2026-08-28 19:05:47.746225+00'),
	('4cf56496-82bb-4bd0-b500-b449570b8a9a', 'fa', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'آیا کودک باید به دلیل طولانی بودن مسیر در محل تحصیل اقامت کند (خوابگاه)؟', '2026-08-28 19:05:47.746225+00'),
	('e01668a2-27a5-4090-8d92-50016bad5e96', 'fa', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'آیا مسکن نیاز به مناسب‌سازی دارد (مثلاً رمپ، بازکن در، حمام)؟', '2026-08-28 19:05:47.746225+00'),
	('cbd3d18c-40c1-4145-80f9-79ff7cd91795', 'fa', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'آیا یکی از فرزندان ۸ تا ۱۹ ساله شما به عینک یا لنز نیاز دارد؟', '2026-08-28 19:05:47.746225+00'),
	('3bed0b99-ba64-4391-beeb-c26db6984f56', 'fa', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'آیا والد دیگر هیچ نفقه‌ای نمی‌پردازد یا کمتر از نفقه کامل می‌پردازد؟', '2026-08-28 19:05:47.746225+00'),
	('cdf2b7e9-d3e5-4a3e-a2dd-b83db3db82b9', 'fa', 'Betalar du hyra eller andra boendekostnader?', 'آیا اجاره یا هزینه‌های مسکن دیگری می‌پردازید؟', '2026-08-28 19:05:47.746225+00'),
	('2b07c30a-2133-43bc-be93-d8186a96807f', 'fa', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'کمک‌هزینه برای مناسب‌سازی مسکن در صورت معلولیت — مثلاً رمپ، بازکن در یا مناسب‌سازی حمام.', '2026-08-28 19:05:47.746225+00'),
	('9e4a6adf-fb22-4c47-bfa5-fb711da3e19b', 'fa', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'کمک‌هزینه برای ساختن، خریدن یا بازسازی سالن‌های اجتماعات عمومی.', '2026-08-28 19:05:47.746225+00'),
	('a7772395-b996-4428-8184-1cb926817b03', 'fa', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'کمک‌هزینه برای خرید یا مناسب‌سازی خودرو وقتی معلولیت پایدار جابه‌جایی یا سفر با وسایل نقلیه عمومی را بسیار دشوار می‌کند.', '2026-08-28 19:05:47.746225+00'),
	('c5ba9589-5fa9-4d1d-a208-019989fef942', 'fa', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'کمک‌هزینه برای سفرها و تبادل‌های بین‌المللی حرفه‌ای‌های حوزه فرهنگ.', '2026-08-28 19:05:47.746225+00'),
	('21e541ad-82d1-4b89-827f-7069a78bd768', 'fa', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'کمک‌هزینه برای تبادل‌های بین‌المللی، سفرها و اقامت‌های کاری هنرمندان حرفه‌ای.', '2026-08-28 19:05:47.746225+00'),
	('9f5ffd0d-7c7d-4b2f-8125-2d4048c0daee', 'fa', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'کمک‌هزینه و وام اختیاری برای تحصیل در مقطع دبیرستان یا پس از دبیرستان.', '2026-08-28 19:05:47.746225+00'),
	('46e53b0c-f8ea-4e87-a581-0fe3a805a4f8', 'fa', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'کمک‌هزینه و وام برای تحصیل در خارج، با وام‌های تکمیلی برای مثلاً شهریه و سفر.', '2026-08-28 19:05:47.746225+00'),
	('8ee50a23-46a0-424b-a6c4-8e9f8bfb05f9', 'fa', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'کمکی که به نهادهای سوئدی در آماده‌سازی درخواست برای برنامه‌های اتحادیه اروپا مانند Horisont Europa یاری می‌رساند.', '2026-08-28 19:05:47.746225+00'),
	('c5582526-d84c-4ac1-b011-e10fb47e197a', 'fa', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'کمک‌هزینه برای کارفرمایانی که افراد با توان کاری کاهش‌یافته را استخدام می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('d7064511-8fe2-46c9-87a2-7ae2455b577b', 'fa', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'کمک‌هزینه اقامت و سفرهای بازگشت به خانه وقتی دانش‌آموز دبیرستانی به دلیل مسیر طولانی باید در محل تحصیل اقامت کند.', '2026-08-28 19:05:47.746225+00'),
	('7e71ccb9-01a6-4815-b41b-3d923035c887', 'fa', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'کمک‌هزینه برای کار سازمان‌های غیرانتفاعی در حفظ، استفاده و توسعه میراث فرهنگی.', '2026-08-28 19:05:47.746225+00'),
	('c06eafea-07f8-40de-b337-1eb41da7a0f0', 'fa', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'کمک‌هزینه برای پروژه‌های شهری و محلی حفاظت از طبیعت، از جمله تالاب‌ها و تفریح در فضای باز.', '2026-08-28 19:05:47.746225+00'),
	('fa27c768-b9c8-44a9-8887-272966e7bce6', 'fa', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'کمک‌هزینه به شهرداری‌ها برای خرید کتاب برای کتابخانه‌های عمومی و مدرسه‌ای.', '2026-08-28 19:05:47.746225+00'),
	('b9892046-6a43-477b-8724-5340ae9a7fb0', 'fa', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'کمک‌هزینه به مسئولان مدارس برای آشنایی دانش‌آموزان دوره ابتدایی با فرهنگ حرفه‌ای.', '2026-08-28 19:05:47.746225+00'),
	('14aeae5d-86eb-4778-a66a-4d01cfd0bf8a', 'fa', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'کمک‌هزینه برای آنچه فرزندتان نیاز دارد اما بودجه خانواده کفاف نمی‌دهد: فعالیت‌های اوقات فراغت، لباس، اردوهای مدرسه، عینک، فعالیت‌های تعطیلات و غیره.', '2026-08-28 19:05:47.746225+00'),
	('fed0583c-73dc-460d-abbf-21311613a248', 'fa', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'کمک‌هزینه از صندوق‌هایی مانند Världens Barn و Musikhjälpen و Victoriafonden — سازمان‌های غیرانتفاعی سوئدی دارای 90-konto آن را درخواست می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('663a06ad-2204-4267-9359-09b58a5fa38a', 'fa', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'کمک‌هزینه از محل درآمدهای برق‌آبی و بادی برای پروژه‌هایی که منطقه را توسعه می‌دهند.', '2026-08-28 19:05:47.746225+00'),
	('2794b8c0-e239-47fe-b615-4127cd2e7f67', 'fa', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'کمک‌هزینه بدون بخش وام برای بیکاران ۲۵ تا ۶۰ ساله با تحصیلات کوتاه که باید در سطح مدرسه ابتدایی یا دبیرستان تحصیل کنند.', '2026-08-28 19:05:47.746225+00'),
	('501b10f9-536d-4c76-a43b-cf78846c5b82', 'fa', 'Bidrar projektet till energiomställningen?', 'آیا پروژه به گذار انرژی کمک می‌کند؟', '2026-08-28 19:05:47.746225+00'),
	('d11b9690-b55e-48e5-932a-763abae674d5', 'fa', 'Bor du och barnets andra förälder på skilda håll?', 'آیا شما و والد دیگر کودک جدا از هم زندگی می‌کنید؟', '2026-08-28 19:05:47.746225+00'),
	('d6a40f90-a2ee-495c-be64-121ba12da6a4', 'fa', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'چک‌هایی برای شرکت‌های کوچک برای به‌کارگیری تخصص بیرونی در بین‌المللی‌سازی یا دیجیتالی‌سازی.', '2026-08-28 19:05:47.746225+00'),
	('73bf08d7-3867-4c82-9be5-a0a5c2cef0c1', 'fa', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'آیا در برنامه‌ای نزد Arbetsförmedlingen شرکت می‌کنید (مثلاً jobb- och utvecklingsgarantin)؟', '2026-08-28 19:05:47.746225+00'),
	('89280f6f-50a1-4f05-98a8-3ef75d645542', 'fa', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'حمایت پسینی از ناشران برای انتشار ادبیات باکیفیت.', '2026-08-28 19:05:47.746225+00'),
	('fad812cb-daf5-4c55-b254-463b37ade8ed', 'fa', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'حمایت مالی برای کسی که اجازه اقامت مرتبط با حمایت دارد و داوطلبانه می‌خواهد برای همیشه به کشور مبدأ بازگردد.', '2026-08-28 19:05:47.746225+00'),
	('e1e7d2b7-73b6-448d-9ea0-5b739ba59b2c', 'fa', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'حمایت مالی از کارفرمایانی که فردی را استخدام می‌کنند که مدت طولانی از زندگی کاری دور بوده است.', '2026-08-28 19:05:47.746225+00'),
	('910b66a9-a9ca-4d4c-a379-3eff5eac22c8', 'fa', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'حمایت مالی در دوره راه‌اندازی برای جویندگان کار که کسب‌وکار خود را آغاز می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('6e41134b-f397-4072-8609-9bb7fac8f4c3', 'fa', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten به‌طور مستمر فراخوان‌هایی در پژوهش انرژی، نوآوری و بهره‌وری انرژی برگزار می‌کند.', '2026-08-28 19:05:47.746225+00'),
	('9b046e28-ce76-4a80-be61-4ff1b6d8b24b', 'fa', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'پرداختی برای غیبت از کار یا تحصیل به‌منظور مراقبت از کودک.', '2026-08-28 19:05:47.746225+00'),
	('06278a24-d439-4590-9948-d9bca383cc02', 'fa', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'پرداختی برای کسی که تازه‌وارد سوئد است و در برنامه استقرار Arbetsförmedlingen شرکت می‌کند؛ توسط Försäkringskassan پرداخت می‌شود.', '2026-08-28 19:05:47.746225+00'),
	('e8c65682-7055-4d94-87ba-6f1bb0d91334', 'fa', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'پرداختی که بخشی از هزینه مسکن جوانان بدون فرزند با درآمد کم را می‌پوشاند.', '2026-08-28 19:05:47.746225+00'),
	('4c0df67f-4280-4a51-b530-236501a0475a', 'fa', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'پرداختی برای هزینه‌های اضافی ناشی از معلولیت پایدار — برای بزرگسالان یا والدین کودکان دارای معلولیت.', '2026-08-28 19:05:47.746225+00'),
	('720cb31e-a053-4da5-97ca-dc35d8e98c5d', 'fa', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'پرداختی برای جوانان (۱۹–۲۹ ساله) که به دلیل بیماری یا معلولیت دست‌کم یک سال نمی‌توانند تمام‌وقت کار کنند.', '2026-08-28 19:05:47.746225+00'),
	('c683dc21-b7fa-4c8b-9085-c7a0bd9d6b72', 'fa', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'پرداختی وقتی توان کاری به‌طور پایدار کاهش یافته است — آنچه پیش‌تر förtidspension (بازنشستگی پیش از موعد) نامیده می‌شد.', '2026-08-28 19:05:47.746225+00'),
	('771470d7-c6be-4317-9150-2c3a44e72b9b', 'fa', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'پرداختی وقتی از کار صرف‌نظر می‌کنید تا در کنار یکی از نزدیکانِ به‌شدت بیمار باشید.', '2026-08-28 19:05:47.746225+00'),
	('ccdc3943-2b66-4bb8-8ccd-20315570b71f', 'fa', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'پرداختی هنگام شرکت شما در یک برنامه بازار کار نزد Arbetsförmedlingen.', '2026-08-28 19:05:47.746225+00');
INSERT INTO public.kb_translations VALUES
	('2d13297a-4148-4f69-925b-a19742e452f9', 'fa', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'پرداختی وقتی به دلیل بیماری نمی‌توانید مانند معمول کار کنید.', '2026-08-28 19:05:47.746225+00'),
	('cbf0be98-ba5e-40ea-b1d8-bf0960c8584b', 'fa', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'پرداختی وقتی برای مراقبت از کودک بیمار در خانه می‌مانید.', '2026-08-28 19:05:47.746225+00'),
	('63a641b4-ad7c-4f04-854c-a6bd1b2cd1b9', 'fa', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'پرداختی که بخشی از هزینه مسکن خانوارهای دارای فرزند و درآمد پایین‌تر را می‌پوشاند.', '2026-08-28 19:05:47.746225+00'),
	('a16a6339-4944-48cb-a5ba-3d1218c12b27', 'fa', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'پرداختی برای والدینی که فرزندشان به دلیل معلولیت به مراقبت و نظارت بیشتری از کودکان هم‌سن نیاز دارد.', '2026-08-28 19:05:47.746225+00'),
	('49300054-1e3b-466a-b443-d22b6e3a17cd', 'fa', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'پرداختی در دوران بیکاری — مبتنی بر درآمد برای اعضا، مبلغ پایه برای دیگران.', '2026-08-28 19:05:47.746225+00'),
	('585f956d-ae79-4a7a-9ae1-8f9698e75cc9', 'fa', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'حدود پنجاه بنیاد بانک‌های پس‌انداز به پروژه‌های محلی در ورزش، فرهنگ، آموزش و توسعه اجتماعی کمک می‌کنند — در حوزه فعالیت بانک.', '2026-08-28 19:05:47.746225+00'),
	('b5c30eaf-e88b-4f2a-9ef7-83be84fd0506', 'fa', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'حمایت پروژه‌ای با بودجه اتحادیه اروپا که نزد منطقه Leader محلی شما درخواست می‌شود — برای انجمن‌ها، شرکت‌ها و شهرداری‌هایی که روستاها را توسعه می‌دهند.', '2026-08-28 19:05:47.746225+00'),
	('4f7c7102-d2e3-43e4-b7fc-c212ae3bc59a', 'fa', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'حمایت با بودجه اتحادیه اروپا برای جویندگان کار که در کشور دیگری از اتحادیه اروپا/منطقه اقتصادی اروپا کاری می‌پذیرند: جبران هزینه سفر مصاحبه، هزینه اسباب‌کشی و دوره زبان.', '2026-08-28 19:05:47.746225+00'),
	('0ddb1e02-d82d-4b0b-b683-0ad8a42553dd', 'fa', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'بودجه صندوق اجتماعی اروپا برای پروژه‌هایی که مهارت‌ها، گذار شغلی و شمول در بازار کار را تقویت می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('595c6de3-4002-49c7-8328-bd79c10af8bc', 'fa', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'حمایت اتحادیه اروپا از تبادل‌های گروهی جوانان ۱۳ تا ۳۰ ساله، به مدت ۵ تا ۲۱ روز بدون روزهای سفر.', '2026-08-28 19:05:47.746225+00'),
	('d4447768-cadf-47fa-ad93-f66134f5d0e9', 'fa', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'حمایت اتحادیه اروپا از پروژه‌های همکاری سازمان‌های فرهنگی با شرکایی در چند کشور اروپایی.', '2026-08-28 19:05:47.746225+00'),
	('b8491559-eab0-4029-a45f-7efc7b2fe4c9', 'fa', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'حمایت اتحادیه اروپا از سازمان‌هایی که داوطلبان جوان ۱۸ تا ۳۰ ساله را می‌پذیرند یا می‌فرستند.', '2026-08-28 19:05:47.746225+00'),
	('a3b293a7-8fa0-4ebb-b02d-dd820ab7751c', 'fa', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'حمایت اتحادیه اروپا از تحرک کارکنان و دانش‌آموزان در مدرسه و آموزش بزرگسالان.', '2026-08-28 19:05:47.746225+00'),
	('63b24988-0831-4c27-9bf0-445dbdcdf70a', 'fa', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'حمایت اتحادیه اروپا با مبالغ مقطوع برای نخستین پروژه‌های همکاری اروپایی سازمان‌های کوچک‌تر.', '2026-08-28 19:05:47.746225+00'),
	('f97754d1-bd73-445d-b52d-a89e857f46fa', 'fa', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تأمین مالی برای شرکت‌های جوانی که محصولات یا خدمات نوآورانه با ظرفیت بین‌المللی توسعه می‌دهند.', '2026-08-28 19:05:47.746225+00'),
	('8102ef6e-7bd0-4ae8-9cad-72c208f0cae8', 'prs', 'Bor du och barnets andra förälder på skilda håll?', 'آیا شما و والد دیگر طفل جدا از هم زندگی می‌کنید؟', '2026-08-28 19:05:47.755665+00'),
	('e788c750-f9e8-47a0-bd62-43f74b8a45db', 'fa', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'آیا در محل فعالیت شما بانک پس‌اندازی (و در نتیجه بنیاد بانک پس‌انداز) وجود دارد؟', '2026-08-28 19:05:47.746225+00'),
	('cfb02d07-0e69-42e4-bf90-f1a9507408ab', 'fa', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'کمک‌هزینه فعالیت چندساله برای گروه‌های مستقل حرفه‌ای رقص، تئاتر و تئاتر موزیکال.', '2026-08-28 19:05:47.746225+00'),
	('61f86b40-796c-4d0a-8e2b-7ffa88675f10', 'fa', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'کمک‌هزینه پژوهشی در حوزه‌های Forte: سلامت، زندگی کاری و رفاه. پژوهشگران دارای دکترا در دانشگاه‌های سوئد درخواست می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('c7f2db6f-baee-4eee-89ce-3dd9fa3bb541', 'fa', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'بودجه پژوهشی برای پژوهش بنیادی آزاد در همه حوزه‌های علمی.', '2026-08-28 19:05:47.746225+00'),
	('a1d06374-4004-4908-a6a7-77b47b2b0e93', 'fa', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'بودجه پژوهشی در محیط‌زیست، علوم کشاورزی و شهرسازی.', '2026-08-28 19:05:47.746225+00'),
	('f1c33524-e6f7-47e5-8b8c-41aab3af2b99', 'fa', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'آیا به مهاجرت به خارج فکر می‌کنید (برای کار، تحصیل یا بازگشت به وطن)؟', '2026-08-28 19:05:47.746225+00'),
	('7ffaff3c-83c3-4199-adf7-d97c54d299fa', 'fa', 'Genomförs insatserna av professionella kulturaktörer?', 'آیا فعالیت‌ها را کنشگران فرهنگی حرفه‌ای اجرا می‌کنند؟', '2026-08-28 19:05:47.746225+00'),
	('e0aae810-377e-4065-aa6f-d4e840c52f3b', 'fa', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'آیا پروژه در روستا یا در شهرک کوچکی اجرا می‌شود؟', '2026-08-28 19:05:47.746225+00'),
	('017733e1-2c6e-41a9-ba45-81d7475de24a', 'fa', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حمایت پایه برای کسی که در طول زندگی درآمد کاری کم یا هیچ نداشته است.', '2026-08-28 19:05:47.746225+00'),
	('cc9b8409-8fe7-45f4-afe6-c315253452c4', 'fa', 'Går något av dina barn i grundskolan?', 'آیا یکی از فرزندانتان به مدرسه ابتدایی می‌رود؟', '2026-08-28 19:05:47.746225+00'),
	('cdd2e94d-2bd5-4eb9-806b-44a1822d0191', 'fa', 'Går något av dina barn på gymnasiet?', 'آیا یکی از فرزندانتان در دبیرستان تحصیل می‌کند؟', '2026-08-28 19:05:47.746225+00'),
	('55b6dbc1-6d54-4335-bcb1-050d4680178c', 'fa', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'آیا استخدام مربوط به فردی با توان کاری کاهش‌یافته است؟', '2026-08-28 19:05:47.746225+00'),
	('726178d2-2068-47e8-94ed-2ff3d6aa308e', 'fa', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'آیا استخدام مربوط به کسی است که مدت طولانی بیکار بوده یا تازه‌وارد سوئد است؟', '2026-08-28 19:05:47.746225+00'),
	('75dbd9a5-e9a2-46a0-a2d9-1d3b87e84d9f', 'fa', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'آیا پروژه درباره حفظ میراث فرهنگی یا دسترس‌پذیر کردن آن است؟', '2026-08-28 19:05:47.746225+00'),
	('a9414fab-b209-48b7-a5dd-20a9a2e42891', 'fa', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'آیا پروژه درباره انرژی، بهره‌وری انرژی یا نوآوری مرتبط با انرژی است؟', '2026-08-28 19:05:47.746225+00'),
	('305d56d8-a23c-46d2-9be9-a138396cca61', 'fa', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'آیا پروژه درباره سلامت، زندگی کاری یا رفاه است؟', '2026-08-28 19:05:47.746225+00'),
	('c92cc11c-edf5-42b3-883a-fbb8024c0403', 'fa', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'آیا پروژه درباره توسعه مهارت‌ها یا اقدامات بازار کار است؟', '2026-08-28 19:05:47.746225+00'),
	('739bdab5-bfca-4571-b4e3-e27a60bd8098', 'fa', 'Handlar projektet om miljö- eller klimatåtgärder?', 'آیا پروژه درباره اقدامات زیست‌محیطی یا اقلیمی است؟', '2026-08-28 19:05:47.746225+00'),
	('b252e265-561c-4876-91ff-9b9b419737df', 'fa', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'آیا مسیر کودک به مدرسه طولانی، به دلیل ترافیک خطرناک یا به شکل دیگری دشوار است؟', '2026-08-28 19:05:47.746225+00'),
	('9237e213-7e9a-44b7-a776-b094deb0bc1e', 'fa', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'آیا دست‌کم ۱۶ ساعت در هفته و در مجموع دست‌کم ۸ سال کار کرده‌اید؟', '2026-08-28 19:05:47.746225+00'),
	('afb06e14-9f2d-4cdb-87b5-609e975d048e', 'fa', 'Har du barn som bor hos dig, helt eller växelvis?', 'آیا فرزندانی دارید که نزد شما زندگی می‌کنند، تمام‌وقت یا به‌تناوب؟', '2026-08-28 19:05:47.746225+00'),
	('8d721486-2b0c-4d18-9f8a-0793d4175055', 'fa', 'Har du barn som bor hos dig?', 'آیا فرزندانی دارید که نزد شما زندگی می‌کنند؟', '2026-08-28 19:05:47.746225+00'),
	('8dff79ed-fb4d-4cd6-95d2-227a5f6b2128', 'fa', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'آیا شما یا فرزندتان معلولیتی دارید که انتظار می‌رود دست‌کم یک سال ادامه یابد؟', '2026-08-28 19:05:47.746225+00'),
	('a74ac80b-ec53-4b4e-a0d1-c5a7f00a3a57', 'fa', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'آیا شما یا کسی در خانوار معلولیت پایداری دارد که بر مسکن اثر می‌گذارد؟', '2026-08-28 19:05:47.746225+00'),
	('c2a351fc-e904-4779-a446-1339103b9cce', 'fa', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'آیا شما یا یکی از نزدیکان معلولیت یا بیماری طولانی یا جدی دارید؟', '2026-08-28 19:05:47.746225+00'),
	('d0d78946-4679-44c1-a7ae-2e1cc78eadbe', 'fa', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'آیا بیماری یا آسیبی دارید که هم‌اکنون توان کاری شما را کاهش می‌دهد؟', '2026-08-28 19:05:47.746225+00'),
	('34be642d-a033-4e73-b8d4-165298579d19', 'fa', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'آیا تاکنون در پرداخت هزینه اردوی مدرسه، سفر کلاسی یا فعالیت اوقات فراغتی که انتظار می‌رود فرزندتان در آن شرکت کند مشکل داشته‌اید؟', '2026-08-28 19:05:47.746225+00'),
	('de173299-f9fe-4f38-bcf2-95760ab1d065', 'fa', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'آیا گذران زندگی با مستمری و سایر درآمدهایتان برایتان دشوار است؟', '2026-08-28 19:05:47.746225+00'),
	('31223075-1e04-4219-8180-2abf3d28582d', 'fa', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'آیا در سال‌های اخیر اجازه اقامت در سوئد گرفته‌اید، مثلاً به‌عنوان نیازمند حمایت یا عضو خانواده؟', '2026-08-28 19:05:47.746225+00'),
	('fabf745f-3729-4ba0-a50a-713f572f1cf0', 'fa', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'آیا اجازه اقامت در سوئد به‌عنوان پناهنده یا نیازمند حمایت دارید (یا از بستگان نزدیک چنین کسی هستید)؟', '2026-08-28 19:05:47.746225+00'),
	('a15eb5d0-d37f-4c95-8f29-0dd99dec8b32', 'fa', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'آیا به سن مرجع بازنشستگی رسیده‌اید (۶۷ سال در ۲۰۲۶)؟', '2026-08-28 19:05:47.746225+00'),
	('ff930588-de78-4123-990e-4e5d734f913c', 'fa', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'آیا سازمان شما OID (Organisation ID) ثبت‌شده در Organisation Registration System اتحادیه اروپا دارد؟', '2026-08-28 19:05:47.746225+00'),
	('758799d8-10ae-4ad4-89ec-a463b698adbb', 'fa', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'آیا معلولیت هزینه‌های اضافی به همراه داشته است — مثلاً وسایل کمکی، سفر، رژیم غذایی خاص یا استهلاک؟', '2026-08-28 19:05:47.746225+00'),
	('031e4c09-a06d-46c2-91b8-76512555a16c', 'fa', 'Har föreningen antagna stadgar och en vald styrelse?', 'آیا انجمن اساسنامه مصوب و هیئت‌مدیره منتخب دارد؟', '2026-08-28 19:05:47.746225+00');
INSERT INTO public.kb_translations VALUES
	('1db4d979-ba5f-47e5-8dda-c174b7314fb9', 'fa', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'آیا انجمن ساختار دموکراتیک دارد (اساسنامه، مجمع سالانه، هیئت‌مدیره)؟', '2026-08-28 19:05:47.746225+00'),
	('a4655de0-6500-412e-b825-ac97bc24dce7', 'fa', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'آیا انجمن فعالیت منظمی برای کودکان یا جوانان دارد؟', '2026-08-28 19:05:47.746225+00'),
	('2465a114-fb78-41b8-9708-1dabb30092aa', 'fa', 'Har företaget mellan cirka 2 och 49 anställda?', 'آیا شرکت بین حدود ۲ تا ۴۹ کارمند دارد؟', '2026-08-28 19:05:47.746225+00'),
	('236cfe56-eed6-4e9f-ab4d-3fa72f5df8d2', 'fa', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'آیا خانوار در تأمین هزینه‌های خوراک، مسکن و ضروری‌ترین چیزها مشکل دارد؟', '2026-08-28 19:05:47.746225+00'),
	('e16a2846-4106-468d-821e-f669d1d86b74', 'fa', 'Har lösningen internationell potential?', 'آیا راه‌حل ظرفیت بین‌المللی دارد؟', '2026-08-28 19:05:47.746225+00'),
	('5ccfee63-f1d6-4deb-828f-cc9fc18121dc', 'fa', 'Har ni en partnergrupp i ett annat land?', 'آیا گروه شریکی در کشور دیگری دارید؟', '2026-08-28 19:05:47.746225+00'),
	('8477722c-3a52-45a6-a6c8-2c9ea6ac69f4', 'fa', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'آیا سازمان شریکی در کشور اروپایی دیگری دارید؟', '2026-08-28 19:05:47.746225+00'),
	('168b48fc-792d-43c0-96de-9d1da1e15877', 'fa', 'Har ni partner i minst tre olika europeiska länder?', 'آیا در دست‌کم سه کشور اروپایی مختلف شریک دارید؟', '2026-08-28 19:05:47.746225+00'),
	('ab77cb4f-1b48-45e8-85ba-473dc9195330', 'fa', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'آیا دفتر مرکزی یا فعالیت اصلی شما در منطقه‌ای است که در آن درخواست می‌دهید؟', '2026-08-28 19:05:47.746225+00'),
	('5315dbc3-acae-4cf8-9dea-55890b3fcd23', 'fa', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'آیا یکی از فرزندانتان معلولیتی دارد که باعث می‌شود به مراقبت یا نظارت بیشتری از کودکان هم‌سن نیاز داشته باشد؟', '2026-08-28 19:05:47.746225+00'),
	('4b0279e3-e464-49f7-992f-d29c5a851312', 'fa', 'Har organisationen en demokratisk uppbyggnad?', 'آیا سازمان ساختار دموکراتیک دارد؟', '2026-08-28 19:05:47.746225+00'),
	('cc5392c6-210d-4d6b-b6e6-97c09bba8539', 'fa', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'آیا سازمان Quality Label (نشان کیفیت) دارد؟', '2026-08-28 19:05:47.746225+00'),
	('7b535cfe-745b-4b3f-b999-5f060e799e89', 'fa', 'Har organisationen ett 90-konto?', 'آیا سازمان 90-konto دارد؟', '2026-08-28 19:05:47.746225+00'),
	('678ca5c5-6da4-41ed-a3ec-9c8bb2022620', 'fa', 'Har organisationen ett OID (Organisation ID)?', 'آیا سازمان OID (Organisation ID) دارد؟', '2026-08-28 19:05:47.746225+00'),
	('f521ee99-c2d4-4fcc-b269-9f4cffde0b1e', 'fa', 'Har organisationen ett OID?', 'آیا سازمان OID دارد؟', '2026-08-28 19:05:47.746225+00'),
	('a55e7784-06b1-4fdf-8d75-0b7fc290aa45', 'fa', 'Har organisationen medlemsföreningar i flera län?', 'آیا سازمان انجمن‌های عضو در چند استان دارد؟', '2026-08-28 19:05:47.746225+00'),
	('94397944-bf93-4afc-8a7e-72e24b10c093', 'fa', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'آیا سازمان مالی منظم و ساختار دموکراتیک دارد؟', '2026-08-28 19:05:47.746225+00'),
	('168e919f-12e0-4913-9e06-e908ac4ff5d7', 'fa', 'Har projektet en partner i ett annat land?', 'آیا پروژه شریکی در کشور دیگری دارد؟', '2026-08-28 19:05:47.746225+00'),
	('3b2dd2a8-b6e5-4dc4-87e4-51bc9ef7fa62', 'fa', 'Har projektledaren doktorsexamen?', 'آیا سرپرست پروژه مدرک دکترا دارد؟', '2026-08-28 19:05:47.746225+00'),
	('2365fb6b-bedd-4de6-9c3c-3558a4daf6f7', 'fa', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'شهرداری محل سکونت باید رفت‌وآمد روزانه میان خانه و دبیرستان را وقتی مسیر دست‌کم شش کیلومتر است تأمین کند (مثلاً کارت اتوبوس).', '2026-08-28 19:05:47.746225+00'),
	('768f5734-e5d4-4109-ab58-4e71b15a5a83', 'fa', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'آیا در حال تهیه یا تجهیز نخستین خانه شخصی خود در سوئد هستید؟', '2026-08-28 19:05:47.746225+00'),
	('9844e0be-238f-4f3d-bcd5-3799bff18df3', 'fa', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'آیا پروژه شامل سفر یا تبادل بین‌المللی است؟', '2026-08-28 19:05:47.746225+00'),
	('e2c4205d-1b21-4105-a131-5d4f5525809a', 'fa', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'حمایت سرمایه‌گذاری از شرکت‌ها در مناطق حمایتی برای ساختمان، ماشین‌آلات و آموزش.', '2026-08-28 19:05:47.746225+00'),
	('d1d9b840-408c-4f60-8398-9c56a52dc285', 'fa', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'حمایت سرمایه‌گذاری از اقداماتی که انتشار گازهای گلخانه‌ای را کاهش می‌دهند.', '2026-08-28 19:05:47.746225+00'),
	('72b6495b-33ca-4063-b38d-8bbb7d9b5161', 'fa', 'Kan projektets miljönytta mätas?', 'آیا فایده زیست‌محیطی پروژه قابل اندازه‌گیری است؟', '2026-08-28 19:05:47.746225+00'),
	('4311b9c4-6b2d-4222-93df-12cef4f4e826', 'fa', 'Kan åtgärdens utsläppsminskning beräknas?', 'آیا کاهش انتشار حاصل از اقدام قابل محاسبه است؟', '2026-08-28 19:05:47.746225+00'),
	('a656ee97-5746-4f4c-b46c-8fb06321dfd6', 'fa', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'آیا سازمان می‌تواند هزینه‌ها را تا پرداخت حمایت بر عهده بگیرد؟', '2026-08-28 19:05:47.746225+00'),
	('2624dd1f-d267-4326-b58a-436cf11fcf46', 'fa', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'آیا تجربه‌ها در فعالیت شما در سوئد به کار گرفته می‌شوند؟', '2026-08-28 19:05:47.746225+00'),
	('daa57add-33c3-4518-bf09-7074693a5ae2', 'fa', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'آیا سرمایه‌گذاری تنها پس از ارسال درخواست آغاز می‌شود؟', '2026-08-28 19:05:47.746225+00'),
	('710e52a9-e253-471f-a871-9939a7d1cc19', 'fa', 'Kommer projektet människor i ert närområde till del?', 'آیا پروژه به مردم منطقه شما سود می‌رساند؟', '2026-08-28 19:05:47.746225+00'),
	('e9862ee6-0f05-4beb-a319-ddc2ed600dad', 'fa', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'واپسین تور ایمنی اقتصادی شهرداری وقتی درآمدها کفاف ضروری‌ترین چیزها را نمی‌دهند.', '2026-08-28 19:05:47.746225+00'),
	('4be4168c-20a3-4af8-9f1c-0636b1d06729', 'fa', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'حمایت شروع برای کسی که ۴۰ ساله یا جوان‌تر است و بنگاه کشاورزی راه می‌اندازد یا تحویل می‌گیرد.', '2026-08-28 19:05:47.746225+00'),
	('a8359817-0a95-4891-a6b7-38b8c3ec4646', 'fa', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'حمایت‌های خود شهرداری‌ها از انجمن‌های محلی: کمک‌هزینه فعالیت به ازای هر جلسه، کمک‌هزینه محل، کمک‌هزینه شروع و غیره.', '2026-08-28 19:05:47.746225+00'),
	('32a80c4d-cde6-47fa-a815-1c516d2d392c', 'fa', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'سرویس رایگان مدرسه برای دانش‌آموزان ابتدایی در صورت مسافت طولانی، مسیر پرخطر یا معلولیت — حقی طبق قانون مدارس.', '2026-08-28 19:05:47.746225+00'),
	('2aaede8b-1ac1-403d-b474-ff6fed6ef4c1', 'fa', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'کمک‌هزینه قانونی عینک یا لنز برای کودکان و جوانان؛ مبالغ و روال‌ها در هر استان متفاوت است — سطح استان خود را بررسی کنید.', '2026-08-28 19:05:47.746225+00'),
	('5664af4f-b868-4a77-a507-34fcc2c31337', 'fa', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'آیا پروژه در منطقه‌ای است که برق‌آبی یا بادی به آن مربوط می‌شود؟', '2026-08-28 19:05:47.746225+00'),
	('f054ef8d-1a7f-41da-bbe8-eb620b575a71', 'fa', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'آیا پروژه در حوزه محیط‌زیست، علوم کشاورزی یا شهرسازی است؟', '2026-08-28 19:05:47.746225+00'),
	('10c5cf5f-c417-4e60-bcee-677c5ba91e2f', 'fa', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'آیا محل فعالیت در منطقه حمایتی A یا B است (بخش‌های بزرگ نورلند و سوئالند داخلی)؟', '2026-08-28 19:05:47.746225+00'),
	('0e7dd934-cc59-4169-98ce-4361a8f2d826', 'fa', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'وامی برای خرید ضروری‌ترین چیزها برای نخستین خانه در سوئد — مبلمان، لوازم خانه و دیگر تجهیزات پایه.', '2026-08-28 19:05:47.746225+00'),
	('49d4986e-eac3-4ff8-acf7-5e77ad3f10f8', 'fa', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'آیا پروژه انتشار فرایندی صنعت را کاهش می‌دهد یا انتشار منفی ایجاد می‌کند؟', '2026-08-28 19:05:47.746225+00'),
	('3c185c79-90ea-4ae0-9117-40e6f2f18c9e', 'fa', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'کمک‌هزینه ماهانه برای کودکان ساکن سوئد، از تولد تا ۱۶ سالگی.', '2026-08-28 19:05:47.746225+00'),
	('32339ac7-7d17-4ecd-9b94-22cfb72c5fd8', 'fa', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket به سازمان‌ها، شرکت‌ها، انجمن‌ها، بخش عمومی و اشخاص در حوزه محیط‌زیست کمک‌هزینه می‌دهد.', '2026-08-28 19:05:47.746225+00'),
	('3f933b63-2cb3-4951-9393-edc9272ee6d8', 'fa', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'آیا قصد دارید داوطلبانه برای همیشه به کشور مبدأ بازگردید؟', '2026-08-28 19:05:47.746225+00'),
	('571ff496-dc76-4085-bb83-72ae3a27ee34', 'fa', 'Planerar du att starta eget företag?', 'آیا قصد دارید کسب‌وکار خود را راه بیندازید؟', '2026-08-28 19:05:47.746225+00'),
	('d333d704-470c-467c-a7cc-66a327127c08', 'fa', 'Planerar du att studera utomlands?', 'آیا قصد تحصیل در خارج را دارید؟', '2026-08-28 19:05:47.746225+00'),
	('0a259594-459d-4e58-bb59-1d929dc4a861', 'fa', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'آیا قصد تحصیلی دارید که جایگاه شما را در بازار کار تقویت کند؟', '2026-08-28 19:05:47.746225+00'),
	('bf78123d-4edd-4975-9054-d6f3d1ae6112', 'fa', 'Planerar ni att anställa?', 'آیا قصد استخدام دارید؟', '2026-08-28 19:05:47.746225+00'),
	('d902b8bb-db84-4606-870b-a138525ce2e0', 'fa', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'آیا قصد دارید برای برنامه‌ای از اتحادیه اروپا (مثلاً Horisont Europa) درخواست دهید؟', '2026-08-28 19:05:47.746225+00'),
	('0a84483f-2a2e-4c02-ab71-522c0fc6100f', 'fa', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'حمایت از تولید و توسعه فیلم کوتاه و مستند.', '2026-08-28 19:05:47.746225+00'),
	('db635288-faa4-4367-9763-e8fe0008178a', 'fa', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'کمک‌هزینه پروژه‌ای برای صحنه موسیقی مستقل: کنسرت، تولید و توسعه.', '2026-08-28 19:05:47.746225+00');
INSERT INTO public.kb_translations VALUES
	('8931d354-4126-4f0c-b8b4-9e4b63c97352', 'fa', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'کمک‌هزینه پروژه‌ای برای سازمان‌های غیرانتفاعی که با کودکان و جوانان و برای آنان کار می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('d11668ed-8269-49d6-ae11-62fca6c4fd10', 'fa', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'آیا پروژه بیان‌ها، روش‌ها یا همکاری‌های هنری تازه‌ای می‌آزماید؟', '2026-08-28 19:05:47.746225+00'),
	('1c871a32-d94c-4541-be4c-74501f720571', 'fa', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'آیا تبادل ۵ تا ۲۱ روز طول می‌کشد (بدون روزهای سفر)؟', '2026-08-28 19:05:47.746225+00'),
	('07e1352c-105d-447e-8676-cf7766b4635f', 'fa', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'حمایت‌های خود استان‌ها از پروژه‌ها و فعالیت‌های فرهنگی، در کنار کمک‌های ملی Kulturrådet.', '2026-08-28 19:05:47.746225+00'),
	('9a5b6e2c-420c-4c2c-8049-22f06d70bd7d', 'fa', 'Riktar sig projektet till barn eller unga?', 'آیا پروژه کودکان یا جوانان را هدف می‌گیرد؟', '2026-08-28 19:05:47.746225+00'),
	('7b9bb23d-bd2b-4bfe-9400-ca4bb2003110', 'fa', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'آیا پروژه کودکان، جوانان، سالمندان یا افراد دارای معلولیت را هدف می‌گیرد؟', '2026-08-28 19:05:47.746225+00'),
	('3586a7da-82b7-486c-bcb1-a14874242c84', 'fa', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'آیا فعالیت کودکان و جوانان (۷–۲۵ ساله) را هدف می‌گیرد؟', '2026-08-28 19:05:47.746225+00'),
	('d72747c2-8fd4-47a5-87a3-b6c57ad17886', 'fa', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'آیا پس‌انداز یا دارایی‌ای ندارید که بتواند هزینه‌ها را بپوشاند؟', '2026-08-28 19:05:47.746225+00'),
	('9e0c7e69-b51f-4fcd-9830-4d9641f6fa04', 'fa', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'آیا با شرکایی در دست‌کم دو کشور شمال اروپای دیگر همکاری می‌کنید؟', '2026-08-28 19:05:47.746225+00'),
	('b6fd8c4b-315c-4ad5-874c-eea7f3b59291', 'fa', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'آیا برای یک اقدام توسعه‌ای تخصص بیرونی به کار می‌گیرید؟', '2026-08-28 19:05:47.746225+00'),
	('9bf8d5bd-2e1c-4049-9bc8-09c5ffc3a413', 'fa', 'Sker mobiliteten till ett annat europeiskt land?', 'آیا تحرک به کشور اروپایی دیگری است؟', '2026-08-28 19:05:47.746225+00'),
	('70aa8d78-532f-4ccb-88a1-5df1d8e2e424', 'fa', 'Startar du eller tar du över företaget för första gången?', 'آیا برای نخستین بار کسب‌وکار را راه می‌اندازید یا تحویل می‌گیرید؟', '2026-08-28 19:05:47.746225+00'),
	('3d6ead39-0afb-46a7-9659-7cd732461157', 'fa', 'Är du yrkesverksam konstnär?', 'آیا هنرمند حرفه‌ای هستید؟', '2026-08-28 19:05:47.746225+00'),
	('576b7220-df2e-4f11-889a-b5b74f4721fb', 'fa', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'بورسیه‌ای که به هنرمندان حرفه‌ای امکان می‌دهد بر کار هنری تمرکز کنند.', '2026-08-28 19:05:47.746225+00'),
	('129e66a6-08fb-4ae6-9819-7a12019a0544', 'fa', 'Studerar du, eller planerar du att börja studera?', 'آیا تحصیل می‌کنید یا قصد شروع تحصیل دارید؟', '2026-08-28 19:05:47.746225+00'),
	('8d1310a8-f1a7-43bc-be06-db70b7e96ead', 'fa', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'حمایت تحصیلی برای بزرگسالان شاغل که می‌خواهند برای تقویت جایگاه خود در بازار کار آموزش ببینند.', '2026-08-28 19:05:47.746225+00'),
	('88459143-dc3b-4d39-ac4c-ebf4e7d22797', 'fa', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'حمایت از سرمایه‌گذاری‌هایی که رقابت‌پذیری را افزایش یا اثرات زیست‌محیطی را در بنگاه‌های کشاورزی کاهش می‌دهند.', '2026-08-28 19:05:47.746225+00'),
	('76547aba-24a3-4906-aa9c-d37218929b27', 'fa', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'حمایتی وقتی کودکی نزد شما زندگی می‌کند و والد دیگر نفقه نمی‌پردازد.', '2026-08-28 19:05:47.746225+00'),
	('11f5e9f8-518c-4352-a776-0153314efc94', 'fa', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'حمایت از پروژه‌های سازمان‌های غیرانتفاعی برای مردم، محیط‌زیست و جهانی بهتر.', '2026-08-28 19:05:47.746225+00'),
	('0545135e-a957-4fb9-b16a-df687b0f2252', 'fa', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'حمایت از گذار صنعت به سوی انتشار صفر گازهای گلخانه‌ای.', '2026-08-28 19:05:47.746225+00'),
	('7bf9ea85-e19e-4592-81c0-f02a1aae552c', 'fa', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'حمایت از پروژه‌های هنری و فرهنگی با بُعد نوردیک و همکاری فرامرزی.', '2026-08-28 19:05:47.746225+00'),
	('39c7259b-6e4c-49e0-a06a-a7212b04f352', 'fa', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'حمایت از پروژه‌های فرهنگی نوآورانه که بیان‌ها، روش‌ها یا همکاری‌های هنری تازه می‌آزمایند.', '2026-08-28 19:05:47.746225+00'),
	('02faea28-a454-4abb-b8b4-770efd87073f', 'fa', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'حمایت از پروژه‌های نوآورانه برای کودکان، جوانان، سالمندان و افراد دارای معلولیت.', '2026-08-28 19:05:47.746225+00'),
	('44a07a4f-b721-419a-b756-e6bc245684e2', 'fa', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'حمایت از پروژه‌های همکاری در صحنه موسیقی مستقل.', '2026-08-28 19:05:47.746225+00'),
	('c61f02d6-2f58-4772-a2e1-74d8931a6d8e', 'fa', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'حمایت از پروژه‌های همکاری در فرهنگ و رسانه که دموکراسی و آزادی بیان را در سطح بین‌المللی تقویت می‌کنند.', '2026-08-28 19:05:47.746225+00'),
	('b79b4a60-6143-46cc-875e-d56845efce89', 'fa', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'آیا هدف پروژه تقویت دموکراسی، برابری یا آزادی بیان است؟', '2026-08-28 19:05:47.746225+00'),
	('3a7bcbe9-13d2-4658-8393-a7b57ae43a08', 'fa', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'آیا در کشور دیگری از اتحادیه اروپا یا منطقه اقتصادی اروپا دنبال کار می‌گردید یا پیشنهاد کاری گرفته‌اید؟', '2026-08-28 19:05:47.746225+00'),
	('ceb7669e-d113-481f-931c-bb6f7a9c24e9', 'fa', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقفی برای آنچه در دوره دوازده‌ماهه بابت هزینه‌های بیمار می‌پردازید — پس از آن frikort (کارت رایگان).', '2026-08-28 19:05:47.746225+00'),
	('ba038fc6-f5a8-46d6-a924-bce90c5af2c0', 'fa', 'Tar du ut hel allmän pension?', 'آیا مستمری عمومی کامل خود را دریافت می‌کنید؟', '2026-08-28 19:05:47.746225+00'),
	('8036be87-c7af-4f50-92e1-125ee91eaffa', 'fa', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'افزودنی‌ای که بخشی از هزینه مسکن را برای کسی که مستمری و درآمد کم دارد می‌پوشاند.', '2026-08-28 19:05:47.746225+00'),
	('aadba55f-dcaa-4caa-9d7b-4f41a699c73e', 'fa', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'کمک‌هزینه سازمانی سالانه برای سازمان‌های ملی کودکان و جوانان.', '2026-08-28 19:05:47.746225+00'),
	('ae7e28c9-4783-4ad8-9785-a56043e97337', 'fa', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'اعتبار سالانه‌ای که مستقیماً نزد دندان‌پزشک یا بهداشت‌کار دهان کسر می‌شود.', '2026-08-28 19:05:47.746225+00'),
	('a931ca7d-7d32-449e-9b65-843c2503689a', 'fa', 'Är bolaget yngre än cirka 5 år?', 'آیا عمر شرکت کمتر از حدود ۵ سال است؟', '2026-08-28 19:05:47.746225+00'),
	('14850e60-9c33-42f3-8f5f-df0bef80bd91', 'fa', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'آیا شرکت‌کنندگان تبادل بین ۱۳ و ۳۰ سال دارند؟', '2026-08-28 19:05:47.746225+00'),
	('d789eb69-aa05-49ea-afa2-2ed7405b1bf7', 'fa', 'Är det här ert första EU-projekt?', 'آیا این نخستین پروژه اتحادیه اروپای شماست؟', '2026-08-28 19:05:47.746225+00'),
	('27099aa7-35f4-4f6a-9c19-8626cf410bc9', 'fa', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'آیا برای شما (یا فرزندتان) جابه‌جایی مستقل یا سفر با اتوبوس و قطار بسیار دشوار است؟', '2026-08-28 19:05:47.746225+00'),
	('d233f266-6848-4300-ae48-0e2b216a0265', 'fa', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا درآمد شما کمتر از حدود ۲۵٬۰۰۰ کرون در ماه پیش از مالیات است؟', '2026-08-28 19:05:47.746225+00'),
	('776a81d1-ff83-4359-a7aa-784410628dc1', 'fa', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'آیا آخرین تحصیل تمام‌شده شما مدرسه ابتدایی است، یا دبیرستانی که تمامش نکردید؟', '2026-08-28 19:05:47.746225+00'),
	('1149e136-fa4a-47be-88b6-ef516d32fe0b', 'fa', 'Är du 40 år eller yngre?', 'آیا ۴۰ ساله یا جوان‌تر هستید؟', '2026-08-28 19:05:47.746225+00'),
	('50e7be64-2407-4d46-bedf-28272b2220ef', 'fa', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'آیا به‌عنوان جوینده کار نزد Arbetsförmedlingen ثبت‌نام کرده‌اید؟', '2026-08-28 19:05:47.746225+00'),
	('645c1e33-4c97-4156-b453-cdd5d64f8810', 'fa', 'Är du mellan 18 och 28 år?', 'آیا بین ۱۸ و ۲۸ سال دارید؟', '2026-08-28 19:05:47.746225+00'),
	('989c3338-a7ca-4c12-b9df-d9540af2fb4e', 'fa', 'Är du mellan 19 och 29 år?', 'آیا بین ۱۹ و ۲۹ سال دارید؟', '2026-08-28 19:05:47.746225+00'),
	('05f47e81-17a9-4b91-b8ef-f561f662364d', 'fa', 'Är du mellan 25 och 60 år?', 'آیا بین ۲۵ و ۶۰ سال دارید؟', '2026-08-28 19:05:47.746225+00'),
	('0ea188b3-1645-4f31-a81a-e9ee1ddbdc11', 'fa', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'آیا به‌طور حرفه‌ای در حوزه فرهنگ فعالیت می‌کنید (مثلاً رقص، موسیقی، هنرهای نمایشی)؟', '2026-08-28 19:05:47.746225+00'),
	('ed2bf758-c0d9-43e7-baad-c77de2fffa58', 'fa', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'آیا هنرمند حرفه‌ای هستید (نه آماتور و نه در آموزش پایه)؟', '2026-08-28 19:05:47.746225+00'),
	('86f2818e-6564-439a-92a9-589e792e8033', 'fa', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'آیا راه‌حل شما در مقایسه با آنچه موجود است اساساً نوآورانه است؟', '2026-08-28 19:05:47.749887+00'),
	('47ff5a4b-0979-44e0-a6df-f8e66d1fab3f', 'fa', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'آیا باشگاه به فدراسیون ورزشی تخصصی درون Riksidrottsförbundet وابسته است؟', '2026-08-28 19:05:47.749887+00'),
	('983b280d-211d-43d5-ae80-2d141b5a8905', 'fa', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'آیا درآمد خانوار نسبت به هزینه مسکن پایین است؟', '2026-08-28 19:05:47.749887+00'),
	('79eb4696-1345-4309-99b6-e66bd825bc30', 'fa', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا درآمد جمعی خانوار کمتر از حدود ۲۵٬۰۰۰ کرون در ماه پیش از مالیات است؟', '2026-08-28 19:05:47.749887+00'),
	('bda31860-7d86-4867-8978-bad88e2474a4', 'fa', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'آیا اقدام یک پروژه مشخص است (نه فعالیت عادی)؟', '2026-08-28 19:05:47.749887+00');
INSERT INTO public.kb_translations VALUES
	('1ed9f2c4-31e2-4b69-92ae-9b039020c440', 'fa', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'آیا محل برای همه باز است — نه فقط اعضای خودتان؟', '2026-08-28 19:05:47.749887+00'),
	('3d6b6e89-d7f9-4f94-94b2-baf5467e3fc3', 'fa', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'آیا دست‌کم ۶۰ درصد اعضا بین ۶ و ۲۵ سال دارند؟', '2026-08-28 19:05:47.749887+00'),
	('c32b1b71-02c4-43ed-9e40-4f27ea39fd9b', 'fa', 'Är minst 60 % av medlemmarna under 26 år?', 'آیا دست‌کم ۶۰ درصد اعضا زیر ۲۶ سال هستند؟', '2026-08-28 19:05:47.749887+00'),
	('c865cbf8-d0a4-4239-8bd7-55eef1d2500a', 'fa', 'Är målgruppen delaktig i planering och genomförande?', 'آیا گروه هدف در برنامه‌ریزی و اجرا مشارکت دارد؟', '2026-08-28 19:05:47.749887+00'),
	('425a5a46-ea93-4468-99ed-ae364425c791', 'fa', 'Är ni ett förlag med professionell utgivning?', 'آیا ناشری با انتشار حرفه‌ای هستید؟', '2026-08-28 19:05:47.749887+00'),
	('f8018ed7-0e5d-44f5-a091-2691581a8ca3', 'fa', 'Är ni huvudman för förskoleklass eller grundskola?', 'آیا مسئول یک کلاس پیش‌دبستانی یا مدرسه ابتدایی هستید؟', '2026-08-28 19:05:47.749887+00'),
	('98478343-b845-41d9-915a-ed67f4f32cea', 'fa', 'Är organisationen registrerad i EU:s deltagarregister?', 'آیا سازمان در فهرست شرکت‌کنندگان اتحادیه اروپا ثبت شده است؟', '2026-08-28 19:05:47.749887+00'),
	('450139b3-1267-4bf6-a6c9-ef7997322382', 'fa', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'آیا پروژه یک پروژه سینمایی است (فیلم کوتاه یا مستند)؟', '2026-08-28 19:05:47.749887+00'),
	('ac3bf710-a57a-4e42-86e1-25b45acaaa08', 'fa', 'Är projektet ett konst- eller kulturprojekt?', 'آیا پروژه یک پروژه هنری یا فرهنگی است؟', '2026-08-28 19:05:47.749887+00'),
	('504b442b-4c6a-4dd9-90f4-3ffa60914912', 'fa', 'Är projektet ett kulturprojekt?', 'آیا پروژه یک پروژه فرهنگی است؟', '2026-08-28 19:05:47.749887+00'),
	('c4cbfb47-4355-4743-a108-aeec6b6c1c3d', 'fa', 'Är projektet ett musikprojekt?', 'آیا پروژه یک پروژه موسیقایی است؟', '2026-08-28 19:05:47.749887+00'),
	('790bf64b-bcd7-4b1f-b3ae-7a5918883ed5', 'fa', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'آیا پروژه نوآورانه است — کاری که هم‌اکنون در فعالیت عادی انجام نمی‌دهید؟', '2026-08-28 19:05:47.749887+00'),
	('6c448c83-27b8-43a7-b809-e160a83afdeb', 'fa', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'آیا پروژه به کل منطقه سود می‌رساند (نه به اشخاص)؟', '2026-08-28 19:05:47.749887+00'),
	('f32549a7-d12b-4187-b989-6fdcf921edbd', 'fa', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'آیا مسیر میان خانه و دبیرستان دست‌کم شش کیلومتر است؟', '2026-08-28 19:05:47.749887+00'),
	('f62aa6ed-32fe-4219-ab5f-7e7c2ff9d3ba', 'fa', 'Är verksamheten professionell (inte amatörverksamhet)?', 'آیا فعالیت حرفه‌ای است (نه آماتوری)؟', '2026-08-28 19:05:47.749887+00'),
	('c7c4ee05-405c-4e09-8602-bc5de2a94bcf', 'fa', 'Är verksamheten professionell?', 'آیا فعالیت حرفه‌ای است؟', '2026-08-28 19:05:47.749887+00'),
	('c312661e-458b-4e27-890b-41434e4dff6f', 'fa', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'آیا فعالیت از هنرهای نمایشی است (رقص، تئاتر، تئاتر موزیکال)؟', '2026-08-28 19:05:47.749887+00'),
	('dcccde90-630b-47f1-8598-50a5d429b3fb', 'fa', 'Är volontärerna mellan 18 och 30 år?', 'آیا داوطلبان بین ۱۸ و ۳۰ سال دارند؟', '2026-08-28 19:05:47.749887+00'),
	('fe6a76b5-e573-4987-8723-413027982bbd', 'prs', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'حمایت از فعالیت کلپ‌های ورزشی که فعالیت‌های زیر نظر مربی برای اطفال و جوانان ۷ تا ۲۵ ساله برگزار می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('79bd233a-4df8-45d9-83dc-7b2a4c3b066e', 'prs', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'اضافه خودکار بر کمک مالی اطفال (barnbidrag) از طفل دوم به بعد.', '2026-08-28 19:05:47.755665+00'),
	('5efcb841-1658-46fb-9e17-86122a99b89e', 'prs', 'Avser ansökan en fysisk investering?', 'آیا درخواست مربوط به یک سرمایه‌گذاری فزیکی است؟', '2026-08-28 19:05:47.755665+00'),
	('3632e171-ca7f-4a58-bb1c-d818435ac648', 'prs', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'آیا درخواست مربوط به یک سفر یا تبادله بین‌المللی است؟', '2026-08-28 19:05:47.755665+00'),
	('5e3b8f2d-195c-485c-be25-9fbbdfc106c4', 'prs', 'Avser ansökan en investering i byggnader eller maskiner?', 'آیا درخواست مربوط به سرمایه‌گذاری در تعمیرات یا ماشین‌آلات است؟', '2026-08-28 19:05:47.755665+00'),
	('c090bbce-2d31-4588-852a-ef2b9d5c1155', 'prs', 'Avser ansökan en redan utgiven titel?', 'آیا درخواست مربوط به اثری است که قبلاً چاپ شده است؟', '2026-08-28 19:05:47.755665+00'),
	('6b0fbd84-fee8-4726-baf7-88a79c74baf5', 'prs', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'آیا درخواست مربوط به یک تشبث زراعتی، باغداری یا پرورش گوزن شمالی است؟', '2026-08-28 19:05:47.755665+00'),
	('2dce46dd-af12-4d64-aaa2-42a338518c58', 'prs', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'آیا درخواست مربوط به خرید کتاب برای کتابخانه‌های عامه یا مکتب است؟', '2026-08-28 19:05:47.755665+00'),
	('447d1add-356a-4d4b-bb8d-c351894eda3e', 'prs', 'Avser investeringen jordbruksverksamhet?', 'آیا سرمایه‌گذاری مربوط به فعالیت زراعتی است؟', '2026-08-28 19:05:47.755665+00'),
	('98af87f0-3f84-4725-84b6-65943e673c29', 'prs', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'آیا پروژه شامل ساختن، خریدن یا ترمیم یک محل است؟', '2026-08-28 19:05:47.755665+00'),
	('df6dc1b3-4a21-4ef9-9108-c7b790611b66', 'prs', 'Avser projektet naturvård eller friluftsliv?', 'آیا پروژه مربوط به حفاظت از طبیعت یا تفریح در هوای آزاد است؟', '2026-08-28 19:05:47.755665+00'),
	('94d13f08-e7e2-4797-a6ec-0271343e9cee', 'prs', 'Avser projektet skola eller vuxenutbildning?', 'آیا پروژه مربوط به مکتب یا آموزش بزرگسالان است؟', '2026-08-28 19:05:47.755665+00'),
	('c2daffb3-7b89-4f7b-a98e-335566cd67c1', 'prs', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'آیا از کار دست می‌کشید تا از یکی از نزدیکان که چنان سخت مریض است که مریضی جانش را تهدید می‌کند مراقبت کنید یا در کنارش باشید؟', '2026-08-28 19:05:47.755665+00'),
	('fa067405-4d7f-47c0-a19b-e5da968dcc40', 'prs', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'آیا انجمن در شاروالی فعالیت منظم دارد؟', '2026-08-28 19:05:47.755665+00'),
	('b44b093d-5776-4f2d-a22e-afe48f12cc68', 'prs', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'آیا فکر می‌کنید توان کاری‌تان به دلیل مریضی یا معلولیت دست‌کم برای یک سال کاهش یافته است؟', '2026-08-28 19:05:47.755665+00'),
	('51d7b2ba-10c4-4dce-bad1-e4784d750fef', 'prs', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'حمایت نیازسنجی‌شده برای کسی که تقاعد کم دارد یا ندارد و برای رسیدن به سطح زندگی مناسب به کمک ضرورت دارد.', '2026-08-28 19:05:47.755665+00'),
	('ee478015-0f73-465c-8675-6b8c7ca34d34', 'prs', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'آیا طفل باید به دلیل درازی راه در محل درس اقامت کند (بودوباش)؟', '2026-08-28 19:05:47.755665+00'),
	('f9875476-2bbe-4f8e-aebc-b465fd979a97', 'prs', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'آیا منزل به مناسب‌سازی ضرورت دارد (مثلاً رمپ، بازکننده دروازه، تشناب)؟', '2026-08-28 19:05:47.755665+00'),
	('4eea4f5f-c7d5-49f9-8504-5e6225a68d4f', 'prs', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'آیا یکی از اطفال ۸ تا ۱۹ ساله شما به عینک یا لنز ضرورت دارد؟', '2026-08-28 19:05:47.755665+00'),
	('1eda3da0-f436-4464-869d-8d6c1a99f1d0', 'prs', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'آیا والد دیگر هیچ نفقه نمی‌پردازد یا کمتر از نفقه کامل می‌پردازد؟', '2026-08-28 19:05:47.755665+00'),
	('dd039c7c-b4e7-491b-a92c-d1741d2d0ad0', 'prs', 'Betalar du hyra eller andra boendekostnader?', 'آیا کرایه یا مصارف دیگر مسکن می‌پردازید؟', '2026-08-28 19:05:47.755665+00'),
	('938ea880-6fe6-469e-9fd6-d3795a4533ec', 'prs', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'کمک مالی برای مناسب‌سازی منزل در صورت معلولیت — مثلاً رمپ، بازکننده دروازه یا مناسب‌سازی تشناب.', '2026-08-28 19:05:47.755665+00'),
	('965c232b-56dd-42fe-94ee-60370bde9430', 'prs', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'کمک‌های مالی برای ساختن، خریدن یا ترمیم سالون‌های اجتماعات عامه.', '2026-08-28 19:05:47.755665+00'),
	('8786a820-7459-4d58-9bed-cd0fe4727c22', 'prs', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'کمک مالی برای خرید یا مناسب‌سازی موتر وقتی معلولیت دایمی گشت‌وگذار یا سفر با ترانسپورت عامه را بسیار دشوار می‌سازد.', '2026-08-28 19:05:47.755665+00'),
	('14eaac83-5ca4-4ce2-97e3-48c52b09ea7f', 'prs', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'کمک‌های مالی برای سفرها و تبادله‌های بین‌المللی مسلکی‌های عرصه فرهنگ.', '2026-08-28 19:05:47.755665+00'),
	('c2827e0a-b9d4-4a82-b6d5-96546d3bc1b7', 'prs', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'کمک‌های مالی برای تبادله‌های بین‌المللی، سفرها و اقامت‌های کاری هنرمندان مسلکی.', '2026-08-28 19:05:47.755665+00'),
	('368c10ce-5499-4b97-b443-c906490fe111', 'prs', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'کمک مالی و قرضه اختیاری برای درس در سویه لیسه یا بالاتر از لیسه.', '2026-08-28 19:05:47.755665+00'),
	('598adaf9-d8e2-4d09-9d59-e61783c38fdf', 'prs', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'کمک‌های مالی و قرضه برای تحصیل در خارج، با قرضه‌های اضافی برای مثلاً فیس تحصیلی و سفر.', '2026-08-28 19:05:47.755665+00'),
	('4e451f83-70ac-42fc-9994-1df10fc3ab3a', 'prs', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'کمکی که به نهادهای سویدنی در آماده‌سازی درخواست برای برنامه‌های اتحادیه اروپا مانند Horisont Europa یاری می‌رساند.', '2026-08-28 19:05:47.755665+00'),
	('c2e6be80-fbe7-46a7-9322-6b02f5d7540b', 'prs', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'کمک مالی برای کارفرمایانی که افراد دارای توان کاری کاهش‌یافته را استخدام می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('e65c9670-502f-4baf-9f58-1b6502fa567c', 'prs', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'کمک مالی برای بودوباش و سفرهای بازگشت به خانه وقتی شاگرد لیسه به دلیل درازی راه باید در محل درس اقامت کند.', '2026-08-28 19:05:47.755665+00'),
	('991a34cb-378b-41af-b347-311ba1271f83', 'prs', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'کمک‌های مالی برای کار سازمان‌های غیرانتفاعی در حفظ، استفاده و انکشاف میراث فرهنگی.', '2026-08-28 19:05:47.755665+00');
INSERT INTO public.kb_translations VALUES
	('9f715b3a-c411-4cd3-89f6-e2f31f9b3f01', 'prs', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'کمک‌های مالی برای پروژه‌های شاروالی و محلی حفاظت از طبیعت، به شمول ساحات مرطوب و تفریح در هوای آزاد.', '2026-08-28 19:05:47.755665+00'),
	('6ab8fc0b-ab39-4270-825b-2f946d6e830f', 'prs', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'کمک‌های مالی به شاروالی‌ها برای خرید کتاب برای کتابخانه‌های عامه و مکتب.', '2026-08-28 19:05:47.755665+00'),
	('423c8c36-4b1c-4e65-8945-4501f2721dbd', 'prs', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'کمک‌های مالی به مسئولان مکاتب برای آشنایی شاگردان مکتب ابتداییه با فرهنگ مسلکی.', '2026-08-28 19:05:47.755665+00'),
	('f36b14fb-909d-4656-a37b-b9803f4fd49c', 'prs', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'کمک مالی برای آنچه طفل‌تان ضرورت دارد اما بودجه فامیل کفایت نمی‌کند: فعالیت‌های تفریحی، لباس، سیرهای مکتب، عینک، فعالیت‌های رخصتی و غیره.', '2026-08-28 19:05:47.755665+00'),
	('d2a82493-1383-432e-a934-ffa27c344a0d', 'prs', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'کمک‌های مالی از صندوق‌هایی مانند Världens Barn و Musikhjälpen و Victoriafonden — سازمان‌های غیرانتفاعی سویدنی دارای 90-konto آن را درخواست می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('cf4a096d-be59-4490-8677-08230407fb14', 'prs', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'کمک‌های مالی از عواید برق آبی و بادی برای پروژه‌هایی که منطقه را انکشاف می‌دهند.', '2026-08-28 19:05:47.755665+00'),
	('a1c74990-e5c5-420a-aefb-4490f6f81fce', 'prs', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'کمک مالی بدون بخش قرضه برای بیکاران ۲۵ تا ۶۰ ساله با تحصیلات کوتاه که باید در سویه مکتب ابتداییه یا لیسه درس بخوانند.', '2026-08-28 19:05:47.755665+00'),
	('2da9fab4-ea36-4a0c-90b6-aa63f03f5643', 'prs', 'Bidrar projektet till energiomställningen?', 'آیا پروژه به گذار انرژی کمک می‌کند؟', '2026-08-28 19:05:47.755665+00'),
	('94236857-a1a6-4932-9b9b-3ef12c92bca8', 'prs', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'چک‌هایی برای شرکت‌های کوچک برای جلب تخصص بیرونی در بین‌المللی‌سازی یا دیجیتل‌سازی.', '2026-08-28 19:05:47.755665+00'),
	('75a883f3-845c-44e8-ac46-a440b7eb5f0d', 'prs', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'آیا در برنامه‌ای نزد Arbetsförmedlingen شرکت می‌کنید (مثلاً jobb- och utvecklingsgarantin)؟', '2026-08-28 19:05:47.755665+00'),
	('69c68459-8207-40b8-b690-8b867d27d7f0', 'prs', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'حمایت بعدی از ناشران برای چاپ ادبیات باکیفیت.', '2026-08-28 19:05:47.755665+00'),
	('a1a31d8e-57b0-4a76-884e-3e460a2d1658', 'prs', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'حمایت مالی برای کسی که جواز اقامت مرتبط با حمایت دارد و داوطلبانه می‌خواهد برای همیشه به کشور اصلی خود برگردد.', '2026-08-28 19:05:47.755665+00'),
	('f8643e7e-4e4a-45a8-8ac1-f647b6e3a736', 'prs', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'حمایت مالی از کارفرمایانی که کسی را استخدام می‌کنند که مدت زیادی از زندگی کاری دور بوده است.', '2026-08-28 19:05:47.755665+00'),
	('942283a2-cba6-4095-bc3f-1c03d2ca1d2c', 'prs', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'حمایت مالی در دوره آغاز برای جویندگان کار که تشبث خود را شروع می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('f85b6c69-8359-4edf-a58a-f11fb9f085a9', 'prs', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten به‌طور دوامدار فراخوان‌هایی در تحقیقات انرژی، نوآوری و مؤثریت انرژی باز می‌کند.', '2026-08-28 19:05:47.755665+00'),
	('e22b0c41-5acb-4167-b4da-d7bcf8dc6a2f', 'prs', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'پرداختی برای غیرحاضری از کار یا درس به‌خاطر مراقبت از طفل.', '2026-08-28 19:05:47.755665+00'),
	('d0b2f50b-f1eb-43a8-beaf-a5c06ccb3860', 'prs', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'پرداختی برای کسی که تازه‌وارد سویدن است و در برنامه استقرار Arbetsförmedlingen شرکت می‌کند؛ توسط Försäkringskassan پرداخت می‌شود.', '2026-08-28 19:05:47.755665+00'),
	('9154bf8e-7f40-479b-9047-ac0dc2fa2264', 'prs', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'پرداختی که بخشی از مصارف مسکن جوانان بدون اطفال با عاید کم را می‌پوشاند.', '2026-08-28 19:05:47.755665+00'),
	('9cbd04e9-bc99-49ae-8225-5415a4387dc6', 'prs', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'پرداختی برای مصارف اضافی ناشی از معلولیت دایمی — برای بزرگسالان یا والدین اطفال دارای معلولیت.', '2026-08-28 19:05:47.755665+00'),
	('dd0d9893-6627-485a-b226-742dbfb44ab6', 'prs', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'پرداختی برای جوانان (۱۹–۲۹ ساله) که به دلیل مریضی یا معلولیت دست‌کم یک سال نمی‌توانند تمام‌وقت کار کنند.', '2026-08-28 19:05:47.755665+00'),
	('30a84718-1659-4060-b43d-06b226e45702', 'prs', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'پرداختی وقتی توان کاری به‌طور دایمی کاهش یافته است — آنچه پیش‌تر förtidspension (تقاعد پیش از وقت) نامیده می‌شد.', '2026-08-28 19:05:47.755665+00'),
	('44990cce-5b26-4560-b876-572888bff3ce', 'prs', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'پرداختی وقتی از کار دست می‌کشید تا در کنار یکی از نزدیکانِ سخت مریض باشید.', '2026-08-28 19:05:47.755665+00'),
	('5e319900-8498-4561-be31-5d4c4c90fa59', 'prs', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'پرداختی هنگام شرکت شما در برنامه بازار کار نزد Arbetsförmedlingen.', '2026-08-28 19:05:47.755665+00'),
	('0cd9ad7b-ae94-47b1-8d9e-e2c419b8c97b', 'prs', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'پرداختی وقتی به دلیل مریضی نمی‌توانید مانند معمول کار کنید.', '2026-08-28 19:05:47.755665+00'),
	('503d5ad3-053d-4674-8549-f8aba83abcf7', 'prs', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'پرداختی وقتی برای مراقبت از طفل مریض در خانه می‌مانید.', '2026-08-28 19:05:47.755665+00'),
	('f6a6b7f0-329d-4579-b0c6-2124ededfc4f', 'prs', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'پرداختی که بخشی از مصارف مسکن فامیل‌های دارای اطفال و عاید پایین‌تر را می‌پوشاند.', '2026-08-28 19:05:47.755665+00'),
	('fc27599e-abf5-4262-afea-bd179f7257be', 'prs', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'پرداختی برای والدینی که طفل‌شان به دلیل معلولیت به مراقبت و نظارت بیشتری نسبت به اطفال هم‌سن ضرورت دارد.', '2026-08-28 19:05:47.755665+00'),
	('63355b17-4d5e-4f1a-bb50-b8cabb1c7a9c', 'prs', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'پرداختی در دوران بیکاری — بر اساس عاید برای اعضا، مبلغ اساسی برای دیگران.', '2026-08-28 19:05:47.755665+00'),
	('04aae757-98bf-45fc-b719-77c57ce6e0ce', 'prs', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'در حدود پنجاه بنیاد بانک‌های پس‌انداز به پروژه‌های محلی در ورزش، فرهنگ، تعلیم و انکشاف اجتماعی کمک مالی می‌دهند — در ساحه فعالیت بانک.', '2026-08-28 19:05:47.755665+00'),
	('25af81e0-05df-48a1-b2ca-e37d2ab64edf', 'prs', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'حمایت پروژه‌ای با بودجه اتحادیه اروپا که نزد ساحه Leader محلی شما درخواست می‌شود — برای انجمن‌ها، شرکت‌ها و شاروالی‌هایی که دهات را انکشاف می‌دهند.', '2026-08-28 19:05:47.755665+00'),
	('742b6507-b9bd-468d-bb27-779c400976cc', 'prs', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'حمایت با بودجه اتحادیه اروپا برای جویندگان کار که در کشور دیگری از اتحادیه اروپا/ساحه اقتصادی اروپا وظیفه می‌گیرند: جبران مصارف سفر مصاحبه، مصارف کوچ‌کشی و کورس زبان.', '2026-08-28 19:05:47.755665+00'),
	('1c3fc7f1-764f-42b1-a0e2-03c7edf4c6aa', 'prs', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'بودجه صندوق اجتماعی اروپا برای پروژه‌هایی که مهارت‌ها، گذار وظیفوی و شمولیت در بازار کار را تقویت می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('57fcba8b-f172-45cb-bae2-1014c497d4fb', 'prs', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'حمایت اتحادیه اروپا از تبادله‌های گروهی جوانان ۱۳ تا ۳۰ ساله، برای ۵ تا ۲۱ روز بدون روزهای سفر.', '2026-08-28 19:05:47.755665+00'),
	('85d96295-6b80-4632-af02-93dbf3215622', 'prs', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'حمایت اتحادیه اروپا از پروژه‌های همکاری سازمان‌های فرهنگی با شرکایی در چند کشور اروپایی.', '2026-08-28 19:05:47.755665+00'),
	('88950ced-4923-4a61-a068-3d6ae9b93c67', 'prs', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'حمایت اتحادیه اروپا از سازمان‌هایی که رضاکاران جوان ۱۸ تا ۳۰ ساله را می‌پذیرند یا می‌فرستند.', '2026-08-28 19:05:47.755665+00'),
	('f2d2deb9-0b9b-4a34-a31b-dfe38c66e10d', 'prs', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'حمایت اتحادیه اروپا از تحرک کارمندان و شاگردان در مکتب و آموزش بزرگسالان.', '2026-08-28 19:05:47.755665+00'),
	('b0cf1b32-ed4d-486c-83a8-c61d02226cf9', 'prs', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'حمایت اتحادیه اروپا با مبالغ مقطوع برای نخستین پروژه‌های همکاری اروپایی سازمان‌های کوچک‌تر.', '2026-08-28 19:05:47.755665+00'),
	('16b6157c-1230-45fa-9597-0cc44d61decb', 'prs', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تمویل شرکت‌های جوانی که محصولات یا خدمات نوآورانه با ظرفیت بین‌المللی انکشاف می‌دهند.', '2026-08-28 19:05:47.755665+00'),
	('afd7cbc2-f65f-48ca-bcbd-2eeafad4d188', 'prs', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'آیا در محل فعالیت شما بانک پس‌اندازی (و در نتیجه بنیاد بانک پس‌انداز) وجود دارد؟', '2026-08-28 19:05:47.755665+00'),
	('3d1fb4da-023a-4b4d-acc9-4b88af123c38', 'prs', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'کمک‌های مالی فعالیت چندساله برای گروه‌های مستقل مسلکی رقص، تیاتر و تیاتر موزیکال.', '2026-08-28 19:05:47.755665+00'),
	('1af1f881-3ba3-4dc7-91cb-efeafe2193ca', 'prs', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'کمک‌های مالی تحقیقاتی در عرصه‌های Forte: صحت، زندگی کاری و رفاه. محققان دارای دوکتورا در پوهنتون‌های سویدن درخواست می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('e04cf9a8-7e4b-4e19-a715-034ddc7b5c9f', 'prs', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'بودجه تحقیقاتی برای تحقیقات بنیادی آزاد در همه عرصه‌های علمی.', '2026-08-28 19:05:47.755665+00'),
	('07b28d22-9da3-4715-8196-741cf5e1c4bb', 'prs', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'بودجه تحقیقاتی در محیط‌زیست، علوم زراعتی و شهرسازی.', '2026-08-28 19:05:47.755665+00'),
	('9485577b-596f-41f5-b9e5-62f3bd2fd8b2', 'prs', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'آیا در فکر رفتن به خارج هستید (برای کار، تحصیل یا بازگشت به وطن)؟', '2026-08-28 19:05:47.755665+00'),
	('aedbe41d-1865-4cf0-966f-9c4ac692e25f', 'prs', 'Genomförs insatserna av professionella kulturaktörer?', 'آیا فعالیت‌ها را کنشگران فرهنگی مسلکی اجرا می‌کنند؟', '2026-08-28 19:05:47.755665+00'),
	('fb4fb09e-0428-4251-9c4c-827e7ffde481', 'prs', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'آیا پروژه در دهات یا در قصبه کوچکی اجرا می‌شود؟', '2026-08-28 19:05:47.755665+00'),
	('07f156ac-77bc-4324-a4da-b060b996ace6', 'prs', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حمایت اساسی برای کسی که در طول زندگی عاید کاری کم یا هیچ نداشته است.', '2026-08-28 19:05:47.755665+00'),
	('3ba0a3d3-4555-4b3c-a086-a1ab3fd90775', 'prs', 'Går något av dina barn i grundskolan?', 'آیا یکی از اطفال‌تان به مکتب ابتداییه می‌رود؟', '2026-08-28 19:05:47.755665+00'),
	('12106b48-94e0-41b2-83e4-b1e1ff0b6646', 'prs', 'Går något av dina barn på gymnasiet?', 'آیا یکی از اطفال‌تان در لیسه درس می‌خواند؟', '2026-08-28 19:05:47.755665+00'),
	('f95079f1-97e1-433c-bede-67deab773116', 'prs', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'آیا استخدام مربوط به فردی با توان کاری کاهش‌یافته است؟', '2026-08-28 19:05:47.755665+00');
INSERT INTO public.kb_translations VALUES
	('f83b2ed4-edbc-4304-bc28-8ec7305e59ff', 'prs', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'آیا استخدام مربوط به کسی است که مدت زیادی بیکار بوده یا تازه‌وارد سویدن است؟', '2026-08-28 19:05:47.755665+00'),
	('99d2cdbb-b03e-4d95-880e-082a2d0acb60', 'prs', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'آیا پروژه درباره حفظ میراث فرهنگی یا دسترس‌پذیر ساختن آن است؟', '2026-08-28 19:05:47.755665+00'),
	('22805a83-a6dc-4fcc-ace7-c7703b532b34', 'prs', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'آیا پروژه درباره انرژی، مؤثریت انرژی یا نوآوری مرتبط با انرژی است؟', '2026-08-28 19:05:47.755665+00'),
	('b4f2edfb-b531-4787-89d3-55d0027807ce', 'prs', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'آیا پروژه درباره صحت، زندگی کاری یا رفاه است؟', '2026-08-28 19:05:47.755665+00'),
	('898b6c14-d7a1-4e56-bbc5-e897d8783e5d', 'prs', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'آیا پروژه درباره انکشاف مهارت‌ها یا اقدامات بازار کار است؟', '2026-08-28 19:05:47.755665+00'),
	('76f935f9-39a1-4a2c-9733-474a548051c7', 'prs', 'Handlar projektet om miljö- eller klimatåtgärder?', 'آیا پروژه درباره اقدامات محیط‌زیستی یا اقلیمی است؟', '2026-08-28 19:05:47.755665+00'),
	('ae5795c7-9f1a-4b78-ae8c-78aaf36fb253', 'prs', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'آیا راه طفل به مکتب دراز، به دلیل ترافیک خطرناک یا به شکل دیگری دشوار است؟', '2026-08-28 19:05:47.755665+00'),
	('d8f631cc-4c42-4f2f-92a1-b32e11b1ca5e', 'prs', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'آیا دست‌کم ۱۶ ساعت در هفته و در مجموع دست‌کم ۸ سال کار کرده‌اید؟', '2026-08-28 19:05:47.755665+00'),
	('0421c1be-eaa5-45a5-85b9-c2ed1a8a0032', 'prs', 'Har du barn som bor hos dig, helt eller växelvis?', 'آیا اطفالی دارید که نزد شما زندگی می‌کنند، تمام‌وقت یا به نوبت؟', '2026-08-28 19:05:47.755665+00'),
	('9923e8ea-31b7-4219-8dd2-a45374881bbb', 'prs', 'Har du barn som bor hos dig?', 'آیا اطفالی دارید که نزد شما زندگی می‌کنند؟', '2026-08-28 19:05:47.755665+00'),
	('9b90b29e-7f0a-4f6c-a163-2fe51d8165a5', 'prs', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'آیا شما یا طفل‌تان معلولیتی دارید که انتظار می‌رود دست‌کم یک سال دوام کند؟', '2026-08-28 19:05:47.755665+00'),
	('20c811f0-9d7f-4662-bfb9-c8a1f5f296f1', 'prs', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'آیا شما یا کسی در فامیل معلولیت دایمی دارد که بر مسکن اثر می‌گذارد؟', '2026-08-28 19:05:47.755665+00'),
	('57a9c087-5b57-4223-953e-89d748049e36', 'prs', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'آیا شما یا یکی از نزدیکان معلولیت یا مریضی طولانی یا جدی دارید؟', '2026-08-28 19:05:47.755665+00'),
	('8fb61909-2e0d-4b76-b5f1-c2452cac6bf5', 'prs', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'آیا مریضی یا آسیبی دارید که فعلاً توان کاری شما را کاهش می‌دهد؟', '2026-08-28 19:05:47.755665+00'),
	('f1c4482d-ffb6-4118-9cc8-a712d976dd2d', 'prs', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'آیا تا حال در پرداخت مصارف سیر مکتب، سفر صنفی یا فعالیت تفریحی که انتظار می‌رود طفل‌تان در آن شرکت کند مشکل داشته‌اید؟', '2026-08-28 19:05:47.755665+00'),
	('a952312a-a9eb-4ab0-b7a4-9e36d4d6f8bd', 'prs', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'آیا گذران زندگی با تقاعد و عواید دیگرتان برای‌تان دشوار است؟', '2026-08-28 19:05:47.755665+00'),
	('3d8e9898-5c40-4e77-94bb-cd602547e91e', 'prs', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'آیا در سال‌های اخیر جواز اقامت در سویدن گرفته‌اید، مثلاً به‌عنوان نیازمند حمایت یا عضو فامیل؟', '2026-08-28 19:05:47.755665+00'),
	('b521ba19-864b-4a69-af14-d7de3d1af817', 'prs', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'آیا جواز اقامت در سویدن به‌عنوان پناهنده یا نیازمند حمایت دارید (یا از اقارب نزدیک چنین کسی هستید)؟', '2026-08-28 19:05:47.755665+00'),
	('dad6a2ce-9de7-4185-9446-cbb6b0af81c2', 'prs', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'آیا به سن معیاری تقاعد رسیده‌اید (۶۷ سال در ۲۰۲۶)؟', '2026-08-28 19:05:47.755665+00'),
	('82656a51-57e8-4b48-9d8f-65f8813171bf', 'prs', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'آیا سازمان شما OID (Organisation ID) ثبت‌شده در Organisation Registration System اتحادیه اروپا دارد؟', '2026-08-28 19:05:47.755665+00'),
	('d727f086-feee-4020-a359-a17f00519b83', 'prs', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'آیا معلولیت مصارف اضافی به بار آورده است — مثلاً وسایل کمکی، سفر، غذای خاص یا استهلاک؟', '2026-08-28 19:05:47.755665+00'),
	('34e72151-ccd8-47ea-b27e-58ddf2619f11', 'prs', 'Har föreningen antagna stadgar och en vald styrelse?', 'آیا انجمن اساسنامه تصویب‌شده و هیئت اداری انتخاب‌شده دارد؟', '2026-08-28 19:05:47.755665+00'),
	('5282101d-d727-46c0-8e69-57eb7e76e90e', 'prs', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'آیا انجمن ساختار دموکراتیک دارد (اساسنامه، مجمع سالانه، هیئت اداری)؟', '2026-08-28 19:05:47.755665+00'),
	('bc23a393-bc49-4f9d-bc15-ac14a987537a', 'prs', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'آیا انجمن فعالیت منظمی برای اطفال یا جوانان دارد؟', '2026-08-28 19:05:47.755665+00'),
	('deefccc8-2925-45d7-b436-b9832156e9e5', 'prs', 'Har företaget mellan cirka 2 och 49 anställda?', 'آیا شرکت بین تقریباً ۲ تا ۴۹ کارمند دارد؟', '2026-08-28 19:05:47.755665+00'),
	('4a8f987b-8e94-441e-9c36-186ac8feae7d', 'prs', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'آیا فامیل در تأمین مصارف خوراک، مسکن و ضروری‌ترین چیزها مشکل دارد؟', '2026-08-28 19:05:47.755665+00'),
	('4a24067a-4905-4c12-ba84-936ff5e2a4ba', 'prs', 'Har lösningen internationell potential?', 'آیا راه‌حل ظرفیت بین‌المللی دارد؟', '2026-08-28 19:05:47.755665+00'),
	('30e17caf-c700-4329-9fc5-87a0c49f13c6', 'prs', 'Har ni en partnergrupp i ett annat land?', 'آیا گروه شریکی در کشور دیگری دارید؟', '2026-08-28 19:05:47.755665+00'),
	('f0cc6268-1964-4d43-978e-70dbef43bafe', 'prs', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'آیا سازمان شریکی در کشور اروپایی دیگری دارید؟', '2026-08-28 19:05:47.755665+00'),
	('782de000-f907-42b3-90ec-f8c2476632d0', 'prs', 'Har ni partner i minst tre olika europeiska länder?', 'آیا در دست‌کم سه کشور مختلف اروپایی شریک دارید؟', '2026-08-28 19:05:47.755665+00'),
	('304683f3-d9bb-4591-929f-1357f99bbdef', 'prs', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'آیا دفتر یا فعالیت اصلی شما در ولایتی است که در آن درخواست می‌دهید؟', '2026-08-28 19:05:47.755665+00'),
	('5f0021d1-9304-48df-a696-5c06ce10a717', 'prs', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'آیا یکی از اطفال‌تان معلولیتی دارد که باعث می‌شود به مراقبت یا نظارت بیشتری نسبت به اطفال هم‌سن ضرورت داشته باشد؟', '2026-08-28 19:05:47.755665+00'),
	('d5064194-3ae6-446e-b8af-77530d692719', 'prs', 'Har organisationen en demokratisk uppbyggnad?', 'آیا سازمان ساختار دموکراتیک دارد؟', '2026-08-28 19:05:47.755665+00'),
	('90292fd7-34c1-42c5-85d5-d6ef82743fa9', 'prs', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'آیا سازمان Quality Label (نشان کیفیت) دارد؟', '2026-08-28 19:05:47.755665+00'),
	('30583e1c-f283-4d88-a169-69248fe22d02', 'prs', 'Har organisationen ett 90-konto?', 'آیا سازمان 90-konto دارد؟', '2026-08-28 19:05:47.755665+00'),
	('f144a1d2-ecd6-4efc-a5c9-54438244bedb', 'prs', 'Har organisationen ett OID (Organisation ID)?', 'آیا سازمان OID (Organisation ID) دارد؟', '2026-08-28 19:05:47.755665+00'),
	('86c07d11-0099-45b8-8b51-6c553c0f49a0', 'prs', 'Har organisationen ett OID?', 'آیا سازمان OID دارد؟', '2026-08-28 19:05:47.755665+00'),
	('f6df8b65-95c6-4e25-84ed-7e69e20ec56b', 'prs', 'Har organisationen medlemsföreningar i flera län?', 'آیا سازمان انجمن‌های عضو در چند ولایت دارد؟', '2026-08-28 19:05:47.755665+00'),
	('ad1a633e-31cb-4b6d-814c-6801be1dfd98', 'prs', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'آیا سازمان مالی منظم و ساختار دموکراتیک دارد؟', '2026-08-28 19:05:47.755665+00'),
	('ebe2361f-d008-4785-a3ba-7809936e5843', 'prs', 'Har projektet en partner i ett annat land?', 'آیا پروژه شریکی در کشور دیگری دارد؟', '2026-08-28 19:05:47.755665+00'),
	('6bb20541-874b-40c3-9db4-aa14ba04ad68', 'prs', 'Har projektledaren doktorsexamen?', 'آیا مسئول پروژه سند دوکتورا دارد؟', '2026-08-28 19:05:47.755665+00'),
	('28e269c5-1c73-4aae-8e69-fb8167c69d3a', 'prs', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'شاروالی محل بودوباش باید رفت‌وآمد روزانه میان خانه و لیسه را وقتی راه دست‌کم شش کیلومتر است تأمین کند (مثلاً کارت سرویس).', '2026-08-28 19:05:47.755665+00'),
	('9f49381b-811d-4e1e-9a56-0012b55d1dba', 'prs', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'آیا در حال تهیه یا تجهیز نخستین خانه شخصی خود در سویدن هستید؟', '2026-08-28 19:05:47.755665+00'),
	('73ae6d25-f02d-4777-b60d-6c946cf75a27', 'prs', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'آیا پروژه شامل سفر یا تبادله بین‌المللی است؟', '2026-08-28 19:05:47.755665+00'),
	('b98d7fa7-6c16-4cec-8d9d-57736c117d40', 'prs', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'حمایت سرمایه‌گذاری از شرکت‌ها در ساحات حمایتی برای تعمیرات، ماشین‌آلات و آموزش.', '2026-08-28 19:05:47.755665+00'),
	('98da20ac-1965-4057-aafd-493f7d4999aa', 'prs', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'حمایت سرمایه‌گذاری از اقداماتی که انتشار گازهای گلخانه‌ای را کاهش می‌دهند.', '2026-08-28 19:05:47.755665+00'),
	('840a5691-3c95-4dce-9844-d1565bc0bb39', 'prs', 'Kan åtgärdens utsläppsminskning beräknas?', 'آیا کاهش انتشار حاصل از اقدام قابل محاسبه است؟', '2026-08-28 19:05:47.755665+00'),
	('968f1bd7-c423-4034-aeb6-bf76598b0f66', 'prs', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'آیا سازمان می‌تواند مصارف را تا پرداخت حمایت به دوش بگیرد؟', '2026-08-28 19:05:47.755665+00'),
	('0724fa74-75a6-4073-8764-804e1a2c93c5', 'prs', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'آیا تجربه‌ها در فعالیت شما در سویدن به کار گرفته می‌شوند؟', '2026-08-28 19:05:47.755665+00'),
	('443f518d-7b1b-4091-8c14-387d60c7d960', 'prs', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'آیا سرمایه‌گذاری تنها بعد از ارسال درخواست آغاز می‌شود؟', '2026-08-28 19:05:47.755665+00');
INSERT INTO public.kb_translations VALUES
	('293299fc-fe07-489d-951f-0949445bc282', 'prs', 'Kommer projektet människor i ert närområde till del?', 'آیا پروژه به مردم منطقه شما فایده می‌رساند؟', '2026-08-28 19:05:47.755665+00'),
	('b9ed2b34-a172-403a-acb1-80d56537ce27', 'prs', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'واپسین شبکه ایمنی اقتصادی شاروالی وقتی عواید کفاف ضروری‌ترین چیزها را نمی‌دهند.', '2026-08-28 19:05:47.755665+00'),
	('0a98e942-9b6b-499a-a50d-6d5263fc2d54', 'prs', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'حمایت‌های خود شاروالی‌ها از انجمن‌های محلی: کمک مالی فعالیت به ازای هر جلسه، کمک مالی محل، کمک مالی آغاز و غیره.', '2026-08-28 19:05:47.755665+00'),
	('c10a7688-9221-45ce-9550-3e4294a63492', 'prs', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'سرویس رایگان مکتب برای شاگردان مکتب ابتداییه در صورت فاصله دراز، راه خطرناک یا معلولیت — حقی طبق قانون مکاتب.', '2026-08-28 19:05:47.755665+00'),
	('97575702-9d10-404d-8673-53999f3250f4', 'prs', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'کمک مالی قانونی عینک یا لنز برای اطفال و جوانان؛ مبالغ و طرزالعمل‌ها در هر ولایت متفاوت است — سطح ولایت خود را بررسی کنید.', '2026-08-28 19:05:47.755665+00'),
	('a5ceed24-f153-4187-8004-b23f7855546e', 'prs', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'آیا پروژه در منطقه‌ای است که برق آبی یا بادی به آن مربوط می‌شود؟', '2026-08-28 19:05:47.755665+00'),
	('77bc7fa3-c947-417f-974f-4a047d3f4b0b', 'prs', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'آیا پروژه در عرصه محیط‌زیست، علوم زراعتی یا شهرسازی است؟', '2026-08-28 19:05:47.755665+00'),
	('c45ca850-7e96-450b-9d49-79fb7a962cb3', 'prs', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'آیا محل فعالیت در ساحه حمایتی A یا B است (بخش‌های بزرگ نورلند و سویالند داخلی)؟', '2026-08-28 19:05:47.755665+00'),
	('860692a1-0b95-49fb-8156-df6eed1ed21d', 'prs', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'قرضه‌ای برای خرید ضروری‌ترین چیزها برای نخستین خانه در سویدن — فرنیچر، لوازم خانه و دیگر تجهیزات اساسی.', '2026-08-28 19:05:47.755665+00'),
	('dfe4fe61-8317-4f40-b566-4d6d88676688', 'prs', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'آیا پروژه انتشار پروسه‌ای صنعت را کاهش می‌دهد یا انتشار منفی ایجاد می‌کند؟', '2026-08-28 19:05:47.755665+00'),
	('045d2330-aa58-452c-863c-10ccf4c26cdb', 'prs', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'کمک مالی ماهانه برای اطفال مقیم سویدن، از تولد تا ۱۶ سالگی.', '2026-08-28 19:05:47.755665+00'),
	('fa7d0f9b-1785-4c42-8828-a30bc40871c2', 'prs', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket به سازمان‌ها، شرکت‌ها، انجمن‌ها، سکتور عامه و اشخاص در عرصه محیط‌زیست کمک مالی می‌دهد.', '2026-08-28 19:05:47.755665+00'),
	('40b32070-462e-4683-a683-bb41c6858ce6', 'prs', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'آیا قصد دارید داوطلبانه برای همیشه به کشور اصلی خود برگردید؟', '2026-08-28 19:05:47.755665+00'),
	('6559c6e2-d816-41b1-9dba-b303d39e37ea', 'prs', 'Planerar du att starta eget företag?', 'آیا قصد دارید تشبث شخصی خود را آغاز کنید؟', '2026-08-28 19:05:47.755665+00'),
	('2ecd45a5-9d2b-4133-9fdd-2b0a0ddcc276', 'prs', 'Planerar du att studera utomlands?', 'آیا قصد تحصیل در خارج را دارید؟', '2026-08-28 19:05:47.755665+00'),
	('bd3ae34a-3602-4c90-926d-ab0a5f8fdde1', 'prs', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'آیا قصد درسی دارید که موقعیت شما را در بازار کار تقویت کند؟', '2026-08-28 19:05:47.755665+00'),
	('32a240e9-4847-413d-b4ac-0fa2b290d628', 'prs', 'Planerar ni att anställa?', 'آیا قصد استخدام دارید؟', '2026-08-28 19:05:47.755665+00'),
	('b24d3755-d85b-4078-92bb-0a1eb1786015', 'prs', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'آیا قصد دارید برای برنامه‌ای از اتحادیه اروپا (مثلاً Horisont Europa) درخواست بدهید؟', '2026-08-28 19:05:47.755665+00'),
	('2cacfb52-cfda-4983-9a7f-643be8c325e0', 'prs', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'حمایت از تولید و انکشاف فلم کوتاه و مستند.', '2026-08-28 19:05:47.755665+00'),
	('5b1dbe4b-b477-49cf-a47f-367b2c5f3b62', 'prs', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'کمک‌های مالی پروژه‌ای برای صحنه موسیقی آزاد: کنسرت، تولید و انکشاف.', '2026-08-28 19:05:47.755665+00'),
	('2aefab55-fb0e-48af-b8c4-9f4fd9b96dbd', 'prs', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'کمک‌های مالی پروژه‌ای برای سازمان‌های غیرانتفاعی که با اطفال و جوانان و برای آنان کار می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('ac545ab1-1be8-4e7c-9f95-5f0827139cc7', 'prs', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'آیا پروژه بیان‌ها، روش‌ها یا همکاری‌های هنری تازه‌ای می‌آزماید؟', '2026-08-28 19:05:47.755665+00'),
	('7752ccb5-9b0a-4dd4-97f7-ae039a2c5ee6', 'prs', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'آیا تبادله ۵ تا ۲۱ روز دوام می‌کند (بدون روزهای سفر)؟', '2026-08-28 19:05:47.755665+00'),
	('666e14bb-8404-4782-a020-401936b95d6b', 'prs', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'حمایت‌های خود ولایات از پروژه‌ها و فعالیت‌های فرهنگی، در پهلوی کمک‌های ملی Kulturrådet.', '2026-08-28 19:05:47.755665+00'),
	('1af93dbf-b397-4dd9-80ea-228c6d377bbd', 'prs', 'Riktar sig projektet till barn eller unga?', 'آیا پروژه اطفال یا جوانان را هدف قرار می‌دهد؟', '2026-08-28 19:05:47.755665+00'),
	('722bebfe-9e4e-41cf-b7da-2a98ab142944', 'prs', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'آیا پروژه اطفال، جوانان، کهنسالان یا افراد دارای معلولیت را هدف قرار می‌دهد؟', '2026-08-28 19:05:47.755665+00'),
	('197051fc-524e-4a6f-9e44-07c7b7124bde', 'prs', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'آیا فعالیت اطفال و جوانان (۷–۲۵ ساله) را هدف قرار می‌دهد؟', '2026-08-28 19:05:47.755665+00'),
	('f39888b6-f465-46f1-9ab1-b4978563fc8d', 'prs', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'آیا پس‌انداز یا دارایی‌ای ندارید که بتواند مصارف را بپوشاند؟', '2026-08-28 19:05:47.755665+00'),
	('59522342-b7e9-4fa7-932e-c8342e1a9c0c', 'prs', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'آیا با شرکایی در دست‌کم دو کشور دیگر شمال اروپا همکاری می‌کنید؟', '2026-08-28 19:05:47.755665+00'),
	('cce5da62-9b08-4fdb-9ca6-308804abe982', 'prs', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'آیا برای یک اقدام انکشافی تخصص بیرونی جلب می‌کنید؟', '2026-08-28 19:05:47.755665+00'),
	('37296051-f628-432a-ab62-a69b32a650ed', 'prs', 'Sker mobiliteten till ett annat europeiskt land?', 'آیا تحرک به کشور اروپایی دیگری است؟', '2026-08-28 19:05:47.755665+00'),
	('e073c9bb-1bdd-4e87-80d5-9126bb23e30b', 'prs', 'Startar du eller tar du över företaget för första gången?', 'آیا برای نخستین بار تشبث را آغاز می‌کنید یا تسلیم می‌شوید؟', '2026-08-28 19:05:47.755665+00'),
	('9726993b-b9d2-4550-8f4c-d328b80ece99', 'prs', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'حمایت آغاز برای کسی که ۴۰ ساله یا جوان‌تر است و تشبث زراعتی را آغاز می‌کند یا تسلیم می‌شود.', '2026-08-28 19:05:47.755665+00'),
	('c23baed9-885c-47e9-a744-4cdc3ac1aae0', 'prs', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'بورسیه‌ای که به هنرمندان مسلکی امکان می‌دهد بر کار هنری تمرکز کنند.', '2026-08-28 19:05:47.755665+00'),
	('1da03578-1859-4442-b97e-fce71e83e9ca', 'prs', 'Studerar du, eller planerar du att börja studera?', 'آیا درس می‌خوانید یا قصد شروع درس دارید؟', '2026-08-28 19:05:47.755665+00'),
	('eff7f5fb-0981-462a-8efa-5c7cb366d00d', 'prs', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'حمایت درسی برای بزرگسالان شاغل که می‌خواهند برای تقویت موقعیت خود در بازار کار آموزش ببینند.', '2026-08-28 19:05:47.755665+00'),
	('9b55be1a-52e9-41ee-b944-9fababd3c997', 'prs', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'حمایت از سرمایه‌گذاری‌هایی که رقابت‌پذیری را افزایش یا اثرات محیط‌زیستی را در تشبثات زراعتی کاهش می‌دهند.', '2026-08-28 19:05:47.755665+00'),
	('89dbd518-8116-4497-8ea1-3d2466cf2fbc', 'prs', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'حمایتی وقتی طفلی نزد شما زندگی می‌کند و والد دیگر نفقه نمی‌پردازد.', '2026-08-28 19:05:47.755665+00'),
	('b7af0075-ed89-47bc-88b7-c4a348db39cb', 'prs', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'حمایت از پروژه‌های سازمان‌های غیرانتفاعی برای مردم، محیط‌زیست و جهانی بهتر.', '2026-08-28 19:05:47.755665+00'),
	('af19db45-9079-4ad6-bb0c-841ba24a3280', 'prs', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'حمایت از گذار صنعت به سوی انتشار صفری گازهای گلخانه‌ای.', '2026-08-28 19:05:47.755665+00'),
	('c0c66538-5f7c-4530-b474-e7958317c9c5', 'prs', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'حمایت از پروژه‌های هنری و فرهنگی با بُعد نوردیک و همکاری فرامرزی.', '2026-08-28 19:05:47.755665+00'),
	('531c5038-6aaf-44fc-9acd-fe726c1fb83b', 'prs', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'حمایت از پروژه‌های فرهنگی نوآورانه که بیان‌ها، روش‌ها یا همکاری‌های هنری تازه می‌آزمایند.', '2026-08-28 19:05:47.755665+00'),
	('955fe15c-6458-4a5d-bc10-706f376a8d08', 'prs', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'حمایت از پروژه‌های نوآورانه برای اطفال، جوانان، کهنسالان و افراد دارای معلولیت.', '2026-08-28 19:05:47.755665+00'),
	('4d9abb27-930c-4ff5-a340-4c538ed20926', 'prs', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'حمایت از پروژه‌های همکاری در صحنه موسیقی آزاد.', '2026-08-28 19:05:47.755665+00'),
	('a2a9ffd2-d52d-4f21-bd8e-8ed68e3b4d87', 'prs', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'حمایت از پروژه‌های همکاری در فرهنگ و رسانه که دموکراسی و آزادی بیان را در سطح بین‌المللی تقویت می‌کنند.', '2026-08-28 19:05:47.755665+00'),
	('52cd22ce-f5b2-40af-a612-1b1eac8b8322', 'prs', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'آیا هدف پروژه تقویت دموکراسی، برابری یا آزادی بیان است؟', '2026-08-28 19:05:47.755665+00'),
	('6fc04898-cd50-4bbe-8f88-7893f8fb9372', 'prs', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'آیا در کشور دیگری از اتحادیه اروپا یا ساحه اقتصادی اروپا دنبال وظیفه می‌گردید یا پیشنهاد وظیفه گرفته‌اید؟', '2026-08-28 19:05:47.755665+00'),
	('5430ff03-0211-4b1f-a44f-9d3a4c57f93b', 'prs', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقفی برای آنچه در دوره دوازده‌ماهه بابت فیس مریض می‌پردازید — بعد از آن frikort (کارت رایگان).', '2026-08-28 19:05:47.755665+00'),
	('65b45e1e-4c30-4bd9-bc01-f747f13479e0', 'prs', 'Tar du ut hel allmän pension?', 'آیا تقاعد عمومی کامل خود را می‌گیرید؟', '2026-08-28 19:05:47.755665+00'),
	('21de2deb-fb4b-4015-90c4-bf962b5072bf', 'prs', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'اضافه‌ای که بخشی از مصارف مسکن را برای کسی که تقاعد و عاید کم دارد می‌پوشاند.', '2026-08-28 19:05:47.755665+00');
INSERT INTO public.kb_translations VALUES
	('64462acc-9318-4fcd-b1a7-a3bf7f6bdf9b', 'prs', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'کمک مالی سازمانی سالانه برای سازمان‌های ملی اطفال و جوانان.', '2026-08-28 19:05:47.755665+00'),
	('49566d83-61ea-4e65-b479-f696eb8f1860', 'prs', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'اعتبار سالانه‌ای که مستقیماً نزد داکتر دندان یا صحی‌کار دندان کم می‌شود.', '2026-08-28 19:05:47.755665+00'),
	('53b666e6-13df-495d-ae8b-713fffd1c099', 'prs', 'Är bolaget yngre än cirka 5 år?', 'آیا عمر شرکت کمتر از تقریباً ۵ سال است؟', '2026-08-28 19:05:47.755665+00'),
	('732a0565-4dc2-4e2f-9d25-682a54f2dc09', 'prs', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'آیا اشتراک‌کنندگان تبادله بین ۱۳ و ۳۰ سال دارند؟', '2026-08-28 19:05:47.755665+00'),
	('2be72af9-bcb5-4b3d-b79a-1692cce15826', 'prs', 'Är det här ert första EU-projekt?', 'آیا این نخستین پروژه اتحادیه اروپای شماست؟', '2026-08-28 19:05:47.755665+00'),
	('08b7d72d-8ce4-4816-9537-b9361a4182e0', 'prs', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'آیا برای شما (یا طفل‌تان) گشت‌وگذار مستقل یا سفر با سرویس و قطار بسیار دشوار است؟', '2026-08-28 19:05:47.755665+00'),
	('29bb4369-3ee8-46a8-b4e5-4c3fec08f825', 'prs', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا عاید شما کمتر از تقریباً ۲۵٬۰۰۰ کرون در ماه پیش از مالیه است؟', '2026-08-28 19:05:47.755665+00'),
	('f671a3f4-d780-4ed0-848f-155c7a7c3dfe', 'prs', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'آیا آخرین تحصیل تمام‌شده شما مکتب ابتداییه است، یا لیسه‌ای که تمامش نکردید؟', '2026-08-28 19:05:47.755665+00'),
	('1bbba0f5-3e3e-4903-a6a2-3bb90aa33a64', 'prs', 'Är du 40 år eller yngre?', 'آیا ۴۰ ساله یا جوان‌تر هستید؟', '2026-08-28 19:05:47.755665+00'),
	('ad3e9db2-554a-4493-ba6c-0fb3ddeb7474', 'prs', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'آیا به‌عنوان جوینده کار نزد Arbetsförmedlingen ثبت‌نام شده‌اید؟', '2026-08-28 19:05:47.755665+00'),
	('d38bc910-197a-4d1a-91d9-a1f579ab1eac', 'prs', 'Är du mellan 18 och 28 år?', 'آیا بین ۱۸ و ۲۸ سال دارید؟', '2026-08-28 19:05:47.755665+00'),
	('b937ad3d-32a8-4c4f-a888-141e0e4bebcb', 'prs', 'Är du mellan 19 och 29 år?', 'آیا بین ۱۹ و ۲۹ سال دارید؟', '2026-08-28 19:05:47.755665+00'),
	('46c792d2-9107-402b-86b7-9614c5f4c938', 'prs', 'Är du mellan 25 och 60 år?', 'آیا بین ۲۵ و ۶۰ سال دارید؟', '2026-08-28 19:05:47.755665+00'),
	('78e2232f-c223-44ef-b876-b65768446ed8', 'prs', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'آیا به‌طور مسلکی در عرصه فرهنگ فعالیت می‌کنید (مثلاً رقص، موسیقی، هنرهای نمایشی)؟', '2026-08-28 19:05:47.755665+00'),
	('5a29e8f9-2670-4d99-9cf8-973fc5b37879', 'prs', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'آیا هنرمند مسلکی هستید (نه شوقی و نه در آموزش اساسی)؟', '2026-08-28 19:05:47.755665+00'),
	('b1878d59-d448-40ee-8edf-f7c6bbefb771', 'prs', 'Är du yrkesverksam konstnär?', 'آیا هنرمند مسلکی هستید؟', '2026-08-28 19:05:47.755665+00'),
	('957a693a-892f-4b91-b465-ceba5203a5f8', 'prs', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'آیا راه‌حل شما در مقایسه با آنچه موجود است اساساً نوآورانه است؟', '2026-08-28 19:05:47.759459+00'),
	('e802c3d3-8f31-4e73-bb14-be762e65d174', 'prs', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'آیا کلپ به فدراسیون ورزشی تخصصی درون Riksidrottsförbundet وابسته است؟', '2026-08-28 19:05:47.759459+00'),
	('f68f1f4a-fe4f-4560-b60b-cfcca716cc4e', 'prs', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'آیا عاید فامیل نسبت به مصارف مسکن پایین است؟', '2026-08-28 19:05:47.759459+00'),
	('75f969cc-74dd-493b-8e32-edd6ce8af4ec', 'prs', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا عاید مجموعی فامیل کمتر از تقریباً ۲۵٬۰۰۰ کرون در ماه پیش از مالیه است؟', '2026-08-28 19:05:47.759459+00'),
	('e7238d85-3905-451c-8a73-948a23c9f495', 'prs', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'آیا اقدام یک پروژه مشخص است (نه فعالیت عادی)؟', '2026-08-28 19:05:47.759459+00'),
	('d108df04-a546-456f-a261-11b1339fbd00', 'prs', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'آیا محل برای همه باز است — نه تنها اعضای خودتان؟', '2026-08-28 19:05:47.759459+00'),
	('60ea4f58-cfe6-4308-b4f1-6bd8750c95fc', 'prs', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'آیا دست‌کم ۶۰ فیصد اعضا بین ۶ و ۲۵ سال دارند؟', '2026-08-28 19:05:47.759459+00'),
	('bff4e47d-5d97-4663-a621-b08c0e006f1d', 'prs', 'Är minst 60 % av medlemmarna under 26 år?', 'آیا دست‌کم ۶۰ فیصد اعضا زیر ۲۶ سال هستند؟', '2026-08-28 19:05:47.759459+00'),
	('ee5c0d70-aac1-4e2d-a06e-24eb15b3a484', 'prs', 'Är målgruppen delaktig i planering och genomförande?', 'آیا گروه هدف در پلان‌گذاری و اجرا سهم دارد؟', '2026-08-28 19:05:47.759459+00'),
	('7dfb66a1-9fef-4f75-8e4e-45234ea09df3', 'prs', 'Är ni ett förlag med professionell utgivning?', 'آیا ناشری با نشرات مسلکی هستید؟', '2026-08-28 19:05:47.759459+00'),
	('e8ad51ad-6afa-46bd-b03f-d29e45693503', 'prs', 'Är ni huvudman för förskoleklass eller grundskola?', 'آیا مسئول یک صنف آمادگی یا مکتب ابتداییه هستید؟', '2026-08-28 19:05:47.759459+00'),
	('461a044f-6a16-4720-8077-a3340eec2281', 'prs', 'Är organisationen registrerad i EU:s deltagarregister?', 'آیا سازمان در فهرست اشتراک‌کنندگان اتحادیه اروپا ثبت شده است؟', '2026-08-28 19:05:47.759459+00'),
	('d4692a56-a2bb-44ad-8f3e-e459ba4d3226', 'prs', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'آیا پروژه یک پروژه سینمایی است (فلم کوتاه یا مستند)؟', '2026-08-28 19:05:47.759459+00'),
	('0357554c-2f50-410d-901a-f85b2baf3955', 'prs', 'Är projektet ett konst- eller kulturprojekt?', 'آیا پروژه یک پروژه هنری یا فرهنگی است؟', '2026-08-28 19:05:47.759459+00'),
	('20c98ab4-4987-4924-a9af-b5b7ea33372b', 'prs', 'Är projektet ett kulturprojekt?', 'آیا پروژه یک پروژه فرهنگی است؟', '2026-08-28 19:05:47.759459+00'),
	('532b14ea-253b-4055-802b-5ce4833be1b6', 'prs', 'Är projektet ett musikprojekt?', 'آیا پروژه یک پروژه موسیقی است؟', '2026-08-28 19:05:47.759459+00'),
	('6ba92c13-9e89-44b0-8c0a-c03412a4248d', 'prs', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'آیا پروژه نوآورانه است — کاری که فعلاً در فعالیت عادی انجام نمی‌دهید؟', '2026-08-28 19:05:47.759459+00'),
	('a64a8dfb-4e46-480b-af2a-eed978a4091e', 'prs', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'آیا پروژه به کل منطقه فایده می‌رساند (نه به اشخاص)؟', '2026-08-28 19:05:47.759459+00'),
	('c0befa46-f855-41e6-9cf3-c7f081efab0a', 'prs', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'آیا راه میان خانه و لیسه دست‌کم شش کیلومتر است؟', '2026-08-28 19:05:47.759459+00'),
	('69c93ca4-5e67-490b-ad13-32fcc9cef531', 'prs', 'Är verksamheten professionell (inte amatörverksamhet)?', 'آیا فعالیت مسلکی است (نه شوقی)؟', '2026-08-28 19:05:47.759459+00'),
	('83f87f1d-729e-4d96-82d6-b7b6dfa43358', 'prs', 'Är verksamheten professionell?', 'آیا فعالیت مسلکی است؟', '2026-08-28 19:05:47.759459+00'),
	('02dd173a-3397-4fe4-a146-99cdc96eb743', 'prs', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'آیا فعالیت از هنرهای نمایشی است (رقص، تیاتر، تیاتر موزیکال)؟', '2026-08-28 19:05:47.759459+00'),
	('041327c8-729c-4062-a5d6-09d19ac0984e', 'prs', 'Är volontärerna mellan 18 och 30 år?', 'آیا رضاکاران بین ۱۸ و ۳۰ سال دارند؟', '2026-08-28 19:05:47.759459+00'),
	('26598213-4c5f-4804-a5d7-f13a33e37972', 'ru', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Поддержка деятельности спортивных клубов, проводящих занятия под руководством тренеров для детей и молодёжи 7–25 лет.', '2026-08-28 19:05:47.765794+00'),
	('86e5ff69-7930-46a1-87eb-af26039b0420', 'ru', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Автоматическая надбавка к детскому пособию (barnbidrag) начиная со второго ребёнка.', '2026-08-28 19:05:47.765794+00'),
	('db9a0384-9ef0-44e1-87e5-f5e68b6a1d4d', 'ru', 'Avser ansökan en fysisk investering?', 'Касается ли заявка физической инвестиции?', '2026-08-28 19:05:47.765794+00'),
	('6c8376e3-a521-47b7-9eca-afca72580415', 'ru', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Касается ли заявка международной поездки или обмена?', '2026-08-28 19:05:47.765794+00'),
	('4a6c3af0-3c72-4241-98f3-2f9e67ea6d18', 'ru', 'Avser ansökan en investering i byggnader eller maskiner?', 'Касается ли заявка инвестиции в здания или оборудование?', '2026-08-28 19:05:47.765794+00'),
	('28b075e9-728f-423a-b946-eb808ee5832b', 'ru', 'Avser ansökan en redan utgiven titel?', 'Касается ли заявка уже изданного произведения?', '2026-08-28 19:05:47.765794+00'),
	('79e14370-451a-47e4-9cec-629beb980b14', 'ru', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Касается ли заявка сельскохозяйственного, садоводческого или оленеводческого предприятия?', '2026-08-28 19:05:47.765794+00'),
	('6f77acc8-0e6d-496e-aa36-4fcbde7f6b1e', 'ru', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Касается ли заявка закупки литературы для публичных или школьных библиотек?', '2026-08-28 19:05:47.765794+00'),
	('0e7205fb-c9ea-48be-bf19-c35b16a555c0', 'ru', 'Avser investeringen jordbruksverksamhet?', 'Касается ли инвестиция сельскохозяйственной деятельности?', '2026-08-28 19:05:47.765794+00'),
	('42864f5e-12c0-4d1e-97a3-1d03c47378d6', 'ru', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Предполагает ли проект строительство, покупку или ремонт помещения?', '2026-08-28 19:05:47.765794+00'),
	('02119d37-0422-418d-94b7-a15c521caaab', 'ru', 'Avser projektet naturvård eller friluftsliv?', 'Касается ли проект охраны природы или активного отдыха на природе?', '2026-08-28 19:05:47.765794+00');
INSERT INTO public.kb_translations VALUES
	('b17b2098-c60d-42dc-b83e-f94dd2e8e1c4', 'ru', 'Avser projektet skola eller vuxenutbildning?', 'Касается ли проект школы или образования взрослых?', '2026-08-28 19:05:47.765794+00'),
	('9d7b837b-93f0-4542-b8e1-67ab10471601', 'ru', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Отказываетесь ли вы от работы, чтобы ухаживать за близким человеком или быть рядом с ним, когда болезнь настолько тяжела, что угрожает его жизни?', '2026-08-28 19:05:47.765794+00'),
	('b9fa5d82-7161-462b-b523-783e89985064', 'ru', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Ведёт ли объединение регулярную деятельность в коммуне?', '2026-08-28 19:05:47.765794+00'),
	('33003b9a-256f-41d6-b599-7849e7442ffa', 'ru', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Считаете ли вы, что ваша трудоспособность снижена как минимум на год из-за болезни или инвалидности?', '2026-08-28 19:05:47.765794+00'),
	('804e1d58-b247-4831-ba3e-09955e4a6809', 'ru', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Адресная поддержка для тех, у кого низкая пенсия или её нет, и кому нужна помощь для достижения разумного уровня жизни.', '2026-08-28 19:05:47.765794+00'),
	('8ac0654c-ffb9-4534-935d-3e02eecd8d26', 'ru', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Нужно ли ребёнку жить в месте учёбы (проживание) из-за слишком долгой дороги?', '2026-08-28 19:05:47.765794+00'),
	('986472e8-817a-4bb1-9a26-07f4fa5ff8d3', 'ru', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Нужно ли адаптировать жильё (например, пандус, автоматическая дверь, ванная)?', '2026-08-28 19:05:47.765794+00'),
	('d1ce4488-c0b7-4597-ae3b-851af76e0ac4', 'ru', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Нужны ли кому-то из ваших детей 8–19 лет очки или линзы?', '2026-08-28 19:05:47.765794+00'),
	('9cf5f8b5-e6dc-4132-9d81-bf63719e3edb', 'ru', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Другой родитель не платит ничего или платит меньше полного содержания?', '2026-08-28 19:05:47.765794+00'),
	('3bd23363-11ec-43e4-88a7-dcaa431e72cf', 'ru', 'Betalar du hyra eller andra boendekostnader?', 'Платите ли вы аренду или другие расходы на жильё?', '2026-08-28 19:05:47.765794+00'),
	('ee8411af-0ae4-4456-9440-a4b0cf540adc', 'ru', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Пособие на адаптацию жилья при инвалидности — например, пандусы, автоматические двери или переоборудование ванной.', '2026-08-28 19:05:47.765794+00'),
	('cc50c293-496e-4e9d-b988-59fec8879907', 'ru', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Пособия на строительство, покупку или ремонт общественных помещений для собраний.', '2026-08-28 19:05:47.765794+00'),
	('c15541d5-5fa5-4aee-b530-9471658d9e48', 'ru', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Пособие на покупку или адаптацию автомобиля, когда стойкая инвалидность сильно затрудняет передвижение или поездки на общественном транспорте.', '2026-08-28 19:05:47.765794+00'),
	('c8c29f2e-d941-47ad-8280-f564740ec13f', 'ru', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Пособия на международные поездки и обмены для профессионалов в сфере культуры.', '2026-08-28 19:05:47.765794+00'),
	('009da5cc-00aa-4342-b5a2-655267ea1f8e', 'ru', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Пособия на международные обмены, поездки и рабочие пребывания профессиональных художников.', '2026-08-28 19:05:47.765794+00'),
	('84d0963a-03c1-4b4c-bf9a-cae0e3ac89d3', 'ru', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Пособие и добровольный заём для учёбы на гимназическом или послегимназическом уровне.', '2026-08-28 19:05:47.765794+00'),
	('6d7788be-70cb-4381-9962-ef0668784292', 'ru', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Пособия и займы для учёбы за границей, с дополнительными займами, например, на плату за обучение и поездки.', '2026-08-28 19:05:47.765794+00'),
	('460a4497-47cf-4a09-9211-dcc648162e1c', 'ru', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Пособие, помогающее шведским организациям готовить заявки на программы ЕС, такие как Horisont Europa.', '2026-08-28 19:05:47.765794+00'),
	('0bd66338-b1aa-4260-988c-2f9103fb283e', 'ru', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Пособие работодателям, нанимающим людей со сниженной трудоспособностью.', '2026-08-28 19:05:47.765794+00'),
	('c70fe3a1-35e2-4b0b-979d-865e49a7e4b3', 'ru', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Пособие на проживание и поездки домой, когда гимназист вынужден жить в месте учёбы из-за долгой дороги.', '2026-08-28 19:05:47.765794+00'),
	('d64c43b0-0b3b-4f00-a41f-2030b4b7197f', 'ru', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Пособия на работу некоммерческих организаций по сохранению, использованию и развитию культурного наследия.', '2026-08-28 19:05:47.765794+00'),
	('80cbaae7-feed-4785-894c-9edcbd5c30ea', 'ru', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Пособия на муниципальные и местные природоохранные проекты, включая водно-болотные угодья и активный отдых.', '2026-08-28 19:05:47.765794+00'),
	('294a5e98-7fc1-42e0-b107-e632f7109182', 'ru', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Пособия коммунам на закупку литературы для публичных и школьных библиотек.', '2026-08-28 19:05:47.765794+00'),
	('6e5f358a-1fe8-455a-9eec-52c07c3452c2', 'ru', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Пособия школьным организациям для знакомства учеников основной школы с профессиональной культурой.', '2026-08-28 19:05:47.765794+00'),
	('8c9d53de-cd7f-4a54-8474-e135a687e2c1', 'ru', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Пособие на то, что нужно вашему ребёнку, но на что не хватает семейного бюджета: досуг, одежда, школьные экскурсии, очки, каникулярные занятия и другое.', '2026-08-28 19:05:47.765794+00'),
	('6a2559d9-21cc-449a-8629-037bf0c060cc', 'ru', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Пособия из фондов Världens Barn, Musikhjälpen и Victoriafonden — их запрашивают шведские некоммерческие организации с 90-konto.', '2026-08-28 19:05:47.765794+00'),
	('7f68f118-90dc-4ed3-9796-d6c57f5d6b74', 'ru', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Пособия из средств гидро- и ветроэнергетики на проекты, развивающие местность.', '2026-08-28 19:05:47.765794+00'),
	('7c1aa0f6-83f1-4ffd-bbff-bc015d28c303', 'ru', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Пособие без заёмной части для безработных 25–60 лет с коротким образованием, которым нужно учиться на уровне основной школы или гимназии.', '2026-08-28 19:05:47.765794+00'),
	('6eff8c58-5cf9-4fb0-8ea3-eeab7e4d58fd', 'ru', 'Bidrar projektet till energiomställningen?', 'Вносит ли проект вклад в энергетический переход?', '2026-08-28 19:05:47.765794+00'),
	('5c1c2157-6193-487d-9a6d-bd59ee21360b', 'ru', 'Bor du och barnets andra förälder på skilda håll?', 'Живёте ли вы и другой родитель ребёнка раздельно?', '2026-08-28 19:05:47.765794+00'),
	('8f16c388-842a-4ecf-96c0-7e5b60d8df0e', 'ru', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Чеки для малых предприятий на привлечение внешней экспертизы для интернационализации или цифровизации.', '2026-08-28 19:05:47.765794+00'),
	('0f7602a2-75fb-4b4f-bc5e-982986d5ab4e', 'ru', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Участвуете ли вы в программе Arbetsförmedlingen (например, jobb- och utvecklingsgarantin)?', '2026-08-28 19:05:47.765794+00'),
	('1dd16fd2-ba2b-4821-b9d3-2f3d26569169', 'ru', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Последующая поддержка издательствам за выпуск качественной литературы.', '2026-08-28 19:05:47.765794+00'),
	('b9364417-99c5-450d-9e76-b11c7ad27637', 'ru', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Экономическая поддержка для тех, у кого вид на жительство по защите и кто добровольно хочет навсегда вернуться в страну происхождения.', '2026-08-28 19:05:47.765794+00'),
	('6e66f6f2-c7fc-4d14-a5bb-4352620c2d4f', 'ru', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Экономическая поддержка работодателям, нанимающим человека, долго не работавшего.', '2026-08-28 19:05:47.765794+00'),
	('08b25335-9715-4174-8681-d80e72bf3b0a', 'ru', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Экономическая поддержка на этапе запуска для ищущих работу, открывающих собственное дело.', '2026-08-28 19:05:47.765794+00'),
	('9a39915b-4fcd-4cbb-a4b2-8d90c64d9413', 'ru', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten постоянно открывает конкурсы в области энергетических исследований, инноваций и энергоэффективности.', '2026-08-28 19:05:47.765794+00'),
	('9e38cc36-d785-4c76-9f03-ed5ae70a05af', 'ru', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Выплата за отсутствие на работе или учёбе для ухода за ребёнком.', '2026-08-28 19:05:47.765794+00'),
	('c61ba10c-19c3-474f-b406-23f3297d5a92', 'ru', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Выплата для тех, кто недавно в Швеции и участвует в программе адаптации Arbetsförmedlingen; выплачивает Försäkringskassan.', '2026-08-28 19:05:47.765794+00'),
	('58dd5e4a-f3f0-4c6d-b64d-2a077fc0230f', 'ru', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Выплата, покрывающая часть расходов на жильё для молодых людей без детей с низкими доходами.', '2026-08-28 19:05:47.765794+00'),
	('30a202f8-a0b2-4e98-9ec3-b0490a655388', 'ru', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Выплата за дополнительные расходы, связанные со стойкой инвалидностью — для взрослых или родителей детей с инвалидностью.', '2026-08-28 19:05:47.765794+00'),
	('ac9daf29-4392-468b-9db0-a3ce4d8ace98', 'ru', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Выплата для молодых людей (19–29 лет), которые не могут работать полный день минимум год из-за болезни или инвалидности.', '2026-08-28 19:05:47.765794+00'),
	('4495110e-19d5-4de6-8b95-f7eb022ab94a', 'ru', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Выплата при стойко сниженной трудоспособности — то, что раньше называлось förtidspension (досрочная пенсия).', '2026-08-28 19:05:47.765794+00'),
	('9788eabb-0d7c-47be-bf1d-1a1df39e1662', 'ru', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Выплата, когда вы отказываетесь от работы, чтобы быть рядом с тяжелобольным близким.', '2026-08-28 19:05:47.765794+00'),
	('c575ae97-72f5-446c-bcfe-6b67ad64b9a6', 'ru', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Выплата за участие в программе рынка труда Arbetsförmedlingen.', '2026-08-28 19:05:47.765794+00'),
	('183928f6-67f0-4649-9967-6f9bd43cb57e', 'ru', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Выплата, когда вы не можете работать как обычно из-за болезни.', '2026-08-28 19:05:47.765794+00'),
	('f92a81d7-0749-4d8f-978f-1bd2829013d6', 'ru', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Выплата, когда вы остаётесь дома с работы для ухода за больным ребёнком.', '2026-08-28 19:05:47.765794+00'),
	('3127e807-dfdb-4e02-b58d-8454520fe40d', 'ru', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Выплата, покрывающая часть расходов на жильё для семей с детьми и невысокими доходами.', '2026-08-28 19:05:47.765794+00'),
	('91360aa5-756e-4b95-a929-af3d507887ea', 'ru', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Выплата родителям, чьи дети из-за инвалидности нуждаются в большем уходе и присмотре, чем сверстники.', '2026-08-28 19:05:47.765794+00'),
	('cf826cf3-19bc-4e30-8cd0-4c8b31880784', 'ru', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Выплата при безработице — на основе дохода для членов кассы, базовая сумма для остальных.', '2026-08-28 19:05:47.765794+00');
INSERT INTO public.kb_translations VALUES
	('a5277156-01f8-48ea-84aa-735e8a1ca39b', 'ru', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Около пятидесяти фондов сберегательных банков выдают пособия местным проектам в спорте, культуре, образовании и развитии общества — в зоне деятельности банка.', '2026-08-28 19:05:47.765794+00'),
	('f614cdb1-79ee-4c81-abc6-8d3de987cf7a', 'ru', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Финансируемая ЕС проектная поддержка, запрашиваемая в вашей местной зоне Leader — для объединений, компаний и коммун, развивающих сельскую местность.', '2026-08-28 19:05:47.765794+00'),
	('62de0295-6011-43d0-96c5-a1ce2c91754b', 'ru', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Финансируемая ЕС поддержка для ищущих работу, устраивающихся в другой стране ЕС/ЕЭЗ: компенсация поездки на собеседование, расходов на переезд и языкового курса.', '2026-08-28 19:05:47.765794+00'),
	('c62428d9-9246-4d60-ae9c-4c1761cfd2d4', 'ru', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Средства социального фонда ЕС на проекты, укрепляющие компетенции, переквалификацию и инклюзию на рынке труда.', '2026-08-28 19:05:47.765794+00'),
	('8ab35a96-5739-4259-8c20-f6fa89c597f1', 'ru', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Поддержка ЕС для групповых обменов молодёжи 13–30 лет, длительностью 5–21 день без учёта дней в пути.', '2026-08-28 19:05:47.765794+00'),
	('415ef5ea-6216-4fca-917e-7b5b36980d0d', 'ru', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Поддержка ЕС для проектов сотрудничества культурных организаций с партнёрами в нескольких европейских странах.', '2026-08-28 19:05:47.765794+00'),
	('29305649-9f25-46c5-8a4f-d67811db0bb2', 'ru', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Поддержка ЕС для организаций, принимающих или направляющих молодых волонтёров 18–30 лет.', '2026-08-28 19:05:47.765794+00'),
	('6db15fe4-0f8f-4e33-9ac5-cab1301053cc', 'ru', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Поддержка ЕС для мобильности персонала и учащихся в школе и образовании взрослых.', '2026-08-28 19:05:47.765794+00'),
	('3ea7430c-3c39-481e-afa1-3a33bf4fba1b', 'ru', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Поддержка ЕС с фиксированными суммами для первых европейских проектов сотрудничества небольших организаций.', '2026-08-28 19:05:47.765794+00'),
	('ca0829bb-471c-44cc-a125-7b27a75c9add', 'ru', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Финансирование молодых компаний, разрабатывающих новаторские продукты или услуги с международным потенциалом.', '2026-08-28 19:05:47.765794+00'),
	('754b6643-ca46-49a1-9142-02298a2b9d36', 'ru', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Есть ли сберегательный банк (и, значит, фонд сберегательного банка) там, где вы ведёте деятельность?', '2026-08-28 19:05:47.765794+00'),
	('d4080ffd-8ba1-4f86-9418-c27726ee8fb2', 'ru', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Многолетние операционные пособия профессиональным независимым коллективам танца, театра и музыкального театра.', '2026-08-28 19:05:47.765794+00'),
	('75511f48-d9a5-4625-8e69-1a990f54f073', 'ru', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Исследовательские пособия в областях Forte: здоровье, трудовая жизнь и благосостояние. Запрашивают исследователи с докторской степенью в шведских вузах.', '2026-08-28 19:05:47.765794+00'),
	('902848ac-524c-45a1-9a3f-ea81988703cc', 'ru', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Финансирование свободных фундаментальных исследований во всех областях науки.', '2026-08-28 19:05:47.765794+00'),
	('c0891902-dc52-44f5-8b2f-3c5a55fadde0', 'ru', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Финансирование исследований в области окружающей среды, аграрных наук и градостроительства.', '2026-08-28 19:05:47.765794+00'),
	('e87e8c24-faf7-4d40-aca0-13b7dc498cdf', 'ru', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Думаете ли вы о переезде за границу (работа, учёба или возвращение на родину)?', '2026-08-28 19:05:47.765794+00'),
	('26c23f50-220b-4dab-b969-6aa6d75d3b0e', 'ru', 'Genomförs insatserna av professionella kulturaktörer?', 'Проводятся ли мероприятия профессиональными деятелями культуры?', '2026-08-28 19:05:47.765794+00'),
	('63e59286-c987-4343-8033-4663e8801733', 'ru', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Реализуется ли проект в сельской местности или небольшом населённом пункте?', '2026-08-28 19:05:47.765794+00'),
	('3d2042d3-c3ab-4ffa-b893-6170c0dc6b93', 'ru', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Базовая защита для тех, у кого в течение жизни был низкий трудовой доход или его не было.', '2026-08-28 19:05:47.765794+00'),
	('f448c52e-d6da-4ba6-adb7-25e8f781f7c9', 'ru', 'Går något av dina barn i grundskolan?', 'Ходит ли кто-то из ваших детей в основную школу?', '2026-08-28 19:05:47.765794+00'),
	('b585b0d3-d1f6-46f3-b095-f50ced31e0b9', 'ru', 'Går något av dina barn på gymnasiet?', 'Учится ли кто-то из ваших детей в гимназии?', '2026-08-28 19:05:47.765794+00'),
	('b0df09be-4add-4f53-8284-1b120b41bec8', 'ru', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Касается ли наём человека со сниженной трудоспособностью?', '2026-08-28 19:05:47.765794+00'),
	('ae82d442-ff17-4c9b-99ac-9f109f5f5917', 'ru', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Касается ли наём человека, долго бывшего безработным или недавно приехавшего в Швецию?', '2026-08-28 19:05:47.765794+00'),
	('e24ba9d7-6355-4183-b621-d2d03c2786cb', 'ru', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Посвящён ли проект сохранению культурного наследия или обеспечению доступа к нему?', '2026-08-28 19:05:47.765794+00'),
	('dd6bd52a-5d5a-47bb-8782-d83ae770fdde', 'ru', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Посвящён ли проект энергетике, энергоэффективности или энергетическим инновациям?', '2026-08-28 19:05:47.765794+00'),
	('70521549-7b03-45bf-94d6-44b67e05aae3', 'ru', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Посвящён ли проект здоровью, трудовой жизни или благосостоянию?', '2026-08-28 19:05:47.765794+00'),
	('59a45d83-ac4a-4146-8b23-c818e72e6723', 'ru', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Посвящён ли проект развитию компетенций или мерам на рынке труда?', '2026-08-28 19:05:47.765794+00'),
	('59cf29c3-4234-4154-9f12-c33e3a0fa906', 'ru', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Посвящён ли проект экологическим или климатическим мерам?', '2026-08-28 19:05:47.765794+00'),
	('f3c5a44a-08c7-4e0a-9357-4ddb93713dcd', 'ru', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Длинная ли у ребёнка дорога в школу, опасная из-за движения или трудная по другим причинам?', '2026-08-28 19:05:47.765794+00'),
	('054f197e-a102-4630-b05c-2cd783b74697', 'ru', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Работали ли вы не менее 16 часов в неделю в общей сложности не менее 8 лет?', '2026-08-28 19:05:47.765794+00'),
	('4ba840f4-38f3-4851-beaa-d51b88428b94', 'ru', 'Har du barn som bor hos dig, helt eller växelvis?', 'Живут ли с вами дети — постоянно или попеременно?', '2026-08-28 19:05:47.765794+00'),
	('46032269-2edf-4fae-9bf0-8ba004b46b12', 'ru', 'Har du barn som bor hos dig?', 'Живут ли с вами дети?', '2026-08-28 19:05:47.765794+00'),
	('cd64e2f8-35ec-49d1-ae0d-10b3317dfce8', 'ru', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Есть ли у вас или вашего ребёнка инвалидность, которая, как ожидается, продлится не менее года?', '2026-08-28 19:05:47.765794+00'),
	('cea49939-2d63-4426-9310-ec4d75d3eb4b', 'ru', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Есть ли у вас или кого-то в семье стойкая инвалидность, влияющая на жильё?', '2026-08-28 19:05:47.765794+00'),
	('d9243796-6960-4dc1-89f0-c56fee2d6854', 'ru', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Есть ли у вас или близкого родственника инвалидность либо длительная или тяжёлая болезнь?', '2026-08-28 19:05:47.765794+00'),
	('f7e65bcc-e795-447d-b927-fc51101d44ef', 'ru', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Есть ли у вас болезнь или травма, которая сейчас снижает вашу трудоспособность?', '2026-08-28 19:05:47.765794+00'),
	('0dc7bd3e-306f-488f-a3b9-b7414d926219', 'ru', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Бывало ли вам трудно оплатить школьную экскурсию, классную поездку или досуговое занятие, в котором должен участвовать ваш ребёнок?', '2026-08-28 19:05:47.765794+00'),
	('f7c3d4d6-0952-4f21-8f00-859cd7ad87ca', 'ru', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Трудно ли вам прожить на пенсию и прочие доходы?', '2026-08-28 19:05:47.765794+00'),
	('aa895a10-3292-4348-bc77-a001cdd90072', 'ru', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Получали ли вы в последние годы вид на жительство в Швеции, например, как нуждающийся в защите или как член семьи?', '2026-08-28 19:05:47.765794+00'),
	('7d27d0d3-d067-4111-987a-1f04436d5399', 'ru', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Есть ли у вас вид на жительство в Швеции как у беженца или нуждающегося в защите (или вы близкий родственник такого человека)?', '2026-08-28 19:05:47.765794+00'),
	('787c53c6-0883-4842-8156-66e10ec868fd', 'ru', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Достигли ли вы целевого пенсионного возраста (67 лет в 2026 году)?', '2026-08-28 19:05:47.765794+00'),
	('5f400ee0-9b92-475f-a595-d0694685d6ed', 'ru', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Есть ли у вашей организации OID (Organisation ID), зарегистрированный в Organisation Registration System ЕС?', '2026-08-28 19:05:47.765794+00'),
	('fbe368cf-bf92-40ba-bbfa-eb12dcdffed9', 'ru', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Повлекла ли инвалидность дополнительные расходы — например, вспомогательные средства, поездки, особое питание или износ?', '2026-08-28 19:05:47.765794+00'),
	('8e59e7b5-3685-467d-b2df-43050c2cf29a', 'ru', 'Har föreningen antagna stadgar och en vald styrelse?', 'Есть ли у объединения принятый устав и избранное правление?', '2026-08-28 19:05:47.765794+00'),
	('23479598-df0a-4929-a590-6a147ae4c812', 'ru', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Есть ли у объединения демократическое устройство (устав, годовое собрание, правление)?', '2026-08-28 19:05:47.765794+00'),
	('30801c61-64c2-4325-a6f4-6ce0d33b6479', 'ru', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Ведёт ли объединение регулярную деятельность для детей или молодёжи?', '2026-08-28 19:05:47.765794+00'),
	('66d0f2d7-5405-417f-b798-977962cd2f88', 'ru', 'Har företaget mellan cirka 2 och 49 anställda?', 'В компании примерно от 2 до 49 сотрудников?', '2026-08-28 19:05:47.765794+00'),
	('868eea8f-6cf7-4b46-ad54-56640a11a4cd', 'ru', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Трудно ли семье покрывать расходы на еду, жильё и самое необходимое?', '2026-08-28 19:05:47.765794+00'),
	('448a7487-ae3f-459a-b6b5-f479c6ffdd87', 'ru', 'Har lösningen internationell potential?', 'Есть ли у решения международный потенциал?', '2026-08-28 19:05:47.765794+00'),
	('43905c6f-3c89-4bab-9422-85c518415eab', 'ru', 'Har ni en partnergrupp i ett annat land?', 'Есть ли у вас партнёрская группа в другой стране?', '2026-08-28 19:05:47.765794+00');
INSERT INTO public.kb_translations VALUES
	('b1869a77-f750-4c8f-a896-2cbd479ffb7a', 'ru', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Есть ли у вас партнёрская организация в другой европейской стране?', '2026-08-28 19:05:47.765794+00'),
	('85047b68-ad40-4437-8b3c-40c245a9c023', 'ru', 'Har ni partner i minst tre olika europeiska länder?', 'Есть ли у вас партнёры как минимум в трёх разных европейских странах?', '2026-08-28 19:05:47.765794+00'),
	('29b8e7b0-3472-476c-85b5-04889a4e8c0c', 'ru', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Находится ли ваш офис или основная деятельность в регионе, где вы подаёте заявку?', '2026-08-28 19:05:47.765794+00'),
	('d2dfee60-07bf-484d-8e79-41e827e8319c', 'ru', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Есть ли у кого-то из ваших детей инвалидность, из-за которой ребёнку нужно больше ухода или присмотра, чем другим детям того же возраста?', '2026-08-28 19:05:47.765794+00'),
	('220bcd67-6654-4e9d-b62b-76ae3dd0b65b', 'ru', 'Har organisationen en demokratisk uppbyggnad?', 'Есть ли у организации демократическое устройство?', '2026-08-28 19:05:47.765794+00'),
	('7a25b30f-1d14-4696-8687-39ed225d96a0', 'ru', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Есть ли у организации Quality Label (знак качества)?', '2026-08-28 19:05:47.765794+00'),
	('5453c0b8-dcba-4a94-8f06-7d938f290fce', 'ru', 'Har organisationen ett 90-konto?', 'Есть ли у организации 90-konto?', '2026-08-28 19:05:47.765794+00'),
	('eaa5b4bf-8d82-4d8e-b45b-e4390c87d9b3', 'ru', 'Har organisationen ett OID (Organisation ID)?', 'Есть ли у организации OID (Organisation ID)?', '2026-08-28 19:05:47.765794+00'),
	('5ffd56e1-e5e3-4b96-86c0-30e7db914368', 'ru', 'Har organisationen ett OID?', 'Есть ли у организации OID?', '2026-08-28 19:05:47.765794+00'),
	('db4d242f-6508-4f04-8f81-9737329d2951', 'ru', 'Har organisationen medlemsföreningar i flera län?', 'Есть ли у организации объединения-члены в нескольких ленах?', '2026-08-28 19:05:47.765794+00'),
	('0e7ee809-7168-4cd3-b2ac-353bb34d4e41', 'ru', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Есть ли у организации упорядоченные финансы и демократическое устройство?', '2026-08-28 19:05:47.765794+00'),
	('f3c757dd-1172-415e-9db1-4deb01dbf1d8', 'ru', 'Har projektet en partner i ett annat land?', 'Есть ли у проекта партнёр в другой стране?', '2026-08-28 19:05:47.765794+00'),
	('0214486d-8d77-44ea-b60c-d7f1b9dca694', 'ru', 'Har projektledaren doktorsexamen?', 'Есть ли у руководителя проекта докторская степень?', '2026-08-28 19:05:47.765794+00'),
	('f8f3cc51-0e14-4c16-8708-6f4a70ede724', 'ru', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Домашняя коммуна должна обеспечивать ежедневные поездки между домом и гимназией, если дорога составляет не менее шести километров (например, проездной на автобус).', '2026-08-28 19:05:47.765794+00'),
	('3a478251-a5b8-41e5-b84f-bd523422c649', 'ru', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Обзаводитесь ли вы своим первым собственным жильём в Швеции или обустраиваете его?', '2026-08-28 19:05:47.765794+00'),
	('3f8999cf-f153-45e6-a14f-34c45df48df2', 'ru', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Включает ли проект международную поездку или обмен?', '2026-08-28 19:05:47.765794+00'),
	('4aa55f65-94f4-41b6-ba3d-6341f13be5b0', 'ru', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Инвестиционная поддержка компаниям в зонах поддержки — на здания, оборудование и обучение.', '2026-08-28 19:05:47.765794+00'),
	('82ce9559-6b44-4c30-aad9-df3964c71beb', 'ru', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Инвестиционная поддержка мер, снижающих выбросы парниковых газов.', '2026-08-28 19:05:47.765794+00'),
	('f91aa51c-0073-48c0-b3d6-0ae777b39fd2', 'ru', 'Kan projektets miljönytta mätas?', 'Можно ли измерить экологическую пользу проекта?', '2026-08-28 19:05:47.765794+00'),
	('c35e67ee-d20d-4e73-92d3-b9197f731250', 'ru', 'Kan åtgärdens utsläppsminskning beräknas?', 'Можно ли рассчитать снижение выбросов от меры?', '2026-08-28 19:05:47.765794+00'),
	('5882166a-2e20-4e18-a981-bbe4c45c0007', 'ru', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Может ли организация нести расходы до выплаты поддержки?', '2026-08-28 19:05:47.765794+00'),
	('cd546c39-81c7-410f-b571-4c194f4bdd09', 'ru', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Будет ли опыт использоваться в вашей деятельности в Швеции?', '2026-08-28 19:05:47.765794+00'),
	('a1b03c21-1e7e-4d5f-a833-8990a7465bff', 'ru', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Начнётся ли инвестиция только после подачи заявки?', '2026-08-28 19:05:47.765794+00'),
	('601f4447-9c1d-4fe5-b042-ff7a4485e8d9', 'ru', 'Kommer projektet människor i ert närområde till del?', 'Приносит ли проект пользу людям в вашей местности?', '2026-08-28 19:05:47.765794+00'),
	('30518ff8-ada1-4c1e-a13a-4634ab08f362', 'ru', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Крайняя экономическая защита коммуны, когда доходов не хватает на самое необходимое.', '2026-08-28 19:05:47.765794+00'),
	('e77229fd-a30c-4a2e-a063-cfa518b336db', 'ru', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Собственная поддержка коммун местным объединениям: пособие за занятие, помощь с помещениями, стартовое пособие и другое.', '2026-08-28 19:05:47.765794+00'),
	('14b1a1bd-8da7-4897-ad38-264cd7162f93', 'ru', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Бесплатный школьный транспорт для учеников основной школы при большом расстоянии, опасной дороге или инвалидности — право по школьному закону.', '2026-08-28 19:05:47.765794+00'),
	('bd7e65e4-7e06-4779-85cf-5fd43b29ed2b', 'ru', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Установленное законом пособие на очки или линзы для детей и молодёжи; суммы и порядок различаются по регионам — проверьте уровень своего региона.', '2026-08-28 19:05:47.765794+00'),
	('f96774c9-99e4-4813-9a24-cff2cb788ad9', 'ru', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Находится ли проект в местности, затронутой гидро- или ветроэнергетикой?', '2026-08-28 19:05:47.765794+00'),
	('3e0ed6d5-0c21-4d38-b158-0613dd75ea42', 'uk', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Чи веде об''єднання регулярну діяльність у комуні?', '2026-08-28 19:05:47.778076+00'),
	('88cd7813-edc1-4b40-bb27-047270c77c77', 'ru', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Относится ли проект к окружающей среде, аграрным наукам или градостроительству?', '2026-08-28 19:05:47.765794+00'),
	('f53a5dac-7344-4300-a31f-687b2459727a', 'ru', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Находится ли место деятельности в зоне поддержки A или B (большая часть Норрланда и внутреннего Свеаланда)?', '2026-08-28 19:05:47.765794+00'),
	('76914609-f4b8-4965-bda1-37e717402e95', 'ru', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Заём на покупку самого необходимого для первого дома в Швеции — мебели, домашней утвари и другого базового оснащения.', '2026-08-28 19:05:47.765794+00'),
	('f4063a7b-95c0-4e20-8e5e-8f02bffdcd3e', 'ru', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Снижает ли проект технологические выбросы промышленности или создаёт отрицательные выбросы?', '2026-08-28 19:05:47.765794+00'),
	('3efeb890-1f27-4d74-affa-3e225e3e8e52', 'ru', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Ежемесячное пособие на детей, живущих в Швеции, от рождения до 16 лет.', '2026-08-28 19:05:47.765794+00'),
	('5f0d4592-729e-499f-b8b4-da1d518f9304', 'ru', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket предлагает пособия организациям, компаниям, объединениям, публичному сектору и частным лицам в сфере экологии.', '2026-08-28 19:05:47.765794+00'),
	('6c601d9b-ba98-4f1d-bf2f-333de3b0e250', 'ru', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Планируете ли вы добровольно навсегда вернуться в страну происхождения?', '2026-08-28 19:05:47.765794+00'),
	('cfad7616-68cc-4ce2-8091-d647ef367a84', 'ru', 'Planerar du att starta eget företag?', 'Планируете ли вы открыть собственное дело?', '2026-08-28 19:05:47.765794+00'),
	('5deb0b91-aeb1-461a-a53c-f15e1e273f6e', 'ru', 'Planerar du att studera utomlands?', 'Планируете ли вы учиться за границей?', '2026-08-28 19:05:47.765794+00'),
	('0bdc8cdf-cf04-4acd-9e63-03754feeaa97', 'ru', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Планируете ли вы учёбу, укрепляющую вашу позицию на рынке труда?', '2026-08-28 19:05:47.765794+00'),
	('32794a2e-b6f0-49d6-b61f-8631004c55e7', 'ru', 'Planerar ni att anställa?', 'Планируете ли вы нанимать сотрудников?', '2026-08-28 19:05:47.765794+00'),
	('5f69ef7a-1d96-4fa3-8d17-e27a2a07b6a7', 'ru', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Планируете ли вы подавать заявку на программу ЕС (например, Horisont Europa)?', '2026-08-28 19:05:47.765794+00'),
	('d0144864-dbf3-4f9f-8fb4-354e71cc165d', 'ru', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Поддержка производства и разработки короткометражных и документальных фильмов.', '2026-08-28 19:05:47.765794+00'),
	('013e8e76-a85f-4d2a-a8c0-4b1410fd9394', 'ru', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Проектные пособия свободной музыкальной сцене на концерты, производство и развитие.', '2026-08-28 19:05:47.765794+00'),
	('2b3f618a-55ec-43df-a6ea-c7ee8795642e', 'ru', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Проектные пособия некоммерческим организациям, работающим с детьми и молодёжью и для них.', '2026-08-28 19:05:47.765794+00'),
	('9c3f1e77-08eb-40c2-963d-b132b24a6c80', 'ru', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Пробует ли проект новые художественные выражения, методы или сотрудничества?', '2026-08-28 19:05:47.765794+00'),
	('cf4d68c1-7f5a-4318-b49c-69972c873365', 'ru', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Длится ли обмен 5–21 день (без учёта дней в пути)?', '2026-08-28 19:05:47.765794+00'),
	('54a0a897-f708-40ce-b451-7620637c1c6f', 'ru', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Собственная проектная и операционная поддержка регионов культурной жизни, наряду с национальными пособиями Kulturrådet.', '2026-08-28 19:05:47.765794+00'),
	('3d5a5aff-db90-4b1f-a49a-9f9c44b46738', 'ru', 'Riktar sig projektet till barn eller unga?', 'Адресован ли проект детям или молодёжи?', '2026-08-28 19:05:47.765794+00'),
	('7892df6d-2007-4ec7-9bfa-5b0acf7f2122', 'ru', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Адресован ли проект детям, молодёжи, пожилым или людям с инвалидностью?', '2026-08-28 19:05:47.765794+00');
INSERT INTO public.kb_translations VALUES
	('e593d831-00be-4357-b810-276feb5647f0', 'ru', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Адресована ли деятельность детям и молодёжи (7–25 лет)?', '2026-08-28 19:05:47.765794+00'),
	('18eb5f46-b27c-430b-b0f4-6df00d7954d6', 'ru', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'У вас нет сбережений или активов, которые могли бы покрыть расходы?', '2026-08-28 19:05:47.765794+00'),
	('7c142cc2-f63c-4708-90b6-6c8a6c1d9e0b', 'ru', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Сотрудничаете ли вы с партнёрами как минимум в двух других северных странах?', '2026-08-28 19:05:47.765794+00'),
	('6e16ba6e-c0a7-4dfd-a9ae-77898264ff3d', 'ru', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Собираетесь ли вы привлечь внешнюю экспертизу для меры развития?', '2026-08-28 19:05:47.765794+00'),
	('084f0f7e-05ed-44cc-9be9-b06e82a7c101', 'ru', 'Sker mobiliteten till ett annat europeiskt land?', 'Направлена ли мобильность в другую европейскую страну?', '2026-08-28 19:05:47.765794+00'),
	('6b6b5b2f-dadf-49b3-a717-3e14ba834a7b', 'ru', 'Startar du eller tar du över företaget för första gången?', 'Открываете ли вы предприятие или берёте его на себя впервые?', '2026-08-28 19:05:47.765794+00'),
	('5e83b119-2da5-45c6-a053-74361f01e53e', 'ru', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Стартовая поддержка для тех, кому 40 лет или меньше, кто открывает сельскохозяйственное предприятие или берёт его на себя.', '2026-08-28 19:05:47.765794+00'),
	('95014f16-7ee8-4f0c-b2b3-dda213c2623d', 'ru', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Стипендия, позволяющая профессиональным художникам сосредоточиться на художественной работе.', '2026-08-28 19:05:47.765794+00'),
	('a75ec2a8-1fab-4c4a-b8ae-162b65c0737f', 'ru', 'Studerar du, eller planerar du att börja studera?', 'Учитесь ли вы или планируете начать учёбу?', '2026-08-28 19:05:47.765794+00'),
	('7536cb0a-bd61-4260-abbc-9d0a14cf22c5', 'ru', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Существенно ли новаторское ваше решение по сравнению с уже существующим?', '2026-08-28 19:05:47.770201+00'),
	('5a4b9cdf-2538-4c1e-b314-d7c7509f4a53', 'ru', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Учебная поддержка для работающих взрослых, желающих получить образование для укрепления позиции на рынке труда.', '2026-08-28 19:05:47.765794+00'),
	('9065d941-937a-41d7-bc74-460f8e706762', 'ru', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Поддержка инвестиций, повышающих конкурентоспособность или снижающих воздействие на окружающую среду в сельскохозяйственных предприятиях.', '2026-08-28 19:05:47.765794+00'),
	('d2f685b4-f0f4-4e7d-a816-17409417265d', 'ru', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Поддержка, когда ребёнок живёт с вами, а другой родитель не платит содержание.', '2026-08-28 19:05:47.765794+00'),
	('09e28997-dcfe-4fef-9d7c-9fe720976f61', 'ru', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Поддержка проектов некоммерческих организаций для людей, окружающей среды и лучшего мира.', '2026-08-28 19:05:47.765794+00'),
	('c8cb7adc-a96c-4aa7-a55b-78d76f4afc4c', 'ru', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Поддержка перехода промышленности к нулевым выбросам парниковых газов.', '2026-08-28 19:05:47.765794+00'),
	('9ef343a0-ab7b-432c-92e2-7ed8a4051b7e', 'ru', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Поддержка художественных и культурных проектов с северным измерением и трансграничным сотрудничеством.', '2026-08-28 19:05:47.765794+00'),
	('550a55f6-b028-4008-b85a-61622385be2d', 'ru', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Поддержка новаторских культурных проектов, пробующих новые художественные выражения, методы или сотрудничества.', '2026-08-28 19:05:47.765794+00'),
	('9f74b6a4-9573-4fea-803f-ad25f1f73b49', 'ru', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Поддержка новаторских проектов для детей, молодёжи, пожилых и людей с инвалидностью.', '2026-08-28 19:05:47.765794+00'),
	('c9f632e6-7cbf-428e-ab8e-f556518d26c6', 'ru', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Поддержка проектов сотрудничества в свободной музыкальной сцене.', '2026-08-28 19:05:47.765794+00'),
	('feeacbb9-a0e5-40b4-89f1-3ecd05a633d6', 'ru', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Поддержка проектов сотрудничества в культуре и медиа, укрепляющих демократию и свободу слова на международном уровне.', '2026-08-28 19:05:47.765794+00'),
	('c0f2d1ec-5854-49c4-ae53-bc030ae15938', 'ru', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Направлен ли проект на укрепление демократии, равенства или свободы слова?', '2026-08-28 19:05:47.765794+00'),
	('bedf72ab-36a1-4b6e-81e2-ade51a7ac2a8', 'ru', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Ищете ли вы работу или получили предложение о работе в другой стране ЕС или ЕЭЗ?', '2026-08-28 19:05:47.765794+00'),
	('38664fe1-d5fd-439a-a3c2-024449526167', 'ru', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Потолок того, что вы платите в виде пациентских сборов за двенадцать месяцев — затем frikort (бесплатная карта).', '2026-08-28 19:05:47.765794+00'),
	('4e7ff843-c3cc-4494-81df-1b1a5acf2bf0', 'ru', 'Tar du ut hel allmän pension?', 'Получаете ли вы полную государственную пенсию?', '2026-08-28 19:05:47.765794+00'),
	('5b7b5345-512e-4da0-9926-fef05bdce520', 'ru', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Надбавка, покрывающая часть расходов на жильё для тех, у кого пенсия и низкие доходы.', '2026-08-28 19:05:47.765794+00'),
	('583303a6-68ff-4cfd-a84c-f513c4efe803', 'ru', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Ежегодное организационное пособие национальным детским и молодёжным организациям.', '2026-08-28 19:05:47.765794+00'),
	('7357db72-dfaa-40e2-87a9-b9a880b9e566', 'ru', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Ежегодная сумма, вычитаемая напрямую у стоматолога или зубного гигиениста.', '2026-08-28 19:05:47.765794+00'),
	('2a749049-a082-4e4b-ad24-cc7a5d4f8f34', 'ru', 'Är bolaget yngre än cirka 5 år?', 'Компании меньше примерно 5 лет?', '2026-08-28 19:05:47.765794+00'),
	('64fe7be8-e44b-4d27-a86d-ccfe20cfca43', 'ru', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Участникам обмена от 13 до 30 лет?', '2026-08-28 19:05:47.765794+00'),
	('9932fead-e2f3-47cc-8b4e-86ad568257d3', 'ru', 'Är det här ert första EU-projekt?', 'Это ваш первый проект ЕС?', '2026-08-28 19:05:47.765794+00'),
	('1ab4b2d7-842a-4d14-85f1-969b2015cf8d', 'ru', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Очень ли трудно вам (или вашему ребёнку) передвигаться самостоятельно или ездить на автобусе и поезде?', '2026-08-28 19:05:47.765794+00'),
	('929a9bfe-e0b1-48d2-8e2f-7b303d3b2ac5', 'ru', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Ваш доход ниже примерно 25 000 крон в месяц до налогов?', '2026-08-28 19:05:47.765794+00'),
	('c0cf6a30-37f0-4369-9020-98227509515e', 'ru', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Ваше последнее законченное образование — основная школа или незаконченная гимназия?', '2026-08-28 19:05:47.765794+00'),
	('846e8181-3465-42ea-bfc7-d71e20f638ec', 'ru', 'Är du 40 år eller yngre?', 'Вам 40 лет или меньше?', '2026-08-28 19:05:47.765794+00'),
	('c6b87c54-6f94-4e43-b1aa-8a674c16af73', 'ru', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Зарегистрированы ли вы как ищущий работу в Arbetsförmedlingen?', '2026-08-28 19:05:47.765794+00'),
	('3ee625df-df0a-4997-bd95-a6bc9662cf41', 'ru', 'Är du mellan 18 och 28 år?', 'Вам от 18 до 28 лет?', '2026-08-28 19:05:47.765794+00'),
	('87219ea5-de3c-40e7-8c3c-331a7c71dcd6', 'ru', 'Är du mellan 19 och 29 år?', 'Вам от 19 до 29 лет?', '2026-08-28 19:05:47.765794+00'),
	('29f9bdac-edfb-4e50-b44a-1b00fc6c4132', 'ru', 'Är du mellan 25 och 60 år?', 'Вам от 25 до 60 лет?', '2026-08-28 19:05:47.765794+00'),
	('99ea6f15-92bf-4d46-9cf4-2e63bf6de9c0', 'ru', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Работаете ли вы профессионально в сфере культуры (например, танец, музыка, сценическое искусство)?', '2026-08-28 19:05:47.765794+00'),
	('67fb2574-f88d-4ed9-977f-53b6799e1c78', 'ru', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Вы профессиональный художник (не любитель и не на базовом обучении)?', '2026-08-28 19:05:47.765794+00'),
	('81796a3f-5de4-440d-9e35-2ba30276665b', 'ru', 'Är du yrkesverksam konstnär?', 'Вы профессиональный художник?', '2026-08-28 19:05:47.765794+00'),
	('d687a099-5531-427d-9eb4-4640e45b0265', 'ru', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Входит ли клуб в специализированную спортивную федерацию в составе Riksidrottsförbundet?', '2026-08-28 19:05:47.770201+00'),
	('a3c4b518-1d23-49ba-ac4a-86aebdb459b3', 'ru', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Низки ли доходы семьи по отношению к расходам на жильё?', '2026-08-28 19:05:47.770201+00'),
	('c2cd04bb-a1bf-4f12-9cec-ca35a31486de', 'ru', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Совокупный доход семьи ниже примерно 25 000 крон в месяц до налогов?', '2026-08-28 19:05:47.770201+00'),
	('40032ad8-72cb-4f10-99bb-0324899b8141', 'ru', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Является ли мера отдельным проектом (а не обычной деятельностью)?', '2026-08-28 19:05:47.770201+00'),
	('aef244c5-e017-498a-9c86-d5475a116a20', 'ru', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Открыто ли помещение для всех — не только для собственных членов?', '2026-08-28 19:05:47.770201+00'),
	('e690bc47-0aeb-4963-b8d0-c899c92b6feb', 'ru', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Не менее 60 % членов в возрасте от 6 до 25 лет?', '2026-08-28 19:05:47.770201+00'),
	('31f094e8-ec40-4f08-8ac5-2ab44111721f', 'ru', 'Är minst 60 % av medlemmarna under 26 år?', 'Не менее 60 % членов младше 26 лет?', '2026-08-28 19:05:47.770201+00'),
	('8b967985-164b-4a24-990d-748f4c3e3dba', 'ru', 'Är målgruppen delaktig i planering och genomförande?', 'Участвует ли целевая группа в планировании и реализации?', '2026-08-28 19:05:47.770201+00'),
	('586184b9-6d7b-4ea8-b0ec-0a2394298c65', 'ru', 'Är ni ett förlag med professionell utgivning?', 'Вы издательство с профессиональным книгоизданием?', '2026-08-28 19:05:47.770201+00');
INSERT INTO public.kb_translations VALUES
	('7af3bb39-e1fa-4711-a0b5-756f42c674c0', 'ru', 'Är ni huvudman för förskoleklass eller grundskola?', 'Являетесь ли вы ответственной организацией дошкольного класса или основной школы?', '2026-08-28 19:05:47.770201+00'),
	('24bf14e4-51ca-4634-b66d-bb2295f8b8b7', 'ru', 'Är organisationen registrerad i EU:s deltagarregister?', 'Зарегистрирована ли организация в реестре участников ЕС?', '2026-08-28 19:05:47.770201+00'),
	('e6c4eb3c-1469-475d-b72c-a34a128081f4', 'ru', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Это кинопроект (короткометражный или документальный фильм)?', '2026-08-28 19:05:47.770201+00'),
	('9720eff9-20b3-4005-b625-24311d27cfc2', 'ru', 'Är projektet ett konst- eller kulturprojekt?', 'Это художественный или культурный проект?', '2026-08-28 19:05:47.770201+00'),
	('86174821-c5f0-4aa1-a615-f8c000f3f787', 'ru', 'Är projektet ett kulturprojekt?', 'Это культурный проект?', '2026-08-28 19:05:47.770201+00'),
	('d9b3fcbb-798c-4aaa-8299-3fb67f54e9fe', 'ru', 'Är projektet ett musikprojekt?', 'Это музыкальный проект?', '2026-08-28 19:05:47.770201+00'),
	('345ac7ac-7c4c-4368-9430-75df44ac1774', 'ru', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Новаторский ли проект — то, чего вы ещё не делаете в обычной деятельности?', '2026-08-28 19:05:47.770201+00'),
	('75d26f07-5b80-4348-8d36-9e84844d9bda', 'ru', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Приносит ли проект пользу местности в целом (а не отдельным лицам)?', '2026-08-28 19:05:47.770201+00'),
	('acfa98c2-f418-4c22-a67c-323f989e901f', 'ru', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Дорога между домом и гимназией составляет не менее шести километров?', '2026-08-28 19:05:47.770201+00'),
	('5196ec3c-9d32-4d4d-99e4-6c1839b42f95', 'ru', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Профессиональная ли это деятельность (не любительская)?', '2026-08-28 19:05:47.770201+00'),
	('d9b074fa-e028-40a1-9e21-b4a042f2365c', 'ru', 'Är verksamheten professionell?', 'Профессиональная ли это деятельность?', '2026-08-28 19:05:47.770201+00'),
	('3b33916b-7af2-46d1-932d-d6eca799b576', 'ru', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Относится ли деятельность к сценическому искусству (танец, театр, музыкальный театр)?', '2026-08-28 19:05:47.770201+00'),
	('dce832aa-519d-4351-973d-cab822702118', 'ru', 'Är volontärerna mellan 18 och 30 år?', 'Волонтёрам от 18 до 30 лет?', '2026-08-28 19:05:47.770201+00'),
	('7d5059eb-717e-4598-a5a5-89c0adfce0b6', 'uk', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Підтримка діяльності спортивних клубів, що проводять заняття під керівництвом тренерів для дітей та молоді 7–25 років.', '2026-08-28 19:05:47.778076+00'),
	('f465ae01-863d-4069-b359-689957181a3e', 'uk', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Автоматична надбавка до дитячої допомоги (barnbidrag) починаючи з другої дитини.', '2026-08-28 19:05:47.778076+00'),
	('5a1575ed-c729-456d-9e56-6c3d9994240c', 'uk', 'Avser ansökan en fysisk investering?', 'Чи стосується заявка фізичної інвестиції?', '2026-08-28 19:05:47.778076+00'),
	('5bc37706-01f2-4166-91e8-7cdb521f0f2d', 'uk', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Чи стосується заявка міжнародної поїздки або обміну?', '2026-08-28 19:05:47.778076+00'),
	('094a0d1a-faae-40e8-8e08-25a7907b4edd', 'uk', 'Avser ansökan en investering i byggnader eller maskiner?', 'Чи стосується заявка інвестиції в будівлі або обладнання?', '2026-08-28 19:05:47.778076+00'),
	('1a65e716-e925-44fc-9aba-b1a018dee270', 'uk', 'Avser ansökan en redan utgiven titel?', 'Чи стосується заявка вже виданого твору?', '2026-08-28 19:05:47.778076+00'),
	('4d4e4b44-0fc7-4dc4-ab52-eda85cf99475', 'uk', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Чи стосується заявка сільськогосподарського, садівничого чи оленярського підприємства?', '2026-08-28 19:05:47.778076+00'),
	('1fb6a385-aed7-485d-affc-19a79001da26', 'uk', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Чи стосується заявка закупівлі літератури для публічних або шкільних бібліотек?', '2026-08-28 19:05:47.778076+00'),
	('c3b32496-fc44-4100-83f3-fa3492556042', 'uk', 'Avser investeringen jordbruksverksamhet?', 'Чи стосується інвестиція сільськогосподарської діяльності?', '2026-08-28 19:05:47.778076+00'),
	('ce292d2d-7540-49a7-b5c9-15d06704265b', 'uk', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Чи передбачає проєкт будівництво, купівлю або ремонт приміщення?', '2026-08-28 19:05:47.778076+00'),
	('401d7406-d336-4d4a-8a3f-a5b896408ea9', 'uk', 'Avser projektet naturvård eller friluftsliv?', 'Чи стосується проєкт охорони природи або активного відпочинку на природі?', '2026-08-28 19:05:47.778076+00'),
	('0acfef76-2356-43e8-b13f-8f106f88eddc', 'uk', 'Avser projektet skola eller vuxenutbildning?', 'Чи стосується проєкт школи або освіти дорослих?', '2026-08-28 19:05:47.778076+00'),
	('9403dbeb-277a-4f78-a79f-1a7ec7c95058', 'uk', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Чи відмовляєтеся ви від роботи, щоб доглядати за близькою людиною або бути поруч із нею, коли хвороба настільки тяжка, що загрожує її життю?', '2026-08-28 19:05:47.778076+00'),
	('fa9496c8-8e13-4181-a45c-6282f2c9f7fe', 'uk', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Чи вважаєте ви, що ваша працездатність знижена щонайменше на рік через хворобу або інвалідність?', '2026-08-28 19:05:47.778076+00'),
	('da8b10b0-03c7-4e11-b370-22db2b02f815', 'uk', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Адресна підтримка для тих, хто має низьку пенсію або не має її, і потребує допомоги для досягнення прийнятного рівня життя.', '2026-08-28 19:05:47.778076+00'),
	('11e11745-6345-46cd-aa7c-3ede7c71173c', 'uk', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Чи потрібно дитині жити в місці навчання (проживання), бо дорога надто довга?', '2026-08-28 19:05:47.778076+00'),
	('512084a5-d3b4-4f56-9dc8-9520748e9338', 'uk', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Чи потрібно адаптувати житло (наприклад, пандус, автоматичні двері, ванна)?', '2026-08-28 19:05:47.778076+00'),
	('fcd17c06-3263-4ebe-bbfe-4dbf93855a5c', 'uk', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Чи потрібні комусь із ваших дітей 8–19 років окуляри або лінзи?', '2026-08-28 19:05:47.778076+00'),
	('fb3f2b82-6757-4c59-b080-f8fcc0d9befa', 'uk', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Другий із батьків не платить нічого або платить менше за повне утримання?', '2026-08-28 19:05:47.778076+00'),
	('742cd036-c383-4b2a-9357-70722699c09b', 'uk', 'Betalar du hyra eller andra boendekostnader?', 'Чи сплачуєте ви оренду або інші витрати на житло?', '2026-08-28 19:05:47.778076+00'),
	('929144b4-3cb5-4c87-a773-89956fe9aaf8', 'uk', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Допомога на адаптацію житла при інвалідності — наприклад, пандуси, автоматичні двері чи переобладнання ванної.', '2026-08-28 19:05:47.778076+00'),
	('35486a59-6351-49bb-9889-f8d84271e5fb', 'uk', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Допомоги на будівництво, купівлю або ремонт громадських приміщень для зібрань.', '2026-08-28 19:05:47.778076+00'),
	('e51478de-4526-4994-bd90-5637ba8f0d40', 'uk', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Допомога на купівлю або адаптацію автомобіля, коли стійка інвалідність значно ускладнює пересування чи поїздки громадським транспортом.', '2026-08-28 19:05:47.778076+00'),
	('15dc3329-4f33-48c8-a843-f04c88cfb09a', 'uk', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Допомоги на міжнародні поїздки та обміни для професіоналів у сфері культури.', '2026-08-28 19:05:47.778076+00'),
	('9686505e-4e77-4b93-b91c-66d3ecc6f79f', 'uk', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Допомоги на міжнародні обміни, поїздки та робочі перебування професійних митців.', '2026-08-28 19:05:47.778076+00'),
	('ccc47019-7763-456d-ac92-963076852915', 'uk', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Допомога та добровільна позика для навчання на гімназійному або післягімназійному рівні.', '2026-08-28 19:05:47.778076+00'),
	('f37736f9-5c1a-47e0-8e5a-96b75e7cfe53', 'uk', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Допомоги й позики для навчання за кордоном, з додатковими позиками, наприклад, на плату за навчання та поїздки.', '2026-08-28 19:05:47.778076+00'),
	('d7fad1db-c4d5-412b-bdfb-8e71c0f69b09', 'uk', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Допомога, що допомагає шведським організаціям готувати заявки на програми ЄС, як-от Horisont Europa.', '2026-08-28 19:05:47.778076+00'),
	('9ab50a50-e564-40ee-afe8-fbbd33f4feb7', 'uk', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Допомога роботодавцям, які наймають людей зі зниженою працездатністю.', '2026-08-28 19:05:47.778076+00'),
	('e2d8c54d-e052-4e0d-99e7-3eb804c25c45', 'uk', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Допомога на проживання та поїздки додому, коли гімназист мусить жити в місці навчання через довгу дорогу.', '2026-08-28 19:05:47.778076+00'),
	('ea7b7742-98c2-4691-bb95-341f0adcbce1', 'uk', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Допомоги на роботу неприбуткових організацій зі збереження, використання та розвитку культурної спадщини.', '2026-08-28 19:05:47.778076+00'),
	('4e94a1c6-2b12-4342-9c04-ed4fdbcecc71', 'uk', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Допомоги на муніципальні та місцеві природоохоронні проєкти, включно з водно-болотними угіддями та активним відпочинком.', '2026-08-28 19:05:47.778076+00'),
	('1f2944ea-e03c-4fd7-b5aa-5a1ed57d5b21', 'uk', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Допомоги комунам на закупівлю літератури для публічних і шкільних бібліотек.', '2026-08-28 19:05:47.778076+00'),
	('31ab467c-86d0-496e-87a9-ea5893d005c3', 'uk', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Допомоги шкільним організаціям для знайомства учнів основної школи з професійною культурою.', '2026-08-28 19:05:47.778076+00'),
	('fccbd759-9cfd-42ca-bb9d-5e544ba8f111', 'uk', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Допомога на те, що потрібно вашій дитині, але на що не вистачає сімейного бюджету: дозвілля, одяг, шкільні екскурсії, окуляри, канікулярні заняття тощо.', '2026-08-28 19:05:47.778076+00'),
	('8f14ada1-cef4-4ee0-b090-21741f2ac213', 'uk', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Допомоги з фондів Världens Barn, Musikhjälpen і Victoriafonden — їх запитують шведські неприбуткові організації з 90-konto.', '2026-08-28 19:05:47.778076+00'),
	('f7406fbe-f2d9-4111-81c8-6754a3e9fab0', 'uk', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Допомоги з коштів гідро- та вітроенергетики на проєкти, що розвивають місцевість.', '2026-08-28 19:05:47.778076+00');
INSERT INTO public.kb_translations VALUES
	('22c3a324-a818-4083-a8cf-c7cc610672e7', 'so', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Khibradaha ma loo isticmaali doonaa hawshaada Sweden gudaheeda?', '2026-08-28 19:05:47.787236+00'),
	('3d049d8a-3591-45ed-8117-669f6dceb5c7', 'uk', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Допомога без позикової частини для безробітних 25–60 років із короткою освітою, яким потрібно вчитися на рівні основної школи або гімназії.', '2026-08-28 19:05:47.778076+00'),
	('b5ddb905-2f6a-448b-b17e-1f0c362f6f99', 'uk', 'Bidrar projektet till energiomställningen?', 'Чи робить проєкт внесок в енергетичний перехід?', '2026-08-28 19:05:47.778076+00'),
	('f0c1f448-d749-4d53-89ce-73c6c07f0d60', 'uk', 'Bor du och barnets andra förälder på skilda håll?', 'Чи живете ви й другий із батьків дитини окремо?', '2026-08-28 19:05:47.778076+00'),
	('addfd6e5-cda8-418f-b93f-abbac4eb85c5', 'uk', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Чеки для малих підприємств на залучення зовнішньої експертизи для інтернаціоналізації або цифровізації.', '2026-08-28 19:05:47.778076+00'),
	('d04c5421-d1c3-4030-93bc-237578aa20aa', 'uk', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Чи берете ви участь у програмі Arbetsförmedlingen (наприклад, jobb- och utvecklingsgarantin)?', '2026-08-28 19:05:47.778076+00'),
	('32981186-139f-4487-a82d-8a148034c61d', 'uk', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Подальша підтримка видавництвам за випуск якісної літератури.', '2026-08-28 19:05:47.778076+00'),
	('3276be5b-7319-491d-b5ff-a10ab0c32f36', 'uk', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Економічна підтримка для тих, хто має посвідку на проживання за захистом і добровільно хоче назавжди повернутися до країни походження.', '2026-08-28 19:05:47.778076+00'),
	('af156223-86d4-4364-9ae4-82ff518f9121', 'uk', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Економічна підтримка роботодавцям, які наймають людину, що довго не працювала.', '2026-08-28 19:05:47.778076+00'),
	('7223a9a5-2c43-41b5-87fd-9328a828f242', 'uk', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Економічна підтримка на етапі запуску для шукачів роботи, які відкривають власну справу.', '2026-08-28 19:05:47.778076+00'),
	('edae30a2-0428-46a6-91c5-87b2e142dd2a', 'uk', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten постійно відкриває конкурси в галузі енергетичних досліджень, інновацій та енергоефективності.', '2026-08-28 19:05:47.778076+00'),
	('a79de91b-1df4-457d-a68d-0b98bcc03519', 'uk', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Виплата за відсутність на роботі чи навчанні для догляду за дитиною.', '2026-08-28 19:05:47.778076+00'),
	('99d0b3e7-61ab-4d6d-bd6b-e255bd84a63c', 'uk', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Виплата для тих, хто нещодавно у Швеції та бере участь у програмі адаптації Arbetsförmedlingen; виплачує Försäkringskassan.', '2026-08-28 19:05:47.778076+00'),
	('0c885670-546d-4e85-8bde-049fcda43f5f', 'uk', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Виплата, що покриває частину витрат на житло для молоді без дітей із низькими доходами.', '2026-08-28 19:05:47.778076+00'),
	('dc52f916-d6e1-4e41-9bb4-62fa5ad2440f', 'uk', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Виплата за додаткові витрати, пов''язані зі стійкою інвалідністю — для дорослих або батьків дітей з інвалідністю.', '2026-08-28 19:05:47.778076+00'),
	('552b5e66-82e9-4eb0-acd7-fe4bb0315c74', 'uk', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Виплата для молоді (19–29 років), яка не може працювати повний день щонайменше рік через хворобу чи інвалідність.', '2026-08-28 19:05:47.778076+00'),
	('17f56d58-e42e-4340-aeb4-e6e01a17ddb6', 'uk', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Виплата при стійко зниженій працездатності — те, що раніше називалося förtidspension (дострокова пенсія).', '2026-08-28 19:05:47.778076+00'),
	('07e016db-c8ce-410d-8fd1-156240b93c08', 'uk', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Виплата, коли ви відмовляєтеся від роботи, щоб бути поруч із тяжкохворою близькою людиною.', '2026-08-28 19:05:47.778076+00'),
	('47486f2c-3532-4999-a5da-628248c751d8', 'uk', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Виплата за участь у програмі ринку праці Arbetsförmedlingen.', '2026-08-28 19:05:47.778076+00'),
	('e4031f6e-a5f5-4013-b86f-b71488040a90', 'uk', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Виплата, коли ви не можете працювати як зазвичай через хворобу.', '2026-08-28 19:05:47.778076+00'),
	('5f6c475d-1f60-4ec9-928d-c03474b95aaa', 'uk', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Виплата, коли ви залишаєтеся вдома з роботи для догляду за хворою дитиною.', '2026-08-28 19:05:47.778076+00'),
	('f2ffed1e-6fb1-4d39-94a9-b9f2dbb1ec86', 'uk', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Виплата, що покриває частину витрат на житло для сімей із дітьми та невисокими доходами.', '2026-08-28 19:05:47.778076+00'),
	('44b91cd6-4fa9-4287-a391-6c6484b1984e', 'uk', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Виплата батькам, чиї діти через інвалідність потребують більше догляду й нагляду, ніж однолітки.', '2026-08-28 19:05:47.778076+00'),
	('2a277056-4e3c-4d17-8a1d-a4ddf522a74e', 'uk', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Виплата при безробітті — на основі доходу для членів каси, базова сума для інших.', '2026-08-28 19:05:47.778076+00'),
	('3323e67c-7ba0-43b3-a5e3-bc64091dd50a', 'uk', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Близько п''ятдесяти фондів ощадних банків надають допомоги місцевим проєктам у спорті, культурі, освіті та розвитку громади — у зоні діяльності банку.', '2026-08-28 19:05:47.778076+00'),
	('3ef9cd7a-3afb-4496-8177-9587f57ca34c', 'uk', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Чи присвячений проєкт екологічним або кліматичним заходам?', '2026-08-28 19:05:47.778076+00'),
	('28f62dcd-480f-4550-a7bd-21f06ddf933d', 'uk', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Фінансована ЄС проєктна підтримка, яку запитують у вашій місцевій зоні Leader — для об''єднань, компаній і комун, що розвивають сільську місцевість.', '2026-08-28 19:05:47.778076+00'),
	('b1a6c673-21e0-4402-a25a-358fd092d1c9', 'uk', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Фінансована ЄС підтримка для шукачів роботи, які влаштовуються в іншій країні ЄС/ЄЕП: компенсація поїздки на співбесіду, витрат на переїзд і мовного курсу.', '2026-08-28 19:05:47.778076+00'),
	('4c11b44e-1761-45ce-9d24-af645673988b', 'uk', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Кошти соціального фонду ЄС на проєкти, що зміцнюють компетенції, перекваліфікацію та інклюзію на ринку праці.', '2026-08-28 19:05:47.778076+00'),
	('3efcce85-aeaf-42a9-baf0-df31148c7556', 'uk', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Підтримка ЄС для групових обмінів молоді 13–30 років, тривалістю 5–21 день без урахування днів у дорозі.', '2026-08-28 19:05:47.778076+00'),
	('bfca2a5a-a93f-4b62-897c-8669f37e25f5', 'uk', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Підтримка ЄС для проєктів співпраці культурних організацій із партнерами в кількох європейських країнах.', '2026-08-28 19:05:47.778076+00'),
	('c7229518-e94b-435b-8621-f36cd4a0e320', 'uk', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Підтримка ЄС для організацій, що приймають або направляють молодих волонтерів 18–30 років.', '2026-08-28 19:05:47.778076+00'),
	('8df60ad7-06d8-4eb0-ab9f-6dea01fe1ce0', 'uk', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Підтримка ЄС для мобільності персоналу та учнів у школі та освіті дорослих.', '2026-08-28 19:05:47.778076+00'),
	('981f5778-3718-4f13-9250-eff640198e00', 'uk', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Підтримка ЄС із фіксованими сумами для перших європейських проєктів співпраці невеликих організацій.', '2026-08-28 19:05:47.778076+00'),
	('17b57ee4-5625-434e-a63c-357d622b88ab', 'uk', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Фінансування молодих компаній, що розробляють новаторські продукти чи послуги з міжнародним потенціалом.', '2026-08-28 19:05:47.778076+00'),
	('fc148010-3561-45c4-ad70-a56aceee6d55', 'uk', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Чи є ощадний банк (і, отже, фонд ощадного банку) там, де ви ведете діяльність?', '2026-08-28 19:05:47.778076+00'),
	('a218abd4-2413-4287-a92a-f9f34d2902ee', 'uk', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Багаторічні операційні допомоги професійним незалежним колективам танцю, театру та музичного театру.', '2026-08-28 19:05:47.778076+00'),
	('c377fd09-1eb3-42d6-8bf1-2f8b5a6cd31e', 'uk', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Дослідницькі допомоги в галузях Forte: здоров''я, трудове життя та добробут. Запитують дослідники з докторським ступенем у шведських вишах.', '2026-08-28 19:05:47.778076+00'),
	('d8a65b43-70f8-45a3-82e9-7e93bcc1302c', 'uk', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Фінансування вільних фундаментальних досліджень у всіх галузях науки.', '2026-08-28 19:05:47.778076+00'),
	('1819d6d6-fb84-48b4-992a-5dace9fc1b0f', 'uk', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Фінансування досліджень у галузі довкілля, аграрних наук і містобудування.', '2026-08-28 19:05:47.778076+00'),
	('09e2712e-cc2b-45b3-b7bd-dd97d9d1b3a7', 'uk', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Чи думаєте ви про переїзд за кордон (робота, навчання чи повернення на батьківщину)?', '2026-08-28 19:05:47.778076+00'),
	('830e5df1-2e56-4489-819c-a45d9330c257', 'uk', 'Genomförs insatserna av professionella kulturaktörer?', 'Чи проводяться заходи професійними діячами культури?', '2026-08-28 19:05:47.778076+00'),
	('701d534f-f1a5-4540-94e8-66e2b9ebfb4d', 'uk', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Чи реалізується проєкт у сільській місцевості або невеликому населеному пункті?', '2026-08-28 19:05:47.778076+00'),
	('436c09bc-f239-4644-91a7-c3239292e365', 'uk', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Базовий захист для тих, хто протягом життя мав низький трудовий дохід або не мав його.', '2026-08-28 19:05:47.778076+00'),
	('96297028-cc6f-4b9c-bbd6-e0e671d3a6e5', 'uk', 'Går något av dina barn i grundskolan?', 'Чи ходить хтось із ваших дітей до основної школи?', '2026-08-28 19:05:47.778076+00'),
	('31a4d55f-210a-4b34-8342-070f5b56082f', 'uk', 'Går något av dina barn på gymnasiet?', 'Чи навчається хтось із ваших дітей у гімназії?', '2026-08-28 19:05:47.778076+00'),
	('b643f412-d08d-4acc-b4fc-919b589f59b9', 'uk', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Чи стосується найм людини зі зниженою працездатністю?', '2026-08-28 19:05:47.778076+00'),
	('90d14d99-313d-4f69-9689-31c63f2e20bc', 'uk', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Чи стосується найм людини, яка довго була безробітною або нещодавно приїхала до Швеції?', '2026-08-28 19:05:47.778076+00'),
	('41674218-11dc-44d2-8b65-e87e95f08b8a', 'uk', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Чи присвячений проєкт збереженню культурної спадщини або забезпеченню доступу до неї?', '2026-08-28 19:05:47.778076+00'),
	('f6fcb1f0-31f8-489c-b654-c873366b649d', 'uk', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Чи присвячений проєкт енергетиці, енергоефективності або енергетичним інноваціям?', '2026-08-28 19:05:47.778076+00');
INSERT INTO public.kb_translations VALUES
	('26e466b9-410b-4209-b413-6ddbfa8b89c9', 'uk', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Чи присвячений проєкт здоров''ю, трудовому життю або добробуту?', '2026-08-28 19:05:47.778076+00'),
	('883ede22-317a-4c3c-8bad-85e6e291900b', 'uk', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Чи присвячений проєкт розвитку компетенцій або заходам на ринку праці?', '2026-08-28 19:05:47.778076+00'),
	('136cc08f-8175-4419-a12c-eb657fdf23a3', 'uk', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Чи довга в дитини дорога до школи, небезпечна через рух або складна з інших причин?', '2026-08-28 19:05:47.778076+00'),
	('2e112666-6d61-4a0b-9a5e-7ba7f22abe2b', 'uk', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Чи працювали ви щонайменше 16 годин на тиждень загалом щонайменше 8 років?', '2026-08-28 19:05:47.778076+00'),
	('2e749c12-64a9-4cfd-8a8e-7932cedaa60a', 'uk', 'Har du barn som bor hos dig, helt eller växelvis?', 'Чи живуть із вами діти — постійно або почергово?', '2026-08-28 19:05:47.778076+00'),
	('1322fa7f-9596-4d3b-89e2-76bd2abf24ae', 'uk', 'Har du barn som bor hos dig?', 'Чи живуть із вами діти?', '2026-08-28 19:05:47.778076+00'),
	('5b7d3891-3f80-4499-b4bc-35e48299f036', 'uk', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Чи є у вас або вашої дитини інвалідність, яка, як очікується, триватиме щонайменше рік?', '2026-08-28 19:05:47.778076+00'),
	('4b8d99b9-e0a7-4adc-a08a-aad4f03ce4d5', 'uk', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Чи має хтось у родині стійку інвалідність, що впливає на житло?', '2026-08-28 19:05:47.778076+00'),
	('47ec6b19-6eec-4f28-a584-1b103c629225', 'uk', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Чи має хтось із вас або близьких родичів інвалідність або тривалу чи тяжку хворобу?', '2026-08-28 19:05:47.778076+00'),
	('0d4bb248-3591-48d7-957f-670669c45768', 'uk', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Чи є у вас хвороба або травма, яка зараз знижує вашу працездатність?', '2026-08-28 19:05:47.778076+00'),
	('e04fd442-684f-44d4-b5c0-09ca837a3ec5', 'uk', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Чи бувало вам важко оплатити шкільну екскурсію, класну поїздку або дозвіллєве заняття, у якому має брати участь ваша дитина?', '2026-08-28 19:05:47.778076+00'),
	('7aac2f11-c431-4788-94ba-c387126fa1e7', 'uk', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Чи важко вам прожити на пенсію та інші доходи?', '2026-08-28 19:05:47.778076+00'),
	('1a81133e-645d-4ee5-8bb7-9de2e695e806', 'uk', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Чи отримували ви останніми роками посвідку на проживання у Швеції, наприклад, як особа, що потребує захисту, або як член сім''ї?', '2026-08-28 19:05:47.778076+00'),
	('5200c3e5-711c-4138-adb9-f8dcfff8ec77', 'uk', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Чи маєте ви посвідку на проживання у Швеції як біженець або особа, що потребує захисту (або ви близький родич такої особи)?', '2026-08-28 19:05:47.778076+00'),
	('5d5830b8-01d3-40dd-9093-fe60be4b487f', 'uk', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Чи досягли ви цільового пенсійного віку (67 років у 2026 році)?', '2026-08-28 19:05:47.778076+00'),
	('c4752937-4be8-41ab-8764-4e74d82746c1', 'uk', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Чи має ваша організація OID (Organisation ID), зареєстрований в Organisation Registration System ЄС?', '2026-08-28 19:05:47.778076+00'),
	('b1af10ae-f17d-43a0-8fe0-d85fa409041d', 'uk', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Чи спричинила інвалідність додаткові витрати — наприклад, допоміжні засоби, поїздки, особливе харчування або знос?', '2026-08-28 19:05:47.778076+00'),
	('c28a57fd-4c38-4261-b673-a7aefb398752', 'uk', 'Har föreningen antagna stadgar och en vald styrelse?', 'Чи має об''єднання ухвалений статут та обране правління?', '2026-08-28 19:05:47.778076+00'),
	('6ffd2280-1ffb-4043-8582-6d4bb1ca777f', 'uk', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Чи має об''єднання демократичний устрій (статут, річні збори, правління)?', '2026-08-28 19:05:47.778076+00'),
	('c8f09195-b384-4916-8fdb-15fb513e96fe', 'uk', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Чи веде об''єднання регулярну діяльність для дітей або молоді?', '2026-08-28 19:05:47.778076+00'),
	('923fd69c-f5d8-43a6-adf1-8b9d20ff1610', 'uk', 'Har företaget mellan cirka 2 och 49 anställda?', 'У компанії приблизно від 2 до 49 працівників?', '2026-08-28 19:05:47.778076+00'),
	('81bef723-d8cc-4f41-b510-612e41d13ac2', 'uk', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Чи важко родині покривати витрати на їжу, житло та найнеобхідніше?', '2026-08-28 19:05:47.778076+00'),
	('af62ae31-538d-4522-9e21-8d4f3f9b68e2', 'uk', 'Har lösningen internationell potential?', 'Чи має рішення міжнародний потенціал?', '2026-08-28 19:05:47.778076+00'),
	('cf7ede80-e52e-4b4a-9723-381ef0cb34e8', 'uk', 'Har ni en partnergrupp i ett annat land?', 'Чи є у вас партнерська група в іншій країні?', '2026-08-28 19:05:47.778076+00'),
	('f502a951-4c64-4c09-9efd-99d6513926fc', 'uk', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Чи є у вас партнерська організація в іншій європейській країні?', '2026-08-28 19:05:47.778076+00'),
	('026244b1-a464-46da-8fec-8457ae621ed2', 'uk', 'Har ni partner i minst tre olika europeiska länder?', 'Чи є у вас партнери щонайменше у трьох різних європейських країнах?', '2026-08-28 19:05:47.778076+00'),
	('99c92741-a13e-470e-b2b4-3951e9d57245', 'uk', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Чи розташований ваш офіс або основна діяльність у регіоні, де ви подаєте заявку?', '2026-08-28 19:05:47.778076+00'),
	('28406446-ebb5-46e3-8f39-d6e615cada2a', 'uk', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Чи має хтось із ваших дітей інвалідність, через яку дитина потребує більше догляду або нагляду, ніж інші діти того ж віку?', '2026-08-28 19:05:47.778076+00'),
	('29f02996-acb4-45a4-87d1-33941925e2d5', 'uk', 'Har organisationen en demokratisk uppbyggnad?', 'Чи має організація демократичний устрій?', '2026-08-28 19:05:47.778076+00'),
	('4de41c31-80bc-4c88-9211-b1a01b373f30', 'uk', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Чи має організація Quality Label (знак якості)?', '2026-08-28 19:05:47.778076+00'),
	('eedefce3-6b4e-4d62-a4c1-7d2e92d49fe3', 'uk', 'Har organisationen ett 90-konto?', 'Чи має організація 90-konto?', '2026-08-28 19:05:47.778076+00'),
	('d7d49e8f-df13-4e88-b28a-c4a8dc0cd27a', 'uk', 'Har organisationen ett OID (Organisation ID)?', 'Чи має організація OID (Organisation ID)?', '2026-08-28 19:05:47.778076+00'),
	('c128b31f-b535-4f3d-ad6d-fca858b7d551', 'uk', 'Har organisationen ett OID?', 'Чи має організація OID?', '2026-08-28 19:05:47.778076+00'),
	('628fb619-28f9-4baf-bd4a-f14b12ee2bf4', 'uk', 'Har organisationen medlemsföreningar i flera län?', 'Чи має організація об''єднання-члени в кількох ленах?', '2026-08-28 19:05:47.778076+00'),
	('ae3cb5f9-68d3-471b-9f78-f9202c925740', 'uk', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Чи має організація впорядковані фінанси та демократичний устрій?', '2026-08-28 19:05:47.778076+00'),
	('2b6b28d1-679d-4898-bb07-df21b708c8cd', 'uk', 'Har projektet en partner i ett annat land?', 'Чи має проєкт партнера в іншій країні?', '2026-08-28 19:05:47.778076+00'),
	('07a5b8e1-6e8e-490d-b417-378549611448', 'uk', 'Har projektledaren doktorsexamen?', 'Чи має керівник проєкту докторський ступінь?', '2026-08-28 19:05:47.778076+00'),
	('f365e0f5-90e4-4114-8cf7-40bd90fa5c0a', 'uk', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Домашня комуна має забезпечувати щоденні поїздки між домом і гімназією, якщо дорога становить щонайменше шість кілометрів (наприклад, проїзний на автобус).', '2026-08-28 19:05:47.778076+00'),
	('72e321be-2856-485a-a852-adf36fe67cb8', 'uk', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Чи облаштовуєте ви своє перше власне житло у Швеції?', '2026-08-28 19:05:47.778076+00'),
	('ce0b3689-9de6-4877-8df6-ff85ca1b9911', 'uk', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Чи включає проєкт міжнародну поїздку або обмін?', '2026-08-28 19:05:47.778076+00'),
	('6a4ff00e-2b05-4ba9-9e87-385f859187b5', 'uk', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Інвестиційна підтримка компаніям у зонах підтримки — на будівлі, обладнання та навчання.', '2026-08-28 19:05:47.778076+00'),
	('c4404f74-d941-4924-8489-62943a49e458', 'uk', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Інвестиційна підтримка заходів, що знижують викиди парникових газів.', '2026-08-28 19:05:47.778076+00'),
	('5cf96c7a-d59f-4fcc-ba93-f5b0c931b2c4', 'uk', 'Kan projektets miljönytta mätas?', 'Чи можна виміряти екологічну користь проєкту?', '2026-08-28 19:05:47.778076+00'),
	('f8ca5359-98eb-4a04-bd80-0b8158c7c7a1', 'uk', 'Kan åtgärdens utsläppsminskning beräknas?', 'Чи можна розрахувати зниження викидів від заходу?', '2026-08-28 19:05:47.778076+00'),
	('cdfabb56-39eb-4a6a-bc97-5075d76da6a1', 'uk', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Чи може організація нести витрати до виплати підтримки?', '2026-08-28 19:05:47.778076+00'),
	('1ccd449d-176e-4b30-a393-48db8835a400', 'uk', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Чи буде досвід використано у вашій діяльності у Швеції?', '2026-08-28 19:05:47.778076+00'),
	('4270b184-c288-4880-8b45-9619c05948d3', 'uk', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Чи розпочнеться інвестиція лише після подання заявки?', '2026-08-28 19:05:47.778076+00'),
	('c7e1add0-381d-447c-aedb-aae1a0616c03', 'uk', 'Kommer projektet människor i ert närområde till del?', 'Чи приносить проєкт користь людям у вашій місцевості?', '2026-08-28 19:05:47.778076+00'),
	('a9d38ae7-22d7-419d-b604-7175b076bc54', 'uk', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Крайній економічний захист комуни, коли доходів не вистачає на найнеобхідніше.', '2026-08-28 19:05:47.778076+00'),
	('8ff39cd5-8636-4ec2-beeb-641adcdc900e', 'uk', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Власна підтримка комун місцевим об''єднанням: допомога за заняття, допомога з приміщеннями, стартова допомога тощо.', '2026-08-28 19:05:47.778076+00');
INSERT INTO public.kb_translations VALUES
	('05e80a5c-d62f-4cbd-bdac-8ebd4b908b1d', 'uk', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Безкоштовний шкільний транспорт для учнів основної школи при великій відстані, небезпечній дорозі або інвалідності — право за шкільним законом.', '2026-08-28 19:05:47.778076+00'),
	('b79f0cf7-adcd-4910-8a56-ae7fb6e0024b', 'uk', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Встановлена законом допомога на окуляри або лінзи для дітей та молоді; суми та порядок різняться за регіонами — перевірте рівень свого регіону.', '2026-08-28 19:05:47.778076+00'),
	('bc45af62-9afb-4ca3-bc1e-8c84b55f54b3', 'uk', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Чи розташований проєкт у місцевості, якої стосується гідро- або вітроенергетика?', '2026-08-28 19:05:47.778076+00'),
	('91b71f3c-d051-482e-8181-40bf2585cb4c', 'uk', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Чи належить проєкт до довкілля, аграрних наук або містобудування?', '2026-08-28 19:05:47.778076+00'),
	('9abe4931-ab0f-4391-b020-84d836d89652', 'uk', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Чи розташоване місце діяльності в зоні підтримки A або B (велика частина Норрланда та внутрішнього Свеаланда)?', '2026-08-28 19:05:47.778076+00'),
	('606db530-245f-48ec-89ec-9e697b4ab966', 'uk', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Позика на купівлю найнеобхіднішого для першого дому у Швеції — меблів, домашнього начиння та іншого базового оснащення.', '2026-08-28 19:05:47.778076+00'),
	('0b5c2d26-45d4-408f-8964-8dae4f7fe54c', 'uk', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Чи знижує проєкт технологічні викиди промисловості або створює від''ємні викиди?', '2026-08-28 19:05:47.778076+00'),
	('2cc103e1-cf3d-43b9-ac06-9e136bd396a2', 'uk', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Щомісячна допомога на дітей, які живуть у Швеції, від народження до 16 років.', '2026-08-28 19:05:47.778076+00'),
	('693c039b-0e88-4528-bf3e-b92b7ba43b4d', 'uk', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket пропонує допомоги організаціям, компаніям, об''єднанням, публічному сектору та приватним особам у сфері довкілля.', '2026-08-28 19:05:47.778076+00'),
	('e75900f4-4266-4b95-94d4-b842d49e7925', 'uk', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Чи плануєте ви добровільно назавжди повернутися до країни походження?', '2026-08-28 19:05:47.778076+00'),
	('347a7e32-55a1-4236-83cf-c72cd7083cff', 'uk', 'Planerar du att starta eget företag?', 'Чи плануєте ви відкрити власну справу?', '2026-08-28 19:05:47.778076+00'),
	('122fcb6c-7ef4-4338-8848-83494f22e736', 'uk', 'Planerar du att studera utomlands?', 'Чи плануєте ви навчатися за кордоном?', '2026-08-28 19:05:47.778076+00'),
	('73b96d5c-a961-4f09-b374-5c146f230734', 'uk', 'Är projektet ett konst- eller kulturprojekt?', 'Це мистецький або культурний проєкт?', '2026-08-28 19:05:47.782235+00'),
	('44bc75b8-02a9-4587-b529-7319a010d589', 'uk', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Чи плануєте ви навчання, що зміцнить вашу позицію на ринку праці?', '2026-08-28 19:05:47.778076+00'),
	('99fbe647-b07a-400d-96b1-58ccc9e3bb77', 'uk', 'Planerar ni att anställa?', 'Чи плануєте ви наймати працівників?', '2026-08-28 19:05:47.778076+00'),
	('021bf0b4-7dfc-432c-9bc1-7e8adbc7a6ca', 'uk', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Чи плануєте ви подаватися на програму ЄС (наприклад, Horisont Europa)?', '2026-08-28 19:05:47.778076+00'),
	('3ae7e842-fb91-4732-a8dc-94abf7c39684', 'uk', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Підтримка виробництва та розробки короткометражних і документальних фільмів.', '2026-08-28 19:05:47.778076+00'),
	('8595cb7e-bc6c-4a20-a217-f3ebf5aa692d', 'uk', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Проєктні допомоги вільній музичній сцені на концерти, виробництво та розвиток.', '2026-08-28 19:05:47.778076+00'),
	('468783db-fd43-46ef-910b-c60d732bc80c', 'uk', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Проєктні допомоги неприбутковим організаціям, що працюють із дітьми та молоддю і для них.', '2026-08-28 19:05:47.778076+00'),
	('c643a325-fbaa-4235-a7b0-4249fae2ac73', 'uk', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Чи випробовує проєкт нові мистецькі вирази, методи або співпраці?', '2026-08-28 19:05:47.778076+00'),
	('fe25afdb-5f54-477c-91f1-c9b49f0341f4', 'uk', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Чи триває обмін 5–21 день (без урахування днів у дорозі)?', '2026-08-28 19:05:47.778076+00'),
	('1f26bf8d-e1d9-4e2b-945b-6cdb84a00f4a', 'uk', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Власна проєктна та операційна підтримка регіонів культурного життя, поряд із національними допомогами Kulturrådet.', '2026-08-28 19:05:47.778076+00'),
	('b4bdcc2b-360b-4917-a9c8-638dd290cbc5', 'uk', 'Riktar sig projektet till barn eller unga?', 'Чи адресований проєкт дітям або молоді?', '2026-08-28 19:05:47.778076+00'),
	('1f0ad5f3-2393-4334-a313-04a8fcb213c0', 'uk', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Чи адресований проєкт дітям, молоді, літнім людям або людям з інвалідністю?', '2026-08-28 19:05:47.778076+00'),
	('d63e7973-9f31-40e5-807e-3456a295dbff', 'uk', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Чи адресована діяльність дітям і молоді (7–25 років)?', '2026-08-28 19:05:47.778076+00'),
	('5ed7b2e5-543e-4733-b447-62f381a14341', 'uk', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Чи бракує вам заощаджень або активів, які могли б покрити витрати?', '2026-08-28 19:05:47.778076+00'),
	('4e936770-a9a2-4e14-86b3-58472fb0e3b6', 'uk', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Чи співпрацюєте ви з партнерами щонайменше у двох інших північних країнах?', '2026-08-28 19:05:47.778076+00'),
	('c2f129a7-e293-4a15-98cc-88ea1e96863a', 'uk', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Чи залучатимете ви зовнішню експертизу для заходу розвитку?', '2026-08-28 19:05:47.778076+00'),
	('9acd6104-34c8-4ffe-88aa-00a9c39317af', 'uk', 'Sker mobiliteten till ett annat europeiskt land?', 'Чи спрямована мобільність до іншої європейської країни?', '2026-08-28 19:05:47.778076+00'),
	('6cbdcbb3-c951-4f74-b30f-317443d046b7', 'uk', 'Startar du eller tar du över företaget för första gången?', 'Чи відкриваєте ви підприємство або берете його на себе вперше?', '2026-08-28 19:05:47.778076+00'),
	('91f699d4-8b28-47bf-991e-a468f365952e', 'uk', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Стартова підтримка для тих, кому 40 років або менше, хто відкриває сільськогосподарське підприємство або бере його на себе.', '2026-08-28 19:05:47.778076+00'),
	('2f6638b9-6d64-47ef-bd7d-b565c46e5ab1', 'uk', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Стипендія, що дає професійним митцям змогу зосередитися на мистецькій роботі.', '2026-08-28 19:05:47.778076+00'),
	('f9c0d261-3ed9-4343-a6ba-6dc690708529', 'uk', 'Studerar du, eller planerar du att börja studera?', 'Чи навчаєтеся ви або плануєте почати навчання?', '2026-08-28 19:05:47.778076+00'),
	('5480e4e1-5c12-4f55-b2ed-83e6f1bdc7b2', 'uk', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Навчальна підтримка для працюючих дорослих, які хочуть здобути освіту для зміцнення позиції на ринку праці.', '2026-08-28 19:05:47.778076+00'),
	('71d7674c-5291-43ee-ac10-6cb43530d456', 'uk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Підтримка інвестицій, що підвищують конкурентоспроможність або знижують вплив на довкілля в сільськогосподарських підприємствах.', '2026-08-28 19:05:47.778076+00'),
	('769f8b9b-bccf-4c82-81c5-931f731e2a69', 'uk', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Підтримка, коли дитина живе з вами, а другий із батьків не платить утримання.', '2026-08-28 19:05:47.778076+00'),
	('e1b7b41a-2058-4b9b-8f83-1ce5c86b69e8', 'uk', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Підтримка проєктів неприбуткових організацій для людей, довкілля та кращого світу.', '2026-08-28 19:05:47.778076+00'),
	('f7cee29f-7e68-4887-aef7-d0d7b5de6ec8', 'uk', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Підтримка переходу промисловості до нульових викидів парникових газів.', '2026-08-28 19:05:47.778076+00'),
	('e1958f08-1823-46e4-9711-a31246006f9f', 'uk', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Підтримка мистецьких і культурних проєктів із північним виміром та транскордонною співпрацею.', '2026-08-28 19:05:47.778076+00'),
	('f65991e8-48ba-4cca-8445-cbb3e8aa241f', 'uk', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Підтримка новаторських культурних проєктів, що випробовують нові мистецькі вирази, методи або співпраці.', '2026-08-28 19:05:47.778076+00'),
	('ab3ce589-7333-463e-bade-089a2734d0ee', 'uk', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Підтримка новаторських проєктів для дітей, молоді, літніх людей і людей з інвалідністю.', '2026-08-28 19:05:47.778076+00'),
	('4d04f8aa-3177-4096-96c3-4dcf3db3ce71', 'uk', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Підтримка проєктів співпраці у вільній музичній сцені.', '2026-08-28 19:05:47.778076+00'),
	('7138e00b-2552-4d2c-8f6d-eace8b96ef26', 'uk', 'Är projektet ett kulturprojekt?', 'Це культурний проєкт?', '2026-08-28 19:05:47.782235+00'),
	('1c866f56-f6e0-4668-8357-4f64be2d6f33', 'uk', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Підтримка проєктів співпраці в культурі та медіа, що зміцнюють демократію та свободу слова на міжнародному рівні.', '2026-08-28 19:05:47.778076+00'),
	('96ace1a0-5289-4157-9af0-28102805c319', 'uk', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Чи спрямований проєкт на зміцнення демократії, рівності або свободи слова?', '2026-08-28 19:05:47.778076+00'),
	('c556a0eb-4b9d-4d5c-b9f4-0f0c0ed7d6e0', 'uk', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Чи шукаєте ви роботу або отримали пропозицію роботи в іншій країні ЄС чи ЄЕП?', '2026-08-28 19:05:47.778076+00'),
	('a59bd2bc-1e00-4f87-9cea-9e923726e714', 'uk', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Стеля того, що ви платите як пацієнтські збори за дванадцять місяців — далі frikort (безкоштовна картка).', '2026-08-28 19:05:47.778076+00'),
	('9ce2e555-8d01-4831-a7e1-371705c737cf', 'uk', 'Tar du ut hel allmän pension?', 'Чи отримуєте ви повну державну пенсію?', '2026-08-28 19:05:47.778076+00'),
	('57b406a8-8b3f-4a6b-97aa-cfc00bebccb1', 'uk', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Надбавка, що покриває частину витрат на житло для тих, хто має пенсію та низькі доходи.', '2026-08-28 19:05:47.778076+00'),
	('185e0ea2-e207-452f-87b7-a7840ddd4374', 'uk', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Щорічна організаційна допомога національним дитячим і молодіжним організаціям.', '2026-08-28 19:05:47.778076+00');
INSERT INTO public.kb_translations VALUES
	('5ef71644-7e71-4ece-9b5f-7f6b1e87adc3', 'uk', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Щорічна сума, що вираховується безпосередньо у стоматолога або зубного гігієніста.', '2026-08-28 19:05:47.778076+00'),
	('7b78e19e-7b08-4b6b-9af7-64584884acef', 'uk', 'Är bolaget yngre än cirka 5 år?', 'Компанії менше ніж приблизно 5 років?', '2026-08-28 19:05:47.778076+00'),
	('646135bd-7d26-4bf0-82f7-538b58673cda', 'uk', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Учасникам обміну від 13 до 30 років?', '2026-08-28 19:05:47.778076+00'),
	('24e580ce-5b62-4108-ab02-81312bc26a60', 'uk', 'Är det här ert första EU-projekt?', 'Це ваш перший проєкт ЄС?', '2026-08-28 19:05:47.778076+00'),
	('ff913a4b-ba62-406e-92a2-af89d7bc27ba', 'uk', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Чи дуже важко вам (або вашій дитині) пересуватися самостійно чи їздити автобусом і потягом?', '2026-08-28 19:05:47.778076+00'),
	('6161063d-8e43-49fa-869e-1a72d642988c', 'uk', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Ваш дохід нижчий за приблизно 25 000 крон на місяць до податків?', '2026-08-28 19:05:47.778076+00'),
	('92c47a36-8e2e-401b-a139-b51950e5b33d', 'uk', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Ваша остання закінчена освіта — основна школа або незакінчена гімназія?', '2026-08-28 19:05:47.778076+00'),
	('206548c1-faae-4b55-9b45-04dadcd9cd62', 'uk', 'Är du 40 år eller yngre?', 'Вам 40 років або менше?', '2026-08-28 19:05:47.778076+00'),
	('c56cade5-b9f8-4a1d-bc36-546affbcba0e', 'uk', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Чи зареєстровані ви як шукач роботи в Arbetsförmedlingen?', '2026-08-28 19:05:47.778076+00'),
	('1d1df123-dda0-4d67-9f30-f52fd048a223', 'uk', 'Är du mellan 18 och 28 år?', 'Вам від 18 до 28 років?', '2026-08-28 19:05:47.778076+00'),
	('28b5bb57-fc2c-4fcf-b9b0-98eb943eb7ba', 'uk', 'Är du mellan 19 och 29 år?', 'Вам від 19 до 29 років?', '2026-08-28 19:05:47.778076+00'),
	('2534dcdb-eed5-4c4b-9fd1-db5c212834c3', 'uk', 'Är du mellan 25 och 60 år?', 'Вам від 25 до 60 років?', '2026-08-28 19:05:47.778076+00'),
	('d5b126ea-f81b-4816-bab1-ebba4f642ef4', 'uk', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Чи працюєте ви професійно у сфері культури (наприклад, танець, музика, сценічне мистецтво)?', '2026-08-28 19:05:47.778076+00'),
	('e1cd32de-89af-4e4a-ae80-cc56c51123d2', 'uk', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Ви професійний митець (не аматор і не на базовому навчанні)?', '2026-08-28 19:05:47.778076+00'),
	('c53cfe85-3326-46d5-8856-4c909db1acd6', 'uk', 'Är du yrkesverksam konstnär?', 'Ви професійний митець?', '2026-08-28 19:05:47.778076+00'),
	('f6344d9c-2cba-4a60-861f-011a2c3d8a8d', 'uk', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Чи суттєво новаторське ваше рішення порівняно з тим, що вже існує?', '2026-08-28 19:05:47.782235+00'),
	('3a7a4e50-b6a2-4b33-b8fe-3f1cdeb7e2b1', 'uk', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Чи входить клуб до спеціалізованої спортивної федерації у складі Riksidrottsförbundet?', '2026-08-28 19:05:47.782235+00'),
	('112adfb3-eaab-483c-891f-a5e71260dbd0', 'uk', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Чи низькі доходи родини відносно витрат на житло?', '2026-08-28 19:05:47.782235+00'),
	('192c040f-ed99-41a6-a75b-0229e2aaf695', 'uk', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Сукупний дохід родини нижчий за приблизно 25 000 крон на місяць до податків?', '2026-08-28 19:05:47.782235+00'),
	('407ed2b3-1658-44c4-8fec-df1411163597', 'uk', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Чи є захід окремим проєктом (а не звичайною діяльністю)?', '2026-08-28 19:05:47.782235+00'),
	('282080c6-b5b5-47c8-9eb2-06b4b472fe9a', 'uk', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Чи відкрите приміщення для всіх — не лише для власних членів?', '2026-08-28 19:05:47.782235+00'),
	('1035bc75-89d2-4921-be3f-91410ecbe8b5', 'uk', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Щонайменше 60 % членів віком від 6 до 25 років?', '2026-08-28 19:05:47.782235+00'),
	('f0df192d-62b9-4d8a-8efe-189382d92d48', 'uk', 'Är minst 60 % av medlemmarna under 26 år?', 'Щонайменше 60 % членів молодші за 26 років?', '2026-08-28 19:05:47.782235+00'),
	('939bd01e-f7b9-4eab-8c8e-69735f01a8b1', 'uk', 'Är målgruppen delaktig i planering och genomförande?', 'Чи бере цільова група участь у плануванні та реалізації?', '2026-08-28 19:05:47.782235+00'),
	('dce1f8cd-5fb5-4817-8345-2be11201153a', 'uk', 'Är ni ett förlag med professionell utgivning?', 'Ви видавництво з професійним книговиданням?', '2026-08-28 19:05:47.782235+00'),
	('87d7dbbc-8e38-45ce-9b28-84f79e45b5c7', 'uk', 'Är ni huvudman för förskoleklass eller grundskola?', 'Чи є ви відповідальною організацією дошкільного класу або основної школи?', '2026-08-28 19:05:47.782235+00'),
	('ce33da57-919e-4d12-aa52-0230509c59df', 'uk', 'Är organisationen registrerad i EU:s deltagarregister?', 'Чи зареєстрована організація в реєстрі учасників ЄС?', '2026-08-28 19:05:47.782235+00'),
	('faa2494a-d985-4c13-bd0d-981fc29ffb46', 'uk', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Це кінопроєкт (короткометражний або документальний фільм)?', '2026-08-28 19:05:47.782235+00'),
	('2299b0c7-7ba7-4471-b7ae-c6388ca5f42d', 'uk', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Чи новаторський проєкт — те, чого ви ще не робите у звичайній діяльності?', '2026-08-28 19:05:47.782235+00'),
	('003bc011-e54d-40c1-aa10-dcf1c2147033', 'uk', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Чи приносить проєкт користь місцевості загалом (а не окремим особам)?', '2026-08-28 19:05:47.782235+00'),
	('2883f18a-9861-43c5-945c-6bb36ee270ab', 'uk', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Дорога між домом і гімназією становить щонайменше шість кілометрів?', '2026-08-28 19:05:47.782235+00'),
	('1c94d667-eac4-47fe-8f32-1cfe7ef87014', 'uk', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Чи професійна це діяльність (не аматорська)?', '2026-08-28 19:05:47.782235+00'),
	('1a988142-9ab5-4edb-b156-33b099726595', 'uk', 'Är verksamheten professionell?', 'Чи професійна це діяльність?', '2026-08-28 19:05:47.782235+00'),
	('eda711d8-dfd8-451c-bd9b-0bd7d51885f5', 'uk', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Чи належить діяльність до сценічного мистецтва (танець, театр, музичний театр)?', '2026-08-28 19:05:47.782235+00'),
	('1309a04c-32e4-43c7-a6d6-f0697e42ad92', 'uk', 'Är volontärerna mellan 18 och 30 år?', 'Волонтерам від 18 до 30 років?', '2026-08-28 19:05:47.782235+00'),
	('b90ab868-a498-439b-9468-99f9a19c1c42', 'so', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Taageero hawleed loogu talagalay naadiyada isboortiga ee u qabta carruurta iyo dhallinyarada 7–25 jir hawlo uu hoggaamiyo tababare.', '2026-08-28 19:05:47.787236+00'),
	('a2fcb047-ad15-4527-9f27-a2116e57c4d6', 'so', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Kordhin toos ah oo lagu daro gunnada carruurta (barnbidrag) laga bilaabo ilmaha labaad.', '2026-08-28 19:05:47.787236+00'),
	('be0cda84-e4f7-4453-8296-17af62c56aea', 'so', 'Avser ansökan en fysisk investering?', 'Codsigu ma khuseeyaa maalgelin muuqata (dhisme ama qalab)?', '2026-08-28 19:05:47.787236+00'),
	('e6370471-f4aa-44fc-9a6a-919d3e6d5255', 'so', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Codsigu ma khuseeyaa safar ama isweydaarsi caalami ah?', '2026-08-28 19:05:47.787236+00'),
	('609e5a53-10f7-4f9a-b5d4-0bb9d938406c', 'so', 'Avser ansökan en investering i byggnader eller maskiner?', 'Codsigu ma khuseeyaa maalgelin lagu sameynayo dhismayaal ama mashiinno?', '2026-08-28 19:05:47.787236+00'),
	('81d71bf0-503b-4039-b9a9-ae0dfaa84d4f', 'so', 'Avser ansökan en redan utgiven titel?', 'Codsigu ma khuseeyaa buug horeba loo daabacay?', '2026-08-28 19:05:47.787236+00'),
	('5f8302c5-f708-426e-9892-54be5e5aa6a3', 'so', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Codsigu ma khuseeyaa ganacsi beeraley ah, beero-korin ama xoolo-dhaqato deero-woqooyi?', '2026-08-28 19:05:47.787236+00'),
	('f6b8f76c-b199-4a62-bcb2-c508c037ba85', 'so', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Codsigu ma khuseeyaa buugaag loo iibinayo maktabadaha dadweynaha ama kuwa dugsiyada?', '2026-08-28 19:05:47.787236+00'),
	('844a65ad-7051-44f1-a8f4-90b45f52d750', 'so', 'Avser investeringen jordbruksverksamhet?', 'Maalgelintu ma khuseysaa hawl beeraley ah?', '2026-08-28 19:05:47.787236+00'),
	('eb473770-92f9-4780-8a28-0fb2f4028473', 'so', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Mashruucu ma yahay dhisid, iibsi ama dayactir goob?', '2026-08-28 19:05:47.787236+00'),
	('41ed8252-22aa-4e0a-a106-83740c936a92', 'so', 'Avser projektet naturvård eller friluftsliv?', 'Mashruucu ma khuseeyaa ilaalinta dabeecadda ama madadaalada banaanka?', '2026-08-28 19:05:47.787236+00'),
	('e8107fd7-66fe-4ca7-88d5-7e2dd62320fb', 'so', 'Avser projektet skola eller vuxenutbildning?', 'Mashruucu ma khuseeyaa dugsi ama waxbarashada dadka waaweyn?', '2026-08-28 19:05:47.787236+00'),
	('bd168ede-dbd3-4925-8e42-89878af5a570', 'so', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Ma ka fadhiisanaysaa shaqada si aad u daryeesho ama ugu dhowaato qof kuu dhow oo aad u xanuunsan, oo cudurkiisu nolosha khatar ku yahay?', '2026-08-28 19:05:47.787236+00'),
	('9e0bf3d7-a6f2-4356-a000-8db07687e84a', 'so', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Ururku ma ku leeyahay hawlo joogto ah degmada?', '2026-08-28 19:05:47.787236+00'),
	('028b3c18-85b4-43a5-bd16-435fb533f85e', 'so', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Ma qiimeynaysaa in awooddaada shaqo ay hoos u dhacday ugu yaraan hal sano cudur ama naafanimo dartood?', '2026-08-28 19:05:47.787236+00');
INSERT INTO public.kb_translations VALUES
	('94e4c3e6-ab1e-403b-ba2e-a1ace1f1e286', 'so', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Taageero baahi lagu qiimeeyo oo loogu talagalay qofka haysta hawlgab yar ama aan haysan, una baahan caawimo si uu u gaadho heer nololeed macquul ah.', '2026-08-28 19:05:47.787236+00'),
	('b2549f69-d5a8-4620-bc58-fcd59716b451', 'so', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Ilmuhu ma u baahan yahay inuu dego magaalada uu wax ku barto (hoy) sababtoo ah waddadu aad bay u dheer tahay?', '2026-08-28 19:05:47.787236+00'),
	('cdeaa10a-9203-48ec-a967-6fe5d70db679', 'so', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Gurigu ma u baahan yahay in la habeeyo (tus. jaranjaro-fudud, albaab-fure, musqul)?', '2026-08-28 19:05:47.787236+00'),
	('77a70ed1-1d3e-48d4-b40e-97c3a3482149', 'so', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Mid ka mid ah carruurtaada 8–19 jirka ah ma u baahan yahay muraayado indho ama lenso?', '2026-08-28 19:05:47.787236+00'),
	('3db6650a-b3cd-464c-b74f-15ecbb23208f', 'so', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Waalidka kale miyuusan waxba bixin, mise wuxuu bixiyaa wax ka yar masruufka buuxa?', '2026-08-28 19:05:47.787236+00'),
	('00900606-544c-4ad5-abdf-c410144fe94f', 'so', 'Betalar du hyra eller andra boendekostnader?', 'Ma bixisaa kiro ama kharashyo kale oo guri?', '2026-08-28 19:05:47.787236+00'),
	('8ea2b7e1-3094-4f05-96ef-27aeafe6c2c9', 'so', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Gunno lagu habeeyo guriga marka naafanimo jirto — tus. jaranjarooyin fudud, albaab-fureyaal ama habeyn musqusha.', '2026-08-28 19:05:47.787236+00'),
	('1e543feb-8964-432f-97a3-c560ab04726a', 'so', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Gunnooyin lagu dhiso, lagu iibsado ama lagu dayactiro hoolal shir oo dadweyne.', '2026-08-28 19:05:47.787236+00'),
	('063ccde2-da87-4c2a-96e0-9aaf3c221742', 'so', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Gunno lagu iibsado ama lagu habeeyo baabuur marka naafanimo joogto ahi ay aad u adkeyso dhaqdhaqaaqa ama safarka gaadiidka dadweynaha.', '2026-08-28 19:05:47.787236+00'),
	('c5302435-421f-4416-b511-423227fbb14f', 'so', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Gunnooyin safarro iyo isweydaarsiyo caalami ah oo loogu talagalay xirfadlayaasha dhinaca dhaqanka.', '2026-08-28 19:05:47.787236+00'),
	('5b549906-bc5d-4da1-b810-6d48564cfcbd', 'so', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Gunnooyin isweydaarsiyada caalamiga ah, safarrada iyo joogitaannada shaqo ee fannaaniinta xirfadleyda ah.', '2026-08-28 19:05:47.787236+00'),
	('2b597238-5469-404f-99dc-63d4f344c115', 'so', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Gunno iyo deyn ikhtiyaari ah oo loogu talagalay waxbarashada heerka dugsiga sare ama ka dambeeya.', '2026-08-28 19:05:47.787236+00'),
	('0675b4bb-2b94-4a15-b09e-69ac3afb281c', 'so', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Gunnooyin iyo deymo waxbarasho dibadda ah, oo leh deymo dheeraad ah tus. lacagta waxbarashada iyo safarrada.', '2026-08-28 19:05:47.787236+00'),
	('d3977b07-5afb-4288-8385-568fe6226e56', 'so', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Gunno ka caawisa jihooyinka Swedishka inay diyaariyaan codsiyada barnaamijyada EU sida Horisont Europa.', '2026-08-28 19:05:47.787236+00'),
	('1fe92356-501f-4770-b1f1-53f522cb5644', 'so', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Gunno loo fidiyo loo-shaqeeyayaasha shaqaaleysiiya dadka awoodda shaqo ee hooseysa.', '2026-08-28 19:05:47.787236+00'),
	('41e47c0c-24ea-475b-b117-18d3b21d63af', 'so', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Gunno hoy iyo safarro guri-ku-noqosho ah marka arday dugsi sare uu qasab ku noqdo inuu dego magaalada waxbarashada waddo dheer awgeed.', '2026-08-28 19:05:47.787236+00'),
	('14891946-70cc-4b05-9fac-c61438fb1bd8', 'so', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Gunnooyin shaqada ururrada aan faa''iido doonka ahayn ee ilaalinta, isticmaalka iyo horumarinta hidaha dhaqanka.', '2026-08-28 19:05:47.787236+00'),
	('c836a538-4701-4441-a5c9-adef4d085103', 'so', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Gunnooyin mashaariicda degmooyinka iyo kuwa maxalliga ah ee ilaalinta dabeecadda, oo ay ku jiraan dhulalka qoyan iyo madadaalada banaanka.', '2026-08-28 19:05:47.787236+00'),
	('9cf38446-2a93-42d9-965a-f84520aeb86d', 'so', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Gunnooyin degmooyinka loogu talagalay iibsiga buugaagta maktabadaha dadweynaha iyo kuwa dugsiyada.', '2026-08-28 19:05:47.787236+00'),
	('6610dd90-d992-41d2-bd20-72e356e6ed1c', 'so', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Gunnooyin masuuliyiinta dugsiyada si ardayda dugsiga hoose-dhexe ay ula kulmaan dhaqan xirfadle.', '2026-08-28 19:05:47.787236+00'),
	('2c0a8107-d337-4499-89e0-6524ce287fcd', 'so', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Gunno waxa ilmahaagu u baahan yahay laakiin dhaqaalaha qoysku uusan gaadhin: hawlo firaaqo, dhar, socdaallo dugsi, muraayado indho, hawlo fasax iyo wax kale.', '2026-08-28 19:05:47.787236+00'),
	('acdfc2fe-ccdc-4707-acee-5c356c596d72', 'so', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Gunnooyin ka yimaadda sanduuqyada sida Världens Barn, Musikhjälpen iyo Victoriafonden — waxaa codsada ururrada Swedishka ee aan faa''iido doonka ahayn ee haysta 90-konto.', '2026-08-28 19:05:47.787236+00'),
	('79bf284d-6dd5-4d8f-8ac0-080f1f2788a3', 'so', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Gunnooyin ka yimaadda lacagaha korontada biyaha iyo dabaysha oo loogu talagalay mashaariic horumarisa deegaanka.', '2026-08-28 19:05:47.787236+00'),
	('10964815-0092-4f6b-96f7-c1edd5c7c849', 'so', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Gunno aan lahayn qayb deyn ah oo loogu talagalay shaqo-la''aanta 25–60 jirka ah ee waxbarashadoodu gaaban tahay, una baahan inay wax ku bartaan heerka dugsiga hoose-dhexe ama sare.', '2026-08-28 19:05:47.787236+00'),
	('7c0ac75a-f6f6-4660-a9d3-c6c65b172249', 'so', 'Bidrar projektet till energiomställningen?', 'Mashruucu ma gacan ka geystaa isbeddelka tamarta?', '2026-08-28 19:05:47.787236+00'),
	('77051bbd-6f18-4eaa-8023-1abd62ea546a', 'so', 'Bor du och barnets andra förälder på skilda håll?', 'Adiga iyo waalidka kale ee ilmuhu ma kala nooshihiin?', '2026-08-28 19:05:47.787236+00'),
	('84e7d1e2-7ec5-4ca2-9d70-f377cbab7a62', 'so', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Jeegag shirkado yaryar si ay u keensadaan aqoon dibadeed oo caalamiyeyn ama dhijitaaleyn ah.', '2026-08-28 19:05:47.787236+00'),
	('b502398b-a799-496f-a4fb-6e40708e43bf', 'so', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Ma ka qaybqaadataa barnaamij ka socda Arbetsförmedlingen (tus. jobb- och utvecklingsgarantin)?', '2026-08-28 19:05:47.787236+00'),
	('252aa584-7fdd-4340-ac34-53e59d67a5b9', 'so', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Taageero dib-u-dhac ah oo loo fidiyo daabacayaasha soo saara suugaan tayo leh.', '2026-08-28 19:05:47.787236+00'),
	('f8ec8e1e-0a34-4d2d-9fd5-afa92a29482f', 'so', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Taageero dhaqaale oo loogu talagalay qofka haysta sharci degganaansho oo magangelyo la xiriira, oo si mutadawacnimo ah u doonaya inuu si joogto ah ugu laabto dalkiisii asalka ahaa.', '2026-08-28 19:05:47.787236+00'),
	('02917ba7-94ad-4bf5-bb6f-3f74594f5cbe', 'so', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Taageero dhaqaale oo loo fidiyo loo-shaqeeyayaasha shaqaaleysiiya qof muddo dheer ka maqnaa nolosha shaqada.', '2026-08-28 19:05:47.787236+00'),
	('2f03496b-6da7-44eb-b134-8f395d550f46', 'so', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Taageero dhaqaale inta lagu jiro bilowga, oo loogu talagalay shaqo-doonka bilaabaya ganacsigooda.', '2026-08-28 19:05:47.787236+00'),
	('09ddc78c-06a9-4977-a808-b0300f0f6c66', 'so', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten waxay si joogto ah u furtaa baaqyo cilmi-baarista tamarta, hal-abuurka iyo hufnaanta tamarta.', '2026-08-28 19:05:47.787236+00'),
	('9c741d78-9d38-450f-8aff-fd3bf911693b', 'so', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Magdhow ka-maqnaanshaha shaqada ama waxbarashada si loo daryeelo ilmo.', '2026-08-28 19:05:47.787236+00'),
	('6334c3fd-6715-4f10-8122-34e7913ead35', 'so', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Magdhow qofka ku cusub Sweden oo ka qaybqaata barnaamijka dejinta ee Arbetsförmedlingen; waxaa bixisa Försäkringskassan.', '2026-08-28 19:05:47.787236+00'),
	('2892434e-1cc5-4d49-b02d-04230552e4f0', 'so', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Magdhow daboolaya qayb ka mid ah kharashka guriga ee dhallinyarada aan carruurta lahayn ee dakhligoodu hooseeyo.', '2026-08-28 19:05:47.787236+00'),
	('67e2d04c-2ee6-4fce-b4d6-aa4d76de4d13', 'so', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Magdhow kharashyada dheeraadka ah ee naafanimo joogto ahi keento — dadka waaweyn, ama waalidiinta carruurta naafada ah.', '2026-08-28 19:05:47.787236+00'),
	('ecdc40a1-8626-4afa-ad47-78133fd92f5d', 'so', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Magdhow dhallinyarada (19–29 jir) aan awoodin inay waqti-buuxa u shaqeeyaan ugu yaraan hal sano cudur ama naafanimo dartood.', '2026-08-28 19:05:47.787236+00'),
	('78dbfb5d-4925-4759-8cae-af5561edd5a5', 'so', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Magdhow marka awoodda shaqo si joogto ah hoos ugu dhacday — wixii hore loogu yiqiin förtidspension (hawlgab hore).', '2026-08-28 19:05:47.787236+00'),
	('b5e07414-a901-455c-984d-788cd69eb13e', 'so', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Magdhow marka aad shaqada uga fadhiisato inaad u dhowaato qof kuu dhow oo aad u xanuunsan.', '2026-08-28 19:05:47.787236+00'),
	('97131e6b-7752-4d44-a264-85b5995c6ee8', 'so', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Magdhow marka aad ka qaybqaadato barnaamij suuqa shaqada ee Arbetsförmedlingen.', '2026-08-28 19:05:47.787236+00'),
	('810f07db-ee7f-4570-88d9-1ed8184440ff', 'so', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Magdhow marka aadan sidii caadiga ahayd u shaqeyn karin cudur dartiis.', '2026-08-28 19:05:47.787236+00'),
	('3033cca6-abf3-4dbd-b650-b97ef07d00d5', 'so', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Magdhow marka aad shaqada ka joogto guriga si aad u daryeesho ilmo jirran.', '2026-08-28 19:05:47.787236+00'),
	('da92cbc2-fb32-4926-8a2c-76bf224eed29', 'so', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Magdhow daboolaya qayb ka mid ah kharashka guriga ee qoysaska carruurta leh ee dakhligoodu hooseeyo.', '2026-08-28 19:05:47.787236+00'),
	('452ecf9a-82d7-4ce1-b291-b7a5720f0c22', 'so', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Magdhow waalidiinta ay carruurtoodu naafanimo dartood ugu baahan yihiin daryeel iyo ilaalin ka badan carruurta da''dooda ah.', '2026-08-28 19:05:47.787236+00'),
	('da48b958-576e-4837-8c9c-08a4e880d331', 'so', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Magdhow xilliga shaqo-la''aanta — ku salaysan dakhliga xubnaha, qadar aasaasi ah kuwa kale.', '2026-08-28 19:05:47.787236+00'),
	('ad023578-fd29-43de-a436-00cf4ff6d953', 'so', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Ilaa konton sanduuq oo bangiyada kaydka ah ayaa gunnooyin siiya mashaariic maxalli ah oo isboorti, dhaqan, waxbarasho iyo horumar bulsho — gudaha aagga hawlgalka bangiga.', '2026-08-28 19:05:47.787236+00'),
	('9f0c8ddb-13c7-4d95-a578-9cd1084ce4ab', 'so', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Taageero mashruuc oo EU maalgeliso oo laga codsado aaggaaga Leader ee maxalliga ah — ururrada, shirkadaha iyo degmooyinka horumarinaya miyiga.', '2026-08-28 19:05:47.787236+00'),
	('88086942-414a-498d-9070-91024b51107d', 'so', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Taageero EU maalgeliso oo loogu talagalay shaqo-doonka qaadanaya shaqo dal kale oo EU/EES ah: magdhow safarka wareysiga, kharashka guuritaanka iyo koorso luqadeed.', '2026-08-28 19:05:47.787236+00'),
	('ca679d5b-22d8-41ad-8a0c-55a38e31d27e', 'so', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Lacago ka yimaadda sanduuqa bulshada ee EU oo loogu talagalay mashaariic xoojiya aqoonta, u-gudubka iyo ka-mid-noqoshada suuqa shaqada.', '2026-08-28 19:05:47.787236+00');
INSERT INTO public.kb_translations VALUES
	('27201168-0c79-45cd-a9b3-cbf3c5de8b2c', 'so', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Taageero EU oo loogu talagalay isweydaarsiyo kooxeed dhallinyarada 13–30 jir, 5–21 maalmood oo aan lagu darin maalmaha safarka.', '2026-08-28 19:05:47.787236+00'),
	('7c871100-41bf-4084-ade7-658f009d8770', 'so', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Taageero EU oo loogu talagalay mashaariicda iskaashiga ururrada dhaqanka ee la leh shuraakada dhowr dal oo Yurub ah.', '2026-08-28 19:05:47.787236+00'),
	('044a9549-8b42-41de-9bd4-58aec15e3666', 'so', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Taageero EU oo loogu talagalay ururrada soo dhoweeya ama dira mutadawiciin dhallinyaro ah oo 18–30 jir ah.', '2026-08-28 19:05:47.787236+00'),
	('62c7eaca-4631-4a4e-b437-cdddbc89188b', 'so', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Taageero EU oo loogu talagalay dhaqdhaqaaqa shaqaalaha iyo ardayda dugsiga iyo waxbarashada dadka waaweyn.', '2026-08-28 19:05:47.787236+00'),
	('5602ea7b-c9c4-48c6-b658-b94bca845ef9', 'so', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Taageero EU oo leh qaddaro go''an oo loogu talagalay mashaariicda iskaashiga Yurub ee ugu horreeya ee ururrada yaryar.', '2026-08-28 19:05:47.787236+00'),
	('eaf3373f-2f40-43a3-a4cb-ffb420c06f86', 'so', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Maalgelin shirkado da''yar oo horumarinaya alaabo ama adeegyo hal-abuur leh oo awood caalami leh.', '2026-08-28 19:05:47.787236+00'),
	('c30f9d87-1e62-4bd2-b04d-909aa408d478', 'so', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Ma jiraa bangi kayd (sidaas darteedna sanduuq bangi-kayd) meesha aad ka hawlgashaan?', '2026-08-28 19:05:47.787236+00'),
	('d24173d2-a6fa-4d0d-b740-c5e6262973ac', 'so', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Gunnooyin hawlgal oo dhowr sano ah oo loogu talagalay kooxaha madaxbannaan ee xirfadleyda ah ee qoob-ka-ciyaarka, masraxa iyo masraxa muusiga.', '2026-08-28 19:05:47.787236+00'),
	('b22b55ee-76d4-4f68-8d3f-4cb34fcf9564', 'so', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Gunnooyin cilmi-baaris oo ku saabsan aagagga Forte: caafimaadka, nolosha shaqada iyo barwaaqada. Waxaa codsada cilmi-baarayaal shahaadada dhoktoorada haysta oo jaamacadaha Sweden jooga.', '2026-08-28 19:05:47.787236+00'),
	('bc971d37-bfc6-4ece-b414-98b1b39a0352', 'so', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Maalgelin cilmi-baaris oo loogu talagalay baaritaan aasaasi ah oo xor ah dhammaan qaybaha sayniska.', '2026-08-28 19:05:47.787236+00'),
	('57b89637-76f1-4169-95ec-d57ffd5c19f9', 'so', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Maalgelin cilmi-baaris oo ku saabsan deegaanka, cilmiga beeraha iyo qorshaynta magaalooyinka.', '2026-08-28 19:05:47.787236+00'),
	('9bba9bd3-dcab-466c-978b-2ce344ca4f34', 'so', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Ma ka fekereysaa inaad dibadda u guurto (shaqo, waxbarasho ama dib-u-laabasho)?', '2026-08-28 19:05:47.787236+00'),
	('4c5bdc54-c631-415a-9116-c44d7c1d171d', 'so', 'Genomförs insatserna av professionella kulturaktörer?', 'Hawlaha ma fuliyaan jilayaal dhaqameed xirfadle ah?', '2026-08-28 19:05:47.787236+00'),
	('8b604232-49c1-4bdf-bf87-980e2ae5bc7e', 'so', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Mashruuca ma laga fuliyaa miyiga ama tuulo yar?', '2026-08-28 19:05:47.787236+00'),
	('be0edcd5-9ea2-4ffe-922c-fbd113048dc3', 'so', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Ilaalin aasaasi ah oo loogu talagalay qofka noloshiisa oo dhan dakhli shaqo yar ama aan lahayn.', '2026-08-28 19:05:47.787236+00'),
	('1b4c9bd2-2586-4e4a-b032-78e8da04f882', 'so', 'Går något av dina barn i grundskolan?', 'Mid ka mid ah carruurtaadu ma dhigtaa dugsiga hoose-dhexe?', '2026-08-28 19:05:47.787236+00'),
	('1a31b32c-5d2f-4ee3-b0f9-045ae3db2cb9', 'so', 'Går något av dina barn på gymnasiet?', 'Mid ka mid ah carruurtaadu ma dhigtaa dugsiga sare?', '2026-08-28 19:05:47.787236+00'),
	('d0635015-c0de-4247-9884-cb3beb80b095', 'so', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Shaqaaleysiintu ma khuseysaa qof awooddiisa shaqo hoos u dhacday?', '2026-08-28 19:05:47.787236+00'),
	('c3c9873c-1e06-4a13-b5ea-c2e089bdc720', 'so', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Shaqaaleysiintu ma khuseysaa qof muddo dheer shaqo la''aan ahaa ama ku cusub Sweden?', '2026-08-28 19:05:47.787236+00'),
	('9d9a2c42-024a-4030-8e63-99203d2a197f', 'so', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Mashruucu ma ku saabsan yahay ilaalinta hidaha dhaqanka ama helitaankiisa?', '2026-08-28 19:05:47.787236+00'),
	('69479f45-8e9d-4fd4-b04f-cb89a90b6feb', 'so', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Mashruucu ma ku saabsan yahay tamar, hufnaan tamar ama hal-abuur tamar la xiriira?', '2026-08-28 19:05:47.787236+00'),
	('663ab4f8-1907-421b-949c-4fb4df6e62ca', 'so', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Mashruucu ma ku saabsan yahay caafimaad, nolol shaqo ama barwaaqo?', '2026-08-28 19:05:47.787236+00'),
	('f99f00ed-a7f7-44f5-af75-46b15cc94c6d', 'so', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Mashruucu ma ku saabsan yahay horumarinta aqoonta ama tallaabooyinka suuqa shaqada?', '2026-08-28 19:05:47.787236+00'),
	('e8b5a78e-cbd8-4615-84db-a8314c91fa77', 'so', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Mashruucu ma ku saabsan yahay tallaabooyin deegaan ama cimilo?', '2026-08-28 19:05:47.787236+00'),
	('c1a828cf-0c0f-4015-97c0-1293de694ab4', 'so', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Ilmuhu ma leeyahay waddo dugsi oo dheer, khatar gaadiid leh ama si kale u adag?', '2026-08-28 19:05:47.787236+00'),
	('b2a0ff70-59d9-4678-bfac-db75fdba307a', 'so', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Ma shaqeysay ugu yaraan 16 saacadood asbuucii, wadar ahaan ugu yaraan 8 sano?', '2026-08-28 19:05:47.787236+00'),
	('efdb3f76-6764-4d17-9d55-c02aa392b565', 'so', 'Har du barn som bor hos dig, helt eller växelvis?', 'Ma leedahay carruur kula nool, si buuxda ama si kala duwan?', '2026-08-28 19:05:47.787236+00'),
	('fd9e0b7c-0687-4a3a-8383-a6fb96b2e3ff', 'so', 'Har du barn som bor hos dig?', 'Ma leedahay carruur kula nool?', '2026-08-28 19:05:47.787236+00'),
	('ba6024ee-9708-44b2-9697-8a8b30fa225f', 'so', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Adiga ama ilmahaagu ma leedihiin naafanimo la filayo inay socoto ugu yaraan hal sano?', '2026-08-28 19:05:47.787236+00'),
	('88e9c639-7e61-4697-a853-5a5f99eee8a8', 'so', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Adiga ama qof qoyska ka mid ahi ma leeyahay naafanimo joogto ah oo saameysa guriga?', '2026-08-28 19:05:47.787236+00'),
	('714cf916-f187-4406-b576-85a83f5d5e6c', 'so', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Adiga ama qaraabo kuu dhow ma leedihiin naafanimo ama cudur muddo dheer socda ama daran?', '2026-08-28 19:05:47.787236+00'),
	('dfc5fc93-4048-4acd-9bad-4ed53d087958', 'so', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Ma qabtaa cudur ama dhaawac hadda hoos u dhigaya awooddaada shaqo?', '2026-08-28 19:05:47.787236+00'),
	('aa904426-7019-440c-9310-0356c339ccfd', 'so', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Weligaa ma kugu adkaatay inaad bixiso socdaal dugsi, safar fasal ama hawl firaaqo oo ilmahaaga laga filayo inuu ka qaybqaato?', '2026-08-28 19:05:47.787236+00'),
	('e2380672-8c1f-440c-8c2b-c89522e514d3', 'so', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Ma kugu adag tahay inaad ku noolaato hawlgabkaaga iyo dakhligaaga kale?', '2026-08-28 19:05:47.787236+00'),
	('e598a827-90a0-463a-a29b-131535ff1710', 'so', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Sannadihii u dambeeyay ma heshay sharci degganaansho Sweden, tus. qof magangelyo u baahan ama xubin qoys ahaan?', '2026-08-28 19:05:47.787236+00'),
	('a30266c8-7bbc-4f8c-a24b-0686bdd8416d', 'so', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Ma haysataa sharci degganaansho Sweden qaxooti ahaan ama qof magangelyo u baahan (mise waxaad tahay qaraabo u dhow qof haysta)?', '2026-08-28 19:05:47.787236+00'),
	('8811797d-2315-4178-ab3f-800d66301975', 'so', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Ma gaadhay da''da tixraaca hawlgabka (67 sano 2026)?', '2026-08-28 19:05:47.787236+00'),
	('43a268be-ae16-41f6-9b95-7b0657d1288a', 'so', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Ururkiinnu ma leeyahay OID (Organisation ID) oo ka diiwaangashan Organisation Registration System ee EU?', '2026-08-28 19:05:47.787236+00'),
	('24b1e466-a727-4852-bfe6-aa3d8c5cbe0b', 'so', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Naafanimadu ma keentay kharashyo dheeraad ah — tus. qalab caawiye, safarro, cunto gaar ah ama duugoobid?', '2026-08-28 19:05:47.787236+00'),
	('94f445a5-1436-4fe1-9cbc-c1e76bd7b916', 'so', 'Har föreningen antagna stadgar och en vald styrelse?', 'Ururku ma leeyahay xeerar la ansixiyay iyo guddi la doortay?', '2026-08-28 19:05:47.787236+00'),
	('ffa0cf19-f124-410f-a181-52ca6f358975', 'so', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Ururku ma leeyahay qaab-dhismeed dimoqraadi ah (xeerar, shir sannadeed, guddi)?', '2026-08-28 19:05:47.787236+00'),
	('8ac0e64f-85e9-4dfe-9d9b-e63a6a55da84', 'so', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Ururku ma u qabtaa hawlo joogto ah carruurta ama dhallinyarada?', '2026-08-28 19:05:47.787236+00'),
	('b4b2c789-4db2-44e6-a4e4-5514c9f105c1', 'so', 'Har företaget mellan cirka 2 och 49 anställda?', 'Shirkaddu ma leedahay inta u dhaxaysa qiyaastii 2 iyo 49 shaqaale?', '2026-08-28 19:05:47.787236+00'),
	('3cfe2965-7284-44cf-9ab0-bac47e5472c2', 'so', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Qoysku ma ku dhibtoodaa daboolidda kharashka cuntada, guriga iyo waxyaabaha ugu muhiimsan?', '2026-08-28 19:05:47.787236+00'),
	('a591c836-780d-44b0-a64d-cfa88b5d171f', 'so', 'Har lösningen internationell potential?', 'Xalku ma leeyahay awood caalami ah?', '2026-08-28 19:05:47.787236+00'),
	('5d5362e5-3ef6-44bb-95c0-7e508a7ef9cf', 'so', 'Har ni en partnergrupp i ett annat land?', 'Ma leedihiin koox shuraako ah dal kale?', '2026-08-28 19:05:47.787236+00'),
	('6c3946b9-4412-48dc-90f0-9e8ce14cfc1c', 'so', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Ma leedihiin urur shuraako ah dal kale oo Yurub ah?', '2026-08-28 19:05:47.787236+00'),
	('1fdda346-434b-4ef7-94b8-fe5a4129c6ac', 'so', 'Har ni partner i minst tre olika europeiska länder?', 'Ma ku leedihiin shuraako ugu yaraan saddex dal oo Yurub ah oo kala duwan?', '2026-08-28 19:05:47.787236+00'),
	('fe5cefa8-79ed-49ff-80ec-d476c535d973', 'so', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Xaruntiinnu ama hawshiinna ugu weyni ma ku taal gobolka aad ka codsanaysaan?', '2026-08-28 19:05:47.787236+00'),
	('16c65d49-160f-4d3e-ba72-34ec3ca461f7', 'so', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Mid ka mid ah carruurtaadu ma leeyahay naafanimo ka dhigaysa inuu u baahdo daryeel ama ilaalin ka badan carruurta kale ee da''diisa ah?', '2026-08-28 19:05:47.787236+00');
INSERT INTO public.kb_translations VALUES
	('8d43239d-26fa-4ce9-b026-382bef2515c1', 'so', 'Har organisationen en demokratisk uppbyggnad?', 'Ururku ma leeyahay qaab-dhismeed dimoqraadi ah?', '2026-08-28 19:05:47.787236+00'),
	('25c5943a-0f27-4b08-a167-7b4526c71e0f', 'so', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Ururku ma leeyahay Quality Label (calaamad tayo)?', '2026-08-28 19:05:47.787236+00'),
	('0d797a7d-82ce-4cdb-a265-28a9dcadfe36', 'so', 'Har organisationen ett 90-konto?', 'Ururku ma leeyahay 90-konto?', '2026-08-28 19:05:47.787236+00'),
	('050df43e-05c4-48f3-8848-96004d08decc', 'so', 'Har organisationen ett OID (Organisation ID)?', 'Ururku ma leeyahay OID (Organisation ID)?', '2026-08-28 19:05:47.787236+00'),
	('707a6a16-cc6c-4a19-a6fc-1080f5ff6322', 'so', 'Har organisationen ett OID?', 'Ururku ma leeyahay OID?', '2026-08-28 19:05:47.787236+00'),
	('9bc2cffe-ef6c-4073-9717-781ed3d602ee', 'so', 'Har organisationen medlemsföreningar i flera län?', 'Ururku ma ku leeyahay ururro xubno ah dhowr gobol?', '2026-08-28 19:05:47.787236+00'),
	('00977ab4-04fb-42ec-8205-441f82bb18b5', 'so', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Ururku ma leeyahay dhaqaale nidaamsan iyo qaab-dhismeed dimoqraadi ah?', '2026-08-28 19:05:47.787236+00'),
	('8f5f11e1-8bfb-494e-a434-99388169b547', 'so', 'Har projektet en partner i ett annat land?', 'Mashruucu ma leeyahay shuraako dal kale?', '2026-08-28 19:05:47.787236+00'),
	('84033934-f08a-4566-8417-ba21bdd151e6', 'so', 'Har projektledaren doktorsexamen?', 'Hoggaamiyaha mashruucu ma haystaa shahaadada dhoktoorada?', '2026-08-28 19:05:47.787236+00'),
	('887bfe9a-a595-4835-b75e-1d5313728f03', 'so', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Degmada aad degan tahay waa inay bixiso safarrada maalinlaha ah ee u dhexeeya guriga iyo dugsiga sare marka waddadu tahay ugu yaraan lix kiilomitir (tus. kaadhka baska).', '2026-08-28 19:05:47.787236+00'),
	('75b99642-b442-441a-b8c9-a3d0865e49a2', 'so', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Ma ku guda jirtaa helidda ama qalabaynta gurigaaga ugu horreeya ee Sweden?', '2026-08-28 19:05:47.787236+00'),
	('b3b0325a-08a4-43ae-bd07-886e722cef9c', 'so', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Mashruucu ma ku jiraa safar ama isweydaarsi caalami ah?', '2026-08-28 19:05:47.787236+00'),
	('c5452e2b-4aa6-43c5-a2d3-fde497b2ec7b', 'so', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Taageero maalgelin oo loogu talagalay shirkadaha aagagga taageerada — dhismayaal, mashiinno iyo tababar.', '2026-08-28 19:05:47.787236+00'),
	('ca9d889f-ea79-4a32-bcb9-3c3fa0069c54', 'so', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Taageero maalgelin oo loogu talagalay tallaabooyin yareeya qiiqa gaaska lab-guriyeed.', '2026-08-28 19:05:47.787236+00'),
	('e1cd537b-0bc0-4b0e-868b-58d68c4e428f', 'so', 'Kan projektets miljönytta mätas?', 'Faa''iidada deegaanka ee mashruuca ma la cabbiri karaa?', '2026-08-28 19:05:47.787236+00'),
	('2f4767b6-ab05-4004-bd34-25dbcc557c0b', 'so', 'Kan åtgärdens utsläppsminskning beräknas?', 'Yaraynta qiiqa ee tallaabada ma la xisaabin karaa?', '2026-08-28 19:05:47.787236+00'),
	('28f60f7b-5e38-4768-a0c7-19fdec1309f7', 'so', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Ururku ma awoodaa inuu qaado kharashyada ilaa taageerada la bixiyo?', '2026-08-28 19:05:47.787236+00'),
	('6f677269-af10-49e5-b7fc-67638c563819', 'so', 'Är minst 60 % av medlemmarna under 26 år?', 'Ugu yaraan 60 % xubnuhu ma ka yar yihiin 26 jir?', '2026-08-28 19:05:47.790984+00'),
	('f049eba6-188c-4af4-b85d-ab62f3d6efbc', 'so', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Maalgelintu ma bilaabmaysaa kaliya kadib markaad codsiga dirto?', '2026-08-28 19:05:47.787236+00'),
	('e3de2ddb-6880-40fc-9e19-43b1ddb459b6', 'so', 'Kommer projektet människor i ert närområde till del?', 'Mashruucu ma anfacaa dadka deegaankiinna?', '2026-08-28 19:05:47.787236+00'),
	('d204f4a0-1b3b-4f3c-95bd-415e65aed4ae', 'so', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Shabakadda badbaadada dhaqaale ee ugu dambeysa ee degmada marka dakhligu uusan gaadhin waxyaabaha ugu muhiimsan.', '2026-08-28 19:05:47.787236+00'),
	('ff8642f4-f864-4948-bd45-240733fece73', 'so', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Taageerooyinka gaarka ah ee degmooyinka ee ururrada maxalliga ah: taageero hawleed goob kasta, gunno goob, gunno bilow iyo wax kale.', '2026-08-28 19:05:47.787236+00'),
	('73b29e7d-ce95-4045-a9f7-f391e09e8ebd', 'so', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Gaadiid dugsi oo bilaash ah oo loogu talagalay ardayda dugsiga hoose-dhexe marka masaafadu dheer tahay, waddadu khatar tahay ama naafanimo jirto — xaq sida uu dhigayo sharciga dugsiyada.', '2026-08-28 19:05:47.787236+00'),
	('760ccd2c-8985-4db8-9631-603867d7a514', 'so', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Gunno sharci ah oo muraayado indho ama lenso ah oo loogu talagalay carruurta iyo dhallinyarada; qaddarka iyo habraacu way ku kala duwan yihiin gobolka — hubi heerka gobolkaaga.', '2026-08-28 19:05:47.787236+00'),
	('5708d37d-2409-47e4-a8b0-851f7437f88e', 'so', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Mashruucu ma ku yaal deegaan ay khusayso korontada biyaha ama dabayshu?', '2026-08-28 19:05:47.787236+00'),
	('019d96ec-37b3-43e5-894f-40a2adeb4bc4', 'so', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Mashruucu ma ku jiraa deegaanka, cilmiga beeraha ama qorshaynta magaalooyinka?', '2026-08-28 19:05:47.787236+00'),
	('83c58432-ee13-41d4-9dc8-2b0cff6e0889', 'so', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Goobta hawshu ma ku taal aagga taageerada A ama B (qaybo badan oo Norrland iyo Svealand gudaha ah)?', '2026-08-28 19:05:47.787236+00'),
	('11b605ca-d52f-41f8-a940-41cb5d3e0918', 'so', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Deyn lagu iibsado waxyaabaha ugu muhiimsan ee guriga ugu horreeya ee Sweden — fadhi, qalab guri iyo qalab kale oo aasaasi ah.', '2026-08-28 19:05:47.787236+00'),
	('dff6ca7b-6cda-43a5-8cb7-e4a90bbf22c9', 'so', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Mashruucu ma yareeyaa qiiqa hawlaha warshadaha mise wuxuu abuuraa qiiq taban?', '2026-08-28 19:05:47.787236+00'),
	('ec0d3c0d-d69a-4a81-b289-d150a25d59ba', 'so', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Gunno bille ah oo loogu talagalay carruurta Sweden ku nool, dhalashada ilaa 16 jir.', '2026-08-28 19:05:47.787236+00'),
	('131abb77-4e9c-43bc-858f-60c51fc7862c', 'so', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket waxay gunnooyin siisaa ururro, shirkado, jameecooyin, qaybta dadweynaha iyo shakhsiyaad dhinaca deegaanka.', '2026-08-28 19:05:47.787236+00'),
	('ffde53ea-dbf3-475a-9d0c-d6d4c3c2d57a', 'so', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Ma qorsheyneysaa inaad si mutadawacnimo ah oo joogto ah ugu laabato dalkaagii asalka ahaa?', '2026-08-28 19:05:47.787236+00'),
	('68d5d374-f4e0-4346-862b-30bd855e19da', 'so', 'Planerar du att starta eget företag?', 'Ma qorsheyneysaa inaad bilowdo ganacsi adiga kuu gaar ah?', '2026-08-28 19:05:47.787236+00'),
	('6ea841ee-361b-4c46-b054-27d95e52b79f', 'so', 'Planerar du att studera utomlands?', 'Ma qorsheyneysaa inaad dibadda wax ku barato?', '2026-08-28 19:05:47.787236+00'),
	('fde933d9-3e65-4a9d-a39f-ab319fb83bca', 'so', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Ma qorsheyneysaa waxbarasho xoojisa meeshaad ka taagan tahay suuqa shaqada?', '2026-08-28 19:05:47.787236+00'),
	('5c3a280b-ddfd-488a-b0fd-617ed88f5c05', 'so', 'Planerar ni att anställa?', 'Ma qorsheyneysaan inaad shaqaaleysiisaan?', '2026-08-28 19:05:47.787236+00'),
	('3278c129-fd92-4996-8d5b-049f3086b5e9', 'so', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Ma qorsheyneysaan inaad codsataan barnaamij EU (tus. Horisont Europa)?', '2026-08-28 19:05:47.787236+00'),
	('0c07fcda-fa80-4880-b749-259cc508dbb4', 'so', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Taageero soo-saarid iyo horumarin oo loogu talagalay filimo gaagaaban iyo dokumentari.', '2026-08-28 19:05:47.787236+00'),
	('720ebf80-e23d-4452-877a-4b04fae862bc', 'so', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Gunnooyin mashruuc oo loogu talagalay goobta muusiga ee madaxbannaan: riwaayado, soo-saarid iyo horumarin.', '2026-08-28 19:05:47.787236+00'),
	('d7f53588-c4ab-4cdb-8f79-5434016e0988', 'so', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Gunnooyin mashruuc oo loogu talagalay ururrada aan faa''iido doonka ahayn ee la shaqeeya carruurta iyo dhallinyarada, unana shaqeeya iyaga.', '2026-08-28 19:05:47.787236+00'),
	('5324ba0e-7240-4331-b485-2006df4bb04b', 'so', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Mashruucu ma tijaabiyaa muujinno, habab ama iskaashiyo faneed oo cusub?', '2026-08-28 19:05:47.787236+00'),
	('ea2da93a-f698-41d7-b718-0cfd530d4652', 'so', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Isweydaarsigu ma socdaa 5–21 maalmood (aan lagu darin maalmaha safarka)?', '2026-08-28 19:05:47.787236+00'),
	('ec1fef6c-6f66-4a97-a196-9ea35a9d7ec4', 'so', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Taageerooyinka gaarka ah ee gobollada ee mashaariicda iyo hawlaha dhaqanka, oo ka baxsan gunnooyinka qaranka ee Kulturrådet.', '2026-08-28 19:05:47.787236+00'),
	('fec706a3-c93f-4cb4-838e-97ff1e9d6bf7', 'so', 'Riktar sig projektet till barn eller unga?', 'Mashruucu ma u jiheysan yahay carruurta ama dhallinyarada?', '2026-08-28 19:05:47.787236+00'),
	('cf3caefc-f995-4c98-b07f-531d7e715361', 'so', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Mashruucu ma u jiheysan yahay carruurta, dhallinyarada, waayeelka ama dadka naafada ah?', '2026-08-28 19:05:47.787236+00'),
	('45eccb42-8988-4d59-aa2a-cfe06f235a21', 'so', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Hawshu ma u jiheysan tahay carruurta iyo dhallinyarada (7–25 jir)?', '2026-08-28 19:05:47.787236+00'),
	('d39b10d2-2007-4db0-872e-b72b140ba9e6', 'so', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Ma waayey kayd lacageed ama hanti dabooli karta kharashyada?', '2026-08-28 19:05:47.787236+00'),
	('a20ee7f6-8005-4748-a3ae-686968d0d253', 'so', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Ma la shaqeysaan shuraako jooga ugu yaraan laba dal oo kale oo Waqooyiga Yurub ah?', '2026-08-28 19:05:47.787236+00'),
	('3ced2745-33a6-4159-96f7-8b985ffd7ca7', 'so', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Ma keensanaysaan aqoon dibadeed hawl horumarineed dartood?', '2026-08-28 19:05:47.787236+00'),
	('93b8faec-1a5d-47ed-b73c-bb9f24d8707b', 'so', 'Sker mobiliteten till ett annat europeiskt land?', 'Dhaqdhaqaaqu ma u socdaa dal kale oo Yurub ah?', '2026-08-28 19:05:47.787236+00');
INSERT INTO public.kb_translations VALUES
	('63f99af9-470c-4a14-9086-e30f73c89f91', 'so', 'Startar du eller tar du över företaget för första gången?', 'Markan ma tahay markii ugu horreysay oo aad bilowdo ama la wareegto ganacsiga?', '2026-08-28 19:05:47.787236+00'),
	('ee9c58f0-aa49-4590-b1c2-7a486d2638e8', 'so', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Taageero bilow oo loogu talagalay qofka 40 jir ama ka yar ee bilaabaya ama la wareegaya ganacsi beeraley ah.', '2026-08-28 19:05:47.787236+00'),
	('2fe41ac4-1a89-4c53-99c0-dcf353497795', 'so', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Deeq-waxbarasho u oggolaanaysa fannaaniinta xirfadleyda ah inay diiradda saaraan shaqadooda faneed.', '2026-08-28 19:05:47.787236+00'),
	('a33e921e-4875-430a-8ee0-5de037df9451', 'so', 'Studerar du, eller planerar du att börja studera?', 'Wax ma baranaysaa, mise waxaad qorsheyneysaa inaad bilowdo waxbarasho?', '2026-08-28 19:05:47.787236+00'),
	('685cee4f-28f6-43c4-8afc-288cf27751ec', 'so', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Taageero waxbarasho oo loogu talagalay dadka waaweyn ee shaqeeya ee doonaya inay wax bartaan si ay u xoojiyaan meeshay ka taagan yihiin suuqa shaqada.', '2026-08-28 19:05:47.787236+00'),
	('75309179-7f19-46bb-8ae2-abc5c54e15a1', 'so', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Taageero maalgelinno kordhiya tartanka ama yareeya saameynta deegaanka ee ganacsiyada beeraleyda.', '2026-08-28 19:05:47.787236+00'),
	('c121237d-628c-444a-ba59-b8d1fec1f7e2', 'so', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Taageero marka ilmo kula nool yahay oo waalidka kale uusan bixin masruuf.', '2026-08-28 19:05:47.787236+00'),
	('93ffdab6-9295-458d-9a6d-9016fee2d80a', 'so', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Taageero mashaariicda ururrada aan faa''iido doonka ahayn ee dadka, deegaanka iyo dunida ka wanaagsan.', '2026-08-28 19:05:47.787236+00'),
	('1e791ecd-c9ff-400c-95a3-d089441f0378', 'so', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Taageero u-gudubka warshadaha ee eber qiiqa gaaska lab-guriyeed.', '2026-08-28 19:05:47.787236+00'),
	('67462edc-5516-46ac-8ce9-ac26a8cf984e', 'so', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Taageero mashaariicda fanka iyo dhaqanka ee leh muuqaal waqooyi-yurubeed iyo iskaashi xuduudaha ka gudba.', '2026-08-28 19:05:47.787236+00'),
	('c459eb79-97cc-48f2-a183-f1a7f88eae0e', 'so', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Taageero mashaariic dhaqameed hal-abuur leh oo tijaabinaya muujinno, habab ama iskaashiyo faneed oo cusub.', '2026-08-28 19:05:47.787236+00'),
	('4bf6c9e0-ed04-47ba-842b-5860c40d515b', 'so', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Taageero mashaariic hal-abuur leh oo loogu talagalay carruurta, dhallinyarada, waayeelka iyo dadka naafada ah.', '2026-08-28 19:05:47.787236+00'),
	('258abf54-9c0a-429e-a0f9-080b505a03ed', 'so', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Taageero mashaariicda iskaashiga ee goobta muusiga madaxbannaan.', '2026-08-28 19:05:47.787236+00'),
	('f1f3fc96-dc15-476e-b9d2-4d6c95d2c7e6', 'so', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Taageero mashaariicda iskaashiga ee dhaqanka iyo warbaahinta ee xoojiya dimoqraadiyadda iyo xorriyadda hadalka caalami ahaan.', '2026-08-28 19:05:47.787236+00'),
	('713a0667-3b87-4ed9-a5ba-a823c0105655', 'so', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Mashruucu ma hiigsadaa xoojinta dimoqraadiyadda, sinnaanta ama xorriyadda hadalka?', '2026-08-28 19:05:47.787236+00'),
	('61604fdf-77c8-4355-b24f-3ed690174f51', 'so', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Shaqo ma ka raadinaysaa, mise waxaa lagaa siiyay shaqo, dal kale oo EU ama EES ah?', '2026-08-28 19:05:47.787236+00'),
	('2f927f01-425f-4c78-910a-94842419339a', 'so', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Xad sare oo waxa aad bixiso khidmadaha bukaanka muddo laba iyo toban bilood ah — kadibna frikort (kaadh bilaash ah).', '2026-08-28 19:05:47.787236+00'),
	('8d4e345e-0361-499f-98e4-2d7b7e9781f7', 'so', 'Tar du ut hel allmän pension?', 'Ma qaadataa hawlgabkaaga guud oo dhammaystiran?', '2026-08-28 19:05:47.787236+00'),
	('273f30de-a00c-4ab0-b584-3100bbcc6587', 'so', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Kordhin daboolaysa qayb ka mid ah kharashka guriga qofka haysta hawlgab iyo dakhli hooseeya.', '2026-08-28 19:05:47.787236+00'),
	('3c2ee3bb-48da-4b7c-9b67-95d88fedace0', 'so', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Gunno urureed sannadle ah oo loogu talagalay ururrada qaranka ee carruurta iyo dhallinyarada.', '2026-08-28 19:05:47.787236+00'),
	('282df769-d337-40ee-9b09-a3cf22f43218', 'so', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Xisaab sannadle ah oo si toos ah looga jaro dhakhtarka ilkaha ama nadiifiyaha ilkaha.', '2026-08-28 19:05:47.787236+00'),
	('4b9ca380-26ae-4626-9953-559236fc733b', 'so', 'Är bolaget yngre än cirka 5 år?', 'Shirkaddu ma ka yar tahay qiyaastii 5 sano?', '2026-08-28 19:05:47.787236+00'),
	('dfc47808-031e-4ffa-b348-845b0d3637e6', 'so', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Ka-qaybgalayaasha isweydaarsigu ma u dhexeeyaan 13 iyo 30 jir?', '2026-08-28 19:05:47.787236+00'),
	('b795f176-f1d8-4b46-87eb-1131b3f367d0', 'so', 'Är det här ert första EU-projekt?', 'Kani ma mashruucii EU ee idiin ugu horreeyay baa?', '2026-08-28 19:05:47.787236+00'),
	('1802a6c7-9ab7-41fc-81b4-ac301461098d', 'so', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Ma aad ugu adag tahay adiga (ama ilmahaaga) inaad keligaa dhaqdhaqaaqdo ama aad ku safarto bas iyo tareen?', '2026-08-28 19:05:47.787236+00'),
	('0ea8b26e-3159-4a13-b41c-1320cfd36924', 'so', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Dakhligaagu ma ka yar yahay qiyaastii 25 000 kr bishii canshuurta ka hor?', '2026-08-28 19:05:47.787236+00'),
	('e2cf823b-16ed-46ca-a02e-82f1c8afeb68', 'so', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Waxbarashadaadii ugu dambeysay ee dhammaystirneyd ma dugsiga hoose-dhexe baa, mise dugsi sare oo aadan dhammaystirin?', '2026-08-28 19:05:47.787236+00'),
	('e37891f5-22a8-46e9-a038-1ddd6d62c045', 'so', 'Är du 40 år eller yngre?', 'Ma tahay 40 jir ama ka yar?', '2026-08-28 19:05:47.787236+00'),
	('1f891e25-0fce-4e85-8eaf-56a080f96f4c', 'so', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Ma ka diiwaangashan tahay Arbetsförmedlingen shaqo-doon ahaan?', '2026-08-28 19:05:47.787236+00'),
	('69554b80-b2ed-43ac-a544-44839ab4eb75', 'so', 'Är du mellan 18 och 28 år?', 'Ma u dhexeysaa 18 iyo 28 jir?', '2026-08-28 19:05:47.787236+00'),
	('1bf54711-5761-4b83-8720-fb366c67d8db', 'so', 'Är du mellan 19 och 29 år?', 'Ma u dhexeysaa 19 iyo 29 jir?', '2026-08-28 19:05:47.787236+00'),
	('e28d651f-6f4a-401b-ba23-be69041ca587', 'so', 'Är du mellan 25 och 60 år?', 'Ma u dhexeysaa 25 iyo 60 jir?', '2026-08-28 19:05:47.787236+00'),
	('b679c62a-a46b-40c5-a829-02c85455e6b4', 'so', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Si xirfadle ah ma uga shaqeysaa dhinaca dhaqanka (tus. qoob-ka-ciyaar, muusig, fanka masraxa)?', '2026-08-28 19:05:47.787236+00'),
	('6c5ac312-92ca-4552-8df1-e7710c6b7d1a', 'so', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Ma tahay fannaan xirfadle ah (ma tihid hiwaayad ama tababar aasaasi ah)?', '2026-08-28 19:05:47.787236+00'),
	('7516cd5f-4fe9-49c0-8b6b-a880e60130e6', 'so', 'Är du yrkesverksam konstnär?', 'Ma tahay fannaan xirfadle ah?', '2026-08-28 19:05:47.787236+00'),
	('48368a2a-fb20-42b3-ba14-e67b7339bc9c', 'so', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Xalkiinnu ma yahay mid si weyn hal-abuur ugu ah marka la barbardhigo waxa horeba u jira?', '2026-08-28 19:05:47.790984+00'),
	('e514956a-904c-410f-bcec-cd83bc8b5af0', 'so', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Naadigu ma ka tirsan yahay xiriir isboorti oo gaar ah oo hoos yimaadda Riksidrottsförbundet?', '2026-08-28 19:05:47.790984+00'),
	('97abc3e4-2449-4007-8209-c2f7f4eb3d95', 'so', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Dakhliga qoysku ma hooseeyaa marka loo eego kharashka guriga?', '2026-08-28 19:05:47.790984+00'),
	('5b712c72-cdd6-4b19-b757-abe236848ea9', 'so', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Dakhliga wadajirka ah ee qoysku ma ka yar yahay qiyaastii 25 000 kr bishii canshuurta ka hor?', '2026-08-28 19:05:47.790984+00'),
	('84092b40-821c-4152-9ddb-e9071d8095d2', 'so', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Tallaabadu ma tahay mashruuc go''an (ma aha hawsha caadiga ah)?', '2026-08-28 19:05:47.790984+00'),
	('b7c43060-0053-48d5-a6cf-f71960faee3c', 'so', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Goobtu ma u furan tahay dhammaan dadka — ma aha oo kaliya xubnihiinna?', '2026-08-28 19:05:47.790984+00'),
	('502f5325-45c0-49b4-9f9b-7d8d59fa20b8', 'so', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Ugu yaraan 60 % xubnuhu ma u dhexeeyaan 6 iyo 25 jir?', '2026-08-28 19:05:47.790984+00'),
	('15c6671e-dfdb-49a7-b62a-7a9560a93d44', 'so', 'Är målgruppen delaktig i planering och genomförande?', 'Kooxda bartilmaameedka ahi ma ka qaybqaataa qorshaynta iyo fulinta?', '2026-08-28 19:05:47.790984+00'),
	('2609a2fa-6c87-4e8e-bb65-0fa64dcfd1e7', 'so', 'Är ni ett förlag med professionell utgivning?', 'Ma tihiin daabacaad leh daabacaad xirfadle ah?', '2026-08-28 19:05:47.790984+00'),
	('0e2ba9d2-9406-4061-9ac5-6155d77973ca', 'so', 'Är ni huvudman för förskoleklass eller grundskola?', 'Ma tihiin masuulka fasalka dugsi-barbaarinta ama dugsiga hoose-dhexe?', '2026-08-28 19:05:47.790984+00'),
	('5b240f94-45ca-41b9-91b0-e81c2c7d785a', 'so', 'Är organisationen registrerad i EU:s deltagarregister?', 'Ururku ma ka diiwaangashan yahay diiwaanka ka-qaybgalayaasha ee EU?', '2026-08-28 19:05:47.790984+00'),
	('2e74380b-0d3a-4f94-a188-752763a66608', 'so', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Mashruucu ma yahay mashruuc filim (filim gaaban ama dokumentari)?', '2026-08-28 19:05:47.790984+00'),
	('1f06f255-0404-449d-a052-de2e2a8060b2', 'so', 'Är projektet ett konst- eller kulturprojekt?', 'Mashruucu ma yahay mashruuc faneed ama dhaqameed?', '2026-08-28 19:05:47.790984+00'),
	('f87a9616-d166-4abd-8c13-533c242335eb', 'so', 'Är projektet ett kulturprojekt?', 'Mashruucu ma yahay mashruuc dhaqameed?', '2026-08-28 19:05:47.790984+00'),
	('3f394882-3f05-4c72-abe6-901b03f9af82', 'so', 'Är projektet ett musikprojekt?', 'Mashruucu ma yahay mashruuc muusig?', '2026-08-28 19:05:47.790984+00');
INSERT INTO public.kb_translations VALUES
	('e6f9ddb8-366b-451a-a83a-fd1cb2bd7b98', 'so', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Mashruucu ma yahay hal-abuur — wax aydaan horeba ugu samayn hawshiinna caadiga ah?', '2026-08-28 19:05:47.790984+00'),
	('ac05f106-ae68-4f78-a68c-79cb1123430c', 'so', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Mashruucu ma anfacaa deegaanka oo dhan (ma aha shakhsiyaad)?', '2026-08-28 19:05:47.790984+00'),
	('93ca2a1a-fe88-46f3-85ae-863c5026e4a6', 'so', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Waddada u dhexeysa guriga iyo dugsiga sare ma tahay ugu yaraan lix kiilomitir?', '2026-08-28 19:05:47.790984+00'),
	('269aa8fc-f29f-43b3-9199-9beab68f2c69', 'so', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Hawshu ma tahay mid xirfadle ah (ma aha hiwaayad)?', '2026-08-28 19:05:47.790984+00'),
	('82012043-cf2b-4aa2-81bd-52a4a43a972f', 'so', 'Är verksamheten professionell?', 'Hawshu ma tahay mid xirfadle ah?', '2026-08-28 19:05:47.790984+00'),
	('1f8ff6b6-be64-48b8-a2f3-5ceaac387a63', 'so', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Hawshu ma tahay fanka masraxa (qoob-ka-ciyaar, masrax, masrax muusig)?', '2026-08-28 19:05:47.790984+00'),
	('977eb2f2-bcd1-4d5d-b519-7aa5754b79b5', 'so', 'Är volontärerna mellan 18 och 30 år?', 'Mutadawiciintu ma u dhexeeyaan 18 iyo 30 jir?', '2026-08-28 19:05:47.790984+00'),
	('673403a3-22c9-4fda-9c6a-979287996a9c', 'ti', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'ንስፖርታዊ ማሕበራት ንህጻናትን መንእሰያትን 7–25 ዓመት ብመራሒ ዝምራሕ ንጥፈታት ዘካይዳ ዝወሃብ ደገፍ ንጥፈታት።', '2026-08-28 19:05:47.796108+00'),
	('46c66c04-6ba2-422c-a922-e9b74658dacd', 'ti', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'ካብ ካልኣይ ውሉድ ጀሚሩ ኣብ ልዕሊ ናይ ህጻናት ሓገዝ (barnbidrag) ብቐጥታ ዝውሰኽ ተወሳኺ።', '2026-08-28 19:05:47.796108+00'),
	('05b387e1-d7a3-46b5-b61a-6e47dff1183a', 'ti', 'Avser ansökan en fysisk investering?', 'እቲ ማመልከቻ ንኣካላዊ ወፍሪ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('06a69d69-f57e-4f71-88dd-edd2f33fe9a3', 'ti', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'እቲ ማመልከቻ ንኣህጉራዊ ጕዕዞ ወይ ምልውዋጥ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('8bd62c06-39e5-4b75-a060-7248fbb4d89f', 'ti', 'Avser ansökan en investering i byggnader eller maskiner?', 'እቲ ማመልከቻ ኣብ ህንጻታት ወይ ማሽናት ንዝግበር ወፍሪ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('7f6bb350-27c3-4d3e-af28-e260bb341e8e', 'ti', 'Avser ansökan en redan utgiven titel?', 'እቲ ማመልከቻ ድሮ ንዝተሓትመ ስራሕ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('4530aa04-2d05-482b-bf1f-a41d3510cafe', 'ti', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'እቲ ማመልከቻ ንሕርሻዊ፣ ኣታኽልታዊ ወይ ናይ ሰሜናዊ ጤለ-በጊዕ ኣርብሓ ትካል ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('9c15a466-d7a0-4ce3-b975-f55aa2839410', 'ti', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'እቲ ማመልከቻ ንህዝባዊ ወይ ናይ ቤት-ትምህርቲ ኣብያተ-መጻሕፍቲ መጻሕፍቲ ምዕዳግ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('94d4ced6-1b6d-4c61-803f-5492da7927c0', 'ti', 'Avser investeringen jordbruksverksamhet?', 'እቲ ወፍሪ ንሕርሻዊ ንጥፈት ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('8f2e9e29-5fb5-46fd-940f-b5a1bb8bccff', 'ti', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'እቲ ፕሮጀክት ምህናጽ፣ ምዕዳግ ወይ ምጽጋን ኣዳራሽ ድዩ ዘጠቓልል?', '2026-08-28 19:05:47.796108+00'),
	('396a5fa7-c1e5-4c8d-b909-8edf40191345', 'ti', 'Avser projektet naturvård eller friluftsliv?', 'እቲ ፕሮጀክት ንሓለዋ ተፈጥሮ ወይ ንደገ ዝግበር ምዝንጋዕ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('1cbd683e-395d-448b-b3aa-db1a2da52011', 'ti', 'Avser projektet skola eller vuxenutbildning?', 'እቲ ፕሮጀክት ንቤት-ትምህርቲ ወይ ንትምህርቲ ዓበይቲ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('03d34e05-7cf6-4913-8391-f5d0f531ea70', 'ti', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'ሕማሙ ንህይወቱ ዘስግእ ብጽኑዕ ዝሓመመ ቀረባ ሰብ ንምክንኻን ወይ ኣብ ጐድኑ ንምህላው ካብ ስራሕ ትቑጠብ ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('549ceda1-38c4-414c-b34c-8a43bbfcb352', 'ti', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'እቲ ማሕበር ኣብቲ ምምሕዳር ከተማ ስሩዕ ንጥፈታት ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('cdec5b99-c218-436e-b1e4-cc8b675ab37d', 'ti', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'ብሰንኪ ሕማም ወይ ስንክልና ናይ ስራሕ ዓቕምኻ እንተ ወሓደ ንሓደ ዓመት ከም ዝጐደለ ትግምግም ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('78e6788f-cbad-4622-b911-f343ed48e5aa', 'ti', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'ንትሑት ወይ ዜብሉ ጡረታ ዘለዎም እሞ ብቑዕ ደረጃ ናብራ ንምብጻሕ ሓገዝ ዘድልዮም ብድሌት ዝግምገም ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('24bd4ca3-39da-4b6c-8e2d-b299eee89b1f', 'ti', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'እቲ ቆልዓ መገዲ ኣዝዩ ነዊሕ ስለ ዝኾነ ኣብ ቦታ ትምህርቲ ክቕመጥ (መንበሪ) የድልዮ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('af6548e0-a000-43bc-aca5-54499681d43f', 'ti', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'እቲ መንበሪ ምምዕርራይ የድልዮ ድዩ (ንኣብነት መደያይቦ፣ መኽፈቲ ማዕጾ፣ መሕጸቢ)?', '2026-08-28 19:05:47.796108+00'),
	('e5632732-6be8-4fcf-8a3c-a9c3386f7e0a', 'ti', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'ካብ ደቅኻ ኣብ ዕድመ 8–19 ዘሎ መነጽር ወይ ሌንስ የድልዮ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('859a648e-c559-4feb-a002-354f165457a9', 'ti', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'እቲ ካልእ ወላዲ ገለ ኣይከፍልን ወይ ካብ ምሉእ ቀለብ ዝወሓደ ድዩ ዝኸፍል?', '2026-08-28 19:05:47.796108+00'),
	('5085b03b-1309-4647-a1a5-206631db44f5', 'ti', 'Betalar du hyra eller andra boendekostnader?', 'ክራይ ወይ ካልእ ወጻኢታት መንበሪ ትኸፍል ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('d4ad5fdc-f8f5-419b-a6ab-142024bda71e', 'ti', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'እቲ ወፍሪ ማመልከቻ ምስ ለኣኽኩም ጥራይ ድዩ ዝጅምር?', '2026-08-28 19:05:47.796108+00'),
	('99b7f97e-d17c-4c5d-b479-fca332fe3030', 'ti', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'ኣብ እዋን ስንክልና ንመንበሪ ምምዕርራይ ዝወሃብ ሓገዝ — ንኣብነት መደያይቦታት፣ መኽፈቲ ማዕጾ ወይ ምምዕርራይ መሕጸቢ።', '2026-08-28 19:05:47.796108+00'),
	('33fd915e-be56-4a97-99e7-d6929f34c473', 'ti', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'ህዝባዊ ኣዳራሻት ኣኼባ ንምህናጽ፣ ንምዕዳግ ወይ ንምጽጋን ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('f90a3bc3-4d6e-47a8-a306-ba3578b0c465', 'ti', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'ቀዋሚ ስንክልና ምንቅስቓስ ወይ ብህዝባዊ መጓዓዝያ ምጕዓዝ ኣዝዩ ኣጸጋሚ ምስ ዝገብሮ መኪና ንምዕዳግ ወይ ንምምዕርራይ ዝወሃብ ሓገዝ።', '2026-08-28 19:05:47.796108+00'),
	('7d5e34c1-c681-45bd-9177-a17f66c747d5', 'ti', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'ኣብ ዓውዲ ባህሊ ንዝሰርሑ ሞያውያን ንኣህጉራዊ ጕዕዞታትን ምልውዋጣትን ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('7e9033a1-abfd-4da8-89f1-d56a2b451881', 'ti', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'ንሞያውያን ስነ-ጥበበኛታት ኣህጉራዊ ምልውዋጣት፣ ጕዕዞታትን ናይ ስራሕ ጻንሒታትን ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('8c1f9405-83f4-4987-9289-6060f072fbd0', 'ti', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'ኣብ ደረጃ ካልኣይ ደረጃ ወይ ድሕሪኡ ንዝግበር ትምህርቲ ሓገዝን ወለንታዊ ልቓሕን።', '2026-08-28 19:05:47.796108+00'),
	('ad690417-16ec-475f-862d-7ec191fd2d6d', 'ti', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'ኣብ ወጻኢ ንዝግበር ትምህርቲ ሓገዛትን ልቓሓትን፣ ንኣብነት ክፍሊት ትምህርትን ጕዕዞን ዝሽፍኑ ተወሰኽቲ ልቓሓት ዘለዉዎ።', '2026-08-28 19:05:47.796108+00'),
	('fac36bf8-abd7-4dd6-bf20-af71cf2be8b2', 'ti', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'ንሽወደናውያን ኣካላት ናብ ናይ EU መደባት ከም Horisont Europa ማመልከቻ ንምድላው ዝሕግዝ ሓገዝ።', '2026-08-28 19:05:47.796108+00'),
	('2fd2f4e8-3e6d-4cb5-bb64-106c5373728a', 'ti', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'ዝጐደለ ናይ ስራሕ ዓቕሚ ንዘለዎም ሰባት ንዝቖጽሩ ኣስራሕቲ ዝወሃብ ሓገዝ።', '2026-08-28 19:05:47.796108+00'),
	('3b514983-2dbc-4ba0-bd92-2323979efe6c', 'ti', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'ተምሃራይ ካልኣይ ደረጃ ብሰንኪ ነዊሕ መገዲ ኣብ ቦታ ትምህርቲ ክቕመጥ ምስ ዝግደድ ንመንበርን ናብ ገዛ ንዝግበር ጕዕዞታትን ዝወሃብ ሓገዝ።', '2026-08-28 19:05:47.796108+00'),
	('94c27ba4-0bae-4e52-a5aa-76073350ffe1', 'ti', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'ባህላዊ ውርሻ ንምዕቃብ፣ ንምጥቃምን ንምምዕባልን ንዝሰርሓ ዘይመኽሰባውያን ውድባት ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('5c4baf47-52b3-413e-9be5-be6002e6905a', 'ti', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'ንምምሕዳራዊን ከባብያዊን ፕሮጀክትታት ሓለዋ ተፈጥሮ፣ ማይ-ዘለዎም ቦታታትን ንደገ ዝግበር ምዝንጋዕን ሓዊሱ ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('0af8d435-bad0-4c31-90bc-ec87e6895b29', 'ti', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'ንህዝባዊን ናይ ቤት-ትምህርትን ኣብያተ-መጻሕፍቲ መጻሕፍቲ ንምዕዳግ ንምምሕዳራት ከተማ ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('4873343c-5aa3-4016-bf10-751c67855c2a', 'ti', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'ተምሃሮ መባእታ ምስ ሞያዊ ባህሊ ንኽራኸቡ ንሓለፍቲ ኣብያተ-ትምህርቲ ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('183e7a30-46d0-4352-8b7f-dea1eed312d2', 'ti', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'ውሉድካ ዘድልዮ ግን ቁጠባ ስድራ ዘይኣኽሎ ነገራት ዝወሃብ ሓገዝ፦ ናይ ትርፊ ግዜ ንጥፈታት፣ ክዳውንቲ፣ ናይ ቤት-ትምህርቲ ዙረታት፣ መነጽር፣ ናይ ዕረፍቲ ንጥፈታትን ካልእን።', '2026-08-28 19:05:47.796108+00'),
	('0dd12a37-8c45-49ad-b3b1-ad410865e5df', 'ti', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'ካብ Världens Barn፣ Musikhjälpen ከምኡውን Victoriafonden ዝኣመሰሉ ፈንድታት ዝወሃቡ ሓገዛት — 90-konto ዘለወን ሽወደናውያን ዘይመኽሰባውያን ውድባት ይሓትታኦም።', '2026-08-28 19:05:47.796108+00'),
	('53358361-c37e-4b36-a20c-cc036d67a7cc', 'ti', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'ነቲ ከባቢ ዘማዕብሉ ፕሮጀክትታት ካብ ገንዘብ ሓይሊ ማይን ንፋስን ዝወሃቡ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('ed44ff4e-6dae-42ed-b828-d74505ccab27', 'ti', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'ሓጺር ትምህርቲ ንዘለዎም ስራሕ-ኣልቦ 25–60 ዓመት ኣብ ደረጃ መባእታ ወይ ካልኣይ ደረጃ ክመሃሩ ዘድልዮም ብዘይ ልቓሕ ዝወሃብ ሓገዝ።', '2026-08-28 19:05:47.796108+00'),
	('5c6b92aa-793b-4e80-87af-bd1d37b0f221', 'ti', 'Bidrar projektet till energiomställningen?', 'እቲ ፕሮጀክት ኣብ ምስግጋር ጸዓት ኣበርክቶ ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('fc42f72f-59cc-403b-9f33-8623f4aea16d', 'ti', 'Bor du och barnets andra förälder på skilda håll?', 'ንስኻን እቲ ካልእ ወላዲ እቲ ቆልዓን ተፈላሊኹም ዲኹም ትነብሩ?', '2026-08-28 19:05:47.796108+00'),
	('dc1d5572-e776-4488-a14c-b142c3d3877b', 'ti', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'ንንኣሽቱ ትካላት ኣብ ኣህጉራውነት ወይ ዲጂታላዊ ምቕያር ናይ ወጻኢ ክእለት ንምእታው ዝወሃቡ ቸካት።', '2026-08-28 19:05:47.796108+00');
INSERT INTO public.kb_translations VALUES
	('50f5e745-ab50-405b-889c-56f7c0784008', 'ti', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'ኣብ Arbetsförmedlingen ኣብ ዝካየድ መደብ ትሳተፍ ዲኻ (ንኣብነት jobb- och utvecklingsgarantin)?', '2026-08-28 19:05:47.796108+00'),
	('373c441e-e5eb-42fe-9208-10a914ee9cc0', 'ti', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'ብሉጽ ስነ-ጽሑፍ ንዘሕትሙ ኣሕተምቲ ድሕሪ ሕትመት ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('6d344d94-61a2-404a-82e0-86408bc70cd1', 'ti', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'ምስ ዑቕባ ዝተኣሳሰር ናይ መንበሪ ፍቓድ ዘለዎም እሞ ብወለንታ ናብ ሃገሮም ንሓዋሩ ክምለሱ ዝደልዩ ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('dd202eb0-f744-4629-8294-bbc8cbe690b5', 'ti', 'Kommer projektet människor i ert närområde till del?', 'እቲ ፕሮጀክት ንህዝቢ ከባቢኹም ይጠቅም ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('ac72d226-0908-49ac-bb3a-a07298624f14', 'ti', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'ካብ ናብራ ስራሕ ንነዊሕ ግዜ ርሒቑ ንዝጸንሐ ሰብ ንዝቖጽሩ ኣስራሕቲ ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('85a1ccfe-85ed-4fdd-a4a9-d55d85e733f6', 'ti', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'ናይ ገዛእ ርእሶም ትካል ንዝጅምሩ ደለይቲ ስራሕ ኣብ እዋን ምጅማር ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('884eaa3d-3c1c-4437-8be0-322a396bf1b3', 'ti', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten ኣብ ምርምር ጸዓት፣ ምህዞን ብቕዓት ጸዓትን ቀጻሊ ጻውዒታት ትኸፍት።', '2026-08-28 19:05:47.796108+00'),
	('d6e54ce6-7149-4b58-80c5-37bad86c863a', 'ti', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'ንምክንኻን ቆልዓ ካብ ስራሕ ወይ ትምህርቲ ንምቁጣብ ዝወሃብ ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('99affcce-2f4b-4fba-952e-5a3f8f15e756', 'ti', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'ኣብ ሽወደን ሓድሽ ኮይኑ ኣብ ናይ Arbetsförmedlingen መደብ ምስፋር ንዝሳተፍ ዝወሃብ ክፍሊት፤ Försäkringskassan እያ ትኸፍሎ።', '2026-08-28 19:05:47.796108+00'),
	('db612ae2-5827-41f7-b933-4dd0d8c1936a', 'ti', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'ውሉድ ዘይብሎም ትሑት ኣታዊ ዘለዎም መንእሰያት ክፋል ወጻኢታት መንበሪ ዝሽፍን ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('fb0e7179-eae0-4445-a4aa-6567cdc6f62e', 'ti', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'ቀዋሚ ስንክልና ዘምጽኦም ተወሰኽቲ ወጻኢታት ዝሽፍን ክፍሊት — ንዓበይቲ፣ ወይ ንወለዲ ስንክልና ዘለዎም ቆልዑ።', '2026-08-28 19:05:47.796108+00'),
	('54406b16-d55b-4079-aea6-3be1bfc2577e', 'ti', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'ብሰንኪ ሕማም ወይ ስንክልና እንተ ወሓደ ንሓደ ዓመት ምሉእ ግዜ ክሰርሑ ዘይክእሉ መንእሰያት (19–29 ዓመት) ዝወሃብ ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('2392097b-5003-4793-8c00-e25ad0f77d9a', 'ti', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'ናይ ስራሕ ዓቕሚ ብቐዋሚ ምስ ዝጐድል ዝወሃብ ክፍሊት — ቅድም förtidspension (ናይ ኣቐዲሙ ጡረታ) ዝበሃል ዝነበረ።', '2026-08-28 19:05:47.796108+00'),
	('de0449e5-140f-44bd-88ef-becf67b103cc', 'ti', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'ብጽኑዕ ዝሓመመ ቀረባ ሰብ ኣብ ጐድኑ ንምህላው ካብ ስራሕ ምስ እትቑጠብ ዝወሃብ ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('3f3bce46-d19b-4ab6-8c40-cd4fdf9ec17a', 'ti', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'ኣብ ናይ Arbetsförmedlingen ናይ ዕዳጋ ስራሕ መደብ ምስ እትሳተፍ ዝወሃብ ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('907e33a0-9877-4726-ae11-dc870feabab5', 'ti', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'ብሰንኪ ሕማም ከም ልማድ ክትሰርሕ ምስ ዘይትኽእል ዝወሃብ ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('27a14304-fea7-4c1d-a7b0-7ed10638e5bc', 'ti', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'ሕሙም ቆልዓ ንምክንኻን ካብ ስራሕ ኣብ ገዛ ምስ እትተርፍ ዝወሃብ ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('840a5353-5da5-4c87-ae7a-9cad6dc87db5', 'ti', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'ቆልዑ ዘለዎምን ትሑት ኣታዊ ዘለዎምን ስድራቤታት ክፋል ወጻኢታት መንበሪ ዝሽፍን ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('63985446-efbf-4002-80a9-2e34c5fc27dd', 'ti', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'ደቆም ብሰንኪ ስንክልና ካብ መዛኖኦም ንላዕሊ ክንክንን ቁጽጽርን ንዘድልዮም ወለዲ ዝወሃብ ክፍሊት።', '2026-08-28 19:05:47.796108+00'),
	('7cf8e50f-79ee-4366-b5e4-91748de14244', 'ti', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'ኣብ እዋን ስራሕ-ኣልቦነት ዝወሃብ ክፍሊት — ንኣባላት ኣብ ኣታዊ ዝተመስረተ፣ ንኻልኦት መሰረታዊ መጠን።', '2026-08-28 19:05:47.796108+00'),
	('1b63a93e-03c6-4ccb-94a4-6fd29200f9fb', 'ti', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'ኣስታት ሓምሳ ናይ ዕቋር ባንክታት ትካላት ኣብ ስፖርት፣ ባህሊ፣ ትምህርትን ማሕበራዊ ምዕባለን ንዝካየዱ ከባብያውያን ፕሮጀክትታት ሓገዛት ይህባ — ኣብ ናይቲ ባንክ ናይ ስራሕ ከባቢ።', '2026-08-28 19:05:47.796108+00'),
	('ae56b277-c19f-4c32-95b4-d591ff988eb3', 'ti', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'ብ EU ዝምወል ናይ ፕሮጀክት ደገፍ ኣብ ከባቢኻ ዘሎ ናይ Leader ዞባ ዝሕተት — ንማሕበራት፣ ትካላትን ምምሕዳራት ከተማን ገጠር ዘማዕብላ።', '2026-08-28 19:05:47.796108+00'),
	('61f8d8c6-968a-4a10-a77a-91a5bf5cfddf', 'ti', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'ኣብ ካልእ ሃገር EU/EES ስራሕ ንዝሕዙ ደለይቲ ስራሕ ብ EU ዝምወል ደገፍ፦ ናይ ቃለ-መሕትት ጕዕዞ፣ ወጻኢታት ምግዓዝን ትምህርቲ ቋንቋን ዝሽፍን።', '2026-08-28 19:05:47.796108+00'),
	('a182d8bb-4687-4bf7-9d3c-798d64e792ef', 'ti', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'ክእለት፣ ምስግጋርን ኣብ ዕዳጋ ስራሕ ምስታፍን ንዘደልድሉ ፕሮጀክትታት ካብ ማሕበራዊ ፈንድ EU ዝወሃብ ገንዘብ።', '2026-08-28 19:05:47.796108+00'),
	('da0ff037-ac0d-40bc-b3ca-d59bde7d4935', 'ti', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'ንጕጅለኣዊ ምልውዋጣት መንእሰያት 13–30 ዓመት፣ ብዘይ መዓልታት ጕዕዞ 5–21 መዓልታት ዝጸንሕ ናይ EU ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('abec5f23-e7f0-4347-8be0-f123d32d33f6', 'ti', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'ባህላውያን ውድባት ምስ መሻርኽቲ ኣብ ብዙሓት ሃገራት ኤውሮጳ ንዘካይድኦም ፕሮጀክትታት ምትሕብባር ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('271ebb73-4374-4287-9e21-9e1170415613', 'ti', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'መንእሰያት ወለንተኛታት 18–30 ዓመት ንዝቕበላ ወይ ንዝልእኻ ውድባት ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('0253bed9-e404-4811-bf59-f03ea5009c93', 'ti', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'ኣብ ቤት-ትምህርትን ትምህርቲ ዓበይትን ንምንቅስቓስ ሰራሕተኛታትን ተምሃሮን ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('04cbbba5-e452-4343-ad61-f82fff0e0ac6', 'ti', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'ንንኣሽቱ ውድባት ናይ መጀመርታ ኤውሮጳዊ ፕሮጀክትታት ምትሕብባር ብቑርጺ መጠን ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('e9dcfae5-8f25-45f1-aabd-debd907cf745', 'ti', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'ኣህጉራዊ ተኽእሎ ዘለዎም ሓደስቲ ፍርያት ወይ ኣገልግሎታት ንዘማዕብላ መንእሰያት ትካላት ዝወሃብ ምወላ።', '2026-08-28 19:05:47.796108+00'),
	('3ce43b7e-3aba-44d3-b716-316fd20bdbb4', 'ti', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'ኣብቲ ንጥፈትኩም እትገብሩሉ ቦታ ናይ ዕቋር ባንክ (ስለዚ ድማ ትካል ዕቋር ባንክ) ኣሎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('17c2e5ce-7def-4359-a04e-2b204eb47888', 'ti', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'ኣብ ሳዕስዒት፣ ትያትርን ሙዚቃዊ ትያትርን ንዝነጥፋ ሞያውያን ናጻ ጕጅለታት ናይ ብዙሕ ዓመታት ናይ ስራሕ ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('8359fad9-343c-4aea-b2c8-f6c42e5aac78', 'ti', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'ኣብ ናይ Forte ዓውድታት ዝወሃቡ ናይ ምርምር ሓገዛት፦ ጥዕና፣ ናብራ ስራሕን ድሕነትን። ኣብ ሽወደናውያን ላዕለዎት ትካላት ትምህርቲ ዶክትረይት ዘለዎም ተመራመርቲ ይሓትዎም።', '2026-08-28 19:05:47.796108+00'),
	('a31b90aa-2163-46f7-968c-826d62faca62', 'ti', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'ኣብ ኩሎም ዓውድታት ስነ-ፍልጠት ንናጻ መሰረታዊ ምርምር ዝወሃብ ናይ ምርምር ገንዘብ።', '2026-08-28 19:05:47.796108+00'),
	('95c97c33-e36e-4808-9469-6a405b5564d0', 'ti', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'ኣብ ከባቢ፣ ሕርሻዊ ስነ-ፍልጠታትን ህንጸት ከተማን ዝወሃብ ናይ ምርምር ገንዘብ።', '2026-08-28 19:05:47.796108+00'),
	('4180f321-630d-45a1-88e7-9c379abd7a37', 'ti', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'ናብ ወጻኢ ክትግዕዝ ትሓስብ ዲኻ (ንስራሕ፣ ንትምህርቲ ወይ ንምምላስ ናብ ዓዲ)?', '2026-08-28 19:05:47.796108+00'),
	('0e1fbbe2-5546-44fc-80d8-9c82c4ad26dc', 'ti', 'Genomförs insatserna av professionella kulturaktörer?', 'እቶም ንጥፈታት ብሞያውያን ባህላውያን ተዋሳእቲ ድዮም ዝፍጸሙ?', '2026-08-28 19:05:47.796108+00'),
	('9e767e7e-22ee-4470-a3e8-a299c861abfd', 'ti', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'እቲ ፕሮጀክት ኣብ ገጠር ወይ ኣብ ንእሽቶ ከተማ ድዩ ዝካየድ?', '2026-08-28 19:05:47.796108+00'),
	('bd1ee50e-8036-4887-8063-3da81e0eff27', 'ti', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'ኣብ ህይወቶም ትሑት ወይ ዜብሉ ናይ ስራሕ ኣታዊ ንዝነበሮም መሰረታዊ ውሕስነት።', '2026-08-28 19:05:47.796108+00'),
	('cffa88c5-7d23-4659-a931-ad87b99d86eb', 'ti', 'Går något av dina barn i grundskolan?', 'ካብ ደቅኻ ኣብ መባእታ ቤት-ትምህርቲ ዝመሃር ኣሎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('e5b42d5f-80a2-40f9-a510-259805ff5bc4', 'ti', 'Går något av dina barn på gymnasiet?', 'ካብ ደቅኻ ኣብ ካልኣይ ደረጃ ዝመሃር ኣሎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('7704f18c-b7fa-47a1-957a-4231990e85e0', 'ti', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'እቲ ቁጻር ንዝጐደለ ናይ ስራሕ ዓቕሚ ዘለዎ ሰብ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('44984fa0-8414-4ee5-b51b-49b6007f4142', 'ti', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'እቲ ቁጻር ንነዊሕ ግዜ ስራሕ-ኣልቦ ንዝነበረ ወይ ኣብ ሽወደን ሓድሽ ንዝኾነ ሰብ ድዩ ዝምልከት?', '2026-08-28 19:05:47.796108+00'),
	('471d752f-ffcb-4054-a098-16a6daa1440c', 'ti', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'እቲ ፕሮጀክት ብዛዕባ ምዕቃብ ወይ ምብጻሕ ባህላዊ ውርሻ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('72b6b5e2-545c-49ab-a755-8b9ff1a31a25', 'ti', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'እቲ ፕሮጀክት ብዛዕባ ጸዓት፣ ብቕዓት ጸዓት ወይ ምስ ጸዓት ዝተኣሳሰር ምህዞ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('19e3ca4f-7b68-474b-81b2-b53241f6311d', 'ti', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'እቲ ፕሮጀክት ብዛዕባ ጥዕና፣ ናብራ ስራሕ ወይ ድሕነት ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('81751f0b-cf55-426d-80a2-acaf03972602', 'ti', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'እቲ ፕሮጀክት ብዛዕባ ምምዕባል ክእለት ወይ ስጉምትታት ዕዳጋ ስራሕ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('aceabc32-d47a-4099-8e14-e4982ef466fc', 'ti', 'Handlar projektet om miljö- eller klimatåtgärder?', 'እቲ ፕሮጀክት ብዛዕባ ከባብያዊ ወይ ክሊማዊ ስጉምትታት ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('16574868-2baf-47c7-a956-3f4b3ef69b29', 'ti', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'እቲ ቆልዓ ናብ ቤት-ትምህርቲ ነዊሕ፣ ብትራፊክ ሓደገኛ ወይ ብኻልእ መገዲ ኣጸጋሚ መገዲ ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('8194c415-4b39-4cc9-b8dc-e66fbe63354e', 'ti', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'እንተ ወሓደ 16 ሰዓታት ኣብ ሰሙን፣ ብድምር እንተ ወሓደ 8 ዓመታት ሰሪሕካ ዲኻ?', '2026-08-28 19:05:47.796108+00');
INSERT INTO public.kb_translations VALUES
	('e776e89c-02d4-4c7b-a32d-b265477262ee', 'ti', 'Har du barn som bor hos dig, helt eller växelvis?', 'ምሳኻ ዝነብሩ ቆልዑ ኣለዉኻ ድዮም፣ ምሉእ ብምሉእ ወይ ብተመላላሲ?', '2026-08-28 19:05:47.796108+00'),
	('ca43b16b-dcd5-4e82-82cb-8c567b15dfa1', 'ti', 'Har du barn som bor hos dig?', 'ምሳኻ ዝነብሩ ቆልዑ ኣለዉኻ ድዮም?', '2026-08-28 19:05:47.796108+00'),
	('30362b69-d338-42dd-b846-5b0acea3ccac', 'ti', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'ንስኻ ወይ ውሉድካ እንተ ወሓደ ሓደ ዓመት ክጸንሕ ትጽቢት ዝግበረሉ ስንክልና ኣለኩም ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('e8c6220c-ba95-4b83-b456-cb62d3a36832', 'ti', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'ንስኻ ወይ ሓደ ካብ ስድራቤት ኣብ መንበሪ ጽልዋ ዘለዎ ቀዋሚ ስንክልና ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('93d926d2-5848-4e79-a007-0d4ed1a0a8b1', 'ti', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'ንስኻ ወይ ቀረባ ዘመድ ስንክልና ወይ ነዊሕ ዝጸንሐ ወይ ከቢድ ሕማም ኣለኩም ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('b5ca0cb0-b5d4-48e2-8e1b-660a4e8d8b72', 'ti', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'ሕጂ ናይ ስራሕ ዓቕምኻ ዘጕድል ሕማም ወይ ጉድኣት ኣለካ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('fed0f78f-bdec-45dc-a6f8-1de084b89317', 'ti', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'ውሉድካ ክሳተፎ ትጽቢት ዝግበረሉ ናይ ቤት-ትምህርቲ ዙረት፣ ናይ ክፍሊ ጕዕዞ ወይ ናይ ትርፊ ግዜ ንጥፈት ንምኽፋል ተጸጊምካ ትፈልጥ ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('8246a44e-75aa-46d5-80b9-c888f0d8f9df', 'ti', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'ብጡረታኻን ካልእ ኣታዊኻን ምንባር የጸግመካ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('65a8215d-ad24-4f2a-b2db-6919a0db05b0', 'ti', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'ኣብ ዝሓለፉ ዓመታት ኣብ ሽወደን ናይ መንበሪ ፍቓድ ረኺብካ ዲኻ፣ ንኣብነት ከም ዑቕባ ዘድልዮ ወይ ከም ኣባል ስድራ?', '2026-08-28 19:05:47.796108+00'),
	('f76ead96-d1fb-4a36-93f0-387025084041', 'ti', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'ከም ስደተኛ ወይ ዑቕባ ዘድልዮ ሰብ ኣብ ሽወደን ናይ መንበሪ ፍቓድ ኣለካ ድዩ (ወይ ከምኡ ዘለዎ ሰብ ቀረባ ዘመድ ዲኻ)?', '2026-08-28 19:05:47.796108+00'),
	('c488a6dc-8b8a-4e0b-a2f5-94b1973bf380', 'ti', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'ናይ ጡረታ መወከሲ ዕድመ (67 ዓመት ኣብ 2026) በጺሕካ ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('e0e77692-07cf-4447-b337-b00d3bb044e8', 'ti', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'ውድብኩም ኣብ ናይ EU Organisation Registration System ዝተመዝገበ OID (Organisation ID) ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('d83397a8-a235-45d9-a7ca-74632ca8a282', 'ti', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'እቲ ስንክልና ተወሰኽቲ ወጻኢታት ኣምጺኡ ድዩ — ንኣብነት መሳርሒታት፣ ጕዕዞታት፣ ፍሉይ መግቢ ወይ ምብልሻው?', '2026-08-28 19:05:47.796108+00'),
	('e5e758c5-63ca-4be0-a3ba-270d10d64dd1', 'ti', 'Har föreningen antagna stadgar och en vald styrelse?', 'እቲ ማሕበር ዝጸደቐ ሕገ-ደንብን ዝተመርጸ ኣመራርሓን ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('6cecb3fb-3b31-48cc-a118-3b7abfddce08', 'ti', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'እቲ ማሕበር ዲሞክራስያዊ ኣቃውማ ኣለዎ ድዩ (ሕገ-ደንቢ፣ ዓመታዊ ኣኼባ፣ ኣመራርሓ)?', '2026-08-28 19:05:47.796108+00'),
	('86189267-d4b0-4f4b-bc10-1eb91d07bd32', 'ti', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'እቲ ማሕበር ንቆልዑ ወይ መንእሰያት ስሩዕ ንጥፈታት ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('ba228c6c-ac12-4c05-950e-105299e59770', 'ti', 'Har företaget mellan cirka 2 och 49 anställda?', 'እታ ትካል ኣስታት ካብ 2 ክሳብ 49 ሰራሕተኛታት ኣለዉዋ ድዮም?', '2026-08-28 19:05:47.796108+00'),
	('10244673-465a-4e59-b309-98143d808dd9', 'ti', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'እታ ስድራቤት ወጻኢታት መግቢ፣ መንበርን እቲ ኣዝዩ ኣድላዪን ንምሽፋን ትጽገም ድያ?', '2026-08-28 19:05:47.796108+00'),
	('205a5720-ec98-47d3-b3f3-7a86e7bb5404', 'ti', 'Har lösningen internationell potential?', 'እቲ ፍታሕ ኣህጉራዊ ተኽእሎ ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('13d48920-76b5-4e6f-aa12-859ea2d3cf50', 'ti', 'Har ni en partnergrupp i ett annat land?', 'ኣብ ካልእ ሃገር መሻርኽቲ ጕጅለ ኣለኩም ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('6cc013d2-8c40-4305-8e96-b7070a3be92b', 'ti', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'ኣብ ካልእ ሃገር ኤውሮጳ መሻርኽቲ ውድብ ኣለኩም ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('79efe370-3898-4ed3-a613-03b4ed42a62e', 'ti', 'Har ni partner i minst tre olika europeiska länder?', 'እንተ ወሓደ ኣብ ሰለስተ ዝተፈላለያ ሃገራት ኤውሮጳ መሻርኽቲ ኣለዉኹም ድዮም?', '2026-08-28 19:05:47.796108+00'),
	('072d114c-d009-4897-a921-c4d087943bd7', 'ti', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'መቐመጢኹም ወይ ቀንዲ ንጥፈትኩም ኣብቲ እትሓቱሉ ዞባ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('b953689f-0186-4c22-8743-2abb62359b98', 'ti', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'ካብ ደቅኻ ብሰንኪ ስንክልና ካብ መዛኖኡ ንላዕሊ ክንክን ወይ ቁጽጽር ዘድልዮ ኣሎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('bdf32d7f-39f2-420f-a7c9-72e3fe09b3d6', 'ti', 'Har organisationen en demokratisk uppbyggnad?', 'እቲ ውድብ ዲሞክራስያዊ ኣቃውማ ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('2134ce52-b691-4737-8eca-270752c3a3e4', 'ti', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'እቲ ውድብ Quality Label (ምልክት ብቕዓት) ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('6af3866a-147b-41c3-ad97-62bc3ce341cf', 'ti', 'Har organisationen ett 90-konto?', 'እቲ ውድብ 90-konto ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('4afc57bf-775a-4046-9dcf-f3e9b9d32d40', 'ti', 'Har organisationen ett OID (Organisation ID)?', 'እቲ ውድብ OID (Organisation ID) ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('922a465b-324a-4e38-80e7-11ea7bac4ce0', 'ti', 'Har organisationen ett OID?', 'እቲ ውድብ OID ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('f09f7602-d23b-4a96-9628-6e53cdf174cd', 'ti', 'Har organisationen medlemsföreningar i flera län?', 'እቲ ውድብ ኣብ ብዙሓት ዞባታት ኣባላት ማሕበራት ኣለዉዎ ድዮም?', '2026-08-28 19:05:47.796108+00'),
	('e3f86577-1d9e-483d-9a5c-c2e3c980e7e3', 'ti', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'እቲ ውድብ ስሩዕ ቁጠባን ዲሞክራስያዊ ኣቃውማን ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('79c29ce6-1f02-486c-880c-5e1f7332ef29', 'ti', 'Har projektet en partner i ett annat land?', 'እቲ ፕሮጀክት ኣብ ካልእ ሃገር መሻርኽቲ ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('50afa2aa-3785-4b07-b399-3b0896374a39', 'ti', 'Har projektledaren doktorsexamen?', 'እቲ መራሒ ፕሮጀክት ዶክትረይት ኣለዎ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('f95314c0-fad2-49af-86cb-97acb2db34f7', 'ti', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'እቲ መገዲ እንተ ወሓደ ሽዱሽተ ኪሎሜተር ምስ ዝኸውን፣ ምምሕዳር ከተማኻ ኣብ መንጎ ገዛን ካልኣይ ደረጃ ቤት-ትምህርትን ዕለታዊ ጕዕዞ ከቕርብ ኣለዎ (ንኣብነት ናይ ኣውቶቡስ ካርድ)።', '2026-08-28 19:05:47.796108+00'),
	('ea90cfdf-85ce-4c0d-b2fa-00c8831cb579', 'ti', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'ኣብ ሽወደን ናይ መጀመርታ ናይ ገዛእ ርእስኻ ገዛ ትረክብ ወይ ተዳሉ ኣለኻ ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('b29729d7-39ac-454d-ab5a-44bb5efbc33d', 'ti', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'እቲ ፕሮጀክት ኣህጉራዊ ጕዕዞ ወይ ምልውዋጥ የጠቓልል ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('023e1ddc-feee-4987-aeb8-2f3a282e7926', 'ti', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'ኣብ ናይ ደገፍ ዞባታት ንዘለዋ ትካላት ንህንጻታት፣ ማሽናትን ስልጠናን ዝወሃብ ናይ ወፍሪ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('6259400b-713e-4e12-b988-0bb18cbc577a', 'ti', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'ልቀት ጋዛት ግሪንሃውስ ንዘጕድሉ ስጉምትታት ዝወሃብ ናይ ወፍሪ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('ba2a2a22-1144-437f-9d5e-d168ae413f8e', 'ti', 'Kan projektets miljönytta mätas?', 'ከባብያዊ ጥቕሚ እቲ ፕሮጀክት ክዕቀን ይከኣል ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('c9778304-32a5-4019-abf7-615cc120fd0c', 'ti', 'Kan åtgärdens utsläppsminskning beräknas?', 'ምጕዳል ልቀት እቲ ስጉምቲ ክሕሰብ ይከኣል ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('d16eb567-d871-4b51-bae9-1226b186512d', 'ti', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'እቲ ውድብ እቲ ደገፍ ክሳብ ዝኽፈል ወጻኢታት ክጻወር ይኽእል ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('b40910f7-1719-4d46-8917-616ea403598d', 'ti', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'እቲ ተመኩሮ ኣብ ንጥፈትካ ኣብ ሽወደን ክውዕል ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('a8ec00c9-018b-46d8-9e7b-ec5ccd6c209d', 'ti', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'ኣታዊ ነቲ ኣዝዩ ኣድላዪ ምስ ዘይኣክል ናይ ምምሕዳር ከተማ ናይ መወዳእታ ቁጠባዊ መከላኸሊ መርበብ።', '2026-08-28 19:05:47.796108+00'),
	('db7cc086-a74b-4031-a4fb-d6b59e940d94', 'ti', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'ናይ ምምሕዳራት ከተማ ናይ ገዛእ ርእሰን ደገፍ ንከባብያዊ ማሕበራት፦ ንነፍሲ ወከፍ ኣጋጣሚ ናይ ንጥፈት ደገፍ፣ ናይ ኣዳራሽ ሓገዝ፣ ናይ ምጅማር ሓገዝን ካልእን።', '2026-08-28 19:05:47.796108+00'),
	('9bf5a71e-6be2-4ed4-aabe-3fa32dbb0f26', 'ti', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'ኣብ ነዊሕ ርሕቀት፣ ሓደገኛ መገዲ ወይ ስንክልና ንተምሃሮ መባእታ ነጻ ናይ ቤት-ትምህርቲ መጓዓዝያ — ብሕጊ ትምህርቲ መሰል እዩ።', '2026-08-28 19:05:47.796108+00'),
	('2245ac61-5d14-4db8-bc3d-0586a4e3f055', 'ti', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'ንቆልዑን መንእሰያትን ብሕጊ ዝተደንገገ ናይ መነጽር ወይ ሌንስ ሓገዝ፤ መጠናትን ኣገባባትን በብዞባ ይፈላለ — ደረጃ ዞባኻ ኣረጋግጽ።', '2026-08-28 19:05:47.796108+00'),
	('abf08afd-576e-4f17-9e16-6493b435340f', 'ti', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'እቲ ፕሮጀክት ብሓይሊ ማይ ወይ ንፋስ ኣብ ዝትንከፍ ከባቢ ድዩ ዘሎ?', '2026-08-28 19:05:47.796108+00'),
	('d900de1f-ca08-4337-8e08-47fbde9d6ce8', 'ti', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'እቲ ፕሮጀክት ኣብ ውሽጢ ከባቢ፣ ሕርሻዊ ስነ-ፍልጠታት ወይ ህንጸት ከተማ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('d80df68e-6207-4fcb-8d97-d8a9f9b30469', 'ti', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'እቲ ናይ ንጥፈት ቦታ ኣብ ናይ ደገፍ ዞባ A ወይ B ድዩ (ዓበይቲ ክፋላት Norrland ውሽጣዊ Svealandን)?', '2026-08-28 19:05:47.796108+00'),
	('c1ef277f-a41c-4a83-8170-3d5206131db3', 'ti', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'ኣብ ሽወደን ንመጀመርታ ገዛ እቲ ኣዝዩ ኣድላዪ ንምዕዳግ ዝወሃብ ልቓሕ — ኣቕሑ ገዛ፣ ናውቲ ገዛን ካልእ መሰረታዊ መሳርሕን።', '2026-08-28 19:05:47.796108+00');
INSERT INTO public.kb_translations VALUES
	('d770ca63-7dfc-4b07-9b08-aa15d9e64459', 'ti', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'እቲ ፕሮጀክት ናይ ኢንዱስትሪ ናይ መስርሕ ልቀታት የጕድል ድዩ ወይስ ኣሉታዊ ልቀታት ይፈጥር?', '2026-08-28 19:05:47.796108+00'),
	('c612b9a9-2912-4275-bb11-81b04dea33e5', 'ti', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'ካብ ልደት ክሳብ 16 ዓመት ኣብ ሽወደን ንዝነብሩ ቆልዑ ወርሓዊ ሓገዝ።', '2026-08-28 19:05:47.796108+00'),
	('9bc26d78-5b77-4971-82ba-49e37a1996c3', 'ti', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket ኣብ ዓውዲ ከባቢ ንውድባት፣ ትካላት፣ ማሕበራት፣ ህዝባዊ ጽላትን ውልቀሰባትን ሓገዛት ትህብ።', '2026-08-28 19:05:47.796108+00'),
	('6933fe3c-f2ef-49bc-ae14-1690fe53ff45', 'ti', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'ብወለንታ ናብ ሃገርካ ንሓዋሩ ክትምለስ ትውጥን ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('afb00a2c-e848-45d1-9b85-d5096414a916', 'ti', 'Planerar du att starta eget företag?', 'ናይ ገዛእ ርእስኻ ትካል ክትጅምር ትውጥን ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('59cbca33-b68b-4d51-99d8-d1c9938c6be8', 'ti', 'Planerar du att studera utomlands?', 'ኣብ ወጻኢ ክትመሃር ትውጥን ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('bbbe975c-c155-4715-95f5-98130c14bd70', 'ti', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'ኣብ ዕዳጋ ስራሕ ቦታኻ ዘደልድል ትምህርቲ ትውጥን ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('18abb91a-4a82-4464-ae4d-3a544af1ac0f', 'ti', 'Planerar ni att anställa?', 'ክትቆጽሩ ትውጥኑ ዲኹም?', '2026-08-28 19:05:47.796108+00'),
	('90f3639e-e90c-49dc-8b26-2fb39db92390', 'ti', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'ናይ EU መደብ (ንኣብነት Horisont Europa) ክትሓቱ ትውጥኑ ዲኹም?', '2026-08-28 19:05:47.796108+00'),
	('cd550209-b2ac-4430-b7dc-3e0ca1608f1f', 'ti', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'ንሓጸርቲ ፊልምታትን ዶኩመንታሪታትን ናይ ፍርያትን ምዕባለን ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('78ca5a9e-6463-48a9-84d3-7362340f17a1', 'ti', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'ንናጻ ሙዚቃዊ ህይወት ንኮንሰርታት፣ ፍርያትን ምዕባለን ዝወሃቡ ናይ ፕሮጀክት ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('03a02556-2e4f-4329-8b48-09aed24336f5', 'ti', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'ምስ ቆልዑን መንእሰያትን ንዓኦምን ንዝሰርሓ ዘይመኽሰባውያን ውድባት ዝወሃቡ ናይ ፕሮጀክት ሓገዛት።', '2026-08-28 19:05:47.796108+00'),
	('35dcf734-854b-4651-8f87-73dd38fbe3c6', 'ti', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'እቲ ፕሮጀክት ሓደስቲ ስነ-ጥበባዊ መግለጺታት፣ ኣገባባት ወይ ምትሕብባራት ይፍትን ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('01674468-2d5a-4424-8d6f-a8cf9c0838e8', 'ti', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'እቲ ምልውዋጥ 5–21 መዓልታት (ብዘይ መዓልታት ጕዕዞ) ይጸንሕ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('157f5db7-5176-4a23-b500-5acbe370be91', 'ti', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'ኣብ ጐድኒ ናይ Kulturrådet ሃገራውያን ሓገዛት፣ ናይ ዞባታት ናይ ገዛእ ርእሰን ናይ ፕሮጀክትን ስራሕን ደገፍ ንባህላዊ ህይወት።', '2026-08-28 19:05:47.796108+00'),
	('d2ae9178-0799-49a6-885a-c62063923997', 'ti', 'Riktar sig projektet till barn eller unga?', 'እቲ ፕሮጀክት ንቆልዑ ወይ መንእሰያት ድዩ ዝዓለመ?', '2026-08-28 19:05:47.796108+00'),
	('b4bbb2f1-8966-4391-8479-8eae7302563a', 'ti', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'እቲ ፕሮጀክት ንቆልዑ፣ መንእሰያት፣ ኣረጋውያን ወይ ስንክልና ዘለዎም ሰባት ድዩ ዝዓለመ?', '2026-08-28 19:05:47.796108+00'),
	('5dc5d6c6-8eb2-4584-947c-a76691344ed7', 'ti', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'እቲ ንጥፈት ንቆልዑን መንእሰያትን (7–25 ዓመት) ድዩ ዝዓለመ?', '2026-08-28 19:05:47.796108+00'),
	('60175b12-b947-4bca-87d0-9c7d1476f72a', 'ti', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'ነቶም ወጻኢታት ክሽፍኑ ዝኽእሉ ዕቋር ወይ ንብረት የብልካን ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('8fa66323-11a2-4538-992a-5299fc158a25', 'ti', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'እንተ ወሓደ ምስ ክልተ ካልኦት ሰሜናውያን ሃገራት መሻርኽቲ ትተሓባበሩ ዲኹም?', '2026-08-28 19:05:47.796108+00'),
	('1945c4cf-ec99-4054-b166-64248ad8e77a', 'ti', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'ንናይ ምዕባለ ስጉምቲ ናይ ወጻኢ ክእለት ከተእትዉ ዲኹም?', '2026-08-28 19:05:47.796108+00'),
	('cb809536-c2b7-4764-8c30-af3afaf33aaa', 'ti', 'Sker mobiliteten till ett annat europeiskt land?', 'እቲ ምንቅስቓስ ናብ ካልእ ሃገር ኤውሮጳ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('af19ae71-6c84-42bc-8f96-a9c6f42fae93', 'ti', 'Startar du eller tar du över företaget för första gången?', 'ንመጀመርታ ግዜ ዲኻ እታ ትካል ትጅምር ወይ ትርከብ ዘለኻ?', '2026-08-28 19:05:47.796108+00'),
	('5dc171fb-54fd-4247-be03-04211df272ee', 'ti', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', '40 ዓመት ወይ ካብኡ ንታሕቲ ኮይኑ ሕርሻዊ ትካል ንዝጅምር ወይ ንዝርከብ ዝወሃብ ናይ ምጅማር ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('57de850c-41be-4b47-b6d2-1e84f77a0eb0', 'ti', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'ንሞያውያን ስነ-ጥበበኛታት ኣብ ስነ-ጥበባዊ ስራሖም ከተኵሩ ዘኽእል ስኮላርሺፕ።', '2026-08-28 19:05:47.796108+00'),
	('8e980bc7-b714-4c14-9c34-13ce1e39c859', 'ti', 'Studerar du, eller planerar du att börja studera?', 'ትመሃር ኣለኻ ዲኻ፣ ወይስ ትምህርቲ ክትጅምር ትውጥን?', '2026-08-28 19:05:47.796108+00'),
	('ff94f27a-4dac-4a0d-bea7-b8b492a0b8d0', 'ti', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'ኣብ ዕዳጋ ስራሕ ቦታኦም ንምድልዳል ክመሃሩ ንዝደልዩ ሰራሕተኛታት ዓበይቲ ዝወሃብ ናይ ትምህርቲ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('3aee5e23-95a7-46a3-9f33-8f9c92297488', 'ti', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'ኣብ ሕርሻውያን ትካላት ተወዳዳርነት ዘዕብዩ ወይ ከባብያዊ ጽልዋ ዘጕድሉ ወፍርታት ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('09316cb2-a76f-4c61-a3f7-5dac99122837', 'ti', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'ቆልዓ ምሳኻ ምስ ዝነብር እሞ እቲ ካልእ ወላዲ ቀለብ ምስ ዘይከፍል ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('b15c9cf7-fcd4-476f-a8b0-ed01b517086d', 'ti', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'ንሰባት፣ ከባብን ዝሓሸ ዓለምን ንዝካየዱ ፕሮጀክትታት ዘይመኽሰባውያን ውድባት ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('b71ab566-209b-48d9-8ad1-b24f0de9600b', 'ti', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'ናብ ዜሮ ልቀት ጋዛት ግሪንሃውስ ንዝግበር ምስግጋር ኢንዱስትሪ ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('07c1e23c-c55b-4834-961b-b7c67a4a9705', 'ti', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'ሰሜናዊ መልክዕን ዶብ ሰጊሩ ዝግበር ምትሕብባርን ንዘለዎም ፕሮጀክትታት ስነ-ጥበብን ባህልን ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('eeea83d3-6f63-4aaa-ad31-cef680872a60', 'ti', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'ሓደስቲ ስነ-ጥበባዊ መግለጺታት፣ ኣገባባት ወይ ምትሕብባራት ንዝፍትኑ ሓደስቲ ባህላውያን ፕሮጀክትታት ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('53caa8ac-4e70-483c-bf96-f194bc3cdc4a', 'ti', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'ንቆልዑ፣ መንእሰያት፣ ኣረጋውያንን ስንክልና ዘለዎም ሰባትን ንዝካየዱ ሓደስቲ ፕሮጀክትታት ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('e763b980-955d-4b55-b0bb-ad13c5697284', 'ti', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'ኣብ ናጻ ሙዚቃዊ ህይወት ንፕሮጀክትታት ምትሕብባር ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('d579b874-a9b3-4375-9c14-c779cfeb4c1d', 'ti', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'ዲሞክራስን ናጽነት ሓሳብን ብኣህጉራዊ ደረጃ ንዘደልድሉ ፕሮጀክትታት ምትሕብባር ኣብ ባህልን ሚድያን ዝወሃብ ደገፍ።', '2026-08-28 19:05:47.796108+00'),
	('f2e0b001-7849-46c3-bc8f-9a4ac89dce68', 'ti', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'እቲ ፕሮጀክት ዲሞክራሲ፣ ማዕርነት ወይ ናጽነት ሓሳብ ንምድልዳል ድዩ ዝዓለመ?', '2026-08-28 19:05:47.796108+00'),
	('d8b9f041-1da9-46ac-814e-61a787d0ebca', 'ti', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'ኣብ ካልእ ሃገር EU ወይ EES ስራሕ ትደሊ ኣለኻ፣ ወይ ናይ ስራሕ ውዕል ተዋሂቡካ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('0aa14600-583d-4899-8bc6-384150472304', 'ti', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'ኣብ ውሽጢ ዓሰርተ ክልተ ኣዋርሕ ብናይ ሕሙም ክፍሊታት እትኸፍሎ ጣርያ — ድሕሪኡ frikort (ነጻ ካርድ)።', '2026-08-28 19:05:47.796108+00'),
	('e0b51ccd-4b48-426a-9e92-170b61f2629d', 'ti', 'Tar du ut hel allmän pension?', 'ምሉእ ሃገራዊ ጡረታኻ ትወስድ ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('ddf9d424-e225-4753-9529-1e0b7cecdba5', 'ti', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'ጡረታን ትሑት ኣታውን ንዘለዎም ክፋል ወጻኢታት መንበሪ ዝሽፍን ተወሳኺ።', '2026-08-28 19:05:47.796108+00'),
	('0a3f7fb2-663d-48d2-a5b7-4f40f87970a2', 'ti', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'ንሃገራውያን ውድባት ቆልዑን መንእሰያትን ዓመታዊ ናይ ውድብ ሓገዝ።', '2026-08-28 19:05:47.796108+00'),
	('ed254b58-5361-4cb5-9dea-de4e1360b696', 'ti', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'ኣብ ሓኪም ስኒ ወይ ክኢላ ጽሬት ስኒ ብቐጥታ ዝቕነስ ዓመታዊ ሕሳብ።', '2026-08-28 19:05:47.796108+00'),
	('4d96117a-b411-4eab-819e-45a5ad1c46b9', 'ti', 'Är bolaget yngre än cirka 5 år?', 'እታ ትካል ካብ ኣስታት 5 ዓመት ንታሕቲ ድያ?', '2026-08-28 19:05:47.796108+00'),
	('2e89cdc4-90e6-49f1-b27a-fb755ca11e7c', 'ti', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'ተሳተፍቲ እቲ ምልውዋጥ ኣብ መንጎ 13ን 30ን ዓመት ድዮም?', '2026-08-28 19:05:47.796108+00'),
	('4b89bf62-2c74-46ac-a4c4-95dba6fa66f5', 'ti', 'Är det här ert första EU-projekt?', 'እዚ ናይ መጀመርታ ናይ EU ፕሮጀክትኩም ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('40805743-3efd-40ee-a8a6-f33153717047', 'ti', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'ንዓኻ (ወይ ንውሉድካ) በይንኻ ምንቅስቓስ ወይ ብኣውቶቡስን ባቡርን ምጕዓዝ ኣዝዩ ኣጸጋሚ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('9c428271-b327-40d2-afed-2f203dbf303a', 'ti', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'ኣታዊኻ ካብ ኣስታት 25 000 kr ኣብ ወርሒ ቅድሚ ግብሪ ዝወሓደ ድዩ?', '2026-08-28 19:05:47.796108+00'),
	('f3316909-6c0d-4e35-8d36-8d375b2194a2', 'ti', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'ናይ መወዳእታ ዝወዳእካዮ ትምህርቲ መባእታ ድዩ፣ ወይስ ዘይወዳእካዮ ካልኣይ ደረጃ?', '2026-08-28 19:05:47.796108+00'),
	('3fb268a4-1ccd-4ce7-a9a6-98f0c2bd6a55', 'ti', 'Är du 40 år eller yngre?', '40 ዓመት ወይ ካብኡ ንታሕቲ ዲኻ?', '2026-08-28 19:05:47.796108+00');
INSERT INTO public.kb_translations VALUES
	('a7493cf9-752b-4c51-b76c-beb5f35da6af', 'ti', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'ኣብ Arbetsförmedlingen ከም ደላዪ ስራሕ ተመዝጊብካ ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('9c49cc7d-b572-4212-87d1-06bbe41ea926', 'ti', 'Är du mellan 18 och 28 år?', 'ኣብ መንጎ 18ን 28ን ዓመት ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('d7c85a91-ed00-4bc0-a36a-51997a1eb13b', 'ti', 'Är du mellan 19 och 29 år?', 'ኣብ መንጎ 19ን 29ን ዓመት ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('80ef5a5f-dd4b-495f-8458-b9e43b6c0d5f', 'ti', 'Är du mellan 25 och 60 år?', 'ኣብ መንጎ 25ን 60ን ዓመት ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('edc3a18f-72b7-457b-bb1d-8cb478b31ff3', 'ti', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'ኣብ ዓውዲ ባህሊ ብሞያ ትሰርሕ ዲኻ (ንኣብነት ሳዕስዒት፣ ሙዚቃ፣ ስነ-ጥበብ መድረኽ)?', '2026-08-28 19:05:47.796108+00'),
	('19d46e45-d3c0-48bd-bd9c-bda87343be5f', 'ti', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'ሞያዊ ስነ-ጥበበኛ ዲኻ (ዘይ ሃዋርያ ወይ ኣብ መሰረታዊ ስልጠና ዘሎ)?', '2026-08-28 19:05:47.796108+00'),
	('ed1629f1-fe0a-4c9d-8514-c138cda3f9de', 'ti', 'Är du yrkesverksam konstnär?', 'ሞያዊ ስነ-ጥበበኛ ዲኻ?', '2026-08-28 19:05:47.796108+00'),
	('15411dd4-cc1f-4014-9beb-7d0bab6080c6', 'ti', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'ፍታሕኩም ምስቲ ድሮ ዘሎ ክወዳደር ከሎ ብመሰረቱ ሓድሽ ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('f0cc5a4f-5166-4b0b-b618-fec5dcd53fd4', 'ti', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'እቲ ክለብ ኣብ ውሽጢ Riksidrottsförbundet ናብ ፍሉይ ስፖርታዊ ፌደሬሽን ዝተጸምበረ ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('605efee4-9ec8-480e-aeb1-80f6c95fa3ca', 'ti', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'ኣታዊ እታ ስድራቤት ምስ ወጻኢታት መንበሪ ክወዳደር ከሎ ትሑት ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('1c4c27ca-d6ba-4698-bd5a-ec4fc2e910fe', 'ti', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'ጠቕላላ ኣታዊ እታ ስድራቤት ካብ ኣስታት 25 000 kr ኣብ ወርሒ ቅድሚ ግብሪ ዝወሓደ ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('173623eb-d509-447a-b83d-74ba8d418bd1', 'ti', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'እቲ ስጉምቲ ዝተወሰነ ፕሮጀክት ድዩ (ዘይ ስሩዕ ንጥፈት)?', '2026-08-28 19:05:47.799665+00'),
	('c69a2416-09cc-4a77-83d8-ecc54151ec7c', 'ti', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'እቲ ኣዳራሽ ንኹሉ ክፉት ድዩ — ዘይ ንኣባላትኩም ጥራይ?', '2026-08-28 19:05:47.799665+00'),
	('592a7479-7a93-46f8-b119-784b9921c262', 'ti', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'እንተ ወሓደ 60 % ካብቶም ኣባላት ኣብ መንጎ 6ን 25ን ዓመት ድዮም?', '2026-08-28 19:05:47.799665+00'),
	('de589e98-3d8f-4800-815f-0af393a15573', 'ti', 'Är minst 60 % av medlemmarna under 26 år?', 'እንተ ወሓደ 60 % ካብቶም ኣባላት ትሕቲ 26 ዓመት ድዮም?', '2026-08-28 19:05:47.799665+00'),
	('fe011d46-2a08-4ce7-9a59-d5534c849f4a', 'ti', 'Är målgruppen delaktig i planering och genomförande?', 'እታ ዕላማ ዝኾነት ጕጅለ ኣብ ውጥንን ትግባረን ትሳተፍ ድያ?', '2026-08-28 19:05:47.799665+00'),
	('8f875e62-8db7-416a-a3b5-92564485cf0b', 'ti', 'Är ni ett förlag med professionell utgivning?', 'ሞያዊ ሕትመት ዘለዎ ኣሕታሚ ዲኹም?', '2026-08-28 19:05:47.799665+00'),
	('289b2d94-92e2-4930-9e5c-05b4d83e3964', 'ti', 'Är ni huvudman för förskoleklass eller grundskola?', 'ሓላፊ ናይ ቅድመ-ትምህርቲ ክፍሊ ወይ መባእታ ቤት-ትምህርቲ ዲኹም?', '2026-08-28 19:05:47.799665+00'),
	('d17b5ba1-4d16-40ce-85dc-a1d2a0914225', 'ti', 'Är organisationen registrerad i EU:s deltagarregister?', 'እቲ ውድብ ኣብ ናይ EU መዝገብ ተሳተፍቲ ተመዝጊቡ ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('f3afe015-cac3-4319-95b5-137679d7c11a', 'ti', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'እቲ ፕሮጀክት ናይ ፊልም ፕሮጀክት ድዩ (ሓጻር ፊልም ወይ ዶኩመንታሪ)?', '2026-08-28 19:05:47.799665+00'),
	('699a8af7-11ef-4faf-af98-3994dc21a9e7', 'ti', 'Är projektet ett konst- eller kulturprojekt?', 'እቲ ፕሮጀክት ናይ ስነ-ጥበብ ወይ ባህሊ ፕሮጀክት ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('988b10ca-54b0-40a7-88ff-ee2669e7ba27', 'ti', 'Är projektet ett kulturprojekt?', 'እቲ ፕሮጀክት ባህላዊ ፕሮጀክት ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('aa40a36b-2762-459a-90f0-53b6d8855793', 'ti', 'Är projektet ett musikprojekt?', 'እቲ ፕሮጀክት ሙዚቃዊ ፕሮጀክት ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('71b09e47-c944-4737-91de-55c2c029f6fc', 'ti', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'እቲ ፕሮጀክት ሓድሽ ድዩ — ኣብ ስሩዕ ንጥፈትኩም ዘይትገብርዎ ነገር?', '2026-08-28 19:05:47.799665+00'),
	('d2ea21c5-7a85-454d-b630-67be127a5637', 'ti', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'እቲ ፕሮጀክት ንብምሉኡ እቲ ከባቢ ይጠቅም ድዩ (ዘይ ንውልቀሰባት)?', '2026-08-28 19:05:47.799665+00'),
	('913fcc81-f2dd-40f1-8a48-af6dadfd086f', 'ti', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'እቲ ኣብ መንጎ ገዛን ካልኣይ ደረጃ ቤት-ትምህርትን ዘሎ መገዲ እንተ ወሓደ ሽዱሽተ ኪሎሜተር ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('b1508bda-cabc-45da-9a59-3e3e0029a3f8', 'ti', 'Är verksamheten professionell (inte amatörverksamhet)?', 'እቲ ንጥፈት ሞያዊ ድዩ (ዘይ ናይ ሃዋርያ)?', '2026-08-28 19:05:47.799665+00'),
	('6e6abbb4-185e-42fa-89fc-516c2e676570', 'ti', 'Är verksamheten professionell?', 'እቲ ንጥፈት ሞያዊ ድዩ?', '2026-08-28 19:05:47.799665+00'),
	('fc0d2787-5a6f-427a-b6c3-5809e9d2e4c6', 'ti', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'እቲ ንጥፈት ስነ-ጥበብ መድረኽ ድዩ (ሳዕስዒት፣ ትያትር፣ ሙዚቃዊ ትያትር)?', '2026-08-28 19:05:47.799665+00'),
	('9b113cb7-6c6f-4a4a-8b2a-433063ce45bd', 'ti', 'Är volontärerna mellan 18 och 30 år?', 'እቶም ወለንተኛታት ኣብ መንጎ 18ን 30ን ዓመት ድዮም?', '2026-08-28 19:05:47.799665+00');


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
	('6fc16817-ff85-4696-bd8d-eacea52402cf', 'bd265af5-d31d-47ef-b64d-ae35aa93362a', 1, '[{"id": "kr-rb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-rb-h2", "op": "in", "kind": "hard", "expected": ["individual", "association", "company"], "factPath": "applicant.type", "description": "Sökande ska vara yrkesverksam kulturskapare, grupp eller organisation"}, {"id": "kr-rb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam inom kulturområdet", "evidenceKinds": ["cv"], "intakeQuestion": "Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?"}, {"id": "kr-rb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska avse internationellt kulturutbyte", "evidenceKinds": ["invitation"], "intakeQuestion": "Innehåller projektet en internationell resa eller ett internationellt utbyte?"}, {"id": "kr-rb-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Kulturprojekt"}, {"id": "kr-rb-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}, {"id": "kr-rb-w3", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "project.bringsKnowledgeBack", "description": "Kunskapen tas tillvara i Sverige", "intakeQuestion": "Kommer erfarenheterna att användas i din verksamhet i Sverige?"}]', '[{"id": "kr-rb-b1", "type": "max_requested", "amountMinor": 5000000, "description": "Sökt belopp bör inte överstiga 50 000 kr för resebidrag."}]', '[{"id": "kr-rb-e1", "kind": "cv", "mandatory": true, "description": "CV eller konstnärlig meritförteckning"}, {"id": "kr-rb-e2", "kind": "invitation", "mandatory": true, "description": "Inbjudan eller bekräftelse från mottagande part"}, {"id": "kr-rb-e3", "kind": "budget", "mandatory": false, "description": "Resebudget"}]', '2026-08-28 19:05:47.172122+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.172122+00'),
	('7888917f-1645-4e04-a6c2-64dca560b859', '7de4b8a9-195b-4254-b82b-11d5969f2e97', 1, '[{"id": "er-yx-h1", "op": "in", "kind": "hard", "expected": ["association", "informal_group", "municipality"], "factPath": "applicant.type", "description": "Sökande ska vara en organisation eller informell ungdomsgrupp"}, {"id": "er-yx-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska nationella programkontoret"}, {"id": "er-yx-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge13to30", "description": "Deltagarna ska vara 13–30 år", "intakeQuestion": "Är deltagarna i utbytet mellan 13 och 30 år?"}, {"id": "er-yx-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.durationDays5to21", "description": "Utbytet ska vara 5–21 dagar exklusive resdagar", "intakeQuestion": "Pågår utbytet 5–21 dagar (exklusive resdagar)?"}, {"id": "er-yx-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partnergrupp i ett annat programland krävs", "intakeQuestion": "Har ni en partnergrupp i ett annat land?"}, {"id": "er-yx-m4", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID (Organisation ID)", "intakeQuestion": "Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?"}, {"id": "er-yx-w1", "op": "includes", "kind": "weighted", "weight": 3, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}, {"id": "er-yx-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training"], "factPath": "project.activityTypes", "description": "Utbytes-/lärandeaktiviteter"}, {"id": "er-yx-w3", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "er-yx-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från partnergrupp(er)"}, {"id": "er-yx-e2", "kind": "activity_programme", "mandatory": true, "description": "Aktivitetsprogram dag för dag"}, {"id": "er-yx-e3", "kind": "budget", "mandatory": false, "description": "Budget enligt programmets schabloner"}]', '2026-08-28 19:05:47.179442+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.179442+00'),
	('814cecd0-3b11-43f7-b5a5-7259f5ec28a0', 'af44e2ea-2fdf-483f-8220-8e0cd6284d42', 1, '[{"id": "mucf-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara verksam i Sverige"}, {"id": "mucf-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska ha en demokratisk uppbyggnad", "intakeQuestion": "Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?"}, {"id": "mucf-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Projektet ska rikta sig till barn eller unga", "intakeQuestion": "Riktar sig projektet till barn eller unga?"}, {"id": "mucf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["youth", "civil_society", "culture"], "factPath": "project.sector", "description": "Verksamhet inom ungdoms-/civilsamhällesområdet"}, {"id": "mucf-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.youthMembersShareOver60", "description": "Hög andel unga medlemmar", "intakeQuestion": "Är minst 60 % av medlemmarna under 26 år?"}]', '[]', '[{"id": "mucf-e1", "kind": "stadgar", "mandatory": true, "description": "Föreningens stadgar"}, {"id": "mucf-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse och årsredovisning"}, {"id": "mucf-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 19:05:47.185518+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.185518+00'),
	('224af18f-dd5e-460d-ba78-9e0b7f1d415d', 'db95c200-883b-4831-8ae4-32d0920f47df', 1, '[{"id": "vin-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett aktiebolag"}, {"id": "vin-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "vin-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.ageYearsMax5", "description": "Bolaget ska vara ungt (typiskt max ca 5 år — se aktuell utlysning)", "intakeQuestion": "Är bolaget yngre än cirka 5 år?"}, {"id": "vin-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isInnovative", "description": "Lösningen ska vara nyskapande jämfört med befintliga alternativ", "intakeQuestion": "Är er lösning väsentligt nyskapande jämfört med vad som redan finns?"}, {"id": "vin-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.scalableInternationally", "description": "Internationell skalbarhet", "intakeQuestion": "Har lösningen internationell potential?"}, {"id": "vin-w2", "op": "in", "kind": "weighted", "weight": 1, "expected": ["innovation", "technology", "energy", "health"], "factPath": "project.sector", "description": "Prioriterade områden"}]', '[{"id": "vin-b1", "type": "max_requested", "amountMinor": 30000000, "description": "Maximalt bidrag enligt programmets ramar (se aktuell utlysning)."}]', '[{"id": "vin-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "vin-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}, {"id": "vin-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelpersoner"}]', '2026-08-28 19:05:47.191459+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.191459+00'),
	('18d3ccce-a1e1-4cfe-9ada-32ec2d8734ff', 'b20a46a6-bffc-4d54-8ff8-d86276fcf5fc', 1, '[{"id": "pm-afs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "pm-afs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-afs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Du ska ha uppnått riktåldern för pension (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}, {"id": "pm-afs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.veryLowOrNoPension", "description": "Pension och inkomster ska inte räcka till en skälig levnadsnivå", "intakeQuestion": "Har du svårt att klara dig på din pension och dina övriga inkomster?"}]', '[]', '[]', '2026-08-28 19:05:47.390974+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.390974+00'),
	('c477fe27-47a6-4f34-a1e9-2a79ac6caece', 'dc3ad4d7-8317-48e5-bf45-124fa60aba6b', 1, '[{"id": "em-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "em-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association", "economic_association"], "factPath": "applicant.type", "description": "Öppet för organisationer — inte privatpersoner"}, {"id": "em-m1", "op": "in", "kind": "mandatory", "expected": ["energy", "environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom energiområdet", "intakeQuestion": "Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?"}, {"id": "em-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.contributesToEnergyTransition", "description": "Bidrar till energiomställningen", "intakeQuestion": "Bidrar projektet till energiomställningen?"}]', '[]', '[{"id": "em-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "em-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget med kostnadskategorier"}]', '2026-08-28 19:05:47.197038+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.197038+00'),
	('cae9796b-1c1b-4df6-a6eb-ee0c0c60afcd', 'ceb42f7b-50cf-412b-b657-c17fb34a1670', 1, '[{"id": "nv-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "nv-m1", "op": "in", "kind": "mandatory", "expected": ["environment", "energy"], "factPath": "project.sector", "description": "Projektet ska avse miljö- eller klimatåtgärder", "intakeQuestion": "Handlar projektet om miljö- eller klimatåtgärder?"}, {"id": "nv-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.measurableEnvironmentalImpact", "description": "Mätbar miljönytta", "intakeQuestion": "Kan projektets miljönytta mätas?"}]', '[{"id": "nv-b1", "type": "max_funding_share", "percent": 50, "description": "Många av bidragen täcker upp till 50 % av kostnaden — se aktuellt bidrag."}]', '[{"id": "nv-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av åtgärden"}]', '2026-08-28 19:05:47.205718+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.205718+00'),
	('1376db7c-290a-4412-b54d-e1442edde20e', 'ca268aa9-7310-4769-ba9a-36aa0deb1e23', 1, '[{"id": "kr-pm-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-pm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell verksamhet inom musikområdet", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-pm-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kr-pm-w1", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["performance", "production"], "factPath": "project.activityTypes", "description": "Konsert-/produktionsverksamhet"}]', '[]', '[{"id": "kr-pm-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kr-pm-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 19:05:47.211787+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.211787+00'),
	('183c3313-bcf8-4000-a54a-e1d0689efceb', '68ad80de-f7af-44ed-bad3-55f51c8b3377', 1, '[{"id": "kn-iku-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av enskilda yrkesverksamma konstnärer"}, {"id": "kn-iku-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-iku-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?"}, {"id": "kn-iku-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Ansökan ska avse internationellt utbyte eller resa", "evidenceKinds": ["invitation"], "intakeQuestion": "Avser ansökan en internationell resa eller ett internationellt utbyte?"}, {"id": "kn-iku-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Konstnärligt projekt"}, {"id": "kn-iku-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}]', '[]', '[{"id": "kn-iku-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-iku-e2", "kind": "invitation", "mandatory": false, "description": "Inbjudan eller beskrivning av samarbetet"}]', '2026-08-28 19:05:47.218901+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.218901+00'),
	('3e6da4c3-46a2-45da-b0cd-9aabde1f646f', 'd67f3673-e33d-456c-a45b-976af2fb0880', 1, '[{"id": "kn-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stipendiet söks av enskilda konstnärer"}, {"id": "kn-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär?"}, {"id": "kn-as-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "culture", "factPath": "project.sector", "description": "Konstnärlig verksamhet"}]', '[]', '[{"id": "kn-as-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-as-e2", "kind": "project_description", "mandatory": true, "description": "Beskrivning av konstnärlig verksamhet och planer"}]', '2026-08-28 19:05:47.224355+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.224355+00'),
	('9b1159aa-056a-4050-90df-e61c1a6bdaeb', 'b5dc8e07-05f0-4313-b71b-3d8b1f8fd1cd', 1, '[{"id": "af-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara en ideell organisation"}, {"id": "af-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "af-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.targetsArvsfondenGroups", "description": "Målgruppen ska vara barn, unga, äldre eller personer med funktionsnedsättning", "intakeQuestion": "Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?"}, {"id": "af-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande i förhållande till ordinarie verksamhet", "intakeQuestion": "Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?"}, {"id": "af-ps-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.targetGroupParticipates", "description": "Målgruppen ska vara delaktig i projektet", "intakeQuestion": "Är målgruppen delaktig i planering och genomförande?"}, {"id": "af-ps-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga som målgrupp"}, {"id": "af-ps-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.democraticStructure", "description": "Demokratiskt uppbyggd organisation", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}]', '[]', '[{"id": "af-ps-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "af-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning/verksamhetsberättelse"}, {"id": "af-ps-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 19:05:47.230171+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.230171+00'),
	('fe091ab4-d199-4fb0-ad58-89f7916fc58e', '8ae331d3-fc63-4bbb-82a1-cb5088109734', 1, '[{"id": "bv-as-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara förening eller stiftelse"}, {"id": "bv-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Lokalen ska ligga i Sverige"}, {"id": "bv-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.isPublicVenue", "description": "Lokalen ska vara öppen och tillgänglig för allmänheten", "intakeQuestion": "Är lokalen öppen för alla — inte bara egna medlemmar?"}, {"id": "bv-as-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse investering (bygga, köpa eller rusta upp)", "intakeQuestion": "Avser projektet att bygga, köpa eller rusta upp en lokal?"}, {"id": "bv-as-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamhet för ungdomar prioriteras"}]', '[{"id": "bv-as-b1", "type": "max_funding_share", "percent": 50, "description": "Bidraget täcker som huvudregel högst 50 % av godkänd kostnad."}]', '[{"id": "bv-as-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av lokalen och åtgärderna"}, {"id": "bv-as-e2", "kind": "budget", "mandatory": true, "description": "Kostnadskalkyl och finansieringsplan"}]', '2026-08-28 19:05:47.235709+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.235709+00'),
	('75bb0ad8-9bbd-4399-850d-a8b02240bac3', '2d9fbfd5-ae38-441d-89ac-aa02ae23f34b', 1, '[{"id": "rf-lok-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en idrottsförening"}, {"id": "rf-lok-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "rf-lok-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.memberOfSportsFederation", "description": "Föreningen ska vara ansluten till ett specialidrottsförbund inom RF", "intakeQuestion": "Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?"}, {"id": "rf-lok-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamheten ska rikta sig till barn och unga 7–25 år", "intakeQuestion": "Riktar sig verksamheten till barn och unga (7–25 år)?"}, {"id": "rf-lok-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "sports", "factPath": "project.sector", "description": "Idrottsverksamhet"}]', '[]', '[{"id": "rf-lok-e1", "kind": "activity_programme", "mandatory": true, "description": "Närvaroregistrerad aktivitetsredovisning"}]', '2026-08-28 19:05:47.241526+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.241526+00'),
	('f814b2ac-f4e5-4d34-9534-3edd34304888', 'c7c974ed-19c6-4236-932e-c313ddaff86a', 1, '[{"id": "sfi-kf-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Stödet söks av ett produktionsbolag"}, {"id": "sfi-kf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "sfi-kf-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett filmprojekt", "intakeQuestion": "Är projektet ett filmprojekt (kort- eller dokumentärfilm)?"}, {"id": "sfi-kf-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "production", "factPath": "project.activityTypes", "description": "Produktion/utveckling"}]', '[]', '[{"id": "sfi-kf-e1", "kind": "project_description", "mandatory": true, "description": "Synopsis/treatment och regivision"}, {"id": "sfi-kf-e2", "kind": "budget", "mandatory": true, "description": "Produktionsbudget och finansieringsplan"}, {"id": "sfi-kf-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelfunktioner"}]', '2026-08-28 19:05:47.247154+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.247154+00'),
	('7b14ad1c-b414-4e41-80d6-1fba8d32f387', '9b083b0a-67aa-4540-bd3e-0676600e1de9', 1, '[{"id": "kr-ss-h1", "op": "in", "kind": "hard", "expected": ["municipality", "school", "company"], "factPath": "applicant.type", "description": "Sökande ska vara skolhuvudman"}, {"id": "kr-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSchoolAuthority", "description": "Sökande ska vara huvudman för förskoleklass/grundskola", "intakeQuestion": "Är ni huvudman för förskoleklass eller grundskola?"}, {"id": "kr-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.usesProfessionalCulture", "description": "Insatserna ska genomföras av professionella kulturaktörer", "intakeQuestion": "Genomförs insatserna av professionella kulturaktörer?"}, {"id": "kr-ss-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Elever som målgrupp"}]', '[]', '[{"id": "kr-ss-e1", "kind": "project_description", "mandatory": true, "description": "Plan för kulturinsatserna"}, {"id": "kr-ss-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 19:05:47.25228+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.25228+00'),
	('c04f7fdc-b59c-4a53-953b-1f12d18f176a', '83578d3a-2a6d-4262-ba0f-4a122d9bdf95', 1, '[{"id": "fo-ou-h1", "op": "in", "kind": "hard", "expected": ["university", "public_body"], "factPath": "applicant.type", "description": "Medlen förvaltas av lärosäte eller forskningsinstitut"}, {"id": "fo-ou-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Medelsförvaltaren ska vara svensk"}, {"id": "fo-ou-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "fo-ou-m2", "op": "in", "kind": "mandatory", "expected": ["environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom Formas ansvarsområden", "intakeQuestion": "Ligger projektet inom miljö, areella näringar eller samhällsbyggande?"}]', '[]', '[{"id": "fo-ou-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "fo-ou-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}, {"id": "fo-ou-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 19:05:47.257867+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.257867+00'),
	('161a5cbe-1fa3-4937-8aca-168e41aa0854', 'd8df3387-7585-4e66-a5b4-6a9e88af9204', 1, '[{"id": "fk-fp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-fp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha (eller vänta) barn som du avstår arbete för att ta hand om", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 19:05:47.559409+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.559409+00'),
	('c85564f3-bb46-4224-9997-4affca685161', 'c27ea324-63d0-4d09-bb82-ece7b5b489da', 1, '[{"id": "tv-ac-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett företag"}, {"id": "tv-ac-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Företaget ska vara registrerat i Sverige"}, {"id": "tv-ac-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSmallEnterprise", "description": "Företaget ska vara litet (typiskt 2–49 anställda — se regionens villkor)", "intakeQuestion": "Har företaget mellan cirka 2 och 49 anställda?"}, {"id": "tv-ac-m2", "op": "includes", "kind": "mandatory", "expected": "development", "factPath": "project.activityTypes", "description": "Checken ska användas för utvecklingsinsats med extern kompetens", "intakeQuestion": "Ska ni ta in extern kompetens för en utvecklingsinsats?"}, {"id": "tv-ac-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.scalableInternationally", "description": "Internationaliseringsambition"}]', '[{"id": "tv-ac-b1", "type": "max_funding_share", "percent": 50, "description": "Checken täcker normalt högst 50 % av kostnaden."}]', '[{"id": "tv-ac-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av utvecklingsinsatsen"}, {"id": "tv-ac-e2", "kind": "budget", "mandatory": true, "description": "Kostnads- och finansieringsplan"}]', '2026-08-28 19:05:47.263732+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.263732+00'),
	('766e45b5-d01b-4aca-88ab-dc9aac1ef014', '5f0a8992-a4cc-439b-8f1d-a633a7a927cf', 1, '[{"id": "jv-ss-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-ss-h2", "op": "in", "kind": "hard", "expected": ["individual", "company"], "factPath": "applicant.type", "description": "Söks av person eller företag"}, {"id": "jv-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age40OrYounger", "description": "Sökande ska vara 40 år eller yngre", "intakeQuestion": "Är du 40 år eller yngre?"}, {"id": "jv-ss-m2", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Ansökan ska avse jordbruks-, trädgårds- eller rennäringsföretag", "intakeQuestion": "Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?"}, {"id": "jv-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.startingOrTakingOverFarm", "description": "Sökande ska starta eller ta över företaget för första gången", "intakeQuestion": "Startar du eller tar du över företaget för första gången?"}]', '[]', '[{"id": "jv-ss-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}, {"id": "jv-ss-e2", "kind": "budget", "mandatory": true, "description": "Ekonomisk kalkyl"}]', '2026-08-28 19:05:47.269234+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.269234+00'),
	('3483791e-9cd1-4a5f-af50-c49044d1033b', 'f8d08a0c-0441-4056-b78c-c9cd4bf46fa5', 1, '[{"id": "jv-is-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-is-m1", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Investeringen ska avse jordbruksverksamhet", "intakeQuestion": "Avser investeringen jordbruksverksamhet?"}, {"id": "jv-is-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en fysisk investering?"}]', '[{"id": "jv-is-b1", "type": "max_funding_share", "percent": 40, "description": "Stödandelen är typiskt upp till 40 % av godkänd kostnad — se aktuellt stöd."}]', '[{"id": "jv-is-e1", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl med offerter"}]', '2026-08-28 19:05:47.274259+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.274259+00'),
	('b6f411f6-fc9a-4b61-9221-9b3013ca891a', 'e7025e12-9ea0-4cf0-ba68-c23b1b9e8cf7', 1, '[{"id": "esf-ku-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "esf-ku-h2", "op": "in", "kind": "hard", "expected": ["company", "association", "municipality", "region", "public_body", "university"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "esf-ku-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensLabourMarket", "description": "Projektet ska stärka kompetens eller ställning på arbetsmarknaden", "intakeQuestion": "Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?"}, {"id": "esf-ku-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Sökande ska klara att förskottera kostnader (stöd betalas ut i efterskott)", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[{"id": "esf-ku-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med förändringsteori"}, {"id": "esf-ku-e2", "kind": "budget", "mandatory": true, "description": "Detaljerad projektbudget"}]', '2026-08-28 19:05:47.279648+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.279648+00'),
	('f40fd884-1c28-4521-a3a6-7b9913e8751b', '1bcfc883-6093-466a-bf78-5a177218d0b4', 1, '[{"id": "em-ik-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "em-ik-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "em-ik-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.reducesIndustrialEmissions", "description": "Projektet ska minska industrins utsläpp eller skapa negativa utsläpp", "intakeQuestion": "Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?"}, {"id": "em-ik-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["energy", "environment"], "factPath": "project.sector", "description": "Energi-/klimatprojekt"}]', '[]', '[{"id": "em-ik-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med utsläppsberäkning"}, {"id": "em-ik-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 19:05:47.284879+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.284879+00'),
	('9e3c2e61-7f51-4dcc-8613-60cc30ba2feb', 'df7edb7e-d12a-4f36-bed7-b4a07c6cec51', 1, '[{"id": "pm-bt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget söks av privatpersoner"}, {"id": "pm-bt-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-bt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.receivesPension", "description": "Du ska ta ut hel allmän pension", "intakeQuestion": "Tar du ut hel allmän pension?"}, {"id": "pm-bt-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Inkomsterna ska vara låga i förhållande till boendekostnaden", "intakeQuestion": "Är hushållets inkomster låga i förhållande till boendekostnaden?"}, {"id": "pm-bt-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 19:05:47.386451+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.386451+00'),
	('70be0db9-1554-4ec0-951d-444e8ce1d421', '8ba650c8-c0e3-415f-bec5-21d25efa64a5', 1, '[{"id": "nv-kk-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Åtgärden ska genomföras i Sverige"}, {"id": "nv-kk-h2", "op": "in", "kind": "hard", "expected": ["company", "municipality", "region", "association", "economic_association", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "nv-kk-m1", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Stödet avser fysiska investeringar", "intakeQuestion": "Avser ansökan en fysisk investering?"}, {"id": "nv-kk-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.measurableEnvironmentalImpact", "description": "Klimatnyttan ska kunna beräknas", "intakeQuestion": "Kan åtgärdens utsläppsminskning beräknas?"}]', '[]', '[{"id": "nv-kk-e1", "kind": "project_description", "mandatory": true, "description": "Åtgärdsbeskrivning med klimatnyttoberäkning"}, {"id": "nv-kk-e2", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl"}]', '2026-08-28 19:05:47.290399+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.290399+00'),
	('85aa27a3-fabf-4e39-a4a1-4d399b4fb486', 'eed373fb-4bfa-4f65-9437-9152403b4266', 1, '[{"id": "nv-lona-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Formell sökande är en kommun (föreningar deltar via kommunen)"}, {"id": "nv-lona-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "nv-lona-m1", "op": "eq", "kind": "mandatory", "expected": "environment", "factPath": "project.sector", "description": "Projektet ska avse naturvård eller friluftsliv", "intakeQuestion": "Avser projektet naturvård eller friluftsliv?"}]', '[{"id": "nv-lona-b1", "type": "max_funding_share", "percent": 50, "description": "Högst 50 % bidrag (våtmarksprojekt kan få upp till 90 % — se villkoren)."}]', '[{"id": "nv-lona-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 19:05:47.295412+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.295412+00'),
	('fcce3646-2be5-4ef6-8b1c-6d9ecffe6298', '13e01367-6210-4cf6-aecc-89f98fc1bf3a', 1, '[{"id": "mucf-esc-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "mucf-esc-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "mucf-esc-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "mucf-esc-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasQualityLabel", "description": "Organisationen behöver en Quality Label för solidaritetskåren", "intakeQuestion": "Har organisationen en Quality Label (kvalitetsmärkning)?"}, {"id": "mucf-esc-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge18to30", "description": "Volontärerna ska vara 18–30 år", "intakeQuestion": "Är volontärerna mellan 18 och 30 år?"}, {"id": "mucf-esc-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}, {"id": "mucf-esc-w2", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}]', '[]', '[{"id": "mucf-esc-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med aktivitetsplan"}, {"id": "mucf-esc-e2", "kind": "partner_letter", "mandatory": false, "description": "Bekräftelse från partnerorganisation(er)"}]', '2026-08-28 19:05:47.300772+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.300772+00'),
	('d22e9911-71b0-444d-b6bd-b15c38df3839', 'f3562a14-d093-4de5-9114-2fc93393517f', 1, '[{"id": "er-ka1-h1", "op": "in", "kind": "hard", "expected": ["school", "municipality", "company", "association", "public_body"], "factPath": "applicant.type", "description": "Söks av utbildningsorganisationer/huvudmän"}, {"id": "er-ka1-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "er-ka1-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "er-ka1-m2", "op": "eq", "kind": "mandatory", "expected": "education", "factPath": "project.sector", "description": "Projektet ska avse utbildningsverksamhet", "intakeQuestion": "Avser projektet skola eller vuxenutbildning?"}, {"id": "er-ka1-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Mobiliteten ska ske till ett annat programland", "intakeQuestion": "Sker mobiliteten till ett annat europeiskt land?"}]', '[]', '[{"id": "er-ka1-e1", "kind": "project_description", "mandatory": true, "description": "Mobilitetsplan"}]', '2026-08-28 19:05:47.306476+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.306476+00'),
	('cdce65d6-4d4d-4e34-993b-9ddb200ea7f4', '47c90689-76cb-4190-a2ba-077827aff474', 1, '[{"id": "ke-sp-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer inom kultursektorn"}, {"id": "ke-sp-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "ke-sp-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasThreeCountryPartnership", "description": "Minst tre partner från tre olika programländer krävs", "intakeQuestion": "Har ni partner i minst tre olika europeiska länder?"}, {"id": "ke-sp-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver registrering i EU:s system (PIC/OID)", "intakeQuestion": "Är organisationen registrerad i EU:s deltagarregister?"}, {"id": "ke-sp-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "ke-sp-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning enligt utlysningens mall"}, {"id": "ke-sp-e2", "kind": "partner_letter", "mandatory": true, "description": "Partneravtal/avsiktsförklaringar"}, {"id": "ke-sp-e3", "kind": "budget", "mandatory": true, "description": "Detaljerad budget"}]', '2026-08-28 19:05:47.314122+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.314122+00'),
	('03e26c1d-bf64-48b3-b6e6-451520cc3980', '25486d77-0a0c-49fa-b6a4-a61c70878cba', 1, '[{"id": "fk-tfp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-tfp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (normalt under 12 år) som du vårdar när det är sjukt", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 19:05:47.563321+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.563321+00'),
	('fb2a3b7c-be7d-49e9-9710-36a64fcb0679', '3174c73f-fa02-42c7-98ca-7cfbd9b1a49f', 1, '[{"id": "kr-vs-h1", "op": "in", "kind": "hard", "expected": ["association", "company"], "factPath": "applicant.type", "description": "Söks av grupper/organisationer — inte enskilda"}, {"id": "kr-vs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-vs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Verksamheten ska vara professionell", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-vs-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Verksamheten ska vara scenkonst", "intakeQuestion": "Är verksamheten scenkonst (dans, teater, musikteater)?"}, {"id": "kr-vs-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "performance", "factPath": "project.activityTypes", "description": "Publik verksamhet"}]', '[]', '[{"id": "kr-vs-e1", "kind": "project_description", "mandatory": true, "description": "Verksamhetsplan"}, {"id": "kr-vs-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse"}, {"id": "kr-vs-e3", "kind": "budget", "mandatory": true, "description": "Verksamhetsbudget"}]', '2026-08-28 19:05:47.319872+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.319872+00'),
	('4887e198-66c9-488a-a1ac-2eb4097b12c3', '1aae92ae-585c-4746-8ad1-e3b5e1caff85', 1, '[{"id": "vin-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara svensk organisation"}, {"id": "vin-pb-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "vin-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansEuApplication", "description": "Bidraget ska användas för att förbereda en EU-ansökan", "intakeQuestion": "Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?"}]', '[]', '[{"id": "vin-pb-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av planerad EU-ansökan"}]', '2026-08-28 19:05:47.326401+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.326401+00'),
	('d4572ef7-1397-40ff-9000-558dd7b573d4', 'a6f2e8dc-c1db-4d01-8d6a-2bc9b8b9dc0c', 1, '[{"id": "mucf-ob-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-ob-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara nationell och verksam i Sverige"}, {"id": "mucf-ob-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Demokratisk uppbyggnad krävs", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}, {"id": "mucf-ob-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.youthMembersShareOver60", "description": "Minst 60 % av medlemmarna ska vara 6–25 år", "intakeQuestion": "Är minst 60 % av medlemmarna mellan 6 och 25 år?"}, {"id": "mucf-ob-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasNationalSpread", "description": "Verksamhet i flera län krävs", "intakeQuestion": "Har organisationen medlemsföreningar i flera län?"}]', '[]', '[{"id": "mucf-ob-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "mucf-ob-e2", "kind": "annual_report", "mandatory": true, "description": "Årsredovisning och medlemsredovisning"}]', '2026-08-28 19:05:47.331296+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.331296+00'),
	('5e127516-d0fc-4c83-98a1-fc19f3662f26', 'fc5cf270-6d44-4083-ad1c-bfe5b9daa605', 1, '[{"id": "fk-bbf-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbf-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig (helt eller växelvis)", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-bbf-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Hushållets inkomst ska vara under inkomstgränsen", "intakeQuestion": "Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbf-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 19:05:47.336254+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.336254+00'),
	('168e5b0c-2d19-4a3b-aeef-4a4d0368e78a', 'ffcaad8d-9445-421f-a38f-f75d58a5efe7', 1, '[{"id": "reg-glas-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare"}, {"id": "reg-glas-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska vara folkbokfört i Sverige"}, {"id": "reg-glas-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "reg-glas-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childNeedsGlasses", "description": "Barnet (8–19 år) behöver glasögon eller kontaktlinser", "intakeQuestion": "Behöver något av dina barn i åldern 8–19 år glasögon eller linser?"}]', '[]', '[]', '2026-08-28 19:05:47.341857+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.341857+00'),
	('89c4f083-37a6-4dfb-81ba-dbbdcec825e8', 'eccf68ab-be6b-47aa-8496-3f8eb94f5d4b', 1, '[{"id": "maj-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare eller t.ex. skolsköterska"}, {"id": "maj-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "maj-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (upp till 18 år) som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "maj-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childCostsStrain", "description": "Ekonomin räcker inte till sådant barnet behöver eller förväntas delta i", "intakeQuestion": "Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?"}, {"id": "maj-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "person.lowHouseholdIncome", "description": "Låg hushållsinkomst stärker ansökan"}]', '[]', '[]', '2026-08-28 19:05:47.346634+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.346634+00'),
	('6a5d16ed-77a4-48b3-80f8-884bc3ff9300', '41c414ba-6af3-4006-8650-ee358bba77fc', 1, '[{"id": "skjuts-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av vårdnadshavare"}, {"id": "skjuts-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "skjuts-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "skjuts-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInCompulsorySchool", "description": "Barnet går i grundskolan", "intakeQuestion": "Går något av dina barn i grundskolan?"}, {"id": "skjuts-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childSchoolDistanceQualifies", "description": "Färdvägen kvalificerar (längd, trafik eller funktionsnedsättning — kommunens bedömning)", "intakeQuestion": "Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?"}]', '[]', '[]', '2026-08-28 19:05:47.351493+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.351493+00'),
	('347c1c46-7309-4541-b620-740a12a0ff41', 'a0ff68b8-ffae-4bc7-8609-b47c16d79a8a', 1, '[{"id": "elevres-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "elevres-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "elevres-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "elevres-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Barnet går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "elevres-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childGymnasiumLongTravel", "description": "Färdvägen till skolan är minst sex kilometer", "intakeQuestion": "Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?"}]', '[]', '[]', '2026-08-28 19:05:47.35691+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.35691+00'),
	('6904e44a-45ae-48e0-8c9c-ae7e96c131fa', '772fc254-a2b1-43fd-bec2-ace7ae231536', 1, '[{"id": "fk-bbu-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbu-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbu-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara mellan 18 och 28 år", "intakeQuestion": "Är du mellan 18 och 28 år?"}, {"id": "fk-bbu-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Din inkomst ska vara låg", "intakeQuestion": "Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbu-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 19:05:47.361248+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.361248+00'),
	('c90f2ab4-fac7-4d7b-af9a-0a690249b366', '297dd869-5f82-44dc-b2e5-2a5cb22620cf', 1, '[{"id": "kfs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "kfs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "kfs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.incomeInsufficientForBasicNeeds", "description": "Inkomsterna ska inte räcka till det mest nödvändiga", "intakeQuestion": "Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?"}, {"id": "kfs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.limitedSavings", "description": "Du ska sakna sparande eller tillgångar som kan täcka behoven", "intakeQuestion": "Saknar du sparpengar eller tillgångar som kan täcka utgifterna?"}]', '[]', '[]', '2026-08-28 19:05:47.366179+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.366179+00'),
	('86b55dd3-e3f4-4e18-94bd-95fd96a6d9c0', '22685532-2f89-4f86-bb85-10eadedd5ffa', 1, '[{"id": "csn-sm-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-sm-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. det år du fyller 60"}, {"id": "csn-sm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}]', '[]', '[]', '2026-08-28 19:05:47.371204+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.371204+00'),
	('f99f99be-fed9-4662-9414-6e75c499e9c3', '05e2a219-0224-4e9a-a4fc-a490e50c2362', 1, '[{"id": "fk-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-ae-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara 19–29 år", "intakeQuestion": "Är du mellan 19 och 29 år?"}, {"id": "fk-ae-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.reducedWorkCapacityLongTerm", "description": "Arbetsförmågan ska vara nedsatt i minst ett år", "intakeQuestion": "Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?"}]', '[]', '[{"id": "fk-ae-e1", "kind": "medical_certificate", "mandatory": true, "description": "Läkarutlåtande om arbetsförmåga"}]', '2026-08-28 19:05:47.376322+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.376322+00'),
	('a8c76cfb-7bc9-4221-b5ee-cb546b95d914', '2a2922ce-9a4d-4f6e-8a9f-94b69f4f08ec', 1, '[{"id": "fk-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Barnet ska bo hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}, {"id": "fk-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.separatedParent", "description": "Föräldrarna ska inte bo tillsammans", "intakeQuestion": "Bor du och barnets andra förälder på skilda håll?"}, {"id": "fk-us-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.otherParentNotPaying", "description": "Den andra föräldern betalar inte underhåll (eller för lite)", "intakeQuestion": "Betalar den andra föräldern inget eller mindre än fullt underhåll?"}]', '[]', '[]', '2026-08-28 19:05:47.381121+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.381121+00'),
	('09bd5a8c-6180-460f-b637-738e5f389341', 'a0ee3771-36b8-4bcd-b9f8-d98ec242eb47', 1, '[{"id": "af-ssn-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "af-ssn-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara inskriven hos Arbetsförmedlingen i Sverige"}, {"id": "af-ssn-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven som arbetssökande", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "af-ssn-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansToStartBusiness", "description": "Du ska planera att starta företag", "intakeQuestion": "Planerar du att starta eget företag?"}]', '[]', '[{"id": "af-ssn-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}]', '2026-08-28 19:05:47.395767+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.395767+00'),
	('a40526df-622c-41f8-8d1e-1afdcc3803d2', 'b229c4b1-da17-4783-ad8c-527c6c2db2b4', 1, '[{"id": "csn-oss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-oss-h2", "op": "is_false", "kind": "hard", "factPath": "person.age62Plus", "description": "Stödet kan sökas längst t.o.m. det år du fyller 62"}, {"id": "csn-oss-h3", "op": "is_false", "kind": "hard", "factPath": "person.receivesPension", "description": "Stödet riktar sig till yrkesverksamma, inte pensionärer"}, {"id": "csn-oss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.establishedInLabourMarket", "description": "Du ska ha arbetat i genomsnitt minst 16 h/vecka i minst 8 år", "intakeQuestion": "Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?"}, {"id": "csn-oss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska planera studier som stärker din ställning på arbetsmarknaden", "intakeQuestion": "Planerar du studier som stärker din ställning på arbetsmarknaden?"}]', '[]', '[]', '2026-08-28 19:05:47.400668+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.400668+00'),
	('fa5772ba-f4dd-49d5-94a8-123efdbf375f', 'ba6fcb93-6a60-4adf-a37d-d53718fa3afd', 1, '[{"id": "kom-bab-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "kom-bab-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bostaden ska ligga i Sverige"}, {"id": "kom-bab-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i hushållet har en funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "kom-bab-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du eller någon i hushållet ska ha en bestående funktionsnedsättning", "intakeQuestion": "Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?"}, {"id": "kom-bab-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.needsHomeAdaptation", "description": "Bostaden ska behöva anpassas", "intakeQuestion": "Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?"}]', '[]', '[{"id": "kom-bab-e1", "kind": "medical_certificate", "mandatory": true, "description": "Intyg från arbetsterapeut, läkare eller motsvarande"}]', '2026-08-28 19:05:47.405775+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.405775+00'),
	('599e0cb7-da6a-4c72-9be2-dd4c608bb282', '3be8b47f-055c-472e-901e-f52f0158f9af', 1, '[{"id": "kn-kb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kn-kb-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kn-kb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande", "intakeQuestion": "Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?"}]', '[]', '[{"id": "kn-kb-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kn-kb-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 19:05:47.410831+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.410831+00'),
	('df85b44d-a82d-4ca5-ade8-1ae091c5f757', 'e1feccd1-97a2-4cb1-948a-19fadfd3a7f0', 1, '[{"id": "raa-ka-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "raa-ka-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "raa-ka-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsCulturalHeritage", "description": "Projektet ska avse kulturarv", "intakeQuestion": "Handlar projektet om att bevara eller tillgängliggöra kulturarv?"}]', '[]', '[]', '2026-08-28 19:05:47.416085+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.416085+00'),
	('32ab05cc-1e8c-4cc7-bedb-264a830f279a', '7232f6a3-7855-4491-8882-b561314bf0ff', 1, '[{"id": "si-cf-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "si-cf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande organisation ska vara svensk"}, {"id": "si-cf-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska genomföras med internationell partner", "intakeQuestion": "Har projektet en partner i ett annat land?"}, {"id": "si-cf-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensDemocracy", "description": "Projektet ska stärka demokrati, jämlikhet eller yttrandefrihet", "intakeQuestion": "Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?"}, {"id": "si-cf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["culture", "civil_society"], "factPath": "project.sector", "description": "Kultur/media som verktyg"}]', '[]', '[{"id": "si-cf-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från internationell partner"}, {"id": "si-cf-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 19:05:47.421378+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.421378+00'),
	('71b0de7f-8a3c-4476-bb74-c2e8627e4f65', '66bc3ff8-31bc-4582-a1b4-4a6d2ba38fb6', 1, '[{"id": "fk-sp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-sp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.sickReducedWorkCapacity", "description": "Sjukdomen ska sätta ned din arbetsförmåga med minst en fjärdedel", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?"}]', '[]', '[]', '2026-08-28 19:05:47.567791+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.567791+00'),
	('f8c329e2-7bd3-42d4-843e-d08130e8627b', '527c67ea-1c17-4a82-a849-d7873ad60d80', 1, '[{"id": "nkf-ps-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett konst- eller kulturprojekt", "intakeQuestion": "Är projektet ett konst- eller kulturprojekt?"}, {"id": "nkf-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasNordicDimension", "description": "Projektet ska ha nordisk dimension (samarbete i flera nordiska länder)", "intakeQuestion": "Samarbetar ni med partner i minst två andra nordiska länder?"}, {"id": "nkf-ps-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Gränsöverskridande samarbete"}]', '[]', '[{"id": "nkf-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "nkf-ps-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 19:05:47.42697+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.42697+00');
INSERT INTO public.rule_versions VALUES
	('153e4e51-91d9-4d6c-bd7a-6b97a640653c', '7df24286-ffcc-47d3-8736-331afe557653', 1, '[{"id": "vr-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte"}, {"id": "vr-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}]', '[]', '[{"id": "vr-pb-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "vr-pb-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}]', '2026-08-28 19:05:47.431305+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.431305+00'),
	('0a8ec684-0b20-48d0-b7e9-1e1738233aef', 'a2a2b258-0466-4347-a8c0-429a5f25878f', 1, '[{"id": "pk-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "pk-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska vara etablerad och välskött", "intakeQuestion": "Har organisationen ordnad ekonomi och demokratisk struktur?"}, {"id": "pk-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Stödet ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[{"id": "pk-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "pk-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning"}]', '2026-08-28 19:05:47.435589+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.435589+00'),
	('02b0bf53-bda1-4a29-8e13-191e718d17c3', '8604efc7-3a5a-4d59-a5cf-c891177ae55c', 1, '[{"id": "mv-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "mv-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell musikverksamhet", "intakeQuestion": "Är verksamheten professionell?"}, {"id": "mv-pb-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Musikprojekt", "intakeQuestion": "Är projektet ett musikprojekt?"}]', '[]', '[]', '2026-08-28 19:05:47.440607+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.440607+00'),
	('585d8380-b181-4906-9771-2921a429dbf7', 'f556dd02-23ba-44f5-9628-d1975855f2fd', 1, '[{"id": "er-ka2-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "school", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "er-ka2-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID?"}, {"id": "er-ka2-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partner i ett annat programland", "intakeQuestion": "Har ni en partnerorganisation i ett annat europeiskt land?"}, {"id": "er-ka2-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.newToEuFunding", "description": "Nykomlingar i Erasmus+ prioriteras", "intakeQuestion": "Är det här ert första EU-projekt?"}]', '[]', '[{"id": "er-ka2-e1", "kind": "partner_letter", "mandatory": true, "description": "Partnerbekräftelse"}, {"id": "er-ka2-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 19:05:47.44528+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.44528+00'),
	('d4222bd5-88b6-494e-b0bd-b0f678c4d938', '5f815fab-d207-4dcb-afc2-067cd1b19845', 1, '[{"id": "tv-ris-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av företag"}, {"id": "tv-ris-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "tv-ris-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.inSupportArea", "description": "Verksamhetsorten ska ligga i stödområde A eller B", "intakeQuestion": "Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?"}, {"id": "tv-ris-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en investering i byggnader eller maskiner?"}, {"id": "tv-ris-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.notStartedYet", "description": "Investeringen får inte vara påbörjad före ansökan", "intakeQuestion": "Kommer investeringen att påbörjas först efter att ni skickat in ansökan?"}]', '[{"id": "tv-ris-b1", "type": "max_funding_share", "percent": 35, "description": "Stödandelen är högst 35 % beroende på område och företagsstorlek."}]', '[]', '2026-08-28 19:05:47.450451+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.450451+00'),
	('02309fa3-d42e-4921-a9ed-a115a5dc07fa', 'b17fbe89-6a8c-443c-8481-e75be0561798', 1, '[{"id": "kr-ib-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Söks av kommuner"}, {"id": "kr-ib-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsLibraries", "description": "Medlen ska användas till litteraturinköp för folk- eller skolbibliotek", "intakeQuestion": "Avser ansökan litteraturinköp till folk- eller skolbibliotek?"}, {"id": "kr-ib-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga prioriteras"}]', '[]', '[]', '2026-08-28 19:05:47.455259+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.455259+00'),
	('4f3f36ca-bf03-4200-a28e-1dbeebdcaeb5', '649b98f4-5f25-47c6-a7b0-b89f0f7d8920', 1, '[{"id": "kr-ls-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av förlag"}, {"id": "kr-ls-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isPublisher", "description": "Sökande ska vara ett förlag med professionell utgivning", "intakeQuestion": "Är ni ett förlag med professionell utgivning?"}, {"id": "kr-ls-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsPublishedBook", "description": "Stödet söks för redan utgiven titel", "intakeQuestion": "Avser ansökan en redan utgiven titel?"}]', '[]', '[]', '2026-08-28 19:05:47.458757+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.458757+00'),
	('3b810cca-f5c6-4892-8b89-851b603b2462', 'a02f598a-09c8-4129-8315-6d1ebd533849', 1, '[{"id": "ls-bm-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality"], "factPath": "applicant.type", "description": "Söks av föreningar och kommuner"}, {"id": "ls-bm-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "ls-bm-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inAffectedArea", "description": "Projektet ska ligga i en bygd berörd av vatten- eller vindkraft", "intakeQuestion": "Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?"}, {"id": "ls-bm-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsCommunity", "description": "Projektet ska vara till allmän nytta för bygden", "intakeQuestion": "Är projektet till nytta för bygden i stort (inte enskilda)?"}]', '[]', '[]', '2026-08-28 19:05:47.463626+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.463626+00'),
	('53ecd377-e3ce-4ff4-ae9b-8f75766eba60', '48f5a3c2-7682-456d-aac6-90f3c3b2b7c0', 1, '[{"id": "mv-av-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "mv-av-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "mv-av-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.planningReturnMigration", "description": "Du ska frivilligt planera att flytta tillbaka till ditt ursprungsland permanent", "intakeQuestion": "Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?"}, {"id": "mv-av-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.protectionBasedResidence", "description": "Du ska ha uppehållstillstånd som flykting eller skyddsbehövande (eller vara nära anhörig till någon som har det)", "intakeQuestion": "Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?"}]', '[]', '[]', '2026-08-28 19:05:47.468163+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.468163+00'),
	('9bfd4984-0a5f-4d60-a9d2-83fb0df92047', '6420b212-cc32-4590-ba27-a768d9824dae', 1, '[{"id": "eures-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "eures-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara bosatt i ett EU-land (här: Sverige)"}, {"id": "eures-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "eures-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.seekingJobInOtherEuCountry", "description": "Du ska söka eller ha fått jobb i ett annat EU-/EES-land", "intakeQuestion": "Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?"}]', '[]', '[]', '2026-08-28 19:05:47.472892+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.472892+00'),
	('446e4fe2-d3eb-4372-83c5-4781037ddde6', 'e9b3b976-f814-4785-8c7f-efccf761b102', 1, '[{"id": "csn-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-us-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. ca 60 års ålder"}, {"id": "csn-us-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "csn-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}, {"id": "csn-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansStudyAbroad", "description": "Studierna ska bedrivas utomlands", "intakeQuestion": "Planerar du att studera utomlands?"}]', '[]', '[]', '2026-08-28 19:05:47.476883+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.476883+00'),
	('63a04bbb-f0ba-4b9d-9690-77f736db2864', '4e5edd9a-5515-4838-8bd6-bddb852f6b48', 1, '[{"id": "fk-ov-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av vårdnadshavare"}, {"id": "fk-ov-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-ov-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-ov-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-ov-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childHasDisability", "description": "Barnet ska ha en funktionsnedsättning som ger behov av mer omvårdnad och tillsyn än jämnåriga", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?"}]', '[]', '[]', '2026-08-28 19:05:47.484199+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.484199+00'),
	('47b42e2e-8674-435d-9879-e1a47b130da1', '8377bf76-b7f9-4bed-a818-32689e0d11fd', 1, '[{"id": "fk-mk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-mk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-mk-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-mk-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du (eller ditt barn) ska ha en varaktig funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-mk-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityExtraCosts", "description": "Funktionsnedsättningen ska medföra merkostnader över lägstanivån", "intakeQuestion": "Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?"}]', '[]', '[]', '2026-08-28 19:05:47.48883+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.48883+00'),
	('d7871927-9355-4d5a-a958-5eb0d5bcdc50', 'a19bf016-211f-4861-8b46-b2da65c57d7c', 1, '[{"id": "fk-bs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-bs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-bs-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-bs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Funktionsnedsättningen ska vara varaktig", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-bs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityTravelDifficulty", "description": "Det ska vara mycket svårt att förflytta sig på egen hand eller använda allmänna kommunikationer", "intakeQuestion": "Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?"}]', '[]', '[]', '2026-08-28 19:05:47.493599+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.493599+00'),
	('c0433c20-bf31-488e-851c-338eb504055d', 'f4c46b41-fd43-494e-9d7d-21d576bc30de', 1, '[{"id": "fk-np-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-np-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-np-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.caringForSeriouslyIllRelative", "description": "Du ska avstå från förvärvsarbete för att vårda eller vara nära en närstående vars sjukdom är ett påtagligt hot mot livet", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?"}]', '[]', '[]', '2026-08-28 19:05:47.498371+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.498371+00'),
	('66498a87-608c-4384-a11a-67c5411d4e1e', '02d3c6b1-ba09-49bc-9c92-913e9c8eca86', 1, '[{"id": "af-ee-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "af-ee-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "af-ee-h3", "op": "is_false", "kind": "hard", "factPath": "person.age66Plus", "description": "Programmet gäller till och med 66 års ålder"}, {"id": "af-ee-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Du ska nyligen ha fått uppehållstillstånd som skyddsbehövande eller anhörig", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "af-ee-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och delta i etableringsprogrammet", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-28 19:05:47.50297+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.50297+00'),
	('ef8cf74e-e184-4e44-aacf-25ea60ba108b', '7d56e2e5-be39-4a81-a96e-48fa4f599d8a', 1, '[{"id": "csn-hl-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Lånet söks av privatpersoner"}, {"id": "csn-hl-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara mottagen i en svensk kommun"}, {"id": "csn-hl-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Lånet gäller flyktingar och vissa anhöriga under de första åren i Sverige", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "csn-hl-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.settlingFirstHomeInSweden", "description": "Du ska hålla på att skaffa och utrusta ett första hem i Sverige", "intakeQuestion": "Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?"}]', '[]', '[]', '2026-08-28 19:05:47.508038+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.508038+00'),
	('5c36b35d-7e95-45a6-95e5-da5ecf53737f', '7cdbb754-c472-4d4a-8377-ef5bbbb6d62f', 1, '[{"id": "csn-ss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "csn-ss-h3", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Stödet gäller till och med 60 års ålder"}, {"id": "csn-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara arbetslös och anmäld hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "csn-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.age25to60", "description": "Du ska vara mellan 25 och 60 år", "intakeQuestion": "Är du mellan 25 och 60 år?"}, {"id": "csn-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.shortPriorEducation", "description": "Du ska ha kort tidigare utbildning och behöva studier på grundskole- eller gymnasienivå", "intakeQuestion": "Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?"}]', '[]', '[]', '2026-08-28 19:05:47.513365+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.513365+00'),
	('0c4b6ff4-f018-4807-9de6-bdc457fd56d4', 'd424bb27-1491-44a6-8fa7-c99108c6f89e', 1, '[{"id": "csn-it-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "csn-it-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "csn-it-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "csn-it-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Eleven går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "csn-it-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childLivesAwayForStudies", "description": "Eleven behöver bo på studieorten på grund av lång eller besvärlig resväg", "intakeQuestion": "Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?"}]', '[]', '[]', '2026-08-28 19:05:47.519615+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.519615+00'),
	('47abc58f-b930-4d69-bca7-d1a460bd763f', '146e1dad-6a01-4db9-8a1c-a255842d6cd6', 1, '[{"id": "kmn-fb-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Bidragen söks av ideella föreningar"}, {"id": "kmn-fb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "kmn-fb-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Föreningen ska vara demokratiskt uppbyggd med stadgar och styrelse", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har föreningen antagna stadgar och en vald styrelse?"}, {"id": "kmn-fb-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.activeInMunicipality", "description": "Föreningen ska bedriva regelbunden verksamhet i kommunen", "intakeQuestion": "Bedriver föreningen regelbunden verksamhet i kommunen?"}, {"id": "kmn-fb-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.hasYouthActivities", "description": "Barn- och ungdomsverksamhet prioriteras i de flesta kommuner", "intakeQuestion": "Har föreningen regelbunden verksamhet för barn eller unga?"}]', '[]', '[]', '2026-08-28 19:05:47.524904+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.524904+00'),
	('f6633cdf-0cc9-498f-8706-21f77eaa18d8', 'ef5d306b-f30d-48dd-908d-6a43e751ed94', 1, '[{"id": "reg-ks-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "reg-ks-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Stöden gäller kulturverksamhet", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "reg-ks-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.regionalConnection", "description": "Sökanden ska ha säte eller huvudsaklig verksamhet i regionen", "intakeQuestion": "Har ni säte eller huvudsaklig verksamhet i den region där ni söker?"}]', '[]', '[]', '2026-08-28 19:05:47.529953+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.529953+00'),
	('f0c377b3-2e85-43e9-b2ee-63cf43deb523', '63cecab0-051b-4fa9-b4f3-e6213bc29ae6', 1, '[{"id": "spb-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks i regel av ideella organisationer"}, {"id": "spb-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "spb-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.localSparbankPresence", "description": "Det ska finnas en sparbank/sparbanksstiftelse i ert verksamhetsområde", "intakeQuestion": "Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?"}, {"id": "spb-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska komma det lokala samhället till del", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}]', '[]', '[]', '2026-08-28 19:05:47.534615+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.534615+00'),
	('8da6016a-7e3b-4e1c-8479-bb7c47618ca8', 'b2dc12b1-327d-4fae-b797-695f6914b21b', 1, '[{"id": "leader-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "leader-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inRuralLeaderArea", "description": "Projektet ska genomföras inom ett leaderområde (större delen av landsbygden och många tätorter omfattas)", "intakeQuestion": "Genomförs projektet på landsbygden eller i en mindre tätort?"}, {"id": "leader-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska bidra till bygdens utveckling enligt områdets strategi", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}, {"id": "leader-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Stödet betalas ut i efterhand — ni behöver kunna ligga ute med kostnader", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[]', '2026-08-28 19:05:47.539565+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.539565+00'),
	('056c4841-dad6-439e-9522-c9ef2d934682', 'f881cabb-599c-4f1d-ae72-a82823c5c7ed', 1, '[{"id": "forte-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte eller godkänd medelsförvaltare"}, {"id": "forte-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "forte-pb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.withinForteAreas", "description": "Projektet ska ligga inom hälsa, arbetsliv eller välfärd", "intakeQuestion": "Handlar projektet om hälsa, arbetsliv eller välfärd?"}]', '[]', '[]', '2026-08-28 19:05:47.543913+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.543913+00'),
	('f61f4264-cc09-4859-b7a8-3b180fbd8504', 'ce5b2ae0-9e39-408a-84d8-9de9317c749e', 1, '[{"id": "rh-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks av ideella organisationer"}, {"id": "rh-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara svensk"}, {"id": "rh-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.has90Account", "description": "Organisationen ska ha 90-konto (Svensk Insamlingskontroll)", "intakeQuestion": "Har organisationen ett 90-konto?"}, {"id": "rh-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Bidrag ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[]', '2026-08-28 19:05:47.5485+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.5485+00'),
	('be984a30-4573-4e6b-8d25-b0fb1b01e81b', 'b5aec0b5-f575-4334-bc05-9c5704b775a0', 1, '[{"id": "fk-bb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-bb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-bb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn under 16 år som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 19:05:47.552088+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.552088+00'),
	('17ce5d33-dd63-4e70-903b-a4ff4c033226', '34ea1fd5-5df2-46cc-8c7d-3435f8cc4956', 1, '[{"id": "fk-fbt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget gäller privatpersoner"}, {"id": "fk-fbt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Gäller från och med det andra barnet du får barnbidrag för", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 19:05:47.55568+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.55568+00'),
	('4a803baa-a9bb-4c5c-9804-9acf7c17c397', '0d351ab4-1e5b-4ad9-bc7e-30f8c3fc65fb', 1, '[{"id": "fk-se-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-se-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Ersättningen är aktuell vid varaktig sjukdom eller funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-se-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Arbetsförmågan ska vara stadigvarande nedsatt av sjukdom eller funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}]', '[]', '[]', '2026-08-28 19:05:47.57152+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.57152+00'),
	('08586b52-ea04-4394-a169-de1c94637961', '3dd9afb6-fa2a-4b2f-812f-53324f1ae5e8', 1, '[{"id": "fk-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "fk-as-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.inAfProgram", "description": "Du ska delta i ett arbetsmarknadspolitiskt program", "intakeQuestion": "Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?"}]', '[]', '[]', '2026-08-28 19:05:47.577218+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.577218+00'),
	('86bb7fc4-0814-43ee-ba69-d1a847d14a73', '35cc84cc-06bc-45a0-8fb5-e7cf6339ec18', 1, '[{"id": "fk-atb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-atb-h2", "op": "is_true", "kind": "hard", "factPath": "person.age24Plus", "description": "Bidraget gäller från och med det år du fyller 24"}]', '[]', '[]', '2026-08-28 19:05:47.582285+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.582285+00'),
	('147d9193-f593-4849-aee8-c4514f95f9af', '7d9b99ba-2513-4c32-934d-360cd9764d94', 1, '[{"id": "pm-gp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Gäller privatpersoner"}, {"id": "pm-gp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Garantipension lämnas från riktåldern (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}]', '[]', '[]', '2026-08-28 19:05:47.58688+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.58688+00'),
	('fd4bd609-5220-457c-a2bf-db2b215d1845', '1b659cdd-5078-4c5f-b2ff-d94de9db5cc4', 1, '[{"id": "reg-hk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Skyddet gäller privatpersoner"}, {"id": "reg-hk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller vård i Sverige"}]', '[]', '[]', '2026-08-28 19:05:47.591635+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.591635+00'),
	('8337d231-13c4-42e7-945a-42d8899a0fdc', '4ea32df9-b3ca-43e5-9a93-9a0fca6ef0da', 1, '[{"id": "ak-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "ak-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och aktivt söka arbete", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-28 19:05:47.596034+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.596034+00'),
	('3ebf9e84-44f2-4b92-9d7b-9357388f9f60', 'a46ebfdb-d00c-468f-8146-2278e08cd193', 1, '[{"id": "af-nj-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-nj-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateAwayFromWork", "description": "Den som anställs ska ha varit borta från arbetslivet en längre tid eller vara nyanländ", "intakeQuestion": "Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?"}]', '[]', '[]', '2026-08-28 19:05:47.600477+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.600477+00'),
	('934d9111-559b-4c26-b196-ae66ced51774', 'eb79360d-f0ac-465c-a1e6-04c65986d83e', 1, '[{"id": "af-lb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa eller behålla en medarbetare", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-lb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateReducedWorkCapacity", "description": "Den anställda ska ha nedsatt arbetsförmåga på grund av funktionsnedsättning eller ohälsa", "intakeQuestion": "Gäller anställningen en person med nedsatt arbetsförmåga?"}]', '[]', '[]', '2026-08-28 19:05:47.603905+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 19:05:47.603905+00');


--
-- Data for Name: source_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sources VALUES
	('be4aa506-118b-4c76-9be2-e99b1484b03d', '2161428e-0588-46cc-b1b2-93c4fdeccf93', 'Kulturrådet — Sök bidrag', 'https://kulturradet.se/sok-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.108499+00'),
	('424f27c6-b6b9-4c43-a492-bfc953e7b3a4', '64a93432-3fdd-4fb4-b6b8-ec17e6f31535', 'MUCF — Bidrag', 'https://www.mucf.se/bidrag', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.110661+00'),
	('3193dbf3-67b8-4c00-893f-0526f32d5dbf', '683e4116-b793-4d36-9499-703f0a8f15c3', 'Vinnova — Utlysningar', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.112261+00'),
	('f8b3dd5c-2b4b-4250-9424-bf147f6a2ff5', '08248302-d932-4084-a794-f2d8ed80e057', 'Tillväxtverket — Utlysningar', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.113798+00'),
	('c0684838-2412-4109-998e-42deeed44275', '6e4cedc0-be21-481f-b811-9b4115bec533', 'Energimyndigheten — Alla utlysningar', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.115659+00'),
	('a5a5d737-1389-4cf6-930a-1bf6d09c3d48', '13a067b5-4bed-45ef-b3bc-58a16b5fc5d2', 'Naturvårdsverket — Bidrag', 'https://www.naturvardsverket.se/bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.118511+00'),
	('98a8b717-b60c-4286-938f-1d9cbfea367c', '1eed7774-bfb5-4636-b097-a6ecbf93b734', 'Svenska ESF-rådet — Utlysningsplan', 'https://www.esf.se/utlysningar/utlysningsplan/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.120105+00'),
	('c3461f54-92f2-42ef-85f9-61dab97f2664', '13041e01-d9ea-43e3-b47e-6a8c7ac3b7f0', 'Erasmus+ — Youth exchanges', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.121609+00'),
	('1b168247-5d70-4cd4-89ac-e8904fb05df8', '7aadc7e1-b039-4488-83bc-b5eaf129c863', 'Konstnärsnämnden — Stipendier och bidrag', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.123008+00'),
	('9bbc1204-2894-4776-a08f-603080d7598f', '31e8e2f5-52a5-4682-9ca6-cdb2c77ffe18', 'Allmänna arvsfonden — Söka pengar', 'https://www.arvsfonden.se/soka-pengar', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.124546+00'),
	('5974e338-d649-4513-9b87-b1a24bb77ba9', '54851904-35b4-4dfc-9140-1daceb1ef85f', 'Boverket — Bidrag och stöd', 'https://www.boverket.se/sv/bidrag--garantier/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.126448+00'),
	('fe246359-cd7a-4b9c-9fe2-692affa52366', '70576e97-1033-4edc-a69c-bfa1190af574', 'Riksidrottsförbundet — Ekonomiskt stöd', 'https://www.rf.se/bidrag-och-stod', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.127753+00'),
	('c4f2f986-e144-4468-80dc-fc5e904255b8', '1784f0ae-7080-4e92-b714-37ae106ce213', 'Svenska Filminstitutet — Stöd', 'https://www.filminstitutet.se/sv/sok-stod/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.129439+00'),
	('66399e93-991b-41bd-bd5b-940d943a2ebb', 'e89c9252-43be-40a8-a1c5-8977f0997df4', 'Formas — Utlysningar', 'https://www.formas.se/soka-finansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.130909+00'),
	('e44bafc3-24db-4bd7-bff1-a41a8b817b72', 'afded389-82d6-46aa-9b9e-7c62d0d2afbb', 'UHR — Erasmus+ utbildning', 'https://www.uhr.se/internationella-mojligheter/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.132369+00'),
	('8609bbf3-3599-45f8-8910-763c6c6676c6', '1cfeb4e5-ab96-4c29-b609-840ac55ba108', 'Försäkringskassan — Privatperson', 'https://www.forsakringskassan.se/privatperson', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.133936+00'),
	('6db4f68f-bce5-408a-877a-1fe62bf13efb', '8e2d3869-e858-473f-88ab-ab5f47b9b8c1', 'CSN — Studiemedel', 'https://www.csn.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.135365+00'),
	('e3e530ee-2207-485f-9ce7-a2c703e61d8c', '6b993806-e6f5-43e3-b37e-542c6b2952bc', 'Pensionsmyndigheten — Stöd och bidrag', 'https://www.pensionsmyndigheten.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.137101+00'),
	('8781626c-d968-474c-9055-4e45a6e68156', '96346af8-c105-4f07-a823-ab8648762e19', 'Socialstyrelsen — Ekonomiskt bistånd', 'https://www.socialstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.138562+00'),
	('57d7ab75-fce9-45b6-b3d4-eea6b05f948d', '4a35ddab-675d-42d2-9775-a483285ec84e', '1177 — Bidrag för glasögon till barn och unga', 'https://www.1177.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.13989+00'),
	('91a1b59c-fa58-453f-98f0-e74ba5fcef44', '6b8aaecc-daad-4dd2-b30e-35ac2f695e82', 'Majblomman — Ansök om bidrag', 'https://majblomman.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.141447+00'),
	('d375f390-715e-4bf8-8b50-0f010c4dfd52', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'Skolverket — Skolskjuts', 'https://www.skolverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.142864+00'),
	('0e980ead-f1ac-4bc9-a5ac-1dc83ac6c78e', '114e913f-a8a0-48a0-97df-33ebfee16ea8', 'Lag (1991:1110) om kommunernas skyldighet att svara för vissa elevresor', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.144269+00'),
	('068d3eb2-4c99-4221-818a-332737f04718', 'dcce227d-e1b1-42da-bdd1-9f25d04b82bc', 'Arbetsförmedlingen — Stöd och bidrag', 'https://arbetsformedlingen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.145608+00'),
	('70c94c7b-0319-4c35-8ab5-b56f32ab2f6f', '335178e6-1b98-4482-a282-2b6788dd7622', 'Sveriges a-kassor — Så fungerar a-kassan', 'https://www.sverigesakassor.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.146878+00'),
	('a0dab6ca-6ef7-4f88-a1ea-c8e6bf7856c2', '7cd7f6c5-33de-49cf-9959-ecfdf7406b3d', 'Migrationsverket — Återvandring', 'https://www.migrationsverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.14868+00'),
	('dcdc5241-7ff0-421a-915f-c91df09b61b5', '289fbe84-3d6a-4d62-ae45-9e2f284a0761', 'Riksantikvarieämbetet — Bidrag', 'https://www.raa.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.150059+00'),
	('f23f1ea2-8b7a-4142-95a2-350bcace4981', '471d5586-a07e-4256-8a02-4923cc1b9b19', 'Svenska institutet — Utlysningar', 'https://si.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.151331+00'),
	('bc0277a9-8ee7-4cb0-8e6b-b7d17ee04bbb', 'd8174b27-1934-450d-909e-74445d1cdf5d', 'Nordisk kulturfond — Støtte', 'https://www.nordiskkulturfond.org/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.153131+00'),
	('cac5da47-63af-4655-a176-dbb79f13859e', 'e4ccb9a5-dc99-4045-8368-14f3110e7ee0', 'Vetenskapsrådet — Utlysningar', 'https://www.vr.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.154573+00'),
	('783d53df-b2fd-463c-b02f-16022a80b1f9', '1180e0a9-e60d-40d5-a4bb-8c0658834f19', 'Postkodstiftelsen — Ansök om stöd', 'https://postkodstiftelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.155895+00'),
	('e2f419fc-cedb-463f-9aac-ea45fd02e07a', '5c2016b6-f733-4a4f-9f06-1bacb2cda675', 'Musikverket — Bidrag', 'https://musikverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.15731+00'),
	('1cd93aab-8ba0-4a9c-afcd-b11ae1ffcad2', 'cb2c2570-e8f4-4bc3-86fb-c1985027fdb6', 'Länsstyrelserna — Stöd och bidrag', 'https://www.lansstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.158589+00'),
	('d35472d5-d164-40f8-97ed-3b1c2dd79420', '0b29c47b-a9ee-422e-b3cf-70cc3d40d453', 'Forte — Utlysningar', 'https://forte.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.159903+00'),
	('6c16471e-5766-42a9-af6f-73332ef21709', 'f8ad8f1e-4686-4fa9-bd93-8104df989a2d', 'Sparbankernas Riksförbund — Sparbanksstiftelser', 'https://www.sparbankerna.se/', 'html', 'B', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.161391+00'),
	('ce053fcd-125a-4314-acaf-967c4cbe6724', '5bb1059c-7173-484a-a36c-9d907d2b60ac', 'Radiohjälpen — Söka bidrag', 'https://www.radiohjalpen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.162697+00'),
	('47bec89a-463d-4940-9157-5943f5b129a5', 'b2e0436a-46a5-4353-840c-daecf935e86a', 'Jordbruksverket — Stöd', 'https://jordbruksverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 19:05:47.163925+00');


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

SELECT pg_catalog.setval('drizzle.__drizzle_migrations_id_seq', 14, true);


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
-- Name: kb_translations kb_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kb_translations
    ADD CONSTRAINT kb_translations_pkey PRIMARY KEY (id);


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
-- Name: kb_translations_locale_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX kb_translations_locale_source_idx ON public.kb_translations USING btree (locale, source_text);


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
-- Name: kb_translations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.kb_translations ENABLE ROW LEVEL SECURITY;

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


