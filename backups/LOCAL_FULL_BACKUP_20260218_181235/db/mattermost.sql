--
-- PostgreSQL database dump
--

\restrict XtJlgehMjOeoL7eWs46XWomRn8hyidw0kHpukZwiI9sK1h0jGShGzyEIFAbUlBL

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

--
-- Name: channel_bookmark_type; Type: TYPE; Schema: public; Owner: mmuser
--

CREATE TYPE public.channel_bookmark_type AS ENUM (
    'link',
    'file'
);


ALTER TYPE public.channel_bookmark_type OWNER TO mmuser;

--
-- Name: channel_type; Type: TYPE; Schema: public; Owner: mmuser
--

CREATE TYPE public.channel_type AS ENUM (
    'P',
    'G',
    'O',
    'D'
);


ALTER TYPE public.channel_type OWNER TO mmuser;

--
-- Name: outgoingoauthconnections_granttype; Type: TYPE; Schema: public; Owner: mmuser
--

CREATE TYPE public.outgoingoauthconnections_granttype AS ENUM (
    'client_credentials',
    'password'
);


ALTER TYPE public.outgoingoauthconnections_granttype OWNER TO mmuser;

--
-- Name: property_field_type; Type: TYPE; Schema: public; Owner: mmuser
--

CREATE TYPE public.property_field_type AS ENUM (
    'text',
    'select',
    'multiselect',
    'date',
    'user',
    'multiuser'
);


ALTER TYPE public.property_field_type OWNER TO mmuser;

--
-- Name: team_type; Type: TYPE; Schema: public; Owner: mmuser
--

CREATE TYPE public.team_type AS ENUM (
    'I',
    'O'
);


ALTER TYPE public.team_type OWNER TO mmuser;

--
-- Name: upload_session_type; Type: TYPE; Schema: public; Owner: mmuser
--

CREATE TYPE public.upload_session_type AS ENUM (
    'attachment',
    'import'
);


ALTER TYPE public.upload_session_type OWNER TO mmuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accesscontrolpolicies; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.accesscontrolpolicies (
    id character varying(26) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    active boolean NOT NULL,
    createat bigint NOT NULL,
    revision integer NOT NULL,
    version character varying(8) NOT NULL,
    data jsonb,
    props jsonb
);


ALTER TABLE public.accesscontrolpolicies OWNER TO mmuser;

--
-- Name: accesscontrolpolicyhistory; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.accesscontrolpolicyhistory (
    id character varying(26) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    createat bigint NOT NULL,
    revision integer NOT NULL,
    version character varying(8) NOT NULL,
    data jsonb,
    props jsonb
);


ALTER TABLE public.accesscontrolpolicyhistory OWNER TO mmuser;

--
-- Name: propertyfields; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.propertyfields (
    id character varying(26) NOT NULL,
    groupid character varying(26) NOT NULL,
    name character varying(255) NOT NULL,
    type public.property_field_type,
    attrs jsonb,
    targetid character varying(255),
    targettype character varying(255),
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint NOT NULL
);


ALTER TABLE public.propertyfields OWNER TO mmuser;

--
-- Name: propertyvalues; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.propertyvalues (
    id character varying(26) NOT NULL,
    targetid character varying(255) NOT NULL,
    targettype character varying(255) NOT NULL,
    groupid character varying(26) NOT NULL,
    fieldid character varying(26) NOT NULL,
    value jsonb NOT NULL,
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint NOT NULL
);


ALTER TABLE public.propertyvalues OWNER TO mmuser;

--
-- Name: attributeview; Type: MATERIALIZED VIEW; Schema: public; Owner: mmuser
--

CREATE MATERIALIZED VIEW public.attributeview AS
 SELECT pv.groupid,
    pv.targetid,
    pv.targettype,
    jsonb_object_agg(pf.name,
        CASE
            WHEN (pf.type = 'select'::public.property_field_type) THEN ( SELECT to_jsonb(options.name) AS to_jsonb
               FROM jsonb_to_recordset((pf.attrs -> 'options'::text)) options(id text, name text)
              WHERE (options.id = (pv.value #>> '{}'::text[]))
             LIMIT 1)
            WHEN ((pf.type = 'multiselect'::public.property_field_type) AND (jsonb_typeof(pv.value) = 'array'::text)) THEN ( SELECT jsonb_agg(option_names.name) AS jsonb_agg
               FROM (jsonb_array_elements_text(pv.value) option_id(value)
                 JOIN jsonb_to_recordset((pf.attrs -> 'options'::text)) option_names(id text, name text) ON ((option_id.value = option_names.id))))
            ELSE pv.value
        END) AS attributes
   FROM (public.propertyvalues pv
     LEFT JOIN public.propertyfields pf ON (((pf.id)::text = (pv.fieldid)::text)))
  WHERE (((pv.deleteat = 0) OR (pv.deleteat IS NULL)) AND ((pf.deleteat = 0) OR (pf.deleteat IS NULL)))
  GROUP BY pv.groupid, pv.targetid, pv.targettype
  WITH NO DATA;


ALTER TABLE public.attributeview OWNER TO mmuser;

--
-- Name: audits; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.audits (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    action character varying(512),
    extrainfo character varying(1024),
    ipaddress character varying(64),
    sessionid character varying(26)
);


ALTER TABLE public.audits OWNER TO mmuser;

--
-- Name: bots; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.bots (
    userid character varying(26) NOT NULL,
    description character varying(1024),
    ownerid character varying(190),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    lasticonupdate bigint
);


ALTER TABLE public.bots OWNER TO mmuser;

--
-- Name: channels; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.channels (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    teamid character varying(26),
    type public.channel_type,
    displayname character varying(64),
    name character varying(64),
    header character varying(1024),
    purpose character varying(250),
    lastpostat bigint,
    totalmsgcount bigint,
    extraupdateat bigint,
    creatorid character varying(26),
    schemeid character varying(26),
    groupconstrained boolean,
    shared boolean,
    totalmsgcountroot bigint,
    lastrootpostat bigint DEFAULT '0'::bigint,
    bannerinfo jsonb,
    defaultcategoryname character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.channels OWNER TO mmuser;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.posts (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26),
    channelid character varying(26),
    rootid character varying(26),
    originalid character varying(26),
    message character varying(65535),
    type character varying(26),
    props jsonb,
    hashtags character varying(1000),
    filenames character varying(4000),
    fileids character varying(300),
    hasreactions boolean,
    editat bigint,
    ispinned boolean,
    remoteid character varying(26)
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


ALTER TABLE public.posts OWNER TO mmuser;

--
-- Name: bot_posts_by_team_day; Type: MATERIALIZED VIEW; Schema: public; Owner: mmuser
--

CREATE MATERIALIZED VIEW public.bot_posts_by_team_day AS
 SELECT (to_timestamp(((p.createat / 1000))::double precision))::date AS day,
    count(*) AS num,
    c.teamid
   FROM ((public.posts p
     JOIN public.bots b ON (((p.userid)::text = (b.userid)::text)))
     JOIN public.channels c ON (((p.channelid)::text = (c.id)::text)))
  GROUP BY ((to_timestamp(((p.createat / 1000))::double precision))::date), c.teamid
  WITH NO DATA;


ALTER TABLE public.bot_posts_by_team_day OWNER TO mmuser;

--
-- Name: calls; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.calls (
    id character varying(26) NOT NULL,
    channelid character varying(26),
    startat bigint,
    endat bigint,
    createat bigint,
    deleteat bigint,
    title character varying(256),
    postid character varying(26),
    threadid character varying(26),
    ownerid character varying(26),
    participants jsonb NOT NULL,
    stats jsonb NOT NULL,
    props jsonb NOT NULL
);


ALTER TABLE public.calls OWNER TO mmuser;

--
-- Name: calls_channels; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.calls_channels (
    channelid character varying(26) NOT NULL,
    enabled boolean,
    props jsonb NOT NULL
);


ALTER TABLE public.calls_channels OWNER TO mmuser;

--
-- Name: calls_jobs; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.calls_jobs (
    id character varying(26) NOT NULL,
    callid character varying(26),
    type character varying(64),
    creatorid character varying(26),
    initat bigint,
    startat bigint,
    endat bigint,
    props jsonb NOT NULL
);


ALTER TABLE public.calls_jobs OWNER TO mmuser;

--
-- Name: calls_sessions; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.calls_sessions (
    id character varying(26) NOT NULL,
    callid character varying(26),
    userid character varying(26),
    joinat bigint,
    unmuted boolean,
    raisedhand bigint
);


ALTER TABLE public.calls_sessions OWNER TO mmuser;

--
-- Name: channelbookmarks; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.channelbookmarks (
    id character varying(26) NOT NULL,
    ownerid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    fileinfoid character varying(26) DEFAULT NULL::character varying,
    createat bigint DEFAULT 0,
    updateat bigint DEFAULT 0,
    deleteat bigint DEFAULT 0,
    displayname text DEFAULT ''::text,
    sortorder integer DEFAULT 0,
    linkurl text,
    imageurl text,
    emoji character varying(64) DEFAULT NULL::character varying,
    type public.channel_bookmark_type DEFAULT 'link'::public.channel_bookmark_type,
    originalid character varying(26) DEFAULT NULL::character varying,
    parentid character varying(26) DEFAULT NULL::character varying
);


ALTER TABLE public.channelbookmarks OWNER TO mmuser;

--
-- Name: channelmemberhistory; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.channelmemberhistory (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    jointime bigint NOT NULL,
    leavetime bigint
);


ALTER TABLE public.channelmemberhistory OWNER TO mmuser;

--
-- Name: channelmembers; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.channelmembers (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    roles character varying(256),
    lastviewedat bigint,
    msgcount bigint,
    mentioncount bigint,
    notifyprops jsonb,
    lastupdateat bigint,
    schemeuser boolean,
    schemeadmin boolean,
    schemeguest boolean,
    mentioncountroot bigint,
    msgcountroot bigint,
    urgentmentioncount bigint
);


ALTER TABLE public.channelmembers OWNER TO mmuser;

--
-- Name: clusterdiscovery; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.clusterdiscovery (
    id character varying(26) NOT NULL,
    type character varying(64),
    clustername character varying(64),
    hostname character varying(512),
    gossipport integer,
    port integer,
    createat bigint,
    lastpingat bigint
);


ALTER TABLE public.clusterdiscovery OWNER TO mmuser;

--
-- Name: commands; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.commands (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    teamid character varying(26),
    trigger character varying(128),
    method character varying(1),
    username character varying(64),
    iconurl character varying(1024),
    autocomplete boolean,
    autocompletedesc character varying(1024),
    autocompletehint character varying(1024),
    displayname character varying(64),
    description character varying(128),
    url character varying(1024),
    pluginid character varying(190)
);


ALTER TABLE public.commands OWNER TO mmuser;

--
-- Name: commandwebhooks; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.commandwebhooks (
    id character varying(26) NOT NULL,
    createat bigint,
    commandid character varying(26),
    userid character varying(26),
    channelid character varying(26),
    rootid character varying(26),
    usecount integer
);


ALTER TABLE public.commandwebhooks OWNER TO mmuser;

--
-- Name: compliances; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.compliances (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    status character varying(64),
    count integer,
    "desc" character varying(512),
    type character varying(64),
    startat bigint,
    endat bigint,
    keywords character varying(512),
    emails character varying(1024)
);


ALTER TABLE public.compliances OWNER TO mmuser;

--
-- Name: contentflaggingcommonreviewers; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.contentflaggingcommonreviewers (
    userid character varying(26) NOT NULL
);


ALTER TABLE public.contentflaggingcommonreviewers OWNER TO mmuser;

--
-- Name: contentflaggingteamreviewers; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.contentflaggingteamreviewers (
    teamid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL
);


ALTER TABLE public.contentflaggingteamreviewers OWNER TO mmuser;

--
-- Name: contentflaggingteamsettings; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.contentflaggingteamsettings (
    teamid character varying(26) NOT NULL,
    enabled boolean
);


ALTER TABLE public.contentflaggingteamsettings OWNER TO mmuser;

--
-- Name: db_lock; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.db_lock (
    id character varying(64) NOT NULL,
    expireat bigint
);


ALTER TABLE public.db_lock OWNER TO mmuser;

--
-- Name: db_migrations; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.db_migrations (
    version bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.db_migrations OWNER TO mmuser;

--
-- Name: db_migrations_calls; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.db_migrations_calls (
    version bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.db_migrations_calls OWNER TO mmuser;

--
-- Name: desktoptokens; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.desktoptokens (
    token character varying(64) NOT NULL,
    createat bigint NOT NULL,
    userid character varying(26) NOT NULL
);


ALTER TABLE public.desktoptokens OWNER TO mmuser;

--
-- Name: drafts; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.drafts (
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    rootid character varying(26) DEFAULT ''::character varying NOT NULL,
    message character varying(65535),
    props character varying(8000),
    fileids character varying(300),
    priority text
);


ALTER TABLE public.drafts OWNER TO mmuser;

--
-- Name: emoji; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.emoji (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    name character varying(64)
);


ALTER TABLE public.emoji OWNER TO mmuser;

--
-- Name: fileinfo; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.fileinfo (
    id character varying(26) NOT NULL,
    creatorid character varying(26),
    postid character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    path character varying(512),
    thumbnailpath character varying(512),
    previewpath character varying(512),
    name character varying(256),
    extension character varying(64),
    size bigint,
    mimetype character varying(256),
    width integer,
    height integer,
    haspreviewimage boolean,
    minipreview bytea,
    content text,
    remoteid character varying(26),
    archived boolean DEFAULT false NOT NULL,
    channelid character varying(26)
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


ALTER TABLE public.fileinfo OWNER TO mmuser;

--
-- Name: file_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: mmuser
--

CREATE MATERIALIZED VIEW public.file_stats AS
 SELECT count(*) AS num,
    COALESCE(sum(fileinfo.size), (0)::numeric) AS usage
   FROM public.fileinfo
  WHERE (fileinfo.deleteat = 0)
  WITH NO DATA;


ALTER TABLE public.file_stats OWNER TO mmuser;

--
-- Name: groupchannels; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.groupchannels (
    groupid character varying(26) NOT NULL,
    autoadd boolean,
    schemeadmin boolean,
    createat bigint,
    deleteat bigint,
    updateat bigint,
    channelid character varying(26) NOT NULL
);


ALTER TABLE public.groupchannels OWNER TO mmuser;

--
-- Name: groupmembers; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.groupmembers (
    groupid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    createat bigint,
    deleteat bigint
);


ALTER TABLE public.groupmembers OWNER TO mmuser;

--
-- Name: groupteams; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.groupteams (
    groupid character varying(26) NOT NULL,
    autoadd boolean,
    schemeadmin boolean,
    createat bigint,
    deleteat bigint,
    updateat bigint,
    teamid character varying(26) NOT NULL
);


ALTER TABLE public.groupteams OWNER TO mmuser;

--
-- Name: incomingwebhooks; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.incomingwebhooks (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26),
    channelid character varying(26),
    teamid character varying(26),
    displayname character varying(64),
    description character varying(500),
    username character varying(255),
    iconurl character varying(1024),
    channellocked boolean
);


ALTER TABLE public.incomingwebhooks OWNER TO mmuser;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.jobs (
    id character varying(26) NOT NULL,
    type character varying(32),
    priority bigint,
    createat bigint,
    startat bigint,
    lastactivityat bigint,
    status character varying(32),
    progress bigint,
    data jsonb
);


ALTER TABLE public.jobs OWNER TO mmuser;

--
-- Name: licenses; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.licenses (
    id character varying(26) NOT NULL,
    createat bigint,
    bytes character varying(10000)
);


ALTER TABLE public.licenses OWNER TO mmuser;

--
-- Name: linkmetadata; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.linkmetadata (
    hash bigint NOT NULL,
    url character varying(2048),
    "timestamp" bigint,
    type character varying(16),
    data jsonb
);


ALTER TABLE public.linkmetadata OWNER TO mmuser;

--
-- Name: llm_postmeta; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.llm_postmeta (
    rootpostid text NOT NULL,
    title text NOT NULL
);


ALTER TABLE public.llm_postmeta OWNER TO mmuser;

--
-- Name: notifyadmin; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.notifyadmin (
    userid character varying(26) NOT NULL,
    createat bigint,
    requiredplan character varying(100) NOT NULL,
    requiredfeature character varying(255) NOT NULL,
    trial boolean NOT NULL,
    sentat bigint
);


ALTER TABLE public.notifyadmin OWNER TO mmuser;

--
-- Name: oauthaccessdata; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.oauthaccessdata (
    token character varying(26) NOT NULL,
    refreshtoken character varying(26),
    redirecturi character varying(256),
    clientid character varying(26),
    userid character varying(26),
    expiresat bigint,
    scope character varying(128),
    audience character varying(512) DEFAULT ''::character varying
);


ALTER TABLE public.oauthaccessdata OWNER TO mmuser;

--
-- Name: oauthapps; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.oauthapps (
    id character varying(26) NOT NULL,
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    clientsecret character varying(128),
    name character varying(64),
    description character varying(512),
    callbackurls character varying(1024),
    homepage character varying(256),
    istrusted boolean,
    iconurl character varying(512),
    mattermostappid character varying(32) DEFAULT ''::character varying NOT NULL,
    isdynamicallyregistered boolean DEFAULT false
);


ALTER TABLE public.oauthapps OWNER TO mmuser;

--
-- Name: oauthauthdata; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.oauthauthdata (
    clientid character varying(26),
    userid character varying(26),
    code character varying(128) NOT NULL,
    expiresin integer,
    createat bigint,
    redirecturi character varying(256),
    state character varying(1024),
    scope character varying(128),
    codechallenge character varying(128) DEFAULT ''::character varying,
    codechallengemethod character varying(10) DEFAULT ''::character varying,
    resource character varying(512) DEFAULT ''::character varying
);


ALTER TABLE public.oauthauthdata OWNER TO mmuser;

--
-- Name: outgoingoauthconnections; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.outgoingoauthconnections (
    id character varying(26) NOT NULL,
    name character varying(64),
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    clientid character varying(255),
    clientsecret character varying(255),
    credentialsusername character varying(255),
    credentialspassword character varying(255),
    oauthtokenurl text,
    granttype public.outgoingoauthconnections_granttype DEFAULT 'client_credentials'::public.outgoingoauthconnections_granttype,
    audiences character varying(1024)
);


ALTER TABLE public.outgoingoauthconnections OWNER TO mmuser;

--
-- Name: outgoingwebhooks; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.outgoingwebhooks (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    channelid character varying(26),
    teamid character varying(26),
    triggerwords character varying(1024),
    callbackurls character varying(1024),
    displayname character varying(64),
    contenttype character varying(128),
    triggerwhen integer,
    username character varying(64),
    iconurl character varying(1024),
    description character varying(500)
);


ALTER TABLE public.outgoingwebhooks OWNER TO mmuser;

--
-- Name: persistentnotifications; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.persistentnotifications (
    postid character varying(26) NOT NULL,
    createat bigint,
    lastsentat bigint,
    deleteat bigint,
    sentcount smallint
);


ALTER TABLE public.persistentnotifications OWNER TO mmuser;

--
-- Name: pluginkeyvaluestore; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.pluginkeyvaluestore (
    pluginid character varying(190) NOT NULL,
    pkey character varying(150) NOT NULL,
    pvalue bytea,
    expireat bigint
);


ALTER TABLE public.pluginkeyvaluestore OWNER TO mmuser;

--
-- Name: postacknowledgements; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.postacknowledgements (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    acknowledgedat bigint,
    remoteid character varying(26) DEFAULT ''::character varying,
    channelid character varying(26) DEFAULT ''::character varying
);


ALTER TABLE public.postacknowledgements OWNER TO mmuser;

--
-- Name: postreminders; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.postreminders (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    targettime bigint
);


ALTER TABLE public.postreminders OWNER TO mmuser;

--
-- Name: posts_by_team_day; Type: MATERIALIZED VIEW; Schema: public; Owner: mmuser
--

CREATE MATERIALIZED VIEW public.posts_by_team_day AS
 SELECT (to_timestamp(((p.createat / 1000))::double precision))::date AS day,
    count(*) AS num,
    c.teamid
   FROM (public.posts p
     JOIN public.channels c ON (((p.channelid)::text = (c.id)::text)))
  GROUP BY ((to_timestamp(((p.createat / 1000))::double precision))::date), c.teamid
  WITH NO DATA;


ALTER TABLE public.posts_by_team_day OWNER TO mmuser;

--
-- Name: postspriority; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.postspriority (
    postid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    priority character varying(32) NOT NULL,
    requestedack boolean,
    persistentnotifications boolean
);


ALTER TABLE public.postspriority OWNER TO mmuser;

--
-- Name: poststats; Type: MATERIALIZED VIEW; Schema: public; Owner: mmuser
--

CREATE MATERIALIZED VIEW public.poststats AS
 SELECT posts.userid,
    (to_timestamp(((posts.createat / 1000))::double precision))::date AS day,
    count(*) AS numposts,
    max(posts.createat) AS lastpostdate
   FROM public.posts
  GROUP BY posts.userid, ((to_timestamp(((posts.createat / 1000))::double precision))::date)
  WITH NO DATA;


ALTER TABLE public.poststats OWNER TO mmuser;

--
-- Name: preferences; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.preferences (
    userid character varying(26) NOT NULL,
    category character varying(32) NOT NULL,
    name character varying(32) NOT NULL,
    value text
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


ALTER TABLE public.preferences OWNER TO mmuser;

--
-- Name: productnoticeviewstate; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.productnoticeviewstate (
    userid character varying(26) NOT NULL,
    noticeid character varying(26) NOT NULL,
    viewed integer,
    "timestamp" bigint
);


ALTER TABLE public.productnoticeviewstate OWNER TO mmuser;

--
-- Name: propertygroups; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.propertygroups (
    id character varying(26) NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.propertygroups OWNER TO mmuser;

--
-- Name: publicchannels; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.publicchannels (
    id character varying(26) NOT NULL,
    deleteat bigint,
    teamid character varying(26),
    displayname character varying(64),
    name character varying(64),
    header character varying(1024),
    purpose character varying(250)
);


ALTER TABLE public.publicchannels OWNER TO mmuser;

--
-- Name: reactions; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.reactions (
    userid character varying(26) NOT NULL,
    postid character varying(26) NOT NULL,
    emojiname character varying(64) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    remoteid character varying(26),
    channelid character varying(26) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.reactions OWNER TO mmuser;

--
-- Name: recentsearches; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.recentsearches (
    userid character(26) NOT NULL,
    searchpointer integer NOT NULL,
    query jsonb,
    createat bigint NOT NULL
);


ALTER TABLE public.recentsearches OWNER TO mmuser;

--
-- Name: remoteclusters; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.remoteclusters (
    remoteid character varying(26) NOT NULL,
    remoteteamid character varying(26),
    name character varying(64) NOT NULL,
    displayname character varying(64),
    siteurl character varying(512),
    createat bigint,
    lastpingat bigint,
    token character varying(26),
    remotetoken character varying(26),
    topics character varying(512),
    creatorid character varying(26),
    pluginid character varying(190) DEFAULT ''::character varying NOT NULL,
    options smallint DEFAULT 0 NOT NULL,
    defaultteamid character varying(26) DEFAULT ''::character varying,
    deleteat bigint DEFAULT 0,
    lastglobalusersyncat bigint DEFAULT 0
);


ALTER TABLE public.remoteclusters OWNER TO mmuser;

--
-- Name: retentionidsfordeletion; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.retentionidsfordeletion (
    id character varying(26) NOT NULL,
    tablename character varying(64),
    ids character varying(26)[]
);


ALTER TABLE public.retentionidsfordeletion OWNER TO mmuser;

--
-- Name: retentionpolicies; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.retentionpolicies (
    id character varying(26) NOT NULL,
    displayname character varying(64),
    postduration bigint
);


ALTER TABLE public.retentionpolicies OWNER TO mmuser;

--
-- Name: retentionpolicieschannels; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.retentionpolicieschannels (
    policyid character varying(26),
    channelid character varying(26) NOT NULL
);


ALTER TABLE public.retentionpolicieschannels OWNER TO mmuser;

--
-- Name: retentionpoliciesteams; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.retentionpoliciesteams (
    policyid character varying(26),
    teamid character varying(26) NOT NULL
);


ALTER TABLE public.retentionpoliciesteams OWNER TO mmuser;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.roles (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    permissions text,
    schememanaged boolean,
    builtin boolean
);


ALTER TABLE public.roles OWNER TO mmuser;

--
-- Name: scheduledposts; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.scheduledposts (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    userid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    rootid character varying(26),
    message character varying(65535),
    props character varying(8000),
    fileids character varying(300),
    priority text,
    scheduledat bigint NOT NULL,
    processedat bigint,
    errorcode character varying(200)
);


ALTER TABLE public.scheduledposts OWNER TO mmuser;

--
-- Name: schemes; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.schemes (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    scope character varying(32),
    defaultteamadminrole character varying(64),
    defaultteamuserrole character varying(64),
    defaultchanneladminrole character varying(64),
    defaultchanneluserrole character varying(64),
    defaultteamguestrole character varying(64),
    defaultchannelguestrole character varying(64),
    defaultplaybookadminrole character varying(64) DEFAULT ''::character varying,
    defaultplaybookmemberrole character varying(64) DEFAULT ''::character varying,
    defaultrunadminrole character varying(64) DEFAULT ''::character varying,
    defaultrunmemberrole character varying(64) DEFAULT ''::character varying
);


ALTER TABLE public.schemes OWNER TO mmuser;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.sessions (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    expiresat bigint,
    lastactivityat bigint,
    userid character varying(26),
    deviceid character varying(512),
    roles character varying(256),
    isoauth boolean,
    props jsonb,
    expirednotify boolean
);


ALTER TABLE public.sessions OWNER TO mmuser;

--
-- Name: sharedchannelattachments; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.sharedchannelattachments (
    id character varying(26) NOT NULL,
    fileid character varying(26),
    remoteid character varying(26),
    createat bigint,
    lastsyncat bigint
);


ALTER TABLE public.sharedchannelattachments OWNER TO mmuser;

--
-- Name: sharedchannelremotes; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.sharedchannelremotes (
    id character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    isinviteaccepted boolean,
    isinviteconfirmed boolean,
    remoteid character varying(26),
    lastpostupdateat bigint,
    lastpostid character varying(26),
    lastpostcreateat bigint DEFAULT 0 NOT NULL,
    lastpostcreateid character varying(26),
    deleteat bigint DEFAULT 0,
    lastmemberssyncat bigint DEFAULT 0
);


ALTER TABLE public.sharedchannelremotes OWNER TO mmuser;

--
-- Name: sharedchannels; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.sharedchannels (
    channelid character varying(26) NOT NULL,
    teamid character varying(26),
    home boolean,
    readonly boolean,
    sharename character varying(64),
    sharedisplayname character varying(64),
    sharepurpose character varying(250),
    shareheader character varying(1024),
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    remoteid character varying(26)
);


ALTER TABLE public.sharedchannels OWNER TO mmuser;

--
-- Name: sharedchannelusers; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.sharedchannelusers (
    id character varying(26) NOT NULL,
    userid character varying(26),
    remoteid character varying(26),
    createat bigint,
    lastsyncat bigint,
    channelid character varying(26),
    lastmembershipsyncat bigint DEFAULT 0
);


ALTER TABLE public.sharedchannelusers OWNER TO mmuser;

--
-- Name: sidebarcategories; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.sidebarcategories (
    id character varying(128) NOT NULL,
    userid character varying(26),
    teamid character varying(26),
    sortorder bigint,
    sorting character varying(64),
    type character varying(64),
    displayname character varying(64),
    muted boolean,
    collapsed boolean
);


ALTER TABLE public.sidebarcategories OWNER TO mmuser;

--
-- Name: sidebarchannels; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.sidebarchannels (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    categoryid character varying(128) NOT NULL,
    sortorder bigint
);


ALTER TABLE public.sidebarchannels OWNER TO mmuser;

--
-- Name: status; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.status (
    userid character varying(26) NOT NULL,
    status character varying(32),
    manual boolean,
    lastactivityat bigint,
    dndendtime bigint,
    prevstatus character varying(32)
);


ALTER TABLE public.status OWNER TO mmuser;

--
-- Name: systems; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.systems (
    name character varying(64) NOT NULL,
    value character varying(1024)
);


ALTER TABLE public.systems OWNER TO mmuser;

--
-- Name: teammembers; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.teammembers (
    teamid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    roles character varying(256),
    deleteat bigint,
    schemeuser boolean,
    schemeadmin boolean,
    schemeguest boolean,
    createat bigint DEFAULT 0
);


ALTER TABLE public.teammembers OWNER TO mmuser;

--
-- Name: teams; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.teams (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    displayname character varying(64),
    name character varying(64),
    description character varying(255),
    email character varying(128),
    type public.team_type,
    companyname character varying(64),
    alloweddomains character varying(1000),
    inviteid character varying(32),
    schemeid character varying(26),
    allowopeninvite boolean,
    lastteamiconupdate bigint,
    groupconstrained boolean,
    cloudlimitsarchived boolean DEFAULT false NOT NULL
);


ALTER TABLE public.teams OWNER TO mmuser;

--
-- Name: termsofservice; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.termsofservice (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    text character varying(65535)
);


ALTER TABLE public.termsofservice OWNER TO mmuser;

--
-- Name: threadmemberships; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.threadmemberships (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    following boolean,
    lastviewed bigint,
    lastupdated bigint,
    unreadmentions bigint
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


ALTER TABLE public.threadmemberships OWNER TO mmuser;

--
-- Name: threads; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.threads (
    postid character varying(26) NOT NULL,
    replycount bigint,
    lastreplyat bigint,
    participants jsonb,
    channelid character varying(26),
    threaddeleteat bigint,
    threadteamid character varying(26)
);


ALTER TABLE public.threads OWNER TO mmuser;

--
-- Name: tokens; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.tokens (
    token character varying(64) NOT NULL,
    createat bigint,
    type character varying(64),
    extra character varying(2048)
);


ALTER TABLE public.tokens OWNER TO mmuser;

--
-- Name: uploadsessions; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.uploadsessions (
    id character varying(26) NOT NULL,
    type public.upload_session_type,
    createat bigint,
    userid character varying(26),
    channelid character varying(26),
    filename character varying(256),
    path character varying(512),
    filesize bigint,
    fileoffset bigint,
    remoteid character varying(26),
    reqfileid character varying(26)
);


ALTER TABLE public.uploadsessions OWNER TO mmuser;

--
-- Name: useraccesstokens; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.useraccesstokens (
    id character varying(26) NOT NULL,
    token character varying(26),
    userid character varying(26),
    description character varying(512),
    isactive boolean
);


ALTER TABLE public.useraccesstokens OWNER TO mmuser;

--
-- Name: usergroups; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.usergroups (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    source character varying(64),
    remoteid character varying(48),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    allowreference boolean
);


ALTER TABLE public.usergroups OWNER TO mmuser;

--
-- Name: users; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.users (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    username character varying(64),
    password character varying(128),
    authdata character varying(128),
    authservice character varying(32),
    email character varying(128),
    emailverified boolean,
    nickname character varying(64),
    firstname character varying(64),
    lastname character varying(64),
    roles character varying(256),
    allowmarketing boolean,
    props jsonb,
    notifyprops jsonb,
    lastpasswordupdate bigint,
    lastpictureupdate bigint,
    failedattempts integer,
    locale character varying(5),
    mfaactive boolean,
    mfasecret character varying(128),
    "position" character varying(128),
    timezone jsonb,
    remoteid character varying(26),
    lastlogin bigint DEFAULT 0 NOT NULL,
    mfausedtimestamps jsonb
);


ALTER TABLE public.users OWNER TO mmuser;

--
-- Name: usertermsofservice; Type: TABLE; Schema: public; Owner: mmuser
--

CREATE TABLE public.usertermsofservice (
    userid character varying(26) NOT NULL,
    termsofserviceid character varying(26),
    createat bigint
);


ALTER TABLE public.usertermsofservice OWNER TO mmuser;

--
-- Data for Name: accesscontrolpolicies; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.accesscontrolpolicies (id, name, type, active, createat, revision, version, data, props) FROM stdin;
\.


--
-- Data for Name: accesscontrolpolicyhistory; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.accesscontrolpolicyhistory (id, name, type, createat, revision, version, data, props) FROM stdin;
\.


--
-- Data for Name: audits; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.audits (id, createat, userid, action, extrainfo, ipaddress, sessionid) FROM stdin;
uetzjijkzb8cz8njur7c9z7ony	1771232683135	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/login	attempt - login_id=	172.67.180.55	
3z8nzgpg6byhxbbh33w3gaco8h	1771232683589	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/login	authenticated	172.67.180.55	
z1ishrsypinnpbizu5id3i355a	1771232683595	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/login	success session_user=4num934yzfb9udo1zdwxwd7gjc	172.67.180.55	49ui14tyejbrjxt4eks7dxsyur
wg8oinmaaib33yzua4k7m4bqjh	1771232683708	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/me/patch		172.67.180.55	49ui14tyejbrjxt4eks7dxsyur
wqjc3m7kktf5dbcsbcgi5f81ra	1771232683722	4num934yzfb9udo1zdwxwd7gjc	/api/v4/system/onboarding/complete	attempt	172.67.180.55	49ui14tyejbrjxt4eks7dxsyur
yhnetpwimp8f5jhg7ip3so7u5a	1771232701912	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/logout		172.67.180.55	49ui14tyejbrjxt4eks7dxsyur
ff49atea93ghif1kj9h8mbbm1e	1771232846824		/api/v4/users/login	attempt - login_id=admin	172.67.180.55	
u58i8368fjgjdkhj14ky7nyj9h	1771232847291	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/login	authenticated	172.67.180.55	
eed6sbduuiyb9qy3dozn36gj7a	1771232847294	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/login	success session_user=4num934yzfb9udo1zdwxwd7gjc	172.67.180.55	k7ycqrwssjg1ugtxzqg8necqkw
kkbhwmg18pyx9p6ag6qgzsd61o	1771233063791	4num934yzfb9udo1zdwxwd7gjc	/api/v4/users/logout		172.67.180.55	k7ycqrwssjg1ugtxzqg8necqkw
e31ekrzt4brwmdzga3nngptrmc	1771233063833		/api/v4/users/logout		172.67.180.55	
k73gt5kmxbbn7qzdne3cyjmoyo	1771233065792		/oauth/gitlab/login	success	172.67.180.55	
ez9w5m4je3nm9d8ksh9duw6hme	1771233194019		/oauth/gitlab/login	success	194.254.109.170	
35yc1hm3ot84dmpyw4af9as6cr	1771233199630		/oauth/gitlab/login	success	194.254.109.170	
mzoa4afrsidepxfsnpjp6f6oxr	1771233212598		/oauth/gitlab/login	success	194.254.109.170	
tutnahyd4bgxfxu1rmzk34t8ch	1771233348303		/oauth/gitlab/login	success	194.254.109.170	
\.


--
-- Data for Name: bots; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.bots (userid, description, ownerid, createat, updateat, deleteat, lasticonupdate) FROM stdin;
qw9175rnt7yyjbtwczmx1y3z5y	Calls Bot	com.mattermost.calls	1769687704469	1769687704469	0	0
fne5rqz9u3fzfdmdxna1tfw5ro	A bot account created by the ServiceNow plugin.	mattermost-plugin-servicenow	1771232696102	1771232696102	0	0
j4a8f886hpgbxefoufyyepqkeh	A bot account created by the plugin GitLab.	com.github.manland.mattermost-plugin-gitlab	1771232697383	1771232697383	0	0
gxtta9hxf7gpup4xfpgpddfapo	Created by the Jira Plugin.	jira	1771232697460	1771232697460	0	0
7zmzqjej63838kcqaz5xsuh1yo	Created by the GitHub plugin.	github	1771232697539	1771232697539	0	0
gk3t4rqfq3fh7fim776puakuee		4num934yzfb9udo1zdwxwd7gjc	1771232699001	1771232699001	0	0
39bi4ca55jnazg885s3rj9j1ka	Feedbackbot collects user feedback to improve Mattermost. [Learn more](https://mattermost.com/pl/default-nps).	com.mattermost.nps	1771233027689	1771233027689	0	0
\.


--
-- Data for Name: calls; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.calls (id, channelid, startat, endat, createat, deleteat, title, postid, threadid, ownerid, participants, stats, props) FROM stdin;
\.


--
-- Data for Name: calls_channels; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.calls_channels (channelid, enabled, props) FROM stdin;
\.


--
-- Data for Name: calls_jobs; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.calls_jobs (id, callid, type, creatorid, initat, startat, endat, props) FROM stdin;
\.


--
-- Data for Name: calls_sessions; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.calls_sessions (id, callid, userid, joinat, unmuted, raisedhand) FROM stdin;
\.


--
-- Data for Name: channelbookmarks; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.channelbookmarks (id, ownerid, channelid, fileinfoid, createat, updateat, deleteat, displayname, sortorder, linkurl, imageurl, emoji, type, originalid, parentid) FROM stdin;
\.


--
-- Data for Name: channelmemberhistory; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.channelmemberhistory (channelid, userid, jointime, leavetime) FROM stdin;
a4qjba5kb7doj8e3ob9p6zgsbc	4num934yzfb9udo1zdwxwd7gjc	1771232687407	\N
44b8teksdin8dmx18ctogjf6eh	4num934yzfb9udo1zdwxwd7gjc	1771232687449	\N
w7zggyteefg39kffpxhx1ojegh	7zmzqjej63838kcqaz5xsuh1yo	1771232699015	\N
w7zggyteefg39kffpxhx1ojegh	4num934yzfb9udo1zdwxwd7gjc	1771232699016	\N
k5soarcppffwj8nxs9qsne7rda	j4a8f886hpgbxefoufyyepqkeh	1771232699123	\N
k5soarcppffwj8nxs9qsne7rda	4num934yzfb9udo1zdwxwd7gjc	1771232699124	\N
y34rezxo6bgqf8z1kuuaxqfypa	gxtta9hxf7gpup4xfpgpddfapo	1771232699289	\N
y34rezxo6bgqf8z1kuuaxqfypa	4num934yzfb9udo1zdwxwd7gjc	1771232699289	\N
\.


--
-- Data for Name: channelmembers; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.channelmembers (channelid, userid, roles, lastviewedat, msgcount, mentioncount, notifyprops, lastupdateat, schemeuser, schemeadmin, schemeguest, mentioncountroot, msgcountroot, urgentmentioncount) FROM stdin;
a4qjba5kb7doj8e3ob9p6zgsbc	4num934yzfb9udo1zdwxwd7gjc		0	0	0	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232687402	t	t	f	0	0	0
44b8teksdin8dmx18ctogjf6eh	4num934yzfb9udo1zdwxwd7gjc		0	0	0	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232687441	t	t	f	0	0	0
w7zggyteefg39kffpxhx1ojegh	7zmzqjej63838kcqaz5xsuh1yo		0	0	0	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232699011	t	f	f	0	0	0
w7zggyteefg39kffpxhx1ojegh	4num934yzfb9udo1zdwxwd7gjc		0	0	1	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232699039	t	f	f	1	0	0
k5soarcppffwj8nxs9qsne7rda	j4a8f886hpgbxefoufyyepqkeh		0	0	0	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232699121	t	f	f	0	0	0
k5soarcppffwj8nxs9qsne7rda	4num934yzfb9udo1zdwxwd7gjc		0	0	1	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232699129	t	f	f	1	0	0
y34rezxo6bgqf8z1kuuaxqfypa	gxtta9hxf7gpup4xfpgpddfapo		0	0	0	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232699287	t	f	f	0	0	0
y34rezxo6bgqf8z1kuuaxqfypa	4num934yzfb9udo1zdwxwd7gjc		0	0	1	{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}	1771232699294	t	f	f	1	0	0
\.


--
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.channels (id, createat, updateat, deleteat, teamid, type, displayname, name, header, purpose, lastpostat, totalmsgcount, extraupdateat, creatorid, schemeid, groupconstrained, shared, totalmsgcountroot, lastrootpostat, bannerinfo, defaultcategoryname) FROM stdin;
a4qjba5kb7doj8e3ob9p6zgsbc	1771232687367	1771232687367	0	pphqf1o9gtf97jjp5dwid5hqje	O	Town Square	town-square			1771232687410	0	0		\N	\N	\N	0	1771232687410	\N	
44b8teksdin8dmx18ctogjf6eh	1771232687377	1771232687377	0	pphqf1o9gtf97jjp5dwid5hqje	O	Off-Topic	off-topic			1771232687449	0	0		\N	\N	\N	0	1771232687449	\N	
w7zggyteefg39kffpxhx1ojegh	1771232699011	1771232699011	0		D		4num934yzfb9udo1zdwxwd7gjc__7zmzqjej63838kcqaz5xsuh1yo			1771232699025	1	0	7zmzqjej63838kcqaz5xsuh1yo	\N	\N	f	1	1771232699025	\N	
k5soarcppffwj8nxs9qsne7rda	1771232699121	1771232699121	0		D		4num934yzfb9udo1zdwxwd7gjc__j4a8f886hpgbxefoufyyepqkeh			1771232699127	1	0	j4a8f886hpgbxefoufyyepqkeh	\N	\N	f	1	1771232699127	\N	
y34rezxo6bgqf8z1kuuaxqfypa	1771232699287	1771232699287	0		D		4num934yzfb9udo1zdwxwd7gjc__gxtta9hxf7gpup4xfpgpddfapo			1771232699292	1	0	gxtta9hxf7gpup4xfpgpddfapo	\N	\N	f	1	1771232699292	\N	
\.


--
-- Data for Name: clusterdiscovery; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.clusterdiscovery (id, type, clustername, hostname, gossipport, port, createat, lastpingat) FROM stdin;
\.


--
-- Data for Name: commands; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.commands (id, token, createat, updateat, deleteat, creatorid, teamid, trigger, method, username, iconurl, autocomplete, autocompletedesc, autocompletehint, displayname, description, url, pluginid) FROM stdin;
\.


--
-- Data for Name: commandwebhooks; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.commandwebhooks (id, createat, commandid, userid, channelid, rootid, usecount) FROM stdin;
\.


--
-- Data for Name: compliances; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.compliances (id, createat, userid, status, count, "desc", type, startat, endat, keywords, emails) FROM stdin;
\.


--
-- Data for Name: contentflaggingcommonreviewers; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.contentflaggingcommonreviewers (userid) FROM stdin;
\.


--
-- Data for Name: contentflaggingteamreviewers; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.contentflaggingteamreviewers (teamid, userid) FROM stdin;
\.


--
-- Data for Name: contentflaggingteamsettings; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.contentflaggingteamsettings (teamid, enabled) FROM stdin;
\.


--
-- Data for Name: db_lock; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.db_lock (id, expireat) FROM stdin;
\.


--
-- Data for Name: db_migrations; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.db_migrations (version, name) FROM stdin;
1	create_teams
2	create_team_members
3	create_cluster_discovery
4	create_command_webhooks
5	create_compliances
6	create_emojis
7	create_user_groups
8	create_group_members
9	create_group_teams
10	create_group_channels
11	create_link_metadata
12	create_commands
13	create_incoming_webhooks
14	create_outgoing_webhooks
15	create_systems
16	create_reactions
17	create_roles
18	create_schemes
19	create_licenses
20	create_posts
21	create_product_notice_view_state
22	create_sessions
23	create_terms_of_service
24	create_audits
25	create_oauth_access_data
26	create_preferences
27	create_status
28	create_tokens
29	create_bots
30	create_user_access_tokens
31	create_remote_clusters
32	create_sharedchannels
33	create_sidebar_channels
34	create_oauthauthdata
35	create_sharedchannelattachments
36	create_sharedchannelusers
37	create_sharedchannelremotes
38	create_jobs
39	create_channel_member_history
40	create_sidebar_categories
41	create_upload_sessions
42	create_threads
43	thread_memberships
44	create_user_terms_of_service
45	create_plugin_key_value_store
46	create_users
47	create_file_info
48	create_oauth_apps
49	create_channels
50	create_channelmembers
51	create_msg_root_count
52	create_public_channels
53	create_retention_policies
54	create_crt_channelmembership_count
55	create_crt_thread_count_and_unreads
56	upgrade_channels_v6.0
57	upgrade_command_webhooks_v6.0
58	upgrade_channelmembers_v6.0
59	upgrade_users_v6.0
60	upgrade_jobs_v6.0
61	upgrade_link_metadata_v6.0
62	upgrade_sessions_v6.0
63	upgrade_threads_v6.0
64	upgrade_status_v6.0
65	upgrade_groupchannels_v6.0
66	upgrade_posts_v6.0
67	upgrade_channelmembers_v6.1
68	upgrade_teammembers_v6.1
69	upgrade_jobs_v6.1
70	upgrade_cte_v6.1
71	upgrade_sessions_v6.1
72	upgrade_schemes_v6.3
73	upgrade_plugin_key_value_store_v6.3
74	upgrade_users_v6.3
75	alter_upload_sessions_index
76	upgrade_lastrootpostat
77	upgrade_users_v6.5
78	create_oauth_mattermost_app_id
79	usergroups_displayname_index
80	posts_createat_id
81	threads_deleteat
82	upgrade_oauth_mattermost_app_id
83	threads_threaddeleteat
84	recent_searches
85	fileinfo_add_archived_column
86	add_cloud_limits_archived
87	sidebar_categories_index
88	remaining_migrations
89	add-channelid-to-reaction
90	create_enums
91	create_post_reminder
92	add_createat_to_teamembers
93	notify_admin
94	threads_teamid
95	remove_posts_parentid
96	threads_threadteamid
97	create_posts_priority
98	create_post_acknowledgements
99	create_drafts
100	add_draft_priority_column
101	create_true_up_review_history
102	posts_originalid_index
103	add_sentat_to_notifyadmin
104	upgrade_notifyadmin
105	remove_tokens
106	fileinfo_channelid
107	threadmemberships_cleanup
108	remove_orphaned_oauth_preferences
109	create_persistent_notifications
111	update_vacuuming
112	rework_desktop_tokens
113	create_retentionidsfordeletion_table
114	sharedchannelremotes_drop_nextsyncat_description
115	user_reporting_changes
116	create_outgoing_oauth_connections
117	msteams_shared_channels
118	create_index_poststats
119	msteams_shared_channels_opts
120	create_channelbookmarks_table
121	remove_true_up_review_history
122	preferences_value_length
123	remove_upload_file_permission
124	remove_manage_team_permission
125	remoteclusters_add_default_team_id
126	sharedchannels_remotes_add_deleteat
127	add_mfa_used_ts_to_users
128	create_scheduled_posts
129	add_property_system_architecture
130	system_console_stats
131	create_index_pagination_on_property_values
132	create_index_pagination_on_property_fields
133	add_channel_banner_fields
134	create_access_control_policies
135	sidebarchannels_categoryid
136	create_attribute_view
137	update_attribute_view
138	add_default_category_name_to_channel
139	remoteclusters_add_last_global_user_sync_at
140	add_lastmemberssyncat_to_sharedchannelremotes
141	add_remoteid_channelid_to_post_acknowledgements
142	create_content_flagging_tables
143	content_flagging_table_index
144	add_dcr_fields_to_oauth_apps
145	add_pkce_to_oauthauthdata
146	add_audience_and_resource_to_oauth
\.


--
-- Data for Name: db_migrations_calls; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.db_migrations_calls (version, name) FROM stdin;
1	create_calls_channels
2	create_calls
3	create_calls_sessions
4	create_calls_jobs
\.


--
-- Data for Name: desktoptokens; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.desktoptokens (token, createat, userid) FROM stdin;
\.


--
-- Data for Name: drafts; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.drafts (createat, updateat, deleteat, userid, channelid, rootid, message, props, fileids, priority) FROM stdin;
\.


--
-- Data for Name: emoji; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.emoji (id, createat, updateat, deleteat, creatorid, name) FROM stdin;
\.


--
-- Data for Name: fileinfo; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.fileinfo (id, creatorid, postid, createat, updateat, deleteat, path, thumbnailpath, previewpath, name, extension, size, mimetype, width, height, haspreviewimage, minipreview, content, remoteid, archived, channelid) FROM stdin;
\.


--
-- Data for Name: groupchannels; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.groupchannels (groupid, autoadd, schemeadmin, createat, deleteat, updateat, channelid) FROM stdin;
\.


--
-- Data for Name: groupmembers; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.groupmembers (groupid, userid, createat, deleteat) FROM stdin;
\.


--
-- Data for Name: groupteams; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.groupteams (groupid, autoadd, schemeadmin, createat, deleteat, updateat, teamid) FROM stdin;
\.


--
-- Data for Name: incomingwebhooks; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.incomingwebhooks (id, createat, updateat, deleteat, userid, channelid, teamid, displayname, description, username, iconurl, channellocked) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.jobs (id, type, priority, createat, startat, lastactivityat, status, progress, data) FROM stdin;
qnykrzjbu3878jbgqr1b96a9uy	cleanup_desktop_tokens	0	1769698562176	1769698564465	1769698564471	success	100	null
tmsar7sa778e7pteyg4x9f88ya	expiry_notify	0	1769696281960	1769696283378	1769696283384	success	100	null
mobwynhaxtbqixsyfxc3mks5ae	delete_empty_drafts_migration	0	1769687702010	1769687729881	1769687730888	success	100	{}
t3be7t63qjfopdaf99dxiu85aa	expiry_notify	0	1769691661555	1769691676354	1769691676357	success	100	null
35k87xw4cf8y7e5x88qqh11s7o	delete_orphan_drafts_migration	0	1769687702016	1769687729881	1769687730895	success	100	{}
z1dp6y6wfpbazxtmnycjp96a9h	delete_dms_preferences_migration	0	1769687702018	1769687729881	1769687730895	success	100	{}
7euja8msbtf6tft6qonfykysrr	expiry_notify	0	1769698922198	1769698924639	1769698924645	success	100	null
bcwg6r5mtjynzydhw6ikoxjyzr	migrations	0	1769687761288	1769687774886	1769687775101	success	0	{"last_done": "{\\"current_table\\":\\"ChannelMembers\\",\\"last_team_id\\":\\"00000000000000000000000000\\",\\"last_channel_id\\":\\"00000000000000000000000000\\",\\"last_user\\":\\"00000000000000000000000000\\"}", "migration_key": "migration_advanced_permissions_phase_2"}
qryfrrujifrxtr7uxtcrb79qgy	expiry_notify	0	1769699582246	1769699584922	1769699584927	success	100	null
xzd7i57wy3yyixfbt198ojumbr	expiry_notify	0	1769688361335	1769688375090	1769688375096	success	100	null
jnsk1kqo5tdb3xotb817debazo	product_notices	0	1769702102366	1769702105737	1769702105852	success	100	null
xs6i81cm5fgg9qh5zktxfuercc	expiry_notify	0	1769692321626	1769692336632	1769692336640	success	100	null
jdf6hf3zz3ntpq35n3jmnuz4ka	expiry_notify	0	1769689021352	1769689035302	1769689035308	success	100	null
minirnh87fgexrrmabmujtb8hw	expiry_notify	0	1769700242281	1769700245151	1769700245158	success	100	null
i3iazahr37bt5f345nsu31gajr	expiry_notify	0	1769689681408	1769689695554	1769689695560	success	100	null
eju6bpm477gr5p31xyghy57ezc	expiry_notify	0	1769700902307	1769700905375	1769700905379	success	100	null
f4kymyrfxb81in6mfe3jztyb8r	expiry_notify	0	1769690341463	1769690355835	1769690355838	success	100	null
mjkm654top85pgwx69w8c5b4tw	expiry_notify	0	1769701562336	1769701565570	1769701565579	success	100	null
ggt1cf1o4if43b9uk5wk6ttgtr	expiry_notify	0	1769691001490	1769691016041	1769691016044	success	100	null
ir6kyj5ymjrb3jniwymt4tm5ro	expiry_notify	0	1769703542517	1769703546376	1769703546381	success	100	null
793pncu5abfomq8ujwyfg5xora	expiry_notify	0	1769692981680	1769692981925	1769692981931	success	100	null
5xn7nqa1mjrs3jyo9xcutcthxw	cleanup_desktop_tokens	0	1769691301518	1769691316192	1769691316197	success	100	null
5uxjm4fm9pdwupidfptuz8qxfy	expiry_notify	0	1769702222377	1769702225776	1769702225781	success	100	null
kyss76pwrtnhiksxjojruh1mto	product_notices	0	1769691301522	1769691316192	1769691316295	success	100	null
64dj4kawd3g1fqu4umxxhj8j8y	cleanup_desktop_tokens	0	1769702222374	1769702225776	1769702225781	success	100	null
j4iso1zuj3f4tp6bseusag3htr	expiry_notify	0	1769693641709	1769693642210	1769693642214	success	100	null
gh6dq7yo9jgkircsnqiz1dq4py	expiry_notify	0	1769702882456	1769702886105	1769702886109	success	100	null
h9su3pp68jgk781seyhrsp3zwe	expiry_notify	0	1769696942041	1769696943698	1769696943704	success	100	null
6awbm93q8inb7gkz7tfbarrgka	expiry_notify	0	1769694301768	1769694302510	1769694302517	success	100	null
mpebu3xhzb85fnh7uh6b43o1ue	expiry_notify	0	1769704202575	1769704206685	1769704206692	success	100	null
1r4jd6jeytg5mdgp3jmjcs3mkw	cleanup_desktop_tokens	0	1769694901830	1769694902809	1769694902814	success	100	null
9kcgstafktgy8edc3z6uum8ajc	expiry_notify	0	1769706182738	1769706187476	1769706187478	success	100	null
gop833yxgfripga4hgw7hcfx3e	product_notices	0	1769694901834	1769694902808	1769694902920	success	100	null
x8oj37qaxj8bi8qjnod6ax9gne	expiry_notify	0	1769704862641	1769704866983	1769704866990	success	100	null
q3y69yxsm7gztyhqqy6mkwyzfr	expiry_notify	0	1769694961840	1769694962833	1769694962838	success	100	null
1n9rwehs6pbrfrrbnh9pph7i8c	product_notices	0	1769705702696	1769705707322	1769705707432	success	100	null
u5jzrzkqpibgtfjph7b43c6gma	expiry_notify	0	1769705522683	1769705527243	1769705527249	success	100	null
m1ghr537ffr75fbgtdrzzgcwuo	expiry_notify	0	1769697602078	1769697603986	1769697603992	success	100	null
5rajgx89fbgeibfd5nqxewiqrr	expiry_notify	0	1769695621901	1769695623147	1769695623149	success	100	null
w9np9iy5qbr83naoy3gzno53bw	cleanup_desktop_tokens	0	1769705882719	1769705887385	1769705887390	success	100	null
ki17cnbtgbgotkegczwjpwx1uo	expiry_notify	0	1769698262122	1769698264298	1769698264304	success	100	null
xjymaxe31pnq9kri4wybty1xba	expiry_notify	0	1769707502836	1769707508019	1769707508022	success	100	null
5orurdii4pfozqc3w5yr3b7i4e	product_notices	0	1769698502164	1769698504428	1769698504538	success	100	null
rtky7nf61inbpjunw61ceicwyw	expiry_notify	0	1769706842780	1769706847754	1769706847756	success	100	null
ji5ig7sz3id8bp39pohh311atw	expiry_notify	0	1769708102910	1769708108309	1769708108315	success	100	null
jpbrqtihhjngxc91h3qtw7ckqr	expiry_notify	0	1769708702971	1769708708619	1769708708626	success	100	null
nn44haw71fn6ujik8binfsp3ee	product_notices	0	1769709303023	1769709308890	1769709308994	success	100	null
5n3uegjqoigtzj9npwbgo36yma	expiry_notify	0	1769709363032	1769709368902	1769709368914	success	100	null
tbm3ceubmbgj7yshjnadkr6s1a	cleanup_desktop_tokens	0	1769709543057	1769709548958	1769709548960	success	100	null
3ct37tnx13bn5nyn4d6d544mzo	expiry_notify	0	1769710023091	1769710029177	1769710029179	success	100	null
d4mopxupc7bwzenarx9rropppy	expiry_notify	0	1769710683127	1769710689406	1769710689408	success	100	null
qdr8yp8kwb8kpjwtxbi7axiy6y	expiry_notify	0	1769711343182	1769711349687	1769711349692	success	100	null
36tq4j7mbtby3pm1pt1sf5rysc	expiry_notify	0	1769712003230	1769712010007	1769712010015	success	100	null
3nh7ti6odtr3fgrdd1nbg9r7ua	expiry_notify	0	1769718603786	1769718613013	1769718613018	success	100	null
cx3jeoiq5prjxcqhxxhuzfdady	expiry_notify	0	1769712663282	1769712670349	1769712670354	success	100	null
1ujj7ie3kidkpmsz7a8mnz5ear	product_notices	0	1769712903308	1769712910486	1769712910572	success	100	null
n5rxfuxgafyt8fpc7xaqfru8xy	expiry_notify	0	1769730484932	1769730498196	1769730498202	success	100	null
1x77tsye7bnzxjdcty8co1wipy	expiry_notify	0	1769727844706	1769727857056	1769727857059	success	100	null
1ajecrfr7fr7zc3fbxdey1e8go	cleanup_desktop_tokens	0	1769713143331	1769713150588	1769713150590	success	100	null
k7a3ag5etffgtfubky8bgcggce	expiry_notify	0	1769728504757	1769728517320	1769728517326	success	100	null
4hkat3e5m7y4i84rtqkirh9zdr	expiry_notify	0	1769713323354	1769713330659	1769713330662	success	100	null
1ees5g43difoin8pcox91w8cqa	expiry_notify	0	1769713983402	1769713990971	1769713990975	success	100	null
eq8wbnajjbrj7xqw7pdfz1447c	expiry_notify	0	1769729164817	1769729177623	1769729177628	success	100	null
k7j8fniz138fpruoucjjbwjxrr	expiry_notify	0	1769719263847	1769719273305	1769719273309	success	100	null
3eiw8rhtm3b18qfr3t3s8jy83w	expiry_notify	0	1769714643457	1769714651244	1769714651249	success	100	null
heeepb4nnjydjyjqoaocq6wkoh	expiry_notify	0	1769729824878	1769729837909	1769729837915	success	100	null
4xp57hbx3fym7qy7ps3c9zjo5o	expiry_notify	0	1769715303527	1769715311563	1769715311569	success	100	null
mq5eun835f8nikwqdq8n6nx91w	expiry_notify	0	1769715963569	1769715971838	1769715971844	success	100	null
hr5ps9r1rbgj5cdtog5usa1bnh	product_notices	0	1769730904962	1769730918395	1769730918515	success	100	null
8sf8sn3p8trbzmo9u36i7pnm7c	product_notices	0	1769716503633	1769716512075	1769716512188	success	100	null
4grcrribnprxuqfg5y65k9xabc	expiry_notify	0	1769731144985	1769731158517	1769731158522	success	100	null
odi8ridoafyxdjwot6irq6de7e	expiry_notify	0	1769719923898	1769719933518	1769719933521	success	100	null
3sg7qo8hx3f95rxnrxmh9aketc	expiry_notify	0	1769716623644	1769716632130	1769716632134	success	100	null
dw5swspb5fyp8bfn1nm4ki7u8w	cleanup_desktop_tokens	0	1769731385023	1769731398647	1769731398651	success	100	null
a8k86ae9f7rutknuup1e8bk1qo	cleanup_desktop_tokens	0	1769716803675	1769716812206	1769716812211	success	100	null
wr6oznurwbgnuck1qa8bxkj9he	refresh_materialized_views	0	1769731204994	1769731218552	1769731218592	success	100	null
p1oatiq67jyt88nuka3ksdxh3y	expiry_notify	0	1769717283704	1769717292391	1769717292396	success	100	null
p1oe99t877y6fghs1xmyc3ciwh	expiry_notify	0	1769732465128	1769732479162	1769732479169	success	100	null
eyp9jcwphff3zgdhfjegownw1w	expiry_notify	0	1769731805071	1769731818827	1769731818834	success	100	null
6e8gz49wi7dfxbkuspap3kfrba	expiry_notify	0	1769717943754	1769717952723	1769717952729	success	100	null
axxeixi37bbupgoc5xjk6dawzh	product_notices	0	1769723704279	1769723715197	1769723715294	success	100	null
o31hzy8ztjye9y1igocx1hwajh	product_notices	0	1769720103926	1769720113579	1769720113680	success	100	null
osbucupgtfyc5gwhzi9jtg91fh	expiry_notify	0	1769733125159	1769733139394	1769733139399	success	100	null
fghjif3dtbfj8c755mzm3ao9kr	cleanup_desktop_tokens	0	1769720463969	1769720473698	1769720473700	success	100	null
akzihbt5yb8z5c15ndhab46bho	expiry_notify	0	1769733785194	1769733799684	1769733799688	success	100	null
4roe1zzu8pb5zpahide6qdomrc	expiry_notify	0	1769720583988	1769720593739	1769720593742	success	100	null
q7tefd73gin78ni1bibf4ttrnc	expiry_notify	0	1769734385231	1769734399949	1769734399954	success	100	null
ik3zfggr5jdu5rimubgopteadr	expiry_notify	0	1769721244049	1769721254026	1769721254032	success	100	null
tond5eosgjbr7pdzswezqeku9e	product_notices	0	1769734505260	1769734520008	1769734520104	success	100	null
e1pdro97j7rrjpqxpuf5tb8iyh	expiry_notify	0	1769723884311	1769723895270	1769723895276	success	100	null
4wwy6uqjz38wumfiht1a3q4mjr	expiry_notify	0	1769721904092	1769721914329	1769721914334	success	100	null
ea6u9jdjhpn7xqdnenwfquwp3e	expiry_notify	0	1769722564155	1769722574664	1769722574671	success	100	null
7qnnur9i8frxjd8z9qtsxgmuua	expiry_notify	0	1769735045305	1769735060238	1769735060243	success	100	null
67wpnw9gkjfm8x3kmdw7p1yw1e	expiry_notify	0	1769723224232	1769723234960	1769723234967	success	100	null
37eqtd3rwtdixfbq3x7mrybp8w	cleanup_desktop_tokens	0	1769735045301	1769735060238	1769735060243	success	100	null
jc8m9ni6z3nk5kmruwkj44w7ko	cleanup_desktop_tokens	0	1769724124343	1769724135391	1769724135395	success	100	null
grbsko1xstn8mpefietsonahyw	expiry_notify	0	1769735705341	1769735705484	1769735705488	success	100	null
j9fqaxtao3fbjkgbqiugzo1i9h	expiry_notify	0	1769727184638	1769727196732	1769727196739	success	100	null
ukonndn41pbhfp5ugfd9xkwdye	expiry_notify	0	1769724544376	1769724555569	1769724555573	success	100	null
1g6wg48papbxfpcye9kq5ax5uh	expiry_notify	0	1769736365389	1769736365757	1769736365763	success	100	null
dcsnsofm8py5brorx314yzj3ny	expiry_notify	0	1769725204433	1769725215848	1769725215855	success	100	null
trpwnmj53fbttq4wd1gty9fi6a	expiry_notify	0	1769737025429	1769737026088	1769737026092	success	100	null
xyxrpi5ehbr7fjmkzuxmq8wmgy	expiry_notify	0	1769725864498	1769725876138	1769725876144	success	100	null
brcmf4nn1ifcpf49ppen1arqja	expiry_notify	0	1769737685492	1769737686419	1769737686424	success	100	null
sp1oh1rgmjnoxmmm1y7mur8gbc	expiry_notify	0	1769726524574	1769726536435	1769726536440	success	100	null
zrkokazb6jgg9x53pr4xwdzwac	product_notices	0	1769727304654	1769727316791	1769727316887	success	100	null
3tscrda1a3f88keira9h7jemzy	product_notices	0	1769738105528	1769738106612	1769738106731	success	100	null
kpq4ro5supfpiq3wcu9xcc7xze	cleanup_desktop_tokens	0	1769727724694	1769727737009	1769727737011	success	100	null
hy1c6i8o53gcmrp7zj3bhde93h	expiry_notify	0	1769742965923	1769742968740	1769742968746	success	100	null
pdop3t8zo7875kq86qq6qmmwqa	expiry_notify	0	1769738345556	1769738346703	1769738346708	success	100	null
6noszw3ac3dgz8ibwuhxpp8cco	expiry_notify	0	1769762767571	1769762777350	1769762777356	success	100	null
bkfdu5wwuifn8gwydr7yi1ma7h	expiry_notify	0	1769748246377	1769748251138	1769748251140	success	100	null
5ctpm85mqj8zbgfgx7xkjj8reh	cleanup_desktop_tokens	0	1769738705600	1769738706849	1769738706854	success	100	null
55jsbeg4f3y4zqn7yjznpbag1h	expiry_notify	0	1769743626001	1769743629036	1769743629045	success	100	null
9ss3u4moopdjuekun6dedaiubr	expiry_notify	0	1769739005632	1769739006982	1769739006986	success	100	null
ogh6xpf86tdm3e7tforiumhraa	product_notices	0	1769763307634	1769763317578	1769763317678	success	100	null
bj5hj9dz7fbt7x6g5f3bsdii8w	expiry_notify	0	1769744286031	1769744289330	1769744289334	success	100	null
cffskxdba3bo5ybiykc9te378e	expiry_notify	0	1769739665655	1769739667227	1769739667231	success	100	null
mcg4jyni67yupjq8jp5xhsrxdr	expiry_notify	0	1769763427646	1769763437634	1769763437639	success	100	null
8oyxebo8fibifn1zgogikbtfth	expiry_notify	0	1769744946092	1769744949610	1769744949614	success	100	null
1gp7ic88n3nfbqq8h9gdbwf3ph	expiry_notify	0	1769740325694	1769740327559	1769740327565	success	100	null
rsmc3i5sofdu8ft7swru9asj6w	expiry_notify	0	1769764087681	1769764097880	1769764097885	success	100	null
bm8daowustgjif8ndpm4wfceyr	expiry_notify	0	1769740985752	1769740987865	1769740987870	success	100	null
7qx14kdfmjg3peeo6w46n1ixyo	product_notices	0	1769745306124	1769745309757	1769745309874	success	100	null
mbku8tx9q3fopqmekwbfqyh6fc	expiry_notify	0	1769741645800	1769741648156	1769741648160	success	100	null
xi6seszebj8zid4sec4o1ypzfe	expiry_notify	0	1769745606145	1769745609905	1769745609912	success	100	null
z15ibyanzpy5jquj7ijjt4ndih	product_notices	0	1769741705813	1769741708185	1769741708297	success	100	null
1mchu4cp9j8afdianhde87uhqh	cleanup_desktop_tokens	0	1769746026163	1769746030111	1769746030115	success	100	null
zgzejt3xtjbsjmp1wpqrohphhw	expiry_notify	0	1769742305863	1769742308442	1769742308448	success	100	null
nfuoajowfpn8dnuxqpiiar7jwa	expiry_notify	0	1769748906440	1769748911468	1769748911474	success	100	null
m4395p4nijg3tpzewtmpeb9cyc	cleanup_desktop_tokens	0	1769742365879	1769742368469	1769742368473	success	100	null
dk7dpm8urtg7tmxpgbcm96y8sh	expiry_notify	0	1769746266218	1769746270241	1769746270248	success	100	null
cm3hmfihtir97moi34oy7o7irh	expiry_notify	0	1769754186859	1769754193712	1769754193714	success	100	null
ht3k75cemfyadg64w5igqoq1nc	expiry_notify	0	1769746926270	1769746930543	1769746930548	success	100	null
7tebw1nfjpnm3caybtmctcjyxe	product_notices	0	1769748906444	1769748911467	1769748911582	success	100	null
zq6ojcxzx3ntugi9bcfmj3qioc	expiry_notify	0	1769747586313	1769747590812	1769747590820	success	100	null
izkpi91r7bg43ckpz654cxe1ph	expiry_notify	0	1769752206692	1769752212923	1769752212929	success	100	null
5izj1zwjpbyc9e5raufgwnob7y	expiry_notify	0	1769749566489	1769749571736	1769749571743	success	100	null
za9nqi3qajd7bds6x5fcyjjn5w	cleanup_desktop_tokens	0	1769749686500	1769749691813	1769749691817	success	100	null
6rd9mynhkbneunb5uq3o8oncqa	expiry_notify	0	1769750226534	1769750232071	1769750232075	success	100	null
4exabcw4gfby5rx8ze3yobps9y	product_notices	0	1769752506735	1769752513034	1769752513156	success	100	null
ok5ajcih47bn5jqogs61x6ryue	expiry_notify	0	1769750886593	1769750892333	1769750892339	success	100	null
4kp9kqsc3bfu9fyy4x8wasuwke	expiry_notify	0	1769751546651	1769751552642	1769751552646	success	100	null
jwjpcwwm1pfauno8zzp7fgc3qy	expiry_notify	0	1769752866764	1769752873204	1769752873208	success	100	null
bwwe9naff7rotj7qxbjzpuando	cleanup_desktop_tokens	0	1769753346808	1769753353427	1769753353432	success	100	null
o4r96r53r7gcpeqcjdrk3tndky	expiry_notify	0	1769754846910	1769754854007	1769754854011	success	100	null
wq1zqbo8b7rqdc1pe4x5x6bhuc	expiry_notify	0	1769753526838	1769753533509	1769753533516	success	100	null
55a1cqsotirctmr6t8f3pyuwyh	expiry_notify	0	1769755506960	1769755514279	1769755514286	success	100	null
4xzhu1hmy7yhjeckh5sz4za3te	expiry_notify	0	1769756827081	1769756834858	1769756834864	success	100	null
fio5fn5fmbdt8b51zqsn5fwejh	product_notices	0	1769756107041	1769756114579	1769756114695	success	100	null
hhuu539i93rbukt34cb6xtc4wo	expiry_notify	0	1769756167043	1769756174606	1769756174612	success	100	null
sftziz1uujr1pgbn47m3qmafpw	cleanup_desktop_tokens	0	1769757007103	1769757014948	1769757014952	success	100	null
zicdjwxaxpn7jykwya7rdheeoy	expiry_notify	0	1769758147210	1769758155404	1769758155407	success	100	null
ckc17ed8pirpdxqsfy6o7xtmyh	expiry_notify	0	1769757487158	1769757495161	1769757495166	success	100	null
fjgpmamccjbc7y8m7mhtgn7joa	expiry_notify	0	1769759467291	1769759475965	1769759475971	success	100	null
enatan7jzjne9d4juz8jo9jqry	expiry_notify	0	1769758807266	1769758815666	1769758815673	success	100	null
bynmfm84ebbnbkoo6yuri1zxhc	product_notices	0	1769759707323	1769759716086	1769759716177	success	100	null
9nsof9drz7f6dmrjgszqt3h6ya	expiry_notify	0	1769760127367	1769760136261	1769760136265	success	100	null
4xxrja5iojy5fkn8m4zeywrrno	cleanup_desktop_tokens	0	1769760667418	1769760676509	1769760676514	success	100	null
wbbs6hyppp8fmxcqk5h4xco4wa	expiry_notify	0	1769760787434	1769760796580	1769760796585	success	100	null
rh7tk6epr3nkbmumanrp1mkxkh	expiry_notify	0	1769761447483	1769761456921	1769761456927	success	100	null
3zfuiyi18pyimxa4yqx7p94nay	expiry_notify	0	1769762107516	1769762117151	1769762117158	success	100	null
y8twrdjsiin98mxy4ndpui6moa	expiry_notify	0	1769781249158	1769781250708	1769781250715	success	100	null
66bk4ugxfpd6fpite9cbrnhgfa	product_notices	0	1769802910869	1769802920044	1769802920153	success	100	null
1qx54fh7dbfszqycksy6q3qs3e	cleanup_desktop_tokens	0	1769764327712	1769764338000	1769764338005	success	100	null
75ec7r5aopykbnwt4if7urthpa	expiry_notify	0	1769825412751	1769825415003	1769825415010	success	100	null
qx44yaj3zbbajnroztihdwonzo	product_notices	0	1769781309167	1769781310733	1769781310838	success	100	null
8tpjy5nnhtd7pb5tzbfx5q41so	expiry_notify	0	1769803030882	1769803040080	1769803040085	success	100	null
35gonxdonbdg8gd4g9aage57ho	expiry_notify	0	1769782569298	1769782571375	1769782571381	success	100	null
ughe77d6ap8x3k15xiieim6bfr	expiry_notify	0	1769806991169	1769807001760	1769807001766	success	100	null
c1khde8iwj8ibfg1bxcam67oac	expiry_notify	0	1769803690908	1769803700294	1769803700301	success	100	null
e9rtejyfapbm3xmjrq96aystmr	expiry_notify	0	1769793790158	1769793796123	1769793796128	success	100	null
35mkzbnde7nz7n73a4ir7rss4y	cleanup_desktop_tokens	0	1769782629306	1769782631405	1769782631410	success	100	null
ew63kn4raprd7r6siwxbz7gtpo	expiry_notify	0	1769805671088	1769805681168	1769805681170	success	100	null
ek51hi6953no7muewpmn976kjc	expiry_notify	0	1769783229331	1769783231663	1769783231669	success	100	null
twsag4oenbn4bnfrdm8cifg4sy	expiry_notify	0	1769804350975	1769804360598	1769804360602	success	100	null
7udu36wdpbb95yf6yyjc17o19c	expiry_notify	0	1769785209521	1769785212574	1769785212582	success	100	null
a8mabifnmfgwfngd3zun6esodh	cleanup_desktop_tokens	0	1769804530997	1769804540683	1769804540688	success	100	null
em47jjezatd5fm4m7ncoxnbhbc	product_notices	0	1769799310614	1769799318610	1769799318698	success	100	null
3g7x51ugxfge3mj4p9nzwjp44o	cleanup_desktop_tokens	0	1769786289617	1769786293123	1769786293129	success	100	null
5u9f74o3kjd4pqy6wh9hm3irqr	expiry_notify	0	1769794450217	1769794456423	1769794456429	success	100	null
7sikx4h7wbnp7d8xiokap3gocc	expiry_notify	0	1769787189683	1769787193477	1769787193483	success	100	null
injktqq7hfnnbqskbft55qdpjw	expiry_notify	0	1769805011038	1769805020865	1769805020870	success	100	null
jifxbu58hpb7jdyrojbor79g9a	expiry_notify	0	1769787849730	1769787853714	1769787853717	success	100	null
qe7f4quzwtrqbjronkpdh9sprh	expiry_notify	0	1769806331136	1769806341444	1769806341449	success	100	null
bhu1fd7i7bbzzcem3i75n7moto	expiry_notify	0	1769788509775	1769788513934	1769788513935	success	100	null
by7jrbzx9tym5q9ck54tfkytwh	expiry_notify	0	1769795770320	1769795777013	1769795777018	success	100	null
o6jk9pcmipr59nxhzt1f4qt8uo	product_notices	0	1769788509785	1769788513934	1769788514000	success	100	null
ej7ajbcjpprcbna7cxiy6qwzwr	product_notices	0	1769806511141	1769806521534	1769806521639	success	100	null
cs7n5kbcoibcteep8tesz1n3gw	expiry_notify	0	1769791149956	1769791154984	1769791154991	success	100	null
p8z6ku51yfd4fjcehm1jd3tspc	expiry_notify	0	1769808311291	1769808322408	1769808322413	success	100	null
t4iiufugsbdi3cxtg1uaft1rpe	expiry_notify	0	1769807651240	1769807662100	1769807662106	success	100	null
he3kwg7ow7fy8dwchsy6bwtkce	expiry_notify	0	1769792470077	1769792475523	1769792475528	success	100	null
zukpqk9qx38pjnn39gkkb5tway	expiry_notify	0	1769796430365	1769796437282	1769796437284	success	100	null
x5kmtncoufft9y6da3o7hxjo5h	cleanup_desktop_tokens	0	1769808131275	1769808142337	1769808142343	success	100	null
tpukpsprkjdnpjetz61a7xey3h	expiry_notify	0	1769797090413	1769797097575	1769797097582	success	100	null
tbqyt6rwaigj5d3ezpekxrrx9a	expiry_notify	0	1769799730658	1769799738837	1769799738843	success	100	null
p8h8tc75a7bgfradjorjpcoeio	cleanup_desktop_tokens	0	1769797210430	1769797217621	1769797217626	success	100	null
7jmr1jxpufyn8fmmrfcbf3h8oe	expiry_notify	0	1769809631409	1769809643017	1769809643024	success	100	null
5hw6dznctjdjzxuta63dkq53dh	expiry_notify	0	1769808971353	1769808982684	1769808982690	success	100	null
97pnypkoyfgjieqz5yhe88yixw	expiry_notify	0	1769797750451	1769797757855	1769797757861	success	100	null
mjzgpmb5zpbpmqiwonewf4bkth	expiry_notify	0	1769798410511	1769798418171	1769798418177	success	100	null
gu4hbmsdgiyf7yebcb8os8o31h	product_notices	0	1769810111441	1769810123231	1769810123340	success	100	null
gjbrjxnekin6ddcj4ebwa8fuwc	expiry_notify	0	1769799070583	1769799078487	1769799078491	success	100	null
bxb8xa9wkfnwiqq365p59f7a4w	expiry_notify	0	1769810291468	1769810303302	1769810303305	success	100	null
6r1y6ket1frqi8geyrnb3kti5e	expiry_notify	0	1769800390710	1769800399153	1769800399155	success	100	null
37eznbzt538wtyjxkf9hsn1fxc	expiry_notify	0	1769810951513	1769810963620	1769810963624	success	100	null
33zu5ja76f8xunhz5wopryu6nc	cleanup_desktop_tokens	0	1769800870762	1769800879325	1769800879328	success	100	null
p6wjbesrpfgy8citr8g6g4wwdw	expiry_notify	0	1769811611580	1769811623914	1769811623919	success	100	null
h4kghmhux3nedkcbjrce1bei7e	expiry_notify	0	1769801050784	1769801059401	1769801059408	success	100	null
6uc4rzxeajdx3yuf6mytykcdme	cleanup_desktop_tokens	0	1769811791595	1769811803968	1769811803971	success	100	null
cio1g31jopddpj5cxpair7bcfr	expiry_notify	0	1769801710798	1769801719627	1769801719633	success	100	null
jonpeumhjfrouen3dffows46fw	expiry_notify	0	1769812271636	1769812284102	1769812284105	success	100	null
exfi7b8qb3d4dcqchofxeunruy	expiry_notify	0	1769802370834	1769802379858	1769802379864	success	100	null
1emw9zxtyj8e3ytbk1otrtfrry	expiry_notify	0	1769812931688	1769812944308	1769812944314	success	100	null
kin3jf6kbffmzebgbkghyozooc	expiry_notify	0	1769813591750	1769813604641	1769813604647	success	100	null
85wzfhm3yb81uyq44mr3qifcar	product_notices	0	1769813711764	1769813724691	1769813724806	success	100	null
gix8i8qup3gddycif5eyuitmee	expiry_notify	0	1769814251809	1769814264920	1769814264925	success	100	null
heyi5n7mj7ygujxyssp4t1eber	expiry_notify	0	1769853015143	1769853027228	1769853027231	success	100	null
ntnji4aei3f6fqoqj41czfctfr	expiry_notify	0	1769764747751	1769764758186	1769764758191	success	100	null
9e4whgipmpyo5ntnhyn4885yoa	expiry_notify	0	1769781909217	1769781911014	1769781911021	success	100	null
d6mkibip73d77yybh7s5of5exa	expiry_notify	0	1769765407811	1769765418524	1769765418529	success	100	null
rg9yje58binzmd5ogbkcnhox9a	mobile_session_metadata	0	1769774108604	1769774122425	1769774122433	success	100	null
i14otrujfi815xhojt3y43j8ho	expiry_notify	0	1769766067873	1769766078789	1769766078795	success	100	null
h1iw1854ffgtpd4otk9uyhej7r	expiry_notify	0	1769783889394	1769783891961	1769783891968	success	100	null
4ubx4y6kgtnaxcr36hrynhs7qe	expiry_notify	0	1769771348342	1769771361162	1769771361168	success	100	null
fowgaio5n3dnffooxc4o3qnxrr	expiry_notify	0	1769766727936	1769766739080	1769766739085	success	100	null
ppgudm6wy3895niusxjobfyhrr	expiry_notify	0	1769784549448	1769784552251	1769784552256	success	100	null
m6mkfhgi4br7mcsp18njjjiuha	product_notices	0	1769766907953	1769766919163	1769766919263	success	100	null
hdy8tm686pn7feewq9z7zpqh7r	product_notices	0	1769784909474	1769784912409	1769784912516	success	100	null
qaaeofq65bd7xe8635gdb3h3ac	expiry_notify	0	1769767387988	1769767399356	1769767399362	success	100	null
a1d1on8rxjbe7fa418esegp6nr	expiry_notify	0	1769789169831	1769789174199	1769789174206	success	100	null
tr5iwaydbbg19qzszug9ethmne	expiry_notify	0	1769785869585	1769785872876	1769785872880	success	100	null
zkzmqs7ekjbotcxx1rhx4q4qgy	install_plugin_notify_admin	0	1769774108610	1769774122424	1769774122439	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
iyypmmqe7irbujobpic4ir3twc	cleanup_desktop_tokens	0	1769767988028	1769767999619	1769767999624	success	100	null
4i3kj4nehpdxxktpggqyrshf1w	expiry_notify	0	1769786529633	1769786533198	1769786533205	success	100	null
kqc13qnk4inpjy9y7rto9nrqac	cleanup_desktop_tokens	0	1769771648382	1769771661301	1769771661306	success	100	null
h95hu7tt83ditncnp7k46khn6e	expiry_notify	0	1769768048042	1769768059646	1769768059651	success	100	null
kwxbmk491td7xj7pr1ugexcwdc	expiry_notify	0	1769768708112	1769768719932	1769768719936	success	100	null
78ugpbah5t8ozrizo8ppe7esee	expiry_notify	0	1769769368160	1769769380215	1769769380222	success	100	null
humdrxjsjtbbppatmt1qfnfuia	expiry_notify	0	1769789829858	1769789834443	1769789834447	success	100	null
uh6scro9bpf93xrjk4zjgubudy	cleanup_desktop_tokens	0	1769789949874	1769789954495	1769789954500	success	100	null
r65uz5dq3jn68pbyjby18i1qry	expiry_notify	0	1769770028205	1769770040497	1769770040502	success	100	null
w9io7tsrif8edx1c5699ohk8hy	expiry_notify	0	1769772008415	1769772021452	1769772021459	success	100	null
cujewdwb7jbo7fxwx9894eeq4h	product_notices	0	1769770508246	1769770520746	1769770520849	success	100	null
wwk4ae8c5i8q78b54nkspwxzmc	expiry_notify	0	1769790489917	1769790494738	1769790494742	success	100	null
m9bb9xezstggpx7b8jgoeqgmbe	expiry_notify	0	1769770688268	1769770700841	1769770700847	success	100	null
ur7o4a9rjfr7bczek8md5wj4dy	expiry_notify	0	1769791810011	1769791815235	1769791815241	success	100	null
oxbzcadf47dgpeziara1fhqosr	expiry_notify	0	1769772668463	1769772681784	1769772681790	success	100	null
c1a1yxpk4idhdxqn9mxx56j5jc	product_notices	0	1769792110053	1769792115378	1769792115463	success	100	null
1t9rbxxsst8duk1ymjk7s7cjww	plugins	0	1769774108606	1769774122424	1769774122443	success	0	null
35wfsysjibnqmxip6jiptgtine	expiry_notify	0	1769773328515	1769773342087	1769773342091	success	100	null
hyyyxf67fpncbk78th6ws4qc9o	export_delete	0	1769774108601	1769774122424	1769774122443	success	100	null
jgqpow9u6t83mj6sxafgnrawxh	expiry_notify	0	1769773988579	1769774002358	1769774002364	success	100	null
6xtpobfe4ffbmkgwkeqwcz7uza	expiry_notify	0	1769793130122	1769793135821	1769793135828	success	100	null
eyunqfthsfge7c5irrc6fssbgh	cleanup_desktop_tokens	0	1769793550136	1769793556016	1769793556021	success	100	null
uxctm1c8mtdabro1pcxa4m88oh	expiry_notify	0	1769795110267	1769795116736	1769795116742	success	100	null
mydkhtf43bnfxx7i5mdk9s7wty	product_notices	0	1769795710312	1769795716983	1769795717093	success	100	null
u9c3x1wkgtnjxfwcxi3yqsayzr	import_delete	0	1769774108612	1769774122424	1769774122431	success	100	null
k84er3k1mt8d3jwd75fwae7gue	expiry_notify	0	1769776628764	1769776643548	1769776643554	success	100	null
ttpzmm4oqigr3xe376hhm3rn9a	product_notices	0	1769774108597	1769774122424	1769774122514	success	100	null
jrhdynsb37byuyy1y9y3adiuyw	expiry_notify	0	1769774648655	1769774662668	1769774662674	success	100	null
155h5g5hntbd9c8jyzq9dausih	cleanup_desktop_tokens	0	1769775308695	1769775322994	1769775322999	success	100	null
qiouq39rpjrnjphfgh4sc41cjh	expiry_notify	0	1769775308698	1769775322993	1769775322999	success	100	null
1wdnytwgnjf9pfurd8bqky6uyo	expiry_notify	0	1769777288800	1769777303802	1769777303809	success	100	null
7yatmmu6tpgqtjcsio4d9zc16a	expiry_notify	0	1769775968731	1769775983296	1769775983303	success	100	null
4mxbt5cq7pbxtcng415sc9cxoe	cleanup_desktop_tokens	0	1769778968960	1769778969572	1769778969580	success	100	null
jhpf7i8jetbutffsnx4eefx3xr	product_notices	0	1769777708846	1769777709005	1769777709105	success	100	null
wz18s6y5f3bo7qcww5uggkonko	expiry_notify	0	1769777948872	1769777949114	1769777949118	success	100	null
gfnaw47agbgq3kuoq53cb1wewr	expiry_notify	0	1769778608930	1769778609388	1769778609395	success	100	null
1q917cjxnpgytjrdisoikzikzo	expiry_notify	0	1769779268989	1769779269717	1769779269723	success	100	null
yeh7ae3cejbr78zo8qphuw5agy	expiry_notify	0	1769779929040	1769779930037	1769779930044	success	100	null
rx69m59geiddj8zy4bugqqd5xw	expiry_notify	0	1769780589110	1769780590382	1769780590387	success	100	null
gm8cf6u9utb5bcfrtmgfkq6jca	expiry_notify	0	1769814911842	1769814925239	1769814925244	success	100	null
u8wkbywsyfys7xbyerk9et56yw	expiry_notify	0	1769826072830	1769826075242	1769826075246	success	100	null
9tcupmm3opdwjyaroi6cyuki8r	expiry_notify	0	1769858895516	1769858909311	1769858909315	success	100	null
zt91dw8nft8jxqz51cqqemr85y	product_notices	0	1769853315159	1769853327347	1769853327442	success	100	null
f83urdrghbrgm8qi5735gx1t4r	expiry_notify	0	1769815571922	1769815585548	1769815585552	success	100	null
trjiyk4mbiym5r56o4c595758r	expiry_notify	0	1769835973679	1769835979580	1769835979586	success	100	null
mg9s7sqmobr69et861omwqqt3y	expiry_notify	0	1769826732914	1769826735558	1769826735563	success	100	null
iem9r5zqkt81jy81ja97kpcsby	expiry_notify	0	1769827392964	1769827395854	1769827395859	success	100	null
e5b6wfbrbfgcz87chw7jkhz9da	expiry_notify	0	1769853615176	1769853627440	1769853627444	success	100	null
xhzjwk6rnff45fjq1n7fr85gga	expiry_notify	0	1769828053008	1769828056159	1769828056164	success	100	null
aqntfiqab3f7zem58qpiqo7c8o	expiry_notify	0	1769855595316	1769855608247	1769855608254	success	100	null
ozs91xubh3gyff7fm3wbhf9ddy	expiry_notify	0	1769841854182	1769841862314	1769841862318	success	100	null
k7afdg4z83f6tfw6zirrpkoqwh	product_notices	0	1769828113016	1769828116183	1769828116344	success	100	null
umuyd73y9fgsfg11m9fhx5ymio	expiry_notify	0	1769837293814	1769837300196	1769837300200	success	100	null
yorsra9affdj5nwf7q3t38uqza	expiry_notify	0	1769828713077	1769828716447	1769828716452	success	100	null
upemhtoxqfbr3nhasznxq9zg7e	expiry_notify	0	1769857575445	1769857588896	1769857588906	success	100	null
ukkjthj3mtrjzcoijh7t8mmpfa	product_notices	0	1769831713327	1769831717634	1769831717737	success	100	null
pog54zn6dpn79breaqyr71hp8e	cleanup_desktop_tokens	0	1769859315531	1769859329412	1769859329418	success	100	null
9u1aate1r3gbteik4es1aorb9e	expiry_notify	0	1769833333454	1769833338350	1769833338356	success	100	null
fhgweqonh3gtdxypz7fehghkny	cleanup_desktop_tokens	0	1769833693493	1769833698512	1769833698517	success	100	null
pcqk6qximfd8fps75og4ot9r8h	expiry_notify	0	1769859555547	1769859569504	1769859569509	success	100	null
11jrjprnjine7ne1btnnnq9m6w	cleanup_desktop_tokens	0	1769837353823	1769837360226	1769837360231	success	100	null
7dry97984i8fxgkh5e63bx9wwy	expiry_notify	0	1769834653584	1769834658967	1769834658973	success	100	null
ooee16qskpgq9x1uyrqyc34g9e	expiry_notify	0	1769860215576	1769860229721	1769860229727	success	100	null
16xzcxrh5fn1in11ti36qnyu6o	expiry_notify	0	1769835313609	1769835319257	1769835319262	success	100	null
ypwa58mtgjywpnskkt4i3o5tth	product_notices	0	1769835313613	1769835319256	1769835319360	success	100	null
kiexiiyd8ty59b434ag9h7f1uc	expiry_notify	0	1769837953869	1769837960473	1769837960477	success	100	null
x968jeny7in9pcqybi94kgbnyy	export_delete	0	1769860515589	1769860529803	1769860529807	success	100	null
4mheqzroupdttdm5xyuhtebxpy	mobile_session_metadata	0	1769860515593	1769860529803	1769860529808	success	100	null
dx3zmkfrdbby8ygp5c5sorxbie	install_plugin_notify_admin	0	1769860515598	1769860529803	1769860529808	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
indxbrjhwtfa5br7otg89cqwgc	expiry_notify	0	1769838553927	1769838560767	1769838560771	success	100	null
d68qjxzqft8aufqz5przdqnx6w	plugins	0	1769860515595	1769860529803	1769860529817	success	0	null
kxpbwszh97f7zj8hrjj8r57scr	expiry_notify	0	1769860875620	1769860889903	1769860889908	success	100	null
q6ckjn3a8fr4bp13irokbzuk3r	cleanup_desktop_tokens	0	1769844674424	1769844683627	1769844683632	success	100	null
k7xjoeenopy9uewgekmax843sa	product_notices	0	1769838913962	1769838920948	1769838921044	success	100	null
q5fgctxjs7gjdjyf3mohzoqzqa	import_delete	0	1769860515599	1769860529803	1769860529818	success	100	null
8z45zh6he7nktc7z3oi4occ94r	product_notices	0	1769860515601	1769860529803	1769860529856	success	100	null
5fw9ps66cfgm7b93u9yougmyma	expiry_notify	0	1769839874055	1769839881387	1769839881393	success	100	null
cg37bhhm47y45deo9pdnkd6qky	expiry_notify	0	1769861535675	1769861550121	1769861550125	success	100	null
zg1djhafdtbbubn7dhg5zbpw1c	cleanup_desktop_tokens	0	1769841014125	1769841021935	1769841021941	success	100	null
9utt1f54x3y9xkpyy6jyhwnite	expiry_notify	0	1769841194141	1769841202024	1769841202031	success	100	null
uj677hq1sirgbjwib9jqoezo3w	expiry_notify	0	1769862195705	1769862210309	1769862210312	success	100	null
xk5xpkbartndiroi4k7ki3nhre	expiry_notify	0	1769845814532	1769845824158	1769845824165	success	100	null
tp6g94r6g7bxuczx64sxnsu4uw	expiry_notify	0	1769850434955	1769850446182	1769850446190	success	100	null
ebtgmq9bzfyk9krque1fgs6bjy	expiry_notify	0	1769847134642	1769847144714	1769847144717	success	100	null
ksewjh46xfyz8rx4r3fk56fyuc	expiry_notify	0	1769862855738	1769862870501	1769862870507	success	100	null
dga95rz14pbxfm7ojdnbqyny6r	cleanup_desktop_tokens	0	1769848334757	1769848345207	1769848345210	success	100	null
b3bkrbpmf3nefmxbmr6nmq7bnh	cleanup_desktop_tokens	0	1769862975750	1769862990540	1769862990544	success	100	null
cexistcr9tr5bm8ixw689z76rr	expiry_notify	0	1769848454766	1769848465259	1769848465264	success	100	null
nrjkw5f5u7do989mwtfksfj7wh	expiry_notify	0	1769863515771	1769863530717	1769863530728	success	100	null
ycgbphxdjty6bbb8gij85onyqy	expiry_notify	0	1769849114802	1769849125551	1769849125556	success	100	null
p8sxpi1xh7d5te179r6azxjc3w	expiry_notify	0	1769851035014	1769851046441	1769851046445	success	100	null
e5jhypyyxinq9nyws6zfs8b7ka	product_notices	0	1769864115785	1769864115929	1769864115980	success	100	null
uk1rijhwwby48xr15wj1bo877c	expiry_notify	0	1769864175795	1769864175954	1769864175958	success	100	null
1isy56ppcj8d9rjip3z6mq7yya	expiry_notify	0	1769864835836	1769864836182	1769864836189	success	100	null
eg11wqbr93bkfct8s6un5keh8e	expiry_notify	0	1769881337243	1769881343597	1769881343603	success	100	null
6iygbtozgtrntmfuhcra8pi4ty	expiry_notify	0	1769915540301	1769915543898	1769915543903	success	100	null
phxi5ghmn3818bqyc8kijt1sir	cleanup_desktop_tokens	0	1769815451896	1769815465487	1769815465492	success	100	null
u17me9zz5trp5ns59jwg1mix9a	cleanup_desktop_tokens	0	1769826372876	1769826375406	1769826375410	success	100	null
3a4q38bwktdzbfbzkw1axs9jpo	expiry_notify	0	1769854275223	1769854287723	1769854287729	success	100	null
x1ma544e1ibqjc197gga3tdjca	expiry_notify	0	1769816231969	1769816245826	1769816245828	success	100	null
n3u6momht78upbinxnmhkmpqie	expiry_notify	0	1769832673398	1769832678081	1769832678087	success	100	null
tqardqxdy7g55qnwpmfer8bznw	expiry_notify	0	1769829373139	1769829376722	1769829376728	success	100	null
xkyqif4fdidxdrmwr5fkqyi73h	expiry_notify	0	1769816892041	1769816906148	1769816906153	success	100	null
ataq5cdtyiy1pdw9436h99hdoh	expiry_notify	0	1769854935273	1769854948003	1769854948008	success	100	null
6ebpqqdd1f8rpq78td87xz6skw	expiry_notify	0	1769821452420	1769821453138	1769821453143	success	100	null
558phdmbr7g13rkfaar4iyw5re	product_notices	0	1769817312086	1769817326311	1769817326428	success	100	null
fb9cn5yrsfdb5gi5y3byowk8eo	cleanup_desktop_tokens	0	1769855655324	1769855668272	1769855668277	success	100	null
8fntut7nbbyedcucnqb1wsymoc	expiry_notify	0	1769817552130	1769817566448	1769817566454	success	100	null
fm5me5mxb7rexq5xkzjcqk8fpa	cleanup_desktop_tokens	0	1769830033157	1769830036980	1769830036986	success	100	null
hqapw1dggbd7pdafhn1rkz6pjo	expiry_notify	0	1769830033154	1769830036981	1769830036986	success	100	null
6hny4yr8itg45de5nnw5f7bsor	refresh_materialized_views	0	1769817612140	1769817626477	1769817626497	success	100	null
pba47uhqkibi7kcjoy6gey7z4e	expiry_notify	0	1769856255358	1769856268460	1769856268467	success	100	null
3hs6r3fxu3ysxepmcizmnzqixw	expiry_notify	0	1769842514240	1769842522605	1769842522610	success	100	null
hzm4r46nsjbomgzsy7ry6ugwze	expiry_notify	0	1769818212184	1769818226733	1769818226739	success	100	null
ni4ai5rk4jywicmj4kne1y99zy	expiry_notify	0	1769830693219	1769830697228	1769830697230	success	100	null
uhhdzh7onirazgpdzoq9o8je1w	expiry_notify	0	1769822112453	1769822113467	1769822113473	success	100	null
hoepout157fszezr4wd3q5187o	expiry_notify	0	1769818872234	1769818887034	1769818887040	success	100	null
skzppmmi8tbctp7j3exsxs1s3r	expiry_notify	0	1769833993516	1769833998652	1769833998659	success	100	null
4gts9h7swbg5zj83rab346uu9y	expiry_notify	0	1769831353280	1769831357506	1769831357510	success	100	null
3ow6tn59g3yef8tkis8x53om1e	cleanup_desktop_tokens	0	1769819052244	1769819067102	1769819067107	success	100	null
bdimm1fbh3g4tq7k3pxhoaie1w	expiry_notify	0	1769856915390	1769856928662	1769856928668	success	100	null
7tj9iuuyjtybpb6ht9ktdksx6r	expiry_notify	0	1769819532266	1769819532295	1769819532298	success	100	null
m7gx6fzcsjbyux6nihyi7tpadw	expiry_notify	0	1769832013348	1769832017789	1769832017793	success	100	null
68c9sosfa3bemmckxhd3yt6rwc	product_notices	0	1769856915395	1769856928661	1769856928750	success	100	null
q3uhdzwsjig6byb3d4tm7btiwo	expiry_notify	0	1769820192316	1769820192595	1769820192600	success	100	null
ytn8dizu1bymiqc3aqf6pdy9ky	expiry_notify	0	1769858235489	1769858249122	1769858249130	success	100	null
3ds9m4ktj3bcbkde6io1rtjzer	cleanup_desktop_tokens	0	1769822712515	1769822713727	1769822713731	success	100	null
ifey9p6kopr1xysn51q61kuoth	expiry_notify	0	1769820792376	1769820792873	1769820792878	success	100	null
warxmohcgfrwdgj338giwg8d4y	expiry_notify	0	1769836633752	1769836639879	1769836639883	success	100	null
sk8sd8baqfy3zgb3b6qx8gxezc	product_notices	0	1769820912390	1769820912909	1769820913018	success	100	null
jb6sb51kyjr5jmxw4897wmqf4o	product_notices	0	1769842514244	1769842522605	1769842522737	success	100	null
59d6pf3a5pbpbmyz86auq61nme	expiry_notify	0	1769839214010	1769839221120	1769839221126	success	100	null
fe4xnztpy3gdffkag3gsstpebe	expiry_notify	0	1769822772523	1769822773744	1769822773748	success	100	null
u68dwrhn5jfzmpj78gwb1fi55w	expiry_notify	0	1769823432572	1769823434025	1769823434027	success	100	null
afyux1gaxpdk9roa318sz8ubxa	expiry_notify	0	1769840534099	1769840541704	1769840541710	success	100	null
rgf5ubaiwpbsb8ayqtc9odsuzw	expiry_notify	0	1769824092612	1769824094350	1769824094356	success	100	null
c5johpqjdigbjnqhq1y6knuaxa	product_notices	0	1769824512658	1769824514571	1769824514684	success	100	null
sr536am5q7di7yfnj3moarwyjh	expiry_notify	0	1769843174290	1769843182887	1769843182894	success	100	null
wq7uihw9djrk8m9zb7ur7oorde	expiry_notify	0	1769824752669	1769824754673	1769824754677	success	100	null
h9azism1sfn1jy87mpy5jdssro	expiry_notify	0	1769845154479	1769845163866	1769845163870	success	100	null
zwi5y7crbigq8jhssi75d5om7h	expiry_notify	0	1769843834354	1769843843214	1769843843218	success	100	null
99chi6pjziyubd9jm4ibnkadky	expiry_notify	0	1769844494409	1769844503542	1769844503547	success	100	null
hb537obkmpy6in1upxm9hqp6py	product_notices	0	1769846114577	1769846124308	1769846124434	success	100	null
xbmy19jthjrjupbimxgb37kjuw	expiry_notify	0	1769847794708	1769847804990	1769847804996	success	100	null
mmcq7gf9c3yfznswmfr3z8r3gh	expiry_notify	0	1769846474601	1769846484469	1769846484471	success	100	null
8g6wsj15q7nkxjjt846yu7w1so	expiry_notify	0	1769849774868	1769849785856	1769849785859	success	100	null
pa1pspbzbtraikh4kyq5mxhpfw	product_notices	0	1769849714857	1769849725824	1769849725916	success	100	null
t1owej79kpry9xydzz4e7djuqo	expiry_notify	0	1769851695081	1769851706711	1769851706714	success	100	null
gmry3b4atbfjpk84g6sy56x77w	cleanup_desktop_tokens	0	1769851995115	1769852006815	1769852006818	success	100	null
ujkizsni4fnh8rmbo66zni61bh	expiry_notify	0	1769852355137	1769852367008	1769852367014	success	100	null
pdnd3kdsqjyq9bwrqfm57afxdy	product_notices	0	1769950523278	1769950524750	1769950524885	success	100	null
xgtgp5kwx7ripekmp5r8367f1h	expiry_notify	0	1769865495889	1769865496517	1769865496523	success	100	null
sistp6nfgpy87rdj576ugyqyfe	expiry_notify	0	1769883977482	1769883984856	1769883984860	success	100	null
fbx59rxx67bd9rkxfh17ucrnqw	expiry_notify	0	1769881997292	1769882003899	1769882003907	success	100	null
d4mxox177byu5p9okp66x43t3h	expiry_notify	0	1769866155921	1769866156817	1769866156824	success	100	null
t5x46h5faj8ite98b8mug34j3c	product_notices	0	1769882117317	1769882123982	1769882124044	success	100	null
eenwq96rjpge5prwkupi39objy	cleanup_desktop_tokens	0	1769866635963	1769866637027	1769866637033	success	100	null
ckhgmmgk9jfatpuzj76rqsh14r	expiry_notify	0	1769871436347	1769871439130	1769871439136	success	100	null
mc8tytgrgfdfmj7uzb393ebhpc	expiry_notify	0	1769866815983	1769866817112	1769866817118	success	100	null
owaspxt6n7gsjjhwpgsda4uohh	expiry_notify	0	1769882657378	1769882664243	1769882664249	success	100	null
98qndz7s5pf4fn4wfdd9t7p81h	expiry_notify	0	1769867476029	1769867477401	1769867477409	success	100	null
n7hrmf4b6fgbtr1yeex9ah5nre	expiry_notify	0	1769883317452	1769883324607	1769883324611	success	100	null
xkr8qzepmfyyucug18w14iw3dy	product_notices	0	1769867716056	1769867717519	1769867717590	success	100	null
hrkmr98j87fnie9wytm77577ea	expiry_notify	0	1769876056768	1769876061120	1769876061127	success	100	null
p358oprgmtdnzgayhhfkgiotmr	expiry_notify	0	1769868136075	1769868137646	1769868137652	success	100	null
dituy1ffo3dgzmedbyqu8zd1ha	expiry_notify	0	1769884637538	1769884645162	1769884645166	success	100	null
bxoee8a5jt89jm5uua3juotegc	expiry_notify	0	1769872096402	1769872099427	1769872099434	success	100	null
cxp8fsfzi3rx5fqdpnt61sezmo	expiry_notify	0	1769868796106	1769868797902	1769868797909	success	100	null
7s5eac39qjg9mc8q8f34bok1iy	cleanup_desktop_tokens	0	1769884937561	1769884945313	1769884945318	success	100	null
e3ukbgfebjna7k3e1hfou6dwdw	expiry_notify	0	1769869456165	1769869458205	1769869458211	success	100	null
rynwmeyojibpmemnqho19sgy4a	product_notices	0	1769885717622	1769885725578	1769885725653	success	100	null
acq4ng455pgodrqiywrbw1ywca	expiry_notify	0	1769870116209	1769870118529	1769870118536	success	100	null
47rpe4saqb8tffzdz86adiu1ay	expiry_notify	0	1769885297579	1769885305427	1769885305429	success	100	null
oroiuzktjpby8ppkzju9cg7zne	cleanup_desktop_tokens	0	1769870296223	1769870298595	1769870298597	success	100	null
7db15dpy5pyxznike3mx1dfbda	expiry_notify	0	1769886617708	1769886625999	1769886626005	success	100	null
zd3e1um7gfgszbp3sgqiks5jje	expiry_notify	0	1769885957649	1769885965689	1769885965695	success	100	null
ju3brsd1ujdedjmdhf1uemuyza	expiry_notify	0	1769872756475	1769872759769	1769872759777	success	100	null
bgzm9ko4qig5tnmjq6hg95g4ic	expiry_notify	0	1769870776272	1769870778833	1769870778839	success	100	null
4c33khtfoib3ixxcnyaqas7b3o	product_notices	0	1769871316328	1769871319087	1769871319150	success	100	null
u1xqxspanfyfie3mbjh7x4ypia	expiry_notify	0	1769873416538	1769873420047	1769873420051	success	100	null
ja7npjck8f8r98o4hm4r6fkmio	expiry_notify	0	1769887277783	1769887286282	1769887286290	success	100	null
yeidhc718tdyxc14ekf7ki4ujh	expiry_notify	0	1769879357078	1769879362652	1769879362657	success	100	null
yo7rpas99jgr3yjj16etwwpybw	cleanup_desktop_tokens	0	1769873956580	1769873960280	1769873960286	success	100	null
nh4ogajyb7fp88kawsedz9iyor	expiry_notify	0	1769887937839	1769887946580	1769887946584	success	100	null
rbk6rhs8ybnppdcx6qtppggh9a	expiry_notify	0	1769876716834	1769876721408	1769876721416	success	100	null
id4q1w9t7bftxgac5pqetsi64e	expiry_notify	0	1769874076595	1769874080336	1769874080342	success	100	null
eooyq8ct77rr7ntxcnumqk1g5c	expiry_notify	0	1769874736665	1769874740581	1769874740586	success	100	null
yta3b57skfr95g1w1y7z5b5o3y	cleanup_desktop_tokens	0	1769888597902	1769888606880	1769888606884	success	100	null
i7zruwi6bfdwmnyx4wo34y7i4y	expiry_notify	0	1769888597897	1769888606880	1769888606885	success	100	null
a3h5cgd3t3d79frfg9ocipimsy	product_notices	0	1769874916687	1769874920650	1769874920722	success	100	null
8rrmypkihfrm7n9prwzeb3ynro	expiry_notify	0	1769889257968	1769889267174	1769889267182	success	100	null
x6gofm8xhfd5ugq8ofw8xwwn1c	expiry_notify	0	1769875396711	1769875400839	1769875400846	success	100	null
66cf677fm7dimeqnbzywf86a6y	product_notices	0	1769889317980	1769889327200	1769889327267	success	100	null
i8ghz9cmfpy9mjrkijh9hh9q8c	expiry_notify	0	1769877376893	1769877381745	1769877381752	success	100	null
7gjqpxg67i8otxqjwxgc73nbse	expiry_notify	0	1769889918041	1769889927469	1769889927473	success	100	null
567j1zpa9pboiyp85cp1zue5cc	cleanup_desktop_tokens	0	1769877616917	1769877621853	1769877621857	success	100	null
c1kohqaq7tghtqw7h5zemjxtke	expiry_notify	0	1769890578085	1769890587794	1769890587801	success	100	null
anr59uezp78e5q4gagwsmdwode	expiry_notify	0	1769878036966	1769878042055	1769878042058	success	100	null
1umif4bixinwbxqjoxw9xswxwa	expiry_notify	0	1769880017129	1769880022954	1769880022956	success	100	null
zit9mbkq17y38fbk97wzfmooqe	product_notices	0	1769878517011	1769878522248	1769878522301	success	100	null
9kumbojoi7fb5kwhuj1wtq1n6o	expiry_notify	0	1769891238134	1769891248129	1769891248135	success	100	null
qrykniezbjno38ybj1kgq6b9tc	expiry_notify	0	1769878697033	1769878702344	1769878702350	success	100	null
ezhgag7s53rfido3qwdbar39gh	expiry_notify	0	1769891898189	1769891908486	1769891908490	success	100	null
9ismgukun7yzjn5qhikf6yhs6c	cleanup_desktop_tokens	0	1769892198233	1769892208642	1769892208648	success	100	null
n9gsrd4etpdjt8uxufdtbuksiw	expiry_notify	0	1769880677200	1769880683259	1769880683262	success	100	null
bmsj6apfm3gt9mztsuxbmuhgra	cleanup_desktop_tokens	0	1769881277231	1769881283571	1769881283577	success	100	null
68y46tyeotrxdmcyjdcgwfu8uh	expiry_notify	0	1769992466932	1769992468833	1769992468837	success	100	null
e6d4j9qmkid68czgws8f38bkdc	expiry_notify	0	1769892558266	1769892568820	1769892568827	success	100	null
ux8j9cbaujr98jngzn6bxu6jfe	expiry_notify	0	1769916200351	1769916204221	1769916204228	success	100	null
88i653wo5b8n58g6csc5uryyhe	product_notices	0	1769892918301	1769892929003	1769892929077	success	100	null
km6b1qt8b7nz5de15y6yc61ycr	expiry_notify	0	1769916860399	1769916864550	1769916864554	success	100	null
4it4gmhr4frxtpdwcy6n5d3cpw	expiry_notify	0	1769893218336	1769893229126	1769893229134	success	100	null
4s7spn5zfi8btgotcejf73444o	expiry_notify	0	1769917520445	1769917524866	1769917524870	success	100	null
3yqitrzd9ib8xcj6q934zmi7ee	expiry_notify	0	1769899158836	1769899171669	1769899171676	success	100	null
gffotnrbjfn37e1eu9ddp7x3zy	expiry_notify	0	1769893878392	1769893889436	1769893889442	success	100	null
u8t8h76hcirnunajy7s8rgkt6y	cleanup_desktop_tokens	0	1769917820476	1769917825017	1769917825021	success	100	null
x1jtsaarujy6mj1bka7wq9qqhh	expiry_notify	0	1769894538448	1769894549748	1769894549754	success	100	null
7cnt5mtw9fgoumebqinfisfp6w	product_notices	0	1769918120510	1769918125127	1769918125234	success	100	null
t4jz7scuib8ntxnt5tnbn346xh	expiry_notify	0	1769895198502	1769895210050	1769895210053	success	100	null
bd18tory638ctqr7s96zz6563y	cleanup_desktop_tokens	0	1769903179150	1769903193355	1769903193360	success	100	null
8yugr7pw73f3pjxcecmtz8b9ce	cleanup_desktop_tokens	0	1769899518859	1769899531840	1769899531846	success	100	null
ik6db968mjri3pnxdtppngsdfy	expiry_notify	0	1769895858575	1769895870337	1769895870342	success	100	null
op56isam8fr138qcjiapdcwwmr	cleanup_desktop_tokens	0	1769895858571	1769895870337	1769895870342	success	100	null
s7h8xzs4ntbtjx6ezx4ddhuneh	expiry_notify	0	1769896518584	1769896530552	1769896530560	success	100	null
idy19wuogffzdd9u3hswzy79ye	product_notices	0	1769896518590	1769896530552	1769896530609	success	100	null
5jrzqzm9e7g8dxif66fiw7mb4a	expiry_notify	0	1769897178661	1769897190851	1769897190856	success	100	null
o9xugodfitfbbm18nea9z7du6e	expiry_notify	0	1769899818889	1769899832006	1769899832011	success	100	null
6dmqtjd9oinh9etsg8xmeqywra	expiry_notify	0	1769897838707	1769897851110	1769897851118	success	100	null
yx5f49ki5pd6pqf1kidq3fy4jh	expiry_notify	0	1769898498765	1769898511351	1769898511354	success	100	null
d3qd9kazcibmpb4a4udnbiunyc	product_notices	0	1769900118910	1769900132134	1769900132197	success	100	null
nf5tj77fdtbh9yiw1zkst48a3c	expiry_notify	0	1769900478944	1769900492294	1769900492302	success	100	null
t9i7mxbnbp8tbbj9ynieq3uw9a	product_notices	0	1769903719194	1769903733640	1769903733696	success	100	null
hrqtrw595tfp9jsdgoe73uz1ea	expiry_notify	0	1769901138994	1769901152556	1769901152564	success	100	null
8ii89bh4nbb8zjx6rz5e6r5r9y	expiry_notify	0	1769901799035	1769901812776	1769901812782	success	100	null
ojo5nnsoyjnh3g6n6zubo6d48o	expiry_notify	0	1769902459070	1769902472989	1769902472991	success	100	null
4sx5qzijifnx7nc9aer7boofdc	expiry_notify	0	1769906419427	1769906419915	1769906419920	success	100	null
tkt8d397bffnuybzticujukgsr	expiry_notify	0	1769903119137	1769903133331	1769903133338	success	100	null
bxjfb74gxbnbmyyb5n9yqgxwpy	expiry_notify	0	1769903779200	1769903793669	1769903793674	success	100	null
cuabrab85tn6mpd4tsq9f3pazr	refresh_materialized_views	0	1769904019234	1769904033774	1769904033796	success	100	null
8o7u35877b89mfzafk4m9uwy3w	expiry_notify	0	1769904439272	1769904454005	1769904454012	success	100	null
mmq4pr9txb86zfoz56m1m4oesy	expiry_notify	0	1769905099309	1769905114308	1769905114312	success	100	null
96tumrsgbtno5ka9c9jfgk7msy	cleanup_desktop_tokens	0	1769906839473	1769906840120	1769906840125	success	100	null
dzun8f13fi8ijcucczz4a6ik7r	expiry_notify	0	1769905759378	1769905759576	1769905759581	success	100	null
fu7kj95uc38wbgraok7h7ycf1e	expiry_notify	0	1769908339642	1769908340808	1769908340814	success	100	null
56fdy14hgpn1t8dzuhdjp9t8by	expiry_notify	0	1769907079518	1769907080249	1769907080253	success	100	null
ndtycnrudbf4mpqgeai1nnrgwa	product_notices	0	1769907319548	1769907320350	1769907320413	success	100	null
mo5adaizp3bc3djj7i9gwghmah	expiry_notify	0	1769907679579	1769907680508	1769907680514	success	100	null
edij4dmmc3b83nx7h33nq8su3r	expiry_notify	0	1769908999708	1769909001095	1769909001098	success	100	null
nq5i9qdsk3d3fnsuwdz3kkse3o	expiry_notify	0	1769909599737	1769909601201	1769909601206	success	100	null
a9wdc7guubd1teyhu5yoju4zaw	cleanup_desktop_tokens	0	1769910499816	1769910501573	1769910501578	success	100	null
5gda4cmxb3dadd9319pbih7dgy	expiry_notify	0	1769910259787	1769910261463	1769910261467	success	100	null
zoccxjcej3dzmjckbeib4gfq1c	expiry_notify	0	1769910919860	1769910921776	1769910921782	success	100	null
kqxbx8uyypf4frjimskgg1n1xy	product_notices	0	1769910919864	1769910921776	1769910921846	success	100	null
c4n6k1qzyjr59pfqk3ptuzetqy	expiry_notify	0	1769911579920	1769911582071	1769911582074	success	100	null
dkho8wsx67f17b4hxhjg4urmdh	expiry_notify	0	1769913560108	1769913563012	1769913563017	success	100	null
5ppoqie1fi8b5em7hcftdmqdyo	expiry_notify	0	1769912239979	1769912242363	1769912242369	success	100	null
josdrwgbuiyqmp7r54u4hto1br	expiry_notify	0	1769912900057	1769912902671	1769912902676	success	100	null
qjm4yt6157yw3xtroynmsjecwy	cleanup_desktop_tokens	0	1769914160160	1769914163259	1769914163265	success	100	null
ut51776po7nx5d1nsi9djamsqr	expiry_notify	0	1769914220175	1769914223291	1769914223299	success	100	null
38kt49rmdfgjtd3wo18z3igb6e	product_notices	0	1769914520201	1769914523440	1769914523546	success	100	null
srsjbq6kcpfjmm8hopnjg7cgbo	expiry_notify	0	1769914880235	1769914883594	1769914883596	success	100	null
1k6t5g6fttfz8ns9b7o833gphe	expiry_notify	0	1770036030841	1770036034256	1770036034262	success	100	null
a9ug8daydpb67cysmer388bpyo	expiry_notify	0	1769918180527	1769918185151	1769918185156	success	100	null
z16bje43h7f6dkbpn6ms6jwzzo	expiry_notify	0	1769918840577	1769918845441	1769918845448	success	100	null
n9639q3s3pg6jgz78s5eh4u6wy	expiry_notify	0	1769919500619	1769919505706	1769919505711	success	100	null
iw5m6htxcfgm5egi3558fomc6c	cleanup_desktop_tokens	0	1769925141068	1769925148288	1769925148293	success	100	null
4wcsu1e9oj895dg8g5zn85swao	expiry_notify	0	1769920160692	1769920166026	1769920166033	success	100	null
kqm9jct6mtfcj8uhn77pbbqzxh	expiry_notify	0	1769920820725	1769920826296	1769920826303	success	100	null
5ir7495g978kir6q4est5itfte	product_notices	0	1769928921429	1769928930089	1769928930203	success	100	null
toqe5eymjfygbn89td76gpiyce	cleanup_desktop_tokens	0	1769921480768	1769921486609	1769921486615	success	100	null
j86tsfxmdfbhmcjziqdnh4gcer	expiry_notify	0	1769921480773	1769921486609	1769921486616	success	100	null
ieyxi69a4tryjkr187ajh1axzw	product_notices	0	1769925321089	1769925328377	1769925328486	success	100	null
jri7kccjy7napfyaare5gxcxxr	product_notices	0	1769921720806	1769921726718	1769921726834	success	100	null
g9qdgsrig38njr1aigzmujae8w	expiry_notify	0	1769922140839	1769922146921	1769922146926	success	100	null
p7ez5uqoxby3pcnf89qjhpwszy	expiry_notify	0	1769922800883	1769922807221	1769922807228	success	100	null
4beecaomzpg7mkdawfcqwq9y1a	expiry_notify	0	1769923400935	1769923407493	1769923407499	success	100	null
w9wk7wtzdf89dbh34sr3e61nze	expiry_notify	0	1769925381098	1769925388405	1769925388409	success	100	null
h1dx86qcf7fp9c4ugp7oh65rjy	expiry_notify	0	1769924060995	1769924067795	1769924067801	success	100	null
tcax4pacgbb8dncuecms4jajwa	expiry_notify	0	1769924721044	1769924728088	1769924728094	success	100	null
69heeqreafym7dsfy1o736u63a	expiry_notify	0	1769926041173	1769926048728	1769926048733	success	100	null
rxuib6367fnebqnzqfnw13dtwy	product_notices	0	1769932521731	1769932531754	1769932531863	success	100	null
xmeftb7moffnuce4wmmdb669ha	expiry_notify	0	1769926701220	1769926709051	1769926709057	success	100	null
dm8gpb14q3gbdfweschc6g7irw	expiry_notify	0	1769929281454	1769929290272	1769929290275	success	100	null
xgzzrhdet3n5zcioh61pzre1fc	expiry_notify	0	1769927361286	1769927369346	1769927369353	success	100	null
tezu5yn5y3r45b3ya6od45uwxo	expiry_notify	0	1769928021338	1769928029643	1769928029650	success	100	null
51s9x4zmajfsmgr9wmettoepiy	expiry_notify	0	1769928621410	1769928629940	1769928629946	success	100	null
81kd14gmdt8r9jqmbg33yypz4e	cleanup_desktop_tokens	0	1769928801424	1769928810033	1769928810037	success	100	null
e3ofj7m5xifnteyerceamhjubw	expiry_notify	0	1769929941510	1769929950558	1769929950563	success	100	null
5eygbiz8wjd3tpbxdgn1ayptba	expiry_notify	0	1769930601552	1769930610850	1769930610855	success	100	null
rtpgjsdyyjr8bjgi4iaac11fsy	expiry_notify	0	1769935221988	1769935232977	1769935232983	success	100	null
4zpafr5pgjbz88tszhs3eq8rzh	expiry_notify	0	1769931261603	1769931271165	1769931271169	success	100	null
fziwisndkpf49nzhjy5wr8imde	expiry_notify	0	1769932581740	1769932591771	1769932591776	success	100	null
87hibff6ojyidkm4yfox9fp4oh	expiry_notify	0	1769931921670	1769931931505	1769931931511	success	100	null
jcra6ebrainnfpcyd9sxxx58zo	cleanup_desktop_tokens	0	1769932461716	1769932471727	1769932471731	success	100	null
yw61fbhu9jf65em4hes5i4zxmo	expiry_notify	0	1769933241797	1769933252053	1769933252059	success	100	null
5xgzcuzdz3yzxfnmdgt3xf8ozw	expiry_notify	0	1769933901848	1769933912350	1769933912356	success	100	null
wk1yh3u1ybdaien8mwfk9fm85c	expiry_notify	0	1769934561913	1769934572655	1769934572661	success	100	null
a36st6rbajge8pibhid8apdzhc	expiry_notify	0	1769935882024	1769935893253	1769935893257	success	100	null
fouxnzuzntbxicdqoqjq9s53or	expiry_notify	0	1769936542085	1769936553562	1769936553566	success	100	null
it3wtfrx8pd8dy68p3c63ansyr	cleanup_desktop_tokens	0	1769936062039	1769936073333	1769936073337	success	100	null
tpzhsz1gjpbqub37bnpad56ggw	product_notices	0	1769936122050	1769936133359	1769936133461	success	100	null
mms4cwwcotfmpc1bwgk9sx495w	expiry_notify	0	1769937202143	1769937213832	1769937213838	success	100	null
3x9fx9upxjyrdqz8mahiegqpch	expiry_notify	0	1769937862187	1769937874098	1769937874103	success	100	null
qxrsjct8mjb63koo1y8htmj1gh	expiry_notify	0	1769938522235	1769938534404	1769938534410	success	100	null
m5jhofuq9tndtrbsnufgf3k8go	expiry_notify	0	1769939182284	1769939194686	1769939194692	success	100	null
jm5h7w88abbxxytiw8f8uxcmia	product_notices	0	1769939722344	1769939734944	1769939735050	success	100	null
k9za46jjatf4pjzoyyu63sipjw	cleanup_desktop_tokens	0	1769939722338	1769939734945	1769939734950	success	100	null
6i115q5kxtgczmsq5qnhaki5cw	expiry_notify	0	1769939842349	1769939854972	1769939854976	success	100	null
hek5n1kob7neibrxur5q7o5pqe	expiry_notify	0	1769940502394	1769940515234	1769940515238	success	100	null
z9rbdu117br53rbi57eabfhyto	expiry_notify	0	1769941162434	1769941175489	1769941175495	success	100	null
ew7akocobpd43n8kifss74ma6c	expiry_notify	0	1769941822489	1769941835811	1769941835817	success	100	null
9gqzhdmpbtgwfjubrs8umyf89h	expiry_notify	0	1769942482539	1769942496121	1769942496128	success	100	null
dcm3rpu9gfg8jyzsgj4qo686sw	expiry_notify	0	1769943142594	1769943156428	1769943156433	success	100	null
yf5djkncgtdn5j88mja7rh1bky	product_notices	0	1769943322616	1769943336502	1769943336611	success	100	null
1j7i4h6s37bc9y78cdyzsur4ge	cleanup_desktop_tokens	0	1769943382623	1769943396529	1769943396534	success	100	null
9ijxem756jnc98m4sowqg68dpe	expiry_notify	0	1770086675589	1770086684631	1770086684637	success	100	null
x54pon6eijn57yrejdbnu565tw	cleanup_desktop_tokens	0	1769950643293	1769950644801	1769950644804	success	100	null
umqwszxzxbrni8r1osapmpmzbo	expiry_notify	0	1769943802654	1769943816697	1769943816700	success	100	null
1zifqipjpirxbjxo85fzmm7u3r	expiry_notify	0	1769947763026	1769947763526	1769947763534	success	100	null
54oem5pcgjn5jgrr8yken5ecte	expiry_notify	0	1769944462685	1769944476965	1769944476967	success	100	null
8wqt8z4zgifqjndayx5rwqxgfo	expiry_notify	0	1769954363600	1769954366580	1769954366586	success	100	null
5tc43tttmbyk3bg5wyfsnnn8pr	expiry_notify	0	1769951063324	1769951064971	1769951064973	success	100	null
zysz46zm3fgw3b7twnofrxyh3h	expiry_notify	0	1769945122746	1769945137278	1769945137282	success	100	null
971x34x7tjgmmdomk95s7rmgoy	expiry_notify	0	1769951723381	1769951725267	1769951725270	success	100	null
nj8j7ntzebnftj3y8gf1uk5tro	expiry_notify	0	1769945782807	1769945797583	1769945797589	success	100	null
uj9wrdt9uf8jdp9fwigd6smuro	expiry_notify	0	1769946442864	1769946442921	1769946442927	success	100	null
fhot6yf56ty1zmwu8oe1af5swc	expiry_notify	0	1769952383455	1769952385562	1769952385567	success	100	null
onk6m9epppyxpmueukhwfwpxyo	product_notices	0	1769957723916	1769957728046	1769957728143	success	100	null
iyc1defgx78wufpoz4a7oodric	expiry_notify	0	1769953043486	1769953045930	1769953045933	success	100	null
jjg7c86dnpy8jkamhi9kdod78r	expiry_notify	0	1769955023654	1769955026904	1769955026907	success	100	null
a8c4bcrbfpdo9y4pfswjn8zmby	expiry_notify	0	1769953703546	1769953706252	1769953706260	success	100	null
ttfr49fpnjb8bbritnksxw9gcw	expiry_notify	0	1769948423060	1769948423842	1769948423848	success	100	null
jsiagwpnmtgcxjm3k6qsskbkqr	import_delete	0	1769946922928	1769946923129	1769946923134	success	100	null
49wj8wzpzby49ccuk5gqo5heyr	export_delete	0	1769946922922	1769946923130	1769946923134	success	100	null
9m7s4e7jmjfpzgr6mcgsq6ocoo	mobile_session_metadata	0	1769946922924	1769946923130	1769946923134	success	100	null
pt161x3ff7ba5kqegxf8ow5o4a	product_notices	0	1769954123573	1769954126463	1769954126548	success	100	null
o7twt7jxufnb5y6wyczs45drpr	plugins	0	1769946922925	1769946923130	1769946923145	success	0	null
aqq5qkrysi81zfo81sih596rqh	install_plugin_notify_admin	0	1769946922926	1769946923130	1769946923148	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
khn9xo7qcpb6tcqih6tk1g31sy	product_notices	0	1769946922920	1769946923130	1769946923243	success	100	null
hyizzqdq9bbbzxq3hdzrr73ydr	cleanup_desktop_tokens	0	1769954303591	1769954306547	1769954306553	success	100	null
xfcoac58etg9pr7nn1rmmtqkto	expiry_notify	0	1769949083113	1769949084122	1769949084125	success	100	null
mau5yyix5fbtdq9b4j1yfow9kr	cleanup_desktop_tokens	0	1769947042945	1769947043176	1769947043182	success	100	null
nyos6ahfybdzxekhbaczmt3b5h	expiry_notify	0	1769947102955	1769947103196	1769947103202	success	100	null
q8os8mouhfg3jk7cd3cb9ha4dr	expiry_notify	0	1769955683712	1769955687100	1769955687104	success	100	null
ghgkkzu6ef8jjpe5m8jmoe13nw	expiry_notify	0	1769949743191	1769949744380	1769949744383	success	100	null
mwc1r8z49tnzix19rmzcemyfwr	expiry_notify	0	1769956343776	1769956347381	1769956347387	success	100	null
ew9ckobegfy39qmpgsb3r5kqsy	expiry_notify	0	1769950403252	1769950404689	1769950404691	success	100	null
oxubr96tqbfhbfzyxqro9rqtba	cleanup_desktop_tokens	0	1769957963937	1769957968175	1769957968180	success	100	null
nx53gkfsybfkxfoaizdun6jhee	expiry_notify	0	1769957003819	1769957007655	1769957007659	success	100	null
5q1pzomwwbguppaaoq9jjbnn1w	expiry_notify	0	1769957663885	1769957667999	1769957668005	success	100	null
swu8a46n9tgh3yhdspypyepc5w	expiry_notify	0	1769962224327	1769962230067	1769962230072	success	100	null
g5obu84hibrt8nb69y34sam3ir	expiry_notify	0	1769960304110	1769960309219	1769960309226	success	100	null
ffa7t5wabiruxgm8zxpsqoug8e	expiry_notify	0	1769958323970	1769958328342	1769958328346	success	100	null
5hnifhxco7bfjqxnhuc3nroh8y	expiry_notify	0	1769958984038	1769958988652	1769958988657	success	100	null
8kayput9qbreigid7oid55bkfy	expiry_notify	0	1769959644081	1769959648940	1769959648944	success	100	null
da3hyrf1rtf5fdrti9ji9gpdey	expiry_notify	0	1769961564242	1769961569743	1769961569749	success	100	null
6dka1wtp1bgtuboxqu43w6pmir	expiry_notify	0	1769960904172	1769960909470	1769960909475	success	100	null
awwhbyi6wtbhucrerhfomdnnxe	product_notices	0	1769961324221	1769961329651	1769961329779	success	100	null
ozax9ntoyjdodmxaqhhenn1fdw	cleanup_desktop_tokens	0	1769961624249	1769961629768	1769961629773	success	100	null
y1cdsqn9t7gjjr5366i96ew8de	expiry_notify	0	1769964204457	1769964211010	1769964211015	success	100	null
sozf1s4aq7djbqybpt9h4y641w	expiry_notify	0	1769963544416	1769963550681	1769963550687	success	100	null
xn4tgy16mpfruj9x733c8d1ior	expiry_notify	0	1769962884371	1769962890380	1769962890386	success	100	null
pcefz4bt1ifn58sm5kajor59wo	expiry_notify	0	1769964804496	1769964811271	1769964811275	success	100	null
4zzkrstuspf33c5hajd9mp8bsw	product_notices	0	1769964924519	1769964931327	1769964931444	success	100	null
prdy8p7wzfntdki753nen77f6y	cleanup_desktop_tokens	0	1769965284538	1769965291476	1769965291482	success	100	null
rawpjcycbp8xbd6nex11i67iuc	expiry_notify	0	1769965464564	1769965471544	1769965471548	success	100	null
qfichgh4didrbntrupzohb5nhc	expiry_notify	0	1769966124625	1769966131860	1769966131866	success	100	null
x3344jdzypye9fpatijwjduekc	expiry_notify	0	1769966784681	1769966792159	1769966792163	success	100	null
iwrzd16tp3b85c5weghbbbx8fy	expiry_notify	0	1769967444745	1769967452437	1769967452442	success	100	null
6qkba5jt7in1zndatgxy9pemde	expiry_notify	0	1769968104791	1769968112758	1769968112765	success	100	null
ptxdggtw9igf5n3kz1jdxu35hc	expiry_notify	0	1770141280740	1770141282456	1770141282461	success	100	null
qregjs8rwf87xqi6nrrx34dfxh	expiry_notify	0	1769993126979	1769993129023	1769993129031	success	100	null
5xsbzes187nhfmjpswx1bsa6fa	product_notices	0	1769968524840	1769968532971	1769968533101	success	100	null
nksi9m4uxtneingz1bwh7z5c9o	expiry_notify	0	1769968764872	1769968773086	1769968773091	success	100	null
pda5ootnebd6merfii6pruhcuc	product_notices	0	1769993727013	1769993729315	1769993729423	success	100	null
yefoee3gp3y9dbhy8abx6s6hhh	cleanup_desktop_tokens	0	1769968944886	1769968953180	1769968953185	success	100	null
pqm1bp4s7tfmunmu7krp3qe7kc	expiry_notify	0	1769974705386	1769974715946	1769974715953	success	100	null
ddfpp66iu3yi7j8xxqhkkz5ise	expiry_notify	0	1769969424934	1769969433386	1769969433390	success	100	null
prfpdn7infbfjcswwub648sqfe	expiry_notify	0	1769970084992	1769970093719	1769970093724	success	100	null
j8jgyq5skjnhfrcrnxpk8ogy1y	expiry_notify	0	1769970745042	1769970754022	1769970754027	success	100	null
197kbqssntn4mefao6zy17dpdr	expiry_notify	0	1769971405112	1769971414346	1769971414352	success	100	null
wsykkrdautdymdwmat7tajxine	expiry_notify	0	1769975365460	1769975376241	1769975376247	success	100	null
p8qx4nsq93ddzk9qb9r5ogybdc	expiry_notify	0	1769972065150	1769972074625	1769972074629	success	100	null
sudbt9pr9jg1zj3o874zpuraor	product_notices	0	1769972125163	1769972134647	1769972134764	success	100	null
buycpym5mj83mywzh19oaqw9ye	cleanup_desktop_tokens	0	1769972605200	1769972614893	1769972614898	success	100	null
4hxxs9qk9ibk7p44om56udrpmo	expiry_notify	0	1769972725209	1769972734958	1769972734963	success	100	null
5bgguc9xup8tpy6h51y89gj3sy	product_notices	0	1769975725496	1769975736418	1769975736500	success	100	null
qkyzeqee43ruxritp41o6hbpqa	expiry_notify	0	1769973385257	1769973395251	1769973395258	success	100	null
yzbqf4rz778s5reqxjex8nbhqr	expiry_notify	0	1769974045335	1769974055587	1769974055592	success	100	null
48nqnenyntrzfjgxjorpuuzc7o	expiry_notify	0	1769979325749	1769979337608	1769979337615	success	100	null
ww3573as4tna3p8mwci1pbdtoa	expiry_notify	0	1769976025536	1769976036517	1769976036522	success	100	null
cygm4tht1pn7ikxqc8sgc9bmiw	cleanup_desktop_tokens	0	1769976265542	1769976276590	1769976276593	success	100	null
gghwmzecjfrbmxik3f7jd6uqbo	product_notices	0	1769979325754	1769979337608	1769979337722	success	100	null
f9uyi9pucfnk7jeqbo6quj9iyw	expiry_notify	0	1769976685566	1769976696726	1769976696731	success	100	null
9bm1p46tufdybmiu6pcffufuae	expiry_notify	0	1769977345616	1769977356904	1769977356912	success	100	null
ym7czx1hx38jpfba333cpxomoo	expiry_notify	0	1769978005653	1769978017111	1769978017116	success	100	null
mn5ogibsg7yqmfdgk3kmrakfyr	expiry_notify	0	1769982626031	1769982639134	1769982639141	success	100	null
eyefufq5i7bampbzo4nsitj3zy	expiry_notify	0	1769978665690	1769978677319	1769978677326	success	100	null
s7u9qpxxrty35b9s1dzia8y8tc	cleanup_desktop_tokens	0	1769979925797	1769979937860	1769979937865	success	100	null
6fwa17pzc3ys5j16afhrz6a6zc	expiry_notify	0	1769979985807	1769979997901	1769979997906	success	100	null
wsk3qedzdbf67xm9k5ap4johoh	expiry_notify	0	1769980645854	1769980658197	1769980658203	success	100	null
9csry4n7ojduxnaz98uj8u6fse	expiry_notify	0	1769981305893	1769981318496	1769981318502	success	100	null
i9mgiojiyinr3eeec8wzb1dcra	product_notices	0	1769982926065	1769982939286	1769982939402	success	100	null
6ynraco44frpteepae9wu4fu4c	expiry_notify	0	1769981965947	1769981978796	1769981978800	success	100	null
qgep7yp7ktr5ikscy633nfdu4y	expiry_notify	0	1769984606160	1769984619976	1769984619982	success	100	null
4iedqoputbn9unqs9ho6943jyy	expiry_notify	0	1769983286089	1769983299456	1769983299461	success	100	null
ym8z46sptj8umjrkm7f13j1roa	cleanup_desktop_tokens	0	1769983526122	1769983539553	1769983539558	success	100	null
rqcod6adntdouqxazj8erdisoa	expiry_notify	0	1769983946142	1769983959710	1769983959717	success	100	null
fzrtu76zajndtcqargkd9j78gw	expiry_notify	0	1769985266211	1769985280313	1769985280320	success	100	null
kgs635w1ejnfdjshybef864rdc	expiry_notify	0	1769985926278	1769985940636	1769985940642	success	100	null
ak81gdzujj8jznqiqdkkbntw6r	expiry_notify	0	1769986586385	1769986601010	1769986601015	success	100	null
i3oq7o3pbtbx7f5bemicgyiqoc	product_notices	0	1769986526372	1769986540967	1769986541096	success	100	null
paunu3akmpr9idtziuhowfqzeo	cleanup_desktop_tokens	0	1769987186456	1769987201330	1769987201335	success	100	null
4qnmycjx6tb67pthbz1zyakgmy	expiry_notify	0	1769987246472	1769987261350	1769987261355	success	100	null
5jn5iq1p33dj3x6qf63t96k4xc	expiry_notify	0	1769987906539	1769987906640	1769987906647	success	100	null
ypupyp8o7ff6uex8mkco3nhdor	expiry_notify	0	1769989886670	1769989887533	1769989887540	success	100	null
jqj77kue47yb8n94i1tiyzgw1y	expiry_notify	0	1769988566561	1769988566934	1769988566935	success	100	null
53w9yd6n9pfdtm5dbt8axxe34h	expiry_notify	0	1769989226612	1769989227220	1769989227227	success	100	null
zfcreqz5gp8b9ps6mgz35o85eo	product_notices	0	1769990126695	1769990127676	1769990127807	success	100	null
q6eubo8qnin87g5g5fb1bbo8oy	refresh_materialized_views	0	1769990426755	1769990427832	1769990427856	success	100	null
bcuq5b55cjg6pj918et9hikioe	expiry_notify	0	1769990486762	1769990487854	1769990487859	success	100	null
tpdaws8ixfgommi6wocu98ytdy	cleanup_desktop_tokens	0	1769990846799	1769990848042	1769990848046	success	100	null
rm8pbbi5o3rp8qpm19fp4f8dfc	expiry_notify	0	1769991146833	1769991148213	1769991148220	success	100	null
y4roajdn538fubqcmdrrdf7g4y	expiry_notify	0	1769991806894	1769991808573	1769991808578	success	100	null
uwubbedujibkprtitzdozhbs4h	expiry_notify	0	1770201286470	1770201296712	1770201296717	success	100	null
rfxqck9io3fmdnny7wmp4f68ny	expiry_notify	0	1769993787021	1769993789349	1769993789354	success	100	null
pit7b53gqtn5jnkfp7b6db84pw	expiry_notify	0	1769994447064	1769994449647	1769994449653	success	100	null
oznw6hcn8jyeuchki9oakkgaqy	cleanup_desktop_tokens	0	1769994507072	1769994509677	1769994509683	success	100	null
menx1gm9mbywfj6a8dey6yyt5w	expiry_notify	0	1770000387563	1770000392602	1770000392607	success	100	null
7zuugy1ziproznyyz3x8eizbsc	expiry_notify	0	1769995107032	1769995109929	1769995109935	success	100	null
notcnssjz3gn3y4iu44yebwo4w	expiry_notify	0	1769995767039	1769995770262	1769995770266	success	100	null
e518eq5nabdcxdke3mdhzze6za	expiry_notify	0	1769996427069	1769996430553	1769996430559	success	100	null
5gwzyfy9s3bwzy799z3rzjw9mc	product_notices	0	1770004528028	1770004534629	1770004534734	success	100	null
de6rsus55fg57qg54j31nes7cy	expiry_notify	0	1769997087233	1769997090996	1769997091003	success	100	null
6jkh5g1o5byzdbf1i1hu1qz4gr	product_notices	0	1770000927630	1770000932857	1770000932964	success	100	null
mrh3tkcguj84tjpbrrkjg6dssh	product_notices	0	1769997327266	1769997331105	1769997331213	success	100	null
qf1su4ep5t8s5czymj3f1bhuyr	expiry_notify	0	1769997747317	1769997751303	1769997751309	success	100	null
8sxcrif6b38bmbf4rg3z9khcxa	cleanup_desktop_tokens	0	1769998167366	1769998171513	1769998171518	success	100	null
3emk5i4xg3dt3nt8q6e89abotr	expiry_notify	0	1769998407392	1769998411626	1769998411633	success	100	null
kwoabqsm5br3mmojrw8y6711cy	expiry_notify	0	1770001047669	1770001052930	1770001052936	success	100	null
kwsuk3a7atr8fg4qer5b3mbbjy	expiry_notify	0	1769999067434	1769999071956	1769999071960	success	100	null
3ppxion8i7n6pq951dbzad5e3h	expiry_notify	0	1769999727500	1769999732254	1769999732260	success	100	null
gr3448tuajfb3q1cozw4a44h4h	expiry_notify	0	1770001707746	1770001713271	1770001713277	success	100	null
gsrradxqyiyw5xa9eia16c4c8e	product_notices	0	1770008128355	1770008136325	1770008136413	success	100	null
m1qo4nr1n3nrdx895dh1zmwrqy	cleanup_desktop_tokens	0	1770001827762	1770001833330	1770001833334	success	100	null
6fpaow9h3igpmyfbqfxsmdchpr	expiry_notify	0	1770005008080	1770005014851	1770005014856	success	100	null
sguaoosdo783mps47sn9xt89gh	expiry_notify	0	1770002367819	1770002373590	1770002373596	success	100	null
w6wmk6mqgfn19ct96rxh1npwxo	expiry_notify	0	1770003027905	1770003033927	1770003033933	success	100	null
un9dcrx987g1ieo6ujjttdhi5e	expiry_notify	0	1770003687946	1770003694224	1770003694229	success	100	null
bw3w694m87nrjxa6abhpuw6y1h	expiry_notify	0	1770004348011	1770004354552	1770004354557	success	100	null
p6r97h78fprhzcnpwhdq8kh7uh	cleanup_desktop_tokens	0	1770005488112	1770005495062	1770005495067	success	100	null
iga97r5p9bnrmczw8r65y985ec	expiry_notify	0	1770005668131	1770005675145	1770005675150	success	100	null
iwfdsborttb1pbkg1h1zbnai9y	expiry_notify	0	1770010288445	1770010297306	1770010297314	success	100	null
fknkzxqiq7d93p965iruqqeqkc	expiry_notify	0	1770006328197	1770006335454	1770006335459	success	100	null
k5ewugdxitbu5bmx95ie5s8gnh	expiry_notify	0	1770008308368	1770008316426	1770008316430	success	100	null
obbnimjyobd1fkaabh5wt3txhh	expiry_notify	0	1770006988249	1770006995780	1770006995787	success	100	null
pqyn4sqecbbc9833xwrtphje4c	expiry_notify	0	1770007648305	1770007656070	1770007656074	success	100	null
h4t5syu9nj8tpxy7joiua1tt1w	expiry_notify	0	1770008968448	1770008976768	1770008976775	success	100	null
gnaubbg6gfdybei836yb4f947w	cleanup_desktop_tokens	0	1770009148462	1770009156852	1770009156857	success	100	null
m8xuac9fifro8xyfoeor38n56h	expiry_notify	0	1770009628491	1770009637085	1770009637092	success	100	null
ezcj95ygh3fhxfqswng8yday8r	expiry_notify	0	1770010948487	1770010957626	1770010957633	success	100	null
amdsn9nc1ibjjexbqfcgy9mp4w	expiry_notify	0	1770012268693	1770012278400	1770012278405	success	100	null
rniyzuqigpb7ie3rixxrad6bba	expiry_notify	0	1770011608540	1770011617959	1770011617965	success	100	null
apq93mj3bfnrb87hfaekzp8fyw	product_notices	0	1770011728555	1770011738019	1770011738116	success	100	null
nzhn67fib3r4bfh4o7efbnsjky	cleanup_desktop_tokens	0	1770012808731	1770012818650	1770012818652	success	100	null
uuemeu4jj7dc5fyaih6kkosype	expiry_notify	0	1770012928749	1770012938708	1770012938713	success	100	null
h741m8kpqt81tniws3jseyzjqa	expiry_notify	0	1770013588830	1770013599048	1770013599054	success	100	null
uajzyphhxtyo8qf5du9nzkc88e	product_notices	0	1770015328993	1770015339896	1770015339983	success	100	null
yurzc5sk1jd9uyq9mpjhzfry5h	expiry_notify	0	1770014248915	1770014259394	1770014259399	success	100	null
aa8jf84ksfdm5ntnp3u9tpzobe	expiry_notify	0	1770014908976	1770014919669	1770014919676	success	100	null
44737h6dbjdaxfzgx9zr3shpfc	expiry_notify	0	1770015569019	1770015580007	1770015580009	success	100	null
rmqi5izmtbrntn1pgkhe46i9ky	expiry_notify	0	1770016229105	1770016240355	1770016240359	success	100	null
hu4nka37o3g4fcg3gt31gyr66r	cleanup_desktop_tokens	0	1770016469137	1770016480486	1770016480492	success	100	null
czc94b5bitfpjgxhx7w5gh6pue	expiry_notify	0	1770016889201	1770016900717	1770016900721	success	100	null
ry8ja3fwri8xxejcm3f7dm53ny	expiry_notify	0	1770017549279	1770017561041	1770017561048	success	100	null
o53epzc5qbdyfeobrpg5aukp9y	expiry_notify	0	1770018209290	1770018221302	1770018221309	success	100	null
h8uqzeax7jgi9jsc4busn957me	expiry_notify	0	1770018869372	1770018881596	1770018881600	success	100	null
f9854xnizbr398osuhxrkaz6yh	product_notices	0	1770018929390	1770018941635	1770018941732	success	100	null
jtrn1k9nt3nq5ptdzmgxx57ioa	expiry_notify	0	1770036690902	1770036694585	1770036694590	success	100	null
uyeq4aqppfr8t88d1sdx64hzrc	expiry_notify	0	1770268972384	1770268976756	1770268976762	success	100	null
x3c1xoaqfbrizds7aq3p9mj91w	expiry_notify	0	1770019529447	1770019541926	1770019541931	success	100	null
gairnu5awbd78e9jxyameehcje	product_notices	0	1770036930936	1770036934698	1770036934812	success	100	null
z16uciww5jbjtrbuuftq5w6b6c	cleanup_desktop_tokens	0	1770020069486	1770020082202	1770020082208	success	100	null
jo8meu3ryjybimmdjad5ff5wsc	expiry_notify	0	1770038011016	1770038015239	1770038015243	success	100	null
5sadwa9n1frg8doxzw5qghuhoc	expiry_notify	0	1770020189495	1770020202255	1770020202262	success	100	null
o541j3tnwpyu9cexsb8gwfsjta	expiry_notify	0	1770037350988	1770037354936	1770037354943	success	100	null
yijnqf3sepdpzr8rn1t91dpyco	expiry_notify	0	1770020849574	1770020862624	1770020862631	success	100	null
j763m3sqxff35yp9chdge3poje	expiry_notify	0	1770021509633	1770021522873	1770021522879	success	100	null
bbzum7pmd78fdkc7umozs3wohr	cleanup_desktop_tokens	0	1770038311041	1770038315375	1770038315380	success	100	null
fh893ghd4fbt7xt4nx7p8q3yjh	expiry_notify	0	1770026130010	1770026130132	1770026130139	success	100	null
w61wg79qrfym5b9tircpu4hfke	expiry_notify	0	1770022169714	1770022183202	1770022183208	success	100	null
dshwatrj87bczbwog5ue3rfrhw	expiry_notify	0	1770038671080	1770038675540	1770038675545	success	100	null
tf1fomqukigf9yp93x1idmt8yy	expiry_notify	0	1770030090316	1770030091854	1770030091860	success	100	null
uxks41rp6fdcbfa6ntcjzcsuro	product_notices	0	1770022529744	1770022543408	1770022543493	success	100	null
w3i4ucot77fgzyfayuinz8ydgh	expiry_notify	0	1770039331122	1770039335853	1770039335858	success	100	null
duhdwr6eqpg3meeqpmpt95xgfc	product_notices	0	1770026130014	1770026130132	1770026130215	success	100	null
m39moj6s9bbxb8caerupfjisfy	expiry_notify	0	1770022829771	1770022843559	1770022843562	success	100	null
y6paw4f4f3rcumrx1nx8uu7dty	expiry_notify	0	1770039991212	1770039996187	1770039996194	success	100	null
ou8k1iww3jrxbfhh4on1t1jxmr	expiry_notify	0	1770023489796	1770023503874	1770023503880	success	100	null
173rra86h3ni7gm3ndr5q73poa	product_notices	0	1770040531264	1770040536444	1770040536573	success	100	null
13nzjc8nojfgzpeukhmafoansw	cleanup_desktop_tokens	0	1770023729833	1770023744000	1770023744006	success	100	null
bb5maqr3x3gpmbe6qgyacbf7mw	expiry_notify	0	1770040651281	1770040656500	1770040656504	success	100	null
56gt4q91gfdedjx7k3po6g93sc	expiry_notify	0	1770024149863	1770024164209	1770024164215	success	100	null
ru5smef4t7fqtq9hnnu1u9ymrc	expiry_notify	0	1770026790034	1770026790350	1770026790357	success	100	null
btgakwmgr3ysujpn1j6arqwaho	expiry_notify	0	1770024809913	1770024824548	1770024824554	success	100	null
so4ahfq84ir5ze9hbfhonbzcha	expiry_notify	0	1770041311328	1770041316793	1770041316799	success	100	null
h7aen8c1rpdn7d6qwfbspegx1e	expiry_notify	0	1770025469972	1770025484871	1770025484878	success	100	null
kg5s13x7pb8m78nx3pf8mwhi8y	cleanup_desktop_tokens	0	1770041911373	1770041917089	1770041917095	success	100	null
fdq1tsbbcjr73ebin8ystnyano	cleanup_desktop_tokens	0	1770027390063	1770027390559	1770027390563	success	100	null
da7qrx9k6jgm3kduizk4m9ko3c	expiry_notify	0	1770041971382	1770041977120	1770041977126	success	100	null
5yakk3xekpf3ufj13eu387ognr	expiry_notify	0	1770027450081	1770027450588	1770027450592	success	100	null
nxipxd5dfprzunxmgb3ijm4zac	expiry_notify	0	1770042631440	1770042637423	1770042637430	success	100	null
kwazuwkry3rifxyyh4pdxdpknr	expiry_notify	0	1770030750390	1770030752099	1770030752104	success	100	null
cbctkhjrwbdqxkiwpz4ofdb7yy	expiry_notify	0	1770028110152	1770028110895	1770028110900	success	100	null
fr1k67en8tbn7chiestriapsmc	expiry_notify	0	1770043291477	1770043297725	1770043297730	success	100	null
95dzd3im5f86pjwubfat34fcra	expiry_notify	0	1770028770214	1770028771240	1770028771246	success	100	null
nqyhtbpoxpyk3xxbxk9rn8qtrw	expiry_notify	0	1770029430262	1770029431559	1770029431565	success	100	null
stytrf5ebbnrmq6tg1cs148rco	plugins	0	1770033330541	1770033332926	1770033332931	success	0	null
e9tez5hk7pb9z8xdxzk93jqkae	product_notices	0	1770029730289	1770029731683	1770029731787	success	100	null
1q9t9b8oafdutk74fg1u45aodw	cleanup_desktop_tokens	0	1770031050420	1770031052165	1770031052170	success	100	null
gg1hw5h8dinsmjb1makrk9ftor	install_plugin_notify_admin	0	1770033330529	1770033332926	1770033332933	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
jwq5xtc9ubfp78mgjxudz39abc	expiry_notify	0	1770031410461	1770031412277	1770031412283	success	100	null
4u5zx7hgdjdfzkpp3qw878soxo	expiry_notify	0	1770032070456	1770032072461	1770032072467	success	100	null
68tni65hfbro7k3poduna8k33r	expiry_notify	0	1770032730486	1770032732696	1770032732703	success	100	null
kjstsadegfns8jqcc6k577if7c	export_delete	0	1770033330538	1770033332926	1770033332941	success	100	null
6z3bh7ueibystmykk5thmcfojo	import_delete	0	1770033330534	1770033332926	1770033332941	success	100	null
c1bmiiac738kiy6wncfd8kia6c	mobile_session_metadata	0	1770033330540	1770033332927	1770033332942	success	100	null
8kcrtkprridatmj4fgo4f1pw8e	expiry_notify	0	1770033390546	1770033392959	1770033392966	success	100	null
e6xbgo7ttiyixxcwgazgc58czc	product_notices	0	1770033330537	1770033332927	1770033333015	success	100	null
nk3f74p9mjgptynw5phwqmbqph	expiry_notify	0	1770034050652	1770034053276	1770034053282	success	100	null
ym3cxbfzp3df8bgmerw9ygkb1a	cleanup_desktop_tokens	0	1770034650715	1770034653540	1770034653546	success	100	null
5dsscsncji8edpemar5t46jpsy	expiry_notify	0	1770035370786	1770035373931	1770035373936	success	100	null
jxes7xzy1ffs7fuwkoomruo84h	expiry_notify	0	1770034710728	1770034713576	1770034713582	success	100	null
o6m3ougkfb8k8kewj6jrcb94ce	product_notices	0	1770141340750	1770141342485	1770141342586	success	100	null
o949zjxbc3f8fxn7qa8393moqa	expiry_notify	0	1770087335636	1770087344999	1770087345006	success	100	null
psomzmqpx3fh5qsbcpeuw1o14w	expiry_notify	0	1770043951501	1770043958048	1770043958054	success	100	null
geh9nkyxybbafe6u7koj7rsyue	expiry_notify	0	1770343499029	1770343500291	1770343500296	success	100	null
zgmo74n6g7n5bxymjcugpfzd1e	product_notices	0	1770087335638	1770087344999	1770087345100	success	100	null
u8i4qrexetna8esdqhobg8qopr	expiry_notify	0	1770097234600	1770097248040	1770097248047	success	100	null
1617uodxnpgo8bhsbg9xwydeoy	expiry_notify	0	1770089315855	1770089326057	1770089326062	success	100	null
jq93qq4i97yticmpgbx73988yw	expiry_notify	0	1770143260917	1770143263264	1770143263270	success	100	null
8b74ex19oibjdj9i8q3erqwexo	cleanup_desktop_tokens	0	1770089375864	1770089386099	1770089386104	success	100	null
bif3zcaz7tdnt83wdwmwwzjjgy	expiry_notify	0	1770143920973	1770143923649	1770143923654	success	100	null
msty1jq1otyhxxxw85y1nahq4o	expiry_notify	0	1770090635970	1770090646722	1770090646726	success	100	null
fzpaboesrpgg98qd7jsadb7bmo	expiry_notify	0	1770105817414	1770105819396	1770105819401	success	100	null
kuzfqhn8pjnf78um4xdc4pdfdr	product_notices	0	1770090936002	1770090946885	1770090947009	success	100	null
86qjcwea47b4mju1c4umsra45r	expiry_notify	0	1770097894656	1770097908356	1770097908361	success	100	null
fmidg7fqtinq3d8i9arp3ybkta	expiry_notify	0	1770091296030	1770091307046	1770091307052	success	100	null
cphzwtouupyf5c3fkmunej6uic	expiry_notify	0	1770092616124	1770092627712	1770092627718	success	100	null
37wh7nt1efro9j8ccefkrrnqge	expiry_notify	0	1770093936243	1770093948309	1770093948316	success	100	null
gwkuyi1tbir6bpk3a8rme6swnw	product_notices	0	1770094536301	1770094548616	1770094548732	success	100	null
qu9suon6x3yfpgyqxw1n7mje5o	cleanup_desktop_tokens	0	1770100356884	1770100371577	1770100371583	success	100	null
zcj7bi3fnfdq9f8extpyckn94c	expiry_notify	0	1770094596307	1770094608639	1770094608645	success	100	null
sswq89oi3irrmpc9k3tqy5bujc	expiry_notify	0	1770095916438	1770095929334	1770095929338	success	100	null
94pbjxz3g3fo5kaqrisk8pcz9a	cleanup_desktop_tokens	0	1770096696528	1770096709771	1770096709777	success	100	null
3xi38f6igig7dfskca43ku8p7a	expiry_notify	0	1770101196979	1770101197088	1770101197095	success	100	null
gqhsttz533ftzbgm3adk88rpta	expiry_notify	0	1770106477439	1770106479727	1770106479734	success	100	null
edjp5gucxtboxydg5ota6e78mr	expiry_notify	0	1770103177164	1770103178100	1770103178106	success	100	null
dq3znbnqbbnbpkz9ptufkzqrzo	expiry_notify	0	1770103837227	1770103838412	1770103838416	success	100	null
twsg1uh5utfhmfihkymm6nbbuh	cleanup_desktop_tokens	0	1770104017257	1770104018496	1770104018500	success	100	null
4cdt145nn3gqpy4ezs9w1m4g4r	expiry_notify	0	1770109777742	1770109781367	1770109781373	success	100	null
n8zdegkcnibdtc1i1owoebj4co	expiry_notify	0	1770104497279	1770104498738	1770104498743	success	100	null
bkizf5kowtdexkmn4ypygb4xuc	expiry_notify	0	1770107137504	1770107140036	1770107140040	success	100	null
cjf94rmkyjyqfdmxqsaurm5zea	product_notices	0	1770105337370	1770105339140	1770105339239	success	100	null
a7jhdcmtaigmukg8oyc4o5yhzr	expiry_notify	0	1770107797536	1770107800347	1770107800352	success	100	null
8j6gejc85jf3fbit5pmmjxk5do	expiry_notify	0	1770108457608	1770108460701	1770108460706	success	100	null
acrpwqasxbdemrpsuzpti7ppjr	expiry_notify	0	1770110437818	1770110441764	1770110441771	success	100	null
zx4xpgkhkpdytgc6ku58t41umy	product_notices	0	1770108937658	1770108940930	1770108941040	success	100	null
swnfb6uggtrrxf396n45n8tohh	expiry_notify	0	1770109117693	1770109121024	1770109121028	success	100	null
c1gjwdo6q3dj7fj3ifi1dyug5w	product_notices	0	1770112538004	1770112542748	1770112542859	success	100	null
wh67c9rsmi8jpgzjegh7ezcj9r	expiry_notify	0	1770111097885	1770111102074	1770111102079	success	100	null
qkck5k9w4frptn4qqbci64w8qh	cleanup_desktop_tokens	0	1770111337910	1770111342151	1770111342155	success	100	null
a14qyzjuribhuf6dko9jk56qza	expiry_notify	0	1770112417991	1770112422707	1770112422711	success	100	null
39jh1u9ygpnyd8qxaybjfcs93h	expiry_notify	0	1770113078060	1770113083008	1770113083013	success	100	null
unwbzgr5e3n9tpwiooyrx1kjno	expiry_notify	0	1770115718303	1770115724422	1770115724428	success	100	null
nffzi7i1b3gmjq8d31gzgh44co	expiry_notify	0	1770113738120	1770113743351	1770113743356	success	100	null
5dha416mipfbmkf96uc9scmhsy	cleanup_desktop_tokens	0	1770114998224	1770115004031	1770115004037	success	100	null
ijsqnzx473yemkt5cbwhf1uijy	expiry_notify	0	1770114398169	1770114403709	1770114403713	success	100	null
ottdcfdunfbdtcfpfqaq7o749e	expiry_notify	0	1770115058240	1770115064057	1770115064063	success	100	null
45skg8ko7ibxunkqd956ehsbyh	expiry_notify	0	1770116378387	1770116384727	1770116384731	success	100	null
r9hqfjmrg3gw8x55jtjwoa7qcy	product_notices	0	1770116138372	1770116144607	1770116144687	success	100	null
ih9wt5rp6fyquy56ubka36tq5e	expiry_notify	0	1770117038438	1770117045090	1770117045092	success	100	null
ymdmr5jz4fymijsq4k5zczat3r	expiry_notify	0	1770117698492	1770117705418	1770117705420	success	100	null
usyifxwtrbymmk1m35j63k5rfy	expiry_notify	0	1770118358540	1770118365690	1770118365695	success	100	null
qubu6xgoc3nipxf3f4g46ue11e	cleanup_desktop_tokens	0	1770118658583	1770118665865	1770118665870	success	100	null
64unybffnf8ij8fr7twj7q4uyc	expiry_notify	0	1770119018622	1770119026053	1770119026060	success	100	null
tdieaezs9td97cyu9uweukpehr	expiry_notify	0	1770119678697	1770119686412	1770119686420	success	100	null
9irb5n4ttin6udon68im4xt76r	plugins	0	1770119738723	1770119746446	1770119746462	success	0	null
auxafz8jpf8rpdma5m6w1twnta	product_notices	0	1770425766359	1770425767736	1770425767848	success	100	null
h4xycetjdpdbxrxcczcxitrpdy	product_notices	0	1770044131518	1770044138146	1770044138237	success	100	null
6chnjf61k7dnbp8oa4qd5eptbr	expiry_notify	0	1770044611588	1770044618436	1770044618440	success	100	null
q59bdpit1igt5m57kfgn5ncwge	expiry_notify	0	1770045271634	1770045278726	1770045278732	success	100	null
zyjeaoowbfrcunxypgxwiwxc1o	expiry_notify	0	1770050492091	1770050501138	1770050501144	success	100	null
zdqs9e1ro78yxpadxk7nixaxuo	cleanup_desktop_tokens	0	1770045571671	1770045578865	1770045578871	success	100	null
fi5ox5y5gjnwpc4s5m557iyhqe	expiry_notify	0	1770045931716	1770045939055	1770045939059	success	100	null
wefxaowwybnkbki9o6n39edxqo	expiry_notify	0	1770046591772	1770046599375	1770046599379	success	100	null
kczbzf64o38emr3p3ebxpq4mgw	product_notices	0	1770054932507	1770054943340	1770054943460	success	100	null
a3rpq9dj8bbjbnjfaeg7mo5oqa	expiry_notify	0	1770047251808	1770047259701	1770047259707	success	100	null
atsxood517fejgnmyhnwehqk3y	expiry_notify	0	1770051152142	1770051161436	1770051161440	success	100	null
ce31i3mxkfdbmxooqjq1d5jr9e	product_notices	0	1770047731835	1770047739876	1770047739972	success	100	null
fkk5sksoebfemdswuk3nz7unko	expiry_notify	0	1770047911853	1770047919957	1770047919962	success	100	null
7si786ba3bbipy94nc3t9urhar	expiry_notify	0	1770048571906	1770048580248	1770048580250	success	100	null
fmiufc136fyhzf6rk7f9f6hb8o	product_notices	0	1770051332156	1770051341500	1770051341599	success	100	null
p3subabd77nttftd991xg3ro3e	cleanup_desktop_tokens	0	1770049171984	1770049180567	1770049180571	success	100	null
46xfa7t4wbggfyyfgdn64whtbe	expiry_notify	0	1770049171989	1770049180567	1770049180571	success	100	null
h96cq1b3rpyhim35uqd8wrgoeo	expiry_notify	0	1770049832037	1770049840891	1770049840894	success	100	null
ugibejy8mfgq7p8dtf3zn6ja8e	expiry_notify	0	1770051812197	1770051821682	1770051821686	success	100	null
x8yzdzeccin158gqox1yzmx6ar	expiry_notify	0	1770058412840	1770058425216	1770058425221	success	100	null
5zqs1ddi7tnabyow3ta3tn5i3e	expiry_notify	0	1770052472256	1770052482027	1770052482034	success	100	null
31xma8pqq7f5tdhcofkr5z7usy	expiry_notify	0	1770055112522	1770055123444	1770055123450	success	100	null
yadujgbbq7btxdfysxcz7s94ro	cleanup_desktop_tokens	0	1770052832293	1770052842215	1770052842219	success	100	null
xeqmf5rm3ibf5mwn43ftwb17nc	expiry_notify	0	1770053132331	1770053142385	1770053142392	success	100	null
8s8tnnnygjrrdy15xafphafi4h	expiry_notify	0	1770053792385	1770053802731	1770053802737	success	100	null
y4u5jpn9k3fq8rn59itqqhitte	expiry_notify	0	1770054452476	1770054463088	1770054463095	success	100	null
ms13rj7ukidrumyxmyafrbc1ko	expiry_notify	0	1770055772567	1770055783795	1770055783803	success	100	null
kb3qyr4tx78sxemkncpkxgjeee	expiry_notify	0	1770056432632	1770056444139	1770056444143	success	100	null
dnd8ioewupf9ufjy4s71hrjqey	expiry_notify	0	1770060333049	1770060346236	1770060346241	success	100	null
tn668bx47pbutbcqx3kymdai5r	cleanup_desktop_tokens	0	1770056492648	1770056504186	1770056504192	success	100	null
t66ntwnrx3dqpp4bz8ebydjwma	product_notices	0	1770058532866	1770058545271	1770058545396	success	100	null
xpniuxccqpbmx8ajrdb4fms68h	expiry_notify	0	1770057092696	1770057104537	1770057104544	success	100	null
tf8p37kw17bejedjarm3f1t95a	expiry_notify	0	1770057752768	1770057764890	1770057764895	success	100	null
9eht88135tr6fr817y4yghr67o	expiry_notify	0	1770059072929	1770059085545	1770059085551	success	100	null
96qahfypntbrixg8ge6nz37bhh	expiry_notify	0	1770059672972	1770059685871	1770059685875	success	100	null
ukcg8tyws3yfdk965j1343axth	cleanup_desktop_tokens	0	1770060153036	1770060166125	1770060166131	success	100	null
itot3km14pbt5nn3yxhbsyd8jr	expiry_notify	0	1770060993120	1770061006608	1770061006615	success	100	null
zbbddw448t8n7c3s6r9jonjg8h	expiry_notify	0	1770062313249	1770062327269	1770062327275	success	100	null
u947poa87jywtbcch7rxb917sw	expiry_notify	0	1770061653167	1770061666975	1770061666982	success	100	null
hrmo993ts7dz7xqz1c7kpdpbya	product_notices	0	1770062133216	1770062147184	1770062147292	success	100	null
j95hnn4bxfr6tk877m8iz5mnoy	expiry_notify	0	1770062973325	1770062987603	1770062987609	success	100	null
aykyhu8abfb3xe66355yafggho	expiry_notify	0	1770063633411	1770063647942	1770063647947	success	100	null
6wak3jbuofd6pfutakmrabefzc	cleanup_desktop_tokens	0	1770063813433	1770063828018	1770063828021	success	100	null
14194rdyfjgupypihbhtzbj73y	expiry_notify	0	1770065613586	1770065614020	1770065614025	success	100	null
c77pgw57ejy4ixzz6ocaosnn1a	expiry_notify	0	1770064293481	1770064308290	1770064308295	success	100	null
xka8o3yaopbszym4ghb3poo9bo	expiry_notify	0	1770064953537	1770064953654	1770064953659	success	100	null
iawf7pey93yk7j7ufuziwe6qxy	product_notices	0	1770065733595	1770065734072	1770065734171	success	100	null
o5m35qhdb7fajemixcbzdtmeye	expiry_notify	0	1770066273642	1770066274356	1770066274360	success	100	null
ijmt4n469pbzteqxxgr8hftzya	expiry_notify	0	1770066933683	1770066934698	1770066934703	success	100	null
runoq371c7yjbgj4oy1ieuhbye	cleanup_desktop_tokens	0	1770067473742	1770067474975	1770067474981	success	100	null
ibtrysf5ofrz8chxn3wibk77bo	expiry_notify	0	1770067593762	1770067595030	1770067595036	success	100	null
sjesi3dprtyxprjgknxz5dr7kc	expiry_notify	0	1770068253834	1770068255420	1770068255425	success	100	null
jtm7hoksupf7mmxigpfra1o9ba	expiry_notify	0	1770068913899	1770068915833	1770068915839	success	100	null
fpqp9dt6z3y49e1j8ea383kq8e	product_notices	0	1770069333939	1770069336051	1770069336154	success	100	null
owdsxrr57f8aubn8qdkbp8idia	expiry_notify	0	1770201946558	1770201957024	1770201957031	success	100	null
9t69iaqyeirr7q9fo19wa6qgic	expiry_notify	0	1770091956078	1770091967397	1770091967403	success	100	null
kteqg5qdcidzzbas9h5cuqbpky	expiry_notify	0	1770069513957	1770069516148	1770069516153	success	100	null
wexye3agafypbyfgdwoexcm5sr	expiry_notify	0	1770087995734	1770088005377	1770088005385	success	100	null
6wtzcb9xp7ftuyb45yecga6unw	expiry_notify	0	1770070174018	1770070176514	1770070176518	success	100	null
4e8zsjpgw3fe78jj9onwa1rwjy	expiry_notify	0	1770088655791	1770088665716	1770088665721	success	100	null
xb4gbbdpb7d5ipgifdqgzsp1dh	expiry_notify	0	1770070834119	1770070836905	1770070836909	success	100	null
zssdnm9my3889q54hattetrwhy	expiry_notify	0	1770076114622	1770076119479	1770076119484	success	100	null
7944j7m8tbny8ewmieuu41oxuw	cleanup_desktop_tokens	0	1770071134157	1770071137070	1770071137077	success	100	null
uodhdwbssig55yszeh6bx7wz5o	expiry_notify	0	1770089975914	1770089986391	1770089986397	success	100	null
6fikubhnbjb99pcrbp4i59xbdh	expiry_notify	0	1770071494203	1770071497271	1770071497276	success	100	null
1o4a9bzkxtb57eii47xwoe4eme	cleanup_desktop_tokens	0	1770093036172	1770093047923	1770093047929	success	100	null
y7d16nxoaf8f8x4aegomp7bc3c	expiry_notify	0	1770072154256	1770072157591	1770072157597	success	100	null
mh67qqcc3pd89khicuhfst88rc	expiry_notify	0	1770080075006	1770080081531	1770080081533	success	100	null
etrtozg5f38wujcaf9pw41xu6c	expiry_notify	0	1770072814276	1770072817815	1770072817822	success	100	null
hc5ukf6cpiykjeq5maqe1yg6ga	expiry_notify	0	1770095256362	1770095268995	1770095269002	success	100	null
bycid7pi33rsbc779z5ej8b4ya	expiry_notify	0	1770093276190	1770093288028	1770093288034	success	100	null
ruedx9mfhiddz85p99pkeh576h	product_notices	0	1770076534664	1770076539698	1770076539794	success	100	null
xc5ucgxfm7ra9bgz6eesf7eeiw	product_notices	0	1770072934282	1770072937872	1770072937984	success	100	null
s38upn7fjj8ypmoerc17nh9s1c	expiry_notify	0	1770073474328	1770073478127	1770073478133	success	100	null
str7ksbhm3n59j9pe1bcf3jyko	expiry_notify	0	1770098554725	1770098568697	1770098568702	success	100	null
jpsfnggebpg4zjticfassq6hfy	expiry_notify	0	1770096576515	1770096589694	1770096589698	success	100	null
k6zu74zg3frqtpork8p1n4ic3e	expiry_notify	0	1770074134399	1770074138449	1770074138455	success	100	null
1d5kg9smot8aup755y1uqz97qh	product_notices	0	1770098134690	1770098148475	1770098148597	success	100	null
1rq4a4i7oty5fxbt1pdj7om4jc	cleanup_desktop_tokens	0	1770074794461	1770074798773	1770074798778	success	100	null
qssymkyn3pfiuyp6ydzkexp83o	expiry_notify	0	1770076774690	1770076779818	1770076779824	success	100	null
s7q9iqu55t8cmnz9h9inp5f8hy	expiry_notify	0	1770074794468	1770074798773	1770074798779	success	100	null
3cfyfz4tgjd19ggqmjxxb3cq3c	expiry_notify	0	1770099216781	1770099231028	1770099231032	success	100	null
nbjue8zib7go9rrywn4do94ozo	expiry_notify	0	1770075454540	1770075459100	1770075459105	success	100	null
dfbs63cg6iyjjd4h6e3pxir7er	expiry_notify	0	1770099876836	1770099891324	1770099891328	success	100	null
uqfsw47ip38mmehpqntrgeo6uh	refresh_materialized_views	0	1770076834699	1770076839864	1770076839886	success	100	null
oyw8tati4igkxbprsh356nbgsr	expiry_notify	0	1770100536908	1770100551678	1770100551685	success	100	null
yafcbds4fbnp8ynbwrcde4qcmh	expiry_notify	0	1770077434738	1770077440204	1770077440212	success	100	null
k8sm47znrpfndpo3m9jxe3t8qc	product_notices	0	1770080135021	1770080141553	1770080141642	success	100	null
dhxxwda6wjgx9pssysuckt5mgo	expiry_notify	0	1770078094823	1770078100575	1770078100581	success	100	null
cxciew3oo3gfmn6tsfpcwjosta	product_notices	0	1770101737028	1770101737374	1770101737482	success	100	null
chd86y7sbfb8zmp19gwafnsnfr	cleanup_desktop_tokens	0	1770078454846	1770078460785	1770078460792	success	100	null
x6a1ndjddidzzczjp4rcdrrh6y	expiry_notify	0	1770101857043	1770101857450	1770101857452	success	100	null
bpm9gbkhzfbgfm847f6zmfi66c	expiry_notify	0	1770078754877	1770078760956	1770078760960	success	100	null
boxuqz8xepyf9dkpqp3spd8fda	expiry_notify	0	1770102517109	1770102517775	1770102517780	success	100	null
6cjzqyedffnqjjh1u5pjgu66ah	expiry_notify	0	1770083375272	1770083382977	1770083382983	success	100	null
azr946frrinm7edbruk5wzpuar	expiry_notify	0	1770079414950	1770079421229	1770079421231	success	100	null
7opcwjroifr1jkf8smuqf3raur	expiry_notify	0	1770105157354	1770105159060	1770105159067	success	100	null
nrosoagc8trh98z9114fbgc5po	expiry_notify	0	1770080735084	1770080741765	1770080741767	success	100	null
nmzjetrkdjgd5ch89oruep1cka	cleanup_desktop_tokens	0	1770107677527	1770107680281	1770107680287	success	100	null
c9rpqep1et81tx4s56z4d6bjio	expiry_notify	0	1770081395105	1770081402006	1770081402011	success	100	null
5x837dhqm3nwue3grim7dp3jny	expiry_notify	0	1770111757938	1770111762363	1770111762367	success	100	null
z7sn7q7arjb4tysnamegdwp3nr	expiry_notify	0	1770082055169	1770082062338	1770082062344	success	100	null
zz6h91k4tfyxmgqyezt9xhx11y	cleanup_desktop_tokens	0	1770082115181	1770082122374	1770082122380	success	100	null
cb1gy3trkf8kzm44dts6i5he4o	product_notices	0	1770083735301	1770083743165	1770083743269	success	100	null
jnbxhkai4ifdpkexmq5nq4s57c	expiry_notify	0	1770082715233	1770082722649	1770082722655	success	100	null
36ybtircntbx9xbbzw5hsd9isw	cleanup_desktop_tokens	0	1770085715473	1770085724140	1770085724144	success	100	null
gp5f8z7gq3b9my5ywj3mbnhdno	expiry_notify	0	1770084035329	1770084043309	1770084043316	success	100	null
313jg6prctg5zbbae8gddwch8r	expiry_notify	0	1770084695395	1770084703634	1770084703639	success	100	null
ofya9hhezb8gdyimjpopfzz38c	expiry_notify	0	1770085355445	1770085363950	1770085363955	success	100	null
e17zrh1awtd69geop1ua4psuqe	expiry_notify	0	1770086015499	1770086024304	1770086024309	success	100	null
59bcaa5j6pf6urtbqujxbzqwgh	expiry_notify	0	1770511453857	1770511456236	1770511456243	success	100	null
wfyb3k3c4byztnixai613odr1h	expiry_notify	0	1770141940811	1770141942671	1770141942673	success	100	null
8rhgjzj7h3g7pf1axue3i84nth	import_delete	0	1770119738726	1770119746445	1770119746457	success	100	null
8jijts191jnspchwpoqu91yx3o	expiry_notify	0	1770151841751	1770151847626	1770151847632	success	100	null
d8duzbds43ycdy8hhea3th99nw	cleanup_desktop_tokens	0	1770144221000	1770144223799	1770144223804	success	100	null
xfd1apsbfjbzxxzukbiio7yzer	expiry_notify	0	1770144581037	1770144583966	1770144583968	success	100	null
n9g7oaurht8b3ftfy8jxozr1aw	expiry_notify	0	1770145241095	1770145244298	1770145244305	success	100	null
8ztskszhu3djmc9tmm5f1ayjbh	expiry_notify	0	1770155802098	1770155809616	1770155809622	success	100	null
4f76maw5w3fydyuf8ewdrx41qe	expiry_notify	0	1770145901179	1770145904604	1770145904609	success	100	null
4izst5thffgh7xca9peezwqbze	product_notices	0	1770152141793	1770152147801	1770152147908	success	100	null
xpof4c54dfgs5fth3zhm5usteh	expiry_notify	0	1770146561236	1770146564927	1770146564934	success	100	null
sgydygcjffbc3bn9s6uwktueqo	expiry_notify	0	1770148541420	1770148545925	1770148545933	success	100	null
x63hxs75fbgsp8zupdunc91u7h	product_notices	0	1770148541427	1770148545925	1770148546027	success	100	null
a8jux8e7h7nhdk58h9kq39krua	expiry_notify	0	1770149201476	1770149206258	1770149206265	success	100	null
747b8h5597gtmjwotw48tpzrbe	expiry_notify	0	1770152501818	1770152507964	1770152507971	success	100	null
koh989atjjrbuen5gg9dmaf3oo	expiry_notify	0	1770149861550	1770149866610	1770149866616	success	100	null
oyot9u3mxjfszr1ey7g9g4e5ie	expiry_notify	0	1770150521623	1770150526963	1770150526972	success	100	null
qk5kzumn5jfm9mwftru9somcwo	expiry_notify	0	1770151181680	1770151187304	1770151187310	success	100	null
69o1ox9jxtd9tfanmw8xxq4ncc	cleanup_desktop_tokens	0	1770151541728	1770151547472	1770151547477	success	100	null
6wt3w91hatf8d87cpysoihcycw	expiry_notify	0	1770153161864	1770153168289	1770153168291	success	100	null
qmireabiy38nzcrs7qcrk5oj6h	expiry_notify	0	1770156462180	1770156469985	1770156469993	success	100	null
zd13x185fjbbtpccxk7zkbtbmy	expiry_notify	0	1770153821901	1770153828604	1770153828611	success	100	null
jo59zei36ffhxmf97s8a9xdmhe	expiry_notify	0	1770154481946	1770154488950	1770154488956	success	100	null
x9hqcympst8s7kxd4g1w8i7wge	expiry_notify	0	1770155142003	1770155149306	1770155149311	success	100	null
ditfshga5bycxyhehtbc541wza	product_notices	0	1770159342476	1770159351464	1770159351580	success	100	null
xtjg91jyp7f3t881fqwnaikz7e	cleanup_desktop_tokens	0	1770155202017	1770155209333	1770155209341	success	100	null
nn5rmc7az3gkdmp15ohmqaqtaw	expiry_notify	0	1770157122252	1770157130316	1770157130320	success	100	null
9w4gdb1aztfmuy4g1uutsrticr	product_notices	0	1770155742079	1770155749593	1770155749702	success	100	null
g14hc94yxpyf9cn1mic83gx31a	expiry_notify	0	1770157782322	1770157790681	1770157790688	success	100	null
su65szeo6fdffyghi8hmcdg8pc	expiry_notify	0	1770162402809	1770162413083	1770162413088	success	100	null
zr6w6s66zpgwifeqp4ibs141yw	expiry_notify	0	1770158442391	1770158451004	1770158451009	success	100	null
h5kkyddgoj85te5ahcz5yz8unc	expiry_notify	0	1770159762520	1770159771679	1770159771690	success	100	null
djw3zjduifgif8rp1otpck69gr	cleanup_desktop_tokens	0	1770158862422	1770158871233	1770158871239	success	100	null
9rcpeir9djy6uyhojejmi4amph	expiry_notify	0	1770159102451	1770159111348	1770159111351	success	100	null
bk6sdrkecj8nufzwhmq8kc7x1w	expiry_notify	0	1770160422604	1770160432054	1770160432057	success	100	null
6bys9tegzp8cigkrfamsje7tgy	expiry_notify	0	1770161082672	1770161092397	1770161092406	success	100	null
sstk4g19etnzpg4ts3k353jaby	expiry_notify	0	1770161742746	1770161752754	1770161752761	success	100	null
78xu3rix4id5zkz38sdnsc1n3e	cleanup_desktop_tokens	0	1770162522833	1770162533144	1770162533149	success	100	null
hzintjxhptrfmmxrx6b9ue8r7h	expiry_notify	0	1770164383007	1770164394124	1770164394129	success	100	null
tgkgr8ehfifcbmsh6unzqgno1o	product_notices	0	1770162942862	1770162953354	1770162953501	success	100	null
kdq1cxn6pinopychboqrazrcec	refresh_materialized_views	0	1770163242919	1770163253519	1770163253542	success	100	null
3gurkw3xb3g8ij7dmeyrfkmcya	expiry_notify	0	1770163062898	1770163073421	1770163073426	success	100	null
tfkzngkod7r73fbr75jy8cmdth	expiry_notify	0	1770163722956	1770163733790	1770163733797	success	100	null
wcinifbh8jbsbkgm9bwnoefihy	expiry_notify	0	1770165703120	1770165714776	1770165714782	success	100	null
jtjgnixx8irdjjhed1mcaray5y	expiry_notify	0	1770165043070	1770165054475	1770165054484	success	100	null
khc38b5zj3nk58bbqwdjecte9c	cleanup_desktop_tokens	0	1770166183157	1770166194997	1770166195001	success	100	null
xoxydr5febdxzqweq7mjq464oc	expiry_notify	0	1770166363182	1770166375101	1770166375106	success	100	null
nw4aof8hmfg35k49qysok8ge1e	product_notices	0	1770166543208	1770166555191	1770166555306	success	100	null
yteqfs5mqib5fpuriuri6txy9e	expiry_notify	0	1770167023253	1770167035430	1770167035437	success	100	null
jt6xtg4k7fb5bqsk8qadidxuxe	expiry_notify	0	1770167683323	1770167695757	1770167695765	success	100	null
yrg99tai77f3t83s8skoezcfrc	expiry_notify	0	1770168343385	1770168356056	1770168356059	success	100	null
cazmjrjnti84bndi5436sdgsty	expiry_notify	0	1770169003428	1770169016355	1770169016360	success	100	null
o9ad3rijx7bmtmhtwj84jjgk9h	expiry_notify	0	1770169663518	1770169676640	1770169676645	success	100	null
fjq7wet8kbygxnnuh83a1uw8we	cleanup_desktop_tokens	0	1770169783535	1770169796679	1770169796683	success	100	null
tqn9jxqxcfrrfgizpj3a6rae9a	expiry_notify	0	1770269632439	1770269637011	1770269637017	success	100	null
jitnxrj14bgkpcmmxi19ej5ruc	product_notices	0	1770202546610	1770202557302	1770202557414	success	100	null
3xoaskfa5jgt7ksbjhhgid559o	expiry_notify	0	1770142600864	1770142602922	1770142602926	success	100	null
mwmwyjsrg7dr587zp3efmcm7aw	mobile_session_metadata	0	1770119738721	1770119746446	1770119746465	success	100	null
mcbiqdcyyiyfiduibojuu7breo	export_delete	0	1770119738719	1770119746446	1770119746465	success	100	null
oai1cfoqaibbmp5pruqjssmnba	install_plugin_notify_admin	0	1770119738724	1770119746446	1770119746468	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
soxyrbpm9jbjpkd4fubug3gfge	product_notices	0	1770119738714	1770119746446	1770119746545	success	100	null
1t4uw99zg7netcdi1oaeyfycsh	product_notices	0	1770144941074	1770144944154	1770144944258	success	100	null
och5niwpcfntbkibken433pzkh	expiry_notify	0	1770125619251	1770125629556	1770125629560	success	100	null
67bmgrphmt81zx1h1webfshbpo	expiry_notify	0	1770120338780	1770120346817	1770120346823	success	100	null
3jt6wwhpw7dx3eugutft7b14gc	expiry_notify	0	1770147221299	1770147225252	1770147225258	success	100	null
mdkkj61bybnh9dqgdbebpzwocc	expiry_notify	0	1770120998822	1770121007093	1770121007098	success	100	null
8qos5uxn1tr3xe4bdrxat7bfza	expiry_notify	0	1770121658887	1770121667452	1770121667457	success	100	null
7ihp1xsm3jg7de11ky7ap5gqya	expiry_notify	0	1770147881369	1770147885549	1770147885553	success	100	null
1sar3ojz1fyc5cx1567bjyw93e	cleanup_desktop_tokens	0	1770147881366	1770147885549	1770147885553	success	100	null
hmnnyxq3ofd7ddtcsij81moczw	cleanup_desktop_tokens	0	1770122258929	1770122267750	1770122267755	success	100	null
m6znr8wicidubn9nnhrq8iarka	cleanup_desktop_tokens	0	1770125919277	1770125929821	1770125929827	success	100	null
jcfuo4tmotfs5p3iicaumj8c6a	expiry_notify	0	1770122318942	1770122327790	1770122327798	success	100	null
73ffrsqucfgstf856guziorewc	expiry_notify	0	1770122978992	1770122988144	1770122988149	success	100	null
xpes9em9atbam8jcz61uggih8e	product_notices	0	1770123339022	1770123348321	1770123348419	success	100	null
z3p3msekwif3zc4d7jf1usk3jc	expiry_notify	0	1770132759962	1770132773190	1770132773195	success	100	null
dbha1fbdbbyut83tthzkg8udpw	expiry_notify	0	1770123639056	1770123648473	1770123648478	success	100	null
yuu374um5iyzm864t94eouhesr	expiry_notify	0	1770126219325	1770126229991	1770126229999	success	100	null
6thdw1yqb7ntimw4e8636duair	expiry_notify	0	1770124299111	1770124308844	1770124308850	success	100	null
s6r3og3fsjbdbqbznk9mb4itga	expiry_notify	0	1770124959168	1770124969227	1770124969232	success	100	null
f6tnzdmz7prafk3fbmh13n6irc	cleanup_desktop_tokens	0	1770129579662	1770129591576	1770129591579	success	100	null
duumhms64tgndf5eb4o8bh5qke	expiry_notify	0	1770126879398	1770126890325	1770126890331	success	100	null
ps4prg684fftd8ep831q5fr9ow	product_notices	0	1770126939412	1770126950351	1770126950463	success	100	null
xdcgjzbykfrrxcoh8xuwxtnurh	expiry_notify	0	1770127539469	1770127550643	1770127550646	success	100	null
8imoy7pgwtdj9dftkae5gp1swh	expiry_notify	0	1770128199523	1770128210992	1770128210998	success	100	null
7aczowxk4ig9tndpmzczgfaedw	expiry_notify	0	1770130179690	1770130191836	1770130191840	success	100	null
ywp865rrctfdbmdckgee56zybh	expiry_notify	0	1770128859590	1770128871306	1770128871311	success	100	null
jqrj8cx5xfd6mpsictkkbx7aso	expiry_notify	0	1770129519651	1770129531555	1770129531558	success	100	null
fbokme9pjpbzbytbxnhwgmxjky	product_notices	0	1770130539719	1770130552007	1770130552096	success	100	null
pby3otkwntnzdrscxunthk7mho	expiry_notify	0	1770134740134	1770134754150	1770134754155	success	100	null
u3xoggkgf3b6fycp5d7x1hem5r	expiry_notify	0	1770130839745	1770130852159	1770130852165	success	100	null
ftdgd9h6zfne9bnpjy55emyq4w	cleanup_desktop_tokens	0	1770133240010	1770133253425	1770133253430	success	100	null
mhn7e3s58tfp7kdg4hz3hqxk6y	expiry_notify	0	1770131499801	1770131512521	1770131512527	success	100	null
86n4zisfmbfu3rj8hzs5c6znsy	expiry_notify	0	1770132099919	1770132112914	1770132112921	success	100	null
ourhs4onz3r3zmnx3jakmbm45r	expiry_notify	0	1770133420033	1770133433492	1770133433498	success	100	null
fwgcdekuhbdmtm8bno3ciegbch	expiry_notify	0	1770134080096	1770134093858	1770134093864	success	100	null
6q7xtm9bybrpjdzppi17yyo9uc	expiry_notify	0	1770135400196	1770135414515	1770135414521	success	100	null
97aq5zaa4bghjqh6d5pnsqkugw	product_notices	0	1770134140108	1770134153891	1770134153997	success	100	null
6ut5wpyj97n3def8zxdaykua3y	cleanup_desktop_tokens	0	1770136900308	1770136915274	1770136915280	success	100	null
e5xmu1do77nhfgip55iszezsrr	expiry_notify	0	1770136000257	1770136014896	1770136014902	success	100	null
jr31ohb753ryzxsmigbbeu5uia	expiry_notify	0	1770136660290	1770136675169	1770136675176	success	100	null
11i9rfqjo3br5nbzdtk417jc4r	expiry_notify	0	1770137320335	1770137320467	1770137320470	success	100	null
k439pskqobyqtdw1mt31d7hxsh	expiry_notify	0	1770137980390	1770137980777	1770137980780	success	100	null
kobzba3zt7nhdndtrmf7pk4g6o	product_notices	0	1770137740374	1770137740676	1770137740792	success	100	null
ef91qx1g4irjpc833jemgnsxco	expiry_notify	0	1770139960596	1770139961821	1770139961825	success	100	null
pd3q6r9p5tyjtp967fxc74itor	expiry_notify	0	1770138640449	1770138641109	1770138641116	success	100	null
xmzanqhrb3ddznb1fwecfk1i6h	expiry_notify	0	1770139300525	1770139301449	1770139301454	success	100	null
87u5nxinriby9gbwyrkjf7wzoo	cleanup_desktop_tokens	0	1770140560665	1770140562117	1770140562124	success	100	null
hkbfw9h1dtdfmrdti9nyhe9sse	expiry_notify	0	1770140620681	1770140622170	1770140622177	success	100	null
ywskmserxffb5e1meejh5skyby	expiry_notify	0	1770344159086	1770344160619	1770344160624	success	100	null
9je4fjehd3yxt8uirihhqiy5iw	product_notices	0	1770170143565	1770170156862	1770170157030	success	100	null
8src6r7iyjf5iqe74uin4osszh	expiry_notify	0	1770170323590	1770170336942	1770170336946	success	100	null
bctjae1jeb819fzthiuzwdwfsr	expiry_notify	0	1770188145311	1770188150627	1770188150633	success	100	null
rogmmuu4s7fxmqnz7gg3ox4h5o	expiry_notify	0	1770170983645	1770170997273	1770170997278	success	100	null
nh5uzdaas7r8dpofhd9g78a98e	expiry_notify	0	1770176924229	1770176925028	1770176925032	success	100	null
47draianr78i5nemxitnge8yey	expiry_notify	0	1770171643706	1770171657605	1770171657614	success	100	null
na6objsr1fbspd9wstg1dbmjoe	expiry_notify	0	1770172303788	1770172317924	1770172317927	success	100	null
j5pqq5q7xpyepnimei1oahmumr	expiry_notify	0	1770172963894	1770172978255	1770172978259	success	100	null
aet37wem4fbf3phottbircwxwc	expiry_notify	0	1770180884625	1770180887051	1770180887055	success	100	null
3uj79z5c5ig3fysgkdgp754f4h	cleanup_desktop_tokens	0	1770173443935	1770173458469	1770173458473	success	100	null
c857wejwztfo9gkaj79ekupfwa	cleanup_desktop_tokens	0	1770177044268	1770177045110	1770177045116	success	100	null
enfmkic537fjjkrb3ms31y1idy	expiry_notify	0	1770173623954	1770173638563	1770173638566	success	100	null
u9jtgsw3gtbbbmapg3ingxrspr	product_notices	0	1770173743978	1770173758608	1770173758707	success	100	null
qqe59nnfatgz7k68snzz5ekhjr	expiry_notify	0	1770174284035	1770174298872	1770174298876	success	100	null
ubp549ny47y1x8dxp3eq3ri7ma	expiry_notify	0	1770174944075	1770174944120	1770174944126	success	100	null
jnr79y34ftdn8ygw17t74xcy7c	product_notices	0	1770177344307	1770177345268	1770177345375	success	100	null
atnfsb4im7nbxnipekcrtr7rnr	expiry_notify	0	1770175604113	1770175604378	1770175604382	success	100	null
zdhs1ow47irxuezjzqnarm5jho	expiry_notify	0	1770176264182	1770176264702	1770176264708	success	100	null
cq6k799qufb9zp5crrs98ofzyr	expiry_notify	0	1770177584348	1770177585395	1770177585402	success	100	null
j9177x3crfy35mamnxuoaf3sae	cleanup_desktop_tokens	0	1770184364973	1770184368873	1770184368878	success	100	null
hstfha35o7b9uba9o8ua6ui9th	expiry_notify	0	1770178244416	1770178245741	1770178245747	success	100	null
9et1mt98offwpec7ka655fe7se	product_notices	0	1770180944642	1770180947080	1770180947216	success	100	null
hw6u7ky3ojnzjmurnkpnkhifky	expiry_notify	0	1770178904460	1770178906074	1770178906081	success	100	null
xd87613tkidj5mkiyesp86i4zw	expiry_notify	0	1770179564508	1770179566403	1770179566407	success	100	null
tus1p6njp38kinxmwmdfkrw7mw	expiry_notify	0	1770180224566	1770180226738	1770180226745	success	100	null
ampj6c3kspfq5qmpx7884uer3r	cleanup_desktop_tokens	0	1770180704596	1770180706969	1770180706976	success	100	null
yptax9bf378u5r7yekiadffsfa	expiry_notify	0	1770181544726	1770181547403	1770181547410	success	100	null
9rssyx4zpfr8mpzh3qgb3agzhw	expiry_notify	0	1770182204790	1770182207717	1770182207723	success	100	null
s3cpgco6xtdeppkpw69aroq3nr	expiry_notify	0	1770186825193	1770186829977	1770186829983	success	100	null
u73occouo7frujcpy1brakfexa	expiry_notify	0	1770182864865	1770182868070	1770182868076	success	100	null
d5k86a6cyfgxmrsn7ef7jsj5mr	product_notices	0	1770184544991	1770184548955	1770184549061	success	100	null
tethno7ao3fn8m8h55kyypz43h	expiry_notify	0	1770183524913	1770183528436	1770183528442	success	100	null
bknnpkymwbyuzpp79u9xw9srco	expiry_notify	0	1770184184947	1770184188783	1770184188791	success	100	null
o9ew6fddd3d7tjnxj6u5kuefso	expiry_notify	0	1770184845008	1770184849072	1770184849077	success	100	null
t14jaqni3bbwtq5c7ttto75kmo	expiry_notify	0	1770185505065	1770185509322	1770185509329	success	100	null
1m3xky39yjdmug11b1zbfitkua	expiry_notify	0	1770189465412	1770189471153	1770189471159	success	100	null
5ws5ut9u6pyziqxuwt5woa7gqc	expiry_notify	0	1770186165147	1770186169647	1770186169653	success	100	null
5k6ujqb6qtd4uri496gzyefayr	expiry_notify	0	1770187485259	1770187490290	1770187490296	success	100	null
uu3fdj7em7bd8n4swgewjostro	product_notices	0	1770188145316	1770188150626	1770188150716	success	100	null
uk5yutdwojr49jfct96x6x9cua	cleanup_desktop_tokens	0	1770188025299	1770188030572	1770188030579	success	100	null
xnts87edybdk9rsxjgankiofuy	expiry_notify	0	1770188805367	1770188810877	1770188810884	success	100	null
7cj99eh6sbyqpewpkbx5wfgr3e	expiry_notify	0	1770190125458	1770190131450	1770190131456	success	100	null
3t7mo4x657dcixke7pbj3x5cra	cleanup_desktop_tokens	0	1770191685626	1770191692177	1770191692182	success	100	null
p8rpk8yo53fa3e64m8jsmnd5mh	expiry_notify	0	1770190785536	1770190791788	1770190791792	success	100	null
rrs1irfy9jnaib436f8uk49n4a	expiry_notify	0	1770191445594	1770191452051	1770191452056	success	100	null
qfa6jnaf7pd6bc9w3kqyyz6rra	product_notices	0	1770191745635	1770191752208	1770191752301	success	100	null
xuey59kw6jys5gceje5zxw6nwr	expiry_notify	0	1770192105660	1770192112376	1770192112382	success	100	null
8hyq5f18i3ywuk185wicqfmo1e	expiry_notify	0	1770192765731	1770192772718	1770192772723	success	100	null
fas95en3zpbwzy6hoyh1md3q8y	expiry_notify	0	1770193425792	1770193433031	1770193433038	success	100	null
faamo8hhc38nz88h4fz4cihjoc	expiry_notify	0	1770194085846	1770194093347	1770194093354	success	100	null
1mw6y7trs7g5jxjnpj4or3d99y	expiry_notify	0	1770194745903	1770194753644	1770194753651	success	100	null
6ownt4cnd7nizpqx3eqds9f48a	product_notices	0	1770195345964	1770195353914	1770195354029	success	100	null
b5exnnsfmibk98egpu31ifjcge	expiry_notify	0	1770197386170	1770197394940	1770197394945	success	100	null
8se6c15ehtg69ytqzwhry4qd5c	expiry_notify	0	1770580700144	1770580713164	1770580713170	success	100	null
7zuyjsai73gambjbojbzcwwsby	expiry_notify	0	1770202606621	1770202617339	1770202617344	success	100	null
rwyoc3e9h3rm8cx8z78nmh8fjw	cleanup_desktop_tokens	0	1770195345959	1770195353914	1770195353919	success	100	null
6689cormoprommznrqmbys3bwr	product_notices	0	1770209747182	1770209760481	1770209760583	success	100	null
c5gunmp9ip8h9dy5atig7e8c4y	expiry_notify	0	1770195405980	1770195413946	1770195413953	success	100	null
48ttn1nudjfm7qftmasgmy1kio	cleanup_desktop_tokens	0	1770202666634	1770202677384	1770202677390	success	100	null
p7oxnrxto3npzeoffgcgotkgwh	expiry_notify	0	1770196066038	1770196074297	1770196074302	success	100	null
akjwzzqq9ib83e3wdto6qdrmhr	expiry_notify	0	1770203266692	1770203277679	1770203277683	success	100	null
f8xh4p7xw7fz3q69md59xmhuxw	expiry_notify	0	1770196726100	1770196734619	1770196734624	success	100	null
pr1imn57sfb9xbkgr95kg4ewuy	expiry_notify	0	1770205246836	1770205258652	1770205258658	success	100	null
pug3ywasutfr8b6fm4dcxq5f6h	expiry_notify	0	1770209867200	1770209880541	1770209880547	success	100	null
tgkyd619x3bduk7su9k5w1r58r	mobile_session_metadata	0	1770206146924	1770206159017	1770206159019	success	100	null
ssg8aj9crt847p7tmchfmwy4rr	import_delete	0	1770206146928	1770206159017	1770206159019	success	100	null
yo33wtiza3d9jd11uujbutycec	export_delete	0	1770206146923	1770206159017	1770206159020	success	100	null
5qio1t6rytdh8c5odtayfcy3ho	plugins	0	1770206146926	1770206159017	1770206159025	success	0	null
dz9qh7ie1fbsud9xdzppf68c1h	install_plugin_notify_admin	0	1770206146927	1770206159017	1770206159027	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
cbikr4kyqbgqbnp1eiuh5pny8y	product_notices	0	1770206146918	1770206159017	1770206159087	success	100	null
sbs7d8msi7drinkhusj88om6me	expiry_notify	0	1770206566984	1770206579126	1770206579130	success	100	null
j3bh6to6atn1uc1nyr4r3xp1nr	cleanup_desktop_tokens	0	1770209987214	1770210000608	1770210000613	success	100	null
5tq7tehw9fnx7bkanawkjd5amc	expiry_notify	0	1770207887067	1770207899628	1770207899634	success	100	null
x6i1hgf1pjbxpff8m8kopjzzco	expiry_notify	0	1770216467881	1770216468406	1770216468412	success	100	null
4opjqsswd3gbmgjodrsru34tgo	expiry_notify	0	1770210527274	1770210540867	1770210540871	success	100	null
uaarw5u5s3bdxfo9jghufuxf9o	expiry_notify	0	1770211847444	1770211861460	1770211861465	success	100	null
5t89fkymitd5mm8tno43pgg1py	expiry_notify	0	1770212507503	1770212521760	1770212521768	success	100	null
urra7113uf89pdxrogq4fn9jhh	expiry_notify	0	1770225648687	1770225652535	1770225652542	success	100	null
qtbrgg1ocin8f8eork94bpsnue	expiry_notify	0	1770213167525	1770213181928	1770213181932	success	100	null
z9q5j55ifbnq5pxt4pp3cc3fic	product_notices	0	1770216947914	1770216948663	1770216948777	success	100	null
ouknek9iatfe7qpky5jq8dw58w	expiry_notify	0	1770214487626	1770214502483	1770214502488	success	100	null
eo893c8ik7bk7ecepucqu8xbky	expiry_notify	0	1770215147687	1770215147756	1770215147762	success	100	null
7on5pkzuuifzpe84zmdfs1b7te	expiry_notify	0	1770222408382	1770222411019	1770222411026	success	100	null
xw4x1kagypy938nrizn7yt99oo	expiry_notify	0	1770217127937	1770217128733	1770217128737	success	100	null
9773iquuijrwmb731spdpaec1r	expiry_notify	0	1770217788011	1770217788967	1770217788972	success	100	null
em518etu6trsty5bpntnzafcjr	expiry_notify	0	1770219108065	1770219109422	1770219109428	success	100	null
r5w3cst96iypzq6aiishm44zno	product_notices	0	1770220548182	1770220550105	1770220550212	success	100	null
sthrt7qne7ru8pc4p4bhejzsrh	expiry_notify	0	1770223008438	1770223011290	1770223011294	success	100	null
fcppmuo1zt8fxf15gb1oqrzpgw	expiry_notify	0	1770223668477	1770223671611	1770223671617	success	100	null
j1wrst4463g9ip33cwnsgjen3o	expiry_notify	0	1770224988618	1770224992213	1770224992218	success	100	null
s854yrwzmfd19rrnrhqzx1jhkh	expiry_notify	0	1770234169469	1770234176454	1770234176461	success	100	null
q6817irtk786jp6kua9hg1yqaw	expiry_notify	0	1770226248744	1770226252802	1770226252807	success	100	null
7ry3uxwgb7ngucw8nt1m9bxkhe	cleanup_desktop_tokens	0	1770228288934	1770228293758	1770228293764	success	100	null
udnbdmrpg78h5fckuf1m88k67o	expiry_notify	0	1770226908812	1770226913138	1770226913142	success	100	null
xpj9hj1tybgbxxwhqi9thtgy9r	expiry_notify	0	1770228228918	1770228233730	1770228233736	success	100	null
8foeqibf5bnitk9p9ggwdcx66y	expiry_notify	0	1770230209104	1770230214630	1770230214635	success	100	null
5wygmpighighjqgrf9z18tcduy	expiry_notify	0	1770236149658	1770236157308	1770236157314	success	100	null
q3ar8zmxqt8ajeqg6pn3x1p94c	product_notices	0	1770234949547	1770234956799	1770234956911	success	100	null
ukxak1p5uibeimpci9xisnzhrc	expiry_notify	0	1770237469725	1770237477889	1770237477896	success	100	null
jh61miiz77detfmdxy8ot4dpzc	product_notices	0	1770238549819	1770238558399	1770238558500	success	100	null
3s8mabecof8zppzjjtgoxd4snc	expiry_notify	0	1770238729842	1770238738479	1770238738484	success	100	null
1d68d9mdrpff58up8gr69jyhmr	expiry_notify	0	1770242030144	1770242040000	1770242040006	success	100	null
1i4hqdqpdpyo8dupwag19f9zwo	product_notices	0	1770242150160	1770242160054	1770242160181	success	100	null
umad4f3nyjbujy9rpyz18cawaa	cleanup_desktop_tokens	0	1770242810201	1770242820260	1770242820264	success	100	null
gikh7myyhbrtzno5imj1ks6bfh	expiry_notify	0	1770243350228	1770243360456	1770243360463	success	100	null
j9fcwmjugfyh3ris7zuh4fgpkr	expiry_notify	0	1770244670297	1770244680901	1770244680906	success	100	null
uyf6z9ondfdspchqqjepoujyyo	expiry_notify	0	1770245330362	1770245341132	1770245341137	success	100	null
t85fxds8cfd43dukhe3azi7bmh	expiry_notify	0	1770198046217	1770198055265	1770198055270	success	100	null
jx7xo75xfjdndyzyxfbsy3tskw	expiry_notify	0	1770203926715	1770203938003	1770203938010	success	100	null
waqa77in7by8trcqbpihxh11ey	expiry_notify	0	1770198706298	1770198715606	1770198715613	success	100	null
r4cd15i9638gtpskj9qjixhbiw	expiry_notify	0	1770204586763	1770204598319	1770204598324	success	100	null
s6njz7x9xp8gfeo5xuse3sao4o	product_notices	0	1770198946326	1770198955703	1770198955813	success	100	null
a3ayadyjcbgxzfcmh8fh3ob46o	cleanup_desktop_tokens	0	1770199006339	1770199015715	1770199015721	success	100	null
1pisrpb1wjfr7pjhzq1nz1dn5r	expiry_notify	0	1770205906890	1770205918936	1770205918939	success	100	null
xush41j6wpdmtkfpthezu5ugay	expiry_notify	0	1770199306325	1770199315779	1770199315784	success	100	null
kk6j48kiwtfauqf7qg4dedbuca	expiry_notify	0	1770215807778	1770215808058	1770215808064	success	100	null
3sm6q4t47t8kix7mogq7cjihxw	cleanup_desktop_tokens	0	1770206326947	1770206339073	1770206339074	success	100	null
34ejd9up9bf8pfakagipprrrqh	expiry_notify	0	1770199966362	1770199976059	1770199976065	success	100	null
nuokjq9djtf5zcz9j43drhehnc	expiry_notify	0	1770207227023	1770207239411	1770207239417	success	100	null
u1nsk4uqrtrsxekactqd4g4mke	expiry_notify	0	1770200626411	1770200636385	1770200636390	success	100	null
5464ykcsifd1dg1cnnzu7w3xze	expiry_notify	0	1770208547108	1770208559930	1770208559937	success	100	null
4mtiihnj5bnc7f9ouftd91m99o	expiry_notify	0	1770209207133	1770209220223	1770209220227	success	100	null
35fseznymtda5pm9ibmyze1rza	cleanup_desktop_tokens	0	1770217307963	1770217308803	1770217308807	success	100	null
jxdum49zbfn45rm51dr61jndzh	expiry_notify	0	1770211187387	1770211201211	1770211201215	success	100	null
sbsedi356pn78ra6zusnnx8uho	product_notices	0	1770213347541	1770213362001	1770213362102	success	100	null
hraems4anbyduphkd7z39dcxdr	cleanup_desktop_tokens	0	1770213647551	1770213662121	1770213662127	success	100	null
799j9np5d3rcjrgfydqe7ia6fr	product_notices	0	1770224148525	1770224151850	1770224151950	success	100	null
xaae6yhsw7daxm7g739yc5fxqw	expiry_notify	0	1770213827557	1770213842191	1770213842198	success	100	null
anth4gtt83fdzq5dphj1ynye4w	expiry_notify	0	1770218448060	1770218449236	1770218449238	success	100	null
aezmtczerirdzbsdnwoo7zdq6o	expiry_notify	0	1770219768103	1770219769726	1770219769732	success	100	null
xjbcnq5wgbrex86ny1zxi3fjqe	expiry_notify	0	1770220428162	1770220430046	1770220430049	success	100	null
jd1eke4bsjbatjeeswjx66om4e	cleanup_desktop_tokens	0	1770231949273	1770231955442	1770231955447	success	100	null
9jmj1qbjcpywt8cpokj7fzr5ae	cleanup_desktop_tokens	0	1770220968227	1770220970332	1770220970337	success	100	null
twbgxjgowbrnbe93uwrigsibte	expiry_notify	0	1770224328544	1770224331914	1770224331920	success	100	null
4hegoa7u5fb8uyua44gqoynf4o	expiry_notify	0	1770221088247	1770221090388	1770221090392	success	100	null
xrzy4gjsubb6ffdtxeikrp4mjh	expiry_notify	0	1770221748321	1770221750740	1770221750747	success	100	null
jp8164w6dty19dpjxeuxi3qgzr	expiry_notify	0	1770229549046	1770229554315	1770229554320	success	100	null
xewa6h4ym7re3b9hnsdu8cmkxc	cleanup_desktop_tokens	0	1770224628580	1770224632054	1770224632058	success	100	null
9cztyetpo3f43dejobag7y55jr	expiry_notify	0	1770227568851	1770227573439	1770227573445	success	100	null
usrzu1cqxj8emdt8wdkz8xdbra	product_notices	0	1770227748875	1770227753521	1770227753634	success	100	null
p5ptup8eybrw9xsayitcfq63xh	expiry_notify	0	1770228888981	1770228894012	1770228894018	success	100	null
p9ntkuoyztdy8k6swksi4j16fr	expiry_notify	0	1770230869168	1770230874953	1770230874959	success	100	null
sqmgm1q7ipd8u8imkx8x55xhcr	product_notices	0	1770231349206	1770231355183	1770231355300	success	100	null
o7rqmy49ptyu9q5htwa4cd454h	expiry_notify	0	1770231529222	1770231535267	1770231535271	success	100	null
h18aq865kibodb86y6tbie99rc	expiry_notify	0	1770232189288	1770232195561	1770232195565	success	100	null
shasn9zfkbrwzejsmwk9uk4x1e	expiry_notify	0	1770232849340	1770232855827	1770232855832	success	100	null
ekuxjudyw3yqxr4q1txitku6ry	expiry_notify	0	1770234829532	1770234836750	1770234836756	success	100	null
9azpawdnxpgtdxzorngn5x9n4a	expiry_notify	0	1770233509401	1770233516125	1770233516130	success	100	null
tbcih3xqztd77yie5mcce3e48h	cleanup_desktop_tokens	0	1770235549621	1770235557054	1770235557058	success	100	null
n8r9d49dg3dxmfw9x5obafrxea	expiry_notify	0	1770235489605	1770235497029	1770235497033	success	100	null
wa9gkpafj7rzxeuoya1cr5wqmc	expiry_notify	0	1770236809691	1770236817594	1770236817599	success	100	null
8pc1cm1wcfyifd6u4r6mgcx36a	expiry_notify	0	1770238129769	1770238138195	1770238138201	success	100	null
f5n3ttkjs7ycjxmeqnbpk359ih	cleanup_desktop_tokens	0	1770239149865	1770239158678	1770239158683	success	100	null
b1ybphu7kpnh7kw7weourhsq8a	expiry_notify	0	1770239389893	1770239398769	1770239398772	success	100	null
u36nqqfj5j83ijj4x45wcnr11y	expiry_notify	0	1770240049953	1770240059032	1770240059036	success	100	null
5gkdzi7j7pyz9jofsza9xs14xo	expiry_notify	0	1770240710018	1770240719368	1770240719374	success	100	null
3jb6s1bwubgq5xyzujmffq7urh	expiry_notify	0	1770241370085	1770241379680	1770241379686	success	100	null
hjw64rsufifhdys3rn65t1oksh	expiry_notify	0	1770242690191	1770242700221	1770242700227	success	100	null
431qjec5kb8aurtwoeqfq45x8a	expiry_notify	0	1770244010266	1770244020693	1770244020701	success	100	null
roeeamry1ff85yfcwms8zcfjnc	product_notices	0	1770245750382	1770245761292	1770245761394	success	100	null
xuh67iqwxjrz5pax9aonmrounc	expiry_notify	0	1770245990399	1770246001371	1770246001375	success	100	null
3pdofy3ou389pfgrq7dtkquyjo	expiry_notify	0	1770655046646	1770655057099	1770655057106	success	100	null
peqbd9yhafbpfgijudmnrb7e6e	cleanup_desktop_tokens	0	1770246410429	1770246421512	1770246421515	success	100	null
yodizkr84bbdfjqn51qhemouby	expiry_notify	0	1770270292528	1770270297355	1770270297361	success	100	null
jbn8q53wq3bodmamdxoqn3ga4w	expiry_notify	0	1770246650444	1770246661613	1770246661619	success	100	null
x7b479u9iinubdbmh5nf8gcrbc	expiry_notify	0	1770247310501	1770247321876	1770247321881	success	100	null
5gurejyt8inyicy6eenpdxqwbw	expiry_notify	0	1770270952610	1770270957679	1770270957686	success	100	null
yxhtrmmnc3d3zrzafwiht6rmuh	product_notices	0	1770270952612	1770270957679	1770270957786	success	100	null
5p3ae8p1obby8qcyczzg9bkyuw	expiry_notify	0	1770252590894	1770252604307	1770252604314	success	100	null
6wq4admwc7yj8cda6nba5znrkc	expiry_notify	0	1770247970545	1770247982178	1770247982185	success	100	null
jmxdh651n7dmikszjc76msfgic	expiry_notify	0	1770271612656	1770271617971	1770271617977	success	100	null
ws7fuwn9rj8sfr8zqdjh6j5r4h	expiry_notify	0	1770248630619	1770248642484	1770248642491	success	100	null
qu87o5qgmfde8mnuaijd5go81y	cleanup_desktop_tokens	0	1770271972699	1770271978113	1770271978118	success	100	null
c9d91eam17gu8gt6caehhhcuyr	expiry_notify	0	1770249290611	1770249302723	1770249302726	success	100	null
g3bzf6cjabr68dg3g6cba4tfzc	product_notices	0	1770256551273	1770256566203	1770256566314	success	100	null
adwhbupi678ctefkbnbb5huuar	product_notices	0	1770249350622	1770249362744	1770249362852	success	100	null
5ndhtobe6ffummjodihmrgssyh	expiry_notify	0	1770272272735	1770272278216	1770272278223	success	100	null
o8ph39m3cfdjtk9t6yxg11rrnh	product_notices	0	1770252950924	1770252964495	1770252964615	success	100	null
sx7pb4gey3bd8xagfsbr84te8y	refresh_materialized_views	0	1770249650629	1770249662855	1770249662879	success	100	null
pbo7etk3iibexf85jgja58hwue	expiry_notify	0	1770249950659	1770249963012	1770249963019	success	100	null
tr9w9nr6ktym7bjohux68c4b6c	cleanup_desktop_tokens	0	1770250070677	1770250083072	1770250083079	success	100	null
zwouykuh9frs5j3ja7e1an8h1e	expiry_notify	0	1770250610720	1770250623324	1770250623330	success	100	null
br955637rjnz3j5szc8cwzsf7c	expiry_notify	0	1770253250943	1770253264640	1770253264646	success	100	null
yri8ri8n4tga7y9ezos3bqwnia	expiry_notify	0	1770251270745	1770251283663	1770251283671	success	100	null
a56e4p3et7budk6qmmc3h4qgfo	expiry_notify	0	1770251930756	1770251943924	1770251943928	success	100	null
jp6df3jtzfnx7roxdum6arhe7e	cleanup_desktop_tokens	0	1770253730978	1770253744871	1770253744875	success	100	null
zhnuahtxf7y798y3bwcsmfgo1a	expiry_notify	0	1770253910997	1770253924955	1770253924961	success	100	null
6igr83iimibjffq8r93hnd1d4w	expiry_notify	0	1770257151322	1770257151447	1770257151454	success	100	null
fo7aj8h9dbby7rpr43ci63igph	expiry_notify	0	1770254571054	1770254585244	1770254585249	success	100	null
zf5u6b863ifk5j8zfgqbz6zbdy	expiry_notify	0	1770255231124	1770255245561	1770255245569	success	100	null
u7mokagjo3d97yx696b97gs59a	expiry_notify	0	1770255891194	1770255905870	1770255905876	success	100	null
d869oqkj1f8y3rf891347coo6y	product_notices	0	1770260151581	1770260152750	1770260152850	success	100	null
nqqsrcceztbb9yawmc399try6o	expiry_notify	0	1770256551269	1770256566203	1770256566210	success	100	null
z3tby7g36tnxjr5c3zyxied6to	cleanup_desktop_tokens	0	1770257391355	1770257391560	1770257391566	success	100	null
4xcuqm6jbtr4ukn96o76f9xruc	expiry_notify	0	1770257811374	1770257811730	1770257811738	success	100	null
bwxf4zxdjigkbr9aust8newyto	expiry_notify	0	1770258411431	1770258411930	1770258411932	success	100	null
34bpn4ckhpfpdmh44z1od8axyr	expiry_notify	0	1770259071467	1770259072210	1770259072213	success	100	null
8yx8h58f43bzm8przsxrqfud9o	expiry_notify	0	1770260391604	1770260392887	1770260392894	success	100	null
19gofx3ob7yjpeymxzczu3dksw	expiry_notify	0	1770259731521	1770259732549	1770259732555	success	100	null
585akrmq7jgkickyczm331sj1c	expiry_notify	0	1770262371817	1770262373771	1770262373774	success	100	null
zgnwd81btpg4pp5cy8ee6gf6ih	cleanup_desktop_tokens	0	1770261051656	1770261053174	1770261053178	success	100	null
acwa14m383rimfep4ofq3jaidc	expiry_notify	0	1770261051661	1770261053174	1770261053178	success	100	null
6mw6s5pcpi8cxrxf1cdr43rfpe	expiry_notify	0	1770261711736	1770261713462	1770261713464	success	100	null
d8t5e7daz3fi9cqdp9qs3rfxbc	expiry_notify	0	1770263031870	1770263034018	1770263034020	success	100	null
kemptbpcub8y5xmqu5gnaahrsh	expiry_notify	0	1770263691926	1770263694310	1770263694314	success	100	null
e6nc6oz3winu8pbpkaeutgpp8a	expiry_notify	0	1770264351968	1770264354589	1770264354593	success	100	null
ayq7ud1nyb8xxduj3cj55xosgy	product_notices	0	1770263751935	1770263754335	1770263754457	success	100	null
kuak6gbbojnstkjuxb9s7eduxh	cleanup_desktop_tokens	0	1770264711988	1770264714799	1770264714803	success	100	null
typ8rjahafnt5eehrndy91x9kw	expiry_notify	0	1770265012009	1770265014927	1770265014931	success	100	null
9azyw61rxbbzfx7yqxkowy68hh	expiry_notify	0	1770265672045	1770265675243	1770265675250	success	100	null
od7wf8g87jbnxg7i5i4w177o4h	product_notices	0	1770267352205	1770267356003	1770267356105	success	100	null
ab78cr341iggtrmwa39oszppmy	expiry_notify	0	1770266332107	1770266335542	1770266335549	success	100	null
ro4z6xiyjjbd5yno64xkpjkwrr	expiry_notify	0	1770266992166	1770266995853	1770266995855	success	100	null
6syheejzbfn47fg5ygqo453grw	expiry_notify	0	1770267652249	1770267656162	1770267656167	success	100	null
951onx5cwbfnde7fgo865n8rbc	expiry_notify	0	1770268312329	1770268316461	1770268316465	success	100	null
sb83d6dtptyb5xjonszo6y6byr	cleanup_desktop_tokens	0	1770268372331	1770268376487	1770268376492	success	100	null
91197xhztbg87fj1gfh6xnfzxh	expiry_notify	0	1770425826374	1770425827757	1770425827763	success	100	null
wdjj5soyrbdajnnxs9c4mn9fww	expiry_notify	0	1770272932805	1770272938532	1770272938537	success	100	null
ji19grqocbffjfdcg7dtnp8qyc	expiry_notify	0	1770273592851	1770273598872	1770273598879	success	100	null
em3sts8b4tntubwyy1tzbtw1bo	expiry_notify	0	1770274252881	1770274259184	1770274259189	success	100	null
qugo85tqaidztq7bc713rsuspw	cleanup_desktop_tokens	0	1770279233332	1770279241431	1770279241435	success	100	null
51oz6o3y9tgtbpawpsr77pjmbh	product_notices	0	1770274552896	1770274559329	1770274559431	success	100	null
q1oqptgy7p8fddomg4rtbzz8jy	expiry_notify	0	1770274912916	1770274919455	1770274919463	success	100	null
dc734qdnipg35mnnzu1edu3oiw	expiry_notify	0	1770275572960	1770275579759	1770275579765	success	100	null
tqkpw7e5f7bk9drp83knkgz4ph	expiry_notify	0	1770283493740	1770283503397	1770283503402	success	100	null
9cbtaij7g3nemg8smjumfb93ia	cleanup_desktop_tokens	0	1770275632971	1770275639804	1770275639809	success	100	null
hs1rzjrngtfh3kpq4sbk5tk5xh	expiry_notify	0	1770279533351	1770279541596	1770279541603	success	100	null
os73g1rdmbfxbc99i3wksngpea	expiry_notify	0	1770276233040	1770276240113	1770276240117	success	100	null
wuxf18gftbyxdpqnoscawudfqr	expiry_notify	0	1770276893092	1770276900430	1770276900435	success	100	null
q77n79hhqtdsxpt5uchmf4qkwh	expiry_notify	0	1770277553192	1770277560728	1770277560730	success	100	null
md5jot3dpfbkdqpcsaga9ti7zh	product_notices	0	1770278153265	1770278160961	1770278161043	success	100	null
sj1ywzarzfgifbdug48rb63njc	expiry_notify	0	1770280193412	1770280201890	1770280201896	success	100	null
kt7n1krcdpgrbd43qqkwrcuzxo	expiry_notify	0	1770278213274	1770278220987	1770278220991	success	100	null
xwxj31ebspfzfx88geaypq7ehw	expiry_notify	0	1770278873330	1770278881293	1770278881301	success	100	null
4db1jxj393bf8dusp11thgor8h	expiry_notify	0	1770280853461	1770280862232	1770280862236	success	100	null
wokfxf6mdfdmxnppds9qx3hx7h	expiry_notify	0	1770286793939	1770286804686	1770286804693	success	100	null
k4dntftfcff87kzboaghgzwdmy	expiry_notify	0	1770281513548	1770281522520	1770281522525	success	100	null
4ds4jm94fjycudrqawsxykd33y	expiry_notify	0	1770284153822	1770284163723	1770284163730	success	100	null
qiwjfow57by9b8bfz54yend97y	product_notices	0	1770281753576	1770281762619	1770281762711	success	100	null
wkdaykuippdhmku78pqgkz1pua	expiry_notify	0	1770282173620	1770282182794	1770282182801	success	100	null
nwfibzhe9tdn3qyupxa36gfsdw	expiry_notify	0	1770282833682	1770282843048	1770282843054	success	100	null
pzrcwwswzjfdfys1gf1kg6h3xw	cleanup_desktop_tokens	0	1770282893693	1770282903084	1770282903090	success	100	null
t3imyic9ut85mf51d13u3xy55c	expiry_notify	0	1770284813847	1770284823948	1770284823955	success	100	null
ua7fxeyxgtf9bfouybxwg8h5ah	product_notices	0	1770285353851	1770285364152	1770285364257	success	100	null
ejadkpdyxfghxpo5ae8wbxnu5r	expiry_notify	0	1770289434190	1770289445889	1770289445894	success	100	null
fogeh7f8eprpxqo86gjd79eyzw	expiry_notify	0	1770285473871	1770285484202	1770285484209	success	100	null
6g3cr1acwpdzfehfpdkcb8afih	expiry_notify	0	1770287454011	1770287464996	1770287465001	success	100	null
4hfbdk3c33yg7yprqztckwnfoe	expiry_notify	0	1770286133896	1770286144435	1770286144440	success	100	null
btm95gi1jfn68njyrpud7dytzh	cleanup_desktop_tokens	0	1770286553910	1770286564586	1770286564593	success	100	null
53irjtbfgtbqt86wcxr59h56xo	expiry_notify	0	1770288114071	1770288125307	1770288125314	success	100	null
8ebzwf13m3bnbgj7kko4mxjtre	expiry_notify	0	1770288774127	1770288785595	1770288785599	success	100	null
d7w55pbi8bgxmkye9konuh4nir	product_notices	0	1770288954137	1770288965701	1770288965792	success	100	null
uq8yqcyoxjbdim3yxry4pgs9ba	expiry_notify	0	1770290094262	1770290106137	1770290106139	success	100	null
akhp8xdmspy93k38nnjc4tkxzr	expiry_notify	0	1770291414403	1770291426594	1770291426598	success	100	null
7zkw7r3x9jgqdpo6zsy5sm14rw	cleanup_desktop_tokens	0	1770290154274	1770290166161	1770290166163	success	100	null
bxoi9ysm9inq9gnimdetedps6e	expiry_notify	0	1770290754333	1770290766376	1770290766379	success	100	null
dg34j17cbbb4i81cxsmhdx796e	expiry_notify	0	1770292074461	1770292086923	1770292086930	success	100	null
iyua1mnnhpgstnkptcu71ahbba	install_plugin_notify_admin	0	1770292554532	1770292567144	1770292567161	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
ndc1nd5xiiy9b8gjrimqz7mexy	import_delete	0	1770292554532	1770292567144	1770292567150	success	100	null
tqmkko51hp8ntkhj7atjrtemxr	plugins	0	1770292554531	1770292567144	1770292567150	success	0	null
wrocpb5n53ffdn9kei85pbrdqw	mobile_session_metadata	0	1770292554529	1770292567144	1770292567151	success	100	null
s8hbwkkref85tkop4qftmh3zmr	export_delete	0	1770292554527	1770292567144	1770292567159	success	100	null
5dppona4a78xznmkho6wsgm9th	product_notices	0	1770292554533	1770292567144	1770292567237	success	100	null
9u5hpddj8bdz3n76x3gfojwzdh	expiry_notify	0	1770292734556	1770292747236	1770292747241	success	100	null
j87yipcurjnwfjpobowpk6ma6w	expiry_notify	0	1770293394631	1770293407528	1770293407533	success	100	null
ewfbyggfc7bmubdeeo7wm9de6o	cleanup_desktop_tokens	0	1770293814647	1770293827686	1770293827691	success	100	null
soux1jf6k7g4jcquhgmo3sh75e	expiry_notify	0	1770294054658	1770294067810	1770294067816	success	100	null
ey9dhwwsbj8apr1acrinyjmhna	expiry_notify	0	1770294714727	1770294728133	1770294728140	success	100	null
bm6t8zcatjrfxkjmcx9grcfgay	expiry_notify	0	1770295374770	1770295388454	1770295388460	success	100	null
nk93eati5idu9ko6ihytbebzby	expiry_notify	0	1770296034854	1770296048826	1770296048832	success	100	null
j14iche6itraux53k5fqmb6a9o	expiry_notify	0	1770344819169	1770344820913	1770344820921	success	100	null
9snm8rbyybbh8kqjn5xhjbypyy	product_notices	0	1770306955691	1770306958258	1770306958356	success	100	null
ow3kjkmbzf8zxy3pdjnkp5r3he	product_notices	0	1770296154873	1770296168869	1770296168972	success	100	null
zb4nukkmf7yw5cuk4potqq7ory	expiry_notify	0	1770302575336	1770302576656	1770302576663	success	100	null
k73xs4ntgbbt989ynriq1zdcke	expiry_notify	0	1770296694921	1770296709124	1770296709131	success	100	null
ahjdkjhoo7f3zmscwybdeqa76c	expiry_notify	0	1770297294984	1770297309422	1770297309429	success	100	null
upz4p3kp63n5z811kxum87twww	cleanup_desktop_tokens	0	1770297474996	1770297489511	1770297489516	success	100	null
buaorkiajjgu7ez69naoifbtry	expiry_notify	0	1770297955045	1770297969748	1770297969754	success	100	null
npz3oa1fapyabfiqi7bhkz7poa	expiry_notify	0	1770303235372	1770303236864	1770303236869	success	100	null
kagunswzu3nzzcbgfjyurzagyh	expiry_notify	0	1770298615084	1770298630001	1770298630006	success	100	null
dew3ta11bjfa3m514mhhjxyiwo	expiry_notify	0	1770299275128	1770299275271	1770299275274	success	100	null
hbmqnanfwidmpmwadaa1orsk1o	product_notices	0	1770299755160	1770299755481	1770299755587	success	100	null
4xicuiwzqigcbqpmgtbhbxspac	expiry_notify	0	1770299935170	1770299935558	1770299935564	success	100	null
ufah6aq6tfbdxr4fz6j6m54doe	product_notices	0	1770303355387	1770303356908	1770303357007	success	100	null
ecee948wbtb8fq13ti94c1zd7r	expiry_notify	0	1770300595214	1770300595871	1770300595875	success	100	null
u4jjr1qcpidfxkaqc759d8haic	cleanup_desktop_tokens	0	1770301135243	1770301136087	1770301136094	success	100	null
nascpiufypg3zf98ewpmei6qzw	expiry_notify	0	1770301255259	1770301256138	1770301256144	success	100	null
oc8caeb57pba8dqbzkpdcxxcxw	expiry_notify	0	1770310495915	1770310499659	1770310499667	success	100	null
7ai5z783g3yxup3smr688hmo1h	expiry_notify	0	1770301915301	1770301916417	1770301916424	success	100	null
4f1tij1e73nfbkf8kkbb8y8r9r	expiry_notify	0	1770303895413	1770303897099	1770303897107	success	100	null
iob58yi3q38dif614pu88x7fbr	expiry_notify	0	1770307195702	1770307198356	1770307198363	success	100	null
eirrzpxc6innpn8drmd833xnjo	expiry_notify	0	1770304555480	1770304557351	1770304557354	success	100	null
8y7t39xr7tbcpesd4n9sx87jxa	cleanup_desktop_tokens	0	1770304735528	1770304737443	1770304737448	success	100	null
n3y7hbinbiride1e3695151oyo	expiry_notify	0	1770305215563	1770305217633	1770305217639	success	100	null
b1m96akfgjfmbgz56zhty9hnbh	expiry_notify	0	1770305875609	1770305877873	1770305877878	success	100	null
bxnidrf4m3nkzcwnxe63j7o9mr	expiry_notify	0	1770307855753	1770307858581	1770307858589	success	100	null
rqem638o77r5mxyhj4n94a5ffa	expiry_notify	0	1770306535661	1770306538108	1770306538116	success	100	null
fpd4i3it5jnztf4wmsybup8whc	expiry_notify	0	1770312476150	1770312480594	1770312480600	success	100	null
c83bhorpe7biupcmsyjjcxk7ny	cleanup_desktop_tokens	0	1770308395766	1770308398764	1770308398770	success	100	null
gidxkd96dbyixbzxpe1hk5xnca	product_notices	0	1770310555929	1770310559695	1770310559813	success	100	null
seebr7qzoifeix1yh6xius1ycr	expiry_notify	0	1770308515780	1770308518820	1770308518828	success	100	null
ujzheubppfr5xeui64gnfua9co	expiry_notify	0	1770309175817	1770309179067	1770309179077	success	100	null
zfmjx8duepdfmg8pfsfefo5fzo	expiry_notify	0	1770309835853	1770309839340	1770309839346	success	100	null
nndt9s19yjbdbx4cad3n1ftqqw	expiry_notify	0	1770311155987	1770311159953	1770311159959	success	100	null
ws5mo1t5btb3fbjykk543oji3h	expiry_notify	0	1770311816068	1770311820261	1770311820267	success	100	null
ft7wbamn3ffb8pkdo6ck76ohyh	expiry_notify	0	1770313136196	1770313140881	1770313140886	success	100	null
9ywafqi5tbyopk8gsw9rhuiq7y	cleanup_desktop_tokens	0	1770312056100	1770312060351	1770312060356	success	100	null
it7k5hudxi8kpmujotb4w3dfuo	expiry_notify	0	1770314456321	1770314461518	1770314461524	success	100	null
fiysmy8rc3dh8nxceth4je9o4y	expiry_notify	0	1770313796260	1770313801181	1770313801187	success	100	null
uqafrydhdfd98p1k7zo7ebes5e	product_notices	0	1770314156308	1770314161356	1770314161487	success	100	null
167ttqs9siyz9psoagrgx7zpsc	expiry_notify	0	1770315116352	1770315121863	1770315121867	success	100	null
68gbygnq8fdkbxhytymuk88rpr	expiry_notify	0	1770315776402	1770315782115	1770315782120	success	100	null
uns6yng3qbdnpj9ydemudymmrc	cleanup_desktop_tokens	0	1770315716392	1770315722101	1770315722107	success	100	null
t8q8aa5bzjdpuks1nwcu9hf7ja	expiry_notify	0	1770316436464	1770316442386	1770316442394	success	100	null
idajcq1a9pffzxtrhjxu5fiscr	expiry_notify	0	1770317096530	1770317102692	1770317102699	success	100	null
pwjgqs55g3b6imuk14uyfrykiw	expiry_notify	0	1770317756588	1770317762988	1770317762993	success	100	null
bwen55gyb7ybbmoiyttzm43ahr	product_notices	0	1770317756593	1770317762988	1770317763123	success	100	null
5ej9qot6bfnwzntx9ncz7zxiyy	expiry_notify	0	1770318416653	1770318423313	1770318423317	success	100	null
u87gypo8w7f4tp4mhmmedcphko	expiry_notify	0	1770319076694	1770319083679	1770319083685	success	100	null
rc6uqo6853gtjb4fr3jidktnor	cleanup_desktop_tokens	0	1770319376717	1770319383834	1770319383839	success	100	null
4t8cooekmty1pqmbhrwyteeupw	expiry_notify	0	1770319736748	1770319743995	1770319744000	success	100	null
cu6yznda67gopp7iqteo5ojzir	expiry_notify	0	1770320396799	1770320404332	1770320404339	success	100	null
f1dyjh3m93dkdk5qdh3bx6qqpe	expiry_notify	0	1770321056850	1770321064690	1770321064696	success	100	null
cfgxmciaq3rbfg8q16nokocbhc	product_notices	0	1770321356877	1770321364822	1770321364951	success	100	null
4gbrajrmztrrdnxwactq61aaso	expiry_notify	0	1770512113902	1770512116571	1770512116577	success	100	null
oppoz54sp7byfbnwzqwex7cutc	expiry_notify	0	1770321716916	1770321725024	1770321725028	success	100	null
a6qbjwqi9pnwjj4qkspesu1aaw	expiry_notify	0	1770355380085	1770355385740	1770355385745	success	100	null
drsnagskntfqmdymkrukpfgxye	cleanup_desktop_tokens	0	1770344879183	1770344880934	1770344880940	success	100	null
dqtg97su6jga7r6kxszjeey94c	product_notices	0	1770346559356	1770346561653	1770346561763	success	100	null
1w4ek6qa4pfcuqo6pd84jsteer	expiry_notify	0	1770346799391	1770346801799	1770346801805	success	100	null
7tpumjexk3go9re7i65urw4oge	cleanup_desktop_tokens	0	1770348539559	1770348542621	1770348542626	success	100	null
wzah4mmnxjb7b8ysypyumro4oa	cleanup_desktop_tokens	0	1770355860124	1770355865945	1770355865951	success	100	null
camxjpcxp7bimrjjr6ea4drz7w	expiry_notify	0	1770348779586	1770348782725	1770348782731	success	100	null
1gw7d7r5jpy3fkounh783odwio	expiry_notify	0	1770350099620	1770350103324	1770350103332	success	100	null
5894zmb9apge5mawzt9cn735ze	expiry_notify	0	1770350759675	1770350763641	1770350763646	success	100	null
yy7bpaugxjne9jen7bd33jcdth	expiry_notify	0	1770351419728	1770351423864	1770351423870	success	100	null
morw65114inqjjxyzwqhkttfue	expiry_notify	0	1770356040154	1770356046042	1770356046048	success	100	null
m4ed8y6kifrezn781xhcq83u4w	cleanup_desktop_tokens	0	1770352199786	1770352204204	1770352204210	success	100	null
rcoyp8h55jd1pmsbu8766d6bah	product_notices	0	1770353759926	1770353764966	1770353765098	success	100	null
ib7gd8iip7boxyuw68qdn58aey	expiry_notify	0	1770354059963	1770354065131	1770354065135	success	100	null
xgi1n1o8ep8pt8izrhfe6x66yh	cleanup_desktop_tokens	0	1770363180783	1770363189622	1770363189628	success	100	null
qk9xhu5qdtby8cuig3c1t89m4h	expiry_notify	0	1770354720030	1770354725436	1770354725442	success	100	null
pnyym89gbf89xy1phi8gqzqnkc	expiry_notify	0	1770360000490	1770360008119	1770360008124	success	100	null
p6pnbjhwpigx8pwz3fopkxr1ic	expiry_notify	0	1770356700202	1770356706332	1770356706337	success	100	null
u3t5rxrm6bgjtefmpqhe6g9nrr	expiry_notify	0	1770357360259	1770357366694	1770357366701	success	100	null
95xe7mfdtfd8m8qs1sks8wj95o	product_notices	0	1770357360263	1770357366693	1770357366807	success	100	null
34ujq36j9trk9pwber8prxnuge	expiry_notify	0	1770358020284	1770358026992	1770358026997	success	100	null
pobjurgf87rb9b8maxp9jx13ww	expiry_notify	0	1770360660548	1770360668404	1770360668411	success	100	null
hf73ten54pnf8kdjrcb11gsmcr	expiry_notify	0	1770358680357	1770358687405	1770358687410	success	100	null
fch4szqdmpd4fnduagdq1pqqbc	expiry_notify	0	1770359340433	1770359347777	1770359347782	success	100	null
coeo7kxgmfyzuf1h5kgzr5d5ar	cleanup_desktop_tokens	0	1770359520452	1770359527841	1770359527846	success	100	null
t1ggookf9t8mprg3xtpynmb7ny	product_notices	0	1770360960579	1770360968554	1770360968645	success	100	null
furzsgm1e7dwmgxr81wqxyuzqc	expiry_notify	0	1770365280952	1770365290608	1770365290615	success	100	null
mapax1rku7yapr3wus1a1ynh1o	expiry_notify	0	1770361320619	1770361328696	1770361328702	success	100	null
rxjdnxd7p38f3cn6qz5z13yg9e	expiry_notify	0	1770363300797	1770363309677	1770363309680	success	100	null
843ed3s3x3yj5nykwjjizd6fjr	expiry_notify	0	1770361980668	1770361988999	1770361989003	success	100	null
d8h4dwitmtbwxfify7n6aafkhy	expiry_notify	0	1770362640740	1770362649353	1770362649359	success	100	null
p1rzbssysp87bma35req3bb3ba	expiry_notify	0	1770363960842	1770363969951	1770363969961	success	100	null
kbjkra8d1bn88c53ywbpkhpbah	product_notices	0	1770364560881	1770364570248	1770364570343	success	100	null
nz6sf1k87i8bxjgr7k7yyynpby	expiry_notify	0	1770365941020	1770365950883	1770365950885	success	100	null
w7pqqfjecjrpzg77c5jfgk6hhr	expiry_notify	0	1770364620892	1770364630269	1770364630272	success	100	null
cjuq9iwd4fr65x8pi63pj5yo9e	expiry_notify	0	1770367261135	1770367271459	1770367271464	success	100	null
34x441q7nj8hzmis8buc3h8dxw	expiry_notify	0	1770366601080	1770366611133	1770366611145	success	100	null
hj1jkejogffkubwn3f9qm4jxxh	cleanup_desktop_tokens	0	1770366841098	1770366851259	1770366851264	success	100	null
iitady879tdzfb6tfq6xycehue	expiry_notify	0	1770367921205	1770367931777	1770367931784	success	100	null
8utummi99jbu9dz8o9pgiapnwe	expiry_notify	0	1770368581262	1770368592098	1770368592102	success	100	null
p1w1tko9m7r9pcnfsefpgd1mcr	product_notices	0	1770368161232	1770368171888	1770368171971	success	100	null
1jbqqor87p8xbgkxti8bw11zer	cleanup_desktop_tokens	0	1770370501456	1770370513032	1770370513038	success	100	null
qyonkepruf8zdnh9fui6yo4y1a	expiry_notify	0	1770369241330	1770369252454	1770369252458	success	100	null
c6cs7yjhtf8ytmwbx9imh6d9ae	expiry_notify	0	1770369901391	1770369912784	1770369912792	success	100	null
mxocho9qatgjmpxmo7ju33amse	expiry_notify	0	1770370561463	1770370573052	1770370573056	success	100	null
1y1faz9oijr5jf13kd77jzr9eh	expiry_notify	0	1770371221521	1770371233333	1770371233340	success	100	null
i5dwr95qbfb48et9ai6gj7tkue	product_notices	0	1770371761567	1770371773543	1770371773637	success	100	null
fshr514bit8ombbmpqeceq3w6h	expiry_notify	0	1770371881578	1770371893583	1770371893590	success	100	null
s4migrzgjiyojd395gp6iupxko	expiry_notify	0	1770372541617	1770372553819	1770372553823	success	100	null
g7iuodfobtf1icgyrskq84b6ie	expiry_notify	0	1770373201644	1770373214130	1770373214137	success	100	null
5hjwfxasg38sbfkms5bzosnhbo	expiry_notify	0	1770373861675	1770373874447	1770373874453	success	100	null
49xe4zo16prmdpmynq1hduk49c	cleanup_desktop_tokens	0	1770374161717	1770374174584	1770374174590	success	100	null
59a84p7z4bnq8xrk4fw8fpdpjw	expiry_notify	0	1770741933982	1770741947046	1770741947053	success	100	null
4d7z885ngtdf7q1ieoupnr17jc	expiry_notify	0	1770322377008	1770322385342	1770322385347	success	100	null
dzygom3mz3ghfqrtguyny613ir	expiry_notify	0	1770345479253	1770345481190	1770345481196	success	100	null
h74qqawq9fgpb8xbgwwdxmy8mh	expiry_notify	0	1770346139293	1770346141445	1770346141449	success	100	null
uygzanm9xjbwibtu7zwzmi3qfh	expiry_notify	0	1770323037081	1770323045687	1770323045692	success	100	null
p7pz7os16jfxirr69kb8hhkmhc	cleanup_desktop_tokens	0	1770323037075	1770323045687	1770323045692	success	100	null
w7p6dau7ppduurrqsa51j6konr	expiry_notify	0	1770347459453	1770347462071	1770347462077	success	100	null
s8jodomr6tbfxg5k7kjjp18r7r	product_notices	0	1770328557601	1770328568198	1770328568335	success	100	null
xi1ow1sp1bn3xddtqxwj55rdew	expiry_notify	0	1770323697144	1770323705996	1770323706004	success	100	null
9euzqfd7u3rs9jxw5uk5kpmquw	expiry_notify	0	1770348119504	1770348122413	1770348122417	success	100	null
j7d36ojxrjb43rad6mhorbmmoc	expiry_notify	0	1770324357185	1770324366292	1770324366298	success	100	null
f4upobjm1frdinjepcnmghjsfh	expiry_notify	0	1770349439583	1770349442980	1770349442985	success	100	null
7qenozewbjf68mhnnnbih5taxo	product_notices	0	1770324957238	1770324966558	1770324966715	success	100	null
3esgdzsebtgoud7kn9y6is5xec	expiry_notify	0	1770332937959	1770332950229	1770332950236	success	100	null
mkhrmqpspfga3865u8xx3a9tdc	expiry_notify	0	1770325017247	1770325026575	1770325026581	success	100	null
yz7ixjth9tffbxr65hpynzsiyh	product_notices	0	1770350159631	1770350163357	1770350163463	success	100	null
sc6fmrnzb78w3g3ergt7qcdtmc	expiry_notify	0	1770328977635	1770328988389	1770328988395	success	100	null
aiqu1ningfgkzepif3oty769na	expiry_notify	0	1770325677301	1770325686879	1770325686885	success	100	null
b743sxwt1bra5nxey3ayx9fa1h	expiry_notify	0	1770352079768	1770352084146	1770352084153	success	100	null
7hrrjozt33dydq8pzdtq4nabyo	expiry_notify	0	1770326337362	1770326347185	1770326347189	success	100	null
hs71rzkbb3dtxf6emincgw1zwc	expiry_notify	0	1770352739833	1770352744443	1770352744449	success	100	null
41mzuksediba5xrs593o1w16ww	cleanup_desktop_tokens	0	1770326637396	1770326647304	1770326647309	success	100	null
xxis8dgnwbdotgjnt4qqxgoedy	expiry_notify	0	1770353399901	1770353404774	1770353404781	success	100	null
4ceo98cqxbn78dbssu5u5pw6ic	expiry_notify	0	1770326997430	1770327007471	1770327007476	success	100	null
mgqssrdf7tn5tjwqnkxt85wyzo	expiry_notify	0	1770329637703	1770329648691	1770329648698	success	100	null
3wyiamm57fds384bj9y4srkyea	expiry_notify	0	1770327657501	1770327667768	1770327667772	success	100	null
yotx6n3cmir7frfthkudnkzdqa	expiry_notify	0	1770328317574	1770328328061	1770328328067	success	100	null
ta1zrx9747r1unnay83ppkmsje	cleanup_desktop_tokens	0	1770330297758	1770330308980	1770330308985	success	100	null
u3kyjt1cp7rc9xt3eccw9fuhqe	expiry_notify	0	1770330297763	1770330308979	1770330308985	success	100	null
bui84u4cq3roumftta9uabkfxc	expiry_notify	0	1770333598054	1770333610583	1770333610588	success	100	null
g9djnf3crtfyme669s3nqmh69h	expiry_notify	0	1770330957801	1770330969289	1770330969294	success	100	null
ngje89zi8fd53mcpjgqgff54fw	expiry_notify	0	1770331617828	1770331629598	1770331629602	success	100	null
pkow3wwnhfybjq6xtwwckmb94e	product_notices	0	1770332157879	1770332169864	1770332169990	success	100	null
dh69ggbdo3bq3xjdgpzxkgsiec	refresh_materialized_views	0	1770336058324	1770336071814	1770336071838	success	100	null
rn1naiyhw38r5beymg3mxukizr	expiry_notify	0	1770332277888	1770332289931	1770332289938	success	100	null
gfrmpkhnxfyobcnhzghkgymmfe	cleanup_desktop_tokens	0	1770333898082	1770333910759	1770333910763	success	100	null
b8xbsifzn7rt9mq7hb7kesum8o	expiry_notify	0	1770334258127	1770334270917	1770334270922	success	100	null
g7chihswcfb53cxzq9c48aumkw	expiry_notify	0	1770334918233	1770334931277	1770334931284	success	100	null
tf5zrt87nbyg8yb6cx6cjzrghw	expiry_notify	0	1770335578291	1770335591581	1770335591586	success	100	null
mehakajna78it8qxtxnda1hmuw	expiry_notify	0	1770336238338	1770336251890	1770336251895	success	100	null
3t13ao3dmtgymg7m9n3ng8skjh	product_notices	0	1770335758301	1770335771680	1770335771808	success	100	null
eunbifkqgpnoidcjh1tr7yneor	expiry_notify	0	1770338218506	1770338232813	1770338232817	success	100	null
qhp91nmxn3ggdbiis1p7hfwume	expiry_notify	0	1770336898389	1770336912212	1770336912218	success	100	null
ghtzms6jtbnx5kywnuke87y8qr	cleanup_desktop_tokens	0	1770337558441	1770337572524	1770337572535	success	100	null
e44o5g1ai3nyigw5kuns5kbwmh	expiry_notify	0	1770337558436	1770337572525	1770337572542	success	100	null
xbj6tcnhhbdxmj7miryfsniwga	expiry_notify	0	1770338878561	1770338893125	1770338893127	success	100	null
538dac1c13gh3rsh7dgiyi7p4y	product_notices	0	1770339358610	1770339373350	1770339373451	success	100	null
xsufpwdyr7d33qh54f41xzmh9e	expiry_notify	0	1770340198681	1770340198746	1770340198750	success	100	null
56kuzgojq7dbtb1ozyta74f4se	expiry_notify	0	1770339538635	1770339553443	1770339553449	success	100	null
r9ifjojyw3gtmbbb4exo9yjuda	expiry_notify	0	1770340858758	1770340859071	1770340859078	success	100	null
7733xjrey7b9tfx3yr474h3bsa	cleanup_desktop_tokens	0	1770341218789	1770341219232	1770341219236	success	100	null
jztreqkpxfgobgpas4s4ja3pyr	expiry_notify	0	1770341518819	1770341519369	1770341519375	success	100	null
ntbf8bb4aib45nmmntnsfskyxe	product_notices	0	1770342958973	1770342960050	1770342960163	success	100	null
p3rared3k7yp8yhq4ixxodkh4a	expiry_notify	0	1770342178886	1770342179703	1770342179707	success	100	null
9a58pki8k3d1ic71sbqqzdddey	expiry_notify	0	1770342838958	1770342839993	1770342839999	success	100	null
pwkpjyc99fr9zg6ejfmnnydruo	product_notices	0	1770854204037	1770854213820	1770854213929	success	100	null
6gbsh45gibrwbq179prdhijrao	expiry_notify	0	1770426486437	1770426488063	1770426488068	success	100	null
x4bbsseesin9uc35eostf64gdh	expiry_notify	0	1770374521738	1770374534756	1770374534758	success	100	null
tbenhyurbtdhpkqc38fuyrqcde	expiry_notify	0	1770375181766	1770375195057	1770375195061	success	100	null
wf3dwq1uqfg5upqp4cucppi78e	expiry_notify	0	1770427146475	1770427148356	1770427148358	success	100	null
79rdg9ztdif6j89udwah1apo4e	product_notices	0	1770375361784	1770375375125	1770375375232	success	100	null
rgc5re45kf83mc66akyyrz9mby	expiry_notify	0	1770433087046	1770433091133	1770433091141	success	100	null
hws8u6669trfffmr8zsw38djiy	expiry_notify	0	1770427806541	1770427808638	1770427808641	success	100	null
mb864hae57rwieu97zxpifbt1a	expiry_notify	0	1770375841826	1770375855306	1770375855312	success	100	null
a1wqbcjjatr7mjp8o9g3adtqxw	expiry_notify	0	1770428466587	1770428468970	1770428468973	success	100	null
sbj3ybo6hb8wm88tymdxfa31uh	expiry_notify	0	1770376501872	1770376515671	1770376515678	success	100	null
y3397fouz78ptmjmattqrq8t9c	expiry_notify	0	1770377161911	1770377175940	1770377175947	success	100	null
ban9jt4ryfbebcb7juzp6ba71w	expiry_notify	0	1770429126639	1770429129272	1770429129279	success	100	null
h199o1ypbigepm1tgxgc37adrr	expiry_notify	0	1770429786714	1770429789575	1770429789577	success	100	null
hjjnwaw1ejbuzb57dg6c5dyyur	cleanup_desktop_tokens	0	1770377821978	1770377836244	1770377836249	success	100	null
zeehhqhsqbn7bm7htkjt77mj4o	expiry_notify	0	1770377821981	1770377836243	1770377836249	success	100	null
zipaqy4puprz9erk9fueajwfoy	expiry_notify	0	1770433747116	1770433751422	1770433751429	success	100	null
qajnxytw9pb8tj5iehceok1irr	expiry_notify	0	1770430446765	1770430449830	1770430449835	success	100	null
qf9wyrhnipdh98g4h1anh48wwy	expiry_notify	0	1770378482044	1770378496553	1770378496557	success	100	null
7jacwjmkcbydudmdb95ygoejzy	expiry_notify	0	1770431106836	1770431110146	1770431110156	success	100	null
j5ewedkwyjbm7fh6pa84cw1e7e	expiry_notify	0	1770432426956	1770432430812	1770432430817	success	100	null
bnb3af99fjdfxr17k1hb9cfjxy	cleanup_desktop_tokens	0	1770439867664	1770439874148	1770439874154	success	100	null
pr4ek3i5itne3muucyp99q1j7h	cleanup_desktop_tokens	0	1770432606986	1770432610887	1770432610894	success	100	null
snmgquqwt3nrummcedqaqjyd1c	expiry_notify	0	1770434407183	1770434411733	1770434411740	success	100	null
ctb53j5iwf8ziqfm53uh9rgjur	product_notices	0	1770432967023	1770432971058	1770432971147	success	100	null
hnax8j3ox7d7tb9ztcc6zowuaa	expiry_notify	0	1770437047405	1770437052844	1770437052850	success	100	null
54jtusssxpnh5ksjibptg3ekkc	expiry_notify	0	1770435067224	1770435072050	1770435072056	success	100	null
roratosakbdhzdydwuteior1yr	expiry_notify	0	1770435727269	1770435732307	1770435732313	success	100	null
z5qw9xih5jycxetbf4yutwh46e	cleanup_desktop_tokens	0	1770436207302	1770436212493	1770436212497	success	100	null
3owwje98u7brd8s1xfnpmrbozo	expiry_notify	0	1770436387329	1770436392563	1770436392569	success	100	null
huwygn45wp8dzp8ipq93ntjrar	expiry_notify	0	1770437707461	1770437713147	1770437713153	success	100	null
sjaqmr6mgt8auxepjtxjjus9rr	product_notices	0	1770436567346	1770436572633	1770436572737	success	100	null
uqwsfwjpppf8xbdjz7eseercfr	expiry_notify	0	1770438367510	1770438373462	1770438373469	success	100	null
ih1g64mbq7ye9x8hxqjram6otr	expiry_notify	0	1770439027584	1770439033764	1770439033766	success	100	null
wimmg4em9trui8gntu3ygcauyw	product_notices	0	1770440167708	1770440174281	1770440174398	success	100	null
eyjq31w87jr7fdbn7fras5btfc	expiry_notify	0	1770439687642	1770439694068	1770439694075	success	100	null
5ww9xebnwpgrugr4eyzu7ra7nh	expiry_notify	0	1770440347722	1770440354378	1770440354384	success	100	null
4jn5wmjtbir5ipjicwydgwc15r	expiry_notify	0	1770442327881	1770442335203	1770442335209	success	100	null
ziywpwx7eirm7puss8fywus73c	expiry_notify	0	1770441007771	1770441014650	1770441014657	success	100	null
sxzuip4phby3td3e6k67toxfha	expiry_notify	0	1770441667827	1770441674884	1770441674888	success	100	null
uhr1wg8q6fdutygjhq7d6pg9ka	expiry_notify	0	1770442987937	1770442995518	1770442995524	success	100	null
w19914fc37noucis573rt9tksr	expiry_notify	0	1770443648009	1770443655800	1770443655802	success	100	null
dp7fc1icqins5nzq71tmmai57r	cleanup_desktop_tokens	0	1770443527997	1770443535739	1770443535742	success	100	null
8dffgc5yc7rmbbwm1kwb3xguih	expiry_notify	0	1770444308075	1770444316067	1770444316072	success	100	null
o7f1hzys978o8dgngaebmqi3kc	product_notices	0	1770443768034	1770443775837	1770443775939	success	100	null
55bc8pmoajr19kjcjya5t493ph	expiry_notify	0	1770444968134	1770444976345	1770444976350	success	100	null
f9ut6k4ikpgcugmq8786b6eqwe	expiry_notify	0	1770445628180	1770445636596	1770445636599	success	100	null
umnsopappjgibpqu5biao86yyo	expiry_notify	0	1770446288232	1770446296858	1770446296862	success	100	null
j31ymg3rpff9jbbhu6hbeazjmy	expiry_notify	0	1770446948282	1770446957200	1770446957206	success	100	null
ui948i95htnupm3kn6tbwjyh4r	cleanup_desktop_tokens	0	1770447188315	1770447197305	1770447197311	success	100	null
547oah3h5jfupe56sk9hyyahsc	product_notices	0	1770447368331	1770447377385	1770447377485	success	100	null
th76wif4bffmmysxx1b7fiewco	expiry_notify	0	1770447608360	1770447617508	1770447617514	success	100	null
pu5bh1dmm3ym9ryib6fw3xaube	expiry_notify	0	1770448268439	1770448277821	1770448277828	success	100	null
fyma5sitjif8zne3d7jajpwica	expiry_notify	0	1770448928503	1770448938150	1770448938157	success	100	null
4hani763njra3cfupbnfefnteh	expiry_notify	0	1770449588561	1770449598495	1770449598500	success	100	null
okouirzspjys5nm4mq1679n19a	expiry_notify	0	1770581360197	1770581373499	1770581373503	success	100	null
bmnuuszpkbgfmbgdpp5sb71dec	product_notices	0	1770382562439	1770382563562	1770382563670	success	100	null
9cdd5y167tbdxm4iokp3csna1o	mobile_session_metadata	0	1770378962113	1770378976748	1770378976755	success	100	null
e5cxo95rbigipp96ikwj5hsgxw	import_delete	0	1770378962108	1770378976749	1770378976755	success	100	null
jh5q1tddytyrbmrj93irof6tjo	plugins	0	1770378962101	1770378976748	1770378976756	success	0	null
rq17im9uq7y7j8pzhhzmqm43ph	install_plugin_notify_admin	0	1770378962105	1770378976748	1770378976757	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
9ff8e1eczffzdfqub68i9imrfc	export_delete	0	1770378962112	1770378976749	1770378976764	success	100	null
zge36e1j7pbgmb5s45j3gokxte	product_notices	0	1770378962110	1770378976749	1770378976854	success	100	null
xs1u8k11fjr3demq8k6n1cdc4c	expiry_notify	0	1770387062809	1770387065535	1770387065540	success	100	null
y9rh16iq3irr9xemxiyg89kgye	expiry_notify	0	1770379142122	1770379156823	1770379156829	success	100	null
7sdqjxuex78r5n49ukqwdi397c	expiry_notify	0	1770383102487	1770383103798	1770383103804	success	100	null
wodm663md3fs7pojnq5fjaxjkr	expiry_notify	0	1770379802175	1770379817135	1770379817142	success	100	null
xixax4o6apf78ki8wyw138t9co	expiry_notify	0	1770380462236	1770380462443	1770380462448	success	100	null
6uhrwr9rq7daujwu6qufmgqsfc	expiry_notify	0	1770381122272	1770381122806	1770381122812	success	100	null
ty3xc7jw3t8f3mp6e5djwwfakr	cleanup_desktop_tokens	0	1770381482298	1770381483000	1770381483006	success	100	null
ey1jgqba1ibsjfph8pquqjg81a	expiry_notify	0	1770383762548	1770383764143	1770383764149	success	100	null
85ij5b8rzf8e8g5ae8x6yhcm7h	expiry_notify	0	1770381782336	1770381783172	1770381783179	success	100	null
gz88kiu4u7rm8fqx1c6btdccuh	expiry_notify	0	1770382442422	1770382443491	1770382443498	success	100	null
5w4axfaxhfbsfnkzykfb9wy4rr	expiry_notify	0	1770384422594	1770384424424	1770384424429	success	100	null
trkxgjucj7b5pgxtdgjxbicico	expiry_notify	0	1770385082651	1770385084709	1770385084715	success	100	null
shtjkaf9538pdbr8ipayyyshba	expiry_notify	0	1770387722864	1770387725862	1770387725866	success	100	null
13zdbqgnkifgxdts1td4wyhk8o	cleanup_desktop_tokens	0	1770385142663	1770385144732	1770385144738	success	100	null
gbgat8mk33bftkgek6o4e1jhfr	expiry_notify	0	1770385742699	1770385744936	1770385744941	success	100	null
zndumpu9jbg3dmxfcd9j3t1x3a	product_notices	0	1770386162741	1770386165111	1770386165212	success	100	null
ha5w9y1hkbn9uq1pr3q6ob6wxo	expiry_notify	0	1770390303114	1770390306933	1770390306939	success	100	null
bf399yrgo3rw3j7k1kyznzd4mr	expiry_notify	0	1770386402762	1770386405221	1770386405227	success	100	null
5bbeajtfbp89pfkxwe77xditdr	expiry_notify	0	1770388322909	1770388326137	1770388326139	success	100	null
k3c5fy5xxifpfknzyr6n1qnikc	cleanup_desktop_tokens	0	1770388802952	1770388806320	1770388806323	success	100	null
7sx1dnxwmp8pupnszusbzt5r4w	expiry_notify	0	1770388982978	1770388986378	1770388986381	success	100	null
uyebjryztt8u7jsqqp8t8e6pqc	expiry_notify	0	1770389643049	1770389646649	1770389646654	success	100	null
19od3ryuaif89bb3mn85rhnf3o	expiry_notify	0	1770390963185	1770390967254	1770390967258	success	100	null
g8gzuhb7n3bqijqb9zpqmpa98c	product_notices	0	1770389763063	1770389766716	1770389766806	success	100	null
ega958c5epnmpeyjsdiqgtk88w	expiry_notify	0	1770392943374	1770392948162	1770392948165	success	100	null
je4xx3m817yutduzii4recas3y	expiry_notify	0	1770391623258	1770391627555	1770391627561	success	100	null
6rtj1czjypdzbctbtfnqz7osgr	expiry_notify	0	1770392283304	1770392287837	1770392287843	success	100	null
i93xb7fumj8hzf165ygjs7w5sc	cleanup_desktop_tokens	0	1770392463318	1770392467905	1770392467910	success	100	null
khop9fab7frp8pjdoccajkcruy	product_notices	0	1770393363429	1770393368347	1770393368450	success	100	null
ne4a3x7y8td33b3cwon44awamr	expiry_notify	0	1770393603464	1770393608485	1770393608488	success	100	null
3cxysayt1brt7dnjqqzzhscwwo	expiry_notify	0	1770394923589	1770394929066	1770394929070	success	100	null
rn4ebohzs3g6ffowubk46bdjay	expiry_notify	0	1770394263543	1770394268792	1770394268799	success	100	null
9b996tfshtdamfuwfpnxb1brso	expiry_notify	0	1770395583614	1770395589302	1770395589310	success	100	null
ieowke5o1tbepbmj766kwicj1w	cleanup_desktop_tokens	0	1770396063666	1770396069549	1770396069554	success	100	null
fq6wf1e56fgdxmsqzs95qaby1c	expiry_notify	0	1770396243684	1770396249655	1770396249660	success	100	null
uaubwk5fdtnembspqfp7gq4otc	expiry_notify	0	1770397563786	1770397570242	1770397570248	success	100	null
zhak6wja7t8gdntx8bkmce8pka	expiry_notify	0	1770396903726	1770396909968	1770396909974	success	100	null
wtq7kdta47nrppwoqwn1cqsfwy	product_notices	0	1770396963741	1770396969990	1770396970111	success	100	null
gk5drndj1tbo7n6xtsnjgj371c	expiry_notify	0	1770398223835	1770398230469	1770398230473	success	100	null
964hmubrztftbywoj8ff5y79oo	expiry_notify	0	1770398883908	1770398890746	1770398890751	success	100	null
546tfgmodpns7f3rgqgmt4hncr	expiry_notify	0	1770399543963	1770399550987	1770399550992	success	100	null
uhmw89a8ofbypx88e7zppstdae	cleanup_desktop_tokens	0	1770399723992	1770399731064	1770399731070	success	100	null
gfmwibymjibzmpq3w8zxdby8na	expiry_notify	0	1770400204058	1770400211267	1770400211273	success	100	null
9wqybfsn1fgn5xq7mcoqeujc8o	product_notices	0	1770400564099	1770400571449	1770400571565	success	100	null
mx3ytknaybdy8fzo4nk5gmrwaw	expiry_notify	0	1770400864136	1770400871616	1770400871620	success	100	null
4f1scky1pifa7eqyk56myxpxgc	expiry_notify	0	1770401524215	1770401531945	1770401531952	success	100	null
19ciajr67idour6f6s7rrqrrpe	product_notices	0	1770512173917	1770512176591	1770512176709	success	100	null
3ywb3crf57f73qdrtck95hszsc	expiry_notify	0	1770402184264	1770402192275	1770402192282	success	100	null
yz3kmsd1tincmypdzu589yh3ry	cleanup_desktop_tokens	0	1770428946617	1770428949218	1770428949223	success	100	null
zteqg977qiruuct3i3m5hc71ie	expiry_notify	0	1770402844326	1770402852560	1770402852568	success	100	null
r4ium4ccifyg8kuktmbto9fp6o	product_notices	0	1770429366664	1770429369374	1770429369477	success	100	null
34j6gj5u4t8i885czf5nzeka7r	cleanup_desktop_tokens	0	1770403384391	1770403392807	1770403392812	success	100	null
wrd5tt8hdjdo8bthhicajcxx1e	expiry_notify	0	1770431766890	1770431770483	1770431770490	success	100	null
5mjf71fr7fn87eob5ushyftngo	expiry_notify	0	1770408004817	1770408014922	1770408014926	success	100	null
r59ha7ibxprhdj48mpighrwbze	expiry_notify	0	1770403444400	1770403452830	1770403452836	success	100	null
qsyuegx49bnqinf5s78eig1b9a	expiry_notify	0	1770404104470	1770404113167	1770404113171	success	100	null
ynwmktp7hfyu9pgyre6hicxnsy	product_notices	0	1770404164487	1770404173202	1770404173305	success	100	null
jco3fo9uhf81pydy85jcgefs1r	expiry_notify	0	1770412625231	1770412636808	1770412636813	success	100	null
euz9rewxhi8jijh33f3b66h7qw	expiry_notify	0	1770404764548	1770404773458	1770404773462	success	100	null
kggs8bddof86bqmux1fm9p8hoh	expiry_notify	0	1770408664861	1770408675160	1770408675165	success	100	null
qypuzgwhobfp5ryrwquf5pf8nw	expiry_notify	0	1770405424580	1770405433749	1770405433755	success	100	null
scrcwmdmdbydddaekxitx75yyo	expiry_notify	0	1770406024640	1770406034034	1770406034039	success	100	null
nu6b443wbfdaurxxtpbsbp7zdy	expiry_notify	0	1770406684707	1770406694329	1770406694333	success	100	null
xmy4dn9jstn13m6y9gom1kxuwa	cleanup_desktop_tokens	0	1770407044734	1770407054491	1770407054496	success	100	null
w8gxd8rjm7n39bt56okuy5f8uw	expiry_notify	0	1770409324933	1770409335434	1770409335441	success	100	null
1iuiw5wniby5de68smt1q8xpge	expiry_notify	0	1770407344753	1770407354637	1770407354644	success	100	null
hyaxdco68bre3m9thbm1afj7ba	product_notices	0	1770407764795	1770407774829	1770407774939	success	100	null
i8gw4xm8xtfupxed3pp419wopw	expiry_notify	0	1770409984996	1770409995743	1770409995747	success	100	null
u87wmdnk1ibp7e79mjm7q6i9ma	expiry_notify	0	1770415925518	1770415938323	1770415938328	success	100	null
1agnppj9e3d4xx4gsgpf313z1a	expiry_notify	0	1770410645058	1770410655984	1770410655990	success	100	null
9dp76x4qwpn1zga4dyeofw64ka	expiry_notify	0	1770413285263	1770413297076	1770413297082	success	100	null
isaidjgca3d1dr66ajjzje3a6y	cleanup_desktop_tokens	0	1770410705066	1770410716019	1770410716025	success	100	null
ciw7oygb4pnpzdxh5xyunt5nyo	expiry_notify	0	1770411305112	1770411316279	1770411316286	success	100	null
3kraq8disjrxzm3t6en7erno6y	product_notices	0	1770411365123	1770411376295	1770411376391	success	100	null
n9xraz75ofdb9j11gyzbjk1mrc	expiry_notify	0	1770411965175	1770411976531	1770411976535	success	100	null
8sadq35rn7gpdpgwdzcystwhby	expiry_notify	0	1770413945330	1770413957384	1770413957389	success	100	null
xmm3i4per7dezr3n9x1z5cxy1y	cleanup_desktop_tokens	0	1770414365372	1770414377576	1770414377581	success	100	null
pdtznhc3gbrbfq9o9kpsahfqgc	expiry_notify	0	1770414605391	1770414617695	1770414617702	success	100	null
1saw77kbaffrjdkfojmbyex7yo	expiry_notify	0	1770416585573	1770416598692	1770416598696	success	100	null
x3qhfrwy3igspyraxbtcxmf49e	product_notices	0	1770414965417	1770414977873	1770414977989	success	100	null
kjqdidztntyn7ktw9doesjtb1e	expiry_notify	0	1770415265451	1770415278007	1770415278012	success	100	null
38ezxh6xzt8p78h87ne7iiq8ya	expiry_notify	0	1770417245590	1770417258944	1770417258952	success	100	null
dkbqdtwoqfdbtgw7iad3w7fdma	expiry_notify	0	1770418565716	1770418579547	1770418579554	success	100	null
hkgo79oqef8s9ygze7g344on4w	expiry_notify	0	1770417905655	1770417919247	1770417919253	success	100	null
7omrj8cdj3btbgfgfbh1zezkna	cleanup_desktop_tokens	0	1770417965666	1770417979275	1770417979281	success	100	null
uniqii6zqfyqikdfsrb4sqtn6c	product_notices	0	1770418565721	1770418579547	1770418579649	success	100	null
14qqke1kr3dtmnojffebe61zpw	expiry_notify	0	1770419225768	1770419239880	1770419239884	success	100	null
86pniuzn4i87zdzc98h4y3f7no	expiry_notify	0	1770420545863	1770420560422	1770420560428	success	100	null
jzg5r8qrnfnntk55tf3c7ww7gh	expiry_notify	0	1770419885825	1770419900153	1770419900160	success	100	null
nbbc8ww4btg3djpojro5ac963h	expiry_notify	0	1770421205922	1770421220717	1770421220723	success	100	null
c9oppsornjbmfdid9xcw8s43uw	cleanup_desktop_tokens	0	1770421625957	1770421640874	1770421640880	success	100	null
8busqndyxty18pcgswu976dbhh	expiry_notify	0	1770421865975	1770421880983	1770421880990	success	100	null
dzo7soo5otfd3f7hchxb4hyzjw	expiry_notify	0	1770422526033	1770422526244	1770422526246	success	100	null
9s74n19ckibzdn3np69qmes1fo	product_notices	0	1770422165998	1770422166096	1770422166201	success	100	null
z6xcxarznfd4jy1iex5yqeufey	refresh_materialized_views	0	1770422406016	1770422406198	1770422406218	success	100	null
sfo9fhp8tbdydc9jtyc7csnyue	expiry_notify	0	1770423186102	1770423186581	1770423186585	success	100	null
96yctmnyotbcjgu9qeqhmfwkie	expiry_notify	0	1770423846170	1770423846849	1770423846852	success	100	null
xwbcjraq1jr5df8wcam9ydnrby	expiry_notify	0	1770424506246	1770424507118	1770424507122	success	100	null
9xmbfkwimibxteeimsknfpfg9e	expiry_notify	0	1770425166291	1770425167425	1770425167431	success	100	null
gfhkh5hem3r1un4t5rcttd6oqa	cleanup_desktop_tokens	0	1770425286310	1770425287484	1770425287491	success	100	null
rzfk83prfprh5qopt8yk55duha	expiry_notify	0	1770986576103	1770986589586	1770986589592	success	100	null
pknys654n3gyjb1f9hgnh6n73h	expiry_notify	0	1770450248632	1770450258824	1770450258831	success	100	null
fdn7dzwrwtgrpk7cw8qnisfi5c	cleanup_desktop_tokens	0	1770450788689	1770450799055	1770450799061	success	100	null
hto4uyf5sj8c7xh99kee3rsmja	expiry_notify	0	1770450908701	1770450919114	1770450919119	success	100	null
1sx7guwfbtdfbb9e794yuqpnnr	expiry_notify	0	1770456189014	1770456201422	1770456201428	success	100	null
apwfu7kg8p8hzgiiq1p1uwdanw	product_notices	0	1770450968715	1770450979139	1770450979253	success	100	null
z6uxb6mzijg1dbdrx4t15d9xtw	expiry_notify	0	1770451568738	1770451579415	1770451579421	success	100	null
7d61ypxtpfd5pru89djknrtx1r	expiry_notify	0	1770452228784	1770452239742	1770452239750	success	100	null
jqwsufu6bpfdxj66tyeutq89hc	expiry_notify	0	1770460749435	1770460762946	1770460762951	success	100	null
kaqmc5wdkjyi9cc8jy65z9gofy	expiry_notify	0	1770452888827	1770452900027	1770452900034	success	100	null
o3m9ni57kjge8yqtyr7rf6dnha	expiry_notify	0	1770456849036	1770456861681	1770456861686	success	100	null
i8yq1nrr9byz9fjqd5tbmtk1bo	expiry_notify	0	1770453548876	1770453560297	1770453560304	success	100	null
jnqmhqd9ttda3mgug6jna4rrzw	expiry_notify	0	1770454208920	1770454220626	1770454220631	success	100	null
fbtmjps77tr3f8q6eieqdyb49c	cleanup_desktop_tokens	0	1770454448931	1770454460727	1770454460732	success	100	null
nkx911o8w788dkwrqt7wycu93h	product_notices	0	1770454568948	1770454580773	1770454580901	success	100	null
7sea61bb1in95etubysawrjodr	expiry_notify	0	1770457509063	1770457521918	1770457521921	success	100	null
xgmqg9fn3pfdbcytf9kmpnid1c	expiry_notify	0	1770454868991	1770454880901	1770454880905	success	100	null
cwgw1xgpkt81pf3gmwd7cunydr	expiry_notify	0	1770455529048	1770455541200	1770455541208	success	100	null
5qge8qm3strj8njbcx557iw7ce	cleanup_desktop_tokens	0	1770458109085	1770458122105	1770458122107	success	100	null
byz31o9nmtyitgdwuqgkrn56dy	expiry_notify	0	1770463989717	1770464004328	1770464004335	success	100	null
jiqdawdjetrwxd6aboj84x8esc	expiry_notify	0	1770458169094	1770458182114	1770458182116	success	100	null
j44wqdkrwtraurhm67ngbhu5ro	expiry_notify	0	1770461409474	1770461423136	1770461423141	success	100	null
t4pxixbc1fntzr1dfoxz3nta7c	product_notices	0	1770458169090	1770458182114	1770458182224	success	100	null
e3qpntktctr4bnj5uongku6y6c	expiry_notify	0	1770458829119	1770458842228	1770458842231	success	100	null
thr1n1yey7gdip1iqj84hyegno	expiry_notify	0	1770459429326	1770459442545	1770459442549	success	100	null
rnwmut48bt888nzbyj8rxfs9yw	expiry_notify	0	1770460089381	1770460102751	1770460102754	success	100	null
a88aj9a9affdmmz1a166ffuhir	cleanup_desktop_tokens	0	1770461769503	1770461783246	1770461783250	success	100	null
bt8djyx6h3fndywubmrugati6y	product_notices	0	1770461769508	1770461783246	1770461783347	success	100	null
r8pfthnbub8m8bcodowo4fd4zy	expiry_notify	0	1770462009540	1770462023360	1770462023367	success	100	null
54gh13ji3tgwuqzpcqsj83m7se	expiry_notify	0	1770464649744	1770464664647	1770464664651	success	100	null
to8yuau74fdiic94neyzswj5ra	expiry_notify	0	1770462669597	1770462683669	1770462683673	success	100	null
p5de4cwcgfnc8x3ak7srk7635c	expiry_notify	0	1770463329642	1770463343977	1770463343983	success	100	null
ii4orou3ybd1xebkzic4o5m3ph	expiry_notify	0	1770465309788	1770465309947	1770465309953	success	100	null
4ubor3ce9tgompnpxm3wi79yne	plugins	0	1770465369801	1770465369982	1770465369988	success	0	null
5eysqs38kbb538c63otq8esxch	install_plugin_notify_admin	0	1770465369792	1770465369983	1770465369991	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
hynq91pph3yitbqqzhh5y7zeiw	export_delete	0	1770465369799	1770465369983	1770465369999	success	100	null
mjmyhrjtg78gpddaumuubnhkia	import_delete	0	1770465369795	1770465369983	1770465370000	success	100	null
hi7tedxxefd9mrewuzmzdh64ne	expiry_notify	0	1770466629903	1770466630442	1770466630445	success	100	null
gqpdqw8ustrd7ykaafi1bw6k6o	mobile_session_metadata	0	1770465369799	1770465369983	1770465370001	success	100	null
mbufom9g13r89ci48ggp7ki61a	cleanup_desktop_tokens	0	1770465429804	1770465430007	1770465430012	success	100	null
w16g1hm1zpgwjxyqjzohjwrqmy	product_notices	0	1770465369798	1770465369984	1770465370088	success	100	null
37sp5fwdqfns7c8yt9uax14p5h	expiry_notify	0	1770465969851	1770465970209	1770465970213	success	100	null
n3eubc9ee3bi8keryjntchtxxa	expiry_notify	0	1770467289967	1770467290724	1770467290730	success	100	null
6616dd1ibpbdpc7xxr6zpewggh	product_notices	0	1770468970106	1770468971533	1770468971645	success	100	null
gtdeksjtqbgptkjjntk1pku7xr	expiry_notify	0	1770467950010	1770467951049	1770467951053	success	100	null
tjtnpxteofbedy9mzckndkp3rw	expiry_notify	0	1770468610067	1770468611362	1770468611368	success	100	null
pyx5gz5xstycmrk7bipxe7bj4a	cleanup_desktop_tokens	0	1770469030121	1770469031572	1770469031576	success	100	null
q94uym6zmtnqff48y89xkg7duo	expiry_notify	0	1770469270143	1770469271678	1770469271684	success	100	null
6mgp6rigp38x5xzwop8o3x8b5a	expiry_notify	0	1770469930198	1770469931992	1770469931999	success	100	null
fzpn6ffk3tb3jnw6hnw3o7ttuy	expiry_notify	0	1770470590230	1770470592325	1770470592332	success	100	null
exaoyzb6eigiibyi15xk74s5go	expiry_notify	0	1770471250291	1770471252644	1770471252648	success	100	null
uq5986yzmib3ins5ufcagytzih	expiry_notify	0	1770471910349	1770471912940	1770471912944	success	100	null
ykabywuctjdnjyshuqxx3dckhc	product_notices	0	1770472570403	1770472573250	1770472573353	success	100	null
squpibaadbd87dwtg8htgc7fyw	cleanup_desktop_tokens	0	1770472690387	1770472693275	1770472693280	success	100	null
aznd8qyzjbbpfdr1qebnkpjdoe	cleanup_desktop_tokens	0	1770655286654	1770655297205	1770655297211	success	100	null
8s3xajzb33r33fq84y95mq3xke	expiry_notify	0	1770472570398	1770472573251	1770472573257	success	100	null
9jpxtz98w3gm5r1o3p6i5wnqyo	expiry_notify	0	1770512773959	1770512776875	1770512776882	success	100	null
fn1341i7hbniiqiok63qo7cxde	expiry_notify	0	1770473230442	1770473233530	1770473233535	success	100	null
pux7sf6bqpfpf8broyf8gm57nr	expiry_notify	0	1770473890496	1770473893862	1770473893867	success	100	null
6abf63x1dprpzxphxbr4dad5pw	expiry_notify	0	1770474550562	1770474554171	1770474554177	success	100	null
k1iw1nuo6pbzbytwxdenqzjkdc	expiry_notify	0	1770475210633	1770475214461	1770475214465	success	100	null
ytxy598cypg198o561r6rs6mzh	expiry_notify	0	1770479771046	1770479776548	1770479776554	success	100	null
7w14hdb9ztdhmnmx63uur9t6ic	expiry_notify	0	1770475870667	1770475874739	1770475874743	success	100	null
bnagjb5srbyo3mi77gz6ertrcy	cleanup_desktop_tokens	0	1770483671388	1770483678401	1770483678406	success	100	null
hse8ia4hutd6xxrmbnbjozodpc	product_notices	0	1770476170685	1770476174851	1770476174980	success	100	null
4skq8j7petnhtroqh9qedi7e5y	product_notices	0	1770479771052	1770479776548	1770479776636	success	100	null
i7en3m641p8ztrpd6mfu8cmw3w	cleanup_desktop_tokens	0	1770476350708	1770476354943	1770476354947	success	100	null
di6nuikyut8rpmuoxyi4qhx4xo	expiry_notify	0	1770476530717	1770476534994	1770476534999	success	100	null
tfacmqctyjf98yeq6rri9fo5pw	expiry_notify	0	1770477130791	1770477135262	1770477135268	success	100	null
kqssg11w4tnxzy6w1wot48scke	expiry_notify	0	1770477790838	1770477795602	1770477795608	success	100	null
yyfcyy746jdd7d5wxfifpryi8e	cleanup_desktop_tokens	0	1770480011077	1770480016652	1770480016658	success	100	null
bz3kfywf7jn6fq97ppqgkox87w	expiry_notify	0	1770478450903	1770478455884	1770478455891	success	100	null
mpi8hwddhtgupcrasj3x5q3bsy	expiry_notify	0	1770479110973	1770479116208	1770479116216	success	100	null
whjpaybkg3rf98e5q8tdff1toe	expiry_notify	0	1770480431134	1770480436826	1770480436832	success	100	null
fhz4rn3phinebyanczpzk5ex5r	expiry_notify	0	1770487031699	1770487040000	1770487040005	success	100	null
7g1afs911ibfzq31k74mtwjmny	expiry_notify	0	1770481091170	1770481097129	1770481097136	success	100	null
ko5yqed9abdeffng5zfzj66m3o	expiry_notify	0	1770483731402	1770483738429	1770483738434	success	100	null
s8akskkz7pgs8miteggei487ia	expiry_notify	0	1770481751203	1770481757478	1770481757483	success	100	null
p7jgrqeo8jyd985fr36kesma4c	expiry_notify	0	1770482411258	1770482417792	1770482417799	success	100	null
iu3zmub7ipgzu85x6rq9e588mo	expiry_notify	0	1770483071324	1770483078122	1770483078128	success	100	null
195mubzfcbntim7ufx99ponrmh	product_notices	0	1770483371356	1770483378254	1770483378370	success	100	null
9ddabo78k3r89jk3edftduwpnh	expiry_notify	0	1770484391457	1770484398763	1770484398768	success	100	null
mbmsqnzc57d9m8wdnk3913bnfy	expiry_notify	0	1770485051508	1770485059043	1770485059047	success	100	null
nibdo3trstbemfy4ejkxh3d3wr	expiry_notify	0	1770489671913	1770489681245	1770489681252	success	100	null
9igtexh4jbggpjdhzxntyq98je	expiry_notify	0	1770485711564	1770485719376	1770485719382	success	100	null
we7d3efeg7r8pqe19fpuwrk88e	cleanup_desktop_tokens	0	1770487331727	1770487340158	1770487340163	success	100	null
r1pf77rj9jf3xqjt8onsquhiuh	expiry_notify	0	1770486371626	1770486379691	1770486379698	success	100	null
w4jdw6jzsibqfcbfqxgfjmhooy	product_notices	0	1770486971690	1770486979977	1770486980098	success	100	null
bjhb1tnbhbf4truh57or4qe6kc	expiry_notify	0	1770487691759	1770487700313	1770487700319	success	100	null
sos7bjtfhpy8d8eudz6buc4yta	expiry_notify	0	1770488351822	1770488360598	1770488360603	success	100	null
j56tepfz83dbpkcgi9z1wmywuh	expiry_notify	0	1770489011863	1770489020901	1770489020906	success	100	null
mdrgk5tgw7g7pf9b9p7bumxiyo	expiry_notify	0	1770490331971	1770490341541	1770490341546	success	100	null
aega9a3fujbj3k6dgiyudyi16w	cleanup_desktop_tokens	0	1770490992026	1770491001811	1770491001827	success	100	null
ac56xikkzfnwp8aghygq9nsrfy	product_notices	0	1770490571985	1770490581649	1770490581759	success	100	null
qkisjm3sbp8bmqe87tuqpkaxjy	expiry_notify	0	1770490992031	1770491001811	1770491001819	success	100	null
88jpkrfgepfrmc1dh3x5ccm35c	expiry_notify	0	1770491652094	1770491662130	1770491662136	success	100	null
txynyxxxb7bm3gozydgybu3xww	expiry_notify	0	1770492312153	1770492322449	1770492322456	success	100	null
y188ijy4tty6ufosfxxt8xyzuc	expiry_notify	0	1770492972203	1770492982789	1770492982797	success	100	null
rdbjfe9qtpfuicbxsbe1axfitr	expiry_notify	0	1770494292308	1770494303444	1770494303449	success	100	null
mux47uyjdtn8pr3rocsnm4reba	expiry_notify	0	1770493632239	1770493643129	1770493643134	success	100	null
7sos83znifgafxepgqye46jazc	product_notices	0	1770494172293	1770494183379	1770494183505	success	100	null
4ht59y5xj7d73jfx5htpdn6jdr	cleanup_desktop_tokens	0	1770494592343	1770494603565	1770494603571	success	100	null
p5upucron3fbujd141mc95r5kc	expiry_notify	0	1770494952356	1770494963702	1770494963708	success	100	null
fbukfcs38tbyufjucfy4beiube	expiry_notify	0	1770495612428	1770495624026	1770495624033	success	100	null
oidedztnzfdmpynbtcrfuxk9qy	expiry_notify	0	1770496272470	1770496284372	1770496284377	success	100	null
okejnfx8dfguuyogcndf8x3ksa	expiry_notify	0	1770496932518	1770496944699	1770496944706	success	100	null
bnk4zhacgin3dbdpzf8taq41bh	expiry_notify	0	1770497592591	1770497604997	1770497605001	success	100	null
pmr69g8m53gnzyto6uqywhr4oo	product_notices	0	1770497772615	1770497785085	1770497785198	success	100	null
yi1ytabbzif7jn95z1kwmdwwpw	product_notices	0	1771142230604	1771142241955	1771142242080	success	100	null
bqjcgrgfr7ni8n5r7u5up5icdh	expiry_notify	0	1770582020254	1770582033828	1770582033834	success	100	null
z31yjj7dsfnfin7n7zizzihqhe	cleanup_desktop_tokens	0	1770498252650	1770498265334	1770498265340	success	100	null
37z5kx7ojtdk7qswfy3rp4967a	cleanup_desktop_tokens	0	1770512893981	1770512896941	1770512896946	success	100	null
4go1qufzxbgfzcguswq8n9dfno	expiry_notify	0	1770931431119	1770931439526	1770931439532	success	100	null
n8zei7pa83bizmr8djwgfc78mh	product_notices	0	1770742594052	1770742607368	1770742607490	success	100	null
ifhsx78q9idz8eu1g79x5z6h9y	expiry_notify	0	1770498912676	1770498925657	1770498925662	success	100	null
h6om8nykitf8zdgocb4qac848c	expiry_notify	0	1770655706672	1770655717418	1770655717422	success	100	null
9jkaq4rz3jgjxdeyds94wht5po	expiry_notify	0	1770513434034	1770513437207	1770513437213	success	100	null
tyd6wdbaufrxfb6fkgeqrjbnwe	expiry_notify	0	1770583340352	1770583354472	1770583354476	success	100	null
fzeit67o7pdyxekernqporrocw	expiry_notify	0	1770854384054	1770854393916	1770854393921	success	100	null
zz17uh6rffga5j4u71a73qnr6a	expiry_notify	0	1770514094062	1770514097508	1770514097513	success	100	null
4a9cyazuo3ndmkmfk7sufype9y	expiry_notify	0	1770607042358	1770607050612	1770607050619	success	100	null
jeops84aspyg5yfz63uqcg5fte	expiry_notify	0	1770657686591	1770657698096	1770657698104	success	100	null
5473swp6tjbsfysowzd7s5m64e	expiry_notify	0	1770514754112	1770514757804	1770514757807	success	100	null
rb88i8inzpgf9rygjqdgp4zzuc	expiry_notify	0	1770743254098	1770743267729	1770743267734	success	100	null
aju3emgh5fn6m8cd53tiefrt3w	expiry_notify	0	1770987236170	1770987249903	1770987249906	success	100	null
an8hjcdox7rhfmy7s4grbkzcaa	expiry_notify	0	1770536536171	1770536548085	1770536548091	success	100	null
9i4tfht5ci83zr1u5rg6em61qa	cleanup_desktop_tokens	0	1770629784439	1770629785712	1770629785716	success	100	null
tb35ti73qid8xc3wnzb4yxtx4h	expiry_notify	0	1770876766131	1770876769448	1770876769454	success	100	null
p9jqea7d1iydfe1a5efri8x6ce	expiry_notify	0	1770682708872	1770682714844	1770682714850	success	100	null
hag954ifgigstdp1bbjwsentyh	expiry_notify	0	1770537196231	1770537208421	1770537208426	success	100	null
gtm7y1prmtgx5k18u3g4zzu5sy	product_notices	0	1770764195884	1770764202155	1770764202258	success	100	null
48yemkhkqpybdps1sprb8r1mch	expiry_notify	0	1770537856296	1770537868742	1770537868747	success	100	null
fub688r6ityuundunqb4hfeu7c	cleanup_desktop_tokens	0	1770702750581	1770702764346	1770702764351	success	100	null
6h7e15c6xjd6trngs1xpxgq65y	expiry_notify	0	1771002357557	1771002362051	1771002362057	success	100	null
xieqmch8mbg9frcafhbdkfjsxe	expiry_notify	0	1770906408753	1770906422672	1770906422678	success	100	null
f45ocd5f1pbgmehzy3seo7pxdh	cleanup_desktop_tokens	0	1770538456361	1770538469075	1770538469081	success	100	null
ckch8jtsnfbczbi6fgz4i69j3e	expiry_notify	0	1770764315896	1770764322222	1770764322229	success	100	null
1hc8r7hbztd1bxgredwe7w9pko	cleanup_desktop_tokens	0	1770724652435	1770724659210	1770724659215	success	100	null
woqbx89w6bf68e113xhw8cgcje	expiry_notify	0	1770538516369	1770538529112	1770538529118	success	100	null
4ginfj3x7bd15r7d5eipi87pwa	expiry_notify	0	1771003017638	1771003022414	1771003022418	success	100	null
c4h77resjfboxgubsobi6rr3aa	expiry_notify	0	1770787958165	1770787973089	1770787973095	success	100	null
wm751razsjgafdd7xyhkcdcefe	expiry_notify	0	1770539176429	1770539189438	1770539189443	success	100	null
yotn4hbsitr73p6wgwggyxb94a	expiry_notify	0	1770957113504	1770957116472	1770957116476	success	100	null
cizkqrd6938q8e4dmb3qmp7zie	expiry_notify	0	1770563598602	1770563605304	1770563605307	success	100	null
78kc6hbgft8bikb4586wokp5xh	expiry_notify	0	1770810280143	1770810288024	1770810288030	success	100	null
jphk5mq333n7fcom51g6as8cxw	expiry_notify	0	1771003677681	1771003682801	1771003682806	success	100	null
3wrmaijmj7rkidtouewi5dappr	cleanup_desktop_tokens	0	1770958253598	1770958256982	1770958256986	success	100	null
hkpnu687tpdu5deuym6dyoqowr	mobile_session_metadata	0	1770811000245	1770811008436	1770811008444	success	100	null
gux1s61t73d19k7r8izhukw4za	expiry_notify	0	1770810940205	1770810948392	1770810948397	success	100	null
4yzm4pp1rjb9zk87t45x4h6tqe	expiry_notify	0	1770957713553	1770957716724	1770957716728	success	100	null
ad5zc3ytg3f5pkr68cwo96m4ja	plugins	0	1770811000234	1770811008436	1770811008445	success	0	null
kfzo51dcebr1zen565dqoxtexe	expiry_notify	0	1771004337750	1771004343139	1771004343144	success	100	null
it977kqetfy3bkb6mtfacgit1y	expiry_notify	0	1770958373638	1770958377086	1770958377090	success	100	null
4fg9od8nkibu5px9kqgyb9ctqy	product_notices	0	1770958613649	1770958617194	1770958617317	success	100	null
jy5w1sdcdtb13ch1rzzw8afbya	expiry_notify	0	1771016879005	1771016889001	1771016889008	success	100	null
1rygeihxnpnefmniurukirde3r	export_delete	0	1770811000244	1770811008437	1770811008453	success	100	null
yu8u4xmhqbdeifbp8sqczpmh9e	import_delete	0	1770811000240	1770811008437	1770811008453	success	100	null
ditbapj1tbfpje6f34o4a93wgh	install_plugin_notify_admin	0	1770811000238	1770811008436	1770811008456	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
93gkag6pppfiumb7n59x93gyzo	expiry_notify	0	1770833322114	1770833323732	1770833323739	success	100	null
qutw4ywqafydpqq5xcnwijbjkh	product_notices	0	1770811000242	1770811008437	1770811008527	success	100	null
o5xrxkb4ptfcpedy8nck47y4cw	expiry_notify	0	1770977995272	1770978005479	1770978005485	success	100	null
dgtyhtoztbgair91y8hzaigfdw	expiry_notify	0	1770853063946	1770853073204	1770853073211	success	100	null
nh69158qp7ftxeh5fy1c8f8z9y	expiry_notify	0	1771028760035	1771028774326	1771028774333	success	100	null
4zij3caxgib9d8jedmtegjaz9r	expiry_notify	0	1771031400341	1771031400489	1771031400493	success	100	null
9neadic7j3rixfjm6qeyoegsqa	expiry_notify	0	1771315089774	1771315096134	1771315096140	success	100	null
rj8bcbzji7bptkaorpgp8etjze	product_notices	0	1770656186693	1770656197643	1770656197750	success	100	null
3tyyqfynrfnm7kgz9ubxwyhjxr	expiry_notify	0	1770499572732	1770499585926	1770499585929	success	100	null
g4hiwhcgbifq3cumh1k6iar8fh	expiry_notify	0	1770515414157	1770515418123	1770515418130	success	100	null
p3b8oeqwc7guif5s8dj19sne8c	cleanup_desktop_tokens	0	1770582380282	1770582394047	1770582394053	success	100	null
uhkjmsm4htr37jy5ujiazq7f6r	expiry_notify	0	1770742594048	1770742607369	1770742607376	success	100	null
8sf1gjj8otnjpgfzj598ga96zy	cleanup_desktop_tokens	0	1770516554271	1770516558735	1770516558741	success	100	null
9zsgwyx9cjyoxpp1w1fuatc55o	refresh_materialized_views	0	1770854444067	1770854453942	1770854453965	success	100	null
hsmw1hkr9jd8mer7od8r7wu1ur	expiry_notify	0	1770582680308	1770582694189	1770582694194	success	100	null
ekc4c8eaj3gcure857ehdisi7w	expiry_notify	0	1770656366708	1770656377734	1770656377740	success	100	null
yyp1q57dd3yomp1eenq94dh49c	product_notices	0	1770537376250	1770537388526	1770537388638	success	100	null
ksigx3zdcid1pk3cug9m1ooahe	cleanup_desktop_tokens	0	1770742954075	1770742967583	1770742967588	success	100	null
f7oq9smgptr1t8a97ik6gkqbyo	expiry_notify	0	1770584660481	1770584675066	1770584675071	success	100	null
78xpg1tk7jd4udnbo8mh5fzjeh	cleanup_desktop_tokens	0	1770564078642	1770564085560	1770564085564	success	100	null
fnf5mhr9jbfrddt8ukd3pb8inr	expiry_notify	0	1770657026747	1770657038045	1770657038050	success	100	null
i8q488i4sbrq5qu8z4kmyaki3c	expiry_notify	0	1770564258673	1770564265646	1770564265652	success	100	null
ycner8spspr1tk41zodoaj5fjr	expiry_notify	0	1770607702405	1770607710915	1770607710922	success	100	null
4syi5yeh1jdtuemkewjim46huw	expiry_notify	0	1770789218313	1770789218648	1770789218651	success	100	null
63tgaekorbdaixupcjwu3p9xxc	expiry_notify	0	1770765576037	1770765582884	1770765582890	success	100	null
59md3spg8pfq3bapjbij8wph8r	expiry_notify	0	1770683368897	1770683375156	1770683375162	success	100	null
atcyztfhf3d85y6tyquky5d68e	cleanup_desktop_tokens	0	1770607942425	1770607951043	1770607951049	success	100	null
nsmw4nph4t8iujwzsk34cepb3r	expiry_notify	0	1770878746309	1770878750347	1770878750353	success	100	null
eq6rojxy97rkpqz7tqot53ngnh	expiry_notify	0	1770608362450	1770608371244	1770608371249	success	100	null
growqcr1yib53fi1awxg57bs8c	expiry_notify	0	1770684028942	1770684035483	1770684035487	success	100	null
efxpua4ei3yrzjcnh3f75ku3ne	expiry_notify	0	1770766236086	1770766243180	1770766243185	success	100	null
zbbxcnn6offopqw5myta5yojyy	expiry_notify	0	1770631344569	1770631346339	1770631346345	success	100	null
sq6sz1hcaf8n7xk7ugcparnr9r	expiry_notify	0	1770879406353	1770879410561	1770879410564	success	100	null
nbod9unqminx8e7q9z7cemxkhr	product_notices	0	1770702990623	1770703004470	1770703004584	success	100	null
e58zh3gi7tnpmbwtjweh4ob5ke	cleanup_desktop_tokens	0	1770907308853	1770907323117	1770907323122	success	100	null
ixk81fg6mtbkupkpobrbxgxp6r	expiry_notify	0	1770632664666	1770632666853	1770632666857	success	100	null
drd61cn9kfg7jbe8sgimgjmu8h	expiry_notify	0	1770767556222	1770767563760	1770767563762	success	100	null
mgqa8smp47n6bfz1xunugd4jnc	product_notices	0	1770879406358	1770879410561	1770879410641	success	100	null
fe5du1ph9irti8j9hdqc5cnpsh	expiry_notify	0	1770703110633	1770703124530	1770703124536	success	100	null
7wdjiry5h7yt3jxs5cub49b3fh	expiry_notify	0	1770633324723	1770633327179	1770633327183	success	100	null
wugp83zw8ibcxfuyjp1hsaa6uw	expiry_notify	0	1770907008818	1770907022950	1770907022956	success	100	null
4fh74x1r73rrxyobsenhzhuxeo	product_notices	0	1770767796246	1770767803819	1770767803899	success	100	null
yiucfkrer7do5d6ygthukoftac	cleanup_desktop_tokens	0	1770633444744	1770633447235	1770633447239	success	100	null
a7hkgfxk1pgm7ct1o8qcftuzqo	expiry_notify	0	1770724892461	1770724899309	1770724899315	success	100	null
oipeww1dnfr6mm48n3kjmfw5cr	product_notices	0	1770789398340	1770789398720	1770789398829	success	100	null
7j4hakmspigf9gcgjpooh7ap5c	expiry_notify	0	1770788618252	1770788618375	1770788618381	success	100	null
rgwrtisdstb55eec3wx5bts1no	expiry_notify	0	1770833982176	1770833984063	1770833984069	success	100	null
93xw8188cpds8du8f55bbtw7cy	expiry_notify	0	1770790538461	1770790539221	1770790539226	success	100	null
k85jsh5acfnuiyuan8af7p6ifc	expiry_notify	0	1770907668886	1770907683294	1770907683300	success	100	null
u86ricrc6byb8mwgy3wu7fxnxr	expiry_notify	0	1770791198506	1770791199499	1770791199503	success	100	null
1wwcmq7p7tyo5rdhbg8o4osmgy	product_notices	0	1770908208915	1770908223557	1770908223678	success	100	null
onypjqd8nfbxmprhtxd7ooukmh	expiry_notify	0	1770811600312	1770811608686	1770811608692	success	100	null
hcz8gmgdg78tuee8n3b6u4n81c	expiry_notify	0	1770908328933	1770908343610	1770908343615	success	100	null
kzetrfiw7781pbetz81k3jj94a	expiry_notify	0	1770834642241	1770834644382	1770834644386	success	100	null
dmyu3nptq38kmgzazn43zqmbpo	expiry_notify	0	1770932091183	1770932099821	1770932099828	success	100	null
3afha3wzyfydbkfwiiz43r8qqy	expiry_notify	0	1770835962347	1770835965007	1770835965012	success	100	null
yn54auwdsffp58jxwtp7j1ys3h	expiry_notify	0	1770959033690	1770959037393	1770959037400	success	100	null
byhny9mxtffzfyygbo5ic47ieo	expiry_notify	0	1770853724002	1770853733572	1770853733578	success	100	null
ygo6u853gi8ide87c7hw1w1cce	product_notices	0	1770836202383	1770836205133	1770836205231	success	100	null
rhcpct9en3rkuktggmyy8pd54y	expiry_notify	0	1770959693769	1770959697699	1770959697704	success	100	null
83n767j8sbgepds9dyz1eseqya	expiry_notify	0	1770960353837	1770960358020	1770960358024	success	100	null
f73a84wy9inube4wjwa365tz3o	expiry_notify	0	1770978655351	1770978665813	1770978665820	success	100	null
q5gsm8uehtf33pqjdu3e1p57kh	expiry_notify	0	1770725552524	1770725559582	1770725559586	success	100	null
nrjrjixk3br6dqio7jzg9koouy	expiry_notify	0	1770500232791	1770500246228	1770500246231	success	100	null
uzpktktmqpb5bgm6hxa7wdeztr	product_notices	0	1770515774222	1770515778338	1770515778462	success	100	null
jiju9jqxxtr93p7eaak49xqmqa	expiry_notify	0	1770584000405	1770584014796	1770584014803	success	100	null
kz94yc5yjbfmtcjc9dgih9ywew	expiry_notify	0	1770658346648	1770658358430	1770658358437	success	100	null
s1oxcqfnk787xchrjjbq9wbarc	product_notices	0	1770501372821	1770501386599	1770501386710	success	100	null
s1s6h91pkjfazrqseqhgcx5eby	expiry_notify	0	1770516074253	1770516078490	1770516078496	success	100	null
1iwc3kd8rpd85d7rot3dzo7h7c	expiry_notify	0	1770743914151	1770743928048	1770743928054	success	100	null
waipwkm57ibhdnf1c846mzs49e	expiry_notify	0	1770501552832	1770501566646	1770501566652	success	100	null
po5c51ubkpyo8r3ppqt3zgpg1w	product_notices	0	1770584180435	1770584194867	1770584194980	success	100	null
ibopwtr76byop8uwkgt6pd84pw	expiry_notify	0	1770855044140	1770855054243	1770855054248	success	100	null
bmis8dn4miyhjdadr93cabf7rw	expiry_notify	0	1770516734300	1770516738846	1770516738851	success	100	null
bfw3bwbi4tgftf6bai4gr8wcph	expiry_notify	0	1770502212885	1770502226938	1770502226941	success	100	null
9cqz6nx73bbc8qr6z8e67yufao	cleanup_desktop_tokens	0	1770658946685	1770658958723	1770658958728	success	100	null
cwiep1xdo3gs9g8ro5rqubbwko	expiry_notify	0	1770609022507	1770609031597	1770609031606	success	100	null
rthpzroyu3dyxdtr8q78p9donh	expiry_notify	0	1770502872948	1770502887251	1770502887257	success	100	null
93gbb8rwfbg4mm55rq861fw17c	expiry_notify	0	1770539836475	1770539849805	1770539849812	success	100	null
ygnwdjhkb3gu98rncm45fqorhh	expiry_notify	0	1770745894319	1770745909065	1770745909070	success	100	null
kuo7ztdohirtxegt4h3z9ychry	expiry_notify	0	1770503533069	1770503547609	1770503547611	success	100	null
g77qbfkm6prgpkjainr7wxy6sa	expiry_notify	0	1770659006692	1770659018755	1770659018760	success	100	null
e5iewftirbga8ggfpsnsxz3u6r	expiry_notify	0	1770541816647	1770541830692	1770541830694	success	100	null
mk4jdg4scfni5g94uks8bd55cw	expiry_notify	0	1770609622581	1770609631798	1770609631805	success	100	null
mfnkyqqaxf8tjcmf8ej5i41mno	expiry_notify	0	1770857024325	1770857035161	1770857035166	success	100	null
zfe3ahg8gpbkf8f6xy5uy6izqw	expiry_notify	0	1770855704204	1770855714530	1770855714535	success	100	null
ykp7cxfjmtdffg78d93dbfijfc	expiry_notify	0	1770564918738	1770564925926	1770564925932	success	100	null
wdb39pihrjnmir6p8gsai44zkh	cleanup_desktop_tokens	0	1770790418451	1770790419183	1770790419188	success	100	null
q4m9cqmhnfd7iph3xpgw5xs7fy	expiry_notify	0	1770632004610	1770632006587	1770632006593	success	100	null
5hpp1adtjjyzzqeb5993g41txe	expiry_notify	0	1770659666971	1770659679279	1770659679284	success	100	null
7ecfc9hybiry8e3whidiyio1sa	expiry_notify	0	1770746494362	1770746494375	1770746494377	success	100	null
ow7oi5a317gtxbakrm7zqcu3ca	expiry_notify	0	1770726212558	1770726219875	1770726219879	success	100	null
kwfu5fzke7fj5got5b7bub7wya	expiry_notify	0	1770684689022	1770684695770	1770684695776	success	100	null
7bibdx8gzbrstdw9ximqt7pubh	cleanup_desktop_tokens	0	1770746614370	1770746614447	1770746614450	success	100	null
k3qrjazoubgbxkau1qqknbjebh	expiry_notify	0	1770685349086	1770685356119	1770685356123	success	100	null
ssfkefhrmfgczf7738w4f3dq8y	expiry_notify	0	1770856364262	1770856374845	1770856374849	success	100	null
er4yysqoiib65pnx48zp7myfte	expiry_notify	0	1770703770685	1770703784872	1770703784878	success	100	null
q4n3ejn9sig9imq4kwwkzoyado	expiry_notify	0	1770766896150	1770766903493	1770766903497	success	100	null
ttm7ynqj33gzdcpx3tf97c1u8e	expiry_notify	0	1770704430728	1770704445144	1770704445146	success	100	null
un7cx3bjj7ybukckiewie4udur	cleanup_desktop_tokens	0	1770834222210	1770834224175	1770834224181	success	100	null
c5637b6ua7819rsukzca3qdugw	expiry_notify	0	1770789878408	1770789878961	1770789878967	success	100	null
ie8em4q7upr55qxne6useoutto	expiry_notify	0	1770880066416	1770880070854	1770880070860	success	100	null
1ekpy9zngiyypm3hf5hz4wzsoh	expiry_notify	0	1770812260362	1770812268965	1770812268969	success	100	null
9qufcto37jbhtpjf6qrd6iufhy	cleanup_desktop_tokens	0	1770812320374	1770812328984	1770812328989	success	100	null
sp5kgiueafgymchou8ixis7n4w	expiry_notify	0	1770880726463	1770880731147	1770880731152	success	100	null
w8bedcjtu7fou8qgcbkcdcf91h	expiry_notify	0	1770908989005	1770909003945	1770909003951	success	100	null
zcqww8a1q3bsje3h61fzs7ohty	expiry_notify	0	1770813580446	1770813589480	1770813589485	success	100	null
nt4rxe37einaiemwty3cw5iwoa	expiry_notify	0	1770909649080	1770909649224	1770909649230	success	100	null
8ruikhg9girnzgpuyhzn37z3sy	expiry_notify	0	1770910969240	1770910969906	1770910969913	success	100	null
fmzx669763rztkkdw6pkb6w54o	cleanup_desktop_tokens	0	1770910969234	1770910969907	1770910969913	success	100	null
7nw8jnjjcpgwikexn9mgotdnce	expiry_notify	0	1770911629303	1770911630187	1770911630190	success	100	null
5qtco9qk6bdc9dydzzn6n7665h	product_notices	0	1770911809324	1770911810287	1770911810391	success	100	null
oefdh6jdxtff9jbmzy1c9fxs3r	expiry_notify	0	1770932751242	1770932760138	1770932760144	success	100	null
z4muu59b6fru3n7sqa5utz6rgw	cleanup_desktop_tokens	0	1770932751237	1770932760138	1770932760143	success	100	null
p6m98kzt9tnttm31rtsb5zyx1e	expiry_notify	0	1770961013897	1770961018345	1770961018352	success	100	null
mdaxgjam5jy5zd3rd1kgp4tuzw	expiry_notify	0	1770961673949	1770961678639	1770961678644	success	100	null
8dmpkspmgbyj3enii7cn3q53je	product_notices	0	1770962214011	1770962218914	1770962219032	success	100	null
mpi97cthsbn3pxrdtqjpxmms9a	product_notices	0	1770987416187	1770987429981	1770987430040	success	100	null
p17yn965ktyj3gdhpeh7bmhzwr	expiry_notify	0	1771142650660	1771142662181	1771142662188	success	100	null
rbbqk48wq7bcxdgye8kgo1xfua	expiry_notify	0	1770500892849	1770500906469	1770500906472	success	100	null
ja6cyz76u3frxkmf6uqz19ppba	expiry_notify	0	1770517394346	1770517399192	1770517399196	success	100	null
11qboi7bnffeipig7guobwws8y	expiry_notify	0	1770585320505	1770585335315	1770585335322	success	100	null
m85osdigdpdmxjbbbsrhcmcyyy	product_notices	0	1770659786998	1770659799362	1770659799476	success	100	null
tqrf9tb93tyut86pcmk765daxy	expiry_notify	0	1770744574198	1770744588430	1770744588436	success	100	null
iszxxcd7abrhdpgs6wqb95h74c	expiry_notify	0	1770518054420	1770518059491	1770518059495	success	100	null
5s4st4tpopd69bskw7zk9b8bdo	cleanup_desktop_tokens	0	1770856184238	1770856194771	1770856194776	success	100	null
3wezc3gmcjyjxprrurf99t6y3w	expiry_notify	0	1770585980535	1770585980582	1770585980584	success	100	null
1bsw7318y7b3igrf3tdaj1zkga	expiry_notify	0	1770660327039	1770660339614	1770660339621	success	100	null
wd4skrjb8jro8m7pyuadz1xhwy	cleanup_desktop_tokens	0	1770987536207	1770987550027	1770987550029	success	100	null
tdbsmn6a63853gpgbe4mac7r9y	expiry_notify	0	1770519374547	1770519380134	1770519380143	success	100	null
fmtzag8sm3bcfdadmu7iy3qz1a	cleanup_desktop_tokens	0	1770586040545	1770586040610	1770586040612	success	100	null
ek4jxr7yzfbddrc8k6411ftyar	product_notices	0	1770519374552	1770519380134	1770519380236	success	100	null
esfiughqrpfo7fszsjuda39rco	refresh_materialized_views	0	1770768036283	1770768043897	1770768043913	success	100	null
51oe9sb39fdudmoo1u5wah1abo	product_notices	0	1770634584855	1770634587712	1770634587806	success	100	null
yq8pqn7jwbrszgzwgkgohhpd1o	expiry_notify	0	1770540496543	1770540510124	1770540510130	success	100	null
dfgq4w7ngp868ygqeh3ewqpmme	expiry_notify	0	1770587300635	1770587301199	1770587301204	success	100	null
4htdude6hjd98ewthmtdjzqoxr	product_notices	0	1770684989058	1770684995917	1770684996036	success	100	null
on1hnquy5jdexe9w5b7y3st8br	expiry_notify	0	1770881386512	1770881391478	1770881391481	success	100	null
g3is53ky4fd89kp3u8moh8pj8o	product_notices	0	1770540976585	1770540990366	1770540990485	success	100	null
zwwa6aa4tfn3jjj9oxe4sk8aae	product_notices	0	1770587780686	1770587781453	1770587781545	success	100	null
wtkfbwswopfazg1ben1pe8ap9e	expiry_notify	0	1770768216303	1770768223971	1770768223979	success	100	null
j6qj7jpzstrb7mgs3jz6tbrqxh	expiry_notify	0	1770541156603	1770541170441	1770541170445	success	100	null
ck6o4d7f7inm7nss6cqcah1j3e	expiry_notify	0	1770705090796	1770705105364	1770705105371	success	100	null
q6mzzrr683b9pmqhamy45ce8fw	expiry_notify	0	1770587960703	1770587961553	1770587961558	success	100	null
kaxor6fmc7fxtqsoxkd6qkxx8o	cleanup_desktop_tokens	0	1770542116673	1770542130756	1770542130763	success	100	null
d43wyrse338edfm3kz6piffozc	expiry_notify	0	1770812920409	1770812929204	1770812929210	success	100	null
txqgfcgxp7dexkqb3rdif6x57y	expiry_notify	0	1770726872609	1770726880166	1770726880173	success	100	null
w54gzhyyojrf3r6hfs917b56jy	expiry_notify	0	1770543136771	1770543151138	1770543151142	success	100	null
p6auys31ijbtbkkzp89c46649c	product_notices	0	1770609382553	1770609391743	1770609391884	success	100	null
y38mpzffxbdcpm9pjp1xk944dh	cleanup_desktop_tokens	0	1770768456330	1770768464079	1770768464086	success	100	null
7geajqb8d7b6tqkbth57bnrd9h	cleanup_desktop_tokens	0	1770881686539	1770881691628	1770881691631	success	100	null
sj9xkt73wfds7d9p6rrgtiu1xh	expiry_notify	0	1770565578806	1770565586257	1770565586263	success	100	null
wsrdzxxyjty7bpg8qestg5nwyr	expiry_notify	0	1770610282624	1770610292080	1770610292085	success	100	null
hxsczmkiejbkdk5yu6qcu416ec	expiry_notify	0	1770566898878	1770566906798	1770566906802	success	100	null
ded3i3wpd7bixq6wgd13mtgage	expiry_notify	0	1770791858574	1770791859805	1770791859811	success	100	null
q159emb4gtf67rj7p3m4ge5fmo	product_notices	0	1770883006630	1770883012240	1770883012361	success	100	null
ndyjxaa6obbaxcgsq8s1fw6ycc	expiry_notify	0	1770610942679	1770610952419	1770610952426	success	100	null
widdp1o4w38czqfncc1g685igo	expiry_notify	0	1770882706611	1770882712097	1770882712101	success	100	null
xmu8nkkohiyupbiot9ztgrr5ww	expiry_notify	0	1770792518595	1770792520095	1770792520101	success	100	null
f3mwb3k797gnzb3sew686f3nie	expiry_notify	0	1770633984792	1770633987465	1770633987470	success	100	null
bikzfngprtfc8xaupy1zrk59tr	expiry_notify	0	1770835302290	1770835304685	1770835304691	success	100	null
k5ekghb3kbf68r8s9f1hbwu7wc	expiry_notify	0	1770884026729	1770884032738	1770884032742	success	100	null
iw4io6nwgpr6bm958nacb6ekow	expiry_notify	0	1770910309169	1770910309584	1770910309591	success	100	null
3jzffr3kibddf8jqbo5s5pjuky	expiry_notify	0	1770933411318	1770933420386	1770933420388	success	100	null
zarjhaggt7dofrouk41ce4uxao	expiry_notify	0	1770934731437	1770934741027	1770934741032	success	100	null
kopzwwahujff7kryxjc4gtu8ho	product_notices	0	1770933411323	1770933420386	1770933420494	success	100	null
hc4h7yngkbbm7pmekikzhxifsh	expiry_notify	0	1770934071377	1770934080674	1770934080680	success	100	null
thw37183q3bhdyu3aorsfhoamy	cleanup_desktop_tokens	0	1770961913988	1770961918760	1770961918764	success	100	null
ww6yh66bi3bcimhq8qdmxscfjc	expiry_notify	0	1770964254189	1770964259815	1770964259822	success	100	null
h16ufcxwjidg38tb4ahoc4w36c	expiry_notify	0	1770979315397	1770979326132	1770979326139	success	100	null
qxwmdrfk77g8bmr1axgbt87q3h	expiry_notify	0	1770979975438	1770979986379	1770979986381	success	100	null
9oqtf8czspdpmd6855e6f3pbac	expiry_notify	0	1770980635489	1770980646685	1770980646691	success	100	null
8hpd54t4btfxjqeoc35t3ct5ec	expiry_notify	0	1770981295529	1770981307009	1770981307014	success	100	null
gef7gtk797nrp87wm4kfzy1d5c	expiry_notify	0	1770912289351	1770912290480	1770912290485	success	100	null
ry5cka697tgbdjrxj99hfxzzmo	cleanup_desktop_tokens	0	1770501912862	1770501926812	1770501926814	success	100	null
z1qoysfbrpdjb8qyh9k5iknjne	expiry_notify	0	1770518714485	1770518719824	1770518719831	success	100	null
5yfqtq39bbnspx9os5fdk6q4oh	expiry_notify	0	1770586640596	1770586640865	1770586640868	success	100	null
5ndwg7fdp3r3dpeni6egnhduxw	expiry_notify	0	1770660987090	1770660999937	1770660999943	success	100	null
todcctrsgfn1if1kiaoxgm835y	expiry_notify	0	1770745234267	1770745248753	1770745248760	success	100	null
z1i8weu8njrm8ru1bdmjzj1e6a	expiry_notify	0	1770542476727	1770542490828	1770542490832	success	100	null
c5k7wkbszjra8g1xia4qjm4dmr	expiry_notify	0	1770857624401	1770857635498	1770857635504	success	100	null
c3fo4qr7k7bzxx9pb86uiens5e	expiry_notify	0	1770987896248	1770987910202	1770987910204	success	100	null
1rpsdnehdffguennf78rk5zo8c	expiry_notify	0	1770662967266	1770662980763	1770662980765	success	100	null
ogjpc83tqp8qbrmabxicb7rnoo	expiry_notify	0	1770543796853	1770543811494	1770543811497	success	100	null
bugy54nhpbr9urbbng9yf5gyac	cleanup_desktop_tokens	0	1770794078706	1770794080721	1770794080726	success	100	null
64axgai1ntf8fmoommqxapd4ca	expiry_notify	0	1770611602717	1770611612696	1770611612701	success	100	null
opssh1x9ap8kujrtjtoimj31xa	cleanup_desktop_tokens	0	1770611602722	1770611612695	1770611612701	success	100	null
nx8jqtzyitgf5yp7gt63n5b8ch	product_notices	0	1770566178838	1770566186524	1770566186631	success	100	null
etbhys3xpif7fg8rwzucgfon1w	product_notices	0	1770746194337	1770746209223	1770746209317	success	100	null
a8wh5t35j3ykikjxniz9a4uqbc	expiry_notify	0	1770708391052	1770708391777	1770708391781	success	100	null
f99octckc3f9innonnecp1r3gy	expiry_notify	0	1770686009147	1770686016422	1770686016429	success	100	null
d5af3syccjg77xynxa3mizs6dc	expiry_notify	0	1770566238854	1770566246549	1770566246554	success	100	null
nj8d76sfrb89tgs148im3gqbhw	expiry_notify	0	1770634644870	1770634647742	1770634647746	success	100	null
gsyhuhe31tf4icosdpgdbecj4h	expiry_notify	0	1770858284445	1770858295851	1770858295856	success	100	null
bysmkkgx43f8myfoibo41w47ec	expiry_notify	0	1770686669185	1770686676733	1770686676737	success	100	null
y6ufu6sphj818xyx68ygx5mzse	expiry_notify	0	1770747154423	1770747154700	1770747154703	success	100	null
gy7i5fezkbbe8p1cwxp4siag1h	expiry_notify	0	1770989216325	1770989230769	1770989230773	success	100	null
i3cayrkfsiyztm6us1hi1hycxa	expiry_notify	0	1770705750860	1770705765645	1770705765651	success	100	null
nasymkdftjnmijpy9nftriaago	expiry_notify	0	1770768876346	1770768884258	1770768884263	success	100	null
nmfuesibyifxirftphsss3yhpa	expiry_notify	0	1770882046565	1770882051823	1770882051829	success	100	null
qai9nrg7a38d7b1jrwyieuok7c	expiry_notify	0	1770989876369	1770989891101	1770989891106	success	100	null
d68hx8xpopft8juymi6gnfyqte	expiry_notify	0	1770727532662	1770727540474	1770727540477	success	100	null
9yd1miyfhfgrdbp57ec5dupdae	expiry_notify	0	1770706410901	1770706410934	1770706410938	success	100	null
fdiu33uzmfrtbkfd3bccnqpqyw	cleanup_desktop_tokens	0	1770706410895	1770706410935	1770706410939	success	100	null
e1md4f3eojbdbqhz5ebp5o1zte	product_notices	0	1770792998628	1770793000263	1770793000363	success	100	null
9px7eo6wpfywdptkdc3bhyiwxw	expiry_notify	0	1770962334031	1770962338973	1770962338978	success	100	null
h8j1g57upjbmtkryosxku1cboe	expiry_notify	0	1770936051553	1770936061642	1770936061645	success	100	null
enfuimwmutgbtc6jk5qkugc5xw	product_notices	0	1770706590920	1770706591017	1770706591114	success	100	null
a3q36j98obbm9b3au8noiz7ckc	expiry_notify	0	1770814240477	1770814249798	1770814249801	success	100	null
eqjawwrb6fn8xfuou7ebqbnc7w	expiry_notify	0	1770793178650	1770793180334	1770793180342	success	100	null
bw1sxyw4dpbtxerm4bdfoymjgr	expiry_notify	0	1770912949400	1770912950792	1770912950796	success	100	null
nsw55x7b9bnj5k858pywo41sew	expiry_notify	0	1770707070968	1770707071259	1770707071262	success	100	null
i5a1oww7ttg1xnoaowbznncene	expiry_notify	0	1771004997828	1771005003500	1771005003506	success	100	null
kjaz7ukn3pfepjaw6h8pxzrc4r	expiry_notify	0	1770793838679	1770793840594	1770793840599	success	100	null
1p67jqk4efynikmu96w1cignmc	expiry_notify	0	1770707731031	1770707731528	1770707731533	success	100	null
6h78w1ee6tn8zkaeejf8bif6ze	expiry_notify	0	1770935391503	1770935401348	1770935401354	success	100	null
jqaum9gfyjdx3f9uxbsd8n8z4o	expiry_notify	0	1771005657879	1771005663823	1771005663827	success	100	null
z3jyrd9ju3d7jdxrmwpq91zhfh	product_notices	0	1770814600501	1770814609975	1770814610074	success	100	null
wrmauhthm38p3ybkem7yb6axte	cleanup_desktop_tokens	0	1770837882531	1770837885854	1770837885859	success	100	null
71uyw3y3f7fzurkimzydud1m3h	expiry_notify	0	1770814900542	1770814910105	1770814910111	success	100	null
684m5ixaypnizbaxtg5z67ts8c	expiry_notify	0	1770936711615	1770936721939	1770936721944	success	100	null
yx8tmuwmgj8k8dcygi7tdso9xc	cleanup_desktop_tokens	0	1771005717893	1771005723854	1771005723859	success	100	null
s69nb1g48prxidqw3ox87qmckh	cleanup_desktop_tokens	0	1770980215459	1770980226481	1770980226483	success	100	null
5ts7aoyyup8sjfsjtphm3dz47a	expiry_notify	0	1770816220656	1770816230712	1770816230716	success	100	null
zczfcri6njyu8k65mupisi73sr	expiry_notify	0	1771006317951	1771006324121	1771006324124	success	100	null
ypu7kbadppy5bchwsjkraw64hy	expiry_notify	0	1770836622431	1770836625328	1770836625335	success	100	null
36t8d4nnkfd38dx19aykbt1rga	expiry_notify	0	1770837942544	1770837945889	1770837945894	success	100	null
n69b6af1wjyot8jrymgckmkeoe	product_notices	0	1770980215463	1770980226480	1770980226538	success	100	null
7ome6d9nkpfc9ry199pzqtktra	expiry_notify	0	1771006978033	1771006984462	1771006984467	success	100	null
mjkzmseqojgfmqh6a8zj63i5ia	expiry_notify	0	1771315749862	1771315756479	1771315756487	success	100	null
dfbgxkn9wfda3p9sdk3syeszhh	cleanup_desktop_tokens	0	1770815980637	1770815990599	1770815990603	success	100	null
q5yd37hu4ib1fpwhxnjqhnup5w	expiry_notify	0	1770504193133	1770504207929	1770504207932	success	100	null
ykab4t9sw3b8dmgg83xrpxmgby	expiry_notify	0	1770520034646	1770520040486	1770520040493	success	100	null
6eyqs8cij7y8dxt7oti3ax3jtr	expiry_notify	0	1770588620728	1770588621848	1770588621850	success	100	null
oxfq5cpoetbspgx39pzusiuaia	expiry_notify	0	1770661647139	1770661660177	1770661660184	success	100	null
ob7fdqbxifnrmc7r9j9ccatxzc	expiry_notify	0	1770504853178	1770504853184	1770504853186	success	100	null
coypw7pkbjgt3eszgcssyo3j5e	expiry_notify	0	1770747814491	1770747814935	1770747814938	success	100	null
n9supjg1p3nf78xs1wc6pmxn3r	cleanup_desktop_tokens	0	1770520214673	1770520220570	1770520220576	success	100	null
6wmxrce1ppru8f14xri8zxs7ta	product_notices	0	1770504973187	1770504973236	1770504973335	success	100	null
h1w75o5z6frqmfscf5y54oajqh	expiry_notify	0	1770589280783	1770589282193	1770589282198	success	100	null
gsqymmcqsty5dxagn9z5f5ebde	product_notices	0	1770857804414	1770857815589	1770857815694	success	100	null
okxxnp8i6tgexfyzyrxd1agcno	expiry_notify	0	1770520694691	1770520700785	1770520700790	success	100	null
xr94sxp777gj7d63azdejisd3y	expiry_notify	0	1770662307189	1770662320455	1770662320461	success	100	null
n4rwuaj45fga8bei4wat4pd4bw	expiry_notify	0	1770988556272	1770988570460	1770988570466	success	100	null
yn5ty35qa7nmbn6j8w91oihtbr	expiry_notify	0	1770612262790	1770612273036	1770612273043	success	100	null
79kcb8a39ig79jtccm7mgprfco	expiry_notify	0	1770544456889	1770544471751	1770544471758	success	100	null
m47b49dgcinpfy9kdpyjbw1q3o	expiry_notify	0	1770748474543	1770748475190	1770748475194	success	100	null
nrxw9i3e3bytimyfu38okazkgy	expiry_notify	0	1770709051108	1770709052052	1770709052058	success	100	null
7g6fg64nqbrpxqnsyrhyt95g7w	cleanup_desktop_tokens	0	1770662607228	1770662620596	1770662620602	success	100	null
i9xxnc64fjdwtb1z54qoy45nyy	expiry_notify	0	1770545116951	1770545117023	1770545117027	success	100	null
s8rxhg1oy3bedgrkq61zqjeito	expiry_notify	0	1770635304895	1770635308038	1770635308044	success	100	null
66g8f341pfbc5c7kj8qo69ppmw	expiry_notify	0	1770547097158	1770547098035	1770547098038	success	100	null
w1d473xywjgpfm3ffzg3ro7uyr	expiry_notify	0	1770883366672	1770883372439	1770883372445	success	100	null
87uyht3wriy63e9o57eegh7eey	expiry_notify	0	1770635964923	1770635968315	1770635968319	success	100	null
4wnucgkuepfmipsgc9phntf1uh	expiry_notify	0	1770687329248	1770687337107	1770687337113	success	100	null
frrudiu9r7d99kmnwmefjhwjya	expiry_notify	0	1770567558960	1770567567127	1770567567133	success	100	null
fzg9c4zdbbf9bdqd7aztmi5k3a	expiry_notify	0	1770769536400	1770769544539	1770769544548	success	100	null
kw5j6fqafjg9xrwimo41mod5ka	product_notices	0	1771005417848	1771005423695	1771005423779	success	100	null
rfkjpqpwo7gujjh67rwnnwut1c	expiry_notify	0	1770636625042	1770636628649	1770636628653	success	100	null
pb87zhjxgi8aidhgw7wsrqoq5y	cleanup_desktop_tokens	0	1770567738967	1770567747210	1770567747214	success	100	null
ruy1ia1xntd758y38hb53r5xdh	expiry_notify	0	1770687989295	1770687997445	1770687997449	success	100	null
66q4919uifd8ijddg54wacxfbr	expiry_notify	0	1771017539082	1771017549365	1771017549371	success	100	null
y8hxpmzibp8hibg6urqoawsatw	expiry_notify	0	1770637285108	1770637288974	1770637288978	success	100	null
8oj1dryfzty59rc8ummi8wieyh	expiry_notify	0	1770794438741	1770794440894	1770794440902	success	100	null
cquwftepfidh58gzkkdfm69qdh	expiry_notify	0	1770913609444	1770913611119	1770913611128	success	100	null
zxmmt3teej8c9rsmrpoudurghy	cleanup_desktop_tokens	0	1770688109323	1770688117512	1770688117516	success	100	null
udnor69ewffqzcx3z8k6npf45e	expiry_notify	0	1770837282483	1770837285561	1770837285567	success	100	null
zubwr77kb3yn7pqwpjt5g7ka7c	expiry_notify	0	1770815560604	1770815570416	1770815570422	success	100	null
791a9t7xxpno5bpdqtrub9ax1h	product_notices	0	1770688589369	1770688597702	1770688597818	success	100	null
hu8iqfuzuf8pjy5nmfh7117z1r	expiry_notify	0	1770914929599	1770914931773	1770914931778	success	100	null
64x1w57rqbrdxqaai3t184qrwo	cleanup_desktop_tokens	0	1770914629578	1770914631621	1770914631626	success	100	null
paxhoaumn7ypzr59j4b5dpkjxr	expiry_notify	0	1770688649378	1770688657730	1770688657736	success	100	null
it7f4ukz9ibsbqaax9zmfiojzh	expiry_notify	0	1771029420122	1771029434652	1771029434658	success	100	null
zjd9dydho7n7jbruhesut6fwdr	expiry_notify	0	1770728192707	1770728200771	1770728200787	success	100	null
8mfydg5wwigyzbis71ibh634fr	product_notices	0	1770728192712	1770728200771	1770728200892	success	100	null
zmusobcphjdod8crs9j6rqkxro	cleanup_desktop_tokens	0	1770936411586	1770936421795	1770936421799	success	100	null
7tnexfuozbbk8juigqubg7xmec	expiry_notify	0	1771030080201	1771030094936	1771030094940	success	100	null
c57kx59pkbrqdcbpa3xki63pge	product_notices	0	1770937011642	1770937022113	1770937022221	success	100	null
ao8r578ikpns8kcjq1kjape75a	expiry_notify	0	1770937371667	1770937382334	1770937382338	success	100	null
ohnxgr7skpnqmczwjaye7zs6mc	product_notices	0	1771030620264	1771030635205	1771030635315	success	100	null
qee8pzz1ajrzfb6xs8z3jf83ya	expiry_notify	0	1770981955626	1770981967375	1770981967382	success	100	null
y4ipqoaqfbrumxgw4x3p6gip3c	expiry_notify	0	1770962994074	1770962999275	1770962999281	success	100	null
3km44kqhc7dy3n6wxbnbd6y7ww	expiry_notify	0	1770963594139	1770963599519	1770963599524	success	100	null
ahuf9or3tbd18rfy9gdjaxdzey	expiry_notify	0	1771030740282	1771030755250	1771030755255	success	100	null
kg935sc4iiy4xjugay6t4rfy3r	expiry_notify	0	1771039921108	1771039924650	1771039924657	success	100	null
865ju1etztnxfn87ihc1onbqea	expiry_notify	0	1771041241208	1771041245314	1771041245318	success	100	null
bqkkqso9g7yi8qyeru4xn3askc	export_delete	0	1770638185165	1770638189399	1770638189405	success	100	null
dzaaxennj3rqjxeytdymnxhk3o	expiry_notify	0	1770505513255	1770505513483	1770505513486	success	100	null
kr14ejpexiynig7thw4w5ujrxo	expiry_notify	0	1770521354741	1770521361056	1770521361059	success	100	null
n5bhn9mc97fttnazykc8e5qp9a	cleanup_desktop_tokens	0	1770589700832	1770589702446	1770589702451	success	100	null
jospjidbxp8pmrt6cmuosffobo	cleanup_desktop_tokens	0	1770505573268	1770505573509	1770505573516	success	100	null
7q37yexk47rs7y517j9morkrfh	product_notices	0	1770663387303	1770663400978	1770663401111	success	100	null
59sw7rujjjrpinrac8exchwg5e	expiry_notify	0	1770522014802	1770522021270	1770522021275	success	100	null
kk97dxd7r7n15c68z55gt4fu5w	import_delete	0	1770638185171	1770638189399	1770638189405	success	100	null
18fxocj44pfxbyfurou5buz3re	expiry_notify	0	1770506173327	1770506173799	1770506173804	success	100	null
44ec4uha5fdi7qj658b8p1rsio	expiry_notify	0	1770612922839	1770612933348	1770612933355	success	100	null
mhaa7pt4wpgwzj9uxuetbntuic	expiry_notify	0	1770749134588	1770749135522	1770749135527	success	100	null
ob9edyap17nkte5f3dkmkj3k9e	expiry_notify	0	1770522674857	1770522681551	1770522681557	success	100	null
qmyipu14sfyj5ksmo7igxqwipy	expiry_notify	0	1770858944492	1770858956181	1770858956188	success	100	null
9auh9fmzg3dffen5nrge9j9u7a	expiry_notify	0	1770569539154	1770569548017	1770569548021	success	100	null
jju6sckafb8wbdrg6h7mwqjz6e	product_notices	0	1770522974900	1770522981672	1770522981782	success	100	null
zbngwfsg7p8pi8os9s9t1aq5ea	product_notices	0	1770612982849	1770612993380	1770612993498	success	100	null
9kkhei9wujroip7oxz4bfqyoso	expiry_notify	0	1770689309423	1770689318050	1770689318057	success	100	null
t53cg7uywf8x8r9sy6jx46wc1y	cleanup_desktop_tokens	0	1770523874970	1770523882087	1770523882092	success	100	null
hz379kayxiyo9d3dwng64g7z3c	cleanup_desktop_tokens	0	1770859784567	1770859796568	1770859796575	success	100	null
dfj3itjs1jg73qhki4t1fyrbrh	expiry_notify	0	1770614242965	1770614253984	1770614253988	success	100	null
kqrjwdud6i8tbyx7aq9fydizga	expiry_notify	0	1770859604555	1770859616508	1770859616512	success	100	null
7bf8cn6efprq5gqxfu1karsnwa	expiry_notify	0	1770523994980	1770524002145	1770524002152	success	100	null
9qtty1ps7jrcmmsbs5optz4diw	expiry_notify	0	1770689969484	1770689978299	1770689978302	success	100	null
7x757o8xubnt5fmn4y655zd4se	expiry_notify	0	1770749794645	1770749795801	1770749795806	success	100	null
6dosnc85jpfezphhyc3ao8gkce	cleanup_desktop_tokens	0	1770637045089	1770637048858	1770637048863	success	100	null
j4jdbex13pnx5fpdiwzhigkgcr	expiry_notify	0	1770524655051	1770524662477	1770524662481	success	100	null
6peg88wy1id6zmggiwceph55ya	expiry_notify	0	1770770196495	1770770204855	1770770204861	success	100	null
z6j3swgie3b6bebbjjeguuw3zw	product_notices	0	1770749794650	1770749795800	1770749795930	success	100	null
gk7zx7udxf839f4a6qpw4w4jje	expiry_notify	0	1770570199204	1770570208338	1770570208342	success	100	null
ed6hej7ecjg65y36o9ohgkztfr	product_notices	0	1770544576908	1770544591788	1770544591908	success	100	null
g4irun34e7bd8nte4h7m7fqa1o	expiry_notify	0	1770709711157	1770709712322	1770709712329	success	100	null
wjacm4zzfpdejn56x1i3rsj6fw	expiry_notify	0	1770637945149	1770637949277	1770637949283	success	100	null
xqzr377e5t84me34mzfk8ukf5c	cleanup_desktop_tokens	0	1770728312727	1770728320848	1770728320853	success	100	null
y6cbr46ppidfugrnmrq71ued9c	cleanup_desktop_tokens	0	1770545777025	1770545777363	1770545777368	success	100	null
4q4kdara83gybrrfhc5uejcfur	expiry_notify	0	1770545777019	1770545777363	1770545777367	success	100	null
9ay8o61jitfi8crfd3q59rsu8w	cleanup_desktop_tokens	0	1770750274692	1770750276026	1770750276031	success	100	null
dryrtrma3p8mtyjyqwi1c1sfpo	expiry_notify	0	1770568218996	1770568227428	1770568227434	success	100	null
xmqifqiu1j8zzb947mn8xe3igh	expiry_notify	0	1770884686781	1770884693022	1770884693028	success	100	null
b565yjqdkjr7ueshaizpksd49c	expiry_notify	0	1770795098782	1770795101200	1770795101206	success	100	null
gzr9s3wbbpy5ug94zuxz5bq5ze	expiry_notify	0	1770568879100	1770568887725	1770568887729	success	100	null
iy9q1ow9npg3384yhhdhyphy1o	mobile_session_metadata	0	1770638185167	1770638189400	1770638189415	success	100	null
pjanpej1wiyxur8y1kcafhojse	install_plugin_notify_admin	0	1770638185169	1770638189399	1770638189418	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
ggy6xj7mdbygjqkf38g5cfwhtr	plugins	0	1770638185168	1770638189399	1770638189418	success	0	null
jujtmj1c57na5qcyaodyefdazy	expiry_notify	0	1770838602624	1770838606187	1770838606189	success	100	null
1na9wgc1ztfa5j1p3b9dkxpawh	product_notices	0	1770638185161	1770638189399	1770638189501	success	100	null
8qnbeq8d8bfatdp7ggcu91bi4h	expiry_notify	0	1770816880716	1770816890986	1770816890992	success	100	null
booot53fqpbiibpras1n5sqb6y	cleanup_desktop_tokens	0	1770885346818	1770885353243	1770885353249	success	100	null
9i7p7os1xbfk7rxr5gfok9hm6w	expiry_notify	0	1770885346823	1770885353243	1770885353250	success	100	null
rzp69tw5ybyn3cizb9bequshic	expiry_notify	0	1770886006880	1770886013584	1770886013588	success	100	null
qfjtue63ntgo8jggrc66eknper	product_notices	0	1770886606943	1770886613921	1770886615520	success	100	null
o8e89oj7wfrjbb5otzoiu1d4oh	expiry_notify	0	1770886666954	1770886673950	1770886673955	success	100	null
6jdd1qteciddjnyqkx87nrdjsw	expiry_notify	0	1770914269512	1770914271430	1770914271436	success	100	null
h983gb8mjfyp5qtym7n45t79xc	expiry_notify	0	1770938031742	1770938042665	1770938042672	success	100	null
fnfux6pfajdfbp4umhpkeomw3o	expiry_notify	0	1770964914269	1770964920116	1770964920120	success	100	null
rwoeoyzmdfbjurmccb5pg8t4ge	expiry_notify	0	1770965514302	1770965520346	1770965520351	success	100	null
sbib5sh76trejpnqfyc1zngqre	expiry_notify	0	1771143310718	1771143322498	1771143322505	success	100	null
cw1gceffxfgrumn49tw1up5nyo	expiry_notify	0	1770990536453	1770990536467	1770990536469	success	100	null
uetjcbsjnfr8jjcx3geedqohoh	expiry_notify	0	1770506833407	1770506834100	1770506834105	success	100	null
we4c58sszigq9x6awd4tem9h7a	expiry_notify	0	1770523334942	1770523341834	1770523341841	success	100	null
iw9jtwmsmbdx3cppn1pd8rhsja	expiry_notify	0	1770589940854	1770589942600	1770589942608	success	100	null
837oigpm6jna8q7nag6c853a5e	expiry_notify	0	1770663627338	1770663641095	1770663641099	success	100	null
dp6783pyh38p5d1pp3gqa1e4mr	expiry_notify	0	1770750454714	1770750456098	1770750456105	success	100	null
4e5cs3ehcb85fxc8nek7uhi7sc	expiry_notify	0	1770546437087	1770546437705	1770546437711	success	100	null
491uqkhn9jgy5yrjiezc43bkxw	expiry_notify	0	1770860264609	1770860276763	1770860276770	success	100	null
taqqocdr9tbq8ps3146nckee8o	expiry_notify	0	1770613582904	1770613593680	1770613593687	success	100	null
d67dec4k5bgedme7nzq7r75ubw	product_notices	0	1770569779176	1770569788147	1770569788266	success	100	null
cpekmj6br7yb7y5y9wc78z4msy	expiry_notify	0	1770690629551	1770690638624	1770690638631	success	100	null
5km8d6cpdtrzmb576ojid6ehyy	expiry_notify	0	1770638605215	1770638609582	1770638609588	success	100	null
tszbw86dwtbrfq8foywqxwagxa	expiry_notify	0	1770770856552	1770770865143	1770770865151	success	100	null
4aazy8sxbbn47brjun9cfmsear	cleanup_desktop_tokens	0	1770710071193	1770710072462	1770710072464	success	100	null
rrmb4g36otrntpb4irsrwp5zre	expiry_notify	0	1770640585391	1770640590459	1770640590463	success	100	null
py95j68hapdyjpk3n9seaw5j1y	expiry_notify	0	1770860924681	1770860937023	1770860937027	success	100	null
b17fwse4q38gbdrwmx541hx6ye	expiry_notify	0	1771007638088	1771007644768	1771007644774	success	100	null
hokfpim31bg1ij63eu5bzoxuno	product_notices	0	1770771396601	1770771405426	1770771405548	success	100	null
xj5iycf8xidjfpe91epf93zf4h	cleanup_desktop_tokens	0	1770640705415	1770640710514	1770640710518	success	100	null
roymkhjn4b8ktxmfenrz9zuw5o	product_notices	0	1770710191212	1770710192507	1770710192584	success	100	null
xtipbyub9irn3j7zh56qojqz8h	expiry_notify	0	1770641245467	1770641250701	1770641250705	success	100	null
5hxqkj6mfi8r7czeiitywqh5wo	expiry_notify	0	1770887327013	1770887334308	1770887334312	success	100	null
1j7abx6uat8i5g5wda3y58pisc	expiry_notify	0	1770710371227	1770710372557	1770710372559	success	100	null
7xzh1fzfqbbddgio8j6r9rkscy	expiry_notify	0	1770771516617	1770771525484	1770771525489	success	100	null
otm43jn4uid6pnkcf41x5mnrew	expiry_notify	0	1771040581174	1771040584973	1771040584980	success	100	null
9sytwwjuxf888gzabf5bp53k4o	expiry_notify	0	1771018199155	1771018209689	1771018209696	success	100	null
qk8rjx7qding3ymwfq593racoa	expiry_notify	0	1770728852746	1770728861135	1770728861141	success	100	null
txtu85mdmigi3fgnuai8zq6w8r	expiry_notify	0	1770938691807	1770938702999	1770938703006	success	100	null
kqr5fncuftgeikdomw8oy8ffih	expiry_notify	0	1770795758864	1770795761525	1770795761531	success	100	null
ftzry58d9tfaifp5zoh4q4y9uy	expiry_notify	0	1770887987050	1770887994579	1770887994583	success	100	null
5ntoejps7ffnffcjujuc1zb7ho	expiry_notify	0	1770729512817	1770729521447	1770729521451	success	100	null
k8ferds1r7nt5r6bzoqhj5zubh	expiry_notify	0	1770817540729	1770817551267	1770817551273	success	100	null
gwoaaxa95jrp8egipr3nsufp9h	product_notices	0	1770915409631	1770915412015	1770915412097	success	100	null
dw9szg3zqbb8mro3fbs1dcwj5r	cleanup_desktop_tokens	0	1771031220322	1771031220416	1771031220420	success	100	null
n9814gnwt7gpurwtymx3wwi55e	expiry_notify	0	1770839262692	1770839266492	1770839266498	success	100	null
c9tu3xarnffxff191fqhk8iouc	expiry_notify	0	1770915589662	1770915592088	1770915592092	success	100	null
q93aiwfeztrs7dbpwytnejqtza	product_notices	0	1771041421235	1771041425391	1771041425500	success	100	null
e1r414wy1iyt9phys8wbmozwhy	expiry_notify	0	1770916909750	1770916912667	1770916912672	success	100	null
q3df1nagh3f69mhhibk7jscsrc	expiry_notify	0	1770939351902	1770939363400	1770939363405	success	100	null
8ur73b93h7njbn56cbnqrcer5o	expiry_notify	0	1771041901284	1771041905632	1771041905637	success	100	null
xd9ah5gqbjdfujtzp456ksbjfa	expiry_notify	0	1770941332071	1770941344390	1770941344393	success	100	null
6tfd1ipdjfrdpmh675xtgsa9jr	cleanup_desktop_tokens	0	1771042141310	1771042145762	1771042145767	success	100	null
gnyckubgyjdzdqrpsfonrsfzec	cleanup_desktop_tokens	0	1770965574313	1770965580367	1770965580372	success	100	null
oa7rnhzxs7dydmgyrk69xhbusw	product_notices	0	1771048621892	1771048628858	1771048628976	success	100	null
5ktexjpwcbrapcxinkgu7cxucy	expiry_notify	0	1771048501877	1771048508797	1771048508803	success	100	null
7auhccejjjdz7mdftr1i6ek5de	expiry_notify	0	1770982615680	1770982627703	1770982627710	success	100	null
c6jjojxub7ft9m1e89hjmsdenc	expiry_notify	0	1771049161938	1771049169136	1771049169142	success	100	null
mib6uottkpd48jekoz54qzbyyc	expiry_notify	0	1771049822000	1771049829462	1771049829468	success	100	null
rndez6ijbirbxjwt4r1ctenpfh	expiry_notify	0	1771055762560	1771055772305	1771055772312	success	100	null
nxbytyrzg3893bn7qyd44ennkc	product_notices	0	1771055822578	1771055832323	1771055832426	success	100	null
uy4ewcrqrfyj7p3bzimwj6eyjh	expiry_notify	0	1771057742779	1771057753166	1771057753171	success	100	null
57jtdzunq3rauq4mt59nhjfhga	expiry_notify	0	1771061703140	1771061715052	1771061715059	success	100	null
gy539t76iifytmedrqk9ewj3rh	expiry_notify	0	1771062363233	1771062375383	1771062375388	success	100	null
sr74ffabwpfwxm4d9gzx8kxboh	expiry_notify	0	1771065003523	1771065016664	1771065016671	success	100	null
mo75mdz4p3gqmnir17shxw3r1e	expiry_notify	0	1771066323628	1771066337240	1771066337242	success	100	null
oeojgji5stbkjc1ug7mhdtqw3y	expiry_notify	0	1770507493472	1770507494397	1770507494404	success	100	null
s89k7goprj8fmkku7x7pycnabo	expiry_notify	0	1770525315127	1770525322840	1770525322852	success	100	null
rs8b7gwug3ys58cr9xb5tbemjh	expiry_notify	0	1770590600939	1770590602950	1770590602955	success	100	null
ikip6hkta7namph58zqr8ep5ic	expiry_notify	0	1770664287401	1770664301463	1770664301470	success	100	null
g1rdkbhx6tg49m6kraibwzq95c	expiry_notify	0	1770508153531	1770508154679	1770508154686	success	100	null
g4xyyanhfprxjdmwja9s3aghxy	expiry_notify	0	1770751114784	1770751116383	1770751116390	success	100	null
hwir8jpsubdtx8o3trzqdj8qih	product_notices	0	1770526575212	1770526583417	1770526583537	success	100	null
ecba4ufe63ge5e3gu9suxj6rwa	product_notices	0	1770861404727	1770861417232	1770861417339	success	100	null
nrqy95on3jnppjhyobu97gx9fo	product_notices	0	1770508573582	1770508574889	1770508575009	success	100	null
zkda7c8jkig19k8qc1jp87eiac	product_notices	0	1770591380996	1770591383320	1770591383440	success	100	null
goak1qjrqjdtfnn45u5jo5eody	expiry_notify	0	1770526635222	1770526643439	1770526643443	success	100	null
d98oubg85pyq5gtnzzzpchwywc	cleanup_desktop_tokens	0	1770509233664	1770509235193	1770509235196	success	100	null
1h5b3nj9i78xxjm45q416b5iso	expiry_notify	0	1770664947473	1770664961762	1770664961764	success	100	null
txciexbfwidsuythfb3trsnd6h	expiry_notify	0	1770614903027	1770614914292	1770614914301	success	100	null
g5nxmqxqe7rfuecnmhozp376da	expiry_notify	0	1770510133743	1770510135632	1770510135636	success	100	null
j8u9d8mgyiy378hoasu6ke38ne	expiry_notify	0	1770547757221	1770547758327	1770547758333	success	100	null
emk3ib73ninb7foo3hbkumyjjr	expiry_notify	0	1770751774817	1770751776672	1770751776678	success	100	null
6ewry4ccuirejb74b5qnaibz9e	expiry_notify	0	1770888647092	1770888654814	1770888654817	success	100	null
kbj49s7n8jd6unubj7u67w8kyw	expiry_notify	0	1770510793795	1770510795934	1770510795940	success	100	null
1zwx61j71pnwtdarf53a46ct4h	expiry_notify	0	1770691289605	1770691298978	1770691298984	success	100	null
ssi1oewki3d7prcf5kpd1kzanh	product_notices	0	1770548177265	1770548178551	1770548178664	success	100	null
xtewkjpb4tgq8goeskgwmthego	expiry_notify	0	1770639265286	1770639269885	1770639269892	success	100	null
nokcpatuz7djurfs3z11xindeo	expiry_notify	0	1770861584756	1770861597318	1770861597325	success	100	null
yt6d3g1diiri7nyg37mxzrgmpr	expiry_notify	0	1770772836739	1770772845997	1770772846001	success	100	null
gwdwqs4ctpbe5ku9cx1i88moph	expiry_notify	0	1770570859259	1770570868639	1770570868645	success	100	null
8qd4d9de9jg1pgdfzcfjbiu8zc	product_notices	0	1770753394915	1770753397384	1770753397489	success	100	null
rmc1gu7rujym3rjqp9ggdt1o9w	expiry_notify	0	1770639925329	1770639930131	1770639930136	success	100	null
p8dxzxrztff77em5e5ziip4a5o	cleanup_desktop_tokens	0	1770691769666	1770691779230	1770691779235	success	100	null
ojoj6do8njd1pn4f37sspaprfw	cleanup_desktop_tokens	0	1770571399308	1770571408884	1770571408886	success	100	null
arm9j1gxyirnxbxarge8wtd78y	expiry_notify	0	1770571519331	1770571528931	1770571528936	success	100	null
abk6bsn8fidwmgm8xwib6r3snw	expiry_notify	0	1770691889687	1770691899300	1770691899305	success	100	null
jsnh1nt1p7bnmb4buoz8un7dna	cleanup_desktop_tokens	0	1770753934988	1770753937671	1770753937677	success	100	null
o5m5au7boi8g5mjidxac4pxe8a	expiry_notify	0	1770711031274	1770711032878	1770711032884	success	100	null
o7nrqk7z7igcfp7i1hnrzrupbw	cleanup_desktop_tokens	0	1770889007127	1770889014935	1770889014937	success	100	null
z5nfpbqxd3gxucx6bi8e8cu53e	cleanup_desktop_tokens	0	1770772116673	1770772125714	1770772125719	success	100	null
sjtjuew787gx9nf5wogx3jga6h	expiry_notify	0	1770712351383	1770712353509	1770712353514	success	100	null
3xo5u6p1ribjtejnoir3edhqne	expiry_notify	0	1770889967232	1770889975277	1770889975283	success	100	null
ncgr9ikqw7dxucmi8eb5876e1e	product_notices	0	1770839802729	1770839806763	1770839806875	success	100	null
tcotn81wctd17n3f1cg91wd3ah	expiry_notify	0	1770772176687	1770772185745	1770772185752	success	100	null
b8qju74r4tb95pz5n86pgftmko	expiry_notify	0	1770730112895	1770730121749	1770730121755	success	100	null
mbzsszg8qpfd7y67waysw9k1ia	expiry_notify	0	1770796418921	1770796421814	1770796421821	success	100	null
ba6czq8ftfdqj8duj44nokscth	expiry_notify	0	1770891287344	1770891295787	1770891295791	success	100	null
rq1zp67eh3d3jx5ngst6tpfk3w	expiry_notify	0	1770818200795	1770818211568	1770818211573	success	100	null
m8jphzxfobnhmmu3817c86tmqa	product_notices	0	1770796598940	1770796601910	1770796602000	success	100	null
j1dgo1uu4pft8k7zcnwxpytz6c	expiry_notify	0	1770916249723	1770916252392	1770916252397	success	100	null
r67jeg33ypyxzr5yppgi8xayih	expiry_notify	0	1770797078980	1770797082153	1770797082159	success	100	null
puwo8688rfg4bpu1urj18sdu3a	product_notices	0	1770818200799	1770818211567	1770818211669	success	100	null
jgxon7cx8frujqhnpbfqzcqyfc	expiry_notify	0	1770940011954	1770940023714	1770940023721	success	100	null
sd7psd1rr3bebbxdqnrg8dnb1c	cleanup_desktop_tokens	0	1770940011949	1770940023715	1770940023721	success	100	null
9ewpa3r447retfdb4hw5dezp3h	expiry_notify	0	1770818860838	1770818871841	1770818871847	success	100	null
mqembn1hifrx7fdyze4gderocw	product_notices	0	1770940612022	1770940624017	1770940624139	success	100	null
ezcjscxsnbb39ps3u9zewq8egw	expiry_notify	0	1770839922740	1770839926832	1770839926838	success	100	null
s3xfg3j9rbbotcqw7fzjkfgboc	expiry_notify	0	1770940672033	1770940684053	1770940684057	success	100	null
7dsuk1fh538stbbfbk798kunhe	refresh_materialized_views	0	1770940852045	1770940864161	1770940864182	success	100	null
sufgrygwkpyf58r8x69bk3u9ic	expiry_notify	0	1770941992145	1770942004712	1770942004717	success	100	null
r6ksbxfmbfb9jf4aj3f73rax1c	product_notices	0	1770965814353	1770965820475	1770965820564	success	100	null
zb3s49jo6b8b7jpqjr96nsfkze	expiry_notify	0	1770525975176	1770525983165	1770525983170	success	100	null
x7gxjkk18f879cqusswcc41u6w	expiry_notify	0	1770591260992	1770591263274	1770591263282	success	100	null
xm6ytzjojpgcmq4wmpkgr7epma	expiry_notify	0	1770508813621	1770508814998	1770508815003	success	100	null
741hn768q3ryzqn1tqoz9794zc	expiry_notify	0	1770665607520	1770665622027	1770665622035	success	100	null
xu9ry4j6etgdfqc5kntapjnxsh	refresh_materialized_views	0	1770508813626	1770508814998	1770508815022	success	100	null
3j96npur33nkfett7qxpbgw7xo	expiry_notify	0	1770752434842	1770752436944	1770752436951	success	100	null
s3nnerhz9bd69xcwwksbnxpiah	expiry_notify	0	1770548417290	1770548418669	1770548418675	success	100	null
f5h84wi1etyktrhp9i7uo8rgzo	expiry_notify	0	1770862244797	1770862257632	1770862257638	success	100	null
pbaphh3iufnq8edmq9d8w9ze9y	expiry_notify	0	1770509473690	1770509475315	1770509475320	success	100	null
fq1n6qno5brsjdh9tj4qp6tako	cleanup_desktop_tokens	0	1770615263070	1770615274474	1770615274480	success	100	null
oawix5bdt3gdpmwjnfpy8uqwco	product_notices	0	1770991016489	1770991016683	1770991016738	success	100	null
w3f56pb363gh3pp5ytq9h9gqjy	expiry_notify	0	1770549077337	1770549078990	1770549078995	success	100	null
4kbzmznhfjn7xq6e1asfnhj3wo	product_notices	0	1770692189726	1770692199474	1770692199601	success	100	null
4t5o5mce6ffhzp8yrbx5yy7e7a	expiry_notify	0	1770615563097	1770615574624	1770615574631	success	100	null
hdbh5zra33ytmy7utgqtw1o7jo	expiry_notify	0	1770572179395	1770572189218	1770572189225	success	100	null
x1mtg9g7xp8npp635uud6ajtny	expiry_notify	0	1770773496793	1770773506294	1770773506300	success	100	null
fbi38wu6jtyjixp776yu4iqmrh	expiry_notify	0	1770692549762	1770692559636	1770692559643	success	100	null
isw3p4b5cfnuxkana1t8prh1ey	expiry_notify	0	1770574819608	1770574830386	1770574830390	success	100	null
1ga9xh7mi7b1jy5hxb63omkhto	expiry_notify	0	1770616223176	1770616234938	1770616234940	success	100	null
tw1c7dbbw7dxxnnhzbb9nzxmdw	expiry_notify	0	1770862904849	1770862917977	1770862917983	success	100	null
4pgk3fdzh3nifbdpg1j7h3qs5o	expiry_notify	0	1770991136510	1770991136750	1770991136757	success	100	null
7kis9u4ktifi7m53kojogwi16e	cleanup_desktop_tokens	0	1770575059630	1770575070500	1770575070504	success	100	null
izzw8re6ob8itnsd3ekftconzr	expiry_notify	0	1770616883240	1770616895187	1770616895191	success	100	null
z48kjajuj7gxuyg555be1e66gw	expiry_notify	0	1770711691322	1770711693203	1770711693210	success	100	null
nshoif4znfdujp4seuunurjx9r	expiry_notify	0	1770889307171	1770889315057	1770889315061	success	100	null
ctwoyp7i5pgq9nk64eks7mwxmw	expiry_notify	0	1770864224943	1770864238597	1770864238599	success	100	null
fe8u3747q78d3gnxqugxoscn6w	product_notices	0	1770641785551	1770641790972	1770641791061	success	100	null
m94q3dy6g38mbx84khxt16peeo	cleanup_desktop_tokens	0	1770797739041	1770797742465	1770797742471	success	100	null
rbj5hf563bgkdnwscp8j4gsj4w	expiry_notify	0	1770714331556	1770714334397	1770714334401	success	100	null
m7jpof7jbffrp8ik743e6niywy	expiry_notify	0	1770797739047	1770797742464	1770797742471	success	100	null
uqn9bjhy1p8wurpjeb8sa5qjfc	expiry_notify	0	1770641905564	1770641911029	1770641911034	success	100	null
776nzi54s38p9kftaou8zpszzc	cleanup_desktop_tokens	0	1770991196522	1770991196782	1770991196789	success	100	null
unznqy5so7rfxb3thb7zpps7tc	expiry_notify	0	1770730772954	1770730782024	1770730782027	success	100	null
c6oi7cbdefgktc3ibj3o8ou4wo	expiry_notify	0	1770798399116	1770798402784	1770798402789	success	100	null
3pg6ugp1u3fmmmhw7xtj4qyi7y	expiry_notify	0	1770864884985	1770864898894	1770864898900	success	100	null
9hs9t4ykw7yxxpec3b8qza1csh	product_notices	0	1770731793032	1770731802414	1770731802510	success	100	null
zty4wuhpfpgg5dho14gs464ufw	expiry_notify	0	1770991796571	1770991797074	1770991797079	success	100	null
66fh7y36cjrszpa3ry38a79joe	expiry_notify	0	1770819520910	1770819532152	1770819532157	success	100	null
fdc3mafk9ir4jb5f483fzwpoao	cleanup_desktop_tokens	0	1770731973048	1770731982500	1770731982506	success	100	null
fwtqrsiwtpf83g4pronmfoid6o	product_notices	0	1770865005007	1770865018933	1770865019020	success	100	null
79gojodxp3gr88xepxe7sqbfgh	expiry_notify	0	1770840582815	1770840587179	1770840587186	success	100	null
7hf4dmfb13dz9dca9b8y95rwyw	expiry_notify	0	1770992456638	1770992457377	1770992457384	success	100	null
ym5fnw5mkb88xgdgckd7nypzte	expiry_notify	0	1770917569805	1770917572999	1770917573009	success	100	null
tq1gp4tmcidgbc85s3kpmctuha	expiry_notify	0	1770918229881	1770918233306	1770918233311	success	100	null
fjwgdnqet3roueqj1q1y93b8kc	expiry_notify	0	1770918889932	1770918893637	1770918893643	success	100	null
1an4ayfo67bfmpmjiupthwpozr	cleanup_desktop_tokens	0	1770918289898	1770918293329	1770918293336	success	100	null
4mrzxssahifxubcbzgqf5ktgec	product_notices	0	1770919009951	1770919013698	1770919013791	success	100	null
4urkai8istbo9c1uc7s93ujity	expiry_notify	0	1770920210064	1770920214279	1770920214284	success	100	null
fghx5kf5xbnxm8e9tqqndwn5eo	expiry_notify	0	1770942652192	1770942664970	1770942664976	success	100	null
xu1by445zp8bxk4iudzqgz7rga	expiry_notify	0	1770944632381	1770944645748	1770944645752	success	100	null
arhasko5wfdqugurw317de4nta	expiry_notify	0	1770943312234	1770943325239	1770943325242	success	100	null
rzqgq7zq5byjij1nzm98frqxhw	expiry_notify	0	1770943972297	1770943985506	1770943985509	success	100	null
35ssemntdpyrmchr6ju9bgmbwy	expiry_notify	0	1770966174375	1770966180665	1770966180673	success	100	null
8sd7p4o3op8ztxipuadeez1imo	expiry_notify	0	1770983275752	1770983287943	1770983287946	success	100	null
7tbpjpx98p8udfmbjmgf9ueefe	export_delete	0	1770983815815	1770983828230	1770983828234	success	100	null
kiiz33arkf8dj8zbs1si6xathe	expiry_notify	0	1770799059154	1770799063028	1770799063033	success	100	null
6rijddyfd7gd5non4m68we1wsy	expiry_notify	0	1770527295279	1770527303764	1770527303771	success	100	null
4boruusjk3n7tmqijkin3qmygh	expiry_notify	0	1770591921047	1770591923614	1770591923621	success	100	null
ir19ytguhbyoumjfmxybtd4htw	expiry_notify	0	1770753094878	1770753097240	1770753097248	success	100	null
txm44hn9hjd7pgpidewwgaktba	cleanup_desktop_tokens	0	1770527535311	1770527543856	1770527543861	success	100	null
coumm8zai7bszpch64b3uo5mcr	cleanup_desktop_tokens	0	1770863444888	1770863458269	1770863458275	success	100	null
4eqkgc8gf7bsxnb496d3k41odr	expiry_notify	0	1770592581138	1770592583953	1770592583959	success	100	null
oi4kkrfm7784fm59g5k4jofz6e	cleanup_desktop_tokens	0	1770666267549	1770666282293	1770666282297	success	100	null
yues5ixntjnmpci8ge7mr1hanr	cleanup_desktop_tokens	0	1770549437378	1770549439168	1770549439173	success	100	null
ibfdxi4agf84fjx63w9uymemga	expiry_notify	0	1770666267552	1770666282292	1770666282298	success	100	null
a859etfu5fd8xj3gebcoxwm79o	expiry_notify	0	1770993116690	1770993117698	1770993117701	success	100	null
hij8q8qm83dmbxj5rtothrk7iw	expiry_notify	0	1770593241193	1770593244257	1770593244262	success	100	null
e16tuuwgy7gb7j3grii43xtfbr	expiry_notify	0	1770549737416	1770549739322	1770549739325	success	100	null
49bq3q61r7di5kn1hu3tzfeuzo	expiry_notify	0	1770753754946	1770753757552	1770753757557	success	100	null
f3mosk3xaig9jnxbegrdo99oih	expiry_notify	0	1770667527645	1770667527790	1770667527793	success	100	null
x75jsbb7mib9dfpym5jo7hjodw	expiry_notify	0	1770572839437	1770572849550	1770572849557	success	100	null
7kabqafkei8h3kzfwfbryiq6xe	cleanup_desktop_tokens	0	1770593361219	1770593364325	1770593364332	success	100	null
pzwai39dxpg5zdz88pawmxurec	expiry_notify	0	1770863564907	1770863578328	1770863578335	success	100	null
ownye3u5eigf8x541kyjinwgew	product_notices	0	1770573379473	1770573389756	1770573389881	success	100	null
e73fm9tegtn1jkmeis16pfhj6r	cleanup_desktop_tokens	0	1770713731500	1770713734139	1770713734144	success	100	null
maktp7zu3ig5pffzbecx8zaanh	product_notices	0	1770616583216	1770616595062	1770616595155	success	100	null
pt8kc8a35iyh9yffajeetd38ny	expiry_notify	0	1770668187702	1770668188092	1770668188095	success	100	null
hr58yfktgj8ateha68u7ihyxer	expiry_notify	0	1770573499485	1770573509804	1770573509809	success	100	null
wao718xhwfbj7xjx74hzf7kniy	expiry_notify	0	1770774156855	1770774166588	1770774166594	success	100	null
snzjm58dy7rwmqb75dgirncw9y	expiry_notify	0	1770993776748	1770993777979	1770993777981	success	100	null
deh8p3omptftuxh91up3wwzjbo	expiry_notify	0	1770617543292	1770617555468	1770617555474	success	100	null
f9ua1tokw7fjjx8os7fcimuf8y	expiry_notify	0	1770668847736	1770668848376	1770668848378	success	100	null
xhw9qsffbin5ifqq5usdwz3kzr	expiry_notify	0	1770642565605	1770642571332	1770642571338	success	100	null
fdym11ihwtyi7d1fskoxcpjfra	product_notices	0	1770774996962	1770775006999	1770775007103	success	100	null
wdioh1pinpny3jsauk9a4f836c	product_notices	0	1770890207255	1770890215372	1770890215484	success	100	null
4dmezcwgetd35dju1uf7r6hrue	expiry_notify	0	1770669507785	1770669508640	1770669508645	success	100	null
hwhi7bp3ifyxmytadpekgn11jr	expiry_notify	0	1770643225654	1770643231647	1770643231651	success	100	null
aizf9jae8fdyjkj5qp9d6ea4by	expiry_notify	0	1770890627288	1770890635519	1770890635525	success	100	null
rtnz6grydjd6tg9yjwt39w4ura	expiry_notify	0	1770799719220	1770799723300	1770799723305	success	100	null
3p6fzjx3378qmq6zuqe4u1mw9r	expiry_notify	0	1770775476997	1770775487198	1770775487200	success	100	null
bpisugg483yb5bb3au9q8hr7ah	expiry_notify	0	1770643885692	1770643891910	1770643891914	success	100	null
7584srzmppdo8qqwhb85o67saa	expiry_notify	0	1770693209814	1770693219953	1770693219959	success	100	null
kcpba1j94pdcfr5ss3zmu4y5ge	product_notices	0	1770713791512	1770713794161	1770713794261	success	100	null
f3fhygdbapyt9crpa7r5san6tr	expiry_notify	0	1770713011421	1770713013795	1770713013802	success	100	null
3ydb674jstf6tn784esuui3ipo	cleanup_desktop_tokens	0	1770892667463	1770892676351	1770892676353	success	100	null
uuwbq3zth3yxfgiuqp7b77fa6y	expiry_notify	0	1770891947422	1770891956058	1770891956063	success	100	null
ihjsitgpzb8su816sexh5n9sja	expiry_notify	0	1770713671490	1770713674117	1770713674122	success	100	null
j7eeg5gjjirs8d6wue47khq4kh	expiry_notify	0	1770892607457	1770892616328	1770892616330	success	100	null
dt9zoya4xjdqpximbnesaugs7c	cleanup_desktop_tokens	0	1770819640933	1770819652224	1770819652230	success	100	null
6d1g7m8oejfsmew3z868rzhezc	expiry_notify	0	1770731433017	1770731442271	1770731442275	success	100	null
hwqohwigajntmywt5mk4c3sa8a	expiry_notify	0	1770841902931	1770841907832	1770841907837	success	100	null
ggciqmqedbyhtpy9syjjh6m9cy	expiry_notify	0	1770732093068	1770732102543	1770732102547	success	100	null
hh561nic9brx7dsemde5c7k6ew	expiry_notify	0	1770820841015	1770820852769	1770820852776	success	100	null
61nm9wozeb8d5phxsu5688q9ph	expiry_notify	0	1770841242872	1770841247504	1770841247510	success	100	null
mzfxgef9sbytfe1cjkqck6zd4h	expiry_notify	0	1770893267521	1770893276586	1770893276591	success	100	null
gcece7jy4pr75dktxnr5nhh8ha	expiry_notify	0	1770919549995	1770919553933	1770919553939	success	100	null
176p4x4qo3nzmqz4neq7r3ahtr	cleanup_desktop_tokens	0	1770943672268	1770943685409	1770943685411	success	100	null
uq7hg18tjpbg7d3i6tchkndd6h	expiry_notify	0	1770966834425	1770966840983	1770966840990	success	100	null
mzem6y4stby4zy3uxis7rxhuse	plugins	0	1770983815820	1770983828230	1770983828246	success	0	null
ehj789nid7giibhuad8ytksize	install_plugin_notify_admin	0	1770983815821	1770983828230	1770983828248	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
gqrp5hwad3yhbqranmuu6zju1c	expiry_notify	0	1771143970759	1771143982845	1771143982850	success	100	null
gydepmz3ntbmtd5w7uhabofxyh	product_notices	0	1771316229904	1771316236758	1771316236838	success	100	null
s1jnynjfgjdeibnx9puzmmhxfr	expiry_notify	0	1770527955344	1770527964064	1770527964071	success	100	null
du83xze77jnbbxmogs9m1fg53c	expiry_notify	0	1770593901262	1770593904581	1770593904585	success	100	null
k69y84erb3rctqiog65e7dorrw	expiry_notify	0	1770666927571	1770666942553	1770666942556	success	100	null
9ai1ucda6fro9p4duea6wqu74y	expiry_notify	0	1770754415032	1770754417897	1770754417900	success	100	null
gtj7byg8sbgk8c43n1ar5uk1mc	expiry_notify	0	1770550397454	1770550399585	1770550399591	success	100	null
pejtebxo67f3zk7jwdt63dktwo	expiry_notify	0	1770865545057	1770865559150	1770865559158	success	100	null
yz4ihr5o37n67n9361a3ce6pse	expiry_notify	0	1770618203341	1770618215714	1770618215721	success	100	null
97jzd9h5jtgp9enhanatqeob3a	expiry_notify	0	1770994436805	1770994438301	1770994438308	success	100	null
nk1k48rknifmxdqnohtyrizmca	expiry_notify	0	1770551057512	1770551059883	1770551059888	success	100	null
z5xm8qjk1b8jzdjnfgqgz4ejpw	product_notices	0	1770666987577	1770667002571	1770667002668	success	100	null
wq76h51rzid5bduxkr19sjf45h	expiry_notify	0	1770619523457	1770619536333	1770619536337	success	100	null
w5frf3pncibmprtsi9mk6hdqae	expiry_notify	0	1770574159542	1770574170112	1770574170119	success	100	null
9q5xi6bcjbd6xg843138xzmhua	expiry_notify	0	1770774816935	1770774826914	1770774826922	success	100	null
xypziw6ukfdc3d1fnngj4opsqa	expiry_notify	0	1770693869845	1770693880273	1770693880280	success	100	null
5ndumkp9ubf13xhup6dsuzx6ca	expiry_notify	0	1770621503644	1770621517207	1770621517213	success	100	null
ek44zdgxzir13knkidz89ufnke	product_notices	0	1770893807572	1770893816840	1770893816974	success	100	null
m83gdoj4gjdgfewxitr5y1ecaa	expiry_notify	0	1771018859190	1771018869959	1771018869966	success	100	null
yh8uzskjutdd7mnq8yb37us3ac	product_notices	0	1770800199261	1770800203523	1770800203625	success	100	null
u9yi39scyj88txcokh1if984xa	cleanup_desktop_tokens	0	1770644365734	1770644372144	1770644372148	success	100	null
4fb17ahiqin5mxeh3qergy9tyh	expiry_notify	0	1770714991603	1770714994722	1770714994728	success	100	null
55cc89izgb85f8398cb8np3gty	expiry_notify	0	1770995756912	1770995758955	1770995758960	success	100	null
4omtgk9xzpgtuj1pt34mzfhjew	product_notices	0	1770944212329	1770944225583	1770944225677	success	100	null
djywpkeixfr55jobiiimshf76e	expiry_notify	0	1770644545751	1770644552223	1770644552229	success	100	null
fwpcs1symbydxftns9ifzimnwa	expiry_notify	0	1770893927591	1770893936894	1770893936900	success	100	null
muh7khjh6fgo3d9frujx5rtoey	expiry_notify	0	1770732753121	1770732762884	1770732762890	success	100	null
uiag5r18xprwun1xx734384zor	expiry_notify	0	1770800379297	1770800383607	1770800383610	success	100	null
4s5upt9hyfbgfq68jimx5en1ce	expiry_notify	0	1770646525944	1770646533093	1770646533096	success	100	null
f91o8xxoofbn8kgowcroadxsyc	expiry_notify	0	1771008298151	1771008305071	1771008305078	success	100	null
z95t1snzt7rffbbso3ft18usyc	expiry_notify	0	1770733413157	1770733423210	1770733423214	success	100	null
zrmo7gpdbiytddgxqdcycqmm8y	expiry_notify	0	1770820180958	1770820192479	1770820192485	success	100	null
os8ced1cmtnazmyqbj373fu3ac	expiry_notify	0	1770894587636	1770894597190	1770894597194	success	100	null
4rig8deabbrqteye3fhu34ysbw	expiry_notify	0	1771008958224	1771008965386	1771008965391	success	100	null
sd6mg83c77fq3j9cc8h5krb96c	cleanup_desktop_tokens	0	1770841542901	1770841547663	1770841547668	success	100	null
qjnf1s8bsigf7xsz6auqeeb8we	expiry_notify	0	1770920870139	1770920874594	1770920874601	success	100	null
8wezfdys9pggdcktajwcgxn47c	product_notices	0	1771009018233	1771009025416	1771009025523	success	100	null
tqmhrw6cct8b9rhwd6rttkdw5w	expiry_notify	0	1770921530169	1770921534928	1770921534934	success	100	null
5k14owrzujf3ud3zfeh6868upo	expiry_notify	0	1770967494487	1770967501296	1770967501300	success	100	null
p6ixe38xh3yq7xrmms7gbg4gew	cleanup_desktop_tokens	0	1770921890217	1770921895125	1770921895130	success	100	null
me7cutt8dink3egazt1aoqo6uc	expiry_notify	0	1771032060359	1771032060772	1771032060775	success	100	null
aeucpf757tym5cpib8tnfjuwgr	import_delete	0	1770983815823	1770983828229	1770983828234	success	100	null
iu3uw1bwijb8mp9e4t9g96yc7w	expiry_notify	0	1771042561331	1771042565930	1771042565935	success	100	null
87zxrgeiffy1dqpsp3xkmw4qrw	expiry_notify	0	1771044541519	1771044546843	1771044546847	success	100	null
qp8bet6aui8z5xuf8a7ydtaqdw	expiry_notify	0	1771043221387	1771043226262	1771043226266	success	100	null
wmno5rf1k7bf7bjr4oqnddfg5e	cleanup_desktop_tokens	0	1771049401960	1771049409240	1771049409246	success	100	null
nrers73iyfn3mrknpo6ownnyih	expiry_notify	0	1771045201586	1771045207181	1771045207187	success	100	null
49t1barott8g9jk4zo9tsh5p4c	expiry_notify	0	1771058402818	1771058413501	1771058413508	success	100	null
nyhc7r3igfnxxxpgfj9a6eggzr	expiry_notify	0	1771063023319	1771063035689	1771063035696	success	100	null
59gqqcrns3d6mq31ftzuhpwsfy	product_notices	0	1771063023324	1771063035689	1771063035778	success	100	null
9oxah4ophjgpiehnkoiwfnb6ur	expiry_notify	0	1771064343427	1771064356337	1771064356343	success	100	null
fsiicf64qtfcfewnq1okh6hoqa	expiry_notify	0	1771065663573	1771065676960	1771065676963	success	100	null
oawqy9zqrtn7b8aqmth1ofyc7e	product_notices	0	1771066623649	1771066637353	1771066637449	success	100	null
9k95iqt6gfg7fj9yi8635agw4o	cleanup_desktop_tokens	0	1771067703762	1771067717863	1771067717869	success	100	null
xmz1si5sg78ofd8wj6tijqfjpw	expiry_notify	0	1771068303823	1771068318162	1771068318165	success	100	null
d8tu3yhecpr59mxfo4gbc4eyhh	plugins	0	1771070223972	1771070238839	1771070238855	success	0	null
hxxxyzugspyxppsshksmojim5c	expiry_notify	0	1770528615425	1770528624385	1770528624392	success	100	null
tnqyori6g3b4iggpyfm6nsw67r	expiry_notify	0	1770594561323	1770594564875	1770594564879	success	100	null
oxj9p3mcs7nz8ye5zttxk1o5ph	cleanup_desktop_tokens	0	1770669927831	1770669928805	1770669928810	success	100	null
k1q857fqifd83nbbbedwaa89hc	expiry_notify	0	1770755075091	1770755078157	1770755078160	success	100	null
n4knmj14ufbmdquggu3btrjb5y	expiry_notify	0	1770529275487	1770529284707	1770529284713	success	100	null
kzdwsim4xfgn7d9te35dgy338e	expiry_notify	0	1770866205115	1770866219466	1770866219472	success	100	null
se83jianxjgmbq3kirkp8spb4y	expiry_notify	0	1770595881420	1770595885347	1770595885352	success	100	null
c6mpbeircjdc5p573twf3jun8o	expiry_notify	0	1770551717546	1770551720155	1770551720160	success	100	null
uqki1asb4tybjgdseaocrskogh	expiry_notify	0	1770670167857	1770670168890	1770670168896	success	100	null
n6eq6krne7bm7xef9k4554azgy	cleanup_desktop_tokens	0	1770775777024	1770775787354	1770775787361	success	100	null
wrg73bndr7d4ddedm3dobceqje	expiry_notify	0	1770922850304	1770922855566	1770922855573	success	100	null
kme1i4uihfyetx9ppga5bp9wyw	product_notices	0	1770670587817	1770670588982	1770670589083	success	100	null
mnn3rds4xj8k3m5cib437fcuiy	cleanup_desktop_tokens	0	1770618863386	1770618876020	1770618876026	success	100	null
egq5a5smzbyzmg3wjdnqcisz6w	expiry_notify	0	1770618863391	1770618876020	1770618876026	success	100	null
9um5c3chwfbbbykot7jpqc4e6r	cleanup_desktop_tokens	0	1770867105196	1770867119934	1770867119940	success	100	null
z3ojkgj78fd1bfxbn4tnzth3yh	expiry_notify	0	1770821501074	1770821513076	1770821513082	success	100	null
u4i9ohowm3g1jn53c7djmcducr	expiry_notify	0	1770801039355	1770801043890	1770801043892	success	100	null
tota1yem7ifbugzeuu16zcukkr	expiry_notify	0	1770645205800	1770645212481	1770645212485	success	100	null
uhonwfjkdjyojbxmfyghxcuojy	expiry_notify	0	1770694529894	1770694540585	1770694540591	success	100	null
jyx4btt1mbfnxfi7jdtfit1i8o	mobile_session_metadata	0	1770551777568	1770551780173	1770551780180	success	100	null
9qsmsm9yu3raurxndthpx13bry	export_delete	0	1770551777566	1770551780173	1770551780185	success	100	null
hktxm46f33gmmeiprbx5sjn5nw	plugins	0	1770551777569	1770551780173	1770551780185	success	0	null
zjnh7eu6jtbn9gy1xxu96ukzme	import_delete	0	1770551777571	1770551780173	1770551780185	success	100	null
tebh9zkhwtrndjim7qmnrfy1wc	product_notices	0	1770645385827	1770645392559	1770645392658	success	100	null
gaco6twpztnyz8cqpbj7swjiko	install_plugin_notify_admin	0	1770551777570	1770551780173	1770551780193	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
o3skbp3tpfnk8fzrx9nscikrtw	expiry_notify	0	1770922190238	1770922195293	1770922195300	success	100	null
uo9t3hhuw7nn9kd3o75q1aabca	product_notices	0	1770551777561	1770551780173	1770551780266	success	100	null
uzi7d3jsjf8kzxhz55qpi6yxwy	expiry_notify	0	1770715651655	1770715655039	1770715655045	success	100	null
38rcqu4p3igfbyzohqx3gg9afr	expiry_notify	0	1770801699420	1770801704195	1770801704197	success	100	null
mkobzdxfsibn7yekcp75ydfe6e	expiry_notify	0	1770645865881	1770645872782	1770645872786	success	100	null
f5epegdyffy78rjf7mesqfmmdh	expiry_notify	0	1770575479654	1770575490696	1770575490702	success	100	null
p3sxfy8mmfnn8rb3md3fcfr3ee	expiry_notify	0	1770895247684	1770895257436	1770895257444	success	100	null
nt5by7kjnfdo9pgwt1sbxmeora	expiry_notify	0	1770735393369	1770735404140	1770735404147	success	100	null
6gxpwa7hiin1fnj76ok131jhnh	expiry_notify	0	1770716311691	1770716315329	1770716315333	success	100	null
h6k44z9d3p8njj59y633h471mc	expiry_notify	0	1770647185975	1770647193424	1770647193429	success	100	null
wawp8a377td5jj7wbcjrophgby	expiry_notify	0	1770802359486	1770802364483	1770802364485	success	100	null
rre8zj6b9pygdqiwsmbwe6s8gw	cleanup_desktop_tokens	0	1770648026060	1770648033853	1770648033858	success	100	null
7azgs3gyrjrsfm1fhhpgacha6r	expiry_notify	0	1770734073227	1770734083519	1770734083525	success	100	null
o8wd6z3gypbitji9de9p78cdyo	product_notices	0	1770735393373	1770735404140	1770735404236	success	100	null
4ti9zswhobfdzqir9jzww1ykjc	expiry_notify	0	1770734733291	1770734743836	1770734743840	success	100	null
b7kb84qtdtb9jrr7664ypqksnr	product_notices	0	1770821801118	1770821813249	1770821813339	success	100	null
qg73fa4e47rdzy3us4nycsh5rr	product_notices	0	1770922610284	1770922615476	1770922615576	success	100	null
8nfhfnohntg5fdqy9he1cye69w	cleanup_desktop_tokens	0	1770735633389	1770735644242	1770735644246	success	100	null
qjfqffus67n5iyya6d7p8paw4o	expiry_notify	0	1770842562986	1770842568144	1770842568147	success	100	null
b3ywpw5ptibd5c1bnux3o8jx7c	expiry_notify	0	1770947272561	1770947286989	1770947286993	success	100	null
gtyk6p9knfgc5pj9jk6xbqqnre	expiry_notify	0	1770946612523	1770946626645	1770946626654	success	100	null
ekkk9swnifftbkagei45e8jhma	expiry_notify	0	1770945292425	1770945306075	1770945306081	success	100	null
hrutikpfwpgzdqnds1gpprnq9c	cleanup_desktop_tokens	0	1770947332576	1770947347015	1770947347021	success	100	null
mdsy4dnpafnafxptydihzr6naa	product_notices	0	1770947812619	1770947827251	1770947827362	success	100	null
uka8ag15ojfobkjicbeha6n37o	expiry_notify	0	1770947932644	1770947947311	1770947947318	success	100	null
fnbgjq9csbdqzjxcfr4eif3qer	expiry_notify	0	1770968154535	1770968161606	1770968161613	success	100	null
foatr8x8q7833coddeodckwfeh	expiry_notify	0	1770968814585	1770968821910	1770968821914	success	100	null
wh9igace3i8hxb1dpny4iqqwnr	cleanup_desktop_tokens	0	1770969234641	1770969242105	1770969242109	success	100	null
jwoxj4pm3tfxzqm4rgjzp8573e	product_notices	0	1770969414690	1770969422207	1770969422322	success	100	null
xjm8gfb36tb5jj1f9anoxuq4ah	expiry_notify	0	1770969474701	1770969482239	1770969482244	success	100	null
zsjhq95793bfznj9xt3ob5d5oy	expiry_notify	0	1771019519253	1771019530292	1771019530298	success	100	null
ng8t5779wffdif9mqfgzrjepfy	product_notices	0	1770994616809	1770994618366	1770994618415	success	100	null
fksjukcuhtdsibbhjadu3wku5h	expiry_notify	0	1770529935543	1770529945018	1770529945026	success	100	null
qhknj4g67pnyic57x88xonh3hw	product_notices	0	1770594981367	1770594984987	1770594985094	success	100	null
e54dhr96r3fzxeq19xrxyfardh	expiry_notify	0	1770670827828	1770670829084	1770670829091	success	100	null
mgs8bie8jtnzxpzik74ift3tty	expiry_notify	0	1770755735162	1770755738420	1770755738427	success	100	null
e13eg3t33bgz9gj31q4ryu6uea	expiry_notify	0	1770530595624	1770530605332	1770530605337	success	100	null
xhpdkqc3mirmiri1cdrk95u74o	expiry_notify	0	1770866865169	1770866879802	1770866879808	success	100	null
67frfgmeqfg49m43tefofgt5jw	expiry_notify	0	1770695189941	1770695200831	1770695200833	success	100	null
kirky7ngutncpc1qe9bxrfd4oo	expiry_notify	0	1770552377615	1770552380425	1770552380432	success	100	null
zwnrpg4ubigkzeets4rtc1bqie	expiry_notify	0	1770595221388	1770595225071	1770595225079	success	100	null
6898t1unp3fz3rxq3fguarjcoo	refresh_materialized_views	0	1770595221383	1770595225072	1770595225092	success	100	null
9tfwoaqnqjr7idmhn5wx8r38kh	expiry_notify	0	1770553037651	1770553040706	1770553040710	success	100	null
7jmqbx1pctgd9k54u1drdyekpo	expiry_notify	0	1770776137064	1770776147530	1770776147537	success	100	null
ioonmkf3tjr7bnm3fbxnhdymyo	cleanup_desktop_tokens	0	1771009378269	1771009385605	1771009385610	success	100	null
ear4m3cnj7nnzcrat6k3e79wzy	cleanup_desktop_tokens	0	1770695429961	1770695440907	1770695440909	success	100	null
94bm7wz1ppfydr167gcfqt3yqa	cleanup_desktop_tokens	0	1770553097657	1770553100721	1770553100725	success	100	null
zmja4txzgbf7587ykq5ymaaumh	expiry_notify	0	1770596541458	1770596545631	1770596545634	success	100	null
9rj7nax78tdaumwywgruywh5cy	expiry_notify	0	1770895907723	1770895917711	1770895917719	success	100	null
d9ujbngrupnifd6ktkyhsk69mo	cleanup_desktop_tokens	0	1770994856842	1770994858483	1770994858489	success	100	null
6s5re8peu3du9gat56a7zgyfdo	expiry_notify	0	1770554357754	1770554361179	1770554361183	success	100	null
bs59x5w847btupacp4b5u88phr	cleanup_desktop_tokens	0	1770801399384	1770801404042	1770801404045	success	100	null
hoi9dn45bjn88mpikitijmauza	cleanup_desktop_tokens	0	1770597021491	1770597025848	1770597025852	success	100	null
8oy84wyakbd5xb5po1hef7f8pe	expiry_notify	0	1770716971745	1770716975629	1770716975635	success	100	null
nmd6w4end38wtgqf5uzhn1tx5h	expiry_notify	0	1770576139729	1770576151018	1770576151024	success	100	null
scwu6u7kgpd9myekorfk3zjbre	expiry_notify	0	1770945952468	1770945966381	1770945966388	success	100	null
eet8cweedpgb8nnnzounix4j8h	expiry_notify	0	1770597201518	1770597205936	1770597205940	success	100	null
h3yn39pttfr3jyt1c7b3e1bpay	cleanup_desktop_tokens	0	1770896327757	1770896337869	1770896337874	success	100	null
r3n4x6m4dpbfjye8km1a5apuby	expiry_notify	0	1770717631815	1770717635910	1770717635916	success	100	null
81r53tiea3fhxc48rqpc1x6ser	expiry_notify	0	1770822161165	1770822173417	1770822173423	success	100	null
m7m8g5ytk7r3zjzi4oajqigxmw	expiry_notify	0	1770597801573	1770597806221	1770597806226	success	100	null
t16q6xrkmbgjbppajsztr4htjo	expiry_notify	0	1770718291857	1770718296188	1770718296192	success	100	null
1eoqitmtip8sxxyerrtkt4iy6w	expiry_notify	0	1770995096857	1770995098628	1770995098634	success	100	null
bdfxba8wstdfjdc6b67dy97gow	expiry_notify	0	1770843223014	1770843228483	1770843228490	success	100	null
bphitoazd3bu8r59m55rmzstxe	expiry_notify	0	1770620183538	1770620196603	1770620196606	success	100	null
mkogzogoctg4mxcbkzbe9a8wfy	expiry_notify	0	1770896567786	1770896577986	1770896577990	success	100	null
gkwqs3hj9td5ixqfnzddkb451h	product_notices	0	1770620183545	1770620196603	1770620196690	success	100	null
s8xzrzymwinu98ohq3rtgh61ta	expiry_notify	0	1770736053418	1770736064398	1770736064402	success	100	null
d9fydtg98tg39gsrho3wgqxyuw	expiry_notify	0	1770647846041	1770647853753	1770647853759	success	100	null
ygnkkqpgoidduc5twgxtejxj4a	product_notices	0	1770843403041	1770843408571	1770843408695	success	100	null
scb7wpacqpda7nui4mf84sdomy	expiry_notify	0	1770736713503	1770736724738	1770736724742	success	100	null
c5un4jdpfb8kff3buxhwj7i8nr	expiry_notify	0	1770923510359	1770923515850	1770923515857	success	100	null
emj58hpkw7r98redhe1kzq1i6y	expiry_notify	0	1771011598450	1771011606631	1771011606635	success	100	null
bxsksgizxf8djx43drxowskmoa	expiry_notify	0	1770970134749	1770970142558	1770970142565	success	100	null
xns7ma3uopdabfodkonnw7op1w	mobile_session_metadata	0	1770983815818	1770983828230	1770983828244	success	100	null
yzwmmjia57g1dqt44a5x3styph	expiry_notify	0	1771032720438	1771032721095	1771032721101	success	100	null
6zkr6e7ga7gt7qj3ddzi5hrqfa	expiry_notify	0	1771020179324	1771020190583	1771020190588	success	100	null
x3uxq961njdt3x3t4rfugywrze	product_notices	0	1771019819293	1771019830425	1771019830524	success	100	null
e8pgydfjwbgop854z8r74u6syr	expiry_notify	0	1771043881446	1771043886573	1771043886580	success	100	null
ebb4d9sm9f87xroqg9pbinrkdh	expiry_notify	0	1771050482078	1771050489807	1771050489810	success	100	null
9opyxnenm3ybfc1ua7zi4rsp1h	product_notices	0	1771052222262	1771052230600	1771052230706	success	100	null
4imp5hx3yif55gudzd7jdswpye	expiry_notify	0	1771052462293	1771052470713	1771052470717	success	100	null
w7747gu8jiffpcnjewbu5ga14o	cleanup_desktop_tokens	0	1771053062319	1771053071001	1771053071007	success	100	null
55md8bab6bd9fbbp1u18pcfody	expiry_notify	0	1771053122334	1771053131040	1771053131047	success	100	null
jsqbqi4ag7d87qcwzn1ujckd5c	expiry_notify	0	1771059062876	1771059073822	1771059073825	success	100	null
9pwu38rtzjyc9ctwgfte3xpbho	cleanup_desktop_tokens	0	1771144270790	1771144282995	1771144283001	success	100	null
bu8kz8566f8hpqq7k5557jw5xc	expiry_notify	0	1770803019538	1770803024788	1770803024794	success	100	null
xjpg5sxy7j8uxe9u1aukygbkmr	product_notices	0	1770530175573	1770530185127	1770530185242	success	100	null
hi9mtocz13yipnnbj9ehgyw6je	expiry_notify	0	1770598461606	1770598466535	1770598466541	success	100	null
t6af137tdjgn7p7pz1xyrgirkw	expiry_notify	0	1770671487867	1770671489364	1770671489371	success	100	null
fipu6j1rtjgnifafp6r7miymoc	expiry_notify	0	1770756395199	1770756398660	1770756398665	success	100	null
wrfarskzwtng5kwici8bthz8oy	expiry_notify	0	1770553697700	1770553700926	1770553700932	success	100	null
n93hea3u7jd1dejastzpjcipce	expiry_notify	0	1770924170401	1770924176133	1770924176140	success	100	null
464pbrdhqt8rueo6menzimsoua	product_notices	0	1770598581623	1770598586594	1770598586709	success	100	null
qmhssu9ss3y9p8uzyrpg3zou3w	expiry_notify	0	1770867525231	1770867540139	1770867540146	success	100	null
6k496art8fn9z83z8cn7t33knw	expiry_notify	0	1770576799776	1770576811274	1770576811280	success	100	null
11kh94ogri8iufmokhg8p95n6o	expiry_notify	0	1770672147909	1770672149679	1770672149684	success	100	null
qrr7fhgccin4bk9w33wm5nkqro	expiry_notify	0	1770620843597	1770620856923	1770620856931	success	100	null
wdut3oc3nbrw8mxc7kukikujmy	product_notices	0	1770576979802	1770576991372	1770576991501	success	100	null
zrwb8rjos3fkxqyp4my8sa893y	expiry_notify	0	1770776797138	1770776807831	1770776807835	success	100	null
otctdifdmbfs5k4qq8jws4oder	expiry_notify	0	1770996416973	1770996419354	1770996419361	success	100	null
8n3tm9b8hfgutb4rb8b3gyhury	product_notices	0	1770695789997	1770695801056	1770695801154	success	100	null
qtd59i9eu3dyfpqt3pjphmq8th	expiry_notify	0	1770577399846	1770577411545	1770577411549	success	100	null
q1p68ttddjys8przoik6g6q98r	expiry_notify	0	1770648506090	1770648514079	1770648514083	success	100	null
j79b44yfh78mjcxwhaak3mqoyc	expiry_notify	0	1770868845359	1770868845663	1770868845667	success	100	null
m398pncz37bk5g83rteeixp8qo	product_notices	0	1770738993658	1770739005694	1770739005836	success	100	null
i4orjcui63d4pneik8ccizmtny	product_notices	0	1770648986151	1770648994257	1770648994348	success	100	null
kbkswn3inirg8gk5g66ud9uu1a	expiry_notify	0	1770695850005	1770695861075	1770695861079	success	100	null
657rqane5j8j38j5juqxiey1qe	expiry_notify	0	1770777457188	1770777468149	1770777468156	success	100	null
ecduszwjzb89myayii3jmnkdhy	expiry_notify	0	1770649166180	1770649174348	1770649174352	success	100	null
jst1zbgg9tystkdswwouu5stnw	expiry_notify	0	1771009618307	1771009625723	1771009625731	success	100	null
ja7fssj5o7gs7xksrmg78mwepe	expiry_notify	0	1770696510050	1770696521359	1770696521363	success	100	null
jkphjrfop7gjj89x7qy8s846ar	expiry_notify	0	1770845863281	1770845869769	1770845869773	success	100	null
6agnocf8jtg8xb35k4chwx5yzc	expiry_notify	0	1770650486303	1770650494906	1770650494910	success	100	null
w5fsm1egytft5k3g5p4wbxp8wo	expiry_notify	0	1770778117234	1770778128439	1770778128443	success	100	null
hq53ch1xj7gx7rhboeor8i43ie	cleanup_desktop_tokens	0	1770717331777	1770717335768	1770717335773	success	100	null
iahfgrr49trr5mjue6yeo97biy	expiry_notify	0	1770897227875	1770897238330	1770897238336	success	100	null
aojqjqhfyjfptgqg5mm7efwioa	expiry_notify	0	1770822821217	1770822833751	1770822833757	success	100	null
uouoikyrmirs3ry98aar5qqpor	product_notices	0	1770778597281	1770778608639	1770778608757	success	100	null
ufia73wc47ypzeattjorfxwtwc	product_notices	0	1770717391786	1770717395791	1770717395895	success	100	null
mq13uyb57iywzkzsx6ofzpujkw	expiry_notify	0	1771010278342	1771010286002	1771010286007	success	100	null
szfrdqdfifrd7xbx8hqjr7hj6y	cleanup_desktop_tokens	0	1770739293692	1770739305819	1770739305824	success	100	null
ex7rg337wfyqzcjf8w8u3abjgo	expiry_notify	0	1770737373545	1770737384948	1770737384954	success	100	null
9ynfhx6hojg4ugnccy5ek34bcr	expiry_notify	0	1770778777292	1770778788713	1770778788718	success	100	null
56rsrabzd7r1bjy8t3dn3y6ijc	product_notices	0	1770926210635	1770926217158	1770926217259	success	100	null
o5t1rj6dffr6bfsz1wpfagmrua	expiry_notify	0	1770738033591	1770738045221	1770738045226	success	100	null
wb94uumb5frw58759xamfe6tpe	expiry_notify	0	1770924830496	1770924836477	1770924836482	success	100	null
iha34pe8s3gwxehkejyg3p74te	cleanup_desktop_tokens	0	1771020299350	1771020310643	1771020310648	success	100	null
zmm4rujgjtn9bf1h3eux9ft36h	expiry_notify	0	1770738693628	1770738705539	1770738705544	success	100	null
om7cf1qcd3d4bpbupwzyxryo9a	expiry_notify	0	1770739353707	1770739365859	1770739365863	success	100	null
xhwi51n8e3yxuy6i8fqn8df4tr	cleanup_desktop_tokens	0	1770823301236	1770823313969	1770823313973	success	100	null
huysckotapg33ntm1bg8jbhpjr	expiry_notify	0	1770926150624	1770926157115	1770926157119	success	100	null
sspxib5oofr19bsddpcyziz9rc	expiry_notify	0	1771033380496	1771033381383	1771033381388	success	100	null
n9oreo43ninhzgj1qq5unt7x1o	expiry_notify	0	1770823481256	1770823494048	1770823494054	success	100	null
tdf5dzhydino9fnkmx6oa6nqrw	expiry_notify	0	1770970794790	1770970802801	1770970802806	success	100	null
1f4y9139h3r13jb77wm7tsyxpy	expiry_notify	0	1770948592724	1770948607620	1770948607626	success	100	null
o1zenzs767y59xndqgpshmqwgr	expiry_notify	0	1770843883080	1770843888829	1770843888833	success	100	null
94p6kx1ngbyitnz37pbhwbf8ne	expiry_notify	0	1771034040586	1771034041707	1771034041712	success	100	null
9sskgbb31py3xjuk9oxy1k6pjc	product_notices	0	1770983815810	1770983828229	1770983828292	success	100	null
35oue38gxinqidyp4sw9xc94yr	product_notices	0	1771034220599	1771034221798	1771034221905	success	100	null
dtag85mh5idbxc17fyjbh5gybr	cleanup_desktop_tokens	0	1770983875838	1770983888266	1770983888270	success	100	null
nx8goy3gbjdcjcxmzihucm5qph	expiry_notify	0	1770983935853	1770983948291	1770983948296	success	100	null
qk8xoaabdjyc7p57xs4bu4n4ze	expiry_notify	0	1770803679594	1770803685073	1770803685081	success	100	null
5o9oc8prn3ba3qyddqbdnygoge	cleanup_desktop_tokens	0	1770531195648	1770531205595	1770531205602	success	100	null
xg95t7yfgpbu3ggmywjedb8w5c	expiry_notify	0	1770599121686	1770599126837	1770599126843	success	100	null
xcyyikq5cfr7ucqc9tt5f79ane	expiry_notify	0	1770672807942	1770672809959	1770672809965	success	100	null
b9beoowt7b8z3qpa5oxtajs3fy	product_notices	0	1770756995237	1770756998871	1770756998978	success	100	null
cr74k33wyiyw7fawxjek5ayamw	expiry_notify	0	1770531255659	1770531265633	1770531265639	success	100	null
cswo5obtityaxgngw3uksihp5o	export_delete	0	1770897407901	1770897418422	1770897418428	success	100	null
qmke5qddbiyjidjnk58rernr7h	expiry_notify	0	1770622163703	1770622177511	1770622177518	success	100	null
n59curmeytdq3cdjq16zxpdque	expiry_notify	0	1770868185297	1770868185421	1770868185427	success	100	null
jchj8b9ifpdttcjgkhftiodfae	expiry_notify	0	1770531915719	1770531925868	1770531925875	success	100	null
xm8jrcdrcp8o9ngw4zuj7ucjwa	expiry_notify	0	1770673468176	1770673470496	1770673470500	success	100	null
soxqsx7tqjfyxgh8r8ktpznbxh	expiry_notify	0	1770622823778	1770622837755	1770622837761	success	100	null
smrugx34hjrsdgfsphkcorocdy	expiry_notify	0	1770555017796	1770555021429	1770555021435	success	100	null
fs3369usjb8xufapwg67tasiwh	expiry_notify	0	1770757055256	1770757058898	1770757058904	success	100	null
7zhibpc4stngbefcnj37dpswtr	expiry_notify	0	1770997077010	1770997079664	1770997079670	success	100	null
xprn35b9ijf57mz7yub36jty6o	cleanup_desktop_tokens	0	1770673528190	1770673530530	1770673530535	success	100	null
4ub1i61e97bi7pe58ezfg5ecww	product_notices	0	1770555377834	1770555381566	1770555381681	success	100	null
fmp38n4tkp8rmkrierczaw9h6w	expiry_notify	0	1770649826226	1770649834636	1770649834642	success	100	null
drjfdt5bspf3ibgdamwtri7xea	expiry_notify	0	1770555677863	1770555681692	1770555681696	success	100	null
9eto3bni1py97kg6cz15hreygo	cleanup_desktop_tokens	0	1770757535308	1770757539125	1770757539131	success	100	null
sj6zrez8nbbmpgmnig19srsdoh	expiry_notify	0	1770675448343	1770675451393	1770675451397	success	100	null
7w7nuo1qzbfodjqxzd1fk1fnte	expiry_notify	0	1771010938396	1771010946331	1771010946335	success	100	null
tknrcu75d7frucg4spb6sqc6ba	expiry_notify	0	1770556337940	1770556341958	1770556341962	success	100	null
a76dc3qnspycuntx4dy566dfzo	expiry_notify	0	1770676108385	1770676111664	1770676111669	success	100	null
1iaishzcatr1uetrb1zezkbd7a	cleanup_desktop_tokens	0	1770556757966	1770556762141	1770556762146	success	100	null
a9w1fngqffr7upa8cszya6uq8o	expiry_notify	0	1770757715333	1770757719207	1770757719211	success	100	null
s8d1q1p7s7gt7xpk1domb99bsy	expiry_notify	0	1771012258528	1771012266946	1771012266950	success	100	null
hnttxw341p81mn1p393zuo4eyw	expiry_notify	0	1770556997992	1770557002261	1770557002266	success	100	null
yih4afodrtg1dcrgtud9tqiwgo	expiry_notify	0	1770697170102	1770697181653	1770697181659	success	100	null
b9ei6rxdqjydurb6wcrbge66gy	product_notices	0	1771012618576	1771012627129	1771012627236	success	100	null
r7h1biwes3yx7jzhejxtrsx4me	expiry_notify	0	1770578059889	1770578071866	1770578071873	success	100	null
u38eriqowjgfdq991jysy8a3gh	expiry_notify	0	1770824141351	1770824154366	1770824154373	success	100	null
u5jkeycjq3nn3fssp3jqxsggho	expiry_notify	0	1770718951932	1770718956520	1770718956527	success	100	null
8e6cmbbyej8ttrekra9zeuxw6o	cleanup_desktop_tokens	0	1770779437351	1770779449042	1770779449048	success	100	null
k56zpxdqgbdqu89trp8fqm5jqa	cleanup_desktop_tokens	0	1770578719934	1770578732192	1770578732197	success	100	null
y4ugykwudprgtgfniuqzf4dmzr	expiry_notify	0	1770779437355	1770779449042	1770779449048	success	100	null
7h5fwhcfqfrz5ri9j8c35uwgbh	expiry_notify	0	1770740013778	1770740026224	1770740026226	success	100	null
iy9qdof3sjrdbrj8nm3wzexahr	expiry_notify	0	1770578719928	1770578732192	1770578732210	success	100	null
zyczn7euyjrhpmjy47hw33fyrr	import_delete	0	1770897407907	1770897418422	1770897418427	success	100	null
r55mke3w4fbp5gf5g6xmzqwoua	mobile_session_metadata	0	1770897407903	1770897418422	1770897418428	success	100	null
bbe6f5uif7g978t45tae9ca6dc	install_plugin_notify_admin	0	1770897407906	1770897418422	1770897418430	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
i5fjqpiokf8z3bydyijecmrjec	expiry_notify	0	1771020839361	1771020850873	1771020850880	success	100	null
44hpwkxcupftufmjdjtenc968c	expiry_notify	0	1770844543142	1770844549094	1770844549097	success	100	null
duw4dw5ndpnx9rxiyyamemwkuy	plugins	0	1770897407905	1770897418422	1770897418436	success	0	null
d5f1stjp6trrj851s6oz3jhpca	product_notices	0	1770897407896	1770897418422	1770897418518	success	100	null
nm5qqmnhfpykzx5ko4hh7ky9my	expiry_notify	0	1770949252778	1770949252930	1770949252936	success	100	null
1ngsphozz3nj3mt53k3i858h5a	expiry_notify	0	1771021499416	1771021511192	1771021511197	success	100	null
kjoc7793yibqtnf8y65icf5q5e	cleanup_desktop_tokens	0	1770925490562	1770925496755	1770925496760	success	100	null
jmhws3chhbfwppq5c95tzmww3r	expiry_notify	0	1770925490566	1770925496755	1770925496760	success	100	null
qjhb5h9c73d9xp85fif47qqy3o	expiry_notify	0	1770950512877	1770950513514	1770950513519	success	100	null
1qke84nbdbnfuq6thu31afkg9w	expiry_notify	0	1770949912842	1770949913242	1770949913247	success	100	null
3quqywaj8pdn5yazems9pjesja	cleanup_desktop_tokens	0	1770950992916	1770950993746	1770950993751	success	100	null
rt4gany9ifgktnhoqbpxfyo8tc	product_notices	0	1770951412979	1770951413950	1770951414058	success	100	null
5mu6zd1n9bnxzgczjczram39dy	expiry_notify	0	1770971454840	1770971463027	1770971463032	success	100	null
6eq885iz4pgqtej3ft53cs3n8r	expiry_notify	0	1770984595890	1770984608599	1770984608604	success	100	null
9mqe4wdsip8q8c6jgrxuz3wsea	expiry_notify	0	1771316409927	1771316416851	1771316416860	success	100	null
6dsxfikwkpbxpxuntetns8s8bh	expiry_notify	0	1770532575745	1770532586162	1770532586169	success	100	null
xjtak3hrgtymigm4dg75dsyguw	expiry_notify	0	1770599781732	1770599787137	1770599787144	success	100	null
bzmoniyhgtnp5fgzegwx5k4z6e	expiry_notify	0	1770674128239	1770674130813	1770674130820	success	100	null
5rxd446xptykxynacjsr9o9d7a	expiry_notify	0	1770758375377	1770758379522	1770758379524	success	100	null
cwhbk1owst8y9r7njenfkjrf4w	expiry_notify	0	1770557658050	1770557662553	1770557662560	success	100	null
rp6cujhyijd5ujw6qx7t8s3z6r	product_notices	0	1770868605334	1770868605572	1770868605677	success	100	null
ipw4e11sqjn1dgh9bb43axe93y	expiry_notify	0	1770600441791	1770600447475	1770600447479	success	100	null
e5j7th77a7gqfkeunpu93wi4do	expiry_notify	0	1770997737078	1770997739989	1770997739997	success	100	null
trdzuurfk3d6bes533otes7syr	product_notices	0	1770674188250	1770674190849	1770674190948	success	100	null
icpy8xe1bidx7fufxkc6sosfqr	expiry_notify	0	1770558978126	1770558983144	1770558983149	success	100	null
m4ffo8cc4id3tnqhdf78jqwbpa	cleanup_desktop_tokens	0	1770600621817	1770600627566	1770600627572	success	100	null
7ti8d8rsc7d9pbtnt4gaat68cr	product_notices	0	1770558978132	1770558983144	1770558983415	success	100	null
aknhaf14n7diubwgatx1egahkr	expiry_notify	0	1770780097437	1770780109350	1770780109356	success	100	null
1tb6axce7pgkpeu6q9r9sxth4a	expiry_notify	0	1770674786314	1770674789093	1770674789097	success	100	null
yfuyodtn5fbezgjz3u8sytpshy	expiry_notify	0	1770579379990	1770579392521	1770579392525	success	100	null
u4i9say4t7yaxquwos8dz8sdqa	expiry_notify	0	1770601761933	1770601768125	1770601768129	success	100	null
1j34cqnicbbjdx8zx6uqifzeyo	expiry_notify	0	1770897887941	1770897898647	1770897898653	success	100	null
76o79h7mdj85jm3oqpw94mmpjc	expiry_notify	0	1771012918624	1771012927245	1771012927247	success	100	null
dxurkpmjkt8spxmyz77iwjmm1w	expiry_notify	0	1770580040050	1770580052806	1770580052810	success	100	null
73agyuc7kfb6tmromi8pg6eswo	expiry_notify	0	1770780757500	1770780769673	1770780769677	success	100	null
7kfergbiubgntgyhd4u8nqrq7h	product_notices	0	1770602181991	1770602188330	1770602188428	success	100	null
hcu7nh5kutdjufkcmzukzaw3tw	expiry_notify	0	1770697830150	1770697841974	1770697841981	success	100	null
txmet8ftu7bppx61rhubhda67o	product_notices	0	1770580580135	1770580593117	1770580593248	success	100	null
a8g3zts7ki849d6m9wt1qx9piw	expiry_notify	0	1770951172949	1770951173846	1770951173854	success	100	null
rhxi9qgtbpbu9gteyk4nynszea	cleanup_desktop_tokens	0	1770622463733	1770622477635	1770622477641	success	100	null
a719opiyptbgjds3zx1yawqifa	expiry_notify	0	1770825461494	1770825474908	1770825474913	success	100	null
9cb9gtacajf35k5o5otecc4dbh	expiry_notify	0	1770698490226	1770698502302	1770698502306	success	100	null
b4kgz1dedfnp9g6zrnr4sq8ofc	product_notices	0	1770803799605	1770803805117	1770803805214	success	100	null
cwxejr8w6bbm3joidxkx7nim3r	expiry_notify	0	1770651146359	1770651155215	1770651155222	success	100	null
84ndjggno7nsdfhanwrhxjnega	expiry_notify	0	1770926810683	1770926817451	1770926817456	success	100	null
ggrgmho1ipda9eaahdi7g1nk3e	expiry_notify	0	1770719612000	1770719616838	1770719616844	success	100	null
d77a43hz7pnnbd3qd68n9unf3o	product_notices	0	1770652586504	1770652595901	1770652596002	success	100	null
ew58pu5q3ibebfk4ukfpc4y47a	cleanup_desktop_tokens	0	1771012978639	1771012987267	1771012987270	success	100	null
8naq6nhiyf8q9my1x8z6coknic	expiry_notify	0	1770805659767	1770805665990	1770805665994	success	100	null
o9q8uicjj3gqtf5j64ax8yeg6a	expiry_notify	0	1770720272040	1770720277129	1770720277133	success	100	null
oyfgihca3i8jjfccfugqx5wyec	expiry_notify	0	1770972054861	1770972063233	1770972063238	success	100	null
qkrr1t5f3tf7znkctj9tujm5ie	expiry_notify	0	1770951833025	1770951834131	1770951834133	success	100	null
kbgrhtri3f85tb5xzmsppxar8a	expiry_notify	0	1770824801419	1770824814654	1770824814660	success	100	null
aqchskcg1iyn8fdicrzsc4fwew	expiry_notify	0	1770740673849	1770740686494	1770740686500	success	100	null
m1acwepoyp8m3xhfn95i9xdser	expiry_notify	0	1771022159476	1771022171447	1771022171449	success	100	null
5yd5orytwtynuxdp86d9t78f3r	expiry_notify	0	1770741333925	1770741346787	1770741346791	success	100	null
fsd73d7fb7gr9kge8gjreyywjh	product_notices	0	1770825401486	1770825414890	1770825414991	success	100	null
7um1mcgeytr1jxjni491y5izre	cleanup_desktop_tokens	0	1770826901561	1770826915491	1770826915496	success	100	null
ypnhb5ubfir3icodi3k89k6oyw	expiry_notify	0	1771022819577	1771022831706	1771022831708	success	100	null
8i1nfwhn6jbtmm7br4ucogoeuw	expiry_notify	0	1770972714887	1770972723460	1770972723464	success	100	null
septtdqkcpn1brbumwhamecn8a	cleanup_desktop_tokens	0	1770972894897	1770972903532	1770972903537	success	100	null
5tz156r6x7nsxn3noy6craywho	cleanup_desktop_tokens	0	1770845203219	1770845209434	1770845209439	success	100	null
xze8fpw7s3gziqfzmgydb76k3y	product_notices	0	1770847003426	1770847010292	1770847010384	success	100	null
4t4p394er389jqunchdfmt91iw	expiry_notify	0	1770845203222	1770845209434	1770845209440	success	100	null
6gh9j7m7bbyn3g1fsqbktc5zyw	product_notices	0	1771023419622	1771023431888	1771023431972	success	100	null
xe18cpgyaprkufq1s936rod4he	product_notices	0	1770973014910	1770973023578	1770973023658	success	100	null
8gxr38amx78mdgjhwp6ry8e3rw	expiry_notify	0	1770846463359	1770846470019	1770846470023	success	100	null
xxhybqiou7y19jmbcepu99ja5a	expiry_notify	0	1770847123442	1770847130347	1770847130354	success	100	null
gebg5swjwi8o7bmoepgg6pxfke	expiry_notify	0	1770974034940	1770974043940	1770974043944	success	100	null
7bhftnfor7ruxyxhofrw4rgpqo	expiry_notify	0	1770847783508	1770847790630	1770847790634	success	100	null
y5jmmfzuitf35gxuimnpymq7yy	expiry_notify	0	1770985255958	1770985268949	1770985268955	success	100	null
wjz19uzkcbnufccn7gnpawmkfr	expiry_notify	0	1771144630837	1771144643158	1771144643163	success	100	null
5dxc6kz6pf8tijo6ufkbzq3gpa	expiry_notify	0	1770998397138	1770998400298	1770998400303	success	100	null
mpeabi9bwbfr7f8u6jmh7mk5re	expiry_notify	0	1770533235842	1770533246488	1770533246493	success	100	null
tc3y6u4bh3fy9pskcfya5k63uo	expiry_notify	0	1770601101886	1770601107807	1770601107813	success	100	null
73oiuyqqo7gn7kfd8nfiwsbhfy	expiry_notify	0	1770676766461	1770676769971	1770676769978	success	100	null
bk7d9x6dg3d15ypqmmwhbfuiwo	expiry_notify	0	1770759035453	1770759039787	1770759039794	success	100	null
ewx4udi87tfc8ee4xidd19quwr	cleanup_desktop_tokens	0	1770534796014	1770534807215	1770534807218	success	100	null
hm1k5qwcypduujb4k7bbw8mukw	expiry_notify	0	1770869505416	1770869505936	1770869505939	success	100	null
pcmrrbrgzfnmbkxnxbr5ewdb3h	expiry_notify	0	1770602422021	1770602428451	1770602428454	success	100	null
8rowfgf3kf8wxf6hqbibqmyp3r	expiry_notify	0	1770722252249	1770722258042	1770722258047	success	100	null
bqiga6en63b7ze77z5oujpabcc	expiry_notify	0	1770558318100	1770558322855	1770558322862	success	100	null
di69io6f4jbdupamtzocqsz8dy	cleanup_desktop_tokens	0	1770677126500	1770677130100	1770677130105	success	100	null
z8zgjm1j8prcjpmb18wcdqqz3c	product_notices	0	1770998217119	1770998220203	1770998220300	success	100	null
ffmspxk5yjd58yc17hspupxpsy	expiry_notify	0	1770603082055	1770603088752	1770603088756	success	100	null
4dum5dcko38mffb7tydxjczydy	expiry_notify	0	1770759695515	1770759700069	1770759700075	success	100	null
m6dtffce5t8qxd1o8g17wsad1w	cleanup_desktop_tokens	0	1770699090276	1770699102566	1770699102570	success	100	null
7h1r4zi9pig778ffd6j4o5ea4o	expiry_notify	0	1770623483858	1770623498036	1770623498043	success	100	null
nzcu4c766jde5rtearb4as7npa	expiry_notify	0	1770870165484	1770870166204	1770870166210	success	100	null
35o4iqk3n78w7ew9j74huktu1h	expiry_notify	0	1770848443570	1770848450951	1770848450957	success	100	null
rgynt8ducfb9uqahi89u4kqftr	product_notices	0	1770623783880	1770623798139	1770623798224	success	100	null
pf5spwi9aj8zzcgskzz8gg7zje	expiry_notify	0	1770699150289	1770699162591	1770699162597	success	100	null
589ki7wa4jdn3px1as6mk411gw	expiry_notify	0	1770760355541	1770760360365	1770760360370	success	100	null
jhrmdkc3xffmteacwncz1aqbbo	expiry_notify	0	1770625464052	1770625478827	1770625478829	success	100	null
kgk1q87cw3bqjy5ehzt7h1yu8a	expiry_notify	0	1770699810345	1770699822927	1770699822931	success	100	null
swo5asxe6fr9xd11b7gwwcf1po	expiry_notify	0	1770927470742	1770927477757	1770927477760	success	100	null
j5uq1kf6s3b7fr4z9zf3o77b6e	product_notices	0	1770760595552	1770760600463	1770760600576	success	100	null
eue8kq7hyby5ufpca97d4ynpfc	expiry_notify	0	1770871485592	1770871486809	1770871486814	success	100	null
qps8bhe7bt8f7emzb1eyj5fm5y	expiry_notify	0	1770626124097	1770626139063	1770626139067	success	100	null
6tg6uawgzjbeicez1dj11iqg3o	expiry_notify	0	1770700470416	1770700483207	1770700483211	success	100	null
hhboiqjoffdcm8x4hsb93bi14o	cleanup_desktop_tokens	0	1770626124091	1770626139064	1770626139068	success	100	null
ubaquechs3g7feghh8mhf1r9go	expiry_notify	0	1770781417565	1770781429999	1770781430002	success	100	null
hgen4c4qftysfn86mxfh8irbzy	cleanup_desktop_tokens	0	1770651686419	1770651695474	1770651695480	success	100	null
89nkcaqkffgctq7zd1mq7z3fje	expiry_notify	0	1770720932109	1770720937428	1770720937435	success	100	null
1peu4s993ifebrt3qqefzkbsma	expiry_notify	0	1770898487989	1770898498914	1770898498920	success	100	null
1h43qtwwmt8uir8hbzm1sb9xiw	expiry_notify	0	1770872145653	1770872147142	1770872147146	success	100	null
9pp671haytbtdegc89wms4rf9o	expiry_notify	0	1770651806438	1770651815532	1770651815538	success	100	null
ndxecumoebbexfj1in7t947kne	cleanup_desktop_tokens	0	1770998517158	1770998520352	1770998520354	success	100	null
bj4hpjjr638sxg3codsz44e51y	expiry_notify	0	1770804339635	1770804345314	1770804345317	success	100	null
iudz5851c3ynmrc4fwqxuaiaio	cleanup_desktop_tokens	0	1770720992124	1770720997465	1770720997470	success	100	null
x3en5rygn78b8bzddhkwtkmzbh	expiry_notify	0	1771013578699	1771013587492	1771013587498	success	100	null
tiqk87dypfdm9cdd3uprirkeno	product_notices	0	1770720992129	1770720997465	1770720997567	success	100	null
seqz4grmqbn7xekjd7tchce9xw	cleanup_desktop_tokens	0	1770848863615	1770848871144	1770848871148	success	100	null
rhqcf87x53yztqbx9mw1zhgq3c	expiry_notify	0	1770826121503	1770826135131	1770826135135	success	100	null
rday4ezwd7899cwu1qnduinigo	product_notices	0	1770872205666	1770872207162	1770872207265	success	100	null
5b6ejmejribu5k3c4iukhbqgjo	expiry_notify	0	1771023479627	1771023491899	1771023491901	success	100	null
wf5j4sf46tfxzr7d3ou7mr4mnw	product_notices	0	1770901008206	1770901020067	1770901020178	success	100	null
xoc5m65sxtfmte8uotowybshqa	cleanup_desktop_tokens	0	1771023959667	1771023972089	1771023972094	success	100	null
xmb9tjs6wirrixt1ar8xcw76fw	expiry_notify	0	1770901128219	1770901140131	1770901140136	success	100	null
xsfyxa3kzpdouxfrxswiwrs44w	expiry_notify	0	1771024139685	1771024152186	1771024152191	success	100	null
y8xd6mwheff39g78xriuaqp9hw	expiry_notify	0	1770973374929	1770973383722	1770973383726	success	100	null
ots4yp5gtibfmx5bju95bnt7yr	expiry_notify	0	1770952493090	1770952494451	1770952494455	success	100	null
d9dsumyuo3yk9bz86wofzyf7xw	expiry_notify	0	1771034700655	1771034702030	1771034702037	success	100	null
x41zxab9wbft5e8skcnshzmdor	expiry_notify	0	1770953153171	1770953154637	1770953154640	success	100	null
trfpfen9f3b79yjgxmsgq534wh	cleanup_desktop_tokens	0	1771034880668	1771034882118	1771034882122	success	100	null
ftctjryik7fmxf45qfxxrziqnr	expiry_notify	0	1770985916026	1770985929303	1770985929310	success	100	null
kqmiybc4yirf9yn6atqsgk8crh	expiry_notify	0	1771035960760	1771035962654	1771035962659	success	100	null
n9k78cba8tndtcoewo3x3pkxey	expiry_notify	0	1771036620823	1771036623002	1771036623007	success	100	null
mnre3ifweby7fdt1j5636zkzha	cleanup_desktop_tokens	0	1770899988110	1770899999623	1770899999628	success	100	null
kyczyxnhdbrobk335s5b1qed8y	product_notices	0	1770533775899	1770533786750	1770533786862	success	100	null
a79mzqf477r1pcbeckosdn5fqo	expiry_notify	0	1770603742102	1770603749072	1770603749080	success	100	null
cfgjmf9urbd3m8t8j5ow7x5g1e	expiry_notify	0	1770677428572	1770677432302	1770677432308	success	100	null
esquqrjr4idydrs9ndphfdmf4a	expiry_notify	0	1770761015591	1770761020678	1770761020686	success	100	null
i8puijgt1jdoubhsjzbfqxcdqw	expiry_notify	0	1770533895917	1770533906795	1770533906801	success	100	null
1f73d97qqfrkdg3rqsug8isu4y	cleanup_desktop_tokens	0	1770870765531	1770870766473	1770870766479	success	100	null
szbey3oj7ino9ded7zas6fxkac	expiry_notify	0	1770624143925	1770624158295	1770624158298	success	100	null
gx85trpdqpni7dzccndrtwncye	expiry_notify	0	1770559638182	1770559643473	1770559643479	success	100	null
hocuwdbhef8jtb6qt1djjjeuco	product_notices	0	1770677788593	1770677792469	1770677792583	success	100	null
ucwyi8834ingpfwn4j9ftp4a6h	cleanup_desktop_tokens	0	1770805059720	1770805065663	1770805065669	success	100	null
gncgu3zfgty5dkpmxcd1ekw6bh	expiry_notify	0	1770624803997	1770624818604	1770624818607	success	100	null
f983wfrchbrwpefggzxbbss55y	expiry_notify	0	1770560958356	1770560964077	1770560964081	success	100	null
g564861di78cfdpr8hnm1gk8fw	expiry_notify	0	1770761675644	1770761680992	1770761680998	success	100	null
433e3kxo9trx7eg136fwekgtic	expiry_notify	0	1770999057252	1770999060587	1770999060591	success	100	null
36w6c9qk73ga8m9fpg86beb49w	expiry_notify	0	1770678088620	1770678092580	1770678092583	success	100	null
yqrkeofxbfdymxhxpxpcgp1ise	product_notices	0	1770562578503	1770562584853	1770562584981	success	100	null
m1t7ep9dffd7z8okca5b3jdw9w	expiry_notify	0	1770652466494	1770652475829	1770652475835	success	100	null
jqbx1ekyx3f3mgj7ke9ybcqcxw	expiry_notify	0	1770870825541	1770870826497	1770870826504	success	100	null
c8p6pscbxiyo3qyybc5grtyrnw	expiry_notify	0	1770562938540	1770562945009	1770562945013	success	100	null
b6csey6scigw7dsiobst3c5ntr	expiry_notify	0	1770782077616	1770782090276	1770782090282	success	100	null
5nqqyct9ufypfyd9c98g4gkbjy	expiry_notify	0	1770653066551	1770653076122	1770653076126	success	100	null
8amfwd6am7nn5jnbxbge45dayr	expiry_notify	0	1770678748647	1770678752909	1770678752910	success	100	null
1nkexddgqjbm3kep4pw66o8kqc	expiry_notify	0	1771014238746	1771014247751	1771014247757	success	100	null
69jskoz73b8nfxf1z3zka6qrfa	expiry_notify	0	1770679408719	1770679413288	1770679413293	success	100	null
7ctednp9rbyxfxnyoxohehmway	expiry_notify	0	1770782737655	1770782750576	1770782750581	success	100	null
56kttb9g6fb5pnzhznywrjbbfa	expiry_notify	0	1770899148040	1770899159236	1770899159242	success	100	null
eohc8rj9h3g6inhxx6r375exmy	product_notices	0	1770699390314	1770699402696	1770699402797	success	100	null
3hhz7bxzqi8qfd75n5emejfgac	expiry_notify	0	1771024799754	1771024812513	1771024812519	success	100	null
455qhbmmtbnuzywcz688i8zuzw	cleanup_desktop_tokens	0	1770783097684	1770783110742	1770783110749	success	100	null
bu4eftjcdi8piy4kzh8xruiwha	expiry_notify	0	1770721592172	1770721597725	1770721597732	success	100	null
9ajz48xeepfzumkd34u1uxs53a	expiry_notify	0	1770899808091	1770899819562	1770899819567	success	100	null
8hw3phxom3d3tdyj9gkgxe7kxe	expiry_notify	0	1770826781548	1770826795455	1770826795462	success	100	null
7fj6anfccbn3ipqjbkpn51n9nc	expiry_notify	0	1770783397712	1770783410876	1770783410880	success	100	null
zpzqrbi8ypbsmcqsrzjs6srnme	expiry_notify	0	1771025459805	1771025472829	1771025472831	success	100	null
k31qiby45pbydjn4r9iqe47eco	expiry_notify	0	1770928130814	1770928138106	1770928138113	success	100	null
kfka8k8t6tdifbrrxxdt44efyc	expiry_notify	0	1770784057799	1770784071172	1770784071178	success	100	null
fkpj4yxyg3dpdret7wcz4im4gy	expiry_notify	0	1770900468165	1770900479835	1770900479839	success	100	null
hawxi7wqaif43yj4ocqhzs9bry	expiry_notify	0	1770804999711	1770805005629	1770805005636	success	100	null
fwe345fr1fg49xu4mcxr7ra3gw	expiry_notify	0	1771026779894	1771026793425	1771026793430	success	100	null
5jhwo1u1u7r5mrk7qstcjby6kw	expiry_notify	0	1770901788283	1770901800441	1770901800446	success	100	null
cq57f1ms178hjnfk8hfn3i7aka	expiry_notify	0	1770827441579	1770827455718	1770827455722	success	100	null
wisw1eirs78gtj1oteurpybr4y	product_notices	0	1771027019916	1771027033528	1771027033636	success	100	null
6htxjji4k7bm7moszcuq6baugc	expiry_notify	0	1770902448345	1770902460723	1770902460727	success	100	null
sc6k63a4fpr5jetmmy84yd9dih	expiry_notify	0	1770828101634	1770828116057	1770828116061	success	100	null
h18f35e46i8bpya9kbu39x6soe	refresh_materialized_views	0	1771027259913	1771027273644	1771027273665	success	100	null
kakxme4a6pnbjnifosq184xqiw	expiry_notify	0	1770849103635	1770849111255	1770849111262	success	100	null
ompdidkut3r5dpttebo4mki9rr	expiry_notify	0	1770928790881	1770928798364	1770928798368	success	100	null
hdx8kqdd6pr5fcmdk8pjy764ko	expiry_notify	0	1770849763680	1770849771563	1770849771566	success	100	null
bha1zjejk7r8bq9io6mtg7h3zw	expiry_notify	0	1770974694982	1770974704166	1770974704169	success	100	null
ye91bdbu7tgqbnxj6sej5h5dqw	expiry_notify	0	1770953813196	1770953814892	1770953814897	success	100	null
e9y86r59yjdnzn4cbhqipmsjec	expiry_notify	0	1771027439926	1771027453739	1771027453744	success	100	null
h4oqwmgxjpb38bukbdiy1z1jpe	expiry_notify	0	1771035360707	1771035362359	1771035362365	success	100	null
kpytrcc5ntb1jp468bt3c16a5a	product_notices	0	1771045021565	1771045027094	1771045027213	success	100	null
d4zp6r5qmjbkdpxi4mrtgfzera	cleanup_desktop_tokens	0	1771045801642	1771045807448	1771045807454	success	100	null
pqmrtashijn4bnte8c47rpd9pe	expiry_notify	0	1771045861649	1771045867476	1771045867481	success	100	null
omgmxytk5ig7zkcnieycd57hgy	expiry_notify	0	1771026119853	1771026133131	1771026133138	success	100	null
8wp5zdoqspgdzp43pmehhmxrfe	expiry_notify	0	1770534555993	1770534567114	1770534567121	success	100	null
6me68ig8wjy9mqdqgr8etyp8oc	cleanup_desktop_tokens	0	1770604282122	1770604289316	1770604289321	success	100	null
6as7nhij93yh58d5y5sewhbxwr	expiry_notify	0	1770680068786	1770680073593	1770680073598	success	100	null
qwndsthgziyf5r9bbp5njerz3c	cleanup_desktop_tokens	0	1770761195611	1770761200759	1770761200763	success	100	null
icdq6cdbofn55nhd787t7x78ry	expiry_notify	0	1770560298287	1770560303780	1770560303787	success	100	null
918fb5wmsjbqjx4ix9844og4sw	expiry_notify	0	1770872805710	1770872807478	1770872807485	success	100	null
w8i9nuie8bbsbctpkne4mbbi8w	expiry_notify	0	1770604402141	1770604409381	1770604409387	success	100	null
qaa85e9df3ypxyqkcy3i69nz1w	expiry_notify	0	1770999717323	1770999720903	1770999720905	success	100	null
9zwko8ayi7n49ezatzqj8fjcsw	cleanup_desktop_tokens	0	1770560418306	1770560423842	1770560423847	success	100	null
d1ofbik5o7yp3xkwqaqh77r7mo	expiry_notify	0	1770701130458	1770701143540	1770701143546	success	100	null
mwdkejecy7rzmezy3qmbhu7fzy	expiry_notify	0	1771145290894	1771145303426	1771145303432	success	100	null
5tr34mso3tr5xeynnefnaegtxy	expiry_notify	0	1770626784138	1770626784338	1770626784344	success	100	null
oiceenkfu3dc9kn9xizocmtp3y	expiry_notify	0	1770762995758	1770763001640	1770763001645	success	100	null
4s4rkncu7fd9pyua8j61x8dxjw	cleanup_desktop_tokens	0	1770903648473	1770903661263	1770903661268	success	100	null
we7qfrpbdtywzdfp44fr6b4xqw	expiry_notify	0	1770722912300	1770722918383	1770722918389	success	100	null
kctxdzbos78htxjiqo7ysc5ybw	expiry_notify	0	1770653726572	1770653736449	1770653736456	success	100	null
33cags8h6i898cce4ds76so7eo	expiry_notify	0	1770873465783	1770873467801	1770873467806	success	100	null
n1ib7fx5afy7upc84ao6oc5wda	cleanup_desktop_tokens	0	1770830561857	1770830562276	1770830562280	success	100	null
ityx14udni85pcgqt4idugbeme	product_notices	0	1770782197616	1770782210322	1770782210429	success	100	null
bwphydh393f6xkmgzh8z9dcbcy	expiry_notify	0	1771014898808	1771014908053	1771014908056	success	100	null
hp3kj5cezjdd5mh4i4hkome77a	expiry_notify	0	1770806319813	1770806326313	1770806326319	success	100	null
8jnptrq9dtnkugtadd8sszredo	expiry_notify	0	1770874785951	1770874788476	1770874788481	success	100	null
z4nb6455njdninkzkw6536175e	expiry_notify	0	1770806979850	1770806986591	1770806986593	success	100	null
sy9b6btxqigc3ruzg4ow7wkjxy	product_notices	0	1771037820899	1771037823633	1771037823736	success	100	null
j78ra88kbpgadm7t7iczgm34oc	expiry_notify	0	1770875445994	1770875448796	1770875448800	success	100	null
k6zty1zi37fdfdrhtnyacbh3ar	product_notices	0	1770807399888	1770807406704	1770807406791	success	100	null
bzmg17e8abbofys89xocqxjyac	expiry_notify	0	1771037280854	1771037283348	1771037283354	success	100	null
az9ehi7mw78p9cgw5myp1t5krc	expiry_notify	0	1770830741865	1770830742386	1770830742392	success	100	null
fxj77rzpf3nh8xd3wgae8hadfo	expiry_notify	0	1770807639922	1770807646802	1770807646808	success	100	null
4scqb6o3jffqp81gyy97egjsuc	product_notices	0	1770875806043	1770875808967	1770875809061	success	100	null
b95c91ofrigt7f94bjqgetny8o	expiry_notify	0	1770828761684	1770828776395	1770828776401	success	100	null
ucgoerzizidn7npdm43shm44je	expiry_notify	0	1770903768489	1770903781307	1770903781312	success	100	null
ywfhfj5ct7yc8pbdn5ca1mxrac	expiry_notify	0	1770903108420	1770903121003	1770903121009	success	100	null
y91c3iwfrpfjxmosdkmkinu4da	product_notices	0	1770829001705	1770829016514	1770829016610	success	100	null
nf45yxmt53r4zki9zapgs769hw	expiry_notify	0	1771037940913	1771037943696	1771037943700	success	100	null
jqd4g35x7inixbx9rhu8hartna	expiry_notify	0	1770829421746	1770829436723	1770829436728	success	100	null
emxfgj75ipdjbjjmi7bom5odfa	expiry_notify	0	1770831341970	1770831342732	1770831342736	success	100	null
6fg86ahdbpfxfmqpf1b8s1nhey	cleanup_desktop_tokens	0	1770929150917	1770929158562	1770929158567	success	100	null
s4ruc65kqbywtemxio4upp4rfh	expiry_notify	0	1771046521714	1771046527817	1771046527824	success	100	null
wgjxnzsibfnyipnbz6nj8bqz8r	expiry_notify	0	1770832002008	1770832003059	1770832003063	success	100	null
ukre8ddg1jywfg97gnifb5xx1c	cleanup_desktop_tokens	0	1770954593271	1770954595289	1770954595293	success	100	null
hfki78gn9j8g5yfric9aznnheo	product_notices	0	1770929810968	1770929818843	1770929818931	success	100	null
r8ewkiyg7tfiiyu1g97udaui4o	expiry_notify	0	1771051142153	1771051150103	1771051150108	success	100	null
dgisnzo1sfg3iej46tyy4bjxah	expiry_notify	0	1770850423729	1770850431902	1770850431909	success	100	null
pcmr84ec87nf9xrbohuk1d188y	expiry_notify	0	1770954473258	1770954475233	1770954475239	success	100	null
f44qngrc1fyxixr1r96h17z4ao	product_notices	0	1770850603749	1770850611964	1770850612083	success	100	null
6ijzx8brif8ztqk7tx47ybreqa	expiry_notify	0	1771051802219	1771051810427	1771051810429	success	100	null
ign7ya3wc789zbu83em5smfqko	expiry_notify	0	1770975355026	1770975364392	1770975364398	success	100	null
e7s3tdf5mbnwjd4d544dnydqya	product_notices	0	1770955013304	1770955015488	1770955015600	success	100	null
xf3cicsk6pght8x3rhws3ar4kr	expiry_notify	0	1771053782395	1771053791403	1771053791409	success	100	null
utw4ao7dztbgfg7ii55fueukxe	expiry_notify	0	1770955133324	1770955135545	1770955135550	success	100	null
nso5n6jpdtr33k9ierqn518poa	product_notices	0	1771059422906	1771059434000	1771059434117	success	100	null
51nu3dktitnd5jnpyyss1wcxua	expiry_notify	0	1771059722943	1771059734154	1771059734160	success	100	null
oe4oqkoe3fy15nu3ydunngw63c	cleanup_desktop_tokens	0	1771060383013	1771060394448	1771060394452	success	100	null
pkpcge9ofidt9gs3me9jbwj4rc	expiry_notify	0	1771063683357	1771063696021	1771063696026	success	100	null
1yjx6j8gktyc9qxxiui5ef3zpw	expiry_notify	0	1770955793367	1770955795854	1770955795861	success	100	null
jm3wn1k1rfdgpdcsso5qwfmf8y	expiry_notify	0	1770535216057	1770535227414	1770535227420	success	100	null
uamecm35ubyc5y6umqpb9gyazo	expiry_notify	0	1770605062219	1770605069697	1770605069704	success	100	null
gnpkniqa97f1dfudw39r973wer	expiry_notify	0	1770680728807	1770680733915	1770680733920	success	100	null
gau8dc7m37b7ferzs9fjmn8jwy	expiry_notify	0	1770762335684	1770762341295	1770762341302	success	100	null
wcowcrkbxjynixhqjmkpbu395h	expiry_notify	0	1770561618413	1770561624410	1770561624416	success	100	null
w4gcnrcihtdmufnpbg4mmbd6xe	expiry_notify	0	1770874125868	1770874128137	1770874128144	success	100	null
p7hw1rswt3r4trr3gopgwnuwge	expiry_notify	0	1770605722271	1770605729984	1770605729989	success	100	null
4qeeqbpcgifwmp4eehq9zocu9a	cleanup_desktop_tokens	0	1770680788810	1770680793955	1770680793959	success	100	null
eu6k6jfjs7fnz86k8agmqfst7o	expiry_notify	0	1771000377385	1771000381221	1771000381224	success	100	null
giwdzjsp9pdym84puq777eju5y	product_notices	0	1770605782280	1770605790016	1770605790124	success	100	null
56s3ixej3irnxkpn347xzojb1w	expiry_notify	0	1770784717872	1770784731530	1770784731537	success	100	null
g6tuuu7amtf7zm7k57s6a74gwa	product_notices	0	1771145830985	1771145843707	1771145843822	success	100	null
z778t5tof7nxi8a9c3atxgcu1r	cleanup_desktop_tokens	0	1770874425899	1770874428289	1770874428294	success	100	null
swuwf84p5t8ubjwtoe335kxoxo	product_notices	0	1770627384191	1770627384618	1770627384726	success	100	null
pky315nc9ifstyrns3c98jekro	expiry_notify	0	1770681388818	1770681394227	1770681394235	success	100	null
y1no41x8ijnkxpndbbgu6d4pxw	expiry_notify	0	1770785377921	1770785391856	1770785391865	success	100	null
aoz1gqckafffiksdq3j3xjk9qo	expiry_notify	0	1770627444208	1770627444643	1770627444648	success	100	null
qqsygiru4bd5tyk1bcuio5odrw	product_notices	0	1770681388820	1770681394227	1770681394336	success	100	null
zx37grbssiy3mbt4wjos3749bh	expiry_notify	0	1771015558837	1771015568366	1771015568372	success	100	null
3cbgcia5qifc7gi8tupwnbhqdc	expiry_notify	0	1770654386625	1770654396781	1770654396787	success	100	null
ojt6q16oufrojpf1sx6jx3yona	expiry_notify	0	1770904428558	1770904441615	1770904441622	success	100	null
7y8gzf7twiykxq9nzeypo1fj7y	refresh_materialized_views	0	1770681628824	1770681634337	1770681634357	success	100	null
kizenh431f8s3gq74wyx6tiopo	product_notices	0	1770785797980	1770785812076	1770785812194	success	100	null
tufpsujuo7fxbfjhntu5ojno5c	expiry_notify	0	1770701790507	1770701803864	1770701803870	success	100	null
ya7ah3jbgf88dxhy8wrobhzk6r	expiry_notify	0	1770786037985	1770786052167	1770786052172	success	100	null
x3opio7n5bf8uc5y4dkt8d755w	product_notices	0	1770904608580	1770904621718	1770904621805	success	100	null
gpfgxctxzibj9n15j86z3trkmh	expiry_notify	0	1770723572350	1770723578693	1770723578700	success	100	null
zn6a4th9z7dptdfyzbgbhfszne	cleanup_desktop_tokens	0	1771027619942	1771027633834	1771027633839	success	100	null
fxmsmnck4tnsugjxur1tonzi6r	expiry_notify	0	1770808299972	1770808307092	1770808307098	success	100	null
8py35ntajjyqdes4ufz49rpz6y	expiry_notify	0	1770724232387	1770724239021	1770724239026	success	100	null
45n1r8n7atg5pcsepaimcm6tew	expiry_notify	0	1770976015058	1770976024621	1770976024627	success	100	null
kp9r7sdcn7b3jq8ugr3dgazmmc	expiry_notify	0	1770929450935	1770929458724	1770929458733	success	100	null
yee33mo6nbyo3gripnjf4dqbxa	expiry_notify	0	1770830081820	1770830082016	1770830082022	success	100	null
nkfxs9emft8qzjtucrka5rfgow	expiry_notify	0	1771039261054	1771039264346	1771039264354	success	100	null
iw3ofypdwifkinb1px86nxfaxh	cleanup_desktop_tokens	0	1771038540973	1771038543981	1771038543986	success	100	null
irfiiqzwrbyaumcsgozgqjcy1a	expiry_notify	0	1770930110996	1770930118970	1770930118975	success	100	null
1w3n3yj5q7gu9ru9bf8f1njz5c	expiry_notify	0	1770851083786	1770851092163	1770851092166	success	100	null
idgyqm6xsirzzxs6pr9xptddda	expiry_notify	0	1770851743856	1770851752542	1770851752546	success	100	null
aewbxrj3cbrtijcia3rjk4f9mr	expiry_notify	0	1771047181765	1771047188156	1771047188162	success	100	null
rjgeodo6k3fhmbz5sstb14yy9o	cleanup_desktop_tokens	0	1770976555097	1770976564807	1770976564812	success	100	null
hbedrqq5fiyq8jk6ezyac3a8qh	expiry_notify	0	1771054442436	1771054451712	1771054451718	success	100	null
xjw4oja4jidq9jg5cux4benf7e	product_notices	0	1770976615107	1770976624828	1770976624926	success	100	null
ym5in6fqzjfjurfzbuadi79qmh	expiry_notify	0	1771060383019	1771060394447	1771060394452	success	100	null
i5d9sa7h93ftdqfk5qyobxmwne	expiry_notify	0	1770976675122	1770976684857	1770976684862	success	100	null
krfsbdej8trsxyk4duboifj4dy	cleanup_desktop_tokens	0	1771064043391	1771064056184	1771064056189	success	100	null
3unxuykkj7goufukgsugmu7a7a	expiry_notify	0	1771061043078	1771061054753	1771061054757	success	100	null
zc6tubm89bd6ug75uefgdwbwby	expiry_notify	0	1771066983691	1771066997472	1771066997477	success	100	null
bknpr8fh63fofp8au4c4nnhfda	expiry_notify	0	1771067643752	1771067657825	1771067657830	success	100	null
bua4gtc8yib9djxfhfuuzg3pea	expiry_notify	0	1771068963886	1771068978441	1771068978444	success	100	null
h4swyito4tne3bzbds4czoiiee	expiry_notify	0	1771069623936	1771069638649	1771069638654	success	100	null
zrzx39xuitgyup3bggaps58poo	install_plugin_notify_admin	0	1771070223973	1771070238839	1771070238848	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
rmb5bomz6jdoibffc96beb9rgc	product_notices	0	1771070223976	1771070238839	1771070238923	success	100	null
o5p9hy8o3pf6zf9auhgmdrmfpa	import_delete	0	1771070223974	1771070238839	1771070238855	success	100	null
f9t58uhhrbd1dgyouep98s41hc	export_delete	0	1771070223968	1771070238839	1771070238855	success	100	null
tfphmmbb7f84ppbr5w3k9cwsno	expiry_notify	0	1770498252647	1770498265335	1770498265340	success	100	null
mcid4ta5mi8r3p1ba9zqephctc	expiry_notify	0	1770905088630	1770905101953	1770905101959	success	100	null
bgdghqz6e3gh5jat9e88utbiuh	expiry_notify	0	1770535876130	1770535887742	1770535887749	success	100	null
djos79jqctdibq5j9itqqsiryo	expiry_notify	0	1770606382320	1770606390302	1770606390309	success	100	null
mfjw5mgfsjnejqxi8jwxzhqsnh	expiry_notify	0	1770682048832	1770682054534	1770682054539	success	100	null
883qraw7aigrpx1jswbuybwmar	expiry_notify	0	1770763655820	1770763661949	1770763661955	success	100	null
46wbuqzu1fgxmykeqgizmos3kh	expiry_notify	0	1770562278475	1770562284731	1770562284737	success	100	null
xck9w1qdbpnydchkwpqq88hyme	expiry_notify	0	1770876106071	1770876109116	1770876109122	success	100	null
15pe8fktk7bnuyfzz6qd1kdeky	expiry_notify	0	1770628104297	1770628104955	1770628104961	success	100	null
fxrsgjbx7pg17c4ujypx76na5c	cleanup_desktop_tokens	0	1770684449000	1770684455673	1770684455677	success	100	null
m635w7357prb5kf98ud3afeejo	expiry_notify	0	1771001037433	1771001041446	1771001041453	success	100	null
44qbopwk9j887xx3g46tj3t1xa	expiry_notify	0	1770628764351	1770628765262	1770628765266	success	100	null
omjgqsj9a3g7jpj4m14xenn86w	cleanup_desktop_tokens	0	1770764855941	1770764862491	1770764862497	success	100	null
e5gt3saombnaic9mm6hfz4isho	expiry_notify	0	1770702450550	1770702464183	1770702464189	success	100	null
7pciau6tspratqe5nkw3ig87ha	expiry_notify	0	1770629424398	1770629425559	1770629425563	success	100	null
uociryhunbgszpm9isjpifuaso	expiry_notify	0	1770877426213	1770877429725	1770877429729	success	100	null
iumqhe55z3nr9dfhffz41otiye	expiry_notify	0	1770764975964	1770764982537	1770764982540	success	100	null
cmg74hs91igeunk5owzc7casuc	expiry_notify	0	1770630084466	1770630085828	1770630085832	success	100	null
b4wpgcctg78oik87r77qpg5e4a	product_notices	0	1771001817490	1771001821791	1771001821896	success	100	null
8nqjk7mu8ifauegoepym66xfqa	expiry_notify	0	1771001697480	1771001701734	1771001701738	success	100	null
r5743b1zsjffdd4podeo7ik1fy	expiry_notify	0	1770809620087	1770809627713	1770809627717	success	100	null
mcip7j9x63y4ubz7mme87ys19w	expiry_notify	0	1770630684518	1770630686106	1770630686110	success	100	null
mimsytzab7d8xm91x1fwu5oroc	expiry_notify	0	1770786638047	1770786652469	1770786652477	success	100	null
we6zi6ff1pdxir3nxbhjg87xor	product_notices	0	1770630984538	1770630986213	1770630986300	success	100	null
agj5kqr1bpyazg6qyzyjdee99w	cleanup_desktop_tokens	0	1770786758070	1770786772518	1770786772522	success	100	null
cpe6iy1k73dsu85bf335snip9e	expiry_notify	0	1770878086266	1770878090033	1770878090038	success	100	null
dynspy3dg3dh5daotrg4msjzpa	cleanup_desktop_tokens	0	1770878086260	1770878090033	1770878090039	success	100	null
ei1ejkwurfdptnzqj9bzfb6j3h	export_delete	0	1770724592422	1770724599185	1770724599190	success	100	null
6dmw8u4xpfdzbq7iwynhemny4w	import_delete	0	1770724592428	1770724599184	1770724599190	success	100	null
bzbjxe5pdp8bfxwyuuj4rmp5zw	mobile_session_metadata	0	1770724592424	1770724599185	1770724599191	success	100	null
uqzyhygpdfynuphos99jcgkeua	expiry_notify	0	1770787298099	1770787312798	1770787312804	success	100	null
4zx1c1kakfr99bfjnknmnhd6nh	plugins	0	1770724592425	1770724599185	1770724599199	success	0	null
5fg5bmjcntd698k9nzxai7qr3r	install_plugin_notify_admin	0	1770724592426	1770724599185	1770724599202	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
bxfyko8b8jy5tncx34b514k66h	product_notices	0	1770724592417	1770724599185	1770724599263	success	100	null
7kwhkykqxt8uxcmixx197cym9r	cleanup_desktop_tokens	0	1771002117519	1771002121936	1771002121941	success	100	null
arcm89x8xjyeiyd9pfu9qpxz7o	expiry_notify	0	1770905748698	1770905762328	1770905762335	success	100	null
yzfzo76fu7y69kkst1d9xumbcy	cleanup_desktop_tokens	0	1770808720001	1770808727289	1770808727294	success	100	null
3zdsse1wb3bbbnt8unaa5noz6h	product_notices	0	1770832602051	1770832603390	1770832603486	success	100	null
hionhfr6mbrxtmo5e1jejitpxw	expiry_notify	0	1770808960023	1770808967397	1770808967404	success	100	null
8b148huczidkmf7pisgum8js6w	expiry_notify	0	1770977335183	1770977345152	1770977345159	success	100	null
rhfqa7fpetr1fmdqdr81kqq6sc	expiry_notify	0	1770930771064	1770930779260	1770930779266	success	100	null
gfix79x5jpf19fdo8bksn1n36c	expiry_notify	0	1770832662065	1770832663425	1770832663430	success	100	null
ufiuur977pnwu8t9fhq6sqi4cw	expiry_notify	0	1771016218926	1771016228699	1771016228703	success	100	null
i9x4ksbosfnefb3jr5mba6xrrw	product_notices	0	1771016218931	1771016228699	1771016228803	success	100	null
eh41qog5ttnrdda1arwko1ftwa	expiry_notify	0	1770956453439	1770956456175	1770956456182	success	100	null
9euwq1m4tfgtjebgirtuqxmh5w	expiry_notify	0	1770852403901	1770852412860	1770852412866	success	100	null
1mwk6h9sbtgepp9aqm9zompqdo	cleanup_desktop_tokens	0	1771016638977	1771016648875	1771016648880	success	100	null
jdr6omb4hbf6xjmg5u8tews69w	cleanup_desktop_tokens	0	1770852523920	1770852532942	1770852532946	success	100	null
mma9uf9bcj8k9g31118htwrkiy	expiry_notify	0	1771028099973	1771028114038	1771028114044	success	100	null
p943bf3wriyqxjgwkf9bqquwty	expiry_notify	0	1771038600984	1771038604021	1771038604025	success	100	null
1txbwucdw38iby47maz8w5qway	expiry_notify	0	1771047841831	1771047848470	1771047848475	success	100	null
7nhpoy4jgjyzzkn7pe4spkqafc	expiry_notify	0	1771055102489	1771055112008	1771055112011	success	100	null
urr1d39rjjnrtnsbbi6id7khur	expiry_notify	0	1771056422642	1771056432562	1771056432567	success	100	null
denw7pkb7pd5fg8gpp4jwew6so	cleanup_desktop_tokens	0	1771056722677	1771056732698	1771056732704	success	100	null
nfg5z8sa5jfgipn3iogu91g34h	expiry_notify	0	1771057082715	1771057092843	1771057092847	success	100	null
ch9zwtko7jnhppyizhywt5mzjw	expiry_notify	0	1771317069976	1771317077263	1771317077269	success	100	null
oa44tpzxw7do7xieaeo31xmkda	mobile_session_metadata	0	1771070223970	1771070238839	1771070238855	success	100	null
zj486iadstfsxpg7oduu3bwpjr	expiry_notify	0	1771070283980	1771070298855	1771070298862	success	100	null
a6yfbfjojbgdi8mpkk38fbx3jc	expiry_notify	0	1771070944012	1771070944087	1771070944092	success	100	null
hrwmb3orr7bupr31iaquhyz6he	expiry_notify	0	1771076224373	1771076226010	1771076226017	success	100	null
kwu46b3tubf6f88xcqr36b6dgo	cleanup_desktop_tokens	0	1771071364039	1771071364231	1771071364236	success	100	null
nt9xya1myffimnpp38c3sq87jo	expiry_notify	0	1771071604056	1771071604314	1771071604321	success	100	null
orzawnhyjb8bmcjcycbdy973za	expiry_notify	0	1771072264089	1771072264522	1771072264526	success	100	null
dck8cyzd1pdn3ey7eokhuntkjc	expiry_notify	0	1771080844707	1771080847626	1771080847635	success	100	null
h6ztopk1s3dc9fz566goonyqec	expiry_notify	0	1771072924186	1771072924835	1771072924838	success	100	null
qctquyp4tirbxkkz8ddx4ke6qr	expiry_notify	0	1771076884417	1771076886266	1771076886273	success	100	null
yzeefjzmpbb39xjegt3t6t94ty	expiry_notify	0	1771073584243	1771073585079	1771073585082	success	100	null
j9qczk8xkpd37jaamex8rwu3my	product_notices	0	1771073824267	1771073825161	1771073825250	success	100	null
x8qoxh4sj3gc7foiteadffcmac	expiry_notify	0	1771074244296	1771074245307	1771074245314	success	100	null
wys6gj5ep7r4xfrg6ne9iaa9ja	expiry_notify	0	1771074904294	1771074905512	1771074905516	success	100	null
z1g17ud8hirmjqg1ipsjoxftar	product_notices	0	1771077424449	1771077426444	1771077426489	success	100	null
udzrxw6jejyw8jhjp45i79d1xe	cleanup_desktop_tokens	0	1771075024303	1771075025565	1771075025570	success	100	null
ihugew7a9p8d7p6zm8pgcgc99r	expiry_notify	0	1771075564343	1771075565792	1771075565801	success	100	null
8pcdfn68ntng8bjtmyznaqc7wa	expiry_notify	0	1771077544461	1771077546489	1771077546494	success	100	null
1a9ko6nowtbriyibxr1ggq15ma	expiry_notify	0	1771078204510	1771078206730	1771078206741	success	100	null
cdadgdkjcbd48c9cfhxcgbcj5w	product_notices	0	1771081024722	1771081027678	1771081027751	success	100	null
9qyuz79ad7f89ku1gkb4ibhk8h	cleanup_desktop_tokens	0	1771078624527	1771078626871	1771078626874	success	100	null
uukfurtud7djdxugxt8c4aftaw	expiry_notify	0	1771078864552	1771078866951	1771078866954	success	100	null
witdt83fubrtucceia1ca4sgmw	expiry_notify	0	1771079524600	1771079527163	1771079527167	success	100	null
8c5uwhwkhifymkczxic6y3s6hr	expiry_notify	0	1771084144986	1771084148836	1771084148840	success	100	null
ufx3h8ijsfr3jfb7gca81wq3de	expiry_notify	0	1771080184662	1771080187416	1771080187423	success	100	null
du544ra6oprd3xwtcmcpjfpw1c	expiry_notify	0	1771081504766	1771081507845	1771081507849	success	100	null
wywcwxbsu7dd9c8mmbwzn17d6y	expiry_notify	0	1771082164800	1771082168041	1771082168047	success	100	null
h4y58piy3pgrtyy6maw7fboxqc	cleanup_desktop_tokens	0	1771082284812	1771082288079	1771082288084	success	100	null
5ut4ezn3ftfptcy1cazy5dguca	expiry_notify	0	1771082824849	1771082828246	1771082828252	success	100	null
6xyef6nwsbdx5kbs3duiaws5yr	product_notices	0	1771084625023	1771084629030	1771084629152	success	100	null
tkwrnkq4wjbr9x9bywfe1tusbr	expiry_notify	0	1771083484898	1771083488539	1771083488545	success	100	null
h5rny18f6pyptj57srujri7och	expiry_notify	0	1771086125166	1771086129684	1771086129692	success	100	null
p551hho8838embd3jjdm5fq1tc	expiry_notify	0	1771084805041	1771084809107	1771084809112	success	100	null
tyf14p7dkpbo8r174k5q5yyesa	expiry_notify	0	1771085465101	1771085469415	1771085469421	success	100	null
74rmjtf8rpb5dr4tce4q4cpd4o	cleanup_desktop_tokens	0	1771085945149	1771085949617	1771085949621	success	100	null
fc6jwxbzgtndubag5poq1daz7h	expiry_notify	0	1771086785219	1771086789919	1771086789925	success	100	null
pgrnxeg9yb8s9d853zfdmaw83h	expiry_notify	0	1771087445266	1771087450143	1771087450149	success	100	null
wre765qhofyimqu3465qz1rs9y	product_notices	0	1771088225314	1771088230409	1771088230479	success	100	null
w1m9dkpifpykuehiwk59urokkh	expiry_notify	0	1771088105302	1771088110358	1771088110362	success	100	null
pe531oyygpbbd8untszr6p7sha	expiry_notify	0	1771088765341	1771088770582	1771088770589	success	100	null
5nsmnr9ee7bxj8a5suutsehorc	expiry_notify	0	1771089425382	1771089430809	1771089430811	success	100	null
pz53uwyj4bncbn4x4ha9tkh6ah	cleanup_desktop_tokens	0	1771089545402	1771089550850	1771089550853	success	100	null
fcx58jpp9jdt3eo4b9gkg5n7ye	expiry_notify	0	1771091345538	1771091351673	1771091351679	success	100	null
gibi1t1tep88dbpcixpkotgeea	expiry_notify	0	1771090025426	1771090030995	1771090030998	success	100	null
nc9itta4xbrq8ckuyif5yhpwxa	expiry_notify	0	1771090685470	1771090691318	1771090691321	success	100	null
qpy1or5totd55nb9b93dgyfqie	product_notices	0	1771091825597	1771091831905	1771091832013	success	100	null
wuno49on6bny9r9s7r8sg7gycc	expiry_notify	0	1771092005615	1771092011999	1771092012001	success	100	null
xjc9w5jsnigp7kaiuo8q1te6ir	expiry_notify	0	1771092665675	1771092672319	1771092672322	success	100	null
u9eqmkp7riyz8d6dm95iy7rdno	cleanup_desktop_tokens	0	1771093205723	1771093212616	1771093212623	success	100	null
dai86wm5o3g8ppmf19j8rh68fw	expiry_notify	0	1771093325743	1771093332672	1771093332680	success	100	null
69muzaeaotfu8gcrdutwmbhz3w	expiry_notify	0	1771093985792	1771093993013	1771093993017	success	100	null
uem5db77iif1zcxnj3zpsbw59o	expiry_notify	0	1771094645853	1771094653319	1771094653324	success	100	null
63cyftsopfnipbec8493wma6ta	expiry_notify	0	1771095305920	1771095313566	1771095313574	success	100	null
b1imddo44ffgubf5yyhgu5xrze	expiry_notify	0	1771145951000	1771145963751	1771145963758	success	100	null
n7qehb6q67f1mb4h1d9ojr4o4y	product_notices	0	1771095425941	1771095433615	1771095433715	success	100	null
wmjmwthscfdgbpg5dukjw58odo	expiry_notify	0	1771095965992	1771095973830	1771095973835	success	100	null
57dhuxm1ptf1fb466an3kwgupc	expiry_notify	0	1771096626081	1771096634196	1771096634202	success	100	null
pohz3prai7y38qmbd8u5zdx8fc	expiry_notify	0	1771101846589	1771101856739	1771101856745	success	100	null
a6fp4hr61idezkogta13ze3o5e	cleanup_desktop_tokens	0	1771096866117	1771096874306	1771096874310	success	100	null
khrf4px1eigupp8ngpdrodk4ne	expiry_notify	0	1771097286151	1771097294545	1771097294550	success	100	null
nj1pg1xg8bnt5xqmtypmd57egc	expiry_notify	0	1771097946233	1771097954837	1771097954844	success	100	null
riu6ekucn3dqjnqkzkq1ae8u4c	product_notices	0	1771106227019	1771106238969	1771106239083	success	100	null
13dkbrczzfnb3ez4bqigwgodsh	expiry_notify	0	1771098546281	1771098555141	1771098555147	success	100	null
gubh8pf1m7fpdb5njnb7jr14zc	expiry_notify	0	1771102506654	1771102517067	1771102517073	success	100	null
y9sfkuof6pf9pere7yiytuf8gw	product_notices	0	1771099026319	1771099035387	1771099035510	success	100	null
1yb516nei3rq5qdnn1r9ie7jna	expiry_notify	0	1771099206343	1771099215473	1771099215478	success	100	null
4njy7sxamtnwik6rdue3ruk56a	expiry_notify	0	1771099866406	1771099875805	1771099875810	success	100	null
mmp6qxmaxf8hi8k7xmq85r5sce	product_notices	0	1771102626673	1771102637130	1771102637237	success	100	null
up6paw4xe3bo8bpdu7fyxes88o	cleanup_desktop_tokens	0	1771100526477	1771100536146	1771100536150	success	100	null
pxb3eigtgigb9mhz7tozegqe4h	expiry_notify	0	1771100526482	1771100536146	1771100536150	success	100	null
8m75rikpx3nw7fd66831xbgjmr	expiry_notify	0	1771101186526	1771101196420	1771101196427	success	100	null
1hqxe114rfffbdo1k4ik99hnto	expiry_notify	0	1771103166726	1771103177389	1771103177393	success	100	null
5zg6pekjridfbg5tj4qq4u87xw	expiry_notify	0	1771109767372	1771109780781	1771109780786	success	100	null
9zia88rk4ffkzjj77asnyqeiqh	expiry_notify	0	1771103826779	1771103837730	1771103837736	success	100	null
gyug57ycpjdx98ubdmof6ntugr	expiry_notify	0	1771106467042	1771106479098	1771106479102	success	100	null
13bjy8dbhjrgdxf8cff915zr9w	cleanup_desktop_tokens	0	1771104186824	1771104197913	1771104197918	success	100	null
wtiust3ji3d13ebw4s4njae96a	expiry_notify	0	1771104486868	1771104498080	1771104498087	success	100	null
kenijyo4zfgkxy5wccaw8u8j7e	expiry_notify	0	1771105146941	1771105158447	1771105158452	success	100	null
hfma5zp13jfq8fz3hx7mz4bipc	expiry_notify	0	1771105806995	1771105818760	1771105818764	success	100	null
ufxqn91wwpbr9q3tkzmgndyq7c	expiry_notify	0	1771107127121	1771107139466	1771107139475	success	100	null
7nefpmokn3dr7m1q56uig5reze	expiry_notify	0	1771111747602	1771111761786	1771111761791	success	100	null
bpgxqu4je7d43ywekjzj9t199o	cleanup_desktop_tokens	0	1771107787187	1771107799783	1771107799787	success	100	null
9b3w6y1j9frptkh3zbkpyper9o	expiry_notify	0	1771107787191	1771107799782	1771107799788	success	100	null
fmmck1eua78epmuzmfmxgshahr	product_notices	0	1771109827378	1771109840807	1771109840914	success	100	null
5x6w8pp5e3gmubr7chqp6u6qso	expiry_notify	0	1771108447265	1771108460125	1771108460131	success	100	null
jwj8aici43re8kpskcsijwumgo	expiry_notify	0	1771109107319	1771109120432	1771109120438	success	100	null
x1tetho15jfxbq9f6nfaeej1mh	expiry_notify	0	1771110427442	1771110441129	1771110441135	success	100	null
q5uqsfdropyyi8peezhnxmmy1y	expiry_notify	0	1771111087515	1771111101469	1771111101474	success	100	null
sa8bcoihhtg8zgiqaiwb94gpaw	cleanup_desktop_tokens	0	1771111447557	1771111461634	1771111461636	success	100	null
1uq6qsotapfymbnadic8419goy	expiry_notify	0	1771112407664	1771112422116	1771112422122	success	100	null
9bkp3qbj6trp3qzjysiwiuf5ic	refresh_materialized_views	0	1771113607743	1771113622745	1771113622768	success	100	null
f79jf4a3h7yufrzkmhe3efgxhy	expiry_notify	0	1771113067718	1771113082474	1771113082480	success	100	null
tx8qbs5kmjymbys6rsi9a9o1br	product_notices	0	1771113427729	1771113442641	1771113442755	success	100	null
9ayjfx5yubff5d5z5jt133nehh	expiry_notify	0	1771113727772	1771113727782	1771113727784	success	100	null
kby8nb9fmin3iyg68awfibuopo	expiry_notify	0	1771114387829	1771114388113	1771114388117	success	100	null
c3su5fdjutrfx8t48cjdiuneny	expiry_notify	0	1771115047880	1771115048481	1771115048486	success	100	null
xu5tspohfbb4drpwqghu3miaih	expiry_notify	0	1771116308036	1771116309191	1771116309196	success	100	null
wnau1kqh6jrxfddwa977s31bmo	cleanup_desktop_tokens	0	1771115107889	1771115108513	1771115108518	success	100	null
7q8tai1id7ysunjxu6hszwgbaa	expiry_notify	0	1771115707968	1771115708853	1771115708862	success	100	null
woufoaff4fd58ebe7zihcom6yc	expiry_notify	0	1771116968093	1771116969552	1771116969557	success	100	null
y85o5gc4dpd5jdd5pd6txiumey	product_notices	0	1771117028100	1771117029586	1771117029700	success	100	null
9doccjd3r3r4j8i7z44capo9yy	expiry_notify	0	1771117628143	1771117629822	1771117629825	success	100	null
4mjxi7qrzt8mugyfpoeudpsmbe	expiry_notify	0	1771118288227	1771118290130	1771118290136	success	100	null
4m8utrbqfbde7c8ydrr1d6fzcc	cleanup_desktop_tokens	0	1771118768273	1771118770370	1771118770375	success	100	null
qjc3j9a8h78gfmhaxpfjgokjxa	expiry_notify	0	1771118948300	1771118950443	1771118950448	success	100	null
zfuathpsfbypdcdistmwtrtgwo	expiry_notify	0	1771119608375	1771119610813	1771119610819	success	100	null
diamof6jrfnyukyuu761tzojey	expiry_notify	0	1771120268448	1771120271166	1771120271171	success	100	null
7by4icbsijgaiyxfqpiobxfooh	product_notices	0	1771120628483	1771120631330	1771120631393	success	100	null
od3igj8zjifdug876y5kdkeewr	plugins	0	1771156631959	1771156634049	1771156634054	success	0	null
mq5wncjejtytpnob7gq8binncr	expiry_notify	0	1771146611044	1771146624092	1771146624098	success	100	null
b678u1e7etf3fqb4a34kcno1qh	install_plugin_notify_admin	0	1771156631943	1771156634049	1771156634060	error	-1	{"error": "Error during job execution. — GetSystemBot: List of admins is empty."}
11x763fza3y1pkgi4zm9stdr4o	expiry_notify	0	1771148591216	1771148605055	1771148605060	success	100	null
xzyi6f5a47gxxfufbgaxx8jw9e	expiry_notify	0	1771149251272	1771149265416	1771149265422	success	100	null
1gzkcdcz9i88iqd4ghqibtfcso	product_notices	0	1771149431297	1771149445483	1771149445602	success	100	null
s83sfjdyctnuzdogd7emaizpkh	cleanup_desktop_tokens	0	1771151591466	1771151591573	1771151591578	success	100	null
sqme3rwfwbyhzpmpamay4htgyw	expiry_notify	0	1771152551566	1771152551980	1771152551982	success	100	null
qahnp3aj6jd5pqhur6zit34raw	product_notices	0	1771153031622	1771153032257	1771153032366	success	100	null
8pum6mdihjni8c7n4abhu5zjio	expiry_notify	0	1771159092117	1771159095242	1771159095249	success	100	null
fd4marc7opfifkc3p4disa7die	expiry_notify	0	1771155191840	1771155193324	1771155193330	success	100	null
pff6m7b7ztnb7fscps99yj3q9w	mobile_session_metadata	0	1771156631958	1771156634050	1771156634065	success	100	null
1qycb9jbstdczrqedsrn71y3yw	cleanup_desktop_tokens	0	1771155251852	1771155253353	1771155253359	success	100	null
saz1qyiqo7bb9c9duu6j9br1gr	expiry_notify	0	1771155851872	1771155853656	1771155853663	success	100	null
qm6nkwr5qjykxjxywn5s1yei8y	export_delete	0	1771156631956	1771156634050	1771156634065	success	100	null
cr3xscfbr7fujpe99p9chj76qc	expiry_notify	0	1771156511927	1771156513988	1771156513992	success	100	null
mxnb8xh6aide8k543yxqkzcaoy	import_delete	0	1771156631950	1771156634050	1771156634066	success	100	null
jqrghaaxmtrb8xqbc4b8yfywnr	product_notices	0	1771156631954	1771156634050	1771156634152	success	100	null
cu9yw95ybbf4bgs9dmiatqdino	expiry_notify	0	1771157171985	1771157174314	1771157174320	success	100	null
6kjuzqwn8bbudbag9z7k9685ka	expiry_notify	0	1771159752178	1771159755552	1771159755559	success	100	null
fbjy66tt4tyazmiwyy6bmw9oby	expiry_notify	0	1771157832029	1771157834633	1771157834639	success	100	null
7tcrqwc3ytfqd85nhpmeikkkqh	expiry_notify	0	1771158432078	1771158434889	1771158434893	success	100	null
3biseurs5intipnsnz7e649pur	cleanup_desktop_tokens	0	1771158912120	1771158915154	1771158915159	success	100	null
du6tp99nuiggfbd4yh4itz53cr	cleanup_desktop_tokens	0	1771162512473	1771162517027	1771162517032	success	100	null
tkq8rgzm8bb4mne695so7nnbwa	product_notices	0	1771160232224	1771160235781	1771160235896	success	100	null
y5cgg6odwbrricxfxtpsh1hmfw	expiry_notify	0	1771160412230	1771160415867	1771160415872	success	100	null
ty75n6t7e7bbixjh5fw9zqc65e	expiry_notify	0	1771161072319	1771161076251	1771161076257	success	100	null
knizka7c1tdzpdaarboe5xjgoh	expiry_notify	0	1771161732369	1771161736564	1771161736570	success	100	null
tixek7wywjdpjm8twnundyh58e	expiry_notify	0	1771163052541	1771163057309	1771163057313	success	100	null
9bgbzcxid7d9mrr7yigiryws9r	expiry_notify	0	1771162392455	1771162396966	1771162396971	success	100	null
bs1gkkjgbbfnxkasxs6t4bbrtc	expiry_notify	0	1771165032739	1771165038245	1771165038253	success	100	null
w7mhowkaypdjtdq3hq8arrc9oe	expiry_notify	0	1771163712602	1771163717638	1771163717642	success	100	null
s6m6gbfsupfodkf5jrzcu6xmqr	product_notices	0	1771163832619	1771163837681	1771163837793	success	100	null
tuqz1wqf1p8zuytubtmf6xwaqe	expiry_notify	0	1771164372674	1771164377907	1771164377912	success	100	null
ffkkzqxzktb9upxoii4cpjfhfy	expiry_notify	0	1771165692811	1771165698596	1771165698599	success	100	null
bq593hd7hibwxxn4h195wi5s7o	cleanup_desktop_tokens	0	1771166172857	1771166178842	1771166178847	success	100	null
zjt61w7aepynfnx55x4ci48rgw	expiry_notify	0	1771167012954	1771167019324	1771167019331	success	100	null
uaigdetur3ryjjn6tsa31cswny	expiry_notify	0	1771166352880	1771166358952	1771166358955	success	100	null
6zgw6ttutiyhmd5h81mw8oo11a	product_notices	0	1771167432993	1771167439529	1771167439640	success	100	null
8fccdk6tjjd88g3o6ep48y5a5w	expiry_notify	0	1771167673017	1771167679642	1771167679647	success	100	null
jdp5tfm4g38n3nzy7ok4m6d7cr	expiry_notify	0	1771168333079	1771168339973	1771168339980	success	100	null
wqdtdzp96igq7nrcs5pxwpjw1c	expiry_notify	0	1771168993144	1771169000304	1771169000311	success	100	null
d5rq7n87iinmbn7wzm5sdtbs6a	expiry_notify	0	1771169653183	1771169660662	1771169660666	success	100	null
mo6yq946b3fozxjahapekih7ty	cleanup_desktop_tokens	0	1771169773211	1771169780734	1771169780739	success	100	null
kp5qiqxci3ybmnnm9nxh8omm8a	expiry_notify	0	1771170313247	1771170320998	1771170321004	success	100	null
t4cexf7wpir4zd5e6b8wdidsey	expiry_notify	0	1771170973294	1771170981369	1771170981374	success	100	null
h3wf4ioywjgpie8o4njhb7bnjh	product_notices	0	1771171033306	1771171041396	1771171041517	success	100	null
bsxjt1d1dbffp8afrqqi899two	expiry_notify	0	1771171633356	1771171641652	1771171641658	success	100	null
1tmecoxb3ine3gjcqc3jcm6ajh	expiry_notify	0	1771172293404	1771172301898	1771172301904	success	100	null
e7ikewjey7gh8ewbjizmd1gn1y	expiry_notify	0	1771172953458	1771172962228	1771172962233	success	100	null
9sd8h9okc7yszek9yo4jzjje6h	cleanup_desktop_tokens	0	1771173433502	1771173442468	1771173442471	success	100	null
hejb3on9mjy7jy5whu5jjyxyiy	expiry_notify	0	1771173613517	1771173622551	1771173622556	success	100	null
nip1gprgi3nwjc9wxara9uapzo	expiry_notify	0	1771120928508	1771120931441	1771120931442	success	100	null
ca853aoxjjfr5ccdhs4p1dcize	expiry_notify	0	1771147271099	1771147284428	1771147284434	success	100	null
1zha88u5fiyz3m9n5ni3mshjoe	expiry_notify	0	1771121588579	1771121591686	1771121591690	success	100	null
sdub69yo9bgotgsdgp7egda7cr	expiry_notify	0	1771122248626	1771122252043	1771122252048	success	100	null
74f1nxdsh3fpzgaj9j7bdofyyy	expiry_notify	0	1771147931173	1771147944730	1771147944734	success	100	null
jn8bffygdid18rtugqkrgeefca	expiry_notify	0	1771127529120	1771127534557	1771127534563	success	100	null
fds7nwsshtdg7ywwh9cydr6inw	cleanup_desktop_tokens	0	1771122428652	1771122432155	1771122432161	success	100	null
t17ptwic4pnoxdjswxycp5ydqa	cleanup_desktop_tokens	0	1771147931168	1771147944730	1771147944735	success	100	null
h9fefegjcpbb5pbf94y8wdf67y	expiry_notify	0	1771149911339	1771149925764	1771149925770	success	100	null
dx4t8q4gi7fx7yjp5hhbbysq9w	expiry_notify	0	1771122908699	1771122912367	1771122912370	success	100	null
6h4n97jwyfbmxn34chbws8wiwo	expiry_notify	0	1771150571383	1771150586096	1771150586100	success	100	null
6oyzy4egcfdbtj3xmbo5zkrj4c	expiry_notify	0	1771123568776	1771123572737	1771123572744	success	100	null
6e4i1s5xwfyitknrwfsckqz66h	expiry_notify	0	1771151231431	1771151246387	1771151246393	success	100	null
bix9iixku3dsibtw1dbw7b8oqr	product_notices	0	1771131429577	1771131436514	1771131436622	success	100	null
b4f9wfyhw7yhfgi97uqquzz7co	expiry_notify	0	1771124228788	1771124233018	1771124233023	success	100	null
od9469duzbgktmt9mmiq1rp6ow	product_notices	0	1771127829162	1771127834699	1771127834796	success	100	null
fuyx6zm76b86bcs4s7gyqxyd4a	product_notices	0	1771124228794	1771124233018	1771124233130	success	100	null
k3spoy1fc7rs9yqybss7j1ewcy	expiry_notify	0	1771151891502	1771151891723	1771151891726	success	100	null
kpt7f48pkfgq5ep91zjecwscmh	expiry_notify	0	1771124888852	1771124893297	1771124893304	success	100	null
asf69o137tdc7yfegctsa4koyc	expiry_notify	0	1771153211644	1771153212342	1771153212349	success	100	null
o439hz5w8ffkiepmnah1sd6saw	expiry_notify	0	1771125548923	1771125553616	1771125553624	success	100	null
4qdg5z6webg57gfayg3p9cfono	expiry_notify	0	1771153871718	1771153872713	1771153872718	success	100	null
77k1zxih8ffwubx7ase1fjg4py	cleanup_desktop_tokens	0	1771126088969	1771126093891	1771126093896	success	100	null
h5u5trui5pbb78g8tshgt1drha	expiry_notify	0	1771154531768	1771154533021	1771154533023	success	100	null
x7nhgrnij3nxmq7e8fpj7s1joc	expiry_notify	0	1771128189210	1771128194873	1771128194881	success	100	null
e7fkoz1kn7rszju68xg3ubs3xo	expiry_notify	0	1771126208984	1771126213956	1771126213962	success	100	null
1w54nytwffybtbzkuz473ho91c	expiry_notify	0	1771126869055	1771126874272	1771126874277	success	100	null
mycupy8eopn6imnejagj4isdiw	expiry_notify	0	1771128789259	1771128795191	1771128795198	success	100	null
4h13h8g6ftyhjxi8cgpk1pkx7r	product_notices	0	1771135029910	1771135038416	1771135038526	success	100	null
q3ohaeqsh7g9pjjcxbmgbrxzjw	expiry_notify	0	1771129449332	1771129455483	1771129455487	success	100	null
qmsj1jeeejbgfx7i84e6139xgo	expiry_notify	0	1771132089595	1771132096836	1771132096840	success	100	null
3aenj9im47813xb5s5f9kmpmsy	cleanup_desktop_tokens	0	1771129749373	1771129755667	1771129755673	success	100	null
9teiuhuxs7fsueem5hdfxtf1hh	expiry_notify	0	1771130109430	1771130115864	1771130115871	success	100	null
391wiwwaxbnh7yzdcpfb5gjpnr	expiry_notify	0	1771130769503	1771130776219	1771130776225	success	100	null
yrpzqzg5q3bfxnoqsg3gapmgeo	expiry_notify	0	1771131429572	1771131436514	1771131436521	success	100	null
ctr67s7i9iri5rxudg8e99zi4w	expiry_notify	0	1771132749652	1771132757180	1771132757186	success	100	null
nw4gou7m8fnn3bnn3aerftg44e	expiry_notify	0	1771137370142	1771137379515	1771137379520	success	100	null
g96co1sozprpmrfs6zxsdzda8o	expiry_notify	0	1771133409725	1771133417531	1771133417536	success	100	null
3m1s7docq788tn7x7mg8b64pco	cleanup_desktop_tokens	0	1771133409721	1771133417532	1771133417536	success	100	null
8fsc893mbjd73kxjarkndrwmwc	expiry_notify	0	1771135389961	1771135398639	1771135398646	success	100	null
g7pw4zgb8fbtby7rb8ucp81k7c	expiry_notify	0	1771134069765	1771134077873	1771134077876	success	100	null
t5ncq3yggbdj7px47h8ybf9oba	expiry_notify	0	1771134729862	1771134738270	1771134738275	success	100	null
i71uhobqrtyzirr3e5fg9xwsto	expiry_notify	0	1771136050024	1771136058989	1771136058992	success	100	null
imcr4949w3fp8e7ckczz6w9d7r	expiry_notify	0	1771136710058	1771136719191	1771136719195	success	100	null
1x3f5hgddtn3bf39jfxko1y45e	cleanup_desktop_tokens	0	1771137010102	1771137019341	1771137019346	success	100	null
nbkakw3e8bdst84r7w14ws9era	expiry_notify	0	1771138030205	1771138039805	1771138039811	success	100	null
ccyu8xc4tfryxp6hj5pby5x4zw	expiry_notify	0	1771139350294	1771139360436	1771139360442	success	100	null
7wm7jxerm3bbxfdp98zdb7wp6w	product_notices	0	1771138630243	1771138640101	1771138640224	success	100	null
o3daf7tghiygir54c9cqyecddr	expiry_notify	0	1771138690251	1771138700134	1771138700139	success	100	null
c6hkj8xqj3y79nophz36qb7jxo	expiry_notify	0	1771140010356	1771140020745	1771140020749	success	100	null
ffp8hsxoitdc8bzdtmaoxc94cc	cleanup_desktop_tokens	0	1771140670430	1771140681097	1771140681102	success	100	null
q1mztr545f87xjakgygmc9gy4a	expiry_notify	0	1771140670435	1771140681097	1771140681103	success	100	null
3mbuiaxxwjb1frdrjpdsp361xh	expiry_notify	0	1771141330499	1771141341462	1771141341466	success	100	null
3hxrt3czobb6ura4ddsgg9yxto	expiry_notify	0	1771141990573	1771142001816	1771142001820	success	100	null
3wbr4t88ffr3bc3sjf4dctwm5h	cleanup_desktop_tokens	0	1771317310016	1771317317409	1771317317415	success	100	null
jboibbqmbtnnzme7ndswerq1re	expiry_notify	0	1771174273578	1771174282870	1771174282873	success	100	null
853834j15pbm3n5oe6u391u3yy	expiry_notify	0	1771323010499	1771323020625	1771323020636	success	100	null
x59ghsshfpybbjbtnam4gt9fqa	product_notices	0	1771323430544	1771323440875	1771323440973	success	100	null
emixbwffjbd1dkc6tfytx8fgno	expiry_notify	0	1771346773411	1771346779072	1771346779079	success	100	null
35io1d3nctgwdgcm7dcxmhitze	expiry_notify	0	1771326310898	1771326322509	1771326322518	success	100	null
6hbbp5o5ztnbujf1sbbwmk4ekw	expiry_notify	0	1771326970948	1771326982860	1771326982866	success	100	null
5okbpw8rnf858eun3acs8ty6rh	expiry_notify	0	1771329611232	1771329624325	1771329624333	success	100	null
k5jjhqegmbdkjg4fndgoew61eh	expiry_notify	0	1771330271293	1771330284731	1771330284737	success	100	null
oocu5sycspbwmp1joa5rj6npde	expiry_notify	0	1771348093617	1771348099826	1771348099830	success	100	null
iznwqq3njpnwjgkn7txfq3x4ge	product_notices	0	1771330631344	1771330644864	1771330644991	success	100	null
gtf696fnd3d3x8wx6y1o4cipzh	expiry_notify	0	1771332251554	1771332265766	1771332265773	success	100	null
rzbmx9bfcpnw8meohn634y8ano	expiry_notify	0	1771334231763	1771334231859	1771334231863	success	100	null
s9jc4wr73jnziq8wooosz4og7a	product_notices	0	1771334231756	1771334231859	1771334231933	success	100	null
mtkik1h8ijd1tbix3px8smtzxr	expiry_notify	0	1771379810816	1771379822486	1771379822545	success	100	null
6pz4cszuj3bndr7o4ktz5xzxow	expiry_notify	0	1771334891846	1771334892213	1771334892218	success	100	null
yshif3arkpfeuqqd368e8czzce	expiry_notify	0	1771340172512	1771340175339	1771340175346	success	100	null
huoopbwscpf95kb5m45zywf4aw	product_notices	0	1771383313781	1771383324820	1771383324939	success	100	null
mbgndwg6nb8wtr3gk7xgjy7sto	expiry_notify	0	1771409533839	1771409546324	1771409546332	success	100	null
q5m4ht7xwtdaipyrgd6xktzkny	expiry_notify	0	1771432839079	1771432853763	1771432853768	success	100	null
s3cusz1p9pb87g6f5y1tf5qshr	product_notices	0	1771433079092	1771433093856	1771433093932	success	100	null
qqn38iuuwtyfxmeto88d4iy83a	expiry_notify	0	1771433499111	1771433514070	1771433514076	success	100	null
imyx8ksumfbc3mgeqdqgube8co	product_notices	0	1771174633612	1771174643047	1771174643216	success	100	null
kz443k53htf4tm64878ny37rkh	expiry_notify	0	1771174933651	1771174943176	1771174943179	success	100	null
k99ob3ge3jgnmn5nqnzkqm7ory	expiry_notify	0	1771175593721	1771175603480	1771175603484	success	100	null
s1bfyaje3py7pxqp3ktnunmaca	expiry_notify	0	1771180874225	1771180886201	1771180886208	success	100	null
38ry6xaszfnn5jwkkqrr998qpe	expiry_notify	0	1771176253763	1771176263827	1771176263833	success	100	null
tgxtb1n8x3ghfk94n5muditmgy	expiry_notify	0	1771176913838	1771176924163	1771176924170	success	100	null
wdsd3zreeirzmk8zmn74at38rr	cleanup_desktop_tokens	0	1771177093866	1771177104259	1771177104265	success	100	null
i7yrxnoympdn8qe5f3zi9kdjbr	product_notices	0	1771185434696	1771185448320	1771185448419	success	100	null
dg4kb57cobn1jnyu38frozadmo	expiry_notify	0	1771177573935	1771177584537	1771177584542	success	100	null
d3hnmwyyyf8cpfpyyxr7i9styo	expiry_notify	0	1771181534275	1771181546485	1771181546488	success	100	null
e8eckmiecfbqdy49mt7xi676sc	expiry_notify	0	1771178233989	1771178244883	1771178244887	success	100	null
pznmwpnu93g8uefw8wftkimgah	product_notices	0	1771178233993	1771178244882	1771178244987	success	100	null
8hnmpkh49ig8jpqnnrjeyk7xfh	expiry_notify	0	1771178894046	1771178905230	1771178905235	success	100	null
jbjkbx37o3bkim6ezcgzdkiz7a	expiry_notify	0	1771179554124	1771179565526	1771179565532	success	100	null
811jgu4ubtdbzr53h3m5fzdw6c	product_notices	0	1771181834317	1771181846596	1771181846714	success	100	null
187qrya8ktdudbk1nexproacyo	expiry_notify	0	1771180214157	1771180225874	1771180225880	success	100	null
dft1mbb1nbgf38yhcy5axf88ac	cleanup_desktop_tokens	0	1771180694208	1771180706094	1771180706100	success	100	null
58g7ucm4z7yfiqibrx31tbt7xr	expiry_notify	0	1771182194370	1771182206767	1771182206772	success	100	null
t38z7dsjw3rszbjp8u8p398dpr	expiry_notify	0	1771188794948	1771188809715	1771188809720	success	100	null
he65rgmybb83787r9d3ggp6mzc	expiry_notify	0	1771182854444	1771182867145	1771182867153	success	100	null
hu5i3cak37f5drrxfm44rsxpoh	expiry_notify	0	1771185494711	1771185508352	1771185508356	success	100	null
awhy7ewtjf8w3ycg3s5bqjkrhc	expiry_notify	0	1771183514500	1771183527502	1771183527504	success	100	null
ujmmp8wtybgexcuhcni7dpenoh	expiry_notify	0	1771184174547	1771184187758	1771184187760	success	100	null
fw4u36fprjbxurgn8tfygkafre	cleanup_desktop_tokens	0	1771184354567	1771184367804	1771184367808	success	100	null
5htsfw5rppb83y3xodqxu4kw1r	expiry_notify	0	1771184834633	1771184848054	1771184848058	success	100	null
qsj7y7xzrpngmpw8suqwdmb8wo	expiry_notify	0	1771186154772	1771186168690	1771186168696	success	100	null
kppjmayqq7gs3kf9cenq6go5ga	expiry_notify	0	1771186814790	1771186828904	1771186828910	success	100	null
xh5j6cdzkj8cigq53rej4q4cuh	expiry_notify	0	1771191435244	1771191436066	1771191436073	success	100	null
7o7qhp3f9fbw5g3qxbzbonma9w	expiry_notify	0	1771187474829	1771187489222	1771187489228	success	100	null
waka66x1g3d9dqqgjd9tb8uhyw	product_notices	0	1771189034983	1771189049825	1771189049937	success	100	null
zsixz8n3b7gdtcnd6wm5r1ps9w	cleanup_desktop_tokens	0	1771188014869	1771188029414	1771188029418	success	100	null
ozfk8u5smj87pb8e9bfuzw54wr	expiry_notify	0	1771188134886	1771188149486	1771188149490	success	100	null
8t1bhh5983y5xdi1aqzogdrtfc	expiry_notify	0	1771189455019	1771189470011	1771189470018	success	100	null
fueoo3sqwbyw9ds5m5t1q4zndw	expiry_notify	0	1771190115082	1771190115347	1771190115351	success	100	null
9nirm7rhctb7zrzaeq1sbbyp3w	expiry_notify	0	1771190775169	1771190775738	1771190775741	success	100	null
yt8kkbpreb8g8qaw7ubf9hp3kh	cleanup_desktop_tokens	0	1771191615261	1771191616153	1771191616158	success	100	null
3hrhiy9jhjrf9j6ougio1ygwka	expiry_notify	0	1771192755371	1771192756687	1771192756691	success	100	null
861eiy179byedqdhdsggu4hssc	expiry_notify	0	1771192095308	1771192096363	1771192096366	success	100	null
788r14ooutnpmcgfspdr1em41e	product_notices	0	1771192635360	1771192636629	1771192636737	success	100	null
exa1yaf1ff8a8fkfmojxemjehc	expiry_notify	0	1771193415406	1771193416966	1771193416969	success	100	null
7d694h9p6bremc8t5ztxeg43ra	expiry_notify	0	1771194075451	1771194077328	1771194077335	success	100	null
yizn3tngmin35x5qm9tsjw5mie	expiry_notify	0	1771194735519	1771194737674	1771194737678	success	100	null
kbah3aezjtnofcx18bbxn7g8ze	expiry_notify	0	1771196055652	1771196058404	1771196058409	success	100	null
7g549gkwgtfjjxqozrdgrjgtxy	cleanup_desktop_tokens	0	1771195275559	1771195277985	1771195277989	success	100	null
fz7j17dh7ty9tjaya666q6h3ea	expiry_notify	0	1771195395579	1771195398053	1771195398059	success	100	null
futxippzppgs986dfx554u53mc	product_notices	0	1771196235685	1771196238516	1771196238624	success	100	null
1trj5sfijfneunioxmuieqcafe	expiry_notify	0	1771196715732	1771196718752	1771196718758	success	100	null
dxqtezncdjnx78ipyyrm4os69w	expiry_notify	0	1771197375760	1771197379068	1771197379072	success	100	null
dt59csz4i3gezjzokg7fmphbyy	expiry_notify	0	1771198035810	1771198039387	1771198039392	success	100	null
xxs3ip6o1jg8bc7qnx3ew6it4c	expiry_notify	0	1771198695876	1771198699704	1771198699710	success	100	null
gqu4fz5skirz3poe7cbuhsgjia	cleanup_desktop_tokens	0	1771198935901	1771198939817	1771198939821	success	100	null
jo9ukz7oj3ramj8o4odrf6huky	expiry_notify	0	1771199355966	1771199360034	1771199360040	success	100	null
ks7i8dg1oprxmgoiexozzb97xr	product_notices	0	1771199836018	1771199840291	1771199840387	success	100	null
m7pm4kik7p8r3c6cy8ews1yrir	expiry_notify	0	1771317730067	1771317737658	1771317737666	success	100	null
wm35pcxcajre5bsd9bb8r9ejfe	refresh_materialized_views	0	1771200016046	1771200020365	1771200020384	success	100	null
7ocgaaeu4tnztdwjbsb16uuoea	expiry_notify	0	1771341492702	1771341496058	1771341496065	success	100	null
wobtb7qndidu9jrc4k8n5ntf5o	expiry_notify	0	1771200676111	1771200680721	1771200680726	success	100	null
1wq9eoo5z3ncfkdioq6acn16ja	expiry_notify	0	1771318390116	1771318398063	1771318398068	success	100	null
aj94awm3pfy9pkacu7i7j78hoe	expiry_notify	0	1771319050156	1771319058402	1771319058408	success	100	null
anya7trr9pg59foutepcj68ufw	expiry_notify	0	1771323670588	1771323681007	1771323681015	success	100	null
nre8ss1t47fa3ba7xrxcruux3y	expiry_notify	0	1771434159167	1771434159380	1771434159387	success	100	null
ecyp95aohprk9kfyt8i9ax9g7e	cleanup_desktop_tokens	0	1771324630703	1771324641552	1771324641558	success	100	null
ysxrtsgysfnzjk7c64y595wtko	expiry_notify	0	1771342152813	1771342156366	1771342156369	success	100	null
8kt4mjs1bi8dmmq7ryip4ebgac	expiry_notify	0	1771325650803	1771325662185	1771325662192	success	100	null
7weo4myqwtn3dkjr9n4dqmy8gc	product_notices	0	1771327030964	1771327042890	1771327042961	success	100	null
b6qp5h6zqp8azk3sxtt7qxwt4w	expiry_notify	0	1771328951164	1771328963929	1771328963935	success	100	null
yeooquhwtfdhxkppe8ro3n5c5y	expiry_notify	0	1771330931386	1771330945019	1771330945025	success	100	null
xyzpud9fcir6xbbn35htmtytby	cleanup_desktop_tokens	0	1771335551935	1771335552598	1771335552603	success	100	null
nmshesuwztyi5xpy17zz6q8hho	expiry_notify	0	1771335551937	1771335552597	1771335552604	success	100	null
jwpcs8u1ptyofq1gj79rmczquc	product_notices	0	1771341432687	1771341436028	1771341436132	success	100	null
iqdz354xtbga5kz5qnz9msxbyr	expiry_notify	0	1771342812896	1771342816715	1771342816721	success	100	null
j7yf9th15jfjfp7zywxao33rke	cleanup_desktop_tokens	0	1771342812890	1771342816716	1771342816722	success	100	null
6h1p9fhwibyyxqppwdce53okye	expiry_notify	0	1771343472983	1771343477118	1771343477121	success	100	null
n8z389auufgp8ru75j8h964h8o	cleanup_desktop_tokens	0	1771434639213	1771434639578	1771434639582	success	100	null
a14skmtydjgziqtkaemhzrsp7h	expiry_notify	0	1771347433489	1771347439436	1771347439444	success	100	null
7owsu1ohwfy5ijx7e4omegyday	expiry_notify	0	1771387660801	1771387672037	1771387672045	success	100	null
6mmki9rc47bibd816r3uycjzqc	expiry_notify	0	1771416351171	1771416364533	1771416364542	success	100	null
przzd8j76bggmjjirrt5wrht4o	expiry_notify	0	1771430198871	1771430212764	1771430212769	success	100	null
cz4nh378ui818ex9dm5rskutec	expiry_notify	0	1771200016040	1771200020365	1771200020372	success	100	null
pwa5wjuxitfi8nhueuc31q1fwe	expiry_notify	0	1771201336172	1771201341107	1771201341113	success	100	null
6ebq59dro38jxg7nirg1hbiskw	expiry_notify	0	1771201996243	1771202001453	1771202001457	success	100	null
4fm9ejiqz3ynxxwx8un9d8kmpw	product_notices	0	1771207036703	1771207044087	1771207044194	success	100	null
6j6xs7t1h3y3jc7apfptbbx6yr	cleanup_desktop_tokens	0	1771202596312	1771202601749	1771202601754	success	100	null
p6rt3q7pdbnsxr96fos8ju5h6e	expiry_notify	0	1771202656321	1771202661775	1771202661781	success	100	null
jga4qiamniryfg39di4nzre3bc	expiry_notify	0	1771203316375	1771203322118	1771203322125	success	100	null
qeknp3sintgsxbrzxjd5uofe6a	expiry_notify	0	1771211237093	1771211246240	1771211246247	success	100	null
8w8kutrg7bdj8ekocmdkqb5moh	product_notices	0	1771203436393	1771203442174	1771203442285	success	100	null
qbmhdbf3ijyp9rrgjin8g6w6jy	expiry_notify	0	1771207276726	1771207284217	1771207284223	success	100	null
qj51sw8783nt8gb5weungc4q9w	expiry_notify	0	1771203976459	1771203982474	1771203982479	success	100	null
usykgzmed38oxeh9nu1s7sr6wa	expiry_notify	0	1771204636505	1771204642805	1771204642809	success	100	null
sdahmu1isbbeixykpamu4xxioe	expiry_notify	0	1771205296532	1771205303179	1771205303185	success	100	null
59pcryyts7bzmbu1b6e8rttepy	expiry_notify	0	1771205956604	1771205963531	1771205963538	success	100	null
g64kbr8zjbg3dfx9ro35y4ttdy	expiry_notify	0	1771207936758	1771207944560	1771207944566	success	100	null
n79bnmepp7gpdx6eyseqtb13cy	cleanup_desktop_tokens	0	1771206256634	1771206263687	1771206263693	success	100	null
hkdrot85ctgyigg7gzzfhjuxqa	expiry_notify	0	1771206616664	1771206623885	1771206623892	success	100	null
ag8e8zkoibgtuksg61hc485f1o	expiry_notify	0	1771208596834	1771208604892	1771208604899	success	100	null
5wtswggwafdyupsbghnem5ji9e	expiry_notify	0	1771214537461	1771214547988	1771214547994	success	100	null
nxzszdsrm3rumrbhb9sfidth4r	expiry_notify	0	1771209256883	1771209265234	1771209265240	success	100	null
ntnr88ha1bfkzpna31cwqh71jr	expiry_notify	0	1771211897177	1771211906559	1771211906565	success	100	null
ip78nqg8sbdgdnzrx35tzfbqtw	expiry_notify	0	1771209916965	1771209925566	1771209925570	success	100	null
j8jydnxmuiyx8muduhu1hq947h	cleanup_desktop_tokens	0	1771209916961	1771209925566	1771209925571	success	100	null
kbtp41jfk7ng5ygq1quqtphd9o	expiry_notify	0	1771210577021	1771210585912	1771210585916	success	100	null
qqaa6ogyu78gic1nhdu1r31hdo	product_notices	0	1771210637033	1771210645941	1771210646029	success	100	null
zxzofk8qotg8frgpntx3sdsjmr	expiry_notify	0	1771212557242	1771212566920	1771212566926	success	100	null
r7wkegcjg3bxtf8jjx3ymrbxeh	expiry_notify	0	1771213217306	1771213227256	1771213227261	success	100	null
r1eh36mzeffk9yhnz5tnqpdj5o	cleanup_desktop_tokens	0	1771217237759	1771217249262	1771217249267	success	100	null
ojomsid9mb8e9xnbdowigbpsfc	cleanup_desktop_tokens	0	1771213577354	1771213587460	1771213587465	success	100	null
549ahb3a7jrbbmo5cten4bzymo	expiry_notify	0	1771215197523	1771215208232	1771215208238	success	100	null
atpme63t9idq7nbphj4nwfpmna	expiry_notify	0	1771213877383	1771213887618	1771213887623	success	100	null
o18izuosspdyxqbs1nacxdr9qw	product_notices	0	1771214237426	1771214247792	1771214247913	success	100	null
6ccyyarxatgzmxfxpfce9fwp8r	expiry_notify	0	1771215857620	1771215868591	1771215868597	success	100	null
xdkjgcgz4fr5bysnd7hkwdnjkr	expiry_notify	0	1771216517708	1771216528913	1771216528919	success	100	null
jtfrkbzjg3nj3y35da5g77aswe	expiry_notify	0	1771217177746	1771217189238	1771217189244	success	100	null
91mmkiuappgf8mqq75k7rzhy5w	expiry_notify	0	1771217837801	1771217849517	1771217849522	success	100	null
5nn4kaf7kffrtxygmiqderxoje	expiry_notify	0	1771219157916	1771219170084	1771219170091	success	100	null
y4jy8zuu4t8yuxbietxpsckpww	product_notices	0	1771217837804	1771217849517	1771217849632	success	100	null
73u8kek8k7nn5kzh5yb7enhq8e	expiry_notify	0	1771218497855	1771218509789	1771218509796	success	100	null
najicaf1wib5xddazswmj3h4mh	expiry_notify	0	1771219817987	1771219830349	1771219830356	success	100	null
b7amhj35opghimt1313i9nctwa	expiry_notify	0	1771220478055	1771220490704	1771220490710	success	100	null
1w6rjrf8nfdfzeq8mhmy3wbq8o	cleanup_desktop_tokens	0	1771220838093	1771220850883	1771220850888	success	100	null
hby3jibo43b9jjxsdhz68qstze	expiry_notify	0	1771221798178	1771221811326	1771221811332	success	100	null
3ze4ises5brq8nfaygkb1h8cxc	expiry_notify	0	1771221138116	1771221151029	1771221151035	success	100	null
yidi1nwxz3fppjumwqy3th4gjy	product_notices	0	1771221438140	1771221451170	1771221451280	success	100	null
r8dp6ywhkidbinibr36oi3ccwa	expiry_notify	0	1771222458217	1771222471650	1771222471654	success	100	null
rcqaeu9rttne8ng3xaxaudkt5c	expiry_notify	0	1771223118262	1771223131943	1771223131954	success	100	null
ip7uhxxqapdu3ydie67u8qqkno	expiry_notify	0	1771223778346	1771223792247	1771223792254	success	100	null
5kknqx48p7fb9fzwrus9548hza	expiry_notify	0	1771224438416	1771224452576	1771224452584	success	100	null
t3i334edobdduqfbmcm1s1k3ie	cleanup_desktop_tokens	0	1771224498423	1771224512607	1771224512613	success	100	null
iqrabxnfobfmpy4pgryqd1wq4c	product_notices	0	1771225038471	1771225052866	1771225052986	success	100	null
6njyz5i3epbd9jin8efi5by9yw	expiry_notify	0	1771225098483	1771225112893	1771225112900	success	100	null
dmo8zjzhmpntbjaj1c9ueuxf3a	expiry_notify	0	1771225758550	1771225773270	1771225773275	success	100	null
qksytbwtcpf63q9fiytfsepamw	expiry_notify	0	1771226418623	1771226433634	1771226433640	success	100	null
eee59wrzxfbk7yrm5jddtipa3e	expiry_notify	0	1771227078686	1771227078955	1771227078959	success	100	null
j3qzfnz68ty39yoycxy7knm5zr	expiry_notify	0	1771227738745	1771227739278	1771227739283	success	100	null
s7bkmadi7tfmucdggqe8ftimha	expiry_notify	0	1771232359181	1771232361374	1771232361378	success	100	null
xr1nmiaufbbs8fa1dbfjtdtp9r	cleanup_desktop_tokens	0	1771228158794	1771228159506	1771228159511	success	100	null
5i59f3ie83gz7xzihtsuqsyarw	expiry_notify	0	1771228398813	1771228399595	1771228399598	success	100	null
3c9kbr5ccpg67qojmc8ydfdabh	product_notices	0	1771228638866	1771228639697	1771228639773	success	100	null
s3ph6pgoypbd7mmun5kj5and6y	expiry_notify	0	1771238040234	1771238041166	1771238041172	success	100	null
jhx75ztfk7feimrsnt6njgopga	expiry_notify	0	1771229058911	1771229059916	1771229059924	success	100	null
tkhowioexiygmyz1miqjqdf3aw	expiry_notify	0	1771234079922	1771234094208	1771234094217	success	100	null
kq7h3zemg7n88gcini5errkihe	expiry_notify	0	1771229718977	1771229720277	1771229720284	success	100	null
urtyi3xbhi8qufsf88u5du5zdc	expiry_notify	0	1771230379047	1771230380619	1771230380626	success	100	null
aa9xb7agpjyqbdxnpjmkshj8ah	expiry_notify	0	1771231039073	1771231040877	1771231040882	success	100	null
rpnnhmfm5ifj5py344zhbee51w	expiry_notify	0	1771231699123	1771231701127	1771231701132	success	100	null
eecxtgqtfib45k33min5md39sc	expiry_notify	0	1771234739947	1771234754534	1771234754539	success	100	null
1chjh1muqifz3bg5q118hfwfwa	cleanup_desktop_tokens	0	1771231819136	1771231821180	1771231821185	success	100	null
i5e533e5pfrbte9xxjyg6ef5dc	product_notices	0	1771232239168	1771232241330	1771232241430	success	100	null
4yf8xy48zjfnbebnsn86cbnwze	expiry_notify	0	1771235400014	1771235414893	1771235414899	success	100	null
p53busbecfyrmy799m9i4kme4c	expiry_notify	0	1771241340515	1771241343236	1771241343243	success	100	null
xpqacncwzjyu3eenk3qcuxypar	expiry_notify	0	1771236060054	1771236060121	1771236060127	success	100	null
qwxg6zfszfb6iqquz4wqo97uwy	expiry_notify	0	1771238700249	1771238701530	1771238701536	success	100	null
obh95oqtfid8pjahzeba9wwxkr	expiry_notify	0	1771236720106	1771236720364	1771236720370	success	100	null
bwxees337tnjmbqc8enty1z19o	product_notices	0	1771237020127	1771237020507	1771237020625	success	100	null
t77y5smip3fa8f37t3cjw485iw	cleanup_desktop_tokens	0	1771237080139	1771237080539	1771237080545	success	100	null
w7rzzp4jrfb7xehpnunhih8bpo	expiry_notify	0	1771237380170	1771237380724	1771237380731	success	100	null
k55s8dkzo7y6iytp3kuafyezme	expiry_notify	0	1771239360305	1771239361946	1771239361953	success	100	null
6q7mg8w3bjnyjyt9ji9o1mochw	expiry_notify	0	1771240020372	1771240022363	1771240022369	success	100	null
t8xy58z58bysxc75bikdw5z45y	product_notices	0	1771244220828	1771244225077	1771244225147	success	100	null
okwwde8uyffsfbur6ibh7t3pzc	product_notices	0	1771240620430	1771240622728	1771240622797	success	100	null
mkr4c8wdnbb68bfqs69p1sjj6a	expiry_notify	0	1771242000573	1771242003650	1771242003654	success	100	null
n8rjtjfoajr5tpxr497jrk1e8a	expiry_notify	0	1771240680447	1771240682769	1771240682776	success	100	null
cfp8hj7c8bf9dpj3yzu1n49zte	cleanup_desktop_tokens	0	1771240740457	1771240742802	1771240742808	success	100	null
mys5d5abfjnpzdrp38hr8o8qzo	expiry_notify	0	1771242660653	1771242664129	1771242664138	success	100	null
y4b1axpq9pdsiktn85yyyuofyo	expiry_notify	0	1771243320721	1771243324546	1771243324551	success	100	null
snwrjq8jfbfubfswi6eurzdusw	expiry_notify	0	1771243980800	1771243984954	1771243984959	success	100	null
oqubyusegbn4ubm4x97axaph1w	cleanup_desktop_tokens	0	1771244400853	1771244405191	1771244405197	success	100	null
fdk1tm5bjbr6im7aps3ddmrcbe	expiry_notify	0	1771245960987	1771245966040	1771245966047	success	100	null
nnffzqt7ip8uzqbnweqwhjm4yw	expiry_notify	0	1771244640888	1771244645326	1771244645334	success	100	null
sgchr397n7ndjyq6y39386rjby	expiry_notify	0	1771245300941	1771245305673	1771245305678	success	100	null
img3jr585t8gig6swwbm11sa7a	expiry_notify	0	1771246621059	1771246626411	1771246626418	success	100	null
xboimk4xapgn7p9r8qgof6cp7c	expiry_notify	0	1771247281155	1771247286863	1771247286868	success	100	null
gm1cd6neefdzmfuenatb3pej6c	product_notices	0	1771247821238	1771247827216	1771247827284	success	100	null
91xs9wdy5pfetn48dfkzim1j7w	expiry_notify	0	1771248601353	1771248607664	1771248607669	success	100	null
3xgyrxxx6ffebgsmchmtq4oxyr	expiry_notify	0	1771247941256	1771247947291	1771247947298	success	100	null
9a4xyj4wc3n4ipcoztr7wt4unc	cleanup_desktop_tokens	0	1771248061278	1771248067360	1771248067366	success	100	null
ksp19nqhs3bu8xqo55fyqon1xr	expiry_notify	0	1771249261443	1771249268057	1771249268063	success	100	null
izi3486tetbfub31933kfr4pea	expiry_notify	0	1771249921515	1771249928405	1771249928411	success	100	null
tqie9swnd7g5jfxdhtofj7h6mr	expiry_notify	0	1771250581608	1771250588778	1771250588784	success	100	null
kmqpqwk3sbn9iyqrnwo77q7qzy	expiry_notify	0	1771251241691	1771251249162	1771251249170	success	100	null
fybyyzjuqffefxdkf6t5tt45ra	product_notices	0	1771251421727	1771251429277	1771251429382	success	100	null
uw6ed1fumibu5d1kjjtqihexqh	cleanup_desktop_tokens	0	1771251661771	1771251669433	1771251669442	success	100	null
6iekisksy3gjxn3y4myntynjee	expiry_notify	0	1771251901799	1771251909602	1771251909609	success	100	null
hygcsicf5ifn5ngmwewmihfqth	expiry_notify	0	1771252561879	1771252569970	1771252569976	success	100	null
zdumbanxppgzje1rw1y8h89hgw	expiry_notify	0	1771253221963	1771253230266	1771253230274	success	100	null
s3hbzknbu7rute3eddqyi3qjyr	expiry_notify	0	1771253882052	1771253890628	1771253890636	success	100	null
dkp1mioik3gezjwm6en3miwqke	expiry_notify	0	1771254542134	1771254550965	1771254550973	success	100	null
z46daz5xmtfezyfwpe1r8egqjy	expiry_notify	0	1771259102796	1771259113943	1771259113952	success	100	null
3jt1wkgjkfn17fjqey4k8mxz6e	product_notices	0	1771255022194	1771255031240	1771255031313	success	100	null
7cibwkj7atfoudadfd399wh8jh	expiry_notify	0	1771255202251	1771255211355	1771255211363	success	100	null
mc7dtfya8bdy8br6dizet96yje	cleanup_desktop_tokens	0	1771255322270	1771255331421	1771255331426	success	100	null
873y9zm39brqpfnbqyndypihir	expiry_notify	0	1771263663500	1771263676709	1771263676715	success	100	null
kcxnxiqyoff1fcdijj15a7ipya	expiry_notify	0	1771255862338	1771255871751	1771255871756	success	100	null
c1b4p4ohuiffpxk689rh8189gw	expiry_notify	0	1771259702879	1771259714321	1771259714324	success	100	null
kmmzk9it5ifbd8troa4rxot3ke	expiry_notify	0	1771256522441	1771256532198	1771256532203	success	100	null
8fmn7sqzzjyotpr5zgj4b79s7a	expiry_notify	0	1771257182521	1771257192672	1771257192678	success	100	null
1h4bz8pbotfeud6kbibm8aqepe	expiry_notify	0	1771257782599	1771257793056	1771257793062	success	100	null
x1szrm3ewp8rue9atd4krpsa8a	expiry_notify	0	1771258442697	1771258453468	1771258453475	success	100	null
azqo8czr438r8fw15ke5om37gr	expiry_notify	0	1771260362953	1771260374802	1771260374808	success	100	null
5euspmw637rjfn8mncm97663jc	product_notices	0	1771258622728	1771258633608	1771258633689	success	100	null
4jj4ix7zcbf1iyai6s7569pgra	cleanup_desktop_tokens	0	1771258982780	1771258993849	1771258993855	success	100	null
5pxr4nzq9pnw7qr39nirx9rg5e	expiry_notify	0	1771261023072	1771261035119	1771261035122	success	100	null
h19rmmg8oidddjfmirtwf4g5de	expiry_notify	0	1771266963850	1771266978684	1771266978689	success	100	null
73yornx9zjydfnez13hmjpeqdc	expiry_notify	0	1771261683183	1771261695462	1771261695468	success	100	null
ho5azkw4a7nxtg4kee3bpm16xc	expiry_notify	0	1771264323574	1771264337063	1771264337069	success	100	null
pq9oc9u8fifjib6om1nkjgugrr	product_notices	0	1771262223291	1771262235811	1771262235941	success	100	null
wafj1mpcs3nr5xa37ge6w7dwwr	expiry_notify	0	1771262343311	1771262355864	1771262355871	success	100	null
s6jrq38zub8tf8a8199x9b78fo	cleanup_desktop_tokens	0	1771262643361	1771262656052	1771262656058	success	100	null
wnmryosee7yhxe3qmm3k5wu9so	expiry_notify	0	1771263003404	1771263016276	1771263016284	success	100	null
rmsfuu4rxjd5ik5igasehdtftc	expiry_notify	0	1771264983648	1771264997458	1771264997465	success	100	null
qzkc5us18jdu9egbbt8b6hekih	expiry_notify	0	1771265643714	1771265657856	1771265657864	success	100	null
sqxjqfa38tdbp856aqnn3a9ahc	expiry_notify	0	1771269604221	1771269605215	1771269605221	success	100	null
a3nk6p6zqpng3pypkpo8z1f3na	product_notices	0	1771265823743	1771265837970	1771265838070	success	100	null
qxcuham1cfrx7j9wr6yy5w493h	expiry_notify	0	1771267623943	1771267624072	1771267624077	success	100	null
swhzuub3dbbsixdzxcjpsw398y	cleanup_desktop_tokens	0	1771266303793	1771266318244	1771266318251	success	100	null
auh8yuowz7n9mpk6ocnxj5scgw	expiry_notify	0	1771266303800	1771266318244	1771266318251	success	100	null
n6pbcndzcprdip65d5mmsrrz6h	expiry_notify	0	1771268284030	1771268284458	1771268284464	success	100	null
zpmbj3jgh7re5rtjrpaa9oq75a	expiry_notify	0	1771268944116	1771268944851	1771268944858	success	100	null
gzk6zisam7ffzbj6dpofio1iby	product_notices	0	1771269424189	1771269425118	1771269425206	success	100	null
7d9m967d7bgeurcgnybftqredw	cleanup_desktop_tokens	0	1771269904263	1771269905352	1771269905356	success	100	null
1bqx3afdo3g8iez57schh4iwrw	expiry_notify	0	1771271584500	1771271586329	1771271586336	success	100	null
oyuwze6gjpb3fqeag47tizopko	expiry_notify	0	1771270264314	1771270265553	1771270265556	success	100	null
e9u56x7d9j8y7q83fs3qrye4fo	expiry_notify	0	1771270924405	1771270925927	1771270925934	success	100	null
a7ncyzpoctfn8cbhmx6ke6fgfr	expiry_notify	0	1771272244695	1771272246806	1771272246813	success	100	null
u5pug4w4g7f5dep1jp9qgxr9dc	expiry_notify	0	1771272904801	1771272907253	1771272907259	success	100	null
to51146egbbdpnggbafkidpbxc	product_notices	0	1771273024823	1771273027324	1771273027404	success	100	null
7z7h74u6kbnwxyrf4q67hnedrc	expiry_notify	0	1771274224922	1771274228018	1771274228022	success	100	null
wi8aa46kni88mjz6xhahxab6oc	cleanup_desktop_tokens	0	1771273504865	1771273507596	1771273507603	success	100	null
muybw8du1fna7ni4bdn7gbzhkr	expiry_notify	0	1771273564883	1771273567624	1771273567630	success	100	null
7cw5w1uem389dgxudxf1pqpeyh	expiry_notify	0	1771274884987	1771274888413	1771274888418	success	100	null
8hamf65ma3b6if7nyx1szfddme	expiry_notify	0	1771275545006	1771275548726	1771275548731	success	100	null
9bmg9bgi4384meohbh64qxi3kc	expiry_notify	0	1771276205075	1771276209133	1771276209139	success	100	null
hjc4cam5hfg5bp7caxqwm8hbwr	product_notices	0	1771276625102	1771276629347	1771276629420	success	100	null
fwtxbdj1htyk3g9n4nqysy4xyy	expiry_notify	0	1771276865127	1771276869481	1771276869487	success	100	null
fye1ni9zs7g9bcbagrzom4fu4w	cleanup_desktop_tokens	0	1771277165169	1771277169637	1771277169642	success	100	null
jdbyu9797pffj83a1mmrgawrzy	expiry_notify	0	1771277525231	1771277529850	1771277529856	success	100	null
rtmmpqz6kidzugmwd7k93tb1ur	expiry_notify	0	1771278185288	1771278190161	1771278190167	success	100	null
da14jp3cptyy7p3gyr3j4psidh	expiry_notify	0	1771319710211	1771319718783	1771319718792	success	100	null
5s67cn7h4igjfg48trp8r69kfe	expiry_notify	0	1771278845348	1771278850500	1771278850508	success	100	null
566wyi17gbyg7m469tywarr4cr	expiry_notify	0	1771279505436	1771279510890	1771279510896	success	100	null
4gagcp94etfw8n6s3ebagg81oa	expiry_notify	0	1771280165500	1771280171257	1771280171265	success	100	null
o8b9f95sptgmbc3pxh7pdar44e	expiry_notify	0	1771284786098	1771284793955	1771284793962	success	100	null
whwecandc7rwug8zjma5fas4dw	product_notices	0	1771280225520	1771280231291	1771280231378	success	100	null
9wpr5d6dqbbgbbc4wt6msgwnkr	expiry_notify	0	1771280825602	1771280831643	1771280831650	success	100	null
1pwkfhfxi7b8deao4ctnehccph	cleanup_desktop_tokens	0	1771280825606	1771280831643	1771280831650	success	100	null
gkjxkzmghjr6tdn6nj5qrfw84y	expiry_notify	0	1771288746587	1771288756271	1771288756277	success	100	null
3piub6ona7njdy85sw18j7irxy	expiry_notify	0	1771281485672	1771281492021	1771281492029	success	100	null
7z1y1a9w1bnu5jrm3okbyspd3c	expiry_notify	0	1771285446175	1771285454415	1771285454418	success	100	null
km7h5inpipggjj917i9hsek1mo	expiry_notify	0	1771282145757	1771282152431	1771282152437	success	100	null
gpiy8zyd1bfab8xqj6tbb1ti1h	expiry_notify	0	1771282805840	1771282812799	1771282812806	success	100	null
zkz7h5mkcb8b8y14t7xsmqg6xy	expiry_notify	0	1771283465919	1771283473183	1771283473186	success	100	null
bxazwe9f57diby1giir3rjrwpa	product_notices	0	1771283825960	1771283833396	1771283833473	success	100	null
s9zkwdtfnif8dbj3cnridq97iw	expiry_notify	0	1771286106226	1771286114796	1771286114802	success	100	null
sh1yfnspnifniqc6j3xh9mqesr	expiry_notify	0	1771284125988	1771284133559	1771284133563	success	100	null
cf9myogo6ibetk4ozui8i8s1dy	cleanup_desktop_tokens	0	1771284486047	1771284493770	1771284493775	success	100	null
mmiqxhepypnu7yju8de7rg7ide	refresh_post_stats	0	1771286406270	1771286414925	1771286414941	success	100	null
xhx37h43d3btbpasqet6n5wpiw	expiry_notify	0	1771292047055	1771292058393	1771292058398	success	100	null
b4stqzsm7ir1fyadezkeupbm7h	expiry_notify	0	1771286766296	1771286775072	1771286775075	success	100	null
ib3jr363xfr88pjy3mpwo5meya	expiry_notify	0	1771289406673	1771289416651	1771289416659	success	100	null
khfo6yfju7bfbjonkyed7k5psc	expiry_notify	0	1771287426381	1771287435452	1771287435456	success	100	null
gqf7o7qy83r9b8e9dkn6e95sia	product_notices	0	1771287426388	1771287435451	1771287435517	success	100	null
isj5rboo9pfmiqrrmmod8th4fw	expiry_notify	0	1771288086461	1771288095854	1771288095860	success	100	null
gf6bm4r5hbdcbbxg3p6erb18te	cleanup_desktop_tokens	0	1771288146475	1771288155882	1771288155888	success	100	null
63iqj11mxjdmbjpe7mq8rsetzh	expiry_notify	0	1771290066761	1771290077066	1771290077073	success	100	null
a1y46fiky38b3e6sc98wswjbua	expiry_notify	0	1771290726863	1771290737488	1771290737496	success	100	null
c1m1cnywepretg5n81ozwwsruh	expiry_notify	0	1771294687335	1771294700100	1771294700108	success	100	null
8ycsadwsmprducih6wkd63woxc	product_notices	0	1771291026911	1771291037710	1771291037788	success	100	null
abpgntko9f8yibswn1qh5syh9e	expiry_notify	0	1771292707121	1771292718823	1771292718831	success	100	null
zy5hqu9hojyqum6ag83yrjut7c	expiry_notify	0	1771291386975	1771291397950	1771291397955	success	100	null
a3wt7tmyytyh5p7t61xoz8ntpo	cleanup_desktop_tokens	0	1771291807027	1771291818251	1771291818257	success	100	null
qf5zynn7wpr4ufm3kpyyr9ksor	expiry_notify	0	1771293367219	1771293379275	1771293379281	success	100	null
mta4s9yfk7gg5q5nmg4b1ag9ia	expiry_notify	0	1771294027293	1771294039759	1771294039764	success	100	null
rq7z9mg9mpndifsntpmy1kwj3o	product_notices	0	1771294627325	1771294640076	1771294640146	success	100	null
xnkthzkt7ign5gru1w1znr6igo	expiry_notify	0	1771295287420	1771295300370	1771295300375	success	100	null
crquhdgmgtrptkuacz181zqzna	expiry_notify	0	1771296607542	1771296621130	1771296621137	success	100	null
7bq5smfm83nwtrzjkkccp359wy	cleanup_desktop_tokens	0	1771295407435	1771295420438	1771295420443	success	100	null
mgkeh9msdfda7gfbk7co59p8zr	expiry_notify	0	1771295947499	1771295960744	1771295960749	success	100	null
xe4e8dxcxjbk5xc74q1tww8jry	expiry_notify	0	1771297267622	1771297281463	1771297281467	success	100	null
kt39c9g85fgfzp9onao3biozje	expiry_notify	0	1771297927696	1771297941876	1771297941882	success	100	null
tfxfbsp3d3f55yrxjkfueuc4hw	product_notices	0	1771298227743	1771298242063	1771298242142	success	100	null
otsyqmfs5jb93mqk8pqoi4pjpa	expiry_notify	0	1771299247866	1771299262604	1771299262609	success	100	null
nth7twepdpd57eye9g6noce1mc	expiry_notify	0	1771298587801	1771298602295	1771298602303	success	100	null
1f5ttx7wmf8ttyf3ygi7b4zsgo	cleanup_desktop_tokens	0	1771299007837	1771299022496	1771299022501	success	100	null
btonpfjcsfdpxkk3xte8photth	expiry_notify	0	1771299907928	1771299907932	1771299907935	success	100	null
o43589ddtfn8bnpxjp8osofbdc	expiry_notify	0	1771300567996	1771300568279	1771300568287	success	100	null
5c7y3oyec7bxmbte1zg93uiukc	expiry_notify	0	1771301228081	1771301228607	1771301228612	success	100	null
kzzb9e7n3jdrde61isidarby4c	product_notices	0	1771301828151	1771301828935	1771301829021	success	100	null
a61j63ndjf8xdrefu5zpz5nzge	expiry_notify	0	1771301888168	1771301888968	1771301888977	success	100	null
xkkjwsm8fi8fjxjf1t89gu4waw	expiry_notify	0	1771302548242	1771302549337	1771302549342	success	100	null
r9qdxgo5yb8iinqm838y7a9w9r	cleanup_desktop_tokens	0	1771302668266	1771302669397	1771302669403	success	100	null
pr5iq4993irodencdu389uopqa	expiry_notify	0	1771303208327	1771303209696	1771303209701	success	100	null
pifq5wzybfg93kkya81ksuytza	expiry_notify	0	1771303868399	1771303870026	1771303870031	success	100	null
fc6qti6cq7fj3but1h7bmz3soa	expiry_notify	0	1771336872100	1771336873393	1771336873398	success	100	null
yxhsmi4ujpg6ufmhbkmq4n7bpy	import_delete	0	1771319830232	1771319838851	1771319838856	success	100	null
y7k3zh65kpnw3nxjearjt9ryia	mobile_session_metadata	0	1771319830234	1771319838851	1771319838856	success	100	null
wgzu7wrxgfya9j6s7wdiei663o	export_delete	0	1771319830229	1771319838851	1771319838856	success	100	null
4jsjm73rnbd8xytydjpe1zxw1e	install_plugin_notify_admin	0	1771319830236	1771319838851	1771319838863	success	100	null
gwba3nnw7jd8t8ik44zso94row	plugins	0	1771319830223	1771319838851	1771319838867	success	0	null
fj5rh5iak3ydikxxya6cfxu1ma	expiry_notify	0	1771338192260	1771338194202	1771338194208	success	100	null
ddxxj6bgbtbs8chz8qmqijmy3a	product_notices	0	1771319830238	1771319838851	1771319838913	success	100	null
siddf3gp8ibhxmn4ycxebgeo7r	expiry_notify	0	1771324330638	1771324341372	1771324341378	success	100	null
gt9rarzasjnk5qbg7hrg89qznw	expiry_notify	0	1771327631024	1771327643210	1771327643219	success	100	null
wmkcgj8gftfx9ynfkeo1z3apoh	expiry_notify	0	1771331591475	1771331605372	1771331605376	success	100	null
1cdaxfri17d55nhcyjqd64eory	expiry_notify	0	1771338852332	1771338854685	1771338854691	success	100	null
ti697ikfm7bgdxz8ox4abcys8r	cleanup_desktop_tokens	0	1771331951515	1771331965577	1771331965583	success	100	null
i8moowccwfdqinezifino5y9ac	expiry_notify	0	1771332911629	1771332926138	1771332926143	success	100	null
34dye6rbg3rbmjggij1w1c9fua	expiry_notify	0	1771336212014	1771336212962	1771336212969	success	100	null
3uf54yp1wjyufmy4yo94awztwa	expiry_notify	0	1771351649848	1771351656971	1771351656978	success	100	null
pi6hhez1pfr8fjntc1xiuzwzse	cleanup_desktop_tokens	0	1771339212399	1771339214876	1771339214881	success	100	null
xsrofnryubnwtj7gn9egcmsf1a	expiry_notify	0	1771339512449	1771339515037	1771339515043	success	100	null
dyyxzg8kipyx8dzzm6swb4thsa	expiry_notify	0	1771344133089	1771344137477	1771344137485	success	100	null
yqkg3aybut8bmpnsx8kebc5hye	expiry_notify	0	1771344793193	1771344797880	1771344797885	success	100	null
s9d5opj647d3jrdqp9snwrzp1w	expiry_notify	0	1771352249942	1771352257268	1771352257275	success	100	null
483hwmiitjr6zbyna745c9jccw	product_notices	0	1771345033216	1771345038041	1771345038146	success	100	null
itp6bgeh8tyebpbiopko3a3cuo	expiry_notify	0	1771346113326	1771346118675	1771346118681	success	100	null
iqw4piu9ci885x5h7an8b1z7qw	product_notices	0	1771351529835	1771351536916	1771351537032	success	100	null
bc918g6fpig1pr1d519uscx7ey	expiry_notify	0	1771394000344	1771394011933	1771394011940	success	100	null
9zerahd5478kikpqx698i63rww	cleanup_desktop_tokens	0	1771398544726	1771398556574	1771398556580	success	100	null
9eybx8hgb3ftbnu61y3qctqtyr	product_notices	0	1771423598698	1771423612276	1771423612382	success	100	null
rac3py3qsfb8tckhnrx97wudiy	expiry_notify	0	1771424172631	1771424186250	1771424186258	success	100	null
ikms3eeomfgo8pzaezswek7dno	expiry_notify	0	1771304528448	1771304530337	1771304530346	success	100	null
dzk8178nppn6tnuodd8ya5cbwo	cleanup_desktop_tokens	0	1771430978940	1771430993027	1771430993032	success	100	null
bzswhabxdifri8ystqktm3uyoy	expiry_notify	0	1771320370266	1771320379188	1771320379191	success	100	null
mx9okr89tirefpqsdybpf8zjfy	expiry_notify	0	1771305188486	1771305190703	1771305190710	success	100	null
bpbjtw9q9j8638cm3gtw83eqja	cleanup_desktop_tokens	0	1771328291103	1771328303573	1771328303580	success	100	null
icfodn5kebg95gkwqts1619quc	cleanup_desktop_tokens	0	1771320970308	1771320979576	1771320979582	success	100	null
jtmca651wjfj8x47bj3qw36kqr	product_notices	0	1771305428533	1771305430843	1771305430912	success	100	null
7io3cf6uwj8mpmfnfjgsrmonar	expiry_notify	0	1771310469263	1771310473666	1771310473669	success	100	null
y1j3jxfrc785bp6h7pt3wpxcqa	expiry_notify	0	1771305848604	1771305851071	1771305851076	success	100	null
6ckp6asuzpbgdqytqysh9yocwc	expiry_notify	0	1771328291099	1771328303574	1771328303580	success	100	null
1woipdxesbg3bmn1xuua56ahrr	expiry_notify	0	1771321030312	1771321039619	1771321039624	success	100	null
m5dgmtsmj7nu9p6zopdxzh8ygw	cleanup_desktop_tokens	0	1771306328657	1771306331334	1771306331341	success	100	null
wrqwwy9xx7gkpkp4rrtzrurdwh	expiry_notify	0	1771321690362	1771321699974	1771321699981	success	100	null
4adpsqoqwprgtmqhs6exu8a3zo	expiry_notify	0	1771306508678	1771306511408	1771306511413	success	100	null
p65bh4pwjid1u859tfqxdgzrma	expiry_notify	0	1771307168782	1771307171748	1771307171750	success	100	null
j3ydi8qo9bb4mxmwtomeofdbar	expiry_notify	0	1771322350433	1771322360278	1771322360283	success	100	null
cxyftyhqqjd57cb6zxemfh95xw	expiry_notify	0	1771311129337	1771311134088	1771311134097	success	100	null
69jq1e5e6bybikdf1y6mzn1d6w	expiry_notify	0	1771307828872	1771307832109	1771307832113	success	100	null
oghugb1befr4zegagryf4ciera	expiry_notify	0	1771345453276	1771345458317	1771345458325	success	100	null
pmursuwnqb8u7m7ataqu358gkw	expiry_notify	0	1771324990738	1771325001754	1771325001762	success	100	null
fj7dui1u9pnu9qeo95445x4h9h	expiry_notify	0	1771308488980	1771308492468	1771308492475	success	100	null
64o8f58wfirwfd9p74ctomtbqw	product_notices	0	1771309029055	1771309032784	1771309032905	success	100	null
adsc47rhh3bgfj1pyxaztmp85r	expiry_notify	0	1771333571688	1771333586489	1771333586497	success	100	null
3ejfyu8n3iyapr1sjd7ub7m6cy	expiry_notify	0	1771309149082	1771309152842	1771309152850	success	100	null
wzp31wd7y7fwuj1b7dj34iogoc	expiry_notify	0	1771311789417	1771311794511	1771311794517	success	100	null
mfrfq1no6fd4fenpjhkpdmi1dy	expiry_notify	0	1771309809164	1771309813258	1771309813266	success	100	null
sq7kgbojt7y59nm6ro3uourpmc	expiry_notify	0	1771337532166	1771337533840	1771337533847	success	100	null
5qjo1c7b6ff9mnk3wo1n564idy	cleanup_desktop_tokens	0	1771309989185	1771309993385	1771309993391	success	100	null
xptnyun9g38uixg19m6o4aunjw	expiry_notify	0	1771364800322	1771364809695	1771364809700	success	100	null
yww84iob6frjbcs5sh9uegw9jc	expiry_notify	0	1771312449513	1771312454867	1771312454872	success	100	null
778mqpjappd55rrx4i37ci7zpy	product_notices	0	1771337832223	1771337833996	1771337834087	success	100	null
bc1yurw7hi8t8esi5aomberjpc	product_notices	0	1771312629553	1771312634932	1771312634995	success	100	null
5xaet88ba3g5ieqsn1mhmpounc	cleanup_desktop_tokens	0	1771346413367	1771346418856	1771346418863	success	100	null
19i4cbqczpg89d7niboutwshxc	expiry_notify	0	1771340832600	1771340835686	1771340835690	success	100	null
hyydair4cbfkjbj1xrqutxj6py	expiry_notify	0	1771313109608	1771313115148	1771313115152	success	100	null
4hmicjdmkbfaxdtk7n66u7kupa	cleanup_desktop_tokens	0	1771313649638	1771313655381	1771313655387	success	100	null
wsd4a6nn6jfximdgyh8dywizjr	expiry_notify	0	1771357464115	1771357473203	1771357473211	success	100	null
yupmhikfsffbupoac8rqkeu4pc	expiry_notify	0	1771313769647	1771313775436	1771313775441	success	100	null
5ajqukfpkfbp7rcfpyrwfc3x7e	cleanup_desktop_tokens	0	1771357524324	1771357533433	1771357533439	success	100	null
aw1ca4rhm3nnty7u6s8a4zzmho	expiry_notify	0	1771314429708	1771314435762	1771314435765	success	100	null
f3e4ipagabggikxg51qm866jze	expiry_notify	0	1771401547068	1771401560462	1771401560468	success	100	null
b31cd8hx6tgsir36yaywc3kzth	expiry_notify	0	1771372144709	1771372154045	1771372154052	success	100	null
5sbjgweob78amc9u6co88616cr	refresh_post_stats	0	1771373296219	1771373306370	1771373306385	success	100	null
kboao914yj8omdgapx9c859r4c	expiry_notify	0	1771430858921	1771430872986	1771430872990	success	100	null
wn1d1ddc67nu7por3edigmq49r	expiry_notify	0	1771432179046	1771432193491	1771432193494	success	100	null
gpxz4rad3id6pesfqnxmgsnb8e	expiry_notify	0	1771431518988	1771431533209	1771431533211	success	100	null
\.


--
-- Data for Name: licenses; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.licenses (id, createat, bytes) FROM stdin;
\.


--
-- Data for Name: linkmetadata; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.linkmetadata (hash, url, "timestamp", type, data) FROM stdin;
\.


--
-- Data for Name: llm_postmeta; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.llm_postmeta (rootpostid, title) FROM stdin;
\.


--
-- Data for Name: notifyadmin; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.notifyadmin (userid, createat, requiredplan, requiredfeature, trial, sentat) FROM stdin;
\.


--
-- Data for Name: oauthaccessdata; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.oauthaccessdata (token, refreshtoken, redirecturi, clientid, userid, expiresat, scope, audience) FROM stdin;
\.


--
-- Data for Name: oauthapps; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.oauthapps (id, creatorid, createat, updateat, clientsecret, name, description, callbackurls, homepage, istrusted, iconurl, mattermostappid, isdynamicallyregistered) FROM stdin;
\.


--
-- Data for Name: oauthauthdata; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.oauthauthdata (clientid, userid, code, expiresin, createat, redirecturi, state, scope, codechallenge, codechallengemethod, resource) FROM stdin;
\.


--
-- Data for Name: outgoingoauthconnections; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.outgoingoauthconnections (id, name, creatorid, createat, updateat, clientid, clientsecret, credentialsusername, credentialspassword, oauthtokenurl, granttype, audiences) FROM stdin;
\.


--
-- Data for Name: outgoingwebhooks; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.outgoingwebhooks (id, token, createat, updateat, deleteat, creatorid, channelid, teamid, triggerwords, callbackurls, displayname, contenttype, triggerwhen, username, iconurl, description) FROM stdin;
\.


--
-- Data for Name: persistentnotifications; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.persistentnotifications (postid, createat, lastsentat, deleteat, sentcount) FROM stdin;
\.


--
-- Data for Name: pluginkeyvaluestore; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.pluginkeyvaluestore (pluginid, pkey, pvalue, expireat) FROM stdin;
com.mattermost.calls	mmi_botid	\\x717739313735726e743779796a627477637a6d783179337a3579	0
mattermost-plugin-servicenow	mmi_botid	\\x666e653572717a397533667a66646d64786e613174667735726f	0
com.github.manland.mattermost-plugin-gitlab	mmi_botid	\\x6a34613866383836687067627865666f756679796570716b6568	0
jira	mmi_botid	\\x677874746139687866376770757034786670677064646661706f	0
github	mmi_botid	\\x377a6d7a716a656a36333833386b6371617a357873756831796f	0
jira	rsa_key	\\x7b224e223a3135323431353334323832383439333234343336383031323339393830313931363632363834383730383035393436393636383736323131313639393937323934383535343534343136383030323333303330303239363130343938333134383933373535383730393634333830323132373834383639393638303537353239343736383939383936313339363934333332313033303638363434373438353633373432333436313635313030313137383934353034363637313638343737343032323638313530303433313338323431363239343432313332393937373337373434323132333434303734373232303534383039353639323138333338343338383835303633333531393235313139323033323530393838303531303837343332393233373330313839363537313537363632372c2245223a36353533372c2244223a343836363339373638313734363532363630303835323433333638373631393336383332313432303239313034383431393730303038383738353435323339313730303131343139303032333131343832323937353837303131343234343435393634363333313037393037393834373330303335353538363633393636363230383436343338333838353739313239313933303631343934303235373737373533333538383631323034383237383130383934353731323035383138323830303338323831323631343638393637333530323330343932343439323531383036353338383236333439353133363632393432313833353031343432323737363530373533353738393734353936343239353330353836383632383639353332383032343234353732353132303039323137332c225072696d6573223a5b31323732303731383337373238343733353832303734363131383030363031313531373434373132303739373238333735393731363630373034333430323836313438353230383635343338333532303535353330383931323931363539393432373537343032343137333936393936393734343530353539343833333634303533373638323035323030373734363730363933353233343131372c31313938313636313539333934343234323339323835363939363232383137323135393134323334333337313234363338333035353437313232343436373533313131323838323535303533353332303538333431393734333933393532323232323834373136303836353733323538303533313137323932363832323835323936333031303333353636343434353437303534363530373033315d2c22507265636f6d7075746564223a7b224470223a31303136383131313935303639313033323039393531303239333939393736393839313039393435333238373235303035373737363733393439393435333737383830383336393933373131323339363137303236313236373836343730323034303236353639343635313533343130373938353334363735323037383239333037343234383331373338353236303532343432393038383532312c224471223a393130343934333933353531313430383230363830303139313133313034373034303133393236343630373339343438353038333637313438323037373738373838323933323935303537333837343834343637353037303338323737373435303032343137343231333537373237363538353935313035323130323335303137323633323837353132303332343630303231323936353835332c2251696e76223a31313932373738303731383239353836303430313336333834393431323539373435393632353231393035393039333939373236363131373838343737343531353034323030343636323136353539393133343338333630373237343939353431393238313434383235383036383539383933363734343634353939333030343230383330373837383934393434303035303238383637363535392c2243525456616c756573223a5b5d7d7d	0
github	_flow-4num934yzfb9udo1zdwxwd7gjc-setup	\\x7b22537465704e616d65223a2277656c636f6d65222c22446f6e65223a66616c73652c22506f73744944223a226f667861343835706d627231356a66707873737a736b6f7a7065222c224170705374617465223a7b224261736555524c223a2268747470733a2f2f6769746875622e636f6d2f222c2244656c65676174656446726f6d223a22222c2249734f41757468436f6e66696775726564223a66616c73652c22557365507265726567697374657265644170706c69636174696f6e223a66616c73657d7d	0
com.github.manland.mattermost-plugin-gitlab	_flow-4num934yzfb9udo1zdwxwd7gjc-setup	\\x7b22537465704e616d65223a2277656c636f6d65222c22446f6e65223a66616c73652c22506f73744944223a2263693865716b63626b37727a6678777035366237357036783365222c224170705374617465223a7b2244656c65676174656446726f6d223a22222c224769746c616255524c223a2268747470733a2f2f6769746c61622e636f6d222c2249734f41757468436f6e66696775726564223a66616c73652c22557365507265726567697374657265644170706c69636174696f6e223a66616c73657d7d	0
jira	_flow-4num934yzfb9udo1zdwxwd7gjc-setup-wizard	\\x7b22537465704e616d65223a2277656c636f6d65222c22446f6e65223a66616c73652c22506f73744944223a226570356f66617870366a79386d657277626d756b797a71367377222c224170705374617465223a7b7d7d	0
github	mm34646_token_reset_done	\\x646f6e65	0
com.mattermost.nps	ServerUpgrade-10.4.0	\\x7b227365727665725f76657273696f6e223a2231302e342e30222c22757067726164655f6174223a22323032362d30322d31365430393a31303a32372e3730333736383932375a227d	0
com.mattermost.nps	WelcomeFeedbackMigration	\\x7b224372656174654174223a22323032362d30322d31365430393a31303a32372e3730333736383932375a227d	0
com.mattermost.nps	Survey-10.4.0	\\x7b227365727665725f76657273696f6e223a2231302e342e30222c226372656174655f6174223a22323032362d30322d31365430393a31303a32372e3730333736383932375a222c2273746172745f6174223a22323032362d30342d30325430393a31303a32372e3730333736383932375a227d	0
com.mattermost.nps	AdminDM-4num934yzfb9udo1zdwxwd7gjc-10.4.0	\\x7b2273656e74223a66616c73652c227365727665725f76657273696f6e223a2231302e342e30222c227375727665795f73746172745f6174223a22323032362d30342d30325430393a31303a32372e3730333736383932375a227d	0
com.mattermost.nps	LastAdminNotice	\\x22323032362d30322d31365430393a31303a32372e3730333736383932375a22	0
\.


--
-- Data for Name: postacknowledgements; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.postacknowledgements (postid, userid, acknowledgedat, remoteid, channelid) FROM stdin;
\.


--
-- Data for Name: postreminders; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.postreminders (postid, userid, targettime) FROM stdin;
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.posts (id, createat, updateat, deleteat, userid, channelid, rootid, originalid, message, type, props, hashtags, filenames, fileids, hasreactions, editat, ispinned, remoteid) FROM stdin;
jy6x3k845jntxn1uzxb9pspuuy	1771232687410	1771232687410	0	4num934yzfb9udo1zdwxwd7gjc	a4qjba5kb7doj8e3ob9p6zgsbc			admin joined the team.	system_join_team	{"username": "admin"}		[]	[]	f	0	f	\N
5jukga5epf8eprn9dwqx8fpiae	1771232687449	1771232687449	0	4num934yzfb9udo1zdwxwd7gjc	44b8teksdin8dmx18ctogjf6eh			admin joined the channel.	system_join_channel	{"username": "admin"}		[]	[]	f	0	f	\N
ofxa485pmbr15jfpxsszskozpe	1771232699025	1771232699025	0	7zmzqjej63838kcqaz5xsuh1yo	w7zggyteefg39kffpxhx1ojegh				slack_attachment	{"from_bot": "true", "attachments": [{"id": 0, "ts": null, "text": "Just a few configuration steps to go!\\n- **Step 1:** Register an OAuth application in GitHub and enter OAuth values.\\n- **Step 2:** Connect your GitHub account\\n- **Step 3:** Create a webhook in GitHub", "color": "", "title": "", "fields": null, "footer": "", "actions": [{"id": "16yts6x6cfy1dkeqmu4nmrhffe", "name": "Continue", "type": "button", "style": "primary", "integration": {"url": "/plugins/github/setup/button", "context": {"step": "welcome", "button": "1"}}}], "pretext": ":wave: Welcome to your GitHub integration! [Learn more](https://github.com/mattermost/mattermost-plugin-github#readme)", "fallback": ": Just a few configuration steps to go!\\n- **Step 1:** Register an OAuth application in GitHub and enter OAuth values.\\n- **Step 2:** Connect your GitHub account\\n- **Step 3:** Create a webhook in GitHub", "image_url": "", "thumb_url": "", "title_link": "", "author_icon": "", "author_link": "", "author_name": "", "footer_icon": ""}], "from_plugin": "true"}		[]	[]	f	0	f	\N
ci8eqkcbk7rzfxwp56b75p6x3e	1771232699127	1771232699127	0	j4a8f886hpgbxefoufyyepqkeh	k5soarcppffwj8nxs9qsne7rda				slack_attachment	{"from_bot": "true", "attachments": [{"id": 0, "ts": null, "text": "Just a few configuration steps to go!\\n- **Step 1:** Register an OAuth application in GitLab and enter OAuth values.\\n- **Step 2:** Connect your GitLab account\\n- **Step 3:** Create a webhook in GitLab", "color": "", "title": "", "fields": null, "footer": "", "actions": [{"id": "31koegwnktbe9qpsauhcj9mg8h", "name": "Continue", "type": "button", "style": "primary", "integration": {"url": "/plugins/com.github.manland.mattermost-plugin-gitlab/setup/button", "context": {"step": "welcome", "button": "1"}}}], "pretext": ":wave: Welcome to your GitLab integration! [Learn more](https://mattermost.gitbook.io/plugin-gitlab/)", "fallback": ": Just a few configuration steps to go!\\n- **Step 1:** Register an OAuth application in GitLab and enter OAuth values.\\n- **Step 2:** Connect your GitLab account\\n- **Step 3:** Create a webhook in GitLab", "image_url": "", "thumb_url": "", "title_link": "", "author_icon": "", "author_link": "", "author_name": "", "footer_icon": ""}], "from_plugin": "true"}		[]	[]	f	0	f	\N
ep5ofaxp6jy8merwbmukyzq6sw	1771232699292	1771232699292	0	gxtta9hxf7gpup4xfpgpddfapo	y34rezxo6bgqf8z1kuuaxqfypa				slack_attachment	{"from_bot": "true", "attachments": [{"id": 0, "ts": null, "text": "Just a few more configuration steps to go!\\n1. Choose your Jira edition.\\n2. Create an incoming application link.\\n3. Configure a Jira subscription webhook.\\n4. Connect your user account.\\n\\nYou can **Cancel** setup at any time, and use `/jira` command to complete the configuration later. See the [documentation](https://mattermost.gitbook.io/plugin-jira/setting-up/configuration) for details.", "color": "", "title": "", "fields": null, "footer": "", "actions": [{"id": "pt8a746f5id6fpasdrzqj9ddba", "name": "Continue", "type": "button", "style": "primary", "integration": {"url": "/plugins/jira/setup-wizard/button", "context": {"step": "welcome", "button": "1"}}}, {"id": "hhtcqjefwj8rtbyjdbd7qoe96a", "name": "Cancel setup", "type": "button", "style": "danger", "integration": {"url": "/plugins/jira/setup-wizard/button", "context": {"step": "welcome", "button": "2"}}}], "pretext": ":wave: Welcome to Jira integration! [Learn more](https://github.com/mattermost/mattermost-plugin-jira#readme)", "fallback": ": Just a few more configuration steps to go!\\n1. Choose your Jira edition.\\n2. Create an incoming application link.\\n3. Configure a Jira subscription webhook.\\n4. Connect your user account.\\n\\nYou can **Cancel** setup at any time, and use `/jira` command to complete the configuration later. See the [documentation](https://mattermost.gitbook.io/plugin-jira/setting-up/configuration) for details.", "image_url": "", "thumb_url": "", "title_link": "", "author_icon": "", "author_link": "", "author_name": "", "footer_icon": ""}], "from_plugin": "true"}		[]	[]	f	0	f	\N
\.


--
-- Data for Name: postspriority; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.postspriority (postid, channelid, priority, requestedack, persistentnotifications) FROM stdin;
\.


--
-- Data for Name: preferences; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.preferences (userid, category, name, value) FROM stdin;
4num934yzfb9udo1zdwxwd7gjc	tutorial_step	4num934yzfb9udo1zdwxwd7gjc	0
4num934yzfb9udo1zdwxwd7gjc	system_notice	GMasDM	true
4num934yzfb9udo1zdwxwd7gjc	onboarding_task_list	onboarding_task_list_show	true
4num934yzfb9udo1zdwxwd7gjc	recommended_next_steps	hide	true
4num934yzfb9udo1zdwxwd7gjc	onboarding_task_list	onboarding_task_list_open	false
4num934yzfb9udo1zdwxwd7gjc	direct_channel_show	7zmzqjej63838kcqaz5xsuh1yo	true
4num934yzfb9udo1zdwxwd7gjc	direct_channel_show	j4a8f886hpgbxefoufyyepqkeh	true
4num934yzfb9udo1zdwxwd7gjc	direct_channel_show	gxtta9hxf7gpup4xfpgpddfapo	true
\.


--
-- Data for Name: productnoticeviewstate; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.productnoticeviewstate (userid, noticeid, viewed, "timestamp") FROM stdin;
4num934yzfb9udo1zdwxwd7gjc	gfycat_deprecation_7.8	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	gif_deprecation_7.9_7.10	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	gfycat_deprecation_8.0	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	gfycat_deprecation_8.1	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	patch_upgrade	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	patch_upgrade2	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	crt-admin-disabled	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	crt-admin-default_off	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	crt-user-default-on	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	crt-user-always-on	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	bleve_deprecation	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	certificate_deprecation	1	1771232683
4num934yzfb9udo1zdwxwd7gjc	unsupported-server-v5.37	1	1771232683
\.


--
-- Data for Name: propertyfields; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.propertyfields (id, groupid, name, type, attrs, targetid, targettype, createat, updateat, deleteat) FROM stdin;
9d9dnxyw13y17rge4p89enumec	itd4zda567rrd861y75oo719ry	flagged_post_id	text	null			1769687701992	1769687701992	0
s4pphexrhp8h8g4f6zj1hbcryh	itd4zda567rrd861y75oo719ry	reporting_reason	select	null			1769687701994	1769687701994	0
5erpwa6wj7rqbqb368cr38u38r	itd4zda567rrd861y75oo719ry	reporting_comment	text	null			1769687701997	1769687701997	0
wxuqn54u5brrbetao46qk8rauy	itd4zda567rrd861y75oo719ry	reporting_time	text	{"subType": "timestamp"}			1769687701999	1769687701999	0
7bfx7ijskjfauko3paw1hahgdy	itd4zda567rrd861y75oo719ry	reviewer_user_id	user	{"editable": true}			1769687702000	1769687702000	0
sqhrzehdrfyiugi7pkm77x41qw	itd4zda567rrd861y75oo719ry	actor_user_id	user	null			1769687702002	1769687702002	0
cejzrq1ritfupprkzh3nz7qm5h	itd4zda567rrd861y75oo719ry	actor_comment	text	null			1769687702004	1769687702004	0
decfm8jun3rbxpcy6byqn4tbbw	itd4zda567rrd861y75oo719ry	action_time	text	{"subType": "timestamp"}			1769687702005	1769687702005	0
67ujdfhrqtb3dfyje4nfbsjama	itd4zda567rrd861y75oo719ry	status	select	{"options": [{"name": "Pending", "color": "light_grey"}, {"name": "Assigned", "color": "dark_blue"}, {"name": "Removed", "color": "dark_red"}, {"name": "Retained", "color": "light_blue"}]}			1769687702006	1769687702006	0
czkdu7r4rjrtbj6yczsodyrfwo	itd4zda567rrd861y75oo719ry	reporting_user_id	user	null			1769687702007	1769687702007	0
mi3ohw4hbifdzbtszbd8xcnzny	itd4zda567rrd861y75oo719ry	content_flagging_managed	text	null			1769687702008	1769687702008	0
\.


--
-- Data for Name: propertygroups; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.propertygroups (id, name) FROM stdin;
itd4zda567rrd861y75oo719ry	content_flagging
\.


--
-- Data for Name: propertyvalues; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.propertyvalues (id, targetid, targettype, groupid, fieldid, value, createat, updateat, deleteat) FROM stdin;
\.


--
-- Data for Name: publicchannels; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.publicchannels (id, deleteat, teamid, displayname, name, header, purpose) FROM stdin;
a4qjba5kb7doj8e3ob9p6zgsbc	0	pphqf1o9gtf97jjp5dwid5hqje	Town Square	town-square		
44b8teksdin8dmx18ctogjf6eh	0	pphqf1o9gtf97jjp5dwid5hqje	Off-Topic	off-topic		
\.


--
-- Data for Name: reactions; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.reactions (userid, postid, emojiname, createat, updateat, deleteat, remoteid, channelid) FROM stdin;
\.


--
-- Data for Name: recentsearches; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.recentsearches (userid, searchpointer, query, createat) FROM stdin;
\.


--
-- Data for Name: remoteclusters; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.remoteclusters (remoteid, remoteteamid, name, displayname, siteurl, createat, lastpingat, token, remotetoken, topics, creatorid, pluginid, options, defaultteamid, deleteat, lastglobalusersyncat) FROM stdin;
\.


--
-- Data for Name: retentionidsfordeletion; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.retentionidsfordeletion (id, tablename, ids) FROM stdin;
\.


--
-- Data for Name: retentionpolicies; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.retentionpolicies (id, displayname, postduration) FROM stdin;
\.


--
-- Data for Name: retentionpolicieschannels; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.retentionpolicieschannels (policyid, channelid) FROM stdin;
\.


--
-- Data for Name: retentionpoliciesteams; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.retentionpoliciesteams (policyid, teamid) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.roles (id, name, displayname, description, createat, updateat, deleteat, permissions, schememanaged, builtin) FROM stdin;
3mdg1yzb1bd47cyx41jokd66kw	team_user	authentication.roles.team_user.name	authentication.roles.team_user.description	1769687701288	1769687701969	0	 view_team add_user_to_team create_private_channel invite_user join_public_channels list_team_channels playbook_private_create create_public_channel read_public_channel playbook_public_create	t	t
snqc3kq6n7n85n8qqkb5i5yuty	custom_group_user	authentication.roles.custom_group_user.name	authentication.roles.custom_group_user.description	1769687701284	1769687701966	0		f	f
gx5e5zb7i3r4dgz9daosb4979a	channel_guest	authentication.roles.channel_guest.name	authentication.roles.channel_guest.description	1769687701285	1769687701966	0	 remove_reaction upload_file add_reaction read_channel read_channel_content edit_post use_channel_mentions create_post	t	t
opt86ysnjpb1iyp96ec3x1j3ea	channel_user	authentication.roles.channel_user.name	authentication.roles.channel_user.description	1769687701285	1769687701967	0	 manage_private_channel_members add_reaction create_post read_channel edit_post get_public_link read_private_channel_groups use_channel_mentions order_bookmark_private_channel delete_post use_group_mentions edit_bookmark_private_channel upload_file delete_bookmark_public_channel remove_reaction delete_bookmark_private_channel manage_public_channel_members add_bookmark_public_channel manage_private_channel_properties manage_public_channel_properties delete_private_channel delete_public_channel edit_bookmark_public_channel read_public_channel_groups order_bookmark_public_channel add_bookmark_private_channel read_channel_content	t	t
7s5xo5ccc3y8bbbpgp8n33k7te	channel_admin	authentication.roles.channel_admin.name	authentication.roles.channel_admin.description	1769687701286	1769687701967	0	 edit_bookmark_public_channel add_bookmark_private_channel manage_private_channel_banner delete_bookmark_public_channel manage_public_channel_members edit_bookmark_private_channel read_public_channel_groups add_reaction order_bookmark_private_channel use_channel_mentions order_bookmark_public_channel use_group_mentions manage_private_channel_members remove_reaction upload_file add_bookmark_public_channel manage_channel_roles create_post read_private_channel_groups manage_public_channel_banner delete_bookmark_private_channel manage_channel_access_rules	t	t
4xqknbqajtnaufn3k5wkf7ieyw	system_admin	authentication.roles.global_admin.name	authentication.roles.global_admin.description	1769687701282	1769687701969	0	 manage_secure_connections manage_system_wide_oauth read_public_channel sysconsole_write_user_management_system_roles sysconsole_write_environment_image_proxy manage_license_information revoke_user_access_token read_elasticsearch_post_aggregation_job remove_saml_public_cert bypass_incoming_webhook_channel_lock list_team_channels sysconsole_write_user_management_users sysconsole_read_environment_rate_limiting add_saml_idp_cert join_public_teams read_compliance_export_job sysconsole_read_user_management_permissions manage_others_outgoing_webhooks view_team test_ldap add_ldap_private_cert manage_others_bots list_private_teams playbook_public_manage_properties view_members edit_others_posts create_elasticsearch_post_aggregation_job sysconsole_write_environment_database create_direct_channel sysconsole_read_experimental_feature_flags manage_private_channel_properties playbook_private_create remove_saml_private_cert create_public_channel sysconsole_write_environment_developer sysconsole_read_environment_smtp sysconsole_read_about_edition_and_license join_public_channels sysconsole_read_compliance_compliance_monitoring sysconsole_read_site_emoji read_elasticsearch_post_indexing_job read_others_bots sysconsole_write_compliance_custom_terms_of_service create_data_retention_job sysconsole_read_user_management_groups test_s3 create_group_channel add_saml_public_cert delete_emojis create_post_ephemeral delete_post sysconsole_write_authentication_ldap manage_own_incoming_webhooks invalidate_caches add_saml_private_cert manage_own_slash_commands read_private_channel_groups sysconsole_write_site_notices read_ldap_sync_job sysconsole_write_authentication_guest_access sysconsole_read_environment_elasticsearch sysconsole_write_environment_rate_limiting sysconsole_read_environment_high_availability sysconsole_write_site_posts manage_ldap_sync_job sysconsole_read_environment_database remove_ldap_public_cert sysconsole_read_compliance_custom_terms_of_service sysconsole_write_authentication_mfa order_bookmark_private_channel playbook_private_view invite_guest sysconsole_write_environment_web_server manage_data_retention_job add_bookmark_private_channel sysconsole_read_site_notices delete_others_emojis upload_file manage_channel_roles add_ldap_public_cert sysconsole_write_reporting_team_statistics sysconsole_write_experimental_feature_flags manage_team_roles sysconsole_read_products_boards sysconsole_read_authentication_mfa sysconsole_write_authentication_email manage_compliance_export_job sysconsole_read_environment_file_storage sysconsole_write_site_ip_filters sysconsole_read_authentication_email create_user_access_token remove_saml_idp_cert sysconsole_write_environment_mobile_security create_post manage_public_channel_members read_public_channel_groups purge_elasticsearch_indexes sysconsole_read_site_public_links edit_bookmark_private_channel read_data_retention_job add_bookmark_public_channel manage_others_slash_commands convert_private_channel_to_public sysconsole_write_integrations_integration_management manage_private_channel_banner list_users_without_team sysconsole_read_authentication_openid sysconsole_write_compliance_compliance_monitoring sysconsole_write_environment_file_storage sysconsole_write_site_emoji sysconsole_write_environment_push_notification_server join_private_teams edit_bookmark_public_channel read_audits demote_to_guest create_private_channel delete_others_posts assign_system_admin_role sysconsole_write_user_management_groups sysconsole_read_integrations_cors read_jobs sysconsole_write_site_announcement_banner sysconsole_read_environment_session_lengths sysconsole_read_site_file_sharing_and_downloads read_license_information create_custom_group sysconsole_read_reporting_team_statistics sysconsole_write_site_localization remove_ldap_private_cert add_reaction manage_team use_group_mentions manage_shared_channels sysconsole_read_site_users_and_teams sysconsole_read_site_localization read_bots download_compliance_export_result sysconsole_read_site_announcement_banner read_deleted_posts delete_public_channel sysconsole_read_site_ip_filters read_user_access_token playbook_private_manage_properties remove_others_reactions sysconsole_read_experimental_features read_channel_content sysconsole_write_about_edition_and_license delete_custom_group sysconsole_write_site_customization edit_other_users sysconsole_read_plugins create_bot sysconsole_write_reporting_site_statistics manage_bots playbook_public_view sysconsole_write_authentication_password reload_config convert_public_channel_to_private delete_private_channel sysconsole_read_authentication_guest_access manage_public_channel_properties sysconsole_read_authentication_saml create_emojis use_channel_mentions sysconsole_write_environment_high_availability read_channel test_elasticsearch sysconsole_read_billing test_site_url sysconsole_write_plugins edit_custom_group manage_elasticsearch_post_aggregation_job invite_user playbook_private_manage_roles delete_bookmark_public_channel sysconsole_write_authentication_saml sysconsole_write_integrations_gif create_ldap_sync_job run_manage_members sysconsole_write_compliance_compliance_export get_logs sysconsole_read_site_customization sysconsole_write_integrations_cors manage_jobs import_team manage_roles run_create manage_system invalidate_email_invite sysconsole_write_environment_smtp playbook_public_make_private sysconsole_write_authentication_openid manage_elasticsearch_post_indexing_job sysconsole_write_site_public_links manage_channel_access_rules sysconsole_read_site_posts sysconsole_read_site_notifications sysconsole_read_user_management_system_roles sysconsole_write_authentication_signup sysconsole_read_environment_web_server sysconsole_write_environment_logging sysconsole_read_authentication_password sysconsole_write_site_notifications manage_public_channel_banner sysconsole_write_environment_session_lengths create_post_public edit_brand sysconsole_write_site_file_sharing_and_downloads playbook_private_manage_members sysconsole_read_reporting_server_logs remove_reaction assign_bot get_saml_cert_status manage_own_outgoing_webhooks run_manage_properties sysconsole_write_billing sysconsole_read_environment_developer get_analytics sysconsole_read_environment_push_notification_server create_team delete_bookmark_private_channel get_public_link manage_private_channel_members sysconsole_write_site_users_and_teams order_bookmark_public_channel sysconsole_read_integrations_gif sysconsole_read_reporting_site_statistics sysconsole_write_reporting_server_logs playbook_public_manage_members run_view recycle_database_connections use_slash_commands sysconsole_read_integrations_integration_management sysconsole_read_user_management_channels sysconsole_write_experimental_features playbook_private_make_public sysconsole_write_products_boards playbook_public_create sysconsole_write_integrations_bot_accounts sysconsole_read_environment_mobile_security promote_guest sysconsole_read_user_management_teams sysconsole_read_authentication_signup restore_custom_group create_compliance_export_job sysconsole_write_compliance_data_retention_policy sysconsole_read_authentication_ldap sysconsole_read_compliance_data_retention_policy sysconsole_read_integrations_bot_accounts sysconsole_write_environment_performance_monitoring sysconsole_write_user_management_channels add_user_to_team sysconsole_read_compliance_compliance_export sysconsole_write_environment_elasticsearch sysconsole_write_user_management_permissions get_saml_metadata_from_idp edit_post sysconsole_write_user_management_teams sysconsole_read_environment_performance_monitoring read_other_users_teams list_public_teams manage_outgoing_oauth_connections sysconsole_read_user_management_users sysconsole_read_environment_image_proxy manage_custom_group_members sysconsole_read_environment_logging test_email create_elasticsearch_post_indexing_job manage_others_incoming_webhooks playbook_public_manage_roles remove_user_from_team	t	t
6m188m316bg5tek6xikquxynih	team_guest	authentication.roles.team_guest.name	authentication.roles.team_guest.description	1769687701286	1769687701968	0	 view_team	t	t
bwf7rgq787nizj4afwhjscps4e	team_post_all_public	authentication.roles.team_post_all_public.name	authentication.roles.team_post_all_public.description	1769687701287	1769687701968	0	 use_group_mentions use_channel_mentions create_post_public	f	t
kammmdxs3jr3dcbmn1sifm9zpa	system_custom_group_admin	authentication.roles.system_custom_group_admin.name	authentication.roles.system_custom_group_admin.description	1769687701278	1769687701964	0	 restore_custom_group manage_custom_group_members create_custom_group edit_custom_group delete_custom_group	f	t
sot9ptsjgiyktj81pcktr7gepw	run_member	authentication.roles.run_member.name	authentication.roles.run_member.description	1769687701279	1769687701964	0	 run_view	t	t
qafuxe3a87bbjyygbahpt7reda	run_admin	authentication.roles.run_admin.name	authentication.roles.run_admin.description	1769687701287	1769687701968	0	 run_manage_members run_manage_properties	t	t
hoks6a43d7fnbk65cwkbghskao	playbook_member	authentication.roles.playbook_member.name	authentication.roles.playbook_member.description	1769687701280	1769687701964	0	 playbook_public_manage_properties playbook_private_view playbook_private_manage_members playbook_private_manage_properties run_create playbook_public_view playbook_public_manage_members	t	t
fryobq6atid7dnyqwx5hxypi6w	team_post_all	authentication.roles.team_post_all.name	authentication.roles.team_post_all.description	1769687701282	1769687701965	0	 create_post use_channel_mentions upload_file use_group_mentions	f	t
xcqkcyfqapdopqrtkkypctho7h	system_guest	authentication.roles.global_guest.name	authentication.roles.global_guest.description	1769687701284	1769687701966	0	 create_direct_channel create_group_channel	t	t
hxeoeipmc3yx984iigb893jy7c	playbook_admin	authentication.roles.playbook_admin.name	authentication.roles.playbook_admin.description	1769687701289	1769687701970	0	 playbook_public_manage_roles playbook_public_manage_properties playbook_private_manage_members playbook_private_manage_roles playbook_private_manage_properties playbook_public_make_private playbook_public_manage_members	t	t
wd3snowncjndd8p9uzmg88u34h	system_post_all	authentication.roles.system_post_all.name	authentication.roles.system_post_all.description	1769687701289	1769687701970	0	 use_channel_mentions create_post use_group_mentions upload_file	f	t
up4ss6kcdtr98f38izxfchry3h	system_post_all_public	authentication.roles.system_post_all_public.name	authentication.roles.system_post_all_public.description	1769687701290	1769687701971	0	 use_channel_mentions create_post_public use_group_mentions	f	t
czjdpbbq5jntjkaqontd1awtey	system_user_access_token	authentication.roles.system_user_access_token.name	authentication.roles.system_user_access_token.description	1769687701290	1769687701971	0	 revoke_user_access_token create_user_access_token read_user_access_token	f	t
1nzp8ftx6jn45gwyipyou4h5er	system_user	authentication.roles.global_user.name	authentication.roles.global_user.description	1769687701288	1769687701972	0	 create_custom_group manage_custom_group_members create_emojis create_team restore_custom_group edit_custom_group list_public_teams create_direct_channel join_public_teams view_members delete_custom_group delete_emojis create_group_channel	t	t
43sx6xz8ifyujp51qhdnsqhsby	system_read_only_admin	authentication.roles.system_read_only_admin.name	authentication.roles.system_read_only_admin.description	1769687701281	1769687701965	0	 sysconsole_read_compliance_compliance_monitoring sysconsole_read_authentication_ldap read_elasticsearch_post_aggregation_job read_public_channel sysconsole_read_environment_rate_limiting sysconsole_read_environment_file_storage sysconsole_read_user_management_permissions sysconsole_read_environment_session_lengths sysconsole_read_compliance_data_retention_policy read_elasticsearch_post_indexing_job sysconsole_read_plugins read_private_channel_groups sysconsole_read_user_management_groups sysconsole_read_compliance_compliance_export sysconsole_read_site_notices sysconsole_read_environment_logging read_audits sysconsole_read_environment_elasticsearch test_ldap sysconsole_read_integrations_bot_accounts list_private_teams sysconsole_read_integrations_integration_management read_ldap_sync_job view_team sysconsole_read_environment_image_proxy sysconsole_read_authentication_signup sysconsole_read_environment_push_notification_server sysconsole_read_site_notifications sysconsole_read_authentication_saml read_other_users_teams sysconsole_read_site_announcement_banner sysconsole_read_site_emoji sysconsole_read_environment_web_server read_compliance_export_job sysconsole_read_integrations_cors sysconsole_read_environment_high_availability sysconsole_read_authentication_password sysconsole_read_site_customization sysconsole_read_user_management_users sysconsole_read_site_public_links download_compliance_export_result sysconsole_read_experimental_features sysconsole_read_authentication_openid sysconsole_read_site_posts sysconsole_read_user_management_channels read_license_information sysconsole_read_user_management_teams sysconsole_read_authentication_guest_access sysconsole_read_environment_mobile_security sysconsole_read_environment_database sysconsole_read_products_boards sysconsole_read_authentication_mfa sysconsole_read_site_localization sysconsole_read_environment_developer read_data_retention_job sysconsole_read_reporting_server_logs sysconsole_read_site_users_and_teams sysconsole_read_environment_smtp sysconsole_read_integrations_gif list_public_teams sysconsole_read_reporting_team_statistics read_channel read_public_channel_groups sysconsole_read_reporting_site_statistics get_logs get_analytics sysconsole_read_about_edition_and_license sysconsole_read_environment_performance_monitoring sysconsole_read_compliance_custom_terms_of_service sysconsole_read_experimental_feature_flags sysconsole_read_site_file_sharing_and_downloads sysconsole_read_authentication_email	f	t
b74hmcsux3y4dxx5wsb7877rgw	system_user_manager	authentication.roles.system_user_manager.name	authentication.roles.system_user_manager.description	1769687701291	1769687701972	0	 join_private_teams sysconsole_read_authentication_ldap read_public_channel sysconsole_read_authentication_guest_access sysconsole_write_user_management_channels manage_public_channel_members sysconsole_read_authentication_email remove_user_from_team manage_private_channel_members sysconsole_read_user_management_permissions manage_team_roles list_public_teams sysconsole_read_authentication_mfa delete_private_channel sysconsole_read_authentication_openid manage_channel_roles add_user_to_team read_channel sysconsole_read_authentication_password sysconsole_write_user_management_teams test_ldap manage_team sysconsole_read_authentication_signup read_public_channel_groups sysconsole_read_user_management_teams sysconsole_write_user_management_groups convert_public_channel_to_private sysconsole_read_authentication_saml read_ldap_sync_job manage_public_channel_properties convert_private_channel_to_public read_private_channel_groups sysconsole_read_user_management_channels list_private_teams delete_public_channel join_public_teams manage_private_channel_properties view_team sysconsole_read_user_management_groups	f	t
xmda5onrs3r38k9zjdhp1bnt9o	system_manager	authentication.roles.system_manager.name	authentication.roles.system_manager.description	1769687701276	1769687701963	0	 create_elasticsearch_post_aggregation_job sysconsole_read_plugins test_email sysconsole_read_site_file_sharing_and_downloads reload_config sysconsole_write_site_localization sysconsole_read_environment_session_lengths sysconsole_read_products_boards delete_private_channel manage_elasticsearch_post_aggregation_job sysconsole_read_environment_developer sysconsole_write_integrations_integration_management read_channel manage_elasticsearch_post_indexing_job sysconsole_read_site_announcement_banner sysconsole_read_integrations_bot_accounts sysconsole_read_reporting_team_statistics sysconsole_read_about_edition_and_license remove_user_from_team sysconsole_read_authentication_guest_access sysconsole_read_site_localization sysconsole_read_environment_image_proxy sysconsole_write_integrations_cors manage_channel_roles sysconsole_read_user_management_permissions sysconsole_read_integrations_cors sysconsole_read_site_notifications manage_private_channel_members sysconsole_read_site_public_links convert_private_channel_to_public sysconsole_read_reporting_site_statistics sysconsole_read_user_management_channels sysconsole_read_environment_smtp view_team sysconsole_read_authentication_mfa sysconsole_write_environment_smtp read_public_channel sysconsole_write_environment_session_lengths sysconsole_write_environment_database sysconsole_read_authentication_saml sysconsole_write_user_management_groups manage_team_roles sysconsole_read_site_emoji sysconsole_write_environment_rate_limiting join_public_teams sysconsole_read_environment_database sysconsole_read_authentication_signup invalidate_caches sysconsole_read_site_customization sysconsole_write_integrations_bot_accounts sysconsole_read_environment_push_notification_server purge_elasticsearch_indexes test_elasticsearch sysconsole_read_integrations_gif sysconsole_read_reporting_server_logs sysconsole_write_environment_file_storage sysconsole_write_site_public_links add_user_to_team sysconsole_write_environment_logging get_logs sysconsole_read_environment_high_availability convert_public_channel_to_private list_public_teams sysconsole_write_environment_elasticsearch read_public_channel_groups sysconsole_write_site_customization sysconsole_write_site_notifications test_ldap sysconsole_write_products_boards read_ldap_sync_job read_private_channel_groups sysconsole_write_site_emoji sysconsole_write_user_management_permissions sysconsole_read_environment_performance_monitoring sysconsole_read_site_notices sysconsole_write_environment_developer sysconsole_write_site_notices sysconsole_write_environment_high_availability manage_public_channel_properties list_private_teams sysconsole_write_site_users_and_teams manage_public_channel_members sysconsole_read_environment_logging sysconsole_write_site_posts read_elasticsearch_post_aggregation_job edit_brand manage_outgoing_oauth_connections sysconsole_write_environment_performance_monitoring sysconsole_write_environment_push_notification_server sysconsole_read_environment_file_storage sysconsole_read_authentication_email sysconsole_write_user_management_channels sysconsole_write_user_management_teams sysconsole_read_authentication_openid test_s3 recycle_database_connections read_elasticsearch_post_indexing_job sysconsole_write_integrations_gif sysconsole_write_site_file_sharing_and_downloads sysconsole_read_authentication_ldap sysconsole_read_environment_web_server sysconsole_write_environment_web_server sysconsole_read_environment_rate_limiting sysconsole_read_integrations_integration_management read_license_information sysconsole_read_user_management_groups test_site_url sysconsole_write_environment_image_proxy sysconsole_read_site_posts sysconsole_read_site_users_and_teams sysconsole_read_user_management_teams delete_public_channel join_private_teams create_elasticsearch_post_indexing_job sysconsole_read_authentication_password manage_private_channel_properties sysconsole_write_site_announcement_banner sysconsole_read_environment_elasticsearch get_analytics manage_team	f	t
ek8heydqw7nc5jotnxkm9emjhy	team_admin	authentication.roles.team_admin.name	authentication.roles.team_admin.description	1769687701283	1769687701965	0	 bypass_incoming_webhook_channel_lock add_bookmark_private_channel convert_public_channel_to_private playbook_private_manage_roles manage_own_slash_commands add_reaction manage_channel_roles edit_bookmark_public_channel manage_private_channel_banner manage_team_roles upload_file delete_bookmark_public_channel delete_bookmark_private_channel delete_post remove_reaction delete_others_posts manage_team order_bookmark_private_channel order_bookmark_public_channel manage_public_channel_members read_public_channel_groups convert_private_channel_to_public manage_own_outgoing_webhooks manage_channel_access_rules use_channel_mentions manage_private_channel_members remove_user_from_team read_private_channel_groups manage_own_incoming_webhooks create_post use_group_mentions edit_bookmark_private_channel manage_others_incoming_webhooks import_team manage_others_outgoing_webhooks add_bookmark_public_channel manage_public_channel_banner manage_others_slash_commands playbook_public_manage_roles	t	t
\.


--
-- Data for Name: scheduledposts; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.scheduledposts (id, createat, updateat, userid, channelid, rootid, message, props, fileids, priority, scheduledat, processedat, errorcode) FROM stdin;
\.


--
-- Data for Name: schemes; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.schemes (id, name, displayname, description, createat, updateat, deleteat, scope, defaultteamadminrole, defaultteamuserrole, defaultchanneladminrole, defaultchanneluserrole, defaultteamguestrole, defaultchannelguestrole, defaultplaybookadminrole, defaultplaybookmemberrole, defaultrunadminrole, defaultrunmemberrole) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.sessions (id, token, createat, expiresat, lastactivityat, userid, deviceid, roles, isoauth, props, expirednotify) FROM stdin;
oi58ghy1njdztnfbehz6kubzfh	fojiowma6jdw5jq4a7fhntuoma	1771233422857	0	1771233422857	qw9175rnt7yyjbtwczmx1y3z5y			f	{}	f
\.


--
-- Data for Name: sharedchannelattachments; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.sharedchannelattachments (id, fileid, remoteid, createat, lastsyncat) FROM stdin;
\.


--
-- Data for Name: sharedchannelremotes; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.sharedchannelremotes (id, channelid, creatorid, createat, updateat, isinviteaccepted, isinviteconfirmed, remoteid, lastpostupdateat, lastpostid, lastpostcreateat, lastpostcreateid, deleteat, lastmemberssyncat) FROM stdin;
\.


--
-- Data for Name: sharedchannels; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.sharedchannels (channelid, teamid, home, readonly, sharename, sharedisplayname, sharepurpose, shareheader, creatorid, createat, updateat, remoteid) FROM stdin;
\.


--
-- Data for Name: sharedchannelusers; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.sharedchannelusers (id, userid, remoteid, createat, lastsyncat, channelid, lastmembershipsyncat) FROM stdin;
\.


--
-- Data for Name: sidebarcategories; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.sidebarcategories (id, userid, teamid, sortorder, sorting, type, displayname, muted, collapsed) FROM stdin;
favorites_4num934yzfb9udo1zdwxwd7gjc_pphqf1o9gtf97jjp5dwid5hqje	4num934yzfb9udo1zdwxwd7gjc	pphqf1o9gtf97jjp5dwid5hqje	0		favorites	Favorites	f	f
channels_4num934yzfb9udo1zdwxwd7gjc_pphqf1o9gtf97jjp5dwid5hqje	4num934yzfb9udo1zdwxwd7gjc	pphqf1o9gtf97jjp5dwid5hqje	10		channels	Channels	f	f
direct_messages_4num934yzfb9udo1zdwxwd7gjc_pphqf1o9gtf97jjp5dwid5hqje	4num934yzfb9udo1zdwxwd7gjc	pphqf1o9gtf97jjp5dwid5hqje	20	recent	direct_messages	Direct Messages	f	f
\.


--
-- Data for Name: sidebarchannels; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.sidebarchannels (channelid, userid, categoryid, sortorder) FROM stdin;
\.


--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.status (userid, status, manual, lastactivityat, dndendtime, prevstatus) FROM stdin;
\.


--
-- Data for Name: systems; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.systems (name, value) FROM stdin;
CRTChannelMembershipCountsMigrationComplete	true
CRTThreadCountsAndUnreadsMigrationComplete	true
AsymmetricSigningKey	{"ecdsa_key":{"curve":"P-256","x":95693673189697345113452032827023290235657795460237227817161086080046413521605,"y":66555210696122518470079358928974622132576050638049266863256465275827945450332,"d":15329620931182988727751868694683578298438741561871073557485024058590367061833}}
DiagnosticId	38kqwepixtdoznqq3ci5t9rhzw
AdvancedPermissionsMigrationComplete	true
EmojisPermissionsMigrationComplete	true
GuestRolesCreationMigrationComplete	true
SystemConsoleRolesCreationMigrationComplete	true
CustomGroupAdminRoleCreationMigrationComplete	true
emoji_permissions_split	true
webhook_permissions_split	true
integrations_own_permissions	true
list_join_public_private_teams	true
remove_permanent_delete_user	true
add_bot_permissions	true
apply_channel_manage_delete_to_channel_user	true
remove_channel_manage_delete_from_team_user	true
view_members_new_permission	true
add_manage_guests_permissions	true
channel_moderations_permissions	true
add_use_group_mentions_permission	true
add_system_console_permissions	true
add_convert_channel_permissions	true
manage_shared_channel_permissions	true
manage_secure_connections_permissions	true
add_system_roles_permissions	true
add_billing_permissions	true
download_compliance_export_results	true
experimental_subsection_permissions	true
authentication_subsection_permissions	true
integrations_subsection_permissions	true
site_subsection_permissions	true
compliance_subsection_permissions	true
environment_subsection_permissions	true
about_subsection_permissions	true
reporting_subsection_permissions	true
test_email_ancillary_permission	true
playbooks_permissions	true
custom_groups_permissions	true
playbooks_manage_roles	true
products_boards	true
custom_groups_permission_restore	true
read_channel_content_permissions	true
add_ip_filtering_permissions	true
add_outgoing_oauth_connections_permissions	true
add_channel_bookmarks_permissions	true
add_manage_jobs_ancillary_permissions	true
add_upload_file_permission	true
restrict_access_to_channel_conversion_to_public_permissions	true
fix_read_audits_permission	true
remove_get_analytics_permission	true
add_sysconsole_mobile_security_permission	true
add_channel_banner_permissions	true
add_channel_access_rules_permission	true
ContentExtractionConfigDefaultTrueMigrationComplete	true
PlaybookRolesCreationMigrationComplete	true
RemainingSchemaMigrations	true
PostPriorityConfigDefaultTrueMigrationComplete	true
content_flagging_setup_done	v5
PostActionCookieSecret	{"key":"pxQ6nNFxma7lNdlQlkSklCpwlXRV7KZO8Cdmnrw5ens="}
InstallationDate	1769687704459
FirstServerRunTimestamp	1769687705184
delete_empty_drafts_migration	true
delete_orphan_drafts_migration	true
delete_dms_preferences_migration	true
migration_advanced_permissions_phase_2	true
OrganizationName	iut
FirstAdminSetupComplete	true
LastSecurityTime	1771276619847
\.


--
-- Data for Name: teammembers; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.teammembers (teamid, userid, roles, deleteat, schemeuser, schemeadmin, schemeguest, createat) FROM stdin;
pphqf1o9gtf97jjp5dwid5hqje	4num934yzfb9udo1zdwxwd7gjc		0	t	t	f	1771232687379
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.teams (id, createat, updateat, deleteat, displayname, name, description, email, type, companyname, alloweddomains, inviteid, schemeid, allowopeninvite, lastteamiconupdate, groupconstrained, cloudlimitsarchived) FROM stdin;
pphqf1o9gtf97jjp5dwid5hqje	1771232687362	1771232687362	0	iut	iut		steeve.pytel@gmail.com	O			9cmp9txd8frx5bx8hs495hiykh		f	0	f	f
\.


--
-- Data for Name: termsofservice; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.termsofservice (id, createat, userid, text) FROM stdin;
\.


--
-- Data for Name: threadmemberships; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.threadmemberships (postid, userid, following, lastviewed, lastupdated, unreadmentions) FROM stdin;
\.


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.threads (postid, replycount, lastreplyat, participants, channelid, threaddeleteat, threadteamid) FROM stdin;
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.tokens (token, createat, type, extra) FROM stdin;
\.


--
-- Data for Name: uploadsessions; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.uploadsessions (id, type, createat, userid, channelid, filename, path, filesize, fileoffset, remoteid, reqfileid) FROM stdin;
\.


--
-- Data for Name: useraccesstokens; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.useraccesstokens (id, token, userid, description, isactive) FROM stdin;
\.


--
-- Data for Name: usergroups; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.usergroups (id, name, displayname, description, source, remoteid, createat, updateat, deleteat, allowreference) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.users (id, createat, updateat, deleteat, username, password, authdata, authservice, email, emailverified, nickname, firstname, lastname, roles, allowmarketing, props, notifyprops, lastpasswordupdate, lastpictureupdate, failedattempts, locale, mfaactive, mfasecret, "position", timezone, remoteid, lastlogin, mfausedtimestamps) FROM stdin;
j4a8f886hpgbxefoufyyepqkeh	1771232697379	1771232697649	0	gitlab		\N		gitlab@localhost	f		GitLab Plugin		system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1771232697379	1771232697649	0	en	f			{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}	\N	0	null
gxtta9hxf7gpup4xfpgpddfapo	1771232697459	1771232697573	0	jira		\N		jira@localhost	f		Jira		system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1771232697459	1771232697573	0	en	f			{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}	\N	0	null
7zmzqjej63838kcqaz5xsuh1yo	1771232697538	1771232697712	0	github		\N		github@localhost	f		GitHub		system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1771232697538	1771232697712	0	en	f			{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}	\N	0	null
gk3t4rqfq3fh7fim776puakuee	1771232699000	1771232699000	0	system-bot		\N		system-bot@localhost	f		System		system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1771232699000	0	0	en	f			{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}	\N	0	null
39bi4ca55jnazg885s3rj9j1ka	1771233027677	1771233027700	0	feedbackbot		\N		feedbackbot@localhost	f		Feedbackbot		system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1771233027677	1771233027700	0	en	f			{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}	\N	0	null
4num934yzfb9udo1zdwxwd7gjc	1771232682659	1771232847294	0	admin	$pbkdf2$f=SHA256,w=600000,l=32$hfkFPpUlqLiieGjaRqzTng$S/+mBmbIFKJBgSiUt8sG4WZIzlhv2Q3kD0cyT4DqTjQ	\N		steeve.pytel@gmail.com	f				system_admin system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1771232682659	0	0	en	f			{"manualTimezone": "", "automaticTimezone": "Europe/Paris", "useAutomaticTimezone": "true"}		1771232847293	[]
fne5rqz9u3fzfdmdxna1tfw5ro	1771232696079	1771233026717	0	servicenow		\N		servicenow@localhost	f		ServiceNow		system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1771232696079	1771233026717	0	en	f			{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}	\N	0	null
qw9175rnt7yyjbtwczmx1y3z5y	1769687704459	1771233028990	0	calls		\N		calls@localhost	f		Calls		system_user	f	{}	{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}	1769687704459	1771233028990	0	en	f			{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}	\N	0	null
\.


--
-- Data for Name: usertermsofservice; Type: TABLE DATA; Schema: public; Owner: mmuser
--

COPY public.usertermsofservice (userid, termsofserviceid, createat) FROM stdin;
\.


--
-- Name: accesscontrolpolicies accesscontrolpolicies_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.accesscontrolpolicies
    ADD CONSTRAINT accesscontrolpolicies_pkey PRIMARY KEY (id);


--
-- Name: accesscontrolpolicyhistory accesscontrolpolicyhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.accesscontrolpolicyhistory
    ADD CONSTRAINT accesscontrolpolicyhistory_pkey PRIMARY KEY (id, revision);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: bots bots_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_pkey PRIMARY KEY (userid);


--
-- Name: calls_channels calls_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.calls_channels
    ADD CONSTRAINT calls_channels_pkey PRIMARY KEY (channelid);


--
-- Name: calls_jobs calls_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.calls_jobs
    ADD CONSTRAINT calls_jobs_pkey PRIMARY KEY (id);


--
-- Name: calls calls_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.calls
    ADD CONSTRAINT calls_pkey PRIMARY KEY (id);


--
-- Name: calls_sessions calls_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.calls_sessions
    ADD CONSTRAINT calls_sessions_pkey PRIMARY KEY (id);


--
-- Name: channelbookmarks channelbookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.channelbookmarks
    ADD CONSTRAINT channelbookmarks_pkey PRIMARY KEY (id);


--
-- Name: channelmemberhistory channelmemberhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.channelmemberhistory
    ADD CONSTRAINT channelmemberhistory_pkey PRIMARY KEY (channelid, userid, jointime);


--
-- Name: channelmembers channelmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.channelmembers
    ADD CONSTRAINT channelmembers_pkey PRIMARY KEY (channelid, userid);


--
-- Name: channels channels_name_teamid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_name_teamid_key UNIQUE (name, teamid);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: clusterdiscovery clusterdiscovery_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.clusterdiscovery
    ADD CONSTRAINT clusterdiscovery_pkey PRIMARY KEY (id);


--
-- Name: commands commands_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.commands
    ADD CONSTRAINT commands_pkey PRIMARY KEY (id);


--
-- Name: commandwebhooks commandwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.commandwebhooks
    ADD CONSTRAINT commandwebhooks_pkey PRIMARY KEY (id);


--
-- Name: compliances compliances_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.compliances
    ADD CONSTRAINT compliances_pkey PRIMARY KEY (id);


--
-- Name: contentflaggingcommonreviewers contentflaggingcommonreviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.contentflaggingcommonreviewers
    ADD CONSTRAINT contentflaggingcommonreviewers_pkey PRIMARY KEY (userid);


--
-- Name: contentflaggingteamreviewers contentflaggingteamreviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.contentflaggingteamreviewers
    ADD CONSTRAINT contentflaggingteamreviewers_pkey PRIMARY KEY (teamid, userid);


--
-- Name: contentflaggingteamsettings contentflaggingteamsettings_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.contentflaggingteamsettings
    ADD CONSTRAINT contentflaggingteamsettings_pkey PRIMARY KEY (teamid);


--
-- Name: db_lock db_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.db_lock
    ADD CONSTRAINT db_lock_pkey PRIMARY KEY (id);


--
-- Name: db_migrations_calls db_migrations_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.db_migrations_calls
    ADD CONSTRAINT db_migrations_calls_pkey PRIMARY KEY (version);


--
-- Name: db_migrations db_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.db_migrations
    ADD CONSTRAINT db_migrations_pkey PRIMARY KEY (version);


--
-- Name: desktoptokens desktoptokens_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.desktoptokens
    ADD CONSTRAINT desktoptokens_pkey PRIMARY KEY (token);


--
-- Name: drafts drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_pkey PRIMARY KEY (userid, channelid, rootid);


--
-- Name: emoji emoji_name_deleteat_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.emoji
    ADD CONSTRAINT emoji_name_deleteat_key UNIQUE (name, deleteat);


--
-- Name: emoji emoji_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.emoji
    ADD CONSTRAINT emoji_pkey PRIMARY KEY (id);


--
-- Name: fileinfo fileinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.fileinfo
    ADD CONSTRAINT fileinfo_pkey PRIMARY KEY (id);


--
-- Name: groupchannels groupchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.groupchannels
    ADD CONSTRAINT groupchannels_pkey PRIMARY KEY (groupid, channelid);


--
-- Name: groupmembers groupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.groupmembers
    ADD CONSTRAINT groupmembers_pkey PRIMARY KEY (groupid, userid);


--
-- Name: groupteams groupteams_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.groupteams
    ADD CONSTRAINT groupteams_pkey PRIMARY KEY (groupid, teamid);


--
-- Name: incomingwebhooks incomingwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.incomingwebhooks
    ADD CONSTRAINT incomingwebhooks_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: linkmetadata linkmetadata_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.linkmetadata
    ADD CONSTRAINT linkmetadata_pkey PRIMARY KEY (hash);


--
-- Name: llm_postmeta llm_postmeta_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.llm_postmeta
    ADD CONSTRAINT llm_postmeta_pkey PRIMARY KEY (rootpostid);


--
-- Name: notifyadmin notifyadmin_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.notifyadmin
    ADD CONSTRAINT notifyadmin_pkey PRIMARY KEY (userid, requiredfeature, requiredplan);


--
-- Name: oauthaccessdata oauthaccessdata_clientid_userid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.oauthaccessdata
    ADD CONSTRAINT oauthaccessdata_clientid_userid_key UNIQUE (clientid, userid);


--
-- Name: oauthaccessdata oauthaccessdata_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.oauthaccessdata
    ADD CONSTRAINT oauthaccessdata_pkey PRIMARY KEY (token);


--
-- Name: oauthapps oauthapps_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.oauthapps
    ADD CONSTRAINT oauthapps_pkey PRIMARY KEY (id);


--
-- Name: oauthauthdata oauthauthdata_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.oauthauthdata
    ADD CONSTRAINT oauthauthdata_pkey PRIMARY KEY (code);


--
-- Name: outgoingoauthconnections outgoingoauthconnections_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.outgoingoauthconnections
    ADD CONSTRAINT outgoingoauthconnections_pkey PRIMARY KEY (id);


--
-- Name: outgoingwebhooks outgoingwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.outgoingwebhooks
    ADD CONSTRAINT outgoingwebhooks_pkey PRIMARY KEY (id);


--
-- Name: persistentnotifications persistentnotifications_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.persistentnotifications
    ADD CONSTRAINT persistentnotifications_pkey PRIMARY KEY (postid);


--
-- Name: pluginkeyvaluestore pluginkeyvaluestore_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.pluginkeyvaluestore
    ADD CONSTRAINT pluginkeyvaluestore_pkey PRIMARY KEY (pluginid, pkey);


--
-- Name: postacknowledgements postacknowledgements_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.postacknowledgements
    ADD CONSTRAINT postacknowledgements_pkey PRIMARY KEY (postid, userid);


--
-- Name: postreminders postreminders_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.postreminders
    ADD CONSTRAINT postreminders_pkey PRIMARY KEY (postid, userid);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: postspriority postspriority_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.postspriority
    ADD CONSTRAINT postspriority_pkey PRIMARY KEY (postid);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (userid, category, name);


--
-- Name: productnoticeviewstate productnoticeviewstate_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.productnoticeviewstate
    ADD CONSTRAINT productnoticeviewstate_pkey PRIMARY KEY (userid, noticeid);


--
-- Name: propertyfields propertyfields_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.propertyfields
    ADD CONSTRAINT propertyfields_pkey PRIMARY KEY (id);


--
-- Name: propertygroups propertygroups_name_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.propertygroups
    ADD CONSTRAINT propertygroups_name_key UNIQUE (name);


--
-- Name: propertygroups propertygroups_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.propertygroups
    ADD CONSTRAINT propertygroups_pkey PRIMARY KEY (id);


--
-- Name: propertyvalues propertyvalues_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.propertyvalues
    ADD CONSTRAINT propertyvalues_pkey PRIMARY KEY (id);


--
-- Name: publicchannels publicchannels_name_teamid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.publicchannels
    ADD CONSTRAINT publicchannels_name_teamid_key UNIQUE (name, teamid);


--
-- Name: publicchannels publicchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.publicchannels
    ADD CONSTRAINT publicchannels_pkey PRIMARY KEY (id);


--
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (postid, userid, emojiname);


--
-- Name: recentsearches recentsearches_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.recentsearches
    ADD CONSTRAINT recentsearches_pkey PRIMARY KEY (userid, searchpointer);


--
-- Name: remoteclusters remoteclusters_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.remoteclusters
    ADD CONSTRAINT remoteclusters_pkey PRIMARY KEY (remoteid, name);


--
-- Name: retentionidsfordeletion retentionidsfordeletion_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.retentionidsfordeletion
    ADD CONSTRAINT retentionidsfordeletion_pkey PRIMARY KEY (id);


--
-- Name: retentionpolicies retentionpolicies_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.retentionpolicies
    ADD CONSTRAINT retentionpolicies_pkey PRIMARY KEY (id);


--
-- Name: retentionpolicieschannels retentionpolicieschannels_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.retentionpolicieschannels
    ADD CONSTRAINT retentionpolicieschannels_pkey PRIMARY KEY (channelid);


--
-- Name: retentionpoliciesteams retentionpoliciesteams_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.retentionpoliciesteams
    ADD CONSTRAINT retentionpoliciesteams_pkey PRIMARY KEY (teamid);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scheduledposts scheduledposts_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.scheduledposts
    ADD CONSTRAINT scheduledposts_pkey PRIMARY KEY (id);


--
-- Name: schemes schemes_name_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_name_key UNIQUE (name);


--
-- Name: schemes schemes_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sharedchannelattachments sharedchannelattachments_fileid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannelattachments
    ADD CONSTRAINT sharedchannelattachments_fileid_remoteid_key UNIQUE (fileid, remoteid);


--
-- Name: sharedchannelattachments sharedchannelattachments_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannelattachments
    ADD CONSTRAINT sharedchannelattachments_pkey PRIMARY KEY (id);


--
-- Name: sharedchannelremotes sharedchannelremotes_channelid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannelremotes
    ADD CONSTRAINT sharedchannelremotes_channelid_remoteid_key UNIQUE (channelid, remoteid);


--
-- Name: sharedchannelremotes sharedchannelremotes_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannelremotes
    ADD CONSTRAINT sharedchannelremotes_pkey PRIMARY KEY (id, channelid);


--
-- Name: sharedchannels sharedchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannels
    ADD CONSTRAINT sharedchannels_pkey PRIMARY KEY (channelid);


--
-- Name: sharedchannels sharedchannels_sharename_teamid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannels
    ADD CONSTRAINT sharedchannels_sharename_teamid_key UNIQUE (sharename, teamid);


--
-- Name: sharedchannelusers sharedchannelusers_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannelusers
    ADD CONSTRAINT sharedchannelusers_pkey PRIMARY KEY (id);


--
-- Name: sharedchannelusers sharedchannelusers_userid_channelid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sharedchannelusers
    ADD CONSTRAINT sharedchannelusers_userid_channelid_remoteid_key UNIQUE (userid, channelid, remoteid);


--
-- Name: sidebarcategories sidebarcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sidebarcategories
    ADD CONSTRAINT sidebarcategories_pkey PRIMARY KEY (id);


--
-- Name: sidebarchannels sidebarchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.sidebarchannels
    ADD CONSTRAINT sidebarchannels_pkey PRIMARY KEY (channelid, userid, categoryid);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (userid);


--
-- Name: systems systems_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.systems
    ADD CONSTRAINT systems_pkey PRIMARY KEY (name);


--
-- Name: teammembers teammembers_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.teammembers
    ADD CONSTRAINT teammembers_pkey PRIMARY KEY (teamid, userid);


--
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: termsofservice termsofservice_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.termsofservice
    ADD CONSTRAINT termsofservice_pkey PRIMARY KEY (id);


--
-- Name: threadmemberships threadmemberships_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.threadmemberships
    ADD CONSTRAINT threadmemberships_pkey PRIMARY KEY (postid, userid);


--
-- Name: threads threads_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (postid);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token);


--
-- Name: uploadsessions uploadsessions_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.uploadsessions
    ADD CONSTRAINT uploadsessions_pkey PRIMARY KEY (id);


--
-- Name: useraccesstokens useraccesstokens_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.useraccesstokens
    ADD CONSTRAINT useraccesstokens_pkey PRIMARY KEY (id);


--
-- Name: useraccesstokens useraccesstokens_token_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.useraccesstokens
    ADD CONSTRAINT useraccesstokens_token_key UNIQUE (token);


--
-- Name: usergroups usergroups_name_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_name_key UNIQUE (name);


--
-- Name: usergroups usergroups_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_pkey PRIMARY KEY (id);


--
-- Name: usergroups usergroups_source_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_source_remoteid_key UNIQUE (source, remoteid);


--
-- Name: users users_authdata_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_authdata_key UNIQUE (authdata);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: usertermsofservice usertermsofservice_pkey; Type: CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.usertermsofservice
    ADD CONSTRAINT usertermsofservice_pkey PRIMARY KEY (userid);


--
-- Name: idx_audits_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_audits_user_id ON public.audits USING btree (userid);


--
-- Name: idx_calls_channel_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_calls_channel_id ON public.calls USING btree (channelid);


--
-- Name: idx_calls_end_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_calls_end_at ON public.calls USING btree (endat);


--
-- Name: idx_calls_jobs_call_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_calls_jobs_call_id ON public.calls_jobs USING btree (callid);


--
-- Name: idx_calls_sessions_call_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_calls_sessions_call_id ON public.calls_sessions USING btree (callid);


--
-- Name: idx_channel_search_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channel_search_txt ON public.channels USING gin (to_tsvector('english'::regconfig, (((((name)::text || ' '::text) || (displayname)::text) || ' '::text) || (purpose)::text)));


--
-- Name: idx_channelbookmarks_channelid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channelbookmarks_channelid ON public.channelbookmarks USING btree (channelid);


--
-- Name: idx_channelbookmarks_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channelbookmarks_delete_at ON public.channelbookmarks USING btree (deleteat);


--
-- Name: idx_channelbookmarks_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channelbookmarks_update_at ON public.channelbookmarks USING btree (updateat);


--
-- Name: idx_channelmembers_channel_id_scheme_guest_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channelmembers_channel_id_scheme_guest_user_id ON public.channelmembers USING btree (channelid, schemeguest, userid);


--
-- Name: idx_channelmembers_user_id_channel_id_last_viewed_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channelmembers_user_id_channel_id_last_viewed_at ON public.channelmembers USING btree (userid, channelid, lastviewedat);


--
-- Name: idx_channels_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_create_at ON public.channels USING btree (createat);


--
-- Name: idx_channels_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_delete_at ON public.channels USING btree (deleteat);


--
-- Name: idx_channels_displayname_lower; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_displayname_lower ON public.channels USING btree (lower((displayname)::text));


--
-- Name: idx_channels_name_lower; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_name_lower ON public.channels USING btree (lower((name)::text));


--
-- Name: idx_channels_scheme_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_scheme_id ON public.channels USING btree (schemeid);


--
-- Name: idx_channels_team_id_display_name; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_team_id_display_name ON public.channels USING btree (teamid, displayname);


--
-- Name: idx_channels_team_id_type; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_team_id_type ON public.channels USING btree (teamid, type);


--
-- Name: idx_channels_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_channels_update_at ON public.channels USING btree (updateat);


--
-- Name: idx_command_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_command_create_at ON public.commands USING btree (createat);


--
-- Name: idx_command_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_command_delete_at ON public.commands USING btree (deleteat);


--
-- Name: idx_command_team_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_command_team_id ON public.commands USING btree (teamid);


--
-- Name: idx_command_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_command_update_at ON public.commands USING btree (updateat);


--
-- Name: idx_command_webhook_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_command_webhook_create_at ON public.commandwebhooks USING btree (createat);


--
-- Name: idx_contentflaggingteamreviewers_userid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_contentflaggingteamreviewers_userid ON public.contentflaggingteamreviewers USING btree (userid);


--
-- Name: idx_desktoptokens_token_createat; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_desktoptokens_token_createat ON public.desktoptokens USING btree (token, createat);


--
-- Name: idx_emoji_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_emoji_create_at ON public.emoji USING btree (createat);


--
-- Name: idx_emoji_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_emoji_delete_at ON public.emoji USING btree (deleteat);


--
-- Name: idx_emoji_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_emoji_update_at ON public.emoji USING btree (updateat);


--
-- Name: idx_fileinfo_channel_id_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_channel_id_create_at ON public.fileinfo USING btree (channelid, createat);


--
-- Name: idx_fileinfo_content_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_content_txt ON public.fileinfo USING gin (to_tsvector('english'::regconfig, content));


--
-- Name: idx_fileinfo_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_create_at ON public.fileinfo USING btree (createat);


--
-- Name: idx_fileinfo_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_delete_at ON public.fileinfo USING btree (deleteat);


--
-- Name: idx_fileinfo_extension_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_extension_at ON public.fileinfo USING btree (extension);


--
-- Name: idx_fileinfo_name_splitted; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_name_splitted ON public.fileinfo USING gin (to_tsvector('english'::regconfig, translate((name)::text, '.,-'::text, '   '::text)));


--
-- Name: idx_fileinfo_name_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_name_txt ON public.fileinfo USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: idx_fileinfo_postid_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_postid_at ON public.fileinfo USING btree (postid);


--
-- Name: idx_fileinfo_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_fileinfo_update_at ON public.fileinfo USING btree (updateat);


--
-- Name: idx_groupchannels_channelid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_groupchannels_channelid ON public.groupchannels USING btree (channelid);


--
-- Name: idx_groupchannels_schemeadmin; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_groupchannels_schemeadmin ON public.groupchannels USING btree (schemeadmin);


--
-- Name: idx_groupmembers_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_groupmembers_create_at ON public.groupmembers USING btree (createat);


--
-- Name: idx_groupteams_schemeadmin; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_groupteams_schemeadmin ON public.groupteams USING btree (schemeadmin);


--
-- Name: idx_groupteams_teamid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_groupteams_teamid ON public.groupteams USING btree (teamid);


--
-- Name: idx_incoming_webhook_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_incoming_webhook_create_at ON public.incomingwebhooks USING btree (createat);


--
-- Name: idx_incoming_webhook_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_incoming_webhook_delete_at ON public.incomingwebhooks USING btree (deleteat);


--
-- Name: idx_incoming_webhook_team_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_incoming_webhook_team_id ON public.incomingwebhooks USING btree (teamid);


--
-- Name: idx_incoming_webhook_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_incoming_webhook_update_at ON public.incomingwebhooks USING btree (updateat);


--
-- Name: idx_incoming_webhook_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_incoming_webhook_user_id ON public.incomingwebhooks USING btree (userid);


--
-- Name: idx_jobs_status_type; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_jobs_status_type ON public.jobs USING btree (status, type);


--
-- Name: idx_jobs_type; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_jobs_type ON public.jobs USING btree (type);


--
-- Name: idx_link_metadata_url_timestamp; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_link_metadata_url_timestamp ON public.linkmetadata USING btree (url, "timestamp");


--
-- Name: idx_notice_views_notice_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_notice_views_notice_id ON public.productnoticeviewstate USING btree (noticeid);


--
-- Name: idx_notice_views_timestamp; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_notice_views_timestamp ON public.productnoticeviewstate USING btree ("timestamp");


--
-- Name: idx_oauthaccessdata_refresh_token; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_oauthaccessdata_refresh_token ON public.oauthaccessdata USING btree (refreshtoken);


--
-- Name: idx_oauthaccessdata_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_oauthaccessdata_user_id ON public.oauthaccessdata USING btree (userid);


--
-- Name: idx_oauthapps_creator_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_oauthapps_creator_id ON public.oauthapps USING btree (creatorid);


--
-- Name: idx_outgoing_webhook_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_outgoing_webhook_create_at ON public.outgoingwebhooks USING btree (createat);


--
-- Name: idx_outgoing_webhook_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_outgoing_webhook_delete_at ON public.outgoingwebhooks USING btree (deleteat);


--
-- Name: idx_outgoing_webhook_team_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_outgoing_webhook_team_id ON public.outgoingwebhooks USING btree (teamid);


--
-- Name: idx_outgoing_webhook_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_outgoing_webhook_update_at ON public.outgoingwebhooks USING btree (updateat);


--
-- Name: idx_outgoingoauthconnections_name; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_outgoingoauthconnections_name ON public.outgoingoauthconnections USING btree (name);


--
-- Name: idx_postreminders_targettime; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_postreminders_targettime ON public.postreminders USING btree (targettime);


--
-- Name: idx_posts_channel_id_delete_at_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_channel_id_delete_at_create_at ON public.posts USING btree (channelid, deleteat, createat);


--
-- Name: idx_posts_channel_id_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_channel_id_update_at ON public.posts USING btree (channelid, updateat);


--
-- Name: idx_posts_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_create_at ON public.posts USING btree (createat);


--
-- Name: idx_posts_create_at_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_create_at_id ON public.posts USING btree (createat, id);


--
-- Name: idx_posts_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_delete_at ON public.posts USING btree (deleteat);


--
-- Name: idx_posts_hashtags_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_hashtags_txt ON public.posts USING gin (to_tsvector('english'::regconfig, (hashtags)::text));


--
-- Name: idx_posts_is_pinned; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_is_pinned ON public.posts USING btree (ispinned);


--
-- Name: idx_posts_message_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_message_txt ON public.posts USING gin (to_tsvector('english'::regconfig, (message)::text));


--
-- Name: idx_posts_original_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_original_id ON public.posts USING btree (originalid);


--
-- Name: idx_posts_root_id_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_root_id_delete_at ON public.posts USING btree (rootid, deleteat);


--
-- Name: idx_posts_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_update_at ON public.posts USING btree (updateat);


--
-- Name: idx_posts_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_posts_user_id ON public.posts USING btree (userid);


--
-- Name: idx_poststats_userid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_poststats_userid ON public.poststats USING btree (userid);


--
-- Name: idx_preferences_category; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_preferences_category ON public.preferences USING btree (category);


--
-- Name: idx_preferences_name; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_preferences_name ON public.preferences USING btree (name);


--
-- Name: idx_propertyfields_create_at_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_propertyfields_create_at_id ON public.propertyfields USING btree (createat, id);


--
-- Name: idx_propertyfields_unique; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE UNIQUE INDEX idx_propertyfields_unique ON public.propertyfields USING btree (groupid, targetid, name) WHERE (deleteat = 0);


--
-- Name: idx_propertyvalues_create_at_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_propertyvalues_create_at_id ON public.propertyvalues USING btree (createat, id);


--
-- Name: idx_propertyvalues_targetid_groupid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_propertyvalues_targetid_groupid ON public.propertyvalues USING btree (targetid, groupid);


--
-- Name: idx_propertyvalues_unique; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE UNIQUE INDEX idx_propertyvalues_unique ON public.propertyvalues USING btree (groupid, targetid, fieldid) WHERE (deleteat = 0);


--
-- Name: idx_publicchannels_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_publicchannels_delete_at ON public.publicchannels USING btree (deleteat);


--
-- Name: idx_publicchannels_displayname_lower; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_publicchannels_displayname_lower ON public.publicchannels USING btree (lower((displayname)::text));


--
-- Name: idx_publicchannels_name_lower; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_publicchannels_name_lower ON public.publicchannels USING btree (lower((name)::text));


--
-- Name: idx_publicchannels_search_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_publicchannels_search_txt ON public.publicchannels USING gin (to_tsvector('english'::regconfig, (((((name)::text || ' '::text) || (displayname)::text) || ' '::text) || (purpose)::text)));


--
-- Name: idx_publicchannels_team_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_publicchannels_team_id ON public.publicchannels USING btree (teamid);


--
-- Name: idx_reactions_channel_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_reactions_channel_id ON public.reactions USING btree (channelid);


--
-- Name: idx_retentionidsfordeletion_tablename; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_retentionidsfordeletion_tablename ON public.retentionidsfordeletion USING btree (tablename);


--
-- Name: idx_retentionpolicies_displayname; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_retentionpolicies_displayname ON public.retentionpolicies USING btree (displayname);


--
-- Name: idx_retentionpolicieschannels_policyid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_retentionpolicieschannels_policyid ON public.retentionpolicieschannels USING btree (policyid);


--
-- Name: idx_retentionpoliciesteams_policyid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_retentionpoliciesteams_policyid ON public.retentionpoliciesteams USING btree (policyid);


--
-- Name: idx_scheduledposts_userid_channel_id_scheduled_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_scheduledposts_userid_channel_id_scheduled_at ON public.scheduledposts USING btree (userid, channelid, scheduledat);


--
-- Name: idx_schemes_channel_admin_role; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_schemes_channel_admin_role ON public.schemes USING btree (defaultchanneladminrole);


--
-- Name: idx_schemes_channel_guest_role; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_schemes_channel_guest_role ON public.schemes USING btree (defaultchannelguestrole);


--
-- Name: idx_schemes_channel_user_role; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_schemes_channel_user_role ON public.schemes USING btree (defaultchanneluserrole);


--
-- Name: idx_sessions_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sessions_create_at ON public.sessions USING btree (createat);


--
-- Name: idx_sessions_expires_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sessions_expires_at ON public.sessions USING btree (expiresat);


--
-- Name: idx_sessions_last_activity_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sessions_last_activity_at ON public.sessions USING btree (lastactivityat);


--
-- Name: idx_sessions_token; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sessions_token ON public.sessions USING btree (token);


--
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (userid);


--
-- Name: idx_sharedchannelusers_remote_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sharedchannelusers_remote_id ON public.sharedchannelusers USING btree (remoteid);


--
-- Name: idx_sidebarcategories_userid_teamid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sidebarcategories_userid_teamid ON public.sidebarcategories USING btree (userid, teamid);


--
-- Name: idx_sidebarchannels_categoryid; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_sidebarchannels_categoryid ON public.sidebarchannels USING btree (categoryid);


--
-- Name: idx_status_status_dndendtime; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_status_status_dndendtime ON public.status USING btree (status, dndendtime);


--
-- Name: idx_teammembers_createat; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teammembers_createat ON public.teammembers USING btree (createat);


--
-- Name: idx_teammembers_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teammembers_delete_at ON public.teammembers USING btree (deleteat);


--
-- Name: idx_teammembers_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teammembers_user_id ON public.teammembers USING btree (userid);


--
-- Name: idx_teams_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teams_create_at ON public.teams USING btree (createat);


--
-- Name: idx_teams_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teams_delete_at ON public.teams USING btree (deleteat);


--
-- Name: idx_teams_invite_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teams_invite_id ON public.teams USING btree (inviteid);


--
-- Name: idx_teams_scheme_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teams_scheme_id ON public.teams USING btree (schemeid);


--
-- Name: idx_teams_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_teams_update_at ON public.teams USING btree (updateat);


--
-- Name: idx_thread_memberships_last_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_thread_memberships_last_update_at ON public.threadmemberships USING btree (lastupdated);


--
-- Name: idx_thread_memberships_last_view_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_thread_memberships_last_view_at ON public.threadmemberships USING btree (lastviewed);


--
-- Name: idx_thread_memberships_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_thread_memberships_user_id ON public.threadmemberships USING btree (userid);


--
-- Name: idx_threads_channel_id_last_reply_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_threads_channel_id_last_reply_at ON public.threads USING btree (channelid, lastreplyat);


--
-- Name: idx_uploadsessions_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_uploadsessions_create_at ON public.uploadsessions USING btree (createat);


--
-- Name: idx_uploadsessions_type; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_uploadsessions_type ON public.uploadsessions USING btree (type);


--
-- Name: idx_uploadsessions_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_uploadsessions_user_id ON public.uploadsessions USING btree (userid);


--
-- Name: idx_user_access_tokens_user_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_user_access_tokens_user_id ON public.useraccesstokens USING btree (userid);


--
-- Name: idx_usergroups_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_usergroups_delete_at ON public.usergroups USING btree (deleteat);


--
-- Name: idx_usergroups_displayname; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_usergroups_displayname ON public.usergroups USING btree (displayname);


--
-- Name: idx_usergroups_remote_id; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_usergroups_remote_id ON public.usergroups USING btree (remoteid);


--
-- Name: idx_users_all_no_full_name_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_all_no_full_name_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((username)::text || ' '::text) || (nickname)::text) || ' '::text) || (email)::text)));


--
-- Name: idx_users_all_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_all_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((((((username)::text || ' '::text) || (firstname)::text) || ' '::text) || (lastname)::text) || ' '::text) || (nickname)::text) || ' '::text) || (email)::text)));


--
-- Name: idx_users_create_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_create_at ON public.users USING btree (createat);


--
-- Name: idx_users_delete_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_delete_at ON public.users USING btree (deleteat);


--
-- Name: idx_users_email_lower_textpattern; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_email_lower_textpattern ON public.users USING btree (lower((email)::text) text_pattern_ops);


--
-- Name: idx_users_firstname_lower_textpattern; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_firstname_lower_textpattern ON public.users USING btree (lower((firstname)::text) text_pattern_ops);


--
-- Name: idx_users_lastname_lower_textpattern; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_lastname_lower_textpattern ON public.users USING btree (lower((lastname)::text) text_pattern_ops);


--
-- Name: idx_users_names_no_full_name_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_names_no_full_name_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((username)::text || ' '::text) || (nickname)::text)));


--
-- Name: idx_users_names_txt; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_names_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((((username)::text || ' '::text) || (firstname)::text) || ' '::text) || (lastname)::text) || ' '::text) || (nickname)::text)));


--
-- Name: idx_users_nickname_lower_textpattern; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_nickname_lower_textpattern ON public.users USING btree (lower((nickname)::text) text_pattern_ops);


--
-- Name: idx_users_update_at; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_update_at ON public.users USING btree (updateat);


--
-- Name: idx_users_username_lower_textpattern; Type: INDEX; Schema: public; Owner: mmuser
--

CREATE INDEX idx_users_username_lower_textpattern ON public.users USING btree (lower((username)::text) text_pattern_ops);


--
-- Name: retentionpolicieschannels fk_retentionpolicieschannels_retentionpolicies; Type: FK CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.retentionpolicieschannels
    ADD CONSTRAINT fk_retentionpolicieschannels_retentionpolicies FOREIGN KEY (policyid) REFERENCES public.retentionpolicies(id) ON DELETE CASCADE;


--
-- Name: retentionpoliciesteams fk_retentionpoliciesteams_retentionpolicies; Type: FK CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.retentionpoliciesteams
    ADD CONSTRAINT fk_retentionpoliciesteams_retentionpolicies FOREIGN KEY (policyid) REFERENCES public.retentionpolicies(id) ON DELETE CASCADE;


--
-- Name: llm_postmeta llm_postmeta_rootpostid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mmuser
--

ALTER TABLE ONLY public.llm_postmeta
    ADD CONSTRAINT llm_postmeta_rootpostid_fkey FOREIGN KEY (rootpostid) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: attributeview; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: mmuser
--

REFRESH MATERIALIZED VIEW public.attributeview;


--
-- Name: bot_posts_by_team_day; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: mmuser
--

REFRESH MATERIALIZED VIEW public.bot_posts_by_team_day;


--
-- Name: file_stats; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: mmuser
--

REFRESH MATERIALIZED VIEW public.file_stats;


--
-- Name: posts_by_team_day; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: mmuser
--

REFRESH MATERIALIZED VIEW public.posts_by_team_day;


--
-- Name: poststats; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: mmuser
--

REFRESH MATERIALIZED VIEW public.poststats;


--
-- PostgreSQL database dump complete
--

\unrestrict XtJlgehMjOeoL7eWs46XWomRn8hyidw0kHpukZwiI9sK1h0jGShGzyEIFAbUlBL

