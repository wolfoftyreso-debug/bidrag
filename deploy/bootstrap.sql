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
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    amount_note text,
    amount_source_url text
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
	(14, 'c1e078548250c737bc1986e92754cccad137e8c0c6a4c9fe72cd7aec517aee40', 1787936414108),
	(15, '7834c4605e4f5bde475fb19e25868d5775f78d2c4c3e53b97aa27de52e28acf6', 1787964482724);


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
	('c9cd3733-424c-4c99-ae92-6f412cc937e1', 'a2a04941-b1d3-48a4-b48a-41a5af4bdce6', 1, '{"id": "kulturradet-resebidrag-v1", "title": "Ansökan — Resebidrag för internationellt kulturutbyte", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "sokande_verksamhet", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "guidance": "T.ex. dans, musik, scenkonst.", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv resan och utbytet", "section": "projekt", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_land", "type": "text", "label": "Resmål (land)", "section": "projekt", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "projekt_datum", "type": "date_range", "label": "Resperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Har du en inbjudan eller bekräftelse från mottagande part?", "section": "projekt", "required": true}, {"key": "inbjudan_beskrivning", "type": "long_text", "label": "Beskriv inbjudan/samarbetet", "section": "projekt", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_inbjudan"}]}, {"key": "aterforing", "type": "long_text", "label": "Hur tar du tillvara erfarenheterna i Sverige?", "section": "projekt", "required": true, "maxLength": 2000, "canonicalKey": "project.knowledgeTransferPlan"}, {"key": "sokt_belopp", "max": 50000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig som söker"}, {"key": "projekt", "title": "Resan och utbytet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.903767+00'),
	('d35e8a20-4c4d-4aa7-86b8-20f3ff6b29e5', 'd7b462a5-957d-4f97-83af-ab6a1be08eff', 1, '{"id": "erasmus-ungdomsutbyte-v1", "title": "Ansökan — Erasmus+ Ungdomsutbyte (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System med EU Login.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv utbytet", "section": "projekt", "guidance": "Tema, aktiviteter och förväntat lärande.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Utbytesperiod (exklusive resdagar)", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "antal_deltagare", "max": 200, "min": 4, "type": "number", "label": "Antal deltagare", "section": "deltagare", "required": true}, {"key": "har_partner", "type": "boolean", "label": "Har ni en bekräftad partnergrupp i ett annat land?", "section": "deltagare", "required": true}, {"key": "partner_namn", "type": "text", "label": "Partnergruppens namn och land", "section": "deltagare", "required": true, "maxLength": 300, "visibleWhen": [{"op": "is_true", "factPath": "har_partner"}], "canonicalKey": "project.partnerName"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Utbytet"}, {"key": "deltagare", "title": "Deltagare och partner"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.905475+00'),
	('80c01a6c-337e-448c-83a8-9de644cec31a', '8f0b862f-211f-4605-ad2c-72e6ee8fdee8', 1, '{"id": "nordisk-kulturfond-projektstod-v1", "title": "Ansökan — Nordisk kulturfond, projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller organisation)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_titel", "type": "text", "label": "Projektets titel", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska ni göra, varför, och vad är den konstnärliga/kulturella idén?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "nordiska_lander", "type": "multiselect", "label": "Vilka nordiska länder deltar aktivt i projektet?", "options": [{"label": "Sverige", "value": "SE"}, {"label": "Danmark", "value": "DK"}, {"label": "Norge", "value": "NO"}, {"label": "Finland", "value": "FI"}, {"label": "Island", "value": "IS"}, {"label": "Grönland", "value": "GL"}, {"label": "Färöarna", "value": "FO"}, {"label": "Åland", "value": "AX"}], "section": "norden", "guidance": "Fonden kräver samarbete mellan flera nordiska länder — ange de länder som har en aktiv roll.", "required": true}, {"key": "nordisk_dimension", "type": "long_text", "label": "Vad tillför det nordiska samarbetet projektet?", "section": "norden", "guidance": "Konkret: vad händer i samarbetet som inte hade hänt nationellt?", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig/er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "norden", "title": "Nordisk dimension"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.907054+00'),
	('5518996d-17d8-47f5-bd60-44f37231120f', '46124e71-ccb1-4ef3-a30a-62a27a09b19c', 1, '{"id": "mucf-projektbidrag-v1", "title": "Ansökan — MUCF projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_syfte", "type": "long_text", "label": "Syfte och genomförande", "section": "projekt", "guidance": "Vilket problem adresserar projektet, vad ska ni göra, och hur vet ni att det fungerat?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka unga når projektet, och hur är de delaktiga?", "section": "malgrupp", "guidance": "Ungas egen delaktighet i planering och genomförande väger tungt i bedömningen.", "required": true, "maxLength": 3000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.908713+00'),
	('e975ce80-8aa4-4584-8315-720b6f3a2ca8', 'e9167b6c-adae-4e91-a1dd-cf417419ba38', 1, '{"id": "kommun-forsorjningsstod-v1", "title": "Ansökan — Försörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "hushall_vuxna", "max": 10, "min": 1, "type": "number", "label": "Antal vuxna i hushållet", "section": "hushall", "required": true, "canonicalKey": "person.householdAdults"}, {"key": "hushall_barn", "max": 15, "min": 0, "type": "number", "label": "Antal barn som bor hemma", "section": "hushall", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "inkomst_manad", "min": 0, "type": "currency", "label": "Hushållets inkomster per månad (kr)", "section": "ekonomi", "guidance": "Räkna ihop lön, ersättningar och bidrag före skatt. Ungefärligt räcker i förberedelsen — kommunen begär exakta underlag.", "required": true, "canonicalKey": "person.monthlyHouseholdIncome"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har hushållet sparade medel eller tillgångar som kan användas till försörjningen?", "section": "ekonomi", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna", "section": "ekonomi", "guidance": "T.ex. sparkonto, bil, värdepapper. Kommunen prövar alltid tillgångar först — att redovisa dem öppet undviker kompletteringar.", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "behov_beskrivning", "type": "long_text", "label": "Beskriv din situation och vad du behöver stöd till", "section": "behov", "guidance": "Konkret: vad har hänt, vad räcker inte pengarna till, och vad gör du själv för att förändra situationen?", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hushall", "title": "Hushållet"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "behov", "title": "Din situation"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.910141+00'),
	('0f2d0497-38c2-4bbd-ab49-dd6422859401', 'ebf624c6-e356-4f65-abdc-9355e0d87583', 1, '{"id": "fk-bostadsbidrag-barnfamiljer-v1", "title": "Ansökan — Bostadsbidrag till barnfamiljer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hemma (helt eller växelvis)", "section": "sokande", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 500, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "guidance": "Bidraget beräknas delvis på ytan — siffran står i hyresavtalet.", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Hushållets beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bostadsbidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav. Ta i lite uppåt hellre än neråt.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.911515+00'),
	('70986920-33e3-4ee1-b331-7b76f6098ec8', '30d11949-6313-4065-8343-6dd2c89361d0', 1, '{"id": "majblomman-bidrag-barn-v1", "title": "Ansökan — Majblomman, bidrag till barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "behov_vad", "type": "long_text", "label": "Vad söker ni bidrag för?", "section": "behov", "guidance": "Något konkret som gör skillnad för barnet: en fritidsaktivitet, kläder, utrustning, en cykel. Majblomman ger till barnet, inte till hushållets löpande utgifter.", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "max": 20000, "min": 1, "type": "currency", "label": "Ungefärligt belopp (kr)", "section": "behov", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "situation", "type": "long_text", "label": "Beskriv kort familjens situation", "section": "behov", "guidance": "Varför räcker pengarna inte till det här just nu? Kortfattat räcker.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet"}, {"key": "behov", "title": "Vad ni söker för"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.913026+00'),
	('eadb7880-45e5-4f09-8a57-dc7ec7b8fc87', '907ff8ba-6609-4fc0-9bb3-a03db3135734', 1, '{"id": "af-stod-start-naringsverksamhet-v1", "title": "Ansökan — Stöd till start av näringsverksamhet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?", "section": "sokande", "guidance": "Stödet förutsätter inskrivning — beslutet fattas av din handläggare.", "required": true}, {"key": "affarside", "type": "long_text", "label": "Beskriv affärsidén", "section": "verksamhet", "guidance": "Vad ska du sälja, till vem, och varför finns det efterfrågan? Konkreta belägg (kundkontakter, erfarenhet, marknadskännedom) väger tyngre än visioner.", "required": true, "maxLength": 4000}, {"key": "verksamhet_start", "type": "date", "label": "Planerad start", "section": "plan", "required": true}, {"key": "har_affarsplan", "type": "boolean", "label": "Har du en skriftlig affärsplan?", "section": "plan", "required": true}, {"key": "forsorjning", "type": "long_text", "label": "Hur försörjer du dig under uppstarten?", "section": "plan", "guidance": "Aktivitetsstödet är tidsbegränsat — visa att kalkylen håller tills verksamheten bär sig.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Affärsidén"}, {"key": "plan", "title": "Planen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.914382+00'),
	('eadf4eb1-9523-4bb5-82bd-80a0737b5134', '68eba158-7604-4223-8549-8072e45d0369', 1, '{"id": "kulturradet-projektbidrag-musik-v1", "title": "Ansökan — Kulturrådet, projektbidrag musik (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "guidance": "Tio siffror. Kontrollsiffran valideras — ett felskrivet nummer är en vanlig avslagsorsak på formalia.", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska genomföras, av vem, för vilken publik — och vad skiljer det från er ordinarie verksamhet?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ovrig_finansiering", "type": "long_text", "label": "Beskriv övrig finansiering", "section": "budget", "guidance": "Egna medel, andra bidrag, intäkter. Lämna tomt om allt söks här.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.916328+00'),
	('d2bc0cb6-962e-416e-ab6e-e86b26f6fc16', '5b97cddb-ca0e-491b-a920-311c88591982', 1, '{"id": "fk-bostadsbidrag-unga-v1", "title": "Ansökan — Bostadsbidrag för unga (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 300, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Din beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.918611+00'),
	('60cfe594-3cef-4fc7-81c5-d28ba1af8aa6', 'ba9cb75e-c5e1-4785-888c-b3f959d062a4', 1, '{"id": "fk-underhallsstod-v1", "title": "Ansökan — Underhållsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hos dig", "section": "barnen", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "underhall_idag", "type": "long_text", "label": "Hur fungerar underhållet i dag?", "section": "underhall", "guidance": "Betalar den andra föräldern inget, för lite eller oregelbundet? Konkret — det avgör vilken väg Försäkringskassan tar.", "required": true, "maxLength": 2000}, {"key": "har_avtal", "type": "boolean", "label": "Finns avtal eller dom om underhållsbidrag?", "section": "underhall", "required": true}, {"key": "avtal_beskrivning", "type": "long_text", "label": "Beskriv avtalet/domen kort", "section": "underhall", "guidance": "Belopp och datum räcker — dokumentet kan bifogas hos Försäkringskassan.", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_avtal"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnen", "title": "Barnen"}, {"key": "underhall", "title": "Underhållet i dag"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.920325+00'),
	('06e84f5d-c5ef-4d09-9a42-8bf158bce48a', '0e140a7c-0699-42b6-9951-f81de9e97846', 1, '{"id": "pm-bostadstillagg-v1", "title": "Ansökan — Bostadstillägg för pensionärer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Allmän pension, tjänstepension och eventuell utländsk pension — sammanlagt.", "required": true}, {"key": "har_kapital", "type": "boolean", "label": "Har du sparade medel eller tillgångar över ungefär 100 000 kr?", "section": "ekonomi", "guidance": "Kapital påverkar bostadstilläggets storlek — att redovisa det öppet undviker återkrav.", "required": true}, {"key": "kapital_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_kapital"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.9218+00'),
	('faa4a3bf-37f2-4533-af4b-87c59cc59579', '8ba44ea9-2f57-4a2b-b5af-a48f1ebe154e', 1, '{"id": "region-glasogonbidrag-barn-v1", "title": "Ansökan — Glasögonbidrag för barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 19, "min": 8, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "har_ordination", "type": "boolean", "label": "Finns ordination eller recept från optiker/ögonläkare?", "section": "barnet", "guidance": "Ordinationen är regionens underlag — utan den kan bidraget inte betalas ut.", "required": true}, {"key": "kostnad", "max": 10000, "min": 1, "type": "currency", "label": "Kostnad för glasögon eller linser (kr)", "section": "barnet", "guidance": "Bidragets tak varierar mellan regioner — hela kostnaden ersätts inte alltid.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och synbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.923223+00'),
	('4f7ef1d0-712a-42c0-94ce-3eace512ec1e', '4fde6677-6df1-4fa3-ad75-f9908f56eccb', 1, '{"id": "kommun-skolskjuts-v1", "title": "Ansökan — Skolskjuts (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skolans namn", "section": "eleven", "required": true, "maxLength": 200}, {"key": "arskurs", "type": "text", "label": "Årskurs", "section": "eleven", "guidance": "Kommunens avståndsgräns skiljer sig ofta per årskurs.", "required": true, "maxLength": 20}, {"key": "avstand_km", "max": 200, "min": 0, "type": "number", "label": "Avstånd hem–skola (km)", "section": "eleven", "required": true}, {"key": "skal", "type": "long_text", "label": "Varför behövs skolskjuts?", "section": "eleven", "guidance": "Konkret: avståndet, en trafikfarlig passage, funktionsnedsättning eller växelvis boende. Kommunen prövar mot sina riktlinjer.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och skolvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.924525+00'),
	('00f9ea05-64e5-4330-a08d-856b62013431', '997cc202-d8b9-49db-9e25-889483577277', 1, '{"id": "arvsfonden-projektstod-v1", "title": "Ansökan — Arvsfonden projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad är nyskapande jämfört med er ordinarie verksamhet? Arvsfonden finansierar inte mer av det ni redan gör.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "malgrupp_delaktighet", "type": "long_text", "label": "Hur är målgruppen delaktig i planering och genomförande?", "section": "malgrupp", "guidance": "Delaktigheten är ett skarpt krav — beskriv mekanismen, inte avsikten: vem ur målgruppen gör vad?", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "overlevnad", "type": "long_text", "label": "Hur lever verksamheten vidare efter projektet?", "section": "budget", "guidance": "Arvsfonden kräver en överlevnadsplan: vem tar över, vem betalar, vad består?", "required": true, "maxLength": 2000}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och överlevnad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.926027+00'),
	('602e81d6-720b-4ea7-860e-2a30b14fa496', 'e31683f9-d952-4386-8ddc-c30becfdec42', 1, '{"id": "csn-studiemedel-v1", "title": "Ansökan — Studiemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "utbildning", "type": "text", "label": "Utbildning och skola", "section": "studier", "guidance": "T.ex. \"Sjuksköterskeprogrammet, Umeå universitet\".", "required": true, "maxLength": 300}, {"key": "studietakt", "type": "select", "label": "Studietakt", "options": [{"label": "Heltid (100 %)", "value": "100"}, {"label": "75 %", "value": "75"}, {"label": "Halvtid (50 %)", "value": "50"}], "section": "studier", "required": true}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod du söker för", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "vill_lana", "type": "boolean", "label": "Vill du även ta studielån (utöver bidraget)?", "section": "ekonomi", "guidance": "Lånedelen är frivillig och kan väljas per vecka — det går att ångra sig senare.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "ekonomi", "title": "Bidrag och lån"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.927485+00'),
	('d4d40d11-65b3-4e95-8d55-0736c5777936', '8cd35f7d-ae52-4807-8329-3cc924bb3027', 1, '{"id": "fk-aktivitetsersattning-v1", "title": "Ansökan — Aktivitetsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "nedsattning_beskrivning", "type": "long_text", "label": "Beskriv hur arbetsförmågan är nedsatt", "section": "halsa", "guidance": "Med egna ord: vad klarar du inte i dag som ett arbete kräver? Försäkringskassan gör alltid den medicinska prövningen — din beskrivning ska stämma med läkarintyget, inte ersätta det.", "required": true, "maxLength": 4000}, {"key": "har_lakarintyg", "type": "boolean", "label": "Finns ett aktuellt läkarintyg eller läkarutlåtande?", "section": "halsa", "guidance": "Läkarutlåtandet är det centrala underlaget — ansökan utan det leder nästan alltid till komplettering.", "required": true}, {"key": "pagaende_insatser", "type": "long_text", "label": "Pågående vård eller insatser", "section": "halsa", "guidance": "T.ex. behandling, rehabilitering, daglig verksamhet. Lämna tomt om inget pågår.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "halsa", "title": "Arbetsförmågan"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.928835+00'),
	('3bf3dbaf-7c86-403b-bcc0-569cd7112582', '852cb486-9e15-40f7-ad8b-42fd6257e13c', 1, '{"id": "pm-aldreforsorjningsstod-v1", "title": "Ansökan — Äldreförsörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Alla pensioner sammanlagt — även utländsk pension räknas.", "required": true}, {"key": "ovriga_inkomster", "min": 0, "type": "currency", "label": "Övriga inkomster per månad (kr)", "section": "ekonomi", "required": false}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har du sparade medel eller tillgångar?", "section": "ekonomi", "guidance": "Tillgångar påverkar prövningen — öppen redovisning undviker återkrav.", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.930169+00'),
	('454b3965-9613-4025-9d25-be824cab4cb8', '6ae1c899-5fe0-45aa-ab69-5d80a6af1d85', 1, '{"id": "kommun-elevresor-gymnasiet-v1", "title": "Ansökan — Elevresor gymnasiet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (elev eller vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Gymnasieskolans namn och ort", "section": "eleven", "required": true, "maxLength": 200}, {"key": "avstand_km", "max": 300, "min": 0, "type": "number", "label": "Resväg hem–skola (km)", "section": "eleven", "guidance": "Gränsen är normalt sex kilometer närmaste väg.", "required": true}, {"key": "har_studiehjalp", "type": "boolean", "label": "Har eleven studiehjälp från CSN?", "section": "eleven", "guidance": "Elevresestödet förutsätter studiehjälp — den kommer automatiskt för de flesta gymnasieelever under 20.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och resvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.931516+00'),
	('c8dae03d-80b1-4b86-83d3-959105c2a37b', 'feb697d1-0ec2-4c29-a773-b973fb6bf623', 1, '{"id": "kommun-bostadsanpassningsbidrag-v1", "title": "Ansökan — Bostadsanpassningsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen och hur den påverkar boendet", "section": "behov", "guidance": "Konkret ur vardagen: trösklar, trappor, badrum. Intyg från arbetsterapeut eller läkare styrker behovet.", "required": true, "maxLength": 3000}, {"key": "anpassning", "type": "long_text", "label": "Vilken anpassning söker du bidrag för?", "section": "behov", "guidance": "T.ex. ramp vid entrén, borttagna trösklar, dörrautomatik, anpassat badrum.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "behov", "guidance": "Offert från entreprenör räcker — kommunen kan begära fler.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "har_intyg", "type": "boolean", "label": "Finns intyg från arbetsterapeut, läkare eller annan sakkunnig?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Behovet och anpassningen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.932866+00'),
	('ba1692b5-0538-4cb0-93f3-38f1b1247317', '400960a3-b232-41ea-8268-696ee266bbc3', 1, '{"id": "csn-omstallningsstudiestod-v1", "title": "Ansökan — Omställningsstudiestöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "arbetsliv_ar", "max": 50, "min": 0, "type": "number", "label": "Ungefär hur många år har du arbetat (minst 16 h/vecka)?", "section": "arbetsliv", "guidance": "Kravet är i genomsnitt minst 16 timmar i veckan under minst 8 år.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du planerar", "section": "studier", "required": true, "maxLength": 300}, {"key": "starkning_beskrivning", "type": "long_text", "label": "Hur stärker utbildningen din ställning på arbetsmarknaden?", "section": "studier", "guidance": "Det här är prövningens kärna: koppla utbildningen till faktisk efterfrågan — en bransch som rekryterar, en roll din arbetsgivare behöver. Söktrycket är högt och generiska motiveringar sållas bort.", "required": true, "maxLength": 4000}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "arbetsliv", "title": "Ditt arbetsliv"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.934315+00'),
	('e44a69e0-d6df-486b-8e5b-c26068f5176b', '3ddfcab1-712c-405c-a3f9-cbc4f4623854', 1, '{"id": "vinnova-innovativa-startups-v1", "title": "Ansökan — Vinnova Innovativa startups (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Bolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "losning_beskrivning", "type": "long_text", "label": "Beskriv lösningen och vad som är nyskapande", "section": "losning", "guidance": "Vad finns i dag, och vad gör er lösning väsentligt bättre? Vinnova jämför mot faktiska alternativ — belägg väger tyngre än vision.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "kundbevis", "type": "long_text", "label": "Vilka belägg finns för efterfrågan?", "section": "marknad", "guidance": "Kunddialoger, piloter, avsiktsförklaringar, betalande användare — det ni faktiskt har.", "required": true, "maxLength": 3000}, {"key": "team_beskrivning", "type": "long_text", "label": "Teamet och dess förmåga att genomföra", "section": "marknad", "guidance": "Roller, relevant erfarenhet och hur mycket tid nyckelpersonerna lägger.", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "budget", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "max": 300000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Bolaget"}, {"key": "losning", "title": "Lösningen"}, {"key": "marknad", "title": "Marknad och team"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.935656+00'),
	('0c6ffdb7-0660-4d25-99a1-a61f0bf73643', '49a40583-294d-4bb5-8e3e-6257de2cd982', 1, '{"id": "tillvaxtverket-affarsutvecklingscheckar-v1", "title": "Ansökan — Affärsutvecklingscheck (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_anstallda", "max": 500, "min": 0, "type": "number", "label": "Antal anställda", "section": "foretag", "guidance": "Checkarna riktar sig typiskt till företag med 2–49 anställda — regionens villkor styr.", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv utvecklingsinsatsen", "section": "insats", "guidance": "Vad ska den externa kompetensen göra, och vad ska vara annorlunda i företaget efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "extern_leverantor", "type": "text", "label": "Extern leverantör/konsult (om känd)", "section": "insats", "required": false, "maxLength": 200}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "guidance": "Checken täcker normalt högst hälften av kostnaden — resten är egen insats.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "insats", "title": "Utvecklingsinsatsen"}, {"key": "budget", "title": "Kostnad och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.93741+00'),
	('03499e11-1a3f-4d12-aa95-c2034214954d', 'a5279701-a293-4f62-886e-158c67a5cec3', 1, '{"id": "tillvaxtverket-regionalt-investeringsstod-v1", "title": "Ansökan — Regionalt investeringsstöd (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsort", "type": "text", "label": "Verksamhetsort (kommun)", "section": "foretag", "guidance": "Orten avgör stödområdestillhörigheten (A/B) och därmed stödnivån.", "required": true, "maxLength": 100}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Byggnader, maskiner eller inventarier — och hur investeringen ökar sysselsättningen eller konkurrenskraften på orten.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjas före ansökan", "section": "investering", "guidance": "En påbörjad investering diskvalificerar hela ansökan — beställ inget förrän ansökan är inne.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "investering", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "investering", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.939274+00'),
	('4a8e63a1-cac6-4d0b-9321-8859cfe4d533', '42758d87-e474-498c-887c-194f6d868e9e', 1, '{"id": "jordbruksverket-startstod-unga-v1", "title": "Ansökan — Startstöd unga jordbrukare (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten", "section": "foretaget", "guidance": "Inriktning (växtodling, djurhållning, trädgård, rennäring), omfattning och om du startar nytt eller tar över.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "overtagande_datum", "type": "date", "label": "Datum för start eller övertagande", "section": "foretaget", "required": true}, {"key": "utbildning_erfarenhet", "type": "long_text", "label": "Din utbildning och erfarenhet inom området", "section": "plan", "guidance": "Naturbruksutbildning, kurser eller praktisk erfarenhet — kravet kan uppfyllas på flera sätt.", "required": true, "maxLength": 2000}, {"key": "har_affarsplan", "type": "boolean", "label": "Finns en skriftlig affärsplan?", "section": "plan", "guidance": "Affärsplanen är obligatorisk bilaga hos Jordbruksverket.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "foretaget", "title": "Företaget du startar eller tar över"}, {"key": "plan", "title": "Affärsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.940828+00'),
	('2a390236-661b-42fd-96fe-149b96225da6', 'aec964e1-b795-40c2-a954-e4b7ca0f5d00', 1, '{"id": "jordbruksverket-investeringsstod-v1", "title": "Ansökan — Investeringsstöd jordbruk (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller företag)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Vad ska byggas eller köpas, och hur stärker det verksamheten (produktion, djurvälfärd, miljö, energi)?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad investeringskostnad (kr)", "section": "investering", "guidance": "Offerter styrker kalkylen — stödandelen räknas på faktiska kostnader.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjats före ansökan", "section": "investering", "required": true}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.942245+00'),
	('a90055f0-a41e-4026-9062-5ab8a1906728', '51a922be-6082-43ac-bacb-54041c0e6512', 1, '{"id": "rf-lok-stod-v1", "title": "Ansökan — LOK-stöd (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "forbund", "type": "text", "label": "Specialidrottsförbund", "section": "forening", "guidance": "T.ex. Svenska Fotbollförbundet — anslutningen är ett krav.", "required": true, "maxLength": 200}, {"key": "antal_aktiviteter", "max": 10000, "min": 1, "type": "number", "label": "Ungefärligt antal gruppaktiviteter per termin (deltagare 7–25 år)", "section": "verksamhet", "guidance": "LOK-stödet räknas per genomförd gruppaktivitet och deltagare — närvaroregistrering i IdrottOnline är underlaget.", "required": true}, {"key": "registrerar_narvaro", "type": "boolean", "label": "Registrerar föreningen närvaro digitalt (t.ex. IdrottOnline)?", "section": "verksamhet", "guidance": "Utan närvaroregistrering kan stödet inte betalas ut — börja registrera innan perioden ansöks.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Föreningen"}, {"key": "verksamhet", "title": "Aktiviteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.943756+00'),
	('2ae7ab59-49fe-49ca-bc06-4f5f4cf79aa3', 'f2578a55-f5c1-4bdb-bef2-98219e52eade', 1, '{"id": "kulturradet-skapande-skola-v1", "title": "Ansökan — Skapande skola (förberedelse)", "fields": [{"key": "huvudman_namn", "type": "text", "label": "Huvudmannens namn", "section": "huvudman", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "huvudman", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_elever", "max": 100000, "min": 1, "type": "number", "label": "Antal elever som omfattas", "section": "insatser", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv kulturinsatserna", "section": "insatser", "guidance": "Vilka professionella kulturaktörer, vilka konstformer, och hur eleverna är delaktiga — inte bara publik.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "lasar_period", "type": "date_range", "label": "Period (läsår)", "section": "insatser", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "huvudman", "title": "Huvudmannen"}, {"key": "insatser", "title": "Kulturinsatserna"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.945155+00'),
	('dcb20e0d-1edf-415c-8961-34108d589a57', '246b303a-90c2-4a94-aa06-b721983de98b', 1, '{"id": "konstnarsnamnden-internationellt-kulturutbyte-v1", "title": "Ansökan — Internationellt kulturutbyte (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "utbyte_beskrivning", "type": "long_text", "label": "Beskriv utbytet", "section": "utbyte", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling just nu?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utbyte_period", "type": "date_range", "label": "Period", "section": "utbyte", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Finns en inbjudan eller bekräftelse från mottagande part?", "section": "utbyte", "guidance": "Inbjudan väger tungt — utan den bedöms utbytet som oplanerat.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "utbyte", "title": "Utbytet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.946625+00'),
	('70192adf-7ea7-41a8-9e57-cdf3ed4c2799', '8f65f0c0-288c-4d3a-8a4d-774625f88b66', 1, '{"id": "filminstitutet-kortfilmsstod-v1", "title": "Ansökan — Kortfilmsstöd (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Produktionsbolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "film_titel", "type": "text", "label": "Filmens arbetstitel", "section": "film", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "synopsis", "type": "long_text", "label": "Synopsis och konstnärlig vision", "section": "film", "guidance": "Berättelsen, formen och varför den här filmen behöver göras — konsulenten läser hundratals, det specifika bär.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "regissor", "type": "text", "label": "Regissör och tidigare verk", "section": "film", "required": true, "maxLength": 300}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Produktionsbolaget"}, {"key": "film", "title": "Filmen"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.94801+00'),
	('b93dc2a4-d675-47af-9c2a-eb48b369bc05', '2fc1d884-cadf-43e3-b6e2-a38b76051271', 1, '{"id": "musikverket-projektbidrag-v1", "title": "Ansökan — Musikverket projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv musikprojektet", "section": "projekt", "guidance": "Vad ska göras, av vilka, och vad tillför det musiklivet utöver er egen verksamhet?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "medverkande", "type": "long_text", "label": "Medverkande musiker/aktörer", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.949563+00'),
	('5bc5d23f-f8d5-4a82-8589-a543785e765f', '2e231444-342a-492b-90d4-8972fae42b6a', 1, '{"id": "postkodstiftelsen-projektstod-v1", "title": "Ansökan — Postkodstiftelsen projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Ett avgränsat projekt med tydlig början och slut — stiftelsen finansierar inte löpande verksamhet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "forvantad_effekt", "type": "long_text", "label": "Vilken förändring ska projektet åstadkomma?", "section": "projekt", "guidance": "Formulera som förändring för målgruppen, inte som aktiviteter.", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.951098+00'),
	('2ecd9bfe-d622-48e0-b3b5-c878335c2d7f', '11248c93-a2ed-4a26-9a1b-b024c4ae4fe8', 1, '{"id": "mucf-organisationsbidrag-v1", "title": "Ansökan — MUCF organisationsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_medlemmar", "max": 1000000, "min": 1, "type": "number", "label": "Totalt antal medlemmar", "section": "medlemmar", "required": true}, {"key": "andel_unga", "max": 100, "min": 0, "type": "percentage", "label": "Andel medlemmar 6–25 år (%)", "section": "medlemmar", "guidance": "Kravet är minst 60 % — medlemsregistret är underlaget och MUCF granskar det.", "required": true}, {"key": "antal_medlemsforeningar", "max": 10000, "min": 1, "type": "number", "label": "Antal medlemsföreningar/lokalavdelningar", "section": "medlemmar", "guidance": "Nationell spridning krävs — normalt verksamhet i minst fem län.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "medlemmar", "title": "Medlemmar och struktur"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.952375+00'),
	('c777d2ed-ece8-4cbc-91f3-635c50897aa1', 'e19104fa-6c9a-4bfb-8b0c-44dbc773360b', 1, '{"id": "kreativa-europa-samarbetsprojekt-v1", "title": "Ansökan — Kreativa Europa samarbetsprojekt (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partnerskap_beskrivning", "type": "long_text", "label": "Partnerskapet (organisationer och länder)", "section": "projekt", "guidance": "Minst tre organisationer från tre olika länder krävs — ange samtliga med land.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och dess europeiska dimension", "section": "projekt", "guidance": "Vad tillför samarbetet som inte hade hänt nationellt? EU-mervärdet är ett bedömningskriterium, inte en formalitet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.967619+00'),
	('ccfd4285-1167-4ae3-8d98-278ef56b3991', '80a6dd98-3d6b-4117-b532-fd4a41aa0b5a', 1, '{"id": "boverket-allmanna-samlingslokaler-v1", "title": "Ansökan — Stöd till allmänna samlingslokaler (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Föreningens/stiftelsens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "lokal_beskrivning", "type": "long_text", "label": "Beskriv lokalen och hur den används av allmänheten", "section": "lokal", "guidance": "Öppenheten är kravet: vilka utomstående grupper använder lokalen i dag, och hur bokar de?", "required": true, "maxLength": 3000}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Vad ska byggas, köpas eller rustas upp?", "section": "lokal", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "budget", "guidance": "Stödet täcker högst halva kostnaden — resten är egen finansiering.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "lokal", "title": "Lokalen och åtgärden"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.953526+00'),
	('48ca8616-6651-498d-a6f9-c2298a165cd7', '611376c1-02ef-4bbc-9d59-8a7db9f647f1', 1, '{"id": "naturvardsverket-ladda-bilen-v1", "title": "Ansökan — Ladda bilen (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_laddpunkter", "max": 1000, "min": 1, "type": "number", "label": "Antal laddpunkter", "section": "laddning", "required": true}, {"key": "plats_beskrivning", "type": "long_text", "label": "Var installeras laddpunkterna, och vilka använder dem?", "section": "laddning", "guidance": "Stödet gäller laddning för boende eller anställda — inte publika laddstationer.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "laddning", "guidance": "Bidraget är högst halva kostnaden per laddpunkt, med takbelopp.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "laddning", "title": "Laddpunkterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.95509+00'),
	('b7e2aa2e-a7bc-4bb9-ad1a-bb71ed592546', '76e44e84-a3fa-45dc-b97a-018b70209e89', 1, '{"id": "raa-kulturarvsbidrag-v1", "title": "Ansökan — Kulturarvsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv kulturarvsinsatsen", "section": "projekt", "guidance": "Vad ska bevaras, användas eller utvecklas — och hur blir det tillgängligt för fler?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.956692+00'),
	('619b038e-9072-41e4-acfa-8e3b2f2560c8', 'ffba91cf-dd29-4a2f-98d5-195d3d3a970f', 1, '{"id": "lansstyrelsen-bygdemedel-v1", "title": "Ansökan — Bygdemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Föreningens/kommunens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "bygd_beskrivning", "type": "long_text", "label": "Vilken bygd gäller det, och hur berörs den av vatten- eller vindkraft?", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Allmännyttan är kravet: vem i bygden får glädje av investeringen, utöver den egna föreningen?", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.958206+00'),
	('92004174-2bb2-4196-b6e0-e47699d9f477', 'f36d31cc-a2d8-4f69-a080-0bc1457bfda1', 1, '{"id": "csn-utlandsstudier-v1", "title": "Ansökan — Studiemedel för utlandsstudier (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "studie_land", "type": "text", "label": "Studieland", "section": "studier", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "utbildning", "type": "text", "label": "Utbildning och lärosäte", "section": "studier", "guidance": "Kontrollera att utbildningen är godkänd för studiemedel i CSN:s tjänst INNAN du tackar ja till platsen.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "terminsavgift", "min": 0, "type": "currency", "label": "Terminsavgift om sådan finns (kr)", "section": "studier", "guidance": "Merkostnadslån kan täcka undervisningsavgifter — lämna tomt om avgift saknas.", "required": false}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna utomlands"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.989166+00'),
	('20cc4618-2d0c-4a08-abcc-b30349f78459', 'e0e9a726-21da-4f87-af24-38748de98344', 1, '{"id": "kulturradet-verksamhetsbidrag-scenkonst-v1", "title": "Ansökan — Verksamhetsbidrag scenkonst (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Gruppens/organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten kommande år", "section": "verksamhet", "guidance": "Repertoar, produktioner, spelplatser och publik — verksamhetsbidraget bedöms på helheten, inte enskilda projekt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "antal_forestallningar", "max": 2000, "min": 1, "type": "number", "label": "Planerat antal föreställningar per år", "section": "verksamhet", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Gruppen/organisationen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.959623+00'),
	('65bb68ef-94dc-4702-9900-bbc79565e1c4', 'c7168d6c-e793-4282-9254-ae5a4bbf0bff', 1, '{"id": "konstnarsnamnden-arbetsstipendium-v1", "title": "Ansökan — Arbetsstipendium (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstområde", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv din konstnärliga verksamhet och dina planer", "section": "verksamhet", "guidance": "Stipendiet bedöms på konstnärlig kvalitet och aktivitet — konkreta verk, uppdrag och planer väger tyngre än ambitioner.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "meriter", "type": "long_text", "label": "Viktigaste verk och uppdrag (senaste åren)", "section": "verksamhet", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Din konstnärliga verksamhet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.961069+00'),
	('4c345ee0-fab6-4b3b-9192-20ffcca0f5d0', '2ef27dfa-fbd2-432e-b1aa-2cff8121df89', 1, '{"id": "konstnarsnamnden-kulturbryggan-v1", "title": "Ansökan — Kulturbryggan (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vad som är nyskapande", "section": "projekt", "guidance": "Kulturbryggan finansierar det oprövade — beskriv vad som skiljer projektet från befintlig praxis, inte bara att det är nytt för er.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "ovriga_finansiarer", "type": "long_text", "label": "Övriga finansiärer (sökta eller beviljade)", "section": "projekt", "guidance": "Kulturbryggan ser gärna fler finansieringskällor — redovisa öppet vad som är sökt respektive beviljat.", "required": false, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.962444+00'),
	('cbcc7b35-a879-43ad-9d4b-3e9e12902adf', '6b410cf5-2dbd-4f63-9c77-004925ffc694', 1, '{"id": "erasmus-mobilitet-skola-vuxen-v1", "title": "Ansökan — Erasmus+ mobilitet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System — utan OID kan ansökan inte lämnas in.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "mobilitet_beskrivning", "type": "long_text", "label": "Beskriv mobiliteterna och deras syfte", "section": "mobilitet", "guidance": "Vilka åker, vart, och hur tas lärdomarna om hand i organisationen efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_deltagare", "max": 500, "min": 1, "type": "number", "label": "Antal deltagare", "section": "mobilitet", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "mobilitet", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "mobilitet", "title": "Mobiliteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.963875+00'),
	('9b87caa7-ba2f-40fc-a6a3-5a9b057c29c7', '0bf4d414-9c2b-4858-be25-4b9de889456d', 1, '{"id": "erasmus-ka2-smaskaliga-partnerskap-v1", "title": "Ansökan — Erasmus+ småskaliga partnerskap (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "partnerskap", "guidance": "Minst en partner i ett annat programland krävs.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv samarbetet", "section": "partnerskap", "guidance": "Småskaliga partnerskap är instegsformatet — enklare aktiviteter, lägre budget, men samma krav på tydligt syfte.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "partnerskap", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "partnerskap", "title": "Partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.965504+00'),
	('17a93ed9-2ba1-4f0b-86b6-bccc3dec62fb', '6d619133-7c4e-4e5c-b3d3-eb1c817dd5f4', 1, '{"id": "vinnova-planeringsbidrag-eu-v1", "title": "Ansökan — Planeringsbidrag EU-ansökan (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "eu_utlysning", "type": "text", "label": "Vilken EU-utlysning avser ni att söka?", "section": "eu", "guidance": "Program och utlysningsnamn — planeringsbidraget kräver ett konkret mål.", "required": true, "maxLength": 300}, {"key": "planering_beskrivning", "type": "long_text", "label": "Vad ska planeringsarbetet omfatta?", "section": "eu", "guidance": "Konsortiebyggande, ansökningsskrivning, resor — det bidraget faktiskt får användas till.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "eu", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "eu", "title": "EU-ansökan som planeras"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.969448+00'),
	('a3b5f9a6-2e42-475d-916e-b6126689b1d5', '1242e318-cd06-48a6-bbbb-4806d4cdc374', 1, '{"id": "mucf-solidaritetskaren-v1", "title": "Ansökan — Europeiska solidaritetskåren (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "har_kvalitetsmarkning", "type": "boolean", "label": "Har organisationen giltig Quality Label?", "section": "org", "guidance": "Kvalitetsmärkningen söks separat och måste finnas innan volontärprojekt kan beviljas.", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv volontärprojektet", "section": "volontar", "guidance": "Vad gör volontärerna, vilket stöd får de, och vilken nytta skapar projektet lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_volontarer", "max": 100, "min": 1, "type": "number", "label": "Antal volontärer", "section": "volontar", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "volontar", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "volontar", "title": "Volontärprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.971069+00'),
	('da132148-cfc9-4d51-b68f-d680c04c92a1', '4955c52c-9cbc-46b9-b36a-80366f8b670e', 1, '{"id": "esf-kompetensutveckling-v1", "title": "Ansökan — ESF kompetensutveckling (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka anställda/deltagare omfattas, och vad behöver de?", "section": "insats", "guidance": "ESF bedömer kopplingen till arbetsmarknadens behov — konkret kompetensgap, inte allmän utbildning.", "required": true, "maxLength": 4000}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv insatserna", "section": "insats", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kan_forfinansiera", "type": "boolean", "label": "Kan organisationen förfinansiera kostnaderna?", "section": "ekonomi", "guidance": "ESF betalar ut i efterskott mot redovisning — likviditeten måste bära projektet under tiden.", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "insats", "required": true, "canonicalKey": "project.dateRange"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "ekonomi", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "insats", "title": "Kompetensinsatsen"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.972792+00'),
	('fc64b93e-ce72-4446-a157-912eb8b28623', 'e53f78a0-2b6c-47e9-86b2-40699b80f7ad', 1, '{"id": "si-creative-force-v1", "title": "Ansökan — Creative Force (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "projekt", "guidance": "Ett etablerat partnerskap i mållandet är kärnan i programmet.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Hur stärker projektet demokrati, yttrandefrihet eller mänskliga rättigheter genom kultur eller media? Mekanismen bedöms, inte avsikten.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnern"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.974433+00'),
	('f37fc5cf-c418-4fad-a29b-6c9e2afac7d3', 'bbc6cdca-3a52-4ffa-99ad-37689c63e8dc', 1, '{"id": "radiohjalpen-projektbidrag-v1", "title": "Ansökan — Radiohjälpens projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "niokonto", "type": "text", "label": "90-kontonummer", "section": "sokande", "guidance": "T.ex. 90 1234-5. Kontot kontrolleras mot Svensk Insamlingskontroll.", "required": true, "maxLength": 20}, {"key": "fond", "type": "select", "label": "Vilken utlysning/fond söker ni ur?", "options": [{"label": "Världens Barn", "value": "varldens_barn"}, {"label": "Musikhjälpen", "value": "musikhjalpen"}, {"label": "Victoriafonden", "value": "victoriafonden"}, {"label": "Annan aktuell utlysning", "value": "other"}], "section": "projekt", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:27.007679+00'),
	('cfce8c10-73a9-4e2f-993b-3c99f18873ea', 'ba48f852-da3b-496c-8ff0-0a998745e437', 1, '{"id": "vr-projektbidrag-v1", "title": "Ansökan — Vetenskapsrådet projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "har_doktorsexamen", "type": "boolean", "label": "Har du doktorsexamen?", "section": "sokande", "guidance": "Behörighetskrav — examensår kan påverka vilka bidragsformer som är öppna.", "required": true}, {"key": "larosate", "type": "text", "label": "Medelsförvaltande lärosäte", "section": "sokande", "guidance": "Bidraget förvaltas av ett svenskt lärosäte — det ska bekräfta åtagandet.", "required": true, "maxLength": 200}, {"key": "forskningsplan", "type": "long_text", "label": "Forskningsplanens kärna", "section": "forskning", "guidance": "Frågeställning, metod och förväntade resultat — sakkunniggranskningen bedömer originalitet och genomförbarhet.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "forskning", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "forskning", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Forskaren"}, {"key": "forskning", "title": "Forskningsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.975983+00');
INSERT INTO public.application_schemas VALUES
	('6c2a7580-fece-4247-b582-71d62063594d', 'bab6e91a-ef86-4ba5-974c-6ea98731ca33', 1, '{"id": "energimyndigheten-energieffektivisering-v1", "title": "Ansökan — Stöd till energieffektivisering (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv energiåtgärden", "section": "atgard", "guidance": "Vilken energianvändning minskas, med vilken teknik, och vad är beräknad besparing i kWh?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "besparing_kwh", "max": 100000000, "min": 1, "type": "number", "label": "Beräknad energibesparing (kWh/år)", "section": "atgard", "guidance": "En energikartläggning eller leverantörsberäkning styrker siffran.", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "atgard", "title": "Åtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.977589+00'),
	('18083aa1-fa3b-4abf-9088-87f66d7579cc', '0f905278-8d79-44d7-a291-102c13d07464', 1, '{"id": "energimyndigheten-industriklivet-v1", "title": "Ansökan — Industriklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och utsläppsminskningen", "section": "projekt", "guidance": "Industriklivet finansierar åtgärder mot processutsläpp — kvantifiera minskningen i CO2-ekvivalenter och beskriv teknikens mognadsgrad.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 100000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "projekt", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.979185+00'),
	('f7178eed-4744-4a1a-aebc-645ff0445fff', 'e8ff528a-11af-4d20-82ec-c063e0f512f6', 1, '{"id": "naturvardsverket-klimatklivet-v1", "title": "Ansökan — Klimatklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Sökandens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv åtgärden", "section": "atgard", "guidance": "Klimatklivet rangordnar på klimatnytta per investerad krona — utsläppsminskningen ska vara beräknad och beräkningen redovisbar.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 10000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "atgard", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Investeringskostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att åtgärden inte påbörjats före ansökan", "section": "atgard", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Sökande"}, {"key": "atgard", "title": "Klimatåtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.98063+00'),
	('6c9b577e-800a-4c44-af4e-9f32e1d1332e', '198d8d6c-44aa-499c-ac8a-c10015ad87a9', 1, '{"id": "naturvardsverket-lona-v1", "title": "Ansökan — LONA lokala naturvårdssatsningen (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "guidance": "LONA söks via kommunen — föreningar deltar som initiativtagare.", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommun", "type": "text", "label": "Kommun som står bakom ansökan", "section": "sokande", "required": true, "maxLength": 100}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv naturvårdsinsatsen", "section": "projekt", "guidance": "Vad görs, var, och vilken naturvårds- eller friluftsnytta skapas lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "guidance": "LONA täcker högst halva kostnaden.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Naturvårdsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.982256+00'),
	('1d479f27-d4c1-4167-988b-ac0817b9e52c', 'c2b559b9-ee37-40e9-9e6e-71daff70b1c2', 1, '{"id": "kulturradet-inkopsstod-bibliotek-v1", "title": "Ansökan — Inköpsstöd till folkbibliotek (förberedelse)", "fields": [{"key": "kommun_namn", "type": "text", "label": "Kommunens namn", "section": "kommun", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "kommun", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "inkop_beskrivning", "type": "long_text", "label": "Hur ska stödet användas?", "section": "inkop", "guidance": "Inköp av litteratur för barn och unga prioriteras; stödet får inte ersätta kommunens egen medieanslag — egeninsatsen ska bestå.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "eget_anslag", "min": 0, "type": "currency", "label": "Kommunens eget medieanslag i år (kr)", "section": "inkop", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "inkop", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "kommun", "title": "Kommunen"}, {"key": "inkop", "title": "Inköpen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.983739+00'),
	('a591aa03-b4a2-47c8-ba4f-e3173e03c0e2', '74c0fdc8-6b92-4d9d-bf6d-37e456136140', 1, '{"id": "kulturradet-litteraturstod-v1", "title": "Ansökan — Litteraturstöd (förberedelse)", "fields": [{"key": "forlag_namn", "type": "text", "label": "Förlagets namn", "section": "forlag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forlag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "titel", "type": "text", "label": "Titel och författare", "section": "titel", "required": true, "maxLength": 300, "canonicalKey": "project.title"}, {"key": "titel_beskrivning", "type": "long_text", "label": "Beskriv utgivningen", "section": "titel", "guidance": "Litteraturstödet söks efter utgivning och bedöms på kvalitet — beskriv verket sakligt, inte säljande.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "upplaga", "max": 1000000, "min": 1, "type": "number", "label": "Upplaga (exemplar)", "section": "titel", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forlag", "title": "Förlaget"}, {"key": "titel", "title": "Titeln"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.985174+00'),
	('03d1900d-aef6-44b7-a3be-1bfa4032166a', '83080275-413e-4e21-81bb-3a09b8a7208a', 1, '{"id": "migrationsverket-atervandringsbidrag-v1", "title": "Ansökan — Stöd vid frivillig återvandring (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "ursprungsland", "type": "text", "label": "Land du planerar att återvandra till", "section": "atervandring", "required": true, "maxLength": 100}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet som återvandrar", "section": "atervandring", "required": true}, {"key": "planerad_utresa", "type": "date", "label": "Planerad utresa", "section": "atervandring", "required": true}, {"key": "situation_beskrivning", "type": "long_text", "label": "Beskriv din plan för återetableringen", "section": "atervandring", "guidance": "Boende, försörjning och nätverk i ursprungslandet. OBS: beslutet är oåterkalleligt i bidragshänseende — uppehållstillståndet återkallas normalt. Ta det lugnt med beslutet och kontrollera aktuella belopp hos Migrationsverket.", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "atervandring", "title": "Återvandringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.986524+00'),
	('32fe4e75-ba9f-488d-8af2-da9572f5feb4', '43d56b50-b052-4ade-9684-23d7ca7a9c53', 1, '{"id": "af-eures-targeted-mobility-v1", "title": "Ansökan — EURES Targeted Mobility (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "mal_land", "type": "text", "label": "Land där jobbet finns", "section": "jobbet", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "jobb_status", "type": "select", "label": "Var i processen är du?", "options": [{"label": "Kallad till intervju", "value": "interview"}, {"label": "Har jobberbjudande", "value": "offer"}, {"label": "Söker aktivt", "value": "searching"}], "section": "jobbet", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Vilket stöd behöver du?", "section": "jobbet", "guidance": "Intervjuresa, flyttkostnad, språkkurs eller erkännande av examen — beloppen är schabloner per insats. EURES-rådgivaren bekräftar vad som gäller din programperiod.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "jobbet", "title": "Jobbet och flytten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.987824+00'),
	('9bd0f0a2-32e1-4f15-b5a8-e420565dfcad', '3285e0f1-7dfe-4c53-8a06-f090af76b725', 1, '{"id": "fk-omvardnadsbidrag-v1", "title": "Ansökan — Omvårdnadsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv barnets funktionsnedsättning", "section": "barnet", "guidance": "Diagnos eller svårigheter i vardagen — läkarutlåtandet bär den medicinska bedömningen, din beskrivning bär vardagen.", "required": true, "maxLength": 3000}, {"key": "omvardnadsbehov", "type": "long_text", "label": "Vilken extra omvårdnad och tillsyn behöver barnet?", "section": "barnet", "guidance": "Jämför med barn i samma ålder: vad kräver mer tid, närvaro eller passning — dygnet runt-perspektivet räknas.", "required": true, "maxLength": 4000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om barnets funktionsnedsättning?", "section": "barnet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och behoven"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.990542+00'),
	('c0a84c90-71b5-4657-a3fa-f56356a21ca5', '82623f15-5b9c-4408-87f3-cf9dce70531f', 1, '{"id": "fk-merkostnadsersattning-v1", "title": "Ansökan — Merkostnadsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "galler_barn", "type": "boolean", "label": "Gäller ansökan ett barn du är vårdnadshavare för?", "section": "sokande", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen", "section": "sokande", "required": true, "maxLength": 3000}, {"key": "merkostnader_ar", "min": 0, "type": "currency", "label": "Uppskattade merkostnader per år (kr)", "section": "kostnader", "guidance": "Räkna bara kostnader du inte skulle ha utan funktionsnedsättningen — och dra av eventuella bidrag som redan täcker dem.", "required": true}, {"key": "merkostnader_beskrivning", "type": "long_text", "label": "Specificera merkostnaderna", "section": "kostnader", "guidance": "Post för post: vad, hur ofta, ungefär vad det kostar per år. Kvitton och intyg stärker.", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "kostnader", "title": "Merkostnaderna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.991893+00'),
	('8cb3b62c-f59c-4cac-abfd-136a98b6dccc', '139f4a15-edaf-4a8b-8d1c-f4e4e394e4d7', 1, '{"id": "fk-bilstod-v1", "title": "Ansökan — Bilstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "forflyttning", "type": "long_text", "label": "Beskriv svårigheterna att förflytta dig eller resa kollektivt", "section": "behov", "guidance": "Konkret: vad går inte, vad krävs för att det ska gå, och hur varaktigt är det?", "required": true, "maxLength": 4000}, {"key": "har_korkort", "type": "boolean", "label": "Har du (eller den som ska köra) körkort?", "section": "behov", "required": true}, {"key": "behov_anpassning", "type": "long_text", "label": "Behöver bilen anpassas — i så fall hur?", "section": "behov", "guidance": "T.ex. handreglage, ramp eller lyft. Lämna tomt om du inte vet ännu — behovet utreds.", "required": false, "maxLength": 2000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om funktionsnedsättningen?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Förflyttningsbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.993195+00'),
	('52e805e0-0adb-4434-91c8-c227f2c12eef', 'd3c40e81-3e19-4764-b364-110e1d5c2bc1', 1, '{"id": "fk-narstaendepenning-v1", "title": "Ansökan — Närståendepenning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "relation", "type": "text", "label": "Din relation till den som är sjuk", "section": "varden", "guidance": "T.ex. förälder, barn, syskon, vän — närstående är den som står den sjuke nära.", "required": true, "maxLength": 200}, {"key": "vard_period", "type": "date_range", "label": "Period du avstår från arbete", "section": "varden", "required": true, "canonicalKey": "project.dateRange"}, {"key": "omfattning", "type": "select", "label": "Omfattning", "options": [{"label": "Hel dag", "value": "full"}, {"label": "Tre fjärdedelar", "value": "three_quarters"}, {"label": "Halv dag", "value": "half"}, {"label": "En fjärdedel", "value": "quarter"}], "section": "varden", "required": true}, {"key": "har_samtycke", "type": "boolean", "label": "Har den sjuke samtyckt till ansökan?", "section": "varden", "guidance": "Samtycke krävs när det är möjligt att lämna.", "required": true}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om den närståendes tillstånd?", "section": "varden", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "varden", "title": "Vården och tiden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.994583+00'),
	('9d30c64f-73b2-43e0-9943-0f775697c73e', '1486ea2a-fac8-44b9-b248-d4c0c9140ea4', 1, '{"id": "af-etableringsersattning-v1", "title": "Ansökan — Etableringsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "uppehallstillstand_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år fick du uppehållstillstånd?", "section": "sokande", "required": true}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven hos Arbetsförmedlingen?", "section": "etablering", "guidance": "Etableringsprogrammet förutsätter inskrivning — börja där om du inte redan är inskriven.", "required": true}, {"key": "har_barn_hemma", "type": "boolean", "label": "Har du barn som bor hos dig?", "section": "etablering", "guidance": "Med barn hemma kan etableringstillägg bli aktuellt hos Försäkringskassan.", "required": true}, {"key": "bor_ensam", "type": "boolean", "label": "Bor du ensam i egen bostad?", "section": "etablering", "guidance": "Den som bor ensam kan ha rätt till bostadsersättning.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "etablering", "title": "Etableringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.995865+00'),
	('ca66a188-0996-4c47-be81-3e6761f49da7', '0b4b4b89-c8af-4361-91c4-aaabcee3473c', 1, '{"id": "csn-hemutrustningslan-v1", "title": "Ansökan — Hemutrustningslån (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommunmottagande_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år togs du emot i en kommun?", "section": "sokande", "guidance": "Lånet söks inom två år från det första kommunmottagandet.", "required": true}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet", "section": "hemmet", "required": true}, {"key": "bostad_typ", "type": "select", "label": "Är bostaden möblerad eller omöblerad?", "options": [{"label": "Omöblerad", "value": "unfurnished"}, {"label": "Möblerad", "value": "furnished"}], "section": "hemmet", "guidance": "Lånebeloppet skiljer sig — omöblerad bostad ger högre lån.", "required": true}, {"key": "aterbetalning_medveten", "type": "boolean", "label": "Jag är medveten om att detta är ett lån som ska betalas tillbaka", "section": "hemmet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hemmet", "title": "Hemmet och behovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.997247+00'),
	('6935f00a-74e4-4467-a6c9-2a343af20848', '1555f28b-9594-494d-81c0-4d2c7d5906af', 1, '{"id": "csn-studiestartsstod-v1", "title": "Ansökan — Studiestartsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "tidigare_utbildning", "type": "select", "label": "Din senast avslutade utbildning", "options": [{"label": "Grundskola eller kortare", "value": "grundskola"}, {"label": "Påbörjat men inte slutfört gymnasium", "value": "gymnasium_ej_klart"}, {"label": "Slutfört gymnasium", "value": "gymnasium"}], "section": "sokande", "required": true}, {"key": "kommun_kontaktad", "type": "boolean", "label": "Har du kontaktat hemkommunen om studiestartsstödet?", "section": "studier", "guidance": "Kommunen bedömer om du tillhör målgruppen innan CSN kan bevilja.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du vill gå", "section": "studier", "guidance": "Grundskole- eller gymnasienivå, t.ex. komvux.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.998583+00'),
	('e89f01f0-35ae-4c2d-81c7-31584a7d0b79', '8676b172-c852-454f-b935-f8b47938e2e8', 1, '{"id": "csn-inackorderingstillagg-v1", "title": "Ansökan — Inackorderingstillägg (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Elevens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skola och ort", "section": "boendet", "required": true, "maxLength": 300}, {"key": "skoltyp", "type": "select", "label": "Vilken typ av skola?", "options": [{"label": "Fristående gymnasieskola", "value": "independent"}, {"label": "Folkhögskola", "value": "folk_high"}, {"label": "Kommunal gymnasieskola", "value": "municipal"}], "section": "boendet", "guidance": "Fristående skola och folkhögskola → CSN. Kommunal skola → hemkommunen.", "required": true}, {"key": "resvag", "type": "long_text", "label": "Beskriv resvägen mellan hemmet och skolan", "section": "boendet", "guidance": "Avstånd och restid — varför daglig pendling inte fungerar.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om eleven"}, {"key": "boendet", "title": "Skolan och boendet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:26.999792+00'),
	('1380bd7d-a2c6-4878-8e81-0b617dc95d5f', 'a83bf538-f3ec-4693-90d9-a789fc2bd05e', 1, '{"id": "kommun-foreningsbidrag-v1", "title": "Ansökan — Kommunalt föreningsbidrag (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "medlemsantal", "max": 1000000, "min": 1, "type": "number", "label": "Antal medlemmar", "section": "forening", "required": true}, {"key": "bidragstyp", "type": "select", "label": "Vilket bidrag söker ni?", "options": [{"label": "Aktivitetsstöd (per deltagartillfälle)", "value": "activity"}, {"label": "Lokalbidrag", "value": "venue"}, {"label": "Startbidrag för ny förening", "value": "start"}, {"label": "Annat/vet inte ännu", "value": "other"}], "section": "verksamhet", "required": true}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten i kommunen", "section": "verksamhet", "guidance": "Vad ni gör, hur ofta, för vilka — särskilt barn- och ungdomsverksamhet.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Om föreningen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:27.001081+00'),
	('c1c21592-d3ab-42a0-b062-6eb0d8ec4422', '1c866c7e-8c24-4fdb-9caf-2f0d7c21df19', 1, '{"id": "region-kulturstod-v1", "title": "Ansökan — Regionalt kulturstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "regional_forankring", "type": "long_text", "label": "Beskriv er förankring i regionen", "section": "sokande", "guidance": "Säte, verksamhetsort, publik och samarbeten i regionen.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:27.002402+00'),
	('d1cebbb8-9454-4a2f-bcac-323bba7bd25f', '33cac5d0-73fa-476f-aa3a-ff82ed272872', 1, '{"id": "sparbanksstiftelsen-projektstod-v1", "title": "Ansökan — Sparbanksstiftelsens projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsomrade", "type": "text", "label": "Ort/område där projektet genomförs", "section": "projekt", "guidance": "Stiftelsen stödjer bara projekt i den egna sparbankens verksamhetsområde.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vem det kommer till del", "section": "projekt", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:27.003772+00'),
	('f35a7df9-ab98-43dc-9f2b-f0ffc041971d', '0a238082-9bad-4a67-b0b6-d7fc05ea5d09', 1, '{"id": "leader-lokalt-ledd-utveckling-v1", "title": "Ansökan — Leader-projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "leaderomrade", "type": "text", "label": "Vilket leaderområde tillhör ni?", "section": "projekt", "guidance": "Osäker? Sök på \"leaderområde\" + din kommun — kansliet hjälper till.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Koppla till leaderområdets utvecklingsstrategi — lokal förankring och samarbete väger tungt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "likviditet", "type": "long_text", "label": "Hur klarar ni likviditeten tills stödet betalas ut?", "section": "budget", "guidance": "Leaderstöd betalas ut i efterhand mot redovisade kostnader.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:27.005141+00'),
	('5e3e8c14-689c-4b43-887f-4ba07b308fae', '88262647-8d83-4ea4-bc98-d712131aeb66', 1, '{"id": "forte-projektbidrag-v1", "title": "Ansökan — Forte projektbidrag (förberedelse)", "fields": [{"key": "projektledare", "type": "text", "label": "Projektledarens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "medelsforvaltare", "type": "text", "label": "Medelsförvaltare (lärosäte)", "section": "sokande", "required": true, "maxLength": 300}, {"key": "disputationsar", "max": 2100, "min": 1950, "type": "number", "label": "Projektledarens disputationsår", "section": "sokande", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv forskningsprojektet", "section": "projekt", "guidance": "Frågeställning, metod och relevans för hälsa, arbetsliv eller välfärd — sakligt och prövbart.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Projektledare och medelsförvaltare"}, {"key": "projekt", "title": "Forskningsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-29 00:51:27.006463+00');


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
	('f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'Kulturrådet', 'SE', 'state_agency', 'https://kulturradet.se', '2026-08-29 00:51:26.336212+00'),
	('b11b2d34-56de-4cfe-af50-d3dfd9997dcb', 'MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor', 'SE', 'state_agency', 'https://www.mucf.se', '2026-08-29 00:51:26.339342+00'),
	('3d781c3a-47ad-4402-aefc-68d920a0a0a0', 'Vinnova', 'SE', 'state_agency', 'https://www.vinnova.se', '2026-08-29 00:51:26.341257+00'),
	('796064d4-174e-44d7-9429-13915b689a8d', 'Tillväxtverket', 'SE', 'state_agency', 'https://tillvaxtverket.se', '2026-08-29 00:51:26.342949+00'),
	('d3a4ef8a-3762-4da9-a832-a8421bbcf595', 'Energimyndigheten', 'SE', 'state_agency', 'https://www.energimyndigheten.se', '2026-08-29 00:51:26.344938+00'),
	('58d0414d-119a-4f14-b1a2-01668af0297f', 'Naturvårdsverket', 'SE', 'state_agency', 'https://www.naturvardsverket.se', '2026-08-29 00:51:26.346965+00'),
	('3b945b80-de20-4135-be2a-5408dc8c676b', 'Jordbruksverket', 'SE', 'state_agency', 'https://jordbruksverket.se', '2026-08-29 00:51:26.348427+00'),
	('cca68a01-b5f4-4c44-9d7e-0316efa9b733', 'Svenska ESF-rådet', 'SE', 'state_agency', 'https://www.esf.se', '2026-08-29 00:51:26.349655+00'),
	('5324fe9f-2625-4ee3-9ade-e690b048dd35', 'Europeiska kommissionen (Erasmus+/EACEA)', 'EU', 'eu', 'https://erasmus-plus.ec.europa.eu', '2026-08-29 00:51:26.351073+00'),
	('a4392274-1c63-4de7-9227-bc612fbf2939', 'UHR — Universitets- och högskolerådet', 'SE', 'state_agency', 'https://www.uhr.se', '2026-08-29 00:51:26.352676+00'),
	('cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', 'Konstnärsnämnden', 'SE', 'state_agency', 'https://www.konstnarsnamnden.se', '2026-08-29 00:51:26.354116+00'),
	('ad6073c0-efaf-4f0c-87ed-394cf15f8369', 'Allmänna arvsfonden', 'SE', 'foundation', 'https://www.arvsfonden.se', '2026-08-29 00:51:26.35544+00'),
	('a160a2aa-5ce4-442f-a656-9f0214ddc676', 'Boverket', 'SE', 'state_agency', 'https://www.boverket.se', '2026-08-29 00:51:26.356622+00'),
	('4ae0a05d-106c-4ec8-9097-a4b3c81f25aa', 'Riksidrottsförbundet', 'SE', 'association', 'https://www.rf.se', '2026-08-29 00:51:26.357839+00'),
	('713c0c5a-418d-4713-88e3-ca4b7ca03919', 'Svenska Filminstitutet', 'SE', 'foundation', 'https://www.filminstitutet.se', '2026-08-29 00:51:26.359023+00'),
	('738eed1c-eac6-475d-95bd-a3790565a559', 'Formas', 'SE', 'state_agency', 'https://www.formas.se', '2026-08-29 00:51:26.360439+00'),
	('014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Försäkringskassan', 'SE', 'state_agency', 'https://www.forsakringskassan.se', '2026-08-29 00:51:26.361837+00'),
	('0ef7acfa-9322-4818-9f67-b920daa08581', 'CSN — Centrala studiestödsnämnden', 'SE', 'state_agency', 'https://www.csn.se', '2026-08-29 00:51:26.362996+00'),
	('d136ab5a-1fba-410f-a96e-3fd26f446c31', 'Pensionsmyndigheten', 'SE', 'state_agency', 'https://www.pensionsmyndigheten.se', '2026-08-29 00:51:26.364159+00'),
	('0c3fab7d-16ce-4e8e-a526-145053a0c8d5', 'Socialtjänsten i din kommun', 'SE', 'municipality', 'https://www.socialstyrelsen.se', '2026-08-29 00:51:26.365425+00'),
	('87b7ca1e-f240-4dc6-806f-7299a90d0d9f', 'Arbetsförmedlingen', 'SE', 'state_agency', 'https://arbetsformedlingen.se', '2026-08-29 00:51:26.366629+00'),
	('0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'Din kommun', 'SE', 'municipality', NULL, '2026-08-29 00:51:26.367822+00'),
	('86d2ddcc-9d26-4927-80f2-4671d7bfe833', 'Riksantikvarieämbetet', 'SE', 'state_agency', 'https://www.raa.se', '2026-08-29 00:51:26.368979+00'),
	('3afd736e-6538-41a9-80a3-5e2469ee928b', 'Svenska institutet', 'SE', 'state_agency', 'https://si.se', '2026-08-29 00:51:26.370098+00'),
	('4bc38c33-8fa0-4b0c-b50d-fd15992bd0db', 'Nordisk kulturfond', 'DK', 'foundation', 'https://www.nordiskkulturfond.org', '2026-08-29 00:51:26.371136+00'),
	('1a3a4fea-4170-4f67-afbe-69782a79c836', 'Vetenskapsrådet', 'SE', 'state_agency', 'https://www.vr.se', '2026-08-29 00:51:26.372241+00'),
	('1287f5d9-dff5-44ae-a7d8-45c8831165af', 'Svenska Postkodstiftelsen', 'SE', 'foundation', 'https://postkodstiftelsen.se', '2026-08-29 00:51:26.373441+00'),
	('1159e72d-a5e4-411b-971e-2e8643f36ff4', 'Statens musikverk', 'SE', 'state_agency', 'https://musikverket.se', '2026-08-29 00:51:26.374596+00'),
	('9b17149a-f39f-4b7e-b63f-c5ea60acc35a', 'Länsstyrelsen i ditt län', 'SE', 'region', 'https://www.lansstyrelsen.se', '2026-08-29 00:51:26.375759+00'),
	('e908b93d-0526-467c-a510-235ec0c217ab', 'Din region', 'SE', 'region', 'https://www.1177.se', '2026-08-29 00:51:26.376977+00'),
	('7c223625-c6cf-49bb-94ec-0a50c07b5576', 'Majblommans Riksförbund', 'SE', 'foundation', 'https://majblomman.se', '2026-08-29 00:51:26.378051+00'),
	('fea1ecec-978c-4a2c-b646-4b448ef3ba14', 'Migrationsverket', 'SE', 'state_agency', 'https://www.migrationsverket.se', '2026-08-29 00:51:26.379168+00'),
	('dc409620-c5bc-4ca7-9266-8311ac367d87', 'Forte — Forskningsrådet för hälsa, arbetsliv och välfärd', 'SE', 'state_agency', 'https://forte.se', '2026-08-29 00:51:26.380414+00'),
	('85f53dd8-7fdb-46d0-8f2b-4c980dec62af', 'Sparbanksstiftelsen i ditt område', 'SE', 'foundation', 'https://www.sparbankerna.se', '2026-08-29 00:51:26.38193+00'),
	('a8b1caea-e4d3-42e8-a450-c0259f491585', 'Radiohjälpen', 'SE', 'foundation', 'https://www.radiohjalpen.se', '2026-08-29 00:51:26.383338+00'),
	('aeb2eb40-63ff-4bdc-aa1f-7a31a946ef3c', 'Din a-kassa', 'SE', 'association', 'https://www.sverigesakassor.se', '2026-08-29 00:51:26.384533+00');


--
-- Data for Name: funding_opportunities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_opportunities VALUES
	('a2a04941-b1d3-48a4-b48a-41a5af4bdce6', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', '3d78f6a0-eae7-456e-a63a-055bbe048e0b', 'kulturradet-internationellt-resebidrag-musik', 'Kulturrådet — Resebidrag för internationellt kulturutbyte', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Stödet riktar sig till yrkesverksamma kulturskapare i Sverige som deltar i internationellt kulturutbyte, till exempel gästspel, samarbetsprojekt eller kompetensutveckling utomlands. Bidraget kan täcka resekostnader och relaterade omkostnader. Kontrollera alltid aktuella villkor hos Kulturrådet.', 'Främja internationellt kulturutbyte och svenska kulturskapares internationella närvaro.', 'travel_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-09-24 21:59:59+00', NULL, 'Ansökan görs i Kulturrådets onlinetjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', '85b4eb17-0b80-4948-8fa1-405663bf8419', '4e04f263-c25c-4500-a65c-5baf44148a2f', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.444852+00', '2026-08-29 00:51:26.444852+00', NULL, NULL),
	('d7b462a5-957d-4f97-83af-ab6a1be08eff', '5324fe9f-2625-4ee3-9ade-e690b048dd35', '1e4ce668-a686-4926-a965-e553e39d398b', 'erasmus-plus-ungdomsutbyten', 'Erasmus+ — Ungdomsutbyten (Youth Exchanges)', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Ungdomsutbyten inom Erasmus+ låter grupper av unga från olika länder mötas i 5–21 dagar (exklusive resa) kring ett gemensamt program. Stödet täcker resekostnader samt praktiska kostnader och aktivitetskostnader enligt programguidens schabloner. Ansökan görs av en organisation eller informell grupp via det nationella programkontoret (i Sverige: MUCF för ungdomsdelen). Organisationen behöver ett OID (Organisation ID) via EU:s Organisation Registration System.', 'Interkulturellt lärande, ungas delaktighet och europeiskt samarbete.', 'eu_grant', '["association", "informal_group", "municipality"]', '["SE"]', '["youth", "culture", "education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, '2026-10-01 10:00:00+00', NULL, 'Ansökan lämnas i EU:s ansökningssystem för Erasmus+ (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'eu_login', 'assisted', 15, '', 'published', '23c8c995-89a7-45af-b6d4-027571862c59', 'be916037-f790-4c4d-827e-034ebceffeed', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.453167+00', '2026-08-29 00:51:26.453167+00', NULL, NULL),
	('46124e71-ccb1-4ef3-a30a-62a27a09b19c', 'b11b2d34-56de-4cfe-af50-d3dfd9997dcb', '78e76df2-1d27-4e34-84ab-6ef0eee5ac49', 'mucf-projektbidrag-ungdomsorganisationer', 'MUCF — Projektbidrag för barn- och ungdomsorganisationer', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'MUCF fördelar statsbidrag till civilsamhällets organisationer, bland annat projektbidrag för verksamhet med och för barn och unga. Bidragen har specifika villkor per utlysning — kontrollera alltid aktuell utlysning hos MUCF.', 'Stärka ungas delaktighet och civilsamhällets verksamhet för barn och unga.', 'project_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i MUCF:s ansökningssystem när en utlysning är öppen.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', '1bdecff9-6fa5-4253-a27b-aad713891b53', 'c7ffcbec-3811-454a-ba00-87878fe6eac0', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.459119+00', '2026-08-29 00:51:26.459119+00', NULL, NULL),
	('3ddfcab1-712c-405c-a3f9-cbc4f4623854', '3d781c3a-47ad-4402-aefc-68d920a0a0a0', 'bcf7b249-831d-44e8-b1ee-7ce82fa11c22', 'vinnova-innovativa-startups', 'Vinnova — Innovativa startups', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Vinnovas program för innovativa startups riktar sig till unga svenska aktiebolag med skalbara, nyskapande lösningar. Utlysningar öppnar i omgångar med specifika villkor per omgång — kontrollera aktuell utlysning hos Vinnova. Bidraget kräver normalt att bolaget är yngre än en viss ålder och har begränsad omsättning.', 'Stärka svenska startups förmåga att utveckla och kommersialisera innovationer.', 'public_grant', '["company"]', '["SE"]', '["innovation", "technology"]', NULL, 30000000, 'SEK', 100, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst (Intressentportalen).', 'https://www.vinnova.se/soka-finansiering/', 'vinnova_konto', 'assisted', 10, '', 'published', '71208f98-7047-4d6b-ad50-d854cec840ff', '6ad2aa7f-a44d-4e4f-a0b6-f57dcbdc4d80', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.465579+00', '2026-08-29 00:51:26.465579+00', NULL, NULL),
	('bab6e91a-ef86-4ba5-974c-6ea98731ca33', 'd3a4ef8a-3762-4da9-a832-a8421bbcf595', '38993a1c-d225-42dc-a30f-d89ab01eee09', 'energimyndigheten-energieffektivisering', 'Energimyndigheten — Stöd för energi- och klimatprojekt (löpande utlysningar)', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Det mesta av Energimyndighetens stöd fördelas via utlysningar som öppnar löpande inom olika områden. Ansökan och ärendehantering sker via Mina sidor. Villkoren varierar per utlysning — den här posten representerar programområdet; kontrollera aktuella utlysningar hos Energimyndigheten.', 'Energiomställning: forskning, innovation och effektivare energianvändning.', 'public_grant', '["company", "university", "public_body", "association", "economic_association"]', '["SE"]', '["energy", "environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 12, '', 'published', '01cbadc8-2100-4322-b274-dc037c8e5598', 'eb432f5d-0999-43b7-9f2c-dbbc3f201517', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.472394+00', '2026-08-29 00:51:26.472394+00', NULL, NULL),
	('611376c1-02ef-4bbc-9d59-8a7db9f647f1', '58d0414d-119a-4f14-b1a2-01668af0297f', '6ef3ec1a-66f9-465e-9f28-877d2046d0c4', 'naturvardsverket-ladda-bilen-organisationer', 'Naturvårdsverket — Bidrag för miljö- och klimatåtgärder (organisationer)', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket administrerar flera bidrag inom miljö- och klimatområdet, uppdelade efter mottagartyp (organisationer, företag, ekonomiska föreningar, offentlig sektor och privatpersoner). Villkoren varierar per bidrag — den här posten representerar området; kontrollera aktuellt bidrag hos Naturvårdsverket.', 'Miljö- och klimatåtgärder i hela samhället.', 'public_grant', '["association", "company", "economic_association", "public_body", "individual"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänster.', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 6, '', 'published', '02c509c1-78a4-4683-b4c0-6c8732c634e0', '8fcc8e09-bb9f-46f5-a56a-90c2e6c2d213', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.478815+00', '2026-08-29 00:51:26.478815+00', NULL, NULL),
	('68eba158-7604-4223-8549-8072e45d0369', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'cc73534c-b6b9-428e-a422-39e7bd7f0949', 'kulturradet-projektbidrag-musik', 'Kulturrådet — Projektbidrag musik (fria musiklivet)', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Kulturrådet fördelar projektbidrag till det fria musiklivet. Bidraget söks av grupper, arrangörer och organisationer inom musikområdet. Villkor och ansökningsperioder publiceras per omgång på Kulturrådets webbplats.', 'Ett levande och oberoende musikliv i hela landet.', 'project_grant', '["association", "company", "individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Kulturrådets onlinetjänst när omgången är öppen.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 7, '', 'published', 'cce4014d-df93-431d-8624-7ba25a61d347', '4e04f263-c25c-4500-a65c-5baf44148a2f', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.485319+00', '2026-08-29 00:51:26.485319+00', NULL, NULL),
	('246b303a-90c2-4a94-aa06-b721983de98b', 'cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', '70e05a6f-ab06-4b13-8550-f17e55649a0a', 'konstnarsnamnden-internationellt-kulturutbyte', 'Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Konstnärsnämnden ger bidrag till yrkesverksamma konstnärer inom bild, form, dans, film, musik och teater för internationellt kulturutbyte — t.ex. resor för samarbeten, gästspel eller arbetsvistelser utomlands. Ansökningsomgångar publiceras per konstområde; kontrollera aktuella tider hos Konstnärsnämnden.', 'Konstnärers internationalisering och konstnärliga utveckling.', 'travel_grant', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 4, '', 'published', '9035e376-59c7-43ba-9cf4-cc82ce73e3ee', '23956d5f-6f03-4bfc-9c2a-2fa3a17fd7e9', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.49231+00', '2026-08-29 00:51:26.49231+00', NULL, NULL),
	('c7168d6c-e793-4282-9254-ae5a4bbf0bff', 'cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', '893e897f-ec9a-4d96-a66a-ec2778c2d76d', 'konstnarsnamnden-arbetsstipendium', 'Konstnärsnämnden — Arbetsstipendium', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Arbetsstipendiet ska ge yrkesverksamma konstnärer ekonomiskt utrymme att utveckla sitt konstnärskap. Söks per konstområde i årliga omgångar; villkor och tider publiceras av Konstnärsnämnden.', 'Konstnärlig fördjupning och försörjningstrygghet för yrkesverksamma konstnärer.', 'stipend', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 6, '', 'published', '6ff1082e-10ea-4f2e-bf73-4677b09f66fc', '23956d5f-6f03-4bfc-9c2a-2fa3a17fd7e9', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.49832+00', '2026-08-29 00:51:26.49832+00', NULL, NULL),
	('997cc202-d8b9-49db-9e25-889483577277', 'ad6073c0-efaf-4f0c-87ed-394cf15f8369', '51136e51-70a4-48d9-9f3d-c1ed72a90adc', 'arvsfonden-projektstod', 'Allmänna arvsfonden — Projektstöd', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Arvsfonden stödjer ideella organisationers utvecklingsprojekt som är nyskapande och där målgruppen — barn, ungdomar, äldre eller personer med funktionsnedsättning — är delaktig. Ansökan kan lämnas löpande; projekt kan pågå i upp till tre år.', 'Nyskapande och utvecklande verksamhet för fondens målgrupper.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.arvsfonden.se/soka-pengar', 'none', 'assisted', 12, '', 'published', '48232e6e-df8e-41db-a5b9-abaca19b9db0', 'a3bdcb49-1b06-4af9-804c-9208d1fc9ea5', 'https://www.arvsfonden.se/soka-pengar', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.504134+00', '2026-08-29 00:51:26.504134+00', NULL, NULL),
	('80a6dd98-3d6b-4117-b532-fd4a41aa0b5a', 'a160a2aa-5ce4-442f-a656-9f0214ddc676', '8d9d24f5-6036-4270-9edd-144ffc06609c', 'boverket-allmanna-samlingslokaler', 'Boverket — Investeringsbidrag till allmänna samlingslokaler', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Boverket ger investeringsbidrag till föreningar och stiftelser för nybyggnad, ombyggnad, köp eller standardhöjande reparationer av allmänna samlingslokaler — t.ex. bygdegårdar, folkets hus och föreningslokaler. Årlig ansökningsomgång; villkor publiceras av Boverket.', 'Tillgång till lokaler för möten, kultur och fritid i hela landet.', 'public_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "culture"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.boverket.se/sv/bidrag--garantier/', 'eid', 'assisted', 10, '', 'published', '1417834a-1b87-44c3-8019-d70e67eaee13', '906c2cd7-09e3-4d97-b7e6-d47d6f56118b', 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.509511+00', '2026-08-29 00:51:26.509511+00', NULL, NULL),
	('51a922be-6082-43ac-bacb-54041c0e6512', '4ae0a05d-106c-4ec8-9097-a4b3c81f25aa', '20d0018a-d524-4b9e-9753-a6a0ba093032', 'rf-lok-stod', 'Riksidrottsförbundet — Statligt lokalt aktivitetsstöd (LOK-stöd)', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'LOK-stödet ger idrottsföreningar anslutna till ett specialidrottsförbund ersättning per sammankomst och deltagartillfälle för ledarledd verksamhet för deltagare 7–25 år. Redovisas i IdrottOnline två gånger per år.', 'Stödja föreningsdriven barn- och ungdomsidrott.', 'public_grant', '["association"]', '["SE"]', '["sports", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-08-25 21:59:59+00', NULL, 'Ansökan/redovisning görs i IdrottOnline. Ansökningsperioderna stänger 25 februari och 25 augusti.', 'https://www.rf.se/bidrag-och-stod', 'none', 'assisted', 2, '', 'published', 'f695f1e3-8951-48bf-8e21-d61b6fab255a', '229ee644-4f20-4299-bd96-fa8995b9512c', 'https://www.rf.se/bidrag-och-stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.515313+00', '2026-08-29 00:51:26.515313+00', NULL, NULL),
	('8f65f0c0-288c-4d3a-8a4d-774625f88b66', '713c0c5a-418d-4713-88e3-ca4b7ca03919', '08c48b26-924e-4c5c-9522-2e3d79904f3a', 'filminstitutet-kortfilmsstod', 'Svenska Filminstitutet — Stöd till kort- och dokumentärfilm', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Filminstitutet ger utvecklings- och produktionsstöd till kort- och dokumentärfilm. Stödet söks normalt av ett produktionsbolag; beslut fattas av filmkonsulent. Villkor och ansökningstider publiceras per stödform.', 'Konstnärligt värdefull svensk film.', 'project_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.filminstitutet.se/sv/sok-stod/', 'none', 'assisted', 8, '', 'published', 'be4d3b3e-401d-42ce-935b-1882b08d7db6', '428ad22b-42d9-4da0-bd2f-bc84eb5769f9', 'https://www.filminstitutet.se/sv/sok-stod/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.520905+00', '2026-08-29 00:51:26.520905+00', NULL, NULL),
	('2fc1d884-cadf-43e3-b6e2-a38b76051271', '1159e72d-a5e4-411b-971e-2e8643f36ff4', 'ff36f488-b9a5-411b-81ad-373117aa577b', 'musikverket-projektbidrag', 'Statens musikverk — Projektbidrag till musiklivet', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Musikverket fördelar projektbidrag till professionella samarbetsprojekt i det fria musiklivet, med särskilt fokus på förnyelse och jämställdhet. Utlysningsomgångar publiceras på musikverket.se.', 'Ett vitalt fritt musikliv.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://musikverket.se/', 'none', 'assisted', 6, '', 'published', '737eae80-41e2-4b48-b500-ce40f1aeb7a4', '19f7c0a9-1192-4259-b2a5-2204262a4b3d', 'https://musikverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.719958+00', '2026-08-29 00:51:26.719958+00', NULL, NULL),
	('0bf4d414-9c2b-4858-be25-4b9de889456d', '5324fe9f-2625-4ee3-9ade-e690b048dd35', 'bfdb7fbe-568c-41ce-9d1d-daf717991aad', 'erasmus-ka2-smaskaliga-partnerskap', 'Erasmus+ — Småskaliga partnerskap (KA2)', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Småskaliga partnerskap är utformade för att sänka tröskeln för organisationer som är nya i Erasmus+: färre krav, schablonbelopp (typiskt 30 000 eller 60 000 euro) och minst en partner i ett annat programland.', 'Bredda deltagandet i europeiskt samarbete.', 'eu_grant', '["association", "municipality", "school", "public_body"]', '["SE"]', '["education", "youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/', 'eu_login', 'assisted', 10, '', 'published', '9692d40e-9879-4b18-acc7-806fab8d4b94', NULL, 'https://erasmus-plus.ec.europa.eu/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.725185+00', '2026-08-29 00:51:26.725185+00', NULL, NULL),
	('a5279701-a293-4f62-886e-158c67a5cec3', '796064d4-174e-44d7-9429-13915b689a8d', '4ad02efa-2cc5-4359-8055-7f8cc8ed6b46', 'tillvaxtverket-regionalt-investeringsstod', 'Tillväxtverket — Regionalt investeringsstöd', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Regionalt investeringsstöd kan delfinansiera större investeringar i stödområde A och B. Stödandel beror på område och företagsstorlek. Söks via Min ansökan.', 'Hållbar tillväxt i regioner med geografiska lägesnackdelar.', 'public_grant', '["company"]', '["SE"]', '[]', NULL, NULL, 'SEK', 35, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) innan investeringen påbörjas.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 12, '', 'published', '2e34f4d8-cb5d-46aa-90fa-d8264d2188ca', '468a1d62-9108-4141-9dc9-d650c74ae822', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.730239+00', '2026-08-29 00:51:26.730239+00', NULL, NULL),
	('c2b559b9-ee37-40e9-9e6e-71daff70b1c2', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'cdfa5633-e3e1-468f-af89-d21007c98793', 'kulturradet-inkopsstod-bibliotek', 'Kulturrådet — Inköpsstöd till folk- och skolbibliotek', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Inköpsstödet söks av kommuner för att stärka bibliotekens utbud av litteratur för barn och unga. Årlig omgång.', 'Läsfrämjande och tillgång till litteratur.', 'public_grant', '["municipality"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 3, '', 'published', '70c8c1e4-790d-443e-885c-5db29b0d0c92', '4e04f263-c25c-4500-a65c-5baf44148a2f', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.735147+00', '2026-08-29 00:51:26.735147+00', NULL, NULL),
	('f2578a55-f5c1-4bdb-bef2-98219e52eade', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'a666779b-e339-49cc-a387-7a31943517a2', 'kulturradet-skapande-skola', 'Kulturrådet — Skapande skola', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Skapande skola söks av skolhuvudmän (kommuner, fristående skolor) för konst- och kulturinsatser i förskoleklass och grundskola, genomförda av professionella kulturaktörer. Årlig ansökningsomgång.', 'Att alla elever ska få möta professionell konst och kultur.', 'public_grant', '["municipality", "school", "company"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 6, '', 'published', '1207d601-23d7-40e1-9485-7c8e310a0ff7', '4e04f263-c25c-4500-a65c-5baf44148a2f', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.526193+00', '2026-08-29 00:51:26.526193+00', NULL, NULL),
	('5bd2c29b-3505-4985-962b-f7d60c4bcfda', '738eed1c-eac6-475d-95bd-a3790565a559', 'ec8da948-da00-4054-a8dc-3236ee05631b', 'formas-oppna-utlysningen', 'Formas — Årliga öppna utlysningen', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Formas årliga öppna utlysning finansierar forskningsprojekt inom miljö, areella näringar och samhällsbyggande. Söks av disputerade forskare vid svenska lärosäten och forskningsinstitut. Årlig omgång med publicerade tider.', 'Kunskap för hållbar utveckling.', 'public_grant', '["university", "public_body"]', '["SE"]', '["environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.formas.se/soka-finansiering.html', 'none', 'assisted', 20, '', 'published', 'a084a0f4-de6e-4b4c-a78f-19774a15802b', '789eaf04-6281-4ed5-b51e-a179cc31aeea', 'https://www.formas.se/soka-finansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.532508+00', '2026-08-29 00:51:26.532508+00', NULL, NULL),
	('49a40583-294d-4bb5-8e3e-6257de2cd982', '796064d4-174e-44d7-9429-13915b689a8d', '00042352-d886-4513-af82-db57ccf7da7d', 'tillvaxtverket-affarsutvecklingscheckar', 'Tillväxtverket — Affärsutvecklingscheckar (internationalisering/digitalisering)', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Affärsutvecklingscheckarna hjälper små företag att köpa extern kompetens för att utvecklas internationellt eller digitalt. Checkarna administreras regionalt; belopp, andelar och tider varierar per region — kontrollera din regions aktuella utlysning.', 'Stärkt konkurrenskraft i små företag.', 'public_grant', '["company"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', 50, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) när regionens omgång är öppen.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 6, '', 'published', '8a57e57d-d4dd-46c9-b38c-7ce387832e84', '468a1d62-9108-4141-9dc9-d650c74ae822', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.539207+00', '2026-08-29 00:51:26.539207+00', NULL, NULL),
	('42758d87-e474-498c-887c-194f6d868e9e', '3b945b80-de20-4135-be2a-5408dc8c676b', '22648352-fdef-4b75-98f8-72d1ad4b0cd7', 'jordbruksverket-startstod-unga', 'Jordbruksverket — Startstöd till unga jordbrukare', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Startstödet riktar sig till unga som startar eller tar över jordbruks-, trädgårds- eller rennäringsföretag. Kräver bl.a. åldersgräns, utbildning/erfarenhet och en affärsplan. Ansökan görs i Jordbruksverkets e-tjänst med e-legitimation.', 'Generationsväxling och föryngring i jordbruket.', 'public_grant', '["individual", "company"]', '["SE"]', '["agriculture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation; fullmakt kan användas).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', 'f71ebd88-714a-4ee3-81b9-8aadf928d892', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.545092+00', '2026-08-29 00:51:26.545092+00', NULL, NULL),
	('74c0fdc8-6b92-4d9d-bf6d-37e456136140', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'cdfa5633-e3e1-468f-af89-d21007c98793', 'kulturradet-litteraturstod', 'Kulturrådet — Litteraturstöd (efterhandsstöd till utgivning)', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Litteraturstödet är ett efterhandsstöd som förlag söker för utgiven kvalitetslitteratur inom olika kategorier. Beslut fattas av arbetsgrupper med litterär expertis.', 'Bredd och kvalitet i svensk bokutgivning.', 'public_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', 'e39a2170-6069-48bb-b737-ea30a9c185a0', '4e04f263-c25c-4500-a65c-5baf44148a2f', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.739505+00', '2026-08-29 00:51:26.739505+00', NULL, NULL),
	('ffba91cf-dd29-4a2f-98d5-195d3d3a970f', '9b17149a-f39f-4b7e-b63f-c5ea60acc35a', '921146b4-ca23-42de-84fb-62e7e7c47c94', 'lansstyrelsen-bygdemedel', 'Länsstyrelsen — Bygdemedel', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Bygdemedel är ersättningar från vattenkraft (och i vissa län vindkraft) som återförs till berörda bygder. Föreningar och kommuner kan söka för t.ex. samlingslokaler, leder och bygdeutveckling. Villkor varierar per län.', 'Lokal utveckling i berörda bygder.', 'public_grant', '["association", "municipality"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos länsstyrelsen i ditt län, ofta via e-tjänst.', 'https://www.lansstyrelsen.se/', 'eid', 'assisted', 6, '', 'published', 'e16c9447-2b2d-43ab-9278-0242571021d8', 'dbc46770-3017-4b61-9089-5529a80d201d', 'https://www.lansstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.744939+00', '2026-08-29 00:51:26.744939+00', NULL, NULL),
	('83080275-413e-4e21-81bb-3a09b8a7208a', 'fea1ecec-978c-4a2c-b646-4b448ef3ba14', 'a6237a60-3245-4ca0-a5fd-282065d1ecc9', 'migrationsverket-atervandringsbidrag', 'Migrationsverket — Stöd vid frivillig återvandring', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Den som har uppehållstillstånd som flykting eller skyddsbehövande (samt vissa anhöriga) och frivilligt vill återvandra permanent kan ansöka om bidrag till resa och återetablering. Schablonbeloppen är beslutade att höjas väsentligt från 2026 — kontrollera aktuella belopp och villkor hos Migrationsverket innan beslut. Beslutet att återvandra är oåterkalleligt i bidragshänseende: uppehållstillståndet återkallas normalt.', 'Möjliggöra frivillig, värdig återvandring för den som själv vill.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Migrationsverket före utresan.', 'https://www.migrationsverket.se/', 'none', 'assisted', 3, '', 'published', '74b0ca57-e477-4950-bf13-07afe35b4e45', '50c21a38-27dd-47d9-9688-4b32b8575a12', 'https://www.migrationsverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.749911+00', '2026-08-29 00:51:26.749911+00', NULL, NULL),
	('aec964e1-b795-40c2-a954-e4b7ca0f5d00', '3b945b80-de20-4135-be2a-5408dc8c676b', '4c2a2739-e038-407b-be8a-a475df74c2e3', 'jordbruksverket-investeringsstod', 'Jordbruksverket — Investeringsstöd för jordbruk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Investeringsstöd kan sökas för t.ex. djurstallar, växthus, energieffektivisering och miljöåtgärder i jordbruksföretag. Villkor, stödandelar och regionala prioriteringar framgår av aktuell stödinformation hos Jordbruksverket.', 'Konkurrenskraftigt och hållbart jordbruk.', 'public_grant', '["company", "individual", "economic_association"]', '["SE"]', '["agriculture", "environment"]', NULL, NULL, 'SEK', 40, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', '6c02d482-d879-4a3a-a160-b56093f34c27', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.550373+00', '2026-08-29 00:51:26.550373+00', NULL, NULL),
	('4955c52c-9cbc-46b9-b36a-80366f8b670e', 'cca68a01-b5f4-4c44-9d7e-0316efa9b733', '9f953180-dca0-4f15-89e2-7d0a46ebc2dd', 'esf-kompetensutveckling', 'Svenska ESF-rådet — ESF+ projektstöd för kompetensutveckling och omställning', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Svenska ESF-rådet utlyser projektmedel ur Europeiska socialfonden+ i regionala och nationella utlysningar, t.ex. kompetensutveckling för anställda och insatser för personer långt från arbetsmarknaden. Villkor och medfinansieringskrav framgår per utlysning i utlysningsplanen.', 'En väl fungerande och inkluderande arbetsmarknad.', 'eu_grant', '["company", "association", "municipality", "region", "public_body", "university"]', '["SE"]', '["education", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i ESF-rådets Projektrummet när en utlysning är öppen.', 'https://www.esf.se/utlysningar/', 'none', 'assisted', 15, '', 'published', '186d86d7-0c67-4955-8ab1-d5bec30076a4', '876afae4-dfb9-4f44-b01d-d657f6bfc097', 'https://www.esf.se/utlysningar/utlysningsplan/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.555925+00', '2026-08-29 00:51:26.555925+00', NULL, NULL),
	('0f905278-8d79-44d7-a291-102c13d07464', 'd3a4ef8a-3762-4da9-a832-a8421bbcf595', '2ff8e757-a05d-41b4-b5ac-d2ff69d60dea', 'energimyndigheten-industriklivet', 'Energimyndigheten — Industriklivet', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Industriklivet stödjer forskning, förstudier och investeringar som minskar industrins processrelaterade utsläpp samt negativa utsläpp (t.ex. bio-CCS). Söks löpande eller i utlysningar via Mina sidor.', 'Industrins klimatomställning.', 'public_grant', '["company", "university", "public_body"]', '["SE"]', '["energy", "environment"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 15, '', 'published', '60a98b61-ce2a-4238-919d-3001c5f16032', 'eb432f5d-0999-43b7-9f2c-dbbc3f201517', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.562303+00', '2026-08-29 00:51:26.562303+00', NULL, NULL),
	('e8ff528a-11af-4d20-82ec-c063e0f512f6', '58d0414d-119a-4f14-b1a2-01668af0297f', 'd9dd5bbf-17e2-4ba1-b446-1ec2b22c8513', 'naturvardsverket-klimatklivet', 'Naturvårdsverket — Klimatklivet', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Klimatklivet ger investeringsstöd till företag, kommuner, regioner och organisationer för åtgärder som ger stor klimatnytta per stödkrona — t.ex. laddinfrastruktur, biogas och energikonvertering. Ansökningsomgångar öppnar flera gånger per år.', 'Minskade växthusgasutsläpp.', 'public_grant', '["company", "municipality", "region", "association", "economic_association", "public_body"]', '["SE"]', '["environment", "energy"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänst när en omgång är öppen (kräver e-legitimation).', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 8, '', 'published', '924acb2e-9112-4293-8b34-73eabdf60a66', '8fcc8e09-bb9f-46f5-a56a-90c2e6c2d213', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.568808+00', '2026-08-29 00:51:26.568808+00', NULL, NULL),
	('198d8d6c-44aa-499c-ac8a-c10015ad87a9', '58d0414d-119a-4f14-b1a2-01668af0297f', 'e1b4d2e0-8d8c-4588-950e-6b1f837dc43f', 'naturvardsverket-lona', 'Naturvårdsverket — Lokala naturvårdssatsningen (LONA)', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'LONA ger upp till 50 % (våtmarksprojekt upp till 90 %) i bidrag till naturvårds- och friluftslivsprojekt. Kommunen ansöker hos länsstyrelsen, men lokala föreningar kan initiera projekt genom sin kommun.', 'Lokalt naturvårdsengagemang och friluftsliv.', 'public_grant', '["municipality"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Kommunen ansöker via länsstyrelsen; föreningar initierar via sin kommun.', 'https://www.naturvardsverket.se/bidrag/', 'none', 'assisted', 6, '', 'published', 'b793eb84-8b4b-4681-b11f-204574a2e105', '8fcc8e09-bb9f-46f5-a56a-90c2e6c2d213', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.574454+00', '2026-08-29 00:51:26.574454+00', NULL, NULL),
	('1242e318-cd06-48a6-bbbb-4806d4cdc374', 'b11b2d34-56de-4cfe-af50-d3dfd9997dcb', 'a9e7b4ba-fc74-44fd-ae5a-39abc9d8ad75', 'mucf-solidaritetskaren-volontarprojekt', 'MUCF — Europeiska solidaritetskåren: volontärprojekt', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Europeiska solidaritetskåren finansierar volontärprojekt där unga 18–30 år gör volontärtjänst i ett annat land eller i Sverige. Organisationen behöver en kvalitetsmärkning (Quality Label) och ett OID. MUCF är nationellt programkontor.', 'Ungas engagemang och solidaritet i Europa.', 'eu_grant', '["association", "municipality", "public_body"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login, OID och Quality Label).', 'https://www.mucf.se/bidrag', 'eu_login', 'assisted', 12, '', 'published', '1546506b-adf0-48bf-8f6a-88ca378aba85', 'c7ffcbec-3811-454a-ba00-87878fe6eac0', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.579722+00', '2026-08-29 00:51:26.579722+00', NULL, NULL),
	('6b410cf5-2dbd-4f63-9c77-004925ffc694', 'a4392274-1c63-4de7-9227-bc612fbf2939', '1945751b-63c1-46de-808f-ccbff3aac6b0', 'erasmus-mobilitet-skola-vuxen', 'Erasmus+ — Mobilitet för skola och vuxenutbildning (KA1)', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Erasmus+ KA1 ger skolor, förskolor och vuxenutbildningsorganisationer stöd för kompetensutveckling utomlands — jobbskuggning, kurser och undervisningsuppdrag samt elevmobilitet. UHR är nationellt programkontor för utbildningsdelen. Kräver OID; årliga ansökningsomgångar.', 'Internationalisering av svensk utbildning.', 'eu_grant', '["school", "municipality", "company", "association", "public_body"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://www.uhr.se/internationella-mojligheter/', 'eu_login', 'assisted', 12, '', 'published', 'd7f1d17b-0fa9-47b7-9e56-9aa86873ec8b', '7c518b3f-dc45-4dca-a0f7-6389ae83dd5b', 'https://www.uhr.se/internationella-mojligheter/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.584945+00', '2026-08-29 00:51:26.584945+00', NULL, NULL),
	('e19104fa-6c9a-4bfb-8b0c-44dbc773360b', '5324fe9f-2625-4ee3-9ade-e690b048dd35', '46e15631-66fb-47d9-b5a3-6ae58fb97ed4', 'kreativa-europa-samarbetsprojekt', 'Kreativa Europa — Europeiska samarbetsprojekt (kultur)', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Kreativa Europas kulturprogram finansierar samarbetsprojekt mellan kulturorganisationer i minst tre programländer. Kulturrådet är kontaktkontor i Sverige för kulturdelen. Ansökan görs i EU:s Funding & Tenders-portal; årliga utlysningar.', 'Europeiskt kultursamarbete och cirkulation av konstnärliga verk.', 'eu_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', 80, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s Funding & Tenders-portal (kräver EU Login och PIC/OID).', 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'eu_login', 'assisted', 25, '', 'published', 'd9556ce2-a1f3-48f1-8a3c-f29e4caa2d10', NULL, 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.590212+00', '2026-08-29 00:51:26.590212+00', NULL, NULL),
	('e0e9a726-21da-4f87-af24-38748de98344', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', '9516b937-17fc-4a47-97d8-271062db5299', 'kulturradet-verksamhetsbidrag-scenkonst', 'Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Verksamhetsbidraget riktar sig till professionella fria scenkonstaktörer med kontinuerlig verksamhet av hög kvalitet. Söks i årlig omgång hos Kulturrådet.', 'Ett starkt fritt scenkonstliv i hela landet.', 'public_grant', '["association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 10, '', 'published', 'fd73006d-b9a2-4060-aa7d-cd73c585c2fb', '4e04f263-c25c-4500-a65c-5baf44148a2f', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.595969+00', '2026-08-29 00:51:26.595969+00', NULL, NULL),
	('6d619133-7c4e-4e5c-b3d3-eb1c817dd5f4', '3d781c3a-47ad-4402-aefc-68d920a0a0a0', '5ce57c4d-5850-4134-801b-99fa5498d865', 'vinnova-planeringsbidrag-eu', 'Vinnova — Planeringsbidrag för EU-ansökningar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Vinnova erbjuder återkommande planeringsbidrag som sänker tröskeln för svenska organisationer att söka EU-finansiering, t.ex. inför Horisont Europa-utlysningar och EIC Accelerator. Villkor per aktuell utlysning.', 'Ökat svenskt deltagande i EU:s ramprogram.', 'public_grant', '["company", "university", "public_body", "association"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst när en omgång är öppen.', 'https://www.vinnova.se/soka-finansiering/', 'none', 'assisted', 6, '', 'published', 'd45cb393-a099-4574-bb83-0d9dec7ddab1', '6ad2aa7f-a44d-4e4f-a0b6-f57dcbdc4d80', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.601544+00', '2026-08-29 00:51:26.601544+00', NULL, NULL),
	('11248c93-a2ed-4a26-9a1b-b024c4ae4fe8', 'b11b2d34-56de-4cfe-af50-d3dfd9997dcb', 'd3f75bd8-2e24-4b1a-bb39-d58b0b641682', 'mucf-organisationsbidrag', 'MUCF — Organisationsbidrag till barn- och ungdomsorganisationer', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Organisationsbidraget söks årligen av nationella barn- och ungdomsorganisationer som uppfyller krav på bl.a. medlemsantal, åldersstruktur, demokratisk uppbyggnad och geografisk spridning. Villkoren framgår av förordning och MUCF:s anvisningar.', 'Ett starkt och självständigt ungdomscivilsamhälle.', 'public_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', 'b3a60b75-f8a1-4946-926d-9953252fe70d', 'c7ffcbec-3811-454a-ba00-87878fe6eac0', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.606607+00', '2026-08-29 00:51:26.606607+00', NULL, NULL),
	('ebf624c6-e356-4f65-abdc-9355e0d87583', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '0c0ce694-b995-49b4-943d-642d2598a9d5', 'fk-bostadsbidrag-barnfamiljer', 'Försäkringskassan — Bostadsbidrag till barnfamiljer', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Bostadsbidrag kan lämnas till barnfamiljer med lägre inkomster som betalar för sitt boende. Beloppet beror på inkomst, boendekostnad, bostadens storlek och antal barn. Ansökan görs hos Försäkringskassan; bidraget är preliminärt och stäms av mot taxerad inkomst i efterhand.', 'Ekonomisk trygghet i boendet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '498441d3-1428-44e7-9909-fcdb56d7123d', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.611835+00', '2026-08-29 00:51:26.611835+00', 'Beror på inkomst, boendekostnad och antal barn. Bostadskostnad räknas upp till 6 800 kr/mån vid 1 barn, 7 900 kr vid 2 barn och 8 600 kr vid 3 eller fler.', 'https://www.forsakringskassan.se/privatperson/familj-och-barn/bostadsbidrag-for-barnfamiljer/ansok-om-bostadsbidrag-for-barnfamiljer'),
	('8ba44ea9-2f57-4a2b-b5af-a48f1ebe154e', 'e908b93d-0526-467c-a510-235ec0c217ab', 'b4b56dff-b8c1-4f87-99ef-81f53db94bae', 'region-glasogonbidrag-barn', 'Din region — Glasögonbidrag för barn och unga (8–19 år)', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Alla regioner är enligt lag (2016:35) skyldiga att ge bidrag för glasögon eller kontaktlinser till barn och unga 8–19 år som behöver synhjälpmedel. Lagen fastställer inget nationellt belopp — nivån bestäms per region och varierar. Ansökan sker oftast via optikern eller direkt till regionen — rutinerna skiljer sig, kontrollera din regions sidor och aktuellt belopp via 1177.', 'Alla barn ska ha råd med de synhjälpmedel de behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Vanligen via optikern eller regionens e-tjänst — se din regions rutin på 1177.se.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', '04de7026-5ed4-4277-be8c-d3efcc8d2554', 'ca8f4df0-05a5-4720-abb9-852cc3b7dd9c', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.617346+00', '2026-08-29 00:51:26.617346+00', NULL, NULL),
	('30d11949-6313-4065-8343-6dd2c89361d0', '7c223625-c6cf-49bb-94ec-0a50c07b5576', '636fcd19-14a9-4792-927a-f26d293c9ff4', 'majblomman-bidrag-barn', 'Majblomman — Bidrag till barn i familjer där pengarna inte räcker', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Majblommans lokalföreningar ger bidrag till barn upp till 18 år i familjer med knapp ekonomi. Det kan gälla en fritidsaktivitet, en cykel, kläder, en klassresa eller något annat konkret som barnet behöver. Ansökan görs till den lokala majblommeföreningen där barnet bor och kan göras av vårdnadshavare eller via t.ex. skolsköterska.', 'Alla barn ska kunna delta i sådant som andra barn tar för givet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan till din lokala majblommeförening via majblomman.se.', 'https://majblomman.se/', 'none', 'assisted', 1, '', 'published', '948836fe-e1b8-487a-9ab0-bd0f1107e593', '12c0ac62-8581-4d6a-8a9a-2eba3f6f3aa7', 'https://majblomman.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.622629+00', '2026-08-29 00:51:26.622629+00', NULL, NULL),
	('4fde6677-6df1-4fa3-ad75-f9908f56eccb', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'd0f67566-daf3-4db9-9f3c-c564ed94119e', 'kommun-skolskjuts', 'Din kommun — Skolskjuts i grundskolan', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Elever i grundskolan har enligt skollagen (10 kap. 32 §) rätt till kostnadsfri skolskjuts från hemkommunen om det behövs på grund av färdvägens längd, trafikförhållanden, funktionsnedsättning eller någon annan särskild omständighet. Kommunerna har egna avståndsgränser och rutiner — ansökan görs hos barnets hemkommun.', 'Alla barn ska kunna ta sig till skolan utan kostnad när vägen är lång eller osäker.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos barnets hemkommun (e-tjänst eller blankett).', 'https://www.skolverket.se/', 'none', 'assisted', 1, '', 'published', 'a1e09cf1-b86c-406e-a4d4-7008db46f042', '6041c394-ddb7-49b1-8d59-44213c116f4a', 'https://www.skolverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.62756+00', '2026-08-29 00:51:26.62756+00', NULL, NULL),
	('0e140a7c-0699-42b6-9951-f81de9e97846', 'd136ab5a-1fba-410f-a96e-3fd26f446c31', '333d0958-051f-4e2f-a8ee-258500408e0a', 'pm-bostadstillagg', 'Pensionsmyndigheten — Bostadstillägg för pensionärer', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Bostadstillägg kan lämnas till den som tar ut hel allmän pension och har låga inkomster i förhållande till sin boendekostnad. Många som har rätt till tillägget söker det aldrig — det är värt att kontrollera. Ansökan görs hos Pensionsmyndigheten.', 'Ekonomisk trygghet i boendet för pensionärer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Pensionsmyndighetens webbplats (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '9a627d87-c81e-4716-a1bf-6d899432ffa8', '56a08fcd-c2f5-4344-8f91-b126bf54b285', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.662487+00', '2026-08-29 00:51:26.662487+00', NULL, NULL),
	('852cb486-9e15-40f7-ad8b-42fd6257e13c', 'd136ab5a-1fba-410f-a96e-3fd26f446c31', 'd7703a1c-b399-414e-8bc0-26a5b38cb036', 'pm-aldreforsorjningsstod', 'Pensionsmyndigheten — Äldreförsörjningsstöd', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Äldreförsörjningsstöd kan lämnas från riktåldern för pension (67 år från 2026) till den som inte får sina grundläggande behov tillgodosedda genom pension och andra inkomster. Prövas tillsammans med bostadstillägg. Ansökan görs hos Pensionsmyndigheten.', 'Skälig levnadsnivå för äldre.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Pensionsmyndigheten (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '39d6df56-7952-43e1-ac4b-0b23972bf32e', '56a08fcd-c2f5-4344-8f91-b126bf54b285', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.667262+00', '2026-08-29 00:51:26.667262+00', NULL, NULL),
	('907ff8ba-6609-4fc0-9bb3-a03db3135734', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', '772d89c3-0b3d-4f08-bfa8-c657a673d5ac', 'af-stod-start-naringsverksamhet', 'Arbetsförmedlingen — Stöd till start av näringsverksamhet', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Den som är inskriven som arbetssökande och bedöms ha goda förutsättningar att driva företag kan få stöd (aktivitetsstöd) under verksamhetens uppstartsfas. Beslut fattas av Arbetsförmedlingen efter prövning av affärsplanen.', 'Väg från arbetslöshet till egen försörjning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Arbetsförmedlingen — kontakta din handläggare.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 5, '', 'published', '68c68198-8d31-4b74-8844-04ce1cf4120d', 'c3959729-46d2-492f-94d3-ae4c8d1703a0', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.672659+00', '2026-08-29 00:51:26.672659+00', NULL, NULL),
	('400960a3-b232-41ea-8268-696ee266bbc3', '0ef7acfa-9322-4818-9f67-b920daa08581', '951b8b77-fe46-4808-a6f7-8d594af2f7fc', 'csn-omstallningsstudiestod', 'CSN — Omställningsstudiestöd', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Omställningsstudiestödet riktar sig till dig som arbetat länge och vill studera för att bli mer attraktiv på arbetsmarknaden. Kräver bl.a. etablering på arbetsmarknaden (arbetade år) och att utbildningen stärker din framtida ställning. Söktrycket är högt och handläggningstiderna kan vara långa.', 'Omställning och kompetensutveckling mitt i arbetslivet.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN; omställningsorganisationen kan komplettera med kollektivavtalat stöd.', 'https://www.csn.se/', 'eid', 'assisted', 3, '', 'published', '640f8a1a-4416-4141-9beb-56b005051780', 'bc9ee322-f144-46dd-890c-23e815cfdc7a', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.678628+00', '2026-08-29 00:51:26.678628+00', NULL, NULL),
	('6ae1c899-5fe0-45aa-ab69-5d80a6af1d85', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', '9d3d6879-7c62-46e3-a740-c5f527ba9a08', 'kommun-elevresor-gymnasiet', 'Din kommun — Stöd för elevresor på gymnasiet', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Enligt lag (1991:1110) ska hemkommunen ansvara för kostnader för dagliga resor mellan bostaden och gymnasieskolan för elever med studiehjälp, om färdvägen är minst sex kilometer. Stödet ges oftast som busskort/resekort och söks hos hemkommunen.', 'Gymnasieelever ska kunna ta sig till skolan oavsett var de bor.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos elevens hemkommun, vanligen inför varje läsår.', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'none', 'assisted', 1, '', 'published', '6768b3a2-c81a-48d6-9fdf-206536831a01', '54c4c8c0-c808-4e45-bdfb-9ab953aeceb2', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.633218+00', '2026-08-29 00:51:26.633218+00', NULL, NULL),
	('5b97cddb-ca0e-491b-a920-311c88591982', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '0c0ce694-b995-49b4-943d-642d2598a9d5', 'fk-bostadsbidrag-unga', 'Försäkringskassan — Bostadsbidrag för unga (18–28 år)', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Unga mellan 18 och 28 år utan barn kan få bostadsbidrag om inkomsten är låg och boendekostnaden tillräckligt hög. Ansökan görs hos Försäkringskassan.', 'Ekonomisk trygghet i boendet för unga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '02a5f773-caa0-4f3f-9ed4-7b58ac07a3cc', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.637515+00', '2026-08-29 00:51:26.637515+00', 'Högst 1 300 kr/mån. Kräver att årsinkomsten är högst 86 720 kr (103 720 kr tillsammans med make eller sambo) och att boendet kostar mer än 1 800 kr/mån.', 'https://www.forsakringskassan.se/privatperson/studerande/bostadsbidrag-till-unga-under-29-ar'),
	('e9167b6c-adae-4e91-a1dd-cf417419ba38', '0c3fab7d-16ce-4e8e-a526-145053a0c8d5', '82fa15c4-1afd-4194-a7e3-bf05970484ba', 'kommun-forsorjningsstod', 'Socialtjänsten — Försörjningsstöd (ekonomiskt bistånd)', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Försörjningsstöd kan beviljas av socialtjänsten i din kommun när du inte kan försörja dig själv och saknar tillgångar som kan täcka behoven. Stödet prövas individuellt utifrån hela hushållets ekonomi, och du förväntas först ha sökt andra ersättningar du kan ha rätt till. Ansökan görs hos din kommun.', 'Skälig levnadsnivå enligt socialtjänstlagen.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos socialtjänsten i din kommun — ofta via kommunens e-tjänst eller ett bokat besök.', 'https://www.socialstyrelsen.se/', 'none', 'assisted', 2, '', 'published', '4ef85eed-9f17-465e-936c-4145886a4270', '1979f0fb-447b-4806-84f3-c9d01d14a676', 'https://www.socialstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.642186+00', '2026-08-29 00:51:26.642186+00', NULL, NULL),
	('e31683f9-d952-4386-8ddc-c30becfdec42', '0ef7acfa-9322-4818-9f67-b920daa08581', 'deae9b06-d4fd-4221-bc9f-26d38913bad3', 'csn-studiemedel', 'CSN — Studiemedel (bidrag och studielån)', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Studiemedel består av en bidragsdel och en frivillig lånedel för studier i Sverige eller utomlands. Kraven gäller bl.a. studiernas omfattning, tidigare studieresultat och ålder. Ansökan görs hos CSN.', 'Ekonomiska möjligheter att studera.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Mina sidor hos CSN (kräver e-legitimation).', 'https://www.csn.se/', 'eid', 'assisted', 1, '', 'published', 'd8187afc-710d-4893-8297-d913df3030df', 'bc9ee322-f144-46dd-890c-23e815cfdc7a', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.646826+00', '2026-08-29 00:51:26.646826+00', NULL, NULL),
	('8cd35f7d-ae52-4807-8329-3cc924bb3027', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '2d0a6325-c928-4759-93de-f0a2fe0ddc44', 'fk-aktivitetsersattning', 'Försäkringskassan — Aktivitetsersättning vid nedsatt arbetsförmåga', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Aktivitetsersättning kan lämnas till den som är 19–29 år och har arbetsförmågan nedsatt med minst en fjärdedel under minst ett år. Läkarutlåtande krävs. Ansökan görs hos Försäkringskassan; beslutet fattas efter medicinsk utredning.', 'Ekonomisk trygghet vid långvarigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan tillsammans med läkarutlåtande.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '7bff466d-7aa6-45ab-91d5-850dc4824b12', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.652618+00', '2026-08-29 00:51:26.652618+00', NULL, NULL),
	('ba9cb75e-c5e1-4785-888c-b3f959d062a4', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '392d38f0-a3ea-417d-abc0-6c61954f4d9d', 'fk-underhallsstod', 'Försäkringskassan — Underhållsstöd', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Underhållsstöd kan lämnas när föräldrar inte bor ihop, barnet bor varaktigt hos dig och den andra föräldern inte betalar underhållsbidrag eller betalar mindre än stödets nivå. Ansökan görs hos Försäkringskassan.', 'Barnets försörjning när underhåll uteblir.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'a45300a0-341a-429c-a1c4-6b11941639a9', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.657714+00', '2026-08-29 00:51:26.657714+00', '1 673 kr/mån till och med månaden barnet fyller 7 år, 1 823 kr till och med 15 år, därefter 2 223 kr/mån. Avser fullt underhållsstöd.', 'https://www.forsakringskassan.se/privatperson/familj-och-barn/foraldrar-som-inte-lever-ihop/om-den-som-ska-betala-underhall-inte-kan-eller-vill-betala'),
	('feb697d1-0ec2-4c29-a773-b973fb6bf623', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', '53d0ccdb-cad1-4e73-8602-73331cd990c2', 'kommun-bostadsanpassningsbidrag', 'Din kommun — Bostadsanpassningsbidrag', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Bostadsanpassningsbidraget är ett kommunalt bidrag enligt lag för den som har en bestående funktionsnedsättning och behöver anpassa sin permanentbostad. Intyg från t.ex. arbetsterapeut krävs. Ansökan görs hos kommunen.', 'Självständigt liv i egen bostad.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos din kommun, ofta via e-tjänst eller blankett, med intyg.', 'https://www.boverket.se/sv/bidrag--garantier/', 'none', 'assisted', 3, '', 'published', 'f2b8c839-944b-44e2-abe1-c35e2c2e3ce4', NULL, 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.683844+00', '2026-08-29 00:51:26.683844+00', NULL, NULL);
INSERT INTO public.funding_opportunities VALUES
	('2ef27dfa-fbd2-432e-b1aa-2cff8121df89', 'cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', 'af526fb4-b90f-459b-8c52-eb466ae6dd42', 'konstnarsnamnden-kulturbryggan', 'Konstnärsnämnden — Kulturbryggan', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Kulturbryggan är Konstnärsnämndens stöd till kulturprojekt som är nyskapande i förhållande till etablerade uttryck och strukturer. Söks i utlysningsomgångar av både enskilda och organisationer.', 'Förnyelse och experiment i kulturlivet.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 8, '', 'published', '34d8080f-22d1-474b-a0df-38121937fb98', '23956d5f-6f03-4bfc-9c2a-2fa3a17fd7e9', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.689071+00', '2026-08-29 00:51:26.689071+00', NULL, NULL),
	('76e44e84-a3fa-45dc-b97a-018b70209e89', '86d2ddcc-9d26-4927-80f2-4671d7bfe833', '0c112ae8-781d-4700-aadf-6b7be919a4d0', 'raa-kulturarvsbidrag', 'Riksantikvarieämbetet — Bidrag till kulturarvsarbete', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Riksantikvarieämbetet fördelar årligen bidrag till ideellt kulturarvsarbete — t.ex. hembygdsrörelsen och arbetslivsmuseer. Årlig ansökningsomgång.', 'Ett levande och tillgängligt kulturarv.', 'public_grant', '["association", "foundation"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.raa.se/', 'none', 'assisted', 6, '', 'published', '7f9597aa-0b06-4080-b3ca-9eab248e8362', '7dc08288-fb83-4363-913f-ed5cbd3ba4cc', 'https://www.raa.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.694008+00', '2026-08-29 00:51:26.694008+00', NULL, NULL),
	('e53f78a0-2b6c-47e9-86b2-40699b80f7ad', '3afd736e-6538-41a9-80a3-5e2469ee928b', 'c9b95e42-c9d8-41d7-b248-1f199900a9c3', 'si-creative-force', 'Svenska institutet — Creative Force', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Creative Force ger stöd till svenska organisationers samarbetsprojekt med partner i vissa länder, där kultur eller media används som verktyg för demokrati, jämlikhet och yttrandefrihet. Länderlista och villkor per utlysning.', 'Demokrati och yttrandefrihet genom kultur och media.', 'project_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://si.se/', 'none', 'assisted', 10, '', 'published', '628f452f-acab-49b1-ae79-60777151a0f0', 'adb2a3dc-635c-407f-8a44-0c2c11b73b50', 'https://si.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.699871+00', '2026-08-29 00:51:26.699871+00', NULL, NULL),
	('8f0b862f-211f-4605-ad2c-72e6ee8fdee8', '4bc38c33-8fa0-4b0c-b50d-fd15992bd0db', '3a163d1d-166d-4956-b56e-e558c36cfa2d', 'nordisk-kulturfond-projektstod', 'Nordisk kulturfond — Projektstöd', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Nordisk kulturfond stödjer projekt som utvecklar konst- och kulturlivet i Norden och involverar flera nordiska länder. Flera ansökningsfrister per år.', 'Ett dynamiskt nordiskt konst- och kulturliv.', 'project_grant', '["individual", "association", "company", "public_body"]', '["SE", "DK", "NO", "FI", "IS"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.nordiskkulturfond.org/', 'none', 'assisted', 8, '', 'published', 'a0e650ce-d48a-4fb4-941e-f9a0d587fb3f', '4b28b12f-a87c-4bd7-87a7-2534e51e6f65', 'https://www.nordiskkulturfond.org/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.705429+00', '2026-08-29 00:51:26.705429+00', NULL, NULL),
	('ba48f852-da3b-496c-8ff0-0a998745e437', '1a3a4fea-4170-4f67-afbe-69782a79c836', '61d40a1f-f87c-4850-b3f2-9e55754effdd', 'vr-projektbidrag', 'Vetenskapsrådet — Projektbidrag (fri forskning)', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Vetenskapsrådets projektbidrag söks av disputerade forskare via svenska lärosäten i årliga utlysningar per ämnesområde.', 'Forskning av högsta vetenskapliga kvalitet.', 'public_grant', '["university"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.vr.se/', 'none', 'assisted', 20, '', 'published', '8552163c-923d-4746-ade9-03ddf32e466c', 'cbf004c3-9c86-483e-b5bf-857eb6da3c20', 'https://www.vr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.710193+00', '2026-08-29 00:51:26.710193+00', NULL, NULL),
	('2e231444-342a-492b-90d4-8972fae42b6a', '1287f5d9-dff5-44ae-a7d8-45c8831165af', '025b791f-86c6-43c8-86eb-ffce6c8cd87f', 'postkodstiftelsen-projektstod', 'Svenska Postkodstiftelsen — Projektstöd', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Postkodstiftelsen stödjer ideella organisationer med projekt inom bl.a. mänskliga rättigheter, miljö och kultur. Ansökan kan lämnas löpande via stiftelsens webbplats.', 'Positiv förändring för människor och miljö.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "environment", "culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://postkodstiftelsen.se/', 'none', 'assisted', 8, '', 'published', '802d0780-e66f-4d8b-adfa-4a3cb137c350', 'e4534d9c-f899-4d64-b82b-aeb2ab7ee25e', 'https://postkodstiftelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.714732+00', '2026-08-29 00:51:26.714732+00', NULL, NULL),
	('43d56b50-b052-4ade-9684-23d7ca7a9c53', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', '38034e00-aada-48e0-897e-913b77aec036', 'af-eures-targeted-mobility', 'EURES — Targeted Mobility Scheme (jobb i annat EU-land)', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU:s riktade rörlighetsprogram hjälper arbetssökande från 18 år att ta anställning i ett annat EU-/EES-land. Stödet kan omfatta bidrag till intervjuresa, flytt, språkkurs och erkännande av kvalifikationer — beloppen är schabloner per insats och land och varierar per programperiod. Vägen in är EURES-rådgivarna hos Arbetsförmedlingen.', 'Rörlighet på den europeiska arbetsmarknaden.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta en EURES-rådgivare via Arbetsförmedlingen — ansökan görs innan flytten/resan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '76798e02-22ea-4575-a5ad-1546788e54f5', 'c3959729-46d2-492f-94d3-ae4c8d1703a0', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.759765+00', '2026-08-29 00:51:26.759765+00', NULL, NULL),
	('f36d31cc-a2d8-4f69-a080-0bc1457bfda1', '0ef7acfa-9322-4818-9f67-b920daa08581', 'deae9b06-d4fd-4221-bc9f-26d38913bad3', 'csn-utlandsstudier', 'CSN — Studiemedel för utlandsstudier', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Studiemedel kan tas med till studier utomlands på utbildningar som uppfyller CSN:s krav. Utöver ordinarie bidrag och lån finns merkostnadslån för undervisningsavgifter, resor och försäkring. Utbildningen och skolan ska vara godkänd — kontrollera i CSN:s tjänst innan du tackar ja till en plats.', 'Göra utlandsstudier möjliga oavsett privatekonomi.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN med e-legitimation.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '17d40e05-a711-4ae8-87a1-cbbf7c8bcec0', 'bc9ee322-f144-46dd-890c-23e815cfdc7a', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.764135+00', '2026-08-29 00:51:26.764135+00', NULL, NULL),
	('3285e0f1-7dfe-4c53-8a06-f090af76b725', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '899f66a9-2509-4dc7-b832-bc5baa253321', 'fk-omvardnadsbidrag', 'Försäkringskassan — Omvårdnadsbidrag för barn med funktionsnedsättning', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Omvårdnadsbidrag kan lämnas till vårdnadshavare för barn med funktionsnedsättning som behöver mer omvårdnad och tillsyn än jämnåriga. Bidraget finns i fyra nivåer utifrån barnets sammanlagda behov och kan lämnas till och med juni det år barnet fyller 19. Ansökan görs hos Försäkringskassan; ett läkarutlåtande om barnets funktionsnedsättning behövs.', 'Ge föräldrar ekonomiskt utrymme för den extra omvårdnad barnet behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); läkarutlåtande bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', 'af139f3a-6492-494a-9940-bd5990285c54', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.76929+00', '2026-08-29 00:51:26.76929+00', 'Helt bidrag 12 333 kr/mån före skatt. Tre fjärdedels 9 250 kr, halvt 6 167 kr, en fjärdedels 3 083 kr.', 'https://www.forsakringskassan.se/privatperson/e-tjanster-blanketter-och-informationsmaterial/aktuella-belopp'),
	('82623f15-5b9c-4408-87f3-cf9dce70531f', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '8f85893e-1fef-440a-86b7-45299c86b68c', 'fk-merkostnadsersattning', 'Försäkringskassan — Merkostnadsersättning vid funktionsnedsättning', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Merkostnadsersättning kan lämnas när en varaktig funktionsnedsättning medför merkostnader — t.ex. slitage, hjälpmedel, resor eller särskild kost. Ersättningen finns i fem nivåer och kräver att merkostnaderna når upp till en lägsta nivå per år (knuten till prisbasbeloppet). Både vuxna med funktionsnedsättning och vårdnadshavare för barn kan ansöka hos Försäkringskassan.', 'Utjämna de extra kostnader en funktionsnedsättning medför.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); merkostnaderna specificeras.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', 'da299fa4-60ff-4cec-a029-c13fe3062708', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.77452+00', '2026-08-29 00:51:26.77452+00', NULL, NULL),
	('139f4a15-edaf-4a8b-8d1c-f4e4e394e4d7', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '891ca714-c10f-476c-b1a9-d2479dbaa3b9', 'fk-bilstod', 'Försäkringskassan — Bilstöd vid funktionsnedsättning', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Bilstöd kan lämnas till den som har en varaktig funktionsnedsättning med stora svårigheter att förflytta sig på egen hand eller att använda allmänna kommunikationer — och till föräldrar till barn med sådan funktionsnedsättning. Stödet består av flera delar: grundbidrag, inkomstprövat anskaffningsbidrag och anpassningsbidrag för särskild utrustning. Nytt bilstöd kan normalt beviljas först efter nio år.', 'Göra det möjligt att förflytta sig självständigt när kollektivtrafik inte fungerar.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande om funktionsnedsättningen och körkortsuppgifter behövs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '3672dfa3-f389-4e2b-b283-f2de4c80ea25', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.779392+00', '2026-08-29 00:51:26.779392+00', NULL, NULL),
	('d3c40e81-3e19-4764-b364-110e1d5c2bc1', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'fc4e1fc6-ad5a-441d-ae56-2b72d11785bc', 'fk-narstaendepenning', 'Försäkringskassan — Närståendepenning', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Närståendepenning kan lämnas när du avstår från förvärvsarbete för att vårda eller vara nära en närstående med en sjukdom som innebär ett påtagligt hot mot livet. Ersättningen kan betalas i upp till 100 dagar per person som vårdas (dagarna kan delas mellan flera närstående). Läkarutlåtande om den sjukes tillstånd och den sjukes samtycke krävs.', 'Ingen ska behöva välja mellan sin försörjning och att finnas hos en svårt sjuk anhörig.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarutlåtande och den sjukes samtycke bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'a37f7187-332d-4965-85a4-98a18b6f2e0b', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.784638+00', '2026-08-29 00:51:26.784638+00', NULL, NULL),
	('1486ea2a-fac8-44b9-b248-d4c0c9140ea4', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', 'ca75ad04-4fc0-407a-81e3-2d17622f5bcb', 'af-etableringsersattning', 'Arbetsförmedlingen — Etableringsersättning för nyanlända', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Den som nyligen fått uppehållstillstånd (som skyddsbehövande eller vissa anhöriga) och är 20–66 år kan delta i Arbetsförmedlingens etableringsprogram och få etableringsersättning under tiden. Den som har barn eller bor ensam i egen bostad kan även få etableringstillägg respektive bostadsersättning. Arbetsförmedlingen beslutar om programmet; Försäkringskassan beslutar om och betalar ut ersättningen.', 'Försörjning under de första årens etablering i arbets- och samhällslivet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen; ersättningen ansöks sedan hos Försäkringskassan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '967e2163-ecd9-4502-9c2f-b106987c81b8', 'c3959729-46d2-492f-94d3-ae4c8d1703a0', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.789528+00', '2026-08-29 00:51:26.789528+00', NULL, NULL),
	('0b4b4b89-c8af-4361-91c4-aaabcee3473c', '0ef7acfa-9322-4818-9f67-b920daa08581', '02c87711-3734-495a-aa66-06535101cdde', 'csn-hemutrustningslan', 'CSN — Hemutrustningslån för nyanlända', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Hemutrustningslån kan lämnas till flyktingar och vissa anhöriga som tagits emot i en kommun och behöver utrusta ett första hem i Sverige. Lånet söks hos CSN inom två år från det första kommunmottagandet, har låg ränta och betalas tillbaka enligt en plan som tar hänsyn till inkomst. Det är ett lån — inte ett bidrag — och ska betalas tillbaka.', 'Ett fungerande hem från start, utan att behöva vända sig till dyra krediter.', 'loan', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos CSN; kommunmottagandet styr vilka som kan söka.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', 'a75f2add-6218-4728-aa21-61b930bf639d', 'bc9ee322-f144-46dd-890c-23e815cfdc7a', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.794905+00', '2026-08-29 00:51:26.794905+00', NULL, NULL),
	('1555f28b-9594-494d-81c0-4d2c7d5906af', '0ef7acfa-9322-4818-9f67-b920daa08581', 'bb61290b-b4ec-45e6-87a2-4b0cc40a9b70', 'csn-studiestartsstod', 'CSN — Studiestartsstöd för arbetslösa med kort utbildning', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Studiestartsstöd är ett rent bidrag (ingen lånedel) för den som är 25–60 år, har varit arbetslös, har kort tidigare utbildning och behöver studera på grundskole- eller gymnasienivå för att stärka sina chanser till jobb. Stödet kan lämnas i upp till 50 veckor. Hemkommunen bedömer om du tillhör målgruppen; ansökan görs sedan hos CSN.', 'Sänka tröskeln till studier för den som behöver dem mest.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta hemkommunen (målgruppsbedömning) och ansök därefter hos CSN.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '681de72c-ac22-42ad-ae31-4d23e6067795', 'bc9ee322-f144-46dd-890c-23e815cfdc7a', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.799981+00', '2026-08-29 00:51:26.799981+00', NULL, NULL),
	('8676b172-c852-454f-b935-f8b47938e2e8', '0ef7acfa-9322-4818-9f67-b920daa08581', 'ea8a1c6c-e879-4b4f-9bcb-6bb8e2b10234', 'csn-inackorderingstillagg', 'CSN — Inackorderingstillägg för gymnasieelever som bor på studieorten', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Elever på fristående gymnasieskolor och folkhögskolor som måste inackordera sig på studieorten på grund av lång eller besvärlig resväg kan få inackorderingstillägg från CSN. Går eleven på en kommunal gymnasieskola är det i stället hemkommunen som ger stöd till inackordering — kontrollera med kommunen. Tillägget söks för varje läsår.', 'Gymnasievalet ska inte begränsas av var i landet utbildningen finns.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos CSN (fristående skola/folkhögskola) eller hos hemkommunen (kommunal skola), inför varje läsår.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', '6e1c2e8e-69ae-45f4-90c7-3260e9fbe855', 'bc9ee322-f144-46dd-890c-23e815cfdc7a', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.805572+00', '2026-08-29 00:51:26.805572+00', NULL, NULL),
	('a83bf538-f3ec-4693-90d9-a789fc2bd05e', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'a61bc79e-df7c-4dd1-98bf-1f80093ca631', 'kommun-foreningsbidrag', 'Din kommun — Föreningsbidrag (aktivitets-, lokal- och startbidrag)', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'I stort sett alla kommuner ger bidrag till lokala föreningar — vanligast är aktivitetsstöd per deltagartillfälle för barn- och ungdomsverksamhet, bidrag till lokalhyra och startbidrag för nya föreningar. Regler, belopp och ansökningstider skiljer sig åt mellan kommuner; ansökan görs hos kultur- och fritidsförvaltningen i den kommun där föreningen är verksam.', 'Ett levande lokalt föreningsliv med låga trösklar för deltagande.', 'public_grant', '["association"]', '["SE"]', '["civil_society", "sports", "culture", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos kommunens kultur- och fritidsförvaltning — rutiner och tider varierar per kommun.', 'https://www.skr.se/', 'none', 'assisted', 2, '', 'published', 'be65fc46-a297-4d58-9710-93a25f7372c9', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.812786+00', '2026-08-29 00:51:26.812786+00', NULL, NULL),
	('1c866c7e-8c24-4fdb-9caf-2f0d7c21df19', 'e908b93d-0526-467c-a510-235ec0c217ab', 'a8ab4690-a06e-4e9e-ac0f-f1fc22dba01d', 'region-kulturstod', 'Din region — Regionala kulturstöd och projektbidrag', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Alla regioner fördelar egna kulturstöd — projektbidrag, arrangörsstöd och stipendier — inom kultursamverkansmodellen. Stöden riktar sig till kulturaktörer med förankring i regionen och söks direkt hos regionens kulturförvaltning. Utlysningar, belopp och tider varierar per region; kontrollera din regions kultursidor.', 'Ett professionellt och tillgängligt kulturliv i hela regionen.', 'public_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos regionens kulturförvaltning — utlysningar publiceras på regionens webbplats.', 'https://www.skr.se/', 'none', 'assisted', 4, '', 'published', '3bad51dc-c21c-4b61-8cee-8d026c6ba5b6', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.817578+00', '2026-08-29 00:51:26.817578+00', NULL, NULL),
	('33cac5d0-73fa-476f-aa3a-ff82ed272872', '85f53dd8-7fdb-46d0-8f2b-4c980dec62af', '8113dd9d-f4c7-4368-91cb-64c440c6a0fd', 'sparbanksstiftelsen-projektstod', 'Sparbanksstiftelsen i ditt område — Bidrag till lokala projekt', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Sparbanksstiftelserna förvaltar sparbanksrörelsens överskott och delar ut bidrag till projekt som utvecklar det lokala samhället — ofta inom idrott, kultur, utbildning, forskning och näringslivsutveckling. Varje stiftelse beslutar självständigt och stödjer bara projekt i den egna sparbankens verksamhetsområde. Hitta stiftelsen där ni verkar och sök enligt dess rutiner.', 'Lokal utveckling där sparbanken verkar.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "sports", "culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos den sparbanksstiftelse vars område ni verkar i — rutiner varierar per stiftelse.', 'https://www.sparbankerna.se/', 'none', 'assisted', 3, '', 'published', 'fcbd0332-6008-459d-8228-3517565bdfec', '840129c9-e965-48ea-ba84-0225a41971b8', 'https://www.sparbankerna.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.822463+00', '2026-08-29 00:51:26.822463+00', NULL, NULL),
	('0a238082-9bad-4a67-b0b6-d7fc05ea5d09', '3b945b80-de20-4135-be2a-5408dc8c676b', '4f9a8326-0f3e-44e9-bb9a-46baf309cf18', 'leader-lokalt-ledd-utveckling', 'Leader — Projektstöd för lokalt ledd utveckling på landsbygden', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Genom Leader finansieras lokala utvecklingsprojekt på landsbygden med medel från EU och svenska staten. Sverige är indelat i ett fyrtiotal leaderområden med egna utvecklingsstrategier; projektidén söks hos leaderområdets kansli, prioriteras av den lokala LAG-styrelsen och beslutas formellt av Jordbruksverket. Föreningar, företag, kommuner och andra lokala aktörer kan söka.', 'Utveckling av landsbygden utifrån lokala behov och idéer.', 'eu_grant', '["association", "company", "municipality"]', '["SE"]', '["rural", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta ditt leaderområdes kansli; ansökan lämnas i Jordbruksverkets e-tjänst.', 'https://jordbruksverket.se/', 'none', 'assisted', 8, '', 'published', '2a9dcb4e-a120-4be3-87c0-693439833e37', '1e7f3594-2df7-46a7-a196-152d7ac27908', 'https://jordbruksverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.827561+00', '2026-08-29 00:51:26.827561+00', NULL, NULL),
	('88262647-8d83-4ea4-bc98-d712131aeb66', 'dc409620-c5bc-4ca7-9266-8311ac367d87', 'aa2b985b-f719-411b-a606-dfbc0d29c019', 'forte-projektbidrag', 'Forte — Projektbidrag för forskning om hälsa, arbetsliv och välfärd', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Forte är det statliga forskningsrådet för hälsa, arbetsliv och välfärd och utlyser projektbidrag, postdokbidrag och programstöd inom sina områden. Bidragen söks av disputerade forskare och förvaltas av ett svenskt lärosäte eller annan godkänd medelsförvaltare. Årliga öppna utlysningar publiceras på forte.se.', 'Kunskap som förbättrar människors hälsa, arbetsliv och välfärd.', 'public_grant', '["university"]', '["SE"]', '["research"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan i Fortes ansökningssystem Prisma, via medelsförvaltaren.', 'https://forte.se/', 'none', 'assisted', 15, '', 'published', 'bc10038f-e1df-4c20-a19a-2961324a30b2', 'd02a6acf-79eb-4945-b62f-cfd9463c22a8', 'https://forte.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.832974+00', '2026-08-29 00:51:26.832974+00', NULL, NULL),
	('bbc6cdca-3a52-4ffa-99ad-37689c63e8dc', 'a8b1caea-e4d3-42e8-a450-c0259f491585', '68a93589-8b44-4474-96d9-5225df9c2c06', 'radiohjalpen-projektbidrag', 'Radiohjälpen — Projektbidrag ur insamlingskampanjerna', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Radiohjälpen fördelar insamlade medel till projekt som drivs av svenska ideella organisationer med 90-konto: internationella humanitära insatser och utvecklingsprojekt (t.ex. Världens Barn, Musikhjälpen) samt nationella insatser för barn och unga med funktionsnedsättning eller kronisk sjukdom (Victoriafonden — där kan även t.ex. kuratorer söka aktivitets- och lägerbidrag för enskilda barn). Utlysningar och villkor finns på radiohjalpen.se.', 'Insamlade medel ska nå fram genom seriösa organisationer.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan enligt respektive utlysning på radiohjalpen.se.', 'https://www.radiohjalpen.se/', 'none', 'assisted', 6, '', 'published', '6af691ba-2c8a-47b4-a313-91903ea9ddbb', '69eb686f-486c-4d2e-a7f6-5b609f076e8d', 'https://www.radiohjalpen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.838252+00', '2026-08-29 00:51:26.838252+00', NULL, NULL),
	('001a27e8-1efb-4ffd-b2fc-eae50998ecb1', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '392d38f0-a3ea-417d-abc0-6c61954f4d9d', 'fk-barnbidrag', 'Försäkringskassan — Barnbidrag', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Barnbidrag lämnas för barn som bor i Sverige, normalt utan ansökan — det betalas ut automatiskt från månaden efter födseln eller flytten till Sverige. Ansökan behövs i vissa fall, till exempel när barnet flyttar hit eller vid ändrad utbetalningsmottagare. Beloppet per barn och månad framgår hos Försäkringskassan. Från och med det andra barnet lämnas även flerbarnstillägg (egen post).', 'Ekonomisk grundtrygghet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt; ansökan i särskilda fall på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'de95d3fd-9daa-4dba-9a7b-ce2b701fcc87', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.842269+00', '2026-08-29 00:51:26.842269+00', '1 250 kr per barn och månad, delat mellan vårdnadshavarna.', 'https://www.forsakringskassan.se/privatperson/familj-och-barn/barnbidrag-och-flerbarnstillagg/barnbidrag-och-flerbarnstillagg-sa-funkar-det'),
	('833041bb-eb89-40d4-b9df-9b385b7706c3', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '392d38f0-a3ea-417d-abc0-6c61954f4d9d', 'fk-flerbarnstillagg', 'Försäkringskassan — Flerbarnstillägg', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Flerbarnstillägg lämnas automatiskt till den som får barnbidrag för två eller fler barn — ingen separat ansökan behövs i normalfallet. Tillägget ökar med antalet barn; nivåerna framgår hos Försäkringskassan. Den som har barn över 16 år som studerar kan i vissa fall behöva anmäla för fortsatt flerbarnstillägg.', 'Förstärkt stöd till familjer med flera barn.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Betalas normalt ut automatiskt tillsammans med barnbidraget.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '10f16055-b31f-4e76-b090-9269b43f7810', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.846562+00', '2026-08-29 00:51:26.846562+00', 'Utöver barnbidraget: 150 kr/mån vid 2 barn, 730 kr vid 3 barn, 1 740 kr vid 4 barn. Från femte barnet ytterligare 1 250 kr per barn och månad.', 'https://www.forsakringskassan.se/privatperson/e-tjanster-blanketter-och-informationsmaterial/aktuella-belopp'),
	('41839f31-54f1-46eb-ab6e-24102e9f9698', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '392d38f0-a3ea-417d-abc0-6c61954f4d9d', 'fk-foraldrapenning', 'Försäkringskassan — Föräldrapenning', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Föräldrapenning kan tas ut av föräldrar (och i vissa fall andra vårdnadshavare) för tid med barnet, från graviditet tills barnet fyllt tolv år, med flest dagar under de första åren. Ersättningens nivå beror på din inkomst och vilken typ av dagar du tar ut; nivåer och regler framgår hos Försäkringskassan. Ansökan görs i efterhand för de dagar du varit ledig.', 'Möjliggöra föräldraledighet med ersättning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '7c7b0767-c82d-4d87-88b0-3a62c4382583', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.850504+00', '2026-08-29 00:51:26.850504+00', 'Högst 1 259 kr/dag på sjukpenningnivå, lägst 250 kr/dag. Lägstanivådagar ger 180 kr/dag.', 'https://www.forsakringskassan.se/privatperson/e-tjanster-blanketter-och-informationsmaterial/aktuella-belopp'),
	('661ec89f-61e7-4690-a98a-b47d865ca9d2', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '392d38f0-a3ea-417d-abc0-6c61954f4d9d', 'fk-tillfallig-foraldrapenning', 'Försäkringskassan — Tillfällig föräldrapenning (vab)', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Tillfällig föräldrapenning — i dagligt tal vab — kan lämnas när du avstår från arbete för att vårda ett sjukt barn som är under 12 år (i vissa fall äldre). Ersättningen baseras på din inkomst; nivå och antal dagar framgår hos Försäkringskassan. Anmäl första dagen och ansök i efterhand; läkarintyg krävs från åttonde dagen.', 'Göra det möjligt att vårda sjukt barn utan att förlora hela inkomsten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Anmäl och ansök på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '1a057ad3-5f50-405c-ba6a-5085a0fd7d70', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.854696+00', '2026-08-29 00:51:26.854696+00', NULL, NULL),
	('dec6a85d-aca1-4209-bb00-7d48639943a0', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '8abef71e-3a77-46f3-b16b-332ab88713c3', 'fk-sjukpenning', 'Försäkringskassan — Sjukpenning', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Sjukpenning kan lämnas när sjukdom sätter ned din arbetsförmåga med minst en fjärdedel. Anställda får normalt sjuklön från arbetsgivaren de första två veckorna; därefter kan sjukpenning från Försäkringskassan ta vid. Egenföretagare och arbetslösa ansöker direkt. Läkarintyg krävs efter en tid; nivåer och regler framgår hos Försäkringskassan.', 'Försörjning när arbetsförmågan är nedsatt av sjukdom.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarintyg bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '56acf9fd-c239-4c6e-9455-7d2586f7f471', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.859993+00', '2026-08-29 00:51:26.859993+00', NULL, NULL),
	('de7cb791-042e-4e7c-9baa-efcfdbdf112c', '014cef2e-6d22-41ef-805e-5496d4cef9bc', '8abef71e-3a77-46f3-b16b-332ab88713c3', 'fk-sjukersattning', 'Försäkringskassan — Sjukersättning', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Sjukersättning kan lämnas till den som troligen aldrig kommer att kunna arbeta heltid på grund av sjukdom, skada eller funktionsnedsättning. Arbetsförmågan ska vara stadigvarande nedsatt med minst en fjärdedel i förhållande till hela arbetsmarknaden. Ersättningen kan vara inkomstrelaterad eller på garantinivå; regler och nivåer framgår hos Försäkringskassan.', 'Långsiktig försörjning vid varaktigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande krävs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', 'e1c27cbc-1dcc-4e54-8155-f2b8c5ba432c', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.864226+00', '2026-08-29 00:51:26.864226+00', NULL, NULL),
	('65d404be-9005-48ae-a214-20c2a2580974', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'ea0b4d27-eaa3-4ad4-a9fa-890cf09c7d69', 'fk-aktivitetsstod', 'Försäkringskassan — Aktivitetsstöd', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Aktivitetsstöd lämnas till den som deltar i ett program hos Arbetsförmedlingen, till exempel jobb- och utvecklingsgarantin eller arbetsmarknadsutbildning. Arbetsförmedlingen anvisar programmet; Försäkringskassan beslutar om och betalar ut ersättningen, som bland annat beror på om du uppfyller villkoren för a-kassa. Yngre deltagare kan i stället få utvecklingsersättning.', 'Försörjning under program som stärker vägen till arbete.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Programmet anvisas av Arbetsförmedlingen; ersättningen ansöks månadsvis hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'e9f45fdc-d036-44b9-a945-c1c9f70de0d6', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.870203+00', '2026-08-29 00:51:26.870203+00', NULL, NULL),
	('55a665b2-e007-4927-b461-64d74b00ab68', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'e56a9bed-fa92-4d79-8cef-4edadc12437c', 'fk-tandvardsbidrag', 'Försäkringskassan — Allmänt tandvårdsbidrag (ATB)', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Det allmänna tandvårdsbidraget gäller alla från det år de fyller 24 och används automatiskt som avdrag när du besöker en ansluten tandläkare eller tandhygienist — ingen ansökan behövs. Beloppet beror på ålder och kan sparas ett år; nivåerna framgår hos Försäkringskassan. Den med särskilda behov kan därutöver ha rätt till särskilt tandvårdsbidrag.', 'Sänka tröskeln till regelbunden tandvård.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — säg till hos tandvården att du vill använda bidraget.', 'https://www.forsakringskassan.se/privatperson', 'none', 'assisted', 1, '', 'published', 'bd84bf7a-0b8d-4053-ac35-9f5a7d3bdb69', '8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.875852+00', '2026-08-29 00:51:26.875852+00', NULL, NULL),
	('26027711-153c-40ef-b8ad-8abe2723f09a', 'd136ab5a-1fba-410f-a96e-3fd26f446c31', 'ae727024-5fb2-4097-8790-d017f0cb4d90', 'pm-garantipension', 'Pensionsmyndigheten — Garantipension', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Garantipension är ett grundskydd i den allmänna pensionen för den som haft låg eller ingen inkomstgrundad pension. Den betalas normalt ut automatiskt när du ansöker om allmän pension från riktåldern — ingen separat ansökan behövs om du bor i Sverige. Nivån beror på inkomstpensionens storlek, civilstånd och försäkringstid; detaljerna framgår hos Pensionsmyndigheten.', 'Lägsta rimliga pensionsnivå oavsett tidigare inkomster.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingår i ansökan om allmän pension hos Pensionsmyndigheten; prövas automatiskt.', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '9752356f-ec9d-498f-897f-7bed01d16370', '56a08fcd-c2f5-4344-8f91-b126bf54b285', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.880882+00', '2026-08-29 00:51:26.880882+00', NULL, NULL),
	('046bf444-4d02-4f5c-a99f-7bb6fd82a152', 'e908b93d-0526-467c-a510-235ec0c217ab', 'ef9d5574-0cb7-4568-a764-e335db326b73', 'region-hogkostnadsskydd-vard', 'Din region — Högkostnadsskydd för sjukvård', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Högkostnadsskyddet innebär att du under en period på tolv månader aldrig betalar mer än ett takbelopp i patientavgifter för öppen sjukvård; därefter får du frikort för resten av perioden. Registreringen sker normalt automatiskt i regionens system när du betalar. Takbeloppet fastställs årligen — se 1177 för aktuell nivå. Motsvarande skydd finns för läkemedel och sjukresor.', 'Skydda mot höga sammanlagda vårdkostnader.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ingen ansökan — registreras normalt automatiskt i regionens system; spara kvitton vid besök i annan region.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', 'b00068a6-6879-4096-b558-a52788d8f072', 'ca8f4df0-05a5-4720-abb9-852cc3b7dd9c', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.885814+00', '2026-08-29 00:51:26.885814+00', NULL, NULL),
	('909b281b-4d83-4320-a526-b882487327fa', 'aeb2eb40-63ff-4bdc-aa1f-7a31a946ef3c', 'a6c45b36-9af5-4436-ad81-1b4483f785d8', 'akassa-arbetsloshetsersattning', 'Din a-kassa — Arbetslöshetsersättning (a-kassa)', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Arbetslöshetsersättning lämnas av a-kassorna till den som är arbetslös, inskriven hos Arbetsförmedlingen, aktivt söker arbete och uppfyller arbetsvillkoret. Medlemmar som uppfyllt medlemsvillkoret kan få inkomstbaserad ersättning; den som inte är medlem kan ha rätt till grundbelopp via Alfa-kassan. Vilken a-kassa som passar beror på bransch; villkor och nivåer framgår hos din a-kassa och Sveriges a-kassor.', 'Inkomsttrygghet under omställning mellan arbeten.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen första arbetslösa dagen; ansök sedan hos din a-kassa (Mina sidor).', 'https://www.sverigesakassor.se/', 'eid', 'assisted', 1, '', 'published', '491ce70a-d970-4a9a-94ae-f78a8dd1a7b1', 'f09be294-446e-4121-b8ca-eb87c4bbf597', 'https://www.sverigesakassor.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.890915+00', '2026-08-29 00:51:26.890915+00', NULL, NULL),
	('9bcf8bbf-d15e-4419-afc8-c3e118657fd1', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', '2078a0f7-5a8e-4257-857e-a532b7a00e90', 'af-nystartsjobb', 'Arbetsförmedlingen — Nystartsjobb', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Nystartsjobb ger arbetsgivare ett bidrag motsvarande en del av lönekostnaden vid anställning av personer som varit arbetslösa en längre tid, är nyanlända eller av andra skäl varit borta från arbetslivet. Stödets storlek och längd beror på den anställdas situation; villkoren framgår hos Arbetsförmedlingen. Anställningen ska ha marknadsmässiga villkor och beslut ska finnas innan den påbörjas.', 'Sänka tröskeln in på arbetsmarknaden för dem som stått utanför.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', 'ce8407bf-7a48-498a-bccd-99e4c17a64d7', 'c3959729-46d2-492f-94d3-ae4c8d1703a0', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.895621+00', '2026-08-29 00:51:26.895621+00', NULL, NULL),
	('38704d2f-2c8a-4969-ba9e-8711451b057e', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', '2078a0f7-5a8e-4257-857e-a532b7a00e90', 'af-lonebidrag', 'Arbetsförmedlingen — Lönebidrag vid nedsatt arbetsförmåga', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Lönebidrag kan lämnas till arbetsgivare som anställer (eller behåller) en person vars arbetsförmåga är nedsatt av funktionsnedsättning eller ohälsa. Bidraget kompenserar en del av lönekostnaden och kan kombineras med anpassning av arbetet; det finns i flera former (utveckling, trygghet, anställning). Nivå och längd bedöms individuellt av Arbetsförmedlingen.', 'Göra det möjligt att anställa utifrån förmåga, inte hinder.', 'public_grant', '["company", "sole_trader", "association"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Arbetsgivaren ansöker hos Arbetsförmedlingen innan anställningen börjar.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', '636c736a-8cc4-400a-a081-e2d9604ce8d4', 'c3959729-46d2-492f-94d3-ae4c8d1703a0', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-29 00:51:26.899413+00', '2026-08-29 00:51:26.899413+00', NULL, NULL);


--
-- Data for Name: funding_programmes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_programmes VALUES
	('3d78f6a0-eae7-456e-a63a-055bbe048e0b', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'Internationellt kulturutbyte', '', '2026-08-29 00:51:26.441671+00'),
	('1e4ce668-a686-4926-a965-e553e39d398b', '5324fe9f-2625-4ee3-9ade-e690b048dd35', 'Erasmus+ Ungdom', '', '2026-08-29 00:51:26.451031+00'),
	('78e76df2-1d27-4e34-84ab-6ef0eee5ac49', 'b11b2d34-56de-4cfe-af50-d3dfd9997dcb', 'Bidrag till civilsamhället', '', '2026-08-29 00:51:26.457104+00'),
	('bcf7b249-831d-44e8-b1ee-7ce82fa11c22', '3d781c3a-47ad-4402-aefc-68d920a0a0a0', 'Innovativa startups', '', '2026-08-29 00:51:26.463458+00'),
	('38993a1c-d225-42dc-a30f-d89ab01eee09', 'd3a4ef8a-3762-4da9-a832-a8421bbcf595', 'Forskning och innovation för energiomställning', '', '2026-08-29 00:51:26.470486+00'),
	('6ef3ec1a-66f9-465e-9f28-877d2046d0c4', '58d0414d-119a-4f14-b1a2-01668af0297f', 'Klimatinvesteringar', '', '2026-08-29 00:51:26.47614+00'),
	('cc73534c-b6b9-428e-a422-39e7bd7f0949', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'Musik', '', '2026-08-29 00:51:26.483229+00'),
	('70e05a6f-ab06-4b13-8550-f17e55649a0a', 'cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', 'Internationellt kulturutbyte', '', '2026-08-29 00:51:26.490415+00'),
	('893e897f-ec9a-4d96-a66a-ec2778c2d76d', 'cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', 'Arbetsstipendier', '', '2026-08-29 00:51:26.496082+00'),
	('51136e51-70a4-48d9-9f3d-c1ed72a90adc', 'ad6073c0-efaf-4f0c-87ed-394cf15f8369', 'Projektstöd', '', '2026-08-29 00:51:26.502404+00'),
	('8d9d24f5-6036-4270-9edd-144ffc06609c', 'a160a2aa-5ce4-442f-a656-9f0214ddc676', 'Stöd till allmänna samlingslokaler', '', '2026-08-29 00:51:26.507722+00'),
	('20d0018a-d524-4b9e-9753-a6a0ba093032', '4ae0a05d-106c-4ec8-9097-a4b3c81f25aa', 'LOK-stöd', '', '2026-08-29 00:51:26.513448+00'),
	('08c48b26-924e-4c5c-9522-2e3d79904f3a', '713c0c5a-418d-4713-88e3-ca4b7ca03919', 'Produktionsstöd', '', '2026-08-29 00:51:26.519069+00'),
	('a666779b-e339-49cc-a387-7a31943517a2', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'Skapande skola', '', '2026-08-29 00:51:26.524437+00'),
	('ec8da948-da00-4054-a8dc-3236ee05631b', '738eed1c-eac6-475d-95bd-a3790565a559', 'Årliga öppna utlysningen', '', '2026-08-29 00:51:26.530161+00'),
	('00042352-d886-4513-af82-db57ccf7da7d', '796064d4-174e-44d7-9429-13915b689a8d', 'Affärsutvecklingscheckar', '', '2026-08-29 00:51:26.536689+00'),
	('22648352-fdef-4b75-98f8-72d1ad4b0cd7', '3b945b80-de20-4135-be2a-5408dc8c676b', 'Startstöd', '', '2026-08-29 00:51:26.543219+00'),
	('4c2a2739-e038-407b-be8a-a475df74c2e3', '3b945b80-de20-4135-be2a-5408dc8c676b', 'Investeringsstöd', '', '2026-08-29 00:51:26.548646+00'),
	('9f953180-dca0-4f15-89e2-7d0a46ebc2dd', 'cca68a01-b5f4-4c44-9d7e-0316efa9b733', 'ESF+', '', '2026-08-29 00:51:26.554045+00'),
	('2ff8e757-a05d-41b4-b5ac-d2ff69d60dea', 'd3a4ef8a-3762-4da9-a832-a8421bbcf595', 'Industriklivet', '', '2026-08-29 00:51:26.560163+00'),
	('d9dd5bbf-17e2-4ba1-b446-1ec2b22c8513', '58d0414d-119a-4f14-b1a2-01668af0297f', 'Klimatklivet', '', '2026-08-29 00:51:26.566648+00'),
	('e1b4d2e0-8d8c-4588-950e-6b1f837dc43f', '58d0414d-119a-4f14-b1a2-01668af0297f', 'LONA', '', '2026-08-29 00:51:26.572731+00'),
	('a9e7b4ba-fc74-44fd-ae5a-39abc9d8ad75', 'b11b2d34-56de-4cfe-af50-d3dfd9997dcb', 'Europeiska solidaritetskåren', '', '2026-08-29 00:51:26.578058+00'),
	('1945751b-63c1-46de-808f-ccbff3aac6b0', 'a4392274-1c63-4de7-9227-bc612fbf2939', 'Erasmus+ Utbildning', '', '2026-08-29 00:51:26.583226+00'),
	('46e15631-66fb-47d9-b5a3-6ae58fb97ed4', '5324fe9f-2625-4ee3-9ade-e690b048dd35', 'Kreativa Europa', '', '2026-08-29 00:51:26.588357+00'),
	('9516b937-17fc-4a47-97d8-271062db5299', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'Scenkonst', '', '2026-08-29 00:51:26.594339+00'),
	('5ce57c4d-5850-4134-801b-99fa5498d865', '3d781c3a-47ad-4402-aefc-68d920a0a0a0', 'EU-relaterade stöd', '', '2026-08-29 00:51:26.599884+00'),
	('d3f75bd8-2e24-4b1a-bb39-d58b0b641682', 'b11b2d34-56de-4cfe-af50-d3dfd9997dcb', 'Statsbidrag till civilsamhället', '', '2026-08-29 00:51:26.604961+00'),
	('0c0ce694-b995-49b4-943d-642d2598a9d5', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Bostadsbidrag', '', '2026-08-29 00:51:26.610096+00'),
	('b4b56dff-b8c1-4f87-99ef-81f53db94bae', 'e908b93d-0526-467c-a510-235ec0c217ab', 'Glasögonbidrag', '', '2026-08-29 00:51:26.615671+00'),
	('636fcd19-14a9-4792-927a-f26d293c9ff4', '7c223625-c6cf-49bb-94ec-0a50c07b5576', 'Majblommans bidrag', '', '2026-08-29 00:51:26.620975+00'),
	('d0f67566-daf3-4db9-9f3c-c564ed94119e', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'Skolskjuts', '', '2026-08-29 00:51:26.625983+00'),
	('9d3d6879-7c62-46e3-a740-c5f527ba9a08', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'Elevresor', '', '2026-08-29 00:51:26.631351+00'),
	('82fa15c4-1afd-4194-a7e3-bf05970484ba', '0c3fab7d-16ce-4e8e-a526-145053a0c8d5', 'Ekonomiskt bistånd', '', '2026-08-29 00:51:26.640517+00'),
	('deae9b06-d4fd-4221-bc9f-26d38913bad3', '0ef7acfa-9322-4818-9f67-b920daa08581', 'Studiemedel', '', '2026-08-29 00:51:26.645276+00'),
	('2d0a6325-c928-4759-93de-f0a2fe0ddc44', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Sjuk- och aktivitetsersättning', '', '2026-08-29 00:51:26.650432+00'),
	('392d38f0-a3ea-417d-abc0-6c61954f4d9d', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Stöd till barnfamiljer', '', '2026-08-29 00:51:26.656156+00'),
	('333d0958-051f-4e2f-a8ee-258500408e0a', 'd136ab5a-1fba-410f-a96e-3fd26f446c31', 'Bostadstillägg', '', '2026-08-29 00:51:26.660924+00'),
	('d7703a1c-b399-414e-8bc0-26a5b38cb036', 'd136ab5a-1fba-410f-a96e-3fd26f446c31', 'Äldreförsörjningsstöd', '', '2026-08-29 00:51:26.665659+00'),
	('772d89c3-0b3d-4f08-bfa8-c657a673d5ac', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', 'Arbetsmarknadsprogram', '', '2026-08-29 00:51:26.670409+00'),
	('951b8b77-fe46-4808-a6f7-8d594af2f7fc', '0ef7acfa-9322-4818-9f67-b920daa08581', 'Omställningsstudiestöd', '', '2026-08-29 00:51:26.676914+00'),
	('53d0ccdb-cad1-4e73-8602-73331cd990c2', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'Bostadsanpassning', '', '2026-08-29 00:51:26.682162+00'),
	('af526fb4-b90f-459b-8c52-eb466ae6dd42', 'cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', 'Kulturbryggan', '', '2026-08-29 00:51:26.687329+00'),
	('0c112ae8-781d-4700-aadf-6b7be919a4d0', '86d2ddcc-9d26-4927-80f2-4671d7bfe833', 'Bidrag till kulturarvsarbete', '', '2026-08-29 00:51:26.692392+00'),
	('c9b95e42-c9d8-41d7-b248-1f199900a9c3', '3afd736e-6538-41a9-80a3-5e2469ee928b', 'Creative Force', '', '2026-08-29 00:51:26.69822+00'),
	('3a163d1d-166d-4956-b56e-e558c36cfa2d', '4bc38c33-8fa0-4b0c-b50d-fd15992bd0db', 'Projektstöd', '', '2026-08-29 00:51:26.703826+00'),
	('61d40a1f-f87c-4850-b3f2-9e55754effdd', '1a3a4fea-4170-4f67-afbe-69782a79c836', 'Projektbidrag', '', '2026-08-29 00:51:26.708674+00'),
	('025b791f-86c6-43c8-86eb-ffce6c8cd87f', '1287f5d9-dff5-44ae-a7d8-45c8831165af', 'Projektstöd', '', '2026-08-29 00:51:26.713226+00'),
	('ff36f488-b9a5-411b-81ad-373117aa577b', '1159e72d-a5e4-411b-971e-2e8643f36ff4', 'Musiksamarbeten', '', '2026-08-29 00:51:26.718365+00'),
	('bfdb7fbe-568c-41ce-9d1d-daf717991aad', '5324fe9f-2625-4ee3-9ade-e690b048dd35', 'Erasmus+ Partnerskap', '', '2026-08-29 00:51:26.72355+00');
INSERT INTO public.funding_programmes VALUES
	('4ad02efa-2cc5-4359-8055-7f8cc8ed6b46', '796064d4-174e-44d7-9429-13915b689a8d', 'Regionala företagsstöd', '', '2026-08-29 00:51:26.728526+00'),
	('cdfa5633-e3e1-468f-af89-d21007c98793', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'Litteratur och bibliotek', '', '2026-08-29 00:51:26.733382+00'),
	('921146b4-ca23-42de-84fb-62e7e7c47c94', '9b17149a-f39f-4b7e-b63f-c5ea60acc35a', 'Bygdemedel', '', '2026-08-29 00:51:26.743311+00'),
	('a6237a60-3245-4ca0-a5fd-282065d1ecc9', 'fea1ecec-978c-4a2c-b646-4b448ef3ba14', 'Frivillig återvandring', '', '2026-08-29 00:51:26.748408+00'),
	('38034e00-aada-48e0-897e-913b77aec036', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', 'EURES', '', '2026-08-29 00:51:26.75402+00'),
	('899f66a9-2509-4dc7-b832-bc5baa253321', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Omvårdnadsbidrag', '', '2026-08-29 00:51:26.76748+00'),
	('8f85893e-1fef-440a-86b7-45299c86b68c', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Merkostnadsersättning', '', '2026-08-29 00:51:26.772897+00'),
	('891ca714-c10f-476c-b1a9-d2479dbaa3b9', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Bilstöd', '', '2026-08-29 00:51:26.777831+00'),
	('fc4e1fc6-ad5a-441d-ae56-2b72d11785bc', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Närståendepenning', '', '2026-08-29 00:51:26.783139+00'),
	('ca75ad04-4fc0-407a-81e3-2d17622f5bcb', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', 'Etableringsprogrammet', '', '2026-08-29 00:51:26.787918+00'),
	('02c87711-3734-495a-aa66-06535101cdde', '0ef7acfa-9322-4818-9f67-b920daa08581', 'Hemutrustningslån', '', '2026-08-29 00:51:26.793063+00'),
	('bb61290b-b4ec-45e6-87a2-4b0cc40a9b70', '0ef7acfa-9322-4818-9f67-b920daa08581', 'Studiestartsstöd', '', '2026-08-29 00:51:26.798398+00'),
	('ea8a1c6c-e879-4b4f-9bcb-6bb8e2b10234', '0ef7acfa-9322-4818-9f67-b920daa08581', 'Inackorderingstillägg', '', '2026-08-29 00:51:26.803358+00'),
	('a61bc79e-df7c-4dd1-98bf-1f80093ca631', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'Föreningsbidrag', '', '2026-08-29 00:51:26.811117+00'),
	('a8ab4690-a06e-4e9e-ac0f-f1fc22dba01d', 'e908b93d-0526-467c-a510-235ec0c217ab', 'Regionalt kulturstöd', '', '2026-08-29 00:51:26.816035+00'),
	('8113dd9d-f4c7-4368-91cb-64c440c6a0fd', '85f53dd8-7fdb-46d0-8f2b-4c980dec62af', 'Projektstöd', '', '2026-08-29 00:51:26.820942+00'),
	('4f9a8326-0f3e-44e9-bb9a-46baf309cf18', '3b945b80-de20-4135-be2a-5408dc8c676b', 'Leader — lokalt ledd utveckling', '', '2026-08-29 00:51:26.825702+00'),
	('aa2b985b-f719-411b-a606-dfbc0d29c019', 'dc409620-c5bc-4ca7-9266-8311ac367d87', 'Projektbidrag', '', '2026-08-29 00:51:26.831304+00'),
	('68a93589-8b44-4474-96d9-5225df9c2c06', 'a8b1caea-e4d3-42e8-a450-c0259f491585', 'Projektbidrag', '', '2026-08-29 00:51:26.836553+00'),
	('8abef71e-3a77-46f3-b16b-332ab88713c3', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Vid sjukdom', '', '2026-08-29 00:51:26.858342+00'),
	('ea0b4d27-eaa3-4ad4-a9fa-890cf09c7d69', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Vid arbetslöshet', '', '2026-08-29 00:51:26.868234+00'),
	('e56a9bed-fa92-4d79-8cef-4edadc12437c', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Tandvårdsstöd', '', '2026-08-29 00:51:26.8741+00'),
	('ae727024-5fb2-4097-8790-d017f0cb4d90', 'd136ab5a-1fba-410f-a96e-3fd26f446c31', 'Grundskydd för pensionärer', '', '2026-08-29 00:51:26.879262+00'),
	('ef9d5574-0cb7-4568-a764-e335db326b73', 'e908b93d-0526-467c-a510-235ec0c217ab', 'Patientavgifter', '', '2026-08-29 00:51:26.884269+00'),
	('a6c45b36-9af5-4436-ad81-1b4483f785d8', 'aeb2eb40-63ff-4bdc-aa1f-7a31a946ef3c', 'Arbetslöshetsförsäkringen', '', '2026-08-29 00:51:26.889308+00'),
	('2078a0f7-5a8e-4257-857e-a532b7a00e90', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', 'Anställningsstöd', '', '2026-08-29 00:51:26.894045+00');


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
	('ffcd164e-0fd5-43c5-9b34-9790f7f0f29d', 'en', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Activity support for sports clubs running leader-led activities for children and young people aged 7–25.', '2026-08-29 00:51:27.012844+00'),
	('dd765ea4-5591-441d-8317-27472236521f', 'en', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'An automatic supplement to the child allowance (barnbidrag) from the second child onwards.', '2026-08-29 00:51:27.012844+00'),
	('894dee79-2826-49db-b011-1cdbfcd15d29', 'en', 'Avser ansökan en fysisk investering?', 'Does the application concern a physical investment?', '2026-08-29 00:51:27.012844+00'),
	('8eda880e-cdc8-4ea9-af1e-08a27b6abb2f', 'en', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Does the application concern an international trip or exchange?', '2026-08-29 00:51:27.012844+00'),
	('d9968646-b26a-4181-8a30-b55693790d13', 'en', 'Avser ansökan en investering i byggnader eller maskiner?', 'Does the application concern an investment in buildings or machinery?', '2026-08-29 00:51:27.012844+00'),
	('443bb1b6-c9b0-4a7a-b0b5-ed3c0ea68a69', 'en', 'Avser ansökan en redan utgiven titel?', 'Does the application concern an already published title?', '2026-08-29 00:51:27.012844+00'),
	('98e66b46-47cc-4db9-a83b-e642771517a5', 'en', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Does the application concern an agricultural, horticultural or reindeer husbandry business?', '2026-08-29 00:51:27.012844+00'),
	('d69be7dc-9391-4679-9b72-64d0d5f0e5f7', 'en', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Does the application concern purchasing literature for public or school libraries?', '2026-08-29 00:51:27.012844+00'),
	('ab3b4d8c-f984-4816-9762-41f57b51e763', 'en', 'Avser investeringen jordbruksverksamhet?', 'Does the investment concern agricultural activities?', '2026-08-29 00:51:27.012844+00'),
	('e22cf2a9-11c1-46fd-a5c7-c9fcb87e6b21', 'en', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Does the project involve building, buying or renovating premises?', '2026-08-29 00:51:27.012844+00'),
	('b0e7a9c1-137b-44b7-8551-5bcf6f11dd02', 'en', 'Avser projektet naturvård eller friluftsliv?', 'Does the project concern nature conservation or outdoor recreation?', '2026-08-29 00:51:27.012844+00'),
	('4606d036-1798-4d6c-8517-da1205b5fc77', 'en', 'Avser projektet skola eller vuxenutbildning?', 'Does the project concern school or adult education?', '2026-08-29 00:51:27.012844+00'),
	('0858637a-326c-426f-b28e-4038df6aa37d', 'en', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Are you refraining from work to care for or be close to a relative who is so seriously ill that the illness is a threat to their life?', '2026-08-29 00:51:27.012844+00'),
	('f83bad82-d227-40ca-bdc1-ae33e7b7a823', 'en', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Does the association run regular activities in the municipality?', '2026-08-29 00:51:27.012844+00'),
	('d34de340-6c26-4b78-ab68-3f7dd7e442d9', 'en', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Do you consider your ability to work to be reduced for at least a year due to illness or disability?', '2026-08-29 00:51:27.012844+00'),
	('f0ecd5a5-98db-4f13-b5e2-e145e835b6c9', 'en', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Means-tested support for you who have a low pension or none and need help reaching a reasonable standard of living.', '2026-08-29 00:51:27.012844+00'),
	('c360fa04-f4cf-4951-b41a-c661eb27285d', 'en', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Does the child need to live in the town of study (lodging) because the journey is too long?', '2026-08-29 00:51:27.012844+00'),
	('d048ee4e-250b-45f3-a290-46036039826a', 'en', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Does the home need to be adapted (e.g. a ramp, door opener, bathroom)?', '2026-08-29 00:51:27.012844+00'),
	('e9355eb5-a516-47b2-8335-feb9ba408007', 'en', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Does any of your children aged 8–19 need glasses or contact lenses?', '2026-08-29 00:51:27.012844+00'),
	('bccdb6c3-b6b7-4a60-ba3e-3695950f29f3', 'en', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Does the other parent pay nothing, or less than full maintenance?', '2026-08-29 00:51:27.012844+00'),
	('fd3904db-0971-4995-b0d6-c0206b257414', 'en', 'Betalar du hyra eller andra boendekostnader?', 'Do you pay rent or other housing costs?', '2026-08-29 00:51:27.012844+00'),
	('d50f6235-824b-484f-aecc-a0fe45552a9b', 'en', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'A grant for adapting your home in case of disability — e.g. ramps, door openers or bathroom adaptations.', '2026-08-29 00:51:27.012844+00'),
	('62815d75-6eb9-4a53-a551-6fc8278a4131', 'en', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Grants for building, buying or renovating public assembly halls.', '2026-08-29 00:51:27.012844+00'),
	('083bd855-6f63-4db9-9aab-bc84350f88eb', 'en', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'A grant for buying or adapting a car when a lasting disability makes it very difficult to get around or travel by public transport.', '2026-08-29 00:51:27.012844+00'),
	('d46c670b-95b0-4c85-825b-36f9cdc6ed4f', 'en', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Grants for international travel and exchanges for professionals in the cultural sector.', '2026-08-29 00:51:27.012844+00'),
	('5316d47e-bef8-425d-a190-59fe1adf4b30', 'en', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Grants for professional artists'' international exchanges, travel and working stays.', '2026-08-29 00:51:27.012844+00'),
	('acf7dd15-138a-49c4-9889-5dd87623d2d0', 'en', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'A grant and optional loan for studies at upper secondary or post-secondary level.', '2026-08-29 00:51:27.012844+00'),
	('b2f421ce-65cf-4650-9af6-1b1445047592', 'en', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Grants and loans for studies abroad, with extra supplementary loans for e.g. tuition fees and travel.', '2026-08-29 00:51:27.012844+00'),
	('601a722c-0248-46ab-9270-abd448901e5c', 'en', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'A grant that helps Swedish actors prepare applications for EU programmes such as Horisont Europa.', '2026-08-29 00:51:27.012844+00'),
	('5ba118db-d35a-41cb-b0bd-30f9f193e550', 'en', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'A grant for employers who hire people with reduced work capacity.', '2026-08-29 00:51:27.012844+00'),
	('9ea6ad4c-d53f-48b8-9c45-f35e03023511', 'en', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'A grant towards lodging and journeys home when an upper secondary pupil has to live in the town of study because of a long journey.', '2026-08-29 00:51:27.012844+00'),
	('47e3b7e5-2f82-42b4-b5b1-f046f1c077e1', 'en', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Grants for non-profit organisations'' work to preserve, use and develop cultural heritage.', '2026-08-29 00:51:27.012844+00'),
	('2153db0c-ba1f-40f8-b7c2-c203511fb42d', 'en', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Grants for municipal and local nature conservation projects, including wetlands and outdoor recreation.', '2026-08-29 00:51:27.012844+00'),
	('24251587-e1d9-403b-b767-df95bf3bbb76', 'en', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Grants to municipalities for purchasing literature for public and school libraries.', '2026-08-29 00:51:27.012844+00'),
	('6952ca2d-aa22-4644-9e73-60e2ae9f6084', 'en', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Grants to school authorities for pupils'' encounters with professional culture in compulsory school.', '2026-08-29 00:51:27.012844+00'),
	('1e3b987a-9d63-4924-a016-fb17d4e4c0e5', 'en', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'EU social fund money for projects that strengthen skills, transition and inclusion in the labour market.', '2026-08-29 00:51:27.012844+00'),
	('f90a757b-b197-471d-b92f-cf442eff9ed4', 'en', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Grants for things your child needs but the family finances cannot cover: leisure activities, clothes, school outings, glasses, holiday activities and more.', '2026-08-29 00:51:27.012844+00'),
	('1723dc42-57d4-4144-89d6-6a393d45c27e', 'en', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Grants from funds such as Världens Barn, Musikhjälpen and Victoriafonden — applied for by Swedish non-profit organisations with a 90-konto.', '2026-08-29 00:51:27.012844+00'),
	('a20f7899-38cd-4b25-a28e-da235ee07ad4', 'en', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Grants from hydropower and wind power funds for projects that develop the local community.', '2026-08-29 00:51:27.012844+00'),
	('9043600b-2450-407b-9c50-04f347ca8bcf', 'en', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'A grant with no loan component for unemployed people aged 25–60 with short previous education who need to study at compulsory or upper secondary level.', '2026-08-29 00:51:27.012844+00'),
	('a1724fef-d5e1-4d88-a6ab-651e7091f8f1', 'en', 'Bidrar projektet till energiomställningen?', 'Does the project contribute to the energy transition?', '2026-08-29 00:51:27.012844+00'),
	('df7ade55-6e85-43b5-be36-52874e686b1b', 'en', 'Bor du och barnets andra förälder på skilda håll?', 'Do you and the child''s other parent live apart?', '2026-08-29 00:51:27.012844+00'),
	('1a582ca7-688a-4580-abcb-719b5c634502', 'en', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Vouchers for small companies to bring in external expertise for internationalisation or digitalisation.', '2026-08-29 00:51:27.012844+00'),
	('823cfeb8-ff34-4ae4-ba4a-f2ce18aeb7e1', 'en', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Are you taking part in a programme at Arbetsförmedlingen (e.g. jobb- och utvecklingsgarantin)?', '2026-08-29 00:51:27.012844+00'),
	('b66b1db7-244d-44b6-b9c6-61c6af7878e1', 'en', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Retrospective support to publishers for publishing quality literature.', '2026-08-29 00:51:27.012844+00'),
	('9c0d3fa2-c0a8-4812-ad45-a6c9ceef3ccc', 'en', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Financial support for those with a protection-related residence permit who voluntarily want to move back to their country of origin permanently.', '2026-08-29 00:51:27.012844+00'),
	('84e0a88b-016f-4bf5-baed-8af5e38085b8', 'en', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Financial support for employers who hire someone who has been away from working life for a long time.', '2026-08-29 00:51:27.012844+00'),
	('27b959fe-22d8-40e4-a761-9dcb649799f1', 'en', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Financial support during the start-up phase for jobseekers starting their own business.', '2026-08-29 00:51:27.012844+00'),
	('5723d9ba-fc5d-4ed9-a3e8-3d5a5525448a', 'en', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten continuously opens calls within energy research, innovation and energy efficiency.', '2026-08-29 00:51:27.012844+00'),
	('0de8b7f3-eb62-4a96-a056-f8a345306ba3', 'en', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Compensation for taking time off work or studies to care for a child.', '2026-08-29 00:51:27.012844+00');
INSERT INTO public.kb_translations VALUES
	('f92495cc-fa26-4ef2-801d-d96e76042d48', 'en', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Compensation for those who are new in Sweden and take part in the establishment programme at Arbetsförmedlingen; paid out by Försäkringskassan.', '2026-08-29 00:51:27.012844+00'),
	('78a46f86-bf35-45bc-96b1-cb63d73cf561', 'en', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Compensation for part of the housing cost for young people without children on low incomes.', '2026-08-29 00:51:27.012844+00'),
	('6ad0a683-c14f-4b07-b467-f2fdfcd4f36b', 'en', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Compensation for the extra costs that a lasting disability brings — for adults, or for parents of children with disabilities.', '2026-08-29 00:51:27.012844+00'),
	('7319b00c-8256-4100-91a7-de8b03b8f07f', 'en', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Compensation for young people (19–29) who cannot work full-time for at least a year due to illness or disability.', '2026-08-29 00:51:27.012844+00'),
	('3c36ad0c-cc42-4210-b07e-8948c438075d', 'en', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Compensation when your ability to work is permanently reduced — previously known as förtidspension (early retirement pension).', '2026-08-29 00:51:27.012844+00'),
	('7a8e5b87-b539-4182-a4d9-1d2fe5ef9adf', 'en', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Compensation when you refrain from work to be close to a seriously ill relative.', '2026-08-29 00:51:27.012844+00'),
	('a81b352b-3b2c-4caa-bfbb-27261bf487df', 'en', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Compensation when you take part in a labour market programme at Arbetsförmedlingen.', '2026-08-29 00:51:27.012844+00'),
	('bc7ede10-4af8-4ea7-8bba-d37b81ba1c84', 'en', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Compensation when you cannot work as usual due to illness.', '2026-08-29 00:51:27.012844+00'),
	('c2d0d584-c880-4816-b3c4-81e944f1349c', 'en', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Compensation when you stay home from work to care for a sick child.', '2026-08-29 00:51:27.012844+00'),
	('6babe9f6-cd26-4ba8-af42-5ee9fb53513e', 'en', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Compensation covering part of the housing cost for households with children and lower incomes.', '2026-08-29 00:51:27.012844+00'),
	('e8a30da1-46ce-4fa2-b9e9-8e329980a9ba', 'en', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Compensation for parents whose children, due to disability, need more care and supervision than children of the same age.', '2026-08-29 00:51:27.012844+00'),
	('916da074-81ff-4fad-8dc9-2bd6da7475b0', 'en', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Compensation during unemployment — income-based for members, a basic amount for others.', '2026-08-29 00:51:27.012844+00'),
	('14f4e0d7-074a-436d-bfa4-8acc71a6b607', 'en', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Some fifty savings bank foundations award grants to local projects in sports, culture, education and community development — within the savings bank''s area of operation.', '2026-08-29 00:51:27.012844+00'),
	('431ba325-c5e0-4f05-9575-6f3f1b75be6c', 'en', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'EU-funded project support applied for through your local Leader area — for associations, companies and municipalities developing rural areas.', '2026-08-29 00:51:27.012844+00'),
	('6ffb0cbb-a066-4f8e-9c0a-61ef926a62e4', 'en', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU-funded support for jobseekers taking a job in another EU/EEA country: compensation for interview travel, moving costs and language courses.', '2026-08-29 00:51:27.012844+00'),
	('40d999e2-1210-4aef-9423-d707c6dc0a0f', 'en', 'Är volontärerna mellan 18 och 30 år?', 'Are the volunteers between 18 and 30 years old?', '2026-08-29 00:51:27.016331+00'),
	('3bea3a87-b3c1-4f01-8ba3-dde5933cbb9d', 'en', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'EU support for group exchanges for young people aged 13–30, lasting 5–21 days excluding travel days.', '2026-08-29 00:51:27.012844+00'),
	('a08c8361-1965-4f69-9626-90e339c84efb', 'en', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'EU support for cultural organisations'' cooperation projects with partners in several European countries.', '2026-08-29 00:51:27.012844+00'),
	('91658e5d-6991-4b8b-b369-2738ce4056da', 'en', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'EU support for organisations receiving or sending young volunteers aged 18–30.', '2026-08-29 00:51:27.012844+00'),
	('1dcfe215-6f96-4646-b437-773a9a9283e1', 'en', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'EU support for staff and pupil mobility in schools and adult education.', '2026-08-29 00:51:27.012844+00'),
	('30f8883b-09ee-4fec-a679-1c07466b7c31', 'en', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'EU support with lump sums for smaller organisations'' first European cooperation projects.', '2026-08-29 00:51:27.012844+00'),
	('5530f646-c45f-449e-a2d7-1f13b6cfb063', 'en', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Funding for young companies developing innovative products or services with international potential.', '2026-08-29 00:51:27.012844+00'),
	('f40e91c5-d5e3-469b-a9f7-00fcce7a89e3', 'en', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Is there a savings bank (and thus a savings bank foundation) where you operate?', '2026-08-29 00:51:27.012844+00'),
	('47a6ef71-8734-4076-8826-f49f8345698c', 'en', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Multi-year operating grants for professional independent groups in dance, theatre and musical theatre.', '2026-08-29 00:51:27.012844+00'),
	('ebaea72f-7507-4a39-b2aa-c93bfa5c6f8d', 'en', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Research grants within Forte''s areas of responsibility: health, working life and welfare. Applied for by researchers with a doctorate at Swedish higher education institutions.', '2026-08-29 00:51:27.012844+00'),
	('2539d114-f88c-4140-836c-561f08c442df', 'en', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Research funding for free basic research in all scientific fields.', '2026-08-29 00:51:27.012844+00'),
	('6328c9c0-a8a0-4cbd-a405-f87fc68c5da7', 'en', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Research funding within the environment, agricultural sciences and spatial planning.', '2026-08-29 00:51:27.012844+00'),
	('ae4e47df-1a66-48f9-a9ba-83fbc05390ca', 'en', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Are you thinking about moving abroad (for work, studies or return migration)?', '2026-08-29 00:51:27.012844+00'),
	('0e82f111-b3f3-49bd-b60c-bfbfbeec25a3', 'en', 'Genomförs insatserna av professionella kulturaktörer?', 'Are the activities carried out by professional cultural actors?', '2026-08-29 00:51:27.012844+00'),
	('86fddbe0-376f-427f-b72a-5b52a9872d49', 'en', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Is the project carried out in a rural area or a smaller town?', '2026-08-29 00:51:27.012844+00'),
	('2f93f07a-75b2-43cb-81d0-ad156d4e2b97', 'en', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Basic protection for those who have had little or no earned income during their life.', '2026-08-29 00:51:27.012844+00'),
	('569fd267-84c8-469d-926d-663eaebfd8c2', 'en', 'Går något av dina barn i grundskolan?', 'Is any of your children in compulsory school?', '2026-08-29 00:51:27.012844+00'),
	('c511b1fd-41ae-42bf-af8b-fa35be011d18', 'en', 'Går något av dina barn på gymnasiet?', 'Is any of your children in upper secondary school?', '2026-08-29 00:51:27.012844+00'),
	('cffcf72c-0c1e-4251-ae01-803d6880eec4', 'en', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Does the employment concern a person with reduced work capacity?', '2026-08-29 00:51:27.012844+00'),
	('bab5ac41-3197-481b-8509-14933745dfa9', 'en', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Does the employment concern someone who has been unemployed for a long time or is new in Sweden?', '2026-08-29 00:51:27.012844+00'),
	('368792f3-a056-4407-a7c6-65ac0c785136', 'en', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Is the project about preserving or making cultural heritage accessible?', '2026-08-29 00:51:27.012844+00'),
	('84ec40ae-7255-4423-a22d-14421341fe8c', 'en', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Is the project about energy, energy efficiency or energy-related innovation?', '2026-08-29 00:51:27.012844+00'),
	('fee4d830-7bc4-4c6a-a39d-00b38a6b0af6', 'en', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Is the project about health, working life or welfare?', '2026-08-29 00:51:27.012844+00'),
	('bfa9ccd9-f4c4-4d53-8de0-4fd521245754', 'en', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Is the project about skills development or labour market measures?', '2026-08-29 00:51:27.012844+00'),
	('f1c2d1d9-4752-41cc-a6b4-4bdda39cad62', 'en', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Is the project about environmental or climate measures?', '2026-08-29 00:51:27.012844+00'),
	('56e29bba-042c-4e23-8bfa-a2a8fe7a63a0', 'en', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Does the child have a long, traffic-hazardous or otherwise difficult route to school?', '2026-08-29 00:51:27.012844+00'),
	('e2fbe379-e4e8-4ed2-ad44-2d716456d02f', 'en', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Have you worked at least 16 hours a week for a total of at least 8 years?', '2026-08-29 00:51:27.012844+00'),
	('d54db7dd-dfce-4e8a-81e1-563c65378dec', 'en', 'Har du barn som bor hos dig, helt eller växelvis?', 'Do you have children living with you, full-time or alternately?', '2026-08-29 00:51:27.012844+00'),
	('cbcc67f5-4f45-4288-a27b-f9ce49024399', 'en', 'Har du barn som bor hos dig?', 'Do you have children living with you?', '2026-08-29 00:51:27.012844+00'),
	('e787b6aa-1690-434e-9b75-ff732b49d145', 'en', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Do you or your child have a disability expected to last at least a year?', '2026-08-29 00:51:27.012844+00'),
	('7b160b9b-00fd-4ec2-a28f-77bb8e50985b', 'en', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Do you or anyone in the household have a lasting disability that affects your housing?', '2026-08-29 00:51:27.012844+00'),
	('600dd0f5-fbbb-4416-90c7-d2220a28df0c', 'en', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Do you or a close relative have a disability or a long-term or serious illness?', '2026-08-29 00:51:27.012844+00'),
	('45262340-a1f6-4ae3-8cc6-01b164c26434', 'en', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Do you have an illness or injury that currently reduces your ability to work?', '2026-08-29 00:51:27.012844+00'),
	('78bb8108-20e1-4313-bc84-9576d5c8efe8', 'en', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Have you ever found it hard to pay for a school outing, class trip or leisure activity your child is expected to take part in?', '2026-08-29 00:51:27.012844+00'),
	('36775ef1-0324-4d7f-8eec-1e22275ad919', 'en', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Do you find it hard to manage on your pension and your other income?', '2026-08-29 00:51:27.012844+00');
INSERT INTO public.kb_translations VALUES
	('486d46d1-3e02-4ad1-be54-4af04a949929', 'en', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Have you been granted a residence permit in Sweden in recent years, e.g. as a person in need of protection or as a family member?', '2026-08-29 00:51:27.012844+00'),
	('cce3836e-f08c-4a0d-9483-fc8e6d2e267a', 'en', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Do you have a residence permit in Sweden as a refugee or person in need of protection (or are you a close family member of someone who has)?', '2026-08-29 00:51:27.012844+00'),
	('8af063d6-b102-4f29-be0a-0f9cb7017453', 'en', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Have you reached the target age for pension (67 in 2026)?', '2026-08-29 00:51:27.012844+00'),
	('b7a6ad5d-ae52-461d-b978-c39be0a091c8', 'en', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Does your organisation have an OID (Organisation ID) registered in the EU''s Organisation Registration System?', '2026-08-29 00:51:27.012844+00'),
	('4013215b-925d-43c8-ae5b-3a843f6bad61', 'en', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Has the disability led to extra costs — e.g. aids, travel, special diet or wear and tear?', '2026-08-29 00:51:27.012844+00'),
	('5ede7e88-58dd-4737-83df-db0b724d0b8a', 'en', 'Har föreningen antagna stadgar och en vald styrelse?', 'Does the association have adopted statutes and an elected board?', '2026-08-29 00:51:27.012844+00'),
	('5f45d4aa-62c3-4a57-a096-aca0296beed6', 'en', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Does the association have a democratic structure (statutes, annual meeting, board)?', '2026-08-29 00:51:27.012844+00'),
	('c084b3c1-c348-482b-845a-689cc01628ca', 'en', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Does the association run regular activities for children or young people?', '2026-08-29 00:51:27.012844+00'),
	('805f0aca-69e1-4c4d-8a1a-61752d271905', 'en', 'Har företaget mellan cirka 2 och 49 anställda?', 'Does the company have between roughly 2 and 49 employees?', '2026-08-29 00:51:27.012844+00'),
	('c95e066f-3c3b-43bd-99f3-93e816863d59', 'en', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Does the household struggle to cover the costs of food, housing and the bare necessities?', '2026-08-29 00:51:27.012844+00'),
	('e66d0e38-d5d0-4b15-ac93-436b32502b29', 'en', 'Har lösningen internationell potential?', 'Does the solution have international potential?', '2026-08-29 00:51:27.012844+00'),
	('a5031e03-d5b1-4755-8147-ff8d8388215f', 'en', 'Har ni en partnergrupp i ett annat land?', 'Do you have a partner group in another country?', '2026-08-29 00:51:27.012844+00'),
	('fcbea743-f038-492c-8afc-d4e43cb182a3', 'en', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Do you have a partner organisation in another European country?', '2026-08-29 00:51:27.012844+00'),
	('bb319927-8042-4612-af6a-9070a211c114', 'en', 'Har ni partner i minst tre olika europeiska länder?', 'Do you have partners in at least three different European countries?', '2026-08-29 00:51:27.012844+00'),
	('6e630663-0032-4725-a360-f42b0d2a9501', 'en', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Is your registered office or main activity in the region where you are applying?', '2026-08-29 00:51:27.012844+00'),
	('70d469d0-7fed-4d40-b92e-37aef196dc08', 'en', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Does any of your children have a disability that means the child needs more care or supervision than other children of the same age?', '2026-08-29 00:51:27.012844+00'),
	('0c17b0e8-81cc-464e-afd2-5a2a7b822f5d', 'en', 'Har organisationen en demokratisk uppbyggnad?', 'Does the organisation have a democratic structure?', '2026-08-29 00:51:27.012844+00'),
	('bbc3c9c6-d396-41db-87cb-24d91555a047', 'en', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Does the organisation have a Quality Label?', '2026-08-29 00:51:27.012844+00'),
	('2c4ba7d5-a092-4fee-b9bf-10484f827479', 'en', 'Har organisationen ett 90-konto?', 'Does the organisation have a 90-konto?', '2026-08-29 00:51:27.012844+00'),
	('cc3d1e52-73e5-415f-a574-4a8934d445cc', 'en', 'Har organisationen ett OID (Organisation ID)?', 'Does the organisation have an OID (Organisation ID)?', '2026-08-29 00:51:27.012844+00'),
	('7da85f8d-e01a-4286-adac-37d8496730e5', 'en', 'Har organisationen ett OID?', 'Does the organisation have an OID?', '2026-08-29 00:51:27.012844+00'),
	('0433dc20-71cf-4036-b783-0a0d460c7ad0', 'en', 'Har organisationen medlemsföreningar i flera län?', 'Does the organisation have member associations in several counties?', '2026-08-29 00:51:27.012844+00'),
	('22c366c1-e1ae-4ef2-bd03-885f4be4fa1a', 'en', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Does the organisation have sound finances and a democratic structure?', '2026-08-29 00:51:27.012844+00'),
	('9266d312-b755-43ba-b1ee-d58be2595ba2', 'en', 'Har projektet en partner i ett annat land?', 'Does the project have a partner in another country?', '2026-08-29 00:51:27.012844+00'),
	('316ce343-2acb-4bf6-a76e-e979607720ea', 'en', 'Har projektledaren doktorsexamen?', 'Does the project leader have a doctoral degree?', '2026-08-29 00:51:27.012844+00'),
	('b05e27ec-2465-4a72-ad45-232080adfcb1', 'en', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Your home municipality must provide daily travel between home and upper secondary school when the route is at least six kilometres (e.g. a bus pass).', '2026-08-29 00:51:27.012844+00'),
	('ed77541f-8b4b-4de1-948d-ae833c7cfe77', 'en', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Are you in the process of getting or equipping your first own home in Sweden?', '2026-08-29 00:51:27.012844+00'),
	('1b8105ca-a7cb-4136-8832-150f6df5d6fd', 'en', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Does the project include an international trip or exchange?', '2026-08-29 00:51:27.012844+00'),
	('b86865ad-7c45-46bd-969d-b0c0aea5b013', 'en', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Investment support for companies in designated support areas, for buildings, machinery and training.', '2026-08-29 00:51:27.012844+00'),
	('18f6a8eb-c4a5-4a26-8bdb-698985b3193a', 'en', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Investment support for measures that reduce greenhouse gas emissions.', '2026-08-29 00:51:27.012844+00'),
	('e5345d8d-23e3-45ea-9f2a-5cfd3812319e', 'en', 'Kan projektets miljönytta mätas?', 'Can the project''s environmental benefit be measured?', '2026-08-29 00:51:27.012844+00'),
	('abfa7f71-4203-4bae-97b8-c6e8d7f0b206', 'en', 'Kan åtgärdens utsläppsminskning beräknas?', 'Can the measure''s emission reduction be calculated?', '2026-08-29 00:51:27.012844+00'),
	('3bd318d6-8948-4e9b-8ac9-322ffe990ef2', 'en', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Can the organisation carry the costs until the support is paid out?', '2026-08-29 00:51:27.012844+00'),
	('117e4df9-ebfb-4d20-9b35-f30b851a250b', 'en', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Will the experience be used in your activities in Sweden?', '2026-08-29 00:51:27.012844+00'),
	('19dab18c-3f85-4fd8-be9b-672fd11dbbfd', 'en', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Will the investment start only after you have submitted the application?', '2026-08-29 00:51:27.012844+00'),
	('ba1f090c-cfa4-4519-a036-724e34a30834', 'en', 'Kommer projektet människor i ert närområde till del?', 'Does the project benefit people in your local area?', '2026-08-29 00:51:27.012844+00'),
	('6ac9872b-deb9-47ea-acb3-05a3f336b8af', 'en', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'The municipality''s last financial safety net when income does not cover the bare necessities.', '2026-08-29 00:51:27.012844+00'),
	('e2cf2915-331e-4ddf-9d24-7d996c578f4c', 'en', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'The municipalities'' own support for the local association scene: activity support per session, premises grants, start-up grants and more.', '2026-08-29 00:51:27.012844+00'),
	('7c161430-651f-486b-9520-75f7be903eac', 'en', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Free school transport for compulsory school pupils in case of long distance, traffic-hazardous routes or disability — a right under the Education Act.', '2026-08-29 00:51:27.012844+00'),
	('da54de74-4dec-484a-9e45-c2a7a497d9e1', 'en', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'A statutory grant towards glasses or contact lenses for children and young people; amounts and routines vary by region — check your region''s level.', '2026-08-29 00:51:27.012844+00'),
	('6adb8e47-b062-486c-934c-ef1873dac581', 'en', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Is the project located in an area affected by hydropower or wind power?', '2026-08-29 00:51:27.012844+00'),
	('233510e9-98e6-4c79-8980-c20a84518b0d', 'en', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Is the project within the environment, agricultural sciences or spatial planning?', '2026-08-29 00:51:27.012844+00'),
	('993d4e32-e31e-4a34-bb01-8891bde51a51', 'en', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Is your place of business in support area A or B (large parts of Norrland and inner Svealand)?', '2026-08-29 00:51:27.012844+00'),
	('808557b0-f007-4bbd-af64-3bdb0d4572e6', 'en', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'A loan for buying the essentials for a first home in Sweden — furniture, household goods and other basic equipment.', '2026-08-29 00:51:27.012844+00'),
	('25b78a45-6769-4c62-a7ae-d1ff9d7a0fc8', 'en', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Does the project reduce industrial process emissions or create negative emissions?', '2026-08-29 00:51:27.012844+00'),
	('38dd1483-3091-4483-a14d-586ba7a8b146', 'en', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'A monthly allowance for children living in Sweden, from birth until age 16.', '2026-08-29 00:51:27.012844+00'),
	('2440ed36-7a2e-490f-8de8-4541dae883a8', 'en', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket offers grants to organisations, companies, associations, the public sector and private individuals in the environmental field.', '2026-08-29 00:51:27.012844+00'),
	('10524aed-a903-421b-b39a-7efcfd6bc95f', 'en', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Are you planning to voluntarily move back to your country of origin permanently?', '2026-08-29 00:51:27.012844+00'),
	('b88d4b19-8bde-4977-a476-ff8383dd0c8d', 'en', 'Planerar du att starta eget företag?', 'Are you planning to start your own business?', '2026-08-29 00:51:27.012844+00'),
	('78478da6-1305-4b21-be28-76f1073ea3c6', 'en', 'Planerar du att studera utomlands?', 'Are you planning to study abroad?', '2026-08-29 00:51:27.012844+00');
INSERT INTO public.kb_translations VALUES
	('0dd62343-cd20-460a-964d-bac93dcbc07c', 'en', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Are you planning studies that strengthen your position in the labour market?', '2026-08-29 00:51:27.012844+00'),
	('c8d6f61d-bd22-468b-b9e7-9629e96c77e5', 'en', 'Planerar ni att anställa?', 'Are you planning to hire?', '2026-08-29 00:51:27.012844+00'),
	('886239ab-b324-4d4e-a68e-2f13e4938491', 'en', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Are you planning to apply to an EU programme (e.g. Horisont Europa)?', '2026-08-29 00:51:27.012844+00'),
	('c1ec6816-62d2-4ffe-8bc1-b15763720eef', 'en', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Production and development support for short films and documentaries.', '2026-08-29 00:51:27.012844+00'),
	('04be84bb-97f4-4bc1-b7ab-c7f6597d4adc', 'en', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Project grants for the independent music scene for concerts, production and development.', '2026-08-29 00:51:27.012844+00'),
	('8500d64c-f40c-4106-8b00-e9e3421b19cf', 'en', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Project grants for non-profit organisations working with and for children and young people.', '2026-08-29 00:51:27.012844+00'),
	('334c2200-1bd3-49f9-9a00-dbe0ab5fdbbe', 'en', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Does the project explore new artistic expressions, methods or collaborations?', '2026-08-29 00:51:27.012844+00'),
	('0589397d-bc93-4c09-918f-ea981c2dbb50', 'en', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Does the exchange last 5–21 days (excluding travel days)?', '2026-08-29 00:51:27.012844+00'),
	('f9cbd80a-66c8-4cad-a470-2df2e8195c4d', 'en', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'The regions'' own project and operating support for cultural life, alongside Kulturrådet''s national grants.', '2026-08-29 00:51:27.012844+00'),
	('1c09ac72-9389-4432-b333-601d147a935f', 'en', 'Riktar sig projektet till barn eller unga?', 'Is the project aimed at children or young people?', '2026-08-29 00:51:27.012844+00'),
	('d3eda06c-cde7-434f-9fe1-e5fbce1d6a66', 'en', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Is the project aimed at children, young people, the elderly or people with disabilities?', '2026-08-29 00:51:27.012844+00'),
	('f3198e61-084f-4f08-9c60-1ebbcf17234a', 'en', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Are the activities aimed at children and young people (7–25)?', '2026-08-29 00:51:27.012844+00'),
	('8202ae05-b5ff-4766-81eb-dde8808f738b', 'en', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Do you lack savings or assets that could cover the expenses?', '2026-08-29 00:51:27.012844+00'),
	('39f7a5b1-1350-47bd-be57-4c6d39c95f56', 'en', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Are you cooperating with partners in at least two other Nordic countries?', '2026-08-29 00:51:27.012844+00'),
	('10e0b431-72ee-46ad-802b-b41acea3388e', 'en', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Will you bring in external expertise for a development initiative?', '2026-08-29 00:51:27.012844+00'),
	('6034c6f8-6839-4c7c-8d22-a2add7927626', 'en', 'Sker mobiliteten till ett annat europeiskt land?', 'Is the mobility to another European country?', '2026-08-29 00:51:27.012844+00'),
	('285d07aa-b2b1-4f02-8e16-6cd8c9567717', 'en', 'Startar du eller tar du över företaget för första gången?', 'Are you starting or taking over the business for the first time?', '2026-08-29 00:51:27.012844+00'),
	('8a9669d0-d5db-4cdd-81b7-da959ec54d4c', 'en', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Start-up support for those aged 40 or younger who start or take over an agricultural business.', '2026-08-29 00:51:27.012844+00'),
	('74abd8ae-6630-4d6d-a3d4-415503f6d78e', 'en', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'A scholarship that lets professional artists concentrate on their artistic work.', '2026-08-29 00:51:27.012844+00'),
	('94cb59bc-6b6c-426e-bd02-56d186c757fc', 'en', 'Studerar du, eller planerar du att börja studera?', 'Are you studying, or planning to start studying?', '2026-08-29 00:51:27.012844+00'),
	('aec8e0c9-c348-4c70-8b73-be4bc20e65a7', 'en', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Study support for working adults who want to educate themselves to strengthen their position in the labour market.', '2026-08-29 00:51:27.012844+00'),
	('de783bf2-ef0d-4fb4-80d1-5721d34c2187', 'en', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Support for investments that increase competitiveness or reduce environmental impact in agricultural businesses.', '2026-08-29 00:51:27.012844+00'),
	('46ad29d7-0f9d-47f1-9c98-1f0a83373a4b', 'en', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Support when a child lives with you and the other parent does not pay maintenance.', '2026-08-29 00:51:27.012844+00'),
	('7850c166-69de-49b4-97e7-a5d64b11bc95', 'en', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Support for non-profit organisations'' projects for people, the environment and a better world.', '2026-08-29 00:51:27.012844+00'),
	('27f31ddf-6c4a-41e8-8f29-5c388ac4b746', 'en', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Support for industry''s transition towards zero greenhouse gas emissions.', '2026-08-29 00:51:27.012844+00'),
	('89792a81-ebe3-43d5-824f-97b99ba4ec60', 'en', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Support for arts and culture projects with a Nordic dimension and cross-border cooperation.', '2026-08-29 00:51:27.012844+00'),
	('020c384d-955e-48ee-9492-34c8ac11bc3b', 'en', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Support for innovative cultural projects exploring new artistic expressions, methods or collaborations.', '2026-08-29 00:51:27.012844+00'),
	('507bd08b-9f9a-44a9-8933-cfda8dff9ee1', 'en', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Support for innovative projects for children, young people, the elderly and people with disabilities.', '2026-08-29 00:51:27.012844+00'),
	('b777836a-29bf-4c34-a088-636304d8e14a', 'en', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Support for cooperation projects in the independent music scene.', '2026-08-29 00:51:27.012844+00'),
	('750c765f-df03-4355-a390-df8c459cc184', 'es', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', '¿Le cuesta arreglárselas con su pensión y sus demás ingresos?', '2026-08-29 00:51:27.021303+00'),
	('2cc38a14-e2cb-4925-acd5-a837abf8aa62', 'en', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Support for cooperation projects in culture and media that strengthen democracy and freedom of expression internationally.', '2026-08-29 00:51:27.012844+00'),
	('b6b5daf2-5722-4666-a7d4-3f1997755375', 'en', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Does the project aim to strengthen democracy, equality or freedom of expression?', '2026-08-29 00:51:27.012844+00'),
	('2737802d-bd70-417d-ac47-67f0c09cf39c', 'en', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Are you looking for a job, or have you received a job offer, in another EU or EEA country?', '2026-08-29 00:51:27.012844+00'),
	('ebef0da9-fd86-4926-8266-36518879166e', 'en', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'A cap on what you need to pay in patient fees over a twelve-month period — after that, a frikort (free pass).', '2026-08-29 00:51:27.012844+00'),
	('a0717e67-3476-4b44-8c9c-fbdc4010fa1f', 'en', 'Tar du ut hel allmän pension?', 'Are you drawing your full public pension?', '2026-08-29 00:51:27.012844+00'),
	('74b5db97-461d-4efb-adb3-ce5923ca7687', 'en', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'A supplement covering part of the housing cost for those with a pension and low income.', '2026-08-29 00:51:27.012844+00'),
	('268f8057-8829-492e-b5f3-f9e8262406da', 'en', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'An annual organisation grant for national child and youth organisations.', '2026-08-29 00:51:27.012844+00'),
	('2c4de17d-fe41-4bb5-8515-74368d546d0e', 'en', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'An annual allowance deducted directly at the dentist or dental hygienist.', '2026-08-29 00:51:27.012844+00'),
	('93054461-91f5-4601-9af5-144b7087b983', 'en', 'Är bolaget yngre än cirka 5 år?', 'Is the company younger than about 5 years?', '2026-08-29 00:51:27.012844+00'),
	('58f64f61-8e96-4ff3-aae1-2ea95f2ca591', 'en', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Are the exchange participants between 13 and 30 years old?', '2026-08-29 00:51:27.012844+00'),
	('24de5151-a4f5-447f-b8ee-e4409650854b', 'en', 'Är det här ert första EU-projekt?', 'Is this your first EU project?', '2026-08-29 00:51:27.012844+00'),
	('5c369764-73f8-43ec-82c4-18fc07a34aef', 'en', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Is it very difficult for you (or your child) to get around on your own or to travel by bus and train?', '2026-08-29 00:51:27.012844+00'),
	('a2d8a787-f15b-4ba6-bed7-1deafbfb8766', 'en', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Is your income lower than about SEK 25,000 a month before tax?', '2026-08-29 00:51:27.012844+00'),
	('b05087db-e83a-4349-b787-4e30b68b543d', 'en', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Is your most recently completed education compulsory school, or an upper secondary programme you did not finish?', '2026-08-29 00:51:27.012844+00'),
	('eaa5e1a7-1cce-4918-8d01-069ce82b2b8c', 'en', 'Är du 40 år eller yngre?', 'Are you 40 or younger?', '2026-08-29 00:51:27.012844+00'),
	('5a3afa60-bd39-4c7e-8cbc-6e37319e8ea2', 'en', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Are you registered as a jobseeker with Arbetsförmedlingen?', '2026-08-29 00:51:27.012844+00'),
	('bb0a0a46-e4cf-4d8b-8da9-a32a9274f4ba', 'en', 'Är du mellan 18 och 28 år?', 'Are you between 18 and 28?', '2026-08-29 00:51:27.012844+00'),
	('1ed1040b-c3f8-465e-b3a8-5c067b603d9c', 'en', 'Är du mellan 19 och 29 år?', 'Are you between 19 and 29?', '2026-08-29 00:51:27.012844+00'),
	('b4c5acdf-4f6e-4d45-bd75-50bc53bb2405', 'en', 'Är du mellan 25 och 60 år?', 'Are you between 25 and 60?', '2026-08-29 00:51:27.012844+00'),
	('5545e6f7-cf64-4f17-8512-854432dea531', 'en', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Are you professionally active in the cultural sector (e.g. dance, music, performing arts)?', '2026-08-29 00:51:27.012844+00');
INSERT INTO public.kb_translations VALUES
	('75439869-bcdf-4647-a6b6-ce190c4141b7', 'en', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Are you a professional artist (not an amateur or in basic training)?', '2026-08-29 00:51:27.012844+00'),
	('067a507f-b3c9-491e-a438-dc0f2b4738ea', 'en', 'Är du yrkesverksam konstnär?', 'Are you a professional artist?', '2026-08-29 00:51:27.012844+00'),
	('b8ec6547-5e3d-4871-8aaa-f251ca1d0bbc', 'en', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Is your solution substantially innovative compared with what already exists?', '2026-08-29 00:51:27.016331+00'),
	('441295a4-cbfd-4325-936e-d170bc8b6eb4', 'en', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Is the club affiliated to a specialised sports federation within Riksidrottsförbundet?', '2026-08-29 00:51:27.016331+00'),
	('c6884c2c-e67c-479e-a4ad-6565067ce2fd', 'en', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Is the household''s income low in relation to the housing cost?', '2026-08-29 00:51:27.016331+00'),
	('b6cc055e-cc49-4f59-9c92-4dac14f2a8b4', 'en', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Is the household''s combined income lower than about SEK 25,000 a month before tax?', '2026-08-29 00:51:27.016331+00'),
	('4a997650-c58b-4b27-9659-4a073309b3dc', 'en', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Is the initiative a defined project (not regular operations)?', '2026-08-29 00:51:27.016331+00'),
	('ea088b30-c19d-40d9-84d7-e717513f1eae', 'en', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Is the venue open to everyone — not just your own members?', '2026-08-29 00:51:27.016331+00'),
	('5ad74f9d-8f88-4813-905b-64887004921b', 'en', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Are at least 60% of the members between 6 and 25 years old?', '2026-08-29 00:51:27.016331+00'),
	('348a6aae-9f97-42c6-adc3-5471636c66b5', 'en', 'Är minst 60 % av medlemmarna under 26 år?', 'Are at least 60% of the members under 26?', '2026-08-29 00:51:27.016331+00'),
	('44c1955f-c63b-4a2a-89ad-6f6d73fd3a3b', 'en', 'Är målgruppen delaktig i planering och genomförande?', 'Is the target group involved in planning and implementation?', '2026-08-29 00:51:27.016331+00'),
	('6a460e41-d9db-4a92-89b2-c4bc55d9caea', 'en', 'Är ni ett förlag med professionell utgivning?', 'Are you a publisher with professional publishing?', '2026-08-29 00:51:27.016331+00'),
	('fcff3baf-29b6-4bc3-af52-d46e2900ad5e', 'en', 'Är ni huvudman för förskoleklass eller grundskola?', 'Are you the authority responsible for a preschool class or compulsory school?', '2026-08-29 00:51:27.016331+00'),
	('df826707-c259-486c-86a3-badce15aabd9', 'en', 'Är organisationen registrerad i EU:s deltagarregister?', 'Is the organisation registered in the EU''s participant register?', '2026-08-29 00:51:27.016331+00'),
	('56cae24a-f443-4d4e-bef3-6b7233e1a11b', 'en', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Is the project a film project (short film or documentary)?', '2026-08-29 00:51:27.016331+00'),
	('e5d10c67-03c0-4030-a67b-ea3f87fe43d8', 'en', 'Är projektet ett konst- eller kulturprojekt?', 'Is the project an arts or culture project?', '2026-08-29 00:51:27.016331+00'),
	('fa05e48c-a689-4eea-855c-12fe77607e09', 'en', 'Är projektet ett kulturprojekt?', 'Is the project a culture project?', '2026-08-29 00:51:27.016331+00'),
	('08d8f0a0-9dca-4a34-8687-20a557cf7078', 'en', 'Är projektet ett musikprojekt?', 'Is the project a music project?', '2026-08-29 00:51:27.016331+00'),
	('6c134b2c-b5cf-45d5-845b-a2b0c6ce3f13', 'en', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Is the project innovative — something you do not already do in regular operations?', '2026-08-29 00:51:27.016331+00'),
	('4eeb3968-cf75-4240-b267-67206052136b', 'en', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Does the project benefit the community at large (not individuals)?', '2026-08-29 00:51:27.016331+00'),
	('b9ab4c56-1ae2-4866-b813-7300158ac1ee', 'en', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Is the journey between home and upper secondary school at least six kilometres?', '2026-08-29 00:51:27.016331+00'),
	('e0c3e450-baca-4ff0-a5a6-4ecb482f971c', 'en', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Are the activities professional (not amateur)?', '2026-08-29 00:51:27.016331+00'),
	('810868f9-b6be-43aa-a69b-c8fc7a4c9225', 'en', 'Är verksamheten professionell?', 'Are the activities professional?', '2026-08-29 00:51:27.016331+00'),
	('3c429442-2367-49d4-b75b-6441a72712ef', 'en', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Are the activities performing arts (dance, theatre, musical theatre)?', '2026-08-29 00:51:27.016331+00'),
	('fda0e04c-afcc-4d5b-8211-f0cd6abfb3e2', 'es', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Apoyo a actividades para clubes deportivos con actividades dirigidas por monitores para niños y jóvenes de 7 a 25 años.', '2026-08-29 00:51:27.021303+00'),
	('e853cb13-8fa4-42ed-ad6f-379836e5a681', 'es', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Suplemento automático a la asignación por hijo (barnbidrag) a partir del segundo hijo.', '2026-08-29 00:51:27.021303+00'),
	('68b15464-bd7a-4031-8b9f-94ccc80455f2', 'es', 'Avser ansökan en fysisk investering?', '¿La solicitud se refiere a una inversión física?', '2026-08-29 00:51:27.021303+00'),
	('47d5bfd9-2ec2-46f4-abde-333c58f4237d', 'es', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', '¿La solicitud se refiere a un viaje o intercambio internacional?', '2026-08-29 00:51:27.021303+00'),
	('4c71a0e7-b0e7-4855-95ed-2f9794076324', 'es', 'Avser ansökan en investering i byggnader eller maskiner?', '¿La solicitud se refiere a una inversión en edificios o maquinaria?', '2026-08-29 00:51:27.021303+00'),
	('d6f4d4c7-7d12-4eb7-b1a3-d43128a48704', 'es', 'Avser ansökan en redan utgiven titel?', '¿La solicitud se refiere a un título ya publicado?', '2026-08-29 00:51:27.021303+00'),
	('c6f77e67-27f0-47b5-b454-f4b18f71bfa8', 'es', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', '¿La solicitud se refiere a una empresa agrícola, hortícola o de cría de renos?', '2026-08-29 00:51:27.021303+00'),
	('a621644c-96a7-4d7f-bb0a-ef9051b8231a', 'es', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', '¿La solicitud se refiere a la compra de literatura para bibliotecas públicas o escolares?', '2026-08-29 00:51:27.021303+00'),
	('62534baa-d10d-4b4a-aaaf-9b2a6071bd86', 'es', 'Avser investeringen jordbruksverksamhet?', '¿La inversión se refiere a una actividad agrícola?', '2026-08-29 00:51:27.021303+00'),
	('23367f2b-3eff-4c1e-8eec-20b5f07e157a', 'es', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', '¿El proyecto consiste en construir, comprar o renovar un local?', '2026-08-29 00:51:27.021303+00'),
	('d527d48c-ed39-4127-b76b-b743c249e851', 'es', 'Avser projektet naturvård eller friluftsliv?', '¿El proyecto se refiere a la conservación de la naturaleza o a actividades al aire libre?', '2026-08-29 00:51:27.021303+00'),
	('de1c030e-33af-4492-87e2-cc125416e8a5', 'es', 'Avser projektet skola eller vuxenutbildning?', '¿El proyecto se refiere a la escuela o a la educación de adultos?', '2026-08-29 00:51:27.021303+00'),
	('b09820b8-b79d-429f-a963-de5963933a6e', 'es', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', '¿Deja usted de trabajar para cuidar o estar cerca de un familiar tan gravemente enfermo que la enfermedad es una amenaza para su vida?', '2026-08-29 00:51:27.021303+00'),
	('c2f87a0b-b07f-4c0f-b099-e6a27a480b6e', 'es', 'Bedriver föreningen regelbunden verksamhet i kommunen?', '¿La asociación desarrolla actividades regulares en el municipio?', '2026-08-29 00:51:27.021303+00'),
	('e83aaafa-9b75-44e1-b2b3-fcdcc59e8304', 'es', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', '¿Considera que su capacidad de trabajo está reducida durante al menos un año por enfermedad o discapacidad?', '2026-08-29 00:51:27.021303+00'),
	('706a31f7-801e-428b-8315-efdc9974f4e1', 'es', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Apoyo sujeto a comprobación de recursos para quien tiene una pensión baja o nula y necesita ayuda para alcanzar un nivel de vida razonable.', '2026-08-29 00:51:27.021303+00'),
	('899c6435-e58e-4f93-afa3-60b95242bbd7', 'es', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', '¿El menor necesita vivir en la localidad de estudios (alojamiento) porque el trayecto es demasiado largo?', '2026-08-29 00:51:27.021303+00'),
	('259c7d5f-64d4-4697-b0a5-7f48699fc234', 'es', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', '¿La vivienda necesita adaptarse (p. ej. rampa, abridor de puertas, baño)?', '2026-08-29 00:51:27.021303+00'),
	('4677a6b6-b7d8-4c07-af0a-f6eb960418e3', 'es', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', '¿Alguno de sus hijos de 8 a 19 años necesita gafas o lentillas?', '2026-08-29 00:51:27.021303+00'),
	('013e374a-3a84-4742-bf9d-59bb396ea460', 'es', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', '¿El otro progenitor no paga nada o paga menos que la pensión alimenticia completa?', '2026-08-29 00:51:27.021303+00'),
	('4b3bd256-cd0f-41dc-afc0-929147e8730b', 'es', 'Betalar du hyra eller andra boendekostnader?', '¿Paga usted alquiler u otros gastos de vivienda?', '2026-08-29 00:51:27.021303+00'),
	('a38d3bcf-2c2d-49d5-8005-8fe65f61cc53', 'es', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Subvención para adaptar la vivienda en caso de discapacidad — p. ej. rampas, abridores de puertas o adaptación del baño.', '2026-08-29 00:51:27.021303+00'),
	('482dedca-66fc-4a78-944b-85549a46a7a4', 'es', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Subvenciones para construir, comprar o renovar locales públicos de reunión.', '2026-08-29 00:51:27.021303+00'),
	('374d4f15-3dba-4ee5-931a-8ffcf9c6ea8a', 'es', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Subvención para comprar o adaptar un coche cuando una discapacidad permanente hace muy difícil desplazarse o usar el transporte público.', '2026-08-29 00:51:27.021303+00'),
	('cf25ca33-49e9-4ca8-8ca5-79ba3e97b1e3', 'es', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Subvenciones para viajes e intercambios internacionales de profesionales del sector cultural.', '2026-08-29 00:51:27.021303+00'),
	('45a3fef4-ad21-4b9e-872d-ace70237e75b', 'es', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Subvenciones para intercambios internacionales, viajes y estancias de trabajo de artistas profesionales.', '2026-08-29 00:51:27.021303+00');
INSERT INTO public.kb_translations VALUES
	('4ba2249c-0ca9-4cda-8afe-7cacc7d40725', 'es', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Beca y préstamo voluntario para estudios de nivel secundario superior o postsecundario.', '2026-08-29 00:51:27.021303+00'),
	('8007d402-d25f-4497-a6b6-d1719b83ccca', 'es', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Becas y préstamos para estudiar en el extranjero, con préstamos adicionales para p. ej. tasas académicas y viajes.', '2026-08-29 00:51:27.021303+00'),
	('79e67696-52de-4900-9885-57c0ee8ecd58', 'es', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Subvención que ayuda a actores suecos a preparar solicitudes para programas de la UE como Horisont Europa.', '2026-08-29 00:51:27.021303+00'),
	('c7de3e9d-93cc-48e8-a8e9-52c02d17df9b', 'es', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Subvención para empleadores que contratan a personas con capacidad de trabajo reducida.', '2026-08-29 00:51:27.021303+00'),
	('2ffb81f1-e437-4f51-87cb-77a66f448098', 'es', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Subvención para alojamiento y viajes a casa cuando un estudiante de secundaria superior debe vivir en la localidad de estudios por la distancia.', '2026-08-29 00:51:27.021303+00'),
	('4efe4b55-c17a-4f6c-be98-7f3208a9fdd2', 'es', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Subvenciones para el trabajo de organizaciones sin ánimo de lucro por conservar, usar y desarrollar el patrimonio cultural.', '2026-08-29 00:51:27.021303+00'),
	('2279a9ac-b0ab-4b18-b067-cc4c333063d2', 'es', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Subvenciones para proyectos municipales y locales de conservación de la naturaleza, incluidos humedales y actividades al aire libre.', '2026-08-29 00:51:27.021303+00'),
	('aff554a1-b471-4194-a832-5a02b50c6727', 'es', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Subvenciones a municipios para la compra de literatura para bibliotecas públicas y escolares.', '2026-08-29 00:51:27.021303+00'),
	('9b43cbc3-6ac5-452b-8a3e-2799fecfe3dd', 'es', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Apoyo a la transición de la industria hacia cero emisiones de gases de efecto invernadero.', '2026-08-29 00:51:27.021303+00'),
	('18a09d24-1625-4d88-96a8-d7f1af2e9bbd', 'es', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Subvenciones a titulares de escuelas para el encuentro de los alumnos con la cultura profesional en la escuela obligatoria.', '2026-08-29 00:51:27.021303+00'),
	('5c09c328-5a60-497b-8ba7-7d108bae47b2', 'es', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Ayuda para lo que su hijo necesita pero la economía familiar no alcanza a cubrir: actividades de ocio, ropa, excursiones escolares, gafas, actividades vacacionales y más.', '2026-08-29 00:51:27.021303+00'),
	('b34d9bca-0717-43dc-be04-da97c70ab40d', 'es', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Ayudas de fondos como Världens Barn, Musikhjälpen y Victoriafonden — solicitadas por organizaciones suecas sin ánimo de lucro con 90-konto.', '2026-08-29 00:51:27.021303+00'),
	('3a87be25-ea1c-45cd-a538-c543eda131d1', 'es', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Ayudas de los fondos de energía hidroeléctrica y eólica para proyectos que desarrollan la comarca.', '2026-08-29 00:51:27.021303+00'),
	('95ffaaf7-2989-4bbd-8ea5-c786c26c2262', 'es', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Beca sin componente de préstamo para desempleados de 25 a 60 años con estudios previos cortos que necesitan estudiar a nivel de primaria o secundaria.', '2026-08-29 00:51:27.021303+00'),
	('15ed527e-12c8-479e-a547-a90908b7a52b', 'es', 'Bidrar projektet till energiomställningen?', '¿El proyecto contribuye a la transición energética?', '2026-08-29 00:51:27.021303+00'),
	('722a72bc-3a94-4292-b67f-a6f5fcf3d4dc', 'es', 'Bor du och barnets andra förälder på skilda håll?', '¿Usted y el otro progenitor del menor viven separados?', '2026-08-29 00:51:27.021303+00'),
	('885e87f2-65b5-4da2-a30a-e08fe64e27aa', 'es', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Cheques para pequeñas empresas para incorporar competencias externas en internacionalización o digitalización.', '2026-08-29 00:51:27.021303+00'),
	('97c4ecab-65e9-4ade-b115-ceb54cab1b81', 'es', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', '¿Participa usted en un programa de Arbetsförmedlingen (p. ej. jobb- och utvecklingsgarantin)?', '2026-08-29 00:51:27.021303+00'),
	('99156f14-c933-4ee8-83c8-b72be569517e', 'es', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Apoyo a posteriori a editoriales por la publicación de literatura de calidad.', '2026-08-29 00:51:27.021303+00'),
	('f841dbcc-e785-43a0-81f7-31d5e5b78300', 'es', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Apoyo económico para quien tiene un permiso de residencia por protección y desea voluntariamente regresar de forma permanente a su país de origen.', '2026-08-29 00:51:27.021303+00'),
	('c1e49ca7-7265-4792-b360-3a3c043d65b3', 'es', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Apoyo económico a empleadores que contratan a alguien que ha estado mucho tiempo fuera de la vida laboral.', '2026-08-29 00:51:27.021303+00'),
	('a3523f89-b933-4ffc-a94d-a43eeef2ac38', 'es', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Apoyo económico durante la fase inicial para demandantes de empleo que crean su propia empresa.', '2026-08-29 00:51:27.021303+00'),
	('4861f7ad-1c03-46bb-b9c6-7f958c670281', 'es', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten abre continuamente convocatorias en investigación energética, innovación y eficiencia energética.', '2026-08-29 00:51:27.021303+00'),
	('aa51ba9e-0149-439e-a7b7-206455b083e2', 'es', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Prestación por ausentarse del trabajo o de los estudios para cuidar de un hijo.', '2026-08-29 00:51:27.021303+00'),
	('ddbb1e19-517c-45b4-b445-1ec0ca208b00', 'es', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Prestación para quien es nuevo en Suecia y participa en el programa de establecimiento de Arbetsförmedlingen; la paga Försäkringskassan.', '2026-08-29 00:51:27.021303+00'),
	('a063de25-b422-414d-b97b-39076df3d4e1', 'es', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Prestación que cubre parte del gasto de vivienda para jóvenes sin hijos con ingresos bajos.', '2026-08-29 00:51:27.021303+00'),
	('b022d05c-b434-481f-a838-6ccc32b0beb5', 'es', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Prestación por los gastos adicionales que conlleva una discapacidad permanente — para adultos o para padres de niños con discapacidad.', '2026-08-29 00:51:27.021303+00'),
	('f8fc5461-39f9-40d8-80c4-7c63ba3a3f28', 'es', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Prestación para jóvenes (19–29 años) que no pueden trabajar a tiempo completo durante al menos un año por enfermedad o discapacidad.', '2026-08-29 00:51:27.021303+00'),
	('2214a153-53f5-410f-9be9-949abe722451', 'es', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Prestación cuando la capacidad de trabajo está reducida de forma permanente — lo que antes se llamaba förtidspension (jubilación anticipada).', '2026-08-29 00:51:27.021303+00'),
	('a34c50cc-849f-45d3-96d4-6ac7423293a1', 'es', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Prestación cuando usted deja de trabajar para estar cerca de un familiar gravemente enfermo.', '2026-08-29 00:51:27.021303+00'),
	('9a40aa16-de6f-4b86-9710-db86043f92cf', 'es', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Prestación cuando participa en un programa de política laboral de Arbetsförmedlingen.', '2026-08-29 00:51:27.021303+00'),
	('e4add0f8-fdc6-43d1-8cb9-434ba4903a83', 'es', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Prestación cuando no puede trabajar con normalidad por enfermedad.', '2026-08-29 00:51:27.021303+00'),
	('66b6d5b0-ed98-428c-9b15-56df27d6cd0d', 'es', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Prestación cuando se queda en casa sin ir al trabajo para cuidar de un hijo enfermo.', '2026-08-29 00:51:27.021303+00'),
	('cff1fd6f-16c8-46b6-8b37-e0c6b9f318fa', 'es', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Prestación que cubre parte del gasto de vivienda para hogares con hijos e ingresos más bajos.', '2026-08-29 00:51:27.021303+00'),
	('718ca82f-fd9f-4e65-bff8-3b6daa6f7bf6', 'es', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Prestación para padres cuyos hijos, por discapacidad, necesitan más cuidado y supervisión que otros niños de la misma edad.', '2026-08-29 00:51:27.021303+00'),
	('39c4a054-1c10-4ba1-b414-0a5e061777b3', 'es', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Prestación por desempleo — basada en los ingresos para afiliados, importe básico para los demás.', '2026-08-29 00:51:27.021303+00'),
	('7bbe301b-0475-47c5-bc70-eabddda56ef0', 'es', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Una cincuentena de fundaciones de cajas de ahorros conceden ayudas a proyectos locales de deporte, cultura, educación y desarrollo comunitario — en la zona de actividad de la caja.', '2026-08-29 00:51:27.021303+00'),
	('7cc46be9-9035-4f8b-ad77-5b800ab58028', 'es', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Apoyo a proyectos financiado por la UE que se solicita en su zona Leader local — para asociaciones, empresas y municipios que desarrollan el medio rural.', '2026-08-29 00:51:27.021303+00'),
	('70721ae8-794b-4c69-a4df-9110d4236ed4', 'es', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Apoyo financiado por la UE para demandantes de empleo que aceptan un trabajo en otro país UE/EEE: compensación por viaje de entrevista, gastos de mudanza y curso de idiomas.', '2026-08-29 00:51:27.021303+00'),
	('ac595357-9943-4534-b4d6-805c68ff19de', 'es', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Fondos del Fondo Social Europeo para proyectos que refuerzan las competencias, la transición y la inclusión en el mercado laboral.', '2026-08-29 00:51:27.021303+00'),
	('227aa74a-a1c0-45ca-b364-69461dd55f37', 'es', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Apoyo de la UE para intercambios de grupos de jóvenes de 13 a 30 años, de 5 a 21 días sin contar los días de viaje.', '2026-08-29 00:51:27.021303+00'),
	('4be59266-3a26-439e-8d28-da5cc138f48d', 'es', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Apoyo de la UE para proyectos de cooperación de organizaciones culturales con socios en varios países europeos.', '2026-08-29 00:51:27.021303+00'),
	('ea240548-33d1-44ac-980b-5ba1d42894e1', 'es', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Apoyo de la UE para organizaciones que reciben o envían jóvenes voluntarios de 18 a 30 años.', '2026-08-29 00:51:27.021303+00'),
	('cd6eb13b-0114-4d22-80c6-89d3cb6f0c45', 'es', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Apoyo de la UE para la movilidad de personal y alumnado en la escuela y la educación de adultos.', '2026-08-29 00:51:27.021303+00'),
	('a4cd506d-c656-4e83-a758-2f48429aea92', 'es', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Apoyo de la UE con importes a tanto alzado para los primeros proyectos europeos de cooperación de organizaciones pequeñas.', '2026-08-29 00:51:27.021303+00'),
	('e0345abd-181f-44be-8c05-3aba2a64333b', 'es', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Financiación para empresas jóvenes que desarrollan productos o servicios innovadores con potencial internacional.', '2026-08-29 00:51:27.021303+00'),
	('8ebf87d3-7ba0-4672-9dd9-0a7121091c27', 'es', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', '¿Hay una caja de ahorros (y por tanto una fundación de caja de ahorros) donde desarrollan su actividad?', '2026-08-29 00:51:27.021303+00'),
	('77b1115a-8225-4049-bc0b-c50681fc789d', 'es', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Subvenciones de funcionamiento plurianuales para grupos profesionales independientes de danza, teatro y teatro musical.', '2026-08-29 00:51:27.021303+00'),
	('c5341eb6-5a9d-498b-9ea3-3fdd82b29c59', 'es', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Ayudas a la investigación en los ámbitos de Forte: salud, vida laboral y bienestar. Las solicitan investigadores doctorados de universidades suecas.', '2026-08-29 00:51:27.021303+00'),
	('027a0a34-dee3-4669-bfe4-4601f654cff4', 'es', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Fondos de investigación para investigación básica libre en todos los campos científicos.', '2026-08-29 00:51:27.021303+00');
INSERT INTO public.kb_translations VALUES
	('9b509ed6-f476-4407-b79d-7ef04584dcc8', 'es', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Fondos de investigación en medio ambiente, ciencias agrarias y urbanismo.', '2026-08-29 00:51:27.021303+00'),
	('0045f14d-e83f-4216-8d16-eb3689bd13e2', 'es', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', '¿Está pensando en mudarse al extranjero (por trabajo, estudios o retorno)?', '2026-08-29 00:51:27.021303+00'),
	('f8e98349-92ea-4dce-878c-7c2cf0b46951', 'es', 'Genomförs insatserna av professionella kulturaktörer?', '¿Las actividades las realizan agentes culturales profesionales?', '2026-08-29 00:51:27.021303+00'),
	('0e10aceb-0a46-44c8-be75-1375a4696662', 'es', 'Genomförs projektet på landsbygden eller i en mindre tätort?', '¿El proyecto se realiza en el medio rural o en una localidad pequeña?', '2026-08-29 00:51:27.021303+00'),
	('d4119419-dfb4-4e32-90aa-0269e986c4cc', 'es', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Protección básica para quien ha tenido pocos o ningún ingreso laboral durante su vida.', '2026-08-29 00:51:27.021303+00'),
	('63215b4f-2106-4569-af38-6337444e52ff', 'es', 'Går något av dina barn i grundskolan?', '¿Alguno de sus hijos va a la escuela obligatoria?', '2026-08-29 00:51:27.021303+00'),
	('afa37bf3-9f9c-4c19-b716-2949a920eb3b', 'es', 'Går något av dina barn på gymnasiet?', '¿Alguno de sus hijos va al instituto (gymnasiet)?', '2026-08-29 00:51:27.021303+00'),
	('3393d81a-2b7d-4262-9cef-211103420ff7', 'es', 'Gäller anställningen en person med nedsatt arbetsförmåga?', '¿La contratación se refiere a una persona con capacidad de trabajo reducida?', '2026-08-29 00:51:27.021303+00'),
	('af0398cb-71de-44b6-8b69-aa4ce1f7ac38', 'es', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', '¿La contratación se refiere a alguien que lleva mucho tiempo en paro o es nuevo en Suecia?', '2026-08-29 00:51:27.021303+00'),
	('1334e6be-80da-45d8-8989-827c3b913735', 'es', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', '¿El proyecto trata de conservar o hacer accesible el patrimonio cultural?', '2026-08-29 00:51:27.021303+00'),
	('50446608-6e49-48da-afe3-c06a033ca33b', 'es', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', '¿El proyecto trata de energía, eficiencia energética o innovación energética?', '2026-08-29 00:51:27.021303+00'),
	('c8e7e1cf-c3b6-4f28-a022-37fbe7b78ff5', 'es', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', '¿El proyecto trata de salud, vida laboral o bienestar?', '2026-08-29 00:51:27.021303+00'),
	('c06c3bb3-fb5c-40ea-ac65-1193badf5f86', 'es', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', '¿El proyecto trata de desarrollo de competencias o medidas de empleo?', '2026-08-29 00:51:27.021303+00'),
	('28fef377-42a5-4aa9-9ffb-d2ecac65ce73', 'es', 'Handlar projektet om miljö- eller klimatåtgärder?', '¿El proyecto trata de medidas medioambientales o climáticas?', '2026-08-29 00:51:27.021303+00'),
	('651aeef1-36d9-44d2-b228-8c75fab18739', 'es', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', '¿El menor tiene un camino a la escuela largo, peligroso por el tráfico o difícil por otros motivos?', '2026-08-29 00:51:27.021303+00'),
	('9c535232-01ba-476e-9c75-32208b2d9a04', 'es', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', '¿Ha trabajado al menos 16 horas semanales durante un total de al menos 8 años?', '2026-08-29 00:51:27.021303+00'),
	('8e48c4a4-4628-4a94-a7c5-702d0a310dea', 'es', 'Har du barn som bor hos dig, helt eller växelvis?', '¿Tiene hijos que viven con usted, todo el tiempo o en alternancia?', '2026-08-29 00:51:27.021303+00'),
	('4d67c9fc-91f2-4b5f-a893-e4a0aaba7b84', 'es', 'Har du barn som bor hos dig?', '¿Tiene hijos que viven con usted?', '2026-08-29 00:51:27.021303+00'),
	('6ca7d774-28c9-4710-b404-599bf9f1ac92', 'es', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', '¿Usted o su hijo tienen una discapacidad que se espera dure al menos un año?', '2026-08-29 00:51:27.021303+00'),
	('19111d52-7b8d-4599-b4b9-d7fe798cd831', 'es', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', '¿Usted o alguien del hogar tiene una discapacidad permanente que afecta a la vivienda?', '2026-08-29 00:51:27.021303+00'),
	('263c4d95-46e4-4751-a1ef-d474b8a68c0c', 'es', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', '¿Usted o un familiar cercano tiene una discapacidad o una enfermedad prolongada o grave?', '2026-08-29 00:51:27.021303+00'),
	('132ba2dc-8dae-47c6-9a37-359e4d9f4958', 'es', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', '¿Tiene una enfermedad o lesión que ahora mismo reduce su capacidad de trabajo?', '2026-08-29 00:51:27.021303+00'),
	('a816275f-b692-4450-ad38-92fde290c0b8', 'es', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', '¿Alguna vez le ha costado pagar una excursión escolar, un viaje de clase o una actividad de ocio en la que se espera que participe su hijo?', '2026-08-29 00:51:27.021303+00'),
	('f631bbe3-0d91-4af0-85be-4a1c9da5d938', 'es', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', '¿Ha obtenido en los últimos años un permiso de residencia en Suecia, p. ej. como persona necesitada de protección o como familiar?', '2026-08-29 00:51:27.021303+00'),
	('55b6bd84-c720-471f-b675-0806512c1739', 'es', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', '¿Tiene permiso de residencia en Suecia como refugiado o persona necesitada de protección (o es familiar cercano de alguien que lo tiene)?', '2026-08-29 00:51:27.021303+00'),
	('71d8b48e-1420-4f77-bbfa-b61965a1c167', 'es', 'Har du uppnått riktåldern för pension (67 år 2026)?', '¿Ha alcanzado la edad de referencia de jubilación (67 años en 2026)?', '2026-08-29 00:51:27.021303+00'),
	('e2b14e7c-76f9-48fb-aebb-085006f94e10', 'es', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', '¿Su organización tiene un OID (Organisation ID) registrado en el Organisation Registration System de la UE?', '2026-08-29 00:51:27.021303+00'),
	('4ffc16a7-8dd6-4d0d-9d76-fbf3434daab4', 'es', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', '¿La discapacidad ha supuesto gastos adicionales — p. ej. ayudas técnicas, viajes, dieta especial o desgaste?', '2026-08-29 00:51:27.021303+00'),
	('730df96a-9d45-43fb-92f3-6e96bf1db350', 'es', 'Har föreningen antagna stadgar och en vald styrelse?', '¿La asociación tiene estatutos aprobados y una junta directiva elegida?', '2026-08-29 00:51:27.021303+00'),
	('6ce84375-9ac0-4b16-8e03-a888ff1a46b6', 'es', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', '¿La asociación tiene una estructura democrática (estatutos, asamblea anual, junta)?', '2026-08-29 00:51:27.021303+00'),
	('9d8e180f-b60b-4df2-ab02-ee1f014f0c8a', 'es', 'Har föreningen regelbunden verksamhet för barn eller unga?', '¿La asociación desarrolla actividades regulares para niños o jóvenes?', '2026-08-29 00:51:27.021303+00'),
	('d444ab55-42e6-4c8f-af3f-02ba83721879', 'es', 'Har företaget mellan cirka 2 och 49 anställda?', '¿La empresa tiene entre aproximadamente 2 y 49 empleados?', '2026-08-29 00:51:27.021303+00'),
	('709d4c47-df2b-4a51-a546-2ad52847201c', 'es', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', '¿Al hogar le cuesta cubrir los gastos de comida, vivienda y lo más necesario?', '2026-08-29 00:51:27.021303+00'),
	('31cb747e-3849-4b11-800f-6b5b2109710a', 'es', 'Har lösningen internationell potential?', '¿La solución tiene potencial internacional?', '2026-08-29 00:51:27.021303+00'),
	('16e878f0-071d-43fd-bc54-a8e386bee976', 'es', 'Har ni en partnergrupp i ett annat land?', '¿Tienen un grupo socio en otro país?', '2026-08-29 00:51:27.021303+00'),
	('a666377b-2f81-40cf-a9d4-d68720873552', 'es', 'Har ni en partnerorganisation i ett annat europeiskt land?', '¿Tienen una organización socia en otro país europeo?', '2026-08-29 00:51:27.021303+00'),
	('69687063-70e1-4055-8c84-383de8c9f2cd', 'es', 'Har ni partner i minst tre olika europeiska länder?', '¿Tienen socios en al menos tres países europeos distintos?', '2026-08-29 00:51:27.021303+00'),
	('d977e37f-9ac1-4000-b0c7-0ca2e906d21f', 'es', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', '¿Tienen su sede o actividad principal en la región donde solicitan?', '2026-08-29 00:51:27.021303+00'),
	('1f3391a3-4724-4d35-a0c7-c1760c6b9ca7', 'es', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', '¿Alguno de sus hijos tiene una discapacidad por la que necesita más cuidado o supervisión que otros niños de la misma edad?', '2026-08-29 00:51:27.021303+00'),
	('7022724e-2108-42bf-b149-d5ea9574f871', 'es', 'Har organisationen en demokratisk uppbyggnad?', '¿La organización tiene una estructura democrática?', '2026-08-29 00:51:27.021303+00'),
	('1d9566b4-ea99-4303-ba6e-756c72d0dd74', 'es', 'Har organisationen en Quality Label (kvalitetsmärkning)?', '¿La organización tiene una Quality Label (sello de calidad)?', '2026-08-29 00:51:27.021303+00'),
	('74be873c-9146-425c-b482-4ca99c4d3863', 'es', 'Har organisationen ett 90-konto?', '¿La organización tiene un 90-konto?', '2026-08-29 00:51:27.021303+00'),
	('9f8941df-8fe5-41a1-ab9a-395e2381a3fc', 'es', 'Har organisationen ett OID (Organisation ID)?', '¿La organización tiene un OID (Organisation ID)?', '2026-08-29 00:51:27.021303+00'),
	('525a89ef-6ceb-4f67-8403-eace839e3e0b', 'es', 'Har organisationen ett OID?', '¿La organización tiene un OID?', '2026-08-29 00:51:27.021303+00'),
	('a54a27dc-1364-4793-ba76-d8a092b82f07', 'es', 'Har organisationen medlemsföreningar i flera län?', '¿La organización tiene asociaciones miembro en varias provincias?', '2026-08-29 00:51:27.021303+00'),
	('7bf3bb44-240f-474c-904c-6c4f0a262b43', 'es', 'Har organisationen ordnad ekonomi och demokratisk struktur?', '¿La organización tiene una economía ordenada y una estructura democrática?', '2026-08-29 00:51:27.021303+00'),
	('075e8869-b94c-4a81-8433-f3ac222bf9b3', 'es', 'Har projektet en partner i ett annat land?', '¿El proyecto tiene un socio en otro país?', '2026-08-29 00:51:27.021303+00'),
	('3ba1dc02-07e0-426e-997d-4ce7755f4baa', 'es', 'Har projektledaren doktorsexamen?', '¿La persona que lidera el proyecto tiene un doctorado?', '2026-08-29 00:51:27.021303+00'),
	('40cec3bd-7a7e-4c89-8425-e64766110eb6', 'es', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'El municipio de residencia debe garantizar los desplazamientos diarios entre la vivienda y el instituto cuando el trayecto es de al menos seis kilómetros (p. ej. abono de autobús).', '2026-08-29 00:51:27.021303+00'),
	('a651b195-74c5-4916-83e3-e8b1a5708f15', 'es', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', '¿Está consiguiendo o equipando su primera vivienda propia en Suecia?', '2026-08-29 00:51:27.021303+00');
INSERT INTO public.kb_translations VALUES
	('e0ab80cb-1ff6-468b-b1cd-5296724c7ee5', 'es', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', '¿El proyecto incluye un viaje o intercambio internacional?', '2026-08-29 00:51:27.021303+00'),
	('89055335-97e8-4361-9d74-55fa5931cf25', 'es', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Apoyo a la inversión para empresas en zonas de ayuda, para edificios, maquinaria y formación.', '2026-08-29 00:51:27.021303+00'),
	('ef15e565-de62-47db-a0c3-8f427d865ae7', 'es', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Apoyo a inversiones en medidas que reducen las emisiones de gases de efecto invernadero.', '2026-08-29 00:51:27.021303+00'),
	('4a377cbe-2f66-4ad9-b809-d0448648023d', 'es', 'Kan projektets miljönytta mätas?', '¿Se puede medir el beneficio medioambiental del proyecto?', '2026-08-29 00:51:27.021303+00'),
	('773ca94d-c3d7-4915-956d-2621b6d16a7f', 'es', 'Kan åtgärdens utsläppsminskning beräknas?', '¿Se puede calcular la reducción de emisiones de la medida?', '2026-08-29 00:51:27.021303+00'),
	('b67c5b20-7add-469a-a079-1948fe957a11', 'es', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', '¿La organización puede adelantar los gastos hasta que se abone la ayuda?', '2026-08-29 00:51:27.021303+00'),
	('fc5d34a4-35d1-41a8-8743-788dee0161c6', 'es', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', '¿Las experiencias se utilizarán en su actividad en Suecia?', '2026-08-29 00:51:27.021303+00'),
	('a25d5e91-0161-42ea-92fe-b397817c6d30', 'es', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', '¿La inversión comenzará solo después de presentar la solicitud?', '2026-08-29 00:51:27.021303+00'),
	('adddd892-916f-42d1-8b03-ade5943e7276', 'es', 'Kommer projektet människor i ert närområde till del?', '¿El proyecto beneficia a las personas de su entorno?', '2026-08-29 00:51:27.021303+00'),
	('6f4bb541-fcdb-45f4-be49-58a2e15e8ba0', 'es', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'La última red de seguridad económica del municipio cuando los ingresos no alcanzan para lo más necesario.', '2026-08-29 00:51:27.021303+00'),
	('1acecc64-77f6-422c-a7b7-a96bd07a97fc', 'es', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Los apoyos propios de los municipios al tejido asociativo local: ayuda por actividad, ayuda para locales, ayuda inicial y más.', '2026-08-29 00:51:27.021303+00'),
	('2aac1f86-fa8e-4804-9a0a-8369794dedea', 'es', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Apoyo a proyectos de arte y cultura con dimensión nórdica y cooperación transfronteriza.', '2026-08-29 00:51:27.021303+00'),
	('95b08152-312d-486f-a0e8-567507f94d7f', 'es', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Transporte escolar gratuito para alumnos de la escuela obligatoria por distancia larga, camino peligroso o discapacidad — un derecho según la ley escolar.', '2026-08-29 00:51:27.021303+00'),
	('ca777af3-9fb1-42a2-8b8a-82b0458d889e', 'es', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Ayuda legal para gafas o lentillas para niños y jóvenes; los importes y trámites varían por región — compruebe el nivel de su región.', '2026-08-29 00:51:27.021303+00'),
	('78da913b-4c5a-41b9-a1ad-24967f656325', 'es', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', '¿El proyecto está en una comarca afectada por la energía hidroeléctrica o eólica?', '2026-08-29 00:51:27.021303+00'),
	('79991ae6-53b1-44cc-8ad2-d07d54c33c98', 'es', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', '¿El proyecto está dentro de medio ambiente, ciencias agrarias o urbanismo?', '2026-08-29 00:51:27.021303+00'),
	('a80a2d38-abb5-43d1-bf23-be35393de22a', 'es', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', '¿El lugar de actividad está en la zona de ayuda A o B (gran parte de Norrland y el interior de Svealand)?', '2026-08-29 00:51:27.021303+00'),
	('4010bd13-3dae-4864-a98c-53075567c572', 'es', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Préstamo para comprar lo más necesario para un primer hogar en Suecia — muebles, utensilios y otro equipamiento básico.', '2026-08-29 00:51:27.021303+00'),
	('60568388-4f54-45a2-a49b-c5a542222812', 'es', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', '¿El proyecto reduce las emisiones de proceso de la industria o crea emisiones negativas?', '2026-08-29 00:51:27.021303+00'),
	('41072bd1-3cf8-48e3-9d3e-c89c0d7983e0', 'es', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Asignación mensual para niños que viven en Suecia, desde el nacimiento hasta los 16 años.', '2026-08-29 00:51:27.021303+00'),
	('0b0fbfc1-3fe2-4664-9509-9534c7687516', 'es', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket ofrece ayudas a organizaciones, empresas, asociaciones, sector público y particulares en el ámbito medioambiental.', '2026-08-29 00:51:27.021303+00'),
	('c0aca722-8991-4ab2-b0f1-ac43bff4065a', 'es', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', '¿Planea regresar voluntariamente y de forma permanente a su país de origen?', '2026-08-29 00:51:27.021303+00'),
	('f787072f-1454-4bf4-9a1a-03265bd75832', 'es', 'Planerar du att starta eget företag?', '¿Planea crear su propia empresa?', '2026-08-29 00:51:27.021303+00'),
	('8c207aed-1d0a-4e4a-9816-2877d11d4c4f', 'es', 'Planerar du att studera utomlands?', '¿Planea estudiar en el extranjero?', '2026-08-29 00:51:27.021303+00'),
	('e5c70a2b-84a8-43a5-8382-51d4c923c792', 'es', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', '¿Planea estudios que refuercen su posición en el mercado laboral?', '2026-08-29 00:51:27.021303+00'),
	('18bc4bc9-1dfa-4a85-b423-a14cb4217dc4', 'es', 'Planerar ni att anställa?', '¿Planean contratar?', '2026-08-29 00:51:27.021303+00'),
	('27fa983c-da66-427d-8bee-e0b2d8147229', 'es', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', '¿Planean solicitar un programa de la UE (p. ej. Horisont Europa)?', '2026-08-29 00:51:27.021303+00'),
	('f2117510-3269-4b0f-9fb6-6c6ef662f6c8', 'es', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Apoyo a la producción y el desarrollo de cortometrajes y documentales.', '2026-08-29 00:51:27.021303+00'),
	('7de98d6d-931f-496d-9dc4-647cdeb915d9', 'es', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Ayudas a proyectos de la escena musical independiente para conciertos, producción y desarrollo.', '2026-08-29 00:51:27.021303+00'),
	('b0925793-719d-40c7-a047-805cdc3f97ad', 'es', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Ayudas a proyectos de organizaciones sin ánimo de lucro que trabajan con y para niños y jóvenes.', '2026-08-29 00:51:27.021303+00'),
	('c6857737-a194-4105-b027-c4059754cad7', 'es', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', '¿El proyecto explora nuevas expresiones, métodos o colaboraciones artísticas?', '2026-08-29 00:51:27.021303+00'),
	('6f917de7-6d83-4335-bbf0-af6c31b216c6', 'es', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', '¿El intercambio dura de 5 a 21 días (sin contar los días de viaje)?', '2026-08-29 00:51:27.021303+00'),
	('0a761c4d-b58b-4b78-882e-20eb58c151c6', 'es', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Los apoyos propios de las regiones a proyectos y actividades culturales, junto a las ayudas nacionales de Kulturrådet.', '2026-08-29 00:51:27.021303+00'),
	('fb5b4a42-1c06-4799-ab9a-7b80b44b004a', 'es', 'Riktar sig projektet till barn eller unga?', '¿El proyecto se dirige a niños o jóvenes?', '2026-08-29 00:51:27.021303+00'),
	('9fdb3349-5317-4790-849f-bafa09afb22d', 'es', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', '¿El proyecto se dirige a niños, jóvenes, mayores o personas con discapacidad?', '2026-08-29 00:51:27.021303+00'),
	('69f8a9ed-b357-4a49-9e2d-e6cbc0baacf7', 'es', 'Riktar sig verksamheten till barn och unga (7–25 år)?', '¿La actividad se dirige a niños y jóvenes (7–25 años)?', '2026-08-29 00:51:27.021303+00'),
	('b54b11f3-f3c4-406d-ad4f-bd1745a2c6bf', 'es', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', '¿Carece de ahorros o bienes que puedan cubrir los gastos?', '2026-08-29 00:51:27.021303+00'),
	('821c3727-2e76-411c-820f-ff0539613b3a', 'es', 'Samarbetar ni med partner i minst två andra nordiska länder?', '¿Colaboran con socios en al menos otros dos países nórdicos?', '2026-08-29 00:51:27.021303+00'),
	('61709f1c-7560-4dda-bab7-df34c4a8bce0', 'es', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', '¿Van a incorporar competencias externas para una acción de desarrollo?', '2026-08-29 00:51:27.021303+00'),
	('787b1ecb-c530-4106-aea0-21fc7e4d80e6', 'es', 'Sker mobiliteten till ett annat europeiskt land?', '¿La movilidad es hacia otro país europeo?', '2026-08-29 00:51:27.021303+00'),
	('be37d387-6920-426d-b487-5dabf1d58d4f', 'es', 'Startar du eller tar du över företaget för första gången?', '¿Crea o asume la empresa por primera vez?', '2026-08-29 00:51:27.021303+00'),
	('0fd76778-ea15-497f-aaae-9c205995c8f8', 'es', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Ayuda inicial para quien tiene 40 años o menos y crea o asume una empresa agrícola.', '2026-08-29 00:51:27.021303+00'),
	('3c3efb4b-95cc-4ea8-bea6-ea93b087128c', 'es', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Beca que permite a artistas profesionales concentrarse en su trabajo artístico.', '2026-08-29 00:51:27.021303+00'),
	('42971aea-187a-4600-aa5b-2df8d9ffecff', 'es', 'Studerar du, eller planerar du att börja studera?', '¿Estudia, o planea empezar a estudiar?', '2026-08-29 00:51:27.021303+00'),
	('fd3ebd59-b765-415c-8bea-da11e5e67efe', 'es', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Apoyo al estudio para adultos en activo que quieren formarse para reforzar su posición en el mercado laboral.', '2026-08-29 00:51:27.021303+00'),
	('13827bfe-9edf-4306-b6f2-48b21fee3456', 'es', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Apoyo a inversiones que aumentan la competitividad o reducen el impacto ambiental en empresas agrícolas.', '2026-08-29 00:51:27.021303+00'),
	('f89ae4e4-57e1-43ff-bd54-6bad2c18466b', 'es', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Apoyo cuando un hijo vive con usted y el otro progenitor no paga la pensión alimenticia.', '2026-08-29 00:51:27.021303+00'),
	('94b62085-33b5-495a-aa0c-54ae77384e80', 'es', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Apoyo a proyectos de organizaciones sin ánimo de lucro por las personas, el medio ambiente y un mundo mejor.', '2026-08-29 00:51:27.021303+00'),
	('96e9eb57-395b-4bcb-8b90-9b3cbc59970f', 'es', 'Är projektet till nytta för bygden i stort (inte enskilda)?', '¿El proyecto beneficia a la comarca en su conjunto (no a particulares)?', '2026-08-29 00:51:27.024845+00'),
	('956fbe54-4f54-4b73-84d0-9d039b77db84', 'es', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Apoyo a proyectos culturales innovadores que exploran nuevas expresiones, métodos o colaboraciones artísticas.', '2026-08-29 00:51:27.021303+00');
INSERT INTO public.kb_translations VALUES
	('8b802ee7-72e1-4b8b-8196-43c6492b7560', 'es', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Apoyo a proyectos innovadores para niños, jóvenes, mayores y personas con discapacidad.', '2026-08-29 00:51:27.021303+00'),
	('90f4817c-875a-4471-8260-5ef758428877', 'es', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Apoyo a proyectos de cooperación en la escena musical independiente.', '2026-08-29 00:51:27.021303+00'),
	('7be2c592-bb1c-4321-9698-730e90c29c9a', 'es', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Apoyo a proyectos de cooperación en cultura y medios que refuerzan la democracia y la libertad de expresión a nivel internacional.', '2026-08-29 00:51:27.021303+00'),
	('11359f3d-7959-4c53-beae-223942072453', 'es', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', '¿El proyecto busca reforzar la democracia, la igualdad o la libertad de expresión?', '2026-08-29 00:51:27.021303+00'),
	('28258f2a-6df0-44e2-8580-0f60257b5389', 'es', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', '¿Busca trabajo, o ha recibido una oferta de trabajo, en otro país de la UE o del EEE?', '2026-08-29 00:51:27.021303+00'),
	('8d7bdeb7-0843-4126-a55a-9e4862ab3887', 'es', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Tope de lo que debe pagar en tasas sanitarias durante un periodo de doce meses — después, frikort (tarjeta gratuita).', '2026-08-29 00:51:27.021303+00'),
	('2dc5f9ed-a14b-4350-96ff-d271d2e10ccc', 'es', 'Tar du ut hel allmän pension?', '¿Cobra la pensión pública completa?', '2026-08-29 00:51:27.021303+00'),
	('7990fb3d-0b1c-41fb-9a0d-8e4ce976e600', 'es', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Suplemento que cubre parte del gasto de vivienda para quien tiene pensión e ingresos bajos.', '2026-08-29 00:51:27.021303+00'),
	('d60cf8eb-8528-43a9-a0cb-95cabdd0521c', 'es', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Subvención anual de organización para organizaciones nacionales de infancia y juventud.', '2026-08-29 00:51:27.021303+00'),
	('21ad58ad-fcf7-4fa6-9362-d29b20d939f0', 'es', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Saldo anual que se descuenta directamente en el dentista o el higienista dental.', '2026-08-29 00:51:27.021303+00'),
	('15614f25-f632-465e-ae15-22c01732a95e', 'es', 'Är bolaget yngre än cirka 5 år?', '¿La empresa tiene menos de unos 5 años?', '2026-08-29 00:51:27.021303+00'),
	('db84e235-58fe-4675-b497-82a70d228c86', 'es', 'Är deltagarna i utbytet mellan 13 och 30 år?', '¿Los participantes del intercambio tienen entre 13 y 30 años?', '2026-08-29 00:51:27.021303+00'),
	('5858178e-d831-4803-8249-cdd07c999445', 'es', 'Är det här ert första EU-projekt?', '¿Es este su primer proyecto de la UE?', '2026-08-29 00:51:27.021303+00'),
	('9972d8c6-ceb2-4787-a721-f24c6891dbd1', 'es', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', '¿Le resulta muy difícil (a usted o a su hijo) desplazarse por su cuenta o viajar en autobús y tren?', '2026-08-29 00:51:27.021303+00'),
	('5c30c8ba-a1a0-4d9c-9585-e0377dfade2e', 'es', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', '¿Sus ingresos son inferiores a unas 25 000 kr al mes antes de impuestos?', '2026-08-29 00:51:27.021303+00'),
	('c0ca4090-d0a4-4c37-b412-c6f73fb5455f', 'es', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', '¿Su última formación terminada es la escuela obligatoria, o un instituto que no completó?', '2026-08-29 00:51:27.021303+00'),
	('eaed59a4-d584-48ef-945e-a62dd1dc465a', 'es', 'Är du 40 år eller yngre?', '¿Tiene 40 años o menos?', '2026-08-29 00:51:27.021303+00'),
	('3b24b811-951f-41ad-81ed-f94a803afbbb', 'es', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', '¿Está inscrito como demandante de empleo en Arbetsförmedlingen?', '2026-08-29 00:51:27.021303+00'),
	('ea67f91a-240b-4367-bcd8-d959341aeb4d', 'es', 'Är du mellan 18 och 28 år?', '¿Tiene entre 18 y 28 años?', '2026-08-29 00:51:27.021303+00'),
	('638be70f-6ac4-45ff-bc28-bb3b0ac93576', 'es', 'Är du mellan 19 och 29 år?', '¿Tiene entre 19 y 29 años?', '2026-08-29 00:51:27.021303+00'),
	('e0e85527-612b-4d26-8b32-35b25c53de56', 'es', 'Är du mellan 25 och 60 år?', '¿Tiene entre 25 y 60 años?', '2026-08-29 00:51:27.021303+00'),
	('5399be00-aa50-4df6-bcef-5a64f8204174', 'es', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', '¿Trabaja profesionalmente en el sector cultural (p. ej. danza, música, artes escénicas)?', '2026-08-29 00:51:27.021303+00'),
	('adb23144-b382-4118-b9a1-3e79fb331c65', 'es', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', '¿Es artista profesional (no aficionado ni en formación básica)?', '2026-08-29 00:51:27.021303+00'),
	('2413d777-27fc-4039-b402-90c533624226', 'es', 'Är du yrkesverksam konstnär?', '¿Es artista profesional?', '2026-08-29 00:51:27.021303+00'),
	('2906eafe-1475-4642-8913-213e8542de53', 'es', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', '¿Su solución es sustancialmente innovadora en comparación con lo que ya existe?', '2026-08-29 00:51:27.024845+00'),
	('ed676999-5d6e-4643-9a36-eb8706a13d86', 'es', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', '¿El club está afiliado a una federación deportiva especializada dentro de Riksidrottsförbundet?', '2026-08-29 00:51:27.024845+00'),
	('30c12b41-4f06-48ad-94b3-b4141a66fbf1', 'es', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', '¿Los ingresos del hogar son bajos en relación con el gasto de vivienda?', '2026-08-29 00:51:27.024845+00'),
	('49c91753-33f6-4dd7-88fe-9c8806e3b447', 'es', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', '¿Los ingresos conjuntos del hogar son inferiores a unas 25 000 kr al mes antes de impuestos?', '2026-08-29 00:51:27.024845+00'),
	('a43fd7be-be93-4a81-a0f9-72e7518a113e', 'es', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', '¿La acción es un proyecto delimitado (no la actividad ordinaria)?', '2026-08-29 00:51:27.024845+00'),
	('bcabb8a2-87ba-49e0-9d28-a0cf53126d00', 'es', 'Är lokalen öppen för alla — inte bara egna medlemmar?', '¿El local está abierto a todos — no solo a los propios socios?', '2026-08-29 00:51:27.024845+00'),
	('5e490962-1a5b-4cc6-8ce3-a2ba11eacc58', 'es', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', '¿Al menos el 60 % de los miembros tienen entre 6 y 25 años?', '2026-08-29 00:51:27.024845+00'),
	('27bb1b96-62d2-4ad3-8057-23b85d96a1f0', 'es', 'Är minst 60 % av medlemmarna under 26 år?', '¿Al menos el 60 % de los miembros tienen menos de 26 años?', '2026-08-29 00:51:27.024845+00'),
	('25641829-31a4-4dcc-989a-f688cde6d36e', 'es', 'Är målgruppen delaktig i planering och genomförande?', '¿El grupo destinatario participa en la planificación y la ejecución?', '2026-08-29 00:51:27.024845+00'),
	('e616463b-23f1-4eb0-9e9b-da08cfee453c', 'es', 'Är ni ett förlag med professionell utgivning?', '¿Son una editorial con publicación profesional?', '2026-08-29 00:51:27.024845+00'),
	('5873ed75-83c3-491f-ba78-cb54b836adb4', 'es', 'Är ni huvudman för förskoleklass eller grundskola?', '¿Son titulares de una clase de preescolar o de una escuela obligatoria?', '2026-08-29 00:51:27.024845+00'),
	('57b4c7a9-c80d-4c42-b08a-59afe02c2871', 'es', 'Är organisationen registrerad i EU:s deltagarregister?', '¿La organización está registrada en el registro de participantes de la UE?', '2026-08-29 00:51:27.024845+00'),
	('3ba01019-006a-4c5e-a323-bca983a30c78', 'es', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', '¿El proyecto es un proyecto de cine (cortometraje o documental)?', '2026-08-29 00:51:27.024845+00'),
	('3785dfcb-e89d-49fb-85a8-608a2bfdfa15', 'es', 'Är projektet ett konst- eller kulturprojekt?', '¿El proyecto es un proyecto de arte o cultura?', '2026-08-29 00:51:27.024845+00'),
	('5e02c799-66b6-43ac-a838-5614828f92ad', 'es', 'Är projektet ett kulturprojekt?', '¿El proyecto es un proyecto cultural?', '2026-08-29 00:51:27.024845+00'),
	('e977b9e6-1ba7-461b-b452-d44c29e08230', 'es', 'Är projektet ett musikprojekt?', '¿El proyecto es un proyecto musical?', '2026-08-29 00:51:27.024845+00'),
	('d76c1dd5-f5ad-404b-93b6-b643093a820f', 'es', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', '¿El proyecto es innovador — algo que no hacen ya en su actividad ordinaria?', '2026-08-29 00:51:27.024845+00'),
	('b148a48d-9acd-46b8-8288-cb48c97a5970', 'es', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', '¿El trayecto entre la vivienda y el instituto es de al menos seis kilómetros?', '2026-08-29 00:51:27.024845+00'),
	('05ab8170-ee5a-4f1c-93d2-14a8b369f874', 'es', 'Är verksamheten professionell (inte amatörverksamhet)?', '¿La actividad es profesional (no de aficionados)?', '2026-08-29 00:51:27.024845+00'),
	('097b8389-4327-4f29-a179-1d88b9faa07c', 'es', 'Är verksamheten professionell?', '¿La actividad es profesional?', '2026-08-29 00:51:27.024845+00'),
	('e5132fcd-4ef0-4925-b38e-d9b664675eb3', 'es', 'Är verksamheten scenkonst (dans, teater, musikteater)?', '¿La actividad es de artes escénicas (danza, teatro, teatro musical)?', '2026-08-29 00:51:27.024845+00'),
	('a8816c27-e8f8-4dd7-bb36-0186b767ef2d', 'es', 'Är volontärerna mellan 18 och 30 år?', '¿Los voluntarios tienen entre 18 y 30 años?', '2026-08-29 00:51:27.024845+00'),
	('0962e681-740e-43a2-bd98-26be1a4f348c', 'fr', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Aide aux activités pour les clubs sportifs proposant des activités encadrées pour les enfants et les jeunes de 7 à 25 ans.', '2026-08-29 00:51:27.030182+00'),
	('5954f7d5-32bf-4e32-aa19-ef5fab640bee', 'fr', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Complément automatique à l''allocation pour enfant (barnbidrag) à partir du deuxième enfant.', '2026-08-29 00:51:27.030182+00'),
	('8598326e-108f-4660-987a-2c8056353b62', 'fr', 'Avser ansökan en fysisk investering?', 'La demande concerne-t-elle un investissement physique ?', '2026-08-29 00:51:27.030182+00'),
	('c8e593fe-6e49-4135-865e-51d7951a4b05', 'fr', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'La demande concerne-t-elle un voyage ou un échange international ?', '2026-08-29 00:51:27.030182+00');
INSERT INTO public.kb_translations VALUES
	('97d2142a-fa9b-4738-8666-619ff260e467', 'fr', 'Avser ansökan en investering i byggnader eller maskiner?', 'La demande concerne-t-elle un investissement dans des bâtiments ou des machines ?', '2026-08-29 00:51:27.030182+00'),
	('a34cdc2e-cecf-4b3d-96cc-fcfb5496c917', 'fr', 'Avser ansökan en redan utgiven titel?', 'La demande concerne-t-elle un titre déjà publié ?', '2026-08-29 00:51:27.030182+00'),
	('8e6bad2c-cace-4521-b7a5-7e8a2467684c', 'fr', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'La demande concerne-t-elle une entreprise agricole, horticole ou d''élevage de rennes ?', '2026-08-29 00:51:27.030182+00'),
	('67290557-96c7-48dd-a2d0-9ec7f4ddbe8b', 'fr', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'La demande concerne-t-elle l''achat de littérature pour des bibliothèques publiques ou scolaires ?', '2026-08-29 00:51:27.030182+00'),
	('eedc8a16-041a-40bb-8da5-ccf4b883403c', 'fr', 'Avser investeringen jordbruksverksamhet?', 'L''investissement concerne-t-il une activité agricole ?', '2026-08-29 00:51:27.030182+00'),
	('8103c192-4e54-46a5-bd9a-8861478e905c', 'fr', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Le projet consiste-t-il à construire, acheter ou rénover un local ?', '2026-08-29 00:51:27.030182+00'),
	('03c3e464-1e5d-4bc9-ad1d-b97378ff9d4e', 'fr', 'Avser projektet naturvård eller friluftsliv?', 'Le projet concerne-t-il la protection de la nature ou les activités de plein air ?', '2026-08-29 00:51:27.030182+00'),
	('afb785df-af41-47fd-b7c2-2c6d07476d81', 'fr', 'Avser projektet skola eller vuxenutbildning?', 'Le projet concerne-t-il l''école ou la formation des adultes ?', '2026-08-29 00:51:27.030182+00'),
	('c71683ad-8169-4a2c-8029-75a35870dc62', 'fr', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Renoncez-vous à travailler pour soigner ou être auprès d''un proche si gravement malade que la maladie menace sa vie ?', '2026-08-29 00:51:27.030182+00'),
	('167690d1-b616-4f89-bb4b-7cafde2a75ad', 'fr', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'L''association mène-t-elle des activités régulières dans la commune ?', '2026-08-29 00:51:27.030182+00'),
	('2bd3164b-5911-4ebb-ad6d-74664ce71dee', 'fr', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Estimez-vous que votre capacité de travail est réduite pendant au moins un an en raison d''une maladie ou d''un handicap ?', '2026-08-29 00:51:27.030182+00'),
	('7f6af86e-8d69-4857-8a83-7a0d6c8a98ac', 'fr', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Aide soumise à conditions de ressources pour ceux qui ont une pension faible ou nulle et ont besoin d''aide pour atteindre un niveau de vie raisonnable.', '2026-08-29 00:51:27.030182+00'),
	('5cf466a5-6f68-4cbb-b3b8-a23f89da0ad4', 'fr', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'L''enfant doit-il habiter sur le lieu d''études (hébergement) parce que le trajet est trop long ?', '2026-08-29 00:51:27.030182+00'),
	('5fc58ef2-2106-46d5-aaa0-11a9053169b0', 'fr', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Le logement doit-il être adapté (p. ex. rampe, ouvre-porte, salle de bain) ?', '2026-08-29 00:51:27.030182+00'),
	('52e219b4-771c-4710-acd0-df2dd9eb142e', 'fr', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'L''un de vos enfants de 8 à 19 ans a-t-il besoin de lunettes ou de lentilles ?', '2026-08-29 00:51:27.030182+00'),
	('b4da4d0a-b0dd-4d34-88eb-a1a6094cf603', 'fr', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'L''autre parent ne paie-t-il rien, ou moins que la pension alimentaire complète ?', '2026-08-29 00:51:27.030182+00'),
	('aa22bbf4-9462-4222-9522-5e23d9909362', 'fr', 'Betalar du hyra eller andra boendekostnader?', 'Payez-vous un loyer ou d''autres frais de logement ?', '2026-08-29 00:51:27.030182+00'),
	('c3811909-58bb-4168-98c2-d4bbad5eb578', 'fr', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Aide pour adapter le logement en cas de handicap — p. ex. rampes, ouvre-portes ou aménagement de la salle de bain.', '2026-08-29 00:51:27.030182+00'),
	('6a37661e-aca2-4d5c-a1ec-6b4d60a87d46', 'fr', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Aides pour construire, acheter ou rénover des salles de réunion publiques.', '2026-08-29 00:51:27.030182+00'),
	('f072de51-6d95-4119-b0c0-15d73dd6a395', 'fr', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Aide pour acheter ou adapter une voiture lorsqu''un handicap durable rend très difficile de se déplacer ou de prendre les transports en commun.', '2026-08-29 00:51:27.030182+00'),
	('56394e34-a3a5-485c-8481-d962471d29a3', 'fr', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Aides aux voyages et échanges internationaux pour les professionnels du secteur culturel.', '2026-08-29 00:51:27.030182+00'),
	('2d6c2b45-d6af-47a2-a910-2ba4df1c9df4', 'fr', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Aides aux échanges internationaux, voyages et séjours de travail des artistes professionnels.', '2026-08-29 00:51:27.030182+00'),
	('87fbb35a-7f79-4abc-bbe2-522caf135b64', 'fr', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Bourse et prêt facultatif pour des études de niveau secondaire supérieur ou post-secondaire.', '2026-08-29 00:51:27.030182+00'),
	('ecdf3f94-306a-40e7-86f0-d67de9016deb', 'fr', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Bourses et prêts pour étudier à l''étranger, avec des prêts complémentaires pour p. ex. les frais de scolarité et les voyages.', '2026-08-29 00:51:27.030182+00'),
	('cc3b6b65-40cb-4540-8373-33f83377d38e', 'fr', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Aide qui accompagne les acteurs suédois dans la préparation de candidatures aux programmes de l''UE comme Horisont Europa.', '2026-08-29 00:51:27.030182+00'),
	('079a1ccd-75d3-4934-a554-022c88537e68', 'fr', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Aide aux employeurs qui embauchent des personnes à capacité de travail réduite.', '2026-08-29 00:51:27.030182+00'),
	('fbfc2dbf-c910-455c-ace8-465ceec6971c', 'fr', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Aide au logement et aux voyages de retour lorsqu''un lycéen doit habiter sur le lieu d''études en raison d''un long trajet.', '2026-08-29 00:51:27.030182+00'),
	('496ea1dd-53aa-491d-81a7-2c0cfd4186ad', 'uk', 'Är projektet ett musikprojekt?', 'Це музичний проєкт?', '2026-08-29 00:51:27.080311+00'),
	('cca66d17-63b3-4e6b-a234-85a62604f222', 'fr', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Aides au travail des organisations à but non lucratif pour préserver, utiliser et développer le patrimoine culturel.', '2026-08-29 00:51:27.030182+00'),
	('720badad-f35b-4a63-91d7-e4614f29e22a', 'fr', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Aides aux projets communaux et locaux de protection de la nature, y compris les zones humides et les activités de plein air.', '2026-08-29 00:51:27.030182+00'),
	('c97dd87a-bfa0-4c55-b60b-3d9b98629027', 'fr', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Aides aux communes pour l''achat de littérature destinée aux bibliothèques publiques et scolaires.', '2026-08-29 00:51:27.030182+00'),
	('36fba91a-ba96-4eef-b6df-e014c64793bd', 'fr', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Aides aux responsables d''écoles pour la rencontre des élèves avec la culture professionnelle à l''école obligatoire.', '2026-08-29 00:51:27.030182+00'),
	('ebb63206-c8ea-4d41-a30b-1173815013f4', 'fr', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Aide pour ce dont votre enfant a besoin mais que le budget familial ne permet pas : loisirs, vêtements, sorties scolaires, lunettes, activités de vacances et plus.', '2026-08-29 00:51:27.030182+00'),
	('40ac6e67-f3c5-42a0-b5a9-a6a551d12cf9', 'fr', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Aides issues notamment de Världens Barn, Musikhjälpen et Victoriafonden — demandées par des organisations suédoises à but non lucratif titulaires d''un 90-konto.', '2026-08-29 00:51:27.030182+00'),
	('3517b45a-6db3-4364-9c26-b1ce3f2e4590', 'fr', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Aides issues des fonds hydroélectriques et éoliens pour des projets qui développent le territoire.', '2026-08-29 00:51:27.030182+00'),
	('1a23edf2-95f0-431f-8e23-eebcbde187fb', 'fr', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Bourse sans part de prêt pour les demandeurs d''emploi de 25 à 60 ans ayant une scolarité courte et devant étudier au niveau du collège ou du lycée.', '2026-08-29 00:51:27.030182+00'),
	('eb2f8e3c-cc77-4c65-b7b8-8f0bdf47b9f1', 'fr', 'Bidrar projektet till energiomställningen?', 'Le projet contribue-t-il à la transition énergétique ?', '2026-08-29 00:51:27.030182+00'),
	('3a9002c8-f268-4713-92d4-fb652fc34410', 'fr', 'Bor du och barnets andra förälder på skilda håll?', 'Vous et l''autre parent de l''enfant vivez-vous séparément ?', '2026-08-29 00:51:27.030182+00'),
	('83a1e24d-96d3-460c-bc3b-4dae8f916db7', 'fr', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Chèques pour les petites entreprises afin de faire appel à des compétences externes pour l''internationalisation ou la numérisation.', '2026-08-29 00:51:27.030182+00'),
	('43a26a20-6397-47d9-853c-9a5ccbe036a6', 'fr', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Participez-vous à un programme d''Arbetsförmedlingen (p. ex. jobb- och utvecklingsgarantin) ?', '2026-08-29 00:51:27.030182+00'),
	('e732677b-9f55-44f3-82e8-2ec19dab0325', 'fr', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Soutien a posteriori aux maisons d''édition pour la publication de littérature de qualité.', '2026-08-29 00:51:27.030182+00'),
	('f730d05c-999e-4b04-9a0c-9d5b892c0e2a', 'fr', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Aide financière pour ceux qui ont un permis de séjour lié à la protection et souhaitent volontairement retourner définitivement dans leur pays d''origine.', '2026-08-29 00:51:27.030182+00'),
	('cbeffeeb-9b3f-47f5-8ccd-d2fb8a30f142', 'fr', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Aide financière aux employeurs qui embauchent une personne longtemps éloignée de la vie professionnelle.', '2026-08-29 00:51:27.030182+00'),
	('e8e5201f-377f-435a-bed7-b5e77b59ff94', 'fr', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Aide financière pendant la phase de démarrage pour les demandeurs d''emploi qui créent leur entreprise.', '2026-08-29 00:51:27.030182+00'),
	('d8e9b3b6-404d-41ed-8d56-036bc85adc7c', 'fr', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten ouvre en continu des appels à projets en recherche énergétique, innovation et efficacité énergétique.', '2026-08-29 00:51:27.030182+00'),
	('204c3f88-034b-43a0-8eb4-68780ba117f8', 'fr', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Indemnité pour s''absenter du travail ou des études afin de s''occuper d''un enfant.', '2026-08-29 00:51:27.030182+00'),
	('0a680cbf-c494-478e-93d3-5ca8eb3554fa', 'fr', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Indemnité pour ceux qui sont nouveaux en Suède et participent au programme d''établissement d''Arbetsförmedlingen ; versée par Försäkringskassan.', '2026-08-29 00:51:27.030182+00'),
	('eb2ad234-d933-4811-a051-699f27688f49', 'fr', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Indemnité couvrant une partie du coût du logement pour les jeunes sans enfants à faibles revenus.', '2026-08-29 00:51:27.030182+00'),
	('dd8a05ac-177d-4f3b-9f0c-e123d22a6a4f', 'fr', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Indemnité pour les surcoûts qu''entraîne un handicap durable — pour les adultes, ou pour les parents d''enfants handicapés.', '2026-08-29 00:51:27.030182+00'),
	('2943e2cf-8158-4ab6-bb25-eaad063565eb', 'fr', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Indemnité pour les jeunes (19–29 ans) qui ne peuvent pas travailler à plein temps pendant au moins un an pour cause de maladie ou de handicap.', '2026-08-29 00:51:27.030182+00');
INSERT INTO public.kb_translations VALUES
	('ca82c325-3f8e-4059-9a3a-ad74d0b66af9', 'fr', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Indemnité lorsque la capacité de travail est durablement réduite — anciennement appelée förtidspension (retraite anticipée).', '2026-08-29 00:51:27.030182+00'),
	('bd97375e-a584-4f61-800f-8c15ce0ed9bc', 'fr', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Indemnité lorsque vous renoncez à travailler pour être auprès d''un proche gravement malade.', '2026-08-29 00:51:27.030182+00'),
	('f21b266f-7563-4589-bfdd-f55d2f24d442', 'fr', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Indemnité lorsque vous participez à un programme de politique de l''emploi d''Arbetsförmedlingen.', '2026-08-29 00:51:27.030182+00'),
	('c9123827-eacf-4841-b901-64e50059de2d', 'fr', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Indemnité lorsque vous ne pouvez pas travailler normalement pour cause de maladie.', '2026-08-29 00:51:27.030182+00'),
	('20539837-b8f9-4d83-b743-30fb45ace3b7', 'fr', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Indemnité lorsque vous restez à la maison pour vous occuper d''un enfant malade.', '2026-08-29 00:51:27.030182+00'),
	('de82101f-270c-4969-b884-2b5a072c9dbb', 'fr', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Indemnité couvrant une partie du coût du logement pour les ménages avec enfants et revenus modestes.', '2026-08-29 00:51:27.030182+00'),
	('25484a21-2090-49e3-9fcd-9a7a72508a5d', 'fr', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Indemnité pour les parents dont l''enfant, en raison d''un handicap, a besoin de plus de soins et de surveillance que les enfants du même âge.', '2026-08-29 00:51:27.030182+00'),
	('4823de7d-2f31-484d-abb4-33e511c392a7', 'fr', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Indemnité en cas de chômage — basée sur le revenu pour les membres, montant de base pour les autres.', '2026-08-29 00:51:27.030182+00'),
	('d78564c4-ed45-4885-abc5-dd6aafc2fac7', 'fr', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Une cinquantaine de fondations de caisses d''épargne accordent des aides à des projets locaux de sport, culture, éducation et développement local — dans la zone d''activité de la caisse.', '2026-08-29 00:51:27.030182+00'),
	('690f7994-1846-4c1d-a267-bde9d0f78e03', 'fr', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Aide aux projets financée par l''UE, demandée auprès de votre zone Leader locale — pour les associations, entreprises et communes qui développent les zones rurales.', '2026-08-29 00:51:27.030182+00'),
	('bf53b0a8-e7f1-42cf-80b7-4385931ca84a', 'fr', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Aide financée par l''UE pour les demandeurs d''emploi qui prennent un poste dans un autre pays UE/EEE : remboursement du voyage d''entretien, des frais de déménagement et d''un cours de langue.', '2026-08-29 00:51:27.030182+00'),
	('53b10ddb-ba74-4f01-9bcd-7c33865b0ec3', 'fr', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Fonds du Fonds social européen pour des projets renforçant les compétences, la reconversion et l''inclusion sur le marché du travail.', '2026-08-29 00:51:27.030182+00'),
	('107cc0ae-de3f-4778-926a-41fde124b7cc', 'fr', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Aide de l''UE pour des échanges de groupes de jeunes de 13 à 30 ans, de 5 à 21 jours hors jours de voyage.', '2026-08-29 00:51:27.030182+00'),
	('bf9075e9-3371-4fab-8da4-e13766250635', 'fr', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Aide de l''UE pour les projets de coopération d''organisations culturelles avec des partenaires dans plusieurs pays européens.', '2026-08-29 00:51:27.030182+00'),
	('1a1fd903-5a1f-4e87-b714-2c487abd771e', 'fr', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Aide de l''UE pour les organisations qui accueillent ou envoient de jeunes volontaires de 18 à 30 ans.', '2026-08-29 00:51:27.030182+00'),
	('faabcbee-1bd7-46f2-a5ff-7c8867c1d1c0', 'fr', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Aide de l''UE pour la mobilité du personnel et des élèves dans l''école et la formation des adultes.', '2026-08-29 00:51:27.030182+00'),
	('05748b92-634e-414c-a955-767475ccbb7e', 'fr', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Aide de l''UE avec des montants forfaitaires pour les premiers projets européens de coopération des petites organisations.', '2026-08-29 00:51:27.030182+00'),
	('30c9f22c-6d4e-46f0-be76-f2a6c7571631', 'fr', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Financement pour les jeunes entreprises développant des produits ou services innovants à potentiel international.', '2026-08-29 00:51:27.030182+00'),
	('7a0d2e05-482b-4f86-b6a8-3abe8cd8ce91', 'fr', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Y a-t-il une caisse d''épargne (et donc une fondation de caisse d''épargne) là où vous exercez votre activité ?', '2026-08-29 00:51:27.030182+00'),
	('b8ba6d55-5aff-457b-a98c-152d02993c39', 'fr', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Aides de fonctionnement pluriannuelles pour les compagnies professionnelles indépendantes de danse, théâtre et théâtre musical.', '2026-08-29 00:51:27.030182+00'),
	('618ed827-e495-4631-94be-1df67211c9cf', 'fr', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Aides à la recherche dans les domaines de Forte : santé, vie professionnelle et protection sociale. Demandées par des chercheurs titulaires d''un doctorat dans les universités suédoises.', '2026-08-29 00:51:27.030182+00'),
	('81268319-a929-469a-b746-479c64149ade', 'fr', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Financement de la recherche fondamentale libre dans tous les domaines scientifiques.', '2026-08-29 00:51:27.030182+00'),
	('2cc205ec-3c33-41d5-960e-6e2999e5d6ff', 'fr', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Financement de la recherche en environnement, sciences agricoles et aménagement du territoire.', '2026-08-29 00:51:27.030182+00'),
	('7a9a91ca-7d37-4f1a-95c0-c61b45cefe95', 'fr', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Envisagez-vous de vous installer à l''étranger (travail, études ou retour au pays) ?', '2026-08-29 00:51:27.030182+00'),
	('9af6ea1c-a72f-4099-91b8-b883ba479e6d', 'fr', 'Genomförs insatserna av professionella kulturaktörer?', 'Les activités sont-elles menées par des acteurs culturels professionnels ?', '2026-08-29 00:51:27.030182+00'),
	('bd47e5f5-0db0-4e3a-8e09-f3c4334b1b14', 'fr', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Le projet se déroule-t-il en zone rurale ou dans une petite localité ?', '2026-08-29 00:51:27.030182+00'),
	('8c3a1e6c-e997-44e9-b304-2bb3abb60d2a', 'fr', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Protection de base pour ceux qui ont eu peu ou pas de revenus du travail au cours de leur vie.', '2026-08-29 00:51:27.030182+00'),
	('80d0747a-08ab-4a03-8fc3-d9a8e6f599c1', 'fr', 'Går något av dina barn i grundskolan?', 'L''un de vos enfants est-il à l''école obligatoire ?', '2026-08-29 00:51:27.030182+00'),
	('ae43ef66-73ec-4b7a-8f1c-939dd5f1becf', 'fr', 'Går något av dina barn på gymnasiet?', 'L''un de vos enfants est-il au lycée ?', '2026-08-29 00:51:27.030182+00'),
	('942ecc9f-bea2-487c-b333-a601a3f92d76', 'fr', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'L''embauche concerne-t-elle une personne à capacité de travail réduite ?', '2026-08-29 00:51:27.030182+00'),
	('421e1b95-8ae6-4e2f-a8e8-35e36e5b9a85', 'fr', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'L''embauche concerne-t-elle une personne longtemps au chômage ou nouvelle en Suède ?', '2026-08-29 00:51:27.030182+00'),
	('187de79a-84ed-4eca-8e60-9bfae8b4ee5f', 'fr', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Le projet vise-t-il à préserver ou à rendre accessible le patrimoine culturel ?', '2026-08-29 00:51:27.030182+00'),
	('ae79b563-447d-4659-a77b-a26f9c8c1235', 'fr', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Le projet porte-t-il sur l''énergie, l''efficacité énergétique ou l''innovation énergétique ?', '2026-08-29 00:51:27.030182+00'),
	('ba623df7-a5ba-4df6-bc4e-7d3650e287cc', 'fr', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Le projet porte-t-il sur la santé, la vie professionnelle ou la protection sociale ?', '2026-08-29 00:51:27.030182+00'),
	('0476dcce-0348-447f-98a3-4fefea81f0c5', 'fr', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Le projet porte-t-il sur le développement des compétences ou des mesures pour l''emploi ?', '2026-08-29 00:51:27.030182+00'),
	('ae6a7cda-35f3-4e8a-aca6-37bf7fed02b7', 'fr', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Le projet porte-t-il sur des mesures environnementales ou climatiques ?', '2026-08-29 00:51:27.030182+00'),
	('f5f3e9c1-3312-4711-bf68-6162746cd1bb', 'fr', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'L''enfant a-t-il un chemin vers l''école long, dangereux à cause de la circulation ou difficile d''une autre manière ?', '2026-08-29 00:51:27.030182+00'),
	('a19224dd-b8d3-4b56-a86b-2fc88f60694e', 'fr', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Avez-vous travaillé au moins 16 heures par semaine pendant au moins 8 ans au total ?', '2026-08-29 00:51:27.030182+00'),
	('3f5ac34e-2025-4335-b507-c4ac8391de25', 'fr', 'Har du barn som bor hos dig, helt eller växelvis?', 'Avez-vous des enfants qui vivent chez vous, à plein temps ou en alternance ?', '2026-08-29 00:51:27.030182+00'),
	('dac3f912-b208-49e7-96d8-c1bc1417b14b', 'fr', 'Har du barn som bor hos dig?', 'Avez-vous des enfants qui vivent chez vous ?', '2026-08-29 00:51:27.030182+00'),
	('6b7a818e-aa44-47c3-926b-a608b02791d6', 'fr', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Vous ou votre enfant avez-vous un handicap censé durer au moins un an ?', '2026-08-29 00:51:27.030182+00'),
	('86fd8f8e-a0b5-458a-881c-e6591ebfd8b8', 'fr', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Vous ou quelqu''un du ménage avez-vous un handicap durable qui affecte le logement ?', '2026-08-29 00:51:27.030182+00'),
	('b5fc75e2-999c-475c-92fa-d2961312debf', 'fr', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Vous ou un proche avez-vous un handicap ou une maladie de longue durée ou grave ?', '2026-08-29 00:51:27.030182+00'),
	('b67108f0-52b5-4bb2-bc8f-c9dab9ba2fb2', 'fr', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Avez-vous une maladie ou une blessure qui réduit actuellement votre capacité de travail ?', '2026-08-29 00:51:27.030182+00'),
	('23c892e4-cc61-4ad5-a0d3-6e795a1a900e', 'fr', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Avez-vous déjà eu du mal à payer une sortie scolaire, un voyage de classe ou une activité de loisir à laquelle votre enfant est censé participer ?', '2026-08-29 00:51:27.030182+00'),
	('127c4946-dd8a-4217-ac70-5bf1890d067f', 'fr', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Avez-vous du mal à vivre de votre pension et de vos autres revenus ?', '2026-08-29 00:51:27.030182+00'),
	('b8ddf052-3579-4c83-b0f4-b5e57d9dd6e2', 'fr', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Avez-vous obtenu ces dernières années un permis de séjour en Suède, p. ex. comme personne à protéger ou comme membre de famille ?', '2026-08-29 00:51:27.030182+00'),
	('1457d1dd-4ca8-431a-97f7-8c6f8dc072fb', 'fr', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Avez-vous un permis de séjour en Suède comme réfugié ou personne à protéger (ou êtes-vous un proche de quelqu''un qui en a un) ?', '2026-08-29 00:51:27.030182+00'),
	('a20c8912-ae08-4be6-a08a-be146547d1aa', 'fr', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Avez-vous atteint l''âge de référence de la retraite (67 ans en 2026) ?', '2026-08-29 00:51:27.030182+00'),
	('aeb6f22c-0edc-4422-8232-80b571dcd276', 'fr', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Votre organisation a-t-elle un OID (Organisation ID) enregistré dans l''Organisation Registration System de l''UE ?', '2026-08-29 00:51:27.030182+00');
INSERT INTO public.kb_translations VALUES
	('34c89dc3-c7e8-4314-9435-b673b0e94bc0', 'fr', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Le handicap a-t-il entraîné des surcoûts — p. ex. aides techniques, déplacements, régime particulier ou usure ?', '2026-08-29 00:51:27.030182+00'),
	('699e195c-1469-44e4-b7b1-187f71bb457b', 'fr', 'Har föreningen antagna stadgar och en vald styrelse?', 'L''association a-t-elle des statuts adoptés et un conseil d''administration élu ?', '2026-08-29 00:51:27.030182+00'),
	('efda8258-9f0a-40c8-90ae-43a52e94e793', 'fr', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'L''association a-t-elle une structure démocratique (statuts, assemblée annuelle, conseil) ?', '2026-08-29 00:51:27.030182+00'),
	('ebf1e75f-53e0-431d-86be-ea3f7ab690fc', 'fr', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'L''association mène-t-elle des activités régulières pour les enfants ou les jeunes ?', '2026-08-29 00:51:27.030182+00'),
	('630cb726-788b-4e98-97a7-7af62c5d29b7', 'fr', 'Har företaget mellan cirka 2 och 49 anställda?', 'L''entreprise compte-t-elle entre environ 2 et 49 salariés ?', '2026-08-29 00:51:27.030182+00'),
	('c79e8ce2-9f53-42df-8d01-3869bc5d57d2', 'fr', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Le ménage a-t-il du mal à couvrir les dépenses de nourriture, de logement et de première nécessité ?', '2026-08-29 00:51:27.030182+00'),
	('65831e9a-6f5f-4d1c-a4ab-32f61fd3c3ed', 'fr', 'Har lösningen internationell potential?', 'La solution a-t-elle un potentiel international ?', '2026-08-29 00:51:27.030182+00'),
	('9c8c823d-dda6-4597-b26a-f36162856f70', 'fr', 'Har ni en partnergrupp i ett annat land?', 'Avez-vous un groupe partenaire dans un autre pays ?', '2026-08-29 00:51:27.030182+00'),
	('3eedf4c2-c40f-4887-bc41-7e2bba332d0b', 'fr', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Avez-vous une organisation partenaire dans un autre pays européen ?', '2026-08-29 00:51:27.030182+00'),
	('670ee609-2b89-4410-8e67-e679aea5354b', 'fr', 'Har ni partner i minst tre olika europeiska länder?', 'Avez-vous des partenaires dans au moins trois pays européens différents ?', '2026-08-29 00:51:27.030182+00'),
	('bf63162b-f483-44c3-8ac5-3050e03289bb', 'fr', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Votre siège ou votre activité principale se trouve-t-il dans la région où vous déposez la demande ?', '2026-08-29 00:51:27.030182+00'),
	('be049ecd-ba9e-4cfd-97f1-d55baccfcb43', 'fr', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'L''un de vos enfants a-t-il un handicap qui fait qu''il a besoin de plus de soins ou de surveillance que les autres enfants du même âge ?', '2026-08-29 00:51:27.030182+00'),
	('51817ac8-5408-4ee6-af04-0c765473b9ab', 'fr', 'Har organisationen en demokratisk uppbyggnad?', 'L''organisation a-t-elle une structure démocratique ?', '2026-08-29 00:51:27.030182+00'),
	('977e15a4-6f6b-41e3-b2c0-4a8db721b9e6', 'fr', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'L''organisation a-t-elle un Quality Label (label de qualité) ?', '2026-08-29 00:51:27.030182+00'),
	('08524fe0-20e0-4d7d-8080-458e7c45de41', 'fr', 'Har organisationen ett 90-konto?', 'L''organisation a-t-elle un 90-konto ?', '2026-08-29 00:51:27.030182+00'),
	('6f06ecb6-2d21-41ff-ba43-6621564bcd18', 'fr', 'Har organisationen ett OID (Organisation ID)?', 'L''organisation a-t-elle un OID (Organisation ID) ?', '2026-08-29 00:51:27.030182+00'),
	('818dfa98-f84a-4ed9-8aee-8f76f48b7ea7', 'fr', 'Har organisationen ett OID?', 'L''organisation a-t-elle un OID ?', '2026-08-29 00:51:27.030182+00'),
	('7ee16401-00e1-4a2a-a83c-6bdeed026c17', 'fr', 'Har organisationen medlemsföreningar i flera län?', 'L''organisation a-t-elle des associations membres dans plusieurs départements ?', '2026-08-29 00:51:27.030182+00'),
	('5cf990e5-3e39-4656-a279-9fd5b03c5ac8', 'fr', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'L''organisation a-t-elle des finances saines et une structure démocratique ?', '2026-08-29 00:51:27.030182+00'),
	('4af2859a-d1de-4704-b91c-0941815f2554', 'fr', 'Har projektet en partner i ett annat land?', 'Le projet a-t-il un partenaire dans un autre pays ?', '2026-08-29 00:51:27.030182+00'),
	('93b8784e-c39b-4bba-9ce9-f938a7bd01a5', 'fr', 'Har projektledaren doktorsexamen?', 'Le responsable du projet est-il titulaire d''un doctorat ?', '2026-08-29 00:51:27.030182+00'),
	('f2ce4e91-3484-401c-90f9-5f014c61eb72', 'fr', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Votre commune de résidence doit assurer les trajets quotidiens entre le domicile et le lycée lorsque le trajet fait au moins six kilomètres (p. ex. carte de bus).', '2026-08-29 00:51:27.030182+00'),
	('94a1e8b9-29f0-4c3d-a039-66e006ec8c28', 'fr', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Êtes-vous en train d''acquérir ou d''équiper votre premier logement en Suède ?', '2026-08-29 00:51:27.030182+00'),
	('adcd554c-5cdc-4f65-90f5-2579f61951a5', 'fr', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Le projet comprend-il un voyage ou un échange international ?', '2026-08-29 00:51:27.030182+00'),
	('2f097331-b07a-45f0-bf10-404e866cd60b', 'fr', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Aide à l''investissement pour les entreprises des zones aidées : bâtiments, machines et formation.', '2026-08-29 00:51:27.030182+00'),
	('8ff78e4e-ba18-43a7-b3d0-efef1cce27e0', 'fr', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Aide à l''investissement pour des mesures réduisant les émissions de gaz à effet de serre.', '2026-08-29 00:51:27.030182+00'),
	('0557bb15-99c3-45e8-b54d-cd25468e5180', 'fr', 'Kan projektets miljönytta mätas?', 'Le bénéfice environnemental du projet peut-il être mesuré ?', '2026-08-29 00:51:27.030182+00'),
	('5dac5716-2bb2-4285-9671-77d0b3c55832', 'fr', 'Kan åtgärdens utsläppsminskning beräknas?', 'La réduction d''émissions de la mesure peut-elle être calculée ?', '2026-08-29 00:51:27.030182+00'),
	('4e85b90b-a203-44ff-b8ad-e84141576261', 'fr', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'L''organisation peut-elle avancer les coûts jusqu''au versement de l''aide ?', '2026-08-29 00:51:27.030182+00'),
	('80db60d5-374e-4754-8524-3111421bf98d', 'fr', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Les enseignements seront-ils utilisés dans votre activité en Suède ?', '2026-08-29 00:51:27.030182+00'),
	('97fb8c4b-ba51-4245-9b5d-35572d800d10', 'fr', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'L''investissement ne commencera-t-il qu''après l''envoi de la demande ?', '2026-08-29 00:51:27.030182+00'),
	('f9327187-11a0-4b88-b9c0-f4ccef7869f8', 'fr', 'Kommer projektet människor i ert närområde till del?', 'Le projet profite-t-il aux habitants de votre territoire ?', '2026-08-29 00:51:27.030182+00'),
	('b9d05258-2caa-4275-b2f1-7fbd06f50afa', 'fr', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Le dernier filet de sécurité économique de la commune lorsque les revenus ne couvrent pas le strict nécessaire.', '2026-08-29 00:51:27.030182+00'),
	('000b8006-f610-4784-870e-cc9cee42ceb7', 'fr', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Les aides propres des communes à la vie associative locale : aide à l''activité par séance, aide aux locaux, aide au démarrage et plus.', '2026-08-29 00:51:27.030182+00'),
	('4b8a62c5-f377-4a1b-86ea-8a78275bc922', 'fr', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Transport scolaire gratuit pour les élèves de l''école obligatoire en cas de longue distance, de trajet dangereux ou de handicap — un droit selon la loi scolaire.', '2026-08-29 00:51:27.030182+00'),
	('cff7e1f4-0686-44b6-b99c-aa11c1e13993', 'fr', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Aide légale pour des lunettes ou lentilles pour enfants et jeunes ; montants et démarches varient selon la région — vérifiez le niveau de votre région.', '2026-08-29 00:51:27.030182+00'),
	('26721a48-a3cd-4b75-a552-83521b5d6d6a', 'fr', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Le projet se situe-t-il dans un territoire concerné par l''hydroélectricité ou l''éolien ?', '2026-08-29 00:51:27.030182+00'),
	('447faac3-a09e-4c0d-9e52-886dd44ee7c1', 'fr', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Le projet relève-t-il de l''environnement, des sciences agricoles ou de l''aménagement du territoire ?', '2026-08-29 00:51:27.030182+00'),
	('672fb54a-a93c-4337-9437-1fe4ab259aec', 'fr', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Le lieu d''activité est-il en zone d''aide A ou B (grande partie du Norrland et du Svealand intérieur) ?', '2026-08-29 00:51:27.030182+00'),
	('40e72231-a942-4ebd-b96f-12859db73eda', 'fr', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Prêt pour acheter le strict nécessaire d''un premier foyer en Suède — meubles, ustensiles et autre équipement de base.', '2026-08-29 00:51:27.030182+00'),
	('895702d0-4806-45f5-92c2-99d2adc722c6', 'fr', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Le projet réduit-il les émissions de procédés industriels ou crée-t-il des émissions négatives ?', '2026-08-29 00:51:27.030182+00'),
	('1683279c-c306-411f-8c79-f16b1abb07b5', 'fr', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Allocation mensuelle pour les enfants vivant en Suède, de la naissance à 16 ans.', '2026-08-29 00:51:27.030182+00'),
	('84cbce70-0765-493f-8279-cc1a7cfccb18', 'fr', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket propose des aides aux organisations, entreprises, associations, au secteur public et aux particuliers dans le domaine de l''environnement.', '2026-08-29 00:51:27.030182+00'),
	('8a25d57c-c494-404c-beb1-7c5fe3fbe900', 'fr', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Envisagez-vous de retourner volontairement et définitivement dans votre pays d''origine ?', '2026-08-29 00:51:27.030182+00'),
	('0b1a830e-eae7-4b1c-b5c2-e16af0cb93f3', 'fr', 'Planerar du att starta eget företag?', 'Envisagez-vous de créer votre propre entreprise ?', '2026-08-29 00:51:27.030182+00'),
	('da7a31d9-d531-4a9d-bbb9-f1abd373c515', 'fr', 'Planerar du att studera utomlands?', 'Envisagez-vous d''étudier à l''étranger ?', '2026-08-29 00:51:27.030182+00'),
	('d678c559-485d-4276-b0fb-5ffa465a9c47', 'fr', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Envisagez-vous des études qui renforcent votre position sur le marché du travail ?', '2026-08-29 00:51:27.030182+00'),
	('e110c2d6-ced0-4748-ad15-99169551b6cc', 'fr', 'Planerar ni att anställa?', 'Envisagez-vous d''embaucher ?', '2026-08-29 00:51:27.030182+00'),
	('d3c8f503-ac51-4ca8-95fd-05aaa708ee2d', 'fr', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Envisagez-vous de candidater à un programme de l''UE (p. ex. Horisont Europa) ?', '2026-08-29 00:51:27.030182+00'),
	('7df2a2dd-21c8-433c-bcff-ec358260919a', 'fr', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Aide à la production et au développement de courts métrages et de documentaires.', '2026-08-29 00:51:27.030182+00');
INSERT INTO public.kb_translations VALUES
	('42c70511-debc-4f12-ab5b-c89a503064fc', 'fr', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Aides aux projets de la scène musicale indépendante : concerts, production et développement.', '2026-08-29 00:51:27.030182+00'),
	('a2dc454f-99da-43a6-a914-99985840857d', 'fr', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Aides aux projets d''organisations à but non lucratif travaillant avec et pour les enfants et les jeunes.', '2026-08-29 00:51:27.030182+00'),
	('bce1d3ba-3bf7-471a-9d58-fb83d628422f', 'fr', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Le projet explore-t-il de nouvelles expressions, méthodes ou collaborations artistiques ?', '2026-08-29 00:51:27.030182+00'),
	('92be7c13-a28a-4ea0-933a-040be8ba69bb', 'fr', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'L''échange dure-t-il de 5 à 21 jours (hors jours de voyage) ?', '2026-08-29 00:51:27.030182+00'),
	('bccb1f08-0417-46dc-8c9d-2925cec6910b', 'fr', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Les aides propres des régions aux projets et activités culturels, à côté des aides nationales de Kulturrådet.', '2026-08-29 00:51:27.030182+00'),
	('5475d0b4-862c-493f-b518-196bf17e5667', 'fr', 'Riktar sig projektet till barn eller unga?', 'Le projet s''adresse-t-il aux enfants ou aux jeunes ?', '2026-08-29 00:51:27.030182+00'),
	('aa1e2ee4-d461-4c57-a2c6-bc68c6f6502e', 'fr', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Le projet s''adresse-t-il aux enfants, aux jeunes, aux personnes âgées ou aux personnes handicapées ?', '2026-08-29 00:51:27.030182+00'),
	('eb8773b3-1045-42c2-978c-1cb1fe694467', 'fr', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'L''activité s''adresse-t-elle aux enfants et aux jeunes (7–25 ans) ?', '2026-08-29 00:51:27.030182+00'),
	('06c8a511-15ef-4538-aed0-b9dc43039f31', 'fr', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Manquez-vous d''économies ou de biens pouvant couvrir les dépenses ?', '2026-08-29 00:51:27.030182+00'),
	('2065252d-67a0-4377-b656-4dab556b72f4', 'fr', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Coopérez-vous avec des partenaires dans au moins deux autres pays nordiques ?', '2026-08-29 00:51:27.030182+00'),
	('149c9f96-8781-4a33-b1de-2097a74acebc', 'fr', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Allez-vous faire appel à des compétences externes pour une action de développement ?', '2026-08-29 00:51:27.030182+00'),
	('a3a519b0-440b-4ce0-a768-ad8068d25d7c', 'fr', 'Sker mobiliteten till ett annat europeiskt land?', 'La mobilité se fait-elle vers un autre pays européen ?', '2026-08-29 00:51:27.030182+00'),
	('d37f6053-e147-4367-8c1f-f8facdb88d2e', 'fr', 'Startar du eller tar du över företaget för första gången?', 'Créez-vous ou reprenez-vous l''entreprise pour la première fois ?', '2026-08-29 00:51:27.030182+00'),
	('36e9ea65-4b45-4a3d-aaf5-331f03887f5b', 'fr', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Aide au démarrage pour ceux de 40 ans ou moins qui créent ou reprennent une exploitation agricole.', '2026-08-29 00:51:27.030182+00'),
	('54c95d74-ce62-43a3-943d-b4fd2d56ec7a', 'fr', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Bourse permettant aux artistes professionnels de se concentrer sur leur travail artistique.', '2026-08-29 00:51:27.030182+00'),
	('08d11318-1559-4af6-b61d-eeb454c219bf', 'fr', 'Studerar du, eller planerar du att börja studera?', 'Étudiez-vous, ou prévoyez-vous de commencer des études ?', '2026-08-29 00:51:27.030182+00'),
	('50dc90be-9da2-4017-9b52-29f73757475d', 'fr', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Aide aux études pour les adultes en activité qui veulent se former afin de renforcer leur position sur le marché du travail.', '2026-08-29 00:51:27.030182+00'),
	('f9864a20-09ab-47b5-854a-e9602c0301f6', 'fr', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Aide aux investissements qui renforcent la compétitivité ou réduisent l''impact environnemental des exploitations agricoles.', '2026-08-29 00:51:27.030182+00'),
	('3a1e2958-8203-4c68-a171-03d5a151de71', 'fr', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Aide lorsqu''un enfant vit chez vous et que l''autre parent ne paie pas de pension alimentaire.', '2026-08-29 00:51:27.030182+00'),
	('1523abaa-af10-4be9-b24e-4bad6ff565d4', 'fr', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Aide aux projets des organisations à but non lucratif pour les personnes, l''environnement et un monde meilleur.', '2026-08-29 00:51:27.030182+00'),
	('3169430a-f0fd-451d-a25c-69c04ea57c3b', 'fr', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Aide à la transition de l''industrie vers zéro émission de gaz à effet de serre.', '2026-08-29 00:51:27.030182+00'),
	('c7f8d2dd-15e9-48c7-950e-190b887e5723', 'fr', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Aide aux projets artistiques et culturels à dimension nordique et à coopération transfrontalière.', '2026-08-29 00:51:27.030182+00'),
	('3eaa687a-1402-4cd5-88c5-a434d27a29bc', 'fr', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Aide aux projets culturels novateurs explorant de nouvelles expressions, méthodes ou collaborations artistiques.', '2026-08-29 00:51:27.030182+00'),
	('b94db348-e34d-40f1-b3ef-6592085f85f2', 'fr', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Aide aux projets novateurs pour les enfants, les jeunes, les personnes âgées et les personnes handicapées.', '2026-08-29 00:51:27.030182+00'),
	('2bb424b7-8a21-45ae-91a5-be9781da61dc', 'fr', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Aide aux projets de coopération de la scène musicale indépendante.', '2026-08-29 00:51:27.030182+00'),
	('fd72e796-667f-4331-804a-e8d0e1b2f87b', 'fr', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Aide aux projets de coopération dans la culture et les médias qui renforcent la démocratie et la liberté d''expression à l''international.', '2026-08-29 00:51:27.030182+00'),
	('b33b00f6-717a-4137-9aea-c9e5bdd83208', 'fr', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Le projet vise-t-il à renforcer la démocratie, l''égalité ou la liberté d''expression ?', '2026-08-29 00:51:27.030182+00'),
	('1078f630-1384-4b9d-9286-c05ebe20b9d9', 'fr', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Cherchez-vous un emploi, ou avez-vous reçu une offre d''emploi, dans un autre pays de l''UE ou de l''EEE ?', '2026-08-29 00:51:27.030182+00'),
	('efc953dc-d1b5-442c-922d-d4e0e6ecdd15', 'fr', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Plafond de ce que vous payez en frais de patient sur une période de douze mois — ensuite, frikort (carte de gratuité).', '2026-08-29 00:51:27.030182+00'),
	('b90c9809-07f3-4b78-9b43-109e936c39d3', 'fr', 'Tar du ut hel allmän pension?', 'Percevez-vous la totalité de votre pension publique ?', '2026-08-29 00:51:27.030182+00'),
	('ba06564d-8d27-478f-8f99-f735190f91f4', 'fr', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Complément couvrant une partie du coût du logement pour ceux qui ont une pension et de faibles revenus.', '2026-08-29 00:51:27.030182+00'),
	('5c4467e4-7169-427b-ad3e-b02689fc7b94', 'fr', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Subvention annuelle d''organisation pour les organisations nationales d''enfance et de jeunesse.', '2026-08-29 00:51:27.030182+00'),
	('ace4b0c9-d2cd-405d-8f17-6898a3c4839e', 'fr', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Avoir annuel déduit directement chez le dentiste ou l''hygiéniste dentaire.', '2026-08-29 00:51:27.030182+00'),
	('76ad6e31-2c33-47cf-b036-71db0e00d0ad', 'fr', 'Är bolaget yngre än cirka 5 år?', 'L''entreprise a-t-elle moins d''environ 5 ans ?', '2026-08-29 00:51:27.030182+00'),
	('42f3ad22-16d7-47dc-b002-b924223d0d7b', 'fr', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Les participants à l''échange ont-ils entre 13 et 30 ans ?', '2026-08-29 00:51:27.030182+00'),
	('a10e6853-93e5-46ce-8b27-1b13352b5313', 'fr', 'Är det här ert första EU-projekt?', 'Est-ce votre premier projet UE ?', '2026-08-29 00:51:27.030182+00'),
	('15833dd1-daf0-4efb-8723-5ad67e54c145', 'fr', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Est-il très difficile pour vous (ou votre enfant) de vous déplacer seul ou de voyager en bus et en train ?', '2026-08-29 00:51:27.030182+00'),
	('c5c01a7a-119e-4109-b005-557622639783', 'fr', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Vos revenus sont-ils inférieurs à environ 25 000 kr par mois avant impôt ?', '2026-08-29 00:51:27.030182+00'),
	('a761f9eb-9818-4cbe-a403-37c92f825805', 'fr', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Votre dernière formation achevée est-elle l''école obligatoire, ou un lycée que vous n''avez pas terminé ?', '2026-08-29 00:51:27.030182+00'),
	('208bf2ca-109f-4119-a14d-ffeee6cb8f21', 'fr', 'Är du 40 år eller yngre?', 'Avez-vous 40 ans ou moins ?', '2026-08-29 00:51:27.030182+00'),
	('1f8fa384-66ff-43a6-be1f-7ade24c2f7e2', 'fr', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Êtes-vous inscrit comme demandeur d''emploi auprès d''Arbetsförmedlingen ?', '2026-08-29 00:51:27.030182+00'),
	('437bfa4c-226e-425a-9723-0993b0545951', 'fr', 'Är du mellan 18 och 28 år?', 'Avez-vous entre 18 et 28 ans ?', '2026-08-29 00:51:27.030182+00'),
	('f8b8e829-2e9d-4332-a17b-4deae3b5a46a', 'fr', 'Är du mellan 19 och 29 år?', 'Avez-vous entre 19 et 29 ans ?', '2026-08-29 00:51:27.030182+00'),
	('5b176322-2c1a-47fa-b73e-13a46e95a826', 'fr', 'Är du mellan 25 och 60 år?', 'Avez-vous entre 25 et 60 ans ?', '2026-08-29 00:51:27.030182+00'),
	('68972c68-0b71-469c-9a08-d57839b4d932', 'fr', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Exercez-vous professionnellement dans le secteur culturel (p. ex. danse, musique, arts de la scène) ?', '2026-08-29 00:51:27.030182+00'),
	('560baebb-9722-49cd-8f7f-60d8f9ef3ef8', 'fr', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Êtes-vous un artiste professionnel (ni amateur ni en formation initiale) ?', '2026-08-29 00:51:27.030182+00'),
	('aab060dd-73b4-47a4-86c5-b22603fdf88a', 'fr', 'Är du yrkesverksam konstnär?', 'Êtes-vous un artiste professionnel ?', '2026-08-29 00:51:27.030182+00'),
	('5494751d-cd7b-41f5-9aad-70e7266563a7', 'fr', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Votre solution est-elle substantiellement novatrice par rapport à ce qui existe déjà ?', '2026-08-29 00:51:27.033883+00'),
	('4c34f185-0ae4-43ff-a814-ba8b6e7aa6a7', 'fr', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Le club est-il affilié à une fédération sportive spécialisée au sein de Riksidrottsförbundet ?', '2026-08-29 00:51:27.033883+00'),
	('09c9346d-7af9-4706-a69f-a409072c822d', 'fr', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Les revenus du ménage sont-ils faibles par rapport au coût du logement ?', '2026-08-29 00:51:27.033883+00');
INSERT INTO public.kb_translations VALUES
	('d330f0e4-eeb0-4fa8-acda-518895ddbf4b', 'fr', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Les revenus cumulés du ménage sont-ils inférieurs à environ 25 000 kr par mois avant impôt ?', '2026-08-29 00:51:27.033883+00'),
	('238db874-0675-4d7d-aa6f-867c4f619ff9', 'fr', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'L''action est-elle un projet délimité (pas l''activité ordinaire) ?', '2026-08-29 00:51:27.033883+00'),
	('a9fe0a9e-99f8-4a69-a7cb-471866644bad', 'fr', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Le local est-il ouvert à tous — pas seulement à vos propres membres ?', '2026-08-29 00:51:27.033883+00'),
	('f224582a-f77c-4527-b87a-947f8b3e3c7c', 'fr', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Au moins 60 % des membres ont-ils entre 6 et 25 ans ?', '2026-08-29 00:51:27.033883+00'),
	('01e67227-65ee-4b04-a2ab-066b229e4d14', 'fr', 'Är minst 60 % av medlemmarna under 26 år?', 'Au moins 60 % des membres ont-ils moins de 26 ans ?', '2026-08-29 00:51:27.033883+00'),
	('5396a5e8-6f93-4335-92d1-1d9d2cc1c6f3', 'fr', 'Är målgruppen delaktig i planering och genomförande?', 'Le groupe cible participe-t-il à la planification et à la mise en œuvre ?', '2026-08-29 00:51:27.033883+00'),
	('bdfeae5b-3258-4613-8712-faacbe0e0ff7', 'fr', 'Är ni ett förlag med professionell utgivning?', 'Êtes-vous une maison d''édition avec une publication professionnelle ?', '2026-08-29 00:51:27.033883+00'),
	('538f979f-b37b-46a5-b428-67a5e016109b', 'fr', 'Är ni huvudman för förskoleklass eller grundskola?', 'Êtes-vous responsable d''une classe préscolaire ou d''une école obligatoire ?', '2026-08-29 00:51:27.033883+00'),
	('a135f2c1-bcfc-465a-9b08-f488a5e69dde', 'fr', 'Är organisationen registrerad i EU:s deltagarregister?', 'L''organisation est-elle enregistrée dans le registre des participants de l''UE ?', '2026-08-29 00:51:27.033883+00'),
	('40631f91-1b36-42b0-8b68-071068bb20f8', 'fr', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Le projet est-il un projet de cinéma (court métrage ou documentaire) ?', '2026-08-29 00:51:27.033883+00'),
	('b5e7d1eb-3016-4c84-a1e1-310d5f026fab', 'fr', 'Är projektet ett konst- eller kulturprojekt?', 'Le projet est-il un projet artistique ou culturel ?', '2026-08-29 00:51:27.033883+00'),
	('1550b6c6-79b1-4d0e-9129-15680df7b088', 'fr', 'Är projektet ett kulturprojekt?', 'Le projet est-il un projet culturel ?', '2026-08-29 00:51:27.033883+00'),
	('b206fc2d-e977-4cbf-812e-cf1dae92bebd', 'fr', 'Är projektet ett musikprojekt?', 'Le projet est-il un projet musical ?', '2026-08-29 00:51:27.033883+00'),
	('52986108-fc27-4594-8e9c-c8a793d7f261', 'fr', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Le projet est-il novateur — quelque chose que vous ne faites pas déjà dans votre activité ordinaire ?', '2026-08-29 00:51:27.033883+00'),
	('de286004-ca63-4e5e-ab5d-8a70687da31e', 'fr', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Le projet profite-t-il au territoire dans son ensemble (pas à des particuliers) ?', '2026-08-29 00:51:27.033883+00'),
	('176b6dd3-7840-4fc4-9f44-d17f9f44fd06', 'fr', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Le trajet entre le domicile et le lycée fait-il au moins six kilomètres ?', '2026-08-29 00:51:27.033883+00'),
	('bc0f370e-2277-4930-be3a-28d4decc5f74', 'fr', 'Är verksamheten professionell (inte amatörverksamhet)?', 'L''activité est-elle professionnelle (pas amateur) ?', '2026-08-29 00:51:27.033883+00'),
	('965a9b62-e40e-409b-947f-d5af781933b5', 'fr', 'Är verksamheten professionell?', 'L''activité est-elle professionnelle ?', '2026-08-29 00:51:27.033883+00'),
	('e73bce8c-20d4-4789-9028-403b684ab587', 'fr', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'L''activité relève-t-elle des arts de la scène (danse, théâtre, théâtre musical) ?', '2026-08-29 00:51:27.033883+00'),
	('13199dc2-72a9-42a0-bfa8-96e5ce36f887', 'fr', 'Är volontärerna mellan 18 och 30 år?', 'Les volontaires ont-ils entre 18 et 30 ans ?', '2026-08-29 00:51:27.033883+00'),
	('90b312b8-ae29-45e5-a3ec-e1d21a0744be', 'ar', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'دعم أنشطة للأندية الرياضية التي تقدم أنشطة بقيادة مدربين للأطفال والشباب من 7 إلى 25 عامًا.', '2026-08-29 00:51:27.039515+00'),
	('3bedb107-cc1f-45bd-8fcd-e4c859a187f1', 'ar', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'إضافة تلقائية إلى علاوة الأطفال (barnbidrag) اعتبارًا من الطفل الثاني.', '2026-08-29 00:51:27.039515+00'),
	('0527ecaf-5d19-45a3-9b7f-0834d9fe751f', 'ar', 'Avser ansökan en fysisk investering?', 'هل يتعلق الطلب باستثمار مادي؟', '2026-08-29 00:51:27.039515+00'),
	('7e96c610-97bc-496b-84c6-5e0e30df8f78', 'ar', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'هل يتعلق الطلب برحلة أو تبادل دولي؟', '2026-08-29 00:51:27.039515+00'),
	('d875c668-c0f5-46e1-b0f9-1d85830e7245', 'ar', 'Avser ansökan en investering i byggnader eller maskiner?', 'هل يتعلق الطلب باستثمار في مبانٍ أو آلات؟', '2026-08-29 00:51:27.039515+00'),
	('68a2001f-2e83-40f0-90a9-f4abf6e8bb82', 'ar', 'Avser ansökan en redan utgiven titel?', 'هل يتعلق الطلب بعنوان منشور بالفعل؟', '2026-08-29 00:51:27.039515+00'),
	('29f7ee7e-fe5a-4acb-b8e4-33118c4783a3', 'ar', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'هل يتعلق الطلب بمنشأة زراعية أو بستانية أو لتربية الرنة؟', '2026-08-29 00:51:27.039515+00'),
	('08145bee-f4af-4f4e-89ee-c98759bfb74b', 'ar', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'هل يتعلق الطلب بشراء كتب للمكتبات العامة أو المدرسية؟', '2026-08-29 00:51:27.039515+00'),
	('0630ce72-bc74-4fb9-902a-dafb7d20c28b', 'ar', 'Avser investeringen jordbruksverksamhet?', 'هل يتعلق الاستثمار بنشاط زراعي؟', '2026-08-29 00:51:27.039515+00'),
	('5947d031-e1e8-4eff-a40f-1db23293c33d', 'ar', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'هل يهدف المشروع إلى بناء أو شراء أو ترميم مقر؟', '2026-08-29 00:51:27.039515+00'),
	('166cb1db-9105-4096-91a8-089b01724eb7', 'ar', 'Avser projektet naturvård eller friluftsliv?', 'هل يتعلق المشروع بحماية الطبيعة أو الأنشطة في الهواء الطلق؟', '2026-08-29 00:51:27.039515+00'),
	('c845de33-d715-4cc5-839b-e91a76994f67', 'ar', 'Avser projektet skola eller vuxenutbildning?', 'هل يتعلق المشروع بالمدرسة أو تعليم الكبار؟', '2026-08-29 00:51:27.039515+00'),
	('f2774559-bcd1-49a6-81b7-0227b6cdf6bc', 'ar', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'هل تمتنع عن العمل لرعاية قريب أو البقاء بجانبه لأنه مريض بشدة لدرجة أن المرض يهدد حياته؟', '2026-08-29 00:51:27.039515+00'),
	('24fe0cb4-e4ff-4df6-ae64-0cbfe035561b', 'ar', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'هل تمارس الجمعية نشاطًا منتظمًا في البلدية؟', '2026-08-29 00:51:27.039515+00'),
	('76766a96-ec2a-48cf-8a69-b80e05d51c44', 'ar', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'هل تقدّر أن قدرتك على العمل منخفضة لمدة سنة على الأقل بسبب مرض أو إعاقة؟', '2026-08-29 00:51:27.039515+00'),
	('e8e77cea-02df-4541-a046-9e9111131ebe', 'ar', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'دعم خاضع لتقييم الحاجة لمن لديه معاش منخفض أو لا معاش له ويحتاج إلى مساعدة للوصول إلى مستوى معيشة معقول.', '2026-08-29 00:51:27.039515+00'),
	('33a8a8bf-8a5d-44b9-8407-03040b0dc2f9', 'ar', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'هل يحتاج الطفل إلى السكن في بلدة الدراسة (إقامة) لأن الطريق طويل جدًا؟', '2026-08-29 00:51:27.039515+00'),
	('9a6ad940-2802-48b0-997c-614a56aa772a', 'ar', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'هل يحتاج المسكن إلى تكييف (مثل منحدر أو فاتح أبواب أو حمّام)؟', '2026-08-29 00:51:27.039515+00'),
	('772d13c0-478a-4aff-a3fa-7af83ab5a748', 'ar', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'هل يحتاج أحد أطفالك بين 8 و19 عامًا إلى نظارات أو عدسات؟', '2026-08-29 00:51:27.039515+00'),
	('fbcf6cfa-b4ca-4d98-914c-6bb91e94ae56', 'ar', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'هل لا يدفع الوالد الآخر شيئًا أو يدفع أقل من النفقة الكاملة؟', '2026-08-29 00:51:27.039515+00'),
	('bd351ed6-1daf-4c3a-b5f0-816fec39c105', 'ar', 'Betalar du hyra eller andra boendekostnader?', 'هل تدفع إيجارًا أو تكاليف سكن أخرى؟', '2026-08-29 00:51:27.039515+00'),
	('3b48a0c0-e874-4d3f-bd61-3c1667b39085', 'ar', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'إعانة لتكييف المسكن عند وجود إعاقة — مثل المنحدرات أو فاتحات الأبواب أو تكييف الحمّام.', '2026-08-29 00:51:27.039515+00'),
	('fc8bcc4d-adb4-4d24-9ea0-1e2fc4765b13', 'ar', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'إعانات لبناء أو شراء أو ترميم قاعات الاجتماعات العامة.', '2026-08-29 00:51:27.039515+00'),
	('3499fadf-463a-404e-9bc1-61fa26defc74', 'ar', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'إعانة لشراء سيارة أو تكييفها عندما تجعل إعاقة دائمة التنقل أو استخدام المواصلات العامة صعبًا جدًا.', '2026-08-29 00:51:27.039515+00'),
	('13cfa4e4-9e89-4406-85b5-9524edd0600c', 'ar', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'إعانات للسفر والتبادل الدولي للعاملين المحترفين في المجال الثقافي.', '2026-08-29 00:51:27.039515+00'),
	('34b14889-9346-4248-be52-977b199c0937', 'ar', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'إعانات لتبادلات الفنانين المحترفين الدولية وسفرهم وإقاماتهم للعمل.', '2026-08-29 00:51:27.039515+00'),
	('805cbb24-b5ae-4b7e-821d-b652d4f079ab', 'ar', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'إعانة وقرض اختياري للدراسة في المرحلة الثانوية أو ما بعد الثانوية.', '2026-08-29 00:51:27.039515+00'),
	('3aac2c33-cd4f-403b-8e05-b3e2d957f7fb', 'ar', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'إعانات وقروض للدراسة في الخارج، مع قروض إضافية لتغطية مثل رسوم الدراسة والسفر.', '2026-08-29 00:51:27.039515+00'),
	('15353071-555f-4764-9675-d68aac1fa3e1', 'ar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'إعانة تساعد الجهات السويدية على إعداد طلبات لبرامج الاتحاد الأوروبي مثل Horisont Europa.', '2026-08-29 00:51:27.039515+00'),
	('84f364bc-866b-496f-bdd6-3c1e2860cbb4', 'ar', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'إعانة لأصحاب العمل الذين يوظفون أشخاصًا ذوي قدرة منخفضة على العمل.', '2026-08-29 00:51:27.039515+00');
INSERT INTO public.kb_translations VALUES
	('b2c2be7d-a4fc-41ad-8193-c32bcafa41bf', 'ar', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'إعانة للسكن ورحلات العودة إلى المنزل عندما يضطر طالب ثانوي للسكن في بلدة الدراسة بسبب طول الطريق.', '2026-08-29 00:51:27.039515+00'),
	('0bfcc501-6edb-41c7-925c-688824a1cbc9', 'ar', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'إعانات لعمل المنظمات غير الربحية في الحفاظ على التراث الثقافي واستخدامه وتطويره.', '2026-08-29 00:51:27.039515+00'),
	('b1065dc6-de74-4368-8bff-7e63c4d9c5cd', 'ar', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'إعانات لمشاريع حماية الطبيعة البلدية والمحلية، بما في ذلك الأراضي الرطبة والأنشطة في الهواء الطلق.', '2026-08-29 00:51:27.039515+00'),
	('f9982c7c-4c83-43d3-8aa2-d63bc9544094', 'ar', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'إعانات للبلديات لشراء الكتب للمكتبات العامة والمدرسية.', '2026-08-29 00:51:27.039515+00'),
	('034975a1-84ce-4a1f-9b10-21ff87839dac', 'ar', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'إعانات للجهات المسؤولة عن المدارس ليلتقي تلاميذ المرحلة الأساسية بالثقافة الاحترافية.', '2026-08-29 00:51:27.039515+00'),
	('eb46be9e-34cb-4a59-80e1-254fe1d5f5cb', 'ar', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'إعانة لما يحتاجه طفلك ولا تكفي ميزانية الأسرة لتغطيته: أنشطة ترفيهية، ملابس، رحلات مدرسية، نظارات، أنشطة العطل وغيرها.', '2026-08-29 00:51:27.039515+00'),
	('2d8800bc-8995-47ce-a26a-634ebe43940d', 'ar', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'إعانات من صناديق مثل Världens Barn وMusikhjälpen وVictoriafonden — تطلبها منظمات سويدية غير ربحية لديها 90-konto.', '2026-08-29 00:51:27.039515+00'),
	('25c9b1d7-dde7-4cc1-bc6d-dd3d6d8841e0', 'ar', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'إعانات من أموال الطاقة الكهرومائية وطاقة الرياح لمشاريع تنمّي المنطقة.', '2026-08-29 00:51:27.039515+00'),
	('8155f7b2-83ad-4b84-ab4c-c0e938d3b7b6', 'ar', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'إعانة دون جزء قرضي للعاطلين عن العمل بين 25 و60 عامًا ذوي التعليم القصير الذين يحتاجون إلى الدراسة في مستوى المدرسة الأساسية أو الثانوية.', '2026-08-29 00:51:27.039515+00'),
	('f367e370-0264-4367-a4ba-48032dcb8424', 'ar', 'Bidrar projektet till energiomställningen?', 'هل يساهم المشروع في التحول الطاقي؟', '2026-08-29 00:51:27.039515+00'),
	('a83db50c-0a64-4432-a0c2-dac6fac954c6', 'ar', 'Bor du och barnets andra förälder på skilda håll?', 'هل تعيش أنت والوالد الآخر للطفل منفصلين؟', '2026-08-29 00:51:27.039515+00'),
	('c11d8f03-b4be-45f2-b066-326e2a7ec812', 'ar', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'شيكات للشركات الصغيرة لجلب خبرات خارجية في التدويل أو الرقمنة.', '2026-08-29 00:51:27.039515+00'),
	('a4651b10-b520-47f6-8e73-67f1c6c1490a', 'ar', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'هل تشارك في برنامج لدى Arbetsförmedlingen (مثل jobb- och utvecklingsgarantin)؟', '2026-08-29 00:51:27.039515+00'),
	('79638254-49c9-493b-9095-28c30d31a0c1', 'ar', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'دعم لاحق لدور النشر مقابل نشر أدب ذي جودة.', '2026-08-29 00:51:27.039515+00'),
	('8150a824-01aa-4e29-a069-48bade7298cb', 'ar', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'دعم اقتصادي لمن لديه تصريح إقامة مرتبط بالحماية ويرغب طوعًا في العودة نهائيًا إلى بلده الأصلي.', '2026-08-29 00:51:27.039515+00'),
	('7c1b2a4f-a038-4410-80f3-430c6e58aaef', 'ar', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'دعم اقتصادي لأصحاب العمل الذين يوظفون شخصًا غاب طويلًا عن الحياة العملية.', '2026-08-29 00:51:27.039515+00'),
	('bb9cfe96-ab9c-4979-8d9c-326e33deda44', 'ar', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'دعم اقتصادي خلال مرحلة البدء للباحثين عن عمل الذين يؤسسون شركتهم الخاصة.', '2026-08-29 00:51:27.039515+00'),
	('19da627d-597e-4391-a2fd-1ee89fa35d3a', 'ar', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'تفتح Energimyndigheten باستمرار دعوات في أبحاث الطاقة والابتكار وكفاءة الطاقة.', '2026-08-29 00:51:27.039515+00'),
	('d568e513-f8f2-4a27-9670-7e4ba26b5e6a', 'ar', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'تعويض عن التغيب عن العمل أو الدراسة لرعاية طفل.', '2026-08-29 00:51:27.039515+00'),
	('e01cf9cb-5ebf-4619-8863-14030be8becb', 'ar', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'تعويض لمن هو جديد في السويد ويشارك في برنامج التأسيس لدى Arbetsförmedlingen؛ تدفعه Försäkringskassan.', '2026-08-29 00:51:27.039515+00'),
	('e90fffb4-eee6-4236-88ce-e407967c568d', 'ar', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'تعويض يغطي جزءًا من تكلفة السكن للشباب دون أطفال ذوي الدخل المنخفض.', '2026-08-29 00:51:27.039515+00'),
	('3feb0e44-2d62-498f-89d2-3f982f91bd40', 'ar', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'تعويض عن التكاليف الإضافية التي تسببها إعاقة دائمة — للبالغين أو لأهل الأطفال ذوي الإعاقة.', '2026-08-29 00:51:27.039515+00'),
	('412e478b-1448-4e67-9b18-be0cf1478977', 'ar', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'تعويض للشباب (19–29 عامًا) الذين لا يستطيعون العمل بدوام كامل لمدة سنة على الأقل بسبب مرض أو إعاقة.', '2026-08-29 00:51:27.039515+00'),
	('d6bd654e-ca76-4004-b44d-a11acf94a7ea', 'ar', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'تعويض عندما تكون القدرة على العمل منخفضة بشكل دائم — ما كان يسمى سابقًا förtidspension (التقاعد المبكر).', '2026-08-29 00:51:27.039515+00'),
	('7d601ae7-3911-4004-907b-dc47ebc84c68', 'ar', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'تعويض عندما تمتنع عن العمل لتكون بجانب قريب مريض بشدة.', '2026-08-29 00:51:27.039515+00'),
	('ebbc0edd-494d-47bb-a7a3-0ac8b63320e1', 'ar', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'تعويض عند مشاركتك في برنامج لسياسة سوق العمل لدى Arbetsförmedlingen.', '2026-08-29 00:51:27.039515+00'),
	('6e33d8bd-958d-4289-8f69-1ec74202e21d', 'ar', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'تعويض عندما لا تستطيع العمل كالمعتاد بسبب المرض.', '2026-08-29 00:51:27.039515+00'),
	('34d039dc-e43e-49c5-88bc-1b0918c53041', 'ar', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'تعويض عندما تبقى في المنزل عن العمل لرعاية طفل مريض.', '2026-08-29 00:51:27.039515+00'),
	('92c58238-cbce-42a6-911a-5174dc33cc94', 'ar', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'تعويض يغطي جزءًا من تكلفة السكن للأسر التي لديها أطفال ودخل أقل.', '2026-08-29 00:51:27.039515+00'),
	('42bf2307-18b1-4627-a6f3-f8cf7abd66ec', 'ar', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'تعويض للوالدين الذين يحتاج أطفالهم بسبب الإعاقة إلى رعاية وإشراف أكثر من أطفال في نفس العمر.', '2026-08-29 00:51:27.039515+00'),
	('fb1f3961-6aca-4a8b-a813-4433aaffd7ac', 'ar', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'تعويض عند البطالة — على أساس الدخل للأعضاء، ومبلغ أساسي لغيرهم.', '2026-08-29 00:51:27.039515+00'),
	('2e4c673b-9bdc-4249-9ef0-6b3f6b89c82b', 'ar', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'نحو خمسين مؤسسة لبنوك الادخار تمنح إعانات لمشاريع محلية في الرياضة والثقافة والتعليم وتنمية المجتمع — في منطقة نشاط البنك.', '2026-08-29 00:51:27.039515+00'),
	('d2a39ef9-c415-4862-9d53-1e96352f894f', 'ar', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'دعم مشاريع ممول من الاتحاد الأوروبي يُطلب لدى منطقة Leader المحلية — للجمعيات والشركات والبلديات التي تنمّي الريف.', '2026-08-29 00:51:27.039515+00'),
	('60909bd6-e8fc-489c-854f-c192eb721db9', 'ar', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'دعم ممول من الاتحاد الأوروبي للباحثين عن عمل الذين يقبلون وظيفة في بلد آخر من الاتحاد الأوروبي/المنطقة الاقتصادية الأوروبية: تعويض عن سفر المقابلة وتكاليف الانتقال ودورة لغة.', '2026-08-29 00:51:27.039515+00'),
	('c640236a-7f57-469e-a7f0-6c50f47b4869', 'ar', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'أموال من الصندوق الاجتماعي الأوروبي لمشاريع تعزز الكفاءات والتحول والإدماج في سوق العمل.', '2026-08-29 00:51:27.039515+00'),
	('4db9aa92-239d-4cc7-a043-be477737fc1f', 'ar', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'دعم من الاتحاد الأوروبي لتبادلات جماعية للشباب من 13 إلى 30 عامًا، لمدة 5 إلى 21 يومًا دون أيام السفر.', '2026-08-29 00:51:27.039515+00'),
	('e2c1d3dc-2cc5-4e31-b3d8-1125e14555c7', 'ar', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'دعم من الاتحاد الأوروبي لمشاريع تعاون المنظمات الثقافية مع شركاء في عدة بلدان أوروبية.', '2026-08-29 00:51:27.039515+00'),
	('18598015-3250-41f4-a34d-dcec73077b50', 'ar', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'دعم من الاتحاد الأوروبي للمنظمات التي تستقبل أو ترسل متطوعين شبابًا من 18 إلى 30 عامًا.', '2026-08-29 00:51:27.039515+00'),
	('9f49e5c8-2921-484c-93e5-5b8da311e2ea', 'ar', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'دعم من الاتحاد الأوروبي لتنقل العاملين والتلاميذ في المدرسة وتعليم الكبار.', '2026-08-29 00:51:27.039515+00'),
	('45d1e0e9-1d3f-432b-8bda-7410f88eb923', 'ar', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'دعم من الاتحاد الأوروبي بمبالغ مقطوعة لأول مشاريع تعاون أوروبية للمنظمات الصغيرة.', '2026-08-29 00:51:27.039515+00'),
	('042f7896-2c44-4a48-97e5-962a0c9c1fe2', 'ar', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تمويل للشركات الفتية التي تطور منتجات أو خدمات مبتكرة ذات إمكانات دولية.', '2026-08-29 00:51:27.039515+00'),
	('f2886e98-3e4b-4aad-bae8-1555272c33d4', 'ar', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'هل يوجد بنك ادخار (وبالتالي مؤسسة بنك ادخار) حيث تمارسون نشاطكم؟', '2026-08-29 00:51:27.039515+00'),
	('3333f6ac-eefe-433c-9c16-8d505749b159', 'prs', 'Kan projektets miljönytta mätas?', 'آیا فایده محیط‌زیستی پروژه قابل اندازه‌گیری است؟', '2026-08-29 00:51:27.058206+00'),
	('365a380b-24df-4811-b946-312779b087b6', 'ar', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'إعانات تشغيل متعددة السنوات للفرق المستقلة المحترفة في الرقص والمسرح والمسرح الموسيقي.', '2026-08-29 00:51:27.039515+00'),
	('adf99f96-e2d5-42d1-902d-c90d1184faab', 'ar', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'إعانات بحثية في مجالات Forte: الصحة والحياة العملية والرفاه. يطلبها باحثون حاصلون على الدكتوراه في الجامعات السويدية.', '2026-08-29 00:51:27.039515+00'),
	('7e9d7d0d-a739-47ef-b4ae-f512b80300ba', 'ar', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'تمويل بحثي للبحث الأساسي الحر في جميع المجالات العلمية.', '2026-08-29 00:51:27.039515+00'),
	('86f8b7de-eb45-47b1-9a86-93dfd14b8be3', 'ar', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'تمويل بحثي في البيئة والعلوم الزراعية والتخطيط العمراني.', '2026-08-29 00:51:27.039515+00'),
	('bb7bf800-a83e-4594-944c-57405af1ceb6', 'ar', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'هل تفكر في الانتقال إلى الخارج (للعمل أو الدراسة أو العودة إلى الوطن)؟', '2026-08-29 00:51:27.039515+00'),
	('74f2efbd-9086-47a9-9537-10d9469e5f08', 'ar', 'Genomförs insatserna av professionella kulturaktörer?', 'هل ينفذ الأنشطة فاعلون ثقافيون محترفون؟', '2026-08-29 00:51:27.039515+00'),
	('ea5c0bc6-3ecb-4fd5-9909-2f0e75934e80', 'ar', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'هل يُنفذ المشروع في الريف أو في بلدة صغيرة؟', '2026-08-29 00:51:27.039515+00');
INSERT INTO public.kb_translations VALUES
	('6ffa5a3d-5ccd-41ce-a993-254e167eb921', 'ar', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حماية أساسية لمن كان دخله من العمل قليلًا أو معدومًا خلال حياته.', '2026-08-29 00:51:27.039515+00'),
	('f1e09254-7224-4e1f-947a-b5dceed55f28', 'ar', 'Går något av dina barn i grundskolan?', 'هل يذهب أحد أطفالك إلى المدرسة الأساسية؟', '2026-08-29 00:51:27.039515+00'),
	('007dfc64-f88f-4f5e-88b2-91cef1ab21b6', 'ar', 'Går något av dina barn på gymnasiet?', 'هل يدرس أحد أطفالك في الثانوية؟', '2026-08-29 00:51:27.039515+00'),
	('3603cf2c-82ec-4860-9fcb-27f17e5e3587', 'ar', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'هل يتعلق التوظيف بشخص ذي قدرة منخفضة على العمل؟', '2026-08-29 00:51:27.039515+00'),
	('e23f6ef2-7fea-4f18-86c6-24b91e11bb5e', 'ar', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'هل يتعلق التوظيف بشخص كان عاطلًا طويلًا أو جديدًا في السويد؟', '2026-08-29 00:51:27.039515+00'),
	('0c3c3115-6bb8-4389-b6bd-bc696c34ea28', 'ar', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'هل يدور المشروع حول الحفاظ على التراث الثقافي أو إتاحته؟', '2026-08-29 00:51:27.039515+00'),
	('5d942258-6055-4c51-8e61-9312b39f2f54', 'ar', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'هل يدور المشروع حول الطاقة أو كفاءة الطاقة أو الابتكار المتعلق بالطاقة؟', '2026-08-29 00:51:27.039515+00'),
	('ed2feda6-84f8-4ed8-b108-6a1093abf61b', 'ar', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'هل يدور المشروع حول الصحة أو الحياة العملية أو الرفاه؟', '2026-08-29 00:51:27.039515+00'),
	('fa3c7a3b-7e47-4177-8f1f-a6188dd9c78d', 'ar', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'هل يدور المشروع حول تطوير الكفاءات أو تدابير سوق العمل؟', '2026-08-29 00:51:27.039515+00'),
	('9eb42df1-3029-4f0d-991b-84640fc0ba19', 'ar', 'Handlar projektet om miljö- eller klimatåtgärder?', 'هل يدور المشروع حول تدابير بيئية أو مناخية؟', '2026-08-29 00:51:27.039515+00'),
	('2f391c9b-9dc6-49ac-8160-ae949dcb97eb', 'ar', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'هل طريق الطفل إلى المدرسة طويل أو خطر بسبب حركة المرور أو صعب لأسباب أخرى؟', '2026-08-29 00:51:27.039515+00'),
	('fa3a2bd8-f1a4-4b66-b2cb-b173a32397dc', 'ar', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'هل عملت 16 ساعة أسبوعيًا على الأقل لمدة إجمالية لا تقل عن 8 سنوات؟', '2026-08-29 00:51:27.039515+00'),
	('7ff904a1-77fd-4b10-ba44-0344019cb947', 'ar', 'Har du barn som bor hos dig, helt eller växelvis?', 'هل لديك أطفال يعيشون معك، كليًا أو بالتناوب؟', '2026-08-29 00:51:27.039515+00'),
	('40a748db-0e08-42b1-ae00-b67db552a8f1', 'ar', 'Har du barn som bor hos dig?', 'هل لديك أطفال يعيشون معك؟', '2026-08-29 00:51:27.039515+00'),
	('d0139743-5cb8-4a94-82e2-dd0a5d558720', 'ar', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'هل لديك أو لدى طفلك إعاقة يُتوقع أن تستمر سنة على الأقل؟', '2026-08-29 00:51:27.039515+00'),
	('2ad913b3-d273-4170-b5f4-3b93d0837801', 'ar', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'هل لديك أو لدى أحد في الأسرة إعاقة دائمة تؤثر على السكن؟', '2026-08-29 00:51:27.039515+00'),
	('be823291-2847-47e2-9766-f85927224d45', 'ar', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'هل لديك أو لدى قريب مقرب إعاقة أو مرض طويل الأمد أو خطير؟', '2026-08-29 00:51:27.039515+00'),
	('b5740d48-ebee-43ad-8fed-f7fe0ca12942', 'ar', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'هل لديك مرض أو إصابة تحدّ حاليًا من قدرتك على العمل؟', '2026-08-29 00:51:27.039515+00'),
	('d1fdcd84-dec2-4cc2-96dd-36cc42d88aaa', 'ar', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'هل واجهت يومًا صعوبة في دفع تكلفة رحلة مدرسية أو رحلة صف أو نشاط ترفيهي يُتوقع أن يشارك فيه طفلك؟', '2026-08-29 00:51:27.039515+00'),
	('ebacaa66-8649-4193-b118-8d67d82f6b0b', 'ar', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'هل يصعب عليك تدبير أمورك بمعاشك ودخلك الآخر؟', '2026-08-29 00:51:27.039515+00'),
	('b6eba7ff-6640-4f7f-9481-eca898f5973a', 'ar', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'هل حصلت في السنوات الأخيرة على تصريح إقامة في السويد، مثلًا كشخص بحاجة إلى حماية أو كقريب؟', '2026-08-29 00:51:27.039515+00'),
	('e2442b22-dae5-40e6-a032-26226a27d558', 'ar', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'هل لديك تصريح إقامة في السويد كلاجئ أو شخص بحاجة إلى حماية (أو أنت قريب مقرب لشخص لديه ذلك)؟', '2026-08-29 00:51:27.039515+00'),
	('dd6a3edf-282e-471c-beaa-574eb650a9f3', 'ar', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'هل بلغت السن المرجعية للتقاعد (67 عامًا في 2026)؟', '2026-08-29 00:51:27.039515+00'),
	('90fde75a-73e1-4e8b-b751-b29aa09a072d', 'ar', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'هل لدى منظمتكم OID (Organisation ID) مسجل في Organisation Registration System التابع للاتحاد الأوروبي؟', '2026-08-29 00:51:27.039515+00'),
	('a2656737-e008-4052-8a7e-bda60b3523a6', 'ar', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'هل تسببت الإعاقة في تكاليف إضافية — مثل الوسائل المساعدة أو التنقل أو نظام غذائي خاص أو الاستهلاك؟', '2026-08-29 00:51:27.039515+00'),
	('ee21458d-3f81-4d92-a45a-7738179f3dd1', 'ar', 'Har föreningen antagna stadgar och en vald styrelse?', 'هل لدى الجمعية نظام أساسي معتمد ومجلس إدارة منتخب؟', '2026-08-29 00:51:27.039515+00'),
	('260c6c0b-7275-4a26-a076-42c152a84602', 'ar', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'هل لدى الجمعية بنية ديمقراطية (نظام أساسي، اجتماع سنوي، مجلس إدارة)؟', '2026-08-29 00:51:27.039515+00'),
	('515d1df6-1c71-4832-b2a8-62fe78eca6c2', 'ar', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'هل تمارس الجمعية نشاطًا منتظمًا للأطفال أو الشباب؟', '2026-08-29 00:51:27.039515+00'),
	('1d3a185a-3647-46b4-9e93-356181ad2273', 'ar', 'Har företaget mellan cirka 2 och 49 anställda?', 'هل لدى الشركة ما بين حوالي 2 و49 موظفًا؟', '2026-08-29 00:51:27.039515+00'),
	('d378084a-2086-4b4c-9542-732de6b15897', 'ar', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'هل تجد الأسرة صعوبة في تغطية تكاليف الطعام والسكن وأبسط الضروريات؟', '2026-08-29 00:51:27.039515+00'),
	('34c19688-8622-472b-b8ad-fb366a989411', 'ar', 'Har lösningen internationell potential?', 'هل للحل إمكانات دولية؟', '2026-08-29 00:51:27.039515+00'),
	('5506d610-9768-4c1c-8d4b-cf3190437eb1', 'ar', 'Har ni en partnergrupp i ett annat land?', 'هل لديكم مجموعة شريكة في بلد آخر؟', '2026-08-29 00:51:27.039515+00'),
	('95da5530-3dcc-4d16-9e8d-8e2e4c237be8', 'ar', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'هل لديكم منظمة شريكة في بلد أوروبي آخر؟', '2026-08-29 00:51:27.039515+00'),
	('89b9551a-46f4-497d-8d6b-f66e6884c98e', 'ar', 'Har ni partner i minst tre olika europeiska länder?', 'هل لديكم شركاء في ثلاثة بلدان أوروبية مختلفة على الأقل؟', '2026-08-29 00:51:27.039515+00'),
	('b3901d5f-edff-49f2-8be1-926d85dabacb', 'ar', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'هل مقركم أو نشاطكم الرئيسي في المنطقة التي تقدمون فيها الطلب؟', '2026-08-29 00:51:27.039515+00'),
	('5ede5888-5994-4911-a0ee-277316cd114f', 'ar', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'هل لدى أحد أطفالك إعاقة تجعله يحتاج إلى رعاية أو إشراف أكثر من أطفال آخرين في نفس العمر؟', '2026-08-29 00:51:27.039515+00'),
	('f6d41d26-ff95-4d9f-bdac-4c5c85123ed5', 'ar', 'Har organisationen en demokratisk uppbyggnad?', 'هل لدى المنظمة بنية ديمقراطية؟', '2026-08-29 00:51:27.039515+00'),
	('e69bb393-1741-4925-8e04-0e582f731527', 'ar', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'هل لدى المنظمة Quality Label (علامة الجودة)؟', '2026-08-29 00:51:27.039515+00'),
	('ddd50c7f-44dc-4c4b-8ad1-90264a78bcc7', 'ar', 'Har organisationen ett 90-konto?', 'هل لدى المنظمة 90-konto؟', '2026-08-29 00:51:27.039515+00'),
	('09229f0b-2519-465c-b215-0fcb9e6ec547', 'ar', 'Har organisationen ett OID (Organisation ID)?', 'هل لدى المنظمة OID (Organisation ID)؟', '2026-08-29 00:51:27.039515+00'),
	('19ce33c8-a2da-44e2-b990-e0416b7eb124', 'ar', 'Har organisationen ett OID?', 'هل لدى المنظمة OID؟', '2026-08-29 00:51:27.039515+00'),
	('520aeedc-b46c-41a4-b33d-44f8f10866c3', 'ar', 'Har organisationen medlemsföreningar i flera län?', 'هل لدى المنظمة جمعيات أعضاء في عدة محافظات؟', '2026-08-29 00:51:27.039515+00'),
	('ad0008b1-4868-46a3-9027-3c2b46e5e972', 'ar', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'هل لدى المنظمة مالية منظمة وبنية ديمقراطية؟', '2026-08-29 00:51:27.039515+00'),
	('c114d5fa-0b63-4028-b707-8dbb870bbcb7', 'ar', 'Har projektet en partner i ett annat land?', 'هل للمشروع شريك في بلد آخر؟', '2026-08-29 00:51:27.039515+00'),
	('6185c91b-51da-4393-a963-f9a9fde760b7', 'ar', 'Har projektledaren doktorsexamen?', 'هل قائد المشروع حاصل على الدكتوراه؟', '2026-08-29 00:51:27.039515+00'),
	('a71a11a4-46c8-46ff-ac71-de2b74f1589c', 'ar', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'على بلدية السكن توفير التنقل اليومي بين المنزل والمدرسة الثانوية عندما يبلغ الطريق ستة كيلومترات على الأقل (مثل بطاقة حافلة).', '2026-08-29 00:51:27.039515+00'),
	('89d2a1f8-c059-4fe8-99b2-9f04a786c8c7', 'ar', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'هل أنت بصدد الحصول على أول مسكن خاص بك في السويد أو تجهيزه؟', '2026-08-29 00:51:27.039515+00'),
	('c29a9fc8-3a7d-447a-8c93-60d1422c7313', 'ar', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'هل يتضمن المشروع رحلة أو تبادلًا دوليًا؟', '2026-08-29 00:51:27.039515+00'),
	('ca2d2dda-7420-4e3c-9789-5c7786803c11', 'ar', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'دعم استثماري للشركات في مناطق الدعم للمباني والآلات والتدريب.', '2026-08-29 00:51:27.039515+00'),
	('76160849-5a46-4dd7-acbb-705306accf78', 'ar', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'دعم استثماري لتدابير تخفض انبعاثات غازات الدفيئة.', '2026-08-29 00:51:27.039515+00');
INSERT INTO public.kb_translations VALUES
	('9446f98f-b5e7-4b18-a1b9-3061df77f5f3', 'ar', 'Kan projektets miljönytta mätas?', 'هل يمكن قياس الفائدة البيئية للمشروع؟', '2026-08-29 00:51:27.039515+00'),
	('10fa3577-aed7-4b3e-b0f0-149042224301', 'ar', 'Kan åtgärdens utsläppsminskning beräknas?', 'هل يمكن حساب خفض الانبعاثات الناتج عن التدبير؟', '2026-08-29 00:51:27.039515+00'),
	('1dbb040f-417d-4748-bc3d-4999ac8bbd20', 'ar', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'هل تستطيع المنظمة تحمّل التكاليف حتى صرف الدعم؟', '2026-08-29 00:51:27.039515+00'),
	('43f79dbf-fde3-4ff2-9d3c-8f139d45f710', 'ar', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'هل ستُستخدم الخبرات في نشاطك في السويد؟', '2026-08-29 00:51:27.039515+00'),
	('7c860f3d-a796-4c26-a9f6-bf5e2bbc9ee7', 'ar', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'هل سيبدأ الاستثمار فقط بعد إرسال الطلب؟', '2026-08-29 00:51:27.039515+00'),
	('0de08c73-ecaa-4bbc-af0b-4aaf27e1d03f', 'ar', 'Kommer projektet människor i ert närområde till del?', 'هل يعود المشروع بالفائدة على الناس في منطقتكم؟', '2026-08-29 00:51:27.039515+00'),
	('690a02b0-6e43-4150-984d-55da4f073e04', 'ar', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'شبكة الأمان الاقتصادية الأخيرة للبلدية عندما لا يكفي الدخل لأبسط الضروريات.', '2026-08-29 00:51:27.039515+00'),
	('2bdb71f3-5964-487c-9c30-a85813c66a6a', 'ar', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'دعم البلديات الخاص للحياة الجمعوية المحلية: دعم النشاط عن كل جلسة، دعم المقرات، دعم البدء وغير ذلك.', '2026-08-29 00:51:27.039515+00'),
	('740cf697-14eb-4f1e-8940-bfdb9d80ea2d', 'ar', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'نقل مدرسي مجاني لتلاميذ المدرسة الأساسية عند بعد المسافة أو خطورة الطريق أو الإعاقة — حق بموجب قانون المدرسة.', '2026-08-29 00:51:27.039515+00'),
	('d767991f-0387-4742-9800-7c736f903c45', 'ar', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'إعانة قانونية للنظارات أو العدسات للأطفال والشباب؛ تختلف المبالغ والإجراءات حسب المنطقة — تحقق من مستوى منطقتك.', '2026-08-29 00:51:27.039515+00'),
	('e520d0e6-c2e7-4cfc-b80c-f6375b34eb8b', 'ar', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'دعم لتحول الصناعة نحو انبعاثات صفرية من غازات الدفيئة.', '2026-08-29 00:51:27.039515+00'),
	('ecc68b4d-c59b-406a-8e72-8f257082558a', 'ar', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'هل يقع المشروع في منطقة معنية بالطاقة الكهرومائية أو طاقة الرياح؟', '2026-08-29 00:51:27.039515+00'),
	('f8e86472-b6cf-471d-b758-8c8a340daefa', 'ar', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'هل يقع المشروع ضمن البيئة أو العلوم الزراعية أو التخطيط العمراني؟', '2026-08-29 00:51:27.039515+00'),
	('838741c8-e5a0-4771-8294-9f1701e2bee0', 'ar', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'هل يقع مكان النشاط في منطقة الدعم A أو B (أجزاء كبيرة من نورلاند وسفيالاند الداخلية)؟', '2026-08-29 00:51:27.039515+00'),
	('b4dc5460-9bde-4cd7-a4ab-38d0a612e1a8', 'ar', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'قرض لشراء أبسط الضروريات لأول منزل في السويد — أثاث وأدوات منزلية وتجهيزات أساسية أخرى.', '2026-08-29 00:51:27.039515+00'),
	('f5fd7c44-8769-46aa-9169-683ee0c5f7b1', 'ar', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'هل يخفض المشروع انبعاثات العمليات الصناعية أو ينشئ انبعاثات سالبة؟', '2026-08-29 00:51:27.039515+00'),
	('fe66824b-708b-44ca-82c8-3971b96995eb', 'ar', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'علاوة شهرية للأطفال المقيمين في السويد، من الولادة حتى سن 16.', '2026-08-29 00:51:27.039515+00'),
	('8fa69fc8-a83d-4ff2-974d-fc057ae87831', 'ar', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'تقدم Naturvårdsverket إعانات للمنظمات والشركات والجمعيات والقطاع العام والأفراد في مجال البيئة.', '2026-08-29 00:51:27.039515+00'),
	('4eb2f677-98e6-4f6f-a150-8f0c71558968', 'ar', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'هل تخطط للعودة طوعًا ونهائيًا إلى بلدك الأصلي؟', '2026-08-29 00:51:27.039515+00'),
	('734d843c-9c40-4617-bf81-59c95224dfa9', 'ar', 'Planerar du att starta eget företag?', 'هل تخطط لتأسيس شركتك الخاصة؟', '2026-08-29 00:51:27.039515+00'),
	('d74df72a-8e27-4ac8-9e89-15f91cf8cc3c', 'ar', 'Planerar du att studera utomlands?', 'هل تخطط للدراسة في الخارج؟', '2026-08-29 00:51:27.039515+00'),
	('153702e1-6831-42bb-9e6f-5b9c0a77efbf', 'ar', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'هل تخطط لدراسة تقوي وضعك في سوق العمل؟', '2026-08-29 00:51:27.039515+00'),
	('2bf445b4-1c5a-475b-bc52-8d8f2845bdf7', 'ar', 'Planerar ni att anställa?', 'هل تخططون للتوظيف؟', '2026-08-29 00:51:27.039515+00'),
	('5bba5ff8-9e56-402e-8070-9b33886678dd', 'ar', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'هل تخططون للتقدم إلى برنامج للاتحاد الأوروبي (مثل Horisont Europa)؟', '2026-08-29 00:51:27.039515+00'),
	('1143853b-7fd8-4267-847f-0d2be9d201a6', 'ar', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'دعم إنتاج وتطوير الأفلام القصيرة والوثائقية.', '2026-08-29 00:51:27.039515+00'),
	('d9fd46f8-4d18-4c85-b283-6315e795104b', 'ar', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'إعانات مشاريع للمشهد الموسيقي الحر للحفلات والإنتاج والتطوير.', '2026-08-29 00:51:27.039515+00'),
	('80c55262-3d76-436b-82ad-dabf6564fe2a', 'ar', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'إعانات مشاريع للمنظمات غير الربحية العاملة مع الأطفال والشباب ولأجلهم.', '2026-08-29 00:51:27.039515+00'),
	('8dbbfc56-4051-4dd9-a063-a0692308adb9', 'ar', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'هل يجرب المشروع تعبيرات أو أساليب أو تعاونات فنية جديدة؟', '2026-08-29 00:51:27.039515+00'),
	('39d49324-d5db-4b1c-9b59-567a662b1a0b', 'ar', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'هل يستمر التبادل من 5 إلى 21 يومًا (دون أيام السفر)؟', '2026-08-29 00:51:27.039515+00'),
	('87886ca4-74c9-47dc-b7e4-3118aaf7de4f', 'ar', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'دعم المناطق الخاص لمشاريع وأنشطة الحياة الثقافية، إلى جانب إعانات Kulturrådet الوطنية.', '2026-08-29 00:51:27.039515+00'),
	('6db1ad40-47c5-4112-a1a2-ea5a4a22e8a5', 'ar', 'Riktar sig projektet till barn eller unga?', 'هل يستهدف المشروع الأطفال أو الشباب؟', '2026-08-29 00:51:27.039515+00'),
	('7e5e2b2b-540c-4bee-933f-2738ce6ae72a', 'ar', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'هل يستهدف المشروع الأطفال أو الشباب أو كبار السن أو ذوي الإعاقة؟', '2026-08-29 00:51:27.039515+00'),
	('584afc47-aa6a-4466-80fc-53b97dbd7dd3', 'ar', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'هل يستهدف النشاط الأطفال والشباب (7–25 عامًا)؟', '2026-08-29 00:51:27.039515+00'),
	('8aa274de-069b-41cd-bb3d-6c0aa7583543', 'ar', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'هل تفتقر إلى مدخرات أو أصول يمكن أن تغطي النفقات؟', '2026-08-29 00:51:27.039515+00'),
	('34acbebd-d191-4833-bb3f-c38ea719a328', 'ar', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'هل تتعاونون مع شركاء في بلدين شماليين آخرين على الأقل؟', '2026-08-29 00:51:27.039515+00'),
	('f851c9fd-43b5-4595-a9cb-b1bfca604f2c', 'ar', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'هل ستجلبون خبرات خارجية لإجراء تطويري؟', '2026-08-29 00:51:27.039515+00'),
	('de4e1f16-41a3-4dda-98ce-c3afdda2da69', 'ar', 'Sker mobiliteten till ett annat europeiskt land?', 'هل التنقل إلى بلد أوروبي آخر؟', '2026-08-29 00:51:27.039515+00'),
	('095d875c-2469-41ec-816f-bd0114000c60', 'ar', 'Startar du eller tar du över företaget för första gången?', 'هل تؤسس الشركة أو تتولاها لأول مرة؟', '2026-08-29 00:51:27.039515+00'),
	('207e9661-8008-4022-9388-c45e866fb4f1', 'ar', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'دعم بدء لمن هو في سن 40 أو أقل ويؤسس منشأة زراعية أو يتولاها.', '2026-08-29 00:51:27.039515+00'),
	('b7da9653-d44a-4f82-974f-7934996fe7b1', 'ar', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'منحة تتيح للفنانين المحترفين التركيز على عملهم الفني.', '2026-08-29 00:51:27.039515+00'),
	('8d795a02-5332-4213-8a66-38abe8916539', 'ar', 'Studerar du, eller planerar du att börja studera?', 'هل تدرس، أو تخطط لبدء الدراسة؟', '2026-08-29 00:51:27.039515+00'),
	('231a5651-5206-46df-a196-6a7b12c8260a', 'ar', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'دعم دراسي للبالغين العاملين الراغبين في التعلم لتقوية وضعهم في سوق العمل.', '2026-08-29 00:51:27.039515+00'),
	('65ac0ddc-4a9f-480c-9171-825a68344be1', 'ar', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'دعم للاستثمارات التي تزيد القدرة التنافسية أو تقلل الأثر البيئي في المنشآت الزراعية.', '2026-08-29 00:51:27.039515+00'),
	('9ae5f022-7668-4867-8ad2-4c337fe923e0', 'ar', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'دعم عندما يعيش طفل معك ولا يدفع الوالد الآخر النفقة.', '2026-08-29 00:51:27.039515+00'),
	('6c25b0f1-ccd5-462e-b8ff-604581b1bae8', 'ar', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'دعم لمشاريع المنظمات غير الربحية من أجل الناس والبيئة وعالم أفضل.', '2026-08-29 00:51:27.039515+00'),
	('cdc31d1b-e47b-496e-8c9d-65be4565491f', 'ar', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'دعم لمشاريع الفنون والثقافة ذات البعد الشمالي والتعاون عبر الحدود.', '2026-08-29 00:51:27.039515+00'),
	('ef7920ac-639e-4206-9304-2af344808fde', 'ar', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'دعم للمشاريع الثقافية المبتكرة التي تجرب تعبيرات أو أساليب أو تعاونات فنية جديدة.', '2026-08-29 00:51:27.039515+00'),
	('286b5c8c-d3e9-433d-9c3f-56dc9bfa642d', 'ar', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'دعم للمشاريع المبتكرة للأطفال والشباب وكبار السن وذوي الإعاقة.', '2026-08-29 00:51:27.039515+00'),
	('109b6619-f69e-4146-b70d-a830f0f6c773', 'ar', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'دعم لمشاريع التعاون في المشهد الموسيقي الحر.', '2026-08-29 00:51:27.039515+00'),
	('c3944cc5-c503-4350-a140-2ce6d1af986e', 'ar', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'دعم لمشاريع التعاون في الثقافة والإعلام التي تعزز الديمقراطية وحرية التعبير دوليًا.', '2026-08-29 00:51:27.039515+00');
INSERT INTO public.kb_translations VALUES
	('69a65831-b4c1-4d65-b248-492aa5b366c3', 'ar', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'هل يهدف المشروع إلى تعزيز الديمقراطية أو المساواة أو حرية التعبير؟', '2026-08-29 00:51:27.039515+00'),
	('351797dc-ec26-4494-ba04-4bd5c90b4861', 'ar', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'هل تبحث عن عمل، أو حصلت على عرض عمل، في بلد آخر من الاتحاد الأوروبي أو المنطقة الاقتصادية الأوروبية؟', '2026-08-29 00:51:27.039515+00'),
	('36cbbc8f-f4b3-4ccd-bb5e-9e3fec43b5a0', 'ar', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقف لما تدفعه من رسوم المرضى خلال فترة اثني عشر شهرًا — بعد ذلك frikort (بطاقة مجانية).', '2026-08-29 00:51:27.039515+00'),
	('cd8c9cd9-40b2-4ffe-b25d-fb8d163b295b', 'ar', 'Tar du ut hel allmän pension?', 'هل تتقاضى معاشك العام كاملًا؟', '2026-08-29 00:51:27.039515+00'),
	('f39a4104-56fa-4797-aa7f-439a634030ac', 'ar', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'إضافة تغطي جزءًا من تكلفة السكن لمن لديه معاش ودخل منخفض.', '2026-08-29 00:51:27.039515+00'),
	('2bcdf4f1-f0a5-4aee-8ef8-babdef067604', 'ar', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'إعانة تنظيمية سنوية للمنظمات الوطنية للأطفال والشباب.', '2026-08-29 00:51:27.039515+00'),
	('266a519e-7a09-44d4-93e8-6aa9f9c6c8ca', 'ar', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'رصيد سنوي يُخصم مباشرة عند طبيب الأسنان أو أخصائي صحة الأسنان.', '2026-08-29 00:51:27.039515+00'),
	('96de1313-c3e5-48ef-9a56-cfd6456d68ff', 'ar', 'Är bolaget yngre än cirka 5 år?', 'هل عمر الشركة أقل من حوالي 5 سنوات؟', '2026-08-29 00:51:27.039515+00'),
	('2e42c908-fe6d-491d-834f-21026d4d94c6', 'ar', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'هل أعمار المشاركين في التبادل بين 13 و30 عامًا؟', '2026-08-29 00:51:27.039515+00'),
	('ba795728-6b75-408d-8363-3d57aba32379', 'ar', 'Är det här ert första EU-projekt?', 'هل هذا أول مشروع اتحاد أوروبي لكم؟', '2026-08-29 00:51:27.039515+00'),
	('b7a6933e-e8f6-447f-8119-5df1be00401e', 'ar', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'هل من الصعب جدًا عليك (أو على طفلك) التنقل بمفردك أو السفر بالحافلة والقطار؟', '2026-08-29 00:51:27.039515+00'),
	('35e97a94-522e-47f2-8572-850710447d65', 'ar', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'هل دخلك أقل من حوالي 25 000 كرونة شهريًا قبل الضريبة؟', '2026-08-29 00:51:27.039515+00'),
	('9326cba9-f77c-402d-9b9c-c78817cd7b71', 'ar', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'هل آخر تعليم أنهيته هو المدرسة الأساسية، أو ثانوية لم تكملها؟', '2026-08-29 00:51:27.039515+00'),
	('3edcea68-9b75-4c3f-b5fa-57aebc26729e', 'ar', 'Är du 40 år eller yngre?', 'هل عمرك 40 عامًا أو أقل؟', '2026-08-29 00:51:27.039515+00'),
	('0fc7ee3b-ff19-4fd0-bb31-0caa956e3c6c', 'ar', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'هل أنت مسجل كباحث عن عمل لدى Arbetsförmedlingen؟', '2026-08-29 00:51:27.039515+00'),
	('660cc01c-bf82-4c07-b82b-572a1c5776d0', 'ar', 'Är du mellan 18 och 28 år?', 'هل عمرك بين 18 و28 عامًا؟', '2026-08-29 00:51:27.039515+00'),
	('aa56a5c4-c59a-417e-8925-c7168f9c8cd2', 'ar', 'Är du mellan 19 och 29 år?', 'هل عمرك بين 19 و29 عامًا؟', '2026-08-29 00:51:27.039515+00'),
	('0516f778-abbc-48a7-8197-98f7389c224c', 'ar', 'Är du mellan 25 och 60 år?', 'هل عمرك بين 25 و60 عامًا؟', '2026-08-29 00:51:27.039515+00'),
	('95766d33-1e96-4bdb-9cf0-ed91cfd2b77f', 'ar', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'هل تعمل باحتراف في المجال الثقافي (مثل الرقص أو الموسيقى أو الفنون الأدائية)؟', '2026-08-29 00:51:27.039515+00'),
	('94a25b7c-7819-41ce-90c2-8a23743305d1', 'ar', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'هل أنت فنان محترف (لست هاويًا ولست في التدريب الأساسي)؟', '2026-08-29 00:51:27.039515+00'),
	('6e340f01-12b2-49b8-a940-630a618a24e5', 'ar', 'Är du yrkesverksam konstnär?', 'هل أنت فنان محترف؟', '2026-08-29 00:51:27.039515+00'),
	('32b2a253-5fae-4f60-b2b5-bf85b7613d41', 'ar', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'هل حلكم مبتكر جوهريًا مقارنة بما هو موجود بالفعل؟', '2026-08-29 00:51:27.043271+00'),
	('af2a58a9-146e-4164-b35d-13250b6a84b0', 'ar', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'هل النادي منتسب إلى اتحاد رياضي متخصص ضمن Riksidrottsförbundet؟', '2026-08-29 00:51:27.043271+00'),
	('3d6215b5-8d4f-4b06-953a-9a90566f8eaf', 'ar', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'هل دخل الأسرة منخفض مقارنة بتكلفة السكن؟', '2026-08-29 00:51:27.043271+00'),
	('0e99ac41-a7ba-4fea-8f99-cf7ff9403566', 'ar', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'هل الدخل الإجمالي للأسرة أقل من حوالي 25 000 كرونة شهريًا قبل الضريبة؟', '2026-08-29 00:51:27.043271+00'),
	('cac9ae22-8564-4154-972f-15a2aa0ba793', 'ar', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'هل الإجراء مشروع محدد (وليس النشاط الاعتيادي)؟', '2026-08-29 00:51:27.043271+00'),
	('903cb423-49f3-4781-bdee-4f8eb0b3467c', 'ar', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'هل المقر مفتوح للجميع — وليس لأعضائكم فقط؟', '2026-08-29 00:51:27.043271+00'),
	('a91ad68c-50cc-4db1-9684-53ac08649246', 'ar', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'هل 60٪ على الأقل من الأعضاء بين 6 و25 عامًا؟', '2026-08-29 00:51:27.043271+00'),
	('ad3d5fef-cd9c-4a60-be7b-4aa2b0c951e9', 'ar', 'Är minst 60 % av medlemmarna under 26 år?', 'هل 60٪ على الأقل من الأعضاء دون 26 عامًا؟', '2026-08-29 00:51:27.043271+00'),
	('7337d024-f02c-45f2-bf0f-d5354ab22ab5', 'ar', 'Är målgruppen delaktig i planering och genomförande?', 'هل تشارك الفئة المستهدفة في التخطيط والتنفيذ؟', '2026-08-29 00:51:27.043271+00'),
	('b8d09d80-f4eb-4884-aac1-86d5ed2c72b3', 'ar', 'Är ni ett förlag med professionell utgivning?', 'هل أنتم دار نشر ذات نشر احترافي؟', '2026-08-29 00:51:27.043271+00'),
	('65f90a71-529d-44b2-acb5-eb6ca851d4a7', 'ar', 'Är ni huvudman för förskoleklass eller grundskola?', 'هل أنتم الجهة المسؤولة عن صف تمهيدي أو مدرسة أساسية؟', '2026-08-29 00:51:27.043271+00'),
	('02a3dcaa-e2bc-4ff3-a460-62f0cbbb377b', 'ar', 'Är organisationen registrerad i EU:s deltagarregister?', 'هل المنظمة مسجلة في سجل المشاركين للاتحاد الأوروبي؟', '2026-08-29 00:51:27.043271+00'),
	('c031e9c0-91e8-4528-9813-254b37acc5d5', 'ar', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'هل المشروع مشروع سينمائي (فيلم قصير أو وثائقي)؟', '2026-08-29 00:51:27.043271+00'),
	('24c84cde-38e2-4683-929b-e119f59cdd8c', 'ar', 'Är projektet ett konst- eller kulturprojekt?', 'هل المشروع مشروع فني أو ثقافي؟', '2026-08-29 00:51:27.043271+00'),
	('9931877b-e27f-4b30-b28f-e3bf924aa2c9', 'ar', 'Är projektet ett kulturprojekt?', 'هل المشروع مشروع ثقافي؟', '2026-08-29 00:51:27.043271+00'),
	('09dfb9e6-89cd-4f21-b7d0-59dedd6d4754', 'ar', 'Är projektet ett musikprojekt?', 'هل المشروع مشروع موسيقي؟', '2026-08-29 00:51:27.043271+00'),
	('356f4451-97e2-4534-8cd4-e566ea739ef7', 'ar', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'هل المشروع مبتكر — شيء لا تفعلونه بالفعل في نشاطكم الاعتيادي؟', '2026-08-29 00:51:27.043271+00'),
	('691f76e9-95cd-4d86-b30e-2d13508f1d16', 'ar', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'هل يفيد المشروع المنطقة ككل (وليس أفرادًا)؟', '2026-08-29 00:51:27.043271+00'),
	('76ae023d-e994-4639-89aa-b1cf5791f46a', 'ar', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'هل الطريق بين المنزل والمدرسة الثانوية ستة كيلومترات على الأقل؟', '2026-08-29 00:51:27.043271+00'),
	('61fbd054-a9c6-4001-a967-4c2ee854a104', 'ar', 'Är verksamheten professionell (inte amatörverksamhet)?', 'هل النشاط احترافي (وليس هاويًا)؟', '2026-08-29 00:51:27.043271+00'),
	('c34bdd2d-d9ea-40d6-8ab1-d3bff1b1f89c', 'ar', 'Är verksamheten professionell?', 'هل النشاط احترافي؟', '2026-08-29 00:51:27.043271+00'),
	('c281c230-f111-4b70-9896-96a4481764e8', 'ar', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'هل النشاط فنون أدائية (رقص، مسرح، مسرح موسيقي)؟', '2026-08-29 00:51:27.043271+00'),
	('94870af6-a1fe-4108-b619-fec650c3413c', 'ar', 'Är volontärerna mellan 18 och 30 år?', 'هل أعمار المتطوعين بين 18 و30 عامًا؟', '2026-08-29 00:51:27.043271+00'),
	('dc68a45e-36dd-48b7-8eee-802668f379d7', 'fa', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'حمایت از فعالیت باشگاه‌های ورزشی که فعالیت‌های زیر نظر مربی برای کودکان و جوانان ۷ تا ۲۵ ساله برگزار می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('09421f23-ad5d-4fa6-a2b7-1eef83598745', 'fa', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'افزودنی خودکار به کمک‌هزینه فرزند (barnbidrag) از فرزند دوم به بعد.', '2026-08-29 00:51:27.048949+00'),
	('6c8f25ce-23f2-490a-bd9e-1410e6c1dd0f', 'fa', 'Avser ansökan en fysisk investering?', 'آیا درخواست مربوط به یک سرمایه‌گذاری فیزیکی است؟', '2026-08-29 00:51:27.048949+00'),
	('363080a7-2d8e-4456-af1a-dbdfafc8d7c9', 'fa', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'آیا درخواست مربوط به یک سفر یا تبادل بین‌المللی است؟', '2026-08-29 00:51:27.048949+00'),
	('adda949d-c767-4ac2-96fc-1eeddbb4a8a5', 'fa', 'Avser ansökan en investering i byggnader eller maskiner?', 'آیا درخواست مربوط به سرمایه‌گذاری در ساختمان یا ماشین‌آلات است؟', '2026-08-29 00:51:27.048949+00'),
	('28afc886-f1ba-4789-b8f8-cfaf02c7978a', 'fa', 'Avser ansökan en redan utgiven titel?', 'آیا درخواست مربوط به اثری است که قبلاً منتشر شده است؟', '2026-08-29 00:51:27.048949+00');
INSERT INTO public.kb_translations VALUES
	('a9643b62-d683-49bf-8141-f3ee74a0e257', 'fa', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'آیا درخواست مربوط به یک بنگاه کشاورزی، باغبانی یا پرورش گوزن شمالی است؟', '2026-08-29 00:51:27.048949+00'),
	('4dbabc7e-c20e-4c29-99fe-165f66ca1b16', 'fa', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'آیا درخواست مربوط به خرید کتاب برای کتابخانه‌های عمومی یا مدرسه‌ای است؟', '2026-08-29 00:51:27.048949+00'),
	('a6d7f97c-1463-4c91-a0f8-80bbb54f05e3', 'fa', 'Avser investeringen jordbruksverksamhet?', 'آیا سرمایه‌گذاری مربوط به فعالیت کشاورزی است؟', '2026-08-29 00:51:27.048949+00'),
	('ef1c6da3-10de-48ce-9fbf-96040ba4a324', 'fa', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'آیا پروژه شامل ساختن، خریدن یا بازسازی یک محل است؟', '2026-08-29 00:51:27.048949+00'),
	('d0f409ba-1366-41ac-a0f6-2da16d71a3b9', 'fa', 'Avser projektet naturvård eller friluftsliv?', 'آیا پروژه مربوط به حفاظت از طبیعت یا تفریح در فضای باز است؟', '2026-08-29 00:51:27.048949+00'),
	('94a92c7f-6d1b-4ae5-8bf2-87fbbdf080f3', 'fa', 'Avser projektet skola eller vuxenutbildning?', 'آیا پروژه مربوط به مدرسه یا آموزش بزرگسالان است؟', '2026-08-29 00:51:27.048949+00'),
	('3ec08238-88de-4097-aac4-c1f956c6d27c', 'fa', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'آیا از کار صرف‌نظر می‌کنید تا از یکی از نزدیکان که چنان بیمار است که بیماری جانش را تهدید می‌کند مراقبت کنید یا در کنارش باشید؟', '2026-08-29 00:51:27.048949+00'),
	('2bf14b7b-f614-4eb9-8200-3cbffe0c57ce', 'fa', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'آیا انجمن در شهرداری فعالیت منظم دارد؟', '2026-08-29 00:51:27.048949+00'),
	('ba609527-fd63-4f50-b41f-48bb8179b9eb', 'fa', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'آیا ارزیابی شما این است که توان کاری‌تان به دلیل بیماری یا معلولیت دست‌کم یک سال کاهش یافته است؟', '2026-08-29 00:51:27.048949+00'),
	('833372d1-38aa-4134-8951-f3c8e226e456', 'fa', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'حمایت نیازسنجی‌شده برای کسی که مستمری کم دارد یا ندارد و برای رسیدن به سطح زندگی معقول به کمک نیاز دارد.', '2026-08-29 00:51:27.048949+00'),
	('7aff03c8-917a-4b1a-9681-5d5bffd8aa9a', 'fa', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'آیا کودک باید به دلیل طولانی بودن مسیر در محل تحصیل اقامت کند (خوابگاه)؟', '2026-08-29 00:51:27.048949+00'),
	('2bc6aadf-9675-4c74-80b6-325b29bc5c40', 'fa', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'آیا مسکن نیاز به مناسب‌سازی دارد (مثلاً رمپ، بازکن در، حمام)؟', '2026-08-29 00:51:27.048949+00'),
	('2445b91b-52ca-4068-a5b5-22d1c7316f94', 'fa', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'آیا یکی از فرزندان ۸ تا ۱۹ ساله شما به عینک یا لنز نیاز دارد؟', '2026-08-29 00:51:27.048949+00'),
	('a4a7920a-8a0c-43b7-acc9-39c09f772640', 'fa', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'آیا والد دیگر هیچ نفقه‌ای نمی‌پردازد یا کمتر از نفقه کامل می‌پردازد؟', '2026-08-29 00:51:27.048949+00'),
	('60937490-a83b-4a51-9a4b-609fdbe61298', 'fa', 'Betalar du hyra eller andra boendekostnader?', 'آیا اجاره یا هزینه‌های مسکن دیگری می‌پردازید؟', '2026-08-29 00:51:27.048949+00'),
	('ec149c99-cca4-42f1-b751-9abad0a56304', 'fa', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'کمک‌هزینه برای مناسب‌سازی مسکن در صورت معلولیت — مثلاً رمپ، بازکن در یا مناسب‌سازی حمام.', '2026-08-29 00:51:27.048949+00'),
	('1056691c-a822-4b93-8e5e-c4f24323176a', 'fa', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'کمک‌هزینه برای ساختن، خریدن یا بازسازی سالن‌های اجتماعات عمومی.', '2026-08-29 00:51:27.048949+00'),
	('b0833925-30ce-4044-b7c1-7f5f0891b19e', 'fa', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'کمک‌هزینه برای خرید یا مناسب‌سازی خودرو وقتی معلولیت پایدار جابه‌جایی یا سفر با وسایل نقلیه عمومی را بسیار دشوار می‌کند.', '2026-08-29 00:51:27.048949+00'),
	('fb43b421-fbd5-401f-9eaa-6ff3ac6c4738', 'fa', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'کمک‌هزینه برای سفرها و تبادل‌های بین‌المللی حرفه‌ای‌های حوزه فرهنگ.', '2026-08-29 00:51:27.048949+00'),
	('fb3cce55-e256-4d03-8ffd-a499aad13276', 'fa', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'کمک‌هزینه برای تبادل‌های بین‌المللی، سفرها و اقامت‌های کاری هنرمندان حرفه‌ای.', '2026-08-29 00:51:27.048949+00'),
	('1958176a-17c9-40ba-b0ab-17dcd9d42ec2', 'fa', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'کمک‌هزینه و وام اختیاری برای تحصیل در مقطع دبیرستان یا پس از دبیرستان.', '2026-08-29 00:51:27.048949+00'),
	('a537b343-1192-49d1-9603-2b4bf27d81ba', 'fa', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'کمک‌هزینه و وام برای تحصیل در خارج، با وام‌های تکمیلی برای مثلاً شهریه و سفر.', '2026-08-29 00:51:27.048949+00'),
	('dccd3bea-5655-4844-8018-304dd380e157', 'fa', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'کمکی که به نهادهای سوئدی در آماده‌سازی درخواست برای برنامه‌های اتحادیه اروپا مانند Horisont Europa یاری می‌رساند.', '2026-08-29 00:51:27.048949+00'),
	('bb212c47-68b8-4763-bccc-80fc1947c023', 'fa', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'کمک‌هزینه برای کارفرمایانی که افراد با توان کاری کاهش‌یافته را استخدام می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('72635f6f-7f44-4b1a-a8c0-7f2d0d028f50', 'fa', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'کمک‌هزینه اقامت و سفرهای بازگشت به خانه وقتی دانش‌آموز دبیرستانی به دلیل مسیر طولانی باید در محل تحصیل اقامت کند.', '2026-08-29 00:51:27.048949+00'),
	('5e558b4d-eed5-41a4-ba18-6c8030097d82', 'fa', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'کمک‌هزینه برای کار سازمان‌های غیرانتفاعی در حفظ، استفاده و توسعه میراث فرهنگی.', '2026-08-29 00:51:27.048949+00'),
	('ad93c36b-5f8b-4f7d-8e39-47d059c19d12', 'fa', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'کمک‌هزینه برای پروژه‌های شهری و محلی حفاظت از طبیعت، از جمله تالاب‌ها و تفریح در فضای باز.', '2026-08-29 00:51:27.048949+00'),
	('db1ef649-53cc-48de-805b-15bd8a78ae6d', 'fa', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'کمک‌هزینه به شهرداری‌ها برای خرید کتاب برای کتابخانه‌های عمومی و مدرسه‌ای.', '2026-08-29 00:51:27.048949+00'),
	('3edc6b90-d993-4828-b6b3-9e568125f42d', 'fa', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'کمک‌هزینه به مسئولان مدارس برای آشنایی دانش‌آموزان دوره ابتدایی با فرهنگ حرفه‌ای.', '2026-08-29 00:51:27.048949+00'),
	('48bd8e38-c920-4dfd-a310-4639edaa7095', 'fa', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'کمک‌هزینه برای آنچه فرزندتان نیاز دارد اما بودجه خانواده کفاف نمی‌دهد: فعالیت‌های اوقات فراغت، لباس، اردوهای مدرسه، عینک، فعالیت‌های تعطیلات و غیره.', '2026-08-29 00:51:27.048949+00'),
	('feebd32c-3ec8-4dd2-ae51-5976661e1ea3', 'fa', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'کمک‌هزینه از صندوق‌هایی مانند Världens Barn و Musikhjälpen و Victoriafonden — سازمان‌های غیرانتفاعی سوئدی دارای 90-konto آن را درخواست می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('41f7b2e6-edf3-4aaa-b1a8-1ec39dc08350', 'fa', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'کمک‌هزینه از محل درآمدهای برق‌آبی و بادی برای پروژه‌هایی که منطقه را توسعه می‌دهند.', '2026-08-29 00:51:27.048949+00'),
	('33d5e833-db53-49b0-b80c-5e5f6b80e3aa', 'fa', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'کمک‌هزینه بدون بخش وام برای بیکاران ۲۵ تا ۶۰ ساله با تحصیلات کوتاه که باید در سطح مدرسه ابتدایی یا دبیرستان تحصیل کنند.', '2026-08-29 00:51:27.048949+00'),
	('227b1c52-b174-4222-8493-355213e07a65', 'fa', 'Bidrar projektet till energiomställningen?', 'آیا پروژه به گذار انرژی کمک می‌کند؟', '2026-08-29 00:51:27.048949+00'),
	('7d395324-9070-4a40-998a-04901de4abb5', 'fa', 'Bor du och barnets andra förälder på skilda håll?', 'آیا شما و والد دیگر کودک جدا از هم زندگی می‌کنید؟', '2026-08-29 00:51:27.048949+00'),
	('fd89bb25-ce64-4be2-96d7-36a1b27efcf2', 'fa', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'چک‌هایی برای شرکت‌های کوچک برای به‌کارگیری تخصص بیرونی در بین‌المللی‌سازی یا دیجیتالی‌سازی.', '2026-08-29 00:51:27.048949+00'),
	('6d8dd4cc-cd1e-4393-9eb6-d636c529c113', 'fa', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'آیا در برنامه‌ای نزد Arbetsförmedlingen شرکت می‌کنید (مثلاً jobb- och utvecklingsgarantin)؟', '2026-08-29 00:51:27.048949+00'),
	('b31bccc2-2956-490c-a2ff-725595530c3b', 'fa', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'حمایت پسینی از ناشران برای انتشار ادبیات باکیفیت.', '2026-08-29 00:51:27.048949+00'),
	('d2c0cfb1-55b7-4f7d-b5ba-43cf953c2df4', 'fa', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'حمایت مالی برای کسی که اجازه اقامت مرتبط با حمایت دارد و داوطلبانه می‌خواهد برای همیشه به کشور مبدأ بازگردد.', '2026-08-29 00:51:27.048949+00'),
	('7c0428f2-4ae9-4e9c-be91-dee79bcf1033', 'fa', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'حمایت مالی از کارفرمایانی که فردی را استخدام می‌کنند که مدت طولانی از زندگی کاری دور بوده است.', '2026-08-29 00:51:27.048949+00'),
	('1025949d-cf5c-41bb-87b6-bde4e1763cab', 'fa', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'حمایت مالی در دوره راه‌اندازی برای جویندگان کار که کسب‌وکار خود را آغاز می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('ad6fb599-ed78-4604-a167-a5cda2c42801', 'fa', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten به‌طور مستمر فراخوان‌هایی در پژوهش انرژی، نوآوری و بهره‌وری انرژی برگزار می‌کند.', '2026-08-29 00:51:27.048949+00'),
	('04851930-658b-4c63-b256-8e83ec0a9415', 'fa', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'پرداختی برای غیبت از کار یا تحصیل به‌منظور مراقبت از کودک.', '2026-08-29 00:51:27.048949+00'),
	('8ce4645a-03ce-4923-88f0-4fe1c4988228', 'fa', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'پرداختی برای کسی که تازه‌وارد سوئد است و در برنامه استقرار Arbetsförmedlingen شرکت می‌کند؛ توسط Försäkringskassan پرداخت می‌شود.', '2026-08-29 00:51:27.048949+00'),
	('d560c4b1-cecd-44c5-a4cc-ea7b5577cb36', 'fa', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'پرداختی که بخشی از هزینه مسکن جوانان بدون فرزند با درآمد کم را می‌پوشاند.', '2026-08-29 00:51:27.048949+00'),
	('e8a0f34d-c893-46f4-9b67-6dec99ca3bbd', 'fa', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'پرداختی برای هزینه‌های اضافی ناشی از معلولیت پایدار — برای بزرگسالان یا والدین کودکان دارای معلولیت.', '2026-08-29 00:51:27.048949+00'),
	('954b87eb-420a-4bb2-90ef-cb7b76e1d1f5', 'fa', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'پرداختی برای جوانان (۱۹–۲۹ ساله) که به دلیل بیماری یا معلولیت دست‌کم یک سال نمی‌توانند تمام‌وقت کار کنند.', '2026-08-29 00:51:27.048949+00'),
	('65c87eb2-6bf2-48ac-9723-d8347286e451', 'fa', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'پرداختی وقتی توان کاری به‌طور پایدار کاهش یافته است — آنچه پیش‌تر förtidspension (بازنشستگی پیش از موعد) نامیده می‌شد.', '2026-08-29 00:51:27.048949+00'),
	('844cba03-ed06-44ba-ac56-2501432b67f4', 'fa', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'پرداختی وقتی از کار صرف‌نظر می‌کنید تا در کنار یکی از نزدیکانِ به‌شدت بیمار باشید.', '2026-08-29 00:51:27.048949+00'),
	('c4fb532e-e01c-43cd-bec4-e99ebbd69c9d', 'fa', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'پرداختی هنگام شرکت شما در یک برنامه بازار کار نزد Arbetsförmedlingen.', '2026-08-29 00:51:27.048949+00');
INSERT INTO public.kb_translations VALUES
	('a701baae-c5e3-404d-ad91-332498c6213c', 'fa', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'پرداختی وقتی به دلیل بیماری نمی‌توانید مانند معمول کار کنید.', '2026-08-29 00:51:27.048949+00'),
	('2e4b0354-e665-44c6-882c-10b8a53e1d44', 'fa', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'پرداختی وقتی برای مراقبت از کودک بیمار در خانه می‌مانید.', '2026-08-29 00:51:27.048949+00'),
	('c6bd5216-c179-4612-b146-c6ece65cc677', 'fa', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'پرداختی که بخشی از هزینه مسکن خانوارهای دارای فرزند و درآمد پایین‌تر را می‌پوشاند.', '2026-08-29 00:51:27.048949+00'),
	('7f21d309-74ab-4737-a927-b68a9138260b', 'fa', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'پرداختی برای والدینی که فرزندشان به دلیل معلولیت به مراقبت و نظارت بیشتری از کودکان هم‌سن نیاز دارد.', '2026-08-29 00:51:27.048949+00'),
	('8f6aa022-062c-4a7c-80eb-de50a167a0a6', 'fa', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'پرداختی در دوران بیکاری — مبتنی بر درآمد برای اعضا، مبلغ پایه برای دیگران.', '2026-08-29 00:51:27.048949+00'),
	('b76d1efe-23c4-4a13-8d4f-8a10959a478a', 'fa', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'حدود پنجاه بنیاد بانک‌های پس‌انداز به پروژه‌های محلی در ورزش، فرهنگ، آموزش و توسعه اجتماعی کمک می‌کنند — در حوزه فعالیت بانک.', '2026-08-29 00:51:27.048949+00'),
	('399aea0e-b754-4218-91d5-0f608356dde0', 'fa', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'حمایت پروژه‌ای با بودجه اتحادیه اروپا که نزد منطقه Leader محلی شما درخواست می‌شود — برای انجمن‌ها، شرکت‌ها و شهرداری‌هایی که روستاها را توسعه می‌دهند.', '2026-08-29 00:51:27.048949+00'),
	('e92cdafd-8c4f-44ff-86d4-71e736d7eb5d', 'fa', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'حمایت با بودجه اتحادیه اروپا برای جویندگان کار که در کشور دیگری از اتحادیه اروپا/منطقه اقتصادی اروپا کاری می‌پذیرند: جبران هزینه سفر مصاحبه، هزینه اسباب‌کشی و دوره زبان.', '2026-08-29 00:51:27.048949+00'),
	('cc423331-e1b6-4239-a7c2-1132e10f5032', 'fa', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'بودجه صندوق اجتماعی اروپا برای پروژه‌هایی که مهارت‌ها، گذار شغلی و شمول در بازار کار را تقویت می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('d622ba44-865c-48c5-a057-e813b2cd821c', 'fa', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'حمایت اتحادیه اروپا از تبادل‌های گروهی جوانان ۱۳ تا ۳۰ ساله، به مدت ۵ تا ۲۱ روز بدون روزهای سفر.', '2026-08-29 00:51:27.048949+00'),
	('eaef62e4-8c15-4f3c-97db-6ab317b6e6ca', 'fa', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'حمایت اتحادیه اروپا از پروژه‌های همکاری سازمان‌های فرهنگی با شرکایی در چند کشور اروپایی.', '2026-08-29 00:51:27.048949+00'),
	('fc42f741-8b73-4ab5-940a-8c67b7d94568', 'fa', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'حمایت اتحادیه اروپا از سازمان‌هایی که داوطلبان جوان ۱۸ تا ۳۰ ساله را می‌پذیرند یا می‌فرستند.', '2026-08-29 00:51:27.048949+00'),
	('7137eef5-0788-422c-bcbf-d212823bdbf1', 'fa', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'حمایت اتحادیه اروپا از تحرک کارکنان و دانش‌آموزان در مدرسه و آموزش بزرگسالان.', '2026-08-29 00:51:27.048949+00'),
	('0b34289e-92bf-447c-87e9-2576aa4ffa86', 'fa', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'حمایت اتحادیه اروپا با مبالغ مقطوع برای نخستین پروژه‌های همکاری اروپایی سازمان‌های کوچک‌تر.', '2026-08-29 00:51:27.048949+00'),
	('1687f2f7-be82-4aca-a677-18a3717b288f', 'fa', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تأمین مالی برای شرکت‌های جوانی که محصولات یا خدمات نوآورانه با ظرفیت بین‌المللی توسعه می‌دهند.', '2026-08-29 00:51:27.048949+00'),
	('63281bc3-ced0-403c-9313-05ada1d03e13', 'prs', 'Bor du och barnets andra förälder på skilda håll?', 'آیا شما و والد دیگر طفل جدا از هم زندگی می‌کنید؟', '2026-08-29 00:51:27.058206+00'),
	('738b6d19-defc-4091-967f-ddb8412ce657', 'fa', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'آیا در محل فعالیت شما بانک پس‌اندازی (و در نتیجه بنیاد بانک پس‌انداز) وجود دارد؟', '2026-08-29 00:51:27.048949+00'),
	('5592a1b8-5f5f-4e1d-bd54-0e3190117328', 'fa', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'کمک‌هزینه فعالیت چندساله برای گروه‌های مستقل حرفه‌ای رقص، تئاتر و تئاتر موزیکال.', '2026-08-29 00:51:27.048949+00'),
	('028666d6-a3a2-4193-b1e0-6ae73a4c069e', 'fa', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'کمک‌هزینه پژوهشی در حوزه‌های Forte: سلامت، زندگی کاری و رفاه. پژوهشگران دارای دکترا در دانشگاه‌های سوئد درخواست می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('44349368-047d-449c-9a2b-d28a2e7d0c65', 'fa', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'بودجه پژوهشی برای پژوهش بنیادی آزاد در همه حوزه‌های علمی.', '2026-08-29 00:51:27.048949+00'),
	('81c7fdad-468f-4c5e-9943-b7df2f210bd9', 'fa', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'بودجه پژوهشی در محیط‌زیست، علوم کشاورزی و شهرسازی.', '2026-08-29 00:51:27.048949+00'),
	('037fcb22-db11-4df5-ba3a-dcd5ca418c3c', 'fa', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'آیا به مهاجرت به خارج فکر می‌کنید (برای کار، تحصیل یا بازگشت به وطن)؟', '2026-08-29 00:51:27.048949+00'),
	('f8b0739c-7ba0-414d-bc7e-3fe3402e29b2', 'fa', 'Genomförs insatserna av professionella kulturaktörer?', 'آیا فعالیت‌ها را کنشگران فرهنگی حرفه‌ای اجرا می‌کنند؟', '2026-08-29 00:51:27.048949+00'),
	('8459a7a8-0213-468a-bb02-745e45be6906', 'fa', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'آیا پروژه در روستا یا در شهرک کوچکی اجرا می‌شود؟', '2026-08-29 00:51:27.048949+00'),
	('84d1e532-479c-42ae-b661-53d8d106f998', 'fa', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حمایت پایه برای کسی که در طول زندگی درآمد کاری کم یا هیچ نداشته است.', '2026-08-29 00:51:27.048949+00'),
	('02fc2ac6-072c-45b4-a39e-313e9a21634d', 'fa', 'Går något av dina barn i grundskolan?', 'آیا یکی از فرزندانتان به مدرسه ابتدایی می‌رود؟', '2026-08-29 00:51:27.048949+00'),
	('3c4c5ae4-bf77-4852-a58c-a7ef342d8b58', 'fa', 'Går något av dina barn på gymnasiet?', 'آیا یکی از فرزندانتان در دبیرستان تحصیل می‌کند؟', '2026-08-29 00:51:27.048949+00'),
	('66abe5ef-2412-4ca6-914e-058e3c18742e', 'fa', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'آیا استخدام مربوط به فردی با توان کاری کاهش‌یافته است؟', '2026-08-29 00:51:27.048949+00'),
	('4ccc8f65-509d-4ccb-9378-050b59b2adf4', 'fa', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'آیا استخدام مربوط به کسی است که مدت طولانی بیکار بوده یا تازه‌وارد سوئد است؟', '2026-08-29 00:51:27.048949+00'),
	('8ef6399c-6d70-4d82-b597-e70965e8b665', 'fa', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'آیا پروژه درباره حفظ میراث فرهنگی یا دسترس‌پذیر کردن آن است؟', '2026-08-29 00:51:27.048949+00'),
	('708a495a-ba59-488f-8afd-4df3f90e7b6e', 'fa', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'آیا پروژه درباره انرژی، بهره‌وری انرژی یا نوآوری مرتبط با انرژی است؟', '2026-08-29 00:51:27.048949+00'),
	('ebad9d6f-661b-4101-aa18-dedae2c39443', 'fa', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'آیا پروژه درباره سلامت، زندگی کاری یا رفاه است؟', '2026-08-29 00:51:27.048949+00'),
	('102f80c0-5ec8-4e55-8af9-d83988efda9a', 'fa', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'آیا پروژه درباره توسعه مهارت‌ها یا اقدامات بازار کار است؟', '2026-08-29 00:51:27.048949+00'),
	('1d6d72f7-beaf-4fcd-82f4-6d2b80d3d434', 'fa', 'Handlar projektet om miljö- eller klimatåtgärder?', 'آیا پروژه درباره اقدامات زیست‌محیطی یا اقلیمی است؟', '2026-08-29 00:51:27.048949+00'),
	('c7b87736-b9de-42dc-8a01-c8c588260a11', 'fa', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'آیا مسیر کودک به مدرسه طولانی، به دلیل ترافیک خطرناک یا به شکل دیگری دشوار است؟', '2026-08-29 00:51:27.048949+00'),
	('b3b45ce8-b56b-401c-b3cf-67a1721149c1', 'fa', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'آیا دست‌کم ۱۶ ساعت در هفته و در مجموع دست‌کم ۸ سال کار کرده‌اید؟', '2026-08-29 00:51:27.048949+00'),
	('71437271-979d-47c7-b7b1-67a3ea475605', 'fa', 'Har du barn som bor hos dig, helt eller växelvis?', 'آیا فرزندانی دارید که نزد شما زندگی می‌کنند، تمام‌وقت یا به‌تناوب؟', '2026-08-29 00:51:27.048949+00'),
	('cd956e1b-2446-4894-bb75-f007158fd416', 'fa', 'Har du barn som bor hos dig?', 'آیا فرزندانی دارید که نزد شما زندگی می‌کنند؟', '2026-08-29 00:51:27.048949+00'),
	('845cf6dd-d746-4c93-a07c-ddcda265aa0a', 'fa', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'آیا شما یا فرزندتان معلولیتی دارید که انتظار می‌رود دست‌کم یک سال ادامه یابد؟', '2026-08-29 00:51:27.048949+00'),
	('3f20e5af-f2f3-4079-a566-766271e57979', 'fa', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'آیا شما یا کسی در خانوار معلولیت پایداری دارد که بر مسکن اثر می‌گذارد؟', '2026-08-29 00:51:27.048949+00'),
	('d4194fbb-b2aa-4646-befc-b3a49333b271', 'fa', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'آیا شما یا یکی از نزدیکان معلولیت یا بیماری طولانی یا جدی دارید؟', '2026-08-29 00:51:27.048949+00'),
	('ac16a924-9aa0-47e4-af38-12e5b871b212', 'fa', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'آیا بیماری یا آسیبی دارید که هم‌اکنون توان کاری شما را کاهش می‌دهد؟', '2026-08-29 00:51:27.048949+00'),
	('63c454f0-712e-424d-bcdd-252285165173', 'fa', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'آیا تاکنون در پرداخت هزینه اردوی مدرسه، سفر کلاسی یا فعالیت اوقات فراغتی که انتظار می‌رود فرزندتان در آن شرکت کند مشکل داشته‌اید؟', '2026-08-29 00:51:27.048949+00'),
	('d0205ce4-c299-4fce-9bb7-7394af917dcf', 'fa', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'آیا گذران زندگی با مستمری و سایر درآمدهایتان برایتان دشوار است؟', '2026-08-29 00:51:27.048949+00'),
	('d57e359f-fd71-41e2-b9b9-f91ddb04efd4', 'fa', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'آیا در سال‌های اخیر اجازه اقامت در سوئد گرفته‌اید، مثلاً به‌عنوان نیازمند حمایت یا عضو خانواده؟', '2026-08-29 00:51:27.048949+00'),
	('d9b47af7-d7b8-435f-86fe-3a2137191520', 'fa', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'آیا اجازه اقامت در سوئد به‌عنوان پناهنده یا نیازمند حمایت دارید (یا از بستگان نزدیک چنین کسی هستید)؟', '2026-08-29 00:51:27.048949+00'),
	('ef4c2fe0-52f7-4671-9649-4a708a6b773a', 'fa', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'آیا به سن مرجع بازنشستگی رسیده‌اید (۶۷ سال در ۲۰۲۶)؟', '2026-08-29 00:51:27.048949+00'),
	('7e944a12-d344-458b-9556-d51dba66da45', 'fa', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'آیا سازمان شما OID (Organisation ID) ثبت‌شده در Organisation Registration System اتحادیه اروپا دارد؟', '2026-08-29 00:51:27.048949+00'),
	('145f594f-579a-4f07-8eb4-834e6f0d5b03', 'fa', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'آیا معلولیت هزینه‌های اضافی به همراه داشته است — مثلاً وسایل کمکی، سفر، رژیم غذایی خاص یا استهلاک؟', '2026-08-29 00:51:27.048949+00'),
	('8063adfe-1592-4121-a5c3-0576bce52f5a', 'fa', 'Har föreningen antagna stadgar och en vald styrelse?', 'آیا انجمن اساسنامه مصوب و هیئت‌مدیره منتخب دارد؟', '2026-08-29 00:51:27.048949+00');
INSERT INTO public.kb_translations VALUES
	('efc5284b-bfb0-4e15-8608-023219f38ba0', 'fa', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'آیا انجمن ساختار دموکراتیک دارد (اساسنامه، مجمع سالانه، هیئت‌مدیره)؟', '2026-08-29 00:51:27.048949+00'),
	('289bde04-fff9-446d-b58f-51ee79238d46', 'fa', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'آیا انجمن فعالیت منظمی برای کودکان یا جوانان دارد؟', '2026-08-29 00:51:27.048949+00'),
	('d30b31b2-bfa1-44fb-9ac3-6bfc50d22d29', 'fa', 'Har företaget mellan cirka 2 och 49 anställda?', 'آیا شرکت بین حدود ۲ تا ۴۹ کارمند دارد؟', '2026-08-29 00:51:27.048949+00'),
	('cc9b05e5-1f93-4979-b258-7b2ac22f766a', 'fa', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'آیا خانوار در تأمین هزینه‌های خوراک، مسکن و ضروری‌ترین چیزها مشکل دارد؟', '2026-08-29 00:51:27.048949+00'),
	('68c64d1d-24b1-4ab8-b424-6633eba59c67', 'fa', 'Har lösningen internationell potential?', 'آیا راه‌حل ظرفیت بین‌المللی دارد؟', '2026-08-29 00:51:27.048949+00'),
	('ff1fb56f-0770-482b-962b-a7370aac33ee', 'fa', 'Har ni en partnergrupp i ett annat land?', 'آیا گروه شریکی در کشور دیگری دارید؟', '2026-08-29 00:51:27.048949+00'),
	('55eccc21-2211-46d7-ae93-786b76daabc6', 'fa', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'آیا سازمان شریکی در کشور اروپایی دیگری دارید؟', '2026-08-29 00:51:27.048949+00'),
	('a5fe4276-ba39-4544-8ac6-0ee6c0590274', 'fa', 'Har ni partner i minst tre olika europeiska länder?', 'آیا در دست‌کم سه کشور اروپایی مختلف شریک دارید؟', '2026-08-29 00:51:27.048949+00'),
	('8e8e16fa-1785-4d58-8915-616443dc7aa9', 'fa', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'آیا دفتر مرکزی یا فعالیت اصلی شما در منطقه‌ای است که در آن درخواست می‌دهید؟', '2026-08-29 00:51:27.048949+00'),
	('df1ab2aa-41f5-49fd-b100-cb9929acdabb', 'fa', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'آیا یکی از فرزندانتان معلولیتی دارد که باعث می‌شود به مراقبت یا نظارت بیشتری از کودکان هم‌سن نیاز داشته باشد؟', '2026-08-29 00:51:27.048949+00'),
	('8e9193e9-f7e6-4102-8346-7fbd7a519e06', 'fa', 'Har organisationen en demokratisk uppbyggnad?', 'آیا سازمان ساختار دموکراتیک دارد؟', '2026-08-29 00:51:27.048949+00'),
	('d738cb6e-5185-4a59-9565-829b5988fd08', 'fa', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'آیا سازمان Quality Label (نشان کیفیت) دارد؟', '2026-08-29 00:51:27.048949+00'),
	('aeed3c1a-93a0-43c2-a9a3-ae1d02a8b870', 'fa', 'Har organisationen ett 90-konto?', 'آیا سازمان 90-konto دارد؟', '2026-08-29 00:51:27.048949+00'),
	('a1af925f-d753-41e5-8f80-5ceb27f0fb2a', 'fa', 'Har organisationen ett OID (Organisation ID)?', 'آیا سازمان OID (Organisation ID) دارد؟', '2026-08-29 00:51:27.048949+00'),
	('15ad997e-b294-4df4-9271-2c758c274e90', 'fa', 'Har organisationen ett OID?', 'آیا سازمان OID دارد؟', '2026-08-29 00:51:27.048949+00'),
	('90f8bd81-9577-4496-8ba8-3110cd75dc9c', 'fa', 'Har organisationen medlemsföreningar i flera län?', 'آیا سازمان انجمن‌های عضو در چند استان دارد؟', '2026-08-29 00:51:27.048949+00'),
	('6c6f6e41-28cd-40fb-9c8d-6b5d8eba71f0', 'fa', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'آیا سازمان مالی منظم و ساختار دموکراتیک دارد؟', '2026-08-29 00:51:27.048949+00'),
	('33fca5fd-3dea-4200-9ba7-e9e32edf4e7d', 'fa', 'Har projektet en partner i ett annat land?', 'آیا پروژه شریکی در کشور دیگری دارد؟', '2026-08-29 00:51:27.048949+00'),
	('d3c41b28-6ac7-4e98-841c-190cd68cef0f', 'fa', 'Har projektledaren doktorsexamen?', 'آیا سرپرست پروژه مدرک دکترا دارد؟', '2026-08-29 00:51:27.048949+00'),
	('c305f6e3-1142-4709-96d2-ddd59ea458f1', 'fa', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'شهرداری محل سکونت باید رفت‌وآمد روزانه میان خانه و دبیرستان را وقتی مسیر دست‌کم شش کیلومتر است تأمین کند (مثلاً کارت اتوبوس).', '2026-08-29 00:51:27.048949+00'),
	('b9f61222-0c07-44f4-b24b-f368d471b236', 'fa', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'آیا در حال تهیه یا تجهیز نخستین خانه شخصی خود در سوئد هستید؟', '2026-08-29 00:51:27.048949+00'),
	('a64bc6f1-fb4b-4802-9402-6a56b21603d2', 'fa', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'آیا پروژه شامل سفر یا تبادل بین‌المللی است؟', '2026-08-29 00:51:27.048949+00'),
	('6bfdc203-3b60-4acf-8339-acdea1c2cb21', 'fa', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'حمایت سرمایه‌گذاری از شرکت‌ها در مناطق حمایتی برای ساختمان، ماشین‌آلات و آموزش.', '2026-08-29 00:51:27.048949+00'),
	('0c887bed-3f85-4e9a-aa2b-6c18454e27cc', 'fa', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'حمایت سرمایه‌گذاری از اقداماتی که انتشار گازهای گلخانه‌ای را کاهش می‌دهند.', '2026-08-29 00:51:27.048949+00'),
	('1dcad865-201f-439d-af28-2ca4787fe1b4', 'fa', 'Kan projektets miljönytta mätas?', 'آیا فایده زیست‌محیطی پروژه قابل اندازه‌گیری است؟', '2026-08-29 00:51:27.048949+00'),
	('2a8cbf4e-ef95-4948-b2f3-c2da21735827', 'fa', 'Kan åtgärdens utsläppsminskning beräknas?', 'آیا کاهش انتشار حاصل از اقدام قابل محاسبه است؟', '2026-08-29 00:51:27.048949+00'),
	('a6a2fb0a-ac09-4a85-a511-8c4224923f98', 'fa', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'آیا سازمان می‌تواند هزینه‌ها را تا پرداخت حمایت بر عهده بگیرد؟', '2026-08-29 00:51:27.048949+00'),
	('235adf7e-ae6f-4924-b4ca-fb8ceac4ef09', 'fa', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'آیا تجربه‌ها در فعالیت شما در سوئد به کار گرفته می‌شوند؟', '2026-08-29 00:51:27.048949+00'),
	('bd52d636-3670-4e7c-9583-3a510b788611', 'fa', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'آیا سرمایه‌گذاری تنها پس از ارسال درخواست آغاز می‌شود؟', '2026-08-29 00:51:27.048949+00'),
	('7f2e2b18-bf9d-4295-af5b-24ed373e7ce3', 'fa', 'Kommer projektet människor i ert närområde till del?', 'آیا پروژه به مردم منطقه شما سود می‌رساند؟', '2026-08-29 00:51:27.048949+00'),
	('612d0ede-655b-4476-b93f-f19432abfb05', 'fa', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'واپسین تور ایمنی اقتصادی شهرداری وقتی درآمدها کفاف ضروری‌ترین چیزها را نمی‌دهند.', '2026-08-29 00:51:27.048949+00'),
	('ee63f225-c05e-4363-9d54-2a6457e570cb', 'fa', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'حمایت شروع برای کسی که ۴۰ ساله یا جوان‌تر است و بنگاه کشاورزی راه می‌اندازد یا تحویل می‌گیرد.', '2026-08-29 00:51:27.048949+00'),
	('ca865eb8-83c2-4441-bcda-0a4065e717ed', 'fa', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'حمایت‌های خود شهرداری‌ها از انجمن‌های محلی: کمک‌هزینه فعالیت به ازای هر جلسه، کمک‌هزینه محل، کمک‌هزینه شروع و غیره.', '2026-08-29 00:51:27.048949+00'),
	('5fb39121-f5fd-4a08-a350-77e75c130942', 'fa', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'سرویس رایگان مدرسه برای دانش‌آموزان ابتدایی در صورت مسافت طولانی، مسیر پرخطر یا معلولیت — حقی طبق قانون مدارس.', '2026-08-29 00:51:27.048949+00'),
	('8531aad8-8b64-4481-8fa2-c20ff427fd88', 'fa', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'کمک‌هزینه قانونی عینک یا لنز برای کودکان و جوانان؛ مبالغ و روال‌ها در هر استان متفاوت است — سطح استان خود را بررسی کنید.', '2026-08-29 00:51:27.048949+00'),
	('e3b1864d-b645-44a2-ae1a-78122f8c247c', 'fa', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'آیا پروژه در منطقه‌ای است که برق‌آبی یا بادی به آن مربوط می‌شود؟', '2026-08-29 00:51:27.048949+00'),
	('e9dad974-4d16-46d7-98b3-fe6617362681', 'fa', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'آیا پروژه در حوزه محیط‌زیست، علوم کشاورزی یا شهرسازی است؟', '2026-08-29 00:51:27.048949+00'),
	('40ece39e-f889-4e31-94a1-7d29f440bcd3', 'fa', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'آیا محل فعالیت در منطقه حمایتی A یا B است (بخش‌های بزرگ نورلند و سوئالند داخلی)؟', '2026-08-29 00:51:27.048949+00'),
	('7e5fe59c-e5f9-4f5a-926d-9ab12ce8fd4a', 'fa', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'وامی برای خرید ضروری‌ترین چیزها برای نخستین خانه در سوئد — مبلمان، لوازم خانه و دیگر تجهیزات پایه.', '2026-08-29 00:51:27.048949+00'),
	('6794f433-d226-4e0e-a93d-1888e8fbba6d', 'fa', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'آیا پروژه انتشار فرایندی صنعت را کاهش می‌دهد یا انتشار منفی ایجاد می‌کند؟', '2026-08-29 00:51:27.048949+00'),
	('ab474f46-11d7-4aee-96d2-2abba3e96d7f', 'fa', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'کمک‌هزینه ماهانه برای کودکان ساکن سوئد، از تولد تا ۱۶ سالگی.', '2026-08-29 00:51:27.048949+00'),
	('620a3541-5928-4df0-8035-8abe271e04ab', 'fa', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket به سازمان‌ها، شرکت‌ها، انجمن‌ها، بخش عمومی و اشخاص در حوزه محیط‌زیست کمک‌هزینه می‌دهد.', '2026-08-29 00:51:27.048949+00'),
	('d900401b-afea-4294-9d06-5ee456cc20a2', 'fa', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'آیا قصد دارید داوطلبانه برای همیشه به کشور مبدأ بازگردید؟', '2026-08-29 00:51:27.048949+00'),
	('a319dae9-9ea1-4150-bc25-e5b2dc71749f', 'fa', 'Planerar du att starta eget företag?', 'آیا قصد دارید کسب‌وکار خود را راه بیندازید؟', '2026-08-29 00:51:27.048949+00'),
	('22b23166-6efb-47c8-ae61-bfc637fa89af', 'fa', 'Planerar du att studera utomlands?', 'آیا قصد تحصیل در خارج را دارید؟', '2026-08-29 00:51:27.048949+00'),
	('431a6c03-f0e2-4e25-8759-292afee99678', 'fa', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'آیا قصد تحصیلی دارید که جایگاه شما را در بازار کار تقویت کند؟', '2026-08-29 00:51:27.048949+00'),
	('c0eab29d-0017-476d-9ba2-00b75beb1b98', 'fa', 'Planerar ni att anställa?', 'آیا قصد استخدام دارید؟', '2026-08-29 00:51:27.048949+00'),
	('af2ce6a1-fa7c-43b5-b128-a11b1c6f74c7', 'fa', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'آیا قصد دارید برای برنامه‌ای از اتحادیه اروپا (مثلاً Horisont Europa) درخواست دهید؟', '2026-08-29 00:51:27.048949+00'),
	('a8b9ee21-bfab-4ea9-a1ed-c579baa20121', 'fa', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'حمایت از تولید و توسعه فیلم کوتاه و مستند.', '2026-08-29 00:51:27.048949+00'),
	('7248702c-d681-4250-8981-f32ba8f6c323', 'fa', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'کمک‌هزینه پروژه‌ای برای صحنه موسیقی مستقل: کنسرت، تولید و توسعه.', '2026-08-29 00:51:27.048949+00');
INSERT INTO public.kb_translations VALUES
	('23da2862-8baf-440e-b89a-703e528d1329', 'fa', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'کمک‌هزینه پروژه‌ای برای سازمان‌های غیرانتفاعی که با کودکان و جوانان و برای آنان کار می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('d30fbd3d-0e18-44d5-bb7b-949b6781ed40', 'fa', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'آیا پروژه بیان‌ها، روش‌ها یا همکاری‌های هنری تازه‌ای می‌آزماید؟', '2026-08-29 00:51:27.048949+00'),
	('7066444e-1b9d-4058-bfa4-0b06b1243c7a', 'fa', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'آیا تبادل ۵ تا ۲۱ روز طول می‌کشد (بدون روزهای سفر)؟', '2026-08-29 00:51:27.048949+00'),
	('a29a3f22-a041-4262-85ed-0ec9d95282fd', 'fa', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'حمایت‌های خود استان‌ها از پروژه‌ها و فعالیت‌های فرهنگی، در کنار کمک‌های ملی Kulturrådet.', '2026-08-29 00:51:27.048949+00'),
	('13ddd0a7-a9cb-4f7d-af72-3b7bb6243fef', 'fa', 'Riktar sig projektet till barn eller unga?', 'آیا پروژه کودکان یا جوانان را هدف می‌گیرد؟', '2026-08-29 00:51:27.048949+00'),
	('59e54aad-1d59-4d91-ba9a-6cf978048d1d', 'fa', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'آیا پروژه کودکان، جوانان، سالمندان یا افراد دارای معلولیت را هدف می‌گیرد؟', '2026-08-29 00:51:27.048949+00'),
	('43ee1dc2-ac1f-414f-9abc-8e30808c9c7d', 'fa', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'آیا فعالیت کودکان و جوانان (۷–۲۵ ساله) را هدف می‌گیرد؟', '2026-08-29 00:51:27.048949+00'),
	('8e59baf8-3c05-4a50-aa92-76acfda7d1ac', 'fa', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'آیا پس‌انداز یا دارایی‌ای ندارید که بتواند هزینه‌ها را بپوشاند؟', '2026-08-29 00:51:27.048949+00'),
	('5d0323cc-bfb2-4047-bf14-78a19f687681', 'fa', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'آیا با شرکایی در دست‌کم دو کشور شمال اروپای دیگر همکاری می‌کنید؟', '2026-08-29 00:51:27.048949+00'),
	('95085b76-71d0-4dba-81d3-6d116e42410c', 'fa', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'آیا برای یک اقدام توسعه‌ای تخصص بیرونی به کار می‌گیرید؟', '2026-08-29 00:51:27.048949+00'),
	('03fe44cb-8712-4453-9c63-57a11f31befa', 'fa', 'Sker mobiliteten till ett annat europeiskt land?', 'آیا تحرک به کشور اروپایی دیگری است؟', '2026-08-29 00:51:27.048949+00'),
	('16f51e81-da2a-46e1-88ac-b5515703e832', 'fa', 'Startar du eller tar du över företaget för första gången?', 'آیا برای نخستین بار کسب‌وکار را راه می‌اندازید یا تحویل می‌گیرید؟', '2026-08-29 00:51:27.048949+00'),
	('414d9c53-df78-4617-899e-8d9b3fa0763a', 'fa', 'Är du yrkesverksam konstnär?', 'آیا هنرمند حرفه‌ای هستید؟', '2026-08-29 00:51:27.048949+00'),
	('16022578-224e-4291-aac7-fded3e3fa2f1', 'fa', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'بورسیه‌ای که به هنرمندان حرفه‌ای امکان می‌دهد بر کار هنری تمرکز کنند.', '2026-08-29 00:51:27.048949+00'),
	('82338991-286e-42d1-a43d-5466631d97c1', 'fa', 'Studerar du, eller planerar du att börja studera?', 'آیا تحصیل می‌کنید یا قصد شروع تحصیل دارید؟', '2026-08-29 00:51:27.048949+00'),
	('c6405664-9054-4e24-a687-775e76f51b7c', 'fa', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'حمایت تحصیلی برای بزرگسالان شاغل که می‌خواهند برای تقویت جایگاه خود در بازار کار آموزش ببینند.', '2026-08-29 00:51:27.048949+00'),
	('99817f75-03c0-46fe-9492-92f58a8df814', 'fa', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'حمایت از سرمایه‌گذاری‌هایی که رقابت‌پذیری را افزایش یا اثرات زیست‌محیطی را در بنگاه‌های کشاورزی کاهش می‌دهند.', '2026-08-29 00:51:27.048949+00'),
	('7928b747-bc5e-4ff8-90fc-8ac3cf1329ae', 'fa', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'حمایتی وقتی کودکی نزد شما زندگی می‌کند و والد دیگر نفقه نمی‌پردازد.', '2026-08-29 00:51:27.048949+00'),
	('62e85396-ced4-4ab5-8365-e8348351e1fd', 'fa', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'حمایت از پروژه‌های سازمان‌های غیرانتفاعی برای مردم، محیط‌زیست و جهانی بهتر.', '2026-08-29 00:51:27.048949+00'),
	('cdd6ded4-a061-4e6d-a4dd-bc3c1f88e8af', 'fa', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'حمایت از گذار صنعت به سوی انتشار صفر گازهای گلخانه‌ای.', '2026-08-29 00:51:27.048949+00'),
	('ea8814b7-63cd-4882-bb93-05a154f81522', 'fa', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'حمایت از پروژه‌های هنری و فرهنگی با بُعد نوردیک و همکاری فرامرزی.', '2026-08-29 00:51:27.048949+00'),
	('e69fe767-4ce9-4df0-99f8-8870a0a09b80', 'fa', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'حمایت از پروژه‌های فرهنگی نوآورانه که بیان‌ها، روش‌ها یا همکاری‌های هنری تازه می‌آزمایند.', '2026-08-29 00:51:27.048949+00'),
	('aab38702-8a7f-4d19-afdf-39b1b3ffd0dd', 'fa', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'حمایت از پروژه‌های نوآورانه برای کودکان، جوانان، سالمندان و افراد دارای معلولیت.', '2026-08-29 00:51:27.048949+00'),
	('523b81b1-47b0-411b-ba4c-2c313b76a997', 'fa', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'حمایت از پروژه‌های همکاری در صحنه موسیقی مستقل.', '2026-08-29 00:51:27.048949+00'),
	('45f10789-3231-4900-b8fe-b0313b8f916d', 'fa', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'حمایت از پروژه‌های همکاری در فرهنگ و رسانه که دموکراسی و آزادی بیان را در سطح بین‌المللی تقویت می‌کنند.', '2026-08-29 00:51:27.048949+00'),
	('b5352a40-ffe9-4d8d-a93b-2d931c16d732', 'fa', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'آیا هدف پروژه تقویت دموکراسی، برابری یا آزادی بیان است؟', '2026-08-29 00:51:27.048949+00'),
	('00c98e4e-5011-44e8-9aa6-03251995a1a0', 'fa', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'آیا در کشور دیگری از اتحادیه اروپا یا منطقه اقتصادی اروپا دنبال کار می‌گردید یا پیشنهاد کاری گرفته‌اید؟', '2026-08-29 00:51:27.048949+00'),
	('45450925-9e46-4677-835e-8e39a259e575', 'fa', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقفی برای آنچه در دوره دوازده‌ماهه بابت هزینه‌های بیمار می‌پردازید — پس از آن frikort (کارت رایگان).', '2026-08-29 00:51:27.048949+00'),
	('a7212c10-fcaa-4f5c-9cb0-08bdae122b9b', 'fa', 'Tar du ut hel allmän pension?', 'آیا مستمری عمومی کامل خود را دریافت می‌کنید؟', '2026-08-29 00:51:27.048949+00'),
	('837a0a47-3b7d-4be4-89a2-0653c2bf2e4a', 'fa', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'افزودنی‌ای که بخشی از هزینه مسکن را برای کسی که مستمری و درآمد کم دارد می‌پوشاند.', '2026-08-29 00:51:27.048949+00'),
	('d1334e06-9d7a-475c-9e95-c6940af89da1', 'fa', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'کمک‌هزینه سازمانی سالانه برای سازمان‌های ملی کودکان و جوانان.', '2026-08-29 00:51:27.048949+00'),
	('81454d8d-64ee-4ef7-8633-cacddd9492b4', 'fa', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'اعتبار سالانه‌ای که مستقیماً نزد دندان‌پزشک یا بهداشت‌کار دهان کسر می‌شود.', '2026-08-29 00:51:27.048949+00'),
	('337d1f23-cb7c-44e2-9d37-d06386177a43', 'fa', 'Är bolaget yngre än cirka 5 år?', 'آیا عمر شرکت کمتر از حدود ۵ سال است؟', '2026-08-29 00:51:27.048949+00'),
	('c7425257-52b7-4076-9ba5-6245f271be62', 'fa', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'آیا شرکت‌کنندگان تبادل بین ۱۳ و ۳۰ سال دارند؟', '2026-08-29 00:51:27.048949+00'),
	('e447fb89-4dd4-4cdf-a354-c17f45900d06', 'fa', 'Är det här ert första EU-projekt?', 'آیا این نخستین پروژه اتحادیه اروپای شماست؟', '2026-08-29 00:51:27.048949+00'),
	('7d87bd95-d0e3-4d93-83fc-cacc6637c47f', 'fa', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'آیا برای شما (یا فرزندتان) جابه‌جایی مستقل یا سفر با اتوبوس و قطار بسیار دشوار است؟', '2026-08-29 00:51:27.048949+00'),
	('5bdfb019-168e-42c7-86fb-5c31874d5198', 'fa', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا درآمد شما کمتر از حدود ۲۵٬۰۰۰ کرون در ماه پیش از مالیات است؟', '2026-08-29 00:51:27.048949+00'),
	('f5437523-02a4-4742-86f0-110c53f85bad', 'fa', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'آیا آخرین تحصیل تمام‌شده شما مدرسه ابتدایی است، یا دبیرستانی که تمامش نکردید؟', '2026-08-29 00:51:27.048949+00'),
	('65ef7321-7669-4b4f-ac1c-547777a3f30f', 'fa', 'Är du 40 år eller yngre?', 'آیا ۴۰ ساله یا جوان‌تر هستید؟', '2026-08-29 00:51:27.048949+00'),
	('917ca047-dd36-46a6-afa4-c346440f5a86', 'fa', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'آیا به‌عنوان جوینده کار نزد Arbetsförmedlingen ثبت‌نام کرده‌اید؟', '2026-08-29 00:51:27.048949+00'),
	('dbe35dfc-ef20-4d7c-ac38-083d584023da', 'fa', 'Är du mellan 18 och 28 år?', 'آیا بین ۱۸ و ۲۸ سال دارید؟', '2026-08-29 00:51:27.048949+00'),
	('894f8fe8-f436-4c6d-860d-7d79948c6d27', 'fa', 'Är du mellan 19 och 29 år?', 'آیا بین ۱۹ و ۲۹ سال دارید؟', '2026-08-29 00:51:27.048949+00'),
	('16445214-31a4-474e-ba51-877c92918e7e', 'fa', 'Är du mellan 25 och 60 år?', 'آیا بین ۲۵ و ۶۰ سال دارید؟', '2026-08-29 00:51:27.048949+00'),
	('cab84729-683d-4889-925c-8951f0791a3a', 'fa', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'آیا به‌طور حرفه‌ای در حوزه فرهنگ فعالیت می‌کنید (مثلاً رقص، موسیقی، هنرهای نمایشی)؟', '2026-08-29 00:51:27.048949+00'),
	('e77fabe5-7286-4877-9d13-ef8809292b85', 'fa', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'آیا هنرمند حرفه‌ای هستید (نه آماتور و نه در آموزش پایه)؟', '2026-08-29 00:51:27.048949+00'),
	('60356158-8a4a-4b58-a72f-ed15e591371a', 'fa', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'آیا راه‌حل شما در مقایسه با آنچه موجود است اساساً نوآورانه است؟', '2026-08-29 00:51:27.052417+00'),
	('e4949263-b0eb-4f0d-8338-19e8369f6a3e', 'fa', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'آیا باشگاه به فدراسیون ورزشی تخصصی درون Riksidrottsförbundet وابسته است؟', '2026-08-29 00:51:27.052417+00'),
	('b09d2e30-9acd-4a75-b9e1-dedef76117f8', 'fa', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'آیا درآمد خانوار نسبت به هزینه مسکن پایین است؟', '2026-08-29 00:51:27.052417+00'),
	('60c7eb04-83d4-45fb-960b-3ac51cf26772', 'fa', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا درآمد جمعی خانوار کمتر از حدود ۲۵٬۰۰۰ کرون در ماه پیش از مالیات است؟', '2026-08-29 00:51:27.052417+00'),
	('505caa24-4b80-4086-b53c-da237b020246', 'fa', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'آیا اقدام یک پروژه مشخص است (نه فعالیت عادی)؟', '2026-08-29 00:51:27.052417+00');
INSERT INTO public.kb_translations VALUES
	('31c589cd-2f70-4b58-8ff5-a308384598f5', 'fa', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'آیا محل برای همه باز است — نه فقط اعضای خودتان؟', '2026-08-29 00:51:27.052417+00'),
	('06a940da-d59f-46a9-8a89-e86e75ed807d', 'fa', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'آیا دست‌کم ۶۰ درصد اعضا بین ۶ و ۲۵ سال دارند؟', '2026-08-29 00:51:27.052417+00'),
	('50b60fec-e1f9-4a5c-ae21-5aa2b8f71dca', 'fa', 'Är minst 60 % av medlemmarna under 26 år?', 'آیا دست‌کم ۶۰ درصد اعضا زیر ۲۶ سال هستند؟', '2026-08-29 00:51:27.052417+00'),
	('10678f93-a640-4d6a-9d11-19c0d8186190', 'fa', 'Är målgruppen delaktig i planering och genomförande?', 'آیا گروه هدف در برنامه‌ریزی و اجرا مشارکت دارد؟', '2026-08-29 00:51:27.052417+00'),
	('0545d074-29ea-45dc-bee0-a8a0bf7ca8c3', 'fa', 'Är ni ett förlag med professionell utgivning?', 'آیا ناشری با انتشار حرفه‌ای هستید؟', '2026-08-29 00:51:27.052417+00'),
	('a1859aa3-5a19-478f-b778-adc3548ce4c2', 'fa', 'Är ni huvudman för förskoleklass eller grundskola?', 'آیا مسئول یک کلاس پیش‌دبستانی یا مدرسه ابتدایی هستید؟', '2026-08-29 00:51:27.052417+00'),
	('0c1b1c9d-e5d1-4ec6-833e-a7546211d053', 'fa', 'Är organisationen registrerad i EU:s deltagarregister?', 'آیا سازمان در فهرست شرکت‌کنندگان اتحادیه اروپا ثبت شده است؟', '2026-08-29 00:51:27.052417+00'),
	('f66255b5-ea08-4799-9283-b10e98964082', 'fa', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'آیا پروژه یک پروژه سینمایی است (فیلم کوتاه یا مستند)؟', '2026-08-29 00:51:27.052417+00'),
	('b61740cf-0ce1-4535-befb-2dd9c69b8df5', 'fa', 'Är projektet ett konst- eller kulturprojekt?', 'آیا پروژه یک پروژه هنری یا فرهنگی است؟', '2026-08-29 00:51:27.052417+00'),
	('88d6194b-52cf-4351-81fe-628ab871532d', 'fa', 'Är projektet ett kulturprojekt?', 'آیا پروژه یک پروژه فرهنگی است؟', '2026-08-29 00:51:27.052417+00'),
	('7a5ee8a0-1e77-4f26-90ad-7507708e6624', 'fa', 'Är projektet ett musikprojekt?', 'آیا پروژه یک پروژه موسیقایی است؟', '2026-08-29 00:51:27.052417+00'),
	('af34ff64-4db3-464c-9625-8b368a772975', 'fa', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'آیا پروژه نوآورانه است — کاری که هم‌اکنون در فعالیت عادی انجام نمی‌دهید؟', '2026-08-29 00:51:27.052417+00'),
	('5d31f946-e94a-48dc-ae72-681cca93e80f', 'fa', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'آیا پروژه به کل منطقه سود می‌رساند (نه به اشخاص)؟', '2026-08-29 00:51:27.052417+00'),
	('09920f4a-170d-46f2-a51b-b2fdbdd128a5', 'fa', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'آیا مسیر میان خانه و دبیرستان دست‌کم شش کیلومتر است؟', '2026-08-29 00:51:27.052417+00'),
	('e2d0c916-a0e6-4868-b40f-2d77a1eba706', 'fa', 'Är verksamheten professionell (inte amatörverksamhet)?', 'آیا فعالیت حرفه‌ای است (نه آماتوری)؟', '2026-08-29 00:51:27.052417+00'),
	('335609be-2903-4e71-a8c3-5fda514d04be', 'fa', 'Är verksamheten professionell?', 'آیا فعالیت حرفه‌ای است؟', '2026-08-29 00:51:27.052417+00'),
	('30658d77-62be-4513-bfa2-9629ee6812a8', 'fa', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'آیا فعالیت از هنرهای نمایشی است (رقص، تئاتر، تئاتر موزیکال)؟', '2026-08-29 00:51:27.052417+00'),
	('afae12b8-8f4a-433e-a153-4434a3a6e1d5', 'fa', 'Är volontärerna mellan 18 och 30 år?', 'آیا داوطلبان بین ۱۸ و ۳۰ سال دارند؟', '2026-08-29 00:51:27.052417+00'),
	('6ef9f8da-d12b-4499-aa4d-45f9fea00d2d', 'prs', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'حمایت از فعالیت کلپ‌های ورزشی که فعالیت‌های زیر نظر مربی برای اطفال و جوانان ۷ تا ۲۵ ساله برگزار می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('302193e0-dde1-4baa-913e-4859d0731bc0', 'prs', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'اضافه خودکار بر کمک مالی اطفال (barnbidrag) از طفل دوم به بعد.', '2026-08-29 00:51:27.058206+00'),
	('c9723629-aa79-43fe-90e1-c23558dd08a8', 'prs', 'Avser ansökan en fysisk investering?', 'آیا درخواست مربوط به یک سرمایه‌گذاری فزیکی است؟', '2026-08-29 00:51:27.058206+00'),
	('62333376-3e3c-475d-a6cc-8014872f026f', 'prs', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'آیا درخواست مربوط به یک سفر یا تبادله بین‌المللی است؟', '2026-08-29 00:51:27.058206+00'),
	('532694fb-bab4-403c-b585-7cb1311c6ab1', 'prs', 'Avser ansökan en investering i byggnader eller maskiner?', 'آیا درخواست مربوط به سرمایه‌گذاری در تعمیرات یا ماشین‌آلات است؟', '2026-08-29 00:51:27.058206+00'),
	('b85895fc-aa60-4aa3-bb92-eeb8a57e72f1', 'prs', 'Avser ansökan en redan utgiven titel?', 'آیا درخواست مربوط به اثری است که قبلاً چاپ شده است؟', '2026-08-29 00:51:27.058206+00'),
	('79bfa3fb-03f1-4520-933b-769ff7fb2b24', 'prs', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'آیا درخواست مربوط به یک تشبث زراعتی، باغداری یا پرورش گوزن شمالی است؟', '2026-08-29 00:51:27.058206+00'),
	('4cbffd26-667a-4dc7-bdd5-711ef84ea10f', 'prs', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'آیا درخواست مربوط به خرید کتاب برای کتابخانه‌های عامه یا مکتب است؟', '2026-08-29 00:51:27.058206+00'),
	('3b3eab81-6e6d-4f63-8e9d-7455d449d1f9', 'prs', 'Avser investeringen jordbruksverksamhet?', 'آیا سرمایه‌گذاری مربوط به فعالیت زراعتی است؟', '2026-08-29 00:51:27.058206+00'),
	('12181e0f-9487-44ab-8025-59adb7c43426', 'prs', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'آیا پروژه شامل ساختن، خریدن یا ترمیم یک محل است؟', '2026-08-29 00:51:27.058206+00'),
	('48ad4685-baff-4c26-ad82-0d7e8198f8ba', 'prs', 'Avser projektet naturvård eller friluftsliv?', 'آیا پروژه مربوط به حفاظت از طبیعت یا تفریح در هوای آزاد است؟', '2026-08-29 00:51:27.058206+00'),
	('a40c0632-bc3e-455b-9319-d8b94e467635', 'prs', 'Avser projektet skola eller vuxenutbildning?', 'آیا پروژه مربوط به مکتب یا آموزش بزرگسالان است؟', '2026-08-29 00:51:27.058206+00'),
	('6e2714ea-a286-4759-a806-421cb61e6842', 'prs', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'آیا از کار دست می‌کشید تا از یکی از نزدیکان که چنان سخت مریض است که مریضی جانش را تهدید می‌کند مراقبت کنید یا در کنارش باشید؟', '2026-08-29 00:51:27.058206+00'),
	('05507fb6-c4eb-4f33-be4c-62c8f37a1935', 'prs', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'آیا انجمن در شاروالی فعالیت منظم دارد؟', '2026-08-29 00:51:27.058206+00'),
	('e53a99b0-939f-48ff-8bcc-5e86223a0909', 'prs', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'آیا فکر می‌کنید توان کاری‌تان به دلیل مریضی یا معلولیت دست‌کم برای یک سال کاهش یافته است؟', '2026-08-29 00:51:27.058206+00'),
	('a96354ae-fa37-4632-9378-a3b4faafbf00', 'prs', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'حمایت نیازسنجی‌شده برای کسی که تقاعد کم دارد یا ندارد و برای رسیدن به سطح زندگی مناسب به کمک ضرورت دارد.', '2026-08-29 00:51:27.058206+00'),
	('80cb863b-f66f-41fa-b4ee-c9b9e525beb0', 'prs', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'آیا طفل باید به دلیل درازی راه در محل درس اقامت کند (بودوباش)؟', '2026-08-29 00:51:27.058206+00'),
	('cf2a9369-0c71-4b2f-a451-d6d24324c6c6', 'prs', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'آیا منزل به مناسب‌سازی ضرورت دارد (مثلاً رمپ، بازکننده دروازه، تشناب)؟', '2026-08-29 00:51:27.058206+00'),
	('a52f644c-962c-4423-9448-42e8871a9174', 'prs', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'آیا یکی از اطفال ۸ تا ۱۹ ساله شما به عینک یا لنز ضرورت دارد؟', '2026-08-29 00:51:27.058206+00'),
	('448bfd3b-110d-476e-a5b0-a9bfa49795ae', 'prs', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'آیا والد دیگر هیچ نفقه نمی‌پردازد یا کمتر از نفقه کامل می‌پردازد؟', '2026-08-29 00:51:27.058206+00'),
	('3b848a65-67dc-4b4a-a3f3-24e5d0e7faa7', 'prs', 'Betalar du hyra eller andra boendekostnader?', 'آیا کرایه یا مصارف دیگر مسکن می‌پردازید؟', '2026-08-29 00:51:27.058206+00'),
	('7777b533-a8fc-46e7-b333-f1ded20260f2', 'prs', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'کمک مالی برای مناسب‌سازی منزل در صورت معلولیت — مثلاً رمپ، بازکننده دروازه یا مناسب‌سازی تشناب.', '2026-08-29 00:51:27.058206+00'),
	('88e6d438-0413-4635-adc0-1c2ce554e19d', 'prs', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'کمک‌های مالی برای ساختن، خریدن یا ترمیم سالون‌های اجتماعات عامه.', '2026-08-29 00:51:27.058206+00'),
	('fd9596c0-4737-4967-8fdd-05765eef99f2', 'prs', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'کمک مالی برای خرید یا مناسب‌سازی موتر وقتی معلولیت دایمی گشت‌وگذار یا سفر با ترانسپورت عامه را بسیار دشوار می‌سازد.', '2026-08-29 00:51:27.058206+00'),
	('db0b1fab-137f-46ab-86c8-21db1b69209a', 'prs', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'کمک‌های مالی برای سفرها و تبادله‌های بین‌المللی مسلکی‌های عرصه فرهنگ.', '2026-08-29 00:51:27.058206+00'),
	('382c2986-8647-432b-b5f1-1a63bf1c91c0', 'prs', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'کمک‌های مالی برای تبادله‌های بین‌المللی، سفرها و اقامت‌های کاری هنرمندان مسلکی.', '2026-08-29 00:51:27.058206+00'),
	('23b58144-16a7-4f47-89e2-8a0b8909fedd', 'prs', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'کمک مالی و قرضه اختیاری برای درس در سویه لیسه یا بالاتر از لیسه.', '2026-08-29 00:51:27.058206+00'),
	('f039e636-8620-470e-8294-5bb328465d41', 'prs', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'کمک‌های مالی و قرضه برای تحصیل در خارج، با قرضه‌های اضافی برای مثلاً فیس تحصیلی و سفر.', '2026-08-29 00:51:27.058206+00'),
	('276902b2-1738-432b-923e-a36503488901', 'prs', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'کمکی که به نهادهای سویدنی در آماده‌سازی درخواست برای برنامه‌های اتحادیه اروپا مانند Horisont Europa یاری می‌رساند.', '2026-08-29 00:51:27.058206+00'),
	('f9edff11-c534-4a1a-9146-3c97b554c660', 'prs', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'کمک مالی برای کارفرمایانی که افراد دارای توان کاری کاهش‌یافته را استخدام می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('4ed28b9b-e6c4-4650-adf0-24cabf039578', 'prs', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'کمک مالی برای بودوباش و سفرهای بازگشت به خانه وقتی شاگرد لیسه به دلیل درازی راه باید در محل درس اقامت کند.', '2026-08-29 00:51:27.058206+00'),
	('b6de6dc4-a3c7-4042-8ff4-6e1ef7865329', 'prs', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'کمک‌های مالی برای کار سازمان‌های غیرانتفاعی در حفظ، استفاده و انکشاف میراث فرهنگی.', '2026-08-29 00:51:27.058206+00');
INSERT INTO public.kb_translations VALUES
	('eee192a3-2603-4b58-9f9c-fc012494bd68', 'prs', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'کمک‌های مالی برای پروژه‌های شاروالی و محلی حفاظت از طبیعت، به شمول ساحات مرطوب و تفریح در هوای آزاد.', '2026-08-29 00:51:27.058206+00'),
	('6c2d9389-2586-4b4b-9e2c-7fd9b975b513', 'prs', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'کمک‌های مالی به شاروالی‌ها برای خرید کتاب برای کتابخانه‌های عامه و مکتب.', '2026-08-29 00:51:27.058206+00'),
	('5f02cb7c-0dd5-4309-b189-0aeaa559ce9e', 'prs', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'کمک‌های مالی به مسئولان مکاتب برای آشنایی شاگردان مکتب ابتداییه با فرهنگ مسلکی.', '2026-08-29 00:51:27.058206+00'),
	('de68a3d5-2e9b-45d7-acd7-60d110e455ce', 'prs', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'کمک مالی برای آنچه طفل‌تان ضرورت دارد اما بودجه فامیل کفایت نمی‌کند: فعالیت‌های تفریحی، لباس، سیرهای مکتب، عینک، فعالیت‌های رخصتی و غیره.', '2026-08-29 00:51:27.058206+00'),
	('0c780234-cfb6-4a0c-a595-1120ec07a4a5', 'prs', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'کمک‌های مالی از صندوق‌هایی مانند Världens Barn و Musikhjälpen و Victoriafonden — سازمان‌های غیرانتفاعی سویدنی دارای 90-konto آن را درخواست می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('c546c986-d8a8-482e-a100-7d5b4f0c13ea', 'prs', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'کمک‌های مالی از عواید برق آبی و بادی برای پروژه‌هایی که منطقه را انکشاف می‌دهند.', '2026-08-29 00:51:27.058206+00'),
	('ca9cd968-772f-4f21-baf2-5e71ad0a7371', 'prs', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'کمک مالی بدون بخش قرضه برای بیکاران ۲۵ تا ۶۰ ساله با تحصیلات کوتاه که باید در سویه مکتب ابتداییه یا لیسه درس بخوانند.', '2026-08-29 00:51:27.058206+00'),
	('70e9abce-c3ad-43de-9570-70fab608c40c', 'prs', 'Bidrar projektet till energiomställningen?', 'آیا پروژه به گذار انرژی کمک می‌کند؟', '2026-08-29 00:51:27.058206+00'),
	('3867bffc-71b2-4b65-a1dd-9563c5741629', 'prs', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'چک‌هایی برای شرکت‌های کوچک برای جلب تخصص بیرونی در بین‌المللی‌سازی یا دیجیتل‌سازی.', '2026-08-29 00:51:27.058206+00'),
	('f35db23e-a06e-4f23-b19a-a38474a88229', 'prs', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'آیا در برنامه‌ای نزد Arbetsförmedlingen شرکت می‌کنید (مثلاً jobb- och utvecklingsgarantin)؟', '2026-08-29 00:51:27.058206+00'),
	('a8b9d6a3-1b58-431e-8ae8-2a1cfb549700', 'prs', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'حمایت بعدی از ناشران برای چاپ ادبیات باکیفیت.', '2026-08-29 00:51:27.058206+00'),
	('d475c5d4-6561-4057-93a8-4a9873ea6d87', 'prs', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'حمایت مالی برای کسی که جواز اقامت مرتبط با حمایت دارد و داوطلبانه می‌خواهد برای همیشه به کشور اصلی خود برگردد.', '2026-08-29 00:51:27.058206+00'),
	('e78cb5af-85a5-44c5-971a-9df6e5d729ef', 'prs', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'حمایت مالی از کارفرمایانی که کسی را استخدام می‌کنند که مدت زیادی از زندگی کاری دور بوده است.', '2026-08-29 00:51:27.058206+00'),
	('73daee65-daef-4555-93b1-c471af53a5a6', 'prs', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'حمایت مالی در دوره آغاز برای جویندگان کار که تشبث خود را شروع می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('bc8f287e-74f5-4b9d-947d-6517e460a508', 'prs', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten به‌طور دوامدار فراخوان‌هایی در تحقیقات انرژی، نوآوری و مؤثریت انرژی باز می‌کند.', '2026-08-29 00:51:27.058206+00'),
	('2763b067-7ad0-4d1e-bfb1-d6f2a2018c1d', 'prs', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'پرداختی برای غیرحاضری از کار یا درس به‌خاطر مراقبت از طفل.', '2026-08-29 00:51:27.058206+00'),
	('4d4aab61-cdff-4de9-b117-9fc5737721ff', 'prs', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'پرداختی برای کسی که تازه‌وارد سویدن است و در برنامه استقرار Arbetsförmedlingen شرکت می‌کند؛ توسط Försäkringskassan پرداخت می‌شود.', '2026-08-29 00:51:27.058206+00'),
	('355275cf-a6c1-45c1-88b4-9e0272e76a26', 'prs', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'پرداختی که بخشی از مصارف مسکن جوانان بدون اطفال با عاید کم را می‌پوشاند.', '2026-08-29 00:51:27.058206+00'),
	('bfa573f9-1eff-41c5-8e07-0f54b01b9123', 'prs', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'پرداختی برای مصارف اضافی ناشی از معلولیت دایمی — برای بزرگسالان یا والدین اطفال دارای معلولیت.', '2026-08-29 00:51:27.058206+00'),
	('61b5f379-7d7c-48b0-bade-69cd038464a1', 'prs', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'پرداختی برای جوانان (۱۹–۲۹ ساله) که به دلیل مریضی یا معلولیت دست‌کم یک سال نمی‌توانند تمام‌وقت کار کنند.', '2026-08-29 00:51:27.058206+00'),
	('ec5e482f-c10a-4d9f-ab40-e7647147b525', 'prs', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'پرداختی وقتی توان کاری به‌طور دایمی کاهش یافته است — آنچه پیش‌تر förtidspension (تقاعد پیش از وقت) نامیده می‌شد.', '2026-08-29 00:51:27.058206+00'),
	('bca77f3a-daf0-4c1d-8a44-b9560cd31ec3', 'prs', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'پرداختی وقتی از کار دست می‌کشید تا در کنار یکی از نزدیکانِ سخت مریض باشید.', '2026-08-29 00:51:27.058206+00'),
	('d9110d3e-4029-4116-b23f-482878c425c6', 'prs', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'پرداختی هنگام شرکت شما در برنامه بازار کار نزد Arbetsförmedlingen.', '2026-08-29 00:51:27.058206+00'),
	('8e258678-1ef6-4fe6-b521-4e4de0cc2897', 'prs', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'پرداختی وقتی به دلیل مریضی نمی‌توانید مانند معمول کار کنید.', '2026-08-29 00:51:27.058206+00'),
	('9f794c6e-e4a8-4bc3-a37c-4587bba3a02b', 'prs', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'پرداختی وقتی برای مراقبت از طفل مریض در خانه می‌مانید.', '2026-08-29 00:51:27.058206+00'),
	('004c0eed-9f69-4c90-ba4a-96de6d4fbfa3', 'prs', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'پرداختی که بخشی از مصارف مسکن فامیل‌های دارای اطفال و عاید پایین‌تر را می‌پوشاند.', '2026-08-29 00:51:27.058206+00'),
	('10a87f9e-cda7-432b-aa05-16495b317a90', 'prs', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'پرداختی برای والدینی که طفل‌شان به دلیل معلولیت به مراقبت و نظارت بیشتری نسبت به اطفال هم‌سن ضرورت دارد.', '2026-08-29 00:51:27.058206+00'),
	('0c779b9b-5910-4de7-aaf4-dc9128a74e32', 'prs', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'پرداختی در دوران بیکاری — بر اساس عاید برای اعضا، مبلغ اساسی برای دیگران.', '2026-08-29 00:51:27.058206+00'),
	('490b5209-ad78-4faa-bf7e-7cb62d923cd0', 'prs', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'در حدود پنجاه بنیاد بانک‌های پس‌انداز به پروژه‌های محلی در ورزش، فرهنگ، تعلیم و انکشاف اجتماعی کمک مالی می‌دهند — در ساحه فعالیت بانک.', '2026-08-29 00:51:27.058206+00'),
	('6a004448-e70f-4949-ace7-1830ee2fae4f', 'prs', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'حمایت پروژه‌ای با بودجه اتحادیه اروپا که نزد ساحه Leader محلی شما درخواست می‌شود — برای انجمن‌ها، شرکت‌ها و شاروالی‌هایی که دهات را انکشاف می‌دهند.', '2026-08-29 00:51:27.058206+00'),
	('5d9ba3e8-9e84-49e3-8217-0e5360c94661', 'prs', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'حمایت با بودجه اتحادیه اروپا برای جویندگان کار که در کشور دیگری از اتحادیه اروپا/ساحه اقتصادی اروپا وظیفه می‌گیرند: جبران مصارف سفر مصاحبه، مصارف کوچ‌کشی و کورس زبان.', '2026-08-29 00:51:27.058206+00'),
	('c1188250-6967-4de7-a6c3-b0201c1ab5e8', 'prs', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'بودجه صندوق اجتماعی اروپا برای پروژه‌هایی که مهارت‌ها، گذار وظیفوی و شمولیت در بازار کار را تقویت می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('73f608f6-41db-4919-870d-b767d2b1ad57', 'prs', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'حمایت اتحادیه اروپا از تبادله‌های گروهی جوانان ۱۳ تا ۳۰ ساله، برای ۵ تا ۲۱ روز بدون روزهای سفر.', '2026-08-29 00:51:27.058206+00'),
	('82602947-5c33-406a-aea1-9a4e39652ea7', 'prs', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'حمایت اتحادیه اروپا از پروژه‌های همکاری سازمان‌های فرهنگی با شرکایی در چند کشور اروپایی.', '2026-08-29 00:51:27.058206+00'),
	('9c396289-08f2-462e-bd61-6a89390e51f6', 'prs', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'حمایت اتحادیه اروپا از سازمان‌هایی که رضاکاران جوان ۱۸ تا ۳۰ ساله را می‌پذیرند یا می‌فرستند.', '2026-08-29 00:51:27.058206+00'),
	('930596b4-9bfd-4ed7-9a17-e9359322e045', 'prs', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'حمایت اتحادیه اروپا از تحرک کارمندان و شاگردان در مکتب و آموزش بزرگسالان.', '2026-08-29 00:51:27.058206+00'),
	('e386ef90-0196-4dc6-b043-acb25b2de962', 'prs', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'حمایت اتحادیه اروپا با مبالغ مقطوع برای نخستین پروژه‌های همکاری اروپایی سازمان‌های کوچک‌تر.', '2026-08-29 00:51:27.058206+00'),
	('803ebe3d-c472-4c12-a1d9-84e2fd60c434', 'prs', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'تمویل شرکت‌های جوانی که محصولات یا خدمات نوآورانه با ظرفیت بین‌المللی انکشاف می‌دهند.', '2026-08-29 00:51:27.058206+00'),
	('aaa171e4-8cb9-4888-818b-b0d06c4e1103', 'prs', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'آیا در محل فعالیت شما بانک پس‌اندازی (و در نتیجه بنیاد بانک پس‌انداز) وجود دارد؟', '2026-08-29 00:51:27.058206+00'),
	('9ffecb6f-d3d1-45fd-9a3f-39c5af387b9e', 'prs', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'کمک‌های مالی فعالیت چندساله برای گروه‌های مستقل مسلکی رقص، تیاتر و تیاتر موزیکال.', '2026-08-29 00:51:27.058206+00'),
	('0da6f260-a2fa-439c-a395-2c619a04cbee', 'prs', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'کمک‌های مالی تحقیقاتی در عرصه‌های Forte: صحت، زندگی کاری و رفاه. محققان دارای دوکتورا در پوهنتون‌های سویدن درخواست می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('bbab96c7-177b-4c5e-b050-3dbc8aec463a', 'prs', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'بودجه تحقیقاتی برای تحقیقات بنیادی آزاد در همه عرصه‌های علمی.', '2026-08-29 00:51:27.058206+00'),
	('f5ce3746-c960-47b6-ab86-a25eb7adcb39', 'prs', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'بودجه تحقیقاتی در محیط‌زیست، علوم زراعتی و شهرسازی.', '2026-08-29 00:51:27.058206+00'),
	('4e7d32c2-d3d0-4585-8864-746aef0534b2', 'prs', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'آیا در فکر رفتن به خارج هستید (برای کار، تحصیل یا بازگشت به وطن)؟', '2026-08-29 00:51:27.058206+00'),
	('64f82493-0026-402b-a1ad-f3be362ea524', 'prs', 'Genomförs insatserna av professionella kulturaktörer?', 'آیا فعالیت‌ها را کنشگران فرهنگی مسلکی اجرا می‌کنند؟', '2026-08-29 00:51:27.058206+00'),
	('69f1b379-94db-488c-b7e9-3ffd3201fcd6', 'prs', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'آیا پروژه در دهات یا در قصبه کوچکی اجرا می‌شود؟', '2026-08-29 00:51:27.058206+00'),
	('5fd1f8f7-2d3a-452a-b5b5-383794a1db77', 'prs', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'حمایت اساسی برای کسی که در طول زندگی عاید کاری کم یا هیچ نداشته است.', '2026-08-29 00:51:27.058206+00'),
	('49fa77b3-a033-4475-8ff3-983f9f7f6411', 'prs', 'Går något av dina barn i grundskolan?', 'آیا یکی از اطفال‌تان به مکتب ابتداییه می‌رود؟', '2026-08-29 00:51:27.058206+00'),
	('35da2b67-9a66-4426-92b9-87b6eb74dba8', 'prs', 'Går något av dina barn på gymnasiet?', 'آیا یکی از اطفال‌تان در لیسه درس می‌خواند؟', '2026-08-29 00:51:27.058206+00'),
	('b28088c6-60d4-4cdf-a44b-170c18471fb8', 'prs', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'آیا استخدام مربوط به فردی با توان کاری کاهش‌یافته است؟', '2026-08-29 00:51:27.058206+00');
INSERT INTO public.kb_translations VALUES
	('5aa62ae5-c01a-4efe-a093-30619de06008', 'prs', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'آیا استخدام مربوط به کسی است که مدت زیادی بیکار بوده یا تازه‌وارد سویدن است؟', '2026-08-29 00:51:27.058206+00'),
	('6016ceb5-630b-43ca-b6c9-788fdda17922', 'prs', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'آیا پروژه درباره حفظ میراث فرهنگی یا دسترس‌پذیر ساختن آن است؟', '2026-08-29 00:51:27.058206+00'),
	('aecc2829-24a9-4710-8998-20330825100a', 'prs', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'آیا پروژه درباره انرژی، مؤثریت انرژی یا نوآوری مرتبط با انرژی است؟', '2026-08-29 00:51:27.058206+00'),
	('0d6825c0-f3db-41d3-86b7-3a4e30559d68', 'prs', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'آیا پروژه درباره صحت، زندگی کاری یا رفاه است؟', '2026-08-29 00:51:27.058206+00'),
	('63852aac-9e39-424f-96d4-6071a15eb3c3', 'prs', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'آیا پروژه درباره انکشاف مهارت‌ها یا اقدامات بازار کار است؟', '2026-08-29 00:51:27.058206+00'),
	('a4fef619-9de3-4fb8-a2f8-a3110e61c09e', 'prs', 'Handlar projektet om miljö- eller klimatåtgärder?', 'آیا پروژه درباره اقدامات محیط‌زیستی یا اقلیمی است؟', '2026-08-29 00:51:27.058206+00'),
	('5704796b-dfa0-4308-b05a-3e8c5739e47b', 'prs', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'آیا راه طفل به مکتب دراز، به دلیل ترافیک خطرناک یا به شکل دیگری دشوار است؟', '2026-08-29 00:51:27.058206+00'),
	('41d31fd6-9e56-461c-a88a-df89dc44b3ad', 'prs', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'آیا دست‌کم ۱۶ ساعت در هفته و در مجموع دست‌کم ۸ سال کار کرده‌اید؟', '2026-08-29 00:51:27.058206+00'),
	('e1753c7c-07d9-49b8-adeb-76fb3055b8ba', 'prs', 'Har du barn som bor hos dig, helt eller växelvis?', 'آیا اطفالی دارید که نزد شما زندگی می‌کنند، تمام‌وقت یا به نوبت؟', '2026-08-29 00:51:27.058206+00'),
	('d9ac068f-1208-4405-ad75-fee785df6647', 'prs', 'Har du barn som bor hos dig?', 'آیا اطفالی دارید که نزد شما زندگی می‌کنند؟', '2026-08-29 00:51:27.058206+00'),
	('cf18d917-760f-44b7-87a5-1e0af17a257c', 'prs', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'آیا شما یا طفل‌تان معلولیتی دارید که انتظار می‌رود دست‌کم یک سال دوام کند؟', '2026-08-29 00:51:27.058206+00'),
	('8d0e7bc7-719b-42bc-a7ad-9b55c8d9dcf0', 'prs', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'آیا شما یا کسی در فامیل معلولیت دایمی دارد که بر مسکن اثر می‌گذارد؟', '2026-08-29 00:51:27.058206+00'),
	('8375e22a-8960-4b6d-90f8-e79c552dc110', 'prs', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'آیا شما یا یکی از نزدیکان معلولیت یا مریضی طولانی یا جدی دارید؟', '2026-08-29 00:51:27.058206+00'),
	('07917e19-ef28-4525-bab7-b6adcd5208d7', 'prs', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'آیا مریضی یا آسیبی دارید که فعلاً توان کاری شما را کاهش می‌دهد؟', '2026-08-29 00:51:27.058206+00'),
	('10f196cf-7e9f-42c9-b933-25dad5432ac6', 'prs', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'آیا تا حال در پرداخت مصارف سیر مکتب، سفر صنفی یا فعالیت تفریحی که انتظار می‌رود طفل‌تان در آن شرکت کند مشکل داشته‌اید؟', '2026-08-29 00:51:27.058206+00'),
	('01c3b425-c570-431d-bdef-fae9e660583e', 'prs', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'آیا گذران زندگی با تقاعد و عواید دیگرتان برای‌تان دشوار است؟', '2026-08-29 00:51:27.058206+00'),
	('f01cf8f5-d921-4aea-a5ae-9d8b50cae504', 'prs', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'آیا در سال‌های اخیر جواز اقامت در سویدن گرفته‌اید، مثلاً به‌عنوان نیازمند حمایت یا عضو فامیل؟', '2026-08-29 00:51:27.058206+00'),
	('5da4698c-f2dc-495a-9acf-4ce01c7d1d96', 'prs', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'آیا جواز اقامت در سویدن به‌عنوان پناهنده یا نیازمند حمایت دارید (یا از اقارب نزدیک چنین کسی هستید)؟', '2026-08-29 00:51:27.058206+00'),
	('a78538e5-41f3-4a0e-b7ab-217fa114674d', 'prs', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'آیا به سن معیاری تقاعد رسیده‌اید (۶۷ سال در ۲۰۲۶)؟', '2026-08-29 00:51:27.058206+00'),
	('69c1dbf9-f0e5-4623-9670-7d2bdf518f15', 'prs', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'آیا سازمان شما OID (Organisation ID) ثبت‌شده در Organisation Registration System اتحادیه اروپا دارد؟', '2026-08-29 00:51:27.058206+00'),
	('f2e2b1da-958a-4a40-8afd-5679320e7b63', 'prs', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'آیا معلولیت مصارف اضافی به بار آورده است — مثلاً وسایل کمکی، سفر، غذای خاص یا استهلاک؟', '2026-08-29 00:51:27.058206+00'),
	('8ba8a6f8-8149-45b5-aad2-8db49f6ccaec', 'prs', 'Har föreningen antagna stadgar och en vald styrelse?', 'آیا انجمن اساسنامه تصویب‌شده و هیئت اداری انتخاب‌شده دارد؟', '2026-08-29 00:51:27.058206+00'),
	('55606a47-974b-4894-91ec-f8e249fc58e2', 'prs', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'آیا انجمن ساختار دموکراتیک دارد (اساسنامه، مجمع سالانه، هیئت اداری)؟', '2026-08-29 00:51:27.058206+00'),
	('637b5e7d-2cf5-44ef-abcf-d27ec5352c0e', 'prs', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'آیا انجمن فعالیت منظمی برای اطفال یا جوانان دارد؟', '2026-08-29 00:51:27.058206+00'),
	('1eb029f6-7044-47a5-9cee-b66cfee74848', 'prs', 'Har företaget mellan cirka 2 och 49 anställda?', 'آیا شرکت بین تقریباً ۲ تا ۴۹ کارمند دارد؟', '2026-08-29 00:51:27.058206+00'),
	('b85f9fbc-fa92-4101-b3fd-eef3f93196d1', 'prs', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'آیا فامیل در تأمین مصارف خوراک، مسکن و ضروری‌ترین چیزها مشکل دارد؟', '2026-08-29 00:51:27.058206+00'),
	('b091414f-6aad-4310-9332-77a9e7925f02', 'prs', 'Har lösningen internationell potential?', 'آیا راه‌حل ظرفیت بین‌المللی دارد؟', '2026-08-29 00:51:27.058206+00'),
	('ad1ed148-c8e2-4ada-9539-c162bd7db3ec', 'prs', 'Har ni en partnergrupp i ett annat land?', 'آیا گروه شریکی در کشور دیگری دارید؟', '2026-08-29 00:51:27.058206+00'),
	('08600913-18f5-42f4-af31-cbbbc9449637', 'prs', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'آیا سازمان شریکی در کشور اروپایی دیگری دارید؟', '2026-08-29 00:51:27.058206+00'),
	('be242bc1-c6f1-46d2-86ae-63885fe8d4c2', 'prs', 'Har ni partner i minst tre olika europeiska länder?', 'آیا در دست‌کم سه کشور مختلف اروپایی شریک دارید؟', '2026-08-29 00:51:27.058206+00'),
	('8ca1b73c-cecb-4d06-b556-392e0806f246', 'prs', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'آیا دفتر یا فعالیت اصلی شما در ولایتی است که در آن درخواست می‌دهید؟', '2026-08-29 00:51:27.058206+00'),
	('b977786d-e15b-4f74-ad54-cba7d50a9c95', 'prs', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'آیا یکی از اطفال‌تان معلولیتی دارد که باعث می‌شود به مراقبت یا نظارت بیشتری نسبت به اطفال هم‌سن ضرورت داشته باشد؟', '2026-08-29 00:51:27.058206+00'),
	('45294906-d062-437d-a07f-fa5beb18bfc2', 'prs', 'Har organisationen en demokratisk uppbyggnad?', 'آیا سازمان ساختار دموکراتیک دارد؟', '2026-08-29 00:51:27.058206+00'),
	('61dc908e-5d2f-4eea-b905-7d90f3fa3b22', 'prs', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'آیا سازمان Quality Label (نشان کیفیت) دارد؟', '2026-08-29 00:51:27.058206+00'),
	('bc4ebab8-9ac2-45b6-a5f1-07428eace787', 'prs', 'Har organisationen ett 90-konto?', 'آیا سازمان 90-konto دارد؟', '2026-08-29 00:51:27.058206+00'),
	('f75a33cd-3e55-4d53-a35a-dff33b074ad5', 'prs', 'Har organisationen ett OID (Organisation ID)?', 'آیا سازمان OID (Organisation ID) دارد؟', '2026-08-29 00:51:27.058206+00'),
	('9441d981-0c6a-4e49-b186-1f92846f8e78', 'prs', 'Har organisationen ett OID?', 'آیا سازمان OID دارد؟', '2026-08-29 00:51:27.058206+00'),
	('c18f6f7b-a94c-4ad9-a4d1-0e7bf62451c5', 'prs', 'Har organisationen medlemsföreningar i flera län?', 'آیا سازمان انجمن‌های عضو در چند ولایت دارد؟', '2026-08-29 00:51:27.058206+00'),
	('e9b9126b-bcd7-480b-964f-5ed00807aebd', 'prs', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'آیا سازمان مالی منظم و ساختار دموکراتیک دارد؟', '2026-08-29 00:51:27.058206+00'),
	('b181aef7-21d6-4277-a429-15aa98fdb4f8', 'prs', 'Har projektet en partner i ett annat land?', 'آیا پروژه شریکی در کشور دیگری دارد؟', '2026-08-29 00:51:27.058206+00'),
	('17e9ddff-a20c-4cca-aa09-17feee5f883e', 'prs', 'Har projektledaren doktorsexamen?', 'آیا مسئول پروژه سند دوکتورا دارد؟', '2026-08-29 00:51:27.058206+00'),
	('1e1c3e1b-1398-4672-8ac0-14d91e3f8f80', 'prs', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'شاروالی محل بودوباش باید رفت‌وآمد روزانه میان خانه و لیسه را وقتی راه دست‌کم شش کیلومتر است تأمین کند (مثلاً کارت سرویس).', '2026-08-29 00:51:27.058206+00'),
	('2953407f-68d3-4aaa-8e98-b3ddf6bdac6e', 'prs', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'آیا در حال تهیه یا تجهیز نخستین خانه شخصی خود در سویدن هستید؟', '2026-08-29 00:51:27.058206+00'),
	('2ac26fee-ea07-4e87-b7fd-602273067d4a', 'prs', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'آیا پروژه شامل سفر یا تبادله بین‌المللی است؟', '2026-08-29 00:51:27.058206+00'),
	('f10b5a85-8343-4739-bb6d-fa67eaa89d93', 'prs', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'حمایت سرمایه‌گذاری از شرکت‌ها در ساحات حمایتی برای تعمیرات، ماشین‌آلات و آموزش.', '2026-08-29 00:51:27.058206+00'),
	('07b9b08a-f0f7-44d2-af80-18c39bf20f9e', 'prs', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'حمایت سرمایه‌گذاری از اقداماتی که انتشار گازهای گلخانه‌ای را کاهش می‌دهند.', '2026-08-29 00:51:27.058206+00'),
	('de7d275f-9ca0-49be-922d-1877b180ddbf', 'prs', 'Kan åtgärdens utsläppsminskning beräknas?', 'آیا کاهش انتشار حاصل از اقدام قابل محاسبه است؟', '2026-08-29 00:51:27.058206+00'),
	('182dc5ab-9cee-451a-98c4-ef096bb21aca', 'prs', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'آیا سازمان می‌تواند مصارف را تا پرداخت حمایت به دوش بگیرد؟', '2026-08-29 00:51:27.058206+00'),
	('79877a68-2978-48e8-92c5-5f893b138ede', 'prs', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'آیا تجربه‌ها در فعالیت شما در سویدن به کار گرفته می‌شوند؟', '2026-08-29 00:51:27.058206+00'),
	('2af96fb0-fd57-47ca-96f8-281353174d0b', 'prs', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'آیا سرمایه‌گذاری تنها بعد از ارسال درخواست آغاز می‌شود؟', '2026-08-29 00:51:27.058206+00');
INSERT INTO public.kb_translations VALUES
	('792beb49-2d56-4330-9b2d-c1f8005bb04e', 'prs', 'Kommer projektet människor i ert närområde till del?', 'آیا پروژه به مردم منطقه شما فایده می‌رساند؟', '2026-08-29 00:51:27.058206+00'),
	('93fef1e2-173c-4e3a-a0b4-4527785bda46', 'prs', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'واپسین شبکه ایمنی اقتصادی شاروالی وقتی عواید کفاف ضروری‌ترین چیزها را نمی‌دهند.', '2026-08-29 00:51:27.058206+00'),
	('54533d36-4a53-4f11-a2c8-6b6062016cc2', 'prs', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'حمایت‌های خود شاروالی‌ها از انجمن‌های محلی: کمک مالی فعالیت به ازای هر جلسه، کمک مالی محل، کمک مالی آغاز و غیره.', '2026-08-29 00:51:27.058206+00'),
	('9f993f43-6827-4ce7-9553-e4451165dbd2', 'prs', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'سرویس رایگان مکتب برای شاگردان مکتب ابتداییه در صورت فاصله دراز، راه خطرناک یا معلولیت — حقی طبق قانون مکاتب.', '2026-08-29 00:51:27.058206+00'),
	('dfad88fd-fddc-4f30-8629-9b8af7b3ffcc', 'prs', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'کمک مالی قانونی عینک یا لنز برای اطفال و جوانان؛ مبالغ و طرزالعمل‌ها در هر ولایت متفاوت است — سطح ولایت خود را بررسی کنید.', '2026-08-29 00:51:27.058206+00'),
	('1325e4c4-d459-402e-b86b-6fea42fd24dc', 'prs', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'آیا پروژه در منطقه‌ای است که برق آبی یا بادی به آن مربوط می‌شود؟', '2026-08-29 00:51:27.058206+00'),
	('f4b4d8af-4380-4b8b-aff1-9dab76186c56', 'prs', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'آیا پروژه در عرصه محیط‌زیست، علوم زراعتی یا شهرسازی است؟', '2026-08-29 00:51:27.058206+00'),
	('bafa4846-3948-4a7e-a6f3-188b2bb9eb4a', 'prs', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'آیا محل فعالیت در ساحه حمایتی A یا B است (بخش‌های بزرگ نورلند و سویالند داخلی)؟', '2026-08-29 00:51:27.058206+00'),
	('8e79ae89-5b01-4df3-bff2-fd22c323da7b', 'prs', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'قرضه‌ای برای خرید ضروری‌ترین چیزها برای نخستین خانه در سویدن — فرنیچر، لوازم خانه و دیگر تجهیزات اساسی.', '2026-08-29 00:51:27.058206+00'),
	('9f263187-e3df-459e-8e33-e3a6308fc496', 'prs', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'آیا پروژه انتشار پروسه‌ای صنعت را کاهش می‌دهد یا انتشار منفی ایجاد می‌کند؟', '2026-08-29 00:51:27.058206+00'),
	('847acd30-1797-4bda-aae8-01a106440d41', 'prs', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'کمک مالی ماهانه برای اطفال مقیم سویدن، از تولد تا ۱۶ سالگی.', '2026-08-29 00:51:27.058206+00'),
	('a7532538-7931-4718-9431-c733c9ab0ca8', 'prs', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket به سازمان‌ها، شرکت‌ها، انجمن‌ها، سکتور عامه و اشخاص در عرصه محیط‌زیست کمک مالی می‌دهد.', '2026-08-29 00:51:27.058206+00'),
	('96e60758-1923-4304-b3e7-6550f3816115', 'prs', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'آیا قصد دارید داوطلبانه برای همیشه به کشور اصلی خود برگردید؟', '2026-08-29 00:51:27.058206+00'),
	('05df3195-2907-4532-94db-f786c604ad8d', 'prs', 'Planerar du att starta eget företag?', 'آیا قصد دارید تشبث شخصی خود را آغاز کنید؟', '2026-08-29 00:51:27.058206+00'),
	('42428652-8714-4894-88b7-20a45a082313', 'prs', 'Planerar du att studera utomlands?', 'آیا قصد تحصیل در خارج را دارید؟', '2026-08-29 00:51:27.058206+00'),
	('667ba296-0ca4-471d-ae24-187f9ce1bf35', 'prs', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'آیا قصد درسی دارید که موقعیت شما را در بازار کار تقویت کند؟', '2026-08-29 00:51:27.058206+00'),
	('0bfb69a3-1528-4871-b5c2-b1c7e46d6b81', 'prs', 'Planerar ni att anställa?', 'آیا قصد استخدام دارید؟', '2026-08-29 00:51:27.058206+00'),
	('2a51eb29-74be-482b-832f-2504a58dfc16', 'prs', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'آیا قصد دارید برای برنامه‌ای از اتحادیه اروپا (مثلاً Horisont Europa) درخواست بدهید؟', '2026-08-29 00:51:27.058206+00'),
	('995f66ba-1e59-4908-8e6f-39b5fb9ab690', 'prs', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'حمایت از تولید و انکشاف فلم کوتاه و مستند.', '2026-08-29 00:51:27.058206+00'),
	('2ac8f8b3-8bde-4e84-b22d-d2f0413a47aa', 'prs', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'کمک‌های مالی پروژه‌ای برای صحنه موسیقی آزاد: کنسرت، تولید و انکشاف.', '2026-08-29 00:51:27.058206+00'),
	('4a6fa76c-d633-45fc-a150-2c7e070a1df1', 'prs', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'کمک‌های مالی پروژه‌ای برای سازمان‌های غیرانتفاعی که با اطفال و جوانان و برای آنان کار می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('7a0a6c89-802a-43c6-bc4d-b1030150cc26', 'prs', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'آیا پروژه بیان‌ها، روش‌ها یا همکاری‌های هنری تازه‌ای می‌آزماید؟', '2026-08-29 00:51:27.058206+00'),
	('04e0a1b9-650a-43b3-b863-ef3b8a30c182', 'prs', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'آیا تبادله ۵ تا ۲۱ روز دوام می‌کند (بدون روزهای سفر)؟', '2026-08-29 00:51:27.058206+00'),
	('e248c867-1cfa-424b-9194-6f456d94d02f', 'prs', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'حمایت‌های خود ولایات از پروژه‌ها و فعالیت‌های فرهنگی، در پهلوی کمک‌های ملی Kulturrådet.', '2026-08-29 00:51:27.058206+00'),
	('07ff322d-be1b-4c05-a2e9-3b3b5ea33855', 'prs', 'Riktar sig projektet till barn eller unga?', 'آیا پروژه اطفال یا جوانان را هدف قرار می‌دهد؟', '2026-08-29 00:51:27.058206+00'),
	('a0c9e235-b643-461b-8495-4c24ae54c7a6', 'prs', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'آیا پروژه اطفال، جوانان، کهنسالان یا افراد دارای معلولیت را هدف قرار می‌دهد؟', '2026-08-29 00:51:27.058206+00'),
	('58ae4804-5ed2-42ef-8419-3e3dc004a3f4', 'prs', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'آیا فعالیت اطفال و جوانان (۷–۲۵ ساله) را هدف قرار می‌دهد؟', '2026-08-29 00:51:27.058206+00'),
	('f5c11aac-366c-45f4-bf3b-5607afd12b8e', 'prs', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'آیا پس‌انداز یا دارایی‌ای ندارید که بتواند مصارف را بپوشاند؟', '2026-08-29 00:51:27.058206+00'),
	('1075edda-1dff-4415-9d4a-b7f48fa3b9bf', 'prs', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'آیا با شرکایی در دست‌کم دو کشور دیگر شمال اروپا همکاری می‌کنید؟', '2026-08-29 00:51:27.058206+00'),
	('52d04294-653e-4fc3-aac7-6799137a95ae', 'prs', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'آیا برای یک اقدام انکشافی تخصص بیرونی جلب می‌کنید؟', '2026-08-29 00:51:27.058206+00'),
	('5e42385b-d7f5-4d20-8461-0a5d86b51f65', 'prs', 'Sker mobiliteten till ett annat europeiskt land?', 'آیا تحرک به کشور اروپایی دیگری است؟', '2026-08-29 00:51:27.058206+00'),
	('c065fca9-86c5-4e37-b2f3-32a745459b3d', 'prs', 'Startar du eller tar du över företaget för första gången?', 'آیا برای نخستین بار تشبث را آغاز می‌کنید یا تسلیم می‌شوید؟', '2026-08-29 00:51:27.058206+00'),
	('41bc2b61-f097-4d71-9684-4a6e159d5d1d', 'prs', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'حمایت آغاز برای کسی که ۴۰ ساله یا جوان‌تر است و تشبث زراعتی را آغاز می‌کند یا تسلیم می‌شود.', '2026-08-29 00:51:27.058206+00'),
	('3b2969dd-59e8-46d3-8efd-b191d01c88bd', 'prs', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'بورسیه‌ای که به هنرمندان مسلکی امکان می‌دهد بر کار هنری تمرکز کنند.', '2026-08-29 00:51:27.058206+00'),
	('7288374d-aebe-42d3-88b3-c4f1e7934481', 'prs', 'Studerar du, eller planerar du att börja studera?', 'آیا درس می‌خوانید یا قصد شروع درس دارید؟', '2026-08-29 00:51:27.058206+00'),
	('2bd30c10-a177-48a1-a3cb-ec3de0d8ee28', 'prs', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'حمایت درسی برای بزرگسالان شاغل که می‌خواهند برای تقویت موقعیت خود در بازار کار آموزش ببینند.', '2026-08-29 00:51:27.058206+00'),
	('3cc4d4f4-d87a-457c-bb93-94c395e500e4', 'prs', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'حمایت از سرمایه‌گذاری‌هایی که رقابت‌پذیری را افزایش یا اثرات محیط‌زیستی را در تشبثات زراعتی کاهش می‌دهند.', '2026-08-29 00:51:27.058206+00'),
	('d4440908-7d86-4056-9e51-d41ef07c602e', 'prs', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'حمایتی وقتی طفلی نزد شما زندگی می‌کند و والد دیگر نفقه نمی‌پردازد.', '2026-08-29 00:51:27.058206+00'),
	('e360a639-c016-450e-a541-9c2b767480b7', 'prs', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'حمایت از پروژه‌های سازمان‌های غیرانتفاعی برای مردم، محیط‌زیست و جهانی بهتر.', '2026-08-29 00:51:27.058206+00'),
	('cdcc2c44-7186-4fa5-a267-5ab9b2ed898f', 'prs', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'حمایت از گذار صنعت به سوی انتشار صفری گازهای گلخانه‌ای.', '2026-08-29 00:51:27.058206+00'),
	('810cc832-dc32-4fc8-930b-93f9ca01ecab', 'prs', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'حمایت از پروژه‌های هنری و فرهنگی با بُعد نوردیک و همکاری فرامرزی.', '2026-08-29 00:51:27.058206+00'),
	('339aa71b-5109-4a44-9f58-00800c9d7abe', 'prs', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'حمایت از پروژه‌های فرهنگی نوآورانه که بیان‌ها، روش‌ها یا همکاری‌های هنری تازه می‌آزمایند.', '2026-08-29 00:51:27.058206+00'),
	('d36bf6e5-0baa-4d69-96fb-ea2355a3d584', 'prs', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'حمایت از پروژه‌های نوآورانه برای اطفال، جوانان، کهنسالان و افراد دارای معلولیت.', '2026-08-29 00:51:27.058206+00'),
	('fb9b283f-ea37-4361-92e1-4583e0fe9bbf', 'prs', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'حمایت از پروژه‌های همکاری در صحنه موسیقی آزاد.', '2026-08-29 00:51:27.058206+00'),
	('8c3e3b1d-f8ac-4db4-af98-0a98a377e1cb', 'prs', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'حمایت از پروژه‌های همکاری در فرهنگ و رسانه که دموکراسی و آزادی بیان را در سطح بین‌المللی تقویت می‌کنند.', '2026-08-29 00:51:27.058206+00'),
	('726558c6-dac0-4e34-9724-bdb7967f86c8', 'prs', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'آیا هدف پروژه تقویت دموکراسی، برابری یا آزادی بیان است؟', '2026-08-29 00:51:27.058206+00'),
	('d8a348dd-edf7-4fca-ba49-d830d64b989b', 'prs', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'آیا در کشور دیگری از اتحادیه اروپا یا ساحه اقتصادی اروپا دنبال وظیفه می‌گردید یا پیشنهاد وظیفه گرفته‌اید؟', '2026-08-29 00:51:27.058206+00'),
	('0c853c8a-283d-4936-b4f9-73e4a82e04e2', 'prs', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'سقفی برای آنچه در دوره دوازده‌ماهه بابت فیس مریض می‌پردازید — بعد از آن frikort (کارت رایگان).', '2026-08-29 00:51:27.058206+00'),
	('815e68a1-2d1e-42e0-8c91-30150659d1a6', 'prs', 'Tar du ut hel allmän pension?', 'آیا تقاعد عمومی کامل خود را می‌گیرید؟', '2026-08-29 00:51:27.058206+00'),
	('717e5ca3-2b62-4e0d-a622-989fd96b14f9', 'prs', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'اضافه‌ای که بخشی از مصارف مسکن را برای کسی که تقاعد و عاید کم دارد می‌پوشاند.', '2026-08-29 00:51:27.058206+00');
INSERT INTO public.kb_translations VALUES
	('51225cad-8b89-4ab5-8ca6-98fbebbc6b99', 'prs', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'کمک مالی سازمانی سالانه برای سازمان‌های ملی اطفال و جوانان.', '2026-08-29 00:51:27.058206+00'),
	('20767b43-57ee-42f8-a6f0-484894985927', 'prs', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'اعتبار سالانه‌ای که مستقیماً نزد داکتر دندان یا صحی‌کار دندان کم می‌شود.', '2026-08-29 00:51:27.058206+00'),
	('e8d66849-9c11-43d1-839c-fe87a8ef7dc6', 'prs', 'Är bolaget yngre än cirka 5 år?', 'آیا عمر شرکت کمتر از تقریباً ۵ سال است؟', '2026-08-29 00:51:27.058206+00'),
	('797e0d26-bcef-4ada-b939-7add786fa090', 'prs', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'آیا اشتراک‌کنندگان تبادله بین ۱۳ و ۳۰ سال دارند؟', '2026-08-29 00:51:27.058206+00'),
	('e83b5403-2db6-4b62-b1bf-ace9a58310ab', 'prs', 'Är det här ert första EU-projekt?', 'آیا این نخستین پروژه اتحادیه اروپای شماست؟', '2026-08-29 00:51:27.058206+00'),
	('827c6ae4-1ccc-4227-9e8d-2437ce4f20a5', 'prs', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'آیا برای شما (یا طفل‌تان) گشت‌وگذار مستقل یا سفر با سرویس و قطار بسیار دشوار است؟', '2026-08-29 00:51:27.058206+00'),
	('1bd5c76e-f5f1-47eb-8370-20198610898d', 'prs', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا عاید شما کمتر از تقریباً ۲۵٬۰۰۰ کرون در ماه پیش از مالیه است؟', '2026-08-29 00:51:27.058206+00'),
	('0a9549e0-9cac-42fb-9961-d99060d61433', 'prs', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'آیا آخرین تحصیل تمام‌شده شما مکتب ابتداییه است، یا لیسه‌ای که تمامش نکردید؟', '2026-08-29 00:51:27.058206+00'),
	('bef5408a-0d89-4092-8953-e8a796116c6a', 'prs', 'Är du 40 år eller yngre?', 'آیا ۴۰ ساله یا جوان‌تر هستید؟', '2026-08-29 00:51:27.058206+00'),
	('e1280ad9-6f65-45a0-b183-934f7ac72c4a', 'prs', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'آیا به‌عنوان جوینده کار نزد Arbetsförmedlingen ثبت‌نام شده‌اید؟', '2026-08-29 00:51:27.058206+00'),
	('17f7697d-b93c-494d-aeb1-d5ae783a01fb', 'prs', 'Är du mellan 18 och 28 år?', 'آیا بین ۱۸ و ۲۸ سال دارید؟', '2026-08-29 00:51:27.058206+00'),
	('5d03c572-9bde-47a0-9362-9bee989fa61c', 'prs', 'Är du mellan 19 och 29 år?', 'آیا بین ۱۹ و ۲۹ سال دارید؟', '2026-08-29 00:51:27.058206+00'),
	('cbd6e8ff-7c55-4ceb-9d41-5c68751e0496', 'prs', 'Är du mellan 25 och 60 år?', 'آیا بین ۲۵ و ۶۰ سال دارید؟', '2026-08-29 00:51:27.058206+00'),
	('cca219a7-4a24-45c8-a690-5b6775892db9', 'prs', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'آیا به‌طور مسلکی در عرصه فرهنگ فعالیت می‌کنید (مثلاً رقص، موسیقی، هنرهای نمایشی)؟', '2026-08-29 00:51:27.058206+00'),
	('3f9921cb-0e7a-4560-9bd6-82e6f8e765ff', 'prs', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'آیا هنرمند مسلکی هستید (نه شوقی و نه در آموزش اساسی)؟', '2026-08-29 00:51:27.058206+00'),
	('33bf0e23-a167-43cf-94a9-1cdfdf084227', 'prs', 'Är du yrkesverksam konstnär?', 'آیا هنرمند مسلکی هستید؟', '2026-08-29 00:51:27.058206+00'),
	('decef946-3e36-42ba-87ba-6be419c86949', 'prs', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'آیا راه‌حل شما در مقایسه با آنچه موجود است اساساً نوآورانه است؟', '2026-08-29 00:51:27.06182+00'),
	('a0b4fcaa-29f4-40c7-ae8c-e275de6e62d8', 'prs', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'آیا کلپ به فدراسیون ورزشی تخصصی درون Riksidrottsförbundet وابسته است؟', '2026-08-29 00:51:27.06182+00'),
	('69cf2cc1-693a-4892-af43-e9defc3f5e7f', 'prs', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'آیا عاید فامیل نسبت به مصارف مسکن پایین است؟', '2026-08-29 00:51:27.06182+00'),
	('f34d5bdf-7006-4916-ba3c-1392519c356c', 'prs', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'آیا عاید مجموعی فامیل کمتر از تقریباً ۲۵٬۰۰۰ کرون در ماه پیش از مالیه است؟', '2026-08-29 00:51:27.06182+00'),
	('625d5f18-8ec2-41a3-9cb8-943f7051cf70', 'prs', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'آیا اقدام یک پروژه مشخص است (نه فعالیت عادی)؟', '2026-08-29 00:51:27.06182+00'),
	('f8aeef75-e862-4d10-a84a-00b0938a5aa9', 'prs', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'آیا محل برای همه باز است — نه تنها اعضای خودتان؟', '2026-08-29 00:51:27.06182+00'),
	('995e24dc-720f-4a7d-9fe8-1f05e3f0aca5', 'prs', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'آیا دست‌کم ۶۰ فیصد اعضا بین ۶ و ۲۵ سال دارند؟', '2026-08-29 00:51:27.06182+00'),
	('3cdcff58-0d07-48a8-82a9-9086ee3dc4d2', 'prs', 'Är minst 60 % av medlemmarna under 26 år?', 'آیا دست‌کم ۶۰ فیصد اعضا زیر ۲۶ سال هستند؟', '2026-08-29 00:51:27.06182+00'),
	('be715cad-c6ee-435b-97a0-537e4cfd53b4', 'prs', 'Är målgruppen delaktig i planering och genomförande?', 'آیا گروه هدف در پلان‌گذاری و اجرا سهم دارد؟', '2026-08-29 00:51:27.06182+00'),
	('15b038fa-c104-433a-aa47-92f074c2d740', 'prs', 'Är ni ett förlag med professionell utgivning?', 'آیا ناشری با نشرات مسلکی هستید؟', '2026-08-29 00:51:27.06182+00'),
	('4f8a58b8-b6b9-48a0-aab4-857bbfafca13', 'prs', 'Är ni huvudman för förskoleklass eller grundskola?', 'آیا مسئول یک صنف آمادگی یا مکتب ابتداییه هستید؟', '2026-08-29 00:51:27.06182+00'),
	('e459521b-8426-4b5a-8d44-86860d0530fb', 'prs', 'Är organisationen registrerad i EU:s deltagarregister?', 'آیا سازمان در فهرست اشتراک‌کنندگان اتحادیه اروپا ثبت شده است؟', '2026-08-29 00:51:27.06182+00'),
	('c020ddd7-f11d-40bd-a640-a0b4ebc00ab8', 'prs', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'آیا پروژه یک پروژه سینمایی است (فلم کوتاه یا مستند)؟', '2026-08-29 00:51:27.06182+00'),
	('f8974e2e-570d-4cad-b951-1b1d7ee96629', 'prs', 'Är projektet ett konst- eller kulturprojekt?', 'آیا پروژه یک پروژه هنری یا فرهنگی است؟', '2026-08-29 00:51:27.06182+00'),
	('7d6a08bd-b446-4666-8835-758511ce6b45', 'prs', 'Är projektet ett kulturprojekt?', 'آیا پروژه یک پروژه فرهنگی است؟', '2026-08-29 00:51:27.06182+00'),
	('bded3d3d-7f02-44d1-bbb4-8596158cc876', 'prs', 'Är projektet ett musikprojekt?', 'آیا پروژه یک پروژه موسیقی است؟', '2026-08-29 00:51:27.06182+00'),
	('3d8aa56b-2801-40f1-9832-5b79a5da2bae', 'prs', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'آیا پروژه نوآورانه است — کاری که فعلاً در فعالیت عادی انجام نمی‌دهید؟', '2026-08-29 00:51:27.06182+00'),
	('1afad9cc-05dc-4e58-8a48-405d5fec2d78', 'prs', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'آیا پروژه به کل منطقه فایده می‌رساند (نه به اشخاص)؟', '2026-08-29 00:51:27.06182+00'),
	('f2feadab-4868-49ca-be0e-20738e5d90fc', 'prs', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'آیا راه میان خانه و لیسه دست‌کم شش کیلومتر است؟', '2026-08-29 00:51:27.06182+00'),
	('0b7c686b-87a7-493d-9322-10814dab3806', 'prs', 'Är verksamheten professionell (inte amatörverksamhet)?', 'آیا فعالیت مسلکی است (نه شوقی)؟', '2026-08-29 00:51:27.06182+00'),
	('0fd4e4ba-f4d9-46f2-b3d3-cb1c66525d83', 'prs', 'Är verksamheten professionell?', 'آیا فعالیت مسلکی است؟', '2026-08-29 00:51:27.06182+00'),
	('5de3ec98-6e3f-4e75-b805-7062210e4d4a', 'prs', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'آیا فعالیت از هنرهای نمایشی است (رقص، تیاتر، تیاتر موزیکال)؟', '2026-08-29 00:51:27.06182+00'),
	('5fb02a17-5520-4bdc-a693-295b636a5f80', 'prs', 'Är volontärerna mellan 18 och 30 år?', 'آیا رضاکاران بین ۱۸ و ۳۰ سال دارند؟', '2026-08-29 00:51:27.06182+00'),
	('cd923e44-eadf-4f21-a045-13df54ef029f', 'ru', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Поддержка деятельности спортивных клубов, проводящих занятия под руководством тренеров для детей и молодёжи 7–25 лет.', '2026-08-29 00:51:27.067612+00'),
	('c86521ea-868c-4145-b222-933694e83546', 'ru', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Автоматическая надбавка к детскому пособию (barnbidrag) начиная со второго ребёнка.', '2026-08-29 00:51:27.067612+00'),
	('89ca4d81-9698-44c0-bbd6-9cdbb37c7560', 'ru', 'Avser ansökan en fysisk investering?', 'Касается ли заявка физической инвестиции?', '2026-08-29 00:51:27.067612+00'),
	('99150945-89a2-4ae0-b276-2b58ddc0c428', 'ru', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Касается ли заявка международной поездки или обмена?', '2026-08-29 00:51:27.067612+00'),
	('0e6da41f-3443-41c4-8496-64c668dc2dd6', 'ru', 'Avser ansökan en investering i byggnader eller maskiner?', 'Касается ли заявка инвестиции в здания или оборудование?', '2026-08-29 00:51:27.067612+00'),
	('f27de70b-c5ce-49c2-950e-5e081dd8ce96', 'ru', 'Avser ansökan en redan utgiven titel?', 'Касается ли заявка уже изданного произведения?', '2026-08-29 00:51:27.067612+00'),
	('a16f6626-7372-4fa2-823b-f2b3dc7a3a0b', 'ru', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Касается ли заявка сельскохозяйственного, садоводческого или оленеводческого предприятия?', '2026-08-29 00:51:27.067612+00'),
	('2f241010-ac7d-4907-87a9-d7d034971a61', 'ru', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Касается ли заявка закупки литературы для публичных или школьных библиотек?', '2026-08-29 00:51:27.067612+00'),
	('96e7f5d2-0999-4612-88c3-875452dabf09', 'ru', 'Avser investeringen jordbruksverksamhet?', 'Касается ли инвестиция сельскохозяйственной деятельности?', '2026-08-29 00:51:27.067612+00'),
	('32234b98-85e2-467a-bf01-66e76ed91a13', 'ru', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Предполагает ли проект строительство, покупку или ремонт помещения?', '2026-08-29 00:51:27.067612+00'),
	('1e528dfb-acd6-4b53-97ef-2559f04019bd', 'ru', 'Avser projektet naturvård eller friluftsliv?', 'Касается ли проект охраны природы или активного отдыха на природе?', '2026-08-29 00:51:27.067612+00');
INSERT INTO public.kb_translations VALUES
	('95528d41-1e1e-4ce6-a909-54eed9f1053e', 'ru', 'Avser projektet skola eller vuxenutbildning?', 'Касается ли проект школы или образования взрослых?', '2026-08-29 00:51:27.067612+00'),
	('fa35e522-864a-4c6a-ab81-9ed00e81c33a', 'ru', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Отказываетесь ли вы от работы, чтобы ухаживать за близким человеком или быть рядом с ним, когда болезнь настолько тяжела, что угрожает его жизни?', '2026-08-29 00:51:27.067612+00'),
	('92fa8dfc-2ff8-4f32-83ba-a9ebfdadfd8b', 'ru', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Ведёт ли объединение регулярную деятельность в коммуне?', '2026-08-29 00:51:27.067612+00'),
	('636dcffe-3e92-4fd2-ae81-0ae664679fa2', 'ru', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Считаете ли вы, что ваша трудоспособность снижена как минимум на год из-за болезни или инвалидности?', '2026-08-29 00:51:27.067612+00'),
	('7521f39b-630a-4d07-ae44-a97d768f1eed', 'ru', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Адресная поддержка для тех, у кого низкая пенсия или её нет, и кому нужна помощь для достижения разумного уровня жизни.', '2026-08-29 00:51:27.067612+00'),
	('a772dc32-6a41-4992-bb39-fd19fe29a7fd', 'ru', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Нужно ли ребёнку жить в месте учёбы (проживание) из-за слишком долгой дороги?', '2026-08-29 00:51:27.067612+00'),
	('511b62aa-2190-4ba3-a222-e20ee571af6b', 'ru', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Нужно ли адаптировать жильё (например, пандус, автоматическая дверь, ванная)?', '2026-08-29 00:51:27.067612+00'),
	('714c334b-5caa-4989-b671-7ea766e9f6f5', 'ru', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Нужны ли кому-то из ваших детей 8–19 лет очки или линзы?', '2026-08-29 00:51:27.067612+00'),
	('13d7fb63-f756-46a6-ae5d-46bec5940c3c', 'ru', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Другой родитель не платит ничего или платит меньше полного содержания?', '2026-08-29 00:51:27.067612+00'),
	('03184a57-8d92-4273-9ae3-631315332a1d', 'ru', 'Betalar du hyra eller andra boendekostnader?', 'Платите ли вы аренду или другие расходы на жильё?', '2026-08-29 00:51:27.067612+00'),
	('15ccb9fe-4a20-4e85-929a-dffbaad0e758', 'ru', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Пособие на адаптацию жилья при инвалидности — например, пандусы, автоматические двери или переоборудование ванной.', '2026-08-29 00:51:27.067612+00'),
	('38b28435-e96e-4416-8872-d047f75942bf', 'ru', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Пособия на строительство, покупку или ремонт общественных помещений для собраний.', '2026-08-29 00:51:27.067612+00'),
	('75177392-56dc-41b2-a0c7-7853edf74e1d', 'ru', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Пособие на покупку или адаптацию автомобиля, когда стойкая инвалидность сильно затрудняет передвижение или поездки на общественном транспорте.', '2026-08-29 00:51:27.067612+00'),
	('a2862701-644d-46b4-8b2c-6aa03816f6a9', 'ru', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Пособия на международные поездки и обмены для профессионалов в сфере культуры.', '2026-08-29 00:51:27.067612+00'),
	('b47225ac-9306-4eb5-b7bb-fa1208bb82c9', 'ru', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Пособия на международные обмены, поездки и рабочие пребывания профессиональных художников.', '2026-08-29 00:51:27.067612+00'),
	('c956660f-f98e-4b36-9e71-25388bcf510a', 'ru', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Пособие и добровольный заём для учёбы на гимназическом или послегимназическом уровне.', '2026-08-29 00:51:27.067612+00'),
	('0234e558-91f8-4362-8bf4-fb4a53996fe1', 'ru', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Пособия и займы для учёбы за границей, с дополнительными займами, например, на плату за обучение и поездки.', '2026-08-29 00:51:27.067612+00'),
	('9e567b98-8161-46dd-89b8-e4e237a740bc', 'ru', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Пособие, помогающее шведским организациям готовить заявки на программы ЕС, такие как Horisont Europa.', '2026-08-29 00:51:27.067612+00'),
	('5cc6f226-d60c-49b4-9f81-1aa6a8740681', 'ru', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Пособие работодателям, нанимающим людей со сниженной трудоспособностью.', '2026-08-29 00:51:27.067612+00'),
	('806462a9-3242-4a71-b608-c28d3f37aa90', 'ru', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Пособие на проживание и поездки домой, когда гимназист вынужден жить в месте учёбы из-за долгой дороги.', '2026-08-29 00:51:27.067612+00'),
	('22e213fb-a66b-4816-955e-d5833e7117a0', 'ru', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Пособия на работу некоммерческих организаций по сохранению, использованию и развитию культурного наследия.', '2026-08-29 00:51:27.067612+00'),
	('08cc6fc9-99fd-4175-8875-55e3ab63ac71', 'ru', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Пособия на муниципальные и местные природоохранные проекты, включая водно-болотные угодья и активный отдых.', '2026-08-29 00:51:27.067612+00'),
	('ab2a3795-f708-441c-ab9e-acc696bfab2b', 'ru', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Пособия коммунам на закупку литературы для публичных и школьных библиотек.', '2026-08-29 00:51:27.067612+00'),
	('b840f4ae-9499-4ac2-a916-7755e9ffe6d4', 'ru', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Пособия школьным организациям для знакомства учеников основной школы с профессиональной культурой.', '2026-08-29 00:51:27.067612+00'),
	('0925adc1-ed56-4292-9f89-b9843d4742a4', 'ru', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Пособие на то, что нужно вашему ребёнку, но на что не хватает семейного бюджета: досуг, одежда, школьные экскурсии, очки, каникулярные занятия и другое.', '2026-08-29 00:51:27.067612+00'),
	('14f9904e-c4af-4892-a5c6-3f8a6f0d12a8', 'ru', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Пособия из фондов Världens Barn, Musikhjälpen и Victoriafonden — их запрашивают шведские некоммерческие организации с 90-konto.', '2026-08-29 00:51:27.067612+00'),
	('1c14b895-fb01-47ff-b792-f961ae9e4e22', 'ru', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Пособия из средств гидро- и ветроэнергетики на проекты, развивающие местность.', '2026-08-29 00:51:27.067612+00'),
	('f49f685d-42bc-460e-8989-6c83fd40d342', 'ru', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Пособие без заёмной части для безработных 25–60 лет с коротким образованием, которым нужно учиться на уровне основной школы или гимназии.', '2026-08-29 00:51:27.067612+00'),
	('1610bbbd-b262-49c6-b243-fe012690ff84', 'ru', 'Bidrar projektet till energiomställningen?', 'Вносит ли проект вклад в энергетический переход?', '2026-08-29 00:51:27.067612+00'),
	('5f5014a1-577d-41f2-a7a0-56a4fd3e9af2', 'ru', 'Bor du och barnets andra förälder på skilda håll?', 'Живёте ли вы и другой родитель ребёнка раздельно?', '2026-08-29 00:51:27.067612+00'),
	('dcea8be9-f8e9-4455-b79e-0327efe27321', 'ru', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Чеки для малых предприятий на привлечение внешней экспертизы для интернационализации или цифровизации.', '2026-08-29 00:51:27.067612+00'),
	('d20ff0ea-a58e-49e7-b23f-3835248eacc0', 'ru', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Участвуете ли вы в программе Arbetsförmedlingen (например, jobb- och utvecklingsgarantin)?', '2026-08-29 00:51:27.067612+00'),
	('ad217b6f-f974-4db6-b6a9-3c22ebd09095', 'ru', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Последующая поддержка издательствам за выпуск качественной литературы.', '2026-08-29 00:51:27.067612+00'),
	('0c0c6515-cb8f-4014-a2b9-6c670b08f463', 'ru', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Экономическая поддержка для тех, у кого вид на жительство по защите и кто добровольно хочет навсегда вернуться в страну происхождения.', '2026-08-29 00:51:27.067612+00'),
	('c95cb165-7db7-43c7-9298-f7e2f6709ee5', 'ru', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Экономическая поддержка работодателям, нанимающим человека, долго не работавшего.', '2026-08-29 00:51:27.067612+00'),
	('34b3ad68-3da5-402b-8bfd-ed67692c34aa', 'ru', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Экономическая поддержка на этапе запуска для ищущих работу, открывающих собственное дело.', '2026-08-29 00:51:27.067612+00'),
	('87a7738d-eb58-49e3-9558-db3eeb296a30', 'ru', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten постоянно открывает конкурсы в области энергетических исследований, инноваций и энергоэффективности.', '2026-08-29 00:51:27.067612+00'),
	('fbbe5d1a-363c-4ab0-9487-a5015de0f972', 'ru', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Выплата за отсутствие на работе или учёбе для ухода за ребёнком.', '2026-08-29 00:51:27.067612+00'),
	('2acc70d0-3570-49b5-a135-1882ff72495e', 'ru', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Выплата для тех, кто недавно в Швеции и участвует в программе адаптации Arbetsförmedlingen; выплачивает Försäkringskassan.', '2026-08-29 00:51:27.067612+00'),
	('df46470c-d0bd-42cc-bc32-be4cc5ce513e', 'ru', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Выплата, покрывающая часть расходов на жильё для молодых людей без детей с низкими доходами.', '2026-08-29 00:51:27.067612+00'),
	('c1ef2872-f73b-4462-8914-62b4b167ed54', 'ru', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Выплата за дополнительные расходы, связанные со стойкой инвалидностью — для взрослых или родителей детей с инвалидностью.', '2026-08-29 00:51:27.067612+00'),
	('25cebacc-948d-407b-8cae-a9ec809e5776', 'ru', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Выплата для молодых людей (19–29 лет), которые не могут работать полный день минимум год из-за болезни или инвалидности.', '2026-08-29 00:51:27.067612+00'),
	('9d059969-e0a4-4c27-b857-546995cc238c', 'ru', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Выплата при стойко сниженной трудоспособности — то, что раньше называлось förtidspension (досрочная пенсия).', '2026-08-29 00:51:27.067612+00'),
	('9fc90184-0373-4b34-853d-3a606535185f', 'ru', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Выплата, когда вы отказываетесь от работы, чтобы быть рядом с тяжелобольным близким.', '2026-08-29 00:51:27.067612+00'),
	('cda13672-b4bc-447e-a62a-e434d599f1a9', 'ru', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Выплата за участие в программе рынка труда Arbetsförmedlingen.', '2026-08-29 00:51:27.067612+00'),
	('98e478a4-26af-4b4e-98e3-3496c20605a0', 'ru', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Выплата, когда вы не можете работать как обычно из-за болезни.', '2026-08-29 00:51:27.067612+00'),
	('cfd2f526-d42a-4b41-b8f4-dfea2ac13110', 'ru', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Выплата, когда вы остаётесь дома с работы для ухода за больным ребёнком.', '2026-08-29 00:51:27.067612+00'),
	('7d1b4391-bf95-4076-a058-2adb3a1a1748', 'ru', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Выплата, покрывающая часть расходов на жильё для семей с детьми и невысокими доходами.', '2026-08-29 00:51:27.067612+00'),
	('3333ea5b-9278-421c-ac73-d6c543765b69', 'ru', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Выплата родителям, чьи дети из-за инвалидности нуждаются в большем уходе и присмотре, чем сверстники.', '2026-08-29 00:51:27.067612+00'),
	('ed7e443e-62f0-4971-a947-d5f87a0bce21', 'ru', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Выплата при безработице — на основе дохода для членов кассы, базовая сумма для остальных.', '2026-08-29 00:51:27.067612+00');
INSERT INTO public.kb_translations VALUES
	('d08827c3-f3ce-4ac3-b0e5-30984ece7d95', 'ru', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Около пятидесяти фондов сберегательных банков выдают пособия местным проектам в спорте, культуре, образовании и развитии общества — в зоне деятельности банка.', '2026-08-29 00:51:27.067612+00'),
	('47eda0b4-c94c-4484-94c2-173a5180d2c6', 'ru', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Финансируемая ЕС проектная поддержка, запрашиваемая в вашей местной зоне Leader — для объединений, компаний и коммун, развивающих сельскую местность.', '2026-08-29 00:51:27.067612+00'),
	('4d811188-afeb-4967-937f-9e2795aa8649', 'ru', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Финансируемая ЕС поддержка для ищущих работу, устраивающихся в другой стране ЕС/ЕЭЗ: компенсация поездки на собеседование, расходов на переезд и языкового курса.', '2026-08-29 00:51:27.067612+00'),
	('61286646-e31a-470c-a0c6-cfd7dea6de75', 'ru', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Средства социального фонда ЕС на проекты, укрепляющие компетенции, переквалификацию и инклюзию на рынке труда.', '2026-08-29 00:51:27.067612+00'),
	('cc572109-c582-452a-8534-e7bd1c4717ff', 'ru', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Поддержка ЕС для групповых обменов молодёжи 13–30 лет, длительностью 5–21 день без учёта дней в пути.', '2026-08-29 00:51:27.067612+00'),
	('885d6395-23be-4f71-a5ba-140903b90e6f', 'ru', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Поддержка ЕС для проектов сотрудничества культурных организаций с партнёрами в нескольких европейских странах.', '2026-08-29 00:51:27.067612+00'),
	('7fd68e3c-642f-4682-bd8d-78a865f575c6', 'ru', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Поддержка ЕС для организаций, принимающих или направляющих молодых волонтёров 18–30 лет.', '2026-08-29 00:51:27.067612+00'),
	('78ee72c7-5314-4d21-96b7-6cdff123bbba', 'ru', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Поддержка ЕС для мобильности персонала и учащихся в школе и образовании взрослых.', '2026-08-29 00:51:27.067612+00'),
	('dc07654d-beac-4211-86cb-3de438acc7c4', 'ru', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Поддержка ЕС с фиксированными суммами для первых европейских проектов сотрудничества небольших организаций.', '2026-08-29 00:51:27.067612+00'),
	('3d09fd97-4c46-48fc-bf9c-eee14a1b2f19', 'ru', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Финансирование молодых компаний, разрабатывающих новаторские продукты или услуги с международным потенциалом.', '2026-08-29 00:51:27.067612+00'),
	('992211e1-9a65-49f5-a144-f937e802b982', 'ru', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Есть ли сберегательный банк (и, значит, фонд сберегательного банка) там, где вы ведёте деятельность?', '2026-08-29 00:51:27.067612+00'),
	('c656102a-38a8-492d-a1da-94fa0eb87528', 'ru', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Многолетние операционные пособия профессиональным независимым коллективам танца, театра и музыкального театра.', '2026-08-29 00:51:27.067612+00'),
	('543cb4a9-38bd-4b7b-870a-f40d563f1b16', 'ru', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Исследовательские пособия в областях Forte: здоровье, трудовая жизнь и благосостояние. Запрашивают исследователи с докторской степенью в шведских вузах.', '2026-08-29 00:51:27.067612+00'),
	('1999d575-82b8-4b5f-8966-bdf1722b4da5', 'ru', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Финансирование свободных фундаментальных исследований во всех областях науки.', '2026-08-29 00:51:27.067612+00'),
	('2563c5ed-5a39-499b-91bb-f4944223e13a', 'ru', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Финансирование исследований в области окружающей среды, аграрных наук и градостроительства.', '2026-08-29 00:51:27.067612+00'),
	('7e9cf5a0-8742-4585-bbbb-7ff18c6bc5d9', 'ru', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Думаете ли вы о переезде за границу (работа, учёба или возвращение на родину)?', '2026-08-29 00:51:27.067612+00'),
	('ad5cd85b-cca5-4602-a37d-ff36083bf946', 'ru', 'Genomförs insatserna av professionella kulturaktörer?', 'Проводятся ли мероприятия профессиональными деятелями культуры?', '2026-08-29 00:51:27.067612+00'),
	('9778bad2-f59c-4414-b42d-2faed94f0e30', 'ru', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Реализуется ли проект в сельской местности или небольшом населённом пункте?', '2026-08-29 00:51:27.067612+00'),
	('57bbe670-b0c8-4144-a298-76ae411dc013', 'ru', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Базовая защита для тех, у кого в течение жизни был низкий трудовой доход или его не было.', '2026-08-29 00:51:27.067612+00'),
	('aa9b53fb-3f1f-4259-a3b9-75afcef069e0', 'ru', 'Går något av dina barn i grundskolan?', 'Ходит ли кто-то из ваших детей в основную школу?', '2026-08-29 00:51:27.067612+00'),
	('e0324727-f462-428a-9b03-3cba80b3cce5', 'ru', 'Går något av dina barn på gymnasiet?', 'Учится ли кто-то из ваших детей в гимназии?', '2026-08-29 00:51:27.067612+00'),
	('e707e031-a460-40ad-ae6a-787fee05db7c', 'ru', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Касается ли наём человека со сниженной трудоспособностью?', '2026-08-29 00:51:27.067612+00'),
	('d6109d2c-4308-4596-a599-615649062a3e', 'ru', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Касается ли наём человека, долго бывшего безработным или недавно приехавшего в Швецию?', '2026-08-29 00:51:27.067612+00'),
	('9af09766-5481-4d4e-b93c-ad1fc9959366', 'ru', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Посвящён ли проект сохранению культурного наследия или обеспечению доступа к нему?', '2026-08-29 00:51:27.067612+00'),
	('09ba6d80-c432-471d-8f68-a44fc9ed343e', 'ru', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Посвящён ли проект энергетике, энергоэффективности или энергетическим инновациям?', '2026-08-29 00:51:27.067612+00'),
	('10a32a78-1752-4791-9ce1-8cf6d0f02a63', 'ru', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Посвящён ли проект здоровью, трудовой жизни или благосостоянию?', '2026-08-29 00:51:27.067612+00'),
	('1d577b87-07c9-4a68-b2c7-9a1f5fb4cdb6', 'ru', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Посвящён ли проект развитию компетенций или мерам на рынке труда?', '2026-08-29 00:51:27.067612+00'),
	('b42d34f1-5945-44b7-b085-c6f165172c6c', 'ru', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Посвящён ли проект экологическим или климатическим мерам?', '2026-08-29 00:51:27.067612+00'),
	('d18b2f9e-6cb8-4412-acab-74a9798cc505', 'ru', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Длинная ли у ребёнка дорога в школу, опасная из-за движения или трудная по другим причинам?', '2026-08-29 00:51:27.067612+00'),
	('e8a0fec1-27ac-4f30-8ad0-c3822d634a5c', 'ru', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Работали ли вы не менее 16 часов в неделю в общей сложности не менее 8 лет?', '2026-08-29 00:51:27.067612+00'),
	('4e93373a-572d-45e2-9336-24bfc0a9ff36', 'ru', 'Har du barn som bor hos dig, helt eller växelvis?', 'Живут ли с вами дети — постоянно или попеременно?', '2026-08-29 00:51:27.067612+00'),
	('b1a22223-7fa1-49fe-9cc0-76fe6eda615a', 'ru', 'Har du barn som bor hos dig?', 'Живут ли с вами дети?', '2026-08-29 00:51:27.067612+00'),
	('9c551a56-a180-42ce-bbf8-76bb9c911f00', 'ru', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Есть ли у вас или вашего ребёнка инвалидность, которая, как ожидается, продлится не менее года?', '2026-08-29 00:51:27.067612+00'),
	('818fc7e0-14f8-420a-b2b2-67745af6f149', 'ru', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Есть ли у вас или кого-то в семье стойкая инвалидность, влияющая на жильё?', '2026-08-29 00:51:27.067612+00'),
	('876af3c5-1934-4b0e-b330-a06d88fbdacd', 'ru', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Есть ли у вас или близкого родственника инвалидность либо длительная или тяжёлая болезнь?', '2026-08-29 00:51:27.067612+00'),
	('11f13788-b0a5-4454-a19e-88e3b7b5fa44', 'ru', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Есть ли у вас болезнь или травма, которая сейчас снижает вашу трудоспособность?', '2026-08-29 00:51:27.067612+00'),
	('0ac53617-433d-4f29-97d1-bedd1309ac2d', 'ru', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Бывало ли вам трудно оплатить школьную экскурсию, классную поездку или досуговое занятие, в котором должен участвовать ваш ребёнок?', '2026-08-29 00:51:27.067612+00'),
	('a1e694e9-6f33-4968-8d64-5371afe228fb', 'ru', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Трудно ли вам прожить на пенсию и прочие доходы?', '2026-08-29 00:51:27.067612+00'),
	('cc06a906-6080-4147-a5d7-5d32a69997e1', 'ru', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Получали ли вы в последние годы вид на жительство в Швеции, например, как нуждающийся в защите или как член семьи?', '2026-08-29 00:51:27.067612+00'),
	('38806200-4c34-473a-8fd2-69df919fd2fb', 'ru', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Есть ли у вас вид на жительство в Швеции как у беженца или нуждающегося в защите (или вы близкий родственник такого человека)?', '2026-08-29 00:51:27.067612+00'),
	('25503673-1d7e-4701-af62-3dcc942c4e19', 'ru', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Достигли ли вы целевого пенсионного возраста (67 лет в 2026 году)?', '2026-08-29 00:51:27.067612+00'),
	('76c8fe4d-0661-4900-8e64-5562555a1d5d', 'ru', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Есть ли у вашей организации OID (Organisation ID), зарегистрированный в Organisation Registration System ЕС?', '2026-08-29 00:51:27.067612+00'),
	('291ed17a-fecc-4d4b-8c01-521970c36e7a', 'ru', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Повлекла ли инвалидность дополнительные расходы — например, вспомогательные средства, поездки, особое питание или износ?', '2026-08-29 00:51:27.067612+00'),
	('3e30cf8e-8717-4822-b15f-14ce4f972427', 'ru', 'Har föreningen antagna stadgar och en vald styrelse?', 'Есть ли у объединения принятый устав и избранное правление?', '2026-08-29 00:51:27.067612+00'),
	('59152821-2921-4719-b73f-6922cc08933c', 'ru', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Есть ли у объединения демократическое устройство (устав, годовое собрание, правление)?', '2026-08-29 00:51:27.067612+00'),
	('da6edafd-7d59-419b-94af-1d9f0cebbac1', 'ru', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Ведёт ли объединение регулярную деятельность для детей или молодёжи?', '2026-08-29 00:51:27.067612+00'),
	('9eff63a5-ea6d-47ac-be1a-39d6b414d20d', 'ru', 'Har företaget mellan cirka 2 och 49 anställda?', 'В компании примерно от 2 до 49 сотрудников?', '2026-08-29 00:51:27.067612+00'),
	('805e0e41-44a0-47e6-acb4-d9b1ef37c925', 'ru', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Трудно ли семье покрывать расходы на еду, жильё и самое необходимое?', '2026-08-29 00:51:27.067612+00'),
	('64b3b183-a720-4331-983a-1b038ce05149', 'ru', 'Har lösningen internationell potential?', 'Есть ли у решения международный потенциал?', '2026-08-29 00:51:27.067612+00'),
	('fb08b47d-bf87-4268-833e-7e38270d93be', 'ru', 'Har ni en partnergrupp i ett annat land?', 'Есть ли у вас партнёрская группа в другой стране?', '2026-08-29 00:51:27.067612+00');
INSERT INTO public.kb_translations VALUES
	('ca8633ae-f3b3-42db-8eb4-105d43334901', 'ru', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Есть ли у вас партнёрская организация в другой европейской стране?', '2026-08-29 00:51:27.067612+00'),
	('89738606-125e-4939-a977-1ab80f8d82ff', 'ru', 'Har ni partner i minst tre olika europeiska länder?', 'Есть ли у вас партнёры как минимум в трёх разных европейских странах?', '2026-08-29 00:51:27.067612+00'),
	('ca48a6ff-5a45-4809-b640-043267e3c86f', 'ru', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Находится ли ваш офис или основная деятельность в регионе, где вы подаёте заявку?', '2026-08-29 00:51:27.067612+00'),
	('b5dce318-c2d5-4a27-bfbc-b6f7731a8140', 'ru', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Есть ли у кого-то из ваших детей инвалидность, из-за которой ребёнку нужно больше ухода или присмотра, чем другим детям того же возраста?', '2026-08-29 00:51:27.067612+00'),
	('476033d4-f776-46fa-95fb-8eb929df872f', 'ru', 'Har organisationen en demokratisk uppbyggnad?', 'Есть ли у организации демократическое устройство?', '2026-08-29 00:51:27.067612+00'),
	('c6cd78bb-daf6-45fc-ade2-89554b17d940', 'ru', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Есть ли у организации Quality Label (знак качества)?', '2026-08-29 00:51:27.067612+00'),
	('84d780b5-9b76-4acb-bf62-c659065b3eba', 'ru', 'Har organisationen ett 90-konto?', 'Есть ли у организации 90-konto?', '2026-08-29 00:51:27.067612+00'),
	('1b729e49-71dc-49e2-8ee4-13bfc04bb474', 'ru', 'Har organisationen ett OID (Organisation ID)?', 'Есть ли у организации OID (Organisation ID)?', '2026-08-29 00:51:27.067612+00'),
	('4ecec5e9-40c5-4d33-8376-70cd1d8c0574', 'ru', 'Har organisationen ett OID?', 'Есть ли у организации OID?', '2026-08-29 00:51:27.067612+00'),
	('e6474911-186e-4f10-9596-e4d6da7a4fd8', 'ru', 'Har organisationen medlemsföreningar i flera län?', 'Есть ли у организации объединения-члены в нескольких ленах?', '2026-08-29 00:51:27.067612+00'),
	('53c31941-8f58-4da8-8348-6b1d45529292', 'ru', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Есть ли у организации упорядоченные финансы и демократическое устройство?', '2026-08-29 00:51:27.067612+00'),
	('ce935f3d-b108-447e-aa7a-42c529f4cf44', 'ru', 'Har projektet en partner i ett annat land?', 'Есть ли у проекта партнёр в другой стране?', '2026-08-29 00:51:27.067612+00'),
	('7776fb18-a596-4e5b-bc98-cfb78bc9604e', 'ru', 'Har projektledaren doktorsexamen?', 'Есть ли у руководителя проекта докторская степень?', '2026-08-29 00:51:27.067612+00'),
	('7397eaa1-6233-467b-b77d-f862f0a60baa', 'ru', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Домашняя коммуна должна обеспечивать ежедневные поездки между домом и гимназией, если дорога составляет не менее шести километров (например, проездной на автобус).', '2026-08-29 00:51:27.067612+00'),
	('4611f5d1-2696-49bc-969b-e4f98a5b551c', 'ru', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Обзаводитесь ли вы своим первым собственным жильём в Швеции или обустраиваете его?', '2026-08-29 00:51:27.067612+00'),
	('ccd70327-a8e5-4b74-82b9-6fe91da7b381', 'ru', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Включает ли проект международную поездку или обмен?', '2026-08-29 00:51:27.067612+00'),
	('872bec08-ef86-4346-ac83-d3ebc90cf223', 'ru', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Инвестиционная поддержка компаниям в зонах поддержки — на здания, оборудование и обучение.', '2026-08-29 00:51:27.067612+00'),
	('4a2d7ffa-17cf-4414-85f2-92e84690a59f', 'ru', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Инвестиционная поддержка мер, снижающих выбросы парниковых газов.', '2026-08-29 00:51:27.067612+00'),
	('98947208-ea7a-4270-92ae-8d60acf42e52', 'ru', 'Kan projektets miljönytta mätas?', 'Можно ли измерить экологическую пользу проекта?', '2026-08-29 00:51:27.067612+00'),
	('b02b86c5-8a3e-46f1-bf3a-1615edd7674e', 'ru', 'Kan åtgärdens utsläppsminskning beräknas?', 'Можно ли рассчитать снижение выбросов от меры?', '2026-08-29 00:51:27.067612+00'),
	('ab048666-ad60-4997-a7b8-d8d812b0e9bc', 'ru', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Может ли организация нести расходы до выплаты поддержки?', '2026-08-29 00:51:27.067612+00'),
	('7042a200-3996-4b02-801d-f81c7bf9eaa9', 'ru', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Будет ли опыт использоваться в вашей деятельности в Швеции?', '2026-08-29 00:51:27.067612+00'),
	('2e127733-ab64-4f1e-a948-d68177c1c14a', 'ru', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Начнётся ли инвестиция только после подачи заявки?', '2026-08-29 00:51:27.067612+00'),
	('59e8f164-04e6-4c01-8103-801a1c82e9b9', 'ru', 'Kommer projektet människor i ert närområde till del?', 'Приносит ли проект пользу людям в вашей местности?', '2026-08-29 00:51:27.067612+00'),
	('a8969cda-4a95-43c0-aa6a-fff81f3caa35', 'ru', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Крайняя экономическая защита коммуны, когда доходов не хватает на самое необходимое.', '2026-08-29 00:51:27.067612+00'),
	('c2b9149e-12a7-4b14-aeba-a574fdfa51c7', 'ru', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Собственная поддержка коммун местным объединениям: пособие за занятие, помощь с помещениями, стартовое пособие и другое.', '2026-08-29 00:51:27.067612+00'),
	('46e9ddb7-b954-466c-8f20-200eaadb25ac', 'ru', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Бесплатный школьный транспорт для учеников основной школы при большом расстоянии, опасной дороге или инвалидности — право по школьному закону.', '2026-08-29 00:51:27.067612+00'),
	('febaf49c-2218-469a-99a8-7b8218d13570', 'ru', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Установленное законом пособие на очки или линзы для детей и молодёжи; суммы и порядок различаются по регионам — проверьте уровень своего региона.', '2026-08-29 00:51:27.067612+00'),
	('1d89c911-1f07-488e-9e4d-30726fcaacc6', 'ru', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Находится ли проект в местности, затронутой гидро- или ветроэнергетикой?', '2026-08-29 00:51:27.067612+00'),
	('98af102d-e4c6-4c70-89fb-177676b05983', 'uk', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Чи веде об''єднання регулярну діяльність у комуні?', '2026-08-29 00:51:27.076815+00'),
	('377da2c8-691e-447e-bb69-db409f6f3122', 'ru', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Относится ли проект к окружающей среде, аграрным наукам или градостроительству?', '2026-08-29 00:51:27.067612+00'),
	('431c83f9-2f88-42a2-a54e-2bc2201864ec', 'ru', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Находится ли место деятельности в зоне поддержки A или B (большая часть Норрланда и внутреннего Свеаланда)?', '2026-08-29 00:51:27.067612+00'),
	('0a97da37-86b4-465f-a7ee-6c066400bfa0', 'ru', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Заём на покупку самого необходимого для первого дома в Швеции — мебели, домашней утвари и другого базового оснащения.', '2026-08-29 00:51:27.067612+00'),
	('42f1a240-d4b9-4124-a36a-23b3eebb9b81', 'ru', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Снижает ли проект технологические выбросы промышленности или создаёт отрицательные выбросы?', '2026-08-29 00:51:27.067612+00'),
	('5ba7da26-d87d-4e09-ada9-9324c3e07978', 'ru', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Ежемесячное пособие на детей, живущих в Швеции, от рождения до 16 лет.', '2026-08-29 00:51:27.067612+00'),
	('14ab75c5-e90d-439d-a6b5-365dc63e3e9f', 'ru', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket предлагает пособия организациям, компаниям, объединениям, публичному сектору и частным лицам в сфере экологии.', '2026-08-29 00:51:27.067612+00'),
	('c4c1b93a-497e-4d52-822a-226eff89eb82', 'ru', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Планируете ли вы добровольно навсегда вернуться в страну происхождения?', '2026-08-29 00:51:27.067612+00'),
	('5cc7a934-0fcd-4832-9612-c83a852e65df', 'ru', 'Planerar du att starta eget företag?', 'Планируете ли вы открыть собственное дело?', '2026-08-29 00:51:27.067612+00'),
	('451c7aa6-e2a6-4865-b5b9-48da7cf78418', 'ru', 'Planerar du att studera utomlands?', 'Планируете ли вы учиться за границей?', '2026-08-29 00:51:27.067612+00'),
	('dd9da4b2-bb58-4810-9e6e-c1b0d56845c4', 'ru', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Планируете ли вы учёбу, укрепляющую вашу позицию на рынке труда?', '2026-08-29 00:51:27.067612+00'),
	('b9fd51d0-9bb8-4c73-ab93-902e3527fdcd', 'ru', 'Planerar ni att anställa?', 'Планируете ли вы нанимать сотрудников?', '2026-08-29 00:51:27.067612+00'),
	('ccf01d9a-924a-4447-a5b8-c6e7bc621b87', 'ru', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Планируете ли вы подавать заявку на программу ЕС (например, Horisont Europa)?', '2026-08-29 00:51:27.067612+00'),
	('0b82050b-73ef-4b14-a262-c39e182e4bae', 'ru', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Поддержка производства и разработки короткометражных и документальных фильмов.', '2026-08-29 00:51:27.067612+00'),
	('ac551ea1-0176-41b4-93fc-d42154b2f17b', 'ru', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Проектные пособия свободной музыкальной сцене на концерты, производство и развитие.', '2026-08-29 00:51:27.067612+00'),
	('c0c02caf-5c4e-4e42-a051-4d74003b1c5a', 'ru', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Проектные пособия некоммерческим организациям, работающим с детьми и молодёжью и для них.', '2026-08-29 00:51:27.067612+00'),
	('29ded78e-ddff-476b-be09-dedeb8aebc54', 'ru', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Пробует ли проект новые художественные выражения, методы или сотрудничества?', '2026-08-29 00:51:27.067612+00'),
	('34b7453d-ef93-458f-a033-22118a39c122', 'ru', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Длится ли обмен 5–21 день (без учёта дней в пути)?', '2026-08-29 00:51:27.067612+00'),
	('5f5029b2-5145-49ce-969c-38e1439e7712', 'ru', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Собственная проектная и операционная поддержка регионов культурной жизни, наряду с национальными пособиями Kulturrådet.', '2026-08-29 00:51:27.067612+00'),
	('c44a3e42-8d98-4330-904f-b6b38debbd36', 'ru', 'Riktar sig projektet till barn eller unga?', 'Адресован ли проект детям или молодёжи?', '2026-08-29 00:51:27.067612+00'),
	('3826d79f-f670-43af-87b4-ad40ff90137c', 'ru', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Адресован ли проект детям, молодёжи, пожилым или людям с инвалидностью?', '2026-08-29 00:51:27.067612+00');
INSERT INTO public.kb_translations VALUES
	('62bf66e7-da1c-42a2-bc04-6747e29f7441', 'ru', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Адресована ли деятельность детям и молодёжи (7–25 лет)?', '2026-08-29 00:51:27.067612+00'),
	('c7b03578-8971-40c8-b06b-5d837e89d59b', 'ru', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'У вас нет сбережений или активов, которые могли бы покрыть расходы?', '2026-08-29 00:51:27.067612+00'),
	('eab72f6c-5b34-4dfa-8ce1-3e58e4798f72', 'ru', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Сотрудничаете ли вы с партнёрами как минимум в двух других северных странах?', '2026-08-29 00:51:27.067612+00'),
	('402c932d-a10f-407a-a729-5f9ac0e00d8b', 'ru', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Собираетесь ли вы привлечь внешнюю экспертизу для меры развития?', '2026-08-29 00:51:27.067612+00'),
	('bc4d831d-8c00-42c2-9090-fd92ac9f3317', 'ru', 'Sker mobiliteten till ett annat europeiskt land?', 'Направлена ли мобильность в другую европейскую страну?', '2026-08-29 00:51:27.067612+00'),
	('e4a228b6-4114-4dc4-bfc7-a68d67f75113', 'ru', 'Startar du eller tar du över företaget för första gången?', 'Открываете ли вы предприятие или берёте его на себя впервые?', '2026-08-29 00:51:27.067612+00'),
	('dab5be7f-1676-440f-b304-43b1d29cc153', 'ru', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Стартовая поддержка для тех, кому 40 лет или меньше, кто открывает сельскохозяйственное предприятие или берёт его на себя.', '2026-08-29 00:51:27.067612+00'),
	('4723e78d-7412-455b-9445-971896df08cc', 'ru', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Стипендия, позволяющая профессиональным художникам сосредоточиться на художественной работе.', '2026-08-29 00:51:27.067612+00'),
	('138c5f08-e8f5-4cad-8859-24d6e47ed1b8', 'ru', 'Studerar du, eller planerar du att börja studera?', 'Учитесь ли вы или планируете начать учёбу?', '2026-08-29 00:51:27.067612+00'),
	('bdd3d865-0a95-43d7-ad7a-0dd0e3825ddf', 'ru', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Существенно ли новаторское ваше решение по сравнению с уже существующим?', '2026-08-29 00:51:27.071194+00'),
	('d2117c8b-413b-4190-81b2-336136d591bc', 'ru', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Учебная поддержка для работающих взрослых, желающих получить образование для укрепления позиции на рынке труда.', '2026-08-29 00:51:27.067612+00'),
	('7c1c15b0-a786-48e2-b52e-dc47717db895', 'ru', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Поддержка инвестиций, повышающих конкурентоспособность или снижающих воздействие на окружающую среду в сельскохозяйственных предприятиях.', '2026-08-29 00:51:27.067612+00'),
	('ab62b7ab-e6f3-48d4-bf45-3ba3cf90218f', 'ru', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Поддержка, когда ребёнок живёт с вами, а другой родитель не платит содержание.', '2026-08-29 00:51:27.067612+00'),
	('0a8d611d-c215-4de1-8243-4b27ffd711d8', 'ru', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Поддержка проектов некоммерческих организаций для людей, окружающей среды и лучшего мира.', '2026-08-29 00:51:27.067612+00'),
	('f4e22f48-b1dc-4416-ae4b-cb69577da2b3', 'ru', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Поддержка перехода промышленности к нулевым выбросам парниковых газов.', '2026-08-29 00:51:27.067612+00'),
	('dafc2b4e-55bb-4ac3-a8b4-e13bda613717', 'ru', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Поддержка художественных и культурных проектов с северным измерением и трансграничным сотрудничеством.', '2026-08-29 00:51:27.067612+00'),
	('6163f6af-0324-404e-b6c7-5fa9244ed82e', 'ru', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Поддержка новаторских культурных проектов, пробующих новые художественные выражения, методы или сотрудничества.', '2026-08-29 00:51:27.067612+00'),
	('ca5eee80-623a-485d-977e-e61cd19ac599', 'ru', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Поддержка новаторских проектов для детей, молодёжи, пожилых и людей с инвалидностью.', '2026-08-29 00:51:27.067612+00'),
	('7382301f-885c-4ae7-91fc-5951fdf468fb', 'ru', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Поддержка проектов сотрудничества в свободной музыкальной сцене.', '2026-08-29 00:51:27.067612+00'),
	('90938be4-c01e-473e-92ad-2e3aa62d37ed', 'ru', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Поддержка проектов сотрудничества в культуре и медиа, укрепляющих демократию и свободу слова на международном уровне.', '2026-08-29 00:51:27.067612+00'),
	('c07931cb-c4a1-4a09-8b22-70e50c7483b7', 'ru', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Направлен ли проект на укрепление демократии, равенства или свободы слова?', '2026-08-29 00:51:27.067612+00'),
	('a58d5fd0-84a2-400b-916c-b72685dfc14e', 'ru', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Ищете ли вы работу или получили предложение о работе в другой стране ЕС или ЕЭЗ?', '2026-08-29 00:51:27.067612+00'),
	('689b3c65-51c9-4fe0-b287-7acd679a2d3e', 'ru', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Потолок того, что вы платите в виде пациентских сборов за двенадцать месяцев — затем frikort (бесплатная карта).', '2026-08-29 00:51:27.067612+00'),
	('14fddf5a-f1cc-4db7-920b-1ebc60d5ff56', 'ru', 'Tar du ut hel allmän pension?', 'Получаете ли вы полную государственную пенсию?', '2026-08-29 00:51:27.067612+00'),
	('84508bbf-c6d0-4bdb-9618-0169de99f275', 'ru', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Надбавка, покрывающая часть расходов на жильё для тех, у кого пенсия и низкие доходы.', '2026-08-29 00:51:27.067612+00'),
	('cefde016-8cf3-4187-964d-23185901dd4e', 'ru', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Ежегодное организационное пособие национальным детским и молодёжным организациям.', '2026-08-29 00:51:27.067612+00'),
	('731957a0-d30d-4bca-b078-eb9b41992536', 'ru', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Ежегодная сумма, вычитаемая напрямую у стоматолога или зубного гигиениста.', '2026-08-29 00:51:27.067612+00'),
	('1575687b-d642-48da-a36f-7a4d26b40fae', 'ru', 'Är bolaget yngre än cirka 5 år?', 'Компании меньше примерно 5 лет?', '2026-08-29 00:51:27.067612+00'),
	('8d94f580-6f05-495c-a9a1-39bd9c41ae3d', 'ru', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Участникам обмена от 13 до 30 лет?', '2026-08-29 00:51:27.067612+00'),
	('0e1abaae-ec65-421d-acd6-d216a29d6709', 'ru', 'Är det här ert första EU-projekt?', 'Это ваш первый проект ЕС?', '2026-08-29 00:51:27.067612+00'),
	('8578e8f2-c827-47af-99d2-16b5bd39c2cc', 'ru', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Очень ли трудно вам (или вашему ребёнку) передвигаться самостоятельно или ездить на автобусе и поезде?', '2026-08-29 00:51:27.067612+00'),
	('642ccc21-9a36-437f-bdd3-7e76fd30f45c', 'ru', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Ваш доход ниже примерно 25 000 крон в месяц до налогов?', '2026-08-29 00:51:27.067612+00'),
	('de5cfb71-4569-47e9-a82e-9c54812fb167', 'ru', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Ваше последнее законченное образование — основная школа или незаконченная гимназия?', '2026-08-29 00:51:27.067612+00'),
	('acc5e76c-4805-4a5d-8912-6ad546c4cd6d', 'ru', 'Är du 40 år eller yngre?', 'Вам 40 лет или меньше?', '2026-08-29 00:51:27.067612+00'),
	('1b0af9aa-1baf-4bc7-a8d3-f94907f21e57', 'ru', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Зарегистрированы ли вы как ищущий работу в Arbetsförmedlingen?', '2026-08-29 00:51:27.067612+00'),
	('caea9803-c195-4642-be08-50404a481b6b', 'ru', 'Är du mellan 18 och 28 år?', 'Вам от 18 до 28 лет?', '2026-08-29 00:51:27.067612+00'),
	('8f6fbe66-0333-48dd-b82f-59513129d082', 'ru', 'Är du mellan 19 och 29 år?', 'Вам от 19 до 29 лет?', '2026-08-29 00:51:27.067612+00'),
	('54f67daf-d231-42cd-82f6-1574b2a20b12', 'ru', 'Är du mellan 25 och 60 år?', 'Вам от 25 до 60 лет?', '2026-08-29 00:51:27.067612+00'),
	('2c20d087-6f02-484e-842d-d2eb54d551ab', 'ru', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Работаете ли вы профессионально в сфере культуры (например, танец, музыка, сценическое искусство)?', '2026-08-29 00:51:27.067612+00'),
	('a565d513-b8f0-4a0d-9ceb-7ed45794bddf', 'ru', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Вы профессиональный художник (не любитель и не на базовом обучении)?', '2026-08-29 00:51:27.067612+00'),
	('ed546d3d-f712-4b68-a454-6bc56737c86c', 'ru', 'Är du yrkesverksam konstnär?', 'Вы профессиональный художник?', '2026-08-29 00:51:27.067612+00'),
	('b778ff37-75c3-4665-9ad1-51c4f37aad95', 'ru', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Входит ли клуб в специализированную спортивную федерацию в составе Riksidrottsförbundet?', '2026-08-29 00:51:27.071194+00'),
	('5be60fa0-c351-4043-98f8-25151c05ce96', 'ru', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Низки ли доходы семьи по отношению к расходам на жильё?', '2026-08-29 00:51:27.071194+00'),
	('e0c256d7-3b85-4a3a-9fc0-381731b07167', 'ru', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Совокупный доход семьи ниже примерно 25 000 крон в месяц до налогов?', '2026-08-29 00:51:27.071194+00'),
	('e2eb5a0e-f746-49b6-936e-b57ac4ec7e71', 'ru', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Является ли мера отдельным проектом (а не обычной деятельностью)?', '2026-08-29 00:51:27.071194+00'),
	('4ffd824d-c841-4756-b74c-8ba8292209ff', 'ru', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Открыто ли помещение для всех — не только для собственных членов?', '2026-08-29 00:51:27.071194+00'),
	('573d58ee-a80a-4d9b-9ff3-70392c6afa00', 'ru', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Не менее 60 % членов в возрасте от 6 до 25 лет?', '2026-08-29 00:51:27.071194+00'),
	('0733a687-5c72-456e-8dd6-32f68b472236', 'ru', 'Är minst 60 % av medlemmarna under 26 år?', 'Не менее 60 % членов младше 26 лет?', '2026-08-29 00:51:27.071194+00'),
	('2a7ccaeb-c219-4649-bd0d-c03e258d8427', 'ru', 'Är målgruppen delaktig i planering och genomförande?', 'Участвует ли целевая группа в планировании и реализации?', '2026-08-29 00:51:27.071194+00'),
	('4eed3b68-aa43-4c45-b035-85339e87e753', 'ru', 'Är ni ett förlag med professionell utgivning?', 'Вы издательство с профессиональным книгоизданием?', '2026-08-29 00:51:27.071194+00');
INSERT INTO public.kb_translations VALUES
	('5c67b16d-a4b4-4f35-a4ea-eb99e46ccc4a', 'ru', 'Är ni huvudman för förskoleklass eller grundskola?', 'Являетесь ли вы ответственной организацией дошкольного класса или основной школы?', '2026-08-29 00:51:27.071194+00'),
	('739110f7-b286-4932-b97d-7bb68365a8c2', 'ru', 'Är organisationen registrerad i EU:s deltagarregister?', 'Зарегистрирована ли организация в реестре участников ЕС?', '2026-08-29 00:51:27.071194+00'),
	('7c14ca04-3480-427f-ab5b-20bc3aa6daab', 'ru', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Это кинопроект (короткометражный или документальный фильм)?', '2026-08-29 00:51:27.071194+00'),
	('f8936dd1-175a-4798-a4f3-f7f26b1ccc3b', 'ru', 'Är projektet ett konst- eller kulturprojekt?', 'Это художественный или культурный проект?', '2026-08-29 00:51:27.071194+00'),
	('2b3b8eaf-b96b-4549-8576-91569c009671', 'ru', 'Är projektet ett kulturprojekt?', 'Это культурный проект?', '2026-08-29 00:51:27.071194+00'),
	('7261595f-e0ce-48ac-951e-f93a3433b644', 'ru', 'Är projektet ett musikprojekt?', 'Это музыкальный проект?', '2026-08-29 00:51:27.071194+00'),
	('fa8dac08-ad23-4aef-88d8-76f897772c19', 'ru', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Новаторский ли проект — то, чего вы ещё не делаете в обычной деятельности?', '2026-08-29 00:51:27.071194+00'),
	('88392823-70a2-4937-b53e-e99ac5173a5f', 'ru', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Приносит ли проект пользу местности в целом (а не отдельным лицам)?', '2026-08-29 00:51:27.071194+00'),
	('d40d01dc-0936-48b6-9491-ed6d565f30bd', 'ru', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Дорога между домом и гимназией составляет не менее шести километров?', '2026-08-29 00:51:27.071194+00'),
	('609d00a5-d253-455a-bb2a-bdcc56b14c33', 'ru', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Профессиональная ли это деятельность (не любительская)?', '2026-08-29 00:51:27.071194+00'),
	('2b7a3e2a-de1b-455c-9ecb-4d73d8bbc78c', 'ru', 'Är verksamheten professionell?', 'Профессиональная ли это деятельность?', '2026-08-29 00:51:27.071194+00'),
	('b0cae28b-2320-4f40-9d81-15dce0cb39b0', 'ru', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Относится ли деятельность к сценическому искусству (танец, театр, музыкальный театр)?', '2026-08-29 00:51:27.071194+00'),
	('a20f7f7e-17b9-4dbe-833d-a0f4c052607a', 'ru', 'Är volontärerna mellan 18 och 30 år?', 'Волонтёрам от 18 до 30 лет?', '2026-08-29 00:51:27.071194+00'),
	('590afc27-4bb3-4aeb-8848-a395b5ffa5d2', 'uk', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Підтримка діяльності спортивних клубів, що проводять заняття під керівництвом тренерів для дітей та молоді 7–25 років.', '2026-08-29 00:51:27.076815+00'),
	('c26241a1-9498-4f55-b6ee-caad32f565b9', 'uk', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Автоматична надбавка до дитячої допомоги (barnbidrag) починаючи з другої дитини.', '2026-08-29 00:51:27.076815+00'),
	('1c7c7066-1383-4ee3-ad6d-2fe655af8f5f', 'uk', 'Avser ansökan en fysisk investering?', 'Чи стосується заявка фізичної інвестиції?', '2026-08-29 00:51:27.076815+00'),
	('8f4772b9-52a2-4227-aa8d-fd454e9ac8d2', 'uk', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Чи стосується заявка міжнародної поїздки або обміну?', '2026-08-29 00:51:27.076815+00'),
	('36ef2804-eb8e-4a26-b1c0-5d5777defd38', 'uk', 'Avser ansökan en investering i byggnader eller maskiner?', 'Чи стосується заявка інвестиції в будівлі або обладнання?', '2026-08-29 00:51:27.076815+00'),
	('20c8209d-4e8f-4697-b363-a08703e1c027', 'uk', 'Avser ansökan en redan utgiven titel?', 'Чи стосується заявка вже виданого твору?', '2026-08-29 00:51:27.076815+00'),
	('3e79dd52-9c29-4d7b-b28f-6f0665d7ddba', 'uk', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Чи стосується заявка сільськогосподарського, садівничого чи оленярського підприємства?', '2026-08-29 00:51:27.076815+00'),
	('631fe9bc-f1d8-4b88-8572-9266e7fa73fa', 'uk', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Чи стосується заявка закупівлі літератури для публічних або шкільних бібліотек?', '2026-08-29 00:51:27.076815+00'),
	('87d2afef-3f07-4a89-aabe-9a017e4f78c3', 'uk', 'Avser investeringen jordbruksverksamhet?', 'Чи стосується інвестиція сільськогосподарської діяльності?', '2026-08-29 00:51:27.076815+00'),
	('52a4ca10-d1cf-49ec-ad13-b34043f33818', 'uk', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Чи передбачає проєкт будівництво, купівлю або ремонт приміщення?', '2026-08-29 00:51:27.076815+00'),
	('0723d494-a502-4ef0-86f3-9327687ed9ac', 'uk', 'Avser projektet naturvård eller friluftsliv?', 'Чи стосується проєкт охорони природи або активного відпочинку на природі?', '2026-08-29 00:51:27.076815+00'),
	('ed15dea4-a32a-4162-afec-452f82c2c2cf', 'uk', 'Avser projektet skola eller vuxenutbildning?', 'Чи стосується проєкт школи або освіти дорослих?', '2026-08-29 00:51:27.076815+00'),
	('da4b0f21-4408-435c-b634-609d906c231b', 'uk', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Чи відмовляєтеся ви від роботи, щоб доглядати за близькою людиною або бути поруч із нею, коли хвороба настільки тяжка, що загрожує її життю?', '2026-08-29 00:51:27.076815+00'),
	('2914e380-4d07-42cf-8753-d5baab69d221', 'uk', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Чи вважаєте ви, що ваша працездатність знижена щонайменше на рік через хворобу або інвалідність?', '2026-08-29 00:51:27.076815+00'),
	('cc3296bc-887c-4bf7-af62-8ec092c14d7d', 'uk', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Адресна підтримка для тих, хто має низьку пенсію або не має її, і потребує допомоги для досягнення прийнятного рівня життя.', '2026-08-29 00:51:27.076815+00'),
	('69b38951-3e95-4b97-921b-ac63d8ec3459', 'uk', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Чи потрібно дитині жити в місці навчання (проживання), бо дорога надто довга?', '2026-08-29 00:51:27.076815+00'),
	('350ea844-3dca-434a-ba78-9494a1de1383', 'uk', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Чи потрібно адаптувати житло (наприклад, пандус, автоматичні двері, ванна)?', '2026-08-29 00:51:27.076815+00'),
	('071329a0-128f-4231-a361-53021af5bbef', 'uk', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Чи потрібні комусь із ваших дітей 8–19 років окуляри або лінзи?', '2026-08-29 00:51:27.076815+00'),
	('00424e03-5af9-476b-9107-37846632f16c', 'uk', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Другий із батьків не платить нічого або платить менше за повне утримання?', '2026-08-29 00:51:27.076815+00'),
	('cacd3d95-d0b2-459c-97d6-0449e6c6610d', 'uk', 'Betalar du hyra eller andra boendekostnader?', 'Чи сплачуєте ви оренду або інші витрати на житло?', '2026-08-29 00:51:27.076815+00'),
	('897bbfe8-2f85-4bf9-b489-c0798274e321', 'uk', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Допомога на адаптацію житла при інвалідності — наприклад, пандуси, автоматичні двері чи переобладнання ванної.', '2026-08-29 00:51:27.076815+00'),
	('96d08aac-e4f1-4f4f-b80e-f607673567bf', 'uk', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Допомоги на будівництво, купівлю або ремонт громадських приміщень для зібрань.', '2026-08-29 00:51:27.076815+00'),
	('cfedecd0-8877-46d3-986c-e1537c90872e', 'uk', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Допомога на купівлю або адаптацію автомобіля, коли стійка інвалідність значно ускладнює пересування чи поїздки громадським транспортом.', '2026-08-29 00:51:27.076815+00'),
	('e5e0a3da-5698-4504-aaea-46dd40496cb2', 'uk', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Допомоги на міжнародні поїздки та обміни для професіоналів у сфері культури.', '2026-08-29 00:51:27.076815+00'),
	('553a2574-488a-4f4c-8fc3-ee347755ff81', 'uk', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Допомоги на міжнародні обміни, поїздки та робочі перебування професійних митців.', '2026-08-29 00:51:27.076815+00'),
	('b2add33a-74bd-4426-bf05-eccd8b7786d9', 'uk', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Допомога та добровільна позика для навчання на гімназійному або післягімназійному рівні.', '2026-08-29 00:51:27.076815+00'),
	('1dc8dfc1-23e2-43ae-8a3c-63eff5379aeb', 'uk', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Допомоги й позики для навчання за кордоном, з додатковими позиками, наприклад, на плату за навчання та поїздки.', '2026-08-29 00:51:27.076815+00'),
	('39932af4-ce0b-462d-8365-f4c99c9db7bb', 'uk', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Допомога, що допомагає шведським організаціям готувати заявки на програми ЄС, як-от Horisont Europa.', '2026-08-29 00:51:27.076815+00'),
	('c1d8b8d1-f468-4f8b-a329-4a3fa4eb0733', 'uk', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Допомога роботодавцям, які наймають людей зі зниженою працездатністю.', '2026-08-29 00:51:27.076815+00'),
	('89dd9520-ee51-4f53-bda0-65c55ae23de9', 'uk', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Допомога на проживання та поїздки додому, коли гімназист мусить жити в місці навчання через довгу дорогу.', '2026-08-29 00:51:27.076815+00'),
	('869aa999-74e0-4b79-9994-95409ee3e895', 'uk', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Допомоги на роботу неприбуткових організацій зі збереження, використання та розвитку культурної спадщини.', '2026-08-29 00:51:27.076815+00'),
	('505ecfc4-faa8-4684-bee4-8dedfe49aa2f', 'uk', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Допомоги на муніципальні та місцеві природоохоронні проєкти, включно з водно-болотними угіддями та активним відпочинком.', '2026-08-29 00:51:27.076815+00'),
	('53c9b9aa-7a98-46d3-8e5b-fcae2a80daae', 'uk', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Допомоги комунам на закупівлю літератури для публічних і шкільних бібліотек.', '2026-08-29 00:51:27.076815+00'),
	('e502f676-27b2-49cc-8793-22f75105e5c0', 'uk', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Допомоги шкільним організаціям для знайомства учнів основної школи з професійною культурою.', '2026-08-29 00:51:27.076815+00'),
	('0387de05-b077-4422-9273-e77f3bbd5d2d', 'uk', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Допомога на те, що потрібно вашій дитині, але на що не вистачає сімейного бюджету: дозвілля, одяг, шкільні екскурсії, окуляри, канікулярні заняття тощо.', '2026-08-29 00:51:27.076815+00'),
	('cd1c706b-83bb-4d26-b796-25208126086e', 'uk', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Допомоги з фондів Världens Barn, Musikhjälpen і Victoriafonden — їх запитують шведські неприбуткові організації з 90-konto.', '2026-08-29 00:51:27.076815+00'),
	('10dc8b8b-baca-4e31-94a8-35cf19205edf', 'uk', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Допомоги з коштів гідро- та вітроенергетики на проєкти, що розвивають місцевість.', '2026-08-29 00:51:27.076815+00');
INSERT INTO public.kb_translations VALUES
	('15e31b15-9a69-480b-81f8-8563f7767221', 'so', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Khibradaha ma loo isticmaali doonaa hawshaada Sweden gudaheeda?', '2026-08-29 00:51:27.085901+00'),
	('691c01b3-a51a-4068-8aff-7cd28e5795c9', 'uk', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Допомога без позикової частини для безробітних 25–60 років із короткою освітою, яким потрібно вчитися на рівні основної школи або гімназії.', '2026-08-29 00:51:27.076815+00'),
	('4ecb2e3f-6fc1-4366-a2f9-dafedc871962', 'uk', 'Bidrar projektet till energiomställningen?', 'Чи робить проєкт внесок в енергетичний перехід?', '2026-08-29 00:51:27.076815+00'),
	('a6dd5a10-e77e-4dbc-aff2-6e56f7ce44e6', 'uk', 'Bor du och barnets andra förälder på skilda håll?', 'Чи живете ви й другий із батьків дитини окремо?', '2026-08-29 00:51:27.076815+00'),
	('fe988427-18db-4fae-a0a7-2ab0c5946171', 'uk', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Чеки для малих підприємств на залучення зовнішньої експертизи для інтернаціоналізації або цифровізації.', '2026-08-29 00:51:27.076815+00'),
	('4ebbccc9-6eb9-4221-8e0e-19c7cf5a73ee', 'uk', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Чи берете ви участь у програмі Arbetsförmedlingen (наприклад, jobb- och utvecklingsgarantin)?', '2026-08-29 00:51:27.076815+00'),
	('8275bc79-6a1a-4c5a-b283-32d61f790d7d', 'uk', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Подальша підтримка видавництвам за випуск якісної літератури.', '2026-08-29 00:51:27.076815+00'),
	('460cd1b4-9f78-46c5-8cc3-cfc0312438d9', 'uk', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Економічна підтримка для тих, хто має посвідку на проживання за захистом і добровільно хоче назавжди повернутися до країни походження.', '2026-08-29 00:51:27.076815+00'),
	('5a1f550a-aa4a-4c4b-a424-4c55a55e336c', 'uk', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Економічна підтримка роботодавцям, які наймають людину, що довго не працювала.', '2026-08-29 00:51:27.076815+00'),
	('383ac403-d29f-4eaf-851e-4dc78031b0a6', 'uk', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Економічна підтримка на етапі запуску для шукачів роботи, які відкривають власну справу.', '2026-08-29 00:51:27.076815+00'),
	('d0d17e5f-5262-4b71-986d-05e1141d4595', 'uk', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten постійно відкриває конкурси в галузі енергетичних досліджень, інновацій та енергоефективності.', '2026-08-29 00:51:27.076815+00'),
	('8d3259f8-e411-499e-8642-7611b33d0cad', 'uk', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Виплата за відсутність на роботі чи навчанні для догляду за дитиною.', '2026-08-29 00:51:27.076815+00'),
	('c486765d-40c2-401c-ab55-ea47e1997b61', 'uk', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Виплата для тих, хто нещодавно у Швеції та бере участь у програмі адаптації Arbetsförmedlingen; виплачує Försäkringskassan.', '2026-08-29 00:51:27.076815+00'),
	('9a5e0c5e-33c9-434c-b457-caaafa881616', 'uk', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Виплата, що покриває частину витрат на житло для молоді без дітей із низькими доходами.', '2026-08-29 00:51:27.076815+00'),
	('47d7538a-8678-4069-984a-9a28bad2673d', 'uk', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Виплата за додаткові витрати, пов''язані зі стійкою інвалідністю — для дорослих або батьків дітей з інвалідністю.', '2026-08-29 00:51:27.076815+00'),
	('5225335a-9493-4e0c-90c8-3dc3faf7b493', 'uk', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Виплата для молоді (19–29 років), яка не може працювати повний день щонайменше рік через хворобу чи інвалідність.', '2026-08-29 00:51:27.076815+00'),
	('718d7c9c-4d88-402f-9905-20d1912207b6', 'uk', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Виплата при стійко зниженій працездатності — те, що раніше називалося förtidspension (дострокова пенсія).', '2026-08-29 00:51:27.076815+00'),
	('42fe7746-5b7d-4201-aaea-ca6482f09fdb', 'uk', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Виплата, коли ви відмовляєтеся від роботи, щоб бути поруч із тяжкохворою близькою людиною.', '2026-08-29 00:51:27.076815+00'),
	('e9e73371-1b99-4c08-85e0-75a2f5bdaa3d', 'uk', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Виплата за участь у програмі ринку праці Arbetsförmedlingen.', '2026-08-29 00:51:27.076815+00'),
	('305c58a0-1660-440f-885b-02f1a6ffc005', 'uk', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Виплата, коли ви не можете працювати як зазвичай через хворобу.', '2026-08-29 00:51:27.076815+00'),
	('ac6b9c8d-eb38-486a-8447-7781b32aabf6', 'uk', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Виплата, коли ви залишаєтеся вдома з роботи для догляду за хворою дитиною.', '2026-08-29 00:51:27.076815+00'),
	('17c06b24-8cd3-4a9e-a905-f4d8c1c0f232', 'uk', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Виплата, що покриває частину витрат на житло для сімей із дітьми та невисокими доходами.', '2026-08-29 00:51:27.076815+00'),
	('918c1fcf-8b36-4fc1-8c74-0b0473b0134f', 'uk', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Виплата батькам, чиї діти через інвалідність потребують більше догляду й нагляду, ніж однолітки.', '2026-08-29 00:51:27.076815+00'),
	('cdfe7d66-9c4f-4655-94e0-fbb66b35f4f2', 'uk', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Виплата при безробітті — на основі доходу для членів каси, базова сума для інших.', '2026-08-29 00:51:27.076815+00'),
	('a4c0dd27-ad30-4fa8-84c4-d0580243b60f', 'uk', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Близько п''ятдесяти фондів ощадних банків надають допомоги місцевим проєктам у спорті, культурі, освіті та розвитку громади — у зоні діяльності банку.', '2026-08-29 00:51:27.076815+00'),
	('45b8e73b-cfb7-40f4-851b-8b4fa7b389ad', 'uk', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Чи присвячений проєкт екологічним або кліматичним заходам?', '2026-08-29 00:51:27.076815+00'),
	('3872bc98-87ff-42e1-88f7-0b6b2b8a5d30', 'uk', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Фінансована ЄС проєктна підтримка, яку запитують у вашій місцевій зоні Leader — для об''єднань, компаній і комун, що розвивають сільську місцевість.', '2026-08-29 00:51:27.076815+00'),
	('f8e21f95-67ba-477b-aad6-5e4f11132a23', 'uk', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Фінансована ЄС підтримка для шукачів роботи, які влаштовуються в іншій країні ЄС/ЄЕП: компенсація поїздки на співбесіду, витрат на переїзд і мовного курсу.', '2026-08-29 00:51:27.076815+00'),
	('7c484ee0-ce1f-4a03-88f2-a2e25e7ce72f', 'uk', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Кошти соціального фонду ЄС на проєкти, що зміцнюють компетенції, перекваліфікацію та інклюзію на ринку праці.', '2026-08-29 00:51:27.076815+00'),
	('c5a226c1-ea60-43f3-8330-1c4e48e9fa47', 'uk', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Підтримка ЄС для групових обмінів молоді 13–30 років, тривалістю 5–21 день без урахування днів у дорозі.', '2026-08-29 00:51:27.076815+00'),
	('f96c681d-b2b8-4d0a-a8ba-1deb9b9aa32d', 'uk', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Підтримка ЄС для проєктів співпраці культурних організацій із партнерами в кількох європейських країнах.', '2026-08-29 00:51:27.076815+00'),
	('a9ccb9da-7bc5-4a25-94a6-c87bdc18a144', 'uk', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Підтримка ЄС для організацій, що приймають або направляють молодих волонтерів 18–30 років.', '2026-08-29 00:51:27.076815+00'),
	('aa7ff98e-af1d-4428-9e7b-73bb8a81a0c7', 'uk', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Підтримка ЄС для мобільності персоналу та учнів у школі та освіті дорослих.', '2026-08-29 00:51:27.076815+00'),
	('ac9f969f-0a03-4043-8d26-73a028418ca8', 'uk', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Підтримка ЄС із фіксованими сумами для перших європейських проєктів співпраці невеликих організацій.', '2026-08-29 00:51:27.076815+00'),
	('e92f2f61-20e2-4eaa-bbe4-7e0e6b83dfca', 'uk', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Фінансування молодих компаній, що розробляють новаторські продукти чи послуги з міжнародним потенціалом.', '2026-08-29 00:51:27.076815+00'),
	('ff720c21-1170-4958-8bd7-e56fa75ce1fe', 'uk', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Чи є ощадний банк (і, отже, фонд ощадного банку) там, де ви ведете діяльність?', '2026-08-29 00:51:27.076815+00'),
	('2c7f5c44-93fb-4ef1-a2e1-4d7149945938', 'uk', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Багаторічні операційні допомоги професійним незалежним колективам танцю, театру та музичного театру.', '2026-08-29 00:51:27.076815+00'),
	('ec89cbc1-4800-480c-96ca-8a333d98a36e', 'uk', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Дослідницькі допомоги в галузях Forte: здоров''я, трудове життя та добробут. Запитують дослідники з докторським ступенем у шведських вишах.', '2026-08-29 00:51:27.076815+00'),
	('8df36b24-3ee5-4e07-8c6d-4bc8b7c591a2', 'uk', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Фінансування вільних фундаментальних досліджень у всіх галузях науки.', '2026-08-29 00:51:27.076815+00'),
	('070a9f6a-b6e3-46b7-bb4e-c4987824bf54', 'uk', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Фінансування досліджень у галузі довкілля, аграрних наук і містобудування.', '2026-08-29 00:51:27.076815+00'),
	('1ea200d0-81e7-4274-90f0-78055dd38fa3', 'uk', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Чи думаєте ви про переїзд за кордон (робота, навчання чи повернення на батьківщину)?', '2026-08-29 00:51:27.076815+00'),
	('acd463a9-9ba4-4556-a831-89ec0271dae0', 'uk', 'Genomförs insatserna av professionella kulturaktörer?', 'Чи проводяться заходи професійними діячами культури?', '2026-08-29 00:51:27.076815+00'),
	('49df5b0a-369e-4a1b-a481-e1cb40f8b3b8', 'uk', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Чи реалізується проєкт у сільській місцевості або невеликому населеному пункті?', '2026-08-29 00:51:27.076815+00'),
	('5896cf69-4df9-4950-af68-1632a4645c0f', 'uk', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Базовий захист для тих, хто протягом життя мав низький трудовий дохід або не мав його.', '2026-08-29 00:51:27.076815+00'),
	('56056cc0-ea42-45fe-8a0f-603c03f775ca', 'uk', 'Går något av dina barn i grundskolan?', 'Чи ходить хтось із ваших дітей до основної школи?', '2026-08-29 00:51:27.076815+00'),
	('0ebe207e-911a-4317-9f28-e1d12bde2533', 'uk', 'Går något av dina barn på gymnasiet?', 'Чи навчається хтось із ваших дітей у гімназії?', '2026-08-29 00:51:27.076815+00'),
	('4c2eef81-7a48-4a6d-a39b-eb8d386401c8', 'uk', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Чи стосується найм людини зі зниженою працездатністю?', '2026-08-29 00:51:27.076815+00'),
	('a10cd21f-35ac-482b-9bef-87f918a2f196', 'uk', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Чи стосується найм людини, яка довго була безробітною або нещодавно приїхала до Швеції?', '2026-08-29 00:51:27.076815+00'),
	('281165eb-b4f6-4b1c-badd-63780339aa55', 'uk', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Чи присвячений проєкт збереженню культурної спадщини або забезпеченню доступу до неї?', '2026-08-29 00:51:27.076815+00'),
	('59f30410-7587-4c14-8071-e7053e15c431', 'uk', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Чи присвячений проєкт енергетиці, енергоефективності або енергетичним інноваціям?', '2026-08-29 00:51:27.076815+00');
INSERT INTO public.kb_translations VALUES
	('826f6cfa-d832-47f8-a57c-aafd45cc0d6b', 'uk', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Чи присвячений проєкт здоров''ю, трудовому життю або добробуту?', '2026-08-29 00:51:27.076815+00'),
	('d7238128-28a2-4ffa-9e86-290969228076', 'uk', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Чи присвячений проєкт розвитку компетенцій або заходам на ринку праці?', '2026-08-29 00:51:27.076815+00'),
	('135925d9-417d-4522-8f3c-2391823b14ec', 'uk', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Чи довга в дитини дорога до школи, небезпечна через рух або складна з інших причин?', '2026-08-29 00:51:27.076815+00'),
	('820a588e-d1ec-4dc5-9fbe-f62325bb6730', 'uk', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Чи працювали ви щонайменше 16 годин на тиждень загалом щонайменше 8 років?', '2026-08-29 00:51:27.076815+00'),
	('355c67c0-aed6-4b22-a562-caac830ed484', 'uk', 'Har du barn som bor hos dig, helt eller växelvis?', 'Чи живуть із вами діти — постійно або почергово?', '2026-08-29 00:51:27.076815+00'),
	('a6bbbfd1-c337-4e29-b5ea-af2a5e452185', 'uk', 'Har du barn som bor hos dig?', 'Чи живуть із вами діти?', '2026-08-29 00:51:27.076815+00'),
	('fd7604d1-6c66-4d8c-b6c3-e199fa00aa78', 'uk', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Чи є у вас або вашої дитини інвалідність, яка, як очікується, триватиме щонайменше рік?', '2026-08-29 00:51:27.076815+00'),
	('2e615a5c-4a84-4514-bc33-0f34c6e9d027', 'uk', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Чи має хтось у родині стійку інвалідність, що впливає на житло?', '2026-08-29 00:51:27.076815+00'),
	('59583efe-fec5-443a-8bcc-743aee1d981d', 'uk', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Чи має хтось із вас або близьких родичів інвалідність або тривалу чи тяжку хворобу?', '2026-08-29 00:51:27.076815+00'),
	('c413917d-3d9e-47b0-a257-34f3e2e692cf', 'uk', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Чи є у вас хвороба або травма, яка зараз знижує вашу працездатність?', '2026-08-29 00:51:27.076815+00'),
	('a0486aa6-3dbb-4ab3-895e-e7e1e93e655e', 'uk', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Чи бувало вам важко оплатити шкільну екскурсію, класну поїздку або дозвіллєве заняття, у якому має брати участь ваша дитина?', '2026-08-29 00:51:27.076815+00'),
	('5545832f-7015-4258-9eb6-1d1979446a0b', 'uk', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Чи важко вам прожити на пенсію та інші доходи?', '2026-08-29 00:51:27.076815+00'),
	('68cb26ae-4b32-493e-9d8e-933da59e18ca', 'uk', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Чи отримували ви останніми роками посвідку на проживання у Швеції, наприклад, як особа, що потребує захисту, або як член сім''ї?', '2026-08-29 00:51:27.076815+00'),
	('37547a2a-d472-418e-88e2-d72ab4f4b13f', 'uk', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Чи маєте ви посвідку на проживання у Швеції як біженець або особа, що потребує захисту (або ви близький родич такої особи)?', '2026-08-29 00:51:27.076815+00'),
	('f976a3e0-28dc-44c5-8c66-6e51088ec33b', 'uk', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Чи досягли ви цільового пенсійного віку (67 років у 2026 році)?', '2026-08-29 00:51:27.076815+00'),
	('5d43f276-1832-4a6d-84cf-30577d35dfee', 'uk', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Чи має ваша організація OID (Organisation ID), зареєстрований в Organisation Registration System ЄС?', '2026-08-29 00:51:27.076815+00'),
	('e8dcb7de-1c68-4436-9c32-f028834e9948', 'uk', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Чи спричинила інвалідність додаткові витрати — наприклад, допоміжні засоби, поїздки, особливе харчування або знос?', '2026-08-29 00:51:27.076815+00'),
	('790abdf1-0101-47e9-98ce-891fd275edf3', 'uk', 'Har föreningen antagna stadgar och en vald styrelse?', 'Чи має об''єднання ухвалений статут та обране правління?', '2026-08-29 00:51:27.076815+00'),
	('b29ec340-470e-4df1-9a99-1c8730a6c186', 'uk', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Чи має об''єднання демократичний устрій (статут, річні збори, правління)?', '2026-08-29 00:51:27.076815+00'),
	('fb2b8d1e-4912-45b2-949d-0368e39df03d', 'uk', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Чи веде об''єднання регулярну діяльність для дітей або молоді?', '2026-08-29 00:51:27.076815+00'),
	('f29f697d-a812-438f-9d06-4e7307449c5b', 'uk', 'Har företaget mellan cirka 2 och 49 anställda?', 'У компанії приблизно від 2 до 49 працівників?', '2026-08-29 00:51:27.076815+00'),
	('503e5004-55a5-4cca-b372-b9151e548152', 'uk', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Чи важко родині покривати витрати на їжу, житло та найнеобхідніше?', '2026-08-29 00:51:27.076815+00'),
	('44013084-c433-4db4-86ce-1dcde1cc49af', 'uk', 'Har lösningen internationell potential?', 'Чи має рішення міжнародний потенціал?', '2026-08-29 00:51:27.076815+00'),
	('b5775d05-654d-4e8a-be30-9c4e7e1be5c9', 'uk', 'Har ni en partnergrupp i ett annat land?', 'Чи є у вас партнерська група в іншій країні?', '2026-08-29 00:51:27.076815+00'),
	('09d632b3-a97f-4e9f-9376-32f8d3c7f8ea', 'uk', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Чи є у вас партнерська організація в іншій європейській країні?', '2026-08-29 00:51:27.076815+00'),
	('446128aa-ba97-45b7-945a-808da0508c8a', 'uk', 'Har ni partner i minst tre olika europeiska länder?', 'Чи є у вас партнери щонайменше у трьох різних європейських країнах?', '2026-08-29 00:51:27.076815+00'),
	('be2ecc7f-b4ab-45e7-8b57-571ecffc19f8', 'uk', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Чи розташований ваш офіс або основна діяльність у регіоні, де ви подаєте заявку?', '2026-08-29 00:51:27.076815+00'),
	('19bf3ec4-a753-4598-a9d5-3be80ac2f3c9', 'uk', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Чи має хтось із ваших дітей інвалідність, через яку дитина потребує більше догляду або нагляду, ніж інші діти того ж віку?', '2026-08-29 00:51:27.076815+00'),
	('9090319b-cc9c-4598-a6ff-7e5545b1e417', 'uk', 'Har organisationen en demokratisk uppbyggnad?', 'Чи має організація демократичний устрій?', '2026-08-29 00:51:27.076815+00'),
	('58d2cc25-a833-4dcd-b7c5-4c3fe78410d2', 'uk', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Чи має організація Quality Label (знак якості)?', '2026-08-29 00:51:27.076815+00'),
	('af2112c3-e096-4839-8e60-1f3d5f4b221e', 'uk', 'Har organisationen ett 90-konto?', 'Чи має організація 90-konto?', '2026-08-29 00:51:27.076815+00'),
	('11bd326d-d396-4e6d-b384-747014f5bbbf', 'uk', 'Har organisationen ett OID (Organisation ID)?', 'Чи має організація OID (Organisation ID)?', '2026-08-29 00:51:27.076815+00'),
	('31ffcbf6-119d-43d4-b533-1e3de2ed4957', 'uk', 'Har organisationen ett OID?', 'Чи має організація OID?', '2026-08-29 00:51:27.076815+00'),
	('40610c04-9233-4909-a263-c814e6705846', 'uk', 'Har organisationen medlemsföreningar i flera län?', 'Чи має організація об''єднання-члени в кількох ленах?', '2026-08-29 00:51:27.076815+00'),
	('bec53286-1323-4392-9d57-7cc1707c4dd6', 'uk', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Чи має організація впорядковані фінанси та демократичний устрій?', '2026-08-29 00:51:27.076815+00'),
	('31ede106-15f5-4a74-a317-12753365197e', 'uk', 'Har projektet en partner i ett annat land?', 'Чи має проєкт партнера в іншій країні?', '2026-08-29 00:51:27.076815+00'),
	('ecb6d49c-c708-49ad-bc7c-5e23e70445eb', 'uk', 'Har projektledaren doktorsexamen?', 'Чи має керівник проєкту докторський ступінь?', '2026-08-29 00:51:27.076815+00'),
	('d3935ef9-3ba3-44bb-8367-ac80e066f736', 'uk', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Домашня комуна має забезпечувати щоденні поїздки між домом і гімназією, якщо дорога становить щонайменше шість кілометрів (наприклад, проїзний на автобус).', '2026-08-29 00:51:27.076815+00'),
	('47f9b059-f4ab-4ddc-a38a-dcc05c1192db', 'uk', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Чи облаштовуєте ви своє перше власне житло у Швеції?', '2026-08-29 00:51:27.076815+00'),
	('6a15d1a2-833e-417d-9f7e-ea21683fb4fc', 'uk', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Чи включає проєкт міжнародну поїздку або обмін?', '2026-08-29 00:51:27.076815+00'),
	('9f9e661a-38a3-4d02-ab66-f56a80160671', 'uk', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Інвестиційна підтримка компаніям у зонах підтримки — на будівлі, обладнання та навчання.', '2026-08-29 00:51:27.076815+00'),
	('7c4c93c4-ff01-4ac0-b688-53e990d4d657', 'uk', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Інвестиційна підтримка заходів, що знижують викиди парникових газів.', '2026-08-29 00:51:27.076815+00'),
	('f768ac6e-aa33-4b6a-a5de-a1483e7e6b15', 'uk', 'Kan projektets miljönytta mätas?', 'Чи можна виміряти екологічну користь проєкту?', '2026-08-29 00:51:27.076815+00'),
	('68620156-c1ed-4355-90c2-8b96714ba219', 'uk', 'Kan åtgärdens utsläppsminskning beräknas?', 'Чи можна розрахувати зниження викидів від заходу?', '2026-08-29 00:51:27.076815+00'),
	('be5b1c2b-671e-4354-ad30-0723e44b805c', 'uk', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Чи може організація нести витрати до виплати підтримки?', '2026-08-29 00:51:27.076815+00'),
	('f400ca2b-c2bb-4eaa-bda9-840560ccafe1', 'uk', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'Чи буде досвід використано у вашій діяльності у Швеції?', '2026-08-29 00:51:27.076815+00'),
	('a5ae7948-204b-4af7-ace9-5b6dcca1ec22', 'uk', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Чи розпочнеться інвестиція лише після подання заявки?', '2026-08-29 00:51:27.076815+00'),
	('deb85d0d-38d9-4d60-868a-3160ba5362a7', 'uk', 'Kommer projektet människor i ert närområde till del?', 'Чи приносить проєкт користь людям у вашій місцевості?', '2026-08-29 00:51:27.076815+00'),
	('1ebe36f9-c09f-44f9-b293-15fed24adba6', 'uk', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Крайній економічний захист комуни, коли доходів не вистачає на найнеобхідніше.', '2026-08-29 00:51:27.076815+00'),
	('00c175ec-8583-4f1d-a35c-fe13fbd6ef19', 'uk', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Власна підтримка комун місцевим об''єднанням: допомога за заняття, допомога з приміщеннями, стартова допомога тощо.', '2026-08-29 00:51:27.076815+00');
INSERT INTO public.kb_translations VALUES
	('c8500b4c-d30d-4603-a9fc-4be9e75df985', 'uk', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Безкоштовний шкільний транспорт для учнів основної школи при великій відстані, небезпечній дорозі або інвалідності — право за шкільним законом.', '2026-08-29 00:51:27.076815+00'),
	('c1aa85bf-10e7-4daf-b10a-90070928f623', 'uk', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Встановлена законом допомога на окуляри або лінзи для дітей та молоді; суми та порядок різняться за регіонами — перевірте рівень свого регіону.', '2026-08-29 00:51:27.076815+00'),
	('4fd808d0-d865-4f7c-943a-6b5ff9b51ab0', 'uk', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Чи розташований проєкт у місцевості, якої стосується гідро- або вітроенергетика?', '2026-08-29 00:51:27.076815+00'),
	('1f7c0e49-34e4-4756-b51f-ddb71a8c4b50', 'uk', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Чи належить проєкт до довкілля, аграрних наук або містобудування?', '2026-08-29 00:51:27.076815+00'),
	('66ce8c3f-bfeb-41db-b811-95309ccab21d', 'uk', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Чи розташоване місце діяльності в зоні підтримки A або B (велика частина Норрланда та внутрішнього Свеаланда)?', '2026-08-29 00:51:27.076815+00'),
	('e464caa2-bac8-412b-b2f1-be9a627e865d', 'uk', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Позика на купівлю найнеобхіднішого для першого дому у Швеції — меблів, домашнього начиння та іншого базового оснащення.', '2026-08-29 00:51:27.076815+00'),
	('4cb59330-173c-4fb8-8823-7793bb8b6729', 'uk', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Чи знижує проєкт технологічні викиди промисловості або створює від''ємні викиди?', '2026-08-29 00:51:27.076815+00'),
	('703224b5-b168-4e6d-b1ab-4cb06dfd4dfc', 'uk', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Щомісячна допомога на дітей, які живуть у Швеції, від народження до 16 років.', '2026-08-29 00:51:27.076815+00'),
	('35c59d38-fd10-44a2-91cf-3a43d3a8bcf0', 'uk', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket пропонує допомоги організаціям, компаніям, об''єднанням, публічному сектору та приватним особам у сфері довкілля.', '2026-08-29 00:51:27.076815+00'),
	('ce306a54-3690-46d6-ada3-e825a7a17219', 'uk', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Чи плануєте ви добровільно назавжди повернутися до країни походження?', '2026-08-29 00:51:27.076815+00'),
	('1c9e9b6a-b4a6-47b8-b2b2-5d3da86d2534', 'uk', 'Planerar du att starta eget företag?', 'Чи плануєте ви відкрити власну справу?', '2026-08-29 00:51:27.076815+00'),
	('4b7b0009-486d-4379-ac12-8886710709f2', 'uk', 'Planerar du att studera utomlands?', 'Чи плануєте ви навчатися за кордоном?', '2026-08-29 00:51:27.076815+00'),
	('6c286632-c7fe-4fb0-9470-8f1a72912539', 'uk', 'Är projektet ett konst- eller kulturprojekt?', 'Це мистецький або культурний проєкт?', '2026-08-29 00:51:27.080311+00'),
	('17f527ad-3e94-4d51-b06c-353a9ea10bb0', 'uk', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Чи плануєте ви навчання, що зміцнить вашу позицію на ринку праці?', '2026-08-29 00:51:27.076815+00'),
	('16a14e56-41b6-49e4-b4fd-880ea83a2291', 'uk', 'Planerar ni att anställa?', 'Чи плануєте ви наймати працівників?', '2026-08-29 00:51:27.076815+00'),
	('25e522e9-cd24-46c0-ac99-bd7559ea2ba1', 'uk', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Чи плануєте ви подаватися на програму ЄС (наприклад, Horisont Europa)?', '2026-08-29 00:51:27.076815+00'),
	('c48dde41-cb67-4092-80a1-9a16947e83a8', 'uk', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Підтримка виробництва та розробки короткометражних і документальних фільмів.', '2026-08-29 00:51:27.076815+00'),
	('c8d198ac-8bf2-43a9-8a18-c162be03aa02', 'uk', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Проєктні допомоги вільній музичній сцені на концерти, виробництво та розвиток.', '2026-08-29 00:51:27.076815+00'),
	('009e51f6-c1c3-4c75-a7c4-f7fc21418926', 'uk', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Проєктні допомоги неприбутковим організаціям, що працюють із дітьми та молоддю і для них.', '2026-08-29 00:51:27.076815+00'),
	('dc24ccb8-9e90-40c9-bd01-22e5cf059033', 'uk', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Чи випробовує проєкт нові мистецькі вирази, методи або співпраці?', '2026-08-29 00:51:27.076815+00'),
	('19b3fd31-425f-4be7-a7df-52f156412b1e', 'uk', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Чи триває обмін 5–21 день (без урахування днів у дорозі)?', '2026-08-29 00:51:27.076815+00'),
	('996edd87-751e-4d79-bdc9-2f9bf87e4912', 'uk', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Власна проєктна та операційна підтримка регіонів культурного життя, поряд із національними допомогами Kulturrådet.', '2026-08-29 00:51:27.076815+00'),
	('b1ec5bf0-c214-46a5-94d8-45bcbd672761', 'uk', 'Riktar sig projektet till barn eller unga?', 'Чи адресований проєкт дітям або молоді?', '2026-08-29 00:51:27.076815+00'),
	('1bbcaa2d-2667-4b41-a819-704726b919aa', 'uk', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Чи адресований проєкт дітям, молоді, літнім людям або людям з інвалідністю?', '2026-08-29 00:51:27.076815+00'),
	('93744276-8c92-460b-8d32-36af5d75d6f3', 'uk', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Чи адресована діяльність дітям і молоді (7–25 років)?', '2026-08-29 00:51:27.076815+00'),
	('c9de9cd2-1b84-4dc0-b2c1-4b659dc7429a', 'uk', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Чи бракує вам заощаджень або активів, які могли б покрити витрати?', '2026-08-29 00:51:27.076815+00'),
	('e032bd80-72a4-4376-8e9c-f2a897270641', 'uk', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Чи співпрацюєте ви з партнерами щонайменше у двох інших північних країнах?', '2026-08-29 00:51:27.076815+00'),
	('73aac111-f7d8-431c-a4a1-2c73e3012aa2', 'uk', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Чи залучатимете ви зовнішню експертизу для заходу розвитку?', '2026-08-29 00:51:27.076815+00'),
	('2700eca8-ef3a-4300-8f49-23dda1d66ac8', 'uk', 'Sker mobiliteten till ett annat europeiskt land?', 'Чи спрямована мобільність до іншої європейської країни?', '2026-08-29 00:51:27.076815+00'),
	('8d79042b-19cc-459c-b0ed-330fb9cc3b3a', 'uk', 'Startar du eller tar du över företaget för första gången?', 'Чи відкриваєте ви підприємство або берете його на себе вперше?', '2026-08-29 00:51:27.076815+00'),
	('8b27d668-c7a6-4277-a77d-7340a7dee128', 'uk', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Стартова підтримка для тих, кому 40 років або менше, хто відкриває сільськогосподарське підприємство або бере його на себе.', '2026-08-29 00:51:27.076815+00'),
	('1e5c7794-ab23-4261-bd08-c4e70d3ebabb', 'uk', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Стипендія, що дає професійним митцям змогу зосередитися на мистецькій роботі.', '2026-08-29 00:51:27.076815+00'),
	('fb084adc-de93-47e0-a3b5-a061d3880e2a', 'uk', 'Studerar du, eller planerar du att börja studera?', 'Чи навчаєтеся ви або плануєте почати навчання?', '2026-08-29 00:51:27.076815+00'),
	('1aa43fb0-df87-438b-85ce-4b6f07bec452', 'uk', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Навчальна підтримка для працюючих дорослих, які хочуть здобути освіту для зміцнення позиції на ринку праці.', '2026-08-29 00:51:27.076815+00'),
	('a80790ae-98ce-48df-bb68-d43b7db45b73', 'uk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Підтримка інвестицій, що підвищують конкурентоспроможність або знижують вплив на довкілля в сільськогосподарських підприємствах.', '2026-08-29 00:51:27.076815+00'),
	('4b630c0f-9584-453e-9718-9a9b3940a044', 'uk', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Підтримка, коли дитина живе з вами, а другий із батьків не платить утримання.', '2026-08-29 00:51:27.076815+00'),
	('4e51205c-ab80-4260-9a2f-4052a749914a', 'uk', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Підтримка проєктів неприбуткових організацій для людей, довкілля та кращого світу.', '2026-08-29 00:51:27.076815+00'),
	('5dbad41c-eb03-4042-a533-2f558a904ed0', 'uk', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Підтримка переходу промисловості до нульових викидів парникових газів.', '2026-08-29 00:51:27.076815+00'),
	('1213ee1b-6c20-4d25-a906-c0781c2487b4', 'uk', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Підтримка мистецьких і культурних проєктів із північним виміром та транскордонною співпрацею.', '2026-08-29 00:51:27.076815+00'),
	('9642219d-a387-4468-8562-bf2fce32c7c4', 'uk', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Підтримка новаторських культурних проєктів, що випробовують нові мистецькі вирази, методи або співпраці.', '2026-08-29 00:51:27.076815+00'),
	('8e01a0de-c003-46cc-8ecb-3c69d87a0238', 'uk', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Підтримка новаторських проєктів для дітей, молоді, літніх людей і людей з інвалідністю.', '2026-08-29 00:51:27.076815+00'),
	('525d2337-664d-4a54-823c-38a90c483301', 'uk', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Підтримка проєктів співпраці у вільній музичній сцені.', '2026-08-29 00:51:27.076815+00'),
	('df932b11-d0d2-4fa5-aacf-872bdf971a4e', 'uk', 'Är projektet ett kulturprojekt?', 'Це культурний проєкт?', '2026-08-29 00:51:27.080311+00'),
	('cbd61a47-8972-4fac-a2e6-b3651fe2eaba', 'uk', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Підтримка проєктів співпраці в культурі та медіа, що зміцнюють демократію та свободу слова на міжнародному рівні.', '2026-08-29 00:51:27.076815+00'),
	('44529d91-6b2f-4391-9945-4d054d7cc6b2', 'uk', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Чи спрямований проєкт на зміцнення демократії, рівності або свободи слова?', '2026-08-29 00:51:27.076815+00'),
	('0392a240-a4eb-4326-bdf2-53db260b421a', 'uk', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Чи шукаєте ви роботу або отримали пропозицію роботи в іншій країні ЄС чи ЄЕП?', '2026-08-29 00:51:27.076815+00'),
	('fe09bb77-39f2-467a-b144-015f05f08084', 'uk', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Стеля того, що ви платите як пацієнтські збори за дванадцять місяців — далі frikort (безкоштовна картка).', '2026-08-29 00:51:27.076815+00'),
	('912610b9-d061-4ed5-8c9b-75fdc0d2f8d9', 'uk', 'Tar du ut hel allmän pension?', 'Чи отримуєте ви повну державну пенсію?', '2026-08-29 00:51:27.076815+00'),
	('149dccd9-392e-4b3b-bcea-9b6a007b836e', 'uk', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Надбавка, що покриває частину витрат на житло для тих, хто має пенсію та низькі доходи.', '2026-08-29 00:51:27.076815+00'),
	('3259bf3e-4d16-4980-8be1-8c54da42b6b6', 'uk', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Щорічна організаційна допомога національним дитячим і молодіжним організаціям.', '2026-08-29 00:51:27.076815+00');
INSERT INTO public.kb_translations VALUES
	('1cefd9e8-9e92-4ae3-812e-822b1b586fd8', 'uk', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Щорічна сума, що вираховується безпосередньо у стоматолога або зубного гігієніста.', '2026-08-29 00:51:27.076815+00'),
	('51dc3532-7fdc-4bf5-ae1b-91c331e36ba9', 'uk', 'Är bolaget yngre än cirka 5 år?', 'Компанії менше ніж приблизно 5 років?', '2026-08-29 00:51:27.076815+00'),
	('1c7e18f0-ac84-487a-85f4-8d0285aadb29', 'uk', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Учасникам обміну від 13 до 30 років?', '2026-08-29 00:51:27.076815+00'),
	('3e5fb99a-2922-4da1-92e7-2714a93ae3da', 'uk', 'Är det här ert första EU-projekt?', 'Це ваш перший проєкт ЄС?', '2026-08-29 00:51:27.076815+00'),
	('91ab04de-6122-4176-9443-2283eeceec03', 'uk', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Чи дуже важко вам (або вашій дитині) пересуватися самостійно чи їздити автобусом і потягом?', '2026-08-29 00:51:27.076815+00'),
	('91833b50-375a-4534-942d-b19cb8d74fcf', 'uk', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Ваш дохід нижчий за приблизно 25 000 крон на місяць до податків?', '2026-08-29 00:51:27.076815+00'),
	('63c2ca71-0a1d-4b3b-bba7-15889a8b174f', 'uk', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Ваша остання закінчена освіта — основна школа або незакінчена гімназія?', '2026-08-29 00:51:27.076815+00'),
	('5c694a96-1bee-4b89-83ae-a22f2fd0e9b4', 'uk', 'Är du 40 år eller yngre?', 'Вам 40 років або менше?', '2026-08-29 00:51:27.076815+00'),
	('83081c67-d8ba-4873-89b5-9acc02545103', 'uk', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Чи зареєстровані ви як шукач роботи в Arbetsförmedlingen?', '2026-08-29 00:51:27.076815+00'),
	('55c04b27-c88a-4785-a1bb-cf42be97df86', 'uk', 'Är du mellan 18 och 28 år?', 'Вам від 18 до 28 років?', '2026-08-29 00:51:27.076815+00'),
	('711ed642-34d6-4646-a01c-b97ea82fcb8d', 'uk', 'Är du mellan 19 och 29 år?', 'Вам від 19 до 29 років?', '2026-08-29 00:51:27.076815+00'),
	('0fd83452-8d1f-4453-98c9-25c69aa4df0d', 'uk', 'Är du mellan 25 och 60 år?', 'Вам від 25 до 60 років?', '2026-08-29 00:51:27.076815+00'),
	('3ccfa6b4-5984-4ea6-a4ec-dd9218cef1b2', 'uk', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Чи працюєте ви професійно у сфері культури (наприклад, танець, музика, сценічне мистецтво)?', '2026-08-29 00:51:27.076815+00'),
	('3d4a6a09-0e4f-4123-bd04-ff0911ee1a68', 'uk', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Ви професійний митець (не аматор і не на базовому навчанні)?', '2026-08-29 00:51:27.076815+00'),
	('5c833e39-54f0-41b7-b89e-bdba79ecc4b1', 'uk', 'Är du yrkesverksam konstnär?', 'Ви професійний митець?', '2026-08-29 00:51:27.076815+00'),
	('adca4497-532c-4724-b2b8-7d6a4ced0336', 'uk', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Чи суттєво новаторське ваше рішення порівняно з тим, що вже існує?', '2026-08-29 00:51:27.080311+00'),
	('47363647-fb0e-434a-8f75-a1b809517da2', 'uk', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Чи входить клуб до спеціалізованої спортивної федерації у складі Riksidrottsförbundet?', '2026-08-29 00:51:27.080311+00'),
	('111d2c8b-0bba-4160-9f5e-0b717eba68f1', 'uk', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Чи низькі доходи родини відносно витрат на житло?', '2026-08-29 00:51:27.080311+00'),
	('aa953a4b-b49f-472d-8657-13c11c49c859', 'uk', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Сукупний дохід родини нижчий за приблизно 25 000 крон на місяць до податків?', '2026-08-29 00:51:27.080311+00'),
	('a9aec13a-274a-490b-a095-b378de5ec57b', 'uk', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Чи є захід окремим проєктом (а не звичайною діяльністю)?', '2026-08-29 00:51:27.080311+00'),
	('f35db6ab-fa09-40f4-b417-ad1bbc6b1ee2', 'uk', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Чи відкрите приміщення для всіх — не лише для власних членів?', '2026-08-29 00:51:27.080311+00'),
	('f9bf9eb5-56ed-4262-9c86-eb48312798b4', 'uk', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Щонайменше 60 % членів віком від 6 до 25 років?', '2026-08-29 00:51:27.080311+00'),
	('24fcaa28-ec4a-40d5-bef8-3e767d4df0d2', 'uk', 'Är minst 60 % av medlemmarna under 26 år?', 'Щонайменше 60 % членів молодші за 26 років?', '2026-08-29 00:51:27.080311+00'),
	('66aad3ad-8098-4599-8fe8-bcb4e16305cd', 'uk', 'Är målgruppen delaktig i planering och genomförande?', 'Чи бере цільова група участь у плануванні та реалізації?', '2026-08-29 00:51:27.080311+00'),
	('a166d343-89b3-472a-a369-6e75b925f218', 'uk', 'Är ni ett förlag med professionell utgivning?', 'Ви видавництво з професійним книговиданням?', '2026-08-29 00:51:27.080311+00'),
	('7f2b351e-ecc1-4b54-96f5-2d72cf520998', 'uk', 'Är ni huvudman för förskoleklass eller grundskola?', 'Чи є ви відповідальною організацією дошкільного класу або основної школи?', '2026-08-29 00:51:27.080311+00'),
	('1c3330e1-8c32-4216-915a-4a139382838e', 'uk', 'Är organisationen registrerad i EU:s deltagarregister?', 'Чи зареєстрована організація в реєстрі учасників ЄС?', '2026-08-29 00:51:27.080311+00'),
	('921b8003-6847-4411-9349-5b71b9364f15', 'uk', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Це кінопроєкт (короткометражний або документальний фільм)?', '2026-08-29 00:51:27.080311+00'),
	('8c52bbf9-102c-47a1-9ed7-7254af0e4725', 'uk', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Чи новаторський проєкт — те, чого ви ще не робите у звичайній діяльності?', '2026-08-29 00:51:27.080311+00'),
	('4b869e5a-5cf2-4004-806a-b0e3c076b705', 'uk', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Чи приносить проєкт користь місцевості загалом (а не окремим особам)?', '2026-08-29 00:51:27.080311+00'),
	('a63b30e2-d699-4f11-9e87-5d21ebb02124', 'uk', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Дорога між домом і гімназією становить щонайменше шість кілометрів?', '2026-08-29 00:51:27.080311+00'),
	('f84ddf96-fb2b-4b09-9512-4562b787b177', 'uk', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Чи професійна це діяльність (не аматорська)?', '2026-08-29 00:51:27.080311+00'),
	('00f8b376-3e0a-4b82-86f4-5cee1cfa23c8', 'uk', 'Är verksamheten professionell?', 'Чи професійна це діяльність?', '2026-08-29 00:51:27.080311+00'),
	('e74cf78c-5a02-4ab9-bc4a-ba9771fa4c60', 'uk', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Чи належить діяльність до сценічного мистецтва (танець, театр, музичний театр)?', '2026-08-29 00:51:27.080311+00'),
	('cd3c7e2f-ccd4-414f-b12b-03c4a4ad7499', 'uk', 'Är volontärerna mellan 18 och 30 år?', 'Волонтерам від 18 до 30 років?', '2026-08-29 00:51:27.080311+00'),
	('4faf8649-cf70-4969-8462-aa3cb7607bea', 'so', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'Taageero hawleed loogu talagalay naadiyada isboortiga ee u qabta carruurta iyo dhallinyarada 7–25 jir hawlo uu hoggaamiyo tababare.', '2026-08-29 00:51:27.085901+00'),
	('fa5f3647-d682-43e1-81ea-cf9a04379803', 'so', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'Kordhin toos ah oo lagu daro gunnada carruurta (barnbidrag) laga bilaabo ilmaha labaad.', '2026-08-29 00:51:27.085901+00'),
	('ca8b1fcc-57a8-4d57-9f4f-6ffdc580def3', 'so', 'Avser ansökan en fysisk investering?', 'Codsigu ma khuseeyaa maalgelin muuqata (dhisme ama qalab)?', '2026-08-29 00:51:27.085901+00'),
	('1b6b019b-553a-440d-a4aa-54acc5186ee4', 'so', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'Codsigu ma khuseeyaa safar ama isweydaarsi caalami ah?', '2026-08-29 00:51:27.085901+00'),
	('302578de-6d9f-4450-a197-684d8c461d83', 'so', 'Avser ansökan en investering i byggnader eller maskiner?', 'Codsigu ma khuseeyaa maalgelin lagu sameynayo dhismayaal ama mashiinno?', '2026-08-29 00:51:27.085901+00'),
	('7184cd08-3521-4e4d-91be-b2d7b0491ba5', 'so', 'Avser ansökan en redan utgiven titel?', 'Codsigu ma khuseeyaa buug horeba loo daabacay?', '2026-08-29 00:51:27.085901+00'),
	('b749bdf6-cc0f-4c4b-aec3-0f6748e00a86', 'so', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'Codsigu ma khuseeyaa ganacsi beeraley ah, beero-korin ama xoolo-dhaqato deero-woqooyi?', '2026-08-29 00:51:27.085901+00'),
	('f2e8125b-ddc8-45d8-8b0a-af8c49a83244', 'so', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'Codsigu ma khuseeyaa buugaag loo iibinayo maktabadaha dadweynaha ama kuwa dugsiyada?', '2026-08-29 00:51:27.085901+00'),
	('c00e4933-b094-48a6-8600-a0b554f42ab3', 'so', 'Avser investeringen jordbruksverksamhet?', 'Maalgelintu ma khuseysaa hawl beeraley ah?', '2026-08-29 00:51:27.085901+00'),
	('a78d0837-2b26-43cb-a630-084325e6894b', 'so', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'Mashruucu ma yahay dhisid, iibsi ama dayactir goob?', '2026-08-29 00:51:27.085901+00'),
	('c1f1766a-358e-4dc7-9c99-d642aeda2231', 'so', 'Avser projektet naturvård eller friluftsliv?', 'Mashruucu ma khuseeyaa ilaalinta dabeecadda ama madadaalada banaanka?', '2026-08-29 00:51:27.085901+00'),
	('a39900b5-d043-4eaa-93c6-26e6f559aa17', 'so', 'Avser projektet skola eller vuxenutbildning?', 'Mashruucu ma khuseeyaa dugsi ama waxbarashada dadka waaweyn?', '2026-08-29 00:51:27.085901+00'),
	('0b05320a-45f8-417a-8264-10beb03a6fec', 'so', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'Ma ka fadhiisanaysaa shaqada si aad u daryeesho ama ugu dhowaato qof kuu dhow oo aad u xanuunsan, oo cudurkiisu nolosha khatar ku yahay?', '2026-08-29 00:51:27.085901+00'),
	('a8496e64-c25b-440d-ad28-0476ab961e1d', 'so', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'Ururku ma ku leeyahay hawlo joogto ah degmada?', '2026-08-29 00:51:27.085901+00'),
	('b5cedf27-7864-48df-b8a5-cb2108187a3c', 'so', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'Ma qiimeynaysaa in awooddaada shaqo ay hoos u dhacday ugu yaraan hal sano cudur ama naafanimo dartood?', '2026-08-29 00:51:27.085901+00');
INSERT INTO public.kb_translations VALUES
	('b3f7e7a7-c40b-4b04-aafe-0671aab361d0', 'so', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Taageero baahi lagu qiimeeyo oo loogu talagalay qofka haysta hawlgab yar ama aan haysan, una baahan caawimo si uu u gaadho heer nololeed macquul ah.', '2026-08-29 00:51:27.085901+00'),
	('8728dd88-33b3-4660-8c71-d68d548dbd67', 'so', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'Ilmuhu ma u baahan yahay inuu dego magaalada uu wax ku barto (hoy) sababtoo ah waddadu aad bay u dheer tahay?', '2026-08-29 00:51:27.085901+00'),
	('5cf9eb5e-5ff6-47c4-8823-53972e2dd9de', 'so', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'Gurigu ma u baahan yahay in la habeeyo (tus. jaranjaro-fudud, albaab-fure, musqul)?', '2026-08-29 00:51:27.085901+00'),
	('907c885c-c5f1-4d7f-b36f-684c47218d81', 'so', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'Mid ka mid ah carruurtaada 8–19 jirka ah ma u baahan yahay muraayado indho ama lenso?', '2026-08-29 00:51:27.085901+00'),
	('041aab49-5779-4901-8500-cff9f3de670a', 'so', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'Waalidka kale miyuusan waxba bixin, mise wuxuu bixiyaa wax ka yar masruufka buuxa?', '2026-08-29 00:51:27.085901+00'),
	('9792d2fe-85c5-4ad3-bf56-e3257c3e5353', 'so', 'Betalar du hyra eller andra boendekostnader?', 'Ma bixisaa kiro ama kharashyo kale oo guri?', '2026-08-29 00:51:27.085901+00'),
	('e2719c13-3b8c-4dbc-93ca-be8650f08534', 'so', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Gunno lagu habeeyo guriga marka naafanimo jirto — tus. jaranjarooyin fudud, albaab-fureyaal ama habeyn musqusha.', '2026-08-29 00:51:27.085901+00'),
	('318159bd-9f20-4e8e-a1fd-9be6e3b69323', 'so', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Gunnooyin lagu dhiso, lagu iibsado ama lagu dayactiro hoolal shir oo dadweyne.', '2026-08-29 00:51:27.085901+00'),
	('14c1bc8d-0bc0-48d5-8574-8766c9be4a92', 'so', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Gunno lagu iibsado ama lagu habeeyo baabuur marka naafanimo joogto ahi ay aad u adkeyso dhaqdhaqaaqa ama safarka gaadiidka dadweynaha.', '2026-08-29 00:51:27.085901+00'),
	('2274da1d-f7e9-4ff4-b72b-afa9860ab1da', 'so', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Gunnooyin safarro iyo isweydaarsiyo caalami ah oo loogu talagalay xirfadlayaasha dhinaca dhaqanka.', '2026-08-29 00:51:27.085901+00'),
	('66ac612d-43c9-4e58-8c0e-3e1e769f0683', 'so', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Gunnooyin isweydaarsiyada caalamiga ah, safarrada iyo joogitaannada shaqo ee fannaaniinta xirfadleyda ah.', '2026-08-29 00:51:27.085901+00'),
	('685e859d-132f-4d6d-a4dd-dc6a2fc7b854', 'so', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Gunno iyo deyn ikhtiyaari ah oo loogu talagalay waxbarashada heerka dugsiga sare ama ka dambeeya.', '2026-08-29 00:51:27.085901+00'),
	('94b3dd23-4b07-4a76-add6-ac5c38ab69cd', 'so', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Gunnooyin iyo deymo waxbarasho dibadda ah, oo leh deymo dheeraad ah tus. lacagta waxbarashada iyo safarrada.', '2026-08-29 00:51:27.085901+00'),
	('f2836922-0c86-4278-a247-ca0d3a13e8a1', 'so', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Gunno ka caawisa jihooyinka Swedishka inay diyaariyaan codsiyada barnaamijyada EU sida Horisont Europa.', '2026-08-29 00:51:27.085901+00'),
	('6df148fa-f7de-43e1-8968-028ee451d88a', 'so', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'Gunno loo fidiyo loo-shaqeeyayaasha shaqaaleysiiya dadka awoodda shaqo ee hooseysa.', '2026-08-29 00:51:27.085901+00'),
	('4fd265eb-c4b7-4b37-b513-9964b0b64735', 'so', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Gunno hoy iyo safarro guri-ku-noqosho ah marka arday dugsi sare uu qasab ku noqdo inuu dego magaalada waxbarashada waddo dheer awgeed.', '2026-08-29 00:51:27.085901+00'),
	('b30d0fa2-305e-41ea-8a7a-e25d447f56f0', 'so', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Gunnooyin shaqada ururrada aan faa''iido doonka ahayn ee ilaalinta, isticmaalka iyo horumarinta hidaha dhaqanka.', '2026-08-29 00:51:27.085901+00'),
	('d19d8735-1ab2-4a32-94c5-f2d8f11d860e', 'so', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'Gunnooyin mashaariicda degmooyinka iyo kuwa maxalliga ah ee ilaalinta dabeecadda, oo ay ku jiraan dhulalka qoyan iyo madadaalada banaanka.', '2026-08-29 00:51:27.085901+00'),
	('e251f56f-b6f1-4893-a218-cc807bfef73b', 'so', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Gunnooyin degmooyinka loogu talagalay iibsiga buugaagta maktabadaha dadweynaha iyo kuwa dugsiyada.', '2026-08-29 00:51:27.085901+00'),
	('cd7b2e1c-3d58-40b5-af3b-1126f0862dc5', 'so', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Gunnooyin masuuliyiinta dugsiyada si ardayda dugsiga hoose-dhexe ay ula kulmaan dhaqan xirfadle.', '2026-08-29 00:51:27.085901+00'),
	('91d2532f-0333-4406-b56d-12caa26b7249', 'so', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Gunno waxa ilmahaagu u baahan yahay laakiin dhaqaalaha qoysku uusan gaadhin: hawlo firaaqo, dhar, socdaallo dugsi, muraayado indho, hawlo fasax iyo wax kale.', '2026-08-29 00:51:27.085901+00'),
	('2dccbd94-3a94-421e-a97f-88a89164ee7e', 'so', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Gunnooyin ka yimaadda sanduuqyada sida Världens Barn, Musikhjälpen iyo Victoriafonden — waxaa codsada ururrada Swedishka ee aan faa''iido doonka ahayn ee haysta 90-konto.', '2026-08-29 00:51:27.085901+00'),
	('daebacb6-455c-4be9-85fd-ac4beec44efd', 'so', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Gunnooyin ka yimaadda lacagaha korontada biyaha iyo dabaysha oo loogu talagalay mashaariic horumarisa deegaanka.', '2026-08-29 00:51:27.085901+00'),
	('2402da43-7560-48dc-83a8-c9c8ed24d7ac', 'so', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Gunno aan lahayn qayb deyn ah oo loogu talagalay shaqo-la''aanta 25–60 jirka ah ee waxbarashadoodu gaaban tahay, una baahan inay wax ku bartaan heerka dugsiga hoose-dhexe ama sare.', '2026-08-29 00:51:27.085901+00'),
	('62acd739-cd7a-48e6-8061-78731589ed10', 'so', 'Bidrar projektet till energiomställningen?', 'Mashruucu ma gacan ka geystaa isbeddelka tamarta?', '2026-08-29 00:51:27.085901+00'),
	('d071b829-0d9a-4649-8d06-0d4be5a3c2a6', 'so', 'Bor du och barnets andra förälder på skilda håll?', 'Adiga iyo waalidka kale ee ilmuhu ma kala nooshihiin?', '2026-08-29 00:51:27.085901+00'),
	('1aec5e79-1b55-4482-a3b6-758d0171bcb5', 'so', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Jeegag shirkado yaryar si ay u keensadaan aqoon dibadeed oo caalamiyeyn ama dhijitaaleyn ah.', '2026-08-29 00:51:27.085901+00'),
	('0724a898-b139-415d-a69d-25aa9ca00e09', 'so', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'Ma ka qaybqaadataa barnaamij ka socda Arbetsförmedlingen (tus. jobb- och utvecklingsgarantin)?', '2026-08-29 00:51:27.085901+00'),
	('407c3562-534f-4af0-ba86-7f8eab12def4', 'so', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Taageero dib-u-dhac ah oo loo fidiyo daabacayaasha soo saara suugaan tayo leh.', '2026-08-29 00:51:27.085901+00'),
	('d60abed2-83c3-42f1-8e07-0d35e8b9e726', 'so', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Taageero dhaqaale oo loogu talagalay qofka haysta sharci degganaansho oo magangelyo la xiriira, oo si mutadawacnimo ah u doonaya inuu si joogto ah ugu laabto dalkiisii asalka ahaa.', '2026-08-29 00:51:27.085901+00'),
	('2b9ae837-3fbf-4800-8a0c-901b0a7b415c', 'so', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'Taageero dhaqaale oo loo fidiyo loo-shaqeeyayaasha shaqaaleysiiya qof muddo dheer ka maqnaa nolosha shaqada.', '2026-08-29 00:51:27.085901+00'),
	('410d6efa-5286-4368-acba-fade509be177', 'so', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Taageero dhaqaale inta lagu jiro bilowga, oo loogu talagalay shaqo-doonka bilaabaya ganacsigooda.', '2026-08-29 00:51:27.085901+00'),
	('e9180bd6-2bf1-4226-8a7e-e4f41a7f56b4', 'so', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten waxay si joogto ah u furtaa baaqyo cilmi-baarista tamarta, hal-abuurka iyo hufnaanta tamarta.', '2026-08-29 00:51:27.085901+00'),
	('333bf338-aa77-4b07-b9af-fe1ec3dca0e6', 'so', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'Magdhow ka-maqnaanshaha shaqada ama waxbarashada si loo daryeelo ilmo.', '2026-08-29 00:51:27.085901+00'),
	('a9ee665c-e19d-4190-86f8-c81a905c600a', 'so', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Magdhow qofka ku cusub Sweden oo ka qaybqaata barnaamijka dejinta ee Arbetsförmedlingen; waxaa bixisa Försäkringskassan.', '2026-08-29 00:51:27.085901+00'),
	('d1757aeb-d108-4caa-bcea-0f346deab587', 'so', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Magdhow daboolaya qayb ka mid ah kharashka guriga ee dhallinyarada aan carruurta lahayn ee dakhligoodu hooseeyo.', '2026-08-29 00:51:27.085901+00'),
	('b857f32f-b8e8-48d3-b68f-16aba686e74c', 'so', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Magdhow kharashyada dheeraadka ah ee naafanimo joogto ahi keento — dadka waaweyn, ama waalidiinta carruurta naafada ah.', '2026-08-29 00:51:27.085901+00'),
	('9aba6264-ed41-47f5-9bb2-bfd6a55a1956', 'so', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Magdhow dhallinyarada (19–29 jir) aan awoodin inay waqti-buuxa u shaqeeyaan ugu yaraan hal sano cudur ama naafanimo dartood.', '2026-08-29 00:51:27.085901+00'),
	('570a9d59-7517-4ca3-9569-47887d8e964b', 'so', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'Magdhow marka awoodda shaqo si joogto ah hoos ugu dhacday — wixii hore loogu yiqiin förtidspension (hawlgab hore).', '2026-08-29 00:51:27.085901+00'),
	('5e40db43-914a-4fb1-88af-bcc322db795f', 'so', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Magdhow marka aad shaqada uga fadhiisato inaad u dhowaato qof kuu dhow oo aad u xanuunsan.', '2026-08-29 00:51:27.085901+00'),
	('f9f9aa0e-54c7-44ef-840c-f67d5c1716c1', 'so', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'Magdhow marka aad ka qaybqaadato barnaamij suuqa shaqada ee Arbetsförmedlingen.', '2026-08-29 00:51:27.085901+00'),
	('7721f640-5c94-446b-a8f0-496529a13727', 'so', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'Magdhow marka aadan sidii caadiga ahayd u shaqeyn karin cudur dartiis.', '2026-08-29 00:51:27.085901+00'),
	('4b91e952-e616-4771-ab5b-48aa10937c1e', 'so', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'Magdhow marka aad shaqada ka joogto guriga si aad u daryeesho ilmo jirran.', '2026-08-29 00:51:27.085901+00'),
	('0f16a501-3f0b-4a3f-911b-ab6a885bfc62', 'so', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Magdhow daboolaya qayb ka mid ah kharashka guriga ee qoysaska carruurta leh ee dakhligoodu hooseeyo.', '2026-08-29 00:51:27.085901+00'),
	('26f8f577-aecd-4a64-bd63-171368dac072', 'so', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Magdhow waalidiinta ay carruurtoodu naafanimo dartood ugu baahan yihiin daryeel iyo ilaalin ka badan carruurta da''dooda ah.', '2026-08-29 00:51:27.085901+00'),
	('c0ad167a-f68d-4206-b450-e3f4900e1c39', 'so', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'Magdhow xilliga shaqo-la''aanta — ku salaysan dakhliga xubnaha, qadar aasaasi ah kuwa kale.', '2026-08-29 00:51:27.085901+00'),
	('71fc06a6-8452-4981-a3ea-3de2b86b4615', 'so', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Ilaa konton sanduuq oo bangiyada kaydka ah ayaa gunnooyin siiya mashaariic maxalli ah oo isboorti, dhaqan, waxbarasho iyo horumar bulsho — gudaha aagga hawlgalka bangiga.', '2026-08-29 00:51:27.085901+00'),
	('2833dbc9-8092-45f5-8984-6d486d7b04c2', 'so', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Taageero mashruuc oo EU maalgeliso oo laga codsado aaggaaga Leader ee maxalliga ah — ururrada, shirkadaha iyo degmooyinka horumarinaya miyiga.', '2026-08-29 00:51:27.085901+00'),
	('65e4caf2-f8ac-415d-bad4-6e8d203d50b3', 'so', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'Taageero EU maalgeliso oo loogu talagalay shaqo-doonka qaadanaya shaqo dal kale oo EU/EES ah: magdhow safarka wareysiga, kharashka guuritaanka iyo koorso luqadeed.', '2026-08-29 00:51:27.085901+00'),
	('b2fad8f2-646b-47b8-b383-35a2573301e8', 'so', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Lacago ka yimaadda sanduuqa bulshada ee EU oo loogu talagalay mashaariic xoojiya aqoonta, u-gudubka iyo ka-mid-noqoshada suuqa shaqada.', '2026-08-29 00:51:27.085901+00');
INSERT INTO public.kb_translations VALUES
	('195bfbe3-c107-4b56-aac0-5047d109a0a3', 'so', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Taageero EU oo loogu talagalay isweydaarsiyo kooxeed dhallinyarada 13–30 jir, 5–21 maalmood oo aan lagu darin maalmaha safarka.', '2026-08-29 00:51:27.085901+00'),
	('9eb8f105-dd86-47a4-892e-79e8f40d2445', 'so', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Taageero EU oo loogu talagalay mashaariicda iskaashiga ururrada dhaqanka ee la leh shuraakada dhowr dal oo Yurub ah.', '2026-08-29 00:51:27.085901+00'),
	('f19a2ecd-1b19-4c02-881e-c0d8c719a711', 'so', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Taageero EU oo loogu talagalay ururrada soo dhoweeya ama dira mutadawiciin dhallinyaro ah oo 18–30 jir ah.', '2026-08-29 00:51:27.085901+00'),
	('0b98cdc9-5579-4997-9126-c4729438adea', 'so', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Taageero EU oo loogu talagalay dhaqdhaqaaqa shaqaalaha iyo ardayda dugsiga iyo waxbarashada dadka waaweyn.', '2026-08-29 00:51:27.085901+00'),
	('fa8945f7-ba37-49fa-a453-1ed9d662514b', 'so', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Taageero EU oo leh qaddaro go''an oo loogu talagalay mashaariicda iskaashiga Yurub ee ugu horreeya ee ururrada yaryar.', '2026-08-29 00:51:27.085901+00'),
	('0d826b67-ca32-4e71-951b-3514edc613ba', 'so', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Maalgelin shirkado da''yar oo horumarinaya alaabo ama adeegyo hal-abuur leh oo awood caalami leh.', '2026-08-29 00:51:27.085901+00'),
	('76400492-fe01-4b59-a340-d7d7a1e254fe', 'so', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'Ma jiraa bangi kayd (sidaas darteedna sanduuq bangi-kayd) meesha aad ka hawlgashaan?', '2026-08-29 00:51:27.085901+00'),
	('96a4c6db-de4f-4d00-a457-bda38f9d34f8', 'so', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Gunnooyin hawlgal oo dhowr sano ah oo loogu talagalay kooxaha madaxbannaan ee xirfadleyda ah ee qoob-ka-ciyaarka, masraxa iyo masraxa muusiga.', '2026-08-29 00:51:27.085901+00'),
	('79935f2b-3f14-435d-9638-c460149a782f', 'so', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Gunnooyin cilmi-baaris oo ku saabsan aagagga Forte: caafimaadka, nolosha shaqada iyo barwaaqada. Waxaa codsada cilmi-baarayaal shahaadada dhoktoorada haysta oo jaamacadaha Sweden jooga.', '2026-08-29 00:51:27.085901+00'),
	('ffc726a5-cdff-4126-9e51-897b9a0713cf', 'so', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Maalgelin cilmi-baaris oo loogu talagalay baaritaan aasaasi ah oo xor ah dhammaan qaybaha sayniska.', '2026-08-29 00:51:27.085901+00'),
	('a9dbadab-1182-4972-894d-8654b7fde0e5', 'so', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Maalgelin cilmi-baaris oo ku saabsan deegaanka, cilmiga beeraha iyo qorshaynta magaalooyinka.', '2026-08-29 00:51:27.085901+00'),
	('6e0e8065-5640-498d-8de8-a94bf60eda16', 'so', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'Ma ka fekereysaa inaad dibadda u guurto (shaqo, waxbarasho ama dib-u-laabasho)?', '2026-08-29 00:51:27.085901+00'),
	('a577fc9e-79da-4bab-92b2-835db87d5184', 'so', 'Genomförs insatserna av professionella kulturaktörer?', 'Hawlaha ma fuliyaan jilayaal dhaqameed xirfadle ah?', '2026-08-29 00:51:27.085901+00'),
	('50083baa-46d5-469c-aeab-afc4762d0aaa', 'so', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'Mashruuca ma laga fuliyaa miyiga ama tuulo yar?', '2026-08-29 00:51:27.085901+00'),
	('69206105-30f3-4c38-8c86-3831c2916901', 'so', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'Ilaalin aasaasi ah oo loogu talagalay qofka noloshiisa oo dhan dakhli shaqo yar ama aan lahayn.', '2026-08-29 00:51:27.085901+00'),
	('9ac21302-dcf7-4e38-9ef0-79e7cb72c7b5', 'so', 'Går något av dina barn i grundskolan?', 'Mid ka mid ah carruurtaadu ma dhigtaa dugsiga hoose-dhexe?', '2026-08-29 00:51:27.085901+00'),
	('d39c1222-ffaf-45e6-8c5f-4a216a7f298d', 'so', 'Går något av dina barn på gymnasiet?', 'Mid ka mid ah carruurtaadu ma dhigtaa dugsiga sare?', '2026-08-29 00:51:27.085901+00'),
	('a14b35e8-cfa0-4882-a879-5072cbc8789e', 'so', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'Shaqaaleysiintu ma khuseysaa qof awooddiisa shaqo hoos u dhacday?', '2026-08-29 00:51:27.085901+00'),
	('6ce4f27b-394f-4ed0-ba3b-5910d34b1858', 'so', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'Shaqaaleysiintu ma khuseysaa qof muddo dheer shaqo la''aan ahaa ama ku cusub Sweden?', '2026-08-29 00:51:27.085901+00'),
	('f4bfc977-23a3-4b0c-91c3-16eb1c4d822e', 'so', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'Mashruucu ma ku saabsan yahay ilaalinta hidaha dhaqanka ama helitaankiisa?', '2026-08-29 00:51:27.085901+00'),
	('4b9b7c41-69e0-414f-b17c-067fe354d30f', 'so', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'Mashruucu ma ku saabsan yahay tamar, hufnaan tamar ama hal-abuur tamar la xiriira?', '2026-08-29 00:51:27.085901+00'),
	('b3827ce3-f8cd-4df4-8d2b-ef91d30b6876', 'so', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'Mashruucu ma ku saabsan yahay caafimaad, nolol shaqo ama barwaaqo?', '2026-08-29 00:51:27.085901+00'),
	('d3dab2ff-abed-4292-85c3-0c0f45f25094', 'so', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'Mashruucu ma ku saabsan yahay horumarinta aqoonta ama tallaabooyinka suuqa shaqada?', '2026-08-29 00:51:27.085901+00'),
	('d3dc1d47-7416-4496-a05a-4942d53b8f55', 'so', 'Handlar projektet om miljö- eller klimatåtgärder?', 'Mashruucu ma ku saabsan yahay tallaabooyin deegaan ama cimilo?', '2026-08-29 00:51:27.085901+00'),
	('47d3e767-a463-4d15-b993-033b41e09b81', 'so', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'Ilmuhu ma leeyahay waddo dugsi oo dheer, khatar gaadiid leh ama si kale u adag?', '2026-08-29 00:51:27.085901+00'),
	('c8bf4816-25a6-4d3b-960c-943cd34cc42c', 'so', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'Ma shaqeysay ugu yaraan 16 saacadood asbuucii, wadar ahaan ugu yaraan 8 sano?', '2026-08-29 00:51:27.085901+00'),
	('f7c3c43d-d401-4989-9bd1-26b9da3e7602', 'so', 'Har du barn som bor hos dig, helt eller växelvis?', 'Ma leedahay carruur kula nool, si buuxda ama si kala duwan?', '2026-08-29 00:51:27.085901+00'),
	('c1f3d5bf-03a1-4921-96c6-48759001474c', 'so', 'Har du barn som bor hos dig?', 'Ma leedahay carruur kula nool?', '2026-08-29 00:51:27.085901+00'),
	('2cb1c67e-2ac3-4eba-9574-0c70aa61180e', 'so', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'Adiga ama ilmahaagu ma leedihiin naafanimo la filayo inay socoto ugu yaraan hal sano?', '2026-08-29 00:51:27.085901+00'),
	('c9d28be9-1fdb-4cd9-bcc3-fb63afd9624a', 'so', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'Adiga ama qof qoyska ka mid ahi ma leeyahay naafanimo joogto ah oo saameysa guriga?', '2026-08-29 00:51:27.085901+00'),
	('f27ea3d5-3eb8-449f-858a-ee60f4131dc1', 'so', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'Adiga ama qaraabo kuu dhow ma leedihiin naafanimo ama cudur muddo dheer socda ama daran?', '2026-08-29 00:51:27.085901+00'),
	('cff1ce6f-a9f5-425a-b017-05764061810d', 'so', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'Ma qabtaa cudur ama dhaawac hadda hoos u dhigaya awooddaada shaqo?', '2026-08-29 00:51:27.085901+00'),
	('bb46d107-3d8e-494a-970f-7d9737e82235', 'so', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'Weligaa ma kugu adkaatay inaad bixiso socdaal dugsi, safar fasal ama hawl firaaqo oo ilmahaaga laga filayo inuu ka qaybqaato?', '2026-08-29 00:51:27.085901+00'),
	('89361e81-46b8-4fd2-aeda-62467cff2360', 'so', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'Ma kugu adag tahay inaad ku noolaato hawlgabkaaga iyo dakhligaaga kale?', '2026-08-29 00:51:27.085901+00'),
	('b96b8019-f4a1-45df-8080-318d10bcb16b', 'so', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'Sannadihii u dambeeyay ma heshay sharci degganaansho Sweden, tus. qof magangelyo u baahan ama xubin qoys ahaan?', '2026-08-29 00:51:27.085901+00'),
	('74c5f756-6dbf-4a85-8b66-889e6fac3223', 'so', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'Ma haysataa sharci degganaansho Sweden qaxooti ahaan ama qof magangelyo u baahan (mise waxaad tahay qaraabo u dhow qof haysta)?', '2026-08-29 00:51:27.085901+00'),
	('b87eadec-d0fe-4ffd-a0f7-e3f5ba5c21bb', 'so', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'Ma gaadhay da''da tixraaca hawlgabka (67 sano 2026)?', '2026-08-29 00:51:27.085901+00'),
	('09b2a5e3-b3ff-490d-b0ef-ca58600bcee1', 'so', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'Ururkiinnu ma leeyahay OID (Organisation ID) oo ka diiwaangashan Organisation Registration System ee EU?', '2026-08-29 00:51:27.085901+00'),
	('eb89fc37-0502-47c7-b802-ac96251acf2a', 'so', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'Naafanimadu ma keentay kharashyo dheeraad ah — tus. qalab caawiye, safarro, cunto gaar ah ama duugoobid?', '2026-08-29 00:51:27.085901+00'),
	('c78cf613-4f6f-414a-afe6-1edcaf32a82b', 'so', 'Har föreningen antagna stadgar och en vald styrelse?', 'Ururku ma leeyahay xeerar la ansixiyay iyo guddi la doortay?', '2026-08-29 00:51:27.085901+00'),
	('80d0fe48-af5c-46bb-980c-1e297ddd52c1', 'so', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'Ururku ma leeyahay qaab-dhismeed dimoqraadi ah (xeerar, shir sannadeed, guddi)?', '2026-08-29 00:51:27.085901+00'),
	('8eb53eea-ae26-49de-868f-4b31fd7cf02e', 'so', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'Ururku ma u qabtaa hawlo joogto ah carruurta ama dhallinyarada?', '2026-08-29 00:51:27.085901+00'),
	('1c838d01-526e-4af3-a0bd-00c83ef44e43', 'so', 'Har företaget mellan cirka 2 och 49 anställda?', 'Shirkaddu ma leedahay inta u dhaxaysa qiyaastii 2 iyo 49 shaqaale?', '2026-08-29 00:51:27.085901+00'),
	('a245e282-0cee-440f-b9ae-ee99f1a55d62', 'so', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'Qoysku ma ku dhibtoodaa daboolidda kharashka cuntada, guriga iyo waxyaabaha ugu muhiimsan?', '2026-08-29 00:51:27.085901+00'),
	('732264a1-7e9b-4120-be12-f9090ff6c38c', 'so', 'Har lösningen internationell potential?', 'Xalku ma leeyahay awood caalami ah?', '2026-08-29 00:51:27.085901+00'),
	('50abbb15-2134-4b6e-b2fd-53f66ef06abe', 'so', 'Har ni en partnergrupp i ett annat land?', 'Ma leedihiin koox shuraako ah dal kale?', '2026-08-29 00:51:27.085901+00'),
	('9a85c660-2320-4d20-b557-e6a53b0038e5', 'so', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'Ma leedihiin urur shuraako ah dal kale oo Yurub ah?', '2026-08-29 00:51:27.085901+00'),
	('5acb7f2b-42ff-4be7-8dc1-4a65d489c4cf', 'so', 'Har ni partner i minst tre olika europeiska länder?', 'Ma ku leedihiin shuraako ugu yaraan saddex dal oo Yurub ah oo kala duwan?', '2026-08-29 00:51:27.085901+00'),
	('343a8678-155d-4c40-99c9-a48c56838499', 'so', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'Xaruntiinnu ama hawshiinna ugu weyni ma ku taal gobolka aad ka codsanaysaan?', '2026-08-29 00:51:27.085901+00'),
	('3d810886-fbee-4885-be4f-679ab6fe406d', 'so', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'Mid ka mid ah carruurtaadu ma leeyahay naafanimo ka dhigaysa inuu u baahdo daryeel ama ilaalin ka badan carruurta kale ee da''diisa ah?', '2026-08-29 00:51:27.085901+00');
INSERT INTO public.kb_translations VALUES
	('c0cd59d7-c595-4427-9cca-8abdabf7442b', 'so', 'Har organisationen en demokratisk uppbyggnad?', 'Ururku ma leeyahay qaab-dhismeed dimoqraadi ah?', '2026-08-29 00:51:27.085901+00'),
	('f808d358-b3b6-4514-bca6-2d7827b44da5', 'so', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'Ururku ma leeyahay Quality Label (calaamad tayo)?', '2026-08-29 00:51:27.085901+00'),
	('397a55d4-196f-4f83-ace1-ef79a39f6335', 'so', 'Har organisationen ett 90-konto?', 'Ururku ma leeyahay 90-konto?', '2026-08-29 00:51:27.085901+00'),
	('57be377b-ec7b-4cbf-8147-e99d5dba4893', 'so', 'Har organisationen ett OID (Organisation ID)?', 'Ururku ma leeyahay OID (Organisation ID)?', '2026-08-29 00:51:27.085901+00'),
	('1e38db3a-d931-4add-82ea-e40a9a7e7194', 'so', 'Har organisationen ett OID?', 'Ururku ma leeyahay OID?', '2026-08-29 00:51:27.085901+00'),
	('4a82545d-77f0-471f-81ff-43d1700d4f59', 'so', 'Har organisationen medlemsföreningar i flera län?', 'Ururku ma ku leeyahay ururro xubno ah dhowr gobol?', '2026-08-29 00:51:27.085901+00'),
	('f381ca5c-e5d9-4554-b818-dab5bade329f', 'so', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'Ururku ma leeyahay dhaqaale nidaamsan iyo qaab-dhismeed dimoqraadi ah?', '2026-08-29 00:51:27.085901+00'),
	('bb72be86-f1b6-4ca8-9ade-edf906a5d7ae', 'so', 'Har projektet en partner i ett annat land?', 'Mashruucu ma leeyahay shuraako dal kale?', '2026-08-29 00:51:27.085901+00'),
	('4e995796-e4c0-412f-92d4-95c7f3740cb9', 'so', 'Har projektledaren doktorsexamen?', 'Hoggaamiyaha mashruucu ma haystaa shahaadada dhoktoorada?', '2026-08-29 00:51:27.085901+00'),
	('335527d8-1e0f-4591-97b9-adfd3ba7a742', 'so', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Degmada aad degan tahay waa inay bixiso safarrada maalinlaha ah ee u dhexeeya guriga iyo dugsiga sare marka waddadu tahay ugu yaraan lix kiilomitir (tus. kaadhka baska).', '2026-08-29 00:51:27.085901+00'),
	('52c0a7de-6a9b-4fba-8356-ab0fe5f808fb', 'so', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'Ma ku guda jirtaa helidda ama qalabaynta gurigaaga ugu horreeya ee Sweden?', '2026-08-29 00:51:27.085901+00'),
	('2e950a14-388b-4385-b63a-a57bdc28b066', 'so', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'Mashruucu ma ku jiraa safar ama isweydaarsi caalami ah?', '2026-08-29 00:51:27.085901+00'),
	('0a1c1260-af1d-4988-833a-26b13bc44d19', 'so', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Taageero maalgelin oo loogu talagalay shirkadaha aagagga taageerada — dhismayaal, mashiinno iyo tababar.', '2026-08-29 00:51:27.085901+00'),
	('5d9cde7f-5b07-4869-9cbe-c7a462f93cbc', 'so', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Taageero maalgelin oo loogu talagalay tallaabooyin yareeya qiiqa gaaska lab-guriyeed.', '2026-08-29 00:51:27.085901+00'),
	('03589897-7226-4cd0-93ca-a7e8adafed0c', 'so', 'Kan projektets miljönytta mätas?', 'Faa''iidada deegaanka ee mashruuca ma la cabbiri karaa?', '2026-08-29 00:51:27.085901+00'),
	('7faee4ef-f4ec-4ea1-8f4b-3e1f546db633', 'so', 'Kan åtgärdens utsläppsminskning beräknas?', 'Yaraynta qiiqa ee tallaabada ma la xisaabin karaa?', '2026-08-29 00:51:27.085901+00'),
	('c350a5fc-9fee-4be0-8685-998cfa040c68', 'so', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'Ururku ma awoodaa inuu qaado kharashyada ilaa taageerada la bixiyo?', '2026-08-29 00:51:27.085901+00'),
	('93389122-5430-432f-bec1-ffbdbd29ef3a', 'so', 'Är minst 60 % av medlemmarna under 26 år?', 'Ugu yaraan 60 % xubnuhu ma ka yar yihiin 26 jir?', '2026-08-29 00:51:27.089585+00'),
	('2634f576-165b-4c1b-8d77-c5c626c1d052', 'so', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'Maalgelintu ma bilaabmaysaa kaliya kadib markaad codsiga dirto?', '2026-08-29 00:51:27.085901+00'),
	('ba425b2e-caff-4271-9e03-18f71121c5e4', 'so', 'Kommer projektet människor i ert närområde till del?', 'Mashruucu ma anfacaa dadka deegaankiinna?', '2026-08-29 00:51:27.085901+00'),
	('7c48d506-8cbf-494c-81bb-49bcaf509377', 'so', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Shabakadda badbaadada dhaqaale ee ugu dambeysa ee degmada marka dakhligu uusan gaadhin waxyaabaha ugu muhiimsan.', '2026-08-29 00:51:27.085901+00'),
	('c97f867e-8e47-4c85-95d3-877eb38cdb21', 'so', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'Taageerooyinka gaarka ah ee degmooyinka ee ururrada maxalliga ah: taageero hawleed goob kasta, gunno goob, gunno bilow iyo wax kale.', '2026-08-29 00:51:27.085901+00'),
	('ca670428-9ee2-471f-ba55-58cb41907e36', 'so', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Gaadiid dugsi oo bilaash ah oo loogu talagalay ardayda dugsiga hoose-dhexe marka masaafadu dheer tahay, waddadu khatar tahay ama naafanimo jirto — xaq sida uu dhigayo sharciga dugsiyada.', '2026-08-29 00:51:27.085901+00'),
	('7191a00d-98b5-491a-8e77-ee8b57ae967e', 'so', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Gunno sharci ah oo muraayado indho ama lenso ah oo loogu talagalay carruurta iyo dhallinyarada; qaddarka iyo habraacu way ku kala duwan yihiin gobolka — hubi heerka gobolkaaga.', '2026-08-29 00:51:27.085901+00'),
	('4889f14d-f3a1-412d-9dfa-f0a2c9b011bc', 'so', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'Mashruucu ma ku yaal deegaan ay khusayso korontada biyaha ama dabayshu?', '2026-08-29 00:51:27.085901+00'),
	('7be235a4-869b-4e0f-bce2-feb94229babf', 'so', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'Mashruucu ma ku jiraa deegaanka, cilmiga beeraha ama qorshaynta magaalooyinka?', '2026-08-29 00:51:27.085901+00'),
	('8c023a9f-f9f1-49aa-81c2-e3559b8e4087', 'so', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'Goobta hawshu ma ku taal aagga taageerada A ama B (qaybo badan oo Norrland iyo Svealand gudaha ah)?', '2026-08-29 00:51:27.085901+00'),
	('17293005-ae52-46f4-b42a-c33a976e9e15', 'so', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Deyn lagu iibsado waxyaabaha ugu muhiimsan ee guriga ugu horreeya ee Sweden — fadhi, qalab guri iyo qalab kale oo aasaasi ah.', '2026-08-29 00:51:27.085901+00'),
	('4b90e53e-946e-4dff-92fc-d0791e792811', 'so', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'Mashruucu ma yareeyaa qiiqa hawlaha warshadaha mise wuxuu abuuraa qiiq taban?', '2026-08-29 00:51:27.085901+00'),
	('476d1e94-01c2-4770-8af1-9a3d77721499', 'so', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'Gunno bille ah oo loogu talagalay carruurta Sweden ku nool, dhalashada ilaa 16 jir.', '2026-08-29 00:51:27.085901+00'),
	('7eff44f8-9426-45a2-b9bb-1bff0b5ed580', 'so', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket waxay gunnooyin siisaa ururro, shirkado, jameecooyin, qaybta dadweynaha iyo shakhsiyaad dhinaca deegaanka.', '2026-08-29 00:51:27.085901+00'),
	('173f56bc-dbcd-4b6f-9ebe-46e8db488737', 'so', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'Ma qorsheyneysaa inaad si mutadawacnimo ah oo joogto ah ugu laabato dalkaagii asalka ahaa?', '2026-08-29 00:51:27.085901+00'),
	('d05dd383-513d-4b40-b204-3f746a2036aa', 'so', 'Planerar du att starta eget företag?', 'Ma qorsheyneysaa inaad bilowdo ganacsi adiga kuu gaar ah?', '2026-08-29 00:51:27.085901+00'),
	('c463b2d9-d30b-41fd-bebf-bb38980217f0', 'so', 'Planerar du att studera utomlands?', 'Ma qorsheyneysaa inaad dibadda wax ku barato?', '2026-08-29 00:51:27.085901+00'),
	('34999049-b728-490c-a9cd-2cc1d936db60', 'so', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'Ma qorsheyneysaa waxbarasho xoojisa meeshaad ka taagan tahay suuqa shaqada?', '2026-08-29 00:51:27.085901+00'),
	('b70201ed-cd96-4cf9-b418-7fbc6663dc23', 'so', 'Planerar ni att anställa?', 'Ma qorsheyneysaan inaad shaqaaleysiisaan?', '2026-08-29 00:51:27.085901+00'),
	('ff695fe7-0625-41de-8ce4-b596afbf9dab', 'so', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'Ma qorsheyneysaan inaad codsataan barnaamij EU (tus. Horisont Europa)?', '2026-08-29 00:51:27.085901+00'),
	('1ea7005c-500e-4118-8640-f8634bbee96b', 'so', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Taageero soo-saarid iyo horumarin oo loogu talagalay filimo gaagaaban iyo dokumentari.', '2026-08-29 00:51:27.085901+00'),
	('55fb418b-b4ca-4d1e-b09f-306d3832b7ed', 'so', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Gunnooyin mashruuc oo loogu talagalay goobta muusiga ee madaxbannaan: riwaayado, soo-saarid iyo horumarin.', '2026-08-29 00:51:27.085901+00'),
	('d4a102b5-dce5-4e5d-a5dd-3d4ddaad68f9', 'so', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'Gunnooyin mashruuc oo loogu talagalay ururrada aan faa''iido doonka ahayn ee la shaqeeya carruurta iyo dhallinyarada, unana shaqeeya iyaga.', '2026-08-29 00:51:27.085901+00'),
	('dc0bf9e4-c540-4bf5-ae5e-90b349c329f2', 'so', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'Mashruucu ma tijaabiyaa muujinno, habab ama iskaashiyo faneed oo cusub?', '2026-08-29 00:51:27.085901+00'),
	('6e836aa4-ce66-4083-a3ec-193300beffec', 'so', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'Isweydaarsigu ma socdaa 5–21 maalmood (aan lagu darin maalmaha safarka)?', '2026-08-29 00:51:27.085901+00'),
	('96988b7a-3bdd-4a66-8a7c-423236c3e972', 'so', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Taageerooyinka gaarka ah ee gobollada ee mashaariicda iyo hawlaha dhaqanka, oo ka baxsan gunnooyinka qaranka ee Kulturrådet.', '2026-08-29 00:51:27.085901+00'),
	('ff2e127f-dfaf-4573-a3b0-51fb9eab4514', 'so', 'Riktar sig projektet till barn eller unga?', 'Mashruucu ma u jiheysan yahay carruurta ama dhallinyarada?', '2026-08-29 00:51:27.085901+00'),
	('f95f46dc-2bf3-49d5-b887-4699a3bf7b3a', 'so', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'Mashruucu ma u jiheysan yahay carruurta, dhallinyarada, waayeelka ama dadka naafada ah?', '2026-08-29 00:51:27.085901+00'),
	('2fc01479-3b76-4d96-885b-e1b2c24acb41', 'so', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'Hawshu ma u jiheysan tahay carruurta iyo dhallinyarada (7–25 jir)?', '2026-08-29 00:51:27.085901+00'),
	('960b0576-2131-4c8a-bc54-5190e7806e30', 'so', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'Ma waayey kayd lacageed ama hanti dabooli karta kharashyada?', '2026-08-29 00:51:27.085901+00'),
	('282770b9-0d9e-452b-a21f-d43c1c3528bf', 'so', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'Ma la shaqeysaan shuraako jooga ugu yaraan laba dal oo kale oo Waqooyiga Yurub ah?', '2026-08-29 00:51:27.085901+00'),
	('26200df6-6e92-4fb0-bd44-63412b6dfe24', 'so', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'Ma keensanaysaan aqoon dibadeed hawl horumarineed dartood?', '2026-08-29 00:51:27.085901+00'),
	('31d381e2-afad-4d28-90b3-3284d18e7c37', 'so', 'Sker mobiliteten till ett annat europeiskt land?', 'Dhaqdhaqaaqu ma u socdaa dal kale oo Yurub ah?', '2026-08-29 00:51:27.085901+00');
INSERT INTO public.kb_translations VALUES
	('f681e863-13b9-4029-9bdb-de5a54eb2007', 'so', 'Startar du eller tar du över företaget för första gången?', 'Markan ma tahay markii ugu horreysay oo aad bilowdo ama la wareegto ganacsiga?', '2026-08-29 00:51:27.085901+00'),
	('8b792dfe-932b-46c9-9153-39075a4b8e67', 'so', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Taageero bilow oo loogu talagalay qofka 40 jir ama ka yar ee bilaabaya ama la wareegaya ganacsi beeraley ah.', '2026-08-29 00:51:27.085901+00'),
	('836fd7c1-5d50-46aa-a627-141ba9438bce', 'so', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Deeq-waxbarasho u oggolaanaysa fannaaniinta xirfadleyda ah inay diiradda saaraan shaqadooda faneed.', '2026-08-29 00:51:27.085901+00'),
	('a7ad0328-1f68-481f-b1e3-2a78b19e97f3', 'so', 'Studerar du, eller planerar du att börja studera?', 'Wax ma baranaysaa, mise waxaad qorsheyneysaa inaad bilowdo waxbarasho?', '2026-08-29 00:51:27.085901+00'),
	('c1f7019d-09c0-4c10-9a5b-07e190e0d22b', 'so', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Taageero waxbarasho oo loogu talagalay dadka waaweyn ee shaqeeya ee doonaya inay wax bartaan si ay u xoojiyaan meeshay ka taagan yihiin suuqa shaqada.', '2026-08-29 00:51:27.085901+00'),
	('9d4b1f30-2a25-4562-ab88-c4378448b1d1', 'so', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Taageero maalgelinno kordhiya tartanka ama yareeya saameynta deegaanka ee ganacsiyada beeraleyda.', '2026-08-29 00:51:27.085901+00'),
	('aa67a409-612f-473d-93f3-e6e3b0206043', 'so', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Taageero marka ilmo kula nool yahay oo waalidka kale uusan bixin masruuf.', '2026-08-29 00:51:27.085901+00'),
	('d21fe555-708e-42e9-a744-15498904a49c', 'so', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Taageero mashaariicda ururrada aan faa''iido doonka ahayn ee dadka, deegaanka iyo dunida ka wanaagsan.', '2026-08-29 00:51:27.085901+00'),
	('d4187498-71a5-4665-ae43-d3252a972b1d', 'so', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Taageero u-gudubka warshadaha ee eber qiiqa gaaska lab-guriyeed.', '2026-08-29 00:51:27.085901+00'),
	('37aedf28-2c6b-409a-9f1a-ee25aae4b877', 'so', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Taageero mashaariicda fanka iyo dhaqanka ee leh muuqaal waqooyi-yurubeed iyo iskaashi xuduudaha ka gudba.', '2026-08-29 00:51:27.085901+00'),
	('3c77d3e4-a87a-413f-97b3-1d6801920f70', 'so', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Taageero mashaariic dhaqameed hal-abuur leh oo tijaabinaya muujinno, habab ama iskaashiyo faneed oo cusub.', '2026-08-29 00:51:27.085901+00'),
	('ea3646c8-d545-483f-b339-8133e7022d3a', 'so', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Taageero mashaariic hal-abuur leh oo loogu talagalay carruurta, dhallinyarada, waayeelka iyo dadka naafada ah.', '2026-08-29 00:51:27.085901+00'),
	('a22b4a2d-459a-4b11-b76e-84a9f7fc4417', 'so', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Taageero mashaariicda iskaashiga ee goobta muusiga madaxbannaan.', '2026-08-29 00:51:27.085901+00'),
	('3b0b1619-1f5a-447f-8a43-ec90811ec0fc', 'so', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Taageero mashaariicda iskaashiga ee dhaqanka iyo warbaahinta ee xoojiya dimoqraadiyadda iyo xorriyadda hadalka caalami ahaan.', '2026-08-29 00:51:27.085901+00'),
	('2c7dc2b8-c96d-4caf-9982-928d5574d56f', 'so', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'Mashruucu ma hiigsadaa xoojinta dimoqraadiyadda, sinnaanta ama xorriyadda hadalka?', '2026-08-29 00:51:27.085901+00'),
	('6cf22cb4-1bb0-44c1-a37a-14ae1d4934a3', 'so', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'Shaqo ma ka raadinaysaa, mise waxaa lagaa siiyay shaqo, dal kale oo EU ama EES ah?', '2026-08-29 00:51:27.085901+00'),
	('7d4272bc-c7e7-4901-b537-7b01d3aadde7', 'so', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'Xad sare oo waxa aad bixiso khidmadaha bukaanka muddo laba iyo toban bilood ah — kadibna frikort (kaadh bilaash ah).', '2026-08-29 00:51:27.085901+00'),
	('cda06904-f614-4e4b-b81b-e1b7c9a4f7c8', 'so', 'Tar du ut hel allmän pension?', 'Ma qaadataa hawlgabkaaga guud oo dhammaystiran?', '2026-08-29 00:51:27.085901+00'),
	('9079c89c-4a2e-4bd0-a22b-5e2ba6b08d31', 'so', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Kordhin daboolaysa qayb ka mid ah kharashka guriga qofka haysta hawlgab iyo dakhli hooseeya.', '2026-08-29 00:51:27.085901+00'),
	('68569860-4a91-4e7f-be2b-7327571b851d', 'so', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Gunno urureed sannadle ah oo loogu talagalay ururrada qaranka ee carruurta iyo dhallinyarada.', '2026-08-29 00:51:27.085901+00'),
	('5ae3e034-0f14-4c37-b2df-d8a202f352b9', 'so', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'Xisaab sannadle ah oo si toos ah looga jaro dhakhtarka ilkaha ama nadiifiyaha ilkaha.', '2026-08-29 00:51:27.085901+00'),
	('89577517-99af-4041-a4a4-b8c491281b35', 'so', 'Är bolaget yngre än cirka 5 år?', 'Shirkaddu ma ka yar tahay qiyaastii 5 sano?', '2026-08-29 00:51:27.085901+00'),
	('6933dfc0-1a21-452c-87a8-a71bf12970ab', 'so', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'Ka-qaybgalayaasha isweydaarsigu ma u dhexeeyaan 13 iyo 30 jir?', '2026-08-29 00:51:27.085901+00'),
	('984d5113-f289-4abf-b941-689a8b95dd60', 'so', 'Är det här ert första EU-projekt?', 'Kani ma mashruucii EU ee idiin ugu horreeyay baa?', '2026-08-29 00:51:27.085901+00'),
	('f4d70b4f-f01d-4831-8568-e416e958c7e0', 'so', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'Ma aad ugu adag tahay adiga (ama ilmahaaga) inaad keligaa dhaqdhaqaaqdo ama aad ku safarto bas iyo tareen?', '2026-08-29 00:51:27.085901+00'),
	('7a427981-5408-436a-bc1b-6b658e697898', 'so', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Dakhligaagu ma ka yar yahay qiyaastii 25 000 kr bishii canshuurta ka hor?', '2026-08-29 00:51:27.085901+00'),
	('57fee70f-9982-41ad-a04a-93b58a5e2853', 'so', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'Waxbarashadaadii ugu dambeysay ee dhammaystirneyd ma dugsiga hoose-dhexe baa, mise dugsi sare oo aadan dhammaystirin?', '2026-08-29 00:51:27.085901+00'),
	('20a5cb81-d553-42cf-926f-4888b5571c34', 'so', 'Är du 40 år eller yngre?', 'Ma tahay 40 jir ama ka yar?', '2026-08-29 00:51:27.085901+00'),
	('ab4f90a2-3888-4ba0-97c9-fe303771d72a', 'so', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'Ma ka diiwaangashan tahay Arbetsförmedlingen shaqo-doon ahaan?', '2026-08-29 00:51:27.085901+00'),
	('83354fd4-f938-45c4-9df1-2aff1a00657d', 'so', 'Är du mellan 18 och 28 år?', 'Ma u dhexeysaa 18 iyo 28 jir?', '2026-08-29 00:51:27.085901+00'),
	('96a5dfba-8767-4415-9317-019f3a7fb8ce', 'so', 'Är du mellan 19 och 29 år?', 'Ma u dhexeysaa 19 iyo 29 jir?', '2026-08-29 00:51:27.085901+00'),
	('4b23602a-9d96-486f-b43e-c331f27e42ad', 'so', 'Är du mellan 25 och 60 år?', 'Ma u dhexeysaa 25 iyo 60 jir?', '2026-08-29 00:51:27.085901+00'),
	('14a90c07-08a0-437d-9624-d05379a73aad', 'so', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'Si xirfadle ah ma uga shaqeysaa dhinaca dhaqanka (tus. qoob-ka-ciyaar, muusig, fanka masraxa)?', '2026-08-29 00:51:27.085901+00'),
	('ec8e4c7a-fec9-49f7-a062-0104eb6d5129', 'so', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'Ma tahay fannaan xirfadle ah (ma tihid hiwaayad ama tababar aasaasi ah)?', '2026-08-29 00:51:27.085901+00'),
	('cfc6bcef-9f2d-46e1-a22a-ef8725bdd74b', 'so', 'Är du yrkesverksam konstnär?', 'Ma tahay fannaan xirfadle ah?', '2026-08-29 00:51:27.085901+00'),
	('004eeaf6-05b3-4be3-bd03-5ac1e374d817', 'so', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'Xalkiinnu ma yahay mid si weyn hal-abuur ugu ah marka la barbardhigo waxa horeba u jira?', '2026-08-29 00:51:27.089585+00'),
	('33488f7a-d734-4f88-9bea-ba77b2e2267f', 'so', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'Naadigu ma ka tirsan yahay xiriir isboorti oo gaar ah oo hoos yimaadda Riksidrottsförbundet?', '2026-08-29 00:51:27.089585+00'),
	('122b8839-88fb-4e59-9727-14cfea12c892', 'so', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'Dakhliga qoysku ma hooseeyaa marka loo eego kharashka guriga?', '2026-08-29 00:51:27.089585+00'),
	('59e1b63d-ed89-41f8-b0b1-c16b16210ac2', 'so', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'Dakhliga wadajirka ah ee qoysku ma ka yar yahay qiyaastii 25 000 kr bishii canshuurta ka hor?', '2026-08-29 00:51:27.089585+00'),
	('267f995e-95c2-4da9-846b-eb4b45040667', 'so', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'Tallaabadu ma tahay mashruuc go''an (ma aha hawsha caadiga ah)?', '2026-08-29 00:51:27.089585+00'),
	('72c56202-215c-46e8-9d1c-0c875a92091d', 'so', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'Goobtu ma u furan tahay dhammaan dadka — ma aha oo kaliya xubnihiinna?', '2026-08-29 00:51:27.089585+00'),
	('d3ce63f1-fc43-4a7a-a492-a6793f4e079e', 'so', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'Ugu yaraan 60 % xubnuhu ma u dhexeeyaan 6 iyo 25 jir?', '2026-08-29 00:51:27.089585+00'),
	('b8b7c0e3-3ef4-4cfb-adf0-b3a2336543a7', 'so', 'Är målgruppen delaktig i planering och genomförande?', 'Kooxda bartilmaameedka ahi ma ka qaybqaataa qorshaynta iyo fulinta?', '2026-08-29 00:51:27.089585+00'),
	('a2eeef4b-4641-4617-94cb-20ab57843739', 'so', 'Är ni ett förlag med professionell utgivning?', 'Ma tihiin daabacaad leh daabacaad xirfadle ah?', '2026-08-29 00:51:27.089585+00'),
	('2129ed9d-3d17-47b0-bfa4-d7730c5f6abd', 'so', 'Är ni huvudman för förskoleklass eller grundskola?', 'Ma tihiin masuulka fasalka dugsi-barbaarinta ama dugsiga hoose-dhexe?', '2026-08-29 00:51:27.089585+00'),
	('19bb6a87-51b8-44b6-b1ac-e4d4832881bb', 'so', 'Är organisationen registrerad i EU:s deltagarregister?', 'Ururku ma ka diiwaangashan yahay diiwaanka ka-qaybgalayaasha ee EU?', '2026-08-29 00:51:27.089585+00'),
	('d62ea9a0-e7c4-4c65-bbf5-b799a4d8cbac', 'so', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'Mashruucu ma yahay mashruuc filim (filim gaaban ama dokumentari)?', '2026-08-29 00:51:27.089585+00'),
	('ce886e62-e869-4df3-8aed-508685e5d5bc', 'so', 'Är projektet ett konst- eller kulturprojekt?', 'Mashruucu ma yahay mashruuc faneed ama dhaqameed?', '2026-08-29 00:51:27.089585+00'),
	('b470362e-2c8d-407f-ab37-3d73797c6cd3', 'so', 'Är projektet ett kulturprojekt?', 'Mashruucu ma yahay mashruuc dhaqameed?', '2026-08-29 00:51:27.089585+00'),
	('b2a7fb47-ec33-4906-925b-964c11fd9a05', 'so', 'Är projektet ett musikprojekt?', 'Mashruucu ma yahay mashruuc muusig?', '2026-08-29 00:51:27.089585+00');
INSERT INTO public.kb_translations VALUES
	('de356a1c-8fb6-49da-aef2-78c47437db63', 'so', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'Mashruucu ma yahay hal-abuur — wax aydaan horeba ugu samayn hawshiinna caadiga ah?', '2026-08-29 00:51:27.089585+00'),
	('6f4134e4-0e22-4209-9d29-61f928261632', 'so', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'Mashruucu ma anfacaa deegaanka oo dhan (ma aha shakhsiyaad)?', '2026-08-29 00:51:27.089585+00'),
	('6edc33a3-f486-4cec-8887-597090dab4a9', 'so', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'Waddada u dhexeysa guriga iyo dugsiga sare ma tahay ugu yaraan lix kiilomitir?', '2026-08-29 00:51:27.089585+00'),
	('b0d4b295-e947-4a12-b939-f7bfd926cea0', 'so', 'Är verksamheten professionell (inte amatörverksamhet)?', 'Hawshu ma tahay mid xirfadle ah (ma aha hiwaayad)?', '2026-08-29 00:51:27.089585+00'),
	('4c0eddb1-1e01-4808-913f-a4534f832a05', 'so', 'Är verksamheten professionell?', 'Hawshu ma tahay mid xirfadle ah?', '2026-08-29 00:51:27.089585+00'),
	('1d0db741-9205-43de-bf0a-5509ab7e486b', 'so', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'Hawshu ma tahay fanka masraxa (qoob-ka-ciyaar, masrax, masrax muusig)?', '2026-08-29 00:51:27.089585+00'),
	('25d04cb4-c669-4888-9607-55296a5f7c7a', 'so', 'Är volontärerna mellan 18 och 30 år?', 'Mutadawiciintu ma u dhexeeyaan 18 iyo 30 jir?', '2026-08-29 00:51:27.089585+00'),
	('22e8ab51-96a4-4bf6-a1cb-130da273fe31', 'ti', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'ንስፖርታዊ ማሕበራት ንህጻናትን መንእሰያትን 7–25 ዓመት ብመራሒ ዝምራሕ ንጥፈታት ዘካይዳ ዝወሃብ ደገፍ ንጥፈታት።', '2026-08-29 00:51:27.094571+00'),
	('a4a3f406-7dc3-40a2-8ec6-8f9d1e20d431', 'ti', 'Automatiskt tillägg till barnbidraget från och med det andra barnet.', 'ካብ ካልኣይ ውሉድ ጀሚሩ ኣብ ልዕሊ ናይ ህጻናት ሓገዝ (barnbidrag) ብቐጥታ ዝውሰኽ ተወሳኺ።', '2026-08-29 00:51:27.094571+00'),
	('4fa5a12b-31d0-46fe-9151-24b52b0c6860', 'ti', 'Avser ansökan en fysisk investering?', 'እቲ ማመልከቻ ንኣካላዊ ወፍሪ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('4a66c1fa-1dc6-42e2-b074-eaefb81761f1', 'ti', 'Avser ansökan en internationell resa eller ett internationellt utbyte?', 'እቲ ማመልከቻ ንኣህጉራዊ ጕዕዞ ወይ ምልውዋጥ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('c5b50350-b847-473f-a9d8-34e6e2bb833a', 'ti', 'Avser ansökan en investering i byggnader eller maskiner?', 'እቲ ማመልከቻ ኣብ ህንጻታት ወይ ማሽናት ንዝግበር ወፍሪ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('2b77eeb6-9907-47ad-a4fe-c5281a5b6edc', 'ti', 'Avser ansökan en redan utgiven titel?', 'እቲ ማመልከቻ ድሮ ንዝተሓትመ ስራሕ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('b598420f-581d-4f83-98e5-b12b6c3e0ca6', 'ti', 'Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?', 'እቲ ማመልከቻ ንሕርሻዊ፣ ኣታኽልታዊ ወይ ናይ ሰሜናዊ ጤለ-በጊዕ ኣርብሓ ትካል ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('5fe91093-8059-4990-a91c-5767d37bddcc', 'ti', 'Avser ansökan litteraturinköp till folk- eller skolbibliotek?', 'እቲ ማመልከቻ ንህዝባዊ ወይ ናይ ቤት-ትምህርቲ ኣብያተ-መጻሕፍቲ መጻሕፍቲ ምዕዳግ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('49edf2e9-f672-4235-bdb4-9d93509c8a33', 'ti', 'Avser investeringen jordbruksverksamhet?', 'እቲ ወፍሪ ንሕርሻዊ ንጥፈት ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('6626f0ed-541f-4adc-bf84-5436648d8fa2', 'ti', 'Avser projektet att bygga, köpa eller rusta upp en lokal?', 'እቲ ፕሮጀክት ምህናጽ፣ ምዕዳግ ወይ ምጽጋን ኣዳራሽ ድዩ ዘጠቓልል?', '2026-08-29 00:51:27.094571+00'),
	('a102f3fc-eb95-4906-ada1-4ef62eef5d98', 'ti', 'Avser projektet naturvård eller friluftsliv?', 'እቲ ፕሮጀክት ንሓለዋ ተፈጥሮ ወይ ንደገ ዝግበር ምዝንጋዕ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('d0b135de-3e18-4a7c-9801-04d049fdb88f', 'ti', 'Avser projektet skola eller vuxenutbildning?', 'እቲ ፕሮጀክት ንቤት-ትምህርቲ ወይ ንትምህርቲ ዓበይቲ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('2df1ecbc-f255-4082-871d-9def31a362ad', 'ti', 'Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?', 'ሕማሙ ንህይወቱ ዘስግእ ብጽኑዕ ዝሓመመ ቀረባ ሰብ ንምክንኻን ወይ ኣብ ጐድኑ ንምህላው ካብ ስራሕ ትቑጠብ ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('e46da3a1-0f32-4835-b1ed-52d4455f822c', 'ti', 'Bedriver föreningen regelbunden verksamhet i kommunen?', 'እቲ ማሕበር ኣብቲ ምምሕዳር ከተማ ስሩዕ ንጥፈታት ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('8eff8401-5981-4f19-80f7-0087b26d083b', 'ti', 'Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?', 'ብሰንኪ ሕማም ወይ ስንክልና ናይ ስራሕ ዓቕምኻ እንተ ወሓደ ንሓደ ዓመት ከም ዝጐደለ ትግምግም ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('6aee7669-b57e-4404-ade0-578ce1405b9a', 'ti', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'ንትሑት ወይ ዜብሉ ጡረታ ዘለዎም እሞ ብቑዕ ደረጃ ናብራ ንምብጻሕ ሓገዝ ዘድልዮም ብድሌት ዝግምገም ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('2d59d50a-12a2-43a9-82ee-cbfb08fadbe5', 'ti', 'Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?', 'እቲ ቆልዓ መገዲ ኣዝዩ ነዊሕ ስለ ዝኾነ ኣብ ቦታ ትምህርቲ ክቕመጥ (መንበሪ) የድልዮ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('7532c36b-dbd4-4b8c-bb8e-ff0c944a4f24', 'ti', 'Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?', 'እቲ መንበሪ ምምዕርራይ የድልዮ ድዩ (ንኣብነት መደያይቦ፣ መኽፈቲ ማዕጾ፣ መሕጸቢ)?', '2026-08-29 00:51:27.094571+00'),
	('0bb13850-6ef0-49ef-a41b-0d47c07ca586', 'ti', 'Behöver något av dina barn i åldern 8–19 år glasögon eller linser?', 'ካብ ደቅኻ ኣብ ዕድመ 8–19 ዘሎ መነጽር ወይ ሌንስ የድልዮ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('8df08204-f9b6-4318-ace3-44e209544d6b', 'ti', 'Betalar den andra föräldern inget eller mindre än fullt underhåll?', 'እቲ ካልእ ወላዲ ገለ ኣይከፍልን ወይ ካብ ምሉእ ቀለብ ዝወሓደ ድዩ ዝኸፍል?', '2026-08-29 00:51:27.094571+00'),
	('31b0d757-113f-45cd-99d3-b01c485cff07', 'ti', 'Betalar du hyra eller andra boendekostnader?', 'ክራይ ወይ ካልእ ወጻኢታት መንበሪ ትኸፍል ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('908628f2-f546-4c6c-acb0-2099213faf3a', 'ti', 'Kommer investeringen att påbörjas först efter att ni skickat in ansökan?', 'እቲ ወፍሪ ማመልከቻ ምስ ለኣኽኩም ጥራይ ድዩ ዝጅምር?', '2026-08-29 00:51:27.094571+00'),
	('f3286871-1161-43b1-8dba-62f2c9c55e87', 'ti', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'ኣብ እዋን ስንክልና ንመንበሪ ምምዕርራይ ዝወሃብ ሓገዝ — ንኣብነት መደያይቦታት፣ መኽፈቲ ማዕጾ ወይ ምምዕርራይ መሕጸቢ።', '2026-08-29 00:51:27.094571+00'),
	('3ccd2b1e-02f9-47ea-b0ef-9160afbfeb6d', 'ti', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'ህዝባዊ ኣዳራሻት ኣኼባ ንምህናጽ፣ ንምዕዳግ ወይ ንምጽጋን ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('9a613ac0-f878-4742-aa8a-9e84d3d93c97', 'ti', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'ቀዋሚ ስንክልና ምንቅስቓስ ወይ ብህዝባዊ መጓዓዝያ ምጕዓዝ ኣዝዩ ኣጸጋሚ ምስ ዝገብሮ መኪና ንምዕዳግ ወይ ንምምዕርራይ ዝወሃብ ሓገዝ።', '2026-08-29 00:51:27.094571+00'),
	('d2c68555-bea9-4f79-85ee-6bf6fffbf688', 'ti', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'ኣብ ዓውዲ ባህሊ ንዝሰርሑ ሞያውያን ንኣህጉራዊ ጕዕዞታትን ምልውዋጣትን ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('48904355-a273-4823-98bf-3c96673b97f8', 'ti', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'ንሞያውያን ስነ-ጥበበኛታት ኣህጉራዊ ምልውዋጣት፣ ጕዕዞታትን ናይ ስራሕ ጻንሒታትን ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('f6181c5c-24f5-4d31-a25b-e9a799adeef0', 'ti', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'ኣብ ደረጃ ካልኣይ ደረጃ ወይ ድሕሪኡ ንዝግበር ትምህርቲ ሓገዝን ወለንታዊ ልቓሕን።', '2026-08-29 00:51:27.094571+00'),
	('6abea79e-7762-43c7-a793-33b2801c4d53', 'ti', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'ኣብ ወጻኢ ንዝግበር ትምህርቲ ሓገዛትን ልቓሓትን፣ ንኣብነት ክፍሊት ትምህርትን ጕዕዞን ዝሽፍኑ ተወሰኽቲ ልቓሓት ዘለዉዎ።', '2026-08-29 00:51:27.094571+00'),
	('278d0546-3cfe-4340-9803-1fad82d9cc23', 'ti', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'ንሽወደናውያን ኣካላት ናብ ናይ EU መደባት ከም Horisont Europa ማመልከቻ ንምድላው ዝሕግዝ ሓገዝ።', '2026-08-29 00:51:27.094571+00'),
	('faa52f8d-0b63-4be0-8927-cb9e7764614e', 'ti', 'Bidrag till arbetsgivare som anställer personer med nedsatt arbetsförmåga.', 'ዝጐደለ ናይ ስራሕ ዓቕሚ ንዘለዎም ሰባት ንዝቖጽሩ ኣስራሕቲ ዝወሃብ ሓገዝ።', '2026-08-29 00:51:27.094571+00'),
	('a2e211de-0639-40ff-9baa-e24874aec6ed', 'ti', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'ተምሃራይ ካልኣይ ደረጃ ብሰንኪ ነዊሕ መገዲ ኣብ ቦታ ትምህርቲ ክቕመጥ ምስ ዝግደድ ንመንበርን ናብ ገዛ ንዝግበር ጕዕዞታትን ዝወሃብ ሓገዝ።', '2026-08-29 00:51:27.094571+00'),
	('5dcf0c64-0781-463b-91cc-2274c6699745', 'ti', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'ባህላዊ ውርሻ ንምዕቃብ፣ ንምጥቃምን ንምምዕባልን ንዝሰርሓ ዘይመኽሰባውያን ውድባት ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('9a98dacd-91d7-46d2-8656-f7a78e005238', 'ti', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'ንምምሕዳራዊን ከባብያዊን ፕሮጀክትታት ሓለዋ ተፈጥሮ፣ ማይ-ዘለዎም ቦታታትን ንደገ ዝግበር ምዝንጋዕን ሓዊሱ ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('9df3e5a0-f321-4993-b50e-515f16b2b055', 'ti', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'ንህዝባዊን ናይ ቤት-ትምህርትን ኣብያተ-መጻሕፍቲ መጻሕፍቲ ንምዕዳግ ንምምሕዳራት ከተማ ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('ab6a32c3-a8d7-4cbf-9d54-66a8a872f895', 'ti', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'ተምሃሮ መባእታ ምስ ሞያዊ ባህሊ ንኽራኸቡ ንሓለፍቲ ኣብያተ-ትምህርቲ ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('fb125dab-26e0-4156-be04-4b61391e9009', 'ti', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'ውሉድካ ዘድልዮ ግን ቁጠባ ስድራ ዘይኣኽሎ ነገራት ዝወሃብ ሓገዝ፦ ናይ ትርፊ ግዜ ንጥፈታት፣ ክዳውንቲ፣ ናይ ቤት-ትምህርቲ ዙረታት፣ መነጽር፣ ናይ ዕረፍቲ ንጥፈታትን ካልእን።', '2026-08-29 00:51:27.094571+00'),
	('0c520ff8-9561-4d4f-baac-02d3478aa34c', 'ti', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'ካብ Världens Barn፣ Musikhjälpen ከምኡውን Victoriafonden ዝኣመሰሉ ፈንድታት ዝወሃቡ ሓገዛት — 90-konto ዘለወን ሽወደናውያን ዘይመኽሰባውያን ውድባት ይሓትታኦም።', '2026-08-29 00:51:27.094571+00'),
	('8dacc04b-de08-4500-9815-17b5fc2190fb', 'ti', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'ነቲ ከባቢ ዘማዕብሉ ፕሮጀክትታት ካብ ገንዘብ ሓይሊ ማይን ንፋስን ዝወሃቡ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('1fb9968b-15bd-4ab3-9211-ee3a4f6de28d', 'ti', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'ሓጺር ትምህርቲ ንዘለዎም ስራሕ-ኣልቦ 25–60 ዓመት ኣብ ደረጃ መባእታ ወይ ካልኣይ ደረጃ ክመሃሩ ዘድልዮም ብዘይ ልቓሕ ዝወሃብ ሓገዝ።', '2026-08-29 00:51:27.094571+00'),
	('51d219ce-4aaa-46cd-adaf-839585a87dc2', 'ti', 'Bidrar projektet till energiomställningen?', 'እቲ ፕሮጀክት ኣብ ምስግጋር ጸዓት ኣበርክቶ ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('b95de24e-d2ff-43b4-994d-2c713d87ac8c', 'ti', 'Bor du och barnets andra förälder på skilda håll?', 'ንስኻን እቲ ካልእ ወላዲ እቲ ቆልዓን ተፈላሊኹም ዲኹም ትነብሩ?', '2026-08-29 00:51:27.094571+00'),
	('b1a15310-bdd8-40a6-bf95-b0c8e53f2d56', 'ti', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'ንንኣሽቱ ትካላት ኣብ ኣህጉራውነት ወይ ዲጂታላዊ ምቕያር ናይ ወጻኢ ክእለት ንምእታው ዝወሃቡ ቸካት።', '2026-08-29 00:51:27.094571+00');
INSERT INTO public.kb_translations VALUES
	('cdc890bb-c161-41a8-b67c-0c3da53a5226', 'ti', 'Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?', 'ኣብ Arbetsförmedlingen ኣብ ዝካየድ መደብ ትሳተፍ ዲኻ (ንኣብነት jobb- och utvecklingsgarantin)?', '2026-08-29 00:51:27.094571+00'),
	('28464aae-2626-490b-8c35-20c72106de33', 'ti', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'ብሉጽ ስነ-ጽሑፍ ንዘሕትሙ ኣሕተምቲ ድሕሪ ሕትመት ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('aa9f5dd6-fdc1-46fc-be15-89dad9a5addd', 'ti', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'ምስ ዑቕባ ዝተኣሳሰር ናይ መንበሪ ፍቓድ ዘለዎም እሞ ብወለንታ ናብ ሃገሮም ንሓዋሩ ክምለሱ ዝደልዩ ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('9a441b01-73c1-451c-9c0e-b1099df13434', 'ti', 'Kommer projektet människor i ert närområde till del?', 'እቲ ፕሮጀክት ንህዝቢ ከባቢኹም ይጠቅም ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('b3d95079-4a51-4a6c-bc65-5d50d103db5a', 'ti', 'Ekonomiskt stöd till arbetsgivare som anställer någon som varit borta länge från arbetslivet.', 'ካብ ናብራ ስራሕ ንነዊሕ ግዜ ርሒቑ ንዝጸንሐ ሰብ ንዝቖጽሩ ኣስራሕቲ ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('484228c9-8c85-48ca-9e9c-b19b4f70666c', 'ti', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'ናይ ገዛእ ርእሶም ትካል ንዝጅምሩ ደለይቲ ስራሕ ኣብ እዋን ምጅማር ዝወሃብ ቁጠባዊ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('257e56e2-987b-41fd-a27a-568ff9bf975a', 'ti', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Energimyndigheten ኣብ ምርምር ጸዓት፣ ምህዞን ብቕዓት ጸዓትን ቀጻሊ ጻውዒታት ትኸፍት።', '2026-08-29 00:51:27.094571+00'),
	('c1e6bac0-d64c-4fc1-afb7-2ea2f629c460', 'ti', 'Ersättning för att vara ledig från arbete eller studier för att ta hand om barn.', 'ንምክንኻን ቆልዓ ካብ ስራሕ ወይ ትምህርቲ ንምቁጣብ ዝወሃብ ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('913e1dfc-1e6c-4a73-b13f-c8e57c530f75', 'ti', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'ኣብ ሽወደን ሓድሽ ኮይኑ ኣብ ናይ Arbetsförmedlingen መደብ ምስፋር ንዝሳተፍ ዝወሃብ ክፍሊት፤ Försäkringskassan እያ ትኸፍሎ።', '2026-08-29 00:51:27.094571+00'),
	('fa2dd409-e2aa-4e84-98c2-28478894c139', 'ti', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'ውሉድ ዘይብሎም ትሑት ኣታዊ ዘለዎም መንእሰያት ክፋል ወጻኢታት መንበሪ ዝሽፍን ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('0a5b9f3d-1ccb-490e-b6f9-2d2b98101738', 'ti', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'ቀዋሚ ስንክልና ዘምጽኦም ተወሰኽቲ ወጻኢታት ዝሽፍን ክፍሊት — ንዓበይቲ፣ ወይ ንወለዲ ስንክልና ዘለዎም ቆልዑ።', '2026-08-29 00:51:27.094571+00'),
	('92a654e2-ea20-4632-8521-2401605e1e46', 'ti', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'ብሰንኪ ሕማም ወይ ስንክልና እንተ ወሓደ ንሓደ ዓመት ምሉእ ግዜ ክሰርሑ ዘይክእሉ መንእሰያት (19–29 ዓመት) ዝወሃብ ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('803766b6-6480-4b74-b20e-352a50be7fe4', 'ti', 'Ersättning när arbetsförmågan är stadigvarande nedsatt — det som tidigare kallades förtidspension.', 'ናይ ስራሕ ዓቕሚ ብቐዋሚ ምስ ዝጐድል ዝወሃብ ክፍሊት — ቅድም förtidspension (ናይ ኣቐዲሙ ጡረታ) ዝበሃል ዝነበረ።', '2026-08-29 00:51:27.094571+00'),
	('3a259bc8-0534-42dd-814d-44d246da58d6', 'ti', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'ብጽኑዕ ዝሓመመ ቀረባ ሰብ ኣብ ጐድኑ ንምህላው ካብ ስራሕ ምስ እትቑጠብ ዝወሃብ ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('7111ebc8-98e1-4d42-9960-826deb22fc26', 'ti', 'Ersättning när du deltar i ett arbetsmarknadspolitiskt program hos Arbetsförmedlingen.', 'ኣብ ናይ Arbetsförmedlingen ናይ ዕዳጋ ስራሕ መደብ ምስ እትሳተፍ ዝወሃብ ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('3790b112-bc79-4eb3-8446-5349e1e95a98', 'ti', 'Ersättning när du inte kan arbeta som vanligt på grund av sjukdom.', 'ብሰንኪ ሕማም ከም ልማድ ክትሰርሕ ምስ ዘይትኽእል ዝወሃብ ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('775dfaea-afda-46ca-bd6e-0859ebc3530e', 'ti', 'Ersättning när du stannar hemma från arbetet för att ta hand om ett sjukt barn.', 'ሕሙም ቆልዓ ንምክንኻን ካብ ስራሕ ኣብ ገዛ ምስ እትተርፍ ዝወሃብ ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('babd5ec8-ecaf-403a-b339-bf208280d580', 'ti', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'ቆልዑ ዘለዎምን ትሑት ኣታዊ ዘለዎምን ስድራቤታት ክፋል ወጻኢታት መንበሪ ዝሽፍን ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('b0a13c0f-ed24-4969-9d88-2528b551ee6d', 'ti', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'ደቆም ብሰንኪ ስንክልና ካብ መዛኖኦም ንላዕሊ ክንክንን ቁጽጽርን ንዘድልዮም ወለዲ ዝወሃብ ክፍሊት።', '2026-08-29 00:51:27.094571+00'),
	('ac0eeb65-8a70-4c84-b256-3782cd83e9b6', 'ti', 'Ersättning vid arbetslöshet — inkomstbaserad för medlemmar, grundbelopp för övriga.', 'ኣብ እዋን ስራሕ-ኣልቦነት ዝወሃብ ክፍሊት — ንኣባላት ኣብ ኣታዊ ዝተመስረተ፣ ንኻልኦት መሰረታዊ መጠን።', '2026-08-29 00:51:27.094571+00'),
	('c0ea160b-9ba3-4aac-8937-1db6caa61f12', 'ti', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'ኣስታት ሓምሳ ናይ ዕቋር ባንክታት ትካላት ኣብ ስፖርት፣ ባህሊ፣ ትምህርትን ማሕበራዊ ምዕባለን ንዝካየዱ ከባብያውያን ፕሮጀክትታት ሓገዛት ይህባ — ኣብ ናይቲ ባንክ ናይ ስራሕ ከባቢ።', '2026-08-29 00:51:27.094571+00'),
	('e924103b-2d89-4dbe-9951-b4e97e100bd7', 'ti', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'ብ EU ዝምወል ናይ ፕሮጀክት ደገፍ ኣብ ከባቢኻ ዘሎ ናይ Leader ዞባ ዝሕተት — ንማሕበራት፣ ትካላትን ምምሕዳራት ከተማን ገጠር ዘማዕብላ።', '2026-08-29 00:51:27.094571+00'),
	('f329f7ba-09d8-4304-884e-401ec5056695', 'ti', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'ኣብ ካልእ ሃገር EU/EES ስራሕ ንዝሕዙ ደለይቲ ስራሕ ብ EU ዝምወል ደገፍ፦ ናይ ቃለ-መሕትት ጕዕዞ፣ ወጻኢታት ምግዓዝን ትምህርቲ ቋንቋን ዝሽፍን።', '2026-08-29 00:51:27.094571+00'),
	('9d6a6c08-5a68-44b0-9f7b-58ae0a8ba7c9', 'ti', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'ክእለት፣ ምስግጋርን ኣብ ዕዳጋ ስራሕ ምስታፍን ንዘደልድሉ ፕሮጀክትታት ካብ ማሕበራዊ ፈንድ EU ዝወሃብ ገንዘብ።', '2026-08-29 00:51:27.094571+00'),
	('575f05b9-16d7-46cc-94a0-9bfad9c77416', 'ti', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'ንጕጅለኣዊ ምልውዋጣት መንእሰያት 13–30 ዓመት፣ ብዘይ መዓልታት ጕዕዞ 5–21 መዓልታት ዝጸንሕ ናይ EU ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('0aec937a-0046-4cca-a344-4836379dbb73', 'ti', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'ባህላውያን ውድባት ምስ መሻርኽቲ ኣብ ብዙሓት ሃገራት ኤውሮጳ ንዘካይድኦም ፕሮጀክትታት ምትሕብባር ዝወሃብ ናይ EU ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('7649ccaa-6461-462d-a505-1beaea5b826f', 'ti', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'መንእሰያት ወለንተኛታት 18–30 ዓመት ንዝቕበላ ወይ ንዝልእኻ ውድባት ዝወሃብ ናይ EU ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('7434ba21-5530-4304-936b-9b0970ab79a3', 'ti', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'ኣብ ቤት-ትምህርትን ትምህርቲ ዓበይትን ንምንቅስቓስ ሰራሕተኛታትን ተምሃሮን ዝወሃብ ናይ EU ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('08e96c56-8e3f-4b18-8bd6-fb6b9809a2c8', 'ti', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'ንንኣሽቱ ውድባት ናይ መጀመርታ ኤውሮጳዊ ፕሮጀክትታት ምትሕብባር ብቑርጺ መጠን ዝወሃብ ናይ EU ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('04ff6201-d65f-46fc-af10-854e475cc8fb', 'ti', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'ኣህጉራዊ ተኽእሎ ዘለዎም ሓደስቲ ፍርያት ወይ ኣገልግሎታት ንዘማዕብላ መንእሰያት ትካላት ዝወሃብ ምወላ።', '2026-08-29 00:51:27.094571+00'),
	('46d52999-c7ad-4138-a552-bcb8a411e906', 'ti', 'Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?', 'ኣብቲ ንጥፈትኩም እትገብሩሉ ቦታ ናይ ዕቋር ባንክ (ስለዚ ድማ ትካል ዕቋር ባንክ) ኣሎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('367b83c5-4c9b-443c-b8b3-f88c77a14d7e', 'ti', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'ኣብ ሳዕስዒት፣ ትያትርን ሙዚቃዊ ትያትርን ንዝነጥፋ ሞያውያን ናጻ ጕጅለታት ናይ ብዙሕ ዓመታት ናይ ስራሕ ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('2a9383ce-182d-427b-8a55-aa2828636136', 'ti', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'ኣብ ናይ Forte ዓውድታት ዝወሃቡ ናይ ምርምር ሓገዛት፦ ጥዕና፣ ናብራ ስራሕን ድሕነትን። ኣብ ሽወደናውያን ላዕለዎት ትካላት ትምህርቲ ዶክትረይት ዘለዎም ተመራመርቲ ይሓትዎም።', '2026-08-29 00:51:27.094571+00'),
	('f6ddefd5-46c8-4dd2-b6b0-a4190914dc69', 'ti', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'ኣብ ኩሎም ዓውድታት ስነ-ፍልጠት ንናጻ መሰረታዊ ምርምር ዝወሃብ ናይ ምርምር ገንዘብ።', '2026-08-29 00:51:27.094571+00'),
	('536c282f-4249-415c-ab2c-31ff7fb45398', 'ti', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'ኣብ ከባቢ፣ ሕርሻዊ ስነ-ፍልጠታትን ህንጸት ከተማን ዝወሃብ ናይ ምርምር ገንዘብ።', '2026-08-29 00:51:27.094571+00'),
	('0ab41d3f-6e97-4989-9825-dc7d776680b2', 'ti', 'Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?', 'ናብ ወጻኢ ክትግዕዝ ትሓስብ ዲኻ (ንስራሕ፣ ንትምህርቲ ወይ ንምምላስ ናብ ዓዲ)?', '2026-08-29 00:51:27.094571+00'),
	('7040b7f1-5081-4306-93d7-291d0c65a3e3', 'ti', 'Genomförs insatserna av professionella kulturaktörer?', 'እቶም ንጥፈታት ብሞያውያን ባህላውያን ተዋሳእቲ ድዮም ዝፍጸሙ?', '2026-08-29 00:51:27.094571+00'),
	('0bc90c87-35a9-429a-aa0b-19e71b03a4a6', 'ti', 'Genomförs projektet på landsbygden eller i en mindre tätort?', 'እቲ ፕሮጀክት ኣብ ገጠር ወይ ኣብ ንእሽቶ ከተማ ድዩ ዝካየድ?', '2026-08-29 00:51:27.094571+00'),
	('fdec136f-0178-4462-b4b3-f2c905e1855b', 'ti', 'Grundskydd för den som haft låg eller ingen arbetsinkomst under livet.', 'ኣብ ህይወቶም ትሑት ወይ ዜብሉ ናይ ስራሕ ኣታዊ ንዝነበሮም መሰረታዊ ውሕስነት።', '2026-08-29 00:51:27.094571+00'),
	('daca0274-ec90-4f8b-bc35-80530ca0b78f', 'ti', 'Går något av dina barn i grundskolan?', 'ካብ ደቅኻ ኣብ መባእታ ቤት-ትምህርቲ ዝመሃር ኣሎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('6db35278-1bb0-4f8b-bdf9-492bcebedb8d', 'ti', 'Går något av dina barn på gymnasiet?', 'ካብ ደቅኻ ኣብ ካልኣይ ደረጃ ዝመሃር ኣሎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('a2394621-6ac0-4459-9d94-0390e8c80383', 'ti', 'Gäller anställningen en person med nedsatt arbetsförmåga?', 'እቲ ቁጻር ንዝጐደለ ናይ ስራሕ ዓቕሚ ዘለዎ ሰብ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('d3cc05b0-d04c-40ed-9c71-8f351b56f178', 'ti', 'Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?', 'እቲ ቁጻር ንነዊሕ ግዜ ስራሕ-ኣልቦ ንዝነበረ ወይ ኣብ ሽወደን ሓድሽ ንዝኾነ ሰብ ድዩ ዝምልከት?', '2026-08-29 00:51:27.094571+00'),
	('3a3d505f-0e22-410f-b749-f3dbfe6519a8', 'ti', 'Handlar projektet om att bevara eller tillgängliggöra kulturarv?', 'እቲ ፕሮጀክት ብዛዕባ ምዕቃብ ወይ ምብጻሕ ባህላዊ ውርሻ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('1de75553-569f-4c86-b3a8-e05de5d7cbc6', 'ti', 'Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?', 'እቲ ፕሮጀክት ብዛዕባ ጸዓት፣ ብቕዓት ጸዓት ወይ ምስ ጸዓት ዝተኣሳሰር ምህዞ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('7bacd0f5-ac20-4517-bc5f-99d40128a890', 'ti', 'Handlar projektet om hälsa, arbetsliv eller välfärd?', 'እቲ ፕሮጀክት ብዛዕባ ጥዕና፣ ናብራ ስራሕ ወይ ድሕነት ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('31486aec-7ede-413b-9c43-7252b58d7fbe', 'ti', 'Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?', 'እቲ ፕሮጀክት ብዛዕባ ምምዕባል ክእለት ወይ ስጉምትታት ዕዳጋ ስራሕ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('a03838fc-4173-4c39-95db-70ae42ebac7b', 'ti', 'Handlar projektet om miljö- eller klimatåtgärder?', 'እቲ ፕሮጀክት ብዛዕባ ከባብያዊ ወይ ክሊማዊ ስጉምትታት ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('6cb0abe0-d67a-46a4-be6c-a80950c0956a', 'ti', 'Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?', 'እቲ ቆልዓ ናብ ቤት-ትምህርቲ ነዊሕ፣ ብትራፊክ ሓደገኛ ወይ ብኻልእ መገዲ ኣጸጋሚ መገዲ ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('a309a4d2-4b65-4511-8044-39c80cdb8316', 'ti', 'Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?', 'እንተ ወሓደ 16 ሰዓታት ኣብ ሰሙን፣ ብድምር እንተ ወሓደ 8 ዓመታት ሰሪሕካ ዲኻ?', '2026-08-29 00:51:27.094571+00');
INSERT INTO public.kb_translations VALUES
	('3d8f4d8d-5c0a-45c4-a4bc-84e402ae45f4', 'ti', 'Har du barn som bor hos dig, helt eller växelvis?', 'ምሳኻ ዝነብሩ ቆልዑ ኣለዉኻ ድዮም፣ ምሉእ ብምሉእ ወይ ብተመላላሲ?', '2026-08-29 00:51:27.094571+00'),
	('b8e92968-d458-4e44-a99a-b87c1c5f4e18', 'ti', 'Har du barn som bor hos dig?', 'ምሳኻ ዝነብሩ ቆልዑ ኣለዉኻ ድዮም?', '2026-08-29 00:51:27.094571+00'),
	('7d9336b2-b270-49b0-8817-4eed8fd34399', 'ti', 'Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?', 'ንስኻ ወይ ውሉድካ እንተ ወሓደ ሓደ ዓመት ክጸንሕ ትጽቢት ዝግበረሉ ስንክልና ኣለኩም ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('355eebb6-8a88-4a86-8854-c39c7ce370bf', 'ti', 'Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?', 'ንስኻ ወይ ሓደ ካብ ስድራቤት ኣብ መንበሪ ጽልዋ ዘለዎ ቀዋሚ ስንክልና ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('8d9bd301-2abf-4c43-9b31-7d5477568104', 'ti', 'Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?', 'ንስኻ ወይ ቀረባ ዘመድ ስንክልና ወይ ነዊሕ ዝጸንሐ ወይ ከቢድ ሕማም ኣለኩም ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('fe4b0d45-bdd6-4ebd-8c4e-dde84d8968f8', 'ti', 'Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?', 'ሕጂ ናይ ስራሕ ዓቕምኻ ዘጕድል ሕማም ወይ ጉድኣት ኣለካ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('a28582fe-130d-41fe-8f69-e00542d855cd', 'ti', 'Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?', 'ውሉድካ ክሳተፎ ትጽቢት ዝግበረሉ ናይ ቤት-ትምህርቲ ዙረት፣ ናይ ክፍሊ ጕዕዞ ወይ ናይ ትርፊ ግዜ ንጥፈት ንምኽፋል ተጸጊምካ ትፈልጥ ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('4aaa0e66-d33b-4f8b-9512-eb15667b752d', 'ti', 'Har du svårt att klara dig på din pension och dina övriga inkomster?', 'ብጡረታኻን ካልእ ኣታዊኻን ምንባር የጸግመካ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('ccec65f9-859b-49c9-9f05-401d89b02715', 'ti', 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?', 'ኣብ ዝሓለፉ ዓመታት ኣብ ሽወደን ናይ መንበሪ ፍቓድ ረኺብካ ዲኻ፣ ንኣብነት ከም ዑቕባ ዘድልዮ ወይ ከም ኣባል ስድራ?', '2026-08-29 00:51:27.094571+00'),
	('aa5b9ea5-22e9-43f0-b978-53dd59d20fc9', 'ti', 'Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?', 'ከም ስደተኛ ወይ ዑቕባ ዘድልዮ ሰብ ኣብ ሽወደን ናይ መንበሪ ፍቓድ ኣለካ ድዩ (ወይ ከምኡ ዘለዎ ሰብ ቀረባ ዘመድ ዲኻ)?', '2026-08-29 00:51:27.094571+00'),
	('210f70cd-f585-453b-b9c8-9f2535072611', 'ti', 'Har du uppnått riktåldern för pension (67 år 2026)?', 'ናይ ጡረታ መወከሲ ዕድመ (67 ዓመት ኣብ 2026) በጺሕካ ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('a979f5ce-296c-4784-88fe-8fbd20ff5354', 'ti', 'Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?', 'ውድብኩም ኣብ ናይ EU Organisation Registration System ዝተመዝገበ OID (Organisation ID) ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('b6010a34-84f9-441f-9fc3-22573a11f21d', 'ti', 'Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?', 'እቲ ስንክልና ተወሰኽቲ ወጻኢታት ኣምጺኡ ድዩ — ንኣብነት መሳርሒታት፣ ጕዕዞታት፣ ፍሉይ መግቢ ወይ ምብልሻው?', '2026-08-29 00:51:27.094571+00'),
	('9b4cbfe6-d242-4e6e-9385-777eb188fa9c', 'ti', 'Har föreningen antagna stadgar och en vald styrelse?', 'እቲ ማሕበር ዝጸደቐ ሕገ-ደንብን ዝተመርጸ ኣመራርሓን ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('db50c72d-a2ac-4d08-bdb3-d9567ae79280', 'ti', 'Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?', 'እቲ ማሕበር ዲሞክራስያዊ ኣቃውማ ኣለዎ ድዩ (ሕገ-ደንቢ፣ ዓመታዊ ኣኼባ፣ ኣመራርሓ)?', '2026-08-29 00:51:27.094571+00'),
	('d221250d-8807-4fd1-ac17-6915cfebd816', 'ti', 'Har föreningen regelbunden verksamhet för barn eller unga?', 'እቲ ማሕበር ንቆልዑ ወይ መንእሰያት ስሩዕ ንጥፈታት ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('5a384d42-efc5-475f-8e5b-6f87226514ba', 'ti', 'Har företaget mellan cirka 2 och 49 anställda?', 'እታ ትካል ኣስታት ካብ 2 ክሳብ 49 ሰራሕተኛታት ኣለዉዋ ድዮም?', '2026-08-29 00:51:27.094571+00'),
	('d1e2c537-9a6e-4cce-b784-2ade6d6bbce3', 'ti', 'Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?', 'እታ ስድራቤት ወጻኢታት መግቢ፣ መንበርን እቲ ኣዝዩ ኣድላዪን ንምሽፋን ትጽገም ድያ?', '2026-08-29 00:51:27.094571+00'),
	('945f2030-9c9c-4501-8835-8ac613f3c449', 'ti', 'Har lösningen internationell potential?', 'እቲ ፍታሕ ኣህጉራዊ ተኽእሎ ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('79e82e48-764a-40b0-9958-c13cf9021c32', 'ti', 'Har ni en partnergrupp i ett annat land?', 'ኣብ ካልእ ሃገር መሻርኽቲ ጕጅለ ኣለኩም ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('63d1baa3-6853-4892-ab10-30e4f9de8d24', 'ti', 'Har ni en partnerorganisation i ett annat europeiskt land?', 'ኣብ ካልእ ሃገር ኤውሮጳ መሻርኽቲ ውድብ ኣለኩም ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('adaa69c0-6086-4804-929f-9aaa8a91f9b6', 'ti', 'Har ni partner i minst tre olika europeiska länder?', 'እንተ ወሓደ ኣብ ሰለስተ ዝተፈላለያ ሃገራት ኤውሮጳ መሻርኽቲ ኣለዉኹም ድዮም?', '2026-08-29 00:51:27.094571+00'),
	('f5b055dc-a51e-493f-bedd-14c6abb63dde', 'ti', 'Har ni säte eller huvudsaklig verksamhet i den region där ni söker?', 'መቐመጢኹም ወይ ቀንዲ ንጥፈትኩም ኣብቲ እትሓቱሉ ዞባ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('0056b4b6-bc1c-4a7a-ae4f-c4c18a37abb6', 'ti', 'Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?', 'ካብ ደቅኻ ብሰንኪ ስንክልና ካብ መዛኖኡ ንላዕሊ ክንክን ወይ ቁጽጽር ዘድልዮ ኣሎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('50ffa041-9c28-47d4-90be-21ff56dc8ba0', 'ti', 'Har organisationen en demokratisk uppbyggnad?', 'እቲ ውድብ ዲሞክራስያዊ ኣቃውማ ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('a3171ad8-49e7-479d-bd79-5ea55e2b2305', 'ti', 'Har organisationen en Quality Label (kvalitetsmärkning)?', 'እቲ ውድብ Quality Label (ምልክት ብቕዓት) ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('e57b93e8-22a0-4132-a7f5-19b0b443b9bb', 'ti', 'Har organisationen ett 90-konto?', 'እቲ ውድብ 90-konto ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('8cbd3e52-7540-4f69-9edc-31ef6a3e0ba6', 'ti', 'Har organisationen ett OID (Organisation ID)?', 'እቲ ውድብ OID (Organisation ID) ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('0f4d555b-d080-425c-a493-8d4c543a7833', 'ti', 'Har organisationen ett OID?', 'እቲ ውድብ OID ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('2302a275-9e60-4dd0-96d0-25e9e84fa374', 'ti', 'Har organisationen medlemsföreningar i flera län?', 'እቲ ውድብ ኣብ ብዙሓት ዞባታት ኣባላት ማሕበራት ኣለዉዎ ድዮም?', '2026-08-29 00:51:27.094571+00'),
	('9275d2f1-dd2e-447d-bd68-7f33c2261885', 'ti', 'Har organisationen ordnad ekonomi och demokratisk struktur?', 'እቲ ውድብ ስሩዕ ቁጠባን ዲሞክራስያዊ ኣቃውማን ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('d80b2338-a992-46c9-905a-917f5a2ee723', 'ti', 'Har projektet en partner i ett annat land?', 'እቲ ፕሮጀክት ኣብ ካልእ ሃገር መሻርኽቲ ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('9468f210-dc58-4965-97ff-c2ce01aeab5f', 'ti', 'Har projektledaren doktorsexamen?', 'እቲ መራሒ ፕሮጀክት ዶክትረይት ኣለዎ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('1320f02a-8f69-4463-bd0e-87ab61fe3884', 'ti', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'እቲ መገዲ እንተ ወሓደ ሽዱሽተ ኪሎሜተር ምስ ዝኸውን፣ ምምሕዳር ከተማኻ ኣብ መንጎ ገዛን ካልኣይ ደረጃ ቤት-ትምህርትን ዕለታዊ ጕዕዞ ከቕርብ ኣለዎ (ንኣብነት ናይ ኣውቶቡስ ካርድ)።', '2026-08-29 00:51:27.094571+00'),
	('307676fc-cc24-45b3-a84a-f9c13387563e', 'ti', 'Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?', 'ኣብ ሽወደን ናይ መጀመርታ ናይ ገዛእ ርእስኻ ገዛ ትረክብ ወይ ተዳሉ ኣለኻ ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('b88173fd-199c-4441-a0fd-885e43ec1f12', 'ti', 'Innehåller projektet en internationell resa eller ett internationellt utbyte?', 'እቲ ፕሮጀክት ኣህጉራዊ ጕዕዞ ወይ ምልውዋጥ የጠቓልል ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('7422b43a-4bb9-4d55-aa1f-26c142be4e03', 'ti', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'ኣብ ናይ ደገፍ ዞባታት ንዘለዋ ትካላት ንህንጻታት፣ ማሽናትን ስልጠናን ዝወሃብ ናይ ወፍሪ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('4472e9e8-9c58-4422-b669-fbab47841cbf', 'ti', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'ልቀት ጋዛት ግሪንሃውስ ንዘጕድሉ ስጉምትታት ዝወሃብ ናይ ወፍሪ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('57e6de02-3a9f-434d-aaf0-8af527684b25', 'ti', 'Kan projektets miljönytta mätas?', 'ከባብያዊ ጥቕሚ እቲ ፕሮጀክት ክዕቀን ይከኣል ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('fc083d63-461e-4ae2-8c2f-dc6e44698e1e', 'ti', 'Kan åtgärdens utsläppsminskning beräknas?', 'ምጕዳል ልቀት እቲ ስጉምቲ ክሕሰብ ይከኣል ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('8d1dc7b6-fd71-4bd6-829f-4d8932844e59', 'ti', 'Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?', 'እቲ ውድብ እቲ ደገፍ ክሳብ ዝኽፈል ወጻኢታት ክጻወር ይኽእል ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('c24c3894-4b46-4b39-b1b9-0e0df2d797dd', 'ti', 'Kommer erfarenheterna att användas i din verksamhet i Sverige?', 'እቲ ተመኩሮ ኣብ ንጥፈትካ ኣብ ሽወደን ክውዕል ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('071f086d-0820-40ef-b9f7-fa05ee7710a4', 'ti', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'ኣታዊ ነቲ ኣዝዩ ኣድላዪ ምስ ዘይኣክል ናይ ምምሕዳር ከተማ ናይ መወዳእታ ቁጠባዊ መከላኸሊ መርበብ።', '2026-08-29 00:51:27.094571+00'),
	('eede6594-db3a-4893-88f5-f4a8612bce01', 'ti', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'ናይ ምምሕዳራት ከተማ ናይ ገዛእ ርእሰን ደገፍ ንከባብያዊ ማሕበራት፦ ንነፍሲ ወከፍ ኣጋጣሚ ናይ ንጥፈት ደገፍ፣ ናይ ኣዳራሽ ሓገዝ፣ ናይ ምጅማር ሓገዝን ካልእን።', '2026-08-29 00:51:27.094571+00'),
	('f223d43e-3259-49bc-b96d-1e4e0903ba6b', 'ti', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'ኣብ ነዊሕ ርሕቀት፣ ሓደገኛ መገዲ ወይ ስንክልና ንተምሃሮ መባእታ ነጻ ናይ ቤት-ትምህርቲ መጓዓዝያ — ብሕጊ ትምህርቲ መሰል እዩ።', '2026-08-29 00:51:27.094571+00'),
	('938c455f-ac12-4ee8-b6f1-bbff11997f22', 'ti', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'ንቆልዑን መንእሰያትን ብሕጊ ዝተደንገገ ናይ መነጽር ወይ ሌንስ ሓገዝ፤ መጠናትን ኣገባባትን በብዞባ ይፈላለ — ደረጃ ዞባኻ ኣረጋግጽ።', '2026-08-29 00:51:27.094571+00'),
	('27bb6a38-de14-4e67-b06e-a6b60f577036', 'ti', 'Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?', 'እቲ ፕሮጀክት ብሓይሊ ማይ ወይ ንፋስ ኣብ ዝትንከፍ ከባቢ ድዩ ዘሎ?', '2026-08-29 00:51:27.094571+00'),
	('aa20c9b0-2345-41fd-a5f6-02f050d226e9', 'ti', 'Ligger projektet inom miljö, areella näringar eller samhällsbyggande?', 'እቲ ፕሮጀክት ኣብ ውሽጢ ከባቢ፣ ሕርሻዊ ስነ-ፍልጠታት ወይ ህንጸት ከተማ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('2d299996-8080-47ca-a9a2-fa41799dc302', 'ti', 'Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?', 'እቲ ናይ ንጥፈት ቦታ ኣብ ናይ ደገፍ ዞባ A ወይ B ድዩ (ዓበይቲ ክፋላት Norrland ውሽጣዊ Svealandን)?', '2026-08-29 00:51:27.094571+00'),
	('5cff236c-9594-475a-b7f4-7165a2ea4d69', 'ti', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'ኣብ ሽወደን ንመጀመርታ ገዛ እቲ ኣዝዩ ኣድላዪ ንምዕዳግ ዝወሃብ ልቓሕ — ኣቕሑ ገዛ፣ ናውቲ ገዛን ካልእ መሰረታዊ መሳርሕን።', '2026-08-29 00:51:27.094571+00');
INSERT INTO public.kb_translations VALUES
	('46caab65-3cbb-412d-b1ab-2859f94e5ca9', 'ti', 'Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?', 'እቲ ፕሮጀክት ናይ ኢንዱስትሪ ናይ መስርሕ ልቀታት የጕድል ድዩ ወይስ ኣሉታዊ ልቀታት ይፈጥር?', '2026-08-29 00:51:27.094571+00'),
	('cf52ebcb-e352-4149-9fd3-4a044293a18c', 'ti', 'Månatligt bidrag för barn som bor i Sverige, från födseln till 16 års ålder.', 'ካብ ልደት ክሳብ 16 ዓመት ኣብ ሽወደን ንዝነብሩ ቆልዑ ወርሓዊ ሓገዝ።', '2026-08-29 00:51:27.094571+00'),
	('e7b647fb-6c64-4164-8467-b8c551ce225c', 'ti', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket ኣብ ዓውዲ ከባቢ ንውድባት፣ ትካላት፣ ማሕበራት፣ ህዝባዊ ጽላትን ውልቀሰባትን ሓገዛት ትህብ።', '2026-08-29 00:51:27.094571+00'),
	('9b51a998-b17c-4581-9b49-8b8376be097a', 'ti', 'Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?', 'ብወለንታ ናብ ሃገርካ ንሓዋሩ ክትምለስ ትውጥን ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('362e28b9-c750-4fdd-9c9e-d231473bf167', 'ti', 'Planerar du att starta eget företag?', 'ናይ ገዛእ ርእስኻ ትካል ክትጅምር ትውጥን ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('91fddf33-104e-4ae0-aaf0-12f4fbe64472', 'ti', 'Planerar du att studera utomlands?', 'ኣብ ወጻኢ ክትመሃር ትውጥን ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('d9e39bdc-e122-4246-8f0f-b5133d0266ab', 'ti', 'Planerar du studier som stärker din ställning på arbetsmarknaden?', 'ኣብ ዕዳጋ ስራሕ ቦታኻ ዘደልድል ትምህርቲ ትውጥን ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('143927c9-2b96-48e4-b668-a3ae753d24b5', 'ti', 'Planerar ni att anställa?', 'ክትቆጽሩ ትውጥኑ ዲኹም?', '2026-08-29 00:51:27.094571+00'),
	('a955987f-efa8-4387-99f2-330e4ea2dab3', 'ti', 'Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?', 'ናይ EU መደብ (ንኣብነት Horisont Europa) ክትሓቱ ትውጥኑ ዲኹም?', '2026-08-29 00:51:27.094571+00'),
	('ee2e7807-0583-4c7e-963d-ec09f4a1d5da', 'ti', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'ንሓጸርቲ ፊልምታትን ዶኩመንታሪታትን ናይ ፍርያትን ምዕባለን ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('5bda2a62-0752-4713-a5e5-6101dfb49102', 'ti', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'ንናጻ ሙዚቃዊ ህይወት ንኮንሰርታት፣ ፍርያትን ምዕባለን ዝወሃቡ ናይ ፕሮጀክት ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('375bef77-fd1b-479c-9d04-9fa195cf3cfd', 'ti', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'ምስ ቆልዑን መንእሰያትን ንዓኦምን ንዝሰርሓ ዘይመኽሰባውያን ውድባት ዝወሃቡ ናይ ፕሮጀክት ሓገዛት።', '2026-08-29 00:51:27.094571+00'),
	('cb5814e7-07f9-408a-ae11-ebd51b457872', 'ti', 'Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?', 'እቲ ፕሮጀክት ሓደስቲ ስነ-ጥበባዊ መግለጺታት፣ ኣገባባት ወይ ምትሕብባራት ይፍትን ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('5ec8c6b3-6553-4fdc-bb44-c1616637dc68', 'ti', 'Pågår utbytet 5–21 dagar (exklusive resdagar)?', 'እቲ ምልውዋጥ 5–21 መዓልታት (ብዘይ መዓልታት ጕዕዞ) ይጸንሕ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('0ea734b9-0871-49f2-bc2b-bee1199ce719', 'ti', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'ኣብ ጐድኒ ናይ Kulturrådet ሃገራውያን ሓገዛት፣ ናይ ዞባታት ናይ ገዛእ ርእሰን ናይ ፕሮጀክትን ስራሕን ደገፍ ንባህላዊ ህይወት።', '2026-08-29 00:51:27.094571+00'),
	('31838d92-35f6-4c1a-b1c4-340483dbe6fd', 'ti', 'Riktar sig projektet till barn eller unga?', 'እቲ ፕሮጀክት ንቆልዑ ወይ መንእሰያት ድዩ ዝዓለመ?', '2026-08-29 00:51:27.094571+00'),
	('773a4d0f-5ac6-4202-8611-33131834bcda', 'ti', 'Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?', 'እቲ ፕሮጀክት ንቆልዑ፣ መንእሰያት፣ ኣረጋውያን ወይ ስንክልና ዘለዎም ሰባት ድዩ ዝዓለመ?', '2026-08-29 00:51:27.094571+00'),
	('7b93e212-99e0-485f-9b9e-0d4f7d14c880', 'ti', 'Riktar sig verksamheten till barn och unga (7–25 år)?', 'እቲ ንጥፈት ንቆልዑን መንእሰያትን (7–25 ዓመት) ድዩ ዝዓለመ?', '2026-08-29 00:51:27.094571+00'),
	('4c3cfc6e-0b4b-4c41-b371-9a073a6e39bf', 'ti', 'Saknar du sparpengar eller tillgångar som kan täcka utgifterna?', 'ነቶም ወጻኢታት ክሽፍኑ ዝኽእሉ ዕቋር ወይ ንብረት የብልካን ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('2f85dcdc-5b2e-4936-b121-9627d1b6cab0', 'ti', 'Samarbetar ni med partner i minst två andra nordiska länder?', 'እንተ ወሓደ ምስ ክልተ ካልኦት ሰሜናውያን ሃገራት መሻርኽቲ ትተሓባበሩ ዲኹም?', '2026-08-29 00:51:27.094571+00'),
	('174d46d4-8b3b-4e61-93f2-1fbcb556ebb9', 'ti', 'Ska ni ta in extern kompetens för en utvecklingsinsats?', 'ንናይ ምዕባለ ስጉምቲ ናይ ወጻኢ ክእለት ከተእትዉ ዲኹም?', '2026-08-29 00:51:27.094571+00'),
	('f69ca9fa-91a3-481e-88ae-8c46504f3873', 'ti', 'Sker mobiliteten till ett annat europeiskt land?', 'እቲ ምንቅስቓስ ናብ ካልእ ሃገር ኤውሮጳ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('47ffda2b-8f93-416f-b346-36ec673419ba', 'ti', 'Startar du eller tar du över företaget för första gången?', 'ንመጀመርታ ግዜ ዲኻ እታ ትካል ትጅምር ወይ ትርከብ ዘለኻ?', '2026-08-29 00:51:27.094571+00'),
	('87c67e1a-2b6d-49de-a5b2-b0673b740756', 'ti', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', '40 ዓመት ወይ ካብኡ ንታሕቲ ኮይኑ ሕርሻዊ ትካል ንዝጅምር ወይ ንዝርከብ ዝወሃብ ናይ ምጅማር ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('1c08dee9-3ec5-41e1-97a7-57c2ec4318ae', 'ti', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'ንሞያውያን ስነ-ጥበበኛታት ኣብ ስነ-ጥበባዊ ስራሖም ከተኵሩ ዘኽእል ስኮላርሺፕ።', '2026-08-29 00:51:27.094571+00'),
	('a7f3788a-6610-47ac-b70d-bcf91a42f952', 'ti', 'Studerar du, eller planerar du att börja studera?', 'ትመሃር ኣለኻ ዲኻ፣ ወይስ ትምህርቲ ክትጅምር ትውጥን?', '2026-08-29 00:51:27.094571+00'),
	('bf87592e-f7ad-4a4a-9961-e47f3872aa5f', 'ti', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'ኣብ ዕዳጋ ስራሕ ቦታኦም ንምድልዳል ክመሃሩ ንዝደልዩ ሰራሕተኛታት ዓበይቲ ዝወሃብ ናይ ትምህርቲ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('519139fd-7710-4dbe-bd4f-b6194052f4f0', 'ti', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'ኣብ ሕርሻውያን ትካላት ተወዳዳርነት ዘዕብዩ ወይ ከባብያዊ ጽልዋ ዘጕድሉ ወፍርታት ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('b6e27905-718d-4415-af5b-ca317103e40a', 'ti', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'ቆልዓ ምሳኻ ምስ ዝነብር እሞ እቲ ካልእ ወላዲ ቀለብ ምስ ዘይከፍል ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('089f1b80-fdf3-45d0-bf76-2a4689ed4736', 'ti', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'ንሰባት፣ ከባብን ዝሓሸ ዓለምን ንዝካየዱ ፕሮጀክትታት ዘይመኽሰባውያን ውድባት ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('8e633124-9a8f-47ad-9f48-19d2b80e8c46', 'ti', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'ናብ ዜሮ ልቀት ጋዛት ግሪንሃውስ ንዝግበር ምስግጋር ኢንዱስትሪ ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('19c461de-e9d1-4c62-beb6-6f4f7b9e95d1', 'ti', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'ሰሜናዊ መልክዕን ዶብ ሰጊሩ ዝግበር ምትሕብባርን ንዘለዎም ፕሮጀክትታት ስነ-ጥበብን ባህልን ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('394c9bb5-e356-417e-bedc-0893a3082073', 'ti', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'ሓደስቲ ስነ-ጥበባዊ መግለጺታት፣ ኣገባባት ወይ ምትሕብባራት ንዝፍትኑ ሓደስቲ ባህላውያን ፕሮጀክትታት ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('15c42e00-4670-48dd-ad44-97974c926317', 'ti', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'ንቆልዑ፣ መንእሰያት፣ ኣረጋውያንን ስንክልና ዘለዎም ሰባትን ንዝካየዱ ሓደስቲ ፕሮጀክትታት ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('3a1de34b-7094-4b0c-b024-cbd058f0032b', 'ti', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'ኣብ ናጻ ሙዚቃዊ ህይወት ንፕሮጀክትታት ምትሕብባር ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('2ce45c1d-703c-4f43-a5ce-1bf189a2c15b', 'ti', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'ዲሞክራስን ናጽነት ሓሳብን ብኣህጉራዊ ደረጃ ንዘደልድሉ ፕሮጀክትታት ምትሕብባር ኣብ ባህልን ሚድያን ዝወሃብ ደገፍ።', '2026-08-29 00:51:27.094571+00'),
	('3bbc4096-e3ec-4c79-9b41-5c12c2e4b26c', 'ti', 'Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?', 'እቲ ፕሮጀክት ዲሞክራሲ፣ ማዕርነት ወይ ናጽነት ሓሳብ ንምድልዳል ድዩ ዝዓለመ?', '2026-08-29 00:51:27.094571+00'),
	('3b46d971-5677-4419-9969-717fa0b694cc', 'ti', 'Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?', 'ኣብ ካልእ ሃገር EU ወይ EES ስራሕ ትደሊ ኣለኻ፣ ወይ ናይ ስራሕ ውዕል ተዋሂቡካ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('9633a6ed-dfcd-42a4-bc57-9bb4bf6451c4', 'ti', 'Tak för vad du behöver betala i patientavgifter under en tolvmånadersperiod — därefter frikort.', 'ኣብ ውሽጢ ዓሰርተ ክልተ ኣዋርሕ ብናይ ሕሙም ክፍሊታት እትኸፍሎ ጣርያ — ድሕሪኡ frikort (ነጻ ካርድ)።', '2026-08-29 00:51:27.094571+00'),
	('0d57b1a7-7fba-4b96-ad8c-d9793f326ab0', 'ti', 'Tar du ut hel allmän pension?', 'ምሉእ ሃገራዊ ጡረታኻ ትወስድ ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('2714ce59-8176-4052-8b40-80fbd85c45e8', 'ti', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'ጡረታን ትሑት ኣታውን ንዘለዎም ክፋል ወጻኢታት መንበሪ ዝሽፍን ተወሳኺ።', '2026-08-29 00:51:27.094571+00'),
	('149c2273-f13c-4a4e-b2d1-3acbbcd682a1', 'ti', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'ንሃገራውያን ውድባት ቆልዑን መንእሰያትን ዓመታዊ ናይ ውድብ ሓገዝ።', '2026-08-29 00:51:27.094571+00'),
	('1e6856c0-8737-4f8b-be48-de27ae0a4ca6', 'ti', 'Årligt tillgodohavande som dras av direkt hos tandläkaren eller tandhygienisten.', 'ኣብ ሓኪም ስኒ ወይ ክኢላ ጽሬት ስኒ ብቐጥታ ዝቕነስ ዓመታዊ ሕሳብ።', '2026-08-29 00:51:27.094571+00'),
	('9707fe00-1154-40a2-965e-de2ec89517cb', 'ti', 'Är bolaget yngre än cirka 5 år?', 'እታ ትካል ካብ ኣስታት 5 ዓመት ንታሕቲ ድያ?', '2026-08-29 00:51:27.094571+00'),
	('2218690a-0f86-48a6-a72a-5b4d0e96ec79', 'ti', 'Är deltagarna i utbytet mellan 13 och 30 år?', 'ተሳተፍቲ እቲ ምልውዋጥ ኣብ መንጎ 13ን 30ን ዓመት ድዮም?', '2026-08-29 00:51:27.094571+00'),
	('8ee95b5f-b180-4fe9-91b0-6ae05acbe733', 'ti', 'Är det här ert första EU-projekt?', 'እዚ ናይ መጀመርታ ናይ EU ፕሮጀክትኩም ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('900dcc0a-d6b6-4a62-b923-d6b55df07c18', 'ti', 'Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?', 'ንዓኻ (ወይ ንውሉድካ) በይንኻ ምንቅስቓስ ወይ ብኣውቶቡስን ባቡርን ምጕዓዝ ኣዝዩ ኣጸጋሚ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('74f563f0-c711-4624-9300-5551ce795df1', 'ti', 'Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'ኣታዊኻ ካብ ኣስታት 25 000 kr ኣብ ወርሒ ቅድሚ ግብሪ ዝወሓደ ድዩ?', '2026-08-29 00:51:27.094571+00'),
	('caf15b68-ff5f-459c-a544-8cc9b08afcd2', 'ti', 'Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?', 'ናይ መወዳእታ ዝወዳእካዮ ትምህርቲ መባእታ ድዩ፣ ወይስ ዘይወዳእካዮ ካልኣይ ደረጃ?', '2026-08-29 00:51:27.094571+00'),
	('02596c56-f285-4159-b02a-90a3e67d82dc', 'ti', 'Är du 40 år eller yngre?', '40 ዓመት ወይ ካብኡ ንታሕቲ ዲኻ?', '2026-08-29 00:51:27.094571+00');
INSERT INTO public.kb_translations VALUES
	('60be400f-a2bf-49b9-97a0-22a2af228852', 'ti', 'Är du inskriven som arbetssökande hos Arbetsförmedlingen?', 'ኣብ Arbetsförmedlingen ከም ደላዪ ስራሕ ተመዝጊብካ ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('7e08236f-6644-4b71-94ad-924e69f1bbaf', 'ti', 'Är du mellan 18 och 28 år?', 'ኣብ መንጎ 18ን 28ን ዓመት ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('2bcff3d5-cd0c-4c22-be68-a662fdf9de89', 'ti', 'Är du mellan 19 och 29 år?', 'ኣብ መንጎ 19ን 29ን ዓመት ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('4dcfb4c8-c011-4fbc-9bf2-123b6442a97d', 'ti', 'Är du mellan 25 och 60 år?', 'ኣብ መንጎ 25ን 60ን ዓመት ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('77d36cb2-625f-4219-a335-a10d81ca5bf2', 'ti', 'Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?', 'ኣብ ዓውዲ ባህሊ ብሞያ ትሰርሕ ዲኻ (ንኣብነት ሳዕስዒት፣ ሙዚቃ፣ ስነ-ጥበብ መድረኽ)?', '2026-08-29 00:51:27.094571+00'),
	('4ae63434-b16c-4dac-a6b5-f03182ece3cc', 'ti', 'Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?', 'ሞያዊ ስነ-ጥበበኛ ዲኻ (ዘይ ሃዋርያ ወይ ኣብ መሰረታዊ ስልጠና ዘሎ)?', '2026-08-29 00:51:27.094571+00'),
	('31d1e388-81f8-4e24-a045-27aeb66b4bab', 'ti', 'Är du yrkesverksam konstnär?', 'ሞያዊ ስነ-ጥበበኛ ዲኻ?', '2026-08-29 00:51:27.094571+00'),
	('04679bd6-beec-4e8d-80c6-1f4f4560bdd6', 'ti', 'Är er lösning väsentligt nyskapande jämfört med vad som redan finns?', 'ፍታሕኩም ምስቲ ድሮ ዘሎ ክወዳደር ከሎ ብመሰረቱ ሓድሽ ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('afecb33f-675f-443a-b3be-40b65a1ef032', 'ti', 'Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?', 'እቲ ክለብ ኣብ ውሽጢ Riksidrottsförbundet ናብ ፍሉይ ስፖርታዊ ፌደሬሽን ዝተጸምበረ ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('132a9d52-c0c6-4abe-b76f-8864c9c7dc7c', 'ti', 'Är hushållets inkomster låga i förhållande till boendekostnaden?', 'ኣታዊ እታ ስድራቤት ምስ ወጻኢታት መንበሪ ክወዳደር ከሎ ትሑት ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('3b7c854b-d9b3-4403-ba36-969f745749f9', 'ti', 'Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?', 'ጠቕላላ ኣታዊ እታ ስድራቤት ካብ ኣስታት 25 000 kr ኣብ ወርሒ ቅድሚ ግብሪ ዝወሓደ ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('d10a72aa-0908-4956-9599-aea1c1b4d61d', 'ti', 'Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?', 'እቲ ስጉምቲ ዝተወሰነ ፕሮጀክት ድዩ (ዘይ ስሩዕ ንጥፈት)?', '2026-08-29 00:51:27.098228+00'),
	('fd9dd653-9899-440a-b1d0-7c59a4e6269d', 'ti', 'Är lokalen öppen för alla — inte bara egna medlemmar?', 'እቲ ኣዳራሽ ንኹሉ ክፉት ድዩ — ዘይ ንኣባላትኩም ጥራይ?', '2026-08-29 00:51:27.098228+00'),
	('455362f7-5a0a-431d-8aaf-58f9b1448263', 'ti', 'Är minst 60 % av medlemmarna mellan 6 och 25 år?', 'እንተ ወሓደ 60 % ካብቶም ኣባላት ኣብ መንጎ 6ን 25ን ዓመት ድዮም?', '2026-08-29 00:51:27.098228+00'),
	('abd6277b-a2b3-4b3d-ab0e-b318bd3ca89b', 'ti', 'Är minst 60 % av medlemmarna under 26 år?', 'እንተ ወሓደ 60 % ካብቶም ኣባላት ትሕቲ 26 ዓመት ድዮም?', '2026-08-29 00:51:27.098228+00'),
	('6f46f148-2918-416b-b0f1-9672a78d26f1', 'ti', 'Är målgruppen delaktig i planering och genomförande?', 'እታ ዕላማ ዝኾነት ጕጅለ ኣብ ውጥንን ትግባረን ትሳተፍ ድያ?', '2026-08-29 00:51:27.098228+00'),
	('6d389940-e27f-46e0-938b-42e9421dada4', 'ti', 'Är ni ett förlag med professionell utgivning?', 'ሞያዊ ሕትመት ዘለዎ ኣሕታሚ ዲኹም?', '2026-08-29 00:51:27.098228+00'),
	('d1ea6499-83f5-4c05-95b9-5107745b99b6', 'ti', 'Är ni huvudman för förskoleklass eller grundskola?', 'ሓላፊ ናይ ቅድመ-ትምህርቲ ክፍሊ ወይ መባእታ ቤት-ትምህርቲ ዲኹም?', '2026-08-29 00:51:27.098228+00'),
	('6f97c21e-810e-4d29-bae9-8e45ffb93b3f', 'ti', 'Är organisationen registrerad i EU:s deltagarregister?', 'እቲ ውድብ ኣብ ናይ EU መዝገብ ተሳተፍቲ ተመዝጊቡ ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('55b8993c-69d4-47a4-a85e-37e62c6a082a', 'ti', 'Är projektet ett filmprojekt (kort- eller dokumentärfilm)?', 'እቲ ፕሮጀክት ናይ ፊልም ፕሮጀክት ድዩ (ሓጻር ፊልም ወይ ዶኩመንታሪ)?', '2026-08-29 00:51:27.098228+00'),
	('92d13128-0002-48dd-b45b-ed47839759ff', 'ti', 'Är projektet ett konst- eller kulturprojekt?', 'እቲ ፕሮጀክት ናይ ስነ-ጥበብ ወይ ባህሊ ፕሮጀክት ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('ddfbf96e-0b45-4f48-a9c8-a25b0f534e2e', 'ti', 'Är projektet ett kulturprojekt?', 'እቲ ፕሮጀክት ባህላዊ ፕሮጀክት ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('1a439058-4c9d-4186-b4d5-aa3920be21d1', 'ti', 'Är projektet ett musikprojekt?', 'እቲ ፕሮጀክት ሙዚቃዊ ፕሮጀክት ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('e9275c92-d0c6-4bf1-8309-2b28ec7e26a8', 'ti', 'Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?', 'እቲ ፕሮጀክት ሓድሽ ድዩ — ኣብ ስሩዕ ንጥፈትኩም ዘይትገብርዎ ነገር?', '2026-08-29 00:51:27.098228+00'),
	('01ace9cf-4416-46b9-8c63-21a1fdde1f1d', 'ti', 'Är projektet till nytta för bygden i stort (inte enskilda)?', 'እቲ ፕሮጀክት ንብምሉኡ እቲ ከባቢ ይጠቅም ድዩ (ዘይ ንውልቀሰባት)?', '2026-08-29 00:51:27.098228+00'),
	('28e62408-0ea9-4014-a5dc-48c24ab34991', 'ti', 'Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?', 'እቲ ኣብ መንጎ ገዛን ካልኣይ ደረጃ ቤት-ትምህርትን ዘሎ መገዲ እንተ ወሓደ ሽዱሽተ ኪሎሜተር ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('751656d3-ecea-4ece-a4e8-796c4d7b78c3', 'ti', 'Är verksamheten professionell (inte amatörverksamhet)?', 'እቲ ንጥፈት ሞያዊ ድዩ (ዘይ ናይ ሃዋርያ)?', '2026-08-29 00:51:27.098228+00'),
	('94181e07-f6ee-4961-bbf1-74035c15031a', 'ti', 'Är verksamheten professionell?', 'እቲ ንጥፈት ሞያዊ ድዩ?', '2026-08-29 00:51:27.098228+00'),
	('f5e13e60-9696-4197-9984-5b469a4e566b', 'ti', 'Är verksamheten scenkonst (dans, teater, musikteater)?', 'እቲ ንጥፈት ስነ-ጥበብ መድረኽ ድዩ (ሳዕስዒት፣ ትያትር፣ ሙዚቃዊ ትያትር)?', '2026-08-29 00:51:27.098228+00'),
	('04dc4f0f-dea9-4fef-b8fa-1a0fd1e2c0d3', 'ti', 'Är volontärerna mellan 18 och 30 år?', 'እቶም ወለንተኛታት ኣብ መንጎ 18ን 30ን ዓመት ድዮም?', '2026-08-29 00:51:27.098228+00');


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
	('85b4eb17-0b80-4948-8fa1-405663bf8419', 'a2a04941-b1d3-48a4-b48a-41a5af4bdce6', 1, '[{"id": "kr-rb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-rb-h2", "op": "in", "kind": "hard", "expected": ["individual", "association", "company"], "factPath": "applicant.type", "description": "Sökande ska vara yrkesverksam kulturskapare, grupp eller organisation"}, {"id": "kr-rb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam inom kulturområdet", "evidenceKinds": ["cv"], "intakeQuestion": "Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?"}, {"id": "kr-rb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska avse internationellt kulturutbyte", "evidenceKinds": ["invitation"], "intakeQuestion": "Innehåller projektet en internationell resa eller ett internationellt utbyte?"}, {"id": "kr-rb-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Kulturprojekt"}, {"id": "kr-rb-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}, {"id": "kr-rb-w3", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "project.bringsKnowledgeBack", "description": "Kunskapen tas tillvara i Sverige", "intakeQuestion": "Kommer erfarenheterna att användas i din verksamhet i Sverige?"}]', '[{"id": "kr-rb-b1", "type": "max_requested", "amountMinor": 5000000, "description": "Sökt belopp bör inte överstiga 50 000 kr för resebidrag."}]', '[{"id": "kr-rb-e1", "kind": "cv", "mandatory": true, "description": "CV eller konstnärlig meritförteckning"}, {"id": "kr-rb-e2", "kind": "invitation", "mandatory": true, "description": "Inbjudan eller bekräftelse från mottagande part"}, {"id": "kr-rb-e3", "kind": "budget", "mandatory": false, "description": "Resebudget"}]', '2026-08-29 00:51:26.447863+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.447863+00'),
	('23c8c995-89a7-45af-b6d4-027571862c59', 'd7b462a5-957d-4f97-83af-ab6a1be08eff', 1, '[{"id": "er-yx-h1", "op": "in", "kind": "hard", "expected": ["association", "informal_group", "municipality"], "factPath": "applicant.type", "description": "Sökande ska vara en organisation eller informell ungdomsgrupp"}, {"id": "er-yx-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska nationella programkontoret"}, {"id": "er-yx-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge13to30", "description": "Deltagarna ska vara 13–30 år", "intakeQuestion": "Är deltagarna i utbytet mellan 13 och 30 år?"}, {"id": "er-yx-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.durationDays5to21", "description": "Utbytet ska vara 5–21 dagar exklusive resdagar", "intakeQuestion": "Pågår utbytet 5–21 dagar (exklusive resdagar)?"}, {"id": "er-yx-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partnergrupp i ett annat programland krävs", "intakeQuestion": "Har ni en partnergrupp i ett annat land?"}, {"id": "er-yx-m4", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID (Organisation ID)", "intakeQuestion": "Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?"}, {"id": "er-yx-w1", "op": "includes", "kind": "weighted", "weight": 3, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}, {"id": "er-yx-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training"], "factPath": "project.activityTypes", "description": "Utbytes-/lärandeaktiviteter"}, {"id": "er-yx-w3", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "er-yx-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från partnergrupp(er)"}, {"id": "er-yx-e2", "kind": "activity_programme", "mandatory": true, "description": "Aktivitetsprogram dag för dag"}, {"id": "er-yx-e3", "kind": "budget", "mandatory": false, "description": "Budget enligt programmets schabloner"}]', '2026-08-29 00:51:26.455046+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.455046+00'),
	('1bdecff9-6fa5-4253-a27b-aad713891b53', '46124e71-ccb1-4ef3-a30a-62a27a09b19c', 1, '[{"id": "mucf-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara verksam i Sverige"}, {"id": "mucf-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska ha en demokratisk uppbyggnad", "intakeQuestion": "Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?"}, {"id": "mucf-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Projektet ska rikta sig till barn eller unga", "intakeQuestion": "Riktar sig projektet till barn eller unga?"}, {"id": "mucf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["youth", "civil_society", "culture"], "factPath": "project.sector", "description": "Verksamhet inom ungdoms-/civilsamhällesområdet"}, {"id": "mucf-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.youthMembersShareOver60", "description": "Hög andel unga medlemmar", "intakeQuestion": "Är minst 60 % av medlemmarna under 26 år?"}]', '[]', '[{"id": "mucf-e1", "kind": "stadgar", "mandatory": true, "description": "Föreningens stadgar"}, {"id": "mucf-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse och årsredovisning"}, {"id": "mucf-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-29 00:51:26.461003+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.461003+00'),
	('71208f98-7047-4d6b-ad50-d854cec840ff', '3ddfcab1-712c-405c-a3f9-cbc4f4623854', 1, '[{"id": "vin-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett aktiebolag"}, {"id": "vin-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "vin-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.ageYearsMax5", "description": "Bolaget ska vara ungt (typiskt max ca 5 år — se aktuell utlysning)", "intakeQuestion": "Är bolaget yngre än cirka 5 år?"}, {"id": "vin-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isInnovative", "description": "Lösningen ska vara nyskapande jämfört med befintliga alternativ", "intakeQuestion": "Är er lösning väsentligt nyskapande jämfört med vad som redan finns?"}, {"id": "vin-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.scalableInternationally", "description": "Internationell skalbarhet", "intakeQuestion": "Har lösningen internationell potential?"}, {"id": "vin-w2", "op": "in", "kind": "weighted", "weight": 1, "expected": ["innovation", "technology", "energy", "health"], "factPath": "project.sector", "description": "Prioriterade områden"}]', '[{"id": "vin-b1", "type": "max_requested", "amountMinor": 30000000, "description": "Maximalt bidrag enligt programmets ramar (se aktuell utlysning)."}]', '[{"id": "vin-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "vin-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}, {"id": "vin-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelpersoner"}]', '2026-08-29 00:51:26.468071+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.468071+00'),
	('39d6df56-7952-43e1-ac4b-0b23972bf32e', '852cb486-9e15-40f7-ad8b-42fd6257e13c', 1, '[{"id": "pm-afs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "pm-afs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-afs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Du ska ha uppnått riktåldern för pension (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}, {"id": "pm-afs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.veryLowOrNoPension", "description": "Pension och inkomster ska inte räcka till en skälig levnadsnivå", "intakeQuestion": "Har du svårt att klara dig på din pension och dina övriga inkomster?"}]', '[]', '[]', '2026-08-29 00:51:26.668729+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.668729+00'),
	('01cbadc8-2100-4322-b274-dc037c8e5598', 'bab6e91a-ef86-4ba5-974c-6ea98731ca33', 1, '[{"id": "em-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "em-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association", "economic_association"], "factPath": "applicant.type", "description": "Öppet för organisationer — inte privatpersoner"}, {"id": "em-m1", "op": "in", "kind": "mandatory", "expected": ["energy", "environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom energiområdet", "intakeQuestion": "Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?"}, {"id": "em-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.contributesToEnergyTransition", "description": "Bidrar till energiomställningen", "intakeQuestion": "Bidrar projektet till energiomställningen?"}]', '[]', '[{"id": "em-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "em-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget med kostnadskategorier"}]', '2026-08-29 00:51:26.474119+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.474119+00'),
	('02c509c1-78a4-4683-b4c0-6c8732c634e0', '611376c1-02ef-4bbc-9d59-8a7db9f647f1', 1, '[{"id": "nv-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "nv-m1", "op": "in", "kind": "mandatory", "expected": ["environment", "energy"], "factPath": "project.sector", "description": "Projektet ska avse miljö- eller klimatåtgärder", "intakeQuestion": "Handlar projektet om miljö- eller klimatåtgärder?"}, {"id": "nv-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.measurableEnvironmentalImpact", "description": "Mätbar miljönytta", "intakeQuestion": "Kan projektets miljönytta mätas?"}]', '[{"id": "nv-b1", "type": "max_funding_share", "percent": 50, "description": "Många av bidragen täcker upp till 50 % av kostnaden — se aktuellt bidrag."}]', '[{"id": "nv-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av åtgärden"}]', '2026-08-29 00:51:26.481189+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.481189+00'),
	('cce4014d-df93-431d-8624-7ba25a61d347', '68eba158-7604-4223-8549-8072e45d0369', 1, '[{"id": "kr-pm-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-pm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell verksamhet inom musikområdet", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-pm-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kr-pm-w1", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["performance", "production"], "factPath": "project.activityTypes", "description": "Konsert-/produktionsverksamhet"}]', '[]', '[{"id": "kr-pm-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kr-pm-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-29 00:51:26.488136+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.488136+00'),
	('9035e376-59c7-43ba-9cf4-cc82ce73e3ee', '246b303a-90c2-4a94-aa06-b721983de98b', 1, '[{"id": "kn-iku-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av enskilda yrkesverksamma konstnärer"}, {"id": "kn-iku-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-iku-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?"}, {"id": "kn-iku-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Ansökan ska avse internationellt utbyte eller resa", "evidenceKinds": ["invitation"], "intakeQuestion": "Avser ansökan en internationell resa eller ett internationellt utbyte?"}, {"id": "kn-iku-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Konstnärligt projekt"}, {"id": "kn-iku-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}]', '[]', '[{"id": "kn-iku-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-iku-e2", "kind": "invitation", "mandatory": false, "description": "Inbjudan eller beskrivning av samarbetet"}]', '2026-08-29 00:51:26.494157+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.494157+00'),
	('6ff1082e-10ea-4f2e-bf73-4677b09f66fc', 'c7168d6c-e793-4282-9254-ae5a4bbf0bff', 1, '[{"id": "kn-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stipendiet söks av enskilda konstnärer"}, {"id": "kn-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär?"}, {"id": "kn-as-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "culture", "factPath": "project.sector", "description": "Konstnärlig verksamhet"}]', '[]', '[{"id": "kn-as-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-as-e2", "kind": "project_description", "mandatory": true, "description": "Beskrivning av konstnärlig verksamhet och planer"}]', '2026-08-29 00:51:26.499972+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.499972+00'),
	('48232e6e-df8e-41db-a5b9-abaca19b9db0', '997cc202-d8b9-49db-9e25-889483577277', 1, '[{"id": "af-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara en ideell organisation"}, {"id": "af-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "af-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.targetsArvsfondenGroups", "description": "Målgruppen ska vara barn, unga, äldre eller personer med funktionsnedsättning", "intakeQuestion": "Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?"}, {"id": "af-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande i förhållande till ordinarie verksamhet", "intakeQuestion": "Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?"}, {"id": "af-ps-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.targetGroupParticipates", "description": "Målgruppen ska vara delaktig i projektet", "intakeQuestion": "Är målgruppen delaktig i planering och genomförande?"}, {"id": "af-ps-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga som målgrupp"}, {"id": "af-ps-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.democraticStructure", "description": "Demokratiskt uppbyggd organisation", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}]', '[]', '[{"id": "af-ps-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "af-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning/verksamhetsberättelse"}, {"id": "af-ps-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-29 00:51:26.505801+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.505801+00'),
	('1417834a-1b87-44c3-8019-d70e67eaee13', '80a6dd98-3d6b-4117-b532-fd4a41aa0b5a', 1, '[{"id": "bv-as-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara förening eller stiftelse"}, {"id": "bv-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Lokalen ska ligga i Sverige"}, {"id": "bv-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.isPublicVenue", "description": "Lokalen ska vara öppen och tillgänglig för allmänheten", "intakeQuestion": "Är lokalen öppen för alla — inte bara egna medlemmar?"}, {"id": "bv-as-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse investering (bygga, köpa eller rusta upp)", "intakeQuestion": "Avser projektet att bygga, köpa eller rusta upp en lokal?"}, {"id": "bv-as-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamhet för ungdomar prioriteras"}]', '[{"id": "bv-as-b1", "type": "max_funding_share", "percent": 50, "description": "Bidraget täcker som huvudregel högst 50 % av godkänd kostnad."}]', '[{"id": "bv-as-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av lokalen och åtgärderna"}, {"id": "bv-as-e2", "kind": "budget", "mandatory": true, "description": "Kostnadskalkyl och finansieringsplan"}]', '2026-08-29 00:51:26.511455+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.511455+00'),
	('f695f1e3-8951-48bf-8e21-d61b6fab255a', '51a922be-6082-43ac-bacb-54041c0e6512', 1, '[{"id": "rf-lok-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en idrottsförening"}, {"id": "rf-lok-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "rf-lok-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.memberOfSportsFederation", "description": "Föreningen ska vara ansluten till ett specialidrottsförbund inom RF", "intakeQuestion": "Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?"}, {"id": "rf-lok-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamheten ska rikta sig till barn och unga 7–25 år", "intakeQuestion": "Riktar sig verksamheten till barn och unga (7–25 år)?"}, {"id": "rf-lok-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "sports", "factPath": "project.sector", "description": "Idrottsverksamhet"}]', '[]', '[{"id": "rf-lok-e1", "kind": "activity_programme", "mandatory": true, "description": "Närvaroregistrerad aktivitetsredovisning"}]', '2026-08-29 00:51:26.517077+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.517077+00'),
	('be4d3b3e-401d-42ce-935b-1882b08d7db6', '8f65f0c0-288c-4d3a-8a4d-774625f88b66', 1, '[{"id": "sfi-kf-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Stödet söks av ett produktionsbolag"}, {"id": "sfi-kf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "sfi-kf-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett filmprojekt", "intakeQuestion": "Är projektet ett filmprojekt (kort- eller dokumentärfilm)?"}, {"id": "sfi-kf-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "production", "factPath": "project.activityTypes", "description": "Produktion/utveckling"}]', '[]', '[{"id": "sfi-kf-e1", "kind": "project_description", "mandatory": true, "description": "Synopsis/treatment och regivision"}, {"id": "sfi-kf-e2", "kind": "budget", "mandatory": true, "description": "Produktionsbudget och finansieringsplan"}, {"id": "sfi-kf-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelfunktioner"}]', '2026-08-29 00:51:26.522593+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.522593+00'),
	('1207d601-23d7-40e1-9485-7c8e310a0ff7', 'f2578a55-f5c1-4bdb-bef2-98219e52eade', 1, '[{"id": "kr-ss-h1", "op": "in", "kind": "hard", "expected": ["municipality", "school", "company"], "factPath": "applicant.type", "description": "Sökande ska vara skolhuvudman"}, {"id": "kr-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSchoolAuthority", "description": "Sökande ska vara huvudman för förskoleklass/grundskola", "intakeQuestion": "Är ni huvudman för förskoleklass eller grundskola?"}, {"id": "kr-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.usesProfessionalCulture", "description": "Insatserna ska genomföras av professionella kulturaktörer", "intakeQuestion": "Genomförs insatserna av professionella kulturaktörer?"}, {"id": "kr-ss-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Elever som målgrupp"}]', '[]', '[{"id": "kr-ss-e1", "kind": "project_description", "mandatory": true, "description": "Plan för kulturinsatserna"}, {"id": "kr-ss-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-29 00:51:26.528062+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.528062+00'),
	('a084a0f4-de6e-4b4c-a78f-19774a15802b', '5bd2c29b-3505-4985-962b-f7d60c4bcfda', 1, '[{"id": "fo-ou-h1", "op": "in", "kind": "hard", "expected": ["university", "public_body"], "factPath": "applicant.type", "description": "Medlen förvaltas av lärosäte eller forskningsinstitut"}, {"id": "fo-ou-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Medelsförvaltaren ska vara svensk"}, {"id": "fo-ou-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "fo-ou-m2", "op": "in", "kind": "mandatory", "expected": ["environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom Formas ansvarsområden", "intakeQuestion": "Ligger projektet inom miljö, areella näringar eller samhällsbyggande?"}]', '[]', '[{"id": "fo-ou-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "fo-ou-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}, {"id": "fo-ou-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-29 00:51:26.534563+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.534563+00'),
	('7c7b0767-c82d-4d87-88b0-3a62c4382583', '41839f31-54f1-46eb-ab6e-24102e9f9698', 1, '[{"id": "fk-fp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-fp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha (eller vänta) barn som du avstår arbete för att ta hand om", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-29 00:51:26.852024+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.852024+00'),
	('8a57e57d-d4dd-46c9-b38c-7ce387832e84', '49a40583-294d-4bb5-8e3e-6257de2cd982', 1, '[{"id": "tv-ac-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett företag"}, {"id": "tv-ac-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Företaget ska vara registrerat i Sverige"}, {"id": "tv-ac-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSmallEnterprise", "description": "Företaget ska vara litet (typiskt 2–49 anställda — se regionens villkor)", "intakeQuestion": "Har företaget mellan cirka 2 och 49 anställda?"}, {"id": "tv-ac-m2", "op": "includes", "kind": "mandatory", "expected": "development", "factPath": "project.activityTypes", "description": "Checken ska användas för utvecklingsinsats med extern kompetens", "intakeQuestion": "Ska ni ta in extern kompetens för en utvecklingsinsats?"}, {"id": "tv-ac-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.scalableInternationally", "description": "Internationaliseringsambition"}]', '[{"id": "tv-ac-b1", "type": "max_funding_share", "percent": 50, "description": "Checken täcker normalt högst 50 % av kostnaden."}]', '[{"id": "tv-ac-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av utvecklingsinsatsen"}, {"id": "tv-ac-e2", "kind": "budget", "mandatory": true, "description": "Kostnads- och finansieringsplan"}]', '2026-08-29 00:51:26.541108+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.541108+00'),
	('f71ebd88-714a-4ee3-81b9-8aadf928d892', '42758d87-e474-498c-887c-194f6d868e9e', 1, '[{"id": "jv-ss-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-ss-h2", "op": "in", "kind": "hard", "expected": ["individual", "company"], "factPath": "applicant.type", "description": "Söks av person eller företag"}, {"id": "jv-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age40OrYounger", "description": "Sökande ska vara 40 år eller yngre", "intakeQuestion": "Är du 40 år eller yngre?"}, {"id": "jv-ss-m2", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Ansökan ska avse jordbruks-, trädgårds- eller rennäringsföretag", "intakeQuestion": "Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?"}, {"id": "jv-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.startingOrTakingOverFarm", "description": "Sökande ska starta eller ta över företaget för första gången", "intakeQuestion": "Startar du eller tar du över företaget för första gången?"}]', '[]', '[{"id": "jv-ss-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}, {"id": "jv-ss-e2", "kind": "budget", "mandatory": true, "description": "Ekonomisk kalkyl"}]', '2026-08-29 00:51:26.546749+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.546749+00'),
	('6c02d482-d879-4a3a-a160-b56093f34c27', 'aec964e1-b795-40c2-a954-e4b7ca0f5d00', 1, '[{"id": "jv-is-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-is-m1", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Investeringen ska avse jordbruksverksamhet", "intakeQuestion": "Avser investeringen jordbruksverksamhet?"}, {"id": "jv-is-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en fysisk investering?"}]', '[{"id": "jv-is-b1", "type": "max_funding_share", "percent": 40, "description": "Stödandelen är typiskt upp till 40 % av godkänd kostnad — se aktuellt stöd."}]', '[{"id": "jv-is-e1", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl med offerter"}]', '2026-08-29 00:51:26.55197+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.55197+00'),
	('186d86d7-0c67-4955-8ab1-d5bec30076a4', '4955c52c-9cbc-46b9-b36a-80366f8b670e', 1, '[{"id": "esf-ku-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "esf-ku-h2", "op": "in", "kind": "hard", "expected": ["company", "association", "municipality", "region", "public_body", "university"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "esf-ku-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensLabourMarket", "description": "Projektet ska stärka kompetens eller ställning på arbetsmarknaden", "intakeQuestion": "Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?"}, {"id": "esf-ku-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Sökande ska klara att förskottera kostnader (stöd betalas ut i efterskott)", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[{"id": "esf-ku-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med förändringsteori"}, {"id": "esf-ku-e2", "kind": "budget", "mandatory": true, "description": "Detaljerad projektbudget"}]', '2026-08-29 00:51:26.557883+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.557883+00'),
	('60a98b61-ce2a-4238-919d-3001c5f16032', '0f905278-8d79-44d7-a291-102c13d07464', 1, '[{"id": "em-ik-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "em-ik-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "em-ik-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.reducesIndustrialEmissions", "description": "Projektet ska minska industrins utsläpp eller skapa negativa utsläpp", "intakeQuestion": "Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?"}, {"id": "em-ik-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["energy", "environment"], "factPath": "project.sector", "description": "Energi-/klimatprojekt"}]', '[]', '[{"id": "em-ik-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med utsläppsberäkning"}, {"id": "em-ik-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-29 00:51:26.564364+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.564364+00'),
	('9a627d87-c81e-4716-a1bf-6d899432ffa8', '0e140a7c-0699-42b6-9951-f81de9e97846', 1, '[{"id": "pm-bt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget söks av privatpersoner"}, {"id": "pm-bt-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-bt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.receivesPension", "description": "Du ska ta ut hel allmän pension", "intakeQuestion": "Tar du ut hel allmän pension?"}, {"id": "pm-bt-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Inkomsterna ska vara låga i förhållande till boendekostnaden", "intakeQuestion": "Är hushållets inkomster låga i förhållande till boendekostnaden?"}, {"id": "pm-bt-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-29 00:51:26.663954+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.663954+00'),
	('924acb2e-9112-4293-8b34-73eabdf60a66', 'e8ff528a-11af-4d20-82ec-c063e0f512f6', 1, '[{"id": "nv-kk-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Åtgärden ska genomföras i Sverige"}, {"id": "nv-kk-h2", "op": "in", "kind": "hard", "expected": ["company", "municipality", "region", "association", "economic_association", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "nv-kk-m1", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Stödet avser fysiska investeringar", "intakeQuestion": "Avser ansökan en fysisk investering?"}, {"id": "nv-kk-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.measurableEnvironmentalImpact", "description": "Klimatnyttan ska kunna beräknas", "intakeQuestion": "Kan åtgärdens utsläppsminskning beräknas?"}]', '[]', '[{"id": "nv-kk-e1", "kind": "project_description", "mandatory": true, "description": "Åtgärdsbeskrivning med klimatnyttoberäkning"}, {"id": "nv-kk-e2", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl"}]', '2026-08-29 00:51:26.570635+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.570635+00'),
	('b793eb84-8b4b-4681-b11f-204574a2e105', '198d8d6c-44aa-499c-ac8a-c10015ad87a9', 1, '[{"id": "nv-lona-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Formell sökande är en kommun (föreningar deltar via kommunen)"}, {"id": "nv-lona-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "nv-lona-m1", "op": "eq", "kind": "mandatory", "expected": "environment", "factPath": "project.sector", "description": "Projektet ska avse naturvård eller friluftsliv", "intakeQuestion": "Avser projektet naturvård eller friluftsliv?"}]', '[{"id": "nv-lona-b1", "type": "max_funding_share", "percent": 50, "description": "Högst 50 % bidrag (våtmarksprojekt kan få upp till 90 % — se villkoren)."}]', '[{"id": "nv-lona-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-29 00:51:26.576067+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.576067+00'),
	('1546506b-adf0-48bf-8f6a-88ca378aba85', '1242e318-cd06-48a6-bbbb-4806d4cdc374', 1, '[{"id": "mucf-esc-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "mucf-esc-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "mucf-esc-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "mucf-esc-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasQualityLabel", "description": "Organisationen behöver en Quality Label för solidaritetskåren", "intakeQuestion": "Har organisationen en Quality Label (kvalitetsmärkning)?"}, {"id": "mucf-esc-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge18to30", "description": "Volontärerna ska vara 18–30 år", "intakeQuestion": "Är volontärerna mellan 18 och 30 år?"}, {"id": "mucf-esc-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}, {"id": "mucf-esc-w2", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}]', '[]', '[{"id": "mucf-esc-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med aktivitetsplan"}, {"id": "mucf-esc-e2", "kind": "partner_letter", "mandatory": false, "description": "Bekräftelse från partnerorganisation(er)"}]', '2026-08-29 00:51:26.581339+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.581339+00'),
	('d7f1d17b-0fa9-47b7-9e56-9aa86873ec8b', '6b410cf5-2dbd-4f63-9c77-004925ffc694', 1, '[{"id": "er-ka1-h1", "op": "in", "kind": "hard", "expected": ["school", "municipality", "company", "association", "public_body"], "factPath": "applicant.type", "description": "Söks av utbildningsorganisationer/huvudmän"}, {"id": "er-ka1-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "er-ka1-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "er-ka1-m2", "op": "eq", "kind": "mandatory", "expected": "education", "factPath": "project.sector", "description": "Projektet ska avse utbildningsverksamhet", "intakeQuestion": "Avser projektet skola eller vuxenutbildning?"}, {"id": "er-ka1-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Mobiliteten ska ske till ett annat programland", "intakeQuestion": "Sker mobiliteten till ett annat europeiskt land?"}]', '[]', '[{"id": "er-ka1-e1", "kind": "project_description", "mandatory": true, "description": "Mobilitetsplan"}]', '2026-08-29 00:51:26.586491+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.586491+00'),
	('d9556ce2-a1f3-48f1-8a3c-f29e4caa2d10', 'e19104fa-6c9a-4bfb-8b0c-44dbc773360b', 1, '[{"id": "ke-sp-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer inom kultursektorn"}, {"id": "ke-sp-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "ke-sp-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasThreeCountryPartnership", "description": "Minst tre partner från tre olika programländer krävs", "intakeQuestion": "Har ni partner i minst tre olika europeiska länder?"}, {"id": "ke-sp-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver registrering i EU:s system (PIC/OID)", "intakeQuestion": "Är organisationen registrerad i EU:s deltagarregister?"}, {"id": "ke-sp-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "ke-sp-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning enligt utlysningens mall"}, {"id": "ke-sp-e2", "kind": "partner_letter", "mandatory": true, "description": "Partneravtal/avsiktsförklaringar"}, {"id": "ke-sp-e3", "kind": "budget", "mandatory": true, "description": "Detaljerad budget"}]', '2026-08-29 00:51:26.592323+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.592323+00'),
	('1a057ad3-5f50-405c-ba6a-5085a0fd7d70', '661ec89f-61e7-4690-a98a-b47d865ca9d2', 1, '[{"id": "fk-tfp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-tfp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (normalt under 12 år) som du vårdar när det är sjukt", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-29 00:51:26.856342+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.856342+00'),
	('fd73006d-b9a2-4060-aa7d-cd73c585c2fb', 'e0e9a726-21da-4f87-af24-38748de98344', 1, '[{"id": "kr-vs-h1", "op": "in", "kind": "hard", "expected": ["association", "company"], "factPath": "applicant.type", "description": "Söks av grupper/organisationer — inte enskilda"}, {"id": "kr-vs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-vs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Verksamheten ska vara professionell", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-vs-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Verksamheten ska vara scenkonst", "intakeQuestion": "Är verksamheten scenkonst (dans, teater, musikteater)?"}, {"id": "kr-vs-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "performance", "factPath": "project.activityTypes", "description": "Publik verksamhet"}]', '[]', '[{"id": "kr-vs-e1", "kind": "project_description", "mandatory": true, "description": "Verksamhetsplan"}, {"id": "kr-vs-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse"}, {"id": "kr-vs-e3", "kind": "budget", "mandatory": true, "description": "Verksamhetsbudget"}]', '2026-08-29 00:51:26.597811+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.597811+00'),
	('d45cb393-a099-4574-bb83-0d9dec7ddab1', '6d619133-7c4e-4e5c-b3d3-eb1c817dd5f4', 1, '[{"id": "vin-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara svensk organisation"}, {"id": "vin-pb-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "vin-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansEuApplication", "description": "Bidraget ska användas för att förbereda en EU-ansökan", "intakeQuestion": "Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?"}]', '[]', '[{"id": "vin-pb-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av planerad EU-ansökan"}]', '2026-08-29 00:51:26.603077+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.603077+00'),
	('b3a60b75-f8a1-4946-926d-9953252fe70d', '11248c93-a2ed-4a26-9a1b-b024c4ae4fe8', 1, '[{"id": "mucf-ob-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-ob-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara nationell och verksam i Sverige"}, {"id": "mucf-ob-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Demokratisk uppbyggnad krävs", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}, {"id": "mucf-ob-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.youthMembersShareOver60", "description": "Minst 60 % av medlemmarna ska vara 6–25 år", "intakeQuestion": "Är minst 60 % av medlemmarna mellan 6 och 25 år?"}, {"id": "mucf-ob-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasNationalSpread", "description": "Verksamhet i flera län krävs", "intakeQuestion": "Har organisationen medlemsföreningar i flera län?"}]', '[]', '[{"id": "mucf-ob-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "mucf-ob-e2", "kind": "annual_report", "mandatory": true, "description": "Årsredovisning och medlemsredovisning"}]', '2026-08-29 00:51:26.608067+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.608067+00'),
	('498441d3-1428-44e7-9909-fcdb56d7123d', 'ebf624c6-e356-4f65-abdc-9355e0d87583', 1, '[{"id": "fk-bbf-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbf-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig (helt eller växelvis)", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-bbf-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Hushållets inkomst ska vara under inkomstgränsen", "intakeQuestion": "Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbf-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-29 00:51:26.613639+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.613639+00'),
	('04de7026-5ed4-4277-be8c-d3efcc8d2554', '8ba44ea9-2f57-4a2b-b5af-a48f1ebe154e', 1, '[{"id": "reg-glas-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare"}, {"id": "reg-glas-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska vara folkbokfört i Sverige"}, {"id": "reg-glas-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "reg-glas-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childNeedsGlasses", "description": "Barnet (8–19 år) behöver glasögon eller kontaktlinser", "intakeQuestion": "Behöver något av dina barn i åldern 8–19 år glasögon eller linser?"}]', '[]', '[]', '2026-08-29 00:51:26.619079+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.619079+00'),
	('948836fe-e1b8-487a-9ab0-bd0f1107e593', '30d11949-6313-4065-8343-6dd2c89361d0', 1, '[{"id": "maj-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare eller t.ex. skolsköterska"}, {"id": "maj-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "maj-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (upp till 18 år) som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "maj-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childCostsStrain", "description": "Ekonomin räcker inte till sådant barnet behöver eller förväntas delta i", "intakeQuestion": "Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?"}, {"id": "maj-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "person.lowHouseholdIncome", "description": "Låg hushållsinkomst stärker ansökan"}]', '[]', '[]', '2026-08-29 00:51:26.624049+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.624049+00'),
	('a1e09cf1-b86c-406e-a4d4-7008db46f042', '4fde6677-6df1-4fa3-ad75-f9908f56eccb', 1, '[{"id": "skjuts-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av vårdnadshavare"}, {"id": "skjuts-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "skjuts-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "skjuts-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInCompulsorySchool", "description": "Barnet går i grundskolan", "intakeQuestion": "Går något av dina barn i grundskolan?"}, {"id": "skjuts-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childSchoolDistanceQualifies", "description": "Färdvägen kvalificerar (längd, trafik eller funktionsnedsättning — kommunens bedömning)", "intakeQuestion": "Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?"}]', '[]', '[]', '2026-08-29 00:51:26.629212+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.629212+00'),
	('6768b3a2-c81a-48d6-9fdf-206536831a01', '6ae1c899-5fe0-45aa-ab69-5d80a6af1d85', 1, '[{"id": "elevres-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "elevres-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "elevres-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "elevres-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Barnet går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "elevres-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childGymnasiumLongTravel", "description": "Färdvägen till skolan är minst sex kilometer", "intakeQuestion": "Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?"}]', '[]', '[]', '2026-08-29 00:51:26.635111+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.635111+00'),
	('02a5f773-caa0-4f3f-9ed4-7b58ac07a3cc', '5b97cddb-ca0e-491b-a920-311c88591982', 1, '[{"id": "fk-bbu-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbu-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbu-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara mellan 18 och 28 år", "intakeQuestion": "Är du mellan 18 och 28 år?"}, {"id": "fk-bbu-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Din inkomst ska vara låg", "intakeQuestion": "Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbu-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-29 00:51:26.638932+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.638932+00'),
	('4ef85eed-9f17-465e-936c-4145886a4270', 'e9167b6c-adae-4e91-a1dd-cf417419ba38', 1, '[{"id": "kfs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "kfs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "kfs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.incomeInsufficientForBasicNeeds", "description": "Inkomsterna ska inte räcka till det mest nödvändiga", "intakeQuestion": "Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?"}, {"id": "kfs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.limitedSavings", "description": "Du ska sakna sparande eller tillgångar som kan täcka behoven", "intakeQuestion": "Saknar du sparpengar eller tillgångar som kan täcka utgifterna?"}]', '[]', '[]', '2026-08-29 00:51:26.64362+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.64362+00'),
	('d8187afc-710d-4893-8297-d913df3030df', 'e31683f9-d952-4386-8ddc-c30becfdec42', 1, '[{"id": "csn-sm-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-sm-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. det år du fyller 60"}, {"id": "csn-sm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}]', '[]', '[]', '2026-08-29 00:51:26.648244+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.648244+00'),
	('7bff466d-7aa6-45ab-91d5-850dc4824b12', '8cd35f7d-ae52-4807-8329-3cc924bb3027', 1, '[{"id": "fk-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-ae-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara 19–29 år", "intakeQuestion": "Är du mellan 19 och 29 år?"}, {"id": "fk-ae-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.reducedWorkCapacityLongTerm", "description": "Arbetsförmågan ska vara nedsatt i minst ett år", "intakeQuestion": "Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?"}]', '[]', '[{"id": "fk-ae-e1", "kind": "medical_certificate", "mandatory": true, "description": "Läkarutlåtande om arbetsförmåga"}]', '2026-08-29 00:51:26.654384+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.654384+00'),
	('a45300a0-341a-429c-a1c4-6b11941639a9', 'ba9cb75e-c5e1-4785-888c-b3f959d062a4', 1, '[{"id": "fk-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Barnet ska bo hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}, {"id": "fk-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.separatedParent", "description": "Föräldrarna ska inte bo tillsammans", "intakeQuestion": "Bor du och barnets andra förälder på skilda håll?"}, {"id": "fk-us-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.otherParentNotPaying", "description": "Den andra föräldern betalar inte underhåll (eller för lite)", "intakeQuestion": "Betalar den andra föräldern inget eller mindre än fullt underhåll?"}]', '[]', '[]', '2026-08-29 00:51:26.659057+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.659057+00'),
	('68c68198-8d31-4b74-8844-04ce1cf4120d', '907ff8ba-6609-4fc0-9bb3-a03db3135734', 1, '[{"id": "af-ssn-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "af-ssn-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara inskriven hos Arbetsförmedlingen i Sverige"}, {"id": "af-ssn-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven som arbetssökande", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "af-ssn-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansToStartBusiness", "description": "Du ska planera att starta företag", "intakeQuestion": "Planerar du att starta eget företag?"}]', '[]', '[{"id": "af-ssn-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}]', '2026-08-29 00:51:26.674855+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.674855+00'),
	('640f8a1a-4416-4141-9beb-56b005051780', '400960a3-b232-41ea-8268-696ee266bbc3', 1, '[{"id": "csn-oss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-oss-h2", "op": "is_false", "kind": "hard", "factPath": "person.age62Plus", "description": "Stödet kan sökas längst t.o.m. det år du fyller 62"}, {"id": "csn-oss-h3", "op": "is_false", "kind": "hard", "factPath": "person.receivesPension", "description": "Stödet riktar sig till yrkesverksamma, inte pensionärer"}, {"id": "csn-oss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.establishedInLabourMarket", "description": "Du ska ha arbetat i genomsnitt minst 16 h/vecka i minst 8 år", "intakeQuestion": "Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?"}, {"id": "csn-oss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska planera studier som stärker din ställning på arbetsmarknaden", "intakeQuestion": "Planerar du studier som stärker din ställning på arbetsmarknaden?"}]', '[]', '[]', '2026-08-29 00:51:26.680218+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.680218+00'),
	('f2b8c839-944b-44e2-abe1-c35e2c2e3ce4', 'feb697d1-0ec2-4c29-a773-b973fb6bf623', 1, '[{"id": "kom-bab-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "kom-bab-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bostaden ska ligga i Sverige"}, {"id": "kom-bab-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i hushållet har en funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "kom-bab-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du eller någon i hushållet ska ha en bestående funktionsnedsättning", "intakeQuestion": "Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?"}, {"id": "kom-bab-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.needsHomeAdaptation", "description": "Bostaden ska behöva anpassas", "intakeQuestion": "Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?"}]', '[]', '[{"id": "kom-bab-e1", "kind": "medical_certificate", "mandatory": true, "description": "Intyg från arbetsterapeut, läkare eller motsvarande"}]', '2026-08-29 00:51:26.685417+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.685417+00'),
	('34d8080f-22d1-474b-a0df-38121937fb98', '2ef27dfa-fbd2-432e-b1aa-2cff8121df89', 1, '[{"id": "kn-kb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kn-kb-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kn-kb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande", "intakeQuestion": "Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?"}]', '[]', '[{"id": "kn-kb-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kn-kb-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-29 00:51:26.690638+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.690638+00'),
	('7f9597aa-0b06-4080-b3ca-9eab248e8362', '76e44e84-a3fa-45dc-b97a-018b70209e89', 1, '[{"id": "raa-ka-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "raa-ka-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "raa-ka-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsCulturalHeritage", "description": "Projektet ska avse kulturarv", "intakeQuestion": "Handlar projektet om att bevara eller tillgängliggöra kulturarv?"}]', '[]', '[]', '2026-08-29 00:51:26.695476+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.695476+00'),
	('628f452f-acab-49b1-ae79-60777151a0f0', 'e53f78a0-2b6c-47e9-86b2-40699b80f7ad', 1, '[{"id": "si-cf-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "si-cf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande organisation ska vara svensk"}, {"id": "si-cf-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska genomföras med internationell partner", "intakeQuestion": "Har projektet en partner i ett annat land?"}, {"id": "si-cf-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensDemocracy", "description": "Projektet ska stärka demokrati, jämlikhet eller yttrandefrihet", "intakeQuestion": "Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?"}, {"id": "si-cf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["culture", "civil_society"], "factPath": "project.sector", "description": "Kultur/media som verktyg"}]', '[]', '[{"id": "si-cf-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från internationell partner"}, {"id": "si-cf-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-29 00:51:26.701715+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.701715+00'),
	('56acf9fd-c239-4c6e-9455-7d2586f7f471', 'dec6a85d-aca1-4209-bb00-7d48639943a0', 1, '[{"id": "fk-sp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-sp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.sickReducedWorkCapacity", "description": "Sjukdomen ska sätta ned din arbetsförmåga med minst en fjärdedel", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du en sjukdom eller skada som just nu sätter ned din förmåga att arbeta?"}]', '[]', '[]', '2026-08-29 00:51:26.861461+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.861461+00'),
	('a0e650ce-d48a-4fb4-941e-f9a0d587fb3f', '8f0b862f-211f-4605-ad2c-72e6ee8fdee8', 1, '[{"id": "nkf-ps-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett konst- eller kulturprojekt", "intakeQuestion": "Är projektet ett konst- eller kulturprojekt?"}, {"id": "nkf-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasNordicDimension", "description": "Projektet ska ha nordisk dimension (samarbete i flera nordiska länder)", "intakeQuestion": "Samarbetar ni med partner i minst två andra nordiska länder?"}, {"id": "nkf-ps-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Gränsöverskridande samarbete"}]', '[]', '[{"id": "nkf-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "nkf-ps-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-29 00:51:26.706863+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.706863+00');
INSERT INTO public.rule_versions VALUES
	('8552163c-923d-4746-ade9-03ddf32e466c', 'ba48f852-da3b-496c-8ff0-0a998745e437', 1, '[{"id": "vr-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte"}, {"id": "vr-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}]', '[]', '[{"id": "vr-pb-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "vr-pb-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}]', '2026-08-29 00:51:26.711521+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.711521+00'),
	('802d0780-e66f-4d8b-adfa-4a3cb137c350', '2e231444-342a-492b-90d4-8972fae42b6a', 1, '[{"id": "pk-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "pk-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska vara etablerad och välskött", "intakeQuestion": "Har organisationen ordnad ekonomi och demokratisk struktur?"}, {"id": "pk-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Stödet ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[{"id": "pk-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "pk-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning"}]', '2026-08-29 00:51:26.716028+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.716028+00'),
	('737eae80-41e2-4b48-b500-ce40f1aeb7a4', '2fc1d884-cadf-43e3-b6e2-a38b76051271', 1, '[{"id": "mv-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "mv-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell musikverksamhet", "intakeQuestion": "Är verksamheten professionell?"}, {"id": "mv-pb-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Musikprojekt", "intakeQuestion": "Är projektet ett musikprojekt?"}]', '[]', '[]', '2026-08-29 00:51:26.721472+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.721472+00'),
	('9692d40e-9879-4b18-acc7-806fab8d4b94', '0bf4d414-9c2b-4858-be25-4b9de889456d', 1, '[{"id": "er-ka2-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "school", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "er-ka2-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID?"}, {"id": "er-ka2-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partner i ett annat programland", "intakeQuestion": "Har ni en partnerorganisation i ett annat europeiskt land?"}, {"id": "er-ka2-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.newToEuFunding", "description": "Nykomlingar i Erasmus+ prioriteras", "intakeQuestion": "Är det här ert första EU-projekt?"}]', '[]', '[{"id": "er-ka2-e1", "kind": "partner_letter", "mandatory": true, "description": "Partnerbekräftelse"}, {"id": "er-ka2-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-29 00:51:26.72667+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.72667+00'),
	('2e34f4d8-cb5d-46aa-90fa-d8264d2188ca', 'a5279701-a293-4f62-886e-158c67a5cec3', 1, '[{"id": "tv-ris-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av företag"}, {"id": "tv-ris-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "tv-ris-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.inSupportArea", "description": "Verksamhetsorten ska ligga i stödområde A eller B", "intakeQuestion": "Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?"}, {"id": "tv-ris-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en investering i byggnader eller maskiner?"}, {"id": "tv-ris-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.notStartedYet", "description": "Investeringen får inte vara påbörjad före ansökan", "intakeQuestion": "Kommer investeringen att påbörjas först efter att ni skickat in ansökan?"}]', '[{"id": "tv-ris-b1", "type": "max_funding_share", "percent": 35, "description": "Stödandelen är högst 35 % beroende på område och företagsstorlek."}]', '[]', '2026-08-29 00:51:26.73158+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.73158+00'),
	('70c8c1e4-790d-443e-885c-5db29b0d0c92', 'c2b559b9-ee37-40e9-9e6e-71daff70b1c2', 1, '[{"id": "kr-ib-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Söks av kommuner"}, {"id": "kr-ib-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsLibraries", "description": "Medlen ska användas till litteraturinköp för folk- eller skolbibliotek", "intakeQuestion": "Avser ansökan litteraturinköp till folk- eller skolbibliotek?"}, {"id": "kr-ib-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga prioriteras"}]', '[]', '[]', '2026-08-29 00:51:26.736532+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.736532+00'),
	('e39a2170-6069-48bb-b737-ea30a9c185a0', '74c0fdc8-6b92-4d9d-bf6d-37e456136140', 1, '[{"id": "kr-ls-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av förlag"}, {"id": "kr-ls-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isPublisher", "description": "Sökande ska vara ett förlag med professionell utgivning", "intakeQuestion": "Är ni ett förlag med professionell utgivning?"}, {"id": "kr-ls-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsPublishedBook", "description": "Stödet söks för redan utgiven titel", "intakeQuestion": "Avser ansökan en redan utgiven titel?"}]', '[]', '[]', '2026-08-29 00:51:26.741301+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.741301+00'),
	('e16c9447-2b2d-43ab-9278-0242571021d8', 'ffba91cf-dd29-4a2f-98d5-195d3d3a970f', 1, '[{"id": "ls-bm-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality"], "factPath": "applicant.type", "description": "Söks av föreningar och kommuner"}, {"id": "ls-bm-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "ls-bm-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inAffectedArea", "description": "Projektet ska ligga i en bygd berörd av vatten- eller vindkraft", "intakeQuestion": "Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?"}, {"id": "ls-bm-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsCommunity", "description": "Projektet ska vara till allmän nytta för bygden", "intakeQuestion": "Är projektet till nytta för bygden i stort (inte enskilda)?"}]', '[]', '[]', '2026-08-29 00:51:26.746563+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.746563+00'),
	('74b0ca57-e477-4950-bf13-07afe35b4e45', '83080275-413e-4e21-81bb-3a09b8a7208a', 1, '[{"id": "mv-av-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "mv-av-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "mv-av-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.planningReturnMigration", "description": "Du ska frivilligt planera att flytta tillbaka till ditt ursprungsland permanent", "intakeQuestion": "Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?"}, {"id": "mv-av-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.protectionBasedResidence", "description": "Du ska ha uppehållstillstånd som flykting eller skyddsbehövande (eller vara nära anhörig till någon som har det)", "intakeQuestion": "Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?"}]', '[]', '[]', '2026-08-29 00:51:26.75182+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.75182+00'),
	('76798e02-22ea-4575-a5ad-1546788e54f5', '43d56b50-b052-4ade-9684-23d7ca7a9c53', 1, '[{"id": "eures-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "eures-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara bosatt i ett EU-land (här: Sverige)"}, {"id": "eures-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "eures-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.seekingJobInOtherEuCountry", "description": "Du ska söka eller ha fått jobb i ett annat EU-/EES-land", "intakeQuestion": "Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?"}]', '[]', '[]', '2026-08-29 00:51:26.761619+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.761619+00'),
	('17d40e05-a711-4ae8-87a1-cbbf7c8bcec0', 'f36d31cc-a2d8-4f69-a080-0bc1457bfda1', 1, '[{"id": "csn-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-us-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. ca 60 års ålder"}, {"id": "csn-us-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "csn-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}, {"id": "csn-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansStudyAbroad", "description": "Studierna ska bedrivas utomlands", "intakeQuestion": "Planerar du att studera utomlands?"}]', '[]', '[]', '2026-08-29 00:51:26.765597+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.765597+00'),
	('af139f3a-6492-494a-9940-bd5990285c54', '3285e0f1-7dfe-4c53-8a06-f090af76b725', 1, '[{"id": "fk-ov-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av vårdnadshavare"}, {"id": "fk-ov-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-ov-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-ov-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-ov-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childHasDisability", "description": "Barnet ska ha en funktionsnedsättning som ger behov av mer omvårdnad och tillsyn än jämnåriga", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?"}]', '[]', '[]', '2026-08-29 00:51:26.770963+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.770963+00'),
	('da299fa4-60ff-4cec-a029-c13fe3062708', '82623f15-5b9c-4408-87f3-cf9dce70531f', 1, '[{"id": "fk-mk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-mk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-mk-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-mk-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du (eller ditt barn) ska ha en varaktig funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-mk-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityExtraCosts", "description": "Funktionsnedsättningen ska medföra merkostnader över lägstanivån", "intakeQuestion": "Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?"}]', '[]', '[]', '2026-08-29 00:51:26.775948+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.775948+00'),
	('3672dfa3-f389-4e2b-b283-f2de4c80ea25', '139f4a15-edaf-4a8b-8d1c-f4e4e394e4d7', 1, '[{"id": "fk-bs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-bs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-bs-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-bs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Funktionsnedsättningen ska vara varaktig", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-bs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityTravelDifficulty", "description": "Det ska vara mycket svårt att förflytta sig på egen hand eller använda allmänna kommunikationer", "intakeQuestion": "Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?"}]', '[]', '[]', '2026-08-29 00:51:26.781022+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.781022+00'),
	('a37f7187-332d-4965-85a4-98a18b6f2e0b', 'd3c40e81-3e19-4764-b364-110e1d5c2bc1', 1, '[{"id": "fk-np-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-np-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-np-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.caringForSeriouslyIllRelative", "description": "Du ska avstå från förvärvsarbete för att vårda eller vara nära en närstående vars sjukdom är ett påtagligt hot mot livet", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?"}]', '[]', '[]', '2026-08-29 00:51:26.786102+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.786102+00'),
	('967e2163-ecd9-4502-9c2f-b106987c81b8', '1486ea2a-fac8-44b9-b248-d4c0c9140ea4', 1, '[{"id": "af-ee-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "af-ee-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "af-ee-h3", "op": "is_false", "kind": "hard", "factPath": "person.age66Plus", "description": "Programmet gäller till och med 66 års ålder"}, {"id": "af-ee-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Du ska nyligen ha fått uppehållstillstånd som skyddsbehövande eller anhörig", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "af-ee-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och delta i etableringsprogrammet", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-29 00:51:26.791068+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.791068+00'),
	('a75f2add-6218-4728-aa21-61b930bf639d', '0b4b4b89-c8af-4361-91c4-aaabcee3473c', 1, '[{"id": "csn-hl-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Lånet söks av privatpersoner"}, {"id": "csn-hl-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara mottagen i en svensk kommun"}, {"id": "csn-hl-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Lånet gäller flyktingar och vissa anhöriga under de första åren i Sverige", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "csn-hl-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.settlingFirstHomeInSweden", "description": "Du ska hålla på att skaffa och utrusta ett första hem i Sverige", "intakeQuestion": "Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?"}]', '[]', '[]', '2026-08-29 00:51:26.796528+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.796528+00'),
	('681de72c-ac22-42ad-ae31-4d23e6067795', '1555f28b-9594-494d-81c0-4d2c7d5906af', 1, '[{"id": "csn-ss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "csn-ss-h3", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Stödet gäller till och med 60 års ålder"}, {"id": "csn-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara arbetslös och anmäld hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "csn-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.age25to60", "description": "Du ska vara mellan 25 och 60 år", "intakeQuestion": "Är du mellan 25 och 60 år?"}, {"id": "csn-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.shortPriorEducation", "description": "Du ska ha kort tidigare utbildning och behöva studier på grundskole- eller gymnasienivå", "intakeQuestion": "Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?"}]', '[]', '[]', '2026-08-29 00:51:26.801515+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.801515+00'),
	('6e1c2e8e-69ae-45f4-90c7-3260e9fbe855', '8676b172-c852-454f-b935-f8b47938e2e8', 1, '[{"id": "csn-it-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "csn-it-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "csn-it-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "csn-it-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Eleven går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "csn-it-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childLivesAwayForStudies", "description": "Eleven behöver bo på studieorten på grund av lång eller besvärlig resväg", "intakeQuestion": "Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?"}]', '[]', '[]', '2026-08-29 00:51:26.808652+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.808652+00'),
	('be65fc46-a297-4d58-9710-93a25f7372c9', 'a83bf538-f3ec-4693-90d9-a789fc2bd05e', 1, '[{"id": "kmn-fb-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Bidragen söks av ideella föreningar"}, {"id": "kmn-fb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "kmn-fb-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Föreningen ska vara demokratiskt uppbyggd med stadgar och styrelse", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har föreningen antagna stadgar och en vald styrelse?"}, {"id": "kmn-fb-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.activeInMunicipality", "description": "Föreningen ska bedriva regelbunden verksamhet i kommunen", "intakeQuestion": "Bedriver föreningen regelbunden verksamhet i kommunen?"}, {"id": "kmn-fb-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.hasYouthActivities", "description": "Barn- och ungdomsverksamhet prioriteras i de flesta kommuner", "intakeQuestion": "Har föreningen regelbunden verksamhet för barn eller unga?"}]', '[]', '[]', '2026-08-29 00:51:26.814374+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.814374+00'),
	('3bad51dc-c21c-4b61-8cee-8d026c6ba5b6', '1c866c7e-8c24-4fdb-9caf-2f0d7c21df19', 1, '[{"id": "reg-ks-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "reg-ks-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Stöden gäller kulturverksamhet", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "reg-ks-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.regionalConnection", "description": "Sökanden ska ha säte eller huvudsaklig verksamhet i regionen", "intakeQuestion": "Har ni säte eller huvudsaklig verksamhet i den region där ni söker?"}]', '[]', '[]', '2026-08-29 00:51:26.819212+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.819212+00'),
	('fcbd0332-6008-459d-8228-3517565bdfec', '33cac5d0-73fa-476f-aa3a-ff82ed272872', 1, '[{"id": "spb-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks i regel av ideella organisationer"}, {"id": "spb-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "spb-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.localSparbankPresence", "description": "Det ska finnas en sparbank/sparbanksstiftelse i ert verksamhetsområde", "intakeQuestion": "Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?"}, {"id": "spb-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska komma det lokala samhället till del", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}]', '[]', '[]', '2026-08-29 00:51:26.823774+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.823774+00'),
	('2a9dcb4e-a120-4be3-87c0-693439833e37', '0a238082-9bad-4a67-b0b6-d7fc05ea5d09', 1, '[{"id": "leader-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "leader-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inRuralLeaderArea", "description": "Projektet ska genomföras inom ett leaderområde (större delen av landsbygden och många tätorter omfattas)", "intakeQuestion": "Genomförs projektet på landsbygden eller i en mindre tätort?"}, {"id": "leader-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska bidra till bygdens utveckling enligt områdets strategi", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}, {"id": "leader-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Stödet betalas ut i efterhand — ni behöver kunna ligga ute med kostnader", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[]', '2026-08-29 00:51:26.829134+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.829134+00'),
	('bc10038f-e1df-4c20-a19a-2961324a30b2', '88262647-8d83-4ea4-bc98-d712131aeb66', 1, '[{"id": "forte-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte eller godkänd medelsförvaltare"}, {"id": "forte-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "forte-pb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.withinForteAreas", "description": "Projektet ska ligga inom hälsa, arbetsliv eller välfärd", "intakeQuestion": "Handlar projektet om hälsa, arbetsliv eller välfärd?"}]', '[]', '[]', '2026-08-29 00:51:26.834638+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.834638+00'),
	('6af691ba-2c8a-47b4-a313-91903ea9ddbb', 'bbc6cdca-3a52-4ffa-99ad-37689c63e8dc', 1, '[{"id": "rh-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks av ideella organisationer"}, {"id": "rh-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara svensk"}, {"id": "rh-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.has90Account", "description": "Organisationen ska ha 90-konto (Svensk Insamlingskontroll)", "intakeQuestion": "Har organisationen ett 90-konto?"}, {"id": "rh-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Bidrag ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[]', '2026-08-29 00:51:26.839717+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.839717+00'),
	('de95d3fd-9daa-4dba-9a7b-ce2b701fcc87', '001a27e8-1efb-4ffd-b2fc-eae50998ecb1', 1, '[{"id": "fk-bb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-bb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-bb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn under 16 år som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-29 00:51:26.843937+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.843937+00'),
	('10f16055-b31f-4e76-b090-9269b43f7810', '833041bb-eb89-40d4-b9df-9b385b7706c3', 1, '[{"id": "fk-fbt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget gäller privatpersoner"}, {"id": "fk-fbt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Gäller från och med det andra barnet du får barnbidrag för", "intakeQuestion": "Har du barn som bor hos dig?"}]', '[]', '[]', '2026-08-29 00:51:26.848017+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.848017+00'),
	('e1c27cbc-1dcc-4e54-8155-f2b8c5ba432c', 'de7cb791-042e-4e7c-9baa-efcfdbdf112c', 1, '[{"id": "fk-se-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-se-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Ersättningen är aktuell vid varaktig sjukdom eller funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-se-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Arbetsförmågan ska vara stadigvarande nedsatt av sjukdom eller funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}]', '[]', '[]', '2026-08-29 00:51:26.865889+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.865889+00'),
	('e9f45fdc-d036-44b9-a945-c1c9f70de0d6', '65d404be-9005-48ae-a214-20c2a2580974', 1, '[{"id": "fk-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "fk-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "fk-as-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.inAfProgram", "description": "Du ska delta i ett arbetsmarknadspolitiskt program", "intakeQuestion": "Deltar du i ett program hos Arbetsförmedlingen (t.ex. jobb- och utvecklingsgarantin)?"}]', '[]', '[]', '2026-08-29 00:51:26.871804+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.871804+00'),
	('bd84bf7a-0b8d-4053-ac35-9f5a7d3bdb69', '55a665b2-e007-4927-b461-64d74b00ab68', 1, '[{"id": "fk-atb-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget gäller privatpersoner"}, {"id": "fk-atb-h2", "op": "is_true", "kind": "hard", "factPath": "person.age24Plus", "description": "Bidraget gäller från och med det år du fyller 24"}]', '[]', '[]', '2026-08-29 00:51:26.877424+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.877424+00'),
	('9752356f-ec9d-498f-897f-7bed01d16370', '26027711-153c-40ef-b8ad-8abe2723f09a', 1, '[{"id": "pm-gp-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Gäller privatpersoner"}, {"id": "pm-gp-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Garantipension lämnas från riktåldern (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}]', '[]', '[]', '2026-08-29 00:51:26.882504+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.882504+00'),
	('b00068a6-6879-4096-b558-a52788d8f072', '046bf444-4d02-4f5c-a99f-7bb6fd82a152', 1, '[{"id": "reg-hk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Skyddet gäller privatpersoner"}, {"id": "reg-hk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller vård i Sverige"}]', '[]', '[]', '2026-08-29 00:51:26.887365+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.887365+00'),
	('491ce70a-d970-4a9a-94ae-f78a8dd1a7b1', '909b281b-4d83-4320-a526-b882487327fa', 1, '[{"id": "ak-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen gäller privatpersoner"}, {"id": "ak-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och aktivt söka arbete", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-29 00:51:26.892285+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.892285+00'),
	('ce8407bf-7a48-498a-bccd-99e4c17a64d7', '9bcf8bbf-d15e-4419-afc8-c3e118657fd1', 1, '[{"id": "af-nj-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-nj-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateAwayFromWork", "description": "Den som anställs ska ha varit borta från arbetslivet en längre tid eller vara nyanländ", "intakeQuestion": "Gäller anställningen någon som varit arbetslös länge eller är ny i Sverige?"}]', '[]', '[]', '2026-08-29 00:51:26.897068+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.897068+00'),
	('636c736a-8cc4-400a-a081-e2d9604ce8d4', '38704d2f-2c8a-4969-ba9e-8711451b057e', 1, '[{"id": "af-lb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansToHire", "description": "Stödet förutsätter att ni planerar att anställa eller behålla en medarbetare", "intakeQuestion": "Planerar ni att anställa?"}, {"id": "af-lb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hireCandidateReducedWorkCapacity", "description": "Den anställda ska ha nedsatt arbetsförmåga på grund av funktionsnedsättning eller ohälsa", "intakeQuestion": "Gäller anställningen en person med nedsatt arbetsförmåga?"}]', '[]', '[]', '2026-08-29 00:51:26.901108+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-29 00:51:26.901108+00');


--
-- Data for Name: source_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sources VALUES
	('4e04f263-c25c-4500-a65c-5baf44148a2f', 'f5e7049a-03b4-415f-9d10-4cc1c60729cc', 'Kulturrådet — Sök bidrag', 'https://kulturradet.se/sok-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.386287+00'),
	('c7ffcbec-3811-454a-ba00-87878fe6eac0', 'b11b2d34-56de-4cfe-af50-d3dfd9997dcb', 'MUCF — Bidrag', 'https://www.mucf.se/bidrag', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.388219+00'),
	('6ad2aa7f-a44d-4e4f-a0b6-f57dcbdc4d80', '3d781c3a-47ad-4402-aefc-68d920a0a0a0', 'Vinnova — Utlysningar', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.389647+00'),
	('468a1d62-9108-4141-9dc9-d650c74ae822', '796064d4-174e-44d7-9429-13915b689a8d', 'Tillväxtverket — Utlysningar', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.392678+00'),
	('eb432f5d-0999-43b7-9f2c-dbbc3f201517', 'd3a4ef8a-3762-4da9-a832-a8421bbcf595', 'Energimyndigheten — Alla utlysningar', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.394402+00'),
	('8fcc8e09-bb9f-46f5-a56a-90c2e6c2d213', '58d0414d-119a-4f14-b1a2-01668af0297f', 'Naturvårdsverket — Bidrag', 'https://www.naturvardsverket.se/bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.395787+00'),
	('876afae4-dfb9-4f44-b01d-d657f6bfc097', 'cca68a01-b5f4-4c44-9d7e-0316efa9b733', 'Svenska ESF-rådet — Utlysningsplan', 'https://www.esf.se/utlysningar/utlysningsplan/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.397167+00'),
	('be916037-f790-4c4d-827e-034ebceffeed', '5324fe9f-2625-4ee3-9ade-e690b048dd35', 'Erasmus+ — Youth exchanges', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.398696+00'),
	('23956d5f-6f03-4bfc-9c2a-2fa3a17fd7e9', 'cb27acf1-f164-47fe-8c9e-c3f3d5f2c63d', 'Konstnärsnämnden — Stipendier och bidrag', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.40009+00'),
	('a3bdcb49-1b06-4af9-804c-9208d1fc9ea5', 'ad6073c0-efaf-4f0c-87ed-394cf15f8369', 'Allmänna arvsfonden — Söka pengar', 'https://www.arvsfonden.se/soka-pengar', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.401614+00'),
	('906c2cd7-09e3-4d97-b7e6-d47d6f56118b', 'a160a2aa-5ce4-442f-a656-9f0214ddc676', 'Boverket — Bidrag och stöd', 'https://www.boverket.se/sv/bidrag--garantier/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.403686+00'),
	('229ee644-4f20-4299-bd96-fa8995b9512c', '4ae0a05d-106c-4ec8-9097-a4b3c81f25aa', 'Riksidrottsförbundet — Ekonomiskt stöd', 'https://www.rf.se/bidrag-och-stod', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.405318+00'),
	('428ad22b-42d9-4da0-bd2f-bc84eb5769f9', '713c0c5a-418d-4713-88e3-ca4b7ca03919', 'Svenska Filminstitutet — Stöd', 'https://www.filminstitutet.se/sv/sok-stod/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.406833+00'),
	('789eaf04-6281-4ed5-b51e-a179cc31aeea', '738eed1c-eac6-475d-95bd-a3790565a559', 'Formas — Utlysningar', 'https://www.formas.se/soka-finansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.408222+00'),
	('7c518b3f-dc45-4dca-a0f7-6389ae83dd5b', 'a4392274-1c63-4de7-9227-bc612fbf2939', 'UHR — Erasmus+ utbildning', 'https://www.uhr.se/internationella-mojligheter/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.409663+00'),
	('8fd37e0b-0c20-43cb-ae2a-f8a0a8a0fe8c', '014cef2e-6d22-41ef-805e-5496d4cef9bc', 'Försäkringskassan — Privatperson', 'https://www.forsakringskassan.se/privatperson', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.411096+00'),
	('bc9ee322-f144-46dd-890c-23e815cfdc7a', '0ef7acfa-9322-4818-9f67-b920daa08581', 'CSN — Studiemedel', 'https://www.csn.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.412401+00'),
	('56a08fcd-c2f5-4344-8f91-b126bf54b285', 'd136ab5a-1fba-410f-a96e-3fd26f446c31', 'Pensionsmyndigheten — Stöd och bidrag', 'https://www.pensionsmyndigheten.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.413639+00'),
	('1979f0fb-447b-4806-84f3-c9d01d14a676', '0c3fab7d-16ce-4e8e-a526-145053a0c8d5', 'Socialstyrelsen — Ekonomiskt bistånd', 'https://www.socialstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.415026+00'),
	('ca8f4df0-05a5-4720-abb9-852cc3b7dd9c', 'e908b93d-0526-467c-a510-235ec0c217ab', '1177 — Bidrag för glasögon till barn och unga', 'https://www.1177.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.416231+00'),
	('12c0ac62-8581-4d6a-8a9a-2eba3f6f3aa7', '7c223625-c6cf-49bb-94ec-0a50c07b5576', 'Majblomman — Ansök om bidrag', 'https://majblomman.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.417615+00'),
	('6041c394-ddb7-49b1-8d59-44213c116f4a', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'Skolverket — Skolskjuts', 'https://www.skolverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.418933+00'),
	('54c4c8c0-c808-4e45-bdfb-9ab953aeceb2', '0ba4b173-46d7-411c-a30f-1d2bf857c2b8', 'Lag (1991:1110) om kommunernas skyldighet att svara för vissa elevresor', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.4202+00'),
	('c3959729-46d2-492f-94d3-ae4c8d1703a0', '87b7ca1e-f240-4dc6-806f-7299a90d0d9f', 'Arbetsförmedlingen — Stöd och bidrag', 'https://arbetsformedlingen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.421493+00'),
	('f09be294-446e-4121-b8ca-eb87c4bbf597', 'aeb2eb40-63ff-4bdc-aa1f-7a31a946ef3c', 'Sveriges a-kassor — Så fungerar a-kassan', 'https://www.sverigesakassor.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.423014+00'),
	('50c21a38-27dd-47d9-9688-4b32b8575a12', 'fea1ecec-978c-4a2c-b646-4b448ef3ba14', 'Migrationsverket — Återvandring', 'https://www.migrationsverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.425162+00'),
	('7dc08288-fb83-4363-913f-ed5cbd3ba4cc', '86d2ddcc-9d26-4927-80f2-4671d7bfe833', 'Riksantikvarieämbetet — Bidrag', 'https://www.raa.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.426761+00'),
	('adb2a3dc-635c-407f-8a44-0c2c11b73b50', '3afd736e-6538-41a9-80a3-5e2469ee928b', 'Svenska institutet — Utlysningar', 'https://si.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.428074+00'),
	('4b28b12f-a87c-4bd7-87a7-2534e51e6f65', '4bc38c33-8fa0-4b0c-b50d-fd15992bd0db', 'Nordisk kulturfond — Støtte', 'https://www.nordiskkulturfond.org/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.429578+00'),
	('cbf004c3-9c86-483e-b5bf-857eb6da3c20', '1a3a4fea-4170-4f67-afbe-69782a79c836', 'Vetenskapsrådet — Utlysningar', 'https://www.vr.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.43109+00'),
	('e4534d9c-f899-4d64-b82b-aeb2ab7ee25e', '1287f5d9-dff5-44ae-a7d8-45c8831165af', 'Postkodstiftelsen — Ansök om stöd', 'https://postkodstiftelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.432412+00'),
	('19f7c0a9-1192-4259-b2a5-2204262a4b3d', '1159e72d-a5e4-411b-971e-2e8643f36ff4', 'Musikverket — Bidrag', 'https://musikverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.433664+00'),
	('dbc46770-3017-4b61-9089-5529a80d201d', '9b17149a-f39f-4b7e-b63f-c5ea60acc35a', 'Länsstyrelserna — Stöd och bidrag', 'https://www.lansstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.434994+00'),
	('d02a6acf-79eb-4945-b62f-cfd9463c22a8', 'dc409620-c5bc-4ca7-9266-8311ac367d87', 'Forte — Utlysningar', 'https://forte.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.436272+00'),
	('840129c9-e965-48ea-ba84-0225a41971b8', '85f53dd8-7fdb-46d0-8f2b-4c980dec62af', 'Sparbankernas Riksförbund — Sparbanksstiftelser', 'https://www.sparbankerna.se/', 'html', 'B', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.437569+00'),
	('69eb686f-486c-4d2e-a7f6-5b609f076e8d', 'a8b1caea-e4d3-42e8-a450-c0259f491585', 'Radiohjälpen — Söka bidrag', 'https://www.radiohjalpen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.438867+00'),
	('1e7f3594-2df7-46a7-a196-152d7ac27908', '3b945b80-de20-4135-be2a-5408dc8c676b', 'Jordbruksverket — Stöd', 'https://jordbruksverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-29 00:51:26.440211+00');


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

SELECT pg_catalog.setval('drizzle.__drizzle_migrations_id_seq', 15, true);


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


