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
	('da81ca29-8c1b-414b-9707-40a88eb8afc8', '1ce740ab-9c27-4da7-94df-d3c8dff4006c', 1, '{"id": "kulturradet-resebidrag-v1", "title": "Ansökan — Resebidrag för internationellt kulturutbyte", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "sokande_verksamhet", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "guidance": "T.ex. dans, musik, scenkonst.", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv resan och utbytet", "section": "projekt", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_land", "type": "text", "label": "Resmål (land)", "section": "projekt", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "projekt_datum", "type": "date_range", "label": "Resperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Har du en inbjudan eller bekräftelse från mottagande part?", "section": "projekt", "required": true}, {"key": "inbjudan_beskrivning", "type": "long_text", "label": "Beskriv inbjudan/samarbetet", "section": "projekt", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_inbjudan"}]}, {"key": "aterforing", "type": "long_text", "label": "Hur tar du tillvara erfarenheterna i Sverige?", "section": "projekt", "required": true, "maxLength": 2000, "canonicalKey": "project.knowledgeTransferPlan"}, {"key": "sokt_belopp", "max": 50000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig som söker"}, {"key": "projekt", "title": "Resan och utbytet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.444669+00'),
	('357399af-3d27-4c6a-a754-75353ce4c3db', '808c5f5b-7f8c-40c3-a1d8-5d5d77b2b575', 1, '{"id": "erasmus-ungdomsutbyte-v1", "title": "Ansökan — Erasmus+ Ungdomsutbyte (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System med EU Login.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv utbytet", "section": "projekt", "guidance": "Tema, aktiviteter och förväntat lärande.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Utbytesperiod (exklusive resdagar)", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "antal_deltagare", "max": 200, "min": 4, "type": "number", "label": "Antal deltagare", "section": "deltagare", "required": true}, {"key": "har_partner", "type": "boolean", "label": "Har ni en bekräftad partnergrupp i ett annat land?", "section": "deltagare", "required": true}, {"key": "partner_namn", "type": "text", "label": "Partnergruppens namn och land", "section": "deltagare", "required": true, "maxLength": 300, "visibleWhen": [{"op": "is_true", "factPath": "har_partner"}], "canonicalKey": "project.partnerName"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Utbytet"}, {"key": "deltagare", "title": "Deltagare och partner"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.447088+00'),
	('ebc99bed-fb39-40fc-bb02-abfc63eaf64b', '9f060715-2c83-47b7-9b1f-b25cfcb0d3c8', 1, '{"id": "nordisk-kulturfond-projektstod-v1", "title": "Ansökan — Nordisk kulturfond, projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller organisation)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_titel", "type": "text", "label": "Projektets titel", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska ni göra, varför, och vad är den konstnärliga/kulturella idén?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "nordiska_lander", "type": "multiselect", "label": "Vilka nordiska länder deltar aktivt i projektet?", "options": [{"label": "Sverige", "value": "SE"}, {"label": "Danmark", "value": "DK"}, {"label": "Norge", "value": "NO"}, {"label": "Finland", "value": "FI"}, {"label": "Island", "value": "IS"}, {"label": "Grönland", "value": "GL"}, {"label": "Färöarna", "value": "FO"}, {"label": "Åland", "value": "AX"}], "section": "norden", "guidance": "Fonden kräver samarbete mellan flera nordiska länder — ange de länder som har en aktiv roll.", "required": true}, {"key": "nordisk_dimension", "type": "long_text", "label": "Vad tillför det nordiska samarbetet projektet?", "section": "norden", "guidance": "Konkret: vad händer i samarbetet som inte hade hänt nationellt?", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig/er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "norden", "title": "Nordisk dimension"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.448922+00'),
	('d085e1f6-7ccf-4cab-a6c8-e906ea536b6d', '8dae3789-436f-4689-999b-9297b43fad01', 1, '{"id": "mucf-projektbidrag-v1", "title": "Ansökan — MUCF projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_syfte", "type": "long_text", "label": "Syfte och genomförande", "section": "projekt", "guidance": "Vilket problem adresserar projektet, vad ska ni göra, och hur vet ni att det fungerat?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka unga når projektet, och hur är de delaktiga?", "section": "malgrupp", "guidance": "Ungas egen delaktighet i planering och genomförande väger tungt i bedömningen.", "required": true, "maxLength": 3000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.45103+00'),
	('e05bb982-d294-40c2-84e4-f00f4c51974c', '99920797-c699-40fc-ac6e-c5cc631aced0', 1, '{"id": "kommun-forsorjningsstod-v1", "title": "Ansökan — Försörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "hushall_vuxna", "max": 10, "min": 1, "type": "number", "label": "Antal vuxna i hushållet", "section": "hushall", "required": true, "canonicalKey": "person.householdAdults"}, {"key": "hushall_barn", "max": 15, "min": 0, "type": "number", "label": "Antal barn som bor hemma", "section": "hushall", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "inkomst_manad", "min": 0, "type": "currency", "label": "Hushållets inkomster per månad (kr)", "section": "ekonomi", "guidance": "Räkna ihop lön, ersättningar och bidrag före skatt. Ungefärligt räcker i förberedelsen — kommunen begär exakta underlag.", "required": true, "canonicalKey": "person.monthlyHouseholdIncome"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har hushållet sparade medel eller tillgångar som kan användas till försörjningen?", "section": "ekonomi", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna", "section": "ekonomi", "guidance": "T.ex. sparkonto, bil, värdepapper. Kommunen prövar alltid tillgångar först — att redovisa dem öppet undviker kompletteringar.", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "behov_beskrivning", "type": "long_text", "label": "Beskriv din situation och vad du behöver stöd till", "section": "behov", "guidance": "Konkret: vad har hänt, vad räcker inte pengarna till, och vad gör du själv för att förändra situationen?", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hushall", "title": "Hushållet"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "behov", "title": "Din situation"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.45312+00'),
	('259be23e-4d1a-49d7-b72e-4763d3480338', '6a39173a-06b8-4892-a8b9-ab0312bb2cc8', 1, '{"id": "fk-bostadsbidrag-barnfamiljer-v1", "title": "Ansökan — Bostadsbidrag till barnfamiljer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hemma (helt eller växelvis)", "section": "sokande", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 500, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "guidance": "Bidraget beräknas delvis på ytan — siffran står i hyresavtalet.", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Hushållets beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bostadsbidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav. Ta i lite uppåt hellre än neråt.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.454814+00'),
	('829c53fe-ef5f-4629-8bb5-4183c2727ca7', '32eb2795-dcb4-473a-b76f-df14f8883ff4', 1, '{"id": "majblomman-bidrag-barn-v1", "title": "Ansökan — Majblomman, bidrag till barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "behov_vad", "type": "long_text", "label": "Vad söker ni bidrag för?", "section": "behov", "guidance": "Något konkret som gör skillnad för barnet: en fritidsaktivitet, kläder, utrustning, en cykel. Majblomman ger till barnet, inte till hushållets löpande utgifter.", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "max": 20000, "min": 1, "type": "currency", "label": "Ungefärligt belopp (kr)", "section": "behov", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "situation", "type": "long_text", "label": "Beskriv kort familjens situation", "section": "behov", "guidance": "Varför räcker pengarna inte till det här just nu? Kortfattat räcker.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet"}, {"key": "behov", "title": "Vad ni söker för"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.456735+00'),
	('2fa090f4-db67-4df8-8f4f-61a1dc9cc26a', '70b8688c-0646-44a8-9a91-af94cada48bc', 1, '{"id": "af-stod-start-naringsverksamhet-v1", "title": "Ansökan — Stöd till start av näringsverksamhet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?", "section": "sokande", "guidance": "Stödet förutsätter inskrivning — beslutet fattas av din handläggare.", "required": true}, {"key": "affarside", "type": "long_text", "label": "Beskriv affärsidén", "section": "verksamhet", "guidance": "Vad ska du sälja, till vem, och varför finns det efterfrågan? Konkreta belägg (kundkontakter, erfarenhet, marknadskännedom) väger tyngre än visioner.", "required": true, "maxLength": 4000}, {"key": "verksamhet_start", "type": "date", "label": "Planerad start", "section": "plan", "required": true}, {"key": "har_affarsplan", "type": "boolean", "label": "Har du en skriftlig affärsplan?", "section": "plan", "required": true}, {"key": "forsorjning", "type": "long_text", "label": "Hur försörjer du dig under uppstarten?", "section": "plan", "guidance": "Aktivitetsstödet är tidsbegränsat — visa att kalkylen håller tills verksamheten bär sig.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Affärsidén"}, {"key": "plan", "title": "Planen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.458247+00'),
	('bd4baa5d-4553-4a8f-98d8-5496f07b8a6a', '341416fd-513a-4d90-98fc-622dac87253a', 1, '{"id": "kulturradet-projektbidrag-musik-v1", "title": "Ansökan — Kulturrådet, projektbidrag musik (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "guidance": "Tio siffror. Kontrollsiffran valideras — ett felskrivet nummer är en vanlig avslagsorsak på formalia.", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska genomföras, av vem, för vilken publik — och vad skiljer det från er ordinarie verksamhet?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ovrig_finansiering", "type": "long_text", "label": "Beskriv övrig finansiering", "section": "budget", "guidance": "Egna medel, andra bidrag, intäkter. Lämna tomt om allt söks här.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.460083+00'),
	('f13de8d9-b6ce-441b-9dae-750d97886ba3', '5c96a984-730a-4687-8d55-ffdb56fa4cda', 1, '{"id": "fk-bostadsbidrag-unga-v1", "title": "Ansökan — Bostadsbidrag för unga (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 300, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Din beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.462531+00'),
	('587b2c5a-c682-4cd8-b019-db51d20da642', 'a63bb697-3963-4ab4-8ce7-7e1595e5346a', 1, '{"id": "fk-underhallsstod-v1", "title": "Ansökan — Underhållsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hos dig", "section": "barnen", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "underhall_idag", "type": "long_text", "label": "Hur fungerar underhållet i dag?", "section": "underhall", "guidance": "Betalar den andra föräldern inget, för lite eller oregelbundet? Konkret — det avgör vilken väg Försäkringskassan tar.", "required": true, "maxLength": 2000}, {"key": "har_avtal", "type": "boolean", "label": "Finns avtal eller dom om underhållsbidrag?", "section": "underhall", "required": true}, {"key": "avtal_beskrivning", "type": "long_text", "label": "Beskriv avtalet/domen kort", "section": "underhall", "guidance": "Belopp och datum räcker — dokumentet kan bifogas hos Försäkringskassan.", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_avtal"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnen", "title": "Barnen"}, {"key": "underhall", "title": "Underhållet i dag"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.464433+00'),
	('f27e396c-f15c-46f7-af7c-cbb11f40fa0c', '472f3ec4-3cd2-46af-b29e-5f55dd1cd470', 1, '{"id": "pm-bostadstillagg-v1", "title": "Ansökan — Bostadstillägg för pensionärer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Allmän pension, tjänstepension och eventuell utländsk pension — sammanlagt.", "required": true}, {"key": "har_kapital", "type": "boolean", "label": "Har du sparade medel eller tillgångar över ungefär 100 000 kr?", "section": "ekonomi", "guidance": "Kapital påverkar bostadstilläggets storlek — att redovisa det öppet undviker återkrav.", "required": true}, {"key": "kapital_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_kapital"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.466135+00'),
	('80af50d0-a3ec-4ff5-a5d7-b2f757583204', 'aee48bcd-9e74-4cfc-80ef-aa5d4a691e6c', 1, '{"id": "region-glasogonbidrag-barn-v1", "title": "Ansökan — Glasögonbidrag för barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 19, "min": 8, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "har_ordination", "type": "boolean", "label": "Finns ordination eller recept från optiker/ögonläkare?", "section": "barnet", "guidance": "Ordinationen är regionens underlag — utan den kan bidraget inte betalas ut.", "required": true}, {"key": "kostnad", "max": 10000, "min": 1, "type": "currency", "label": "Kostnad för glasögon eller linser (kr)", "section": "barnet", "guidance": "Bidragets tak varierar mellan regioner — hela kostnaden ersätts inte alltid.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och synbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.467647+00'),
	('d879a5dc-c6bb-43bc-aa7c-2a41f355be6f', '125b0d3f-8395-4454-8402-0796efec258f', 1, '{"id": "kommun-skolskjuts-v1", "title": "Ansökan — Skolskjuts (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skolans namn", "section": "eleven", "required": true, "maxLength": 200}, {"key": "arskurs", "type": "text", "label": "Årskurs", "section": "eleven", "guidance": "Kommunens avståndsgräns skiljer sig ofta per årskurs.", "required": true, "maxLength": 20}, {"key": "avstand_km", "max": 200, "min": 0, "type": "number", "label": "Avstånd hem–skola (km)", "section": "eleven", "required": true}, {"key": "skal", "type": "long_text", "label": "Varför behövs skolskjuts?", "section": "eleven", "guidance": "Konkret: avståndet, en trafikfarlig passage, funktionsnedsättning eller växelvis boende. Kommunen prövar mot sina riktlinjer.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och skolvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.469218+00'),
	('68d44b9a-58c3-4619-91ac-ab9a4d98fe8e', '0ecc6405-02b4-4dd6-8c73-c19a09591ebf', 1, '{"id": "arvsfonden-projektstod-v1", "title": "Ansökan — Arvsfonden projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad är nyskapande jämfört med er ordinarie verksamhet? Arvsfonden finansierar inte mer av det ni redan gör.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "malgrupp_delaktighet", "type": "long_text", "label": "Hur är målgruppen delaktig i planering och genomförande?", "section": "malgrupp", "guidance": "Delaktigheten är ett skarpt krav — beskriv mekanismen, inte avsikten: vem ur målgruppen gör vad?", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "overlevnad", "type": "long_text", "label": "Hur lever verksamheten vidare efter projektet?", "section": "budget", "guidance": "Arvsfonden kräver en överlevnadsplan: vem tar över, vem betalar, vad består?", "required": true, "maxLength": 2000}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och överlevnad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.470883+00'),
	('6449d124-ac01-4ebb-9260-a68e4bd3fa53', 'eb52f86a-001b-4da2-bd54-e409c8b96089', 1, '{"id": "csn-studiemedel-v1", "title": "Ansökan — Studiemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "utbildning", "type": "text", "label": "Utbildning och skola", "section": "studier", "guidance": "T.ex. \"Sjuksköterskeprogrammet, Umeå universitet\".", "required": true, "maxLength": 300}, {"key": "studietakt", "type": "select", "label": "Studietakt", "options": [{"label": "Heltid (100 %)", "value": "100"}, {"label": "75 %", "value": "75"}, {"label": "Halvtid (50 %)", "value": "50"}], "section": "studier", "required": true}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod du söker för", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "vill_lana", "type": "boolean", "label": "Vill du även ta studielån (utöver bidraget)?", "section": "ekonomi", "guidance": "Lånedelen är frivillig och kan väljas per vecka — det går att ångra sig senare.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "ekonomi", "title": "Bidrag och lån"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.472589+00'),
	('e3cbdbed-487c-4d22-96f4-a18c8c0ec676', '8368ce79-e59e-441a-b532-8fdc8e643995', 1, '{"id": "fk-aktivitetsersattning-v1", "title": "Ansökan — Aktivitetsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "nedsattning_beskrivning", "type": "long_text", "label": "Beskriv hur arbetsförmågan är nedsatt", "section": "halsa", "guidance": "Med egna ord: vad klarar du inte i dag som ett arbete kräver? Försäkringskassan gör alltid den medicinska prövningen — din beskrivning ska stämma med läkarintyget, inte ersätta det.", "required": true, "maxLength": 4000}, {"key": "har_lakarintyg", "type": "boolean", "label": "Finns ett aktuellt läkarintyg eller läkarutlåtande?", "section": "halsa", "guidance": "Läkarutlåtandet är det centrala underlaget — ansökan utan det leder nästan alltid till komplettering.", "required": true}, {"key": "pagaende_insatser", "type": "long_text", "label": "Pågående vård eller insatser", "section": "halsa", "guidance": "T.ex. behandling, rehabilitering, daglig verksamhet. Lämna tomt om inget pågår.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "halsa", "title": "Arbetsförmågan"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.474089+00'),
	('ef79b2fb-67c4-4f65-bbe8-294e901b5801', '095700f4-8d8e-4746-aa9d-cc7b393baa03', 1, '{"id": "pm-aldreforsorjningsstod-v1", "title": "Ansökan — Äldreförsörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Alla pensioner sammanlagt — även utländsk pension räknas.", "required": true}, {"key": "ovriga_inkomster", "min": 0, "type": "currency", "label": "Övriga inkomster per månad (kr)", "section": "ekonomi", "required": false}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har du sparade medel eller tillgångar?", "section": "ekonomi", "guidance": "Tillgångar påverkar prövningen — öppen redovisning undviker återkrav.", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.475896+00'),
	('b3c57987-b31b-4a54-b820-65783b9bff09', 'a15fc2f5-15d4-43d7-9f80-db3711a7eeeb', 1, '{"id": "kommun-elevresor-gymnasiet-v1", "title": "Ansökan — Elevresor gymnasiet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (elev eller vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Gymnasieskolans namn och ort", "section": "eleven", "required": true, "maxLength": 200}, {"key": "avstand_km", "max": 300, "min": 0, "type": "number", "label": "Resväg hem–skola (km)", "section": "eleven", "guidance": "Gränsen är normalt sex kilometer närmaste väg.", "required": true}, {"key": "har_studiehjalp", "type": "boolean", "label": "Har eleven studiehjälp från CSN?", "section": "eleven", "guidance": "Elevresestödet förutsätter studiehjälp — den kommer automatiskt för de flesta gymnasieelever under 20.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och resvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.477558+00'),
	('6d97bc64-9248-4d22-a8a5-75bd2bd130c0', '4a5c9a5c-bfce-4759-a9e1-5ef9286562b1', 1, '{"id": "kommun-bostadsanpassningsbidrag-v1", "title": "Ansökan — Bostadsanpassningsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen och hur den påverkar boendet", "section": "behov", "guidance": "Konkret ur vardagen: trösklar, trappor, badrum. Intyg från arbetsterapeut eller läkare styrker behovet.", "required": true, "maxLength": 3000}, {"key": "anpassning", "type": "long_text", "label": "Vilken anpassning söker du bidrag för?", "section": "behov", "guidance": "T.ex. ramp vid entrén, borttagna trösklar, dörrautomatik, anpassat badrum.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "behov", "guidance": "Offert från entreprenör räcker — kommunen kan begära fler.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "har_intyg", "type": "boolean", "label": "Finns intyg från arbetsterapeut, läkare eller annan sakkunnig?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Behovet och anpassningen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.478939+00'),
	('048b92fc-9d4c-43de-a59e-937b10a9ccb5', '2860dbb0-554f-4653-8cbb-c248cef4bdc7', 1, '{"id": "csn-omstallningsstudiestod-v1", "title": "Ansökan — Omställningsstudiestöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "arbetsliv_ar", "max": 50, "min": 0, "type": "number", "label": "Ungefär hur många år har du arbetat (minst 16 h/vecka)?", "section": "arbetsliv", "guidance": "Kravet är i genomsnitt minst 16 timmar i veckan under minst 8 år.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du planerar", "section": "studier", "required": true, "maxLength": 300}, {"key": "starkning_beskrivning", "type": "long_text", "label": "Hur stärker utbildningen din ställning på arbetsmarknaden?", "section": "studier", "guidance": "Det här är prövningens kärna: koppla utbildningen till faktisk efterfrågan — en bransch som rekryterar, en roll din arbetsgivare behöver. Söktrycket är högt och generiska motiveringar sållas bort.", "required": true, "maxLength": 4000}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "arbetsliv", "title": "Ditt arbetsliv"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.480283+00'),
	('a4e779f2-a246-47aa-9724-628feeb8fb1c', '2fa40993-227e-4608-9b2a-9afbc271ccc1', 1, '{"id": "vinnova-innovativa-startups-v1", "title": "Ansökan — Vinnova Innovativa startups (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Bolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "losning_beskrivning", "type": "long_text", "label": "Beskriv lösningen och vad som är nyskapande", "section": "losning", "guidance": "Vad finns i dag, och vad gör er lösning väsentligt bättre? Vinnova jämför mot faktiska alternativ — belägg väger tyngre än vision.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "kundbevis", "type": "long_text", "label": "Vilka belägg finns för efterfrågan?", "section": "marknad", "guidance": "Kunddialoger, piloter, avsiktsförklaringar, betalande användare — det ni faktiskt har.", "required": true, "maxLength": 3000}, {"key": "team_beskrivning", "type": "long_text", "label": "Teamet och dess förmåga att genomföra", "section": "marknad", "guidance": "Roller, relevant erfarenhet och hur mycket tid nyckelpersonerna lägger.", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "budget", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "max": 300000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Bolaget"}, {"key": "losning", "title": "Lösningen"}, {"key": "marknad", "title": "Marknad och team"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.481919+00'),
	('68712b72-d3f1-4d1b-836d-b1fb833261b2', '352541d9-0db6-42d3-858b-ce7be920f555', 1, '{"id": "tillvaxtverket-affarsutvecklingscheckar-v1", "title": "Ansökan — Affärsutvecklingscheck (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_anstallda", "max": 500, "min": 0, "type": "number", "label": "Antal anställda", "section": "foretag", "guidance": "Checkarna riktar sig typiskt till företag med 2–49 anställda — regionens villkor styr.", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv utvecklingsinsatsen", "section": "insats", "guidance": "Vad ska den externa kompetensen göra, och vad ska vara annorlunda i företaget efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "extern_leverantor", "type": "text", "label": "Extern leverantör/konsult (om känd)", "section": "insats", "required": false, "maxLength": 200}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "guidance": "Checken täcker normalt högst hälften av kostnaden — resten är egen insats.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "insats", "title": "Utvecklingsinsatsen"}, {"key": "budget", "title": "Kostnad och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.484363+00'),
	('13fd5ebb-ae98-4d68-8253-9b592179f8df', '3f29bfda-af66-4da9-9f5d-4700773d645d', 1, '{"id": "tillvaxtverket-regionalt-investeringsstod-v1", "title": "Ansökan — Regionalt investeringsstöd (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsort", "type": "text", "label": "Verksamhetsort (kommun)", "section": "foretag", "guidance": "Orten avgör stödområdestillhörigheten (A/B) och därmed stödnivån.", "required": true, "maxLength": 100}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Byggnader, maskiner eller inventarier — och hur investeringen ökar sysselsättningen eller konkurrenskraften på orten.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjas före ansökan", "section": "investering", "guidance": "En påbörjad investering diskvalificerar hela ansökan — beställ inget förrän ansökan är inne.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "investering", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "investering", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.487729+00'),
	('e4154ce8-501e-49df-83b5-fc24fa5fc65b', 'fb27a1f7-b763-4ab8-b8b4-188c9fd719b8', 1, '{"id": "jordbruksverket-startstod-unga-v1", "title": "Ansökan — Startstöd unga jordbrukare (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten", "section": "foretaget", "guidance": "Inriktning (växtodling, djurhållning, trädgård, rennäring), omfattning och om du startar nytt eller tar över.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "overtagande_datum", "type": "date", "label": "Datum för start eller övertagande", "section": "foretaget", "required": true}, {"key": "utbildning_erfarenhet", "type": "long_text", "label": "Din utbildning och erfarenhet inom området", "section": "plan", "guidance": "Naturbruksutbildning, kurser eller praktisk erfarenhet — kravet kan uppfyllas på flera sätt.", "required": true, "maxLength": 2000}, {"key": "har_affarsplan", "type": "boolean", "label": "Finns en skriftlig affärsplan?", "section": "plan", "guidance": "Affärsplanen är obligatorisk bilaga hos Jordbruksverket.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "foretaget", "title": "Företaget du startar eller tar över"}, {"key": "plan", "title": "Affärsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.489607+00'),
	('52818dcb-89c5-4f06-b138-b5d1c8771010', '9ea8f3b8-7e5a-411f-9c3f-2e11ee86bb53', 1, '{"id": "jordbruksverket-investeringsstod-v1", "title": "Ansökan — Investeringsstöd jordbruk (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller företag)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Vad ska byggas eller köpas, och hur stärker det verksamheten (produktion, djurvälfärd, miljö, energi)?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad investeringskostnad (kr)", "section": "investering", "guidance": "Offerter styrker kalkylen — stödandelen räknas på faktiska kostnader.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjats före ansökan", "section": "investering", "required": true}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.491257+00'),
	('9dcc2883-a262-4285-bb74-33eb2784e11c', '0b1994e6-e493-4e2e-b231-7ebecc33ef13', 1, '{"id": "rf-lok-stod-v1", "title": "Ansökan — LOK-stöd (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "forbund", "type": "text", "label": "Specialidrottsförbund", "section": "forening", "guidance": "T.ex. Svenska Fotbollförbundet — anslutningen är ett krav.", "required": true, "maxLength": 200}, {"key": "antal_aktiviteter", "max": 10000, "min": 1, "type": "number", "label": "Ungefärligt antal gruppaktiviteter per termin (deltagare 7–25 år)", "section": "verksamhet", "guidance": "LOK-stödet räknas per genomförd gruppaktivitet och deltagare — närvaroregistrering i IdrottOnline är underlaget.", "required": true}, {"key": "registrerar_narvaro", "type": "boolean", "label": "Registrerar föreningen närvaro digitalt (t.ex. IdrottOnline)?", "section": "verksamhet", "guidance": "Utan närvaroregistrering kan stödet inte betalas ut — börja registrera innan perioden ansöks.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Föreningen"}, {"key": "verksamhet", "title": "Aktiviteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.493388+00'),
	('5e5f7919-6e67-41f2-bbbf-0978fb281ad4', '13e34d24-98ca-4928-838a-6d600c2af368', 1, '{"id": "kulturradet-skapande-skola-v1", "title": "Ansökan — Skapande skola (förberedelse)", "fields": [{"key": "huvudman_namn", "type": "text", "label": "Huvudmannens namn", "section": "huvudman", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "huvudman", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_elever", "max": 100000, "min": 1, "type": "number", "label": "Antal elever som omfattas", "section": "insatser", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv kulturinsatserna", "section": "insatser", "guidance": "Vilka professionella kulturaktörer, vilka konstformer, och hur eleverna är delaktiga — inte bara publik.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "lasar_period", "type": "date_range", "label": "Period (läsår)", "section": "insatser", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "huvudman", "title": "Huvudmannen"}, {"key": "insatser", "title": "Kulturinsatserna"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.495166+00'),
	('06e3e2cf-d8e8-40fb-b30a-c7df1abc8983', '7a5794e7-0ad6-4820-a360-76fad5023a76', 1, '{"id": "konstnarsnamnden-internationellt-kulturutbyte-v1", "title": "Ansökan — Internationellt kulturutbyte (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "utbyte_beskrivning", "type": "long_text", "label": "Beskriv utbytet", "section": "utbyte", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling just nu?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utbyte_period", "type": "date_range", "label": "Period", "section": "utbyte", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Finns en inbjudan eller bekräftelse från mottagande part?", "section": "utbyte", "guidance": "Inbjudan väger tungt — utan den bedöms utbytet som oplanerat.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "utbyte", "title": "Utbytet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.496593+00'),
	('97a67cc2-8493-4493-911c-5bd1e4f859ec', '9f891fb9-175e-4d85-9c28-7dd3de6d146e', 1, '{"id": "filminstitutet-kortfilmsstod-v1", "title": "Ansökan — Kortfilmsstöd (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Produktionsbolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "film_titel", "type": "text", "label": "Filmens arbetstitel", "section": "film", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "synopsis", "type": "long_text", "label": "Synopsis och konstnärlig vision", "section": "film", "guidance": "Berättelsen, formen och varför den här filmen behöver göras — konsulenten läser hundratals, det specifika bär.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "regissor", "type": "text", "label": "Regissör och tidigare verk", "section": "film", "required": true, "maxLength": 300}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Produktionsbolaget"}, {"key": "film", "title": "Filmen"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.498397+00'),
	('a780065a-dc00-47bd-9c26-48f1bc92aab9', 'fd6a0c95-a691-42b7-b3d6-e7f4d39fbb04', 1, '{"id": "musikverket-projektbidrag-v1", "title": "Ansökan — Musikverket projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv musikprojektet", "section": "projekt", "guidance": "Vad ska göras, av vilka, och vad tillför det musiklivet utöver er egen verksamhet?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "medverkande", "type": "long_text", "label": "Medverkande musiker/aktörer", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.500106+00'),
	('47858973-adca-4d0d-a611-7e698dea1047', '32f951b7-0352-485d-a7a7-f8290c8feabe', 1, '{"id": "postkodstiftelsen-projektstod-v1", "title": "Ansökan — Postkodstiftelsen projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Ett avgränsat projekt med tydlig början och slut — stiftelsen finansierar inte löpande verksamhet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "forvantad_effekt", "type": "long_text", "label": "Vilken förändring ska projektet åstadkomma?", "section": "projekt", "guidance": "Formulera som förändring för målgruppen, inte som aktiviteter.", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.501765+00'),
	('beb646bf-00e7-45c9-a7b4-961cf8f005d1', '715ee057-3e05-4bea-b829-ba4ad8cbca5e', 1, '{"id": "mucf-organisationsbidrag-v1", "title": "Ansökan — MUCF organisationsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_medlemmar", "max": 1000000, "min": 1, "type": "number", "label": "Totalt antal medlemmar", "section": "medlemmar", "required": true}, {"key": "andel_unga", "max": 100, "min": 0, "type": "percentage", "label": "Andel medlemmar 6–25 år (%)", "section": "medlemmar", "guidance": "Kravet är minst 60 % — medlemsregistret är underlaget och MUCF granskar det.", "required": true}, {"key": "antal_medlemsforeningar", "max": 10000, "min": 1, "type": "number", "label": "Antal medlemsföreningar/lokalavdelningar", "section": "medlemmar", "guidance": "Nationell spridning krävs — normalt verksamhet i minst fem län.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "medlemmar", "title": "Medlemmar och struktur"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.503596+00'),
	('ea7e5c31-329b-4b12-93cd-b120cae57eb2', '8896ddc9-a1da-4818-8ca6-488e9b4e592c', 1, '{"id": "kreativa-europa-samarbetsprojekt-v1", "title": "Ansökan — Kreativa Europa samarbetsprojekt (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partnerskap_beskrivning", "type": "long_text", "label": "Partnerskapet (organisationer och länder)", "section": "projekt", "guidance": "Minst tre organisationer från tre olika länder krävs — ange samtliga med land.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och dess europeiska dimension", "section": "projekt", "guidance": "Vad tillför samarbetet som inte hade hänt nationellt? EU-mervärdet är ett bedömningskriterium, inte en formalitet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.52416+00'),
	('22ddb7cc-2f86-4340-bb12-5ba502318ec4', '58a6f196-a76f-48c9-ab8b-8cc37f41a9b7', 1, '{"id": "boverket-allmanna-samlingslokaler-v1", "title": "Ansökan — Stöd till allmänna samlingslokaler (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Föreningens/stiftelsens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "lokal_beskrivning", "type": "long_text", "label": "Beskriv lokalen och hur den används av allmänheten", "section": "lokal", "guidance": "Öppenheten är kravet: vilka utomstående grupper använder lokalen i dag, och hur bokar de?", "required": true, "maxLength": 3000}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Vad ska byggas, köpas eller rustas upp?", "section": "lokal", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "budget", "guidance": "Stödet täcker högst halva kostnaden — resten är egen finansiering.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "lokal", "title": "Lokalen och åtgärden"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.506252+00'),
	('327c2b8d-be6c-4227-86fa-b7e346e36751', 'e8f61700-5a3c-4b21-bdd5-ef341a30b736', 1, '{"id": "naturvardsverket-ladda-bilen-v1", "title": "Ansökan — Ladda bilen (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_laddpunkter", "max": 1000, "min": 1, "type": "number", "label": "Antal laddpunkter", "section": "laddning", "required": true}, {"key": "plats_beskrivning", "type": "long_text", "label": "Var installeras laddpunkterna, och vilka använder dem?", "section": "laddning", "guidance": "Stödet gäller laddning för boende eller anställda — inte publika laddstationer.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "laddning", "guidance": "Bidraget är högst halva kostnaden per laddpunkt, med takbelopp.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "laddning", "title": "Laddpunkterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.508603+00'),
	('88d92f8b-ab95-4c12-885a-39e6f42c8231', '73676412-9575-4972-a5e3-7b01393e0168', 1, '{"id": "raa-kulturarvsbidrag-v1", "title": "Ansökan — Kulturarvsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv kulturarvsinsatsen", "section": "projekt", "guidance": "Vad ska bevaras, användas eller utvecklas — och hur blir det tillgängligt för fler?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.510314+00'),
	('35fef705-10c6-4bd2-9209-6f6a98bf890b', '2fdec643-5329-4cba-82ac-0ab8265083f5', 1, '{"id": "lansstyrelsen-bygdemedel-v1", "title": "Ansökan — Bygdemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Föreningens/kommunens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "bygd_beskrivning", "type": "long_text", "label": "Vilken bygd gäller det, och hur berörs den av vatten- eller vindkraft?", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Allmännyttan är kravet: vem i bygden får glädje av investeringen, utöver den egna föreningen?", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.512262+00'),
	('a286079b-d261-4ed4-aa83-45592861e2fe', 'b2b95a8a-5434-45a4-ae1d-c5da68c8c0a9', 1, '{"id": "csn-utlandsstudier-v1", "title": "Ansökan — Studiemedel för utlandsstudier (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "studie_land", "type": "text", "label": "Studieland", "section": "studier", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "utbildning", "type": "text", "label": "Utbildning och lärosäte", "section": "studier", "guidance": "Kontrollera att utbildningen är godkänd för studiemedel i CSN:s tjänst INNAN du tackar ja till platsen.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "terminsavgift", "min": 0, "type": "currency", "label": "Terminsavgift om sådan finns (kr)", "section": "studier", "guidance": "Merkostnadslån kan täcka undervisningsavgifter — lämna tomt om avgift saknas.", "required": false}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna utomlands"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.547154+00'),
	('6d45abc2-912f-461f-b3c5-d9620bbe2407', '41a0986f-d8cf-427e-b731-b63cb5a70a8f', 1, '{"id": "kulturradet-verksamhetsbidrag-scenkonst-v1", "title": "Ansökan — Verksamhetsbidrag scenkonst (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Gruppens/organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten kommande år", "section": "verksamhet", "guidance": "Repertoar, produktioner, spelplatser och publik — verksamhetsbidraget bedöms på helheten, inte enskilda projekt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "antal_forestallningar", "max": 2000, "min": 1, "type": "number", "label": "Planerat antal föreställningar per år", "section": "verksamhet", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Gruppen/organisationen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.514525+00'),
	('a3cbfb97-1f27-458e-ba43-c3c0de7c6941', '2c0487d4-d4bb-497d-afc6-578c035fe7d2', 1, '{"id": "konstnarsnamnden-arbetsstipendium-v1", "title": "Ansökan — Arbetsstipendium (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstområde", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv din konstnärliga verksamhet och dina planer", "section": "verksamhet", "guidance": "Stipendiet bedöms på konstnärlig kvalitet och aktivitet — konkreta verk, uppdrag och planer väger tyngre än ambitioner.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "meriter", "type": "long_text", "label": "Viktigaste verk och uppdrag (senaste åren)", "section": "verksamhet", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Din konstnärliga verksamhet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.51692+00'),
	('2a9b00c2-ffb2-48ac-a5af-3aaea6046a3d', '3ef92ea6-3338-4b14-8e4b-eb12ace30e0b', 1, '{"id": "konstnarsnamnden-kulturbryggan-v1", "title": "Ansökan — Kulturbryggan (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vad som är nyskapande", "section": "projekt", "guidance": "Kulturbryggan finansierar det oprövade — beskriv vad som skiljer projektet från befintlig praxis, inte bara att det är nytt för er.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "ovriga_finansiarer", "type": "long_text", "label": "Övriga finansiärer (sökta eller beviljade)", "section": "projekt", "guidance": "Kulturbryggan ser gärna fler finansieringskällor — redovisa öppet vad som är sökt respektive beviljat.", "required": false, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.518965+00'),
	('2ebc36a3-b817-494d-8fb1-d66fba67c625', '3b982049-9767-4a02-8dfd-e2cf9df41b91', 1, '{"id": "erasmus-mobilitet-skola-vuxen-v1", "title": "Ansökan — Erasmus+ mobilitet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System — utan OID kan ansökan inte lämnas in.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "mobilitet_beskrivning", "type": "long_text", "label": "Beskriv mobiliteterna och deras syfte", "section": "mobilitet", "guidance": "Vilka åker, vart, och hur tas lärdomarna om hand i organisationen efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_deltagare", "max": 500, "min": 1, "type": "number", "label": "Antal deltagare", "section": "mobilitet", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "mobilitet", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "mobilitet", "title": "Mobiliteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.521059+00'),
	('a68b4abb-d7e3-4299-9950-4ccd3567590f', 'a982ea09-aeab-4287-841b-c09fd33456bc', 1, '{"id": "erasmus-ka2-smaskaliga-partnerskap-v1", "title": "Ansökan — Erasmus+ småskaliga partnerskap (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "partnerskap", "guidance": "Minst en partner i ett annat programland krävs.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv samarbetet", "section": "partnerskap", "guidance": "Småskaliga partnerskap är instegsformatet — enklare aktiviteter, lägre budget, men samma krav på tydligt syfte.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "partnerskap", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "partnerskap", "title": "Partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.52264+00'),
	('81efdc71-0606-45d6-b5ec-50d27639ccaf', '5bc51a6c-ac08-4624-aa47-f770913ebc7b', 1, '{"id": "vinnova-planeringsbidrag-eu-v1", "title": "Ansökan — Planeringsbidrag EU-ansökan (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "eu_utlysning", "type": "text", "label": "Vilken EU-utlysning avser ni att söka?", "section": "eu", "guidance": "Program och utlysningsnamn — planeringsbidraget kräver ett konkret mål.", "required": true, "maxLength": 300}, {"key": "planering_beskrivning", "type": "long_text", "label": "Vad ska planeringsarbetet omfatta?", "section": "eu", "guidance": "Konsortiebyggande, ansökningsskrivning, resor — det bidraget faktiskt får användas till.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "eu", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "eu", "title": "EU-ansökan som planeras"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.526079+00'),
	('7185114b-bf80-45a5-b38a-f7cc096f661a', 'eafe09c2-a9be-4c64-8dd2-f905c264c78a', 1, '{"id": "mucf-solidaritetskaren-v1", "title": "Ansökan — Europeiska solidaritetskåren (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "har_kvalitetsmarkning", "type": "boolean", "label": "Har organisationen giltig Quality Label?", "section": "org", "guidance": "Kvalitetsmärkningen söks separat och måste finnas innan volontärprojekt kan beviljas.", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv volontärprojektet", "section": "volontar", "guidance": "Vad gör volontärerna, vilket stöd får de, och vilken nytta skapar projektet lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_volontarer", "max": 100, "min": 1, "type": "number", "label": "Antal volontärer", "section": "volontar", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "volontar", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "volontar", "title": "Volontärprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.527528+00'),
	('2b0b2a6c-6aa3-4abc-a2bf-b95bf95f5c89', 'cee75a50-3525-4555-bafc-6743751cf93a', 1, '{"id": "esf-kompetensutveckling-v1", "title": "Ansökan — ESF kompetensutveckling (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka anställda/deltagare omfattas, och vad behöver de?", "section": "insats", "guidance": "ESF bedömer kopplingen till arbetsmarknadens behov — konkret kompetensgap, inte allmän utbildning.", "required": true, "maxLength": 4000}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv insatserna", "section": "insats", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kan_forfinansiera", "type": "boolean", "label": "Kan organisationen förfinansiera kostnaderna?", "section": "ekonomi", "guidance": "ESF betalar ut i efterskott mot redovisning — likviditeten måste bära projektet under tiden.", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "insats", "required": true, "canonicalKey": "project.dateRange"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "ekonomi", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "insats", "title": "Kompetensinsatsen"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.52894+00'),
	('2d69bf55-7787-4075-854b-c9931e36161f', 'ec1cab90-c695-4f9f-b5c7-e2a4785dce42', 1, '{"id": "si-creative-force-v1", "title": "Ansökan — Creative Force (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "projekt", "guidance": "Ett etablerat partnerskap i mållandet är kärnan i programmet.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Hur stärker projektet demokrati, yttrandefrihet eller mänskliga rättigheter genom kultur eller media? Mekanismen bedöms, inte avsikten.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnern"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.530465+00'),
	('b6c3a9b9-284c-416c-9f93-f03136d36441', '357e2489-1440-4e44-8fb1-d528a58df995', 1, '{"id": "radiohjalpen-projektbidrag-v1", "title": "Ansökan — Radiohjälpens projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "niokonto", "type": "text", "label": "90-kontonummer", "section": "sokande", "guidance": "T.ex. 90 1234-5. Kontot kontrolleras mot Svensk Insamlingskontroll.", "required": true, "maxLength": 20}, {"key": "fond", "type": "select", "label": "Vilken utlysning/fond söker ni ur?", "options": [{"label": "Världens Barn", "value": "varldens_barn"}, {"label": "Musikhjälpen", "value": "musikhjalpen"}, {"label": "Victoriafonden", "value": "victoriafonden"}, {"label": "Annan aktuell utlysning", "value": "other"}], "section": "projekt", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.574694+00'),
	('593a97fb-1319-40b7-ae80-c812285511b2', 'f22969a7-5225-427b-82e3-d9fc1ea37ced', 1, '{"id": "vr-projektbidrag-v1", "title": "Ansökan — Vetenskapsrådet projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "har_doktorsexamen", "type": "boolean", "label": "Har du doktorsexamen?", "section": "sokande", "guidance": "Behörighetskrav — examensår kan påverka vilka bidragsformer som är öppna.", "required": true}, {"key": "larosate", "type": "text", "label": "Medelsförvaltande lärosäte", "section": "sokande", "guidance": "Bidraget förvaltas av ett svenskt lärosäte — det ska bekräfta åtagandet.", "required": true, "maxLength": 200}, {"key": "forskningsplan", "type": "long_text", "label": "Forskningsplanens kärna", "section": "forskning", "guidance": "Frågeställning, metod och förväntade resultat — sakkunniggranskningen bedömer originalitet och genomförbarhet.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "forskning", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "forskning", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Forskaren"}, {"key": "forskning", "title": "Forskningsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.531558+00');
INSERT INTO public.application_schemas VALUES
	('275123b0-0405-4dda-9ae3-544adaa310e4', '655ce725-4921-4ead-8c71-a65db15d9bd3', 1, '{"id": "energimyndigheten-energieffektivisering-v1", "title": "Ansökan — Stöd till energieffektivisering (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv energiåtgärden", "section": "atgard", "guidance": "Vilken energianvändning minskas, med vilken teknik, och vad är beräknad besparing i kWh?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "besparing_kwh", "max": 100000000, "min": 1, "type": "number", "label": "Beräknad energibesparing (kWh/år)", "section": "atgard", "guidance": "En energikartläggning eller leverantörsberäkning styrker siffran.", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "atgard", "title": "Åtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.532855+00'),
	('16f2c15e-54ff-4782-a25e-ce4cbd7794ee', '01f8696b-ebdc-417b-9b71-d1160373303d', 1, '{"id": "energimyndigheten-industriklivet-v1", "title": "Ansökan — Industriklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och utsläppsminskningen", "section": "projekt", "guidance": "Industriklivet finansierar åtgärder mot processutsläpp — kvantifiera minskningen i CO2-ekvivalenter och beskriv teknikens mognadsgrad.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 100000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "projekt", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.534287+00'),
	('df0e55eb-ad1f-4623-b16e-5e4ac2bd8fa3', '4fa0d5eb-1e47-4923-9627-6ef69a548588', 1, '{"id": "naturvardsverket-klimatklivet-v1", "title": "Ansökan — Klimatklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Sökandens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv åtgärden", "section": "atgard", "guidance": "Klimatklivet rangordnar på klimatnytta per investerad krona — utsläppsminskningen ska vara beräknad och beräkningen redovisbar.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 10000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "atgard", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Investeringskostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att åtgärden inte påbörjats före ansökan", "section": "atgard", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Sökande"}, {"key": "atgard", "title": "Klimatåtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.535527+00'),
	('b47423e8-3778-4bab-98a7-d8cc41cf9390', 'e8893c24-c7c5-48c5-bad2-7e81f51e8e19', 1, '{"id": "naturvardsverket-lona-v1", "title": "Ansökan — LONA lokala naturvårdssatsningen (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "guidance": "LONA söks via kommunen — föreningar deltar som initiativtagare.", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommun", "type": "text", "label": "Kommun som står bakom ansökan", "section": "sokande", "required": true, "maxLength": 100}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv naturvårdsinsatsen", "section": "projekt", "guidance": "Vad görs, var, och vilken naturvårds- eller friluftsnytta skapas lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "guidance": "LONA täcker högst halva kostnaden.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Naturvårdsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.538033+00'),
	('8673351a-8199-42eb-b581-7e448c8094cb', 'f9e5e1aa-035c-4cc3-846a-892a17e7ebd8', 1, '{"id": "kulturradet-inkopsstod-bibliotek-v1", "title": "Ansökan — Inköpsstöd till folkbibliotek (förberedelse)", "fields": [{"key": "kommun_namn", "type": "text", "label": "Kommunens namn", "section": "kommun", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "kommun", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "inkop_beskrivning", "type": "long_text", "label": "Hur ska stödet användas?", "section": "inkop", "guidance": "Inköp av litteratur för barn och unga prioriteras; stödet får inte ersätta kommunens egen medieanslag — egeninsatsen ska bestå.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "eget_anslag", "min": 0, "type": "currency", "label": "Kommunens eget medieanslag i år (kr)", "section": "inkop", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "inkop", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "kommun", "title": "Kommunen"}, {"key": "inkop", "title": "Inköpen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.54033+00'),
	('fef255e8-f70b-4218-aacb-c4d3a0929cd4', '0cafa3dc-381f-4fe9-82be-dfed79fc9d36', 1, '{"id": "kulturradet-litteraturstod-v1", "title": "Ansökan — Litteraturstöd (förberedelse)", "fields": [{"key": "forlag_namn", "type": "text", "label": "Förlagets namn", "section": "forlag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forlag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "titel", "type": "text", "label": "Titel och författare", "section": "titel", "required": true, "maxLength": 300, "canonicalKey": "project.title"}, {"key": "titel_beskrivning", "type": "long_text", "label": "Beskriv utgivningen", "section": "titel", "guidance": "Litteraturstödet söks efter utgivning och bedöms på kvalitet — beskriv verket sakligt, inte säljande.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "upplaga", "max": 1000000, "min": 1, "type": "number", "label": "Upplaga (exemplar)", "section": "titel", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forlag", "title": "Förlaget"}, {"key": "titel", "title": "Titeln"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.542804+00'),
	('cad2e987-f18b-4ad6-ad78-864f8ba6cff5', 'abbae5ba-41cd-4d64-a370-089591b8727b', 1, '{"id": "migrationsverket-atervandringsbidrag-v1", "title": "Ansökan — Stöd vid frivillig återvandring (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "ursprungsland", "type": "text", "label": "Land du planerar att återvandra till", "section": "atervandring", "required": true, "maxLength": 100}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet som återvandrar", "section": "atervandring", "required": true}, {"key": "planerad_utresa", "type": "date", "label": "Planerad utresa", "section": "atervandring", "required": true}, {"key": "situation_beskrivning", "type": "long_text", "label": "Beskriv din plan för återetableringen", "section": "atervandring", "guidance": "Boende, försörjning och nätverk i ursprungslandet. OBS: beslutet är oåterkalleligt i bidragshänseende — uppehållstillståndet återkallas normalt. Ta det lugnt med beslutet och kontrollera aktuella belopp hos Migrationsverket.", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "atervandring", "title": "Återvandringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.544458+00'),
	('ac5e2ca7-e651-40df-b8ae-4c65f7808a5c', 'b3344631-582f-4f26-b0c1-1d9da050b7c8', 1, '{"id": "af-eures-targeted-mobility-v1", "title": "Ansökan — EURES Targeted Mobility (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "mal_land", "type": "text", "label": "Land där jobbet finns", "section": "jobbet", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "jobb_status", "type": "select", "label": "Var i processen är du?", "options": [{"label": "Kallad till intervju", "value": "interview"}, {"label": "Har jobberbjudande", "value": "offer"}, {"label": "Söker aktivt", "value": "searching"}], "section": "jobbet", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Vilket stöd behöver du?", "section": "jobbet", "guidance": "Intervjuresa, flyttkostnad, språkkurs eller erkännande av examen — beloppen är schabloner per insats. EURES-rådgivaren bekräftar vad som gäller din programperiod.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "jobbet", "title": "Jobbet och flytten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.545863+00'),
	('bc5d1779-879f-4a99-8f21-1de17cd4805a', 'ba3032a0-7fc8-40de-aa75-909e0c0ab2ef', 1, '{"id": "fk-omvardnadsbidrag-v1", "title": "Ansökan — Omvårdnadsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv barnets funktionsnedsättning", "section": "barnet", "guidance": "Diagnos eller svårigheter i vardagen — läkarutlåtandet bär den medicinska bedömningen, din beskrivning bär vardagen.", "required": true, "maxLength": 3000}, {"key": "omvardnadsbehov", "type": "long_text", "label": "Vilken extra omvårdnad och tillsyn behöver barnet?", "section": "barnet", "guidance": "Jämför med barn i samma ålder: vad kräver mer tid, närvaro eller passning — dygnet runt-perspektivet räknas.", "required": true, "maxLength": 4000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om barnets funktionsnedsättning?", "section": "barnet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och behoven"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.548386+00'),
	('ecf026da-401a-4ca9-a915-a39042c42aaf', '9d74542e-d4fd-44f5-a5ae-8548bee7b07e', 1, '{"id": "fk-merkostnadsersattning-v1", "title": "Ansökan — Merkostnadsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "galler_barn", "type": "boolean", "label": "Gäller ansökan ett barn du är vårdnadshavare för?", "section": "sokande", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen", "section": "sokande", "required": true, "maxLength": 3000}, {"key": "merkostnader_ar", "min": 0, "type": "currency", "label": "Uppskattade merkostnader per år (kr)", "section": "kostnader", "guidance": "Räkna bara kostnader du inte skulle ha utan funktionsnedsättningen — och dra av eventuella bidrag som redan täcker dem.", "required": true}, {"key": "merkostnader_beskrivning", "type": "long_text", "label": "Specificera merkostnaderna", "section": "kostnader", "guidance": "Post för post: vad, hur ofta, ungefär vad det kostar per år. Kvitton och intyg stärker.", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "kostnader", "title": "Merkostnaderna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.549783+00'),
	('10a37aca-3bf5-44a5-a69f-80aa8ffeca82', '6df88dc2-0527-49fb-b7be-cd1bcd3e9394', 1, '{"id": "fk-bilstod-v1", "title": "Ansökan — Bilstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "forflyttning", "type": "long_text", "label": "Beskriv svårigheterna att förflytta dig eller resa kollektivt", "section": "behov", "guidance": "Konkret: vad går inte, vad krävs för att det ska gå, och hur varaktigt är det?", "required": true, "maxLength": 4000}, {"key": "har_korkort", "type": "boolean", "label": "Har du (eller den som ska köra) körkort?", "section": "behov", "required": true}, {"key": "behov_anpassning", "type": "long_text", "label": "Behöver bilen anpassas — i så fall hur?", "section": "behov", "guidance": "T.ex. handreglage, ramp eller lyft. Lämna tomt om du inte vet ännu — behovet utreds.", "required": false, "maxLength": 2000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om funktionsnedsättningen?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Förflyttningsbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.551819+00'),
	('3f87c076-84fc-478e-9488-72b89090c68c', 'd258b038-bcd2-4c92-b696-17332a540339', 1, '{"id": "fk-narstaendepenning-v1", "title": "Ansökan — Närståendepenning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "relation", "type": "text", "label": "Din relation till den som är sjuk", "section": "varden", "guidance": "T.ex. förälder, barn, syskon, vän — närstående är den som står den sjuke nära.", "required": true, "maxLength": 200}, {"key": "vard_period", "type": "date_range", "label": "Period du avstår från arbete", "section": "varden", "required": true, "canonicalKey": "project.dateRange"}, {"key": "omfattning", "type": "select", "label": "Omfattning", "options": [{"label": "Hel dag", "value": "full"}, {"label": "Tre fjärdedelar", "value": "three_quarters"}, {"label": "Halv dag", "value": "half"}, {"label": "En fjärdedel", "value": "quarter"}], "section": "varden", "required": true}, {"key": "har_samtycke", "type": "boolean", "label": "Har den sjuke samtyckt till ansökan?", "section": "varden", "guidance": "Samtycke krävs när det är möjligt att lämna.", "required": true}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om den närståendes tillstånd?", "section": "varden", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "varden", "title": "Vården och tiden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.553871+00'),
	('6b02b14b-9c54-4954-afc4-e1d62bd226eb', 'c144f440-1e1e-4d57-9229-3e239b75c5d7', 1, '{"id": "af-etableringsersattning-v1", "title": "Ansökan — Etableringsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "uppehallstillstand_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år fick du uppehållstillstånd?", "section": "sokande", "required": true}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven hos Arbetsförmedlingen?", "section": "etablering", "guidance": "Etableringsprogrammet förutsätter inskrivning — börja där om du inte redan är inskriven.", "required": true}, {"key": "har_barn_hemma", "type": "boolean", "label": "Har du barn som bor hos dig?", "section": "etablering", "guidance": "Med barn hemma kan etableringstillägg bli aktuellt hos Försäkringskassan.", "required": true}, {"key": "bor_ensam", "type": "boolean", "label": "Bor du ensam i egen bostad?", "section": "etablering", "guidance": "Den som bor ensam kan ha rätt till bostadsersättning.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "etablering", "title": "Etableringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.555958+00'),
	('55466ebd-6df3-4e1f-9188-c2678f775308', '019ef51d-398d-459c-a57c-85eec18ac253', 1, '{"id": "csn-hemutrustningslan-v1", "title": "Ansökan — Hemutrustningslån (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommunmottagande_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år togs du emot i en kommun?", "section": "sokande", "guidance": "Lånet söks inom två år från det första kommunmottagandet.", "required": true}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet", "section": "hemmet", "required": true}, {"key": "bostad_typ", "type": "select", "label": "Är bostaden möblerad eller omöblerad?", "options": [{"label": "Omöblerad", "value": "unfurnished"}, {"label": "Möblerad", "value": "furnished"}], "section": "hemmet", "guidance": "Lånebeloppet skiljer sig — omöblerad bostad ger högre lån.", "required": true}, {"key": "aterbetalning_medveten", "type": "boolean", "label": "Jag är medveten om att detta är ett lån som ska betalas tillbaka", "section": "hemmet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hemmet", "title": "Hemmet och behovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.557903+00'),
	('23fb77a2-ccbf-42c9-9ea6-a70479159501', 'cc6b0482-bf43-434e-9a57-8b2ad0c5c77b', 1, '{"id": "csn-studiestartsstod-v1", "title": "Ansökan — Studiestartsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "tidigare_utbildning", "type": "select", "label": "Din senast avslutade utbildning", "options": [{"label": "Grundskola eller kortare", "value": "grundskola"}, {"label": "Påbörjat men inte slutfört gymnasium", "value": "gymnasium_ej_klart"}, {"label": "Slutfört gymnasium", "value": "gymnasium"}], "section": "sokande", "required": true}, {"key": "kommun_kontaktad", "type": "boolean", "label": "Har du kontaktat hemkommunen om studiestartsstödet?", "section": "studier", "guidance": "Kommunen bedömer om du tillhör målgruppen innan CSN kan bevilja.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du vill gå", "section": "studier", "guidance": "Grundskole- eller gymnasienivå, t.ex. komvux.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.559789+00'),
	('4a7a49d9-a302-4a82-9d9d-49b0951a7c84', '2dee0a22-35d6-4d57-bbb2-f66264d3fc9e', 1, '{"id": "csn-inackorderingstillagg-v1", "title": "Ansökan — Inackorderingstillägg (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Elevens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skola och ort", "section": "boendet", "required": true, "maxLength": 300}, {"key": "skoltyp", "type": "select", "label": "Vilken typ av skola?", "options": [{"label": "Fristående gymnasieskola", "value": "independent"}, {"label": "Folkhögskola", "value": "folk_high"}, {"label": "Kommunal gymnasieskola", "value": "municipal"}], "section": "boendet", "guidance": "Fristående skola och folkhögskola → CSN. Kommunal skola → hemkommunen.", "required": true}, {"key": "resvag", "type": "long_text", "label": "Beskriv resvägen mellan hemmet och skolan", "section": "boendet", "guidance": "Avstånd och restid — varför daglig pendling inte fungerar.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om eleven"}, {"key": "boendet", "title": "Skolan och boendet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.561473+00'),
	('e55eba49-2962-4e4c-87a9-947959ea7fce', '6949dd50-4014-4632-ad2f-e5ec791d0ae8', 1, '{"id": "kommun-foreningsbidrag-v1", "title": "Ansökan — Kommunalt föreningsbidrag (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "medlemsantal", "max": 1000000, "min": 1, "type": "number", "label": "Antal medlemmar", "section": "forening", "required": true}, {"key": "bidragstyp", "type": "select", "label": "Vilket bidrag söker ni?", "options": [{"label": "Aktivitetsstöd (per deltagartillfälle)", "value": "activity"}, {"label": "Lokalbidrag", "value": "venue"}, {"label": "Startbidrag för ny förening", "value": "start"}, {"label": "Annat/vet inte ännu", "value": "other"}], "section": "verksamhet", "required": true}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten i kommunen", "section": "verksamhet", "guidance": "Vad ni gör, hur ofta, för vilka — särskilt barn- och ungdomsverksamhet.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Om föreningen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.563481+00'),
	('26ca784a-0fd7-42f4-a46a-c0b5419bd4b5', '4e96271f-fba4-4946-b61d-e5c65b2df39e', 1, '{"id": "region-kulturstod-v1", "title": "Ansökan — Regionalt kulturstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "regional_forankring", "type": "long_text", "label": "Beskriv er förankring i regionen", "section": "sokande", "guidance": "Säte, verksamhetsort, publik och samarbeten i regionen.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.565607+00'),
	('e8741d45-c68b-4e05-966e-25fdc90fcc7e', '84126469-19cf-42c9-bcae-0fa870cdd7fd', 1, '{"id": "sparbanksstiftelsen-projektstod-v1", "title": "Ansökan — Sparbanksstiftelsens projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsomrade", "type": "text", "label": "Ort/område där projektet genomförs", "section": "projekt", "guidance": "Stiftelsen stödjer bara projekt i den egna sparbankens verksamhetsområde.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vem det kommer till del", "section": "projekt", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.567814+00'),
	('122aef4d-cd91-4854-a2fc-09c8dff0fe33', '457fb4d3-6027-4768-8a18-51f7c9dbd771', 1, '{"id": "leader-lokalt-ledd-utveckling-v1", "title": "Ansökan — Leader-projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "leaderomrade", "type": "text", "label": "Vilket leaderområde tillhör ni?", "section": "projekt", "guidance": "Osäker? Sök på \"leaderområde\" + din kommun — kansliet hjälper till.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Koppla till leaderområdets utvecklingsstrategi — lokal förankring och samarbete väger tungt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "likviditet", "type": "long_text", "label": "Hur klarar ni likviditeten tills stödet betalas ut?", "section": "budget", "guidance": "Leaderstöd betalas ut i efterhand mot redovisade kostnader.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.570154+00'),
	('55b55f6e-c846-4859-b08b-3491d18820dd', '668709ea-2bb8-47e8-a386-f2606decf6bb', 1, '{"id": "forte-projektbidrag-v1", "title": "Ansökan — Forte projektbidrag (förberedelse)", "fields": [{"key": "projektledare", "type": "text", "label": "Projektledarens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "medelsforvaltare", "type": "text", "label": "Medelsförvaltare (lärosäte)", "section": "sokande", "required": true, "maxLength": 300}, {"key": "disputationsar", "max": 2100, "min": 1950, "type": "number", "label": "Projektledarens disputationsår", "section": "sokande", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv forskningsprojektet", "section": "projekt", "guidance": "Frågeställning, metod och relevans för hälsa, arbetsliv eller välfärd — sakligt och prövbart.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Projektledare och medelsförvaltare"}, {"key": "projekt", "title": "Forskningsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 17:30:50.57254+00');


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
	('790d2ba3-423f-4f9d-bd31-fa05daad4345', 'Kulturrådet', 'SE', 'state_agency', 'https://kulturradet.se', '2026-08-28 17:30:49.661148+00'),
	('7928f3e1-b535-4c3d-99b0-9cbc9805b656', 'MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor', 'SE', 'state_agency', 'https://www.mucf.se', '2026-08-28 17:30:49.665056+00'),
	('6840ca04-5bfd-46f1-9bfa-d57c6467c78a', 'Vinnova', 'SE', 'state_agency', 'https://www.vinnova.se', '2026-08-28 17:30:49.668072+00'),
	('defe9be7-89f2-4f33-8337-76d282f7a1c5', 'Tillväxtverket', 'SE', 'state_agency', 'https://tillvaxtverket.se', '2026-08-28 17:30:49.670687+00'),
	('2f5700a6-91a9-46b3-bb82-d965d9a3e82d', 'Energimyndigheten', 'SE', 'state_agency', 'https://www.energimyndigheten.se', '2026-08-28 17:30:49.693067+00'),
	('e1c00ee3-8b20-43ce-b545-aa4c17aaf605', 'Naturvårdsverket', 'SE', 'state_agency', 'https://www.naturvardsverket.se', '2026-08-28 17:30:49.695603+00'),
	('b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', 'Jordbruksverket', 'SE', 'state_agency', 'https://jordbruksverket.se', '2026-08-28 17:30:49.697598+00'),
	('3d5fd611-e20b-4cf8-bfe4-2f8553d8a84e', 'Svenska ESF-rådet', 'SE', 'state_agency', 'https://www.esf.se', '2026-08-28 17:30:49.699613+00'),
	('30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', 'Europeiska kommissionen (Erasmus+/EACEA)', 'EU', 'eu', 'https://erasmus-plus.ec.europa.eu', '2026-08-28 17:30:49.701929+00'),
	('ab667f93-6e24-4b35-92e3-9eaeba7015f4', 'UHR — Universitets- och högskolerådet', 'SE', 'state_agency', 'https://www.uhr.se', '2026-08-28 17:30:49.704373+00'),
	('ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', 'Konstnärsnämnden', 'SE', 'state_agency', 'https://www.konstnarsnamnden.se', '2026-08-28 17:30:49.706353+00'),
	('6cd09f95-6db4-428c-9762-a9fefa9f43d4', 'Allmänna arvsfonden', 'SE', 'foundation', 'https://www.arvsfonden.se', '2026-08-28 17:30:49.708072+00'),
	('2e0d9f8b-ded0-4c94-a96c-ecef9738046f', 'Boverket', 'SE', 'state_agency', 'https://www.boverket.se', '2026-08-28 17:30:49.713641+00'),
	('35767ea0-a4ba-4393-8c5e-d99847961c0d', 'Riksidrottsförbundet', 'SE', 'association', 'https://www.rf.se', '2026-08-28 17:30:49.715356+00'),
	('f3c3ea5c-003e-4cf1-a5b0-9503b74505ef', 'Svenska Filminstitutet', 'SE', 'foundation', 'https://www.filminstitutet.se', '2026-08-28 17:30:49.716705+00'),
	('51b7ef66-675d-413d-864e-5f78eb822716', 'Formas', 'SE', 'state_agency', 'https://www.formas.se', '2026-08-28 17:30:49.718374+00'),
	('356e2388-b799-4434-9b34-5d6f93a6b058', 'Försäkringskassan', 'SE', 'state_agency', 'https://www.forsakringskassan.se', '2026-08-28 17:30:49.720374+00'),
	('eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'CSN — Centrala studiestödsnämnden', 'SE', 'state_agency', 'https://www.csn.se', '2026-08-28 17:30:49.722006+00'),
	('f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', 'Pensionsmyndigheten', 'SE', 'state_agency', 'https://www.pensionsmyndigheten.se', '2026-08-28 17:30:49.723872+00'),
	('e61f7274-52de-4471-83ae-cc934b981d89', 'Socialtjänsten i din kommun', 'SE', 'municipality', 'https://www.socialstyrelsen.se', '2026-08-28 17:30:49.72591+00'),
	('d498d63f-945c-4e31-8042-2503c6c643e6', 'Arbetsförmedlingen', 'SE', 'state_agency', 'https://arbetsformedlingen.se', '2026-08-28 17:30:49.727751+00'),
	('775271e3-a9b2-4704-a04b-9eb6e0e52562', 'Din kommun', 'SE', 'municipality', NULL, '2026-08-28 17:30:49.729676+00'),
	('44ccc9f1-b4bf-4333-9623-e15c456e32d5', 'Riksantikvarieämbetet', 'SE', 'state_agency', 'https://www.raa.se', '2026-08-28 17:30:49.731757+00'),
	('91a8f2a5-5cea-4289-8886-257ce35181c5', 'Svenska institutet', 'SE', 'state_agency', 'https://si.se', '2026-08-28 17:30:49.733535+00'),
	('d012d319-6538-4150-90f1-c8a7b82a28f8', 'Nordisk kulturfond', 'DK', 'foundation', 'https://www.nordiskkulturfond.org', '2026-08-28 17:30:49.735438+00'),
	('2c787c76-4737-49c9-b8b4-63bc29e78dfb', 'Vetenskapsrådet', 'SE', 'state_agency', 'https://www.vr.se', '2026-08-28 17:30:49.73695+00'),
	('e30c7a25-122b-43bc-bced-3009439fbd97', 'Svenska Postkodstiftelsen', 'SE', 'foundation', 'https://postkodstiftelsen.se', '2026-08-28 17:30:49.73844+00'),
	('7567c42c-d5fb-441f-a833-5c4f9f60019a', 'Statens musikverk', 'SE', 'state_agency', 'https://musikverket.se', '2026-08-28 17:30:49.740145+00'),
	('c9ab513b-a69e-47e2-b855-acc8c910e74f', 'Länsstyrelsen i ditt län', 'SE', 'region', 'https://www.lansstyrelsen.se', '2026-08-28 17:30:49.741956+00'),
	('fa5dfa8b-3f48-4480-933d-456a4159612b', 'Din region', 'SE', 'region', 'https://www.1177.se', '2026-08-28 17:30:49.743686+00'),
	('c0fa4105-8057-42fc-a46b-2200f2a6eb33', 'Majblommans Riksförbund', 'SE', 'foundation', 'https://majblomman.se', '2026-08-28 17:30:49.74547+00'),
	('5ec8e845-3c3f-497b-8ae4-34245b3d8fae', 'Migrationsverket', 'SE', 'state_agency', 'https://www.migrationsverket.se', '2026-08-28 17:30:49.747208+00'),
	('8b2c3f3b-ef6f-415a-a343-0a72393107a6', 'Forte — Forskningsrådet för hälsa, arbetsliv och välfärd', 'SE', 'state_agency', 'https://forte.se', '2026-08-28 17:30:49.748725+00'),
	('ba1278ad-4f74-44c5-8851-f51fd092f029', 'Sparbanksstiftelsen i ditt område', 'SE', 'foundation', 'https://www.sparbankerna.se', '2026-08-28 17:30:49.75059+00'),
	('06c449c3-980c-4486-a438-c8f040513700', 'Radiohjälpen', 'SE', 'foundation', 'https://www.radiohjalpen.se', '2026-08-28 17:30:49.752316+00'),
	('37e1245f-98d1-4063-be5f-c27054c5f82a', 'Din a-kassa', 'SE', 'association', 'https://www.sverigesakassor.se', '2026-08-28 17:30:49.75399+00');


--
-- Data for Name: funding_opportunities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_opportunities VALUES
	('1ce740ab-9c27-4da7-94df-d3c8dff4006c', '790d2ba3-423f-4f9d-bd31-fa05daad4345', '1b27aff5-a92b-4948-8b6c-fd29de2c6513', 'kulturradet-internationellt-resebidrag-musik', 'Kulturrådet — Resebidrag för internationellt kulturutbyte', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Stödet riktar sig till yrkesverksamma kulturskapare i Sverige som deltar i internationellt kulturutbyte, till exempel gästspel, samarbetsprojekt eller kompetensutveckling utomlands. Bidraget kan täcka resekostnader och relaterade omkostnader. Kontrollera alltid aktuella villkor hos Kulturrådet.', 'Främja internationellt kulturutbyte och svenska kulturskapares internationella närvaro.', 'travel_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-09-24 21:59:59+00', NULL, 'Ansökan görs i Kulturrådets onlinetjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', '391d6e31-657f-4aff-9472-01972ecdc466', '7dea1841-65cc-480f-9b87-22177e7b0032', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.835554+00', '2026-08-28 17:30:49.835554+00'),
	('808c5f5b-7f8c-40c3-a1d8-5d5d77b2b575', '30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', '0528fb15-e5c7-44af-a7b2-17556d692840', 'erasmus-plus-ungdomsutbyten', 'Erasmus+ — Ungdomsutbyten (Youth Exchanges)', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Ungdomsutbyten inom Erasmus+ låter grupper av unga från olika länder mötas i 5–21 dagar (exklusive resa) kring ett gemensamt program. Stödet täcker resekostnader samt praktiska kostnader och aktivitetskostnader enligt programguidens schabloner. Ansökan görs av en organisation eller informell grupp via det nationella programkontoret (i Sverige: MUCF för ungdomsdelen). Organisationen behöver ett OID (Organisation ID) via EU:s Organisation Registration System.', 'Interkulturellt lärande, ungas delaktighet och europeiskt samarbete.', 'eu_grant', '["association", "informal_group", "municipality"]', '["SE"]', '["youth", "culture", "education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, '2026-10-01 10:00:00+00', NULL, 'Ansökan lämnas i EU:s ansökningssystem för Erasmus+ (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'eu_login', 'assisted', 15, '', 'published', 'a80bb618-8744-4e92-a1f4-32dbd788cf5c', '1a95cc11-b340-4a44-85c6-cf9bb83753c2', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.845824+00', '2026-08-28 17:30:49.845824+00'),
	('8dae3789-436f-4689-999b-9297b43fad01', '7928f3e1-b535-4c3d-99b0-9cbc9805b656', 'f456381c-77d4-4752-ac45-94bed246d89a', 'mucf-projektbidrag-ungdomsorganisationer', 'MUCF — Projektbidrag för barn- och ungdomsorganisationer', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'MUCF fördelar statsbidrag till civilsamhällets organisationer, bland annat projektbidrag för verksamhet med och för barn och unga. Bidragen har specifika villkor per utlysning — kontrollera alltid aktuell utlysning hos MUCF.', 'Stärka ungas delaktighet och civilsamhällets verksamhet för barn och unga.', 'project_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i MUCF:s ansökningssystem när en utlysning är öppen.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', 'ef60e1a2-9fee-4c0c-a281-a3b8a4f56976', '9196e670-e60b-469a-83d6-68bdfaaa1216', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.853535+00', '2026-08-28 17:30:49.853535+00'),
	('2fa40993-227e-4608-9b2a-9afbc271ccc1', '6840ca04-5bfd-46f1-9bfa-d57c6467c78a', '2ef4b0e6-e8ac-40df-a7f2-d0df978fe91c', 'vinnova-innovativa-startups', 'Vinnova — Innovativa startups', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Vinnovas program för innovativa startups riktar sig till unga svenska aktiebolag med skalbara, nyskapande lösningar. Utlysningar öppnar i omgångar med specifika villkor per omgång — kontrollera aktuell utlysning hos Vinnova. Bidraget kräver normalt att bolaget är yngre än en viss ålder och har begränsad omsättning.', 'Stärka svenska startups förmåga att utveckla och kommersialisera innovationer.', 'public_grant', '["company"]', '["SE"]', '["innovation", "technology"]', NULL, 30000000, 'SEK', 100, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst (Intressentportalen).', 'https://www.vinnova.se/soka-finansiering/', 'vinnova_konto', 'assisted', 10, '', 'published', '7ad6c192-fa6e-4215-aa61-4443b5ee74c2', 'c695ab35-b0bc-4274-b01a-8b921e5f476d', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.862316+00', '2026-08-28 17:30:49.862316+00'),
	('655ce725-4921-4ead-8c71-a65db15d9bd3', '2f5700a6-91a9-46b3-bb82-d965d9a3e82d', '1064fd51-8201-49e0-b77b-573d3c5be99b', 'energimyndigheten-energieffektivisering', 'Energimyndigheten — Stöd för energi- och klimatprojekt (löpande utlysningar)', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Det mesta av Energimyndighetens stöd fördelas via utlysningar som öppnar löpande inom olika områden. Ansökan och ärendehantering sker via Mina sidor. Villkoren varierar per utlysning — den här posten representerar programområdet; kontrollera aktuella utlysningar hos Energimyndigheten.', 'Energiomställning: forskning, innovation och effektivare energianvändning.', 'public_grant', '["company", "university", "public_body", "association", "economic_association"]', '["SE"]', '["energy", "environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 12, '', 'published', 'a8619d2e-f342-492e-99d9-fac95c4d4ebb', 'd1214947-e0ab-4212-9583-32de614b4dfb', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.87038+00', '2026-08-28 17:30:49.87038+00'),
	('e8f61700-5a3c-4b21-bdd5-ef341a30b736', 'e1c00ee3-8b20-43ce-b545-aa4c17aaf605', '4474cc0c-333e-4f45-80ab-909ba27060e5', 'naturvardsverket-ladda-bilen-organisationer', 'Naturvårdsverket — Bidrag för miljö- och klimatåtgärder (organisationer)', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket administrerar flera bidrag inom miljö- och klimatområdet, uppdelade efter mottagartyp (organisationer, företag, ekonomiska föreningar, offentlig sektor och privatpersoner). Villkoren varierar per bidrag — den här posten representerar området; kontrollera aktuellt bidrag hos Naturvårdsverket.', 'Miljö- och klimatåtgärder i hela samhället.', 'public_grant', '["association", "company", "economic_association", "public_body", "individual"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänster.', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 6, '', 'published', '32b03ab9-b148-46ee-8c66-253556eb97bc', '4d910c0e-0d09-4882-b9fd-d9227cbba3f4', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.880069+00', '2026-08-28 17:30:49.880069+00'),
	('341416fd-513a-4d90-98fc-622dac87253a', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'e0eda88d-fa79-48be-98de-3a71896e2dc8', 'kulturradet-projektbidrag-musik', 'Kulturrådet — Projektbidrag musik (fria musiklivet)', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Kulturrådet fördelar projektbidrag till det fria musiklivet. Bidraget söks av grupper, arrangörer och organisationer inom musikområdet. Villkor och ansökningsperioder publiceras per omgång på Kulturrådets webbplats.', 'Ett levande och oberoende musikliv i hela landet.', 'project_grant', '["association", "company", "individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Kulturrådets onlinetjänst när omgången är öppen.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 7, '', 'published', '1ebf7e25-0c6d-48f5-bec5-f40f26510f1f', '7dea1841-65cc-480f-9b87-22177e7b0032', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.888819+00', '2026-08-28 17:30:49.888819+00'),
	('7a5794e7-0ad6-4820-a360-76fad5023a76', 'ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', '07d6b4c5-582d-4a12-bea5-7cab934e5c34', 'konstnarsnamnden-internationellt-kulturutbyte', 'Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Konstnärsnämnden ger bidrag till yrkesverksamma konstnärer inom bild, form, dans, film, musik och teater för internationellt kulturutbyte — t.ex. resor för samarbeten, gästspel eller arbetsvistelser utomlands. Ansökningsomgångar publiceras per konstområde; kontrollera aktuella tider hos Konstnärsnämnden.', 'Konstnärers internationalisering och konstnärliga utveckling.', 'travel_grant', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 4, '', 'published', 'e83c35df-90d1-4923-889a-99f8caaa4c4d', 'a778d0a0-ba7d-4b13-99a3-a3c7b00eeb47', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.89645+00', '2026-08-28 17:30:49.89645+00'),
	('2c0487d4-d4bb-497d-afc6-578c035fe7d2', 'ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', '4e4cdefb-e351-4684-81e9-42c8a91f8956', 'konstnarsnamnden-arbetsstipendium', 'Konstnärsnämnden — Arbetsstipendium', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Arbetsstipendiet ska ge yrkesverksamma konstnärer ekonomiskt utrymme att utveckla sitt konstnärskap. Söks per konstområde i årliga omgångar; villkor och tider publiceras av Konstnärsnämnden.', 'Konstnärlig fördjupning och försörjningstrygghet för yrkesverksamma konstnärer.', 'stipend', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 6, '', 'published', '1b09dd7b-49be-4060-a58f-e2b75dc171a0', 'a778d0a0-ba7d-4b13-99a3-a3c7b00eeb47', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.904693+00', '2026-08-28 17:30:49.904693+00'),
	('0ecc6405-02b4-4dd6-8c73-c19a09591ebf', '6cd09f95-6db4-428c-9762-a9fefa9f43d4', '8d3b2a59-90ff-424e-92c1-b04b1a0f8ebb', 'arvsfonden-projektstod', 'Allmänna arvsfonden — Projektstöd', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Arvsfonden stödjer ideella organisationers utvecklingsprojekt som är nyskapande och där målgruppen — barn, ungdomar, äldre eller personer med funktionsnedsättning — är delaktig. Ansökan kan lämnas löpande; projekt kan pågå i upp till tre år.', 'Nyskapande och utvecklande verksamhet för fondens målgrupper.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.arvsfonden.se/soka-pengar', 'none', 'assisted', 12, '', 'published', '2f3eca3b-77c1-46cd-83a2-8464309eb655', 'd9f603e2-0569-41ed-bb32-1df53dc399c5', 'https://www.arvsfonden.se/soka-pengar', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.913161+00', '2026-08-28 17:30:49.913161+00'),
	('58a6f196-a76f-48c9-ab8b-8cc37f41a9b7', '2e0d9f8b-ded0-4c94-a96c-ecef9738046f', 'ee08b244-3e40-43d6-ae0f-ecef83df55f3', 'boverket-allmanna-samlingslokaler', 'Boverket — Investeringsbidrag till allmänna samlingslokaler', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Boverket ger investeringsbidrag till föreningar och stiftelser för nybyggnad, ombyggnad, köp eller standardhöjande reparationer av allmänna samlingslokaler — t.ex. bygdegårdar, folkets hus och föreningslokaler. Årlig ansökningsomgång; villkor publiceras av Boverket.', 'Tillgång till lokaler för möten, kultur och fritid i hela landet.', 'public_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "culture"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.boverket.se/sv/bidrag--garantier/', 'eid', 'assisted', 10, '', 'published', '6bee3b2f-72c3-4593-a3cb-cf84eee988da', '43fc859b-6d9e-4a89-a289-98e685e857fd', 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.921009+00', '2026-08-28 17:30:49.921009+00'),
	('0b1994e6-e493-4e2e-b231-7ebecc33ef13', '35767ea0-a4ba-4393-8c5e-d99847961c0d', 'c7c167ac-8094-44f1-80bf-a44c78d36812', 'rf-lok-stod', 'Riksidrottsförbundet — Statligt lokalt aktivitetsstöd (LOK-stöd)', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'LOK-stödet ger idrottsföreningar anslutna till ett specialidrottsförbund ersättning per sammankomst och deltagartillfälle för ledarledd verksamhet för deltagare 7–25 år. Redovisas i IdrottOnline två gånger per år.', 'Stödja föreningsdriven barn- och ungdomsidrott.', 'public_grant', '["association"]', '["SE"]', '["sports", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-08-25 21:59:59+00', NULL, 'Ansökan/redovisning görs i IdrottOnline. Ansökningsperioderna stänger 25 februari och 25 augusti.', 'https://www.rf.se/bidrag-och-stod', 'none', 'assisted', 2, '', 'published', '3d4c2bb6-d605-450c-82c9-715d307d9103', '89dbf8db-2982-4793-bc85-c49acca4d0cf', 'https://www.rf.se/bidrag-och-stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.929423+00', '2026-08-28 17:30:49.929423+00'),
	('9f891fb9-175e-4d85-9c28-7dd3de6d146e', 'f3c3ea5c-003e-4cf1-a5b0-9503b74505ef', '0680d0b5-c7bf-4483-8301-2f35cc1a61d2', 'filminstitutet-kortfilmsstod', 'Svenska Filminstitutet — Stöd till kort- och dokumentärfilm', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Filminstitutet ger utvecklings- och produktionsstöd till kort- och dokumentärfilm. Stödet söks normalt av ett produktionsbolag; beslut fattas av filmkonsulent. Villkor och ansökningstider publiceras per stödform.', 'Konstnärligt värdefull svensk film.', 'project_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.filminstitutet.se/sv/sok-stod/', 'none', 'assisted', 8, '', 'published', '7b7f289d-ed17-40ef-b13f-1fc32fda5c94', 'be31c15f-2784-446f-bde5-6f11a87c081a', 'https://www.filminstitutet.se/sv/sok-stod/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.936533+00', '2026-08-28 17:30:49.936533+00'),
	('13e34d24-98ca-4928-838a-6d600c2af368', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'd6adb7f1-9b55-4c08-8dfb-dbc48f577aef', 'kulturradet-skapande-skola', 'Kulturrådet — Skapande skola', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Skapande skola söks av skolhuvudmän (kommuner, fristående skolor) för konst- och kulturinsatser i förskoleklass och grundskola, genomförda av professionella kulturaktörer. Årlig ansökningsomgång.', 'Att alla elever ska få möta professionell konst och kultur.', 'public_grant', '["municipality", "school", "company"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 6, '', 'published', '93e7ac93-edc2-4fb3-9305-05b78f58bacf', '7dea1841-65cc-480f-9b87-22177e7b0032', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.944054+00', '2026-08-28 17:30:49.944054+00'),
	('e7d5806a-ea09-4411-b947-57ad4f8b67a4', '51b7ef66-675d-413d-864e-5f78eb822716', '7a7c0b83-11c7-448d-a4d8-8b037bfcfc68', 'formas-oppna-utlysningen', 'Formas — Årliga öppna utlysningen', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Formas årliga öppna utlysning finansierar forskningsprojekt inom miljö, areella näringar och samhällsbyggande. Söks av disputerade forskare vid svenska lärosäten och forskningsinstitut. Årlig omgång med publicerade tider.', 'Kunskap för hållbar utveckling.', 'public_grant', '["university", "public_body"]', '["SE"]', '["environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.formas.se/soka-finansiering.html', 'none', 'assisted', 20, '', 'published', '3b2b64be-dc0d-435e-92f4-fb37a3a55397', 'c144e25c-2125-4704-b730-23a676ad1e64', 'https://www.formas.se/soka-finansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.951818+00', '2026-08-28 17:30:49.951818+00'),
	('352541d9-0db6-42d3-858b-ce7be920f555', 'defe9be7-89f2-4f33-8337-76d282f7a1c5', '9ff34818-4616-44c1-83d5-a4e4cdab3846', 'tillvaxtverket-affarsutvecklingscheckar', 'Tillväxtverket — Affärsutvecklingscheckar (internationalisering/digitalisering)', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Affärsutvecklingscheckarna hjälper små företag att köpa extern kompetens för att utvecklas internationellt eller digitalt. Checkarna administreras regionalt; belopp, andelar och tider varierar per region — kontrollera din regions aktuella utlysning.', 'Stärkt konkurrenskraft i små företag.', 'public_grant', '["company"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', 50, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) när regionens omgång är öppen.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 6, '', 'published', '1d8b0f53-fe7a-47c3-8186-6be43cc9d6f7', 'd5d4afd3-fd05-4b41-9da2-01513a9e448a', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.962637+00', '2026-08-28 17:30:49.962637+00'),
	('fb27a1f7-b763-4ab8-b8b4-188c9fd719b8', 'b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', '2c7c3acd-f0c2-401c-b55b-e601e86e0337', 'jordbruksverket-startstod-unga', 'Jordbruksverket — Startstöd till unga jordbrukare', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Startstödet riktar sig till unga som startar eller tar över jordbruks-, trädgårds- eller rennäringsföretag. Kräver bl.a. åldersgräns, utbildning/erfarenhet och en affärsplan. Ansökan görs i Jordbruksverkets e-tjänst med e-legitimation.', 'Generationsväxling och föryngring i jordbruket.', 'public_grant', '["individual", "company"]', '["SE"]', '["agriculture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation; fullmakt kan användas).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', 'a4511f96-ab3f-427f-b7b4-e79b83000195', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.970795+00', '2026-08-28 17:30:49.970795+00'),
	('9ea8f3b8-7e5a-411f-9c3f-2e11ee86bb53', 'b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', 'efa93a28-9a16-482f-8f95-017a7d0db158', 'jordbruksverket-investeringsstod', 'Jordbruksverket — Investeringsstöd för jordbruk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Investeringsstöd kan sökas för t.ex. djurstallar, växthus, energieffektivisering och miljöåtgärder i jordbruksföretag. Villkor, stödandelar och regionala prioriteringar framgår av aktuell stödinformation hos Jordbruksverket.', 'Konkurrenskraftigt och hållbart jordbruk.', 'public_grant', '["company", "individual", "economic_association"]', '["SE"]', '["agriculture", "environment"]', NULL, NULL, 'SEK', 40, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', '756b3e0a-03c9-4607-a6d2-ac2a3cf87a84', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.978214+00', '2026-08-28 17:30:49.978214+00'),
	('cee75a50-3525-4555-bafc-6743751cf93a', '3d5fd611-e20b-4cf8-bfe4-2f8553d8a84e', 'd617557d-37f8-492c-8af6-87bafb642a25', 'esf-kompetensutveckling', 'Svenska ESF-rådet — ESF+ projektstöd för kompetensutveckling och omställning', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Svenska ESF-rådet utlyser projektmedel ur Europeiska socialfonden+ i regionala och nationella utlysningar, t.ex. kompetensutveckling för anställda och insatser för personer långt från arbetsmarknaden. Villkor och medfinansieringskrav framgår per utlysning i utlysningsplanen.', 'En väl fungerande och inkluderande arbetsmarknad.', 'eu_grant', '["company", "association", "municipality", "region", "public_body", "university"]', '["SE"]', '["education", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i ESF-rådets Projektrummet när en utlysning är öppen.', 'https://www.esf.se/utlysningar/', 'none', 'assisted', 15, '', 'published', 'e92323e6-56d5-4d81-ae6a-5fe0a0b7a43f', '110a07c1-0cf8-4910-a3a1-16f8854f7e6b', 'https://www.esf.se/utlysningar/utlysningsplan/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.98549+00', '2026-08-28 17:30:49.98549+00'),
	('01f8696b-ebdc-417b-9b71-d1160373303d', '2f5700a6-91a9-46b3-bb82-d965d9a3e82d', '8bacbd28-ae65-4120-b49e-1d26946ff1eb', 'energimyndigheten-industriklivet', 'Energimyndigheten — Industriklivet', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Industriklivet stödjer forskning, förstudier och investeringar som minskar industrins processrelaterade utsläpp samt negativa utsläpp (t.ex. bio-CCS). Söks löpande eller i utlysningar via Mina sidor.', 'Industrins klimatomställning.', 'public_grant', '["company", "university", "public_body"]', '["SE"]', '["energy", "environment"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 15, '', 'published', '62d4ea43-c942-448e-9d7b-5e2fdc55b76b', 'd1214947-e0ab-4212-9583-32de614b4dfb', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:49.992146+00', '2026-08-28 17:30:49.992146+00'),
	('4fa0d5eb-1e47-4923-9627-6ef69a548588', 'e1c00ee3-8b20-43ce-b545-aa4c17aaf605', 'fbef7a25-1d78-4297-8ac4-d0974f802187', 'naturvardsverket-klimatklivet', 'Naturvårdsverket — Klimatklivet', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Klimatklivet ger investeringsstöd till företag, kommuner, regioner och organisationer för åtgärder som ger stor klimatnytta per stödkrona — t.ex. laddinfrastruktur, biogas och energikonvertering. Ansökningsomgångar öppnar flera gånger per år.', 'Minskade växthusgasutsläpp.', 'public_grant', '["company", "municipality", "region", "association", "economic_association", "public_body"]', '["SE"]', '["environment", "energy"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänst när en omgång är öppen (kräver e-legitimation).', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 8, '', 'published', '8a0ec9f8-187e-43d8-88b7-e5fe18cb6c2e', '4d910c0e-0d09-4882-b9fd-d9227cbba3f4', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.000109+00', '2026-08-28 17:30:50.000109+00'),
	('e8893c24-c7c5-48c5-bad2-7e81f51e8e19', 'e1c00ee3-8b20-43ce-b545-aa4c17aaf605', 'dedba60e-f7b4-477c-b395-cb7cb6915a1d', 'naturvardsverket-lona', 'Naturvårdsverket — Lokala naturvårdssatsningen (LONA)', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'LONA ger upp till 50 % (våtmarksprojekt upp till 90 %) i bidrag till naturvårds- och friluftslivsprojekt. Kommunen ansöker hos länsstyrelsen, men lokala föreningar kan initiera projekt genom sin kommun.', 'Lokalt naturvårdsengagemang och friluftsliv.', 'public_grant', '["municipality"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Kommunen ansöker via länsstyrelsen; föreningar initierar via sin kommun.', 'https://www.naturvardsverket.se/bidrag/', 'none', 'assisted', 6, '', 'published', '08aaffd0-c5d0-4769-ac20-01c0b007597b', '4d910c0e-0d09-4882-b9fd-d9227cbba3f4', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.008159+00', '2026-08-28 17:30:50.008159+00'),
	('eafe09c2-a9be-4c64-8dd2-f905c264c78a', '7928f3e1-b535-4c3d-99b0-9cbc9805b656', '2fbfc88f-3226-44f5-8dc8-f761e9a9f198', 'mucf-solidaritetskaren-volontarprojekt', 'MUCF — Europeiska solidaritetskåren: volontärprojekt', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Europeiska solidaritetskåren finansierar volontärprojekt där unga 18–30 år gör volontärtjänst i ett annat land eller i Sverige. Organisationen behöver en kvalitetsmärkning (Quality Label) och ett OID. MUCF är nationellt programkontor.', 'Ungas engagemang och solidaritet i Europa.', 'eu_grant', '["association", "municipality", "public_body"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login, OID och Quality Label).', 'https://www.mucf.se/bidrag', 'eu_login', 'assisted', 12, '', 'published', 'f8aca49a-edda-448d-9e80-d050fb9191ff', '9196e670-e60b-469a-83d6-68bdfaaa1216', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.016283+00', '2026-08-28 17:30:50.016283+00'),
	('3b982049-9767-4a02-8dfd-e2cf9df41b91', 'ab667f93-6e24-4b35-92e3-9eaeba7015f4', 'bbd52deb-b5ba-4d21-87e7-9e589ce27882', 'erasmus-mobilitet-skola-vuxen', 'Erasmus+ — Mobilitet för skola och vuxenutbildning (KA1)', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Erasmus+ KA1 ger skolor, förskolor och vuxenutbildningsorganisationer stöd för kompetensutveckling utomlands — jobbskuggning, kurser och undervisningsuppdrag samt elevmobilitet. UHR är nationellt programkontor för utbildningsdelen. Kräver OID; årliga ansökningsomgångar.', 'Internationalisering av svensk utbildning.', 'eu_grant', '["school", "municipality", "company", "association", "public_body"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://www.uhr.se/internationella-mojligheter/', 'eu_login', 'assisted', 12, '', 'published', '81998240-16bb-4464-813f-4ec5a314e1e2', 'eaee409c-8ca9-4c06-9620-3286f98051d7', 'https://www.uhr.se/internationella-mojligheter/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.023238+00', '2026-08-28 17:30:50.023238+00'),
	('8896ddc9-a1da-4818-8ca6-488e9b4e592c', '30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', 'b743b4b1-2831-4acf-81e9-4666513ed6cc', 'kreativa-europa-samarbetsprojekt', 'Kreativa Europa — Europeiska samarbetsprojekt (kultur)', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Kreativa Europas kulturprogram finansierar samarbetsprojekt mellan kulturorganisationer i minst tre programländer. Kulturrådet är kontaktkontor i Sverige för kulturdelen. Ansökan görs i EU:s Funding & Tenders-portal; årliga utlysningar.', 'Europeiskt kultursamarbete och cirkulation av konstnärliga verk.', 'eu_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', 80, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s Funding & Tenders-portal (kräver EU Login och PIC/OID).', 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'eu_login', 'assisted', 25, '', 'published', '217d2691-92b5-4053-bf54-3488b59266ff', NULL, 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.029213+00', '2026-08-28 17:30:50.029213+00'),
	('41a0986f-d8cf-427e-b731-b63cb5a70a8f', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'dd8b605b-b3c8-4c15-ad09-6d32a6ad95cb', 'kulturradet-verksamhetsbidrag-scenkonst', 'Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Verksamhetsbidraget riktar sig till professionella fria scenkonstaktörer med kontinuerlig verksamhet av hög kvalitet. Söks i årlig omgång hos Kulturrådet.', 'Ett starkt fritt scenkonstliv i hela landet.', 'public_grant', '["association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 10, '', 'published', '5dbe6cb8-5a34-46f1-aabc-e12ff7d9d01a', '7dea1841-65cc-480f-9b87-22177e7b0032', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.035879+00', '2026-08-28 17:30:50.035879+00'),
	('5bc51a6c-ac08-4624-aa47-f770913ebc7b', '6840ca04-5bfd-46f1-9bfa-d57c6467c78a', 'd1194e87-3d05-4778-b6c0-37b7cfc98abb', 'vinnova-planeringsbidrag-eu', 'Vinnova — Planeringsbidrag för EU-ansökningar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Vinnova erbjuder återkommande planeringsbidrag som sänker tröskeln för svenska organisationer att söka EU-finansiering, t.ex. inför Horisont Europa-utlysningar och EIC Accelerator. Villkor per aktuell utlysning.', 'Ökat svenskt deltagande i EU:s ramprogram.', 'public_grant', '["company", "university", "public_body", "association"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst när en omgång är öppen.', 'https://www.vinnova.se/soka-finansiering/', 'none', 'assisted', 6, '', 'published', '11305445-8ce0-4cf2-be11-2fb70d753907', 'c695ab35-b0bc-4274-b01a-8b921e5f476d', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.042164+00', '2026-08-28 17:30:50.042164+00'),
	('715ee057-3e05-4bea-b829-ba4ad8cbca5e', '7928f3e1-b535-4c3d-99b0-9cbc9805b656', '4cf03cce-aa7a-4e44-b534-107179852e47', 'mucf-organisationsbidrag', 'MUCF — Organisationsbidrag till barn- och ungdomsorganisationer', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Organisationsbidraget söks årligen av nationella barn- och ungdomsorganisationer som uppfyller krav på bl.a. medlemsantal, åldersstruktur, demokratisk uppbyggnad och geografisk spridning. Villkoren framgår av förordning och MUCF:s anvisningar.', 'Ett starkt och självständigt ungdomscivilsamhälle.', 'public_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', '9d07063c-a3cb-4368-8406-645222af5d13', '9196e670-e60b-469a-83d6-68bdfaaa1216', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.04921+00', '2026-08-28 17:30:50.04921+00'),
	('6a39173a-06b8-4892-a8b9-ab0312bb2cc8', '356e2388-b799-4434-9b34-5d6f93a6b058', 'f1a74dc3-f423-49e7-b849-9dd6824843f3', 'fk-bostadsbidrag-barnfamiljer', 'Försäkringskassan — Bostadsbidrag till barnfamiljer', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Bostadsbidrag kan lämnas till barnfamiljer med lägre inkomster som betalar för sitt boende. Beloppet beror på inkomst, boendekostnad, bostadens storlek och antal barn. Ansökan görs hos Försäkringskassan; bidraget är preliminärt och stäms av mot taxerad inkomst i efterhand.', 'Ekonomisk trygghet i boendet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '29f534af-62e8-4dda-aa2e-103d9af93c7f', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.056577+00', '2026-08-28 17:30:50.056577+00'),
	('a63bb697-3963-4ab4-8ce7-7e1595e5346a', '356e2388-b799-4434-9b34-5d6f93a6b058', '54065071-e746-406a-9436-c69bbf7ed11d', 'fk-underhallsstod', 'Försäkringskassan — Underhållsstöd', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Underhållsstöd kan lämnas när föräldrar inte bor ihop, barnet bor varaktigt hos dig och den andra föräldern inte betalar underhållsbidrag eller betalar mindre än stödets nivå. Ansökan görs hos Försäkringskassan.', 'Barnets försörjning när underhåll uteblir.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'af64ca1e-9b4d-47f7-a6d8-332d2a0d3308', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.122682+00', '2026-08-28 17:30:50.122682+00'),
	('472f3ec4-3cd2-46af-b29e-5f55dd1cd470', 'f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', 'f9313d49-13df-4e8e-8904-19aa452628b0', 'pm-bostadstillagg', 'Pensionsmyndigheten — Bostadstillägg för pensionärer', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Bostadstillägg kan lämnas till den som tar ut hel allmän pension och har låga inkomster i förhållande till sin boendekostnad. Många som har rätt till tillägget söker det aldrig — det är värt att kontrollera. Ansökan görs hos Pensionsmyndigheten.', 'Ekonomisk trygghet i boendet för pensionärer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Pensionsmyndighetens webbplats (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '19a7d85b-4281-45d5-9b3e-987ff9cbccb9', '0d17bd6d-d5c3-46c0-8dd5-ef420a2df55f', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.129657+00', '2026-08-28 17:30:50.129657+00'),
	('095700f4-8d8e-4746-aa9d-cc7b393baa03', 'f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', 'a65ee484-2ca4-47f5-a9bc-6196e9ad51c2', 'pm-aldreforsorjningsstod', 'Pensionsmyndigheten — Äldreförsörjningsstöd', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Äldreförsörjningsstöd kan lämnas från riktåldern för pension (67 år från 2026) till den som inte får sina grundläggande behov tillgodosedda genom pension och andra inkomster. Prövas tillsammans med bostadstillägg. Ansökan görs hos Pensionsmyndigheten.', 'Skälig levnadsnivå för äldre.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Pensionsmyndigheten (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '94062597-1ab1-4fad-ab4e-69048df9f39b', '0d17bd6d-d5c3-46c0-8dd5-ef420a2df55f', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.135864+00', '2026-08-28 17:30:50.135864+00'),
	('70b8688c-0646-44a8-9a91-af94cada48bc', 'd498d63f-945c-4e31-8042-2503c6c643e6', '8db1e2e9-62f8-4c8c-93e5-8f63ecc7e94d', 'af-stod-start-naringsverksamhet', 'Arbetsförmedlingen — Stöd till start av näringsverksamhet', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Den som är inskriven som arbetssökande och bedöms ha goda förutsättningar att driva företag kan få stöd (aktivitetsstöd) under verksamhetens uppstartsfas. Beslut fattas av Arbetsförmedlingen efter prövning av affärsplanen.', 'Väg från arbetslöshet till egen försörjning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Arbetsförmedlingen — kontakta din handläggare.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 5, '', 'published', '09d1ccae-a40b-4d82-99f9-eb33d92cef77', 'd4bf2c40-9127-4bc8-8fdc-a0011b07b0e6', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.14283+00', '2026-08-28 17:30:50.14283+00'),
	('aee48bcd-9e74-4cfc-80ef-aa5d4a691e6c', 'fa5dfa8b-3f48-4480-933d-456a4159612b', 'daf0e009-60a8-466c-a267-a6337f1fc836', 'region-glasogonbidrag-barn', 'Din region — Glasögonbidrag för barn och unga (8–19 år)', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Alla regioner är enligt lag (2016:35) skyldiga att ge bidrag för glasögon eller kontaktlinser till barn och unga 8–19 år som behöver synhjälpmedel. Lagen fastställer inget nationellt belopp — nivån bestäms per region och varierar. Ansökan sker oftast via optikern eller direkt till regionen — rutinerna skiljer sig, kontrollera din regions sidor och aktuellt belopp via 1177.', 'Alla barn ska ha råd med de synhjälpmedel de behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Vanligen via optikern eller regionens e-tjänst — se din regions rutin på 1177.se.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', 'b0611045-3632-428b-9a75-b929ea6ba181', '18b3814a-6e6d-4869-a4b6-ad0b6576cb86', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.064289+00', '2026-08-28 17:30:50.064289+00'),
	('32eb2795-dcb4-473a-b76f-df14f8883ff4', 'c0fa4105-8057-42fc-a46b-2200f2a6eb33', '1f18e054-f6ed-4cdd-8a61-28ac02236255', 'majblomman-bidrag-barn', 'Majblomman — Bidrag till barn i familjer där pengarna inte räcker', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Majblommans lokalföreningar ger bidrag till barn upp till 18 år i familjer med knapp ekonomi. Det kan gälla en fritidsaktivitet, en cykel, kläder, en klassresa eller något annat konkret som barnet behöver. Ansökan görs till den lokala majblommeföreningen där barnet bor och kan göras av vårdnadshavare eller via t.ex. skolsköterska.', 'Alla barn ska kunna delta i sådant som andra barn tar för givet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan till din lokala majblommeförening via majblomman.se.', 'https://majblomman.se/', 'none', 'assisted', 1, '', 'published', '35551cd7-13e9-46e0-919d-830549777ac3', '704fa635-09d7-4665-801f-21fcc2b0082a', 'https://majblomman.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.072549+00', '2026-08-28 17:30:50.072549+00'),
	('125b0d3f-8395-4454-8402-0796efec258f', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'f33a3934-cfdc-4e5c-b209-b3b1923554b4', 'kommun-skolskjuts', 'Din kommun — Skolskjuts i grundskolan', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Elever i grundskolan har enligt skollagen (10 kap. 32 §) rätt till kostnadsfri skolskjuts från hemkommunen om det behövs på grund av färdvägens längd, trafikförhållanden, funktionsnedsättning eller någon annan särskild omständighet. Kommunerna har egna avståndsgränser och rutiner — ansökan görs hos barnets hemkommun.', 'Alla barn ska kunna ta sig till skolan utan kostnad när vägen är lång eller osäker.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos barnets hemkommun (e-tjänst eller blankett).', 'https://www.skolverket.se/', 'none', 'assisted', 1, '', 'published', 'cf9b0a6d-4bc8-481c-86b6-ee63c3eaf7fa', 'a8815f01-c7ee-48e9-bdd0-7a843ed5d26d', 'https://www.skolverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.080156+00', '2026-08-28 17:30:50.080156+00'),
	('fd6a0c95-a691-42b7-b3d6-e7f4d39fbb04', '7567c42c-d5fb-441f-a833-5c4f9f60019a', '4e7a2e24-6c95-461c-b19c-65e097074872', 'musikverket-projektbidrag', 'Statens musikverk — Projektbidrag till musiklivet', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Musikverket fördelar projektbidrag till professionella samarbetsprojekt i det fria musiklivet, med särskilt fokus på förnyelse och jämställdhet. Utlysningsomgångar publiceras på musikverket.se.', 'Ett vitalt fritt musikliv.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://musikverket.se/', 'none', 'assisted', 6, '', 'published', '295de765-5e57-4b2e-a720-eefdf8369fc9', '7d58f13b-d51a-4245-bb07-dfe80ed35e83', 'https://musikverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.207732+00', '2026-08-28 17:30:50.207732+00'),
	('a982ea09-aeab-4287-841b-c09fd33456bc', '30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', '311f1e01-c92a-468a-854d-2e920378f509', 'erasmus-ka2-smaskaliga-partnerskap', 'Erasmus+ — Småskaliga partnerskap (KA2)', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Småskaliga partnerskap är utformade för att sänka tröskeln för organisationer som är nya i Erasmus+: färre krav, schablonbelopp (typiskt 30 000 eller 60 000 euro) och minst en partner i ett annat programland.', 'Bredda deltagandet i europeiskt samarbete.', 'eu_grant', '["association", "municipality", "school", "public_body"]', '["SE"]', '["education", "youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/', 'eu_login', 'assisted', 10, '', 'published', '0bd0b61b-05fc-40d4-9eb4-fed4ae0fb98f', NULL, 'https://erasmus-plus.ec.europa.eu/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.213817+00', '2026-08-28 17:30:50.213817+00'),
	('3f29bfda-af66-4da9-9f5d-4700773d645d', 'defe9be7-89f2-4f33-8337-76d282f7a1c5', '6b04e498-0db9-4e0a-ae84-3e2a1e4508cc', 'tillvaxtverket-regionalt-investeringsstod', 'Tillväxtverket — Regionalt investeringsstöd', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Regionalt investeringsstöd kan delfinansiera större investeringar i stödområde A och B. Stödandel beror på område och företagsstorlek. Söks via Min ansökan.', 'Hållbar tillväxt i regioner med geografiska lägesnackdelar.', 'public_grant', '["company"]', '["SE"]', '[]', NULL, NULL, 'SEK', 35, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) innan investeringen påbörjas.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 12, '', 'published', '0d3badca-ad1d-4b91-90f0-25aeb9dbd509', 'd5d4afd3-fd05-4b41-9da2-01513a9e448a', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.221297+00', '2026-08-28 17:30:50.221297+00'),
	('f9e5e1aa-035c-4cc3-846a-892a17e7ebd8', '790d2ba3-423f-4f9d-bd31-fa05daad4345', '950ab058-67e8-476a-9424-010443b14808', 'kulturradet-inkopsstod-bibliotek', 'Kulturrådet — Inköpsstöd till folk- och skolbibliotek', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Inköpsstödet söks av kommuner för att stärka bibliotekens utbud av litteratur för barn och unga. Årlig omgång.', 'Läsfrämjande och tillgång till litteratur.', 'public_grant', '["municipality"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 3, '', 'published', 'fe88332e-bf60-47b0-abcd-f4fa44c8a9f2', '7dea1841-65cc-480f-9b87-22177e7b0032', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.228691+00', '2026-08-28 17:30:50.228691+00'),
	('0cafa3dc-381f-4fe9-82be-dfed79fc9d36', '790d2ba3-423f-4f9d-bd31-fa05daad4345', '950ab058-67e8-476a-9424-010443b14808', 'kulturradet-litteraturstod', 'Kulturrådet — Litteraturstöd (efterhandsstöd till utgivning)', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Litteraturstödet är ett efterhandsstöd som förlag söker för utgiven kvalitetslitteratur inom olika kategorier. Beslut fattas av arbetsgrupper med litterär expertis.', 'Bredd och kvalitet i svensk bokutgivning.', 'public_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', 'eeba7957-2bfc-461c-8b25-afc232592e25', '7dea1841-65cc-480f-9b87-22177e7b0032', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.233232+00', '2026-08-28 17:30:50.233232+00'),
	('a15fc2f5-15d4-43d7-9f80-db3711a7eeeb', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'e7160993-7fbb-400a-b5cf-269acee1dd79', 'kommun-elevresor-gymnasiet', 'Din kommun — Stöd för elevresor på gymnasiet', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Enligt lag (1991:1110) ska hemkommunen ansvara för kostnader för dagliga resor mellan bostaden och gymnasieskolan för elever med studiehjälp, om färdvägen är minst sex kilometer. Stödet ges oftast som busskort/resekort och söks hos hemkommunen.', 'Gymnasieelever ska kunna ta sig till skolan oavsett var de bor.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos elevens hemkommun, vanligen inför varje läsår.', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'none', 'assisted', 1, '', 'published', 'd792dd0f-3d84-4144-a9c1-a030482841fe', 'f2cfe006-5834-4922-80d1-df959e7b79a6', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.087479+00', '2026-08-28 17:30:50.087479+00'),
	('5c96a984-730a-4687-8d55-ffdb56fa4cda', '356e2388-b799-4434-9b34-5d6f93a6b058', 'f1a74dc3-f423-49e7-b849-9dd6824843f3', 'fk-bostadsbidrag-unga', 'Försäkringskassan — Bostadsbidrag för unga (18–28 år)', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Unga mellan 18 och 28 år utan barn kan få bostadsbidrag om inkomsten är låg och boendekostnaden tillräckligt hög. Ansökan görs hos Försäkringskassan.', 'Ekonomisk trygghet i boendet för unga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '21132d5f-c0af-4cbb-a6ed-84b1718f6a05', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.092857+00', '2026-08-28 17:30:50.092857+00'),
	('99920797-c699-40fc-ac6e-c5cc631aced0', 'e61f7274-52de-4471-83ae-cc934b981d89', '6fa8d0d6-98c6-40af-9d78-643820e8b2dd', 'kommun-forsorjningsstod', 'Socialtjänsten — Försörjningsstöd (ekonomiskt bistånd)', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Försörjningsstöd kan beviljas av socialtjänsten i din kommun när du inte kan försörja dig själv och saknar tillgångar som kan täcka behoven. Stödet prövas individuellt utifrån hela hushållets ekonomi, och du förväntas först ha sökt andra ersättningar du kan ha rätt till. Ansökan görs hos din kommun.', 'Skälig levnadsnivå enligt socialtjänstlagen.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos socialtjänsten i din kommun — ofta via kommunens e-tjänst eller ett bokat besök.', 'https://www.socialstyrelsen.se/', 'none', 'assisted', 2, '', 'published', 'e6607bc9-e7df-4c55-aa16-739410a61b55', 'd29dae95-7923-4eae-968d-e263b2fc0f92', 'https://www.socialstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.100474+00', '2026-08-28 17:30:50.100474+00'),
	('eb52f86a-001b-4da2-bd54-e409c8b96089', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'a59dcf28-938b-4358-93eb-10d3d4804d06', 'csn-studiemedel', 'CSN — Studiemedel (bidrag och studielån)', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Studiemedel består av en bidragsdel och en frivillig lånedel för studier i Sverige eller utomlands. Kraven gäller bl.a. studiernas omfattning, tidigare studieresultat och ålder. Ansökan görs hos CSN.', 'Ekonomiska möjligheter att studera.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Mina sidor hos CSN (kräver e-legitimation).', 'https://www.csn.se/', 'eid', 'assisted', 1, '', 'published', '50b6000c-6ee0-484c-846c-33358b926983', 'a25f131a-2056-4e39-b26e-ce317ba1ca0b', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.107906+00', '2026-08-28 17:30:50.107906+00'),
	('8368ce79-e59e-441a-b532-8fdc8e643995', '356e2388-b799-4434-9b34-5d6f93a6b058', '836ed04e-90fa-421f-9f26-68ef8b7af778', 'fk-aktivitetsersattning', 'Försäkringskassan — Aktivitetsersättning vid nedsatt arbetsförmåga', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Aktivitetsersättning kan lämnas till den som är 19–29 år och har arbetsförmågan nedsatt med minst en fjärdedel under minst ett år. Läkarutlåtande krävs. Ansökan görs hos Försäkringskassan; beslutet fattas efter medicinsk utredning.', 'Ekonomisk trygghet vid långvarigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan tillsammans med läkarutlåtande.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', 'f55d01de-55ae-4858-9665-45f1ba2ab3e6', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.114988+00', '2026-08-28 17:30:50.114988+00'),
	('2860dbb0-554f-4653-8cbb-c248cef4bdc7', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', '87219366-c48c-426c-a7f2-128dc516d7ec', 'csn-omstallningsstudiestod', 'CSN — Omställningsstudiestöd', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Omställningsstudiestödet riktar sig till dig som arbetat länge och vill studera för att bli mer attraktiv på arbetsmarknaden. Kräver bl.a. etablering på arbetsmarknaden (arbetade år) och att utbildningen stärker din framtida ställning. Söktrycket är högt och handläggningstiderna kan vara långa.', 'Omställning och kompetensutveckling mitt i arbetslivet.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN; omställningsorganisationen kan komplettera med kollektivavtalat stöd.', 'https://www.csn.se/', 'eid', 'assisted', 3, '', 'published', '3747c388-834e-4627-84d8-8d6b66ec37a9', 'a25f131a-2056-4e39-b26e-ce317ba1ca0b', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.149472+00', '2026-08-28 17:30:50.149472+00'),
	('4a5c9a5c-bfce-4759-a9e1-5ef9286562b1', '775271e3-a9b2-4704-a04b-9eb6e0e52562', '84babba5-f9de-474d-a506-f48128560b1c', 'kommun-bostadsanpassningsbidrag', 'Din kommun — Bostadsanpassningsbidrag', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Bostadsanpassningsbidraget är ett kommunalt bidrag enligt lag för den som har en bestående funktionsnedsättning och behöver anpassa sin permanentbostad. Intyg från t.ex. arbetsterapeut krävs. Ansökan görs hos kommunen.', 'Självständigt liv i egen bostad.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos din kommun, ofta via e-tjänst eller blankett, med intyg.', 'https://www.boverket.se/sv/bidrag--garantier/', 'none', 'assisted', 3, '', 'published', '4cf187ce-c3f3-4e22-ac23-d551e17748c9', NULL, 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.158266+00', '2026-08-28 17:30:50.158266+00'),
	('3ef92ea6-3338-4b14-8e4b-eb12ace30e0b', 'ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', '131b4080-7ad2-4c15-ba0e-473bdcad3f45', 'konstnarsnamnden-kulturbryggan', 'Konstnärsnämnden — Kulturbryggan', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Kulturbryggan är Konstnärsnämndens stöd till kulturprojekt som är nyskapande i förhållande till etablerade uttryck och strukturer. Söks i utlysningsomgångar av både enskilda och organisationer.', 'Förnyelse och experiment i kulturlivet.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 8, '', 'published', '1617bf68-91b8-4739-ba84-86402198934a', 'a778d0a0-ba7d-4b13-99a3-a3c7b00eeb47', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.165509+00', '2026-08-28 17:30:50.165509+00'),
	('73676412-9575-4972-a5e3-7b01393e0168', '44ccc9f1-b4bf-4333-9623-e15c456e32d5', 'f180e5fc-f9a6-445d-bebd-f621fb682b1d', 'raa-kulturarvsbidrag', 'Riksantikvarieämbetet — Bidrag till kulturarvsarbete', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Riksantikvarieämbetet fördelar årligen bidrag till ideellt kulturarvsarbete — t.ex. hembygdsrörelsen och arbetslivsmuseer. Årlig ansökningsomgång.', 'Ett levande och tillgängligt kulturarv.', 'public_grant', '["association", "foundation"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.raa.se/', 'none', 'assisted', 6, '', 'published', 'dfb1c9ec-48d2-4093-8aa7-3af05a9fab1a', '50086a50-79f5-440c-b634-8a4ce1d4fb55', 'https://www.raa.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.172412+00', '2026-08-28 17:30:50.172412+00');
INSERT INTO public.funding_opportunities VALUES
	('ec1cab90-c695-4f9f-b5c7-e2a4785dce42', '91a8f2a5-5cea-4289-8886-257ce35181c5', 'e33ed590-423a-419e-b1e1-977add659a19', 'si-creative-force', 'Svenska institutet — Creative Force', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Creative Force ger stöd till svenska organisationers samarbetsprojekt med partner i vissa länder, där kultur eller media används som verktyg för demokrati, jämlikhet och yttrandefrihet. Länderlista och villkor per utlysning.', 'Demokrati och yttrandefrihet genom kultur och media.', 'project_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://si.se/', 'none', 'assisted', 10, '', 'published', '072754db-0473-419e-990f-8dc56c5341a9', '53ad8826-d0f1-43c8-849e-51873f0a4fba', 'https://si.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.179649+00', '2026-08-28 17:30:50.179649+00'),
	('9f060715-2c83-47b7-9b1f-b25cfcb0d3c8', 'd012d319-6538-4150-90f1-c8a7b82a28f8', '9d4862d4-57df-45b0-8339-75fd5d5027ba', 'nordisk-kulturfond-projektstod', 'Nordisk kulturfond — Projektstöd', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Nordisk kulturfond stödjer projekt som utvecklar konst- och kulturlivet i Norden och involverar flera nordiska länder. Flera ansökningsfrister per år.', 'Ett dynamiskt nordiskt konst- och kulturliv.', 'project_grant', '["individual", "association", "company", "public_body"]', '["SE", "DK", "NO", "FI", "IS"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.nordiskkulturfond.org/', 'none', 'assisted', 8, '', 'published', 'b0014add-c5d5-4a76-8ac4-858e848b4a6b', 'cc34f9cd-f1dc-4129-800e-c49e9d09fcbf', 'https://www.nordiskkulturfond.org/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.186653+00', '2026-08-28 17:30:50.186653+00'),
	('f22969a7-5225-427b-82e3-d9fc1ea37ced', '2c787c76-4737-49c9-b8b4-63bc29e78dfb', 'b41a7c10-1e28-4eae-a587-33814301c5a6', 'vr-projektbidrag', 'Vetenskapsrådet — Projektbidrag (fri forskning)', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Vetenskapsrådets projektbidrag söks av disputerade forskare via svenska lärosäten i årliga utlysningar per ämnesområde.', 'Forskning av högsta vetenskapliga kvalitet.', 'public_grant', '["university"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.vr.se/', 'none', 'assisted', 20, '', 'published', '4ae6be54-0df2-41de-9fe2-63d63216de7a', 'cd5d13dc-5cd3-48e7-87ad-66a26ec3c9b5', 'https://www.vr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.193464+00', '2026-08-28 17:30:50.193464+00'),
	('32f951b7-0352-485d-a7a7-f8290c8feabe', 'e30c7a25-122b-43bc-bced-3009439fbd97', 'a7cbd2b2-86aa-4e7b-b820-876672883183', 'postkodstiftelsen-projektstod', 'Svenska Postkodstiftelsen — Projektstöd', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Postkodstiftelsen stödjer ideella organisationer med projekt inom bl.a. mänskliga rättigheter, miljö och kultur. Ansökan kan lämnas löpande via stiftelsens webbplats.', 'Positiv förändring för människor och miljö.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "environment", "culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://postkodstiftelsen.se/', 'none', 'assisted', 8, '', 'published', '622a6e61-ab71-4db7-89b7-c25854a47c21', '67911d73-2282-4c13-9fff-2e6957022819', 'https://postkodstiftelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.201174+00', '2026-08-28 17:30:50.201174+00'),
	('2fdec643-5329-4cba-82ac-0ab8265083f5', 'c9ab513b-a69e-47e2-b855-acc8c910e74f', '8e256f73-bb08-492e-b98e-67b2b6036a58', 'lansstyrelsen-bygdemedel', 'Länsstyrelsen — Bygdemedel', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Bygdemedel är ersättningar från vattenkraft (och i vissa län vindkraft) som återförs till berörda bygder. Föreningar och kommuner kan söka för t.ex. samlingslokaler, leder och bygdeutveckling. Villkor varierar per län.', 'Lokal utveckling i berörda bygder.', 'public_grant', '["association", "municipality"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos länsstyrelsen i ditt län, ofta via e-tjänst.', 'https://www.lansstyrelsen.se/', 'eid', 'assisted', 6, '', 'published', '7a924793-34aa-485a-9f94-f46eafddaacd', 'cfacfd92-24aa-4fa5-b957-ddd38dbf815f', 'https://www.lansstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.241299+00', '2026-08-28 17:30:50.241299+00'),
	('abbae5ba-41cd-4d64-a370-089591b8727b', '5ec8e845-3c3f-497b-8ae4-34245b3d8fae', '136f10a7-e1f6-48a0-8006-f03acb450a05', 'migrationsverket-atervandringsbidrag', 'Migrationsverket — Stöd vid frivillig återvandring', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Den som har uppehållstillstånd som flykting eller skyddsbehövande (samt vissa anhöriga) och frivilligt vill återvandra permanent kan ansöka om bidrag till resa och återetablering. Schablonbeloppen är beslutade att höjas väsentligt från 2026 — kontrollera aktuella belopp och villkor hos Migrationsverket innan beslut. Beslutet att återvandra är oåterkalleligt i bidragshänseende: uppehållstillståndet återkallas normalt.', 'Möjliggöra frivillig, värdig återvandring för den som själv vill.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Migrationsverket före utresan.', 'https://www.migrationsverket.se/', 'none', 'assisted', 3, '', 'published', 'babcda21-24d2-4b1a-a34f-963ff4b8f0ea', '1a8b8a62-a1ba-451c-bf62-e666c3b5b463', 'https://www.migrationsverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.250121+00', '2026-08-28 17:30:50.250121+00'),
	('b3344631-582f-4f26-b0c1-1d9da050b7c8', 'd498d63f-945c-4e31-8042-2503c6c643e6', '80762b86-2ed1-45b7-b56a-c8620b9a272c', 'af-eures-targeted-mobility', 'EURES — Targeted Mobility Scheme (jobb i annat EU-land)', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU:s riktade rörlighetsprogram hjälper arbetssökande från 18 år att ta anställning i ett annat EU-/EES-land. Stödet kan omfatta bidrag till intervjuresa, flytt, språkkurs och erkännande av kvalifikationer — beloppen är schabloner per insats och land och varierar per programperiod. Vägen in är EURES-rådgivarna hos Arbetsförmedlingen.', 'Rörlighet på den europeiska arbetsmarknaden.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta en EURES-rådgivare via Arbetsförmedlingen — ansökan görs innan flytten/resan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '6a97913c-be23-47c1-a03d-6dc93c975422', 'd4bf2c40-9127-4bc8-8fdc-a0011b07b0e6', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.257982+00', '2026-08-28 17:30:50.257982+00'),
	('b2b95a8a-5434-45a4-ae1d-c5da68c8c0a9', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'a59dcf28-938b-4358-93eb-10d3d4804d06', 'csn-utlandsstudier', 'CSN — Studiemedel för utlandsstudier', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Studiemedel kan tas med till studier utomlands på utbildningar som uppfyller CSN:s krav. Utöver ordinarie bidrag och lån finns merkostnadslån för undervisningsavgifter, resor och försäkring. Utbildningen och skolan ska vara godkänd — kontrollera i CSN:s tjänst innan du tackar ja till en plats.', 'Göra utlandsstudier möjliga oavsett privatekonomi.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN med e-legitimation.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', 'b0f8d96b-261f-43af-bc1f-a407c8b44110', 'a25f131a-2056-4e39-b26e-ce317ba1ca0b', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.263457+00', '2026-08-28 17:30:50.263457+00'),
	('ba3032a0-7fc8-40de-aa75-909e0c0ab2ef', '356e2388-b799-4434-9b34-5d6f93a6b058', 'f0ee96d9-318a-4597-9670-3bbb2798b584', 'fk-omvardnadsbidrag', 'Försäkringskassan — Omvårdnadsbidrag för barn med funktionsnedsättning', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Omvårdnadsbidrag kan lämnas till vårdnadshavare för barn med funktionsnedsättning som behöver mer omvårdnad och tillsyn än jämnåriga. Bidraget finns i fyra nivåer utifrån barnets sammanlagda behov och kan lämnas till och med juni det år barnet fyller 19. Ansökan görs hos Försäkringskassan; ett läkarutlåtande om barnets funktionsnedsättning behövs.', 'Ge föräldrar ekonomiskt utrymme för den extra omvårdnad barnet behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); läkarutlåtande bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', '5a410004-b03c-437c-b6bc-ed35f076c226', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.271089+00', '2026-08-28 17:30:50.271089+00'),
	('9d74542e-d4fd-44f5-a5ae-8548bee7b07e', '356e2388-b799-4434-9b34-5d6f93a6b058', '229f65cb-c573-413f-bb7e-8fab0db2fdc7', 'fk-merkostnadsersattning', 'Försäkringskassan — Merkostnadsersättning vid funktionsnedsättning', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Merkostnadsersättning kan lämnas när en varaktig funktionsnedsättning medför merkostnader — t.ex. slitage, hjälpmedel, resor eller särskild kost. Ersättningen finns i fem nivåer och kräver att merkostnaderna når upp till en lägsta nivå per år (knuten till prisbasbeloppet). Både vuxna med funktionsnedsättning och vårdnadshavare för barn kan ansöka hos Försäkringskassan.', 'Utjämna de extra kostnader en funktionsnedsättning medför.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); merkostnaderna specificeras.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', 'aa4b34e0-6053-48af-b511-c218410bbee1', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.278747+00', '2026-08-28 17:30:50.278747+00'),
	('6df88dc2-0527-49fb-b7be-cd1bcd3e9394', '356e2388-b799-4434-9b34-5d6f93a6b058', 'c2f6e968-dab8-4a36-a564-9f2d95ab991a', 'fk-bilstod', 'Försäkringskassan — Bilstöd vid funktionsnedsättning', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Bilstöd kan lämnas till den som har en varaktig funktionsnedsättning med stora svårigheter att förflytta sig på egen hand eller att använda allmänna kommunikationer — och till föräldrar till barn med sådan funktionsnedsättning. Stödet består av flera delar: grundbidrag, inkomstprövat anskaffningsbidrag och anpassningsbidrag för särskild utrustning. Nytt bilstöd kan normalt beviljas först efter nio år.', 'Göra det möjligt att förflytta sig självständigt när kollektivtrafik inte fungerar.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande om funktionsnedsättningen och körkortsuppgifter behövs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', 'f1cde184-128b-47dd-9f05-fb27d95462f4', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.285007+00', '2026-08-28 17:30:50.285007+00'),
	('b474bc96-8fab-4953-8905-72bbc9703875', '356e2388-b799-4434-9b34-5d6f93a6b058', '54065071-e746-406a-9436-c69bbf7ed11d', 'fk-foraldrapenning', 'Försäkringskassan — Föräldrapenning', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Föräldrapenning kan tas ut av föräldrar (och i vissa fall andra vårdnadshavare) för tid med barnet, från graviditet tills barnet fyllt tolv år, med flest dagar under de första åren. Ersättningens nivå beror på din inkomst och vilken typ av dagar du tar ut; nivåer och regler framgår hos Försäkringskassan. Ansökan görs i efterhand för de dagar du varit ledig.', 'Möjliggöra föräldraledighet med ersättning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '0d2444d4-1130-44fb-bbd5-101305fb737d', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.378227+00', '2026-08-28 17:30:50.378227+00'),
	('d258b038-bcd2-4c92-b696-17332a540339', '356e2388-b799-4434-9b34-5d6f93a6b058', '19bea494-a278-49ca-9af5-ab9beb8c02f1', 'fk-narstaendepenning', 'Försäkringskassan — Närståendepenning', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Närståendepenning kan lämnas när du avstår från förvärvsarbete för att vårda eller vara nära en närstående med en sjukdom som innebär ett påtagligt hot mot livet. Ersättningen kan betalas i upp till 100 dagar per person som vårdas (dagarna kan delas mellan flera närstående). Läkarutlåtande om den sjukes tillstånd och den sjukes samtycke krävs.', 'Ingen ska behöva välja mellan sin försörjning och att finnas hos en svårt sjuk anhörig.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarutlåtande och den sjukes samtycke bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '5f52e832-667b-458e-9f33-76e6b809e337', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.291594+00', '2026-08-28 17:30:50.291594+00'),
	('c144f440-1e1e-4d57-9229-3e239b75c5d7', 'd498d63f-945c-4e31-8042-2503c6c643e6', '1e00c578-56f9-438a-9bdb-ff57c56f6323', 'af-etableringsersattning', 'Arbetsförmedlingen — Etableringsersättning för nyanlända', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Den som nyligen fått uppehållstillstånd (som skyddsbehövande eller vissa anhöriga) och är 20–66 år kan delta i Arbetsförmedlingens etableringsprogram och få etableringsersättning under tiden. Den som har barn eller bor ensam i egen bostad kan även få etableringstillägg respektive bostadsersättning. Arbetsförmedlingen beslutar om programmet; Försäkringskassan beslutar om och betalar ut ersättningen.', 'Försörjning under de första årens etablering i arbets- och samhällslivet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen; ersättningen ansöks sedan hos Försäkringskassan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '5e66f243-5350-467f-963a-d69feffaa696', 'd4bf2c40-9127-4bc8-8fdc-a0011b07b0e6', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.298255+00', '2026-08-28 17:30:50.298255+00'),
	('019ef51d-398d-459c-a57c-85eec18ac253', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', '9b71c694-2946-499d-9083-27634a9a13de', 'csn-hemutrustningslan', 'CSN — Hemutrustningslån för nyanlända', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Hemutrustningslån kan lämnas till flyktingar och vissa anhöriga som tagits emot i en kommun och behöver utrusta ett första hem i Sverige. Lånet söks hos CSN inom två år från det första kommunmottagandet, har låg ränta och betalas tillbaka enligt en plan som tar hänsyn till inkomst. Det är ett lån — inte ett bidrag — och ska betalas tillbaka.', 'Ett fungerande hem från start, utan att behöva vända sig till dyra krediter.', 'loan', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos CSN; kommunmottagandet styr vilka som kan söka.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', '65ccccbb-2313-442f-b9e8-dfc5bf98bb40', 'a25f131a-2056-4e39-b26e-ce317ba1ca0b', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.3045+00', '2026-08-28 17:30:50.3045+00'),
	('cc6b0482-bf43-434e-9a57-8b2ad0c5c77b', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'a5679c04-40f3-44b1-b52a-b8fb3fcb3a17', 'csn-studiestartsstod', 'CSN — Studiestartsstöd för arbetslösa med kort utbildning', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Studiestartsstöd är ett rent bidrag (ingen lånedel) för den som är 25–60 år, har varit arbetslös, har kort tidigare utbildning och behöver studera på grundskole- eller gymnasienivå för att stärka sina chanser till jobb. Stödet kan lämnas i upp till 50 veckor. Hemkommunen bedömer om du tillhör målgruppen; ansökan görs sedan hos CSN.', 'Sänka tröskeln till studier för den som behöver dem mest.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta hemkommunen (målgruppsbedömning) och ansök därefter hos CSN.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '649453ec-5fee-49e4-8c89-c15abbbdfa19', 'a25f131a-2056-4e39-b26e-ce317ba1ca0b', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.311916+00', '2026-08-28 17:30:50.311916+00'),
	('2dee0a22-35d6-4d57-bbb2-f66264d3fc9e', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'b28d2c92-5aa4-454b-bb6e-27054c92fb16', 'csn-inackorderingstillagg', 'CSN — Inackorderingstillägg för gymnasieelever som bor på studieorten', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Elever på fristående gymnasieskolor och folkhögskolor som måste inackordera sig på studieorten på grund av lång eller besvärlig resväg kan få inackorderingstillägg från CSN. Går eleven på en kommunal gymnasieskola är det i stället hemkommunen som ger stöd till inackordering — kontrollera med kommunen. Tillägget söks för varje läsår.', 'Gymnasievalet ska inte begränsas av var i landet utbildningen finns.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos CSN (fristående skola/folkhögskola) eller hos hemkommunen (kommunal skola), inför varje läsår.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', 'a1dac4bf-59fe-4855-a469-66b4566b0671', 'a25f131a-2056-4e39-b26e-ce317ba1ca0b', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.318216+00', '2026-08-28 17:30:50.318216+00'),
	('6949dd50-4014-4632-ad2f-e5ec791d0ae8', '775271e3-a9b2-4704-a04b-9eb6e0e52562', '270c6fe3-cacf-4dd2-907f-3d51da5bbe68', 'kommun-foreningsbidrag', 'Din kommun — Föreningsbidrag (aktivitets-, lokal- och startbidrag)', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'I stort sett alla kommuner ger bidrag till lokala föreningar — vanligast är aktivitetsstöd per deltagartillfälle för barn- och ungdomsverksamhet, bidrag till lokalhyra och startbidrag för nya föreningar. Regler, belopp och ansökningstider skiljer sig åt mellan kommuner; ansökan görs hos kultur- och fritidsförvaltningen i den kommun där föreningen är verksam.', 'Ett levande lokalt föreningsliv med låga trösklar för deltagande.', 'public_grant', '["association"]', '["SE"]', '["civil_society", "sports", "culture", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos kommunens kultur- och fritidsförvaltning — rutiner och tider varierar per kommun.', 'https://www.skr.se/', 'none', 'assisted', 2, '', 'published', '2b6c7a4c-050b-414e-a129-85146541fb97', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.329126+00', '2026-08-28 17:30:50.329126+00'),
	('4e96271f-fba4-4946-b61d-e5c65b2df39e', 'fa5dfa8b-3f48-4480-933d-456a4159612b', '3adb99b6-3170-46f5-bb01-6dbd81c0d466', 'region-kulturstod', 'Din region — Regionala kulturstöd och projektbidrag', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Alla regioner fördelar egna kulturstöd — projektbidrag, arrangörsstöd och stipendier — inom kultursamverkansmodellen. Stöden riktar sig till kulturaktörer med förankring i regionen och söks direkt hos regionens kulturförvaltning. Utlysningar, belopp och tider varierar per region; kontrollera din regions kultursidor.', 'Ett professionellt och tillgängligt kulturliv i hela regionen.', 'public_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos regionens kulturförvaltning — utlysningar publiceras på regionens webbplats.', 'https://www.skr.se/', 'none', 'assisted', 4, '', 'published', '094a2274-7a37-419d-8eb5-428804dd84c3', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.336305+00', '2026-08-28 17:30:50.336305+00'),
	('84126469-19cf-42c9-bcae-0fa870cdd7fd', 'ba1278ad-4f74-44c5-8851-f51fd092f029', 'efe2dd5d-4330-4583-80ea-d4999355ed02', 'sparbanksstiftelsen-projektstod', 'Sparbanksstiftelsen i ditt område — Bidrag till lokala projekt', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Sparbanksstiftelserna förvaltar sparbanksrörelsens överskott och delar ut bidrag till projekt som utvecklar det lokala samhället — ofta inom idrott, kultur, utbildning, forskning och näringslivsutveckling. Varje stiftelse beslutar självständigt och stödjer bara projekt i den egna sparbankens verksamhetsområde. Hitta stiftelsen där ni verkar och sök enligt dess rutiner.', 'Lokal utveckling där sparbanken verkar.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "sports", "culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos den sparbanksstiftelse vars område ni verkar i — rutiner varierar per stiftelse.', 'https://www.sparbankerna.se/', 'none', 'assisted', 3, '', 'published', 'd680d1c4-cc0a-4aa1-91cc-dff3ccf677e4', '3d60d3f0-d2b2-47d3-8986-73f530c0f593', 'https://www.sparbankerna.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.342619+00', '2026-08-28 17:30:50.342619+00'),
	('457fb4d3-6027-4768-8a18-51f7c9dbd771', 'b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', '14f69cfc-8c24-40c1-a79e-340a70ce88a7', 'leader-lokalt-ledd-utveckling', 'Leader — Projektstöd för lokalt ledd utveckling på landsbygden', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Genom Leader finansieras lokala utvecklingsprojekt på landsbygden med medel från EU och svenska staten. Sverige är indelat i ett fyrtiotal leaderområden med egna utvecklingsstrategier; projektidén söks hos leaderområdets kansli, prioriteras av den lokala LAG-styrelsen och beslutas formellt av Jordbruksverket. Föreningar, företag, kommuner och andra lokala aktörer kan söka.', 'Utveckling av landsbygden utifrån lokala behov och idéer.', 'eu_grant', '["association", "company", "municipality"]', '["SE"]', '["rural", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta ditt leaderområdes kansli; ansökan lämnas i Jordbruksverkets e-tjänst.', 'https://jordbruksverket.se/', 'none', 'assisted', 8, '', 'published', '8bc57843-f5b3-4066-b501-b5f48fccf1ee', 'feb8a47e-115b-462b-9cf6-b8866d96ce4e', 'https://jordbruksverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.349437+00', '2026-08-28 17:30:50.349437+00'),
	('668709ea-2bb8-47e8-a386-f2606decf6bb', '8b2c3f3b-ef6f-415a-a343-0a72393107a6', '2da528c3-6331-4d68-a523-6006a6d16644', 'forte-projektbidrag', 'Forte — Projektbidrag för forskning om hälsa, arbetsliv och välfärd', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Forte är det statliga forskningsrådet för hälsa, arbetsliv och välfärd och utlyser projektbidrag, postdokbidrag och programstöd inom sina områden. Bidragen söks av disputerade forskare och förvaltas av ett svenskt lärosäte eller annan godkänd medelsförvaltare. Årliga öppna utlysningar publiceras på forte.se.', 'Kunskap som förbättrar människors hälsa, arbetsliv och välfärd.', 'public_grant', '["university"]', '["SE"]', '["research"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan i Fortes ansökningssystem Prisma, via medelsförvaltaren.', 'https://forte.se/', 'none', 'assisted', 15, '', 'published', '806e1ee1-abb4-4b5a-8202-793c17c4d997', '51eb7c8d-8165-42e4-bf3e-1eed28ed42cb', 'https://forte.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.355466+00', '2026-08-28 17:30:50.355466+00'),
	('357e2489-1440-4e44-8fb1-d528a58df995', '06c449c3-980c-4486-a438-c8f040513700', '5863445d-cf1e-4527-955f-3d83bafbf22a', 'radiohjalpen-projektbidrag', 'Radiohjälpen — Projektbidrag ur insamlingskampanjerna', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Radiohjälpen fördelar insamlade medel till projekt som drivs av svenska ideella organisationer med 90-konto: internationella humanitära insatser och utvecklingsprojekt (t.ex. Världens Barn, Musikhjälpen) samt nationella insatser för barn och unga med funktionsnedsättning eller kronisk sjukdom (Victoriafonden — där kan även t.ex. kuratorer söka aktivitets- och lägerbidrag för enskilda barn). Utlysningar och villkor finns på radiohjalpen.se.', 'Insamlade medel ska nå fram genom seriösa organisationer.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan enligt respektive utlysning på radiohjalpen.se.', 'https://www.radiohjalpen.se/', 'none', 'assisted', 6, '', 'published', 'eca76421-d321-4a54-9cee-0f42358300e0', 'aee0d120-bb43-4d07-bd64-188e3e247bc9', 'https://www.radiohjalpen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.362014+00', '2026-08-28 17:30:50.362014+00'),
	('ff3a8408-8ff8-42b7-83ca-79d7bc824d85', '356e2388-b799-4434-9b34-5d6f93a6b058', '54065071-e746-406a-9436-c69bbf7ed11d', 'fk-barnbidrag', 'Försäkringskassan — Barnbidrag', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Barnbidrag lämnas för barn som bor i Sverige, normalt utan ansökan — det betalas ut automatiskt från månaden efter födseln eller flytten till Sverige. Ansökan behövs i vissa fall, till exempel när barnet flyttar hit eller vid ändrad utbetalningsmottagare. Beloppet per barn och månad framgår hos Försäkringskassan. Från och med det andra barnet lämnas även flerbarnstillägg (egen post).', 'Ekonomisk grundtrygghet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt; ansökan i särskilda fall på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '3dc21f82-2c94-4b2b-8ace-de04d2e68fc3', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.366852+00', '2026-08-28 17:30:50.366852+00'),
	('cc802fc0-832c-43ae-89ed-8afcf1335a95', '356e2388-b799-4434-9b34-5d6f93a6b058', '54065071-e746-406a-9436-c69bbf7ed11d', 'fk-flerbarnstillagg', 'Försäkringskassan — Flerbarnstillägg', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Flerbarnstillägg lämnas automatiskt till den som får barnbidrag för två eller fler barn — ingen separat ansökan behövs i normalfallet. Tillägget ökar med antalet barn; nivåerna framgår hos Försäkringskassan. Den som har barn över 16 år som studerar kan i vissa fall behöva anmäla för fortsatt flerbarnstillägg.', 'Förstärkt stöd till familjer med flera barn.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt tillsammans med barnbidraget.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'ae03afb4-54bc-4f18-bfe7-73011d2c0166', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.371956+00', '2026-08-28 17:30:50.371956+00'),
	('1d8bf172-7160-4f8b-b661-a72fb5630bc3', '356e2388-b799-4434-9b34-5d6f93a6b058', '54065071-e746-406a-9436-c69bbf7ed11d', 'fk-tillfallig-foraldrapenning', 'Försäkringskassan — Tillfällig föräldrapenning (vab)', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Tillfällig föräldrapenning — i dagligt tal vab — kan lämnas när du avstår från arbete för att vårda ett sjukt barn som är under 12 år (i vissa fall äldre). Ersättningen baseras på din inkomst; nivå och antal dagar framgår hos Försäkringskassan. Anmäl första dagen och ansök i efterhand; läkarintyg krävs från åttonde dagen.', 'Göra det möjligt att vårda sjukt barn utan att förlora hela inkomsten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Anmäl och ansök på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '695181e8-d9cd-483e-ad76-56a3cc8d2bf3', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.384031+00', '2026-08-28 17:30:50.384031+00'),
	('ecb386d0-e9ce-42d2-9e36-c34092fc7c04', '356e2388-b799-4434-9b34-5d6f93a6b058', '9074d696-9a21-4809-a2b4-4c2afcb4c8ab', 'fk-sjukpenning', 'Försäkringskassan — Sjukpenning', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Sjukpenning kan lämnas när sjukdom sätter ned din arbetsförmåga med minst en fjärdedel. Anställda får normalt sjuklön från arbetsgivaren de första två veckorna; därefter kan sjukpenning från Försäkringskassan ta vid. Egenföretagare och arbetslösa ansöker direkt. Läkarintyg krävs efter en tid; nivåer och regler framgår hos Försäkringskassan.', 'Försörjning när arbetsförmågan är nedsatt av sjukdom.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarintyg bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'c2f6630a-2b0b-471b-9e89-4514305b7833', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.389935+00', '2026-08-28 17:30:50.389935+00'),
	('fc461e3b-564a-4ad3-a056-d740c3789928', '356e2388-b799-4434-9b34-5d6f93a6b058', '9074d696-9a21-4809-a2b4-4c2afcb4c8ab', 'fk-sjukersattning', 'Försäkringskassan — Sjukersättning', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Sjukersättning kan lämnas till den som troligen aldrig kommer att kunna arbeta heltid på grund av sjukdom, skada eller funktionsnedsättning. Arbetsförmågan ska vara stadigvarande nedsatt med minst en fjärdedel i förhållande till hela arbetsmarknaden. Ersättningen kan vara inkomstrelaterad eller på garantinivå; regler och nivåer framgår hos Försäkringskassan.', 'Långsiktig försörjning vid varaktigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande krävs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', 'c4a02da7-a312-4fd7-bbf4-2d55dbf5d109', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.394701+00', '2026-08-28 17:30:50.394701+00'),
	('32c0bf5e-b6c0-4082-96ef-78ed224e4775', '356e2388-b799-4434-9b34-5d6f93a6b058', '92edf2a6-ebee-4aa6-a5cf-7704b65c3ec7', 'fk-aktivitetsstod', 'Försäkringskassan — Aktivitetsstöd', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Aktivitetsstöd lämnas till den som deltar i ett program hos Arbetsförmedlingen, till exempel jobb- och utvecklingsgarantin eller arbetsmarknadsutbildning. Arbetsförmedlingen anvisar programmet; Försäkringskassan beslutar om och betalar ut ersättningen, som bland annat beror på om du uppfyller villkoren för a-kassa. Yngre deltagare kan i stället få utvecklingsersättning.', 'Försörjning under program som stärker vägen till arbete.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Programmet anvisas av Arbetsförmedlingen; ersättningen ansöks månadsvis hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '7200e5a4-1f84-48cb-af39-2cb1a830f384', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.401909+00', '2026-08-28 17:30:50.401909+00'),
	('156324ee-3dbb-443f-89cd-33c115df4d08', '356e2388-b799-4434-9b34-5d6f93a6b058', 'f9bce642-3c37-4a9d-af5c-42e7a8c4f566', 'fk-tandvardsbidrag', 'Försäkringskassan — Allmänt tandvårdsbidrag (ATB)', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Det allmänna tandvårdsbidraget gäller alla från det år de fyller 24 och används automatiskt som avdrag när du besöker en ansluten tandläkare eller tandhygienist — ingen ansökan behövs. Beloppet beror på ålder och kan sparas ett år; nivåerna framgår hos Försäkringskassan. Den med särskilda behov kan därutöver ha rätt till särskilt tandvårdsbidrag.', 'Sänka tröskeln till regelbunden tandvård.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — säg till hos tandvården att du vill använda bidraget.', 'https://www.forsakringskassan.se/privatperson', 'none', 'assisted', 1, '', 'published', '3e2b91f1-eb99-4abd-8fca-2f74c9a5eef0', '19f5d5b1-f427-4094-852e-4b989e25cf16', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.409154+00', '2026-08-28 17:30:50.409154+00'),
	('68c9f539-b5cd-4ec4-b34d-037cdfc4f5a7', 'f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', '59ca1bca-357b-4690-a829-a41d9f76c41c', 'pm-garantipension', 'Pensionsmyndigheten — Garantipension', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Garantipension är ett grundskydd i den allmänna pensionen för den som haft låg eller ingen inkomstgrundad pension. Den betalas normalt ut automatiskt när du ansöker om allmän pension från riktåldern — ingen separat ansökan behövs om du bor i Sverige. Nivån beror på inkomstpensionens storlek, civilstånd och försäkringstid; detaljerna framgår hos Pensionsmyndigheten.', 'Lägsta rimliga pensionsnivå oavsett tidigare inkomster.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingår i ansökan om allmän pension hos Pensionsmyndigheten; prövas automatiskt.', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', 'dcd41ca8-cdd2-4766-955c-a183eb00632d', '0d17bd6d-d5c3-46c0-8dd5-ef420a2df55f', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.415005+00', '2026-08-28 17:30:50.415005+00'),
	('089965de-3eb0-469e-ac15-30f5c087c973', 'fa5dfa8b-3f48-4480-933d-456a4159612b', 'c92793ff-331d-4be7-920a-08e01c000647', 'region-hogkostnadsskydd-vard', 'Din region — Högkostnadsskydd för sjukvård', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Högkostnadsskyddet innebär att du under en period på tolv månader aldrig betalar mer än ett takbelopp i patientavgifter för öppen sjukvård; därefter får du frikort för resten av perioden. Registreringen sker normalt automatiskt i regionens system när du betalar. Takbeloppet fastställs årligen — se 1177 för aktuell nivå. Motsvarande skydd finns för läkemedel och sjukresor.', 'Skydda mot höga sammanlagda vårdkostnader.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — registreras normalt automatiskt i regionens system; spara kvitton vid besök i annan region.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', '1e73ed7d-2313-450b-b7c2-f8e576f7b593', '18b3814a-6e6d-4869-a4b6-ad0b6576cb86', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.422064+00', '2026-08-28 17:30:50.422064+00'),
	('1f5f3908-6d87-4a6a-a654-26fca5436623', '37e1245f-98d1-4063-be5f-c27054c5f82a', 'e8ebe0bc-d9b0-4817-b265-7f687c9f1517', 'akassa-arbetsloshetsersattning', 'Din a-kassa — Arbetslöshetsersättning (a-kassa)', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Arbetslöshetsersättning lämnas av a-kassorna till den som är arbetslös, inskriven hos Arbetsförmedlingen, aktivt söker arbete och uppfyller arbetsvillkoret. Medlemmar som uppfyllt medlemsvillkoret kan få inkomstbaserad ersättning; den som inte är medlem kan ha rätt till grundbelopp via Alfa-kassan. Vilken a-kassa som passar beror på bransch; villkor och nivåer framgår hos din a-kassa och Sveriges a-kassor.', 'Inkomsttrygghet under omställning mellan arbeten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen första arbetslösa dagen; ansök sedan hos din a-kassa (Mina sidor).', 'https://www.sverigesakassor.se/', 'eid', 'assisted', 1, '', 'published', 'e07cbbcb-f1da-42a6-a3e2-575436ec3b89', '5415f6a9-6f87-4ffe-a3cc-ea03a36153a9', 'https://www.sverigesakassor.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.428466+00', '2026-08-28 17:30:50.428466+00'),
	('c771903f-505b-4b60-9e42-acc4c4aaccd7', 'd498d63f-945c-4e31-8042-2503c6c643e6', '92f08bf5-672f-4ae3-8553-d1373721cdc7', 'af-nystartsjobb', 'Arbetsförmedlingen — Nystartsjobb', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Nystartsjobb ger arbetsgivare ett bidrag motsvarande en del av lönekostnaden vid anställning av personer som varit arbetslösa en längre tid, är nyanlända eller av andra skäl varit borta från arbetslivet. Stödets storlek och längd beror på den anställdas situation; villkoren framgår hos Arbetsförmedlingen. Anställningen ska ha marknadsmässiga villkor och beslut ska finnas innan den påbörjas.', 'Sänka tröskeln in på arbetsmarknaden för dem som stått utanför.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', 'bc90a2ca-11c9-4323-aa09-faa7cc1c84c1', 'd4bf2c40-9127-4bc8-8fdc-a0011b07b0e6', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.433992+00', '2026-08-28 17:30:50.433992+00'),
	('6bf87f8c-76d8-4c69-b124-38d7bceb64a7', 'd498d63f-945c-4e31-8042-2503c6c643e6', '92f08bf5-672f-4ae3-8553-d1373721cdc7', 'af-lonebidrag', 'Arbetsförmedlingen — Lönebidrag vid nedsatt arbetsförmåga', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Lönebidrag kan lämnas till arbetsgivare som anställer (eller behåller) en person vars arbetsförmåga är nedsatt av funktionsnedsättning eller ohälsa. Bidraget kompenserar en del av lönekostnaden och kan kombineras med anpassning av arbetet; det finns i flera former (utveckling, trygghet, anställning). Nivå och längd bedöms individuellt av Arbetsförmedlingen.', 'Göra det möjligt att anställa utifrån förmåga, inte hinder.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '0216d1c7-3254-4338-8774-3ae8313224d3', 'd4bf2c40-9127-4bc8-8fdc-a0011b07b0e6', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 17:30:50.439435+00', '2026-08-28 17:30:50.439435+00');


--
-- Data for Name: funding_programmes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_programmes VALUES
	('1b27aff5-a92b-4948-8b6c-fd29de2c6513', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'Internationellt kulturutbyte', '', '2026-08-28 17:30:49.83176+00'),
	('0528fb15-e5c7-44af-a7b2-17556d692840', '30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', 'Erasmus+ Ungdom', '', '2026-08-28 17:30:49.843241+00'),
	('f456381c-77d4-4752-ac45-94bed246d89a', '7928f3e1-b535-4c3d-99b0-9cbc9805b656', 'Bidrag till civilsamhället', '', '2026-08-28 17:30:49.851317+00'),
	('2ef4b0e6-e8ac-40df-a7f2-d0df978fe91c', '6840ca04-5bfd-46f1-9bfa-d57c6467c78a', 'Innovativa startups', '', '2026-08-28 17:30:49.859386+00'),
	('1064fd51-8201-49e0-b77b-573d3c5be99b', '2f5700a6-91a9-46b3-bb82-d965d9a3e82d', 'Forskning och innovation för energiomställning', '', '2026-08-28 17:30:49.867914+00'),
	('4474cc0c-333e-4f45-80ab-909ba27060e5', 'e1c00ee3-8b20-43ce-b545-aa4c17aaf605', 'Klimatinvesteringar', '', '2026-08-28 17:30:49.876044+00'),
	('e0eda88d-fa79-48be-98de-3a71896e2dc8', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'Musik', '', '2026-08-28 17:30:49.886549+00'),
	('07d6b4c5-582d-4a12-bea5-7cab934e5c34', 'ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', 'Internationellt kulturutbyte', '', '2026-08-28 17:30:49.894101+00'),
	('4e4cdefb-e351-4684-81e9-42c8a91f8956', 'ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', 'Arbetsstipendier', '', '2026-08-28 17:30:49.901753+00'),
	('8d3b2a59-90ff-424e-92c1-b04b1a0f8ebb', '6cd09f95-6db4-428c-9762-a9fefa9f43d4', 'Projektstöd', '', '2026-08-28 17:30:49.91056+00'),
	('ee08b244-3e40-43d6-ae0f-ecef83df55f3', '2e0d9f8b-ded0-4c94-a96c-ecef9738046f', 'Stöd till allmänna samlingslokaler', '', '2026-08-28 17:30:49.918758+00'),
	('c7c167ac-8094-44f1-80bf-a44c78d36812', '35767ea0-a4ba-4393-8c5e-d99847961c0d', 'LOK-stöd', '', '2026-08-28 17:30:49.92705+00'),
	('0680d0b5-c7bf-4483-8301-2f35cc1a61d2', 'f3c3ea5c-003e-4cf1-a5b0-9503b74505ef', 'Produktionsstöd', '', '2026-08-28 17:30:49.934344+00'),
	('d6adb7f1-9b55-4c08-8dfb-dbc48f577aef', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'Skapande skola', '', '2026-08-28 17:30:49.941585+00'),
	('7a7c0b83-11c7-448d-a4d8-8b037bfcfc68', '51b7ef66-675d-413d-864e-5f78eb822716', 'Årliga öppna utlysningen', '', '2026-08-28 17:30:49.949386+00'),
	('9ff34818-4616-44c1-83d5-a4e4cdab3846', 'defe9be7-89f2-4f33-8337-76d282f7a1c5', 'Affärsutvecklingscheckar', '', '2026-08-28 17:30:49.960096+00'),
	('2c7c3acd-f0c2-401c-b55b-e601e86e0337', 'b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', 'Startstöd', '', '2026-08-28 17:30:49.968292+00'),
	('efa93a28-9a16-482f-8f95-017a7d0db158', 'b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', 'Investeringsstöd', '', '2026-08-28 17:30:49.976133+00'),
	('d617557d-37f8-492c-8af6-87bafb642a25', '3d5fd611-e20b-4cf8-bfe4-2f8553d8a84e', 'ESF+', '', '2026-08-28 17:30:49.983279+00'),
	('8bacbd28-ae65-4120-b49e-1d26946ff1eb', '2f5700a6-91a9-46b3-bb82-d965d9a3e82d', 'Industriklivet', '', '2026-08-28 17:30:49.990339+00'),
	('fbef7a25-1d78-4297-8ac4-d0974f802187', 'e1c00ee3-8b20-43ce-b545-aa4c17aaf605', 'Klimatklivet', '', '2026-08-28 17:30:49.997586+00'),
	('dedba60e-f7b4-477c-b395-cb7cb6915a1d', 'e1c00ee3-8b20-43ce-b545-aa4c17aaf605', 'LONA', '', '2026-08-28 17:30:50.00598+00'),
	('2fbfc88f-3226-44f5-8dc8-f761e9a9f198', '7928f3e1-b535-4c3d-99b0-9cbc9805b656', 'Europeiska solidaritetskåren', '', '2026-08-28 17:30:50.013773+00'),
	('bbd52deb-b5ba-4d21-87e7-9e589ce27882', 'ab667f93-6e24-4b35-92e3-9eaeba7015f4', 'Erasmus+ Utbildning', '', '2026-08-28 17:30:50.021349+00'),
	('b743b4b1-2831-4acf-81e9-4666513ed6cc', '30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', 'Kreativa Europa', '', '2026-08-28 17:30:50.027515+00'),
	('dd8b605b-b3c8-4c15-ad09-6d32a6ad95cb', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'Scenkonst', '', '2026-08-28 17:30:50.033892+00'),
	('d1194e87-3d05-4778-b6c0-37b7cfc98abb', '6840ca04-5bfd-46f1-9bfa-d57c6467c78a', 'EU-relaterade stöd', '', '2026-08-28 17:30:50.040331+00'),
	('4cf03cce-aa7a-4e44-b534-107179852e47', '7928f3e1-b535-4c3d-99b0-9cbc9805b656', 'Statsbidrag till civilsamhället', '', '2026-08-28 17:30:50.047194+00'),
	('f1a74dc3-f423-49e7-b849-9dd6824843f3', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Bostadsbidrag', '', '2026-08-28 17:30:50.054327+00'),
	('daf0e009-60a8-466c-a267-a6337f1fc836', 'fa5dfa8b-3f48-4480-933d-456a4159612b', 'Glasögonbidrag', '', '2026-08-28 17:30:50.062236+00'),
	('1f18e054-f6ed-4cdd-8a61-28ac02236255', 'c0fa4105-8057-42fc-a46b-2200f2a6eb33', 'Majblommans bidrag', '', '2026-08-28 17:30:50.070224+00'),
	('f33a3934-cfdc-4e5c-b209-b3b1923554b4', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'Skolskjuts', '', '2026-08-28 17:30:50.078074+00'),
	('e7160993-7fbb-400a-b5cf-269acee1dd79', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'Elevresor', '', '2026-08-28 17:30:50.085214+00'),
	('6fa8d0d6-98c6-40af-9d78-643820e8b2dd', 'e61f7274-52de-4471-83ae-cc934b981d89', 'Ekonomiskt bistånd', '', '2026-08-28 17:30:50.098096+00'),
	('a59dcf28-938b-4358-93eb-10d3d4804d06', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'Studiemedel', '', '2026-08-28 17:30:50.105634+00'),
	('836ed04e-90fa-421f-9f26-68ef8b7af778', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Sjuk- och aktivitetsersättning', '', '2026-08-28 17:30:50.112468+00'),
	('54065071-e746-406a-9436-c69bbf7ed11d', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Stöd till barnfamiljer', '', '2026-08-28 17:30:50.120517+00'),
	('f9313d49-13df-4e8e-8904-19aa452628b0', 'f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', 'Bostadstillägg', '', '2026-08-28 17:30:50.127773+00'),
	('a65ee484-2ca4-47f5-a9bc-6196e9ad51c2', 'f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', 'Äldreförsörjningsstöd', '', '2026-08-28 17:30:50.133945+00'),
	('8db1e2e9-62f8-4c8c-93e5-8f63ecc7e94d', 'd498d63f-945c-4e31-8042-2503c6c643e6', 'Arbetsmarknadsprogram', '', '2026-08-28 17:30:50.140852+00'),
	('87219366-c48c-426c-a7f2-128dc516d7ec', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'Omställningsstudiestöd', '', '2026-08-28 17:30:50.147614+00'),
	('84babba5-f9de-474d-a506-f48128560b1c', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'Bostadsanpassning', '', '2026-08-28 17:30:50.155089+00'),
	('131b4080-7ad2-4c15-ba0e-473bdcad3f45', 'ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', 'Kulturbryggan', '', '2026-08-28 17:30:50.163266+00'),
	('f180e5fc-f9a6-445d-bebd-f621fb682b1d', '44ccc9f1-b4bf-4333-9623-e15c456e32d5', 'Bidrag till kulturarvsarbete', '', '2026-08-28 17:30:50.170648+00'),
	('e33ed590-423a-419e-b1e1-977add659a19', '91a8f2a5-5cea-4289-8886-257ce35181c5', 'Creative Force', '', '2026-08-28 17:30:50.177288+00'),
	('9d4862d4-57df-45b0-8339-75fd5d5027ba', 'd012d319-6538-4150-90f1-c8a7b82a28f8', 'Projektstöd', '', '2026-08-28 17:30:50.184705+00'),
	('b41a7c10-1e28-4eae-a587-33814301c5a6', '2c787c76-4737-49c9-b8b4-63bc29e78dfb', 'Projektbidrag', '', '2026-08-28 17:30:50.19123+00'),
	('a7cbd2b2-86aa-4e7b-b820-876672883183', 'e30c7a25-122b-43bc-bced-3009439fbd97', 'Projektstöd', '', '2026-08-28 17:30:50.199146+00'),
	('4e7a2e24-6c95-461c-b19c-65e097074872', '7567c42c-d5fb-441f-a833-5c4f9f60019a', 'Musiksamarbeten', '', '2026-08-28 17:30:50.206172+00'),
	('311f1e01-c92a-468a-854d-2e920378f509', '30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', 'Erasmus+ Partnerskap', '', '2026-08-28 17:30:50.211845+00');
INSERT INTO public.funding_programmes VALUES
	('6b04e498-0db9-4e0a-ae84-3e2a1e4508cc', 'defe9be7-89f2-4f33-8337-76d282f7a1c5', 'Regionala företagsstöd', '', '2026-08-28 17:30:50.21879+00'),
	('950ab058-67e8-476a-9424-010443b14808', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'Litteratur och bibliotek', '', '2026-08-28 17:30:50.226599+00'),
	('8e256f73-bb08-492e-b98e-67b2b6036a58', 'c9ab513b-a69e-47e2-b855-acc8c910e74f', 'Bygdemedel', '', '2026-08-28 17:30:50.239012+00'),
	('136f10a7-e1f6-48a0-8006-f03acb450a05', '5ec8e845-3c3f-497b-8ae4-34245b3d8fae', 'Frivillig återvandring', '', '2026-08-28 17:30:50.247368+00'),
	('80762b86-2ed1-45b7-b56a-c8620b9a272c', 'd498d63f-945c-4e31-8042-2503c6c643e6', 'EURES', '', '2026-08-28 17:30:50.255797+00'),
	('f0ee96d9-318a-4597-9670-3bbb2798b584', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Omvårdnadsbidrag', '', '2026-08-28 17:30:50.26886+00'),
	('229f65cb-c573-413f-bb7e-8fab0db2fdc7', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Merkostnadsersättning', '', '2026-08-28 17:30:50.277132+00'),
	('c2f6e968-dab8-4a36-a564-9f2d95ab991a', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Bilstöd', '', '2026-08-28 17:30:50.283258+00'),
	('19bea494-a278-49ca-9af5-ab9beb8c02f1', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Närståendepenning', '', '2026-08-28 17:30:50.289341+00'),
	('1e00c578-56f9-438a-9bdb-ff57c56f6323', 'd498d63f-945c-4e31-8042-2503c6c643e6', 'Etableringsprogrammet', '', '2026-08-28 17:30:50.296039+00'),
	('9b71c694-2946-499d-9083-27634a9a13de', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'Hemutrustningslån', '', '2026-08-28 17:30:50.302342+00'),
	('a5679c04-40f3-44b1-b52a-b8fb3fcb3a17', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'Studiestartsstöd', '', '2026-08-28 17:30:50.310088+00'),
	('b28d2c92-5aa4-454b-bb6e-27054c92fb16', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'Inackorderingstillägg', '', '2026-08-28 17:30:50.316541+00'),
	('270c6fe3-cacf-4dd2-907f-3d51da5bbe68', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'Föreningsbidrag', '', '2026-08-28 17:30:50.326987+00'),
	('3adb99b6-3170-46f5-bb01-6dbd81c0d466', 'fa5dfa8b-3f48-4480-933d-456a4159612b', 'Regionalt kulturstöd', '', '2026-08-28 17:30:50.334409+00'),
	('efe2dd5d-4330-4583-80ea-d4999355ed02', 'ba1278ad-4f74-44c5-8851-f51fd092f029', 'Projektstöd', '', '2026-08-28 17:30:50.340684+00'),
	('14f69cfc-8c24-40c1-a79e-340a70ce88a7', 'b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', 'Leader — lokalt ledd utveckling', '', '2026-08-28 17:30:50.34737+00'),
	('2da528c3-6331-4d68-a523-6006a6d16644', '8b2c3f3b-ef6f-415a-a343-0a72393107a6', 'Projektbidrag', '', '2026-08-28 17:30:50.353736+00'),
	('5863445d-cf1e-4527-955f-3d83bafbf22a', '06c449c3-980c-4486-a438-c8f040513700', 'Projektbidrag', '', '2026-08-28 17:30:50.360142+00'),
	('9074d696-9a21-4809-a2b4-4c2afcb4c8ab', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Vid sjukdom', '', '2026-08-28 17:30:50.388101+00'),
	('92edf2a6-ebee-4aa6-a5cf-7704b65c3ec7', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Vid arbetslöshet', '', '2026-08-28 17:30:50.399929+00'),
	('f9bce642-3c37-4a9d-af5c-42e7a8c4f566', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Tandvårdsstöd', '', '2026-08-28 17:30:50.406379+00'),
	('59ca1bca-357b-4690-a829-a41d9f76c41c', 'f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', 'Grundskydd för pensionärer', '', '2026-08-28 17:30:50.413429+00'),
	('c92793ff-331d-4be7-920a-08e01c000647', 'fa5dfa8b-3f48-4480-933d-456a4159612b', 'Patientavgifter', '', '2026-08-28 17:30:50.419966+00'),
	('e8ebe0bc-d9b0-4817-b265-7f687c9f1517', '37e1245f-98d1-4063-be5f-c27054c5f82a', 'Arbetslöshetsförsäkringen', '', '2026-08-28 17:30:50.426435+00'),
	('92f08bf5-672f-4ae3-8553-d1373721cdc7', 'd498d63f-945c-4e31-8042-2503c6c643e6', 'Anställningsstöd', '', '2026-08-28 17:30:50.432374+00');


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
	('0e739a55-d090-4c27-9d4f-39e2c055987e', 'en', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Activity support for sports clubs running leader-led activities for children and young people aged 7–25.', '2026-08-28 17:30:50.579789+00'),
	('0fff2401-caa4-4ee5-adbf-2901b391814c', 'en', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'An automatic supplement to the child allowance (barnbidrag) from the second child onwards.', '2026-08-28 17:30:50.579789+00'),
	('d7387dca-3a81-4d7a-bbb9-c5a0867940f4', 'en', 'Avser ansökan en fysisk investering?', 'Does the application concern a physical investment?', '2026-08-28 17:30:50.579789+00'),
	('8d3a4345-eb15-4619-b30b-3161371315a0', 'en', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Does the application concern an international trip or exchange?', '2026-08-28 17:30:50.579789+00'),
	('96346e6c-9ec4-4d1b-8327-80dd12da050a', 'en', 'Avser ansökan en investering i byggnader eller maskiner?', 'Does the application concern an investment in buildings or machinery?', '2026-08-28 17:30:50.579789+00'),
	('4ec67bfd-ea6f-4c75-a0a5-d17a3e12628e', 'en', 'Avser ansökan en redan utgiven titel?', 'Does the application concern an already published title?', '2026-08-28 17:30:50.579789+00'),
	('7081350a-0a4d-4ed9-aa0c-7a7daa252402', 'en', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Does the application concern an agricultural, horticultural or reindeer husbandry business?', '2026-08-28 17:30:50.579789+00'),
	('e3a6db13-59f3-4e9c-94f6-caeec619616f', 'en', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Does the application concern purchasing literature for public or school libraries?', '2026-08-28 17:30:50.579789+00'),
	('1fce1d67-3735-46ce-8979-efbda114fb38', 'en', 'Avser investeringen jordbruksverksamhet?', 'Does the investment concern agricultural activities?', '2026-08-28 17:30:50.579789+00'),
	('400e9446-e9ca-4732-bf25-ba46c9ca3534', 'en', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Does the project involve building, buying or renovating premises?', '2026-08-28 17:30:50.579789+00'),
	('5add2f4a-b62c-44e0-bb2c-3b3c1e4e521b', 'en', 'Avser projektet naturvård eller friluftsliv?', 'Does the project concern nature conservation or outdoor recreation?', '2026-08-28 17:30:50.579789+00'),
	('31e85bfa-eacd-45ba-ade2-aae7f23a4d85', 'en', 'Avser projektet skola eller vuxenutbildning?', 'Does the project concern school or adult education?', '2026-08-28 17:30:50.579789+00'),
	('d2517279-93fb-4190-b1dc-0e031f4685c5', 'en', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Are you refraining from work to care for or be close to a relative who is so seriously ill that the illness is a threat to their life?', '2026-08-28 17:30:50.579789+00'),
	('c2ad5165-1d10-4466-a25f-28688543f588', 'en', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Does the association run regular activities in the municipality?', '2026-08-28 17:30:50.579789+00'),
	('814eacfb-f7d8-448c-a18d-612dedd5354e', 'en', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Do you consider your ability to work to be reduced for at least a year due to illness or disability?', '2026-08-28 17:30:50.579789+00'),
	('8cabc0d4-10ed-4d9c-8e82-2a684c6ede9e', 'en', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Means-tested support for you who have a low pension or none and need help reaching a reasonable standard of living.', '2026-08-28 17:30:50.579789+00'),
	('9c73ee71-12d4-4a85-8164-79c4f041f04a', 'en', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Does the child need to live in the town of study (lodging) because the journey is too long?', '2026-08-28 17:30:50.579789+00'),
	('06a5cbf5-ab65-4a3d-9d6d-8901f731fa96', 'en', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Does the home need to be adapted (e.g. a ramp, door opener, bathroom)?', '2026-08-28 17:30:50.579789+00'),
	('858ed8c1-4d17-481d-aef6-27af9a07e50e', 'en', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Does any of your children aged 8–19 need glasses or contact lenses?', '2026-08-28 17:30:50.579789+00'),
	('720606f3-1be6-4842-a899-efb25de940db', 'en', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Does the other parent pay nothing, or less than full maintenance?', '2026-08-28 17:30:50.579789+00'),
	('a5f5db28-dde3-412c-97e0-9ecaf675c2de', 'en', 'Betalar du hyra eller andra boendekostnader?', 'Do you pay rent or other housing costs?', '2026-08-28 17:30:50.579789+00'),
	('ac201786-298f-466c-9740-c3b52ee4e2b7', 'en', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'A grant for adapting your home in case of disability — e.g. ramps, door openers or bathroom adaptations.', '2026-08-28 17:30:50.579789+00'),
	('1489cbb6-351d-41ac-91d4-b0ad86ec1631', 'en', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Grants for building, buying or renovating public assembly halls.', '2026-08-28 17:30:50.579789+00'),
	('d23d4328-f544-4441-af23-8e2a1b3e1a30', 'en', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'A grant for buying or adapting a car when a lasting disability makes it very difficult to get around or travel by public transport.', '2026-08-28 17:30:50.579789+00'),
	('17a8e50e-3e43-4207-ae32-1472efb47b6c', 'en', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Grants for international travel and exchanges for professionals in the cultural sector.', '2026-08-28 17:30:50.579789+00'),
	('41c6654f-7ba9-48d9-b4e8-407842f735fa', 'en', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Grants for professional artists'' international exchanges, travel and working stays.', '2026-08-28 17:30:50.579789+00'),
	('ce33ee5c-1257-45aa-bf20-447b167c4673', 'en', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'A grant and optional loan for studies at upper secondary or post-secondary level.', '2026-08-28 17:30:50.579789+00'),
	('c45a41b3-63ac-45db-b7e1-6d15479465be', 'en', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Grants and loans for studies abroad, with extra supplementary loans for e.g. tuition fees and travel.', '2026-08-28 17:30:50.579789+00'),
	('923ba0e5-5d68-449c-af2b-1ff5751146e5', 'en', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'A grant that helps Swedish actors prepare applications for EU programmes such as Horisont Europa.', '2026-08-28 17:30:50.579789+00'),
	('b4b584f4-f0e4-4757-aa2f-16a84162de25', 'en', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'A grant for employers who hire people with reduced work capacity.', '2026-08-28 17:30:50.579789+00'),
	('e02bfb8b-d5ad-488e-907d-58cd8b1a98d1', 'en', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'A grant towards lodging and journeys home when an upper secondary pupil has to live in the town of study because of a long journey.', '2026-08-28 17:30:50.579789+00'),
	('58b79ed7-d422-4229-986b-a4e3ded0c2ae', 'en', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Grants for non-profit organisations'' work to preserve, use and develop cultural heritage.', '2026-08-28 17:30:50.579789+00'),
	('690c6c9a-4273-4394-b28b-b338e0724563', 'en', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Grants for municipal and local nature conservation projects, including wetlands and outdoor recreation.', '2026-08-28 17:30:50.579789+00'),
	('acb75cfb-975d-4dd9-92b2-c70054189e48', 'en', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Grants to municipalities for purchasing literature for public and school libraries.', '2026-08-28 17:30:50.579789+00'),
	('adc2a93e-4cde-4324-be98-af14ebd5775d', 'en', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Grants to school authorities for pupils'' encounters with professional culture in compulsory school.', '2026-08-28 17:30:50.579789+00'),
	('115c7e30-60ee-45fd-a7a8-f00ce2e1b45d', 'en', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'EU social fund money for projects that strengthen skills, transition and inclusion in the labour market.', '2026-08-28 17:30:50.579789+00'),
	('0711aabd-217c-430a-898d-a2d9847e2e2f', 'en', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Grants for things your child needs but the family finances cannot cover: leisure activities, clothes, school outings, glasses, holiday activities and more.', '2026-08-28 17:30:50.579789+00'),
	('a8bbb7c7-2d75-4818-ba22-870b79ae9748', 'en', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Grants from funds such as Världens Barn, Musikhjälpen and Victoriafonden — applied for by Swedish non-profit organisations with a 90-konto.', '2026-08-28 17:30:50.579789+00'),
	('7ff7856d-9674-4066-aa71-baa9d40d6d7a', 'en', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Grants from hydropower and wind power funds for projects that develop the local community.', '2026-08-28 17:30:50.579789+00'),
	('a89f1f95-6229-4f0f-9993-6b6ceac2032f', 'en', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'A grant with no loan component for unemployed people aged 25–60 with short previous education who need to study at compulsory or upper secondary level.', '2026-08-28 17:30:50.579789+00'),
	('288604dc-f991-47bb-99e3-0497cdc29a27', 'en', 'Bidrar projektet till energiomställningen?', 'Does the project contribute to the energy transition?', '2026-08-28 17:30:50.579789+00'),
	('2d4cbe7b-ea5d-4d35-83fa-d617be8d99aa', 'en', 'Bor du och barnets andra förälder på skilda håll?', 'Do you and the child''s other parent live apart?', '2026-08-28 17:30:50.579789+00'),
	('103003fd-ea6d-4711-8aa7-5f31c4647afd', 'en', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Vouchers for small companies to bring in external expertise for internationalisation or digitalisation.', '2026-08-28 17:30:50.579789+00'),
	('a41c30ac-105d-4a65-8135-18e803438630', 'en', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Are you taking part in a programme at Arbetsförmedlingen (e.g. jobb- och utvecklingsgarantin)?', '2026-08-28 17:30:50.579789+00'),
	('ecd22ec5-2c9c-4f16-97b6-3ee627aaf935', 'en', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Retrospective support to publishers for publishing quality literature.', '2026-08-28 17:30:50.579789+00'),
	('d4c6326c-899d-4f20-97c7-329738965dc8', 'en', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Financial support for those with a protection-related residence permit who voluntarily want to move back to their country of origin permanently.', '2026-08-28 17:30:50.579789+00'),
	('b016767d-3f5a-4a00-a162-39f0deb98146', 'en', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Financial support for employers who hire someone who has been away from working life for a long time.', '2026-08-28 17:30:50.579789+00'),
	('aefc00e2-d4b0-4e8b-ba3d-70de09ced8c2', 'en', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Financial support during the start-up phase for jobseekers starting their own business.', '2026-08-28 17:30:50.579789+00'),
	('5cbf1be7-20a6-4ef3-920a-f5efaf338bb6', 'en', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten continuously opens calls within energy research, innovation and energy efficiency.', '2026-08-28 17:30:50.579789+00'),
	('bf8c1fc1-b606-4b7e-810e-c0fc7d43d96d', 'en', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Compensation for taking time off work or studies to care for a child.', '2026-08-28 17:30:50.579789+00');
INSERT INTO public.kb_translations VALUES
	('7bb2f46c-dcd1-4b12-bb84-c68e918dacd3', 'en', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Compensation for those who are new in Sweden and take part in the establishment programme at Arbetsförmedlingen; paid out by Försäkringskassan.', '2026-08-28 17:30:50.579789+00'),
	('224753c9-8baf-4dec-b1bc-f24431c54888', 'en', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Compensation for part of the housing cost for young people without children on low incomes.', '2026-08-28 17:30:50.579789+00'),
	('bb3074fd-4c20-4552-bf34-d581200d36eb', 'en', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Compensation for the extra costs that a lasting disability brings — for adults, or for parents of children with disabilities.', '2026-08-28 17:30:50.579789+00'),
	('706ec8bf-497d-408e-be56-b910f38e0ab1', 'en', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Compensation for young people (19–29) who cannot work full-time for at least a year due to illness or disability.', '2026-08-28 17:30:50.579789+00'),
	('b709a056-1285-40a3-8a61-6d187c12ac61', 'en', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Compensation when your ability to work is permanently reduced — previously known as förtidspension (early retirement pension).', '2026-08-28 17:30:50.579789+00'),
	('a19fad15-6e29-493b-829e-9b4966cc4698', 'en', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Compensation when you refrain from work to be close to a seriously ill relative.', '2026-08-28 17:30:50.579789+00'),
	('3bfce9ad-b151-4f18-a1df-38160d27ec01', 'en', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Compensation when you take part in a labour market programme at Arbetsförmedlingen.', '2026-08-28 17:30:50.579789+00'),
	('0ef1316f-19c2-4ef9-9c5d-68ac9b67d642', 'en', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Compensation when you cannot work as usual due to illness.', '2026-08-28 17:30:50.579789+00'),
	('2466b8da-d9da-4c43-94c2-6279faad3232', 'en', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Compensation when you stay home from work to care for a sick child.', '2026-08-28 17:30:50.579789+00'),
	('94c30002-d08f-4a94-8099-8f319808a930', 'en', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Compensation covering part of the housing cost for households with children and lower incomes.', '2026-08-28 17:30:50.579789+00'),
	('43898e4c-5a65-42b1-9d69-07a71b07eeb5', 'en', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Compensation for parents whose children, due to disability, need more care and supervision than children of the same age.', '2026-08-28 17:30:50.579789+00'),
	('e6b37259-8607-43d9-8b23-807fea7a1c93', 'en', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Compensation during unemployment — income-based for members, a basic amount for others.', '2026-08-28 17:30:50.579789+00'),
	('0c754ba4-1941-4642-bd0d-a564fa9ed2f0', 'en', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Some fifty savings bank foundations award grants to local projects in sports, culture, education and community development — within the savings bank''s area of operation.', '2026-08-28 17:30:50.579789+00'),
	('5dc59473-8759-48f8-a064-585582bf7cb3', 'en', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'EU-funded project support applied for through your local Leader area — for associations, companies and municipalities developing rural areas.', '2026-08-28 17:30:50.579789+00'),
	('178287db-7993-4d5e-829d-8ec9262af48a', 'en', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU-funded support for jobseekers taking a job in another EU/EEA country: compensation for interview travel, moving costs and language courses.', '2026-08-28 17:30:50.579789+00'),
	('71ab3d49-dbfa-4524-8c3e-2c1aafbd0990', 'en', 'Är volontärerna mellan 18 och 30 år?', 'Are the volunteers between 18 and 30 years old?', '2026-08-28 17:30:50.583972+00'),
	('e7273aa9-73d9-4904-88c5-06bc462bed78', 'en', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'EU support for group exchanges for young people aged 13–30, lasting 5–21 days excluding travel days.', '2026-08-28 17:30:50.579789+00'),
	('caa2991f-7cfb-4cff-9d87-76c37f2a5d02', 'en', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'EU support for cultural organisations'' cooperation projects with partners in several European countries.', '2026-08-28 17:30:50.579789+00'),
	('544adc8a-ecd6-47e4-9492-f6eac6b3698f', 'en', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'EU support for organisations receiving or sending young volunteers aged 18–30.', '2026-08-28 17:30:50.579789+00'),
	('841962bc-4658-46ab-8f9a-89fe43680386', 'en', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'EU support for staff and pupil mobility in schools and adult education.', '2026-08-28 17:30:50.579789+00'),
	('fcf2beec-fe64-417f-8cce-fb81e8ca8c2b', 'en', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'EU support with lump sums for smaller organisations'' first European cooperation projects.', '2026-08-28 17:30:50.579789+00'),
	('47950e91-d155-43b8-ad21-0fdadb23bf44', 'en', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Funding for young companies developing innovative products or services with international potential.', '2026-08-28 17:30:50.579789+00'),
	('cfae1a36-6f4f-404b-b36d-cc7f42fa4544', 'en', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Is there a savings bank (and thus a savings bank foundation) where you operate?', '2026-08-28 17:30:50.579789+00'),
	('b424b579-6763-4466-907d-703b8f6a9041', 'en', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Multi-year operating grants for professional independent groups in dance, theatre and musical theatre.', '2026-08-28 17:30:50.579789+00'),
	('dca1024e-63be-41c2-a95d-aab400ce456e', 'en', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Research grants within Forte''s areas of responsibility: health, working life and welfare. Applied for by researchers with a doctorate at Swedish higher education institutions.', '2026-08-28 17:30:50.579789+00'),
	('c1b3da55-a30d-4be9-ba99-69e2a6a34dab', 'en', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Research funding for free basic research in all scientific fields.', '2026-08-28 17:30:50.579789+00'),
	('c8bcd46e-a2af-4afe-b064-78cb02f1dcd5', 'en', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Research funding within the environment, agricultural sciences and spatial planning.', '2026-08-28 17:30:50.579789+00'),
	('e3806450-b759-4a67-ad5a-760ec02ba919', 'en', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Are you thinking about moving abroad (for work, studies or return migration)?', '2026-08-28 17:30:50.579789+00'),
	('7cf1f02c-d707-4925-931c-524141d5f2b5', 'en', 'Genomförs insatserna av professionella kulturaktörer?', 'Are the activities carried out by professional cultural actors?', '2026-08-28 17:30:50.579789+00'),
	('c9e2364d-9e95-493d-8038-07d918c2155b', 'en', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Is the project carried out in a rural area or a smaller town?', '2026-08-28 17:30:50.579789+00'),
	('cfe83267-47c2-4a31-88b8-4414751c8610', 'en', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Basic protection for those who have had little or no earned income during their life.', '2026-08-28 17:30:50.579789+00'),
	('59cd21b8-3ffa-4072-a7e4-ead30febfec8', 'en', 'Går något av dina barn i grundskolan?', 'Is any of your children in compulsory school?', '2026-08-28 17:30:50.579789+00'),
	('a35c1f6c-b117-4505-abee-530ce6fc3ee8', 'en', 'Går något av dina barn på gymnasiet?', 'Is any of your children in upper secondary school?', '2026-08-28 17:30:50.579789+00'),
	('4a079d64-7b70-4475-9753-f3159c4f51db', 'en', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Does the employment concern a person with reduced work capacity?', '2026-08-28 17:30:50.579789+00'),
	('0081dafb-6236-4702-901f-4a3688e19dcc', 'en', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Does the employment concern someone who has been unemployed for a long time or is new in Sweden?', '2026-08-28 17:30:50.579789+00'),
	('7247a54d-9600-40d2-b66b-ca9affa18417', 'en', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Is the project about preserving or making cultural heritage accessible?', '2026-08-28 17:30:50.579789+00'),
	('9bb8f8d4-3728-4b50-8f76-ebd15e545c6d', 'en', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Is the project about energy, energy efficiency or energy-related innovation?', '2026-08-28 17:30:50.579789+00'),
	('e1690b78-dbdd-4031-b357-97d7a7c6bb4f', 'en', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Is the project about health, working life or welfare?', '2026-08-28 17:30:50.579789+00'),
	('7b39fc65-366b-4fe1-b1d1-1d89dd23c29f', 'en', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Is the project about skills development or labour market measures?', '2026-08-28 17:30:50.579789+00'),
	('eaaf705f-ad4b-4efc-9a9a-35d5911393f2', 'en', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Is the project about environmental or climate measures?', '2026-08-28 17:30:50.579789+00'),
	('1d9252e6-538a-49d4-812d-680e99023065', 'en', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Does the child have a long, traffic-hazardous or otherwise difficult route to school?', '2026-08-28 17:30:50.579789+00'),
	('b8d14658-2a25-4fef-9556-937a1888c4fb', 'en', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Have you worked at least 16 hours a week for a total of at least 8 years?', '2026-08-28 17:30:50.579789+00'),
	('7731bf40-19dc-4c62-8fbe-644c449084ca', 'en', 'Har du barn som bor hos dig, helt eller växelvis?', 'Do you have children living with you, full-time or alternately?', '2026-08-28 17:30:50.579789+00'),
	('565d10a8-e59a-4777-b70d-44c4d71d93f6', 'en', 'Har du barn som bor hos dig?', 'Do you have children living with you?', '2026-08-28 17:30:50.579789+00'),
	('c80f1f41-a0fa-4738-bba2-ba9a6b0f02fc', 'en', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Do you or your child have a disability expected to last at least a year?', '2026-08-28 17:30:50.579789+00'),
	('e85ae78f-74a4-4285-9260-4e4cfb189006', 'en', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Do you or anyone in the household have a lasting disability that affects your housing?', '2026-08-28 17:30:50.579789+00'),
	('6d9a47ef-8a48-4017-ba3a-6b344e918c71', 'en', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Do you or a close relative have a disability or a long-term or serious illness?', '2026-08-28 17:30:50.579789+00'),
	('6f5c1518-4307-431d-80ee-a77cd74f6fb7', 'en', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Do you have an illness or injury that currently reduces your ability to work?', '2026-08-28 17:30:50.579789+00'),
	('f85c1934-f62f-4e77-9f9d-371529122dd1', 'en', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Have you ever found it hard to pay for a school outing, class trip or leisure activity your child is expected to take part in?', '2026-08-28 17:30:50.579789+00'),
	('7b339679-e800-467f-800e-32e29437b143', 'en', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Do you find it hard to manage on your pension and your other income?', '2026-08-28 17:30:50.579789+00');
INSERT INTO public.kb_translations VALUES
	('98feab3c-17ff-4e55-8191-484115b0c434', 'en', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Have you been granted a residence permit in Sweden in recent years, e.g. as a person in need of protection or as a family member?', '2026-08-28 17:30:50.579789+00'),
	('83a4797b-9ba9-4006-ae09-fd8e93056870', 'en', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Do you have a residence permit in Sweden as a refugee or person in need of protection (or are you a close family member of someone who has)?', '2026-08-28 17:30:50.579789+00'),
	('6e478908-a12d-4436-84dc-2cd513c44415', 'en', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Have you reached the target age for pension (67 in 2026)?', '2026-08-28 17:30:50.579789+00'),
	('96a20a82-260d-460e-8456-3edd67faeda4', 'en', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Does your organisation have an OID (Organisation ID) registered in the EU''s Organisation Registration System?', '2026-08-28 17:30:50.579789+00'),
	('d9d0845b-5c11-47db-9616-94de63d272a3', 'en', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Has the disability led to extra costs — e.g. aids, travel, special diet or wear and tear?', '2026-08-28 17:30:50.579789+00'),
	('200e1e7a-804c-467c-8783-a8910e5e04ac', 'en', 'Har föreningen antagna stadgar och en vald styrelse?', 'Does the association have adopted statutes and an elected board?', '2026-08-28 17:30:50.579789+00'),
	('ff6a5066-914d-4b76-a2a6-15a8c8472085', 'en', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Does the association have a democratic structure (statutes, annual meeting, board)?', '2026-08-28 17:30:50.579789+00'),
	('83619d41-f3d1-4dee-ada8-6dca7a9d5070', 'en', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Does the association run regular activities for children or young people?', '2026-08-28 17:30:50.579789+00'),
	('0df8e3a7-4db3-4804-bbb6-ad2081b9e8c8', 'en', 'Har företaget mellan cirka 2 och 49 anställda?', 'Does the company have between roughly 2 and 49 employees?', '2026-08-28 17:30:50.579789+00'),
	('7bc8571f-d62c-45e4-8420-950af4ec60c5', 'en', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Does the household struggle to cover the costs of food, housing and the bare necessities?', '2026-08-28 17:30:50.579789+00'),
	('e2a5ca59-2961-4581-82e4-d5144705932b', 'en', 'Har lösningen internationell potential?', 'Does the solution have international potential?', '2026-08-28 17:30:50.579789+00'),
	('1c0bd077-7e89-4972-a510-b96dd6a7ef6b', 'en', 'Har ni en partnergrupp i ett annat land?', 'Do you have a partner group in another country?', '2026-08-28 17:30:50.579789+00'),
	('8f73398d-e9f4-47d1-8053-0748f7608eb0', 'en', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Do you have a partner organisation in another European country?', '2026-08-28 17:30:50.579789+00'),
	('170b65a3-087b-47d6-9ad6-60b3c3024dce', 'en', 'Har ni partner i minst tre olika europeiska länder?', 'Do you have partners in at least three different European countries?', '2026-08-28 17:30:50.579789+00'),
	('8c841ff1-e3bb-4b3a-ad35-b48e0d58aafb', 'en', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Is your registered office or main activity in the region where you are applying?', '2026-08-28 17:30:50.579789+00'),
	('90c15a30-37a3-476b-ad65-238efa6a386f', 'en', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Does any of your children have a disability that means the child needs more care or supervision than other children of the same age?', '2026-08-28 17:30:50.579789+00'),
	('a96ca0ca-978c-4841-8bb0-eb5ca572038c', 'en', 'Har organisationen en demokratisk uppbyggnad?', 'Does the organisation have a democratic structure?', '2026-08-28 17:30:50.579789+00'),
	('b0801996-9e36-4b34-9e75-40a7627221fa', 'en', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Does the organisation have a Quality Label?', '2026-08-28 17:30:50.579789+00'),
	('c88599e4-b84f-4e2f-9ee0-4c4748dc8c2a', 'en', 'Har organisationen ett 90-konto?', 'Does the organisation have a 90-konto?', '2026-08-28 17:30:50.579789+00'),
	('b866ff96-1518-47b8-8786-b931b1eae3b2', 'en', 'Har organisationen ett OID (Organisation ID)?', 'Does the organisation have an OID (Organisation ID)?', '2026-08-28 17:30:50.579789+00'),
	('831e4361-f449-4ecd-a8bb-f2a143b55a6a', 'en', 'Har organisationen ett OID?', 'Does the organisation have an OID?', '2026-08-28 17:30:50.579789+00'),
	('50396ce4-ae44-475a-b400-17c7f9638231', 'en', 'Har organisationen medlemsföreningar i flera län?', 'Does the organisation have member associations in several counties?', '2026-08-28 17:30:50.579789+00'),
	('83412a49-86d7-4128-bd23-7c13e71f7a45', 'en', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Does the organisation have sound finances and a democratic structure?', '2026-08-28 17:30:50.579789+00'),
	('40bea520-d536-4658-a1ae-810f8aadd24e', 'en', 'Har projektet en partner i ett annat land?', 'Does the project have a partner in another country?', '2026-08-28 17:30:50.579789+00'),
	('e0929ca1-e3e7-47ba-a155-06a63d0ea928', 'en', 'Har projektledaren doktorsexamen?', 'Does the project leader have a doctoral degree?', '2026-08-28 17:30:50.579789+00'),
	('e6a15d64-6bef-4318-8e52-142075f3dbcd', 'en', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Your home municipality must provide daily travel between home and upper secondary school when the route is at least six kilometres (e.g. a bus pass).', '2026-08-28 17:30:50.579789+00'),
	('82fea4f8-4c85-4801-abf2-89a7b424bd3a', 'en', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Are you in the process of getting or equipping your first own home in Sweden?', '2026-08-28 17:30:50.579789+00'),
	('40cf62f9-682a-4c4f-831b-c8c315edc665', 'en', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Does the project include an international trip or exchange?', '2026-08-28 17:30:50.579789+00'),
	('20a968ca-7893-42ef-9750-cd577f840130', 'en', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Investment support for companies in designated support areas, for buildings, machinery and training.', '2026-08-28 17:30:50.579789+00'),
	('feaa0766-9926-45fa-b383-f198a30c3f2b', 'en', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Investment support for measures that reduce greenhouse gas emissions.', '2026-08-28 17:30:50.579789+00'),
	('c599a006-63a1-4309-b73a-d62633674763', 'en', 'Kan projektets miljönytta mätas?', 'Can the project''s environmental benefit be measured?', '2026-08-28 17:30:50.579789+00'),
	('ad2c9287-f41e-4615-b80e-ddfd438f3b59', 'en', 'Kan åtgärdens utsläppsminskning beräknas?', 'Can the measure''s emission reduction be calculated?', '2026-08-28 17:30:50.579789+00'),
	('fb811980-99b8-4695-bb23-72e184fed880', 'en', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Can the organisation carry the costs until the support is paid out?', '2026-08-28 17:30:50.579789+00'),
	('60cda7a9-e6b3-4f09-9440-58cfb0b77eea', 'en', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Will the experience be used in your activities in Sweden?', '2026-08-28 17:30:50.579789+00'),
	('2da89146-cf91-4a8e-958e-60e7a1c392bb', 'en', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Will the investment start only after you have submitted the application?', '2026-08-28 17:30:50.579789+00'),
	('b12b113c-f504-4f63-b9ca-14a2447492d6', 'en', 'Kommer projektet människor i ert närområde till del?', 'Does the project benefit people in your local area?', '2026-08-28 17:30:50.579789+00'),
	('a8f6d489-f006-462e-b715-794b7cd3fb87', 'en', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'The municipality''s last financial safety net when income does not cover the bare necessities.', '2026-08-28 17:30:50.579789+00'),
	('d7dfa64d-1a0f-459b-9b30-db5baba2d774', 'en', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'The municipalities'' own support for the local association scene: activity support per session, premises grants, start-up grants and more.', '2026-08-28 17:30:50.579789+00'),
	('86b503c5-0162-4fe2-9496-c37b319448dc', 'en', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Free school transport for compulsory school pupils in case of long distance, traffic-hazardous routes or disability — a right under the Education Act.', '2026-08-28 17:30:50.579789+00'),
	('360896a3-80e4-4b81-9d54-95b45cf648a9', 'en', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'A statutory grant towards glasses or contact lenses for children and young people; amounts and routines vary by region — check your region''s level.', '2026-08-28 17:30:50.579789+00'),
	('505f49d2-7f4a-44bc-b840-e16be3100317', 'en', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Is the project located in an area affected by hydropower or wind power?', '2026-08-28 17:30:50.579789+00'),
	('d2bd90fa-5491-4d84-9cd7-8598658855d9', 'en', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Is the project within the environment, agricultural sciences or spatial planning?', '2026-08-28 17:30:50.579789+00'),
	('ef7c2d67-cfa7-40e3-91d3-47bab02032d4', 'en', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Is your place of business in support area A or B (large parts of Norrland and inner Svealand)?', '2026-08-28 17:30:50.579789+00'),
	('a16d69ad-ff71-4db8-98f7-cd027db75e64', 'en', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'A loan for buying the essentials for a first home in Sweden — furniture, household goods and other basic equipment.', '2026-08-28 17:30:50.579789+00'),
	('4173a8c8-efa3-4d14-9f66-019b771594ed', 'en', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Does the project reduce industrial process emissions or create negative emissions?', '2026-08-28 17:30:50.579789+00'),
	('c6eaa400-54da-4a8d-ad80-653ece9b7af9', 'en', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'A monthly allowance for children living in Sweden, from birth until age 16.', '2026-08-28 17:30:50.579789+00'),
	('a5fbe7a9-3934-4d45-a4d9-987ceb83971b', 'en', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket offers grants to organisations, companies, associations, the public sector and private individuals in the environmental field.', '2026-08-28 17:30:50.579789+00'),
	('358ada03-ff21-4655-8e90-b7aa03c66f87', 'en', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Are you planning to voluntarily move back to your country of origin permanently?', '2026-08-28 17:30:50.579789+00'),
	('7d47d761-029f-4e3f-aee1-7cc8ed3b8875', 'en', 'Planerar du att starta eget företag?', 'Are you planning to start your own business?', '2026-08-28 17:30:50.579789+00'),
	('b9dd64ed-ce15-48d5-a07c-82f9a96b54a8', 'en', 'Planerar du att studera utomlands?', 'Are you planning to study abroad?', '2026-08-28 17:30:50.579789+00');
INSERT INTO public.kb_translations VALUES
	('0dc871fc-30fb-47dd-9a52-f6bbebb1fb79', 'en', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Are you planning studies that strengthen your position in the labour market?', '2026-08-28 17:30:50.579789+00'),
	('987bcdc3-5912-46f7-baa3-3981c8292896', 'en', 'Planerar ni att anställa?', 'Are you planning to hire?', '2026-08-28 17:30:50.579789+00'),
	('ca1aaed1-6147-44f3-af61-bc80b6cb91f2', 'en', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Are you planning to apply to an EU programme (e.g. Horisont Europa)?', '2026-08-28 17:30:50.579789+00'),
	('e2c5cecf-c5a4-4e2f-a0d3-8eb05a06266a', 'en', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Production and development support for short films and documentaries.', '2026-08-28 17:30:50.579789+00'),
	('d7cd4c5c-38d9-416e-8e3c-014990fbc1b4', 'en', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Project grants for the independent music scene for concerts, production and development.', '2026-08-28 17:30:50.579789+00'),
	('872d98ef-4362-4f89-be00-f1a875179b26', 'en', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Project grants for non-profit organisations working with and for children and young people.', '2026-08-28 17:30:50.579789+00'),
	('c1ada4f7-c228-46d4-8c10-7f9a2e149f24', 'en', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Does the project explore new artistic expressions, methods or collaborations?', '2026-08-28 17:30:50.579789+00'),
	('896c1dac-c266-4c62-84fd-b113ac999b49', 'en', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Does the exchange last 5–21 days (excluding travel days)?', '2026-08-28 17:30:50.579789+00'),
	('f9fceab6-ed8f-480f-bd47-ce2bc8672d45', 'en', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'The regions'' own project and operating support for cultural life, alongside Kulturrådet''s national grants.', '2026-08-28 17:30:50.579789+00'),
	('eeca448f-ccce-4328-83d7-506344c6a88b', 'en', 'Riktar sig projektet till barn eller unga?', 'Is the project aimed at children or young people?', '2026-08-28 17:30:50.579789+00'),
	('06775ec0-620c-42e4-9faa-ab4d6a90a960', 'en', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Is the project aimed at children, young people, the elderly or people with disabilities?', '2026-08-28 17:30:50.579789+00'),
	('aa79ce03-0eaf-4ac5-b3c0-74ddab0e568b', 'en', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Are the activities aimed at children and young people (7–25)?', '2026-08-28 17:30:50.579789+00'),
	('8b256a8c-a45d-4e28-9007-c4406059cd32', 'en', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Do you lack savings or assets that could cover the expenses?', '2026-08-28 17:30:50.579789+00'),
	('74e666b4-f7b2-4177-bcca-4f5dad72c4e1', 'en', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Are you cooperating with partners in at least two other Nordic countries?', '2026-08-28 17:30:50.579789+00'),
	('0a43fb82-50de-4561-bdcd-7a53b18df2c4', 'en', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Will you bring in external expertise for a development initiative?', '2026-08-28 17:30:50.579789+00'),
	('b0fb014a-0c6e-413b-9b40-7bbb13a8155a', 'en', 'Sker mobiliteten till ett annat europeiskt land?', 'Is the mobility to another European country?', '2026-08-28 17:30:50.579789+00'),
	('cbf74723-c5be-4743-844e-cb23530ca756', 'en', 'Startar du eller tar du över företaget för första gången?', 'Are you starting or taking over the business for the first time?', '2026-08-28 17:30:50.579789+00'),
	('56596faa-acdb-4c5e-92dd-95659ff48b70', 'en', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Start-up support for those aged 40 or younger who start or take over an agricultural business.', '2026-08-28 17:30:50.579789+00'),
	('aed2b0b6-27a0-4cfe-ac02-8f7f87e0a4c1', 'en', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'A scholarship that lets professional artists concentrate on their artistic work.', '2026-08-28 17:30:50.579789+00'),
	('1a95567d-2707-4ebb-9c97-19ea00875b55', 'en', 'Studerar du, eller planerar du att börja studera?', 'Are you studying, or planning to start studying?', '2026-08-28 17:30:50.579789+00'),
	('5143fbf1-acf0-4ba6-925d-341506e73f31', 'en', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Study support for working adults who want to educate themselves to strengthen their position in the labour market.', '2026-08-28 17:30:50.579789+00'),
	('86fcaa1e-d5e5-4636-a8d9-a3ef71c4aab1', 'en', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Support for investments that increase competitiveness or reduce environmental impact in agricultural businesses.', '2026-08-28 17:30:50.579789+00'),
	('207aadd4-2016-41d2-ae00-d0f08a4d9f05', 'en', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Support when a child lives with you and the other parent does not pay maintenance.', '2026-08-28 17:30:50.579789+00'),
	('a7776597-3ed9-4238-8e77-aae301a8cbb0', 'en', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Support for non-profit organisations'' projects for people, the environment and a better world.', '2026-08-28 17:30:50.579789+00'),
	('0ad62235-dd5f-4025-b901-a2737736f5d3', 'en', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Support for industry''s transition towards zero greenhouse gas emissions.', '2026-08-28 17:30:50.579789+00'),
	('2915311a-0051-447f-9c88-0c6f046ef91b', 'en', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Support for arts and culture projects with a Nordic dimension and cross-border cooperation.', '2026-08-28 17:30:50.579789+00'),
	('fe4ad976-086a-4691-9858-b90fa76fa634', 'en', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Support for innovative cultural projects exploring new artistic expressions, methods or collaborations.', '2026-08-28 17:30:50.579789+00'),
	('fc02af62-2fe1-40b0-a5e1-8c74636e6cf2', 'en', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Support for innovative projects for children, young people, the elderly and people with disabilities.', '2026-08-28 17:30:50.579789+00'),
	('8acddec7-6e0f-4082-9a07-9f1f9bf59573', 'en', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Support for cooperation projects in the independent music scene.', '2026-08-28 17:30:50.579789+00'),
	('574fcd3f-a566-4408-a791-d3f54f8c6216', 'es', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', '¿Le cuesta arreglárselas con su pensión y sus demás ingresos?', '2026-08-28 17:30:50.588849+00'),
	('fbd6f5ee-de3c-449c-a462-733addfc9314', 'en', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Support for cooperation projects in culture and media that strengthen democracy and freedom of expression internationally.', '2026-08-28 17:30:50.579789+00'),
	('9915cf49-2ad6-4710-a2c0-a6f2cb89837e', 'en', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Does the project aim to strengthen democracy, equality or freedom of expression?', '2026-08-28 17:30:50.579789+00'),
	('0e8ddc0c-6079-47d2-a4e8-dee802a158ad', 'en', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Are you looking for a job, or have you received a job offer, in another EU or EEA country?', '2026-08-28 17:30:50.579789+00'),
	('58226e63-05e4-4346-ba10-14538aaaeee5', 'en', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'A cap on what you need to pay in patient fees over a twelve-month period — after that, a frikort (free pass).', '2026-08-28 17:30:50.579789+00'),
	('ff153efe-2e24-432e-9e71-a007929edd05', 'en', 'Tar du ut hel allmän pension?', 'Are you drawing your full public pension?', '2026-08-28 17:30:50.579789+00'),
	('0a95075f-42fc-4e43-97b4-af7f0c628b03', 'en', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'A supplement covering part of the housing cost for those with a pension and low income.', '2026-08-28 17:30:50.579789+00'),
	('82ffc9e7-f892-4f39-86c2-e3fee7d96c23', 'en', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'An annual organisation grant for national child and youth organisations.', '2026-08-28 17:30:50.579789+00'),
	('5d7d5fa8-2d52-43ac-8c51-c3ad88018c2e', 'en', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'An annual allowance deducted directly at the dentist or dental hygienist.', '2026-08-28 17:30:50.579789+00'),
	('ecc8892c-e62d-4914-95ac-abd93a82d5cf', 'en', 'Är bolaget yngre än cirka 5 år?', 'Is the company younger than about 5 years?', '2026-08-28 17:30:50.579789+00'),
	('5833f710-0fdd-4e23-98cf-838e84959f32', 'en', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Are the exchange participants between 13 and 30 years old?', '2026-08-28 17:30:50.579789+00'),
	('cafc5b18-90af-425a-b750-32c832b901da', 'en', 'Är det här ert första EU-projekt?', 'Is this your first EU project?', '2026-08-28 17:30:50.579789+00'),
	('1070d047-7d68-4953-9b24-f86592b4ede0', 'en', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Is it very difficult for you (or your child) to get around on your own or to travel by bus and train?', '2026-08-28 17:30:50.579789+00'),
	('37f316ca-b5ba-4ce6-9c73-a9ecd2eb9532', 'en', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Is your income lower than about SEK 25,000 a month before tax?', '2026-08-28 17:30:50.579789+00'),
	('bdfe9e4b-fdce-43be-ac8f-59873868db44', 'en', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Is your most recently completed education compulsory school, or an upper secondary programme you did not finish?', '2026-08-28 17:30:50.579789+00'),
	('110b0232-b7ef-4185-9ba8-5f7c3f8baefe', 'en', 'Är du 40 år eller yngre?', 'Are you 40 or younger?', '2026-08-28 17:30:50.579789+00'),
	('7c2790ac-b46d-459f-84b4-e5cce83a132e', 'en', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Are you registered as a jobseeker with Arbetsförmedlingen?', '2026-08-28 17:30:50.579789+00'),
	('16d7cbd8-9676-43cd-8a51-766d6e125866', 'en', 'Är du mellan 18 och 28 år?', 'Are you between 18 and 28?', '2026-08-28 17:30:50.579789+00'),
	('22887848-6a11-499e-8004-1d18168e6120', 'en', 'Är du mellan 19 och 29 år?', 'Are you between 19 and 29?', '2026-08-28 17:30:50.579789+00'),
	('335c0856-2397-4e6b-8162-03fcf84e209e', 'en', 'Är du mellan 25 och 60 år?', 'Are you between 25 and 60?', '2026-08-28 17:30:50.579789+00'),
	('e54df812-bd69-4aea-bbe3-2d1ddafcfffb', 'en', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Are you professionally active in the cultural sector (e.g. dance, music, performing arts)?', '2026-08-28 17:30:50.579789+00');
INSERT INTO public.kb_translations VALUES
	('5d2d8a30-9746-486a-9289-ce14ea2986c7', 'en', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Are you a professional artist (not an amateur or in basic training)?', '2026-08-28 17:30:50.579789+00'),
	('d48ce254-6ca2-446d-bbc0-1e20b7047db9', 'en', 'Är du yrkesverksam konstnär?', 'Are you a professional artist?', '2026-08-28 17:30:50.579789+00'),
	('499a1a91-a9b8-4230-a150-b0059ae4afae', 'en', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Is your solution substantially innovative compared with what already exists?', '2026-08-28 17:30:50.583972+00'),
	('1cfc1f86-f0b9-4b45-87c2-78d655995d7e', 'en', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Is the club affiliated to a specialised sports federation within Riksidrottsförbundet?', '2026-08-28 17:30:50.583972+00'),
	('ccba9440-8dc8-4254-8a1b-764f9acc5baa', 'en', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Is the household''s income low in relation to the housing cost?', '2026-08-28 17:30:50.583972+00'),
	('c4c753a8-242d-431a-8ab8-2d6801b55068', 'en', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Is the household''s combined income lower than about SEK 25,000 a month before tax?', '2026-08-28 17:30:50.583972+00'),
	('aab0f2e0-0785-4245-858c-b155f4601860', 'en', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Is the initiative a defined project (not regular operations)?', '2026-08-28 17:30:50.583972+00'),
	('bab92376-5435-4cd6-9d7f-096aae3a22c7', 'en', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Is the venue open to everyone — not just your own members?', '2026-08-28 17:30:50.583972+00'),
	('f9c33384-9549-4454-b8c1-85feabcea8c5', 'en', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Are at least 60% of the members between 6 and 25 years old?', '2026-08-28 17:30:50.583972+00'),
	('99b733a2-04be-47be-88e9-248930927f6b', 'en', 'Är minst 60 % av medlemmarna under 26 år?', 'Are at least 60% of the members under 26?', '2026-08-28 17:30:50.583972+00'),
	('aa562ca2-f014-40fe-ad0f-e93e5327d944', 'en', 'Är målgruppen delaktig i planering och genomförande?', 'Is the target group involved in planning and implementation?', '2026-08-28 17:30:50.583972+00'),
	('cb152e95-8fe3-44f9-9a32-5c6ac654ba30', 'en', 'Är ni ett förlag med professionell utgivning?', 'Are you a publisher with professional publishing?', '2026-08-28 17:30:50.583972+00'),
	('1356f856-c13d-4b0d-9780-f899e3a266a1', 'en', 'Är ni huvudman för förskoleklass eller grundskola?', 'Are you the authority responsible for a preschool class or compulsory school?', '2026-08-28 17:30:50.583972+00'),
	('949898ec-0ebc-4b18-b7f0-6c9441c78841', 'en', 'Är organisationen registrerad i EU:s deltagarregister?', 'Is the organisation registered in the EU''s participant register?', '2026-08-28 17:30:50.583972+00'),
	('b9bfe5f4-92ab-42c4-87bc-e35cd4a372e3', 'en', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Is the project a film project (short film or documentary)?', '2026-08-28 17:30:50.583972+00'),
	('c682b80b-630f-4a6e-8944-a24f0eda0355', 'en', 'Är projektet ett konst- eller kulturprojekt?', 'Is the project an arts or culture project?', '2026-08-28 17:30:50.583972+00'),
	('7781943c-1d0b-4048-9d91-49a4d08e67b0', 'en', 'Är projektet ett kulturprojekt?', 'Is the project a culture project?', '2026-08-28 17:30:50.583972+00'),
	('22d81db8-aad4-4e04-b35c-0eefd85d3680', 'en', 'Är projektet ett musikprojekt?', 'Is the project a music project?', '2026-08-28 17:30:50.583972+00'),
	('267f72b3-0f3e-449a-aa85-2e8ac1a3f69a', 'en', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Is the project innovative — something you do not already do in regular operations?', '2026-08-28 17:30:50.583972+00'),
	('42ff9081-67f9-4752-b291-eb393c68c648', 'en', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Does the project benefit the community at large (not individuals)?', '2026-08-28 17:30:50.583972+00'),
	('d62d29f3-1008-4b09-82c5-a3fee010215e', 'en', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Is the journey between home and upper secondary school at least six kilometres?', '2026-08-28 17:30:50.583972+00'),
	('84657a97-efd4-48ac-adfd-d119ed73fcd5', 'en', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Are the activities professional (not amateur)?', '2026-08-28 17:30:50.583972+00'),
	('372a4447-1c5e-4e77-9fd1-8e8aa988ba30', 'en', 'Är verksamheten professionell?', 'Are the activities professional?', '2026-08-28 17:30:50.583972+00'),
	('85af7764-b8c8-4c1d-820f-d1818aa1c5f5', 'en', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Are the activities performing arts (dance, theatre, musical theatre)?', '2026-08-28 17:30:50.583972+00'),
	('21edfc8d-b44c-40ba-9cd9-51b0e423a26a', 'es', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Apoyo a actividades para clubes deportivos con actividades dirigidas por monitores para niños y jóvenes de 7 a 25 años.', '2026-08-28 17:30:50.588849+00'),
	('6f57c427-cc3f-46e6-a67a-b020d9cabfef', 'es', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Suplemento automático a la asignación por hijo (barnbidrag) a partir del segundo hijo.', '2026-08-28 17:30:50.588849+00'),
	('fbc45d4b-1c0b-45fc-9e19-b813dbafaf53', 'es', 'Avser ansökan en fysisk investering?', '¿La solicitud se refiere a una inversión física?', '2026-08-28 17:30:50.588849+00'),
	('89a04395-470c-4154-a437-0cf46ab312d5', 'es', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', '¿La solicitud se refiere a un viaje o intercambio internacional?', '2026-08-28 17:30:50.588849+00'),
	('e105bfd8-7163-42ef-b1ef-bd9da055d54d', 'es', 'Avser ansökan en investering i byggnader eller maskiner?', '¿La solicitud se refiere a una inversión en edificios o maquinaria?', '2026-08-28 17:30:50.588849+00'),
	('c9953f17-2eca-4ad3-8eb7-d5635581db35', 'es', 'Avser ansökan en redan utgiven titel?', '¿La solicitud se refiere a un título ya publicado?', '2026-08-28 17:30:50.588849+00'),
	('fe6cd0ce-5c41-402d-bb06-e00e13ee1182', 'es', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', '¿La solicitud se refiere a una empresa agrícola, hortícola o de cría de renos?', '2026-08-28 17:30:50.588849+00'),
	('0b41b7d9-2f36-42bc-ab1a-343c54e0473d', 'es', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', '¿La solicitud se refiere a la compra de literatura para bibliotecas públicas o escolares?', '2026-08-28 17:30:50.588849+00'),
	('a98751be-ba0a-4c07-aee7-b04577e7ed38', 'es', 'Avser investeringen jordbruksverksamhet?', '¿La inversión se refiere a una actividad agrícola?', '2026-08-28 17:30:50.588849+00'),
	('c8403831-675f-47e6-a11b-6e7173a11034', 'es', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', '¿El proyecto consiste en construir, comprar o renovar un local?', '2026-08-28 17:30:50.588849+00'),
	('9ea980db-a55a-42dc-bc8b-9b3c9d984c64', 'es', 'Avser projektet naturvård eller friluftsliv?', '¿El proyecto se refiere a la conservación de la naturaleza o a actividades al aire libre?', '2026-08-28 17:30:50.588849+00'),
	('d54a0f2f-6d78-4516-ba51-63554d846236', 'es', 'Avser projektet skola eller vuxenutbildning?', '¿El proyecto se refiere a la escuela o a la educación de adultos?', '2026-08-28 17:30:50.588849+00'),
	('7bf4a4d2-cc27-4525-8703-ccb929f2ac64', 'es', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', '¿Deja usted de trabajar para cuidar o estar cerca de un familiar tan gravemente enfermo que la enfermedad es una amenaza para su vida?', '2026-08-28 17:30:50.588849+00'),
	('12fd90aa-401a-4a67-bc68-de9c887e1687', 'es', 'Bedriver föreningen regelbunden verksamhet i kommunen?', '¿La asociación desarrolla actividades regulares en el municipio?', '2026-08-28 17:30:50.588849+00'),
	('ead9369a-cad0-4f06-8f62-40373ee21b8c', 'es', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', '¿Considera que su capacidad de trabajo está reducida durante al menos un año por enfermedad o discapacidad?', '2026-08-28 17:30:50.588849+00'),
	('9758c40c-28f5-4aa1-910a-aaed23333c33', 'es', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Apoyo sujeto a comprobación de recursos para quien tiene una pensión baja o nula y necesita ayuda para alcanzar un nivel de vida razonable.', '2026-08-28 17:30:50.588849+00'),
	('e64e46de-210a-4d20-baba-804f4daa236f', 'es', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', '¿El menor necesita vivir en la localidad de estudios (alojamiento) porque el trayecto es demasiado largo?', '2026-08-28 17:30:50.588849+00'),
	('7b609a0c-ac74-4d5f-9448-2221973a5f1f', 'es', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', '¿La vivienda necesita adaptarse (p. ej. rampa, abridor de puertas, baño)?', '2026-08-28 17:30:50.588849+00'),
	('a2234596-39b7-42a8-ba95-3afa6535a2f5', 'es', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', '¿Alguno de sus hijos de 8 a 19 años necesita gafas o lentillas?', '2026-08-28 17:30:50.588849+00'),
	('367128ed-f41f-4147-beac-e9d7faf131ee', 'es', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', '¿El otro progenitor no paga nada o paga menos que la pensión alimenticia completa?', '2026-08-28 17:30:50.588849+00'),
	('9a26e61e-c228-4451-a3f1-21b7f41f6253', 'es', 'Betalar du hyra eller andra boendekostnader?', '¿Paga usted alquiler u otros gastos de vivienda?', '2026-08-28 17:30:50.588849+00'),
	('7d92fa66-2c0b-4bb5-a5c4-d3d46d2e9f17', 'es', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Subvención para adaptar la vivienda en caso de discapacidad — p. ej. rampas, abridores de puertas o adaptación del baño.', '2026-08-28 17:30:50.588849+00'),
	('4ad87af4-1bc1-47be-a91b-23bc767113ce', 'es', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Subvenciones para construir, comprar o renovar locales públicos de reunión.', '2026-08-28 17:30:50.588849+00'),
	('0893ef05-240f-4739-b093-32fe09a3bc39', 'es', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Subvención para comprar o adaptar un coche cuando una discapacidad permanente hace muy difícil desplazarse o usar el transporte público.', '2026-08-28 17:30:50.588849+00'),
	('f4e943ed-b620-4619-916d-7e470e510df8', 'es', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Subvenciones para viajes e intercambios internacionales de profesionales del sector cultural.', '2026-08-28 17:30:50.588849+00'),
	('5ef4ebf1-0aca-4d25-a491-39964b61a519', 'es', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Subvenciones para intercambios internacionales, viajes y estancias de trabajo de artistas profesionales.', '2026-08-28 17:30:50.588849+00');
INSERT INTO public.kb_translations VALUES
	('43b2fa51-37d6-46a5-b656-197be1348339', 'es', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Beca y préstamo voluntario para estudios de nivel secundario superior o postsecundario.', '2026-08-28 17:30:50.588849+00'),
	('b52540d1-076e-4d70-90b6-49f83a0ebd8b', 'es', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Becas y préstamos para estudiar en el extranjero, con préstamos adicionales para p. ej. tasas académicas y viajes.', '2026-08-28 17:30:50.588849+00'),
	('220dc3f6-a3b1-4d3b-befd-38634a411130', 'es', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Subvención que ayuda a actores suecos a preparar solicitudes para programas de la UE como Horisont Europa.', '2026-08-28 17:30:50.588849+00'),
	('eea0a547-b088-4bbb-b786-0156f5b01374', 'es', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Subvención para empleadores que contratan a personas con capacidad de trabajo reducida.', '2026-08-28 17:30:50.588849+00'),
	('2946a214-120c-4804-8682-959af5be2871', 'es', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Subvención para alojamiento y viajes a casa cuando un estudiante de secundaria superior debe vivir en la localidad de estudios por la distancia.', '2026-08-28 17:30:50.588849+00'),
	('2e15a9f1-9901-4e5e-ad7c-ad9c94d768a3', 'es', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Subvenciones para el trabajo de organizaciones sin ánimo de lucro por conservar, usar y desarrollar el patrimonio cultural.', '2026-08-28 17:30:50.588849+00'),
	('b2fe725d-1d09-4a8f-a5c9-9422f8a2eef2', 'es', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Subvenciones para proyectos municipales y locales de conservación de la naturaleza, incluidos humedales y actividades al aire libre.', '2026-08-28 17:30:50.588849+00'),
	('2a4648bd-68dc-40d6-abc4-57b894430d0e', 'es', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Subvenciones a municipios para la compra de literatura para bibliotecas públicas y escolares.', '2026-08-28 17:30:50.588849+00'),
	('1e42fbcf-9fe9-40ec-8b85-338685688baf', 'es', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Apoyo a la transición de la industria hacia cero emisiones de gases de efecto invernadero.', '2026-08-28 17:30:50.588849+00'),
	('33e881ff-07af-473c-a949-4f032e5270d6', 'es', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Subvenciones a titulares de escuelas para el encuentro de los alumnos con la cultura profesional en la escuela obligatoria.', '2026-08-28 17:30:50.588849+00'),
	('8334ab62-1b23-443a-81bd-5320b3d0b943', 'es', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Ayuda para lo que su hijo necesita pero la economía familiar no alcanza a cubrir: actividades de ocio, ropa, excursiones escolares, gafas, actividades vacacionales y más.', '2026-08-28 17:30:50.588849+00'),
	('42c628f3-7446-4f48-b644-9d7e559edd87', 'es', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Ayudas de fondos como Världens Barn, Musikhjälpen y Victoriafonden — solicitadas por organizaciones suecas sin ánimo de lucro con 90-konto.', '2026-08-28 17:30:50.588849+00'),
	('56b53980-93e6-4ccd-9f63-e8bf8df86197', 'es', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Ayudas de los fondos de energía hidroeléctrica y eólica para proyectos que desarrollan la comarca.', '2026-08-28 17:30:50.588849+00'),
	('d364ddd6-5d64-46af-8ad6-9205755e91ff', 'es', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Beca sin componente de préstamo para desempleados de 25 a 60 años con estudios previos cortos que necesitan estudiar a nivel de primaria o secundaria.', '2026-08-28 17:30:50.588849+00'),
	('6eac2d45-1838-4223-8291-7265f16cc796', 'es', 'Bidrar projektet till energiomställningen?', '¿El proyecto contribuye a la transición energética?', '2026-08-28 17:30:50.588849+00'),
	('c8a87acd-4a42-413d-b848-56d1fbf640ef', 'es', 'Bor du och barnets andra förälder på skilda håll?', '¿Usted y el otro progenitor del menor viven separados?', '2026-08-28 17:30:50.588849+00'),
	('cb5fd9bd-02aa-4c19-9197-9bf868d6fd53', 'es', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Cheques para pequeñas empresas para incorporar competencias externas en internacionalización o digitalización.', '2026-08-28 17:30:50.588849+00'),
	('3c5eca84-89ac-4ae4-ba71-534520464ff8', 'es', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', '¿Participa usted en un programa de Arbetsförmedlingen (p. ej. jobb- och utvecklingsgarantin)?', '2026-08-28 17:30:50.588849+00'),
	('38aa4a16-ede0-4f75-857b-62ca964433b4', 'es', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Apoyo a posteriori a editoriales por la publicación de literatura de calidad.', '2026-08-28 17:30:50.588849+00'),
	('585e0ec4-afaa-4310-83ec-5b1a95c589b2', 'es', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Apoyo económico para quien tiene un permiso de residencia por protección y desea voluntariamente regresar de forma permanente a su país de origen.', '2026-08-28 17:30:50.588849+00'),
	('2feca10c-ea33-431d-aa3a-c2494c7357a2', 'es', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Apoyo económico a empleadores que contratan a alguien que ha estado mucho tiempo fuera de la vida laboral.', '2026-08-28 17:30:50.588849+00'),
	('2ed9a0d8-5456-4a09-bad7-20867724898b', 'es', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Apoyo económico durante la fase inicial para demandantes de empleo que crean su propia empresa.', '2026-08-28 17:30:50.588849+00'),
	('596c4ca9-b629-484d-9429-3934bbeb4d60', 'es', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten abre continuamente convocatorias en investigación energética, innovación y eficiencia energética.', '2026-08-28 17:30:50.588849+00'),
	('04f244ca-10ee-4d40-8a8e-a20a46052d9d', 'es', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Prestación por ausentarse del trabajo o de los estudios para cuidar de un hijo.', '2026-08-28 17:30:50.588849+00'),
	('47fe1944-8247-4459-bea6-d062d485dca8', 'es', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Prestación para quien es nuevo en Suecia y participa en el programa de establecimiento de Arbetsförmedlingen; la paga Försäkringskassan.', '2026-08-28 17:30:50.588849+00'),
	('ff402bfb-febd-4456-a992-cacc93045125', 'es', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Prestación que cubre parte del gasto de vivienda para jóvenes sin hijos con ingresos bajos.', '2026-08-28 17:30:50.588849+00'),
	('cd667179-51e5-4aa1-ae7e-550d0d340891', 'es', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Prestación por los gastos adicionales que conlleva una discapacidad permanente — para adultos o para padres de niños con discapacidad.', '2026-08-28 17:30:50.588849+00'),
	('9053e853-a8b5-4382-a5c5-cb6a45aac272', 'es', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Prestación para jóvenes (19–29 años) que no pueden trabajar a tiempo completo durante al menos un año por enfermedad o discapacidad.', '2026-08-28 17:30:50.588849+00'),
	('368b9d41-f665-465a-bb83-f5c9956a7b46', 'es', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Prestación cuando la capacidad de trabajo está reducida de forma permanente — lo que antes se llamaba förtidspension (jubilación anticipada).', '2026-08-28 17:30:50.588849+00'),
	('43a52fde-cc3e-4f76-a8b4-18d3268501f4', 'es', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Prestación cuando usted deja de trabajar para estar cerca de un familiar gravemente enfermo.', '2026-08-28 17:30:50.588849+00'),
	('6fab9017-deb4-436a-b865-4d104cdb4c3e', 'es', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Prestación cuando participa en un programa de política laboral de Arbetsförmedlingen.', '2026-08-28 17:30:50.588849+00'),
	('377ea796-ba33-4341-8732-0fc205640460', 'es', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Prestación cuando no puede trabajar con normalidad por enfermedad.', '2026-08-28 17:30:50.588849+00'),
	('7b29e7c6-e8d2-44fa-81fe-d773ee36a2b3', 'es', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Prestación cuando se queda en casa sin ir al trabajo para cuidar de un hijo enfermo.', '2026-08-28 17:30:50.588849+00'),
	('561e4522-e52a-44a0-9fdd-c1fd3b375550', 'es', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Prestación que cubre parte del gasto de vivienda para hogares con hijos e ingresos más bajos.', '2026-08-28 17:30:50.588849+00'),
	('0ac90d2e-65fd-430c-a7f4-9908078ba729', 'es', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Prestación para padres cuyos hijos, por discapacidad, necesitan más cuidado y supervisión que otros niños de la misma edad.', '2026-08-28 17:30:50.588849+00'),
	('7258e097-a701-4ef4-964f-61343c8bd7e0', 'es', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Prestación por desempleo — basada en los ingresos para afiliados, importe básico para los demás.', '2026-08-28 17:30:50.588849+00'),
	('bc505c88-78c0-479d-b21a-bf9d60097edb', 'es', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Una cincuentena de fundaciones de cajas de ahorros conceden ayudas a proyectos locales de deporte, cultura, educación y desarrollo comunitario — en la zona de actividad de la caja.', '2026-08-28 17:30:50.588849+00'),
	('b20b2f88-5a7d-4d81-ba85-4ba2741579e5', 'es', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Apoyo a proyectos financiado por la UE que se solicita en su zona Leader local — para asociaciones, empresas y municipios que desarrollan el medio rural.', '2026-08-28 17:30:50.588849+00'),
	('6e67f50e-610d-4e80-933d-bc69ea4b3b0b', 'es', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Apoyo financiado por la UE para demandantes de empleo que aceptan un trabajo en otro país UE/EEE: compensación por viaje de entrevista, gastos de mudanza y curso de idiomas.', '2026-08-28 17:30:50.588849+00'),
	('3042118a-cf9e-4e0a-8c61-559d8b029bf2', 'es', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Fondos del Fondo Social Europeo para proyectos que refuerzan las competencias, la transición y la inclusión en el mercado laboral.', '2026-08-28 17:30:50.588849+00'),
	('38988e23-3b53-4a49-971f-291dedf2c1f0', 'es', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Apoyo de la UE para intercambios de grupos de jóvenes de 13 a 30 años, de 5 a 21 días sin contar los días de viaje.', '2026-08-28 17:30:50.588849+00'),
	('c22802d6-4bca-4680-a25e-8eb49545b926', 'es', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Apoyo de la UE para proyectos de cooperación de organizaciones culturales con socios en varios países europeos.', '2026-08-28 17:30:50.588849+00'),
	('ddfd8514-f7db-4f58-b39c-fcf14b9d8ae5', 'es', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Apoyo de la UE para organizaciones que reciben o envían jóvenes voluntarios de 18 a 30 años.', '2026-08-28 17:30:50.588849+00'),
	('5f6af3a0-9c38-4877-b5c8-e72eb9ca05e3', 'es', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Apoyo de la UE para la movilidad de personal y alumnado en la escuela y la educación de adultos.', '2026-08-28 17:30:50.588849+00'),
	('94abab14-661d-4bb0-92e8-3c4674c239dd', 'es', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Apoyo de la UE con importes a tanto alzado para los primeros proyectos europeos de cooperación de organizaciones pequeñas.', '2026-08-28 17:30:50.588849+00'),
	('d02dcf74-efbe-4f84-95e6-e880393426fe', 'es', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Financiación para empresas jóvenes que desarrollan productos o servicios innovadores con potencial internacional.', '2026-08-28 17:30:50.588849+00'),
	('b6ce6258-8696-4ce8-bdda-9dc8695c340a', 'es', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', '¿Hay una caja de ahorros (y por tanto una fundación de caja de ahorros) donde desarrollan su actividad?', '2026-08-28 17:30:50.588849+00'),
	('ab10b6df-0d3b-492a-9941-15e959649260', 'es', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Subvenciones de funcionamiento plurianuales para grupos profesionales independientes de danza, teatro y teatro musical.', '2026-08-28 17:30:50.588849+00'),
	('dbc87384-f8a5-4591-b46d-b7027b13d4cc', 'es', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Ayudas a la investigación en los ámbitos de Forte: salud, vida laboral y bienestar. Las solicitan investigadores doctorados de universidades suecas.', '2026-08-28 17:30:50.588849+00'),
	('215eaf49-8d5e-4852-b0f0-607c12d27276', 'es', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Fondos de investigación para investigación básica libre en todos los campos científicos.', '2026-08-28 17:30:50.588849+00');
INSERT INTO public.kb_translations VALUES
	('e0718411-c7dd-4e6a-9561-f3559ddad01a', 'es', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Fondos de investigación en medio ambiente, ciencias agrarias y urbanismo.', '2026-08-28 17:30:50.588849+00'),
	('56f5b6ec-d91c-49a9-9a19-9460ff25837d', 'es', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', '¿Está pensando en mudarse al extranjero (por trabajo, estudios o retorno)?', '2026-08-28 17:30:50.588849+00'),
	('bbe2ffa2-fcd4-4ea3-bde4-e87be8418a32', 'es', 'Genomförs insatserna av professionella kulturaktörer?', '¿Las actividades las realizan agentes culturales profesionales?', '2026-08-28 17:30:50.588849+00'),
	('2fbfabfd-74e7-4e26-85b9-70a8593241ba', 'es', 'Genomförs projektet på landsbygden eller i en mindre tätort?', '¿El proyecto se realiza en el medio rural o en una localidad pequeña?', '2026-08-28 17:30:50.588849+00'),
	('9c33a82b-fb31-49f6-a946-bc456b7a395b', 'es', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Protección básica para quien ha tenido pocos o ningún ingreso laboral durante su vida.', '2026-08-28 17:30:50.588849+00'),
	('dc189b99-9c2f-45eb-a340-a2c6d759714a', 'es', 'Går något av dina barn i grundskolan?', '¿Alguno de sus hijos va a la escuela obligatoria?', '2026-08-28 17:30:50.588849+00'),
	('411e5dbd-f11e-48c5-924f-4d8fdc3d3e3e', 'es', 'Går något av dina barn på gymnasiet?', '¿Alguno de sus hijos va al instituto (gymnasiet)?', '2026-08-28 17:30:50.588849+00'),
	('989a48eb-a879-44f8-b5e3-2e17289c62d8', 'es', 'Gäller anställningen en person med nedsatt arbetsförmåga?', '¿La contratación se refiere a una persona con capacidad de trabajo reducida?', '2026-08-28 17:30:50.588849+00'),
	('bd6c7919-b276-4cf4-8f55-1c47c55b67c6', 'es', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', '¿La contratación se refiere a alguien que lleva mucho tiempo en paro o es nuevo en Suecia?', '2026-08-28 17:30:50.588849+00'),
	('fd049cee-0787-4d2a-a735-1e9c7a4268ec', 'es', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', '¿El proyecto trata de conservar o hacer accesible el patrimonio cultural?', '2026-08-28 17:30:50.588849+00'),
	('a049fcda-fe0f-4a32-b0c7-47c4a7c6e94b', 'es', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', '¿El proyecto trata de energía, eficiencia energética o innovación energética?', '2026-08-28 17:30:50.588849+00'),
	('c6a29e53-5b3a-436e-ab49-5a89197b3f67', 'es', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', '¿El proyecto trata de salud, vida laboral o bienestar?', '2026-08-28 17:30:50.588849+00'),
	('c0cb228f-992e-474c-ac07-9004d6302bf1', 'es', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', '¿El proyecto trata de desarrollo de competencias o medidas de empleo?', '2026-08-28 17:30:50.588849+00'),
	('0b654960-0b8c-4a66-8bf1-9c46288ed9df', 'es', 'Handlar projektet om miljö- eller klimatåtgärder?', '¿El proyecto trata de medidas medioambientales o climáticas?', '2026-08-28 17:30:50.588849+00'),
	('d122c852-e3fd-41ba-b1b4-2f83bf942adc', 'es', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', '¿El menor tiene un camino a la escuela largo, peligroso por el tráfico o difícil por otros motivos?', '2026-08-28 17:30:50.588849+00'),
	('433ba970-4314-4f29-b30e-1cc4312b996e', 'es', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', '¿Ha trabajado al menos 16 horas semanales durante un total de al menos 8 años?', '2026-08-28 17:30:50.588849+00'),
	('7692ccfd-a148-4a23-bafd-25312258659f', 'es', 'Har du barn som bor hos dig, helt eller växelvis?', '¿Tiene hijos que viven con usted, todo el tiempo o en alternancia?', '2026-08-28 17:30:50.588849+00'),
	('a02ead29-e5fa-4cd2-a430-e3e9dd4058d5', 'es', 'Har du barn som bor hos dig?', '¿Tiene hijos que viven con usted?', '2026-08-28 17:30:50.588849+00'),
	('2a3c0af5-ec1d-4678-ae88-ef81ae08f7eb', 'es', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', '¿Usted o su hijo tienen una discapacidad que se espera dure al menos un año?', '2026-08-28 17:30:50.588849+00'),
	('f709e0b6-523c-4e34-ab75-c8843ebba42e', 'es', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', '¿Usted o alguien del hogar tiene una discapacidad permanente que afecta a la vivienda?', '2026-08-28 17:30:50.588849+00'),
	('b07f804f-4c9b-48ef-9e2b-abe016e7ffcf', 'es', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', '¿Usted o un familiar cercano tiene una discapacidad o una enfermedad prolongada o grave?', '2026-08-28 17:30:50.588849+00'),
	('eb30fdf7-43e6-4984-96fa-029c2475232d', 'es', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', '¿Tiene una enfermedad o lesión que ahora mismo reduce su capacidad de trabajo?', '2026-08-28 17:30:50.588849+00'),
	('83c6e457-cde8-4164-b65f-f43a25969429', 'es', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', '¿Alguna vez le ha costado pagar una excursión escolar, un viaje de clase o una actividad de ocio en la que se espera que participe su hijo?', '2026-08-28 17:30:50.588849+00'),
	('77ce517d-71c5-46ae-9899-d6b71d257570', 'es', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', '¿Ha obtenido en los últimos años un permiso de residencia en Suecia, p. ej. como persona necesitada de protección o como familiar?', '2026-08-28 17:30:50.588849+00'),
	('cafaf402-ed87-4d65-801f-78879b997c87', 'es', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', '¿Tiene permiso de residencia en Suecia como refugiado o persona necesitada de protección (o es familiar cercano de alguien que lo tiene)?', '2026-08-28 17:30:50.588849+00'),
	('c57dac0c-12b3-4583-b54b-fcd288ec7aad', 'es', 'Har du uppnått riktåldern för pension (67 år 2026)?', '¿Ha alcanzado la edad de referencia de jubilación (67 años en 2026)?', '2026-08-28 17:30:50.588849+00'),
	('8b20fa17-c751-49ce-889a-683da1dfd809', 'es', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', '¿Su organización tiene un OID (Organisation ID) registrado en el Organisation Registration System de la UE?', '2026-08-28 17:30:50.588849+00'),
	('9f91113d-b434-417c-99dc-39c49df76108', 'es', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', '¿La discapacidad ha supuesto gastos adicionales — p. ej. ayudas técnicas, viajes, dieta especial o desgaste?', '2026-08-28 17:30:50.588849+00'),
	('929d303e-35a7-4daa-8094-b467cec0f5a1', 'es', 'Har föreningen antagna stadgar och en vald styrelse?', '¿La asociación tiene estatutos aprobados y una junta directiva elegida?', '2026-08-28 17:30:50.588849+00'),
	('8a4d9ede-0189-4a66-acb3-a57a0cd1caca', 'es', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', '¿La asociación tiene una estructura democrática (estatutos, asamblea anual, junta)?', '2026-08-28 17:30:50.588849+00'),
	('a30e6334-68ee-458e-a94a-ac86c61b6569', 'es', 'Har föreningen regelbunden verksamhet för barn eller unga?', '¿La asociación desarrolla actividades regulares para niños o jóvenes?', '2026-08-28 17:30:50.588849+00'),
	('0d8b0905-aa7b-4045-a72b-a55312a93cc0', 'es', 'Har företaget mellan cirka 2 och 49 anställda?', '¿La empresa tiene entre aproximadamente 2 y 49 empleados?', '2026-08-28 17:30:50.588849+00'),
	('d127d96d-697c-44e5-9290-8f078142fd65', 'es', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', '¿Al hogar le cuesta cubrir los gastos de comida, vivienda y lo más necesario?', '2026-08-28 17:30:50.588849+00'),
	('1f830750-d1d4-45fd-b90a-16a28afc08ca', 'es', 'Har lösningen internationell potential?', '¿La solución tiene potencial internacional?', '2026-08-28 17:30:50.588849+00'),
	('456bd109-4ccb-408a-bf75-e14313c01f4b', 'es', 'Har ni en partnergrupp i ett annat land?', '¿Tienen un grupo socio en otro país?', '2026-08-28 17:30:50.588849+00'),
	('f9772ad4-74bf-41da-a0cf-3778be76522e', 'es', 'Har ni en partnerorganisation i ett annat europeiskt land?', '¿Tienen una organización socia en otro país europeo?', '2026-08-28 17:30:50.588849+00'),
	('5e21c178-eeff-426e-bb7f-c916c5f1fba8', 'es', 'Har ni partner i minst tre olika europeiska länder?', '¿Tienen socios en al menos tres países europeos distintos?', '2026-08-28 17:30:50.588849+00'),
	('eedb5d6e-3128-4047-b8a4-35752f8516aa', 'es', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', '¿Tienen su sede o actividad principal en la región donde solicitan?', '2026-08-28 17:30:50.588849+00'),
	('c0ec0d47-8dbe-4573-af1a-809478aa2fc1', 'es', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', '¿Alguno de sus hijos tiene una discapacidad por la que necesita más cuidado o supervisión que otros niños de la misma edad?', '2026-08-28 17:30:50.588849+00'),
	('cfb726f9-276c-4bc2-bf7c-5e3466736107', 'es', 'Har organisationen en demokratisk uppbyggnad?', '¿La organización tiene una estructura democrática?', '2026-08-28 17:30:50.588849+00'),
	('f8213fd6-f704-43ed-be3e-acd897c9dae9', 'es', 'Har organisationen en Quality Label (kvalitetsmärkning)?', '¿La organización tiene una Quality Label (sello de calidad)?', '2026-08-28 17:30:50.588849+00'),
	('9f63ddae-df72-47f1-9039-de7fd8ce133a', 'es', 'Har organisationen ett 90-konto?', '¿La organización tiene un 90-konto?', '2026-08-28 17:30:50.588849+00'),
	('c2337bfd-553f-40b5-8f94-67991d7d334c', 'es', 'Har organisationen ett OID (Organisation ID)?', '¿La organización tiene un OID (Organisation ID)?', '2026-08-28 17:30:50.588849+00'),
	('f3f62175-96f3-49b4-9d44-f4fad3293777', 'es', 'Har organisationen ett OID?', '¿La organización tiene un OID?', '2026-08-28 17:30:50.588849+00'),
	('ae1d7f25-a171-4619-ab2f-1b23d244d688', 'es', 'Har organisationen medlemsföreningar i flera län?', '¿La organización tiene asociaciones miembro en varias provincias?', '2026-08-28 17:30:50.588849+00'),
	('7d963fd4-6f34-4a23-9d55-3b447b850085', 'es', 'Har organisationen ordnad ekonomi och demokratisk struktur?', '¿La organización tiene una economía ordenada y una estructura democrática?', '2026-08-28 17:30:50.588849+00'),
	('184f886e-9e83-47b8-9c6f-55e9a6ee0bd3', 'es', 'Har projektet en partner i ett annat land?', '¿El proyecto tiene un socio en otro país?', '2026-08-28 17:30:50.588849+00'),
	('738b70e4-cfb6-430a-9aa9-82fc0f294203', 'es', 'Har projektledaren doktorsexamen?', '¿La persona que lidera el proyecto tiene un doctorado?', '2026-08-28 17:30:50.588849+00'),
	('1800f025-443d-4b28-a7b8-195104f7efe8', 'es', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'El municipio de residencia debe garantizar los desplazamientos diarios entre la vivienda y el instituto cuando el trayecto es de al menos seis kilómetros (p. ej. abono de autobús).', '2026-08-28 17:30:50.588849+00'),
	('cbddf5e4-372a-4143-89f0-1f6a10cac8fe', 'es', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', '¿Está consiguiendo o equipando su primera vivienda propia en Suecia?', '2026-08-28 17:30:50.588849+00');
INSERT INTO public.kb_translations VALUES
	('14a6f6c4-1f1a-4d19-a83f-4d6bbc24e0c4', 'es', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', '¿El proyecto incluye un viaje o intercambio internacional?', '2026-08-28 17:30:50.588849+00'),
	('afb44ba3-0c76-49d2-b0e6-5bedcf53ed58', 'es', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Apoyo a la inversión para empresas en zonas de ayuda, para edificios, maquinaria y formación.', '2026-08-28 17:30:50.588849+00'),
	('a6127c66-079e-445c-8c25-9adb48e7b4cc', 'es', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Apoyo a inversiones en medidas que reducen las emisiones de gases de efecto invernadero.', '2026-08-28 17:30:50.588849+00'),
	('cbd0b228-7f1a-49b7-ae81-e880044877b6', 'es', 'Kan projektets miljönytta mätas?', '¿Se puede medir el beneficio medioambiental del proyecto?', '2026-08-28 17:30:50.588849+00'),
	('36aa4341-18a0-44bf-be25-89c394294c0e', 'es', 'Kan åtgärdens utsläppsminskning beräknas?', '¿Se puede calcular la reducción de emisiones de la medida?', '2026-08-28 17:30:50.588849+00'),
	('80b1842f-da6f-45e1-afec-1a773508f5ee', 'es', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', '¿La organización puede adelantar los gastos hasta que se abone la ayuda?', '2026-08-28 17:30:50.588849+00'),
	('af3881d3-ebad-4e83-b81e-bd703739c192', 'es', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', '¿Las experiencias se utilizarán en su actividad en Suecia?', '2026-08-28 17:30:50.588849+00'),
	('3f33ebe6-a72c-48e6-8202-8d37eb36fc24', 'es', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', '¿La inversión comenzará solo después de presentar la solicitud?', '2026-08-28 17:30:50.588849+00'),
	('15049d95-0668-4491-bce0-b1c768d7a486', 'es', 'Kommer projektet människor i ert närområde till del?', '¿El proyecto beneficia a las personas de su entorno?', '2026-08-28 17:30:50.588849+00'),
	('071d9282-c9e3-40fc-8da2-960e2a1247f6', 'es', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'La última red de seguridad económica del municipio cuando los ingresos no alcanzan para lo más necesario.', '2026-08-28 17:30:50.588849+00'),
	('3dcde678-dd9b-455f-ba19-c26216512f25', 'es', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Los apoyos propios de los municipios al tejido asociativo local: ayuda por actividad, ayuda para locales, ayuda inicial y más.', '2026-08-28 17:30:50.588849+00'),
	('3cebe1ab-379e-47fc-9831-5ef53d103838', 'es', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Apoyo a proyectos de arte y cultura con dimensión nórdica y cooperación transfronteriza.', '2026-08-28 17:30:50.588849+00'),
	('dc6987a5-2793-40cd-b876-487e0530fcb9', 'es', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Transporte escolar gratuito para alumnos de la escuela obligatoria por distancia larga, camino peligroso o discapacidad — un derecho según la ley escolar.', '2026-08-28 17:30:50.588849+00'),
	('5e2dd5f5-a98d-4aca-90e4-312917910308', 'es', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Ayuda legal para gafas o lentillas para niños y jóvenes; los importes y trámites varían por región — compruebe el nivel de su región.', '2026-08-28 17:30:50.588849+00'),
	('d064003f-729e-4c30-882b-48a630c41498', 'es', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', '¿El proyecto está en una comarca afectada por la energía hidroeléctrica o eólica?', '2026-08-28 17:30:50.588849+00'),
	('04a541b4-159b-44e3-ba38-ae06885bb8d1', 'es', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', '¿El proyecto está dentro de medio ambiente, ciencias agrarias o urbanismo?', '2026-08-28 17:30:50.588849+00'),
	('c43bbdfd-887c-4119-bc5d-347fc992fa01', 'es', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', '¿El lugar de actividad está en la zona de ayuda A o B (gran parte de Norrland y el interior de Svealand)?', '2026-08-28 17:30:50.588849+00'),
	('eb6ce423-b0e7-4b6f-89e1-16274d9f2527', 'es', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Préstamo para comprar lo más necesario para un primer hogar en Suecia — muebles, utensilios y otro equipamiento básico.', '2026-08-28 17:30:50.588849+00'),
	('e59106b5-8f3a-4b73-818e-f3a453ecbf2f', 'es', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', '¿El proyecto reduce las emisiones de proceso de la industria o crea emisiones negativas?', '2026-08-28 17:30:50.588849+00'),
	('eae67052-aa58-47da-841f-e582bea0e778', 'es', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Asignación mensual para niños que viven en Suecia, desde el nacimiento hasta los 16 años.', '2026-08-28 17:30:50.588849+00'),
	('b601f9f0-a6ce-42e1-885c-bb2f68eec0dd', 'es', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket ofrece ayudas a organizaciones, empresas, asociaciones, sector público y particulares en el ámbito medioambiental.', '2026-08-28 17:30:50.588849+00'),
	('c391a708-3dcd-4522-a613-2c0ac2ce04a4', 'es', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', '¿Planea regresar voluntariamente y de forma permanente a su país de origen?', '2026-08-28 17:30:50.588849+00'),
	('bd24cc8b-403d-46cb-9e7b-d2e9aaaceb70', 'es', 'Planerar du att starta eget företag?', '¿Planea crear su propia empresa?', '2026-08-28 17:30:50.588849+00'),
	('8bd11677-0b4e-4524-9677-eb7aa3260c54', 'es', 'Planerar du att studera utomlands?', '¿Planea estudiar en el extranjero?', '2026-08-28 17:30:50.588849+00'),
	('6ee4f90e-1e75-4b8f-8fd6-29f9953b83ff', 'es', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', '¿Planea estudios que refuercen su posición en el mercado laboral?', '2026-08-28 17:30:50.588849+00'),
	('3377a1d4-3c3e-41b0-bc58-9613e62d76a3', 'es', 'Planerar ni att anställa?', '¿Planean contratar?', '2026-08-28 17:30:50.588849+00'),
	('6cf37ec3-7f71-4f3b-9277-6d10dda20d54', 'es', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', '¿Planean solicitar un programa de la UE (p. ej. Horisont Europa)?', '2026-08-28 17:30:50.588849+00'),
	('f144a756-3c7b-47df-bf9f-e26e68041f2a', 'es', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Apoyo a la producción y el desarrollo de cortometrajes y documentales.', '2026-08-28 17:30:50.588849+00'),
	('8c4ce9af-84ed-4937-b23d-2e4b38494aaf', 'es', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Ayudas a proyectos de la escena musical independiente para conciertos, producción y desarrollo.', '2026-08-28 17:30:50.588849+00'),
	('15854ac7-a021-4a43-ac6a-b51aa7d35895', 'es', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Ayudas a proyectos de organizaciones sin ánimo de lucro que trabajan con y para niños y jóvenes.', '2026-08-28 17:30:50.588849+00'),
	('e751451d-1aca-42f2-984f-a04839d7fec6', 'es', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', '¿El proyecto explora nuevas expresiones, métodos o colaboraciones artísticas?', '2026-08-28 17:30:50.588849+00'),
	('cdfc3684-dcbc-44e2-a9ba-b3f38e2ed880', 'es', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', '¿El intercambio dura de 5 a 21 días (sin contar los días de viaje)?', '2026-08-28 17:30:50.588849+00'),
	('4dfa5aca-d987-47ef-84ad-4dfd2fc15ec1', 'es', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Los apoyos propios de las regiones a proyectos y actividades culturales, junto a las ayudas nacionales de Kulturrådet.', '2026-08-28 17:30:50.588849+00'),
	('df3e6041-dccd-46d3-8228-c13516aebc54', 'es', 'Riktar sig projektet till barn eller unga?', '¿El proyecto se dirige a niños o jóvenes?', '2026-08-28 17:30:50.588849+00'),
	('7a2c33ea-1fb6-46ca-85b6-b4218265120a', 'es', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', '¿El proyecto se dirige a niños, jóvenes, mayores o personas con discapacidad?', '2026-08-28 17:30:50.588849+00'),
	('33e6d833-0907-43bc-b3d9-e600a417c3f4', 'es', 'Riktar sig verksamheten till barn och unga (7–25 år)?', '¿La actividad se dirige a niños y jóvenes (7–25 años)?', '2026-08-28 17:30:50.588849+00'),
	('6ca5f2cc-1ede-453f-9c29-cc8ad9836d5e', 'es', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', '¿Carece de ahorros o bienes que puedan cubrir los gastos?', '2026-08-28 17:30:50.588849+00'),
	('ab77ac97-1dd9-4995-a49a-eb1d5bf4c277', 'es', 'Samarbetar ni med partner i minst två andra nordiska länder?', '¿Colaboran con socios en al menos otros dos países nórdicos?', '2026-08-28 17:30:50.588849+00'),
	('8f615295-ed78-4e40-bd14-a68ddaaa44bd', 'es', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', '¿Van a incorporar competencias externas para una acción de desarrollo?', '2026-08-28 17:30:50.588849+00'),
	('97b134e4-0ab5-4a91-af89-3a289f44df2b', 'es', 'Sker mobiliteten till ett annat europeiskt land?', '¿La movilidad es hacia otro país europeo?', '2026-08-28 17:30:50.588849+00'),
	('62a4d3b6-38b3-40f6-80a4-47f8884ef0f0', 'es', 'Startar du eller tar du över företaget för första gången?', '¿Crea o asume la empresa por primera vez?', '2026-08-28 17:30:50.588849+00'),
	('47ae8e89-7619-49ef-b45e-69d1d4fc3c85', 'es', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Ayuda inicial para quien tiene 40 años o menos y crea o asume una empresa agrícola.', '2026-08-28 17:30:50.588849+00'),
	('b854871f-4ad6-4b13-9d53-d17ed19276f3', 'es', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Beca que permite a artistas profesionales concentrarse en su trabajo artístico.', '2026-08-28 17:30:50.588849+00'),
	('bad61e20-5e94-4391-9aa4-03c78ae0b5c3', 'es', 'Studerar du, eller planerar du att börja studera?', '¿Estudia, o planea empezar a estudiar?', '2026-08-28 17:30:50.588849+00'),
	('84cd9e34-87f8-44ff-8157-ac11ff228fdd', 'es', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Apoyo al estudio para adultos en activo que quieren formarse para reforzar su posición en el mercado laboral.', '2026-08-28 17:30:50.588849+00'),
	('b3d52084-5a84-426a-80c8-97cb7d3cefc0', 'es', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Apoyo a inversiones que aumentan la competitividad o reducen el impacto ambiental en empresas agrícolas.', '2026-08-28 17:30:50.588849+00'),
	('9f06dc9c-3768-4243-8ac9-ac425fb01b69', 'es', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Apoyo cuando un hijo vive con usted y el otro progenitor no paga la pensión alimenticia.', '2026-08-28 17:30:50.588849+00'),
	('87c1daa9-4ea9-4c96-8bcb-bf3904512652', 'es', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Apoyo a proyectos de organizaciones sin ánimo de lucro por las personas, el medio ambiente y un mundo mejor.', '2026-08-28 17:30:50.588849+00'),
	('7fcfd4c8-91c3-43d4-8151-c031d287d45e', 'es', 'Är projektet till nytta för bygden i stort (inte enskilda)?', '¿El proyecto beneficia a la comarca en su conjunto (no a particulares)?', '2026-08-28 17:30:50.592405+00'),
	('8a04f1d8-da64-44dd-b8d8-bf3c56b46e30', 'es', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Apoyo a proyectos culturales innovadores que exploran nuevas expresiones, métodos o colaboraciones artísticas.', '2026-08-28 17:30:50.588849+00');
INSERT INTO public.kb_translations VALUES
	('ed5c035c-50ed-4c2f-8bd5-32bd3c1b58fd', 'es', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Apoyo a proyectos innovadores para niños, jóvenes, mayores y personas con discapacidad.', '2026-08-28 17:30:50.588849+00'),
	('7592ac5b-ba39-4ca5-8cb5-4e995d82bd41', 'es', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Apoyo a proyectos de cooperación en la escena musical independiente.', '2026-08-28 17:30:50.588849+00'),
	('45472b69-4b35-4962-91b6-bbe849d934e6', 'es', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Apoyo a proyectos de cooperación en cultura y medios que refuerzan la democracia y la libertad de expresión a nivel internacional.', '2026-08-28 17:30:50.588849+00'),
	('d36db17b-80ae-41b5-9b3c-b6c793d5ede9', 'es', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', '¿El proyecto busca reforzar la democracia, la igualdad o la libertad de expresión?', '2026-08-28 17:30:50.588849+00'),
	('b743ebcf-c6c1-4f90-999d-bff7248b4876', 'es', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', '¿Busca trabajo, o ha recibido una oferta de trabajo, en otro país de la UE o del EEE?', '2026-08-28 17:30:50.588849+00'),
	('6d5b3e9a-b3bc-4255-b95f-25f828db91b3', 'es', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Tope de lo que debe pagar en tasas sanitarias durante un periodo de doce meses — después, frikort (tarjeta gratuita).', '2026-08-28 17:30:50.588849+00'),
	('7f97cf72-11da-4919-aa70-e1ed7a54bf94', 'es', 'Tar du ut hel allmän pension?', '¿Cobra la pensión pública completa?', '2026-08-28 17:30:50.588849+00'),
	('d823f570-4a3e-4575-9541-0a3f318db975', 'es', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Suplemento que cubre parte del gasto de vivienda para quien tiene pensión e ingresos bajos.', '2026-08-28 17:30:50.588849+00'),
	('9706edad-6f97-476e-b39c-e5288c8951fd', 'es', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Subvención anual de organización para organizaciones nacionales de infancia y juventud.', '2026-08-28 17:30:50.588849+00'),
	('856153ff-5480-4c26-acfd-ce6979aa359f', 'es', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Saldo anual que se descuenta directamente en el dentista o el higienista dental.', '2026-08-28 17:30:50.588849+00'),
	('92688bbe-b0e0-406d-9804-a0a498f26fa4', 'es', 'Är bolaget yngre än cirka 5 år?', '¿La empresa tiene menos de unos 5 años?', '2026-08-28 17:30:50.588849+00'),
	('ce86aab4-7422-42e9-ab72-b7880fe67b05', 'es', 'Är deltagarna i utbytet mellan 13 och 30 år?', '¿Los participantes del intercambio tienen entre 13 y 30 años?', '2026-08-28 17:30:50.588849+00'),
	('a01d022e-20a3-4375-8d92-6e4e375a1e6c', 'es', 'Är det här ert första EU-projekt?', '¿Es este su primer proyecto de la UE?', '2026-08-28 17:30:50.588849+00'),
	('64b74db0-ebf6-43e0-9991-6a2e2ca22950', 'es', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', '¿Le resulta muy difícil (a usted o a su hijo) desplazarse por su cuenta o viajar en autobús y tren?', '2026-08-28 17:30:50.588849+00'),
	('1deaec0a-17c4-4dde-9129-10e8e57f2e87', 'es', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', '¿Sus ingresos son inferiores a unas 25 000 kr al mes antes de impuestos?', '2026-08-28 17:30:50.588849+00'),
	('c770430d-86c2-4544-a856-a1d250006562', 'es', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', '¿Su última formación terminada es la escuela obligatoria, o un instituto que no completó?', '2026-08-28 17:30:50.588849+00'),
	('82de7907-3274-45c4-ad01-8321ca3a483b', 'es', 'Är du 40 år eller yngre?', '¿Tiene 40 años o menos?', '2026-08-28 17:30:50.588849+00'),
	('d5159d1e-a75e-4e0e-a70d-f32b22f9f08d', 'es', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', '¿Está inscrito como demandante de empleo en Arbetsförmedlingen?', '2026-08-28 17:30:50.588849+00'),
	('089d2522-eeb5-4b44-bc59-901dd3d52949', 'es', 'Är du mellan 18 och 28 år?', '¿Tiene entre 18 y 28 años?', '2026-08-28 17:30:50.588849+00'),
	('34691e68-afdf-4175-8402-4e2654c066fc', 'es', 'Är du mellan 19 och 29 år?', '¿Tiene entre 19 y 29 años?', '2026-08-28 17:30:50.588849+00'),
	('d681c119-3b7f-4c57-8006-8aee8c039386', 'es', 'Är du mellan 25 och 60 år?', '¿Tiene entre 25 y 60 años?', '2026-08-28 17:30:50.588849+00'),
	('826f239c-b74b-4460-9185-50fc06aa2082', 'es', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', '¿Trabaja profesionalmente en el sector cultural (p. ej. danza, música, artes escénicas)?', '2026-08-28 17:30:50.588849+00'),
	('2700ef97-d127-449c-883d-12fdf8d72e7e', 'es', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', '¿Es artista profesional (no aficionado ni en formación básica)?', '2026-08-28 17:30:50.588849+00'),
	('fc41f16f-0797-4744-a8d7-3cd43a8bfcb0', 'es', 'Är du yrkesverksam konstnär?', '¿Es artista profesional?', '2026-08-28 17:30:50.588849+00'),
	('d5307e39-6026-4c29-b6ac-ec1ca37a1d5d', 'es', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', '¿Su solución es sustancialmente innovadora en comparación con lo que ya existe?', '2026-08-28 17:30:50.592405+00'),
	('ca036bb0-99da-4082-b8f0-35aef2a351db', 'es', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', '¿El club está afiliado a una federación deportiva especializada dentro de Riksidrottsförbundet?', '2026-08-28 17:30:50.592405+00'),
	('7e5325a7-57e1-40a3-acb2-7853ee78c013', 'es', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', '¿Los ingresos del hogar son bajos en relación con el gasto de vivienda?', '2026-08-28 17:30:50.592405+00'),
	('9e329ad1-7907-4db2-8505-fd6683af83fc', 'es', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', '¿Los ingresos conjuntos del hogar son inferiores a unas 25 000 kr al mes antes de impuestos?', '2026-08-28 17:30:50.592405+00'),
	('8cc42c46-ca05-41a3-8c15-9085294bd55b', 'es', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', '¿La acción es un proyecto delimitado (no la actividad ordinaria)?', '2026-08-28 17:30:50.592405+00'),
	('df39a160-2472-4586-b951-3947fb24624b', 'es', 'Är lokalen öppen för alla — inte bara egna medlemmar?', '¿El local está abierto a todos — no solo a los propios socios?', '2026-08-28 17:30:50.592405+00'),
	('2d18ed23-f1c1-4bec-be76-f0318c527559', 'es', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', '¿Al menos el 60 % de los miembros tienen entre 6 y 25 años?', '2026-08-28 17:30:50.592405+00'),
	('a5fa0571-eb35-4f57-9eec-a31373566a11', 'es', 'Är minst 60 % av medlemmarna under 26 år?', '¿Al menos el 60 % de los miembros tienen menos de 26 años?', '2026-08-28 17:30:50.592405+00'),
	('2fc2c6ac-0844-4db3-b257-16d286c38fc1', 'es', 'Är målgruppen delaktig i planering och genomförande?', '¿El grupo destinatario participa en la planificación y la ejecución?', '2026-08-28 17:30:50.592405+00'),
	('4a8cb30f-fa3d-49c6-b751-3b56bdf6ca5b', 'es', 'Är ni ett förlag med professionell utgivning?', '¿Son una editorial con publicación profesional?', '2026-08-28 17:30:50.592405+00'),
	('85d4143e-9c91-4662-88b3-734b4796ffa5', 'es', 'Är ni huvudman för förskoleklass eller grundskola?', '¿Son titulares de una clase de preescolar o de una escuela obligatoria?', '2026-08-28 17:30:50.592405+00'),
	('9ce3eed8-53d3-455f-b34c-2708f74533e2', 'es', 'Är organisationen registrerad i EU:s deltagarregister?', '¿La organización está registrada en el registro de participantes de la UE?', '2026-08-28 17:30:50.592405+00'),
	('005e8830-63b4-4bce-9404-d15beb73e663', 'es', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', '¿El proyecto es un proyecto de cine (cortometraje o documental)?', '2026-08-28 17:30:50.592405+00'),
	('f064e3c1-bb5b-4284-9b9f-ac50a015c1b7', 'es', 'Är projektet ett konst- eller kulturprojekt?', '¿El proyecto es un proyecto de arte o cultura?', '2026-08-28 17:30:50.592405+00'),
	('3ce83113-2a2a-487f-b226-9e7be20c2b05', 'es', 'Är projektet ett kulturprojekt?', '¿El proyecto es un proyecto cultural?', '2026-08-28 17:30:50.592405+00'),
	('8072d84e-0757-4947-bbde-795ee4633e77', 'es', 'Är projektet ett musikprojekt?', '¿El proyecto es un proyecto musical?', '2026-08-28 17:30:50.592405+00'),
	('2a1fac55-6b1b-46cf-9597-d6e139f6d1c5', 'es', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', '¿El proyecto es innovador — algo que no hacen ya en su actividad ordinaria?', '2026-08-28 17:30:50.592405+00'),
	('0e210338-d0fd-45d3-a2dc-d832bdb2668a', 'es', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', '¿El trayecto entre la vivienda y el instituto es de al menos seis kilómetros?', '2026-08-28 17:30:50.592405+00'),
	('dc31b04c-9318-4f91-b848-6294c3eab3f4', 'es', 'Är verksamheten professionell (inte amatörverksamhet)?', '¿La actividad es profesional (no de aficionados)?', '2026-08-28 17:30:50.592405+00'),
	('42d0cb7f-d9c6-4925-90de-5bede52e2f2d', 'es', 'Är verksamheten professionell?', '¿La actividad es profesional?', '2026-08-28 17:30:50.592405+00'),
	('ad37579b-31d3-4793-9048-7cc777980a61', 'es', 'Är verksamheten scenkonst (dans, teater, musikteater)?', '¿La actividad es de artes escénicas (danza, teatro, teatro musical)?', '2026-08-28 17:30:50.592405+00'),
	('bb2bf643-010d-4991-bc7e-7db7a2c67299', 'es', 'Är volontärerna mellan 18 och 30 år?', '¿Los voluntarios tienen entre 18 y 30 años?', '2026-08-28 17:30:50.592405+00'),
	('8761b21f-b075-4a9e-9d4a-8bc3c88edee4', 'fr', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Aide aux activités pour les clubs sportifs proposant des activités encadrées pour les enfants et les jeunes de 7 à 25 ans.', '2026-08-28 17:30:50.597173+00'),
	('7f57fbca-72b9-4876-9e7a-f77be86a9007', 'fr', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Complément automatique à l''allocation pour enfant (barnbidrag) à partir du deuxième enfant.', '2026-08-28 17:30:50.597173+00'),
	('2efff95e-dac6-41b9-8404-544027c05983', 'fr', 'Avser ansökan en fysisk investering?', 'La demande concerne-t-elle un investissement physique ?', '2026-08-28 17:30:50.597173+00'),
	('a99b73bd-feb3-48d2-b262-1a93623dcae1', 'fr', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'La demande concerne-t-elle un voyage ou un échange international ?', '2026-08-28 17:30:50.597173+00');
INSERT INTO public.kb_translations VALUES
	('47679849-d922-40c7-97be-32ddcc380f63', 'fr', 'Avser ansökan en investering i byggnader eller maskiner?', 'La demande concerne-t-elle un investissement dans des bâtiments ou des machines ?', '2026-08-28 17:30:50.597173+00'),
	('6174fcf8-504a-4522-81a3-0475991b5166', 'fr', 'Avser ansökan en redan utgiven titel?', 'La demande concerne-t-elle un titre déjà publié ?', '2026-08-28 17:30:50.597173+00'),
	('52701b82-7df4-4a73-aa91-c9832680e684', 'fr', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'La demande concerne-t-elle une entreprise agricole, horticole ou d''élevage de rennes ?', '2026-08-28 17:30:50.597173+00'),
	('36d8ce12-41b1-41bc-9d52-888c9b35e93c', 'fr', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'La demande concerne-t-elle l''achat de littérature pour des bibliothèques publiques ou scolaires ?', '2026-08-28 17:30:50.597173+00'),
	('c1ff5e3b-de9e-41ce-a1ed-acf66bf87056', 'fr', 'Avser investeringen jordbruksverksamhet?', 'L''investissement concerne-t-il une activité agricole ?', '2026-08-28 17:30:50.597173+00'),
	('dfdfcc7f-2b63-448d-87e2-81ac561c0bbb', 'fr', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Le projet consiste-t-il à construire, acheter ou rénover un local ?', '2026-08-28 17:30:50.597173+00'),
	('0f909c59-c467-4a4c-a6be-40971eee8c4b', 'fr', 'Avser projektet naturvård eller friluftsliv?', 'Le projet concerne-t-il la protection de la nature ou les activités de plein air ?', '2026-08-28 17:30:50.597173+00'),
	('1e286735-6f2f-4a87-bc21-719d4fe8cdeb', 'fr', 'Avser projektet skola eller vuxenutbildning?', 'Le projet concerne-t-il l''école ou la formation des adultes ?', '2026-08-28 17:30:50.597173+00'),
	('d15498f9-e7b7-4c55-8920-8a56a60843bf', 'fr', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Renoncez-vous à travailler pour soigner ou être auprès d''un proche si gravement malade que la maladie menace sa vie ?', '2026-08-28 17:30:50.597173+00'),
	('eb93f851-e19e-4082-9e93-4b5880747008', 'fr', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'L''association mène-t-elle des activités régulières dans la commune ?', '2026-08-28 17:30:50.597173+00'),
	('1e766425-e8d8-47d1-ae08-be243a85b13b', 'fr', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Estimez-vous que votre capacité de travail est réduite pendant au moins un an en raison d''une maladie ou d''un handicap ?', '2026-08-28 17:30:50.597173+00'),
	('ebb36051-c14d-42c9-bd68-2bedc90ca86e', 'fr', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Aide soumise à conditions de ressources pour ceux qui ont une pension faible ou nulle et ont besoin d''aide pour atteindre un niveau de vie raisonnable.', '2026-08-28 17:30:50.597173+00'),
	('edfe307f-52b7-4ad3-ac1e-8a663bf60daa', 'fr', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'L''enfant doit-il habiter sur le lieu d''études (hébergement) parce que le trajet est trop long ?', '2026-08-28 17:30:50.597173+00'),
	('d6878954-b56a-4899-a36a-5229698f5d17', 'fr', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Le logement doit-il être adapté (p. ex. rampe, ouvre-porte, salle de bain) ?', '2026-08-28 17:30:50.597173+00'),
	('fb8f780c-51ca-44f7-8377-70ab957f028c', 'fr', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'L''un de vos enfants de 8 à 19 ans a-t-il besoin de lunettes ou de lentilles ?', '2026-08-28 17:30:50.597173+00'),
	('f0fe90a7-affd-402d-a8a7-df9d50c3d3c9', 'fr', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'L''autre parent ne paie-t-il rien, ou moins que la pension alimentaire complète ?', '2026-08-28 17:30:50.597173+00'),
	('e856527e-aa0e-4f04-8bbb-02da913e4f93', 'fr', 'Betalar du hyra eller andra boendekostnader?', 'Payez-vous un loyer ou d''autres frais de logement ?', '2026-08-28 17:30:50.597173+00'),
	('86879575-23c4-4053-ac79-6d2dec4d0ec0', 'fr', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Aide pour adapter le logement en cas de handicap — p. ex. rampes, ouvre-portes ou aménagement de la salle de bain.', '2026-08-28 17:30:50.597173+00'),
	('04154a7b-7d04-41b8-88fc-07adb6aaee8b', 'fr', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Aides pour construire, acheter ou rénover des salles de réunion publiques.', '2026-08-28 17:30:50.597173+00'),
	('3585ed7f-2e97-47cf-914d-aeb8f18ea0ae', 'fr', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Aide pour acheter ou adapter une voiture lorsqu''un handicap durable rend très difficile de se déplacer ou de prendre les transports en commun.', '2026-08-28 17:30:50.597173+00'),
	('b696c8f6-26c0-4f48-9e3d-a9dc516f01f1', 'fr', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Aides aux voyages et échanges internationaux pour les professionnels du secteur culturel.', '2026-08-28 17:30:50.597173+00'),
	('a75bbbdf-0576-4b5c-b483-18f66f4f91da', 'fr', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Aides aux échanges internationaux, voyages et séjours de travail des artistes professionnels.', '2026-08-28 17:30:50.597173+00'),
	('70ddc9fb-fd7e-46d7-ada8-496db51c8d4b', 'fr', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Bourse et prêt facultatif pour des études de niveau secondaire supérieur ou post-secondaire.', '2026-08-28 17:30:50.597173+00'),
	('ef1b40ab-d7d2-4402-8a04-7f5e9b8a2895', 'fr', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Bourses et prêts pour étudier à l''étranger, avec des prêts complémentaires pour p. ex. les frais de scolarité et les voyages.', '2026-08-28 17:30:50.597173+00'),
	('7de0d0c3-d912-4a25-bc7f-5c28c1a5d7d6', 'fr', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Aide qui accompagne les acteurs suédois dans la préparation de candidatures aux programmes de l''UE comme Horisont Europa.', '2026-08-28 17:30:50.597173+00'),
	('bc570bb5-e3d0-4262-9a36-1a7cd16afb66', 'fr', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Aide aux employeurs qui embauchent des personnes à capacité de travail réduite.', '2026-08-28 17:30:50.597173+00'),
	('1b1bcfa5-78e2-415d-b985-460937a28d6e', 'fr', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Aide au logement et aux voyages de retour lorsqu''un lycéen doit habiter sur le lieu d''études en raison d''un long trajet.', '2026-08-28 17:30:50.597173+00'),
	('8e97d3ab-4b3d-474b-9b5f-398749bef721', 'uk', 'Är projektet ett musikprojekt?', 'Це музичний проєкт?', '2026-08-28 17:30:50.646065+00'),
	('a9f9d482-cc5d-40a5-8380-c42d652e9661', 'fr', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Aides au travail des organisations à but non lucratif pour préserver, utiliser et développer le patrimoine culturel.', '2026-08-28 17:30:50.597173+00'),
	('d3bfa3cb-31ba-4fef-a846-957ff2f4eb86', 'fr', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Aides aux projets communaux et locaux de protection de la nature, y compris les zones humides et les activités de plein air.', '2026-08-28 17:30:50.597173+00'),
	('eb03692b-02e2-48e2-b0d8-915f84910234', 'fr', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Aides aux communes pour l''achat de littérature destinée aux bibliothèques publiques et scolaires.', '2026-08-28 17:30:50.597173+00'),
	('a12934b5-fe27-4d18-8c52-e85d70123ed7', 'fr', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Aides aux responsables d''écoles pour la rencontre des élèves avec la culture professionnelle à l''école obligatoire.', '2026-08-28 17:30:50.597173+00'),
	('361628a0-df04-4864-98cf-dfea6dd7bf86', 'fr', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Aide pour ce dont votre enfant a besoin mais que le budget familial ne permet pas : loisirs, vêtements, sorties scolaires, lunettes, activités de vacances et plus.', '2026-08-28 17:30:50.597173+00'),
	('4cd598f2-30ae-4ba5-812e-3af5257d878e', 'fr', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Aides issues notamment de Världens Barn, Musikhjälpen et Victoriafonden — demandées par des organisations suédoises à but non lucratif titulaires d''un 90-konto.', '2026-08-28 17:30:50.597173+00'),
	('5ad55065-91ad-4dd1-9bef-86e4f99c8cde', 'fr', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Aides issues des fonds hydroélectriques et éoliens pour des projets qui développent le territoire.', '2026-08-28 17:30:50.597173+00'),
	('05fed48a-d2c4-456e-8fb6-709f3354d970', 'fr', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Bourse sans part de prêt pour les demandeurs d''emploi de 25 à 60 ans ayant une scolarité courte et devant étudier au niveau du collège ou du lycée.', '2026-08-28 17:30:50.597173+00'),
	('c119e80c-7c54-4ce6-8d1e-179b10ee7c2f', 'fr', 'Bidrar projektet till energiomställningen?', 'Le projet contribue-t-il à la transition énergétique ?', '2026-08-28 17:30:50.597173+00'),
	('bb15f182-3c88-4bcc-82c4-4745c0321a23', 'fr', 'Bor du och barnets andra förälder på skilda håll?', 'Vous et l''autre parent de l''enfant vivez-vous séparément ?', '2026-08-28 17:30:50.597173+00'),
	('004727ee-23f6-4f36-b784-7a8b4b28decc', 'fr', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Chèques pour les petites entreprises afin de faire appel à des compétences externes pour l''internationalisation ou la numérisation.', '2026-08-28 17:30:50.597173+00'),
	('a73ea524-403a-4dc6-8130-1adff57a5a1f', 'fr', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Participez-vous à un programme d''Arbetsförmedlingen (p. ex. jobb- och utvecklingsgarantin) ?', '2026-08-28 17:30:50.597173+00'),
	('37d33b34-2e2a-43db-b506-7c13f5654c42', 'fr', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Soutien a posteriori aux maisons d''édition pour la publication de littérature de qualité.', '2026-08-28 17:30:50.597173+00'),
	('5ca32065-b38b-462f-8c8a-8e2207f1e244', 'fr', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Aide financière pour ceux qui ont un permis de séjour lié à la protection et souhaitent volontairement retourner définitivement dans leur pays d''origine.', '2026-08-28 17:30:50.597173+00'),
	('1d340833-5f51-47a7-8d7f-1c7ea6cc450a', 'fr', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Aide financière aux employeurs qui embauchent une personne longtemps éloignée de la vie professionnelle.', '2026-08-28 17:30:50.597173+00'),
	('fa1d7c33-420f-4a7a-bf09-d4b11ab98829', 'fr', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Aide financière pendant la phase de démarrage pour les demandeurs d''emploi qui créent leur entreprise.', '2026-08-28 17:30:50.597173+00'),
	('fe778d8f-d2fb-4619-a24c-bcc5a2bce7ec', 'fr', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten ouvre en continu des appels à projets en recherche énergétique, innovation et efficacité énergétique.', '2026-08-28 17:30:50.597173+00'),
	('3e1f0e83-20b5-4e47-9e8f-a7c4a299ec12', 'fr', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Indemnité pour s''absenter du travail ou des études afin de s''occuper d''un enfant.', '2026-08-28 17:30:50.597173+00'),
	('6c7cb737-e624-4a2a-b112-6575dd18f008', 'fr', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Indemnité pour ceux qui sont nouveaux en Suède et participent au programme d''établissement d''Arbetsförmedlingen ; versée par Försäkringskassan.', '2026-08-28 17:30:50.597173+00'),
	('701812c9-2ed6-48b4-8fe6-7f071b633685', 'fr', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Indemnité couvrant une partie du coût du logement pour les jeunes sans enfants à faibles revenus.', '2026-08-28 17:30:50.597173+00'),
	('6b78c0b8-3aaf-41df-aff3-d2118bf5e41e', 'fr', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Indemnité pour les surcoûts qu''entraîne un handicap durable — pour les adultes, ou pour les parents d''enfants handicapés.', '2026-08-28 17:30:50.597173+00'),
	('0cdba826-3a7f-4cd9-8ec7-c23f7961cf29', 'fr', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Indemnité pour les jeunes (19–29 ans) qui ne peuvent pas travailler à plein temps pendant au moins un an pour cause de maladie ou de handicap.', '2026-08-28 17:30:50.597173+00');
INSERT INTO public.kb_translations VALUES
	('b14c1702-bad2-4207-8f26-caae8d633044', 'fr', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Indemnité lorsque la capacité de travail est durablement réduite — anciennement appelée förtidspension (retraite anticipée).', '2026-08-28 17:30:50.597173+00'),
	('3d895a05-f851-4a2f-beb1-e849fabd6ba8', 'fr', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Indemnité lorsque vous renoncez à travailler pour être auprès d''un proche gravement malade.', '2026-08-28 17:30:50.597173+00'),
	('2d7e43f5-00db-4396-9da8-26ca4a256df8', 'fr', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Indemnité lorsque vous participez à un programme de politique de l''emploi d''Arbetsförmedlingen.', '2026-08-28 17:30:50.597173+00'),
	('735d80c7-4adc-4cb0-af97-75faa640bf7b', 'fr', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Indemnité lorsque vous ne pouvez pas travailler normalement pour cause de maladie.', '2026-08-28 17:30:50.597173+00'),
	('1a01dc62-0474-41cf-b287-b65862057ae1', 'fr', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Indemnité lorsque vous restez à la maison pour vous occuper d''un enfant malade.', '2026-08-28 17:30:50.597173+00'),
	('d3e87270-778b-4024-84cf-b430005ac12c', 'fr', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Indemnité couvrant une partie du coût du logement pour les ménages avec enfants et revenus modestes.', '2026-08-28 17:30:50.597173+00'),
	('4c1601a6-4571-40e0-87f4-4f537c268024', 'fr', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Indemnité pour les parents dont l''enfant, en raison d''un handicap, a besoin de plus de soins et de surveillance que les enfants du même âge.', '2026-08-28 17:30:50.597173+00'),
	('b4ff6403-0adc-4dd0-87f4-36638f7b12b6', 'fr', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Indemnité en cas de chômage — basée sur le revenu pour les membres, montant de base pour les autres.', '2026-08-28 17:30:50.597173+00'),
	('744838c6-eb23-4a95-94f7-c928bf37532c', 'fr', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Une cinquantaine de fondations de caisses d''épargne accordent des aides à des projets locaux de sport, culture, éducation et développement local — dans la zone d''activité de la caisse.', '2026-08-28 17:30:50.597173+00'),
	('b80f9636-4a85-44a1-8b8d-8791df7d5cb7', 'fr', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Aide aux projets financée par l''UE, demandée auprès de votre zone Leader locale — pour les associations, entreprises et communes qui développent les zones rurales.', '2026-08-28 17:30:50.597173+00'),
	('64dcf46c-86b4-4435-a621-7269de9ce74a', 'fr', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Aide financée par l''UE pour les demandeurs d''emploi qui prennent un poste dans un autre pays UE/EEE : remboursement du voyage d''entretien, des frais de déménagement et d''un cours de langue.', '2026-08-28 17:30:50.597173+00'),
	('8cd04968-a117-4c11-8740-de4f5053756f', 'fr', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Fonds du Fonds social européen pour des projets renforçant les compétences, la reconversion et l''inclusion sur le marché du travail.', '2026-08-28 17:30:50.597173+00'),
	('34bae435-f96d-4773-bffd-95030eda3cc3', 'fr', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Aide de l''UE pour des échanges de groupes de jeunes de 13 à 30 ans, de 5 à 21 jours hors jours de voyage.', '2026-08-28 17:30:50.597173+00'),
	('a5e59c99-6f4a-4506-9b8d-305d375c51e5', 'fr', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Aide de l''UE pour les projets de coopération d''organisations culturelles avec des partenaires dans plusieurs pays européens.', '2026-08-28 17:30:50.597173+00'),
	('f4cc2117-07bb-4b6a-a18b-f74e338a8606', 'fr', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Aide de l''UE pour les organisations qui accueillent ou envoient de jeunes volontaires de 18 à 30 ans.', '2026-08-28 17:30:50.597173+00'),
	('425ab616-8189-4ab8-aeb4-c5d9919e9ce0', 'fr', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Aide de l''UE pour la mobilité du personnel et des élèves dans l''école et la formation des adultes.', '2026-08-28 17:30:50.597173+00'),
	('e11a8191-1243-4e59-837c-e78e312fe4bd', 'fr', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Aide de l''UE avec des montants forfaitaires pour les premiers projets européens de coopération des petites organisations.', '2026-08-28 17:30:50.597173+00'),
	('c60ceb8c-180d-4f88-8343-f3d91f702743', 'fr', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Financement pour les jeunes entreprises développant des produits ou services innovants à potentiel international.', '2026-08-28 17:30:50.597173+00'),
	('4297635c-05db-42ac-b424-f1aad33d9bc3', 'fr', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Y a-t-il une caisse d''épargne (et donc une fondation de caisse d''épargne) là où vous exercez votre activité ?', '2026-08-28 17:30:50.597173+00'),
	('8ba4a955-f8ff-4f0f-8d84-0804f03d4d43', 'fr', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Aides de fonctionnement pluriannuelles pour les compagnies professionnelles indépendantes de danse, théâtre et théâtre musical.', '2026-08-28 17:30:50.597173+00'),
	('e1985bae-14e0-4504-b509-466a51fd2894', 'fr', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Aides à la recherche dans les domaines de Forte : santé, vie professionnelle et protection sociale. Demandées par des chercheurs titulaires d''un doctorat dans les universités suédoises.', '2026-08-28 17:30:50.597173+00'),
	('42a712de-f0cc-475d-8e47-0a001694cf86', 'fr', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Financement de la recherche fondamentale libre dans tous les domaines scientifiques.', '2026-08-28 17:30:50.597173+00'),
	('e8441fe9-7719-429e-b469-c63364f2e4ed', 'fr', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Financement de la recherche en environnement, sciences agricoles et aménagement du territoire.', '2026-08-28 17:30:50.597173+00'),
	('528dabe7-47b0-47ce-8e1c-10757b862e80', 'fr', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Envisagez-vous de vous installer à l''étranger (travail, études ou retour au pays) ?', '2026-08-28 17:30:50.597173+00'),
	('72cb61bc-2269-43ef-a4fb-5dfdf101eede', 'fr', 'Genomförs insatserna av professionella kulturaktörer?', 'Les activités sont-elles menées par des acteurs culturels professionnels ?', '2026-08-28 17:30:50.597173+00'),
	('4cf6144f-4b74-4e87-a60f-580dafa83477', 'fr', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Le projet se déroule-t-il en zone rurale ou dans une petite localité ?', '2026-08-28 17:30:50.597173+00'),
	('6a1a4790-8824-4f7f-8f62-7f48c92501ca', 'fr', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Protection de base pour ceux qui ont eu peu ou pas de revenus du travail au cours de leur vie.', '2026-08-28 17:30:50.597173+00'),
	('96a8fc17-eebf-48bd-963b-6b9afa730fdc', 'fr', 'Går något av dina barn i grundskolan?', 'L''un de vos enfants est-il à l''école obligatoire ?', '2026-08-28 17:30:50.597173+00'),
	('10daeada-9249-4770-9480-697a91b4fa29', 'fr', 'Går något av dina barn på gymnasiet?', 'L''un de vos enfants est-il au lycée ?', '2026-08-28 17:30:50.597173+00'),
	('2bb9899a-aed4-443a-8baa-54c42cb3cbd1', 'fr', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'L''embauche concerne-t-elle une personne à capacité de travail réduite ?', '2026-08-28 17:30:50.597173+00'),
	('005db11a-be64-4763-af9c-36ba96915d8c', 'fr', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'L''embauche concerne-t-elle une personne longtemps au chômage ou nouvelle en Suède ?', '2026-08-28 17:30:50.597173+00'),
	('360764e6-0beb-45bf-b078-9e7554b40e5d', 'fr', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Le projet vise-t-il à préserver ou à rendre accessible le patrimoine culturel ?', '2026-08-28 17:30:50.597173+00'),
	('98e05b7d-ee22-4f83-96ca-5c7be9b56e29', 'fr', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Le projet porte-t-il sur l''énergie, l''efficacité énergétique ou l''innovation énergétique ?', '2026-08-28 17:30:50.597173+00'),
	('45fd78ae-2093-4fce-ae15-8a46b1cb1e1e', 'fr', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Le projet porte-t-il sur la santé, la vie professionnelle ou la protection sociale ?', '2026-08-28 17:30:50.597173+00'),
	('e78d83d7-61bc-4761-991d-c6e0f9a28955', 'fr', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Le projet porte-t-il sur le développement des compétences ou des mesures pour l''emploi ?', '2026-08-28 17:30:50.597173+00'),
	('9a05c84f-4142-4ce9-a773-cc18be31dd36', 'fr', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Le projet porte-t-il sur des mesures environnementales ou climatiques ?', '2026-08-28 17:30:50.597173+00'),
	('55001c48-079e-4520-87f2-96775746942d', 'fr', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'L''enfant a-t-il un chemin vers l''école long, dangereux à cause de la circulation ou difficile d''une autre manière ?', '2026-08-28 17:30:50.597173+00'),
	('dba5c872-e323-4534-9a04-93a2b79670cf', 'fr', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Avez-vous travaillé au moins 16 heures par semaine pendant au moins 8 ans au total ?', '2026-08-28 17:30:50.597173+00'),
	('0e5a6d00-591d-4454-acb1-0db4f0650d82', 'fr', 'Har du barn som bor hos dig, helt eller växelvis?', 'Avez-vous des enfants qui vivent chez vous, à plein temps ou en alternance ?', '2026-08-28 17:30:50.597173+00'),
	('404228b9-e0cb-4b09-96eb-86c11419d145', 'fr', 'Har du barn som bor hos dig?', 'Avez-vous des enfants qui vivent chez vous ?', '2026-08-28 17:30:50.597173+00'),
	('1b6db163-e61c-440d-a6a4-d7cfef980e42', 'fr', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Vous ou votre enfant avez-vous un handicap censé durer au moins un an ?', '2026-08-28 17:30:50.597173+00'),
	('f19553e7-46f0-49b2-87d4-8658322cdb6c', 'fr', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Vous ou quelqu''un du ménage avez-vous un handicap durable qui affecte le logement ?', '2026-08-28 17:30:50.597173+00'),
	('40112118-91fb-41de-a98e-9dbab56575b8', 'fr', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Vous ou un proche avez-vous un handicap ou une maladie de longue durée ou grave ?', '2026-08-28 17:30:50.597173+00'),
	('aef4ce0c-b869-4d04-a9cc-6df6d5f2f846', 'fr', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Avez-vous une maladie ou une blessure qui réduit actuellement votre capacité de travail ?', '2026-08-28 17:30:50.597173+00'),
	('64684140-17c0-4f83-b7bb-121844edf570', 'fr', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Avez-vous déjà eu du mal à payer une sortie scolaire, un voyage de classe ou une activité de loisir à laquelle votre enfant est censé participer ?', '2026-08-28 17:30:50.597173+00'),
	('49a6ed66-6bfd-452f-89b6-cbfebf696b2a', 'fr', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Avez-vous du mal à vivre de votre pension et de vos autres revenus ?', '2026-08-28 17:30:50.597173+00'),
	('26142c1a-f64c-46e5-b62b-6ed4a90372f6', 'fr', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Avez-vous obtenu ces dernières années un permis de séjour en Suède, p. ex. comme personne à protéger ou comme membre de famille ?', '2026-08-28 17:30:50.597173+00'),
	('14b75073-3bb6-4ca7-ae86-48d1022e7809', 'fr', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Avez-vous un permis de séjour en Suède comme réfugié ou personne à protéger (ou êtes-vous un proche de quelqu''un qui en a un) ?', '2026-08-28 17:30:50.597173+00'),
	('8aa99e9b-5cc4-482b-9ee1-b5ee06770c6f', 'fr', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Avez-vous atteint l''âge de référence de la retraite (67 ans en 2026) ?', '2026-08-28 17:30:50.597173+00'),
	('73edbf56-f7d1-48d1-9b44-246882f01d83', 'fr', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Votre organisation a-t-elle un OID (Organisation ID) enregistré dans l''Organisation Registration System de l''UE ?', '2026-08-28 17:30:50.597173+00');
INSERT INTO public.kb_translations VALUES
	('e8624b9d-a8f2-473a-82d3-8254a40457a0', 'fr', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Le handicap a-t-il entraîné des surcoûts — p. ex. aides techniques, déplacements, régime particulier ou usure ?', '2026-08-28 17:30:50.597173+00'),
	('b99dc071-3007-4653-a064-10e831e712e9', 'fr', 'Har föreningen antagna stadgar och en vald styrelse?', 'L''association a-t-elle des statuts adoptés et un conseil d''administration élu ?', '2026-08-28 17:30:50.597173+00'),
	('958121af-d357-41ad-9cca-ebf405967516', 'fr', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'L''association a-t-elle une structure démocratique (statuts, assemblée annuelle, conseil) ?', '2026-08-28 17:30:50.597173+00'),
	('811a4943-bd45-44e2-ba21-62a44d2afa6e', 'fr', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'L''association mène-t-elle des activités régulières pour les enfants ou les jeunes ?', '2026-08-28 17:30:50.597173+00'),
	('9518a404-7135-4165-93a7-c5aa04600654', 'fr', 'Har företaget mellan cirka 2 och 49 anställda?', 'L''entreprise compte-t-elle entre environ 2 et 49 salariés ?', '2026-08-28 17:30:50.597173+00'),
	('ee20823f-aee6-489b-9362-dd62d1581301', 'fr', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Le ménage a-t-il du mal à couvrir les dépenses de nourriture, de logement et de première nécessité ?', '2026-08-28 17:30:50.597173+00'),
	('e05759b4-e861-41c4-99cf-aadab60ea8e7', 'fr', 'Har lösningen internationell potential?', 'La solution a-t-elle un potentiel international ?', '2026-08-28 17:30:50.597173+00'),
	('bfc5a7a8-2d82-40e2-87c4-da5ce78898a1', 'fr', 'Har ni en partnergrupp i ett annat land?', 'Avez-vous un groupe partenaire dans un autre pays ?', '2026-08-28 17:30:50.597173+00'),
	('6d0dc24d-8819-408e-968f-0f200bcb9a1f', 'fr', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Avez-vous une organisation partenaire dans un autre pays européen ?', '2026-08-28 17:30:50.597173+00'),
	('1d53899e-abb4-4eb1-bb1d-bf06018d8af1', 'fr', 'Har ni partner i minst tre olika europeiska länder?', 'Avez-vous des partenaires dans au moins trois pays européens différents ?', '2026-08-28 17:30:50.597173+00'),
	('bc092b9d-c3bf-412b-bd3c-db4de9be3868', 'fr', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Votre siège ou votre activité principale se trouve-t-il dans la région où vous déposez la demande ?', '2026-08-28 17:30:50.597173+00'),
	('673db040-daeb-4479-97f0-c1c467120963', 'fr', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'L''un de vos enfants a-t-il un handicap qui fait qu''il a besoin de plus de soins ou de surveillance que les autres enfants du même âge ?', '2026-08-28 17:30:50.597173+00'),
	('2b973321-f61f-439e-b2dd-54c091abfd56', 'fr', 'Har organisationen en demokratisk uppbyggnad?', 'L''organisation a-t-elle une structure démocratique ?', '2026-08-28 17:30:50.597173+00'),
	('5ebaf5a9-6d59-45fb-b0c3-00064ab1db09', 'fr', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'L''organisation a-t-elle un Quality Label (label de qualité) ?', '2026-08-28 17:30:50.597173+00'),
	('8178945a-7ae0-46b6-90da-2f7a76c57a9b', 'fr', 'Har organisationen ett 90-konto?', 'L''organisation a-t-elle un 90-konto ?', '2026-08-28 17:30:50.597173+00'),
	('ccb9a9b1-7108-4a10-9712-0b3f67d72a70', 'fr', 'Har organisationen ett OID (Organisation ID)?', 'L''organisation a-t-elle un OID (Organisation ID) ?', '2026-08-28 17:30:50.597173+00'),
	('c40c7695-5406-481d-ab16-354fa25832e0', 'fr', 'Har organisationen ett OID?', 'L''organisation a-t-elle un OID ?', '2026-08-28 17:30:50.597173+00'),
	('ed2d2a3a-5e4b-457f-a762-baff688b982d', 'fr', 'Har organisationen medlemsföreningar i flera län?', 'L''organisation a-t-elle des associations membres dans plusieurs départements ?', '2026-08-28 17:30:50.597173+00'),
	('0e3e8320-e498-4f07-ac61-9a493f7e4969', 'fr', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'L''organisation a-t-elle des finances saines et une structure démocratique ?', '2026-08-28 17:30:50.597173+00'),
	('1db3eff0-16b4-4f79-b92c-b7c1f38d7b4a', 'fr', 'Har projektet en partner i ett annat land?', 'Le projet a-t-il un partenaire dans un autre pays ?', '2026-08-28 17:30:50.597173+00'),
	('44351860-074a-4e10-8edf-83424064d823', 'fr', 'Har projektledaren doktorsexamen?', 'Le responsable du projet est-il titulaire d''un doctorat ?', '2026-08-28 17:30:50.597173+00'),
	('4bf1e492-1b6a-41e6-a4a2-6a1799060653', 'fr', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Votre commune de résidence doit assurer les trajets quotidiens entre le domicile et le lycée lorsque le trajet fait au moins six kilomètres (p. ex. carte de bus).', '2026-08-28 17:30:50.597173+00'),
	('3bd1a831-a21d-4473-a02e-993fa2ba8d49', 'fr', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Êtes-vous en train d''acquérir ou d''équiper votre premier logement en Suède ?', '2026-08-28 17:30:50.597173+00'),
	('26b026df-3c75-4eb3-9f51-20f3b977213f', 'fr', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Le projet comprend-il un voyage ou un échange international ?', '2026-08-28 17:30:50.597173+00'),
	('8288642c-f64b-43e6-9228-2bd8c1992092', 'fr', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Aide à l''investissement pour les entreprises des zones aidées : bâtiments, machines et formation.', '2026-08-28 17:30:50.597173+00'),
	('98cbf55e-a1d4-4757-a377-3122c397cd6c', 'fr', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Aide à l''investissement pour des mesures réduisant les émissions de gaz à effet de serre.', '2026-08-28 17:30:50.597173+00'),
	('2fcff43e-45a1-49d7-b11d-ea1702dd4000', 'fr', 'Kan projektets miljönytta mätas?', 'Le bénéfice environnemental du projet peut-il être mesuré ?', '2026-08-28 17:30:50.597173+00'),
	('4d0a609d-77aa-47c4-b41a-019af5af1c21', 'fr', 'Kan åtgärdens utsläppsminskning beräknas?', 'La réduction d''émissions de la mesure peut-elle être calculée ?', '2026-08-28 17:30:50.597173+00'),
	('338615fa-16fb-429c-951d-3cd395db5c48', 'fr', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'L''organisation peut-elle avancer les coûts jusqu''au versement de l''aide ?', '2026-08-28 17:30:50.597173+00'),
	('c8f72e86-a3d0-4810-9fcd-223628659ea3', 'fr', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Les enseignements seront-ils utilisés dans votre activité en Suède ?', '2026-08-28 17:30:50.597173+00'),
	('e5a5d273-8a84-4743-9aa3-8a99741f8b62', 'fr', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'L''investissement ne commencera-t-il qu''après l''envoi de la demande ?', '2026-08-28 17:30:50.597173+00'),
	('33897f24-1496-4227-b9c7-b02ca0ef2384', 'fr', 'Kommer projektet människor i ert närområde till del?', 'Le projet profite-t-il aux habitants de votre territoire ?', '2026-08-28 17:30:50.597173+00'),
	('ceb967b3-25ca-4d0c-88d1-26a0b943d017', 'fr', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Le dernier filet de sécurité économique de la commune lorsque les revenus ne couvrent pas le strict nécessaire.', '2026-08-28 17:30:50.597173+00'),
	('45c85afa-4d17-440b-8132-e1e1cb918887', 'fr', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Les aides propres des communes à la vie associative locale : aide à l''activité par séance, aide aux locaux, aide au démarrage et plus.', '2026-08-28 17:30:50.597173+00'),
	('685296d0-7a15-489e-9a85-ab91b03e1078', 'fr', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Transport scolaire gratuit pour les élèves de l''école obligatoire en cas de longue distance, de trajet dangereux ou de handicap — un droit selon la loi scolaire.', '2026-08-28 17:30:50.597173+00'),
	('0b2b3c11-8e4e-43d3-8c74-6a4268b1df27', 'fr', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Aide légale pour des lunettes ou lentilles pour enfants et jeunes ; montants et démarches varient selon la région — vérifiez le niveau de votre région.', '2026-08-28 17:30:50.597173+00'),
	('3907eb06-5707-4861-a523-10cb146d9720', 'fr', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Le projet se situe-t-il dans un territoire concerné par l''hydroélectricité ou l''éolien ?', '2026-08-28 17:30:50.597173+00'),
	('362df807-d17d-463e-a872-52a79ae1cbdc', 'fr', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Le projet relève-t-il de l''environnement, des sciences agricoles ou de l''aménagement du territoire ?', '2026-08-28 17:30:50.597173+00'),
	('fac87112-41bf-445f-be5a-c763caac05d1', 'fr', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Le lieu d''activité est-il en zone d''aide A ou B (grande partie du Norrland et du Svealand intérieur) ?', '2026-08-28 17:30:50.597173+00'),
	('3d8ffb09-6f23-4bb2-95c2-34434a7edf5a', 'fr', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Prêt pour acheter le strict nécessaire d''un premier foyer en Suède — meubles, ustensiles et autre équipement de base.', '2026-08-28 17:30:50.597173+00'),
	('035e0f51-6014-4565-befc-c5f26e3a8321', 'fr', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Le projet réduit-il les émissions de procédés industriels ou crée-t-il des émissions négatives ?', '2026-08-28 17:30:50.597173+00'),
	('1d1e3298-0236-4f07-8c88-e417adb0c5ac', 'fr', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Allocation mensuelle pour les enfants vivant en Suède, de la naissance à 16 ans.', '2026-08-28 17:30:50.597173+00'),
	('eca0eb7c-0185-4107-b1a1-83795862ba8c', 'fr', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket propose des aides aux organisations, entreprises, associations, au secteur public et aux particuliers dans le domaine de l''environnement.', '2026-08-28 17:30:50.597173+00'),
	('287393b0-7693-40d7-a5bf-74b08d475d99', 'fr', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Envisagez-vous de retourner volontairement et définitivement dans votre pays d''origine ?', '2026-08-28 17:30:50.597173+00'),
	('e8b38283-3c33-4723-b1a3-154422493efd', 'fr', 'Planerar du att starta eget företag?', 'Envisagez-vous de créer votre propre entreprise ?', '2026-08-28 17:30:50.597173+00'),
	('302b8c26-135c-4045-9283-664b3407eb7d', 'fr', 'Planerar du att studera utomlands?', 'Envisagez-vous d''étudier à l''étranger ?', '2026-08-28 17:30:50.597173+00'),
	('038b803c-9963-4850-915e-ef821af69410', 'fr', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Envisagez-vous des études qui renforcent votre position sur le marché du travail ?', '2026-08-28 17:30:50.597173+00'),
	('d0b6e78d-a3b8-492f-8b0a-035875b82051', 'fr', 'Planerar ni att anställa?', 'Envisagez-vous d''embaucher ?', '2026-08-28 17:30:50.597173+00'),
	('beb7cda5-561a-498c-a92a-3affc1a9e26a', 'fr', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Envisagez-vous de candidater à un programme de l''UE (p. ex. Horisont Europa) ?', '2026-08-28 17:30:50.597173+00'),
	('c147db6d-45ab-49d8-8b2d-daeba7ec79fb', 'fr', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Aide à la production et au développement de courts métrages et de documentaires.', '2026-08-28 17:30:50.597173+00');
INSERT INTO public.kb_translations VALUES
	('653077da-85bb-4187-902b-3fc85178a580', 'fr', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Aides aux projets de la scène musicale indépendante : concerts, production et développement.', '2026-08-28 17:30:50.597173+00'),
	('424fe6d5-3dfe-4259-bd22-167177178a7a', 'fr', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Aides aux projets d''organisations à but non lucratif travaillant avec et pour les enfants et les jeunes.', '2026-08-28 17:30:50.597173+00'),
	('8fccf836-ea2c-4ae4-b70b-6106a17a7dac', 'fr', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Le projet explore-t-il de nouvelles expressions, méthodes ou collaborations artistiques ?', '2026-08-28 17:30:50.597173+00'),
	('5cab8296-b75f-4166-83de-f5abe77a75d7', 'fr', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'L''échange dure-t-il de 5 à 21 jours (hors jours de voyage) ?', '2026-08-28 17:30:50.597173+00'),
	('ecd00f76-de09-46fd-80a0-f24e1c925234', 'fr', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Les aides propres des régions aux projets et activités culturels, à côté des aides nationales de Kulturrådet.', '2026-08-28 17:30:50.597173+00'),
	('7efb8323-2d96-4698-a57b-a51994b6c432', 'fr', 'Riktar sig projektet till barn eller unga?', 'Le projet s''adresse-t-il aux enfants ou aux jeunes ?', '2026-08-28 17:30:50.597173+00'),
	('1efce736-cabe-4009-aa89-3ff42e8f64ff', 'fr', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Le projet s''adresse-t-il aux enfants, aux jeunes, aux personnes âgées ou aux personnes handicapées ?', '2026-08-28 17:30:50.597173+00'),
	('d2a1dc6e-407a-4d53-9499-a3725455523e', 'fr', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'L''activité s''adresse-t-elle aux enfants et aux jeunes (7–25 ans) ?', '2026-08-28 17:30:50.597173+00'),
	('06433679-9030-48b2-b9a7-1cdcf219a89f', 'fr', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Manquez-vous d''économies ou de biens pouvant couvrir les dépenses ?', '2026-08-28 17:30:50.597173+00'),
	('804d905f-5ee3-427e-9d4a-fe2f9d2d1494', 'fr', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Coopérez-vous avec des partenaires dans au moins deux autres pays nordiques ?', '2026-08-28 17:30:50.597173+00'),
	('b65a0751-7f50-4125-bf4e-2fcdbb7d89a8', 'fr', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Allez-vous faire appel à des compétences externes pour une action de développement ?', '2026-08-28 17:30:50.597173+00'),
	('45854171-0906-4c21-a8b2-34ea9cd9b729', 'fr', 'Sker mobiliteten till ett annat europeiskt land?', 'La mobilité se fait-elle vers un autre pays européen ?', '2026-08-28 17:30:50.597173+00'),
	('81bd95ef-a024-446c-9814-1dcf15ac93cc', 'fr', 'Startar du eller tar du över företaget för första gången?', 'Créez-vous ou reprenez-vous l''entreprise pour la première fois ?', '2026-08-28 17:30:50.597173+00'),
	('66decd8f-3367-409f-b71c-1dfe12fd52e5', 'fr', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Aide au démarrage pour ceux de 40 ans ou moins qui créent ou reprennent une exploitation agricole.', '2026-08-28 17:30:50.597173+00'),
	('dbce47a6-42be-4e0e-9449-ec3455ae885c', 'fr', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Bourse permettant aux artistes professionnels de se concentrer sur leur travail artistique.', '2026-08-28 17:30:50.597173+00'),
	('d04e9e4d-c7e3-4439-bde6-16e2be572e30', 'fr', 'Studerar du, eller planerar du att börja studera?', 'Étudiez-vous, ou prévoyez-vous de commencer des études ?', '2026-08-28 17:30:50.597173+00'),
	('d1267c69-3027-4c1d-8d9d-a55f14ffa5f5', 'fr', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Aide aux études pour les adultes en activité qui veulent se former afin de renforcer leur position sur le marché du travail.', '2026-08-28 17:30:50.597173+00'),
	('7bf180de-9f4d-4159-abc4-5332b2643d1c', 'fr', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Aide aux investissements qui renforcent la compétitivité ou réduisent l''impact environnemental des exploitations agricoles.', '2026-08-28 17:30:50.597173+00'),
	('c1532370-8bb0-4e39-b22b-58f2676ec7be', 'fr', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Aide lorsqu''un enfant vit chez vous et que l''autre parent ne paie pas de pension alimentaire.', '2026-08-28 17:30:50.597173+00'),
	('f88439e0-37ce-400d-a64d-94b9499392f9', 'fr', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Aide aux projets des organisations à but non lucratif pour les personnes, l''environnement et un monde meilleur.', '2026-08-28 17:30:50.597173+00'),
	('aa4476d2-52bb-461b-b609-c358f0e3f72a', 'fr', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Aide à la transition de l''industrie vers zéro émission de gaz à effet de serre.', '2026-08-28 17:30:50.597173+00'),
	('0eb0432e-44f7-4ebc-8d6b-9d0d989aea3f', 'fr', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Aide aux projets artistiques et culturels à dimension nordique et à coopération transfrontalière.', '2026-08-28 17:30:50.597173+00'),
	('75672156-39a8-4b33-9e2d-b9e086dcf969', 'fr', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Aide aux projets culturels novateurs explorant de nouvelles expressions, méthodes ou collaborations artistiques.', '2026-08-28 17:30:50.597173+00'),
	('d70fbd91-defc-4552-a996-3f7e13d571f2', 'fr', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Aide aux projets novateurs pour les enfants, les jeunes, les personnes âgées et les personnes handicapées.', '2026-08-28 17:30:50.597173+00'),
	('16923a0e-ac3d-4379-9985-597c4e86c7f6', 'fr', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Aide aux projets de coopération de la scène musicale indépendante.', '2026-08-28 17:30:50.597173+00'),
	('901d77aa-f787-44a3-ba04-facf8b6fba7c', 'fr', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Aide aux projets de coopération dans la culture et les médias qui renforcent la démocratie et la liberté d''expression à l''international.', '2026-08-28 17:30:50.597173+00'),
	('bb89935e-fc72-4468-baa9-814e77055289', 'fr', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Le projet vise-t-il à renforcer la démocratie, l''égalité ou la liberté d''expression ?', '2026-08-28 17:30:50.597173+00'),
	('23b6fd05-0375-442a-a5fe-ed922933ecec', 'fr', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Cherchez-vous un emploi, ou avez-vous reçu une offre d''emploi, dans un autre pays de l''UE ou de l''EEE ?', '2026-08-28 17:30:50.597173+00'),
	('a904f45d-6f6a-453d-ad4e-051f43e0f38e', 'fr', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Plafond de ce que vous payez en frais de patient sur une période de douze mois — ensuite, frikort (carte de gratuité).', '2026-08-28 17:30:50.597173+00'),
	('6cb03306-178c-4bba-afc1-18180268001e', 'fr', 'Tar du ut hel allmän pension?', 'Percevez-vous la totalité de votre pension publique ?', '2026-08-28 17:30:50.597173+00'),
	('2fe8f1df-0c6a-4149-bd28-41d2083d823b', 'fr', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Complément couvrant une partie du coût du logement pour ceux qui ont une pension et de faibles revenus.', '2026-08-28 17:30:50.597173+00'),
	('09b8ca52-837a-4062-922d-f1429e97d778', 'fr', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Subvention annuelle d''organisation pour les organisations nationales d''enfance et de jeunesse.', '2026-08-28 17:30:50.597173+00'),
	('0bebb13a-3042-4779-922e-04b75b58ec70', 'fr', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Avoir annuel déduit directement chez le dentiste ou l''hygiéniste dentaire.', '2026-08-28 17:30:50.597173+00'),
	('9aa9c020-b198-4d73-9142-0817005fb60c', 'fr', 'Är bolaget yngre än cirka 5 år?', 'L''entreprise a-t-elle moins d''environ 5 ans ?', '2026-08-28 17:30:50.597173+00'),
	('80f1c763-e80f-4140-aacd-623e1a48d838', 'fr', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Les participants à l''échange ont-ils entre 13 et 30 ans ?', '2026-08-28 17:30:50.597173+00'),
	('0db70a31-6d7a-498a-a1d5-0a2529124dbf', 'fr', 'Är det här ert första EU-projekt?', 'Est-ce votre premier projet UE ?', '2026-08-28 17:30:50.597173+00'),
	('dfaac6f1-3b1d-4b27-bfec-43fc3d211eb5', 'fr', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Est-il très difficile pour vous (ou votre enfant) de vous déplacer seul ou de voyager en bus et en train ?', '2026-08-28 17:30:50.597173+00'),
	('cc831b37-92ca-4e32-b9fc-67a53d552b6c', 'fr', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Vos revenus sont-ils inférieurs à environ 25 000 kr par mois avant impôt ?', '2026-08-28 17:30:50.597173+00'),
	('88bfd67d-a5e8-467e-bddf-e7fb6b16c3a1', 'fr', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Votre dernière formation achevée est-elle l''école obligatoire, ou un lycée que vous n''avez pas terminé ?', '2026-08-28 17:30:50.597173+00'),
	('3e2cf3f6-ef66-438e-b5cb-e3242221e1ca', 'fr', 'Är du 40 år eller yngre?', 'Avez-vous 40 ans ou moins ?', '2026-08-28 17:30:50.597173+00'),
	('72e457fb-f0f2-4bc1-bdfe-b72b460ec21a', 'fr', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Êtes-vous inscrit comme demandeur d''emploi auprès d''Arbetsförmedlingen ?', '2026-08-28 17:30:50.597173+00'),
	('6b618d74-a6ba-4664-bcea-0d440e33d65e', 'fr', 'Är du mellan 18 och 28 år?', 'Avez-vous entre 18 et 28 ans ?', '2026-08-28 17:30:50.597173+00'),
	('1e059b1b-d6f2-4f28-a6b6-ca3d45b7f95a', 'fr', 'Är du mellan 19 och 29 år?', 'Avez-vous entre 19 et 29 ans ?', '2026-08-28 17:30:50.597173+00'),
	('9a6a905d-f362-49b7-9722-08ec67462358', 'fr', 'Är du mellan 25 och 60 år?', 'Avez-vous entre 25 et 60 ans ?', '2026-08-28 17:30:50.597173+00'),
	('6f8a941a-255d-4a57-a48e-4458cbef0cbd', 'fr', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Exercez-vous professionnellement dans le secteur culturel (p. ex. danse, musique, arts de la scène) ?', '2026-08-28 17:30:50.597173+00'),
	('480b886f-ee2d-4d10-91c9-23d31c4defad', 'fr', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Êtes-vous un artiste professionnel (ni amateur ni en formation initiale) ?', '2026-08-28 17:30:50.597173+00'),
	('fde67da0-13f0-46e2-ade3-c7d5ba81e60e', 'fr', 'Är du yrkesverksam konstnär?', 'Êtes-vous un artiste professionnel ?', '2026-08-28 17:30:50.597173+00'),
	('292eaf9e-d30f-443f-8a27-d57a4c7ca9e1', 'fr', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Votre solution est-elle substantiellement novatrice par rapport à ce qui existe déjà ?', '2026-08-28 17:30:50.60106+00'),
	('a5042f90-7493-4da2-8680-af61e60a56a4', 'fr', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Le club est-il affilié à une fédération sportive spécialisée au sein de Riksidrottsförbundet ?', '2026-08-28 17:30:50.60106+00'),
	('021c6662-f5bb-42ea-9669-de5b35460824', 'fr', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Les revenus du ménage sont-ils faibles par rapport au coût du logement ?', '2026-08-28 17:30:50.60106+00');
INSERT INTO public.kb_translations VALUES
	('f52d3af9-450a-43e6-a74b-b8a84307e2eb', 'fr', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Les revenus cumulés du ménage sont-ils inférieurs à environ 25 000 kr par mois avant impôt ?', '2026-08-28 17:30:50.60106+00'),
	('6fd44f23-6f58-4ead-adce-3597c7105a72', 'fr', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'L''action est-elle un projet délimité (pas l''activité ordinaire) ?', '2026-08-28 17:30:50.60106+00'),
	('b02efc6f-3488-4bc6-a884-3797d5e99c0a', 'fr', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Le local est-il ouvert à tous — pas seulement à vos propres membres ?', '2026-08-28 17:30:50.60106+00'),
	('aee2020b-ea00-4591-a60e-8dbe61c22b79', 'fr', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Au moins 60 % des membres ont-ils entre 6 et 25 ans ?', '2026-08-28 17:30:50.60106+00'),
	('a8249d99-35ea-4b10-844f-0db27475f66a', 'fr', 'Är minst 60 % av medlemmarna under 26 år?', 'Au moins 60 % des membres ont-ils moins de 26 ans ?', '2026-08-28 17:30:50.60106+00'),
	('4d8ac4af-6634-4d27-9d47-888977d507b8', 'fr', 'Är målgruppen delaktig i planering och genomförande?', 'Le groupe cible participe-t-il à la planification et à la mise en œuvre ?', '2026-08-28 17:30:50.60106+00'),
	('6d2ed62d-dbbd-4d66-ba94-ef7aabceb406', 'fr', 'Är ni ett förlag med professionell utgivning?', 'Êtes-vous une maison d''édition avec une publication professionnelle ?', '2026-08-28 17:30:50.60106+00'),
	('c5ff4f06-04e4-42e6-90de-7c5d4e480fcb', 'fr', 'Är ni huvudman för förskoleklass eller grundskola?', 'Êtes-vous responsable d''une classe préscolaire ou d''une école obligatoire ?', '2026-08-28 17:30:50.60106+00'),
	('8d2d0818-4f31-4692-aa71-0ba18987922a', 'fr', 'Är organisationen registrerad i EU:s deltagarregister?', 'L''organisation est-elle enregistrée dans le registre des participants de l''UE ?', '2026-08-28 17:30:50.60106+00'),
	('00e54589-2038-449d-b274-6df9d562be6e', 'fr', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Le projet est-il un projet de cinéma (court métrage ou documentaire) ?', '2026-08-28 17:30:50.60106+00'),
	('511cba57-53d6-4b80-a07c-e72012a591a3', 'fr', 'Är projektet ett konst- eller kulturprojekt?', 'Le projet est-il un projet artistique ou culturel ?', '2026-08-28 17:30:50.60106+00'),
	('f78f1902-4aa8-4208-83e1-61b917a8ff65', 'fr', 'Är projektet ett kulturprojekt?', 'Le projet est-il un projet culturel ?', '2026-08-28 17:30:50.60106+00'),
	('a081c11a-274e-4078-a745-f1e8ec4c515e', 'fr', 'Är projektet ett musikprojekt?', 'Le projet est-il un projet musical ?', '2026-08-28 17:30:50.60106+00'),
	('ded56ab8-6db9-46cb-8485-0ce90e57cded', 'fr', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Le projet est-il novateur — quelque chose que vous ne faites pas déjà dans votre activité ordinaire ?', '2026-08-28 17:30:50.60106+00'),
	('83ce37b5-7eb7-462f-b57d-daaa98bc5877', 'fr', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Le projet profite-t-il au territoire dans son ensemble (pas à des particuliers) ?', '2026-08-28 17:30:50.60106+00'),
	('47447c3d-2827-4c79-9c84-ef3f3b11e206', 'fr', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Le trajet entre le domicile et le lycée fait-il au moins six kilomètres ?', '2026-08-28 17:30:50.60106+00'),
	('2e410957-b3c5-42b1-8599-cfdfcaf4bc6a', 'fr', 'Är verksamheten professionell (inte amatörverksamhet)?', 'L''activité est-elle professionnelle (pas amateur) ?', '2026-08-28 17:30:50.60106+00'),
	('a94fc3e8-4fa1-4647-b2a4-793997aaa974', 'fr', 'Är verksamheten professionell?', 'L''activité est-elle professionnelle ?', '2026-08-28 17:30:50.60106+00'),
	('4660d58b-cc95-4634-ac9e-1f915bbf18ca', 'fr', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'L''activité relève-t-elle des arts de la scène (danse, théâtre, théâtre musical) ?', '2026-08-28 17:30:50.60106+00'),
	('4a3c40fa-1547-49bd-a159-e285d1524894', 'fr', 'Är volontärerna mellan 18 och 30 år?', 'Les volontaires ont-ils entre 18 et 30 ans ?', '2026-08-28 17:30:50.60106+00'),
	('23dc15cb-6a3e-4b55-a66b-8b12c5f3831e', 'ar', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'دعم أنشطة للأندية الرياضية التي تقدم أنشطة بقيادة مدربين للأطفال والشباب من 7 إلى 25 عامًا.', '2026-08-28 17:30:50.605858+00'),
	('5373baf1-7930-42e6-a859-983d9a392b7d', 'ar', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'إضافة تلقائية إلى علاوة الأطفال (barnbidrag) اعتبارًا من الطفل الثاني.', '2026-08-28 17:30:50.605858+00'),
	('bab3f27e-a24c-452a-b10f-3033588eeb78', 'ar', 'Avser ansökan en fysisk investering?', 'هل يتعلق الطلب باستثمار مادي؟', '2026-08-28 17:30:50.605858+00'),
	('510ed146-2356-4d7f-b14a-0ecc88cbe323', 'ar', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'هل يتعلق الطلب برحلة أو تبادل دولي؟', '2026-08-28 17:30:50.605858+00'),
	('14ee8eab-d6bc-434b-b197-c0a3af7b26fd', 'ar', 'Avser ansökan en investering i byggnader eller maskiner?', 'هل يتعلق الطلب باستثمار في مبانٍ أو آلات؟', '2026-08-28 17:30:50.605858+00'),
	('84874c57-543e-4f58-9112-988fa9dc4f09', 'ar', 'Avser ansökan en redan utgiven titel?', 'هل يتعلق الطلب بعنوان منشور بالفعل؟', '2026-08-28 17:30:50.605858+00'),
	('7382cd82-ddfe-498d-ada5-156ce86de069', 'ar', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'هل يتعلق الطلب بمنشأة زراعية أو بستانية أو لتربية الرنة؟', '2026-08-28 17:30:50.605858+00'),
	('79a95984-bffa-4302-ba5b-1ee07831814b', 'ar', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'هل يتعلق الطلب بشراء كتب للمكتبات العامة أو المدرسية؟', '2026-08-28 17:30:50.605858+00'),
	('54267188-3e6b-4cc6-adcd-31581445270f', 'ar', 'Avser investeringen jordbruksverksamhet?', 'هل يتعلق الاستثمار بنشاط زراعي؟', '2026-08-28 17:30:50.605858+00'),
	('e9e481ef-54f1-4a65-80cd-7dfd42ba8762', 'ar', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'هل يهدف المشروع إلى بناء أو شراء أو ترميم مقر؟', '2026-08-28 17:30:50.605858+00'),
	('3ccc27ed-7f1f-4eab-a849-dd588ae9b8cc', 'ar', 'Avser projektet naturvård eller friluftsliv?', 'هل يتعلق المشروع بحماية الطبيعة أو الأنشطة في الهواء الطلق؟', '2026-08-28 17:30:50.605858+00'),
	('fb4dbef1-d30d-4ebf-bdb7-5f1f5ea37688', 'ar', 'Avser projektet skola eller vuxenutbildning?', 'هل يتعلق المشروع بالمدرسة أو تعليم الكبار؟', '2026-08-28 17:30:50.605858+00'),
	('31977acc-9318-4a54-89f6-b9e659971cab', 'ar', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'هل تمتنع عن العمل لرعاية قريب أو البقاء بجانبه لأنه مريض بشدة لدرجة أن المرض يهدد حياته؟', '2026-08-28 17:30:50.605858+00'),
	('b6f44cee-34fe-4d34-a179-858c861f8b45', 'ar', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'هل تمارس الجمعية نشاطًا منتظمًا في البلدية؟', '2026-08-28 17:30:50.605858+00'),
	('1f865f34-9aa5-44a5-acca-9cd59138c113', 'ar', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'هل تقدّر أن قدرتك على العمل منخفضة لمدة سنة على الأقل بسبب مرض أو إعاقة؟', '2026-08-28 17:30:50.605858+00'),
	('ce13b9f3-1838-45ff-81bd-b23ef067a186', 'ar', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'دعم خاضع لتقييم الحاجة لمن لديه معاش منخفض أو لا معاش له ويحتاج إلى مساعدة للوصول إلى مستوى معيشة معقول.', '2026-08-28 17:30:50.605858+00'),
	('d36f081e-90ed-4bf3-b174-3e1d85b5bf73', 'ar', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'هل يحتاج الطفل إلى السكن في بلدة الدراسة (إقامة) لأن الطريق طويل جدًا؟', '2026-08-28 17:30:50.605858+00'),
	('483acb57-f620-482b-b07c-ff1e5ce904b3', 'ar', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'هل يحتاج المسكن إلى تكييف (مثل منحدر أو فاتح أبواب أو حمّام)؟', '2026-08-28 17:30:50.605858+00'),
	('47bda7ae-0c16-48c1-89f4-b2e7a3a6168d', 'ar', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'هل يحتاج أحد أطفالك بين 8 و19 عامًا إلى نظارات أو عدسات؟', '2026-08-28 17:30:50.605858+00'),
	('51f8e047-34ee-4c39-8595-76b6c96e62c7', 'ar', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'هل لا يدفع الوالد الآخر شيئًا أو يدفع أقل من النفقة الكاملة؟', '2026-08-28 17:30:50.605858+00'),
	('66a48707-d9a7-41a9-ab78-97ef24b999d8', 'ar', 'Betalar du hyra eller andra boendekostnader?', 'هل تدفع إيجارًا أو تكاليف سكن أخرى؟', '2026-08-28 17:30:50.605858+00'),
	('6c59b5f8-8f7d-4ad1-b870-e3301b9997ae', 'ar', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'إعانة لتكييف المسكن عند وجود إعاقة — مثل المنحدرات أو فاتحات الأبواب أو تكييف الحمّام.', '2026-08-28 17:30:50.605858+00'),
	('ed567d34-07d6-4479-b506-3b764e806435', 'ar', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'إعانات لبناء أو شراء أو ترميم قاعات الاجتماعات العامة.', '2026-08-28 17:30:50.605858+00'),
	('76384e21-2387-46d6-af40-39e74dec6d83', 'ar', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'إعانة لشراء سيارة أو تكييفها عندما تجعل إعاقة دائمة التنقل أو استخدام المواصلات العامة صعبًا جدًا.', '2026-08-28 17:30:50.605858+00'),
	('f1b2e113-33d7-43d9-b05a-8ef5a56ec37c', 'ar', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'إعانات للسفر والتبادل الدولي للعاملين المحترفين في المجال الثقافي.', '2026-08-28 17:30:50.605858+00'),
	('3707e0eb-feba-4359-990e-0d76f9c9655a', 'ar', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'إعانات لتبادلات الفنانين المحترفين الدولية وسفرهم وإقاماتهم للعمل.', '2026-08-28 17:30:50.605858+00'),
	('d9878a34-7239-456e-b785-8fd2e21016d1', 'ar', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'إعانة وقرض اختياري للدراسة في المرحلة الثانوية أو ما بعد الثانوية.', '2026-08-28 17:30:50.605858+00'),
	('4d18a68f-e7ff-421e-a2c1-53a9ab1bc8b8', 'ar', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'إعانات وقروض للدراسة في الخارج، مع قروض إضافية لتغطية مثل رسوم الدراسة والسفر.', '2026-08-28 17:30:50.605858+00'),
	('0c5a8bc9-9f03-4b00-a070-d34b8370e321', 'ar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'إعانة تساعد الجهات السويدية على إعداد طلبات لبرامج الاتحاد الأوروبي مثل Horisont Europa.', '2026-08-28 17:30:50.605858+00'),
	('9b9bbffd-0e8f-46c0-812e-18d5016a1906', 'ar', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'إعانة لأصحاب العمل الذين يوظفون أشخاصًا ذوي قدرة منخفضة على العمل.', '2026-08-28 17:30:50.605858+00');
INSERT INTO public.kb_translations VALUES
	('5b263bed-5c6e-4fce-94f9-e406e2bea76a', 'ar', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'إعانة للسكن ورحلات العودة إلى المنزل عندما يضطر طالب ثانوي للسكن في بلدة الدراسة بسبب طول الطريق.', '2026-08-28 17:30:50.605858+00'),
	('0ca717b6-24b8-4814-9543-11713eeb15ef', 'ar', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'إعانات لعمل المنظمات غير الربحية في الحفاظ على التراث الثقافي واستخدامه وتطويره.', '2026-08-28 17:30:50.605858+00'),
	('cad494ff-0915-4c79-a7cc-bb7e851d22f2', 'ar', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'إعانات لمشاريع حماية الطبيعة البلدية والمحلية، بما في ذلك الأراضي الرطبة والأنشطة في الهواء الطلق.', '2026-08-28 17:30:50.605858+00'),
	('7148ada6-0447-4ddc-901d-260832404078', 'ar', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'إعانات للبلديات لشراء الكتب للمكتبات العامة والمدرسية.', '2026-08-28 17:30:50.605858+00'),
	('d14885e1-1fcc-427a-9318-edaf06e74549', 'ar', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'إعانات للجهات المسؤولة عن المدارس ليلتقي تلاميذ المرحلة الأساسية بالثقافة الاحترافية.', '2026-08-28 17:30:50.605858+00'),
	('13be3407-6248-4bbf-87e4-6c11a53cc911', 'ar', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'إعانة لما يحتاجه طفلك ولا تكفي ميزانية الأسرة لتغطيته: أنشطة ترفيهية، ملابس، رحلات مدرسية، نظارات، أنشطة العطل وغيرها.', '2026-08-28 17:30:50.605858+00'),
	('6d27cf2d-9c12-4993-87b3-3ff9216d5380', 'ar', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'إعانات من صناديق مثل Världens Barn وMusikhjälpen وVictoriafonden — تطلبها منظمات سويدية غير ربحية لديها 90-konto.', '2026-08-28 17:30:50.605858+00'),
	('ac37f0be-034e-41f3-ad3b-d2e7f98a1b88', 'ar', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'إعانات من أموال الطاقة الكهرومائية وطاقة الرياح لمشاريع تنمّي المنطقة.', '2026-08-28 17:30:50.605858+00'),
	('805c0b5d-30f4-4faf-9ded-3bd3195c32a7', 'ar', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'إعانة دون جزء قرضي للعاطلين عن العمل بين 25 و60 عامًا ذوي التعليم القصير الذين يحتاجون إلى الدراسة في مستوى المدرسة الأساسية أو الثانوية.', '2026-08-28 17:30:50.605858+00'),
	('412a5e1d-376c-41b8-a9a3-a369be3e3d93', 'ar', 'Bidrar projektet till energiomställningen?', 'هل يساهم المشروع في التحول الطاقي؟', '2026-08-28 17:30:50.605858+00'),
	('710abc09-fd28-4121-b083-f3e3e68b5fa7', 'ar', 'Bor du och barnets andra förälder på skilda håll?', 'هل تعيش أنت والوالد الآخر للطفل منفصلين؟', '2026-08-28 17:30:50.605858+00'),
	('c2763dde-4045-487b-b4c6-4d37454450c0', 'ar', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'شيكات للشركات الصغيرة لجلب خبرات خارجية في التدويل أو الرقمنة.', '2026-08-28 17:30:50.605858+00'),
	('e15e8387-a3b2-4af3-82da-a6be7b37a10c', 'ar', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'هل تشارك في برنامج لدى Arbetsförmedlingen (مثل jobb- och utvecklingsgarantin)؟', '2026-08-28 17:30:50.605858+00'),
	('7296ddfb-c9f3-44fa-b549-d4ec14e18479', 'ar', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'دعم لاحق لدور النشر مقابل نشر أدب ذي جودة.', '2026-08-28 17:30:50.605858+00'),
	('a5417e4e-66ad-4b5c-973a-060925930403', 'ar', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'دعم اقتصادي لمن لديه تصريح إقامة مرتبط بالحماية ويرغب طوعًا في العودة نهائيًا إلى بلده الأصلي.', '2026-08-28 17:30:50.605858+00'),
	('05147b02-527c-43b8-8aba-82a9839b18ee', 'ar', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'دعم اقتصادي لأصحاب العمل الذين يوظفون شخصًا غاب طويلًا عن الحياة العملية.', '2026-08-28 17:30:50.605858+00'),
	('4dc8650b-3b67-4232-80bb-a5bbbf009927', 'ar', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'دعم اقتصادي خلال مرحلة البدء للباحثين عن عمل الذين يؤسسون شركتهم الخاصة.', '2026-08-28 17:30:50.605858+00'),
	('1f15ce78-ce8f-455c-972b-6125358df017', 'ar', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'تفتح Energimyndigheten باستمرار دعوات في أبحاث الطاقة والابتكار وكفاءة الطاقة.', '2026-08-28 17:30:50.605858+00'),
	('67948bb8-13fe-47b4-a516-c215899e0f50', 'ar', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'تعويض عن التغيب عن العمل أو الدراسة لرعاية طفل.', '2026-08-28 17:30:50.605858+00'),
	('7128013f-f3a3-4583-97c8-9679e6061b1a', 'ar', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'تعويض لمن هو جديد في السويد ويشارك في برنامج التأسيس لدى Arbetsförmedlingen؛ تدفعه Försäkringskassan.', '2026-08-28 17:30:50.605858+00'),
	('adb90d3c-7f7a-4f3d-96ea-e83cd472afc2', 'ar', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'تعويض يغطي جزءًا من تكلفة السكن للشباب دون أطفال ذوي الدخل المنخفض.', '2026-08-28 17:30:50.605858+00'),
	('f11418cb-1bd1-4188-8355-8909ce3da8db', 'ar', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'تعويض عن التكاليف الإضافية التي تسببها إعاقة دائمة — للبالغين أو لأهل الأطفال ذوي الإعاقة.', '2026-08-28 17:30:50.605858+00'),
	('08867eb6-f97d-4f5b-ae74-86e5c5ba9401', 'ar', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'تعويض للشباب (19–29 عامًا) الذين لا يستطيعون العمل بدوام كامل لمدة سنة على الأقل بسبب مرض أو إعاقة.', '2026-08-28 17:30:50.605858+00'),
	('56d11004-47af-4f64-a320-bb65b7921bd7', 'ar', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'تعويض عندما تكون القدرة على العمل منخفضة بشكل دائم — ما كان يسمى سابقًا förtidspension (التقاعد المبكر).', '2026-08-28 17:30:50.605858+00'),
	('bfd5a201-5622-49cf-a74c-8c927b054ad2', 'ar', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'تعويض عندما تمتنع عن العمل لتكون بجانب قريب مريض بشدة.', '2026-08-28 17:30:50.605858+00'),
	('6a3164e9-cadc-476e-b56d-e22e361ff718', 'ar', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'تعويض عند مشاركتك في برنامج لسياسة سوق العمل لدى Arbetsförmedlingen.', '2026-08-28 17:30:50.605858+00'),
	('20837201-4509-46aa-b5bc-bb61181a0587', 'ar', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'تعويض عندما لا تستطيع العمل كالمعتاد بسبب المرض.', '2026-08-28 17:30:50.605858+00'),
	('860e9d44-d618-40e7-ba4b-5065169b6a48', 'ar', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'تعويض عندما تبقى في المنزل عن العمل لرعاية طفل مريض.', '2026-08-28 17:30:50.605858+00'),
	('3bbc361d-486c-44ab-86f4-2ec248cec024', 'ar', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'تعويض يغطي جزءًا من تكلفة السكن للأسر التي لديها أطفال ودخل أقل.', '2026-08-28 17:30:50.605858+00'),
	('9b3ba05b-646e-425b-8e6e-fa4207eff503', 'ar', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'تعويض للوالدين الذين يحتاج أطفالهم بسبب الإعاقة إلى رعاية وإشراف أكثر من أطفال في نفس العمر.', '2026-08-28 17:30:50.605858+00'),
	('c2de6a5a-bdf1-42d2-b7e5-3e88c2bf1b5e', 'ar', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'تعويض عند البطالة — على أساس الدخل للأعضاء، ومبلغ أساسي لغيرهم.', '2026-08-28 17:30:50.605858+00'),
	('a8d4fcf4-612b-4994-92ee-5f9bb583d14c', 'ar', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'نحو خمسين مؤسسة لبنوك الادخار تمنح إعانات لمشاريع محلية في الرياضة والثقافة والتعليم وتنمية المجتمع — في منطقة نشاط البنك.', '2026-08-28 17:30:50.605858+00'),
	('71bf1da4-3fd0-4307-8497-50fe533c9bf5', 'ar', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'دعم مشاريع ممول من الاتحاد الأوروبي يُطلب لدى منطقة Leader المحلية — للجمعيات والشركات والبلديات التي تنمّي الريف.', '2026-08-28 17:30:50.605858+00'),
	('18d84b14-ed9e-4b6a-b8df-bc5010aa3464', 'ar', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'دعم ممول من الاتحاد الأوروبي للباحثين عن عمل الذين يقبلون وظيفة في بلد آخر من الاتحاد الأوروبي/المنطقة الاقتصادية الأوروبية: تعويض عن سفر المقابلة وتكاليف الانتقال ودورة لغة.', '2026-08-28 17:30:50.605858+00'),
	('9f1ff271-eb7b-4048-b6c8-50bd16f7f872', 'ar', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'أموال من الصندوق الاجتماعي الأوروبي لمشاريع تعزز الكفاءات والتحول والإدماج في سوق العمل.', '2026-08-28 17:30:50.605858+00'),
	('3a98ca2f-1cd9-48b5-b65f-c11b530ccda3', 'ar', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'دعم من الاتحاد الأوروبي لتبادلات جماعية للشباب من 13 إلى 30 عامًا، لمدة 5 إلى 21 يومًا دون أيام السفر.', '2026-08-28 17:30:50.605858+00'),
	('7a963818-90b2-41ef-af31-1d03f543a48d', 'ar', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'دعم من الاتحاد الأوروبي لمشاريع تعاون المنظمات الثقافية مع شركاء في عدة بلدان أوروبية.', '2026-08-28 17:30:50.605858+00'),
	('4c5bb15f-40b3-424b-b5fc-21e81595f72b', 'ar', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'دعم من الاتحاد الأوروبي للمنظمات التي تستقبل أو ترسل متطوعين شبابًا من 18 إلى 30 عامًا.', '2026-08-28 17:30:50.605858+00'),
	('c6307266-6d06-4684-8145-d97c599d357b', 'ar', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'دعم من الاتحاد الأوروبي لتنقل العاملين والتلاميذ في المدرسة وتعليم الكبار.', '2026-08-28 17:30:50.605858+00'),
	('058af0e7-cfad-42f6-9611-604d88f5473a', 'ar', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'دعم من الاتحاد الأوروبي بمبالغ مقطوعة لأول مشاريع تعاون أوروبية للمنظمات الصغيرة.', '2026-08-28 17:30:50.605858+00'),
	('6b727737-00e8-459b-98bb-3aa6fa27d2d7', 'ar', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تمويل للشركات الفتية التي تطور منتجات أو خدمات مبتكرة ذات إمكانات دولية.', '2026-08-28 17:30:50.605858+00'),
	('a9f407aa-7ccc-4ffa-9bf0-810ff9bf7130', 'ar', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'هل يوجد بنك ادخار (وبالتالي مؤسسة بنك ادخار) حيث تمارسون نشاطكم؟', '2026-08-28 17:30:50.605858+00'),
	('79c8c0c0-aae4-48be-bd44-87566c03f82a', 'prs', 'Kan projektets miljönytta mätas?', 'آیا فایده محیط‌زیستی پروژه قابل اندازه‌گیری است؟', '2026-08-28 17:30:50.623518+00'),
	('fe06590e-087b-4629-b047-00f0df5415f0', 'ar', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'إعانات تشغيل متعددة السنوات للفرق المستقلة المحترفة في الرقص والمسرح والمسرح الموسيقي.', '2026-08-28 17:30:50.605858+00'),
	('f0bb39a4-fc5b-4b15-9ad4-a07a3aaf710f', 'ar', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'إعانات بحثية في مجالات Forte: الصحة والحياة العملية والرفاه. يطلبها باحثون حاصلون على الدكتوراه في الجامعات السويدية.', '2026-08-28 17:30:50.605858+00'),
	('be054ecb-c5e0-49b0-9cb1-62d7a5697e6c', 'ar', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'تمويل بحثي للبحث الأساسي الحر في جميع المجالات العلمية.', '2026-08-28 17:30:50.605858+00'),
	('1fdf7437-765a-46a7-aa72-479fedc0f191', 'ar', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'تمويل بحثي في البيئة والعلوم الزراعية والتخطيط العمراني.', '2026-08-28 17:30:50.605858+00'),
	('9f7a0126-17b5-42d9-970c-c21b70527b3a', 'ar', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'هل تفكر في الانتقال إلى الخارج (للعمل أو الدراسة أو العودة إلى الوطن)؟', '2026-08-28 17:30:50.605858+00'),
	('96f18fd6-f250-4e65-a4d6-0d9aae90cf19', 'ar', 'Genomförs insatserna av professionella kulturaktörer?', 'هل ينفذ الأنشطة فاعلون ثقافيون محترفون؟', '2026-08-28 17:30:50.605858+00'),
	('a699b11c-6e2b-4d34-950f-6d73f58156ba', 'ar', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'هل يُنفذ المشروع في الريف أو في بلدة صغيرة؟', '2026-08-28 17:30:50.605858+00');
INSERT INTO public.kb_translations VALUES
	('50d24826-000e-4040-a879-c1a13c378e1f', 'ar', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حماية أساسية لمن كان دخله من العمل قليلًا أو معدومًا خلال حياته.', '2026-08-28 17:30:50.605858+00'),
	('62fbb147-768a-4313-8978-c12065e8045b', 'ar', 'Går något av dina barn i grundskolan?', 'هل يذهب أحد أطفالك إلى المدرسة الأساسية؟', '2026-08-28 17:30:50.605858+00'),
	('863bb327-1c3f-486a-b837-b127830d74f2', 'ar', 'Går något av dina barn på gymnasiet?', 'هل يدرس أحد أطفالك في الثانوية؟', '2026-08-28 17:30:50.605858+00'),
	('ed5828c6-501c-41e8-8dd4-1c9ae7f8068c', 'ar', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'هل يتعلق التوظيف بشخص ذي قدرة منخفضة على العمل؟', '2026-08-28 17:30:50.605858+00'),
	('0fd42989-e070-4054-a927-f101510f899c', 'ar', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'هل يتعلق التوظيف بشخص كان عاطلًا طويلًا أو جديدًا في السويد؟', '2026-08-28 17:30:50.605858+00'),
	('a2805b55-52ef-4e72-ab46-d8da7c743268', 'ar', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'هل يدور المشروع حول الحفاظ على التراث الثقافي أو إتاحته؟', '2026-08-28 17:30:50.605858+00'),
	('e8e427c1-43bf-43e1-8021-7eb758bf50cc', 'ar', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'هل يدور المشروع حول الطاقة أو كفاءة الطاقة أو الابتكار المتعلق بالطاقة؟', '2026-08-28 17:30:50.605858+00'),
	('9d977ff3-023c-4223-8689-5427345a39f8', 'ar', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'هل يدور المشروع حول الصحة أو الحياة العملية أو الرفاه؟', '2026-08-28 17:30:50.605858+00'),
	('b12c2a19-439d-431e-8479-f6c8faa34bb7', 'ar', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'هل يدور المشروع حول تطوير الكفاءات أو تدابير سوق العمل؟', '2026-08-28 17:30:50.605858+00'),
	('a918eb9b-abb3-4836-9a20-c37f38562a5e', 'ar', 'Handlar projektet om miljö- eller klimatåtgärder?', 'هل يدور المشروع حول تدابير بيئية أو مناخية؟', '2026-08-28 17:30:50.605858+00'),
	('b8f22e93-3509-4fc7-a260-1405affeb59b', 'ar', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'هل طريق الطفل إلى المدرسة طويل أو خطر بسبب حركة المرور أو صعب لأسباب أخرى؟', '2026-08-28 17:30:50.605858+00'),
	('32594af3-65fd-4699-8a87-0f4c050b6d07', 'ar', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'هل عملت 16 ساعة أسبوعيًا على الأقل لمدة إجمالية لا تقل عن 8 سنوات؟', '2026-08-28 17:30:50.605858+00'),
	('5eaa5cdd-c6ff-4d7d-974c-59bf40a57d4d', 'ar', 'Har du barn som bor hos dig, helt eller växelvis?', 'هل لديك أطفال يعيشون معك، كليًا أو بالتناوب؟', '2026-08-28 17:30:50.605858+00'),
	('62751751-1ce1-4d1b-99cb-cedf2bf81668', 'ar', 'Har du barn som bor hos dig?', 'هل لديك أطفال يعيشون معك؟', '2026-08-28 17:30:50.605858+00'),
	('6d330153-52e8-4569-a03e-61d70b4adbab', 'ar', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'هل لديك أو لدى طفلك إعاقة يُتوقع أن تستمر سنة على الأقل؟', '2026-08-28 17:30:50.605858+00'),
	('7b5101cb-9b7c-40d0-bc15-bde8b3ec5d0d', 'ar', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'هل لديك أو لدى أحد في الأسرة إعاقة دائمة تؤثر على السكن؟', '2026-08-28 17:30:50.605858+00'),
	('ce28dafe-1a18-481a-980e-9a373396b419', 'ar', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'هل لديك أو لدى قريب مقرب إعاقة أو مرض طويل الأمد أو خطير؟', '2026-08-28 17:30:50.605858+00'),
	('3901bfbc-5e12-403a-a431-1fd4845893fb', 'ar', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'هل لديك مرض أو إصابة تحدّ حاليًا من قدرتك على العمل؟', '2026-08-28 17:30:50.605858+00'),
	('3a55cf69-4ef5-44e6-8ac0-b5117df8c034', 'ar', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'هل واجهت يومًا صعوبة في دفع تكلفة رحلة مدرسية أو رحلة صف أو نشاط ترفيهي يُتوقع أن يشارك فيه طفلك؟', '2026-08-28 17:30:50.605858+00'),
	('cd99e9b5-e61f-48b6-9273-d7a49bd8ce18', 'ar', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'هل يصعب عليك تدبير أمورك بمعاشك ودخلك الآخر؟', '2026-08-28 17:30:50.605858+00'),
	('55b712ec-8475-4fce-b9b7-27ee53f0608b', 'ar', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'هل حصلت في السنوات الأخيرة على تصريح إقامة في السويد، مثلًا كشخص بحاجة إلى حماية أو كقريب؟', '2026-08-28 17:30:50.605858+00'),
	('e22c3db1-3348-4094-b7af-268206a46fe5', 'ar', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'هل لديك تصريح إقامة في السويد كلاجئ أو شخص بحاجة إلى حماية (أو أنت قريب مقرب لشخص لديه ذلك)؟', '2026-08-28 17:30:50.605858+00'),
	('c06b32f4-bcd2-46ca-8e7c-f7a75ae147da', 'ar', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'هل بلغت السن المرجعية للتقاعد (67 عامًا في 2026)؟', '2026-08-28 17:30:50.605858+00'),
	('30c62ad0-eb43-4f46-a587-e9694ed45b4e', 'ar', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'هل لدى منظمتكم OID (Organisation ID) مسجل في Organisation Registration System التابع للاتحاد الأوروبي؟', '2026-08-28 17:30:50.605858+00'),
	('fa7cb89e-5c2e-450f-9ee7-1ae80000d3af', 'ar', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'هل تسببت الإعاقة في تكاليف إضافية — مثل الوسائل المساعدة أو التنقل أو نظام غذائي خاص أو الاستهلاك؟', '2026-08-28 17:30:50.605858+00'),
	('70f4cf39-6a42-44a8-95d7-e2367ee80488', 'ar', 'Har föreningen antagna stadgar och en vald styrelse?', 'هل لدى الجمعية نظام أساسي معتمد ومجلس إدارة منتخب؟', '2026-08-28 17:30:50.605858+00'),
	('80de890f-937f-4c68-9f2f-17c4a191e0cb', 'ar', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'هل لدى الجمعية بنية ديمقراطية (نظام أساسي، اجتماع سنوي، مجلس إدارة)؟', '2026-08-28 17:30:50.605858+00'),
	('6a6908d1-39ee-4d57-83fd-bc8f8a9c4de2', 'ar', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'هل تمارس الجمعية نشاطًا منتظمًا للأطفال أو الشباب؟', '2026-08-28 17:30:50.605858+00'),
	('5f7bf6d1-b8cc-485e-8d32-3a130e4601b1', 'ar', 'Har företaget mellan cirka 2 och 49 anställda?', 'هل لدى الشركة ما بين حوالي 2 و49 موظفًا؟', '2026-08-28 17:30:50.605858+00'),
	('c97e228d-5306-4468-b53c-c0b5f1d5b3ee', 'ar', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'هل تجد الأسرة صعوبة في تغطية تكاليف الطعام والسكن وأبسط الضروريات؟', '2026-08-28 17:30:50.605858+00'),
	('3c4db7ba-6c6a-467f-8bbd-1711b7a022fa', 'ar', 'Har lösningen internationell potential?', 'هل للحل إمكانات دولية؟', '2026-08-28 17:30:50.605858+00'),
	('6d10d1d1-f82b-4df8-b502-444d2bc71f6a', 'ar', 'Har ni en partnergrupp i ett annat land?', 'هل لديكم مجموعة شريكة في بلد آخر؟', '2026-08-28 17:30:50.605858+00'),
	('f5a28882-bac4-470c-95a7-f6f71b8049c2', 'ar', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'هل لديكم منظمة شريكة في بلد أوروبي آخر؟', '2026-08-28 17:30:50.605858+00'),
	('c4246706-cf88-4efc-95c7-dc45b91e2679', 'ar', 'Har ni partner i minst tre olika europeiska länder?', 'هل لديكم شركاء في ثلاثة بلدان أوروبية مختلفة على الأقل؟', '2026-08-28 17:30:50.605858+00'),
	('48b0f54e-3792-4cdb-a034-a120b88ca2ad', 'ar', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'هل مقركم أو نشاطكم الرئيسي في المنطقة التي تقدمون فيها الطلب؟', '2026-08-28 17:30:50.605858+00'),
	('96ac01c0-9800-47d4-a1ab-ee0de4892a58', 'ar', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'هل لدى أحد أطفالك إعاقة تجعله يحتاج إلى رعاية أو إشراف أكثر من أطفال آخرين في نفس العمر؟', '2026-08-28 17:30:50.605858+00'),
	('e9f03ad4-75ef-4f14-acba-49be7b2baa96', 'ar', 'Har organisationen en demokratisk uppbyggnad?', 'هل لدى المنظمة بنية ديمقراطية؟', '2026-08-28 17:30:50.605858+00'),
	('0868b5ed-6ef5-40af-92a4-f0a28ba0eb76', 'ar', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'هل لدى المنظمة Quality Label (علامة الجودة)؟', '2026-08-28 17:30:50.605858+00'),
	('fa574c00-71f1-437e-ab0a-648df02ae297', 'ar', 'Har organisationen ett 90-konto?', 'هل لدى المنظمة 90-konto؟', '2026-08-28 17:30:50.605858+00'),
	('b962e706-a002-48a6-8d82-0abd0364e362', 'ar', 'Har organisationen ett OID (Organisation ID)?', 'هل لدى المنظمة OID (Organisation ID)؟', '2026-08-28 17:30:50.605858+00'),
	('2ac4fa61-4f20-42f8-9850-d992deca77fa', 'ar', 'Har organisationen ett OID?', 'هل لدى المنظمة OID؟', '2026-08-28 17:30:50.605858+00'),
	('16244f3f-d2b7-4fcb-ac05-5c37d5603121', 'ar', 'Har organisationen medlemsföreningar i flera län?', 'هل لدى المنظمة جمعيات أعضاء في عدة محافظات؟', '2026-08-28 17:30:50.605858+00'),
	('129c5c38-7bba-4576-ad7f-975a215363a0', 'ar', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'هل لدى المنظمة مالية منظمة وبنية ديمقراطية؟', '2026-08-28 17:30:50.605858+00'),
	('2674e8e9-b478-44a7-9e48-0d5f21d2d1a9', 'ar', 'Har projektet en partner i ett annat land?', 'هل للمشروع شريك في بلد آخر؟', '2026-08-28 17:30:50.605858+00'),
	('dde821d4-53c9-42fe-a5f3-fbe7d648ce1d', 'ar', 'Har projektledaren doktorsexamen?', 'هل قائد المشروع حاصل على الدكتوراه؟', '2026-08-28 17:30:50.605858+00'),
	('4b8c0d9f-7dda-439d-b70f-35f760f2a59e', 'ar', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'على بلدية السكن توفير التنقل اليومي بين المنزل والمدرسة الثانوية عندما يبلغ الطريق ستة كيلومترات على الأقل (مثل بطاقة حافلة).', '2026-08-28 17:30:50.605858+00'),
	('d1281230-352e-4b40-b543-a4d63ce18221', 'ar', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'هل أنت بصدد الحصول على أول مسكن خاص بك في السويد أو تجهيزه؟', '2026-08-28 17:30:50.605858+00'),
	('17862fbd-9fc9-4059-9fee-25e4683a646d', 'ar', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'هل يتضمن المشروع رحلة أو تبادلًا دوليًا؟', '2026-08-28 17:30:50.605858+00'),
	('1a60c6ef-d43d-4043-bca4-1694c7982bd6', 'ar', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'دعم استثماري للشركات في مناطق الدعم للمباني والآلات والتدريب.', '2026-08-28 17:30:50.605858+00'),
	('d4734aeb-7177-4c38-9596-d5e356301f5d', 'ar', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'دعم استثماري لتدابير تخفض انبعاثات غازات الدفيئة.', '2026-08-28 17:30:50.605858+00');
INSERT INTO public.kb_translations VALUES
	('ed2c2df9-2efb-4db3-a3e9-b9c27657fa42', 'ar', 'Kan projektets miljönytta mätas?', 'هل يمكن قياس الفائدة البيئية للمشروع؟', '2026-08-28 17:30:50.605858+00'),
	('ff8a0f04-54d8-4885-9bf2-d507f462d59c', 'ar', 'Kan åtgärdens utsläppsminskning beräknas?', 'هل يمكن حساب خفض الانبعاثات الناتج عن التدبير؟', '2026-08-28 17:30:50.605858+00'),
	('071b966c-2fc6-417c-8bb2-79cd0c8683c5', 'ar', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'هل تستطيع المنظمة تحمّل التكاليف حتى صرف الدعم؟', '2026-08-28 17:30:50.605858+00'),
	('ec61944c-b785-4e33-9dd1-9e2c78a1d2ca', 'ar', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'هل ستُستخدم الخبرات في نشاطك في السويد؟', '2026-08-28 17:30:50.605858+00'),
	('62041cbb-bf83-41e7-9013-75dbdea2ffd0', 'ar', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'هل سيبدأ الاستثمار فقط بعد إرسال الطلب؟', '2026-08-28 17:30:50.605858+00'),
	('24d25d51-858f-476f-a8f9-2aa9dea1e63b', 'ar', 'Kommer projektet människor i ert närområde till del?', 'هل يعود المشروع بالفائدة على الناس في منطقتكم؟', '2026-08-28 17:30:50.605858+00'),
	('e46d5672-9e29-4990-8374-1ed1163d0a4b', 'ar', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'شبكة الأمان الاقتصادية الأخيرة للبلدية عندما لا يكفي الدخل لأبسط الضروريات.', '2026-08-28 17:30:50.605858+00'),
	('3cddac1f-fac1-43b2-8b89-f36ac3e28b0e', 'ar', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'دعم البلديات الخاص للحياة الجمعوية المحلية: دعم النشاط عن كل جلسة، دعم المقرات، دعم البدء وغير ذلك.', '2026-08-28 17:30:50.605858+00'),
	('744d3f72-8c10-445f-8ad5-1d901cf318a4', 'ar', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'نقل مدرسي مجاني لتلاميذ المدرسة الأساسية عند بعد المسافة أو خطورة الطريق أو الإعاقة — حق بموجب قانون المدرسة.', '2026-08-28 17:30:50.605858+00'),
	('2dd7b485-5844-492c-b5a4-7c0ab54e7fab', 'ar', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'إعانة قانونية للنظارات أو العدسات للأطفال والشباب؛ تختلف المبالغ والإجراءات حسب المنطقة — تحقق من مستوى منطقتك.', '2026-08-28 17:30:50.605858+00'),
	('51d223ca-3bc7-45ab-a4fe-eb7ac2f04aa4', 'ar', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'دعم لتحول الصناعة نحو انبعاثات صفرية من غازات الدفيئة.', '2026-08-28 17:30:50.605858+00'),
	('6b687430-986f-4bfc-93f9-8cb2992c5f2f', 'ar', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'هل يقع المشروع في منطقة معنية بالطاقة الكهرومائية أو طاقة الرياح؟', '2026-08-28 17:30:50.605858+00'),
	('5e053f7e-45d2-4b2e-8e60-9561354e6d3e', 'ar', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'هل يقع المشروع ضمن البيئة أو العلوم الزراعية أو التخطيط العمراني؟', '2026-08-28 17:30:50.605858+00'),
	('079fc1de-eeed-4228-9058-e43a6ddc53dd', 'ar', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'هل يقع مكان النشاط في منطقة الدعم A أو B (أجزاء كبيرة من نورلاند وسفيالاند الداخلية)؟', '2026-08-28 17:30:50.605858+00'),
	('87ecb2ff-a7db-4d95-9a14-28ee7211eb92', 'ar', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'قرض لشراء أبسط الضروريات لأول منزل في السويد — أثاث وأدوات منزلية وتجهيزات أساسية أخرى.', '2026-08-28 17:30:50.605858+00'),
	('8b345717-9833-4cc7-a2ea-4122b06af01a', 'ar', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'هل يخفض المشروع انبعاثات العمليات الصناعية أو ينشئ انبعاثات سالبة؟', '2026-08-28 17:30:50.605858+00'),
	('55e34b8d-84b6-43d8-80f6-c449cb817b71', 'ar', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'علاوة شهرية للأطفال المقيمين في السويد، من الولادة حتى سن 16.', '2026-08-28 17:30:50.605858+00'),
	('bc66968a-b8e4-40ae-9192-2ca2dd19024f', 'ar', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'تقدم Naturvårdsverket إعانات للمنظمات والشركات والجمعيات والقطاع العام والأفراد في مجال البيئة.', '2026-08-28 17:30:50.605858+00'),
	('868ce53e-9a4c-4297-a9d9-76de1e460eee', 'ar', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'هل تخطط للعودة طوعًا ونهائيًا إلى بلدك الأصلي؟', '2026-08-28 17:30:50.605858+00'),
	('3bd6b96f-2986-432e-ba0c-c2d5b4178206', 'ar', 'Planerar du att starta eget företag?', 'هل تخطط لتأسيس شركتك الخاصة؟', '2026-08-28 17:30:50.605858+00'),
	('9b6e0f79-965e-4994-b3d4-0e9475d4a963', 'ar', 'Planerar du att studera utomlands?', 'هل تخطط للدراسة في الخارج؟', '2026-08-28 17:30:50.605858+00'),
	('e71cd533-5395-473f-bac7-3ee390fe30ae', 'ar', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'هل تخطط لدراسة تقوي وضعك في سوق العمل؟', '2026-08-28 17:30:50.605858+00'),
	('5681513e-2b88-4202-bec4-665a5d03ce98', 'ar', 'Planerar ni att anställa?', 'هل تخططون للتوظيف؟', '2026-08-28 17:30:50.605858+00'),
	('d5bf38f2-652d-4c08-a9f2-19931da0f766', 'ar', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'هل تخططون للتقدم إلى برنامج للاتحاد الأوروبي (مثل Horisont Europa)؟', '2026-08-28 17:30:50.605858+00'),
	('dcd54e23-25e5-43fe-90fa-7e0343e1bd9d', 'ar', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'دعم إنتاج وتطوير الأفلام القصيرة والوثائقية.', '2026-08-28 17:30:50.605858+00'),
	('82ea5f2c-bba0-4246-a48b-13183fce1cae', 'ar', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'إعانات مشاريع للمشهد الموسيقي الحر للحفلات والإنتاج والتطوير.', '2026-08-28 17:30:50.605858+00'),
	('3644f333-9687-43b9-9a5f-f384bda78fe8', 'ar', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'إعانات مشاريع للمنظمات غير الربحية العاملة مع الأطفال والشباب ولأجلهم.', '2026-08-28 17:30:50.605858+00'),
	('b8ac8370-5684-44f0-8a41-74293ae95d36', 'ar', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'هل يجرب المشروع تعبيرات أو أساليب أو تعاونات فنية جديدة؟', '2026-08-28 17:30:50.605858+00'),
	('793cc127-fd05-4730-9ed8-04169835fd23', 'ar', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'هل يستمر التبادل من 5 إلى 21 يومًا (دون أيام السفر)؟', '2026-08-28 17:30:50.605858+00'),
	('347b582a-70cd-4c9c-aaf4-5afd4b9dd32f', 'ar', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'دعم المناطق الخاص لمشاريع وأنشطة الحياة الثقافية، إلى جانب إعانات Kulturrådet الوطنية.', '2026-08-28 17:30:50.605858+00'),
	('d93e8cfb-e522-453a-ad8b-2d23c74b1c5d', 'ar', 'Riktar sig projektet till barn eller unga?', 'هل يستهدف المشروع الأطفال أو الشباب؟', '2026-08-28 17:30:50.605858+00'),
	('71e26210-1ac3-4945-8462-c4e3921ce5eb', 'ar', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'هل يستهدف المشروع الأطفال أو الشباب أو كبار السن أو ذوي الإعاقة؟', '2026-08-28 17:30:50.605858+00'),
	('91745634-55fc-48f1-a435-a8fa668f0370', 'ar', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'هل يستهدف النشاط الأطفال والشباب (7–25 عامًا)؟', '2026-08-28 17:30:50.605858+00'),
	('f3e8658c-d8cf-4818-8246-dd0378596be2', 'ar', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'هل تفتقر إلى مدخرات أو أصول يمكن أن تغطي النفقات؟', '2026-08-28 17:30:50.605858+00'),
	('a5e5276a-3f16-4b46-8fa0-94fcc7620d37', 'ar', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'هل تتعاونون مع شركاء في بلدين شماليين آخرين على الأقل؟', '2026-08-28 17:30:50.605858+00'),
	('10146ef8-3d06-4465-ab27-62adeb6a2279', 'ar', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'هل ستجلبون خبرات خارجية لإجراء تطويري؟', '2026-08-28 17:30:50.605858+00'),
	('5389f690-c6d4-4d4a-8036-6e90983b41c7', 'ar', 'Sker mobiliteten till ett annat europeiskt land?', 'هل التنقل إلى بلد أوروبي آخر؟', '2026-08-28 17:30:50.605858+00'),
	('068df863-debb-4aa4-af71-b57579c7713b', 'ar', 'Startar du eller tar du över företaget för första gången?', 'هل تؤسس الشركة أو تتولاها لأول مرة؟', '2026-08-28 17:30:50.605858+00'),
	('a92575aa-94dd-4a7d-885e-24f9b410260c', 'ar', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'دعم بدء لمن هو في سن 40 أو أقل ويؤسس منشأة زراعية أو يتولاها.', '2026-08-28 17:30:50.605858+00'),
	('43e81390-e58d-4b1e-b64a-58e74b879f30', 'ar', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'منحة تتيح للفنانين المحترفين التركيز على عملهم الفني.', '2026-08-28 17:30:50.605858+00'),
	('de8fe366-b720-47fc-8cd8-1c248b44253d', 'ar', 'Studerar du, eller planerar du att börja studera?', 'هل تدرس، أو تخطط لبدء الدراسة؟', '2026-08-28 17:30:50.605858+00'),
	('e7cf76fb-91c1-41ad-90bc-c7a6f8adf8f7', 'ar', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'دعم دراسي للبالغين العاملين الراغبين في التعلم لتقوية وضعهم في سوق العمل.', '2026-08-28 17:30:50.605858+00'),
	('4143f0a0-b944-448f-b060-919af775043a', 'ar', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'دعم للاستثمارات التي تزيد القدرة التنافسية أو تقلل الأثر البيئي في المنشآت الزراعية.', '2026-08-28 17:30:50.605858+00'),
	('8f35d349-4995-4270-b73e-ebab30cce635', 'ar', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'دعم عندما يعيش طفل معك ولا يدفع الوالد الآخر النفقة.', '2026-08-28 17:30:50.605858+00'),
	('52f10ea5-6b10-46be-971d-55ce40620eb7', 'ar', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'دعم لمشاريع المنظمات غير الربحية من أجل الناس والبيئة وعالم أفضل.', '2026-08-28 17:30:50.605858+00'),
	('75a18f71-179e-4507-8f3c-32b2fc097be7', 'ar', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'دعم لمشاريع الفنون والثقافة ذات البعد الشمالي والتعاون عبر الحدود.', '2026-08-28 17:30:50.605858+00'),
	('e7d59015-a7bb-45f5-9e41-cd4dfedbd6ef', 'ar', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'دعم للمشاريع الثقافية المبتكرة التي تجرب تعبيرات أو أساليب أو تعاونات فنية جديدة.', '2026-08-28 17:30:50.605858+00'),
	('68a93701-83c3-4fbb-91c4-d9da3194e570', 'ar', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'دعم للمشاريع المبتكرة للأطفال والشباب وكبار السن وذوي الإعاقة.', '2026-08-28 17:30:50.605858+00'),
	('de780660-0bd9-4a63-9038-f028f2f2583b', 'ar', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'دعم لمشاريع التعاون في المشهد الموسيقي الحر.', '2026-08-28 17:30:50.605858+00'),
	('c73e475e-178e-46f3-9ccc-fec22284006b', 'ar', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'دعم لمشاريع التعاون في الثقافة والإعلام التي تعزز الديمقراطية وحرية التعبير دوليًا.', '2026-08-28 17:30:50.605858+00');
INSERT INTO public.kb_translations VALUES
	('768a1ca3-eb81-41a5-8235-7eefd9200d66', 'ar', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'هل يهدف المشروع إلى تعزيز الديمقراطية أو المساواة أو حرية التعبير؟', '2026-08-28 17:30:50.605858+00'),
	('037b0ab4-8fc9-430a-99d3-4ff6ef1b64b5', 'ar', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'هل تبحث عن عمل، أو حصلت على عرض عمل، في بلد آخر من الاتحاد الأوروبي أو المنطقة الاقتصادية الأوروبية؟', '2026-08-28 17:30:50.605858+00'),
	('13cba796-514d-4742-b848-e33d0ca27ece', 'ar', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقف لما تدفعه من رسوم المرضى خلال فترة اثني عشر شهرًا — بعد ذلك frikort (بطاقة مجانية).', '2026-08-28 17:30:50.605858+00'),
	('8a22737d-e259-4ebb-99a4-76a25037490d', 'ar', 'Tar du ut hel allmän pension?', 'هل تتقاضى معاشك العام كاملًا؟', '2026-08-28 17:30:50.605858+00'),
	('a8446aa9-930a-4d84-bf98-52c69df664c6', 'ar', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'إضافة تغطي جزءًا من تكلفة السكن لمن لديه معاش ودخل منخفض.', '2026-08-28 17:30:50.605858+00'),
	('f9cbb046-85e6-4906-9c36-7d8562dbe967', 'ar', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'إعانة تنظيمية سنوية للمنظمات الوطنية للأطفال والشباب.', '2026-08-28 17:30:50.605858+00'),
	('fb81ac7f-afc6-4b9f-bbb4-c31d18b025c3', 'ar', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'رصيد سنوي يُخصم مباشرة عند طبيب الأسنان أو أخصائي صحة الأسنان.', '2026-08-28 17:30:50.605858+00'),
	('327f07a4-b753-47c7-85dc-3fb3dd47c90c', 'ar', 'Är bolaget yngre än cirka 5 år?', 'هل عمر الشركة أقل من حوالي 5 سنوات؟', '2026-08-28 17:30:50.605858+00'),
	('5e00bc52-5d9f-4124-81c9-f0903dd55297', 'ar', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'هل أعمار المشاركين في التبادل بين 13 و30 عامًا؟', '2026-08-28 17:30:50.605858+00'),
	('50104621-103e-4a9d-a69b-4a0eae72e04f', 'ar', 'Är det här ert första EU-projekt?', 'هل هذا أول مشروع اتحاد أوروبي لكم؟', '2026-08-28 17:30:50.605858+00'),
	('ab580d1e-779b-4d04-be1e-07f30cedc260', 'ar', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'هل من الصعب جدًا عليك (أو على طفلك) التنقل بمفردك أو السفر بالحافلة والقطار؟', '2026-08-28 17:30:50.605858+00'),
	('13209509-65a3-4700-9a1b-8a42fe14609a', 'ar', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'هل دخلك أقل من حوالي 25 000 كرونة شهريًا قبل الضريبة؟', '2026-08-28 17:30:50.605858+00'),
	('2dad31fc-c5c2-4105-93c2-15414ec64509', 'ar', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'هل آخر تعليم أنهيته هو المدرسة الأساسية، أو ثانوية لم تكملها؟', '2026-08-28 17:30:50.605858+00'),
	('7c172ba8-374e-464b-8d28-c3a5804e21a9', 'ar', 'Är du 40 år eller yngre?', 'هل عمرك 40 عامًا أو أقل؟', '2026-08-28 17:30:50.605858+00'),
	('168d539f-98b1-4f27-a3a2-a10f5ab71b88', 'ar', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'هل أنت مسجل كباحث عن عمل لدى Arbetsförmedlingen؟', '2026-08-28 17:30:50.605858+00'),
	('9864d917-2fd5-45e2-90a1-082654727722', 'ar', 'Är du mellan 18 och 28 år?', 'هل عمرك بين 18 و28 عامًا؟', '2026-08-28 17:30:50.605858+00'),
	('f441e040-27df-41dc-a5cf-d2438ff65bbd', 'ar', 'Är du mellan 19 och 29 år?', 'هل عمرك بين 19 و29 عامًا؟', '2026-08-28 17:30:50.605858+00'),
	('3b6972a0-64cb-468d-82b7-b406ba77bdaf', 'ar', 'Är du mellan 25 och 60 år?', 'هل عمرك بين 25 و60 عامًا؟', '2026-08-28 17:30:50.605858+00'),
	('87b5ac16-7aad-417c-b376-6dbf31abfb9d', 'ar', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'هل تعمل باحتراف في المجال الثقافي (مثل الرقص أو الموسيقى أو الفنون الأدائية)؟', '2026-08-28 17:30:50.605858+00'),
	('c92ec7d8-eef0-4efa-a3cf-fb019f403c14', 'ar', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'هل أنت فنان محترف (لست هاويًا ولست في التدريب الأساسي)؟', '2026-08-28 17:30:50.605858+00'),
	('4cef460c-ae42-4a08-8906-b6878c3ee27c', 'ar', 'Är du yrkesverksam konstnär?', 'هل أنت فنان محترف؟', '2026-08-28 17:30:50.605858+00'),
	('d616c4f5-5628-42bf-96b0-51b4657e6d97', 'ar', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'هل حلكم مبتكر جوهريًا مقارنة بما هو موجود بالفعل؟', '2026-08-28 17:30:50.609641+00'),
	('06b9e450-805a-4e79-8036-479f5f0f77a2', 'ar', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'هل النادي منتسب إلى اتحاد رياضي متخصص ضمن Riksidrottsförbundet؟', '2026-08-28 17:30:50.609641+00'),
	('ce37c372-e1be-479c-8413-7a1b35b67077', 'ar', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'هل دخل الأسرة منخفض مقارنة بتكلفة السكن؟', '2026-08-28 17:30:50.609641+00'),
	('e98de529-e6d1-4ce7-a4aa-376e54148ce2', 'ar', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'هل الدخل الإجمالي للأسرة أقل من حوالي 25 000 كرونة شهريًا قبل الضريبة؟', '2026-08-28 17:30:50.609641+00'),
	('79e49ca2-2ef8-46ff-ab23-711541109e53', 'ar', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'هل الإجراء مشروع محدد (وليس النشاط الاعتيادي)؟', '2026-08-28 17:30:50.609641+00'),
	('6874ae6e-b3c4-4deb-82e9-d3b8cfb2472a', 'ar', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'هل المقر مفتوح للجميع — وليس لأعضائكم فقط؟', '2026-08-28 17:30:50.609641+00'),
	('657b829c-f0a7-447e-af0f-412a97583cf3', 'ar', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'هل 60٪ على الأقل من الأعضاء بين 6 و25 عامًا؟', '2026-08-28 17:30:50.609641+00'),
	('56331b9b-7479-49e7-a087-667f590f37f6', 'ar', 'Är minst 60 % av medlemmarna under 26 år?', 'هل 60٪ على الأقل من الأعضاء دون 26 عامًا؟', '2026-08-28 17:30:50.609641+00'),
	('fea95b9c-4419-444c-aebf-0e7cb80b3a36', 'ar', 'Är målgruppen delaktig i planering och genomförande?', 'هل تشارك الفئة المستهدفة في التخطيط والتنفيذ؟', '2026-08-28 17:30:50.609641+00'),
	('e63b52bf-ac70-4a81-87ae-2bd8448787e5', 'ar', 'Är ni ett förlag med professionell utgivning?', 'هل أنتم دار نشر ذات نشر احترافي؟', '2026-08-28 17:30:50.609641+00'),
	('4253fef5-f581-4641-9a99-66a997c1f975', 'ar', 'Är ni huvudman för förskoleklass eller grundskola?', 'هل أنتم الجهة المسؤولة عن صف تمهيدي أو مدرسة أساسية؟', '2026-08-28 17:30:50.609641+00'),
	('0c9231cf-f7cc-4909-ad45-6b6d21892beb', 'ar', 'Är organisationen registrerad i EU:s deltagarregister?', 'هل المنظمة مسجلة في سجل المشاركين للاتحاد الأوروبي؟', '2026-08-28 17:30:50.609641+00'),
	('4662aee2-ce2c-42fe-b75a-52ea8559b2cc', 'ar', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'هل المشروع مشروع سينمائي (فيلم قصير أو وثائقي)؟', '2026-08-28 17:30:50.609641+00'),
	('1816bc38-69e0-44af-a527-5ed950935732', 'ar', 'Är projektet ett konst- eller kulturprojekt?', 'هل المشروع مشروع فني أو ثقافي؟', '2026-08-28 17:30:50.609641+00'),
	('c24533b4-bc31-45a1-abf3-7264476fbb46', 'ar', 'Är projektet ett kulturprojekt?', 'هل المشروع مشروع ثقافي؟', '2026-08-28 17:30:50.609641+00'),
	('12a798a6-50bb-4da8-b681-16ada12a8cf4', 'ar', 'Är projektet ett musikprojekt?', 'هل المشروع مشروع موسيقي؟', '2026-08-28 17:30:50.609641+00'),
	('11106596-b3b2-4bfb-aa2a-51f64ba622ca', 'ar', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'هل المشروع مبتكر — شيء لا تفعلونه بالفعل في نشاطكم الاعتيادي؟', '2026-08-28 17:30:50.609641+00'),
	('30df5d66-30bb-4ad9-a5a0-601cb199b1c4', 'ar', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'هل يفيد المشروع المنطقة ككل (وليس أفرادًا)؟', '2026-08-28 17:30:50.609641+00'),
	('388345b2-4ad3-4a33-b416-13b1d8839c96', 'ar', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'هل الطريق بين المنزل والمدرسة الثانوية ستة كيلومترات على الأقل؟', '2026-08-28 17:30:50.609641+00'),
	('d3aa9f28-9e25-411d-b9fa-af51b3708caa', 'ar', 'Är verksamheten professionell (inte amatörverksamhet)?', 'هل النشاط احترافي (وليس هاويًا)؟', '2026-08-28 17:30:50.609641+00'),
	('f46b1af9-11a4-4247-92da-f7e909b87081', 'ar', 'Är verksamheten professionell?', 'هل النشاط احترافي؟', '2026-08-28 17:30:50.609641+00'),
	('58324f74-e8c4-4de0-8839-bfe4ee6c9443', 'ar', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'هل النشاط فنون أدائية (رقص، مسرح، مسرح موسيقي)؟', '2026-08-28 17:30:50.609641+00'),
	('0a7ae4de-85a1-417e-a2f4-29b7d9370f0d', 'ar', 'Är volontärerna mellan 18 och 30 år?', 'هل أعمار المتطوعين بين 18 و30 عامًا؟', '2026-08-28 17:30:50.609641+00'),
	('a0ad8534-39b0-4fc1-8587-efab4d368862', 'fa', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'حمایت از فعالیت باشگاه‌های ورزشی که فعالیت‌های زیر نظر مربی برای کودکان و جوانان ۷ تا ۲۵ ساله برگزار می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('a0d78a5f-6d3c-412d-b0ec-92daa2605797', 'fa', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'افزودنی خودکار به کمک‌هزینه فرزند (barnbidrag) از فرزند دوم به بعد.', '2026-08-28 17:30:50.61502+00'),
	('f92a1944-cb84-4204-a1c0-6702296322c5', 'fa', 'Avser ansökan en fysisk investering?', 'آیا درخواست مربوط به یک سرمایه‌گذاری فیزیکی است؟', '2026-08-28 17:30:50.61502+00'),
	('b0265763-f4c6-43ee-be83-43a91f8bf106', 'fa', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'آیا درخواست مربوط به یک سفر یا تبادل بین‌المللی است؟', '2026-08-28 17:30:50.61502+00'),
	('f96221f9-c4ef-4a12-80ae-6e7fef145a03', 'fa', 'Avser ansökan en investering i byggnader eller maskiner?', 'آیا درخواست مربوط به سرمایه‌گذاری در ساختمان یا ماشین‌آلات است؟', '2026-08-28 17:30:50.61502+00'),
	('5fb3d82c-8f7d-4b39-84ef-8ff80d996e58', 'fa', 'Avser ansökan en redan utgiven titel?', 'آیا درخواست مربوط به اثری است که قبلاً منتشر شده است؟', '2026-08-28 17:30:50.61502+00');
INSERT INTO public.kb_translations VALUES
	('06f1af41-180c-4d63-bc87-8bcc81f1e9fe', 'fa', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'آیا درخواست مربوط به یک بنگاه کشاورزی، باغبانی یا پرورش گوزن شمالی است؟', '2026-08-28 17:30:50.61502+00'),
	('b355dd59-ede2-49fc-ac0e-3700cc9e2ccd', 'fa', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'آیا درخواست مربوط به خرید کتاب برای کتابخانه‌های عمومی یا مدرسه‌ای است؟', '2026-08-28 17:30:50.61502+00'),
	('c8383816-0c6c-4837-96ad-0daa6fb02e6a', 'fa', 'Avser investeringen jordbruksverksamhet?', 'آیا سرمایه‌گذاری مربوط به فعالیت کشاورزی است؟', '2026-08-28 17:30:50.61502+00'),
	('3a8a2c9d-885a-4efe-ae72-a57298196449', 'fa', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'آیا پروژه شامل ساختن، خریدن یا بازسازی یک محل است؟', '2026-08-28 17:30:50.61502+00'),
	('fbcfff11-8e31-4f4f-a527-ffc24aa70edb', 'fa', 'Avser projektet naturvård eller friluftsliv?', 'آیا پروژه مربوط به حفاظت از طبیعت یا تفریح در فضای باز است؟', '2026-08-28 17:30:50.61502+00'),
	('529aec92-4ac5-4549-8fb6-f56a89b31613', 'fa', 'Avser projektet skola eller vuxenutbildning?', 'آیا پروژه مربوط به مدرسه یا آموزش بزرگسالان است؟', '2026-08-28 17:30:50.61502+00'),
	('aa4304f7-e8ef-4109-b1bb-e3753a94eda9', 'fa', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'آیا از کار صرف‌نظر می‌کنید تا از یکی از نزدیکان که چنان بیمار است که بیماری جانش را تهدید می‌کند مراقبت کنید یا در کنارش باشید؟', '2026-08-28 17:30:50.61502+00'),
	('0ddffc87-455f-4214-9c54-7a311f15582a', 'fa', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'آیا انجمن در شهرداری فعالیت منظم دارد؟', '2026-08-28 17:30:50.61502+00'),
	('77a5e82f-8709-4c7a-944b-3ae864a211f5', 'fa', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'آیا ارزیابی شما این است که توان کاری‌تان به دلیل بیماری یا معلولیت دست‌کم یک سال کاهش یافته است؟', '2026-08-28 17:30:50.61502+00'),
	('63feac08-12b4-4bd8-b180-15501dfa3350', 'fa', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'حمایت نیازسنجی‌شده برای کسی که مستمری کم دارد یا ندارد و برای رسیدن به سطح زندگی معقول به کمک نیاز دارد.', '2026-08-28 17:30:50.61502+00'),
	('e3327441-979d-4859-8382-030516b50dcc', 'fa', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'آیا کودک باید به دلیل طولانی بودن مسیر در محل تحصیل اقامت کند (خوابگاه)؟', '2026-08-28 17:30:50.61502+00'),
	('1e08550d-9810-49f7-bfa0-c6248d8c3a0c', 'fa', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'آیا مسکن نیاز به مناسب‌سازی دارد (مثلاً رمپ، بازکن در، حمام)؟', '2026-08-28 17:30:50.61502+00'),
	('eedaa3c0-c08e-4163-b782-69093271b197', 'fa', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'آیا یکی از فرزندان ۸ تا ۱۹ ساله شما به عینک یا لنز نیاز دارد؟', '2026-08-28 17:30:50.61502+00'),
	('6152d4a7-bf19-4344-8065-7730e434ef90', 'fa', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'آیا والد دیگر هیچ نفقه‌ای نمی‌پردازد یا کمتر از نفقه کامل می‌پردازد؟', '2026-08-28 17:30:50.61502+00'),
	('b01ef1a0-3b3e-47c0-8451-8b0fd9eb85f1', 'fa', 'Betalar du hyra eller andra boendekostnader?', 'آیا اجاره یا هزینه‌های مسکن دیگری می‌پردازید؟', '2026-08-28 17:30:50.61502+00'),
	('4b58386a-8bda-484c-81fe-091c05eda8ca', 'fa', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'کمک‌هزینه برای مناسب‌سازی مسکن در صورت معلولیت — مثلاً رمپ، بازکن در یا مناسب‌سازی حمام.', '2026-08-28 17:30:50.61502+00'),
	('ffeaa2ba-325e-42ef-b61d-52e70f407aa2', 'fa', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'کمک‌هزینه برای ساختن، خریدن یا بازسازی سالن‌های اجتماعات عمومی.', '2026-08-28 17:30:50.61502+00'),
	('dc9da27e-32e5-435c-bfc5-d16dd4c58aee', 'fa', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'کمک‌هزینه برای خرید یا مناسب‌سازی خودرو وقتی معلولیت پایدار جابه‌جایی یا سفر با وسایل نقلیه عمومی را بسیار دشوار می‌کند.', '2026-08-28 17:30:50.61502+00'),
	('12c6faae-92aa-4d31-b10f-8b4defffa565', 'fa', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'کمک‌هزینه برای سفرها و تبادل‌های بین‌المللی حرفه‌ای‌های حوزه فرهنگ.', '2026-08-28 17:30:50.61502+00'),
	('b68d2d22-ff67-413e-babe-dcd66adbf2b2', 'fa', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'کمک‌هزینه برای تبادل‌های بین‌المللی، سفرها و اقامت‌های کاری هنرمندان حرفه‌ای.', '2026-08-28 17:30:50.61502+00'),
	('e29a4e17-16e7-4899-a2f5-6a217ae5e978', 'fa', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'کمک‌هزینه و وام اختیاری برای تحصیل در مقطع دبیرستان یا پس از دبیرستان.', '2026-08-28 17:30:50.61502+00'),
	('c3365402-a0d8-49bb-bc2a-a18a49eb8ac2', 'fa', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'کمک‌هزینه و وام برای تحصیل در خارج، با وام‌های تکمیلی برای مثلاً شهریه و سفر.', '2026-08-28 17:30:50.61502+00'),
	('23b31527-28eb-420c-8f54-43a3d3d17b50', 'fa', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'کمکی که به نهادهای سوئدی در آماده‌سازی درخواست برای برنامه‌های اتحادیه اروپا مانند Horisont Europa یاری می‌رساند.', '2026-08-28 17:30:50.61502+00'),
	('ffc854ef-ed82-4a53-87ec-632958d289a1', 'fa', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'کمک‌هزینه برای کارفرمایانی که افراد با توان کاری کاهش‌یافته را استخدام می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('cfc63a33-f199-41dd-9b7b-1854f1519f64', 'fa', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'کمک‌هزینه اقامت و سفرهای بازگشت به خانه وقتی دانش‌آموز دبیرستانی به دلیل مسیر طولانی باید در محل تحصیل اقامت کند.', '2026-08-28 17:30:50.61502+00'),
	('a43884f1-2988-4417-a4de-0de33247a88d', 'fa', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'کمک‌هزینه برای کار سازمان‌های غیرانتفاعی در حفظ، استفاده و توسعه میراث فرهنگی.', '2026-08-28 17:30:50.61502+00'),
	('8b2ef61a-f41d-47a6-8611-82dfcf8e2b35', 'fa', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'کمک‌هزینه برای پروژه‌های شهری و محلی حفاظت از طبیعت، از جمله تالاب‌ها و تفریح در فضای باز.', '2026-08-28 17:30:50.61502+00'),
	('a2df90dc-6b82-493f-99a0-4c0550056af9', 'fa', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'کمک‌هزینه به شهرداری‌ها برای خرید کتاب برای کتابخانه‌های عمومی و مدرسه‌ای.', '2026-08-28 17:30:50.61502+00'),
	('f2b33515-2b07-4182-b84a-626b11f7accc', 'fa', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'کمک‌هزینه به مسئولان مدارس برای آشنایی دانش‌آموزان دوره ابتدایی با فرهنگ حرفه‌ای.', '2026-08-28 17:30:50.61502+00'),
	('beabd1c9-abac-4cac-a399-11ec83c57c03', 'fa', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'کمک‌هزینه برای آنچه فرزندتان نیاز دارد اما بودجه خانواده کفاف نمی‌دهد: فعالیت‌های اوقات فراغت، لباس، اردوهای مدرسه، عینک، فعالیت‌های تعطیلات و غیره.', '2026-08-28 17:30:50.61502+00'),
	('03c81c33-793f-4ee4-923a-8df64ae8536a', 'fa', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'کمک‌هزینه از صندوق‌هایی مانند Världens Barn و Musikhjälpen و Victoriafonden — سازمان‌های غیرانتفاعی سوئدی دارای 90-konto آن را درخواست می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('cccc064c-226a-45d2-bad6-d37f771e204b', 'fa', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'کمک‌هزینه از محل درآمدهای برق‌آبی و بادی برای پروژه‌هایی که منطقه را توسعه می‌دهند.', '2026-08-28 17:30:50.61502+00'),
	('8d83d917-637f-4e06-a503-100b6dd80ece', 'fa', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'کمک‌هزینه بدون بخش وام برای بیکاران ۲۵ تا ۶۰ ساله با تحصیلات کوتاه که باید در سطح مدرسه ابتدایی یا دبیرستان تحصیل کنند.', '2026-08-28 17:30:50.61502+00'),
	('16d6a5c6-1bea-4ba6-aebc-0966d3dde8d2', 'fa', 'Bidrar projektet till energiomställningen?', 'آیا پروژه به گذار انرژی کمک می‌کند؟', '2026-08-28 17:30:50.61502+00'),
	('c5c801d7-eb0e-4625-ab86-94565c0ddc6c', 'fa', 'Bor du och barnets andra förälder på skilda håll?', 'آیا شما و والد دیگر کودک جدا از هم زندگی می‌کنید؟', '2026-08-28 17:30:50.61502+00'),
	('c3bd9391-4518-4c39-b3c6-a2da2d542776', 'fa', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'چک‌هایی برای شرکت‌های کوچک برای به‌کارگیری تخصص بیرونی در بین‌المللی‌سازی یا دیجیتالی‌سازی.', '2026-08-28 17:30:50.61502+00'),
	('b5bec3b8-a693-4950-a57e-e4eefe741a8e', 'fa', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'آیا در برنامه‌ای نزد Arbetsförmedlingen شرکت می‌کنید (مثلاً jobb- och utvecklingsgarantin)؟', '2026-08-28 17:30:50.61502+00'),
	('f8c0aecf-c241-4d0b-ba07-57ee9a2e40a2', 'fa', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'حمایت پسینی از ناشران برای انتشار ادبیات باکیفیت.', '2026-08-28 17:30:50.61502+00'),
	('1e7618d1-51ef-4029-9ab7-4efbef38aef1', 'fa', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'حمایت مالی برای کسی که اجازه اقامت مرتبط با حمایت دارد و داوطلبانه می‌خواهد برای همیشه به کشور مبدأ بازگردد.', '2026-08-28 17:30:50.61502+00'),
	('53936642-8cf1-4337-93cb-47a0fc6b9081', 'fa', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'حمایت مالی از کارفرمایانی که فردی را استخدام می‌کنند که مدت طولانی از زندگی کاری دور بوده است.', '2026-08-28 17:30:50.61502+00'),
	('b611ccb3-616e-40f2-84f7-cd1fffe62b91', 'fa', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'حمایت مالی در دوره راه‌اندازی برای جویندگان کار که کسب‌وکار خود را آغاز می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('fafce187-8789-417d-bb3c-0b3812905882', 'fa', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten به‌طور مستمر فراخوان‌هایی در پژوهش انرژی، نوآوری و بهره‌وری انرژی برگزار می‌کند.', '2026-08-28 17:30:50.61502+00'),
	('92fda661-44e3-47c2-8205-3e41466074fa', 'fa', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'پرداختی برای غیبت از کار یا تحصیل به‌منظور مراقبت از کودک.', '2026-08-28 17:30:50.61502+00'),
	('d039a4b0-3edd-492f-ba59-eb7e4e045bb4', 'fa', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'پرداختی برای کسی که تازه‌وارد سوئد است و در برنامه استقرار Arbetsförmedlingen شرکت می‌کند؛ توسط Försäkringskassan پرداخت می‌شود.', '2026-08-28 17:30:50.61502+00'),
	('880f9a64-ae15-4f99-aa4f-a5a344729a86', 'fa', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'پرداختی که بخشی از هزینه مسکن جوانان بدون فرزند با درآمد کم را می‌پوشاند.', '2026-08-28 17:30:50.61502+00'),
	('4596b0ab-ffeb-4dca-b1ed-df773a8c08a5', 'fa', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'پرداختی برای هزینه‌های اضافی ناشی از معلولیت پایدار — برای بزرگسالان یا والدین کودکان دارای معلولیت.', '2026-08-28 17:30:50.61502+00'),
	('4ae9f6ee-bb70-4a50-bb78-20b66d75a194', 'fa', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'پرداختی برای جوانان (۱۹–۲۹ ساله) که به دلیل بیماری یا معلولیت دست‌کم یک سال نمی‌توانند تمام‌وقت کار کنند.', '2026-08-28 17:30:50.61502+00'),
	('8822a359-e980-443d-8bc1-f92b93f94503', 'fa', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'پرداختی وقتی توان کاری به‌طور پایدار کاهش یافته است — آنچه پیش‌تر förtidspension (بازنشستگی پیش از موعد) نامیده می‌شد.', '2026-08-28 17:30:50.61502+00'),
	('9c18bf74-d7b8-4518-adb3-fd08b26754f2', 'fa', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'پرداختی وقتی از کار صرف‌نظر می‌کنید تا در کنار یکی از نزدیکانِ به‌شدت بیمار باشید.', '2026-08-28 17:30:50.61502+00'),
	('e5d333c3-be4c-4b6a-a919-2dae9aa1bfed', 'fa', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'پرداختی هنگام شرکت شما در یک برنامه بازار کار نزد Arbetsförmedlingen.', '2026-08-28 17:30:50.61502+00');
INSERT INTO public.kb_translations VALUES
	('d6fead0e-4fe2-43bc-ac61-8f95ebf16215', 'fa', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'پرداختی وقتی به دلیل بیماری نمی‌توانید مانند معمول کار کنید.', '2026-08-28 17:30:50.61502+00'),
	('4f75f603-9bc5-4239-a7b3-9681c4798e00', 'fa', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'پرداختی وقتی برای مراقبت از کودک بیمار در خانه می‌مانید.', '2026-08-28 17:30:50.61502+00'),
	('390d765f-f89e-45f3-a5cc-78001814908e', 'fa', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'پرداختی که بخشی از هزینه مسکن خانوارهای دارای فرزند و درآمد پایین‌تر را می‌پوشاند.', '2026-08-28 17:30:50.61502+00'),
	('7a93cb7b-8116-4977-b235-501a198a7fb1', 'fa', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'پرداختی برای والدینی که فرزندشان به دلیل معلولیت به مراقبت و نظارت بیشتری از کودکان هم‌سن نیاز دارد.', '2026-08-28 17:30:50.61502+00'),
	('6e749998-cfd1-4305-9c14-514d9958fc51', 'fa', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'پرداختی در دوران بیکاری — مبتنی بر درآمد برای اعضا، مبلغ پایه برای دیگران.', '2026-08-28 17:30:50.61502+00'),
	('d930ef9c-8fa2-4c7e-8dd2-466456c000ea', 'fa', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'حدود پنجاه بنیاد بانک‌های پس‌انداز به پروژه‌های محلی در ورزش، فرهنگ، آموزش و توسعه اجتماعی کمک می‌کنند — در حوزه فعالیت بانک.', '2026-08-28 17:30:50.61502+00'),
	('14f247f4-4995-4d8b-ba95-dd4bf03e42ee', 'fa', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'حمایت پروژه‌ای با بودجه اتحادیه اروپا که نزد منطقه Leader محلی شما درخواست می‌شود — برای انجمن‌ها، شرکت‌ها و شهرداری‌هایی که روستاها را توسعه می‌دهند.', '2026-08-28 17:30:50.61502+00'),
	('608dd509-93cb-4f71-bc19-3341d0e8d951', 'fa', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'حمایت با بودجه اتحادیه اروپا برای جویندگان کار که در کشور دیگری از اتحادیه اروپا/منطقه اقتصادی اروپا کاری می‌پذیرند: جبران هزینه سفر مصاحبه، هزینه اسباب‌کشی و دوره زبان.', '2026-08-28 17:30:50.61502+00'),
	('6ed191f8-1aa5-4530-a5ab-dde38253e21a', 'fa', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'بودجه صندوق اجتماعی اروپا برای پروژه‌هایی که مهارت‌ها، گذار شغلی و شمول در بازار کار را تقویت می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('82a1fa7d-9f17-4ce5-9ff5-b3ab9d1ab769', 'fa', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'حمایت اتحادیه اروپا از تبادل‌های گروهی جوانان ۱۳ تا ۳۰ ساله، به مدت ۵ تا ۲۱ روز بدون روزهای سفر.', '2026-08-28 17:30:50.61502+00'),
	('76ac68c4-a7c9-46c2-af2e-bb62673bdf87', 'fa', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'حمایت اتحادیه اروپا از پروژه‌های همکاری سازمان‌های فرهنگی با شرکایی در چند کشور اروپایی.', '2026-08-28 17:30:50.61502+00'),
	('bc2061af-7bb6-4025-a6e1-b1825a241826', 'fa', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'حمایت اتحادیه اروپا از سازمان‌هایی که داوطلبان جوان ۱۸ تا ۳۰ ساله را می‌پذیرند یا می‌فرستند.', '2026-08-28 17:30:50.61502+00'),
	('c889bbc4-1666-42b6-8edc-49802f778b6b', 'fa', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'حمایت اتحادیه اروپا از تحرک کارکنان و دانش‌آموزان در مدرسه و آموزش بزرگسالان.', '2026-08-28 17:30:50.61502+00'),
	('7c481e60-2320-4844-b0b9-eae3600370a4', 'fa', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'حمایت اتحادیه اروپا با مبالغ مقطوع برای نخستین پروژه‌های همکاری اروپایی سازمان‌های کوچک‌تر.', '2026-08-28 17:30:50.61502+00'),
	('594315d8-3ac2-423d-8b00-c4a2eb45c045', 'fa', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تأمین مالی برای شرکت‌های جوانی که محصولات یا خدمات نوآورانه با ظرفیت بین‌المللی توسعه می‌دهند.', '2026-08-28 17:30:50.61502+00'),
	('d0eb0332-a7b9-44b3-acd2-e56f290b2156', 'prs', 'Bor du och barnets andra förälder på skilda håll?', 'آیا شما و والد دیگر طفل جدا از هم زندگی می‌کنید؟', '2026-08-28 17:30:50.623518+00'),
	('ee8ec6c4-5194-414c-a1ae-9025e720fe2b', 'fa', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'آیا در محل فعالیت شما بانک پس‌اندازی (و در نتیجه بنیاد بانک پس‌انداز) وجود دارد؟', '2026-08-28 17:30:50.61502+00'),
	('547cfef9-8ff8-4317-ad55-e1b988823e32', 'fa', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'کمک‌هزینه فعالیت چندساله برای گروه‌های مستقل حرفه‌ای رقص، تئاتر و تئاتر موزیکال.', '2026-08-28 17:30:50.61502+00'),
	('b820fcc3-b077-4c38-979f-e2de9e584110', 'fa', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'کمک‌هزینه پژوهشی در حوزه‌های Forte: سلامت، زندگی کاری و رفاه. پژوهشگران دارای دکترا در دانشگاه‌های سوئد درخواست می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('5ad7f5cf-68f8-4df1-8327-6147355ab605', 'fa', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'بودجه پژوهشی برای پژوهش بنیادی آزاد در همه حوزه‌های علمی.', '2026-08-28 17:30:50.61502+00'),
	('da3b0726-bb1c-428b-929f-3acb3e176d25', 'fa', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'بودجه پژوهشی در محیط‌زیست، علوم کشاورزی و شهرسازی.', '2026-08-28 17:30:50.61502+00'),
	('a1ad73ec-2d19-4533-8619-6884d1e26df3', 'fa', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'آیا به مهاجرت به خارج فکر می‌کنید (برای کار، تحصیل یا بازگشت به وطن)؟', '2026-08-28 17:30:50.61502+00'),
	('ed4157ce-d3dc-4aa3-a655-e56c396e08a0', 'fa', 'Genomförs insatserna av professionella kulturaktörer?', 'آیا فعالیت‌ها را کنشگران فرهنگی حرفه‌ای اجرا می‌کنند؟', '2026-08-28 17:30:50.61502+00'),
	('8feca7f5-415d-4f36-a1c4-efd7a2d59214', 'fa', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'آیا پروژه در روستا یا در شهرک کوچکی اجرا می‌شود؟', '2026-08-28 17:30:50.61502+00'),
	('03adc653-c0b1-46e5-9b59-276c1063228e', 'fa', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حمایت پایه برای کسی که در طول زندگی درآمد کاری کم یا هیچ نداشته است.', '2026-08-28 17:30:50.61502+00'),
	('4540f880-dba8-4365-8e16-a9d45081a59a', 'fa', 'Går något av dina barn i grundskolan?', 'آیا یکی از فرزندانتان به مدرسه ابتدایی می‌رود؟', '2026-08-28 17:30:50.61502+00'),
	('2141b781-2fd8-4ef1-86ec-f6bf6c46412a', 'fa', 'Går något av dina barn på gymnasiet?', 'آیا یکی از فرزندانتان در دبیرستان تحصیل می‌کند؟', '2026-08-28 17:30:50.61502+00'),
	('4de636e9-f708-40d7-a02c-1201b4e88924', 'fa', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'آیا استخدام مربوط به فردی با توان کاری کاهش‌یافته است؟', '2026-08-28 17:30:50.61502+00'),
	('f9c7a84e-7af8-448b-9141-231fae2b1e16', 'fa', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'آیا استخدام مربوط به کسی است که مدت طولانی بیکار بوده یا تازه‌وارد سوئد است؟', '2026-08-28 17:30:50.61502+00'),
	('9ef870e6-d2eb-40d0-ade8-2ab13bcd1c9b', 'fa', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'آیا پروژه درباره حفظ میراث فرهنگی یا دسترس‌پذیر کردن آن است؟', '2026-08-28 17:30:50.61502+00'),
	('bc334767-a740-41c6-95e6-d435bd498cec', 'fa', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'آیا پروژه درباره انرژی، بهره‌وری انرژی یا نوآوری مرتبط با انرژی است؟', '2026-08-28 17:30:50.61502+00'),
	('34a590b7-da6f-4733-8dea-a3d0e917bfc4', 'fa', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'آیا پروژه درباره سلامت، زندگی کاری یا رفاه است؟', '2026-08-28 17:30:50.61502+00'),
	('13f4d7c3-d0a0-48c4-b784-b9a439d6cba5', 'fa', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'آیا پروژه درباره توسعه مهارت‌ها یا اقدامات بازار کار است؟', '2026-08-28 17:30:50.61502+00'),
	('0aadeb29-f1ba-4339-abca-6ee4229a5bd5', 'fa', 'Handlar projektet om miljö- eller klimatåtgärder?', 'آیا پروژه درباره اقدامات زیست‌محیطی یا اقلیمی است؟', '2026-08-28 17:30:50.61502+00'),
	('7ae3bdac-6b7c-4eae-97e1-74cd33d9c71d', 'fa', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'آیا مسیر کودک به مدرسه طولانی، به دلیل ترافیک خطرناک یا به شکل دیگری دشوار است؟', '2026-08-28 17:30:50.61502+00'),
	('d87baf1c-cca6-4fcf-9a23-5a9d5fdeafc4', 'fa', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'آیا دست‌کم ۱۶ ساعت در هفته و در مجموع دست‌کم ۸ سال کار کرده‌اید؟', '2026-08-28 17:30:50.61502+00'),
	('1a97bdd3-2c0e-41e5-bcf0-e71e9442438f', 'fa', 'Har du barn som bor hos dig, helt eller växelvis?', 'آیا فرزندانی دارید که نزد شما زندگی می‌کنند، تمام‌وقت یا به‌تناوب؟', '2026-08-28 17:30:50.61502+00'),
	('04aa1bdf-1d69-4f34-b1c5-4bb2cb495362', 'fa', 'Har du barn som bor hos dig?', 'آیا فرزندانی دارید که نزد شما زندگی می‌کنند؟', '2026-08-28 17:30:50.61502+00'),
	('1819836e-f961-4189-b36e-f609b461c69b', 'fa', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'آیا شما یا فرزندتان معلولیتی دارید که انتظار می‌رود دست‌کم یک سال ادامه یابد؟', '2026-08-28 17:30:50.61502+00'),
	('e259c07f-366e-44fd-93e3-7a63fe5f90b1', 'fa', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'آیا شما یا کسی در خانوار معلولیت پایداری دارد که بر مسکن اثر می‌گذارد؟', '2026-08-28 17:30:50.61502+00'),
	('2a1528f8-e324-4c82-a1de-cb55dd7dadf6', 'fa', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'آیا شما یا یکی از نزدیکان معلولیت یا بیماری طولانی یا جدی دارید؟', '2026-08-28 17:30:50.61502+00'),
	('b18dc7d5-4e25-4bb0-9319-6686238ea5c7', 'fa', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'آیا بیماری یا آسیبی دارید که هم‌اکنون توان کاری شما را کاهش می‌دهد؟', '2026-08-28 17:30:50.61502+00'),
	('c5912f1c-537e-4763-b70e-004377ce94cd', 'fa', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'آیا تاکنون در پرداخت هزینه اردوی مدرسه، سفر کلاسی یا فعالیت اوقات فراغتی که انتظار می‌رود فرزندتان در آن شرکت کند مشکل داشته‌اید؟', '2026-08-28 17:30:50.61502+00'),
	('7706caec-abfd-463f-87be-f95a3f9a8757', 'fa', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'آیا گذران زندگی با مستمری و سایر درآمدهایتان برایتان دشوار است؟', '2026-08-28 17:30:50.61502+00'),
	('98da9fa2-7b1f-4cd1-b89c-69a988e0a809', 'fa', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'آیا در سال‌های اخیر اجازه اقامت در سوئد گرفته‌اید، مثلاً به‌عنوان نیازمند حمایت یا عضو خانواده؟', '2026-08-28 17:30:50.61502+00'),
	('a9f6c3f7-eea3-4818-96b3-68c34df18a8d', 'fa', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'آیا اجازه اقامت در سوئد به‌عنوان پناهنده یا نیازمند حمایت دارید (یا از بستگان نزدیک چنین کسی هستید)؟', '2026-08-28 17:30:50.61502+00'),
	('1063eec9-2018-4d43-a5da-c9e38f0c9ef0', 'fa', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'آیا به سن مرجع بازنشستگی رسیده‌اید (۶۷ سال در ۲۰۲۶)؟', '2026-08-28 17:30:50.61502+00'),
	('7ec630b3-69ab-4959-ae35-659d5ed29646', 'fa', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'آیا سازمان شما OID (Organisation ID) ثبت‌شده در Organisation Registration System اتحادیه اروپا دارد؟', '2026-08-28 17:30:50.61502+00'),
	('31a36b22-cbb1-450b-a51d-460234f0ef75', 'fa', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'آیا معلولیت هزینه‌های اضافی به همراه داشته است — مثلاً وسایل کمکی، سفر، رژیم غذایی خاص یا استهلاک؟', '2026-08-28 17:30:50.61502+00'),
	('eeacc768-51ae-4239-99ac-fe19f1d8bdc2', 'fa', 'Har föreningen antagna stadgar och en vald styrelse?', 'آیا انجمن اساسنامه مصوب و هیئت‌مدیره منتخب دارد؟', '2026-08-28 17:30:50.61502+00');
INSERT INTO public.kb_translations VALUES
	('a1758e15-75d1-47a3-bd0b-275adf34647a', 'fa', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'آیا انجمن ساختار دموکراتیک دارد (اساسنامه، مجمع سالانه، هیئت‌مدیره)؟', '2026-08-28 17:30:50.61502+00'),
	('cd6ee6c3-3cd8-4336-9659-43a9e0ab2077', 'fa', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'آیا انجمن فعالیت منظمی برای کودکان یا جوانان دارد؟', '2026-08-28 17:30:50.61502+00'),
	('33bf7626-38a9-4e06-a340-31f47c4a8adc', 'fa', 'Har företaget mellan cirka 2 och 49 anställda?', 'آیا شرکت بین حدود ۲ تا ۴۹ کارمند دارد؟', '2026-08-28 17:30:50.61502+00'),
	('c603281e-b268-4c46-a8c2-1491a2e26e83', 'fa', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'آیا خانوار در تأمین هزینه‌های خوراک، مسکن و ضروری‌ترین چیزها مشکل دارد؟', '2026-08-28 17:30:50.61502+00'),
	('5876f658-f21e-4e57-a67a-94fdc59b9d51', 'fa', 'Har lösningen internationell potential?', 'آیا راه‌حل ظرفیت بین‌المللی دارد؟', '2026-08-28 17:30:50.61502+00'),
	('02ab8956-b10c-4bb8-989f-6ca961cedece', 'fa', 'Har ni en partnergrupp i ett annat land?', 'آیا گروه شریکی در کشور دیگری دارید؟', '2026-08-28 17:30:50.61502+00'),
	('0731b56f-d602-4e5c-aa7d-9b5fc6accd2b', 'fa', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'آیا سازمان شریکی در کشور اروپایی دیگری دارید؟', '2026-08-28 17:30:50.61502+00'),
	('13e5ee28-d601-4d67-9607-190e04c51424', 'fa', 'Har ni partner i minst tre olika europeiska länder?', 'آیا در دست‌کم سه کشور اروپایی مختلف شریک دارید؟', '2026-08-28 17:30:50.61502+00'),
	('ae16c60c-e4b6-48e5-9a41-187ed024f553', 'fa', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'آیا دفتر مرکزی یا فعالیت اصلی شما در منطقه‌ای است که در آن درخواست می‌دهید؟', '2026-08-28 17:30:50.61502+00'),
	('799ceb9a-45f8-48ff-95cb-c7b18d724453', 'fa', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'آیا یکی از فرزندانتان معلولیتی دارد که باعث می‌شود به مراقبت یا نظارت بیشتری از کودکان هم‌سن نیاز داشته باشد؟', '2026-08-28 17:30:50.61502+00'),
	('ef4ec272-2215-4a89-ad6d-81e55fd7b57c', 'fa', 'Har organisationen en demokratisk uppbyggnad?', 'آیا سازمان ساختار دموکراتیک دارد؟', '2026-08-28 17:30:50.61502+00'),
	('4022a1f8-8064-4bd4-a48c-5900eb2bc840', 'fa', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'آیا سازمان Quality Label (نشان کیفیت) دارد؟', '2026-08-28 17:30:50.61502+00'),
	('c2f736ca-1446-465c-9275-6b67be9b2376', 'fa', 'Har organisationen ett 90-konto?', 'آیا سازمان 90-konto دارد؟', '2026-08-28 17:30:50.61502+00'),
	('90a0a2ae-3fcc-4fa5-b109-023a913de3d2', 'fa', 'Har organisationen ett OID (Organisation ID)?', 'آیا سازمان OID (Organisation ID) دارد؟', '2026-08-28 17:30:50.61502+00'),
	('2396e7c6-d972-4b71-b1a9-ba896ddad44d', 'fa', 'Har organisationen ett OID?', 'آیا سازمان OID دارد؟', '2026-08-28 17:30:50.61502+00'),
	('c7b68857-3a37-47c2-a37f-288832eb8362', 'fa', 'Har organisationen medlemsföreningar i flera län?', 'آیا سازمان انجمن‌های عضو در چند استان دارد؟', '2026-08-28 17:30:50.61502+00'),
	('017d1f8f-50bf-4a13-a15f-5cb21a9a4cf5', 'fa', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'آیا سازمان مالی منظم و ساختار دموکراتیک دارد؟', '2026-08-28 17:30:50.61502+00'),
	('d7ed021e-bd1e-4ec0-8102-c8c8cfd84a96', 'fa', 'Har projektet en partner i ett annat land?', 'آیا پروژه شریکی در کشور دیگری دارد؟', '2026-08-28 17:30:50.61502+00'),
	('4755bdfd-1581-482c-882b-3b7e1264404d', 'fa', 'Har projektledaren doktorsexamen?', 'آیا سرپرست پروژه مدرک دکترا دارد؟', '2026-08-28 17:30:50.61502+00'),
	('0472817a-3b1c-4b03-9acd-56b47678c10a', 'fa', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'شهرداری محل سکونت باید رفت‌وآمد روزانه میان خانه و دبیرستان را وقتی مسیر دست‌کم شش کیلومتر است تأمین کند (مثلاً کارت اتوبوس).', '2026-08-28 17:30:50.61502+00'),
	('1a6714d6-f793-4dab-a341-43ae103f8c83', 'fa', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'آیا در حال تهیه یا تجهیز نخستین خانه شخصی خود در سوئد هستید؟', '2026-08-28 17:30:50.61502+00'),
	('36080a63-5374-41cb-9930-a62576595575', 'fa', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'آیا پروژه شامل سفر یا تبادل بین‌المللی است؟', '2026-08-28 17:30:50.61502+00'),
	('ae9bda2f-3daf-4104-b258-d25b29f9dfc2', 'fa', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'حمایت سرمایه‌گذاری از شرکت‌ها در مناطق حمایتی برای ساختمان، ماشین‌آلات و آموزش.', '2026-08-28 17:30:50.61502+00'),
	('1970d83d-c26d-4b08-b9a0-bab26d4187ca', 'fa', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'حمایت سرمایه‌گذاری از اقداماتی که انتشار گازهای گلخانه‌ای را کاهش می‌دهند.', '2026-08-28 17:30:50.61502+00'),
	('a5d3f3c7-e856-4673-9a1f-7276c7d6ce29', 'fa', 'Kan projektets miljönytta mätas?', 'آیا فایده زیست‌محیطی پروژه قابل اندازه‌گیری است؟', '2026-08-28 17:30:50.61502+00'),
	('924c90ca-5052-4f53-abdc-b02ee627fffa', 'fa', 'Kan åtgärdens utsläppsminskning beräknas?', 'آیا کاهش انتشار حاصل از اقدام قابل محاسبه است؟', '2026-08-28 17:30:50.61502+00'),
	('13cb1276-a000-4ffe-ae57-6bc3faa18a71', 'fa', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'آیا سازمان می‌تواند هزینه‌ها را تا پرداخت حمایت بر عهده بگیرد؟', '2026-08-28 17:30:50.61502+00'),
	('11f5ca94-524b-412a-9a15-6ed9458fb724', 'fa', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'آیا تجربه‌ها در فعالیت شما در سوئد به کار گرفته می‌شوند؟', '2026-08-28 17:30:50.61502+00'),
	('de016e16-d8cf-4568-87f8-f51a55b6c091', 'fa', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'آیا سرمایه‌گذاری تنها پس از ارسال درخواست آغاز می‌شود؟', '2026-08-28 17:30:50.61502+00'),
	('955966d9-5f3e-4cde-95ee-8abfe9ef7745', 'fa', 'Kommer projektet människor i ert närområde till del?', 'آیا پروژه به مردم منطقه شما سود می‌رساند؟', '2026-08-28 17:30:50.61502+00'),
	('a92ac744-2f46-454c-a4c8-8888d93ee6ca', 'fa', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'واپسین تور ایمنی اقتصادی شهرداری وقتی درآمدها کفاف ضروری‌ترین چیزها را نمی‌دهند.', '2026-08-28 17:30:50.61502+00'),
	('47660d6e-2f28-4441-94b6-6cf3a96e0f0f', 'fa', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'حمایت شروع برای کسی که ۴۰ ساله یا جوان‌تر است و بنگاه کشاورزی راه می‌اندازد یا تحویل می‌گیرد.', '2026-08-28 17:30:50.61502+00'),
	('08507bd1-e8c0-4ec6-b453-da970bf88f59', 'fa', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'حمایت‌های خود شهرداری‌ها از انجمن‌های محلی: کمک‌هزینه فعالیت به ازای هر جلسه، کمک‌هزینه محل، کمک‌هزینه شروع و غیره.', '2026-08-28 17:30:50.61502+00'),
	('456ef404-3f9e-4709-a115-d0d8a4d3089a', 'fa', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'سرویس رایگان مدرسه برای دانش‌آموزان ابتدایی در صورت مسافت طولانی، مسیر پرخطر یا معلولیت — حقی طبق قانون مدارس.', '2026-08-28 17:30:50.61502+00'),
	('6f95ff58-39b8-4112-bde1-04433cf76c79', 'fa', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'کمک‌هزینه قانونی عینک یا لنز برای کودکان و جوانان؛ مبالغ و روال‌ها در هر استان متفاوت است — سطح استان خود را بررسی کنید.', '2026-08-28 17:30:50.61502+00'),
	('880d414b-c936-41b4-ae8c-07bb7a7c97aa', 'fa', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'آیا پروژه در منطقه‌ای است که برق‌آبی یا بادی به آن مربوط می‌شود؟', '2026-08-28 17:30:50.61502+00'),
	('85bdb537-f6f9-4911-9928-c31a2d6e5ebe', 'fa', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'آیا پروژه در حوزه محیط‌زیست، علوم کشاورزی یا شهرسازی است؟', '2026-08-28 17:30:50.61502+00'),
	('0270eb1e-35fd-49ea-9563-8484d9b37626', 'fa', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'آیا محل فعالیت در منطقه حمایتی A یا B است (بخش‌های بزرگ نورلند و سوئالند داخلی)؟', '2026-08-28 17:30:50.61502+00'),
	('cac8e056-cac3-4a89-8128-3559910bf40a', 'fa', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'وامی برای خرید ضروری‌ترین چیزها برای نخستین خانه در سوئد — مبلمان، لوازم خانه و دیگر تجهیزات پایه.', '2026-08-28 17:30:50.61502+00'),
	('921822a3-c7bb-4923-9e4f-abd224808fbe', 'fa', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'آیا پروژه انتشار فرایندی صنعت را کاهش می‌دهد یا انتشار منفی ایجاد می‌کند؟', '2026-08-28 17:30:50.61502+00'),
	('91b68b6b-eed4-43d8-a07a-b85246c61f67', 'fa', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'کمک‌هزینه ماهانه برای کودکان ساکن سوئد، از تولد تا ۱۶ سالگی.', '2026-08-28 17:30:50.61502+00'),
	('24647a7a-bb3f-40e8-85ad-301caa52ad9e', 'fa', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket به سازمان‌ها، شرکت‌ها، انجمن‌ها، بخش عمومی و اشخاص در حوزه محیط‌زیست کمک‌هزینه می‌دهد.', '2026-08-28 17:30:50.61502+00'),
	('784018aa-e83c-46af-a898-0d7d6e4a73cf', 'fa', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'آیا قصد دارید داوطلبانه برای همیشه به کشور مبدأ بازگردید؟', '2026-08-28 17:30:50.61502+00'),
	('bfbc4d56-f533-4885-9dae-f7814bf0c1f0', 'fa', 'Planerar du att starta eget företag?', 'آیا قصد دارید کسب‌وکار خود را راه بیندازید؟', '2026-08-28 17:30:50.61502+00'),
	('af7f7afc-32f0-439b-a315-8ffd214d5bf2', 'fa', 'Planerar du att studera utomlands?', 'آیا قصد تحصیل در خارج را دارید؟', '2026-08-28 17:30:50.61502+00'),
	('cb85886f-d147-4acf-ae8d-0b6e8a7cb2d6', 'fa', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'آیا قصد تحصیلی دارید که جایگاه شما را در بازار کار تقویت کند؟', '2026-08-28 17:30:50.61502+00'),
	('7c05e7d1-8321-47f7-adc8-aab365266078', 'fa', 'Planerar ni att anställa?', 'آیا قصد استخدام دارید؟', '2026-08-28 17:30:50.61502+00'),
	('f91a70db-42a7-4509-ac7e-c3b1454f9ba5', 'fa', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'آیا قصد دارید برای برنامه‌ای از اتحادیه اروپا (مثلاً Horisont Europa) درخواست دهید؟', '2026-08-28 17:30:50.61502+00'),
	('22a19a36-f272-4806-a288-2b7e697c1d53', 'fa', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'حمایت از تولید و توسعه فیلم کوتاه و مستند.', '2026-08-28 17:30:50.61502+00'),
	('630babf9-4776-4189-880a-28778889a49c', 'fa', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'کمک‌هزینه پروژه‌ای برای صحنه موسیقی مستقل: کنسرت، تولید و توسعه.', '2026-08-28 17:30:50.61502+00');
INSERT INTO public.kb_translations VALUES
	('37d5e27c-cc8e-4540-a15f-713c643d2d4e', 'fa', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'کمک‌هزینه پروژه‌ای برای سازمان‌های غیرانتفاعی که با کودکان و جوانان و برای آنان کار می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('6a26dbcc-6258-4300-9292-1b18a5d80a3b', 'fa', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'آیا پروژه بیان‌ها، روش‌ها یا همکاری‌های هنری تازه‌ای می‌آزماید؟', '2026-08-28 17:30:50.61502+00'),
	('1c44d898-75b1-4cb4-9cc0-a0781e5afbc4', 'fa', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'آیا تبادل ۵ تا ۲۱ روز طول می‌کشد (بدون روزهای سفر)؟', '2026-08-28 17:30:50.61502+00'),
	('0df7be27-48bd-4c06-a053-eac660e17e9d', 'fa', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'حمایت‌های خود استان‌ها از پروژه‌ها و فعالیت‌های فرهنگی، در کنار کمک‌های ملی Kulturrådet.', '2026-08-28 17:30:50.61502+00'),
	('2b884b04-5ec2-468b-acaa-b343f1185e77', 'fa', 'Riktar sig projektet till barn eller unga?', 'آیا پروژه کودکان یا جوانان را هدف می‌گیرد؟', '2026-08-28 17:30:50.61502+00'),
	('64b79877-ddf7-4560-90d9-490ac11a55d5', 'fa', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'آیا پروژه کودکان، جوانان، سالمندان یا افراد دارای معلولیت را هدف می‌گیرد؟', '2026-08-28 17:30:50.61502+00'),
	('81a4bfd8-6066-4034-b811-87b31b053a5e', 'fa', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'آیا فعالیت کودکان و جوانان (۷–۲۵ ساله) را هدف می‌گیرد؟', '2026-08-28 17:30:50.61502+00'),
	('2de2318c-7b8c-4fd9-a569-b2a964c42a02', 'fa', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'آیا پس‌انداز یا دارایی‌ای ندارید که بتواند هزینه‌ها را بپوشاند؟', '2026-08-28 17:30:50.61502+00'),
	('c2646fa2-6902-42f2-a7f9-addca0d5e977', 'fa', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'آیا با شرکایی در دست‌کم دو کشور شمال اروپای دیگر همکاری می‌کنید؟', '2026-08-28 17:30:50.61502+00'),
	('37d542c2-ddbb-401b-8dc1-9f722711c1a2', 'fa', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'آیا برای یک اقدام توسعه‌ای تخصص بیرونی به کار می‌گیرید؟', '2026-08-28 17:30:50.61502+00'),
	('edd67ffc-46fa-4a78-b2b4-8fdd1c6a6332', 'fa', 'Sker mobiliteten till ett annat europeiskt land?', 'آیا تحرک به کشور اروپایی دیگری است؟', '2026-08-28 17:30:50.61502+00'),
	('878a5e81-6b99-4b98-a24b-e1caf2d71077', 'fa', 'Startar du eller tar du över företaget för första gången?', 'آیا برای نخستین بار کسب‌وکار را راه می‌اندازید یا تحویل می‌گیرید؟', '2026-08-28 17:30:50.61502+00'),
	('18fe2980-8be4-4e5d-9553-4b4c1774e3bd', 'fa', 'Är du yrkesverksam konstnär?', 'آیا هنرمند حرفه‌ای هستید؟', '2026-08-28 17:30:50.61502+00'),
	('875a4424-8d9a-4d06-be31-9f41b6e26c43', 'fa', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'بورسیه‌ای که به هنرمندان حرفه‌ای امکان می‌دهد بر کار هنری تمرکز کنند.', '2026-08-28 17:30:50.61502+00'),
	('edfe78af-bb9a-4681-8320-fc11248b4f11', 'fa', 'Studerar du, eller planerar du att börja studera?', 'آیا تحصیل می‌کنید یا قصد شروع تحصیل دارید؟', '2026-08-28 17:30:50.61502+00'),
	('cd601639-6d34-4872-a9de-7ac03f057dd4', 'fa', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'حمایت تحصیلی برای بزرگسالان شاغل که می‌خواهند برای تقویت جایگاه خود در بازار کار آموزش ببینند.', '2026-08-28 17:30:50.61502+00'),
	('54eebbc9-1273-472b-912f-5eb11adf69e3', 'fa', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'حمایت از سرمایه‌گذاری‌هایی که رقابت‌پذیری را افزایش یا اثرات زیست‌محیطی را در بنگاه‌های کشاورزی کاهش می‌دهند.', '2026-08-28 17:30:50.61502+00'),
	('9a6a46be-5e72-4c00-bba7-b792a0f754ef', 'fa', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'حمایتی وقتی کودکی نزد شما زندگی می‌کند و والد دیگر نفقه نمی‌پردازد.', '2026-08-28 17:30:50.61502+00'),
	('cd041f99-e342-4c8f-a0a7-267d38dac7ea', 'fa', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'حمایت از پروژه‌های سازمان‌های غیرانتفاعی برای مردم، محیط‌زیست و جهانی بهتر.', '2026-08-28 17:30:50.61502+00'),
	('9ed88fa4-a6c6-4127-8da3-cf1f73604cac', 'fa', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'حمایت از گذار صنعت به سوی انتشار صفر گازهای گلخانه‌ای.', '2026-08-28 17:30:50.61502+00'),
	('a37cbcda-ae05-49b1-b892-0d9d8ab6dfc7', 'fa', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'حمایت از پروژه‌های هنری و فرهنگی با بُعد نوردیک و همکاری فرامرزی.', '2026-08-28 17:30:50.61502+00'),
	('fb7a9d5f-950d-45fa-9359-c3b27a00c152', 'fa', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'حمایت از پروژه‌های فرهنگی نوآورانه که بیان‌ها، روش‌ها یا همکاری‌های هنری تازه می‌آزمایند.', '2026-08-28 17:30:50.61502+00'),
	('e5273a4a-d468-4695-a57d-00aed0facfda', 'fa', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'حمایت از پروژه‌های نوآورانه برای کودکان، جوانان، سالمندان و افراد دارای معلولیت.', '2026-08-28 17:30:50.61502+00'),
	('7a11e207-9017-431a-abf9-3563901b33b2', 'fa', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'حمایت از پروژه‌های همکاری در صحنه موسیقی مستقل.', '2026-08-28 17:30:50.61502+00'),
	('d1317625-a6cc-4972-b6f8-bb49e9f43a19', 'fa', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'حمایت از پروژه‌های همکاری در فرهنگ و رسانه که دموکراسی و آزادی بیان را در سطح بین‌المللی تقویت می‌کنند.', '2026-08-28 17:30:50.61502+00'),
	('a6939802-144f-4856-9098-7c114ad8a1c2', 'fa', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'آیا هدف پروژه تقویت دموکراسی، برابری یا آزادی بیان است؟', '2026-08-28 17:30:50.61502+00'),
	('5269a2fd-921f-421f-aa48-7816bf5929d0', 'fa', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'آیا در کشور دیگری از اتحادیه اروپا یا منطقه اقتصادی اروپا دنبال کار می‌گردید یا پیشنهاد کاری گرفته‌اید؟', '2026-08-28 17:30:50.61502+00'),
	('6b1544ac-5ec3-4fe8-b114-18233ea15b69', 'fa', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقفی برای آنچه در دوره دوازده‌ماهه بابت هزینه‌های بیمار می‌پردازید — پس از آن frikort (کارت رایگان).', '2026-08-28 17:30:50.61502+00'),
	('ff1bb9da-52fd-4dc7-8893-2f008bdacae3', 'fa', 'Tar du ut hel allmän pension?', 'آیا مستمری عمومی کامل خود را دریافت می‌کنید؟', '2026-08-28 17:30:50.61502+00'),
	('10942511-7c25-44e7-8711-202cd62fcd17', 'fa', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'افزودنی‌ای که بخشی از هزینه مسکن را برای کسی که مستمری و درآمد کم دارد می‌پوشاند.', '2026-08-28 17:30:50.61502+00'),
	('b2cd180c-eb7c-440e-a182-35efb31dbcdc', 'fa', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'کمک‌هزینه سازمانی سالانه برای سازمان‌های ملی کودکان و جوانان.', '2026-08-28 17:30:50.61502+00'),
	('421fb474-fe2a-4d9b-b902-9b8c36d68150', 'fa', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'اعتبار سالانه‌ای که مستقیماً نزد دندان‌پزشک یا بهداشت‌کار دهان کسر می‌شود.', '2026-08-28 17:30:50.61502+00'),
	('8cb335eb-4475-4b36-8dfa-6382b9ca7548', 'fa', 'Är bolaget yngre än cirka 5 år?', 'آیا عمر شرکت کمتر از حدود ۵ سال است؟', '2026-08-28 17:30:50.61502+00'),
	('f09509da-9d6c-403f-9aa2-50ec07731d0c', 'fa', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'آیا شرکت‌کنندگان تبادل بین ۱۳ و ۳۰ سال دارند؟', '2026-08-28 17:30:50.61502+00'),
	('0cd5c693-a15d-4a3d-823e-d67f17e14ea3', 'fa', 'Är det här ert första EU-projekt?', 'آیا این نخستین پروژه اتحادیه اروپای شماست؟', '2026-08-28 17:30:50.61502+00'),
	('8afdce34-dddb-4dad-87fa-6dacfee7a8a8', 'fa', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'آیا برای شما (یا فرزندتان) جابه‌جایی مستقل یا سفر با اتوبوس و قطار بسیار دشوار است؟', '2026-08-28 17:30:50.61502+00'),
	('73669dd1-6a38-4b43-b9b0-86c823cf62ef', 'fa', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا درآمد شما کمتر از حدود ۲۵٬۰۰۰ کرون در ماه پیش از مالیات است؟', '2026-08-28 17:30:50.61502+00'),
	('7e35e098-e3aa-495c-bde8-f941d619d65d', 'fa', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'آیا آخرین تحصیل تمام‌شده شما مدرسه ابتدایی است، یا دبیرستانی که تمامش نکردید؟', '2026-08-28 17:30:50.61502+00'),
	('669fe111-d00b-4540-9484-7d299f4bbcf6', 'fa', 'Är du 40 år eller yngre?', 'آیا ۴۰ ساله یا جوان‌تر هستید؟', '2026-08-28 17:30:50.61502+00'),
	('f1d5754e-dd68-4ffe-9d7b-ec532d62ec42', 'fa', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'آیا به‌عنوان جوینده کار نزد Arbetsförmedlingen ثبت‌نام کرده‌اید؟', '2026-08-28 17:30:50.61502+00'),
	('6d038031-5799-4546-9f8c-5db1ef5dda89', 'fa', 'Är du mellan 18 och 28 år?', 'آیا بین ۱۸ و ۲۸ سال دارید؟', '2026-08-28 17:30:50.61502+00'),
	('608a3b82-44fb-492a-b446-919fdad9b8a7', 'fa', 'Är du mellan 19 och 29 år?', 'آیا بین ۱۹ و ۲۹ سال دارید؟', '2026-08-28 17:30:50.61502+00'),
	('21e4ae3b-8f83-4481-99e9-b6df8c48ebaa', 'fa', 'Är du mellan 25 och 60 år?', 'آیا بین ۲۵ و ۶۰ سال دارید؟', '2026-08-28 17:30:50.61502+00'),
	('197bef4e-7a38-48bc-a051-055098d08901', 'fa', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'آیا به‌طور حرفه‌ای در حوزه فرهنگ فعالیت می‌کنید (مثلاً رقص، موسیقی، هنرهای نمایشی)؟', '2026-08-28 17:30:50.61502+00'),
	('57a08d8e-e09a-40ca-aa8e-90b0a0bf4201', 'fa', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'آیا هنرمند حرفه‌ای هستید (نه آماتور و نه در آموزش پایه)؟', '2026-08-28 17:30:50.61502+00'),
	('89f8cde0-2396-4823-935c-4994e90ccf9c', 'fa', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'آیا راه‌حل شما در مقایسه با آنچه موجود است اساساً نوآورانه است؟', '2026-08-28 17:30:50.618668+00'),
	('26f1bdb4-81f1-40ca-a457-cc0ebf19b376', 'fa', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'آیا باشگاه به فدراسیون ورزشی تخصصی درون Riksidrottsförbundet وابسته است؟', '2026-08-28 17:30:50.618668+00'),
	('ce2842de-0276-4887-957c-195faf93f221', 'fa', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'آیا درآمد خانوار نسبت به هزینه مسکن پایین است؟', '2026-08-28 17:30:50.618668+00'),
	('416dfdfe-2844-4b21-9a29-ec309c5265a2', 'fa', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا درآمد جمعی خانوار کمتر از حدود ۲۵٬۰۰۰ کرون در ماه پیش از مالیات است؟', '2026-08-28 17:30:50.618668+00'),
	('a96c6412-2431-4fe6-9be3-e43efa805e1d', 'fa', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'آیا اقدام یک پروژه مشخص است (نه فعالیت عادی)؟', '2026-08-28 17:30:50.618668+00');
INSERT INTO public.kb_translations VALUES
	('742d675d-3186-49be-b253-a93dcf442fe2', 'fa', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'آیا محل برای همه باز است — نه فقط اعضای خودتان؟', '2026-08-28 17:30:50.618668+00'),
	('887f4ad4-8f20-4166-a6d0-2e45f5859840', 'fa', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'آیا دست‌کم ۶۰ درصد اعضا بین ۶ و ۲۵ سال دارند؟', '2026-08-28 17:30:50.618668+00'),
	('99e78528-ccc2-4ccf-b321-c0a1621b9afe', 'fa', 'Är minst 60 % av medlemmarna under 26 år?', 'آیا دست‌کم ۶۰ درصد اعضا زیر ۲۶ سال هستند؟', '2026-08-28 17:30:50.618668+00'),
	('bf492c4e-29b0-418e-aee8-ec56b4391f74', 'fa', 'Är målgruppen delaktig i planering och genomförande?', 'آیا گروه هدف در برنامه‌ریزی و اجرا مشارکت دارد؟', '2026-08-28 17:30:50.618668+00'),
	('31ae88f3-71ee-4d49-ac7b-40334c4cf94e', 'fa', 'Är ni ett förlag med professionell utgivning?', 'آیا ناشری با انتشار حرفه‌ای هستید؟', '2026-08-28 17:30:50.618668+00'),
	('e2dcebfd-07ec-40cf-95c7-9f03e271a2e4', 'fa', 'Är ni huvudman för förskoleklass eller grundskola?', 'آیا مسئول یک کلاس پیش‌دبستانی یا مدرسه ابتدایی هستید؟', '2026-08-28 17:30:50.618668+00'),
	('b3b5e95f-bd08-4b33-b95e-52b8ada543b1', 'fa', 'Är organisationen registrerad i EU:s deltagarregister?', 'آیا سازمان در فهرست شرکت‌کنندگان اتحادیه اروپا ثبت شده است؟', '2026-08-28 17:30:50.618668+00'),
	('c96b5dce-0c9d-4340-a261-e4d2df238d01', 'fa', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'آیا پروژه یک پروژه سینمایی است (فیلم کوتاه یا مستند)؟', '2026-08-28 17:30:50.618668+00'),
	('d5dcfd96-2227-452e-a694-54206fd0bec1', 'fa', 'Är projektet ett konst- eller kulturprojekt?', 'آیا پروژه یک پروژه هنری یا فرهنگی است؟', '2026-08-28 17:30:50.618668+00'),
	('af326695-1095-45fa-8281-9d43d40041a5', 'fa', 'Är projektet ett kulturprojekt?', 'آیا پروژه یک پروژه فرهنگی است؟', '2026-08-28 17:30:50.618668+00'),
	('44432e59-4e04-4d9f-b867-bbce9c6bf7fc', 'fa', 'Är projektet ett musikprojekt?', 'آیا پروژه یک پروژه موسیقایی است؟', '2026-08-28 17:30:50.618668+00'),
	('a820fc1b-a949-42ed-bb9c-e3e793459898', 'fa', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'آیا پروژه نوآورانه است — کاری که هم‌اکنون در فعالیت عادی انجام نمی‌دهید؟', '2026-08-28 17:30:50.618668+00'),
	('ca8d4c87-b713-475c-b266-007a1cd042f3', 'fa', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'آیا پروژه به کل منطقه سود می‌رساند (نه به اشخاص)؟', '2026-08-28 17:30:50.618668+00'),
	('f79452d2-aa88-4a98-818b-dd4fab1aa325', 'fa', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'آیا مسیر میان خانه و دبیرستان دست‌کم شش کیلومتر است؟', '2026-08-28 17:30:50.618668+00'),
	('4e0eaecc-8ad2-4f21-b7a4-9a5605ebff78', 'fa', 'Är verksamheten professionell (inte amatörverksamhet)?', 'آیا فعالیت حرفه‌ای است (نه آماتوری)؟', '2026-08-28 17:30:50.618668+00'),
	('f8c528e7-44db-4fcf-93f0-e0f612ded6b0', 'fa', 'Är verksamheten professionell?', 'آیا فعالیت حرفه‌ای است؟', '2026-08-28 17:30:50.618668+00'),
	('c9d85127-846d-49bc-beb9-bd48ce0122df', 'fa', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'آیا فعالیت از هنرهای نمایشی است (رقص، تئاتر، تئاتر موزیکال)؟', '2026-08-28 17:30:50.618668+00'),
	('fd957264-2bca-4ff8-badb-d5ff011be597', 'fa', 'Är volontärerna mellan 18 och 30 år?', 'آیا داوطلبان بین ۱۸ و ۳۰ سال دارند؟', '2026-08-28 17:30:50.618668+00'),
	('f37b9e44-b347-4b55-a01c-29021642f32e', 'prs', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'حمایت از فعالیت کلپ‌های ورزشی که فعالیت‌های زیر نظر مربی برای اطفال و جوانان ۷ تا ۲۵ ساله برگزار می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('1226d163-193c-41cd-98c5-bd4b227b3942', 'prs', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'اضافه خودکار بر کمک مالی اطفال (barnbidrag) از طفل دوم به بعد.', '2026-08-28 17:30:50.623518+00'),
	('75789aaa-5451-47d7-976c-a2bedb5edddf', 'prs', 'Avser ansökan en fysisk investering?', 'آیا درخواست مربوط به یک سرمایه‌گذاری فزیکی است؟', '2026-08-28 17:30:50.623518+00'),
	('2b641e6a-05b6-45cf-975f-e23cd6b78331', 'prs', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'آیا درخواست مربوط به یک سفر یا تبادله بین‌المللی است؟', '2026-08-28 17:30:50.623518+00'),
	('7ddcb2da-74c4-49ae-948e-d45a4643f44a', 'prs', 'Avser ansökan en investering i byggnader eller maskiner?', 'آیا درخواست مربوط به سرمایه‌گذاری در تعمیرات یا ماشین‌آلات است؟', '2026-08-28 17:30:50.623518+00'),
	('dd025dd5-6026-4d17-a28e-6475947a4d50', 'prs', 'Avser ansökan en redan utgiven titel?', 'آیا درخواست مربوط به اثری است که قبلاً چاپ شده است؟', '2026-08-28 17:30:50.623518+00'),
	('80bb9f4d-0978-4bbc-ba1f-9b059a2b286d', 'prs', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'آیا درخواست مربوط به یک تشبث زراعتی، باغداری یا پرورش گوزن شمالی است؟', '2026-08-28 17:30:50.623518+00'),
	('9a8cfabb-e857-4cc7-9b19-e94bb8d9a762', 'prs', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'آیا درخواست مربوط به خرید کتاب برای کتابخانه‌های عامه یا مکتب است؟', '2026-08-28 17:30:50.623518+00'),
	('1713a885-54e2-48f9-972e-03fcd236491b', 'prs', 'Avser investeringen jordbruksverksamhet?', 'آیا سرمایه‌گذاری مربوط به فعالیت زراعتی است؟', '2026-08-28 17:30:50.623518+00'),
	('9eddb38b-cf18-413a-a656-e854d446966c', 'prs', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'آیا پروژه شامل ساختن، خریدن یا ترمیم یک محل است؟', '2026-08-28 17:30:50.623518+00'),
	('6c784a67-3049-4687-8a31-9bd36cee3ae5', 'prs', 'Avser projektet naturvård eller friluftsliv?', 'آیا پروژه مربوط به حفاظت از طبیعت یا تفریح در هوای آزاد است؟', '2026-08-28 17:30:50.623518+00'),
	('5466a6e5-77ff-4bf3-96c0-d40429427b12', 'prs', 'Avser projektet skola eller vuxenutbildning?', 'آیا پروژه مربوط به مکتب یا آموزش بزرگسالان است؟', '2026-08-28 17:30:50.623518+00'),
	('bcc7c96e-184f-49a1-878e-0cc872a212ac', 'prs', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'آیا از کار دست می‌کشید تا از یکی از نزدیکان که چنان سخت مریض است که مریضی جانش را تهدید می‌کند مراقبت کنید یا در کنارش باشید؟', '2026-08-28 17:30:50.623518+00'),
	('601095b9-6966-4e19-8f73-6efad2d1fcfb', 'prs', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'آیا انجمن در شاروالی فعالیت منظم دارد؟', '2026-08-28 17:30:50.623518+00'),
	('6266e7d6-657b-4194-881c-0927d6af0027', 'prs', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'آیا فکر می‌کنید توان کاری‌تان به دلیل مریضی یا معلولیت دست‌کم برای یک سال کاهش یافته است؟', '2026-08-28 17:30:50.623518+00'),
	('a6a1c0ea-45d2-458a-928a-9cd777f9cf3f', 'prs', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'حمایت نیازسنجی‌شده برای کسی که تقاعد کم دارد یا ندارد و برای رسیدن به سطح زندگی مناسب به کمک ضرورت دارد.', '2026-08-28 17:30:50.623518+00'),
	('22bfb7b5-66de-4fd7-b923-56d1a5760825', 'prs', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'آیا طفل باید به دلیل درازی راه در محل درس اقامت کند (بودوباش)؟', '2026-08-28 17:30:50.623518+00'),
	('5286ffa2-58d7-481f-bebd-1ea0e26eb194', 'prs', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'آیا منزل به مناسب‌سازی ضرورت دارد (مثلاً رمپ، بازکننده دروازه، تشناب)؟', '2026-08-28 17:30:50.623518+00'),
	('ed73b98f-87ed-4fc7-8d33-2eb98c81f802', 'prs', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'آیا یکی از اطفال ۸ تا ۱۹ ساله شما به عینک یا لنز ضرورت دارد؟', '2026-08-28 17:30:50.623518+00'),
	('aa0b7854-b8d6-4bf9-abcd-5c35fa838725', 'prs', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'آیا والد دیگر هیچ نفقه نمی‌پردازد یا کمتر از نفقه کامل می‌پردازد؟', '2026-08-28 17:30:50.623518+00'),
	('7f971b77-b0f6-4b23-ae82-5a89ac131224', 'prs', 'Betalar du hyra eller andra boendekostnader?', 'آیا کرایه یا مصارف دیگر مسکن می‌پردازید؟', '2026-08-28 17:30:50.623518+00'),
	('2f0c2e2b-1c91-4074-9cb0-e3016a6e73b7', 'prs', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'کمک مالی برای مناسب‌سازی منزل در صورت معلولیت — مثلاً رمپ، بازکننده دروازه یا مناسب‌سازی تشناب.', '2026-08-28 17:30:50.623518+00'),
	('393bc271-88ea-49d9-b4cf-0c1a0edb6429', 'prs', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'کمک‌های مالی برای ساختن، خریدن یا ترمیم سالون‌های اجتماعات عامه.', '2026-08-28 17:30:50.623518+00'),
	('03f1d6d4-ef91-43db-accb-58f6457bbc42', 'prs', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'کمک مالی برای خرید یا مناسب‌سازی موتر وقتی معلولیت دایمی گشت‌وگذار یا سفر با ترانسپورت عامه را بسیار دشوار می‌سازد.', '2026-08-28 17:30:50.623518+00'),
	('bf4021ae-db1f-49fc-9600-d35b4ead8cba', 'prs', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'کمک‌های مالی برای سفرها و تبادله‌های بین‌المللی مسلکی‌های عرصه فرهنگ.', '2026-08-28 17:30:50.623518+00'),
	('381c9b57-9ad9-4d35-8539-e5cd3ffc321e', 'prs', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'کمک‌های مالی برای تبادله‌های بین‌المللی، سفرها و اقامت‌های کاری هنرمندان مسلکی.', '2026-08-28 17:30:50.623518+00'),
	('61e1a64b-5200-4eb5-9b98-1a9d79a168a7', 'prs', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'کمک مالی و قرضه اختیاری برای درس در سویه لیسه یا بالاتر از لیسه.', '2026-08-28 17:30:50.623518+00'),
	('011e1989-4924-4008-8b02-9a1b35d98023', 'prs', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'کمک‌های مالی و قرضه برای تحصیل در خارج، با قرضه‌های اضافی برای مثلاً فیس تحصیلی و سفر.', '2026-08-28 17:30:50.623518+00'),
	('11afaf02-59f3-490e-a892-bfe2df81645a', 'prs', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'کمکی که به نهادهای سویدنی در آماده‌سازی درخواست برای برنامه‌های اتحادیه اروپا مانند Horisont Europa یاری می‌رساند.', '2026-08-28 17:30:50.623518+00'),
	('1e632b1b-105b-4cb0-ae84-0316295bf28f', 'prs', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'کمک مالی برای کارفرمایانی که افراد دارای توان کاری کاهش‌یافته را استخدام می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('f14b0141-34da-4cac-8892-f2724667ed8e', 'prs', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'کمک مالی برای بودوباش و سفرهای بازگشت به خانه وقتی شاگرد لیسه به دلیل درازی راه باید در محل درس اقامت کند.', '2026-08-28 17:30:50.623518+00'),
	('e29b6fe9-a566-4d66-a6e0-7004b3aaf132', 'prs', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'کمک‌های مالی برای کار سازمان‌های غیرانتفاعی در حفظ، استفاده و انکشاف میراث فرهنگی.', '2026-08-28 17:30:50.623518+00');
INSERT INTO public.kb_translations VALUES
	('9a4db418-79e2-4cf8-bd88-3f5221f4cca1', 'prs', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'کمک‌های مالی برای پروژه‌های شاروالی و محلی حفاظت از طبیعت، به شمول ساحات مرطوب و تفریح در هوای آزاد.', '2026-08-28 17:30:50.623518+00'),
	('405546b1-4c1b-410c-94e7-9e8bd2002970', 'prs', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'کمک‌های مالی به شاروالی‌ها برای خرید کتاب برای کتابخانه‌های عامه و مکتب.', '2026-08-28 17:30:50.623518+00'),
	('6e1ce2d0-95f7-4133-98ff-f4c1eb91a620', 'prs', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'کمک‌های مالی به مسئولان مکاتب برای آشنایی شاگردان مکتب ابتداییه با فرهنگ مسلکی.', '2026-08-28 17:30:50.623518+00'),
	('1b650771-4591-42b1-aa45-b754a19df236', 'prs', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'کمک مالی برای آنچه طفل‌تان ضرورت دارد اما بودجه فامیل کفایت نمی‌کند: فعالیت‌های تفریحی، لباس، سیرهای مکتب، عینک، فعالیت‌های رخصتی و غیره.', '2026-08-28 17:30:50.623518+00'),
	('4cf12ca7-2e4d-4e9a-8594-e52f047a0466', 'prs', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'کمک‌های مالی از صندوق‌هایی مانند Världens Barn و Musikhjälpen و Victoriafonden — سازمان‌های غیرانتفاعی سویدنی دارای 90-konto آن را درخواست می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('33b4f855-2e46-46d7-9c1e-973ffeda771f', 'prs', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'کمک‌های مالی از عواید برق آبی و بادی برای پروژه‌هایی که منطقه را انکشاف می‌دهند.', '2026-08-28 17:30:50.623518+00'),
	('259a513c-d2f9-446a-b722-751d359f8dbe', 'prs', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'کمک مالی بدون بخش قرضه برای بیکاران ۲۵ تا ۶۰ ساله با تحصیلات کوتاه که باید در سویه مکتب ابتداییه یا لیسه درس بخوانند.', '2026-08-28 17:30:50.623518+00'),
	('63f66483-a4f9-4a74-bc87-e0ad968491a9', 'prs', 'Bidrar projektet till energiomställningen?', 'آیا پروژه به گذار انرژی کمک می‌کند؟', '2026-08-28 17:30:50.623518+00'),
	('3909739d-4848-40b1-934f-2c703157062d', 'prs', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'چک‌هایی برای شرکت‌های کوچک برای جلب تخصص بیرونی در بین‌المللی‌سازی یا دیجیتل‌سازی.', '2026-08-28 17:30:50.623518+00'),
	('19e16a74-bf01-4207-94a0-6ca783e064af', 'prs', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'آیا در برنامه‌ای نزد Arbetsförmedlingen شرکت می‌کنید (مثلاً jobb- och utvecklingsgarantin)؟', '2026-08-28 17:30:50.623518+00'),
	('29a560a2-8d51-4048-a3b1-6976f32d5812', 'prs', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'حمایت بعدی از ناشران برای چاپ ادبیات باکیفیت.', '2026-08-28 17:30:50.623518+00'),
	('681a5d7a-228b-4d0d-8a8a-170329ffc4d4', 'prs', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'حمایت مالی برای کسی که جواز اقامت مرتبط با حمایت دارد و داوطلبانه می‌خواهد برای همیشه به کشور اصلی خود برگردد.', '2026-08-28 17:30:50.623518+00'),
	('44b938b8-625e-4b63-91cd-b1b26a1cc1ba', 'prs', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'حمایت مالی از کارفرمایانی که کسی را استخدام می‌کنند که مدت زیادی از زندگی کاری دور بوده است.', '2026-08-28 17:30:50.623518+00'),
	('9da37f59-2ee4-4476-b2fc-d2574e714de5', 'prs', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'حمایت مالی در دوره آغاز برای جویندگان کار که تشبث خود را شروع می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('ef72e874-866b-4db4-a58a-3840c2f1ab37', 'prs', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten به‌طور دوامدار فراخوان‌هایی در تحقیقات انرژی، نوآوری و مؤثریت انرژی باز می‌کند.', '2026-08-28 17:30:50.623518+00'),
	('744568a0-6a85-41c2-a6f0-3383b07c58a8', 'prs', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'پرداختی برای غیرحاضری از کار یا درس به‌خاطر مراقبت از طفل.', '2026-08-28 17:30:50.623518+00'),
	('0e0e6e7a-5bff-44e3-ac15-58595e78120a', 'prs', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'پرداختی برای کسی که تازه‌وارد سویدن است و در برنامه استقرار Arbetsförmedlingen شرکت می‌کند؛ توسط Försäkringskassan پرداخت می‌شود.', '2026-08-28 17:30:50.623518+00'),
	('e488dae5-441e-4437-85c6-d80a87aca5f7', 'prs', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'پرداختی که بخشی از مصارف مسکن جوانان بدون اطفال با عاید کم را می‌پوشاند.', '2026-08-28 17:30:50.623518+00'),
	('972395b0-d2f4-4638-accc-d53edae224f3', 'prs', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'پرداختی برای مصارف اضافی ناشی از معلولیت دایمی — برای بزرگسالان یا والدین اطفال دارای معلولیت.', '2026-08-28 17:30:50.623518+00'),
	('8a0ba165-a831-4241-a907-9e095ad0ea95', 'prs', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'پرداختی برای جوانان (۱۹–۲۹ ساله) که به دلیل مریضی یا معلولیت دست‌کم یک سال نمی‌توانند تمام‌وقت کار کنند.', '2026-08-28 17:30:50.623518+00'),
	('4e73b255-7bd7-49c2-aacf-6352994bb55d', 'prs', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'پرداختی وقتی توان کاری به‌طور دایمی کاهش یافته است — آنچه پیش‌تر förtidspension (تقاعد پیش از وقت) نامیده می‌شد.', '2026-08-28 17:30:50.623518+00'),
	('065ca75f-9e26-43e5-ac02-9f614cbaa4f5', 'prs', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'پرداختی وقتی از کار دست می‌کشید تا در کنار یکی از نزدیکانِ سخت مریض باشید.', '2026-08-28 17:30:50.623518+00'),
	('6f521eee-e72a-4d1f-a8ca-06e6f12a980a', 'prs', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'پرداختی هنگام شرکت شما در برنامه بازار کار نزد Arbetsförmedlingen.', '2026-08-28 17:30:50.623518+00'),
	('9260616d-0c8f-412e-802f-de12a8e4c048', 'prs', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'پرداختی وقتی به دلیل مریضی نمی‌توانید مانند معمول کار کنید.', '2026-08-28 17:30:50.623518+00'),
	('8e83d3fb-47e3-48ca-aba8-7963bc21baf5', 'prs', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'پرداختی وقتی برای مراقبت از طفل مریض در خانه می‌مانید.', '2026-08-28 17:30:50.623518+00'),
	('f63fce5d-b8ee-48f4-a96b-3cd2c5060e95', 'prs', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'پرداختی که بخشی از مصارف مسکن فامیل‌های دارای اطفال و عاید پایین‌تر را می‌پوشاند.', '2026-08-28 17:30:50.623518+00'),
	('e85b31d1-7214-4c40-82d1-ea342bc47b91', 'prs', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'پرداختی برای والدینی که طفل‌شان به دلیل معلولیت به مراقبت و نظارت بیشتری نسبت به اطفال هم‌سن ضرورت دارد.', '2026-08-28 17:30:50.623518+00'),
	('65e36df5-5e04-477d-8233-345e44ec3494', 'prs', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'پرداختی در دوران بیکاری — بر اساس عاید برای اعضا، مبلغ اساسی برای دیگران.', '2026-08-28 17:30:50.623518+00'),
	('2ea348b9-87bd-475c-affc-df02768ffefa', 'prs', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'در حدود پنجاه بنیاد بانک‌های پس‌انداز به پروژه‌های محلی در ورزش، فرهنگ، تعلیم و انکشاف اجتماعی کمک مالی می‌دهند — در ساحه فعالیت بانک.', '2026-08-28 17:30:50.623518+00'),
	('18d4b269-19a7-4d04-9421-23951655fbdb', 'prs', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'حمایت پروژه‌ای با بودجه اتحادیه اروپا که نزد ساحه Leader محلی شما درخواست می‌شود — برای انجمن‌ها، شرکت‌ها و شاروالی‌هایی که دهات را انکشاف می‌دهند.', '2026-08-28 17:30:50.623518+00'),
	('768311d6-e2a8-4f0d-97f9-29173ff44036', 'prs', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'حمایت با بودجه اتحادیه اروپا برای جویندگان کار که در کشور دیگری از اتحادیه اروپا/ساحه اقتصادی اروپا وظیفه می‌گیرند: جبران مصارف سفر مصاحبه، مصارف کوچ‌کشی و کورس زبان.', '2026-08-28 17:30:50.623518+00'),
	('5a31167e-da47-4211-a285-763c3943a5cd', 'prs', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'بودجه صندوق اجتماعی اروپا برای پروژه‌هایی که مهارت‌ها، گذار وظیفوی و شمولیت در بازار کار را تقویت می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('eea77aa9-aedb-4a03-8da0-e3c73b76a50c', 'prs', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'حمایت اتحادیه اروپا از تبادله‌های گروهی جوانان ۱۳ تا ۳۰ ساله، برای ۵ تا ۲۱ روز بدون روزهای سفر.', '2026-08-28 17:30:50.623518+00'),
	('24a5199e-a0ba-46c6-8959-7f3347a4e52d', 'prs', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'حمایت اتحادیه اروپا از پروژه‌های همکاری سازمان‌های فرهنگی با شرکایی در چند کشور اروپایی.', '2026-08-28 17:30:50.623518+00'),
	('a5fdfec0-681b-4d97-9140-b3b7ab62304d', 'prs', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'حمایت اتحادیه اروپا از سازمان‌هایی که رضاکاران جوان ۱۸ تا ۳۰ ساله را می‌پذیرند یا می‌فرستند.', '2026-08-28 17:30:50.623518+00'),
	('fd5f0f0c-5e0b-4b69-b226-ff723016b9f0', 'prs', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'حمایت اتحادیه اروپا از تحرک کارمندان و شاگردان در مکتب و آموزش بزرگسالان.', '2026-08-28 17:30:50.623518+00'),
	('93782170-ecaf-436f-be87-90b19558dffc', 'prs', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'حمایت اتحادیه اروپا با مبالغ مقطوع برای نخستین پروژه‌های همکاری اروپایی سازمان‌های کوچک‌تر.', '2026-08-28 17:30:50.623518+00'),
	('1e5e70ef-657d-4dd7-8872-1e434fc2edf1', 'prs', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تمویل شرکت‌های جوانی که محصولات یا خدمات نوآورانه با ظرفیت بین‌المللی انکشاف می‌دهند.', '2026-08-28 17:30:50.623518+00'),
	('4fd58f84-ed23-471d-a21c-e9cf660a6567', 'prs', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'آیا در محل فعالیت شما بانک پس‌اندازی (و در نتیجه بنیاد بانک پس‌انداز) وجود دارد؟', '2026-08-28 17:30:50.623518+00'),
	('afcb8181-4291-4cba-aa6a-ebf825a4a83c', 'prs', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'کمک‌های مالی فعالیت چندساله برای گروه‌های مستقل مسلکی رقص، تیاتر و تیاتر موزیکال.', '2026-08-28 17:30:50.623518+00'),
	('961b524c-6fb9-4c77-a32a-9a1958ec7f97', 'prs', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'کمک‌های مالی تحقیقاتی در عرصه‌های Forte: صحت، زندگی کاری و رفاه. محققان دارای دوکتورا در پوهنتون‌های سویدن درخواست می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('34026931-3d59-4a8a-894f-0dec67bde06b', 'prs', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'بودجه تحقیقاتی برای تحقیقات بنیادی آزاد در همه عرصه‌های علمی.', '2026-08-28 17:30:50.623518+00'),
	('2ed71c88-55b3-4eb2-b130-ea4491a8ab3f', 'prs', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'بودجه تحقیقاتی در محیط‌زیست، علوم زراعتی و شهرسازی.', '2026-08-28 17:30:50.623518+00'),
	('95bae80c-cedd-481c-ae3d-459bb6fd51ed', 'prs', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'آیا در فکر رفتن به خارج هستید (برای کار، تحصیل یا بازگشت به وطن)؟', '2026-08-28 17:30:50.623518+00'),
	('8724655f-6686-4242-99f8-d9a84acf94b7', 'prs', 'Genomförs insatserna av professionella kulturaktörer?', 'آیا فعالیت‌ها را کنشگران فرهنگی مسلکی اجرا می‌کنند؟', '2026-08-28 17:30:50.623518+00'),
	('8f7e7c03-fa99-4263-9425-4e7c047a3d22', 'prs', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'آیا پروژه در دهات یا در قصبه کوچکی اجرا می‌شود؟', '2026-08-28 17:30:50.623518+00'),
	('ad7da233-d73d-46f9-aa55-56c7407a1c9b', 'prs', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حمایت اساسی برای کسی که در طول زندگی عاید کاری کم یا هیچ نداشته است.', '2026-08-28 17:30:50.623518+00'),
	('559aca22-f59e-4a7e-a5b6-27f860fa466b', 'prs', 'Går något av dina barn i grundskolan?', 'آیا یکی از اطفال‌تان به مکتب ابتداییه می‌رود؟', '2026-08-28 17:30:50.623518+00'),
	('630feb5c-c6bb-4593-be31-fff21e225c2a', 'prs', 'Går något av dina barn på gymnasiet?', 'آیا یکی از اطفال‌تان در لیسه درس می‌خواند؟', '2026-08-28 17:30:50.623518+00'),
	('84f569d9-af37-4f5e-9732-afc654ea7d6e', 'prs', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'آیا استخدام مربوط به فردی با توان کاری کاهش‌یافته است؟', '2026-08-28 17:30:50.623518+00');
INSERT INTO public.kb_translations VALUES
	('5acdf2cc-fcec-46b9-be11-cc959ac05347', 'prs', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'آیا استخدام مربوط به کسی است که مدت زیادی بیکار بوده یا تازه‌وارد سویدن است؟', '2026-08-28 17:30:50.623518+00'),
	('e4483823-6899-448e-bb34-420a57b61acd', 'prs', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'آیا پروژه درباره حفظ میراث فرهنگی یا دسترس‌پذیر ساختن آن است؟', '2026-08-28 17:30:50.623518+00'),
	('6cd5c2b5-4d6d-4172-a8c0-14be5deee316', 'prs', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'آیا پروژه درباره انرژی، مؤثریت انرژی یا نوآوری مرتبط با انرژی است؟', '2026-08-28 17:30:50.623518+00'),
	('fafaccd9-c5c1-437e-a7cc-7f3302577af9', 'prs', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'آیا پروژه درباره صحت، زندگی کاری یا رفاه است؟', '2026-08-28 17:30:50.623518+00'),
	('b79b21dc-1286-4c51-9285-dc7b3982c743', 'prs', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'آیا پروژه درباره انکشاف مهارت‌ها یا اقدامات بازار کار است؟', '2026-08-28 17:30:50.623518+00'),
	('1e0aea45-d6cb-4a43-bbf6-d5373258d8af', 'prs', 'Handlar projektet om miljö- eller klimatåtgärder?', 'آیا پروژه درباره اقدامات محیط‌زیستی یا اقلیمی است؟', '2026-08-28 17:30:50.623518+00'),
	('ddeffe06-797f-493a-9a96-f8d428f8554c', 'prs', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'آیا راه طفل به مکتب دراز، به دلیل ترافیک خطرناک یا به شکل دیگری دشوار است؟', '2026-08-28 17:30:50.623518+00'),
	('4e1291dd-38b7-4967-8577-5f6188ca0270', 'prs', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'آیا دست‌کم ۱۶ ساعت در هفته و در مجموع دست‌کم ۸ سال کار کرده‌اید؟', '2026-08-28 17:30:50.623518+00'),
	('c14fab60-4e39-48f7-a337-319eee197841', 'prs', 'Har du barn som bor hos dig, helt eller växelvis?', 'آیا اطفالی دارید که نزد شما زندگی می‌کنند، تمام‌وقت یا به نوبت؟', '2026-08-28 17:30:50.623518+00'),
	('011ceca4-309a-4760-baf3-eb767165c500', 'prs', 'Har du barn som bor hos dig?', 'آیا اطفالی دارید که نزد شما زندگی می‌کنند؟', '2026-08-28 17:30:50.623518+00'),
	('83e18621-8adb-4815-b203-a6e52b3ef704', 'prs', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'آیا شما یا طفل‌تان معلولیتی دارید که انتظار می‌رود دست‌کم یک سال دوام کند؟', '2026-08-28 17:30:50.623518+00'),
	('81e8f4ae-4f5d-48a3-960b-9edb0f5dad9a', 'prs', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'آیا شما یا کسی در فامیل معلولیت دایمی دارد که بر مسکن اثر می‌گذارد؟', '2026-08-28 17:30:50.623518+00'),
	('a8660809-3a46-4f02-a566-6780b4efe739', 'prs', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'آیا شما یا یکی از نزدیکان معلولیت یا مریضی طولانی یا جدی دارید؟', '2026-08-28 17:30:50.623518+00'),
	('0affa6d8-40c7-411c-af3f-bac8e7800afa', 'prs', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'آیا مریضی یا آسیبی دارید که فعلاً توان کاری شما را کاهش می‌دهد؟', '2026-08-28 17:30:50.623518+00'),
	('ac774531-c015-4b51-9d4e-2959e31d1d73', 'prs', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'آیا تا حال در پرداخت مصارف سیر مکتب، سفر صنفی یا فعالیت تفریحی که انتظار می‌رود طفل‌تان در آن شرکت کند مشکل داشته‌اید؟', '2026-08-28 17:30:50.623518+00'),
	('8826335b-c3c6-4b5e-ba44-fe0b612ae3c9', 'prs', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'آیا گذران زندگی با تقاعد و عواید دیگرتان برای‌تان دشوار است؟', '2026-08-28 17:30:50.623518+00'),
	('de21a89c-b2a7-432e-b6cd-f60486378f71', 'prs', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'آیا در سال‌های اخیر جواز اقامت در سویدن گرفته‌اید، مثلاً به‌عنوان نیازمند حمایت یا عضو فامیل؟', '2026-08-28 17:30:50.623518+00'),
	('f7ea58de-7a66-4d3c-8004-b709f597b6d8', 'prs', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'آیا جواز اقامت در سویدن به‌عنوان پناهنده یا نیازمند حمایت دارید (یا از اقارب نزدیک چنین کسی هستید)؟', '2026-08-28 17:30:50.623518+00'),
	('eeed64e7-b280-461c-8dc3-43ab9097a3e0', 'prs', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'آیا به سن معیاری تقاعد رسیده‌اید (۶۷ سال در ۲۰۲۶)؟', '2026-08-28 17:30:50.623518+00'),
	('fcf8099f-38ec-405a-b319-69cb554e8235', 'prs', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'آیا سازمان شما OID (Organisation ID) ثبت‌شده در Organisation Registration System اتحادیه اروپا دارد؟', '2026-08-28 17:30:50.623518+00'),
	('4ecacfcf-f017-4408-8d74-209092392500', 'prs', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'آیا معلولیت مصارف اضافی به بار آورده است — مثلاً وسایل کمکی، سفر، غذای خاص یا استهلاک؟', '2026-08-28 17:30:50.623518+00'),
	('a67992da-ab10-4cd6-9d6e-627655a11975', 'prs', 'Har föreningen antagna stadgar och en vald styrelse?', 'آیا انجمن اساسنامه تصویب‌شده و هیئت اداری انتخاب‌شده دارد؟', '2026-08-28 17:30:50.623518+00'),
	('58e54bfd-28db-4d92-bdfe-35c44e753d49', 'prs', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'آیا انجمن ساختار دموکراتیک دارد (اساسنامه، مجمع سالانه، هیئت اداری)؟', '2026-08-28 17:30:50.623518+00'),
	('b1535ff4-c693-4d86-a27e-1ec5ed807bb4', 'prs', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'آیا انجمن فعالیت منظمی برای اطفال یا جوانان دارد؟', '2026-08-28 17:30:50.623518+00'),
	('fde3b5e0-ff52-4275-a6ea-87c2ccad65b0', 'prs', 'Har företaget mellan cirka 2 och 49 anställda?', 'آیا شرکت بین تقریباً ۲ تا ۴۹ کارمند دارد؟', '2026-08-28 17:30:50.623518+00'),
	('79fd902a-c074-49d1-8bab-0813cf7f1851', 'prs', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'آیا فامیل در تأمین مصارف خوراک، مسکن و ضروری‌ترین چیزها مشکل دارد؟', '2026-08-28 17:30:50.623518+00'),
	('e965e200-800a-4473-b062-b8fa5d12f38d', 'prs', 'Har lösningen internationell potential?', 'آیا راه‌حل ظرفیت بین‌المللی دارد؟', '2026-08-28 17:30:50.623518+00'),
	('350158e9-b56b-4e2b-b8b6-e64b3fcd5d82', 'prs', 'Har ni en partnergrupp i ett annat land?', 'آیا گروه شریکی در کشور دیگری دارید؟', '2026-08-28 17:30:50.623518+00'),
	('3094a574-a900-4c8d-9db6-f91648fb1907', 'prs', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'آیا سازمان شریکی در کشور اروپایی دیگری دارید؟', '2026-08-28 17:30:50.623518+00'),
	('c91f855d-0192-4db4-a083-153421a35da5', 'prs', 'Har ni partner i minst tre olika europeiska länder?', 'آیا در دست‌کم سه کشور مختلف اروپایی شریک دارید؟', '2026-08-28 17:30:50.623518+00'),
	('3a70be48-db24-4f46-96e1-3c86d304cd63', 'prs', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'آیا دفتر یا فعالیت اصلی شما در ولایتی است که در آن درخواست می‌دهید؟', '2026-08-28 17:30:50.623518+00'),
	('e04d012b-9d69-4b6d-a9fe-fa633a3e237c', 'prs', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'آیا یکی از اطفال‌تان معلولیتی دارد که باعث می‌شود به مراقبت یا نظارت بیشتری نسبت به اطفال هم‌سن ضرورت داشته باشد؟', '2026-08-28 17:30:50.623518+00'),
	('3e204a36-1abb-4381-a617-ab59a1cf768d', 'prs', 'Har organisationen en demokratisk uppbyggnad?', 'آیا سازمان ساختار دموکراتیک دارد؟', '2026-08-28 17:30:50.623518+00'),
	('b572501f-8515-46a9-9473-09e046c1e9ff', 'prs', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'آیا سازمان Quality Label (نشان کیفیت) دارد؟', '2026-08-28 17:30:50.623518+00'),
	('75279d9f-9b9d-4d47-b9a7-fa1e78271bbb', 'prs', 'Har organisationen ett 90-konto?', 'آیا سازمان 90-konto دارد؟', '2026-08-28 17:30:50.623518+00'),
	('70762374-f848-4a2b-a7ab-038abb152900', 'prs', 'Har organisationen ett OID (Organisation ID)?', 'آیا سازمان OID (Organisation ID) دارد؟', '2026-08-28 17:30:50.623518+00'),
	('4e3d33ba-4a09-4217-a18f-2ee1d03032fd', 'prs', 'Har organisationen ett OID?', 'آیا سازمان OID دارد؟', '2026-08-28 17:30:50.623518+00'),
	('9aaeebd8-f084-4c60-8df8-f70ea669a4e4', 'prs', 'Har organisationen medlemsföreningar i flera län?', 'آیا سازمان انجمن‌های عضو در چند ولایت دارد؟', '2026-08-28 17:30:50.623518+00'),
	('e14303f5-333f-4ef9-bee7-7e1f1c247806', 'prs', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'آیا سازمان مالی منظم و ساختار دموکراتیک دارد؟', '2026-08-28 17:30:50.623518+00'),
	('8eb652c5-acc3-4e27-a5d4-f5b10ba77330', 'prs', 'Har projektet en partner i ett annat land?', 'آیا پروژه شریکی در کشور دیگری دارد؟', '2026-08-28 17:30:50.623518+00'),
	('e6147393-342c-4fb1-bef3-e6191e23af50', 'prs', 'Har projektledaren doktorsexamen?', 'آیا مسئول پروژه سند دوکتورا دارد؟', '2026-08-28 17:30:50.623518+00'),
	('2e66ab24-a058-4438-99ba-b7d488b8ed98', 'prs', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'شاروالی محل بودوباش باید رفت‌وآمد روزانه میان خانه و لیسه را وقتی راه دست‌کم شش کیلومتر است تأمین کند (مثلاً کارت سرویس).', '2026-08-28 17:30:50.623518+00'),
	('c60bcc93-dce5-4020-85c2-7b86d899be02', 'prs', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'آیا در حال تهیه یا تجهیز نخستین خانه شخصی خود در سویدن هستید؟', '2026-08-28 17:30:50.623518+00'),
	('2754c345-fa13-4955-95d9-63b16bd24134', 'prs', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'آیا پروژه شامل سفر یا تبادله بین‌المللی است؟', '2026-08-28 17:30:50.623518+00'),
	('cad2a979-5b0f-422a-891e-99bd29c9d104', 'prs', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'حمایت سرمایه‌گذاری از شرکت‌ها در ساحات حمایتی برای تعمیرات، ماشین‌آلات و آموزش.', '2026-08-28 17:30:50.623518+00'),
	('58633fff-8740-4768-897e-47af7c240485', 'prs', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'حمایت سرمایه‌گذاری از اقداماتی که انتشار گازهای گلخانه‌ای را کاهش می‌دهند.', '2026-08-28 17:30:50.623518+00'),
	('25b11c6a-3291-44e9-b555-c02a13993271', 'prs', 'Kan åtgärdens utsläppsminskning beräknas?', 'آیا کاهش انتشار حاصل از اقدام قابل محاسبه است؟', '2026-08-28 17:30:50.623518+00'),
	('0bb4c515-b5de-4e8a-803a-fa8cf72c7251', 'prs', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'آیا سازمان می‌تواند مصارف را تا پرداخت حمایت به دوش بگیرد؟', '2026-08-28 17:30:50.623518+00'),
	('feac6f14-06d0-4895-afe0-7f35784bf200', 'prs', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'آیا تجربه‌ها در فعالیت شما در سویدن به کار گرفته می‌شوند؟', '2026-08-28 17:30:50.623518+00'),
	('5cae2acd-6728-4f95-8501-649c09cd5391', 'prs', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'آیا سرمایه‌گذاری تنها بعد از ارسال درخواست آغاز می‌شود؟', '2026-08-28 17:30:50.623518+00');
INSERT INTO public.kb_translations VALUES
	('543aa16f-20eb-4f1e-b69b-640528e906d5', 'prs', 'Kommer projektet människor i ert närområde till del?', 'آیا پروژه به مردم منطقه شما فایده می‌رساند؟', '2026-08-28 17:30:50.623518+00'),
	('cc447de7-8864-48f6-b314-15cf6083e9da', 'prs', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'واپسین شبکه ایمنی اقتصادی شاروالی وقتی عواید کفاف ضروری‌ترین چیزها را نمی‌دهند.', '2026-08-28 17:30:50.623518+00'),
	('19bef70b-eabd-42db-a366-c43d0a6ef8b5', 'prs', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'حمایت‌های خود شاروالی‌ها از انجمن‌های محلی: کمک مالی فعالیت به ازای هر جلسه، کمک مالی محل، کمک مالی آغاز و غیره.', '2026-08-28 17:30:50.623518+00'),
	('cc66b220-3666-4a5a-b4f7-2653dd7ff7cc', 'prs', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'سرویس رایگان مکتب برای شاگردان مکتب ابتداییه در صورت فاصله دراز، راه خطرناک یا معلولیت — حقی طبق قانون مکاتب.', '2026-08-28 17:30:50.623518+00'),
	('887ddad5-17b1-44ba-9223-cb9975f7fe2b', 'prs', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'کمک مالی قانونی عینک یا لنز برای اطفال و جوانان؛ مبالغ و طرزالعمل‌ها در هر ولایت متفاوت است — سطح ولایت خود را بررسی کنید.', '2026-08-28 17:30:50.623518+00'),
	('03bfd279-559b-470b-9846-40b0c713c0b0', 'prs', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'آیا پروژه در منطقه‌ای است که برق آبی یا بادی به آن مربوط می‌شود؟', '2026-08-28 17:30:50.623518+00'),
	('0c1fa49e-cf1d-468c-b42b-26c9347b2bd7', 'prs', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'آیا پروژه در عرصه محیط‌زیست، علوم زراعتی یا شهرسازی است؟', '2026-08-28 17:30:50.623518+00'),
	('543e513a-c324-4b49-9288-2e1bd67fdc92', 'prs', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'آیا محل فعالیت در ساحه حمایتی A یا B است (بخش‌های بزرگ نورلند و سویالند داخلی)؟', '2026-08-28 17:30:50.623518+00'),
	('8291b7c6-5591-45d2-9ef3-bcecf7b6f180', 'prs', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'قرضه‌ای برای خرید ضروری‌ترین چیزها برای نخستین خانه در سویدن — فرنیچر، لوازم خانه و دیگر تجهیزات اساسی.', '2026-08-28 17:30:50.623518+00'),
	('e16a52e1-8fe0-4780-9bbf-94baff548374', 'prs', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'آیا پروژه انتشار پروسه‌ای صنعت را کاهش می‌دهد یا انتشار منفی ایجاد می‌کند؟', '2026-08-28 17:30:50.623518+00'),
	('b8d1e448-70c3-44b8-adb7-d161967d7eba', 'prs', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'کمک مالی ماهانه برای اطفال مقیم سویدن، از تولد تا ۱۶ سالگی.', '2026-08-28 17:30:50.623518+00'),
	('d93836fc-7b91-4610-bc05-9c743379ee2e', 'prs', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket به سازمان‌ها، شرکت‌ها، انجمن‌ها، سکتور عامه و اشخاص در عرصه محیط‌زیست کمک مالی می‌دهد.', '2026-08-28 17:30:50.623518+00'),
	('d3d15820-c2ea-48a1-a93d-4b17b2745505', 'prs', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'آیا قصد دارید داوطلبانه برای همیشه به کشور اصلی خود برگردید؟', '2026-08-28 17:30:50.623518+00'),
	('699f49c9-fc51-4fa4-9d34-ce501fad4941', 'prs', 'Planerar du att starta eget företag?', 'آیا قصد دارید تشبث شخصی خود را آغاز کنید؟', '2026-08-28 17:30:50.623518+00'),
	('88343fb7-e095-4e9b-b265-ab8748572756', 'prs', 'Planerar du att studera utomlands?', 'آیا قصد تحصیل در خارج را دارید؟', '2026-08-28 17:30:50.623518+00'),
	('81408cce-5f65-4c03-8776-d084e8a708f0', 'prs', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'آیا قصد درسی دارید که موقعیت شما را در بازار کار تقویت کند؟', '2026-08-28 17:30:50.623518+00'),
	('c14436f3-f2aa-42b7-a06e-6f9ff2265fb5', 'prs', 'Planerar ni att anställa?', 'آیا قصد استخدام دارید؟', '2026-08-28 17:30:50.623518+00'),
	('47ba0704-32e7-4894-8559-d846d55d720f', 'prs', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'آیا قصد دارید برای برنامه‌ای از اتحادیه اروپا (مثلاً Horisont Europa) درخواست بدهید؟', '2026-08-28 17:30:50.623518+00'),
	('88cdc2ba-c8a5-4029-99ca-123ada56cecd', 'prs', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'حمایت از تولید و انکشاف فلم کوتاه و مستند.', '2026-08-28 17:30:50.623518+00'),
	('57306747-b0f8-4aa1-8ac1-5d5b1b5f57ca', 'prs', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'کمک‌های مالی پروژه‌ای برای صحنه موسیقی آزاد: کنسرت، تولید و انکشاف.', '2026-08-28 17:30:50.623518+00'),
	('4634f187-de16-4d0e-9e13-2a60bb0cb8f8', 'prs', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'کمک‌های مالی پروژه‌ای برای سازمان‌های غیرانتفاعی که با اطفال و جوانان و برای آنان کار می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('2f8cf332-978a-48b7-b67c-1c650bc38b1d', 'prs', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'آیا پروژه بیان‌ها، روش‌ها یا همکاری‌های هنری تازه‌ای می‌آزماید؟', '2026-08-28 17:30:50.623518+00'),
	('93964f94-ef35-44d9-afd8-786a18c51b5c', 'prs', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'آیا تبادله ۵ تا ۲۱ روز دوام می‌کند (بدون روزهای سفر)؟', '2026-08-28 17:30:50.623518+00'),
	('9f3293ad-12db-449f-91c9-6ef656f2b151', 'prs', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'حمایت‌های خود ولایات از پروژه‌ها و فعالیت‌های فرهنگی، در پهلوی کمک‌های ملی Kulturrådet.', '2026-08-28 17:30:50.623518+00'),
	('a063e3af-50b9-4545-a756-e7a6d9524046', 'prs', 'Riktar sig projektet till barn eller unga?', 'آیا پروژه اطفال یا جوانان را هدف قرار می‌دهد؟', '2026-08-28 17:30:50.623518+00'),
	('e8626d00-7e4c-48f2-8297-c20ec11de054', 'prs', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'آیا پروژه اطفال، جوانان، کهنسالان یا افراد دارای معلولیت را هدف قرار می‌دهد؟', '2026-08-28 17:30:50.623518+00'),
	('ede2e183-dfcc-461a-85c1-4b8d9bc49f34', 'prs', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'آیا فعالیت اطفال و جوانان (۷–۲۵ ساله) را هدف قرار می‌دهد؟', '2026-08-28 17:30:50.623518+00'),
	('b1d2282b-f3cf-4860-a5a1-c691bd7460b1', 'prs', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'آیا پس‌انداز یا دارایی‌ای ندارید که بتواند مصارف را بپوشاند؟', '2026-08-28 17:30:50.623518+00'),
	('92b6fa54-6af0-47da-ba94-043fab422ce9', 'prs', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'آیا با شرکایی در دست‌کم دو کشور دیگر شمال اروپا همکاری می‌کنید؟', '2026-08-28 17:30:50.623518+00'),
	('936f40e3-18b1-48d2-8ba1-717bd23c9b61', 'prs', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'آیا برای یک اقدام انکشافی تخصص بیرونی جلب می‌کنید؟', '2026-08-28 17:30:50.623518+00'),
	('c262b608-5682-4295-b835-6ecea00b897e', 'prs', 'Sker mobiliteten till ett annat europeiskt land?', 'آیا تحرک به کشور اروپایی دیگری است؟', '2026-08-28 17:30:50.623518+00'),
	('6b139088-1a03-453f-8cac-a43e64fae46a', 'prs', 'Startar du eller tar du över företaget för första gången?', 'آیا برای نخستین بار تشبث را آغاز می‌کنید یا تسلیم می‌شوید؟', '2026-08-28 17:30:50.623518+00'),
	('e254be1a-bf41-4641-9bef-7b4634fd4b0b', 'prs', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'حمایت آغاز برای کسی که ۴۰ ساله یا جوان‌تر است و تشبث زراعتی را آغاز می‌کند یا تسلیم می‌شود.', '2026-08-28 17:30:50.623518+00'),
	('b7a21472-bcd3-46ba-814f-72c0593392a6', 'prs', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'بورسیه‌ای که به هنرمندان مسلکی امکان می‌دهد بر کار هنری تمرکز کنند.', '2026-08-28 17:30:50.623518+00'),
	('3bdec07b-e6d4-4dec-a06f-dd7986001b9c', 'prs', 'Studerar du, eller planerar du att börja studera?', 'آیا درس می‌خوانید یا قصد شروع درس دارید؟', '2026-08-28 17:30:50.623518+00'),
	('8ef696b8-45c2-42d2-acbe-e23246ec7206', 'prs', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'حمایت درسی برای بزرگسالان شاغل که می‌خواهند برای تقویت موقعیت خود در بازار کار آموزش ببینند.', '2026-08-28 17:30:50.623518+00'),
	('168c571f-0ece-4237-a3aa-c2466de1957a', 'prs', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'حمایت از سرمایه‌گذاری‌هایی که رقابت‌پذیری را افزایش یا اثرات محیط‌زیستی را در تشبثات زراعتی کاهش می‌دهند.', '2026-08-28 17:30:50.623518+00'),
	('d786167b-9335-4081-88ec-70ba17928f70', 'prs', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'حمایتی وقتی طفلی نزد شما زندگی می‌کند و والد دیگر نفقه نمی‌پردازد.', '2026-08-28 17:30:50.623518+00'),
	('90b541c8-7103-453a-91ef-784afae3e85d', 'prs', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'حمایت از پروژه‌های سازمان‌های غیرانتفاعی برای مردم، محیط‌زیست و جهانی بهتر.', '2026-08-28 17:30:50.623518+00'),
	('2a0c84bb-2264-49d6-9e7e-bf87d9c5abb0', 'prs', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'حمایت از گذار صنعت به سوی انتشار صفری گازهای گلخانه‌ای.', '2026-08-28 17:30:50.623518+00'),
	('5f072dfc-8595-47cc-9205-9979d53c5cf9', 'prs', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'حمایت از پروژه‌های هنری و فرهنگی با بُعد نوردیک و همکاری فرامرزی.', '2026-08-28 17:30:50.623518+00'),
	('35d78671-0c68-45b3-bd06-6f03dd77f04a', 'prs', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'حمایت از پروژه‌های فرهنگی نوآورانه که بیان‌ها، روش‌ها یا همکاری‌های هنری تازه می‌آزمایند.', '2026-08-28 17:30:50.623518+00'),
	('76df98d7-828b-44b7-a4c0-6dbb798adb83', 'prs', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'حمایت از پروژه‌های نوآورانه برای اطفال، جوانان، کهنسالان و افراد دارای معلولیت.', '2026-08-28 17:30:50.623518+00'),
	('a15bfda7-eda3-40d2-8fa1-d9a4a1e8d1b4', 'prs', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'حمایت از پروژه‌های همکاری در صحنه موسیقی آزاد.', '2026-08-28 17:30:50.623518+00'),
	('b74136cc-a047-464d-8664-170aaad85d8f', 'prs', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'حمایت از پروژه‌های همکاری در فرهنگ و رسانه که دموکراسی و آزادی بیان را در سطح بین‌المللی تقویت می‌کنند.', '2026-08-28 17:30:50.623518+00'),
	('8f699c0e-a3bf-4ec2-9db6-f1f1fd7009ea', 'prs', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'آیا هدف پروژه تقویت دموکراسی، برابری یا آزادی بیان است؟', '2026-08-28 17:30:50.623518+00'),
	('e79913ea-fe1d-4656-aa44-efdc98dd795b', 'prs', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'آیا در کشور دیگری از اتحادیه اروپا یا ساحه اقتصادی اروپا دنبال وظیفه می‌گردید یا پیشنهاد وظیفه گرفته‌اید؟', '2026-08-28 17:30:50.623518+00'),
	('deb08e7f-bfbe-4de4-ada3-981e7398e8d9', 'prs', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقفی برای آنچه در دوره دوازده‌ماهه بابت فیس مریض می‌پردازید — بعد از آن frikort (کارت رایگان).', '2026-08-28 17:30:50.623518+00'),
	('d22c4e37-74d8-4691-9d56-a6fcef8196e1', 'prs', 'Tar du ut hel allmän pension?', 'آیا تقاعد عمومی کامل خود را می‌گیرید؟', '2026-08-28 17:30:50.623518+00'),
	('a1a041a4-75d6-4260-b424-f4ed2e8b5a14', 'prs', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'اضافه‌ای که بخشی از مصارف مسکن را برای کسی که تقاعد و عاید کم دارد می‌پوشاند.', '2026-08-28 17:30:50.623518+00');
INSERT INTO public.kb_translations VALUES
	('7a0e3ca3-983c-472e-85eb-7682505b600b', 'prs', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'کمک مالی سازمانی سالانه برای سازمان‌های ملی اطفال و جوانان.', '2026-08-28 17:30:50.623518+00'),
	('504debb2-60fc-4acd-b1fd-33eb1b6b5ec3', 'prs', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'اعتبار سالانه‌ای که مستقیماً نزد داکتر دندان یا صحی‌کار دندان کم می‌شود.', '2026-08-28 17:30:50.623518+00'),
	('4befbdf2-23dc-4015-aa18-6db0fa6fd42a', 'prs', 'Är bolaget yngre än cirka 5 år?', 'آیا عمر شرکت کمتر از تقریباً ۵ سال است؟', '2026-08-28 17:30:50.623518+00'),
	('6678ae0f-e819-40dd-91e3-5af7f12d4d75', 'prs', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'آیا اشتراک‌کنندگان تبادله بین ۱۳ و ۳۰ سال دارند؟', '2026-08-28 17:30:50.623518+00'),
	('07949096-3cbf-418d-b452-d0b7454f3bb0', 'prs', 'Är det här ert första EU-projekt?', 'آیا این نخستین پروژه اتحادیه اروپای شماست؟', '2026-08-28 17:30:50.623518+00'),
	('f6564e06-486e-4952-98b0-3dbf9e27ef39', 'prs', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'آیا برای شما (یا طفل‌تان) گشت‌وگذار مستقل یا سفر با سرویس و قطار بسیار دشوار است؟', '2026-08-28 17:30:50.623518+00'),
	('d30e295d-b9ca-41ea-9f16-15b66928d63d', 'prs', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا عاید شما کمتر از تقریباً ۲۵٬۰۰۰ کرون در ماه پیش از مالیه است؟', '2026-08-28 17:30:50.623518+00'),
	('7e1f31dc-790f-4d62-b898-68f27766d1ef', 'prs', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'آیا آخرین تحصیل تمام‌شده شما مکتب ابتداییه است، یا لیسه‌ای که تمامش نکردید؟', '2026-08-28 17:30:50.623518+00'),
	('19d0fc23-833f-4720-a418-c254b3794769', 'prs', 'Är du 40 år eller yngre?', 'آیا ۴۰ ساله یا جوان‌تر هستید؟', '2026-08-28 17:30:50.623518+00'),
	('955edfb1-0389-4887-b998-dc5d4d391de2', 'prs', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'آیا به‌عنوان جوینده کار نزد Arbetsförmedlingen ثبت‌نام شده‌اید؟', '2026-08-28 17:30:50.623518+00'),
	('27e09547-231b-4946-ae86-974a17cdbb77', 'prs', 'Är du mellan 18 och 28 år?', 'آیا بین ۱۸ و ۲۸ سال دارید؟', '2026-08-28 17:30:50.623518+00'),
	('78178733-84c5-4b00-a246-43f569274b57', 'prs', 'Är du mellan 19 och 29 år?', 'آیا بین ۱۹ و ۲۹ سال دارید؟', '2026-08-28 17:30:50.623518+00'),
	('82eb40b6-8de9-44db-aa4a-513e9c7deb14', 'prs', 'Är du mellan 25 och 60 år?', 'آیا بین ۲۵ و ۶۰ سال دارید؟', '2026-08-28 17:30:50.623518+00'),
	('3ea67446-d893-4d70-b3f1-ef5137832a8c', 'prs', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'آیا به‌طور مسلکی در عرصه فرهنگ فعالیت می‌کنید (مثلاً رقص، موسیقی، هنرهای نمایشی)؟', '2026-08-28 17:30:50.623518+00'),
	('2edf0ca4-dcd5-40d7-9ee9-2cc6540ee3fb', 'prs', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'آیا هنرمند مسلکی هستید (نه شوقی و نه در آموزش اساسی)؟', '2026-08-28 17:30:50.623518+00'),
	('6dd5316b-8f52-4d92-84bd-d2a2b62897ae', 'prs', 'Är du yrkesverksam konstnär?', 'آیا هنرمند مسلکی هستید؟', '2026-08-28 17:30:50.623518+00'),
	('0d2e7b6c-8183-4c56-b7c9-c35e32cba659', 'prs', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'آیا راه‌حل شما در مقایسه با آنچه موجود است اساساً نوآورانه است؟', '2026-08-28 17:30:50.627175+00'),
	('b059dc63-29cc-4cd0-963e-d158d7b41364', 'prs', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'آیا کلپ به فدراسیون ورزشی تخصصی درون Riksidrottsförbundet وابسته است؟', '2026-08-28 17:30:50.627175+00'),
	('3ec358c5-2b90-442d-8f61-c7016e1d1e9f', 'prs', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'آیا عاید فامیل نسبت به مصارف مسکن پایین است؟', '2026-08-28 17:30:50.627175+00'),
	('3cba90f4-b579-4d3b-8f82-abfd93818f01', 'prs', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا عاید مجموعی فامیل کمتر از تقریباً ۲۵٬۰۰۰ کرون در ماه پیش از مالیه است؟', '2026-08-28 17:30:50.627175+00'),
	('fd92ca10-8c48-454a-af96-d32b38b49cc7', 'prs', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'آیا اقدام یک پروژه مشخص است (نه فعالیت عادی)؟', '2026-08-28 17:30:50.627175+00'),
	('da8eaf6f-2e05-4bb7-856e-b5dd0816273d', 'prs', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'آیا محل برای همه باز است — نه تنها اعضای خودتان؟', '2026-08-28 17:30:50.627175+00'),
	('351390b5-a51e-451b-82f6-4845fcb1a3fe', 'prs', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'آیا دست‌کم ۶۰ فیصد اعضا بین ۶ و ۲۵ سال دارند؟', '2026-08-28 17:30:50.627175+00'),
	('2c62f659-2191-44a8-80ff-87dc4e8f3d2e', 'prs', 'Är minst 60 % av medlemmarna under 26 år?', 'آیا دست‌کم ۶۰ فیصد اعضا زیر ۲۶ سال هستند؟', '2026-08-28 17:30:50.627175+00'),
	('23191bdb-7c1d-4480-b7ec-21b2357af397', 'prs', 'Är målgruppen delaktig i planering och genomförande?', 'آیا گروه هدف در پلان‌گذاری و اجرا سهم دارد؟', '2026-08-28 17:30:50.627175+00'),
	('b5365518-9bdb-442d-9f3b-43c16576f9a7', 'prs', 'Är ni ett förlag med professionell utgivning?', 'آیا ناشری با نشرات مسلکی هستید؟', '2026-08-28 17:30:50.627175+00'),
	('9a7ec1df-df3c-44ff-ba93-3d1a6785042c', 'prs', 'Är ni huvudman för förskoleklass eller grundskola?', 'آیا مسئول یک صنف آمادگی یا مکتب ابتداییه هستید؟', '2026-08-28 17:30:50.627175+00'),
	('f66f4e09-4892-40bd-8fda-fd778aa6817c', 'prs', 'Är organisationen registrerad i EU:s deltagarregister?', 'آیا سازمان در فهرست اشتراک‌کنندگان اتحادیه اروپا ثبت شده است؟', '2026-08-28 17:30:50.627175+00'),
	('fa189836-b389-48ab-9e42-72870bba9336', 'prs', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'آیا پروژه یک پروژه سینمایی است (فلم کوتاه یا مستند)؟', '2026-08-28 17:30:50.627175+00'),
	('617936f3-8d91-4cea-b488-774a39312108', 'prs', 'Är projektet ett konst- eller kulturprojekt?', 'آیا پروژه یک پروژه هنری یا فرهنگی است؟', '2026-08-28 17:30:50.627175+00'),
	('9c465ca3-5950-4924-af6b-99328d031a43', 'prs', 'Är projektet ett kulturprojekt?', 'آیا پروژه یک پروژه فرهنگی است؟', '2026-08-28 17:30:50.627175+00'),
	('fbc70746-aa9f-45ed-8f9b-e6f2d5370ff6', 'prs', 'Är projektet ett musikprojekt?', 'آیا پروژه یک پروژه موسیقی است؟', '2026-08-28 17:30:50.627175+00'),
	('1ba51e87-d57d-47ce-9ca1-ad82571c375a', 'prs', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'آیا پروژه نوآورانه است — کاری که فعلاً در فعالیت عادی انجام نمی‌دهید؟', '2026-08-28 17:30:50.627175+00'),
	('603fccef-2046-4c1d-b9e7-6809ddaf942e', 'prs', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'آیا پروژه به کل منطقه فایده می‌رساند (نه به اشخاص)؟', '2026-08-28 17:30:50.627175+00'),
	('a97e0e94-c35e-46ed-bab7-2b42007d1533', 'prs', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'آیا راه میان خانه و لیسه دست‌کم شش کیلومتر است؟', '2026-08-28 17:30:50.627175+00'),
	('01e7e128-b1e0-408f-9aa1-fce13ac4dac7', 'prs', 'Är verksamheten professionell (inte amatörverksamhet)?', 'آیا فعالیت مسلکی است (نه شوقی)؟', '2026-08-28 17:30:50.627175+00'),
	('f4412f52-0cdb-4ac4-98b6-3d604264b479', 'prs', 'Är verksamheten professionell?', 'آیا فعالیت مسلکی است؟', '2026-08-28 17:30:50.627175+00'),
	('8d59cfe1-1e6d-4019-9f25-f20fbf89f84d', 'prs', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'آیا فعالیت از هنرهای نمایشی است (رقص، تیاتر، تیاتر موزیکال)؟', '2026-08-28 17:30:50.627175+00'),
	('3d200d3c-7de0-4186-be6f-da6aa683e2e6', 'prs', 'Är volontärerna mellan 18 och 30 år?', 'آیا رضاکاران بین ۱۸ و ۳۰ سال دارند؟', '2026-08-28 17:30:50.627175+00'),
	('11bf9fad-88da-4335-97bc-02305c46173e', 'ru', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Поддержка деятельности спортивных клубов, проводящих занятия под руководством тренеров для детей и молодёжи 7–25 лет.', '2026-08-28 17:30:50.632707+00'),
	('c017e69a-1be2-4f5d-b288-12ab9c634c41', 'ru', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Автоматическая надбавка к детскому пособию (barnbidrag) начиная со второго ребёнка.', '2026-08-28 17:30:50.632707+00'),
	('39e33575-7fe9-4f19-b51b-5c74a8b43376', 'ru', 'Avser ansökan en fysisk investering?', 'Касается ли заявка физической инвестиции?', '2026-08-28 17:30:50.632707+00'),
	('e2c5501a-6492-44e9-90aa-700cb4a868f8', 'ru', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Касается ли заявка международной поездки или обмена?', '2026-08-28 17:30:50.632707+00'),
	('763a420b-8559-4462-a5b3-7c02afe29aa6', 'ru', 'Avser ansökan en investering i byggnader eller maskiner?', 'Касается ли заявка инвестиции в здания или оборудование?', '2026-08-28 17:30:50.632707+00'),
	('509e91e2-6bae-4d8d-b3b6-f69c9ea12892', 'ru', 'Avser ansökan en redan utgiven titel?', 'Касается ли заявка уже изданного произведения?', '2026-08-28 17:30:50.632707+00'),
	('16036dc6-22eb-4abc-8430-a41ddd752ea3', 'ru', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Касается ли заявка сельскохозяйственного, садоводческого или оленеводческого предприятия?', '2026-08-28 17:30:50.632707+00'),
	('775b147d-def6-43a0-96a2-e86c424a25d6', 'ru', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Касается ли заявка закупки литературы для публичных или школьных библиотек?', '2026-08-28 17:30:50.632707+00'),
	('da622160-67c9-4a56-b774-fd025443da51', 'ru', 'Avser investeringen jordbruksverksamhet?', 'Касается ли инвестиция сельскохозяйственной деятельности?', '2026-08-28 17:30:50.632707+00'),
	('2044089f-4c14-42fa-940a-98ff2ba0cd6f', 'ru', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Предполагает ли проект строительство, покупку или ремонт помещения?', '2026-08-28 17:30:50.632707+00'),
	('0012593c-baa5-4834-9b16-45eca74c2724', 'ru', 'Avser projektet naturvård eller friluftsliv?', 'Касается ли проект охраны природы или активного отдыха на природе?', '2026-08-28 17:30:50.632707+00');
INSERT INTO public.kb_translations VALUES
	('672d1df9-0904-4eb0-b97a-93b1f2b5ed4f', 'ru', 'Avser projektet skola eller vuxenutbildning?', 'Касается ли проект школы или образования взрослых?', '2026-08-28 17:30:50.632707+00'),
	('ae509cd2-ee0d-43dc-9420-aff109bb8afc', 'ru', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Отказываетесь ли вы от работы, чтобы ухаживать за близким человеком или быть рядом с ним, когда болезнь настолько тяжела, что угрожает его жизни?', '2026-08-28 17:30:50.632707+00'),
	('48e905e4-de9e-45a6-90fa-300285d2fb58', 'ru', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Ведёт ли объединение регулярную деятельность в коммуне?', '2026-08-28 17:30:50.632707+00'),
	('6ca53d4e-a3b0-4120-b872-06cb9a9212dd', 'ru', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Считаете ли вы, что ваша трудоспособность снижена как минимум на год из-за болезни или инвалидности?', '2026-08-28 17:30:50.632707+00'),
	('7fbb1ded-5cd8-4988-b460-5d34d98491ca', 'ru', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Адресная поддержка для тех, у кого низкая пенсия или её нет, и кому нужна помощь для достижения разумного уровня жизни.', '2026-08-28 17:30:50.632707+00'),
	('d59b709d-751b-4ab4-aadf-b563e83dc552', 'ru', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Нужно ли ребёнку жить в месте учёбы (проживание) из-за слишком долгой дороги?', '2026-08-28 17:30:50.632707+00'),
	('23c6bda8-1c6e-41b2-8fee-b7d9946270b0', 'ru', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Нужно ли адаптировать жильё (например, пандус, автоматическая дверь, ванная)?', '2026-08-28 17:30:50.632707+00'),
	('e7616040-b12a-4f49-b28c-22faa8cf4b61', 'ru', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Нужны ли кому-то из ваших детей 8–19 лет очки или линзы?', '2026-08-28 17:30:50.632707+00'),
	('d6dc736a-1c89-454a-b7d8-fc00284c0ce5', 'ru', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Другой родитель не платит ничего или платит меньше полного содержания?', '2026-08-28 17:30:50.632707+00'),
	('ff26c886-28ee-4f8a-aebc-f7422471f89e', 'ru', 'Betalar du hyra eller andra boendekostnader?', 'Платите ли вы аренду или другие расходы на жильё?', '2026-08-28 17:30:50.632707+00'),
	('872f863f-a5b8-496a-ab91-79df5b6e2972', 'ru', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Пособие на адаптацию жилья при инвалидности — например, пандусы, автоматические двери или переоборудование ванной.', '2026-08-28 17:30:50.632707+00'),
	('cf6e0a7c-5597-479e-87eb-a534bc1bd6b4', 'ru', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Пособия на строительство, покупку или ремонт общественных помещений для собраний.', '2026-08-28 17:30:50.632707+00'),
	('2ed4ae92-4caa-4f03-8669-9a7c151f5fdc', 'ru', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Пособие на покупку или адаптацию автомобиля, когда стойкая инвалидность сильно затрудняет передвижение или поездки на общественном транспорте.', '2026-08-28 17:30:50.632707+00'),
	('14174d26-52bb-4176-99d8-485fb160a42d', 'ru', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Пособия на международные поездки и обмены для профессионалов в сфере культуры.', '2026-08-28 17:30:50.632707+00'),
	('a885f5ae-fa41-4c8b-b509-2bc9305cbb5e', 'ru', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Пособия на международные обмены, поездки и рабочие пребывания профессиональных художников.', '2026-08-28 17:30:50.632707+00'),
	('9c87066c-f431-44ac-baf9-9fb050083a0c', 'ru', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Пособие и добровольный заём для учёбы на гимназическом или послегимназическом уровне.', '2026-08-28 17:30:50.632707+00'),
	('efc7be10-e5dc-48b8-abd7-3e274c5b6cfc', 'ru', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Пособия и займы для учёбы за границей, с дополнительными займами, например, на плату за обучение и поездки.', '2026-08-28 17:30:50.632707+00'),
	('127e40cb-bf07-4b36-ac60-b6263aec178e', 'ru', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Пособие, помогающее шведским организациям готовить заявки на программы ЕС, такие как Horisont Europa.', '2026-08-28 17:30:50.632707+00'),
	('53952a8a-451d-4bc7-a495-33e658d2f609', 'ru', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Пособие работодателям, нанимающим людей со сниженной трудоспособностью.', '2026-08-28 17:30:50.632707+00'),
	('946bf130-4588-47c6-a005-ab4930769f53', 'ru', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Пособие на проживание и поездки домой, когда гимназист вынужден жить в месте учёбы из-за долгой дороги.', '2026-08-28 17:30:50.632707+00'),
	('0a1b54f6-c709-4a11-b356-f8ee256275c0', 'ru', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Пособия на работу некоммерческих организаций по сохранению, использованию и развитию культурного наследия.', '2026-08-28 17:30:50.632707+00'),
	('987b973a-0dbf-4419-83a1-3048ef7f9861', 'ru', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Пособия на муниципальные и местные природоохранные проекты, включая водно-болотные угодья и активный отдых.', '2026-08-28 17:30:50.632707+00'),
	('5c82e2f3-e7e7-405b-8cf8-3ddf544e6f5a', 'ru', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Пособия коммунам на закупку литературы для публичных и школьных библиотек.', '2026-08-28 17:30:50.632707+00'),
	('7b8afb73-8413-4d5c-9749-6ef43bb6a9ab', 'ru', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Пособия школьным организациям для знакомства учеников основной школы с профессиональной культурой.', '2026-08-28 17:30:50.632707+00'),
	('14995731-61c9-439e-a4d3-bd54f40d68ba', 'ru', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Пособие на то, что нужно вашему ребёнку, но на что не хватает семейного бюджета: досуг, одежда, школьные экскурсии, очки, каникулярные занятия и другое.', '2026-08-28 17:30:50.632707+00'),
	('105a53ee-1657-4474-9efc-6f978792fff0', 'ru', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Пособия из фондов Världens Barn, Musikhjälpen и Victoriafonden — их запрашивают шведские некоммерческие организации с 90-konto.', '2026-08-28 17:30:50.632707+00'),
	('caefbf03-c308-4d32-8bd6-74db0f684c21', 'ru', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Пособия из средств гидро- и ветроэнергетики на проекты, развивающие местность.', '2026-08-28 17:30:50.632707+00'),
	('ea77a089-9887-4f78-992a-aaac9f7a2610', 'ru', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Пособие без заёмной части для безработных 25–60 лет с коротким образованием, которым нужно учиться на уровне основной школы или гимназии.', '2026-08-28 17:30:50.632707+00'),
	('dba64ad0-6437-46ba-b57d-60893d6e55bf', 'ru', 'Bidrar projektet till energiomställningen?', 'Вносит ли проект вклад в энергетический переход?', '2026-08-28 17:30:50.632707+00'),
	('5d55f818-7ae4-4ec0-8b55-f75caafff74e', 'ru', 'Bor du och barnets andra förälder på skilda håll?', 'Живёте ли вы и другой родитель ребёнка раздельно?', '2026-08-28 17:30:50.632707+00'),
	('1d37d9c5-5888-482b-967e-4e0d10ba6053', 'ru', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Чеки для малых предприятий на привлечение внешней экспертизы для интернационализации или цифровизации.', '2026-08-28 17:30:50.632707+00'),
	('fcda2514-6688-4ec8-a4f4-7eec1bae2de8', 'ru', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Участвуете ли вы в программе Arbetsförmedlingen (например, jobb- och utvecklingsgarantin)?', '2026-08-28 17:30:50.632707+00'),
	('4a442424-963f-409c-9ea4-42c71541f5b5', 'ru', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Последующая поддержка издательствам за выпуск качественной литературы.', '2026-08-28 17:30:50.632707+00'),
	('a4720645-d542-4776-8438-add8406cff00', 'ru', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Экономическая поддержка для тех, у кого вид на жительство по защите и кто добровольно хочет навсегда вернуться в страну происхождения.', '2026-08-28 17:30:50.632707+00'),
	('2c3a8fb7-d736-408f-bdde-bc2164c74f99', 'ru', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Экономическая поддержка работодателям, нанимающим человека, долго не работавшего.', '2026-08-28 17:30:50.632707+00'),
	('a13e9885-0870-4be3-b1d8-ca9bd8919af4', 'ru', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Экономическая поддержка на этапе запуска для ищущих работу, открывающих собственное дело.', '2026-08-28 17:30:50.632707+00'),
	('64d6c499-7a01-495a-99c7-a9b751f61a38', 'ru', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten постоянно открывает конкурсы в области энергетических исследований, инноваций и энергоэффективности.', '2026-08-28 17:30:50.632707+00'),
	('f5005d2a-45ec-4bb1-bbde-c88c3c0c974f', 'ru', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Выплата за отсутствие на работе или учёбе для ухода за ребёнком.', '2026-08-28 17:30:50.632707+00'),
	('52e417fc-abff-4d45-844d-751897e2ea73', 'ru', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Выплата для тех, кто недавно в Швеции и участвует в программе адаптации Arbetsförmedlingen; выплачивает Försäkringskassan.', '2026-08-28 17:30:50.632707+00'),
	('d80fd9f2-e4ed-4eb8-80c3-ab6b42d1a33c', 'ru', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Выплата, покрывающая часть расходов на жильё для молодых людей без детей с низкими доходами.', '2026-08-28 17:30:50.632707+00'),
	('d822eaf2-dbfe-499e-874b-56ffd7aed646', 'ru', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Выплата за дополнительные расходы, связанные со стойкой инвалидностью — для взрослых или родителей детей с инвалидностью.', '2026-08-28 17:30:50.632707+00'),
	('3cde9e4a-b64b-464e-9c73-e1b1d2c5146a', 'ru', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Выплата для молодых людей (19–29 лет), которые не могут работать полный день минимум год из-за болезни или инвалидности.', '2026-08-28 17:30:50.632707+00'),
	('aef5ecc6-dede-4ebe-9d34-bfebfa6eefac', 'ru', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Выплата при стойко сниженной трудоспособности — то, что раньше называлось förtidspension (досрочная пенсия).', '2026-08-28 17:30:50.632707+00'),
	('04f3d39f-2158-4013-8434-b81ab830179b', 'ru', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Выплата, когда вы отказываетесь от работы, чтобы быть рядом с тяжелобольным близким.', '2026-08-28 17:30:50.632707+00'),
	('08fd1d0a-eae3-4817-89e2-4ead2aca6850', 'ru', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Выплата за участие в программе рынка труда Arbetsförmedlingen.', '2026-08-28 17:30:50.632707+00'),
	('e7891f39-0404-46e4-adba-f2538d9937ed', 'ru', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Выплата, когда вы не можете работать как обычно из-за болезни.', '2026-08-28 17:30:50.632707+00'),
	('f7a82ac3-e0fb-4ed1-978d-45d3fd7bfe4e', 'ru', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Выплата, когда вы остаётесь дома с работы для ухода за больным ребёнком.', '2026-08-28 17:30:50.632707+00'),
	('d48b4e2e-47b2-48cf-b676-f12173ce0c13', 'ru', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Выплата, покрывающая часть расходов на жильё для семей с детьми и невысокими доходами.', '2026-08-28 17:30:50.632707+00'),
	('f48db8c0-6c34-40d5-945e-38457233e768', 'ru', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Выплата родителям, чьи дети из-за инвалидности нуждаются в большем уходе и присмотре, чем сверстники.', '2026-08-28 17:30:50.632707+00'),
	('a824640c-dab9-44c4-8502-62b1260dfdc8', 'ru', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Выплата при безработице — на основе дохода для членов кассы, базовая сумма для остальных.', '2026-08-28 17:30:50.632707+00');
INSERT INTO public.kb_translations VALUES
	('c624e53e-93c8-40fe-a4ea-5836ad2e564d', 'ru', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Около пятидесяти фондов сберегательных банков выдают пособия местным проектам в спорте, культуре, образовании и развитии общества — в зоне деятельности банка.', '2026-08-28 17:30:50.632707+00'),
	('b0d9893f-9964-4f14-9ae8-f51f1a3a7ed5', 'ru', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Финансируемая ЕС проектная поддержка, запрашиваемая в вашей местной зоне Leader — для объединений, компаний и коммун, развивающих сельскую местность.', '2026-08-28 17:30:50.632707+00'),
	('a36dc9eb-28ed-467f-a49a-7263fe65eeb6', 'ru', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Финансируемая ЕС поддержка для ищущих работу, устраивающихся в другой стране ЕС/ЕЭЗ: компенсация поездки на собеседование, расходов на переезд и языкового курса.', '2026-08-28 17:30:50.632707+00'),
	('0c139ee9-98ee-48ab-ab37-dbbce4993eb4', 'ru', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Средства социального фонда ЕС на проекты, укрепляющие компетенции, переквалификацию и инклюзию на рынке труда.', '2026-08-28 17:30:50.632707+00'),
	('a7ee9977-09ad-48a1-af64-73e83b38bc16', 'ru', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Поддержка ЕС для групповых обменов молодёжи 13–30 лет, длительностью 5–21 день без учёта дней в пути.', '2026-08-28 17:30:50.632707+00'),
	('26d7d92a-6449-407d-bf0f-64c91384986c', 'ru', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Поддержка ЕС для проектов сотрудничества культурных организаций с партнёрами в нескольких европейских странах.', '2026-08-28 17:30:50.632707+00'),
	('f017e2d4-33b0-4216-b31d-3d9798d77ca7', 'ru', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Поддержка ЕС для организаций, принимающих или направляющих молодых волонтёров 18–30 лет.', '2026-08-28 17:30:50.632707+00'),
	('36fe99c5-3719-498d-9872-c560745f29a9', 'ru', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Поддержка ЕС для мобильности персонала и учащихся в школе и образовании взрослых.', '2026-08-28 17:30:50.632707+00'),
	('3365bfa6-85f1-4f97-b15b-f65a55765cac', 'ru', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Поддержка ЕС с фиксированными суммами для первых европейских проектов сотрудничества небольших организаций.', '2026-08-28 17:30:50.632707+00'),
	('5a5798c7-b158-4c6d-a93f-5d1027a17bf2', 'ru', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Финансирование молодых компаний, разрабатывающих новаторские продукты или услуги с международным потенциалом.', '2026-08-28 17:30:50.632707+00'),
	('2efc6dd2-1553-44fb-b833-c211971361d4', 'ru', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Есть ли сберегательный банк (и, значит, фонд сберегательного банка) там, где вы ведёте деятельность?', '2026-08-28 17:30:50.632707+00'),
	('dccd8c3f-e99e-4f47-bfe3-f7fafc9233f4', 'ru', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Многолетние операционные пособия профессиональным независимым коллективам танца, театра и музыкального театра.', '2026-08-28 17:30:50.632707+00'),
	('3fe9c573-666c-405e-a88a-3be241383f06', 'ru', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Исследовательские пособия в областях Forte: здоровье, трудовая жизнь и благосостояние. Запрашивают исследователи с докторской степенью в шведских вузах.', '2026-08-28 17:30:50.632707+00'),
	('a4effa04-0a7d-45b5-9e9b-95899c4360df', 'ru', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Финансирование свободных фундаментальных исследований во всех областях науки.', '2026-08-28 17:30:50.632707+00'),
	('e36d1598-6b5f-40a2-97f4-8f7985b31bdc', 'ru', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Финансирование исследований в области окружающей среды, аграрных наук и градостроительства.', '2026-08-28 17:30:50.632707+00'),
	('ca0e89a4-82b1-4ea1-8462-4cf710bd19d6', 'ru', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Думаете ли вы о переезде за границу (работа, учёба или возвращение на родину)?', '2026-08-28 17:30:50.632707+00'),
	('9f1d1eb6-d3f2-4321-b660-f4097e80e0d5', 'ru', 'Genomförs insatserna av professionella kulturaktörer?', 'Проводятся ли мероприятия профессиональными деятелями культуры?', '2026-08-28 17:30:50.632707+00'),
	('c602c439-8f7c-4ebe-b07e-5a82828bc91c', 'ru', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Реализуется ли проект в сельской местности или небольшом населённом пункте?', '2026-08-28 17:30:50.632707+00'),
	('d2fdcc91-9bcb-4a70-a29a-d32621c3af51', 'ru', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Базовая защита для тех, у кого в течение жизни был низкий трудовой доход или его не было.', '2026-08-28 17:30:50.632707+00'),
	('370031a5-557b-4a8c-bfcf-effc373fa29a', 'ru', 'Går något av dina barn i grundskolan?', 'Ходит ли кто-то из ваших детей в основную школу?', '2026-08-28 17:30:50.632707+00'),
	('61c71170-f7fd-4d0d-8878-b24ec9a6e23d', 'ru', 'Går något av dina barn på gymnasiet?', 'Учится ли кто-то из ваших детей в гимназии?', '2026-08-28 17:30:50.632707+00'),
	('8b6febab-445c-4397-a794-a346d5dc259f', 'ru', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Касается ли наём человека со сниженной трудоспособностью?', '2026-08-28 17:30:50.632707+00'),
	('285f055a-4c8a-42e7-a9f8-23e0b7e3c1d6', 'ru', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Касается ли наём человека, долго бывшего безработным или недавно приехавшего в Швецию?', '2026-08-28 17:30:50.632707+00'),
	('97d59152-a4db-4b7c-92be-0f2923e1e8ac', 'ru', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Посвящён ли проект сохранению культурного наследия или обеспечению доступа к нему?', '2026-08-28 17:30:50.632707+00'),
	('21c9474a-cddb-4ca7-9963-1cb9833426b4', 'ru', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Посвящён ли проект энергетике, энергоэффективности или энергетическим инновациям?', '2026-08-28 17:30:50.632707+00'),
	('c366f26b-5eaf-4f8a-8308-9860ee30d08d', 'ru', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Посвящён ли проект здоровью, трудовой жизни или благосостоянию?', '2026-08-28 17:30:50.632707+00'),
	('5ba3ae0e-b6a8-4b11-b199-1fd44a17bfe2', 'ru', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Посвящён ли проект развитию компетенций или мерам на рынке труда?', '2026-08-28 17:30:50.632707+00'),
	('95320ec4-79f6-48e7-8dc1-c03fd1d974f3', 'ru', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Посвящён ли проект экологическим или климатическим мерам?', '2026-08-28 17:30:50.632707+00'),
	('b76ebafb-dd79-4603-b44e-54eeb686aa63', 'ru', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Длинная ли у ребёнка дорога в школу, опасная из-за движения или трудная по другим причинам?', '2026-08-28 17:30:50.632707+00'),
	('6801a882-89d1-44e5-b8cc-b17dede0712c', 'ru', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Работали ли вы не менее 16 часов в неделю в общей сложности не менее 8 лет?', '2026-08-28 17:30:50.632707+00'),
	('92cc18a4-b5bf-4eac-b634-29a5e9ba644b', 'ru', 'Har du barn som bor hos dig, helt eller växelvis?', 'Живут ли с вами дети — постоянно или попеременно?', '2026-08-28 17:30:50.632707+00'),
	('0bcf7cc7-a59c-426f-8271-4fc122d6ad59', 'ru', 'Har du barn som bor hos dig?', 'Живут ли с вами дети?', '2026-08-28 17:30:50.632707+00'),
	('a98aefd0-cf9d-4df5-bc9e-4c5df5f98a01', 'ru', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Есть ли у вас или вашего ребёнка инвалидность, которая, как ожидается, продлится не менее года?', '2026-08-28 17:30:50.632707+00'),
	('5e524dd6-22ea-476d-9796-88025edcbd56', 'ru', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Есть ли у вас или кого-то в семье стойкая инвалидность, влияющая на жильё?', '2026-08-28 17:30:50.632707+00'),
	('245f7ef8-c18c-4ee3-b09a-9d1fab943e17', 'ru', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Есть ли у вас или близкого родственника инвалидность либо длительная или тяжёлая болезнь?', '2026-08-28 17:30:50.632707+00'),
	('66c970bc-d2db-4ec4-a39b-bea78bb83a43', 'ru', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Есть ли у вас болезнь или травма, которая сейчас снижает вашу трудоспособность?', '2026-08-28 17:30:50.632707+00'),
	('a13210a5-2b26-41d9-a1d0-01f7e31e3ec7', 'ru', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Бывало ли вам трудно оплатить школьную экскурсию, классную поездку или досуговое занятие, в котором должен участвовать ваш ребёнок?', '2026-08-28 17:30:50.632707+00'),
	('da5b14b1-87e9-4374-a7ff-9263fe5bd6ce', 'ru', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Трудно ли вам прожить на пенсию и прочие доходы?', '2026-08-28 17:30:50.632707+00'),
	('272ad55a-8b8f-4ad0-bbae-ab919f549e47', 'ru', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Получали ли вы в последние годы вид на жительство в Швеции, например, как нуждающийся в защите или как член семьи?', '2026-08-28 17:30:50.632707+00'),
	('d9f52207-4a59-4e62-b6ca-ccd56fae622d', 'ru', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Есть ли у вас вид на жительство в Швеции как у беженца или нуждающегося в защите (или вы близкий родственник такого человека)?', '2026-08-28 17:30:50.632707+00'),
	('927f740a-5243-473d-8372-a52b4d6fe397', 'ru', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Достигли ли вы целевого пенсионного возраста (67 лет в 2026 году)?', '2026-08-28 17:30:50.632707+00'),
	('ee843a32-4ba9-4c09-b86a-932a1fdc1bd5', 'ru', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Есть ли у вашей организации OID (Organisation ID), зарегистрированный в Organisation Registration System ЕС?', '2026-08-28 17:30:50.632707+00'),
	('e0044720-93ab-4e23-bf7c-53bb0d93ac05', 'ru', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Повлекла ли инвалидность дополнительные расходы — например, вспомогательные средства, поездки, особое питание или износ?', '2026-08-28 17:30:50.632707+00'),
	('a851fcdc-70bc-41ba-a712-dd33f82ccf2c', 'ru', 'Har föreningen antagna stadgar och en vald styrelse?', 'Есть ли у объединения принятый устав и избранное правление?', '2026-08-28 17:30:50.632707+00'),
	('11478ef1-11d5-46be-8efa-56ba7770faef', 'ru', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Есть ли у объединения демократическое устройство (устав, годовое собрание, правление)?', '2026-08-28 17:30:50.632707+00'),
	('a851a399-3331-40c5-ac4e-e32642c44c04', 'ru', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Ведёт ли объединение регулярную деятельность для детей или молодёжи?', '2026-08-28 17:30:50.632707+00'),
	('5e9b1efb-016f-44c4-bc85-84eebbcac2e8', 'ru', 'Har företaget mellan cirka 2 och 49 anställda?', 'В компании примерно от 2 до 49 сотрудников?', '2026-08-28 17:30:50.632707+00'),
	('570bbee9-ccce-4eb0-821e-0c8c761f292f', 'ru', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Трудно ли семье покрывать расходы на еду, жильё и самое необходимое?', '2026-08-28 17:30:50.632707+00'),
	('7ac35f8a-e185-4d3b-815d-4ee28741d997', 'ru', 'Har lösningen internationell potential?', 'Есть ли у решения международный потенциал?', '2026-08-28 17:30:50.632707+00'),
	('c224ad52-195f-4ad7-8a2b-523376497543', 'ru', 'Har ni en partnergrupp i ett annat land?', 'Есть ли у вас партнёрская группа в другой стране?', '2026-08-28 17:30:50.632707+00');
INSERT INTO public.kb_translations VALUES
	('cbfcdbae-7f0c-4c68-b9f8-021605b4c4e8', 'ru', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Есть ли у вас партнёрская организация в другой европейской стране?', '2026-08-28 17:30:50.632707+00'),
	('b4907c42-aa2f-4f1b-9609-1ad6606c9dc4', 'ru', 'Har ni partner i minst tre olika europeiska länder?', 'Есть ли у вас партнёры как минимум в трёх разных европейских странах?', '2026-08-28 17:30:50.632707+00'),
	('1d4c9757-5c80-42cc-87b8-33274342bef5', 'ru', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Находится ли ваш офис или основная деятельность в регионе, где вы подаёте заявку?', '2026-08-28 17:30:50.632707+00'),
	('d2ad7fd9-cb06-418b-9ca6-706dbc0e87ea', 'ru', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Есть ли у кого-то из ваших детей инвалидность, из-за которой ребёнку нужно больше ухода или присмотра, чем другим детям того же возраста?', '2026-08-28 17:30:50.632707+00'),
	('bf1dcc14-853c-4f21-90d3-18208feb190c', 'ru', 'Har organisationen en demokratisk uppbyggnad?', 'Есть ли у организации демократическое устройство?', '2026-08-28 17:30:50.632707+00'),
	('c6db75ef-152b-4aad-84ee-41af9012b2f7', 'ru', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Есть ли у организации Quality Label (знак качества)?', '2026-08-28 17:30:50.632707+00'),
	('ab735d1b-f4ab-4dc2-9940-e83bb1a4e079', 'ru', 'Har organisationen ett 90-konto?', 'Есть ли у организации 90-konto?', '2026-08-28 17:30:50.632707+00'),
	('62c1d4a2-3796-4d3b-860d-d7f40861b1e1', 'ru', 'Har organisationen ett OID (Organisation ID)?', 'Есть ли у организации OID (Organisation ID)?', '2026-08-28 17:30:50.632707+00'),
	('d787599c-fa59-47de-b19d-988834843212', 'ru', 'Har organisationen ett OID?', 'Есть ли у организации OID?', '2026-08-28 17:30:50.632707+00'),
	('3751db5a-1c05-4ac0-8197-4098f08c2a5a', 'ru', 'Har organisationen medlemsföreningar i flera län?', 'Есть ли у организации объединения-члены в нескольких ленах?', '2026-08-28 17:30:50.632707+00'),
	('1e060c2f-ff1b-4fd4-be1c-b37734e2f278', 'ru', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Есть ли у организации упорядоченные финансы и демократическое устройство?', '2026-08-28 17:30:50.632707+00'),
	('b1d81b5c-5102-4f35-99ba-8c38262da77b', 'ru', 'Har projektet en partner i ett annat land?', 'Есть ли у проекта партнёр в другой стране?', '2026-08-28 17:30:50.632707+00'),
	('4d222066-38e3-4e99-a369-86db41c3d0ab', 'ru', 'Har projektledaren doktorsexamen?', 'Есть ли у руководителя проекта докторская степень?', '2026-08-28 17:30:50.632707+00'),
	('24ecb600-19b0-44d9-a2a9-b5b2b25725bb', 'ru', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Домашняя коммуна должна обеспечивать ежедневные поездки между домом и гимназией, если дорога составляет не менее шести километров (например, проездной на автобус).', '2026-08-28 17:30:50.632707+00'),
	('c4ff4c6c-0c20-4e6b-ba6f-2f8153bfb914', 'ru', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Обзаводитесь ли вы своим первым собственным жильём в Швеции или обустраиваете его?', '2026-08-28 17:30:50.632707+00'),
	('1f574fcd-5c7c-4710-b5db-4fd048b8d6e4', 'ru', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Включает ли проект международную поездку или обмен?', '2026-08-28 17:30:50.632707+00'),
	('a5c0bc57-23b9-4dcd-8b33-d3c802e1e505', 'ru', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Инвестиционная поддержка компаниям в зонах поддержки — на здания, оборудование и обучение.', '2026-08-28 17:30:50.632707+00'),
	('60a7f052-c773-4fe6-8ce8-ddf2efe52660', 'ru', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Инвестиционная поддержка мер, снижающих выбросы парниковых газов.', '2026-08-28 17:30:50.632707+00'),
	('0c5a87e9-3e58-48fe-bdbd-a3a2278ceae0', 'ru', 'Kan projektets miljönytta mätas?', 'Можно ли измерить экологическую пользу проекта?', '2026-08-28 17:30:50.632707+00'),
	('ec0e0c66-43f9-4b43-a84c-31a2a724d05a', 'ru', 'Kan åtgärdens utsläppsminskning beräknas?', 'Можно ли рассчитать снижение выбросов от меры?', '2026-08-28 17:30:50.632707+00'),
	('045b63fc-ec38-4de6-bd50-c0b7fe61e74b', 'ru', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Может ли организация нести расходы до выплаты поддержки?', '2026-08-28 17:30:50.632707+00'),
	('9e00c93b-5624-495a-99c9-7ac11dd7235d', 'ru', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Будет ли опыт использоваться в вашей деятельности в Швеции?', '2026-08-28 17:30:50.632707+00'),
	('fb9cb398-2248-4982-88b0-ee18509b1bbe', 'ru', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Начнётся ли инвестиция только после подачи заявки?', '2026-08-28 17:30:50.632707+00'),
	('95aed36b-1737-45b8-8d15-0d4ba94dc69e', 'ru', 'Kommer projektet människor i ert närområde till del?', 'Приносит ли проект пользу людям в вашей местности?', '2026-08-28 17:30:50.632707+00'),
	('ae7e1601-e7be-4fe6-b1f4-75c332ee2cd1', 'ru', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Крайняя экономическая защита коммуны, когда доходов не хватает на самое необходимое.', '2026-08-28 17:30:50.632707+00'),
	('ef076dc9-af1d-4601-8489-55dab0ac488a', 'ru', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Собственная поддержка коммун местным объединениям: пособие за занятие, помощь с помещениями, стартовое пособие и другое.', '2026-08-28 17:30:50.632707+00'),
	('1a8516bd-0283-4dea-85d1-cc8e31f2e035', 'ru', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Бесплатный школьный транспорт для учеников основной школы при большом расстоянии, опасной дороге или инвалидности — право по школьному закону.', '2026-08-28 17:30:50.632707+00'),
	('4350d0f3-30b0-42d4-9be8-8d81c5b2759f', 'ru', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Установленное законом пособие на очки или линзы для детей и молодёжи; суммы и порядок различаются по регионам — проверьте уровень своего региона.', '2026-08-28 17:30:50.632707+00'),
	('0ae6f334-b1d1-405d-ba1d-b7b6884fb85b', 'ru', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Находится ли проект в местности, затронутой гидро- или ветроэнергетикой?', '2026-08-28 17:30:50.632707+00'),
	('31eb2c4d-130d-4766-968c-adc08fa43f90', 'uk', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Чи веде об''єднання регулярну діяльність у комуні?', '2026-08-28 17:30:50.641951+00'),
	('48ac5788-f425-48c7-ab0c-94a293771ae4', 'ru', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Относится ли проект к окружающей среде, аграрным наукам или градостроительству?', '2026-08-28 17:30:50.632707+00'),
	('e45fa152-13ac-4ca4-95fd-d39a28a9935f', 'ru', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Находится ли место деятельности в зоне поддержки A или B (большая часть Норрланда и внутреннего Свеаланда)?', '2026-08-28 17:30:50.632707+00'),
	('8032654b-168e-4da7-8b35-470571e07a5e', 'ru', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Заём на покупку самого необходимого для первого дома в Швеции — мебели, домашней утвари и другого базового оснащения.', '2026-08-28 17:30:50.632707+00'),
	('3515583a-8ae7-4f79-b440-2ffc1afd5a76', 'ru', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Снижает ли проект технологические выбросы промышленности или создаёт отрицательные выбросы?', '2026-08-28 17:30:50.632707+00'),
	('01956d21-9c1b-4919-8299-bce6d720fe44', 'ru', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Ежемесячное пособие на детей, живущих в Швеции, от рождения до 16 лет.', '2026-08-28 17:30:50.632707+00'),
	('a069d89c-7e73-4bb8-9666-a3ded5977f0a', 'ru', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket предлагает пособия организациям, компаниям, объединениям, публичному сектору и частным лицам в сфере экологии.', '2026-08-28 17:30:50.632707+00'),
	('815cf44a-9091-4813-86b7-d5dbd3bc7670', 'ru', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Планируете ли вы добровольно навсегда вернуться в страну происхождения?', '2026-08-28 17:30:50.632707+00'),
	('e7a26b18-a9ef-4778-8b87-4639f8c4874a', 'ru', 'Planerar du att starta eget företag?', 'Планируете ли вы открыть собственное дело?', '2026-08-28 17:30:50.632707+00'),
	('692119be-8dc5-443d-86ae-0589ccf8c81c', 'ru', 'Planerar du att studera utomlands?', 'Планируете ли вы учиться за границей?', '2026-08-28 17:30:50.632707+00'),
	('7539d910-726d-4c12-b1bf-90fe09fe4dc9', 'ru', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Планируете ли вы учёбу, укрепляющую вашу позицию на рынке труда?', '2026-08-28 17:30:50.632707+00'),
	('0078a6a0-bbee-40aa-b83e-0f8c3f11eb20', 'ru', 'Planerar ni att anställa?', 'Планируете ли вы нанимать сотрудников?', '2026-08-28 17:30:50.632707+00'),
	('e7bc6de9-0387-49e6-8f84-d4d20ad70d9d', 'ru', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Планируете ли вы подавать заявку на программу ЕС (например, Horisont Europa)?', '2026-08-28 17:30:50.632707+00'),
	('06aae910-3050-46d6-afe1-9a925c9973df', 'ru', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Поддержка производства и разработки короткометражных и документальных фильмов.', '2026-08-28 17:30:50.632707+00'),
	('7f60ba44-cc75-4d2d-a369-75c6b3400c5e', 'ru', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Проектные пособия свободной музыкальной сцене на концерты, производство и развитие.', '2026-08-28 17:30:50.632707+00'),
	('41e5efda-2d4f-487d-b895-1957600c5843', 'ru', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Проектные пособия некоммерческим организациям, работающим с детьми и молодёжью и для них.', '2026-08-28 17:30:50.632707+00'),
	('6db4b579-6e9c-4f3d-884f-c6aec9daf475', 'ru', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Пробует ли проект новые художественные выражения, методы или сотрудничества?', '2026-08-28 17:30:50.632707+00'),
	('2a1844b9-04be-4c69-9ff2-f080156bae9b', 'ru', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Длится ли обмен 5–21 день (без учёта дней в пути)?', '2026-08-28 17:30:50.632707+00'),
	('0ce7e81b-f718-4354-b92f-414b037a7c2e', 'ru', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Собственная проектная и операционная поддержка регионов культурной жизни, наряду с национальными пособиями Kulturrådet.', '2026-08-28 17:30:50.632707+00'),
	('971106a8-c86d-46e1-9d07-eb98a2c36494', 'ru', 'Riktar sig projektet till barn eller unga?', 'Адресован ли проект детям или молодёжи?', '2026-08-28 17:30:50.632707+00'),
	('b69d4a9d-83af-4f07-8536-5f049310bfe8', 'ru', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Адресован ли проект детям, молодёжи, пожилым или людям с инвалидностью?', '2026-08-28 17:30:50.632707+00');
INSERT INTO public.kb_translations VALUES
	('9d5925cf-2e99-4ebd-a403-d72ec77b64ee', 'ru', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Адресована ли деятельность детям и молодёжи (7–25 лет)?', '2026-08-28 17:30:50.632707+00'),
	('5992014c-6433-4e22-a033-84dee2b0e837', 'ru', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'У вас нет сбережений или активов, которые могли бы покрыть расходы?', '2026-08-28 17:30:50.632707+00'),
	('ec6b2605-605c-48d4-b4b9-da78aae9390a', 'ru', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Сотрудничаете ли вы с партнёрами как минимум в двух других северных странах?', '2026-08-28 17:30:50.632707+00'),
	('81950819-4b6c-4dbf-8d8d-378e2b94bb59', 'ru', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Собираетесь ли вы привлечь внешнюю экспертизу для меры развития?', '2026-08-28 17:30:50.632707+00'),
	('98a1587b-b3dd-41d7-bded-7dbdc71456ea', 'ru', 'Sker mobiliteten till ett annat europeiskt land?', 'Направлена ли мобильность в другую европейскую страну?', '2026-08-28 17:30:50.632707+00'),
	('b2f6d824-e211-4a0c-9992-575590111c47', 'ru', 'Startar du eller tar du över företaget för första gången?', 'Открываете ли вы предприятие или берёте его на себя впервые?', '2026-08-28 17:30:50.632707+00'),
	('51afcd04-4a36-4b0e-b637-6361c0eabe6a', 'ru', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Стартовая поддержка для тех, кому 40 лет или меньше, кто открывает сельскохозяйственное предприятие или берёт его на себя.', '2026-08-28 17:30:50.632707+00'),
	('be5667ae-dd2a-4070-b5b5-0f7383fd003e', 'ru', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Стипендия, позволяющая профессиональным художникам сосредоточиться на художественной работе.', '2026-08-28 17:30:50.632707+00'),
	('32a6d4b9-e163-457f-bb1b-79856a5c5441', 'ru', 'Studerar du, eller planerar du att börja studera?', 'Учитесь ли вы или планируете начать учёбу?', '2026-08-28 17:30:50.632707+00'),
	('23178dbc-fe71-4b12-b3fc-2b70b0c3a40f', 'ru', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Существенно ли новаторское ваше решение по сравнению с уже существующим?', '2026-08-28 17:30:50.63643+00'),
	('70dbf387-a5fc-41b6-b884-8fbe9b2454c6', 'ru', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Учебная поддержка для работающих взрослых, желающих получить образование для укрепления позиции на рынке труда.', '2026-08-28 17:30:50.632707+00'),
	('5a449087-0758-4243-9f47-32a69e95faab', 'ru', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Поддержка инвестиций, повышающих конкурентоспособность или снижающих воздействие на окружающую среду в сельскохозяйственных предприятиях.', '2026-08-28 17:30:50.632707+00'),
	('3e95f018-1cec-4997-b952-4666720a0102', 'ru', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Поддержка, когда ребёнок живёт с вами, а другой родитель не платит содержание.', '2026-08-28 17:30:50.632707+00'),
	('02bb72c4-e399-4a9c-93ff-059fca6191e5', 'ru', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Поддержка проектов некоммерческих организаций для людей, окружающей среды и лучшего мира.', '2026-08-28 17:30:50.632707+00'),
	('67263b1e-da8c-42d0-8337-50e956143423', 'ru', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Поддержка перехода промышленности к нулевым выбросам парниковых газов.', '2026-08-28 17:30:50.632707+00'),
	('bfb96cbb-6973-422a-99b2-2cdbc7eeb839', 'ru', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Поддержка художественных и культурных проектов с северным измерением и трансграничным сотрудничеством.', '2026-08-28 17:30:50.632707+00'),
	('36de4d4f-8eba-4fef-9e73-3143e90418ee', 'ru', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Поддержка новаторских культурных проектов, пробующих новые художественные выражения, методы или сотрудничества.', '2026-08-28 17:30:50.632707+00'),
	('4d725afa-4f0c-432b-86cd-19ec848443b1', 'ru', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Поддержка новаторских проектов для детей, молодёжи, пожилых и людей с инвалидностью.', '2026-08-28 17:30:50.632707+00'),
	('3899d3dc-8d6f-4fbf-8aec-95e27e18c605', 'ru', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Поддержка проектов сотрудничества в свободной музыкальной сцене.', '2026-08-28 17:30:50.632707+00'),
	('f4a6847f-b9c5-46cc-9782-dcadb58cdd0c', 'ru', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Поддержка проектов сотрудничества в культуре и медиа, укрепляющих демократию и свободу слова на международном уровне.', '2026-08-28 17:30:50.632707+00'),
	('5ab44f54-6f30-4ac7-a730-04ca15470c97', 'ru', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Направлен ли проект на укрепление демократии, равенства или свободы слова?', '2026-08-28 17:30:50.632707+00'),
	('40a96267-64a9-4873-be6b-ce9556b190d7', 'ru', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Ищете ли вы работу или получили предложение о работе в другой стране ЕС или ЕЭЗ?', '2026-08-28 17:30:50.632707+00'),
	('28729eb9-f48d-4939-b10b-af9f04048127', 'ru', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Потолок того, что вы платите в виде пациентских сборов за двенадцать месяцев — затем frikort (бесплатная карта).', '2026-08-28 17:30:50.632707+00'),
	('84dbca6e-e281-475c-9e1e-bcc68ffb3772', 'ru', 'Tar du ut hel allmän pension?', 'Получаете ли вы полную государственную пенсию?', '2026-08-28 17:30:50.632707+00'),
	('f34d3fde-8705-4171-a66c-49e463b365fb', 'ru', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Надбавка, покрывающая часть расходов на жильё для тех, у кого пенсия и низкие доходы.', '2026-08-28 17:30:50.632707+00'),
	('056b69f1-4533-4b2a-bf68-edde742769b2', 'ru', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Ежегодное организационное пособие национальным детским и молодёжным организациям.', '2026-08-28 17:30:50.632707+00'),
	('6f1cce70-17ab-4e3f-9a2c-726c61cb6d2b', 'ru', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Ежегодная сумма, вычитаемая напрямую у стоматолога или зубного гигиениста.', '2026-08-28 17:30:50.632707+00'),
	('af21061d-c3aa-4e7f-9a5a-e765b3bc2133', 'ru', 'Är bolaget yngre än cirka 5 år?', 'Компании меньше примерно 5 лет?', '2026-08-28 17:30:50.632707+00'),
	('005dd77f-52f2-42d3-b9a2-a0faed38966a', 'ru', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Участникам обмена от 13 до 30 лет?', '2026-08-28 17:30:50.632707+00'),
	('5576ae3e-0a59-45ca-9268-6ef6413bfe61', 'ru', 'Är det här ert första EU-projekt?', 'Это ваш первый проект ЕС?', '2026-08-28 17:30:50.632707+00'),
	('287c946f-a8c3-41de-91c5-d46ca5082ba4', 'ru', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Очень ли трудно вам (или вашему ребёнку) передвигаться самостоятельно или ездить на автобусе и поезде?', '2026-08-28 17:30:50.632707+00'),
	('86b042d4-2a59-4464-b6e2-139c702a63db', 'ru', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Ваш доход ниже примерно 25 000 крон в месяц до налогов?', '2026-08-28 17:30:50.632707+00'),
	('ba82f68b-d572-4022-89eb-eef3f8067c71', 'ru', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Ваше последнее законченное образование — основная школа или незаконченная гимназия?', '2026-08-28 17:30:50.632707+00'),
	('261fd28a-ab7e-47e1-b824-1c3876f94816', 'ru', 'Är du 40 år eller yngre?', 'Вам 40 лет или меньше?', '2026-08-28 17:30:50.632707+00'),
	('1471fb3f-9ebb-4603-b02d-8bf9eda30349', 'ru', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Зарегистрированы ли вы как ищущий работу в Arbetsförmedlingen?', '2026-08-28 17:30:50.632707+00'),
	('06e40314-3dda-4760-99ed-3d63c24be8ba', 'ru', 'Är du mellan 18 och 28 år?', 'Вам от 18 до 28 лет?', '2026-08-28 17:30:50.632707+00'),
	('dfc9941d-7227-49f5-9c38-6804da42a121', 'ru', 'Är du mellan 19 och 29 år?', 'Вам от 19 до 29 лет?', '2026-08-28 17:30:50.632707+00'),
	('d9daf577-2526-494d-a4fe-d36569788a82', 'ru', 'Är du mellan 25 och 60 år?', 'Вам от 25 до 60 лет?', '2026-08-28 17:30:50.632707+00'),
	('e9ca6f9e-7af5-49b8-9848-cd89c45994c3', 'ru', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Работаете ли вы профессионально в сфере культуры (например, танец, музыка, сценическое искусство)?', '2026-08-28 17:30:50.632707+00'),
	('901ed23f-f946-4d9a-a958-74bb498e22f9', 'ru', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Вы профессиональный художник (не любитель и не на базовом обучении)?', '2026-08-28 17:30:50.632707+00'),
	('2af1ec82-d740-4554-a99c-58cc9118e480', 'ru', 'Är du yrkesverksam konstnär?', 'Вы профессиональный художник?', '2026-08-28 17:30:50.632707+00'),
	('bdf2c834-2758-42bb-9101-09704b4ff4ee', 'ru', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Входит ли клуб в специализированную спортивную федерацию в составе Riksidrottsförbundet?', '2026-08-28 17:30:50.63643+00'),
	('3f9e681e-7d48-4d2e-ae04-9bff2b541ef9', 'ru', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Низки ли доходы семьи по отношению к расходам на жильё?', '2026-08-28 17:30:50.63643+00'),
	('ffc69a2c-4cf0-455f-817f-614e6fda4391', 'ru', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Совокупный доход семьи ниже примерно 25 000 крон в месяц до налогов?', '2026-08-28 17:30:50.63643+00'),
	('21ec14a1-121f-4e16-9f21-e6fcb3eae9a7', 'ru', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Является ли мера отдельным проектом (а не обычной деятельностью)?', '2026-08-28 17:30:50.63643+00'),
	('4538a1dc-63cd-43b4-ae1c-34f0f8b2f0bd', 'ru', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Открыто ли помещение для всех — не только для собственных членов?', '2026-08-28 17:30:50.63643+00'),
	('c53d910e-fc23-4b0b-82b1-a5f5fde835f5', 'ru', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Не менее 60 % членов в возрасте от 6 до 25 лет?', '2026-08-28 17:30:50.63643+00'),
	('fb1c2e24-6aba-42f7-84b3-47ba006b91de', 'ru', 'Är minst 60 % av medlemmarna under 26 år?', 'Не менее 60 % членов младше 26 лет?', '2026-08-28 17:30:50.63643+00'),
	('ce9c714f-6b50-4478-b065-395ccde8f9e4', 'ru', 'Är målgruppen delaktig i planering och genomförande?', 'Участвует ли целевая группа в планировании и реализации?', '2026-08-28 17:30:50.63643+00'),
	('7c5d71d8-a736-4c72-bf65-2f2d983819b7', 'ru', 'Är ni ett förlag med professionell utgivning?', 'Вы издательство с профессиональным книгоизданием?', '2026-08-28 17:30:50.63643+00');
INSERT INTO public.kb_translations VALUES
	('6c32ba4f-3085-480e-b87c-a8fe9ad7674a', 'ru', 'Är ni huvudman för förskoleklass eller grundskola?', 'Являетесь ли вы ответственной организацией дошкольного класса или основной школы?', '2026-08-28 17:30:50.63643+00'),
	('01caf209-a21b-447e-9732-e5740a86f8b4', 'ru', 'Är organisationen registrerad i EU:s deltagarregister?', 'Зарегистрирована ли организация в реестре участников ЕС?', '2026-08-28 17:30:50.63643+00'),
	('c1100707-fc78-4512-b67c-faa327ecafd0', 'ru', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Это кинопроект (короткометражный или документальный фильм)?', '2026-08-28 17:30:50.63643+00'),
	('c886cbde-8560-43e8-b869-b8e40ab3b1df', 'ru', 'Är projektet ett konst- eller kulturprojekt?', 'Это художественный или культурный проект?', '2026-08-28 17:30:50.63643+00'),
	('64e3a691-6010-43e2-960e-ebb141ba212c', 'ru', 'Är projektet ett kulturprojekt?', 'Это культурный проект?', '2026-08-28 17:30:50.63643+00'),
	('d7ee35fd-8137-45e1-b380-71b9e20476b8', 'ru', 'Är projektet ett musikprojekt?', 'Это музыкальный проект?', '2026-08-28 17:30:50.63643+00'),
	('f2e5967c-facb-4609-b94a-d23a36230cd7', 'ru', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Новаторский ли проект — то, чего вы ещё не делаете в обычной деятельности?', '2026-08-28 17:30:50.63643+00'),
	('bad29a66-305b-4d65-a316-f1ee3682769e', 'ru', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Приносит ли проект пользу местности в целом (а не отдельным лицам)?', '2026-08-28 17:30:50.63643+00'),
	('555ad7dd-b559-439b-b2a8-dbc76e06ebc6', 'ru', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Дорога между домом и гимназией составляет не менее шести километров?', '2026-08-28 17:30:50.63643+00'),
	('7ef90932-a8c3-4f60-915c-e21876b65d7a', 'ru', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Профессиональная ли это деятельность (не любительская)?', '2026-08-28 17:30:50.63643+00'),
	('61c50331-edb1-4f37-9083-b946e8cf12f4', 'ru', 'Är verksamheten professionell?', 'Профессиональная ли это деятельность?', '2026-08-28 17:30:50.63643+00'),
	('8cbf13b8-4498-4d13-834e-741da0fea8de', 'ru', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Относится ли деятельность к сценическому искусству (танец, театр, музыкальный театр)?', '2026-08-28 17:30:50.63643+00'),
	('2a01a6c3-da94-47b4-a65e-c59af26909cd', 'ru', 'Är volontärerna mellan 18 och 30 år?', 'Волонтёрам от 18 до 30 лет?', '2026-08-28 17:30:50.63643+00'),
	('3ee4aac3-6e4d-43f5-9e79-785498d0a7ff', 'uk', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Підтримка діяльності спортивних клубів, що проводять заняття під керівництвом тренерів для дітей та молоді 7–25 років.', '2026-08-28 17:30:50.641951+00'),
	('3dad0937-b70b-4365-a395-bda257d8dd7b', 'uk', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Автоматична надбавка до дитячої допомоги (barnbidrag) починаючи з другої дитини.', '2026-08-28 17:30:50.641951+00'),
	('213de713-9796-4df5-9683-9bce03387e6d', 'uk', 'Avser ansökan en fysisk investering?', 'Чи стосується заявка фізичної інвестиції?', '2026-08-28 17:30:50.641951+00'),
	('2b2bd11f-52ca-43e1-9677-5499d0c2b130', 'uk', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Чи стосується заявка міжнародної поїздки або обміну?', '2026-08-28 17:30:50.641951+00'),
	('8c6d01cb-b6d7-4e7d-9e4e-55bc1345a90f', 'uk', 'Avser ansökan en investering i byggnader eller maskiner?', 'Чи стосується заявка інвестиції в будівлі або обладнання?', '2026-08-28 17:30:50.641951+00'),
	('4b623d78-49f9-4f4e-af0d-ad519b243642', 'uk', 'Avser ansökan en redan utgiven titel?', 'Чи стосується заявка вже виданого твору?', '2026-08-28 17:30:50.641951+00'),
	('26210ffc-5dc5-4c4b-a94c-1602d563dfa2', 'uk', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Чи стосується заявка сільськогосподарського, садівничого чи оленярського підприємства?', '2026-08-28 17:30:50.641951+00'),
	('f34f1d24-18af-4bc2-a57f-fcb7bd6e8519', 'uk', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Чи стосується заявка закупівлі літератури для публічних або шкільних бібліотек?', '2026-08-28 17:30:50.641951+00'),
	('812851f9-f9d5-4d2c-9faf-d6150913cfc6', 'uk', 'Avser investeringen jordbruksverksamhet?', 'Чи стосується інвестиція сільськогосподарської діяльності?', '2026-08-28 17:30:50.641951+00'),
	('874fa6d0-8073-493b-820f-b4fc22b7a906', 'uk', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Чи передбачає проєкт будівництво, купівлю або ремонт приміщення?', '2026-08-28 17:30:50.641951+00'),
	('5d9a0534-0090-4501-8e1b-68ff1975ef3a', 'uk', 'Avser projektet naturvård eller friluftsliv?', 'Чи стосується проєкт охорони природи або активного відпочинку на природі?', '2026-08-28 17:30:50.641951+00'),
	('81d367cd-3c0a-4b1c-87fe-22a7d10f0999', 'uk', 'Avser projektet skola eller vuxenutbildning?', 'Чи стосується проєкт школи або освіти дорослих?', '2026-08-28 17:30:50.641951+00'),
	('c93412cc-29f4-45f1-b93c-3fe0db23f0f1', 'uk', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Чи відмовляєтеся ви від роботи, щоб доглядати за близькою людиною або бути поруч із нею, коли хвороба настільки тяжка, що загрожує її життю?', '2026-08-28 17:30:50.641951+00'),
	('fdd6ec89-70cd-4f00-ac8b-8e64a4293b39', 'uk', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Чи вважаєте ви, що ваша працездатність знижена щонайменше на рік через хворобу або інвалідність?', '2026-08-28 17:30:50.641951+00'),
	('c765ce04-30be-4547-99a6-08e7ed8dcb43', 'uk', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Адресна підтримка для тих, хто має низьку пенсію або не має її, і потребує допомоги для досягнення прийнятного рівня життя.', '2026-08-28 17:30:50.641951+00'),
	('d2566b10-d5a1-4f12-acaa-63a54505061a', 'uk', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Чи потрібно дитині жити в місці навчання (проживання), бо дорога надто довга?', '2026-08-28 17:30:50.641951+00'),
	('dbd5b473-6e71-40dc-859e-3eefe260895d', 'uk', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Чи потрібно адаптувати житло (наприклад, пандус, автоматичні двері, ванна)?', '2026-08-28 17:30:50.641951+00'),
	('a1e93cd7-5386-4253-bd2e-29619c2877ba', 'uk', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Чи потрібні комусь із ваших дітей 8–19 років окуляри або лінзи?', '2026-08-28 17:30:50.641951+00'),
	('160f7dea-9997-4c06-adb9-0138d39b7eb7', 'uk', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Другий із батьків не платить нічого або платить менше за повне утримання?', '2026-08-28 17:30:50.641951+00'),
	('7334e766-b597-4954-9bda-575003b6145a', 'uk', 'Betalar du hyra eller andra boendekostnader?', 'Чи сплачуєте ви оренду або інші витрати на житло?', '2026-08-28 17:30:50.641951+00'),
	('27c52afc-c849-47e9-9886-dcd96c0ad171', 'uk', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Допомога на адаптацію житла при інвалідності — наприклад, пандуси, автоматичні двері чи переобладнання ванної.', '2026-08-28 17:30:50.641951+00'),
	('91d133ec-899c-4a80-ae2f-6e316fb1586d', 'uk', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Допомоги на будівництво, купівлю або ремонт громадських приміщень для зібрань.', '2026-08-28 17:30:50.641951+00'),
	('610bfe32-412a-44d9-bf41-31a4b1be1060', 'uk', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Допомога на купівлю або адаптацію автомобіля, коли стійка інвалідність значно ускладнює пересування чи поїздки громадським транспортом.', '2026-08-28 17:30:50.641951+00'),
	('7d0752a0-21a1-4119-b8a4-894479cc483b', 'uk', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Допомоги на міжнародні поїздки та обміни для професіоналів у сфері культури.', '2026-08-28 17:30:50.641951+00'),
	('63cbf99a-c25f-43b4-9105-91fca1e1d4f2', 'uk', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Допомоги на міжнародні обміни, поїздки та робочі перебування професійних митців.', '2026-08-28 17:30:50.641951+00'),
	('06f913e7-d2ac-43e4-b52f-bd542892a2f1', 'uk', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Допомога та добровільна позика для навчання на гімназійному або післягімназійному рівні.', '2026-08-28 17:30:50.641951+00'),
	('43b746dc-9e74-4dcc-8927-0d2d439996f9', 'uk', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Допомоги й позики для навчання за кордоном, з додатковими позиками, наприклад, на плату за навчання та поїздки.', '2026-08-28 17:30:50.641951+00'),
	('a08e4ca4-22c6-4e7f-a659-1ff6193167eb', 'uk', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Допомога, що допомагає шведським організаціям готувати заявки на програми ЄС, як-от Horisont Europa.', '2026-08-28 17:30:50.641951+00'),
	('f4ce34c0-e47b-4845-9b3d-c4ea044d1e5a', 'uk', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Допомога роботодавцям, які наймають людей зі зниженою працездатністю.', '2026-08-28 17:30:50.641951+00'),
	('f02ae91b-a617-4204-90c8-f89333ec62df', 'uk', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Допомога на проживання та поїздки додому, коли гімназист мусить жити в місці навчання через довгу дорогу.', '2026-08-28 17:30:50.641951+00'),
	('4244b969-82f2-4eb4-8878-4e3d2034079c', 'uk', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Допомоги на роботу неприбуткових організацій зі збереження, використання та розвитку культурної спадщини.', '2026-08-28 17:30:50.641951+00'),
	('bce7b79a-a56d-4bef-96d0-9b4e1879512a', 'uk', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Допомоги на муніципальні та місцеві природоохоронні проєкти, включно з водно-болотними угіддями та активним відпочинком.', '2026-08-28 17:30:50.641951+00'),
	('c84c75bd-f560-402f-a792-545e569a9d24', 'uk', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Допомоги комунам на закупівлю літератури для публічних і шкільних бібліотек.', '2026-08-28 17:30:50.641951+00'),
	('4233384a-2c36-4586-837d-167db9947986', 'uk', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Допомоги шкільним організаціям для знайомства учнів основної школи з професійною культурою.', '2026-08-28 17:30:50.641951+00'),
	('40839dcf-00f8-4dc2-a22c-40b795dfdcdc', 'uk', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Допомога на те, що потрібно вашій дитині, але на що не вистачає сімейного бюджету: дозвілля, одяг, шкільні екскурсії, окуляри, канікулярні заняття тощо.', '2026-08-28 17:30:50.641951+00'),
	('0dea77ce-9350-41be-a724-146b449a7dbf', 'uk', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Допомоги з фондів Världens Barn, Musikhjälpen і Victoriafonden — їх запитують шведські неприбуткові організації з 90-konto.', '2026-08-28 17:30:50.641951+00'),
	('e1d5bb03-df27-4d1f-8cea-fc732a5f811e', 'uk', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Допомоги з коштів гідро- та вітроенергетики на проєкти, що розвивають місцевість.', '2026-08-28 17:30:50.641951+00');
INSERT INTO public.kb_translations VALUES
	('00864a70-e277-4638-851e-624ca530a559', 'so', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Khibradaha ma loo isticmaali doonaa hawshaada Sweden gudaheeda?', '2026-08-28 17:30:50.650239+00'),
	('5d483b3e-7b2d-49ea-8024-02638b0447d3', 'uk', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Допомога без позикової частини для безробітних 25–60 років із короткою освітою, яким потрібно вчитися на рівні основної школи або гімназії.', '2026-08-28 17:30:50.641951+00'),
	('47f3b644-434b-40f8-89e4-f65c6080cca1', 'uk', 'Bidrar projektet till energiomställningen?', 'Чи робить проєкт внесок в енергетичний перехід?', '2026-08-28 17:30:50.641951+00'),
	('efa63251-c2a6-401f-a38f-0e3dd7884f45', 'uk', 'Bor du och barnets andra förälder på skilda håll?', 'Чи живете ви й другий із батьків дитини окремо?', '2026-08-28 17:30:50.641951+00'),
	('087cb83c-e33d-4ddf-94b3-06e83689ecd4', 'uk', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Чеки для малих підприємств на залучення зовнішньої експертизи для інтернаціоналізації або цифровізації.', '2026-08-28 17:30:50.641951+00'),
	('53798321-2914-4d6b-8868-3d34a2e8cf45', 'uk', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Чи берете ви участь у програмі Arbetsförmedlingen (наприклад, jobb- och utvecklingsgarantin)?', '2026-08-28 17:30:50.641951+00'),
	('bc359e55-5918-4e0f-8bb2-e6e1065844b6', 'uk', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Подальша підтримка видавництвам за випуск якісної літератури.', '2026-08-28 17:30:50.641951+00'),
	('28346e37-2cef-49e6-aaf2-0464904c34c4', 'uk', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Економічна підтримка для тих, хто має посвідку на проживання за захистом і добровільно хоче назавжди повернутися до країни походження.', '2026-08-28 17:30:50.641951+00'),
	('368d9d56-12e1-4413-8f5f-48cc87fed895', 'uk', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Економічна підтримка роботодавцям, які наймають людину, що довго не працювала.', '2026-08-28 17:30:50.641951+00'),
	('0b01643e-7e30-4435-805f-a8043770eac0', 'uk', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Економічна підтримка на етапі запуску для шукачів роботи, які відкривають власну справу.', '2026-08-28 17:30:50.641951+00'),
	('b60c440b-0cec-43b6-a5a2-2c5c84e70ce5', 'uk', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten постійно відкриває конкурси в галузі енергетичних досліджень, інновацій та енергоефективності.', '2026-08-28 17:30:50.641951+00'),
	('ec4dc7ee-d8f3-4f04-bfec-ed9d0a0114c0', 'uk', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Виплата за відсутність на роботі чи навчанні для догляду за дитиною.', '2026-08-28 17:30:50.641951+00'),
	('f8a10140-49d3-4d21-8524-bf252085254f', 'uk', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Виплата для тих, хто нещодавно у Швеції та бере участь у програмі адаптації Arbetsförmedlingen; виплачує Försäkringskassan.', '2026-08-28 17:30:50.641951+00'),
	('dcb0d0ac-e66d-4b9d-a804-de4e49bb2241', 'uk', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Виплата, що покриває частину витрат на житло для молоді без дітей із низькими доходами.', '2026-08-28 17:30:50.641951+00'),
	('0688aeba-40a2-43a8-b1e3-778d1dec52ae', 'uk', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Виплата за додаткові витрати, пов''язані зі стійкою інвалідністю — для дорослих або батьків дітей з інвалідністю.', '2026-08-28 17:30:50.641951+00'),
	('15a67829-a9cb-4417-a39f-b8aceee7e2a6', 'uk', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Виплата для молоді (19–29 років), яка не може працювати повний день щонайменше рік через хворобу чи інвалідність.', '2026-08-28 17:30:50.641951+00'),
	('1c0672c0-f1ee-4424-a2ab-02ad45592ea6', 'uk', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Виплата при стійко зниженій працездатності — те, що раніше називалося förtidspension (дострокова пенсія).', '2026-08-28 17:30:50.641951+00'),
	('70aac71e-002b-4f4c-9457-1bbc6edf2dda', 'uk', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Виплата, коли ви відмовляєтеся від роботи, щоб бути поруч із тяжкохворою близькою людиною.', '2026-08-28 17:30:50.641951+00'),
	('ae994c2f-ae93-4bc5-a11d-960d5c1e2240', 'uk', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Виплата за участь у програмі ринку праці Arbetsförmedlingen.', '2026-08-28 17:30:50.641951+00'),
	('58edddfb-d1a6-4c64-b9f3-8757c8b70260', 'uk', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Виплата, коли ви не можете працювати як зазвичай через хворобу.', '2026-08-28 17:30:50.641951+00'),
	('9d8ba886-71bc-4b14-bba0-5fff1cbf59a0', 'uk', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Виплата, коли ви залишаєтеся вдома з роботи для догляду за хворою дитиною.', '2026-08-28 17:30:50.641951+00'),
	('ad3de5d1-6c32-4a48-8922-7fe61c9222d1', 'uk', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Виплата, що покриває частину витрат на житло для сімей із дітьми та невисокими доходами.', '2026-08-28 17:30:50.641951+00'),
	('979a64fc-4d40-4022-b56c-f7429652996b', 'uk', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Виплата батькам, чиї діти через інвалідність потребують більше догляду й нагляду, ніж однолітки.', '2026-08-28 17:30:50.641951+00'),
	('b8b0cd26-3fd9-477e-a5e1-aaf4d1a40872', 'uk', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Виплата при безробітті — на основі доходу для членів каси, базова сума для інших.', '2026-08-28 17:30:50.641951+00'),
	('d9cce52d-2e1b-4ca8-9919-17eb2fc5e63f', 'uk', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Близько п''ятдесяти фондів ощадних банків надають допомоги місцевим проєктам у спорті, культурі, освіті та розвитку громади — у зоні діяльності банку.', '2026-08-28 17:30:50.641951+00'),
	('b878dd84-9561-4f37-9530-e0bb539639bd', 'uk', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Чи присвячений проєкт екологічним або кліматичним заходам?', '2026-08-28 17:30:50.641951+00'),
	('11315537-fe1e-43ab-a97b-46314f51d608', 'uk', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Фінансована ЄС проєктна підтримка, яку запитують у вашій місцевій зоні Leader — для об''єднань, компаній і комун, що розвивають сільську місцевість.', '2026-08-28 17:30:50.641951+00'),
	('06e48823-fd7f-4049-bec1-de6af6a9a65b', 'uk', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Фінансована ЄС підтримка для шукачів роботи, які влаштовуються в іншій країні ЄС/ЄЕП: компенсація поїздки на співбесіду, витрат на переїзд і мовного курсу.', '2026-08-28 17:30:50.641951+00'),
	('5ad22d96-a70f-4b9a-8cd9-a2666d33665c', 'uk', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Кошти соціального фонду ЄС на проєкти, що зміцнюють компетенції, перекваліфікацію та інклюзію на ринку праці.', '2026-08-28 17:30:50.641951+00'),
	('a3be5877-688c-4f68-aede-3fbc9358bacf', 'uk', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Підтримка ЄС для групових обмінів молоді 13–30 років, тривалістю 5–21 день без урахування днів у дорозі.', '2026-08-28 17:30:50.641951+00'),
	('5293264c-a5aa-420b-af33-4e807eff77ae', 'uk', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Підтримка ЄС для проєктів співпраці культурних організацій із партнерами в кількох європейських країнах.', '2026-08-28 17:30:50.641951+00'),
	('7e858922-062c-43be-9853-896beb100ec2', 'uk', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Підтримка ЄС для організацій, що приймають або направляють молодих волонтерів 18–30 років.', '2026-08-28 17:30:50.641951+00'),
	('95106b63-5efa-42b2-9fa7-1971939484de', 'uk', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Підтримка ЄС для мобільності персоналу та учнів у школі та освіті дорослих.', '2026-08-28 17:30:50.641951+00'),
	('352767bf-28a1-4d0f-aa91-2786d1aa7d78', 'uk', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Підтримка ЄС із фіксованими сумами для перших європейських проєктів співпраці невеликих організацій.', '2026-08-28 17:30:50.641951+00'),
	('821ace5d-dc3d-496e-93a7-72ad4752ae8d', 'uk', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Фінансування молодих компаній, що розробляють новаторські продукти чи послуги з міжнародним потенціалом.', '2026-08-28 17:30:50.641951+00'),
	('cf0bebc5-550f-4961-a59f-12e746f4ab2c', 'uk', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Чи є ощадний банк (і, отже, фонд ощадного банку) там, де ви ведете діяльність?', '2026-08-28 17:30:50.641951+00'),
	('6e1e3c1e-89b1-42f0-a66c-e4bb2ed124f6', 'uk', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Багаторічні операційні допомоги професійним незалежним колективам танцю, театру та музичного театру.', '2026-08-28 17:30:50.641951+00'),
	('7f3f4eaf-9c8e-414b-aedc-c7e7d256e981', 'uk', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Дослідницькі допомоги в галузях Forte: здоров''я, трудове життя та добробут. Запитують дослідники з докторським ступенем у шведських вишах.', '2026-08-28 17:30:50.641951+00'),
	('7fd50ec6-9732-4ed5-b52e-aa91d43c9da8', 'uk', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Фінансування вільних фундаментальних досліджень у всіх галузях науки.', '2026-08-28 17:30:50.641951+00'),
	('5d18cc15-16d2-489d-99ed-fce1408b7b00', 'uk', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Фінансування досліджень у галузі довкілля, аграрних наук і містобудування.', '2026-08-28 17:30:50.641951+00'),
	('11f9276f-7c1a-431f-bfc3-773d15b54004', 'uk', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Чи думаєте ви про переїзд за кордон (робота, навчання чи повернення на батьківщину)?', '2026-08-28 17:30:50.641951+00'),
	('7b2e8d0c-f1ca-42a2-b423-733ccd4e3718', 'uk', 'Genomförs insatserna av professionella kulturaktörer?', 'Чи проводяться заходи професійними діячами культури?', '2026-08-28 17:30:50.641951+00'),
	('1e2b0640-e8af-4e9f-abf6-ede1171ddcf8', 'uk', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Чи реалізується проєкт у сільській місцевості або невеликому населеному пункті?', '2026-08-28 17:30:50.641951+00'),
	('9dae3e4b-9d81-4f26-b2df-d943f3755ee8', 'uk', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Базовий захист для тих, хто протягом життя мав низький трудовий дохід або не мав його.', '2026-08-28 17:30:50.641951+00'),
	('7ba98481-3a38-4c98-897c-c28e6947d80b', 'uk', 'Går något av dina barn i grundskolan?', 'Чи ходить хтось із ваших дітей до основної школи?', '2026-08-28 17:30:50.641951+00'),
	('4284f4b2-7bd4-4715-b45b-6aceed017e72', 'uk', 'Går något av dina barn på gymnasiet?', 'Чи навчається хтось із ваших дітей у гімназії?', '2026-08-28 17:30:50.641951+00'),
	('d8647095-f468-48c1-9e77-434883cc4cc4', 'uk', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Чи стосується найм людини зі зниженою працездатністю?', '2026-08-28 17:30:50.641951+00'),
	('8f1a8d16-5dcb-4159-bfd1-f5fea1280900', 'uk', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Чи стосується найм людини, яка довго була безробітною або нещодавно приїхала до Швеції?', '2026-08-28 17:30:50.641951+00'),
	('bfb12d97-fd9b-4cfa-abd4-fe8c2f8d84c5', 'uk', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Чи присвячений проєкт збереженню культурної спадщини або забезпеченню доступу до неї?', '2026-08-28 17:30:50.641951+00'),
	('1410a1c6-1c81-4d37-a3eb-5c90a1b0d58b', 'uk', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Чи присвячений проєкт енергетиці, енергоефективності або енергетичним інноваціям?', '2026-08-28 17:30:50.641951+00');
INSERT INTO public.kb_translations VALUES
	('03119db8-1b9f-4ae6-a97d-f9d2c30bbc80', 'uk', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Чи присвячений проєкт здоров''ю, трудовому життю або добробуту?', '2026-08-28 17:30:50.641951+00'),
	('f7e32804-9227-4502-819a-9640421a5045', 'uk', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Чи присвячений проєкт розвитку компетенцій або заходам на ринку праці?', '2026-08-28 17:30:50.641951+00'),
	('f36e1cd9-d3f3-4b1b-92cc-46eb3d4f512e', 'uk', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Чи довга в дитини дорога до школи, небезпечна через рух або складна з інших причин?', '2026-08-28 17:30:50.641951+00'),
	('70fe3c2d-e240-49bd-b108-e65e840a40b8', 'uk', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Чи працювали ви щонайменше 16 годин на тиждень загалом щонайменше 8 років?', '2026-08-28 17:30:50.641951+00'),
	('de66450d-1b12-4d55-bbb2-3b134b351b16', 'uk', 'Har du barn som bor hos dig, helt eller växelvis?', 'Чи живуть із вами діти — постійно або почергово?', '2026-08-28 17:30:50.641951+00'),
	('b5ad6fde-b1a3-4bb5-961b-a93f533c95c9', 'uk', 'Har du barn som bor hos dig?', 'Чи живуть із вами діти?', '2026-08-28 17:30:50.641951+00'),
	('b320df05-4f9d-4167-9506-2c00e66bf2bc', 'uk', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Чи є у вас або вашої дитини інвалідність, яка, як очікується, триватиме щонайменше рік?', '2026-08-28 17:30:50.641951+00'),
	('07e9e7bc-a59e-41f1-8f7f-d2ce25bb916c', 'uk', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Чи має хтось у родині стійку інвалідність, що впливає на житло?', '2026-08-28 17:30:50.641951+00'),
	('f9fe09a2-31df-496e-8841-a4fab44e5185', 'uk', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Чи має хтось із вас або близьких родичів інвалідність або тривалу чи тяжку хворобу?', '2026-08-28 17:30:50.641951+00'),
	('19b9bb3e-7695-4a18-b88e-7ec67fd05ab9', 'uk', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Чи є у вас хвороба або травма, яка зараз знижує вашу працездатність?', '2026-08-28 17:30:50.641951+00'),
	('48347641-931c-46b2-b468-21948306f4ac', 'uk', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Чи бувало вам важко оплатити шкільну екскурсію, класну поїздку або дозвіллєве заняття, у якому має брати участь ваша дитина?', '2026-08-28 17:30:50.641951+00'),
	('42731291-f4c8-4a25-8e18-8ca4301a6f99', 'uk', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Чи важко вам прожити на пенсію та інші доходи?', '2026-08-28 17:30:50.641951+00'),
	('a7205b97-0ed0-4c84-8499-cb490b01ecf6', 'uk', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Чи отримували ви останніми роками посвідку на проживання у Швеції, наприклад, як особа, що потребує захисту, або як член сім''ї?', '2026-08-28 17:30:50.641951+00'),
	('badb362b-61c8-4105-8c78-0aee50738723', 'uk', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Чи маєте ви посвідку на проживання у Швеції як біженець або особа, що потребує захисту (або ви близький родич такої особи)?', '2026-08-28 17:30:50.641951+00'),
	('074c5f9e-0de6-48ee-8c41-9f8651976bb3', 'uk', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Чи досягли ви цільового пенсійного віку (67 років у 2026 році)?', '2026-08-28 17:30:50.641951+00'),
	('d29519a5-8fb5-4f83-9724-48d0d4abcb24', 'uk', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Чи має ваша організація OID (Organisation ID), зареєстрований в Organisation Registration System ЄС?', '2026-08-28 17:30:50.641951+00'),
	('42c78bbc-88d2-4397-83ef-982ca1fbe0a7', 'uk', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Чи спричинила інвалідність додаткові витрати — наприклад, допоміжні засоби, поїздки, особливе харчування або знос?', '2026-08-28 17:30:50.641951+00'),
	('ca6e87be-47b0-4f9a-bb79-3e6354231e29', 'uk', 'Har föreningen antagna stadgar och en vald styrelse?', 'Чи має об''єднання ухвалений статут та обране правління?', '2026-08-28 17:30:50.641951+00'),
	('06a10632-fa3b-4491-9ff0-41c4cabbdb7b', 'uk', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Чи має об''єднання демократичний устрій (статут, річні збори, правління)?', '2026-08-28 17:30:50.641951+00'),
	('be4f83bb-b5df-495f-82cf-53e9d9ae1a2f', 'uk', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Чи веде об''єднання регулярну діяльність для дітей або молоді?', '2026-08-28 17:30:50.641951+00'),
	('f6f06654-2d44-4840-b52a-ced2a11b470c', 'uk', 'Har företaget mellan cirka 2 och 49 anställda?', 'У компанії приблизно від 2 до 49 працівників?', '2026-08-28 17:30:50.641951+00'),
	('3f6d5a68-b10e-42bf-8bf3-7ba8af3cea7c', 'uk', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Чи важко родині покривати витрати на їжу, житло та найнеобхідніше?', '2026-08-28 17:30:50.641951+00'),
	('cfed5adf-d290-4a49-891d-693a85bff11b', 'uk', 'Har lösningen internationell potential?', 'Чи має рішення міжнародний потенціал?', '2026-08-28 17:30:50.641951+00'),
	('b61354e4-fa85-4a1c-a8f1-b89f051f7c6a', 'uk', 'Har ni en partnergrupp i ett annat land?', 'Чи є у вас партнерська група в іншій країні?', '2026-08-28 17:30:50.641951+00'),
	('16745be7-3d89-4c83-ba18-448997ec59d5', 'uk', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Чи є у вас партнерська організація в іншій європейській країні?', '2026-08-28 17:30:50.641951+00'),
	('f55e27a1-5190-4654-a9dd-050cfe68b633', 'uk', 'Har ni partner i minst tre olika europeiska länder?', 'Чи є у вас партнери щонайменше у трьох різних європейських країнах?', '2026-08-28 17:30:50.641951+00'),
	('c116f41d-894f-4b56-8b90-cdaf2586cf97', 'uk', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Чи розташований ваш офіс або основна діяльність у регіоні, де ви подаєте заявку?', '2026-08-28 17:30:50.641951+00'),
	('382a7c08-34cb-400c-97b1-cdb8c1ddbb40', 'uk', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Чи має хтось із ваших дітей інвалідність, через яку дитина потребує більше догляду або нагляду, ніж інші діти того ж віку?', '2026-08-28 17:30:50.641951+00'),
	('d1cbb0d6-bd82-4bdd-b306-0dec6fa7c586', 'uk', 'Har organisationen en demokratisk uppbyggnad?', 'Чи має організація демократичний устрій?', '2026-08-28 17:30:50.641951+00'),
	('451050de-0763-4baa-b340-7b55a17d20c7', 'uk', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Чи має організація Quality Label (знак якості)?', '2026-08-28 17:30:50.641951+00'),
	('9fceb2cc-3ade-4851-bf18-d05307013d34', 'uk', 'Har organisationen ett 90-konto?', 'Чи має організація 90-konto?', '2026-08-28 17:30:50.641951+00'),
	('594c5139-fa84-4408-b198-952a8e654e99', 'uk', 'Har organisationen ett OID (Organisation ID)?', 'Чи має організація OID (Organisation ID)?', '2026-08-28 17:30:50.641951+00'),
	('3a2b26d6-62eb-48db-862e-2a3eb1b002fe', 'uk', 'Har organisationen ett OID?', 'Чи має організація OID?', '2026-08-28 17:30:50.641951+00'),
	('afff3b03-91e1-4938-9951-ff08a2f19c85', 'uk', 'Har organisationen medlemsföreningar i flera län?', 'Чи має організація об''єднання-члени в кількох ленах?', '2026-08-28 17:30:50.641951+00'),
	('d77645ef-b714-420b-a259-3a2bda570e10', 'uk', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Чи має організація впорядковані фінанси та демократичний устрій?', '2026-08-28 17:30:50.641951+00'),
	('b88acec1-8815-4560-8d96-9041fb13f2e8', 'uk', 'Har projektet en partner i ett annat land?', 'Чи має проєкт партнера в іншій країні?', '2026-08-28 17:30:50.641951+00'),
	('8151c8d8-5b3c-48e0-9ea4-3364b4efd74e', 'uk', 'Har projektledaren doktorsexamen?', 'Чи має керівник проєкту докторський ступінь?', '2026-08-28 17:30:50.641951+00'),
	('038344ca-f6ff-4709-8068-bbf685f6b254', 'uk', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Домашня комуна має забезпечувати щоденні поїздки між домом і гімназією, якщо дорога становить щонайменше шість кілометрів (наприклад, проїзний на автобус).', '2026-08-28 17:30:50.641951+00'),
	('68648df8-4e3a-4d6a-9399-59329f02aea9', 'uk', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Чи облаштовуєте ви своє перше власне житло у Швеції?', '2026-08-28 17:30:50.641951+00'),
	('d72fd6ce-b9d1-4eb0-b78c-d846b02a50e0', 'uk', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Чи включає проєкт міжнародну поїздку або обмін?', '2026-08-28 17:30:50.641951+00'),
	('4939a68d-070b-4e58-9cc9-dc737c059b1b', 'uk', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Інвестиційна підтримка компаніям у зонах підтримки — на будівлі, обладнання та навчання.', '2026-08-28 17:30:50.641951+00'),
	('7e3a539a-0078-4656-a786-ff5c85ae0fac', 'uk', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Інвестиційна підтримка заходів, що знижують викиди парникових газів.', '2026-08-28 17:30:50.641951+00'),
	('9444c20c-250b-4d32-91a6-a63915dd5c21', 'uk', 'Kan projektets miljönytta mätas?', 'Чи можна виміряти екологічну користь проєкту?', '2026-08-28 17:30:50.641951+00'),
	('999b6987-eb65-4820-9e78-59f1980bb6ef', 'uk', 'Kan åtgärdens utsläppsminskning beräknas?', 'Чи можна розрахувати зниження викидів від заходу?', '2026-08-28 17:30:50.641951+00'),
	('291688cb-db76-43ad-8be4-3f2f20a4fe5c', 'uk', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Чи може організація нести витрати до виплати підтримки?', '2026-08-28 17:30:50.641951+00'),
	('d813d9bb-1e6c-4050-9371-ca83483c5fa1', 'uk', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Чи буде досвід використано у вашій діяльності у Швеції?', '2026-08-28 17:30:50.641951+00'),
	('b812529f-34e9-46f0-91b3-3026a02fa03b', 'uk', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Чи розпочнеться інвестиція лише після подання заявки?', '2026-08-28 17:30:50.641951+00'),
	('047256e5-8f60-4fba-b970-96ad06502bbf', 'uk', 'Kommer projektet människor i ert närområde till del?', 'Чи приносить проєкт користь людям у вашій місцевості?', '2026-08-28 17:30:50.641951+00'),
	('3ebd031a-9e06-417a-86a8-221b9f14c45e', 'uk', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Крайній економічний захист комуни, коли доходів не вистачає на найнеобхідніше.', '2026-08-28 17:30:50.641951+00'),
	('dc1a6233-aace-4188-8a31-d1d6da62056a', 'uk', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Власна підтримка комун місцевим об''єднанням: допомога за заняття, допомога з приміщеннями, стартова допомога тощо.', '2026-08-28 17:30:50.641951+00');
INSERT INTO public.kb_translations VALUES
	('47649197-e787-4d34-9563-76caaa5d72c4', 'uk', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Безкоштовний шкільний транспорт для учнів основної школи при великій відстані, небезпечній дорозі або інвалідності — право за шкільним законом.', '2026-08-28 17:30:50.641951+00'),
	('b8e402e3-48c3-4148-9410-dfd9c0121fff', 'uk', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Встановлена законом допомога на окуляри або лінзи для дітей та молоді; суми та порядок різняться за регіонами — перевірте рівень свого регіону.', '2026-08-28 17:30:50.641951+00'),
	('37373a62-226a-4633-ac98-ef13a88bd54a', 'uk', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Чи розташований проєкт у місцевості, якої стосується гідро- або вітроенергетика?', '2026-08-28 17:30:50.641951+00'),
	('4fe42e23-a16b-4439-b4e8-793336385924', 'uk', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Чи належить проєкт до довкілля, аграрних наук або містобудування?', '2026-08-28 17:30:50.641951+00'),
	('2fcdb8d0-6a0e-430e-a165-de6a59aa2283', 'uk', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Чи розташоване місце діяльності в зоні підтримки A або B (велика частина Норрланда та внутрішнього Свеаланда)?', '2026-08-28 17:30:50.641951+00'),
	('4d8e463c-daf8-4bed-92a9-f7c80b834ed4', 'uk', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Позика на купівлю найнеобхіднішого для першого дому у Швеції — меблів, домашнього начиння та іншого базового оснащення.', '2026-08-28 17:30:50.641951+00'),
	('f18f4a8e-e5a5-40cf-a8d9-628bde173579', 'uk', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Чи знижує проєкт технологічні викиди промисловості або створює від''ємні викиди?', '2026-08-28 17:30:50.641951+00'),
	('8839ca69-6e18-4970-8c4c-b1181e838e77', 'uk', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Щомісячна допомога на дітей, які живуть у Швеції, від народження до 16 років.', '2026-08-28 17:30:50.641951+00'),
	('9e1c5cba-de7c-4021-bc73-9e134ce57548', 'uk', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket пропонує допомоги організаціям, компаніям, об''єднанням, публічному сектору та приватним особам у сфері довкілля.', '2026-08-28 17:30:50.641951+00'),
	('e96c0fc6-1281-4fbd-bddb-64f537630c87', 'uk', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Чи плануєте ви добровільно назавжди повернутися до країни походження?', '2026-08-28 17:30:50.641951+00'),
	('6f58c7d6-2452-4310-b824-1833035ab493', 'uk', 'Planerar du att starta eget företag?', 'Чи плануєте ви відкрити власну справу?', '2026-08-28 17:30:50.641951+00'),
	('d8b5cf63-f723-4b64-a8d4-baf58fb123a7', 'uk', 'Planerar du att studera utomlands?', 'Чи плануєте ви навчатися за кордоном?', '2026-08-28 17:30:50.641951+00'),
	('20813dbe-e9ff-4191-811e-ba0a9317e845', 'uk', 'Är projektet ett konst- eller kulturprojekt?', 'Це мистецький або культурний проєкт?', '2026-08-28 17:30:50.646065+00'),
	('5030b8f0-5721-4844-9ed8-aa67f2435cd8', 'uk', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Чи плануєте ви навчання, що зміцнить вашу позицію на ринку праці?', '2026-08-28 17:30:50.641951+00'),
	('4fb094ce-9f89-4995-8724-e57d72f1b898', 'uk', 'Planerar ni att anställa?', 'Чи плануєте ви наймати працівників?', '2026-08-28 17:30:50.641951+00'),
	('cef2f032-c688-4361-a8e0-ebdc3a74f62c', 'uk', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Чи плануєте ви подаватися на програму ЄС (наприклад, Horisont Europa)?', '2026-08-28 17:30:50.641951+00'),
	('c15f8f16-058f-4978-816c-76bec36d1bcb', 'uk', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Підтримка виробництва та розробки короткометражних і документальних фільмів.', '2026-08-28 17:30:50.641951+00'),
	('c28fc4c4-a1f5-4c7f-a1a9-63cc16e745dd', 'uk', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Проєктні допомоги вільній музичній сцені на концерти, виробництво та розвиток.', '2026-08-28 17:30:50.641951+00'),
	('2df8f04c-2146-4524-b0c0-2a633c5192bf', 'uk', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Проєктні допомоги неприбутковим організаціям, що працюють із дітьми та молоддю і для них.', '2026-08-28 17:30:50.641951+00'),
	('d75918ac-9ef4-4c2d-bb0b-b3bfb9ddcd17', 'uk', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Чи випробовує проєкт нові мистецькі вирази, методи або співпраці?', '2026-08-28 17:30:50.641951+00'),
	('21645093-ef27-47ed-a865-13873554b575', 'uk', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Чи триває обмін 5–21 день (без урахування днів у дорозі)?', '2026-08-28 17:30:50.641951+00'),
	('2eb9fa12-dec6-441d-92a9-877c204c1b19', 'uk', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Власна проєктна та операційна підтримка регіонів культурного життя, поряд із національними допомогами Kulturrådet.', '2026-08-28 17:30:50.641951+00'),
	('f5dc3d6a-3354-4e80-8393-52c9a6227657', 'uk', 'Riktar sig projektet till barn eller unga?', 'Чи адресований проєкт дітям або молоді?', '2026-08-28 17:30:50.641951+00'),
	('a5803c36-6e9b-4de7-ad0e-18c582a907a6', 'uk', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Чи адресований проєкт дітям, молоді, літнім людям або людям з інвалідністю?', '2026-08-28 17:30:50.641951+00'),
	('35f6af2c-d7d0-474f-9fa1-40c2edd04de0', 'uk', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Чи адресована діяльність дітям і молоді (7–25 років)?', '2026-08-28 17:30:50.641951+00'),
	('87aeaab8-2b25-4d42-ad47-ecfa73edce03', 'uk', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Чи бракує вам заощаджень або активів, які могли б покрити витрати?', '2026-08-28 17:30:50.641951+00'),
	('f318505e-400c-4aa3-8958-d678b0833f79', 'uk', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Чи співпрацюєте ви з партнерами щонайменше у двох інших північних країнах?', '2026-08-28 17:30:50.641951+00'),
	('4f9dde0a-0093-4cb4-8244-20731e8e5c01', 'uk', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Чи залучатимете ви зовнішню експертизу для заходу розвитку?', '2026-08-28 17:30:50.641951+00'),
	('ad07503b-779c-4390-a041-35aca2b5e654', 'uk', 'Sker mobiliteten till ett annat europeiskt land?', 'Чи спрямована мобільність до іншої європейської країни?', '2026-08-28 17:30:50.641951+00'),
	('94adc692-e412-4541-b9f9-2ae7a6ea3375', 'uk', 'Startar du eller tar du över företaget för första gången?', 'Чи відкриваєте ви підприємство або берете його на себе вперше?', '2026-08-28 17:30:50.641951+00'),
	('bb312a53-ef62-4124-aaad-c62d016d5f66', 'uk', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Стартова підтримка для тих, кому 40 років або менше, хто відкриває сільськогосподарське підприємство або бере його на себе.', '2026-08-28 17:30:50.641951+00'),
	('3720cdb2-9aed-4d60-9d15-5c003301aaaa', 'uk', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Стипендія, що дає професійним митцям змогу зосередитися на мистецькій роботі.', '2026-08-28 17:30:50.641951+00'),
	('2a0c9748-59ee-4197-b6da-ecd040608163', 'uk', 'Studerar du, eller planerar du att börja studera?', 'Чи навчаєтеся ви або плануєте почати навчання?', '2026-08-28 17:30:50.641951+00'),
	('e44f5d0d-ed36-4fee-8c78-28ec1a5cd1af', 'uk', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Навчальна підтримка для працюючих дорослих, які хочуть здобути освіту для зміцнення позиції на ринку праці.', '2026-08-28 17:30:50.641951+00'),
	('5ed9ae22-7a06-42df-b5e8-afaddf3e410f', 'uk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Підтримка інвестицій, що підвищують конкурентоспроможність або знижують вплив на довкілля в сільськогосподарських підприємствах.', '2026-08-28 17:30:50.641951+00'),
	('4f145669-c9c9-4aac-892d-05d170412eda', 'uk', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Підтримка, коли дитина живе з вами, а другий із батьків не платить утримання.', '2026-08-28 17:30:50.641951+00'),
	('05741dfb-a6e4-4df7-9390-0d70a49e5873', 'uk', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Підтримка проєктів неприбуткових організацій для людей, довкілля та кращого світу.', '2026-08-28 17:30:50.641951+00'),
	('e52aafbb-3b32-4e7b-8946-795f50b8fab1', 'uk', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Підтримка переходу промисловості до нульових викидів парникових газів.', '2026-08-28 17:30:50.641951+00'),
	('a0bd1728-ffeb-4fb6-9866-e261ed75060b', 'uk', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Підтримка мистецьких і культурних проєктів із північним виміром та транскордонною співпрацею.', '2026-08-28 17:30:50.641951+00'),
	('896f9293-e1e5-468e-835c-dcedf2479e3f', 'uk', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Підтримка новаторських культурних проєктів, що випробовують нові мистецькі вирази, методи або співпраці.', '2026-08-28 17:30:50.641951+00'),
	('5f7f8799-135f-4e48-a95c-be3591a0e8cd', 'uk', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Підтримка новаторських проєктів для дітей, молоді, літніх людей і людей з інвалідністю.', '2026-08-28 17:30:50.641951+00'),
	('768ec839-8d36-4fca-9db3-d8f838024c48', 'uk', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Підтримка проєктів співпраці у вільній музичній сцені.', '2026-08-28 17:30:50.641951+00'),
	('22661fad-6bb6-44d1-9449-f0c9c3fbfd63', 'uk', 'Är projektet ett kulturprojekt?', 'Це культурний проєкт?', '2026-08-28 17:30:50.646065+00'),
	('23a7efd9-5d68-47d6-bb99-7190fbed31b2', 'uk', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Підтримка проєктів співпраці в культурі та медіа, що зміцнюють демократію та свободу слова на міжнародному рівні.', '2026-08-28 17:30:50.641951+00'),
	('5b428891-ab2e-4b28-a671-a22ad4e38dd5', 'uk', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Чи спрямований проєкт на зміцнення демократії, рівності або свободи слова?', '2026-08-28 17:30:50.641951+00'),
	('2f5f3bf0-62ce-4b92-875c-4536f77b79a2', 'uk', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Чи шукаєте ви роботу або отримали пропозицію роботи в іншій країні ЄС чи ЄЕП?', '2026-08-28 17:30:50.641951+00'),
	('7325d525-4af4-4e6d-bcfe-ac52e42b6483', 'uk', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Стеля того, що ви платите як пацієнтські збори за дванадцять місяців — далі frikort (безкоштовна картка).', '2026-08-28 17:30:50.641951+00'),
	('0c4f32c5-b631-4fad-8ee6-658a2dccc898', 'uk', 'Tar du ut hel allmän pension?', 'Чи отримуєте ви повну державну пенсію?', '2026-08-28 17:30:50.641951+00'),
	('59d0bb2d-2ed1-4064-af2e-721e22de6060', 'uk', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Надбавка, що покриває частину витрат на житло для тих, хто має пенсію та низькі доходи.', '2026-08-28 17:30:50.641951+00'),
	('e391e8f7-dca4-4c02-b3d5-77f2f8536f7c', 'uk', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Щорічна організаційна допомога національним дитячим і молодіжним організаціям.', '2026-08-28 17:30:50.641951+00');
INSERT INTO public.kb_translations VALUES
	('6c2678fe-4451-4459-b2e3-eb367221b700', 'uk', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Щорічна сума, що вираховується безпосередньо у стоматолога або зубного гігієніста.', '2026-08-28 17:30:50.641951+00'),
	('376a77ce-59f7-4f3f-9244-bb81a07c2367', 'uk', 'Är bolaget yngre än cirka 5 år?', 'Компанії менше ніж приблизно 5 років?', '2026-08-28 17:30:50.641951+00'),
	('2f00c07a-f4e3-4e9e-a730-3f2ac93e023a', 'uk', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Учасникам обміну від 13 до 30 років?', '2026-08-28 17:30:50.641951+00'),
	('5512c427-31de-44ed-9552-05e28271b5e1', 'uk', 'Är det här ert första EU-projekt?', 'Це ваш перший проєкт ЄС?', '2026-08-28 17:30:50.641951+00'),
	('ebf3068d-f075-4c9a-943a-489e3b5a32b4', 'uk', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Чи дуже важко вам (або вашій дитині) пересуватися самостійно чи їздити автобусом і потягом?', '2026-08-28 17:30:50.641951+00'),
	('9e55184a-b56e-4a53-8588-2a56fe489167', 'uk', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Ваш дохід нижчий за приблизно 25 000 крон на місяць до податків?', '2026-08-28 17:30:50.641951+00'),
	('30797bdd-8d5c-4039-8349-86af0308af5a', 'uk', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Ваша остання закінчена освіта — основна школа або незакінчена гімназія?', '2026-08-28 17:30:50.641951+00'),
	('309b113e-0f0a-4536-a123-536d1c665f3c', 'uk', 'Är du 40 år eller yngre?', 'Вам 40 років або менше?', '2026-08-28 17:30:50.641951+00'),
	('c269ba4c-6277-48b8-81f1-2ddc5168ff17', 'uk', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Чи зареєстровані ви як шукач роботи в Arbetsförmedlingen?', '2026-08-28 17:30:50.641951+00'),
	('44557878-1da3-42a3-8ec1-91385168ea83', 'uk', 'Är du mellan 18 och 28 år?', 'Вам від 18 до 28 років?', '2026-08-28 17:30:50.641951+00'),
	('945b2a82-77fe-4b5c-a208-989f39fe4328', 'uk', 'Är du mellan 19 och 29 år?', 'Вам від 19 до 29 років?', '2026-08-28 17:30:50.641951+00'),
	('1e5c59dc-79ee-40c0-b41d-024caaeef33e', 'uk', 'Är du mellan 25 och 60 år?', 'Вам від 25 до 60 років?', '2026-08-28 17:30:50.641951+00'),
	('a9664f54-59db-4bd0-a34a-b9b5dd18de42', 'uk', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Чи працюєте ви професійно у сфері культури (наприклад, танець, музика, сценічне мистецтво)?', '2026-08-28 17:30:50.641951+00'),
	('ee04aa7e-b9d7-40cc-b848-11481db93f20', 'uk', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Ви професійний митець (не аматор і не на базовому навчанні)?', '2026-08-28 17:30:50.641951+00'),
	('abe0203d-3dc8-4cbe-9aed-0cef4cc27a4e', 'uk', 'Är du yrkesverksam konstnär?', 'Ви професійний митець?', '2026-08-28 17:30:50.641951+00'),
	('7b1f8edd-38b1-4aa5-983e-7608f379ac0b', 'uk', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Чи суттєво новаторське ваше рішення порівняно з тим, що вже існує?', '2026-08-28 17:30:50.646065+00'),
	('11dd4f6e-c423-40ec-a015-f067af4dcf5d', 'uk', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Чи входить клуб до спеціалізованої спортивної федерації у складі Riksidrottsförbundet?', '2026-08-28 17:30:50.646065+00'),
	('2f67c1fc-1b1f-4d8f-82ad-a07c8d15818b', 'uk', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Чи низькі доходи родини відносно витрат на житло?', '2026-08-28 17:30:50.646065+00'),
	('ae6bd372-893c-4566-b151-f4759366f097', 'uk', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Сукупний дохід родини нижчий за приблизно 25 000 крон на місяць до податків?', '2026-08-28 17:30:50.646065+00'),
	('a4444d7b-e72a-4328-80d4-f1d648bc61e7', 'uk', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Чи є захід окремим проєктом (а не звичайною діяльністю)?', '2026-08-28 17:30:50.646065+00'),
	('a65d86a7-443c-4758-baa9-84254e5e3654', 'uk', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Чи відкрите приміщення для всіх — не лише для власних членів?', '2026-08-28 17:30:50.646065+00'),
	('3a560629-b809-4d7f-a4e8-bf2b0ae25c09', 'uk', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Щонайменше 60 % членів віком від 6 до 25 років?', '2026-08-28 17:30:50.646065+00'),
	('9f95f453-4ed6-4356-8c12-e060d1cf18b2', 'uk', 'Är minst 60 % av medlemmarna under 26 år?', 'Щонайменше 60 % членів молодші за 26 років?', '2026-08-28 17:30:50.646065+00'),
	('a5f98d5f-1386-4420-b3cc-64a763f9e10e', 'uk', 'Är målgruppen delaktig i planering och genomförande?', 'Чи бере цільова група участь у плануванні та реалізації?', '2026-08-28 17:30:50.646065+00'),
	('6b8f1d46-b7b9-4f22-ad34-e945df05e349', 'uk', 'Är ni ett förlag med professionell utgivning?', 'Ви видавництво з професійним книговиданням?', '2026-08-28 17:30:50.646065+00'),
	('bd81d4c9-a6e8-495c-af93-5d3109c4712d', 'uk', 'Är ni huvudman för förskoleklass eller grundskola?', 'Чи є ви відповідальною організацією дошкільного класу або основної школи?', '2026-08-28 17:30:50.646065+00'),
	('d86156d5-a67f-4c06-a805-43979f6a539f', 'uk', 'Är organisationen registrerad i EU:s deltagarregister?', 'Чи зареєстрована організація в реєстрі учасників ЄС?', '2026-08-28 17:30:50.646065+00'),
	('030a7c06-a6e6-45c4-a060-652ff7915fa0', 'uk', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Це кінопроєкт (короткометражний або документальний фільм)?', '2026-08-28 17:30:50.646065+00'),
	('5c0b87cb-11cd-479a-a531-789368391551', 'uk', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Чи новаторський проєкт — те, чого ви ще не робите у звичайній діяльності?', '2026-08-28 17:30:50.646065+00'),
	('0e5b0f99-f52f-4316-bdd6-7438f4258f47', 'uk', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Чи приносить проєкт користь місцевості загалом (а не окремим особам)?', '2026-08-28 17:30:50.646065+00'),
	('55650a06-6b89-4719-8bb1-a6b884e689ed', 'uk', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Дорога між домом і гімназією становить щонайменше шість кілометрів?', '2026-08-28 17:30:50.646065+00'),
	('961eb5d8-b475-48fd-aba0-67102370cd1b', 'uk', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Чи професійна це діяльність (не аматорська)?', '2026-08-28 17:30:50.646065+00'),
	('20916bbb-0bff-4430-b1a2-45975823d20f', 'uk', 'Är verksamheten professionell?', 'Чи професійна це діяльність?', '2026-08-28 17:30:50.646065+00'),
	('11a7a0d8-bc00-45a1-8c10-cffe94a518b0', 'uk', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Чи належить діяльність до сценічного мистецтва (танець, театр, музичний театр)?', '2026-08-28 17:30:50.646065+00'),
	('d66903c5-94fb-48de-99a1-a78330445384', 'uk', 'Är volontärerna mellan 18 och 30 år?', 'Волонтерам від 18 до 30 років?', '2026-08-28 17:30:50.646065+00'),
	('05bb7b1e-fdd9-49d8-bf05-598d26632aef', 'so', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Taageero hawleed loogu talagalay naadiyada isboortiga ee u qabta carruurta iyo dhallinyarada 7–25 jir hawlo uu hoggaamiyo tababare.', '2026-08-28 17:30:50.650239+00'),
	('849edeaf-b418-4e2b-b019-c76b4eb7c7a0', 'so', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Kordhin toos ah oo lagu daro gunnada carruurta (barnbidrag) laga bilaabo ilmaha labaad.', '2026-08-28 17:30:50.650239+00'),
	('8ecc1583-6ffa-4614-bc9a-f8419250c402', 'so', 'Avser ansökan en fysisk investering?', 'Codsigu ma khuseeyaa maalgelin muuqata (dhisme ama qalab)?', '2026-08-28 17:30:50.650239+00'),
	('b68fbd0e-d59f-4673-b5f0-9373bfab8df3', 'so', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Codsigu ma khuseeyaa safar ama isweydaarsi caalami ah?', '2026-08-28 17:30:50.650239+00'),
	('f13f93ce-4159-4ce8-9b4c-a73195fd1ca4', 'so', 'Avser ansökan en investering i byggnader eller maskiner?', 'Codsigu ma khuseeyaa maalgelin lagu sameynayo dhismayaal ama mashiinno?', '2026-08-28 17:30:50.650239+00'),
	('0504dd18-d6d4-419e-ac5b-65523d66c9cd', 'so', 'Avser ansökan en redan utgiven titel?', 'Codsigu ma khuseeyaa buug horeba loo daabacay?', '2026-08-28 17:30:50.650239+00'),
	('ce4afa37-9a23-48a3-b4bd-b998825dde55', 'so', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Codsigu ma khuseeyaa ganacsi beeraley ah, beero-korin ama xoolo-dhaqato deero-woqooyi?', '2026-08-28 17:30:50.650239+00'),
	('b801ea00-ac14-462b-bc5b-36fefd92b254', 'so', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Codsigu ma khuseeyaa buugaag loo iibinayo maktabadaha dadweynaha ama kuwa dugsiyada?', '2026-08-28 17:30:50.650239+00'),
	('6f766929-237b-4582-bbcd-7fea9daed81e', 'so', 'Avser investeringen jordbruksverksamhet?', 'Maalgelintu ma khuseysaa hawl beeraley ah?', '2026-08-28 17:30:50.650239+00'),
	('d2487d07-3c38-4142-8446-141900417b83', 'so', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Mashruucu ma yahay dhisid, iibsi ama dayactir goob?', '2026-08-28 17:30:50.650239+00'),
	('3a59b242-272a-46c7-80d1-f0f322fdfce5', 'so', 'Avser projektet naturvård eller friluftsliv?', 'Mashruucu ma khuseeyaa ilaalinta dabeecadda ama madadaalada banaanka?', '2026-08-28 17:30:50.650239+00'),
	('f211d20f-2e9a-47c9-8793-99650e4a59bd', 'so', 'Avser projektet skola eller vuxenutbildning?', 'Mashruucu ma khuseeyaa dugsi ama waxbarashada dadka waaweyn?', '2026-08-28 17:30:50.650239+00'),
	('b5a29312-4f39-456b-a323-ff49f2df4af9', 'so', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Ma ka fadhiisanaysaa shaqada si aad u daryeesho ama ugu dhowaato qof kuu dhow oo aad u xanuunsan, oo cudurkiisu nolosha khatar ku yahay?', '2026-08-28 17:30:50.650239+00'),
	('311339d0-06b7-47ad-a7c3-f4ce67b2d130', 'so', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Ururku ma ku leeyahay hawlo joogto ah degmada?', '2026-08-28 17:30:50.650239+00'),
	('a6705ac6-e4b3-4248-8439-31d9f5b50e99', 'so', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Ma qiimeynaysaa in awooddaada shaqo ay hoos u dhacday ugu yaraan hal sano cudur ama naafanimo dartood?', '2026-08-28 17:30:50.650239+00');
INSERT INTO public.kb_translations VALUES
	('9d91fe03-e8dc-45b9-9866-552d867bc612', 'so', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Taageero baahi lagu qiimeeyo oo loogu talagalay qofka haysta hawlgab yar ama aan haysan, una baahan caawimo si uu u gaadho heer nololeed macquul ah.', '2026-08-28 17:30:50.650239+00'),
	('eddda4ea-bf17-4a37-9f82-b4771ad0b246', 'so', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Ilmuhu ma u baahan yahay inuu dego magaalada uu wax ku barto (hoy) sababtoo ah waddadu aad bay u dheer tahay?', '2026-08-28 17:30:50.650239+00'),
	('b3bc5c50-83cb-4616-8990-bd5e150a3efa', 'so', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Gurigu ma u baahan yahay in la habeeyo (tus. jaranjaro-fudud, albaab-fure, musqul)?', '2026-08-28 17:30:50.650239+00'),
	('26a16b1b-b791-4054-aa5f-835a1c385fc3', 'so', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Mid ka mid ah carruurtaada 8–19 jirka ah ma u baahan yahay muraayado indho ama lenso?', '2026-08-28 17:30:50.650239+00'),
	('7487db3b-8a96-4144-89e7-2badeddbd5a3', 'so', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Waalidka kale miyuusan waxba bixin, mise wuxuu bixiyaa wax ka yar masruufka buuxa?', '2026-08-28 17:30:50.650239+00'),
	('bbf592f1-39f0-49cd-b6f9-039561cd6a2f', 'so', 'Betalar du hyra eller andra boendekostnader?', 'Ma bixisaa kiro ama kharashyo kale oo guri?', '2026-08-28 17:30:50.650239+00'),
	('5578c5b1-4fde-4641-bf59-517fc6516470', 'so', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Gunno lagu habeeyo guriga marka naafanimo jirto — tus. jaranjarooyin fudud, albaab-fureyaal ama habeyn musqusha.', '2026-08-28 17:30:50.650239+00'),
	('a4849990-9cc2-4721-abea-74280a0515e4', 'so', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Gunnooyin lagu dhiso, lagu iibsado ama lagu dayactiro hoolal shir oo dadweyne.', '2026-08-28 17:30:50.650239+00'),
	('192241e7-8f70-4c62-afda-20283ff1c18f', 'so', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Gunno lagu iibsado ama lagu habeeyo baabuur marka naafanimo joogto ahi ay aad u adkeyso dhaqdhaqaaqa ama safarka gaadiidka dadweynaha.', '2026-08-28 17:30:50.650239+00'),
	('92309777-6be9-4d42-be7c-3bd9cacd199e', 'so', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Gunnooyin safarro iyo isweydaarsiyo caalami ah oo loogu talagalay xirfadlayaasha dhinaca dhaqanka.', '2026-08-28 17:30:50.650239+00'),
	('42e7184b-2fdf-44a1-b676-04d7657bac6e', 'so', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Gunnooyin isweydaarsiyada caalamiga ah, safarrada iyo joogitaannada shaqo ee fannaaniinta xirfadleyda ah.', '2026-08-28 17:30:50.650239+00'),
	('fb6ec05e-a4c9-42eb-ad1a-154b4ce1d715', 'so', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Gunno iyo deyn ikhtiyaari ah oo loogu talagalay waxbarashada heerka dugsiga sare ama ka dambeeya.', '2026-08-28 17:30:50.650239+00'),
	('e5f91ab6-4d19-44f9-9f0e-616e9bbc7b76', 'so', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Gunnooyin iyo deymo waxbarasho dibadda ah, oo leh deymo dheeraad ah tus. lacagta waxbarashada iyo safarrada.', '2026-08-28 17:30:50.650239+00'),
	('42b34580-5a5c-480f-8a33-f36c9e8b1fb4', 'so', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Gunno ka caawisa jihooyinka Swedishka inay diyaariyaan codsiyada barnaamijyada EU sida Horisont Europa.', '2026-08-28 17:30:50.650239+00'),
	('f8e2619d-b091-46e3-9a97-e804425adb90', 'so', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Gunno loo fidiyo loo-shaqeeyayaasha shaqaaleysiiya dadka awoodda shaqo ee hooseysa.', '2026-08-28 17:30:50.650239+00'),
	('5955f1b4-98bd-41e8-9439-4771fe4ededa', 'so', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Gunno hoy iyo safarro guri-ku-noqosho ah marka arday dugsi sare uu qasab ku noqdo inuu dego magaalada waxbarashada waddo dheer awgeed.', '2026-08-28 17:30:50.650239+00'),
	('185e5773-8d33-4a00-8331-8a5400616be9', 'so', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Gunnooyin shaqada ururrada aan faa''iido doonka ahayn ee ilaalinta, isticmaalka iyo horumarinta hidaha dhaqanka.', '2026-08-28 17:30:50.650239+00'),
	('6875aef4-5c97-4bcf-a676-0a301b499b2b', 'so', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Gunnooyin mashaariicda degmooyinka iyo kuwa maxalliga ah ee ilaalinta dabeecadda, oo ay ku jiraan dhulalka qoyan iyo madadaalada banaanka.', '2026-08-28 17:30:50.650239+00'),
	('71e59d23-207c-4a85-9f2d-a6bc597f1363', 'so', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Gunnooyin degmooyinka loogu talagalay iibsiga buugaagta maktabadaha dadweynaha iyo kuwa dugsiyada.', '2026-08-28 17:30:50.650239+00'),
	('a6376bcd-2711-497b-b4ce-2bd2c3ae2db6', 'so', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Gunnooyin masuuliyiinta dugsiyada si ardayda dugsiga hoose-dhexe ay ula kulmaan dhaqan xirfadle.', '2026-08-28 17:30:50.650239+00'),
	('333db0a0-4be0-46e0-8408-5fd6584fa517', 'so', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Gunno waxa ilmahaagu u baahan yahay laakiin dhaqaalaha qoysku uusan gaadhin: hawlo firaaqo, dhar, socdaallo dugsi, muraayado indho, hawlo fasax iyo wax kale.', '2026-08-28 17:30:50.650239+00'),
	('efda1bd0-60f9-4137-aae1-9db467477ecf', 'so', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Gunnooyin ka yimaadda sanduuqyada sida Världens Barn, Musikhjälpen iyo Victoriafonden — waxaa codsada ururrada Swedishka ee aan faa''iido doonka ahayn ee haysta 90-konto.', '2026-08-28 17:30:50.650239+00'),
	('a9b4138c-761f-4cb7-b338-a4c56166196d', 'so', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Gunnooyin ka yimaadda lacagaha korontada biyaha iyo dabaysha oo loogu talagalay mashaariic horumarisa deegaanka.', '2026-08-28 17:30:50.650239+00'),
	('f438a97a-60d6-49d1-9c63-8c347af073ea', 'so', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Gunno aan lahayn qayb deyn ah oo loogu talagalay shaqo-la''aanta 25–60 jirka ah ee waxbarashadoodu gaaban tahay, una baahan inay wax ku bartaan heerka dugsiga hoose-dhexe ama sare.', '2026-08-28 17:30:50.650239+00'),
	('0aa7c81b-b0e5-4444-b6fa-de5ac1059a49', 'so', 'Bidrar projektet till energiomställningen?', 'Mashruucu ma gacan ka geystaa isbeddelka tamarta?', '2026-08-28 17:30:50.650239+00'),
	('71d405e2-b756-4507-a5c8-b293fd8ee2b0', 'so', 'Bor du och barnets andra förälder på skilda håll?', 'Adiga iyo waalidka kale ee ilmuhu ma kala nooshihiin?', '2026-08-28 17:30:50.650239+00'),
	('c6d2486e-39c4-4b67-bb63-16afde619a9c', 'so', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Jeegag shirkado yaryar si ay u keensadaan aqoon dibadeed oo caalamiyeyn ama dhijitaaleyn ah.', '2026-08-28 17:30:50.650239+00'),
	('ae1c47ba-7f9d-461a-87ca-e87672583661', 'so', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Ma ka qaybqaadataa barnaamij ka socda Arbetsförmedlingen (tus. jobb- och utvecklingsgarantin)?', '2026-08-28 17:30:50.650239+00'),
	('62b244c8-7229-4fd2-b961-67a74602f0b6', 'so', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Taageero dib-u-dhac ah oo loo fidiyo daabacayaasha soo saara suugaan tayo leh.', '2026-08-28 17:30:50.650239+00'),
	('e8f47a49-becb-4257-bb08-f1f8e4c0241a', 'so', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Taageero dhaqaale oo loogu talagalay qofka haysta sharci degganaansho oo magangelyo la xiriira, oo si mutadawacnimo ah u doonaya inuu si joogto ah ugu laabto dalkiisii asalka ahaa.', '2026-08-28 17:30:50.650239+00'),
	('6e1e06fe-c309-43dc-bdff-bf81e8d64284', 'so', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Taageero dhaqaale oo loo fidiyo loo-shaqeeyayaasha shaqaaleysiiya qof muddo dheer ka maqnaa nolosha shaqada.', '2026-08-28 17:30:50.650239+00'),
	('3541c29f-1c26-4b8c-8440-2169469a6cf9', 'so', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Taageero dhaqaale inta lagu jiro bilowga, oo loogu talagalay shaqo-doonka bilaabaya ganacsigooda.', '2026-08-28 17:30:50.650239+00'),
	('662a9fe8-4d5c-4280-9f10-af6d339ea6d8', 'so', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten waxay si joogto ah u furtaa baaqyo cilmi-baarista tamarta, hal-abuurka iyo hufnaanta tamarta.', '2026-08-28 17:30:50.650239+00'),
	('61dcf154-d3cb-4f2a-8394-8ad656406f99', 'so', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Magdhow ka-maqnaanshaha shaqada ama waxbarashada si loo daryeelo ilmo.', '2026-08-28 17:30:50.650239+00'),
	('7fe7b944-ee0b-4473-b1aa-0eee03445344', 'so', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Magdhow qofka ku cusub Sweden oo ka qaybqaata barnaamijka dejinta ee Arbetsförmedlingen; waxaa bixisa Försäkringskassan.', '2026-08-28 17:30:50.650239+00'),
	('03dc22da-f7e9-4614-b6b5-d9dd8a124084', 'so', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Magdhow daboolaya qayb ka mid ah kharashka guriga ee dhallinyarada aan carruurta lahayn ee dakhligoodu hooseeyo.', '2026-08-28 17:30:50.650239+00'),
	('c2f6369b-9b24-4623-a98b-e4b0116344da', 'so', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Magdhow kharashyada dheeraadka ah ee naafanimo joogto ahi keento — dadka waaweyn, ama waalidiinta carruurta naafada ah.', '2026-08-28 17:30:50.650239+00'),
	('19106b10-bbd9-4d82-bfbd-106d6cbadf67', 'so', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Magdhow dhallinyarada (19–29 jir) aan awoodin inay waqti-buuxa u shaqeeyaan ugu yaraan hal sano cudur ama naafanimo dartood.', '2026-08-28 17:30:50.650239+00'),
	('06270258-79ee-4a38-b45c-a94b0e5a6760', 'so', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Magdhow marka awoodda shaqo si joogto ah hoos ugu dhacday — wixii hore loogu yiqiin förtidspension (hawlgab hore).', '2026-08-28 17:30:50.650239+00'),
	('0b346aa0-46b4-4004-8940-5a8418381710', 'so', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Magdhow marka aad shaqada uga fadhiisato inaad u dhowaato qof kuu dhow oo aad u xanuunsan.', '2026-08-28 17:30:50.650239+00'),
	('49b22b66-202a-43cd-85c1-5bd8e8223e0f', 'so', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Magdhow marka aad ka qaybqaadato barnaamij suuqa shaqada ee Arbetsförmedlingen.', '2026-08-28 17:30:50.650239+00'),
	('e6d579c3-c9a6-4466-abd9-f23249013964', 'so', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Magdhow marka aadan sidii caadiga ahayd u shaqeyn karin cudur dartiis.', '2026-08-28 17:30:50.650239+00'),
	('270b66ba-34a8-465a-961f-1d8871dcbdfb', 'so', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Magdhow marka aad shaqada ka joogto guriga si aad u daryeesho ilmo jirran.', '2026-08-28 17:30:50.650239+00'),
	('c26e078e-736e-403e-8d70-e6e4eb4c229d', 'so', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Magdhow daboolaya qayb ka mid ah kharashka guriga ee qoysaska carruurta leh ee dakhligoodu hooseeyo.', '2026-08-28 17:30:50.650239+00'),
	('026b31a1-78ac-4793-a321-33a0b48af5aa', 'so', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Magdhow waalidiinta ay carruurtoodu naafanimo dartood ugu baahan yihiin daryeel iyo ilaalin ka badan carruurta da''dooda ah.', '2026-08-28 17:30:50.650239+00'),
	('d8db1b39-1993-4a1e-8df5-3f62fe9f5358', 'so', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Magdhow xilliga shaqo-la''aanta — ku salaysan dakhliga xubnaha, qadar aasaasi ah kuwa kale.', '2026-08-28 17:30:50.650239+00'),
	('849175da-b858-450d-a1fd-c62c45bb7959', 'so', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Ilaa konton sanduuq oo bangiyada kaydka ah ayaa gunnooyin siiya mashaariic maxalli ah oo isboorti, dhaqan, waxbarasho iyo horumar bulsho — gudaha aagga hawlgalka bangiga.', '2026-08-28 17:30:50.650239+00'),
	('9c368fcb-0cfe-4766-9ff0-89e7758d9e6e', 'so', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Taageero mashruuc oo EU maalgeliso oo laga codsado aaggaaga Leader ee maxalliga ah — ururrada, shirkadaha iyo degmooyinka horumarinaya miyiga.', '2026-08-28 17:30:50.650239+00'),
	('40d8ede8-13a8-4f5d-937c-f3b42ef561f5', 'so', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Taageero EU maalgeliso oo loogu talagalay shaqo-doonka qaadanaya shaqo dal kale oo EU/EES ah: magdhow safarka wareysiga, kharashka guuritaanka iyo koorso luqadeed.', '2026-08-28 17:30:50.650239+00'),
	('17353da6-4354-41e8-bf35-461808bbe096', 'so', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Lacago ka yimaadda sanduuqa bulshada ee EU oo loogu talagalay mashaariic xoojiya aqoonta, u-gudubka iyo ka-mid-noqoshada suuqa shaqada.', '2026-08-28 17:30:50.650239+00');
INSERT INTO public.kb_translations VALUES
	('1a999093-f0cf-449f-bd6f-4c5dac1ff63e', 'so', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Taageero EU oo loogu talagalay isweydaarsiyo kooxeed dhallinyarada 13–30 jir, 5–21 maalmood oo aan lagu darin maalmaha safarka.', '2026-08-28 17:30:50.650239+00'),
	('84101cfb-cf18-4e80-b2c6-cfd3e9720dd9', 'so', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Taageero EU oo loogu talagalay mashaariicda iskaashiga ururrada dhaqanka ee la leh shuraakada dhowr dal oo Yurub ah.', '2026-08-28 17:30:50.650239+00'),
	('7a22250d-39d8-4ea4-bd51-ac4550e6ee38', 'so', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Taageero EU oo loogu talagalay ururrada soo dhoweeya ama dira mutadawiciin dhallinyaro ah oo 18–30 jir ah.', '2026-08-28 17:30:50.650239+00'),
	('d93539b7-932e-4546-bdee-893eee0642e6', 'so', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Taageero EU oo loogu talagalay dhaqdhaqaaqa shaqaalaha iyo ardayda dugsiga iyo waxbarashada dadka waaweyn.', '2026-08-28 17:30:50.650239+00'),
	('5bbd218b-d799-41e2-9d6a-fdd810ffe38e', 'so', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Taageero EU oo leh qaddaro go''an oo loogu talagalay mashaariicda iskaashiga Yurub ee ugu horreeya ee ururrada yaryar.', '2026-08-28 17:30:50.650239+00'),
	('bf4eeab5-9fa8-4e7f-8271-03d4acf06e84', 'so', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Maalgelin shirkado da''yar oo horumarinaya alaabo ama adeegyo hal-abuur leh oo awood caalami leh.', '2026-08-28 17:30:50.650239+00'),
	('98b5dd9b-951f-4281-997a-a1d5cfd17e36', 'so', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Ma jiraa bangi kayd (sidaas darteedna sanduuq bangi-kayd) meesha aad ka hawlgashaan?', '2026-08-28 17:30:50.650239+00'),
	('00a8cdcb-e241-4a16-b7d5-2471c162611e', 'so', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Gunnooyin hawlgal oo dhowr sano ah oo loogu talagalay kooxaha madaxbannaan ee xirfadleyda ah ee qoob-ka-ciyaarka, masraxa iyo masraxa muusiga.', '2026-08-28 17:30:50.650239+00'),
	('ab2d0d8a-c6cc-4ec8-a676-aaac9708f37a', 'so', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Gunnooyin cilmi-baaris oo ku saabsan aagagga Forte: caafimaadka, nolosha shaqada iyo barwaaqada. Waxaa codsada cilmi-baarayaal shahaadada dhoktoorada haysta oo jaamacadaha Sweden jooga.', '2026-08-28 17:30:50.650239+00'),
	('46244cf9-26e4-454e-8c4e-0d5d732d965e', 'so', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Maalgelin cilmi-baaris oo loogu talagalay baaritaan aasaasi ah oo xor ah dhammaan qaybaha sayniska.', '2026-08-28 17:30:50.650239+00'),
	('d8942334-61a7-4666-9441-4a1e7d1d40e6', 'so', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Maalgelin cilmi-baaris oo ku saabsan deegaanka, cilmiga beeraha iyo qorshaynta magaalooyinka.', '2026-08-28 17:30:50.650239+00'),
	('cacbcaef-7388-43c2-b8b0-cf3f860fd407', 'so', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Ma ka fekereysaa inaad dibadda u guurto (shaqo, waxbarasho ama dib-u-laabasho)?', '2026-08-28 17:30:50.650239+00'),
	('52a6ee12-6441-4864-9fae-80ca4b9bb9c6', 'so', 'Genomförs insatserna av professionella kulturaktörer?', 'Hawlaha ma fuliyaan jilayaal dhaqameed xirfadle ah?', '2026-08-28 17:30:50.650239+00'),
	('f6319fea-bec4-4ec3-98d9-a75e0f91f981', 'so', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Mashruuca ma laga fuliyaa miyiga ama tuulo yar?', '2026-08-28 17:30:50.650239+00'),
	('cd4a62a7-87f5-49bc-8fd6-7edb9295c57b', 'so', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Ilaalin aasaasi ah oo loogu talagalay qofka noloshiisa oo dhan dakhli shaqo yar ama aan lahayn.', '2026-08-28 17:30:50.650239+00'),
	('4a9b0cc0-5e52-4b74-aeb0-2f859d9cf1ef', 'so', 'Går något av dina barn i grundskolan?', 'Mid ka mid ah carruurtaadu ma dhigtaa dugsiga hoose-dhexe?', '2026-08-28 17:30:50.650239+00'),
	('77eb1ccb-207e-45f8-bc0b-b188c0176e75', 'so', 'Går något av dina barn på gymnasiet?', 'Mid ka mid ah carruurtaadu ma dhigtaa dugsiga sare?', '2026-08-28 17:30:50.650239+00'),
	('a587bcfc-84de-41e8-be9e-f6b5c1d41fa9', 'so', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Shaqaaleysiintu ma khuseysaa qof awooddiisa shaqo hoos u dhacday?', '2026-08-28 17:30:50.650239+00'),
	('9daa034f-d2d5-4e73-8069-2b479353b8ef', 'so', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Shaqaaleysiintu ma khuseysaa qof muddo dheer shaqo la''aan ahaa ama ku cusub Sweden?', '2026-08-28 17:30:50.650239+00'),
	('45ad6a13-87bf-473a-919d-2a4b83aa31f1', 'so', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Mashruucu ma ku saabsan yahay ilaalinta hidaha dhaqanka ama helitaankiisa?', '2026-08-28 17:30:50.650239+00'),
	('b37562a2-5fec-43ad-b6d2-1208105bb1bc', 'so', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Mashruucu ma ku saabsan yahay tamar, hufnaan tamar ama hal-abuur tamar la xiriira?', '2026-08-28 17:30:50.650239+00'),
	('a61d8b67-d37c-432e-8a34-6f2f472b7b5e', 'so', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Mashruucu ma ku saabsan yahay caafimaad, nolol shaqo ama barwaaqo?', '2026-08-28 17:30:50.650239+00'),
	('f1388075-f95a-4d81-8bbd-d789efb27ed6', 'so', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Mashruucu ma ku saabsan yahay horumarinta aqoonta ama tallaabooyinka suuqa shaqada?', '2026-08-28 17:30:50.650239+00'),
	('56551753-32c3-4c54-9530-4d665857b94f', 'so', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Mashruucu ma ku saabsan yahay tallaabooyin deegaan ama cimilo?', '2026-08-28 17:30:50.650239+00'),
	('862228ef-c235-45c0-adb1-5eb3ee703d4a', 'so', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Ilmuhu ma leeyahay waddo dugsi oo dheer, khatar gaadiid leh ama si kale u adag?', '2026-08-28 17:30:50.650239+00'),
	('d11cc5ab-02c5-4eb9-b323-8af5ec7c3b7a', 'so', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Ma shaqeysay ugu yaraan 16 saacadood asbuucii, wadar ahaan ugu yaraan 8 sano?', '2026-08-28 17:30:50.650239+00'),
	('e7ff6a1c-3480-40cc-88b6-027a1b3b253d', 'so', 'Har du barn som bor hos dig, helt eller växelvis?', 'Ma leedahay carruur kula nool, si buuxda ama si kala duwan?', '2026-08-28 17:30:50.650239+00'),
	('951de740-6ad4-4d27-80ec-4a0e177d0c6c', 'so', 'Har du barn som bor hos dig?', 'Ma leedahay carruur kula nool?', '2026-08-28 17:30:50.650239+00'),
	('ad5f08fa-0c5c-495b-975c-03c6ed3dcd11', 'so', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Adiga ama ilmahaagu ma leedihiin naafanimo la filayo inay socoto ugu yaraan hal sano?', '2026-08-28 17:30:50.650239+00'),
	('80bc0ec9-9cbf-448c-9f1c-281d89480db9', 'so', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Adiga ama qof qoyska ka mid ahi ma leeyahay naafanimo joogto ah oo saameysa guriga?', '2026-08-28 17:30:50.650239+00'),
	('e0ea1f24-a37c-4862-87d6-b10cf61eca77', 'so', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Adiga ama qaraabo kuu dhow ma leedihiin naafanimo ama cudur muddo dheer socda ama daran?', '2026-08-28 17:30:50.650239+00'),
	('f7706edc-ee59-4990-9226-d9a3703cd58a', 'so', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Ma qabtaa cudur ama dhaawac hadda hoos u dhigaya awooddaada shaqo?', '2026-08-28 17:30:50.650239+00'),
	('ad28dd44-f7eb-4eec-b817-cbf66ee14660', 'so', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Weligaa ma kugu adkaatay inaad bixiso socdaal dugsi, safar fasal ama hawl firaaqo oo ilmahaaga laga filayo inuu ka qaybqaato?', '2026-08-28 17:30:50.650239+00'),
	('9289bdf4-2430-4735-90cf-a185706bf2a5', 'so', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Ma kugu adag tahay inaad ku noolaato hawlgabkaaga iyo dakhligaaga kale?', '2026-08-28 17:30:50.650239+00'),
	('2d61aca1-7847-455e-afa6-8a7371d0543d', 'so', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Sannadihii u dambeeyay ma heshay sharci degganaansho Sweden, tus. qof magangelyo u baahan ama xubin qoys ahaan?', '2026-08-28 17:30:50.650239+00'),
	('e4cfb3d1-409a-454a-8058-20c06c87a98b', 'so', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Ma haysataa sharci degganaansho Sweden qaxooti ahaan ama qof magangelyo u baahan (mise waxaad tahay qaraabo u dhow qof haysta)?', '2026-08-28 17:30:50.650239+00'),
	('554a888d-d593-4588-97cb-7d5b5787560b', 'so', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Ma gaadhay da''da tixraaca hawlgabka (67 sano 2026)?', '2026-08-28 17:30:50.650239+00'),
	('8d4d579a-6e8f-489b-9a10-81d213965695', 'so', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Ururkiinnu ma leeyahay OID (Organisation ID) oo ka diiwaangashan Organisation Registration System ee EU?', '2026-08-28 17:30:50.650239+00'),
	('824d74bb-f9f5-4715-8bde-f08ddedac9ef', 'so', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Naafanimadu ma keentay kharashyo dheeraad ah — tus. qalab caawiye, safarro, cunto gaar ah ama duugoobid?', '2026-08-28 17:30:50.650239+00'),
	('d84c0876-7d25-4731-bfb4-852bd9a139e0', 'so', 'Har föreningen antagna stadgar och en vald styrelse?', 'Ururku ma leeyahay xeerar la ansixiyay iyo guddi la doortay?', '2026-08-28 17:30:50.650239+00'),
	('677a52e1-8d1d-4acd-818f-97a69d1a421e', 'so', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Ururku ma leeyahay qaab-dhismeed dimoqraadi ah (xeerar, shir sannadeed, guddi)?', '2026-08-28 17:30:50.650239+00'),
	('49397cb8-6c9e-49d2-9afd-73b77981d8f4', 'so', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Ururku ma u qabtaa hawlo joogto ah carruurta ama dhallinyarada?', '2026-08-28 17:30:50.650239+00'),
	('ebe7cadf-8c0b-46b0-86e5-4011ce597cb6', 'so', 'Har företaget mellan cirka 2 och 49 anställda?', 'Shirkaddu ma leedahay inta u dhaxaysa qiyaastii 2 iyo 49 shaqaale?', '2026-08-28 17:30:50.650239+00'),
	('f7e8065d-a058-4668-a344-9fa230844b4a', 'so', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Qoysku ma ku dhibtoodaa daboolidda kharashka cuntada, guriga iyo waxyaabaha ugu muhiimsan?', '2026-08-28 17:30:50.650239+00'),
	('ba2e1bd1-230b-44d3-a5e5-c3796727d3d5', 'so', 'Har lösningen internationell potential?', 'Xalku ma leeyahay awood caalami ah?', '2026-08-28 17:30:50.650239+00'),
	('56094b42-5570-4a0f-a5d8-cb5e2528e497', 'so', 'Har ni en partnergrupp i ett annat land?', 'Ma leedihiin koox shuraako ah dal kale?', '2026-08-28 17:30:50.650239+00'),
	('8a2f26bf-16e4-4552-8de7-82c5d1eeeee0', 'so', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Ma leedihiin urur shuraako ah dal kale oo Yurub ah?', '2026-08-28 17:30:50.650239+00'),
	('e03eaf3c-349a-45b5-8b57-a6161f25632e', 'so', 'Har ni partner i minst tre olika europeiska länder?', 'Ma ku leedihiin shuraako ugu yaraan saddex dal oo Yurub ah oo kala duwan?', '2026-08-28 17:30:50.650239+00'),
	('4fc3378d-1784-4a30-9110-9a7d459039e1', 'so', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Xaruntiinnu ama hawshiinna ugu weyni ma ku taal gobolka aad ka codsanaysaan?', '2026-08-28 17:30:50.650239+00'),
	('fd93022e-8d59-413d-a33d-9630c28f330c', 'so', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Mid ka mid ah carruurtaadu ma leeyahay naafanimo ka dhigaysa inuu u baahdo daryeel ama ilaalin ka badan carruurta kale ee da''diisa ah?', '2026-08-28 17:30:50.650239+00');
INSERT INTO public.kb_translations VALUES
	('c9e57375-7d00-496d-bd16-cf3d60ddf3a4', 'so', 'Har organisationen en demokratisk uppbyggnad?', 'Ururku ma leeyahay qaab-dhismeed dimoqraadi ah?', '2026-08-28 17:30:50.650239+00'),
	('acc750a0-9564-4058-852c-1f08efa0f50b', 'so', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Ururku ma leeyahay Quality Label (calaamad tayo)?', '2026-08-28 17:30:50.650239+00'),
	('f057edcf-1e5b-45bd-a804-2f1a6a829f06', 'so', 'Har organisationen ett 90-konto?', 'Ururku ma leeyahay 90-konto?', '2026-08-28 17:30:50.650239+00'),
	('413e429b-9891-46f9-b445-85930cff0481', 'so', 'Har organisationen ett OID (Organisation ID)?', 'Ururku ma leeyahay OID (Organisation ID)?', '2026-08-28 17:30:50.650239+00'),
	('d7886582-b968-4de1-b796-2e61e343670c', 'so', 'Har organisationen ett OID?', 'Ururku ma leeyahay OID?', '2026-08-28 17:30:50.650239+00'),
	('c6c63739-8aea-4867-b731-fd4e8541c35a', 'so', 'Har organisationen medlemsföreningar i flera län?', 'Ururku ma ku leeyahay ururro xubno ah dhowr gobol?', '2026-08-28 17:30:50.650239+00'),
	('95b97262-21d1-44f1-8261-62b5ae84fca2', 'so', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Ururku ma leeyahay dhaqaale nidaamsan iyo qaab-dhismeed dimoqraadi ah?', '2026-08-28 17:30:50.650239+00'),
	('36848fd7-d895-4887-ae11-ed7f857e18e8', 'so', 'Har projektet en partner i ett annat land?', 'Mashruucu ma leeyahay shuraako dal kale?', '2026-08-28 17:30:50.650239+00'),
	('31e3098a-9dd4-472e-859a-4bef3ad953e0', 'so', 'Har projektledaren doktorsexamen?', 'Hoggaamiyaha mashruucu ma haystaa shahaadada dhoktoorada?', '2026-08-28 17:30:50.650239+00'),
	('6bdec44f-c87c-4113-a576-215490e2ee4a', 'so', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Degmada aad degan tahay waa inay bixiso safarrada maalinlaha ah ee u dhexeeya guriga iyo dugsiga sare marka waddadu tahay ugu yaraan lix kiilomitir (tus. kaadhka baska).', '2026-08-28 17:30:50.650239+00'),
	('a16c8972-6003-4948-a3b6-b63f28b5b23a', 'so', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Ma ku guda jirtaa helidda ama qalabaynta gurigaaga ugu horreeya ee Sweden?', '2026-08-28 17:30:50.650239+00'),
	('f7c1561e-eac5-4420-9135-8aaf1c3233a9', 'so', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Mashruucu ma ku jiraa safar ama isweydaarsi caalami ah?', '2026-08-28 17:30:50.650239+00'),
	('108c84fa-2de7-49dc-b4e4-3d73da309954', 'so', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Taageero maalgelin oo loogu talagalay shirkadaha aagagga taageerada — dhismayaal, mashiinno iyo tababar.', '2026-08-28 17:30:50.650239+00'),
	('95fe5747-1e62-4f47-9465-cbe6feb22c63', 'so', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Taageero maalgelin oo loogu talagalay tallaabooyin yareeya qiiqa gaaska lab-guriyeed.', '2026-08-28 17:30:50.650239+00'),
	('07b10b66-4209-4f6e-8b85-4a481a92bd67', 'so', 'Kan projektets miljönytta mätas?', 'Faa''iidada deegaanka ee mashruuca ma la cabbiri karaa?', '2026-08-28 17:30:50.650239+00'),
	('13d01a30-e318-4139-a0a0-2fd04fec8041', 'so', 'Kan åtgärdens utsläppsminskning beräknas?', 'Yaraynta qiiqa ee tallaabada ma la xisaabin karaa?', '2026-08-28 17:30:50.650239+00'),
	('e5e76b0e-e8fa-4005-b35c-42980d4255cc', 'so', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Ururku ma awoodaa inuu qaado kharashyada ilaa taageerada la bixiyo?', '2026-08-28 17:30:50.650239+00'),
	('dd28b2e3-12f2-44b1-af59-23e6bf0c3b01', 'so', 'Är minst 60 % av medlemmarna under 26 år?', 'Ugu yaraan 60 % xubnuhu ma ka yar yihiin 26 jir?', '2026-08-28 17:30:50.653837+00'),
	('8aab0c30-2ef6-4f16-bec5-20a033ae274a', 'so', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Maalgelintu ma bilaabmaysaa kaliya kadib markaad codsiga dirto?', '2026-08-28 17:30:50.650239+00'),
	('e37e3f36-22b0-467b-bd2e-df3a32f9147e', 'so', 'Kommer projektet människor i ert närområde till del?', 'Mashruucu ma anfacaa dadka deegaankiinna?', '2026-08-28 17:30:50.650239+00'),
	('90efdcf6-70ea-45e7-9d60-5a92eabbb411', 'so', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Shabakadda badbaadada dhaqaale ee ugu dambeysa ee degmada marka dakhligu uusan gaadhin waxyaabaha ugu muhiimsan.', '2026-08-28 17:30:50.650239+00'),
	('2be36d75-1cbb-4990-9b12-93ba45b72c9a', 'so', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Taageerooyinka gaarka ah ee degmooyinka ee ururrada maxalliga ah: taageero hawleed goob kasta, gunno goob, gunno bilow iyo wax kale.', '2026-08-28 17:30:50.650239+00'),
	('43838cdc-e2e0-445b-b472-4aa924a46b13', 'so', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Gaadiid dugsi oo bilaash ah oo loogu talagalay ardayda dugsiga hoose-dhexe marka masaafadu dheer tahay, waddadu khatar tahay ama naafanimo jirto — xaq sida uu dhigayo sharciga dugsiyada.', '2026-08-28 17:30:50.650239+00'),
	('c1d75178-6a41-451b-8d22-7ba1b6001adc', 'so', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Gunno sharci ah oo muraayado indho ama lenso ah oo loogu talagalay carruurta iyo dhallinyarada; qaddarka iyo habraacu way ku kala duwan yihiin gobolka — hubi heerka gobolkaaga.', '2026-08-28 17:30:50.650239+00'),
	('aedac70e-dad5-4b78-b420-17146c31ae4c', 'so', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Mashruucu ma ku yaal deegaan ay khusayso korontada biyaha ama dabayshu?', '2026-08-28 17:30:50.650239+00'),
	('57df451f-d079-4566-872c-d81b9f7d4491', 'so', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Mashruucu ma ku jiraa deegaanka, cilmiga beeraha ama qorshaynta magaalooyinka?', '2026-08-28 17:30:50.650239+00'),
	('ee6e71e5-630c-40cb-a400-e7203f988e60', 'so', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Goobta hawshu ma ku taal aagga taageerada A ama B (qaybo badan oo Norrland iyo Svealand gudaha ah)?', '2026-08-28 17:30:50.650239+00'),
	('d30fe681-9930-4e6e-996d-01a5dcbafcaf', 'so', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Deyn lagu iibsado waxyaabaha ugu muhiimsan ee guriga ugu horreeya ee Sweden — fadhi, qalab guri iyo qalab kale oo aasaasi ah.', '2026-08-28 17:30:50.650239+00'),
	('06323b83-bcd2-4ab7-beb0-e615453e9922', 'so', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Mashruucu ma yareeyaa qiiqa hawlaha warshadaha mise wuxuu abuuraa qiiq taban?', '2026-08-28 17:30:50.650239+00'),
	('8162e8ea-a9f3-4b50-bee6-f9e5df0ca725', 'so', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Gunno bille ah oo loogu talagalay carruurta Sweden ku nool, dhalashada ilaa 16 jir.', '2026-08-28 17:30:50.650239+00'),
	('fa10860f-e846-4d0e-9b8a-e6a158e8713c', 'so', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket waxay gunnooyin siisaa ururro, shirkado, jameecooyin, qaybta dadweynaha iyo shakhsiyaad dhinaca deegaanka.', '2026-08-28 17:30:50.650239+00'),
	('4c1b0980-959d-4a47-84f7-9013fce63f77', 'so', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Ma qorsheyneysaa inaad si mutadawacnimo ah oo joogto ah ugu laabato dalkaagii asalka ahaa?', '2026-08-28 17:30:50.650239+00'),
	('be03b420-b9bc-4c4d-b1d1-16022195afaa', 'so', 'Planerar du att starta eget företag?', 'Ma qorsheyneysaa inaad bilowdo ganacsi adiga kuu gaar ah?', '2026-08-28 17:30:50.650239+00'),
	('bddd1f2f-3a12-4869-95d3-8432b5f7e287', 'so', 'Planerar du att studera utomlands?', 'Ma qorsheyneysaa inaad dibadda wax ku barato?', '2026-08-28 17:30:50.650239+00'),
	('74ecbcfe-429a-4653-91a1-6e3bf36fb981', 'so', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Ma qorsheyneysaa waxbarasho xoojisa meeshaad ka taagan tahay suuqa shaqada?', '2026-08-28 17:30:50.650239+00'),
	('b6f19b2e-fc44-49e9-ae98-d732af588a92', 'so', 'Planerar ni att anställa?', 'Ma qorsheyneysaan inaad shaqaaleysiisaan?', '2026-08-28 17:30:50.650239+00'),
	('481f763e-787f-44fc-9988-037ed44d4ca7', 'so', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Ma qorsheyneysaan inaad codsataan barnaamij EU (tus. Horisont Europa)?', '2026-08-28 17:30:50.650239+00'),
	('5de790b4-c8b9-4e15-82ce-a539322f7009', 'so', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Taageero soo-saarid iyo horumarin oo loogu talagalay filimo gaagaaban iyo dokumentari.', '2026-08-28 17:30:50.650239+00'),
	('e0044b26-3a0e-4631-9db7-7575c1695dae', 'so', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Gunnooyin mashruuc oo loogu talagalay goobta muusiga ee madaxbannaan: riwaayado, soo-saarid iyo horumarin.', '2026-08-28 17:30:50.650239+00'),
	('1c0d45ab-47b6-4f8b-8bd3-bbaa6eb60787', 'so', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Gunnooyin mashruuc oo loogu talagalay ururrada aan faa''iido doonka ahayn ee la shaqeeya carruurta iyo dhallinyarada, unana shaqeeya iyaga.', '2026-08-28 17:30:50.650239+00'),
	('f9019512-3af5-468a-a46c-2348472d30a0', 'so', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Mashruucu ma tijaabiyaa muujinno, habab ama iskaashiyo faneed oo cusub?', '2026-08-28 17:30:50.650239+00'),
	('d88f4833-fb9a-4dc8-acea-6f0c8c5cc6d9', 'so', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Isweydaarsigu ma socdaa 5–21 maalmood (aan lagu darin maalmaha safarka)?', '2026-08-28 17:30:50.650239+00'),
	('ec5a0f21-4914-4662-a914-f13f40f3e202', 'so', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Taageerooyinka gaarka ah ee gobollada ee mashaariicda iyo hawlaha dhaqanka, oo ka baxsan gunnooyinka qaranka ee Kulturrådet.', '2026-08-28 17:30:50.650239+00'),
	('a7bcd713-bd94-4b23-a85d-6ea558fc36f1', 'so', 'Riktar sig projektet till barn eller unga?', 'Mashruucu ma u jiheysan yahay carruurta ama dhallinyarada?', '2026-08-28 17:30:50.650239+00'),
	('1f06cd26-660b-4aa2-bc7d-69ab2eddcdff', 'so', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Mashruucu ma u jiheysan yahay carruurta, dhallinyarada, waayeelka ama dadka naafada ah?', '2026-08-28 17:30:50.650239+00'),
	('9a452825-1dce-46e3-8714-29badf390254', 'so', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Hawshu ma u jiheysan tahay carruurta iyo dhallinyarada (7–25 jir)?', '2026-08-28 17:30:50.650239+00'),
	('a02bb1e1-fa19-46a6-80ac-553fe5af1304', 'so', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Ma waayey kayd lacageed ama hanti dabooli karta kharashyada?', '2026-08-28 17:30:50.650239+00'),
	('5141b9bc-7ca5-443e-9ac2-f14eaa050c3c', 'so', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Ma la shaqeysaan shuraako jooga ugu yaraan laba dal oo kale oo Waqooyiga Yurub ah?', '2026-08-28 17:30:50.650239+00'),
	('11e24c9f-9bc3-42fd-b0c1-49a1d7c6cc47', 'so', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Ma keensanaysaan aqoon dibadeed hawl horumarineed dartood?', '2026-08-28 17:30:50.650239+00'),
	('357c986d-186e-4fee-8021-d7d2cac2f571', 'so', 'Sker mobiliteten till ett annat europeiskt land?', 'Dhaqdhaqaaqu ma u socdaa dal kale oo Yurub ah?', '2026-08-28 17:30:50.650239+00');
INSERT INTO public.kb_translations VALUES
	('25774a2b-50dd-43dc-bd29-36653b34031c', 'so', 'Startar du eller tar du över företaget för första gången?', 'Markan ma tahay markii ugu horreysay oo aad bilowdo ama la wareegto ganacsiga?', '2026-08-28 17:30:50.650239+00'),
	('7cd91358-65f5-48c0-ac68-20d621b4b18c', 'so', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Taageero bilow oo loogu talagalay qofka 40 jir ama ka yar ee bilaabaya ama la wareegaya ganacsi beeraley ah.', '2026-08-28 17:30:50.650239+00'),
	('b3d975e7-c1c7-47ef-803d-72795ca36341', 'so', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Deeq-waxbarasho u oggolaanaysa fannaaniinta xirfadleyda ah inay diiradda saaraan shaqadooda faneed.', '2026-08-28 17:30:50.650239+00'),
	('afdec8c5-3883-4954-a61d-ed11edfc5627', 'so', 'Studerar du, eller planerar du att börja studera?', 'Wax ma baranaysaa, mise waxaad qorsheyneysaa inaad bilowdo waxbarasho?', '2026-08-28 17:30:50.650239+00'),
	('ec115fad-ceaa-4b31-bbf3-8ab75da65ac6', 'so', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Taageero waxbarasho oo loogu talagalay dadka waaweyn ee shaqeeya ee doonaya inay wax bartaan si ay u xoojiyaan meeshay ka taagan yihiin suuqa shaqada.', '2026-08-28 17:30:50.650239+00'),
	('f9376c4b-9538-4a6d-93c0-104e889fff2c', 'so', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Taageero maalgelinno kordhiya tartanka ama yareeya saameynta deegaanka ee ganacsiyada beeraleyda.', '2026-08-28 17:30:50.650239+00'),
	('ba01abea-33bc-4ea6-a889-6b5ec836657e', 'so', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Taageero marka ilmo kula nool yahay oo waalidka kale uusan bixin masruuf.', '2026-08-28 17:30:50.650239+00'),
	('c9ee9d5b-175b-46ad-953f-eeeb7a35efad', 'so', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Taageero mashaariicda ururrada aan faa''iido doonka ahayn ee dadka, deegaanka iyo dunida ka wanaagsan.', '2026-08-28 17:30:50.650239+00'),
	('d4eed1e3-4454-4da8-86ad-5547e1917871', 'so', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Taageero u-gudubka warshadaha ee eber qiiqa gaaska lab-guriyeed.', '2026-08-28 17:30:50.650239+00'),
	('3ea1c05c-4def-4c56-8625-501f6c78f2dc', 'so', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Taageero mashaariicda fanka iyo dhaqanka ee leh muuqaal waqooyi-yurubeed iyo iskaashi xuduudaha ka gudba.', '2026-08-28 17:30:50.650239+00'),
	('c3433130-963f-4a1b-89e5-c2cb601c2dc6', 'so', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Taageero mashaariic dhaqameed hal-abuur leh oo tijaabinaya muujinno, habab ama iskaashiyo faneed oo cusub.', '2026-08-28 17:30:50.650239+00'),
	('fc73ffa5-d431-40de-a387-e85c7594db0e', 'so', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Taageero mashaariic hal-abuur leh oo loogu talagalay carruurta, dhallinyarada, waayeelka iyo dadka naafada ah.', '2026-08-28 17:30:50.650239+00'),
	('10418a97-f5b2-473e-be4b-c29250d63350', 'so', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Taageero mashaariicda iskaashiga ee goobta muusiga madaxbannaan.', '2026-08-28 17:30:50.650239+00'),
	('d094fbde-31a0-4be8-a769-03d91c6c08e6', 'so', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Taageero mashaariicda iskaashiga ee dhaqanka iyo warbaahinta ee xoojiya dimoqraadiyadda iyo xorriyadda hadalka caalami ahaan.', '2026-08-28 17:30:50.650239+00'),
	('f429ab61-e272-4a74-a272-ba741f494963', 'so', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Mashruucu ma hiigsadaa xoojinta dimoqraadiyadda, sinnaanta ama xorriyadda hadalka?', '2026-08-28 17:30:50.650239+00'),
	('96811789-9880-49ef-bf39-09365bdeecd1', 'so', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Shaqo ma ka raadinaysaa, mise waxaa lagaa siiyay shaqo, dal kale oo EU ama EES ah?', '2026-08-28 17:30:50.650239+00'),
	('47de4585-feb1-4c20-a0ac-03f8d16e863a', 'so', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Xad sare oo waxa aad bixiso khidmadaha bukaanka muddo laba iyo toban bilood ah — kadibna frikort (kaadh bilaash ah).', '2026-08-28 17:30:50.650239+00'),
	('6bafbd95-a7a7-4bd7-b40f-485c791c4e1b', 'so', 'Tar du ut hel allmän pension?', 'Ma qaadataa hawlgabkaaga guud oo dhammaystiran?', '2026-08-28 17:30:50.650239+00'),
	('fc1f43a6-a3ec-490a-b8b2-96cbe95b85c3', 'so', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Kordhin daboolaysa qayb ka mid ah kharashka guriga qofka haysta hawlgab iyo dakhli hooseeya.', '2026-08-28 17:30:50.650239+00'),
	('6442d28d-764a-406e-980b-66e931a09246', 'so', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Gunno urureed sannadle ah oo loogu talagalay ururrada qaranka ee carruurta iyo dhallinyarada.', '2026-08-28 17:30:50.650239+00'),
	('e6daa2b7-f76c-4870-b266-127a31d7ab24', 'so', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Xisaab sannadle ah oo si toos ah looga jaro dhakhtarka ilkaha ama nadiifiyaha ilkaha.', '2026-08-28 17:30:50.650239+00'),
	('e969c69c-f690-48bf-b6f9-ddbb08738bb6', 'so', 'Är bolaget yngre än cirka 5 år?', 'Shirkaddu ma ka yar tahay qiyaastii 5 sano?', '2026-08-28 17:30:50.650239+00'),
	('37c9faa2-0317-424b-862f-15cf9c66758a', 'so', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Ka-qaybgalayaasha isweydaarsigu ma u dhexeeyaan 13 iyo 30 jir?', '2026-08-28 17:30:50.650239+00'),
	('3e2abfff-55ec-4dc7-bab4-348ee1f98f52', 'so', 'Är det här ert första EU-projekt?', 'Kani ma mashruucii EU ee idiin ugu horreeyay baa?', '2026-08-28 17:30:50.650239+00'),
	('d511a065-ca48-495a-9cc3-b989873bb018', 'so', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Ma aad ugu adag tahay adiga (ama ilmahaaga) inaad keligaa dhaqdhaqaaqdo ama aad ku safarto bas iyo tareen?', '2026-08-28 17:30:50.650239+00'),
	('92d2c3ab-4925-4587-a8e7-381afc8a5ada', 'so', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Dakhligaagu ma ka yar yahay qiyaastii 25 000 kr bishii canshuurta ka hor?', '2026-08-28 17:30:50.650239+00'),
	('49206130-1deb-4a82-a51f-998f85913b97', 'so', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Waxbarashadaadii ugu dambeysay ee dhammaystirneyd ma dugsiga hoose-dhexe baa, mise dugsi sare oo aadan dhammaystirin?', '2026-08-28 17:30:50.650239+00'),
	('979bc8e2-fd1b-431c-9df2-44c209a96343', 'so', 'Är du 40 år eller yngre?', 'Ma tahay 40 jir ama ka yar?', '2026-08-28 17:30:50.650239+00'),
	('057dbcb0-da4c-44e9-945b-316d8bda2f8a', 'so', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Ma ka diiwaangashan tahay Arbetsförmedlingen shaqo-doon ahaan?', '2026-08-28 17:30:50.650239+00'),
	('0dc6d3de-9e00-4718-bfe0-c09ddd086460', 'so', 'Är du mellan 18 och 28 år?', 'Ma u dhexeysaa 18 iyo 28 jir?', '2026-08-28 17:30:50.650239+00'),
	('47bf0e15-7cdb-4113-a107-cde49960b037', 'so', 'Är du mellan 19 och 29 år?', 'Ma u dhexeysaa 19 iyo 29 jir?', '2026-08-28 17:30:50.650239+00'),
	('7a59a26c-5650-4286-9501-e29fffc7f0dd', 'so', 'Är du mellan 25 och 60 år?', 'Ma u dhexeysaa 25 iyo 60 jir?', '2026-08-28 17:30:50.650239+00'),
	('b0e2ed3f-3fb8-4006-aade-f949e0c7857f', 'so', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Si xirfadle ah ma uga shaqeysaa dhinaca dhaqanka (tus. qoob-ka-ciyaar, muusig, fanka masraxa)?', '2026-08-28 17:30:50.650239+00'),
	('64a9ad32-1202-43e3-890c-7a8bb8dc3fca', 'so', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Ma tahay fannaan xirfadle ah (ma tihid hiwaayad ama tababar aasaasi ah)?', '2026-08-28 17:30:50.650239+00'),
	('281220f5-013e-49f4-9dac-c9f6e39e70fe', 'so', 'Är du yrkesverksam konstnär?', 'Ma tahay fannaan xirfadle ah?', '2026-08-28 17:30:50.650239+00'),
	('e786af11-8253-4bfa-9a2b-bf68b2813bc2', 'so', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Xalkiinnu ma yahay mid si weyn hal-abuur ugu ah marka la barbardhigo waxa horeba u jira?', '2026-08-28 17:30:50.653837+00'),
	('822f07eb-3a2e-4b8a-a364-979c2ec9ca63', 'so', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Naadigu ma ka tirsan yahay xiriir isboorti oo gaar ah oo hoos yimaadda Riksidrottsförbundet?', '2026-08-28 17:30:50.653837+00'),
	('2a79eb42-8bb2-4fbb-bd71-8a8a6ca20a83', 'so', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Dakhliga qoysku ma hooseeyaa marka loo eego kharashka guriga?', '2026-08-28 17:30:50.653837+00'),
	('ae72ff64-ea71-444a-89bb-ae3b69fe37ad', 'so', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Dakhliga wadajirka ah ee qoysku ma ka yar yahay qiyaastii 25 000 kr bishii canshuurta ka hor?', '2026-08-28 17:30:50.653837+00'),
	('6dc9334e-65a1-4942-9646-7d830c290b7e', 'so', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Tallaabadu ma tahay mashruuc go''an (ma aha hawsha caadiga ah)?', '2026-08-28 17:30:50.653837+00'),
	('693d06a5-a2b5-4091-85eb-f0d9d05b003f', 'so', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Goobtu ma u furan tahay dhammaan dadka — ma aha oo kaliya xubnihiinna?', '2026-08-28 17:30:50.653837+00'),
	('0f83f94f-f9da-408b-a06f-426a9fb5e0e3', 'so', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Ugu yaraan 60 % xubnuhu ma u dhexeeyaan 6 iyo 25 jir?', '2026-08-28 17:30:50.653837+00'),
	('bad6e64c-d906-4155-a17b-82cce138004c', 'so', 'Är målgruppen delaktig i planering och genomförande?', 'Kooxda bartilmaameedka ahi ma ka qaybqaataa qorshaynta iyo fulinta?', '2026-08-28 17:30:50.653837+00'),
	('8cb6aaaf-017d-4ba2-a647-f3857492ffa1', 'so', 'Är ni ett förlag med professionell utgivning?', 'Ma tihiin daabacaad leh daabacaad xirfadle ah?', '2026-08-28 17:30:50.653837+00'),
	('2ddb8ea5-73ca-4dae-b0c4-95d19eaa185f', 'so', 'Är ni huvudman för förskoleklass eller grundskola?', 'Ma tihiin masuulka fasalka dugsi-barbaarinta ama dugsiga hoose-dhexe?', '2026-08-28 17:30:50.653837+00'),
	('a0696445-0d1b-4541-a5cd-ff3d6d8df1ca', 'so', 'Är organisationen registrerad i EU:s deltagarregister?', 'Ururku ma ka diiwaangashan yahay diiwaanka ka-qaybgalayaasha ee EU?', '2026-08-28 17:30:50.653837+00'),
	('dedda7e1-91b4-46ce-80e2-ba7e8ff0e1dc', 'so', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Mashruucu ma yahay mashruuc filim (filim gaaban ama dokumentari)?', '2026-08-28 17:30:50.653837+00'),
	('d24376b4-e972-4f16-93e1-71db35d030b8', 'so', 'Är projektet ett konst- eller kulturprojekt?', 'Mashruucu ma yahay mashruuc faneed ama dhaqameed?', '2026-08-28 17:30:50.653837+00'),
	('0e5c412f-5c99-440f-90c6-16fb12b8c82b', 'so', 'Är projektet ett kulturprojekt?', 'Mashruucu ma yahay mashruuc dhaqameed?', '2026-08-28 17:30:50.653837+00'),
	('d4ab2bd9-d86f-43b9-a02a-0f361da7c6ca', 'so', 'Är projektet ett musikprojekt?', 'Mashruucu ma yahay mashruuc muusig?', '2026-08-28 17:30:50.653837+00');
INSERT INTO public.kb_translations VALUES
	('b04ef195-629f-4bb2-8469-a18e3ec2783a', 'so', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Mashruucu ma yahay hal-abuur — wax aydaan horeba ugu samayn hawshiinna caadiga ah?', '2026-08-28 17:30:50.653837+00'),
	('49138004-97cb-40d9-a302-502d38fd9c32', 'so', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Mashruucu ma anfacaa deegaanka oo dhan (ma aha shakhsiyaad)?', '2026-08-28 17:30:50.653837+00'),
	('42540731-5a76-4f8b-ba61-d8724fd0a62d', 'so', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Waddada u dhexeysa guriga iyo dugsiga sare ma tahay ugu yaraan lix kiilomitir?', '2026-08-28 17:30:50.653837+00'),
	('22387c0a-9a80-4c09-ad42-c485fbbe4a49', 'so', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Hawshu ma tahay mid xirfadle ah (ma aha hiwaayad)?', '2026-08-28 17:30:50.653837+00'),
	('63bc9c99-7bd7-4413-b281-c302820faa6a', 'so', 'Är verksamheten professionell?', 'Hawshu ma tahay mid xirfadle ah?', '2026-08-28 17:30:50.653837+00'),
	('de0a79d5-f6ba-4e73-a5b8-3241b4532ff3', 'so', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Hawshu ma tahay fanka masraxa (qoob-ka-ciyaar, masrax, masrax muusig)?', '2026-08-28 17:30:50.653837+00'),
	('382d12d7-6583-4f6a-8001-cd5950abe434', 'so', 'Är volontärerna mellan 18 och 30 år?', 'Mutadawiciintu ma u dhexeeyaan 18 iyo 30 jir?', '2026-08-28 17:30:50.653837+00'),
	('eb8cbb1c-e3d9-481d-aee1-5d7545ec1c30', 'ti', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'ንስፖርታዊ ማሕበራት ንህጻናትን መንእሰያትን 7–25 ዓመት ብመራሒ ዝምራሕ ንጥፈታት ዘካይዳ ዝወሃብ ደገፍ ንጥፈታት።', '2026-08-28 17:30:50.657973+00'),
	('8f4d67b4-9903-4010-8de0-bec93e7ef78b', 'ti', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'ካብ ካልኣይ ውሉድ ጀሚሩ ኣብ ልዕሊ ናይ ህጻናት ሓገዝ (barnbidrag) ብቐጥታ ዝውሰኽ ተወሳኺ።', '2026-08-28 17:30:50.657973+00'),
	('7c746372-1889-48a6-8c32-6ff279b31bfc', 'ti', 'Avser ansökan en fysisk investering?', 'እቲ ማመልከቻ ንኣካላዊ ወፍሪ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('96eae35b-c858-45c0-9dae-c1103fbb30c4', 'ti', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'እቲ ማመልከቻ ንኣህጉራዊ ጕዕዞ ወይ ምልውዋጥ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('7025cf93-6ece-4b92-97f2-e4a3b00bb89a', 'ti', 'Avser ansökan en investering i byggnader eller maskiner?', 'እቲ ማመልከቻ ኣብ ህንጻታት ወይ ማሽናት ንዝግበር ወፍሪ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('3fb671f9-58c5-4e82-888c-2a1c7801c1c3', 'ti', 'Avser ansökan en redan utgiven titel?', 'እቲ ማመልከቻ ድሮ ንዝተሓትመ ስራሕ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('1b8f4f89-6d13-4554-ad7d-747608de5d1e', 'ti', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'እቲ ማመልከቻ ንሕርሻዊ፣ ኣታኽልታዊ ወይ ናይ ሰሜናዊ ጤለ-በጊዕ ኣርብሓ ትካል ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('e1e7f176-329d-4a30-b240-f8c6aa5998cd', 'ti', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'እቲ ማመልከቻ ንህዝባዊ ወይ ናይ ቤት-ትምህርቲ ኣብያተ-መጻሕፍቲ መጻሕፍቲ ምዕዳግ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('efa4e44b-1d08-4db3-af5b-9940d7f380e9', 'ti', 'Avser investeringen jordbruksverksamhet?', 'እቲ ወፍሪ ንሕርሻዊ ንጥፈት ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('f63a4725-b96d-4e6d-8d65-31a40359286c', 'ti', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'እቲ ፕሮጀክት ምህናጽ፣ ምዕዳግ ወይ ምጽጋን ኣዳራሽ ድዩ ዘጠቓልል?', '2026-08-28 17:30:50.657973+00'),
	('138ed3d3-c5ca-4811-823a-f22c2968247c', 'ti', 'Avser projektet naturvård eller friluftsliv?', 'እቲ ፕሮጀክት ንሓለዋ ተፈጥሮ ወይ ንደገ ዝግበር ምዝንጋዕ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('2fcc9059-5fae-4ee7-bc80-013a85830511', 'ti', 'Avser projektet skola eller vuxenutbildning?', 'እቲ ፕሮጀክት ንቤት-ትምህርቲ ወይ ንትምህርቲ ዓበይቲ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('f19c34d4-20a9-477e-a465-d2dbf9351bf0', 'ti', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'ሕማሙ ንህይወቱ ዘስግእ ብጽኑዕ ዝሓመመ ቀረባ ሰብ ንምክንኻን ወይ ኣብ ጐድኑ ንምህላው ካብ ስራሕ ትቑጠብ ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('b5b75f11-7bba-4b4f-acd9-94453aa2672b', 'ti', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'እቲ ማሕበር ኣብቲ ምምሕዳር ከተማ ስሩዕ ንጥፈታት ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('978e079d-1565-44c9-ac46-ed005c28106b', 'ti', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'ብሰንኪ ሕማም ወይ ስንክልና ናይ ስራሕ ዓቕምኻ እንተ ወሓደ ንሓደ ዓመት ከም ዝጐደለ ትግምግም ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('1c8f5689-e976-4e3f-9b3c-b5b90720d292', 'ti', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'ንትሑት ወይ ዜብሉ ጡረታ ዘለዎም እሞ ብቑዕ ደረጃ ናብራ ንምብጻሕ ሓገዝ ዘድልዮም ብድሌት ዝግምገም ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('756cacdf-5d07-47ec-8a50-f859fd102c6b', 'ti', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'እቲ ቆልዓ መገዲ ኣዝዩ ነዊሕ ስለ ዝኾነ ኣብ ቦታ ትምህርቲ ክቕመጥ (መንበሪ) የድልዮ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('24d49a00-c3fc-47a0-b4b5-241c0e9d1e91', 'ti', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'እቲ መንበሪ ምምዕርራይ የድልዮ ድዩ (ንኣብነት መደያይቦ፣ መኽፈቲ ማዕጾ፣ መሕጸቢ)?', '2026-08-28 17:30:50.657973+00'),
	('efc5f922-feae-497f-9080-d1672e208e1a', 'ti', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'ካብ ደቅኻ ኣብ ዕድመ 8–19 ዘሎ መነጽር ወይ ሌንስ የድልዮ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('5b6427a4-6aba-407a-81af-af773d301d73', 'ti', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'እቲ ካልእ ወላዲ ገለ ኣይከፍልን ወይ ካብ ምሉእ ቀለብ ዝወሓደ ድዩ ዝኸፍል?', '2026-08-28 17:30:50.657973+00'),
	('1d7fb9c3-6f06-4f5c-8e77-076021a3e168', 'ti', 'Betalar du hyra eller andra boendekostnader?', 'ክራይ ወይ ካልእ ወጻኢታት መንበሪ ትኸፍል ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('c80dc6e1-dc08-42de-9dc3-2159ae32ae4c', 'ti', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'እቲ ወፍሪ ማመልከቻ ምስ ለኣኽኩም ጥራይ ድዩ ዝጅምር?', '2026-08-28 17:30:50.657973+00'),
	('084c7a18-0b57-4104-8bdb-229cf4a035e2', 'ti', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'ኣብ እዋን ስንክልና ንመንበሪ ምምዕርራይ ዝወሃብ ሓገዝ — ንኣብነት መደያይቦታት፣ መኽፈቲ ማዕጾ ወይ ምምዕርራይ መሕጸቢ።', '2026-08-28 17:30:50.657973+00'),
	('5b39f228-ea2e-4617-a125-92c015e6ac4d', 'ti', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'ህዝባዊ ኣዳራሻት ኣኼባ ንምህናጽ፣ ንምዕዳግ ወይ ንምጽጋን ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('e7bad992-b1f6-4c8f-92ad-3794e88abf6d', 'ti', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'ቀዋሚ ስንክልና ምንቅስቓስ ወይ ብህዝባዊ መጓዓዝያ ምጕዓዝ ኣዝዩ ኣጸጋሚ ምስ ዝገብሮ መኪና ንምዕዳግ ወይ ንምምዕርራይ ዝወሃብ ሓገዝ።', '2026-08-28 17:30:50.657973+00'),
	('d8cfd579-4ae3-4d56-9721-c42a314ed676', 'ti', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'ኣብ ዓውዲ ባህሊ ንዝሰርሑ ሞያውያን ንኣህጉራዊ ጕዕዞታትን ምልውዋጣትን ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('803e3d61-d64c-45e0-ae89-4bf20a832b39', 'ti', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'ንሞያውያን ስነ-ጥበበኛታት ኣህጉራዊ ምልውዋጣት፣ ጕዕዞታትን ናይ ስራሕ ጻንሒታትን ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('f5e40c14-199d-4464-8f0c-11295bb33dc8', 'ti', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'ኣብ ደረጃ ካልኣይ ደረጃ ወይ ድሕሪኡ ንዝግበር ትምህርቲ ሓገዝን ወለንታዊ ልቓሕን።', '2026-08-28 17:30:50.657973+00'),
	('1d41eb54-b686-4f13-8edc-464ac16452da', 'ti', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'ኣብ ወጻኢ ንዝግበር ትምህርቲ ሓገዛትን ልቓሓትን፣ ንኣብነት ክፍሊት ትምህርትን ጕዕዞን ዝሽፍኑ ተወሰኽቲ ልቓሓት ዘለዉዎ።', '2026-08-28 17:30:50.657973+00'),
	('ac865812-563f-435f-9f6c-071eb99c00d3', 'ti', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'ንሽወደናውያን ኣካላት ናብ ናይ EU መደባት ከም Horisont Europa ማመልከቻ ንምድላው ዝሕግዝ ሓገዝ።', '2026-08-28 17:30:50.657973+00'),
	('48601698-9952-4e9d-8ad1-a58b6df0b16e', 'ti', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'ዝጐደለ ናይ ስራሕ ዓቕሚ ንዘለዎም ሰባት ንዝቖጽሩ ኣስራሕቲ ዝወሃብ ሓገዝ።', '2026-08-28 17:30:50.657973+00'),
	('f9ef8dc2-47b5-464c-b4ac-4bbc9a843cc9', 'ti', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'ተምሃራይ ካልኣይ ደረጃ ብሰንኪ ነዊሕ መገዲ ኣብ ቦታ ትምህርቲ ክቕመጥ ምስ ዝግደድ ንመንበርን ናብ ገዛ ንዝግበር ጕዕዞታትን ዝወሃብ ሓገዝ።', '2026-08-28 17:30:50.657973+00'),
	('7f52d955-b694-4fbe-bb6f-336f1306c67d', 'ti', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'ባህላዊ ውርሻ ንምዕቃብ፣ ንምጥቃምን ንምምዕባልን ንዝሰርሓ ዘይመኽሰባውያን ውድባት ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('4ef05108-888d-451e-8e12-01ab2e2ecc67', 'ti', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'ንምምሕዳራዊን ከባብያዊን ፕሮጀክትታት ሓለዋ ተፈጥሮ፣ ማይ-ዘለዎም ቦታታትን ንደገ ዝግበር ምዝንጋዕን ሓዊሱ ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('083f7f1a-4e68-44de-96ba-f52af9e401d9', 'ti', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'ንህዝባዊን ናይ ቤት-ትምህርትን ኣብያተ-መጻሕፍቲ መጻሕፍቲ ንምዕዳግ ንምምሕዳራት ከተማ ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('1e09d2fc-a05a-48d5-923b-37297a96dbc8', 'ti', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'ተምሃሮ መባእታ ምስ ሞያዊ ባህሊ ንኽራኸቡ ንሓለፍቲ ኣብያተ-ትምህርቲ ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('d8593fc4-b95c-4d11-9b8c-d2f2e75b7612', 'ti', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'ውሉድካ ዘድልዮ ግን ቁጠባ ስድራ ዘይኣኽሎ ነገራት ዝወሃብ ሓገዝ፦ ናይ ትርፊ ግዜ ንጥፈታት፣ ክዳውንቲ፣ ናይ ቤት-ትምህርቲ ዙረታት፣ መነጽር፣ ናይ ዕረፍቲ ንጥፈታትን ካልእን።', '2026-08-28 17:30:50.657973+00'),
	('d7b7fe42-d3df-4ba7-a7cd-3be6ffa55088', 'ti', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'ካብ Världens Barn፣ Musikhjälpen ከምኡውን Victoriafonden ዝኣመሰሉ ፈንድታት ዝወሃቡ ሓገዛት — 90-konto ዘለወን ሽወደናውያን ዘይመኽሰባውያን ውድባት ይሓትታኦም።', '2026-08-28 17:30:50.657973+00'),
	('995d44f7-7427-414a-8e11-5e0ed824d1ad', 'ti', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'ነቲ ከባቢ ዘማዕብሉ ፕሮጀክትታት ካብ ገንዘብ ሓይሊ ማይን ንፋስን ዝወሃቡ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('1cdf6762-bbee-4e59-af0b-936a64a56553', 'ti', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'ሓጺር ትምህርቲ ንዘለዎም ስራሕ-ኣልቦ 25–60 ዓመት ኣብ ደረጃ መባእታ ወይ ካልኣይ ደረጃ ክመሃሩ ዘድልዮም ብዘይ ልቓሕ ዝወሃብ ሓገዝ።', '2026-08-28 17:30:50.657973+00'),
	('1e9bc120-ca2e-433d-8ed9-87bc7595d7f3', 'ti', 'Bidrar projektet till energiomställningen?', 'እቲ ፕሮጀክት ኣብ ምስግጋር ጸዓት ኣበርክቶ ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('0d3a56ba-e6cb-4c20-be04-6d117b395baa', 'ti', 'Bor du och barnets andra förälder på skilda håll?', 'ንስኻን እቲ ካልእ ወላዲ እቲ ቆልዓን ተፈላሊኹም ዲኹም ትነብሩ?', '2026-08-28 17:30:50.657973+00'),
	('1e13a155-282f-4759-b8fa-6434502e7d88', 'ti', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'ንንኣሽቱ ትካላት ኣብ ኣህጉራውነት ወይ ዲጂታላዊ ምቕያር ናይ ወጻኢ ክእለት ንምእታው ዝወሃቡ ቸካት።', '2026-08-28 17:30:50.657973+00');
INSERT INTO public.kb_translations VALUES
	('0c75a227-928e-4961-a4ff-43cc434da444', 'ti', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'ኣብ Arbetsförmedlingen ኣብ ዝካየድ መደብ ትሳተፍ ዲኻ (ንኣብነት jobb- och utvecklingsgarantin)?', '2026-08-28 17:30:50.657973+00'),
	('24b67b34-dc45-4c44-b2ad-61fac0a4a4db', 'ti', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'ብሉጽ ስነ-ጽሑፍ ንዘሕትሙ ኣሕተምቲ ድሕሪ ሕትመት ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('39aaf79f-a9ff-441a-a9fd-462f520686a3', 'ti', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'ምስ ዑቕባ ዝተኣሳሰር ናይ መንበሪ ፍቓድ ዘለዎም እሞ ብወለንታ ናብ ሃገሮም ንሓዋሩ ክምለሱ ዝደልዩ ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('fd48b0b0-e3ae-484e-a488-2f0ad2dab295', 'ti', 'Kommer projektet människor i ert närområde till del?', 'እቲ ፕሮጀክት ንህዝቢ ከባቢኹም ይጠቅም ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('dd4e2335-d600-4ef0-becb-0b7c886ce2c9', 'ti', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'ካብ ናብራ ስራሕ ንነዊሕ ግዜ ርሒቑ ንዝጸንሐ ሰብ ንዝቖጽሩ ኣስራሕቲ ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('231355d5-a914-45c9-aa69-713c1de2dae2', 'ti', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'ናይ ገዛእ ርእሶም ትካል ንዝጅምሩ ደለይቲ ስራሕ ኣብ እዋን ምጅማር ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('6e113ce3-9972-437c-8761-97929342e9fc', 'ti', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten ኣብ ምርምር ጸዓት፣ ምህዞን ብቕዓት ጸዓትን ቀጻሊ ጻውዒታት ትኸፍት።', '2026-08-28 17:30:50.657973+00'),
	('94cb047c-6f89-4159-9f02-da7289449709', 'ti', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'ንምክንኻን ቆልዓ ካብ ስራሕ ወይ ትምህርቲ ንምቁጣብ ዝወሃብ ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('7b3d969a-cb5d-41f9-919e-8b892053d39d', 'ti', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'ኣብ ሽወደን ሓድሽ ኮይኑ ኣብ ናይ Arbetsförmedlingen መደብ ምስፋር ንዝሳተፍ ዝወሃብ ክፍሊት፤ Försäkringskassan እያ ትኸፍሎ።', '2026-08-28 17:30:50.657973+00'),
	('4fd1813f-a5c2-4de1-b452-c29dd7f6c15f', 'ti', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'ውሉድ ዘይብሎም ትሑት ኣታዊ ዘለዎም መንእሰያት ክፋል ወጻኢታት መንበሪ ዝሽፍን ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('c9f3b517-c450-4cb6-b47f-a78106e3c013', 'ti', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'ቀዋሚ ስንክልና ዘምጽኦም ተወሰኽቲ ወጻኢታት ዝሽፍን ክፍሊት — ንዓበይቲ፣ ወይ ንወለዲ ስንክልና ዘለዎም ቆልዑ።', '2026-08-28 17:30:50.657973+00'),
	('da00a260-cf5f-4bfd-b681-de8d8e4daf38', 'ti', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'ብሰንኪ ሕማም ወይ ስንክልና እንተ ወሓደ ንሓደ ዓመት ምሉእ ግዜ ክሰርሑ ዘይክእሉ መንእሰያት (19–29 ዓመት) ዝወሃብ ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('7e38aadf-3dd9-460c-b19a-eb8ae30e163c', 'ti', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'ናይ ስራሕ ዓቕሚ ብቐዋሚ ምስ ዝጐድል ዝወሃብ ክፍሊት — ቅድም förtidspension (ናይ ኣቐዲሙ ጡረታ) ዝበሃል ዝነበረ።', '2026-08-28 17:30:50.657973+00'),
	('1fd56824-fbbf-442c-aeed-c5be66f300af', 'ti', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'ብጽኑዕ ዝሓመመ ቀረባ ሰብ ኣብ ጐድኑ ንምህላው ካብ ስራሕ ምስ እትቑጠብ ዝወሃብ ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('309a09e6-b96b-4bc4-922c-50c2123f64d3', 'ti', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'ኣብ ናይ Arbetsförmedlingen ናይ ዕዳጋ ስራሕ መደብ ምስ እትሳተፍ ዝወሃብ ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('0a5d4dc6-c65d-4e1c-9c9c-556a1a1294f6', 'ti', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'ብሰንኪ ሕማም ከም ልማድ ክትሰርሕ ምስ ዘይትኽእል ዝወሃብ ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('da3974eb-e6f4-4cd8-996b-4129db62fff8', 'ti', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'ሕሙም ቆልዓ ንምክንኻን ካብ ስራሕ ኣብ ገዛ ምስ እትተርፍ ዝወሃብ ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('affeca66-f08f-44eb-959a-075a4c527e3a', 'ti', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'ቆልዑ ዘለዎምን ትሑት ኣታዊ ዘለዎምን ስድራቤታት ክፋል ወጻኢታት መንበሪ ዝሽፍን ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('1e3b57d3-5c98-4aab-8dd1-8f241c747ab6', 'ti', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'ደቆም ብሰንኪ ስንክልና ካብ መዛኖኦም ንላዕሊ ክንክንን ቁጽጽርን ንዘድልዮም ወለዲ ዝወሃብ ክፍሊት።', '2026-08-28 17:30:50.657973+00'),
	('646705bf-018c-41fc-b604-d7f55dc244c4', 'ti', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'ኣብ እዋን ስራሕ-ኣልቦነት ዝወሃብ ክፍሊት — ንኣባላት ኣብ ኣታዊ ዝተመስረተ፣ ንኻልኦት መሰረታዊ መጠን።', '2026-08-28 17:30:50.657973+00'),
	('76707c18-9048-4909-8536-9b95f792e4d7', 'ti', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'ኣስታት ሓምሳ ናይ ዕቋር ባንክታት ትካላት ኣብ ስፖርት፣ ባህሊ፣ ትምህርትን ማሕበራዊ ምዕባለን ንዝካየዱ ከባብያውያን ፕሮጀክትታት ሓገዛት ይህባ — ኣብ ናይቲ ባንክ ናይ ስራሕ ከባቢ።', '2026-08-28 17:30:50.657973+00'),
	('d608eda1-7141-40b8-b853-5a6d07fb6580', 'ti', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'ብ EU ዝምወል ናይ ፕሮጀክት ደገፍ ኣብ ከባቢኻ ዘሎ ናይ Leader ዞባ ዝሕተት — ንማሕበራት፣ ትካላትን ምምሕዳራት ከተማን ገጠር ዘማዕብላ።', '2026-08-28 17:30:50.657973+00'),
	('1e1799e1-30e0-4e38-ab96-2220c099841a', 'ti', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'ኣብ ካልእ ሃገር EU/EES ስራሕ ንዝሕዙ ደለይቲ ስራሕ ብ EU ዝምወል ደገፍ፦ ናይ ቃለ-መሕትት ጕዕዞ፣ ወጻኢታት ምግዓዝን ትምህርቲ ቋንቋን ዝሽፍን።', '2026-08-28 17:30:50.657973+00'),
	('b0452e39-3462-4490-812d-4fc04203bc5c', 'ti', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'ክእለት፣ ምስግጋርን ኣብ ዕዳጋ ስራሕ ምስታፍን ንዘደልድሉ ፕሮጀክትታት ካብ ማሕበራዊ ፈንድ EU ዝወሃብ ገንዘብ።', '2026-08-28 17:30:50.657973+00'),
	('b3b28983-4d2b-40f4-81f4-1d81d9259c6c', 'ti', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'ንጕጅለኣዊ ምልውዋጣት መንእሰያት 13–30 ዓመት፣ ብዘይ መዓልታት ጕዕዞ 5–21 መዓልታት ዝጸንሕ ናይ EU ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('0c61c1b8-abfa-4025-bb79-6f2a77700ac8', 'ti', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'ባህላውያን ውድባት ምስ መሻርኽቲ ኣብ ብዙሓት ሃገራት ኤውሮጳ ንዘካይድኦም ፕሮጀክትታት ምትሕብባር ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('5325fa3a-4c60-4105-a24c-18cfb356d70b', 'ti', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'መንእሰያት ወለንተኛታት 18–30 ዓመት ንዝቕበላ ወይ ንዝልእኻ ውድባት ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('08e497f7-df05-4151-a4d3-628a47178edc', 'ti', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'ኣብ ቤት-ትምህርትን ትምህርቲ ዓበይትን ንምንቅስቓስ ሰራሕተኛታትን ተምሃሮን ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('9fa01387-f5eb-4bbc-aea4-c066cad37c35', 'ti', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'ንንኣሽቱ ውድባት ናይ መጀመርታ ኤውሮጳዊ ፕሮጀክትታት ምትሕብባር ብቑርጺ መጠን ዝወሃብ ናይ EU ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('ac60eacf-b022-4775-8330-e862d546cf78', 'ti', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'ኣህጉራዊ ተኽእሎ ዘለዎም ሓደስቲ ፍርያት ወይ ኣገልግሎታት ንዘማዕብላ መንእሰያት ትካላት ዝወሃብ ምወላ።', '2026-08-28 17:30:50.657973+00'),
	('c98939bf-27d9-4d07-a24a-df8ad0de863d', 'ti', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'ኣብቲ ንጥፈትኩም እትገብሩሉ ቦታ ናይ ዕቋር ባንክ (ስለዚ ድማ ትካል ዕቋር ባንክ) ኣሎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('8ecc6b62-50c4-4761-808c-34339f84182e', 'ti', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'ኣብ ሳዕስዒት፣ ትያትርን ሙዚቃዊ ትያትርን ንዝነጥፋ ሞያውያን ናጻ ጕጅለታት ናይ ብዙሕ ዓመታት ናይ ስራሕ ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('2a68d6ea-d806-46a1-aee7-004f0e081648', 'ti', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'ኣብ ናይ Forte ዓውድታት ዝወሃቡ ናይ ምርምር ሓገዛት፦ ጥዕና፣ ናብራ ስራሕን ድሕነትን። ኣብ ሽወደናውያን ላዕለዎት ትካላት ትምህርቲ ዶክትረይት ዘለዎም ተመራመርቲ ይሓትዎም።', '2026-08-28 17:30:50.657973+00'),
	('ada22470-6a67-4770-8723-3fef1422263a', 'ti', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'ኣብ ኩሎም ዓውድታት ስነ-ፍልጠት ንናጻ መሰረታዊ ምርምር ዝወሃብ ናይ ምርምር ገንዘብ።', '2026-08-28 17:30:50.657973+00'),
	('10797ec3-109e-4800-8f3c-2e205d240c65', 'ti', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'ኣብ ከባቢ፣ ሕርሻዊ ስነ-ፍልጠታትን ህንጸት ከተማን ዝወሃብ ናይ ምርምር ገንዘብ።', '2026-08-28 17:30:50.657973+00'),
	('99b0207a-91d2-417a-8ed9-b84ad7c44c1f', 'ti', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'ናብ ወጻኢ ክትግዕዝ ትሓስብ ዲኻ (ንስራሕ፣ ንትምህርቲ ወይ ንምምላስ ናብ ዓዲ)?', '2026-08-28 17:30:50.657973+00'),
	('5e71756b-ccb2-47b5-a38d-366f3cc2c40c', 'ti', 'Genomförs insatserna av professionella kulturaktörer?', 'እቶም ንጥፈታት ብሞያውያን ባህላውያን ተዋሳእቲ ድዮም ዝፍጸሙ?', '2026-08-28 17:30:50.657973+00'),
	('6ccf148f-e108-43c5-b862-39ad6fb7745b', 'ti', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'እቲ ፕሮጀክት ኣብ ገጠር ወይ ኣብ ንእሽቶ ከተማ ድዩ ዝካየድ?', '2026-08-28 17:30:50.657973+00'),
	('4eebd21f-49d8-446f-9a15-155a749226ed', 'ti', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'ኣብ ህይወቶም ትሑት ወይ ዜብሉ ናይ ስራሕ ኣታዊ ንዝነበሮም መሰረታዊ ውሕስነት።', '2026-08-28 17:30:50.657973+00'),
	('69143b9c-3fb4-4b81-9c87-d2ad94ad873b', 'ti', 'Går något av dina barn i grundskolan?', 'ካብ ደቅኻ ኣብ መባእታ ቤት-ትምህርቲ ዝመሃር ኣሎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('aeedcfb0-b341-4681-adb0-a22b19b8b570', 'ti', 'Går något av dina barn på gymnasiet?', 'ካብ ደቅኻ ኣብ ካልኣይ ደረጃ ዝመሃር ኣሎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('d7650599-3356-4444-ae48-59243bf6381f', 'ti', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'እቲ ቁጻር ንዝጐደለ ናይ ስራሕ ዓቕሚ ዘለዎ ሰብ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('d7407b13-6098-41d7-ab41-6866301fc262', 'ti', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'እቲ ቁጻር ንነዊሕ ግዜ ስራሕ-ኣልቦ ንዝነበረ ወይ ኣብ ሽወደን ሓድሽ ንዝኾነ ሰብ ድዩ ዝምልከት?', '2026-08-28 17:30:50.657973+00'),
	('c13c17e7-5076-4cde-a760-e594574950be', 'ti', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'እቲ ፕሮጀክት ብዛዕባ ምዕቃብ ወይ ምብጻሕ ባህላዊ ውርሻ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('f07c6d0e-6dc5-46b4-ba59-38bf3d06c5b9', 'ti', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'እቲ ፕሮጀክት ብዛዕባ ጸዓት፣ ብቕዓት ጸዓት ወይ ምስ ጸዓት ዝተኣሳሰር ምህዞ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('e6efe6ae-5984-418b-af75-8ead01f7a2b5', 'ti', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'እቲ ፕሮጀክት ብዛዕባ ጥዕና፣ ናብራ ስራሕ ወይ ድሕነት ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('5620bda2-3fc0-4231-9521-03fedb8ea7e0', 'ti', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'እቲ ፕሮጀክት ብዛዕባ ምምዕባል ክእለት ወይ ስጉምትታት ዕዳጋ ስራሕ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('d5536da9-393d-423e-95f0-e2ad16bda3f2', 'ti', 'Handlar projektet om miljö- eller klimatåtgärder?', 'እቲ ፕሮጀክት ብዛዕባ ከባብያዊ ወይ ክሊማዊ ስጉምትታት ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('755f8947-8a50-4260-a67d-ff5cb56f2f2d', 'ti', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'እቲ ቆልዓ ናብ ቤት-ትምህርቲ ነዊሕ፣ ብትራፊክ ሓደገኛ ወይ ብኻልእ መገዲ ኣጸጋሚ መገዲ ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('1b230a6d-a883-402f-b927-59ebcc2e6246', 'ti', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'እንተ ወሓደ 16 ሰዓታት ኣብ ሰሙን፣ ብድምር እንተ ወሓደ 8 ዓመታት ሰሪሕካ ዲኻ?', '2026-08-28 17:30:50.657973+00');
INSERT INTO public.kb_translations VALUES
	('e67a29e4-ba68-4587-97e1-98c416b2b986', 'ti', 'Har du barn som bor hos dig, helt eller växelvis?', 'ምሳኻ ዝነብሩ ቆልዑ ኣለዉኻ ድዮም፣ ምሉእ ብምሉእ ወይ ብተመላላሲ?', '2026-08-28 17:30:50.657973+00'),
	('75e50c56-18a0-4cde-af26-8d933f5cccd7', 'ti', 'Har du barn som bor hos dig?', 'ምሳኻ ዝነብሩ ቆልዑ ኣለዉኻ ድዮም?', '2026-08-28 17:30:50.657973+00'),
	('e58d6dcf-2f3b-4d81-bbeb-61e4a100dfd1', 'ti', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'ንስኻ ወይ ውሉድካ እንተ ወሓደ ሓደ ዓመት ክጸንሕ ትጽቢት ዝግበረሉ ስንክልና ኣለኩም ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('014c8f14-5182-41f9-880f-71195585a9ba', 'ti', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'ንስኻ ወይ ሓደ ካብ ስድራቤት ኣብ መንበሪ ጽልዋ ዘለዎ ቀዋሚ ስንክልና ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('d76e0b29-9755-42f7-a2c4-9f713afb5bbe', 'ti', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'ንስኻ ወይ ቀረባ ዘመድ ስንክልና ወይ ነዊሕ ዝጸንሐ ወይ ከቢድ ሕማም ኣለኩም ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('feb574db-1d7e-440d-b177-d4ebf130cf63', 'ti', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'ሕጂ ናይ ስራሕ ዓቕምኻ ዘጕድል ሕማም ወይ ጉድኣት ኣለካ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('2b98da3c-a1bf-48dc-8840-1394147c1cf3', 'ti', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'ውሉድካ ክሳተፎ ትጽቢት ዝግበረሉ ናይ ቤት-ትምህርቲ ዙረት፣ ናይ ክፍሊ ጕዕዞ ወይ ናይ ትርፊ ግዜ ንጥፈት ንምኽፋል ተጸጊምካ ትፈልጥ ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('a53bc1b6-38ee-450c-865e-a235ce24ab75', 'ti', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'ብጡረታኻን ካልእ ኣታዊኻን ምንባር የጸግመካ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('713b0bff-ca81-433a-a533-270bd68e7cc7', 'ti', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'ኣብ ዝሓለፉ ዓመታት ኣብ ሽወደን ናይ መንበሪ ፍቓድ ረኺብካ ዲኻ፣ ንኣብነት ከም ዑቕባ ዘድልዮ ወይ ከም ኣባል ስድራ?', '2026-08-28 17:30:50.657973+00'),
	('94fb5e68-6a33-4495-b248-8b4a76a43207', 'ti', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'ከም ስደተኛ ወይ ዑቕባ ዘድልዮ ሰብ ኣብ ሽወደን ናይ መንበሪ ፍቓድ ኣለካ ድዩ (ወይ ከምኡ ዘለዎ ሰብ ቀረባ ዘመድ ዲኻ)?', '2026-08-28 17:30:50.657973+00'),
	('3f57a7da-c5ac-44db-b245-68c239c57588', 'ti', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'ናይ ጡረታ መወከሲ ዕድመ (67 ዓመት ኣብ 2026) በጺሕካ ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('c31f5a21-232d-4158-938a-ba87637195b7', 'ti', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'ውድብኩም ኣብ ናይ EU Organisation Registration System ዝተመዝገበ OID (Organisation ID) ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('25a738e5-7916-4d56-a85f-2eaa01b5e457', 'ti', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'እቲ ስንክልና ተወሰኽቲ ወጻኢታት ኣምጺኡ ድዩ — ንኣብነት መሳርሒታት፣ ጕዕዞታት፣ ፍሉይ መግቢ ወይ ምብልሻው?', '2026-08-28 17:30:50.657973+00'),
	('3630fa05-7e21-4e47-9682-68d392ec3110', 'ti', 'Har föreningen antagna stadgar och en vald styrelse?', 'እቲ ማሕበር ዝጸደቐ ሕገ-ደንብን ዝተመርጸ ኣመራርሓን ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('93db1c03-80f1-4c7c-9dd6-08173ac604f5', 'ti', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'እቲ ማሕበር ዲሞክራስያዊ ኣቃውማ ኣለዎ ድዩ (ሕገ-ደንቢ፣ ዓመታዊ ኣኼባ፣ ኣመራርሓ)?', '2026-08-28 17:30:50.657973+00'),
	('b6e89ad8-efd6-49bc-b08d-bb296e06011e', 'ti', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'እቲ ማሕበር ንቆልዑ ወይ መንእሰያት ስሩዕ ንጥፈታት ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('ba0cb867-6b60-46bc-aac3-5aa02347a3e4', 'ti', 'Har företaget mellan cirka 2 och 49 anställda?', 'እታ ትካል ኣስታት ካብ 2 ክሳብ 49 ሰራሕተኛታት ኣለዉዋ ድዮም?', '2026-08-28 17:30:50.657973+00'),
	('a13c7afb-43b5-4a59-a919-fe19624860cd', 'ti', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'እታ ስድራቤት ወጻኢታት መግቢ፣ መንበርን እቲ ኣዝዩ ኣድላዪን ንምሽፋን ትጽገም ድያ?', '2026-08-28 17:30:50.657973+00'),
	('d034e803-b1d9-4fa3-8fb1-81a5b4803e49', 'ti', 'Har lösningen internationell potential?', 'እቲ ፍታሕ ኣህጉራዊ ተኽእሎ ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('874391d2-fae5-41ac-bf74-748a00a931be', 'ti', 'Har ni en partnergrupp i ett annat land?', 'ኣብ ካልእ ሃገር መሻርኽቲ ጕጅለ ኣለኩም ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('bb006b18-4146-4c85-b015-15fdaf75c795', 'ti', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'ኣብ ካልእ ሃገር ኤውሮጳ መሻርኽቲ ውድብ ኣለኩም ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('f23f7ff1-25dc-4f36-9f8e-5989ef8d76c9', 'ti', 'Har ni partner i minst tre olika europeiska länder?', 'እንተ ወሓደ ኣብ ሰለስተ ዝተፈላለያ ሃገራት ኤውሮጳ መሻርኽቲ ኣለዉኹም ድዮም?', '2026-08-28 17:30:50.657973+00'),
	('ae153b72-ac80-43ca-b093-90d72a0ddf63', 'ti', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'መቐመጢኹም ወይ ቀንዲ ንጥፈትኩም ኣብቲ እትሓቱሉ ዞባ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('7a11a2bc-e8c4-47fa-8d7a-eb838c16b47a', 'ti', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'ካብ ደቅኻ ብሰንኪ ስንክልና ካብ መዛኖኡ ንላዕሊ ክንክን ወይ ቁጽጽር ዘድልዮ ኣሎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('ac33ce1d-f679-44b0-be9a-67ddb9453364', 'ti', 'Har organisationen en demokratisk uppbyggnad?', 'እቲ ውድብ ዲሞክራስያዊ ኣቃውማ ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('3e0d4412-5f0d-4324-ba54-09e276be0c14', 'ti', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'እቲ ውድብ Quality Label (ምልክት ብቕዓት) ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('d59433da-2b1e-4f8c-a131-272e4b239972', 'ti', 'Har organisationen ett 90-konto?', 'እቲ ውድብ 90-konto ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('a4e966f5-a8b9-46cc-beba-0ef425bc5bbc', 'ti', 'Har organisationen ett OID (Organisation ID)?', 'እቲ ውድብ OID (Organisation ID) ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('87dfeed7-c276-40bc-9d76-3537ce0133d0', 'ti', 'Har organisationen ett OID?', 'እቲ ውድብ OID ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('1a8c97ba-f59c-49c7-a816-f1d1d5f6d817', 'ti', 'Har organisationen medlemsföreningar i flera län?', 'እቲ ውድብ ኣብ ብዙሓት ዞባታት ኣባላት ማሕበራት ኣለዉዎ ድዮም?', '2026-08-28 17:30:50.657973+00'),
	('ce51a52e-954e-42c0-a76e-118403b6f2cd', 'ti', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'እቲ ውድብ ስሩዕ ቁጠባን ዲሞክራስያዊ ኣቃውማን ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('455907c4-4023-4c24-ae5c-7b936d6c2dd2', 'ti', 'Har projektet en partner i ett annat land?', 'እቲ ፕሮጀክት ኣብ ካልእ ሃገር መሻርኽቲ ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('50f22cfe-6a95-4105-9f37-93def1abf365', 'ti', 'Har projektledaren doktorsexamen?', 'እቲ መራሒ ፕሮጀክት ዶክትረይት ኣለዎ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('4929989a-4db0-45b9-a36d-ce9886945e05', 'ti', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'እቲ መገዲ እንተ ወሓደ ሽዱሽተ ኪሎሜተር ምስ ዝኸውን፣ ምምሕዳር ከተማኻ ኣብ መንጎ ገዛን ካልኣይ ደረጃ ቤት-ትምህርትን ዕለታዊ ጕዕዞ ከቕርብ ኣለዎ (ንኣብነት ናይ ኣውቶቡስ ካርድ)።', '2026-08-28 17:30:50.657973+00'),
	('cc91f826-b48d-453f-b641-46b8ca665d98', 'ti', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'ኣብ ሽወደን ናይ መጀመርታ ናይ ገዛእ ርእስኻ ገዛ ትረክብ ወይ ተዳሉ ኣለኻ ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('556d6a2a-676a-42e4-a727-d5300d8a76b6', 'ti', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'እቲ ፕሮጀክት ኣህጉራዊ ጕዕዞ ወይ ምልውዋጥ የጠቓልል ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('cd382d4d-a275-477f-8b1d-43df86f41bfe', 'ti', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'ኣብ ናይ ደገፍ ዞባታት ንዘለዋ ትካላት ንህንጻታት፣ ማሽናትን ስልጠናን ዝወሃብ ናይ ወፍሪ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('0bed22d5-7872-46fb-aeba-31cd4754661f', 'ti', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'ልቀት ጋዛት ግሪንሃውስ ንዘጕድሉ ስጉምትታት ዝወሃብ ናይ ወፍሪ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('0201c605-7afd-47e5-8aa4-2d612d76b351', 'ti', 'Kan projektets miljönytta mätas?', 'ከባብያዊ ጥቕሚ እቲ ፕሮጀክት ክዕቀን ይከኣል ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('371f5bd4-c902-4eea-b77d-bed21c3ca118', 'ti', 'Kan åtgärdens utsläppsminskning beräknas?', 'ምጕዳል ልቀት እቲ ስጉምቲ ክሕሰብ ይከኣል ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('5196c47e-0bb7-4b10-bb9a-a7ce7badb371', 'ti', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'እቲ ውድብ እቲ ደገፍ ክሳብ ዝኽፈል ወጻኢታት ክጻወር ይኽእል ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('6fef08a3-25c2-46cc-b5a0-e49049324b8b', 'ti', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'እቲ ተመኩሮ ኣብ ንጥፈትካ ኣብ ሽወደን ክውዕል ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('2cf168c3-7e5c-4992-8654-499956f8cbba', 'ti', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'ኣታዊ ነቲ ኣዝዩ ኣድላዪ ምስ ዘይኣክል ናይ ምምሕዳር ከተማ ናይ መወዳእታ ቁጠባዊ መከላኸሊ መርበብ።', '2026-08-28 17:30:50.657973+00'),
	('c2fadf1f-5593-4dd3-992e-e9cb94587878', 'ti', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'ናይ ምምሕዳራት ከተማ ናይ ገዛእ ርእሰን ደገፍ ንከባብያዊ ማሕበራት፦ ንነፍሲ ወከፍ ኣጋጣሚ ናይ ንጥፈት ደገፍ፣ ናይ ኣዳራሽ ሓገዝ፣ ናይ ምጅማር ሓገዝን ካልእን።', '2026-08-28 17:30:50.657973+00'),
	('d8f32125-c295-4c18-93ad-472100d00d09', 'ti', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'ኣብ ነዊሕ ርሕቀት፣ ሓደገኛ መገዲ ወይ ስንክልና ንተምሃሮ መባእታ ነጻ ናይ ቤት-ትምህርቲ መጓዓዝያ — ብሕጊ ትምህርቲ መሰል እዩ።', '2026-08-28 17:30:50.657973+00'),
	('f770fcbb-659d-476a-969f-67b2a67cfae0', 'ti', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'ንቆልዑን መንእሰያትን ብሕጊ ዝተደንገገ ናይ መነጽር ወይ ሌንስ ሓገዝ፤ መጠናትን ኣገባባትን በብዞባ ይፈላለ — ደረጃ ዞባኻ ኣረጋግጽ።', '2026-08-28 17:30:50.657973+00'),
	('7b174a89-f561-4545-97c1-1c9fb1b7e157', 'ti', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'እቲ ፕሮጀክት ብሓይሊ ማይ ወይ ንፋስ ኣብ ዝትንከፍ ከባቢ ድዩ ዘሎ?', '2026-08-28 17:30:50.657973+00'),
	('8cb77ad2-f4ed-49ad-baa3-1d34e16ef6cb', 'ti', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'እቲ ፕሮጀክት ኣብ ውሽጢ ከባቢ፣ ሕርሻዊ ስነ-ፍልጠታት ወይ ህንጸት ከተማ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('1df12625-f629-43fa-a518-bb8aea3a2a72', 'ti', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'እቲ ናይ ንጥፈት ቦታ ኣብ ናይ ደገፍ ዞባ A ወይ B ድዩ (ዓበይቲ ክፋላት Norrland ውሽጣዊ Svealandን)?', '2026-08-28 17:30:50.657973+00'),
	('26ea492c-bba2-435d-9a59-b810d8a6b089', 'ti', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'ኣብ ሽወደን ንመጀመርታ ገዛ እቲ ኣዝዩ ኣድላዪ ንምዕዳግ ዝወሃብ ልቓሕ — ኣቕሑ ገዛ፣ ናውቲ ገዛን ካልእ መሰረታዊ መሳርሕን።', '2026-08-28 17:30:50.657973+00');
INSERT INTO public.kb_translations VALUES
	('3654c8ce-c4c9-4810-a20f-c272fe280cd6', 'ti', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'እቲ ፕሮጀክት ናይ ኢንዱስትሪ ናይ መስርሕ ልቀታት የጕድል ድዩ ወይስ ኣሉታዊ ልቀታት ይፈጥር?', '2026-08-28 17:30:50.657973+00'),
	('1abb2acb-a1f9-405d-8032-2e216b891a5a', 'ti', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'ካብ ልደት ክሳብ 16 ዓመት ኣብ ሽወደን ንዝነብሩ ቆልዑ ወርሓዊ ሓገዝ።', '2026-08-28 17:30:50.657973+00'),
	('316a5a2f-6e64-4612-bf7e-ae2b349785d2', 'ti', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket ኣብ ዓውዲ ከባቢ ንውድባት፣ ትካላት፣ ማሕበራት፣ ህዝባዊ ጽላትን ውልቀሰባትን ሓገዛት ትህብ።', '2026-08-28 17:30:50.657973+00'),
	('94bb252d-4f51-43fb-9e01-0c4ca94550df', 'ti', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'ብወለንታ ናብ ሃገርካ ንሓዋሩ ክትምለስ ትውጥን ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('c214a98a-4eed-45bd-9c64-3c80a36d2213', 'ti', 'Planerar du att starta eget företag?', 'ናይ ገዛእ ርእስኻ ትካል ክትጅምር ትውጥን ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('cbc8e0d6-6256-40bd-bffe-fdb23ac789e1', 'ti', 'Planerar du att studera utomlands?', 'ኣብ ወጻኢ ክትመሃር ትውጥን ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('4f26a0df-df96-4058-ab2f-bb9cc4b5a067', 'ti', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'ኣብ ዕዳጋ ስራሕ ቦታኻ ዘደልድል ትምህርቲ ትውጥን ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('12f7a885-0af0-46e2-a60e-07d46915a1f9', 'ti', 'Planerar ni att anställa?', 'ክትቆጽሩ ትውጥኑ ዲኹም?', '2026-08-28 17:30:50.657973+00'),
	('a533f687-d1c8-4950-b42e-d640ac9e6e59', 'ti', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'ናይ EU መደብ (ንኣብነት Horisont Europa) ክትሓቱ ትውጥኑ ዲኹም?', '2026-08-28 17:30:50.657973+00'),
	('351f0c52-90c0-4153-877e-733493e1caf7', 'ti', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'ንሓጸርቲ ፊልምታትን ዶኩመንታሪታትን ናይ ፍርያትን ምዕባለን ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('7fe55fbd-8657-468a-a489-aec47fbed85a', 'ti', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'ንናጻ ሙዚቃዊ ህይወት ንኮንሰርታት፣ ፍርያትን ምዕባለን ዝወሃቡ ናይ ፕሮጀክት ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('54c28c22-3c10-496e-8b56-021ad4f92350', 'ti', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'ምስ ቆልዑን መንእሰያትን ንዓኦምን ንዝሰርሓ ዘይመኽሰባውያን ውድባት ዝወሃቡ ናይ ፕሮጀክት ሓገዛት።', '2026-08-28 17:30:50.657973+00'),
	('2da79aea-63f5-4968-afa4-9206920b5035', 'ti', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'እቲ ፕሮጀክት ሓደስቲ ስነ-ጥበባዊ መግለጺታት፣ ኣገባባት ወይ ምትሕብባራት ይፍትን ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('633568e0-cd18-4131-8e50-f277c4f60111', 'ti', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'እቲ ምልውዋጥ 5–21 መዓልታት (ብዘይ መዓልታት ጕዕዞ) ይጸንሕ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('dc8d16f5-c117-4c6c-b7d0-96b4a596577c', 'ti', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'ኣብ ጐድኒ ናይ Kulturrådet ሃገራውያን ሓገዛት፣ ናይ ዞባታት ናይ ገዛእ ርእሰን ናይ ፕሮጀክትን ስራሕን ደገፍ ንባህላዊ ህይወት።', '2026-08-28 17:30:50.657973+00'),
	('b1e90d40-f8e2-4de7-aa4c-8f1cbfe396e4', 'ti', 'Riktar sig projektet till barn eller unga?', 'እቲ ፕሮጀክት ንቆልዑ ወይ መንእሰያት ድዩ ዝዓለመ?', '2026-08-28 17:30:50.657973+00'),
	('ccc4edab-e00f-423b-ad88-def097d98ef4', 'ti', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'እቲ ፕሮጀክት ንቆልዑ፣ መንእሰያት፣ ኣረጋውያን ወይ ስንክልና ዘለዎም ሰባት ድዩ ዝዓለመ?', '2026-08-28 17:30:50.657973+00'),
	('b8a79f5a-fe4f-4a94-a6dd-2d9d28d53802', 'ti', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'እቲ ንጥፈት ንቆልዑን መንእሰያትን (7–25 ዓመት) ድዩ ዝዓለመ?', '2026-08-28 17:30:50.657973+00'),
	('9f38cca5-6e6a-47c0-b873-c891184b4d71', 'ti', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'ነቶም ወጻኢታት ክሽፍኑ ዝኽእሉ ዕቋር ወይ ንብረት የብልካን ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('a8162899-a7c3-45d9-a1e4-113d6a9128ed', 'ti', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'እንተ ወሓደ ምስ ክልተ ካልኦት ሰሜናውያን ሃገራት መሻርኽቲ ትተሓባበሩ ዲኹም?', '2026-08-28 17:30:50.657973+00'),
	('d3180cb6-232e-4355-b8ae-87d4d2888cc0', 'ti', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'ንናይ ምዕባለ ስጉምቲ ናይ ወጻኢ ክእለት ከተእትዉ ዲኹም?', '2026-08-28 17:30:50.657973+00'),
	('020b2d9d-e7a6-41f5-ac7b-44c35cecdf7a', 'ti', 'Sker mobiliteten till ett annat europeiskt land?', 'እቲ ምንቅስቓስ ናብ ካልእ ሃገር ኤውሮጳ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('09e59477-085b-4e98-9904-a66a8ae2a45c', 'ti', 'Startar du eller tar du över företaget för första gången?', 'ንመጀመርታ ግዜ ዲኻ እታ ትካል ትጅምር ወይ ትርከብ ዘለኻ?', '2026-08-28 17:30:50.657973+00'),
	('fcf9e083-09b6-4b40-a790-56f2766abf5f', 'ti', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', '40 ዓመት ወይ ካብኡ ንታሕቲ ኮይኑ ሕርሻዊ ትካል ንዝጅምር ወይ ንዝርከብ ዝወሃብ ናይ ምጅማር ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('802d1b4e-9fd5-456d-bef8-1a338cdc1af2', 'ti', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'ንሞያውያን ስነ-ጥበበኛታት ኣብ ስነ-ጥበባዊ ስራሖም ከተኵሩ ዘኽእል ስኮላርሺፕ።', '2026-08-28 17:30:50.657973+00'),
	('f0706444-14a9-4788-857a-4d42e89d8666', 'ti', 'Studerar du, eller planerar du att börja studera?', 'ትመሃር ኣለኻ ዲኻ፣ ወይስ ትምህርቲ ክትጅምር ትውጥን?', '2026-08-28 17:30:50.657973+00'),
	('548e9048-b2a5-4fe3-82a4-1469cbc8f5c4', 'ti', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'ኣብ ዕዳጋ ስራሕ ቦታኦም ንምድልዳል ክመሃሩ ንዝደልዩ ሰራሕተኛታት ዓበይቲ ዝወሃብ ናይ ትምህርቲ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('28e0dd4b-6267-4f35-b656-ad9e8ca6445c', 'ti', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'ኣብ ሕርሻውያን ትካላት ተወዳዳርነት ዘዕብዩ ወይ ከባብያዊ ጽልዋ ዘጕድሉ ወፍርታት ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('814edc94-0d7d-4e0f-a110-4e68a6d96c43', 'ti', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'ቆልዓ ምሳኻ ምስ ዝነብር እሞ እቲ ካልእ ወላዲ ቀለብ ምስ ዘይከፍል ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('0749ba1e-08d8-47d8-b7b3-e188b89c535a', 'ti', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'ንሰባት፣ ከባብን ዝሓሸ ዓለምን ንዝካየዱ ፕሮጀክትታት ዘይመኽሰባውያን ውድባት ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('36f6aa16-9239-4ad5-a5c0-2a38712d8eb0', 'ti', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'ናብ ዜሮ ልቀት ጋዛት ግሪንሃውስ ንዝግበር ምስግጋር ኢንዱስትሪ ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('dbaad5f6-d660-47ca-8dd0-94fae9ea05dc', 'ti', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'ሰሜናዊ መልክዕን ዶብ ሰጊሩ ዝግበር ምትሕብባርን ንዘለዎም ፕሮጀክትታት ስነ-ጥበብን ባህልን ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('b51b0feb-db2c-46bc-90ea-a49b94c46bcc', 'ti', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'ሓደስቲ ስነ-ጥበባዊ መግለጺታት፣ ኣገባባት ወይ ምትሕብባራት ንዝፍትኑ ሓደስቲ ባህላውያን ፕሮጀክትታት ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('9ee87233-117a-4dd5-9349-d69ee3d76262', 'ti', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'ንቆልዑ፣ መንእሰያት፣ ኣረጋውያንን ስንክልና ዘለዎም ሰባትን ንዝካየዱ ሓደስቲ ፕሮጀክትታት ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('06f48431-c502-451e-ae6d-dc7299f5e643', 'ti', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'ኣብ ናጻ ሙዚቃዊ ህይወት ንፕሮጀክትታት ምትሕብባር ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('57ba68ee-661b-4f99-adc8-a62b474d5aa2', 'ti', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'ዲሞክራስን ናጽነት ሓሳብን ብኣህጉራዊ ደረጃ ንዘደልድሉ ፕሮጀክትታት ምትሕብባር ኣብ ባህልን ሚድያን ዝወሃብ ደገፍ።', '2026-08-28 17:30:50.657973+00'),
	('5050010c-4911-4da8-91ba-38e63a976fa5', 'ti', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'እቲ ፕሮጀክት ዲሞክራሲ፣ ማዕርነት ወይ ናጽነት ሓሳብ ንምድልዳል ድዩ ዝዓለመ?', '2026-08-28 17:30:50.657973+00'),
	('b20f015f-0a44-4c21-82e5-baa5fd3a428d', 'ti', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'ኣብ ካልእ ሃገር EU ወይ EES ስራሕ ትደሊ ኣለኻ፣ ወይ ናይ ስራሕ ውዕል ተዋሂቡካ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('f509c787-7084-4db0-aa39-406a4e908627', 'ti', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'ኣብ ውሽጢ ዓሰርተ ክልተ ኣዋርሕ ብናይ ሕሙም ክፍሊታት እትኸፍሎ ጣርያ — ድሕሪኡ frikort (ነጻ ካርድ)።', '2026-08-28 17:30:50.657973+00'),
	('7694b1c6-c80a-45a2-902b-b7a0f685ef61', 'ti', 'Tar du ut hel allmän pension?', 'ምሉእ ሃገራዊ ጡረታኻ ትወስድ ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('6fe6728e-c4a3-4946-b419-46d9ee3185d5', 'ti', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'ጡረታን ትሑት ኣታውን ንዘለዎም ክፋል ወጻኢታት መንበሪ ዝሽፍን ተወሳኺ።', '2026-08-28 17:30:50.657973+00'),
	('4962aa11-5dee-4c38-9b3e-5f203e778033', 'ti', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'ንሃገራውያን ውድባት ቆልዑን መንእሰያትን ዓመታዊ ናይ ውድብ ሓገዝ።', '2026-08-28 17:30:50.657973+00'),
	('692b2a4d-6bbf-49fe-896e-65839ba678d0', 'ti', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'ኣብ ሓኪም ስኒ ወይ ክኢላ ጽሬት ስኒ ብቐጥታ ዝቕነስ ዓመታዊ ሕሳብ።', '2026-08-28 17:30:50.657973+00'),
	('ff3ebe1d-88c2-4ee2-b9b0-a0b360bb7284', 'ti', 'Är bolaget yngre än cirka 5 år?', 'እታ ትካል ካብ ኣስታት 5 ዓመት ንታሕቲ ድያ?', '2026-08-28 17:30:50.657973+00'),
	('3f739c74-833b-4394-8896-b1ffcb909ad2', 'ti', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'ተሳተፍቲ እቲ ምልውዋጥ ኣብ መንጎ 13ን 30ን ዓመት ድዮም?', '2026-08-28 17:30:50.657973+00'),
	('7df7d7ee-139e-4ddf-89f5-defc8c10b3fa', 'ti', 'Är det här ert första EU-projekt?', 'እዚ ናይ መጀመርታ ናይ EU ፕሮጀክትኩም ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('1ce954a4-87e1-4e53-9b0a-2d39245741fa', 'ti', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'ንዓኻ (ወይ ንውሉድካ) በይንኻ ምንቅስቓስ ወይ ብኣውቶቡስን ባቡርን ምጕዓዝ ኣዝዩ ኣጸጋሚ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('8b55c936-4834-4304-9dbd-60fcf61a7576', 'ti', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'ኣታዊኻ ካብ ኣስታት 25 000 kr ኣብ ወርሒ ቅድሚ ግብሪ ዝወሓደ ድዩ?', '2026-08-28 17:30:50.657973+00'),
	('355c0f41-e8b1-4b87-8409-949442c198fe', 'ti', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'ናይ መወዳእታ ዝወዳእካዮ ትምህርቲ መባእታ ድዩ፣ ወይስ ዘይወዳእካዮ ካልኣይ ደረጃ?', '2026-08-28 17:30:50.657973+00'),
	('d72dce2f-f63b-4cbb-a52f-8bb0c7d512f5', 'ti', 'Är du 40 år eller yngre?', '40 ዓመት ወይ ካብኡ ንታሕቲ ዲኻ?', '2026-08-28 17:30:50.657973+00');
INSERT INTO public.kb_translations VALUES
	('cb888967-6c47-4d59-b7aa-42e02895a689', 'ti', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'ኣብ Arbetsförmedlingen ከም ደላዪ ስራሕ ተመዝጊብካ ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('0743f8b2-5a37-4baa-838e-e2a7c57ad13c', 'ti', 'Är du mellan 18 och 28 år?', 'ኣብ መንጎ 18ን 28ን ዓመት ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('84b68ba2-dc59-4a36-98d3-67d59bfc9797', 'ti', 'Är du mellan 19 och 29 år?', 'ኣብ መንጎ 19ን 29ን ዓመት ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('23b809af-3d3f-46ff-aa50-a503f41170b4', 'ti', 'Är du mellan 25 och 60 år?', 'ኣብ መንጎ 25ን 60ን ዓመት ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('5d2d00db-fde1-49ab-8c56-ef666abe37de', 'ti', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'ኣብ ዓውዲ ባህሊ ብሞያ ትሰርሕ ዲኻ (ንኣብነት ሳዕስዒት፣ ሙዚቃ፣ ስነ-ጥበብ መድረኽ)?', '2026-08-28 17:30:50.657973+00'),
	('c42e1404-49d3-4e31-8296-6ddd8c332654', 'ti', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'ሞያዊ ስነ-ጥበበኛ ዲኻ (ዘይ ሃዋርያ ወይ ኣብ መሰረታዊ ስልጠና ዘሎ)?', '2026-08-28 17:30:50.657973+00'),
	('8566264a-8c60-4b19-8160-030cf596d20b', 'ti', 'Är du yrkesverksam konstnär?', 'ሞያዊ ስነ-ጥበበኛ ዲኻ?', '2026-08-28 17:30:50.657973+00'),
	('752fc79a-e3c7-4164-b8a7-71c2977afa31', 'ti', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'ፍታሕኩም ምስቲ ድሮ ዘሎ ክወዳደር ከሎ ብመሰረቱ ሓድሽ ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('b6616510-f610-43f2-98e8-f788a868729d', 'ti', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'እቲ ክለብ ኣብ ውሽጢ Riksidrottsförbundet ናብ ፍሉይ ስፖርታዊ ፌደሬሽን ዝተጸምበረ ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('cc5a706f-7472-467b-9a10-63639a044f2e', 'ti', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'ኣታዊ እታ ስድራቤት ምስ ወጻኢታት መንበሪ ክወዳደር ከሎ ትሑት ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('1ba93fe6-7fbe-47b5-9287-4c0750926c98', 'ti', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'ጠቕላላ ኣታዊ እታ ስድራቤት ካብ ኣስታት 25 000 kr ኣብ ወርሒ ቅድሚ ግብሪ ዝወሓደ ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('3521b3fa-b9ee-439f-ab7e-6477874fc5a6', 'ti', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'እቲ ስጉምቲ ዝተወሰነ ፕሮጀክት ድዩ (ዘይ ስሩዕ ንጥፈት)?', '2026-08-28 17:30:50.661678+00'),
	('4a4295c1-f8f5-4988-b8a3-593746464232', 'ti', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'እቲ ኣዳራሽ ንኹሉ ክፉት ድዩ — ዘይ ንኣባላትኩም ጥራይ?', '2026-08-28 17:30:50.661678+00'),
	('f0f58af8-fadd-46d8-baf1-72564c8d2cc2', 'ti', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'እንተ ወሓደ 60 % ካብቶም ኣባላት ኣብ መንጎ 6ን 25ን ዓመት ድዮም?', '2026-08-28 17:30:50.661678+00'),
	('ad5516fc-1b04-41d9-9660-dd0971dfa54f', 'ti', 'Är minst 60 % av medlemmarna under 26 år?', 'እንተ ወሓደ 60 % ካብቶም ኣባላት ትሕቲ 26 ዓመት ድዮም?', '2026-08-28 17:30:50.661678+00'),
	('a675d259-14b0-4149-b4d5-04df120b5983', 'ti', 'Är målgruppen delaktig i planering och genomförande?', 'እታ ዕላማ ዝኾነት ጕጅለ ኣብ ውጥንን ትግባረን ትሳተፍ ድያ?', '2026-08-28 17:30:50.661678+00'),
	('bc077035-8356-4488-af2b-b68a976ece9f', 'ti', 'Är ni ett förlag med professionell utgivning?', 'ሞያዊ ሕትመት ዘለዎ ኣሕታሚ ዲኹም?', '2026-08-28 17:30:50.661678+00'),
	('9c4c81b4-ddfc-477b-9c0b-9e8fb11bcc56', 'ti', 'Är ni huvudman för förskoleklass eller grundskola?', 'ሓላፊ ናይ ቅድመ-ትምህርቲ ክፍሊ ወይ መባእታ ቤት-ትምህርቲ ዲኹም?', '2026-08-28 17:30:50.661678+00'),
	('a2a84414-21c0-412a-8a68-ed9855782df9', 'ti', 'Är organisationen registrerad i EU:s deltagarregister?', 'እቲ ውድብ ኣብ ናይ EU መዝገብ ተሳተፍቲ ተመዝጊቡ ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('6f4a9828-7ea6-4a1c-b0de-d1d811ae2bfe', 'ti', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'እቲ ፕሮጀክት ናይ ፊልም ፕሮጀክት ድዩ (ሓጻር ፊልም ወይ ዶኩመንታሪ)?', '2026-08-28 17:30:50.661678+00'),
	('296f1f74-63ad-43cd-8812-a1f37aaf82f4', 'ti', 'Är projektet ett konst- eller kulturprojekt?', 'እቲ ፕሮጀክት ናይ ስነ-ጥበብ ወይ ባህሊ ፕሮጀክት ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('4c54ebf4-13c5-4570-b12b-0bac5f63d586', 'ti', 'Är projektet ett kulturprojekt?', 'እቲ ፕሮጀክት ባህላዊ ፕሮጀክት ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('9c6bae15-8989-463a-b1f1-e40c80ad368c', 'ti', 'Är projektet ett musikprojekt?', 'እቲ ፕሮጀክት ሙዚቃዊ ፕሮጀክት ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('110e26ea-adac-4db0-93a1-742a4ff238e2', 'ti', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'እቲ ፕሮጀክት ሓድሽ ድዩ — ኣብ ስሩዕ ንጥፈትኩም ዘይትገብርዎ ነገር?', '2026-08-28 17:30:50.661678+00'),
	('963cd30d-d5f5-4d09-90fa-ec20e3f2bbc4', 'ti', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'እቲ ፕሮጀክት ንብምሉኡ እቲ ከባቢ ይጠቅም ድዩ (ዘይ ንውልቀሰባት)?', '2026-08-28 17:30:50.661678+00'),
	('00bbe3c6-2be0-4523-b287-493dd060783c', 'ti', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'እቲ ኣብ መንጎ ገዛን ካልኣይ ደረጃ ቤት-ትምህርትን ዘሎ መገዲ እንተ ወሓደ ሽዱሽተ ኪሎሜተር ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('b87366a6-3e0c-46e8-aea3-a5f42422fe79', 'ti', 'Är verksamheten professionell (inte amatörverksamhet)?', 'እቲ ንጥፈት ሞያዊ ድዩ (ዘይ ናይ ሃዋርያ)?', '2026-08-28 17:30:50.661678+00'),
	('c1334249-d89a-465a-9fce-dbedf23c4cbf', 'ti', 'Är verksamheten professionell?', 'እቲ ንጥፈት ሞያዊ ድዩ?', '2026-08-28 17:30:50.661678+00'),
	('98e635ba-a6fa-4b2b-a9df-5534c56b5019', 'ti', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'እቲ ንጥፈት ስነ-ጥበብ መድረኽ ድዩ (ሳዕስዒት፣ ትያትር፣ ሙዚቃዊ ትያትር)?', '2026-08-28 17:30:50.661678+00'),
	('2b246901-0f32-4ffd-85e0-e2be93f6a874', 'ti', 'Är volontärerna mellan 18 och 30 år?', 'እቶም ወለንተኛታት ኣብ መንጎ 18ን 30ን ዓመት ድዮም?', '2026-08-28 17:30:50.661678+00');


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
	('391d6e31-657f-4aff-9472-01972ecdc466', '1ce740ab-9c27-4da7-94df-d3c8dff4006c', 1, '[{"id": "kr-rb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-rb-h2", "op": "in", "kind": "hard", "expected": ["individual", "association", "company"], "factPath": "applicant.type", "description": "Sökande ska vara yrkesverksam kulturskapare, grupp eller organisation"}, {"id": "kr-rb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam inom kulturområdet", "evidenceKinds": ["cv"], "intakeQuestion": "Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?"}, {"id": "kr-rb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska avse internationellt kulturutbyte", "evidenceKinds": ["invitation"], "intakeQuestion": "Innehåller projektet en internationell resa eller ett internationellt utbyte?"}, {"id": "kr-rb-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Kulturprojekt"}, {"id": "kr-rb-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}, {"id": "kr-rb-w3", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "project.bringsKnowledgeBack", "description": "Kunskapen tas tillvara i Sverige", "intakeQuestion": "Kommer erfarenheterna att användas i din verksamhet i Sverige?"}]', '[{"id": "kr-rb-b1", "type": "max_requested", "amountMinor": 5000000, "description": "Sökt belopp bör inte överstiga 50 000 kr för resebidrag."}]', '[{"id": "kr-rb-e1", "kind": "cv", "mandatory": true, "description": "CV eller konstnärlig meritförteckning"}, {"id": "kr-rb-e2", "kind": "invitation", "mandatory": true, "description": "Inbjudan eller bekräftelse från mottagande part"}, {"id": "kr-rb-e3", "kind": "budget", "mandatory": false, "description": "Resebudget"}]', '2026-08-28 17:30:49.839343+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.839343+00'),
	('a80bb618-8744-4e92-a1f4-32dbd788cf5c', '808c5f5b-7f8c-40c3-a1d8-5d5d77b2b575', 1, '[{"id": "er-yx-h1", "op": "in", "kind": "hard", "expected": ["association", "informal_group", "municipality"], "factPath": "applicant.type", "description": "Sökande ska vara en organisation eller informell ungdomsgrupp"}, {"id": "er-yx-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska nationella programkontoret"}, {"id": "er-yx-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge13to30", "description": "Deltagarna ska vara 13–30 år", "intakeQuestion": "Är deltagarna i utbytet mellan 13 och 30 år?"}, {"id": "er-yx-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.durationDays5to21", "description": "Utbytet ska vara 5–21 dagar exklusive resdagar", "intakeQuestion": "Pågår utbytet 5–21 dagar (exklusive resdagar)?"}, {"id": "er-yx-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partnergrupp i ett annat programland krävs", "intakeQuestion": "Har ni en partnergrupp i ett annat land?"}, {"id": "er-yx-m4", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID (Organisation ID)", "intakeQuestion": "Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?"}, {"id": "er-yx-w1", "op": "includes", "kind": "weighted", "weight": 3, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}, {"id": "er-yx-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training"], "factPath": "project.activityTypes", "description": "Utbytes-/lärandeaktiviteter"}, {"id": "er-yx-w3", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "er-yx-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från partnergrupp(er)"}, {"id": "er-yx-e2", "kind": "activity_programme", "mandatory": true, "description": "Aktivitetsprogram dag för dag"}, {"id": "er-yx-e3", "kind": "budget", "mandatory": false, "description": "Budget enligt programmets schabloner"}]', '2026-08-28 17:30:49.848425+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.848425+00'),
	('ef60e1a2-9fee-4c0c-a281-a3b8a4f56976', '8dae3789-436f-4689-999b-9297b43fad01', 1, '[{"id": "mucf-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara verksam i Sverige"}, {"id": "mucf-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska ha en demokratisk uppbyggnad", "intakeQuestion": "Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?"}, {"id": "mucf-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Projektet ska rikta sig till barn eller unga", "intakeQuestion": "Riktar sig projektet till barn eller unga?"}, {"id": "mucf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["youth", "civil_society", "culture"], "factPath": "project.sector", "description": "Verksamhet inom ungdoms-/civilsamhällesområdet"}, {"id": "mucf-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.youthMembersShareOver60", "description": "Hög andel unga medlemmar", "intakeQuestion": "Är minst 60 % av medlemmarna under 26 år?"}]', '[]', '[{"id": "mucf-e1", "kind": "stadgar", "mandatory": true, "description": "Föreningens stadgar"}, {"id": "mucf-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse och årsredovisning"}, {"id": "mucf-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 17:30:49.85596+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.85596+00'),
	('7ad6c192-fa6e-4215-aa61-4443b5ee74c2', '2fa40993-227e-4608-9b2a-9afbc271ccc1', 1, '[{"id": "vin-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett aktiebolag"}, {"id": "vin-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "vin-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.ageYearsMax5", "description": "Bolaget ska vara ungt (typiskt max ca 5 år — se aktuell utlysning)", "intakeQuestion": "Är bolaget yngre än cirka 5 år?"}, {"id": "vin-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isInnovative", "description": "Lösningen ska vara nyskapande jämfört med befintliga alternativ", "intakeQuestion": "Är er lösning väsentligt nyskapande jämfört med vad som redan finns?"}, {"id": "vin-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.scalableInternationally", "description": "Internationell skalbarhet", "intakeQuestion": "Har lösningen internationell potential?"}, {"id": "vin-w2", "op": "in", "kind": "weighted", "weight": 1, "expected": ["innovation", "technology", "energy", "health"], "factPath": "project.sector", "description": "Prioriterade områden"}]', '[{"id": "vin-b1", "type": "max_requested", "amountMinor": 30000000, "description": "Maximalt bidrag enligt programmets ramar (se aktuell utlysning)."}]', '[{"id": "vin-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "vin-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}, {"id": "vin-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelpersoner"}]', '2026-08-28 17:30:49.864867+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.864867+00'),
	('94062597-1ab1-4fad-ab4e-69048df9f39b', '095700f4-8d8e-4746-aa9d-cc7b393baa03', 1, '[{"id": "pm-afs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "pm-afs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-afs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Du ska ha uppnått riktåldern för pension (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}, {"id": "pm-afs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.veryLowOrNoPension", "description": "Pension och inkomster ska inte räcka till en skälig levnadsnivå", "intakeQuestion": "Har du svårt att klara dig på din pension och dina övriga inkomster?"}]', '[]', '[]', '2026-08-28 17:30:50.138134+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.138134+00'),
	('a8619d2e-f342-492e-99d9-fac95c4d4ebb', '655ce725-4921-4ead-8c71-a65db15d9bd3', 1, '[{"id": "em-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "em-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association", "economic_association"], "factPath": "applicant.type", "description": "Öppet för organisationer — inte privatpersoner"}, {"id": "em-m1", "op": "in", "kind": "mandatory", "expected": ["energy", "environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom energiområdet", "intakeQuestion": "Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?"}, {"id": "em-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.contributesToEnergyTransition", "description": "Bidrar till energiomställningen", "intakeQuestion": "Bidrar projektet till energiomställningen?"}]', '[]', '[{"id": "em-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "em-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget med kostnadskategorier"}]', '2026-08-28 17:30:49.872876+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.872876+00'),
	('32b03ab9-b148-46ee-8c66-253556eb97bc', 'e8f61700-5a3c-4b21-bdd5-ef341a30b736', 1, '[{"id": "nv-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "nv-m1", "op": "in", "kind": "mandatory", "expected": ["environment", "energy"], "factPath": "project.sector", "description": "Projektet ska avse miljö- eller klimatåtgärder", "intakeQuestion": "Handlar projektet om miljö- eller klimatåtgärder?"}, {"id": "nv-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.measurableEnvironmentalImpact", "description": "Mätbar miljönytta", "intakeQuestion": "Kan projektets miljönytta mätas?"}]', '[{"id": "nv-b1", "type": "max_funding_share", "percent": 50, "description": "Många av bidragen täcker upp till 50 % av kostnaden — se aktuellt bidrag."}]', '[{"id": "nv-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av åtgärden"}]', '2026-08-28 17:30:49.883745+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.883745+00'),
	('1ebf7e25-0c6d-48f5-bec5-f40f26510f1f', '341416fd-513a-4d90-98fc-622dac87253a', 1, '[{"id": "kr-pm-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-pm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell verksamhet inom musikområdet", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-pm-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kr-pm-w1", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["performance", "production"], "factPath": "project.activityTypes", "description": "Konsert-/produktionsverksamhet"}]', '[]', '[{"id": "kr-pm-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kr-pm-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 17:30:49.890972+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.890972+00'),
	('e83c35df-90d1-4923-889a-99f8caaa4c4d', '7a5794e7-0ad6-4820-a360-76fad5023a76', 1, '[{"id": "kn-iku-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av enskilda yrkesverksamma konstnärer"}, {"id": "kn-iku-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-iku-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?"}, {"id": "kn-iku-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Ansökan ska avse internationellt utbyte eller resa", "evidenceKinds": ["invitation"], "intakeQuestion": "Avser ansökan en internationell resa eller ett internationellt utbyte?"}, {"id": "kn-iku-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Konstnärligt projekt"}, {"id": "kn-iku-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}]', '[]', '[{"id": "kn-iku-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-iku-e2", "kind": "invitation", "mandatory": false, "description": "Inbjudan eller beskrivning av samarbetet"}]', '2026-08-28 17:30:49.8988+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.8988+00'),
	('1b09dd7b-49be-4060-a58f-e2b75dc171a0', '2c0487d4-d4bb-497d-afc6-578c035fe7d2', 1, '[{"id": "kn-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stipendiet söks av enskilda konstnärer"}, {"id": "kn-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär?"}, {"id": "kn-as-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "culture", "factPath": "project.sector", "description": "Konstnärlig verksamhet"}]', '[]', '[{"id": "kn-as-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-as-e2", "kind": "project_description", "mandatory": true, "description": "Beskrivning av konstnärlig verksamhet och planer"}]', '2026-08-28 17:30:49.907417+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.907417+00'),
	('2f3eca3b-77c1-46cd-83a2-8464309eb655', '0ecc6405-02b4-4dd6-8c73-c19a09591ebf', 1, '[{"id": "af-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara en ideell organisation"}, {"id": "af-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "af-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.targetsArvsfondenGroups", "description": "Målgruppen ska vara barn, unga, äldre eller personer med funktionsnedsättning", "intakeQuestion": "Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?"}, {"id": "af-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande i förhållande till ordinarie verksamhet", "intakeQuestion": "Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?"}, {"id": "af-ps-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.targetGroupParticipates", "description": "Målgruppen ska vara delaktig i projektet", "intakeQuestion": "Är målgruppen delaktig i planering och genomförande?"}, {"id": "af-ps-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga som målgrupp"}, {"id": "af-ps-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.democraticStructure", "description": "Demokratiskt uppbyggd organisation", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}]', '[]', '[{"id": "af-ps-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "af-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning/verksamhetsberättelse"}, {"id": "af-ps-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 17:30:49.915625+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.915625+00'),
	('6bee3b2f-72c3-4593-a3cb-cf84eee988da', '58a6f196-a76f-48c9-ab8b-8cc37f41a9b7', 1, '[{"id": "bv-as-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara förening eller stiftelse"}, {"id": "bv-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Lokalen ska ligga i Sverige"}, {"id": "bv-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.isPublicVenue", "description": "Lokalen ska vara öppen och tillgänglig för allmänheten", "intakeQuestion": "Är lokalen öppen för alla — inte bara egna medlemmar?"}, {"id": "bv-as-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse investering (bygga, köpa eller rusta upp)", "intakeQuestion": "Avser projektet att bygga, köpa eller rusta upp en lokal?"}, {"id": "bv-as-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamhet för ungdomar prioriteras"}]', '[{"id": "bv-as-b1", "type": "max_funding_share", "percent": 50, "description": "Bidraget täcker som huvudregel högst 50 % av godkänd kostnad."}]', '[{"id": "bv-as-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av lokalen och åtgärderna"}, {"id": "bv-as-e2", "kind": "budget", "mandatory": true, "description": "Kostnadskalkyl och finansieringsplan"}]', '2026-08-28 17:30:49.923514+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.923514+00'),
	('3d4c2bb6-d605-450c-82c9-715d307d9103', '0b1994e6-e493-4e2e-b231-7ebecc33ef13', 1, '[{"id": "rf-lok-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en idrottsförening"}, {"id": "rf-lok-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "rf-lok-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.memberOfSportsFederation", "description": "Föreningen ska vara ansluten till ett specialidrottsförbund inom RF", "intakeQuestion": "Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?"}, {"id": "rf-lok-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamheten ska rikta sig till barn och unga 7–25 år", "intakeQuestion": "Riktar sig verksamheten till barn och unga (7–25 år)?"}, {"id": "rf-lok-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "sports", "factPath": "project.sector", "description": "Idrottsverksamhet"}]', '[]', '[{"id": "rf-lok-e1", "kind": "activity_programme", "mandatory": true, "description": "Närvaroregistrerad aktivitetsredovisning"}]', '2026-08-28 17:30:49.931597+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.931597+00'),
	('7b7f289d-ed17-40ef-b13f-1fc32fda5c94', '9f891fb9-175e-4d85-9c28-7dd3de6d146e', 1, '[{"id": "sfi-kf-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Stödet söks av ett produktionsbolag"}, {"id": "sfi-kf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "sfi-kf-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett filmprojekt", "intakeQuestion": "Är projektet ett filmprojekt (kort- eller dokumentärfilm)?"}, {"id": "sfi-kf-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "production", "factPath": "project.activityTypes", "description": "Produktion/utveckling"}]', '[]', '[{"id": "sfi-kf-e1", "kind": "project_description", "mandatory": true, "description": "Synopsis/treatment och regivision"}, {"id": "sfi-kf-e2", "kind": "budget", "mandatory": true, "description": "Produktionsbudget och finansieringsplan"}, {"id": "sfi-kf-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelfunktioner"}]', '2026-08-28 17:30:49.93875+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.93875+00'),
	('93e7ac93-edc2-4fb3-9305-05b78f58bacf', '13e34d24-98ca-4928-838a-6d600c2af368', 1, '[{"id": "kr-ss-h1", "op": "in", "kind": "hard", "expected": ["municipality", "school", "company"], "factPath": "applicant.type", "description": "Sökande ska vara skolhuvudman"}, {"id": "kr-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSchoolAuthority", "description": "Sökande ska vara huvudman för förskoleklass/grundskola", "intakeQuestion": "Är ni huvudman för förskoleklass eller grundskola?"}, {"id": "kr-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.usesProfessionalCulture", "description": "Insatserna ska genomföras av professionella kulturaktörer", "intakeQuestion": "Genomförs insatserna av professionella kulturaktörer?"}, {"id": "kr-ss-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Elever som målgrupp"}]', '[]', '[{"id": "kr-ss-e1", "kind": "project_description", "mandatory": true, "description": "Plan för kulturinsatserna"}, {"id": "kr-ss-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 17:30:49.946698+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.946698+00'),
	('3b2b64be-dc0d-435e-92f4-fb37a3a55397', 'e7d5806a-ea09-4411-b947-57ad4f8b67a4', 1, '[{"id": "fo-ou-h1", "op": "in", "kind": "hard", "expected": ["university", "public_body"], "factPath": "applicant.type", "description": "Medlen förvaltas av lärosäte eller forskningsinstitut"}, {"id": "fo-ou-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Medelsförvaltaren ska vara svensk"}, {"id": "fo-ou-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "fo-ou-m2", "op": "in", "kind": "mandatory", "expected": ["environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom Formas ansvarsområden", "intakeQuestion": "Ligger projektet inom miljö, areella näringar eller samhällsbyggande?"}]', '[]', '[{"id": "fo-ou-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "fo-ou-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}, {"id": "fo-ou-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 17:30:49.956895+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.956895+00'),
	('0d2444d4-1130-44fb-bbd5-101305fb737d', 'b474bc96-8fab-4953-8905-72bbc9703875', 1, '[{"id": "fk-fp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-fp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha (eller vänta) barn som du avstår arbete för att ta hand om", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 17:30:50.380807+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.380807+00'),
	('1d8b0f53-fe7a-47c3-8186-6be43cc9d6f7', '352541d9-0db6-42d3-858b-ce7be920f555', 1, '[{"id": "tv-ac-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett företag"}, {"id": "tv-ac-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Företaget ska vara registrerat i Sverige"}, {"id": "tv-ac-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSmallEnterprise", "description": "Företaget ska vara litet (typiskt 2–49 anställda — se regionens villkor)", "intakeQuestion": "Har företaget mellan cirka 2 och 49 anställda?"}, {"id": "tv-ac-m2", "op": "includes", "kind": "mandatory", "expected": "development", "factPath": "project.activityTypes", "description": "Checken ska användas för utvecklingsinsats med extern kompetens", "intakeQuestion": "Ska ni ta in extern kompetens för en utvecklingsinsats?"}, {"id": "tv-ac-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.scalableInternationally", "description": "Internationaliseringsambition"}]', '[{"id": "tv-ac-b1", "type": "max_funding_share", "percent": 50, "description": "Checken täcker normalt högst 50 % av kostnaden."}]', '[{"id": "tv-ac-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av utvecklingsinsatsen"}, {"id": "tv-ac-e2", "kind": "budget", "mandatory": true, "description": "Kostnads- och finansieringsplan"}]', '2026-08-28 17:30:49.965063+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.965063+00'),
	('a4511f96-ab3f-427f-b7b4-e79b83000195', 'fb27a1f7-b763-4ab8-b8b4-188c9fd719b8', 1, '[{"id": "jv-ss-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-ss-h2", "op": "in", "kind": "hard", "expected": ["individual", "company"], "factPath": "applicant.type", "description": "Söks av person eller företag"}, {"id": "jv-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age40OrYounger", "description": "Sökande ska vara 40 år eller yngre", "intakeQuestion": "Är du 40 år eller yngre?"}, {"id": "jv-ss-m2", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Ansökan ska avse jordbruks-, trädgårds- eller rennäringsföretag", "intakeQuestion": "Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?"}, {"id": "jv-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.startingOrTakingOverFarm", "description": "Sökande ska starta eller ta över företaget för första gången", "intakeQuestion": "Startar du eller tar du över företaget för första gången?"}]', '[]', '[{"id": "jv-ss-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}, {"id": "jv-ss-e2", "kind": "budget", "mandatory": true, "description": "Ekonomisk kalkyl"}]', '2026-08-28 17:30:49.973067+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.973067+00'),
	('756b3e0a-03c9-4607-a6d2-ac2a3cf87a84', '9ea8f3b8-7e5a-411f-9c3f-2e11ee86bb53', 1, '[{"id": "jv-is-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-is-m1", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Investeringen ska avse jordbruksverksamhet", "intakeQuestion": "Avser investeringen jordbruksverksamhet?"}, {"id": "jv-is-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en fysisk investering?"}]', '[{"id": "jv-is-b1", "type": "max_funding_share", "percent": 40, "description": "Stödandelen är typiskt upp till 40 % av godkänd kostnad — se aktuellt stöd."}]', '[{"id": "jv-is-e1", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl med offerter"}]', '2026-08-28 17:30:49.98061+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.98061+00'),
	('e92323e6-56d5-4d81-ae6a-5fe0a0b7a43f', 'cee75a50-3525-4555-bafc-6743751cf93a', 1, '[{"id": "esf-ku-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "esf-ku-h2", "op": "in", "kind": "hard", "expected": ["company", "association", "municipality", "region", "public_body", "university"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "esf-ku-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensLabourMarket", "description": "Projektet ska stärka kompetens eller ställning på arbetsmarknaden", "intakeQuestion": "Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?"}, {"id": "esf-ku-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Sökande ska klara att förskottera kostnader (stöd betalas ut i efterskott)", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[{"id": "esf-ku-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med förändringsteori"}, {"id": "esf-ku-e2", "kind": "budget", "mandatory": true, "description": "Detaljerad projektbudget"}]', '2026-08-28 17:30:49.987812+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.987812+00'),
	('62d4ea43-c942-448e-9d7b-5e2fdc55b76b', '01f8696b-ebdc-417b-9b71-d1160373303d', 1, '[{"id": "em-ik-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "em-ik-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "em-ik-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.reducesIndustrialEmissions", "description": "Projektet ska minska industrins utsläpp eller skapa negativa utsläpp", "intakeQuestion": "Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?"}, {"id": "em-ik-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["energy", "environment"], "factPath": "project.sector", "description": "Energi-/klimatprojekt"}]', '[]', '[{"id": "em-ik-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med utsläppsberäkning"}, {"id": "em-ik-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 17:30:49.994395+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:49.994395+00'),
	('19a7d85b-4281-45d5-9b3e-987ff9cbccb9', '472f3ec4-3cd2-46af-b29e-5f55dd1cd470', 1, '[{"id": "pm-bt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget söks av privatpersoner"}, {"id": "pm-bt-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-bt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.receivesPension", "description": "Du ska ta ut hel allmän pension", "intakeQuestion": "Tar du ut hel allmän pension?"}, {"id": "pm-bt-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Inkomsterna ska vara låga i förhållande till boendekostnaden", "intakeQuestion": "Är hushållets inkomster låga i förhållande till boendekostnaden?"}, {"id": "pm-bt-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 17:30:50.131592+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.131592+00'),
	('8a0ec9f8-187e-43d8-88b7-e5fe18cb6c2e', '4fa0d5eb-1e47-4923-9627-6ef69a548588', 1, '[{"id": "nv-kk-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Åtgärden ska genomföras i Sverige"}, {"id": "nv-kk-h2", "op": "in", "kind": "hard", "expected": ["company", "municipality", "region", "association", "economic_association", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "nv-kk-m1", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Stödet avser fysiska investeringar", "intakeQuestion": "Avser ansökan en fysisk investering?"}, {"id": "nv-kk-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.measurableEnvironmentalImpact", "description": "Klimatnyttan ska kunna beräknas", "intakeQuestion": "Kan åtgärdens utsläppsminskning beräknas?"}]', '[]', '[{"id": "nv-kk-e1", "kind": "project_description", "mandatory": true, "description": "Åtgärdsbeskrivning med klimatnyttoberäkning"}, {"id": "nv-kk-e2", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl"}]', '2026-08-28 17:30:50.00273+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.00273+00'),
	('08aaffd0-c5d0-4769-ac20-01c0b007597b', 'e8893c24-c7c5-48c5-bad2-7e81f51e8e19', 1, '[{"id": "nv-lona-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Formell sökande är en kommun (föreningar deltar via kommunen)"}, {"id": "nv-lona-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "nv-lona-m1", "op": "eq", "kind": "mandatory", "expected": "environment", "factPath": "project.sector", "description": "Projektet ska avse naturvård eller friluftsliv", "intakeQuestion": "Avser projektet naturvård eller friluftsliv?"}]', '[{"id": "nv-lona-b1", "type": "max_funding_share", "percent": 50, "description": "Högst 50 % bidrag (våtmarksprojekt kan få upp till 90 % — se villkoren)."}]', '[{"id": "nv-lona-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 17:30:50.010523+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.010523+00'),
	('f8aca49a-edda-448d-9e80-d050fb9191ff', 'eafe09c2-a9be-4c64-8dd2-f905c264c78a', 1, '[{"id": "mucf-esc-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "mucf-esc-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "mucf-esc-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "mucf-esc-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasQualityLabel", "description": "Organisationen behöver en Quality Label för solidaritetskåren", "intakeQuestion": "Har organisationen en Quality Label (kvalitetsmärkning)?"}, {"id": "mucf-esc-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge18to30", "description": "Volontärerna ska vara 18–30 år", "intakeQuestion": "Är volontärerna mellan 18 och 30 år?"}, {"id": "mucf-esc-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}, {"id": "mucf-esc-w2", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}]', '[]', '[{"id": "mucf-esc-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med aktivitetsplan"}, {"id": "mucf-esc-e2", "kind": "partner_letter", "mandatory": false, "description": "Bekräftelse från partnerorganisation(er)"}]', '2026-08-28 17:30:50.018596+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.018596+00'),
	('81998240-16bb-4464-813f-4ec5a314e1e2', '3b982049-9767-4a02-8dfd-e2cf9df41b91', 1, '[{"id": "er-ka1-h1", "op": "in", "kind": "hard", "expected": ["school", "municipality", "company", "association", "public_body"], "factPath": "applicant.type", "description": "Söks av utbildningsorganisationer/huvudmän"}, {"id": "er-ka1-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "er-ka1-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "er-ka1-m2", "op": "eq", "kind": "mandatory", "expected": "education", "factPath": "project.sector", "description": "Projektet ska avse utbildningsverksamhet", "intakeQuestion": "Avser projektet skola eller vuxenutbildning?"}, {"id": "er-ka1-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Mobiliteten ska ske till ett annat programland", "intakeQuestion": "Sker mobiliteten till ett annat europeiskt land?"}]', '[]', '[{"id": "er-ka1-e1", "kind": "project_description", "mandatory": true, "description": "Mobilitetsplan"}]', '2026-08-28 17:30:50.025136+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.025136+00'),
	('217d2691-92b5-4053-bf54-3488b59266ff', '8896ddc9-a1da-4818-8ca6-488e9b4e592c', 1, '[{"id": "ke-sp-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer inom kultursektorn"}, {"id": "ke-sp-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "ke-sp-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasThreeCountryPartnership", "description": "Minst tre partner från tre olika programländer krävs", "intakeQuestion": "Har ni partner i minst tre olika europeiska länder?"}, {"id": "ke-sp-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver registrering i EU:s system (PIC/OID)", "intakeQuestion": "Är organisationen registrerad i EU:s deltagarregister?"}, {"id": "ke-sp-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "ke-sp-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning enligt utlysningens mall"}, {"id": "ke-sp-e2", "kind": "partner_letter", "mandatory": true, "description": "Partneravtal/avsiktsförklaringar"}, {"id": "ke-sp-e3", "kind": "budget", "mandatory": true, "description": "Detaljerad budget"}]', '2026-08-28 17:30:50.031357+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.031357+00'),
	('695181e8-d9cd-483e-ad76-56a3cc8d2bf3', '1d8bf172-7160-4f8b-b661-a72fb5630bc3', 1, '[{"id": "fk-tfp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-tfp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (normalt under 12 år) som du vårdar när det är sjukt", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 17:30:50.385908+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.385908+00'),
	('5dbe6cb8-5a34-46f1-aabc-e12ff7d9d01a', '41a0986f-d8cf-427e-b731-b63cb5a70a8f', 1, '[{"id": "kr-vs-h1", "op": "in", "kind": "hard", "expected": ["association", "company"], "factPath": "applicant.type", "description": "Söks av grupper/organisationer — inte enskilda"}, {"id": "kr-vs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-vs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Verksamheten ska vara professionell", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-vs-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Verksamheten ska vara scenkonst", "intakeQuestion": "Är verksamheten scenkonst (dans, teater, musikteater)?"}, {"id": "kr-vs-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "performance", "factPath": "project.activityTypes", "description": "Publik verksamhet"}]', '[]', '[{"id": "kr-vs-e1", "kind": "project_description", "mandatory": true, "description": "Verksamhetsplan"}, {"id": "kr-vs-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse"}, {"id": "kr-vs-e3", "kind": "budget", "mandatory": true, "description": "Verksamhetsbudget"}]', '2026-08-28 17:30:50.03764+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.03764+00'),
	('11305445-8ce0-4cf2-be11-2fb70d753907', '5bc51a6c-ac08-4624-aa47-f770913ebc7b', 1, '[{"id": "vin-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara svensk organisation"}, {"id": "vin-pb-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "vin-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansEuApplication", "description": "Bidraget ska användas för att förbereda en EU-ansökan", "intakeQuestion": "Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?"}]', '[]', '[{"id": "vin-pb-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av planerad EU-ansökan"}]', '2026-08-28 17:30:50.04417+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.04417+00'),
	('9d07063c-a3cb-4368-8406-645222af5d13', '715ee057-3e05-4bea-b829-ba4ad8cbca5e', 1, '[{"id": "mucf-ob-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-ob-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara nationell och verksam i Sverige"}, {"id": "mucf-ob-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Demokratisk uppbyggnad krävs", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}, {"id": "mucf-ob-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.youthMembersShareOver60", "description": "Minst 60 % av medlemmarna ska vara 6–25 år", "intakeQuestion": "Är minst 60 % av medlemmarna mellan 6 och 25 år?"}, {"id": "mucf-ob-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasNationalSpread", "description": "Verksamhet i flera län krävs", "intakeQuestion": "Har organisationen medlemsföreningar i flera län?"}]', '[]', '[{"id": "mucf-ob-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "mucf-ob-e2", "kind": "annual_report", "mandatory": true, "description": "Årsredovisning och medlemsredovisning"}]', '2026-08-28 17:30:50.051295+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.051295+00'),
	('29f534af-62e8-4dda-aa2e-103d9af93c7f', '6a39173a-06b8-4892-a8b9-ab0312bb2cc8', 1, '[{"id": "fk-bbf-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbf-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig (helt eller växelvis)", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-bbf-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Hushållets inkomst ska vara under inkomstgränsen", "intakeQuestion": "Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbf-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 17:30:50.059001+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.059001+00'),
	('b0611045-3632-428b-9a75-b929ea6ba181', 'aee48bcd-9e74-4cfc-80ef-aa5d4a691e6c', 1, '[{"id": "reg-glas-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare"}, {"id": "reg-glas-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska vara folkbokfört i Sverige"}, {"id": "reg-glas-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "reg-glas-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childNeedsGlasses", "description": "Barnet (8–19 år) behöver glasögon eller kontaktlinser", "intakeQuestion": "Behöver något av dina barn i åldern 8–19 år glasögon eller linser?"}]', '[]', '[]', '2026-08-28 17:30:50.066789+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.066789+00'),
	('35551cd7-13e9-46e0-919d-830549777ac3', '32eb2795-dcb4-473a-b76f-df14f8883ff4', 1, '[{"id": "maj-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare eller t.ex. skolsköterska"}, {"id": "maj-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "maj-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (upp till 18 år) som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "maj-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childCostsStrain", "description": "Ekonomin räcker inte till sådant barnet behöver eller förväntas delta i", "intakeQuestion": "Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?"}, {"id": "maj-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "person.lowHouseholdIncome", "description": "Låg hushållsinkomst stärker ansökan"}]', '[]', '[]', '2026-08-28 17:30:50.074663+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.074663+00'),
	('cf9b0a6d-4bc8-481c-86b6-ee63c3eaf7fa', '125b0d3f-8395-4454-8402-0796efec258f', 1, '[{"id": "skjuts-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av vårdnadshavare"}, {"id": "skjuts-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "skjuts-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "skjuts-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInCompulsorySchool", "description": "Barnet går i grundskolan", "intakeQuestion": "Går något av dina barn i grundskolan?"}, {"id": "skjuts-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childSchoolDistanceQualifies", "description": "Färdvägen kvalificerar (längd, trafik eller funktionsnedsättning — kommunens bedömning)", "intakeQuestion": "Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?"}]', '[]', '[]', '2026-08-28 17:30:50.082374+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.082374+00'),
	('d792dd0f-3d84-4144-a9c1-a030482841fe', 'a15fc2f5-15d4-43d7-9f80-db3711a7eeeb', 1, '[{"id": "elevres-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "elevres-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "elevres-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "elevres-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Barnet går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "elevres-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childGymnasiumLongTravel", "description": "Färdvägen till skolan är minst sex kilometer", "intakeQuestion": "Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?"}]', '[]', '[]', '2026-08-28 17:30:50.089444+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.089444+00'),
	('21132d5f-c0af-4cbb-a6ed-84b1718f6a05', '5c96a984-730a-4687-8d55-ffdb56fa4cda', 1, '[{"id": "fk-bbu-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbu-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbu-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara mellan 18 och 28 år", "intakeQuestion": "Är du mellan 18 och 28 år?"}, {"id": "fk-bbu-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Din inkomst ska vara låg", "intakeQuestion": "Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbu-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 17:30:50.094767+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.094767+00'),
	('e6607bc9-e7df-4c55-aa16-739410a61b55', '99920797-c699-40fc-ac6e-c5cc631aced0', 1, '[{"id": "kfs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "kfs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "kfs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.incomeInsufficientForBasicNeeds", "description": "Inkomsterna ska inte räcka till det mest nödvändiga", "intakeQuestion": "Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?"}, {"id": "kfs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.limitedSavings", "description": "Du ska sakna sparande eller tillgångar som kan täcka behoven", "intakeQuestion": "Saknar du sparpengar eller tillgångar som kan täcka utgifterna?"}]', '[]', '[]', '2026-08-28 17:30:50.102816+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.102816+00'),
	('50b6000c-6ee0-484c-846c-33358b926983', 'eb52f86a-001b-4da2-bd54-e409c8b96089', 1, '[{"id": "csn-sm-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-sm-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. det år du fyller 60"}, {"id": "csn-sm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}]', '[]', '[]', '2026-08-28 17:30:50.109718+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.109718+00'),
	('f55d01de-55ae-4858-9665-45f1ba2ab3e6', '8368ce79-e59e-441a-b532-8fdc8e643995', 1, '[{"id": "fk-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-ae-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara 19–29 år", "intakeQuestion": "Är du mellan 19 och 29 år?"}, {"id": "fk-ae-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.reducedWorkCapacityLongTerm", "description": "Arbetsförmågan ska vara nedsatt i minst ett år", "intakeQuestion": "Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?"}]', '[]', '[{"id": "fk-ae-e1", "kind": "medical_certificate", "mandatory": true, "description": "Läkarutlåtande om arbetsförmåga"}]', '2026-08-28 17:30:50.117404+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.117404+00'),
	('af64ca1e-9b4d-47f7-a6d8-332d2a0d3308', 'a63bb697-3963-4ab4-8ce7-7e1595e5346a', 1, '[{"id": "fk-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Barnet ska bo hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}, {"id": "fk-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.separatedParent", "description": "Föräldrarna ska inte bo tillsammans", "intakeQuestion": "Bor du och barnets andra förälder på skilda håll?"}, {"id": "fk-us-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.otherParentNotPaying", "description": "Den andra föräldern betalar inte underhåll (eller för lite)", "intakeQuestion": "Betalar den andra föräldern inget eller mindre än fullt underhåll?"}]', '[]', '[]', '2026-08-28 17:30:50.125011+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.125011+00'),
	('09d1ccae-a40b-4d82-99f9-eb33d92cef77', '70b8688c-0646-44a8-9a91-af94cada48bc', 1, '[{"id": "af-ssn-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "af-ssn-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara inskriven hos Arbetsförmedlingen i Sverige"}, {"id": "af-ssn-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven som arbetssökande", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "af-ssn-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansToStartBusiness", "description": "Du ska planera att starta företag", "intakeQuestion": "Planerar du att starta eget företag?"}]', '[]', '[{"id": "af-ssn-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}]', '2026-08-28 17:30:50.144649+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.144649+00'),
	('3747c388-834e-4627-84d8-8d6b66ec37a9', '2860dbb0-554f-4653-8cbb-c248cef4bdc7', 1, '[{"id": "csn-oss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-oss-h2", "op": "is_false", "kind": "hard", "factPath": "person.age62Plus", "description": "Stödet kan sökas längst t.o.m. det år du fyller 62"}, {"id": "csn-oss-h3", "op": "is_false", "kind": "hard", "factPath": "person.receivesPension", "description": "Stödet riktar sig till yrkesverksamma, inte pensionärer"}, {"id": "csn-oss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.establishedInLabourMarket", "description": "Du ska ha arbetat i genomsnitt minst 16 h/vecka i minst 8 år", "intakeQuestion": "Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?"}, {"id": "csn-oss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska planera studier som stärker din ställning på arbetsmarknaden", "intakeQuestion": "Planerar du studier som stärker din ställning på arbetsmarknaden?"}]', '[]', '[]', '2026-08-28 17:30:50.151818+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.151818+00'),
	('4cf187ce-c3f3-4e22-ac23-d551e17748c9', '4a5c9a5c-bfce-4759-a9e1-5ef9286562b1', 1, '[{"id": "kom-bab-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "kom-bab-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bostaden ska ligga i Sverige"}, {"id": "kom-bab-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i hushållet har en funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "kom-bab-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du eller någon i hushållet ska ha en bestående funktionsnedsättning", "intakeQuestion": "Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?"}, {"id": "kom-bab-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.needsHomeAdaptation", "description": "Bostaden ska behöva anpassas", "intakeQuestion": "Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?"}]', '[]', '[{"id": "kom-bab-e1", "kind": "medical_certificate", "mandatory": true, "description": "Intyg från arbetsterapeut, läkare eller motsvarande"}]', '2026-08-28 17:30:50.160469+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.160469+00'),
	('1617bf68-91b8-4739-ba84-86402198934a', '3ef92ea6-3338-4b14-8e4b-eb12ace30e0b', 1, '[{"id": "kn-kb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kn-kb-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kn-kb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande", "intakeQuestion": "Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?"}]', '[]', '[{"id": "kn-kb-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kn-kb-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 17:30:50.167771+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.167771+00'),
	('dfb1c9ec-48d2-4093-8aa7-3af05a9fab1a', '73676412-9575-4972-a5e3-7b01393e0168', 1, '[{"id": "raa-ka-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "raa-ka-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "raa-ka-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsCulturalHeritage", "description": "Projektet ska avse kulturarv", "intakeQuestion": "Handlar projektet om att bevara eller tillgängliggöra kulturarv?"}]', '[]', '[]', '2026-08-28 17:30:50.174465+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.174465+00'),
	('072754db-0473-419e-990f-8dc56c5341a9', 'ec1cab90-c695-4f9f-b5c7-e2a4785dce42', 1, '[{"id": "si-cf-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "si-cf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande organisation ska vara svensk"}, {"id": "si-cf-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska genomföras med internationell partner", "intakeQuestion": "Har projektet en partner i ett annat land?"}, {"id": "si-cf-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensDemocracy", "description": "Projektet ska stärka demokrati, jämlikhet eller yttrandefrihet", "intakeQuestion": "Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?"}, {"id": "si-cf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["culture", "civil_society"], "factPath": "project.sector", "description": "Kultur/media som verktyg"}]', '[]', '[{"id": "si-cf-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från internationell partner"}, {"id": "si-cf-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 17:30:50.181805+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.181805+00'),
	('c2f6630a-2b0b-471b-9e89-4514305b7833', 'ecb386d0-e9ce-42d2-9e36-c34092fc7c04', 1, '[{"id": "fk-sp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-sp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.sickReducedWorkCapacity", "description": "Sjukdomen ska sätta ned din arbetsförmåga med minst en fjärdedel", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?"}]', '[]', '[]', '2026-08-28 17:30:50.391851+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.391851+00'),
	('b0014add-c5d5-4a76-8ac4-858e848b4a6b', '9f060715-2c83-47b7-9b1f-b25cfcb0d3c8', 1, '[{"id": "nkf-ps-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett konst- eller kulturprojekt", "intakeQuestion": "Är projektet ett konst- eller kulturprojekt?"}, {"id": "nkf-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasNordicDimension", "description": "Projektet ska ha nordisk dimension (samarbete i flera nordiska länder)", "intakeQuestion": "Samarbetar ni med partner i minst två andra nordiska länder?"}, {"id": "nkf-ps-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Gränsöverskridande samarbete"}]', '[]', '[{"id": "nkf-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "nkf-ps-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 17:30:50.188524+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.188524+00');
INSERT INTO public.rule_versions VALUES
	('4ae6be54-0df2-41de-9fe2-63d63216de7a', 'f22969a7-5225-427b-82e3-d9fc1ea37ced', 1, '[{"id": "vr-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte"}, {"id": "vr-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}]', '[]', '[{"id": "vr-pb-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "vr-pb-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}]', '2026-08-28 17:30:50.19591+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.19591+00'),
	('622a6e61-ab71-4db7-89b7-c25854a47c21', '32f951b7-0352-485d-a7a7-f8290c8feabe', 1, '[{"id": "pk-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "pk-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska vara etablerad och välskött", "intakeQuestion": "Har organisationen ordnad ekonomi och demokratisk struktur?"}, {"id": "pk-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Stödet ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[{"id": "pk-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "pk-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning"}]', '2026-08-28 17:30:50.20333+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.20333+00'),
	('295de765-5e57-4b2e-a720-eefdf8369fc9', 'fd6a0c95-a691-42b7-b3d6-e7f4d39fbb04', 1, '[{"id": "mv-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "mv-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell musikverksamhet", "intakeQuestion": "Är verksamheten professionell?"}, {"id": "mv-pb-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Musikprojekt", "intakeQuestion": "Är projektet ett musikprojekt?"}]', '[]', '[]', '2026-08-28 17:30:50.209771+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.209771+00'),
	('0bd0b61b-05fc-40d4-9eb4-fed4ae0fb98f', 'a982ea09-aeab-4287-841b-c09fd33456bc', 1, '[{"id": "er-ka2-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "school", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "er-ka2-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID?"}, {"id": "er-ka2-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partner i ett annat programland", "intakeQuestion": "Har ni en partnerorganisation i ett annat europeiskt land?"}, {"id": "er-ka2-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.newToEuFunding", "description": "Nykomlingar i Erasmus+ prioriteras", "intakeQuestion": "Är det här ert första EU-projekt?"}]', '[]', '[{"id": "er-ka2-e1", "kind": "partner_letter", "mandatory": true, "description": "Partnerbekräftelse"}, {"id": "er-ka2-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 17:30:50.215627+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.215627+00'),
	('0d3badca-ad1d-4b91-90f0-25aeb9dbd509', '3f29bfda-af66-4da9-9f5d-4700773d645d', 1, '[{"id": "tv-ris-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av företag"}, {"id": "tv-ris-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "tv-ris-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.inSupportArea", "description": "Verksamhetsorten ska ligga i stödområde A eller B", "intakeQuestion": "Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?"}, {"id": "tv-ris-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en investering i byggnader eller maskiner?"}, {"id": "tv-ris-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.notStartedYet", "description": "Investeringen får inte vara påbörjad före ansökan", "intakeQuestion": "Kommer investeringen att påbörjas först efter att ni skickat in ansökan?"}]', '[{"id": "tv-ris-b1", "type": "max_funding_share", "percent": 35, "description": "Stödandelen är högst 35 % beroende på område och företagsstorlek."}]', '[]', '2026-08-28 17:30:50.223482+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.223482+00'),
	('fe88332e-bf60-47b0-abcd-f4fa44c8a9f2', 'f9e5e1aa-035c-4cc3-846a-892a17e7ebd8', 1, '[{"id": "kr-ib-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Söks av kommuner"}, {"id": "kr-ib-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsLibraries", "description": "Medlen ska användas till litteraturinköp för folk- eller skolbibliotek", "intakeQuestion": "Avser ansökan litteraturinköp till folk- eller skolbibliotek?"}, {"id": "kr-ib-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga prioriteras"}]', '[]', '[]', '2026-08-28 17:30:50.230449+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.230449+00'),
	('eeba7957-2bfc-461c-8b25-afc232592e25', '0cafa3dc-381f-4fe9-82be-dfed79fc9d36', 1, '[{"id": "kr-ls-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av förlag"}, {"id": "kr-ls-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isPublisher", "description": "Sökande ska vara ett förlag med professionell utgivning", "intakeQuestion": "Är ni ett förlag med professionell utgivning?"}, {"id": "kr-ls-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsPublishedBook", "description": "Stödet söks för redan utgiven titel", "intakeQuestion": "Avser ansökan en redan utgiven titel?"}]', '[]', '[]', '2026-08-28 17:30:50.235961+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.235961+00'),
	('7a924793-34aa-485a-9f94-f46eafddaacd', '2fdec643-5329-4cba-82ac-0ab8265083f5', 1, '[{"id": "ls-bm-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality"], "factPath": "applicant.type", "description": "Söks av föreningar och kommuner"}, {"id": "ls-bm-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "ls-bm-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inAffectedArea", "description": "Projektet ska ligga i en bygd berörd av vatten- eller vindkraft", "intakeQuestion": "Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?"}, {"id": "ls-bm-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsCommunity", "description": "Projektet ska vara till allmän nytta för bygden", "intakeQuestion": "Är projektet till nytta för bygden i stort (inte enskilda)?"}]', '[]', '[]', '2026-08-28 17:30:50.243913+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.243913+00'),
	('babcda21-24d2-4b1a-a34f-963ff4b8f0ea', 'abbae5ba-41cd-4d64-a370-089591b8727b', 1, '[{"id": "mv-av-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "mv-av-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "mv-av-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.planningReturnMigration", "description": "Du ska frivilligt planera att flytta tillbaka till ditt ursprungsland permanent", "intakeQuestion": "Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?"}, {"id": "mv-av-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.protectionBasedResidence", "description": "Du ska ha uppehållstillstånd som flykting eller skyddsbehövande (eller vara nära anhörig till någon som har det)", "intakeQuestion": "Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?"}]', '[]', '[]', '2026-08-28 17:30:50.252676+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.252676+00'),
	('6a97913c-be23-47c1-a03d-6dc93c975422', 'b3344631-582f-4f26-b0c1-1d9da050b7c8', 1, '[{"id": "eures-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "eures-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara bosatt i ett EU-land (här: Sverige)"}, {"id": "eures-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "eures-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.seekingJobInOtherEuCountry", "description": "Du ska söka eller ha fått jobb i ett annat EU-/EES-land", "intakeQuestion": "Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?"}]', '[]', '[]', '2026-08-28 17:30:50.260088+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.260088+00'),
	('b0f8d96b-261f-43af-bc1f-a407c8b44110', 'b2b95a8a-5434-45a4-ae1d-c5da68c8c0a9', 1, '[{"id": "csn-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-us-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. ca 60 års ålder"}, {"id": "csn-us-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "csn-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}, {"id": "csn-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansStudyAbroad", "description": "Studierna ska bedrivas utomlands", "intakeQuestion": "Planerar du att studera utomlands?"}]', '[]', '[]', '2026-08-28 17:30:50.265804+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.265804+00'),
	('5a410004-b03c-437c-b6bc-ed35f076c226', 'ba3032a0-7fc8-40de-aa75-909e0c0ab2ef', 1, '[{"id": "fk-ov-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av vårdnadshavare"}, {"id": "fk-ov-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-ov-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-ov-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-ov-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childHasDisability", "description": "Barnet ska ha en funktionsnedsättning som ger behov av mer omvårdnad och tillsyn än jämnåriga", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?"}]', '[]', '[]', '2026-08-28 17:30:50.274406+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.274406+00'),
	('aa4b34e0-6053-48af-b511-c218410bbee1', '9d74542e-d4fd-44f5-a5ae-8548bee7b07e', 1, '[{"id": "fk-mk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-mk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-mk-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-mk-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du (eller ditt barn) ska ha en varaktig funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-mk-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityExtraCosts", "description": "Funktionsnedsättningen ska medföra merkostnader över lägstanivån", "intakeQuestion": "Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?"}]', '[]', '[]', '2026-08-28 17:30:50.280869+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.280869+00'),
	('f1cde184-128b-47dd-9f05-fb27d95462f4', '6df88dc2-0527-49fb-b7be-cd1bcd3e9394', 1, '[{"id": "fk-bs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-bs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-bs-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-bs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Funktionsnedsättningen ska vara varaktig", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-bs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityTravelDifficulty", "description": "Det ska vara mycket svårt att förflytta sig på egen hand eller använda allmänna kommunikationer", "intakeQuestion": "Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?"}]', '[]', '[]', '2026-08-28 17:30:50.286977+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.286977+00'),
	('5f52e832-667b-458e-9f33-76e6b809e337', 'd258b038-bcd2-4c92-b696-17332a540339', 1, '[{"id": "fk-np-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-np-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-np-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.caringForSeriouslyIllRelative", "description": "Du ska avstå från förvärvsarbete för att vårda eller vara nära en närstående vars sjukdom är ett påtagligt hot mot livet", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?"}]', '[]', '[]', '2026-08-28 17:30:50.293598+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.293598+00'),
	('5e66f243-5350-467f-963a-d69feffaa696', 'c144f440-1e1e-4d57-9229-3e239b75c5d7', 1, '[{"id": "af-ee-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "af-ee-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "af-ee-h3", "op": "is_false", "kind": "hard", "factPath": "person.age66Plus", "description": "Programmet gäller till och med 66 års ålder"}, {"id": "af-ee-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Du ska nyligen ha fått uppehållstillstånd som skyddsbehövande eller anhörig", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "af-ee-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och delta i etableringsprogrammet", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-28 17:30:50.300248+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.300248+00'),
	('65ccccbb-2313-442f-b9e8-dfc5bf98bb40', '019ef51d-398d-459c-a57c-85eec18ac253', 1, '[{"id": "csn-hl-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Lånet söks av privatpersoner"}, {"id": "csn-hl-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara mottagen i en svensk kommun"}, {"id": "csn-hl-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Lånet gäller flyktingar och vissa anhöriga under de första åren i Sverige", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "csn-hl-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.settlingFirstHomeInSweden", "description": "Du ska hålla på att skaffa och utrusta ett första hem i Sverige", "intakeQuestion": "Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?"}]', '[]', '[]', '2026-08-28 17:30:50.306694+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.306694+00'),
	('649453ec-5fee-49e4-8c89-c15abbbdfa19', 'cc6b0482-bf43-434e-9a57-8b2ad0c5c77b', 1, '[{"id": "csn-ss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "csn-ss-h3", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Stödet gäller till och med 60 års ålder"}, {"id": "csn-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara arbetslös och anmäld hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "csn-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.age25to60", "description": "Du ska vara mellan 25 och 60 år", "intakeQuestion": "Är du mellan 25 och 60 år?"}, {"id": "csn-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.shortPriorEducation", "description": "Du ska ha kort tidigare utbildning och behöva studier på grundskole- eller gymnasienivå", "intakeQuestion": "Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?"}]', '[]', '[]', '2026-08-28 17:30:50.313937+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.313937+00'),
	('a1dac4bf-59fe-4855-a469-66b4566b0671', '2dee0a22-35d6-4d57-bbb2-f66264d3fc9e', 1, '[{"id": "csn-it-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "csn-it-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "csn-it-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "csn-it-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Eleven går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "csn-it-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childLivesAwayForStudies", "description": "Eleven behöver bo på studieorten på grund av lång eller besvärlig resväg", "intakeQuestion": "Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?"}]', '[]', '[]', '2026-08-28 17:30:50.32297+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.32297+00'),
	('2b6c7a4c-050b-414e-a129-85146541fb97', '6949dd50-4014-4632-ad2f-e5ec791d0ae8', 1, '[{"id": "kmn-fb-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Bidragen söks av ideella föreningar"}, {"id": "kmn-fb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "kmn-fb-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Föreningen ska vara demokratiskt uppbyggd med stadgar och styrelse", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har föreningen antagna stadgar och en vald styrelse?"}, {"id": "kmn-fb-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.activeInMunicipality", "description": "Föreningen ska bedriva regelbunden verksamhet i kommunen", "intakeQuestion": "Bedriver föreningen regelbunden verksamhet i kommunen?"}, {"id": "kmn-fb-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.hasYouthActivities", "description": "Barn- och ungdomsverksamhet prioriteras i de flesta kommuner", "intakeQuestion": "Har föreningen regelbunden verksamhet för barn eller unga?"}]', '[]', '[]', '2026-08-28 17:30:50.331172+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.331172+00'),
	('094a2274-7a37-419d-8eb5-428804dd84c3', '4e96271f-fba4-4946-b61d-e5c65b2df39e', 1, '[{"id": "reg-ks-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "reg-ks-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Stöden gäller kulturverksamhet", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "reg-ks-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.regionalConnection", "description": "Sökanden ska ha säte eller huvudsaklig verksamhet i regionen", "intakeQuestion": "Har ni säte eller huvudsaklig verksamhet i den region där ni söker?"}]', '[]', '[]', '2026-08-28 17:30:50.338057+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.338057+00'),
	('d680d1c4-cc0a-4aa1-91cc-dff3ccf677e4', '84126469-19cf-42c9-bcae-0fa870cdd7fd', 1, '[{"id": "spb-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks i regel av ideella organisationer"}, {"id": "spb-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "spb-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.localSparbankPresence", "description": "Det ska finnas en sparbank/sparbanksstiftelse i ert verksamhetsområde", "intakeQuestion": "Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?"}, {"id": "spb-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska komma det lokala samhället till del", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}]', '[]', '[]', '2026-08-28 17:30:50.344895+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.344895+00'),
	('8bc57843-f5b3-4066-b501-b5f48fccf1ee', '457fb4d3-6027-4768-8a18-51f7c9dbd771', 1, '[{"id": "leader-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "leader-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inRuralLeaderArea", "description": "Projektet ska genomföras inom ett leaderområde (större delen av landsbygden och många tätorter omfattas)", "intakeQuestion": "Genomförs projektet på landsbygden eller i en mindre tätort?"}, {"id": "leader-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska bidra till bygdens utveckling enligt områdets strategi", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}, {"id": "leader-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Stödet betalas ut i efterhand — ni behöver kunna ligga ute med kostnader", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[]', '2026-08-28 17:30:50.351408+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.351408+00'),
	('806e1ee1-abb4-4b5a-8202-793c17c4d997', '668709ea-2bb8-47e8-a386-f2606decf6bb', 1, '[{"id": "forte-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte eller godkänd medelsförvaltare"}, {"id": "forte-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "forte-pb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.withinForteAreas", "description": "Projektet ska ligga inom hälsa, arbetsliv eller välfärd", "intakeQuestion": "Handlar projektet om hälsa, arbetsliv eller välfärd?"}]', '[]', '[]', '2026-08-28 17:30:50.357685+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.357685+00'),
	('eca76421-d321-4a54-9cee-0f42358300e0', '357e2489-1440-4e44-8fb1-d528a58df995', 1, '[{"id": "rh-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks av ideella organisationer"}, {"id": "rh-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara svensk"}, {"id": "rh-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.has90Account", "description": "Organisationen ska ha 90-konto (Svensk Insamlingskontroll)", "intakeQuestion": "Har organisationen ett 90-konto?"}, {"id": "rh-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Bidrag ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[]', '2026-08-28 17:30:50.363826+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.363826+00'),
	('3dc21f82-2c94-4b2b-8ace-de04d2e68fc3', 'ff3a8408-8ff8-42b7-83ca-79d7bc824d85', 1, '[{"id": "fk-bb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-bb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-bb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn under 16 år som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 17:30:50.369169+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.369169+00'),
	('ae03afb4-54bc-4f18-bfe7-73011d2c0166', 'cc802fc0-832c-43ae-89ed-8afcf1335a95', 1, '[{"id": "fk-fbt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget gäller privatpersoner"}, {"id": "fk-fbt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Gäller från och med det andra barnet du får barnbidrag för", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-28 17:30:50.374297+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.374297+00'),
	('c4a02da7-a312-4fd7-bbf4-2d55dbf5d109', 'fc461e3b-564a-4ad3-a056-d740c3789928', 1, '[{"id": "fk-se-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-se-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Ersättningen är aktuell vid varaktig sjukdom eller funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-se-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Arbetsförmågan ska vara stadigvarande nedsatt av sjukdom eller funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}]', '[]', '[]', '2026-08-28 17:30:50.396837+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.396837+00'),
	('7200e5a4-1f84-48cb-af39-2cb1a830f384', '32c0bf5e-b6c0-4082-96ef-78ed224e4775', 1, '[{"id": "fk-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "fk-as-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.inAfProgram", "description": "Du ska delta i ett arbetsmarknadspolitiskt program", "intakeQuestion": "Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?"}]', '[]', '[]', '2026-08-28 17:30:50.404083+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.404083+00'),
	('3e2b91f1-eb99-4abd-8fca-2f74c9a5eef0', '156324ee-3dbb-443f-89cd-33c115df4d08', 1, '[{"id": "fk-atb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-atb-h2", "op": "is_true", "kind": "hard", "factPath": "person.age24Plus", "description": "Bidraget gäller från och med det år du fyller 24"}]', '[]', '[]', '2026-08-28 17:30:50.411124+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.411124+00'),
	('dcd41ca8-cdd2-4766-955c-a183eb00632d', '68c9f539-b5cd-4ec4-b34d-037cdfc4f5a7', 1, '[{"id": "pm-gp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Gäller privatpersoner"}, {"id": "pm-gp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Garantipension lämnas från riktåldern (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}]', '[]', '[]', '2026-08-28 17:30:50.417038+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.417038+00'),
	('1e73ed7d-2313-450b-b7c2-f8e576f7b593', '089965de-3eb0-469e-ac15-30f5c087c973', 1, '[{"id": "reg-hk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Skyddet gäller privatpersoner"}, {"id": "reg-hk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller vård i Sverige"}]', '[]', '[]', '2026-08-28 17:30:50.423954+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.423954+00'),
	('e07cbbcb-f1da-42a6-a3e2-575436ec3b89', '1f5f3908-6d87-4a6a-a654-26fca5436623', 1, '[{"id": "ak-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "ak-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och aktivt söka arbete", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-28 17:30:50.43029+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.43029+00'),
	('bc90a2ca-11c9-4323-aa09-faa7cc1c84c1', 'c771903f-505b-4b60-9e42-acc4c4aaccd7', 1, '[{"id": "af-nj-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-nj-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateAwayFromWork", "description": "Den som anställs ska ha varit borta från arbetslivet en längre tid eller vara nyanländ", "intakeQuestion": "Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?"}]', '[]', '[]', '2026-08-28 17:30:50.436128+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.436128+00'),
	('0216d1c7-3254-4338-8774-3ae8313224d3', '6bf87f8c-76d8-4c69-b124-38d7bceb64a7', 1, '[{"id": "af-lb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa eller behålla en medarbetare", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-lb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateReducedWorkCapacity", "description": "Den anställda ska ha nedsatt arbetsförmåga på grund av funktionsnedsättning eller ohälsa", "intakeQuestion": "Gäller anställningen en person med nedsatt arbetsförmåga?"}]', '[]', '[]', '2026-08-28 17:30:50.441422+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 17:30:50.441422+00');


--
-- Data for Name: source_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sources VALUES
	('7dea1841-65cc-480f-9b87-22177e7b0032', '790d2ba3-423f-4f9d-bd31-fa05daad4345', 'Kulturrådet — Sök bidrag', 'https://kulturradet.se/sok-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.756114+00'),
	('9196e670-e60b-469a-83d6-68bdfaaa1216', '7928f3e1-b535-4c3d-99b0-9cbc9805b656', 'MUCF — Bidrag', 'https://www.mucf.se/bidrag', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.75854+00'),
	('c695ab35-b0bc-4274-b01a-8b921e5f476d', '6840ca04-5bfd-46f1-9bfa-d57c6467c78a', 'Vinnova — Utlysningar', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.760361+00'),
	('d5d4afd3-fd05-4b41-9da2-01513a9e448a', 'defe9be7-89f2-4f33-8337-76d282f7a1c5', 'Tillväxtverket — Utlysningar', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.762413+00'),
	('d1214947-e0ab-4212-9583-32de614b4dfb', '2f5700a6-91a9-46b3-bb82-d965d9a3e82d', 'Energimyndigheten — Alla utlysningar', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.764836+00'),
	('4d910c0e-0d09-4882-b9fd-d9227cbba3f4', 'e1c00ee3-8b20-43ce-b545-aa4c17aaf605', 'Naturvårdsverket — Bidrag', 'https://www.naturvardsverket.se/bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.766936+00'),
	('110a07c1-0cf8-4910-a3a1-16f8854f7e6b', '3d5fd611-e20b-4cf8-bfe4-2f8553d8a84e', 'Svenska ESF-rådet — Utlysningsplan', 'https://www.esf.se/utlysningar/utlysningsplan/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.768968+00'),
	('1a95cc11-b340-4a44-85c6-cf9bb83753c2', '30ce4b7f-f0bb-4667-a8f3-cb7892a70d6a', 'Erasmus+ — Youth exchanges', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.7707+00'),
	('a778d0a0-ba7d-4b13-99a3-a3c7b00eeb47', 'ef2d88a6-e9ad-4c6e-b0f0-06aa0532915d', 'Konstnärsnämnden — Stipendier och bidrag', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.772652+00'),
	('d9f603e2-0569-41ed-bb32-1df53dc399c5', '6cd09f95-6db4-428c-9762-a9fefa9f43d4', 'Allmänna arvsfonden — Söka pengar', 'https://www.arvsfonden.se/soka-pengar', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.774884+00'),
	('43fc859b-6d9e-4a89-a289-98e685e857fd', '2e0d9f8b-ded0-4c94-a96c-ecef9738046f', 'Boverket — Bidrag och stöd', 'https://www.boverket.se/sv/bidrag--garantier/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.777019+00'),
	('89dbf8db-2982-4793-bc85-c49acca4d0cf', '35767ea0-a4ba-4393-8c5e-d99847961c0d', 'Riksidrottsförbundet — Ekonomiskt stöd', 'https://www.rf.se/bidrag-och-stod', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.778842+00'),
	('be31c15f-2784-446f-bde5-6f11a87c081a', 'f3c3ea5c-003e-4cf1-a5b0-9503b74505ef', 'Svenska Filminstitutet — Stöd', 'https://www.filminstitutet.se/sv/sok-stod/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.780448+00'),
	('c144e25c-2125-4704-b730-23a676ad1e64', '51b7ef66-675d-413d-864e-5f78eb822716', 'Formas — Utlysningar', 'https://www.formas.se/soka-finansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.78199+00'),
	('eaee409c-8ca9-4c06-9620-3286f98051d7', 'ab667f93-6e24-4b35-92e3-9eaeba7015f4', 'UHR — Erasmus+ utbildning', 'https://www.uhr.se/internationella-mojligheter/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.783607+00'),
	('19f5d5b1-f427-4094-852e-4b989e25cf16', '356e2388-b799-4434-9b34-5d6f93a6b058', 'Försäkringskassan — Privatperson', 'https://www.forsakringskassan.se/privatperson', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.785318+00'),
	('a25f131a-2056-4e39-b26e-ce317ba1ca0b', 'eaaf74e4-653e-48b6-993e-ff1a4641e2c5', 'CSN — Studiemedel', 'https://www.csn.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.78699+00'),
	('0d17bd6d-d5c3-46c0-8dd5-ef420a2df55f', 'f008a8c2-2127-4dd8-80fd-c8d10bb42b0b', 'Pensionsmyndigheten — Stöd och bidrag', 'https://www.pensionsmyndigheten.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.789145+00'),
	('d29dae95-7923-4eae-968d-e263b2fc0f92', 'e61f7274-52de-4471-83ae-cc934b981d89', 'Socialstyrelsen — Ekonomiskt bistånd', 'https://www.socialstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.790999+00'),
	('18b3814a-6e6d-4869-a4b6-ad0b6576cb86', 'fa5dfa8b-3f48-4480-933d-456a4159612b', '1177 — Bidrag för glasögon till barn och unga', 'https://www.1177.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.792647+00'),
	('704fa635-09d7-4665-801f-21fcc2b0082a', 'c0fa4105-8057-42fc-a46b-2200f2a6eb33', 'Majblomman — Ansök om bidrag', 'https://majblomman.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.794696+00'),
	('a8815f01-c7ee-48e9-bdd0-7a843ed5d26d', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'Skolverket — Skolskjuts', 'https://www.skolverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.79627+00'),
	('f2cfe006-5834-4922-80d1-df959e7b79a6', '775271e3-a9b2-4704-a04b-9eb6e0e52562', 'Lag (1991:1110) om kommunernas skyldighet att svara för vissa elevresor', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.797948+00'),
	('d4bf2c40-9127-4bc8-8fdc-a0011b07b0e6', 'd498d63f-945c-4e31-8042-2503c6c643e6', 'Arbetsförmedlingen — Stöd och bidrag', 'https://arbetsformedlingen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.799633+00'),
	('5415f6a9-6f87-4ffe-a3cc-ea03a36153a9', '37e1245f-98d1-4063-be5f-c27054c5f82a', 'Sveriges a-kassor — Så fungerar a-kassan', 'https://www.sverigesakassor.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.801762+00'),
	('1a8b8a62-a1ba-451c-bf62-e666c3b5b463', '5ec8e845-3c3f-497b-8ae4-34245b3d8fae', 'Migrationsverket — Återvandring', 'https://www.migrationsverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.805009+00'),
	('50086a50-79f5-440c-b634-8a4ce1d4fb55', '44ccc9f1-b4bf-4333-9623-e15c456e32d5', 'Riksantikvarieämbetet — Bidrag', 'https://www.raa.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.807047+00'),
	('53ad8826-d0f1-43c8-849e-51873f0a4fba', '91a8f2a5-5cea-4289-8886-257ce35181c5', 'Svenska institutet — Utlysningar', 'https://si.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.808912+00'),
	('cc34f9cd-f1dc-4129-800e-c49e9d09fcbf', 'd012d319-6538-4150-90f1-c8a7b82a28f8', 'Nordisk kulturfond — Støtte', 'https://www.nordiskkulturfond.org/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.811117+00'),
	('cd5d13dc-5cd3-48e7-87ad-66a26ec3c9b5', '2c787c76-4737-49c9-b8b4-63bc29e78dfb', 'Vetenskapsrådet — Utlysningar', 'https://www.vr.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.813625+00'),
	('67911d73-2282-4c13-9fff-2e6957022819', 'e30c7a25-122b-43bc-bced-3009439fbd97', 'Postkodstiftelsen — Ansök om stöd', 'https://postkodstiftelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.815599+00'),
	('7d58f13b-d51a-4245-bb07-dfe80ed35e83', '7567c42c-d5fb-441f-a833-5c4f9f60019a', 'Musikverket — Bidrag', 'https://musikverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.817838+00'),
	('cfacfd92-24aa-4fa5-b957-ddd38dbf815f', 'c9ab513b-a69e-47e2-b855-acc8c910e74f', 'Länsstyrelserna — Stöd och bidrag', 'https://www.lansstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.820442+00'),
	('51eb7c8d-8165-42e4-bf3e-1eed28ed42cb', '8b2c3f3b-ef6f-415a-a343-0a72393107a6', 'Forte — Utlysningar', 'https://forte.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.822622+00'),
	('3d60d3f0-d2b2-47d3-8986-73f530c0f593', 'ba1278ad-4f74-44c5-8851-f51fd092f029', 'Sparbankernas Riksförbund — Sparbanksstiftelser', 'https://www.sparbankerna.se/', 'html', 'B', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.824694+00'),
	('aee0d120-bb43-4d07-bd64-188e3e247bc9', '06c449c3-980c-4486-a438-c8f040513700', 'Radiohjälpen — Söka bidrag', 'https://www.radiohjalpen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.827683+00'),
	('feb8a47e-115b-462b-9cf6-b8866d96ce4e', 'b4669d1d-fe4f-42ad-b61a-669c1cfa2bb1', 'Jordbruksverket — Stöd', 'https://jordbruksverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 17:30:49.829692+00');


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


