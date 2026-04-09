--
-- PostgreSQL database dump
--

\restrict 6v6zrPgoUgCZXhDE8kDogcWQeRBLtpjjabSWPY2zTe0qioPB2HL8VIMGTfl76t8

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: app_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO app_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: app_user
--

COMMENT ON SCHEMA public IS '';


--
-- Name: activitytype; Type: TYPE; Schema: public; Owner: app_user
--

CREATE TYPE public.activitytype AS ENUM (
    'SAE',
    'STAGE',
    'PROJET',
    'PORTFOLIO'
);


ALTER TYPE public.activitytype OWNER TO app_user;

--
-- Name: applicationstatus; Type: TYPE; Schema: public; Owner: app_user
--

CREATE TYPE public.applicationstatus AS ENUM (
    'APPLIED',
    'INTERVIEW',
    'REJECTED',
    'ACCEPTED'
);


ALTER TYPE public.applicationstatus OWNER TO app_user;

--
-- Name: feedbacktype; Type: TYPE; Schema: public; Owner: app_user
--

CREATE TYPE public.feedbacktype AS ENUM (
    'BUG',
    'IDEA',
    'REQUEST'
);


ALTER TYPE public.feedbacktype OWNER TO app_user;

--
-- Name: responsibilityentitytype; Type: TYPE; Schema: public; Owner: app_user
--

CREATE TYPE public.responsibilityentitytype AS ENUM (
    'RESOURCE',
    'ACTIVITY',
    'STUDENT'
);


ALTER TYPE public.responsibilityentitytype OWNER TO app_user;

--
-- Name: responsibilitytype; Type: TYPE; Schema: public; Owner: app_user
--

CREATE TYPE public.responsibilitytype AS ENUM (
    'OWNER',
    'INTERVENANT',
    'TUTOR'
);


ALTER TYPE public.responsibilitytype OWNER TO app_user;

--
-- Name: userrole; Type: TYPE; Schema: public; Owner: app_user
--

CREATE TYPE public.userrole AS ENUM (
    'SUPER_ADMIN',
    'ADMIN',
    'PROF_RESP_PARCOURS',
    'PROF_RESP_SAE',
    'PROFESSOR',
    'STUDENT',
    'GUEST',
    'DEPT_HEAD',
    'ADMIN_STAFF',
    'STUDY_DIRECTOR'
);


ALTER TYPE public.userrole OWNER TO app_user;

--
-- Name: visittype; Type: TYPE; Schema: public; Owner: app_user
--

CREATE TYPE public.visittype AS ENUM (
    'SITE',
    'PHONE',
    'VISIO'
);


ALTER TYPE public.visittype OWNER TO app_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.activity (
    id integer NOT NULL,
    code character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    type public.activitytype NOT NULL,
    level integer NOT NULL,
    semester integer NOT NULL,
    pathway character varying NOT NULL,
    resources character varying,
    responsible character varying,
    contributors character varying
);


ALTER TABLE public.activity OWNER TO app_user;

--
-- Name: activity_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.activity_id_seq OWNER TO app_user;

--
-- Name: activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.activity_id_seq OWNED BY public.activity.id;


--
-- Name: activityaclink; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.activityaclink (
    activity_id integer NOT NULL,
    ac_id integer NOT NULL
);


ALTER TABLE public.activityaclink OWNER TO app_user;

--
-- Name: activitycelink; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.activitycelink (
    activity_id integer NOT NULL,
    ce_id integer NOT NULL
);


ALTER TABLE public.activitycelink OWNER TO app_user;

--
-- Name: activitygroup; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.activitygroup (
    id integer NOT NULL,
    name character varying NOT NULL,
    activity_id integer NOT NULL,
    academic_year character varying NOT NULL
);


ALTER TABLE public.activitygroup OWNER TO app_user;

--
-- Name: activitygroup_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.activitygroup_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.activitygroup_id_seq OWNER TO app_user;

--
-- Name: activitygroup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.activitygroup_id_seq OWNED BY public.activitygroup.id;


--
-- Name: activitygroupstudentlink; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.activitygroupstudentlink (
    group_id integer NOT NULL,
    student_uid character varying NOT NULL
);


ALTER TABLE public.activitygroupstudentlink OWNER TO app_user;

--
-- Name: company; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.company (
    id integer NOT NULL,
    name character varying NOT NULL,
    address character varying,
    phone character varying,
    email character varying,
    website character varying,
    latitude double precision,
    longitude double precision,
    accepts_interns boolean NOT NULL,
    visible_to_students boolean NOT NULL
);


ALTER TABLE public.company OWNER TO app_user;

--
-- Name: company_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.company_id_seq OWNER TO app_user;

--
-- Name: company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.company_id_seq OWNED BY public.company.id;


--
-- Name: competency; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.competency (
    id integer NOT NULL,
    code character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    situations_pro character varying,
    level integer NOT NULL,
    pathway character varying NOT NULL
);


ALTER TABLE public.competency OWNER TO app_user;

--
-- Name: competency_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.competency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.competency_id_seq OWNER TO app_user;

--
-- Name: competency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.competency_id_seq OWNED BY public.competency.id;


--
-- Name: essentialcomponent; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.essentialcomponent (
    id integer NOT NULL,
    code character varying NOT NULL,
    label character varying NOT NULL,
    level integer NOT NULL,
    pathway character varying NOT NULL,
    competency_id integer NOT NULL
);


ALTER TABLE public.essentialcomponent OWNER TO app_user;

--
-- Name: essentialcomponent_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.essentialcomponent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.essentialcomponent_id_seq OWNER TO app_user;

--
-- Name: essentialcomponent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.essentialcomponent_id_seq OWNED BY public.essentialcomponent.id;


--
-- Name: evaluationrubric; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.evaluationrubric (
    id integer NOT NULL,
    activity_id integer NOT NULL,
    name character varying NOT NULL,
    total_points double precision NOT NULL,
    academic_year character varying NOT NULL
);


ALTER TABLE public.evaluationrubric OWNER TO app_user;

--
-- Name: evaluationrubric_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.evaluationrubric_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.evaluationrubric_id_seq OWNER TO app_user;

--
-- Name: evaluationrubric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.evaluationrubric_id_seq OWNED BY public.evaluationrubric.id;


--
-- Name: group; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public."group" (
    id integer NOT NULL,
    name character varying NOT NULL,
    year integer NOT NULL,
    pathway character varying NOT NULL,
    formation_type character varying NOT NULL,
    academic_year character varying NOT NULL
);


ALTER TABLE public."group" OWNER TO app_user;

--
-- Name: group_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_id_seq OWNER TO app_user;

--
-- Name: group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.group_id_seq OWNED BY public."group".id;


--
-- Name: internship; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.internship (
    id integer NOT NULL,
    student_uid character varying NOT NULL,
    academic_year character varying NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    company_name character varying,
    company_address character varying,
    company_phone character varying,
    company_email character varying,
    supervisor_name character varying,
    supervisor_phone character varying,
    supervisor_email character varying,
    company_id integer,
    is_active boolean DEFAULT true,
    is_finalized boolean DEFAULT false,
    evaluation_token character varying,
    token_expires_at timestamp without time zone
);


ALTER TABLE public.internship OWNER TO app_user;

--
-- Name: internship_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.internship_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internship_id_seq OWNER TO app_user;

--
-- Name: internship_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.internship_id_seq OWNED BY public.internship.id;


--
-- Name: internshipapplication; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.internshipapplication (
    id integer NOT NULL,
    student_uid character varying NOT NULL,
    company_name character varying NOT NULL,
    position_title character varying NOT NULL,
    status public.applicationstatus NOT NULL,
    applied_at timestamp without time zone NOT NULL,
    interview_at timestamp without time zone,
    notes character varying,
    url character varying,
    sort_order integer NOT NULL
);


ALTER TABLE public.internshipapplication OWNER TO app_user;

--
-- Name: internshipapplication_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.internshipapplication_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internshipapplication_id_seq OWNER TO app_user;

--
-- Name: internshipapplication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.internshipapplication_id_seq OWNED BY public.internshipapplication.id;


--
-- Name: internshipevaluation; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.internshipevaluation (
    id integer NOT NULL,
    internship_id integer NOT NULL,
    evaluator_role character varying NOT NULL,
    criterion_id integer NOT NULL,
    score double precision NOT NULL,
    comment character varying,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.internshipevaluation OWNER TO app_user;

--
-- Name: internshipevaluation_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.internshipevaluation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internshipevaluation_id_seq OWNER TO app_user;

--
-- Name: internshipevaluation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.internshipevaluation_id_seq OWNED BY public.internshipevaluation.id;


--
-- Name: internshipvisit; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.internshipvisit (
    id integer NOT NULL,
    internship_id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    type public.visittype NOT NULL,
    report_content character varying
);


ALTER TABLE public.internshipvisit OWNER TO app_user;

--
-- Name: internshipvisit_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.internshipvisit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internshipvisit_id_seq OWNER TO app_user;

--
-- Name: internshipvisit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.internshipvisit_id_seq OWNED BY public.internshipvisit.id;


--
-- Name: learningoutcome; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.learningoutcome (
    id integer NOT NULL,
    code character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    level integer NOT NULL,
    pathway character varying NOT NULL,
    competency_id integer NOT NULL
);


ALTER TABLE public.learningoutcome OWNER TO app_user;

--
-- Name: learningoutcome_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.learningoutcome_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.learningoutcome_id_seq OWNER TO app_user;

--
-- Name: learningoutcome_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.learningoutcome_id_seq OWNED BY public.learningoutcome.id;


--
-- Name: portfolioexportconfig; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.portfolioexportconfig (
    id integer NOT NULL,
    student_uid character varying NOT NULL,
    preamble character varying,
    selected_pages character varying NOT NULL,
    include_internships boolean NOT NULL,
    include_sae boolean NOT NULL,
    include_radar boolean NOT NULL,
    theme_color character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.portfolioexportconfig OWNER TO app_user;

--
-- Name: portfolioexportconfig_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.portfolioexportconfig_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.portfolioexportconfig_id_seq OWNER TO app_user;

--
-- Name: portfolioexportconfig_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.portfolioexportconfig_id_seq OWNED BY public.portfolioexportconfig.id;


--
-- Name: portfoliopage; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.portfoliopage (
    id integer NOT NULL,
    student_uid character varying NOT NULL,
    title character varying NOT NULL,
    content_json character varying NOT NULL,
    linked_file_ids character varying,
    academic_year character varying NOT NULL,
    year_of_study integer NOT NULL,
    is_public boolean NOT NULL,
    share_token character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.portfoliopage OWNER TO app_user;

--
-- Name: portfoliopage_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.portfoliopage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.portfoliopage_id_seq OWNER TO app_user;

--
-- Name: portfoliopage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.portfoliopage_id_seq OWNED BY public.portfoliopage.id;


--
-- Name: promotionresponsibility; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.promotionresponsibility (
    id integer NOT NULL,
    teacher_uid character varying NOT NULL,
    group_id integer NOT NULL,
    academic_year character varying NOT NULL
);


ALTER TABLE public.promotionresponsibility OWNER TO app_user;

--
-- Name: promotionresponsibility_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.promotionresponsibility_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.promotionresponsibility_id_seq OWNER TO app_user;

--
-- Name: promotionresponsibility_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.promotionresponsibility_id_seq OWNED BY public.promotionresponsibility.id;


--
-- Name: resource; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.resource (
    id integer NOT NULL,
    code character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    content character varying,
    hours integer,
    hours_details character varying,
    targeted_competencies character varying,
    pathway character varying NOT NULL,
    responsible character varying,
    contributors character varying
);


ALTER TABLE public.resource OWNER TO app_user;

--
-- Name: resource_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.resource_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resource_id_seq OWNER TO app_user;

--
-- Name: resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.resource_id_seq OWNED BY public.resource.id;


--
-- Name: resourceaclink; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.resourceaclink (
    resource_id integer NOT NULL,
    ac_id integer NOT NULL
);


ALTER TABLE public.resourceaclink OWNER TO app_user;

--
-- Name: responsibilitymatrix; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.responsibilitymatrix (
    id integer NOT NULL,
    user_id character varying NOT NULL,
    entity_type public.responsibilityentitytype NOT NULL,
    entity_id character varying NOT NULL,
    role_type public.responsibilitytype NOT NULL,
    academic_year character varying NOT NULL
);


ALTER TABLE public.responsibilitymatrix OWNER TO app_user;

--
-- Name: responsibilitymatrix_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.responsibilitymatrix_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.responsibilitymatrix_id_seq OWNER TO app_user;

--
-- Name: responsibilitymatrix_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.responsibilitymatrix_id_seq OWNED BY public.responsibilitymatrix.id;


--
-- Name: rubriccriterion; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.rubriccriterion (
    id integer NOT NULL,
    rubric_id integer NOT NULL,
    ac_id integer,
    ce_id integer,
    label character varying NOT NULL,
    description character varying,
    weight double precision NOT NULL
);


ALTER TABLE public.rubriccriterion OWNER TO app_user;

--
-- Name: rubriccriterion_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.rubriccriterion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rubriccriterion_id_seq OWNER TO app_user;

--
-- Name: rubriccriterion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.rubriccriterion_id_seq OWNED BY public.rubriccriterion.id;


--
-- Name: studentfile; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.studentfile (
    id integer NOT NULL,
    student_uid character varying NOT NULL,
    filename character varying NOT NULL,
    nc_path character varying NOT NULL,
    entity_type public.responsibilityentitytype NOT NULL,
    entity_id character varying NOT NULL,
    is_locked boolean NOT NULL,
    uploaded_at timestamp without time zone NOT NULL
);


ALTER TABLE public.studentfile OWNER TO app_user;

--
-- Name: studentfile_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.studentfile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.studentfile_id_seq OWNER TO app_user;

--
-- Name: studentfile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.studentfile_id_seq OWNED BY public.studentfile.id;


--
-- Name: studentppp; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.studentppp (
    id integer NOT NULL,
    student_uid character varying NOT NULL,
    content_json character varying NOT NULL,
    career_goals character varying,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.studentppp OWNER TO app_user;

--
-- Name: studentppp_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.studentppp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.studentppp_id_seq OWNER TO app_user;

--
-- Name: studentppp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.studentppp_id_seq OWNED BY public.studentppp.id;


--
-- Name: systemconfig; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.systemconfig (
    id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL,
    category character varying NOT NULL
);


ALTER TABLE public.systemconfig OWNER TO app_user;

--
-- Name: systemconfig_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.systemconfig_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.systemconfig_id_seq OWNER TO app_user;

--
-- Name: systemconfig_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.systemconfig_id_seq OWNED BY public.systemconfig.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    ldap_uid character varying NOT NULL,
    email character varying NOT NULL,
    full_name character varying NOT NULL,
    role public.userrole NOT NULL,
    group_id integer,
    phone character varying
);


ALTER TABLE public."user" OWNER TO app_user;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO app_user;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: userfeedback; Type: TABLE; Schema: public; Owner: app_user
--

CREATE TABLE public.userfeedback (
    id integer NOT NULL,
    user_id character varying NOT NULL,
    user_name character varying NOT NULL,
    type public.feedbacktype NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    votes integer NOT NULL,
    voters character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    is_resolved boolean NOT NULL
);


ALTER TABLE public.userfeedback OWNER TO app_user;

--
-- Name: userfeedback_id_seq; Type: SEQUENCE; Schema: public; Owner: app_user
--

CREATE SEQUENCE public.userfeedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.userfeedback_id_seq OWNER TO app_user;

--
-- Name: userfeedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_user
--

ALTER SEQUENCE public.userfeedback_id_seq OWNED BY public.userfeedback.id;


--
-- Name: activity id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activity ALTER COLUMN id SET DEFAULT nextval('public.activity_id_seq'::regclass);


--
-- Name: activitygroup id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitygroup ALTER COLUMN id SET DEFAULT nextval('public.activitygroup_id_seq'::regclass);


--
-- Name: company id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.company ALTER COLUMN id SET DEFAULT nextval('public.company_id_seq'::regclass);


--
-- Name: competency id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.competency ALTER COLUMN id SET DEFAULT nextval('public.competency_id_seq'::regclass);


--
-- Name: essentialcomponent id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.essentialcomponent ALTER COLUMN id SET DEFAULT nextval('public.essentialcomponent_id_seq'::regclass);


--
-- Name: evaluationrubric id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.evaluationrubric ALTER COLUMN id SET DEFAULT nextval('public.evaluationrubric_id_seq'::regclass);


--
-- Name: group id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public."group" ALTER COLUMN id SET DEFAULT nextval('public.group_id_seq'::regclass);


--
-- Name: internship id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internship ALTER COLUMN id SET DEFAULT nextval('public.internship_id_seq'::regclass);


--
-- Name: internshipapplication id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipapplication ALTER COLUMN id SET DEFAULT nextval('public.internshipapplication_id_seq'::regclass);


--
-- Name: internshipevaluation id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipevaluation ALTER COLUMN id SET DEFAULT nextval('public.internshipevaluation_id_seq'::regclass);


--
-- Name: internshipvisit id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipvisit ALTER COLUMN id SET DEFAULT nextval('public.internshipvisit_id_seq'::regclass);


--
-- Name: learningoutcome id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.learningoutcome ALTER COLUMN id SET DEFAULT nextval('public.learningoutcome_id_seq'::regclass);


--
-- Name: portfolioexportconfig id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.portfolioexportconfig ALTER COLUMN id SET DEFAULT nextval('public.portfolioexportconfig_id_seq'::regclass);


--
-- Name: portfoliopage id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.portfoliopage ALTER COLUMN id SET DEFAULT nextval('public.portfoliopage_id_seq'::regclass);


--
-- Name: promotionresponsibility id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.promotionresponsibility ALTER COLUMN id SET DEFAULT nextval('public.promotionresponsibility_id_seq'::regclass);


--
-- Name: resource id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.resource ALTER COLUMN id SET DEFAULT nextval('public.resource_id_seq'::regclass);


--
-- Name: responsibilitymatrix id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.responsibilitymatrix ALTER COLUMN id SET DEFAULT nextval('public.responsibilitymatrix_id_seq'::regclass);


--
-- Name: rubriccriterion id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.rubriccriterion ALTER COLUMN id SET DEFAULT nextval('public.rubriccriterion_id_seq'::regclass);


--
-- Name: studentfile id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.studentfile ALTER COLUMN id SET DEFAULT nextval('public.studentfile_id_seq'::regclass);


--
-- Name: studentppp id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.studentppp ALTER COLUMN id SET DEFAULT nextval('public.studentppp_id_seq'::regclass);


--
-- Name: systemconfig id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.systemconfig ALTER COLUMN id SET DEFAULT nextval('public.systemconfig_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: userfeedback id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.userfeedback ALTER COLUMN id SET DEFAULT nextval('public.userfeedback_id_seq'::regclass);


--
-- Data for Name: activity; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.activity (id, code, label, description, type, level, semester, pathway, resources, responsible, contributors) FROM stdin;
1	SAE 1.01	Marketing : positionnement d'une offre simple sur un marché	Compétence ciblée :\n– Conduire les actions marketing\n\nObjectifs et problématique professionnelle :\nIdentifier les opportunités et les menaces dans l'environnement d'une organisation. Cet élément constitue le point d'étape préalable nécessaire à toute action sur un marché.\nLa problématique professionnelle consiste à analyser le contexte de marché dans lequel évolue une offre commerciale simple et le comportement d'achat du client vis-à-vis de cette offre.\n\nDescriptif générique :\n– Diagnostic et analyse micro et macroéconomique pour permettre à une entreprise d'agir sur un marché, et de mettre en lumière les tendances de marché, l'offre (concurrence) et la demande (comportement du consommateur)\n– Analyse du contexte commercial et du comportement d'achat du client pour détecter ou valider les opportunités en vue du lancement d'un nouveau produit	SAE	1	1	Tronc Commun	R1.01, R1.04, R1.05, R1.06, R1.07, R1.08, R1.09, R1.10, R1.11, R1.12, R1.13, R1.14, R1.15	\N	\N
2	SAE 1.02	Vente : démarche de prospection	Compétence ciblée :\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nPréparer et réaliser une démarche complète de prospection, notamment téléphonique.\nLa problématique professionnelle consiste à mener une démarche de prospection, en particulier téléphonique, pour un produit simple depuis les étapes de préparation de l'échange téléphonique jusqu'à l'analyse de l'action commerciale.\n\nDescriptif générique :\n– Elaboration ou qualification d'un fichier de prospects\n– Réalisation d'un plan d'appel\n– Préparation des outils de suivi de la prospection\n– Prise de contact avec les prospects\n– Bilan et analyse des résultats de l'opération de prospection	SAE	1	1	Tronc Commun	R1.01, R1.02, R1.07, R1.08, R1.10, R1.13, R1.14, R1.15	\N	\N
3	SAE 1.03	Communication commerciale : création d'un support "print"	Compétence ciblée :\n– Communiquer l'offre commerciale\n\nObjectifs et problématique professionnelle :\nAnalyser les supports "print" des concurrents d'un secteur et créer un support.\nLa démarche professionnelle consiste à élaborer un support "print" (affiche, plaquette, flyer, encart presse) destiné à une cible de consommateurs, en cohérence avec la stratégie de communication et le mix de l'organisation et en tenant compte des concurrents.\n\nDescriptif générique :\n– Étude d'une campagne de publicité\n– Réalisation d'une plaquette de présentation d'une entreprise ou d'un produit\n– Réalisation d'affiches	SAE	1	1	Tronc Commun	R1.03, R1.06, R1.07, R1.10, R1.11, R1.12, R1.13, R1.14, R1.15	\N	\N
4	PORTFOLIO S1	Démarche portfolio (S1)	Compétences ciblées :\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l'offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 1, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l'étudiant de se positionner, sans être évalué, dans le processus d'acquisition du niveau 1 des compétences de la première année du B.U.T.\n\nDescriptif générique :\nL'équipe pédagogique devra accompagner l'étudiant dans la compréhension et l'appropriation effectives du référentiel de compétences et de ses éléments constitutifs tels que les composantes essentielles en tant qu'elles constituent des critères qualité. Seront également exposées les différentes possibilités de démonstration et d'évaluation de l'acquisition du niveau des compétences ciblé en première année par la mobilisation notamment d'éléments de preuve issus de toutes les SAÉ. L'enjeu est de permettre à l'étudiant d'engager une démarche d'auto-positionnement et d'auto-évaluation.	PORTFOLIO	1	1	Tronc Commun	R1.07, R1.13, R1.14, R1.15	\N	\N
10	STAGE S2	Stage de découverte (S2)	Compétences ciblées :\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l'offre commerciale\n\nObjectifs et problématique professionnelle :\nLe ou la stagiaire participe aux activités d'un service ou d'une organisation, en position d'observer les pratiques professionnelles et d'exécuter des tâches simples relevant du domaine de la vente, du marketing et/ou de la communication commerciale. Les activités du ou de la stagiaire sont supervisées par un encadrant de l'organisme d'accueil.\n\nObjectifs du stage :\n– Découvrir l'entreprise ou l'organisation dans ses aspects sociaux, technico-économiques et organisationnels\n– Découvrir la réalité de l'activité du cadre intermédiaire dans l'environnement commercial\n– Acquérir des savoir-faire et savoir-être professionnels\n– Mobiliser les acquis académiques en situation professionnelle\n– Développer le projet personnel professionnel	STAGE	1	2	Tronc Commun	R2.01, R2.02, R2.03, R2.04, R2.05, R2.06, R2.07, R2.08, R2.09, R2.10, R2.11, R2.12, R2.13, R2.14, R2.15	\N	\N
14	PORTFOLIO S3 SME	Démarche portfolio (S3 SME)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner, sans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement au parcours suivi.\n\nDescriptif générique :\nL’équipe pédagogique devra accompagner l’étudiant dans la compréhension et l’appropriation effectives du référentiel de compétences et de ses éléments constitutifs tels que les composantes essentielles en tant qu’elles constituent des critères qualité. Seront également exposées les différentes possibilités de démonstration et d’évaluation de l’acquisition des niveaux de compétences ciblés en deuxième année par la mobilisation notamment d’éléments de preuve issus de toutes les SAÉ. L’enjeu est de permettre à l’étudiant d’engager une démarche d’auto-positionnement et d’auto-évaluation tout en intégrant la spécificité du parcours suivi.	PORTFOLIO	2	3	SME	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14, R3.SME.15, R3.SME.16	\N	\N
18	STAGE S4 SME	Stage SME (S4)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	SME	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.SME.09, R4.SME.10, R4.SME.11	\N	\N
6	SAE 2.02	Vente : initiation au jeu de rôle de négociation	Réaliser le jeu de rôle de négociation par étapes avec les Outils d’Aide à la Vente (OAV) adaptés\nLa problématique professionnelle est centrée sur la préparation d’un entretien de vente et la mise en œuvre des savoirs-faire\net savoir-être adaptés.\n\n\n– Prise de connaissance des produits/services de l’entreprise étudiée puis préparation de la prise de contact\n– Préparation des OAV et du plan de découverte\n– Pratique de l’écoute active et de l’empathie\n– Préparation et jeu de rôle de la première et de la deuxième partie de l’entretien (préparation de l’argumentaire et des\nobjections (sauf prix)\n– Pratique de l’argumentation centrée sur l’avantage client	SAE	1	2	Tronc Commun	R2.02, R2.05, R2.06, R2.07, R2.09, R2.10, R2.13, R2.14, R2.15	\N	\N
25	STAGE S4 MMPV	Stage MMPV (S4)	Compétences ciblées :\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	MMPV	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MMPV.09, R4.MMPV.10, R4.MMPV.11	\N	\N
16	SAE 4.02	Pilotage commercial d’une organisation	Assurer le pilotage d’une entreprise ﬁctive grâce à la mobilisation des compétences marketing, vente et communication com-\nmerciale.\nLa problématique professionnelle consiste à maîtriser les enjeux de gestion d’une entreprise et l’interdépendance des fonctions\net des décisions qui structurent le fonctionnement d’une entreprise.\n\n\n– Pilotage d’ une entreprise virtuelle\n– Prise de décisions en mettant en oeuvre des compétences marketing, vente et communication commerciale au service\nde la performance de l’entreprise	SAE	2	4	BDMRC	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08	\N	\N
32	STAGE S4 MDEE	Stage MDEE (S4)	Compétences ciblées :\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	MDEE	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MDEE.09, R4.MDEE.10, R4.MDEE.11	\N	\N
39	STAGE S4 BI	Stage BI (S4)	Compétences ciblées :\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	BI	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BI.09, R4.BI.10, R4.BI.11	\N	\N
42	STAGE S4 BDMRC	Stage BDMRC (S4)	Compétences ciblées :\n– Participer à la stratégie marketing et commerciale de l’organisation\n– Manager la relation client\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	BDMRC	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BDMRC.09, R4.BDMRC.10	\N	\N
45	PORTFOLIO S3 BDMRC	Démarche portfolio (S3 BDMRC)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	BDMRC	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14	\N	\N
49	PORTFOLIO S4 SME	Démarche portfolio (S4 SME)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	SME	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.SME.09, R4.SME.10, R4.SME.11	\N	\N
50	PORTFOLIO S4 MMPV	Démarche portfolio (S4 MMPV)	Compétences ciblées :\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	MMPV	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MMPV.09, R4.MMPV.10, R4.MMPV.11	\N	\N
51	PORTFOLIO S4 MDEE	Démarche portfolio (S4 MDEE)	Compétences ciblées :\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	MDEE	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MDEE.09	\N	\N
52	PORTFOLIO S4 BI	Démarche portfolio (S4 BI)	Compétences ciblées :\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	BI	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BI.09, R4.BI.10, R4.BI.11	\N	\N
54	PORTFOLIO S6 SME	Démarche portfolio (S6 SME)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	SME		\N	\N
56	PORTFOLIO S6 MDEE	Démarche portfolio (S6 MDEE)	Compétences ciblées :\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	MDEE		\N	\N
57	PORTFOLIO S6 BI	Démarche portfolio (S6 BI)	Compétences ciblées :\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	BI		\N	\N
58	PORTFOLIO S6 BDMRC	Démarche portfolio (S6 BDMRC)	Compétences ciblées :\n– Participer à la stratégie marketing et commerciale de l’organisation\n– Manager la relation client\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	BDMRC		\N	\N
60	STAGE S6 MMPV	Stage MMPV (S6)	Compétences ciblées :\n\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	MMPV		\N	\N
61	STAGE S6 MDEE	Stage MDEE (S6)	Compétences ciblées :\n\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	MDEE		\N	\N
62	STAGE S6 BI	Stage BI (S6)	Compétences ciblées :\n\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	BI		\N	\N
8	SAE 2.04	Conception d’un projet en déployant les techniques de commercialisation	Analyser au préalable l’environnement commercial et les besoins d’un commanditaire\nLa problématique professionnelle consiste à apporter à l’organisation cliente des solutions adaptées à sa demande, en termes\nde commercialisation au sens large, à savoir de vente, de marketing et de communication commerciale. Dans cette étape\ninitiale, il s’agit de déterminer les outils et l’organisation à mettre en place au regard de l’objectif ﬁxé par le commanditaire.\n\n\nConduite d’un projet en réponse à une problématique commerciale fournie par une organisation :\n– Conception d’un cahier des charges\n– Constitution d’une équipe\n– Répartition et planiﬁcation des tâches\n– Utilisation des outils de gestion de projet\n– Recherche des contraintes inhérentes au projet\n– Présentation de la documentation pertinente	SAE	1	2	Tronc Commun	R2.01, R2.02, R2.03, R2.04, R2.05, R2.06, R2.07, R2.08, R2.09, R2.10, R2.11, R2.12, R2.13, R2.14, R2.15	\N	\N
9	PORTFOLIO S2	Démarche portfolio (S2)	Au semestre 2, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition du niveau 1 des compé-\ntences de la première année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées\ndans le cadre des SAÉ de première année.	PORTFOLIO	1	2	Tronc Commun	R2.06, R2.13, R2.14, R2.15	\N	\N
12	SAE 3.SME.02	Démarche de création d’entreprise dans l’évènementiel ou la communication	Dans un contexte simple de création d’une agence évènementielle (tous types d’évènements et de prestataires) ou d’une\nagence de communication développer des attitudes entrepreneuriales en favorisant la créativité, la prise d’initiative, l’autonomie,\nla prise de risque, l’anticipation et le travail en équipe, mobiliser les compétences en marketing, en vente et en communication\ncommerciale et sensibiliser au choix du statut juridique et de l’organisation.\nLa problématique professionnelle est centrée sur l’élaboration d’une identité de marque et la mobilisation des compétences en\nmanagement de projet évènementiel.\n\n\nConstruction d’une démarche de création d’entreprise dans le digital :\n– Validation d’une idée et élaboration d’un cahier des charges simple pour développer un projet de création\n– Intégration des acteurs de l’écosystème local et interaction avec un réseau de créateurs d’entreprises et/ou des orga-\nnismes d’aide à la création d’entreprise	SAE	2	3	SME	R3.01, R3.02, R3.03, R3.04, R3.06, R3.07, R3.09, R3.12, R3.13, R3.14, R3.SME.15, R3.SME.16	\N	\N
13	SAE 3.SME.03	Création d’un évènement comme outil de branding	Développer l’expertise de conception d’un événement pour valoriser une marque et les techniques de valorisation du contenu\nde marque (brand content).\nLa problématique professionnelle consiste à réﬂéchir à un évènement simple au service d’une marque : évènement d’ampleur\nlimitée, avec un public peu nombreux et des enjeux ﬁnanciers et réglementaires faibles, mais comportant des possibilités de\ncréation de contenus valorisants pour la marque.\n\n\nConception d’ un événement simple (limité en durée et en nombre de participants) pour valoriser une marque :\n– Etude d’une marque et de son positionnement\n– Analyse de la problématique de la marque\n– Proposition d’un évènement simple permettant de valoriser la marque\n– Etude de contenus de marque possibles en lien avec l’évènement	SAE	2	3	SME	R3.14, R3.SME.15, R3.SME.16	\N	\N
15	SAE 4.01	Evaluation de la performance du projet en déployant les techniques de commercialisation	Evaluer la performance des actions menées dans le cadre du projet et rendre compte au commanditaire.\nLa problématique professionnelle consiste à ﬁnaliser un projet et à faire un bilan et des recommandations au commanditaire.\n\n\nCette SAÉ permet de mobiliser l’ensemble des compétences. Elle consiste à ﬁnaliser les actions nécessaires à la réalisation\nd’un projet pour un commanditaire et à les évaluer. Il s’agit de :\n– Analyser des indicateurs pour mesurer concrètement l’efﬁcacité et l’avancement du projet\n– Identiﬁer les sources d’erreurs et proposer des actions correctives\n– Evaluer la qualité et la pertinence des solutions mises en place\n– Evaluer le respect des contraintes de temps, de budget et des éléments du cahier des charges\n– Vériﬁer l’adéquation entre les actions menées et les besoins initiaux du commanditaire	SAE	2	4	BDMRC	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08	\N	\N
20	SAE 5.SME.01	Projet de communication évènementielle	Mettre en place une stratégie de brand content pour exploiter au mieux un évènement complexe au service de la marque.\nLa problématique professionnelle consiste à organiser un évènement d’ampleur, avec un budget conséquent et une diversité\nde prestataires pour valoriser une marque.\n\n\nConception d’une stratégie de brand content reposant sur l’organisation d’un évènement complexe de A à Z :\n– Réﬂexion\n– Proposition\n– Organisation et logistique\n– Gestion\n– Mise en œuvre\n– Branding\n– Bilan et analyse.	SAE	3	5	SME	R5.01, R5.02, R5.03, R5.04, R5.05, R5.06, R5.07, R5.08, R5.09, R5.SME.10, R5.SME.11, R5.SME.12, R5.SME.13, R5.SME.14, R5.SME.15, R5.SME.16	\N	\N
22	SAE 3.MMPV.03	Analyse d’un point de vente ou d’un rayon dans son environnement concurrentiel	Analyser le positionnement concurrentiel d’un espace de vente\nLa problématique professionnelle consiste à faire pour un point de vente donné une étude de la concurrence en terme d’offre\net de demande.\n\n\n– Analyse du marché (offre et demande)\n– Identiﬁcation des concurrents d’un espace de vente après avoir délimiter la zone de chalandise\n– Analyse du mix des concurrents : produits/gammes, prix, communication\n– Positionnement du point de vente par rapport aux concurrents et identiﬁcation de ses avantages concurrentiels	SAE	2	3	MMPV	R3.14, R3.MMPV.15, R3.MMPV.16	\N	\N
23	PORTFOLIO S3 MMPV	Démarche portfolio (S3 MMPV)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	MMPV	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14, R3.MMPV.15, R3.MMPV.16	\N	\N
24	SAE 4.MMPV.03	Propositions d’amélioration du fonctionnement du point de vente et du management de	Appliquer les techniques de merchandising, GRC et management pour optimiser le fonctionnement d’un espace de vente.\nLa problématique commerciale consiste à proposer des actions efﬁcaces pour rendre un espace de vente plus attractif et\naméliorer la gestion de l’équipe commerciale.\n\n\nA partir des analyses réalisées dans la SAÉ "Analyse d’un point de vente ou d’un rayon dans son environnement concurrentiel"\ndu S3, production de recommandations pour améliorer le fonctionnement de l’équipe commerciale et l’attractivité du point de\nvente avec des chiffrages prévisionnels.	SAE	2	4	MMPV	R4.08, R4.MMPV.09, R4.MMPV.10, R4.MMPV.11	\N	\N
26	PORTFOLIO S5 MMPV	Démarche portfolio (S5 MMPV)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	MMPV	R6.01, R6.02, R6.MMPV.03, R6.MMPV.04	\N	\N
27	SAE 5.MMPV.01	Approche omnicanale du point de vente	Développer l’omnicanalité et analyser ses conséquences sur la gestion d’un point de vente et de l’équipe commerciale.\nLa problématique professionnelle consiste à optimiser le fonctionnement commercial et managérial du point de vente par une\napproche omnicanal.\n\n\nProposition de déploiement de l’activité :\n– Intégration dans la stratégie de l’entreprise\n– Optimisation du parcours client dans une perspective omnicanal par l’intégration des différents points de contact	SAE	3	5	MMPV	R5.03, R5.04, R5.08, R5.09, R5.MMPV.10, R5.MMPV.11, R5.MMPV.12, R5.MMPV.13, R5.MMPV.14, R5.MMPV.15	\N	\N
30	PORTFOLIO S3 MDEE	Démarche portfolio (S3 MDEE)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	MDEE	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14	\N	\N
33	PORTFOLIO S5 MDEE	Démarche portfolio (S5 MDEE)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	MDEE	R6.01, R6.02, R6.MDEE.03, R6.MDEE.04	\N	\N
34	SAE 5.MDEE.01	Développement d’un projet digital	Créer un projet de e-business et en saisir les diverses dimensions qui conditionnent sa réussite.\nLa problématique professionnelle consiste à développer un projet de e-business dans le cadre d’une activité partiellement ou\nintégralement digitale.\n\n\nElaboration et mise en œuvre d’un projet complet d’une activité partiellement ou intégralement digitale :\n– Identiﬁcation d’un projet innovant capable de générer de la valeur\n– Développement d’une stratégie marketing digitale performante\n– Elaboration d’un cahier des charges fonctionnel puis technique\n– Optimisation de la relation client digitalisée\n– Gestion performante des ﬂux physiques et/ou informationnels\nCette SAÉ peut être menée dans le cadre d’une création digitale complète.	SAE	3	5	MDEE	R5.04, R5.08, R5.09, R5.MDEE.10, R5.MDEE.11, R5.MDEE.12, R5.MDEE.13, R5.MDEE.14, R5.MDEE.15, R5.MDEE.16	\N	\N
35	SAE 3.BI.02	Démarche de création d’entreprise à l’international	Dans un contexte simple de création d’entreprise, développer des attitudes entrepreneuriales en favorisant la créativité, la\nprise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et mobiliser les compétences en pilotage\nd’opérations à l’international, en stratégie du commerce international, mais aussi en marketing, en vente et en communication\ncommerciale et sensibiliser au choix du statut juridique et de l’organisation.\nLa problématique professionnelle est centrée sur la distribution d’un produit étranger en France, ou d’un produit français à\nl’étranger, dans une situation d’import ou d’export ou d’ouverture d’un point de vente à l’étranger.\n\n\nConstruction d’une démarche de création d’entreprise tournée vers l’international :\n– De l’idée au projet commercial\n– Rejoindre et s’intégrer dans un réseau de créateurs d’entreprises et/ou des organismes d’aide à la création d’entreprise	SAE	2	3	BI	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14	\N	\N
36	SAE 3.BI.03	Etude et sélection des marchés à l’étranger pour déployer l’offre	Identiﬁer et sélectionner un marché potentiel à l’étranger pour le développement de l’offre.\nLa problématique professionnelle est centrée sur le choix d’un marché à l’étranger en évaluant son potentiel et ses risques à\nl’aide d’outils d’analyse adaptés.\n\n\n– Réalisation d’un diagnostic stratégique d’une entreprise existante avec une offre simple déﬁnie (produit de grande\nconsommation)\n– Développement de l’offre sur un marché étranger, en mettant en œuvre le processus de veille (économique et prospec-\ntion, analyse sectorielle et concurrentielle), matrice multi-critères, bilan ﬁnancier, etc.\nCette SAÉ pourra être menée en langues étrangères.	SAE	2	3	BI	R3.14, R3.BI.15, R3.BI.16	\N	\N
37	PORTFOLIO S3 BI	Démarche portfolio (S3 BI)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	BI	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14, R3.BI.15, R3.BI.16	\N	\N
38	SAE 4.BI.03	Développement de l’offre à l’international	Construire une offre en l’adaptant à la demande d’une clientèle internationale.\nLa problématique professionnelle consiste à élaborer une offre en fonction du marché cible à l’international.\n\n\nMise en œuvre opérationnelle de l’offre.\nUne fois le marché étranger identiﬁé, développement marketing de l’offre et adaptation au marché étranger, incluant la partie\nprospection.\nCette SAÉ pourra être menée en langues étrangères.	SAE	2	4	BI	R4.08, R4.BI.09, R4.BI.10, R4.BI.11	\N	\N
40	PORTFOLIO S5 BI	Démarche portfolio (S5 BI)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	BI	R6.01, R6.02, R6.BI.03, R6.BI.04	\N	\N
43	SAE 3.BDMRC.02	Démarche de création ou de reprise d’entreprise	Dans un contexte simple de création ou de reprise d’entreprise, développer des attitudes entrepreneuriales en favorisant la\ncréativité, la prise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et mobiliser les compétences\nen marketing, en vente et en communication commerciale et sensibiliser au choix du statut juridique et de l’organisation.\nLa problématique professionnelle est centrée sur l’analyse de l’offre existante et la proposition de nouvelles activités commer-\nciales innovantes adaptées à la demande des clients. Celles-ci seront accompagnées d’indicateurs de suivi de la satisfaction\ndes futurs clients.\n\n\nConstruction d’une démarche de création ou de reprise d’entreprise :\n– Trouver l’idée innovante\n– Construire la nouvelle offre\n– Rejoindre et s’intégrer dans un réseau de créateurs ou de repreneurs d’entreprises et/ou des organismes d’aide à la\ncréation de projet ou d’entreprise	SAE	2	3	BDMRC	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14, R3.BDMRC.15, R3.BDMRC.16	\N	\N
44	SAE 3.BDMRC.03	Développement d’une expertise commerciale basée sur le diagnostic de la stratégie client	Développer l’expertise commerciale et relationnelle au travers de l’étude des pratiques commerciales de la concurrence et des\nattentes des clients du secteur.\nLa problématique professionnelle consiste à conduire un diagnostic de la situation commerciale d’un secteur d’activité.\n\n\nPréparation d’ un diagnostic de la situation commerciale d’un secteur en réalisant une cartographie des pratiques commerciales\net relationnelles des entreprises d’un secteur.\nContextualisation de la SAÉ : appui sur la situation de l’entreprise dans laquelle l’alternant effectue son apprentissage et / ou\nappui sur un domaine d’activité spéciﬁque (banque, immobilier, agroalimentaire, tourisme, etc ...).	SAE	2	3	BDMRC	R3.14, R3.BDMRC.15, R3.BDMRC.16	\N	\N
47	PORTFOLIO S5 BDMRC	Démarche portfolio (S5 BDMRC)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	BDMRC	R6.01, R6.02, R6.BDMRC.03, R6.BDMRC.04	\N	\N
48	SAE 5.BDMRC.01	Mise en œuvre et pilotage de la stratégie client d’une entreprise	Organiser les actions commerciales d’une entreprise cliente en cohérence avec la stratégie marketing sur un secteur déterminé\n(domaine métiers, secteur géographique...) dans le respect de la RSE.\nLa problématique professionnelle est centrée sur le développement de la stratégie commerciale d’un commanditaire en tant\nque partenaire.\n\n\nEn tant que prestataire spécialiste de l’action commerciale au service d’un commanditaire :\n– Démarchage des entreprises clientes\n– Identiﬁcation des enjeux des partenaires en termes marketing et commercial\n– Proposition d’une démarche et d’une organisation commerciale adaptées\n– Mise en œuvre d’une politique de ﬁdélisation et développement de la clientèle, et de valorisation de la relation client à\ntravers la CLTV (customer long-term value)	SAE	3	5	BDMRC	R5.01, R5.02, R5.03, R5.04, R5.05, R5.06, R5.07, R5.08, R5.09, R5.BDMRC.10, R5.BDMRC.11, R5.BDMRC.12, R5.BDMRC.13, R5.BDMRC.14	\N	\N
5	SAE 2.01	Marketing : marketing mix	Mettre en œuvre de façon éthique la stratégie commerciale d’une offre simple à travers les décisions marketing relevant du\nmarketing mix et de sa cohérence\nApprécier les enjeux des variables du mix et des facteurs liés\nComprendre la complexité d’une décision marketing, son besoin de cohérence avec la stratégie marketing de ciblage et de\npositionnement et les interactions dans l’entreprise\nLa problématique professionnelle consiste à préconiser les déterminants marketing de l’offre commerciale simple en pleine\nappréciation des facteurs internes et externes.\n\n\n– Étude du marketing mix\n– Prise de décisions marketing assurant la cohérence du mix dans le cadre d’un marché concurrentiel et au moyen\nd’informations fournies au préalable\n– Lancement d’un nouveau bien de grande consommation en B2C\n– Conception d’une offre cohérente et éthique en termes de produits, prix, distribution et communication sur un marché de\nbiens de grande consommation B2C en fonction d’une cible et d’un positionnement à pré-établir	SAE	1	2	Tronc Commun	R2.01, R2.04, R2.05, R2.06, R2.07, R2.08, R2.10, R2.11, R2.12, R2.13, R2.14, R2.15	\N	\N
7	SAE 2.03	Communication commerciale : élaboration d’un plan de communication commerciale	Déterminer des cibles et objectifs de communication avant toute action de communication\nComprendre la complexité du choix des moyens de communication commerciale\nÉlaborer des outils pertinents\nProposer des indicateurs aﬁn d’évaluer l’impact du plan de communication choisi, argumenter la pertinence des indicateurs\nLa problématique professionnelle est centrée sur le choix des moyens et l’élaboration d’outils de communication adaptés.\n\n\nMise en œuvre d’une action de communication commerciale :\n– Déﬁnition de la cible et des objectifs\n– Choix d’un ou plusieurs moyens de communication adaptés\n– Collecte d’informations, préparation des outils choisis : e-mailing et/ou dossier de partenariat, etc.\n– Choix des critères d’analyse de l’efﬁcacité	SAE	1	2	Tronc Commun	R2.03, R2.05, R2.06, R2.07, R2.10, R2.12, R2.13, R2.14, R2.15	\N	\N
11	SAE 3.01	Pilotage d’un projet en déployant les techniques de commercialisation	Piloter les actions et mettre en oeuvre le suivi du projet.\nA partir de l’analyse préalable des besoins du commanditaire, la problématique professionnelle consiste à mettre en place les\nactions adéquates et à piloter le projet aﬁn d’apporter à l’organisation cliente des solutions adaptées à sa demande, en termes\nde commercialisation au sens large à savoir de vente, de marketing et de communication commerciale.\n\n\nCette SAÉ permet de mobiliser l’ensemble des compétences acquises de façon à les faire aboutir concrètement au sein du\nprojet.\nElle consiste principalement en la concrétisation d’actions nécessaires à sa réalisation, et au pilotage en :\n– connaissant parfaitement le périmètre du projet\n– assurant le suivi grâce à des indicateurs déﬁnis au préalable\n– garantissant l’avancée du projet par la réalisation des tâches et des jalons, et la production des livrables\n– adaptant le planning du projet et en surveillant l’écart entre le planning prévisionnel et le planning réel\n– maîtrisant le budget en l’adaptant selon les aléas du projet\n– encadrant une équipe projet et en gérant les ressources\n– faisant face, pour s’adapter et prendre les décisions adéquates en fonction des risques	SAE	2	3	BDMRC	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14	\N	\N
17	SAE 4.SME.03	Organisation d’un évènement comme outil de branding	Mettre en oeuvre les outils de l’organisation évènementielle et de la création de contenu de marque.\nLa problématique professionnelle consiste à réaliser un événement simple limité en durée et en nombre de participants pour\nvaloriser une marque et à créer du contenu de marque.\n\n\nRéalisation d’un événement simple (limité en durée et nombre de participants) pour valoriser une marque.\nOrganisation de l’évènement proposé en SAÉ S3 :\n– mise en place et organisation de l’événement : planiﬁcation, pilotage, logistique, gestion budgétaire, cadre juridique\n– mise en œuvre du plan de communication et de la commercialisation\n– gestion des relations presse et relations publiques\n– analyse des retombées\n– création de contenus de marque	SAE	2	4	SME	R4.08, R4.SME.09, R4.SME.10, R4.SME.11	\N	\N
19	PORTFOLIO S5 SME	Démarche portfolio (S5 SME)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	SME	R6.01, R6.02, R6.SME.03, R6.SME.04	\N	\N
21	SAE 3.MMPV.02	Démarche d’ouverture d’un point de vente	Dans un contexte simple de création d’entreprise, développer des attitudes entrepreneuriales en favorisant la créativité, la\nprise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et mobiliser les compétences en marketing,\nen vente, en communication commerciale, marketing digital, e-business et entrepreneuriat et sensibiliser au choix du statut\njuridique et de l’organisation.\nLa problématique professionnelle est centrée, dans le cadre de l’ouverture d’un point de vente, sur l’analyse du potentiel d’une\nzone géographique (concurrents, zone de chalandise, analyse de la demande...), la proposition d’un assortiment de produits\n(largeur, profondeur...) et la ﬁxation d’objectifs de vente.\n\n\nConstruction d’une démarche d’ouverture d’un point de vente :\n– Validation d’une idée et élaboration d’un cahier des charges simple pour développer un projet de création\n– Intégration des acteurs de l’écosystème local et interaction avec un réseau de créateurs d’entreprises et/ou des orga-\nnismes d’aide à la création d’entreprise	SAE	2	3	MMPV	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14, R3.MMPV.15, R3.MMPV.16	\N	\N
28	SAE 3.MDEE.02	Démarche de création d’entreprise en contexte digital	Dans un contexte simple de création d’une activité digitale ou liée à un environnement digital développer des attitudes entre-\npreneuriales en favorisant la créativité, la prise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et\nmobiliser les compétences en marketing, en vente et en communication commerciale.\nLa problématique professionnelle est centrée sur la proposition d’idées de création d’entreprise en les situant par rapport à\nl’existant et sur la sensibilisation au choix du statut juridique de l’organisation en tenant compte des singularités d’une activité\ndigitale ou hybride.\n\n\nConstruction d’une démarche de création d’entreprise dans le digital :\n– Validation d’une idée et élaboration d’un cahier des charges simple pour développer un projet de création\n– Intégration des acteurs de l’écosystème local et interaction avec un réseau de créateurs d’entreprises et/ou des orga-\nnismes d’aide à la création d’entreprise	SAE	2	3	MDEE	R3.01, R3.03, R3.04, R3.06, R3.07, R3.08, R3.09, R3.12, R3.13, R3.14, R3.MDEE.15, R3.MDEE.16	\N	\N
29	SAE 3.MDEE.03	Analyse d’une activité digitale	Analyser une activité digitale partielle ou intégrale et identiﬁer les processus générant du chiffre d’affaires et/ou de la marge.\nLa problématique professionnelle consiste à faire l’audit d’un projet commercial en intégrant l’aspect digital.\n\n\nAnalyse d’un projet commercial :\n– en élaborant, d’une part, le modèle d’affaires correspondant : marketing mix, indicateurs clés de performance, type\nd’organisation, processus de création et délivrance de valeur\n– en effectuant, d’autre part, une étude approfondie des éléments digitaux	SAE	2	3	MDEE	R3.14, R3.MDEE.15, R3.MDEE.16	\N	\N
31	SAE 4.MDEE.03	Création de site web	Créer un site web avec un business model cohérent.\nLa problématique professionnelle consiste à réaliser un site web en ayant identiﬁé la stratégie de e-commerce et à développer\nles compétences en lien avec l’activité digitale de l’entreprise.\n\n\nÉlaboration d’un cahier des charges incluant la déﬁnition du proﬁl de persona ciblé et son parcours d’achat, les étapes de la\nstratégie e-business, le modèle d’affaires pertinent pour atteindre la cible et les modalités de conversion client\nStratégie de contenu, Inbound marketing.\nCréation d’un site web, de son architecture (proposition d’une url, conception d’une maquette du site, prévision des fonctionna-\nlités, conception des éléments de design du logo, conception de la stratégie éditoriale, tunnel de conversion)\nProposition d’un business model simple où la création et la délivrance de valeur pourront être identiﬁées facilement.	SAE	2	4	MDEE	R4.08, R4.MDEE.09, R4.MDEE.10, R4.MDEE.11	\N	\N
41	SAE 5.BI.01	Conduite d’une mission import ou export pour une entreprise	Déployer l’offre à l’international, en intégrant les aspects marketing, vente, logistiques, interculturels, transports, fournisseurs,\napprovisionnements et qualité.\nLa problématique professionnelle consiste à déployer une mission d’import ou d’export en qualité de prestataire d’une entreprise\npartenaire pour une mission d’export ou d’import.\n\n\n– Analyse des capacités de l’entreprise et des éléments contextuels du marché\n– Déploiement de l’offre, en mettant en œuvre le processus de veille (économique et prospection, analyse sectorielle et\nconcurrentielle), matrice multi-critères, bilan ﬁnancier, etc...\n– Prise en compte des enjeux de développement durable et de la stratégie achat de l’entreprise dans le cadre de la\npréparation de la mission\n– Déploiement marketing de l’offre et son adaptation au marché étranger (avec la partie prospection) une fois le marché\nétranger identiﬁé\n– Démarche de sourcing éco-responsable, choix des canaux de distribution adéquats\n– Evaluation des coûts de transport et de dédouanement pour proposer une cotation incluant les incoterms\n– Prise en compte des éléments de droit international et de l’analyse du marché fournisseurs\nCette SAÉ pourra être menée en langues étrangères (dans le cadre d’une participation à une négociation achat ou vente en\nlangue étrangère, etc.).	SAE	3	5	BI	R5.03, R5.04, R5.08, R5.09, R5.BI.10, R5.BI.11, R5.BI.12, R5.BI.13, R5.BI.14, R5.BI.15	\N	\N
46	SAE 4.BDMRC.03	Élaboration d’ un plan d’actions commercial et relationnel	Développer l’offre en termes de bénéﬁce client en s’appuyant sur les équipes commerciales et mettre en place une stratégie\nrelationnelle à laquelle adhèrent les équipes commerciales de l’entreprise.\nLa problématique professionnelle consiste à favoriser, au sein des équipes commerciales, la création d’opportunités commer-\nciales pour le client aﬁn d’optimiser la relation client.\n\n\nCette SAÉ peut faire suite au bilan commercial et relationnel réalisé dans la SAÉ "Développement d’une expertise commerciale\nbasé sur le diagnostic de la stratégie client d’un secteur" .\nDans l’optique d’optimiser la relation client, il s’agit de :\n– Déterminer les actions à mener, notamment des opérations commerciales spéciﬁques\n– Choisir et former les personnes ressources dans l’équipe commerciale\n– Proposer un plan d’actions commerciales permettant de saisir les opportunités du secteur\n– Construire un tableau de reporting présentant les indicateurs pertinents	SAE	2	4	BDMRC	R4.08, R4.BDMRC.09, R4.BDMRC.10	\N	\N
53	PORTFOLIO S4 BDMRC	Démarche portfolio (S4 BDMRC)	Compétences ciblées :\n– Participer à la stratégie marketing et commerciale de l’organisation\n– Manager la relation client\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	BDMRC	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BDMRC.09, R4.BDMRC.10	\N	\N
55	PORTFOLIO S6 MMPV	Démarche portfolio (S6 MMPV)	Compétences ciblées :\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	MMPV		\N	\N
59	STAGE S6 SME	Stage SME (S6)	Compétences ciblées :\n\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	SME		\N	\N
63	STAGE S6 BDMRC	Stage BDMRC (S6)	Compétences ciblées :\n\n– Participer à la stratégie marketing et commerciale de l’organisation\n– Manager la relation client\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	BDMRC		\N	\N
\.


--
-- Data for Name: activityaclink; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.activityaclink (activity_id, ac_id) FROM stdin;
1	1
1	2
1	3
2	13
2	16
2	17
2	18
3	28
3	29
3	30
5	3
5	4
5	2
6	18
6	14
6	15
6	13
7	29
7	31
7	30
7	28
8	31
8	15
8	16
8	18
8	29
8	3
8	1
8	28
8	14
8	30
8	2
8	13
8	17
8	4
10	1
10	2
10	3
10	4
10	13
10	14
10	15
10	16
10	17
10	18
10	28
10	29
10	30
10	31
11	35
11	32
11	34
11	23
11	21
11	6
11	8
11	22
11	33
11	19
11	20
11	5
11	24
11	7
12	35
12	32
12	34
12	21
12	6
12	36
12	8
12	22
12	38
12	33
12	44
12	19
12	20
12	5
12	47
12	46
12	7
13	37
13	38
13	44
13	45
13	36
15	35
15	32
15	34
15	23
15	21
15	6
15	8
15	22
15	33
15	19
15	20
15	5
15	24
15	7
16	35
16	32
16	34
16	23
16	21
16	6
16	8
16	22
16	33
16	19
16	20
16	5
16	24
16	7
17	37
17	38
17	48
17	45
17	47
17	39
17	46
18	5
18	6
18	7
18	8
18	19
18	20
18	21
18	22
18	23
18	24
18	32
18	33
18	34
18	35
18	36
18	37
18	38
18	39
18	44
18	45
18	46
18	47
18	48
20	52
20	26
20	27
20	43
20	40
20	41
20	50
20	53
20	10
20	9
20	11
20	49
20	25
20	42
20	51
20	12
21	35
21	32
21	34
21	23
21	21
21	6
21	62
21	8
21	22
21	33
21	55
21	63
21	19
21	20
21	5
21	54
21	7
22	62
22	63
22	64
22	54
24	66
24	64
24	55
24	56
24	65
24	54
25	5
25	6
25	7
25	8
25	19
25	20
25	21
25	22
25	23
25	24
25	32
25	33
25	34
25	35
25	54
25	55
25	56
25	62
25	63
25	64
25	65
27	26
27	27
27	57
27	59
27	61
27	67
27	10
27	9
27	11
27	69
27	25
27	58
27	72
27	71
27	70
27	68
27	60
27	12
28	35
28	8
28	22
28	76
28	7
28	33
28	19
28	20
28	83
28	84
28	21
28	6
28	87
28	88
28	73
28	86
28	77
28	74
28	34
28	75
28	85
28	5
29	74
29	83
29	75
29	85
29	73
29	76
29	77
29	84
31	74
31	83
31	87
31	75
31	85
31	88
31	73
31	86
31	76
31	77
31	84
32	5
32	6
32	7
32	8
32	19
32	20
32	21
32	22
32	23
32	24
32	32
32	33
32	34
32	35
32	73
32	74
32	75
32	76
32	77
32	83
32	84
32	85
32	86
32	87
32	88
34	90
34	26
34	27
34	81
34	80
34	91
34	93
34	89
34	92
34	10
34	9
34	11
34	25
34	78
34	94
34	82
34	12
34	79
35	35
35	32
35	34
35	23
35	21
35	6
35	102
35	8
35	22
35	97
35	96
35	33
35	19
35	101
35	20
35	5
35	103
35	7
36	102
36	97
36	95
36	96
36	101
36	103
36	104
38	102
38	97
38	95
38	96
38	103
38	104
39	5
39	6
39	7
39	8
39	19
39	20
39	21
39	22
39	23
39	24
39	32
39	33
39	34
39	35
39	95
39	96
39	97
39	101
39	102
39	103
39	104
41	26
41	27
41	105
41	100
41	107
41	10
41	9
41	11
41	98
41	99
41	25
41	106
41	108
41	12
42	5
42	6
42	7
42	8
42	19
42	20
42	21
42	22
42	23
42	24
42	32
42	33
42	34
42	35
42	109
42	110
42	111
42	112
42	116
42	117
42	118
42	119
43	35
43	32
43	34
43	23
43	21
43	6
43	8
43	22
43	112
43	33
43	109
43	19
43	20
43	5
43	116
43	7
44	119
44	111
44	110
44	109
44	116
46	119
46	111
46	118
46	112
46	116
46	117
48	122
48	26
48	27
48	114
48	123
48	10
48	9
48	11
48	115
48	25
48	121
48	113
48	12
48	120
4	87
4	88
4	111
4	112
4	116
4	117
4	118
4	119
4	38
4	54
4	73
4	109
4	32
4	74
4	75
4	76
4	5
4	6
4	7
4	8
4	20
4	55
4	64
4	65
4	66
4	36
4	37
4	47
4	1
4	2
4	3
4	4
4	9
4	10
4	11
4	12
4	13
4	14
4	15
4	16
4	17
4	18
4	19
4	21
4	22
4	23
4	24
4	25
4	26
4	27
4	28
4	29
4	30
4	31
4	33
4	34
4	35
4	39
4	40
4	41
4	42
4	43
4	44
4	45
4	46
4	48
4	49
4	123
4	50
4	51
4	52
4	53
4	56
4	57
4	58
4	59
4	60
4	61
4	62
4	63
4	67
4	68
4	69
4	70
4	71
4	72
4	77
4	78
4	79
4	80
4	81
4	82
4	83
4	84
4	85
4	86
4	89
4	90
4	91
4	92
4	93
4	94
4	95
4	96
4	97
4	98
4	99
4	100
4	101
4	102
4	103
4	104
4	105
4	106
4	107
4	108
4	110
4	113
4	114
4	115
4	120
4	121
4	122
9	1
9	2
9	3
9	4
9	13
9	14
9	15
9	16
9	17
9	18
9	28
9	29
9	30
9	31
51	87
30	87
51	88
30	88
45	111
53	111
45	112
53	112
45	116
53	116
45	117
53	117
45	118
53	118
45	119
53	119
14	38
49	38
50	54
23	54
51	73
30	73
45	109
53	109
14	32
45	32
49	32
50	32
51	32
52	32
23	32
30	32
37	32
53	32
51	74
30	74
51	75
30	75
51	76
30	76
14	5
45	5
49	5
50	5
51	5
52	5
23	5
30	5
37	5
53	5
14	6
45	6
49	6
50	6
51	6
52	6
23	6
30	6
37	6
53	6
14	7
45	7
49	7
50	7
51	7
52	7
23	7
30	7
37	7
53	7
14	8
45	8
49	8
50	8
51	8
52	8
23	8
30	8
37	8
53	8
14	20
45	20
49	20
50	20
51	20
52	20
23	20
30	20
37	20
53	20
50	55
23	55
50	64
23	64
50	65
23	65
50	66
23	66
14	36
49	36
14	37
49	37
14	47
49	47
14	19
45	19
49	19
50	19
51	19
52	19
23	19
30	19
37	19
53	19
14	21
45	21
49	21
50	21
51	21
52	21
23	21
30	21
37	21
53	21
14	22
45	22
49	22
50	22
51	22
52	22
23	22
30	22
37	22
53	22
14	23
45	23
49	23
50	23
51	23
52	23
23	23
30	23
37	23
53	23
14	24
45	24
49	24
50	24
51	24
52	24
23	24
30	24
37	24
53	24
14	33
45	33
49	33
50	33
51	33
52	33
23	33
30	33
37	33
53	33
14	34
45	34
49	34
50	34
51	34
52	34
23	34
30	34
37	34
53	34
14	35
45	35
49	35
50	35
51	35
52	35
23	35
30	35
37	35
53	35
14	39
49	39
14	44
49	44
14	45
49	45
14	46
49	46
14	48
49	48
50	56
23	56
50	62
23	62
50	63
23	63
51	77
30	77
51	83
30	83
51	84
30	84
51	85
30	85
51	86
30	86
52	95
37	95
52	96
37	96
52	97
37	97
52	101
37	101
52	102
37	102
52	103
37	103
52	104
37	104
45	110
53	110
54	9
56	9
57	9
58	9
26	9
33	9
40	9
47	9
19	9
55	9
54	10
56	10
57	10
58	10
26	10
33	10
40	10
47	10
19	10
55	10
54	11
56	11
57	11
58	11
26	11
33	11
40	11
47	11
19	11
55	11
54	12
56	12
57	12
58	12
26	12
33	12
40	12
47	12
19	12
55	12
54	25
56	25
57	25
58	25
26	25
33	25
40	25
47	25
19	25
55	25
54	26
56	26
57	26
58	26
26	26
33	26
40	26
47	26
19	26
55	26
54	27
56	27
57	27
58	27
26	27
33	27
40	27
47	27
19	27
55	27
54	40
19	40
54	41
19	41
54	42
63	9
63	10
63	11
63	12
63	25
63	26
63	27
63	123
63	113
63	114
63	115
63	120
63	121
63	122
19	42
54	43
19	43
54	49
19	49
58	123
47	123
54	50
19	50
54	51
19	51
54	52
19	52
54	53
19	53
26	57
55	57
26	58
55	58
26	59
55	59
26	60
55	60
26	61
55	61
26	67
55	67
26	68
55	68
26	69
55	69
26	70
55	70
26	71
55	71
26	72
55	72
56	78
33	78
56	79
33	79
56	80
33	80
56	81
33	81
56	82
33	82
56	89
33	89
56	90
33	90
56	91
33	91
56	92
33	92
56	93
33	93
56	94
33	94
57	98
40	98
57	99
40	99
57	100
40	100
57	105
40	105
57	106
40	106
57	107
40	107
57	108
40	108
58	113
47	113
58	114
47	114
58	115
47	115
58	120
47	120
58	121
47	121
58	122
47	122
60	9
61	9
62	9
59	9
60	10
61	10
62	10
59	10
60	11
61	11
62	11
59	11
60	12
61	12
62	12
59	12
60	25
61	25
62	25
59	25
60	26
61	26
62	26
59	26
60	27
61	27
62	27
59	27
59	40
59	41
59	42
59	43
59	49
59	50
59	51
59	52
59	53
60	57
60	58
60	59
60	60
60	61
60	67
60	68
60	69
60	70
60	71
60	72
61	78
61	79
61	80
61	81
61	82
61	89
61	90
61	91
61	92
61	93
61	94
62	98
62	99
62	100
62	105
62	106
62	107
62	108
\.


--
-- Data for Name: activitycelink; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.activitycelink (activity_id, ce_id) FROM stdin;
\.


--
-- Data for Name: activitygroup; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.activitygroup (id, name, activity_id, academic_year) FROM stdin;
30	Moussaillon	3	2025-2026
34	Aristide Briand	5	2025-2026
35	Écume	5	2025-2026
39	Estuaire	1	2025-2026
\.


--
-- Data for Name: activitygroupstudentlink; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.activitygroupstudentlink (group_id, student_uid) FROM stdin;
30	bl251857
30	gt231116
30	bn250395
30	al252868
34	bn250395
\.


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.company (id, name, address, phone, email, website, latitude, longitude, accepts_interns, visible_to_students) FROM stdin;
1	🌍 DECATHLON FRANCE (59650 VILLENEUVE-D'ASCQ)	4 BOULEVARD DE MONS 59650 VILLENEUVE-D'ASCQ	01 02 03 04 05	\N	\N	50.644112	3.141528	t	t
\.


--
-- Data for Name: competency; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.competency (id, code, label, description, situations_pro, level, pathway) FROM stdin;
1	C1-BUT1	Marketing (BUT 1)		en situation de développement d'un produit\nen situation de développement d'un service\nen situation de développement d'une activité non marchande	1	Tronc Commun
2	C1-BUT2	Marketing (BUT 2)		en situation de développement d'un produit\nen situation de développement d'un service\nen situation de développement d'une activité non marchande	2	Tronc Commun
3	C1-BUT3	Marketing (BUT 3)		en situation de développement d'un produit\nen situation de développement d'un service\nen situation de développement d'une activité non marchande	3	Tronc Commun
4	C2-BUT1	Vente (BUT 1)		en situation de vente en B to C\nen situation de vente en B to B	1	Tronc Commun
5	C2-BUT2	Vente (BUT 2)		en situation de vente en B to C\nen situation de vente en B to B	2	Tronc Commun
6	C2-BUT3	Vente (BUT 3)		en situation de vente en B to C\nen situation de vente en B to B	3	Tronc Commun
7	C3-BUT1	Communication commerciale (BUT 1)		en situation de communication de l'offre en tant qu'annonceur\nen situation de communication de l'offre en tant qu'agence de communication	1	Tronc Commun
8	C3-BUT2	Communication commerciale (BUT 2)		en situation de communication de l'offre en tant qu'annonceur\nen situation de communication de l'offre en tant qu'agence de communication	2	Tronc Commun
9	C4-SME-BUT2	Branding (BUT 2)		en situation de promotion de l’identité de marque B to C\nen situation d'animation de l’identité de marque B to B\nen situation de réalisation d'un audit de marque interne et externe	2	SME
10	C4-SME-BUT3	Branding (BUT 3)		en situation de promotion de l’identité de marque B to C\nen situation d'animation de l’identité de marque B to B\nen situation de réalisation d'un audit de marque interne et externe	3	SME
11	C5-SME-BUT2	Evénementiel (BUT 2)		en situation de développement d'un projet événementiel accueillant du public\nen situation de développement d'un projet événementiel interne\nen situation de développement d'un projet événementiel piloté en tant que prestataire	2	SME
12	C5-SME-BUT3	Evénementiel (BUT 3)		en situation de développement d'un projet événementiel accueillant du public\nen situation de développement d'un projet événementiel interne\nen situation de développement d'un projet événementiel piloté en tant que prestataire	3	SME
13	C4-MMPV-BUT2	Management (BUT 2)		en situation de commerce intégré\nen situation de commerce indépendant\nen situation de distribution de services\nen situation de distribution de produits	2	MMPV
14	C4-MMPV-BUT3	Management (BUT 3)		en situation de commerce intégré\nen situation de commerce indépendant\nen situation de distribution de services\nen situation de distribution de produits	3	MMPV
15	C5-MMPV-BUT2	Retail marketing (BUT 2)		en situation de commerce intégré\nen situation de commerce indépendant\nen situation de déploiement de l'activité d'un rayon ou d'un corner\nen situation de déploiement de l'activité d'un magasin	2	MMPV
16	C5-MMPV-BUT3	Retail marketing (BUT 3)		en situation de commerce intégré\nen situation de commerce indépendant\nen situation de déploiement de l'activité d'un rayon ou d'un corner\nen situation de déploiement de l'activité d'un magasin	3	MMPV
17	C4-MDEE-BUT2	Marketing digital (BUT 2)		en situation de déploiement d'une activité digitale en B to C\nen situation de déploiement d'une activité digitale en B to B\nen situation de déploiement d'une activité digitale tournée vers un bien\nen situation de déploiement d'une activité digitale tournée vers un service	2	MDEE
18	C4-MDEE-BUT3	Marketing digital (BUT 3)		en situation de déploiement d'une activité digitale en B to C\nen situation de déploiement d'une activité digitale en B to B\nen situation de déploiement d'une activité digitale tournée vers un bien\nen situation de déploiement d'une activité digitale tournée vers un service	3	MDEE
19	C5-MDEE-BUT2	E-business et entrepreneuriat (BUT 2)		en situation de création d'entreprise\nen situation de développement d'un projet au sein d'une organisation	2	MDEE
20	C5-MDEE-BUT3	E-business et entrepreneuriat (BUT 3)		en situation de création d'entreprise\nen situation de développement d'un projet au sein d'une organisation	3	MDEE
21	C4-BI-BUT2	Stratégie à l'international (BUT 2)		en situation de mise en oeuvre d'une stratégie dans une entreprise de taille PME/PMI\nen situation de mise en oeuvre d'une stratégie dans une grande entreprise\nen situation d'import/export sur la zone Europe\nen situation d'import/export sur la zone Grand-Export	2	BI
22	C4-BI-BUT3	Stratégie à l'international (BUT 3)		en situation de mise en oeuvre d'une stratégie dans une entreprise de taille PME/PMI\nen situation de mise en oeuvre d'une stratégie dans une grande entreprise\nen situation d'import/export sur la zone Europe\nen situation d'import/export sur la zone Grand-Export	3	BI
23	C5-BI-BUT2	Opérations à l'international (BUT 2)		en situation de pilotage des opérations à l'international pour un bien de grande consommation\nen situation de pilotage des opérations à l'international pour un bien de grande industrie\nen situation de pilotage des opérations à l'international pour une activité de services	2	BI
24	C5-BI-BUT3	Opérations à l'international (BUT 3)		en situation de pilotage des opérations à l'international pour un bien de grande consommation\nen situation de pilotage des opérations à l'international pour un bien de grande industrie\nen situation de pilotage des opérations à l'international pour une activité de services	3	BI
25	C4-BDMRC-BUT2	Business développement (BUT 2)		en situation d'activité commerciale en B to B\nen situation d'activité commerciale en B to C	2	BDMRC
26	C4-BDMRC-BUT3	Business développement (BUT 3)		en situation d'activité commerciale en B to B\nen situation d'activité commerciale en B to C	3	BDMRC
27	C5-BDMRC-BUT2	Relation client (BUT 2)		en situation d'activité commerciale en B to B\nen situation d'activité commerciale en B to C	2	BDMRC
28	C5-BDMRC-BUT3	Relation client (BUT 3)		en situation d'activité commerciale en B to B\nen situation d'activité commerciale en B to C	3	BDMRC
\.


--
-- Data for Name: essentialcomponent; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.essentialcomponent (id, code, label, level, pathway, competency_id) FROM stdin;
1	CE1.1	en analysant avec des outils pertinents les contextes économiques, juridiques, commerciaux et financiers	1	Tronc Commun	1
2	CE1.2	en évaluant de manière adaptée les principaux acteurs de l’offre sur le marché	1	Tronc Commun	1
3	CE1.3	en quantifiant la demande et en appréciant le comportement du consommateur	1	Tronc Commun	1
4	CE1.4	en analysant avec les outils appropriés les compétences et les ressources de l'entreprise	1	Tronc Commun	1
5	CE1.5	en élaborant un mix adapté à la cible et positionné par rapport aux concurrents	1	Tronc Commun	1
6	CE1.6	en adoptant une posture citoyenne, éthique et écologique	1	Tronc Commun	1
7	CE1.1	en analysant avec des outils pertinents les contextes économiques, juridiques, commerciaux et financiers	2	Tronc Commun	2
8	CE1.2	en évaluant de manière adaptée les principaux acteurs de l’offre sur le marché	2	Tronc Commun	2
9	CE1.3	en quantifiant la demande et en appréciant le comportement du consommateur	2	Tronc Commun	2
10	CE1.4	en analysant avec les outils appropriés les compétences et les ressources de l'entreprise	2	Tronc Commun	2
11	CE1.5	en élaborant un mix adapté à la cible et positionné par rapport aux concurrents	2	Tronc Commun	2
12	CE1.6	en adoptant une posture citoyenne, éthique et écologique	2	Tronc Commun	2
13	CE1.1	en analysant avec des outils pertinents les contextes économiques, juridiques, commerciaux et financiers	3	Tronc Commun	3
14	CE1.2	en évaluant de manière adaptée les principaux acteurs de l’offre sur le marché	3	Tronc Commun	3
15	CE1.3	en quantifiant la demande et en appréciant le comportement du consommateur	3	Tronc Commun	3
16	CE1.4	en analysant avec les outils appropriés les compétences et les ressources de l'entreprise	3	Tronc Commun	3
17	CE1.5	en élaborant un mix adapté à la cible et positionné par rapport aux concurrents	3	Tronc Commun	3
18	CE1.6	en adoptant une posture citoyenne, éthique et écologique	3	Tronc Commun	3
19	CE2.1	en respectant l’ordre des étapes de la négociation commerciale et une démarche éthique	1	Tronc Commun	4
20	CE2.2	en élaborant les documents commerciaux adaptés	1	Tronc Commun	4
21	CE2.3	en utilisant de façon efficace des indicateurs de performance	1	Tronc Commun	4
22	CE2.4	en prospectant à l'aide d'outils adaptés	1	Tronc Commun	4
23	CE2.5	en adaptant sa communication verbale et non verbale	1	Tronc Commun	4
24	CE2.1	en respectant l’ordre des étapes de la négociation commerciale et une démarche éthique	2	Tronc Commun	5
25	CE2.2	en élaborant les documents commerciaux adaptés	2	Tronc Commun	5
26	CE2.3	en utilisant de façon efficace des indicateurs de performance	2	Tronc Commun	5
27	CE2.4	en prospectant à l'aide d'outils adaptés	2	Tronc Commun	5
28	CE2.5	en adaptant sa communication verbale et non verbale	2	Tronc Commun	5
29	CE2.1	en respectant l’ordre des étapes de la négociation commerciale et une démarche éthique	3	Tronc Commun	6
30	CE2.2	en élaborant les documents commerciaux adaptés	3	Tronc Commun	6
31	CE2.3	en utilisant de façon efficace des indicateurs de performance	3	Tronc Commun	6
32	CE2.4	en prospectant à l'aide d'outils adaptés	3	Tronc Commun	6
33	CE2.5	en adaptant sa communication verbale et non verbale	3	Tronc Commun	6
34	CE3.1	en élaborant une stratégie de communication en cohérence avec le mix	1	Tronc Commun	7
35	CE3.2	en utilisant les outils de la communication commerciale adaptés	1	Tronc Commun	7
36	CE3.3	en produisant des supports de communication efficaces et qualitatifs	1	Tronc Commun	7
37	CE3.4	en respectant la réglementation en vigueur	1	Tronc Commun	7
38	CE3.1	en élaborant une stratégie de communication en cohérence avec le mix	2	Tronc Commun	8
39	CE3.2	en utilisant les outils de la communication commerciale adaptés	2	Tronc Commun	8
40	CE3.3	en produisant des supports de communication efficaces et qualitatifs	2	Tronc Commun	8
41	CE3.4	en respectant la réglementation en vigueur	2	Tronc Commun	8
42	CE4.1	en analysant de manière pertinente l'image et les territoires de la marque	2	SME	9
43	CE4.2	en déterminant judicieusement les valeurs et composantes essentielles de la marque	2	SME	9
44	CE4.3	en mettant en place des actions pour valoriser l'image de marque	2	SME	9
45	CE4.4	en mesurant correctement l'efficacité de la stratégie de marque	2	SME	9
46	CE4.1	en analysant de manière pertinente l'image et les territoires de la marque	3	SME	10
47	CE4.2	en déterminant judicieusement les valeurs et composantes essentielles de la marque	3	SME	10
48	CE4.3	en mettant en place des actions pour valoriser l'image de marque	3	SME	10
49	CE4.4	en mesurant correctement l'efficacité de la stratégie de marque	3	SME	10
50	CE5.1	en s'adaptant aux besoins du commanditaire de manière optimale	2	SME	11
51	CE5.2	en utilisant efficacement les outils de gestion de projet et de management d'équipe	2	SME	11
52	CE5.3	en mettant en oeuvre des outils de communication et de commercialisation adaptés	2	SME	11
53	CE5.4	en respectant les contraintes juridiques, budgétaires et logistiques	2	SME	11
54	CE5.1	en s'adaptant aux besoins du commanditaire de manière optimale	3	SME	12
55	CE5.2	en utilisant efficacement les outils de gestion de projet et de management d'équipe	3	SME	12
56	CE5.3	en mettant en oeuvre des outils de communication et de commercialisation adaptés	3	SME	12
57	CE5.4	en respectant les contraintes juridiques, budgétaires et logistiques	3	SME	12
58	CE4.1	en veillant à l'atteinte des objectifs commerciaux par l'équipe	2	MMPV	13
59	CE4.2	en animant l'équipe commerciale par la valorisation des compétences	2	MMPV	13
60	CE4.3	en favorisant l'adhésion à la culture d'entreprise	2	MMPV	13
61	CE4.1	en veillant à l'atteinte des objectifs commerciaux par l'équipe	3	MMPV	14
62	CE4.2	en animant l'équipe commerciale par la valorisation des compétences	3	MMPV	14
63	CE4.3	en favorisant l'adhésion à la culture d'entreprise	3	MMPV	14
64	CE5.1	en appréhendant l'environnement commercial pour en dégager les spécificités	2	MMPV	15
65	CE5.2	en pilotant la relation avec les fournisseurs et le réseau	2	MMPV	15
66	CE5.3	en développant l'attractivité commerciale de l'espace de vente	2	MMPV	15
67	CE5.4	en enrichissant l'expérience client par la mesure de la satisfaction client	2	MMPV	15
68	CE5.1	en appréhendant l'environnement commercial pour en dégager les spécificités	3	MMPV	16
69	CE5.2	en pilotant la relation avec les fournisseurs et le réseau	3	MMPV	16
70	CE5.3	en développant l'attractivité commerciale de l'espace de vente	3	MMPV	16
71	CE5.4	en enrichissant l'expérience client par la mesure de la satisfaction client	3	MMPV	16
72	CE4.1	en sélectionnant les outils pertinents de recueil, traitement et analyse des données de masse	2	MDEE	17
73	CE4.2	en développant une stratégie marketing digitale performante	2	MDEE	17
74	CE4.3	en pilotant efficacement une offre digitale	2	MDEE	17
75	CE4.4	en optimisant la relation client digitalisée	2	MDEE	17
76	CE4.5	en assurant une logistique performante du e-commerce	2	MDEE	17
77	CE4.1	en sélectionnant les outils pertinents de recueil, traitement et analyse des données de masse	3	MDEE	18
78	CE4.2	en développant une stratégie marketing digitale performante	3	MDEE	18
79	CE4.3	en pilotant efficacement une offre digitale	3	MDEE	18
80	CE4.4	en optimisant la relation client digitalisée	3	MDEE	18
81	CE4.5	en assurant une logistique performante du e-commerce	3	MDEE	18
82	CE5.1	en élaborant le document du modèle d'affaires décrivant la création et le partage de la valeur	2	MDEE	19
83	CE5.2	en développant une vision stratégique partagée	2	MDEE	19
84	CE5.3	en analysant de façon pertinente des documents et indicateurs financiers	2	MDEE	19
85	CE5.4	en analysant d'un point de vue quantitatif et qualitatif les environnements spécifiques	2	MDEE	19
86	CE5.5	en mobilisant des techniques adéquates pour passer de la créativité à l'innovation	2	MDEE	19
87	CE5.6	en s'intégrant activement dans un projet collectif	2	MDEE	19
88	CE5.1	en élaborant le document du modèle d'affaires décrivant la création et le partage de la valeur	3	MDEE	20
89	CE5.2	en développant une vision stratégique partagée	3	MDEE	20
90	CE5.3	en analysant de façon pertinente des documents et indicateurs financiers	3	MDEE	20
91	CE5.4	en analysant d'un point de vue quantitatif et qualitatif les environnements spécifiques	3	MDEE	20
92	CE5.5	en mobilisant des techniques adéquates pour passer de la créativité à l'innovation	3	MDEE	20
93	CE5.6	en s'intégrant activement dans un projet collectif	3	MDEE	20
94	CE4.1	en analysant la capacité de l'entreprise à s'internationaliser	2	BI	21
95	CE4.2	en évaluant l'environnement international	2	BI	21
96	CE4.3	en sélectionnant le ou les marchés les plus performants	2	BI	21
97	CE4.1	...	3	BI	22
98	CE5.1	en utilisant les outils adaptés aux achats à l'international	2	BI	23
99	CE5.2	en adaptant la chaîne logistique	2	BI	23
100	CE5.3	en pilotant des opérations d'import-export	2	BI	23
101	CE5.4	en développant une politique marketing adaptée	2	BI	23
102	CE5.1	...	3	BI	24
103	CE4.1	en identifiant les opportunités de développement	2	BDMRC	25
104	CE4.2	en manageant efficacement les équipes commerciales	2	BDMRC	25
105	CE4.3	en élaborant une offre adaptée au contexte sectoriel	2	BDMRC	25
106	CE4.1	...	3	BDMRC	26
107	CE5.1	Manager la relation client en développant une culture partagée de service client	2	BDMRC	27
108	CE5.2	en pilotant la satisfaction et l'expérience client	2	BDMRC	27
109	CE5.3	en valorisant le portefeuille client	2	BDMRC	27
110	CE5.1	...	3	BDMRC	28
\.


--
-- Data for Name: evaluationrubric; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.evaluationrubric (id, activity_id, name, total_points, academic_year) FROM stdin;
10	5	Nouvelle Grillerrt	20	2025-2026
11	1	2026 ind	20	2025-2026
12	34	2026--groupe	20	2025-2026
\.


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public."group" (id, name, year, pathway, formation_type, academic_year) FROM stdin;
1	Enseignants	0	Staff	N/A	2025-2026
59	Groupe 5 BUT1 FI	1	Tronc Commun	FI	2025-2026
60	Groupe 3 BUT1 FI	1	Tronc Commun	FI	2025-2026
61	Groupe 2 BUT1 FI	1	Tronc Commun	FI	2025-2026
62	Groupe 1 BUT1 FI	1	Tronc Commun	FI	2025-2026
63	Groupe 4 BUT1 FI	1	Tronc Commun	FI	2025-2026
64	Démission BUT1 FI	1	Tronc Commun	FI	2025-2026
66	Groupe 2 BUT3 FI	3	Tronc Commun	FI	2025-2026
67	Groupe 3 BUT3 FI	3	Tronc Commun	FI	2025-2026
68	Groupe 1 BUT3 FI	3	Tronc Commun	FI	2025-2026
69	Gr. étrangers BUT3 FI	3	Tronc Commun	FI	2025-2026
71	groupe 1 BUT2 FI	2	Tronc Commun	FI	2025-2026
72	groupe 2 BUT2 FI	2	Tronc Commun	FI	2025-2026
73	groupe 3 BUT2 FI	2	Tronc Commun	FI	2025-2026
74	Gr Etranger BUT2 FI	2	Tronc Commun	FI	2025-2026
76	Global BUT2 FA	2	Tronc Commun	FA	2025-2026
77	Global BUT3 FA	3	Tronc Commun	FA	2025-2026
78	Groupe 1 BUT3 FA	3	Tronc Commun	FA	2025-2026
79	Groupe 2 BUT3 FA	3	Tronc Commun	FA	2025-2026
81	Demo BUT2 MDEE	2	MDEE	FI	2025-2026
\.


--
-- Data for Name: internship; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.internship (id, student_uid, academic_year, start_date, end_date, company_name, company_address, company_phone, company_email, supervisor_name, supervisor_phone, supervisor_email, company_id, is_active, is_finalized, evaluation_token, token_expires_at) FROM stdin;
1	pytels	2025-2026	\N	\N	a	4 Rue du Maulévrier	0770052646	aaa@aaaa.fr	tom cruise	01 02 03 04 05	tomtom@for.ever	\N	t	f	\N	\N
5	tc	2025-2026	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	\N	\N
\.


--
-- Data for Name: internshipapplication; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.internshipapplication (id, student_uid, company_name, position_title, status, applied_at, interview_at, notes, url, sort_order) FROM stdin;
1	tc	MECASPORT	Alternant en communication digitale	INTERVIEW	2026-01-30 19:41:59.574064	\N	Source: LBA (Alternance) - SAINT-JEAN-DU-CARDONNAY	\N	0
\.


--
-- Data for Name: internshipevaluation; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.internshipevaluation (id, internship_id, evaluator_role, criterion_id, score, comment, updated_at) FROM stdin;
\.


--
-- Data for Name: internshipvisit; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.internshipvisit (id, internship_id, date, type, report_content) FROM stdin;
\.


--
-- Data for Name: learningoutcome; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.learningoutcome (id, code, label, description, level, pathway, competency_id) FROM stdin;
87	AC25.05MDEE	Utiliser les techniques de créativité individuelle et collective		2	MDEE	19
88	AC25.06MDEE	Contribuer à l'enrichissement d'un projet collectif		2	MDEE	19
111	AC24.03BDMRC	Travailler en équipe tout en respectant le rôle de chacun		2	BDMRC	25
112	AC24.04BDMRC	Adapter l'offre à une demande client		2	BDMRC	25
116	AC25.01BDMRC	Intégrer la satisfaction client dans la réussite de la relation commerciale		2	BDMRC	27
117	AC25.02BDMRC	Piloter sa relation client au moyen d'indicateurs		2	BDMRC	27
118	AC25.03BDMRC	Traiter les réclamations client pour optimiser l'activité		2	BDMRC	27
119	AC25.04BDMRC	Exploiter de façon pertinente les outils de la relation client		2	BDMRC	27
38	AC24.03SME	Développer la communication de marque et le marketing de contenu		2	SME	9
54	AC24.01MMPV	Analyser les indicateurs de performances commerciales		2	MMPV	13
73	AC24.01MDEE	Mobiliser des indicateurs de performance en fonction du volume et de la variété des données		2	MDEE	17
109	AC24.01BDMRC	Réaliser un diagnostic avant la mise en place d'actions commerciales		2	BDMRC	25
32	AC23.01	Élaborer une stratégie de communication adaptée au brief agence		2	Tronc Commun	8
74	AC24.02MDEE	Identifier les spécifités du marketing digital		2	MDEE	17
75	AC24.03MDEE	Utiliser un cahier des charges e-business		2	MDEE	17
76	AC24.04MDEE	Intégrer les spécificités du e-commerce		2	MDEE	17
5	AC21.01	Diagnostiquer l'environnement en appréhendant les enjeux sociaux et écologiques		2	Tronc Commun	2
6	AC21.02	Mettre en oeuvre une étude de marché dans un environnement complexe		2	Tronc Commun	2
7	AC21.03	Mettre en place une stratégie marketing dans un environnement complexe		2	Tronc Commun	2
8	AC21.04	Concevoir un mix étendu pour une offre complexe		2	Tronc Commun	2
20	AC22.02	Négocier le prix : défendre, valoriser l'offre		2	Tronc Commun	5
55	AC24.02MMPV	Communiquer sur les objectifs et les résultats efficacement et professionnellement		2	MMPV	13
64	AC25.03MMPV	Agencer l'offre sur l'espace de vente en utilisant les techniques de merchandising		2	MMPV	15
65	AC25.04MMPV	Personnaliser la relation client en appliquant les principes de base de la GRC		2	MMPV	15
66	AC25.05MMPV	Gérer la diversité des points de contact avec le client		2	MMPV	15
36	AC24.01SME	Identifier les valeurs et territoires de la marque		2	SME	9
37	AC24.02SME	Mesurer la visibilité de la marque et sa notoriété		2	SME	9
47	AC25.04SME	Piloter le projet		2	SME	11
1	AC11.01	Analyser l'environnement d'une entreprise en repérant et appréciant les sources d'informations	Au niveau 1 (niveau découverte), l'étudiant doit être capable de transformer une analyse d’environnement simple en repérant des sources d’information fiables. L'objectif est de comprendre le marché pour permettre, par la suite, de choisir une cible pertinente.\n\n### Ressources mobilisées (Cours)\n• R1.01 : Fondamentaux du marketing et comportement du consommateur.\n• R1.04 : Études marketing 1.\n• R1.05 : Environnement économique de l'entreprise.\n• R1.06 : Environnement juridique de l'entreprise.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.01 : "Marketing : positionnement d'une offre simple sur un marché".\n\n### Critères d'évaluation\n• Évaluer de manière adaptée les principaux acteurs de l'offre.\n• Quantifier la demande.\n• Adopter une démarche éthique et rigoureuse.\n\nEn résumé, l'AC11.01 apprend à l'étudiant à ne pas se fier à des intuitions mais à des données vérifiées.	1	Tronc Commun	1
2	AC11.02	Mettre en oeuvre une étude de marché dans un environnement simple	Au niveau 1, l'étudiant apprend à collecter des données primaires et secondaires pour mesurer un marché de manière quantitative et qualitative. Il s'agit de poser les bases méthodologiques de la recherche marketing.\n\n### Ressources mobilisées (Cours)\n• R1.04 : Études marketing 1.\n• R1.07 : Techniques quantitatives et représentations 1.\n• R1.08 : Éléments financiers de l'entreprise.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.01 : "Marketing : positionnement d'une offre simple sur un marché".\n\n### Critères d'évaluation\n• Utilisation d'outils de recueil de données adaptés.\n• Rigueur dans le traitement des informations chiffrées.\n• Capacité à synthétiser les résultats de l'étude.\n\nEn résumé, l'AC11.02 permet de valider la réalité d'un marché par des preuves tangibles et chiffrées.	1	Tronc Commun	1
3	AC11.03	Choisir une cible et un positionnement en fonction de la segmentation du marché	Au niveau 1, l'étudiant doit savoir découper un marché en segments homogènes et sélectionner celui qui offre le meilleur potentiel pour une offre simple. Il doit définir l'image que l'offre doit avoir dans l'esprit du consommateur.\n\n### Ressources mobilisées (Cours)\n• R1.01 : Fondamentaux du marketing et comportement du consommateur.\n• R1.14 : Expression, communication et culture 1.\n• R1.09 : Rôle et organisation de l'entreprise sur son marché.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.01 : "Marketing : positionnement d'une offre simple sur un marché".\n\n### Critères d'évaluation\n• Pertinence du choix du segment visé.\n• Cohérence entre la cible choisie et l'avantage concurrentiel proposé.\n• Clarté de la différenciation par rapport aux concurrents.\n\nEn résumé, l'AC11.03 apprend à l'étudiant à ne pas s'adresser à tout le monde mais à une cible précise avec un message clair.	1	Tronc Commun	1
4	AC11.04	Concevoir une offre cohérente et éthique en termes de produits, de prix, de distribution et de communication	Au niveau 1, l'étudiant élabore son premier "Marketing Mix" (les 4P) pour un produit ou service simple. L'accent est mis sur la cohérence entre les quatre variables et le respect des normes éthiques et écologiques.\n\n### Ressources mobilisées (Cours)\n• R1.01 : Fondamentaux du marketing.\n• R1.02 : Fondamentaux de la vente.\n• R1.03 : Fondamentaux de la communication commerciale.\n• R1.08 : Éléments financiers de l'entreprise.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.01 : "Marketing : positionnement d'une offre simple sur un marché".\n\n### Critères d'évaluation\n• Cohérence globale des variables du mix.\n• Justification du prix de vente selon les coûts et le marché.\n• Intégration d'une posture citoyenne et éthique dans l'offre.\n\nEn résumé, l'AC11.04 concrétise la stratégie marketing en une offre commerciale réelle et responsable.	1	Tronc Commun	1
9	AC31.01	Mettre en place des outils de veille pour anticiper les évolutions de l'environnement	Au niveau 3, l étudiant doit être capable de : Mettre en place des outils de veille pour anticiper les évolutions de l'environnement.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	Tronc Commun	3
10	AC31.02	Élaborer une stratégie marketing dans un environnement instable	Au niveau 3, l étudiant doit être capable de : Élaborer une stratégie marketing dans un environnement instable.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	Tronc Commun	3
11	AC31.03	Faire évoluer l'offre à l'aide de leviers de création de valeur	Au niveau 3, l étudiant doit être capable de : Faire évoluer l'offre à l'aide de leviers de création de valeur.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	Tronc Commun	3
12	AC31.04	Intégrer la RSE dans la stratégie de l'offre	Au niveau 3, l étudiant doit être capable de : Intégrer la RSE dans la stratégie de l'offre.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	Tronc Commun	3
13	AC12.01	Préparer un plan de découverte qui permette de profiler le client	Au niveau 1, l'étudiant apprend à préparer la phase de découverte d'un entretien de vente. Il doit structurer ses questions pour identifier les besoins et motivations du client.\n\n### Ressources mobilisées (Cours)\n• R1.02 : Fondamentaux de la vente et négociation.\n• R1.14 : Expression, communication et culture 1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : "Vente : démarche de prospection".\n\n### Critères d'évaluation\n• Qualité et pertinence du questionnement préparé.\n• Capacité à profiler le prospect de manière structurée.\n\nEn résumé, l'AC12.01 enseigne que pour bien vendre, il faut d'abord savoir écouter et comprendre.	1	Tronc Commun	4
14	AC12.02	Concevoir un argumentaire de vente adapté	Au niveau 1, l'étudiant doit transformer les caractéristiques d'un produit en avantages personnalisés pour le client. L'argumentaire doit répondre directement aux besoins identifiés lors de la découverte.\n\n### Ressources mobilisées (Cours)\n• R1.02 : Fondamentaux de la vente.\n• R1.14 : Expression, communication et culture 1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : "Vente : démarche de prospection".\n\n### Critères d'évaluation\n• Adaptation des arguments aux motivations du client.\n• Clarté et conviction de l'expression orale.\n\nEn résumé, l'AC12.02 apprend à l'étudiant à proposer la bonne solution au bon client au moyen d'un discours structuré.	1	Tronc Commun	4
15	AC12.03	Concevoir des OAV efficaces	Au niveau 1, l'étudiant doit être capable de produire les supports physiques ou numériques nécessaires pour soutenir son argumentation lors d'une vente simple. Il s'agit de rendre l'offre tangible et compréhensible pour le prospect.\n\n### Ressources mobilisées (Cours)\n• R1.02 : Fondamentaux de la vente.\n• R1.13 : Ressources et culture numériques 1 (outils de mise en forme).\n• R1.03 : Fondamentaux de la communication commerciale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : "Vente : démarche de prospection".\n\n### Critères d'évaluation\n• Élaboration de documents commerciaux adaptés à la situation.\n• Respect de la réglementation en vigueur sur les documents.\n• Clarté et aspect professionnel des supports produits.\n\nEn résumé, l'AC12.03 consiste à créer les "armes" du vendeur (fiches produits, visuels) pour convaincre plus facilement.	1	Tronc Commun	4
16	AC12.04	Évaluer la performance commerciale au moyen d'indicateurs	L'objectif au niveau 1 est d'initier l'étudiant à la culture du résultat. Il doit être capable de mesurer l'efficacité de ses actions de prospection ou de vente en utilisant des chiffres clés.\n\n### Ressources mobilisées (Cours)\n• R1.07 : Techniques quantitatives et représentations 1 (Statistiques).\n• R1.08 : Éléments financiers de l'entreprise.\n• R1.15 : Projet Personnel et Professionnel 1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : "Vente : démarche de prospection".\n\n### Critères d'évaluation\n• Utilisation efficace des indicateurs de performance fixés par l'organisation.\n• Rigueur dans le calcul des taux (ex: taux de transformation, taux de remontée).\n• Capacité à interpréter simplement les résultats obtenus.\n\nEn résumé, l'AC12.04 apprend à l'étudiant que l'efficacité commerciale se prouve par les chiffres.	1	Tronc Commun	4
17	AC12.05	Recourir aux techniques adaptées à la démarche de prospection	Au niveau 1, l'étudiant apprend à identifier et contacter des clients potentiels. Il doit savoir utiliser les canaux de contact de base (téléphone, mail, face-à-face) pour obtenir un rendez-vous ou une information.\n\n### Ressources mobilisées (Cours)\n• R1.02 : Fondamentaux de la vente et négociation.\n• R1.13 : Ressources et culture numériques 1 (fichiers clients, CRM).\n• R1.10 : Initiation à la conduite de projet.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : "Vente : démarche de prospection".\n\n### Critères d'évaluation\n• Prospection à l'aide d'outils et de méthodes adaptés.\n• Organisation rigoureuse de la recherche de prospects.\n• Persévérance et éthique dans la prise de contact.\n\nEn résumé, l'AC12.05 est la première étape du cycle de vente : trouver le client là où il se trouve.	1	Tronc Commun	4
18	AC12.06	Recourir aux codes d'expression spécifiques et professionnels	Au niveau 1, l'accent est mis sur la posture. L'étudiant doit maîtriser son langage (verbal) et son attitude (non-verbal) pour instaurer une relation de confiance avec le client.\n\n### Ressources mobilisées (Cours)\n• R1.14 : Expression, communication et culture 1.\n• R1.02 : Fondamentaux de la vente.\n• R1.15 : Projet Personnel et Professionnel 1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : "Vente : démarche de prospection".\n\n### Critères d'évaluation\n• Adaptation de la communication verbale et non-verbale à la situation.\n• Maîtrise du vocabulaire professionnel du secteur.\n• Respect des codes de courtoisie et d'écoute active.\n\nEn résumé, l'AC12.06 apprend à l'étudiant à "être" un professionnel crédible face à un client.	1	Tronc Commun	4
19	AC22.01	Convaincre en exprimant avec empathie l’offre		2	Tronc Commun	5
21	AC22.03	Maîtriser les éléments juridiques et comptables de l'offre		2	Tronc Commun	5
22	AC22.04	Utiliser les OAV à bon escient pour convaincre		2	Tronc Commun	5
23	AC22.05	Organiser le suivi de ses résultats		2	Tronc Commun	5
24	AC22.06	Prendre en compte les enjeux de la fonction achat		2	Tronc Commun	5
25	AC32.01	Identifier les techniques d’achat employées par un acheteur professionnel	Au niveau 3, l étudiant doit être capable de : Identifier les techniques d’achat employées par un acheteur professionnel.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	Tronc Commun	6
26	AC32.02	Élaborer des outils de gestion et de calcul efficaces pour la vente complexe	Au niveau 3, l étudiant doit être capable de : Élaborer des outils de gestion et de calcul efficaces pour la vente complexe.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	Tronc Commun	6
27	AC32.03	Maîtriser les codes propres à l'univers spécifique rencontré	Au niveau 3, l étudiant doit être capable de : Maîtriser les codes propres à l'univers spécifique rencontré.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	Tronc Commun	6
28	AC13.01	Identifier les cibles et objectifs de communication	Au niveau 1, l'étudiant définit à qui il doit parler (cible de communication) et quel message il veut transmettre (objectif). Cette action doit être alignée avec la stratégie marketing globale.\n\n### Ressources mobilisées (Cours)\n• R1.03 : Fondamentaux de la communication commerciale.\n• R1.01 : Fondamentaux du marketing.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.03 : "Communication commerciale : création d'un support print".\n\n### Critères d'évaluation\n• Précision de l'identification des cibles.\n• Cohérence du message avec le positionnement du produit.\n\nEn résumé, l'AC13.01 pose les bases stratégiques de toute action de communication réussie.	1	Tronc Commun	7
29	AC13.02	Analyser de manière pertinente les moyens de communication	Au niveau 1, l'étudiant doit comprendre les différents canaux disponibles pour diffuser un message et savoir pourquoi l'un est plus adapté qu'un autre pour une offre simple.\n\n### Ressources mobilisées (Cours)\n• R1.03 : Fondamentaux de la communication commerciale.\n• R1.13 : Ressources et culture numériques 1.\n• R1.06 : Environnement juridique (Droit de la publicité).\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.03 : "Communication commerciale : création d'un support print".\n\n### Critères d'évaluation\n• Pertinence du choix des supports par rapport à la cible.\n• Utilisation des outils adaptés à la demande et aux contraintes.\n• Capacité à justifier le mix-communication (choix des canaux).\n\nEn résumé, l'AC13.02 permet de choisir le meilleur "haut-parleur" pour que le message atteigne sa cible.	1	Tronc Commun	7
30	AC13.03	Élaborer des supports simples (ISA, affiches...)	Au niveau 1, l'étudiant passe à la création concrète en produisant des supports de communication visuelle ou écrite de qualité. Il doit maîtriser les outils de mise en page de base.\n\n### Ressources mobilisées (Cours)\n• R1.03 : Fondamentaux de la communication commerciale.\n• R1.13 : Ressources et culture numériques 1 (PAO).\n• R1.06 : Environnement juridique (droit d'auteur).\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.03 : "Communication commerciale : création d'un support print".\n\n### Critères d'évaluation\n• Qualité graphique et rédactionnelle du support.\n• Respect de la réglementation en vigueur (mentions obligatoires, droits).\n\nEn résumé, l'AC13.03 apprend à traduire une idée stratégique en un objet visuel percutant et professionnel.	1	Tronc Commun	7
31	AC13.04	Analyser les indicateurs post campagne	Au niveau 1, l'étudiant doit être capable de porter un regard critique sur le support de communication qu'il a produit. Il doit vérifier si le message a été reçu et s'il a eu l'effet escompté.\n\n### Ressources mobilisées (Cours)\n• R1.03 : Fondamentaux de la communication commerciale.\n• R1.07 : Techniques quantitatives (Statistiques de base).\n• R1.10 : Initiation à la conduite de projet.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.03 : "Communication commerciale : création d'un support print".\n\n### Critères d'évaluation\n• Pertinence de l'analyse des résultats (score de mémorisation, retours clients).\n• Rigueur dans l'utilisation des indicateurs d'efficacité.\n• Démarche réflexive sur les améliorations possibles.\n\nEn résumé, l'AC13.04 conclut l'action de communication en mesurant si l'investissement a été utile.	1	Tronc Commun	7
33	AC23.02	Établir une stratégie de moyens en utilisant les indicateurs de choix des supports		2	Tronc Commun	8
34	AC23.03	Proposer un plan de com 360° en élaborant les supports		2	Tronc Commun	8
35	AC23.04	Mettre en œuvre une stratégie digitale		2	Tronc Commun	8
39	AC24.04SME	Piloter les relations publiques et les relations presse en veillant aux différentes parutions de la marque		2	SME	9
40	AC34.01SME	Déterminer les attributs et territoires de la marque	Au niveau 3, l étudiant doit être capable de : Déterminer les attributs et territoires de la marque.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	10
41	AC34.02SME	Elaborer une idéologie de marque et ses composantes	Au niveau 3, l étudiant doit être capable de : Elaborer une idéologie de marque et ses composantes.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	10
42	AC34.03SME	Construire l'identité de la marque	Au niveau 3, l étudiant doit être capable de : Construire l'identité de la marque.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	10
43	AC34.04SME	Développer la communauté de marque et l'adhésion	Au niveau 3, l étudiant doit être capable de : Développer la communauté de marque et l'adhésion.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	10
44	AC25.01SME	Elaborer un projet événementiel simple répondant à la demande		2	SME	11
45	AC25.02SME	Intégrer les contraintes financières, juridiques et logistiques		2	SME	11
46	AC25.03SME	Gérer la communication et la commercialisation de l'événement		2	SME	11
48	AC25.05SME	Mesurer l'impact de l'événement		2	SME	11
49	AC35.01SME	Créer un événement complexe adapté aux attentes du commanditaire	Au niveau 3, l étudiant doit être capable de : Créer un événement complexe adapté aux attentes du commanditaire.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	12
123	AC35.04BDMRC	Faire évoluer les outils de la relation client	Au niveau 3, l étudiant doit être capable de : Faire évoluer les outils de la relation client.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BDMRC	28
50	AC35.02SME	Intégrer les enjeux sécuritaires et reglementaires des événements de grande ampleur	Au niveau 3, l étudiant doit être capable de : Intégrer les enjeux sécuritaires et reglementaires des événements de grande ampleur.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	12
51	AC35.03SME	Rechercher des partenaires et des subventions	Au niveau 3, l étudiant doit être capable de : Rechercher des partenaires et des subventions.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	12
52	AC35.04SME	Gérer des prestataires	Au niveau 3, l étudiant doit être capable de : Gérer des prestataires.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	12
53	AC35.05SME	Manager un évènement complexe	Au niveau 3, l étudiant doit être capable de : Manager un évènement complexe.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	SME	12
56	AC24.03MMPV	Planifier les missions de l'équipe en accord avec la stratégie de l'espace de vente		2	MMPV	13
57	AC34.01MMPV	Fixer les objectifs en accord avec la méthode SMART	Au niveau 3, l étudiant doit être capable de : Fixer les objectifs en accord avec la méthode SMART.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	14
58	AC34.02MMPV	Fédérer les équipes autour de l'atteinte des objectifs	Au niveau 3, l étudiant doit être capable de : Fédérer les équipes autour de l'atteinte des objectifs.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	14
59	AC34.03MMPV	Sélectionner des collaborateurs en considérant les besoins de l'équipe	Au niveau 3, l étudiant doit être capable de : Sélectionner des collaborateurs en considérant les besoins de l'équipe.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	14
60	AC34.04MMPV	Intégrer des collaborateurs à l'équipe	Au niveau 3, l étudiant doit être capable de : Intégrer des collaborateurs à l'équipe.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	14
61	AC34.05MMPV	Valoriser les compétences des membres de l'équipe	Au niveau 3, l étudiant doit être capable de : Valoriser les compétences des membres de l'équipe.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	14
62	AC25.01MMPV	Analyser le secteur et l'environnement concurrentiel		2	MMPV	15
63	AC25.02MMPV	S'approprier la chaîne d'approvisionnement de l'espace de vente		2	MMPV	15
67	AC35.01MMPV	Comprendre les enjeux de la distribution et les évolutions du secteur	Au niveau 3, l étudiant doit être capable de : Comprendre les enjeux de la distribution et les évolutions du secteur.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	16
68	AC35.02MMPV	Elaborer une stratégie commerciale en cohérence avec l'environnement concurrentiel	Au niveau 3, l étudiant doit être capable de : Elaborer une stratégie commerciale en cohérence avec l'environnement concurrentiel.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	16
69	AC35.03MMPV	Gérer la relation avec les fournisseurs ou le réseau	Au niveau 3, l étudiant doit être capable de : Gérer la relation avec les fournisseurs ou le réseau.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	16
70	AC35.04MMPV	Implanter un plan de merchandising	Au niveau 3, l étudiant doit être capable de : Implanter un plan de merchandising.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	16
71	AC35.05MMPV	Optimiser les outils de GRC	Au niveau 3, l étudiant doit être capable de : Optimiser les outils de GRC.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	16
72	AC35.06MMPV	Optimiser le parcours client dans une perspective omnicanale	Au niveau 3, l étudiant doit être capable de : Optimiser le parcours client dans une perspective omnicanale.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MMPV	16
77	AC24.05MDEE	Respecter le processus logistique		2	MDEE	17
78	AC34.01MDEE	Exploiter les données de masse en mobilisant les bons outils de traitement de l'information	Au niveau 3, l étudiant doit être capable de : Exploiter les données de masse en mobilisant les bons outils de traitement de l'information.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	18
79	AC34.02MDEE	Mettre en oeuvre des spécificités du marketing digital	Au niveau 3, l étudiant doit être capable de : Mettre en oeuvre des spécificités du marketing digital.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	18
80	AC34.03MDEE	Elaborer un cahier des charges e-business	Au niveau 3, l étudiant doit être capable de : Elaborer un cahier des charges e-business.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	18
81	AC34.04MDEE	S'appuyer sur les indicateurs de performances pour améliorer la relation client	Au niveau 3, l étudiant doit être capable de : S'appuyer sur les indicateurs de performances pour améliorer la relation client.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	18
82	AC34.05MDEE	Proposer des solutions adaptées aux spécificités de la chaine logistique du e-commerce	Au niveau 3, l étudiant doit être capable de : Proposer des solutions adaptées aux spécificités de la chaine logistique du e-commerce.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	18
83	AC25.01MDEE	Concevoir un modèle d'affaires simplifié		2	MDEE	19
84	AC25.02MDEE	Analyser de façon pertinente la situation marché-entreprise grâce aux outils de diagnostic stratégique		2	MDEE	19
85	AC25.03MDEE	Analyser la situation financière d'une entreprise à partir des éléments de la comptabillité générale		2	MDEE	19
86	AC25.04MDEE	Identifier les éléments pertinents nécessaires à la réalisation du projet		2	MDEE	19
89	AC35.01MDEE	Concevoir un modèle d'affaires complet incluant les sources de valeur, les parties prenantes et les externalités	Au niveau 3, l étudiant doit être capable de : Concevoir un modèle d'affaires complet incluant les sources de valeur, les parties prenantes et les externalités.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	20
90	AC35.02MDEE	Faire des préconisations grâce aux outils du diagnostic stratégique	Au niveau 3, l étudiant doit être capable de : Faire des préconisations grâce aux outils du diagnostic stratégique.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	20
91	AC35.03MDEE	Elaborer les documents financiers nécessaires en tant que concepteur du business model	Au niveau 3, l étudiant doit être capable de : Elaborer les documents financiers nécessaires en tant que concepteur du business model.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	20
92	AC35.04MDEE	Contrôler la conformité et la pertinence du modèle	Au niveau 3, l étudiant doit être capable de : Contrôler la conformité et la pertinence du modèle.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	20
93	AC35.05MDEE	Choisir les techniques de créativité individuelle et collective adaptées	Au niveau 3, l étudiant doit être capable de : Choisir les techniques de créativité individuelle et collective adaptées.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	20
94	AC35.06MDEE	Développer un projet de façon proactive	Au niveau 3, l étudiant doit être capable de : Développer un projet de façon proactive.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	MDEE	20
95	AC24.01BI	Réaliser de manière structurée un diagnostic export/import à l'aide d'outils stratégiques		2	BI	21
96	AC24.02BI	Collecter les informations de l'environnement international		2	BI	21
97	AC24.03BI	Sélectionner les marchés opportuns, à l'export et à l'import à l'aide d'indicateurs		2	BI	21
98	AC34.01BI	Evaluer le diagnostic export/import et faire des préconisations	Au niveau 3, l étudiant doit être capable de : Evaluer le diagnostic export/import et faire des préconisations.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BI	22
99	AC34.02BI	Evaluer les marchés internationaux en prenant en compte le contexte géo-éco-politique	Au niveau 3, l étudiant doit être capable de : Evaluer les marchés internationaux en prenant en compte le contexte géo-éco-politique.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BI	22
100	AC34.03BI	Proposer le mode d'entrée (filiale, joint venture, etc.) le plus adéquate	Au niveau 3, l étudiant doit être capable de : Proposer le mode d'entrée (filiale, joint venture, etc.) le plus adéquate.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BI	22
101	AC25.01BI	Gérer les processus de vente et d'achat à l'international		2	BI	23
102	AC25.02BI	Suivre les opérations logistiques à l'international		2	BI	23
103	AC25.03BI	Sélectionner le mode de transport, l'incoterm, l'assurance et les modalités de paiement		2	BI	23
104	AC25.04BI	Positionner l'offre en fonction des spécificités culturelles		2	BI	23
105	AC35.01BI	Mobiliser ses connaissances en processus de vente et d'achat dans des situations interculturelles	Au niveau 3, l étudiant doit être capable de : Mobiliser ses connaissances en processus de vente et d'achat dans des situations interculturelles.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BI	24
106	AC35.02BI	Optimiser la chaîne logistique à l'international	Au niveau 3, l étudiant doit être capable de : Optimiser la chaîne logistique à l'international.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BI	24
107	AC35.03BI	Gérer l'administration des ventes/achats à l'international	Au niveau 3, l étudiant doit être capable de : Gérer l'administration des ventes/achats à l'international.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BI	24
108	AC35.04BI	Proposer l'offre marketing adaptée au(x) marché(s) ciblé(s)	Au niveau 3, l étudiant doit être capable de : Proposer l'offre marketing adaptée au(x) marché(s) ciblé(s).\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BI	24
110	AC24.02BDMRC	Mesurer l'importance du choix des cibles commerciales		2	BDMRC	25
113	AC34.01BDMRC	Mettre en oeuvre la stratégie marketing et commerciale au sein de l'équipe	Au niveau 3, l étudiant doit être capable de : Mettre en oeuvre la stratégie marketing et commerciale au sein de l'équipe.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BDMRC	26
114	AC34.02BDMRC	Fédérer les équipes autour de la réussite des objectifs marketing et commerciaux	Au niveau 3, l étudiant doit être capable de : Fédérer les équipes autour de la réussite des objectifs marketing et commerciaux.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BDMRC	26
115	AC34.03BDMRC	Co-construire une offre en collaboration avec les parties prenantes concernées	Au niveau 3, l étudiant doit être capable de : Co-construire une offre en collaboration avec les parties prenantes concernées.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BDMRC	26
120	AC35.01BDMRC	Asseoir la réussite de la relation client sur la cohérence globale de l'organisation	Au niveau 3, l étudiant doit être capable de : Asseoir la réussite de la relation client sur la cohérence globale de l'organisation.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BDMRC	28
121	AC35.02BDMRC	Optimiser l'expérience client par la mise en place d'un processus d'amélioration continue	Au niveau 3, l étudiant doit être capable de : Optimiser l'expérience client par la mise en place d'un processus d'amélioration continue.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BDMRC	28
122	AC35.03BDMRC	Contribuer à la diffusion de la culture client au sein de l'organisation	Au niveau 3, l étudiant doit être capable de : Contribuer à la diffusion de la culture client au sein de l'organisation.\n\nCette étape marque l acquisition d une expertise permettant d intervenir dans des contextes commerciaux complexes, instables ou de grande envergure.\n\n### Ressources mobilisées (Cours)\n• Ressources de spécialité du semestre 5 et 6.\n• Mises en pratique professionnelles approfondies.\n\n### Critères d évaluation\n• Pertinence et rigueur de l analyse en contexte complexe.\n• Capacité à proposer des solutions stratégiques innovantes.\n• Autonomie et posture de cadre intermédiaire.	3	BDMRC	28
\.


--
-- Data for Name: portfolioexportconfig; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.portfolioexportconfig (id, student_uid, preamble, selected_pages, include_internships, include_sae, include_radar, theme_color, created_at) FROM stdin;
\.


--
-- Data for Name: portfoliopage; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.portfoliopage (id, student_uid, title, content_json, linked_file_ids, academic_year, year_of_study, is_public, share_token, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: promotionresponsibility; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.promotionresponsibility (id, teacher_uid, group_id, academic_year) FROM stdin;
1	montieca	79	2025-2026
2	montieca	78	2025-2026
3	montieca	77	2025-2026
4	montieca	76	2025-2026
5	khaledz	59	2025-2026
6	khaledz	60	2025-2026
\.


--
-- Data for Name: resource; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.resource (id, code, label, description, content, hours, hours_details, targeted_competencies, pathway, responsible, contributors) FROM stdin;
1	R1.01	Fondamentaux du marketing et comportement du consommateur	Contribution au développement de la ou des compétences ciblées :\n– Utiliser le vocabulaire approprié de la démarche marketing\n– Appréhender l’état d’esprit et la démarche marketing fondée sur les besoins\n– Identiﬁer les étapes de la démarche marketing\n– Analyser correctement le marché dans lequel se situe une offre simple\n– Analyser le comportement du consommateur et les facteurs clés de son processus de décision\n– Connaître et utiliser les méthodes de segmentation, les stratégies de ciblage et de positionnement\n\nMots clés :\nDémarche marketing – analyse de marché – comportement du consommateur – segmentation – ciblage – positionnement	– Démarche marketing et champ d’application\n– Identiﬁcation des acteurs de l’offre, de la demande et les facteurs d’inﬂuence d’un marché\n– Analyse de l’inﬂuence des acteurs sur le marché\n– Connaissance du comportement du consommateur et ses attentes : notion de besoins, modélisation du comportement\ndu consommateur, facteurs explicatifs du comportement, processus de décision et variables clés\n– Identiﬁcation des cibles d’un marché et des critères de segmentation\n– Identiﬁcation des positionnements\n– Choix d’une cible et du positionnement lié	35	35 heures	Conduire les actions marketing	Tronc Commun	\N	\N
2	R1.02	Fondamentaux de la vente	Contribution au développement de la ou des compétences ciblées :\n– Découvrir l’univers de la vente et le métier de commercial\n– Connaître les étapes de l’entretien de vente, savoir les identiﬁer, savoir préparer et réaliser les premières étapes de\nl’entretien\n– Appréhender la démarche, les outils et les techniques de prospection\n\nMots clés :\nPlan de découverte – prospection – phoning – création et qualiﬁcation d’un ﬁchier	Les métiers commerciaux\nLa déontologie et l’éthique dans la relation commerciale\nLes fondamentaux de la négociation commerciale\n– Maîtriser l’information (entreprise, environnement, concurrence, produit)\n– Établir les objectifs de l’entretien de vente\n– Connaître les étapes d’un entretien de vente et leurs objectifs et les pratiquer lors de jeux de rôles (étapes 1 et 2 de\nl’entretien de vente)\n– Préparer la prise de contact\n– Construire un plan de découverte : mener un questionnement (poser des questions ouvertes, fermées, alternatives,\nrebonds), pratiquer l’écoute active, savoir reformuler, savoir repérer les besoins du client et identiﬁer son proﬁl (SONCAS\nentre autres)\nLes bases de la prospection commerciale\n– Comprendre les enjeux de la prospection commerciale (générer des contacts et récupérer des contacts perdus, conqué-\nrir de nouvelles cibles, orienter son développement commercial, s’adapter aux technologies...)\n– Connaître les outils de prospection traditionnels (visites, salons, mailing, téléphone)\n– Créer ou qualiﬁer un ﬁchier de prospection\n– Mener une démarche de prospection téléphonique (gérer la relation commerciale par téléphone / mener une opération\nde phoning, construire un GET / analyser les résultats), notamment grâce à des jeux de rôle de phoning	24	24 heures dont 20 heures de TP	Vendre une offre commerciale	Tronc Commun	\N	\N
3	R1.03	Fondamentaux de la communication commerciale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication commerciale et ses acteurs\n– Élaborer une réﬂexion stratégique simple à partir d’un brief\n– Réaliser des supports de communication commerciale simples\n\nMots clés :\nBrief – cibles et objectifs de communication – acteurs et marché de la communication commerciale – message publicitaire	– Brief, stratégies, objectifs et cibles de la communication commerciale\n– Acteurs de la communication commerciale (agences, régies, organismes de régulation)\n– Panorama des moyens de communication, chiffres, secteurs\n– Bases du message publicitaire : fond / forme (couleurs, formes, contrastes, cohérence)\n– Outils simples de communication « print » : afﬁches, encarts presse, ﬂyers, plaquettes\n– Indicateurs d’analyse de la notoriété et de l’image	18	18 heures	Communiquer l’offre commerciale	Tronc Commun	\N	\N
4	R1.04	Etudes marketing - 1	Contribution au développement de la ou des compétences ciblées :\n– Connaître les typologies d’étude et construire une méthodologie d’étude (cahier des charges)\n– Mener une recherche et une analyse documentaire à l’aide de sources correctement sélectionnées\n– Construire un questionnaire\n\nMots clés :\nEtude de marché – recherche documentaire – cahier des charges – étude quantitative – sondage – panel	– Typologie des études de marché\n– Cahier des charges\n– Analyse et recherche documentaire (repérage des sources d’information, collecte et traitement)\n– Types de sondage\n– Élaboration du questionnaire\n– Plan de sondage, population, échantillonnage	18	18 heures	Conduire les actions marketing, Communiquer l’offre commerciale	Tronc Commun	\N	\N
5	R1.05	Environnement économique de l’entreprise	Contribution au développement de la ou des compétences ciblées :\n– Appréhender les mécanismes économiques fondamentaux qui agissent sur les marchés\n– Percevoir les enjeux des politiques économiques et leur inﬂuence sur un marché simple\n\nMots clés :\nMacroéconomie – microéconomie – politique économique	– Agents économiques, interactions et agrégats économiques (PIB, inﬂation...)\n– Comportement du consommateur et analyse de la demande (notions d’élasticités...), comportement du producteur et\nmaximisation du proﬁt\n– Marchés et conditions de concurrence (CPP, marchés imparfaits...)\n– Notions de politique économique\nApprentissage critique ciblé :\n– AC11.01 | Analyser l’environnement d’une entreprise en repérant et appréciant les sources d’informations (ﬁabilité et\npertinence)	18	18 heures	Conduire les actions marketing	Tronc Commun	\N	\N
6	R1.06	Environnement juridique de l’entreprise	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer les différents acteurs civils et commerciaux, ainsi que l’origine des réglementations pour mesurer les risques\net sécuriser les actions mises en place par l’entreprise\n– Respecter les obligations légales dans la réalisation de documents de communication commerciale\n\nMots clés :\nRéglementation – responsabilité – preuve – propriété intellectuelle – droit à l’image	– Environnement juridique et judiciaire, les acteurs du monde des affaires (les personnes), biens et patrimoine, responsa-\nbilité civile, moyens de preuve\n– Éléments de la propriété intellectuelle (droits d’auteur, charte graphique), droit à l’image	18	18 heures	Conduire les actions marketing, Communiquer l’offre commerciale	Tronc Commun	\N	\N
7	R1.07	Techniques quantitatives et représentations - 1	Contribution au développement de la ou des compétences ciblées :\n– Se familiariser avec les nombres pour maîtriser le calcul mental, maîtriser l’ordre de grandeur des nombres utilisés\n– Maîtriser la cohérence des résultats obtenus\n– Calculer, comprendre, analyser, interpréter des indicateurs pertinents pour évaluer un marché ou une action commer-\nciale\n– Utiliser les statistiques pour représenter une situation commerciale (évolutions, parts de marché, fréquentation d’un site\nInternet, analyse des statistiques des réseaux sociaux...)\n– Percevoir et anticiper les variations d’un marché et de son environnement\n\nMots clés :\nTaux – pourcentage – indice – statistique descriptive – représentation graphique	– Calcul mental et ordre de grandeur\n– Pourcentages, taux de variation, indices, élasticité\n– Statistique descriptive : généralités, séries à un caractère, paramètres de position, de dispersion, de concentration,\nreprésentation graphique\n– Équations, fonctions afﬁnes\nUtilisation d’un tableur conseillée	18	18 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
8	R1.08	Eléments ﬁnanciers de l’entreprise	Contribution au développement de la ou des compétences ciblées :\n– Vériﬁer la cohérence des décisions marketing avec la situation ﬁnancière de l’entreprise\n\nMots clés :\nRentabilité – trésorerie – patrimoine	– Mécanisme de la comptabilité (documents commerciaux, TVA et IS)\n– Compte de résultat : notion de produits et charges, résultat\n– Contenu d’un bilan : actif, passif, rôle des amortissements et des provisions\n– Tableau de trésorerie\n– Distinction entre notions de bénéﬁce et de trésorerie	12	12 heures	Conduire les actions marketing, Vendre une offre commerciale	Tronc Commun	\N	\N
9	R1.09	Rôle et organisation de l’entreprise sur son marché	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer une entreprise et son marché\n– Comprendre la structure organisationnelle d’une entreprise\n– Comprendre la ﬁnalité sociale, sociétale d’une entreprise\n– Comprendre les interactions entre une entreprise et son environnement macroéconomique\n– Identiﬁer les concurrents et comprendre le positionnement d’une entreprise par rapport à ses concurrents\n– Introduction au diagnostic stratégique\n\nMots clés :\nOrganigramme – concurrents – SWOT – PESTEL	– Organigramme et rôle du manager (structure simple, fonctionnelle, divisionnelle, matricielle, par projet)\n– PESTEL\n– Concurrence directe et indirecte, avantage concurrentiel\n– SWOT	12	12 heures	Conduire les actions marketing	Tronc Commun	\N	\N
10	R1.10	Initiation à la conduite de projet	Contribution au développement de la ou des compétences ciblées :\n– Analyser le cahier des charges d’un commanditaire pour comprendre le projet, son environnement et ses objectifs\n– Mettre en place un plan d’actions à partir d’une problématique identiﬁée et d’un cahier des charges construit, organiser\nun travail en groupe\n\nMots clés :\nProjet – organisation – cadrage – outil de conduite de projet – tâche – planiﬁcation	– Déﬁnition des étapes de la conduite de projet : phase de cadrage ou avant-projet avec toutes les analyses préliminaires\n(déﬁnition de la note de cadrage)\n– Déﬁnition de la conception et de la planiﬁcation : constitution de l’équipe, organisation du travail en groupe, répartition\ndes tâches et planiﬁcation\n– Présentation des différents outils de la gestion de projet : carte mentale, priorisation des tâches, matrice des responsa-\nbilités, diagramme de planiﬁcation, outils de travail collaboratif, organisation de réunions	8	8 heures dont 4 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
11	R1.11	Langue A Anglais du commerce - 1	Contribution au développement de la ou des compétences ciblées :\nDévelopper les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n\nMots clés :\nLangue de spécialité – présentation – prospection – communication et marketing en anglais	– Présentation d’une entreprise (points faibles et points forts), présentation de soi\n– Recherche d’informations sur internet, de documentations sur une entreprise ou un produit et présentation à l’oral et à\nl’écrit\n– Traduction d’un questionnaire/une enquête/une interview simple en anglais\n– Prospection au téléphone et prise des RDV\n– Rédaction et utilisation de questions pour connaître les besoins du client\n– Description d’un support de communication commerciale (publicité) dans sa dimension culturelle, présentation d’un brief\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire basique général de l’entreprise, de la communication commerciale et du marketing et le restituer\ndans une situation professionnelle spéciﬁque\n– Mobiliser les connecteurs logiques pour l’argumentation	20	20 heures dont 12 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
17	R2.02	Prospection et négociation	Contribution au développement de la ou des compétences ciblées :\n– Connaître la prospection digitale\n– Préparer et mener les étapes d’argumentation, de traitement des objections client, de conclusion et de prise de congé\n– Réaliser des OAV pertinents et efﬁcaces\n\nMots clés :\nProspection – argumentaire de vente – objection – OAV	Contenu :\nAu travers de jeux de rôle portant sur les étapes 3 et 4 de l’entretien de vente, aborder :\nLa prospection commerciale digitale :\n– E-mailing, SMS, réseaux sociaux, etc.\n– Indicateurs de performance / les indicateurs de rentabilité\n– Outils de CRM\nLa maîtrise de son offre\n– Conception ou construction d’un argumentaire de vente CAP complet (produits, services payants, services gratuits,\nmarque...)\n– Traduction de l’offre produit en bénéﬁces client\n– Anticipation et traitement des objections\n– Conclusion et prise de congé (sans négociation du prix)\nL’exploitation et la construction des Outils d’Aide à la Vente (OAV)\n– Outils de présentation\n– Outils de preuve\n– Outils de contractualisation\n– Outils de démonstration (échantillon, exemplaire du produit...)	23	23 heures dont 12 heures de TP	Vendre une offre commerciale	Tronc Commun	\N	\N
55	R4.SME.09	Relations publiques et relations presse			0		Elaborer l’identité d’une marque	SME	\N	\N
56	R4.SME.10	Organisation et logistique - 1			0		Manager un projet événementiel	SME	\N	\N
57	R4.SME.11	Gestion commerciale - 1			0		Manager un projet événementiel	SME	\N	\N
12	R1.12	Langue B du commerce - 1	Contribution au développement de la ou des compétences ciblées :\nDévelopper les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n\nMots clés :\nLangue de spécialité – présentation – prospection – communication et marketing	– Présentation d’une entreprise (points faibles et points forts), présentation de soi\n– Recherche d’informations sur internet, de documentations sur une entreprise ou un produit et présentation à l’oral et à\nl’écrit\n– Traduction d’un questionnaire/une enquête/une interview simple en langue étrangère\n– Prospection au téléphone et prise des RDV\n– Rédaction et utilisation de questions pour connaitre les besoins du client\n– Description d’un support de communication commerciale (publicité) dans sa dimension culturelle, présentation d’un brief\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire basique général de l’entreprise, de la communication commerciale et marketing, et le restituer\ndans une situation professionnelle spéciﬁque\n– Mobiliser les connecteurs logiques pour l’argumentation	20	20 heures dont 12 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
13	R1.13	Ressources et culture numériques - 1	Contribution au développement de la ou des compétences ciblées :\n– Rechercher de l’information et la sélectionner\n– Utiliser les outils numériques pour présenter un projet\n– Concevoir des outils adaptés à la démarche de prospection\n– Utiliser l’outil numérique pour produire des supports de communication simples\n– Collaborer pour conduire un projet\n\nMots clés :\nE.N.T – outils de recherche d’information – traitement de texte – PréAO – tableur	– Prise en main de l’E.N.T. : Mail Netiquette, objets connectés, réunions en distanciel, échange de ﬁchiers\n– Organisation et recherche d’information (ordinateur, support de stockage, réseau interne, sécurité/protection)\n– Outils de recherche sur Internet\n– Traitement de texte : utilisation d’un logiciel de traitement de texte (saisie/import de texte, mise en page, mise en forme,\ninsertion d’objets, export, structuration, gestion de documents longs)\n– Création et exploitation de présentations professionnelles (import/export, transitions, animations, insertions d’objets) à\nl’aide d’un logiciel de PréAO\n– Création et exploitation d’images pour l’intégration dans un support commercial à l’aide de logiciels de retouche d’image\n(type bitmap) : import, export, redimensionnement, format, transparence, effets simples\n– Utilisation d’un tableur simple et des fonctions de base d’un tableur : création de tableaux, calculs de base, création de\ngraphiques simples\n– Import/export, insertions d’objets, mise en page, mise en forme à l’aide des fonctions avancées d’un traitement de texte,\nd’un logiciel de PAO, PréAO	20	20 heures dont 14 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
14	R1.14	Expression, communication et culture 1	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRecherche documentaire – norme de présentation – culture – esprit critique – communication verbale et non verbale – rédaction	S’informer et informer de manière critique et efﬁcace (niveau 1) :\n– Initiation à la recherche documentaire (ex : recourir à l’environnement numérique de travail, aux bases de données, aux\nnormes bibliographiques).\n– Etude de la ﬁabilité et de la pertinence des informations (fake news, plagiat, etc.) et des sources choisies (médias grand\npublic et spécialisés, internet, etc.)\n– Développement de l’esprit critique et la culture générale en privilégiant les sujets d’actualité socio-économique, géopoli-\ntique et culturelle\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 1) :\n– Développement des savoirs et savoir-faire en sémiologie aﬁn de communiquer par l’image (à titre indicatif : ﬂyer, afﬁche,\nsupport d’exposé, etc) et au moyen d’outils de présentation (logiciels de carte heuristique, de diaporama, d’infographie,\netc.)\n– Analyse et compréhension des écritures professionnelles : les textes de la presse généraliste et/ou spécialisée\n– Élaboration de documents et écrits professionnels qui répondent aux différentes situations de communication (à titre\nindicatif : revue de presse, dossier, plaquette de présentation, rapport simple, note, courrier, courriel, etc.)\n– Compréhension et respect des normes de présentation écrites : typographie, orthographe/syntaxe\nCommuniquer, persuader, interagir :\n– Analyse de la communication (niveau 1) : comprendre les enjeux de la communication verbale, non verbale et para-\nverbale en situation (recours possible à un ou des modèles théoriques explicatifs jugés pertinents) pour analyser ses\nmanières de communiquer et les améliorer (fonctions du langage, pragmatique, anthropologie de la - communication,\netc.); accent mis sur l’identiﬁcation et la maitrise des normes sociales, culturelles, professionnelles et des registres de\nlangue)\n– Ecoute active, prise de notes, reformulation, compte-rendu oral, exposé, etc.	20	20 heures dont 10 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
15	R1.15	Projet personnel professionnel - 1	Contribution au développement de la ou des compétences ciblées :\nLe Projet Personnel et Professionnel permet à l’étudiant\n– d’avoir une compréhension exhaustive du référentiel de compétences de la formation et des éléments le structurant\n– de faire le lien entre les niveaux de compétences ciblés, les SAÉ et les ressources au programme de chaque semestre\n– de découvrir les métiers associés à la spécialité et les environnements professionnels correspondants\n– de se positionner sur un des parcours de la spécialité lorsque ces parcours sont proposés en seconde année\n– de mobiliser les techniques de recrutement dans le cadre d’une recherche de stage ou d’un contrat d’alternance\n– d’engager une réﬂexion sur la connaissance de soi\n\nMots clés :\nMétier – parcours – référentiel de compétences – identité professionnelle – stage – alternance	S’approprier la démarche PPP : connaissance de soi (intérêt, curiosité, aspirations, motivations), accompagnement des étu-\ndiants dans la déﬁnition d’une stratégie personnelle permettant la réalisation du projet professionnel\n– Développer une démarche réﬂexive et introspective (de manière à découvrir ses valeurs, qualités, motivations, savoirs,\nsavoir-être, savoirs-faire) au travers, par exemple de son expérience et ses centres d’intérêt\n– Placer l’étudiant dans une démarche prospective en termes d’avenir, souhait, motivation vis-à-vis d’un projet d’études\net/ou professionnel\n– S’initier à la démarche réﬂexive (savoir interroger et analyser son expérience)\nS’approprier la formation\n– S’approprier les compétences de la formation – identiﬁer les blocs de compétences\n– Référencer les compétences et les associer avec la réalité du terrain\n– Découvrir, analyser les parcours B.U.T. de la spécialité\n– Accompagner le choix des parcours (type 1 / type 2)\nDécouvrir les métiers et connaître le territoire\n– Faire le lien avec les métiers (ﬁches ROME – Association article 1, etc.)\n– Se familiariser avec les débouchés en fonction du territoire, les bassins d’entreprise, les réseaux d’entreprise, etc.\n– Identiﬁer les métiers en lien avec la formation, en analyser les principales caractéristiques\nSe projeter dans un environnement professionnel\n– Appréhender les codes, les usages et les cultures d’entreprise\n– Intégrer des codes sociaux au niveau France et Europe pour s’ouvrir à la diversité culturelle et s’ouvrir sur la mondiali-\nsation socio-économique\n– Construire son réseau professionnel : découvrir les réseaux et sensibiliser à l’identité numérique\n– Préparer son stage et/ou son alternance et/ou son parcours à l’international	14	14 heures dont 6 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
16	R2.01	Marketing mix - 1	Contribution au développement de la ou des compétences ciblées :\n– Apprécier les enjeux et les facteurs liés aux variables du marketing mix\n– Prendre les décisions marketing concernant la politique produit d’une offre simple\n– Prendre les décisions marketing concernant la politique prix d’une offre simple\n– Donner une cohérence globale au marketing mix en fonction du positionnement préalablement identiﬁé\n\nMots clés :\nMarketing mix – gamme – marque – packaging – prix – distribution – communication	Contenu :\n– Conception d’une politique de produit : cycle de vie, évolution saisonnière et temporaire, gamme et évolution des\ngammes, marque, packaging\n– Conception d’une politique de prix : objectifs, contraintes, méthodes de ﬁxation\n– Préconisation d’une politique de communication et d’une politique de distribution\n– Mise en cohérence de la stratégie marketing (cible et positionnement choisis) avec les variables du mix (produit, prix,\ncommunication, distribution)	18	18 heures	Conduire les actions marketing	Tronc Commun	\N	\N
77	R6.SME.04	Evènementiel sectoriel			0		Manager un projet événementiel	SME	\N	\N
18	R2.03	Moyens de la communication commerciale	Contribution au développement de la ou des compétences ciblées :\n– Connaître les moyens de communication commerciale, savoir les analyser et les utiliser de manière pertinente\n– Réaliser des supports de communication commerciale médias et hors-médias\n– Evaluer l’efﬁcacité des moyens de communication\n\nMots clés :\nMoyen média – médias sociaux – hors média – relations publiques et presse – marketing direct – outil de communication	Contenu :\n– Moyens de communication médias, médias sociaux\n– Marketing direct (objectifs, ciblage, outils)\n– Promotion des ventes (techniques et mise en œuvre)\n– Sponsoring, mécénat\n– Relations publiques, relations presse\n– Outils de communication : dossier de sponsoring, e-mailing, communiqué de presse, dossier de presse, post réseaux\nsociaux\n– Indicateurs d’analyse et de mesure des résultats : taux de retour, ventes, retombées médias, etc.	18	18 heures	Communiquer l’offre commerciale	Tronc Commun	\N	\N
19	R2.04	Etudes marketing - 2	Contribution au développement de la ou des compétences ciblées :\n– Etre capable de préconiser une stratégie d’étude compte tenu des informations à recueillir\n– Mener une étude quantitative et qualitative\n– Analyser les données recueillies et rendre compte des résultats de l’étude\n– Guider les choix marketing de construction d’une offre simple au moyen de l’étude de marché\n\nMots clés :\nEtude quantitative – sondage – panel – tri échantillonnage – rapport d’étude – traitement d’enquête – étude qualitative	Contenu :\n– Études quantitatives : approfondissement des différents types de sondage, panels...\n– Analyse des données de l’étude et rédaction du rapport d’étude\n– Logiciel de traitement d’enquête\n– Études qualitatives	18	18 heures dont 4 heures de TP	Conduire les actions marketing	Tronc Commun	\N	\N
20	R2.05	Relations contractuelles commerciales	Contribution au développement de la ou des compétences ciblées :\n– Concevoir des Outils d’Aide à la Vente (OAV) conformes aux règles de droit\n– Utiliser le vocabulaire juridique approprié\n– Préparer les éléments essentiels du contrat et faire la distinction entre les contrats commerciaux et le contenu des\ndifférents engagements contractuels\n– Structurer les éléments d’un message commercial et informer les consommateurs en respectant les obligations légales\n– Concevoir une offre cohérente qui respecte les principes juridiques\n\nMots clés :\nContrat de vente – conditions générales de vente – droit de la publicité – propriété intellectuelle – protection du consommateur	Contenu :\n– Information du client : informations légales à communiquer sur l’entreprise et sur les produits (y compris sur internet),\ndroit de la publicité, information du consommateur, promotion des ventes\n– Contrats (y compris conclusion du contrat en ligne); distinction entre contrat de vente et contrat d’entreprise : négocia-\ntions pré-contractuelles, obligations contractuelles, CGV, clauses abusives\n– Éléments de la propriété intellectuelle (marque, logo)	18	18 heures	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
21	R2.06	Techniques quantitatives et représentations - 2	Contribution au développement de la ou des compétences ciblées :\n– Appréhender les incidences des décisions ﬁnancières\n– Calculer et chiffrer un projet et présenter les indicateurs de suivi et de résultats\n– Évaluer, étudier et simuler les interactions entre caractères\n– Intégrer les comportements liés aux saisons\n– Analyser les statistiques des réseaux sociaux et de sites Internet\n– Mesurer le degré de dépendance entre deux variables\n\nMots clés :\nAjustement – corrélation – saisonnalité – prévision – lien entre caractères	Contenu :\n– Calcul ﬁnancier : intérêts simples, intérêts composés, emprunts\n– Séries à deux caractères : ajustement, corrélation\n– Chroniques\n– Tableaux de contingence\n– Test d’indépendance\nL’utilisation de logiciels spéciﬁques est encouragée (tableurs, logiciel d’enquêtes quantitatives, de statistiques)	23	23 heures dont 6 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
22	R2.07	Coûts, marges et prix d’une offre simple	Contribution au développement de la ou des compétences ciblées :\n– Comprendre les notions de coûts, de marge pour calculer la rentabilité d’un produit ou d’une opération commerciale et\nvériﬁer la cohérence de la ﬁxation du prix\n\nMots clés :\nCharge – coût – marge – stock	Contenu :\n– Notion de coûts / charges\n– Différence charges variables/ ﬁxes et directes/ indirectes, seuil de rentabilité simple\n– Application de la méthode des coûts complets et de la méthode des coûts variables\n– Méthode de valorisation des stocks	18	18 heures dont 6 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
23	R2.08	Canaux de commercialisation et de distribution	Contribution au développement de la ou des compétences ciblées :\n– Utiliser le vocabulaire approprié de la distribution et en comprendre les enjeux économiques, environnementaux, socié-\ntaux ...\n– Identiﬁer les formats commerciaux et maîtriser leurs spéciﬁcités\n– Préconiser une stratégie de distribution d’une offre simple en cohérence avec les autres variables du marketing mix\n– Prendre conscience des contraintes des choix de distribution sur les autres variables du mix marketing du producteur\nd’une offre simple\n\nMots clés :\nCanal de distribution – grande surface alimentaire (GSA) – grande surface spécialisée (GSS) – commerce intégré – commerce\nassocié – commerce indépendant	Contenu :\n– Identiﬁcation des types de distribution\n– Panorama de la distribution en France, évolutions et tendances\n– Relation producteur-fournisseur et producteur-distributeur\n– Choix des canaux de distribution et impact sur le mix du producteur\nApprentissage critique ciblé :\n– AC11.04 | Concevoir une offre cohérente et éthique en termes de produits, de prix, de distribution et de communication	14	14 heures	Conduire les actions marketing	Tronc Commun	\N	\N
24	R2.09	Psychologie sociale	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’engagement dans le comportement de consommation\n– Prendre conscience des enjeux des différentes situations de communication\n– Comprendre les processus d’inﬂuence (socioculturels et médiatiques)\n\nMots clés :\nGroupe social – processus d’inﬂuence – personnalité – communication persuasive	Contenu :\n– Les individus, groupes sociaux et leurs caractéristiques : personnalité/ individualité, croyance, attitudes, émotions,\nculture, catégorisation sociale, motivation\n– Les modèles et théories : théories des besoins, théorie du comportement planiﬁé, théories de l’engagement, théories de\nl’inﬂuence sociale\n– Dynamique de groupe\n– Gestion de conﬂit, gestion du stress\n– Communication persuasive / engageante\n– Inﬂuence consciente et non consciente sur les attitudes et les comportements\n– Processus de mémorisation et d’attention	18	18 heures	Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
25	R2.10	Gestion et conduite de projet	Contribution au développement de la ou des compétences ciblées :\nRédiger la note de cadrage en partant de la demande d’un commanditaire et choisir la planiﬁcation la plus efﬁcace\n\nMots clés :\nProjet – antériorité – tâche critique – affectation des ressources – contrainte – budget	Contenu :\n– Conception complète du projet : prise en compte du cadrage du commanditaire, planiﬁcation complète en tenant compte\ndes antériorités, des ressources disponibles et des contraintes diverses, notamment de budget et de temps\n– Détermination des tâches critiques pour faire les meilleurs choix d’affectation de ressources\n– Comparaison de différents plans d’actions possibles en fonction de leur pertinence, acceptabilité et faisabilité et choisir\nle plus adapté\n– Maitrise des outils de la gestion de projet	10	10 heures dont 4 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
26	R2.11	Langue A Anglais du commerce - 2	Contribution au développement de la ou des compétences ciblées :\nDévelopper les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – communication	Contenu :\n– Description techniquement d’un produit, présentation d’un produit sous forme d’avantages\n– Conception d’un support de communication simple qui présente la stratégie appliquée au produit\n– Présentation du marketing mix d’un produit à l’écrit comme à l’oral\n– Compréhension et rédaction des documents commerciaux simples, rédaction des mails, mailing\n– Construction d’un argumentaire de vente et un plan de découverte simple\n– Production d’un support de communication commerciale simple (brochure, courrier commercial simple...)\n– Justiﬁcation des choix, argumentation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire basique général de l’entreprise, de la communication commerciale, et du marketing et le restituer\ndans une situation professionnelle spéciﬁque\n– Mobiliser les connecteurs logiques pour l’argumentation	23	23 heures dont 10 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
27	R2.12	Langue B du commerce - 2	Contribution au développement de la ou des compétences ciblées :\nDévelopper les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – communication	Contenu :\n– Description techniquement d’un produit, présentation d’un produit sous forme d’avantages\n– Conception d’un support de communication simple qui présente la stratégie appliquée au produit\n– Présentation du marketing mix d’un produit à l’écrit comme à l’oral\n– Compréhension et rédaction des documents commerciaux simples, rédaction des mails, mailing\n– Construction d’un argumentaire de vente et un plan de découverte simple\n– Production d’un support de communication commerciale simple (brochure, courrier commercial simple...)\n– Justiﬁcation des choix, argumentation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire basique général de l’entreprise, de la communication commerciale, et du marketing et le restituer\ndans une situation professionnelle spéciﬁque\n– Mobiliser les connecteurs logiques pour l’argumentation	23	23 heures dont 10 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
28	R2.13	Ressources et culture numériques - 2	Contribution au développement de la ou des compétences ciblées :\nUtiliser les outils informatiques :\n– pour calculer et chiffrer un projet et présenter les indicateurs de suivi et de résultat\n– pour réaliser des supports de vente adaptés (devis, facture ...)\n– pour réaliser des supports de communication commerciale efﬁcaces et qualitatifs\n\nMots clés :\nPublipostage – tableur – vidéo – réseaux sociaux – site internet	Contenu :\n– Mise en page élaborée (afﬁches, ﬂyers, dépliants)\n– Publipostage/ Publimailing simple (traitement de texte)\n– Tableur : fonctions simples, calculs conditionnels (SI et Cie, NB.SI, ...), création de graphiques simples, export et liens\nentre les différents logiciels (Tableur, PréAO, Traitement de texte)\n– Montage vidéo simple\n– Utilisation des réseaux sociaux, des sites internet : principe et introduction aux bons usages, fonction de base, prise en\nmain d’un CMS	18	18 heures dont 10 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
29	R2.14	Expression, communication et culture - 2	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique et efﬁcace\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\nCommuniquer de manière adaptée aux situations\n\nMots clés :\nCulture – communication écrite – orale – communication par l’image – argumentation – synthèse – rapport	Contenu : outre l’approfondissement des éléments contenus au S1, peuvent être abordés au S2 les points suivants :\nS’informer et informer de manière critique et efﬁcace (niveau 1) :\n– Découverte d’univers artistiques et développement des pratiques culturelles : expositions, conférences, festivals, mu-\nsées.\n– Synthèses à l’écrit : analyse du corpus, problématique, élaboration de plans détaillés\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 1) :\n– Développement des savoirs et savoir-faire en sémiologie aﬁn de communiquer par l’image ﬁxe et mobile (à titre indicatif :\nposter, spot vidéo, etc.) et au moyen d’outils de présentation (logiciel de présentation, datavisualisation, etc.)\n– Analyse et compréhension des écritures professionnelles : les documents d’entreprise\n– Élaboration de documents qui répondent aux différentes situations de communication (à titre indicatif : compte-rendu\nécrit/oral, résumé, rapport, communiqué de presse, dossier de presse, revue de presse, scénario de vidéo promotion-\nnelle ou de spot publicitaire, post sur les réseaux sociaux, etc.)\n– Compréhension et respect des normes de présentation écrites : typographie, orthographe/syntaxe, etc.\nCommuniquer, persuader, interagir (niveau 1) :\n– Développement des capacités de communication (écrite et orale) à des ﬁns de persuasion (à titre indicatif : initiation à la\nrhétorique et l’argumentation; genres possibles : note d’intention, pitch, discours oratoire, débat, etc.)	23	23 heures dont 10 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
30	R2.15	Projet personnel professionnel - 2	Contribution au développement de la ou les compétences ciblées : le Projet Personnel et Professionnel permet à l’étudiant\n– d’avoir une compréhension exhaustive du référentiel de compétences de la formation et des éléments le structurant\n– de faire le lien entre les niveaux de compétences ciblés, les SAÉ et les ressources au programme de chaque semestre\n– de découvrir les métiers associés à la spécialité et les environnements professionnels correspondants\n– de se positionner sur un des parcours de la spécialité lorsque ces parcours sont proposés en seconde année\n– de mobiliser les techniques de recrutement dans le cadre d’une recherche de stage ou d’un contrat d’alternance\n– d’engager une réﬂexion sur la connaissance de soi\n\nMots clés :\nMétier – parcours – référentiel de compétences – identité professionnelle – stage – alternance	Contenu :\nS’approprier la démarche PPP : connaissance de soi (intérêt, curiosité, aspirations, motivations), accompagnement des étu-\ndiants dans la déﬁnition d’une stratégie personnelle permettant la réalisation du projet professionnel\n– Développer une démarche réﬂexive et introspective (de manière à découvrir ses valeurs, qualités, motivations, savoirs,\nsavoir-être, savoirs-faire) au travers, par exemple de son expérience et ses centres d’intérêt\n– Placer l’étudiant dans une démarche prospective en termes d’avenir, souhait, motivation vis-à-vis d’un projet d’études\net/ou professionnel\n– S’initier à la démarche réﬂexive (savoir interroger et analyser son expérience)\nS’approprier la formation\n– S’approprier les compétences de la formation – identiﬁer les blocs de compétences\n– Référencer les compétences et les associer avec la réalité du terrain\n– Découvrir, analyser les parcours B.U.T. de la spécialité\n– Accompagner le choix des parcours (type 1 / type 2)\nDécouvrir les métiers et connaître le territoire\n– Faire le lien avec les métiers (ﬁches ROME – Association article 1, etc.)\n– Se familiariser avec les débouchés en fonction du territoire, les bassins d’entreprise, les réseaux d’entreprise, etc.\n– Identiﬁer les métiers en lien avec la formation, en analyser les principales caractéristiques\nSe projeter dans un environnement professionnel\n– Appréhender les codes, les usages et les cultures d’entreprise\n– Intégrer des codes sociaux au niveau France et Europe pour s’ouvrir à la diversité culturelle et s’ouvrir sur la mondiali-\nsation socio-économique\n– Construire son réseau professionnel : découvrir les réseaux et sensibiliser à l’identité numérique\n– Préparer son stage et/ou son alternance et/ou son parcours à l’international	10	10 heures dont 5 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
242	R4.BDMRC.10	Relation client omnicanal			0		Manager la relation client	BDMRC	\N	\N
45	R3.SME.15	Marketing de l’évènementiel - 1	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une démarche de projet événementiel\n– Valoriser l’événement avant, pendant, après\n– Mesurer son efﬁcacité\n\nMots clés :\nPanorama événementiel – création d’événements – événements hybrides – événements éco-conçus – communication événe-\nmentielle – impact	– Panorama des différents types d’événements simples en fonction des cibles et objectifs\n– Conception d’un événement adapté à la demande : du brief à la proposition\n– Gestion hybride de l’événementiel : adapter les événements à la nouvelle problématique du distanciel\n– Outils d’éco-conception d’événements\n– Communication avant, pendant, après\n– Communication : apprentissage de logiciels d’infographie\n– Mesure de l’impact : nombre d’inscrits ou participants, mesure de la satisfaction	13	13 heures dont 4 heures de TP	Manager un projet événementiel	SME	\N	\N
46	R3.SME.16	Fondamentaux de la communication de marque	Contribution au développement de la ou des compétences ciblées :\n– Comprendre les enjeux de la création d’une marque\n– Appréhender la notion d’identité de marque\n– Créer du contenu de marque simple\n\nMots clés :\nValeurs – identité de marque – territoires de marque – gestion de contenu	– Leviers de création de marque : liens marketing et communication (mix, positionnement, etc.)\n– Narration de marque (storytelling, construction de l’identité : fonctions, codes, valeurs de marque, etc.)\n– Mesure de la visibilité\n– En lien avec le droit : Propriété industrielle, RSE	13	13 heures dont 4 heures de TP	Elaborer l’identité d’une marque	SME	\N	\N
76	R6.SME.03	Stratégie de développement de marque - 2			0		Elaborer l’identité d’une marque	SME	\N	\N
67	R5.SME.10	Ressources et culture numériques appliquées à la stratégie de marque et à l’évène-	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher, recueillir et structurer les données prospects et clients aﬁn d’exploiter efﬁcacement un CRM, et le\nfaire évoluer\n– Bâtir une campagne de relation client : déterminer les objectifs, cibler les prospects, s’approprier les outils, évaluer son\nefﬁcacité\n– Concevoir, mettre en œuvre et présenter des tableaux de bord efﬁcaces et pertinents\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité et à la conﬁdentialité du système d’informations\n\nMots clés :\nERP – tableaux de bord – billeterie	– Prise en main d’un ERP et d’un CRM\n– Techniques de construction et d’alimentation d’une base de données, scoring\n– Tableurs fonctions avancées : simulations, tableaux de bord\n– Outils de présentation et communication des tableaux de bord\n– Billetterie : utilisation d’outils adaptés aux évènements complexes avec paiement en ligne	13	13 heures dont 6 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel	SME	\N	\N
68	R5.SME.11	Stratégie de développement de marque - 1	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de marque\n– Gérer et animer la marque et le portefeuille de marque de l’entreprise\n\nMots clés :\nIdentité de marque – territoire de la marque – capital marque – développement de la marque – droit de la marque	– Identité et valeur de la marque\n– Construction et mesure du capital marque\n– Création de contenu et animation de la marque\n– Fonctions de la marque pour le consommateur et pour l’entreprise\n– Aspects juridiques de la marque	15	15 heures	Elaborer l’identité d’une marque	SME	\N	\N
69	R5.SME.12	Marketing digital de la marque	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication digitale\n– Gérer les communautés de marque\n– Mesurer la performance des actions et l’e-réputation\n\nMots clés :\nContenu web – ligne éditoriale – community management – e-réputation – inﬂuenceur web – audience digitale	– Création de contenu (textuel, visuel, audio) : développement de contenu en adéquation avec la stratégie éditoriale de\nchacun des supports digitaux tant dans le contenu que dans la forme, respect des spéciﬁcités de rédaction de contenu\nweb, élaboration des supports audio et audiovisuels de qualité\n– Management des communautés de marque : inﬂuenceurs, ambassadeurs. Gestion des collaborations avec les différents\ntypes d’acteurs de la communauté, dans le respect de la stratégie de marque, création des ﬁchiers d’inﬂuenceurs/\nambassadeurs potentiels, déﬁnition des critères de choix, connaissance des plateformes d’inﬂuence marketing et de\nleur fonctionnement, interactions avec la communauté\n– Gestion de la viralité : réactions face aux rumeurs, à la désinformation et aux fake news, gestion de la « guerre digitale »\n– E-réputation, veille : mise en place d’une veille sur l’e-réputation de la marque aﬁn de pouvoir interagir pertinemment\navec la communauté et gestion de l’e-réputation de la marque au niveau stratégique\n– Indicateurs clés de performance et mesure d’audience digitale : déﬁnition des indicateurs clés en fonction des différents\nsupports, réalisation de tableaux de bord de suivi, diffusion de l’information\nApprentissage critique ciblé :\n– AC34.04SME | Développer la communauté de marque et l’adhésion (community management, veille image de marque\net e-réputation)	15	15 heures dont 6 heures de TP	Elaborer l’identité d’une marque	SME	\N	\N
70	R5.SME.13	Gestion commerciale - 2	Contribution au développement de la ou des compétences ciblées :\n– Gérer les relations commerciales avec les fournisseurs et partenaires d’un évènement de grande ampleur\n– Elaborer une démarche de recherche de subventions\n– Optimiser les retombées commerciales d’un évènement\n\nMots clés :\nAchat – prestataire – subvention	– Relations, négociation avec les prestataires\n– Recherche de sponsors auprès de partenaires privés\n– Recherche de subventions auprès de partenaires publics et institutionnels : connaissance des collectivités susceptibles\nde soutenir le projet, dossier de partenariat, suivi des démarches administratives\n– Achat, produits dérivés : choix de produits adaptés, élaboration d’une politique commerciale (quantités, prix, modalités\nde vente)	12	12 heures	Manager un projet événementiel	SME	\N	\N
71	R5.SME.14	Organisation et logistique - 2	Contribution au développement de la ou des compétences ciblées :\n– Appréhender toutes les étapes de la logistique évènementielle d’un évènement de grande ampleur\n– Connaître le cadre juridique d’un évènement de grande ampleur\n– Maitrîser les techniques d’animation et d’évaluation d’une équipe\n\nMots clés :\nGestion des risques – droit de l’évènement – management d’équipe – gestion budgétaire	– Gestion de projet : planiﬁcation, gestion des risques, retour d’expérience\n– Gestion budgétaire : budget prévisionnel et réalisé, analyse d’écart, rédiger un dossier de subvention\n– Droit de l’évènement : autorisations, licences, assurances, sécurité, débit de boisson / évènement et RSE\n– Management d’équipe : connaissance des différents styles de management, techniques d’animation d’une équipe, mo-\ndalités d’évaluation individuelle et collective	15	15 heures dont 4 heures de TP	Manager un projet événementiel	SME	\N	\N
72	R5.SME.15	Conception graphique	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser des logiciels de conception graphique professionnels\n\nMots clés :\nCréation graphique – dessin vectoriel – retouche image – mise en page	-Traitement de l’image complexe\n– Conception et mise en page d’outils de communication complexes\n– Création graphique de l’identité de marque	20	20 heures dont 16 heures de TP	Elaborer l’identité d’une marque	SME	\N	\N
73	R5.SME.16	Marketing de l’évènementiel - 2	Contribution au développement de la ou les compétences ciblées :\n– Connaître les enjeux d’un évènement de grande ampleur\n– Elaborer un évènement de grande ampleur adapté au brief\n– Mesurer les retombées de l’évènement\n\nMots clés :\nEvènement grand format – retombée – mesure de la satisfaction	– Panorama des différents types d’évènements complexes : événements grand public, congrès, conventions, foires et\nsalons, festivals\n– Spéciﬁcités de la création et promotion d’un évènement grand public de grande ampleur\n– Mesure des retombées, de la fréquentation et de la satisfaction\nApprentissage critique ciblé :\n– AC35.01SME | Créer un événement complexe adapté aux attentes du commanditaire	15	15 heures	Manager un projet événementiel	SME	\N	\N
93	R3.MMPV.16	Marketing du point de vente	Contribution au développement de la ou les compétences ciblées :\n– Comprendre les évolutions et les stratégies de développement des différents acteurs de la distribution\n– Comprendre un concept d’enseigne et maîtriser ses leviers opérationnels\n– Analyser le comportement du consommateur face au point de vente\n– Mettre en oeuvre la stratégie d’une enseigne : point de vente physique et/ou virtuel\n– Savoir déterminer le potentiel commercial d’une zone de chalandise (géomarketing).\n\nMots clés :\nEnseignes – parcours – géomarketing	– Stratégies et marketing mix du fabricant\n– Stratégies et marketing du distributeur : enseigne, positionnement, structuration de l’offre, communication nationale /\nrégionale\n– Facteurs d’ambiance en magasin : marketing sensoriel, théâtralisation\n– Rôle et enjeux des marques et de la MDD (tant pour le producteur que pour le distributeur)\n– Choix du point de vente par le consommateur, son comportement en magasin, digitalisation de la relation client\n– Principes, dimensions, mise en oeuvre du géomarketing	13	13 heures dont 4 heures de TP	Piloter un espace de vente	MMPV	\N	\N
139	R3.MDEE.16	Créativité et innovation	Contribution au développement de la ou des compétences ciblées :\n– Découvrir des méthodes de créativité : carte conceptuelle simple, méthodes de questionnement...\n– Participer à une séance de créativité\n– Identiﬁer l’originalité et la faisabilité d’une idée\n– Être capable de déﬁnir une innovation\n– Vériﬁer l’adéquation de l’idée avec un besoin utilisateur/client\nContenus :\n– Méthodes et outils de la créativité\n– Design thinking\n\nMots clés :\nCréativité – Innovation		13	13 heures dont 4 heures de TP	Développer un projet e-business	MDEE	\N	\N
92	R3.MMPV.15	Management de la performance du point de vente	Contribution au développement de la ou les compétences ciblées :\n– Comprendre le fonctionnement d’un point de vente et ses indicateurs de performance commerciale\n– Communiquer sur les objectifs et les résultats professionnellement\n\nMots clés :\nAnalyse du CA – marge – objectifs – résultats	– Analyse du CA, répartition des ventes en volume et en valeur, marges...\n– Analyse des indicateurs du point de vente en fonction de sa localisation, de son format, des caractéristiques de sa\nzone de chalandise (données démographiques, économiques, etc.), de son environnement concurrentiel, des éléments\ndéclencheurs de traﬁc situés à proximité...\n– Suivi de l’activité de l’équipe de vente, mise en place d’objectifs et communication sur les résultats	13	13 heures dont 4 heures de TP	Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
117	R5.MMPV.13	Supply chain	Contribution au développement de la ou des compétences ciblées :\n– S’approprier la chaine d’approvisionnement de l’espace de vente\n– Coordonner et contrôler les opérations logistiques de réception, expédition et livraison\n– Optimiser les approvisionnements (suivi d’une commande, disponibilité des produits, délai de livraison...)\n– Organiser la répartition des emplacements de stockage sur le site et en suivre la gestion\n– Maîtriser les notions clés de la qualité pour les intégrer au processus d’approvisionnement\n\nMots clés :\nApprovisionnement – gestion des stocks – qualité	– Enjeux de la logistique : origine, organisation des différents acteurs, source d’avantages concurrentiels, nouvelles tech-\nnologies\n– Gestion de stock : suivi de l’état des stocks, identiﬁcation des besoins en approvisionnement et suivi des commandes\n(disponibilités, délais de livraison, ect.)\n– Contrôle de l’état et de la conservation des produits périssables et coordination du retrait des produits impropres à la\nvente\n– Gestion des ﬂux : tendus, poussés, tirés, transit, allotis, cross-docking\n– Acteurs de la qualité, certiﬁcation, qualité ﬁlières et produits	15	15 heures	Piloter un espace de vente	MMPV	\N	\N
114	R5.MMPV.10	Ressources et culture numériques appliquées au marketing et management du point	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher et structurer les données et informations importantes\n– Concevoir et mettre en œuvre des tableaux de bord efﬁcaces et pertinents (KPI)\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité du système d’informations\n– Acquérir une culture numérique\n\nMots clés :\nERP – KPI – tableur fonctions avancées – simulation	– Prise en main d’un ERP\n– Tableurs fonctions avancées : simulations, tableaux de bord\n– Introduction au Big Data, au Data Mining	13	13 heures dont 6 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente	MMPV	\N	\N
115	R5.MMPV.11	Parcours expérience client	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une stratégie commerciale en cohérence avec l’environnement concurrentiel\n– Analyser et optimiser le parcours client dans une perspective omnicanal par l’intégration des différents points de contact :\nphygitalisation du point de vente\n– Construire une expérience client\n– Développer un portefeuille de clients/prospects et effectuer le suivi de la clientèle (opérations de ﬁdélisation, enquêtes\nde satisfaction, relances ...)\n\nMots clés :\nGRC – expérience client – omnicanal – portefeuille client	– Mise en place d’une expérience d’achat globale et transparente pour créer une relation durable avec les clients\n– Analyse des besoins du client omni-consommateur pour uniformiser l’ensemble des points de contact, ﬂuidiﬁer le par-\ncours client, améliorer l’expérience client et générer plus de traﬁc\n– Anticipation des nouvelles tendances de consommation et des nouvelles technologies aﬁn d’adapter le point de vente\nou le rayon	26	26 heures dont 10 heures de TP	Piloter un espace de vente	MMPV	\N	\N
116	R5.MMPV.12	Management d’équipe - 2	Contribution au développement de la ou des compétences ciblées :\n– S’approprier un style de management\n– Fédérer les équipes autour de l’atteinte des objectifs (méthode SMART)\n– Sélectionner des collaborateurs en considérant les besoins de l’équipe et les intégrer\n– Suivre et organiser le développement des compétences du personnel (formation continue, entretien annuel...).\n– Valoriser les compétences des membres de l’équipe\n– Accompagner l’équipe pour gérer le changement et les conﬂits\n\nMots clés :\nManagement – conﬂit – compétence	– Différents types de management (pouvoir, leadership, management responsable, autonomie et délégation) et adaptation\naux équipes en place\n– Motivations au travail / management de la différenciation\n– Gestion des conﬂits et du changement	15	15 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
118	R5.MMPV.14	Droit de la distribution	Contribution au développement de la ou des compétences ciblées :\n– Connaître les obligations et les responsabilités des enseignes en matière d’information produit\n– Connaître les obligations et les responsabilités des enseignes par rapport à la sécurité du client dans le point de vente\n– Agir dans le cadre de la règlementation commerciale : droit de la concurrence\nContenus :\n– Législation applicable sur les parkings en matière de circulation automobile, circulation piétons, gestion des chariots\n– Notion de produits dangereux et responsabilité du distributeur\n– Etiquetage, afﬁchage et présentation des produits, publicité comparative, promotion, solde, liquidation, prix d’appel\n– Transparence tarifaire en tant que moyen de prévention et de contrôle des pratiques restrictives de la concurrence\nPrérequis :\n– R5.04 | Droit des activités commerciales - 2\n\nMots clés :\nRèglementation commerciale – soldes – information produit – droit de la concurrence		18	18 heures	Piloter un espace de vente	MMPV	\N	\N
119	R5.MMPV.15	Trade marketing	Contribution au développement de la ou des compétences ciblées :\n– Sélectionner des fournisseurs\n– Optimiser la relation entre le producteur et le fournisseur\n\nMots clés :\nCategory management – sourcing – PCC – CPFR – ECR	– Utilisation des critères du sourcing pour choisir les fournisseurs\n– Pilotage collaboratif des approvisionnements : plan commercial commun (PCC) et gestion collaborative de planiﬁcation\net de la prévision (CPFR)\n– Prévisions des opérations commerciales communes : opérations promotionnelles conjointes, co-branding\n– Utilisation du category management pour optimiser les ventes\n– Mise en place de partenariats entre fournisseurs et distributeurs (Efﬁcient Consumer Response : ECR)	18	18 heures dont 8 heures de TP	Piloter un espace de vente	MMPV	\N	\N
138	R3.MDEE.15	Stratégie de marketing digital	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer les spéciﬁcités du marketing digital et cerner les enjeux\n– Adopter une posture adaptée au marketing digital\n– Connaitre et mobiliser des techniques simples en environnement digital\nContenus :\n– Fondamentaux du web, éléments de diagnostic d’un site\n– Acteurs de l’économie numérique\n– Recontextualisation et enjeux de la transformation numérique\n– Mécanismes de création de la valeur en ligne\n– Système d’information et veille digitale\n– Stratégie de visibilité d’une marque digitale\n– Techniques digitales de base de création de traﬁc, de conversion et de ﬁdélisation\n– Indicateurs clés simples (Kpi)\n\nMots clés :\nStratégie digitale – veille digitale – indicateur – audit – e-commerce		13	13 heures dont 4 heures de TP	Gérer une activité digitale	MDEE	\N	\N
163	R5.MDEE.13	Stratégie social media et e-CRM	Contribution au développement de la ou des compétences ciblées :\n– Utiliser les leviers opérationnels du marketing et de la communication digitale\n– Convertir les visiteurs en clients grâce au e-CRM\n– Concevoir et suivre les résultats d’une campagne de communication sur les réseaux sociaux\n\nMots clés :\nStratégie de contenu – communication sur les réseaux sociaux et recrutement	– Gestion des réseaux sociaux\n– Stratégie de communication digitale\n– E-CRM et fonctionnement de Social Ads\n– Technique d’élaboration d’une campagne d’e-mailing ou MD (SMS...) : recrutement de prospects, qualiﬁcation de ﬁchiers,\nconstruction de la campagne\n– Utilisation d’outils de routage professionnel, mesure du ROI (retour sur investissement)\n– Mettre en place des outils d’animation (jeu concours, etc.)	15	15 heures dont 6 heures de TP	Gérer une activité digitale	MDEE	\N	\N
164	R5.MDEE.14	Business model - 2	Contribution au développement de la ou des compétences ciblées :\n– Concevoir le business model d’un projet dans toutes ses dimensions\n– Appréhender l’approche systémique et tenir compte des effets positifs et/ou négatifs sur ses environnements\n– Défendre le business model face aux investisseurs/parties prenantes\n\nMots clés :\nAnalyse de la valeur – positive business	– Responsabilité, ﬁscalité et protection du dirigeant\n– Gestion ﬁnancière adaptée à l’entrepreneuriat\n– Contenus d’un business model complet\n– Valeur délivrée\n– Création et partage de la valeur\n– RSE et "positive business"	16	16 heures	Développer un projet e-business	MDEE	\N	\N
160	R5.MDEE.10	Ressources et culture numériques appliquées au marketing digital, à l’e-business et	Contribution au développement de la ou des compétences ciblées :\n– Animer et mettre à jour un site internet professionnel\n– Créer un site internet professionnel et le mettre en ligne\n– Analyser un système d’information et contribuer à la création d’une base de données relationnelle\n– Interroger une base de données\n\nMots clés :\nSite internet – e-boutique – HTML5 – CSS – base de données – requête – CMS	– Internet : approfondissement HTML et CSS, (PHP, javascript)\n– FTP\n– SGBD : bases d’un SI, modèle relationnel, requêtes (bases SQL), logiciel de BD\n– Installation d’un CMS et utilisation professionnelle\n– Production d’un site internet (prolongement ou développement du site simple élaboré au niveau 2)	13	13 heures dont 6 heures de TP	Gérer une activité digitale, Développer un projet e-business	MDEE	\N	\N
161	R5.MDEE.11	Management de la créativité et de l’innovation	Contribution au développement de la ou des compétences ciblées :\n– Transformer l’idée en une offre innovante\n– Mobiliser le marketing pour innover\n– Mobiliser la propriété intellectuelle/industrielle\n– Mettre en œuvre un management responsable, voire positif de l’innovation\n\nMots clés :\nCréativité – innovation – artefact – retour utilisateur – persona	– Marketing dédié à l’innovation : création d’idées nouvelles en utilisant des techniques de créativité, sélection d’une idée,\nformalisation et présentation\n– Retours de l’expérience client et utilisateur : élaboration et analyse des retours utilisateurs et proposition d’améliorations\nen termes de valeur délivrée\n– Fiche persona complète avec proﬁl psychologique utilisateur et occasion d’usage\n– Cahier des charges de proposition d’une offre adaptée\n– Techniques de production d’artefact et/ou prototype\n– Propriété intellectuelle et industrielle : recherche d’antériorités, utilisation des dispositifs de protection, dépôt	15	15 heures dont 6 heures de TP	Développer un projet e-business	MDEE	\N	\N
162	R5.MDEE.12	Référencement	Contribution au développement de la ou des compétences ciblées :\n– Mettre en oeuvre un référencement\n– Mobiliser les indicateurs et techniques pour être performant\n– Evaluer le résultat pour décider\n\nMots clés :\nStratégie digitale – veille digitale – indicateur – audit – e-commerce	– Réalisation d’un audit de référencement\n– Mise en œuvre les techniques de référencement naturel (SEO) et de mener des campagnes de référencement payant\n(SEA)\n– Analyse des mots-clés d’une marque et recommandations\n– Evaluation des campagnes de référencement	16	16 heures dont 8 heures de TP	Gérer une activité digitale	MDEE	\N	\N
165	R5.MDEE.15	Stratégie de contenu et rédaction web	Contribution au développement de la ou des compétences ciblées :\n– Etre capable de créer une ﬁche produit, de concevoir un catalogue\n– Actionner une stratégie de marque digitale et de e-merchandising\n– Savoir rédiger différents types de supports numériques (newsletters, livre blanc, infographie...)\n– Savoir créer du contenu adapté aux formats disponibles, permettant un référencement optimal\n\nMots clés :\nStratégie digitale – storytelling – vidéo	– Enjeux liés au contenu\n– Spéciﬁcités d’un contenu numérique et d’une marque digitale\n– Rédaction et design\n– Stratégie de contenu et audience	15	15 heures dont 6 heures de TP	Gérer une activité digitale	MDEE	\N	\N
166	R5.MDEE.16	Logistique et supply chain	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre des compétences relationnelles, de gestion et d’organisation de la logistique pour délivrer un bien ou\nun service qui optimise la relation client\n– Connaître les spéciﬁcités de la logistique pour une activité e-commerce\n– Etre capable de proposer des solutions pour assurer une chaine logistique efﬁcace au niveau national et à l’international\n\nMots clés :\nFlux – ERP	– Les enjeux de la logistique : satisfaction clients, taux de service et coûts logistiques\n– Les ﬂux de production : gestion des stocks, des espaces et des délais\n– Les ﬂux d’information et les solutions digitales\n– La supply chain\n– La logistique du e-commerce	15	15 heures	Gérer une activité digitale, Développer un projet e-business	MDEE	\N	\N
221	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Conduire les actions marketing	BDMRC	\N	\N
185	R3.BI.15	Stratégie et veille à l’international	Contribution au développement de la ou des compétences ciblées :\n– Déﬁnir et comprendre la veille stratégique et l’intelligence économique à l’international\n– Déterminer le problème décisionnel d’une entreprise à l’international\n\nMots clés :\nStratégies d’internationalisation – veille – diagnostic – prospection	– Compréhension de l’intérêt de la démarche d’internationalisation d’une organisation\n– Identiﬁcation des besoins et objectifs d’expansion à l’international d’une organisation\n– Identiﬁcation des options stratégiques de développement à l’international\n– Identiﬁcation des sources d’information pour la prise de décision (veille)\n– Analyse, trie des données par rapport aux objectifs\n– Utilisation des outils d’analyse stratégique pour identiﬁer les marchés porteurs et les cibles à l’international pour l’orga-\nnisation (SWOT, Porter, Pestel)\n– Mobilisation du diagnostic interne de l’entreprise pour déterminer sa capacité à s’internationaliser (moyens ﬁnanciers,\nhumains, logistiques...)\n– Identiﬁcation des organismes d’appui de développement à l’international (BPI,...)\n– Restitution des informations et des recommandations\nCette ressource peut être dispensée en langues étrangères.	13	13 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international	BI	\N	\N
186	R3.BI.16	Marketing et vente à l’international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender les différents aspects d’un problème marketing international\n– Développer les possibilités d’actions commerciales sur les marchés étrangers\n\nMots clés :\nMarketing international – prospection à l’international	– Identiﬁcation des prospects à l’international\n– Chiffrage des coûts et estimation de la faisabilité d’une opération de prospection à l’international\n– Adaptation de l’offre en déployant un marketing mix à l’international (stratégies d’adaptation et de standardisation, etc)\n– Élaboration d’un plan de lancement à l’international qui prend en compte les spéciﬁcités culturelles\nCette ressource peut être dispensée en langues étrangères.\nApprentissage critique ciblé :\n– AC25.04BI | Positionner l’offre en fonction des spéciﬁcités culturelles identiﬁées sur le(s) marché(s) ciblé(s)	13	13 heures	Piloter les opérations à l’international	BI	\N	\N
210	R5.BI.13	Droit international	Contribution au développement de la ou des compétences ciblées :\n– Elaborer un projet de contrat avec un partenaire à l’international\n\nMots clés :\nDroit international – concurrence – protection des données – droit applicable – résolution des litiges – arbitrage – incoterm –\nusage du commerce international – obligation	– Présentation des sources du droit international (public / privé)\n– Analyse de l’environnement global international (OMC, UE, autres zones régionales...)\n– Droit général du contrat international : notions générales, loi applicable\n– Présentation des différents grands risques à l’international (droit applicable, résolution des litiges, familles de droit)\n– Droit spécial du contrat de vente international : cadre juridique du contrat de vente et formation du contrat, négociation,\npourparlers, médiation, arbitrage\n– Droit de la concurrence à l’international (fusions, acquisitions)\n– Protection des données et dispositifs anti-corruption, intelligence économique\nCette ressource peut être dispensée en langues étrangères.	18	18 heures	Formuler une stratégie de commerce à l’international	BI	\N	\N
207	R5.BI.10	Ressources et culture numériques appliquées au business international, achat et vente.	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher et structurer les données et informations importantes\n– Concevoir et mettre en œuvre des tableaux de bord efﬁcaces et pertinents\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité du système d’informations\n– Acquérir une culture numérique\n\nMots clés :\nERP – tableur fonction avancée – simulation – requête – sécurité	– Prise en main d’un ERP\n– Tableurs fonctions avancées : simulations, tableaux de bord,\n– Introduction au Big Data, au Data Mining	13	13 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BI	\N	\N
208	R5.BI.11	Approvisionnements	Contribution au développement de la ou des compétences ciblées :\n– Préciser la fonction d’approvisionneur/fonction d’acheteur dans l’entreprise\n– Maîtriser les outils d’analyse, optimiser les stocks\n\nMots clés :\nApprovisionnement – stock – performance	– Analyse du besoin / de la demande et suivi de commande\n– Calcul de besoin net\n– Tenue des stocks et classement selon les classes ABC : inventaires permanents, périodiques, tournants\n– Outils et techniques de gestion des stocks et des commandes\n– Système de quantité ﬁxe, à intervalles ﬁxes\n– Stock de sécurité\n– Méthode kanban\n– Analyse de la performance approvisionnement\n– Démarche d’amélioration continue\nCette ressource peut être dispensée en langues étrangères.	18	18 heures dont 4 heures de TP	Piloter les opérations à l’international	BI	\N	\N
209	R5.BI.12	Techniques du commerce international - 2	Contribution au développement de la ou des compétences ciblées :\n– Comprendre le mécanisme de l’échange des documents à l’export\n– Comprendre le mécanisme des douanes\n– Maîtriser le paiement et les risques\n\nMots clés :\nPaiement international – change – garantie – transport – logistique	– Instruments de paiement, virement et lettre de change, SWIFT\n– Techniques de paiement documentaires, cash-on-delivery, remise documentaire, crédit documentaire, lettre de crédit\nstand-by, assurance-crédit, forfaitage, affacturage\n– Risque de change, marché des changes, couverture à terme\n– Garanties BPI\n– Echanges Intra Union, dédouanement, dette douanière, régimes douaniers\n– Transport international, tariﬁcation du transport maritime, aérien et routier, groupage\nCette ressource peut être dispensée en langues étrangères.	20	20 heures dont 8 heures de TP	Piloter les opérations à l’international	BI	\N	\N
211	R5.BI.14	Logistique et supply chain	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre des compétences relationnelles, de gestion et d’organisation de la logistique pour fournir un bien ou un\nservice en délivrant la valeur maximum au client et à l’entreprise\n– Connaître les spéciﬁcités de la logistique pour une activité e-commerce\n– Etre capable de proposer des solutions pour assurer une chaîne logistique efﬁcace au national et international\n\nMots clés :\nLogistique – supply chain – ﬂux – ERP	– Les enjeux de la logistique : satisfaction clients, taux de service et coûts logistiques\n– La supply chain\n– Les ﬂux de production : gestion des stocks, des espaces et des délais\n– La logistique de distribution et du e-commerce\n– Les ﬂux d’information et les solutions digitales\n– L’optimisation de la supply chain, décision make or buy\n– Ethique et éco-responsabilité\nCette ressource peut être dispensée en langues étrangères.	18	18 heures dont 8 heures de TP	Piloter les opérations à l’international	BI	\N	\N
212	R5.BI.15	Marketing achat	Contribution au développement de la ou des compétences ciblées :\n– Analyser l’offre des fournisseurs et les actions marketing en direction de ces derniers\nContenu\n– Achats en situation complexe : cahier des charges technique et cahier des charges fonctionnel, négociation achat à\nl’international, contractualisation, gestion et suivi de la relation fournisseur (y compris évaluation des fournisseurs)\n– Démarche qualité achat, certiﬁcation et normalisation\n– Marketing achat : déﬁnition et démarche du marketing achat, segmentation\n– Déﬁnition des besoins pour ajuster la demande à l’offre\n– Interaction avec les fournisseurs dans un objectif de progression\n– Evolution des relations vers un mode partenarial\n– Utilisation et intégration des concepts de développement soutenable (DS) et de RSE\n– Pratique de la veille technologique et commerciale\nCette ressource peut être dispensée en langues étrangères.\n\nMots clés :\nFonction achat – marketing achat – fournisseur – démarche qualité		18	18 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BI	\N	\N
229	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
252	R5.BDMRC.10	Ressources et culture numériques appliquées au business développement et au	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher, recueillir et structurer les données prospects et clients aﬁn d’exploiter efﬁcacement un CRM, et le\nfaire évoluer\n– Bâtir une campagne de relation client : déterminer les objectifs, cibler les prospects, s’approprier les outils, évaluer son\nefﬁcacité\n– Concevoir, mettre en œuvre et présenter des tableaux de bord efﬁcaces et pertinents\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité et à la conﬁdentialité du système d’informations\n\nMots clés :\nERP – CRM – scoring – tableur – sécurité – protection des données – simulations	– Prise en main d’un ERP et d’un CRM\n– Techniques de construction et d’alimentation d’une base de données, scoring\n– Tableurs fonctions avancées : simulations, tableaux de bord\n– Outils de présentation et communication des tableaux de bord\n– Introduction au Big Data, et au Data Mining, etc.	13	13 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client	BDMRC	\N	\N
241	R4.BDMRC.09	Fondamentaux du management de l’équipe commerciale			0		Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
231	R3.BDMRC.15	Marketing B2B	Identiﬁer les spéciﬁcités du marketing B2B :\n– Identiﬁer le centre d’achat, ses acteurs et le processus d’achat B2B\n– Segmenter un marché B2B\n– Mettre en place le marketing-mix B2B\n– Utiliser les canaux relationnels B2B\n\nMots clés :\nAchat B2B – segmentation en B2B – mix B2B	– Veille et intelligence économique\n– Collaboration interne en vue de développer les opportunités commerciales\n– Contribution à la réactivité commerciale en développant la valeur ajoutée client	13	13 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
232	R3.BDMRC.16	Fondamentaux de la relation client	Identiﬁer les enjeux de la relation client et développer la culture client parmi les collaborateurs :\n– Adopter l’orientation client, identiﬁer les attentes relationnelles des clients\n– Écouter la voix du client sur les différents canaux de contact en surveillant les principaux indicateurs de la relation client\n(satisfaction, ﬁdélisation, NPS, etc.)\n– Présenter et situer le rôle d’un logiciel de gestion de la relation client (CRM)\n– Identiﬁer les informations pertinentes et exploitables dans l’objectif d’accumuler de la « connaissance client »\n\nMots clés :\nSatisfaction – ﬁdélisation – GRC – connaissance client	– Culture client\n– Indicateurs de la relation client\n– Logiciel CRM : présentation, rôle	13	13 heures	Manager la relation client	BDMRC	\N	\N
247	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
255	R5.BDMRC.13	Marketing des services	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer les spéciﬁcités du marketing des services\n– Maîtriser les fondamentaux de l’expérience client, de sa mesure et de la recherche d’optimisation\n– Apprécier les notions de co-construction de la valeur\n– Maîtriser les concepts fondamentaux de la qualité\n– Améliorer la qualité de service et prendre en compte la dimension organisationnelle de la qualité de service\n\nMots clés :\nQualité – qualité des services – optimisation des services	culture de service et gestion des incidences service\n– Elaboration et suivi de feed-back des clients\n– Identiﬁcation des types de participation des clients\n– Etude et compréhension des motifs de réclamation des clients (attribution, motivation, émotions)\n– Gestion des incidents de service et des clients mécontents\n– Mise en place d’une prise en charge efﬁcace des réclamations\n– Prise en compte de l’équité et de la justice organisationnelle	25	25 heures dont 6 heures de TP	Manager la relation client	BDMRC	\N	\N
253	R5.BDMRC.11	Développement des pratiques managériales	Contribution au développement de la ou des compétences ciblées :\n– Gérer la relation interpersonnelle et animer une équipe commerciale\n– Enrichir l’observation et l’écoute de l’autre\n– S’approprier un style de management\n– Fédérer les équipes autour de l’atteinte des objectifs (méthode SMART)\n– Suivre et organiser le développement des compétences du personnel (formation continue, entretien annuel, ...)\n– Valoriser les compétences des membres de l’équipe\n– Gérer le changement et les conﬂits\n\nMots clés :\nManagement relationnel – gestion des conﬂits – leadership – coaching	– Positionnement managérial et management relationnel d’une équipe\n– Motivation et valorisation, management de la différenciation\n– Facteurs clés du leadership, qualités du leader, compétences\n– Outils de coaching, de prévention et de gestion de conﬂit	23	23 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
254	R5.BDMRC.12	Management de la valeur client	Contribution au développement de la ou des compétences ciblées :\n– Manager en faveur de la valeur client en concevant une stratégie de la relation client pour améliorer la rentabilité de\nl’entreprise\n– Analyser les bases de données clients (éventuellement via l’utilisation d’un logiciel CRM) et faire un diagnostic aﬁn d’éla-\nborer des stratégies et actions marketing adaptées aux typologies de clients et aux comportements de consommation\n– Distinguer les différentes formes de ﬁdélité, ﬁdéliser et engager les clients dans une relation durable\n\nMots clés :\nPortefeuille client – CRM – segmentation – scoring – ﬁdélisation – typologie client	– Segmentation et valorisation du portefeuille clients, montée en gamme\n– Suivi de l’évolution du portefeuille clients\n– Indicateurs de performance (Net Promoter Score, ...)\n– Calcul de lifetime value (LTV), cross-selling, up-selling\n– Coût d’acquisition d’un client, ﬁdélisation\nPrérequis :\n– R5.BDMRC.10 | Ressources et culture numériques appliquées au business développement et au management de la\nrelation client	21	21 heures dont 6 heures de TP	Manager la relation client	BDMRC	\N	\N
256	R5.BDMRC.14	Pilotage de l’équipe commerciale	Contribution au développement de la ou des compétences ciblées :\n– Sélectionner les collaborateurs en considérant les besoins de l’équipe et les intégrer\n– Animer et piloter l’équipe commerciale\n– Organiser et planiﬁer les tâches de l’équipe\n– Élaborer les tableaux de reporting\n\nMots clés :\nAnimation – pilotage – tableau de bord – indicateur – opportunité commerciale	– Outils d’information (base de données clients, listes précises de prospects, état de la concurrence, ﬁches produits à jour)\n– Outils de communication (réunions internes et clients, participation, réseaux, gestion de la mobilité, intranet, reporting)\n– Outils de suivi de l’activité (évolution de la mission, tableau de bord, atteinte des objectifs...)\nPrérequis :\n– R5.BDMRC.10 | Ressources et culture numériques appliquées au business développement et au management de la\nrelation client	23	23 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
140	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	MDEE	\N	\N
187	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	BI	\N	\N
94	R4.01	Stratégie marketing			0		Conduire les actions marketing	BDMRC	\N	\N
233	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	BDMRC	\N	\N
155	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
257	R6.01	Stratégie d’entreprise - 2			0		Conduire les actions marketing	BDMRC	\N	\N
217	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	BDMRC	\N	\N
218	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	BDMRC	\N	\N
219	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	BDMRC	\N	\N
189	R4.03	Conception d’une campagne de communication	Contribuer au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication adaptée à un cahier des charges\n– Proposer un plan de communication\n\nMots clés : Stratégie communication commerciale – plan média – copy-stratégie – analyse de la performance	– Réﬂexion stratégique : cibles, objectifs, stratégie de communication (ressources S1) / élaboration du budget de cam-\npagne\n– Indicateurs de choix des supports : audience utile, afﬁnité, coût pour mille\n– Plan média : approche 360◦, cohérence des moyens\n– Stratégie de création de contenu et messages performatifs / brief, copy-stratégie, storyboard, copy-writing\n– Évaluation et analyse d’une campagne : pré-test et post-test	0		Communiquer l’offre commerciale	BI	\N	\N
235	R4.03	Conception d’une campagne de communication	Contribuer au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication adaptée à un cahier des charges\n– Proposer un plan de communication\n\nMots clés : Stratégie communication commerciale – plan média – copy-stratégie – analyse de la performance	– Réﬂexion stratégique : cibles, objectifs, stratégie de communication (ressources S1) / élaboration du budget de cam-\npagne\n– Indicateurs de choix des supports : audience utile, afﬁnité, coût pour mille\n– Plan média : approche 360◦, cohérence des moyens\n– Stratégie de création de contenu et messages performatifs / brief, copy-stratégie, storyboard, copy-writing\n– Évaluation et analyse d’une campagne : pré-test et post-test	0		Communiquer l’offre commerciale	BDMRC	\N	\N
220	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	BDMRC	\N	\N
142	R4.03	Conception d’une campagne de communication			0		Communiquer l’offre commerciale	BDMRC	\N	\N
143	R4.04	Droit du travail			0		Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
258	R6.02	Négocier dans des contextes spéciﬁques - 2			0		Vendre une offre commerciale	BDMRC	\N	\N
222	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
223	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
224	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
225	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Participer à la stratégie marketing et commerciale de l’organisation, Conduire les actions marketing	BDMRC	\N	\N
226	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
227	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
228	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
136	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
230	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
243	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	BDMRC	\N	\N
149	R4.MDEE.10	Stratégie e-commerce			0		Gérer une activité digitale	MDEE	\N	\N
238	R4.06	LV B appliquée au commerce - 4			0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
244	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	BDMRC	\N	\N
245	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing	BDMRC	\N	\N
246	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Participer à la stratégie marketing et commerciale de l’organisation, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
248	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
249	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
250	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
251	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
240	R4.08	PPP - 4	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
123	R6.MMPV.04	Prise de décision-pilotage			0		Piloter un espace de vente	MMPV	\N	\N
194	R4.08	PPP - 4			0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
195	R4.BI.09	Stratégie achats			0		Formuler une stratégie de commerce à l’international	BI	\N	\N
196	R4.BI.10	Techniques du commerce international - 1			0		Piloter les opérations à l’international	BI	\N	\N
197	R4.BI.11	Management interculturel			0		Formuler une stratégie de commerce à l’international	BI	\N	\N
236	R4.04	Droit du travail			0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
52	R4.06	LV B appliquée au commerce - 4			0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
48	R4.02	Négociation : rôle du vendeur et de l’acheteur			0		Vendre une offre commerciale	BDMRC	\N	\N
51	R4.05	Anglais appliqué au commerce - 4			0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
53	R4.07	Expression, communication, culture - 4			0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
31	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	MMPV	\N	\N
32	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	MMPV	\N	\N
33	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	MMPV	\N	\N
34	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	MMPV	\N	\N
35	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Conduire les actions marketing	MMPV	\N	\N
36	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
37	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Elaborer l’identité d’une marque, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
61	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
38	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
39	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Conduire les actions marketing	MMPV	\N	\N
40	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
41	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
42	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
43	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
44	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
95	R4.02	Négociation : rôle du vendeur et de l’acheteur			0		Vendre une offre commerciale	MMPV	\N	\N
190	R4.04	Droit du travail			0		Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
98	R4.05	Anglais appliqué au commerce - 4			0		Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
100	R4.07	Expression, communication, culture - 4			0		Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
54	R4.08	PPP - 4			0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
102	R4.MMPV.09	Merchandising			0		Piloter un espace de vente	MMPV	\N	\N
103	R4.MMPV.10	Management des équipes - 1			0		Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
104	R4.MMPV.11	GRC			0		Piloter un espace de vente	MMPV	\N	\N
58	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	MMPV	\N	\N
59	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	MMPV	\N	\N
60	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing	MMPV	\N	\N
62	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
63	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
64	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
65	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
66	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
74	R6.01	Stratégie d’entreprise - 2			0		Conduire les actions marketing	MMPV	\N	\N
75	R6.02	Négocier dans des contextes spéciﬁques - 2			0		Vendre une offre commerciale	MMPV	\N	\N
122	R6.MMPV.03	Droit du travail et relations sociales dans l’entreprise			0		Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
109	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
78	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	MDEE	\N	\N
79	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	MDEE	\N	\N
80	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	MDEE	\N	\N
81	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	MDEE	\N	\N
82	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Conduire les actions marketing	MDEE	\N	\N
83	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
84	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
108	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
85	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
86	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing	MDEE	\N	\N
87	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
88	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
89	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
90	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
91	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
141	R4.02	Négociation : rôle du vendeur et de l’acheteur			0		Vendre une offre commerciale	MDEE	\N	\N
144	R4.05	Anglais appliqué au commerce - 4			0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
99	R4.06	LV B appliquée au commerce - 4			0		Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
146	R4.07	Expression, communication, culture - 4			0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
148	R4.MDEE.09	Conduite de projet digital			0		Gérer une activité digitale	MDEE	\N	\N
150	R4.MDEE.11	Business model - 1			0		Développer un projet e-business	MDEE	\N	\N
105	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	MDEE	\N	\N
106	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	MDEE	\N	\N
107	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing	MDEE	\N	\N
110	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
111	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
112	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
113	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
120	R6.01	Stratégie d’entreprise - 2			0		Conduire les actions marketing	MDEE	\N	\N
121	R6.02	Négocier dans des contextes spéciﬁques - 2			0		Vendre une offre commerciale	MDEE	\N	\N
169	R6.MDEE.03	Traﬁc management - analyse d’audience			0		Gérer une activité digitale	MDEE	\N	\N
170	R6.MDEE.04	Formalisation et sécurisation d’un business model			0		Développer un projet e-business	MDEE	\N	\N
124	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	BI	\N	\N
125	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	BI	\N	\N
126	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	BI	\N	\N
127	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	BI	\N	\N
128	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing	BI	\N	\N
129	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Gérer une activité digitale, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
130	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
131	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
132	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Conduire les actions marketing	BI	\N	\N
133	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
134	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
135	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
172	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	BDMRC	\N	\N
137	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
188	R4.02	Négociation : rôle du vendeur et de l’acheteur			0		Vendre une offre commerciale	BI	\N	\N
49	R4.03	Conception d’une campagne de communication			0		Communiquer l’offre commerciale	BI	\N	\N
50	R4.04	Droit du travail			0		Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
191	R4.05	Anglais appliqué au commerce - 4			0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
145	R4.06	LV B appliquée au commerce - 4			0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
193	R4.07	Expression, communication, culture - 4			0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
101	R4.08	PPP - 4			0		Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
151	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	BI	\N	\N
152	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	BI	\N	\N
153	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Développer un projet e-business, Conduire les actions marketing	BI	\N	\N
154	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
97	R4.04	Droit du travail			0		Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
237	R4.05	Anglais appliqué au commerce - 4			0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
192	R4.06	LV B appliquée au commerce - 4			0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
239	R4.07	Expression, communication, culture - 4			0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
156	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
157	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
158	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Gérer une activité digitale, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
159	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
167	R6.01	Stratégie d’entreprise - 2			0		Conduire les actions marketing	BI	\N	\N
168	R6.02	Négocier dans des contextes spéciﬁques - 2			0		Vendre une offre commerciale	BI	\N	\N
215	R6.BI.03	Anglais appliqué au business international			0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BI	\N	\N
216	R6.BI.04	LVB appliquée au commerce international			0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BDMRC	\N	\N
171	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	BDMRC	\N	\N
173	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	BDMRC	\N	\N
174	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	BDMRC	\N	\N
175	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Formuler une stratégie de commerce à l’international, Conduire les actions marketing	BDMRC	\N	\N
176	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
177	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
178	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
179	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Conduire les actions marketing	BDMRC	\N	\N
147	R4.08	PPP - 4			0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
180	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
181	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
182	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
183	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
184	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
47	R4.01	Stratégie marketing			0		Conduire les actions marketing	BDMRC	\N	\N
234	R4.02	Négociation : rôle du vendeur et de l’acheteur			0		Vendre une offre commerciale	BDMRC	\N	\N
96	R4.03	Conception d’une campagne de communication			0		Communiquer l’offre commerciale	BDMRC	\N	\N
198	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	BDMRC	\N	\N
199	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	BDMRC	\N	\N
200	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Formuler une stratégie de commerce à l’international, Conduire les actions marketing	BDMRC	\N	\N
201	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
202	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Formuler une stratégie de commerce à l’international, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
203	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
204	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
205	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
206	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
213	R6.01	Stratégie d’entreprise - 2			0		Conduire les actions marketing	BDMRC	\N	\N
214	R6.02	Négocier dans des contextes spéciﬁques - 2			0		Vendre une offre commerciale	BDMRC	\N	\N
259	R6.BDMRC.03	Management des comptes-clés (KAM)			0		Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
260	R6.BDMRC.04	Nouveaux comportements des clients			0		Manager la relation client	BDMRC	\N	\N
\.


--
-- Data for Name: resourceaclink; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.resourceaclink (resource_id, ac_id) FROM stdin;
1	2
1	3
1	1
2	13
2	18
2	17
2	16
3	28
3	31
3	30
4	2
4	28
4	1
5	1
6	30
6	1
7	31
7	1
7	16
8	15
8	1
9	2
9	1
10	2
10	30
10	17
10	16
11	13
11	28
11	30
11	1
11	2
12	13
12	28
12	30
12	1
12	2
13	18
13	30
13	1
13	16
13	2
13	17
14	30
14	1
14	18
15	15
15	18
15	13
15	28
15	30
15	3
15	31
15	4
15	1
15	16
15	2
15	14
15	29
15	17
16	4
16	3
17	15
17	16
17	14
17	18
17	17
18	29
18	31
18	30
19	3
19	4
19	2
20	15
20	29
20	14
20	30
20	18
20	4
21	31
21	16
21	3
21	2
22	31
22	15
22	16
22	29
22	14
22	4
23	4
24	30
24	17
25	15
25	3
25	14
25	30
25	2
25	13
25	4
26	18
26	3
26	14
26	30
26	2
26	13
26	4
27	18
27	3
27	14
27	30
27	2
27	13
27	4
28	31
28	15
28	14
28	30
28	2
28	3
28	4
29	14
29	30
29	1
29	18
30	31
30	15
30	16
30	18
30	29
30	3
30	1
30	28
30	14
30	30
30	2
30	13
30	17
30	4
45	48
45	45
45	46
45	44
46	35
46	8
46	22
46	24
46	7
46	37
46	32
46	23
46	38
46	33
46	44
46	19
46	20
46	39
46	46
46	21
46	6
46	45
46	47
46	36
46	34
46	48
46	5
67	43
67	53
68	41
68	42
68	40
69	43
70	52
70	51
71	50
71	53
72	41
72	42
72	40
73	52
73	26
73	27
73	43
73	40
73	41
73	50
73	53
73	10
73	9
73	11
73	49
73	25
73	42
73	51
73	12
92	55
92	54
93	35
93	8
93	22
93	65
93	24
93	62
93	32
93	66
93	23
93	7
93	64
93	33
93	55
93	56
93	19
93	20
93	54
93	21
93	6
93	63
93	34
93	5
114	57
114	71
115	67
115	72
115	71
115	70
115	68
116	57
116	59
116	61
116	58
116	60
117	67
117	69
118	67
118	68
118	69
119	26
119	27
119	57
119	59
119	67
119	61
119	10
119	9
119	11
119	60
119	25
119	58
119	72
119	71
119	70
119	68
119	69
119	12
138	74
138	75
138	73
138	76
138	77
139	35
139	8
139	22
139	76
139	24
139	7
139	32
139	23
139	33
139	19
139	20
139	83
139	84
139	87
139	6
139	21
139	88
139	73
139	86
139	77
139	74
139	34
139	75
139	85
139	5
160	90
160	91
160	78
160	92
160	79
161	89
161	93
161	94
162	81
162	80
162	78
162	82
162	79
163	81
163	80
163	78
163	82
163	79
164	90
164	91
164	89
164	94
164	92
165	81
165	80
165	78
165	82
165	79
166	90
166	26
166	81
166	27
166	80
166	91
166	93
166	89
166	92
166	9
166	10
166	11
166	25
166	78
166	94
166	82
166	12
166	79
185	97
185	95
185	96
186	35
186	102
186	8
186	22
186	96
186	101
186	24
186	7
186	32
186	23
186	97
186	95
186	33
186	19
186	20
186	21
186	6
186	103
186	104
186	34
186	5
155	11
155	98
155	27
207	98
207	108
208	106
208	105
208	107
208	108
209	106
209	105
209	107
210	98
210	100
210	99
229	35
229	32
229	34
229	111
229	6
229	22
229	112
229	118
229	109
229	19
229	20
229	5
229	116
229	7
211	106
211	105
211	107
212	105
212	26
212	27
212	100
212	107
212	9
212	10
212	11
212	98
212	99
212	25
212	106
212	12
212	108
217	8
217	7
218	23
218	21
218	22
218	19
218	20
219	35
219	32
220	5
220	6
220	7
221	6
221	7
222	35
222	32
222	119
222	21
222	112
222	33
222	7
223	23
223	6
223	8
223	33
223	117
223	24
224	34
224	23
224	21
224	8
224	110
224	117
225	111
225	110
225	109
225	5
225	7
226	35
226	32
226	34
226	23
226	6
226	8
226	22
226	110
226	118
226	33
226	19
226	20
226	5
226	24
226	116
226	7
227	35
227	32
227	34
227	23
227	6
227	8
227	22
227	33
227	19
227	20
227	5
227	24
227	7
228	35
228	34
228	23
228	6
228	22
228	109
228	117
136	35
136	32
136	34
136	111
136	6
136	22
136	112
136	118
136	109
136	19
136	20
136	5
136	116
136	7
230	35
230	8
230	22
230	109
230	117
230	24
230	7
230	32
230	23
230	33
230	19
230	20
230	116
230	21
230	6
230	118
230	112
230	34
230	119
230	111
230	110
230	5
231	112
231	110
231	109
232	35
232	8
232	22
232	109
232	117
232	24
232	7
232	32
232	23
232	33
232	19
232	20
232	116
232	21
232	6
232	118
232	112
232	34
232	119
232	111
232	110
232	5
243	11
243	9
244	26
244	27
245	115
245	10
245	9
245	121
245	12
246	12
246	26
246	10
246	115
247	11
247	27
247	120
248	122
248	27
248	114
248	115
248	11
248	25
248	12
249	122
249	27
249	114
249	115
249	11
249	25
249	12
250	122
250	27
250	114
250	10
250	9
250	115
250	12
251	122
251	26
251	27
251	114
251	123
251	10
251	9
251	11
251	115
251	25
251	121
251	113
251	12
251	120
252	114
252	122
252	123
253	114
253	113
254	122
254	123
254	121
31	8
31	7
32	23
32	21
32	22
32	19
32	20
33	35
33	32
34	5
34	6
34	7
35	6
35	7
36	35
36	32
36	62
36	21
36	33
36	65
36	7
37	23
37	6
37	8
37	33
37	54
37	24
38	34
38	23
38	21
38	8
38	63
38	54
39	55
39	5
39	56
39	7
40	35
40	32
40	34
40	23
40	62
40	6
40	64
40	8
40	22
40	33
40	55
40	19
40	20
40	5
40	24
40	7
41	35
41	32
41	34
41	23
41	6
41	8
41	22
41	33
41	19
41	20
41	5
41	24
41	7
42	35
42	34
42	62
42	23
42	6
42	22
42	55
42	56
42	65
43	35
43	32
43	34
43	62
43	64
43	6
43	22
43	55
43	19
43	20
43	5
43	7
44	35
44	8
44	22
44	65
44	24
44	62
44	32
44	7
44	23
44	64
44	66
44	33
44	55
44	56
44	19
44	20
44	54
44	21
44	6
44	63
44	34
44	5
58	11
58	9
59	26
59	27
60	57
60	67
60	10
60	9
60	12
61	12
61	67
61	26
61	10
62	11
62	27
62	57
63	27
63	11
63	69
63	25
63	68
63	60
63	12
64	27
64	11
64	69
64	25
64	68
64	60
64	12
65	27
65	10
65	9
65	58
65	68
65	12
66	26
66	27
66	57
66	59
66	61
66	67
66	10
66	9
66	11
66	69
66	25
66	58
66	72
66	71
66	70
66	68
66	60
66	12
78	8
78	7
79	23
79	21
79	22
79	19
79	20
80	35
80	32
81	5
81	6
81	7
82	84
82	76
82	6
82	7
83	35
83	32
83	74
83	21
83	33
83	76
83	7
84	23
84	6
84	8
84	33
84	83
84	24
85	34
85	23
85	21
85	8
85	85
85	73
85	86
85	83
86	5
86	7
87	35
87	32
87	34
87	23
87	74
87	6
87	75
87	8
87	22
87	88
87	33
87	19
87	20
87	5
87	84
87	24
87	7
88	35
88	32
88	34
88	23
88	6
88	8
88	22
88	33
88	19
88	20
88	5
88	24
88	7
89	35
89	34
89	74
89	23
89	87
89	6
89	22
89	88
89	73
89	76
90	35
90	32
90	34
90	74
90	6
90	75
90	22
90	88
90	19
90	20
90	5
90	84
90	7
91	35
91	8
91	22
91	76
91	24
91	7
91	32
91	23
91	33
91	19
91	20
91	83
91	84
91	21
91	6
91	87
91	88
91	73
91	86
91	77
91	74
91	34
91	75
91	85
91	5
105	11
105	9
106	26
106	27
107	12
107	89
107	10
107	9
108	12
108	89
108	26
108	10
109	11
109	91
109	89
109	27
110	27
110	11
110	25
110	94
110	12
110	79
111	27
111	11
111	25
111	94
111	12
111	79
112	27
112	80
112	10
112	9
112	12
112	79
113	90
113	26
113	27
113	81
113	80
113	91
113	93
113	89
113	92
113	10
113	9
113	11
113	25
113	78
113	94
113	82
113	12
113	79
124	8
124	7
125	23
125	21
125	22
125	19
125	20
126	35
126	32
127	5
127	6
127	7
128	97
128	95
128	6
128	7
129	35
129	32
129	21
129	33
129	7
130	23
130	6
130	8
130	33
130	24
131	34
131	23
131	21
131	8
131	103
132	5
132	7
133	35
133	32
133	34
133	23
133	6
133	8
133	22
133	96
133	33
133	19
133	101
133	20
133	5
133	104
133	24
133	7
134	35
134	32
134	34
134	23
134	6
134	8
134	22
134	96
134	33
134	19
134	101
134	20
134	5
134	104
134	24
134	7
135	35
135	34
135	23
135	6
135	102
135	22
135	95
135	96
135	101
254	120
255	122
255	123
255	121
255	120
256	122
256	26
256	27
256	114
256	123
256	10
137	35
137	102
137	8
137	22
137	96
137	101
137	24
137	7
137	32
137	23
137	97
137	95
137	33
137	19
137	20
137	21
137	6
137	103
137	104
137	34
137	5
151	11
151	9
152	26
152	27
153	100
153	10
153	9
153	98
153	99
153	12
154	12
154	26
154	107
154	10
256	9
256	11
256	115
156	27
156	105
156	11
156	99
156	25
156	12
157	27
157	105
157	11
157	99
157	25
157	12
158	27
158	105
158	10
158	9
158	99
158	12
159	26
159	27
159	105
159	100
159	107
159	10
159	9
159	11
159	98
159	99
159	25
159	106
159	108
159	12
171	8
171	7
172	23
172	21
172	22
172	19
172	20
173	35
173	32
174	5
174	6
174	7
175	6
175	7
176	35
176	32
176	119
176	21
176	112
176	33
176	7
177	23
177	6
177	8
177	33
177	117
177	24
178	34
178	23
178	21
178	8
178	110
178	117
179	111
179	110
179	109
179	5
179	7
180	35
180	32
180	34
180	23
180	6
180	8
180	22
180	110
180	118
180	33
180	19
180	20
180	5
180	24
180	116
180	7
181	35
181	32
181	34
181	23
181	6
181	8
181	22
181	33
181	19
181	20
181	5
181	24
181	7
182	35
182	34
182	23
182	6
182	22
182	109
182	117
183	35
183	32
183	34
183	111
183	6
183	22
183	112
183	118
183	109
183	19
183	20
183	5
183	116
183	7
184	35
184	8
184	22
184	109
184	117
184	24
184	7
184	32
184	23
184	33
184	19
184	20
184	116
184	21
184	6
184	118
184	112
184	34
184	119
184	111
184	110
184	5
198	11
198	9
199	26
199	27
200	115
200	10
200	9
200	121
200	12
201	12
201	26
201	10
201	115
202	11
202	27
202	120
203	122
203	27
203	114
203	115
203	11
203	25
203	12
204	122
204	27
204	114
204	115
204	11
204	25
204	12
205	122
205	27
205	114
205	10
205	9
205	115
205	12
206	122
206	26
206	27
206	114
206	123
206	10
206	9
206	11
206	115
206	25
206	121
206	113
206	12
206	120
256	25
256	121
256	113
256	12
256	120
\.


--
-- Data for Name: responsibilitymatrix; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.responsibilitymatrix (id, user_id, entity_type, entity_id, role_type, academic_year) FROM stdin;
7	davidm	RESOURCE	R1.01	INTERVENANT	2025-2026
11	millemi	RESOURCE	R1.01	INTERVENANT	2025-2026
13	davidm	ACTIVITY	3	INTERVENANT	2025-2026
16	millemi	RESOURCE	R1.13	INTERVENANT	2025-2026
17	davidm	ACTIVITY	1	INTERVENANT	2025-2026
20	millemi	RESOURCE	R2.01	OWNER	2025-2026
28	millemi	ACTIVITY	34	INTERVENANT	2025-2026
29	tabellth	ACTIVITY	34	INTERVENANT	2025-2026
30	montieca	ACTIVITY	34	INTERVENANT	2025-2026
35	millemi	RESOURCE	R1.04	OWNER	2025-2026
41	millemi	STUDENT	pytels	TUTOR	2025-2026
46	tabellth	RESOURCE	R1.06	OWNER	2025-2026
47	pytels	RESOURCE	R1.13	OWNER	2025-2026
48	pytels	RESOURCE	R1.07	OWNER	2025-2026
51	pytels	ACTIVITY	34	OWNER	2025-2026
52	tabellth	ACTIVITY	1	OWNER	2025-2026
53	khaledz	ACTIVITY	5	OWNER	2025-2026
54	tabellth	ACTIVITY	8	OWNER	2025-2026
55	davidm	STUDENT	bm250979	TUTOR	2025-2026
56	davidm	STUDENT	gj252592	TUTOR	2025-2026
57	pytels	STUDENT	tc	TUTOR	2025-2026
58	tabellth	ACTIVITY	10	OWNER	2025-2026
\.


--
-- Data for Name: rubriccriterion; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.rubriccriterion (id, rubric_id, ac_id, ce_id, label, description, weight) FROM stdin;
54	10	4	\N	Concevoir une offre cohérente et éthique en termes de produits, de prix, de distribution et de communication	\N	1
53	10	3	\N	Choisir une cible et un positionnement en fonction de la segmentation du marché	\N	4
55	10	2	\N	Mettre en oeuvre une étude de marché dans un environnement simple	\N	1.5
56	10	\N	\N	Serie	\N	3.5
63	11	\N	\N	horraire	\N	1
64	11	\N	\N	serieux	\N	1
57	11	1	\N	Analyser l'environnement d'une entreprise en repérant et appréciant les sources d'informations	\N	6
58	11	2	\N	Mettre en oeuvre une étude de marché dans un environnement simple	\N	6
59	11	3	\N	Choisir une cible et un positionnement en fonction de la segmentation du marché	\N	6
67	12	81	\N	S'appuyer sur les indicateurs de performances pour améliorer la relation client	\N	1
68	12	12	\N	Intégrer la RSE dans la stratégie de l'offre	\N	1
66	12	27	\N	Maîtriser les codes propres à l'univers spécifique rencontré	\N	2.5
72	12	9	\N	Mettre en place des outils de veille pour anticiper les évolutions de l'environnement	\N	3
73	12	10	\N	Élaborer une stratégie marketing dans un environnement instable	\N	2
70	12	25	\N	Identifier les techniques d’achat employées par un acheteur professionnel	\N	2
69	12	94	\N	Développer un projet de façon proactive	\N	1.5
74	12	\N	\N	presentation	\N	1.5
75	12	\N	\N	orale	\N	1.5
71	12	11	\N	Faire évoluer l'offre à l'aide de leviers de création de valeur	\N	1.5
65	12	90	\N	Faire des préconisations grâce aux outils du diagnostic stratégique	\N	2.5
\.


--
-- Data for Name: studentfile; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.studentfile (id, student_uid, filename, nc_path, entity_type, entity_id, is_locked, uploaded_at) FROM stdin;
1	pytels	Capture_d'écran_2026-01-14_140546.png	SkillsHub/pytels/ResponsibilityEntityType.ACTIVITY_45/Capture_d'écran_2026-01-14_140546.png	ACTIVITY	45	f	2026-01-14 20:25:15.082687
2	pytels	81o-7Rz9ZEL._UF1000,1000_QL80_.jpg	SkillsHub/pytels/ResponsibilityEntityType.ACTIVITY_45/81o-7Rz9ZEL._UF1000,1000_QL80_.jpg	ACTIVITY	45	f	2026-01-14 20:27:23.531205
\.


--
-- Data for Name: studentppp; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.studentppp (id, student_uid, content_json, career_goals, updated_at) FROM stdin;
1	tc	{}	\N	2026-01-29 12:06:14.069382
\.


--
-- Data for Name: systemconfig; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.systemconfig (id, key, value, category) FROM stdin;
1	ldap_url	ldap://ldap:389	ldap
2	ldap_base_dn	dc=univ,dc=fr	ldap
3	smtp_host	mail	mail
4	smtp_port	1025	mail
6	APP_LOGO_URL	https://www-iut.univ-lehavre.fr/wp-content/uploads/2024/12/cropped-logo-IUT_WEB-5-3.png	branding
8	APP_WELCOME_MESSAGE	Bienvenue sur Skills Hub	branding
5	mistral_api_key	3a218ppqAlBzjegiqPSu3JF0c8krF5fo	ai
12	ai_api_key	3a218ppqAlBzjegiqPSu3JF0c8krF5fo	ai
9	ai_provider	codestral	ai
10	ai_model	codestral-latest	ai
11	ai_endpoint	https://codestral.mistral.ai/v1	ai
7	APP_PRIMARY_COLOR	#1971c2	branding
13	ACTIVE_PATHWAYS	BDMRC,MDEE,MMPV	pedagogy
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public."user" (id, ldap_uid, email, full_name, role, group_id, phone) FROM stdin;
1	emma.dupont78	emma.dupont78@etu.univ.fr	Emma DUPONT	GUEST	\N	\N
2	marie.moreau93	marie.moreau93@etu.univ.fr	Marie MOREAU	GUEST	\N	\N
3	nicolas.dupont87	nicolas.dupont87@etu.univ.fr	Nicolas DUPONT	GUEST	\N	\N
18	marie.simon28	marie.simon28@etu.univ.fr	Marie SIMON	GUEST	\N	\N
50	bl251857	lucie.ba@etu.univ-lehavre.fr	Lucie Ba	STUDENT	62	\N
51	bf252370	feinda.bakhayokho@etu.univ-lehavre.fr	Feinda Bakhayokho	STUDENT	62	\N
54	bj250155	jalil.bel-imam--letellier@etu.univ-lehavre.fr	Jalil Bel imam--letellier	STUDENT	63	\N
210	gt231116	thomas.godard@etu.univ-lehavre.fr	Thomas Godard	STUDENT	69	\N
53	bc252577	clemence.beauchamps--jeanne@etu.univ-lehavre.fr	Clemence Beauchamps--jeanne	STUDENT	64	\N
55	bl252505	lehna.benslimane@etu.univ-lehavre.fr	Lehna Benslimane	STUDENT	63	\N
44	ar251429	riad.aissaoui@etu.univ-lehavre.fr	Riad Aissaoui	STUDENT	60	\N
60	bn250395	nathan-david.bothorel@etu.univ-lehavre.fr	Nathan-david Bothorel	STUDENT	61	\N
47	an241357	nellyna.audal--frovil@etu.univ-lehavre.fr	Nellyna Audal--frovil	STUDENT	61	\N
48	al252868	lalie.audouard@etu.univ-lehavre.fr	Lalie Audouard	STUDENT	61	\N
211	gr232671	raphaelle.grieu@etu.univ-lehavre.fr	Raphaelle Grieu	STUDENT	68	\N
52	bk252733	kadiatou.balde@etu.univ-lehavre.fr	Kadiatou Balde	STUDENT	63	\N
215	ky220837	yah.kouame-schmidt@etu.univ-lehavre.fr	Yah Kouame-schmidt	STUDENT	68	\N
220	ll232815	lena.lefevre@etu.univ-lehavre.fr	Lena Lefevre	STUDENT	68	\N
56	bi250967	iliana.bensmaine@etu.univ-lehavre.fr	Iliana Bensmaine	STUDENT	63	\N
242	ao242575	olasubomi.adeniyi@etu.univ-lehavre.fr	Olasubomi Adeniyi	STUDENT	71	\N
49	ad251637	dorine.avenel@etu.univ-lehavre.fr	Dorine Avenel	STUDENT	62	\N
57	br250653	rossana.bettencourt-da-silva-carvalho@etu.univ-lehavre.fr	Rossana Bettencourt da silva carvalho	STUDENT	60	\N
58	bn252938	noe.bloino@etu.univ-lehavre.fr	Noe Bloino	STUDENT	63	\N
61	bj252564	joris.bouchez@etu.univ-lehavre.fr	Joris Bouchez	STUDENT	63	\N
59	bm250979	mila.bonnet@etu.univ-lehavre.fr	Mila Bonnet	STUDENT	64	\N
199	ca211054	antonin.chapelle@etu.univ-lehavre.fr	Antonin Chapelle	STUDENT	66	\N
203	dl230848	leo.delozier@etu.univ-lehavre.fr	Leo Delozier	STUDENT	66	\N
204	dj231904	justine.deschamps@etu.univ-lehavre.fr	Justine Deschamps	STUDENT	66	\N
4	emma.martin16	emma.martin16@etu.univ.fr	Emma MARTIN	GUEST	\N	\N
5	jean.roux79	jean.roux79@etu.univ.fr	Jean ROUX	GUEST	\N	\N
6	sophie.petit89	sophie.petit89@etu.univ.fr	Sophie PETIT	GUEST	\N	\N
7	nicolas.martin13	nicolas.martin13@etu.univ.fr	Nicolas MARTIN	GUEST	\N	\N
8	nicolas.lefebvre43	nicolas.lefebvre43@etu.univ.fr	Nicolas LEFEBVRE	GUEST	\N	\N
9	emma.roux34	emma.roux34@etu.univ.fr	Emma ROUX	GUEST	\N	\N
10	julie.durand50	julie.durand50@etu.univ.fr	Julie DURAND	GUEST	\N	\N
11	marie.simon14	marie.simon14@etu.univ.fr	Marie SIMON	GUEST	\N	\N
12	jean.dupont98	jean.dupont98@etu.univ.fr	Jean DUPONT	GUEST	\N	\N
13	emma.petit57	emma.petit57@etu.univ.fr	Emma PETIT	GUEST	\N	\N
14	antoine.dupont29	antoine.dupont29@etu.univ.fr	Antoine DUPONT	GUEST	\N	\N
20	nicolas.garcia31	nicolas.garcia31@etu.univ.fr	Nicolas GARCIA	GUEST	\N	\N
21	marie.garcia70	marie.garcia70@etu.univ.fr	Marie GARCIA	GUEST	\N	\N
22	julie.dupont12	julie.dupont12@etu.univ.fr	Julie DUPONT	GUEST	\N	\N
23	jean.dupont30	jean.dupont30@etu.univ.fr	Jean DUPONT	GUEST	\N	\N
24	antoine.dupont82	antoine.dupont82@etu.univ.fr	Antoine DUPONT	GUEST	\N	\N
25	nicolas.simon43	nicolas.simon43@etu.univ.fr	Nicolas SIMON	GUEST	\N	\N
26	lucas.martin68	lucas.martin68@etu.univ.fr	Lucas MARTIN	GUEST	\N	\N
27	emma.roux10	emma.roux10@etu.univ.fr	Emma ROUX	GUEST	\N	\N
28	sophie.lefebvre61	sophie.lefebvre61@etu.univ.fr	Sophie LEFEBVRE	GUEST	\N	\N
29	pierre.lefebvre22	pierre.lefebvre22@etu.univ.fr	Pierre LEFEBVRE	GUEST	\N	\N
30	julie.lefebvre86	julie.lefebvre86@etu.univ.fr	Julie LEFEBVRE	GUEST	\N	\N
31	sophie.lefebvre55	sophie.lefebvre55@etu.univ.fr	Sophie LEFEBVRE	GUEST	\N	\N
32	thomas.moreau97	thomas.moreau97@etu.univ.fr	Thomas MOREAU	GUEST	\N	\N
33	marie.petit63	marie.petit63@etu.univ.fr	Marie PETIT	GUEST	\N	\N
34	emma.garcia95	emma.garcia95@etu.univ.fr	Emma GARCIA	GUEST	\N	\N
35	jean.dupont60	jean.dupont60@etu.univ.fr	Jean DUPONT	GUEST	\N	\N
15	sophie.simon48	sophie.simon48@etu.univ.fr	Sophie SIMON	GUEST	\N	\N
16	marie.leroy81	marie.leroy81@etu.univ.fr	Marie LEROY	GUEST	\N	\N
17	pierre.durand11	pierre.durand11@etu.univ.fr	Pierre DURAND	GUEST	\N	\N
19	antoine.durand10	antoine.durand10@etu.univ.fr	Antoine DURAND	GUEST	\N	\N
209	gg253671	godwin-alphonse.gninevi@etu.univ-lehavre.fr	Godwin alphonse Gninevi	STUDENT	67	\N
212	jj231322	janelle.jacq-bonnechere@etu.univ-lehavre.fr	Janelle Jacq--bonnechere	STUDENT	68	\N
213	kc231261	camelia.kadi@etu.univ-lehavre.fr	Camelia Kadi	STUDENT	68	\N
214	kr231780	romane.kiehl@etu.univ-lehavre.fr	Romane Kiehl	STUDENT	69	\N
217	lq231372	quentin.landemaine@etu.univ-lehavre.fr	Quentin Landemaine	STUDENT	69	\N
221	lj230616	jade.lehodey@etu.univ-lehavre.fr	Jade Lehodey	STUDENT	69	\N
245	an240751	nathan.annest-dur@etu.univ-lehavre.fr	Nathan Annest-dur	STUDENT	73	\N
250	bv241118	valere.beauvais@etu.univ-lehavre.fr	Valere Beauvais	STUDENT	71	\N
254	bm242285	marius.bride@etu.univ-lehavre.fr	Marius Bride	STUDENT	74	\N
259	cq242200	quentin.chaumont@etu.univ-lehavre.fr	Quentin Chaumont	STUDENT	73	\N
264	ci240770	ines.crespin@etu.univ-lehavre.fr	Ines Crespin	STUDENT	73	\N
269	dl241212	lola.ducastel@etu.univ-lehavre.fr	Lola Ducastel	STUDENT	73	\N
36	prof.1	prof.1@univ-lehavre.fr	Prof1 PROFESSEUR1	GUEST	\N	\N
37	prof.2	prof.2@univ-lehavre.fr	Prof2 PROFESSEUR2	GUEST	\N	\N
38	prof.3	prof.3@univ-lehavre.fr	Prof3 PROFESSEUR3	GUEST	\N	\N
39	prof.4	prof.4@univ-lehavre.fr	Prof4 PROFESSEUR4	GUEST	\N	\N
40	prof.5	prof.5@univ-lehavre.fr	Prof5 PROFESSEUR5	GUEST	\N	\N
41	prof.6	prof.6@univ-lehavre.fr	Prof6 PROFESSEUR6	GUEST	\N	\N
42	prof.7	prof.7@univ-lehavre.fr	Prof7 PROFESSEUR7	GUEST	\N	\N
227	mh230864	hubercia.massamba@etu.univ-lehavre.fr	Hubercia Massamba	STUDENT	67	\N
228	mk220329	kamelia.mouaoued@etu.univ-lehavre.fr	Kamelia Mouaoued	STUDENT	66	\N
229	oc243330	christianne.ogoe@etu.univ-lehavre.fr	Christianne Ogoe	STUDENT	66	\N
230	ov233784	viktoriia.ohirko@etu.univ-lehavre.fr	Viktoriia Ohirko	STUDENT	66	\N
231	ps231658	selena.peter@etu.univ-lehavre.fr	Selena Peter	STUDENT	66	\N
301	ms232231	sanaa.mekkaoui@etu.univ-lehavre.fr	Sanaa Mekkaoui	STUDENT	73	\N
232	pa230715	achille.plaisant@etu.univ-lehavre.fr	Achille Plaisant	STUDENT	66	\N
233	sl233501	laura.salmi@etu.univ-lehavre.fr	Laura Salmi	STUDENT	66	\N
234	sa230921	aida.seye@etu.univ-lehavre.fr	Aida Seye	STUDENT	68	\N
304	ma242522	aurelien.monnier@etu.univ-lehavre.fr	Aurelien Monnier	STUDENT	71	\N
235	sj231750	justine.sigogne@etu.univ-lehavre.fr	Justine Sigogne	STUDENT	69	\N
237	ta231912	alice.teissere@etu.univ-lehavre.fr	Alice Teissere	STUDENT	69	\N
238	ts231183	selen.topcu@etu.univ-lehavre.fr	Selen Topcu	STUDENT	68	\N
239	vo224060	oleksandr.vusatyi@etu.univ-lehavre.fr	Oleksandr Vusatyi	STUDENT	66	\N
306	nc240702	chaima.naamane@etu.univ-lehavre.fr	Chaima Naamane	STUDENT	72	\N
309	pm242800	matheo.planoudis@etu.univ-lehavre.fr	Matheo Planoudis	STUDENT	73	\N
311	qi241652	ines.quesada@etu.univ-lehavre.fr	Ines Quesada	STUDENT	72	\N
314	se241209	elif.sagir@etu.univ-lehavre.fr	Elif Sagir	STUDENT	73	\N
316	sc242837	carla.signour@etu.univ-lehavre.fr	Carla Signour	STUDENT	72	\N
319	va222409	apolline.vergneault@etu.univ-lehavre.fr	Apolline Vergneault	STUDENT	74	\N
240	zc211044	chaima.zeggai@etu.univ-lehavre.fr	Chaima Zeggai	STUDENT	66	\N
321	wg241458	garance.wawrzyniak@etu.univ-lehavre.fr	Garance Wawrzyniak	STUDENT	74	\N
325	dl231710	lea.dechamps@etu.univ-lehavre.fr	Lea Dechamps	STUDENT	76	\N
328	le241962	eve-lenig.le-mouel@etu.univ-lehavre.fr	Eve-lenig Le mouel	STUDENT	76	\N
62	ba252385	anouk.breton@etu.univ-lehavre.fr	Anouk Breton	STUDENT	63	\N
241	zs231744	sara.zermane@etu.univ-lehavre.fr	Sara Zermane	STUDENT	66	\N
243	aj240990	jade-mahite.alves@etu.univ-lehavre.fr	Jade - mahite Alves	STUDENT	72	\N
63	bg251631	gabriel.bunel@etu.univ-lehavre.fr	Gabriel Bunel	STUDENT	60	\N
66	ck250680	kahina.chabbi@etu.univ-lehavre.fr	Kahina Chabbi	STUDENT	64	\N
330	rl241373	lilou.rioult@etu.univ-lehavre.fr	Lilou Rioult	STUDENT	76	\N
333	an231349	naim.asselin@etu.univ-lehavre.fr	Naim Asselin	STUDENT	77	\N
67	cm252766	marwane.chanaoui@etu.univ-lehavre.fr	Marwane Chanaoui	STUDENT	60	\N
247	ak253272	kossi-mawuto-guy.azonhouto@etu.univ-lehavre.fr	Kossi mawuto guy Azonhouto	STUDENT	72	\N
68	cs252698	selim.chati@etu.univ-lehavre.fr	Selim Chati	STUDENT	59	\N
70	ca250685	alizarine.cherriere@etu.univ-lehavre.fr	Alizarine Cherriere	STUDENT	59	\N
71	ce251389	esra.chtioui@etu.univ-lehavre.fr	Esra Chtioui	STUDENT	62	\N
72	cs250840	sarta.cissoko@etu.univ-lehavre.fr	Sarta Cissoko	STUDENT	61	\N
256	cl240415	lea.calais@etu.univ-lehavre.fr	Lea Calais	STUDENT	73	\N
74	cm242178	mathys.couture@etu.univ-lehavre.fr	Mathys Couture	STUDENT	63	\N
75	dd252233	davina.dassi-momo@etu.univ-lehavre.fr	Davina Dassi momo	STUDENT	63	\N
336	dy230579	yasmine.drici@etu.univ-lehavre.fr	Yasmine Drici	STUDENT	78	\N
337	ej231718	jade.esnault@etu.univ-lehavre.fr	Jade Esnault	STUDENT	77	\N
261	cl242750	lilou.coquin@etu.univ-lehavre.fr	Lilou Coquin	STUDENT	73	\N
266	dl241089	lisa.della-casa@etu.univ-lehavre.fr	Lisa Della casa	STUDENT	74	\N
271	es240531	shaima.el-bazze@etu.univ-lehavre.fr	Shaima El bazze	STUDENT	72	\N
76	de252748	elouan.de-kerliviou@etu.univ-lehavre.fr	Elouan De kerliviou	STUDENT	64	\N
274	gc241716	carla.garnier@etu.univ-lehavre.fr	Carla Garnier	STUDENT	72	\N
77	da252730	aissata.deh1@etu.univ-lehavre.fr	Aissata Deh	STUDENT	60	\N
276	hj242566	jade.haugomat@etu.univ-lehavre.fr	Jade Haugomat	STUDENT	74	\N
279	js242223	salome.jassak@etu.univ-lehavre.fr	Salome Jassak	STUDENT	72	\N
281	ka240442	alisya.kilic@etu.univ-lehavre.fr	Alisya Kilic	STUDENT	73	\N
284	lg240913	garance.langlois@etu.univ-lehavre.fr	Garance Langlois	STUDENT	71	\N
286	lz241599	zoe.le-moal@etu.univ-lehavre.fr	Zoe Le moal	STUDENT	73	\N
289	lm241655	matheo.lefebvre@etu.univ-lehavre.fr	Matheo Lefebvre	STUDENT	72	\N
291	ld242109	diego.leite-goncalves@etu.univ-lehavre.fr	Diego Leite gonçalves	STUDENT	72	\N
294	lf242599	faustine.letellier@etu.univ-lehavre.fr	Faustine Letellier	STUDENT	72	\N
78	df241325	frederique.dehais@etu.univ-lehavre.fr	Frederique Dehais	STUDENT	61	\N
79	dm252979	mansour-yatou.demba@etu.univ-lehavre.fr	Mansour-yatou Demba	STUDENT	60	\N
81	da250807	allyna.deschamps@etu.univ-lehavre.fr	Allyna Deschamps	STUDENT	63	\N
82	dl250475	luka.desweemer@etu.univ-lehavre.fr	Luka Desweemer	STUDENT	61	\N
187	as230483	sarah.aubourg@etu.univ-lehavre.fr	Sarah Aubourg	STUDENT	66	\N
216	ky233536	yuliia.kravchuk@etu.univ-lehavre.fr	Yuliia Kravchuk	STUDENT	66	\N
222	ls231884	simon.lemesle@etu.univ-lehavre.fr	Simon Lemesle	STUDENT	66	\N
223	li231682	ilona.lepiller@etu.univ-lehavre.fr	Ilona Lepiller	STUDENT	67	\N
224	le231208	eliot.levasseur@etu.univ-lehavre.fr	Eliot Levasseur	STUDENT	68	\N
225	ma221128	anais.macedo-coelho@etu.univ-lehavre.fr	Anais Macedo coelho	STUDENT	67	\N
226	ma232161	arthur.marie-olive@etu.univ-lehavre.fr	Arthur Marie-olive	STUDENT	68	\N
296	lm242931	mathias.liaigre--grenet@etu.univ-lehavre.fr	Mathias Liaigre grenet	STUDENT	71	\N
299	me240380	ethan.mauranges@etu.univ-lehavre.fr	Ethan Mauranges	STUDENT	72	\N
341	ll232087	lucas.laville@etu.univ-lehavre.fr	Lucas Laville	STUDENT	77	\N
342	la230535	anaelle.legrand@etu.univ-lehavre.fr	Anaelle Legrand	STUDENT	77	\N
346	oc230995	carla.olivier@etu.univ-lehavre.fr	Carla Olivier	STUDENT	77	\N
347	qb231188	baptiste.quintino@etu.univ-lehavre.fr	Baptiste Quintino	STUDENT	77	\N
351	rm232117	maelys.rustuel@etu.univ-lehavre.fr	Maelys Rustuel	STUDENT	78	\N
352	sm232141	malik.soret@etu.univ-lehavre.fr	Malik Soret	STUDENT	79	\N
277	ha241438	agathe.huberson@etu.univ-lehavre.fr	Agathe Huberson	STUDENT	73	\N
282	km242841	mathys.kong-sinh@etu.univ-lehavre.fr	Mathys Kong-sinh	STUDENT	73	\N
287	ll243139	lola.lecanu@etu.univ-lehavre.fr	Lola Lecanu	STUDENT	71	\N
292	ll242125	laurette.lelong@etu.univ-lehavre.fr	Laurette Lelong	STUDENT	74	\N
297	ly241097	yanis.loubes@etu.univ-lehavre.fr	Yanis Loubes	STUDENT	71	\N
302	ml222490	lorry.mhayerenge@etu.univ-lehavre.fr	Lorry Mhayerenge	STUDENT	72	\N
307	oa242204	asma.ouchamhou@etu.univ-lehavre.fr	Asma Ouchamhou	STUDENT	72	\N
308	oa240740	arthur.ouvry@etu.univ-lehavre.fr	Arthur Ouvry	STUDENT	74	\N
43	am252995	massound-omar.abdillah-said@etu.univ-lehavre.fr	Massound-omar Abdillah said	STUDENT	59	\N
45	as253032	shayna.aksouh@etu.univ-lehavre.fr	Shayna Aksouh	STUDENT	59	\N
46	aa253702	abdelhak-yanis.amiche@etu.univ-lehavre.fr	Abdelhak yanis Amiche	STUDENT	59	\N
64	cl252396	loane.camara@etu.univ-lehavre.fr	Loane Camara	STUDENT	63	\N
65	ca253867	adrien.carluer@etu.univ-lehavre.fr	Adrien Carluer	STUDENT	63	\N
69	ch251397	hajar.cherraj@etu.univ-lehavre.fr	Hajar Cherraj	STUDENT	63	\N
73	cm252920	madyson.cousin@etu.univ-lehavre.fr	Madyson Cousin	STUDENT	59	\N
80	di253062	imane.dembele@etu.univ-lehavre.fr	Imane Dembele	STUDENT	59	\N
83	de252254	el-hadj-hamidou.diaw@etu.univ-lehavre.fr	El hadj hamidou Diaw	STUDENT	60	\N
84	dm251391	malik.djalout@etu.univ-lehavre.fr	Malik Djalout	STUDENT	60	\N
85	dl254035	louisa.djemel@etu.univ-lehavre.fr	Louisa Djemel	STUDENT	59	\N
86	dm251421	melissa.douay@etu.univ-lehavre.fr	Melissa Douay	STUDENT	63	\N
87	dc250695	chloe.dubuc@etu.univ-lehavre.fr	Chloe Dubuc	STUDENT	60	\N
185	am232477	munahil.ashaq@etu.univ-lehavre.fr	Munahil Ashaq	STUDENT	67	\N
312	rg241719	gauthier.reaux@etu.univ-lehavre.fr	Gauthier Reaux	STUDENT	71	\N
313	ri240698	isaac.renault@etu.univ-lehavre.fr	Isaac Renault	STUDENT	73	\N
317	sa242321	aysen.son@etu.univ-lehavre.fr	Aysen Son	STUDENT	73	\N
318	te240919	elena.theodat@etu.univ-lehavre.fr	Elena Theodat	STUDENT	72	\N
322	ys241058	sacha.yalaoui@etu.univ-lehavre.fr	Sacha Yalaoui	STUDENT	71	\N
323	yh240936	herro.yamanda@etu.univ-lehavre.fr	Herro Yamanda	STUDENT	71	\N
326	gv230592	victor.guille@etu.univ-lehavre.fr	Victor Guille	STUDENT	76	\N
331	tn242196	nathan.targy@etu.univ-lehavre.fr	Nathan Targy	STUDENT	76	\N
334	bs231843	sacha.blondel@etu.univ-lehavre.fr	Sacha Blondel	STUDENT	78	\N
338	gc230480	cloe.gosset@etu.univ-lehavre.fr	Cloe Gosset	STUDENT	79	\N
343	ls232085	salome.leveque@etu.univ-lehavre.fr	Salome Leveque	STUDENT	77	\N
348	rh231863	hugo.reynier@etu.univ-lehavre.fr	Hugo Reynier	STUDENT	77	\N
186	aa243443	ayawo-phillippe.attissogan@etu.univ-lehavre.fr	Ayawo phillippe Attissogan	STUDENT	67	\N
188	bl231274	lou.baudry@etu.univ-lehavre.fr	Lou Baudry	STUDENT	68	\N
189	bs231961	samy.beghoura@etu.univ-lehavre.fr	Samy Beghoura	STUDENT	68	\N
190	bm231784	mathieu.bernard@etu.univ-lehavre.fr	Mathieu Bernard	STUDENT	67	\N
353	tm230204	marion.tisserand@etu.univ-lehavre.fr	Marion Tisserand	STUDENT	77	\N
356	ze230272	emilien.zwisler@etu.univ-lehavre.fr	Emilien Zwisler	STUDENT	77	\N
191	bc230951	clemence.bostyn@etu.univ-lehavre.fr	Clemence Bostyn	STUDENT	69	\N
360	tv243830	vianney.tsiba-ngami@etu.univ-lehavre.fr	Vianney Tsiba ngami	GUEST	\N	\N
192	bn232234	naelya.boulard-diallo@etu.univ-lehavre.fr	Naelya Boulard-diallo	STUDENT	68	\N
194	bl230128	luis-samuel.branco@etu.univ-lehavre.fr	Luis samuel Branco	STUDENT	68	\N
196	cf232016	florian.caciotti@etu.univ-lehavre.fr	Florian Caciotti	STUDENT	69	\N
197	cl230297	lou.cartier@etu.univ-lehavre.fr	Lou Cartier	STUDENT	68	\N
200	dj231257	jade.daubeuf@etu.univ-lehavre.fr	Jade Daubeuf	STUDENT	69	\N
201	dr232304	raphael.david@etu.univ-lehavre.fr	Raphael David	STUDENT	68	\N
202	da231203	axel.delamare@etu.univ-lehavre.fr	Axel Delamare	STUDENT	68	\N
205	dt231021	timothee.desmons@etu.univ-lehavre.fr	Timothee Desmons	STUDENT	68	\N
206	dy231946	yanis.dubuc--jouanne@etu.univ-lehavre.fr	Yanis Dubuc--jouanne	STUDENT	68	\N
208	fa231554	adelie.feron@etu.univ-lehavre.fr	Adelie Feron	STUDENT	69	\N
244	am240383	mathilda.aly-stervinou@etu.univ-lehavre.fr	Mathilda Aly-stervinou	STUDENT	72	\N
248	bl242248	lola.batista-gomes@etu.univ-lehavre.fr	Lola Batista gomes	STUDENT	71	\N
252	bl241160	louis.belland@etu.univ-lehavre.fr	Louis Belland	STUDENT	74	\N
257	ca240983	aminata.camara@etu.univ-lehavre.fr	Aminata Camara	STUDENT	72	\N
262	ct241585	timothe.costantin@etu.univ-lehavre.fr	Timothe Costantin	STUDENT	71	\N
267	dp240224	paul.depoix@etu.univ-lehavre.fr	Paul Depoix	STUDENT	72	\N
272	ea242990	adam.elouaid@etu.univ-lehavre.fr	Adam Elouaid	STUDENT	71	\N
123	lm252399	marilou.lebrument@etu.univ-lehavre.fr	Marilou Lebrument	STUDENT	61	\N
193	br231059	raika.boura@etu.univ-lehavre.fr	Raika Boura	STUDENT	66	\N
195	bt222383	theo.broust@etu.univ-lehavre.fr	Theo Broust	STUDENT	66	\N
93	fp250049	pierre.fouillet@etu.univ-lehavre.fr	Pierre Fouillet	STUDENT	63	\N
94	gi251885	ismael.gerard@etu.univ-lehavre.fr	Ismael Gerard-depetris	STUDENT	61	\N
95	gl252149	lily.geretto@etu.univ-lehavre.fr	Lily Geretto	STUDENT	63	\N
198	cr230418	raphael.chanvallon@etu.univ-lehavre.fr	Raphael Chanvallon	STUDENT	66	\N
246	am240684	manon.auger@etu.univ-lehavre.fr	Manon Auger	STUDENT	73	\N
251	bv241130	victor.becquet@etu.univ-lehavre.fr	Victor Becquet	STUDENT	73	\N
255	bm242610	maele.briere@etu.univ-lehavre.fr	Maele Briere	STUDENT	72	\N
260	cy243015	yousra.chehbar@etu.univ-lehavre.fr	Yousra Chehbar	STUDENT	72	\N
265	dj242173	jason.de-polignac@etu.univ-lehavre.fr	Jason De polignac--pawlowski	STUDENT	73	\N
270	eb253669	bladavi-charlotte.egbakou@etu.univ-lehavre.fr	Bladavi charlotte Egbakou	STUDENT	71	\N
275	gm240569	malo.gledel@etu.univ-lehavre.fr	Malo Gledel	STUDENT	73	\N
280	kh241447	hasmik.keanian@etu.univ-lehavre.fr	Hasmik Keanian	STUDENT	73	\N
96	gd253329	dapolek.gomis@etu.univ-lehavre.fr	Dapolek Gomis	STUDENT	59	\N
97	gj252592	joolya.gosset@etu.univ-lehavre.fr	Joolya Gosset	STUDENT	64	\N
285	lm240263	melia.le-flanchec@etu.univ-lehavre.fr	Melia Le flanchec	STUDENT	72	\N
290	lt242899	thomas.lefiot@etu.univ-lehavre.fr	Thomas Lefiot	STUDENT	71	\N
295	ll242751	lena.lhuissier--caballe@etu.univ-lehavre.fr	Lena Lhuissier--caballe	STUDENT	71	\N
300	md240382	dounia.mehadji@etu.univ-lehavre.fr	Dounia Mehadji	STUDENT	71	\N
305	mr230767	ryan.mourzik@etu.univ-lehavre.fr	Ryan Mourzik	STUDENT	71	\N
310	pc242294	clara.poignant@etu.univ-lehavre.fr	Clara Poignant	STUDENT	73	\N
315	sh241427	hugo.saillot@etu.univ-lehavre.fr	Hugo Saillot	STUDENT	72	\N
88	dp251943	paul-antoine.dumais@etu.univ-lehavre.fr	Paul-antoine Dumais	STUDENT	62	\N
89	ee250915	emeline.ettendorff@etu.univ-lehavre.fr	Emeline Ettendorff	STUDENT	62	\N
90	fr250469	rodrigue.fichaux@etu.univ-lehavre.fr	Rodrigue Fichaux	STUDENT	64	\N
91	fa251707	agathe.finet@etu.univ-lehavre.fr	Agathe Finet	STUDENT	64	\N
92	fm251967	maelie.foucourt@etu.univ-lehavre.fr	Maelie Foucourt	STUDENT	62	\N
98	gm251337	margot.grodwohl@etu.univ-lehavre.fr	Margot Grodwohl	STUDENT	64	\N
99	ga250861	antoine.guerin@etu.univ-lehavre.fr	Antoine Guerin	STUDENT	59	\N
100	gm251730	marie.guibe@etu.univ-lehavre.fr	Marie Guibe	STUDENT	64	\N
101	gl252323	louane.guillesser@etu.univ-lehavre.fr	Louane Guillesser	STUDENT	61	\N
102	ge251251	emma.guyomard@etu.univ-lehavre.fr	Emma Guyomard	STUDENT	63	\N
103	gm252545	manon.guyot@etu.univ-lehavre.fr	Manon Guyot	STUDENT	62	\N
104	hn250192	noelie.hachard-etcheto@etu.univ-lehavre.fr	Noelie Hachard-etcheto	STUDENT	62	\N
105	hm242235	marine.haddad@etu.univ-lehavre.fr	Marine Haddad	STUDENT	59	\N
106	hr251962	reda.hamouche@etu.univ-lehavre.fr	Reda Hamouche	STUDENT	64	\N
107	hh252512	hamza.hamoudi@etu.univ-lehavre.fr	Hamza Hamoudi	STUDENT	60	\N
108	hr251331	rafael.hoffecard@etu.univ-lehavre.fr	Rafael Hoffecard	STUDENT	62	\N
109	hc251336	clara.homont@etu.univ-lehavre.fr	Clara Homont	STUDENT	59	\N
110	ha252599	aloyse.houard@etu.univ-lehavre.fr	Aloyse Houard	STUDENT	64	\N
111	hs253005	samir.houmadi@etu.univ-lehavre.fr	Samir Houmadi	STUDENT	63	\N
112	ja251113	alexandre.joubert@etu.univ-lehavre.fr	Alexandre Joubert	STUDENT	59	\N
113	jw253107	wilina.jules-marthe@etu.univ-lehavre.fr	Wilina Jules-marthe	STUDENT	62	\N
114	kc252645	celia.kessas@etu.univ-lehavre.fr	Celia Kessas	STUDENT	64	\N
115	ka252475	aalya.khaloua@etu.univ-lehavre.fr	Aalya Khaloua	STUDENT	64	\N
116	kp251912	paul.kiehl@etu.univ-lehavre.fr	Paul Kiehl	STUDENT	60	\N
117	ko251654	oum-kalthum.konate@etu.univ-lehavre.fr	Oum-kalthum Konate	STUDENT	60	\N
118	ky250972	yelyzaveta.kuznietsova@etu.univ-lehavre.fr	Yelyzaveta Kuznietsova	STUDENT	62	\N
119	la252504	arthur.lagarde@etu.univ-lehavre.fr	Arthur Lagarde	STUDENT	61	\N
120	lm251469	marie.langlois@etu.univ-lehavre.fr	Marie Langlois	STUDENT	60	\N
121	lp252252	pauline.le-drezen@etu.univ-lehavre.fr	Pauline Le drezen	STUDENT	59	\N
122	lm252757	mahene.lebret--mendy@etu.univ-lehavre.fr	Mahene Lebret--mendy	STUDENT	59	\N
320	vc241032	camille.vincent@etu.univ-lehavre.fr	Camille Vincent	STUDENT	73	\N
324	dl243055	louise.danger@etu.univ-lehavre.fr	Louise Danger	STUDENT	76	\N
327	lj240339	jeanne.laignel@etu.univ-lehavre.fr	Jeanne Laignel	STUDENT	76	\N
329	pc241988	cesar.poittevin@etu.univ-lehavre.fr	Cesar Poittevin	STUDENT	76	\N
332	tl242384	lison.thilloy@etu.univ-lehavre.fr	Lison Thilloy	STUDENT	76	\N
335	cz230752	zoe.cailly@etu.univ-lehavre.fr	Zoe Cailly	STUDENT	79	\N
339	kg233164	guillaume.konan@etu.univ-lehavre.fr	Guillaume Konan	STUDENT	78	\N
340	ls231304	soa.lamande@etu.univ-lehavre.fr	Soa Lamande	STUDENT	77	\N
344	ml230379	lena.moulin@etu.univ-lehavre.fr	Lena Moulin	STUDENT	78	\N
345	np231172	paul.neel@etu.univ-lehavre.fr	Paul Neel	STUDENT	78	\N
349	ra231371	axel.romer--messe@etu.univ-lehavre.fr	Axel Romer--messe	STUDENT	78	\N
350	rb230630	baptiste.rose@etu.univ-lehavre.fr	Baptiste Rose	STUDENT	77	\N
354	tm230955	mathieu.tocquer@etu.univ-lehavre.fr	Mathieu Tocquer	STUDENT	77	\N
355	ta221625	alexandre.trancart@etu.univ-lehavre.fr	Alexandre Trancart	STUDENT	77	\N
131	lk253957	kassy.levesque@etu.univ-lehavre.fr	Kassy Levesque	STUDENT	59	\N
132	ln252240	noah.lioust-dit-lafleur@etu.univ-lehavre.fr	Noah Lioust dit lafleur	STUDENT	64	\N
137	mi251216	ibtissem.marni-sandid@etu.univ-lehavre.fr	Ibtissem Marni-sandid	STUDENT	63	\N
138	me251129	eden.mfinka-tomanitou@etu.univ-lehavre.fr	Eden Mfinka tomanitou	STUDENT	59	\N
133	lc251886	clarisse.lorenzon@etu.univ-lehavre.fr	Clarisse Lorenzon	STUDENT	63	\N
143	ni251442	ilhan.ndopedro@etu.univ-lehavre.fr	Ilhan Ndopedro	STUDENT	60	\N
134	mj251114	julien.mahier@etu.univ-lehavre.fr	Julien Mahier	STUDENT	60	\N
139	mj252484	josephina.moisa@etu.univ-lehavre.fr	Josephina Moisa	STUDENT	59	\N
124	lv252253	victor.lecaron@etu.univ-lehavre.fr	Victor Lecaron	STUDENT	64	\N
135	ml250268	lorena.marchais@etu.univ-lehavre.fr	Lorena Marchais	STUDENT	60	\N
136	ml252672	liam.marie@etu.univ-lehavre.fr	Liam Marie	STUDENT	60	\N
149	pm251875	manon.paumelle@etu.univ-lehavre.fr	Manon Paumelle	STUDENT	61	\N
125	la251719	aela.lecoq--petitjean@etu.univ-lehavre.fr	Aela Lecoq--petitjean	STUDENT	64	\N
140	ml252711	lana.monchaux@etu.univ-lehavre.fr	Lana Monchaux	STUDENT	64	\N
155	rj251734	jawad.rhabbour-el-melhaoui@etu.univ-lehavre.fr	Jawad Rhabbour el melhaoui	STUDENT	62	\N
156	rm252597	melene.romeo@etu.univ-lehavre.fr	Melene Romeo	STUDENT	64	\N
126	lm250060	maelle.lecourtois@etu.univ-lehavre.fr	Maelle Lecourtois	STUDENT	60	\N
127	la252743	anne-sarah.legat@etu.univ-lehavre.fr	Anne-sarah Legat	STUDENT	62	\N
167	ta250120	amadou.tall@etu.univ-lehavre.fr	Amadou Tall	STUDENT	59	\N
128	lp252646	paul.lelandais@etu.univ-lehavre.fr	Paul Lelandais	STUDENT	61	\N
141	np251128	pauline.navarro@etu.univ-lehavre.fr	Pauline Navarro	STUDENT	61	\N
144	nt250562	timeo.neusy@etu.univ-lehavre.fr	Timeo Neusy	STUDENT	62	\N
150	pe252659	emma.planchon@etu.univ-lehavre.fr	Emma Planchon	STUDENT	60	\N
151	pm252595	myrtille.pouytes@etu.univ-lehavre.fr	Myrtille Pouytes	STUDENT	63	\N
168	tk250452	kerem.tas@etu.univ-lehavre.fr	Kerem Tas	STUDENT	61	\N
145	na252393	anithan.newton-rubaraj@etu.univ-lehavre.fr	Anithan Newton rubaraj	STUDENT	61	\N
129	lv253345	valentin.lemesle@etu.univ-lehavre.fr	Valentin Lemesle	STUDENT	61	\N
161	ss222742	soimadou.said-mmadi@etu.univ-lehavre.fr	Soimadou Said m'madi	STUDENT	63	\N
169	tm251348	matheo.tauvel@etu.univ-lehavre.fr	Matheo Tauvel	STUDENT	63	\N
172	tc250504	cassandra.turgy@etu.univ-lehavre.fr	Cassandra Turgy	STUDENT	62	\N
219	ll232027	louis.lecomte@etu.univ-lehavre.fr	Louis Lecomte	STUDENT	67	\N
359	davidm	maxime.david@univ-lehavre.fr	Maxime David	PROFESSOR	1	\N
249	bm231958	mathis.baumann@etu.univ-lehavre.fr	Mathis Baumann	STUDENT	71	\N
157	rt251714	timeo.rossard@etu.univ-lehavre.fr	Timeo Rossard	STUDENT	61	\N
162	sl251481	lucie.sapin@etu.univ-lehavre.fr	Lucie Sapin	STUDENT	61	\N
130	le252428	eryne.lerouge-morin@etu.univ-lehavre.fr	Eryne Lerouge-morin	STUDENT	62	\N
170	tc250065	clement.tisserand@etu.univ-lehavre.fr	Clement Tisserand	STUDENT	61	\N
142	nd250498	djilliane.navet@etu.univ-lehavre.fr	Djilliane Navet	STUDENT	60	\N
177	wh252729	hannah.watrin@etu.univ-lehavre.fr	Hannah Watrin	STUDENT	60	\N
152	pi251927	ines.pouzet@etu.univ-lehavre.fr	Ines Pouzet	STUDENT	62	\N
146	na252803	angela.ngudi@etu.univ-lehavre.fr	Angela Ngudi	STUDENT	61	\N
173	va251472	adam.vekemans@etu.univ-lehavre.fr	Adam Vekemans	STUDENT	62	\N
147	oe252498	efe.odabas@etu.univ-lehavre.fr	Efe Odabas	STUDENT	64	\N
148	or252083	rayan.ouamara@etu.univ-lehavre.fr	Rayan Ouamara	STUDENT	60	\N
163	ss251045	steven.schouppe@etu.univ-lehavre.fr	Steven Schouppe	STUDENT	62	\N
253	bm242358	maxime.bertin@etu.univ-lehavre.fr	Maxime Bertin	STUDENT	73	\N
174	vt252276	thibaut.vendeville@etu.univ-lehavre.fr	Thibaut Vendeville	STUDENT	61	\N
164	ss252257	syana.sibler@etu.univ-lehavre.fr	Syana Sibler	STUDENT	64	\N
153	pp252434	paloma.puccinelli@etu.univ-lehavre.fr	Paloma Puccinelli	STUDENT	60	\N
182	zr252098	rayan.zariouh@etu.univ-lehavre.fr	Rayan Zariouh	STUDENT	64	\N
165	sd252701	diariata.sow@etu.univ-lehavre.fr	Diariata Sow	STUDENT	63	\N
171	ts251449	sean.toutain@etu.univ-lehavre.fr	Sean Toutain	STUDENT	62	\N
154	ql251618	louison.quivy@etu.univ-lehavre.fr	Louison Quivy	STUDENT	60	\N
178	wr251278	rose.welle@etu.univ-lehavre.fr	Rose Welle	STUDENT	63	\N
175	vm250803	maxence.vilquin@etu.univ-lehavre.fr	Maxence Vilquin	STUDENT	63	\N
176	va253281	alice.volle@etu.univ-lehavre.fr	Alice Volle	STUDENT	64	\N
179	wt251426	tom.werbrouck@etu.univ-lehavre.fr	Tom Werbrouck	STUDENT	62	\N
180	ws252744	seth.willems@etu.univ-lehavre.fr	Seth Willems	STUDENT	62	\N
183	am230241	maeva.akele@etu.univ-lehavre.fr	Maeva Akele	STUDENT	66	\N
181	wt251770	theophile.woerth--goetz@etu.univ-lehavre.fr	Theophile Woerth--goetz	STUDENT	62	\N
158	rt251125	thomas.rousseau@etu.univ-lehavre.fr	Thomas Rousseau	STUDENT	64	\N
184	as222198	simitha.aruldas@etu.univ-lehavre.fr	Simitha Aruldas	STUDENT	66	\N
159	sh250354	hanae.sa@etu.univ-lehavre.fr	Hanae Sa	STUDENT	60	\N
160	sa252570	adam.sabri@etu.univ-lehavre.fr	Adam Sabri	STUDENT	59	\N
166	se252380	eva.szumacher@etu.univ-lehavre.fr	Eva Lolivier	STUDENT	64	\N
207	ea231234	alexandre.elbaz@etu.univ-lehavre.fr	Alexandre Elbaz	STUDENT	68	\N
218	lm231971	morgane.launay@etu.univ-lehavre.fr	Morgane Launay	STUDENT	67	\N
258	cr241689	romane.camara@etu.univ-lehavre.fr	Romane Camara	STUDENT	71	\N
263	cu241982	ulysse.cottineau@etu.univ-lehavre.fr	Ulysse Cottineau	STUDENT	72	\N
268	dd242940	djibril.diallo@etu.univ-lehavre.fr	Djibril Diallo	STUDENT	73	\N
273	fb242636	britney.faha@etu.univ-lehavre.fr	Britney Faha	STUDENT	71	\N
278	jl242158	lilou.jacquet-usureau@etu.univ-lehavre.fr	Lilou Jacquet - usureau	STUDENT	72	\N
283	ly241902	yanis.lambourdiere--couillard@etu.univ-lehavre.fr	Yanis Lambourdiere - - couillard	STUDENT	71	\N
288	ll242257	lisa.lefebvre@etu.univ-lehavre.fr	Lisa Lefebvre	STUDENT	72	\N
293	lp242802	paloma.lequien@etu.univ-lehavre.fr	Paloma Lequien	STUDENT	74	\N
298	mj240527	jules.mary@etu.univ-lehavre.fr	Jules Mary	STUDENT	71	\N
303	ma242510	adele.michel@etu.univ-lehavre.fr	Adele Michel	STUDENT	72	\N
358	millemi	mickael.millet@univ-lehavre.fr	Mickael Millet	DEPT_HEAD	1	\N
362	khaledz	zahraa.khaled@univ-lehavre.fr	Zahraa Khaled	STUDY_DIRECTOR	1	\N
361	montieca	caroline.milcent-montier@univ-lehavre.fr	Caroline Milcent Montier	STUDY_DIRECTOR	1	\N
236	sl232993	lalya.susunaga@etu.univ-lehavre.fr	Lalya Susunaga	GUEST	\N	\N
357	pytels	steeve.pytel@univ-lehavre.fr	Steeve Pytel	PROFESSOR	1	\N
363	tabellth	thierry.tabellion@univ-lehavre.fr	Thierry Tabellion	PROFESSOR	1	\N
364	duc	chaofan.du@univ-lehavre.fr	Chaofan Du	PROFESSOR	1	\N
365	chef	chef@demo.fr	Chef de Département (Demo)	ADMIN	\N	\N
366	de	de@demo.fr	Directeur d Études (Demo)	PROFESSOR	1	\N
367	prof	prof@demo.fr	Professeur (Demo)	PROFESSOR	1	\N
368	tc	tc@demo.fr	Étudiant MDEE (Demo)	STUDENT	81	\N
\.


--
-- Data for Name: userfeedback; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.userfeedback (id, user_id, user_name, type, title, description, votes, voters, created_at, is_resolved) FROM stdin;
\.


--
-- Name: activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.activity_id_seq', 63, true);


--
-- Name: activitygroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.activitygroup_id_seq', 39, true);


--
-- Name: company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.company_id_seq', 1, true);


--
-- Name: competency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.competency_id_seq', 28, true);


--
-- Name: essentialcomponent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.essentialcomponent_id_seq', 110, true);


--
-- Name: evaluationrubric_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.evaluationrubric_id_seq', 12, true);


--
-- Name: group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.group_id_seq', 81, true);


--
-- Name: internship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.internship_id_seq', 5, true);


--
-- Name: internshipapplication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.internshipapplication_id_seq', 1, true);


--
-- Name: internshipevaluation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.internshipevaluation_id_seq', 1, false);


--
-- Name: internshipvisit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.internshipvisit_id_seq', 2, true);


--
-- Name: learningoutcome_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.learningoutcome_id_seq', 123, true);


--
-- Name: portfolioexportconfig_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.portfolioexportconfig_id_seq', 1, false);


--
-- Name: portfoliopage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.portfoliopage_id_seq', 1, false);


--
-- Name: promotionresponsibility_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.promotionresponsibility_id_seq', 6, true);


--
-- Name: resource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.resource_id_seq', 260, true);


--
-- Name: responsibilitymatrix_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.responsibilitymatrix_id_seq', 58, true);


--
-- Name: rubriccriterion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.rubriccriterion_id_seq', 75, true);


--
-- Name: studentfile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.studentfile_id_seq', 4, true);


--
-- Name: studentppp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.studentppp_id_seq', 1, true);


--
-- Name: systemconfig_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.systemconfig_id_seq', 13, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.user_id_seq', 368, true);


--
-- Name: userfeedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.userfeedback_id_seq', 1, false);


--
-- Name: activity activity_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activity_pkey PRIMARY KEY (id);


--
-- Name: activityaclink activityaclink_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activityaclink
    ADD CONSTRAINT activityaclink_pkey PRIMARY KEY (activity_id, ac_id);


--
-- Name: activitycelink activitycelink_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitycelink
    ADD CONSTRAINT activitycelink_pkey PRIMARY KEY (activity_id, ce_id);


--
-- Name: activitygroup activitygroup_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitygroup
    ADD CONSTRAINT activitygroup_pkey PRIMARY KEY (id);


--
-- Name: activitygroupstudentlink activitygroupstudentlink_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitygroupstudentlink
    ADD CONSTRAINT activitygroupstudentlink_pkey PRIMARY KEY (group_id, student_uid);


--
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (id);


--
-- Name: competency competency_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.competency
    ADD CONSTRAINT competency_pkey PRIMARY KEY (id);


--
-- Name: essentialcomponent essentialcomponent_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.essentialcomponent
    ADD CONSTRAINT essentialcomponent_pkey PRIMARY KEY (id);


--
-- Name: evaluationrubric evaluationrubric_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.evaluationrubric
    ADD CONSTRAINT evaluationrubric_pkey PRIMARY KEY (id);


--
-- Name: group group_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


--
-- Name: internship internship_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internship
    ADD CONSTRAINT internship_pkey PRIMARY KEY (id);


--
-- Name: internshipapplication internshipapplication_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipapplication
    ADD CONSTRAINT internshipapplication_pkey PRIMARY KEY (id);


--
-- Name: internshipevaluation internshipevaluation_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipevaluation
    ADD CONSTRAINT internshipevaluation_pkey PRIMARY KEY (id);


--
-- Name: internshipvisit internshipvisit_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipvisit
    ADD CONSTRAINT internshipvisit_pkey PRIMARY KEY (id);


--
-- Name: learningoutcome learningoutcome_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.learningoutcome
    ADD CONSTRAINT learningoutcome_pkey PRIMARY KEY (id);


--
-- Name: portfolioexportconfig portfolioexportconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.portfolioexportconfig
    ADD CONSTRAINT portfolioexportconfig_pkey PRIMARY KEY (id);


--
-- Name: portfoliopage portfoliopage_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.portfoliopage
    ADD CONSTRAINT portfoliopage_pkey PRIMARY KEY (id);


--
-- Name: promotionresponsibility promotionresponsibility_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.promotionresponsibility
    ADD CONSTRAINT promotionresponsibility_pkey PRIMARY KEY (id);


--
-- Name: resource resource_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (id);


--
-- Name: resourceaclink resourceaclink_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.resourceaclink
    ADD CONSTRAINT resourceaclink_pkey PRIMARY KEY (resource_id, ac_id);


--
-- Name: responsibilitymatrix responsibilitymatrix_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.responsibilitymatrix
    ADD CONSTRAINT responsibilitymatrix_pkey PRIMARY KEY (id);


--
-- Name: rubriccriterion rubriccriterion_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.rubriccriterion
    ADD CONSTRAINT rubriccriterion_pkey PRIMARY KEY (id);


--
-- Name: studentfile studentfile_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.studentfile
    ADD CONSTRAINT studentfile_pkey PRIMARY KEY (id);


--
-- Name: studentppp studentppp_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.studentppp
    ADD CONSTRAINT studentppp_pkey PRIMARY KEY (id);


--
-- Name: systemconfig systemconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.systemconfig
    ADD CONSTRAINT systemconfig_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: userfeedback userfeedback_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.userfeedback
    ADD CONSTRAINT userfeedback_pkey PRIMARY KEY (id);


--
-- Name: ix_activity_code; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_activity_code ON public.activity USING btree (code);


--
-- Name: ix_company_name; Type: INDEX; Schema: public; Owner: app_user
--

CREATE UNIQUE INDEX ix_company_name ON public.company USING btree (name);


--
-- Name: ix_competency_code; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_competency_code ON public.competency USING btree (code);


--
-- Name: ix_evaluationrubric_activity_id; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_evaluationrubric_activity_id ON public.evaluationrubric USING btree (activity_id);


--
-- Name: ix_group_name; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_group_name ON public."group" USING btree (name);


--
-- Name: ix_internship_student_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_internship_student_uid ON public.internship USING btree (student_uid);


--
-- Name: ix_internshipapplication_student_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_internshipapplication_student_uid ON public.internshipapplication USING btree (student_uid);


--
-- Name: ix_portfolioexportconfig_student_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_portfolioexportconfig_student_uid ON public.portfolioexportconfig USING btree (student_uid);


--
-- Name: ix_portfoliopage_share_token; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_portfoliopage_share_token ON public.portfoliopage USING btree (share_token);


--
-- Name: ix_portfoliopage_student_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_portfoliopage_student_uid ON public.portfoliopage USING btree (student_uid);


--
-- Name: ix_promotionresponsibility_group_id; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_promotionresponsibility_group_id ON public.promotionresponsibility USING btree (group_id);


--
-- Name: ix_promotionresponsibility_teacher_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_promotionresponsibility_teacher_uid ON public.promotionresponsibility USING btree (teacher_uid);


--
-- Name: ix_resource_code; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_resource_code ON public.resource USING btree (code);


--
-- Name: ix_responsibilitymatrix_user_id; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_responsibilitymatrix_user_id ON public.responsibilitymatrix USING btree (user_id);


--
-- Name: ix_rubriccriterion_rubric_id; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_rubriccriterion_rubric_id ON public.rubriccriterion USING btree (rubric_id);


--
-- Name: ix_studentfile_student_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_studentfile_student_uid ON public.studentfile USING btree (student_uid);


--
-- Name: ix_studentppp_student_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE UNIQUE INDEX ix_studentppp_student_uid ON public.studentppp USING btree (student_uid);


--
-- Name: ix_systemconfig_key; Type: INDEX; Schema: public; Owner: app_user
--

CREATE UNIQUE INDEX ix_systemconfig_key ON public.systemconfig USING btree (key);


--
-- Name: ix_user_ldap_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE UNIQUE INDEX ix_user_ldap_uid ON public."user" USING btree (ldap_uid);


--
-- Name: ix_userfeedback_user_id; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_userfeedback_user_id ON public.userfeedback USING btree (user_id);


--
-- Name: activityaclink activityaclink_ac_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activityaclink
    ADD CONSTRAINT activityaclink_ac_id_fkey FOREIGN KEY (ac_id) REFERENCES public.learningoutcome(id);


--
-- Name: activityaclink activityaclink_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activityaclink
    ADD CONSTRAINT activityaclink_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(id);


--
-- Name: activitycelink activitycelink_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitycelink
    ADD CONSTRAINT activitycelink_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(id);


--
-- Name: activitycelink activitycelink_ce_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitycelink
    ADD CONSTRAINT activitycelink_ce_id_fkey FOREIGN KEY (ce_id) REFERENCES public.essentialcomponent(id);


--
-- Name: activitygroup activitygroup_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitygroup
    ADD CONSTRAINT activitygroup_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(id);


--
-- Name: activitygroupstudentlink activitygroupstudentlink_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitygroupstudentlink
    ADD CONSTRAINT activitygroupstudentlink_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.activitygroup(id);


--
-- Name: activitygroupstudentlink activitygroupstudentlink_student_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitygroupstudentlink
    ADD CONSTRAINT activitygroupstudentlink_student_uid_fkey FOREIGN KEY (student_uid) REFERENCES public."user"(ldap_uid);


--
-- Name: essentialcomponent essentialcomponent_competency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.essentialcomponent
    ADD CONSTRAINT essentialcomponent_competency_id_fkey FOREIGN KEY (competency_id) REFERENCES public.competency(id);


--
-- Name: evaluationrubric evaluationrubric_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.evaluationrubric
    ADD CONSTRAINT evaluationrubric_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(id);


--
-- Name: internship internship_student_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internship
    ADD CONSTRAINT internship_student_uid_fkey FOREIGN KEY (student_uid) REFERENCES public."user"(ldap_uid);


--
-- Name: internshipapplication internshipapplication_student_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipapplication
    ADD CONSTRAINT internshipapplication_student_uid_fkey FOREIGN KEY (student_uid) REFERENCES public."user"(ldap_uid);


--
-- Name: internshipevaluation internshipevaluation_internship_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipevaluation
    ADD CONSTRAINT internshipevaluation_internship_id_fkey FOREIGN KEY (internship_id) REFERENCES public.internship(id);


--
-- Name: internshipvisit internshipvisit_internship_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.internshipvisit
    ADD CONSTRAINT internshipvisit_internship_id_fkey FOREIGN KEY (internship_id) REFERENCES public.internship(id);


--
-- Name: learningoutcome learningoutcome_competency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.learningoutcome
    ADD CONSTRAINT learningoutcome_competency_id_fkey FOREIGN KEY (competency_id) REFERENCES public.competency(id);


--
-- Name: portfolioexportconfig portfolioexportconfig_student_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.portfolioexportconfig
    ADD CONSTRAINT portfolioexportconfig_student_uid_fkey FOREIGN KEY (student_uid) REFERENCES public."user"(ldap_uid);


--
-- Name: portfoliopage portfoliopage_student_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.portfoliopage
    ADD CONSTRAINT portfoliopage_student_uid_fkey FOREIGN KEY (student_uid) REFERENCES public."user"(ldap_uid);


--
-- Name: promotionresponsibility promotionresponsibility_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.promotionresponsibility
    ADD CONSTRAINT promotionresponsibility_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: promotionresponsibility promotionresponsibility_teacher_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.promotionresponsibility
    ADD CONSTRAINT promotionresponsibility_teacher_uid_fkey FOREIGN KEY (teacher_uid) REFERENCES public."user"(ldap_uid);


--
-- Name: resourceaclink resourceaclink_ac_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.resourceaclink
    ADD CONSTRAINT resourceaclink_ac_id_fkey FOREIGN KEY (ac_id) REFERENCES public.learningoutcome(id);


--
-- Name: resourceaclink resourceaclink_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.resourceaclink
    ADD CONSTRAINT resourceaclink_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resource(id);


--
-- Name: rubriccriterion rubriccriterion_ac_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.rubriccriterion
    ADD CONSTRAINT rubriccriterion_ac_id_fkey FOREIGN KEY (ac_id) REFERENCES public.learningoutcome(id);


--
-- Name: rubriccriterion rubriccriterion_ce_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.rubriccriterion
    ADD CONSTRAINT rubriccriterion_ce_id_fkey FOREIGN KEY (ce_id) REFERENCES public.essentialcomponent(id);


--
-- Name: rubriccriterion rubriccriterion_rubric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.rubriccriterion
    ADD CONSTRAINT rubriccriterion_rubric_id_fkey FOREIGN KEY (rubric_id) REFERENCES public.evaluationrubric(id);


--
-- Name: studentppp studentppp_student_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.studentppp
    ADD CONSTRAINT studentppp_student_uid_fkey FOREIGN KEY (student_uid) REFERENCES public."user"(ldap_uid);


--
-- Name: user user_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: userfeedback userfeedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.userfeedback
    ADD CONSTRAINT userfeedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(ldap_uid);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: app_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict 6v6zrPgoUgCZXhDE8kDogcWQeRBLtpjjabSWPY2zTe0qioPB2HL8VIMGTfl76t8

