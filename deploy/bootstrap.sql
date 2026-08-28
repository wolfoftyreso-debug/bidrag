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
	('b6622c27-cf5a-4df3-87cd-6fa130af717d', '25fc0003-928b-4c7d-955f-3e152571b59c', 1, '{"id": "kulturradet-resebidrag-v1", "title": "Ansökan — Resebidrag för internationellt kulturutbyte", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "sokande_verksamhet", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "guidance": "T.ex. dans, musik, scenkonst.", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv resan och utbytet", "section": "projekt", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_land", "type": "text", "label": "Resmål (land)", "section": "projekt", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "projekt_datum", "type": "date_range", "label": "Resperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Har du en inbjudan eller bekräftelse från mottagande part?", "section": "projekt", "required": true}, {"key": "inbjudan_beskrivning", "type": "long_text", "label": "Beskriv inbjudan/samarbetet", "section": "projekt", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_inbjudan"}]}, {"key": "aterforing", "type": "long_text", "label": "Hur tar du tillvara erfarenheterna i Sverige?", "section": "projekt", "required": true, "maxLength": 2000, "canonicalKey": "project.knowledgeTransferPlan"}, {"key": "sokt_belopp", "max": 50000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig som söker"}, {"key": "projekt", "title": "Resan och utbytet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.193435+00'),
	('d4733783-3150-4f9c-b8c2-9934cce73684', 'd9899e9c-35a4-4278-aaae-07c1994ebcd4', 1, '{"id": "erasmus-ungdomsutbyte-v1", "title": "Ansökan — Erasmus+ Ungdomsutbyte (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System med EU Login.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv utbytet", "section": "projekt", "guidance": "Tema, aktiviteter och förväntat lärande.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Utbytesperiod (exklusive resdagar)", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "antal_deltagare", "max": 200, "min": 4, "type": "number", "label": "Antal deltagare", "section": "deltagare", "required": true}, {"key": "har_partner", "type": "boolean", "label": "Har ni en bekräftad partnergrupp i ett annat land?", "section": "deltagare", "required": true}, {"key": "partner_namn", "type": "text", "label": "Partnergruppens namn och land", "section": "deltagare", "required": true, "maxLength": 300, "visibleWhen": [{"op": "is_true", "factPath": "har_partner"}], "canonicalKey": "project.partnerName"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Utbytet"}, {"key": "deltagare", "title": "Deltagare och partner"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.19575+00'),
	('8e41c5bd-fe28-43c1-b0e0-e330d14ae6e5', '8f3ec4cc-9ead-43cc-a03f-d2ae3978d1de', 1, '{"id": "nordisk-kulturfond-projektstod-v1", "title": "Ansökan — Nordisk kulturfond, projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller organisation)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_titel", "type": "text", "label": "Projektets titel", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska ni göra, varför, och vad är den konstnärliga/kulturella idén?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "nordiska_lander", "type": "multiselect", "label": "Vilka nordiska länder deltar aktivt i projektet?", "options": [{"label": "Sverige", "value": "SE"}, {"label": "Danmark", "value": "DK"}, {"label": "Norge", "value": "NO"}, {"label": "Finland", "value": "FI"}, {"label": "Island", "value": "IS"}, {"label": "Grönland", "value": "GL"}, {"label": "Färöarna", "value": "FO"}, {"label": "Åland", "value": "AX"}], "section": "norden", "guidance": "Fonden kräver samarbete mellan flera nordiska länder — ange de länder som har en aktiv roll.", "required": true}, {"key": "nordisk_dimension", "type": "long_text", "label": "Vad tillför det nordiska samarbetet projektet?", "section": "norden", "guidance": "Konkret: vad händer i samarbetet som inte hade hänt nationellt?", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig/er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "norden", "title": "Nordisk dimension"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.197832+00'),
	('19011e19-e73f-4c8b-9d7b-ea3ded9fd407', 'eb518f74-aa9d-46da-9cf5-06261125137a', 1, '{"id": "mucf-projektbidrag-v1", "title": "Ansökan — MUCF projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_syfte", "type": "long_text", "label": "Syfte och genomförande", "section": "projekt", "guidance": "Vilket problem adresserar projektet, vad ska ni göra, och hur vet ni att det fungerat?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka unga når projektet, och hur är de delaktiga?", "section": "malgrupp", "guidance": "Ungas egen delaktighet i planering och genomförande väger tungt i bedömningen.", "required": true, "maxLength": 3000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.19982+00'),
	('f60d7a87-ae82-4a0c-b860-2bdc2b9b0ed7', 'fbc83baa-c179-4be7-b960-d11b95eb9681', 1, '{"id": "kommun-forsorjningsstod-v1", "title": "Ansökan — Försörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "hushall_vuxna", "max": 10, "min": 1, "type": "number", "label": "Antal vuxna i hushållet", "section": "hushall", "required": true, "canonicalKey": "person.householdAdults"}, {"key": "hushall_barn", "max": 15, "min": 0, "type": "number", "label": "Antal barn som bor hemma", "section": "hushall", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "inkomst_manad", "min": 0, "type": "currency", "label": "Hushållets inkomster per månad (kr)", "section": "ekonomi", "guidance": "Räkna ihop lön, ersättningar och bidrag före skatt. Ungefärligt räcker i förberedelsen — kommunen begär exakta underlag.", "required": true, "canonicalKey": "person.monthlyHouseholdIncome"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har hushållet sparade medel eller tillgångar som kan användas till försörjningen?", "section": "ekonomi", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna", "section": "ekonomi", "guidance": "T.ex. sparkonto, bil, värdepapper. Kommunen prövar alltid tillgångar först — att redovisa dem öppet undviker kompletteringar.", "required": true, "maxLength": 2000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "behov_beskrivning", "type": "long_text", "label": "Beskriv din situation och vad du behöver stöd till", "section": "behov", "guidance": "Konkret: vad har hänt, vad räcker inte pengarna till, och vad gör du själv för att förändra situationen?", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hushall", "title": "Hushållet"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "behov", "title": "Din situation"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.201611+00'),
	('532773af-03f9-4870-b63f-25196aece31d', '7de4083c-e86d-46dd-9a68-8fda8e4c70e8', 1, '{"id": "fk-bostadsbidrag-barnfamiljer-v1", "title": "Ansökan — Bostadsbidrag till barnfamiljer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hemma (helt eller växelvis)", "section": "sokande", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 500, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "guidance": "Bidraget beräknas delvis på ytan — siffran står i hyresavtalet.", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Hushållets beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bostadsbidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav. Ta i lite uppåt hellre än neråt.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.203617+00'),
	('a431726c-a791-4fa4-92ad-aecf5366d1b5', '1fab4f8c-e89d-45fc-b587-dcbf84c25791', 1, '{"id": "majblomman-bidrag-barn-v1", "title": "Ansökan — Majblomman, bidrag till barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "behov_vad", "type": "long_text", "label": "Vad söker ni bidrag för?", "section": "behov", "guidance": "Något konkret som gör skillnad för barnet: en fritidsaktivitet, kläder, utrustning, en cykel. Majblomman ger till barnet, inte till hushållets löpande utgifter.", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "max": 20000, "min": 1, "type": "currency", "label": "Ungefärligt belopp (kr)", "section": "behov", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "situation", "type": "long_text", "label": "Beskriv kort familjens situation", "section": "behov", "guidance": "Varför räcker pengarna inte till det här just nu? Kortfattat räcker.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet"}, {"key": "behov", "title": "Vad ni söker för"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.205811+00'),
	('ae575feb-628c-431a-a420-65f0ffb49c52', '466d2f40-862e-4bc3-9925-99aa9026a490', 1, '{"id": "af-stod-start-naringsverksamhet-v1", "title": "Ansökan — Stöd till start av näringsverksamhet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?", "section": "sokande", "guidance": "Stödet förutsätter inskrivning — beslutet fattas av din handläggare.", "required": true}, {"key": "affarside", "type": "long_text", "label": "Beskriv affärsidén", "section": "verksamhet", "guidance": "Vad ska du sälja, till vem, och varför finns det efterfrågan? Konkreta belägg (kundkontakter, erfarenhet, marknadskännedom) väger tyngre än visioner.", "required": true, "maxLength": 4000}, {"key": "verksamhet_start", "type": "date", "label": "Planerad start", "section": "plan", "required": true}, {"key": "har_affarsplan", "type": "boolean", "label": "Har du en skriftlig affärsplan?", "section": "plan", "required": true}, {"key": "forsorjning", "type": "long_text", "label": "Hur försörjer du dig under uppstarten?", "section": "plan", "guidance": "Aktivitetsstödet är tidsbegränsat — visa att kalkylen håller tills verksamheten bär sig.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Affärsidén"}, {"key": "plan", "title": "Planen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.207517+00'),
	('9e65978c-8962-494a-9438-e685a4ae66b8', '56f4edd5-3f05-4168-8302-e882071ab6e8', 1, '{"id": "kulturradet-projektbidrag-musik-v1", "title": "Ansökan — Kulturrådet, projektbidrag musik (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "guidance": "Tio siffror. Kontrollsiffran valideras — ett felskrivet nummer är en vanlig avslagsorsak på formalia.", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_sammanfattning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad ska genomföras, av vem, för vilken publik — och vad skiljer det från er ordinarie verksamhet?", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ovrig_finansiering", "type": "long_text", "label": "Beskriv övrig finansiering", "section": "budget", "guidance": "Egna medel, andra bidrag, intäkter. Lämna tomt om allt söks här.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.209268+00'),
	('2a8f4a96-9df2-4fa0-a9d1-3a2927e4dc9f', '80f5a94c-4c90-4bb8-93a1-fe4a319ffa6b', 1, '{"id": "fk-bostadsbidrag-unga-v1", "title": "Ansökan — Bostadsbidrag för unga (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "guidance": "Hyra eller månadskostnad inklusive uppvärmning.", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "boyta", "max": 300, "min": 5, "type": "number", "label": "Bostadens yta (kvm)", "section": "boende", "required": true}, {"key": "inkomst_ar", "min": 0, "type": "currency", "label": "Din beräknade inkomst i år, före skatt (kr)", "section": "ekonomi", "guidance": "Bidraget stäms av mot årsinkomsten i efterhand — en för låg uppskattning kan ge återkrav.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Inkomster"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.210965+00'),
	('1d31cc2c-deed-4f56-9bb0-ab6126fa1237', 'e619e017-66eb-4f25-adce-25802f110dc5', 1, '{"id": "fk-underhallsstod-v1", "title": "Ansökan — Underhållsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_hemma", "max": 15, "min": 1, "type": "number", "label": "Antal barn som bor hos dig", "section": "barnen", "required": true, "canonicalKey": "person.childrenAtHomeCount"}, {"key": "underhall_idag", "type": "long_text", "label": "Hur fungerar underhållet i dag?", "section": "underhall", "guidance": "Betalar den andra föräldern inget, för lite eller oregelbundet? Konkret — det avgör vilken väg Försäkringskassan tar.", "required": true, "maxLength": 2000}, {"key": "har_avtal", "type": "boolean", "label": "Finns avtal eller dom om underhållsbidrag?", "section": "underhall", "required": true}, {"key": "avtal_beskrivning", "type": "long_text", "label": "Beskriv avtalet/domen kort", "section": "underhall", "guidance": "Belopp och datum räcker — dokumentet kan bifogas hos Försäkringskassan.", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_avtal"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnen", "title": "Barnen"}, {"key": "underhall", "title": "Underhållet i dag"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.212601+00'),
	('1724b127-997c-44b5-9b3d-1f46f32a8f47', 'cd9b3d16-30ea-465c-ac09-cbce111bd03d', 1, '{"id": "pm-bostadstillagg-v1", "title": "Ansökan — Bostadstillägg för pensionärer (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "boende", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Allmän pension, tjänstepension och eventuell utländsk pension — sammanlagt.", "required": true}, {"key": "har_kapital", "type": "boolean", "label": "Har du sparade medel eller tillgångar över ungefär 100 000 kr?", "section": "ekonomi", "guidance": "Kapital påverkar bostadstilläggets storlek — att redovisa det öppet undviker återkrav.", "required": true}, {"key": "kapital_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_kapital"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "boende", "title": "Bostaden"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.214177+00'),
	('8639a2dc-15ba-4cf7-8f7f-0f2f2b01f6a3', 'fe2a56a0-9de3-4c6b-a3ed-aecdc39a3761', 1, '{"id": "region-glasogonbidrag-barn-v1", "title": "Ansökan — Glasögonbidrag för barn (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 19, "min": 8, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "har_ordination", "type": "boolean", "label": "Finns ordination eller recept från optiker/ögonläkare?", "section": "barnet", "guidance": "Ordinationen är regionens underlag — utan den kan bidraget inte betalas ut.", "required": true}, {"key": "kostnad", "max": 10000, "min": 1, "type": "currency", "label": "Kostnad för glasögon eller linser (kr)", "section": "barnet", "guidance": "Bidragets tak varierar mellan regioner — hela kostnaden ersätts inte alltid.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och synbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.216057+00'),
	('3ee3707b-3a56-4eed-92fb-22edb8fe3774', '4a4f671b-ab38-4dab-8f51-9bc2102a5fa6', 1, '{"id": "kommun-skolskjuts-v1", "title": "Ansökan — Skolskjuts (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skolans namn", "section": "eleven", "required": true, "maxLength": 200}, {"key": "arskurs", "type": "text", "label": "Årskurs", "section": "eleven", "guidance": "Kommunens avståndsgräns skiljer sig ofta per årskurs.", "required": true, "maxLength": 20}, {"key": "avstand_km", "max": 200, "min": 0, "type": "number", "label": "Avstånd hem–skola (km)", "section": "eleven", "required": true}, {"key": "skal", "type": "long_text", "label": "Varför behövs skolskjuts?", "section": "eleven", "guidance": "Konkret: avståndet, en trafikfarlig passage, funktionsnedsättning eller växelvis boende. Kommunen prövar mot sina riktlinjer.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och skolvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.217883+00'),
	('1834b8fe-8ae2-4e73-a3c0-8cb31e95f49d', 'cd523901-ba90-46de-82a5-10b9a1a30403', 1, '{"id": "arvsfonden-projektstod-v1", "title": "Ansökan — Arvsfonden projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_titel", "type": "text", "label": "Projektets namn", "section": "projekt", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Vad är nyskapande jämfört med er ordinarie verksamhet? Arvsfonden finansierar inte mer av det ni redan gör.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "malgrupp_delaktighet", "type": "long_text", "label": "Hur är målgruppen delaktig i planering och genomförande?", "section": "malgrupp", "guidance": "Delaktigheten är ett skarpt krav — beskriv mekanismen, inte avsikten: vem ur målgruppen gör vad?", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "overlevnad", "type": "long_text", "label": "Hur lever verksamheten vidare efter projektet?", "section": "budget", "guidance": "Arvsfonden kräver en överlevnadsplan: vem tar över, vem betalar, vad består?", "required": true, "maxLength": 2000}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "malgrupp", "title": "Målgrupp och delaktighet"}, {"key": "budget", "title": "Budget och överlevnad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.219831+00'),
	('8ef6fdf1-0d90-4279-a170-60e5e91602fa', 'e680dd41-94d3-49c4-9820-ee1e6d1484b6', 1, '{"id": "csn-studiemedel-v1", "title": "Ansökan — Studiemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "utbildning", "type": "text", "label": "Utbildning och skola", "section": "studier", "guidance": "T.ex. \"Sjuksköterskeprogrammet, Umeå universitet\".", "required": true, "maxLength": 300}, {"key": "studietakt", "type": "select", "label": "Studietakt", "options": [{"label": "Heltid (100 %)", "value": "100"}, {"label": "75 %", "value": "75"}, {"label": "Halvtid (50 %)", "value": "50"}], "section": "studier", "required": true}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod du söker för", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "vill_lana", "type": "boolean", "label": "Vill du även ta studielån (utöver bidraget)?", "section": "ekonomi", "guidance": "Lånedelen är frivillig och kan väljas per vecka — det går att ångra sig senare.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "ekonomi", "title": "Bidrag och lån"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.222178+00'),
	('a5541002-e287-434d-91f9-e9dceefdb005', '67621f48-caa3-4a16-9e32-db010748c2e0', 1, '{"id": "fk-aktivitetsersattning-v1", "title": "Ansökan — Aktivitetsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "nedsattning_beskrivning", "type": "long_text", "label": "Beskriv hur arbetsförmågan är nedsatt", "section": "halsa", "guidance": "Med egna ord: vad klarar du inte i dag som ett arbete kräver? Försäkringskassan gör alltid den medicinska prövningen — din beskrivning ska stämma med läkarintyget, inte ersätta det.", "required": true, "maxLength": 4000}, {"key": "har_lakarintyg", "type": "boolean", "label": "Finns ett aktuellt läkarintyg eller läkarutlåtande?", "section": "halsa", "guidance": "Läkarutlåtandet är det centrala underlaget — ansökan utan det leder nästan alltid till komplettering.", "required": true}, {"key": "pagaende_insatser", "type": "long_text", "label": "Pågående vård eller insatser", "section": "halsa", "guidance": "T.ex. behandling, rehabilitering, daglig verksamhet. Lämna tomt om inget pågår.", "required": false, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "halsa", "title": "Arbetsförmågan"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.224976+00'),
	('4e57b61e-5fa3-425f-8d9a-229492bc17d8', 'c1a8f6f0-37a6-4ee9-8153-29890616e961', 1, '{"id": "pm-aldreforsorjningsstod-v1", "title": "Ansökan — Äldreförsörjningsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "pension_manad", "min": 0, "type": "currency", "label": "Pension per månad före skatt (kr)", "section": "ekonomi", "guidance": "Alla pensioner sammanlagt — även utländsk pension räknas.", "required": true}, {"key": "ovriga_inkomster", "min": 0, "type": "currency", "label": "Övriga inkomster per månad (kr)", "section": "ekonomi", "required": false}, {"key": "boendekostnad", "min": 0, "type": "currency", "label": "Boendekostnad per månad (kr)", "section": "ekonomi", "required": true, "canonicalKey": "person.housingCostMonthly"}, {"key": "har_tillgangar", "type": "boolean", "label": "Har du sparade medel eller tillgångar?", "section": "ekonomi", "guidance": "Tillgångar påverkar prövningen — öppen redovisning undviker återkrav.", "required": true}, {"key": "tillgangar_beskrivning", "type": "long_text", "label": "Beskriv tillgångarna kort", "section": "ekonomi", "required": true, "maxLength": 1000, "visibleWhen": [{"op": "is_true", "factPath": "har_tillgangar"}]}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "ekonomi", "title": "Ekonomi per månad"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.227141+00'),
	('6a4357ff-770e-45f2-bd1e-45022da19048', '0b267398-f0fc-4518-a7f0-9c81dfb92e6e', 1, '{"id": "kommun-elevresor-gymnasiet-v1", "title": "Ansökan — Elevresor gymnasiet (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (elev eller vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Gymnasieskolans namn och ort", "section": "eleven", "required": true, "maxLength": 200}, {"key": "avstand_km", "max": 300, "min": 0, "type": "number", "label": "Resväg hem–skola (km)", "section": "eleven", "guidance": "Gränsen är normalt sex kilometer närmaste väg.", "required": true}, {"key": "har_studiehjalp", "type": "boolean", "label": "Har eleven studiehjälp från CSN?", "section": "eleven", "guidance": "Elevresestödet förutsätter studiehjälp — den kommer automatiskt för de flesta gymnasieelever under 20.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "eleven", "title": "Eleven och resvägen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.229086+00'),
	('e1dbcd84-4f60-4423-8cd2-fed7401b96c0', '8a676a8e-9dbb-44e5-8b1c-81cc00d6f4ef', 1, '{"id": "kommun-bostadsanpassningsbidrag-v1", "title": "Ansökan — Bostadsanpassningsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen och hur den påverkar boendet", "section": "behov", "guidance": "Konkret ur vardagen: trösklar, trappor, badrum. Intyg från arbetsterapeut eller läkare styrker behovet.", "required": true, "maxLength": 3000}, {"key": "anpassning", "type": "long_text", "label": "Vilken anpassning söker du bidrag för?", "section": "behov", "guidance": "T.ex. ramp vid entrén, borttagna trösklar, dörrautomatik, anpassat badrum.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "behov", "guidance": "Offert från entreprenör räcker — kommunen kan begära fler.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "har_intyg", "type": "boolean", "label": "Finns intyg från arbetsterapeut, läkare eller annan sakkunnig?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Behovet och anpassningen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.231068+00'),
	('2e11ca56-5a32-48bb-b587-f354f094934d', 'f03a86f0-1368-4293-8016-10b8ce58b9ab', 1, '{"id": "csn-omstallningsstudiestod-v1", "title": "Ansökan — Omställningsstudiestöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "arbetsliv_ar", "max": 50, "min": 0, "type": "number", "label": "Ungefär hur många år har du arbetat (minst 16 h/vecka)?", "section": "arbetsliv", "guidance": "Kravet är i genomsnitt minst 16 timmar i veckan under minst 8 år.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du planerar", "section": "studier", "required": true, "maxLength": 300}, {"key": "starkning_beskrivning", "type": "long_text", "label": "Hur stärker utbildningen din ställning på arbetsmarknaden?", "section": "studier", "guidance": "Det här är prövningens kärna: koppla utbildningen till faktisk efterfrågan — en bransch som rekryterar, en roll din arbetsgivare behöver. Söktrycket är högt och generiska motiveringar sållas bort.", "required": true, "maxLength": 4000}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "arbetsliv", "title": "Ditt arbetsliv"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.232831+00'),
	('20dd6414-008b-4564-93cd-472c733b8a8a', '8b364654-fd29-417b-9e7b-d64d35924bf0', 1, '{"id": "vinnova-innovativa-startups-v1", "title": "Ansökan — Vinnova Innovativa startups (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Bolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "losning_beskrivning", "type": "long_text", "label": "Beskriv lösningen och vad som är nyskapande", "section": "losning", "guidance": "Vad finns i dag, och vad gör er lösning väsentligt bättre? Vinnova jämför mot faktiska alternativ — belägg väger tyngre än vision.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "kundbevis", "type": "long_text", "label": "Vilka belägg finns för efterfrågan?", "section": "marknad", "guidance": "Kunddialoger, piloter, avsiktsförklaringar, betalande användare — det ni faktiskt har.", "required": true, "maxLength": 3000}, {"key": "team_beskrivning", "type": "long_text", "label": "Teamet och dess förmåga att genomföra", "section": "marknad", "guidance": "Roller, relevant erfarenhet och hur mycket tid nyckelpersonerna lägger.", "required": true, "maxLength": 2000}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "budget", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "max": 300000, "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Bolaget"}, {"key": "losning", "title": "Lösningen"}, {"key": "marknad", "title": "Marknad och team"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.234772+00'),
	('79f3d693-ea20-43d9-aa76-78538a3f0ad7', '453a03ca-a7a2-4872-bc21-521d33eeeba8', 1, '{"id": "tillvaxtverket-affarsutvecklingscheckar-v1", "title": "Ansökan — Affärsutvecklingscheck (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_anstallda", "max": 500, "min": 0, "type": "number", "label": "Antal anställda", "section": "foretag", "guidance": "Checkarna riktar sig typiskt till företag med 2–49 anställda — regionens villkor styr.", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv utvecklingsinsatsen", "section": "insats", "guidance": "Vad ska den externa kompetensen göra, och vad ska vara annorlunda i företaget efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "extern_leverantor", "type": "text", "label": "Extern leverantör/konsult (om känd)", "section": "insats", "required": false, "maxLength": 200}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "guidance": "Checken täcker normalt högst hälften av kostnaden — resten är egen insats.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "budget", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "budget", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "insats", "title": "Utvecklingsinsatsen"}, {"key": "budget", "title": "Kostnad och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.237088+00'),
	('33278364-6d94-47e0-9bc8-8d80b7a6451a', '27c88920-3da6-4d1e-96bf-8e58253d0942', 1, '{"id": "tillvaxtverket-regionalt-investeringsstod-v1", "title": "Ansökan — Regionalt investeringsstöd (förberedelse)", "fields": [{"key": "foretag_namn", "type": "text", "label": "Företagets namn", "section": "foretag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "foretag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsort", "type": "text", "label": "Verksamhetsort (kommun)", "section": "foretag", "guidance": "Orten avgör stödområdestillhörigheten (A/B) och därmed stödnivån.", "required": true, "maxLength": 100}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Byggnader, maskiner eller inventarier — och hur investeringen ökar sysselsättningen eller konkurrenskraften på orten.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjas före ansökan", "section": "investering", "guidance": "En påbörjad investering diskvalificerar hela ansökan — beställ inget förrän ansökan är inne.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "investering", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "investering", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "foretag", "title": "Företaget"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.239102+00'),
	('59041c78-14a5-421f-b82a-b53c6528a96e', '9ca04c8f-d0ff-4aec-90f0-cc245a1a3a08', 1, '{"id": "jordbruksverket-startstod-unga-v1", "title": "Ansökan — Startstöd unga jordbrukare (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten", "section": "foretaget", "guidance": "Inriktning (växtodling, djurhållning, trädgård, rennäring), omfattning och om du startar nytt eller tar över.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "overtagande_datum", "type": "date", "label": "Datum för start eller övertagande", "section": "foretaget", "required": true}, {"key": "utbildning_erfarenhet", "type": "long_text", "label": "Din utbildning och erfarenhet inom området", "section": "plan", "guidance": "Naturbruksutbildning, kurser eller praktisk erfarenhet — kravet kan uppfyllas på flera sätt.", "required": true, "maxLength": 2000}, {"key": "har_affarsplan", "type": "boolean", "label": "Finns en skriftlig affärsplan?", "section": "plan", "guidance": "Affärsplanen är obligatorisk bilaga hos Jordbruksverket.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "foretaget", "title": "Företaget du startar eller tar över"}, {"key": "plan", "title": "Affärsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.240995+00'),
	('e3959302-f074-4b2e-a547-8cab3b1f2bda', 'be537cef-44f7-475b-b728-2f95a43b3af6', 1, '{"id": "jordbruksverket-investeringsstod-v1", "title": "Ansökan — Investeringsstöd jordbruk (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn (person eller företag)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "investering_beskrivning", "type": "long_text", "label": "Beskriv investeringen", "section": "investering", "guidance": "Vad ska byggas eller köpas, och hur stärker det verksamheten (produktion, djurvälfärd, miljö, energi)?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad investeringskostnad (kr)", "section": "investering", "guidance": "Offerter styrker kalkylen — stödandelen räknas på faktiska kostnader.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att investeringen inte påbörjats före ansökan", "section": "investering", "required": true}, {"key": "de_minimis_mottaget", "type": "boolean", "label": "Har företaget tagit emot försumbart stöd (de minimis) under de senaste tre åren?", "section": "investering", "guidance": "De flesta mindre företagsstöd är de minimis-stöd. Taket är 300 000 euro per treårsperiod — nytt stöd över taket är otillåtet, och uppgiften intygas på heder och samvete hos finansiären.", "required": true}, {"key": "de_minimis_belopp", "min": 0, "type": "currency", "label": "Sammanlagt de minimis-stöd senaste tre åren (kr)", "section": "investering", "guidance": "Summera besluten — beloppen står i respektive stödbeslut.", "required": true, "visibleWhen": [{"op": "is_true", "factPath": "de_minimis_mottaget"}], "canonicalKey": "organisation.deMinimisTotal"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "investering", "title": "Investeringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.242969+00'),
	('c08d9eee-65b8-457d-a13b-4b0133be0aba', '835a3969-745e-4083-a450-5463c3797743', 1, '{"id": "rf-lok-stod-v1", "title": "Ansökan — LOK-stöd (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "forbund", "type": "text", "label": "Specialidrottsförbund", "section": "forening", "guidance": "T.ex. Svenska Fotbollförbundet — anslutningen är ett krav.", "required": true, "maxLength": 200}, {"key": "antal_aktiviteter", "max": 10000, "min": 1, "type": "number", "label": "Ungefärligt antal gruppaktiviteter per termin (deltagare 7–25 år)", "section": "verksamhet", "guidance": "LOK-stödet räknas per genomförd gruppaktivitet och deltagare — närvaroregistrering i IdrottOnline är underlaget.", "required": true}, {"key": "registrerar_narvaro", "type": "boolean", "label": "Registrerar föreningen närvaro digitalt (t.ex. IdrottOnline)?", "section": "verksamhet", "guidance": "Utan närvaroregistrering kan stödet inte betalas ut — börja registrera innan perioden ansöks.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Föreningen"}, {"key": "verksamhet", "title": "Aktiviteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.244884+00'),
	('ddbf661b-a958-412c-b734-b20faebd94ab', '2e66a1f4-3dfc-403e-a301-415ec8f82ba3', 1, '{"id": "kulturradet-skapande-skola-v1", "title": "Ansökan — Skapande skola (förberedelse)", "fields": [{"key": "huvudman_namn", "type": "text", "label": "Huvudmannens namn", "section": "huvudman", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "huvudman", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_elever", "max": 100000, "min": 1, "type": "number", "label": "Antal elever som omfattas", "section": "insatser", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv kulturinsatserna", "section": "insatser", "guidance": "Vilka professionella kulturaktörer, vilka konstformer, och hur eleverna är delaktiga — inte bara publik.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "lasar_period", "type": "date_range", "label": "Period (läsår)", "section": "insatser", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "huvudman", "title": "Huvudmannen"}, {"key": "insatser", "title": "Kulturinsatserna"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.24693+00'),
	('b029f0d4-adc9-4476-ab62-28f50b6ad2c3', 'ff1627ab-4213-488c-8741-e2da57c960f0', 1, '{"id": "konstnarsnamnden-internationellt-kulturutbyte-v1", "title": "Ansökan — Internationellt kulturutbyte (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstnärlig verksamhet", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "utbyte_beskrivning", "type": "long_text", "label": "Beskriv utbytet", "section": "utbyte", "guidance": "Vad ska du göra, med vem, och varför är det viktigt för din konstnärliga utveckling just nu?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utbyte_period", "type": "date_range", "label": "Period", "section": "utbyte", "required": true, "canonicalKey": "project.dateRange"}, {"key": "har_inbjudan", "type": "boolean", "label": "Finns en inbjudan eller bekräftelse från mottagande part?", "section": "utbyte", "guidance": "Inbjudan väger tungt — utan den bedöms utbytet som oplanerat.", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "utbyte", "title": "Utbytet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.248879+00'),
	('fea7bdfe-db6d-4e52-8ca4-e506865ca6a4', '8202cbd8-dd2a-4d59-a168-74a680a64406', 1, '{"id": "filminstitutet-kortfilmsstod-v1", "title": "Ansökan — Kortfilmsstöd (förberedelse)", "fields": [{"key": "bolag_namn", "type": "text", "label": "Produktionsbolagets namn", "section": "bolag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "bolag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "film_titel", "type": "text", "label": "Filmens arbetstitel", "section": "film", "required": true, "maxLength": 200, "canonicalKey": "project.title"}, {"key": "synopsis", "type": "long_text", "label": "Synopsis och konstnärlig vision", "section": "film", "guidance": "Berättelsen, formen och varför den här filmen behöver göras — konsulenten läser hundratals, det specifika bär.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "regissor", "type": "text", "label": "Regissör och tidigare verk", "section": "film", "required": true, "maxLength": 300}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "bolag", "title": "Produktionsbolaget"}, {"key": "film", "title": "Filmen"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.250685+00'),
	('267ebe6b-b401-47ff-9832-5bb6f7518eb7', '8f509009-0626-497d-9b38-b478caea158a', 1, '{"id": "musikverket-projektbidrag-v1", "title": "Ansökan — Musikverket projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv musikprojektet", "section": "projekt", "guidance": "Vad ska göras, av vilka, och vad tillför det musiklivet utöver er egen verksamhet?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "medverkande", "type": "long_text", "label": "Medverkande musiker/aktörer", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.252411+00'),
	('1fc19e7e-5af3-4786-ad6e-eb57cccbb25a', '70716ddc-c4fa-4a5f-88c7-bcaf6fb8e1f2', 1, '{"id": "postkodstiftelsen-projektstod-v1", "title": "Ansökan — Postkodstiftelsen projektstöd (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Ett avgränsat projekt med tydlig början och slut — stiftelsen finansierar inte löpande verksamhet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "forvantad_effekt", "type": "long_text", "label": "Vilken förändring ska projektet åstadkomma?", "section": "projekt", "guidance": "Formulera som förändring för målgruppen, inte som aktiviteter.", "required": true, "maxLength": 3000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "budget", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.254319+00'),
	('e38ec52a-3163-476c-9f48-59c5b03c348d', '3a7a9ef1-3826-4585-986b-eead34315d96', 1, '{"id": "mucf-organisationsbidrag-v1", "title": "Ansökan — MUCF organisationsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_medlemmar", "max": 1000000, "min": 1, "type": "number", "label": "Totalt antal medlemmar", "section": "medlemmar", "required": true}, {"key": "andel_unga", "max": 100, "min": 0, "type": "percentage", "label": "Andel medlemmar 6–25 år (%)", "section": "medlemmar", "guidance": "Kravet är minst 60 % — medlemsregistret är underlaget och MUCF granskar det.", "required": true}, {"key": "antal_medlemsforeningar", "max": 10000, "min": 1, "type": "number", "label": "Antal medlemsföreningar/lokalavdelningar", "section": "medlemmar", "guidance": "Nationell spridning krävs — normalt verksamhet i minst fem län.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "medlemmar", "title": "Medlemmar och struktur"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.256065+00'),
	('58d7b689-dd91-4cd0-8071-32a982f9c968', '43c0fb0d-c822-4ea0-9d77-c13d1b4027fb', 1, '{"id": "kreativa-europa-samarbetsprojekt-v1", "title": "Ansökan — Kreativa Europa samarbetsprojekt (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partnerskap_beskrivning", "type": "long_text", "label": "Partnerskapet (organisationer och länder)", "section": "projekt", "guidance": "Minst tre organisationer från tre olika länder krävs — ange samtliga med land.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och dess europeiska dimension", "section": "projekt", "guidance": "Vad tillför samarbetet som inte hade hänt nationellt? EU-mervärdet är ett bedömningskriterium, inte en formalitet.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.330267+00'),
	('db5f5b2f-c623-40d7-8cc2-f1cd53e5d287', 'd7bcdcc1-8e69-4566-ba13-01c106b752d2', 1, '{"id": "boverket-allmanna-samlingslokaler-v1", "title": "Ansökan — Stöd till allmänna samlingslokaler (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Föreningens/stiftelsens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "lokal_beskrivning", "type": "long_text", "label": "Beskriv lokalen och hur den används av allmänheten", "section": "lokal", "guidance": "Öppenheten är kravet: vilka utomstående grupper använder lokalen i dag, och hur bokar de?", "required": true, "maxLength": 3000}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Vad ska byggas, köpas eller rustas upp?", "section": "lokal", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "budget", "guidance": "Stödet täcker högst halva kostnaden — resten är egen finansiering.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "lokal", "title": "Lokalen och åtgärden"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.257883+00'),
	('9283ceb4-5152-41a4-8cde-4e67caf606ba', 'cbe9dc6d-1d09-41be-b857-266b16f90f0e', 1, '{"id": "naturvardsverket-ladda-bilen-v1", "title": "Ansökan — Ladda bilen (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "antal_laddpunkter", "max": 1000, "min": 1, "type": "number", "label": "Antal laddpunkter", "section": "laddning", "required": true}, {"key": "plats_beskrivning", "type": "long_text", "label": "Var installeras laddpunkterna, och vilka använder dem?", "section": "laddning", "guidance": "Stödet gäller laddning för boende eller anställda — inte publika laddstationer.", "required": true, "maxLength": 2000}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "laddning", "guidance": "Bidraget är högst halva kostnaden per laddpunkt, med takbelopp.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "laddning", "title": "Laddpunkterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.259993+00'),
	('c65ebe54-c207-4a96-a003-762185d9a9ab', '6b502145-5fdc-44f2-8502-d2e601d0695a', 1, '{"id": "raa-kulturarvsbidrag-v1", "title": "Ansökan — Kulturarvsbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv kulturarvsinsatsen", "section": "projekt", "guidance": "Vad ska bevaras, användas eller utvecklas — och hur blir det tillgängligt för fler?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.261873+00'),
	('09079a29-a84b-4abb-982e-af023c2ad2d6', '54230320-23ec-4d2c-aad0-5d1821a6e719', 1, '{"id": "lansstyrelsen-bygdemedel-v1", "title": "Ansökan — Bygdemedel (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Föreningens/kommunens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "bygd_beskrivning", "type": "long_text", "label": "Vilken bygd gäller det, och hur berörs den av vatten- eller vindkraft?", "section": "projekt", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Allmännyttan är kravet: vem i bygden får glädje av investeringen, utöver den egna föreningen?", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.263764+00'),
	('eb459640-414c-48ba-803d-5711e66594f3', 'adac47e7-e7bb-40da-bc3a-a58a631fc904', 1, '{"id": "csn-utlandsstudier-v1", "title": "Ansökan — Studiemedel för utlandsstudier (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "studie_land", "type": "text", "label": "Studieland", "section": "studier", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "utbildning", "type": "text", "label": "Utbildning och lärosäte", "section": "studier", "guidance": "Kontrollera att utbildningen är godkänd för studiemedel i CSN:s tjänst INNAN du tackar ja till platsen.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "terminsavgift", "min": 0, "type": "currency", "label": "Terminsavgift om sådan finns (kr)", "section": "studier", "guidance": "Merkostnadslån kan täcka undervisningsavgifter — lämna tomt om avgift saknas.", "required": false}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna utomlands"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.357125+00'),
	('55136f76-01f8-42e0-ad8c-e07e03833f0f', '73b4bbc3-bd59-49be-8be8-068551cd8c8a', 1, '{"id": "kulturradet-verksamhetsbidrag-scenkonst-v1", "title": "Ansökan — Verksamhetsbidrag scenkonst (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Gruppens/organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten kommande år", "section": "verksamhet", "guidance": "Repertoar, produktioner, spelplatser och publik — verksamhetsbidraget bedöms på helheten, inte enskilda projekt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "antal_forestallningar", "max": 2000, "min": 1, "type": "number", "label": "Planerat antal föreställningar per år", "section": "verksamhet", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Gruppen/organisationen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.266128+00'),
	('593a97b4-f12a-4b4c-bceb-58b120724d2f', '2c6560c9-f661-47f5-9830-570b9382ef5f', 1, '{"id": "konstnarsnamnden-arbetsstipendium-v1", "title": "Ansökan — Arbetsstipendium (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "konstform", "type": "text", "label": "Konstområde", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.professionalField"}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv din konstnärliga verksamhet och dina planer", "section": "verksamhet", "guidance": "Stipendiet bedöms på konstnärlig kvalitet och aktivitet — konkreta verk, uppdrag och planer väger tyngre än ambitioner.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "meriter", "type": "long_text", "label": "Viktigaste verk och uppdrag (senaste åren)", "section": "verksamhet", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "verksamhet", "title": "Din konstnärliga verksamhet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.268226+00'),
	('b0973f99-3943-4f2e-968f-11fd9297a76f', 'c8811d54-331b-44e3-8a17-1402e50695fb', 1, '{"id": "konstnarsnamnden-kulturbryggan-v1", "title": "Ansökan — Kulturbryggan (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vad som är nyskapande", "section": "projekt", "guidance": "Kulturbryggan finansierar det oprövade — beskriv vad som skiljer projektet från befintlig praxis, inte bara att det är nytt för er.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "ovriga_finansiarer", "type": "long_text", "label": "Övriga finansiärer (sökta eller beviljade)", "section": "projekt", "guidance": "Kulturbryggan ser gärna fler finansieringskällor — redovisa öppet vad som är sökt respektive beviljat.", "required": false, "maxLength": 2000}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "projekt", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.27008+00'),
	('d7e3101f-1300-442e-93a7-ff2fecf70edb', '4311bf5f-f7db-4acd-ab1b-1368940ba16d', 1, '{"id": "erasmus-mobilitet-skola-vuxen-v1", "title": "Ansökan — Erasmus+ mobilitet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "guidance": "Registreras i EU:s Organisation Registration System — utan OID kan ansökan inte lämnas in.", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "mobilitet_beskrivning", "type": "long_text", "label": "Beskriv mobiliteterna och deras syfte", "section": "mobilitet", "guidance": "Vilka åker, vart, och hur tas lärdomarna om hand i organisationen efteråt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_deltagare", "max": 500, "min": 1, "type": "number", "label": "Antal deltagare", "section": "mobilitet", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "mobilitet", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "mobilitet", "title": "Mobiliteterna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.272324+00'),
	('b4ff4a3e-60e8-4011-b0df-0087622f0e18', '6f654791-d039-4d71-8532-b2e88e0cb735', 1, '{"id": "erasmus-ka2-smaskaliga-partnerskap-v1", "title": "Ansökan — Erasmus+ småskaliga partnerskap (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "partnerskap", "guidance": "Minst en partner i ett annat programland krävs.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv samarbetet", "section": "partnerskap", "guidance": "Småskaliga partnerskap är instegsformatet — enklare aktiviteter, lägre budget, men samma krav på tydligt syfte.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "partnerskap", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "partnerskap", "title": "Partnerskapet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.274558+00'),
	('f7ed9774-d269-43d1-9400-307f3e831f21', 'c9a895bc-754d-4418-bc35-a624f1ee4c26', 1, '{"id": "vinnova-planeringsbidrag-eu-v1", "title": "Ansökan — Planeringsbidrag EU-ansökan (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "eu_utlysning", "type": "text", "label": "Vilken EU-utlysning avser ni att söka?", "section": "eu", "guidance": "Program och utlysningsnamn — planeringsbidraget kräver ett konkret mål.", "required": true, "maxLength": 300}, {"key": "planering_beskrivning", "type": "long_text", "label": "Vad ska planeringsarbetet omfatta?", "section": "eu", "guidance": "Konsortiebyggande, ansökningsskrivning, resor — det bidraget faktiskt får användas till.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "eu", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "eu", "title": "EU-ansökan som planeras"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.332318+00'),
	('aa59e464-7f9e-4619-9229-5f80edd0eaef', '14316ca0-2bfd-4716-b43b-cbf29f41b1a8', 1, '{"id": "mucf-solidaritetskaren-v1", "title": "Ansökan — Europeiska solidaritetskåren (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_oid", "type": "text", "label": "OID (Organisation ID)", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.oid"}, {"key": "har_kvalitetsmarkning", "type": "boolean", "label": "Har organisationen giltig Quality Label?", "section": "org", "guidance": "Kvalitetsmärkningen söks separat och måste finnas innan volontärprojekt kan beviljas.", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv volontärprojektet", "section": "volontar", "guidance": "Vad gör volontärerna, vilket stöd får de, och vilken nytta skapar projektet lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "antal_volontarer", "max": 100, "min": 1, "type": "number", "label": "Antal volontärer", "section": "volontar", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "volontar", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "volontar", "title": "Volontärprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.334047+00'),
	('5ed38cf1-9821-4d0a-945f-de19f1264c7f', 'b6b654c2-730a-47e1-8028-92d4e31eb0fb', 1, '{"id": "esf-kompetensutveckling-v1", "title": "Ansökan — ESF kompetensutveckling (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "malgrupp_beskrivning", "type": "long_text", "label": "Vilka anställda/deltagare omfattas, och vad behöver de?", "section": "insats", "guidance": "ESF bedömer kopplingen till arbetsmarknadens behov — konkret kompetensgap, inte allmän utbildning.", "required": true, "maxLength": 4000}, {"key": "insats_beskrivning", "type": "long_text", "label": "Beskriv insatserna", "section": "insats", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "kan_forfinansiera", "type": "boolean", "label": "Kan organisationen förfinansiera kostnaderna?", "section": "ekonomi", "guidance": "ESF betalar ut i efterskott mot redovisning — likviditeten måste bära projektet under tiden.", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "insats", "required": true, "canonicalKey": "project.dateRange"}, {"key": "additionalitet", "type": "select", "label": "Vad händer om stödet inte beviljas?", "options": [{"label": "Projektet blir inte av", "value": "not_at_all"}, {"label": "Genomförs i mindre skala", "value": "smaller"}, {"label": "Genomförs senare", "value": "later"}, {"label": "Genomförs ändå som planerat", "value": "anyway"}], "section": "ekonomi", "guidance": "Svara ärligt — additionaliteten är ett bedömningskriterium. Stödet ska göra skillnad; ett projekt som blir av oförändrat ändå är en vanlig avslagsgrund.", "required": true, "canonicalKey": "project.additionality"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "insats", "title": "Kompetensinsatsen"}, {"key": "ekonomi", "title": "Ekonomi"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.335666+00'),
	('862c68a0-9435-4e96-bc9f-f4839fa6e897', '71346c42-e1dc-4e52-91f8-09cbd99c25fe', 1, '{"id": "si-creative-force-v1", "title": "Ansökan — Creative Force (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "partner_namn", "type": "text", "label": "Partnerorganisation och land", "section": "projekt", "guidance": "Ett etablerat partnerskap i mållandet är kärnan i programmet.", "required": true, "maxLength": 300, "canonicalKey": "project.partnerName"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "guidance": "Hur stärker projektet demokrati, yttrandefrihet eller mänskliga rättigheter genom kultur eller media? Mekanismen bedöms, inte avsikten.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet och partnern"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.337747+00'),
	('aaaea4ec-6b59-4646-881f-88cfab9cbac6', '041b7b1c-771c-4555-ae43-4bdc2852351b', 1, '{"id": "radiohjalpen-projektbidrag-v1", "title": "Ansökan — Radiohjälpens projektbidrag (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "niokonto", "type": "text", "label": "90-kontonummer", "section": "sokande", "guidance": "T.ex. 90 1234-5. Kontot kontrolleras mot Svensk Insamlingskontroll.", "required": true, "maxLength": 20}, {"key": "fond", "type": "select", "label": "Vilken utlysning/fond söker ni ur?", "options": [{"label": "Världens Barn", "value": "varldens_barn"}, {"label": "Musikhjälpen", "value": "musikhjalpen"}, {"label": "Victoriafonden", "value": "victoriafonden"}, {"label": "Annan aktuell utlysning", "value": "other"}], "section": "projekt", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.383435+00'),
	('eb3eafe1-0030-4506-a9b0-2f3160f63300', '3a85807a-d380-4685-8b21-23781ebb6f28', 1, '{"id": "vr-projektbidrag-v1", "title": "Ansökan — Vetenskapsrådet projektbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "har_doktorsexamen", "type": "boolean", "label": "Har du doktorsexamen?", "section": "sokande", "guidance": "Behörighetskrav — examensår kan påverka vilka bidragsformer som är öppna.", "required": true}, {"key": "larosate", "type": "text", "label": "Medelsförvaltande lärosäte", "section": "sokande", "guidance": "Bidraget förvaltas av ett svenskt lärosäte — det ska bekräfta åtagandet.", "required": true, "maxLength": 200}, {"key": "forskningsplan", "type": "long_text", "label": "Forskningsplanens kärna", "section": "forskning", "guidance": "Frågeställning, metod och förväntade resultat — sakkunniggranskningen bedömer originalitet och genomförbarhet.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "forskning", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "forskning", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Forskaren"}, {"key": "forskning", "title": "Forskningsplanen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.339511+00');
INSERT INTO public.application_schemas VALUES
	('186d2fdd-b192-4b77-92d3-352d64bf13d5', 'afda3d43-f3d9-4d77-b00e-63b03b39431e', 1, '{"id": "energimyndigheten-energieffektivisering-v1", "title": "Ansökan — Stöd till energieffektivisering (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv energiåtgärden", "section": "atgard", "guidance": "Vilken energianvändning minskas, med vilken teknik, och vad är beräknad besparing i kWh?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "besparing_kwh", "max": 100000000, "min": 1, "type": "number", "label": "Beräknad energibesparing (kWh/år)", "section": "atgard", "guidance": "En energikartläggning eller leverantörsberäkning styrker siffran.", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "atgard", "title": "Åtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.34145+00'),
	('103205f9-7a6c-4112-9233-8852d809701e', '271a7349-54c2-4392-b174-b60de25c9ef3', 1, '{"id": "energimyndigheten-industriklivet-v1", "title": "Ansökan — Industriklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Organisationens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och utsläppsminskningen", "section": "projekt", "guidance": "Industriklivet finansierar åtgärder mot processutsläpp — kvantifiera minskningen i CO2-ekvivalenter och beskriv teknikens mognadsgrad.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 100000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "projekt", "required": true}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Organisationen"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.343884+00'),
	('84806a8e-49ca-4c2e-9296-98fb5dfaaf3c', '7e7cb03c-5232-4b0e-b2a0-5dbfaf61bd66', 1, '{"id": "naturvardsverket-klimatklivet-v1", "title": "Ansökan — Klimatklivet (förberedelse)", "fields": [{"key": "org_namn", "type": "text", "label": "Sökandens namn", "section": "org", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "org", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "atgard_beskrivning", "type": "long_text", "label": "Beskriv åtgärden", "section": "atgard", "guidance": "Klimatklivet rangordnar på klimatnytta per investerad krona — utsläppsminskningen ska vara beräknad och beräkningen redovisbar.", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "utslappsminskning_ton", "max": 10000000, "min": 0, "type": "number", "label": "Beräknad utsläppsminskning (ton CO2e/år)", "section": "atgard", "required": true}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Investeringskostnad (kr)", "section": "atgard", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "ej_paborjad", "type": "declaration", "label": "Jag intygar att åtgärden inte påbörjats före ansökan", "section": "atgard", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "org", "title": "Sökande"}, {"key": "atgard", "title": "Klimatåtgärden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.345902+00'),
	('c4036c59-273e-486d-836a-56a231116ce8', 'c8cee1bf-40ac-4e22-a136-2d41d4ff89c8', 1, '{"id": "naturvardsverket-lona-v1", "title": "Ansökan — LONA lokala naturvårdssatsningen (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "guidance": "LONA söks via kommunen — föreningar deltar som initiativtagare.", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommun", "type": "text", "label": "Kommun som står bakom ansökan", "section": "sokande", "required": true, "maxLength": 100}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv naturvårdsinsatsen", "section": "projekt", "guidance": "Vad görs, var, och vilken naturvårds- eller friluftsnytta skapas lokalt?", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "projekt_datum", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "kostnad", "min": 1, "type": "currency", "label": "Beräknad kostnad (kr)", "section": "projekt", "guidance": "LONA täcker högst halva kostnaden.", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Sökande"}, {"key": "projekt", "title": "Naturvårdsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.347913+00'),
	('b8752db6-9fac-430d-a965-3c38ab47adbf', 'd773388a-62f3-4036-a4ab-652a8c6565d0', 1, '{"id": "kulturradet-inkopsstod-bibliotek-v1", "title": "Ansökan — Inköpsstöd till folkbibliotek (förberedelse)", "fields": [{"key": "kommun_namn", "type": "text", "label": "Kommunens namn", "section": "kommun", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "kommun", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "inkop_beskrivning", "type": "long_text", "label": "Hur ska stödet användas?", "section": "inkop", "guidance": "Inköp av litteratur för barn och unga prioriteras; stödet får inte ersätta kommunens egen medieanslag — egeninsatsen ska bestå.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "eget_anslag", "min": 0, "type": "currency", "label": "Kommunens eget medieanslag i år (kr)", "section": "inkop", "required": true}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "inkop", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "kommun", "title": "Kommunen"}, {"key": "inkop", "title": "Inköpen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.349617+00'),
	('a3bd9734-1918-425c-b984-a73994f1a888', 'c49d5e2a-29cd-42f0-9978-cf90b1293d61', 1, '{"id": "kulturradet-litteraturstod-v1", "title": "Ansökan — Litteraturstöd (förberedelse)", "fields": [{"key": "forlag_namn", "type": "text", "label": "Förlagets namn", "section": "forlag", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forlag", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "titel", "type": "text", "label": "Titel och författare", "section": "titel", "required": true, "maxLength": 300, "canonicalKey": "project.title"}, {"key": "titel_beskrivning", "type": "long_text", "label": "Beskriv utgivningen", "section": "titel", "guidance": "Litteraturstödet söks efter utgivning och bedöms på kvalitet — beskriv verket sakligt, inte säljande.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "upplaga", "max": 1000000, "min": 1, "type": "number", "label": "Upplaga (exemplar)", "section": "titel", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forlag", "title": "Förlaget"}, {"key": "titel", "title": "Titeln"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.351368+00'),
	('4ddd28e0-a6f9-49a2-b2da-7a1a7802d812', '9fba8a2d-c848-4524-b689-9641d687bc7b', 1, '{"id": "migrationsverket-atervandringsbidrag-v1", "title": "Ansökan — Stöd vid frivillig återvandring (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "ursprungsland", "type": "text", "label": "Land du planerar att återvandra till", "section": "atervandring", "required": true, "maxLength": 100}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet som återvandrar", "section": "atervandring", "required": true}, {"key": "planerad_utresa", "type": "date", "label": "Planerad utresa", "section": "atervandring", "required": true}, {"key": "situation_beskrivning", "type": "long_text", "label": "Beskriv din plan för återetableringen", "section": "atervandring", "guidance": "Boende, försörjning och nätverk i ursprungslandet. OBS: beslutet är oåterkalleligt i bidragshänseende — uppehållstillståndet återkallas normalt. Ta det lugnt med beslutet och kontrollera aktuella belopp hos Migrationsverket.", "required": true, "maxLength": 3000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "atervandring", "title": "Återvandringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.353169+00'),
	('e7cdc092-6934-4b9c-aba2-158ef340503b', 'ced6ee83-5399-40f8-ba50-f95da7474302', 1, '{"id": "af-eures-targeted-mobility-v1", "title": "Ansökan — EURES Targeted Mobility (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "mal_land", "type": "text", "label": "Land där jobbet finns", "section": "jobbet", "required": true, "maxLength": 100, "canonicalKey": "project.destinationCountry"}, {"key": "jobb_status", "type": "select", "label": "Var i processen är du?", "options": [{"label": "Kallad till intervju", "value": "interview"}, {"label": "Har jobberbjudande", "value": "offer"}, {"label": "Söker aktivt", "value": "searching"}], "section": "jobbet", "required": true}, {"key": "insats_beskrivning", "type": "long_text", "label": "Vilket stöd behöver du?", "section": "jobbet", "guidance": "Intervjuresa, flyttkostnad, språkkurs eller erkännande av examen — beloppen är schabloner per insats. EURES-rådgivaren bekräftar vad som gäller din programperiod.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "jobbet", "title": "Jobbet och flytten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.355183+00'),
	('04a2d54e-8b45-4f84-aaa7-2e81c40772ab', 'e5f98200-7495-4257-800b-db3b2ec2791e', 1, '{"id": "fk-omvardnadsbidrag-v1", "title": "Ansökan — Omvårdnadsbidrag (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn (vårdnadshavare)", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "barn_alder", "max": 18, "min": 0, "type": "number", "label": "Barnets ålder", "section": "barnet", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv barnets funktionsnedsättning", "section": "barnet", "guidance": "Diagnos eller svårigheter i vardagen — läkarutlåtandet bär den medicinska bedömningen, din beskrivning bär vardagen.", "required": true, "maxLength": 3000}, {"key": "omvardnadsbehov", "type": "long_text", "label": "Vilken extra omvårdnad och tillsyn behöver barnet?", "section": "barnet", "guidance": "Jämför med barn i samma ålder: vad kräver mer tid, närvaro eller passning — dygnet runt-perspektivet räknas.", "required": true, "maxLength": 4000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om barnets funktionsnedsättning?", "section": "barnet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "barnet", "title": "Barnet och behoven"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.358985+00'),
	('f48d9154-1632-4e4c-be1e-af10565f2c9d', '3f11e339-c106-4d69-9fdc-c5208bf2acdc', 1, '{"id": "fk-merkostnadsersattning-v1", "title": "Ansökan — Merkostnadsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "galler_barn", "type": "boolean", "label": "Gäller ansökan ett barn du är vårdnadshavare för?", "section": "sokande", "required": true}, {"key": "funktionsnedsattning", "type": "long_text", "label": "Beskriv funktionsnedsättningen", "section": "sokande", "required": true, "maxLength": 3000}, {"key": "merkostnader_ar", "min": 0, "type": "currency", "label": "Uppskattade merkostnader per år (kr)", "section": "kostnader", "guidance": "Räkna bara kostnader du inte skulle ha utan funktionsnedsättningen — och dra av eventuella bidrag som redan täcker dem.", "required": true}, {"key": "merkostnader_beskrivning", "type": "long_text", "label": "Specificera merkostnaderna", "section": "kostnader", "guidance": "Post för post: vad, hur ofta, ungefär vad det kostar per år. Kvitton och intyg stärker.", "required": true, "maxLength": 4000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "kostnader", "title": "Merkostnaderna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.360794+00'),
	('93989777-3ef9-45fc-8d73-71b1783a8778', 'dca6e66a-b48c-4b6f-a3b6-7b3ced4b026e', 1, '{"id": "fk-bilstod-v1", "title": "Ansökan — Bilstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "forflyttning", "type": "long_text", "label": "Beskriv svårigheterna att förflytta dig eller resa kollektivt", "section": "behov", "guidance": "Konkret: vad går inte, vad krävs för att det ska gå, och hur varaktigt är det?", "required": true, "maxLength": 4000}, {"key": "har_korkort", "type": "boolean", "label": "Har du (eller den som ska köra) körkort?", "section": "behov", "required": true}, {"key": "behov_anpassning", "type": "long_text", "label": "Behöver bilen anpassas — i så fall hur?", "section": "behov", "guidance": "T.ex. handreglage, ramp eller lyft. Lämna tomt om du inte vet ännu — behovet utreds.", "required": false, "maxLength": 2000}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om funktionsnedsättningen?", "section": "behov", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "behov", "title": "Förflyttningsbehovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.362566+00'),
	('6cdc595c-1fd0-4262-9276-485dd146317c', 'c4fa7013-d021-49dc-b9f1-2dfe8775b2f5', 1, '{"id": "fk-narstaendepenning-v1", "title": "Ansökan — Närståendepenning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "relation", "type": "text", "label": "Din relation till den som är sjuk", "section": "varden", "guidance": "T.ex. förälder, barn, syskon, vän — närstående är den som står den sjuke nära.", "required": true, "maxLength": 200}, {"key": "vard_period", "type": "date_range", "label": "Period du avstår från arbete", "section": "varden", "required": true, "canonicalKey": "project.dateRange"}, {"key": "omfattning", "type": "select", "label": "Omfattning", "options": [{"label": "Hel dag", "value": "full"}, {"label": "Tre fjärdedelar", "value": "three_quarters"}, {"label": "Halv dag", "value": "half"}, {"label": "En fjärdedel", "value": "quarter"}], "section": "varden", "required": true}, {"key": "har_samtycke", "type": "boolean", "label": "Har den sjuke samtyckt till ansökan?", "section": "varden", "guidance": "Samtycke krävs när det är möjligt att lämna.", "required": true}, {"key": "har_lakarutlatande", "type": "boolean", "label": "Finns ett läkarutlåtande om den närståendes tillstånd?", "section": "varden", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "varden", "title": "Vården och tiden"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.364689+00'),
	('96470dcc-4cc2-48ee-9dbe-2b3c8e9c0dcf', '6365ebcf-a41b-4568-87fb-50c7bd647274', 1, '{"id": "af-etableringsersattning-v1", "title": "Ansökan — Etableringsersättning (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "uppehallstillstand_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år fick du uppehållstillstånd?", "section": "sokande", "required": true}, {"key": "inskriven_af", "type": "boolean", "label": "Är du inskriven hos Arbetsförmedlingen?", "section": "etablering", "guidance": "Etableringsprogrammet förutsätter inskrivning — börja där om du inte redan är inskriven.", "required": true}, {"key": "har_barn_hemma", "type": "boolean", "label": "Har du barn som bor hos dig?", "section": "etablering", "guidance": "Med barn hemma kan etableringstillägg bli aktuellt hos Försäkringskassan.", "required": true}, {"key": "bor_ensam", "type": "boolean", "label": "Bor du ensam i egen bostad?", "section": "etablering", "guidance": "Den som bor ensam kan ha rätt till bostadsersättning.", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "etablering", "title": "Etableringen"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.366578+00'),
	('af4d87ee-0af3-456e-8633-015098ae1d0c', 'ed1b1caa-4a62-4bcb-9804-7d0119671895', 1, '{"id": "csn-hemutrustningslan-v1", "title": "Ansökan — Hemutrustningslån (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "kommunmottagande_ar", "max": 2100, "min": 2000, "type": "number", "label": "Vilket år togs du emot i en kommun?", "section": "sokande", "guidance": "Lånet söks inom två år från det första kommunmottagandet.", "required": true}, {"key": "hushall_antal", "max": 20, "min": 1, "type": "number", "label": "Antal personer i hushållet", "section": "hemmet", "required": true}, {"key": "bostad_typ", "type": "select", "label": "Är bostaden möblerad eller omöblerad?", "options": [{"label": "Omöblerad", "value": "unfurnished"}, {"label": "Möblerad", "value": "furnished"}], "section": "hemmet", "guidance": "Lånebeloppet skiljer sig — omöblerad bostad ger högre lån.", "required": true}, {"key": "aterbetalning_medveten", "type": "boolean", "label": "Jag är medveten om att detta är ett lån som ska betalas tillbaka", "section": "hemmet", "required": true}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "hemmet", "title": "Hemmet och behovet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.368799+00'),
	('af5cc28a-474b-43f4-bacd-7606448ecbe4', '10f619cd-7abf-46fe-8bd8-e85a6ead2ce0', 1, '{"id": "csn-studiestartsstod-v1", "title": "Ansökan — Studiestartsstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "tidigare_utbildning", "type": "select", "label": "Din senast avslutade utbildning", "options": [{"label": "Grundskola eller kortare", "value": "grundskola"}, {"label": "Påbörjat men inte slutfört gymnasium", "value": "gymnasium_ej_klart"}, {"label": "Slutfört gymnasium", "value": "gymnasium"}], "section": "sokande", "required": true}, {"key": "kommun_kontaktad", "type": "boolean", "label": "Har du kontaktat hemkommunen om studiestartsstödet?", "section": "studier", "guidance": "Kommunen bedömer om du tillhör målgruppen innan CSN kan bevilja.", "required": true}, {"key": "utbildning", "type": "text", "label": "Utbildning du vill gå", "section": "studier", "guidance": "Grundskole- eller gymnasienivå, t.ex. komvux.", "required": true, "maxLength": 300}, {"key": "studie_period", "type": "date_range", "label": "Planerad studieperiod", "section": "studier", "required": true, "canonicalKey": "project.dateRange"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om dig"}, {"key": "studier", "title": "Studierna"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.370695+00'),
	('de84c65f-6bd6-4578-971e-848f2e7c474c', 'd2f4ebc9-32bf-4e94-9a2d-455089de3842', 1, '{"id": "csn-inackorderingstillagg-v1", "title": "Ansökan — Inackorderingstillägg (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Elevens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "skola", "type": "text", "label": "Skola och ort", "section": "boendet", "required": true, "maxLength": 300}, {"key": "skoltyp", "type": "select", "label": "Vilken typ av skola?", "options": [{"label": "Fristående gymnasieskola", "value": "independent"}, {"label": "Folkhögskola", "value": "folk_high"}, {"label": "Kommunal gymnasieskola", "value": "municipal"}], "section": "boendet", "guidance": "Fristående skola och folkhögskola → CSN. Kommunal skola → hemkommunen.", "required": true}, {"key": "resvag", "type": "long_text", "label": "Beskriv resvägen mellan hemmet och skolan", "section": "boendet", "guidance": "Avstånd och restid — varför daglig pendling inte fungerar.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om eleven"}, {"key": "boendet", "title": "Skolan och boendet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.372434+00'),
	('d02b512f-10f0-4f30-8850-9517c13f7cf3', 'e3296bd2-2fb0-47de-88c2-b54e4854bd8c', 1, '{"id": "kommun-foreningsbidrag-v1", "title": "Ansökan — Kommunalt föreningsbidrag (förberedelse)", "fields": [{"key": "forening_namn", "type": "text", "label": "Föreningens namn", "section": "forening", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "forening", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "medlemsantal", "max": 1000000, "min": 1, "type": "number", "label": "Antal medlemmar", "section": "forening", "required": true}, {"key": "bidragstyp", "type": "select", "label": "Vilket bidrag söker ni?", "options": [{"label": "Aktivitetsstöd (per deltagartillfälle)", "value": "activity"}, {"label": "Lokalbidrag", "value": "venue"}, {"label": "Startbidrag för ny förening", "value": "start"}, {"label": "Annat/vet inte ännu", "value": "other"}], "section": "verksamhet", "required": true}, {"key": "verksamhet_beskrivning", "type": "long_text", "label": "Beskriv verksamheten i kommunen", "section": "verksamhet", "guidance": "Vad ni gör, hur ofta, för vilka — särskilt barn- och ungdomsverksamhet.", "required": true, "maxLength": 3000, "canonicalKey": "project.summary"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "forening", "title": "Om föreningen"}, {"key": "verksamhet", "title": "Verksamheten"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.374491+00'),
	('0318615d-74ff-4426-836a-0322a87b578b', '0f5b852f-f437-476f-8dc3-bb431435bfdd', 1, '{"id": "region-kulturstod-v1", "title": "Ansökan — Regionalt kulturstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "regional_forankring", "type": "long_text", "label": "Beskriv er förankring i regionen", "section": "sokande", "guidance": "Säte, verksamhetsort, publik och samarbeten i regionen.", "required": true, "maxLength": 2000}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet", "section": "projekt", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "budget", "title": "Budget"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.376189+00'),
	('e05b5029-82a4-41c3-9348-2a61922547dc', '2bc6f61e-c3c4-44a5-9df0-247a84ffa9fa', 1, '{"id": "sparbanksstiftelsen-projektstod-v1", "title": "Ansökan — Sparbanksstiftelsens projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Organisationens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "verksamhetsomrade", "type": "text", "label": "Ort/område där projektet genomförs", "section": "projekt", "guidance": "Stiftelsen stödjer bara projekt i den egna sparbankens verksamhetsområde.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och vem det kommer till del", "section": "projekt", "required": true, "maxLength": 4000, "canonicalKey": "project.summary"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.377974+00'),
	('ae516212-2c87-4e31-94dd-7da2febe9741', 'cc8e67bb-d6ed-402d-9c27-195c64bdfac9', 1, '{"id": "leader-lokalt-ledd-utveckling-v1", "title": "Ansökan — Leader-projektstöd (förberedelse)", "fields": [{"key": "sokande_namn", "type": "text", "label": "Sökandens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "org_nummer", "type": "text", "label": "Organisationsnummer", "section": "sokande", "required": true, "maxLength": 20, "canonicalKey": "organisation.orgNumber"}, {"key": "leaderomrade", "type": "text", "label": "Vilket leaderområde tillhör ni?", "section": "projekt", "guidance": "Osäker? Sök på \"leaderområde\" + din kommun — kansliet hjälper till.", "required": true, "maxLength": 200}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv projektet och nyttan för bygden", "section": "projekt", "guidance": "Koppla till leaderområdets utvecklingsstrategi — lokal förankring och samarbete väger tungt.", "required": true, "maxLength": 5000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "budget", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "likviditet", "type": "long_text", "label": "Hur klarar ni likviditeten tills stödet betalas ut?", "section": "budget", "guidance": "Leaderstöd betalas ut i efterhand mot redovisade kostnader.", "required": true, "maxLength": 2000}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Om er som söker"}, {"key": "projekt", "title": "Projektet och bygden"}, {"key": "budget", "title": "Budget och finansiering"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.379728+00'),
	('f40a561d-af65-4d61-8020-ea414491c0b8', '0e165697-13c1-4a62-bd29-f6288d049575', 1, '{"id": "forte-projektbidrag-v1", "title": "Ansökan — Forte projektbidrag (förberedelse)", "fields": [{"key": "projektledare", "type": "text", "label": "Projektledarens namn", "section": "sokande", "required": true, "maxLength": 200, "canonicalKey": "applicant.displayName"}, {"key": "medelsforvaltare", "type": "text", "label": "Medelsförvaltare (lärosäte)", "section": "sokande", "required": true, "maxLength": 300}, {"key": "disputationsar", "max": 2100, "min": 1950, "type": "number", "label": "Projektledarens disputationsår", "section": "sokande", "required": true}, {"key": "projekt_beskrivning", "type": "long_text", "label": "Beskriv forskningsprojektet", "section": "projekt", "guidance": "Frågeställning, metod och relevans för hälsa, arbetsliv eller välfärd — sakligt och prövbart.", "required": true, "maxLength": 6000, "canonicalKey": "project.summary"}, {"key": "projekt_period", "type": "date_range", "label": "Projektperiod", "section": "projekt", "required": true, "canonicalKey": "project.dateRange"}, {"key": "sokt_belopp", "min": 1, "type": "currency", "label": "Sökt belopp (kr)", "section": "projekt", "required": true, "canonicalKey": "project.requestedAmount"}, {"key": "intygande", "type": "declaration", "label": "Jag intygar att lämnade uppgifter är riktiga", "section": "intyg", "required": true}], "version": 1, "sections": [{"key": "sokande", "title": "Projektledare och medelsförvaltare"}, {"key": "projekt", "title": "Forskningsprojektet"}, {"key": "intyg", "title": "Intyg"}]}', '2026-08-28 06:37:09.381471+00');


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
	('d12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'Kulturrådet', 'SE', 'state_agency', 'https://kulturradet.se', '2026-08-28 06:37:08.492095+00'),
	('39be3fc9-aad3-4934-bca7-7d23526d374a', 'MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor', 'SE', 'state_agency', 'https://www.mucf.se', '2026-08-28 06:37:08.502567+00'),
	('3acf93e8-ba3b-4ea9-92a0-2730497c78b1', 'Vinnova', 'SE', 'state_agency', 'https://www.vinnova.se', '2026-08-28 06:37:08.50693+00'),
	('3e461d3b-d656-45bf-934d-1dd28a281259', 'Tillväxtverket', 'SE', 'state_agency', 'https://tillvaxtverket.se', '2026-08-28 06:37:08.509319+00'),
	('78dc70cc-5d4d-4859-afb8-9ebd577ddf7f', 'Energimyndigheten', 'SE', 'state_agency', 'https://www.energimyndigheten.se', '2026-08-28 06:37:08.512224+00'),
	('e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'Naturvårdsverket', 'SE', 'state_agency', 'https://www.naturvardsverket.se', '2026-08-28 06:37:08.514212+00'),
	('766cb84e-b3bb-44f4-89c0-43236a4840af', 'Jordbruksverket', 'SE', 'state_agency', 'https://jordbruksverket.se', '2026-08-28 06:37:08.516132+00'),
	('f34e6a3d-e2ba-46b3-af33-8788090be0e0', 'Svenska ESF-rådet', 'SE', 'state_agency', 'https://www.esf.se', '2026-08-28 06:37:08.518076+00'),
	('f6694444-7bf3-49ad-a33f-a8258e72c318', 'Europeiska kommissionen (Erasmus+/EACEA)', 'EU', 'eu', 'https://erasmus-plus.ec.europa.eu', '2026-08-28 06:37:08.520142+00'),
	('1a4366ce-048a-404f-8d03-8b230c087f66', 'UHR — Universitets- och högskolerådet', 'SE', 'state_agency', 'https://www.uhr.se', '2026-08-28 06:37:08.522041+00'),
	('2ca44d2f-388f-4994-aadf-46315d93ab08', 'Konstnärsnämnden', 'SE', 'state_agency', 'https://www.konstnarsnamnden.se', '2026-08-28 06:37:08.523755+00'),
	('f92c60a0-9d9f-4233-b14e-910c5755bed0', 'Allmänna arvsfonden', 'SE', 'foundation', 'https://www.arvsfonden.se', '2026-08-28 06:37:08.525383+00'),
	('a4c16732-1cab-49f4-aa1b-9f42017e707e', 'Boverket', 'SE', 'state_agency', 'https://www.boverket.se', '2026-08-28 06:37:08.526977+00'),
	('4fa14094-533e-424f-954c-e95a7fbfa3d6', 'Riksidrottsförbundet', 'SE', 'association', 'https://www.rf.se', '2026-08-28 06:37:08.528751+00'),
	('02beaa3b-6f6c-4c2e-94a7-275ff6586a8d', 'Svenska Filminstitutet', 'SE', 'foundation', 'https://www.filminstitutet.se', '2026-08-28 06:37:08.530387+00'),
	('f31d71e6-375b-46a4-93fa-9f540caa97a3', 'Formas', 'SE', 'state_agency', 'https://www.formas.se', '2026-08-28 06:37:08.53212+00'),
	('939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Försäkringskassan', 'SE', 'state_agency', 'https://www.forsakringskassan.se', '2026-08-28 06:37:08.533747+00'),
	('660a7af7-53b3-40a4-b392-c071182cda4d', 'CSN — Centrala studiestödsnämnden', 'SE', 'state_agency', 'https://www.csn.se', '2026-08-28 06:37:08.535327+00'),
	('111f47ca-2eb2-4ba9-bd04-621e03bc4d5c', 'Pensionsmyndigheten', 'SE', 'state_agency', 'https://www.pensionsmyndigheten.se', '2026-08-28 06:37:08.536842+00'),
	('7161944a-45cc-425b-89d3-2dd0d866af36', 'Socialtjänsten i din kommun', 'SE', 'municipality', 'https://www.socialstyrelsen.se', '2026-08-28 06:37:08.538758+00'),
	('c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', 'Arbetsförmedlingen', 'SE', 'state_agency', 'https://arbetsformedlingen.se', '2026-08-28 06:37:08.540386+00'),
	('36935f28-db77-48b2-91aa-8f90e800a97c', 'Din kommun', 'SE', 'municipality', NULL, '2026-08-28 06:37:08.542248+00'),
	('36d13066-e072-45f3-86cc-54c162975216', 'Riksantikvarieämbetet', 'SE', 'state_agency', 'https://www.raa.se', '2026-08-28 06:37:08.543746+00'),
	('7fdd8b51-44a5-4c65-8b01-5137f8ab95bf', 'Svenska institutet', 'SE', 'state_agency', 'https://si.se', '2026-08-28 06:37:08.545315+00'),
	('ceac41d8-0fd6-4712-addc-7db15bf2f6df', 'Nordisk kulturfond', 'DK', 'foundation', 'https://www.nordiskkulturfond.org', '2026-08-28 06:37:08.547139+00'),
	('92569e0b-676f-4c58-8091-3aa7acb4ea25', 'Vetenskapsrådet', 'SE', 'state_agency', 'https://www.vr.se', '2026-08-28 06:37:08.548713+00'),
	('7e5badf8-aa36-42df-aac6-442ceb8c60f7', 'Svenska Postkodstiftelsen', 'SE', 'foundation', 'https://postkodstiftelsen.se', '2026-08-28 06:37:08.550259+00'),
	('0198dd7d-a502-4fa3-bccc-2f995a3a1a4a', 'Statens musikverk', 'SE', 'state_agency', 'https://musikverket.se', '2026-08-28 06:37:08.551869+00'),
	('a5bb5cbb-ab9c-4a19-8df4-d6affb47c61a', 'Länsstyrelsen i ditt län', 'SE', 'region', 'https://www.lansstyrelsen.se', '2026-08-28 06:37:08.553445+00'),
	('40761d43-2fb0-4e5d-be71-eba0ef0f6b60', 'Din region', 'SE', 'region', 'https://www.1177.se', '2026-08-28 06:37:08.554915+00'),
	('e20d988c-65bc-424b-8c10-3e716ca2109f', 'Majblommans Riksförbund', 'SE', 'foundation', 'https://majblomman.se', '2026-08-28 06:37:08.558122+00'),
	('3319fedb-a0da-4bdb-bb79-9eb170f43967', 'Migrationsverket', 'SE', 'state_agency', 'https://www.migrationsverket.se', '2026-08-28 06:37:08.559866+00'),
	('cb6cf559-3bbe-48a6-b684-923c0d07a34c', 'Forte — Forskningsrådet för hälsa, arbetsliv och välfärd', 'SE', 'state_agency', 'https://forte.se', '2026-08-28 06:37:08.561399+00'),
	('5100e5a2-4de1-4c48-b268-a7b9060a4659', 'Sparbanksstiftelsen i ditt område', 'SE', 'foundation', 'https://www.sparbankerna.se', '2026-08-28 06:37:08.562917+00'),
	('6ee726a8-5cc8-47b0-aeb8-12c44b1de731', 'Radiohjälpen', 'SE', 'foundation', 'https://www.radiohjalpen.se', '2026-08-28 06:37:08.56456+00');


--
-- Data for Name: funding_opportunities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_opportunities VALUES
	('25fc0003-928b-4c7d-955f-3e152571b59c', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'f7fb9f9b-1393-43ff-a3a2-d55478c0221a', 'kulturradet-internationellt-resebidrag-musik', 'Kulturrådet — Resebidrag för internationellt kulturutbyte', 'Bidrag för internationella resor och utbyten för yrkesverksamma inom kulturområdet.', 'Stödet riktar sig till yrkesverksamma kulturskapare i Sverige som deltar i internationellt kulturutbyte, till exempel gästspel, samarbetsprojekt eller kompetensutveckling utomlands. Bidraget kan täcka resekostnader och relaterade omkostnader. Kontrollera alltid aktuella villkor hos Kulturrådet.', 'Främja internationellt kulturutbyte och svenska kulturskapares internationella närvaro.', 'travel_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-09-24 21:59:59+00', NULL, 'Ansökan görs i Kulturrådets onlinetjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', 'b1c62f7c-d93f-442c-b95e-e0c3a6f7a305', 'e79c5025-cd83-4526-b903-c1e8f06bb73e', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.637433+00', '2026-08-28 06:37:08.637433+00'),
	('d9899e9c-35a4-4278-aaae-07c1994ebcd4', 'f6694444-7bf3-49ad-a33f-a8258e72c318', '9fe8cbe5-da03-427e-9726-9e8cb51ac1dc', 'erasmus-plus-ungdomsutbyten', 'Erasmus+ — Ungdomsutbyten (Youth Exchanges)', 'EU-stöd för grupputbyten för unga 13–30 år, 5–21 dagar exklusive resdagar.', 'Ungdomsutbyten inom Erasmus+ låter grupper av unga från olika länder mötas i 5–21 dagar (exklusive resa) kring ett gemensamt program. Stödet täcker resekostnader samt praktiska kostnader och aktivitetskostnader enligt programguidens schabloner. Ansökan görs av en organisation eller informell grupp via det nationella programkontoret (i Sverige: MUCF för ungdomsdelen). Organisationen behöver ett OID (Organisation ID) via EU:s Organisation Registration System.', 'Interkulturellt lärande, ungas delaktighet och europeiskt samarbete.', 'eu_grant', '["association", "informal_group", "municipality"]', '["SE"]', '["youth", "culture", "education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, '2026-10-01 10:00:00+00', NULL, 'Ansökan lämnas i EU:s ansökningssystem för Erasmus+ (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'eu_login', 'assisted', 15, '', 'published', '3c600560-6c62-4b6c-890a-ce002dcd43c4', '6f46df8b-ec68-47ac-9c7e-cab26c89942d', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.648792+00', '2026-08-28 06:37:08.648792+00'),
	('eb518f74-aa9d-46da-9cf5-06261125137a', '39be3fc9-aad3-4934-bca7-7d23526d374a', 'ff1df6d6-da7b-4024-927c-773df81c55fc', 'mucf-projektbidrag-ungdomsorganisationer', 'MUCF — Projektbidrag för barn- och ungdomsorganisationer', 'Projektbidrag till ideella organisationer som arbetar med och för barn och unga.', 'MUCF fördelar statsbidrag till civilsamhällets organisationer, bland annat projektbidrag för verksamhet med och för barn och unga. Bidragen har specifika villkor per utlysning — kontrollera alltid aktuell utlysning hos MUCF.', 'Stärka ungas delaktighet och civilsamhällets verksamhet för barn och unga.', 'project_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i MUCF:s ansökningssystem när en utlysning är öppen.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', '6402cfa6-3246-410b-93c5-8f8eaf6554ff', '4c6d9dfa-d316-4ad4-af43-6c8469e17540', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.656175+00', '2026-08-28 06:37:08.656175+00'),
	('8b364654-fd29-417b-9e7b-d64d35924bf0', '3acf93e8-ba3b-4ea9-92a0-2730497c78b1', '73953897-f300-4074-b21f-25718276e643', 'vinnova-innovativa-startups', 'Vinnova — Innovativa startups', 'Finansiering för unga bolag som utvecklar nyskapande produkter eller tjänster med internationell potential.', 'Vinnovas program för innovativa startups riktar sig till unga svenska aktiebolag med skalbara, nyskapande lösningar. Utlysningar öppnar i omgångar med specifika villkor per omgång — kontrollera aktuell utlysning hos Vinnova. Bidraget kräver normalt att bolaget är yngre än en viss ålder och har begränsad omsättning.', 'Stärka svenska startups förmåga att utveckla och kommersialisera innovationer.', 'public_grant', '["company"]', '["SE"]', '["innovation", "technology"]', NULL, 30000000, 'SEK', 100, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst (Intressentportalen).', 'https://www.vinnova.se/soka-finansiering/', 'vinnova_konto', 'assisted', 10, '', 'published', '9eeb77fd-74ed-4f84-bfd9-b99548cd48b0', '8486e9f7-f910-4215-9263-d5476870fdf5', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.663774+00', '2026-08-28 06:37:08.663774+00'),
	('afda3d43-f3d9-4d77-b00e-63b03b39431e', '78dc70cc-5d4d-4859-afb8-9ebd577ddf7f', 'e68ff049-5f8e-4a79-8c81-82f4464c3354', 'energimyndigheten-energieffektivisering', 'Energimyndigheten — Stöd för energi- och klimatprojekt (löpande utlysningar)', 'Energimyndigheten öppnar löpande utlysningar inom energiforskning, innovation och energieffektivisering.', 'Det mesta av Energimyndighetens stöd fördelas via utlysningar som öppnar löpande inom olika områden. Ansökan och ärendehantering sker via Mina sidor. Villkoren varierar per utlysning — den här posten representerar programområdet; kontrollera aktuella utlysningar hos Energimyndigheten.', 'Energiomställning: forskning, innovation och effektivare energianvändning.', 'public_grant', '["company", "university", "public_body", "association", "economic_association"]', '["SE"]', '["energy", "environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 12, '', 'published', 'cdd45a9c-c767-4b7a-94d8-a31224c6a39b', 'cc78af50-3435-4a33-8981-dcffbe942311', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.672758+00', '2026-08-28 06:37:08.672758+00'),
	('cbe9dc6d-1d09-41be-b857-266b16f90f0e', 'e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'd9042b22-eee9-4a72-891f-a6a78dc6bbe9', 'naturvardsverket-ladda-bilen-organisationer', 'Naturvårdsverket — Bidrag för miljö- och klimatåtgärder (organisationer)', 'Naturvårdsverket erbjuder bidrag till organisationer, företag, föreningar, offentlig sektor och privatpersoner inom miljöområdet.', 'Naturvårdsverket administrerar flera bidrag inom miljö- och klimatområdet, uppdelade efter mottagartyp (organisationer, företag, ekonomiska föreningar, offentlig sektor och privatpersoner). Villkoren varierar per bidrag — den här posten representerar området; kontrollera aktuellt bidrag hos Naturvårdsverket.', 'Miljö- och klimatåtgärder i hela samhället.', 'public_grant', '["association", "company", "economic_association", "public_body", "individual"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänster.', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 6, '', 'published', '767c57d6-f3de-4349-b55d-18ce060bcd3d', '62014879-be16-44e8-8ded-cb3ffc965eb2', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.684125+00', '2026-08-28 06:37:08.684125+00'),
	('56f4edd5-3f05-4168-8302-e882071ab6e8', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', '28c637a6-c2ab-4ed9-9f05-ba4c816b0714', 'kulturradet-projektbidrag-musik', 'Kulturrådet — Projektbidrag musik (fria musiklivet)', 'Projektbidrag till det fria musiklivet för konserter, produktion och utveckling.', 'Kulturrådet fördelar projektbidrag till det fria musiklivet. Bidraget söks av grupper, arrangörer och organisationer inom musikområdet. Villkor och ansökningsperioder publiceras per omgång på Kulturrådets webbplats.', 'Ett levande och oberoende musikliv i hela landet.', 'project_grant', '["association", "company", "individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Kulturrådets onlinetjänst när omgången är öppen.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 7, '', 'published', '64f233d8-4d56-4b4a-9c7c-46ee332d7012', 'e79c5025-cd83-4526-b903-c1e8f06bb73e', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.696316+00', '2026-08-28 06:37:08.696316+00'),
	('ff1627ab-4213-488c-8741-e2da57c960f0', '2ca44d2f-388f-4994-aadf-46315d93ab08', '3b21f1da-4a86-4322-a276-d0d6e11c371d', 'konstnarsnamnden-internationellt-kulturutbyte', 'Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor', 'Bidrag för yrkesverksamma konstnärers internationella utbyten, resor och arbetsvistelser.', 'Konstnärsnämnden ger bidrag till yrkesverksamma konstnärer inom bild, form, dans, film, musik och teater för internationellt kulturutbyte — t.ex. resor för samarbeten, gästspel eller arbetsvistelser utomlands. Ansökningsomgångar publiceras per konstområde; kontrollera aktuella tider hos Konstnärsnämnden.', 'Konstnärers internationalisering och konstnärliga utveckling.', 'travel_grant', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 4, '', 'published', '6a336b40-7f8a-4f18-8fb0-897d8d0c7699', '1a379a88-5400-4cb3-bbc4-49ca474f2cd9', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.706908+00', '2026-08-28 06:37:08.706908+00'),
	('2c6560c9-f661-47f5-9830-570b9382ef5f', '2ca44d2f-388f-4994-aadf-46315d93ab08', 'aff48024-6041-4d98-ba90-4d78ac961145', 'konstnarsnamnden-arbetsstipendium', 'Konstnärsnämnden — Arbetsstipendium', 'Stipendium som ger yrkesverksamma konstnärer möjlighet att koncentrera sig på konstnärligt arbete.', 'Arbetsstipendiet ska ge yrkesverksamma konstnärer ekonomiskt utrymme att utveckla sitt konstnärskap. Söks per konstområde i årliga omgångar; villkor och tider publiceras av Konstnärsnämnden.', 'Konstnärlig fördjupning och försörjningstrygghet för yrkesverksamma konstnärer.', 'stipend', '["individual"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 6, '', 'published', '48de7818-1ae6-44d9-abd8-0d1f1bcb7d04', '1a379a88-5400-4cb3-bbc4-49ca474f2cd9', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.717194+00', '2026-08-28 06:37:08.717194+00'),
	('cd523901-ba90-46de-82a5-10b9a1a30403', 'f92c60a0-9d9f-4233-b14e-910c5755bed0', 'a4fb10ad-dbe4-43c4-883e-73792dd19eee', 'arvsfonden-projektstod', 'Allmänna arvsfonden — Projektstöd', 'Stöd till nyskapande projekt för barn, ungdomar, äldre och personer med funktionsnedsättning.', 'Arvsfonden stödjer ideella organisationers utvecklingsprojekt som är nyskapande och där målgruppen — barn, ungdomar, äldre eller personer med funktionsnedsättning — är delaktig. Ansökan kan lämnas löpande; projekt kan pågå i upp till tre år.', 'Nyskapande och utvecklande verksamhet för fondens målgrupper.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.arvsfonden.se/soka-pengar', 'none', 'assisted', 12, '', 'published', 'a00d1338-3d05-4304-a985-9f5236cdca3b', '947774fa-c20b-4c00-a517-493906d878eb', 'https://www.arvsfonden.se/soka-pengar', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.726576+00', '2026-08-28 06:37:08.726576+00'),
	('d7bcdcc1-8e69-4566-ba13-01c106b752d2', 'a4c16732-1cab-49f4-aa1b-9f42017e707e', '5770b226-10d6-442b-8c3a-167498d52988', 'boverket-allmanna-samlingslokaler', 'Boverket — Investeringsbidrag till allmänna samlingslokaler', 'Bidrag för att bygga, köpa eller rusta upp allmänna samlingslokaler.', 'Boverket ger investeringsbidrag till föreningar och stiftelser för nybyggnad, ombyggnad, köp eller standardhöjande reparationer av allmänna samlingslokaler — t.ex. bygdegårdar, folkets hus och föreningslokaler. Årlig ansökningsomgång; villkor publiceras av Boverket.', 'Tillgång till lokaler för möten, kultur och fritid i hela landet.', 'public_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "culture"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.boverket.se/sv/bidrag--garantier/', 'eid', 'assisted', 10, '', 'published', 'b44a5ba6-e11a-4112-a12d-6da291b80aed', '09e9e2b0-364f-49cc-86ec-e88cce84e4bc', 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.735703+00', '2026-08-28 06:37:08.735703+00'),
	('835a3969-745e-4083-a450-5463c3797743', '4fa14094-533e-424f-954c-e95a7fbfa3d6', '736d2627-1334-483f-af41-b7cd95b3d735', 'rf-lok-stod', 'Riksidrottsförbundet — Statligt lokalt aktivitetsstöd (LOK-stöd)', 'Aktivitetsstöd till idrottsföreningar för ledarledd verksamhet för barn och unga 7–25 år.', 'LOK-stödet ger idrottsföreningar anslutna till ett specialidrottsförbund ersättning per sammankomst och deltagartillfälle för ledarledd verksamhet för deltagare 7–25 år. Redovisas i IdrottOnline två gånger per år.', 'Stödja föreningsdriven barn- och ungdomsidrott.', 'public_grant', '["association"]', '["SE"]', '["sports", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, '2026-08-25 21:59:59+00', NULL, 'Ansökan/redovisning görs i IdrottOnline. Ansökningsperioderna stänger 25 februari och 25 augusti.', 'https://www.rf.se/bidrag-och-stod', 'none', 'assisted', 2, '', 'published', 'a82345d9-50b0-4068-b011-28f30448cb9e', 'b19e816b-1eb9-49f6-a511-eb288a1669f4', 'https://www.rf.se/bidrag-och-stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.744055+00', '2026-08-28 06:37:08.744055+00'),
	('8202cbd8-dd2a-4d59-a168-74a680a64406', '02beaa3b-6f6c-4c2e-94a7-275ff6586a8d', 'a529a1d5-92c7-4835-be75-869b957fe45f', 'filminstitutet-kortfilmsstod', 'Svenska Filminstitutet — Stöd till kort- och dokumentärfilm', 'Produktions- och utvecklingsstöd för kortfilm och dokumentärfilm.', 'Filminstitutet ger utvecklings- och produktionsstöd till kort- och dokumentärfilm. Stödet söks normalt av ett produktionsbolag; beslut fattas av filmkonsulent. Villkor och ansökningstider publiceras per stödform.', 'Konstnärligt värdefull svensk film.', 'project_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.filminstitutet.se/sv/sok-stod/', 'none', 'assisted', 8, '', 'published', '8fea73d7-39af-420d-a7de-1258f90001fc', 'f5702e99-2e62-4027-ad95-ae7c623a4b57', 'https://www.filminstitutet.se/sv/sok-stod/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.751375+00', '2026-08-28 06:37:08.751375+00'),
	('2e66a1f4-3dfc-403e-a301-415ec8f82ba3', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'f67ab935-8c8b-43fa-b7ee-a82db01c84df', 'kulturradet-skapande-skola', 'Kulturrådet — Skapande skola', 'Bidrag till skolhuvudmän för elevers möte med professionell kultur i grundskolan.', 'Skapande skola söks av skolhuvudmän (kommuner, fristående skolor) för konst- och kulturinsatser i förskoleklass och grundskola, genomförda av professionella kulturaktörer. Årlig ansökningsomgång.', 'Att alla elever ska få möta professionell konst och kultur.', 'public_grant', '["municipality", "school", "company"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 6, '', 'published', '0636ce4a-c6df-4ea8-b901-8e1a6bec3e79', 'e79c5025-cd83-4526-b903-c1e8f06bb73e', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.758269+00', '2026-08-28 06:37:08.758269+00'),
	('1fc1c37f-5a1a-482a-a2f3-e769512361fd', 'f31d71e6-375b-46a4-93fa-9f540caa97a3', '3c7ac2f4-511a-4e34-9ce2-4da7dd99fea8', 'formas-oppna-utlysningen', 'Formas — Årliga öppna utlysningen', 'Forskningsmedel inom miljö, areella näringar och samhällsbyggande.', 'Formas årliga öppna utlysning finansierar forskningsprojekt inom miljö, areella näringar och samhällsbyggande. Söks av disputerade forskare vid svenska lärosäten och forskningsinstitut. Årlig omgång med publicerade tider.', 'Kunskap för hållbar utveckling.', 'public_grant', '["university", "public_body"]', '["SE"]', '["environment", "innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.formas.se/soka-finansiering.html', 'none', 'assisted', 20, '', 'published', '9169b3f2-6da1-462a-8c6f-94775b07b164', '15ca77c2-87d8-45d3-bdc6-c20d58a6d2fc', 'https://www.formas.se/soka-finansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.766901+00', '2026-08-28 06:37:08.766901+00'),
	('453a03ca-a7a2-4872-bc21-521d33eeeba8', '3e461d3b-d656-45bf-934d-1dd28a281259', 'e51e7e39-fb24-40ea-8e73-9fe50d82820c', 'tillvaxtverket-affarsutvecklingscheckar', 'Tillväxtverket — Affärsutvecklingscheckar (internationalisering/digitalisering)', 'Checkar till små företag för att ta in extern kompetens vid internationalisering eller digitalisering.', 'Affärsutvecklingscheckarna hjälper små företag att köpa extern kompetens för att utvecklas internationellt eller digitalt. Checkarna administreras regionalt; belopp, andelar och tider varierar per region — kontrollera din regions aktuella utlysning.', 'Stärkt konkurrenskraft i små företag.', 'public_grant', '["company"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', 50, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) när regionens omgång är öppen.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 6, '', 'published', 'a5331a14-e101-47d5-9f40-dd2b565d177f', 'eb72880e-92bd-408e-8eb9-c9b6feb08472', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.776783+00', '2026-08-28 06:37:08.776783+00'),
	('9ca04c8f-d0ff-4aec-90f0-cc245a1a3a08', '766cb84e-b3bb-44f4-89c0-43236a4840af', '3ff8a33e-0a8f-4a30-88e9-a5212d21be0e', 'jordbruksverket-startstod-unga', 'Jordbruksverket — Startstöd till unga jordbrukare', 'Startstöd för den som är 40 år eller yngre och startar eller tar över ett jordbruksföretag.', 'Startstödet riktar sig till unga som startar eller tar över jordbruks-, trädgårds- eller rennäringsföretag. Kräver bl.a. åldersgräns, utbildning/erfarenhet och en affärsplan. Ansökan görs i Jordbruksverkets e-tjänst med e-legitimation.', 'Generationsväxling och föryngring i jordbruket.', 'public_grant', '["individual", "company"]', '["SE"]', '["agriculture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation; fullmakt kan användas).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', '7efe46d7-1324-48c1-b70a-7907caaaebb8', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.785181+00', '2026-08-28 06:37:08.785181+00'),
	('be537cef-44f7-475b-b728-2f95a43b3af6', '766cb84e-b3bb-44f4-89c0-43236a4840af', 'a3413e0c-2555-4961-8cdb-a29951a5c7c0', 'jordbruksverket-investeringsstod', 'Jordbruksverket — Investeringsstöd för jordbruk', 'Stöd för investeringar som ökar konkurrenskraften eller minskar miljöpåverkan i jordbruksföretag.', 'Investeringsstöd kan sökas för t.ex. djurstallar, växthus, energieffektivisering och miljöåtgärder i jordbruksföretag. Villkor, stödandelar och regionala prioriteringar framgår av aktuell stödinformation hos Jordbruksverket.', 'Konkurrenskraftigt och hållbart jordbruk.', 'public_grant', '["company", "individual", "economic_association"]', '["SE"]', '["agriculture", "environment"]', NULL, NULL, 'SEK', 40, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation).', 'https://jordbruksverket.se/stod', 'eid', 'assisted', 10, '', 'published', 'b4b43e36-9c71-4c0b-84f8-c52e4624ef3e', NULL, 'https://jordbruksverket.se/stod', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.793709+00', '2026-08-28 06:37:08.793709+00'),
	('b6b654c2-730a-47e1-8028-92d4e31eb0fb', 'f34e6a3d-e2ba-46b3-af33-8788090be0e0', '9007b396-a3b0-46c2-8a32-118071105e41', 'esf-kompetensutveckling', 'Svenska ESF-rådet — ESF+ projektstöd för kompetensutveckling och omställning', 'EU-socialfondsmedel för projekt som stärker kompetens, omställning och inkludering på arbetsmarknaden.', 'Svenska ESF-rådet utlyser projektmedel ur Europeiska socialfonden+ i regionala och nationella utlysningar, t.ex. kompetensutveckling för anställda och insatser för personer långt från arbetsmarknaden. Villkor och medfinansieringskrav framgår per utlysning i utlysningsplanen.', 'En väl fungerande och inkluderande arbetsmarknad.', 'eu_grant', '["company", "association", "municipality", "region", "public_body", "university"]', '["SE"]', '["education", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i ESF-rådets Projektrummet när en utlysning är öppen.', 'https://www.esf.se/utlysningar/', 'none', 'assisted', 15, '', 'published', '9ff94213-9aca-4cde-815b-c018674103e4', '004a212d-fc9e-47a5-ad68-7c7ee04c6719', 'https://www.esf.se/utlysningar/utlysningsplan/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.802033+00', '2026-08-28 06:37:08.802033+00'),
	('271a7349-54c2-4392-b174-b60de25c9ef3', '78dc70cc-5d4d-4859-afb8-9ebd577ddf7f', 'ea9a8646-f8b3-4033-85c4-334eefb73c0a', 'energimyndigheten-industriklivet', 'Energimyndigheten — Industriklivet', 'Stöd till industrins omställning mot noll utsläpp av växthusgaser.', 'Industriklivet stödjer forskning, förstudier och investeringar som minskar industrins processrelaterade utsläpp samt negativa utsläpp (t.ex. bio-CCS). Söks löpande eller i utlysningar via Mina sidor.', 'Industrins klimatomställning.', 'public_grant', '["company", "university", "public_body"]', '["SE"]', '["energy", "environment"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Energimyndighetens Mina sidor.', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/', 'eid', 'assisted', 15, '', 'published', 'ab9fc2f1-302a-4d66-aa79-90ab6761b059', 'cc78af50-3435-4a33-8981-dcffbe942311', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.811363+00', '2026-08-28 06:37:08.811363+00'),
	('7e7cb03c-5232-4b0e-b2a0-5dbfaf61bd66', 'e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'b9edcc44-6c04-441f-9fb3-44d3059701a3', 'naturvardsverket-klimatklivet', 'Naturvårdsverket — Klimatklivet', 'Investeringsstöd till åtgärder som minskar utsläppen av växthusgaser.', 'Klimatklivet ger investeringsstöd till företag, kommuner, regioner och organisationer för åtgärder som ger stor klimatnytta per stödkrona — t.ex. laddinfrastruktur, biogas och energikonvertering. Ansökningsomgångar öppnar flera gånger per år.', 'Minskade växthusgasutsläpp.', 'public_grant', '["company", "municipality", "region", "association", "economic_association", "public_body"]', '["SE"]', '["environment", "energy"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i Naturvårdsverkets e-tjänst när en omgång är öppen (kräver e-legitimation).', 'https://www.naturvardsverket.se/bidrag/', 'eid', 'assisted', 8, '', 'published', 'ed03fd16-2e04-4c9c-ab93-01b6b0a5c3b3', '62014879-be16-44e8-8ded-cb3ffc965eb2', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.819117+00', '2026-08-28 06:37:08.819117+00'),
	('c8cee1bf-40ac-4e22-a136-2d41d4ff89c8', 'e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'bcf38a56-f50b-454b-aad4-051ad2535db0', 'naturvardsverket-lona', 'Naturvårdsverket — Lokala naturvårdssatsningen (LONA)', 'Bidrag till kommunala och lokala naturvårdsprojekt, inklusive våtmarker och friluftsliv.', 'LONA ger upp till 50 % (våtmarksprojekt upp till 90 %) i bidrag till naturvårds- och friluftslivsprojekt. Kommunen ansöker hos länsstyrelsen, men lokala föreningar kan initiera projekt genom sin kommun.', 'Lokalt naturvårdsengagemang och friluftsliv.', 'public_grant', '["municipality"]', '["SE"]', '["environment"]', NULL, NULL, 'SEK', 50, false, '[]', 'recurring', NULL, NULL, NULL, 'Kommunen ansöker via länsstyrelsen; föreningar initierar via sin kommun.', 'https://www.naturvardsverket.se/bidrag/', 'none', 'assisted', 6, '', 'published', '9895af11-d00e-4035-86c4-4aa1562fd213', '62014879-be16-44e8-8ded-cb3ffc965eb2', 'https://www.naturvardsverket.se/bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.827786+00', '2026-08-28 06:37:08.827786+00'),
	('14316ca0-2bfd-4716-b43b-cbf29f41b1a8', '39be3fc9-aad3-4934-bca7-7d23526d374a', 'a52a29e2-d9ec-4534-8c28-3eb55ab5df15', 'mucf-solidaritetskaren-volontarprojekt', 'MUCF — Europeiska solidaritetskåren: volontärprojekt', 'EU-stöd för organisationer som tar emot eller sänder unga volontärer 18–30 år.', 'Europeiska solidaritetskåren finansierar volontärprojekt där unga 18–30 år gör volontärtjänst i ett annat land eller i Sverige. Organisationen behöver en kvalitetsmärkning (Quality Label) och ett OID. MUCF är nationellt programkontor.', 'Ungas engagemang och solidaritet i Europa.', 'eu_grant', '["association", "municipality", "public_body"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login, OID och Quality Label).', 'https://www.mucf.se/bidrag', 'eu_login', 'assisted', 12, '', 'published', 'b8a6b59b-2c02-4d1c-9d4d-0cb3948b5d28', '4c6d9dfa-d316-4ad4-af43-6c8469e17540', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.836027+00', '2026-08-28 06:37:08.836027+00'),
	('4311bf5f-f7db-4acd-ab1b-1368940ba16d', '1a4366ce-048a-404f-8d03-8b230c087f66', '250bb26b-c659-4e11-8289-77a21c655c24', 'erasmus-mobilitet-skola-vuxen', 'Erasmus+ — Mobilitet för skola och vuxenutbildning (KA1)', 'EU-stöd för personal- och elevmobilitet inom skola och vuxenutbildning.', 'Erasmus+ KA1 ger skolor, förskolor och vuxenutbildningsorganisationer stöd för kompetensutveckling utomlands — jobbskuggning, kurser och undervisningsuppdrag samt elevmobilitet. UHR är nationellt programkontor för utbildningsdelen. Kräver OID; årliga ansökningsomgångar.', 'Internationalisering av svensk utbildning.', 'eu_grant', '["school", "municipality", "company", "association", "public_body"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://www.uhr.se/internationella-mojligheter/', 'eu_login', 'assisted', 12, '', 'published', '8d268d1c-dbef-4643-b127-59d2774ef7cf', '03ab1d49-54cf-49e9-90d8-03006df99d56', 'https://www.uhr.se/internationella-mojligheter/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.844126+00', '2026-08-28 06:37:08.844126+00'),
	('43c0fb0d-c822-4ea0-9d77-c13d1b4027fb', 'f6694444-7bf3-49ad-a33f-a8258e72c318', '471410ac-35f8-4cbc-9ad6-2f49afb2bcbf', 'kreativa-europa-samarbetsprojekt', 'Kreativa Europa — Europeiska samarbetsprojekt (kultur)', 'EU-stöd för kulturorganisationers samarbetsprojekt med partner i flera europeiska länder.', 'Kreativa Europas kulturprogram finansierar samarbetsprojekt mellan kulturorganisationer i minst tre programländer. Kulturrådet är kontaktkontor i Sverige för kulturdelen. Ansökan görs i EU:s Funding & Tenders-portal; årliga utlysningar.', 'Europeiskt kultursamarbete och cirkulation av konstnärliga verk.', 'eu_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', 80, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s Funding & Tenders-portal (kräver EU Login och PIC/OID).', 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'eu_login', 'assisted', 25, '', 'published', '10f98b9a-f67d-4788-97d0-483dff1ebdd2', NULL, 'https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.852946+00', '2026-08-28 06:37:08.852946+00'),
	('73b4bbc3-bd59-49be-8be8-068551cd8c8a', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', '3e38be19-86d1-404c-8430-1cce1a7ee08b', 'kulturradet-verksamhetsbidrag-scenkonst', 'Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper', 'Fleråriga verksamhetsbidrag till professionella fria grupper inom dans, teater och musikteater.', 'Verksamhetsbidraget riktar sig till professionella fria scenkonstaktörer med kontinuerlig verksamhet av hög kvalitet. Söks i årlig omgång hos Kulturrådet.', 'Ett starkt fritt scenkonstliv i hela landet.', 'public_grant', '["association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 10, '', 'published', 'c18aaa28-eca6-4ed0-8a63-8ef69b691033', 'e79c5025-cd83-4526-b903-c1e8f06bb73e', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.8603+00', '2026-08-28 06:37:08.8603+00'),
	('c9a895bc-754d-4418-bc35-a624f1ee4c26', '3acf93e8-ba3b-4ea9-92a0-2730497c78b1', 'ac1a8888-44f1-49c0-ad52-71efcc6d5c10', 'vinnova-planeringsbidrag-eu', 'Vinnova — Planeringsbidrag för EU-ansökningar', 'Bidrag som hjälper svenska aktörer att förbereda ansökningar till EU-program som Horisont Europa.', 'Vinnova erbjuder återkommande planeringsbidrag som sänker tröskeln för svenska organisationer att söka EU-finansiering, t.ex. inför Horisont Europa-utlysningar och EIC Accelerator. Villkor per aktuell utlysning.', 'Ökat svenskt deltagande i EU:s ramprogram.', 'public_grant', '["company", "university", "public_body", "association"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i Vinnovas e-tjänst när en omgång är öppen.', 'https://www.vinnova.se/soka-finansiering/', 'none', 'assisted', 6, '', 'published', '1a4f92e6-a366-4136-bd81-3e5a7f104f20', '8486e9f7-f910-4215-9263-d5476870fdf5', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.867375+00', '2026-08-28 06:37:08.867375+00'),
	('3a7a9ef1-3826-4585-986b-eead34315d96', '39be3fc9-aad3-4934-bca7-7d23526d374a', 'a15d9092-0640-43d7-a92e-4be25eb70c1e', 'mucf-organisationsbidrag', 'MUCF — Organisationsbidrag till barn- och ungdomsorganisationer', 'Årligt organisationsbidrag till nationella barn- och ungdomsorganisationer.', 'Organisationsbidraget söks årligen av nationella barn- och ungdomsorganisationer som uppfyller krav på bl.a. medlemsantal, åldersstruktur, demokratisk uppbyggnad och geografisk spridning. Villkoren framgår av förordning och MUCF:s anvisningar.', 'Ett starkt och självständigt ungdomscivilsamhälle.', 'public_grant', '["association"]', '["SE"]', '["youth", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.mucf.se/bidrag', 'mucf_konto', 'assisted', 8, '', 'published', '2488cda9-4f2a-465b-8732-f75f5790e108', '4c6d9dfa-d316-4ad4-af43-6c8469e17540', 'https://www.mucf.se/bidrag', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.874277+00', '2026-08-28 06:37:08.874277+00'),
	('7de4083c-e86d-46dd-9a68-8fda8e4c70e8', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'ca02229e-18f9-480d-ab05-143724f4a6fc', 'fk-bostadsbidrag-barnfamiljer', 'Försäkringskassan — Bostadsbidrag till barnfamiljer', 'Ersättning som täcker en del av boendekostnaden för hushåll med barn och lägre inkomster.', 'Bostadsbidrag kan lämnas till barnfamiljer med lägre inkomster som betalar för sitt boende. Beloppet beror på inkomst, boendekostnad, bostadens storlek och antal barn. Ansökan görs hos Försäkringskassan; bidraget är preliminärt och stäms av mot taxerad inkomst i efterhand.', 'Ekonomisk trygghet i boendet för barnfamiljer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '51bc96dc-54cc-44f7-a18f-a60dc3aadeca', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.880941+00', '2026-08-28 06:37:08.880941+00'),
	('e619e017-66eb-4f25-adce-25802f110dc5', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', '5150a3b8-be57-482f-bdee-f6e33257cee2', 'fk-underhallsstod', 'Försäkringskassan — Underhållsstöd', 'Stöd när ett barn bor hos dig och den andra föräldern inte betalar underhåll.', 'Underhållsstöd kan lämnas när föräldrar inte bor ihop, barnet bor varaktigt hos dig och den andra föräldern inte betalar underhållsbidrag eller betalar mindre än stödets nivå. Ansökan görs hos Försäkringskassan.', 'Barnets försörjning när underhåll uteblir.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'f916f567-ce7d-403d-a45e-ac562d0e09a0', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.945861+00', '2026-08-28 06:37:08.945861+00'),
	('cd9b3d16-30ea-465c-ac09-cbce111bd03d', '111f47ca-2eb2-4ba9-bd04-621e03bc4d5c', 'ce277b0e-340b-4230-b02d-5a2f23b6abd4', 'pm-bostadstillagg', 'Pensionsmyndigheten — Bostadstillägg för pensionärer', 'Tillägg som täcker en del av boendekostnaden för dig som har pension och låga inkomster.', 'Bostadstillägg kan lämnas till den som tar ut hel allmän pension och har låga inkomster i förhållande till sin boendekostnad. Många som har rätt till tillägget söker det aldrig — det är värt att kontrollera. Ansökan görs hos Pensionsmyndigheten.', 'Ekonomisk trygghet i boendet för pensionärer.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Pensionsmyndighetens webbplats (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', '06312803-8c6d-49aa-9214-a2fb72809397', 'cd35bab9-42d7-4724-b6d4-575237e4ed68', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.95319+00', '2026-08-28 06:37:08.95319+00'),
	('c1a8f6f0-37a6-4ee9-8153-29890616e961', '111f47ca-2eb2-4ba9-bd04-621e03bc4d5c', '00a576e4-07e6-42d5-810e-0b63d786259f', 'pm-aldreforsorjningsstod', 'Pensionsmyndigheten — Äldreförsörjningsstöd', 'Behovsprövat stöd för dig som har låg eller ingen pension och behöver hjälp att nå en skälig levnadsnivå.', 'Äldreförsörjningsstöd kan lämnas från riktåldern för pension (67 år från 2026) till den som inte får sina grundläggande behov tillgodosedda genom pension och andra inkomster. Prövas tillsammans med bostadstillägg. Ansökan görs hos Pensionsmyndigheten.', 'Skälig levnadsnivå för äldre.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Pensionsmyndigheten (kräver e-legitimation).', 'https://www.pensionsmyndigheten.se/', 'eid', 'assisted', 1, '', 'published', 'f96a6b54-0a93-4d9f-b81b-6ccc1e40df99', 'cd35bab9-42d7-4724-b6d4-575237e4ed68', 'https://www.pensionsmyndigheten.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.960005+00', '2026-08-28 06:37:08.960005+00'),
	('466d2f40-862e-4bc3-9925-99aa9026a490', 'c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', '451ce1da-a016-4b68-b882-f47b961bee44', 'af-stod-start-naringsverksamhet', 'Arbetsförmedlingen — Stöd till start av näringsverksamhet', 'Ekonomiskt stöd under uppstarten för arbetssökande som startar eget företag.', 'Den som är inskriven som arbetssökande och bedöms ha goda förutsättningar att driva företag kan få stöd (aktivitetsstöd) under verksamhetens uppstartsfas. Beslut fattas av Arbetsförmedlingen efter prövning av affärsplanen.', 'Väg från arbetslöshet till egen försörjning.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Arbetsförmedlingen — kontakta din handläggare.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 5, '', 'published', 'c38dbb37-371f-4c36-9c93-3ee3e65b8083', 'ce9f0d1e-f5b6-40ea-aa94-9994a3c38e14', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.967035+00', '2026-08-28 06:37:08.967035+00'),
	('fe2a56a0-9de3-4c6b-a3ed-aecdc39a3761', '40761d43-2fb0-4e5d-be71-eba0ef0f6b60', '7be05897-bfd2-43f0-b752-42742d90152f', 'region-glasogonbidrag-barn', 'Din region — Glasögonbidrag för barn och unga (8–19 år)', 'Lagstadgat bidrag till glasögon eller linser för barn och unga; belopp och rutiner varierar per region — kontrollera din regions nivå.', 'Alla regioner är enligt lag (2016:35) skyldiga att ge bidrag för glasögon eller kontaktlinser till barn och unga 8–19 år som behöver synhjälpmedel. Lagen fastställer inget nationellt belopp — nivån bestäms per region och varierar. Ansökan sker oftast via optikern eller direkt till regionen — rutinerna skiljer sig, kontrollera din regions sidor och aktuellt belopp via 1177.', 'Alla barn ska ha råd med de synhjälpmedel de behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Vanligen via optikern eller regionens e-tjänst — se din regions rutin på 1177.se.', 'https://www.1177.se/', 'none', 'assisted', 1, '', 'published', 'ac6e3bae-b4e9-437b-8eb5-ec13df026650', '035b9485-2757-4183-a4a4-f64a0b28d67d', 'https://www.1177.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.888524+00', '2026-08-28 06:37:08.888524+00'),
	('1fab4f8c-e89d-45fc-b587-dcbf84c25791', 'e20d988c-65bc-424b-8c10-3e716ca2109f', 'c4990b5e-9f72-405d-bfde-5b08c1aa7cff', 'majblomman-bidrag-barn', 'Majblomman — Bidrag till barn i familjer där pengarna inte räcker', 'Bidrag till sådant ditt barn behöver men som ekonomin inte räcker till: fritidsaktiviteter, kläder, skolutflykter, glasögon, lovaktiviteter med mera.', 'Majblommans lokalföreningar ger bidrag till barn upp till 18 år i familjer med knapp ekonomi. Det kan gälla en fritidsaktivitet, en cykel, kläder, en klassresa eller något annat konkret som barnet behöver. Ansökan görs till den lokala majblommeföreningen där barnet bor och kan göras av vårdnadshavare eller via t.ex. skolsköterska.', 'Alla barn ska kunna delta i sådant som andra barn tar för givet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan till din lokala majblommeförening via majblomman.se.', 'https://majblomman.se/', 'none', 'assisted', 1, '', 'published', 'b30a5c25-e810-4e4f-8a94-aeb6e467868d', '99c8d938-7bfb-4c13-9395-5170f8cbbf8b', 'https://majblomman.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.89511+00', '2026-08-28 06:37:08.89511+00'),
	('4a4f671b-ab38-4dab-8f51-9bc2102a5fa6', '36935f28-db77-48b2-91aa-8f90e800a97c', 'c99a8edd-ebe4-4740-8575-84c5c7d3def6', 'kommun-skolskjuts', 'Din kommun — Skolskjuts i grundskolan', 'Kostnadsfri skolskjuts för grundskoleelever vid långt avstånd, trafikfarlig väg eller funktionsnedsättning — en rättighet enligt skollagen.', 'Elever i grundskolan har enligt skollagen (10 kap. 32 §) rätt till kostnadsfri skolskjuts från hemkommunen om det behövs på grund av färdvägens längd, trafikförhållanden, funktionsnedsättning eller någon annan särskild omständighet. Kommunerna har egna avståndsgränser och rutiner — ansökan görs hos barnets hemkommun.', 'Alla barn ska kunna ta sig till skolan utan kostnad när vägen är lång eller osäker.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos barnets hemkommun (e-tjänst eller blankett).', 'https://www.skolverket.se/', 'none', 'assisted', 1, '', 'published', '0d203d0a-1a0c-4c88-8491-4b7a69e6e00f', '28a7866f-689b-459e-8b26-9b3b1ade73d8', 'https://www.skolverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.902233+00', '2026-08-28 06:37:08.902233+00'),
	('8f509009-0626-497d-9b38-b478caea158a', '0198dd7d-a502-4fa3-bccc-2f995a3a1a4a', 'a5e3cf93-aa39-4c14-95d1-3c92d955f270', 'musikverket-projektbidrag', 'Statens musikverk — Projektbidrag till musiklivet', 'Stöd till samarbetsprojekt i det fria musiklivet.', 'Musikverket fördelar projektbidrag till professionella samarbetsprojekt i det fria musiklivet, med särskilt fokus på förnyelse och jämställdhet. Utlysningsomgångar publiceras på musikverket.se.', 'Ett vitalt fritt musikliv.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'upcoming_round', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://musikverket.se/', 'none', 'assisted', 6, '', 'published', 'e3998ef6-9be3-4cc3-8433-7ebd1c4d7a46', '03399ee2-48d9-4c05-acb5-501b1386e822', 'https://musikverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.037252+00', '2026-08-28 06:37:09.037252+00'),
	('6f654791-d039-4d71-8532-b2e88e0cb735', 'f6694444-7bf3-49ad-a33f-a8258e72c318', '91c79a3d-b009-499d-9194-5d65b0586cab', 'erasmus-ka2-smaskaliga-partnerskap', 'Erasmus+ — Småskaliga partnerskap (KA2)', 'EU-stöd med schablonbelopp för mindre organisationers första europeiska samarbetsprojekt.', 'Småskaliga partnerskap är utformade för att sänka tröskeln för organisationer som är nya i Erasmus+: färre krav, schablonbelopp (typiskt 30 000 eller 60 000 euro) och minst en partner i ett annat programland.', 'Bredda deltagandet i europeiskt samarbete.', 'eu_grant', '["association", "municipality", "school", "public_body"]', '["SE"]', '["education", "youth", "civil_society"]', NULL, NULL, 'SEK', NULL, true, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID).', 'https://erasmus-plus.ec.europa.eu/', 'eu_login', 'assisted', 10, '', 'published', '5ca6575a-1b87-4958-8ad9-8aa93be71b59', NULL, 'https://erasmus-plus.ec.europa.eu/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.044149+00', '2026-08-28 06:37:09.044149+00'),
	('27c88920-3da6-4d1e-96bf-8e58253d0942', '3e461d3b-d656-45bf-934d-1dd28a281259', 'd3f72e79-6a50-4a5d-b183-be1eef17fe76', 'tillvaxtverket-regionalt-investeringsstod', 'Tillväxtverket — Regionalt investeringsstöd', 'Investeringsstöd till företag i stödområden för byggnader, maskiner och utbildning.', 'Regionalt investeringsstöd kan delfinansiera större investeringar i stödområde A och B. Stödandel beror på område och företagsstorlek. Söks via Min ansökan.', 'Hållbar tillväxt i regioner med geografiska lägesnackdelar.', 'public_grant', '["company"]', '["SE"]', '[]', NULL, NULL, 'SEK', 35, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs via Min ansökan (Tillväxtverket) innan investeringen påbörjas.', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'eid', 'assisted', 12, '', 'published', 'a3eab676-1962-4f2c-8590-232af5cd4848', 'eb72880e-92bd-408e-8eb9-c9b6feb08472', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.051039+00', '2026-08-28 06:37:09.051039+00'),
	('d773388a-62f3-4036-a4ab-652a8c6565d0', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', '6e2def2a-2ffb-4caf-bb70-18ae1c813232', 'kulturradet-inkopsstod-bibliotek', 'Kulturrådet — Inköpsstöd till folk- och skolbibliotek', 'Bidrag till kommuner för inköp av litteratur till folk- och skolbibliotek.', 'Inköpsstödet söks av kommuner för att stärka bibliotekens utbud av litteratur för barn och unga. Årlig omgång.', 'Läsfrämjande och tillgång till litteratur.', 'public_grant', '["municipality"]', '["SE"]', '["culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 3, '', 'published', '3bdd4244-551a-431d-911c-05d934f5364b', 'e79c5025-cd83-4526-b903-c1e8f06bb73e', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.057852+00', '2026-08-28 06:37:09.057852+00'),
	('c49d5e2a-29cd-42f0-9978-cf90b1293d61', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', '6e2def2a-2ffb-4caf-bb70-18ae1c813232', 'kulturradet-litteraturstod', 'Kulturrådet — Litteraturstöd (efterhandsstöd till utgivning)', 'Efterhandsstöd till förlag för utgivning av kvalitetslitteratur.', 'Litteraturstödet är ett efterhandsstöd som förlag söker för utgiven kvalitetslitteratur inom olika kategorier. Beslut fattas av arbetsgrupper med litterär expertis.', 'Bredd och kvalitet i svensk bokutgivning.', 'public_grant', '["company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://kulturradet.se/sok-bidrag/', 'kulturradet_konto', 'assisted', 4, '', 'published', 'fff1bbd7-8f69-4492-ae1e-80137d475e5e', 'e79c5025-cd83-4526-b903-c1e8f06bb73e', 'https://kulturradet.se/sok-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.062859+00', '2026-08-28 06:37:09.062859+00'),
	('0b267398-f0fc-4518-a7f0-9c81dfb92e6e', '36935f28-db77-48b2-91aa-8f90e800a97c', 'faa1bba3-f771-45fe-b364-783f60b5c21c', 'kommun-elevresor-gymnasiet', 'Din kommun — Stöd för elevresor på gymnasiet', 'Hemkommunen ska stå för dagliga resor mellan bostad och gymnasieskola när färdvägen är minst sex kilometer (t.ex. busskort).', 'Enligt lag (1991:1110) ska hemkommunen ansvara för kostnader för dagliga resor mellan bostaden och gymnasieskolan för elever med studiehjälp, om färdvägen är minst sex kilometer. Stödet ges oftast som busskort/resekort och söks hos hemkommunen.', 'Gymnasieelever ska kunna ta sig till skolan oavsett var de bor.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan hos elevens hemkommun, vanligen inför varje läsår.', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'none', 'assisted', 1, '', 'published', 'd53a854b-fd9a-4c7c-928f-8282e78f769e', '875ab3e6-065d-42cb-b828-2ba3dc04eda9', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.911584+00', '2026-08-28 06:37:08.911584+00'),
	('80f5a94c-4c90-4bb8-93a1-fe4a319ffa6b', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'ca02229e-18f9-480d-ab05-143724f4a6fc', 'fk-bostadsbidrag-unga', 'Försäkringskassan — Bostadsbidrag för unga (18–28 år)', 'Ersättning för en del av boendekostnaden för unga utan barn med låga inkomster.', 'Unga mellan 18 och 28 år utan barn kan få bostadsbidrag om inkomsten är låg och boendekostnaden tillräckligt hög. Ansökan görs hos Försäkringskassan.', 'Ekonomisk trygghet i boendet för unga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation).', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', 'ac5938fa-d6c6-4579-8671-a93e83865ae3', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.917262+00', '2026-08-28 06:37:08.917262+00'),
	('fbc83baa-c179-4be7-b960-d11b95eb9681', '7161944a-45cc-425b-89d3-2dd0d866af36', '1259dfbb-de10-47c5-b2dc-cf650dbd3501', 'kommun-forsorjningsstod', 'Socialtjänsten — Försörjningsstöd (ekonomiskt bistånd)', 'Kommunens yttersta ekonomiska skyddsnät när inkomsterna inte räcker till det mest nödvändiga.', 'Försörjningsstöd kan beviljas av socialtjänsten i din kommun när du inte kan försörja dig själv och saknar tillgångar som kan täcka behoven. Stödet prövas individuellt utifrån hela hushållets ekonomi, och du förväntas först ha sökt andra ersättningar du kan ha rätt till. Ansökan görs hos din kommun.', 'Skälig levnadsnivå enligt socialtjänstlagen.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos socialtjänsten i din kommun — ofta via kommunens e-tjänst eller ett bokat besök.', 'https://www.socialstyrelsen.se/', 'none', 'assisted', 2, '', 'published', 'd43785f4-f1cd-4f37-adf4-db075242688d', '48ae2c3e-82e4-4417-8555-7b80358b5cee', 'https://www.socialstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.924571+00', '2026-08-28 06:37:08.924571+00'),
	('e680dd41-94d3-49c4-9820-ee1e6d1484b6', '660a7af7-53b3-40a4-b392-c071182cda4d', '0f7fe17f-6052-47b1-b62b-9ed628e84ab3', 'csn-studiemedel', 'CSN — Studiemedel (bidrag och studielån)', 'Bidrag och frivilligt lån för dig som studerar på gymnasial eller eftergymnasial nivå.', 'Studiemedel består av en bidragsdel och en frivillig lånedel för studier i Sverige eller utomlands. Kraven gäller bl.a. studiernas omfattning, tidigare studieresultat och ålder. Ansökan görs hos CSN.', 'Ekonomiska möjligheter att studera.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i Mina sidor hos CSN (kräver e-legitimation).', 'https://www.csn.se/', 'eid', 'assisted', 1, '', 'published', '533227b8-561c-4c0e-a13e-380ceb12d222', 'c30250ee-b923-4188-b3af-b17eb37654e4', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.931741+00', '2026-08-28 06:37:08.931741+00'),
	('67621f48-caa3-4a16-9e32-db010748c2e0', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'e802fa8e-9b0b-4f57-aee4-90746a8789f6', 'fk-aktivitetsersattning', 'Försäkringskassan — Aktivitetsersättning vid nedsatt arbetsförmåga', 'Ersättning för unga (19–29 år) som inte kan arbeta heltid under minst ett år på grund av sjukdom eller funktionsnedsättning.', 'Aktivitetsersättning kan lämnas till den som är 19–29 år och har arbetsförmågan nedsatt med minst en fjärdedel under minst ett år. Läkarutlåtande krävs. Ansökan görs hos Försäkringskassan; beslutet fattas efter medicinsk utredning.', 'Ekonomisk trygghet vid långvarigt nedsatt arbetsförmåga.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan tillsammans med läkarutlåtande.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '6f0ad0b4-087c-454a-9d3f-c3f437ef202a', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.938899+00', '2026-08-28 06:37:08.938899+00'),
	('f03a86f0-1368-4293-8016-10b8ce58b9ab', '660a7af7-53b3-40a4-b392-c071182cda4d', '1fec1480-5a61-4531-9398-1f7998e7c925', 'csn-omstallningsstudiestod', 'CSN — Omställningsstudiestöd', 'Studiestöd för yrkesverksamma vuxna som vill utbilda sig för att stärka sin ställning på arbetsmarknaden.', 'Omställningsstudiestödet riktar sig till dig som arbetat länge och vill studera för att bli mer attraktiv på arbetsmarknaden. Kräver bl.a. etablering på arbetsmarknaden (arbetade år) och att utbildningen stärker din framtida ställning. Söktrycket är högt och handläggningstiderna kan vara långa.', 'Omställning och kompetensutveckling mitt i arbetslivet.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN; omställningsorganisationen kan komplettera med kollektivavtalat stöd.', 'https://www.csn.se/', 'eid', 'assisted', 3, '', 'published', 'bc209782-c01b-4c6c-9d32-74090be9c021', 'c30250ee-b923-4188-b3af-b17eb37654e4', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.974858+00', '2026-08-28 06:37:08.974858+00'),
	('8a676a8e-9dbb-44e5-8b1c-81cc00d6f4ef', '36935f28-db77-48b2-91aa-8f90e800a97c', 'c0fdc00c-a830-40c8-add4-7b92d6a41c97', 'kommun-bostadsanpassningsbidrag', 'Din kommun — Bostadsanpassningsbidrag', 'Bidrag för att anpassa bostaden vid funktionsnedsättning — t.ex. ramper, dörröppnare eller badrumsanpassning.', 'Bostadsanpassningsbidraget är ett kommunalt bidrag enligt lag för den som har en bestående funktionsnedsättning och behöver anpassa sin permanentbostad. Intyg från t.ex. arbetsterapeut krävs. Ansökan görs hos kommunen.', 'Självständigt liv i egen bostad.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos din kommun, ofta via e-tjänst eller blankett, med intyg.', 'https://www.boverket.se/sv/bidrag--garantier/', 'none', 'assisted', 3, '', 'published', 'c749f036-02fe-4d78-b293-4b481a2b6b5d', NULL, 'https://www.boverket.se/sv/bidrag--garantier/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.982486+00', '2026-08-28 06:37:08.982486+00'),
	('c8811d54-331b-44e3-8a17-1402e50695fb', '2ca44d2f-388f-4994-aadf-46315d93ab08', '6c3011e7-61d5-44f1-ab7f-c0a45f0d53c2', 'konstnarsnamnden-kulturbryggan', 'Konstnärsnämnden — Kulturbryggan', 'Stöd till nyskapande kulturprojekt som prövar nya konstnärliga uttryck, metoder eller samarbeten.', 'Kulturbryggan är Konstnärsnämndens stöd till kulturprojekt som är nyskapande i förhållande till etablerade uttryck och strukturer. Söks i utlysningsomgångar av både enskilda och organisationer.', 'Förnyelse och experiment i kulturlivet.', 'project_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'none', 'assisted', 8, '', 'published', 'f80b9168-7721-4940-9e02-a5f7e164eace', '1a379a88-5400-4cb3-bbc4-49ca474f2cd9', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:08.991461+00', '2026-08-28 06:37:08.991461+00'),
	('6b502145-5fdc-44f2-8502-d2e601d0695a', '36d13066-e072-45f3-86cc-54c162975216', 'bd1783a0-38d8-47b8-9b82-b4f3c5f23a88', 'raa-kulturarvsbidrag', 'Riksantikvarieämbetet — Bidrag till kulturarvsarbete', 'Bidrag till ideella organisationers arbete med att bevara, använda och utveckla kulturarvet.', 'Riksantikvarieämbetet fördelar årligen bidrag till ideellt kulturarvsarbete — t.ex. hembygdsrörelsen och arbetslivsmuseer. Årlig ansökningsomgång.', 'Ett levande och tillgängligt kulturarv.', 'public_grant', '["association", "foundation"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.raa.se/', 'none', 'assisted', 6, '', 'published', '4a4c1cf6-519d-41dc-a966-10739af85bd2', 'a524b355-78e0-451a-a216-dc2ecb7e3227', 'https://www.raa.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.000424+00', '2026-08-28 06:37:09.000424+00');
INSERT INTO public.funding_opportunities VALUES
	('71346c42-e1dc-4e52-91f8-09cbd99c25fe', '7fdd8b51-44a5-4c65-8b01-5137f8ab95bf', '99e91d62-c5c5-4779-826e-a0b969cfdd57', 'si-creative-force', 'Svenska institutet — Creative Force', 'Stöd till samarbetsprojekt inom kultur och media som stärker demokrati och yttrandefrihet internationellt.', 'Creative Force ger stöd till svenska organisationers samarbetsprojekt med partner i vissa länder, där kultur eller media används som verktyg för demokrati, jämlikhet och yttrandefrihet. Länderlista och villkor per utlysning.', 'Demokrati och yttrandefrihet genom kultur och media.', 'project_grant', '["association", "company", "foundation", "public_body"]', '["SE"]', '["culture", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://si.se/', 'none', 'assisted', 10, '', 'published', 'fd53a395-60ec-4d0c-b038-66a42d24400c', '7337e00b-0b9f-4e93-a6b8-3089c0dfa75e', 'https://si.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.008838+00', '2026-08-28 06:37:09.008838+00'),
	('8f3ec4cc-9ead-43cc-a03f-d2ae3978d1de', 'ceac41d8-0fd6-4712-addc-7db15bf2f6df', '616bbe96-7035-4afe-b708-10f069a3e2ac', 'nordisk-kulturfond-projektstod', 'Nordisk kulturfond — Projektstöd', 'Stöd till konst- och kulturprojekt med nordisk dimension och samarbete över landsgränser.', 'Nordisk kulturfond stödjer projekt som utvecklar konst- och kulturlivet i Norden och involverar flera nordiska länder. Flera ansökningsfrister per år.', 'Ett dynamiskt nordiskt konst- och kulturliv.', 'project_grant', '["individual", "association", "company", "public_body"]', '["SE", "DK", "NO", "FI", "IS"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.nordiskkulturfond.org/', 'none', 'assisted', 8, '', 'published', '95299261-a762-4418-911c-ca8e08ad2c0b', 'bc502111-2477-4eb8-8178-8e9fbc0f4b5b', 'https://www.nordiskkulturfond.org/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.016041+00', '2026-08-28 06:37:09.016041+00'),
	('3a85807a-d380-4685-8b21-23781ebb6f28', '92569e0b-676f-4c58-8091-3aa7acb4ea25', '23681367-dee0-4f6e-95db-a926c96c148b', 'vr-projektbidrag', 'Vetenskapsrådet — Projektbidrag (fri forskning)', 'Forskningsmedel för fri grundforskning inom alla vetenskapsområden.', 'Vetenskapsrådets projektbidrag söks av disputerade forskare via svenska lärosäten i årliga utlysningar per ämnesområde.', 'Forskning av högsta vetenskapliga kvalitet.', 'public_grant', '["university"]', '["SE"]', '["innovation"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://www.vr.se/', 'none', 'assisted', 20, '', 'published', '57f2df6c-6a56-4f95-8f82-139e10381bcf', '360d9b45-040e-4e91-81e0-19363a0b04d4', 'https://www.vr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.023623+00', '2026-08-28 06:37:09.023623+00'),
	('70716ddc-c4fa-4a5f-88c7-bcaf6fb8e1f2', '7e5badf8-aa36-42df-aac6-442ceb8c60f7', '46a9b633-871d-41a3-8216-b284949da01a', 'postkodstiftelsen-projektstod', 'Svenska Postkodstiftelsen — Projektstöd', 'Stöd till ideella organisationers projekt för människor, miljö och en bättre värld.', 'Postkodstiftelsen stödjer ideella organisationer med projekt inom bl.a. mänskliga rättigheter, miljö och kultur. Ansökan kan lämnas löpande via stiftelsens webbplats.', 'Positiv förändring för människor och miljö.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "environment", "culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs i finansiärens officiella ansökningstjänst.', 'https://postkodstiftelsen.se/', 'none', 'assisted', 8, '', 'published', '7a55a03e-75fe-4add-808a-2285df8e775a', '5e24ee88-46ea-4c2a-876d-ae327a37766c', 'https://postkodstiftelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.031091+00', '2026-08-28 06:37:09.031091+00'),
	('54230320-23ec-4d2c-aad0-5d1821a6e719', 'a5bb5cbb-ab9c-4a19-8df4-d6affb47c61a', 'd4bbf1e5-69fe-4465-9ddb-27604576655f', 'lansstyrelsen-bygdemedel', 'Länsstyrelsen — Bygdemedel', 'Bidrag ur vattenkrafts- och vindkraftsmedel till projekt som utvecklar bygden.', 'Bygdemedel är ersättningar från vattenkraft (och i vissa län vindkraft) som återförs till berörda bygder. Föreningar och kommuner kan söka för t.ex. samlingslokaler, leder och bygdeutveckling. Villkor varierar per län.', 'Lokal utveckling i berörda bygder.', 'public_grant', '["association", "municipality"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos länsstyrelsen i ditt län, ofta via e-tjänst.', 'https://www.lansstyrelsen.se/', 'eid', 'assisted', 6, '', 'published', '2fa8f043-82f4-401f-b061-6a6d8283973f', 'b2645e26-9fc7-4bb4-b641-0ba67dca9d9b', 'https://www.lansstyrelsen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.06917+00', '2026-08-28 06:37:09.06917+00'),
	('9fba8a2d-c848-4524-b689-9641d687bc7b', '3319fedb-a0da-4bdb-bb79-9eb170f43967', 'a4bf0813-d57a-434e-9b2c-b621ee1df945', 'migrationsverket-atervandringsbidrag', 'Migrationsverket — Stöd vid frivillig återvandring', 'Ekonomiskt stöd för den som har skyddsrelaterat uppehållstillstånd och frivilligt vill flytta tillbaka till sitt ursprungsland permanent.', 'Den som har uppehållstillstånd som flykting eller skyddsbehövande (samt vissa anhöriga) och frivilligt vill återvandra permanent kan ansöka om bidrag till resa och återetablering. Schablonbeloppen är beslutade att höjas väsentligt från 2026 — kontrollera aktuella belopp och villkor hos Migrationsverket innan beslut. Beslutet att återvandra är oåterkalleligt i bidragshänseende: uppehållstillståndet återkallas normalt.', 'Möjliggöra frivillig, värdig återvandring för den som själv vill.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Migrationsverket före utresan.', 'https://www.migrationsverket.se/', 'none', 'assisted', 3, '', 'published', 'f3360ce7-99b0-4cd8-9759-689e5b974c96', '858f3d34-6a06-477d-b335-dc2bab8d1cff', 'https://www.migrationsverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.076032+00', '2026-08-28 06:37:09.076032+00'),
	('ced6ee83-5399-40f8-ba50-f95da7474302', 'c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', 'eae41226-2dc2-433b-9e07-0218d705af8c', 'af-eures-targeted-mobility', 'EURES — Targeted Mobility Scheme (jobb i annat EU-land)', 'EU-finansierat stöd för arbetssökande som tar jobb i ett annat EU-/EES-land: ersättning för intervjuresa, flyttkostnader och språkkurs.', 'EU:s riktade rörlighetsprogram hjälper arbetssökande från 18 år att ta anställning i ett annat EU-/EES-land. Stödet kan omfatta bidrag till intervjuresa, flytt, språkkurs och erkännande av kvalifikationer — beloppen är schabloner per insats och land och varierar per programperiod. Vägen in är EURES-rådgivarna hos Arbetsförmedlingen.', 'Rörlighet på den europeiska arbetsmarknaden.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta en EURES-rådgivare via Arbetsförmedlingen — ansökan görs innan flytten/resan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', 'db8b369d-2d74-431a-8302-1dde671db650', 'ce9f0d1e-f5b6-40ea-aa94-9994a3c38e14', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.082565+00', '2026-08-28 06:37:09.082565+00'),
	('adac47e7-e7bb-40da-bc3a-a58a631fc904', '660a7af7-53b3-40a4-b392-c071182cda4d', '0f7fe17f-6052-47b1-b62b-9ed628e84ab3', 'csn-utlandsstudier', 'CSN — Studiemedel för utlandsstudier', 'Bidrag och lån för studier utomlands, med extra merkostnadslån för t.ex. terminsavgifter och resor.', 'Studiemedel kan tas med till studier utomlands på utbildningar som uppfyller CSN:s krav. Utöver ordinarie bidrag och lån finns merkostnadslån för undervisningsavgifter, resor och försäkring. Utbildningen och skolan ska vara godkänd — kontrollera i CSN:s tjänst innan du tackar ja till en plats.', 'Göra utlandsstudier möjliga oavsett privatekonomi.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan görs hos CSN med e-legitimation.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '73bf350d-e04d-4d8f-a6d8-9b9c04d095a4', 'c30250ee-b923-4188-b3af-b17eb37654e4', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.087222+00', '2026-08-28 06:37:09.087222+00'),
	('e5f98200-7495-4257-800b-db3b2ec2791e', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'b4630507-250d-4c74-b2b7-aac883cad13b', 'fk-omvardnadsbidrag', 'Försäkringskassan — Omvårdnadsbidrag för barn med funktionsnedsättning', 'Ersättning till föräldrar vars barn på grund av funktionsnedsättning behöver mer omvårdnad och tillsyn än barn i samma ålder.', 'Omvårdnadsbidrag kan lämnas till vårdnadshavare för barn med funktionsnedsättning som behöver mer omvårdnad och tillsyn än jämnåriga. Bidraget finns i fyra nivåer utifrån barnets sammanlagda behov och kan lämnas till och med juni det år barnet fyller 19. Ansökan görs hos Försäkringskassan; ett läkarutlåtande om barnets funktionsnedsättning behövs.', 'Ge föräldrar ekonomiskt utrymme för den extra omvårdnad barnet behöver.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); läkarutlåtande bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', '2c15b832-8186-436d-803c-f5e1d06d7440', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.093377+00', '2026-08-28 06:37:09.093377+00'),
	('3f11e339-c106-4d69-9fdc-c5208bf2acdc', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', '3979daae-92a2-47c9-adb1-9b9e3472bd93', 'fk-merkostnadsersattning', 'Försäkringskassan — Merkostnadsersättning vid funktionsnedsättning', 'Ersättning för merkostnader som en varaktig funktionsnedsättning för med sig — för vuxna, eller för föräldrar till barn med funktionsnedsättning.', 'Merkostnadsersättning kan lämnas när en varaktig funktionsnedsättning medför merkostnader — t.ex. slitage, hjälpmedel, resor eller särskild kost. Ersättningen finns i fem nivåer och kräver att merkostnaderna når upp till en lägsta nivå per år (knuten till prisbasbeloppet). Både vuxna med funktionsnedsättning och vårdnadshavare för barn kan ansöka hos Försäkringskassan.', 'Utjämna de extra kostnader en funktionsnedsättning medför.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); merkostnaderna specificeras.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 2, '', 'published', '639d7d42-92c5-49a0-92bc-8e6cea858a47', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.100631+00', '2026-08-28 06:37:09.100631+00'),
	('dca6e66a-b48c-4b6f-a3b6-7b3ced4b026e', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'c2f41c23-ad46-4479-b26d-9dd569bcc8d2', 'fk-bilstod', 'Försäkringskassan — Bilstöd vid funktionsnedsättning', 'Bidrag för att köpa eller anpassa en bil när en varaktig funktionsnedsättning gör det mycket svårt att förflytta sig eller resa kollektivt.', 'Bilstöd kan lämnas till den som har en varaktig funktionsnedsättning med stora svårigheter att förflytta sig på egen hand eller att använda allmänna kommunikationer — och till föräldrar till barn med sådan funktionsnedsättning. Stödet består av flera delar: grundbidrag, inkomstprövat anskaffningsbidrag och anpassningsbidrag för särskild utrustning. Nytt bilstöd kan normalt beviljas först efter nio år.', 'Göra det möjligt att förflytta sig självständigt när kollektivtrafik inte fungerar.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos Försäkringskassan; läkarutlåtande om funktionsnedsättningen och körkortsuppgifter behövs.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 3, '', 'published', '9532fc26-c5f9-4c3c-8bb9-ad3996be254f', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.107267+00', '2026-08-28 06:37:09.107267+00'),
	('c4fa7013-d021-49dc-b9f1-2dfe8775b2f5', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', '159d3e41-45eb-434d-a991-69f35fe57c3c', 'fk-narstaendepenning', 'Försäkringskassan — Närståendepenning', 'Ersättning när du avstår från arbete för att vara nära en svårt sjuk närstående.', 'Närståendepenning kan lämnas när du avstår från förvärvsarbete för att vårda eller vara nära en närstående med en sjukdom som innebär ett påtagligt hot mot livet. Ersättningen kan betalas i upp till 100 dagar per person som vårdas (dagarna kan delas mellan flera närstående). Läkarutlåtande om den sjukes tillstånd och den sjukes samtycke krävs.', 'Ingen ska behöva välja mellan sin försörjning och att finnas hos en svårt sjuk anhörig.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs på Mina sidor hos Försäkringskassan; läkarutlåtande och den sjukes samtycke bifogas.', 'https://www.forsakringskassan.se/privatperson', 'eid', 'assisted', 1, '', 'published', '404d0f44-5ff3-413a-a555-0dd296714ed5', '64f925b5-b0b6-4a28-bca9-1dba816efff9', 'https://www.forsakringskassan.se/privatperson', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.11622+00', '2026-08-28 06:37:09.11622+00'),
	('6365ebcf-a41b-4568-87fb-50c7bd647274', 'c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', 'b285c37b-be0c-4d4c-b95e-41994fe820e3', 'af-etableringsersattning', 'Arbetsförmedlingen — Etableringsersättning för nyanlända', 'Ersättning för den som är ny i Sverige och deltar i etableringsprogrammet hos Arbetsförmedlingen; betalas ut av Försäkringskassan.', 'Den som nyligen fått uppehållstillstånd (som skyddsbehövande eller vissa anhöriga) och är 20–66 år kan delta i Arbetsförmedlingens etableringsprogram och få etableringsersättning under tiden. Den som har barn eller bor ensam i egen bostad kan även få etableringstillägg respektive bostadsersättning. Arbetsförmedlingen beslutar om programmet; Försäkringskassan beslutar om och betalar ut ersättningen.', 'Försörjning under de första årens etablering i arbets- och samhällslivet.', 'social_benefit', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Skriv in dig hos Arbetsförmedlingen; ersättningen ansöks sedan hos Försäkringskassan.', 'https://arbetsformedlingen.se/', 'none', 'assisted', 2, '', 'published', 'b23d20e6-9ec4-4681-9112-a4d2421325c6', 'ce9f0d1e-f5b6-40ea-aa94-9994a3c38e14', 'https://arbetsformedlingen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.122962+00', '2026-08-28 06:37:09.122962+00'),
	('ed1b1caa-4a62-4bcb-9804-7d0119671895', '660a7af7-53b3-40a4-b392-c071182cda4d', '7dad446c-96ab-4dfc-a205-ffc7bee93d4f', 'csn-hemutrustningslan', 'CSN — Hemutrustningslån för nyanlända', 'Lån för att köpa det mest nödvändiga till ett första hem i Sverige — möbler, husgeråd och annan grundutrustning.', 'Hemutrustningslån kan lämnas till flyktingar och vissa anhöriga som tagits emot i en kommun och behöver utrusta ett första hem i Sverige. Lånet söks hos CSN inom två år från det första kommunmottagandet, har låg ränta och betalas tillbaka enligt en plan som tar hänsyn till inkomst. Det är ett lån — inte ett bidrag — och ska betalas tillbaka.', 'Ett fungerande hem från start, utan att behöva vända sig till dyra krediter.', 'loan', '["individual"]', '["SE"]', '[]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Ansökan görs hos CSN; kommunmottagandet styr vilka som kan söka.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', 'a72f154f-d3b4-4d06-b189-c0090476a1ce', 'c30250ee-b923-4188-b3af-b17eb37654e4', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.130367+00', '2026-08-28 06:37:09.130367+00'),
	('10f619cd-7abf-46fe-8bd8-e85a6ead2ce0', '660a7af7-53b3-40a4-b392-c071182cda4d', '65953379-6047-4a9d-a637-b685e54db82f', 'csn-studiestartsstod', 'CSN — Studiestartsstöd för arbetslösa med kort utbildning', 'Bidrag utan lånedel för arbetslösa 25–60 år med kort tidigare utbildning som behöver studera på grundskole- eller gymnasienivå.', 'Studiestartsstöd är ett rent bidrag (ingen lånedel) för den som är 25–60 år, har varit arbetslös, har kort tidigare utbildning och behöver studera på grundskole- eller gymnasienivå för att stärka sina chanser till jobb. Stödet kan lämnas i upp till 50 veckor. Hemkommunen bedömer om du tillhör målgruppen; ansökan görs sedan hos CSN.', 'Sänka tröskeln till studier för den som behöver dem mest.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta hemkommunen (målgruppsbedömning) och ansök därefter hos CSN.', 'https://www.csn.se/', 'eid', 'assisted', 2, '', 'published', '705a28f0-ab47-43a0-901a-410ad698adbb', 'c30250ee-b923-4188-b3af-b17eb37654e4', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.137351+00', '2026-08-28 06:37:09.137351+00'),
	('d2f4ebc9-32bf-4e94-9a2d-455089de3842', '660a7af7-53b3-40a4-b392-c071182cda4d', '40d0611f-a6c7-4b80-9fe5-9bf3d0169849', 'csn-inackorderingstillagg', 'CSN — Inackorderingstillägg för gymnasieelever som bor på studieorten', 'Bidrag till boende och hemresor när en gymnasieelev måste bo på studieorten på grund av lång resväg.', 'Elever på fristående gymnasieskolor och folkhögskolor som måste inackordera sig på studieorten på grund av lång eller besvärlig resväg kan få inackorderingstillägg från CSN. Går eleven på en kommunal gymnasieskola är det i stället hemkommunen som ger stöd till inackordering — kontrollera med kommunen. Tillägget söks för varje läsår.', 'Gymnasievalet ska inte begränsas av var i landet utbildningen finns.', 'educational_support', '["individual"]', '["SE"]', '["education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos CSN (fristående skola/folkhögskola) eller hos hemkommunen (kommunal skola), inför varje läsår.', 'https://www.csn.se/', 'none', 'assisted', 1, '', 'published', 'b243629b-aa18-4232-8156-8c98066b6566', 'c30250ee-b923-4188-b3af-b17eb37654e4', 'https://www.csn.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.14478+00', '2026-08-28 06:37:09.14478+00'),
	('e3296bd2-2fb0-47de-88c2-b54e4854bd8c', '36935f28-db77-48b2-91aa-8f90e800a97c', '1dacfdbe-8ef9-46c3-9e7f-9b2220e6da45', 'kommun-foreningsbidrag', 'Din kommun — Föreningsbidrag (aktivitets-, lokal- och startbidrag)', 'Kommunernas egna stöd till det lokala föreningslivet: aktivitetsstöd per deltagartillfälle, lokalbidrag, startbidrag med mera.', 'I stort sett alla kommuner ger bidrag till lokala föreningar — vanligast är aktivitetsstöd per deltagartillfälle för barn- och ungdomsverksamhet, bidrag till lokalhyra och startbidrag för nya föreningar. Regler, belopp och ansökningstider skiljer sig åt mellan kommuner; ansökan görs hos kultur- och fritidsförvaltningen i den kommun där föreningen är verksam.', 'Ett levande lokalt föreningsliv med låga trösklar för deltagande.', 'public_grant', '["association"]', '["SE"]', '["civil_society", "sports", "culture", "youth"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos kommunens kultur- och fritidsförvaltning — rutiner och tider varierar per kommun.', 'https://www.skr.se/', 'none', 'assisted', 2, '', 'published', '8904d5e2-dcf4-4424-a3c2-6d5e398c03da', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.153059+00', '2026-08-28 06:37:09.153059+00'),
	('0f5b852f-f437-476f-8dc3-bb431435bfdd', '40761d43-2fb0-4e5d-be71-eba0ef0f6b60', 'a4f388ff-84e2-4d1b-9efd-7a18b6d6f70d', 'region-kulturstod', 'Din region — Regionala kulturstöd och projektbidrag', 'Regionernas egna projekt- och verksamhetsstöd till kulturlivet, vid sidan av Kulturrådets nationella bidrag.', 'Alla regioner fördelar egna kulturstöd — projektbidrag, arrangörsstöd och stipendier — inom kultursamverkansmodellen. Stöden riktar sig till kulturaktörer med förankring i regionen och söks direkt hos regionens kulturförvaltning. Utlysningar, belopp och tider varierar per region; kontrollera din regions kultursidor.', 'Ett professionellt och tillgängligt kulturliv i hela regionen.', 'public_grant', '["individual", "association", "company"]', '["SE"]', '["culture"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos regionens kulturförvaltning — utlysningar publiceras på regionens webbplats.', 'https://www.skr.se/', 'none', 'assisted', 4, '', 'published', 'f5a8528b-b0cd-4124-a5d6-2935d78c53b9', NULL, 'https://www.skr.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.160205+00', '2026-08-28 06:37:09.160205+00'),
	('2bc6f61e-c3c4-44a5-9df0-247a84ffa9fa', '5100e5a2-4de1-4c48-b268-a7b9060a4659', 'c81aad40-aca6-4df1-ad90-0c77fe7ca735', 'sparbanksstiftelsen-projektstod', 'Sparbanksstiftelsen i ditt område — Bidrag till lokala projekt', 'Ett femtiotal sparbanksstiftelser delar ut bidrag till lokala projekt inom idrott, kultur, utbildning och samhällsutveckling — i sparbankens verksamhetsområde.', 'Sparbanksstiftelserna förvaltar sparbanksrörelsens överskott och delar ut bidrag till projekt som utvecklar det lokala samhället — ofta inom idrott, kultur, utbildning, forskning och näringslivsutveckling. Varje stiftelse beslutar självständigt och stödjer bara projekt i den egna sparbankens verksamhetsområde. Hitta stiftelsen där ni verkar och sök enligt dess rutiner.', 'Lokal utveckling där sparbanken verkar.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society", "sports", "culture", "education"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan hos den sparbanksstiftelse vars område ni verkar i — rutiner varierar per stiftelse.', 'https://www.sparbankerna.se/', 'none', 'assisted', 3, '', 'published', 'd2e175f5-5947-4e8a-8cee-34d38188e90a', 'c41cc3eb-00c8-4d03-a123-15ad738d8803', 'https://www.sparbankerna.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.16623+00', '2026-08-28 06:37:09.16623+00'),
	('cc8e67bb-d6ed-402d-9c27-195c64bdfac9', '766cb84e-b3bb-44f4-89c0-43236a4840af', '885d11df-9a76-47a1-8b84-79148f5a1167', 'leader-lokalt-ledd-utveckling', 'Leader — Projektstöd för lokalt ledd utveckling på landsbygden', 'EU-finansierat projektstöd som söks hos ditt lokala leaderområde — för föreningar, företag och kommuner som utvecklar landsbygden.', 'Genom Leader finansieras lokala utvecklingsprojekt på landsbygden med medel från EU och svenska staten. Sverige är indelat i ett fyrtiotal leaderområden med egna utvecklingsstrategier; projektidén söks hos leaderområdets kansli, prioriteras av den lokala LAG-styrelsen och beslutas formellt av Jordbruksverket. Föreningar, företag, kommuner och andra lokala aktörer kan söka.', 'Utveckling av landsbygden utifrån lokala behov och idéer.', 'eu_grant', '["association", "company", "municipality"]', '["SE"]', '["rural", "civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'rolling', NULL, NULL, NULL, 'Kontakta ditt leaderområdes kansli; ansökan lämnas i Jordbruksverkets e-tjänst.', 'https://jordbruksverket.se/', 'none', 'assisted', 8, '', 'published', 'deb57465-c719-403a-b094-8d108a1d5a1b', 'a8bf2865-9401-4c84-ae93-0c762e50048d', 'https://jordbruksverket.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.173917+00', '2026-08-28 06:37:09.173917+00'),
	('0e165697-13c1-4a62-bd29-f6288d049575', 'cb6cf559-3bbe-48a6-b684-923c0d07a34c', '5cd07981-bae0-4641-a0e2-5f88915a218b', 'forte-projektbidrag', 'Forte — Projektbidrag för forskning om hälsa, arbetsliv och välfärd', 'Forskningsbidrag inom Fortes ansvarsområden: hälsa, arbetsliv och välfärd. Söks av disputerade forskare vid svenska lärosäten.', 'Forte är det statliga forskningsrådet för hälsa, arbetsliv och välfärd och utlyser projektbidrag, postdokbidrag och programstöd inom sina områden. Bidragen söks av disputerade forskare och förvaltas av ett svenskt lärosäte eller annan godkänd medelsförvaltare. Årliga öppna utlysningar publiceras på forte.se.', 'Kunskap som förbättrar människors hälsa, arbetsliv och välfärd.', 'public_grant', '["university"]', '["SE"]', '["research"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan i Fortes ansökningssystem Prisma, via medelsförvaltaren.', 'https://forte.se/', 'none', 'assisted', 15, '', 'published', 'd1b490fa-03fd-46fc-8ff4-4e84da80c218', '13748cea-194e-4aee-a9ac-cca574ea5ff0', 'https://forte.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.180761+00', '2026-08-28 06:37:09.180761+00'),
	('041b7b1c-771c-4555-ae43-4bdc2852351b', '6ee726a8-5cc8-47b0-aeb8-12c44b1de731', '81da07f7-c1bd-4800-84ed-a2d74fa9cb79', 'radiohjalpen-projektbidrag', 'Radiohjälpen — Projektbidrag ur insamlingskampanjerna', 'Bidrag ur bl.a. Världens Barn, Musikhjälpen och Victoriafonden — söks av svenska ideella organisationer med 90-konto.', 'Radiohjälpen fördelar insamlade medel till projekt som drivs av svenska ideella organisationer med 90-konto: internationella humanitära insatser och utvecklingsprojekt (t.ex. Världens Barn, Musikhjälpen) samt nationella insatser för barn och unga med funktionsnedsättning eller kronisk sjukdom (Victoriafonden — där kan även t.ex. kuratorer söka aktivitets- och lägerbidrag för enskilda barn). Utlysningar och villkor finns på radiohjalpen.se.', 'Insamlade medel ska nå fram genom seriösa organisationer.', 'project_grant', '["association", "foundation"]', '["SE"]', '["civil_society"]', NULL, NULL, 'SEK', NULL, false, '[]', 'recurring', NULL, NULL, NULL, 'Ansökan enligt respektive utlysning på radiohjalpen.se.', 'https://www.radiohjalpen.se/', 'none', 'assisted', 6, '', 'published', '1f3deeb9-df0c-49f3-8dfe-cb0e024b046f', 'c43a0b6a-e2fd-4b42-a704-20946333b49e', 'https://www.radiohjalpen.se/', 'A', 'ai_curated', '2026-08-13 00:00:00+00', '2026-09-12 00:00:00+00', 1, '2026-08-28 06:37:09.187824+00', '2026-08-28 06:37:09.187824+00');


--
-- Data for Name: funding_programmes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.funding_programmes VALUES
	('f7fb9f9b-1393-43ff-a3a2-d55478c0221a', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'Internationellt kulturutbyte', '', '2026-08-28 06:37:08.633662+00'),
	('9fe8cbe5-da03-427e-9726-9e8cb51ac1dc', 'f6694444-7bf3-49ad-a33f-a8258e72c318', 'Erasmus+ Ungdom', '', '2026-08-28 06:37:08.646123+00'),
	('ff1df6d6-da7b-4024-927c-773df81c55fc', '39be3fc9-aad3-4934-bca7-7d23526d374a', 'Bidrag till civilsamhället', '', '2026-08-28 06:37:08.653851+00'),
	('73953897-f300-4074-b21f-25718276e643', '3acf93e8-ba3b-4ea9-92a0-2730497c78b1', 'Innovativa startups', '', '2026-08-28 06:37:08.661105+00'),
	('e68ff049-5f8e-4a79-8c81-82f4464c3354', '78dc70cc-5d4d-4859-afb8-9ebd577ddf7f', 'Forskning och innovation för energiomställning', '', '2026-08-28 06:37:08.669487+00'),
	('d9042b22-eee9-4a72-891f-a6a78dc6bbe9', 'e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'Klimatinvesteringar', '', '2026-08-28 06:37:08.67951+00'),
	('28c637a6-c2ab-4ed9-9f05-ba4c816b0714', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'Musik', '', '2026-08-28 06:37:08.693606+00'),
	('3b21f1da-4a86-4322-a276-d0d6e11c371d', '2ca44d2f-388f-4994-aadf-46315d93ab08', 'Internationellt kulturutbyte', '', '2026-08-28 06:37:08.702223+00'),
	('aff48024-6041-4d98-ba90-4d78ac961145', '2ca44d2f-388f-4994-aadf-46315d93ab08', 'Arbetsstipendier', '', '2026-08-28 06:37:08.713627+00'),
	('a4fb10ad-dbe4-43c4-883e-73792dd19eee', 'f92c60a0-9d9f-4233-b14e-910c5755bed0', 'Projektstöd', '', '2026-08-28 06:37:08.723804+00'),
	('5770b226-10d6-442b-8c3a-167498d52988', 'a4c16732-1cab-49f4-aa1b-9f42017e707e', 'Stöd till allmänna samlingslokaler', '', '2026-08-28 06:37:08.732427+00'),
	('736d2627-1334-483f-af41-b7cd95b3d735', '4fa14094-533e-424f-954c-e95a7fbfa3d6', 'LOK-stöd', '', '2026-08-28 06:37:08.741468+00'),
	('a529a1d5-92c7-4835-be75-869b957fe45f', '02beaa3b-6f6c-4c2e-94a7-275ff6586a8d', 'Produktionsstöd', '', '2026-08-28 06:37:08.749034+00'),
	('f67ab935-8c8b-43fa-b7ee-a82db01c84df', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'Skapande skola', '', '2026-08-28 06:37:08.756063+00'),
	('3c7ac2f4-511a-4e34-9ce2-4da7dd99fea8', 'f31d71e6-375b-46a4-93fa-9f540caa97a3', 'Årliga öppna utlysningen', '', '2026-08-28 06:37:08.763724+00'),
	('e51e7e39-fb24-40ea-8e73-9fe50d82820c', '3e461d3b-d656-45bf-934d-1dd28a281259', 'Affärsutvecklingscheckar', '', '2026-08-28 06:37:08.773612+00'),
	('3ff8a33e-0a8f-4a30-88e9-a5212d21be0e', '766cb84e-b3bb-44f4-89c0-43236a4840af', 'Startstöd', '', '2026-08-28 06:37:08.782459+00'),
	('a3413e0c-2555-4961-8cdb-a29951a5c7c0', '766cb84e-b3bb-44f4-89c0-43236a4840af', 'Investeringsstöd', '', '2026-08-28 06:37:08.790506+00'),
	('9007b396-a3b0-46c2-8a32-118071105e41', 'f34e6a3d-e2ba-46b3-af33-8788090be0e0', 'ESF+', '', '2026-08-28 06:37:08.799157+00'),
	('ea9a8646-f8b3-4033-85c4-334eefb73c0a', '78dc70cc-5d4d-4859-afb8-9ebd577ddf7f', 'Industriklivet', '', '2026-08-28 06:37:08.808376+00'),
	('b9edcc44-6c04-441f-9fb3-44d3059701a3', 'e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'Klimatklivet', '', '2026-08-28 06:37:08.816632+00'),
	('bcf38a56-f50b-454b-aad4-051ad2535db0', 'e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'LONA', '', '2026-08-28 06:37:08.825151+00'),
	('a52a29e2-d9ec-4534-8c28-3eb55ab5df15', '39be3fc9-aad3-4934-bca7-7d23526d374a', 'Europeiska solidaritetskåren', '', '2026-08-28 06:37:08.833371+00'),
	('250bb26b-c659-4e11-8289-77a21c655c24', '1a4366ce-048a-404f-8d03-8b230c087f66', 'Erasmus+ Utbildning', '', '2026-08-28 06:37:08.84128+00'),
	('471410ac-35f8-4cbc-9ad6-2f49afb2bcbf', 'f6694444-7bf3-49ad-a33f-a8258e72c318', 'Kreativa Europa', '', '2026-08-28 06:37:08.850147+00'),
	('3e38be19-86d1-404c-8430-1cce1a7ee08b', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'Scenkonst', '', '2026-08-28 06:37:08.858231+00'),
	('ac1a8888-44f1-49c0-ad52-71efcc6d5c10', '3acf93e8-ba3b-4ea9-92a0-2730497c78b1', 'EU-relaterade stöd', '', '2026-08-28 06:37:08.865103+00'),
	('a15d9092-0640-43d7-a92e-4be25eb70c1e', '39be3fc9-aad3-4934-bca7-7d23526d374a', 'Statsbidrag till civilsamhället', '', '2026-08-28 06:37:08.872135+00'),
	('ca02229e-18f9-480d-ab05-143724f4a6fc', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Bostadsbidrag', '', '2026-08-28 06:37:08.878786+00'),
	('7be05897-bfd2-43f0-b752-42742d90152f', '40761d43-2fb0-4e5d-be71-eba0ef0f6b60', 'Glasögonbidrag', '', '2026-08-28 06:37:08.886194+00'),
	('c4990b5e-9f72-405d-bfde-5b08c1aa7cff', 'e20d988c-65bc-424b-8c10-3e716ca2109f', 'Majblommans bidrag', '', '2026-08-28 06:37:08.893016+00'),
	('c99a8edd-ebe4-4740-8575-84c5c7d3def6', '36935f28-db77-48b2-91aa-8f90e800a97c', 'Skolskjuts', '', '2026-08-28 06:37:08.899763+00'),
	('faa1bba3-f771-45fe-b364-783f60b5c21c', '36935f28-db77-48b2-91aa-8f90e800a97c', 'Elevresor', '', '2026-08-28 06:37:08.909088+00'),
	('1259dfbb-de10-47c5-b2dc-cf650dbd3501', '7161944a-45cc-425b-89d3-2dd0d866af36', 'Ekonomiskt bistånd', '', '2026-08-28 06:37:08.922484+00'),
	('0f7fe17f-6052-47b1-b62b-9ed628e84ab3', '660a7af7-53b3-40a4-b392-c071182cda4d', 'Studiemedel', '', '2026-08-28 06:37:08.929474+00'),
	('e802fa8e-9b0b-4f57-aee4-90746a8789f6', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Sjuk- och aktivitetsersättning', '', '2026-08-28 06:37:08.936646+00'),
	('5150a3b8-be57-482f-bdee-f6e33257cee2', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Stöd till barnfamiljer', '', '2026-08-28 06:37:08.943548+00'),
	('ce277b0e-340b-4230-b02d-5a2f23b6abd4', '111f47ca-2eb2-4ba9-bd04-621e03bc4d5c', 'Bostadstillägg', '', '2026-08-28 06:37:08.951051+00'),
	('00a576e4-07e6-42d5-810e-0b63d786259f', '111f47ca-2eb2-4ba9-bd04-621e03bc4d5c', 'Äldreförsörjningsstöd', '', '2026-08-28 06:37:08.957941+00'),
	('451ce1da-a016-4b68-b882-f47b961bee44', 'c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', 'Arbetsmarknadsprogram', '', '2026-08-28 06:37:08.964928+00'),
	('1fec1480-5a61-4531-9398-1f7998e7c925', '660a7af7-53b3-40a4-b392-c071182cda4d', 'Omställningsstudiestöd', '', '2026-08-28 06:37:08.972551+00'),
	('c0fdc00c-a830-40c8-add4-7b92d6a41c97', '36935f28-db77-48b2-91aa-8f90e800a97c', 'Bostadsanpassning', '', '2026-08-28 06:37:08.98019+00'),
	('6c3011e7-61d5-44f1-ab7f-c0a45f0d53c2', '2ca44d2f-388f-4994-aadf-46315d93ab08', 'Kulturbryggan', '', '2026-08-28 06:37:08.989107+00'),
	('bd1783a0-38d8-47b8-9b82-b4f3c5f23a88', '36d13066-e072-45f3-86cc-54c162975216', 'Bidrag till kulturarvsarbete', '', '2026-08-28 06:37:08.997633+00'),
	('99e91d62-c5c5-4779-826e-a0b969cfdd57', '7fdd8b51-44a5-4c65-8b01-5137f8ab95bf', 'Creative Force', '', '2026-08-28 06:37:09.006576+00'),
	('616bbe96-7035-4afe-b708-10f069a3e2ac', 'ceac41d8-0fd6-4712-addc-7db15bf2f6df', 'Projektstöd', '', '2026-08-28 06:37:09.013438+00'),
	('23681367-dee0-4f6e-95db-a926c96c148b', '92569e0b-676f-4c58-8091-3aa7acb4ea25', 'Projektbidrag', '', '2026-08-28 06:37:09.021516+00'),
	('46a9b633-871d-41a3-8216-b284949da01a', '7e5badf8-aa36-42df-aac6-442ceb8c60f7', 'Projektstöd', '', '2026-08-28 06:37:09.02883+00'),
	('a5e3cf93-aa39-4c14-95d1-3c92d955f270', '0198dd7d-a502-4fa3-bccc-2f995a3a1a4a', 'Musiksamarbeten', '', '2026-08-28 06:37:09.035257+00'),
	('91c79a3d-b009-499d-9194-5d65b0586cab', 'f6694444-7bf3-49ad-a33f-a8258e72c318', 'Erasmus+ Partnerskap', '', '2026-08-28 06:37:09.0422+00');
INSERT INTO public.funding_programmes VALUES
	('d3f72e79-6a50-4a5d-b183-be1eef17fe76', '3e461d3b-d656-45bf-934d-1dd28a281259', 'Regionala företagsstöd', '', '2026-08-28 06:37:09.048821+00'),
	('6e2def2a-2ffb-4caf-bb70-18ae1c813232', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'Litteratur och bibliotek', '', '2026-08-28 06:37:09.055577+00'),
	('d4bbf1e5-69fe-4465-9ddb-27604576655f', 'a5bb5cbb-ab9c-4a19-8df4-d6affb47c61a', 'Bygdemedel', '', '2026-08-28 06:37:09.067166+00'),
	('a4bf0813-d57a-434e-9b2c-b621ee1df945', '3319fedb-a0da-4bdb-bb79-9eb170f43967', 'Frivillig återvandring', '', '2026-08-28 06:37:09.073474+00'),
	('eae41226-2dc2-433b-9e07-0218d705af8c', 'c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', 'EURES', '', '2026-08-28 06:37:09.080342+00'),
	('b4630507-250d-4c74-b2b7-aac883cad13b', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Omvårdnadsbidrag', '', '2026-08-28 06:37:09.091222+00'),
	('3979daae-92a2-47c9-adb1-9b9e3472bd93', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Merkostnadsersättning', '', '2026-08-28 06:37:09.09838+00'),
	('c2f41c23-ad46-4479-b26d-9dd569bcc8d2', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Bilstöd', '', '2026-08-28 06:37:09.10493+00'),
	('159d3e41-45eb-434d-a991-69f35fe57c3c', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Närståendepenning', '', '2026-08-28 06:37:09.114135+00'),
	('b285c37b-be0c-4d4c-b95e-41994fe820e3', 'c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', 'Etableringsprogrammet', '', '2026-08-28 06:37:09.120699+00'),
	('7dad446c-96ab-4dfc-a205-ffc7bee93d4f', '660a7af7-53b3-40a4-b392-c071182cda4d', 'Hemutrustningslån', '', '2026-08-28 06:37:09.128012+00'),
	('65953379-6047-4a9d-a637-b685e54db82f', '660a7af7-53b3-40a4-b392-c071182cda4d', 'Studiestartsstöd', '', '2026-08-28 06:37:09.135183+00'),
	('40d0611f-a6c7-4b80-9fe5-9bf3d0169849', '660a7af7-53b3-40a4-b392-c071182cda4d', 'Inackorderingstillägg', '', '2026-08-28 06:37:09.142204+00'),
	('1dacfdbe-8ef9-46c3-9e7f-9b2220e6da45', '36935f28-db77-48b2-91aa-8f90e800a97c', 'Föreningsbidrag', '', '2026-08-28 06:37:09.148886+00'),
	('a4f388ff-84e2-4d1b-9efd-7a18b6d6f70d', '40761d43-2fb0-4e5d-be71-eba0ef0f6b60', 'Regionalt kulturstöd', '', '2026-08-28 06:37:09.158136+00'),
	('c81aad40-aca6-4df1-ad90-0c77fe7ca735', '5100e5a2-4de1-4c48-b268-a7b9060a4659', 'Projektstöd', '', '2026-08-28 06:37:09.164134+00'),
	('885d11df-9a76-47a1-8b84-79148f5a1167', '766cb84e-b3bb-44f4-89c0-43236a4840af', 'Leader — lokalt ledd utveckling', '', '2026-08-28 06:37:09.171694+00'),
	('5cd07981-bae0-4641-a0e2-5f88915a218b', 'cb6cf559-3bbe-48a6-b684-923c0d07a34c', 'Projektbidrag', '', '2026-08-28 06:37:09.178658+00'),
	('81da07f7-c1bd-4800-84ed-a2d74fa9cb79', '6ee726a8-5cc8-47b0-aeb8-12c44b1de731', 'Projektbidrag', '', '2026-08-28 06:37:09.18556+00');


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
	('b1c62f7c-d93f-442c-b95e-e0c3a6f7a305', '25fc0003-928b-4c7d-955f-3e152571b59c', 1, '[{"id": "kr-rb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-rb-h2", "op": "in", "kind": "hard", "expected": ["individual", "association", "company"], "factPath": "applicant.type", "description": "Sökande ska vara yrkesverksam kulturskapare, grupp eller organisation"}, {"id": "kr-rb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam inom kulturområdet", "evidenceKinds": ["cv"], "intakeQuestion": "Är du yrkesverksam inom kulturområdet (t.ex. dans, musik, scenkonst)?"}, {"id": "kr-rb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska avse internationellt kulturutbyte", "evidenceKinds": ["invitation"], "intakeQuestion": "Innehåller projektet en internationell resa eller ett internationellt utbyte?"}, {"id": "kr-rb-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Kulturprojekt"}, {"id": "kr-rb-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}, {"id": "kr-rb-w3", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "project.bringsKnowledgeBack", "description": "Kunskapen tas tillvara i Sverige", "intakeQuestion": "Kommer erfarenheterna att användas i din verksamhet i Sverige?"}]', '[{"id": "kr-rb-b1", "type": "max_requested", "amountMinor": 5000000, "description": "Sökt belopp bör inte överstiga 50 000 kr för resebidrag."}]', '[{"id": "kr-rb-e1", "kind": "cv", "mandatory": true, "description": "CV eller konstnärlig meritförteckning"}, {"id": "kr-rb-e2", "kind": "invitation", "mandatory": true, "description": "Inbjudan eller bekräftelse från mottagande part"}, {"id": "kr-rb-e3", "kind": "budget", "mandatory": false, "description": "Resebudget"}]', '2026-08-28 06:37:08.641934+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.641934+00'),
	('3c600560-6c62-4b6c-890a-ce002dcd43c4', 'd9899e9c-35a4-4278-aaae-07c1994ebcd4', 1, '[{"id": "er-yx-h1", "op": "in", "kind": "hard", "expected": ["association", "informal_group", "municipality"], "factPath": "applicant.type", "description": "Sökande ska vara en organisation eller informell ungdomsgrupp"}, {"id": "er-yx-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska nationella programkontoret"}, {"id": "er-yx-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge13to30", "description": "Deltagarna ska vara 13–30 år", "intakeQuestion": "Är deltagarna i utbytet mellan 13 och 30 år?"}, {"id": "er-yx-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.durationDays5to21", "description": "Utbytet ska vara 5–21 dagar exklusive resdagar", "intakeQuestion": "Pågår utbytet 5–21 dagar (exklusive resdagar)?"}, {"id": "er-yx-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partnergrupp i ett annat programland krävs", "intakeQuestion": "Har ni en partnergrupp i ett annat land?"}, {"id": "er-yx-m4", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID (Organisation ID)", "intakeQuestion": "Har er organisation ett OID (Organisation ID) registrerat i EU:s Organisation Registration System?"}, {"id": "er-yx-w1", "op": "includes", "kind": "weighted", "weight": 3, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}, {"id": "er-yx-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training"], "factPath": "project.activityTypes", "description": "Utbytes-/lärandeaktiviteter"}, {"id": "er-yx-w3", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "er-yx-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från partnergrupp(er)"}, {"id": "er-yx-e2", "kind": "activity_programme", "mandatory": true, "description": "Aktivitetsprogram dag för dag"}, {"id": "er-yx-e3", "kind": "budget", "mandatory": false, "description": "Budget enligt programmets schabloner"}]', '2026-08-28 06:37:08.651133+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.651133+00'),
	('6402cfa6-3246-410b-93c5-8f8eaf6554ff', 'eb518f74-aa9d-46da-9cf5-06261125137a', 1, '[{"id": "mucf-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara verksam i Sverige"}, {"id": "mucf-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska ha en demokratisk uppbyggnad", "intakeQuestion": "Har föreningen en demokratisk uppbyggnad (stadgar, årsmöte, styrelse)?"}, {"id": "mucf-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Projektet ska rikta sig till barn eller unga", "intakeQuestion": "Riktar sig projektet till barn eller unga?"}, {"id": "mucf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["youth", "civil_society", "culture"], "factPath": "project.sector", "description": "Verksamhet inom ungdoms-/civilsamhällesområdet"}, {"id": "mucf-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.youthMembersShareOver60", "description": "Hög andel unga medlemmar", "intakeQuestion": "Är minst 60 % av medlemmarna under 26 år?"}]', '[]', '[{"id": "mucf-e1", "kind": "stadgar", "mandatory": true, "description": "Föreningens stadgar"}, {"id": "mucf-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse och årsredovisning"}, {"id": "mucf-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 06:37:08.65829+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.65829+00'),
	('9eeb77fd-74ed-4f84-bfd9-b99548cd48b0', '8b364654-fd29-417b-9e7b-d64d35924bf0', 1, '[{"id": "vin-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett aktiebolag"}, {"id": "vin-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "vin-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.ageYearsMax5", "description": "Bolaget ska vara ungt (typiskt max ca 5 år — se aktuell utlysning)", "intakeQuestion": "Är bolaget yngre än cirka 5 år?"}, {"id": "vin-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isInnovative", "description": "Lösningen ska vara nyskapande jämfört med befintliga alternativ", "intakeQuestion": "Är er lösning väsentligt nyskapande jämfört med vad som redan finns?"}, {"id": "vin-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.scalableInternationally", "description": "Internationell skalbarhet", "intakeQuestion": "Har lösningen internationell potential?"}, {"id": "vin-w2", "op": "in", "kind": "weighted", "weight": 1, "expected": ["innovation", "technology", "energy", "health"], "factPath": "project.sector", "description": "Prioriterade områden"}]', '[{"id": "vin-b1", "type": "max_requested", "amountMinor": 30000000, "description": "Maximalt bidrag enligt programmets ramar (se aktuell utlysning)."}]', '[{"id": "vin-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "vin-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}, {"id": "vin-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelpersoner"}]', '2026-08-28 06:37:08.66628+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.66628+00'),
	('f96a6b54-0a93-4d9f-b81b-6ccc1e40df99', 'c1a8f6f0-37a6-4ee9-8153-29890616e961', 1, '[{"id": "pm-afs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "pm-afs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-afs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age67Plus", "description": "Du ska ha uppnått riktåldern för pension (67 år från 2026)", "intakeQuestion": "Har du uppnått riktåldern för pension (67 år 2026)?"}, {"id": "pm-afs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.veryLowOrNoPension", "description": "Pension och inkomster ska inte räcka till en skälig levnadsnivå", "intakeQuestion": "Har du svårt att klara dig på din pension och dina övriga inkomster?"}]', '[]', '[]', '2026-08-28 06:37:08.96231+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.96231+00'),
	('cdd45a9c-c767-4b7a-94d8-a31224c6a39b', 'afda3d43-f3d9-4d77-b00e-63b03b39431e', 1, '[{"id": "em-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "em-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association", "economic_association"], "factPath": "applicant.type", "description": "Öppet för organisationer — inte privatpersoner"}, {"id": "em-m1", "op": "in", "kind": "mandatory", "expected": ["energy", "environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom energiområdet", "intakeQuestion": "Handlar projektet om energi, energieffektivisering eller energirelaterad innovation?"}, {"id": "em-w1", "op": "is_true", "kind": "weighted", "weight": 3, "factPath": "project.contributesToEnergyTransition", "description": "Bidrar till energiomställningen", "intakeQuestion": "Bidrar projektet till energiomställningen?"}]', '[]', '[{"id": "em-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "em-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget med kostnadskategorier"}]', '2026-08-28 06:37:08.675888+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.675888+00'),
	('767c57d6-f3de-4349-b55d-18ce060bcd3d', 'cbe9dc6d-1d09-41be-b857-266b16f90f0e', 1, '[{"id": "nv-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "nv-m1", "op": "in", "kind": "mandatory", "expected": ["environment", "energy"], "factPath": "project.sector", "description": "Projektet ska avse miljö- eller klimatåtgärder", "intakeQuestion": "Handlar projektet om miljö- eller klimatåtgärder?"}, {"id": "nv-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.measurableEnvironmentalImpact", "description": "Mätbar miljönytta", "intakeQuestion": "Kan projektets miljönytta mätas?"}]', '[{"id": "nv-b1", "type": "max_funding_share", "percent": 50, "description": "Många av bidragen täcker upp till 50 % av kostnaden — se aktuellt bidrag."}]', '[{"id": "nv-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av åtgärden"}]', '2026-08-28 06:37:08.689484+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.689484+00'),
	('64f233d8-4d56-4b4a-9c7c-46ee332d7012', '56f4edd5-3f05-4168-8302-e882071ab6e8', 1, '[{"id": "kr-pm-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kr-pm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell verksamhet inom musikområdet", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-pm-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kr-pm-w1", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["performance", "production"], "factPath": "project.activityTypes", "description": "Konsert-/produktionsverksamhet"}]', '[]', '[{"id": "kr-pm-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kr-pm-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 06:37:08.698984+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.698984+00'),
	('6a336b40-7f8a-4f18-8fb0-897d8d0c7699', 'ff1627ab-4213-488c-8741-e2da57c960f0', 1, '[{"id": "kn-iku-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av enskilda yrkesverksamma konstnärer"}, {"id": "kn-iku-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-iku-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär (inte amatör eller under grundutbildning)?"}, {"id": "kn-iku-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Ansökan ska avse internationellt utbyte eller resa", "evidenceKinds": ["invitation"], "intakeQuestion": "Avser ansökan en internationell resa eller ett internationellt utbyte?"}, {"id": "kn-iku-w1", "op": "eq", "kind": "weighted", "weight": 3, "expected": "culture", "factPath": "project.sector", "description": "Konstnärligt projekt"}, {"id": "kn-iku-w2", "op": "intersects", "kind": "weighted", "weight": 2, "expected": ["exchange", "training", "performance"], "factPath": "project.activityTypes", "description": "Utbyte, fortbildning eller framträdande"}]', '[]', '[{"id": "kn-iku-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-iku-e2", "kind": "invitation", "mandatory": false, "description": "Inbjudan eller beskrivning av samarbetet"}]', '2026-08-28 06:37:08.710638+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.710638+00'),
	('48de7818-1ae6-44d9-abd8-0d1f1bcb7d04', '2c6560c9-f661-47f5-9830-570b9382ef5f', 1, '[{"id": "kn-as-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stipendiet söks av enskilda konstnärer"}, {"id": "kn-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara verksam i Sverige"}, {"id": "kn-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Sökande ska vara yrkesverksam konstnär", "intakeQuestion": "Är du yrkesverksam konstnär?"}, {"id": "kn-as-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "culture", "factPath": "project.sector", "description": "Konstnärlig verksamhet"}]', '[]', '[{"id": "kn-as-e1", "kind": "cv", "mandatory": true, "description": "Konstnärlig meritförteckning"}, {"id": "kn-as-e2", "kind": "project_description", "mandatory": true, "description": "Beskrivning av konstnärlig verksamhet och planer"}]', '2026-08-28 06:37:08.720042+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.720042+00'),
	('a00d1338-3d05-4304-a985-9f5236cdca3b', 'cd523901-ba90-46de-82a5-10b9a1a30403', 1, '[{"id": "af-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara en ideell organisation"}, {"id": "af-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "af-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.targetsArvsfondenGroups", "description": "Målgruppen ska vara barn, unga, äldre eller personer med funktionsnedsättning", "intakeQuestion": "Riktar sig projektet till barn, unga, äldre eller personer med funktionsnedsättning?"}, {"id": "af-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande i förhållande till ordinarie verksamhet", "intakeQuestion": "Är projektet nyskapande — något ni inte redan gör i ordinarie verksamhet?"}, {"id": "af-ps-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.targetGroupParticipates", "description": "Målgruppen ska vara delaktig i projektet", "intakeQuestion": "Är målgruppen delaktig i planering och genomförande?"}, {"id": "af-ps-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga som målgrupp"}, {"id": "af-ps-w2", "op": "is_true", "kind": "weighted", "weight": 1, "factPath": "organisation.democraticStructure", "description": "Demokratiskt uppbyggd organisation", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}]', '[]', '[{"id": "af-ps-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "af-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning/verksamhetsberättelse"}, {"id": "af-ps-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 06:37:08.729432+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.729432+00'),
	('b44a5ba6-e11a-4112-a12d-6da291b80aed', 'd7bcdcc1-8e69-4566-ba13-01c106b752d2', 1, '[{"id": "bv-as-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Sökande ska vara förening eller stiftelse"}, {"id": "bv-as-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Lokalen ska ligga i Sverige"}, {"id": "bv-as-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.isPublicVenue", "description": "Lokalen ska vara öppen och tillgänglig för allmänheten", "intakeQuestion": "Är lokalen öppen för alla — inte bara egna medlemmar?"}, {"id": "bv-as-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse investering (bygga, köpa eller rusta upp)", "intakeQuestion": "Avser projektet att bygga, köpa eller rusta upp en lokal?"}, {"id": "bv-as-w1", "op": "includes", "kind": "weighted", "weight": 1, "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamhet för ungdomar prioriteras"}]', '[{"id": "bv-as-b1", "type": "max_funding_share", "percent": 50, "description": "Bidraget täcker som huvudregel högst 50 % av godkänd kostnad."}]', '[{"id": "bv-as-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av lokalen och åtgärderna"}, {"id": "bv-as-e2", "kind": "budget", "mandatory": true, "description": "Kostnadskalkyl och finansieringsplan"}]', '2026-08-28 06:37:08.738385+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.738385+00'),
	('a82345d9-50b0-4068-b011-28f30448cb9e', '835a3969-745e-4083-a450-5463c3797743', 1, '[{"id": "rf-lok-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en idrottsförening"}, {"id": "rf-lok-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "rf-lok-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.memberOfSportsFederation", "description": "Föreningen ska vara ansluten till ett specialidrottsförbund inom RF", "intakeQuestion": "Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?"}, {"id": "rf-lok-m2", "op": "includes", "kind": "mandatory", "expected": "youth", "factPath": "project.targetGroups", "description": "Verksamheten ska rikta sig till barn och unga 7–25 år", "intakeQuestion": "Riktar sig verksamheten till barn och unga (7–25 år)?"}, {"id": "rf-lok-w1", "op": "eq", "kind": "weighted", "weight": 2, "expected": "sports", "factPath": "project.sector", "description": "Idrottsverksamhet"}]', '[]', '[{"id": "rf-lok-e1", "kind": "activity_programme", "mandatory": true, "description": "Närvaroregistrerad aktivitetsredovisning"}]', '2026-08-28 06:37:08.746255+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.746255+00'),
	('8fea73d7-39af-420d-a7de-1258f90001fc', '8202cbd8-dd2a-4d59-a168-74a680a64406', 1, '[{"id": "sfi-kf-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Stödet söks av ett produktionsbolag"}, {"id": "sfi-kf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bolaget ska vara registrerat i Sverige"}, {"id": "sfi-kf-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett filmprojekt", "intakeQuestion": "Är projektet ett filmprojekt (kort- eller dokumentärfilm)?"}, {"id": "sfi-kf-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "production", "factPath": "project.activityTypes", "description": "Produktion/utveckling"}]', '[]', '[{"id": "sfi-kf-e1", "kind": "project_description", "mandatory": true, "description": "Synopsis/treatment och regivision"}, {"id": "sfi-kf-e2", "kind": "budget", "mandatory": true, "description": "Produktionsbudget och finansieringsplan"}, {"id": "sfi-kf-e3", "kind": "cv", "mandatory": false, "description": "CV för nyckelfunktioner"}]', '2026-08-28 06:37:08.753588+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.753588+00'),
	('0636ce4a-c6df-4ea8-b901-8e1a6bec3e79', '2e66a1f4-3dfc-403e-a301-415ec8f82ba3', 1, '[{"id": "kr-ss-h1", "op": "in", "kind": "hard", "expected": ["municipality", "school", "company"], "factPath": "applicant.type", "description": "Sökande ska vara skolhuvudman"}, {"id": "kr-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSchoolAuthority", "description": "Sökande ska vara huvudman för förskoleklass/grundskola", "intakeQuestion": "Är ni huvudman för förskoleklass eller grundskola?"}, {"id": "kr-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.usesProfessionalCulture", "description": "Insatserna ska genomföras av professionella kulturaktörer", "intakeQuestion": "Genomförs insatserna av professionella kulturaktörer?"}, {"id": "kr-ss-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Elever som målgrupp"}]', '[]', '[{"id": "kr-ss-e1", "kind": "project_description", "mandatory": true, "description": "Plan för kulturinsatserna"}, {"id": "kr-ss-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 06:37:08.760588+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.760588+00'),
	('9169b3f2-6da1-462a-8c6f-94775b07b164', '1fc1c37f-5a1a-482a-a2f3-e769512361fd', 1, '[{"id": "fo-ou-h1", "op": "in", "kind": "hard", "expected": ["university", "public_body"], "factPath": "applicant.type", "description": "Medlen förvaltas av lärosäte eller forskningsinstitut"}, {"id": "fo-ou-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Medelsförvaltaren ska vara svensk"}, {"id": "fo-ou-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "fo-ou-m2", "op": "in", "kind": "mandatory", "expected": ["environment", "innovation"], "factPath": "project.sector", "description": "Projektet ska ligga inom Formas ansvarsområden", "intakeQuestion": "Ligger projektet inom miljö, areella näringar eller samhällsbyggande?"}]', '[]', '[{"id": "fo-ou-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "fo-ou-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}, {"id": "fo-ou-e3", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 06:37:08.769698+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.769698+00'),
	('a5331a14-e101-47d5-9f40-dd2b565d177f', '453a03ca-a7a2-4872-bc21-521d33eeeba8', 1, '[{"id": "tv-ac-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Sökande ska vara ett företag"}, {"id": "tv-ac-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Företaget ska vara registrerat i Sverige"}, {"id": "tv-ac-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isSmallEnterprise", "description": "Företaget ska vara litet (typiskt 2–49 anställda — se regionens villkor)", "intakeQuestion": "Har företaget mellan cirka 2 och 49 anställda?"}, {"id": "tv-ac-m2", "op": "includes", "kind": "mandatory", "expected": "development", "factPath": "project.activityTypes", "description": "Checken ska användas för utvecklingsinsats med extern kompetens", "intakeQuestion": "Ska ni ta in extern kompetens för en utvecklingsinsats?"}, {"id": "tv-ac-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.scalableInternationally", "description": "Internationaliseringsambition"}]', '[{"id": "tv-ac-b1", "type": "max_funding_share", "percent": 50, "description": "Checken täcker normalt högst 50 % av kostnaden."}]', '[{"id": "tv-ac-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av utvecklingsinsatsen"}, {"id": "tv-ac-e2", "kind": "budget", "mandatory": true, "description": "Kostnads- och finansieringsplan"}]', '2026-08-28 06:37:08.779438+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.779438+00'),
	('7efe46d7-1324-48c1-b70a-7907caaaebb8', '9ca04c8f-d0ff-4aec-90f0-cc245a1a3a08', 1, '[{"id": "jv-ss-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-ss-h2", "op": "in", "kind": "hard", "expected": ["individual", "company"], "factPath": "applicant.type", "description": "Söks av person eller företag"}, {"id": "jv-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.age40OrYounger", "description": "Sökande ska vara 40 år eller yngre", "intakeQuestion": "Är du 40 år eller yngre?"}, {"id": "jv-ss-m2", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Ansökan ska avse jordbruks-, trädgårds- eller rennäringsföretag", "intakeQuestion": "Avser ansökan ett jordbruks-, trädgårds- eller rennäringsföretag?"}, {"id": "jv-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.startingOrTakingOverFarm", "description": "Sökande ska starta eller ta över företaget för första gången", "intakeQuestion": "Startar du eller tar du över företaget för första gången?"}]', '[]', '[{"id": "jv-ss-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}, {"id": "jv-ss-e2", "kind": "budget", "mandatory": true, "description": "Ekonomisk kalkyl"}]', '2026-08-28 06:37:08.787844+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.787844+00'),
	('b4b43e36-9c71-4c0b-84f8-c52e4624ef3e', 'be537cef-44f7-475b-b728-2f95a43b3af6', 1, '[{"id": "jv-is-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "jv-is-m1", "op": "eq", "kind": "mandatory", "expected": "agriculture", "factPath": "project.sector", "description": "Investeringen ska avse jordbruksverksamhet", "intakeQuestion": "Avser investeringen jordbruksverksamhet?"}, {"id": "jv-is-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en fysisk investering?"}]', '[{"id": "jv-is-b1", "type": "max_funding_share", "percent": 40, "description": "Stödandelen är typiskt upp till 40 % av godkänd kostnad — se aktuellt stöd."}]', '[{"id": "jv-is-e1", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl med offerter"}]', '2026-08-28 06:37:08.796157+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.796157+00'),
	('9ff94213-9aca-4cde-815b-c018674103e4', 'b6b654c2-730a-47e1-8028-92d4e31eb0fb', 1, '[{"id": "esf-ku-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "esf-ku-h2", "op": "in", "kind": "hard", "expected": ["company", "association", "municipality", "region", "public_body", "university"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "esf-ku-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensLabourMarket", "description": "Projektet ska stärka kompetens eller ställning på arbetsmarknaden", "intakeQuestion": "Handlar projektet om kompetensutveckling eller arbetsmarknadsinsatser?"}, {"id": "esf-ku-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Sökande ska klara att förskottera kostnader (stöd betalas ut i efterskott)", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[{"id": "esf-ku-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med förändringsteori"}, {"id": "esf-ku-e2", "kind": "budget", "mandatory": true, "description": "Detaljerad projektbudget"}]', '2026-08-28 06:37:08.805318+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.805318+00'),
	('ab9fc2f1-302a-4d66-aa79-90ab6761b059', '271a7349-54c2-4392-b174-b60de25c9ef3', 1, '[{"id": "em-ik-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "em-ik-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "em-ik-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.reducesIndustrialEmissions", "description": "Projektet ska minska industrins utsläpp eller skapa negativa utsläpp", "intakeQuestion": "Minskar projektet industrins processutsläpp eller skapar negativa utsläpp?"}, {"id": "em-ik-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["energy", "environment"], "factPath": "project.sector", "description": "Energi-/klimatprojekt"}]', '[]', '[{"id": "em-ik-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med utsläppsberäkning"}, {"id": "em-ik-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 06:37:08.813861+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.813861+00'),
	('06312803-8c6d-49aa-9214-a2fb72809397', 'cd9b3d16-30ea-465c-ac09-cbce111bd03d', 1, '[{"id": "pm-bt-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Tillägget söks av privatpersoner"}, {"id": "pm-bt-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "pm-bt-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.receivesPension", "description": "Du ska ta ut hel allmän pension", "intakeQuestion": "Tar du ut hel allmän pension?"}, {"id": "pm-bt-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Inkomsterna ska vara låga i förhållande till boendekostnaden", "intakeQuestion": "Är hushållets inkomster låga i förhållande till boendekostnaden?"}, {"id": "pm-bt-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 06:37:08.955305+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.955305+00'),
	('ed03fd16-2e04-4c9c-ab93-01b6b0a5c3b3', '7e7cb03c-5232-4b0e-b2a0-5dbfaf61bd66', 1, '[{"id": "nv-kk-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Åtgärden ska genomföras i Sverige"}, {"id": "nv-kk-h2", "op": "in", "kind": "hard", "expected": ["company", "municipality", "region", "association", "economic_association", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer — inte privatpersoner"}, {"id": "nv-kk-m1", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Stödet avser fysiska investeringar", "intakeQuestion": "Avser ansökan en fysisk investering?"}, {"id": "nv-kk-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.measurableEnvironmentalImpact", "description": "Klimatnyttan ska kunna beräknas", "intakeQuestion": "Kan åtgärdens utsläppsminskning beräknas?"}]', '[]', '[{"id": "nv-kk-e1", "kind": "project_description", "mandatory": true, "description": "Åtgärdsbeskrivning med klimatnyttoberäkning"}, {"id": "nv-kk-e2", "kind": "budget", "mandatory": true, "description": "Investeringskalkyl"}]', '2026-08-28 06:37:08.821804+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.821804+00'),
	('9895af11-d00e-4035-86c4-4aa1562fd213', 'c8cee1bf-40ac-4e22-a136-2d41d4ff89c8', 1, '[{"id": "nv-lona-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Formell sökande är en kommun (föreningar deltar via kommunen)"}, {"id": "nv-lona-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "nv-lona-m1", "op": "eq", "kind": "mandatory", "expected": "environment", "factPath": "project.sector", "description": "Projektet ska avse naturvård eller friluftsliv", "intakeQuestion": "Avser projektet naturvård eller friluftsliv?"}]', '[{"id": "nv-lona-b1", "type": "max_funding_share", "percent": 50, "description": "Högst 50 % bidrag (våtmarksprojekt kan få upp till 90 % — se villkoren)."}]', '[{"id": "nv-lona-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 06:37:08.830271+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.830271+00'),
	('b8a6b59b-2c02-4d1c-9d4d-0cb3948b5d28', '14316ca0-2bfd-4716-b43b-cbf29f41b1a8', 1, '[{"id": "mucf-esc-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "mucf-esc-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "mucf-esc-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "mucf-esc-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasQualityLabel", "description": "Organisationen behöver en Quality Label för solidaritetskåren", "intakeQuestion": "Har organisationen en Quality Label (kvalitetsmärkning)?"}, {"id": "mucf-esc-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.participantsAge18to30", "description": "Volontärerna ska vara 18–30 år", "intakeQuestion": "Är volontärerna mellan 18 och 30 år?"}, {"id": "mucf-esc-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}, {"id": "mucf-esc-w2", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Unga som målgrupp"}]', '[]', '[{"id": "mucf-esc-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning med aktivitetsplan"}, {"id": "mucf-esc-e2", "kind": "partner_letter", "mandatory": false, "description": "Bekräftelse från partnerorganisation(er)"}]', '2026-08-28 06:37:08.838587+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.838587+00'),
	('8d268d1c-dbef-4643-b127-59d2774ef7cf', '4311bf5f-f7db-4acd-ab1b-1368940ba16d', 1, '[{"id": "er-ka1-h1", "op": "in", "kind": "hard", "expected": ["school", "municipality", "company", "association", "public_body"], "factPath": "applicant.type", "description": "Söks av utbildningsorganisationer/huvudmän"}, {"id": "er-ka1-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Ansökan görs via det svenska programkontoret"}, {"id": "er-ka1-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID (Organisation ID)?"}, {"id": "er-ka1-m2", "op": "eq", "kind": "mandatory", "expected": "education", "factPath": "project.sector", "description": "Projektet ska avse utbildningsverksamhet", "intakeQuestion": "Avser projektet skola eller vuxenutbildning?"}, {"id": "er-ka1-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Mobiliteten ska ske till ett annat programland", "intakeQuestion": "Sker mobiliteten till ett annat europeiskt land?"}]', '[]', '[{"id": "er-ka1-e1", "kind": "project_description", "mandatory": true, "description": "Mobilitetsplan"}]', '2026-08-28 06:37:08.846624+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.846624+00'),
	('10f98b9a-f67d-4788-97d0-483dff1ebdd2', '43c0fb0d-c822-4ea0-9d77-c13d1b4027fb', 1, '[{"id": "ke-sp-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer inom kultursektorn"}, {"id": "ke-sp-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "ke-sp-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasThreeCountryPartnership", "description": "Minst tre partner från tre olika programländer krävs", "intakeQuestion": "Har ni partner i minst tre olika europeiska länder?"}, {"id": "ke-sp-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver registrering i EU:s system (PIC/OID)", "intakeQuestion": "Är organisationen registrerad i EU:s deltagarregister?"}, {"id": "ke-sp-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Internationell dimension"}]', '[]', '[{"id": "ke-sp-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning enligt utlysningens mall"}, {"id": "ke-sp-e2", "kind": "partner_letter", "mandatory": true, "description": "Partneravtal/avsiktsförklaringar"}, {"id": "ke-sp-e3", "kind": "budget", "mandatory": true, "description": "Detaljerad budget"}]', '2026-08-28 06:37:08.855179+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.855179+00'),
	('c18aaa28-eca6-4ed0-8a63-8ef69b691033', '73b4bbc3-bd59-49be-8be8-068551cd8c8a', 1, '[{"id": "kr-vs-h1", "op": "in", "kind": "hard", "expected": ["association", "company"], "factPath": "applicant.type", "description": "Söks av grupper/organisationer — inte enskilda"}, {"id": "kr-vs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kr-vs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Verksamheten ska vara professionell", "intakeQuestion": "Är verksamheten professionell (inte amatörverksamhet)?"}, {"id": "kr-vs-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Verksamheten ska vara scenkonst", "intakeQuestion": "Är verksamheten scenkonst (dans, teater, musikteater)?"}, {"id": "kr-vs-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "performance", "factPath": "project.activityTypes", "description": "Publik verksamhet"}]', '[]', '[{"id": "kr-vs-e1", "kind": "project_description", "mandatory": true, "description": "Verksamhetsplan"}, {"id": "kr-vs-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste verksamhetsberättelse"}, {"id": "kr-vs-e3", "kind": "budget", "mandatory": true, "description": "Verksamhetsbudget"}]', '2026-08-28 06:37:08.862598+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.862598+00'),
	('1a4f92e6-a366-4136-bd81-3e5a7f104f20', 'c9a895bc-754d-4418-bc35-a624f1ee4c26', 1, '[{"id": "vin-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande ska vara svensk organisation"}, {"id": "vin-pb-h2", "op": "in", "kind": "hard", "expected": ["company", "university", "public_body", "association"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "vin-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.plansEuApplication", "description": "Bidraget ska användas för att förbereda en EU-ansökan", "intakeQuestion": "Planerar ni att söka ett EU-program (t.ex. Horisont Europa)?"}]', '[]', '[{"id": "vin-pb-e1", "kind": "project_description", "mandatory": true, "description": "Beskrivning av planerad EU-ansökan"}]', '2026-08-28 06:37:08.869426+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.869426+00'),
	('2488cda9-4f2a-465b-8732-f75f5790e108', '3a7a9ef1-3826-4585-986b-eead34315d96', 1, '[{"id": "mucf-ob-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Sökande ska vara en ideell förening"}, {"id": "mucf-ob-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara nationell och verksam i Sverige"}, {"id": "mucf-ob-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Demokratisk uppbyggnad krävs", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har organisationen en demokratisk uppbyggnad?"}, {"id": "mucf-ob-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.youthMembersShareOver60", "description": "Minst 60 % av medlemmarna ska vara 6–25 år", "intakeQuestion": "Är minst 60 % av medlemmarna mellan 6 och 25 år?"}, {"id": "mucf-ob-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasNationalSpread", "description": "Verksamhet i flera län krävs", "intakeQuestion": "Har organisationen medlemsföreningar i flera län?"}]', '[]', '[{"id": "mucf-ob-e1", "kind": "stadgar", "mandatory": true, "description": "Stadgar"}, {"id": "mucf-ob-e2", "kind": "annual_report", "mandatory": true, "description": "Årsredovisning och medlemsredovisning"}]', '2026-08-28 06:37:08.87643+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.87643+00'),
	('51bc96dc-54cc-44f7-a18f-a60dc3aadeca', '7de4083c-e86d-46dd-9a68-8fda8e4c70e8', 1, '[{"id": "fk-bbf-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbf-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig (helt eller växelvis)", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-bbf-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Hushållets inkomst ska vara under inkomstgränsen", "intakeQuestion": "Är hushållets sammanlagda inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbf-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 06:37:08.88344+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.88344+00'),
	('ac6e3bae-b4e9-437b-8eb5-ec13df026650', 'fe2a56a0-9de3-4c6b-a3ed-aecdc39a3761', 1, '[{"id": "reg-glas-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare"}, {"id": "reg-glas-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska vara folkbokfört i Sverige"}, {"id": "reg-glas-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "reg-glas-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childNeedsGlasses", "description": "Barnet (8–19 år) behöver glasögon eller kontaktlinser", "intakeQuestion": "Behöver något av dina barn i åldern 8–19 år glasögon eller linser?"}]', '[]', '[]', '2026-08-28 06:37:08.890554+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.890554+00'),
	('b30a5c25-e810-4e4f-8a94-aeb6e467868d', '1fab4f8c-e89d-45fc-b587-dcbf84c25791', 1, '[{"id": "maj-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks för barn av vårdnadshavare eller t.ex. skolsköterska"}, {"id": "maj-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "maj-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn (upp till 18 år) som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "maj-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childCostsStrain", "description": "Ekonomin räcker inte till sådant barnet behöver eller förväntas delta i", "intakeQuestion": "Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller fritidsaktivitet som ditt barn förväntas delta i?"}, {"id": "maj-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "person.lowHouseholdIncome", "description": "Låg hushållsinkomst stärker ansökan"}]', '[]', '[]', '2026-08-28 06:37:08.897183+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.897183+00'),
	('0d203d0a-1a0c-4c88-8491-4b7a69e6e00f', '4a4f671b-ab38-4dab-8f51-9bc2102a5fa6', 1, '[{"id": "skjuts-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av vårdnadshavare"}, {"id": "skjuts-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "skjuts-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "skjuts-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInCompulsorySchool", "description": "Barnet går i grundskolan", "intakeQuestion": "Går något av dina barn i grundskolan?"}, {"id": "skjuts-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childSchoolDistanceQualifies", "description": "Färdvägen kvalificerar (längd, trafik eller funktionsnedsättning — kommunens bedömning)", "intakeQuestion": "Har barnet lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?"}]', '[]', '[]', '2026-08-28 06:37:08.904958+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.904958+00'),
	('d53a854b-fd9a-4c7c-928f-8282e78f769e', '0b267398-f0fc-4518-a7f0-9c81dfb92e6e', 1, '[{"id": "elevres-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "elevres-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "elevres-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "elevres-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Barnet går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "elevres-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childGymnasiumLongTravel", "description": "Färdvägen till skolan är minst sex kilometer", "intakeQuestion": "Är resvägen mellan hemmet och gymnasieskolan minst sex kilometer?"}]', '[]', '[]', '2026-08-28 06:37:08.91386+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.91386+00'),
	('ac5938fa-d6c6-4579-8671-a93e83865ae3', '80f5a94c-4c90-4bb8-93a1-fe4a319ffa6b', 1, '[{"id": "fk-bbu-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "fk-bbu-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "fk-bbu-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara mellan 18 och 28 år", "intakeQuestion": "Är du mellan 18 och 28 år?"}, {"id": "fk-bbu-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.lowHouseholdIncome", "description": "Din inkomst ska vara låg", "intakeQuestion": "Är din inkomst lägre än ungefär 25 000 kr i månaden före skatt?"}, {"id": "fk-bbu-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.paysHousingCost", "description": "Du ska betala för ditt boende", "intakeQuestion": "Betalar du hyra eller andra boendekostnader?"}]', '[]', '[]', '2026-08-28 06:37:08.919875+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.919875+00'),
	('d43785f4-f1cd-4f37-adf4-db075242688d', 'fbc83baa-c179-4be7-b960-d11b95eb9681', 1, '[{"id": "kfs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "kfs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "kfs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.incomeInsufficientForBasicNeeds", "description": "Inkomsterna ska inte räcka till det mest nödvändiga", "intakeQuestion": "Har hushållet svårt att klara kostnaderna för mat, boende och det mest nödvändiga?"}, {"id": "kfs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.limitedSavings", "description": "Du ska sakna sparande eller tillgångar som kan täcka behoven", "intakeQuestion": "Saknar du sparpengar eller tillgångar som kan täcka utgifterna?"}]', '[]', '[]', '2026-08-28 06:37:08.926775+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.926775+00'),
	('533227b8-561c-4c0e-a13e-380ceb12d222', 'e680dd41-94d3-49c4-9820-ee1e6d1484b6', 1, '[{"id": "csn-sm-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-sm-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. det år du fyller 60"}, {"id": "csn-sm-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}]', '[]', '[]', '2026-08-28 06:37:08.933728+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.933728+00'),
	('6f0ad0b4-087c-454a-9d3f-c3f437ef202a', '67621f48-caa3-4a16-9e32-db010748c2e0', 1, '[{"id": "fk-ae-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-ae-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-ae-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.ageUnder29", "description": "Du ska vara 19–29 år", "intakeQuestion": "Är du mellan 19 och 29 år?"}, {"id": "fk-ae-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.reducedWorkCapacityLongTerm", "description": "Arbetsförmågan ska vara nedsatt i minst ett år", "intakeQuestion": "Bedömer du att din arbetsförmåga är nedsatt under minst ett år på grund av sjukdom eller funktionsnedsättning?"}]', '[]', '[{"id": "fk-ae-e1", "kind": "medical_certificate", "mandatory": true, "description": "Läkarutlåtande om arbetsförmåga"}]', '2026-08-28 06:37:08.940919+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.940919+00'),
	('f916f567-ce7d-403d-a45e-ac562d0e09a0', 'e619e017-66eb-4f25-adce-25802f110dc5', 1, '[{"id": "fk-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Barnet ska bo hos dig", "intakeQuestion": "Har du barn som bor hos dig?"}, {"id": "fk-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.separatedParent", "description": "Föräldrarna ska inte bo tillsammans", "intakeQuestion": "Bor du och barnets andra förälder på skilda håll?"}, {"id": "fk-us-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.otherParentNotPaying", "description": "Den andra föräldern betalar inte underhåll (eller för lite)", "intakeQuestion": "Betalar den andra föräldern inget eller mindre än fullt underhåll?"}]', '[]', '[]', '2026-08-28 06:37:08.947913+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.947913+00'),
	('c38dbb37-371f-4c36-9c93-3ee3e65b8083', '466d2f40-862e-4bc3-9925-99aa9026a490', 1, '[{"id": "af-ssn-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "af-ssn-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara inskriven hos Arbetsförmedlingen i Sverige"}, {"id": "af-ssn-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven som arbetssökande", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "af-ssn-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansToStartBusiness", "description": "Du ska planera att starta företag", "intakeQuestion": "Planerar du att starta eget företag?"}]', '[]', '[{"id": "af-ssn-e1", "kind": "project_description", "mandatory": true, "description": "Affärsplan"}]', '2026-08-28 06:37:08.969686+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.969686+00'),
	('bc209782-c01b-4c6c-9d32-74090be9c021', 'f03a86f0-1368-4293-8016-10b8ce58b9ab', 1, '[{"id": "csn-oss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-oss-h2", "op": "is_false", "kind": "hard", "factPath": "person.age62Plus", "description": "Stödet kan sökas längst t.o.m. det år du fyller 62"}, {"id": "csn-oss-h3", "op": "is_false", "kind": "hard", "factPath": "person.receivesPension", "description": "Stödet riktar sig till yrkesverksamma, inte pensionärer"}, {"id": "csn-oss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.establishedInLabourMarket", "description": "Du ska ha arbetat i genomsnitt minst 16 h/vecka i minst 8 år", "intakeQuestion": "Har du arbetat minst 16 timmar i veckan i sammanlagt minst 8 år?"}, {"id": "csn-oss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska planera studier som stärker din ställning på arbetsmarknaden", "intakeQuestion": "Planerar du studier som stärker din ställning på arbetsmarknaden?"}]', '[]', '[]', '2026-08-28 06:37:08.977553+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.977553+00'),
	('c749f036-02fe-4d78-b293-4b481a2b6b5d', '8a676a8e-9dbb-44e5-8b1c-81cc00d6f4ef', 1, '[{"id": "kom-bab-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av privatpersoner"}, {"id": "kom-bab-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Bostaden ska ligga i Sverige"}, {"id": "kom-bab-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i hushållet har en funktionsnedsättning", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "kom-bab-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du eller någon i hushållet ska ha en bestående funktionsnedsättning", "intakeQuestion": "Har du eller någon i hushållet en bestående funktionsnedsättning som påverkar boendet?"}, {"id": "kom-bab-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.needsHomeAdaptation", "description": "Bostaden ska behöva anpassas", "intakeQuestion": "Behöver bostaden anpassas (t.ex. ramp, dörröppnare, badrum)?"}]', '[]', '[{"id": "kom-bab-e1", "kind": "medical_certificate", "mandatory": true, "description": "Intyg från arbetsterapeut, läkare eller motsvarande"}]', '2026-08-28 06:37:08.98599+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.98599+00'),
	('f80b9168-7721-4940-9e02-a5f7e164eace', 'c8811d54-331b-44e3-8a17-1402e50695fb', 1, '[{"id": "kn-kb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "kn-kb-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett kulturprojekt", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "kn-kb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isNovel", "description": "Projektet ska vara nyskapande", "intakeQuestion": "Prövar projektet nya konstnärliga uttryck, metoder eller samarbeten?"}]', '[]', '[{"id": "kn-kb-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "kn-kb-e2", "kind": "budget", "mandatory": true, "description": "Projektbudget"}]', '2026-08-28 06:37:08.994602+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:08.994602+00'),
	('4a4c1cf6-519d-41dc-a966-10739af85bd2', '6b502145-5fdc-44f2-8502-d2e601d0695a', 1, '[{"id": "raa-ka-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "raa-ka-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "raa-ka-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsCulturalHeritage", "description": "Projektet ska avse kulturarv", "intakeQuestion": "Handlar projektet om att bevara eller tillgängliggöra kulturarv?"}]', '[]', '[]', '2026-08-28 06:37:09.002915+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.002915+00'),
	('fd53a395-60ec-4d0c-b038-66a42d24400c', '71346c42-e1dc-4e52-91f8-09cbd99c25fe', 1, '[{"id": "si-cf-h1", "op": "in", "kind": "hard", "expected": ["association", "company", "foundation", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "si-cf-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Sökande organisation ska vara svensk"}, {"id": "si-cf-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.hasInternationalComponent", "description": "Projektet ska genomföras med internationell partner", "intakeQuestion": "Har projektet en partner i ett annat land?"}, {"id": "si-cf-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.strengthensDemocracy", "description": "Projektet ska stärka demokrati, jämlikhet eller yttrandefrihet", "intakeQuestion": "Syftar projektet till att stärka demokrati, jämlikhet eller yttrandefrihet?"}, {"id": "si-cf-w1", "op": "in", "kind": "weighted", "weight": 2, "expected": ["culture", "civil_society"], "factPath": "project.sector", "description": "Kultur/media som verktyg"}]', '[]', '[{"id": "si-cf-e1", "kind": "partner_letter", "mandatory": true, "description": "Bekräftelse från internationell partner"}, {"id": "si-cf-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 06:37:09.010941+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.010941+00'),
	('95299261-a762-4418-911c-ca8e08ad2c0b', '8f3ec4cc-9ead-43cc-a03f-d2ae3978d1de', 1, '[{"id": "nkf-ps-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Projektet ska vara ett konst- eller kulturprojekt", "intakeQuestion": "Är projektet ett konst- eller kulturprojekt?"}, {"id": "nkf-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasNordicDimension", "description": "Projektet ska ha nordisk dimension (samarbete i flera nordiska länder)", "intakeQuestion": "Samarbetar ni med partner i minst två andra nordiska länder?"}, {"id": "nkf-ps-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "project.hasInternationalComponent", "description": "Gränsöverskridande samarbete"}]', '[]', '[{"id": "nkf-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "nkf-ps-e2", "kind": "budget", "mandatory": true, "description": "Budget"}]', '2026-08-28 06:37:09.018974+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.018974+00'),
	('57f2df6c-6a56-4f95-8f82-139e10381bcf', '3a85807a-d380-4685-8b21-23781ebb6f28', 1, '[{"id": "vr-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte"}, {"id": "vr-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}]', '[]', '[{"id": "vr-pb-e1", "kind": "project_description", "mandatory": true, "description": "Forskningsplan"}, {"id": "vr-pb-e2", "kind": "cv", "mandatory": true, "description": "CV och publikationslista"}]', '2026-08-28 06:37:09.025849+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.025849+00'),
	('7a55a03e-75fe-4add-808a-2285df8e775a', '70716ddc-c4fa-4a5f-88c7-bcaf6fb8e1f2', 1, '[{"id": "pk-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Söks av ideella organisationer"}, {"id": "pk-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Organisationen ska vara etablerad och välskött", "intakeQuestion": "Har organisationen ordnad ekonomi och demokratisk struktur?"}, {"id": "pk-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Stödet ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[{"id": "pk-ps-e1", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}, {"id": "pk-ps-e2", "kind": "annual_report", "mandatory": true, "description": "Senaste årsredovisning"}]', '2026-08-28 06:37:09.033083+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.033083+00'),
	('e3998ef6-9be3-4cc3-8433-7ebd1c4d7a46', '8f509009-0626-497d-9b38-b478caea158a', 1, '[{"id": "mv-pb-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "mv-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.professionalArtist", "description": "Professionell musikverksamhet", "intakeQuestion": "Är verksamheten professionell?"}, {"id": "mv-pb-m2", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Musikprojekt", "intakeQuestion": "Är projektet ett musikprojekt?"}]', '[]', '[]', '2026-08-28 06:37:09.039433+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.039433+00');
INSERT INTO public.rule_versions VALUES
	('5ca6575a-1b87-4958-8ad9-8aa93be71b59', '6f654791-d039-4d71-8532-b2e88e0cb735', 1, '[{"id": "er-ka2-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality", "school", "public_body"], "factPath": "applicant.type", "description": "Söks av organisationer"}, {"id": "er-ka2-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.hasOid", "description": "Organisationen behöver ett OID", "intakeQuestion": "Har organisationen ett OID?"}, {"id": "er-ka2-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.hasPartnerGroupAbroad", "description": "Minst en partner i ett annat programland", "intakeQuestion": "Har ni en partnerorganisation i ett annat europeiskt land?"}, {"id": "er-ka2-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.newToEuFunding", "description": "Nykomlingar i Erasmus+ prioriteras", "intakeQuestion": "Är det här ert första EU-projekt?"}]', '[]', '[{"id": "er-ka2-e1", "kind": "partner_letter", "mandatory": true, "description": "Partnerbekräftelse"}, {"id": "er-ka2-e2", "kind": "project_description", "mandatory": true, "description": "Projektbeskrivning"}]', '2026-08-28 06:37:09.046503+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.046503+00'),
	('a3eab676-1962-4f2c-8590-232af5cd4848', '27c88920-3da6-4d1e-96bf-8e58253d0942', 1, '[{"id": "tv-ris-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av företag"}, {"id": "tv-ris-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska bedrivas i Sverige"}, {"id": "tv-ris-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.inSupportArea", "description": "Verksamhetsorten ska ligga i stödområde A eller B", "intakeQuestion": "Ligger verksamhetsorten i stödområde A eller B (stora delar av Norrland och inre Svealand)?"}, {"id": "tv-ris-m2", "op": "includes", "kind": "mandatory", "expected": "investment", "factPath": "project.activityTypes", "description": "Ansökan ska avse en investering", "intakeQuestion": "Avser ansökan en investering i byggnader eller maskiner?"}, {"id": "tv-ris-m3", "op": "is_true", "kind": "mandatory", "factPath": "project.notStartedYet", "description": "Investeringen får inte vara påbörjad före ansökan", "intakeQuestion": "Kommer investeringen att påbörjas först efter att ni skickat in ansökan?"}]', '[{"id": "tv-ris-b1", "type": "max_funding_share", "percent": 35, "description": "Stödandelen är högst 35 % beroende på område och företagsstorlek."}]', '[]', '2026-08-28 06:37:09.052947+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.052947+00'),
	('3bdd4244-551a-431d-911c-05d934f5364b', 'd773388a-62f3-4036-a4ab-652a8c6565d0', 1, '[{"id": "kr-ib-h1", "op": "eq", "kind": "hard", "expected": "municipality", "factPath": "applicant.type", "description": "Söks av kommuner"}, {"id": "kr-ib-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsLibraries", "description": "Medlen ska användas till litteraturinköp för folk- eller skolbibliotek", "intakeQuestion": "Avser ansökan litteraturinköp till folk- eller skolbibliotek?"}, {"id": "kr-ib-w1", "op": "includes", "kind": "weighted", "weight": 2, "expected": "youth", "factPath": "project.targetGroups", "description": "Barn och unga prioriteras"}]', '[]', '[]', '2026-08-28 06:37:09.059808+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.059808+00'),
	('fff1bbd7-8f69-4492-ae1e-80137d475e5e', 'c49d5e2a-29cd-42f0-9978-cf90b1293d61', 1, '[{"id": "kr-ls-h1", "op": "eq", "kind": "hard", "expected": "company", "factPath": "applicant.type", "description": "Söks av förlag"}, {"id": "kr-ls-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.isPublisher", "description": "Sökande ska vara ett förlag med professionell utgivning", "intakeQuestion": "Är ni ett förlag med professionell utgivning?"}, {"id": "kr-ls-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.concernsPublishedBook", "description": "Stödet söks för redan utgiven titel", "intakeQuestion": "Avser ansökan en redan utgiven titel?"}]', '[]', '[]', '2026-08-28 06:37:09.064729+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.064729+00'),
	('2fa8f043-82f4-401f-b061-6a6d8283973f', '54230320-23ec-4d2c-aad0-5d1821a6e719', 1, '[{"id": "ls-bm-h1", "op": "in", "kind": "hard", "expected": ["association", "municipality"], "factPath": "applicant.type", "description": "Söks av föreningar och kommuner"}, {"id": "ls-bm-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "ls-bm-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inAffectedArea", "description": "Projektet ska ligga i en bygd berörd av vatten- eller vindkraft", "intakeQuestion": "Ligger projektet i en bygd som berörs av vattenkraft eller vindkraft?"}, {"id": "ls-bm-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsCommunity", "description": "Projektet ska vara till allmän nytta för bygden", "intakeQuestion": "Är projektet till nytta för bygden i stort (inte enskilda)?"}]', '[]', '[]', '2026-08-28 06:37:09.071211+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.071211+00'),
	('f3360ce7-99b0-4cd8-9759-689e5b974c96', '9fba8a2d-c848-4524-b689-9641d687bc7b', 1, '[{"id": "mv-av-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "mv-av-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "mv-av-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.planningReturnMigration", "description": "Du ska frivilligt planera att flytta tillbaka till ditt ursprungsland permanent", "intakeQuestion": "Planerar du att frivilligt flytta tillbaka till ditt ursprungsland permanent?"}, {"id": "mv-av-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.protectionBasedResidence", "description": "Du ska ha uppehållstillstånd som flykting eller skyddsbehövande (eller vara nära anhörig till någon som har det)", "intakeQuestion": "Har du uppehållstillstånd i Sverige som flykting eller skyddsbehövande (eller är du nära anhörig till någon som har det)?"}]', '[]', '[]', '2026-08-28 06:37:09.077935+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.077935+00'),
	('db8b369d-2d74-431a-8302-1dde671db650', 'ced6ee83-5399-40f8-ba50-f95da7474302', 1, '[{"id": "eures-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "eures-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara bosatt i ett EU-land (här: Sverige)"}, {"id": "eures-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "eures-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.seekingJobInOtherEuCountry", "description": "Du ska söka eller ha fått jobb i ett annat EU-/EES-land", "intakeQuestion": "Söker du jobb, eller har du fått ett jobberbjudande, i ett annat EU- eller EES-land?"}]', '[]', '[]', '2026-08-28 06:37:09.084536+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.084536+00'),
	('73bf350d-e04d-4d8f-a6d8-9b9c04d095a4', 'adac47e7-e7bb-40da-bc3a-a58a631fc904', 1, '[{"id": "csn-us-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Studiemedel söks av privatpersoner"}, {"id": "csn-us-h2", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Studiemedel lämnas längst t.o.m. ca 60 års ålder"}, {"id": "csn-us-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.consideringMovingAbroad", "description": "Stödet är aktuellt vid flytt utomlands", "intakeQuestion": "Funderar du på att flytta utomlands (för jobb, studier eller återvandring)?"}, {"id": "csn-us-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.isOrPlansStudying", "description": "Du ska studera eller planera att börja studera", "intakeQuestion": "Studerar du, eller planerar du att börja studera?"}, {"id": "csn-us-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.plansStudyAbroad", "description": "Studierna ska bedrivas utomlands", "intakeQuestion": "Planerar du att studera utomlands?"}]', '[]', '[]', '2026-08-28 06:37:09.088972+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.088972+00'),
	('2c15b832-8186-436d-803c-f5e1d06d7440', 'e5f98200-7495-4257-800b-db3b2ec2791e', 1, '[{"id": "fk-ov-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Bidraget söks av vårdnadshavare"}, {"id": "fk-ov-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Barnet ska bo i Sverige"}, {"id": "fk-ov-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-ov-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "fk-ov-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childHasDisability", "description": "Barnet ska ha en funktionsnedsättning som ger behov av mer omvårdnad och tillsyn än jämnåriga", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har något av dina barn en funktionsnedsättning som gör att barnet behöver mer omvårdnad eller tillsyn än andra barn i samma ålder?"}]', '[]', '[]', '2026-08-28 06:37:09.095826+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.095826+00'),
	('639d7d42-92c5-49a0-92bc-8e6cea858a47', '3f11e339-c106-4d69-9fdc-c5208bf2acdc', 1, '[{"id": "fk-mk-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-mk-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-mk-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-mk-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Du (eller ditt barn) ska ha en varaktig funktionsnedsättning", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-mk-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityExtraCosts", "description": "Funktionsnedsättningen ska medföra merkostnader över lägstanivån", "intakeQuestion": "Har funktionsnedsättningen medfört extra kostnader — t.ex. hjälpmedel, resor, särskild kost eller slitage?"}]', '[]', '[]', '2026-08-28 06:37:09.102658+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.102658+00'),
	('9532fc26-c5f9-4c3c-8bb9-ad3996be254f', 'dca6e66a-b48c-4b6f-a3b6-7b3ced4b026e', 1, '[{"id": "fk-bs-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "fk-bs-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-bs-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityOrLongTermIllnessInFamily", "description": "Stödet är aktuellt när någon i familjen har en funktionsnedsättning eller långvarig sjukdom", "intakeQuestion": "Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"}, {"id": "fk-bs-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasLastingDisability", "description": "Funktionsnedsättningen ska vara varaktig", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Har du eller ditt barn en funktionsnedsättning som väntas bestå i minst ett år?"}, {"id": "fk-bs-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.disabilityTravelDifficulty", "description": "Det ska vara mycket svårt att förflytta sig på egen hand eller använda allmänna kommunikationer", "intakeQuestion": "Är det mycket svårt för dig (eller ditt barn) att förflytta sig på egen hand eller att resa med buss och tåg?"}]', '[]', '[]', '2026-08-28 06:37:09.111341+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.111341+00'),
	('404d0f44-5ff3-413a-a555-0dd296714ed5', 'c4fa7013-d021-49dc-b9f1-2dfe8775b2f5', 1, '[{"id": "fk-np-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "fk-np-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara försäkrad i Sverige"}, {"id": "fk-np-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.caringForSeriouslyIllRelative", "description": "Du ska avstå från förvärvsarbete för att vårda eller vara nära en närstående vars sjukdom är ett påtagligt hot mot livet", "evidenceKinds": ["medical_certificate"], "intakeQuestion": "Avstår du från arbete för att vårda eller vara nära en närstående som är så svårt sjuk att sjukdomen är ett hot mot livet?"}]', '[]', '[]', '2026-08-28 06:37:09.118263+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.118263+00'),
	('b23d20e6-9ec4-4681-9112-a4d2421325c6', '6365ebcf-a41b-4568-87fb-50c7bd647274', 1, '[{"id": "af-ee-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Ersättningen söks av privatpersoner"}, {"id": "af-ee-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "af-ee-h3", "op": "is_false", "kind": "hard", "factPath": "person.age66Plus", "description": "Programmet gäller till och med 66 års ålder"}, {"id": "af-ee-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Du ska nyligen ha fått uppehållstillstånd som skyddsbehövande eller anhörig", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "af-ee-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara inskriven hos Arbetsförmedlingen och delta i etableringsprogrammet", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}]', '[]', '[]', '2026-08-28 06:37:09.125381+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.125381+00'),
	('a72f154f-d3b4-4d06-b189-c0090476a1ce', 'ed1b1caa-4a62-4bcb-9804-7d0119671895', 1, '[{"id": "csn-hl-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Lånet söks av privatpersoner"}, {"id": "csn-hl-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska vara mottagen i en svensk kommun"}, {"id": "csn-hl-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.newlyArrivedWithResidencePermit", "description": "Lånet gäller flyktingar och vissa anhöriga under de första åren i Sverige", "intakeQuestion": "Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?"}, {"id": "csn-hl-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.settlingFirstHomeInSweden", "description": "Du ska hålla på att skaffa och utrusta ett första hem i Sverige", "intakeQuestion": "Håller du på att skaffa eller utrusta ditt första egna hem i Sverige?"}]', '[]', '[]', '2026-08-28 06:37:09.132653+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.132653+00'),
	('705a28f0-ab47-43a0-901a-410ad698adbb', '10f619cd-7abf-46fe-8bd8-e85a6ead2ce0', 1, '[{"id": "csn-ss-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Stödet söks av privatpersoner"}, {"id": "csn-ss-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Du ska bo i Sverige"}, {"id": "csn-ss-h3", "op": "is_false", "kind": "hard", "factPath": "person.age60Plus", "description": "Stödet gäller till och med 60 års ålder"}, {"id": "csn-ss-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.registeredUnemployed", "description": "Du ska vara arbetslös och anmäld hos Arbetsförmedlingen", "intakeQuestion": "Är du inskriven som arbetssökande hos Arbetsförmedlingen?"}, {"id": "csn-ss-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.age25to60", "description": "Du ska vara mellan 25 och 60 år", "intakeQuestion": "Är du mellan 25 och 60 år?"}, {"id": "csn-ss-m3", "op": "is_true", "kind": "mandatory", "factPath": "person.shortPriorEducation", "description": "Du ska ha kort tidigare utbildning och behöva studier på grundskole- eller gymnasienivå", "intakeQuestion": "Är din senast avslutade utbildning grundskola, eller ett gymnasium du inte slutförde?"}]', '[]', '[]', '2026-08-28 06:37:09.13933+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.13933+00'),
	('b243629b-aa18-4232-8156-8c98066b6566', 'd2f4ebc9-32bf-4e94-9a2d-455089de3842', 1, '[{"id": "csn-it-h1", "op": "eq", "kind": "hard", "expected": "individual", "factPath": "applicant.type", "description": "Söks av eleven eller vårdnadshavare"}, {"id": "csn-it-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Gäller elever folkbokförda i Sverige"}, {"id": "csn-it-m0", "op": "is_true", "kind": "mandatory", "factPath": "person.hasChildrenAtHome", "description": "Du ska ha barn som bor hos dig", "intakeQuestion": "Har du barn som bor hos dig, helt eller växelvis?"}, {"id": "csn-it-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.childInUpperSecondary", "description": "Eleven går på gymnasiet med studiehjälp", "intakeQuestion": "Går något av dina barn på gymnasiet?"}, {"id": "csn-it-m2", "op": "is_true", "kind": "mandatory", "factPath": "person.childLivesAwayForStudies", "description": "Eleven behöver bo på studieorten på grund av lång eller besvärlig resväg", "intakeQuestion": "Behöver barnet bo på studieorten (inackordering) för att resvägen är för lång?"}]', '[]', '[]', '2026-08-28 06:37:09.146771+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.146771+00'),
	('8904d5e2-dcf4-4424-a3c2-6d5e398c03da', 'e3296bd2-2fb0-47de-88c2-b54e4854bd8c', 1, '[{"id": "kmn-fb-h1", "op": "eq", "kind": "hard", "expected": "association", "factPath": "applicant.type", "description": "Bidragen söks av ideella föreningar"}, {"id": "kmn-fb-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Föreningen ska vara verksam i Sverige"}, {"id": "kmn-fb-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.democraticStructure", "description": "Föreningen ska vara demokratiskt uppbyggd med stadgar och styrelse", "evidenceKinds": ["stadgar"], "intakeQuestion": "Har föreningen antagna stadgar och en vald styrelse?"}, {"id": "kmn-fb-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.activeInMunicipality", "description": "Föreningen ska bedriva regelbunden verksamhet i kommunen", "intakeQuestion": "Bedriver föreningen regelbunden verksamhet i kommunen?"}, {"id": "kmn-fb-w1", "op": "is_true", "kind": "weighted", "weight": 2, "factPath": "organisation.hasYouthActivities", "description": "Barn- och ungdomsverksamhet prioriteras i de flesta kommuner", "intakeQuestion": "Har föreningen regelbunden verksamhet för barn eller unga?"}]', '[]', '[]', '2026-08-28 06:37:09.155687+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.155687+00'),
	('f5a8528b-b0cd-4124-a5d6-2935d78c53b9', '0f5b852f-f437-476f-8dc3-bb431435bfdd', 1, '[{"id": "reg-ks-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Verksamheten ska vara förankrad i Sverige"}, {"id": "reg-ks-m1", "op": "eq", "kind": "mandatory", "expected": "culture", "factPath": "project.sector", "description": "Stöden gäller kulturverksamhet", "intakeQuestion": "Är projektet ett kulturprojekt?"}, {"id": "reg-ks-m2", "op": "is_true", "kind": "mandatory", "factPath": "organisation.regionalConnection", "description": "Sökanden ska ha säte eller huvudsaklig verksamhet i regionen", "intakeQuestion": "Har ni säte eller huvudsaklig verksamhet i den region där ni söker?"}]', '[]', '[]', '2026-08-28 06:37:09.16216+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.16216+00'),
	('d2e175f5-5947-4e8a-8cee-34d38188e90a', '2bc6f61e-c3c4-44a5-9df0-247a84ffa9fa', 1, '[{"id": "spb-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks i regel av ideella organisationer"}, {"id": "spb-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "spb-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.localSparbankPresence", "description": "Det ska finnas en sparbank/sparbanksstiftelse i ert verksamhetsområde", "intakeQuestion": "Finns det en sparbank (och därmed en sparbanksstiftelse) där ni bedriver er verksamhet?"}, {"id": "spb-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska komma det lokala samhället till del", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}]', '[]', '[]', '2026-08-28 06:37:09.168863+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.168863+00'),
	('deb57465-c719-403a-b094-8d108a1d5a1b', 'cc8e67bb-d6ed-402d-9c27-195c64bdfac9', 1, '[{"id": "leader-h1", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Projektet ska genomföras i Sverige"}, {"id": "leader-m1", "op": "is_true", "kind": "mandatory", "factPath": "project.inRuralLeaderArea", "description": "Projektet ska genomföras inom ett leaderområde (större delen av landsbygden och många tätorter omfattas)", "intakeQuestion": "Genomförs projektet på landsbygden eller i en mindre tätort?"}, {"id": "leader-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.benefitsLocalCommunity", "description": "Projektet ska bidra till bygdens utveckling enligt områdets strategi", "intakeQuestion": "Kommer projektet människor i ert närområde till del?"}, {"id": "leader-m3", "op": "is_true", "kind": "mandatory", "factPath": "organisation.canPrefinance", "description": "Stödet betalas ut i efterhand — ni behöver kunna ligga ute med kostnader", "intakeQuestion": "Klarar organisationen att ligga ute med kostnader tills stödet betalas ut?"}]', '[]', '[]', '2026-08-28 06:37:09.176137+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.176137+00'),
	('d1b490fa-03fd-46fc-8ff4-4e84da80c218', '0e165697-13c1-4a62-bd29-f6288d049575', 1, '[{"id": "forte-pb-h1", "op": "eq", "kind": "hard", "expected": "university", "factPath": "applicant.type", "description": "Medlen förvaltas av ett svenskt lärosäte eller godkänd medelsförvaltare"}, {"id": "forte-pb-m1", "op": "is_true", "kind": "mandatory", "factPath": "person.hasDoctorate", "description": "Projektledaren ska vara disputerad", "intakeQuestion": "Har projektledaren doktorsexamen?"}, {"id": "forte-pb-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.withinForteAreas", "description": "Projektet ska ligga inom hälsa, arbetsliv eller välfärd", "intakeQuestion": "Handlar projektet om hälsa, arbetsliv eller välfärd?"}]', '[]', '[]', '2026-08-28 06:37:09.183033+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.183033+00'),
	('1f3deeb9-df0c-49f3-8dfe-cb0e024b046f', '041b7b1c-771c-4555-ae43-4bdc2852351b', 1, '[{"id": "rh-ps-h1", "op": "in", "kind": "hard", "expected": ["association", "foundation"], "factPath": "applicant.type", "description": "Bidragen söks av ideella organisationer"}, {"id": "rh-ps-h2", "op": "eq", "kind": "hard", "expected": "SE", "factPath": "applicant.country", "description": "Organisationen ska vara svensk"}, {"id": "rh-ps-m1", "op": "is_true", "kind": "mandatory", "factPath": "organisation.has90Account", "description": "Organisationen ska ha 90-konto (Svensk Insamlingskontroll)", "intakeQuestion": "Har organisationen ett 90-konto?"}, {"id": "rh-ps-m2", "op": "is_true", "kind": "mandatory", "factPath": "project.isTimeLimited", "description": "Bidrag ges till avgränsade projekt, inte löpande verksamhet", "intakeQuestion": "Är insatsen ett avgränsat projekt (inte ordinarie verksamhet)?"}]', '[]', '[]', '2026-08-28 06:37:09.189876+00', NULL, 'Initial curated rule set from official source.', 'seed', '2026-08-28 06:37:09.189876+00');


--
-- Data for Name: source_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sources VALUES
	('e79c5025-cd83-4526-b903-c1e8f06bb73e', 'd12db1cc-b515-46cf-87cb-2c6d0018c5d6', 'Kulturrådet — Sök bidrag', 'https://kulturradet.se/sok-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.566793+00'),
	('4c6d9dfa-d316-4ad4-af43-6c8469e17540', '39be3fc9-aad3-4934-bca7-7d23526d374a', 'MUCF — Bidrag', 'https://www.mucf.se/bidrag', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.569289+00'),
	('8486e9f7-f910-4215-9263-d5476870fdf5', '3acf93e8-ba3b-4ea9-92a0-2730497c78b1', 'Vinnova — Utlysningar', 'https://www.vinnova.se/soka-finansiering/hitta-finansiering/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.571176+00'),
	('eb72880e-92bd-408e-8eb9-c9b6feb08472', '3e461d3b-d656-45bf-934d-1dd28a281259', 'Tillväxtverket — Utlysningar', 'https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.572868+00'),
	('cc78af50-3435-4a33-8981-dcffbe942311', '78dc70cc-5d4d-4859-afb8-9ebd577ddf7f', 'Energimyndigheten — Alla utlysningar', 'https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/alla-utlysningar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.574663+00'),
	('62014879-be16-44e8-8ded-cb3ffc965eb2', 'e7a60f44-9119-4948-9c6b-0ff0a76946cc', 'Naturvårdsverket — Bidrag', 'https://www.naturvardsverket.se/bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.576781+00'),
	('004a212d-fc9e-47a5-ad68-7c7ee04c6719', 'f34e6a3d-e2ba-46b3-af33-8788090be0e0', 'Svenska ESF-rådet — Utlysningsplan', 'https://www.esf.se/utlysningar/utlysningsplan/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.578796+00'),
	('6f46df8b-ec68-47ac-9c7e-cab26c89942d', 'f6694444-7bf3-49ad-a33f-a8258e72c318', 'Erasmus+ — Youth exchanges', 'https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.580592+00'),
	('1a379a88-5400-4cb3-bbc4-49ca474f2cd9', '2ca44d2f-388f-4994-aadf-46315d93ab08', 'Konstnärsnämnden — Stipendier och bidrag', 'https://www.konstnarsnamnden.se/stipendier-och-bidrag/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.582513+00'),
	('947774fa-c20b-4c00-a517-493906d878eb', 'f92c60a0-9d9f-4233-b14e-910c5755bed0', 'Allmänna arvsfonden — Söka pengar', 'https://www.arvsfonden.se/soka-pengar', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.584167+00'),
	('09e9e2b0-364f-49cc-86ec-e88cce84e4bc', 'a4c16732-1cab-49f4-aa1b-9f42017e707e', 'Boverket — Bidrag och stöd', 'https://www.boverket.se/sv/bidrag--garantier/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.586285+00'),
	('b19e816b-1eb9-49f6-a511-eb288a1669f4', '4fa14094-533e-424f-954c-e95a7fbfa3d6', 'Riksidrottsförbundet — Ekonomiskt stöd', 'https://www.rf.se/bidrag-och-stod', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.588698+00'),
	('f5702e99-2e62-4027-ad95-ae7c623a4b57', '02beaa3b-6f6c-4c2e-94a7-275ff6586a8d', 'Svenska Filminstitutet — Stöd', 'https://www.filminstitutet.se/sv/sok-stod/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.590651+00'),
	('15ca77c2-87d8-45d3-bdc6-c20d58a6d2fc', 'f31d71e6-375b-46a4-93fa-9f540caa97a3', 'Formas — Utlysningar', 'https://www.formas.se/soka-finansiering.html', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.592632+00'),
	('03ab1d49-54cf-49e9-90d8-03006df99d56', '1a4366ce-048a-404f-8d03-8b230c087f66', 'UHR — Erasmus+ utbildning', 'https://www.uhr.se/internationella-mojligheter/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.594341+00'),
	('64f925b5-b0b6-4a28-bca9-1dba816efff9', '939c23d2-60c9-4923-a31d-3b5ea1054bb6', 'Försäkringskassan — Privatperson', 'https://www.forsakringskassan.se/privatperson', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.595895+00'),
	('c30250ee-b923-4188-b3af-b17eb37654e4', '660a7af7-53b3-40a4-b392-c071182cda4d', 'CSN — Studiemedel', 'https://www.csn.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.597598+00'),
	('cd35bab9-42d7-4724-b6d4-575237e4ed68', '111f47ca-2eb2-4ba9-bd04-621e03bc4d5c', 'Pensionsmyndigheten — Stöd och bidrag', 'https://www.pensionsmyndigheten.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.599534+00'),
	('48ae2c3e-82e4-4417-8555-7b80358b5cee', '7161944a-45cc-425b-89d3-2dd0d866af36', 'Socialstyrelsen — Ekonomiskt bistånd', 'https://www.socialstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.601377+00'),
	('035b9485-2757-4183-a4a4-f64a0b28d67d', '40761d43-2fb0-4e5d-be71-eba0ef0f6b60', '1177 — Bidrag för glasögon till barn och unga', 'https://www.1177.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.603381+00'),
	('99c8d938-7bfb-4c13-9395-5170f8cbbf8b', 'e20d988c-65bc-424b-8c10-3e716ca2109f', 'Majblomman — Ansök om bidrag', 'https://majblomman.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.605386+00'),
	('28a7866f-689b-459e-8b26-9b3b1ade73d8', '36935f28-db77-48b2-91aa-8f90e800a97c', 'Skolverket — Skolskjuts', 'https://www.skolverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.607463+00'),
	('875ab3e6-065d-42cb-b828-2ba3dc04eda9', '36935f28-db77-48b2-91aa-8f90e800a97c', 'Lag (1991:1110) om kommunernas skyldighet att svara för vissa elevresor', 'https://www.riksdagen.se/sv/dokument-och-lagar/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.609538+00'),
	('ce9f0d1e-f5b6-40ea-aa94-9994a3c38e14', 'c1bbfafc-9e6d-46fd-a438-f0e4c77c3b2c', 'Arbetsförmedlingen — Stöd och bidrag', 'https://arbetsformedlingen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.611691+00'),
	('858f3d34-6a06-477d-b335-dc2bab8d1cff', '3319fedb-a0da-4bdb-bb79-9eb170f43967', 'Migrationsverket — Återvandring', 'https://www.migrationsverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.613748+00'),
	('a524b355-78e0-451a-a216-dc2ecb7e3227', '36d13066-e072-45f3-86cc-54c162975216', 'Riksantikvarieämbetet — Bidrag', 'https://www.raa.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.615482+00'),
	('7337e00b-0b9f-4e93-a6b8-3089c0dfa75e', '7fdd8b51-44a5-4c65-8b01-5137f8ab95bf', 'Svenska institutet — Utlysningar', 'https://si.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.617024+00'),
	('bc502111-2477-4eb8-8178-8e9fbc0f4b5b', 'ceac41d8-0fd6-4712-addc-7db15bf2f6df', 'Nordisk kulturfond — Støtte', 'https://www.nordiskkulturfond.org/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.618557+00'),
	('360d9b45-040e-4e91-81e0-19363a0b04d4', '92569e0b-676f-4c58-8091-3aa7acb4ea25', 'Vetenskapsrådet — Utlysningar', 'https://www.vr.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.620176+00'),
	('5e24ee88-46ea-4c2a-876d-ae327a37766c', '7e5badf8-aa36-42df-aac6-442ceb8c60f7', 'Postkodstiftelsen — Ansök om stöd', 'https://postkodstiftelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.621861+00'),
	('03399ee2-48d9-4c05-acb5-501b1386e822', '0198dd7d-a502-4fa3-bccc-2f995a3a1a4a', 'Musikverket — Bidrag', 'https://musikverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.623636+00'),
	('b2645e26-9fc7-4bb4-b641-0ba67dca9d9b', 'a5bb5cbb-ab9c-4a19-8df4-d6affb47c61a', 'Länsstyrelserna — Stöd och bidrag', 'https://www.lansstyrelsen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.625463+00'),
	('13748cea-194e-4aee-a9ac-cca574ea5ff0', 'cb6cf559-3bbe-48a6-b684-923c0d07a34c', 'Forte — Utlysningar', 'https://forte.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.627038+00'),
	('c41cc3eb-00c8-4d03-a123-15ad738d8803', '5100e5a2-4de1-4c48-b268-a7b9060a4659', 'Sparbankernas Riksförbund — Sparbanksstiftelser', 'https://www.sparbankerna.se/', 'html', 'B', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.628554+00'),
	('c43a0b6a-e2fd-4b42-a704-20946333b49e', '6ee726a8-5cc8-47b0-aeb8-12c44b1de731', 'Radiohjälpen — Söka bidrag', 'https://www.radiohjalpen.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.630134+00'),
	('a8bf2865-9401-4c84-ae93-0c762e50048d', '766cb84e-b3bb-44f4-89c0-43236a4840af', 'Jordbruksverket — Stöd', 'https://jordbruksverket.se/', 'html', 'A', '0 */6 * * *', true, 'none', NULL, NULL, NULL, '2026-08-28 06:37:08.631856+00');


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


