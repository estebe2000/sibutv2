--
-- PostgreSQL database dump
--

\restrict ti7qmjmVI848d2j5SDajjMZpn4M5hg0VbT2zWcQDaC2ABgDiIH4S6nTfryLFkJF

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_event_entity; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.admin_event_entity (
    id character varying(36) NOT NULL,
    admin_event_time bigint,
    realm_id character varying(255),
    operation_type character varying(255),
    auth_realm_id character varying(255),
    auth_client_id character varying(255),
    auth_user_id character varying(255),
    ip_address character varying(255),
    resource_path character varying(2550),
    representation text,
    error character varying(255),
    resource_type character varying(64),
    details_json text
);


ALTER TABLE public.admin_event_entity OWNER TO keycloak;

--
-- Name: associated_policy; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.associated_policy (
    policy_id character varying(36) NOT NULL,
    associated_policy_id character varying(36) NOT NULL
);


ALTER TABLE public.associated_policy OWNER TO keycloak;

--
-- Name: authentication_execution; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.authentication_execution (
    id character varying(36) NOT NULL,
    alias character varying(255),
    authenticator character varying(36),
    realm_id character varying(36),
    flow_id character varying(36),
    requirement integer,
    priority integer,
    authenticator_flow boolean DEFAULT false NOT NULL,
    auth_flow_id character varying(36),
    auth_config character varying(36)
);


ALTER TABLE public.authentication_execution OWNER TO keycloak;

--
-- Name: authentication_flow; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.authentication_flow (
    id character varying(36) NOT NULL,
    alias character varying(255),
    description character varying(255),
    realm_id character varying(36),
    provider_id character varying(36) DEFAULT 'basic-flow'::character varying NOT NULL,
    top_level boolean DEFAULT false NOT NULL,
    built_in boolean DEFAULT false NOT NULL
);


ALTER TABLE public.authentication_flow OWNER TO keycloak;

--
-- Name: authenticator_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.authenticator_config (
    id character varying(36) NOT NULL,
    alias character varying(255),
    realm_id character varying(36)
);


ALTER TABLE public.authenticator_config OWNER TO keycloak;

--
-- Name: authenticator_config_entry; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.authenticator_config_entry (
    authenticator_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.authenticator_config_entry OWNER TO keycloak;

--
-- Name: broker_link; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.broker_link (
    identity_provider character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL,
    broker_user_id character varying(255),
    broker_username character varying(255),
    token text,
    user_id character varying(255) NOT NULL
);


ALTER TABLE public.broker_link OWNER TO keycloak;

--
-- Name: client; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client (
    id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    full_scope_allowed boolean DEFAULT false NOT NULL,
    client_id character varying(255),
    not_before integer,
    public_client boolean DEFAULT false NOT NULL,
    secret character varying(255),
    base_url character varying(255),
    bearer_only boolean DEFAULT false NOT NULL,
    management_url character varying(255),
    surrogate_auth_required boolean DEFAULT false NOT NULL,
    realm_id character varying(36),
    protocol character varying(255),
    node_rereg_timeout integer DEFAULT 0,
    frontchannel_logout boolean DEFAULT false NOT NULL,
    consent_required boolean DEFAULT false NOT NULL,
    name character varying(255),
    service_accounts_enabled boolean DEFAULT false NOT NULL,
    client_authenticator_type character varying(255),
    root_url character varying(255),
    description character varying(255),
    registration_token character varying(255),
    standard_flow_enabled boolean DEFAULT true NOT NULL,
    implicit_flow_enabled boolean DEFAULT false NOT NULL,
    direct_access_grants_enabled boolean DEFAULT false NOT NULL,
    always_display_in_console boolean DEFAULT false NOT NULL
);


ALTER TABLE public.client OWNER TO keycloak;

--
-- Name: client_attributes; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_attributes (
    client_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.client_attributes OWNER TO keycloak;

--
-- Name: client_auth_flow_bindings; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_auth_flow_bindings (
    client_id character varying(36) NOT NULL,
    flow_id character varying(36),
    binding_name character varying(255) NOT NULL
);


ALTER TABLE public.client_auth_flow_bindings OWNER TO keycloak;

--
-- Name: client_initial_access; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_initial_access (
    id character varying(36) NOT NULL,
    realm_id character varying(36) NOT NULL,
    "timestamp" integer,
    expiration integer,
    count integer,
    remaining_count integer
);


ALTER TABLE public.client_initial_access OWNER TO keycloak;

--
-- Name: client_node_registrations; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_node_registrations (
    client_id character varying(36) NOT NULL,
    value integer,
    name character varying(255) NOT NULL
);


ALTER TABLE public.client_node_registrations OWNER TO keycloak;

--
-- Name: client_scope; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_scope (
    id character varying(36) NOT NULL,
    name character varying(255),
    realm_id character varying(36),
    description character varying(255),
    protocol character varying(255)
);


ALTER TABLE public.client_scope OWNER TO keycloak;

--
-- Name: client_scope_attributes; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_scope_attributes (
    scope_id character varying(36) NOT NULL,
    value character varying(2048),
    name character varying(255) NOT NULL
);


ALTER TABLE public.client_scope_attributes OWNER TO keycloak;

--
-- Name: client_scope_client; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_scope_client (
    client_id character varying(255) NOT NULL,
    scope_id character varying(255) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


ALTER TABLE public.client_scope_client OWNER TO keycloak;

--
-- Name: client_scope_role_mapping; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.client_scope_role_mapping (
    scope_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


ALTER TABLE public.client_scope_role_mapping OWNER TO keycloak;

--
-- Name: component; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.component (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_id character varying(36),
    provider_id character varying(36),
    provider_type character varying(255),
    realm_id character varying(36),
    sub_type character varying(255)
);


ALTER TABLE public.component OWNER TO keycloak;

--
-- Name: component_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.component_config (
    id character varying(36) NOT NULL,
    component_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.component_config OWNER TO keycloak;

--
-- Name: composite_role; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.composite_role (
    composite character varying(36) NOT NULL,
    child_role character varying(36) NOT NULL
);


ALTER TABLE public.composite_role OWNER TO keycloak;

--
-- Name: credential; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    user_id character varying(36),
    created_date bigint,
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer,
    version integer DEFAULT 0
);


ALTER TABLE public.credential OWNER TO keycloak;

--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE public.databasechangelog OWNER TO keycloak;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO keycloak;

--
-- Name: default_client_scope; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.default_client_scope (
    realm_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


ALTER TABLE public.default_client_scope OWNER TO keycloak;

--
-- Name: event_entity; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.event_entity (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    details_json character varying(2550),
    error character varying(255),
    ip_address character varying(255),
    realm_id character varying(255),
    session_id character varying(255),
    event_time bigint,
    type character varying(255),
    user_id character varying(255),
    details_json_long_value text
);


ALTER TABLE public.event_entity OWNER TO keycloak;

--
-- Name: fed_user_attribute; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.fed_user_attribute (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    value character varying(2024),
    long_value_hash bytea,
    long_value_hash_lower_case bytea,
    long_value text
);


ALTER TABLE public.fed_user_attribute OWNER TO keycloak;

--
-- Name: fed_user_consent; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.fed_user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


ALTER TABLE public.fed_user_consent OWNER TO keycloak;

--
-- Name: fed_user_consent_cl_scope; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.fed_user_consent_cl_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.fed_user_consent_cl_scope OWNER TO keycloak;

--
-- Name: fed_user_credential; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.fed_user_credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    created_date bigint,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer
);


ALTER TABLE public.fed_user_credential OWNER TO keycloak;

--
-- Name: fed_user_group_membership; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.fed_user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_group_membership OWNER TO keycloak;

--
-- Name: fed_user_required_action; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.fed_user_required_action (
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_required_action OWNER TO keycloak;

--
-- Name: fed_user_role_mapping; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.fed_user_role_mapping (
    role_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_role_mapping OWNER TO keycloak;

--
-- Name: federated_identity; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.federated_identity (
    identity_provider character varying(255) NOT NULL,
    realm_id character varying(36),
    federated_user_id character varying(255),
    federated_username character varying(255),
    token text,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.federated_identity OWNER TO keycloak;

--
-- Name: federated_user; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.federated_user (
    id character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.federated_user OWNER TO keycloak;

--
-- Name: group_attribute; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.group_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.group_attribute OWNER TO keycloak;

--
-- Name: group_role_mapping; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.group_role_mapping (
    role_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.group_role_mapping OWNER TO keycloak;

--
-- Name: identity_provider; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.identity_provider (
    internal_id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    provider_alias character varying(255),
    provider_id character varying(255),
    store_token boolean,
    authenticate_by_default boolean,
    realm_id character varying(36),
    add_token_role boolean,
    trust_email boolean,
    first_broker_login_flow_id character varying(36),
    post_broker_login_flow_id character varying(36),
    provider_display_name character varying(255),
    link_only boolean,
    organization_id character varying(255),
    hide_on_login boolean
);


ALTER TABLE public.identity_provider OWNER TO keycloak;

--
-- Name: identity_provider_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.identity_provider_config (
    identity_provider_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.identity_provider_config OWNER TO keycloak;

--
-- Name: identity_provider_mapper; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.identity_provider_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    idp_alias character varying(255) NOT NULL,
    idp_mapper_name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.identity_provider_mapper OWNER TO keycloak;

--
-- Name: idp_mapper_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.idp_mapper_config (
    idp_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.idp_mapper_config OWNER TO keycloak;

--
-- Name: jgroups_ping; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.jgroups_ping (
    address character varying(200) NOT NULL,
    name character varying(200),
    cluster_name character varying(200) NOT NULL,
    ip character varying(200) NOT NULL,
    coord boolean
);


ALTER TABLE public.jgroups_ping OWNER TO keycloak;

--
-- Name: keycloak_group; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.keycloak_group (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_group character varying(36) NOT NULL,
    realm_id character varying(36),
    type integer DEFAULT 0 NOT NULL,
    description character varying(255)
);


ALTER TABLE public.keycloak_group OWNER TO keycloak;

--
-- Name: keycloak_role; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.keycloak_role (
    id character varying(36) NOT NULL,
    client_realm_constraint character varying(255),
    client_role boolean DEFAULT false NOT NULL,
    description character varying(255),
    name character varying(255),
    realm_id character varying(255),
    client character varying(36),
    realm character varying(36)
);


ALTER TABLE public.keycloak_role OWNER TO keycloak;

--
-- Name: migration_model; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.migration_model (
    id character varying(36) NOT NULL,
    version character varying(36),
    update_time bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.migration_model OWNER TO keycloak;

--
-- Name: offline_client_session; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.offline_client_session (
    user_session_id character varying(36) NOT NULL,
    client_id character varying(255) NOT NULL,
    offline_flag character varying(4) NOT NULL,
    "timestamp" integer,
    data text,
    client_storage_provider character varying(36) DEFAULT 'local'::character varying NOT NULL,
    external_client_id character varying(255) DEFAULT 'local'::character varying NOT NULL,
    version integer DEFAULT 0
);


ALTER TABLE public.offline_client_session OWNER TO keycloak;

--
-- Name: offline_user_session; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.offline_user_session (
    user_session_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    created_on integer NOT NULL,
    offline_flag character varying(4) NOT NULL,
    data text,
    last_session_refresh integer DEFAULT 0 NOT NULL,
    broker_session_id character varying(1024),
    version integer DEFAULT 0,
    remember_me boolean
);


ALTER TABLE public.offline_user_session OWNER TO keycloak;

--
-- Name: org; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.org (
    id character varying(255) NOT NULL,
    enabled boolean NOT NULL,
    realm_id character varying(255) NOT NULL,
    group_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(4000),
    alias character varying(255) NOT NULL,
    redirect_url character varying(2048)
);


ALTER TABLE public.org OWNER TO keycloak;

--
-- Name: org_domain; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.org_domain (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    verified boolean NOT NULL,
    org_id character varying(255) NOT NULL
);


ALTER TABLE public.org_domain OWNER TO keycloak;

--
-- Name: org_invitation; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.org_invitation (
    id character varying(36) NOT NULL,
    organization_id character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    created_at integer NOT NULL,
    expires_at integer,
    invite_link character varying(2048)
);


ALTER TABLE public.org_invitation OWNER TO keycloak;

--
-- Name: policy_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.policy_config (
    policy_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.policy_config OWNER TO keycloak;

--
-- Name: protocol_mapper; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.protocol_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    protocol character varying(255) NOT NULL,
    protocol_mapper_name character varying(255) NOT NULL,
    client_id character varying(36),
    client_scope_id character varying(36)
);


ALTER TABLE public.protocol_mapper OWNER TO keycloak;

--
-- Name: protocol_mapper_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.protocol_mapper_config (
    protocol_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.protocol_mapper_config OWNER TO keycloak;

--
-- Name: realm; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm (
    id character varying(36) NOT NULL,
    access_code_lifespan integer,
    user_action_lifespan integer,
    access_token_lifespan integer,
    account_theme character varying(255),
    admin_theme character varying(255),
    email_theme character varying(255),
    enabled boolean DEFAULT false NOT NULL,
    events_enabled boolean DEFAULT false NOT NULL,
    events_expiration bigint,
    login_theme character varying(255),
    name character varying(255),
    not_before integer,
    password_policy character varying(2550),
    registration_allowed boolean DEFAULT false NOT NULL,
    remember_me boolean DEFAULT false NOT NULL,
    reset_password_allowed boolean DEFAULT false NOT NULL,
    social boolean DEFAULT false NOT NULL,
    ssl_required character varying(255),
    sso_idle_timeout integer,
    sso_max_lifespan integer,
    update_profile_on_soc_login boolean DEFAULT false NOT NULL,
    verify_email boolean DEFAULT false NOT NULL,
    master_admin_client character varying(36),
    login_lifespan integer,
    internationalization_enabled boolean DEFAULT false NOT NULL,
    default_locale character varying(255),
    reg_email_as_username boolean DEFAULT false NOT NULL,
    admin_events_enabled boolean DEFAULT false NOT NULL,
    admin_events_details_enabled boolean DEFAULT false NOT NULL,
    edit_username_allowed boolean DEFAULT false NOT NULL,
    otp_policy_counter integer DEFAULT 0,
    otp_policy_window integer DEFAULT 1,
    otp_policy_period integer DEFAULT 30,
    otp_policy_digits integer DEFAULT 6,
    otp_policy_alg character varying(36) DEFAULT 'HmacSHA1'::character varying,
    otp_policy_type character varying(36) DEFAULT 'totp'::character varying,
    browser_flow character varying(36),
    registration_flow character varying(36),
    direct_grant_flow character varying(36),
    reset_credentials_flow character varying(36),
    client_auth_flow character varying(36),
    offline_session_idle_timeout integer DEFAULT 0,
    revoke_refresh_token boolean DEFAULT false NOT NULL,
    access_token_life_implicit integer DEFAULT 0,
    login_with_email_allowed boolean DEFAULT true NOT NULL,
    duplicate_emails_allowed boolean DEFAULT false NOT NULL,
    docker_auth_flow character varying(36),
    refresh_token_max_reuse integer DEFAULT 0,
    allow_user_managed_access boolean DEFAULT false NOT NULL,
    sso_max_lifespan_remember_me integer DEFAULT 0 NOT NULL,
    sso_idle_timeout_remember_me integer DEFAULT 0 NOT NULL,
    default_role character varying(255)
);


ALTER TABLE public.realm OWNER TO keycloak;

--
-- Name: realm_attribute; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_attribute (
    name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    value text
);


ALTER TABLE public.realm_attribute OWNER TO keycloak;

--
-- Name: realm_default_groups; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_default_groups (
    realm_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.realm_default_groups OWNER TO keycloak;

--
-- Name: realm_enabled_event_types; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_enabled_event_types (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_enabled_event_types OWNER TO keycloak;

--
-- Name: realm_events_listeners; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_events_listeners (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_events_listeners OWNER TO keycloak;

--
-- Name: realm_localizations; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_localizations (
    realm_id character varying(255) NOT NULL,
    locale character varying(255) NOT NULL,
    texts text NOT NULL
);


ALTER TABLE public.realm_localizations OWNER TO keycloak;

--
-- Name: realm_required_credential; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_required_credential (
    type character varying(255) NOT NULL,
    form_label character varying(255),
    input boolean DEFAULT false NOT NULL,
    secret boolean DEFAULT false NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.realm_required_credential OWNER TO keycloak;

--
-- Name: realm_smtp_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_smtp_config (
    realm_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.realm_smtp_config OWNER TO keycloak;

--
-- Name: realm_supported_locales; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.realm_supported_locales (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_supported_locales OWNER TO keycloak;

--
-- Name: redirect_uris; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.redirect_uris (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.redirect_uris OWNER TO keycloak;

--
-- Name: required_action_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.required_action_config (
    required_action_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.required_action_config OWNER TO keycloak;

--
-- Name: required_action_provider; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.required_action_provider (
    id character varying(36) NOT NULL,
    alias character varying(255),
    name character varying(255),
    realm_id character varying(36),
    enabled boolean DEFAULT false NOT NULL,
    default_action boolean DEFAULT false NOT NULL,
    provider_id character varying(255),
    priority integer
);


ALTER TABLE public.required_action_provider OWNER TO keycloak;

--
-- Name: resource_attribute; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    resource_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_attribute OWNER TO keycloak;

--
-- Name: resource_policy; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_policy (
    resource_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_policy OWNER TO keycloak;

--
-- Name: resource_scope; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_scope (
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_scope OWNER TO keycloak;

--
-- Name: resource_server; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_server (
    id character varying(36) NOT NULL,
    allow_rs_remote_mgmt boolean DEFAULT false NOT NULL,
    policy_enforce_mode smallint NOT NULL,
    decision_strategy smallint DEFAULT 1 NOT NULL
);


ALTER TABLE public.resource_server OWNER TO keycloak;

--
-- Name: resource_server_perm_ticket; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_server_perm_ticket (
    id character varying(36) NOT NULL,
    owner character varying(255) NOT NULL,
    requester character varying(255) NOT NULL,
    created_timestamp bigint NOT NULL,
    granted_timestamp bigint,
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36),
    resource_server_id character varying(36) NOT NULL,
    policy_id character varying(36)
);


ALTER TABLE public.resource_server_perm_ticket OWNER TO keycloak;

--
-- Name: resource_server_policy; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_server_policy (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    type character varying(255) NOT NULL,
    decision_strategy smallint,
    logic smallint,
    resource_server_id character varying(36) NOT NULL,
    owner character varying(255)
);


ALTER TABLE public.resource_server_policy OWNER TO keycloak;

--
-- Name: resource_server_resource; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_server_resource (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255),
    icon_uri character varying(255),
    owner character varying(255) NOT NULL,
    resource_server_id character varying(36) NOT NULL,
    owner_managed_access boolean DEFAULT false NOT NULL,
    display_name character varying(255)
);


ALTER TABLE public.resource_server_resource OWNER TO keycloak;

--
-- Name: resource_server_scope; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_server_scope (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon_uri character varying(255),
    resource_server_id character varying(36) NOT NULL,
    display_name character varying(255)
);


ALTER TABLE public.resource_server_scope OWNER TO keycloak;

--
-- Name: resource_uris; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.resource_uris (
    resource_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.resource_uris OWNER TO keycloak;

--
-- Name: revoked_token; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.revoked_token (
    id character varying(255) NOT NULL,
    expire bigint NOT NULL
);


ALTER TABLE public.revoked_token OWNER TO keycloak;

--
-- Name: role_attribute; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.role_attribute (
    id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255)
);


ALTER TABLE public.role_attribute OWNER TO keycloak;

--
-- Name: scope_mapping; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.scope_mapping (
    client_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


ALTER TABLE public.scope_mapping OWNER TO keycloak;

--
-- Name: scope_policy; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.scope_policy (
    scope_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


ALTER TABLE public.scope_policy OWNER TO keycloak;

--
-- Name: server_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.server_config (
    server_config_key character varying(255) NOT NULL,
    value text NOT NULL,
    version integer DEFAULT 0
);


ALTER TABLE public.server_config OWNER TO keycloak;

--
-- Name: user_attribute; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_attribute (
    name character varying(255) NOT NULL,
    value character varying(255),
    user_id character varying(36) NOT NULL,
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    long_value_hash bytea,
    long_value_hash_lower_case bytea,
    long_value text
);


ALTER TABLE public.user_attribute OWNER TO keycloak;

--
-- Name: user_consent; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(36) NOT NULL,
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


ALTER TABLE public.user_consent OWNER TO keycloak;

--
-- Name: user_consent_client_scope; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_consent_client_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.user_consent_client_scope OWNER TO keycloak;

--
-- Name: user_entity; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_entity (
    id character varying(36) NOT NULL,
    email character varying(255),
    email_constraint character varying(255),
    email_verified boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    federation_link character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    realm_id character varying(255),
    username character varying(255),
    created_timestamp bigint,
    service_account_client_link character varying(255),
    not_before integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_entity OWNER TO keycloak;

--
-- Name: user_federation_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_federation_config (
    user_federation_provider_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.user_federation_config OWNER TO keycloak;

--
-- Name: user_federation_mapper; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_federation_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    federation_provider_id character varying(36) NOT NULL,
    federation_mapper_type character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.user_federation_mapper OWNER TO keycloak;

--
-- Name: user_federation_mapper_config; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_federation_mapper_config (
    user_federation_mapper_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.user_federation_mapper_config OWNER TO keycloak;

--
-- Name: user_federation_provider; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_federation_provider (
    id character varying(36) NOT NULL,
    changed_sync_period integer,
    display_name character varying(255),
    full_sync_period integer,
    last_sync integer,
    priority integer,
    provider_name character varying(255),
    realm_id character varying(36)
);


ALTER TABLE public.user_federation_provider OWNER TO keycloak;

--
-- Name: user_group_membership; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    membership_type character varying(255) NOT NULL
);


ALTER TABLE public.user_group_membership OWNER TO keycloak;

--
-- Name: user_required_action; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_required_action (
    user_id character varying(36) NOT NULL,
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL
);


ALTER TABLE public.user_required_action OWNER TO keycloak;

--
-- Name: user_role_mapping; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.user_role_mapping (
    role_id character varying(255) NOT NULL,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.user_role_mapping OWNER TO keycloak;

--
-- Name: web_origins; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.web_origins (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.web_origins OWNER TO keycloak;

--
-- Name: workflow_state; Type: TABLE; Schema: public; Owner: keycloak
--

CREATE TABLE public.workflow_state (
    execution_id character varying(255) NOT NULL,
    resource_id character varying(255) NOT NULL,
    workflow_id character varying(255) NOT NULL,
    resource_type character varying(255),
    scheduled_step_id character varying(255),
    scheduled_step_timestamp bigint
);


ALTER TABLE public.workflow_state OWNER TO keycloak;

--
-- Data for Name: admin_event_entity; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.admin_event_entity (id, admin_event_time, realm_id, operation_type, auth_realm_id, auth_client_id, auth_user_id, ip_address, resource_path, representation, error, resource_type, details_json) FROM stdin;
\.


--
-- Data for Name: associated_policy; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.associated_policy (policy_id, associated_policy_id) FROM stdin;
\.


--
-- Data for Name: authentication_execution; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.authentication_execution (id, alias, authenticator, realm_id, flow_id, requirement, priority, authenticator_flow, auth_flow_id, auth_config) FROM stdin;
44ca95d8-3aad-499d-bee9-527c57c4079b	\N	auth-cookie	173713f9-5e66-4a52-87f5-eff68df04cdc	10b78065-d497-46b3-9462-4dbbeee28183	2	10	f	\N	\N
bae59e14-0ba5-47db-9661-c135fefe6c59	\N	auth-spnego	173713f9-5e66-4a52-87f5-eff68df04cdc	10b78065-d497-46b3-9462-4dbbeee28183	3	20	f	\N	\N
905a7390-529d-4b57-a8e8-01f820e9b913	\N	identity-provider-redirector	173713f9-5e66-4a52-87f5-eff68df04cdc	10b78065-d497-46b3-9462-4dbbeee28183	2	25	f	\N	\N
486d8864-8ad0-4a04-aa81-55ebd65ec304	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	10b78065-d497-46b3-9462-4dbbeee28183	2	30	t	43be64dd-47bb-46ac-8264-10268b230e37	\N
13d17f47-c05a-40aa-b69c-772d5174cbe8	\N	auth-username-password-form	173713f9-5e66-4a52-87f5-eff68df04cdc	43be64dd-47bb-46ac-8264-10268b230e37	0	10	f	\N	\N
f2afbd88-8bed-4999-99fd-7f02da1eab93	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	43be64dd-47bb-46ac-8264-10268b230e37	1	20	t	ae05382d-1e3d-4808-af43-df9a78d25ec8	\N
cd3c5e4d-7df9-43e8-b489-b8986d7906e1	\N	conditional-user-configured	173713f9-5e66-4a52-87f5-eff68df04cdc	ae05382d-1e3d-4808-af43-df9a78d25ec8	0	10	f	\N	\N
8272810a-63e2-4e29-bb6c-dde677b1af6e	\N	conditional-credential	173713f9-5e66-4a52-87f5-eff68df04cdc	ae05382d-1e3d-4808-af43-df9a78d25ec8	0	20	f	\N	5b7f77e1-9068-472f-a019-7b8c07975fa3
b28c7f4c-7e5b-4251-ad45-e6bb3ebb36ac	\N	auth-otp-form	173713f9-5e66-4a52-87f5-eff68df04cdc	ae05382d-1e3d-4808-af43-df9a78d25ec8	2	30	f	\N	\N
b58cf3c0-546f-4758-a821-ea73516e6e31	\N	webauthn-authenticator	173713f9-5e66-4a52-87f5-eff68df04cdc	ae05382d-1e3d-4808-af43-df9a78d25ec8	3	40	f	\N	\N
bb716c1e-1e39-443a-99ae-79a3f6eec4d8	\N	auth-recovery-authn-code-form	173713f9-5e66-4a52-87f5-eff68df04cdc	ae05382d-1e3d-4808-af43-df9a78d25ec8	3	50	f	\N	\N
4afe1e27-05c8-404c-a158-6568bd1df2f4	\N	direct-grant-validate-username	173713f9-5e66-4a52-87f5-eff68df04cdc	ae639f6f-9b0f-4b00-8f72-5bba680d93ea	0	10	f	\N	\N
9781f6ad-d2e5-47c4-a0f2-424bb41eb0e7	\N	direct-grant-validate-password	173713f9-5e66-4a52-87f5-eff68df04cdc	ae639f6f-9b0f-4b00-8f72-5bba680d93ea	0	20	f	\N	\N
1498f992-ebaf-45f2-8abf-2b450795e232	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	ae639f6f-9b0f-4b00-8f72-5bba680d93ea	1	30	t	235c61ad-8a2c-40cc-ae92-34d30449ed7e	\N
e599130d-ae2e-4c8d-b113-3e26d716b797	\N	conditional-user-configured	173713f9-5e66-4a52-87f5-eff68df04cdc	235c61ad-8a2c-40cc-ae92-34d30449ed7e	0	10	f	\N	\N
61d281c3-1d1a-4a52-80a8-0d0f09b5f5c9	\N	direct-grant-validate-otp	173713f9-5e66-4a52-87f5-eff68df04cdc	235c61ad-8a2c-40cc-ae92-34d30449ed7e	0	20	f	\N	\N
0c7e87f5-b93f-47bd-8d09-36e5bbc5e061	\N	registration-page-form	173713f9-5e66-4a52-87f5-eff68df04cdc	732c38eb-0080-42da-b7e2-936f64b67fb7	0	10	t	457331c0-6885-4eaf-9778-d62238a5c089	\N
89f43268-a3d1-4c17-9048-ffc5cac6712e	\N	registration-user-creation	173713f9-5e66-4a52-87f5-eff68df04cdc	457331c0-6885-4eaf-9778-d62238a5c089	0	20	f	\N	\N
f3f5d1c1-8046-4bc2-a0f9-be441e0fe3ae	\N	registration-password-action	173713f9-5e66-4a52-87f5-eff68df04cdc	457331c0-6885-4eaf-9778-d62238a5c089	0	50	f	\N	\N
f6025888-9ed7-455f-b21f-1d0adac362ba	\N	registration-recaptcha-action	173713f9-5e66-4a52-87f5-eff68df04cdc	457331c0-6885-4eaf-9778-d62238a5c089	3	60	f	\N	\N
bf685ede-a882-484b-a3f0-322e440caa8f	\N	registration-terms-and-conditions	173713f9-5e66-4a52-87f5-eff68df04cdc	457331c0-6885-4eaf-9778-d62238a5c089	3	70	f	\N	\N
c300285e-6e63-4375-ba06-bd462411683a	\N	reset-credentials-choose-user	173713f9-5e66-4a52-87f5-eff68df04cdc	65566feb-7989-4d69-b58e-b3f099b2a480	0	10	f	\N	\N
0e49a965-ad7d-4b9e-8911-1e1f862ae714	\N	reset-credential-email	173713f9-5e66-4a52-87f5-eff68df04cdc	65566feb-7989-4d69-b58e-b3f099b2a480	0	20	f	\N	\N
21f127d7-c869-45a4-9fb9-6d0d14be8f07	\N	reset-password	173713f9-5e66-4a52-87f5-eff68df04cdc	65566feb-7989-4d69-b58e-b3f099b2a480	0	30	f	\N	\N
ceaa3048-1d25-4e04-b8c1-817cca9ce585	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	65566feb-7989-4d69-b58e-b3f099b2a480	1	40	t	80abf8ac-46f7-46e9-80aa-8cc4f7b3a739	\N
b048cb39-0836-4b8f-bedf-232d2cb9088b	\N	conditional-user-configured	173713f9-5e66-4a52-87f5-eff68df04cdc	80abf8ac-46f7-46e9-80aa-8cc4f7b3a739	0	10	f	\N	\N
90372b5a-49a6-4c88-aba5-2201e5019e95	\N	reset-otp	173713f9-5e66-4a52-87f5-eff68df04cdc	80abf8ac-46f7-46e9-80aa-8cc4f7b3a739	0	20	f	\N	\N
1ab95334-a5e6-4bd8-97c8-e688267019e7	\N	client-secret	173713f9-5e66-4a52-87f5-eff68df04cdc	ebdb190f-7059-4ff0-8961-0e92d75b160f	2	10	f	\N	\N
f11a2c07-7d6e-4368-b352-c5a097fca676	\N	client-jwt	173713f9-5e66-4a52-87f5-eff68df04cdc	ebdb190f-7059-4ff0-8961-0e92d75b160f	2	20	f	\N	\N
2a402543-3fea-4232-b0fc-189f530bc5af	\N	client-secret-jwt	173713f9-5e66-4a52-87f5-eff68df04cdc	ebdb190f-7059-4ff0-8961-0e92d75b160f	2	30	f	\N	\N
d15abce0-b631-4ec8-a16c-58a1ed3b9b96	\N	client-x509	173713f9-5e66-4a52-87f5-eff68df04cdc	ebdb190f-7059-4ff0-8961-0e92d75b160f	2	40	f	\N	\N
437a1ca6-23c6-47e7-b38a-4a85a8e32990	\N	idp-review-profile	173713f9-5e66-4a52-87f5-eff68df04cdc	6842ad4f-43b7-49cf-8992-bced308e206a	0	10	f	\N	6d8edb26-9ecf-4ec4-b459-5f4faf5f2709
9474acaa-e8e5-46b1-9ead-a84acde505ff	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	6842ad4f-43b7-49cf-8992-bced308e206a	0	20	t	d4207c37-bc89-48ea-8126-e5884b391a7f	\N
4c27d781-e898-4dfb-9b5d-0be5c4554d32	\N	idp-create-user-if-unique	173713f9-5e66-4a52-87f5-eff68df04cdc	d4207c37-bc89-48ea-8126-e5884b391a7f	2	10	f	\N	cc06c851-9bd9-4ddb-9fba-051bbbc12942
536504b9-3a6d-4875-97a8-42b7ddd08a08	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	d4207c37-bc89-48ea-8126-e5884b391a7f	2	20	t	62f864ed-8a74-4b72-ad6b-e725df0c2988	\N
a019fda5-d65f-4507-b117-f6949d1babba	\N	idp-confirm-link	173713f9-5e66-4a52-87f5-eff68df04cdc	62f864ed-8a74-4b72-ad6b-e725df0c2988	0	10	f	\N	\N
d7edb428-dae5-47b1-ab68-ab8b67ca7959	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	62f864ed-8a74-4b72-ad6b-e725df0c2988	0	20	t	e520cbeb-1d3e-4bbe-92fd-a0370ec4ef30	\N
1065c2b6-1afd-41d1-9e3f-6c81d29a1f4c	\N	idp-email-verification	173713f9-5e66-4a52-87f5-eff68df04cdc	e520cbeb-1d3e-4bbe-92fd-a0370ec4ef30	2	10	f	\N	\N
d62cdb45-8785-4541-9654-113439c56c2f	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	e520cbeb-1d3e-4bbe-92fd-a0370ec4ef30	2	20	t	10808413-5901-4b73-add7-9ae264e44c46	\N
663e5efc-574f-4282-97bf-5bfc9bd2ba6a	\N	idp-username-password-form	173713f9-5e66-4a52-87f5-eff68df04cdc	10808413-5901-4b73-add7-9ae264e44c46	0	10	f	\N	\N
71ff7c45-fd68-44e2-b9c5-c5ca4153229f	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	10808413-5901-4b73-add7-9ae264e44c46	1	20	t	4cc6168a-fce7-4246-9d53-a0d5664aca98	\N
d374db85-d990-4fe5-b19d-7531ccb814b5	\N	conditional-user-configured	173713f9-5e66-4a52-87f5-eff68df04cdc	4cc6168a-fce7-4246-9d53-a0d5664aca98	0	10	f	\N	\N
ac552776-14e3-4402-b285-17ba049e191f	\N	conditional-credential	173713f9-5e66-4a52-87f5-eff68df04cdc	4cc6168a-fce7-4246-9d53-a0d5664aca98	0	20	f	\N	1c0c3bb7-28d6-4ae4-bb4e-e640c61ff835
b791b3f0-0dd2-4b45-89c5-660d2a8a2c1c	\N	auth-otp-form	173713f9-5e66-4a52-87f5-eff68df04cdc	4cc6168a-fce7-4246-9d53-a0d5664aca98	2	30	f	\N	\N
0abe292d-4aa5-42a5-a751-05a99a2aec7d	\N	webauthn-authenticator	173713f9-5e66-4a52-87f5-eff68df04cdc	4cc6168a-fce7-4246-9d53-a0d5664aca98	3	40	f	\N	\N
772f5b88-6d8b-41aa-bb67-c258ae5add8a	\N	auth-recovery-authn-code-form	173713f9-5e66-4a52-87f5-eff68df04cdc	4cc6168a-fce7-4246-9d53-a0d5664aca98	3	50	f	\N	\N
63d5e6f3-7005-4276-89d4-133ba68589c6	\N	http-basic-authenticator	173713f9-5e66-4a52-87f5-eff68df04cdc	577c935a-212d-4f58-8d44-64e23efbaa12	0	10	f	\N	\N
dff9fb48-bab3-4144-8e93-fb02f439e5d9	\N	docker-http-basic-authenticator	173713f9-5e66-4a52-87f5-eff68df04cdc	3718a866-6fc4-43c0-8d90-793e1b4088bb	0	10	f	\N	\N
bdbf3a5a-027e-43ad-b614-721380aee1d4	\N	auth-cookie	a7442214-2630-4991-aa3c-a2f06c383451	b36ffeb7-3468-42ec-88b3-6241d6a0fe28	2	10	f	\N	\N
645f2657-52e4-4c0c-bd3d-9d2aea419c5a	\N	auth-spnego	a7442214-2630-4991-aa3c-a2f06c383451	b36ffeb7-3468-42ec-88b3-6241d6a0fe28	3	20	f	\N	\N
3bf161f9-db1d-4c04-a745-042cef9c7394	\N	identity-provider-redirector	a7442214-2630-4991-aa3c-a2f06c383451	b36ffeb7-3468-42ec-88b3-6241d6a0fe28	2	25	f	\N	\N
095eabbe-53cf-43fe-86f5-eb725a3a61a0	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	b36ffeb7-3468-42ec-88b3-6241d6a0fe28	2	30	t	30a498bb-e6cb-47d1-9ae0-3ec16c0ceef4	\N
ffcd66f0-f5ac-4fd4-9537-493bdba54dce	\N	auth-username-password-form	a7442214-2630-4991-aa3c-a2f06c383451	30a498bb-e6cb-47d1-9ae0-3ec16c0ceef4	0	10	f	\N	\N
00e2b945-1ab9-4dd8-9e8b-744b969588c2	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	30a498bb-e6cb-47d1-9ae0-3ec16c0ceef4	1	20	t	92561583-eba1-40d7-ab43-15dfbeeef6e4	\N
9db34a4e-089f-477d-89df-e02e31d255d3	\N	conditional-user-configured	a7442214-2630-4991-aa3c-a2f06c383451	92561583-eba1-40d7-ab43-15dfbeeef6e4	0	10	f	\N	\N
fad8088a-d261-488d-a21a-9d4d04f795bd	\N	conditional-credential	a7442214-2630-4991-aa3c-a2f06c383451	92561583-eba1-40d7-ab43-15dfbeeef6e4	0	20	f	\N	276a07cd-9392-4fa4-a08d-fa43e7e93ab9
d1068d32-3a28-4a77-be8d-db173ec736b2	\N	auth-otp-form	a7442214-2630-4991-aa3c-a2f06c383451	92561583-eba1-40d7-ab43-15dfbeeef6e4	2	30	f	\N	\N
f9fa62f1-d272-4d58-8a96-924504237a90	\N	webauthn-authenticator	a7442214-2630-4991-aa3c-a2f06c383451	92561583-eba1-40d7-ab43-15dfbeeef6e4	3	40	f	\N	\N
e275dfce-8999-462c-a910-c72d06f44f9f	\N	auth-recovery-authn-code-form	a7442214-2630-4991-aa3c-a2f06c383451	92561583-eba1-40d7-ab43-15dfbeeef6e4	3	50	f	\N	\N
b1cbffb4-3d24-4165-9ed7-a0c0c8cce146	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	b36ffeb7-3468-42ec-88b3-6241d6a0fe28	2	26	t	2ea3e0b6-1c41-4a7f-9b5d-7e803688ec22	\N
081f876e-eab7-4b64-b6f4-9cf7d186ff0f	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	2ea3e0b6-1c41-4a7f-9b5d-7e803688ec22	1	10	t	021dd5c3-4419-4134-9261-b64a5da268c9	\N
d2c9319b-9e66-473b-b033-0ffccfbe2fa8	\N	conditional-user-configured	a7442214-2630-4991-aa3c-a2f06c383451	021dd5c3-4419-4134-9261-b64a5da268c9	0	10	f	\N	\N
4bbb172b-04c1-4766-82e5-18c7bce151ea	\N	organization	a7442214-2630-4991-aa3c-a2f06c383451	021dd5c3-4419-4134-9261-b64a5da268c9	2	20	f	\N	\N
90fd092a-20ad-48bd-b724-2ad6ac068ad7	\N	direct-grant-validate-username	a7442214-2630-4991-aa3c-a2f06c383451	58425c44-98bd-4245-b744-1c32f7694a72	0	10	f	\N	\N
b1e897b0-1c93-458b-9f58-105d0d5c3694	\N	direct-grant-validate-password	a7442214-2630-4991-aa3c-a2f06c383451	58425c44-98bd-4245-b744-1c32f7694a72	0	20	f	\N	\N
b8d359a7-9fe5-47c6-8942-abcac56f5f8d	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	58425c44-98bd-4245-b744-1c32f7694a72	1	30	t	4d8917e5-5cd8-450a-b106-6939ed453d5d	\N
94fcca69-4753-4b32-bda5-10efac249569	\N	conditional-user-configured	a7442214-2630-4991-aa3c-a2f06c383451	4d8917e5-5cd8-450a-b106-6939ed453d5d	0	10	f	\N	\N
25fe245f-9dff-4261-886b-15b6a594fe82	\N	direct-grant-validate-otp	a7442214-2630-4991-aa3c-a2f06c383451	4d8917e5-5cd8-450a-b106-6939ed453d5d	0	20	f	\N	\N
8b766ba7-8714-4035-8cea-57546df448ae	\N	registration-page-form	a7442214-2630-4991-aa3c-a2f06c383451	593dddc8-ba1b-4124-8bae-40f96cc8731e	0	10	t	bdfdf2ce-011b-46d9-9b20-940a4d37e87e	\N
ec185cb9-ddcc-4665-842a-fe882e8cf98a	\N	registration-user-creation	a7442214-2630-4991-aa3c-a2f06c383451	bdfdf2ce-011b-46d9-9b20-940a4d37e87e	0	20	f	\N	\N
61e7e6d9-03d7-412c-8e20-550fb25c1d6c	\N	registration-password-action	a7442214-2630-4991-aa3c-a2f06c383451	bdfdf2ce-011b-46d9-9b20-940a4d37e87e	0	50	f	\N	\N
9ff21f76-677b-497a-859b-0ddf89842fa7	\N	registration-recaptcha-action	a7442214-2630-4991-aa3c-a2f06c383451	bdfdf2ce-011b-46d9-9b20-940a4d37e87e	3	60	f	\N	\N
2ae74441-a335-4818-9784-e2500c6435cb	\N	registration-terms-and-conditions	a7442214-2630-4991-aa3c-a2f06c383451	bdfdf2ce-011b-46d9-9b20-940a4d37e87e	3	70	f	\N	\N
a9376402-f46e-4095-a143-42955e47205d	\N	reset-credentials-choose-user	a7442214-2630-4991-aa3c-a2f06c383451	11b0e8b6-db74-4700-9a4a-f91b42073d78	0	10	f	\N	\N
d37fe0cf-56e4-405a-9ada-e3fee1330ddb	\N	reset-credential-email	a7442214-2630-4991-aa3c-a2f06c383451	11b0e8b6-db74-4700-9a4a-f91b42073d78	0	20	f	\N	\N
0db6261e-3e48-4215-8df5-4b1b335c13d9	\N	reset-password	a7442214-2630-4991-aa3c-a2f06c383451	11b0e8b6-db74-4700-9a4a-f91b42073d78	0	30	f	\N	\N
57f1c090-00d9-4a4a-a951-7d43b69dfd84	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	11b0e8b6-db74-4700-9a4a-f91b42073d78	1	40	t	043576a5-5a95-499a-8f01-ec8eb78997df	\N
62fab159-cba1-4b27-84da-b420bebe6e79	\N	conditional-user-configured	a7442214-2630-4991-aa3c-a2f06c383451	043576a5-5a95-499a-8f01-ec8eb78997df	0	10	f	\N	\N
315282ec-44c4-433a-a0b4-321a64e8ec0b	\N	reset-otp	a7442214-2630-4991-aa3c-a2f06c383451	043576a5-5a95-499a-8f01-ec8eb78997df	0	20	f	\N	\N
8a9f9727-931b-470b-a193-50249e6d5e5c	\N	client-secret	a7442214-2630-4991-aa3c-a2f06c383451	aa9110e2-b21e-4481-8862-a4548e3c690e	2	10	f	\N	\N
79898ce2-5216-49e6-b61f-aaef53448287	\N	client-jwt	a7442214-2630-4991-aa3c-a2f06c383451	aa9110e2-b21e-4481-8862-a4548e3c690e	2	20	f	\N	\N
786cf66b-ea42-4bb0-b0ab-3745302ebb83	\N	client-secret-jwt	a7442214-2630-4991-aa3c-a2f06c383451	aa9110e2-b21e-4481-8862-a4548e3c690e	2	30	f	\N	\N
0b585ebc-010e-45d2-9c04-09c37a86926b	\N	client-x509	a7442214-2630-4991-aa3c-a2f06c383451	aa9110e2-b21e-4481-8862-a4548e3c690e	2	40	f	\N	\N
514db1ea-6b54-49d6-bcca-9c31304ec4de	\N	idp-review-profile	a7442214-2630-4991-aa3c-a2f06c383451	837daab9-0f0c-4d3f-bfae-ea67d17a663a	0	10	f	\N	b6a3fb45-252c-4e74-8635-f3ebce76976c
28fd6bed-f95b-40f8-8fcc-b010f54f019c	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	837daab9-0f0c-4d3f-bfae-ea67d17a663a	0	20	t	3bb4a0c8-e966-405e-8e24-2c82dbdd5776	\N
dbf24040-e23b-418b-94e3-360061595263	\N	idp-create-user-if-unique	a7442214-2630-4991-aa3c-a2f06c383451	3bb4a0c8-e966-405e-8e24-2c82dbdd5776	2	10	f	\N	9938295c-5fa7-46a1-abe3-89dfc164df19
310a4a1d-1b64-4689-925a-48faa96641de	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	3bb4a0c8-e966-405e-8e24-2c82dbdd5776	2	20	t	6c91806c-5587-4513-b14e-879ba61d5b8b	\N
a87e2987-2d83-4967-b554-37891044306c	\N	idp-confirm-link	a7442214-2630-4991-aa3c-a2f06c383451	6c91806c-5587-4513-b14e-879ba61d5b8b	0	10	f	\N	\N
2cbf5319-6b32-4b27-a970-e41cb744ab21	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	6c91806c-5587-4513-b14e-879ba61d5b8b	0	20	t	b6a119f7-cab7-4970-8b20-dce3c1c4804a	\N
54419a5b-4fe7-4c2f-ac89-189d67ddef87	\N	idp-email-verification	a7442214-2630-4991-aa3c-a2f06c383451	b6a119f7-cab7-4970-8b20-dce3c1c4804a	2	10	f	\N	\N
18ff653b-72bc-49d6-94ed-7990ca8cb6e9	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	b6a119f7-cab7-4970-8b20-dce3c1c4804a	2	20	t	5e34f1cc-700b-4981-804d-80cb052abd74	\N
ff7e3878-e49e-403f-968a-9c223cce097b	\N	idp-username-password-form	a7442214-2630-4991-aa3c-a2f06c383451	5e34f1cc-700b-4981-804d-80cb052abd74	0	10	f	\N	\N
0b0a051a-3849-4ca2-b47b-f7d421aadf89	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	5e34f1cc-700b-4981-804d-80cb052abd74	1	20	t	883d3d55-41e4-441d-9969-4e2c9852a76b	\N
bd380b17-b69f-4084-91a2-77c79330c615	\N	conditional-user-configured	a7442214-2630-4991-aa3c-a2f06c383451	883d3d55-41e4-441d-9969-4e2c9852a76b	0	10	f	\N	\N
334a228f-6995-43af-b29c-e1975dc3a0cc	\N	conditional-credential	a7442214-2630-4991-aa3c-a2f06c383451	883d3d55-41e4-441d-9969-4e2c9852a76b	0	20	f	\N	d08f2df0-d1ab-4be9-85b9-919311433dc9
94f97b90-0acd-4573-8827-c2afb4ca6b59	\N	auth-otp-form	a7442214-2630-4991-aa3c-a2f06c383451	883d3d55-41e4-441d-9969-4e2c9852a76b	2	30	f	\N	\N
2fce3b79-d25d-4259-ba70-c66179e441a4	\N	webauthn-authenticator	a7442214-2630-4991-aa3c-a2f06c383451	883d3d55-41e4-441d-9969-4e2c9852a76b	3	40	f	\N	\N
48ec7ad2-c746-4f91-9562-0cffc78ecc79	\N	auth-recovery-authn-code-form	a7442214-2630-4991-aa3c-a2f06c383451	883d3d55-41e4-441d-9969-4e2c9852a76b	3	50	f	\N	\N
c963ce9a-2cdd-4622-ab0c-a584e9d25738	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	837daab9-0f0c-4d3f-bfae-ea67d17a663a	1	60	t	9f15b529-3151-4277-bb33-460d3f0d2cde	\N
299a5aeb-cde0-4e44-bff8-17d007e5429e	\N	conditional-user-configured	a7442214-2630-4991-aa3c-a2f06c383451	9f15b529-3151-4277-bb33-460d3f0d2cde	0	10	f	\N	\N
6591c8a3-56b0-410d-b27f-d33b71ccedb5	\N	idp-add-organization-member	a7442214-2630-4991-aa3c-a2f06c383451	9f15b529-3151-4277-bb33-460d3f0d2cde	0	20	f	\N	\N
fdce0259-16cd-4fb6-94b5-ef42b50eb21b	\N	http-basic-authenticator	a7442214-2630-4991-aa3c-a2f06c383451	8e61c12e-2aac-425a-8a27-d825015cbb57	0	10	f	\N	\N
26d3b9e9-289a-4500-a924-e32e7712b64d	\N	docker-http-basic-authenticator	a7442214-2630-4991-aa3c-a2f06c383451	7644ea7c-29fd-43aa-9f51-9c66d7224b7c	0	10	f	\N	\N
\.


--
-- Data for Name: authentication_flow; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.authentication_flow (id, alias, description, realm_id, provider_id, top_level, built_in) FROM stdin;
10b78065-d497-46b3-9462-4dbbeee28183	browser	Browser based authentication	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	t	t
43be64dd-47bb-46ac-8264-10268b230e37	forms	Username, password, otp and other auth forms.	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
ae05382d-1e3d-4808-af43-df9a78d25ec8	Browser - Conditional 2FA	Flow to determine if any 2FA is required for the authentication	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
ae639f6f-9b0f-4b00-8f72-5bba680d93ea	direct grant	OpenID Connect Resource Owner Grant	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	t	t
235c61ad-8a2c-40cc-ae92-34d30449ed7e	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
732c38eb-0080-42da-b7e2-936f64b67fb7	registration	Registration flow	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	t	t
457331c0-6885-4eaf-9778-d62238a5c089	registration form	Registration form	173713f9-5e66-4a52-87f5-eff68df04cdc	form-flow	f	t
65566feb-7989-4d69-b58e-b3f099b2a480	reset credentials	Reset credentials for a user if they forgot their password or something	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	t	t
80abf8ac-46f7-46e9-80aa-8cc4f7b3a739	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
ebdb190f-7059-4ff0-8961-0e92d75b160f	clients	Base authentication for clients	173713f9-5e66-4a52-87f5-eff68df04cdc	client-flow	t	t
6842ad4f-43b7-49cf-8992-bced308e206a	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	t	t
d4207c37-bc89-48ea-8126-e5884b391a7f	User creation or linking	Flow for the existing/non-existing user alternatives	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
62f864ed-8a74-4b72-ad6b-e725df0c2988	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
e520cbeb-1d3e-4bbe-92fd-a0370ec4ef30	Account verification options	Method with which to verify the existing account	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
10808413-5901-4b73-add7-9ae264e44c46	Verify Existing Account by Re-authentication	Reauthentication of existing account	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
4cc6168a-fce7-4246-9d53-a0d5664aca98	First broker login - Conditional 2FA	Flow to determine if any 2FA is required for the authentication	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	f	t
577c935a-212d-4f58-8d44-64e23efbaa12	saml ecp	SAML ECP Profile Authentication Flow	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	t	t
3718a866-6fc4-43c0-8d90-793e1b4088bb	docker auth	Used by Docker clients to authenticate against the IDP	173713f9-5e66-4a52-87f5-eff68df04cdc	basic-flow	t	t
b36ffeb7-3468-42ec-88b3-6241d6a0fe28	browser	Browser based authentication	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	t	t
30a498bb-e6cb-47d1-9ae0-3ec16c0ceef4	forms	Username, password, otp and other auth forms.	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
92561583-eba1-40d7-ab43-15dfbeeef6e4	Browser - Conditional 2FA	Flow to determine if any 2FA is required for the authentication	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
2ea3e0b6-1c41-4a7f-9b5d-7e803688ec22	Organization	\N	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
021dd5c3-4419-4134-9261-b64a5da268c9	Browser - Conditional Organization	Flow to determine if the organization identity-first login is to be used	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
58425c44-98bd-4245-b744-1c32f7694a72	direct grant	OpenID Connect Resource Owner Grant	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	t	t
4d8917e5-5cd8-450a-b106-6939ed453d5d	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
593dddc8-ba1b-4124-8bae-40f96cc8731e	registration	Registration flow	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	t	t
bdfdf2ce-011b-46d9-9b20-940a4d37e87e	registration form	Registration form	a7442214-2630-4991-aa3c-a2f06c383451	form-flow	f	t
11b0e8b6-db74-4700-9a4a-f91b42073d78	reset credentials	Reset credentials for a user if they forgot their password or something	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	t	t
043576a5-5a95-499a-8f01-ec8eb78997df	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
aa9110e2-b21e-4481-8862-a4548e3c690e	clients	Base authentication for clients	a7442214-2630-4991-aa3c-a2f06c383451	client-flow	t	t
837daab9-0f0c-4d3f-bfae-ea67d17a663a	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	t	t
3bb4a0c8-e966-405e-8e24-2c82dbdd5776	User creation or linking	Flow for the existing/non-existing user alternatives	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
6c91806c-5587-4513-b14e-879ba61d5b8b	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
b6a119f7-cab7-4970-8b20-dce3c1c4804a	Account verification options	Method with which to verify the existing account	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
5e34f1cc-700b-4981-804d-80cb052abd74	Verify Existing Account by Re-authentication	Reauthentication of existing account	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
883d3d55-41e4-441d-9969-4e2c9852a76b	First broker login - Conditional 2FA	Flow to determine if any 2FA is required for the authentication	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
9f15b529-3151-4277-bb33-460d3f0d2cde	First Broker Login - Conditional Organization	Flow to determine if the authenticator that adds organization members is to be used	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	f	t
8e61c12e-2aac-425a-8a27-d825015cbb57	saml ecp	SAML ECP Profile Authentication Flow	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	t	t
7644ea7c-29fd-43aa-9f51-9c66d7224b7c	docker auth	Used by Docker clients to authenticate against the IDP	a7442214-2630-4991-aa3c-a2f06c383451	basic-flow	t	t
\.


--
-- Data for Name: authenticator_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.authenticator_config (id, alias, realm_id) FROM stdin;
5b7f77e1-9068-472f-a019-7b8c07975fa3	browser-conditional-credential	173713f9-5e66-4a52-87f5-eff68df04cdc
6d8edb26-9ecf-4ec4-b459-5f4faf5f2709	review profile config	173713f9-5e66-4a52-87f5-eff68df04cdc
cc06c851-9bd9-4ddb-9fba-051bbbc12942	create unique user config	173713f9-5e66-4a52-87f5-eff68df04cdc
1c0c3bb7-28d6-4ae4-bb4e-e640c61ff835	first-broker-login-conditional-credential	173713f9-5e66-4a52-87f5-eff68df04cdc
276a07cd-9392-4fa4-a08d-fa43e7e93ab9	browser-conditional-credential	a7442214-2630-4991-aa3c-a2f06c383451
b6a3fb45-252c-4e74-8635-f3ebce76976c	review profile config	a7442214-2630-4991-aa3c-a2f06c383451
9938295c-5fa7-46a1-abe3-89dfc164df19	create unique user config	a7442214-2630-4991-aa3c-a2f06c383451
d08f2df0-d1ab-4be9-85b9-919311433dc9	first-broker-login-conditional-credential	a7442214-2630-4991-aa3c-a2f06c383451
\.


--
-- Data for Name: authenticator_config_entry; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.authenticator_config_entry (authenticator_id, value, name) FROM stdin;
1c0c3bb7-28d6-4ae4-bb4e-e640c61ff835	webauthn-passwordless	credentials
5b7f77e1-9068-472f-a019-7b8c07975fa3	webauthn-passwordless	credentials
6d8edb26-9ecf-4ec4-b459-5f4faf5f2709	missing	update.profile.on.first.login
cc06c851-9bd9-4ddb-9fba-051bbbc12942	false	require.password.update.after.registration
276a07cd-9392-4fa4-a08d-fa43e7e93ab9	webauthn-passwordless	credentials
9938295c-5fa7-46a1-abe3-89dfc164df19	false	require.password.update.after.registration
b6a3fb45-252c-4e74-8635-f3ebce76976c	missing	update.profile.on.first.login
d08f2df0-d1ab-4be9-85b9-919311433dc9	webauthn-passwordless	credentials
\.


--
-- Data for Name: broker_link; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.broker_link (identity_provider, storage_provider_id, realm_id, broker_user_id, broker_username, token, user_id) FROM stdin;
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client (id, enabled, full_scope_allowed, client_id, not_before, public_client, secret, base_url, bearer_only, management_url, surrogate_auth_required, realm_id, protocol, node_rereg_timeout, frontchannel_logout, consent_required, name, service_accounts_enabled, client_authenticator_type, root_url, description, registration_token, standard_flow_enabled, implicit_flow_enabled, direct_access_grants_enabled, always_display_in_console) FROM stdin;
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	f	master-realm	0	f	\N	\N	t	\N	f	173713f9-5e66-4a52-87f5-eff68df04cdc	\N	0	f	f	master Realm	f	client-secret	\N	\N	\N	t	f	f	f
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	f	account	0	t	\N	/realms/master/account/	f	\N	f	173713f9-5e66-4a52-87f5-eff68df04cdc	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	t	f	account-console	0	t	\N	/realms/master/account/	f	\N	f	173713f9-5e66-4a52-87f5-eff68df04cdc	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
93343304-6333-4ab7-be3f-82eb2d678425	t	f	broker	0	f	\N	\N	t	\N	f	173713f9-5e66-4a52-87f5-eff68df04cdc	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
b082de96-b6a8-4df3-9f64-263f781ca779	t	t	security-admin-console	0	t	\N	/admin/master/console/	f	\N	f	173713f9-5e66-4a52-87f5-eff68df04cdc	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
620cb797-6940-4455-91a3-fd533cddf8dc	t	t	admin-cli	0	t	\N	\N	f	\N	f	173713f9-5e66-4a52-87f5-eff68df04cdc	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	f	but-tc-realm	0	f	\N	\N	t	\N	f	173713f9-5e66-4a52-87f5-eff68df04cdc	\N	0	f	f	but-tc Realm	f	client-secret	\N	\N	\N	t	f	f	f
20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	f	realm-management	0	f	\N	\N	t	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	0	f	f	${client_realm-management}	f	client-secret	\N	\N	\N	t	f	f	f
de51720b-8d19-440e-8b0e-99c995f8af2a	t	f	account	0	t	\N	/realms/but-tc/account/	f	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	t	f	account-console	0	t	\N	/realms/but-tc/account/	f	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
83215572-4fcd-4174-9bc3-0ba39cc76843	t	f	broker	0	f	\N	\N	t	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
059cc72c-80f8-4975-999d-064aab6c33cb	t	t	security-admin-console	0	t	\N	/admin/but-tc/console/	f	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
80cdb23a-da33-4448-ad6b-8f40bd175981	t	t	admin-cli	0	t	\N	\N	f	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	t	t	skills-hub-app	0	f	ASzD8MghmcXaTSas1MvjiK9o81DrlEeO	\N	f	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	-1	f	f	\N	t	client-secret	\N	\N	\N	t	f	f	f
558cf020-06c9-4dd2-a491-0cdfd9598274	t	t	nextcloud-app	0	f	nextcloud_secret_sso	\N	f	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	-1	f	f	\N	f	client-secret	\N	\N	\N	t	f	f	f
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	t	t	mattermost-app	0	f	mattermost_secret_key_76	\N	f	\N	f	a7442214-2630-4991-aa3c-a2f06c383451	openid-connect	-1	f	f	\N	f	client-secret	\N	\N	\N	t	f	f	f
\.


--
-- Data for Name: client_attributes; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_attributes (client_id, name, value) FROM stdin;
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	post.logout.redirect.uris	+
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	post.logout.redirect.uris	+
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	pkce.code.challenge.method	S256
b082de96-b6a8-4df3-9f64-263f781ca779	post.logout.redirect.uris	+
b082de96-b6a8-4df3-9f64-263f781ca779	pkce.code.challenge.method	S256
b082de96-b6a8-4df3-9f64-263f781ca779	client.use.lightweight.access.token.enabled	true
620cb797-6940-4455-91a3-fd533cddf8dc	client.use.lightweight.access.token.enabled	true
de51720b-8d19-440e-8b0e-99c995f8af2a	post.logout.redirect.uris	+
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	post.logout.redirect.uris	+
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	pkce.code.challenge.method	S256
059cc72c-80f8-4975-999d-064aab6c33cb	post.logout.redirect.uris	+
059cc72c-80f8-4975-999d-064aab6c33cb	pkce.code.challenge.method	S256
059cc72c-80f8-4975-999d-064aab6c33cb	client.use.lightweight.access.token.enabled	true
80cdb23a-da33-4448-ad6b-8f40bd175981	client.use.lightweight.access.token.enabled	true
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	post.logout.redirect.uris	+
\.


--
-- Data for Name: client_auth_flow_bindings; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_auth_flow_bindings (client_id, flow_id, binding_name) FROM stdin;
\.


--
-- Data for Name: client_initial_access; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_initial_access (id, realm_id, "timestamp", expiration, count, remaining_count) FROM stdin;
\.


--
-- Data for Name: client_node_registrations; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_node_registrations (client_id, value, name) FROM stdin;
\.


--
-- Data for Name: client_scope; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_scope (id, name, realm_id, description, protocol) FROM stdin;
e641081f-c540-424c-9eb7-e03f41fff62f	offline_access	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect built-in scope: offline_access	openid-connect
58e6a996-3d50-4a33-b8d5-674dfb11fdbb	role_list	173713f9-5e66-4a52-87f5-eff68df04cdc	SAML role list	saml
863b0daf-5a75-4ad2-8c99-457c82e16045	saml_organization	173713f9-5e66-4a52-87f5-eff68df04cdc	Organization Membership	saml
c4f92b29-90a9-4c4b-bd93-0a1d25f84898	profile	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect built-in scope: profile	openid-connect
5665dcd7-902e-4b20-9b38-0e47bc80c009	email	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect built-in scope: email	openid-connect
4711a09a-93d4-4f9e-aa67-a90401daeea3	address	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect built-in scope: address	openid-connect
964830df-0a11-422d-8a77-c9aff78ff09d	phone	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect built-in scope: phone	openid-connect
f6e49207-ad6a-4152-9f92-cf79d4449e85	roles	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect scope for add user roles to the access token	openid-connect
69efb0fa-6fe0-46a6-ae2c-667cf416685e	web-origins	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect scope for add allowed web origins to the access token	openid-connect
4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	microprofile-jwt	173713f9-5e66-4a52-87f5-eff68df04cdc	Microprofile - JWT built-in scope	openid-connect
dfdcef24-77c2-41d1-bd64-2d94d63081fb	acr	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
db010692-12bf-4b5f-b06c-7a7c439327ba	basic	173713f9-5e66-4a52-87f5-eff68df04cdc	OpenID Connect scope for add all basic claims to the token	openid-connect
aa5ccd32-3bd2-41f0-a73b-bfe121f9b28b	service_account	173713f9-5e66-4a52-87f5-eff68df04cdc	Specific scope for a client enabled for service accounts	openid-connect
cbad17e0-dd30-4561-b93a-bd028b1b12a9	organization	173713f9-5e66-4a52-87f5-eff68df04cdc	Additional claims about the organization a subject belongs to	openid-connect
92adc68e-57b2-4c0e-878b-021752bab844	offline_access	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect built-in scope: offline_access	openid-connect
a5cbc010-15b2-46da-92fb-6e7c1fa33deb	role_list	a7442214-2630-4991-aa3c-a2f06c383451	SAML role list	saml
57ff9868-4808-48e0-869f-adafd96df4f3	saml_organization	a7442214-2630-4991-aa3c-a2f06c383451	Organization Membership	saml
da90fa50-4872-4133-927c-5368959f61df	profile	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect built-in scope: profile	openid-connect
eca420ba-22fa-4830-9f47-179618bcc11f	email	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect built-in scope: email	openid-connect
ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	address	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect built-in scope: address	openid-connect
96d952a9-49e8-42c4-9266-5538cf25c9bf	phone	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect built-in scope: phone	openid-connect
0011c370-9f1b-4999-9c46-83e8719e8c4e	roles	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect scope for add user roles to the access token	openid-connect
6d8986b1-ed20-40e0-adcf-26e2f50f1356	web-origins	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect scope for add allowed web origins to the access token	openid-connect
f5a8fc11-d600-4ebb-89da-0343e556b24a	microprofile-jwt	a7442214-2630-4991-aa3c-a2f06c383451	Microprofile - JWT built-in scope	openid-connect
e55a584b-391b-4628-a522-15f7b2b187db	acr	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
35b9a1a5-6273-43b1-bf48-ac59fb6cd402	basic	a7442214-2630-4991-aa3c-a2f06c383451	OpenID Connect scope for add all basic claims to the token	openid-connect
15816c28-89d5-40fc-a899-16bacdb8fd3b	service_account	a7442214-2630-4991-aa3c-a2f06c383451	Specific scope for a client enabled for service accounts	openid-connect
7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	organization	a7442214-2630-4991-aa3c-a2f06c383451	Additional claims about the organization a subject belongs to	openid-connect
\.


--
-- Data for Name: client_scope_attributes; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_scope_attributes (scope_id, value, name) FROM stdin;
e641081f-c540-424c-9eb7-e03f41fff62f	true	display.on.consent.screen
e641081f-c540-424c-9eb7-e03f41fff62f	${offlineAccessScopeConsentText}	consent.screen.text
58e6a996-3d50-4a33-b8d5-674dfb11fdbb	true	display.on.consent.screen
58e6a996-3d50-4a33-b8d5-674dfb11fdbb	${samlRoleListScopeConsentText}	consent.screen.text
863b0daf-5a75-4ad2-8c99-457c82e16045	false	display.on.consent.screen
c4f92b29-90a9-4c4b-bd93-0a1d25f84898	true	display.on.consent.screen
c4f92b29-90a9-4c4b-bd93-0a1d25f84898	${profileScopeConsentText}	consent.screen.text
c4f92b29-90a9-4c4b-bd93-0a1d25f84898	true	include.in.token.scope
5665dcd7-902e-4b20-9b38-0e47bc80c009	true	display.on.consent.screen
5665dcd7-902e-4b20-9b38-0e47bc80c009	${emailScopeConsentText}	consent.screen.text
5665dcd7-902e-4b20-9b38-0e47bc80c009	true	include.in.token.scope
4711a09a-93d4-4f9e-aa67-a90401daeea3	true	display.on.consent.screen
4711a09a-93d4-4f9e-aa67-a90401daeea3	${addressScopeConsentText}	consent.screen.text
4711a09a-93d4-4f9e-aa67-a90401daeea3	true	include.in.token.scope
964830df-0a11-422d-8a77-c9aff78ff09d	true	display.on.consent.screen
964830df-0a11-422d-8a77-c9aff78ff09d	${phoneScopeConsentText}	consent.screen.text
964830df-0a11-422d-8a77-c9aff78ff09d	true	include.in.token.scope
f6e49207-ad6a-4152-9f92-cf79d4449e85	true	display.on.consent.screen
f6e49207-ad6a-4152-9f92-cf79d4449e85	${rolesScopeConsentText}	consent.screen.text
f6e49207-ad6a-4152-9f92-cf79d4449e85	false	include.in.token.scope
69efb0fa-6fe0-46a6-ae2c-667cf416685e	false	display.on.consent.screen
69efb0fa-6fe0-46a6-ae2c-667cf416685e		consent.screen.text
69efb0fa-6fe0-46a6-ae2c-667cf416685e	false	include.in.token.scope
4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	false	display.on.consent.screen
4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	true	include.in.token.scope
dfdcef24-77c2-41d1-bd64-2d94d63081fb	false	display.on.consent.screen
dfdcef24-77c2-41d1-bd64-2d94d63081fb	false	include.in.token.scope
db010692-12bf-4b5f-b06c-7a7c439327ba	false	display.on.consent.screen
db010692-12bf-4b5f-b06c-7a7c439327ba	false	include.in.token.scope
aa5ccd32-3bd2-41f0-a73b-bfe121f9b28b	false	display.on.consent.screen
aa5ccd32-3bd2-41f0-a73b-bfe121f9b28b	false	include.in.token.scope
cbad17e0-dd30-4561-b93a-bd028b1b12a9	true	display.on.consent.screen
cbad17e0-dd30-4561-b93a-bd028b1b12a9	${organizationScopeConsentText}	consent.screen.text
cbad17e0-dd30-4561-b93a-bd028b1b12a9	true	include.in.token.scope
92adc68e-57b2-4c0e-878b-021752bab844	true	display.on.consent.screen
92adc68e-57b2-4c0e-878b-021752bab844	${offlineAccessScopeConsentText}	consent.screen.text
a5cbc010-15b2-46da-92fb-6e7c1fa33deb	true	display.on.consent.screen
a5cbc010-15b2-46da-92fb-6e7c1fa33deb	${samlRoleListScopeConsentText}	consent.screen.text
57ff9868-4808-48e0-869f-adafd96df4f3	false	display.on.consent.screen
da90fa50-4872-4133-927c-5368959f61df	true	display.on.consent.screen
da90fa50-4872-4133-927c-5368959f61df	${profileScopeConsentText}	consent.screen.text
da90fa50-4872-4133-927c-5368959f61df	true	include.in.token.scope
eca420ba-22fa-4830-9f47-179618bcc11f	true	display.on.consent.screen
eca420ba-22fa-4830-9f47-179618bcc11f	${emailScopeConsentText}	consent.screen.text
eca420ba-22fa-4830-9f47-179618bcc11f	true	include.in.token.scope
ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	true	display.on.consent.screen
ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	${addressScopeConsentText}	consent.screen.text
ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	true	include.in.token.scope
96d952a9-49e8-42c4-9266-5538cf25c9bf	true	display.on.consent.screen
96d952a9-49e8-42c4-9266-5538cf25c9bf	${phoneScopeConsentText}	consent.screen.text
96d952a9-49e8-42c4-9266-5538cf25c9bf	true	include.in.token.scope
0011c370-9f1b-4999-9c46-83e8719e8c4e	true	display.on.consent.screen
0011c370-9f1b-4999-9c46-83e8719e8c4e	${rolesScopeConsentText}	consent.screen.text
0011c370-9f1b-4999-9c46-83e8719e8c4e	false	include.in.token.scope
6d8986b1-ed20-40e0-adcf-26e2f50f1356	false	display.on.consent.screen
6d8986b1-ed20-40e0-adcf-26e2f50f1356		consent.screen.text
6d8986b1-ed20-40e0-adcf-26e2f50f1356	false	include.in.token.scope
f5a8fc11-d600-4ebb-89da-0343e556b24a	false	display.on.consent.screen
f5a8fc11-d600-4ebb-89da-0343e556b24a	true	include.in.token.scope
e55a584b-391b-4628-a522-15f7b2b187db	false	display.on.consent.screen
e55a584b-391b-4628-a522-15f7b2b187db	false	include.in.token.scope
35b9a1a5-6273-43b1-bf48-ac59fb6cd402	false	display.on.consent.screen
35b9a1a5-6273-43b1-bf48-ac59fb6cd402	false	include.in.token.scope
15816c28-89d5-40fc-a899-16bacdb8fd3b	false	display.on.consent.screen
15816c28-89d5-40fc-a899-16bacdb8fd3b	false	include.in.token.scope
7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	true	display.on.consent.screen
7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	${organizationScopeConsentText}	consent.screen.text
7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	true	include.in.token.scope
\.


--
-- Data for Name: client_scope_client; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_scope_client (client_id, scope_id, default_scope) FROM stdin;
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	f6e49207-ad6a-4152-9f92-cf79d4449e85	t
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	db010692-12bf-4b5f-b06c-7a7c439327ba	t
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	69efb0fa-6fe0-46a6-ae2c-667cf416685e	t
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	c4f92b29-90a9-4c4b-bd93-0a1d25f84898	t
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	dfdcef24-77c2-41d1-bd64-2d94d63081fb	t
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	5665dcd7-902e-4b20-9b38-0e47bc80c009	t
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	f
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	e641081f-c540-424c-9eb7-e03f41fff62f	f
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	964830df-0a11-422d-8a77-c9aff78ff09d	f
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	4711a09a-93d4-4f9e-aa67-a90401daeea3	f
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	cbad17e0-dd30-4561-b93a-bd028b1b12a9	f
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	f6e49207-ad6a-4152-9f92-cf79d4449e85	t
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	db010692-12bf-4b5f-b06c-7a7c439327ba	t
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	69efb0fa-6fe0-46a6-ae2c-667cf416685e	t
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	c4f92b29-90a9-4c4b-bd93-0a1d25f84898	t
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	dfdcef24-77c2-41d1-bd64-2d94d63081fb	t
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	5665dcd7-902e-4b20-9b38-0e47bc80c009	t
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	f
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	e641081f-c540-424c-9eb7-e03f41fff62f	f
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	964830df-0a11-422d-8a77-c9aff78ff09d	f
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	4711a09a-93d4-4f9e-aa67-a90401daeea3	f
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	cbad17e0-dd30-4561-b93a-bd028b1b12a9	f
620cb797-6940-4455-91a3-fd533cddf8dc	f6e49207-ad6a-4152-9f92-cf79d4449e85	t
620cb797-6940-4455-91a3-fd533cddf8dc	db010692-12bf-4b5f-b06c-7a7c439327ba	t
620cb797-6940-4455-91a3-fd533cddf8dc	69efb0fa-6fe0-46a6-ae2c-667cf416685e	t
620cb797-6940-4455-91a3-fd533cddf8dc	c4f92b29-90a9-4c4b-bd93-0a1d25f84898	t
620cb797-6940-4455-91a3-fd533cddf8dc	dfdcef24-77c2-41d1-bd64-2d94d63081fb	t
620cb797-6940-4455-91a3-fd533cddf8dc	5665dcd7-902e-4b20-9b38-0e47bc80c009	t
620cb797-6940-4455-91a3-fd533cddf8dc	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	f
620cb797-6940-4455-91a3-fd533cddf8dc	e641081f-c540-424c-9eb7-e03f41fff62f	f
620cb797-6940-4455-91a3-fd533cddf8dc	964830df-0a11-422d-8a77-c9aff78ff09d	f
620cb797-6940-4455-91a3-fd533cddf8dc	4711a09a-93d4-4f9e-aa67-a90401daeea3	f
620cb797-6940-4455-91a3-fd533cddf8dc	cbad17e0-dd30-4561-b93a-bd028b1b12a9	f
93343304-6333-4ab7-be3f-82eb2d678425	f6e49207-ad6a-4152-9f92-cf79d4449e85	t
93343304-6333-4ab7-be3f-82eb2d678425	db010692-12bf-4b5f-b06c-7a7c439327ba	t
93343304-6333-4ab7-be3f-82eb2d678425	69efb0fa-6fe0-46a6-ae2c-667cf416685e	t
93343304-6333-4ab7-be3f-82eb2d678425	c4f92b29-90a9-4c4b-bd93-0a1d25f84898	t
93343304-6333-4ab7-be3f-82eb2d678425	dfdcef24-77c2-41d1-bd64-2d94d63081fb	t
93343304-6333-4ab7-be3f-82eb2d678425	5665dcd7-902e-4b20-9b38-0e47bc80c009	t
93343304-6333-4ab7-be3f-82eb2d678425	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	f
93343304-6333-4ab7-be3f-82eb2d678425	e641081f-c540-424c-9eb7-e03f41fff62f	f
93343304-6333-4ab7-be3f-82eb2d678425	964830df-0a11-422d-8a77-c9aff78ff09d	f
93343304-6333-4ab7-be3f-82eb2d678425	4711a09a-93d4-4f9e-aa67-a90401daeea3	f
93343304-6333-4ab7-be3f-82eb2d678425	cbad17e0-dd30-4561-b93a-bd028b1b12a9	f
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	f6e49207-ad6a-4152-9f92-cf79d4449e85	t
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	db010692-12bf-4b5f-b06c-7a7c439327ba	t
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	69efb0fa-6fe0-46a6-ae2c-667cf416685e	t
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	c4f92b29-90a9-4c4b-bd93-0a1d25f84898	t
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	dfdcef24-77c2-41d1-bd64-2d94d63081fb	t
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	5665dcd7-902e-4b20-9b38-0e47bc80c009	t
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	f
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	e641081f-c540-424c-9eb7-e03f41fff62f	f
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	964830df-0a11-422d-8a77-c9aff78ff09d	f
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	4711a09a-93d4-4f9e-aa67-a90401daeea3	f
10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	cbad17e0-dd30-4561-b93a-bd028b1b12a9	f
b082de96-b6a8-4df3-9f64-263f781ca779	f6e49207-ad6a-4152-9f92-cf79d4449e85	t
b082de96-b6a8-4df3-9f64-263f781ca779	db010692-12bf-4b5f-b06c-7a7c439327ba	t
b082de96-b6a8-4df3-9f64-263f781ca779	69efb0fa-6fe0-46a6-ae2c-667cf416685e	t
b082de96-b6a8-4df3-9f64-263f781ca779	c4f92b29-90a9-4c4b-bd93-0a1d25f84898	t
b082de96-b6a8-4df3-9f64-263f781ca779	dfdcef24-77c2-41d1-bd64-2d94d63081fb	t
b082de96-b6a8-4df3-9f64-263f781ca779	5665dcd7-902e-4b20-9b38-0e47bc80c009	t
b082de96-b6a8-4df3-9f64-263f781ca779	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	f
b082de96-b6a8-4df3-9f64-263f781ca779	e641081f-c540-424c-9eb7-e03f41fff62f	f
b082de96-b6a8-4df3-9f64-263f781ca779	964830df-0a11-422d-8a77-c9aff78ff09d	f
b082de96-b6a8-4df3-9f64-263f781ca779	4711a09a-93d4-4f9e-aa67-a90401daeea3	f
b082de96-b6a8-4df3-9f64-263f781ca779	cbad17e0-dd30-4561-b93a-bd028b1b12a9	f
de51720b-8d19-440e-8b0e-99c995f8af2a	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
de51720b-8d19-440e-8b0e-99c995f8af2a	eca420ba-22fa-4830-9f47-179618bcc11f	t
de51720b-8d19-440e-8b0e-99c995f8af2a	da90fa50-4872-4133-927c-5368959f61df	t
de51720b-8d19-440e-8b0e-99c995f8af2a	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
de51720b-8d19-440e-8b0e-99c995f8af2a	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
de51720b-8d19-440e-8b0e-99c995f8af2a	e55a584b-391b-4628-a522-15f7b2b187db	t
de51720b-8d19-440e-8b0e-99c995f8af2a	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
de51720b-8d19-440e-8b0e-99c995f8af2a	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
de51720b-8d19-440e-8b0e-99c995f8af2a	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
de51720b-8d19-440e-8b0e-99c995f8af2a	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
de51720b-8d19-440e-8b0e-99c995f8af2a	92adc68e-57b2-4c0e-878b-021752bab844	f
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	eca420ba-22fa-4830-9f47-179618bcc11f	t
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	da90fa50-4872-4133-927c-5368959f61df	t
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	e55a584b-391b-4628-a522-15f7b2b187db	t
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	92adc68e-57b2-4c0e-878b-021752bab844	f
80cdb23a-da33-4448-ad6b-8f40bd175981	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
80cdb23a-da33-4448-ad6b-8f40bd175981	eca420ba-22fa-4830-9f47-179618bcc11f	t
80cdb23a-da33-4448-ad6b-8f40bd175981	da90fa50-4872-4133-927c-5368959f61df	t
80cdb23a-da33-4448-ad6b-8f40bd175981	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
80cdb23a-da33-4448-ad6b-8f40bd175981	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
80cdb23a-da33-4448-ad6b-8f40bd175981	e55a584b-391b-4628-a522-15f7b2b187db	t
80cdb23a-da33-4448-ad6b-8f40bd175981	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
80cdb23a-da33-4448-ad6b-8f40bd175981	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
80cdb23a-da33-4448-ad6b-8f40bd175981	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
80cdb23a-da33-4448-ad6b-8f40bd175981	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
80cdb23a-da33-4448-ad6b-8f40bd175981	92adc68e-57b2-4c0e-878b-021752bab844	f
83215572-4fcd-4174-9bc3-0ba39cc76843	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
83215572-4fcd-4174-9bc3-0ba39cc76843	eca420ba-22fa-4830-9f47-179618bcc11f	t
83215572-4fcd-4174-9bc3-0ba39cc76843	da90fa50-4872-4133-927c-5368959f61df	t
83215572-4fcd-4174-9bc3-0ba39cc76843	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
83215572-4fcd-4174-9bc3-0ba39cc76843	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
83215572-4fcd-4174-9bc3-0ba39cc76843	e55a584b-391b-4628-a522-15f7b2b187db	t
83215572-4fcd-4174-9bc3-0ba39cc76843	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
83215572-4fcd-4174-9bc3-0ba39cc76843	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
83215572-4fcd-4174-9bc3-0ba39cc76843	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
83215572-4fcd-4174-9bc3-0ba39cc76843	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
83215572-4fcd-4174-9bc3-0ba39cc76843	92adc68e-57b2-4c0e-878b-021752bab844	f
20c3186e-055d-48bd-ac0c-dfbff0820a4e	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
20c3186e-055d-48bd-ac0c-dfbff0820a4e	eca420ba-22fa-4830-9f47-179618bcc11f	t
20c3186e-055d-48bd-ac0c-dfbff0820a4e	da90fa50-4872-4133-927c-5368959f61df	t
20c3186e-055d-48bd-ac0c-dfbff0820a4e	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
20c3186e-055d-48bd-ac0c-dfbff0820a4e	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
20c3186e-055d-48bd-ac0c-dfbff0820a4e	e55a584b-391b-4628-a522-15f7b2b187db	t
20c3186e-055d-48bd-ac0c-dfbff0820a4e	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
20c3186e-055d-48bd-ac0c-dfbff0820a4e	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
20c3186e-055d-48bd-ac0c-dfbff0820a4e	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
20c3186e-055d-48bd-ac0c-dfbff0820a4e	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
20c3186e-055d-48bd-ac0c-dfbff0820a4e	92adc68e-57b2-4c0e-878b-021752bab844	f
059cc72c-80f8-4975-999d-064aab6c33cb	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
059cc72c-80f8-4975-999d-064aab6c33cb	eca420ba-22fa-4830-9f47-179618bcc11f	t
059cc72c-80f8-4975-999d-064aab6c33cb	da90fa50-4872-4133-927c-5368959f61df	t
059cc72c-80f8-4975-999d-064aab6c33cb	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
059cc72c-80f8-4975-999d-064aab6c33cb	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
059cc72c-80f8-4975-999d-064aab6c33cb	e55a584b-391b-4628-a522-15f7b2b187db	t
059cc72c-80f8-4975-999d-064aab6c33cb	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
059cc72c-80f8-4975-999d-064aab6c33cb	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
059cc72c-80f8-4975-999d-064aab6c33cb	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
059cc72c-80f8-4975-999d-064aab6c33cb	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
059cc72c-80f8-4975-999d-064aab6c33cb	92adc68e-57b2-4c0e-878b-021752bab844	f
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	eca420ba-22fa-4830-9f47-179618bcc11f	t
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	da90fa50-4872-4133-927c-5368959f61df	t
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	e55a584b-391b-4628-a522-15f7b2b187db	t
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	92adc68e-57b2-4c0e-878b-021752bab844	f
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	15816c28-89d5-40fc-a899-16bacdb8fd3b	t
558cf020-06c9-4dd2-a491-0cdfd9598274	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
558cf020-06c9-4dd2-a491-0cdfd9598274	eca420ba-22fa-4830-9f47-179618bcc11f	t
558cf020-06c9-4dd2-a491-0cdfd9598274	da90fa50-4872-4133-927c-5368959f61df	t
558cf020-06c9-4dd2-a491-0cdfd9598274	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
558cf020-06c9-4dd2-a491-0cdfd9598274	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
558cf020-06c9-4dd2-a491-0cdfd9598274	e55a584b-391b-4628-a522-15f7b2b187db	t
558cf020-06c9-4dd2-a491-0cdfd9598274	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
558cf020-06c9-4dd2-a491-0cdfd9598274	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
558cf020-06c9-4dd2-a491-0cdfd9598274	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
558cf020-06c9-4dd2-a491-0cdfd9598274	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
558cf020-06c9-4dd2-a491-0cdfd9598274	92adc68e-57b2-4c0e-878b-021752bab844	f
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	eca420ba-22fa-4830-9f47-179618bcc11f	t
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	da90fa50-4872-4133-927c-5368959f61df	t
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	e55a584b-391b-4628-a522-15f7b2b187db	t
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	92adc68e-57b2-4c0e-878b-021752bab844	f
\.


--
-- Data for Name: client_scope_role_mapping; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.client_scope_role_mapping (scope_id, role_id) FROM stdin;
e641081f-c540-424c-9eb7-e03f41fff62f	6a33a8cd-5e8b-4ed1-9ff1-9c6f5244fe36
92adc68e-57b2-4c0e-878b-021752bab844	bcd790a3-c63d-445f-8f99-3dadc41bcfb2
\.


--
-- Data for Name: component; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.component (id, name, parent_id, provider_id, provider_type, realm_id, sub_type) FROM stdin;
c6a7f3b5-3e71-43cd-b430-1f4c2e17715c	Trusted Hosts	173713f9-5e66-4a52-87f5-eff68df04cdc	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	anonymous
ceb191b2-a1be-4e06-bb20-f2ef3bd5c3ee	Consent Required	173713f9-5e66-4a52-87f5-eff68df04cdc	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	anonymous
71934741-77f3-438d-aa56-ebc48249812c	Full Scope Disabled	173713f9-5e66-4a52-87f5-eff68df04cdc	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	anonymous
74d4c609-96af-47f3-8005-93329bc51c2f	Max Clients Limit	173713f9-5e66-4a52-87f5-eff68df04cdc	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	anonymous
43dc5972-b641-4ffe-b35a-0cf93393e5e1	Allowed Protocol Mapper Types	173713f9-5e66-4a52-87f5-eff68df04cdc	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	anonymous
ee3d3b11-ec50-43b8-97c1-f35dd2def8fd	Allowed Client Scopes	173713f9-5e66-4a52-87f5-eff68df04cdc	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	anonymous
d374928a-4bfb-49c6-b7c9-006c8e92db47	Allowed Registration Web Origins	173713f9-5e66-4a52-87f5-eff68df04cdc	registration-web-origins	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	anonymous
2ba6533a-5bcb-4208-80f3-f7914e443657	Allowed Protocol Mapper Types	173713f9-5e66-4a52-87f5-eff68df04cdc	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	authenticated
cabaaa61-cefb-4a4e-ad15-6b0b5550d8fd	Allowed Client Scopes	173713f9-5e66-4a52-87f5-eff68df04cdc	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	authenticated
bc9e9f1b-d76a-43c6-b40d-04251eebfd0d	Allowed Registration Web Origins	173713f9-5e66-4a52-87f5-eff68df04cdc	registration-web-origins	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	authenticated
882edb05-44bb-4b01-a404-7c4be71f12c3	rsa-generated	173713f9-5e66-4a52-87f5-eff68df04cdc	rsa-generated	org.keycloak.keys.KeyProvider	173713f9-5e66-4a52-87f5-eff68df04cdc	\N
ad6e7cc9-6f89-4b39-b4eb-11814e00016b	rsa-enc-generated	173713f9-5e66-4a52-87f5-eff68df04cdc	rsa-enc-generated	org.keycloak.keys.KeyProvider	173713f9-5e66-4a52-87f5-eff68df04cdc	\N
7e4998e5-71ff-4634-9e9d-da81e98b172d	hmac-generated-hs512	173713f9-5e66-4a52-87f5-eff68df04cdc	hmac-generated	org.keycloak.keys.KeyProvider	173713f9-5e66-4a52-87f5-eff68df04cdc	\N
f0c8d304-1d57-4de4-a2e1-39815b12a869	aes-generated	173713f9-5e66-4a52-87f5-eff68df04cdc	aes-generated	org.keycloak.keys.KeyProvider	173713f9-5e66-4a52-87f5-eff68df04cdc	\N
d05162ec-2e5d-461c-b968-9aaf9f22fe1f	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	declarative-user-profile	org.keycloak.userprofile.UserProfileProvider	173713f9-5e66-4a52-87f5-eff68df04cdc	\N
77c751f1-8d04-4069-a723-51c8fc3da4f0	rsa-generated	a7442214-2630-4991-aa3c-a2f06c383451	rsa-generated	org.keycloak.keys.KeyProvider	a7442214-2630-4991-aa3c-a2f06c383451	\N
ea86a57d-52de-4815-80e9-ff97c5f452cc	rsa-enc-generated	a7442214-2630-4991-aa3c-a2f06c383451	rsa-enc-generated	org.keycloak.keys.KeyProvider	a7442214-2630-4991-aa3c-a2f06c383451	\N
194498d5-2709-4684-b611-257533c1d8bb	hmac-generated-hs512	a7442214-2630-4991-aa3c-a2f06c383451	hmac-generated	org.keycloak.keys.KeyProvider	a7442214-2630-4991-aa3c-a2f06c383451	\N
4c82c427-3372-486c-9974-f95d69fda827	aes-generated	a7442214-2630-4991-aa3c-a2f06c383451	aes-generated	org.keycloak.keys.KeyProvider	a7442214-2630-4991-aa3c-a2f06c383451	\N
a6b522a7-04b0-40e5-86d9-1bbef99546ae	Trusted Hosts	a7442214-2630-4991-aa3c-a2f06c383451	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	anonymous
830b93c3-6ff4-49a9-8704-c23afee6ead6	Consent Required	a7442214-2630-4991-aa3c-a2f06c383451	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	anonymous
b523def4-e324-44da-8298-84e79509fc43	Full Scope Disabled	a7442214-2630-4991-aa3c-a2f06c383451	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	anonymous
0fb7a715-1ddb-48c6-b638-9ba8250215d6	Max Clients Limit	a7442214-2630-4991-aa3c-a2f06c383451	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	anonymous
679e2566-79ae-4946-acb6-3835bc644297	Allowed Protocol Mapper Types	a7442214-2630-4991-aa3c-a2f06c383451	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	anonymous
91f776ef-91a3-4d1a-8131-b9af905110e9	Allowed Client Scopes	a7442214-2630-4991-aa3c-a2f06c383451	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	anonymous
1eca90b8-5205-475a-88d3-f32bf966df7f	Allowed Registration Web Origins	a7442214-2630-4991-aa3c-a2f06c383451	registration-web-origins	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	anonymous
7c00c152-8355-40f3-986d-3c005ba226e7	Allowed Protocol Mapper Types	a7442214-2630-4991-aa3c-a2f06c383451	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	authenticated
b1315da6-aea4-4798-9315-7807398bb424	Allowed Client Scopes	a7442214-2630-4991-aa3c-a2f06c383451	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	authenticated
25e41a98-2a0d-4fbd-abac-44841df5286d	Allowed Registration Web Origins	a7442214-2630-4991-aa3c-a2f06c383451	registration-web-origins	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	a7442214-2630-4991-aa3c-a2f06c383451	authenticated
le4Fc2PlTUmQr1g7oJmuaw	univ-lehavre-ldap	a7442214-2630-4991-aa3c-a2f06c383451	ldap	org.keycloak.storage.UserStorageProvider	a7442214-2630-4991-aa3c-a2f06c383451	\N
863f697e-7581-4736-bc48-2b64259648f1	username	le4Fc2PlTUmQr1g7oJmuaw	user-attribute-ldap-mapper	org.keycloak.storage.ldap.mappers.LDAPStorageMapper	a7442214-2630-4991-aa3c-a2f06c383451	\N
2b0c0b8c-e082-4dbf-bb66-1fb0baaf20c1	first name	le4Fc2PlTUmQr1g7oJmuaw	user-attribute-ldap-mapper	org.keycloak.storage.ldap.mappers.LDAPStorageMapper	a7442214-2630-4991-aa3c-a2f06c383451	\N
9e3e9ff4-86f8-41d2-989d-7ab9f3035a40	last name	le4Fc2PlTUmQr1g7oJmuaw	user-attribute-ldap-mapper	org.keycloak.storage.ldap.mappers.LDAPStorageMapper	a7442214-2630-4991-aa3c-a2f06c383451	\N
b4de1b8b-e22f-4f37-bf65-58b36b5238fc	email	le4Fc2PlTUmQr1g7oJmuaw	user-attribute-ldap-mapper	org.keycloak.storage.ldap.mappers.LDAPStorageMapper	a7442214-2630-4991-aa3c-a2f06c383451	\N
88df0a3a-4b06-4577-baee-d0948f2bcd55	creation date	le4Fc2PlTUmQr1g7oJmuaw	user-attribute-ldap-mapper	org.keycloak.storage.ldap.mappers.LDAPStorageMapper	a7442214-2630-4991-aa3c-a2f06c383451	\N
2aa73ae8-0e6d-4e1d-8730-be4f21d7122b	modify date	le4Fc2PlTUmQr1g7oJmuaw	user-attribute-ldap-mapper	org.keycloak.storage.ldap.mappers.LDAPStorageMapper	a7442214-2630-4991-aa3c-a2f06c383451	\N
aea0e851-d956-4047-aaea-7649be661469	Kerberos principal attribute mapper	le4Fc2PlTUmQr1g7oJmuaw	kerberos-principal-attribute-mapper	org.keycloak.storage.ldap.mappers.LDAPStorageMapper	a7442214-2630-4991-aa3c-a2f06c383451	\N
\.


--
-- Data for Name: component_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.component_config (id, component_id, name, value) FROM stdin;
154cbdc0-c0eb-45a2-9706-bff479d5effa	74d4c609-96af-47f3-8005-93329bc51c2f	max-clients	200
f0fd3055-e671-4dbf-99ff-0f82fd2ede02	ee3d3b11-ec50-43b8-97c1-f35dd2def8fd	allow-default-scopes	true
0d1f9ad2-46b1-47b1-aec9-073d43c47241	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	saml-role-list-mapper
b19917a7-08a6-49b9-b505-42ac7284ffac	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
8ed8f038-619d-44be-81fa-627573ab84ca	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	oidc-full-name-mapper
06bc54e6-cc95-4b79-9191-43592585f903	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	oidc-address-mapper
db23104a-1b84-4f39-b4b5-c771ea524a27	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	saml-user-attribute-mapper
4e7fcf41-8967-4e06-b79e-ec611c1d13c4	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	saml-user-property-mapper
720b126a-7ba0-49ee-b5b2-3187c5472dee	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
0c77a2b1-56e9-4d52-bcef-9bdced1b53af	2ba6533a-5bcb-4208-80f3-f7914e443657	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
bb493a83-3e8d-4104-9e07-51aaf62125aa	c6a7f3b5-3e71-43cd-b430-1f4c2e17715c	host-sending-registration-request-must-match	true
4512febb-75c4-4342-a2ce-3766611a169c	c6a7f3b5-3e71-43cd-b430-1f4c2e17715c	client-uris-must-match	true
a8fa3d1d-5f34-44d1-b7d4-09dab781d9c8	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	oidc-full-name-mapper
4f56b2cc-f0ff-4fc3-8718-da910bc3878f	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
8013e148-4172-40c4-9fe9-27d4eb136e73	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
6fe50866-3321-4f7c-94cd-796e425cb42b	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	oidc-address-mapper
11cac660-3da3-4ba0-b44e-0b29a1ea0dc4	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	saml-role-list-mapper
7d9b8c30-b460-4986-bb72-a69a3978470a	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	saml-user-property-mapper
901450c0-217c-42f5-8eef-b2ad8d540b8e	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	saml-user-attribute-mapper
2cee15e2-3f51-44de-a202-a76a89cf58ec	43dc5972-b641-4ffe-b35a-0cf93393e5e1	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
ea18b63f-e7ae-4e18-ad46-2f5ecca080fa	cabaaa61-cefb-4a4e-ad15-6b0b5550d8fd	allow-default-scopes	true
d0910049-8cac-4fe1-a2ee-1ecb24c20393	f0c8d304-1d57-4de4-a2e1-39815b12a869	kid	1de5f07d-730e-4652-aac1-07e7576f49c5
7e364c15-f2d5-4c9a-be6b-8bfc79698025	f0c8d304-1d57-4de4-a2e1-39815b12a869	secret	CcTkwZAyLyWZiyDNKBwWag
a4c9c529-9f40-4ba7-b02d-ef725f664a64	f0c8d304-1d57-4de4-a2e1-39815b12a869	priority	100
d97f092c-1cfe-4dae-9501-177e270c82cf	7e4998e5-71ff-4634-9e9d-da81e98b172d	secret	H4Ty6r5TKQH_6yHTFqPYrfaCA8iGymbBWWttlUuUC-jjiA-As58CtoDWODFvh0gmdhLq5YNN7NZWYBCjmIhWQJdq5BHZjaaZDJ-n5kDCjRxgk-9FKS03leQVvZnx41twjHECdk8FEarZjxaDZQP9mdU3go5tJxGh0h4EFwE4ons
2653e02d-0b1b-4075-80be-c0c3c1ba1fc3	7e4998e5-71ff-4634-9e9d-da81e98b172d	algorithm	HS512
60e7e834-d6eb-4dbe-a973-6f2ba2d67461	7e4998e5-71ff-4634-9e9d-da81e98b172d	priority	100
e8f32207-fc4c-488d-b16f-dd1b1cd83576	7e4998e5-71ff-4634-9e9d-da81e98b172d	kid	18de2907-6e1c-4123-be36-4a419c2bfd9a
03594001-b0b1-4eb1-bf39-411d88f77304	d05162ec-2e5d-461c-b968-9aaf9f22fe1f	kc.user.profile.config	{"attributes":[{"name":"username","displayName":"${username}","validations":{"length":{"min":3,"max":255},"username-prohibited-characters":{},"up-username-not-idn-homograph":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"email","displayName":"${email}","validations":{"email":{},"length":{"max":255}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"firstName","displayName":"${firstName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"lastName","displayName":"${lastName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false}],"groups":[{"name":"user-metadata","displayHeader":"User metadata","displayDescription":"Attributes, which refer to user metadata"}]}
3f31cd27-e296-4376-96a2-1bd0d6bf15c5	ad6e7cc9-6f89-4b39-b4eb-11814e00016b	priority	100
5890ab91-2c3b-4c5d-91c6-3207cbd45b53	ad6e7cc9-6f89-4b39-b4eb-11814e00016b	keyUse	ENC
cc7c5655-f023-4083-89aa-58346f155168	ad6e7cc9-6f89-4b39-b4eb-11814e00016b	algorithm	RSA-OAEP
9af3f8cc-70da-4277-b837-de568144abc9	ad6e7cc9-6f89-4b39-b4eb-11814e00016b	privateKey	MIIEogIBAAKCAQEAwGJkztQehIEoso0oJnA4n0hLScLg31p2Lio5xxoVoTHaVqcBPFvjH8stBaVgfT2zoXeLAgoWGO66dwN0Pwa7hEkvJ9SXv5feJ12pzAx7PwShzzXmc4K9sH90AwheAr/qTF1zwuhiJo/MlmRIJ8SP9FLqCfQ3hnPKsPxxQQY7H7NWiQFmsZC0X9Iv2IKh9/k5CpR4KpBFGB2BkolZI2xA1Yu5lyIbH0LSFhjeYgNOgJnnUms7ILY8rw6AH4e5PqAnUs6lEdyvNW/7YhyXdjWYOZREJpdRg0AxEwggTBfYadArmxdpJMIt9Ele4WM3AYe3JIevOZXtAKYPTHwTQ2PI1QIDAQABAoIBAAHk9iPTPY8Fy+Yg3bRYhouK+rLPPcef7Gn9Sx8Fcru+R0LIgjVF8lvtyZO0p9k+h6D0vGRYv770cCxGgcPdHRuVsjvXgWcG585wwwCaCYdP/wfl+qRIiqBM9lImqEZT/XVNtkYaY7JdgsuNppLoV0KLTnf/9Pat9+D7m2HjMycsvdyqKir8jWbEhWy6IjMYlm3Q1IHcV2peSru5m8R7ZTwnkleLzIGIxrM/7UJfnVMcjbCD/NN0juBde45w/M694p83CUIHNwdsMxATmWA8Rb6aykNVzcsZhpPlIWhMqOrulEH+JY51kUHza91T1Rr6TT6XJuqjLOFYhx4qmk0RHEECgYEA6x30xvl7ijqeI11UlMCd5dUM3NwcSVeTxnxwc4mqiuK+gKvfP2Eo99Y9Vr0z82dS6j5JRM8JtQoTbFPGQ8ctGT2hyrw3nnxwHT3cOvt+eQXynYx/VCHQkNgR9heP4rUBY6mhxY/zpVZcHazrbp3tU4q85mhCe4u8EXvCLFpTmmsCgYEA0XjKcT7v/GYHA4XvAZ76dKLIRZxluZ6J0p3lQ3Lyv6XJllwhg/Dl7MBm9t0O8lkPqZz87yKUVQe/Vv/nT33JQgKIssWW5NVWrvUtzTTFrN7KkBKphor2XY0PkMdIAYEsMYBfmllivsInPsrNj7yyoaj5QtGN0PxKEm64qKDVeb8CgYBUZaNpDUMIYnRDk4v5/Y5wYuLEIQrSVOqJ1D91adRbGHtzqr5vfMv88t1/1ljgpZVA2mzokz0TzHMebo/74nJQ3ivGn3uDm32PMZZtYbuLa9QkM7u9EopQhA8mfFy872Z5RPn59etqzS4xxNGaGnyHgYS/XGuI96bhy7/utdnO0wKBgB8ZceTyVSsB8tShE+UHt2ONr3I2UBwI36l3a8xhyoyNjqpWL1upblmCD0djdo6gjmS+PAc8+QzOw6elArCYmkLEoYr5Lvf2fJIpMI2g4iBSS3ysaKLjCsTE5qS2EYi3ptoKlycRUknEBZObBH3spBDAR5GWDxoR+uVVrvDKQCd9AoGAHbp9SetnMzwuUs++6/BvYw3Xf4f9kGDcH7pX+LUtrs4pPB+lZPq2UWgDayKnFR3bWr9WBslr/1PTVXSdBB1BFKEzNFz9IBPk10F+GE9PZA1QpoRtPq561KeZZkj4KRn9ity1/hDQ9ZPUpzf1wl6l5wbE7+8FlRi2O8uOElnFVrU=
f05d9b97-6a5d-4214-a7ff-511fa6205828	88df0a3a-4b06-4577-baee-d0948f2bcd55	user.model.attribute	createTimestamp
ded2c92f-991e-4ca1-ae08-5b34a1129b5b	88df0a3a-4b06-4577-baee-d0948f2bcd55	is.mandatory.in.ldap	false
df4248da-207e-4011-93a0-ef4c178e951c	88df0a3a-4b06-4577-baee-d0948f2bcd55	read.only	true
b3f67e8a-21bd-4d6d-8e24-b5bad38dd61d	ad6e7cc9-6f89-4b39-b4eb-11814e00016b	certificate	MIICmzCCAYMCBgGcCZuEjDANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjYwMTI5MTE1MzMyWhcNMzYwMTI5MTE1NTEyWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDAYmTO1B6EgSiyjSgmcDifSEtJwuDfWnYuKjnHGhWhMdpWpwE8W+Mfyy0FpWB9PbOhd4sCChYY7rp3A3Q/BruESS8n1Je/l94nXanMDHs/BKHPNeZzgr2wf3QDCF4Cv+pMXXPC6GImj8yWZEgnxI/0UuoJ9DeGc8qw/HFBBjsfs1aJAWaxkLRf0i/YgqH3+TkKlHgqkEUYHYGSiVkjbEDVi7mXIhsfQtIWGN5iA06AmedSazsgtjyvDoAfh7k+oCdSzqUR3K81b/tiHJd2NZg5lEQml1GDQDETCCBMF9hp0CubF2kkwi30SV7hYzcBh7ckh685le0Apg9MfBNDY8jVAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAL3mR6K7pkIw6cRsyUy25VVtmrNihh39UOHJTNZA1DdKGvKQY3xts0T6OnpQkVHs6I4pXaFeZBG5wL3tCX36/nspymyn6QiraAtcX6Bsx8aj42PIA6ITNjUN62O03y3+QsumhOyswvh9a/5CY03IZaSeElTvbprNB1eTuqOHbMAV2gAd/+t9B0TUTfV1ZWXBC25vNY/ewiNMjXALCP8BBY1HEV42Zrr70myJpH5/kKmN7ESxeIASU7iyMUeGxhn73R5taoOFVIW+PIBuK/HkrEUrFwUQZEJxmR2ZCx+3kmM9nPxxftYwy5fro0urSVToPkMmwTAdhLFFkP3rbGkLAu0=
3f2e28e8-5f7d-4a1e-a859-57bb202cecf5	882edb05-44bb-4b01-a404-7c4be71f12c3	keyUse	SIG
e920a907-609b-4754-82a8-a854e1bc5e6b	882edb05-44bb-4b01-a404-7c4be71f12c3	priority	100
0f25f420-7e49-4dfb-9627-6e464362533a	882edb05-44bb-4b01-a404-7c4be71f12c3	privateKey	MIIEowIBAAKCAQEAm6xLgN63homi0uZ4S9pD7MsxpajCPcSoDtMQcMU72UtStqK3zwiMdyJWwMRQKWExolsiReUCWp5fBcOhnJ/fzMmJpsJAY1bUKQrmg8QcH6mTz+YbOeyGrTqBkgKqS2AJNxGDb+n/Ge9/vveTTDeO/h/yZST/HgBlk/t3FNt2TPVj03PSH7HGuXdYuOoL/WkG3kTl+FML42GkFmRKkhUB4lUftacNtfruuVuRLm5CEQx6EImos8O+6VWqk/UaMq2Tfg0NrM5IgdVDc8WlGmEDwAQYqCHS5LPPXHn6pw2c0vs0xaf98zZnj/t7gi3dnXNcdE4OPrVvHtzc6lvGsVkWSQIDAQABAoIBAA7t1gvU0Arh9jB9k7nKg8sYrXkylvYvfuJ1EVWPRK8RDyyerDv5mObv7xvrd7iQLp9gWAgV70TbfUdjPIN1vZO5HC9W36/nKs+I0RR/4SaUL623ZpMGgN/qBXUINmamHhwe3NkFusY09q5Mtd6QUXFDhQ54HtM0vIkVi5T/evfkRi9bOxpqhUyZnzhRRzlrXf2NO5mmE81QIEV8rMOqYsUDeAmuU8m7KJ/7yGae4D9EG8OKL+FLp9+GZAFMK7ov3Tp/IopyEUn18pTfhHI/DeeRhRCW0aI7jOU/oLaeCdaT5RuElov20xLR+72ty/SEmAbRDWOjzP6+Wz/G41IRBQUCgYEA2gCS77YardmiGWI6VFv6eusRF3bfjvDtewpFYzz8yu1DfhO1Wnliz33Eu5MY8LK4M/5Zp37rp5ILrS8u7eREB4UhQoLi/v7HruLG7JrU1n/RwUd9Zg3g76EiJam/LlA9I4Jyl32VuHnn1jwFt2ANzRvDut8Nyff3zoH1vz03nw8CgYEAts6LP0uq54sISrSNmkZ0EcxgMsBvjzhFasN/d/+NLdEsonDtxVG8eyisSNIlqrp9smQ5O9c4ak3zX0j84AA5QzXhxaQr5hWOWj7gHjclhragsvA6GxaPyIXXPjCjgIekIk/4VymbWLVWDnUjuXkL7XXnolMaCQEfOMN4MQrydScCgYEAhhm4SVCh1LN9bVPpQZ9a02XqG576Ijm+O+Ozjzoi3slYrSN+eWsWB0D8Vc5Elzu45/LcP5Zpa6kBGcVefuPdnSqdrQZKkEU1nDTP3RfZOSFjbBuH3dFHvuBF2xkyC1E8aq2BxAJyqQoEPNqrQYQKuVMM8dTn7Idmnld/TeZgYq0CgYATAQPOz7Hzoit5gK2b1Skp1IJHpGO0ktf8klhFBEcL9UvbkzvUoHukngTTCS2rQvngOrUMeII/4tyjEjZfnwZU61wOLNP3dlQ3I4Qu//Khv4iTMZAI0t6drPREXdARg4hXnNKnVQb2QNuyYxEUrfXEeNZctKDnQLubLg7noki0TwKBgFKp39TVzo6ZurhQgyErJdozB6QdoauzDPlhv/SGFYSjvrvHpmBpu+y4ZjE3OF2FeR3EqiuGmDc+8Gyj1k2WDszZgvFISu6+Fd0IeoOPFu35BpxB3dpQVnfoou2ItjV+pw5we2bk67aJJAGH5zTf3gxiBg5eLevAqtN7r1FhJYRu
9cb3da9a-2436-4677-ad80-0655cbe72730	882edb05-44bb-4b01-a404-7c4be71f12c3	certificate	MIICmzCCAYMCBgGcCZuDZTANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjYwMTI5MTE1MzMyWhcNMzYwMTI5MTE1NTEyWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCbrEuA3reGiaLS5nhL2kPsyzGlqMI9xKgO0xBwxTvZS1K2orfPCIx3IlbAxFApYTGiWyJF5QJanl8Fw6Gcn9/MyYmmwkBjVtQpCuaDxBwfqZPP5hs57IatOoGSAqpLYAk3EYNv6f8Z73++95NMN47+H/JlJP8eAGWT+3cU23ZM9WPTc9Ifsca5d1i46gv9aQbeROX4UwvjYaQWZEqSFQHiVR+1pw21+u65W5EubkIRDHoQiaizw77pVaqT9RoyrZN+DQ2szkiB1UNzxaUaYQPABBioIdLks89cefqnDZzS+zTFp/3zNmeP+3uCLd2dc1x0Tg4+tW8e3NzqW8axWRZJAgMBAAEwDQYJKoZIhvcNAQELBQADggEBABVPzhsK2hP4oW49ZUvnooRLKPGbsIc975VfqO5jwgtnOYy73w4Odpycibogjvh7l6f6qLl0Rq4Pa9/7TS03hkUC0gypagOgdodQ0l5xHuGCqP8YQk3Fj9t5VVDEz2+/bnWrz1W3KcJ/VD0pvYgVgwW+zuP1SEZUMnMiY0lh72bxzLlmEmAXgtbuzwmbAnh54NccdW459jl9eiV/zGau32b0Kf01FVsI2mjINs3xsUHHke7DBWBhr6mI+IbJEddxDaWLn2KzAv1In7uKJybBO59VXe4SRrBrs9ol/KywScwUEPy4bB6Z+Gx8bY004lKjJucfvfHWWS+feg7zFTnwMkQ=
e598bc5f-0c31-45a3-9d7c-fb25c973ddfa	ea86a57d-52de-4815-80e9-ff97c5f452cc	priority	100
bade6cfb-e8f6-4210-b627-54dfe4d92688	ea86a57d-52de-4815-80e9-ff97c5f452cc	algorithm	RSA-OAEP
f35669eb-77b3-48c4-a891-ab203fee33e8	ea86a57d-52de-4815-80e9-ff97c5f452cc	privateKey	MIIEogIBAAKCAQEAoOffJWBoQoMf5YepOXnQYw2+ingn2ZaQd1TxX/JgyEF1t8mvLCyoPahVxmXegBiLsEYqWg2xO01he3Nr6lnK+xP3ZgwATPDNDF5/nmm1D+z3cewqisjmpF5xoP1QkXqlyfdBOXH6zrzD2gnW5CVu9+GBA4f20oGjC8n7bs8yUZfFNPFFjMFj2NfP/o4O3X1c8nNbaDCDFKryA6zHWM0R3PO1uWxoKvt7lDNlVThmYx0a5YTo4tIuDYvO5hl3o7aA1XXh0BRJUfi7ZqJYX+yMEUSsOMgyOLnctUkhjeTyX+CNetGL4kgp/DfAa9sc65oI8qxL3e5HZSef+D/N4Wf5kQIDAQABAoIBAAkWa22PmzfVcsfagHna6cRsZmxo4pxJAwYAVcUU2fc5bjn38bUpnQNldlm3D2jV6g7FubbeEtpN8aFgqJHC6kJBs41vhFVUHMqT7DqAzx10BVopa9IsjE0wedOtNt+OiR5F4QjK6Y7DTb7q4xh9zj2A/pG53Dxxnqkn6lPM7zM5K5XCq2pV11+dyr+RSZ4/XazkfabPx42KhgVcGhPA4WjlpE05y95MPzzR9XsrQ4oMiiNbLFM3vkXUAGZVg28kgllsf3OqZpHzytXxP/ConWDRiHEr9alWVxvOGq6dtm64jd+QC1RS1T6/vyqAHPPH4T0++myGux9NulzEcMs0g4ECgYEA0aOirjvA1Y0Zfj2ZL/W2ueM9YsQEJmvuU9rl0GkxyoBIHk/2cXUpOrHVhZt6DSYy3iZrbzaaKjY4gBJVitLl+h0bjqvGMVAuHoWbjDgmykmerAa1cA4QzqnvfiNaVWB53EE1dCN3kmK34Xbp2w8RXcGwHyTVV5DFdP6hg5/mtVECgYEAxH1Gc8QbZxvqAWU+RmFSvdenBBNZhsQjNXrSkjWYI0heAse3F4fLLdVtnRy+JxKiI4JPKNhvfBpTa/2xbC2Xt7fsJ+ut019WACNosHHGDGCXo9S1mR+eujDbS3oTcPQpug+tKpNcOn/4V6FHTMeC2VT8paezYstTI6cYDopY8EECgYBHUFkI2D7S5nrjnOS9keKk/Y5mSLP4tgKO+AnxibdsYZMm7KCzG934n4I5PxiX3IS1WXB2lqZ+8Y7q0lHTNccR/FDhicGUCOiHbX/qhTd83OpjLq0N/1rsUpar3C7gmD8cE/qxFVeZrodK5X7MDCYmNLtK/OauMQtarzwWYJDE4QKBgCECcs2MCpZ96Agn/BhSzVW7XwGeRpIPbWLUqX+KpW53/+Mzrhyz4XxnuKyGYaOqy7Zvc+EGy2PsAEvKKP5lgnGI4pGqVF+ISqhnSnUqB/2YVKFfYMrCtyXMg2rgrVdyjXgGni7i5sGlMhF2tMW/VsowLumdjNNyGRuKPM5ki6CBAoGAVqKoLkkVlpiDOZg2rzo3h/j8MkKPIde3+QeBK2cOMq+BqJwVzaFNrmhOtaaE2o15ozpIRlgREmW8jLT1DqygE4D5d1tXWzQeHruGBVnZwUnhSHZGNNDx3M3CtvmXtzsJnzk/1jgdeWCwPdbZQ6cWN9SZjOMngw2Y+UuW3W60YdE=
d89dde45-c430-4de9-8239-78f9442867f8	ea86a57d-52de-4815-80e9-ff97c5f452cc	keyUse	ENC
cbf89867-413e-4b9b-97a4-12b51393e507	ea86a57d-52de-4815-80e9-ff97c5f452cc	certificate	MIICmzCCAYMCBgGcCZuHWTANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZidXQtdGMwHhcNMjYwMTI5MTE1MzMzWhcNMzYwMTI5MTE1NTEzWjARMQ8wDQYDVQQDDAZidXQtdGMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCg598lYGhCgx/lh6k5edBjDb6KeCfZlpB3VPFf8mDIQXW3ya8sLKg9qFXGZd6AGIuwRipaDbE7TWF7c2vqWcr7E/dmDABM8M0MXn+eabUP7Pdx7CqKyOakXnGg/VCReqXJ90E5cfrOvMPaCdbkJW734YEDh/bSgaMLyftuzzJRl8U08UWMwWPY18/+jg7dfVzyc1toMIMUqvIDrMdYzRHc87W5bGgq+3uUM2VVOGZjHRrlhOji0i4Ni87mGXejtoDVdeHQFElR+Ltmolhf7IwRRKw4yDI4udy1SSGN5PJf4I160YviSCn8N8Br2xzrmgjyrEvd7kdlJ5/4P83hZ/mRAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAHaId8UGMUTCdLfzyMmDXROlgqybsWEnkJx6bMODi1p4Kte07V4JCeQjEbK8oHKTOslxZGzSvY3iRsqMCgZlPKphlrnQ41ejHJvWUds2Rc7c1M7yuGPZ5Fc6hMAB+pmMtrxeirLSU08J/+deMv5x6/TAdJwFr41FfR//ATbI9fouP7PjmxLUbPBrWbrQxQEhZhDVtVvGgSpl4EJGPZZU1thst//shZIptDMbs5AoettrJkbR665W5IC0Ycw74uw0aAX/YR/gku5j68TZ+CA42QfwVxBaO8A22w0Ji9kxE2MS0VCwotTXvqtlm/Po1lMEQyrgn0Gidt5boLcL8GNz4cw=
fc4765c2-5bb8-4a0f-867f-0c39e2518822	77c751f1-8d04-4069-a723-51c8fc3da4f0	keyUse	SIG
5f12dd7c-eb82-4e10-b9ab-aa3422597952	77c751f1-8d04-4069-a723-51c8fc3da4f0	privateKey	MIIEowIBAAKCAQEA3FV9mU/UCk3zzj8othdzyjRbqufaJA8uwbsUYs8Alzg08TDqxwWqxvzPlDd7zxZPsarL6jp8wObIiWaoG549GuRN0thiSreIila8hPQ4wf8TdLCb+y6M4UTvjrLz6VJ+Po45dVYFF+sJ6+4ljdC1R4h7/iwkFQd6IG+yh1bVK3bTK40PTUxmKaxVHZ27aEBUHBQQz6Nmn/YZxOq/xFwekAHxHfY36OkglMXTpV8MZ52qUHYK7xwwanUrKX4U7uAh+JXCthfTL9Mp7tHNns/Nl9LcxCtbVQj7NQmK6VwVUAAuAXVaKNwhN5qeZT1cBjeVEUId/55XGBf0NJTKB0fUcQIDAQABAoIBAATbcp0gXCONA+CqVkarXi9ZN6MdINs2JXj6W5DxEMmEoPAnPKm+B32DAb15+qX+TyvywLONbgYfoFCdHXwcYSr4WPnasNIGWUF5d4bzzlOCgMaMBShEprDpoOFTsxpT6foNjxk11/9mvE2B7ryBWxm0Wc1o4jO/ejMAW15t7N2cIsCgIWpLC2xgckym5Bl31GN3t4Thc8iTgpOueSmyH2KBbIJfNcxyPJtgf33tx1iDMDcrDqAGzfdcsqEqxuAb4uMreUkTHYQxnDf7pYrtshd4jggx/eAxm3OjSW7w2e+524zTd8iKUiFMVqrhemWIgWZy3TD/8lUqOf3gpe5bvrUCgYEA+KRHvB8GoZiw54g2UX3zPmo090bvxfSUjiV7uokeGeII8WGr1TTMU+2nO8Bgd7huYOjPKhO13iJ+gI8vFth4e5qkIF2gNH7+IWS1HyEprsLshNsqFLbXOuH68oJIzfZ2I6btgB3eYLYGH6/R58KwUi11dwhR0/R7Bpq4F+SO+70CgYEA4tq/5CNtMwQXnWiKUhA7qBemfSTFDVQEW+Ep2qF5++LED1IGOXp5X51PnEsChNzOUlWS+xEaCn0A/UmRvhjAKJgWf5AUSXNHhAbV7sEeCExvW4rpQOo2mSpkp4MngCBi9vZ1I3GcqgadDPS9lBFmZ1sA8Zao52kmn7TFS8LUTMUCgYAPbgpxly9PKe2YgLB2QC2vKuIckk9g5nutko/qFIZEru1FJX2HXp5reu0M3TRfWZen9eqdPtnjbhqRmdEfRtG7Qe57f7PobhURN3Gx+9ndWYVZ/UvQO0SCB/INyJ4CAhB0x/AnKjNZpxIcN0n8au2MO/v1JhQF5j8YOtO/z9Q7tQKBgQDQfOhUvHZUp5MoeHZ/OyoIr0u0wcFUIX4sDwDPTQ51/4/e4KyV0MiRplsPMiTrhJ8eLkV59tqu/vmUzzNhuQ+Jf1VWAU2Tv53fagTde6ClUdIaGM2MenSZScvd4/y+lYU+oX1AiN7JqHBYAunkliU+IfX5ElTC8PGtX47ftPw2XQKBgCHG+1NxAlwwfOTCkXtSRiAxbLm9+vU9dFE8jr9s0c+ix7rkV5i6t9qyGwclmdZscZ6YtNuoD94KZcOWb3xHuKPu0Zyh6duaX+oaTebS7KXV3vHsWM6+jN8kNIw75jw79drUwKewHcQwOEychxPotBeV5caLH2x65uGIeRLPlEBu
8f0b74b7-8294-4e9b-8d3a-52f047f9abe1	77c751f1-8d04-4069-a723-51c8fc3da4f0	certificate	MIICmzCCAYMCBgGcCZuGpDANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZidXQtdGMwHhcNMjYwMTI5MTE1MzMzWhcNMzYwMTI5MTE1NTEzWjARMQ8wDQYDVQQDDAZidXQtdGMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDcVX2ZT9QKTfPOPyi2F3PKNFuq59okDy7BuxRizwCXODTxMOrHBarG/M+UN3vPFk+xqsvqOnzA5siJZqgbnj0a5E3S2GJKt4iKVryE9DjB/xN0sJv7LozhRO+OsvPpUn4+jjl1VgUX6wnr7iWN0LVHiHv+LCQVB3ogb7KHVtUrdtMrjQ9NTGYprFUdnbtoQFQcFBDPo2af9hnE6r/EXB6QAfEd9jfo6SCUxdOlXwxnnapQdgrvHDBqdSspfhTu4CH4lcK2F9Mv0ynu0c2ez82X0tzEK1tVCPs1CYrpXBVQAC4BdVoo3CE3mp5lPVwGN5URQh3/nlcYF/Q0lMoHR9RxAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAAZbuYWx2fSRw0TIj6zFGi+UCkteEve5SuL0BA6SAkC9coaHDcLIbl38G/rD4H1bENcOspOdQG2dvrKpOAj7Ta20shj5u+ie55M1w/RYXdrrNH1HfG7lvSGVdJR1zj5l9QaVNQqSIJe7TZOoVN1GUdtR+QncCUgk8K4vep6e6kZoqR4wFTYWYZvxR/KV3uHKnJdOuCYiFH5n0k9AwQFtxXlZRv/Atkb70J6f1xnx1tT9r3WwVVUPRtAaJpDiqv4sieCsUBkKZ5+XkYpUos3dox49yTnAyu7x9vgm5SWLsedzoY5hqm/feknVBvChTRkrFtcjOx5CxT67n4xSkEJ/idA=
a3756894-0985-4811-9f20-42f7d260df52	77c751f1-8d04-4069-a723-51c8fc3da4f0	priority	100
901fc957-56f7-4d93-847a-1f066d935c29	194498d5-2709-4684-b611-257533c1d8bb	kid	14a30d9f-6329-4559-8d5e-df1325ade3c9
e9d87e41-2965-4bd5-a899-39e94dabe14a	194498d5-2709-4684-b611-257533c1d8bb	secret	P4-exQjmKiv3gbey8FKIznmyg3XEqx92CLbTd7wW0eUHVCB-0QVH8bEdSgQAnRh-SMufeOv2yxS-wgbo14CscQNFPhAlj4irNauxcaqe4FTyYkb8XxgfKFVBy5MGOe0BBXQWa_K43pKavQdr9qdudmK20yAMZkwVtLQBXAv0xDU
6288a14b-3b42-4670-8801-25bf57d260b5	194498d5-2709-4684-b611-257533c1d8bb	algorithm	HS512
a1bbb73d-d5be-4ecf-8f15-6b8795dd1c69	194498d5-2709-4684-b611-257533c1d8bb	priority	100
bfa81c29-8e53-455c-af9a-a6935fb28190	4c82c427-3372-486c-9974-f95d69fda827	kid	cc5bb866-a070-4424-a484-7fc2bcb59b4d
708ece08-6aec-44d2-b115-e5ed2bff524f	4c82c427-3372-486c-9974-f95d69fda827	priority	100
e659b9ef-746f-4fdc-84cc-5f3a7f5fa44e	4c82c427-3372-486c-9974-f95d69fda827	secret	GP8zHa-DExKBazYDFSYftw
db332d31-5113-4cf6-bbcd-7547efe23b06	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	oidc-address-mapper
5fb4ce55-dc1b-4c06-8223-9ea74bc55886	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
9b11ba77-4f93-4cdb-bdf2-767f2106495c	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	saml-role-list-mapper
c3c40709-da0b-4bac-bf8b-c803a66719e5	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	saml-user-property-mapper
49307a53-dd94-4b16-8ce0-10c9730526e1	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
dbbb713d-a185-40f7-bfde-a334d29b8f28	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
49cdd64a-4757-47aa-aee4-8a1089b87327	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	oidc-full-name-mapper
3ebf43ce-3c3e-406a-831d-79109b4049ae	679e2566-79ae-4946-acb6-3835bc644297	allowed-protocol-mapper-types	saml-user-attribute-mapper
844266d3-317e-4c76-bf23-e05c1dc203f2	a6b522a7-04b0-40e5-86d9-1bbef99546ae	client-uris-must-match	true
c31b5166-e3a2-4a2f-895e-1c56483e2a30	a6b522a7-04b0-40e5-86d9-1bbef99546ae	host-sending-registration-request-must-match	true
6638d226-f39b-4b59-a89c-73e722ea8f3c	0fb7a715-1ddb-48c6-b638-9ba8250215d6	max-clients	200
d8676481-0b49-44f3-8c88-be164f255296	91f776ef-91a3-4d1a-8131-b9af905110e9	allow-default-scopes	true
14ed64c9-cd71-42f4-86b3-a714482df66a	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
c2bfe80e-5127-4244-9f20-a0461a58df36	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
b980dc5b-42ed-418d-978a-ce7400a56b61	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	oidc-address-mapper
be13d47d-cbcb-4ce6-af51-c35090d80d79	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
ef96edff-ff19-4bbf-92f3-808535e8b0c6	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	saml-role-list-mapper
b5f6b08c-fbc0-46f2-96f1-d6cde43f28c6	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	saml-user-attribute-mapper
30569679-28c7-49ed-ae2a-526ae394d64d	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	oidc-full-name-mapper
7d576c0c-6a2d-4dad-abb0-01d1c5181ea1	7c00c152-8355-40f3-986d-3c005ba226e7	allowed-protocol-mapper-types	saml-user-property-mapper
c1a32403-7eac-4a81-a300-5738c773d5cb	b1315da6-aea4-4798-9315-7807398bb424	allow-default-scopes	true
373c1ae6-3169-4b8f-9f7f-cf42687fdad3	b4de1b8b-e22f-4f37-bf65-58b36b5238fc	ldap.attribute	mail
71a4efc0-9de3-4cf1-8d31-fcbe4bf78701	b4de1b8b-e22f-4f37-bf65-58b36b5238fc	read.only	true
f29732a6-aab5-4d97-a8ad-03cf112cb266	b4de1b8b-e22f-4f37-bf65-58b36b5238fc	always.read.value.from.ldap	false
d0a40044-8e6d-4dfb-a75f-560aae4cb95d	b4de1b8b-e22f-4f37-bf65-58b36b5238fc	user.model.attribute	email
28f09a46-505e-4b74-84fc-c035254b81f0	b4de1b8b-e22f-4f37-bf65-58b36b5238fc	is.mandatory.in.ldap	false
46422748-1f03-414a-990e-d192c6348c8d	88df0a3a-4b06-4577-baee-d0948f2bcd55	always.read.value.from.ldap	true
5221c05a-a820-4906-977d-020969bcb9a9	88df0a3a-4b06-4577-baee-d0948f2bcd55	ldap.attribute	createTimestamp
76661ee5-86ab-425b-b4ff-3f283b6dfbe2	2b0c0b8c-e082-4dbf-bb66-1fb0baaf20c1	ldap.attribute	cn
e47ed938-1922-4608-99d4-9b2813950381	2b0c0b8c-e082-4dbf-bb66-1fb0baaf20c1	always.read.value.from.ldap	true
2f909646-c7a1-4901-98aa-bfd19fa93795	2b0c0b8c-e082-4dbf-bb66-1fb0baaf20c1	is.mandatory.in.ldap	true
b67f671e-b530-497b-8130-535a1d81bcc5	2b0c0b8c-e082-4dbf-bb66-1fb0baaf20c1	user.model.attribute	firstName
fc024712-9c28-4b93-85fe-cdf7a7ff6289	2b0c0b8c-e082-4dbf-bb66-1fb0baaf20c1	read.only	true
062eddb6-2819-4697-aa00-1e2cc727ab4f	2aa73ae8-0e6d-4e1d-8730-be4f21d7122b	user.model.attribute	modifyTimestamp
ea7c363d-9982-4f7a-ba90-6fc6d0667818	2aa73ae8-0e6d-4e1d-8730-be4f21d7122b	always.read.value.from.ldap	true
ea197284-ca95-4697-81cc-9024049e65b7	2aa73ae8-0e6d-4e1d-8730-be4f21d7122b	is.mandatory.in.ldap	false
640f580b-4b9a-4e7b-95f8-5e006472ce61	2aa73ae8-0e6d-4e1d-8730-be4f21d7122b	read.only	true
a4b7ccf8-b7a9-4b32-b0b0-3ed5012d5da7	2aa73ae8-0e6d-4e1d-8730-be4f21d7122b	ldap.attribute	modifyTimestamp
b72d9d07-8171-4047-8dd2-7f3c7008c3be	9e3e9ff4-86f8-41d2-989d-7ab9f3035a40	user.model.attribute	lastName
a71b9f15-7798-4b13-a0b3-43303a739ba2	9e3e9ff4-86f8-41d2-989d-7ab9f3035a40	always.read.value.from.ldap	true
a49a8ff5-f12a-4d3a-b5c7-a8ac0a4ef1ea	9e3e9ff4-86f8-41d2-989d-7ab9f3035a40	ldap.attribute	sn
0ba92249-c1ac-4e79-84ec-25fa7d0b6831	9e3e9ff4-86f8-41d2-989d-7ab9f3035a40	is.mandatory.in.ldap	true
30b401bb-4097-431e-a067-331d19a79335	9e3e9ff4-86f8-41d2-989d-7ab9f3035a40	read.only	true
3751c97a-9018-4f05-b8c6-0e9c24abf78d	863f697e-7581-4736-bc48-2b64259648f1	always.read.value.from.ldap	false
ea54194c-20d9-427f-917b-7d677d6a9e46	863f697e-7581-4736-bc48-2b64259648f1	read.only	true
70720f48-ce3f-44b3-913a-cdcf0a8f5851	863f697e-7581-4736-bc48-2b64259648f1	ldap.attribute	uid
6b19081e-dab1-4ea9-997a-e1b1a67fa288	863f697e-7581-4736-bc48-2b64259648f1	user.model.attribute	username
e074304e-087f-4ddd-bb77-951023fd9699	863f697e-7581-4736-bc48-2b64259648f1	is.mandatory.in.ldap	true
52aac3a0-be28-4d9c-8019-e7281ec22788	le4Fc2PlTUmQr1g7oJmuaw	rdnLDAPAttribute	uid
a4e3701d-5c7d-4a98-aa72-99e86dfdbeb3	le4Fc2PlTUmQr1g7oJmuaw	priority	0
ff9c62f0-1abc-495a-bd92-48067d3fe9ec	le4Fc2PlTUmQr1g7oJmuaw	changedSyncPeriod	-1
3ccb99cd-184a-42b5-b410-498453060c44	le4Fc2PlTUmQr1g7oJmuaw	usernameLDAPAttribute	uid
0f334e5c-3da8-47e5-9890-3240e9ccbebf	le4Fc2PlTUmQr1g7oJmuaw	fullSyncPeriod	-1
48eb7dc9-9eba-47a1-b03d-8c46fc7923d1	le4Fc2PlTUmQr1g7oJmuaw	vendor	other
485eb85d-0014-47d1-a19f-0b5457cda0e4	le4Fc2PlTUmQr1g7oJmuaw	usersDn	ou=People,dc=univ-lehavre,dc=fr
869ec674-8d08-4e07-a27f-a61bf448abe5	le4Fc2PlTUmQr1g7oJmuaw	bindDn	cn=admin,dc=univ-lehavre,dc=fr
ed0f6b70-36e4-4b9f-8379-13e46fc953b3	le4Fc2PlTUmQr1g7oJmuaw	editMode	READ_ONLY
909b8db3-fac7-44f5-aa66-7320aa2ac6ac	le4Fc2PlTUmQr1g7oJmuaw	uuidLDAPAttribute	entryUUID
2fa950e1-e682-488b-94db-c7dc31756cb9	le4Fc2PlTUmQr1g7oJmuaw	connectionUrl	ldap://ldap.univ-lehavre.fr:389
0dba9fdf-0829-4358-a661-d52e5f6e37da	le4Fc2PlTUmQr1g7oJmuaw	host	ldap://but-tc-ldap:389
59c3862b-309c-4eb2-81ab-d4877149c549	le4Fc2PlTUmQr1g7oJmuaw	krbPrincipalAttribute	krb5PrincipalName
301fcdb7-33cd-4b4d-bbd8-8c5f879c3cb8	le4Fc2PlTUmQr1g7oJmuaw	batchSizeForSync	1000
d57bd21c-5ae1-4e36-bf15-5a3ff451acb0	le4Fc2PlTUmQr1g7oJmuaw	cachePolicy	DEFAULT
de4ce396-12bb-4d9c-b37c-71112f916cba	le4Fc2PlTUmQr1g7oJmuaw	bindCredential	Rangetachambre76*
7f212814-68c1-4128-abd6-9568a7fbc66a	le4Fc2PlTUmQr1g7oJmuaw	userObjectClasses	inetOrgPerson
53a30e0c-d455-441a-ab4e-bae411c45056	le4Fc2PlTUmQr1g7oJmuaw	useTruststoreSpi	ldapsOnly
\.


--
-- Data for Name: composite_role; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.composite_role (composite, child_role) FROM stdin;
50adf0ac-66ec-458d-8302-2067390ee0d7	90a341ca-8b74-49d6-9365-768916efcbe6
50adf0ac-66ec-458d-8302-2067390ee0d7	8fea0272-4e7d-4b50-8348-f85dc0c55a67
50adf0ac-66ec-458d-8302-2067390ee0d7	6bbf6fec-a1b7-4ad2-9447-3eb4588f1d70
50adf0ac-66ec-458d-8302-2067390ee0d7	2acb70af-9221-4d6d-a961-ad99f19ae873
50adf0ac-66ec-458d-8302-2067390ee0d7	af8d1575-5d3a-484e-8af3-2a01d995a11b
50adf0ac-66ec-458d-8302-2067390ee0d7	d6a7e316-2e19-41b0-b6ba-bfc548260cbf
50adf0ac-66ec-458d-8302-2067390ee0d7	47001be9-1133-40cb-806c-f59c94830a9b
50adf0ac-66ec-458d-8302-2067390ee0d7	92e49679-2198-4795-8393-868d2e6b23b5
50adf0ac-66ec-458d-8302-2067390ee0d7	433443cf-c8e2-41f9-97e0-419a227e368c
50adf0ac-66ec-458d-8302-2067390ee0d7	271f74d2-2157-4ef0-9427-ac14b3461390
50adf0ac-66ec-458d-8302-2067390ee0d7	51204ba8-648d-4f8c-9502-ed900f9aa5de
50adf0ac-66ec-458d-8302-2067390ee0d7	9ca39b1f-34ac-46ad-8b66-c80de4876f5c
50adf0ac-66ec-458d-8302-2067390ee0d7	62427c07-87c8-4297-9b16-7df53c5c2083
50adf0ac-66ec-458d-8302-2067390ee0d7	b769583d-c960-4516-bd96-8c0d3d845739
50adf0ac-66ec-458d-8302-2067390ee0d7	61010341-71bf-4f00-87e1-1f2bd478b755
50adf0ac-66ec-458d-8302-2067390ee0d7	91164117-4e1e-4425-9383-69849de47d98
50adf0ac-66ec-458d-8302-2067390ee0d7	6ecae27d-2ec2-4dee-be6d-f8d462d75442
50adf0ac-66ec-458d-8302-2067390ee0d7	173781a1-7bde-46ec-881e-6117b6da9c1d
2acb70af-9221-4d6d-a961-ad99f19ae873	61010341-71bf-4f00-87e1-1f2bd478b755
2acb70af-9221-4d6d-a961-ad99f19ae873	173781a1-7bde-46ec-881e-6117b6da9c1d
66d3306f-d865-460b-81d2-7e04f93c580e	0f467850-2052-49ba-b196-43167e6012d5
af8d1575-5d3a-484e-8af3-2a01d995a11b	91164117-4e1e-4425-9383-69849de47d98
66d3306f-d865-460b-81d2-7e04f93c580e	b0573419-cb74-4f85-96e3-7181ec281c08
b0573419-cb74-4f85-96e3-7181ec281c08	e81013a9-8d38-431b-9d2b-6978e4c47a2e
cbb42cb5-5cb4-4f27-bbdf-9faa04c559c1	03a0f2dd-398d-46b0-8459-7a90bc1d2f75
50adf0ac-66ec-458d-8302-2067390ee0d7	c8bad959-766c-47d8-a4bd-df32dc6ef822
66d3306f-d865-460b-81d2-7e04f93c580e	6a33a8cd-5e8b-4ed1-9ff1-9c6f5244fe36
66d3306f-d865-460b-81d2-7e04f93c580e	8841a166-8222-4a93-b3c1-2a63f5006cfa
50adf0ac-66ec-458d-8302-2067390ee0d7	18cefe71-802a-494f-b842-cfe97ab674b5
50adf0ac-66ec-458d-8302-2067390ee0d7	404f677e-f368-46ba-b8af-0475f242c530
50adf0ac-66ec-458d-8302-2067390ee0d7	806b08a3-0866-4917-aaf9-75539fd6a1d2
50adf0ac-66ec-458d-8302-2067390ee0d7	d0bb3701-f407-4851-b1c0-d88fffd319e6
50adf0ac-66ec-458d-8302-2067390ee0d7	d1cfc9e0-ad97-4b96-aca7-9702ff3a3042
50adf0ac-66ec-458d-8302-2067390ee0d7	2735876f-e6e3-4db3-9235-12dd046d1b71
50adf0ac-66ec-458d-8302-2067390ee0d7	9bb994de-07b6-4c0a-b0e0-612ba6af55cd
50adf0ac-66ec-458d-8302-2067390ee0d7	87837d4c-6b87-4c82-b27c-557d7dacd54e
50adf0ac-66ec-458d-8302-2067390ee0d7	ab1ed7ef-8753-4d93-a773-a698e97293eb
50adf0ac-66ec-458d-8302-2067390ee0d7	027ef80a-61c1-4adb-ac64-8468484bf3a3
50adf0ac-66ec-458d-8302-2067390ee0d7	91ce7ddb-0a01-470f-ab07-b89bc5a8a6a0
50adf0ac-66ec-458d-8302-2067390ee0d7	4187fbf9-834e-47ff-a5f1-e5dab92d5315
50adf0ac-66ec-458d-8302-2067390ee0d7	83bb0a8f-9e5e-40c3-9a19-4e521bfea1d9
50adf0ac-66ec-458d-8302-2067390ee0d7	8883695c-5725-4590-bab0-f0aff3316450
50adf0ac-66ec-458d-8302-2067390ee0d7	5ca94246-01b3-406f-ba26-9dcb4f8c27e8
50adf0ac-66ec-458d-8302-2067390ee0d7	652d85e9-7caa-4138-b326-277148e53d3b
50adf0ac-66ec-458d-8302-2067390ee0d7	c89fa27d-237a-4728-b216-12b33d749ce2
806b08a3-0866-4917-aaf9-75539fd6a1d2	c89fa27d-237a-4728-b216-12b33d749ce2
806b08a3-0866-4917-aaf9-75539fd6a1d2	8883695c-5725-4590-bab0-f0aff3316450
d0bb3701-f407-4851-b1c0-d88fffd319e6	5ca94246-01b3-406f-ba26-9dcb4f8c27e8
30488891-dc4d-4f8d-9243-981997be31dc	f26c17fa-66ef-41c4-adb5-98780c5db864
30488891-dc4d-4f8d-9243-981997be31dc	6e78ec13-3a61-4a9c-940a-6a0d24deb7a8
30488891-dc4d-4f8d-9243-981997be31dc	eb9157bc-5ca3-4963-b017-fea29556b13d
30488891-dc4d-4f8d-9243-981997be31dc	a3c6f0f1-df1b-4730-a7dd-fa18996d6d53
30488891-dc4d-4f8d-9243-981997be31dc	5b84bc38-25a7-4b43-aaf4-585b4c6a300b
30488891-dc4d-4f8d-9243-981997be31dc	bfc93764-d6bd-45de-bc90-f665e43f1f30
30488891-dc4d-4f8d-9243-981997be31dc	a97bf783-8c8e-4d91-bd15-faf2f0eede07
30488891-dc4d-4f8d-9243-981997be31dc	54469293-7e8a-42ee-ab58-3e2d39b49f1a
30488891-dc4d-4f8d-9243-981997be31dc	fec76abd-2d50-4edb-9853-688bee32d429
30488891-dc4d-4f8d-9243-981997be31dc	68aa922c-329b-4168-a86a-71ce668a093a
30488891-dc4d-4f8d-9243-981997be31dc	2cf9896b-1b26-4a59-b4c6-230e8c1a31e5
30488891-dc4d-4f8d-9243-981997be31dc	22f441d6-52f0-404d-80fb-00f1a822b7a6
30488891-dc4d-4f8d-9243-981997be31dc	019e901d-967a-4b26-b53a-da37aa323901
30488891-dc4d-4f8d-9243-981997be31dc	240da721-16f6-48c4-a7a3-5b2889100645
30488891-dc4d-4f8d-9243-981997be31dc	477824a6-e268-488b-9a61-303ccabd5020
30488891-dc4d-4f8d-9243-981997be31dc	4707a3a7-77c6-4c51-a2bd-268ac5c8802e
30488891-dc4d-4f8d-9243-981997be31dc	f6e2a4b0-bc44-4bd7-beba-385cc6e03287
a3c6f0f1-df1b-4730-a7dd-fa18996d6d53	477824a6-e268-488b-9a61-303ccabd5020
eb9157bc-5ca3-4963-b017-fea29556b13d	f6e2a4b0-bc44-4bd7-beba-385cc6e03287
eb9157bc-5ca3-4963-b017-fea29556b13d	240da721-16f6-48c4-a7a3-5b2889100645
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	31cd1d5f-16d9-482d-823a-361bd49b932d
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	4e7e7457-bc66-46b7-9331-d112ab24eec2
4e7e7457-bc66-46b7-9331-d112ab24eec2	fe70f593-850c-452a-a5e1-e550120fe4ea
a7e612ed-84df-4a93-acaf-f3eb568b4c47	55bcdc36-ee3a-4bbe-9e6c-5fea00e3ffe7
50adf0ac-66ec-458d-8302-2067390ee0d7	ef128b71-ad21-4fd7-9bad-5662cc5e371d
30488891-dc4d-4f8d-9243-981997be31dc	9aef00af-3dc5-43bc-b01f-44284786ba30
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	bcd790a3-c63d-445f-8f99-3dadc41bcfb2
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	f2dd738f-9e34-4601-8e75-97478a2672f9
\.


--
-- Data for Name: credential; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.credential (id, salt, type, user_id, created_date, user_label, secret_data, credential_data, priority, version) FROM stdin;
de66c63c-52d5-408c-ac3d-606c0055531b	\N	password	b4ffa404-c9be-4193-bce9-7bb1111e39d5	1769687713786	\N	{"value":"5+1Njb84bEdj68GGY7oLiHA5j3PytSt+vwJwojVGpjM=","salt":"rCSe52LjZ2sv8rljJrD6FA==","additionalParameters":{}}	{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}	10	0
12ae494d-900d-4f4c-b9ea-e12d2c16a040	\N	password	8d9472da-8753-469a-9e7c-9ad5f084ce15	1771232913479	\N	{"value":"GwwQ6Ldo6PSZxqwbyi1rMcggFVa7zXaRrOzZETFdvPE=","salt":"acYxG0wYHxZdDlPp5F6jXQ==","additionalParameters":{}}	{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}	10	0
cfd2477b-f773-4dc9-b181-0d6fbabe8fb6	\N	password	fb58b885-e142-4a99-8331-8943ea2f4048	1771233047026	\N	{"value":"l33xCpyvOqLKCOg9Nn4FjLZoaoV+753TKykIvF+f0TI=","salt":"XfeQvaJWjq9b0/D2asrgvA==","additionalParameters":{}}	{"hashIterations":5,"algorithm":"argon2","additionalParameters":{"hashLength":["32"],"memory":["7168"],"type":["id"],"version":["1.3"],"parallelism":["1"]}}	10	0
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/jpa-changelog-1.0.0.Final.xml	2026-01-29 11:55:08.038958	1	EXECUTED	9:6f1016664e21e16d26517a4418f5e3df	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.33.0	\N	\N	9687705430
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/db2-jpa-changelog-1.0.0.Final.xml	2026-01-29 11:55:08.046796	2	MARK_RAN	9:828775b1596a07d1200ba1d49e5e3941	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.33.0	\N	\N	9687705430
1.1.0.Beta1	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Beta1.xml	2026-01-29 11:55:08.063469	3	EXECUTED	9:5f090e44a7d595883c1fb61f4b41fd38	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=CLIENT_ATTRIBUTES; createTable tableName=CLIENT_SESSION_NOTE; createTable tableName=APP_NODE_REGISTRATIONS; addColumn table...		\N	4.33.0	\N	\N	9687705430
1.1.0.Final	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Final.xml	2026-01-29 11:55:08.065022	4	EXECUTED	9:c07e577387a3d2c04d1adc9aaad8730e	renameColumn newColumnName=EVENT_TIME, oldColumnName=TIME, tableName=EVENT_ENTITY		\N	4.33.0	\N	\N	9687705430
1.2.0.Beta1	psilva@redhat.com	META-INF/jpa-changelog-1.2.0.Beta1.xml	2026-01-29 11:55:08.113529	5	EXECUTED	9:b68ce996c655922dbcd2fe6b6ae72686	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.33.0	\N	\N	9687705430
1.2.0.Beta1	psilva@redhat.com	META-INF/db2-jpa-changelog-1.2.0.Beta1.xml	2026-01-29 11:55:08.116423	6	MARK_RAN	9:543b5c9989f024fe35c6f6c5a97de88e	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.33.0	\N	\N	9687705430
1.2.0.RC1	bburke@redhat.com	META-INF/jpa-changelog-1.2.0.CR1.xml	2026-01-29 11:55:08.157542	7	EXECUTED	9:765afebbe21cf5bbca048e632df38336	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.33.0	\N	\N	9687705430
1.2.0.RC1	bburke@redhat.com	META-INF/db2-jpa-changelog-1.2.0.CR1.xml	2026-01-29 11:55:08.160025	8	MARK_RAN	9:db4a145ba11a6fdaefb397f6dbf829a1	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.33.0	\N	\N	9687705430
1.2.0.Final	keycloak	META-INF/jpa-changelog-1.2.0.Final.xml	2026-01-29 11:55:08.163192	9	EXECUTED	9:9d05c7be10cdb873f8bcb41bc3a8ab23	update tableName=CLIENT; update tableName=CLIENT; update tableName=CLIENT		\N	4.33.0	\N	\N	9687705430
1.3.0	bburke@redhat.com	META-INF/jpa-changelog-1.3.0.xml	2026-01-29 11:55:08.212779	10	EXECUTED	9:18593702353128d53111f9b1ff0b82b8	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=ADMI...		\N	4.33.0	\N	\N	9687705430
1.4.0	bburke@redhat.com	META-INF/jpa-changelog-1.4.0.xml	2026-01-29 11:55:08.237384	11	EXECUTED	9:6122efe5f090e41a85c0f1c9e52cbb62	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.33.0	\N	\N	9687705430
1.4.0	bburke@redhat.com	META-INF/db2-jpa-changelog-1.4.0.xml	2026-01-29 11:55:08.239041	12	MARK_RAN	9:e1ff28bf7568451453f844c5d54bb0b5	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.33.0	\N	\N	9687705430
1.5.0	bburke@redhat.com	META-INF/jpa-changelog-1.5.0.xml	2026-01-29 11:55:08.248272	13	EXECUTED	9:7af32cd8957fbc069f796b61217483fd	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.33.0	\N	\N	9687705430
1.6.1_from15	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-01-29 11:55:08.257342	14	EXECUTED	9:6005e15e84714cd83226bf7879f54190	addColumn tableName=REALM; addColumn tableName=KEYCLOAK_ROLE; addColumn tableName=CLIENT; createTable tableName=OFFLINE_USER_SESSION; createTable tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_US_SES_PK2, tableName=...		\N	4.33.0	\N	\N	9687705430
1.6.1_from16-pre	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-01-29 11:55:08.258231	15	MARK_RAN	9:bf656f5a2b055d07f314431cae76f06c	delete tableName=OFFLINE_CLIENT_SESSION; delete tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
1.6.1_from16	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-01-29 11:55:08.259427	16	MARK_RAN	9:f8dadc9284440469dcf71e25ca6ab99b	dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_US_SES_PK, tableName=OFFLINE_USER_SESSION; dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_CL_SES_PK, tableName=OFFLINE_CLIENT_SESSION; addColumn tableName=OFFLINE_USER_SESSION; update tableName=OF...		\N	4.33.0	\N	\N	9687705430
1.6.1	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-01-29 11:55:08.261391	17	EXECUTED	9:d41d8cd98f00b204e9800998ecf8427e	empty		\N	4.33.0	\N	\N	9687705430
1.7.0	bburke@redhat.com	META-INF/jpa-changelog-1.7.0.xml	2026-01-29 11:55:08.279612	18	EXECUTED	9:3368ff0be4c2855ee2dd9ca813b38d8e	createTable tableName=KEYCLOAK_GROUP; createTable tableName=GROUP_ROLE_MAPPING; createTable tableName=GROUP_ATTRIBUTE; createTable tableName=USER_GROUP_MEMBERSHIP; createTable tableName=REALM_DEFAULT_GROUPS; addColumn tableName=IDENTITY_PROVIDER; ...		\N	4.33.0	\N	\N	9687705430
1.8.0	mposolda@redhat.com	META-INF/jpa-changelog-1.8.0.xml	2026-01-29 11:55:08.303339	19	EXECUTED	9:8ac2fb5dd030b24c0570a763ed75ed20	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.33.0	\N	\N	9687705430
1.8.0-2	keycloak	META-INF/jpa-changelog-1.8.0.xml	2026-01-29 11:55:08.305214	20	EXECUTED	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.33.0	\N	\N	9687705430
22.0.5-24031	keycloak	META-INF/jpa-changelog-22.0.0.xml	2026-01-29 11:55:10.329199	119	MARK_RAN	9:a60d2d7b315ec2d3eba9e2f145f9df28	customChange		\N	4.33.0	\N	\N	9687705430
1.8.0	mposolda@redhat.com	META-INF/db2-jpa-changelog-1.8.0.xml	2026-01-29 11:55:08.30648	21	MARK_RAN	9:831e82914316dc8a57dc09d755f23c51	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.33.0	\N	\N	9687705430
1.8.0-2	keycloak	META-INF/db2-jpa-changelog-1.8.0.xml	2026-01-29 11:55:08.307486	22	MARK_RAN	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.33.0	\N	\N	9687705430
1.9.0	mposolda@redhat.com	META-INF/jpa-changelog-1.9.0.xml	2026-01-29 11:55:08.340922	23	EXECUTED	9:bc3d0f9e823a69dc21e23e94c7a94bb1	update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=REALM; update tableName=REALM; customChange; dr...		\N	4.33.0	\N	\N	9687705430
1.9.1	keycloak	META-INF/jpa-changelog-1.9.1.xml	2026-01-29 11:55:08.343374	24	EXECUTED	9:c9999da42f543575ab790e76439a2679	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=PUBLIC_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.33.0	\N	\N	9687705430
1.9.1	keycloak	META-INF/db2-jpa-changelog-1.9.1.xml	2026-01-29 11:55:08.343849	25	MARK_RAN	9:0d6c65c6f58732d81569e77b10ba301d	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.33.0	\N	\N	9687705430
1.9.2	keycloak	META-INF/jpa-changelog-1.9.2.xml	2026-01-29 11:55:08.500219	26	EXECUTED	9:fc576660fc016ae53d2d4778d84d86d0	createIndex indexName=IDX_USER_EMAIL, tableName=USER_ENTITY; createIndex indexName=IDX_USER_ROLE_MAPPING, tableName=USER_ROLE_MAPPING; createIndex indexName=IDX_USER_GROUP_MAPPING, tableName=USER_GROUP_MEMBERSHIP; createIndex indexName=IDX_USER_CO...		\N	4.33.0	\N	\N	9687705430
authz-2.0.0	psilva@redhat.com	META-INF/jpa-changelog-authz-2.0.0.xml	2026-01-29 11:55:08.529826	27	EXECUTED	9:43ed6b0da89ff77206289e87eaa9c024	createTable tableName=RESOURCE_SERVER; addPrimaryKey constraintName=CONSTRAINT_FARS, tableName=RESOURCE_SERVER; addUniqueConstraint constraintName=UK_AU8TT6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER; createTable tableName=RESOURCE_SERVER_RESOU...		\N	4.33.0	\N	\N	9687705430
authz-2.5.1	psilva@redhat.com	META-INF/jpa-changelog-authz-2.5.1.xml	2026-01-29 11:55:08.53137	28	EXECUTED	9:44bae577f551b3738740281eceb4ea70	update tableName=RESOURCE_SERVER_POLICY		\N	4.33.0	\N	\N	9687705430
2.1.0-KEYCLOAK-5461	bburke@redhat.com	META-INF/jpa-changelog-2.1.0.xml	2026-01-29 11:55:08.55573	29	EXECUTED	9:bd88e1f833df0420b01e114533aee5e8	createTable tableName=BROKER_LINK; createTable tableName=FED_USER_ATTRIBUTE; createTable tableName=FED_USER_CONSENT; createTable tableName=FED_USER_CONSENT_ROLE; createTable tableName=FED_USER_CONSENT_PROT_MAPPER; createTable tableName=FED_USER_CR...		\N	4.33.0	\N	\N	9687705430
2.2.0	bburke@redhat.com	META-INF/jpa-changelog-2.2.0.xml	2026-01-29 11:55:08.562286	30	EXECUTED	9:a7022af5267f019d020edfe316ef4371	addColumn tableName=ADMIN_EVENT_ENTITY; createTable tableName=CREDENTIAL_ATTRIBUTE; createTable tableName=FED_CREDENTIAL_ATTRIBUTE; modifyDataType columnName=VALUE, tableName=CREDENTIAL; addForeignKeyConstraint baseTableName=FED_CREDENTIAL_ATTRIBU...		\N	4.33.0	\N	\N	9687705430
2.3.0	bburke@redhat.com	META-INF/jpa-changelog-2.3.0.xml	2026-01-29 11:55:08.569414	31	EXECUTED	9:fc155c394040654d6a79227e56f5e25a	createTable tableName=FEDERATED_USER; addPrimaryKey constraintName=CONSTR_FEDERATED_USER, tableName=FEDERATED_USER; dropDefaultValue columnName=TOTP, tableName=USER_ENTITY; dropColumn columnName=TOTP, tableName=USER_ENTITY; addColumn tableName=IDE...		\N	4.33.0	\N	\N	9687705430
2.4.0	bburke@redhat.com	META-INF/jpa-changelog-2.4.0.xml	2026-01-29 11:55:08.571159	32	EXECUTED	9:eac4ffb2a14795e5dc7b426063e54d88	customChange		\N	4.33.0	\N	\N	9687705430
2.5.0	bburke@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-01-29 11:55:08.573272	33	EXECUTED	9:54937c05672568c4c64fc9524c1e9462	customChange; modifyDataType columnName=USER_ID, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
2.5.0-unicode-oracle	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-01-29 11:55:08.574076	34	MARK_RAN	9:f9753208029f582525ed12011a19d054	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.33.0	\N	\N	9687705430
2.5.0-unicode-other-dbs	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-01-29 11:55:08.584456	35	EXECUTED	9:33d72168746f81f98ae3a1e8e0ca3554	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.33.0	\N	\N	9687705430
2.5.0-duplicate-email-support	slawomir@dabek.name	META-INF/jpa-changelog-2.5.0.xml	2026-01-29 11:55:08.586915	36	EXECUTED	9:61b6d3d7a4c0e0024b0c839da283da0c	addColumn tableName=REALM		\N	4.33.0	\N	\N	9687705430
2.5.0-unique-group-names	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-01-29 11:55:08.589096	37	EXECUTED	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.33.0	\N	\N	9687705430
2.5.1	bburke@redhat.com	META-INF/jpa-changelog-2.5.1.xml	2026-01-29 11:55:08.590712	38	EXECUTED	9:a2b870802540cb3faa72098db5388af3	addColumn tableName=FED_USER_CONSENT		\N	4.33.0	\N	\N	9687705430
3.0.0	bburke@redhat.com	META-INF/jpa-changelog-3.0.0.xml	2026-01-29 11:55:08.592136	39	EXECUTED	9:132a67499ba24bcc54fb5cbdcfe7e4c0	addColumn tableName=IDENTITY_PROVIDER		\N	4.33.0	\N	\N	9687705430
3.2.0-fix	keycloak	META-INF/jpa-changelog-3.2.0.xml	2026-01-29 11:55:08.592748	40	MARK_RAN	9:938f894c032f5430f2b0fafb1a243462	addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS		\N	4.33.0	\N	\N	9687705430
3.2.0-fix-with-keycloak-5416	keycloak	META-INF/jpa-changelog-3.2.0.xml	2026-01-29 11:55:08.593716	41	MARK_RAN	9:845c332ff1874dc5d35974b0babf3006	dropIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS; addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS; createIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS		\N	4.33.0	\N	\N	9687705430
3.2.0-fix-offline-sessions	hmlnarik	META-INF/jpa-changelog-3.2.0.xml	2026-01-29 11:55:08.595836	42	EXECUTED	9:fc86359c079781adc577c5a217e4d04c	customChange		\N	4.33.0	\N	\N	9687705430
3.2.0-fixed	keycloak	META-INF/jpa-changelog-3.2.0.xml	2026-01-29 11:55:09.395646	43	EXECUTED	9:59a64800e3c0d09b825f8a3b444fa8f4	addColumn tableName=REALM; dropPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_PK2, tableName=OFFLINE_CLIENT_SESSION; dropColumn columnName=CLIENT_SESSION_ID, tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_P...		\N	4.33.0	\N	\N	9687705430
3.3.0	keycloak	META-INF/jpa-changelog-3.3.0.xml	2026-01-29 11:55:09.397765	44	EXECUTED	9:d48d6da5c6ccf667807f633fe489ce88	addColumn tableName=USER_ENTITY		\N	4.33.0	\N	\N	9687705430
authz-3.4.0.CR1-resource-server-pk-change-part1	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-01-29 11:55:09.399484	45	EXECUTED	9:dde36f7973e80d71fceee683bc5d2951	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_RESOURCE; addColumn tableName=RESOURCE_SERVER_SCOPE		\N	4.33.0	\N	\N	9687705430
authz-3.4.0.CR1-resource-server-pk-change-part2-KEYCLOAK-6095	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-01-29 11:55:09.401387	46	EXECUTED	9:b855e9b0a406b34fa323235a0cf4f640	customChange		\N	4.33.0	\N	\N	9687705430
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-01-29 11:55:09.401882	47	MARK_RAN	9:51abbacd7b416c50c4421a8cabf7927e	dropIndex indexName=IDX_RES_SERV_POL_RES_SERV, tableName=RESOURCE_SERVER_POLICY; dropIndex indexName=IDX_RES_SRV_RES_RES_SRV, tableName=RESOURCE_SERVER_RESOURCE; dropIndex indexName=IDX_RES_SRV_SCOPE_RES_SRV, tableName=RESOURCE_SERVER_SCOPE		\N	4.33.0	\N	\N	9687705430
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed-nodropindex	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-01-29 11:55:09.463085	48	EXECUTED	9:bdc99e567b3398bac83263d375aad143	addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_POLICY; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_RESOURCE; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, ...		\N	4.33.0	\N	\N	9687705430
authn-3.4.0.CR1-refresh-token-max-reuse	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-01-29 11:55:09.465035	49	EXECUTED	9:d198654156881c46bfba39abd7769e69	addColumn tableName=REALM		\N	4.33.0	\N	\N	9687705430
3.4.0	keycloak	META-INF/jpa-changelog-3.4.0.xml	2026-01-29 11:55:09.482769	50	EXECUTED	9:cfdd8736332ccdd72c5256ccb42335db	addPrimaryKey constraintName=CONSTRAINT_REALM_DEFAULT_ROLES, tableName=REALM_DEFAULT_ROLES; addPrimaryKey constraintName=CONSTRAINT_COMPOSITE_ROLE, tableName=COMPOSITE_ROLE; addPrimaryKey constraintName=CONSTR_REALM_DEFAULT_GROUPS, tableName=REALM...		\N	4.33.0	\N	\N	9687705430
3.4.0-KEYCLOAK-5230	hmlnarik@redhat.com	META-INF/jpa-changelog-3.4.0.xml	2026-01-29 11:55:09.656079	51	EXECUTED	9:7c84de3d9bd84d7f077607c1a4dcb714	createIndex indexName=IDX_FU_ATTRIBUTE, tableName=FED_USER_ATTRIBUTE; createIndex indexName=IDX_FU_CONSENT, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CONSENT_RU, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CREDENTIAL, t...		\N	4.33.0	\N	\N	9687705430
3.4.1	psilva@redhat.com	META-INF/jpa-changelog-3.4.1.xml	2026-01-29 11:55:09.657817	52	EXECUTED	9:5a6bb36cbefb6a9d6928452c0852af2d	modifyDataType columnName=VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
3.4.2	keycloak	META-INF/jpa-changelog-3.4.2.xml	2026-01-29 11:55:09.659188	53	EXECUTED	9:8f23e334dbc59f82e0a328373ca6ced0	update tableName=REALM		\N	4.33.0	\N	\N	9687705430
3.4.2-KEYCLOAK-5172	mkanis@redhat.com	META-INF/jpa-changelog-3.4.2.xml	2026-01-29 11:55:09.66026	54	EXECUTED	9:9156214268f09d970cdf0e1564d866af	update tableName=CLIENT		\N	4.33.0	\N	\N	9687705430
4.0.0-KEYCLOAK-6335	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-01-29 11:55:09.663016	55	EXECUTED	9:db806613b1ed154826c02610b7dbdf74	createTable tableName=CLIENT_AUTH_FLOW_BINDINGS; addPrimaryKey constraintName=C_CLI_FLOW_BIND, tableName=CLIENT_AUTH_FLOW_BINDINGS		\N	4.33.0	\N	\N	9687705430
4.0.0-CLEANUP-UNUSED-TABLE	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-01-29 11:55:09.665527	56	EXECUTED	9:229a041fb72d5beac76bb94a5fa709de	dropTable tableName=CLIENT_IDENTITY_PROV_MAPPING		\N	4.33.0	\N	\N	9687705430
4.0.0-KEYCLOAK-6228	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-01-29 11:55:09.690327	57	EXECUTED	9:079899dade9c1e683f26b2aa9ca6ff04	dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; dropNotNullConstraint columnName=CLIENT_ID, tableName=USER_CONSENT; addColumn tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHO...		\N	4.33.0	\N	\N	9687705430
4.0.0-KEYCLOAK-5579-fixed	mposolda@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-01-29 11:55:09.878174	58	EXECUTED	9:139b79bcbbfe903bb1c2d2a4dbf001d9	dropForeignKeyConstraint baseTableName=CLIENT_TEMPLATE_ATTRIBUTES, constraintName=FK_CL_TEMPL_ATTR_TEMPL; renameTable newTableName=CLIENT_SCOPE_ATTRIBUTES, oldTableName=CLIENT_TEMPLATE_ATTRIBUTES; renameColumn newColumnName=SCOPE_ID, oldColumnName...		\N	4.33.0	\N	\N	9687705430
authz-4.0.0.CR1	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.CR1.xml	2026-01-29 11:55:09.888926	59	EXECUTED	9:b55738ad889860c625ba2bf483495a04	createTable tableName=RESOURCE_SERVER_PERM_TICKET; addPrimaryKey constraintName=CONSTRAINT_FAPMT, tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRHO213XCX4WNKOG82SSPMT...		\N	4.33.0	\N	\N	9687705430
authz-4.0.0.Beta3	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.Beta3.xml	2026-01-29 11:55:09.891272	60	EXECUTED	9:e0057eac39aa8fc8e09ac6cfa4ae15fe	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRPO2128CX4WNKOG82SSRFY, referencedTableName=RESOURCE_SERVER_POLICY		\N	4.33.0	\N	\N	9687705430
authz-4.2.0.Final	mhajas@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2026-01-29 11:55:09.89442	61	EXECUTED	9:42a33806f3a0443fe0e7feeec821326c	createTable tableName=RESOURCE_URIS; addForeignKeyConstraint baseTableName=RESOURCE_URIS, constraintName=FK_RESOURCE_SERVER_URIS, referencedTableName=RESOURCE_SERVER_RESOURCE; customChange; dropColumn columnName=URI, tableName=RESOURCE_SERVER_RESO...		\N	4.33.0	\N	\N	9687705430
authz-4.2.0.Final-KEYCLOAK-9944	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2026-01-29 11:55:09.896385	62	EXECUTED	9:9968206fca46eecc1f51db9c024bfe56	addPrimaryKey constraintName=CONSTRAINT_RESOUR_URIS_PK, tableName=RESOURCE_URIS		\N	4.33.0	\N	\N	9687705430
4.2.0-KEYCLOAK-6313	wadahiro@gmail.com	META-INF/jpa-changelog-4.2.0.xml	2026-01-29 11:55:09.897385	63	EXECUTED	9:92143a6daea0a3f3b8f598c97ce55c3d	addColumn tableName=REQUIRED_ACTION_PROVIDER		\N	4.33.0	\N	\N	9687705430
4.3.0-KEYCLOAK-7984	wadahiro@gmail.com	META-INF/jpa-changelog-4.3.0.xml	2026-01-29 11:55:09.898477	64	EXECUTED	9:82bab26a27195d889fb0429003b18f40	update tableName=REQUIRED_ACTION_PROVIDER		\N	4.33.0	\N	\N	9687705430
4.6.0-KEYCLOAK-7950	psilva@redhat.com	META-INF/jpa-changelog-4.6.0.xml	2026-01-29 11:55:09.899585	65	EXECUTED	9:e590c88ddc0b38b0ae4249bbfcb5abc3	update tableName=RESOURCE_SERVER_RESOURCE		\N	4.33.0	\N	\N	9687705430
4.6.0-KEYCLOAK-8377	keycloak	META-INF/jpa-changelog-4.6.0.xml	2026-01-29 11:55:09.918784	66	EXECUTED	9:5c1f475536118dbdc38d5d7977950cc0	createTable tableName=ROLE_ATTRIBUTE; addPrimaryKey constraintName=CONSTRAINT_ROLE_ATTRIBUTE_PK, tableName=ROLE_ATTRIBUTE; addForeignKeyConstraint baseTableName=ROLE_ATTRIBUTE, constraintName=FK_ROLE_ATTRIBUTE_ID, referencedTableName=KEYCLOAK_ROLE...		\N	4.33.0	\N	\N	9687705430
4.6.0-KEYCLOAK-8555	gideonray@gmail.com	META-INF/jpa-changelog-4.6.0.xml	2026-01-29 11:55:09.93706	67	EXECUTED	9:e7c9f5f9c4d67ccbbcc215440c718a17	createIndex indexName=IDX_COMPONENT_PROVIDER_TYPE, tableName=COMPONENT		\N	4.33.0	\N	\N	9687705430
4.7.0-KEYCLOAK-1267	sguilhen@redhat.com	META-INF/jpa-changelog-4.7.0.xml	2026-01-29 11:55:09.93923	68	EXECUTED	9:88e0bfdda924690d6f4e430c53447dd5	addColumn tableName=REALM		\N	4.33.0	\N	\N	9687705430
4.7.0-KEYCLOAK-7275	keycloak	META-INF/jpa-changelog-4.7.0.xml	2026-01-29 11:55:09.964593	69	EXECUTED	9:f53177f137e1c46b6a88c59ec1cb5218	renameColumn newColumnName=CREATED_ON, oldColumnName=LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION; addNotNullConstraint columnName=CREATED_ON, tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_USER_SESSION; customChange; createIn...		\N	4.33.0	\N	\N	9687705430
4.8.0-KEYCLOAK-8835	sguilhen@redhat.com	META-INF/jpa-changelog-4.8.0.xml	2026-01-29 11:55:09.972109	70	EXECUTED	9:a74d33da4dc42a37ec27121580d1459f	addNotNullConstraint columnName=SSO_MAX_LIFESPAN_REMEMBER_ME, tableName=REALM; addNotNullConstraint columnName=SSO_IDLE_TIMEOUT_REMEMBER_ME, tableName=REALM		\N	4.33.0	\N	\N	9687705430
authz-7.0.0-KEYCLOAK-10443	psilva@redhat.com	META-INF/jpa-changelog-authz-7.0.0.xml	2026-01-29 11:55:09.974211	71	EXECUTED	9:fd4ade7b90c3b67fae0bfcfcb42dfb5f	addColumn tableName=RESOURCE_SERVER		\N	4.33.0	\N	\N	9687705430
8.0.0-adding-credential-columns	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-01-29 11:55:09.977427	72	EXECUTED	9:aa072ad090bbba210d8f18781b8cebf4	addColumn tableName=CREDENTIAL; addColumn tableName=FED_USER_CREDENTIAL		\N	4.33.0	\N	\N	9687705430
8.0.0-updating-credential-data-not-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-01-29 11:55:09.980569	73	EXECUTED	9:1ae6be29bab7c2aa376f6983b932be37	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.33.0	\N	\N	9687705430
8.0.0-updating-credential-data-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-01-29 11:55:09.98152	74	MARK_RAN	9:14706f286953fc9a25286dbd8fb30d97	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.33.0	\N	\N	9687705430
8.0.0-credential-cleanup-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-01-29 11:55:09.990266	75	EXECUTED	9:2b9cc12779be32c5b40e2e67711a218b	dropDefaultValue columnName=COUNTER, tableName=CREDENTIAL; dropDefaultValue columnName=DIGITS, tableName=CREDENTIAL; dropDefaultValue columnName=PERIOD, tableName=CREDENTIAL; dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; dropColumn ...		\N	4.33.0	\N	\N	9687705430
8.0.0-resource-tag-support	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-01-29 11:55:10.008947	76	EXECUTED	9:91fa186ce7a5af127a2d7a91ee083cc5	addColumn tableName=MIGRATION_MODEL; createIndex indexName=IDX_UPDATE_TIME, tableName=MIGRATION_MODEL		\N	4.33.0	\N	\N	9687705430
9.0.0-always-display-client	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-01-29 11:55:10.010531	77	EXECUTED	9:6335e5c94e83a2639ccd68dd24e2e5ad	addColumn tableName=CLIENT		\N	4.33.0	\N	\N	9687705430
9.0.0-drop-constraints-for-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-01-29 11:55:10.011158	78	MARK_RAN	9:6bdb5658951e028bfe16fa0a8228b530	dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5PMT, tableName=RESOURCE_SERVER_PERM_TICKET; dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER_RESOURCE; dropPrimaryKey constraintName=CONSTRAINT_O...		\N	4.33.0	\N	\N	9687705430
9.0.0-increase-column-size-federated-fk	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-01-29 11:55:10.019512	79	EXECUTED	9:d5bc15a64117ccad481ce8792d4c608f	modifyDataType columnName=CLIENT_ID, tableName=FED_USER_CONSENT; modifyDataType columnName=CLIENT_REALM_CONSTRAINT, tableName=KEYCLOAK_ROLE; modifyDataType columnName=OWNER, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=CLIENT_ID, ta...		\N	4.33.0	\N	\N	9687705430
9.0.0-recreate-constraints-after-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-01-29 11:55:10.020166	80	MARK_RAN	9:077cba51999515f4d3e7ad5619ab592c	addNotNullConstraint columnName=CLIENT_ID, tableName=OFFLINE_CLIENT_SESSION; addNotNullConstraint columnName=OWNER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNullConstraint columnName=REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNull...		\N	4.33.0	\N	\N	9687705430
9.0.1-add-index-to-client.client_id	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-01-29 11:55:10.037957	81	EXECUTED	9:be969f08a163bf47c6b9e9ead8ac2afb	createIndex indexName=IDX_CLIENT_ID, tableName=CLIENT		\N	4.33.0	\N	\N	9687705430
9.0.1-KEYCLOAK-12579-drop-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-01-29 11:55:10.038635	82	MARK_RAN	9:6d3bb4408ba5a72f39bd8a0b301ec6e3	dropUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.33.0	\N	\N	9687705430
9.0.1-KEYCLOAK-12579-add-not-null-constraint	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-01-29 11:55:10.040748	83	EXECUTED	9:966bda61e46bebf3cc39518fbed52fa7	addNotNullConstraint columnName=PARENT_GROUP, tableName=KEYCLOAK_GROUP		\N	4.33.0	\N	\N	9687705430
9.0.1-KEYCLOAK-12579-recreate-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-01-29 11:55:10.041388	84	MARK_RAN	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.33.0	\N	\N	9687705430
9.0.1-add-index-to-events	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-01-29 11:55:10.05807	85	EXECUTED	9:7d93d602352a30c0c317e6a609b56599	createIndex indexName=IDX_EVENT_TIME, tableName=EVENT_ENTITY		\N	4.33.0	\N	\N	9687705430
map-remove-ri	keycloak	META-INF/jpa-changelog-11.0.0.xml	2026-01-29 11:55:10.060099	86	EXECUTED	9:71c5969e6cdd8d7b6f47cebc86d37627	dropForeignKeyConstraint baseTableName=REALM, constraintName=FK_TRAF444KK6QRKMS7N56AIWQ5Y; dropForeignKeyConstraint baseTableName=KEYCLOAK_ROLE, constraintName=FK_KJHO5LE2C0RAL09FL8CM9WFW9		\N	4.33.0	\N	\N	9687705430
map-remove-ri	keycloak	META-INF/jpa-changelog-12.0.0.xml	2026-01-29 11:55:10.063954	87	EXECUTED	9:a9ba7d47f065f041b7da856a81762021	dropForeignKeyConstraint baseTableName=REALM_DEFAULT_GROUPS, constraintName=FK_DEF_GROUPS_GROUP; dropForeignKeyConstraint baseTableName=REALM_DEFAULT_ROLES, constraintName=FK_H4WPD7W4HSOOLNI3H0SW7BTJE; dropForeignKeyConstraint baseTableName=CLIENT...		\N	4.33.0	\N	\N	9687705430
12.1.0-add-realm-localization-table	keycloak	META-INF/jpa-changelog-12.0.0.xml	2026-01-29 11:55:10.067194	88	EXECUTED	9:fffabce2bc01e1a8f5110d5278500065	createTable tableName=REALM_LOCALIZATIONS; addPrimaryKey tableName=REALM_LOCALIZATIONS		\N	4.33.0	\N	\N	9687705430
default-roles	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.069396	89	EXECUTED	9:fa8a5b5445e3857f4b010bafb5009957	addColumn tableName=REALM; customChange		\N	4.33.0	\N	\N	9687705430
default-roles-cleanup	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.072675	90	EXECUTED	9:67ac3241df9a8582d591c5ed87125f39	dropTable tableName=REALM_DEFAULT_ROLES; dropTable tableName=CLIENT_DEFAULT_ROLES		\N	4.33.0	\N	\N	9687705430
13.0.0-KEYCLOAK-16844	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.08957	91	EXECUTED	9:ad1194d66c937e3ffc82386c050ba089	createIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
map-remove-ri-13.0.0	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.094102	92	EXECUTED	9:d9be619d94af5a2f5d07b9f003543b91	dropForeignKeyConstraint baseTableName=DEFAULT_CLIENT_SCOPE, constraintName=FK_R_DEF_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SCOPE_CLIENT, constraintName=FK_C_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SC...		\N	4.33.0	\N	\N	9687705430
13.0.0-KEYCLOAK-17992-drop-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.094756	93	MARK_RAN	9:544d201116a0fcc5a5da0925fbbc3bde	dropPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CLSCOPE_CL, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CL_CLSCOPE, tableName=CLIENT_SCOPE_CLIENT		\N	4.33.0	\N	\N	9687705430
13.0.0-increase-column-size-federated	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.098734	94	EXECUTED	9:43c0c1055b6761b4b3e89de76d612ccf	modifyDataType columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; modifyDataType columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT		\N	4.33.0	\N	\N	9687705430
13.0.0-KEYCLOAK-17992-recreate-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.099384	95	MARK_RAN	9:8bd711fd0330f4fe980494ca43ab1139	addNotNullConstraint columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; addNotNullConstraint columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT; addPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; createIndex indexName=...		\N	4.33.0	\N	\N	9687705430
json-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-01-29 11:55:10.10164	96	EXECUTED	9:e07d2bc0970c348bb06fb63b1f82ddbf	addColumn tableName=REALM_ATTRIBUTE; update tableName=REALM_ATTRIBUTE; dropColumn columnName=VALUE, tableName=REALM_ATTRIBUTE; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=REALM_ATTRIBUTE		\N	4.33.0	\N	\N	9687705430
14.0.0-KEYCLOAK-11019	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-01-29 11:55:10.15031	97	EXECUTED	9:24fb8611e97f29989bea412aa38d12b7	createIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USER, tableName=OFFLINE_USER_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
14.0.0-KEYCLOAK-18286	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-01-29 11:55:10.151157	98	MARK_RAN	9:259f89014ce2506ee84740cbf7163aa7	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
14.0.0-KEYCLOAK-18286-revert	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-01-29 11:55:10.159939	99	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
14.0.0-KEYCLOAK-18286-supported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-01-29 11:55:10.178087	100	EXECUTED	9:60ca84a0f8c94ec8c3504a5a3bc88ee8	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
14.0.0-KEYCLOAK-18286-unsupported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-01-29 11:55:10.178744	101	MARK_RAN	9:d3d977031d431db16e2c181ce49d73e9	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
KEYCLOAK-17267-add-index-to-user-attributes	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-01-29 11:55:10.195891	102	EXECUTED	9:0b305d8d1277f3a89a0a53a659ad274c	createIndex indexName=IDX_USER_ATTRIBUTE_NAME, tableName=USER_ATTRIBUTE		\N	4.33.0	\N	\N	9687705430
KEYCLOAK-18146-add-saml-art-binding-identifier	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-01-29 11:55:10.198253	103	EXECUTED	9:2c374ad2cdfe20e2905a84c8fac48460	customChange		\N	4.33.0	\N	\N	9687705430
15.0.0-KEYCLOAK-18467	keycloak	META-INF/jpa-changelog-15.0.0.xml	2026-01-29 11:55:10.202509	104	EXECUTED	9:47a760639ac597360a8219f5b768b4de	addColumn tableName=REALM_LOCALIZATIONS; update tableName=REALM_LOCALIZATIONS; dropColumn columnName=TEXTS, tableName=REALM_LOCALIZATIONS; renameColumn newColumnName=TEXTS, oldColumnName=TEXTS_NEW, tableName=REALM_LOCALIZATIONS; addNotNullConstrai...		\N	4.33.0	\N	\N	9687705430
17.0.0-9562	keycloak	META-INF/jpa-changelog-17.0.0.xml	2026-01-29 11:55:10.221277	105	EXECUTED	9:a6272f0576727dd8cad2522335f5d99e	createIndex indexName=IDX_USER_SERVICE_ACCOUNT, tableName=USER_ENTITY		\N	4.33.0	\N	\N	9687705430
18.0.0-10625-IDX_ADMIN_EVENT_TIME	keycloak	META-INF/jpa-changelog-18.0.0.xml	2026-01-29 11:55:10.24355	106	EXECUTED	9:015479dbd691d9cc8669282f4828c41d	createIndex indexName=IDX_ADMIN_EVENT_TIME, tableName=ADMIN_EVENT_ENTITY		\N	4.33.0	\N	\N	9687705430
18.0.15-30992-index-consent	keycloak	META-INF/jpa-changelog-18.0.15.xml	2026-01-29 11:55:10.265619	107	EXECUTED	9:80071ede7a05604b1f4906f3bf3b00f0	createIndex indexName=IDX_USCONSENT_SCOPE_ID, tableName=USER_CONSENT_CLIENT_SCOPE		\N	4.33.0	\N	\N	9687705430
19.0.0-10135	keycloak	META-INF/jpa-changelog-19.0.0.xml	2026-01-29 11:55:10.267912	108	EXECUTED	9:9518e495fdd22f78ad6425cc30630221	customChange		\N	4.33.0	\N	\N	9687705430
20.0.0-12964-supported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-01-29 11:55:10.286428	109	EXECUTED	9:e5f243877199fd96bcc842f27a1656ac	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.33.0	\N	\N	9687705430
20.0.0-12964-supported-dbs-edb-migration	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-01-29 11:55:10.307442	110	EXECUTED	9:a6b18a8e38062df5793edbe064f4aecd	dropIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE; createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.33.0	\N	\N	9687705430
20.0.0-12964-unsupported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-01-29 11:55:10.308299	111	MARK_RAN	9:1a6fcaa85e20bdeae0a9ce49b41946a5	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.33.0	\N	\N	9687705430
client-attributes-string-accomodation-fixed-pre-drop-index	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-01-29 11:55:10.310301	112	EXECUTED	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
client-attributes-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-01-29 11:55:10.312652	113	EXECUTED	9:3f332e13e90739ed0c35b0b25b7822ca	addColumn tableName=CLIENT_ATTRIBUTES; update tableName=CLIENT_ATTRIBUTES; dropColumn columnName=VALUE, tableName=CLIENT_ATTRIBUTES; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
client-attributes-string-accomodation-fixed-post-create-index	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-01-29 11:55:10.31327	114	MARK_RAN	9:bd2bd0fc7768cf0845ac96a8786fa735	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
21.0.2-17277	keycloak	META-INF/jpa-changelog-21.0.2.xml	2026-01-29 11:55:10.315273	115	EXECUTED	9:7ee1f7a3fb8f5588f171fb9a6ab623c0	customChange		\N	4.33.0	\N	\N	9687705430
21.1.0-19404	keycloak	META-INF/jpa-changelog-21.1.0.xml	2026-01-29 11:55:10.325386	116	EXECUTED	9:3d7e830b52f33676b9d64f7f2b2ea634	modifyDataType columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=LOGIC, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=POLICY_ENFORCE_MODE, tableName=RESOURCE_SERVER		\N	4.33.0	\N	\N	9687705430
21.1.0-19404-2	keycloak	META-INF/jpa-changelog-21.1.0.xml	2026-01-29 11:55:10.326525	117	MARK_RAN	9:627d032e3ef2c06c0e1f73d2ae25c26c	addColumn tableName=RESOURCE_SERVER_POLICY; update tableName=RESOURCE_SERVER_POLICY; dropColumn columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; renameColumn newColumnName=DECISION_STRATEGY, oldColumnName=DECISION_STRATEGY_NEW, tabl...		\N	4.33.0	\N	\N	9687705430
22.0.0-17484-updated	keycloak	META-INF/jpa-changelog-22.0.0.xml	2026-01-29 11:55:10.328701	118	EXECUTED	9:90af0bfd30cafc17b9f4d6eccd92b8b3	customChange		\N	4.33.0	\N	\N	9687705430
23.0.0-12062	keycloak	META-INF/jpa-changelog-23.0.0.xml	2026-01-29 11:55:10.33172	120	EXECUTED	9:2168fbe728fec46ae9baf15bf80927b8	addColumn tableName=COMPONENT_CONFIG; update tableName=COMPONENT_CONFIG; dropColumn columnName=VALUE, tableName=COMPONENT_CONFIG; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=COMPONENT_CONFIG		\N	4.33.0	\N	\N	9687705430
23.0.0-17258	keycloak	META-INF/jpa-changelog-23.0.0.xml	2026-01-29 11:55:10.333019	121	EXECUTED	9:36506d679a83bbfda85a27ea1864dca8	addColumn tableName=EVENT_ENTITY		\N	4.33.0	\N	\N	9687705430
24.0.0-9758	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-01-29 11:55:10.419331	122	EXECUTED	9:502c557a5189f600f0f445a9b49ebbce	addColumn tableName=USER_ATTRIBUTE; addColumn tableName=FED_USER_ATTRIBUTE; createIndex indexName=USER_ATTR_LONG_VALUES, tableName=USER_ATTRIBUTE; createIndex indexName=FED_USER_ATTR_LONG_VALUES, tableName=FED_USER_ATTRIBUTE; createIndex indexName...		\N	4.33.0	\N	\N	9687705430
24.0.0-9758-2	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-01-29 11:55:10.421551	123	EXECUTED	9:bf0fdee10afdf597a987adbf291db7b2	customChange		\N	4.33.0	\N	\N	9687705430
24.0.0-26618-drop-index-if-present	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-01-29 11:55:10.424381	124	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
24.0.0-26618-reindex	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-01-29 11:55:10.445631	125	EXECUTED	9:08707c0f0db1cef6b352db03a60edc7f	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
24.0.0-26618-edb-migration	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-01-29 11:55:10.465116	126	EXECUTED	9:2f684b29d414cd47efe3a3599f390741	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES; createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
24.0.2-27228	keycloak	META-INF/jpa-changelog-24.0.2.xml	2026-01-29 11:55:10.466911	127	EXECUTED	9:eaee11f6b8aa25d2cc6a84fb86fc6238	customChange		\N	4.33.0	\N	\N	9687705430
24.0.2-27967-drop-index-if-present	keycloak	META-INF/jpa-changelog-24.0.2.xml	2026-01-29 11:55:10.467587	128	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
24.0.2-27967-reindex	keycloak	META-INF/jpa-changelog-24.0.2.xml	2026-01-29 11:55:10.468433	129	MARK_RAN	9:d3d977031d431db16e2c181ce49d73e9	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-tables	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.47239	130	EXECUTED	9:deda2df035df23388af95bbd36c17cef	addColumn tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_CLIENT_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-index-creation	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.489694	131	EXECUTED	9:3e96709818458ae49f3c679ae58d263a	createIndex indexName=IDX_OFFLINE_USS_BY_LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-index-cleanup-uss-createdon	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.492929	132	EXECUTED	9:78ab4fc129ed5e8265dbcc3485fba92f	dropIndex indexName=IDX_OFFLINE_USS_CREATEDON, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-index-cleanup-uss-preload	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.495864	133	EXECUTED	9:de5f7c1f7e10994ed8b62e621d20eaab	dropIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-index-cleanup-uss-by-usersess	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.498778	134	EXECUTED	9:6eee220d024e38e89c799417ec33667f	dropIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-index-cleanup-css-preload	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.50179	135	EXECUTED	9:5411d2fb2891d3e8d63ddb55dfa3c0c9	dropIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-index-2-mysql	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.502442	136	MARK_RAN	9:b7ef76036d3126bb83c2423bf4d449d6	createIndex indexName=IDX_OFFLINE_USS_BY_BROKER_SESSION_ID, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-28265-index-2-not-mysql	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.521171	137	EXECUTED	9:23396cf51ab8bc1ae6f0cac7f9f6fcf7	createIndex indexName=IDX_OFFLINE_USS_BY_BROKER_SESSION_ID, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
25.0.0-org	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.529461	138	EXECUTED	9:5c859965c2c9b9c72136c360649af157	createTable tableName=ORG; addUniqueConstraint constraintName=UK_ORG_NAME, tableName=ORG; addUniqueConstraint constraintName=UK_ORG_GROUP, tableName=ORG; createTable tableName=ORG_DOMAIN		\N	4.33.0	\N	\N	9687705430
unique-consentuser	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.533447	139	EXECUTED	9:5857626a2ea8767e9a6c66bf3a2cb32f	customChange; dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_LOCAL_CONSENT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_EXTERNAL_CONSENT, tableName=...		\N	4.33.0	\N	\N	9687705430
unique-consentuser-edb-migration	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.538938	140	MARK_RAN	9:5857626a2ea8767e9a6c66bf3a2cb32f	customChange; dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_LOCAL_CONSENT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_EXTERNAL_CONSENT, tableName=...		\N	4.33.0	\N	\N	9687705430
unique-consentuser-mysql	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.53979	141	MARK_RAN	9:b79478aad5adaa1bc428e31563f55e8e	customChange; dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_LOCAL_CONSENT, tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_EXTERNAL_CONSENT, tableName=...		\N	4.33.0	\N	\N	9687705430
25.0.0-28861-index-creation	keycloak	META-INF/jpa-changelog-25.0.0.xml	2026-01-29 11:55:10.574655	142	EXECUTED	9:b9acb58ac958d9ada0fe12a5d4794ab1	createIndex indexName=IDX_PERM_TICKET_REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; createIndex indexName=IDX_PERM_TICKET_OWNER, tableName=RESOURCE_SERVER_PERM_TICKET		\N	4.33.0	\N	\N	9687705430
26.0.0-org-alias	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.577792	143	EXECUTED	9:6ef7d63e4412b3c2d66ed179159886a4	addColumn tableName=ORG; update tableName=ORG; addNotNullConstraint columnName=ALIAS, tableName=ORG; addUniqueConstraint constraintName=UK_ORG_ALIAS, tableName=ORG		\N	4.33.0	\N	\N	9687705430
26.0.0-org-group	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.580424	144	EXECUTED	9:da8e8087d80ef2ace4f89d8c5b9ca223	addColumn tableName=KEYCLOAK_GROUP; update tableName=KEYCLOAK_GROUP; addNotNullConstraint columnName=TYPE, tableName=KEYCLOAK_GROUP; customChange		\N	4.33.0	\N	\N	9687705430
26.0.0-org-indexes	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.597381	145	EXECUTED	9:79b05dcd610a8c7f25ec05135eec0857	createIndex indexName=IDX_ORG_DOMAIN_ORG_ID, tableName=ORG_DOMAIN		\N	4.33.0	\N	\N	9687705430
26.0.0-org-group-membership	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.599152	146	EXECUTED	9:a6ace2ce583a421d89b01ba2a28dc2d4	addColumn tableName=USER_GROUP_MEMBERSHIP; update tableName=USER_GROUP_MEMBERSHIP; addNotNullConstraint columnName=MEMBERSHIP_TYPE, tableName=USER_GROUP_MEMBERSHIP		\N	4.33.0	\N	\N	9687705430
31296-persist-revoked-access-tokens	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.601434	147	EXECUTED	9:64ef94489d42a358e8304b0e245f0ed4	createTable tableName=REVOKED_TOKEN; addPrimaryKey constraintName=CONSTRAINT_RT, tableName=REVOKED_TOKEN		\N	4.33.0	\N	\N	9687705430
31725-index-persist-revoked-access-tokens	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.61877	148	EXECUTED	9:b994246ec2bf7c94da881e1d28782c7b	createIndex indexName=IDX_REV_TOKEN_ON_EXPIRE, tableName=REVOKED_TOKEN		\N	4.33.0	\N	\N	9687705430
26.0.0-idps-for-login	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.652915	149	EXECUTED	9:51f5fffadf986983d4bd59582c6c1604	addColumn tableName=IDENTITY_PROVIDER; createIndex indexName=IDX_IDP_REALM_ORG, tableName=IDENTITY_PROVIDER; createIndex indexName=IDX_IDP_FOR_LOGIN, tableName=IDENTITY_PROVIDER; customChange		\N	4.33.0	\N	\N	9687705430
26.0.0-32583-drop-redundant-index-on-client-session	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.657622	150	EXECUTED	9:24972d83bf27317a055d234187bb4af9	dropIndex indexName=IDX_US_SESS_ID_ON_CL_SESS, tableName=OFFLINE_CLIENT_SESSION		\N	4.33.0	\N	\N	9687705430
26.0.0.32582-remove-tables-user-session-user-session-note-and-client-session	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.666105	151	EXECUTED	9:febdc0f47f2ed241c59e60f58c3ceea5	dropTable tableName=CLIENT_SESSION_ROLE; dropTable tableName=CLIENT_SESSION_NOTE; dropTable tableName=CLIENT_SESSION_PROT_MAPPER; dropTable tableName=CLIENT_SESSION_AUTH_STATUS; dropTable tableName=CLIENT_USER_SESSION_NOTE; dropTable tableName=CLI...		\N	4.33.0	\N	\N	9687705430
26.0.0-33201-org-redirect-url	keycloak	META-INF/jpa-changelog-26.0.0.xml	2026-01-29 11:55:10.667366	152	EXECUTED	9:4d0e22b0ac68ebe9794fa9cb752ea660	addColumn tableName=ORG		\N	4.33.0	\N	\N	9687705430
29399-jdbc-ping-default	keycloak	META-INF/jpa-changelog-26.1.0.xml	2026-01-29 11:55:10.671647	153	EXECUTED	9:007dbe99d7203fca403b89d4edfdf21e	createTable tableName=JGROUPS_PING; addPrimaryKey constraintName=CONSTRAINT_JGROUPS_PING, tableName=JGROUPS_PING		\N	4.33.0	\N	\N	9687705430
26.1.0-34013	keycloak	META-INF/jpa-changelog-26.1.0.xml	2026-01-29 11:55:10.674654	154	EXECUTED	9:e6b686a15759aef99a6d758a5c4c6a26	addColumn tableName=ADMIN_EVENT_ENTITY		\N	4.33.0	\N	\N	9687705430
26.1.0-34380	keycloak	META-INF/jpa-changelog-26.1.0.xml	2026-01-29 11:55:10.676348	155	EXECUTED	9:ac8b9edb7c2b6c17a1c7a11fcf5ccf01	dropTable tableName=USERNAME_LOGIN_FAILURE		\N	4.33.0	\N	\N	9687705430
26.2.0-36750	keycloak	META-INF/jpa-changelog-26.2.0.xml	2026-01-29 11:55:10.679654	156	EXECUTED	9:b49ce951c22f7eb16480ff085640a33a	createTable tableName=SERVER_CONFIG		\N	4.33.0	\N	\N	9687705430
26.2.0-26106	keycloak	META-INF/jpa-changelog-26.2.0.xml	2026-01-29 11:55:10.680823	157	EXECUTED	9:b5877d5dab7d10ff3a9d209d7beb6680	addColumn tableName=CREDENTIAL		\N	4.33.0	\N	\N	9687705430
26.2.6-39866-duplicate	keycloak	META-INF/jpa-changelog-26.2.6.xml	2026-01-29 11:55:10.682512	158	EXECUTED	9:1dc67ccee24f30331db2cba4f372e40e	customChange		\N	4.33.0	\N	\N	9687705430
26.2.6-39866-uk	keycloak	META-INF/jpa-changelog-26.2.6.xml	2026-01-29 11:55:10.684265	159	EXECUTED	9:b70b76f47210cf0a5f4ef0e219eac7cd	addUniqueConstraint constraintName=UK_MIGRATION_VERSION, tableName=MIGRATION_MODEL		\N	4.33.0	\N	\N	9687705430
26.2.6-40088-duplicate	keycloak	META-INF/jpa-changelog-26.2.6.xml	2026-01-29 11:55:10.685663	160	EXECUTED	9:cc7e02ed69ab31979afb1982f9670e8f	customChange		\N	4.33.0	\N	\N	9687705430
26.2.6-40088-uk	keycloak	META-INF/jpa-changelog-26.2.6.xml	2026-01-29 11:55:10.687421	161	EXECUTED	9:5bb848128da7bc4595cc507383325241	addUniqueConstraint constraintName=UK_MIGRATION_UPDATE_TIME, tableName=MIGRATION_MODEL		\N	4.33.0	\N	\N	9687705430
26.3.0-groups-description	keycloak	META-INF/jpa-changelog-26.3.0.xml	2026-01-29 11:55:10.689521	162	EXECUTED	9:e1a3c05574326fb5b246b73b9a4c4d49	addColumn tableName=KEYCLOAK_GROUP		\N	4.33.0	\N	\N	9687705430
26.4.0-40933-saml-encryption-attributes	keycloak	META-INF/jpa-changelog-26.4.0.xml	2026-01-29 11:55:10.690954	163	EXECUTED	9:7e9eaba362ca105efdda202303a4fe49	customChange		\N	4.33.0	\N	\N	9687705430
26.4.0-51321	keycloak	META-INF/jpa-changelog-26.4.0.xml	2026-01-29 11:55:10.707159	164	EXECUTED	9:34bab2bc56f75ffd7e347c580874e306	createIndex indexName=IDX_EVENT_ENTITY_USER_ID_TYPE, tableName=EVENT_ENTITY		\N	4.33.0	\N	\N	9687705430
40343-workflow-state-table	keycloak	META-INF/jpa-changelog-26.4.0.xml	2026-01-29 11:55:10.742851	165	EXECUTED	9:ed3ab4723ceed210e5b5e60ac4562106	createTable tableName=WORKFLOW_STATE; addPrimaryKey constraintName=PK_WORKFLOW_STATE, tableName=WORKFLOW_STATE; addUniqueConstraint constraintName=UQ_WORKFLOW_RESOURCE, tableName=WORKFLOW_STATE; createIndex indexName=IDX_WORKFLOW_STATE_STEP, table...		\N	4.33.0	\N	\N	9687705430
26.5.0-index-offline-css-by-client	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.761801	166	EXECUTED	9:383e981ce95d16e32af757b7998820f7	createIndex indexName=IDX_OFFLINE_CSS_BY_CLIENT, tableName=OFFLINE_CLIENT_SESSION		\N	4.33.0	\N	\N	9687705430
26.5.0-index-offline-css-by-client-storage-provider	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.780954	167	EXECUTED	9:f5bc200e6fa7d7e483854dee535ca425	createIndex indexName=IDX_OFFLINE_CSS_BY_CLIENT_STORAGE_PROVIDER, tableName=OFFLINE_CLIENT_SESSION		\N	4.33.0	\N	\N	9687705430
26.5.0-idp-config-allow-null	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.784695	168	EXECUTED	9:b667fb087874303b324c1af7fae4f606	dropDefaultValue columnName=TRUST_EMAIL, tableName=IDENTITY_PROVIDER; dropNotNullConstraint columnName=TRUST_EMAIL, tableName=IDENTITY_PROVIDER; dropNotNullConstraint columnName=STORE_TOKEN, tableName=IDENTITY_PROVIDER; dropDefaultValue columnName...		\N	4.33.0	\N	\N	9687705430
26.5.0-remove-workflow-provider-id-column	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.804744	169	EXECUTED	9:d8eeb324484d45e946d03b953e168b21	dropIndex indexName=IDX_WORKFLOW_STATE_PROVIDER, tableName=WORKFLOW_STATE; createIndex indexName=IDX_WORKFLOW_STATE_PROVIDER, tableName=WORKFLOW_STATE; dropColumn columnName=WORKFLOW_PROVIDER_ID, tableName=WORKFLOW_STATE		\N	4.33.0	\N	\N	9687705430
26.5.0-add-remember-me	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.806992	170	EXECUTED	9:a7273ea8b21bd2f674c9c49141999f05	addColumn tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
26.5.0-add-sess-refresh-idx	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.82642	171	EXECUTED	9:ce49383d317ccbcd3434d1f21172b0b7	createIndex indexName=IDX_USER_SESSION_EXPIRATION_CREATED, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
26.5.0-add-sess-create-idx	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.845764	172	EXECUTED	9:aaee09e23a4d8468fbc5c51b7b314c58	createIndex indexName=IDX_USER_SESSION_EXPIRATION_LAST_REFRESH, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
26.5.0-drop-sess-refresh-idx	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.848977	173	EXECUTED	9:f0082210b6ccbbaf81287c27aa23753c	dropIndex indexName=IDX_OFFLINE_USS_BY_LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION		\N	4.33.0	\N	\N	9687705430
26.5.0-invitations-table	keycloak	META-INF/jpa-changelog-26.5.0.xml	2026-01-29 11:55:10.901475	174	EXECUTED	9:322cb11fc03181903dcd67a54f8b3cf0	createTable tableName=ORG_INVITATION; addForeignKeyConstraint baseTableName=ORG_INVITATION, constraintName=FK_ORG_INVITATION_ORG, referencedTableName=ORG; createIndex indexName=IDX_ORG_INVITATION_ORG_ID, tableName=ORG_INVITATION; createIndex index...		\N	4.33.0	\N	\N	9687705430
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
1000	f	\N	\N
\.


--
-- Data for Name: default_client_scope; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.default_client_scope (realm_id, scope_id, default_scope) FROM stdin;
173713f9-5e66-4a52-87f5-eff68df04cdc	e641081f-c540-424c-9eb7-e03f41fff62f	f
173713f9-5e66-4a52-87f5-eff68df04cdc	58e6a996-3d50-4a33-b8d5-674dfb11fdbb	t
173713f9-5e66-4a52-87f5-eff68df04cdc	863b0daf-5a75-4ad2-8c99-457c82e16045	t
173713f9-5e66-4a52-87f5-eff68df04cdc	c4f92b29-90a9-4c4b-bd93-0a1d25f84898	t
173713f9-5e66-4a52-87f5-eff68df04cdc	5665dcd7-902e-4b20-9b38-0e47bc80c009	t
173713f9-5e66-4a52-87f5-eff68df04cdc	4711a09a-93d4-4f9e-aa67-a90401daeea3	f
173713f9-5e66-4a52-87f5-eff68df04cdc	964830df-0a11-422d-8a77-c9aff78ff09d	f
173713f9-5e66-4a52-87f5-eff68df04cdc	f6e49207-ad6a-4152-9f92-cf79d4449e85	t
173713f9-5e66-4a52-87f5-eff68df04cdc	69efb0fa-6fe0-46a6-ae2c-667cf416685e	t
173713f9-5e66-4a52-87f5-eff68df04cdc	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef	f
173713f9-5e66-4a52-87f5-eff68df04cdc	dfdcef24-77c2-41d1-bd64-2d94d63081fb	t
173713f9-5e66-4a52-87f5-eff68df04cdc	db010692-12bf-4b5f-b06c-7a7c439327ba	t
173713f9-5e66-4a52-87f5-eff68df04cdc	cbad17e0-dd30-4561-b93a-bd028b1b12a9	f
a7442214-2630-4991-aa3c-a2f06c383451	92adc68e-57b2-4c0e-878b-021752bab844	f
a7442214-2630-4991-aa3c-a2f06c383451	a5cbc010-15b2-46da-92fb-6e7c1fa33deb	t
a7442214-2630-4991-aa3c-a2f06c383451	57ff9868-4808-48e0-869f-adafd96df4f3	t
a7442214-2630-4991-aa3c-a2f06c383451	da90fa50-4872-4133-927c-5368959f61df	t
a7442214-2630-4991-aa3c-a2f06c383451	eca420ba-22fa-4830-9f47-179618bcc11f	t
a7442214-2630-4991-aa3c-a2f06c383451	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4	f
a7442214-2630-4991-aa3c-a2f06c383451	96d952a9-49e8-42c4-9266-5538cf25c9bf	f
a7442214-2630-4991-aa3c-a2f06c383451	0011c370-9f1b-4999-9c46-83e8719e8c4e	t
a7442214-2630-4991-aa3c-a2f06c383451	6d8986b1-ed20-40e0-adcf-26e2f50f1356	t
a7442214-2630-4991-aa3c-a2f06c383451	f5a8fc11-d600-4ebb-89da-0343e556b24a	f
a7442214-2630-4991-aa3c-a2f06c383451	e55a584b-391b-4628-a522-15f7b2b187db	t
a7442214-2630-4991-aa3c-a2f06c383451	35b9a1a5-6273-43b1-bf48-ac59fb6cd402	t
a7442214-2630-4991-aa3c-a2f06c383451	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350	f
\.


--
-- Data for Name: event_entity; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.event_entity (id, client_id, details_json, error, ip_address, realm_id, session_id, event_time, type, user_id, details_json_long_value) FROM stdin;
\.


--
-- Data for Name: fed_user_attribute; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.fed_user_attribute (id, name, user_id, realm_id, storage_provider_id, value, long_value_hash, long_value_hash_lower_case, long_value) FROM stdin;
\.


--
-- Data for Name: fed_user_consent; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.fed_user_consent (id, client_id, user_id, realm_id, storage_provider_id, created_date, last_updated_date, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: fed_user_consent_cl_scope; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.fed_user_consent_cl_scope (user_consent_id, scope_id) FROM stdin;
\.


--
-- Data for Name: fed_user_credential; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.fed_user_credential (id, salt, type, created_date, user_id, realm_id, storage_provider_id, user_label, secret_data, credential_data, priority) FROM stdin;
\.


--
-- Data for Name: fed_user_group_membership; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.fed_user_group_membership (group_id, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: fed_user_required_action; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.fed_user_required_action (required_action, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: fed_user_role_mapping; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.fed_user_role_mapping (role_id, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: federated_identity; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.federated_identity (identity_provider, realm_id, federated_user_id, federated_username, token, user_id) FROM stdin;
\.


--
-- Data for Name: federated_user; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.federated_user (id, storage_provider_id, realm_id) FROM stdin;
\.


--
-- Data for Name: group_attribute; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.group_attribute (id, name, value, group_id) FROM stdin;
\.


--
-- Data for Name: group_role_mapping; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.group_role_mapping (role_id, group_id) FROM stdin;
\.


--
-- Data for Name: identity_provider; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.identity_provider (internal_id, enabled, provider_alias, provider_id, store_token, authenticate_by_default, realm_id, add_token_role, trust_email, first_broker_login_flow_id, post_broker_login_flow_id, provider_display_name, link_only, organization_id, hide_on_login) FROM stdin;
\.


--
-- Data for Name: identity_provider_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.identity_provider_config (identity_provider_id, value, name) FROM stdin;
\.


--
-- Data for Name: identity_provider_mapper; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.identity_provider_mapper (id, name, idp_alias, idp_mapper_name, realm_id) FROM stdin;
\.


--
-- Data for Name: idp_mapper_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.idp_mapper_config (idp_mapper_id, value, name) FROM stdin;
\.


--
-- Data for Name: jgroups_ping; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.jgroups_ping (address, name, cluster_name, ip, coord) FROM stdin;
\.


--
-- Data for Name: keycloak_group; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.keycloak_group (id, name, parent_group, realm_id, type, description) FROM stdin;
\.


--
-- Data for Name: keycloak_role; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.keycloak_role (id, client_realm_constraint, client_role, description, name, realm_id, client, realm) FROM stdin;
66d3306f-d865-460b-81d2-7e04f93c580e	173713f9-5e66-4a52-87f5-eff68df04cdc	f	${role_default-roles}	default-roles-master	173713f9-5e66-4a52-87f5-eff68df04cdc	\N	\N
50adf0ac-66ec-458d-8302-2067390ee0d7	173713f9-5e66-4a52-87f5-eff68df04cdc	f	${role_admin}	admin	173713f9-5e66-4a52-87f5-eff68df04cdc	\N	\N
90a341ca-8b74-49d6-9365-768916efcbe6	173713f9-5e66-4a52-87f5-eff68df04cdc	f	${role_create-realm}	create-realm	173713f9-5e66-4a52-87f5-eff68df04cdc	\N	\N
8fea0272-4e7d-4b50-8348-f85dc0c55a67	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_create-client}	create-client	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
6bbf6fec-a1b7-4ad2-9447-3eb4588f1d70	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_view-realm}	view-realm	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
2acb70af-9221-4d6d-a961-ad99f19ae873	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_view-users}	view-users	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
af8d1575-5d3a-484e-8af3-2a01d995a11b	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_view-clients}	view-clients	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
d6a7e316-2e19-41b0-b6ba-bfc548260cbf	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_view-events}	view-events	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
47001be9-1133-40cb-806c-f59c94830a9b	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_view-identity-providers}	view-identity-providers	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
92e49679-2198-4795-8393-868d2e6b23b5	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_view-authorization}	view-authorization	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
433443cf-c8e2-41f9-97e0-419a227e368c	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_manage-realm}	manage-realm	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
271f74d2-2157-4ef0-9427-ac14b3461390	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_manage-users}	manage-users	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
51204ba8-648d-4f8c-9502-ed900f9aa5de	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_manage-clients}	manage-clients	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
9ca39b1f-34ac-46ad-8b66-c80de4876f5c	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_manage-events}	manage-events	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
62427c07-87c8-4297-9b16-7df53c5c2083	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_manage-identity-providers}	manage-identity-providers	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
b769583d-c960-4516-bd96-8c0d3d845739	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_manage-authorization}	manage-authorization	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
61010341-71bf-4f00-87e1-1f2bd478b755	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_query-users}	query-users	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
91164117-4e1e-4425-9383-69849de47d98	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_query-clients}	query-clients	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
6ecae27d-2ec2-4dee-be6d-f8d462d75442	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_query-realms}	query-realms	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
173781a1-7bde-46ec-881e-6117b6da9c1d	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_query-groups}	query-groups	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
0f467850-2052-49ba-b196-43167e6012d5	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_view-profile}	view-profile	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
b0573419-cb74-4f85-96e3-7181ec281c08	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_manage-account}	manage-account	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
e81013a9-8d38-431b-9d2b-6978e4c47a2e	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_manage-account-links}	manage-account-links	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
39b76047-285b-441b-9377-64d2ba85c3d8	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_view-applications}	view-applications	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
03a0f2dd-398d-46b0-8459-7a90bc1d2f75	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_view-consent}	view-consent	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
cbb42cb5-5cb4-4f27-bbdf-9faa04c559c1	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_manage-consent}	manage-consent	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
df01dff5-9687-455a-ba28-a227267d9616	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_view-groups}	view-groups	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
d0f113d2-393e-426b-90d0-f2b7b18d5c80	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	t	${role_delete-account}	delete-account	173713f9-5e66-4a52-87f5-eff68df04cdc	18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	\N
d0facc02-8dbc-41b4-83f2-d16c2e366a7e	93343304-6333-4ab7-be3f-82eb2d678425	t	${role_read-token}	read-token	173713f9-5e66-4a52-87f5-eff68df04cdc	93343304-6333-4ab7-be3f-82eb2d678425	\N
c8bad959-766c-47d8-a4bd-df32dc6ef822	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	t	${role_impersonation}	impersonation	173713f9-5e66-4a52-87f5-eff68df04cdc	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	\N
6a33a8cd-5e8b-4ed1-9ff1-9c6f5244fe36	173713f9-5e66-4a52-87f5-eff68df04cdc	f	${role_offline-access}	offline_access	173713f9-5e66-4a52-87f5-eff68df04cdc	\N	\N
8841a166-8222-4a93-b3c1-2a63f5006cfa	173713f9-5e66-4a52-87f5-eff68df04cdc	f	${role_uma_authorization}	uma_authorization	173713f9-5e66-4a52-87f5-eff68df04cdc	\N	\N
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	a7442214-2630-4991-aa3c-a2f06c383451	f	${role_default-roles}	default-roles-but-tc	a7442214-2630-4991-aa3c-a2f06c383451	\N	\N
18cefe71-802a-494f-b842-cfe97ab674b5	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_create-client}	create-client	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
404f677e-f368-46ba-b8af-0475f242c530	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_view-realm}	view-realm	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
806b08a3-0866-4917-aaf9-75539fd6a1d2	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_view-users}	view-users	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
d0bb3701-f407-4851-b1c0-d88fffd319e6	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_view-clients}	view-clients	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
d1cfc9e0-ad97-4b96-aca7-9702ff3a3042	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_view-events}	view-events	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
2735876f-e6e3-4db3-9235-12dd046d1b71	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_view-identity-providers}	view-identity-providers	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
9bb994de-07b6-4c0a-b0e0-612ba6af55cd	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_view-authorization}	view-authorization	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
87837d4c-6b87-4c82-b27c-557d7dacd54e	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_manage-realm}	manage-realm	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
ab1ed7ef-8753-4d93-a773-a698e97293eb	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_manage-users}	manage-users	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
027ef80a-61c1-4adb-ac64-8468484bf3a3	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_manage-clients}	manage-clients	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
91ce7ddb-0a01-470f-ab07-b89bc5a8a6a0	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_manage-events}	manage-events	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
4187fbf9-834e-47ff-a5f1-e5dab92d5315	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_manage-identity-providers}	manage-identity-providers	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
83bb0a8f-9e5e-40c3-9a19-4e521bfea1d9	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_manage-authorization}	manage-authorization	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
8883695c-5725-4590-bab0-f0aff3316450	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_query-users}	query-users	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
5ca94246-01b3-406f-ba26-9dcb4f8c27e8	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_query-clients}	query-clients	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
652d85e9-7caa-4138-b326-277148e53d3b	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_query-realms}	query-realms	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
c89fa27d-237a-4728-b216-12b33d749ce2	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_query-groups}	query-groups	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
30488891-dc4d-4f8d-9243-981997be31dc	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_realm-admin}	realm-admin	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
f26c17fa-66ef-41c4-adb5-98780c5db864	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_create-client}	create-client	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
6e78ec13-3a61-4a9c-940a-6a0d24deb7a8	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_view-realm}	view-realm	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
eb9157bc-5ca3-4963-b017-fea29556b13d	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_view-users}	view-users	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
a3c6f0f1-df1b-4730-a7dd-fa18996d6d53	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_view-clients}	view-clients	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
5b84bc38-25a7-4b43-aaf4-585b4c6a300b	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_view-events}	view-events	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
bfc93764-d6bd-45de-bc90-f665e43f1f30	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_view-identity-providers}	view-identity-providers	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
a97bf783-8c8e-4d91-bd15-faf2f0eede07	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_view-authorization}	view-authorization	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
54469293-7e8a-42ee-ab58-3e2d39b49f1a	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_manage-realm}	manage-realm	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
fec76abd-2d50-4edb-9853-688bee32d429	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_manage-users}	manage-users	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
68aa922c-329b-4168-a86a-71ce668a093a	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_manage-clients}	manage-clients	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
2cf9896b-1b26-4a59-b4c6-230e8c1a31e5	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_manage-events}	manage-events	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
22f441d6-52f0-404d-80fb-00f1a822b7a6	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_manage-identity-providers}	manage-identity-providers	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
019e901d-967a-4b26-b53a-da37aa323901	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_manage-authorization}	manage-authorization	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
240da721-16f6-48c4-a7a3-5b2889100645	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_query-users}	query-users	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
477824a6-e268-488b-9a61-303ccabd5020	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_query-clients}	query-clients	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
4707a3a7-77c6-4c51-a2bd-268ac5c8802e	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_query-realms}	query-realms	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
f6e2a4b0-bc44-4bd7-beba-385cc6e03287	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_query-groups}	query-groups	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
31cd1d5f-16d9-482d-823a-361bd49b932d	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_view-profile}	view-profile	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
4e7e7457-bc66-46b7-9331-d112ab24eec2	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_manage-account}	manage-account	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
fe70f593-850c-452a-a5e1-e550120fe4ea	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_manage-account-links}	manage-account-links	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
d7b0de51-4e0d-4d2a-9880-38d30088db4c	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_view-applications}	view-applications	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
55bcdc36-ee3a-4bbe-9e6c-5fea00e3ffe7	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_view-consent}	view-consent	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
a7e612ed-84df-4a93-acaf-f3eb568b4c47	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_manage-consent}	manage-consent	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
b4a43ed2-b468-4b9c-9cc3-4f2f434f2ac1	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_view-groups}	view-groups	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
f5a40196-314e-439f-988e-f576d7ce7b76	de51720b-8d19-440e-8b0e-99c995f8af2a	t	${role_delete-account}	delete-account	a7442214-2630-4991-aa3c-a2f06c383451	de51720b-8d19-440e-8b0e-99c995f8af2a	\N
ef128b71-ad21-4fd7-9bad-5662cc5e371d	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	t	${role_impersonation}	impersonation	173713f9-5e66-4a52-87f5-eff68df04cdc	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	\N
9aef00af-3dc5-43bc-b01f-44284786ba30	20c3186e-055d-48bd-ac0c-dfbff0820a4e	t	${role_impersonation}	impersonation	a7442214-2630-4991-aa3c-a2f06c383451	20c3186e-055d-48bd-ac0c-dfbff0820a4e	\N
661531f9-5039-4d59-9e87-abbf144abc90	83215572-4fcd-4174-9bc3-0ba39cc76843	t	${role_read-token}	read-token	a7442214-2630-4991-aa3c-a2f06c383451	83215572-4fcd-4174-9bc3-0ba39cc76843	\N
bcd790a3-c63d-445f-8f99-3dadc41bcfb2	a7442214-2630-4991-aa3c-a2f06c383451	f	${role_offline-access}	offline_access	a7442214-2630-4991-aa3c-a2f06c383451	\N	\N
f2dd738f-9e34-4601-8e75-97478a2672f9	a7442214-2630-4991-aa3c-a2f06c383451	f	${role_uma_authorization}	uma_authorization	a7442214-2630-4991-aa3c-a2f06c383451	\N	\N
\.


--
-- Data for Name: migration_model; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.migration_model (id, version, update_time) FROM stdin;
dh83q	26.5.0	1769687711
\.


--
-- Data for Name: offline_client_session; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.offline_client_session (user_session_id, client_id, offline_flag, "timestamp", data, client_storage_provider, external_client_id, version) FROM stdin;
\.


--
-- Data for Name: offline_user_session; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.offline_user_session (user_session_id, user_id, realm_id, created_on, offline_flag, data, last_session_refresh, broker_session_id, version, remember_me) FROM stdin;
\.


--
-- Data for Name: org; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.org (id, enabled, realm_id, group_id, name, description, alias, redirect_url) FROM stdin;
\.


--
-- Data for Name: org_domain; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.org_domain (id, name, verified, org_id) FROM stdin;
\.


--
-- Data for Name: org_invitation; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.org_invitation (id, organization_id, email, first_name, last_name, created_at, expires_at, invite_link) FROM stdin;
\.


--
-- Data for Name: policy_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.policy_config (policy_id, name, value) FROM stdin;
\.


--
-- Data for Name: protocol_mapper; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.protocol_mapper (id, name, protocol, protocol_mapper_name, client_id, client_scope_id) FROM stdin;
f4486aaf-e6a6-4459-85ef-2b34ded4a507	audience resolve	openid-connect	oidc-audience-resolve-mapper	ca425a64-ebd2-47bf-96a4-5273dfcfa60f	\N
a24934c4-7ef2-44d7-914d-052b9227a77f	locale	openid-connect	oidc-usermodel-attribute-mapper	b082de96-b6a8-4df3-9f64-263f781ca779	\N
ffc00b22-9d22-4eaf-b99c-a7a81f2baea6	role list	saml	saml-role-list-mapper	\N	58e6a996-3d50-4a33-b8d5-674dfb11fdbb
6beab1e3-946c-408e-a758-39eb6ddcfa4b	organization	saml	saml-organization-membership-mapper	\N	863b0daf-5a75-4ad2-8c99-457c82e16045
2d9581c4-d82c-4771-b6cf-0cf273370715	full name	openid-connect	oidc-full-name-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
73ce87c9-5a95-4e68-8924-557deec8d153	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
f86d69bb-2733-45b2-b0ff-ef252c76e651	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
0922c1c2-d803-4357-b613-428a0660d92c	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
d4d74b04-6ac3-467d-b523-7aab59118fb7	username	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
28d3ac87-0c46-477f-a992-4735c84c362f	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
ef85f4b0-1035-4782-b691-67e9674aef98	website	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
d1765df9-34de-4427-afac-eda0ef6e832f	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
0423690e-5fe2-4426-9adf-10ca91581d3c	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
c756bcb5-e3b4-4916-9277-f2104190da4f	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
aeb283be-4d4f-427a-b62e-5c865dbc679c	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	c4f92b29-90a9-4c4b-bd93-0a1d25f84898
80040831-ba68-44a4-99db-29cc7e92e8f1	email	openid-connect	oidc-usermodel-attribute-mapper	\N	5665dcd7-902e-4b20-9b38-0e47bc80c009
942e1dfd-8a6d-4b41-bc40-44b1db745f66	email verified	openid-connect	oidc-usermodel-property-mapper	\N	5665dcd7-902e-4b20-9b38-0e47bc80c009
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	address	openid-connect	oidc-address-mapper	\N	4711a09a-93d4-4f9e-aa67-a90401daeea3
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	964830df-0a11-422d-8a77-c9aff78ff09d
0921e820-3658-48ee-bd01-53765df1ea96	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	964830df-0a11-422d-8a77-c9aff78ff09d
07df2164-3ea5-46a1-b011-22137bc935b1	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	f6e49207-ad6a-4152-9f92-cf79d4449e85
675ccfd3-f679-4178-9d3f-350b1a6c694a	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	f6e49207-ad6a-4152-9f92-cf79d4449e85
d18d52a5-fd9d-457d-bf34-73e1d8128067	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	f6e49207-ad6a-4152-9f92-cf79d4449e85
16e4eeac-d29b-46f1-8987-efd042af51b1	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	69efb0fa-6fe0-46a6-ae2c-667cf416685e
1f8e2b47-a8b9-4914-b70d-5d4af095511f	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	4f61fa78-cc46-48d8-bcea-9a1478b9d8ef
81cf3bf9-e9ce-4a9d-a1f3-404417939e71	acr loa level	openid-connect	oidc-acr-mapper	\N	dfdcef24-77c2-41d1-bd64-2d94d63081fb
a565bc8f-e254-4c80-b22d-6d89b01d6933	auth_time	openid-connect	oidc-usersessionmodel-note-mapper	\N	db010692-12bf-4b5f-b06c-7a7c439327ba
0d0938fc-8e1d-41e0-b9b4-9149c7ebc836	sub	openid-connect	oidc-sub-mapper	\N	db010692-12bf-4b5f-b06c-7a7c439327ba
0d73a758-6eed-4d9a-abb0-d16418ddb0c6	Client ID	openid-connect	oidc-usersessionmodel-note-mapper	\N	aa5ccd32-3bd2-41f0-a73b-bfe121f9b28b
4091810e-3342-4787-b39e-6850f0acad51	Client Host	openid-connect	oidc-usersessionmodel-note-mapper	\N	aa5ccd32-3bd2-41f0-a73b-bfe121f9b28b
7c7a6ccd-8588-4481-812f-cf062ad2c3a9	Client IP Address	openid-connect	oidc-usersessionmodel-note-mapper	\N	aa5ccd32-3bd2-41f0-a73b-bfe121f9b28b
edd12a1f-8b57-4f86-b40b-71e78b1f5f78	organization	openid-connect	oidc-organization-membership-mapper	\N	cbad17e0-dd30-4561-b93a-bd028b1b12a9
c16ff40c-4004-47ce-9a20-61fd8c1461b1	audience resolve	openid-connect	oidc-audience-resolve-mapper	ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	\N
eb4deff1-d36e-421b-8175-a3759b1c4bb3	role list	saml	saml-role-list-mapper	\N	a5cbc010-15b2-46da-92fb-6e7c1fa33deb
3b5de4bb-dfd8-41c3-b750-3a897226f0db	organization	saml	saml-organization-membership-mapper	\N	57ff9868-4808-48e0-869f-adafd96df4f3
47d1f5be-4669-4bb0-82ed-fe51655bc51b	full name	openid-connect	oidc-full-name-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
b8236475-fb5c-45d5-9445-eff4769218b2	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
92cc6a6b-d14f-4349-8526-914ec9b56b1c	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
c95e9b72-8f6d-485c-9179-d78d74647a8d	username	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
5bcf33e9-ee12-419e-9895-6e0b882d1804	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
ac80cd49-73a2-412d-a880-f859a9a041b8	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
f92b3dca-5572-4427-8610-2292d16a8afc	website	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
507b271a-8c24-4a86-a9f4-0175a3c5930a	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
bee36369-f3f5-4da3-b55f-6c7aea05c514	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
53cbe971-2a7c-4770-9693-78d3967123ab	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
cd8595f3-8235-42d0-8601-61d64f8e41c4	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
a258a62a-c4c7-4ab6-8571-e5c695a7c422	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	da90fa50-4872-4133-927c-5368959f61df
70918083-988e-46a6-9601-1f285037d2bb	email	openid-connect	oidc-usermodel-attribute-mapper	\N	eca420ba-22fa-4830-9f47-179618bcc11f
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	email verified	openid-connect	oidc-usermodel-property-mapper	\N	eca420ba-22fa-4830-9f47-179618bcc11f
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	address	openid-connect	oidc-address-mapper	\N	ec4fccaf-d0e2-4f02-a994-7b5e2c36bee4
20c2e59c-18e8-4b94-8d05-adff02a45fa5	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	96d952a9-49e8-42c4-9266-5538cf25c9bf
03916088-f0c4-46fd-8259-4e275d0df635	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	96d952a9-49e8-42c4-9266-5538cf25c9bf
54093d51-39f2-4cfd-91a8-d86042647624	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	0011c370-9f1b-4999-9c46-83e8719e8c4e
84b8fd37-9b1d-4671-858b-24c216056e6b	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	0011c370-9f1b-4999-9c46-83e8719e8c4e
14be3d83-94b4-4a89-b2d4-207314e30664	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	0011c370-9f1b-4999-9c46-83e8719e8c4e
4cd2585f-4930-4892-b79a-27debafb4414	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	6d8986b1-ed20-40e0-adcf-26e2f50f1356
3df0d527-3bc0-4813-8355-e78f5eceaa39	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	f5a8fc11-d600-4ebb-89da-0343e556b24a
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	f5a8fc11-d600-4ebb-89da-0343e556b24a
4ebe049b-7694-47b7-b331-7447e53ff2ea	acr loa level	openid-connect	oidc-acr-mapper	\N	e55a584b-391b-4628-a522-15f7b2b187db
45671cf6-36fe-4f99-bb43-83e491753c04	auth_time	openid-connect	oidc-usersessionmodel-note-mapper	\N	35b9a1a5-6273-43b1-bf48-ac59fb6cd402
17795090-6868-4bb6-945c-dba238201def	sub	openid-connect	oidc-sub-mapper	\N	35b9a1a5-6273-43b1-bf48-ac59fb6cd402
fd4f930d-acbf-48e1-a32e-c2a3ec69d8a2	Client ID	openid-connect	oidc-usersessionmodel-note-mapper	\N	15816c28-89d5-40fc-a899-16bacdb8fd3b
c92855d4-a9cf-4b41-a94d-ad9b3ca1a03e	Client Host	openid-connect	oidc-usersessionmodel-note-mapper	\N	15816c28-89d5-40fc-a899-16bacdb8fd3b
ada8bb92-20b2-41ff-b47a-f015362344e4	Client IP Address	openid-connect	oidc-usersessionmodel-note-mapper	\N	15816c28-89d5-40fc-a899-16bacdb8fd3b
a85a1cf1-7fb4-4e81-be93-67564ec8cded	organization	openid-connect	oidc-organization-membership-mapper	\N	7d1230fa-0c3a-4e75-b5fc-a2c6a5309350
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	locale	openid-connect	oidc-usermodel-attribute-mapper	059cc72c-80f8-4975-999d-064aab6c33cb	\N
f20a5ead-d7e1-47c9-a94f-42484198840d	id	openid-connect	oidc-usermodel-property-mapper	96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	\N
fc4a382d-397e-4c7b-9df4-3c5be4723e11	username	openid-connect	oidc-usermodel-property-mapper	96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	\N
9d7e24ac-18ef-4fae-a052-4fbc22f2bae0	email	openid-connect	oidc-usermodel-property-mapper	96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	\N
\.


--
-- Data for Name: protocol_mapper_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.protocol_mapper_config (protocol_mapper_id, value, name) FROM stdin;
a24934c4-7ef2-44d7-914d-052b9227a77f	true	introspection.token.claim
a24934c4-7ef2-44d7-914d-052b9227a77f	true	userinfo.token.claim
a24934c4-7ef2-44d7-914d-052b9227a77f	locale	user.attribute
a24934c4-7ef2-44d7-914d-052b9227a77f	true	id.token.claim
a24934c4-7ef2-44d7-914d-052b9227a77f	true	access.token.claim
a24934c4-7ef2-44d7-914d-052b9227a77f	locale	claim.name
a24934c4-7ef2-44d7-914d-052b9227a77f	String	jsonType.label
ffc00b22-9d22-4eaf-b99c-a7a81f2baea6	false	single
ffc00b22-9d22-4eaf-b99c-a7a81f2baea6	Basic	attribute.nameformat
ffc00b22-9d22-4eaf-b99c-a7a81f2baea6	Role	attribute.name
0423690e-5fe2-4426-9adf-10ca91581d3c	true	introspection.token.claim
0423690e-5fe2-4426-9adf-10ca91581d3c	true	userinfo.token.claim
0423690e-5fe2-4426-9adf-10ca91581d3c	birthdate	user.attribute
0423690e-5fe2-4426-9adf-10ca91581d3c	true	id.token.claim
0423690e-5fe2-4426-9adf-10ca91581d3c	true	access.token.claim
0423690e-5fe2-4426-9adf-10ca91581d3c	birthdate	claim.name
0423690e-5fe2-4426-9adf-10ca91581d3c	String	jsonType.label
0922c1c2-d803-4357-b613-428a0660d92c	true	introspection.token.claim
0922c1c2-d803-4357-b613-428a0660d92c	true	userinfo.token.claim
0922c1c2-d803-4357-b613-428a0660d92c	middleName	user.attribute
0922c1c2-d803-4357-b613-428a0660d92c	true	id.token.claim
0922c1c2-d803-4357-b613-428a0660d92c	true	access.token.claim
0922c1c2-d803-4357-b613-428a0660d92c	middle_name	claim.name
0922c1c2-d803-4357-b613-428a0660d92c	String	jsonType.label
28d3ac87-0c46-477f-a992-4735c84c362f	true	introspection.token.claim
28d3ac87-0c46-477f-a992-4735c84c362f	true	userinfo.token.claim
28d3ac87-0c46-477f-a992-4735c84c362f	profile	user.attribute
28d3ac87-0c46-477f-a992-4735c84c362f	true	id.token.claim
28d3ac87-0c46-477f-a992-4735c84c362f	true	access.token.claim
28d3ac87-0c46-477f-a992-4735c84c362f	profile	claim.name
28d3ac87-0c46-477f-a992-4735c84c362f	String	jsonType.label
2d9581c4-d82c-4771-b6cf-0cf273370715	true	introspection.token.claim
2d9581c4-d82c-4771-b6cf-0cf273370715	true	userinfo.token.claim
2d9581c4-d82c-4771-b6cf-0cf273370715	true	id.token.claim
2d9581c4-d82c-4771-b6cf-0cf273370715	true	access.token.claim
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	true	introspection.token.claim
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	true	userinfo.token.claim
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	nickname	user.attribute
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	true	id.token.claim
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	true	access.token.claim
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	nickname	claim.name
5b406ae4-cca8-4d0b-b6bf-ca8bab1a2b64	String	jsonType.label
73ce87c9-5a95-4e68-8924-557deec8d153	true	introspection.token.claim
73ce87c9-5a95-4e68-8924-557deec8d153	true	userinfo.token.claim
73ce87c9-5a95-4e68-8924-557deec8d153	lastName	user.attribute
73ce87c9-5a95-4e68-8924-557deec8d153	true	id.token.claim
73ce87c9-5a95-4e68-8924-557deec8d153	true	access.token.claim
73ce87c9-5a95-4e68-8924-557deec8d153	family_name	claim.name
73ce87c9-5a95-4e68-8924-557deec8d153	String	jsonType.label
aeb283be-4d4f-427a-b62e-5c865dbc679c	true	introspection.token.claim
aeb283be-4d4f-427a-b62e-5c865dbc679c	true	userinfo.token.claim
aeb283be-4d4f-427a-b62e-5c865dbc679c	updatedAt	user.attribute
aeb283be-4d4f-427a-b62e-5c865dbc679c	true	id.token.claim
aeb283be-4d4f-427a-b62e-5c865dbc679c	true	access.token.claim
aeb283be-4d4f-427a-b62e-5c865dbc679c	updated_at	claim.name
aeb283be-4d4f-427a-b62e-5c865dbc679c	long	jsonType.label
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	true	introspection.token.claim
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	true	userinfo.token.claim
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	locale	user.attribute
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	true	id.token.claim
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	true	access.token.claim
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	locale	claim.name
aeb5b7e8-2fe3-4e56-9dcc-f93dacb75be9	String	jsonType.label
c756bcb5-e3b4-4916-9277-f2104190da4f	true	introspection.token.claim
c756bcb5-e3b4-4916-9277-f2104190da4f	true	userinfo.token.claim
c756bcb5-e3b4-4916-9277-f2104190da4f	zoneinfo	user.attribute
c756bcb5-e3b4-4916-9277-f2104190da4f	true	id.token.claim
c756bcb5-e3b4-4916-9277-f2104190da4f	true	access.token.claim
c756bcb5-e3b4-4916-9277-f2104190da4f	zoneinfo	claim.name
c756bcb5-e3b4-4916-9277-f2104190da4f	String	jsonType.label
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	true	introspection.token.claim
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	true	userinfo.token.claim
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	picture	user.attribute
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	true	id.token.claim
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	true	access.token.claim
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	picture	claim.name
cd55975f-00bd-4bf1-bbc1-0e0d3a957b00	String	jsonType.label
d1765df9-34de-4427-afac-eda0ef6e832f	true	introspection.token.claim
d1765df9-34de-4427-afac-eda0ef6e832f	true	userinfo.token.claim
d1765df9-34de-4427-afac-eda0ef6e832f	gender	user.attribute
d1765df9-34de-4427-afac-eda0ef6e832f	true	id.token.claim
d1765df9-34de-4427-afac-eda0ef6e832f	true	access.token.claim
d1765df9-34de-4427-afac-eda0ef6e832f	gender	claim.name
d1765df9-34de-4427-afac-eda0ef6e832f	String	jsonType.label
d4d74b04-6ac3-467d-b523-7aab59118fb7	true	introspection.token.claim
d4d74b04-6ac3-467d-b523-7aab59118fb7	true	userinfo.token.claim
d4d74b04-6ac3-467d-b523-7aab59118fb7	username	user.attribute
d4d74b04-6ac3-467d-b523-7aab59118fb7	true	id.token.claim
d4d74b04-6ac3-467d-b523-7aab59118fb7	true	access.token.claim
d4d74b04-6ac3-467d-b523-7aab59118fb7	preferred_username	claim.name
d4d74b04-6ac3-467d-b523-7aab59118fb7	String	jsonType.label
ef85f4b0-1035-4782-b691-67e9674aef98	true	introspection.token.claim
ef85f4b0-1035-4782-b691-67e9674aef98	true	userinfo.token.claim
ef85f4b0-1035-4782-b691-67e9674aef98	website	user.attribute
ef85f4b0-1035-4782-b691-67e9674aef98	true	id.token.claim
ef85f4b0-1035-4782-b691-67e9674aef98	true	access.token.claim
ef85f4b0-1035-4782-b691-67e9674aef98	website	claim.name
ef85f4b0-1035-4782-b691-67e9674aef98	String	jsonType.label
f86d69bb-2733-45b2-b0ff-ef252c76e651	true	introspection.token.claim
f86d69bb-2733-45b2-b0ff-ef252c76e651	true	userinfo.token.claim
f86d69bb-2733-45b2-b0ff-ef252c76e651	firstName	user.attribute
f86d69bb-2733-45b2-b0ff-ef252c76e651	true	id.token.claim
f86d69bb-2733-45b2-b0ff-ef252c76e651	true	access.token.claim
f86d69bb-2733-45b2-b0ff-ef252c76e651	given_name	claim.name
f86d69bb-2733-45b2-b0ff-ef252c76e651	String	jsonType.label
80040831-ba68-44a4-99db-29cc7e92e8f1	true	introspection.token.claim
80040831-ba68-44a4-99db-29cc7e92e8f1	true	userinfo.token.claim
80040831-ba68-44a4-99db-29cc7e92e8f1	email	user.attribute
80040831-ba68-44a4-99db-29cc7e92e8f1	true	id.token.claim
80040831-ba68-44a4-99db-29cc7e92e8f1	true	access.token.claim
80040831-ba68-44a4-99db-29cc7e92e8f1	email	claim.name
80040831-ba68-44a4-99db-29cc7e92e8f1	String	jsonType.label
942e1dfd-8a6d-4b41-bc40-44b1db745f66	true	introspection.token.claim
942e1dfd-8a6d-4b41-bc40-44b1db745f66	true	userinfo.token.claim
942e1dfd-8a6d-4b41-bc40-44b1db745f66	emailVerified	user.attribute
942e1dfd-8a6d-4b41-bc40-44b1db745f66	true	id.token.claim
942e1dfd-8a6d-4b41-bc40-44b1db745f66	true	access.token.claim
942e1dfd-8a6d-4b41-bc40-44b1db745f66	email_verified	claim.name
942e1dfd-8a6d-4b41-bc40-44b1db745f66	boolean	jsonType.label
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	formatted	user.attribute.formatted
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	country	user.attribute.country
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	true	introspection.token.claim
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	postal_code	user.attribute.postal_code
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	true	userinfo.token.claim
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	street	user.attribute.street
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	true	id.token.claim
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	region	user.attribute.region
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	true	access.token.claim
acc5ab70-dc95-4a6d-9cd3-61fa380395a4	locality	user.attribute.locality
0921e820-3658-48ee-bd01-53765df1ea96	true	introspection.token.claim
0921e820-3658-48ee-bd01-53765df1ea96	true	userinfo.token.claim
0921e820-3658-48ee-bd01-53765df1ea96	phoneNumberVerified	user.attribute
0921e820-3658-48ee-bd01-53765df1ea96	true	id.token.claim
0921e820-3658-48ee-bd01-53765df1ea96	true	access.token.claim
0921e820-3658-48ee-bd01-53765df1ea96	phone_number_verified	claim.name
0921e820-3658-48ee-bd01-53765df1ea96	boolean	jsonType.label
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	true	introspection.token.claim
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	true	userinfo.token.claim
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	phoneNumber	user.attribute
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	true	id.token.claim
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	true	access.token.claim
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	phone_number	claim.name
6fbba7c8-ecc5-4b0e-bd2f-d9addfd73760	String	jsonType.label
07df2164-3ea5-46a1-b011-22137bc935b1	true	introspection.token.claim
07df2164-3ea5-46a1-b011-22137bc935b1	true	multivalued
07df2164-3ea5-46a1-b011-22137bc935b1	foo	user.attribute
07df2164-3ea5-46a1-b011-22137bc935b1	true	access.token.claim
07df2164-3ea5-46a1-b011-22137bc935b1	realm_access.roles	claim.name
07df2164-3ea5-46a1-b011-22137bc935b1	String	jsonType.label
675ccfd3-f679-4178-9d3f-350b1a6c694a	true	introspection.token.claim
675ccfd3-f679-4178-9d3f-350b1a6c694a	true	multivalued
675ccfd3-f679-4178-9d3f-350b1a6c694a	foo	user.attribute
675ccfd3-f679-4178-9d3f-350b1a6c694a	true	access.token.claim
675ccfd3-f679-4178-9d3f-350b1a6c694a	resource_access.${client_id}.roles	claim.name
675ccfd3-f679-4178-9d3f-350b1a6c694a	String	jsonType.label
d18d52a5-fd9d-457d-bf34-73e1d8128067	true	introspection.token.claim
d18d52a5-fd9d-457d-bf34-73e1d8128067	true	access.token.claim
16e4eeac-d29b-46f1-8987-efd042af51b1	true	introspection.token.claim
16e4eeac-d29b-46f1-8987-efd042af51b1	true	access.token.claim
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	true	introspection.token.claim
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	true	multivalued
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	foo	user.attribute
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	true	id.token.claim
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	true	access.token.claim
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	groups	claim.name
1a9389c4-eca3-4d2b-8c4f-194ee9104dee	String	jsonType.label
1f8e2b47-a8b9-4914-b70d-5d4af095511f	true	introspection.token.claim
1f8e2b47-a8b9-4914-b70d-5d4af095511f	true	userinfo.token.claim
1f8e2b47-a8b9-4914-b70d-5d4af095511f	username	user.attribute
1f8e2b47-a8b9-4914-b70d-5d4af095511f	true	id.token.claim
1f8e2b47-a8b9-4914-b70d-5d4af095511f	true	access.token.claim
1f8e2b47-a8b9-4914-b70d-5d4af095511f	upn	claim.name
1f8e2b47-a8b9-4914-b70d-5d4af095511f	String	jsonType.label
81cf3bf9-e9ce-4a9d-a1f3-404417939e71	true	introspection.token.claim
81cf3bf9-e9ce-4a9d-a1f3-404417939e71	true	id.token.claim
81cf3bf9-e9ce-4a9d-a1f3-404417939e71	true	access.token.claim
0d0938fc-8e1d-41e0-b9b4-9149c7ebc836	true	introspection.token.claim
0d0938fc-8e1d-41e0-b9b4-9149c7ebc836	true	access.token.claim
a565bc8f-e254-4c80-b22d-6d89b01d6933	AUTH_TIME	user.session.note
a565bc8f-e254-4c80-b22d-6d89b01d6933	true	introspection.token.claim
a565bc8f-e254-4c80-b22d-6d89b01d6933	true	id.token.claim
a565bc8f-e254-4c80-b22d-6d89b01d6933	true	access.token.claim
a565bc8f-e254-4c80-b22d-6d89b01d6933	auth_time	claim.name
a565bc8f-e254-4c80-b22d-6d89b01d6933	long	jsonType.label
0d73a758-6eed-4d9a-abb0-d16418ddb0c6	client_id	user.session.note
0d73a758-6eed-4d9a-abb0-d16418ddb0c6	true	introspection.token.claim
0d73a758-6eed-4d9a-abb0-d16418ddb0c6	true	id.token.claim
0d73a758-6eed-4d9a-abb0-d16418ddb0c6	true	access.token.claim
0d73a758-6eed-4d9a-abb0-d16418ddb0c6	client_id	claim.name
0d73a758-6eed-4d9a-abb0-d16418ddb0c6	String	jsonType.label
4091810e-3342-4787-b39e-6850f0acad51	clientHost	user.session.note
4091810e-3342-4787-b39e-6850f0acad51	true	introspection.token.claim
4091810e-3342-4787-b39e-6850f0acad51	true	id.token.claim
4091810e-3342-4787-b39e-6850f0acad51	true	access.token.claim
4091810e-3342-4787-b39e-6850f0acad51	clientHost	claim.name
4091810e-3342-4787-b39e-6850f0acad51	String	jsonType.label
7c7a6ccd-8588-4481-812f-cf062ad2c3a9	clientAddress	user.session.note
7c7a6ccd-8588-4481-812f-cf062ad2c3a9	true	introspection.token.claim
7c7a6ccd-8588-4481-812f-cf062ad2c3a9	true	id.token.claim
7c7a6ccd-8588-4481-812f-cf062ad2c3a9	true	access.token.claim
7c7a6ccd-8588-4481-812f-cf062ad2c3a9	clientAddress	claim.name
7c7a6ccd-8588-4481-812f-cf062ad2c3a9	String	jsonType.label
edd12a1f-8b57-4f86-b40b-71e78b1f5f78	true	introspection.token.claim
edd12a1f-8b57-4f86-b40b-71e78b1f5f78	true	multivalued
edd12a1f-8b57-4f86-b40b-71e78b1f5f78	true	id.token.claim
edd12a1f-8b57-4f86-b40b-71e78b1f5f78	true	access.token.claim
edd12a1f-8b57-4f86-b40b-71e78b1f5f78	organization	claim.name
edd12a1f-8b57-4f86-b40b-71e78b1f5f78	String	jsonType.label
eb4deff1-d36e-421b-8175-a3759b1c4bb3	false	single
eb4deff1-d36e-421b-8175-a3759b1c4bb3	Basic	attribute.nameformat
eb4deff1-d36e-421b-8175-a3759b1c4bb3	Role	attribute.name
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	true	introspection.token.claim
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	true	userinfo.token.claim
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	lastName	user.attribute
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	true	id.token.claim
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	true	access.token.claim
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	family_name	claim.name
442ecddd-ed3f-431e-9bbc-9c5a3d7e7042	String	jsonType.label
47d1f5be-4669-4bb0-82ed-fe51655bc51b	true	introspection.token.claim
47d1f5be-4669-4bb0-82ed-fe51655bc51b	true	userinfo.token.claim
47d1f5be-4669-4bb0-82ed-fe51655bc51b	true	id.token.claim
47d1f5be-4669-4bb0-82ed-fe51655bc51b	true	access.token.claim
507b271a-8c24-4a86-a9f4-0175a3c5930a	true	introspection.token.claim
507b271a-8c24-4a86-a9f4-0175a3c5930a	true	userinfo.token.claim
507b271a-8c24-4a86-a9f4-0175a3c5930a	gender	user.attribute
507b271a-8c24-4a86-a9f4-0175a3c5930a	true	id.token.claim
507b271a-8c24-4a86-a9f4-0175a3c5930a	true	access.token.claim
507b271a-8c24-4a86-a9f4-0175a3c5930a	gender	claim.name
507b271a-8c24-4a86-a9f4-0175a3c5930a	String	jsonType.label
53cbe971-2a7c-4770-9693-78d3967123ab	true	introspection.token.claim
53cbe971-2a7c-4770-9693-78d3967123ab	true	userinfo.token.claim
53cbe971-2a7c-4770-9693-78d3967123ab	zoneinfo	user.attribute
53cbe971-2a7c-4770-9693-78d3967123ab	true	id.token.claim
53cbe971-2a7c-4770-9693-78d3967123ab	true	access.token.claim
53cbe971-2a7c-4770-9693-78d3967123ab	zoneinfo	claim.name
53cbe971-2a7c-4770-9693-78d3967123ab	String	jsonType.label
5bcf33e9-ee12-419e-9895-6e0b882d1804	true	introspection.token.claim
5bcf33e9-ee12-419e-9895-6e0b882d1804	true	userinfo.token.claim
5bcf33e9-ee12-419e-9895-6e0b882d1804	profile	user.attribute
5bcf33e9-ee12-419e-9895-6e0b882d1804	true	id.token.claim
5bcf33e9-ee12-419e-9895-6e0b882d1804	true	access.token.claim
5bcf33e9-ee12-419e-9895-6e0b882d1804	profile	claim.name
5bcf33e9-ee12-419e-9895-6e0b882d1804	String	jsonType.label
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	true	introspection.token.claim
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	true	userinfo.token.claim
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	middleName	user.attribute
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	true	id.token.claim
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	true	access.token.claim
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	middle_name	claim.name
92c0067d-3a35-4bc0-960c-a7aee1ecb2d8	String	jsonType.label
92cc6a6b-d14f-4349-8526-914ec9b56b1c	true	introspection.token.claim
92cc6a6b-d14f-4349-8526-914ec9b56b1c	true	userinfo.token.claim
92cc6a6b-d14f-4349-8526-914ec9b56b1c	nickname	user.attribute
92cc6a6b-d14f-4349-8526-914ec9b56b1c	true	id.token.claim
92cc6a6b-d14f-4349-8526-914ec9b56b1c	true	access.token.claim
92cc6a6b-d14f-4349-8526-914ec9b56b1c	nickname	claim.name
92cc6a6b-d14f-4349-8526-914ec9b56b1c	String	jsonType.label
a258a62a-c4c7-4ab6-8571-e5c695a7c422	true	introspection.token.claim
a258a62a-c4c7-4ab6-8571-e5c695a7c422	true	userinfo.token.claim
a258a62a-c4c7-4ab6-8571-e5c695a7c422	updatedAt	user.attribute
a258a62a-c4c7-4ab6-8571-e5c695a7c422	true	id.token.claim
a258a62a-c4c7-4ab6-8571-e5c695a7c422	true	access.token.claim
a258a62a-c4c7-4ab6-8571-e5c695a7c422	updated_at	claim.name
a258a62a-c4c7-4ab6-8571-e5c695a7c422	long	jsonType.label
ac80cd49-73a2-412d-a880-f859a9a041b8	true	introspection.token.claim
ac80cd49-73a2-412d-a880-f859a9a041b8	true	userinfo.token.claim
ac80cd49-73a2-412d-a880-f859a9a041b8	picture	user.attribute
ac80cd49-73a2-412d-a880-f859a9a041b8	true	id.token.claim
ac80cd49-73a2-412d-a880-f859a9a041b8	true	access.token.claim
ac80cd49-73a2-412d-a880-f859a9a041b8	picture	claim.name
ac80cd49-73a2-412d-a880-f859a9a041b8	String	jsonType.label
b8236475-fb5c-45d5-9445-eff4769218b2	true	introspection.token.claim
b8236475-fb5c-45d5-9445-eff4769218b2	true	userinfo.token.claim
b8236475-fb5c-45d5-9445-eff4769218b2	firstName	user.attribute
b8236475-fb5c-45d5-9445-eff4769218b2	true	id.token.claim
b8236475-fb5c-45d5-9445-eff4769218b2	true	access.token.claim
b8236475-fb5c-45d5-9445-eff4769218b2	given_name	claim.name
b8236475-fb5c-45d5-9445-eff4769218b2	String	jsonType.label
bee36369-f3f5-4da3-b55f-6c7aea05c514	true	introspection.token.claim
bee36369-f3f5-4da3-b55f-6c7aea05c514	true	userinfo.token.claim
bee36369-f3f5-4da3-b55f-6c7aea05c514	birthdate	user.attribute
bee36369-f3f5-4da3-b55f-6c7aea05c514	true	id.token.claim
bee36369-f3f5-4da3-b55f-6c7aea05c514	true	access.token.claim
bee36369-f3f5-4da3-b55f-6c7aea05c514	birthdate	claim.name
bee36369-f3f5-4da3-b55f-6c7aea05c514	String	jsonType.label
c95e9b72-8f6d-485c-9179-d78d74647a8d	true	introspection.token.claim
c95e9b72-8f6d-485c-9179-d78d74647a8d	true	userinfo.token.claim
c95e9b72-8f6d-485c-9179-d78d74647a8d	username	user.attribute
c95e9b72-8f6d-485c-9179-d78d74647a8d	true	id.token.claim
c95e9b72-8f6d-485c-9179-d78d74647a8d	true	access.token.claim
c95e9b72-8f6d-485c-9179-d78d74647a8d	preferred_username	claim.name
c95e9b72-8f6d-485c-9179-d78d74647a8d	String	jsonType.label
cd8595f3-8235-42d0-8601-61d64f8e41c4	true	introspection.token.claim
cd8595f3-8235-42d0-8601-61d64f8e41c4	true	userinfo.token.claim
cd8595f3-8235-42d0-8601-61d64f8e41c4	locale	user.attribute
cd8595f3-8235-42d0-8601-61d64f8e41c4	true	id.token.claim
cd8595f3-8235-42d0-8601-61d64f8e41c4	true	access.token.claim
cd8595f3-8235-42d0-8601-61d64f8e41c4	locale	claim.name
cd8595f3-8235-42d0-8601-61d64f8e41c4	String	jsonType.label
f92b3dca-5572-4427-8610-2292d16a8afc	true	introspection.token.claim
f92b3dca-5572-4427-8610-2292d16a8afc	true	userinfo.token.claim
f92b3dca-5572-4427-8610-2292d16a8afc	website	user.attribute
f92b3dca-5572-4427-8610-2292d16a8afc	true	id.token.claim
f92b3dca-5572-4427-8610-2292d16a8afc	true	access.token.claim
f92b3dca-5572-4427-8610-2292d16a8afc	website	claim.name
f92b3dca-5572-4427-8610-2292d16a8afc	String	jsonType.label
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	true	introspection.token.claim
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	true	userinfo.token.claim
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	emailVerified	user.attribute
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	true	id.token.claim
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	true	access.token.claim
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	email_verified	claim.name
4682a5e2-04e0-47ea-872c-6c1ec5ce3caa	boolean	jsonType.label
70918083-988e-46a6-9601-1f285037d2bb	true	introspection.token.claim
70918083-988e-46a6-9601-1f285037d2bb	true	userinfo.token.claim
70918083-988e-46a6-9601-1f285037d2bb	email	user.attribute
70918083-988e-46a6-9601-1f285037d2bb	true	id.token.claim
70918083-988e-46a6-9601-1f285037d2bb	true	access.token.claim
70918083-988e-46a6-9601-1f285037d2bb	email	claim.name
70918083-988e-46a6-9601-1f285037d2bb	String	jsonType.label
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	formatted	user.attribute.formatted
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	country	user.attribute.country
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	true	introspection.token.claim
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	postal_code	user.attribute.postal_code
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	true	userinfo.token.claim
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	street	user.attribute.street
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	true	id.token.claim
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	region	user.attribute.region
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	true	access.token.claim
d6a9ce01-2a9e-483e-9a2f-db7b1b15a06c	locality	user.attribute.locality
03916088-f0c4-46fd-8259-4e275d0df635	true	introspection.token.claim
03916088-f0c4-46fd-8259-4e275d0df635	true	userinfo.token.claim
03916088-f0c4-46fd-8259-4e275d0df635	phoneNumberVerified	user.attribute
03916088-f0c4-46fd-8259-4e275d0df635	true	id.token.claim
03916088-f0c4-46fd-8259-4e275d0df635	true	access.token.claim
03916088-f0c4-46fd-8259-4e275d0df635	phone_number_verified	claim.name
03916088-f0c4-46fd-8259-4e275d0df635	boolean	jsonType.label
20c2e59c-18e8-4b94-8d05-adff02a45fa5	true	introspection.token.claim
20c2e59c-18e8-4b94-8d05-adff02a45fa5	true	userinfo.token.claim
20c2e59c-18e8-4b94-8d05-adff02a45fa5	phoneNumber	user.attribute
20c2e59c-18e8-4b94-8d05-adff02a45fa5	true	id.token.claim
20c2e59c-18e8-4b94-8d05-adff02a45fa5	true	access.token.claim
20c2e59c-18e8-4b94-8d05-adff02a45fa5	phone_number	claim.name
20c2e59c-18e8-4b94-8d05-adff02a45fa5	String	jsonType.label
14be3d83-94b4-4a89-b2d4-207314e30664	true	introspection.token.claim
14be3d83-94b4-4a89-b2d4-207314e30664	true	access.token.claim
54093d51-39f2-4cfd-91a8-d86042647624	true	introspection.token.claim
54093d51-39f2-4cfd-91a8-d86042647624	true	multivalued
54093d51-39f2-4cfd-91a8-d86042647624	foo	user.attribute
54093d51-39f2-4cfd-91a8-d86042647624	true	access.token.claim
54093d51-39f2-4cfd-91a8-d86042647624	realm_access.roles	claim.name
54093d51-39f2-4cfd-91a8-d86042647624	String	jsonType.label
84b8fd37-9b1d-4671-858b-24c216056e6b	true	introspection.token.claim
84b8fd37-9b1d-4671-858b-24c216056e6b	true	multivalued
84b8fd37-9b1d-4671-858b-24c216056e6b	foo	user.attribute
84b8fd37-9b1d-4671-858b-24c216056e6b	true	access.token.claim
84b8fd37-9b1d-4671-858b-24c216056e6b	resource_access.${client_id}.roles	claim.name
84b8fd37-9b1d-4671-858b-24c216056e6b	String	jsonType.label
4cd2585f-4930-4892-b79a-27debafb4414	true	introspection.token.claim
4cd2585f-4930-4892-b79a-27debafb4414	true	access.token.claim
3df0d527-3bc0-4813-8355-e78f5eceaa39	true	introspection.token.claim
3df0d527-3bc0-4813-8355-e78f5eceaa39	true	userinfo.token.claim
3df0d527-3bc0-4813-8355-e78f5eceaa39	username	user.attribute
3df0d527-3bc0-4813-8355-e78f5eceaa39	true	id.token.claim
3df0d527-3bc0-4813-8355-e78f5eceaa39	true	access.token.claim
3df0d527-3bc0-4813-8355-e78f5eceaa39	upn	claim.name
3df0d527-3bc0-4813-8355-e78f5eceaa39	String	jsonType.label
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	true	introspection.token.claim
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	true	multivalued
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	foo	user.attribute
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	true	id.token.claim
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	true	access.token.claim
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	groups	claim.name
f88e4628-c9ab-4a73-98a4-d7381d5ddef8	String	jsonType.label
4ebe049b-7694-47b7-b331-7447e53ff2ea	true	introspection.token.claim
4ebe049b-7694-47b7-b331-7447e53ff2ea	true	id.token.claim
4ebe049b-7694-47b7-b331-7447e53ff2ea	true	access.token.claim
17795090-6868-4bb6-945c-dba238201def	true	introspection.token.claim
17795090-6868-4bb6-945c-dba238201def	true	access.token.claim
45671cf6-36fe-4f99-bb43-83e491753c04	AUTH_TIME	user.session.note
45671cf6-36fe-4f99-bb43-83e491753c04	true	introspection.token.claim
45671cf6-36fe-4f99-bb43-83e491753c04	true	id.token.claim
45671cf6-36fe-4f99-bb43-83e491753c04	true	access.token.claim
45671cf6-36fe-4f99-bb43-83e491753c04	auth_time	claim.name
45671cf6-36fe-4f99-bb43-83e491753c04	long	jsonType.label
ada8bb92-20b2-41ff-b47a-f015362344e4	clientAddress	user.session.note
ada8bb92-20b2-41ff-b47a-f015362344e4	true	introspection.token.claim
ada8bb92-20b2-41ff-b47a-f015362344e4	true	id.token.claim
ada8bb92-20b2-41ff-b47a-f015362344e4	true	access.token.claim
ada8bb92-20b2-41ff-b47a-f015362344e4	clientAddress	claim.name
ada8bb92-20b2-41ff-b47a-f015362344e4	String	jsonType.label
c92855d4-a9cf-4b41-a94d-ad9b3ca1a03e	clientHost	user.session.note
c92855d4-a9cf-4b41-a94d-ad9b3ca1a03e	true	introspection.token.claim
c92855d4-a9cf-4b41-a94d-ad9b3ca1a03e	true	id.token.claim
c92855d4-a9cf-4b41-a94d-ad9b3ca1a03e	true	access.token.claim
c92855d4-a9cf-4b41-a94d-ad9b3ca1a03e	clientHost	claim.name
c92855d4-a9cf-4b41-a94d-ad9b3ca1a03e	String	jsonType.label
fd4f930d-acbf-48e1-a32e-c2a3ec69d8a2	client_id	user.session.note
fd4f930d-acbf-48e1-a32e-c2a3ec69d8a2	true	introspection.token.claim
fd4f930d-acbf-48e1-a32e-c2a3ec69d8a2	true	id.token.claim
fd4f930d-acbf-48e1-a32e-c2a3ec69d8a2	true	access.token.claim
fd4f930d-acbf-48e1-a32e-c2a3ec69d8a2	client_id	claim.name
fd4f930d-acbf-48e1-a32e-c2a3ec69d8a2	String	jsonType.label
a85a1cf1-7fb4-4e81-be93-67564ec8cded	true	introspection.token.claim
a85a1cf1-7fb4-4e81-be93-67564ec8cded	true	multivalued
a85a1cf1-7fb4-4e81-be93-67564ec8cded	true	id.token.claim
a85a1cf1-7fb4-4e81-be93-67564ec8cded	true	access.token.claim
a85a1cf1-7fb4-4e81-be93-67564ec8cded	organization	claim.name
a85a1cf1-7fb4-4e81-be93-67564ec8cded	String	jsonType.label
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	true	introspection.token.claim
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	true	userinfo.token.claim
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	locale	user.attribute
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	true	id.token.claim
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	true	access.token.claim
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	locale	claim.name
a3a132de-b1b9-4a13-8fb5-1ad05e2cd090	String	jsonType.label
f20a5ead-d7e1-47c9-a94f-42484198840d	id	user.attribute
f20a5ead-d7e1-47c9-a94f-42484198840d	true	id.token.claim
f20a5ead-d7e1-47c9-a94f-42484198840d	true	access.token.claim
f20a5ead-d7e1-47c9-a94f-42484198840d	id	claim.name
f20a5ead-d7e1-47c9-a94f-42484198840d	String	jsonType.label
f20a5ead-d7e1-47c9-a94f-42484198840d	true	userinfo.token.claim
fc4a382d-397e-4c7b-9df4-3c5be4723e11	username	user.attribute
fc4a382d-397e-4c7b-9df4-3c5be4723e11	true	id.token.claim
fc4a382d-397e-4c7b-9df4-3c5be4723e11	true	access.token.claim
fc4a382d-397e-4c7b-9df4-3c5be4723e11	username	claim.name
fc4a382d-397e-4c7b-9df4-3c5be4723e11	String	jsonType.label
fc4a382d-397e-4c7b-9df4-3c5be4723e11	true	userinfo.token.claim
9d7e24ac-18ef-4fae-a052-4fbc22f2bae0	email	user.attribute
9d7e24ac-18ef-4fae-a052-4fbc22f2bae0	true	id.token.claim
9d7e24ac-18ef-4fae-a052-4fbc22f2bae0	true	access.token.claim
9d7e24ac-18ef-4fae-a052-4fbc22f2bae0	email	claim.name
9d7e24ac-18ef-4fae-a052-4fbc22f2bae0	String	jsonType.label
9d7e24ac-18ef-4fae-a052-4fbc22f2bae0	true	userinfo.token.claim
\.


--
-- Data for Name: realm; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm (id, access_code_lifespan, user_action_lifespan, access_token_lifespan, account_theme, admin_theme, email_theme, enabled, events_enabled, events_expiration, login_theme, name, not_before, password_policy, registration_allowed, remember_me, reset_password_allowed, social, ssl_required, sso_idle_timeout, sso_max_lifespan, update_profile_on_soc_login, verify_email, master_admin_client, login_lifespan, internationalization_enabled, default_locale, reg_email_as_username, admin_events_enabled, admin_events_details_enabled, edit_username_allowed, otp_policy_counter, otp_policy_window, otp_policy_period, otp_policy_digits, otp_policy_alg, otp_policy_type, browser_flow, registration_flow, direct_grant_flow, reset_credentials_flow, client_auth_flow, offline_session_idle_timeout, revoke_refresh_token, access_token_life_implicit, login_with_email_allowed, duplicate_emails_allowed, docker_auth_flow, refresh_token_max_reuse, allow_user_managed_access, sso_max_lifespan_remember_me, sso_idle_timeout_remember_me, default_role) FROM stdin;
173713f9-5e66-4a52-87f5-eff68df04cdc	60	300	60	\N	\N	\N	t	f	0	\N	master	0	\N	f	f	f	f	NONE	1800	36000	f	f	10beb14c-91d9-482f-aa9d-1b80b6c5c0b6	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	10b78065-d497-46b3-9462-4dbbeee28183	732c38eb-0080-42da-b7e2-936f64b67fb7	ae639f6f-9b0f-4b00-8f72-5bba680d93ea	65566feb-7989-4d69-b58e-b3f099b2a480	ebdb190f-7059-4ff0-8961-0e92d75b160f	2592000	f	900	t	f	3718a866-6fc4-43c0-8d90-793e1b4088bb	0	f	0	0	66d3306f-d865-460b-81d2-7e04f93c580e
a7442214-2630-4991-aa3c-a2f06c383451	60	300	300	\N	\N	\N	t	f	0	\N	but-tc	0	\N	f	f	f	f	NONE	1800	36000	f	f	d36f320f-d82b-4cc2-82f7-1c8e0bd3bf56	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	b36ffeb7-3468-42ec-88b3-6241d6a0fe28	593dddc8-ba1b-4124-8bae-40f96cc8731e	58425c44-98bd-4245-b744-1c32f7694a72	11b0e8b6-db74-4700-9a4a-f91b42073d78	aa9110e2-b21e-4481-8862-a4548e3c690e	2592000	f	900	t	f	7644ea7c-29fd-43aa-9f51-9c66d7224b7c	0	f	0	0	ff564a8b-5033-49f8-83bc-2ba22a8d5bbb
\.


--
-- Data for Name: realm_attribute; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_attribute (name, realm_id, value) FROM stdin;
_browser_header.contentSecurityPolicyReportOnly	173713f9-5e66-4a52-87f5-eff68df04cdc	
_browser_header.xContentTypeOptions	173713f9-5e66-4a52-87f5-eff68df04cdc	nosniff
_browser_header.referrerPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	no-referrer
_browser_header.xRobotsTag	173713f9-5e66-4a52-87f5-eff68df04cdc	none
_browser_header.xFrameOptions	173713f9-5e66-4a52-87f5-eff68df04cdc	SAMEORIGIN
_browser_header.contentSecurityPolicy	173713f9-5e66-4a52-87f5-eff68df04cdc	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
_browser_header.strictTransportSecurity	173713f9-5e66-4a52-87f5-eff68df04cdc	max-age=31536000; includeSubDomains
bruteForceProtected	173713f9-5e66-4a52-87f5-eff68df04cdc	false
permanentLockout	173713f9-5e66-4a52-87f5-eff68df04cdc	false
maxTemporaryLockouts	173713f9-5e66-4a52-87f5-eff68df04cdc	0
bruteForceStrategy	173713f9-5e66-4a52-87f5-eff68df04cdc	MULTIPLE
maxFailureWaitSeconds	173713f9-5e66-4a52-87f5-eff68df04cdc	900
minimumQuickLoginWaitSeconds	173713f9-5e66-4a52-87f5-eff68df04cdc	60
waitIncrementSeconds	173713f9-5e66-4a52-87f5-eff68df04cdc	60
quickLoginCheckMilliSeconds	173713f9-5e66-4a52-87f5-eff68df04cdc	1000
maxDeltaTimeSeconds	173713f9-5e66-4a52-87f5-eff68df04cdc	43200
failureFactor	173713f9-5e66-4a52-87f5-eff68df04cdc	30
realmReusableOtpCode	173713f9-5e66-4a52-87f5-eff68df04cdc	false
firstBrokerLoginFlowId	173713f9-5e66-4a52-87f5-eff68df04cdc	6842ad4f-43b7-49cf-8992-bced308e206a
displayName	173713f9-5e66-4a52-87f5-eff68df04cdc	Keycloak
displayNameHtml	173713f9-5e66-4a52-87f5-eff68df04cdc	<div class="kc-logo-text"><span>Keycloak</span></div>
defaultSignatureAlgorithm	173713f9-5e66-4a52-87f5-eff68df04cdc	RS256
offlineSessionMaxLifespanEnabled	173713f9-5e66-4a52-87f5-eff68df04cdc	false
offlineSessionMaxLifespan	173713f9-5e66-4a52-87f5-eff68df04cdc	5184000
_browser_header.contentSecurityPolicyReportOnly	a7442214-2630-4991-aa3c-a2f06c383451	
_browser_header.xContentTypeOptions	a7442214-2630-4991-aa3c-a2f06c383451	nosniff
_browser_header.referrerPolicy	a7442214-2630-4991-aa3c-a2f06c383451	no-referrer
_browser_header.xRobotsTag	a7442214-2630-4991-aa3c-a2f06c383451	none
_browser_header.xFrameOptions	a7442214-2630-4991-aa3c-a2f06c383451	SAMEORIGIN
_browser_header.contentSecurityPolicy	a7442214-2630-4991-aa3c-a2f06c383451	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
_browser_header.strictTransportSecurity	a7442214-2630-4991-aa3c-a2f06c383451	max-age=31536000; includeSubDomains
bruteForceProtected	a7442214-2630-4991-aa3c-a2f06c383451	false
permanentLockout	a7442214-2630-4991-aa3c-a2f06c383451	false
maxTemporaryLockouts	a7442214-2630-4991-aa3c-a2f06c383451	0
bruteForceStrategy	a7442214-2630-4991-aa3c-a2f06c383451	MULTIPLE
maxFailureWaitSeconds	a7442214-2630-4991-aa3c-a2f06c383451	900
minimumQuickLoginWaitSeconds	a7442214-2630-4991-aa3c-a2f06c383451	60
waitIncrementSeconds	a7442214-2630-4991-aa3c-a2f06c383451	60
quickLoginCheckMilliSeconds	a7442214-2630-4991-aa3c-a2f06c383451	1000
maxDeltaTimeSeconds	a7442214-2630-4991-aa3c-a2f06c383451	43200
failureFactor	a7442214-2630-4991-aa3c-a2f06c383451	30
realmReusableOtpCode	a7442214-2630-4991-aa3c-a2f06c383451	false
defaultSignatureAlgorithm	a7442214-2630-4991-aa3c-a2f06c383451	RS256
offlineSessionMaxLifespanEnabled	a7442214-2630-4991-aa3c-a2f06c383451	false
offlineSessionMaxLifespan	a7442214-2630-4991-aa3c-a2f06c383451	5184000
clientSessionIdleTimeout	a7442214-2630-4991-aa3c-a2f06c383451	0
clientSessionMaxLifespan	a7442214-2630-4991-aa3c-a2f06c383451	0
clientOfflineSessionIdleTimeout	a7442214-2630-4991-aa3c-a2f06c383451	0
clientOfflineSessionMaxLifespan	a7442214-2630-4991-aa3c-a2f06c383451	0
actionTokenGeneratedByAdminLifespan	a7442214-2630-4991-aa3c-a2f06c383451	43200
actionTokenGeneratedByUserLifespan	a7442214-2630-4991-aa3c-a2f06c383451	300
oauth2DeviceCodeLifespan	a7442214-2630-4991-aa3c-a2f06c383451	600
oauth2DevicePollingInterval	a7442214-2630-4991-aa3c-a2f06c383451	5
organizationsEnabled	a7442214-2630-4991-aa3c-a2f06c383451	false
adminPermissionsEnabled	a7442214-2630-4991-aa3c-a2f06c383451	false
webAuthnPolicyRpEntityName	a7442214-2630-4991-aa3c-a2f06c383451	keycloak
webAuthnPolicySignatureAlgorithms	a7442214-2630-4991-aa3c-a2f06c383451	ES256,RS256
webAuthnPolicyRpId	a7442214-2630-4991-aa3c-a2f06c383451	
webAuthnPolicyAttestationConveyancePreference	a7442214-2630-4991-aa3c-a2f06c383451	not specified
webAuthnPolicyAuthenticatorAttachment	a7442214-2630-4991-aa3c-a2f06c383451	not specified
webAuthnPolicyRequireResidentKey	a7442214-2630-4991-aa3c-a2f06c383451	not specified
webAuthnPolicyUserVerificationRequirement	a7442214-2630-4991-aa3c-a2f06c383451	not specified
webAuthnPolicyCreateTimeout	a7442214-2630-4991-aa3c-a2f06c383451	0
webAuthnPolicyAvoidSameAuthenticatorRegister	a7442214-2630-4991-aa3c-a2f06c383451	false
webAuthnPolicyRpEntityNamePasswordless	a7442214-2630-4991-aa3c-a2f06c383451	keycloak
webAuthnPolicySignatureAlgorithmsPasswordless	a7442214-2630-4991-aa3c-a2f06c383451	ES256,RS256
webAuthnPolicyRpIdPasswordless	a7442214-2630-4991-aa3c-a2f06c383451	
webAuthnPolicyAttestationConveyancePreferencePasswordless	a7442214-2630-4991-aa3c-a2f06c383451	not specified
webAuthnPolicyAuthenticatorAttachmentPasswordless	a7442214-2630-4991-aa3c-a2f06c383451	not specified
webAuthnPolicyRequireResidentKeyPasswordless	a7442214-2630-4991-aa3c-a2f06c383451	Yes
webAuthnPolicyUserVerificationRequirementPasswordless	a7442214-2630-4991-aa3c-a2f06c383451	required
webAuthnPolicyCreateTimeoutPasswordless	a7442214-2630-4991-aa3c-a2f06c383451	0
webAuthnPolicyAvoidSameAuthenticatorRegisterPasswordless	a7442214-2630-4991-aa3c-a2f06c383451	false
cibaBackchannelTokenDeliveryMode	a7442214-2630-4991-aa3c-a2f06c383451	poll
cibaExpiresIn	a7442214-2630-4991-aa3c-a2f06c383451	120
cibaInterval	a7442214-2630-4991-aa3c-a2f06c383451	5
cibaAuthRequestedUserHint	a7442214-2630-4991-aa3c-a2f06c383451	login_hint
parRequestUriLifespan	a7442214-2630-4991-aa3c-a2f06c383451	60
firstBrokerLoginFlowId	a7442214-2630-4991-aa3c-a2f06c383451	837daab9-0f0c-4d3f-bfae-ea67d17a663a
verifiableCredentialsEnabled	a7442214-2630-4991-aa3c-a2f06c383451	false
client-policies.profiles	a7442214-2630-4991-aa3c-a2f06c383451	{"profiles":[]}
client-policies.policies	a7442214-2630-4991-aa3c-a2f06c383451	{"policies":[]}
cibaBackchannelTokenDeliveryMode	173713f9-5e66-4a52-87f5-eff68df04cdc	poll
cibaExpiresIn	173713f9-5e66-4a52-87f5-eff68df04cdc	120
cibaAuthRequestedUserHint	173713f9-5e66-4a52-87f5-eff68df04cdc	login_hint
parRequestUriLifespan	173713f9-5e66-4a52-87f5-eff68df04cdc	60
cibaInterval	173713f9-5e66-4a52-87f5-eff68df04cdc	5
organizationsEnabled	173713f9-5e66-4a52-87f5-eff68df04cdc	false
adminPermissionsEnabled	173713f9-5e66-4a52-87f5-eff68df04cdc	false
verifiableCredentialsEnabled	173713f9-5e66-4a52-87f5-eff68df04cdc	false
actionTokenGeneratedByAdminLifespan	173713f9-5e66-4a52-87f5-eff68df04cdc	43200
actionTokenGeneratedByUserLifespan	173713f9-5e66-4a52-87f5-eff68df04cdc	300
oauth2DeviceCodeLifespan	173713f9-5e66-4a52-87f5-eff68df04cdc	600
oauth2DevicePollingInterval	173713f9-5e66-4a52-87f5-eff68df04cdc	5
clientSessionIdleTimeout	173713f9-5e66-4a52-87f5-eff68df04cdc	0
clientSessionMaxLifespan	173713f9-5e66-4a52-87f5-eff68df04cdc	0
clientOfflineSessionIdleTimeout	173713f9-5e66-4a52-87f5-eff68df04cdc	0
clientOfflineSessionMaxLifespan	173713f9-5e66-4a52-87f5-eff68df04cdc	0
webAuthnPolicyRpEntityName	173713f9-5e66-4a52-87f5-eff68df04cdc	keycloak
webAuthnPolicySignatureAlgorithms	173713f9-5e66-4a52-87f5-eff68df04cdc	ES256,RS256
webAuthnPolicyRpId	173713f9-5e66-4a52-87f5-eff68df04cdc	
webAuthnPolicyAttestationConveyancePreference	173713f9-5e66-4a52-87f5-eff68df04cdc	not specified
webAuthnPolicyAuthenticatorAttachment	173713f9-5e66-4a52-87f5-eff68df04cdc	not specified
webAuthnPolicyRequireResidentKey	173713f9-5e66-4a52-87f5-eff68df04cdc	not specified
webAuthnPolicyUserVerificationRequirement	173713f9-5e66-4a52-87f5-eff68df04cdc	not specified
webAuthnPolicyCreateTimeout	173713f9-5e66-4a52-87f5-eff68df04cdc	0
webAuthnPolicyAvoidSameAuthenticatorRegister	173713f9-5e66-4a52-87f5-eff68df04cdc	false
webAuthnPolicyRpEntityNamePasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	keycloak
webAuthnPolicySignatureAlgorithmsPasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	ES256,RS256
webAuthnPolicyRpIdPasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	
webAuthnPolicyAttestationConveyancePreferencePasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	not specified
webAuthnPolicyAuthenticatorAttachmentPasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	not specified
webAuthnPolicyRequireResidentKeyPasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	Yes
webAuthnPolicyUserVerificationRequirementPasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	required
webAuthnPolicyCreateTimeoutPasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	0
webAuthnPolicyAvoidSameAuthenticatorRegisterPasswordless	173713f9-5e66-4a52-87f5-eff68df04cdc	false
client-policies.profiles	173713f9-5e66-4a52-87f5-eff68df04cdc	{"profiles":[]}
client-policies.policies	173713f9-5e66-4a52-87f5-eff68df04cdc	{"policies":[]}
\.


--
-- Data for Name: realm_default_groups; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_default_groups (realm_id, group_id) FROM stdin;
\.


--
-- Data for Name: realm_enabled_event_types; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_enabled_event_types (realm_id, value) FROM stdin;
\.


--
-- Data for Name: realm_events_listeners; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_events_listeners (realm_id, value) FROM stdin;
173713f9-5e66-4a52-87f5-eff68df04cdc	jboss-logging
a7442214-2630-4991-aa3c-a2f06c383451	jboss-logging
\.


--
-- Data for Name: realm_localizations; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_localizations (realm_id, locale, texts) FROM stdin;
\.


--
-- Data for Name: realm_required_credential; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_required_credential (type, form_label, input, secret, realm_id) FROM stdin;
password	password	t	t	173713f9-5e66-4a52-87f5-eff68df04cdc
password	password	t	t	a7442214-2630-4991-aa3c-a2f06c383451
\.


--
-- Data for Name: realm_smtp_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_smtp_config (realm_id, value, name) FROM stdin;
\.


--
-- Data for Name: realm_supported_locales; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.realm_supported_locales (realm_id, value) FROM stdin;
\.


--
-- Data for Name: redirect_uris; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.redirect_uris (client_id, value) FROM stdin;
18a6eb66-d9b7-4c88-b0c6-45ea6f5625c9	/realms/master/account/*
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	/realms/master/account/*
b082de96-b6a8-4df3-9f64-263f781ca779	/admin/master/console/*
de51720b-8d19-440e-8b0e-99c995f8af2a	/realms/but-tc/account/*
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	/realms/but-tc/account/*
059cc72c-80f8-4975-999d-064aab6c33cb	/admin/but-tc/console/*
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	https://educ-ai.fr/*
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	https://home.educ-ai.fr/*
558cf020-06c9-4dd2-a491-0cdfd9598274	https://nextcloud.educ-ai.fr/*
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	https://mattermost.educ-ai.fr/*
\.


--
-- Data for Name: required_action_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.required_action_config (required_action_id, value, name) FROM stdin;
\.


--
-- Data for Name: required_action_provider; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.required_action_provider (id, alias, name, realm_id, enabled, default_action, provider_id, priority) FROM stdin;
506b0786-1c8b-41c9-982d-5769026c1711	VERIFY_EMAIL	Verify Email	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	VERIFY_EMAIL	50
4de11149-16bd-4391-b161-945baaba7ffb	UPDATE_PROFILE	Update Profile	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	UPDATE_PROFILE	40
264d062c-45e3-44a1-a2e5-7d0b15b425d0	CONFIGURE_TOTP	Configure OTP	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	CONFIGURE_TOTP	10
49d3e2d1-2db2-4403-b179-d9d12c3a26a4	UPDATE_PASSWORD	Update Password	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	UPDATE_PASSWORD	30
704b55f7-6637-4f21-b8f9-13a9e65e2735	TERMS_AND_CONDITIONS	Terms and Conditions	173713f9-5e66-4a52-87f5-eff68df04cdc	f	f	TERMS_AND_CONDITIONS	20
359f5f30-bbee-48ae-abd9-87ef9262d838	delete_account	Delete Account	173713f9-5e66-4a52-87f5-eff68df04cdc	f	f	delete_account	60
0ee86c9a-4434-4d19-ac42-395aff80faa6	delete_credential	Delete Credential	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	delete_credential	110
0553267c-d8cb-4915-8d5a-b948d29210de	update_user_locale	Update User Locale	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	update_user_locale	1000
2154b1fc-4583-43a1-acc6-fd3540952f2d	UPDATE_EMAIL	Update Email	173713f9-5e66-4a52-87f5-eff68df04cdc	f	f	UPDATE_EMAIL	70
63bbb5ad-6d83-4bae-9f7e-6ba7d2930a68	CONFIGURE_RECOVERY_AUTHN_CODES	Recovery Authentication Codes	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	CONFIGURE_RECOVERY_AUTHN_CODES	130
ebdc77bd-4ac7-4ae7-a62e-d8ec0a12e54a	webauthn-register	Webauthn Register	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	webauthn-register	80
2ec28d3f-997b-4e6d-acb1-4c5913ad4932	webauthn-register-passwordless	Webauthn Register Passwordless	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	webauthn-register-passwordless	90
60a7ff42-89de-4d09-8f11-8c89536b3ed1	VERIFY_PROFILE	Verify Profile	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	VERIFY_PROFILE	100
4a4de0a8-bd2e-4699-808f-6d3799a0a363	idp_link	Linking Identity Provider	173713f9-5e66-4a52-87f5-eff68df04cdc	t	f	idp_link	120
1244e843-4a33-4fe4-8f6d-c76f6ddd6e19	VERIFY_EMAIL	Verify Email	a7442214-2630-4991-aa3c-a2f06c383451	t	f	VERIFY_EMAIL	50
1742037e-883d-46fd-9de8-ea0971354219	UPDATE_PROFILE	Update Profile	a7442214-2630-4991-aa3c-a2f06c383451	t	f	UPDATE_PROFILE	40
6eb36216-7db5-4509-b78c-c81a3782c138	CONFIGURE_TOTP	Configure OTP	a7442214-2630-4991-aa3c-a2f06c383451	t	f	CONFIGURE_TOTP	10
5517c2c1-b37f-4e0a-9881-ea48aa8551c5	UPDATE_PASSWORD	Update Password	a7442214-2630-4991-aa3c-a2f06c383451	t	f	UPDATE_PASSWORD	30
d45b546d-aea4-4ce9-8bbf-af699b514d4f	TERMS_AND_CONDITIONS	Terms and Conditions	a7442214-2630-4991-aa3c-a2f06c383451	f	f	TERMS_AND_CONDITIONS	20
19c2183c-8288-4c50-a437-5649b15b6592	delete_account	Delete Account	a7442214-2630-4991-aa3c-a2f06c383451	f	f	delete_account	60
d65cb2d3-ef06-4a41-9c35-3ec10c2b7d69	delete_credential	Delete Credential	a7442214-2630-4991-aa3c-a2f06c383451	t	f	delete_credential	110
d5e73356-0b64-4ef0-8904-5fc706f36a14	update_user_locale	Update User Locale	a7442214-2630-4991-aa3c-a2f06c383451	t	f	update_user_locale	1000
ffecee12-ee2d-41ed-8ce5-8a8859377fe9	UPDATE_EMAIL	Update Email	a7442214-2630-4991-aa3c-a2f06c383451	f	f	UPDATE_EMAIL	70
3ec1a3a5-c389-4588-b8b0-a36e54d2031d	CONFIGURE_RECOVERY_AUTHN_CODES	Recovery Authentication Codes	a7442214-2630-4991-aa3c-a2f06c383451	t	f	CONFIGURE_RECOVERY_AUTHN_CODES	130
70a66cf8-81ec-48b1-a604-57380fadb274	webauthn-register	Webauthn Register	a7442214-2630-4991-aa3c-a2f06c383451	t	f	webauthn-register	80
9ac2e57f-344d-47de-a40b-d1031a0b14cf	webauthn-register-passwordless	Webauthn Register Passwordless	a7442214-2630-4991-aa3c-a2f06c383451	t	f	webauthn-register-passwordless	90
00849192-1bed-4304-ba34-e17e1b9dbc05	VERIFY_PROFILE	Verify Profile	a7442214-2630-4991-aa3c-a2f06c383451	t	f	VERIFY_PROFILE	100
f570d07a-b3f4-4227-abe6-0aae0bfc14bf	idp_link	Linking Identity Provider	a7442214-2630-4991-aa3c-a2f06c383451	t	f	idp_link	120
\.


--
-- Data for Name: resource_attribute; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_attribute (id, name, value, resource_id) FROM stdin;
\.


--
-- Data for Name: resource_policy; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_policy (resource_id, policy_id) FROM stdin;
\.


--
-- Data for Name: resource_scope; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_scope (resource_id, scope_id) FROM stdin;
\.


--
-- Data for Name: resource_server; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_server (id, allow_rs_remote_mgmt, policy_enforce_mode, decision_strategy) FROM stdin;
\.


--
-- Data for Name: resource_server_perm_ticket; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_server_perm_ticket (id, owner, requester, created_timestamp, granted_timestamp, resource_id, scope_id, resource_server_id, policy_id) FROM stdin;
\.


--
-- Data for Name: resource_server_policy; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_server_policy (id, name, description, type, decision_strategy, logic, resource_server_id, owner) FROM stdin;
\.


--
-- Data for Name: resource_server_resource; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_server_resource (id, name, type, icon_uri, owner, resource_server_id, owner_managed_access, display_name) FROM stdin;
\.


--
-- Data for Name: resource_server_scope; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_server_scope (id, name, icon_uri, resource_server_id, display_name) FROM stdin;
\.


--
-- Data for Name: resource_uris; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.resource_uris (resource_id, value) FROM stdin;
\.


--
-- Data for Name: revoked_token; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.revoked_token (id, expire) FROM stdin;
\.


--
-- Data for Name: role_attribute; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.role_attribute (id, role_id, name, value) FROM stdin;
\.


--
-- Data for Name: scope_mapping; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.scope_mapping (client_id, role_id) FROM stdin;
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	b0573419-cb74-4f85-96e3-7181ec281c08
ca425a64-ebd2-47bf-96a4-5273dfcfa60f	df01dff5-9687-455a-ba28-a227267d9616
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	4e7e7457-bc66-46b7-9331-d112ab24eec2
ef2cc8db-51ec-4b57-9aa2-67d2868e2c15	b4a43ed2-b468-4b9c-9cc3-4f2f434f2ac1
\.


--
-- Data for Name: scope_policy; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.scope_policy (scope_id, policy_id) FROM stdin;
\.


--
-- Data for Name: server_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.server_config (server_config_key, value, version) FROM stdin;
\.


--
-- Data for Name: user_attribute; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_attribute (name, value, user_id, id, long_value_hash, long_value_hash_lower_case, long_value) FROM stdin;
is_temporary_admin	true	b4ffa404-c9be-4193-bce9-7bb1111e39d5	3aea16ec-c6c3-4cae-9d3f-df91f0abb1bc	\N	\N	\N
\.


--
-- Data for Name: user_consent; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_consent (id, client_id, user_id, created_date, last_updated_date, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: user_consent_client_scope; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_consent_client_scope (user_consent_id, scope_id) FROM stdin;
\.


--
-- Data for Name: user_entity; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_entity (id, email, email_constraint, email_verified, enabled, federation_link, first_name, last_name, realm_id, username, created_timestamp, service_account_client_link, not_before) FROM stdin;
b4ffa404-c9be-4193-bce9-7bb1111e39d5	\N	e94cf73a-65c2-4c1b-9f23-b94a340f7de5	f	t	\N	\N	\N	173713f9-5e66-4a52-87f5-eff68df04cdc	admin	1769687713706	\N	0
8d9472da-8753-469a-9e7c-9ad5f084ce15	\N	d2132cbe-f472-4050-ab2a-fe250d018716	f	t	\N	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	admin	1771232912839	\N	0
cab5edaa-c096-4bd0-9261-3ae73053a7b8	\N	e9ba40f3-995c-476b-8a1d-d2357cdd6506	f	t	\N	\N	\N	a7442214-2630-4991-aa3c-a2f06c383451	service-account-skills-hub-app	1771232916469	e7ce1de1-f6dc-4b3e-995f-0505b20200ef	0
fb58b885-e142-4a99-8331-8943ea2f4048	test@educ-ai.fr	test@educ-ai.fr	f	t	\N	Test	User	a7442214-2630-4991-aa3c-a2f06c383451	test.user	1771233046384	\N	0
\.


--
-- Data for Name: user_federation_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_federation_config (user_federation_provider_id, value, name) FROM stdin;
\.


--
-- Data for Name: user_federation_mapper; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_federation_mapper (id, name, federation_provider_id, federation_mapper_type, realm_id) FROM stdin;
\.


--
-- Data for Name: user_federation_mapper_config; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_federation_mapper_config (user_federation_mapper_id, value, name) FROM stdin;
\.


--
-- Data for Name: user_federation_provider; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_federation_provider (id, changed_sync_period, display_name, full_sync_period, last_sync, priority, provider_name, realm_id) FROM stdin;
\.


--
-- Data for Name: user_group_membership; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_group_membership (group_id, user_id, membership_type) FROM stdin;
\.


--
-- Data for Name: user_required_action; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_required_action (user_id, required_action) FROM stdin;
\.


--
-- Data for Name: user_role_mapping; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.user_role_mapping (role_id, user_id) FROM stdin;
66d3306f-d865-460b-81d2-7e04f93c580e	b4ffa404-c9be-4193-bce9-7bb1111e39d5
50adf0ac-66ec-458d-8302-2067390ee0d7	b4ffa404-c9be-4193-bce9-7bb1111e39d5
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	8d9472da-8753-469a-9e7c-9ad5f084ce15
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	cab5edaa-c096-4bd0-9261-3ae73053a7b8
ff564a8b-5033-49f8-83bc-2ba22a8d5bbb	fb58b885-e142-4a99-8331-8943ea2f4048
\.


--
-- Data for Name: web_origins; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.web_origins (client_id, value) FROM stdin;
b082de96-b6a8-4df3-9f64-263f781ca779	+
059cc72c-80f8-4975-999d-064aab6c33cb	+
e7ce1de1-f6dc-4b3e-995f-0505b20200ef	+
558cf020-06c9-4dd2-a491-0cdfd9598274	+
96d5b3e3-853b-4c45-88e4-7c1562fe8e8a	+
\.


--
-- Data for Name: workflow_state; Type: TABLE DATA; Schema: public; Owner: keycloak
--

COPY public.workflow_state (execution_id, resource_id, workflow_id, resource_type, scheduled_step_id, scheduled_step_timestamp) FROM stdin;
\.


--
-- Name: org_domain ORG_DOMAIN_pkey; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org_domain
    ADD CONSTRAINT "ORG_DOMAIN_pkey" PRIMARY KEY (id, name);


--
-- Name: org ORG_pkey; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT "ORG_pkey" PRIMARY KEY (id);


--
-- Name: server_config SERVER_CONFIG_pkey; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.server_config
    ADD CONSTRAINT "SERVER_CONFIG_pkey" PRIMARY KEY (server_config_key);


--
-- Name: keycloak_role UK_J3RWUVD56ONTGSUHOGM184WW2-2; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT "UK_J3RWUVD56ONTGSUHOGM184WW2-2" UNIQUE (name, client_realm_constraint);


--
-- Name: client_auth_flow_bindings c_cli_flow_bind; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_auth_flow_bindings
    ADD CONSTRAINT c_cli_flow_bind PRIMARY KEY (client_id, binding_name);


--
-- Name: client_scope_client c_cli_scope_bind; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_scope_client
    ADD CONSTRAINT c_cli_scope_bind PRIMARY KEY (client_id, scope_id);


--
-- Name: client_initial_access cnstr_client_init_acc_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_initial_access
    ADD CONSTRAINT cnstr_client_init_acc_pk PRIMARY KEY (id);


--
-- Name: realm_default_groups con_group_id_def_groups; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT con_group_id_def_groups UNIQUE (group_id);


--
-- Name: broker_link constr_broker_link_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.broker_link
    ADD CONSTRAINT constr_broker_link_pk PRIMARY KEY (identity_provider, user_id);


--
-- Name: component_config constr_component_config_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.component_config
    ADD CONSTRAINT constr_component_config_pk PRIMARY KEY (id);


--
-- Name: component constr_component_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT constr_component_pk PRIMARY KEY (id);


--
-- Name: fed_user_required_action constr_fed_required_action; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.fed_user_required_action
    ADD CONSTRAINT constr_fed_required_action PRIMARY KEY (required_action, user_id);


--
-- Name: fed_user_attribute constr_fed_user_attr_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.fed_user_attribute
    ADD CONSTRAINT constr_fed_user_attr_pk PRIMARY KEY (id);


--
-- Name: fed_user_consent constr_fed_user_consent_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.fed_user_consent
    ADD CONSTRAINT constr_fed_user_consent_pk PRIMARY KEY (id);


--
-- Name: fed_user_credential constr_fed_user_cred_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.fed_user_credential
    ADD CONSTRAINT constr_fed_user_cred_pk PRIMARY KEY (id);


--
-- Name: fed_user_group_membership constr_fed_user_group; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.fed_user_group_membership
    ADD CONSTRAINT constr_fed_user_group PRIMARY KEY (group_id, user_id);


--
-- Name: fed_user_role_mapping constr_fed_user_role; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.fed_user_role_mapping
    ADD CONSTRAINT constr_fed_user_role PRIMARY KEY (role_id, user_id);


--
-- Name: federated_user constr_federated_user; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.federated_user
    ADD CONSTRAINT constr_federated_user PRIMARY KEY (id);


--
-- Name: realm_default_groups constr_realm_default_groups; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT constr_realm_default_groups PRIMARY KEY (realm_id, group_id);


--
-- Name: realm_enabled_event_types constr_realm_enabl_event_types; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_enabled_event_types
    ADD CONSTRAINT constr_realm_enabl_event_types PRIMARY KEY (realm_id, value);


--
-- Name: realm_events_listeners constr_realm_events_listeners; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_events_listeners
    ADD CONSTRAINT constr_realm_events_listeners PRIMARY KEY (realm_id, value);


--
-- Name: realm_supported_locales constr_realm_supported_locales; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_supported_locales
    ADD CONSTRAINT constr_realm_supported_locales PRIMARY KEY (realm_id, value);


--
-- Name: identity_provider constraint_2b; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT constraint_2b PRIMARY KEY (internal_id);


--
-- Name: client_attributes constraint_3c; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_attributes
    ADD CONSTRAINT constraint_3c PRIMARY KEY (client_id, name);


--
-- Name: event_entity constraint_4; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.event_entity
    ADD CONSTRAINT constraint_4 PRIMARY KEY (id);


--
-- Name: federated_identity constraint_40; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.federated_identity
    ADD CONSTRAINT constraint_40 PRIMARY KEY (identity_provider, user_id);


--
-- Name: realm constraint_4a; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm
    ADD CONSTRAINT constraint_4a PRIMARY KEY (id);


--
-- Name: user_federation_provider constraint_5c; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_provider
    ADD CONSTRAINT constraint_5c PRIMARY KEY (id);


--
-- Name: client constraint_7; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT constraint_7 PRIMARY KEY (id);


--
-- Name: scope_mapping constraint_81; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.scope_mapping
    ADD CONSTRAINT constraint_81 PRIMARY KEY (client_id, role_id);


--
-- Name: client_node_registrations constraint_84; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_node_registrations
    ADD CONSTRAINT constraint_84 PRIMARY KEY (client_id, name);


--
-- Name: realm_attribute constraint_9; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_attribute
    ADD CONSTRAINT constraint_9 PRIMARY KEY (name, realm_id);


--
-- Name: realm_required_credential constraint_92; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_required_credential
    ADD CONSTRAINT constraint_92 PRIMARY KEY (realm_id, type);


--
-- Name: keycloak_role constraint_a; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT constraint_a PRIMARY KEY (id);


--
-- Name: admin_event_entity constraint_admin_event_entity; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.admin_event_entity
    ADD CONSTRAINT constraint_admin_event_entity PRIMARY KEY (id);


--
-- Name: authenticator_config_entry constraint_auth_cfg_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authenticator_config_entry
    ADD CONSTRAINT constraint_auth_cfg_pk PRIMARY KEY (authenticator_id, name);


--
-- Name: authentication_execution constraint_auth_exec_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT constraint_auth_exec_pk PRIMARY KEY (id);


--
-- Name: authentication_flow constraint_auth_flow_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authentication_flow
    ADD CONSTRAINT constraint_auth_flow_pk PRIMARY KEY (id);


--
-- Name: authenticator_config constraint_auth_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authenticator_config
    ADD CONSTRAINT constraint_auth_pk PRIMARY KEY (id);


--
-- Name: user_role_mapping constraint_c; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_role_mapping
    ADD CONSTRAINT constraint_c PRIMARY KEY (role_id, user_id);


--
-- Name: composite_role constraint_composite_role; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT constraint_composite_role PRIMARY KEY (composite, child_role);


--
-- Name: identity_provider_config constraint_d; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.identity_provider_config
    ADD CONSTRAINT constraint_d PRIMARY KEY (identity_provider_id, name);


--
-- Name: policy_config constraint_dpc; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.policy_config
    ADD CONSTRAINT constraint_dpc PRIMARY KEY (policy_id, name);


--
-- Name: realm_smtp_config constraint_e; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_smtp_config
    ADD CONSTRAINT constraint_e PRIMARY KEY (realm_id, name);


--
-- Name: credential constraint_f; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.credential
    ADD CONSTRAINT constraint_f PRIMARY KEY (id);


--
-- Name: user_federation_config constraint_f9; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_config
    ADD CONSTRAINT constraint_f9 PRIMARY KEY (user_federation_provider_id, name);


--
-- Name: resource_server_perm_ticket constraint_fapmt; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT constraint_fapmt PRIMARY KEY (id);


--
-- Name: resource_server_resource constraint_farsr; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT constraint_farsr PRIMARY KEY (id);


--
-- Name: resource_server_policy constraint_farsrp; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT constraint_farsrp PRIMARY KEY (id);


--
-- Name: associated_policy constraint_farsrpap; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT constraint_farsrpap PRIMARY KEY (policy_id, associated_policy_id);


--
-- Name: resource_policy constraint_farsrpp; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT constraint_farsrpp PRIMARY KEY (resource_id, policy_id);


--
-- Name: resource_server_scope constraint_farsrs; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT constraint_farsrs PRIMARY KEY (id);


--
-- Name: resource_scope constraint_farsrsp; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT constraint_farsrsp PRIMARY KEY (resource_id, scope_id);


--
-- Name: scope_policy constraint_farsrsps; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT constraint_farsrsps PRIMARY KEY (scope_id, policy_id);


--
-- Name: user_entity constraint_fb; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT constraint_fb PRIMARY KEY (id);


--
-- Name: user_federation_mapper_config constraint_fedmapper_cfg_pm; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_mapper_config
    ADD CONSTRAINT constraint_fedmapper_cfg_pm PRIMARY KEY (user_federation_mapper_id, name);


--
-- Name: user_federation_mapper constraint_fedmapperpm; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT constraint_fedmapperpm PRIMARY KEY (id);


--
-- Name: fed_user_consent_cl_scope constraint_fgrntcsnt_clsc_pm; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.fed_user_consent_cl_scope
    ADD CONSTRAINT constraint_fgrntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- Name: user_consent_client_scope constraint_grntcsnt_clsc_pm; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_consent_client_scope
    ADD CONSTRAINT constraint_grntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- Name: user_consent constraint_grntcsnt_pm; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT constraint_grntcsnt_pm PRIMARY KEY (id);


--
-- Name: keycloak_group constraint_group; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.keycloak_group
    ADD CONSTRAINT constraint_group PRIMARY KEY (id);


--
-- Name: group_attribute constraint_group_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.group_attribute
    ADD CONSTRAINT constraint_group_attribute_pk PRIMARY KEY (id);


--
-- Name: group_role_mapping constraint_group_role; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.group_role_mapping
    ADD CONSTRAINT constraint_group_role PRIMARY KEY (role_id, group_id);


--
-- Name: identity_provider_mapper constraint_idpm; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.identity_provider_mapper
    ADD CONSTRAINT constraint_idpm PRIMARY KEY (id);


--
-- Name: idp_mapper_config constraint_idpmconfig; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.idp_mapper_config
    ADD CONSTRAINT constraint_idpmconfig PRIMARY KEY (idp_mapper_id, name);


--
-- Name: jgroups_ping constraint_jgroups_ping; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.jgroups_ping
    ADD CONSTRAINT constraint_jgroups_ping PRIMARY KEY (address);


--
-- Name: migration_model constraint_migmod; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.migration_model
    ADD CONSTRAINT constraint_migmod PRIMARY KEY (id);


--
-- Name: offline_client_session constraint_offl_cl_ses_pk3; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.offline_client_session
    ADD CONSTRAINT constraint_offl_cl_ses_pk3 PRIMARY KEY (user_session_id, client_id, client_storage_provider, external_client_id, offline_flag);


--
-- Name: offline_user_session constraint_offl_us_ses_pk2; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.offline_user_session
    ADD CONSTRAINT constraint_offl_us_ses_pk2 PRIMARY KEY (user_session_id, offline_flag);


--
-- Name: org_invitation constraint_org_invitation; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org_invitation
    ADD CONSTRAINT constraint_org_invitation PRIMARY KEY (id);


--
-- Name: protocol_mapper constraint_pcm; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT constraint_pcm PRIMARY KEY (id);


--
-- Name: protocol_mapper_config constraint_pmconfig; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.protocol_mapper_config
    ADD CONSTRAINT constraint_pmconfig PRIMARY KEY (protocol_mapper_id, name);


--
-- Name: redirect_uris constraint_redirect_uris; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.redirect_uris
    ADD CONSTRAINT constraint_redirect_uris PRIMARY KEY (client_id, value);


--
-- Name: required_action_config constraint_req_act_cfg_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.required_action_config
    ADD CONSTRAINT constraint_req_act_cfg_pk PRIMARY KEY (required_action_id, name);


--
-- Name: required_action_provider constraint_req_act_prv_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.required_action_provider
    ADD CONSTRAINT constraint_req_act_prv_pk PRIMARY KEY (id);


--
-- Name: user_required_action constraint_required_action; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_required_action
    ADD CONSTRAINT constraint_required_action PRIMARY KEY (required_action, user_id);


--
-- Name: resource_uris constraint_resour_uris_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_uris
    ADD CONSTRAINT constraint_resour_uris_pk PRIMARY KEY (resource_id, value);


--
-- Name: role_attribute constraint_role_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.role_attribute
    ADD CONSTRAINT constraint_role_attribute_pk PRIMARY KEY (id);


--
-- Name: revoked_token constraint_rt; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.revoked_token
    ADD CONSTRAINT constraint_rt PRIMARY KEY (id);


--
-- Name: user_attribute constraint_user_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_attribute
    ADD CONSTRAINT constraint_user_attribute_pk PRIMARY KEY (id);


--
-- Name: user_group_membership constraint_user_group; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_group_membership
    ADD CONSTRAINT constraint_user_group PRIMARY KEY (group_id, user_id);


--
-- Name: web_origins constraint_web_origins; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.web_origins
    ADD CONSTRAINT constraint_web_origins PRIMARY KEY (client_id, value);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: client_scope_attributes pk_cl_tmpl_attr; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_scope_attributes
    ADD CONSTRAINT pk_cl_tmpl_attr PRIMARY KEY (scope_id, name);


--
-- Name: client_scope pk_cli_template; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_scope
    ADD CONSTRAINT pk_cli_template PRIMARY KEY (id);


--
-- Name: resource_server pk_resource_server; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server
    ADD CONSTRAINT pk_resource_server PRIMARY KEY (id);


--
-- Name: client_scope_role_mapping pk_template_scope; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_scope_role_mapping
    ADD CONSTRAINT pk_template_scope PRIMARY KEY (scope_id, role_id);


--
-- Name: workflow_state pk_workflow_state; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.workflow_state
    ADD CONSTRAINT pk_workflow_state PRIMARY KEY (execution_id);


--
-- Name: default_client_scope r_def_cli_scope_bind; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.default_client_scope
    ADD CONSTRAINT r_def_cli_scope_bind PRIMARY KEY (realm_id, scope_id);


--
-- Name: realm_localizations realm_localizations_pkey; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_localizations
    ADD CONSTRAINT realm_localizations_pkey PRIMARY KEY (realm_id, locale);


--
-- Name: resource_attribute res_attr_pk; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_attribute
    ADD CONSTRAINT res_attr_pk PRIMARY KEY (id);


--
-- Name: keycloak_group sibling_names; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.keycloak_group
    ADD CONSTRAINT sibling_names UNIQUE (realm_id, parent_group, name);


--
-- Name: identity_provider uk_2daelwnibji49avxsrtuf6xj33; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT uk_2daelwnibji49avxsrtuf6xj33 UNIQUE (provider_alias, realm_id);


--
-- Name: client uk_b71cjlbenv945rb6gcon438at; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT uk_b71cjlbenv945rb6gcon438at UNIQUE (realm_id, client_id);


--
-- Name: client_scope uk_cli_scope; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_scope
    ADD CONSTRAINT uk_cli_scope UNIQUE (realm_id, name);


--
-- Name: user_entity uk_dykn684sl8up1crfei6eckhd7; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT uk_dykn684sl8up1crfei6eckhd7 UNIQUE (realm_id, email_constraint);


--
-- Name: user_consent uk_external_consent; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT uk_external_consent UNIQUE (client_storage_provider, external_client_id, user_id);


--
-- Name: resource_server_resource uk_frsr6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5ha6 UNIQUE (name, owner, resource_server_id);


--
-- Name: resource_server_perm_ticket uk_frsr6t700s9v50bu18ws5pmt; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5pmt UNIQUE (owner, requester, resource_server_id, resource_id, scope_id);


--
-- Name: resource_server_policy uk_frsrpt700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT uk_frsrpt700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- Name: resource_server_scope uk_frsrst700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT uk_frsrst700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- Name: user_consent uk_local_consent; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT uk_local_consent UNIQUE (client_id, user_id);


--
-- Name: migration_model uk_migration_update_time; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.migration_model
    ADD CONSTRAINT uk_migration_update_time UNIQUE (update_time);


--
-- Name: migration_model uk_migration_version; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.migration_model
    ADD CONSTRAINT uk_migration_version UNIQUE (version);


--
-- Name: org uk_org_alias; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT uk_org_alias UNIQUE (realm_id, alias);


--
-- Name: org uk_org_group; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT uk_org_group UNIQUE (group_id);


--
-- Name: org_invitation uk_org_invitation_email; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org_invitation
    ADD CONSTRAINT uk_org_invitation_email UNIQUE (organization_id, email);


--
-- Name: org uk_org_name; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT uk_org_name UNIQUE (realm_id, name);


--
-- Name: realm uk_orvsdmla56612eaefiq6wl5oi; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm
    ADD CONSTRAINT uk_orvsdmla56612eaefiq6wl5oi UNIQUE (name);


--
-- Name: user_entity uk_ru8tt6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT uk_ru8tt6t700s9v50bu18ws5ha6 UNIQUE (realm_id, username);


--
-- Name: workflow_state uq_workflow_resource; Type: CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.workflow_state
    ADD CONSTRAINT uq_workflow_resource UNIQUE (workflow_id, resource_id);


--
-- Name: fed_user_attr_long_values; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX fed_user_attr_long_values ON public.fed_user_attribute USING btree (long_value_hash, name);


--
-- Name: fed_user_attr_long_values_lower_case; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX fed_user_attr_long_values_lower_case ON public.fed_user_attribute USING btree (long_value_hash_lower_case, name);


--
-- Name: idx_admin_event_time; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_admin_event_time ON public.admin_event_entity USING btree (realm_id, admin_event_time);


--
-- Name: idx_assoc_pol_assoc_pol_id; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_assoc_pol_assoc_pol_id ON public.associated_policy USING btree (associated_policy_id);


--
-- Name: idx_auth_config_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_auth_config_realm ON public.authenticator_config USING btree (realm_id);


--
-- Name: idx_auth_exec_flow; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_auth_exec_flow ON public.authentication_execution USING btree (flow_id);


--
-- Name: idx_auth_exec_realm_flow; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_auth_exec_realm_flow ON public.authentication_execution USING btree (realm_id, flow_id);


--
-- Name: idx_auth_flow_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_auth_flow_realm ON public.authentication_flow USING btree (realm_id);


--
-- Name: idx_cl_clscope; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_cl_clscope ON public.client_scope_client USING btree (scope_id);


--
-- Name: idx_client_att_by_name_value; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_client_att_by_name_value ON public.client_attributes USING btree (name, substr(value, 1, 255));


--
-- Name: idx_client_id; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_client_id ON public.client USING btree (client_id);


--
-- Name: idx_client_init_acc_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_client_init_acc_realm ON public.client_initial_access USING btree (realm_id);


--
-- Name: idx_clscope_attrs; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_clscope_attrs ON public.client_scope_attributes USING btree (scope_id);


--
-- Name: idx_clscope_cl; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_clscope_cl ON public.client_scope_client USING btree (client_id);


--
-- Name: idx_clscope_protmap; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_clscope_protmap ON public.protocol_mapper USING btree (client_scope_id);


--
-- Name: idx_clscope_role; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_clscope_role ON public.client_scope_role_mapping USING btree (scope_id);


--
-- Name: idx_compo_config_compo; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_compo_config_compo ON public.component_config USING btree (component_id);


--
-- Name: idx_component_provider_type; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_component_provider_type ON public.component USING btree (provider_type);


--
-- Name: idx_component_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_component_realm ON public.component USING btree (realm_id);


--
-- Name: idx_composite; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_composite ON public.composite_role USING btree (composite);


--
-- Name: idx_composite_child; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_composite_child ON public.composite_role USING btree (child_role);


--
-- Name: idx_defcls_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_defcls_realm ON public.default_client_scope USING btree (realm_id);


--
-- Name: idx_defcls_scope; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_defcls_scope ON public.default_client_scope USING btree (scope_id);


--
-- Name: idx_event_entity_user_id_type; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_event_entity_user_id_type ON public.event_entity USING btree (user_id, type, event_time);


--
-- Name: idx_event_time; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_event_time ON public.event_entity USING btree (realm_id, event_time);


--
-- Name: idx_fedidentity_feduser; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fedidentity_feduser ON public.federated_identity USING btree (federated_user_id);


--
-- Name: idx_fedidentity_user; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fedidentity_user ON public.federated_identity USING btree (user_id);


--
-- Name: idx_fu_attribute; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_attribute ON public.fed_user_attribute USING btree (user_id, realm_id, name);


--
-- Name: idx_fu_cnsnt_ext; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_cnsnt_ext ON public.fed_user_consent USING btree (user_id, client_storage_provider, external_client_id);


--
-- Name: idx_fu_consent; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_consent ON public.fed_user_consent USING btree (user_id, client_id);


--
-- Name: idx_fu_consent_ru; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_consent_ru ON public.fed_user_consent USING btree (realm_id, user_id);


--
-- Name: idx_fu_credential; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_credential ON public.fed_user_credential USING btree (user_id, type);


--
-- Name: idx_fu_credential_ru; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_credential_ru ON public.fed_user_credential USING btree (realm_id, user_id);


--
-- Name: idx_fu_group_membership; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_group_membership ON public.fed_user_group_membership USING btree (user_id, group_id);


--
-- Name: idx_fu_group_membership_ru; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_group_membership_ru ON public.fed_user_group_membership USING btree (realm_id, user_id);


--
-- Name: idx_fu_required_action; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_required_action ON public.fed_user_required_action USING btree (user_id, required_action);


--
-- Name: idx_fu_required_action_ru; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_required_action_ru ON public.fed_user_required_action USING btree (realm_id, user_id);


--
-- Name: idx_fu_role_mapping; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_role_mapping ON public.fed_user_role_mapping USING btree (user_id, role_id);


--
-- Name: idx_fu_role_mapping_ru; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_fu_role_mapping_ru ON public.fed_user_role_mapping USING btree (realm_id, user_id);


--
-- Name: idx_group_att_by_name_value; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_group_att_by_name_value ON public.group_attribute USING btree (name, ((value)::character varying(250)));


--
-- Name: idx_group_attr_group; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_group_attr_group ON public.group_attribute USING btree (group_id);


--
-- Name: idx_group_role_mapp_group; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_group_role_mapp_group ON public.group_role_mapping USING btree (group_id);


--
-- Name: idx_id_prov_mapp_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_id_prov_mapp_realm ON public.identity_provider_mapper USING btree (realm_id);


--
-- Name: idx_ident_prov_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_ident_prov_realm ON public.identity_provider USING btree (realm_id);


--
-- Name: idx_idp_for_login; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_idp_for_login ON public.identity_provider USING btree (realm_id, enabled, link_only, hide_on_login, organization_id);


--
-- Name: idx_idp_realm_org; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_idp_realm_org ON public.identity_provider USING btree (realm_id, organization_id);


--
-- Name: idx_keycloak_role_client; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_keycloak_role_client ON public.keycloak_role USING btree (client);


--
-- Name: idx_keycloak_role_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_keycloak_role_realm ON public.keycloak_role USING btree (realm);


--
-- Name: idx_offline_css_by_client; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_offline_css_by_client ON public.offline_client_session USING btree (client_id, offline_flag) WHERE ((client_id)::text <> 'external'::text);


--
-- Name: idx_offline_css_by_client_storage_provider; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_offline_css_by_client_storage_provider ON public.offline_client_session USING btree (client_storage_provider, external_client_id, offline_flag) WHERE ((client_storage_provider)::text <> 'internal'::text);


--
-- Name: idx_offline_uss_by_broker_session_id; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_offline_uss_by_broker_session_id ON public.offline_user_session USING btree (broker_session_id, realm_id);


--
-- Name: idx_offline_uss_by_user; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_offline_uss_by_user ON public.offline_user_session USING btree (user_id, realm_id, offline_flag);


--
-- Name: idx_org_domain_org_id; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_org_domain_org_id ON public.org_domain USING btree (org_id);


--
-- Name: idx_org_invitation_email; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_org_invitation_email ON public.org_invitation USING btree (email);


--
-- Name: idx_org_invitation_expires; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_org_invitation_expires ON public.org_invitation USING btree (expires_at);


--
-- Name: idx_org_invitation_org_id; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_org_invitation_org_id ON public.org_invitation USING btree (organization_id);


--
-- Name: idx_perm_ticket_owner; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_perm_ticket_owner ON public.resource_server_perm_ticket USING btree (owner);


--
-- Name: idx_perm_ticket_requester; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_perm_ticket_requester ON public.resource_server_perm_ticket USING btree (requester);


--
-- Name: idx_protocol_mapper_client; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_protocol_mapper_client ON public.protocol_mapper USING btree (client_id);


--
-- Name: idx_realm_attr_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_realm_attr_realm ON public.realm_attribute USING btree (realm_id);


--
-- Name: idx_realm_clscope; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_realm_clscope ON public.client_scope USING btree (realm_id);


--
-- Name: idx_realm_def_grp_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_realm_def_grp_realm ON public.realm_default_groups USING btree (realm_id);


--
-- Name: idx_realm_evt_list_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_realm_evt_list_realm ON public.realm_events_listeners USING btree (realm_id);


--
-- Name: idx_realm_evt_types_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_realm_evt_types_realm ON public.realm_enabled_event_types USING btree (realm_id);


--
-- Name: idx_realm_master_adm_cli; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_realm_master_adm_cli ON public.realm USING btree (master_admin_client);


--
-- Name: idx_realm_supp_local_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_realm_supp_local_realm ON public.realm_supported_locales USING btree (realm_id);


--
-- Name: idx_redir_uri_client; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_redir_uri_client ON public.redirect_uris USING btree (client_id);


--
-- Name: idx_req_act_prov_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_req_act_prov_realm ON public.required_action_provider USING btree (realm_id);


--
-- Name: idx_res_policy_policy; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_res_policy_policy ON public.resource_policy USING btree (policy_id);


--
-- Name: idx_res_scope_scope; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_res_scope_scope ON public.resource_scope USING btree (scope_id);


--
-- Name: idx_res_serv_pol_res_serv; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_res_serv_pol_res_serv ON public.resource_server_policy USING btree (resource_server_id);


--
-- Name: idx_res_srv_res_res_srv; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_res_srv_res_res_srv ON public.resource_server_resource USING btree (resource_server_id);


--
-- Name: idx_res_srv_scope_res_srv; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_res_srv_scope_res_srv ON public.resource_server_scope USING btree (resource_server_id);


--
-- Name: idx_rev_token_on_expire; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_rev_token_on_expire ON public.revoked_token USING btree (expire);


--
-- Name: idx_role_attribute; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_role_attribute ON public.role_attribute USING btree (role_id);


--
-- Name: idx_role_clscope; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_role_clscope ON public.client_scope_role_mapping USING btree (role_id);


--
-- Name: idx_scope_mapping_role; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_scope_mapping_role ON public.scope_mapping USING btree (role_id);


--
-- Name: idx_scope_policy_policy; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_scope_policy_policy ON public.scope_policy USING btree (policy_id);


--
-- Name: idx_update_time; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_update_time ON public.migration_model USING btree (update_time);


--
-- Name: idx_usconsent_clscope; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_usconsent_clscope ON public.user_consent_client_scope USING btree (user_consent_id);


--
-- Name: idx_usconsent_scope_id; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_usconsent_scope_id ON public.user_consent_client_scope USING btree (scope_id);


--
-- Name: idx_user_attribute; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_attribute ON public.user_attribute USING btree (user_id);


--
-- Name: idx_user_attribute_name; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_attribute_name ON public.user_attribute USING btree (name, value);


--
-- Name: idx_user_consent; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_consent ON public.user_consent USING btree (user_id);


--
-- Name: idx_user_credential; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_credential ON public.credential USING btree (user_id);


--
-- Name: idx_user_email; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_email ON public.user_entity USING btree (email);


--
-- Name: idx_user_group_mapping; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_group_mapping ON public.user_group_membership USING btree (user_id);


--
-- Name: idx_user_reqactions; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_reqactions ON public.user_required_action USING btree (user_id);


--
-- Name: idx_user_role_mapping; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_role_mapping ON public.user_role_mapping USING btree (user_id);


--
-- Name: idx_user_service_account; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_service_account ON public.user_entity USING btree (realm_id, service_account_client_link);


--
-- Name: idx_user_session_expiration_created; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_session_expiration_created ON public.offline_user_session USING btree (realm_id, offline_flag, remember_me, created_on, user_session_id, user_id);


--
-- Name: idx_user_session_expiration_last_refresh; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_user_session_expiration_last_refresh ON public.offline_user_session USING btree (realm_id, offline_flag, remember_me, last_session_refresh, user_session_id, user_id);


--
-- Name: idx_usr_fed_map_fed_prv; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_usr_fed_map_fed_prv ON public.user_federation_mapper USING btree (federation_provider_id);


--
-- Name: idx_usr_fed_map_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_usr_fed_map_realm ON public.user_federation_mapper USING btree (realm_id);


--
-- Name: idx_usr_fed_prv_realm; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_usr_fed_prv_realm ON public.user_federation_provider USING btree (realm_id);


--
-- Name: idx_web_orig_client; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_web_orig_client ON public.web_origins USING btree (client_id);


--
-- Name: idx_workflow_state_provider; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_workflow_state_provider ON public.workflow_state USING btree (resource_id);


--
-- Name: idx_workflow_state_step; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX idx_workflow_state_step ON public.workflow_state USING btree (workflow_id, scheduled_step_id);


--
-- Name: user_attr_long_values; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX user_attr_long_values ON public.user_attribute USING btree (long_value_hash, name);


--
-- Name: user_attr_long_values_lower_case; Type: INDEX; Schema: public; Owner: keycloak
--

CREATE INDEX user_attr_long_values_lower_case ON public.user_attribute USING btree (long_value_hash_lower_case, name);


--
-- Name: identity_provider fk2b4ebc52ae5c3b34; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT fk2b4ebc52ae5c3b34 FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: client_attributes fk3c47c64beacca966; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_attributes
    ADD CONSTRAINT fk3c47c64beacca966 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: federated_identity fk404288b92ef007a6; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.federated_identity
    ADD CONSTRAINT fk404288b92ef007a6 FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: client_node_registrations fk4129723ba992f594; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_node_registrations
    ADD CONSTRAINT fk4129723ba992f594 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: redirect_uris fk_1burs8pb4ouj97h5wuppahv9f; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.redirect_uris
    ADD CONSTRAINT fk_1burs8pb4ouj97h5wuppahv9f FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: user_federation_provider fk_1fj32f6ptolw2qy60cd8n01e8; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_provider
    ADD CONSTRAINT fk_1fj32f6ptolw2qy60cd8n01e8 FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_required_credential fk_5hg65lybevavkqfki3kponh9v; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_required_credential
    ADD CONSTRAINT fk_5hg65lybevavkqfki3kponh9v FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: resource_attribute fk_5hrm2vlf9ql5fu022kqepovbr; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu022kqepovbr FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: user_attribute fk_5hrm2vlf9ql5fu043kqepovbr; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu043kqepovbr FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: user_required_action fk_6qj3w1jw9cvafhe19bwsiuvmd; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_required_action
    ADD CONSTRAINT fk_6qj3w1jw9cvafhe19bwsiuvmd FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: keycloak_role fk_6vyqfe4cn4wlq8r6kt5vdsj5c; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT fk_6vyqfe4cn4wlq8r6kt5vdsj5c FOREIGN KEY (realm) REFERENCES public.realm(id);


--
-- Name: realm_smtp_config fk_70ej8xdxgxd0b9hh6180irr0o; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_smtp_config
    ADD CONSTRAINT fk_70ej8xdxgxd0b9hh6180irr0o FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_attribute fk_8shxd6l3e9atqukacxgpffptw; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_attribute
    ADD CONSTRAINT fk_8shxd6l3e9atqukacxgpffptw FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: composite_role fk_a63wvekftu8jo1pnj81e7mce2; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT fk_a63wvekftu8jo1pnj81e7mce2 FOREIGN KEY (composite) REFERENCES public.keycloak_role(id);


--
-- Name: authentication_execution fk_auth_exec_flow; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT fk_auth_exec_flow FOREIGN KEY (flow_id) REFERENCES public.authentication_flow(id);


--
-- Name: authentication_execution fk_auth_exec_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT fk_auth_exec_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: authentication_flow fk_auth_flow_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authentication_flow
    ADD CONSTRAINT fk_auth_flow_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: authenticator_config fk_auth_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.authenticator_config
    ADD CONSTRAINT fk_auth_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: user_role_mapping fk_c4fqv34p1mbylloxang7b1q3l; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_role_mapping
    ADD CONSTRAINT fk_c4fqv34p1mbylloxang7b1q3l FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: client_scope_attributes fk_cl_scope_attr_scope; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_scope_attributes
    ADD CONSTRAINT fk_cl_scope_attr_scope FOREIGN KEY (scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_scope_role_mapping fk_cl_scope_rm_scope; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_scope_role_mapping
    ADD CONSTRAINT fk_cl_scope_rm_scope FOREIGN KEY (scope_id) REFERENCES public.client_scope(id);


--
-- Name: protocol_mapper fk_cli_scope_mapper; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT fk_cli_scope_mapper FOREIGN KEY (client_scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_initial_access fk_client_init_acc_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.client_initial_access
    ADD CONSTRAINT fk_client_init_acc_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: component_config fk_component_config; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.component_config
    ADD CONSTRAINT fk_component_config FOREIGN KEY (component_id) REFERENCES public.component(id);


--
-- Name: component fk_component_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT fk_component_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_default_groups fk_def_groups_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT fk_def_groups_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: user_federation_mapper_config fk_fedmapper_cfg; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_mapper_config
    ADD CONSTRAINT fk_fedmapper_cfg FOREIGN KEY (user_federation_mapper_id) REFERENCES public.user_federation_mapper(id);


--
-- Name: user_federation_mapper fk_fedmapperpm_fedprv; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_fedprv FOREIGN KEY (federation_provider_id) REFERENCES public.user_federation_provider(id);


--
-- Name: user_federation_mapper fk_fedmapperpm_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: associated_policy fk_frsr5s213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT fk_frsr5s213xcx4wnkog82ssrfy FOREIGN KEY (associated_policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: scope_policy fk_frsrasp13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT fk_frsrasp13xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog82sspmt; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82sspmt FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_server_resource fk_frsrho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog83sspmt; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog83sspmt FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog84sspmt; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog84sspmt FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: associated_policy fk_frsrpas14xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT fk_frsrpas14xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: scope_policy fk_frsrpass3xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT fk_frsrpass3xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: resource_server_perm_ticket fk_frsrpo2128cx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrpo2128cx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_server_policy fk_frsrpo213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT fk_frsrpo213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_scope fk_frsrpos13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT fk_frsrpos13xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_policy fk_frsrpos53xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT fk_frsrpos53xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_policy fk_frsrpp213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT fk_frsrpp213xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_scope fk_frsrps213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT fk_frsrps213xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: resource_server_scope fk_frsrso213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT fk_frsrso213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: composite_role fk_gr7thllb9lu8q4vqa4524jjy8; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT fk_gr7thllb9lu8q4vqa4524jjy8 FOREIGN KEY (child_role) REFERENCES public.keycloak_role(id);


--
-- Name: user_consent_client_scope fk_grntcsnt_clsc_usc; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_consent_client_scope
    ADD CONSTRAINT fk_grntcsnt_clsc_usc FOREIGN KEY (user_consent_id) REFERENCES public.user_consent(id);


--
-- Name: user_consent fk_grntcsnt_user; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT fk_grntcsnt_user FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: group_attribute fk_group_attribute_group; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.group_attribute
    ADD CONSTRAINT fk_group_attribute_group FOREIGN KEY (group_id) REFERENCES public.keycloak_group(id);


--
-- Name: group_role_mapping fk_group_role_group; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.group_role_mapping
    ADD CONSTRAINT fk_group_role_group FOREIGN KEY (group_id) REFERENCES public.keycloak_group(id);


--
-- Name: realm_enabled_event_types fk_h846o4h0w8epx5nwedrf5y69j; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_enabled_event_types
    ADD CONSTRAINT fk_h846o4h0w8epx5nwedrf5y69j FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_events_listeners fk_h846o4h0w8epx5nxev9f5y69j; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_events_listeners
    ADD CONSTRAINT fk_h846o4h0w8epx5nxev9f5y69j FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: identity_provider_mapper fk_idpm_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.identity_provider_mapper
    ADD CONSTRAINT fk_idpm_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: idp_mapper_config fk_idpmconfig; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.idp_mapper_config
    ADD CONSTRAINT fk_idpmconfig FOREIGN KEY (idp_mapper_id) REFERENCES public.identity_provider_mapper(id);


--
-- Name: web_origins fk_lojpho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.web_origins
    ADD CONSTRAINT fk_lojpho213xcx4wnkog82ssrfy FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: org_invitation fk_org_invitation_org; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.org_invitation
    ADD CONSTRAINT fk_org_invitation_org FOREIGN KEY (organization_id) REFERENCES public.org(id) ON DELETE CASCADE;


--
-- Name: scope_mapping fk_ouse064plmlr732lxjcn1q5f1; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.scope_mapping
    ADD CONSTRAINT fk_ouse064plmlr732lxjcn1q5f1 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: protocol_mapper fk_pcm_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT fk_pcm_realm FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: credential fk_pfyr0glasqyl0dei3kl69r6v0; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.credential
    ADD CONSTRAINT fk_pfyr0glasqyl0dei3kl69r6v0 FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: protocol_mapper_config fk_pmconfig; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.protocol_mapper_config
    ADD CONSTRAINT fk_pmconfig FOREIGN KEY (protocol_mapper_id) REFERENCES public.protocol_mapper(id);


--
-- Name: default_client_scope fk_r_def_cli_scope_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.default_client_scope
    ADD CONSTRAINT fk_r_def_cli_scope_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: required_action_provider fk_req_act_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.required_action_provider
    ADD CONSTRAINT fk_req_act_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: resource_uris fk_resource_server_uris; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.resource_uris
    ADD CONSTRAINT fk_resource_server_uris FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: role_attribute fk_role_attribute_id; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.role_attribute
    ADD CONSTRAINT fk_role_attribute_id FOREIGN KEY (role_id) REFERENCES public.keycloak_role(id);


--
-- Name: realm_supported_locales fk_supported_locales_realm; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.realm_supported_locales
    ADD CONSTRAINT fk_supported_locales_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: user_federation_config fk_t13hpu1j94r2ebpekr39x5eu5; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_federation_config
    ADD CONSTRAINT fk_t13hpu1j94r2ebpekr39x5eu5 FOREIGN KEY (user_federation_provider_id) REFERENCES public.user_federation_provider(id);


--
-- Name: user_group_membership fk_user_group_user; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.user_group_membership
    ADD CONSTRAINT fk_user_group_user FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: policy_config fkdc34197cf864c4e43; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.policy_config
    ADD CONSTRAINT fkdc34197cf864c4e43 FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: identity_provider_config fkdc4897cf864c4e43; Type: FK CONSTRAINT; Schema: public; Owner: keycloak
--

ALTER TABLE ONLY public.identity_provider_config
    ADD CONSTRAINT fkdc4897cf864c4e43 FOREIGN KEY (identity_provider_id) REFERENCES public.identity_provider(internal_id);


--
-- PostgreSQL database dump complete
--

\unrestrict ti7qmjmVI848d2j5SDajjMZpn4M5hg0VbT2zWcQDaC2ABgDiIH4S6nTfryLFkJF

