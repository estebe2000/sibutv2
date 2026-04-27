--
-- PostgreSQL database dump
--

\restrict RnDm5Uz84RkbCucYZiNCDSpjOgbF7WOzsK1VrHf58phh5P6UqnxQ7jcExG9brC8

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
    supervisor_email character varying
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
    group_id integer
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
-- Name: activity id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activity ALTER COLUMN id SET DEFAULT nextval('public.activity_id_seq'::regclass);


--
-- Name: activitygroup id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.activitygroup ALTER COLUMN id SET DEFAULT nextval('public.activitygroup_id_seq'::regclass);


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
-- Name: learningoutcome id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.learningoutcome ALTER COLUMN id SET DEFAULT nextval('public.learningoutcome_id_seq'::regclass);


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
-- Name: systemconfig id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.systemconfig ALTER COLUMN id SET DEFAULT nextval('public.systemconfig_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: activity; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.activity (id, code, label, description, type, level, semester, pathway, resources, responsible, contributors) FROM stdin;
1	SAE 1.01	Marketing : positionnement d'une offre simple sur un marché	Compétence ciblée :\n– Conduire les actions marketing\n\nObjectifs et problématique professionnelle :\nIdentifier les opportunités et les menaces dans l'environnement d'une organisation. Cet élément constitue le point d'étape préalable nécessaire à toute action sur un marché.\nLa problématique professionnelle consiste à analyser le contexte de marché dans lequel évolue une offre commerciale simple et le comportement d'achat du client vis-à-vis de cette offre.\n\nDescriptif générique :\n– Diagnostic et analyse micro et macroéconomique pour permettre à une entreprise d'agir sur un marché, et de mettre en lumière les tendances de marché, l'offre (concurrence) et la demande (comportement du consommateur)\n– Analyse du contexte commercial et du comportement d'achat du client pour détecter ou valider les opportunités en vue du lancement d'un nouveau produit	SAE	1	1	Tronc Commun	R1.01, R1.04, R1.05, R1.06, R1.07, R1.08, R1.09, R1.10, R1.11, R1.12, R1.13, R1.14, R1.15	\N	\N
2	SAE 1.02	Vente : démarche de prospection	Compétence ciblée :\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nPréparer et réaliser une démarche complète de prospection, notamment téléphonique.\nLa problématique professionnelle consiste à mener une démarche de prospection, en particulier téléphonique, pour un produit simple depuis les étapes de préparation de l'échange téléphonique jusqu'à l'analyse de l'action commerciale.\n\nDescriptif générique :\n– Elaboration ou qualification d'un fichier de prospects\n– Réalisation d'un plan d'appel\n– Préparation des outils de suivi de la prospection\n– Prise de contact avec les prospects\n– Bilan et analyse des résultats de l'opération de prospection	SAE	1	1	Tronc Commun	R1.01, R1.02, R1.07, R1.08, R1.10, R1.13, R1.14, R1.15	\N	\N
3	SAE 1.03	Communication commerciale : création d'un support "print"	Compétence ciblée :\n– Communiquer l'offre commerciale\n\nObjectifs et problématique professionnelle :\nAnalyser les supports "print" des concurrents d'un secteur et créer un support.\nLa démarche professionnelle consiste à élaborer un support "print" (affiche, plaquette, flyer, encart presse) destiné à une cible de consommateurs, en cohérence avec la stratégie de communication et le mix de l'organisation et en tenant compte des concurrents.\n\nDescriptif générique :\n– Étude d'une campagne de publicité\n– Réalisation d'une plaquette de présentation d'une entreprise ou d'un produit\n– Réalisation d'affiches	SAE	1	1	Tronc Commun	R1.03, R1.06, R1.07, R1.10, R1.11, R1.12, R1.13, R1.14, R1.15	\N	\N
4	PORTFOLIO S1	Démarche portfolio (S1)	Compétences ciblées :\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l'offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 1, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l'étudiant de se positionner, sans être évalué, dans le processus d'acquisition du niveau 1 des compétences de la première année du B.U.T.\n\nDescriptif générique :\nL'équipe pédagogique devra accompagner l'étudiant dans la compréhension et l'appropriation effectives du référentiel de compétences et de ses éléments constitutifs tels que les composantes essentielles en tant qu'elles constituent des critères qualité. Seront également exposées les différentes possibilités de démonstration et d'évaluation de l'acquisition du niveau des compétences ciblé en première année par la mobilisation notamment d'éléments de preuve issus de toutes les SAÉ. L'enjeu est de permettre à l'étudiant d'engager une démarche d'auto-positionnement et d'auto-évaluation.	PORTFOLIO	1	1	Tronc Commun	R1.07, R1.13, R1.14, R1.15	\N	\N
5	SAE 2.01	Marketing : marketing mix	Mettre en œuvre de façon éthique la stratégie commerciale d’une offre simple à travers les décisions marketing relevant du\nmarketing mix et de sa cohérence\nApprécier les enjeux des variables du mix et des facteurs liés\nComprendre la complexité d’une décision marketing, son besoin de cohérence avec la stratégie marketing de ciblage et de\npositionnement et les interactions dans l’entreprise\nLa problématique professionnelle consiste à préconiser les déterminants marketing de l’offre commerciale simple en pleine\nappréciation des facteurs internes et externes.\n\n\n– Étude du marketing mix\n– Prise de décisions marketing assurant la cohérence du mix dans le cadre d’un marché concurrentiel et au moyen\nd’informations fournies au préalable\n– Lancement d’un nouveau bien de grande consommation en B2C\n– Conception d’une offre cohérente et éthique en termes de produits, prix, distribution et communication sur un marché de\nbiens de grande consommation B2C en fonction d’une cible et d’un positionnement à pré-établir	SAE	1	2	Tronc Commun	R2.01, R2.08, R2.15, R2.05, R2.14, R2.07, R2.11, R2.04, R2.12, R2.10, R2.06, R2.13	\N	\N
6	SAE 2.02	Vente : initiation au jeu de rôle de négociation	Réaliser le jeu de rôle de négociation par étapes avec les Outils d’Aide à la Vente (OAV) adaptés\nLa problématique professionnelle est centrée sur la préparation d’un entretien de vente et la mise en œuvre des savoirs-faire\net savoir-être adaptés.\n\n\n– Prise de connaissance des produits/services de l’entreprise étudiée puis préparation de la prise de contact\n– Préparation des OAV et du plan de découverte\n– Pratique de l’écoute active et de l’empathie\n– Préparation et jeu de rôle de la première et de la deuxième partie de l’entretien (préparation de l’argumentaire et des\nobjections (sauf prix)\n– Pratique de l’argumentation centrée sur l’avantage client	SAE	1	2	Tronc Commun	R2.15, R2.05, R2.14, R2.07, R2.02, R2.10, R2.06, R2.13, R2.09	\N	\N
7	SAE 2.03	Communication commerciale : élaboration d’un plan de communication commerciale	Déterminer des cibles et objectifs de communication avant toute action de communication\nComprendre la complexité du choix des moyens de communication commerciale\nÉlaborer des outils pertinents\nProposer des indicateurs aﬁn d’évaluer l’impact du plan de communication choisi, argumenter la pertinence des indicateurs\nLa problématique professionnelle est centrée sur le choix des moyens et l’élaboration d’outils de communication adaptés.\n\n\nMise en œuvre d’une action de communication commerciale :\n– Déﬁnition de la cible et des objectifs\n– Choix d’un ou plusieurs moyens de communication adaptés\n– Collecte d’informations, préparation des outils choisis : e-mailing et/ou dossier de partenariat, etc.\n– Choix des critères d’analyse de l’efﬁcacité	SAE	1	2	Tronc Commun	R2.15, R2.05, R2.14, R2.07, R2.12, R2.10, R2.06, R2.13, R2.03	\N	\N
23	PORTFOLIO S3 MMPV	Démarche portfolio (S3 MMPV)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	MMPV	R3.14, R3.06, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.MMPV.15, R3.04, R3.MMPV.16, R3.02, R3.09, R3.01, R3.05	\N	\N
8	SAE 2.04	Conception d’un projet en déployant les techniques de commercialisation	Analyser au préalable l’environnement commercial et les besoins d’un commanditaire\nLa problématique professionnelle consiste à apporter à l’organisation cliente des solutions adaptées à sa demande, en termes\nde commercialisation au sens large, à savoir de vente, de marketing et de communication commerciale. Dans cette étape\ninitiale, il s’agit de déterminer les outils et l’organisation à mettre en place au regard de l’objectif ﬁxé par le commanditaire.\n\n\nConduite d’un projet en réponse à une problématique commerciale fournie par une organisation :\n– Conception d’un cahier des charges\n– Constitution d’une équipe\n– Répartition et planiﬁcation des tâches\n– Utilisation des outils de gestion de projet\n– Recherche des contraintes inhérentes au projet\n– Présentation de la documentation pertinente	SAE	1	2	Tronc Commun	R2.01, R2.08, R2.15, R2.05, R2.14, R2.07, R2.02, R2.11, R2.04, R2.12, R2.10, R2.06, R2.13, R2.09, R2.03	\N	\N
9	PORTFOLIO S2	Démarche portfolio (S2)	Au semestre 2, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition du niveau 1 des compé-\ntences de la première année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées\ndans le cadre des SAÉ de première année.	PORTFOLIO	1	2	Tronc Commun	R2.15, R2.06, R2.13, R2.14	\N	\N
10	STAGE S2	Stage de découverte (S2)	Compétences ciblées :\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l'offre commerciale\n\nObjectifs et problématique professionnelle :\nLe ou la stagiaire participe aux activités d'un service ou d'une organisation, en position d'observer les pratiques professionnelles et d'exécuter des tâches simples relevant du domaine de la vente, du marketing et/ou de la communication commerciale. Les activités du ou de la stagiaire sont supervisées par un encadrant de l'organisme d'accueil.\n\nObjectifs du stage :\n– Découvrir l'entreprise ou l'organisation dans ses aspects sociaux, technico-économiques et organisationnels\n– Découvrir la réalité de l'activité du cadre intermédiaire dans l'environnement commercial\n– Acquérir des savoir-faire et savoir-être professionnels\n– Mobiliser les acquis académiques en situation professionnelle\n– Développer le projet personnel professionnel	STAGE	1	2	Tronc Commun	R2.01, R2.02, R2.03, R2.04, R2.05, R2.06, R2.07, R2.08, R2.09, R2.10, R2.11, R2.12, R2.13, R2.14, R2.15	\N	\N
11	SAE 3.01	Pilotage d’un projet en déployant les techniques de commercialisation	Piloter les actions et mettre en oeuvre le suivi du projet.\nA partir de l’analyse préalable des besoins du commanditaire, la problématique professionnelle consiste à mettre en place les\nactions adéquates et à piloter le projet aﬁn d’apporter à l’organisation cliente des solutions adaptées à sa demande, en termes\nde commercialisation au sens large à savoir de vente, de marketing et de communication commerciale.\n\n\nCette SAÉ permet de mobiliser l’ensemble des compétences acquises de façon à les faire aboutir concrètement au sein du\nprojet.\nElle consiste principalement en la concrétisation d’actions nécessaires à sa réalisation, et au pilotage en :\n– connaissant parfaitement le périmètre du projet\n– assurant le suivi grâce à des indicateurs déﬁnis au préalable\n– garantissant l’avancée du projet par la réalisation des tâches et des jalons, et la production des livrables\n– adaptant le planning du projet et en surveillant l’écart entre le planning prévisionnel et le planning réel\n– maîtrisant le budget en l’adaptant selon les aléas du projet\n– encadrant une équipe projet et en gérant les ressources\n– faisant face, pour s’adapter et prendre les décisions adéquates en fonction des risques	SAE	2	3	BDMRC	R3.14, R3.06, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.04, R3.02, R3.09, R3.01, R3.05	\N	\N
12	SAE 3.SME.02	Démarche de création d’entreprise dans l’évènementiel ou la communication	Dans un contexte simple de création d’une agence évènementielle (tous types d’évènements et de prestataires) ou d’une\nagence de communication développer des attitudes entrepreneuriales en favorisant la créativité, la prise d’initiative, l’autonomie,\nla prise de risque, l’anticipation et le travail en équipe, mobiliser les compétences en marketing, en vente et en communication\ncommerciale et sensibiliser au choix du statut juridique et de l’organisation.\nLa problématique professionnelle est centrée sur l’élaboration d’une identité de marque et la mobilisation des compétences en\nmanagement de projet évènementiel.\n\n\nConstruction d’une démarche de création d’entreprise dans le digital :\n– Validation d’une idée et élaboration d’un cahier des charges simple pour développer un projet de création\n– Intégration des acteurs de l’écosystème local et interaction avec un réseau de créateurs d’entreprises et/ou des orga-\nnismes d’aide à la création d’entreprise	SAE	2	3	SME	R3.SME.15, R3.06, R3.07, R3.13, R3.03, R3.12, R3.04, R3.02, R3.SME.16, R3.09, R3.01, R3.14	\N	\N
13	SAE 3.SME.03	Création d’un évènement comme outil de branding	Développer l’expertise de conception d’un événement pour valoriser une marque et les techniques de valorisation du contenu\nde marque (brand content).\nLa problématique professionnelle consiste à réﬂéchir à un évènement simple au service d’une marque : évènement d’ampleur\nlimitée, avec un public peu nombreux et des enjeux ﬁnanciers et réglementaires faibles, mais comportant des possibilités de\ncréation de contenus valorisants pour la marque.\n\n\nConception d’ un événement simple (limité en durée et en nombre de participants) pour valoriser une marque :\n– Etude d’une marque et de son positionnement\n– Analyse de la problématique de la marque\n– Proposition d’un évènement simple permettant de valoriser la marque\n– Etude de contenus de marque possibles en lien avec l’évènement	SAE	2	3	SME	R3.SME.15, R3.SME.16, R3.14	\N	\N
21	SAE 3.MMPV.02	Démarche d’ouverture d’un point de vente	Dans un contexte simple de création d’entreprise, développer des attitudes entrepreneuriales en favorisant la créativité, la\nprise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et mobiliser les compétences en marketing,\nen vente, en communication commerciale, marketing digital, e-business et entrepreneuriat et sensibiliser au choix du statut\njuridique et de l’organisation.\nLa problématique professionnelle est centrée, dans le cadre de l’ouverture d’un point de vente, sur l’analyse du potentiel d’une\nzone géographique (concurrents, zone de chalandise, analyse de la demande...), la proposition d’un assortiment de produits\n(largeur, profondeur...) et la ﬁxation d’objectifs de vente.\n\n\nConstruction d’une démarche d’ouverture d’un point de vente :\n– Validation d’une idée et élaboration d’un cahier des charges simple pour développer un projet de création\n– Intégration des acteurs de l’écosystème local et interaction avec un réseau de créateurs d’entreprises et/ou des orga-\nnismes d’aide à la création d’entreprise	SAE	2	3	MMPV	R3.14, R3.06, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.MMPV.15, R3.04, R3.MMPV.16, R3.02, R3.09, R3.01, R3.05	\N	\N
14	PORTFOLIO S3 SME	Démarche portfolio (S3 SME)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner, sans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement au parcours suivi.\n\nDescriptif générique :\nL’équipe pédagogique devra accompagner l’étudiant dans la compréhension et l’appropriation effectives du référentiel de compétences et de ses éléments constitutifs tels que les composantes essentielles en tant qu’elles constituent des critères qualité. Seront également exposées les différentes possibilités de démonstration et d’évaluation de l’acquisition des niveaux de compétences ciblés en deuxième année par la mobilisation notamment d’éléments de preuve issus de toutes les SAÉ. L’enjeu est de permettre à l’étudiant d’engager une démarche d’auto-positionnement et d’auto-évaluation tout en intégrant la spécificité du parcours suivi.	PORTFOLIO	2	3	SME	R3.01, R3.02, R3.03, R3.04, R3.05, R3.06, R3.07, R3.08, R3.09, R3.10, R3.11, R3.12, R3.13, R3.14, R3.SME.15, R3.SME.16	\N	\N
15	SAE 4.01	Evaluation de la performance du projet en déployant les techniques de commercialisation	Evaluer la performance des actions menées dans le cadre du projet et rendre compte au commanditaire.\nLa problématique professionnelle consiste à ﬁnaliser un projet et à faire un bilan et des recommandations au commanditaire.\n\n\nCette SAÉ permet de mobiliser l’ensemble des compétences. Elle consiste à ﬁnaliser les actions nécessaires à la réalisation\nd’un projet pour un commanditaire et à les évaluer. Il s’agit de :\n– Analyser des indicateurs pour mesurer concrètement l’efﬁcacité et l’avancement du projet\n– Identiﬁer les sources d’erreurs et proposer des actions correctives\n– Evaluer la qualité et la pertinence des solutions mises en place\n– Evaluer le respect des contraintes de temps, de budget et des éléments du cahier des charges\n– Vériﬁer l’adéquation entre les actions menées et les besoins initiaux du commanditaire	SAE	2	4	BDMRC	R4.05, R4.04, R4.07, R4.03, R4.06, R4.01, R4.02, R4.08	\N	\N
16	SAE 4.02	Pilotage commercial d’une organisation	Assurer le pilotage d’une entreprise ﬁctive grâce à la mobilisation des compétences marketing, vente et communication com-\nmerciale.\nLa problématique professionnelle consiste à maîtriser les enjeux de gestion d’une entreprise et l’interdépendance des fonctions\net des décisions qui structurent le fonctionnement d’une entreprise.\n\n\n– Pilotage d’ une entreprise virtuelle\n– Prise de décisions en mettant en oeuvre des compétences marketing, vente et communication commerciale au service\nde la performance de l’entreprise	SAE	2	4	BDMRC	R4.05, R4.04, R4.07, R4.03, R4.06, R4.01, R4.02, R4.08	\N	\N
17	SAE 4.SME.03	Organisation d’un évènement comme outil de branding	Mettre en oeuvre les outils de l’organisation évènementielle et de la création de contenu de marque.\nLa problématique professionnelle consiste à réaliser un événement simple limité en durée et en nombre de participants pour\nvaloriser une marque et à créer du contenu de marque.\n\n\nRéalisation d’un événement simple (limité en durée et nombre de participants) pour valoriser une marque.\nOrganisation de l’évènement proposé en SAÉ S3 :\n– mise en place et organisation de l’événement : planiﬁcation, pilotage, logistique, gestion budgétaire, cadre juridique\n– mise en œuvre du plan de communication et de la commercialisation\n– gestion des relations presse et relations publiques\n– analyse des retombées\n– création de contenus de marque	SAE	2	4	SME	R4.SME.09, R4.SME.11, R4.08, R4.SME.10	\N	\N
18	STAGE S4 SME	Stage SME (S4)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	SME	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.SME.09, R4.SME.10, R4.SME.11	\N	\N
19	PORTFOLIO S5 SME	Démarche portfolio (S5 SME)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	SME	R6.SME.03, R6.02, R6.01, R6.SME.04	\N	\N
20	SAE 5.SME.01	Projet de communication évènementielle	Mettre en place une stratégie de brand content pour exploiter au mieux un évènement complexe au service de la marque.\nLa problématique professionnelle consiste à organiser un évènement d’ampleur, avec un budget conséquent et une diversité\nde prestataires pour valoriser une marque.\n\n\nConception d’une stratégie de brand content reposant sur l’organisation d’un évènement complexe de A à Z :\n– Réﬂexion\n– Proposition\n– Organisation et logistique\n– Gestion\n– Mise en œuvre\n– Branding\n– Bilan et analyse.	SAE	3	5	SME	R5.08, R5.04, R5.05, R5.01, R5.06, R5.SME.11, R5.SME.16, R5.SME.13, R5.SME.10, R5.07, R5.SME.12, R5.SME.15, R5.SME.14, R5.02, R5.09, R5.03	\N	\N
22	SAE 3.MMPV.03	Analyse d’un point de vente ou d’un rayon dans son environnement concurrentiel	Analyser le positionnement concurrentiel d’un espace de vente\nLa problématique professionnelle consiste à faire pour un point de vente donné une étude de la concurrence en terme d’offre\net de demande.\n\n\n– Analyse du marché (offre et demande)\n– Identiﬁcation des concurrents d’un espace de vente après avoir délimiter la zone de chalandise\n– Analyse du mix des concurrents : produits/gammes, prix, communication\n– Positionnement du point de vente par rapport aux concurrents et identiﬁcation de ses avantages concurrentiels	SAE	2	3	MMPV	R3.MMPV.15, R3.MMPV.16, R3.14	\N	\N
24	SAE 4.MMPV.03	Propositions d’amélioration du fonctionnement du point de vente et du management de	Appliquer les techniques de merchandising, GRC et management pour optimiser le fonctionnement d’un espace de vente.\nLa problématique commerciale consiste à proposer des actions efﬁcaces pour rendre un espace de vente plus attractif et\naméliorer la gestion de l’équipe commerciale.\n\n\nA partir des analyses réalisées dans la SAÉ "Analyse d’un point de vente ou d’un rayon dans son environnement concurrentiel"\ndu S3, production de recommandations pour améliorer le fonctionnement de l’équipe commerciale et l’attractivité du point de\nvente avec des chiffrages prévisionnels.	SAE	2	4	MMPV	R4.MMPV.09, R4.08, R4.MMPV.11, R4.MMPV.10	\N	\N
25	STAGE S4 MMPV	Stage MMPV (S4)	Compétences ciblées :\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	MMPV	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MMPV.09, R4.MMPV.10, R4.MMPV.11	\N	\N
26	PORTFOLIO S5 MMPV	Démarche portfolio (S5 MMPV)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	MMPV	R6.MMPV.04, R6.02, R6.01, R6.MMPV.03	\N	\N
27	SAE 5.MMPV.01	Approche omnicanale du point de vente	Développer l’omnicanalité et analyser ses conséquences sur la gestion d’un point de vente et de l’équipe commerciale.\nLa problématique professionnelle consiste à optimiser le fonctionnement commercial et managérial du point de vente par une\napproche omnicanal.\n\n\nProposition de déploiement de l’activité :\n– Intégration dans la stratégie de l’entreprise\n– Optimisation du parcours client dans une perspective omnicanal par l’intégration des différents points de contact	SAE	3	5	MMPV	R5.08, R5.04, R5.MMPV.12, R5.MMPV.15, R5.MMPV.10, R5.MMPV.14, R5.MMPV.11, R5.09, R5.03, R5.MMPV.13	\N	\N
28	SAE 3.MDEE.02	Démarche de création d’entreprise en contexte digital	Dans un contexte simple de création d’une activité digitale ou liée à un environnement digital développer des attitudes entre-\npreneuriales en favorisant la créativité, la prise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et\nmobiliser les compétences en marketing, en vente et en communication commerciale.\nLa problématique professionnelle est centrée sur la proposition d’idées de création d’entreprise en les situant par rapport à\nl’existant et sur la sensibilisation au choix du statut juridique de l’organisation en tenant compte des singularités d’une activité\ndigitale ou hybride.\n\n\nConstruction d’une démarche de création d’entreprise dans le digital :\n– Validation d’une idée et élaboration d’un cahier des charges simple pour développer un projet de création\n– Intégration des acteurs de l’écosystème local et interaction avec un réseau de créateurs d’entreprises et/ou des orga-\nnismes d’aide à la création d’entreprise	SAE	2	3	MDEE	R3.MDEE.15, R3.06, R3.07, R3.13, R3.03, R3.12, R3.08, R3.04, R3.MDEE.16, R3.09, R3.01, R3.14	\N	\N
29	SAE 3.MDEE.03	Analyse d’une activité digitale	Analyser une activité digitale partielle ou intégrale et identiﬁer les processus générant du chiffre d’affaires et/ou de la marge.\nLa problématique professionnelle consiste à faire l’audit d’un projet commercial en intégrant l’aspect digital.\n\n\nAnalyse d’un projet commercial :\n– en élaborant, d’une part, le modèle d’affaires correspondant : marketing mix, indicateurs clés de performance, type\nd’organisation, processus de création et délivrance de valeur\n– en effectuant, d’autre part, une étude approfondie des éléments digitaux	SAE	2	3	MDEE	R3.MDEE.15, R3.MDEE.16, R3.14	\N	\N
30	PORTFOLIO S3 MDEE	Démarche portfolio (S3 MDEE)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	MDEE	R3.14, R3.06, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.04, R3.02, R3.09, R3.01, R3.05	\N	\N
31	SAE 4.MDEE.03	Création de site web	Créer un site web avec un business model cohérent.\nLa problématique professionnelle consiste à réaliser un site web en ayant identiﬁé la stratégie de e-commerce et à développer\nles compétences en lien avec l’activité digitale de l’entreprise.\n\n\nÉlaboration d’un cahier des charges incluant la déﬁnition du proﬁl de persona ciblé et son parcours d’achat, les étapes de la\nstratégie e-business, le modèle d’affaires pertinent pour atteindre la cible et les modalités de conversion client\nStratégie de contenu, Inbound marketing.\nCréation d’un site web, de son architecture (proposition d’une url, conception d’une maquette du site, prévision des fonctionna-\nlités, conception des éléments de design du logo, conception de la stratégie éditoriale, tunnel de conversion)\nProposition d’un business model simple où la création et la délivrance de valeur pourront être identiﬁées facilement.	SAE	2	4	MDEE	R4.MDEE.11, R4.MDEE.09, R4.08, R4.MDEE.10	\N	\N
48	SAE 5.BDMRC.01	Mise en œuvre et pilotage de la stratégie client d’une entreprise	Organiser les actions commerciales d’une entreprise cliente en cohérence avec la stratégie marketing sur un secteur déterminé\n(domaine métiers, secteur géographique...) dans le respect de la RSE.\nLa problématique professionnelle est centrée sur le développement de la stratégie commerciale d’un commanditaire en tant\nque partenaire.\n\n\nEn tant que prestataire spécialiste de l’action commerciale au service d’un commanditaire :\n– Démarchage des entreprises clientes\n– Identiﬁcation des enjeux des partenaires en termes marketing et commercial\n– Proposition d’une démarche et d’une organisation commerciale adaptées\n– Mise en œuvre d’une politique de ﬁdélisation et développement de la clientèle, et de valorisation de la relation client à\ntravers la CLTV (customer long-term value)	SAE	3	5	BDMRC	R5.08, R5.04, R5.05, R5.BDMRC.11, R5.01, R5.06, R5.BDMRC.14, R5.BDMRC.12, R5.07, R5.BDMRC.10, R5.BDMRC.13, R5.02, R5.09, R5.03	\N	\N
32	STAGE S4 MDEE	Stage MDEE (S4)	Compétences ciblées :\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	MDEE	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MDEE.09, R4.MDEE.10, R4.MDEE.11	\N	\N
33	PORTFOLIO S5 MDEE	Démarche portfolio (S5 MDEE)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	MDEE	R6.MDEE.04, R6.MDEE.03, R6.02, R6.01	\N	\N
34	SAE 5.MDEE.01	Développement d’un projet digital	Créer un projet de e-business et en saisir les diverses dimensions qui conditionnent sa réussite.\nLa problématique professionnelle consiste à développer un projet de e-business dans le cadre d’une activité partiellement ou\nintégralement digitale.\n\n\nElaboration et mise en œuvre d’un projet complet d’une activité partiellement ou intégralement digitale :\n– Identiﬁcation d’un projet innovant capable de générer de la valeur\n– Développement d’une stratégie marketing digitale performante\n– Elaboration d’un cahier des charges fonctionnel puis technique\n– Optimisation de la relation client digitalisée\n– Gestion performante des ﬂux physiques et/ou informationnels\nCette SAÉ peut être menée dans le cadre d’une création digitale complète.	SAE	3	5	MDEE	R5.08, R5.04, R5.MDEE.11, R5.MDEE.14, R5.MDEE.15, R5.MDEE.12, R5.MDEE.16, R5.MDEE.13, R5.09, R5.MDEE.10	\N	\N
35	SAE 3.BI.02	Démarche de création d’entreprise à l’international	Dans un contexte simple de création d’entreprise, développer des attitudes entrepreneuriales en favorisant la créativité, la\nprise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et mobiliser les compétences en pilotage\nd’opérations à l’international, en stratégie du commerce international, mais aussi en marketing, en vente et en communication\ncommerciale et sensibiliser au choix du statut juridique et de l’organisation.\nLa problématique professionnelle est centrée sur la distribution d’un produit étranger en France, ou d’un produit français à\nl’étranger, dans une situation d’import ou d’export ou d’ouverture d’un point de vente à l’étranger.\n\n\nConstruction d’une démarche de création d’entreprise tournée vers l’international :\n– De l’idée au projet commercial\n– Rejoindre et s’intégrer dans un réseau de créateurs d’entreprises et/ou des organismes d’aide à la création d’entreprise	SAE	2	3	BI	R3.14, R3.06, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.04, R3.02, R3.09, R3.01, R3.05	\N	\N
36	SAE 3.BI.03	Etude et sélection des marchés à l’étranger pour déployer l’offre	Identiﬁer et sélectionner un marché potentiel à l’étranger pour le développement de l’offre.\nLa problématique professionnelle est centrée sur le choix d’un marché à l’étranger en évaluant son potentiel et ses risques à\nl’aide d’outils d’analyse adaptés.\n\n\n– Réalisation d’un diagnostic stratégique d’une entreprise existante avec une offre simple déﬁnie (produit de grande\nconsommation)\n– Développement de l’offre sur un marché étranger, en mettant en œuvre le processus de veille (économique et prospec-\ntion, analyse sectorielle et concurrentielle), matrice multi-critères, bilan ﬁnancier, etc.\nCette SAÉ pourra être menée en langues étrangères.	SAE	2	3	BI	R3.BI.16, R3.BI.15, R3.14	\N	\N
37	PORTFOLIO S3 BI	Démarche portfolio (S3 BI)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	BI	R3.14, R3.06, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.BI.16, R3.BI.15, R3.04, R3.02, R3.09, R3.01, R3.05	\N	\N
38	SAE 4.BI.03	Développement de l’offre à l’international	Construire une offre en l’adaptant à la demande d’une clientèle internationale.\nLa problématique professionnelle consiste à élaborer une offre en fonction du marché cible à l’international.\n\n\nMise en œuvre opérationnelle de l’offre.\nUne fois le marché étranger identiﬁé, développement marketing de l’offre et adaptation au marché étranger, incluant la partie\nprospection.\nCette SAÉ pourra être menée en langues étrangères.	SAE	2	4	BI	R4.BI.11, R4.08, R4.BI.10, R4.BI.09	\N	\N
39	STAGE S4 BI	Stage BI (S4)	Compétences ciblées :\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	BI	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BI.09, R4.BI.10, R4.BI.11	\N	\N
40	PORTFOLIO S5 BI	Démarche portfolio (S5 BI)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	BI	R6.BI.04, R6.BI.03, R6.02, R6.01	\N	\N
41	SAE 5.BI.01	Conduite d’une mission import ou export pour une entreprise	Déployer l’offre à l’international, en intégrant les aspects marketing, vente, logistiques, interculturels, transports, fournisseurs,\napprovisionnements et qualité.\nLa problématique professionnelle consiste à déployer une mission d’import ou d’export en qualité de prestataire d’une entreprise\npartenaire pour une mission d’export ou d’import.\n\n\n– Analyse des capacités de l’entreprise et des éléments contextuels du marché\n– Déploiement de l’offre, en mettant en œuvre le processus de veille (économique et prospection, analyse sectorielle et\nconcurrentielle), matrice multi-critères, bilan ﬁnancier, etc...\n– Prise en compte des enjeux de développement durable et de la stratégie achat de l’entreprise dans le cadre de la\npréparation de la mission\n– Déploiement marketing de l’offre et son adaptation au marché étranger (avec la partie prospection) une fois le marché\nétranger identiﬁé\n– Démarche de sourcing éco-responsable, choix des canaux de distribution adéquats\n– Evaluation des coûts de transport et de dédouanement pour proposer une cotation incluant les incoterms\n– Prise en compte des éléments de droit international et de l’analyse du marché fournisseurs\nCette SAÉ pourra être menée en langues étrangères (dans le cadre d’une participation à une négociation achat ou vente en\nlangue étrangère, etc.).	SAE	3	5	BI	R5.08, R5.04, R5.BI.12, R5.03, R5.BI.13, R5.BI.14, R5.BI.11, R5.BI.15, R5.09, R5.BI.10	\N	\N
42	STAGE S4 BDMRC	Stage BDMRC (S4)	Compétences ciblées :\n– Participer à la stratégie marketing et commerciale de l’organisation\n– Manager la relation client\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire contribue aux activités d’un service ou d’une organisation en répondant à des besoins professionnels exprimés par l’organisation. Les travaux du ou de la stagiaire sont supervisés par un encadrant de l’organisme d’accueil.\n\nObjectifs :\n– Apporter un soutien à l’activité d’un service /d’une organisation dans le cadre d’une ou plusieurs missions définies en amont du stage\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour analyser les besoins, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Approfondir la connaissance du secteur professionnel\n– Renforcer le projet personnel professionnel	STAGE	2	4	BDMRC	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BDMRC.09, R4.BDMRC.10	\N	\N
43	SAE 3.BDMRC.02	Démarche de création ou de reprise d’entreprise	Dans un contexte simple de création ou de reprise d’entreprise, développer des attitudes entrepreneuriales en favorisant la\ncréativité, la prise d’initiative, l’autonomie, la prise de risque, l’anticipation et le travail en équipe et mobiliser les compétences\nen marketing, en vente et en communication commerciale et sensibiliser au choix du statut juridique et de l’organisation.\nLa problématique professionnelle est centrée sur l’analyse de l’offre existante et la proposition de nouvelles activités commer-\nciales innovantes adaptées à la demande des clients. Celles-ci seront accompagnées d’indicateurs de suivi de la satisfaction\ndes futurs clients.\n\n\nConstruction d’une démarche de création ou de reprise d’entreprise :\n– Trouver l’idée innovante\n– Construire la nouvelle offre\n– Rejoindre et s’intégrer dans un réseau de créateurs ou de repreneurs d’entreprises et/ou des organismes d’aide à la\ncréation de projet ou d’entreprise	SAE	2	3	BDMRC	R3.14, R3.BDMRC.16, R3.06, R3.BDMRC.15, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.04, R3.02, R3.09, R3.01, R3.05	\N	\N
44	SAE 3.BDMRC.03	Développement d’une expertise commerciale basée sur le diagnostic de la stratégie client	Développer l’expertise commerciale et relationnelle au travers de l’étude des pratiques commerciales de la concurrence et des\nattentes des clients du secteur.\nLa problématique professionnelle consiste à conduire un diagnostic de la situation commerciale d’un secteur d’activité.\n\n\nPréparation d’ un diagnostic de la situation commerciale d’un secteur en réalisant une cartographie des pratiques commerciales\net relationnelles des entreprises d’un secteur.\nContextualisation de la SAÉ : appui sur la situation de l’entreprise dans laquelle l’alternant effectue son apprentissage et / ou\nappui sur un domaine d’activité spéciﬁque (banque, immobilier, agroalimentaire, tourisme, etc ...).	SAE	2	3	BDMRC	R3.BDMRC.15, R3.BDMRC.16, R3.14	\N	\N
45	PORTFOLIO S3 BDMRC	Démarche portfolio (S3 BDMRC)	Au semestre 3, la démarche portfolio consistera en un point étape intermédiaire qui permettra à l’étudiant de se positionner,\nsans être évalué, dans le processus d’acquisition des niveaux de compétences de la seconde année du B.U.T. et relativement\nau parcours suivi.	PORTFOLIO	2	3	BDMRC	R3.14, R3.06, R3.07, R3.13, R3.10, R3.03, R3.12, R3.08, R3.11, R3.04, R3.02, R3.09, R3.01, R3.05	\N	\N
46	SAE 4.BDMRC.03	Élaboration d’ un plan d’actions commercial et relationnel	Développer l’offre en termes de bénéﬁce client en s’appuyant sur les équipes commerciales et mettre en place une stratégie\nrelationnelle à laquelle adhèrent les équipes commerciales de l’entreprise.\nLa problématique professionnelle consiste à favoriser, au sein des équipes commerciales, la création d’opportunités commer-\nciales pour le client aﬁn d’optimiser la relation client.\n\n\nCette SAÉ peut faire suite au bilan commercial et relationnel réalisé dans la SAÉ "Développement d’une expertise commerciale\nbasé sur le diagnostic de la stratégie client d’un secteur" .\nDans l’optique d’optimiser la relation client, il s’agit de :\n– Déterminer les actions à mener, notamment des opérations commerciales spéciﬁques\n– Choisir et former les personnes ressources dans l’équipe commerciale\n– Proposer un plan d’actions commerciales permettant de saisir les opportunités du secteur\n– Construire un tableau de reporting présentant les indicateurs pertinents	SAE	2	4	BDMRC	R4.BDMRC.09, R4.08, R4.BDMRC.10	\N	\N
47	PORTFOLIO S5 BDMRC	Démarche portfolio (S5 BDMRC)	Au semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.	PORTFOLIO	3	5	BDMRC	R6.BDMRC.04, R6.02, R6.01, R6.BDMRC.03	\N	\N
49	PORTFOLIO S4 SME	Démarche portfolio (S4 SME)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	SME	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.SME.09, R4.SME.10, R4.SME.11	\N	\N
50	PORTFOLIO S4 MMPV	Démarche portfolio (S4 MMPV)	Compétences ciblées :\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	MMPV	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MMPV.09, R4.MMPV.10, R4.MMPV.11	\N	\N
51	PORTFOLIO S4 MDEE	Démarche portfolio (S4 MDEE)	Compétences ciblées :\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	MDEE	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.MDEE.09	\N	\N
52	PORTFOLIO S4 BI	Démarche portfolio (S4 BI)	Compétences ciblées :\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	BI	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BI.09, R4.BI.10, R4.BI.11	\N	\N
53	PORTFOLIO S4 BDMRC	Démarche portfolio (S4 BDMRC)	Compétences ciblées :\n– Participer à la stratégie marketing et commerciale de l’organisation\n– Manager la relation client\n– Conduire les actions marketing\n– Vendre une offre commerciale\n– Communiquer l’offre commerciale\n\nObjectifs et problématique professionnelle :\nAu semestre 4, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compétences de la deuxième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve argumentés et sélectionnés. L’étudiant devra donc engager une posture réflexive et de distanciation critique en cohérence avec le parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises en situation proposées dans le cadre des SAÉ de deuxième année.\n\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre d’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la seconde année du B.U.T. au prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée et intégrative de l’ensemble des SAÉ.	PORTFOLIO	2	4	BDMRC	R4.01, R4.02, R4.03, R4.04, R4.05, R4.06, R4.07, R4.08, R4.BDMRC.09, R4.BDMRC.10	\N	\N
54	PORTFOLIO S6 SME	Démarche portfolio (S6 SME)	Compétences ciblées :\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	SME		\N	\N
55	PORTFOLIO S6 MMPV	Démarche portfolio (S6 MMPV)	Compétences ciblées :\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	MMPV		\N	\N
56	PORTFOLIO S6 MDEE	Démarche portfolio (S6 MDEE)	Compétences ciblées :\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	MDEE		\N	\N
57	PORTFOLIO S6 BI	Démarche portfolio (S6 BI)	Compétences ciblées :\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	BI		\N	\N
58	PORTFOLIO S6 BDMRC	Démarche portfolio (S6 BDMRC)	Compétences ciblées :\n– Participer à la stratégie marketing et commerciale de l’organisation\n– Manager la relation client\n– Conduire les actions marketing\n– Vendre une offre commerciale\nObjectifs et problématique professionnelle :\nAu semestre 6, la démarche portfolio permettra d’évaluer l’étudiant dans son processus d’acquisition des niveaux de compé-\ntences de la troisième année du B.U.T., et dans sa capacité à en faire la démonstration par la mobilisation d’éléments de preuve\nargumentés et sélectionnés. L’étudiant devra donc engager une posture réﬂexive et de distanciation critique en cohérence avec\nle parcours suivi et le degré de complexité des niveaux de compétences ciblés, tout en s’appuyant sur l’ensemble des mises\nen situation proposées dans le cadre des SAÉ de troisième année.\nDescriptif générique :\nPrenant n’importe quelle forme, littérale, analogique ou numérique, la démarche portfolio pourra être menée dans le cadre\nd’ateliers au cours desquels l’étudiant retracera la trajectoire individuelle qui a été la sienne durant la troisième année du B.U.T.\nau prisme du référentiel de compétences et du parcours suivi, tout en adoptant une posture propice à une analyse distanciée\net intégrative de l’ensemble des SAÉ.	PORTFOLIO	3	6	BDMRC		\N	\N
59	STAGE S6 SME	Stage SME (S6)	Compétences ciblées :\n\n– Elaborer l’identité d’une marque\n– Manager un projet événementiel\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	SME		\N	\N
60	STAGE S6 MMPV	Stage MMPV (S6)	Compétences ciblées :\n\n– Manager une équipe commerciale sur un espace de vente\n– Piloter un espace de vente\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	MMPV		\N	\N
61	STAGE S6 MDEE	Stage MDEE (S6)	Compétences ciblées :\n\n– Gérer une activité digitale\n– Développer un projet e-business\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	MDEE		\N	\N
62	STAGE S6 BI	Stage BI (S6)	Compétences ciblées :\n\n– Formuler une stratégie de commerce à l’international\n– Piloter les opérations à l’international\n– Conduire les actions marketing\n– Vendre une offre commerciale\n\nObjectifs et problématique professionnelle :\nProblématique professionnelle :\nLe ou la stagiaire agit en tant que collaborateur ou collaboratrice d’un cadre intermédiaire dans un service ou une organisation\nen contribuant à l’activité de l’organisation et à ses résultats. Les travaux du ou de la stagiaire sont supervisés par un encadrant\nde l’organisme d’accueil.\n\nObjectifs :\n– Conduire une ou des missions en responsabilité\n– Participer aux projets en tant que membre de l’équipe\n– Mobiliser l’ensemble des acquis académiques et des compétences en milieu professionnel pour contribuer à l’activité et\naux résultats, proposer des solutions et en rendre compte\n– Renforcer les savoirs-faire et savoirs-être professionnels\n– Conforter le projet professionnel	STAGE	3	6	BI		\N	\N
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
\.


--
-- Data for Name: internship; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.internship (id, student_uid, academic_year, start_date, end_date, company_name, company_address, company_phone, company_email, supervisor_name, supervisor_phone, supervisor_email) FROM stdin;
1	pytels	2025-2026	\N	\N	a	4 Rue du Maulévrier	0770052646	aaa@aaaa.fr	tom cruise	01 02 03 04 05	tomtom@for.ever
\.


--
-- Data for Name: learningoutcome; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.learningoutcome (id, code, label, description, level, pathway, competency_id) FROM stdin;
111	AC24.03BDMRC	Travailler en équipe tout en respectant le rôle de chacun	L'étudiant doit démontrer sa capacité à s'intégrer dans une force de vente, en respectant la hiérarchie et les missions de ses collaborateurs.\n\n### Ressources mobilisées\n• R4.BDMRC.09 : Fondamentaux du management de l’équipe commerciale.\n• R3.09 : Psychologie sociale du travail.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BDMRC.03 : Élaboration d’un plan d’actions commercial et relationnel.\n\n### Critères d’évaluation\n• Adhésion aux objectifs collectifs : Contribution active aux livrables du groupe lors du projet transverse.\n• Posture professionnelle : Respect des consignes du 'manager' (étudiant ou tuteur) et des délais impartis.\n\nEn résumé : cet AC forge le savoir-être indispensable pour fonctionner efficacement au sein d'une direction commerciale.	2	BDMRC	25
112	AC24.04BDMRC	Adapter l'offre à une demande client	L'expertise consiste à transformer une offre standard en une solution sur-mesure répondant au cahier des charges précis d'un client professionnel.\n\n### Ressources mobilisées\n• R3.BDMRC.15 : Marketing B2B.\n• R1.01 : Fondamentaux du marketing.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BDMRC.03 : Élaboration d’un plan d’actions commercial et relationnel.\n\n### Critères d’évaluation\n• Conformité à la demande : L'offre adaptée respecte strictement les contraintes techniques et financières du client.\n• Force de proposition : Mise en évidence des avantages personnalisés et de la création de valeur pour l'organisation cliente.\n\nEn résumé : cet AC apprend à passer d'une logique de 'produit' à une logique de 'solution' adaptée au client.	2	BDMRC	25
79	AC34.02MDEE	Mettre en oeuvre des spécificités du marketing digital	Il s'agit de déployer des stratégies avancées d'acquisition et de fidélisation, incluant le contenu et la visibilité technique.\n\n### Ressources mobilisées\n• R5.MDEE.12 : Référencement.\n• R5.MDEE.13 : Stratégie social media et e-CRM.\n• R5.MDEE.15 : Stratégie de contenu et rédaction web.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Performance de la stratégie : Efficacité démontrée des leviers SEO et des réseaux sociaux pour générer de la visibilité.\n• Cohérence éditoriale : Adéquation entre la stratégie de contenu et les objectifs marketing globaux.\n\nEn résumé : cet AC permet de piloter la visibilité et l'engagement d'une marque sur le web.	3	MDEE	18
80	AC34.03MDEE	Elaborer un cahier des charges e-business	L'étudiant ne se contente plus d'utiliser un document existant mais devient l'auteur du cadrage complet d'un projet digital complexe.\n\n### Ressources mobilisées\n• R5.MDEE.10 : RCN appliquées au marketing digital.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n• Stage S6 : Mission de fin d'études.\n\n### Critères d’évaluation\n• Précision technique : Clarté des spécifications fonctionnelles et techniques transmises aux prestataires.\n• Maîtrise du cadrage : Capacité à intégrer l'ensemble des contraintes du e-business (paiement, sécurité, UX) dès la conception.\n\nEn résumé : cet AC apprend à structurer et à piloter un projet digital de A à Z.	3	MDEE	18
81	AC34.04MDEE	S'appuyer sur les indicateurs de performances pour améliorer la relation client	L'expertise consiste à utiliser les KPIs pour piloter l'amélioration continue de l'expérience client digitalisée.\n\n### Ressources mobilisées\n• R5.MDEE.13 : Stratégie social media et e-CRM.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Optimisation de la relation : Capacité à identifier les points de friction dans le parcours client à partir des données et à proposer des correctifs.\n• Impact stratégique : Justesse du lien établi entre l'évolution des indicateurs et l'augmentation de la valeur client.\n\nEn résumé : cet AC apprend à utiliser la data pour parfaire l'expérience utilisateur et la fidélisation.	3	MDEE	18
2	AC11.02	Mettre en oeuvre une étude de marché dans un environnement simple	Il s'agit de maîtriser des outils de collecte de données (qualitatives ou quantitatives) pour quantifier la demande et comprendre le comportement des consommateurs dans un contexte non complexe.\n\n### Ressources mobilisées (S1)\n• R1.04 : Études marketing - 1.\n• R1.07 : Techniques quantitatives et représentations - 1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.01 : Marketing : positionnement d'une offre simple sur un marché.\n\n### Critères d'évaluation\n• Rigueur de la méthodologie de l'étude (échantillonnage, administration).\n• Exactitude de l'interprétation des résultats statistiques.\n\nEn résumé : cet AC permet de transformer des observations brutes en indicateurs précis pour valider le potentiel d'une offre.	1	Tronc Commun	1
13	AC12.01	Préparer un plan de découverte qui permette de profiler le client	L'étudiant doit structurer la phase de questionnement pour identifier les caractéristiques et les attentes du client avant de formuler une offre.\n\n### Ressources mobilisées\n• R1.02 : Fondamentaux de la vente.\n• R1.14 : Expression, communication et culture.\n• R1.15 : PPP.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : Vente : démarche de prospection.\n• SAÉ 2.02 : Vente : initiation au jeu de rôle de négociation.\n\n### Critères d'évaluation\n• Rigueur de la structure du plan et pertinence du profilage client.\n\nEn résumé : cet AC apprend à fonder la vente sur un diagnostic précis des besoins réels pour éviter une approche standardisée.	1	Tronc Commun	4
14	AC12.02	Concevoir un argumentaire de vente adapté	Il s'agit de transformer les caractéristiques d'un produit ou service en bénéfices concrets pour le client, en utilisant des méthodes professionnelles comme le CAP (Caractéristiques, Avantages, Preuves).\n\n### Ressources mobilisées\n• R1.02 : Fondamentaux de la vente.\n• R2.02 : Techniques de vente et documents commerciaux.\n\n### Mise en pratique (SAÉ)\n• SAÉ 2.02 : Vente : initiation au jeu de rôle de négociation.\n\n### Critères d'évaluation\n• Capacité à personnaliser les avantages en fonction des besoins détectés lors de la découverte.\n\nEn résumé : cet AC permet de construire un discours convaincant axé sur la valeur ajoutée pour le client.	1	Tronc Commun	4
15	AC12.03	Concevoir des OAV efficaces	L'étudiant apprend à créer les supports (plaquettes, fiches techniques, présentations numériques) facilitant la démonstration de l'offre.\n\n### Ressources mobilisées\n• R1.13 : Ressources et culture numériques 1.\n• R2.02 : Techniques de vente.\n\n### Mise en pratique (SAÉ)\n• SAÉ 2.02 : Vente : initiation au jeu de rôle de négociation.\n\n### Critères d'évaluation\n• Qualité visuelle et clarté des informations présentées sur les supports.\n\nEn résumé : cet AC apprend à matérialiser l'offre par des outils professionnels qui rassurent et appuient l'argumentation.	1	Tronc Commun	4
116	AC25.01BDMRC	Intégrer la satisfaction client dans la réussite de la relation commerciale	L'étudiant doit comprendre et appliquer les principes d'une culture de service pour bâtir des relations durables avec les entreprises clientes.\n\n### Ressources mobilisées\n• R3.BDMRC.16 : Fondamentaux de la relation client.\n• R3.09 : Psychologie sociale du travail.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BDMRC.03 : Élaboration d’un plan d’actions commercial et relationnel.\n\n### Critères d’évaluation\n• Qualité de l'écoute client : Capacité à identifier les besoins implicites et explicites lors d'une interaction.\n• Culture de service : Pertinence des propositions visant à améliorer l'expérience client tout au long de son parcours.\n\nEn résumé : cet AC apprend à placer le client au centre des préoccupations pour garantir la pérennité du business.	2	BDMRC	27
117	AC25.02BDMRC	Piloter sa relation client au moyen d'indicateurs	Il s'agit de mettre en place et de suivre des tableaux de bord pour mesurer l'efficacité des actions de fidélisation et de développement du portefeuille.\n\n### Ressources mobilisées\n• R3.08 : Tableau de bord commercial.\n• R3.07 : Techniques quantitatives et représentations 3.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BDMRC.03 : Élaboration d’un plan d’actions commercial et relationnel.\n\n### Critères d’évaluation\n• Choix des indicateurs (KPIs) : Pertinence des mesures retenues (taux de rétention, Net Promoter Score, Life Time Value) pour évaluer la santé de la relation.\n• Justesse de l'analyse : Capacité à interpréter les écarts entre les objectifs fixés et les résultats obtenus.\n\nEn résumé : cet AC permet de transformer des données chiffrées en décisions de gestion pour optimiser la relation client.	2	BDMRC	27
118	AC25.03BDMRC	Traiter les réclamations client pour optimiser l'activité	L'étudiant doit savoir gérer les mécontentements et utiliser les retours négatifs comme des leviers d'amélioration de l'offre et des processus internes.\n\n### Ressources mobilisées\n• R4.BDMRC.10 : Relation client omnicanal.\n• R4.02 : Négociation : rôle du vendeur et de l'acheteur.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BDMRC.03 : Élaboration d’un plan d’actions commercial et relationnel.\n\n### Critères d’évaluation\n• Efficacité de la réponse : Rapidité et pertinence de la solution apportée au client pour restaurer la confiance.\n• Réflexivité stratégique : Capacité à critiquer les causes de la réclamation et à proposer des ajustements concrets pour éviter sa répétition.\n\nEn résumé : cet AC apprend à transformer une situation de crise en une opportunité de renforcement du lien client.	2	BDMRC	27
119	AC25.04BDMRC	Exploiter de façon pertinente les outils de la relation client	L'expertise consiste à maîtriser les outils technologiques (CRM) pour valoriser le portefeuille client tout en respectant scrupuleusement la réglementation sur les données (RGPD).\n\n### Ressources mobilisées\n• R3.12 : Ressources et culture numériques 3.\n• R3.03 : Principes de la communication digitale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BDMRC.03 : Élaboration d’un plan d’actions commercial et relationnel.\n\n### Critères d’évaluation\n• Maîtrise technique du CRM : Capacité à saisir, mettre à jour et extraire des segments de clientèle pertinents pour des actions ciblées.\n• Conformité réglementaire : Respect strict de la règle de protection des données personnelles lors de l'exploitation de la base client.\n\nEn résumé : cet AC garantit une gestion moderne, efficace et légale du capital informationnel de l'entreprise.	2	BDMRC	27
28	AC13.01	Identifier les cibles et objectifs de communication	L'étudiant doit définir précisément à qui il s'adresse (acheteurs, utilisateurs, prescripteurs) et ce qu'il souhaite obtenir (notoriété, image, action), tout en veillant à ce que ce message soit aligné avec le produit, le prix et la distribution.\n\n### Ressources mobilisées\n• R1.03 : Fondamentaux de la communication commerciale.\n• R1.01 : Fondamentaux du marketing.\n\n### Mise en pratique (SAÉ)\n• SAÉ 2.03 : Élaboration d’un plan de communication commerciale.\n\n### Critères d'évaluation\n• Pertinence de la segmentation des cibles par rapport au marché visé.\n• Clarté et réalisme des objectifs de communication fixés.\n• Cohérence stratégique globale entre le mix-marketing et la promesse de communication.\n\nEn résumé : cet AC apprend à définir 'quoi dire à qui' sans contredire l'image globale du produit.	1	Tronc Commun	7
29	AC13.02	Analyser de manière pertinente les moyens de communication	Il s'agit d'étudier les différents vecteurs disponibles (presse, affichage, réseaux sociaux, événementiel) pour sélectionner les plus adaptés à la cible et au budget.\n\n### Ressources mobilisées\n• R2.03 : Moyens de la communication commerciale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 2.03 : Élaboration d’un plan de communication commerciale.\n\n### Critères d'évaluation\n• Justification du choix des supports en fonction des habitudes de consommation média de la cible.\n• Adéquation entre les moyens choisis et les contraintes budgétaires de l'organisation.\n\nEn résumé : cet AC permet de choisir les 'bons haut-parleurs' pour diffuser le message efficacement.	1	Tronc Commun	7
30	AC13.03	Élaborer des supports simples (ISA, affiches...)	L'étudiant passe à la phase de création technique en produisant des visuels ou des documents de présentation efficaces et attractifs.\n\n### Ressources mobilisées\n• R2.13 : Ressources et culture numériques (RCN).\n• R1.14 : Expression, communication et culture.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.03 : Communication commerciale : création d’un support 'print'.\n\n### Critères d'évaluation\n• Qualité esthétique et visuelle du support (mise en page, choix des couleurs, typographie).\n• Efficacité du message (hiérarchisation de l'information, clarté de l'accroche).\n• Respect de la réglementation en vigueur (mentions obligatoires, droit à l'image, éthique).\n\nEn résumé : cet AC transforme une idée abstraite en un outil visuel concret et professionnel.	1	Tronc Commun	7
25	AC32.01	Identifier les techniques d’achat employées par un acheteur professionnel	L'étudiant doit repérer et contrer les tactiques de négociation avancées (mise en concurrence, décomposition des prix, pressions sur les délais) utilisées par les services achats structurés.\n\n### Ressources mobilisées\n• R5.02 : Négocier dans des contextes spécifiques - 1.\n• R6.02 : Négocier dans des contextes spécifiques - 2.\n\n### Mise en pratique (SAÉ)\n• Stage S6 (14 à 16 semaines) : Collaboration en responsabilité.\n\n### Critères d'évaluation\n• Réactivité tactique : Capacité à ajuster sa posture face aux méthodes de l'acheteur pendant la négociation.\n• Résilience commerciale : Maintien des objectifs de vente malgré les pressions exercées par l'acheteur pro.\n\nEn résumé : cet AC prépare l'étudiant à un rapport de force équilibré avec des acheteurs experts.	3	Tronc Commun	6
73	AC24.01MDEE	Mobiliser des indicateurs de performance en fonction du volume et de la variété des données	L'étudiant doit sélectionner et exploiter des indicateurs clés (KPIs) permettant de piloter l'efficacité d'une présence en ligne à partir de données de masse.\n\n### Ressources mobilisées\n• R3.12 : Ressources et culture numériques 3.\n• R3.08 : Tableau de bord commercial.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MDEE.03 : Analyse d’une activité digitale.\n\n### Critères d’évaluation\n• Adéquation stratégique : Justesse du choix des indicateurs (trafic, taux de rebond, conversion) en fonction des objectifs de l'offre.\n• Fiabilité de l'analyse : Exactitude du traitement des données issues du Big Data pour identifier les points de friction.\n• Rigueur quantitative : Capacité à mobiliser efficacement les outils de calcul fondamentaux pour interpréter les résultats.	2	MDEE	17
78	AC34.01MDEE	Exploiter les données de masse en mobilisant les bons outils de traitement de l'information	L'étudiant doit savoir sélectionner et utiliser des outils de Big Data pour transformer des volumes importants de données en leviers décisionnels.\n\n### Ressources mobilisées\n• R5.MDEE.10 : RCN appliquées au marketing digital.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Pertinence technologique : Justesse du choix des outils de recueil et d'analyse au regard de la variété des données.\n• Fiabilité du traitement : Capacité à traiter des données complexes pour en extraire des tendances exploitables.\n\nEn résumé : cet AC apprend à transformer les données de masse en leviers stratégiques décisionnels.	3	MDEE	18
89	AC35.01MDEE	Concevoir un modèle d'affaires complet incluant les sources de valeur, les parties prenantes et les externalités	L'étudiant doit élaborer un document stratégique décrivant la création et le partage de la valeur, en y intégrant les dimensions sociales et écologiques.\n\n### Ressources mobilisées\n• R5.MDEE.14 : Business model-2.\n• R6.MDEE.04 : Formalisation et sécurisation d'un business model.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Exhaustivité de la cartographie : Identification précise de toutes les parties prenantes et des flux de revenus.\n• Prise en compte de la RSE : Intégration réelle des externalités (positives ou négatives) dans le business model.\n\nEn résumé : cet AC permet de concevoir un modèle d'affaires complet et responsable.	3	MDEE	20
54	AC24.01MMPV	Analyser les indicateurs de performances commerciales	L'étudiant doit savoir interpréter les résultats chiffrés du point de vente pour en évaluer la santé économique et proposer des ajustements.\n\n### Ressources mobilisées\n• R3.08 : Tableau de bord commercial.\n• R3.MMPV.15 : Management de la performance du point de vente.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MMPV.03 : Propositions d’amélioration du fonctionnement du point de vente et du management de l’équipe.\n\n### Critères d’évaluation\n• Justesse de l'interprétation : Capacité à identifier les causes réelles d'un écart (positif ou négatif) entre les objectifs et les résultats.\n• Maîtrise des ratios de rentabilité : Calcul exact et explication des indicateurs tels que le panier moyen, le taux de transformation ou la marge brute.\n• Vision réflexive : Capacité à critiquer la pertinence de l'indicateur choisi par rapport au pilotage de l'activité.	2	MMPV	13
57	AC34.01MMPV	Fixer les objectifs en accord avec la méthode SMART	L'étudiant doit traduire la stratégie de l'enseigne en objectifs opérationnels pour ses collaborateurs.\n\n### Ressources mobilisées\n• R5.MMPV.12 : Management d'équipe.\n• R6.MMPV.04 : Prise de décision – pilotage.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MMPV.01 : Approche omnicanal du point de vente.\n\n### Critères d'évaluation\n• Rigueur méthodologique : Capacité à formuler des objectifs qui respectent strictement les cinq critères SMART (Spécifique, Mesurable, Atteignable, Réaliste, Temporel).\n• Justification stratégique : Aptitude à expliciter ses décisions d'action en s'appuyant sur les indicateurs de performance (KPI) du point de vente.\n• Analyse de la performance : Qualité du lien établi entre les objectifs fixés et les résultats commerciaux obtenus (panier moyen, taux de transformation).\n\nEn résumé : cet AC apprend à piloter l'activité par des objectifs clairs et mesurables.	3	MMPV	14
38	AC24.03SME	Développer la communication de marque et le marketing de contenu	L'étudiant apprend à créer des récits (storytelling) et des contenus (brand content) qui soutiennent l'identité de la marque et engagent sa cible.\n\n### Ressources mobilisées\n• R3.03 : Principes de la communication digitale.\n• Storytelling et marketing de contenu.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.SME.03 : Création d’un événement comme outil de branding.\n\n### Critères d’évaluation\n• Efficacité valorisante : Qualité des contenus produits pour améliorer et valoriser l'image de marque de manière concrète.\n• Cohérence créative : Adéquation du contenu avec les codes esthétiques et sémantiques définis dans la plateforme de marque.\n\nEn résumé : cet AC apprend à faire vivre la marque à travers des contenus engageants.	2	SME	9
40	AC34.01SME	Déterminer les attributs et territoires de la marque	L'étudiant doit définir les caractéristiques intrinsèques de la marque et son périmètre de légitimité sur le marché.\n\n### Ressources mobilisées\n• R5.SME.11 : Stratégie de développement de marque-1.\n\n### Critères d’évaluation\n• Profondeur du diagnostic territorial : Capacité à délimiter précisément l'espace concurrentiel et symbolique où la marque peut s'exprimer sans perdre sa crédibilité.\n• Pertinence des attributs : Justesse du choix des traits de caractère de la marque (physiques, fonctionnels ou imaginaires) pour assurer une différenciation réelle face aux concurrents.\n• Justification stratégique : Aptitude à expliquer le choix des attributs en s'appuyant sur des études de marché et des analyses de comportement du consommateur.\n\nEn résumé : cet AC permet de définir le territoire de légitimité et les piliers de différenciation de la marque.	3	SME	10
109	AC24.01BDMRC	Réaliser un diagnostic avant la mise en place d'actions commerciales	L'étudiant doit analyser le secteur et les forces/faiblesses de l'organisation pour identifier les leviers de croissance en environnement B2B.\n\n### Ressources mobilisées\n• R3.BDMRC.15 : Marketing B2B.\n• R3.04 : Études marketing 3.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.BDMRC.03 : Développement d'une expertise commerciale basée sur le diagnostic de la stratégie client d'un secteur.\n\n### Critères d’évaluation\n• Rigueur de l'analyse sectorielle : Capacité à extraire des données pertinentes sur un secteur client spécifique.\n• Fiabilité des sources : Utilisation de sources d'information spécialisées B2B vérifiables.\n\nEn résumé : cet AC permet de fonder toute action commerciale sur une compréhension réelle des enjeux du marché.	2	BDMRC	25
110	AC24.02BDMRC	Mesurer l'importance du choix des cibles commerciales	Il s'agit de comprendre que l'efficacité commerciale dépend de la précision de la segmentation et du ciblage des entreprises clientes.\n\n### Ressources mobilisées\n• R3.BDMRC.15 : Marketing B2B.\n• R3.01 : Marketing Mix-2.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.BDMRC.03 : Développement d'une expertise commerciale.\n\n### Critères d’évaluation\n• Pertinence des critères de ciblage : Cohérence entre les caractéristiques de la cible choisie et le potentiel de chiffre d'affaires.\n• Justification stratégique : Capacité à expliquer pourquoi une cible est prioritaire par rapport à une autre.\n\nEn résumé : cet AC apprend à concentrer les efforts commerciaux là où la valeur ajoutée est la plus forte.	2	BDMRC	25
113	AC34.01BDMRC	Mettre en oeuvre la stratégie marketing et commerciale au sein de l'équipe	L'étudiant doit traduire les orientations stratégiques de l'organisation en plans d'actions concrets et superviser leur exécution par la force de vente.\n\n### Ressources mobilisées\n• R5.01 : Stratégie d'entreprise - 1.\n• R5.BDMRC.14 : Pilotage de l'équipe commerciale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BDMRC.01 : Mise en œuvre et pilotage de la stratégie client d’une entreprise.\n\n### Critères d’évaluation\n• Rigueur de la déclinaison opérationnelle : Capacité à transformer des objectifs globaux en indicateurs de performance (KPI) individuels et collectifs.\n• Cohérence stratégique : Adéquation des actions correctives proposées en fonction des résultats du tableau de bord.\n\nEn résumé : cet AC permet de passer de la vision globale à l'animation de terrain pour garantir l'atteinte des résultats.	3	BDMRC	26
19	AC22.01	Convaincre en exprimant avec empathie l’offre	L'étudiant doit dépasser la simple énumération technique pour adapter son discours à la psychologie du client, en transformant les caractéristiques du produit en bénéfices concrets et sur-mesure.\n\n### Ressources mobilisées\n• R3.02 : Entretien de vente.\n• R3.09 : Psychologie sociale du travail.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.01 : Pilotage d'un projet.\n\n### Critères d'évaluation\n• Qualité de l'empathie démontrée, pertinence de la personnalisation des avantages et force de conviction lors de la présentation.\n\nEn résumé : cet AC apprend à créer une connexion émotionnelle et rationnelle pour que le client s'approprie la solution.	2	Tronc Commun	5
105	AC35.01BI	Mobiliser ses connaissances en processus de vente et d'achat dans des situations interculturelles	L'étudiant doit mener des négociations complexes en adaptant sa posture aux codes culturels de son interlocuteur, souvent en langue étrangère.\n\n### Ressources mobilisées\n• R6.BI.03 : Anglais appliqué au BI.\n• R6.BI.04 : LVB appliquée au CI.\n• R5.BI.15 : Marketing achat.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BI.01 : Conduite d'une mission import ou export.\n\n### Critères d’évaluation\n• Agilité comportementale : Capacité à décoder les signaux non-verbaux et à ajuster l'argumentaire en situation réelle.\n• Aisances linguistiques techniques : Utilisation fluide du vocabulaire spécifique aux contrats et aux échanges internationaux.\n\nEn résumé : cet AC fait de l'étudiant un négociateur capable de conclure des contrats n'importe où dans le monde.	3	BI	24
106	AC35.02BI	Optimiser la chaîne logistique à l'international	Il s'agit de concevoir des flux de marchandises qui minimisent les coûts et les délais tout en intégrant des critères environnementaux (RSE).\n\n### Ressources mobilisées\n• R5.BI.14 : Logistique et supply chain.\n• R5.BI.11 : Approvisionnement.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BI.01 : Conduite d'une mission import ou export.\n\n### Critères d’évaluation\n• Performance logistique : Réduction démontrée des coûts d'approche par un choix multimodal pertinent.\n• Qualité environnementale : Justification de l'optimisation carbone du transport choisi.\n\nEn résumé : cet AC garantit que le produit voyage de la manière la plus rentable et la plus propre possible.	3	BI	24
107	AC35.03BI	Gérer l'administration des ventes/achats à l'international	L'étudiant assure la conformité totale de la liasse documentaire et sécurise les flux financiers de transactions à gros volume.\n\n### Ressources mobilisées\n• R5.BI.12 : Techniques de commerce international 2.\n• R5.05 : Analyse financière.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BI.01 : Conduite d'une mission import ou export.\n• Stage S6 : Mission de fin d'études.\n\n### Critères d’évaluation\n• Rigueur documentaire : Zéro erreur sur les documents de douane, certificats d'origine et titres de transport.\n• Sécurisation des paiements : Maîtrise parfaite des techniques de couverture de risque (ex: Crédit documentaire complexe).\n\nEn résumé : cet AC est le garde-fou qui empêche les blocages douaniers et les impayés.	3	BI	24
108	AC35.04BI	Proposer l'offre marketing adaptée au(x) marché(s) ciblé(s)	Il s'agit de construire un mix-marketing étendu qui répond aux besoins spécifiques locaux tout en conservant l'ADN de la marque.\n\n### Ressources mobilisées\n• R5.BI.10 : RCN appliquées au BI.\n• R6.01 : Stratégie d'entreprise 2.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BI.01 : Conduite d'une mission import ou export.\n\n### Critères d'évaluation\n• Pertinence de l'adaptation : Justification des modifications apportées aux 4P par rapport aux attentes des consommateurs locaux.\n• Synergie stratégique : Cohérence entre l'offre adaptée et l'image de marque globale de l'entreprise.\n\nEn résumé : cet AC garantit que le produit est désirable et accessible pour le client étranger.	3	BI	24
114	AC34.02BDMRC	Fédérer les équipes autour de la réussite des objectifs marketing et commerciaux	Il s'agit de développer des pratiques managériales pour motiver les collaborateurs, valoriser leurs compétences et favoriser l'adhésion à la culture d'entreprise.\n\n### Ressources mobilisées\n• R5.BDMRC.11 : Développement des pratiques managériales.\n• R5.BDMRC.14 : Pilotage de l'équipe commerciale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BDMRC.01 : Mise en œuvre et pilotage de la stratégie client d’une entreprise.\n\n### Critères d’évaluation\n• Qualité de l'animation : Capacité à mener des réunions d'équipe stimulantes et à gérer les relations sociales au sein du groupe.\n• Valorisation des talents : Aptitude à identifier les besoins de formation et à intégrer de nouveaux collaborateurs efficacement.\n\nEn résumé : cet AC forge le leadership nécessaire pour transformer un groupe d'individus en une force de vente unie.	3	BDMRC	26
115	AC34.03BDMRC	Co-construire une offre en collaboration avec les parties prenantes concernées	L'expertise consiste à élaborer des solutions complexes en environnement B2B, en intégrant les besoins du client et les contraintes des services internes (production, logistique, finance).\n\n### Ressources mobilisées\n• R5.BDMRC.13 : Marketing des services.\n• R6.BDMRC.03 : Management des comptes-clés (KAM).\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BDMRC.01 : Mise en œuvre et pilotage de la stratégie client d’une entreprise.\n• Stage S6 : Mission de fin d'études.\n\n### Critères d’évaluation\n• Pertinence sectorielle : L'offre doit être parfaitement adaptée au contexte métier spécifique du client professionnel.\n• Qualité de la collaboration : Capacité à négocier et à obtenir un consensus entre les différentes parties prenantes pour créer de la valeur partagée.\n\nEn résumé : cet AC apprend à piloter la création de solutions sur-mesure pour des clients stratégiques (grands comptes).	3	BDMRC	26
82	AC34.05MDEE	Proposer des solutions adaptées aux spécificités de la chaine logistique du e-commerce	L'étudiant doit concevoir des flux logistiques performants répondant aux exigences du commerce en ligne (rapidité, derniers kilomètres, retours).\n\n### Ressources mobilisées\n• R5.MDEE.16 : Logistique et supply chain.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Réalisme des flux : Adéquation des solutions logistiques avec les promesses de livraison de la plateforme e-commerce.\n• Efficience opérationnelle : Capacité à optimiser les coûts logistiques tout en maintenant une haute qualité de service client.\n\nEn résumé : cet AC garantit l'alignement entre la promesse de vente web et la réalité de la livraison physique.	3	MDEE	18
56	AC24.03MMPV	Planifier les missions de l'équipe en accord avec la stratégie de l'espace de vente	L'étudiant doit organiser le travail quotidien (planning, répartition des tâches) pour assurer la fluidité du parcours client et l'attractivité du magasin.\n\n### Ressources mobilisées\n• R4.MMPV.10 : Management des équipes.\n• R2.09 : Psychologie sociale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MMPV.03 : Propositions d’amélioration du fonctionnement du point de vente.\n\n### Critères d’évaluation\n• Cohérence organisationnelle : Adéquation entre le planning de l'équipe et les pics d'affluence prévus ou les opérations commerciales en cours.\n• Respect du cadre légal : Intégration des contraintes du droit du travail dans l'élaboration des plannings (repos, durées légales).\n• Alignement stratégique : Justification de la répartition des missions en fonction des priorités de l'enseigne.	2	MMPV	13
62	AC25.01MMPV	Analyser le secteur et l'environnement concurrentiel	L'étudiant doit appréhender l'environnement commercial local pour en dégager les spécificités et les opportunités.\n\n### Ressources mobilisées\n• R3.MMPV.16 : Marketing du point de vente.\n• R3.MMPV.15 : Management de la performance du point de vente.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MMPV.03 : Analyse d’un point de vente ou d’un rayon dans un environnement concurrentiel.\n\n### Critères d’évaluation\n• Rigueur du diagnostic : Capacité à identifier précisément les zones de chalandise et les forces des concurrents directs et indirects.\n• Pertinence de la veille : Justesse des conclusions tirées sur les tendances du secteur.\n\nEn résumé : cet AC permet de comprendre le positionnement du point de vente dans son écosystème local.	2	MMPV	15
32	AC23.01	Élaborer une stratégie de communication adaptée au brief agence	L'étudiant doit savoir traduire les besoins d'un annonceur en une stratégie créative et pertinente, en respectant les contraintes énoncées dans le cahier des charges initial.\n\n### Ressources mobilisées\n• R4.03 : Conception de campagnes de communication et choix des médias.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d’évaluation\n• Fidélité au brief agence, pertinence des objectifs de communication et originalité de la promesse.\n\nEn résumé : cet AC apprend à passer de la demande brute du client à une vision stratégique cohérente et inspirante.	2	Tronc Commun	8
33	AC23.02	Établir une stratégie de moyens en utilisant les indicateurs de choix des supports	Il s'agit de sélectionner les vecteurs de diffusion (médias et hors-médias) les plus efficaces en s'appuyant sur des données d'audience et des indicateurs de coût pour optimiser le budget.\n\n### Ressources mobilisées\n• R4.03 : Conception de campagnes de communication.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d’une organisation.\n\n### Critères d’évaluation\n• Justification rigoureuse des supports choisis et optimisation de la couverture de la cible par rapport au budget investi.\n\nEn résumé : cet AC permet de choisir les 'haut-parleurs' les plus performants pour garantir l'impact du message.	2	Tronc Commun	8
34	AC23.03	Proposer un plan de com 360° en élaborant les supports	L'étudiant conçoit une campagne multicanale où chaque support (print, web, événementiel) renforce les autres, tout en créant les visuels ou messages adaptés à chaque canal.\n\n### Ressources mobilisées\n• R4.03 : Choix des médias.\n• R2.13 : Ressources et culture numériques (RCN).\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d’évaluation\n• Cohérence visuelle et éditoriale sur l'ensemble des points de contact et qualité technique de la réalisation des supports.\n\nEn résumé : cet AC assure une présence de marque uniforme et puissante sur tous les terrains de rencontre avec le client.	2	Tronc Commun	8
63	AC25.02MMPV	S'approprier la chaîne d'approvisionnement de l'espace de vente	Il s'agit de comprendre et de piloter les flux de marchandises depuis les fournisseurs jusqu'aux rayons, en respectant les directives du réseau.\n\n### Ressources mobilisées\n• R2.11 / R2.10 : Canaux de commercialisation et distribution.\n• Gestion des stocks et droit de la distribution.\n\n### Critères d’évaluation\n• Maîtrise des flux : Compréhension des mécanismes de réapprovisionnement et des contraintes logistiques (délais, coûts, stockage).\n• Conformité aux accords : Respect des procédures définies entre le point de vente et ses partenaires ou fournisseurs.\n\nEn résumé : cet AC garantit l'efficacité de la chaîne d'approvisionnement pour éviter les ruptures ou le surstock.	2	MMPV	15
120	AC35.01BDMRC	Asseoir la réussite de la relation client sur la cohérence globale de l'organisation	L'étudiant doit s'assurer que la stratégie relationnelle est alignée avec les ressources et la structure de l'entreprise pour garantir une promesse client tenue.\n\n### Ressources mobilisées\n• R5.BDMRC.13 : Marketing des services.\n• R5.01 : Stratégie d'entreprise - 1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BDMRC.01 : Mise en œuvre et pilotage de la stratégie client d'une entreprise.\n\n### Critères d’évaluation\n• Alignement stratégique : Capacité à démontrer que l'organisation interne (processus, services) soutient efficacement les objectifs de satisfaction client.\n• Cohérence organisationnelle : Justesse du lien établi entre la stratégie globale de l'entreprise et les actions de terrain.\n\nEn résumé : cet AC permet de coordonner l'ensemble des fonctions de l'entreprise vers un but unique : la satisfaction du client.	3	BDMRC	28
121	AC35.02BDMRC	Optimiser l'expérience client par la mise en place d'un processus d'amélioration continue	Il s'agit de piloter la satisfaction tout au long du parcours client et de mettre en œuvre des boucles de rétroaction pour améliorer l'offre de façon durable.\n\n### Ressources mobilisées\n• R5.BDMRC.12 : Management de la valeur client.\n• R6.BDMRC.04 : Nouveaux comportements des clients.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BDMRC.01 : Mise en œuvre et pilotage de la stratégie client d'une entreprise.\n\n### Critères d’évaluation\n• Réflexivité stratégique : Aptitude à analyser les échecs ou les points de friction du parcours client pour proposer des correctifs.\n• Maîtrise des KPIs d'expérience : Pertinence de l'utilisation des indicateurs de mesure de l'expérience client (NPS, CES) pour déclencher des actions d'amélioration.\n\nEn résumé : cet AC transforme le manager en un moteur de progrès constant pour l'expérience vécue par le client.	3	BDMRC	28
122	AC35.03BDMRC	Contribuer à la diffusion de la culture client au sein de l'organisation	L'étudiant doit agir comme un ambassadeur de la 'culture de service', en sensibilisant et en fédérant les collaborateurs internes autour des valeurs de l'organisation.\n\n### Ressources mobilisées\n• R5.BDMRC.11 : Développement des pratiques managériales.\n• R3.09 : Psychologie sociale du travail.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BDMRC.01 : Mise en œuvre et pilotage de la stratégie client d'une entreprise.\n\n### Critères d’évaluation\n• Qualité de l'animation managériale : Capacité à motiver une équipe autour d'une vision centrée sur le client et à valoriser les comportements orientés service.\n• Pédagogie interne : Efficacité dans la transmission des valeurs et des bonnes pratiques relationnelles au sein de l'organisation.\n\nEn résumé : cet AC forge le leadership nécessaire pour ancrer la satisfaction client dans l'ADN de l'entreprise.	3	BDMRC	28
123	AC35.04BDMRC	Faire évoluer les outils de la relation client	L'expertise consiste à sélectionner et à adapter les outils technologiques (CRM, omnicanalité) pour valoriser le portefeuille client tout en respectant la protection des données.\n\n### Ressources mobilisées\n• R5.BDMRC.10 : RCN appliquées au BD et au MRC.\n• R4.BDMRC.10 : Relation client omnicanal.\n\n### Mise en pratique (SAÉ)\n• Stage S6 : Mission de fin d'études en responsabilité.\n\n### Critères d’évaluation\n• Performance technologique : Justesse du choix et de l'évolution des outils numériques pour optimiser l'exploitation des données client.\n• Conformité et éthique : Respect rigoureux du RGPD dans l'évolution des processus de collecte et de traitement des données.\n\nEn résumé : cet AC garantit que l'entreprise dispose des outils les plus performants et sécurisés pour gérer son capital client.	3	BDMRC	28
9	AC31.01	Mettre en place des outils de veille pour anticiper les évolutions de l'environnement	L'étudiant doit concevoir un système de surveillance (stratégique, technologique, concurrentielle) permettant à l'organisation de rester proactive face aux changements.\n\n### Ressources mobilisées\n• R5.01 : Stratégie d'entreprise - 1.\n• R6.01 : Stratégie d'entreprise - 2.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.01/6.01 : Pilotage stratégique d'une organisation.\n\n### Critères d'évaluation\n• Qualité de la veille : Capacité à identifier des signaux faibles et des sources d'information expertes.\n• Rigueur de l'anticipation : Justesse des scénarios d'évolution du marché proposés.\n• Réflexivité experte : Capacité à critiquer ses propres méthodes de collecte et à proposer des outils alternatifs en fonction du contexte sectoriel.\n\nEn résumé : cet AC apprend à transformer l'information brute en avantage concurrentiel pour ne jamais être pris de court par le marché.	3	Tronc Commun	3
26	AC32.02	Élaborer des outils de gestion et de calcul efficaces pour la vente complexe	La vente complexe nécessite des montages financiers rigoureux. L'étudiant doit produire des documents contractuels sans erreur, incluant des modalités de paiement, des remises échelonnées ou des calculs de rentabilité financière.\n\n### Ressources mobilisées\n• R5.05 : Analyse financière.\n• R5.04 : Droit des activités commerciales - 2.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.01 : Pilotage de projet et évaluation de performance.\n\n### Critères d'évaluation\n• Exactitude technique : Absence d'erreur dans les calculs de TVA, de marges arrière ou de conditions de paiement.\n• Conformité juridique : Présence des mentions obligatoires et respect du droit des contrats commerciaux dans les supports produits.\n\nEn résumé : cet AC garantit que la solidité administrative et financière de la transaction.	3	Tronc Commun	6
27	AC32.03	Maîtriser les codes propres à l'univers spécifique rencontré	L'étudiant doit démontrer une agilité comportementale et linguistique (vocabulaire technique, codes sociaux, usages culturels) adaptée au secteur d'activité de son client.\n\n### Ressources mobilisées\n• R5.06 / R6.03 : Anglais appliqué au commerce et business international.\n• R5.08 : Expression, communication et culture 5.\n\n### Mise en pratique (SAÉ)\n• SAÉ spécifique au parcours.\n\n### Critères d'évaluation\n• Adaptabilité sectorielle : Utilisation fluide du jargon métier spécifique à l'industrie du client.\n• Posture réflexive : Capacité à critiquer ses propres méthodes de communication après une vente pour les améliorer selon le contexte.\n\nEn résumé : cet AC finalise la crédibilité de l'étudiant en tant qu'expert métier.	3	Tronc Commun	6
90	AC35.02MDEE	Faire des préconisations grâce aux outils du diagnostic stratégique	Il s'agit d'analyser les environnements spécifiques pour réussir un projet digital et d'en tirer une vision stratégique partagée.\n\n### Ressources mobilisées\n• R5.01 : Stratégie d'entreprise-1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Pertinence stratégique : Justesse des recommandations face aux opportunités et menaces du marché digital.\n• Profondeur de l'analyse : Capacité à croiser les données internes de l'entreprise avec les tendances du secteur.\n\nEn résumé : cet AC permet de faire des préconisations stratégiques basées sur un diagnostic approfondi.	3	MDEE	20
74	AC24.02MDEE	Identifier les spécifités du marketing digital	Il s'agit de distinguer et d'expliquer les leviers propres au numérique (SEO, réseaux sociaux, e-CRM) par rapport aux actions traditionnelles.\n\n### Ressources mobilisées\n• R3.MDEE.15 : Stratégie de marketing digital.\n• R3.03 : Principes de la communication digitale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MDEE.03 : Analyse d’une activité digitale.\n\n### Critères d’évaluation\n• Maîtrise conceptuelle : Profondeur de la compréhension des mécanismes d'acquisition et de fidélisation digitalisés.\n• Pertinence de la veille : Capacité à identifier les tendances émergentes et les contraintes de l'environnement numérique spécifique au projet.\n• Esprit critique : Aptitude à justifier l'usage d'un levier digital par rapport à un autre en fonction de la cible choisie.	2	MDEE	17
75	AC24.03MDEE	Utiliser un cahier des charges e-business	L'étudiant s'approprie un document de cadrage technique et fonctionnel pour garantir que le projet répond aux besoins métiers.\n\n### Ressources mobilisées\n• R4.MDEE.09 : Conduite de projet digital.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MDEE.03 : Création de site web.\n\n### Critères d’évaluation\n• Conformité des livrables : Respect rigoureux des contraintes fonctionnelles et des délais énoncés dans le document de cadrage.\n• Rigueur méthodologique : Capacité à traduire des besoins marketing en spécifications techniques claires pour les prestataires.\n• Collaboration active : Efficacité dans la communication des étapes critiques du projet au sein du collectif.	2	MDEE	17
76	AC24.04MDEE	Intégrer les spécificités du e-commerce	Il s'agit de maîtriser l'architecture d'une boutique en ligne, incluant le parcours utilisateur (UX), le tunnel de conversion et la sécurisation des échanges.\n\n### Ressources mobilisées\n• R4.MDEE.10 : Stratégie e-commerce.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MDEE.03 : Création de site web.\n\n### Critères d’évaluation\n• Qualité de l'expérience client (UX) : Fluidité et ergonomie du parcours d'achat mis en place sur la plateforme.\n• Expertise transactionnelle : Intégration pertinente des plateformes de paiement et maîtrise des mécanismes de conversion.\n• Conformité réglementaire : Respect scrupuleux des règles de protection des données (RGPD) et de la sécurité informatique.	2	MDEE	17
77	AC24.05MDEE	Respecter le processus logistique	L'étudiant doit assurer la cohérence entre la vente virtuelle et la livraison physique des biens, en optimisant la chaîne d'approvisionnement.\n\n### Ressources mobilisées\n• R4.MDEE.09 : Conduite de projet digital.\n• R3.01 : Marketing Mix.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MDEE.03 : Focus sur le backend logistique.\n\n### Critères d’évaluation\n• Réalisme opérationnel : Adéquation du dispositif logistique avec les promesses de délais et de coûts faites au client.\n• Performance de la supply chain : Capacité à proposer des solutions logistiques optimisant le prix de revient e-commerce.\n• Posture responsable : Prise en compte des enjeux éthiques et écologiques dans la gestion des livraisons et des retours.	2	MDEE	17
91	AC35.03MDEE	Elaborer les documents financiers nécessaires en tant que concepteur du business model	L'étudiant doit analyser de façon pertinente les indicateurs financiers pour garantir la viabilité économique de la start-up ou du projet.\n\n### Ressources mobilisées\n• R5.05 : Analyse financière.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Rigueur technique : Exactitude des bilans prévisionnels, seuils de rentabilité et plans de financement.\n• Crédibilité du modèle : Adéquation entre les besoins financiers identifiés et les objectifs de développement.\n\nEn résumé : cet AC garantit la solidité financière du projet e-business.	3	MDEE	20
92	AC35.04MDEE	Contrôler la conformité et la pertinence du modèle	L'expertise consiste à vérifier que le projet respecte les contraintes juridiques (droit du numérique, RGPD) et reste cohérent avec les objectifs de départ.\n\n### Ressources mobilisées\n• R6.MDEE.04 : Sécurisation d'un business model.\n\n### Mise en pratique (SAÉ)\n• Stage S6 : Mission de fin d'études.\n\n### Critères d’évaluation\n• Sûreté juridique : Absence de risques réglementaires majeurs dans le modèle proposé.\n• Posture critique : Capacité à remettre en question le modèle initial si la pertinence commerciale n'est plus démontrée.\n\nEn résumé : cet AC assure la conformité et la pérennité du modèle d'affaires.	3	MDEE	20
93	AC35.05MDEE	Choisir les techniques de créativité individuelle et collective adaptées	L'étudiant doit mobiliser les techniques adéquates pour faire émerger l'innovation au sein d'une équipe.\n\n### Ressources mobilisées\n• R5.MDEE.11 : Management de la créativité et de l'innovation.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MDEE.01 : Développement d'un projet digital.\n\n### Critères d’évaluation\n• Efficience du processus : Choix d'une méthode de créativité produisant des solutions réellement innovantes et exploitables.\n• Qualité de l'animation : Capacité à stimuler la génération d'idées au sein du collectif.\n\nEn résumé : cet AC permet de piloter l'innovation par des méthodes de créativité adaptées.	3	MDEE	20
98	AC34.01BI	Evaluer le diagnostic export/import et faire des préconisations	L'étudiant doit critiquer un diagnostic existant pour en extraire des recommandations stratégiques concrètes permettant de valider ou réorienter le développement international.\n\n### Ressources mobilisées\n• R5.01 : Stratégie d'entreprise 1.\n• R5.BI.10 : RCN appliquées au BI.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BI.01 : Conduite d'une mission import ou export.\n\n### Critères d’évaluation\n• Profondeur de la posture réflexive : Capacité à identifier les limites du diagnostic initial.\n• Valeur ajoutée des préconisations : Réalisme des solutions proposées face aux ressources réelles de l'entreprise.\n\nEn résumé : cet AC transforme un analyste en un conseiller capable de dire 'comment' réussir sur un marché.	3	BI	22
94	AC35.06MDEE	Développer un projet de façon proactive	L'étudiant agit comme un initiateur, capable de piloter le projet avec autonomie et de s'intégrer activement dans une dynamique collective.\n\n### Ressources mobilisées\n• R5.MDEE.09 : Management de projet digital.\n\n### Mise en pratique (SAÉ)\n• Stage S6 : Mission de fin d'études.\n\n### Critères d’évaluation\n• Leadership et autonomie : Capacité à prendre des décisions rapides face aux imprévus du développement.\n• Esprit d'entreprise : Démontrer une volonté de faire aboutir le projet au-delà des simples consignes.\n\nEn résumé : cet AC forge la posture de responsable de projet e-business proactif.	3	MDEE	20
69	AC35.03MMPV	Gérer la relation avec les fournisseurs ou le réseau	L'étudiant agit en tant qu'interface entre le point de vente et ses partenaires pour optimiser les conditions d'approvisionnement et de collaboration.\n\n### Ressources mobilisées\n• R5.MMPV.13 : Supply chain.\n• R5.MMPV.15 : Trade marketing.\n\n### Critères d’évaluation\n• Conformité aux accords de réseau : Respect rigoureux des directives de l'enseigne et des procédures de référencement fournisseurs.\n• Efficience opérationnelle : Qualité du suivi des flux et capacité à résoudre les litiges logistiques ou commerciaux avec les partenaires.\n\nEn résumé : cet AC garantit la fluidité et la conformité de la relation avec les partenaires amont.	3	MMPV	16
83	AC25.01MDEE	Concevoir un modèle d'affaires simplifié	L'étudiant doit élaborer un document décrivant la création, la livraison et le partage de la valeur pour un projet entrepreneurial ou intrapreneurial.\n\n### Ressources mobilisées\n• R4.MDEE.11 : Business model-1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MDEE.02 : Démarche de création d’entreprise en contexte digital.\n\n### Critères d'évaluation\n• Cohérence de la proposition de valeur : Adéquation entre le problème identifié et la solution digitale proposée.\n• Logique du modèle : Clarté de l'articulation entre les segments de clientèle et les flux de revenus.\n\nEn résumé : cet AC permet de poser les bases économiques viables d'un projet avant son lancement technique.	2	MDEE	19
16	AC12.04	Évaluer la performance commerciale au moyen d'indicateurs	Cette étape consiste à utiliser des outils chiffrés pour analyser les résultats d'une action commerciale, comme le taux de transformation ou le panier moyen.\n\n### Ressources mobilisées\n• R1.07 : Techniques quantitatives.\n• R1.08 : Éléments financiers.\n• R2.05 : Coûts, marges et prix.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : Analyse des résultats de prospection.\n• SAÉ 2.02 : Vente : initiation au jeu de rôle de négociation.\n\n### Critères d'évaluation\n• Exactitude des calculs et pertinence de l'analyse des résultats.\n\nEn résumé : cet AC donne à l'étudiant la capacité de mesurer l'efficacité de son travail et d'identifier des axes d'amélioration.	1	Tronc Commun	4
1	AC11.01	Analyser l'environnement d'une entreprise en repérant et appréciant les sources d'informations	L'étudiant doit apprendre à réaliser un diagnostic externe et interne en s'appuyant sur des données vérifiées. L'accent est mis sur la capacité à distinguer les sources d'informations fiables pour comprendre le contexte du marché.\n\n### Ressources mobilisées (S1)\n• R1.01 : Fondamentaux du marketing et comportement du consommateur.\n• R1.05 : Environnement économique de l'entreprise.\n• R1.06 : Environnement juridique de l'entreprise.\n• R1.12 : Rôle et organisation de l'entreprise sur son marché.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.01 : Marketing : positionnement d'une offre simple sur un marché.\n\n### Critères d'évaluation\n• Justesse du diagnostic des forces, faiblesses, opportunités et menaces.\n• Pertinence et crédibilité des sources documentaires exploitées.\n\nEn résumé : cet AC apprend à fonder toute décision marketing sur une analyse rigoureuse et factuelle de la réalité de l'entreprise.	1	Tronc Commun	1
3	AC11.03	Choisir une cible et un positionnement en fonction de la segmentation du marché	Sur la base de l'analyse, l'étudiant doit segmenter le marché, sélectionner le segment le plus porteur (ciblage) et définir une promesse distinctive pour le consommateur par rapport à la concurrence (positionnement).\n\n### Ressources mobilisées (S1/S2)\n• R1.01 : Fondamentaux du marketing.\n• R2.01 : Marketing mix (stratégie marketing).\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.01 : Marketing : positionnement d'une offre simple sur un marché.\n\n### Critères d'évaluation\n• Cohérence stratégique entre le segment choisi et les ressources de l'entreprise.\n• Clarté et différenciation du positionnement proposé.\n\nEn résumé : cet AC apprend à 'trancher' stratégiquement pour que l'offre soit adressée aux bons clients avec le bon message.	1	Tronc Commun	1
99	AC34.02BI	Evaluer les marchés internationaux en prenant en compte le contexte géo-éco-politique	Il s'agit d'intégrer des variables complexes (conflits, barrières douanières, stabilité monétaire) pour juger de la viabilité d'un marché sur le long terme.\n\n### Ressources mobilisées\n• R5.03 : Financement et régulation de l’économie.\n• R5.BI.13 : Droit international.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BI.01 : Conduite d'une mission import ou export.\n\n### Critères d’évaluation\n• Maîtrise des risques géopolitiques : Justesse de l'analyse de l'impact des tensions internationales sur le business model.\n• Pertinence de la veille : Qualité et actualité des données économiques utilisées pour l'évaluation.\n\nEn résumé : cet AC permet d'anticiper les tempêtes politiques pour protéger les intérêts de l'entreprise.	3	BI	22
100	AC34.03BI	Proposer le mode d'entrée (filiale, joint venture, etc.) le plus adéquate	L'étudiant doit arbitrer entre les différentes modalités juridiques et financières d'implantation pour optimiser la présence de l'offre sur le marché ciblé.\n\n### Ressources mobilisées\n• R5.BI.13 : Droit international.\n• R5.01 : Stratégie d'entreprise 1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.BI.01 : Conduite d'une mission import ou export.\n• Stage S6 : Mission de fin d'études.\n\n### Critères d’évaluation\n• Cohérence juridique : Adéquation du montage (ex: Joint venture) avec la législation locale et le niveau de risque accepté.\n• Optimisation financière : Justification du choix en fonction du coût d'implantation et du retour sur investissement attendu.\n\nEn résumé : cet AC fixe le cadre légal et structurel de la conquête d'un nouveau pays.	3	BI	22
84	AC25.02MDEE	Analyser de façon pertinente la situation marché-entreprise grâce aux outils de diagnostic stratégique	Il s'agit d'utiliser des matrices d'analyse pour confronter les ressources de l'organisation aux opportunités du marché digital.\n\n### Ressources mobilisées\n• R3.MDEE.15 : Stratégie de marketing digital.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MDEE.03 : Analyse d'une activité digitale.\n\n### Critères d'évaluation\n• Justesse du diagnostic : Utilisation rigoureuse des outils stratégiques (type SWOT ou PESTEL) adaptés au web.\n• Pertinence des conclusions : Capacité à identifier les avantages concurrentiels réels de l'entreprise sur son marché cible.\n\nEn résumé : cet AC assure que le projet s'appuie sur une compréhension réelle de son environnement concurrentiel.	2	MDEE	19
85	AC25.03MDEE	Analyser la situation financière d'une entreprise à partir des éléments de la comptabillité générale	L'étudiant doit savoir interpréter les documents financiers de base pour évaluer la santé et la faisabilité financière d'un projet.\n\n### Ressources mobilisées\n• R1.08 / R1.14 : Éléments financiers de l'entreprise.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MDEE.02 : Développement d'un 'Business Plan digital'.\n\n### Critères d'évaluation\n• Fiabilité de l'interprétation : Exactitude de l'analyse du bilan et du compte de résultat.\n• Maîtrise des indicateurs : Capacité à calculer et expliquer les ratios de rentabilité simples.\n\nEn résumé : cet AC garantit la compréhension des enjeux financiers indispensables à la survie d'une start-up ou d'un projet.	2	MDEE	19
86	AC25.04MDEE	Identifier les éléments pertinents nécessaires à la réalisation du projet	L'étudiant doit lister et planifier l'ensemble des moyens (humains, techniques, financiers) requis pour concrétiser l'idée en projet réel.\n\n### Ressources mobilisées\n• R4.MDEE.09 : Conduite de projet digital.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MDEE.02 : Démarche de création d’entreprise.\n\n### Critères d'évaluation\n• Exhaustivité de l'inventaire : Prise en compte de tous les besoins, notamment les contraintes juridiques et technologiques.\n• Réalisme du cadrage : Adéquation entre les ressources identifiées et les délais impartis.\n\nEn résumé : cet AC transforme une vision abstraite en une feuille de route opérationnelle.	2	MDEE	19
87	AC25.05MDEE	Utiliser les techniques de créativité individuelle et collective	Il s'agit de mobiliser des méthodes de génération d'idées (brainstorming, mind mapping, etc.) pour favoriser l'innovation au sein du projet.\n\n### Ressources mobilisées\n• R3.MDEE.16 : Créativité et innovation.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.MDEE.02 : Ateliers de création.\n\n### Critères d'évaluation\n• Diversité des propositions : Capacité à produire un grand nombre d'idées originales avant la phase de sélection.\n• Efficacité de la méthode : Aptitude à animer ou participer activement à une séance de créativité collective.\n\nEn résumé : cet AC permet de 'sortir du cadre' pour trouver des solutions innovantes et différenciantes.	2	MDEE	19
4	AC11.04	Concevoir une offre cohérente et éthique en termes de produits, de prix, de distribution et de communication	L'étudiant élabore ici le mix-marketing opérationnel. L'offre doit être mutuellement cohérente entre ses 4 piliers et respecter une posture citoyenne, éthique et écologique.\n\n### Ressources mobilisées (S2)\n• R2.01 : Marketing mix - 1.\n• R2.05 : Coûts, marges et prix d'une offre simple.\n• R2.10 : Connaissance des canaux de commercialisation et distribution.\n• R2.03 : Moyens de la communication commerciale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 2.01 : Marketing : marketing mix.\n\n### Critères d'évaluation\n• Adéquation opérationnelle du mix avec le positionnement cible.\n• Respect de la réglementation en vigueur et des enjeux de la RSE.\n\nEn résumé : cet AC finalise la construction concrète du produit prêt à être lancé de manière responsable sur son marché.	1	Tronc Commun	1
17	AC12.05	Recourir aux techniques adaptées à la démarche de prospection	L'étudiant doit savoir qualifier un fichier de prospects, réaliser un plan d'appel (script) et maîtriser la prise de contact, notamment téléphonique.\n\n### Ressources mobilisées\n• R1.02 : Vente.\n• R1.10 : Initiation à la conduite de projet.\n• R1.13 : Ressources et culture numériques 1 (CRM).\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : Vente : démarche de prospection.\n\n### Critères d'évaluation\n• Qualité du fichier de prospects et efficacité de la prise de contact initiale.\n\nEn résumé : cet AC est crucial pour le développement commercial car il apprend à générer de nouvelles opportunités d'affaires.	1	Tronc Commun	4
18	AC12.06	Recourir aux codes d'expression spécifiques et professionnels	Il s'agit de maîtriser la posture professionnelle : communication verbale (ton, vocabulaire) et non verbale (tenue, gestuelle) pour instaurer la confiance.\n\n### Ressources mobilisées\n• R1.14 : Expression, communication et culture 1.\n• R2.09 : Psychologie sociale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 1.02 : Vente : démarche de prospection.\n• SAÉ 2.02 : Vente : initiation au jeu de rôle de négociation.\n\n### Critères d'évaluation\n• Maîtrise de l'écoute active et adéquation du comportement avec les attentes professionnelles.\n\nEn résumé : cet AC forge l'identité professionnelle de l'étudiant pour qu'il soit perçu comme un partenaire crédible.	1	Tronc Commun	4
31	AC13.04	Analyser les indicateurs post campagne	Une fois le communication lancée, l'étudiant doit mesurer si elle a atteint ses buts en analysant des données chiffrées (taux de clic, mémorisation, retours clients).\n\n### Ressources mobilisées\n• R1.10 : Études marketing.\n• R1.07 : Techniques quantitatives et représentations.\n\n### Mise en pratique (SAÉ)\n• SAÉ 2.03 : Élaboration d’un plan de communication commerciale.\n\n### Critères d'évaluation\n• Exactitude de l'interprétation des indicateurs de performance (KPIs).\n• Capacité à proposer des mesures correctives si les objectifs n'ont pas été atteints.\n\nEn résumé : cet AC apporte la preuve par le chiffre que l'investissement en communication a été utile.	1	Tronc Commun	7
5	AC21.01	Diagnostiquer l'environnement en appréhendant les enjeux sociaux et écologiques	L'étudiant doit élargir son analyse au-delà du simple marché pour intégrer les enjeux de la Responsabilité Sociétale des Entreprises (RSE). Il s'agit de comprendre comment les pressions sociales et environnementales impactent la viabilité d'un projet.\n\n### Ressources mobilisées (Cours)\n• R3.01 : Marketing mix - 2.\n• R3.05 : Environnement économique international.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.01 : Pilotage d'un projet en déployant les techniques de commercialisation.\n\n### Critères d'évaluation\n• Pertinence du diagnostic RSE et identification des impacts éthiques.\n• Capacité à lier les contraintes environnementales aux choix stratégiques de l'entreprise.\n\nEn résumé : cet AC apprend à intégrer le développement durable comme une contrainte structurante du marketing moderne.	2	Tronc Commun	2
6	AC21.02	Mettre en oeuvre une étude de marché dans un environnement complexe	L'étude de marché ne porte plus sur un produit simple mais sur des contextes complexes (B2B, innovation technologique, marchés saturés). L'étudiant doit mobiliser des outils d'analyse plus pointus pour traiter des données de masse.\n\n### Ressources mobilisées (Cours)\n• R3.04 : Études marketing - 3.\n• R3.07 : Techniques quantitatives et représentations - 3.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.01 : Pilotage d'un projet complexe.\n\n### Critères d'évaluation\n• Rigueur de la méthodologie face à une problématique peu familière ou mouvante.\n• Exactitude de l'analyse des comportements des consommateurs avancés ou des acheteurs professionnels.\n\nEn résumé : cet AC apprend à lever les incertitudes sur des marchés où l'information est difficile à obtenir ou à interpréter.	2	Tronc Commun	2
7	AC21.03	Mettre en place une stratégie marketing dans un environnement complexe	Il s'agit ici de définir des orientations stratégiques (segmentation, ciblage, positionnement) pour des offres qui sortent de l'ordinaire ou pour des segments de niche très spécifiques.\n\n### Ressources mobilisées (Cours)\n• R4.01 : Stratégie marketing.\n• R3.01 : Marketing Mix - 2.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d'évaluation\n• Différenciation réelle du positionnement face à une concurrence agressive.\n• Cohérence entre les préconisations stratégiques et les capacités financières/humaines de l'organisation.\n\nEn résumé : cet AC apprend à décider d'une direction claire pour une marque dans un environnement concurrentiel intense.	2	Tronc Commun	2
8	AC21.04	Concevoir un mix étendu pour une offre complexe	L'étudiant élabore un marketing mix qui va au-delà des 4P classiques pour inclure les services, les processus et les preuves matérielles (7P) nécessaires à une offre innovante ou complexe.\n\n### Ressources mobilisées (Cours)\n• R3.01 : Marketing mix - 2.\n• R4.01 : Stratégie marketing.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d'évaluation\n• Synergie parfaite entre tous les éléments du mix étendu.\n• Caractère innovant et éthique de la solution proposée au client.\n\nEn résumé : cet AC finalise la construction concrète d'une solution client complète, performante et prête pour un marché complexe.	2	Tronc Commun	2
20	AC22.02	Négocier le prix : défendre, valoriser l'offre	Il s'agit d'apprendre à maintenir ses marges en justifiant la valeur de l'offre face aux tactiques de négociation ou aux demandes de remise des acheteurs.\n\n### Ressources mobilisées\n• R4.02 : Négociation : rôle du vendeur et de l'acheteur.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d'évaluation\n• Capacité à identifier la stratégie de l'acheteur, pertinence des arguments de défense du prix et maintien de la rentabilité de l'offre.\n\nEn résumé : cet AC apprend à ne pas 'brader' son produit mais à faire accepter son prix par la démonstration de sa valeur.	2	Tronc Commun	5
21	AC22.03	Maîtriser les éléments juridiques et comptables de l'offre	L'étudiant doit sécuriser la vente en s'assurant que la proposition respecte le cadre légal (contrats, CGV) et les contraintes financières de l'entreprise.\n\n### Ressources mobilisées\n• R3.06 : Droit des activités commerciales 1.\n• R4.04 : Droit du travail.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d'évaluation\n• Conformité réglementaire des documents produits et exactitude des calculs de rentabilité (marges, seuil de rentabilité).\n\nEn résumé : cet AC garantit que la vente est juridiquement solide et économiquement viable.	2	Tronc Commun	5
22	AC22.04	Utiliser les OAV à bon escient pour convaincre	L'expertise consiste ici à intégrer les supports de vente (présentations numériques, simulateurs de coûts) de manière fluide durant l'entretien pour appuyer les moments clés de l'argumentation.\n\n### Ressources mobilisées\n• R3.12 : Ressources et culture numériques 3.\n• R3.02 : Entretien de vente.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.01 : Pilotage d'un projet.\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d'évaluation\n• Fluidité de l'utilisation des outils en situation réelle et impact visuel/pédagogique des supports sur le client.\n\nEn résumé : cet AC apprend à utiliser la technologie comme un levier de crédibilité et de preuve durant la vente.	2	Tronc Commun	5
23	AC22.05	Organiser le suivi de ses résultats	L'étudiant apprend à piloter son activité en analysant ses propres statistiques de vente pour s'auto-corriger et contribuer à la performance collective.\n\n### Ressources mobilisées\n• R3.08 : Tableau de bord commercial.\n• R3.07 : Techniques quantitatives.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.01 : Évaluation de la performance du projet.\n\n### Critères d'évaluation\n• Justesse de l'analyse des indicateurs clés (KPI) et pertinence des actions correctives proposées pour améliorer les futurs résultats.\n\nEn résumé : cet AC transforme le vendeur en un professionnel capable de gérer sa propre progression par les chiffres.	2	Tronc Commun	5
24	AC22.06	Prendre en compte les enjeux de la fonction achat	L'étudiant doit comprendre la logique de l'acheteur professionnel pour mieux vendre. Cela implique de saisir comment les décisions d'achat impactent globalement la rentabilité de l'organisation.\n\n### Ressources mobilisées\n• R4.02 : Négociation : rôles vendeur/acheteur.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d'évaluation\n• Compréhension démontrée des contraintes de sourcing et de gestion des risques de l'interlocuteur acheteur.\n\nEn résumé : cet AC permet de passer d'une vente 'frontale' à une vente 'partenaire' en comprenant les objectifs de l'autre partie.	2	Tronc Commun	5
35	AC23.04	Mettre en œuvre une stratégie digitale	Cette étape consiste à piloter la présence en ligne en animant des communautés et en collaborant avec des prescripteurs digitaux, tout en analysant les retours et l'image de marque sur le web.\n\n### Ressources mobilisées\n• R3.03 : Principes de la communication digitale.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.02 : Pilotage commercial d'une organisation.\n\n### Critères d’évaluation\n• Qualité de l'engagement généré sur les réseaux sociaux, maîtrise de l'image de marque en ligne (e-réputation) et pertinence des indicateurs de suivi (KPIs digitaux).\n\nEn résumé : cet AC donne les clés pour maîtriser la conversation avec le client dans l'écosystème numérique moderne.	2	Tronc Commun	8
10	AC31.02	Élaborer une stratégie marketing dans un environnement instable	Il s'agit de savoir pivoter ou ajuster une stratégie marketing lorsque les conditions de marché deviennent imprévisibles ou en cas de crise majeure.\n\n### Ressources mobilisées\n• R5.01 : Stratégie d'entreprise - 1.\n• R5.03 : Financement et régulation de l'économie.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.01/6.01 : Pilotage stratégique d'une organisation.\n\n### Critères d'évaluation\n• Robustesse de la stratégie : Cohérence des décisions face à un scénario de crise imposé (sanitaire, économique).\n• Qualité des justifications : Fluidité de l'argumentation s'appuyant sur les ressources stratégiques et financières.\n• Maîtrise des risques : Capacité à évaluer l'impact financier et commercial d'un changement de cap stratégique.\n\nEn résumé : cet AC forge la capacité de décision du futur manager marketing en période de haute incertitude.	3	Tronc Commun	3
11	AC31.03	Faire évoluer l'offre à l'aide de leviers de création de valeur	L'étudiant doit être capable de rénover ou d'étendre une offre existante en identifiant de nouveaux gisements de valeur (innovation d'usage, service, expérience client).\n\n### Ressources mobilisées\n• R5.01 : Stratégie d'entreprise - 1.\n• R5.BDMRC.11 : Management de la créativité et de l'innovation.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.01/6.01 : Pilotage stratégique d'une organisation et évaluation de performance projet.\n\n### Critères d'évaluation\n• Pertinence des leviers : Justification du choix des nouveaux éléments de l'offre par rapport aux attentes des clients.\n• Qualité de l'innovation : Caractère différenciant et viable de la solution proposée.\n• Analyse critique des résultats : Capacité à mesurer l'écart entre la valeur voulue et la valeur perçue par le client.\n\nEn résumé : cet AC apprend à ne jamais laisser une offre péricliter en la réinventant continuellement.	3	Tronc Commun	3
12	AC31.04	Intégrer la RSE dans la stratégie de l'offre	L'expertise consiste ici à faire de la Responsabilité Sociétale des Entreprises un pilier central du business model, et non un simple argument de communication.\n\n### Ressources mobilisées\n• R5.01 : Stratégie d'entreprise.\n• R5.03 : Économie et éthique.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.01/6.01 : Intégration systématique des enjeux RSE dans les projets de fin d'études.\n\n### Critères d'évaluation\n• Profondeur de l'intégration : L'offre doit respecter les principes d'éthique et de responsabilité environnementale sur l'ensemble de son cycle de vie.\n• Conformité réglementaire : Respect strict de la législation en vigueur et anticipation des normes futures.\n• Posture citoyenne : Capacité de l'étudiant à agir en responsabilité au sein d'une organisation professionnelle.\n\nEn résumé : cet AC finalise la posture d'expert en garantissant que la performance marketing est durable et éthiquement irréprochable.	3	Tronc Commun	3
95	AC24.01BI	Réaliser de manière structurée un diagnostic export/import à l'aide d'outils stratégiques	L'étudiant analyse la capacité de l'entreprise à sortir de son marché national en évaluant ses forces et faiblesses internes face aux contraintes mondiales.\n\n### Ressources mobilisées\n• R3.BI.15 : Stratégie et veille à l’international.\n• R3.12 : Ressources et culture numériques 3.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.BI.02 : Démarche de création d’entreprise à l’international.\n\n### Critères d'évaluation\n• Rigueur méthodologique : Utilisation correcte des matrices (type SWOT) adaptées à l'international.\n• Justesse de l'analyse : Capacité à identifier si l'offre actuelle est 'exportable' ou nécessite des modifications majeures.\n\nEn résumé : cet AC permet de valider la faisabilité d'un projet d'internationalisation avant tout investissement.	2	BI	21
96	AC24.02BI	Collecter les informations de l'environnement international	Il s'agit de mettre en œuvre une veille stratégique pour scanner les marchés étrangers et détecter les tendances ou menaces.\n\n### Ressources mobilisées\n• R3.BI.15 : Stratégie et veille à l’international.\n• R3.05 : Environnement économique international.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.BI.03 : Étude et sélection des marchés à l’étranger pour déployer l’offre.\n\n### Critères d'évaluation\n• Qualité du sourcing : Pertinence et fiabilité des sources d'information internationales utilisées.\n• Capacité de synthèse : Aptitude à extraire les signaux forts et faibles de l'environnement PESTEL mondial.\n\nEn résumé : cet AC apprend à transformer une masse de données mondiales en informations décisionnelles.	2	BI	21
97	AC24.03BI	Sélectionner les marchés opportuns, à l'export et à l'import à l'aide d'indicateurs	L'étudiant doit hiérarchiser les zones géographiques en utilisant des critères de sélection précis pour minimiser les risques.\n\n### Ressources mobilisées\n• R3.BI.15 : Stratégie et veille à l’international.\n• R3.07 : Techniques quantitatives et représentations 3.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.BI.03 : Étude et sélection des marchés à l’étranger.\n\n### Critères d'évaluation\n• Pertinence des indicateurs : Choix cohérent des indices (croissance, barrières douanières, risque pays).\n• Cohérence stratégique : Justification logique du choix final du marché par rapport aux objectifs de l'organisation.\n\nEn résumé : cet AC finalise l'étape stratégique en fixant des priorités géographiques rentables.	2	BI	21
101	AC25.01BI	Gérer les processus de vente et d'achat à l'international	L'étudiant apprend à coordonner le sourcing (achats) et la commercialisation (vente) en tenant compte des spécificités des échanges mondiaux.\n\n### Ressources mobilisées\n• R4.BI.09 : Stratégie achats.\n• R3.BI.16 : Marketing et vente à l’international.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BI.03 : Développement de l’offre à l’international.\n\n### Critères d'évaluation\n• Efficacité du sourcing : Capacité à évaluer et sélectionner des fournisseurs étrangers selon des critères de coût et de fiabilité.\n• Performance commerciale : Qualité de la négociation vente dans un cadre professionnel international.\n\nEn résumé : cet AC assure la maîtrise du cycle complet de la transaction marchande internationale.	2	BI	23
102	AC25.02BI	Suivre les opérations logistiques à l'international	Il s'agit de s'approprier et de piloter la liasse documentaire et les flux physiques pour garantir l'acheminement sécurisé des biens.\n\n### Ressources mobilisées\n• R4.BI.10 : Techniques du commerce international 1.\n• R4.04 : Droit du travail/Droit commercial.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BI.03 : Développement de l’offre à l’international.\n\n### Critères d'évaluation\n• Conformité documentaire : Absence d'erreur dans les documents douaniers et les titres de transport.\n• Réactivité opérationnelle : Capacité à coordonner les différents prestataires (transitaires, douanes).\n\nEn résumé : cet AC garantit que les marchandises arrivent physiquement et légalement à destination.	2	BI	23
103	AC25.03BI	Sélectionner le mode de transport, l'incoterm, l'assurance et les modalités de paiement	L'étudiant définit les conditions techniques et contractuelles pour sécuriser financièrement la transaction.\n\n### Ressources mobilisées\n• R4.BI.10 : Techniques du commerce international 1.\n• R4.02 : Négociation : rôle du vendeur et de l'acheteur.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BI.03 : Développement de l’offre à l’international.\n\n### Critères d'évaluation\n• Optimisation transport/assurance : Adéquation du choix logistique avec la nature de la marchandise et le budget.\n• Sécurisation financière : Justesse du choix de l'Incoterm et du moyen de paiement pour couvrir les risques.\n\nEn résumé : cet AC permet de blinder juridiquement et financièrement le contrat international.	2	BI	23
104	AC25.04BI	Positionner l'offre en fonction des spécificités culturelles	L'étudiant adapte le mix marketing international pour respecter les usages locaux et séduire la cible étrangère.\n\n### Ressources mobilisées\n• R4.BI.11 : Management interculturel.\n• R3.BI.16 : Marketing et vente à l’international.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.BI.03 : Développement de l’offre à l’international.\n\n### Critères d'évaluation\n• Adaptabilité culturelle : Cohérence des modifications apportées (packaging, message, prix) avec les valeurs du pays cible.\n• Agilité comportementale : Capacité à intégrer les codes de communication spécifiques lors des interactions professionnelles.\n\nEn résumé : cet AC assure que l'offre soit culturellement acceptable et commercialement compétitive à l'étranger.	2	BI	23
88	AC25.06MDEE	Contribuer à l'enrichissement d'un projet collectif	L'étudiant doit démontrer sa capacité à s'intégrer dans un groupe de travail, à partager ses idées et à soutenir l'effort commun.\n\n### Ressources mobilisées\n• R3.09 : Psychologie sociale du travail.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MDEE.03 : Création de site web en équipe.\n\n### Critères d'évaluation\n• Qualité de la collaboration : Respect des rôles attribués et contribution active aux livrables du groupe.\n• Posture proactive : Force de proposition pour améliorer le travail collectif et résoudre les tensions éventuelles.\n\nEn résumé : cet AC valide le savoir-être indispensable pour réussir au sein d'une équipe projet ou d'une start-up.	2	MDEE	19
55	AC24.02MMPV	Communiquer sur les objectifs et les résultats efficacement et professionnellement	Il s'agit de transmettre les informations stratégiques et opérationnelles à l'équipe de vente de manière claire et motivante.\n\n### Ressources mobilisées\n• R3.13 : Expression, communication, culture 3.\n• R4.MMPV.10 : Management des équipes.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MMPV.03 : Propositions d’amélioration du fonctionnement du point de vente.\n\n### Critères d’évaluation\n• Clarté et précision du discours : Utilisation d'un vocabulaire professionnel adapté et transmission d'objectifs sans ambiguïté.\n• Professionnalisme de la posture : Maîtrise de la communication non-verbale lors d'un briefing d'équipe ou d'un entretien de bilan.\n• Qualité des supports : Efficacité visuelle et rigueur des documents de synthèse présentés à l'équipe.	2	MMPV	13
64	AC25.03MMPV	Agencer l'offre sur l'espace de vente en utilisant les techniques de merchandising	L'étudiant doit développer l'attractivité commerciale de l'espace de vente, notamment par la théâtralisation, pour optimiser les indicateurs de vente.\n\n### Ressources mobilisées\n• R4.MMPV.09 : Merchandising.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.MMPV.03 : Propositions d’amélioration du fonctionnement du point de vente.\n\n### Critères d’évaluation\n• Efficacité visuelle : Qualité de l'implantation des produits et capacité à créer un parcours client fluide et incitatif.\n• Impact sur la performance : Cohérence entre l'agencement proposé et l'optimisation attendue des indicateurs commerciaux (ex: panier moyen).\n\nEn résumé : cet AC permet d'optimiser la mise en valeur des produits pour favoriser l'acte d'achat.	2	MMPV	15
65	AC25.04MMPV	Personnaliser la relation client en appliquant les principes de base de la GRC	L'expertise consiste à enrichir l'expérience client en utilisant les outils de Gestion de la Relation Client (GRC/CRM) pour fidéliser et personnaliser l'accueil.\n\n### Ressources mobilisées\n• R4.MMPV.11 : GRC.\n\n### Critères d’évaluation\n• Qualité de l'écoute : Capacité à exploiter les informations client pour proposer une solution adaptée.\n• Usage des outils de fidélisation : Pertinence de l'utilisation des bases de données et des programmes de récompense pour renforcer le lien client.\n\nEn résumé : cet AC apprend à placer le client au cœur de la stratégie du point de vente.	2	MMPV	15
66	AC25.05MMPV	Gérer la diversité des points de contact avec le client	L'étudiant doit assurer la cohérence du parcours client dans une perspective omnicanale, intérating les points de vente physiques et les canaux digitaux.\n\n### Ressources mobilisées\n• R3.03 : Principes de la communication digitale.\n\n### Critères d’évaluation\n• Continuité de l'expérience : Capacité à gérer sans rupture le passage du client d'un canal à l'autre (ex: Click & Collect).\n• Cohérence du message : Alignement de l'offre et du discours commercial sur l'ensemble des points de contact (physiques, web, réseaux sociaux).\n\nEn résumé : cet AC garantit une expérience client sans couture entre le monde physique et le digital.	2	MMPV	15
58	AC34.02MMPV	Fédérer les équipes autour de l'atteinte des objectifs	Il s'agit d'assurer la cohésion du groupe et l'adhésion aux valeurs de l'organisation.\n\n### Ressources mobilisées\n• R5.MMPV.12 : Management d'équipe.\n• R3.09 : Psychologie sociale du travail.\n\n### Critères d'évaluation\n• Qualité de l'animation : Capacité à mener des briefings motivants et à gérer les relations sociales au sein de l'espace de vente.\n• Posture réflexive : Aptitude à critiquer ses propres résultats d'animation et à proposer des pistes de régulation en cas de tensions ou de baisse de motivation.\n• Justesse relationnelle : Capacité à adapter son discours managérial à la diversité des profils de l'équipe.\n\nEn résumé : cet AC forge le leadership nécessaire pour fédérer l'équipe autour d'un projet commun.	3	MMPV	14
59	AC34.03MMPV	Sélectionner des collaborateurs en considérant les besoins de l'équipe	L'étudiant doit piloter un processus de recrutement adapté aux manques en compétences du collectif.\n\n### Ressources mobilisées\n• R6.MMPV.03 : Droit du travail et relations sociales dans l'entreprise.\n\n### Critères d'évaluation\n• Pertinence du diagnostic RH : Capacité à identifier précisément les besoins en compétences manquantes avant de lancer la sélection.\n• Conformité réglementaire : Respect rigoureux des procédures de recrutement conformément au droit du travail.\n• Éthique de sélection : Adéquation du choix du candidat avec les valeurs de l'enseigne et les besoins opérationnels du rayon.\n\nEn résumé : cet AC permet de recruter les bons profils pour renforcer l'équipe.	3	MMPV	14
60	AC34.04MMPV	Intégrer des collaborateurs à l'équipe	L'expertise consiste à concevoir et piloter un parcours d'onboarding efficace.\n\n### Ressources mobilisées\n• R5.MMPV.12 : Management d'équipe.\n• R3.13 : Communication interne.\n\n### Critères d'évaluation\n• Efficience du parcours d'intégration : Qualité des outils de suivi (livret d'accueil, planning de formation interne) permettant une opérationnalité rapide du nouveau venu.\n• Transmission de la culture : Aptitude à faire adopter les codes de service et les pratiques de l'organisation au nouveau collaborateur.\n• Suivi et accompagnement : Capacité à évaluer les premières étapes de l'intégration et à ajuster l'accompagnement si nécessaire.\n\nEn résumé : cet AC garantit une intégration réussie pour pérenniser l'engagement des nouveaux arrivants.	3	MMPV	14
61	AC34.05MMPV	Valoriser les compétences des membres de l'équipe	Le manager agit comme un coach pour accompagner la montée en compétences et déléguer des responsabilités.\n\n### Ressources mobilisées\n• R5.MMPV.12 : Management d'équipe.\n• R6.MMPV.04 : Pilotage des ressources humaines.\n\n### Critères d'évaluation\n• Reconnaissance et délégation : Aptitude à identifier les potentiels évolutifs et à proposer des missions de délégation pertinentes.\n• Démonstration de la progression : Capacité à apporter des preuves concrètes (comptes rendus d'entretiens, fiches d'évaluation) du développement des compétences des collaborateurs.\n• Impact sur l'identité professionnelle : Capacité à valoriser les succès individuels pour renforcer le sentiment d'appartenance.\n\nEn résumé : cet AC permet de faire grandir ses collaborateurs pour améliorer la performance globale.	3	MMPV	14
67	AC35.01MMPV	Comprendre les enjeux de la distribution et les évolutions du secteur	L'étudiant doit développer une vision prospective du commerce pour anticiper les mutations technologiques et sociétales.\n\n### Ressources mobilisées\n• R5.MMPV.14 : Droit de la distribution.\n• R6.MMPV.04 : Prise de décision – pilotage.\n\n### Critères d’évaluation\n• Profondeur de l'analyse sectorielle : Capacité à identifier les tendances émergentes (phygital, économie circulaire) et à évaluer leur impact sur le modèle économique du point de vente.\n• Maîtrise du cadre réglementaire : Justesse de l'interprétation des évolutions législatives impactant la distribution (droit de la concurrence, contrats de réseau).\n\nEn résumé : cet AC permet d'anticiper les mutations du secteur pour adapter la stratégie du point de vente.	3	MMPV	16
68	AC35.02MMPV	Elaborer une stratégie commerciale en cohérence avec l'environnement concurrentiel	Il s'agit de définir des axes prioritaires pour maintenir l'avantage compétitif du magasin sur sa zone de chalandise.\n\n### Ressources mobilisées\n• R5.MMPV.15 : Trade marketing.\n• R5.01 : Stratégie d'entreprise-1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MMPV.01 : Approche omnicanal du point de vente.\n\n### Critères d’évaluation\n• Pertinence du positionnement : Adéquation entre la stratégie proposée et les forces/faiblesses des concurrents locaux identifiés.\n• Rigueur du pilotage : Capacité à justifier ses décisions stratégiques en s'appuyant sur des indicateurs de rentabilité et des ressources théoriques solides.\n\nEn résumé : cet AC permet de définir et de piloter une stratégie commerciale locale efficace.	3	MMPV	16
70	AC35.04MMPV	Implanter un plan de merchandising	L'expertise consiste à traduire physiquement la stratégie de l'offre pour maximiser l'attractivité et la théâtralisation de l'espace de vente.\n\n### Ressources mobilisées\n• R5.MMPV.11 : Parcours expérience client.\n\n### Critères d’évaluation\n• Efficacité de la théâtralisation : Impact visuel et commercial de l'implantation sur le comportement d'achat (augmentation du panier moyen, fluidité du trafic).\n• Rigueur d'exécution : Conformité stricte du plan de masse ou du planogramme avec les objectifs de rentabilité au mètre linéaire.\n\nEn résumé : cet AC permet de transformer l'espace de vente en un levier de performance par le merchandising.	3	MMPV	16
71	AC35.05MMPV	Optimiser les outils de GRC	L'étudiant doit exploiter les données clients pour personnaliser la relation et accroître la fidélisation.\n\n### Ressources mobilisées\n• R4.MMPV.11 : GRC.\n• R5.MMPV.10 : RCN appliquées.\n\n### Critères d’évaluation\n• Qualité de l'exploitation de la data : Capacité à segmenter la base de données pour proposer des actions de fidélisation ciblées et pertinentes.\n• Performance des préconisations : Justesse du choix des leviers de GRC pour améliorer la valeur client (Life Time Value).\n\nEn résumé : cet AC apprend à optimiser la valeur client par une gestion des données experte.	3	MMPV	16
72	AC35.06MMPV	Optimiser le parcours client dans une perspective omnicanale	L'objectif est d'assurer une expérience sans couture entre le point de vente physique et les canaux numériques.\n\n### Ressources mobilisées\n• R5.MMPV.11 : Parcours expérience client.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.MMPV.01 : Approche omnicanal du point de vente.\n\n### Critères d’évaluation\n• Fluidité de l'expérience : Élimination des points de friction lors du passage du client d'un canal à l'autre (ex : disponibilité du stock pour le Click & Collect).\n• Mesure et amélioration : Pertinence de l'utilisation des mesures de satisfaction (NPS, CSAT) pour apporter des correctifs concrets au parcours client.\n\nEn résumé : cet AC garantit l'alignement stratégique et opérationnel de l'expérience omnicanale.	3	MMPV	16
36	AC24.01SME	Identifier les valeurs et territoires de la marque	L'étudiant doit savoir isoler l'ADN de la marque, ses valeurs fondamentales et définir son périmètre d'expression (physique, symbolique et concurrentiel).\n\n### Ressources mobilisées\n• R3.SME.16 : Fondamentaux de la communication de marque.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.SME.02 : Démarche de création d’entreprise dans l’événementiel ou la communication.\n\n### Critères d’évaluation\n• Justesse de la détermination des valeurs : Capacité à extraire des composantes identitaires uniques et différenciantes pour la marque.\n• Rigueur de l'analyse territoriale : Pertinence du positionnement identifié face aux attentes du marché et à la concurrence.\n\nEn résumé : cet AC permet de définir le socle identitaire de la marque.	2	SME	9
37	AC24.02SME	Mesurer la visibilité de la marque et sa notoriété	Il s'agit d'apprendre à utiliser des outils de mesure pour évaluer si la marque est connue (notoriété) et si elle est présente efficacement sur ses différents canaux (visibilité).\n\n### Ressources mobilisées\n• R3.04 : Études marketing 3.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.SME.03 : Création d’un événement comme outil de branding.\n\n### Critères d’évaluation\n• Précision de la mesure : Capacité à distinguer et quantifier correctement l'image voulue (stratégie) de l'image perçue (public).\n• Maîtrise des indicateurs : Choix cohérent des KPIs pour évaluer l'impact des actions de rayonnement.\n\nEn résumé : cet AC permet de quantifier le rayonnement réel de la marque.	2	SME	9
39	AC24.04SME	Piloter les relations publiques et les relations presse en veillant aux différentes parutions de la marque	Il s'agit de gérer les interactions avec les journalistes, influenceurs et relais d'opinion pour assurer une couverture médiatique positive.\n\n### Ressources mobilisées\n• R4.SME.09 : Relations publiques et relations presse.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.SME.03 : Organisation d’un événement comme outil de branding.\n\n### Critères d’évaluation\n• Pertinence des supports RP : Qualité rédactionnelle et stratégique des communiqués ou dossiers de presse.\n• Veille et suivi : Capacité à répertorier et analyser les retombées médiatiques pour ajuster la communication en temps réel.\n\nEn résumé : cet AC apprend à piloter l'influence et la réputation de la marque dans les médias.	2	SME	9
44	AC25.01SME	Elaborer un projet événementiel simple répondant à la demande	L'étudiant doit concevoir un concept d'événement (interne, public ou pour un prestataire) qui s'aligne sur les besoins d'un commanditaire.\n\n### Ressources mobilisées\n• R3.SME.15 : Marketing de l’événementiel-1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.SME.02 : Démarche de création d’entreprise dans l’événementiel.\n\n### Critères d’évaluation\n• Pertinence conceptuelle : Adéquation entre le concept créatif proposé et les objectifs stratégiques du brief.\n• Rigueur du diagnostic : Capacité à justifier les choix artistiques et thématiques en fonction de la cible visée.\n• Faisabilité : Réalisme technique de la proposition au regard de la demande initiale.\n\nEn résumé : cet AC permet de concevoir un concept événementiel pertinent et viable.	2	SME	11
45	AC25.02SME	Intégrer les contraintes financières, juridiques et logistiques	Il s'agit de sécuriser le projet en maîtrisant les budgets, les contrats et l'organisation matérielle.\n\n### Ressources mobilisées\n• R4.SME.10 : Organisation et logistique-1.\n• R4.SME.11 : Gestion commerciale-1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 3.SME.03 : Création d’un événement comme outil de branding.\n\n### Critères d’évaluation\n• Fiabilité budgétaire : Exactitude du budget prévisionnel et capacité à optimiser les coûts sans dégrader la qualité.\n• Conformité réglementaire : Respect des règles de sécurité des ERP et du droit des contrats.\n• Précision logistique : Qualité de la planification des flux (matériel, personnels, public) pour éviter les ruptures de service.\n\nEn résumé : cet AC garantit la solidité administrative, financière et matérielle du projet.	2	SME	11
46	AC25.03SME	Gérer la communication et la commercialisation de l'événement	L'étudiant doit assurer la visibilité de l'événement et, si nécessaire, la vente de billets ou la recherche de partenaires.\n\n### Ressources mobilisées\n• R4.SME.09 : Relations publiques et relations presse.\n\n### Mise en pratique (SAÉ)\n• SAÉ 4.SME.03 : Organisation d’un événement comme outil de branding.\n\n### Critères d’évaluation\n• Efficience du plan de com : Pertinence du choix des supports pour maximiser le taux de participation.\n• Efficacité commerciale : Capacité à convaincre des sponsors ou à atteindre les objectifs de billetterie.\n• Cohérence visuelle : Respect de la charte graphique et de l'ADN de la marque à travers tous les outils de promotion.\n\nEn résumé : cet AC permet de maximiser le rayonnement et le succès commercial de l'événement.	2	SME	11
47	AC25.04SME	Piloter le projet	L'expertise consiste ici à coordonner l'ensemble des parties prenantes et à gérer les imprévus durant la phase de réalisation.\n\n### Ressources mobilisées\n• Ressources de gestion de projet.\n• Management d'équipe.\n\n### Critères d’évaluation\n• Maîtrise du rétroplanning : Respect rigoureux des jalons et des délais de livraison des prestataires.\n• Qualité du leadership : Capacité à animer l'équipe projet et à coordonner les intervenants le jour J.\n• Réactivité : Aptitude à proposer des solutions de régulation efficaces face aux aléas logistiques ou techniques.\n\nEn résumé : cet AC forge la capacité de pilotage opérationnel en situation réelle.	2	SME	11
48	AC25.05SME	Mesurer l'impact de l'événement	L'étudiant doit évaluer la performance de l'événement en confrontant les résultats aux objectifs de marque initiaux.\n\n### Ressources mobilisées\n• R3.04 : Études marketing.\n• Outils de mesure de satisfaction.\n\n### Critères d’évaluation\n• Pertinence des KPIs : Justesse du choix des indicateurs pour mesurer la satisfaction du public et les retombées médias.\n• Profondeur de l'analyse : Capacité à interpréter l'écart entre l'image voulue par la marque et l'image perçue par les participants.\n• Posture critique : Qualité du bilan post-événement identifiant clairement les axes d'amélioration.\n\nEn résumé : cet AC permet de mesurer le ROI et la valeur ajoutée de l'événement pour la marque.	2	SME	11
41	AC34.02SME	Elaborer une idéologie de marque et ses composantes	Il s'agit de définir l'ADN de la marque, ses valeurs défendues, sa mission et sa vision du monde.\n\n### Ressources mobilisées\n• R6.SME.03 : Stratégie de développement de marque.\n\n### Critères d’évaluation\n• Cohérence de l'ADN : Solidité du lien entre les valeurs revendiquées et l'histoire (ou le projet) de l'organisation.\n• Puissance narrative : Capacité à transformer une idéologie abstraite en composantes concrètes et mobilisatrices pour les publics internes et externes.\n• Intégration éthique et sociétale : Qualité de l'intégration des enjeux de RSE dans le socle de valeurs de la marque.\n\nEn résumé : cet AC permet de définir la mission et les valeurs fondamentales qui guident l'action de la marque.	3	SME	10
42	AC34.03SME	Construire l'identité de la marque	L'étudiant doit concevoir l'ensemble des signes (visuels, sémantiques, comportementaux) qui rendent la marque reconnaissable et unique.\n\n### Ressources mobilisées\n• R5.SME.15 : Conception graphique.\n\n### Critères d’évaluation\n• Harmonie du mix identitaire : Cohérence totale entre l'identité visuelle (logo, charte), l'identité verbale (nom, ton de voix) et l'idéologie définie précédemment.\n• Adaptabilité multicanale : Efficacité du système identitaire à rester déclinable et lisible sur tous les points de contact, du packaging aux réseaux sociaux.\n• Qualité des résultats : Capacité à produire des supports de communication hautement qualitatifs respectant la plateforme de marque.\n\nEn résumé : cet AC permet de matérialiser la stratégie de marque à travers un système de signes cohérent.	3	SME	10
43	AC34.04SME	Développer la communauté de marque et l'adhésion	L'expertise consiste à fédérer un public autour de la marque et à piloter son rayonnement numérique.\n\n### Ressources mobilisées\n• R5.SME.12 : Marketing digital de la marque.\n\n### Critères d’évaluation\n• Efficience du community management : Pertinence des leviers d'engagement choisis pour transformer des prospects en ambassadeurs actifs de la marque.\n• Maîtrise de l'e-réputation : Qualité de la veille et capacité à réagir de façon proactive pour protéger et valoriser l'image de marque en ligne.\n• Mesure de l'adhésion : Justesse de l'interprétation des indicateurs de performance (taux d'engagement, sentiment de marque) pour réguler la stratégie relationnelle.\n\nEn résumé : cet AC permet de piloter l'engagement communautaire et de protéger l'image de la marque sur le web.	3	SME	10
49	AC35.01SME	Créer un événement complexe adapté aux attentes du commanditaire	L'étudiant doit concevoir un concept événementiel d'envergure qui s'intègre parfaitement dans la stratégie globale d'une marque.\n\n### Ressources mobilisées\n• R5.SME.16 : Marketing de l’événementiel-2.\n• R5.SME.11 : Stratégie de développement de marque-1.\n\n### Mise en pratique (SAÉ)\n• SAÉ 5.SME.01 : Projet de communication événementielle.\n\n### Critères d’évaluation\n• Pertinence stratégique : Capacité à démontrer que le concept répond non seulement aux besoins opérationnels mais aussi aux objectifs d'image du commanditaire.\n• Puissance créative : Originalité et cohérence de l'univers proposé par rapport au territoire de marque.\n\nEn résumé : cet AC permet de concevoir des événements d'envergure alignés sur la stratégie de marque.	3	SME	12
50	AC35.02SME	Intégrer les enjeux sécuritaires et reglementaires des événements de grande ampleur	Il s'agit de maîtriser le cadre juridique et sécuritaire spécifique aux rassemblements de grande taille (sécurité des ERP, assurances, protocoles d'urgence).\n\n### Ressources mobilisées\n• R5.SME.14 : Organisation et logistique-2.\n• Ressources juridiques avancées.\n\n### Critères d’évaluation\n• Sûreté du dispositif : Rigueur dans la planification des mesures de sécurité et de secours conformément à la législation en vigueur.\n• Conformité réglementaire : Absence de risques juridiques majeurs dans le montage du dossier de l'événement.\n\nEn résumé : cet AC garantit la sécurité et la conformité légale des grands rassemblements.	3	SME	12
51	AC35.03SME	Rechercher des partenaires et des subventions	L'expertise consiste ici à diversifier les sources de financement pour assurer la viabilité économique du projet complexe.\n\n### Ressources mobilisées\n• R5.SME.13 : Gestion commerciale-2.\n\n### Critères d’évaluation\n• Efficacité de la prospection : Capacité à identifier et convaincre des partenaires dont les valeurs sont alignées avec l'événement.\n• Qualité du mix de financement : Justesse du dosage entre autofinancement, mécénat, sponsoring et subventions publiques.\n\nEn résumé : cet AC permet de sécuriser le financement de projets événementiels complexes.	3	SME	12
52	AC35.04SME	Gérer des prestataires	L'étudiant agit comme un chef d'orchestre capable de coordonner une chaîne complexe de sous-traitants techniques et artistiques.\n\n### Ressources mobilisées\n• R5.SME.14 : Organisation et logistique-2.\n• R6.SME.04 : Événementiel sectoriel.\n\n### Critères d’évaluation\n• Maîtrise de la chaîne logistique : Capacité à négocier les contrats et à contrôler la qualité des livrables de chaque prestataire.\n• Fluidité opérationnelle : Efficience de la coordination sur le terrain pour éviter les goulots d'étranglement ou les ruptures de service.\n\nEn résumé : cet AC forge la capacité à piloter une chaîne de prestataires diversifiés.	3	SME	12
53	AC35.05SME	Manager un évènement complexe	C'est la compétence finale de synthèse : piloter le projet dans sa globalité, gérer l'équipe, les imprévus et mesurer les retombées réelles.\n\n### Mise en pratique (Stage)\n• Stage de fin de BUT (S6) en responsabilité.\n\n### Critères d’évaluation\n• Qualité du leadership : Aptitude à animer l'équipe projet et à prendre des décisions critiques en situation réelle.\n• Vision réflexive et critique : Capacité à produire un bilan post-événement analysant avec recul les résultats (KPIs) et proposant des pistes de régulation.\n\nEn résumé : cet AC valide la capacité à manager intégralement un projet événementiel d'envergure.	3	SME	12
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
236	R4.04	Droit du travail	Contribuer au développement de la ou des compétences ciblées :\n– Comprendre et analyser les relations individuelles du travail\n– Comprendre et analyser les relations collectives du travail\n\nMots clés : Salarié – contrat de travail – négociation collective	– Conclusion du contrat de travail (types de contrats), droits et obligations du salarié et de l’employeur, rupture du contrat\nde travail\n– Négociation collective dans l’entreprise, conventions et accords collectifs, représentants des salariés	0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
7	R1.07	Techniques quantitatives et représentations - 1	Contribution au développement de la ou des compétences ciblées :\n– Se familiariser avec les nombres pour maîtriser le calcul mental, maîtriser l’ordre de grandeur des nombres utilisés\n– Maîtriser la cohérence des résultats obtenus\n– Calculer, comprendre, analyser, interpréter des indicateurs pertinents pour évaluer un marché ou une action commer-\nciale\n– Utiliser les statistiques pour représenter une situation commerciale (évolutions, parts de marché, fréquentation d’un site\nInternet, analyse des statistiques des réseaux sociaux...)\n– Percevoir et anticiper les variations d’un marché et de son environnement\n\nMots clés :\nTaux – pourcentage – indice – statistique descriptive – représentation graphique	– Calcul mental et ordre de grandeur\n– Pourcentages, taux de variation, indices, élasticité\n– Statistique descriptive : généralités, séries à un caractère, paramètres de position, de dispersion, de concentration,\nreprésentation graphique\n– Équations, fonctions afﬁnes\nUtilisation d’un tableur conseillée	18	18 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
8	R1.08	Eléments ﬁnanciers de l’entreprise	Contribution au développement de la ou des compétences ciblées :\n– Vériﬁer la cohérence des décisions marketing avec la situation ﬁnancière de l’entreprise\n\nMots clés :\nRentabilité – trésorerie – patrimoine	– Mécanisme de la comptabilité (documents commerciaux, TVA et IS)\n– Compte de résultat : notion de produits et charges, résultat\n– Contenu d’un bilan : actif, passif, rôle des amortissements et des provisions\n– Tableau de trésorerie\n– Distinction entre notions de bénéﬁce et de trésorerie	12	12 heures	Conduire les actions marketing, Vendre une offre commerciale	Tronc Commun	\N	\N
9	R1.09	Rôle et organisation de l’entreprise sur son marché	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer une entreprise et son marché\n– Comprendre la structure organisationnelle d’une entreprise\n– Comprendre la ﬁnalité sociale, sociétale d’une entreprise\n– Comprendre les interactions entre une entreprise et son environnement macroéconomique\n– Identiﬁer les concurrents et comprendre le positionnement d’une entreprise par rapport à ses concurrents\n– Introduction au diagnostic stratégique\n\nMots clés :\nOrganigramme – concurrents – SWOT – PESTEL	– Organigramme et rôle du manager (structure simple, fonctionnelle, divisionnelle, matricielle, par projet)\n– PESTEL\n– Concurrence directe et indirecte, avantage concurrentiel\n– SWOT	12	12 heures	Conduire les actions marketing	Tronc Commun	\N	\N
10	R1.10	Initiation à la conduite de projet	Contribution au développement de la ou des compétences ciblées :\n– Analyser le cahier des charges d’un commanditaire pour comprendre le projet, son environnement et ses objectifs\n– Mettre en place un plan d’actions à partir d’une problématique identiﬁée et d’un cahier des charges construit, organiser\nun travail en groupe\n\nMots clés :\nProjet – organisation – cadrage – outil de conduite de projet – tâche – planiﬁcation	– Déﬁnition des étapes de la conduite de projet : phase de cadrage ou avant-projet avec toutes les analyses préliminaires\n(déﬁnition de la note de cadrage)\n– Déﬁnition de la conception et de la planiﬁcation : constitution de l’équipe, organisation du travail en groupe, répartition\ndes tâches et planiﬁcation\n– Présentation des différents outils de la gestion de projet : carte mentale, priorisation des tâches, matrice des responsa-\nbilités, diagramme de planiﬁcation, outils de travail collaboratif, organisation de réunions	8	8 heures dont 4 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
11	R1.11	Langue A Anglais du commerce - 1	Contribution au développement de la ou des compétences ciblées :\nDévelopper les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n\nMots clés :\nLangue de spécialité – présentation – prospection – communication et marketing en anglais	– Présentation d’une entreprise (points faibles et points forts), présentation de soi\n– Recherche d’informations sur internet, de documentations sur une entreprise ou un produit et présentation à l’oral et à\nl’écrit\n– Traduction d’un questionnaire/une enquête/une interview simple en anglais\n– Prospection au téléphone et prise des RDV\n– Rédaction et utilisation de questions pour connaître les besoins du client\n– Description d’un support de communication commerciale (publicité) dans sa dimension culturelle, présentation d’un brief\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire basique général de l’entreprise, de la communication commerciale et du marketing et le restituer\ndans une situation professionnelle spéciﬁque\n– Mobiliser les connecteurs logiques pour l’argumentation	20	20 heures dont 12 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
17	R2.02	Prospection et négociation	Contribution au développement de la ou des compétences ciblées :\n– Connaître la prospection digitale\n– Préparer et mener les étapes d’argumentation, de traitement des objections client, de conclusion et de prise de congé\n– Réaliser des OAV pertinents et efﬁcaces\n\nMots clés :\nProspection – argumentaire de vente – objection – OAV	Contenu :\nAu travers de jeux de rôle portant sur les étapes 3 et 4 de l’entretien de vente, aborder :\nLa prospection commerciale digitale :\n– E-mailing, SMS, réseaux sociaux, etc.\n– Indicateurs de performance / les indicateurs de rentabilité\n– Outils de CRM\nLa maîtrise de son offre\n– Conception ou construction d’un argumentaire de vente CAP complet (produits, services payants, services gratuits,\nmarque...)\n– Traduction de l’offre produit en bénéﬁces client\n– Anticipation et traitement des objections\n– Conclusion et prise de congé (sans négociation du prix)\nL’exploitation et la construction des Outils d’Aide à la Vente (OAV)\n– Outils de présentation\n– Outils de preuve\n– Outils de contractualisation\n– Outils de démonstration (échantillon, exemplaire du produit...)	23	23 heures dont 12 heures de TP	Vendre une offre commerciale	Tronc Commun	\N	\N
12	R1.12	Langue B du commerce - 1	Contribution au développement de la ou des compétences ciblées :\nDévelopper les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n\nMots clés :\nLangue de spécialité – présentation – prospection – communication et marketing	– Présentation d’une entreprise (points faibles et points forts), présentation de soi\n– Recherche d’informations sur internet, de documentations sur une entreprise ou un produit et présentation à l’oral et à\nl’écrit\n– Traduction d’un questionnaire/une enquête/une interview simple en langue étrangère\n– Prospection au téléphone et prise des RDV\n– Rédaction et utilisation de questions pour connaitre les besoins du client\n– Description d’un support de communication commerciale (publicité) dans sa dimension culturelle, présentation d’un brief\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire basique général de l’entreprise, de la communication commerciale et marketing, et le restituer\ndans une situation professionnelle spéciﬁque\n– Mobiliser les connecteurs logiques pour l’argumentation	20	20 heures dont 12 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
13	R1.13	Ressources et culture numériques - 1	Contribution au développement de la ou des compétences ciblées :\n– Rechercher de l’information et la sélectionner\n– Utiliser les outils numériques pour présenter un projet\n– Concevoir des outils adaptés à la démarche de prospection\n– Utiliser l’outil numérique pour produire des supports de communication simples\n– Collaborer pour conduire un projet\n\nMots clés :\nE.N.T – outils de recherche d’information – traitement de texte – PréAO – tableur	– Prise en main de l’E.N.T. : Mail Netiquette, objets connectés, réunions en distanciel, échange de ﬁchiers\n– Organisation et recherche d’information (ordinateur, support de stockage, réseau interne, sécurité/protection)\n– Outils de recherche sur Internet\n– Traitement de texte : utilisation d’un logiciel de traitement de texte (saisie/import de texte, mise en page, mise en forme,\ninsertion d’objets, export, structuration, gestion de documents longs)\n– Création et exploitation de présentations professionnelles (import/export, transitions, animations, insertions d’objets) à\nl’aide d’un logiciel de PréAO\n– Création et exploitation d’images pour l’intégration dans un support commercial à l’aide de logiciels de retouche d’image\n(type bitmap) : import, export, redimensionnement, format, transparence, effets simples\n– Utilisation d’un tableur simple et des fonctions de base d’un tableur : création de tableaux, calculs de base, création de\ngraphiques simples\n– Import/export, insertions d’objets, mise en page, mise en forme à l’aide des fonctions avancées d’un traitement de texte,\nd’un logiciel de PAO, PréAO	20	20 heures dont 14 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
14	R1.14	Expression, communication et culture 1	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRecherche documentaire – norme de présentation – culture – esprit critique – communication verbale et non verbale – rédaction	S’informer et informer de manière critique et efﬁcace (niveau 1) :\n– Initiation à la recherche documentaire (ex : recourir à l’environnement numérique de travail, aux bases de données, aux\nnormes bibliographiques).\n– Etude de la ﬁabilité et de la pertinence des informations (fake news, plagiat, etc.) et des sources choisies (médias grand\npublic et spécialisés, internet, etc.)\n– Développement de l’esprit critique et la culture générale en privilégiant les sujets d’actualité socio-économique, géopoli-\ntique et culturelle\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 1) :\n– Développement des savoirs et savoir-faire en sémiologie aﬁn de communiquer par l’image (à titre indicatif : ﬂyer, afﬁche,\nsupport d’exposé, etc) et au moyen d’outils de présentation (logiciels de carte heuristique, de diaporama, d’infographie,\netc.)\n– Analyse et compréhension des écritures professionnelles : les textes de la presse généraliste et/ou spécialisée\n– Élaboration de documents et écrits professionnels qui répondent aux différentes situations de communication (à titre\nindicatif : revue de presse, dossier, plaquette de présentation, rapport simple, note, courrier, courriel, etc.)\n– Compréhension et respect des normes de présentation écrites : typographie, orthographe/syntaxe\nCommuniquer, persuader, interagir :\n– Analyse de la communication (niveau 1) : comprendre les enjeux de la communication verbale, non verbale et para-\nverbale en situation (recours possible à un ou des modèles théoriques explicatifs jugés pertinents) pour analyser ses\nmanières de communiquer et les améliorer (fonctions du langage, pragmatique, anthropologie de la - communication,\netc.); accent mis sur l’identiﬁcation et la maitrise des normes sociales, culturelles, professionnelles et des registres de\nlangue)\n– Ecoute active, prise de notes, reformulation, compte-rendu oral, exposé, etc.	20	20 heures dont 10 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
15	R1.15	Projet personnel professionnel - 1	Contribution au développement de la ou des compétences ciblées :\nLe Projet Personnel et Professionnel permet à l’étudiant\n– d’avoir une compréhension exhaustive du référentiel de compétences de la formation et des éléments le structurant\n– de faire le lien entre les niveaux de compétences ciblés, les SAÉ et les ressources au programme de chaque semestre\n– de découvrir les métiers associés à la spécialité et les environnements professionnels correspondants\n– de se positionner sur un des parcours de la spécialité lorsque ces parcours sont proposés en seconde année\n– de mobiliser les techniques de recrutement dans le cadre d’une recherche de stage ou d’un contrat d’alternance\n– d’engager une réﬂexion sur la connaissance de soi\n\nMots clés :\nMétier – parcours – référentiel de compétences – identité professionnelle – stage – alternance	S’approprier la démarche PPP : connaissance de soi (intérêt, curiosité, aspirations, motivations), accompagnement des étu-\ndiants dans la déﬁnition d’une stratégie personnelle permettant la réalisation du projet professionnel\n– Développer une démarche réﬂexive et introspective (de manière à découvrir ses valeurs, qualités, motivations, savoirs,\nsavoir-être, savoirs-faire) au travers, par exemple de son expérience et ses centres d’intérêt\n– Placer l’étudiant dans une démarche prospective en termes d’avenir, souhait, motivation vis-à-vis d’un projet d’études\net/ou professionnel\n– S’initier à la démarche réﬂexive (savoir interroger et analyser son expérience)\nS’approprier la formation\n– S’approprier les compétences de la formation – identiﬁer les blocs de compétences\n– Référencer les compétences et les associer avec la réalité du terrain\n– Découvrir, analyser les parcours B.U.T. de la spécialité\n– Accompagner le choix des parcours (type 1 / type 2)\nDécouvrir les métiers et connaître le territoire\n– Faire le lien avec les métiers (ﬁches ROME – Association article 1, etc.)\n– Se familiariser avec les débouchés en fonction du territoire, les bassins d’entreprise, les réseaux d’entreprise, etc.\n– Identiﬁer les métiers en lien avec la formation, en analyser les principales caractéristiques\nSe projeter dans un environnement professionnel\n– Appréhender les codes, les usages et les cultures d’entreprise\n– Intégrer des codes sociaux au niveau France et Europe pour s’ouvrir à la diversité culturelle et s’ouvrir sur la mondiali-\nsation socio-économique\n– Construire son réseau professionnel : découvrir les réseaux et sensibiliser à l’identité numérique\n– Préparer son stage et/ou son alternance et/ou son parcours à l’international	14	14 heures dont 6 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
16	R2.01	Marketing mix - 1	Contribution au développement de la ou des compétences ciblées :\n– Apprécier les enjeux et les facteurs liés aux variables du marketing mix\n– Prendre les décisions marketing concernant la politique produit d’une offre simple\n– Prendre les décisions marketing concernant la politique prix d’une offre simple\n– Donner une cohérence globale au marketing mix en fonction du positionnement préalablement identiﬁé\n\nMots clés :\nMarketing mix – gamme – marque – packaging – prix – distribution – communication	Contenu :\n– Conception d’une politique de produit : cycle de vie, évolution saisonnière et temporaire, gamme et évolution des\ngammes, marque, packaging\n– Conception d’une politique de prix : objectifs, contraintes, méthodes de ﬁxation\n– Préconisation d’une politique de communication et d’une politique de distribution\n– Mise en cohérence de la stratégie marketing (cible et positionnement choisis) avec les variables du mix (produit, prix,\ncommunication, distribution)	18	18 heures	Conduire les actions marketing	Tronc Commun	\N	\N
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
169	R6.MDEE.03	Traﬁc management - analyse d’audience	Contribution au développement de la ou des compétences ciblées :\n– Savoir analyser l’audience d’un site complexe\n– Evaluer la performance d’actions de marketing digital (A/B Testing)\n– Concevoir et gérer des tunnels de conversion\n\nMots clés : Traﬁc management – data – analyse d’audience	– Utilisation des outils d’analyse d’audience d’un site web ou d’applications ainsi que des sources d’acquisition pour\névaluer l’audience d’un site\n– Utilisation des indicateurs statistiques, géographiques et démographiques, etc. pour évaluer les résultats d’actions de\nmarketing digital	0		Gérer une activité digitale	MDEE	\N	\N
242	R4.BDMRC.10	Relation client omnicanal	Contribution au développement de la ou des compétences ciblées :\n– Apprécier les enjeux et les limites des différentes interactions avec les clients via les points de contacts online et ofﬂine\n– Apprécier les effets de la digitalisation dans la relation client\n– Maîtriser la relation omnicanal en manageant l’expérience client tout au long du parcours\n– Animer la relation client\n\nMots clés : Points contacts – digitalisation – animation ofﬂine et online – réseaux sociaux	– Relation client online et ofﬂine\n– Salons, opérations commerciales, évènements commerciaux\n– Animation d’une communauté de clients, webinaires\n– Réseaux sociaux	0		Manager la relation client	BDMRC	\N	\N
30	R2.15	Projet personnel professionnel - 2	Contribution au développement de la ou les compétences ciblées : le Projet Personnel et Professionnel permet à l’étudiant\n– d’avoir une compréhension exhaustive du référentiel de compétences de la formation et des éléments le structurant\n– de faire le lien entre les niveaux de compétences ciblés, les SAÉ et les ressources au programme de chaque semestre\n– de découvrir les métiers associés à la spécialité et les environnements professionnels correspondants\n– de se positionner sur un des parcours de la spécialité lorsque ces parcours sont proposés en seconde année\n– de mobiliser les techniques de recrutement dans le cadre d’une recherche de stage ou d’un contrat d’alternance\n– d’engager une réﬂexion sur la connaissance de soi\n\nMots clés :\nMétier – parcours – référentiel de compétences – identité professionnelle – stage – alternance	Contenu :\nS’approprier la démarche PPP : connaissance de soi (intérêt, curiosité, aspirations, motivations), accompagnement des étu-\ndiants dans la déﬁnition d’une stratégie personnelle permettant la réalisation du projet professionnel\n– Développer une démarche réﬂexive et introspective (de manière à découvrir ses valeurs, qualités, motivations, savoirs,\nsavoir-être, savoirs-faire) au travers, par exemple de son expérience et ses centres d’intérêt\n– Placer l’étudiant dans une démarche prospective en termes d’avenir, souhait, motivation vis-à-vis d’un projet d’études\net/ou professionnel\n– S’initier à la démarche réﬂexive (savoir interroger et analyser son expérience)\nS’approprier la formation\n– S’approprier les compétences de la formation – identiﬁer les blocs de compétences\n– Référencer les compétences et les associer avec la réalité du terrain\n– Découvrir, analyser les parcours B.U.T. de la spécialité\n– Accompagner le choix des parcours (type 1 / type 2)\nDécouvrir les métiers et connaître le territoire\n– Faire le lien avec les métiers (ﬁches ROME – Association article 1, etc.)\n– Se familiariser avec les débouchés en fonction du territoire, les bassins d’entreprise, les réseaux d’entreprise, etc.\n– Identiﬁer les métiers en lien avec la formation, en analyser les principales caractéristiques\nSe projeter dans un environnement professionnel\n– Appréhender les codes, les usages et les cultures d’entreprise\n– Intégrer des codes sociaux au niveau France et Europe pour s’ouvrir à la diversité culturelle et s’ouvrir sur la mondiali-\nsation socio-économique\n– Construire son réseau professionnel : découvrir les réseaux et sensibiliser à l’identité numérique\n– Préparer son stage et/ou son alternance et/ou son parcours à l’international	10	10 heures dont 5 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	Tronc Commun	\N	\N
31	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	SME	\N	\N
32	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	SME	\N	\N
33	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	SME	\N	\N
34	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	SME	\N	\N
35	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Conduire les actions marketing	SME	\N	\N
36	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
37	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Elaborer l’identité d’une marque, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
38	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
39	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Conduire les actions marketing	SME	\N	\N
40	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
41	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
42	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
43	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
44	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
45	R3.SME.15	Marketing de l’évènementiel - 1	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une démarche de projet événementiel\n– Valoriser l’événement avant, pendant, après\n– Mesurer son efﬁcacité\n\nMots clés :\nPanorama événementiel – création d’événements – événements hybrides – événements éco-conçus – communication événe-\nmentielle – impact	– Panorama des différents types d’événements simples en fonction des cibles et objectifs\n– Conception d’un événement adapté à la demande : du brief à la proposition\n– Gestion hybride de l’événementiel : adapter les événements à la nouvelle problématique du distanciel\n– Outils d’éco-conception d’événements\n– Communication avant, pendant, après\n– Communication : apprentissage de logiciels d’infographie\n– Mesure de l’impact : nombre d’inscrits ou participants, mesure de la satisfaction	13	13 heures dont 4 heures de TP	Manager un projet événementiel	SME	\N	\N
46	R3.SME.16	Fondamentaux de la communication de marque	Contribution au développement de la ou des compétences ciblées :\n– Comprendre les enjeux de la création d’une marque\n– Appréhender la notion d’identité de marque\n– Créer du contenu de marque simple\n\nMots clés :\nValeurs – identité de marque – territoires de marque – gestion de contenu	– Leviers de création de marque : liens marketing et communication (mix, positionnement, etc.)\n– Narration de marque (storytelling, construction de l’identité : fonctions, codes, valeurs de marque, etc.)\n– Mesure de la visibilité\n– En lien avec le droit : Propriété industrielle, RSE	13	13 heures dont 4 heures de TP	Elaborer l’identité d’une marque	SME	\N	\N
58	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	SME	\N	\N
59	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	SME	\N	\N
60	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing	SME	\N	\N
61	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
62	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
63	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
80	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	MMPV	\N	\N
76	R6.SME.03	Stratégie de développement de marque - 2	Contribution au développement de la ou des compétences ciblées :\n– Accompagner les évolutions de la marque\n\nMots clés : Stratégie de marque – engagement – communauté	– Gestion de la notoriété et de l’image de marque\n– Mise en place d’outils de ﬁdélisation et d’engagement envers la marque\n– Elaboration de stratégies de développement et de changement de marque\n– Enjeux et création de marque locale, marque internationale, co-branding et communauté de marque	0		Elaborer l’identité d’une marque	SME	\N	\N
83	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
64	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
65	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
66	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
67	R5.SME.10	Ressources et culture numériques appliquées à la stratégie de marque et à l’évène-	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher, recueillir et structurer les données prospects et clients aﬁn d’exploiter efﬁcacement un CRM, et le\nfaire évoluer\n– Bâtir une campagne de relation client : déterminer les objectifs, cibler les prospects, s’approprier les outils, évaluer son\nefﬁcacité\n– Concevoir, mettre en œuvre et présenter des tableaux de bord efﬁcaces et pertinents\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité et à la conﬁdentialité du système d’informations\n\nMots clés :\nERP – tableaux de bord – billeterie	– Prise en main d’un ERP et d’un CRM\n– Techniques de construction et d’alimentation d’une base de données, scoring\n– Tableurs fonctions avancées : simulations, tableaux de bord\n– Outils de présentation et communication des tableaux de bord\n– Billetterie : utilisation d’outils adaptés aux évènements complexes avec paiement en ligne	13	13 heures dont 6 heures de TP	Elaborer l’identité d’une marque, Manager un projet événementiel	SME	\N	\N
68	R5.SME.11	Stratégie de développement de marque - 1	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de marque\n– Gérer et animer la marque et le portefeuille de marque de l’entreprise\n\nMots clés :\nIdentité de marque – territoire de la marque – capital marque – développement de la marque – droit de la marque	– Identité et valeur de la marque\n– Construction et mesure du capital marque\n– Création de contenu et animation de la marque\n– Fonctions de la marque pour le consommateur et pour l’entreprise\n– Aspects juridiques de la marque	15	15 heures	Elaborer l’identité d’une marque	SME	\N	\N
81	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	MMPV	\N	\N
82	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Conduire les actions marketing	MMPV	\N	\N
69	R5.SME.12	Marketing digital de la marque	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication digitale\n– Gérer les communautés de marque\n– Mesurer la performance des actions et l’e-réputation\n\nMots clés :\nContenu web – ligne éditoriale – community management – e-réputation – inﬂuenceur web – audience digitale	– Création de contenu (textuel, visuel, audio) : développement de contenu en adéquation avec la stratégie éditoriale de\nchacun des supports digitaux tant dans le contenu que dans la forme, respect des spéciﬁcités de rédaction de contenu\nweb, élaboration des supports audio et audiovisuels de qualité\n– Management des communautés de marque : inﬂuenceurs, ambassadeurs. Gestion des collaborations avec les différents\ntypes d’acteurs de la communauté, dans le respect de la stratégie de marque, création des ﬁchiers d’inﬂuenceurs/\nambassadeurs potentiels, déﬁnition des critères de choix, connaissance des plateformes d’inﬂuence marketing et de\nleur fonctionnement, interactions avec la communauté\n– Gestion de la viralité : réactions face aux rumeurs, à la désinformation et aux fake news, gestion de la « guerre digitale »\n– E-réputation, veille : mise en place d’une veille sur l’e-réputation de la marque aﬁn de pouvoir interagir pertinemment\navec la communauté et gestion de l’e-réputation de la marque au niveau stratégique\n– Indicateurs clés de performance et mesure d’audience digitale : déﬁnition des indicateurs clés en fonction des différents\nsupports, réalisation de tableaux de bord de suivi, diffusion de l’information\nApprentissage critique ciblé :\n– AC34.04SME | Développer la communauté de marque et l’adhésion (community management, veille image de marque\net e-réputation)	15	15 heures dont 6 heures de TP	Elaborer l’identité d’une marque	SME	\N	\N
70	R5.SME.13	Gestion commerciale - 2	Contribution au développement de la ou des compétences ciblées :\n– Gérer les relations commerciales avec les fournisseurs et partenaires d’un évènement de grande ampleur\n– Elaborer une démarche de recherche de subventions\n– Optimiser les retombées commerciales d’un évènement\n\nMots clés :\nAchat – prestataire – subvention	– Relations, négociation avec les prestataires\n– Recherche de sponsors auprès de partenaires privés\n– Recherche de subventions auprès de partenaires publics et institutionnels : connaissance des collectivités susceptibles\nde soutenir le projet, dossier de partenariat, suivi des démarches administratives\n– Achat, produits dérivés : choix de produits adaptés, élaboration d’une politique commerciale (quantités, prix, modalités\nde vente)	12	12 heures	Manager un projet événementiel	SME	\N	\N
71	R5.SME.14	Organisation et logistique - 2	Contribution au développement de la ou des compétences ciblées :\n– Appréhender toutes les étapes de la logistique évènementielle d’un évènement de grande ampleur\n– Connaître le cadre juridique d’un évènement de grande ampleur\n– Maitrîser les techniques d’animation et d’évaluation d’une équipe\n\nMots clés :\nGestion des risques – droit de l’évènement – management d’équipe – gestion budgétaire	– Gestion de projet : planiﬁcation, gestion des risques, retour d’expérience\n– Gestion budgétaire : budget prévisionnel et réalisé, analyse d’écart, rédiger un dossier de subvention\n– Droit de l’évènement : autorisations, licences, assurances, sécurité, débit de boisson / évènement et RSE\n– Management d’équipe : connaissance des différents styles de management, techniques d’animation d’une équipe, mo-\ndalités d’évaluation individuelle et collective	15	15 heures dont 4 heures de TP	Manager un projet événementiel	SME	\N	\N
72	R5.SME.15	Conception graphique	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser des logiciels de conception graphique professionnels\n\nMots clés :\nCréation graphique – dessin vectoriel – retouche image – mise en page	-Traitement de l’image complexe\n– Conception et mise en page d’outils de communication complexes\n– Création graphique de l’identité de marque	20	20 heures dont 16 heures de TP	Elaborer l’identité d’une marque	SME	\N	\N
73	R5.SME.16	Marketing de l’évènementiel - 2	Contribution au développement de la ou les compétences ciblées :\n– Connaître les enjeux d’un évènement de grande ampleur\n– Elaborer un évènement de grande ampleur adapté au brief\n– Mesurer les retombées de l’évènement\n\nMots clés :\nEvènement grand format – retombée – mesure de la satisfaction	– Panorama des différents types d’évènements complexes : événements grand public, congrès, conventions, foires et\nsalons, festivals\n– Spéciﬁcités de la création et promotion d’un évènement grand public de grande ampleur\n– Mesure des retombées, de la fréquentation et de la satisfaction\nApprentissage critique ciblé :\n– AC35.01SME | Créer un événement complexe adapté aux attentes du commanditaire	15	15 heures	Manager un projet événementiel	SME	\N	\N
78	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	MMPV	\N	\N
79	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	MMPV	\N	\N
84	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
85	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
86	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing	MMPV	\N	\N
87	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
93	R3.MMPV.16	Marketing du point de vente	Contribution au développement de la ou les compétences ciblées :\n– Comprendre les évolutions et les stratégies de développement des différents acteurs de la distribution\n– Comprendre un concept d’enseigne et maîtriser ses leviers opérationnels\n– Analyser le comportement du consommateur face au point de vente\n– Mettre en oeuvre la stratégie d’une enseigne : point de vente physique et/ou virtuel\n– Savoir déterminer le potentiel commercial d’une zone de chalandise (géomarketing).\n\nMots clés :\nEnseignes – parcours – géomarketing	– Stratégies et marketing mix du fabricant\n– Stratégies et marketing du distributeur : enseigne, positionnement, structuration de l’offre, communication nationale /\nrégionale\n– Facteurs d’ambiance en magasin : marketing sensoriel, théâtralisation\n– Rôle et enjeux des marques et de la MDD (tant pour le producteur que pour le distributeur)\n– Choix du point de vente par le consommateur, son comportement en magasin, digitalisation de la relation client\n– Principes, dimensions, mise en oeuvre du géomarketing	13	13 heures dont 4 heures de TP	Piloter un espace de vente	MMPV	\N	\N
139	R3.MDEE.16	Créativité et innovation	Contribution au développement de la ou des compétences ciblées :\n– Découvrir des méthodes de créativité : carte conceptuelle simple, méthodes de questionnement...\n– Participer à une séance de créativité\n– Identiﬁer l’originalité et la faisabilité d’une idée\n– Être capable de déﬁnir une innovation\n– Vériﬁer l’adéquation de l’idée avec un besoin utilisateur/client\nContenus :\n– Méthodes et outils de la créativité\n– Design thinking\n\nMots clés :\nCréativité – Innovation		13	13 heures dont 4 heures de TP	Développer un projet e-business	MDEE	\N	\N
88	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
89	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
90	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
91	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
92	R3.MMPV.15	Management de la performance du point de vente	Contribution au développement de la ou les compétences ciblées :\n– Comprendre le fonctionnement d’un point de vente et ses indicateurs de performance commerciale\n– Communiquer sur les objectifs et les résultats professionnellement\n\nMots clés :\nAnalyse du CA – marge – objectifs – résultats	– Analyse du CA, répartition des ventes en volume et en valeur, marges...\n– Analyse des indicateurs du point de vente en fonction de sa localisation, de son format, des caractéristiques de sa\nzone de chalandise (données démographiques, économiques, etc.), de son environnement concurrentiel, des éléments\ndéclencheurs de traﬁc situés à proximité...\n– Suivi de l’activité de l’équipe de vente, mise en place d’objectifs et communication sur les résultats	13	13 heures dont 4 heures de TP	Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
105	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	MMPV	\N	\N
106	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	MMPV	\N	\N
107	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing	MMPV	\N	\N
108	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
109	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
110	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
117	R5.MMPV.13	Supply chain	Contribution au développement de la ou des compétences ciblées :\n– S’approprier la chaine d’approvisionnement de l’espace de vente\n– Coordonner et contrôler les opérations logistiques de réception, expédition et livraison\n– Optimiser les approvisionnements (suivi d’une commande, disponibilité des produits, délai de livraison...)\n– Organiser la répartition des emplacements de stockage sur le site et en suivre la gestion\n– Maîtriser les notions clés de la qualité pour les intégrer au processus d’approvisionnement\n\nMots clés :\nApprovisionnement – gestion des stocks – qualité	– Enjeux de la logistique : origine, organisation des différents acteurs, source d’avantages concurrentiels, nouvelles tech-\nnologies\n– Gestion de stock : suivi de l’état des stocks, identiﬁcation des besoins en approvisionnement et suivi des commandes\n(disponibilités, délais de livraison, ect.)\n– Contrôle de l’état et de la conservation des produits périssables et coordination du retrait des produits impropres à la\nvente\n– Gestion des ﬂux : tendus, poussés, tirés, transit, allotis, cross-docking\n– Acteurs de la qualité, certiﬁcation, qualité ﬁlières et produits	15	15 heures	Piloter un espace de vente	MMPV	\N	\N
111	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
112	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
113	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
114	R5.MMPV.10	Ressources et culture numériques appliquées au marketing et management du point	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher et structurer les données et informations importantes\n– Concevoir et mettre en œuvre des tableaux de bord efﬁcaces et pertinents (KPI)\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité du système d’informations\n– Acquérir une culture numérique\n\nMots clés :\nERP – KPI – tableur fonctions avancées – simulation	– Prise en main d’un ERP\n– Tableurs fonctions avancées : simulations, tableaux de bord\n– Introduction au Big Data, au Data Mining	13	13 heures dont 6 heures de TP	Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente	MMPV	\N	\N
115	R5.MMPV.11	Parcours expérience client	Contribution au développement de la ou des compétences ciblées :\n– Elaborer une stratégie commerciale en cohérence avec l’environnement concurrentiel\n– Analyser et optimiser le parcours client dans une perspective omnicanal par l’intégration des différents points de contact :\nphygitalisation du point de vente\n– Construire une expérience client\n– Développer un portefeuille de clients/prospects et effectuer le suivi de la clientèle (opérations de ﬁdélisation, enquêtes\nde satisfaction, relances ...)\n\nMots clés :\nGRC – expérience client – omnicanal – portefeuille client	– Mise en place d’une expérience d’achat globale et transparente pour créer une relation durable avec les clients\n– Analyse des besoins du client omni-consommateur pour uniformiser l’ensemble des points de contact, ﬂuidiﬁer le par-\ncours client, améliorer l’expérience client et générer plus de traﬁc\n– Anticipation des nouvelles tendances de consommation et des nouvelles technologies aﬁn d’adapter le point de vente\nou le rayon	26	26 heures dont 10 heures de TP	Piloter un espace de vente	MMPV	\N	\N
116	R5.MMPV.12	Management d’équipe - 2	Contribution au développement de la ou des compétences ciblées :\n– S’approprier un style de management\n– Fédérer les équipes autour de l’atteinte des objectifs (méthode SMART)\n– Sélectionner des collaborateurs en considérant les besoins de l’équipe et les intégrer\n– Suivre et organiser le développement des compétences du personnel (formation continue, entretien annuel...).\n– Valoriser les compétences des membres de l’équipe\n– Accompagner l’équipe pour gérer le changement et les conﬂits\n\nMots clés :\nManagement – conﬂit – compétence	– Différents types de management (pouvoir, leadership, management responsable, autonomie et délégation) et adaptation\naux équipes en place\n– Motivations au travail / management de la différenciation\n– Gestion des conﬂits et du changement	15	15 heures dont 8 heures de TP	Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
118	R5.MMPV.14	Droit de la distribution	Contribution au développement de la ou des compétences ciblées :\n– Connaître les obligations et les responsabilités des enseignes en matière d’information produit\n– Connaître les obligations et les responsabilités des enseignes par rapport à la sécurité du client dans le point de vente\n– Agir dans le cadre de la règlementation commerciale : droit de la concurrence\nContenus :\n– Législation applicable sur les parkings en matière de circulation automobile, circulation piétons, gestion des chariots\n– Notion de produits dangereux et responsabilité du distributeur\n– Etiquetage, afﬁchage et présentation des produits, publicité comparative, promotion, solde, liquidation, prix d’appel\n– Transparence tarifaire en tant que moyen de prévention et de contrôle des pratiques restrictives de la concurrence\nPrérequis :\n– R5.04 | Droit des activités commerciales - 2\n\nMots clés :\nRèglementation commerciale – soldes – information produit – droit de la concurrence		18	18 heures	Piloter un espace de vente	MMPV	\N	\N
119	R5.MMPV.15	Trade marketing	Contribution au développement de la ou des compétences ciblées :\n– Sélectionner des fournisseurs\n– Optimiser la relation entre le producteur et le fournisseur\n\nMots clés :\nCategory management – sourcing – PCC – CPFR – ECR	– Utilisation des critères du sourcing pour choisir les fournisseurs\n– Pilotage collaboratif des approvisionnements : plan commercial commun (PCC) et gestion collaborative de planiﬁcation\net de la prévision (CPFR)\n– Prévisions des opérations commerciales communes : opérations promotionnelles conjointes, co-branding\n– Utilisation du category management pour optimiser les ventes\n– Mise en place de partenariats entre fournisseurs et distributeurs (Efﬁcient Consumer Response : ECR)	18	18 heures dont 8 heures de TP	Piloter un espace de vente	MMPV	\N	\N
124	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	MDEE	\N	\N
125	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	MDEE	\N	\N
126	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	MDEE	\N	\N
127	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	MDEE	\N	\N
128	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing	MDEE	\N	\N
183	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
129	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Gérer une activité digitale, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
130	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
131	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
132	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Conduire les actions marketing	MDEE	\N	\N
133	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
150	R4.MDEE.11	Business model - 1	Analyser le business model d’un projet simple, faire son diagnostic, être capable de faire des recommandations pour le faire évoluer. Identifier les éléments innovants du projet. Analyser les effets du business model sur son écosystème. Présenter le business model de manière convaincante.\n\nMots clés : Business model – innovation – entrepreneuriat	Les composantes d’un business model simple. Différences entre business model et business plan. Outils d’analyse stratégique adaptés à l’entrepreneuriat. Techniques et outils de présentation orale ou écrite.	0		Développer un projet e-business	MDEE	\N	\N
202	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Formuler une stratégie de commerce à l’international, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
134	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
135	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
136	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
137	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
138	R3.MDEE.15	Stratégie de marketing digital	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer les spéciﬁcités du marketing digital et cerner les enjeux\n– Adopter une posture adaptée au marketing digital\n– Connaitre et mobiliser des techniques simples en environnement digital\nContenus :\n– Fondamentaux du web, éléments de diagnostic d’un site\n– Acteurs de l’économie numérique\n– Recontextualisation et enjeux de la transformation numérique\n– Mécanismes de création de la valeur en ligne\n– Système d’information et veille digitale\n– Stratégie de visibilité d’une marque digitale\n– Techniques digitales de base de création de traﬁc, de conversion et de ﬁdélisation\n– Indicateurs clés simples (Kpi)\n\nMots clés :\nStratégie digitale – veille digitale – indicateur – audit – e-commerce		13	13 heures dont 4 heures de TP	Gérer une activité digitale	MDEE	\N	\N
151	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	MDEE	\N	\N
152	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	MDEE	\N	\N
153	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Développer un projet e-business, Conduire les actions marketing	MDEE	\N	\N
154	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
155	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
156	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
163	R5.MDEE.13	Stratégie social media et e-CRM	Contribution au développement de la ou des compétences ciblées :\n– Utiliser les leviers opérationnels du marketing et de la communication digitale\n– Convertir les visiteurs en clients grâce au e-CRM\n– Concevoir et suivre les résultats d’une campagne de communication sur les réseaux sociaux\n\nMots clés :\nStratégie de contenu – communication sur les réseaux sociaux et recrutement	– Gestion des réseaux sociaux\n– Stratégie de communication digitale\n– E-CRM et fonctionnement de Social Ads\n– Technique d’élaboration d’une campagne d’e-mailing ou MD (SMS...) : recrutement de prospects, qualiﬁcation de ﬁchiers,\nconstruction de la campagne\n– Utilisation d’outils de routage professionnel, mesure du ROI (retour sur investissement)\n– Mettre en place des outils d’animation (jeu concours, etc.)	15	15 heures dont 6 heures de TP	Gérer une activité digitale	MDEE	\N	\N
164	R5.MDEE.14	Business model - 2	Contribution au développement de la ou des compétences ciblées :\n– Concevoir le business model d’un projet dans toutes ses dimensions\n– Appréhender l’approche systémique et tenir compte des effets positifs et/ou négatifs sur ses environnements\n– Défendre le business model face aux investisseurs/parties prenantes\n\nMots clés :\nAnalyse de la valeur – positive business	– Responsabilité, ﬁscalité et protection du dirigeant\n– Gestion ﬁnancière adaptée à l’entrepreneuriat\n– Contenus d’un business model complet\n– Valeur délivrée\n– Création et partage de la valeur\n– RSE et "positive business"	16	16 heures	Développer un projet e-business	MDEE	\N	\N
157	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
158	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Gérer une activité digitale, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
159	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
160	R5.MDEE.10	Ressources et culture numériques appliquées au marketing digital, à l’e-business et	Contribution au développement de la ou des compétences ciblées :\n– Animer et mettre à jour un site internet professionnel\n– Créer un site internet professionnel et le mettre en ligne\n– Analyser un système d’information et contribuer à la création d’une base de données relationnelle\n– Interroger une base de données\n\nMots clés :\nSite internet – e-boutique – HTML5 – CSS – base de données – requête – CMS	– Internet : approfondissement HTML et CSS, (PHP, javascript)\n– FTP\n– SGBD : bases d’un SI, modèle relationnel, requêtes (bases SQL), logiciel de BD\n– Installation d’un CMS et utilisation professionnelle\n– Production d’un site internet (prolongement ou développement du site simple élaboré au niveau 2)	13	13 heures dont 6 heures de TP	Gérer une activité digitale, Développer un projet e-business	MDEE	\N	\N
161	R5.MDEE.11	Management de la créativité et de l’innovation	Contribution au développement de la ou des compétences ciblées :\n– Transformer l’idée en une offre innovante\n– Mobiliser le marketing pour innover\n– Mobiliser la propriété intellectuelle/industrielle\n– Mettre en œuvre un management responsable, voire positif de l’innovation\n\nMots clés :\nCréativité – innovation – artefact – retour utilisateur – persona	– Marketing dédié à l’innovation : création d’idées nouvelles en utilisant des techniques de créativité, sélection d’une idée,\nformalisation et présentation\n– Retours de l’expérience client et utilisateur : élaboration et analyse des retours utilisateurs et proposition d’améliorations\nen termes de valeur délivrée\n– Fiche persona complète avec proﬁl psychologique utilisateur et occasion d’usage\n– Cahier des charges de proposition d’une offre adaptée\n– Techniques de production d’artefact et/ou prototype\n– Propriété intellectuelle et industrielle : recherche d’antériorités, utilisation des dispositifs de protection, dépôt	15	15 heures dont 6 heures de TP	Développer un projet e-business	MDEE	\N	\N
162	R5.MDEE.12	Référencement	Contribution au développement de la ou des compétences ciblées :\n– Mettre en oeuvre un référencement\n– Mobiliser les indicateurs et techniques pour être performant\n– Evaluer le résultat pour décider\n\nMots clés :\nStratégie digitale – veille digitale – indicateur – audit – e-commerce	– Réalisation d’un audit de référencement\n– Mise en œuvre les techniques de référencement naturel (SEO) et de mener des campagnes de référencement payant\n(SEA)\n– Analyse des mots-clés d’une marque et recommandations\n– Evaluation des campagnes de référencement	16	16 heures dont 8 heures de TP	Gérer une activité digitale	MDEE	\N	\N
165	R5.MDEE.15	Stratégie de contenu et rédaction web	Contribution au développement de la ou des compétences ciblées :\n– Etre capable de créer une ﬁche produit, de concevoir un catalogue\n– Actionner une stratégie de marque digitale et de e-merchandising\n– Savoir rédiger différents types de supports numériques (newsletters, livre blanc, infographie...)\n– Savoir créer du contenu adapté aux formats disponibles, permettant un référencement optimal\n\nMots clés :\nStratégie digitale – storytelling – vidéo	– Enjeux liés au contenu\n– Spéciﬁcités d’un contenu numérique et d’une marque digitale\n– Rédaction et design\n– Stratégie de contenu et audience	15	15 heures dont 6 heures de TP	Gérer une activité digitale	MDEE	\N	\N
166	R5.MDEE.16	Logistique et supply chain	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre des compétences relationnelles, de gestion et d’organisation de la logistique pour délivrer un bien ou\nun service qui optimise la relation client\n– Connaître les spéciﬁcités de la logistique pour une activité e-commerce\n– Etre capable de proposer des solutions pour assurer une chaine logistique efﬁcace au niveau national et à l’international\n\nMots clés :\nFlux – ERP	– Les enjeux de la logistique : satisfaction clients, taux de service et coûts logistiques\n– Les ﬂux de production : gestion des stocks, des espaces et des délais\n– Les ﬂux d’information et les solutions digitales\n– La supply chain\n– La logistique du e-commerce	15	15 heures	Gérer une activité digitale, Développer un projet e-business	MDEE	\N	\N
171	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	BI	\N	\N
172	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	BI	\N	\N
173	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	BI	\N	\N
174	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	BI	\N	\N
175	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Formuler une stratégie de commerce à l’international, Conduire les actions marketing	BI	\N	\N
176	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
177	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
178	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
179	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Conduire les actions marketing	BI	\N	\N
180	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
181	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
182	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
184	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
185	R3.BI.15	Stratégie et veille à l’international	Contribution au développement de la ou des compétences ciblées :\n– Déﬁnir et comprendre la veille stratégique et l’intelligence économique à l’international\n– Déterminer le problème décisionnel d’une entreprise à l’international\n\nMots clés :\nStratégies d’internationalisation – veille – diagnostic – prospection	– Compréhension de l’intérêt de la démarche d’internationalisation d’une organisation\n– Identiﬁcation des besoins et objectifs d’expansion à l’international d’une organisation\n– Identiﬁcation des options stratégiques de développement à l’international\n– Identiﬁcation des sources d’information pour la prise de décision (veille)\n– Analyse, trie des données par rapport aux objectifs\n– Utilisation des outils d’analyse stratégique pour identiﬁer les marchés porteurs et les cibles à l’international pour l’orga-\nnisation (SWOT, Porter, Pestel)\n– Mobilisation du diagnostic interne de l’entreprise pour déterminer sa capacité à s’internationaliser (moyens ﬁnanciers,\nhumains, logistiques...)\n– Identiﬁcation des organismes d’appui de développement à l’international (BPI,...)\n– Restitution des informations et des recommandations\nCette ressource peut être dispensée en langues étrangères.	13	13 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international	BI	\N	\N
186	R3.BI.16	Marketing et vente à l’international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender les différents aspects d’un problème marketing international\n– Développer les possibilités d’actions commerciales sur les marchés étrangers\n\nMots clés :\nMarketing international – prospection à l’international	– Identiﬁcation des prospects à l’international\n– Chiffrage des coûts et estimation de la faisabilité d’une opération de prospection à l’international\n– Adaptation de l’offre en déployant un marketing mix à l’international (stratégies d’adaptation et de standardisation, etc)\n– Élaboration d’un plan de lancement à l’international qui prend en compte les spéciﬁcités culturelles\nCette ressource peut être dispensée en langues étrangères.\nApprentissage critique ciblé :\n– AC25.04BI | Positionner l’offre en fonction des spéciﬁcités culturelles identiﬁées sur le(s) marché(s) ciblé(s)	13	13 heures	Piloter les opérations à l’international	BI	\N	\N
198	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	BI	\N	\N
199	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	BI	\N	\N
200	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Formuler une stratégie de commerce à l’international, Conduire les actions marketing	BI	\N	\N
201	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
203	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
210	R5.BI.13	Droit international	Contribution au développement de la ou des compétences ciblées :\n– Elaborer un projet de contrat avec un partenaire à l’international\n\nMots clés :\nDroit international – concurrence – protection des données – droit applicable – résolution des litiges – arbitrage – incoterm –\nusage du commerce international – obligation	– Présentation des sources du droit international (public / privé)\n– Analyse de l’environnement global international (OMC, UE, autres zones régionales...)\n– Droit général du contrat international : notions générales, loi applicable\n– Présentation des différents grands risques à l’international (droit applicable, résolution des litiges, familles de droit)\n– Droit spécial du contrat de vente international : cadre juridique du contrat de vente et formation du contrat, négociation,\npourparlers, médiation, arbitrage\n– Droit de la concurrence à l’international (fusions, acquisitions)\n– Protection des données et dispositifs anti-corruption, intelligence économique\nCette ressource peut être dispensée en langues étrangères.	18	18 heures	Formuler une stratégie de commerce à l’international	BI	\N	\N
204	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
205	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
206	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
207	R5.BI.10	Ressources et culture numériques appliquées au business international, achat et vente.	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher et structurer les données et informations importantes\n– Concevoir et mettre en œuvre des tableaux de bord efﬁcaces et pertinents\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité du système d’informations\n– Acquérir une culture numérique\n\nMots clés :\nERP – tableur fonction avancée – simulation – requête – sécurité	– Prise en main d’un ERP\n– Tableurs fonctions avancées : simulations, tableaux de bord,\n– Introduction au Big Data, au Data Mining	13	13 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BI	\N	\N
208	R5.BI.11	Approvisionnements	Contribution au développement de la ou des compétences ciblées :\n– Préciser la fonction d’approvisionneur/fonction d’acheteur dans l’entreprise\n– Maîtriser les outils d’analyse, optimiser les stocks\n\nMots clés :\nApprovisionnement – stock – performance	– Analyse du besoin / de la demande et suivi de commande\n– Calcul de besoin net\n– Tenue des stocks et classement selon les classes ABC : inventaires permanents, périodiques, tournants\n– Outils et techniques de gestion des stocks et des commandes\n– Système de quantité ﬁxe, à intervalles ﬁxes\n– Stock de sécurité\n– Méthode kanban\n– Analyse de la performance approvisionnement\n– Démarche d’amélioration continue\nCette ressource peut être dispensée en langues étrangères.	18	18 heures dont 4 heures de TP	Piloter les opérations à l’international	BI	\N	\N
209	R5.BI.12	Techniques du commerce international - 2	Contribution au développement de la ou des compétences ciblées :\n– Comprendre le mécanisme de l’échange des documents à l’export\n– Comprendre le mécanisme des douanes\n– Maîtriser le paiement et les risques\n\nMots clés :\nPaiement international – change – garantie – transport – logistique	– Instruments de paiement, virement et lettre de change, SWIFT\n– Techniques de paiement documentaires, cash-on-delivery, remise documentaire, crédit documentaire, lettre de crédit\nstand-by, assurance-crédit, forfaitage, affacturage\n– Risque de change, marché des changes, couverture à terme\n– Garanties BPI\n– Echanges Intra Union, dédouanement, dette douanière, régimes douaniers\n– Transport international, tariﬁcation du transport maritime, aérien et routier, groupage\nCette ressource peut être dispensée en langues étrangères.	20	20 heures dont 8 heures de TP	Piloter les opérations à l’international	BI	\N	\N
221	R3.05	Environnement économique international	Contribution au développement de la ou des compétences ciblées :\n– Appréhender l’environnement international et se positionner sur un marché\n– Comprendre et analyser un marché complexe et les interdépendances\n– Développer la culture générale\n\nMots clés :\nEconomie internationale – avantage comparatif – innovation – environnement	– Bases d’économie internationale (taux de change, aperçu du commerce mondial et théories du commerce international,\napproche géopolitique)\n– Enjeux économiques de l’innovation, lien avec la notion d’avantages comparatifs\n– Approche des enjeux environnementaux et des questions sociales en économie	13	13 heures	Conduire les actions marketing	BDMRC	\N	\N
211	R5.BI.14	Logistique et supply chain	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre des compétences relationnelles, de gestion et d’organisation de la logistique pour fournir un bien ou un\nservice en délivrant la valeur maximum au client et à l’entreprise\n– Connaître les spéciﬁcités de la logistique pour une activité e-commerce\n– Etre capable de proposer des solutions pour assurer une chaîne logistique efﬁcace au national et international\n\nMots clés :\nLogistique – supply chain – ﬂux – ERP	– Les enjeux de la logistique : satisfaction clients, taux de service et coûts logistiques\n– La supply chain\n– Les ﬂux de production : gestion des stocks, des espaces et des délais\n– La logistique de distribution et du e-commerce\n– Les ﬂux d’information et les solutions digitales\n– L’optimisation de la supply chain, décision make or buy\n– Ethique et éco-responsabilité\nCette ressource peut être dispensée en langues étrangères.	18	18 heures dont 8 heures de TP	Piloter les opérations à l’international	BI	\N	\N
212	R5.BI.15	Marketing achat	Contribution au développement de la ou des compétences ciblées :\n– Analyser l’offre des fournisseurs et les actions marketing en direction de ces derniers\nContenu\n– Achats en situation complexe : cahier des charges technique et cahier des charges fonctionnel, négociation achat à\nl’international, contractualisation, gestion et suivi de la relation fournisseur (y compris évaluation des fournisseurs)\n– Démarche qualité achat, certiﬁcation et normalisation\n– Marketing achat : déﬁnition et démarche du marketing achat, segmentation\n– Déﬁnition des besoins pour ajuster la demande à l’offre\n– Interaction avec les fournisseurs dans un objectif de progression\n– Evolution des relations vers un mode partenarial\n– Utilisation et intégration des concepts de développement soutenable (DS) et de RSE\n– Pratique de la veille technologique et commerciale\nCette ressource peut être dispensée en langues étrangères.\n\nMots clés :\nFonction achat – marketing achat – fournisseur – démarche qualité		18	18 heures dont 6 heures de TP	Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BI	\N	\N
217	R3.01	Marketing Mix - 2	Contribution au développement de la ou des compétences ciblées :\n– Donner une cohérence globale du marketing opérationnel de l’offre complexe avec le positionnement et la cible\n– Prendre des décisions marketing en environnement complexe\n– Adapter les choix opérationnels selon le contexte d’une offre complexe : B to B, international, digital, service ...\n\nMots clés :\nMarketing mix – offre complexe – dimension éthique et responsable de l’offre – marketing digital – marketing international –\nmarketing B to B	– Mise en oeuvre d’une démarche marketing cohérente avec la stratégie choisie\n– Proposition d’une offre opérationnelle en termes de produit/service, de prix, de distribution et de communication\n– Intégration d’une posture et d’une démarche éthiques et responsables en intégrant les enjeux sociétaux et écologiques\ndans l’offre élaborée\n– Prise en compte de l’environnement digital et/ou international	18	18 heures	Conduire les actions marketing	BDMRC	\N	\N
229	R3.13	Expression, communication, culture - 3	Contribution au développement de la ou des compétences ciblées :\n– S’informer et informer de manière critique :\n– Analyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\n– Communiquer de manière adaptée aux situations\n\nMots clés :\nRédaction documentaire – synthèse de documents – écrit professionnel – écrit académaique – conduite de réunion – persua-\nsion	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle).\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document (ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.)\n– Rédaction de synthèse de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc.)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire (note de lecture, contraction de texte).\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, de compte-rendu de réunion, d’article de presse\ngrand public / spécialisée, de dossier de presse, de communiqué de presse, de revue de presse, de publication corporate,\nd’écrit pour le web, de tweet, de post, d’e-mail, d’article de blog, d’e-books, de brochure web, d’élément de marque (logo,\npolices, etc.), datavisualisation.\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication et développement d’une éthique de la communication interpersonnelle (écoute active,\nempathie, attitudes de Porter, analyse et compréhension des malentendus, etc.)\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Utilisation d’outils collaboratifs, des réseaux sociaux pour communiquer\n– Animation de réunions (méthodologie de la conduite de réunion, typologie des réunions, techniques de prise de parole)\net outils de communication adaptés	15	15 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
218	R3.02	Entretien de vente	Contribution au développement de la ou des compétences ciblées :\n– Mener un entretien de vente simple dans sa globalité\n– Défendre son offre\n– Mesurer son efﬁcacité commerciale\n\nMots clés :\nPrix – entretien de négociation – objection prix – mesure de l’efﬁcacité	– Maîtrise des 7 étapes de l’entretien de vente (prise de contact, découverte des besoins, argumentation, traitement des\nobjections, proposition commerciale, conclusion, prise de congé) lors d’une simulation de jeu de rôle\n– Création d’un devis\n– Maîtrise des techniques d’annonce de prix\n– Maîtrise des techniques de défense d’une offre\n– Traitement des objections prix\n– Identiﬁcation des ratios utiles à l’analyse de la performance commerciale et construction des tableaux reporting pour\nmesurer l’efﬁcacité de son action commerciale\n– Réalisation d’une auto-analyse et d’un retour d’expérience	18	18 heures dont 10 heures de TP	Vendre une offre commerciale	BDMRC	\N	\N
219	R3.03	Principes de la communication digitale	Contribution au développement de la ou des compétences ciblées :\n– Connaître l’environnement de la communication digitale\n– Élaborer une stratégie de communication digitale\n– Créer du contenu adapté aux médias digitaux\n– Mesurer les résultats\n\nMots clés :\nCommunication – médias sociaux – gestion de contenus	– Stratégie de communication digitale : axe de communication, objectifs de communication et cible(s)\n– Panorama des médias/réseaux digitaux et sociaux : points forts et points faibles des différents réseaux sociaux / choix\nles médias sociaux adaptés aux besoins de l’entreprise\n– Parcours de communication digitale : principe de conversion (entonnoir « funnel ») de visiteur à client ﬁdèle\n– Création, gestion et planiﬁcation des publications dans le respect d’une ligne éditoriale\n– Création et gestion de contenus d’un site web en adéquation avec la stratégie\n– Gestion des inﬂuenceurs\n– Analyse de la performance : e-reputation	18	18 heures	Communiquer l’offre commerciale	BDMRC	\N	\N
220	R3.04	Etudes marketing - 3	Contribution au développement de la ou des compétences ciblées :\n– Être capable de préconiser une stratégie d’étude en situation complexe\n– Choisir et décrire la méthodologie d’étude\n– Analyser les données recueillies et justiﬁer de leur pertinence et de leur ﬁabilité\n– Mettre en œuvre les actions correspondant à l’étude réalisée\n– Choisir et construire des représentations cohérentes et pertinentes\n\nMots clés :\nEtude quantitative – échantillonnage – estimation – étude qualitative – représentation – traitement des données	– Études quantitatives : échantillonnage et estimation, initiation à l’analyse d’indicateurs et de leurs représentations\n– Études qualitatives : entretiens directifs et semi-directifs, analyse qualitative des données\n– Outils numériques de traitement des données	13	13 heures dont 6 heures de TP	Conduire les actions marketing	BDMRC	\N	\N
222	R3.06	Droit des activités commerciales - 1	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour élaborer le marketing mix, vendre l’offre commerciale et communiquer efﬁcacement dans le\nrespect du cadre législatif en vigueur\n\nMots clés :\nFranchise – concession – réseau de distribution – pratique abusive – responsabilité éditoriale – données personnelles	– Contrats de distribution\n– Législation sur les prix\n– Produits (normes, labels, AO)\n– Effets du contrat / Responsabilité contractuelle\n– Garanties légales et contractuelles\n– Pratiques abusives\n– Droit de la publicité\n– Droit des réseaux sociaux / E-réputation - Droit à l’oubli\n– Données personnelles : collecte et exploitation des données\n– Nom de domaine	13	13 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
223	R3.07	Techniques quantitatives et représentations - 3	Contribution au développement de la ou des compétences ciblées :\n– Savoir mettre en œuvre des modèles de prévision et d’approche probabiliste dans des situations simples\n– Développer un esprit critique et un esprit d’analyse\n– Savoir identiﬁer la loi de probabilité régissant un phénomène\n– Savoir poser des hypothèses\nContenus :\n– Problèmes de dénombrement\n– Calcul de probabilités élémentaires et de probabilités conditionnelles\n– Variables aléatoires\n– Lois de probabilités usuelles (binomiale, poisson, normale)\n– Test d’ajustement (Khi-2)\n\nMots clés :\nDénombrement – probabilité – loi de probabilité		13	13 heures dont 5 heures de TP	Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
224	R3.08	Tableau de bord commercial	Contribution au développement de la ou des compétences ciblées :\n– Réaliser un tableau de bord commercial (CA, trésorerie, bénéﬁce, marge par produit)\n– Mettre en place des actions correctives pour savoir analyser les performances d’une entreprise ou d’un service\n\nMots clés :\nTrésorerie – budget – tableau de bord – écart – indicateur	– Sélection des indicateurs pertinents en fonction de l’activité et suivi de leur évolution\n– Création d’un budget prévisionnel aﬁn d’anticiper les problèmes de trésorerie\n– Mise en évidence des écarts aﬁn de les analyser et de faire des recommandations de gestion\n– Mesure et évaluation de l’impact d’une future décision de gestion	13	13 heures dont 4 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
252	R5.BDMRC.10	Ressources et culture numériques appliquées au business développement et au	Contribution au développement de la ou des compétences ciblées :\n– Savoir utiliser un ERP et contribuer à son paramétrage commercial\n– Savoir rechercher, recueillir et structurer les données prospects et clients aﬁn d’exploiter efﬁcacement un CRM, et le\nfaire évoluer\n– Bâtir une campagne de relation client : déterminer les objectifs, cibler les prospects, s’approprier les outils, évaluer son\nefﬁcacité\n– Concevoir, mettre en œuvre et présenter des tableaux de bord efﬁcaces et pertinents\n– Veiller à la protection des données et au respect de la RGPD\n– Contribuer à la sécurité et à la conﬁdentialité du système d’informations\n\nMots clés :\nERP – CRM – scoring – tableur – sécurité – protection des données – simulations	– Prise en main d’un ERP et d’un CRM\n– Techniques de construction et d’alimentation d’une base de données, scoring\n– Tableurs fonctions avancées : simulations, tableaux de bord\n– Outils de présentation et communication des tableaux de bord\n– Introduction au Big Data, et au Data Mining, etc.	13	13 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client	BDMRC	\N	\N
225	R3.09	Psychologie sociale du travail	Contribution au développement de la ou des compétences ciblées :\n– Comprendre la complexité des organisations\n– Identiﬁer les principaux effets cognitifs, conatifs et affectifs de l’environnement professionnel sur les acteurs et leurs\nrépercussions sur les constructions identitaires professionnelles\n\nMots clés :\nHiérarchie – pouvoir et stratégie des acteurs – ingénierie psychosociale – déterminant sociocognitif – bien-être au travail –\nsatisfaction de vie au travail – changement – identité au travail/identité professionnelle – ergonomie	– Approfondissement et utilisation des leviers pour faire évoluer l’offre en s’appuyant sur des outils de création de valeur\ntout en proposant une communication efﬁcace pour la promouvoir (construction et utilisation d’outils de mesure des\ndéterminants sociocognitifs : attitudes, représentations sociales, intentions comportementales)\n– Questionnement des notions de RSE et de performances commerciales au regard des notions de bien-être, de qualité\nde vie au travail, de satisfaction au travail et de façon plus générale au regard des indicateurs sociaux\n– Appréhension de l’ingénierie psychosociale comme un outil de diagnostic permettant d’évaluer un problème (audit),\nconceptualisation d’une solution alternative, construction d’un modèle d’action et application du modèle d’action tout en\ncomprenant les mécanismes de la résistance au changement et en apprenant à accompagner la conduite du change-\nment.\n– Compréhension des interactions entre les environnements organisationnels, professionnels et les pensées, sentiments\net comportements des salariés et groupes de salariés.\n– Appréhension des impacts de l’environnement sur le fonctionnement d’une entreprise (système ouvert) et sur ses stra-\ntégies marketing (environnement / écologie - vie de travail / vie hors travail - culture du pays)\n– Sensibilisation à l’aménagement des postes de travail mais aussi à la présentation ergonomique des données	12	12 heures	Participer à la stratégie marketing et commerciale de l’organisation, Conduire les actions marketing	BDMRC	\N	\N
226	R3.10	Anglais appliqué au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté au contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
241	R4.BDMRC.09	Fondamentaux du management de l’équipe commerciale	Contribution au développement de la ou des compétences ciblées :\n– Comprendre le fonctionnement d’une équipe commerciale : spéciﬁcités des métiers, organisation de l’équipe de vente,\norganisation du travail commercial\n– Comprendre les principes du management d’une équipe commerciale : principaux leviers d’animation et outils de gestion\n– Découvrir le management situationnel : typologie des styles de management et de collaborateurs\n\nMots clés : Management d’équipe – structure d’équipe – moyens d’animation		0		Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
227	R3.11	LV B appliquée au commerce - 3	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel, présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation active à une réunion pour la mise en place d’un projet marketing\n– Phoning (prise de rdv, administration d’une enquête ...)\n– Élaboration et animation d’un entretien de vente simple\n– Analyse des posts sur les réseaux sociaux d’une entreprise et préparer des réponses\n– Préparation du CV et de la lettre de motivation\nOutils linguistiques\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	15	15 heures dont 8 heures de TP	Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
228	R3.12	Ressources et culture numériques - 3	Contribution au développement de la ou des compétences ciblées :\n– Créer un site internet simple\n– Élaborer un logo, un visuel et l’exporter\n– Concevoir une carte heuristique\n– Réaliser une vidéo complexe\n– Analyser des données et les représenter\n\nMots clés :\nBases HTML & CSS (en local) – tableur – dessin vectoriel – carte heuristique	– Bases HTML & CSS (en local)\n– Tableurs : fonctions avancées incluant formulaires, tris, ﬁltres, rechercheV, consolidation, calculs conditionnels, tableaux\ncroisés dynamiques, graphiques élaborés\n– Prise en main d’un outil de dessin vectoriel\n– Prise en main d’un outil de carte heuristique\n– Multimédia : réalisation d’une vidéo avec outils d’enregistrement & mixage de son\n– Respect de la législation, notamment du droit de propriété intellectuelle et du droit à la vie privée	18	18 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
230	R3.14	PPP - 3	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)\n\nMots clés :\nProjet professionnel – métier – recherche stage – recherche alternance	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	10	10 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
231	R3.BDMRC.15	Marketing B2B	Identiﬁer les spéciﬁcités du marketing B2B :\n– Identiﬁer le centre d’achat, ses acteurs et le processus d’achat B2B\n– Segmenter un marché B2B\n– Mettre en place le marketing-mix B2B\n– Utiliser les canaux relationnels B2B\n\nMots clés :\nAchat B2B – segmentation en B2B – mix B2B	– Veille et intelligence économique\n– Collaboration interne en vue de développer les opportunités commerciales\n– Contribution à la réactivité commerciale en développant la valeur ajoutée client	13	13 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
232	R3.BDMRC.16	Fondamentaux de la relation client	Identiﬁer les enjeux de la relation client et développer la culture client parmi les collaborateurs :\n– Adopter l’orientation client, identiﬁer les attentes relationnelles des clients\n– Écouter la voix du client sur les différents canaux de contact en surveillant les principaux indicateurs de la relation client\n(satisfaction, ﬁdélisation, NPS, etc.)\n– Présenter et situer le rôle d’un logiciel de gestion de la relation client (CRM)\n– Identiﬁer les informations pertinentes et exploitables dans l’objectif d’accumuler de la « connaissance client »\n\nMots clés :\nSatisfaction – ﬁdélisation – GRC – connaissance client	– Culture client\n– Indicateurs de la relation client\n– Logiciel CRM : présentation, rôle	13	13 heures	Manager la relation client	BDMRC	\N	\N
243	R5.01	Stratégie d’entreprise - 1	Contribuer au développement de la ou des compétences ciblées :\n– Réaliser un diagnostic approfondi de l’entreprise, de son environnement et de son potentiel dans un environnement\ncomplexe et instable\n– Proposer des solutions de développement futur des différentes activités de l’entreprise\n– Se positionner en termes d’externalisation de l’activité\n– Identiﬁer les sources de développement et le potentiel de l’entreprise : stratégie de développement et création de valeur\n– Savoir réagir face à l’évolution des environnements de l’organisation\n\nMots clés :\nOutils d’analyse stratégique – veille stratégique – facteur clé de succès – création de valeur – externalisation	– Outils d’analyse stratégique, matrices de positionnement\n– Composantes d’un portefeuille d’activités, facteurs clés de succès et actifs stratégiques\n– Construction d’une veille stratégique (déﬁnition des indicateurs et mise en place)\n– Conditions d’ adaptabilité, de transformation de l’activité, et de gestion du changement organisationnel	16	16 heures	Conduire les actions marketing	BDMRC	\N	\N
244	R5.02	Négocier dans des contextes spéciﬁques - 1	Contribution au développement de la ou des compétences ciblées :\n– S’adapter à un contexte spéciﬁque\n– Construire une offre adaptée au contexte spéciﬁque\n\nMots clés :\nNégociation complexe – contexte situationnel – achat	– Savoir analyser le contexte situationnel (positionnement des interlocuteurs, contexte spatio-temporel, sociologique, psy-\nchologique, problématique commerciale des interlocuteurs)\n– Appréhender des contextes particuliers et en comprendre les spéciﬁcités\n– Identiﬁer le processus d’achat et les décideurs\n– Identiﬁer la valeur ajoutée de la solution en relation avec le besoin du client\n– Jeux de rôle spéciﬁques aux domaines d’activité ciblés	18	18 heures dont 12 heures de TP	Vendre une offre commerciale	BDMRC	\N	\N
245	R5.03	Financement et régulation de l’économie	Contribution au développement de la ou des compétences ciblées :\n– Anticiper et s’adapter aux changements sociétaux, environnementaux et économiques\n– Approfondir sa culture générale\n\nMots clés :\nCrise – ﬁnancement – pensée économique – régulation – environnement et société	– Financement de l’économie, étude des crises\n– Théories économiques, histoire de la pensée économique\n– Régulations, ﬁnancement des enjeux environnementaux et sociaux	13	13 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing	BDMRC	\N	\N
246	R5.04	Droit des activités commerciales - 2	Contribution au développement de la ou des compétences ciblées :\nMobiliser des notions de droit pour intégrer la RSE dans la stratégie de l’offre et connaitre les solutions de paiement, les sûretés\net les recours en vue de mener une vente complexe.\n\nMots clés :\nDroit de l’environnement – risque – propriété commerciale – paiement – garanties – voies d’exécution – règlement amiable	– Cadre légal : intérêt des législations environnementales et sociales\n– Protection de l’activité commerciale : fonds de commerce, bail commercial\n– Paiement et sûretés\n– Règlement des litiges et recours judiciaires	13	13 heures	Participer à la stratégie marketing et commerciale de l’organisation, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
247	R5.05	Analyse ﬁnancière	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre les techniques de base de l’analyse ﬁnancière\n\nMots clés :\nFRNG – BFR – trésorerie – ratios – SIG – CAF – endettement	– Fonds de roulement, besoin en fonds de roulement, trésorerie, ratios de liquidité, solvabilité, endettement, ratios de\nrotation\n– Décomposition de la rentabilité à travers les SIG, la CAF, la trésorerie, ratios de proﬁtabilité et de rentabilité	13	13 heures dont 4 heures de TP	Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
248	R5.06	Anglais appliqué au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
255	R5.BDMRC.13	Marketing des services	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer les spéciﬁcités du marketing des services\n– Maîtriser les fondamentaux de l’expérience client, de sa mesure et de la recherche d’optimisation\n– Apprécier les notions de co-construction de la valeur\n– Maîtriser les concepts fondamentaux de la qualité\n– Améliorer la qualité de service et prendre en compte la dimension organisationnelle de la qualité de service\n\nMots clés :\nQualité – qualité des services – optimisation des services	culture de service et gestion des incidences service\n– Elaboration et suivi de feed-back des clients\n– Identiﬁcation des types de participation des clients\n– Etude et compréhension des motifs de réclamation des clients (attribution, motivation, émotions)\n– Gestion des incidents de service et des clients mécontents\n– Mise en place d’une prise en charge efﬁcace des réclamations\n– Prise en compte de l’équité et de la justice organisationnelle	25	25 heures dont 6 heures de TP	Manager la relation client	BDMRC	\N	\N
249	R5.07	LV B appliquée au commerce - 5	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle, en adaptant les registres de langue à la situation.\n\nMots clés :\nLangue de spécialité – langue professionnelle – langue adaptée au marketing – langue adaptée à la communication commer-\nciale – interculturalité – communication	– Participation et animation de débats sur des sujets en lien avec la RSE et le développement durable\n– Mise en place d’actions pour sensibiliser sur des sujets en lien avec la RSE\n– Création de supports et réalisation d’argumentaires pour défendre leur pertinence\n– Réalisation d’un entretien de vente\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, vocabulaire adapté\nen contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect, syntaxe\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire technique général des affaires et le restituer dans une situation professionnelle spéciﬁque\n– Argumenter et défendre son opinion / ses choix	13	13 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
250	R5.08	Expression, communication, culture - 5	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\n– Rechercher, sélectionner, analyser et synthétiser des informations\n– Se forger une culture médiatique, numérique et informationnelle\n– Enrichir sa connaissance du monde contemporain et sa culture générale\n– Développer l’esprit critique\nCommuniquer de manière adaptée aux situations\n– Produire des visuels, des écrits, des discours normés et adaptés au destinataire\n– Adapter sa communication à la cible et à la situation\n– Travailler en équipe, participer à un projet et à sa conduite\n\nMots clés :\nNote de synthèse – rapport écrit – présentation orale – communication en milieu de travail	S’informer et informer de manière critique et efﬁcace (niveau 3) :\n– Maitriser les techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et sectorielle).\n– Maitriser les techniques de rédaction documentaire :\nLecture et écriture de documents techniques et spécialisés\nRespect des normes bibliographiques et bureautiques appliquées à un document technique ou professionnel : ergonomie d’un\ndocument numérique, texte, paratexte, hypertexte, etc.\nSavoir synthétiser à l’écrit (niveau 3) : note de synthèse opérationnelle.\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel : les écritures académiques\net professionnelles (niveau 3)\n– Écrits académiques : production de documents complexes qui répondent aux différentes situations de communication\nuniversitaire : note de lecture, synthèse, compte-rendu, méthodologie du rapport de stage et de la soutenance.\n– Écrits professionnels (entreprise, web) : rédaction de dossier, de compte-rendu (d’événement, d’entretien, etc.), de\npublication corporate, de facture, devis, d’écrit pour le web, datavisualisation.\nCommuniquer, persuader, interagir (niveau 3) :\n– Analyser la communication en milieu de travail\n– Persuader : approfondir les techniques d’argumentation et de rhétorique et les mettre en pratique dans sa vie profes-\nsionnelle.\n– Animer et gérer une réunion (dynamique de groupe, animation de réunion, de focus group, techniques de prise de parole,\ngestion des conﬂits).\n– Développer ses habiletés relationnelles en contexte de communication au travail (empathie, écoute, entretien, afﬁrmation\nde soi, intelligence émotionnelle, etc.)	18	18 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
251	R5.09	PPP - 5	Contribution au développement de la ou des compétences ciblées :\nAfﬁrmer la posture professionnelle et ﬁnaliser le projet\n\nMots clés :\nPosture professionnelle – insertion professionnelle – recrutement	Approfondir la connaissance de soi et afﬁrmer sa posture professionnelle\n– Exploiter ses stages aﬁn de parfaire sa posture professionnelle\n– Formaliser ses réseaux professionnels (proﬁls, carte réseau, réseau professionnel...)\n– Faire le bilan de ses compétences\nFormaliser son plan de carrière : développement d’une stratégie personnelle et professionnelle\n– À court terme : insertion professionnelle immédiate après le B.U.T. ou poursuite d’études\n– À plus long terme : VAE, CPF, FTLV, etc.\nS’approprier le processus et s’adapter aux différents types de recrutement\n– Mise à jour des outils de communication professionnelle\n– Préparation aux différents types et formes de recrutement : test, entretien collectif ou individuel, mise en situation,\nconcours, en entreprise, en école, à l’université	8	8 heures	Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale	BDMRC	\N	\N
253	R5.BDMRC.11	Développement des pratiques managériales	Contribution au développement de la ou des compétences ciblées :\n– Gérer la relation interpersonnelle et animer une équipe commerciale\n– Enrichir l’observation et l’écoute de l’autre\n– S’approprier un style de management\n– Fédérer les équipes autour de l’atteinte des objectifs (méthode SMART)\n– Suivre et organiser le développement des compétences du personnel (formation continue, entretien annuel, ...)\n– Valoriser les compétences des membres de l’équipe\n– Gérer le changement et les conﬂits\n\nMots clés :\nManagement relationnel – gestion des conﬂits – leadership – coaching	– Positionnement managérial et management relationnel d’une équipe\n– Motivation et valorisation, management de la différenciation\n– Facteurs clés du leadership, qualités du leader, compétences\n– Outils de coaching, de prévention et de gestion de conﬂit	23	23 heures dont 6 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
254	R5.BDMRC.12	Management de la valeur client	Contribution au développement de la ou des compétences ciblées :\n– Manager en faveur de la valeur client en concevant une stratégie de la relation client pour améliorer la rentabilité de\nl’entreprise\n– Analyser les bases de données clients (éventuellement via l’utilisation d’un logiciel CRM) et faire un diagnostic aﬁn d’éla-\nborer des stratégies et actions marketing adaptées aux typologies de clients et aux comportements de consommation\n– Distinguer les différentes formes de ﬁdélité, ﬁdéliser et engager les clients dans une relation durable\n\nMots clés :\nPortefeuille client – CRM – segmentation – scoring – ﬁdélisation – typologie client	– Segmentation et valorisation du portefeuille clients, montée en gamme\n– Suivi de l’évolution du portefeuille clients\n– Indicateurs de performance (Net Promoter Score, ...)\n– Calcul de lifetime value (LTV), cross-selling, up-selling\n– Coût d’acquisition d’un client, ﬁdélisation\nPrérequis :\n– R5.BDMRC.10 | Ressources et culture numériques appliquées au business développement et au management de la\nrelation client	21	21 heures dont 6 heures de TP	Manager la relation client	BDMRC	\N	\N
256	R5.BDMRC.14	Pilotage de l’équipe commerciale	Contribution au développement de la ou des compétences ciblées :\n– Sélectionner les collaborateurs en considérant les besoins de l’équipe et les intégrer\n– Animer et piloter l’équipe commerciale\n– Organiser et planiﬁer les tâches de l’équipe\n– Élaborer les tableaux de reporting\n\nMots clés :\nAnimation – pilotage – tableau de bord – indicateur – opportunité commerciale	– Outils d’information (base de données clients, listes précises de prospects, état de la concurrence, ﬁches produits à jour)\n– Outils de communication (réunions internes et clients, participation, réseaux, gestion de la mobilité, intranet, reporting)\n– Outils de suivi de l’activité (évolution de la mission, tableau de bord, atteinte des objectifs...)\nPrérequis :\n– R5.BDMRC.10 | Ressources et culture numériques appliquées au business développement et au management de la\nrelation client	23	23 heures dont 8 heures de TP	Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
47	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	SME	\N	\N
94	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	MMPV	\N	\N
140	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	MDEE	\N	\N
187	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	BI	\N	\N
233	R4.01	Stratégie marketing	Contribution au développement de la ou des compétences ciblées :\n– Mettre en œuvre une stratégie marketing pertinente selon l’activité et le marché\n– Utiliser les outils d’analyse pour positionner durablement les facteurs clés de succès\n– Appréhender les facteurs et enjeux des environnements complexes à un ou plusieurs niveaux\n– Identiﬁer les étapes de la démarche marketing complexe intégrant une approche éthique et responsable\n\nMots clés : Stratégie marketing – environnement complexe – marketing digital – marketing international – marketing B to B	– Composants d’une stratégie marketing en environnement complexe\n– Éléments clés des spéciﬁcités d’un marché ou d’une activité : B to B, produit ou service, commerce international, activité\ndigitale, etc., en cohérence avec le contexte local, national ou international	0		Conduire les actions marketing	BDMRC	\N	\N
74	R6.01	Stratégie d’entreprise - 2	Contribuer au développement de la ou des compétences ciblées :\n– Élaborer, développer et adapter une stratégie marketing dans un contexte complexe et instable\n– Mobiliser les outils de diagnostic de stratégie marketing dans un environnement complexe et instable\n– Développer un marketing responsable et durable (produits éthiques, locaux, gestion de l’origine, durable...)\n– Intégrer un esprit "positive business" au sein d’un collectif\n\nMots clés : RSE – positive business – stratégie marketing en environnement instable	– Fondamentaux de la stratégie\n– Outils spéciﬁques liés à la RSE et au "positive business"\n– Composantes d’une offre en situation de crise\n– Adaptation de l’offre dans un environnement instable en proﬁtant des opportunités pour développer une offre à forte\nvaleur ajoutée répondant aux problématiques de crise ou d’instabilité	0		Conduire les actions marketing	SME	\N	\N
120	R6.01	Stratégie d’entreprise - 2	Contribuer au développement de la ou des compétences ciblées :\n– Élaborer, développer et adapter une stratégie marketing dans un contexte complexe et instable\n– Mobiliser les outils de diagnostic de stratégie marketing dans un environnement complexe et instable\n– Développer un marketing responsable et durable (produits éthiques, locaux, gestion de l’origine, durable...)\n– Intégrer un esprit "positive business" au sein d’un collectif\n\nMots clés : RSE – positive business – stratégie marketing en environnement instable	– Fondamentaux de la stratégie\n– Outils spéciﬁques liés à la RSE et au "positive business"\n– Composantes d’une offre en situation de crise\n– Adaptation de l’offre dans un environnement instable en proﬁtant des opportunités pour développer une offre à forte\nvaleur ajoutée répondant aux problématiques de crise ou d’instabilité	0		Conduire les actions marketing	MMPV	\N	\N
167	R6.01	Stratégie d’entreprise - 2	Contribuer au développement de la ou des compétences ciblées :\n– Élaborer, développer et adapter une stratégie marketing dans un contexte complexe et instable\n– Mobiliser les outils de diagnostic de stratégie marketing dans un environnement complexe et instable\n– Développer un marketing responsable et durable (produits éthiques, locaux, gestion de l’origine, durable...)\n– Intégrer un esprit "positive business" au sein d’un collectif\n\nMots clés : RSE – positive business – stratégie marketing en environnement instable	– Fondamentaux de la stratégie\n– Outils spéciﬁques liés à la RSE et au "positive business"\n– Composantes d’une offre en situation de crise\n– Adaptation de l’offre dans un environnement instable en proﬁtant des opportunités pour développer une offre à forte\nvaleur ajoutée répondant aux problématiques de crise ou d’instabilité	0		Conduire les actions marketing	MDEE	\N	\N
213	R6.01	Stratégie d’entreprise - 2	Contribuer au développement de la ou des compétences ciblées :\n– Élaborer, développer et adapter une stratégie marketing dans un contexte complexe et instable\n– Mobiliser les outils de diagnostic de stratégie marketing dans un environnement complexe et instable\n– Développer un marketing responsable et durable (produits éthiques, locaux, gestion de l’origine, durable...)\n– Intégrer un esprit "positive business" au sein d’un collectif\n\nMots clés : RSE – positive business – stratégie marketing en environnement instable	– Fondamentaux de la stratégie\n– Outils spéciﬁques liés à la RSE et au "positive business"\n– Composantes d’une offre en situation de crise\n– Adaptation de l’offre dans un environnement instable en proﬁtant des opportunités pour développer une offre à forte\nvaleur ajoutée répondant aux problématiques de crise ou d’instabilité	0		Conduire les actions marketing	BI	\N	\N
257	R6.01	Stratégie d’entreprise - 2	Contribuer au développement de la ou des compétences ciblées :\n– Élaborer, développer et adapter une stratégie marketing dans un contexte complexe et instable\n– Mobiliser les outils de diagnostic de stratégie marketing dans un environnement complexe et instable\n– Développer un marketing responsable et durable (produits éthiques, locaux, gestion de l’origine, durable...)\n– Intégrer un esprit "positive business" au sein d’un collectif\n\nMots clés : RSE – positive business – stratégie marketing en environnement instable	– Fondamentaux de la stratégie\n– Outils spéciﬁques liés à la RSE et au "positive business"\n– Composantes d’une offre en situation de crise\n– Adaptation de l’offre dans un environnement instable en proﬁtant des opportunités pour développer une offre à forte\nvaleur ajoutée répondant aux problématiques de crise ou d’instabilité	0		Conduire les actions marketing	BDMRC	\N	\N
48	R4.02	Négociation : rôle du vendeur et de l’acheteur	Contribution au développement de la ou des compétences ciblées :\n– Préparer la proposition commerciale et la présenter\n– Comprendre les bases du management commercial\n– Comprendre les bases de la fonction achat\n\nMots clés : Proposition commerciale – négociation – marge – management commercial – acheteur	Préparation et présentation de la proposition commerciale dans le cadre de jeux de rôle\n– Construction d’une proposition commerciale en adéquation avec les besoins identiﬁés\n– Prise en compte des enjeux de la marge commerciale et délimitation des marges de manœuvre\n– Gestion de l’objection prix et défense de la marge\nInitiation au management commercial\n– Fondamentaux du management de l’équipe commerciale : organisation des tournées, objectifs, priorisation des cibles,\namélioration de la performance\nInitiation à la fonction achat\n– Rôle de l’acheteur\n– Découverte de la fonction achat\n– Connaissance des stratégies d’un acheteur professionnel	0		Vendre une offre commerciale	SME	\N	\N
190	R4.04	Droit du travail	Contribuer au développement de la ou des compétences ciblées :\n– Comprendre et analyser les relations individuelles du travail\n– Comprendre et analyser les relations collectives du travail\n\nMots clés : Salarié – contrat de travail – négociation collective	– Conclusion du contrat de travail (types de contrats), droits et obligations du salarié et de l’employeur, rupture du contrat\nde travail\n– Négociation collective dans l’entreprise, conventions et accords collectifs, représentants des salariés	0		Conduire les actions marketing, Vendre une offre commerciale	BI	\N	\N
95	R4.02	Négociation : rôle du vendeur et de l’acheteur	Contribution au développement de la ou des compétences ciblées :\n– Préparer la proposition commerciale et la présenter\n– Comprendre les bases du management commercial\n– Comprendre les bases de la fonction achat\n\nMots clés : Proposition commerciale – négociation – marge – management commercial – acheteur	Préparation et présentation de la proposition commerciale dans le cadre de jeux de rôle\n– Construction d’une proposition commerciale en adéquation avec les besoins identiﬁés\n– Prise en compte des enjeux de la marge commerciale et délimitation des marges de manœuvre\n– Gestion de l’objection prix et défense de la marge\nInitiation au management commercial\n– Fondamentaux du management de l’équipe commerciale : organisation des tournées, objectifs, priorisation des cibles,\namélioration de la performance\nInitiation à la fonction achat\n– Rôle de l’acheteur\n– Découverte de la fonction achat\n– Connaissance des stratégies d’un acheteur professionnel	0		Vendre une offre commerciale	MMPV	\N	\N
141	R4.02	Négociation : rôle du vendeur et de l’acheteur	Contribution au développement de la ou des compétences ciblées :\n– Préparer la proposition commerciale et la présenter\n– Comprendre les bases du management commercial\n– Comprendre les bases de la fonction achat\n\nMots clés : Proposition commerciale – négociation – marge – management commercial – acheteur	Préparation et présentation de la proposition commerciale dans le cadre de jeux de rôle\n– Construction d’une proposition commerciale en adéquation avec les besoins identiﬁés\n– Prise en compte des enjeux de la marge commerciale et délimitation des marges de manœuvre\n– Gestion de l’objection prix et défense de la marge\nInitiation au management commercial\n– Fondamentaux du management de l’équipe commerciale : organisation des tournées, objectifs, priorisation des cibles,\namélioration de la performance\nInitiation à la fonction achat\n– Rôle de l’acheteur\n– Découverte de la fonction achat\n– Connaissance des stratégies d’un acheteur professionnel	0		Vendre une offre commerciale	MDEE	\N	\N
188	R4.02	Négociation : rôle du vendeur et de l’acheteur	Contribution au développement de la ou des compétences ciblées :\n– Préparer la proposition commerciale et la présenter\n– Comprendre les bases du management commercial\n– Comprendre les bases de la fonction achat\n\nMots clés : Proposition commerciale – négociation – marge – management commercial – acheteur	Préparation et présentation de la proposition commerciale dans le cadre de jeux de rôle\n– Construction d’une proposition commerciale en adéquation avec les besoins identiﬁés\n– Prise en compte des enjeux de la marge commerciale et délimitation des marges de manœuvre\n– Gestion de l’objection prix et défense de la marge\nInitiation au management commercial\n– Fondamentaux du management de l’équipe commerciale : organisation des tournées, objectifs, priorisation des cibles,\namélioration de la performance\nInitiation à la fonction achat\n– Rôle de l’acheteur\n– Découverte de la fonction achat\n– Connaissance des stratégies d’un acheteur professionnel	0		Vendre une offre commerciale	BI	\N	\N
234	R4.02	Négociation : rôle du vendeur et de l’acheteur	Contribution au développement de la ou des compétences ciblées :\n– Préparer la proposition commerciale et la présenter\n– Comprendre les bases du management commercial\n– Comprendre les bases de la fonction achat\n\nMots clés : Proposition commerciale – négociation – marge – management commercial – acheteur	Préparation et présentation de la proposition commerciale dans le cadre de jeux de rôle\n– Construction d’une proposition commerciale en adéquation avec les besoins identiﬁés\n– Prise en compte des enjeux de la marge commerciale et délimitation des marges de manœuvre\n– Gestion de l’objection prix et défense de la marge\nInitiation au management commercial\n– Fondamentaux du management de l’équipe commerciale : organisation des tournées, objectifs, priorisation des cibles,\namélioration de la performance\nInitiation à la fonction achat\n– Rôle de l’acheteur\n– Découverte de la fonction achat\n– Connaissance des stratégies d’un acheteur professionnel	0		Vendre une offre commerciale	BDMRC	\N	\N
75	R6.02	Négocier dans des contextes spéciﬁques - 2	Contribution au développement de la ou des compétences ciblées :\n– Savoir s’adapter à un contexte spéciﬁque\n– Mener un entretien en tant qu’acheteur\n\nMots clés : Négociation complexe – négociation achat – acheteur	Adaptation à un contexte spéciﬁque (en lien avec le parcours)\n– Maitrise des enjeux d’un entretien de vente dans un contexte spéciﬁque\n– Réalisation d’un entretien de négociation spéciﬁque\nPréparation et réalisation d’un entretien en tant qu’acheteur (en lien avec le parcours)\n– Identiﬁcation des techniques d’un acheteur professionnel\n– Réalisation d’un entretien d’achat\nMise en œuvre de la négociation\n– Jeux de rôle dans le contexte spéciﬁque	0		Vendre une offre commerciale	SME	\N	\N
121	R6.02	Négocier dans des contextes spéciﬁques - 2	Contribution au développement de la ou des compétences ciblées :\n– Savoir s’adapter à un contexte spéciﬁque\n– Mener un entretien en tant qu’acheteur\n\nMots clés : Négociation complexe – négociation achat – acheteur	Adaptation à un contexte spéciﬁque (en lien avec le parcours)\n– Maitrise des enjeux d’un entretien de vente dans un contexte spéciﬁque\n– Réalisation d’un entretien de négociation spéciﬁque\nPréparation et réalisation d’un entretien en tant qu’acheteur (en lien avec le parcours)\n– Identiﬁcation des techniques d’un acheteur professionnel\n– Réalisation d’un entretien d’achat\nMise en œuvre de la négociation\n– Jeux de rôle dans le contexte spéciﬁque	0		Vendre une offre commerciale	MMPV	\N	\N
168	R6.02	Négocier dans des contextes spéciﬁques - 2	Contribution au développement de la ou des compétences ciblées :\n– Savoir s’adapter à un contexte spéciﬁque\n– Mener un entretien en tant qu’acheteur\n\nMots clés : Négociation complexe – négociation achat – acheteur	Adaptation à un contexte spéciﬁque (en lien avec le parcours)\n– Maitrise des enjeux d’un entretien de vente dans un contexte spéciﬁque\n– Réalisation d’un entretien de négociation spéciﬁque\nPréparation et réalisation d’un entretien en tant qu’acheteur (en lien avec le parcours)\n– Identiﬁcation des techniques d’un acheteur professionnel\n– Réalisation d’un entretien d’achat\nMise en œuvre de la négociation\n– Jeux de rôle dans le contexte spéciﬁque	0		Vendre une offre commerciale	MDEE	\N	\N
214	R6.02	Négocier dans des contextes spéciﬁques - 2	Contribution au développement de la ou des compétences ciblées :\n– Savoir s’adapter à un contexte spéciﬁque\n– Mener un entretien en tant qu’acheteur\n\nMots clés : Négociation complexe – négociation achat – acheteur	Adaptation à un contexte spéciﬁque (en lien avec le parcours)\n– Maitrise des enjeux d’un entretien de vente dans un contexte spéciﬁque\n– Réalisation d’un entretien de négociation spéciﬁque\nPréparation et réalisation d’un entretien en tant qu’acheteur (en lien avec le parcours)\n– Identiﬁcation des techniques d’un acheteur professionnel\n– Réalisation d’un entretien d’achat\nMise en œuvre de la négociation\n– Jeux de rôle dans le contexte spéciﬁque	0		Vendre une offre commerciale	BI	\N	\N
258	R6.02	Négocier dans des contextes spéciﬁques - 2	Contribution au développement de la ou des compétences ciblées :\n– Savoir s’adapter à un contexte spéciﬁque\n– Mener un entretien en tant qu’acheteur\n\nMots clés : Négociation complexe – négociation achat – acheteur	Adaptation à un contexte spéciﬁque (en lien avec le parcours)\n– Maitrise des enjeux d’un entretien de vente dans un contexte spéciﬁque\n– Réalisation d’un entretien de négociation spéciﬁque\nPréparation et réalisation d’un entretien en tant qu’acheteur (en lien avec le parcours)\n– Identiﬁcation des techniques d’un acheteur professionnel\n– Réalisation d’un entretien d’achat\nMise en œuvre de la négociation\n– Jeux de rôle dans le contexte spéciﬁque	0		Vendre une offre commerciale	BDMRC	\N	\N
49	R4.03	Conception d’une campagne de communication	Contribuer au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication adaptée à un cahier des charges\n– Proposer un plan de communication\n\nMots clés : Stratégie communication commerciale – plan média – copy-stratégie – analyse de la performance	– Réﬂexion stratégique : cibles, objectifs, stratégie de communication (ressources S1) / élaboration du budget de cam-\npagne\n– Indicateurs de choix des supports : audience utile, afﬁnité, coût pour mille\n– Plan média : approche 360◦, cohérence des moyens\n– Stratégie de création de contenu et messages performatifs / brief, copy-stratégie, storyboard, copy-writing\n– Évaluation et analyse d’une campagne : pré-test et post-test	0		Communiquer l’offre commerciale	SME	\N	\N
96	R4.03	Conception d’une campagne de communication	Contribuer au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication adaptée à un cahier des charges\n– Proposer un plan de communication\n\nMots clés : Stratégie communication commerciale – plan média – copy-stratégie – analyse de la performance	– Réﬂexion stratégique : cibles, objectifs, stratégie de communication (ressources S1) / élaboration du budget de cam-\npagne\n– Indicateurs de choix des supports : audience utile, afﬁnité, coût pour mille\n– Plan média : approche 360◦, cohérence des moyens\n– Stratégie de création de contenu et messages performatifs / brief, copy-stratégie, storyboard, copy-writing\n– Évaluation et analyse d’une campagne : pré-test et post-test	0		Communiquer l’offre commerciale	MMPV	\N	\N
142	R4.03	Conception d’une campagne de communication	Contribuer au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication adaptée à un cahier des charges\n– Proposer un plan de communication\n\nMots clés : Stratégie communication commerciale – plan média – copy-stratégie – analyse de la performance	– Réﬂexion stratégique : cibles, objectifs, stratégie de communication (ressources S1) / élaboration du budget de cam-\npagne\n– Indicateurs de choix des supports : audience utile, afﬁnité, coût pour mille\n– Plan média : approche 360◦, cohérence des moyens\n– Stratégie de création de contenu et messages performatifs / brief, copy-stratégie, storyboard, copy-writing\n– Évaluation et analyse d’une campagne : pré-test et post-test	0		Communiquer l’offre commerciale	MDEE	\N	\N
189	R4.03	Conception d’une campagne de communication	Contribuer au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication adaptée à un cahier des charges\n– Proposer un plan de communication\n\nMots clés : Stratégie communication commerciale – plan média – copy-stratégie – analyse de la performance	– Réﬂexion stratégique : cibles, objectifs, stratégie de communication (ressources S1) / élaboration du budget de cam-\npagne\n– Indicateurs de choix des supports : audience utile, afﬁnité, coût pour mille\n– Plan média : approche 360◦, cohérence des moyens\n– Stratégie de création de contenu et messages performatifs / brief, copy-stratégie, storyboard, copy-writing\n– Évaluation et analyse d’une campagne : pré-test et post-test	0		Communiquer l’offre commerciale	BI	\N	\N
235	R4.03	Conception d’une campagne de communication	Contribuer au développement de la ou des compétences ciblées :\n– Elaborer une stratégie de communication adaptée à un cahier des charges\n– Proposer un plan de communication\n\nMots clés : Stratégie communication commerciale – plan média – copy-stratégie – analyse de la performance	– Réﬂexion stratégique : cibles, objectifs, stratégie de communication (ressources S1) / élaboration du budget de cam-\npagne\n– Indicateurs de choix des supports : audience utile, afﬁnité, coût pour mille\n– Plan média : approche 360◦, cohérence des moyens\n– Stratégie de création de contenu et messages performatifs / brief, copy-stratégie, storyboard, copy-writing\n– Évaluation et analyse d’une campagne : pré-test et post-test	0		Communiquer l’offre commerciale	BDMRC	\N	\N
50	R4.04	Droit du travail	Contribuer au développement de la ou des compétences ciblées :\n– Comprendre et analyser les relations individuelles du travail\n– Comprendre et analyser les relations collectives du travail\n\nMots clés : Salarié – contrat de travail – négociation collective	– Conclusion du contrat de travail (types de contrats), droits et obligations du salarié et de l’employeur, rupture du contrat\nde travail\n– Négociation collective dans l’entreprise, conventions et accords collectifs, représentants des salariés	0		Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale	SME	\N	\N
97	R4.04	Droit du travail	Contribuer au développement de la ou des compétences ciblées :\n– Comprendre et analyser les relations individuelles du travail\n– Comprendre et analyser les relations collectives du travail\n\nMots clés : Salarié – contrat de travail – négociation collective	– Conclusion du contrat de travail (types de contrats), droits et obligations du salarié et de l’employeur, rupture du contrat\nde travail\n– Négociation collective dans l’entreprise, conventions et accords collectifs, représentants des salariés	0		Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale	MMPV	\N	\N
143	R4.04	Droit du travail	Contribuer au développement de la ou des compétences ciblées :\n– Comprendre et analyser les relations individuelles du travail\n– Comprendre et analyser les relations collectives du travail\n\nMots clés : Salarié – contrat de travail – négociation collective	– Conclusion du contrat de travail (types de contrats), droits et obligations du salarié et de l’employeur, rupture du contrat\nde travail\n– Négociation collective dans l’entreprise, conventions et accords collectifs, représentants des salariés	0		Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale	MDEE	\N	\N
51	R4.05	Anglais appliqué au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage par ex.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
98	R4.05	Anglais appliqué au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage par ex.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
144	R4.05	Anglais appliqué au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage par ex.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
191	R4.05	Anglais appliqué au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage par ex.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
170	R6.MDEE.04	Formalisation et sécurisation d’un business model	Contribution au développement de la ou des compétences ciblées :\n– Conforter/concrétiser la création/reprise d’une organisation, d’un projet intrapreneurial\n– Formaliser les processus, les démarches de qualiﬁcation et certiﬁcation\n– Financer son projet et protéger l’entrepreneur\n– Adopter la bonne posture pour un management éthique\n– Comprendre l’écosystème entrepreneurial\n\nMots clés : Formalisation – protection du dirigeant – démarche éthique	– Nouvelles théories et pratiques entrepreneuriales (approche effectuale, construction de l’offre par essai-erreur, méthodes\nde levée de fonds auprès de parties prenantes...)\n– Business model et business plan complet\n– Documents administratifs, ﬁnanciers et légaux de création et reprise d’entreprise	0		Développer un projet e-business	MDEE	\N	\N
237	R4.05	Anglais appliqué au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage par ex.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
52	R4.06	LV B appliquée au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage, etc.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
99	R4.06	LV B appliquée au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage, etc.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Manager une équipe commerciale sur un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
145	R4.06	LV B appliquée au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage, etc.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
148	R4.MDEE.09	Conduite de projet digital	Contribution au développement de la ou des compétences ciblées :\n– Identiﬁer les constituants d’un projet digital simple\n– Utiliser et élaborer un cahier des charges e-business simple\n\nMots clés : Stratégie digitale – e-commerce – projet	– Connaître les éléments constitutifs d’une approche agile de gestion de projet digital\n– Comprendre les rôles et responsabilités d’une équipe de projet digital\n– Elaborer un cahier des charges simple\n– Connaître tous les acteurs à impliquer dès le début du projet digital (référencement, développement, client, marketing...)\n– Conduire un projet en environnement digital	0		Gérer une activité digitale	MDEE	\N	\N
192	R4.06	LV B appliquée au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage, etc.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
238	R4.06	LV B appliquée au commerce - 4	Contribution au développement de la ou des compétences ciblées :\nRenforcer les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement pro-\nfessionnel international, notamment :\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel	– Élaboration d’un questionnaire/une enquête/une interview complexe\n– Réalisation d’un entretien de vente simple\n– Création d’un contenu adapté au pays cible pour alimenter des blogs / réseaux sociaux, en mesurant la performance et\nen veillant à l’e-réputation (posts / concours / vidéos...)\n– Construction du CV et rédaction d’une lettre de motivation dans la langue cible (recherche de stage, etc.)\nOutils linguistiques :\n– Travailler entre autres les éléments suivants : conjugaison et emploi des temps adaptés à la situation, alphabet, vocabu-\nlaire adapté en contexte, forme interrogative, formules de politesse, possession, comparatifs, discours direct et indirect\n– Veiller à la qualité phonétique et idiomatique de l’expression\n– Manier toutes sortes de chiffres (dates, horaires, prix, etc.), lire des graphiques et décrire des tendances\n– Maîtriser le vocabulaire général de l’entreprise, du marketing, de la vente, de la communication commerciale et le resti-\ntuer dans une situation professionnelle	0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
53	R4.07	Expression, communication, culture - 4	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\nCommuniquer de manière adaptée aux situations	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle)\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document, ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.\n– Rédaction de synthèses de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : produire des documents complexes qui répondent aux différentes situations de communication\nuniversitaire (méthodologie du rapport de stage, de projet et de la soutenance)\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, d’article de presse grand public / spécialisée, de\ndossier de presse, de communiqué de presse, de revue de presse, de publication corporate, d’écrit pour le web, de\ntweet, de post, d’e-mails, d’article de blog, d’e-book, de brochure web, datavisualisation\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication : s’initier à la communication interculturelle.\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Communication en public	0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
100	R4.07	Expression, communication, culture - 4	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\nCommuniquer de manière adaptée aux situations	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle)\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document, ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.\n– Rédaction de synthèses de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : produire des documents complexes qui répondent aux différentes situations de communication\nuniversitaire (méthodologie du rapport de stage, de projet et de la soutenance)\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, d’article de presse grand public / spécialisée, de\ndossier de presse, de communiqué de presse, de revue de presse, de publication corporate, d’écrit pour le web, de\ntweet, de post, d’e-mails, d’article de blog, d’e-book, de brochure web, datavisualisation\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication : s’initier à la communication interculturelle.\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Communication en public	0		Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
149	R4.MDEE.10	Stratégie e-commerce	Contribution au développement de la ou des compétences ciblées :\n– Participer activement à un projet digital e-commerce\n– Identiﬁer les spéciﬁcités de l’offre et de la demande du e-commerce\n– Mettre en oeuvre un processus logistique performant\n\nMots clés : Stratégie digitale – segmentation – modèle d’affaires	– Identiﬁer et analyser les segments de marché et leur évolution\n– Concevoir un proﬁl simple de persona cible et son parcours d’achat\n– Identiﬁer les modèles d’affaires sur le web\n– Mettre en œuvre une stratégie e-commerce en suivant les étapes\n– Savoir comment fonctionne une place de marché\n– Connaître les outils de la conversion client (stratégie de contenu, inbound marketing)\n– Connaître les spéciﬁcités de la logistique pour une activité e-commerce\n– Intégrer le digital dans une stratégie de distribution omnicanal	0		Gérer une activité digitale	MDEE	\N	\N
146	R4.07	Expression, communication, culture - 4	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\nCommuniquer de manière adaptée aux situations	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle)\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document, ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.\n– Rédaction de synthèses de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : produire des documents complexes qui répondent aux différentes situations de communication\nuniversitaire (méthodologie du rapport de stage, de projet et de la soutenance)\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, d’article de presse grand public / spécialisée, de\ndossier de presse, de communiqué de presse, de revue de presse, de publication corporate, d’écrit pour le web, de\ntweet, de post, d’e-mails, d’article de blog, d’e-book, de brochure web, datavisualisation\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication : s’initier à la communication interculturelle.\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Communication en public	0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
193	R4.07	Expression, communication, culture - 4	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\nCommuniquer de manière adaptée aux situations	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle)\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document, ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.\n– Rédaction de synthèses de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : produire des documents complexes qui répondent aux différentes situations de communication\nuniversitaire (méthodologie du rapport de stage, de projet et de la soutenance)\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, d’article de presse grand public / spécialisée, de\ndossier de presse, de communiqué de presse, de revue de presse, de publication corporate, d’écrit pour le web, de\ntweet, de post, d’e-mails, d’article de blog, d’e-book, de brochure web, datavisualisation\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication : s’initier à la communication interculturelle.\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Communication en public	0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
239	R4.07	Expression, communication, culture - 4	Contribution au développement de la ou des compétences ciblées :\nS’informer et informer de manière critique\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel\nCommuniquer de manière adaptée aux situations	S’informer et informer de manière critique et efﬁcace (niveau 2) :\n– Approfondissement des techniques de recherche documentaire (à titre indicatif : veille documentaire universitaire et\nsectorielle)\n– Approfondissement des techniques de rédaction documentaire : lecture et écriture de documents techniques et spé-\ncialisés, respect des normes bibliographiques et bureautiques appliquées à un document, ergonomie d’un document\nnumérique, texte, paratexte, hypertexte, etc.\n– Rédaction de synthèses de documents, typologie des plans (thématique, dialectique et d’aide à la décision, etc)\nAnalyser, comprendre et mobiliser les spéciﬁcités de la communication en contexte professionnel (niveau 2) :\n– Écrits académiques : produire des documents complexes qui répondent aux différentes situations de communication\nuniversitaire (méthodologie du rapport de stage, de projet et de la soutenance)\n– Écrits professionnels (entreprise, presse, web) : rédaction de dossier, d’article de presse grand public / spécialisée, de\ndossier de presse, de communiqué de presse, de revue de presse, de publication corporate, d’écrit pour le web, de\ntweet, de post, d’e-mails, d’article de blog, d’e-book, de brochure web, datavisualisation\nCommuniquer, persuader, interagir (niveau 2) :\n– Analyse de la communication : s’initier à la communication interculturelle.\n– Approfondissement des techniques d’argumentation et de rhétorique et mise en pratique aﬁn de mieux gérer les relations\navec le client, les collaborateurs, etc. (typologie des arguments, preuves techniques, pitch, discours, exposé, débat, etc.)\n– Communication en public	0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
54	R4.08	PPP - 4	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	0		Elaborer l’identité d’une marque, Manager un projet événementiel, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	SME	\N	\N
122	R6.MMPV.03	Droit du travail et relations sociales dans l’entreprise	Contribution au développement de la ou des compétences ciblées :\n– Connaître et gérer la négociation collective dans l’entreprise\n– Savoir déterminer la qualiﬁcation professionnelle et les fonctions exercées : éléments substantiels du contrat de travail\n– Savoir gérer le temps de travail des salariés\n– Gérer les relations avec les délégués du personnel et les délégués syndicaux\n\nMots clés : Temps de travail – convention collective – contrat de travail	– Conventions collectives et accords d’entreprise : négociations obligatoires, négociations libres, accords d’entreprise, etc.\n– Organisation du temps de travail des collaborateurs : temps de travail effectif, temps de travail et temps de repos, règles\ndes heures supplémentaires, travail de nuit et travail des jours fériés\n– Missions et moyens d’actions des délégués du personnel et syndicaux, communication efﬁcace avec les représentants\ndu personnel	0		Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
101	R4.08	PPP - 4	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	0		Manager une équipe commerciale sur un espace de vente, Piloter un espace de vente, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MMPV	\N	\N
147	R4.08	PPP - 4	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	0		Gérer une activité digitale, Développer un projet e-business, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	MDEE	\N	\N
194	R4.08	PPP - 4	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BI	\N	\N
240	R4.08	PPP - 4	Contribution au développement de la ou des compétences ciblées :\nAppréhender les voies et les modalités permettant de réaliser son/ses projet(s) professionnel(s)	Déﬁnir son proﬁl, en partant de ses appétences, de ses envies et asseoir son choix professionnel\n– Approfondir la connaissance de soi tout au long de la sa formation\n– Connaître les modalités d’admission (établissement d’études supérieures et entreprise)\n– S’initier à la veille informationnelle sur un secteur d’activité, une entreprise, les innovations, les technologies, etc.\n– Se familiariser avec les différents métiers possibles en lien avec les parcours proposés\nConstruire un/des projet(s) professionnel(s) en déﬁnissant une stratégie personnelle pour le/les réaliser\n– Identiﬁer les métiers associés au(x) projet(s) professionnel(s)\n– Construire son parcours de formation en adéquation avec son/ses projet(s) professionnel(s) (spécialité et modalité en\nalternance ou initiale, réorientation, internationale, poursuite d’études, insertion professionnelle)\n– Découvrir la pluralité des parcours pour accéder à un métier : poursuite d’études et passerelles en B.U.T.2 et B.U.T.3\n(tant au national qu’à l’international), VAE, formation tout au long de la vie, entrepreneuriat\nAnalyser les métiers envisagés : postes, types d’organisation, secteur, environnement professionnel\n– Appréhender les secteurs professionnels\n– Se familiariser avec les métiers représentatifs du secteur\n– Identiﬁer les métiers possibles en fonction du parcours de B.U.T. choisi\nMettre en place une démarche de recherche de stage et d’alternance et les outils associés\n– Formaliser les acquis personnels et professionnels de l’expérience du stage précédent (connaissance de soi, choix de\ndomaine et de métier/découverte du monde l’entreprise, etc.)\n– Développer une posture professionnelle adaptée\n– Mettre en oeuvre les techniques de recherche de stage ou d’alternance : rechercher une offre, l’analyser, élaborer un\nCV & LM adaptés. Se préparer à l’entretien. Développer une méthodologie de suivi de ses démarches\n– Gérer son identité numérique et sa e-réputation	0		Participer à la stratégie marketing et commerciale de l’organisation, Manager la relation client, Conduire les actions marketing, Vendre une offre commerciale, Communiquer l’offre commerciale	BDMRC	\N	\N
123	R6.MMPV.04	Prise de décision-pilotage	Contribution au développement de la ou des compétences ciblées :\n– Mettre en place des stratégies et tactiques opérationnelles, adaptées et innovantes basées sur une analyse du marché\n– Favoriser l’initiative et la créativité\n– Faire face aux imprévus par des décisions adaptées\n– Savoir se positionner en manager coach – manager formateur\n\nMots clés : Indicateur – tableau de bord – créativité – management	– Création d’indicateurs d’activité qualitatifs et quantitatifs intégrés dans un tableau de bord\n– Adaptation du style de management et du processus de délégation selon des critères objectifs (cible, temps, degré\nd’urgence...)\n– Formation et accompagnement\n– Développement de la créativité pour enrichir les décisions et l’analyse	0		Piloter un espace de vente	MMPV	\N	\N
215	R6.BI.03	Anglais appliqué au business international	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle en adaptant les registres de langue à la situation.\nObjectif :\n– Compréhension d’une intervention longue et complexe dans un contexte professionnel, prise de notes et restitution\n– Compréhension d’articles spécialisés/techniques dans des domaines variés, et réalisation de synthèses\n– Expression spontanée d’idées et de faits en utilisant la langue de manière souple et efﬁcace dans un cadre professionnel\n– Réalisation de présentations organisées, de descriptions claires et détaillées de sujets complexes dans divers domaines\n– Écriture sur des sujets complexes en adaptant le style au destinataire et au type de document (lettre, rapport, compte-\nrendu, essai...)\n\nMots clés : Anglais des affaires – traduction – commerce international	Interpréter les différentes zones culturelles\nTraduire des documents ou des discours suivant les différents types de traduction (consécutive, simultanée) sur des domaines\ntels que la gestion ﬁnancière et commerciale, le marketing, la logistique, les achats et les approvisionnements ou la préparation\nd’une mission import ou export	0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BI	\N	\N
216	R6.BI.04	LVB appliquée au commerce international	Contribution au développement de la ou des compétences ciblées :\nApprofondir les capacités de compréhension orale et écrite, d’expression orale et écrite et d’interactivité en environnement\nprofessionnel international, notamment\n– Se présenter dans un contexte professionnel\n– Présenter une entreprise, son activité, son environnement\n– S’exprimer de façon construite et argumentée dans un contexte professionnel\n– Interagir en situation professionnelle en adaptant les registres de langue à la situation.\nObjectif :\n– Compréhension d’une intervention longue et complexe dans un contexte professionnel, prise de notes et restitution\n– Compréhension d’articles spécialisés/techniques dans des domaines variés, et réalisation de synthèses\n– Expression spontanée d’idées et de faits en utilisant la langue de manière souple et efﬁcace dans un cadre professionnel\n– Réalisation de présentations organisées, de descriptions claires et détaillées de sujets complexes dans divers domaines\n– Écriture sur des sujets complexes en adaptant le style au destinataire et au type de document (lettre, rapport, compte-\nrendu, essai...)\n\nMots clés : Langue vivante – traduction – commerce international	Interpréter les différentes zones culturelles\nTraduire des documents ou des discours suivant les différents types de traduction (consécutive, simultanée) sur des domaines\ntels que la gestion ﬁnancière et commerciale, le marketing, la logistique, les achats et les approvisionnements ou la préparation\nd’une mission import ou export	0		Formuler une stratégie de commerce à l’international, Piloter les opérations à l’international	BDMRC	\N	\N
195	R4.BI.09	Stratégie achats	Contribution au développement de la ou des compétences ciblées :\n– Analyser les stratégies d’achat à l’international des entreprises pour comprendre leurs enjeux et leurs implications dans\nle fonctionnement global de l’entreprise\n\nMots clés : Stratégie et enjeux achats – processus achat – éthique – international	– Identiﬁcation des enjeux achats (matrice de Kraljik, analyse Pareto des fournisseurs, etc)\n– Processus achat adapté aux enjeux : étude des besoins, cahier des charges, sourcing, matrice de sélection, notion de\nclient interne et de fournisseur\n– Politique d’entreprise et politique d’achat\n– Veille achat : cartographie des fournisseurs\n– Éthique et responsabilité de l’acheteur\nCette ressource peut être dispensée en langues étrangères.	0		Formuler une stratégie de commerce à l’international	BI	\N	\N
196	R4.BI.10	Techniques du commerce international - 1	Contribution au développement de la ou des compétences ciblées :\n– Comprendre les règles de l’import-export\n– Connaître les bases pour négocier à l’export\n\nMots clés : Vente – achat – transport – logistique – international	– Les incoterms\n– Transport et logistique à l’international\n– La responsabilité du transporteur et l’assurance transport\n– Introduction aux risques liés aux opérations à l’international\nCette ressource peut être dispensée en langues étrangères.	0		Piloter les opérations à l’international	BI	\N	\N
197	R4.BI.11	Management interculturel	Contribution au développement de la ou des compétences ciblées :\n– Connaitre et comprendre les marchés internationaux en ayant une pratique des habitudes et usages des populations\nconcernées\n– Faciliter la communication, la gestion et l’interaction entre les entreprises qui se développent à l’international et les\ncollaborateurs et acteurs de différentes cultures\n\nMots clés : Management interculturel – gestion des conﬂits – dimensions culturelles – international	– Théories du management interculturel\n– Culture d’entreprise et interculturalité\n– Identiﬁcation des risques de conﬂits interculturels au sein des équipes\n– Analyse des situations conﬂictuelles et proposition de solutions\n– Adaptation du management aux situations interculturelles\nCette ressource peut être dispensée en langues étrangères.	0		Formuler une stratégie de commerce à l’international	BI	\N	\N
259	R6.BDMRC.03	Management des comptes-clés (KAM)	Contribution au développement de la ou des compétences ciblées :\n– Établir un diagnostic et un plan d’action commercial grands comptes\n– Répondre aux appels d’offre des grands clients\n– Négocier des accords proﬁtables avec les grands comptes\n– Acquérir les outils pour co-construire une offre en collaboration avec les partenaires\n\nMots clés : Grand compte – appel d’offre	– Compte clé, grand compte, compte stratégique\n– Rôle et enjeux du manager de comptes-clés\n– Réponses aux appels d’offre	0		Participer à la stratégie marketing et commerciale de l’organisation	BDMRC	\N	\N
260	R6.BDMRC.04	Nouveaux comportements des clients	Contribution au développement de la ou des compétences ciblées :\n– Apprécier l’inﬂuence des usages numériques sur les comportements d’achat\n– Situer les nouveaux rôles du client (client participatif, économie collaborative, communautés de clients...)\n– Identiﬁer les nouvelles tendances de consommation (par exemple consommation équitable, durable, locale, etc.)\n\nMots clés : Client participatif – économie collaborative – communauté de client – consommation équitable – consommation durable –\nconsommation locale	– Usages numériques\n– Tendances de consommation	0		Manager la relation client	BDMRC	\N	\N
77	R6.SME.04	Evènementiel sectoriel	Contribution au développement de la ou des compétences ciblées :\n– Comprendre les spéciﬁcités de l’évènementiel dans les secteurs ci-dessous (suivant adaptation locale)\n– Organiser des évènements éco-responsables\n\nMots clés : Evènementiel sportif – évènementiel culturel – évènementiel d’entreprise – développement durable	– Spéciﬁcités techniques, juridiques et organisationnelles de l’évènementiel culturel / sportif / tourisme d’affaires : congrès,\nfoires, salons...\n– Organisation d’événements éco-responsables : les enjeux de l’éco-responsabilité dans l’événementiel, mesure de l’im-\npact environnemental d’un évènement, actions permettant de réduire l’empreinte environnementale d’un évènement	0		Manager un projet événementiel	SME	\N	\N
55	R4.SME.09	Relations publiques et relations presse	Contribution au développement de la ou des compétences ciblées :\n– Savoir replacer les opérations de relations publiques (RP) et relations presse dans la stratégie de communication et en\nrapport avec les objectifs et cibles visés\n– Savoir déﬁnir et rédiger des supports de RP et relations presse : communiqué de presse, dossier de presse, message\nsur les différents réseaux sociaux\n– Connaître les attentes des journalistes, leaders d’opinion et inﬂuenceurs, comment entrer en contact et interagir efﬁca-\ncement avec eux\n– Savoir évaluer l’impact et l’efﬁcacité de cette stratégie et des outils mobilisés\n\nMots clés : Relations publiques (RP) – relations presse – relations médias – communication d’inﬂuence – inﬂuenceurs – éléments de\nlangage		0		Elaborer l’identité d’une marque	SME	\N	\N
56	R4.SME.10	Organisation et logistique - 1	Contribution au développement de la ou des compétences) ciblées :\n– Comprendre les enjeux de la logistique évènementielle et les outils de base\n– Organiser et planiﬁer le projet\n– Gérer le budget alloué\n– Respecter le cadre juridique propre à l’organisation d’un évènement simple\n\nMots clés : Cahier des charges – budget prévisionnel – logistique événementielle – droit événementiel	Gestion de projet : utilisation des outils de gestion de projet, rédaction d’un cahier des charges d’un évènement simple, check-\nlist, rétroplanning, répartition des tâches\nGestion budgétaire : construction d’un budget prévisionnel simple (charges/produit, ventilation par poste). Présentation et ana-\nlyse d’un budget prévisionnel\nLogistique : déﬁnir une logistique en cohérence avec l’identité de la marque organisateur (choix du lieu et des prestataires...) et\ndu budget, établissement des besoins (restauration, sonorisation, effets lumineux, stationnement, signalisation, installation et\ntest du matériel). Utilisation ou création d’outils simples (excel) de réservation de salles, hôtels, transports\nDroit : contrat de cession de spectacle, contrat d’engagement (statut intermittent), contrat de travail pour l’évènement (CDD),\nconvention de location de salle, manifestation avec fond sonore (sacem), contrat de partenariat	0		Manager un projet événementiel	SME	\N	\N
57	R4.SME.11	Gestion commerciale - 1	Contribution au développement de la ou des compétences ciblées :\n– Gérer les relations avec les prestataires de l’évènementiel\n– Négocier avec les fournisseurs, prestataires et autres partenaires de l’évènementiel\n– Connaître les logiciels existants et leurs fonctionnalités / maîtriser quelques outils simples d’inscription\n\nMots clés : Achat – prestataires – gestion des inscriptions	– Achat, relations, négociation avec les prestataires : déﬁnition du besoin, analyse du marché et des fournisseurs et\nprestataires / sélection des prestataires\n– Négociation\n– Gestion des inscriptions : utilisation d’outils simples pour gérer les inscriptions d’un événement de taille réduite	0		Manager un projet événementiel	SME	\N	\N
102	R4.MMPV.09	Merchandising	Maitriser les techniques d’allocation de l’espace et d’implantation des produits : circulation, organisation d’un rayon et d’un point de vente. Connaître les critères de construction de l’assortiment. Utiliser les objectifs et les composantes de la communication sur le lieu de vente pour optimiser les performances. Comprendre l’impact de l’atmosphère du point de vente.\n\nMots clés : Assortiment – implantation de rayon – communication – atmosphère	Analyse d’un plan de masse, zoning. Construction et implantation d’un plan de merchandising déﬁni par le réseau ou par l’équipe de vente. Communication sur le lieu de vente : SLV, ILV, PLV. Atmosphère du point de vente : le design (éclairage, son, matières, couleurs, mobilier). Calcul et utilisation des indices de sensibilité.	0		Piloter un espace de vente	MMPV	\N	\N
103	R4.MMPV.10	Management des équipes - 1	Comprendre le fonctionnement d’une équipe commerciale : spécificité des métiers, organisation de l’équipe de vente, organisation du travail. Comprendre les principes du management d’une équipe : principaux leviers. Organiser et planifier les tâches de l’équipe.\n\nMots clés : dynamique de groupe – planification – communication interne	Conception et mise en place de l’organisation humaine de l’unité de vente (planning, inventaire...). Management d’une équipe (informer, dynamiser, motiver...) en s’appuyant sur une dynamique de groupe. Organisation et suivi de l’activité de l’équipe de vente : appui technique. Communication en interne (réunions, notes, directives...) et transmission des informations.	0		Manager une équipe commerciale sur un espace de vente	MMPV	\N	\N
104	R4.MMPV.11	GRC	Personnaliser la relation client en appliquant les principes de base de la GRC. Mesurer la satisfaction client pour l’optimiser. Mettre en place des stratégies de fidélisation. Gérer la diversité des parcours et des points de contact avec le client. Intégrer la relation avec les centrales d’achat.\n\nMots clés : Fidélisation – satisfaction – points de contact – KPI	Gestion de l’animation commerciale du point de vente ou du rayon : présentations/démonstrations de produit, conseils personnalisés, services complémentaires. Définition des objectifs de vente en cohérence avec les actions. Analyse des comportements du client et des points de contact (omnicanalité). Utilisation de KPI pour mesurer l’efficacité.	0		Piloter un espace de vente	MMPV	\N	\N
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
36	21
36	38
36	33
36	45
36	7
37	37
37	23
37	6
37	8
37	33
37	24
38	34
38	23
38	21
38	8
38	48
38	45
38	47
39	5
39	7
40	35
40	32
40	34
40	23
40	6
40	38
40	8
40	22
40	33
40	19
40	20
40	39
40	5
40	24
40	46
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
42	37
42	23
42	6
42	22
42	48
42	47
43	35
43	32
43	34
43	6
43	38
43	22
43	19
43	20
43	39
43	5
43	46
43	7
44	35
44	8
44	22
44	24
44	7
44	32
44	37
44	23
44	38
44	33
44	44
44	19
44	20
44	39
44	46
44	21
44	6
44	45
44	47
44	36
44	34
44	48
44	5
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
58	11
58	9
59	26
59	27
60	40
60	41
60	10
60	9
60	49
60	42
60	12
61	12
61	50
61	26
61	10
62	11
62	53
62	27
63	43
63	27
63	11
63	25
63	12
64	43
64	27
64	11
64	25
64	12
65	27
65	43
65	10
65	9
65	42
65	51
65	12
66	52
66	26
66	27
66	43
66	40
66	41
66	50
66	53
66	10
66	9
66	11
66	49
66	25
66	42
66	51
66	12
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
82	6
82	7
83	35
83	32
83	62
83	21
83	33
83	65
83	7
84	23
84	6
84	8
84	33
84	54
84	24
85	34
85	23
85	21
85	8
85	63
85	54
86	55
86	5
86	56
86	7
87	35
87	32
87	34
87	23
87	62
87	6
87	64
87	8
87	22
87	33
87	55
87	19
87	20
87	5
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
89	62
89	23
89	6
89	22
89	55
89	56
89	65
90	35
90	32
90	34
90	62
90	64
90	6
90	22
90	55
90	19
90	20
90	5
90	7
91	35
91	8
91	22
91	65
91	24
91	62
91	32
91	7
91	23
91	64
91	66
91	33
91	55
91	56
91	19
91	20
91	54
91	21
91	6
91	63
91	34
91	5
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
105	11
105	9
106	26
106	27
107	57
107	67
107	10
107	9
107	12
108	12
108	67
108	26
108	10
109	11
109	27
109	57
110	27
110	11
110	69
110	25
110	68
110	60
110	12
111	27
111	11
111	69
111	25
111	68
111	60
111	12
112	27
112	10
112	9
112	58
112	68
112	12
113	26
113	27
113	57
113	59
113	61
113	67
113	10
113	9
113	11
113	69
113	25
113	58
113	72
113	71
113	70
113	68
113	60
113	12
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
128	84
128	76
128	6
128	7
129	35
129	32
129	74
129	21
129	33
129	76
129	7
130	23
130	6
130	8
130	33
130	83
130	24
131	34
131	23
131	21
131	8
131	85
131	73
131	86
131	83
132	5
132	7
133	35
133	32
133	34
133	23
133	74
133	6
133	75
133	8
133	22
133	88
133	33
133	19
133	20
133	5
133	84
133	24
133	7
134	35
134	32
134	34
134	23
134	6
134	8
134	22
134	33
134	19
134	20
134	5
134	24
134	7
135	35
135	34
135	74
135	23
135	87
135	6
135	22
135	88
135	73
135	76
136	35
136	32
136	34
136	74
136	6
136	75
136	22
136	88
136	19
136	20
136	5
136	84
136	7
137	35
137	8
137	22
137	76
137	24
137	7
137	32
137	23
137	33
137	19
137	20
137	83
137	84
137	21
137	6
137	87
137	88
137	73
137	86
137	77
137	74
137	34
137	75
137	85
137	5
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
151	11
151	9
152	26
152	27
153	12
153	89
153	10
153	9
154	12
154	89
154	26
154	10
155	11
155	91
155	89
155	27
156	27
156	11
156	25
156	94
156	12
156	79
157	27
157	11
157	25
157	94
157	12
157	79
158	27
158	80
158	10
158	9
158	12
158	79
159	90
159	26
159	27
159	81
159	80
159	91
159	93
159	89
159	92
159	10
159	9
159	11
159	25
159	78
159	94
159	82
159	12
159	79
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
175	97
175	95
175	6
175	7
176	35
176	32
176	21
176	33
176	7
177	23
177	6
177	8
177	33
177	24
178	34
178	23
178	21
178	8
178	103
179	5
179	7
180	35
180	32
180	34
180	23
180	6
180	8
180	22
180	96
180	33
180	19
180	101
180	20
180	5
180	104
180	24
180	7
181	35
181	32
181	34
181	23
181	6
181	8
181	22
181	96
181	33
181	19
181	101
181	20
181	5
181	104
181	24
181	7
182	35
182	34
182	23
182	6
182	102
182	22
182	95
182	96
182	101
183	35
183	32
183	34
183	6
183	22
183	96
183	19
183	20
183	5
183	104
183	7
184	35
184	102
184	8
184	22
184	96
184	101
184	24
184	7
184	32
184	23
184	97
184	95
184	33
184	19
184	20
184	21
184	6
184	103
184	104
184	34
184	5
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
198	11
198	9
199	26
199	27
200	100
200	10
200	9
200	98
200	99
200	12
201	12
201	26
201	107
201	10
202	11
202	98
202	27
203	27
203	105
203	11
203	99
203	25
203	12
204	27
204	105
204	11
204	99
204	25
204	12
205	27
205	105
205	10
205	9
205	99
205	12
206	26
206	27
206	105
206	100
206	107
206	10
206	9
206	11
206	98
206	99
206	25
206	106
206	108
206	12
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
256	9
256	11
256	115
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
-- Data for Name: systemconfig; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public.systemconfig (id, key, value, category) FROM stdin;
1	ldap_url	ldap://ldap:389	ldap
2	ldap_base_dn	dc=univ,dc=fr	ldap
3	smtp_host	mail	mail
4	smtp_port	1025	mail
6	APP_LOGO_URL	https://www-iut.univ-lehavre.fr/wp-content/uploads/2024/12/cropped-logo-IUT_WEB-5-3.png	branding
7	APP_PRIMARY_COLOR	#1971c2	branding
8	APP_WELCOME_MESSAGE	Bienvenue sur Skills Hub	branding
5	mistral_api_key	3a218ppqAlBzjegiqPSu3JF0c8krF5fo	ai
12	ai_api_key	3a218ppqAlBzjegiqPSu3JF0c8krF5fo	ai
9	ai_provider	codestral	ai
10	ai_model	codestral-latest	ai
11	ai_endpoint	https://codestral.mistral.ai/v1	ai
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: app_user
--

COPY public."user" (id, ldap_uid, email, full_name, role, group_id) FROM stdin;
1	emma.dupont78	emma.dupont78@etu.univ.fr	Emma DUPONT	GUEST	\N
2	marie.moreau93	marie.moreau93@etu.univ.fr	Marie MOREAU	GUEST	\N
3	nicolas.dupont87	nicolas.dupont87@etu.univ.fr	Nicolas DUPONT	GUEST	\N
18	marie.simon28	marie.simon28@etu.univ.fr	Marie SIMON	GUEST	\N
50	bl251857	lucie.ba@etu.univ-lehavre.fr	Lucie Ba	STUDENT	62
51	bf252370	feinda.bakhayokho@etu.univ-lehavre.fr	Feinda Bakhayokho	STUDENT	62
54	bj250155	jalil.bel-imam--letellier@etu.univ-lehavre.fr	Jalil Bel imam--letellier	STUDENT	63
210	gt231116	thomas.godard@etu.univ-lehavre.fr	Thomas Godard	STUDENT	69
53	bc252577	clemence.beauchamps--jeanne@etu.univ-lehavre.fr	Clemence Beauchamps--jeanne	STUDENT	64
55	bl252505	lehna.benslimane@etu.univ-lehavre.fr	Lehna Benslimane	STUDENT	63
44	ar251429	riad.aissaoui@etu.univ-lehavre.fr	Riad Aissaoui	STUDENT	60
60	bn250395	nathan-david.bothorel@etu.univ-lehavre.fr	Nathan-david Bothorel	STUDENT	61
47	an241357	nellyna.audal--frovil@etu.univ-lehavre.fr	Nellyna Audal--frovil	STUDENT	61
48	al252868	lalie.audouard@etu.univ-lehavre.fr	Lalie Audouard	STUDENT	61
211	gr232671	raphaelle.grieu@etu.univ-lehavre.fr	Raphaelle Grieu	STUDENT	68
52	bk252733	kadiatou.balde@etu.univ-lehavre.fr	Kadiatou Balde	STUDENT	63
215	ky220837	yah.kouame-schmidt@etu.univ-lehavre.fr	Yah Kouame-schmidt	STUDENT	68
220	ll232815	lena.lefevre@etu.univ-lehavre.fr	Lena Lefevre	STUDENT	68
56	bi250967	iliana.bensmaine@etu.univ-lehavre.fr	Iliana Bensmaine	STUDENT	63
242	ao242575	olasubomi.adeniyi@etu.univ-lehavre.fr	Olasubomi Adeniyi	STUDENT	71
49	ad251637	dorine.avenel@etu.univ-lehavre.fr	Dorine Avenel	STUDENT	62
57	br250653	rossana.bettencourt-da-silva-carvalho@etu.univ-lehavre.fr	Rossana Bettencourt da silva carvalho	STUDENT	60
58	bn252938	noe.bloino@etu.univ-lehavre.fr	Noe Bloino	STUDENT	63
61	bj252564	joris.bouchez@etu.univ-lehavre.fr	Joris Bouchez	STUDENT	63
59	bm250979	mila.bonnet@etu.univ-lehavre.fr	Mila Bonnet	STUDENT	64
199	ca211054	antonin.chapelle@etu.univ-lehavre.fr	Antonin Chapelle	STUDENT	66
203	dl230848	leo.delozier@etu.univ-lehavre.fr	Leo Delozier	STUDENT	66
204	dj231904	justine.deschamps@etu.univ-lehavre.fr	Justine Deschamps	STUDENT	66
4	emma.martin16	emma.martin16@etu.univ.fr	Emma MARTIN	GUEST	\N
5	jean.roux79	jean.roux79@etu.univ.fr	Jean ROUX	GUEST	\N
6	sophie.petit89	sophie.petit89@etu.univ.fr	Sophie PETIT	GUEST	\N
7	nicolas.martin13	nicolas.martin13@etu.univ.fr	Nicolas MARTIN	GUEST	\N
8	nicolas.lefebvre43	nicolas.lefebvre43@etu.univ.fr	Nicolas LEFEBVRE	GUEST	\N
9	emma.roux34	emma.roux34@etu.univ.fr	Emma ROUX	GUEST	\N
10	julie.durand50	julie.durand50@etu.univ.fr	Julie DURAND	GUEST	\N
11	marie.simon14	marie.simon14@etu.univ.fr	Marie SIMON	GUEST	\N
12	jean.dupont98	jean.dupont98@etu.univ.fr	Jean DUPONT	GUEST	\N
13	emma.petit57	emma.petit57@etu.univ.fr	Emma PETIT	GUEST	\N
14	antoine.dupont29	antoine.dupont29@etu.univ.fr	Antoine DUPONT	GUEST	\N
20	nicolas.garcia31	nicolas.garcia31@etu.univ.fr	Nicolas GARCIA	GUEST	\N
21	marie.garcia70	marie.garcia70@etu.univ.fr	Marie GARCIA	GUEST	\N
22	julie.dupont12	julie.dupont12@etu.univ.fr	Julie DUPONT	GUEST	\N
23	jean.dupont30	jean.dupont30@etu.univ.fr	Jean DUPONT	GUEST	\N
24	antoine.dupont82	antoine.dupont82@etu.univ.fr	Antoine DUPONT	GUEST	\N
25	nicolas.simon43	nicolas.simon43@etu.univ.fr	Nicolas SIMON	GUEST	\N
26	lucas.martin68	lucas.martin68@etu.univ.fr	Lucas MARTIN	GUEST	\N
27	emma.roux10	emma.roux10@etu.univ.fr	Emma ROUX	GUEST	\N
28	sophie.lefebvre61	sophie.lefebvre61@etu.univ.fr	Sophie LEFEBVRE	GUEST	\N
29	pierre.lefebvre22	pierre.lefebvre22@etu.univ.fr	Pierre LEFEBVRE	GUEST	\N
30	julie.lefebvre86	julie.lefebvre86@etu.univ.fr	Julie LEFEBVRE	GUEST	\N
31	sophie.lefebvre55	sophie.lefebvre55@etu.univ.fr	Sophie LEFEBVRE	GUEST	\N
32	thomas.moreau97	thomas.moreau97@etu.univ.fr	Thomas MOREAU	GUEST	\N
33	marie.petit63	marie.petit63@etu.univ.fr	Marie PETIT	GUEST	\N
34	emma.garcia95	emma.garcia95@etu.univ.fr	Emma GARCIA	GUEST	\N
35	jean.dupont60	jean.dupont60@etu.univ.fr	Jean DUPONT	GUEST	\N
15	sophie.simon48	sophie.simon48@etu.univ.fr	Sophie SIMON	GUEST	\N
16	marie.leroy81	marie.leroy81@etu.univ.fr	Marie LEROY	GUEST	\N
17	pierre.durand11	pierre.durand11@etu.univ.fr	Pierre DURAND	GUEST	\N
19	antoine.durand10	antoine.durand10@etu.univ.fr	Antoine DURAND	GUEST	\N
209	gg253671	godwin-alphonse.gninevi@etu.univ-lehavre.fr	Godwin alphonse Gninevi	STUDENT	67
212	jj231322	janelle.jacq-bonnechere@etu.univ-lehavre.fr	Janelle Jacq--bonnechere	STUDENT	68
213	kc231261	camelia.kadi@etu.univ-lehavre.fr	Camelia Kadi	STUDENT	68
214	kr231780	romane.kiehl@etu.univ-lehavre.fr	Romane Kiehl	STUDENT	69
217	lq231372	quentin.landemaine@etu.univ-lehavre.fr	Quentin Landemaine	STUDENT	69
221	lj230616	jade.lehodey@etu.univ-lehavre.fr	Jade Lehodey	STUDENT	69
245	an240751	nathan.annest-dur@etu.univ-lehavre.fr	Nathan Annest-dur	STUDENT	73
250	bv241118	valere.beauvais@etu.univ-lehavre.fr	Valere Beauvais	STUDENT	71
254	bm242285	marius.bride@etu.univ-lehavre.fr	Marius Bride	STUDENT	74
259	cq242200	quentin.chaumont@etu.univ-lehavre.fr	Quentin Chaumont	STUDENT	73
264	ci240770	ines.crespin@etu.univ-lehavre.fr	Ines Crespin	STUDENT	73
269	dl241212	lola.ducastel@etu.univ-lehavre.fr	Lola Ducastel	STUDENT	73
36	prof.1	prof.1@univ-lehavre.fr	Prof1 PROFESSEUR1	GUEST	\N
37	prof.2	prof.2@univ-lehavre.fr	Prof2 PROFESSEUR2	GUEST	\N
38	prof.3	prof.3@univ-lehavre.fr	Prof3 PROFESSEUR3	GUEST	\N
39	prof.4	prof.4@univ-lehavre.fr	Prof4 PROFESSEUR4	GUEST	\N
40	prof.5	prof.5@univ-lehavre.fr	Prof5 PROFESSEUR5	GUEST	\N
41	prof.6	prof.6@univ-lehavre.fr	Prof6 PROFESSEUR6	GUEST	\N
42	prof.7	prof.7@univ-lehavre.fr	Prof7 PROFESSEUR7	GUEST	\N
227	mh230864	hubercia.massamba@etu.univ-lehavre.fr	Hubercia Massamba	STUDENT	67
228	mk220329	kamelia.mouaoued@etu.univ-lehavre.fr	Kamelia Mouaoued	STUDENT	66
229	oc243330	christianne.ogoe@etu.univ-lehavre.fr	Christianne Ogoe	STUDENT	66
230	ov233784	viktoriia.ohirko@etu.univ-lehavre.fr	Viktoriia Ohirko	STUDENT	66
231	ps231658	selena.peter@etu.univ-lehavre.fr	Selena Peter	STUDENT	66
301	ms232231	sanaa.mekkaoui@etu.univ-lehavre.fr	Sanaa Mekkaoui	STUDENT	73
232	pa230715	achille.plaisant@etu.univ-lehavre.fr	Achille Plaisant	STUDENT	66
233	sl233501	laura.salmi@etu.univ-lehavre.fr	Laura Salmi	STUDENT	66
234	sa230921	aida.seye@etu.univ-lehavre.fr	Aida Seye	STUDENT	68
304	ma242522	aurelien.monnier@etu.univ-lehavre.fr	Aurelien Monnier	STUDENT	71
235	sj231750	justine.sigogne@etu.univ-lehavre.fr	Justine Sigogne	STUDENT	69
237	ta231912	alice.teissere@etu.univ-lehavre.fr	Alice Teissere	STUDENT	69
238	ts231183	selen.topcu@etu.univ-lehavre.fr	Selen Topcu	STUDENT	68
239	vo224060	oleksandr.vusatyi@etu.univ-lehavre.fr	Oleksandr Vusatyi	STUDENT	66
306	nc240702	chaima.naamane@etu.univ-lehavre.fr	Chaima Naamane	STUDENT	72
309	pm242800	matheo.planoudis@etu.univ-lehavre.fr	Matheo Planoudis	STUDENT	73
311	qi241652	ines.quesada@etu.univ-lehavre.fr	Ines Quesada	STUDENT	72
314	se241209	elif.sagir@etu.univ-lehavre.fr	Elif Sagir	STUDENT	73
316	sc242837	carla.signour@etu.univ-lehavre.fr	Carla Signour	STUDENT	72
319	va222409	apolline.vergneault@etu.univ-lehavre.fr	Apolline Vergneault	STUDENT	74
240	zc211044	chaima.zeggai@etu.univ-lehavre.fr	Chaima Zeggai	STUDENT	66
321	wg241458	garance.wawrzyniak@etu.univ-lehavre.fr	Garance Wawrzyniak	STUDENT	74
325	dl231710	lea.dechamps@etu.univ-lehavre.fr	Lea Dechamps	STUDENT	76
328	le241962	eve-lenig.le-mouel@etu.univ-lehavre.fr	Eve-lenig Le mouel	STUDENT	76
62	ba252385	anouk.breton@etu.univ-lehavre.fr	Anouk Breton	STUDENT	63
241	zs231744	sara.zermane@etu.univ-lehavre.fr	Sara Zermane	STUDENT	66
243	aj240990	jade-mahite.alves@etu.univ-lehavre.fr	Jade - mahite Alves	STUDENT	72
63	bg251631	gabriel.bunel@etu.univ-lehavre.fr	Gabriel Bunel	STUDENT	60
66	ck250680	kahina.chabbi@etu.univ-lehavre.fr	Kahina Chabbi	STUDENT	64
330	rl241373	lilou.rioult@etu.univ-lehavre.fr	Lilou Rioult	STUDENT	76
333	an231349	naim.asselin@etu.univ-lehavre.fr	Naim Asselin	STUDENT	77
67	cm252766	marwane.chanaoui@etu.univ-lehavre.fr	Marwane Chanaoui	STUDENT	60
247	ak253272	kossi-mawuto-guy.azonhouto@etu.univ-lehavre.fr	Kossi mawuto guy Azonhouto	STUDENT	72
68	cs252698	selim.chati@etu.univ-lehavre.fr	Selim Chati	STUDENT	59
70	ca250685	alizarine.cherriere@etu.univ-lehavre.fr	Alizarine Cherriere	STUDENT	59
71	ce251389	esra.chtioui@etu.univ-lehavre.fr	Esra Chtioui	STUDENT	62
72	cs250840	sarta.cissoko@etu.univ-lehavre.fr	Sarta Cissoko	STUDENT	61
256	cl240415	lea.calais@etu.univ-lehavre.fr	Lea Calais	STUDENT	73
74	cm242178	mathys.couture@etu.univ-lehavre.fr	Mathys Couture	STUDENT	63
75	dd252233	davina.dassi-momo@etu.univ-lehavre.fr	Davina Dassi momo	STUDENT	63
336	dy230579	yasmine.drici@etu.univ-lehavre.fr	Yasmine Drici	STUDENT	78
337	ej231718	jade.esnault@etu.univ-lehavre.fr	Jade Esnault	STUDENT	77
261	cl242750	lilou.coquin@etu.univ-lehavre.fr	Lilou Coquin	STUDENT	73
266	dl241089	lisa.della-casa@etu.univ-lehavre.fr	Lisa Della casa	STUDENT	74
271	es240531	shaima.el-bazze@etu.univ-lehavre.fr	Shaima El bazze	STUDENT	72
76	de252748	elouan.de-kerliviou@etu.univ-lehavre.fr	Elouan De kerliviou	STUDENT	64
274	gc241716	carla.garnier@etu.univ-lehavre.fr	Carla Garnier	STUDENT	72
77	da252730	aissata.deh1@etu.univ-lehavre.fr	Aissata Deh	STUDENT	60
276	hj242566	jade.haugomat@etu.univ-lehavre.fr	Jade Haugomat	STUDENT	74
279	js242223	salome.jassak@etu.univ-lehavre.fr	Salome Jassak	STUDENT	72
281	ka240442	alisya.kilic@etu.univ-lehavre.fr	Alisya Kilic	STUDENT	73
284	lg240913	garance.langlois@etu.univ-lehavre.fr	Garance Langlois	STUDENT	71
286	lz241599	zoe.le-moal@etu.univ-lehavre.fr	Zoe Le moal	STUDENT	73
289	lm241655	matheo.lefebvre@etu.univ-lehavre.fr	Matheo Lefebvre	STUDENT	72
291	ld242109	diego.leite-goncalves@etu.univ-lehavre.fr	Diego Leite gonçalves	STUDENT	72
294	lf242599	faustine.letellier@etu.univ-lehavre.fr	Faustine Letellier	STUDENT	72
78	df241325	frederique.dehais@etu.univ-lehavre.fr	Frederique Dehais	STUDENT	61
79	dm252979	mansour-yatou.demba@etu.univ-lehavre.fr	Mansour-yatou Demba	STUDENT	60
81	da250807	allyna.deschamps@etu.univ-lehavre.fr	Allyna Deschamps	STUDENT	63
82	dl250475	luka.desweemer@etu.univ-lehavre.fr	Luka Desweemer	STUDENT	61
187	as230483	sarah.aubourg@etu.univ-lehavre.fr	Sarah Aubourg	STUDENT	66
216	ky233536	yuliia.kravchuk@etu.univ-lehavre.fr	Yuliia Kravchuk	STUDENT	66
222	ls231884	simon.lemesle@etu.univ-lehavre.fr	Simon Lemesle	STUDENT	66
223	li231682	ilona.lepiller@etu.univ-lehavre.fr	Ilona Lepiller	STUDENT	67
224	le231208	eliot.levasseur@etu.univ-lehavre.fr	Eliot Levasseur	STUDENT	68
225	ma221128	anais.macedo-coelho@etu.univ-lehavre.fr	Anais Macedo coelho	STUDENT	67
226	ma232161	arthur.marie-olive@etu.univ-lehavre.fr	Arthur Marie-olive	STUDENT	68
296	lm242931	mathias.liaigre--grenet@etu.univ-lehavre.fr	Mathias Liaigre grenet	STUDENT	71
299	me240380	ethan.mauranges@etu.univ-lehavre.fr	Ethan Mauranges	STUDENT	72
341	ll232087	lucas.laville@etu.univ-lehavre.fr	Lucas Laville	STUDENT	77
342	la230535	anaelle.legrand@etu.univ-lehavre.fr	Anaelle Legrand	STUDENT	77
346	oc230995	carla.olivier@etu.univ-lehavre.fr	Carla Olivier	STUDENT	77
347	qb231188	baptiste.quintino@etu.univ-lehavre.fr	Baptiste Quintino	STUDENT	77
351	rm232117	maelys.rustuel@etu.univ-lehavre.fr	Maelys Rustuel	STUDENT	78
352	sm232141	malik.soret@etu.univ-lehavre.fr	Malik Soret	STUDENT	79
277	ha241438	agathe.huberson@etu.univ-lehavre.fr	Agathe Huberson	STUDENT	73
282	km242841	mathys.kong-sinh@etu.univ-lehavre.fr	Mathys Kong-sinh	STUDENT	73
287	ll243139	lola.lecanu@etu.univ-lehavre.fr	Lola Lecanu	STUDENT	71
292	ll242125	laurette.lelong@etu.univ-lehavre.fr	Laurette Lelong	STUDENT	74
297	ly241097	yanis.loubes@etu.univ-lehavre.fr	Yanis Loubes	STUDENT	71
302	ml222490	lorry.mhayerenge@etu.univ-lehavre.fr	Lorry Mhayerenge	STUDENT	72
307	oa242204	asma.ouchamhou@etu.univ-lehavre.fr	Asma Ouchamhou	STUDENT	72
308	oa240740	arthur.ouvry@etu.univ-lehavre.fr	Arthur Ouvry	STUDENT	74
43	am252995	massound-omar.abdillah-said@etu.univ-lehavre.fr	Massound-omar Abdillah said	STUDENT	59
45	as253032	shayna.aksouh@etu.univ-lehavre.fr	Shayna Aksouh	STUDENT	59
46	aa253702	abdelhak-yanis.amiche@etu.univ-lehavre.fr	Abdelhak yanis Amiche	STUDENT	59
64	cl252396	loane.camara@etu.univ-lehavre.fr	Loane Camara	STUDENT	63
65	ca253867	adrien.carluer@etu.univ-lehavre.fr	Adrien Carluer	STUDENT	63
69	ch251397	hajar.cherraj@etu.univ-lehavre.fr	Hajar Cherraj	STUDENT	63
73	cm252920	madyson.cousin@etu.univ-lehavre.fr	Madyson Cousin	STUDENT	59
80	di253062	imane.dembele@etu.univ-lehavre.fr	Imane Dembele	STUDENT	59
83	de252254	el-hadj-hamidou.diaw@etu.univ-lehavre.fr	El hadj hamidou Diaw	STUDENT	60
84	dm251391	malik.djalout@etu.univ-lehavre.fr	Malik Djalout	STUDENT	60
85	dl254035	louisa.djemel@etu.univ-lehavre.fr	Louisa Djemel	STUDENT	59
86	dm251421	melissa.douay@etu.univ-lehavre.fr	Melissa Douay	STUDENT	63
87	dc250695	chloe.dubuc@etu.univ-lehavre.fr	Chloe Dubuc	STUDENT	60
185	am232477	munahil.ashaq@etu.univ-lehavre.fr	Munahil Ashaq	STUDENT	67
312	rg241719	gauthier.reaux@etu.univ-lehavre.fr	Gauthier Reaux	STUDENT	71
313	ri240698	isaac.renault@etu.univ-lehavre.fr	Isaac Renault	STUDENT	73
317	sa242321	aysen.son@etu.univ-lehavre.fr	Aysen Son	STUDENT	73
318	te240919	elena.theodat@etu.univ-lehavre.fr	Elena Theodat	STUDENT	72
322	ys241058	sacha.yalaoui@etu.univ-lehavre.fr	Sacha Yalaoui	STUDENT	71
323	yh240936	herro.yamanda@etu.univ-lehavre.fr	Herro Yamanda	STUDENT	71
326	gv230592	victor.guille@etu.univ-lehavre.fr	Victor Guille	STUDENT	76
331	tn242196	nathan.targy@etu.univ-lehavre.fr	Nathan Targy	STUDENT	76
334	bs231843	sacha.blondel@etu.univ-lehavre.fr	Sacha Blondel	STUDENT	78
338	gc230480	cloe.gosset@etu.univ-lehavre.fr	Cloe Gosset	STUDENT	79
343	ls232085	salome.leveque@etu.univ-lehavre.fr	Salome Leveque	STUDENT	77
348	rh231863	hugo.reynier@etu.univ-lehavre.fr	Hugo Reynier	STUDENT	77
186	aa243443	ayawo-phillippe.attissogan@etu.univ-lehavre.fr	Ayawo phillippe Attissogan	STUDENT	67
188	bl231274	lou.baudry@etu.univ-lehavre.fr	Lou Baudry	STUDENT	68
189	bs231961	samy.beghoura@etu.univ-lehavre.fr	Samy Beghoura	STUDENT	68
190	bm231784	mathieu.bernard@etu.univ-lehavre.fr	Mathieu Bernard	STUDENT	67
353	tm230204	marion.tisserand@etu.univ-lehavre.fr	Marion Tisserand	STUDENT	77
356	ze230272	emilien.zwisler@etu.univ-lehavre.fr	Emilien Zwisler	STUDENT	77
191	bc230951	clemence.bostyn@etu.univ-lehavre.fr	Clemence Bostyn	STUDENT	69
360	tv243830	vianney.tsiba-ngami@etu.univ-lehavre.fr	Vianney Tsiba ngami	GUEST	\N
192	bn232234	naelya.boulard-diallo@etu.univ-lehavre.fr	Naelya Boulard-diallo	STUDENT	68
194	bl230128	luis-samuel.branco@etu.univ-lehavre.fr	Luis samuel Branco	STUDENT	68
196	cf232016	florian.caciotti@etu.univ-lehavre.fr	Florian Caciotti	STUDENT	69
197	cl230297	lou.cartier@etu.univ-lehavre.fr	Lou Cartier	STUDENT	68
200	dj231257	jade.daubeuf@etu.univ-lehavre.fr	Jade Daubeuf	STUDENT	69
201	dr232304	raphael.david@etu.univ-lehavre.fr	Raphael David	STUDENT	68
202	da231203	axel.delamare@etu.univ-lehavre.fr	Axel Delamare	STUDENT	68
205	dt231021	timothee.desmons@etu.univ-lehavre.fr	Timothee Desmons	STUDENT	68
206	dy231946	yanis.dubuc--jouanne@etu.univ-lehavre.fr	Yanis Dubuc--jouanne	STUDENT	68
208	fa231554	adelie.feron@etu.univ-lehavre.fr	Adelie Feron	STUDENT	69
244	am240383	mathilda.aly-stervinou@etu.univ-lehavre.fr	Mathilda Aly-stervinou	STUDENT	72
248	bl242248	lola.batista-gomes@etu.univ-lehavre.fr	Lola Batista gomes	STUDENT	71
252	bl241160	louis.belland@etu.univ-lehavre.fr	Louis Belland	STUDENT	74
257	ca240983	aminata.camara@etu.univ-lehavre.fr	Aminata Camara	STUDENT	72
262	ct241585	timothe.costantin@etu.univ-lehavre.fr	Timothe Costantin	STUDENT	71
267	dp240224	paul.depoix@etu.univ-lehavre.fr	Paul Depoix	STUDENT	72
272	ea242990	adam.elouaid@etu.univ-lehavre.fr	Adam Elouaid	STUDENT	71
123	lm252399	marilou.lebrument@etu.univ-lehavre.fr	Marilou Lebrument	STUDENT	61
193	br231059	raika.boura@etu.univ-lehavre.fr	Raika Boura	STUDENT	66
195	bt222383	theo.broust@etu.univ-lehavre.fr	Theo Broust	STUDENT	66
93	fp250049	pierre.fouillet@etu.univ-lehavre.fr	Pierre Fouillet	STUDENT	63
94	gi251885	ismael.gerard@etu.univ-lehavre.fr	Ismael Gerard-depetris	STUDENT	61
95	gl252149	lily.geretto@etu.univ-lehavre.fr	Lily Geretto	STUDENT	63
198	cr230418	raphael.chanvallon@etu.univ-lehavre.fr	Raphael Chanvallon	STUDENT	66
246	am240684	manon.auger@etu.univ-lehavre.fr	Manon Auger	STUDENT	73
251	bv241130	victor.becquet@etu.univ-lehavre.fr	Victor Becquet	STUDENT	73
255	bm242610	maele.briere@etu.univ-lehavre.fr	Maele Briere	STUDENT	72
260	cy243015	yousra.chehbar@etu.univ-lehavre.fr	Yousra Chehbar	STUDENT	72
265	dj242173	jason.de-polignac@etu.univ-lehavre.fr	Jason De polignac--pawlowski	STUDENT	73
270	eb253669	bladavi-charlotte.egbakou@etu.univ-lehavre.fr	Bladavi charlotte Egbakou	STUDENT	71
275	gm240569	malo.gledel@etu.univ-lehavre.fr	Malo Gledel	STUDENT	73
280	kh241447	hasmik.keanian@etu.univ-lehavre.fr	Hasmik Keanian	STUDENT	73
96	gd253329	dapolek.gomis@etu.univ-lehavre.fr	Dapolek Gomis	STUDENT	59
97	gj252592	joolya.gosset@etu.univ-lehavre.fr	Joolya Gosset	STUDENT	64
285	lm240263	melia.le-flanchec@etu.univ-lehavre.fr	Melia Le flanchec	STUDENT	72
290	lt242899	thomas.lefiot@etu.univ-lehavre.fr	Thomas Lefiot	STUDENT	71
295	ll242751	lena.lhuissier--caballe@etu.univ-lehavre.fr	Lena Lhuissier--caballe	STUDENT	71
300	md240382	dounia.mehadji@etu.univ-lehavre.fr	Dounia Mehadji	STUDENT	71
305	mr230767	ryan.mourzik@etu.univ-lehavre.fr	Ryan Mourzik	STUDENT	71
310	pc242294	clara.poignant@etu.univ-lehavre.fr	Clara Poignant	STUDENT	73
315	sh241427	hugo.saillot@etu.univ-lehavre.fr	Hugo Saillot	STUDENT	72
88	dp251943	paul-antoine.dumais@etu.univ-lehavre.fr	Paul-antoine Dumais	STUDENT	62
89	ee250915	emeline.ettendorff@etu.univ-lehavre.fr	Emeline Ettendorff	STUDENT	62
90	fr250469	rodrigue.fichaux@etu.univ-lehavre.fr	Rodrigue Fichaux	STUDENT	64
91	fa251707	agathe.finet@etu.univ-lehavre.fr	Agathe Finet	STUDENT	64
92	fm251967	maelie.foucourt@etu.univ-lehavre.fr	Maelie Foucourt	STUDENT	62
98	gm251337	margot.grodwohl@etu.univ-lehavre.fr	Margot Grodwohl	STUDENT	64
99	ga250861	antoine.guerin@etu.univ-lehavre.fr	Antoine Guerin	STUDENT	59
100	gm251730	marie.guibe@etu.univ-lehavre.fr	Marie Guibe	STUDENT	64
101	gl252323	louane.guillesser@etu.univ-lehavre.fr	Louane Guillesser	STUDENT	61
102	ge251251	emma.guyomard@etu.univ-lehavre.fr	Emma Guyomard	STUDENT	63
103	gm252545	manon.guyot@etu.univ-lehavre.fr	Manon Guyot	STUDENT	62
104	hn250192	noelie.hachard-etcheto@etu.univ-lehavre.fr	Noelie Hachard-etcheto	STUDENT	62
105	hm242235	marine.haddad@etu.univ-lehavre.fr	Marine Haddad	STUDENT	59
106	hr251962	reda.hamouche@etu.univ-lehavre.fr	Reda Hamouche	STUDENT	64
107	hh252512	hamza.hamoudi@etu.univ-lehavre.fr	Hamza Hamoudi	STUDENT	60
108	hr251331	rafael.hoffecard@etu.univ-lehavre.fr	Rafael Hoffecard	STUDENT	62
109	hc251336	clara.homont@etu.univ-lehavre.fr	Clara Homont	STUDENT	59
110	ha252599	aloyse.houard@etu.univ-lehavre.fr	Aloyse Houard	STUDENT	64
111	hs253005	samir.houmadi@etu.univ-lehavre.fr	Samir Houmadi	STUDENT	63
112	ja251113	alexandre.joubert@etu.univ-lehavre.fr	Alexandre Joubert	STUDENT	59
113	jw253107	wilina.jules-marthe@etu.univ-lehavre.fr	Wilina Jules-marthe	STUDENT	62
114	kc252645	celia.kessas@etu.univ-lehavre.fr	Celia Kessas	STUDENT	64
115	ka252475	aalya.khaloua@etu.univ-lehavre.fr	Aalya Khaloua	STUDENT	64
116	kp251912	paul.kiehl@etu.univ-lehavre.fr	Paul Kiehl	STUDENT	60
117	ko251654	oum-kalthum.konate@etu.univ-lehavre.fr	Oum-kalthum Konate	STUDENT	60
118	ky250972	yelyzaveta.kuznietsova@etu.univ-lehavre.fr	Yelyzaveta Kuznietsova	STUDENT	62
119	la252504	arthur.lagarde@etu.univ-lehavre.fr	Arthur Lagarde	STUDENT	61
120	lm251469	marie.langlois@etu.univ-lehavre.fr	Marie Langlois	STUDENT	60
121	lp252252	pauline.le-drezen@etu.univ-lehavre.fr	Pauline Le drezen	STUDENT	59
122	lm252757	mahene.lebret--mendy@etu.univ-lehavre.fr	Mahene Lebret--mendy	STUDENT	59
320	vc241032	camille.vincent@etu.univ-lehavre.fr	Camille Vincent	STUDENT	73
324	dl243055	louise.danger@etu.univ-lehavre.fr	Louise Danger	STUDENT	76
327	lj240339	jeanne.laignel@etu.univ-lehavre.fr	Jeanne Laignel	STUDENT	76
329	pc241988	cesar.poittevin@etu.univ-lehavre.fr	Cesar Poittevin	STUDENT	76
332	tl242384	lison.thilloy@etu.univ-lehavre.fr	Lison Thilloy	STUDENT	76
335	cz230752	zoe.cailly@etu.univ-lehavre.fr	Zoe Cailly	STUDENT	79
339	kg233164	guillaume.konan@etu.univ-lehavre.fr	Guillaume Konan	STUDENT	78
340	ls231304	soa.lamande@etu.univ-lehavre.fr	Soa Lamande	STUDENT	77
344	ml230379	lena.moulin@etu.univ-lehavre.fr	Lena Moulin	STUDENT	78
345	np231172	paul.neel@etu.univ-lehavre.fr	Paul Neel	STUDENT	78
349	ra231371	axel.romer--messe@etu.univ-lehavre.fr	Axel Romer--messe	STUDENT	78
350	rb230630	baptiste.rose@etu.univ-lehavre.fr	Baptiste Rose	STUDENT	77
354	tm230955	mathieu.tocquer@etu.univ-lehavre.fr	Mathieu Tocquer	STUDENT	77
355	ta221625	alexandre.trancart@etu.univ-lehavre.fr	Alexandre Trancart	STUDENT	77
131	lk253957	kassy.levesque@etu.univ-lehavre.fr	Kassy Levesque	STUDENT	59
132	ln252240	noah.lioust-dit-lafleur@etu.univ-lehavre.fr	Noah Lioust dit lafleur	STUDENT	64
137	mi251216	ibtissem.marni-sandid@etu.univ-lehavre.fr	Ibtissem Marni-sandid	STUDENT	63
138	me251129	eden.mfinka-tomanitou@etu.univ-lehavre.fr	Eden Mfinka tomanitou	STUDENT	59
133	lc251886	clarisse.lorenzon@etu.univ-lehavre.fr	Clarisse Lorenzon	STUDENT	63
143	ni251442	ilhan.ndopedro@etu.univ-lehavre.fr	Ilhan Ndopedro	STUDENT	60
134	mj251114	julien.mahier@etu.univ-lehavre.fr	Julien Mahier	STUDENT	60
139	mj252484	josephina.moisa@etu.univ-lehavre.fr	Josephina Moisa	STUDENT	59
124	lv252253	victor.lecaron@etu.univ-lehavre.fr	Victor Lecaron	STUDENT	64
135	ml250268	lorena.marchais@etu.univ-lehavre.fr	Lorena Marchais	STUDENT	60
136	ml252672	liam.marie@etu.univ-lehavre.fr	Liam Marie	STUDENT	60
149	pm251875	manon.paumelle@etu.univ-lehavre.fr	Manon Paumelle	STUDENT	61
125	la251719	aela.lecoq--petitjean@etu.univ-lehavre.fr	Aela Lecoq--petitjean	STUDENT	64
140	ml252711	lana.monchaux@etu.univ-lehavre.fr	Lana Monchaux	STUDENT	64
155	rj251734	jawad.rhabbour-el-melhaoui@etu.univ-lehavre.fr	Jawad Rhabbour el melhaoui	STUDENT	62
156	rm252597	melene.romeo@etu.univ-lehavre.fr	Melene Romeo	STUDENT	64
126	lm250060	maelle.lecourtois@etu.univ-lehavre.fr	Maelle Lecourtois	STUDENT	60
127	la252743	anne-sarah.legat@etu.univ-lehavre.fr	Anne-sarah Legat	STUDENT	62
167	ta250120	amadou.tall@etu.univ-lehavre.fr	Amadou Tall	STUDENT	59
128	lp252646	paul.lelandais@etu.univ-lehavre.fr	Paul Lelandais	STUDENT	61
141	np251128	pauline.navarro@etu.univ-lehavre.fr	Pauline Navarro	STUDENT	61
144	nt250562	timeo.neusy@etu.univ-lehavre.fr	Timeo Neusy	STUDENT	62
150	pe252659	emma.planchon@etu.univ-lehavre.fr	Emma Planchon	STUDENT	60
151	pm252595	myrtille.pouytes@etu.univ-lehavre.fr	Myrtille Pouytes	STUDENT	63
168	tk250452	kerem.tas@etu.univ-lehavre.fr	Kerem Tas	STUDENT	61
145	na252393	anithan.newton-rubaraj@etu.univ-lehavre.fr	Anithan Newton rubaraj	STUDENT	61
129	lv253345	valentin.lemesle@etu.univ-lehavre.fr	Valentin Lemesle	STUDENT	61
161	ss222742	soimadou.said-mmadi@etu.univ-lehavre.fr	Soimadou Said m'madi	STUDENT	63
169	tm251348	matheo.tauvel@etu.univ-lehavre.fr	Matheo Tauvel	STUDENT	63
172	tc250504	cassandra.turgy@etu.univ-lehavre.fr	Cassandra Turgy	STUDENT	62
219	ll232027	louis.lecomte@etu.univ-lehavre.fr	Louis Lecomte	STUDENT	67
359	davidm	maxime.david@univ-lehavre.fr	Maxime David	PROFESSOR	1
249	bm231958	mathis.baumann@etu.univ-lehavre.fr	Mathis Baumann	STUDENT	71
157	rt251714	timeo.rossard@etu.univ-lehavre.fr	Timeo Rossard	STUDENT	61
162	sl251481	lucie.sapin@etu.univ-lehavre.fr	Lucie Sapin	STUDENT	61
130	le252428	eryne.lerouge-morin@etu.univ-lehavre.fr	Eryne Lerouge-morin	STUDENT	62
170	tc250065	clement.tisserand@etu.univ-lehavre.fr	Clement Tisserand	STUDENT	61
142	nd250498	djilliane.navet@etu.univ-lehavre.fr	Djilliane Navet	STUDENT	60
177	wh252729	hannah.watrin@etu.univ-lehavre.fr	Hannah Watrin	STUDENT	60
152	pi251927	ines.pouzet@etu.univ-lehavre.fr	Ines Pouzet	STUDENT	62
146	na252803	angela.ngudi@etu.univ-lehavre.fr	Angela Ngudi	STUDENT	61
173	va251472	adam.vekemans@etu.univ-lehavre.fr	Adam Vekemans	STUDENT	62
147	oe252498	efe.odabas@etu.univ-lehavre.fr	Efe Odabas	STUDENT	64
148	or252083	rayan.ouamara@etu.univ-lehavre.fr	Rayan Ouamara	STUDENT	60
163	ss251045	steven.schouppe@etu.univ-lehavre.fr	Steven Schouppe	STUDENT	62
253	bm242358	maxime.bertin@etu.univ-lehavre.fr	Maxime Bertin	STUDENT	73
174	vt252276	thibaut.vendeville@etu.univ-lehavre.fr	Thibaut Vendeville	STUDENT	61
164	ss252257	syana.sibler@etu.univ-lehavre.fr	Syana Sibler	STUDENT	64
153	pp252434	paloma.puccinelli@etu.univ-lehavre.fr	Paloma Puccinelli	STUDENT	60
182	zr252098	rayan.zariouh@etu.univ-lehavre.fr	Rayan Zariouh	STUDENT	64
165	sd252701	diariata.sow@etu.univ-lehavre.fr	Diariata Sow	STUDENT	63
171	ts251449	sean.toutain@etu.univ-lehavre.fr	Sean Toutain	STUDENT	62
154	ql251618	louison.quivy@etu.univ-lehavre.fr	Louison Quivy	STUDENT	60
178	wr251278	rose.welle@etu.univ-lehavre.fr	Rose Welle	STUDENT	63
175	vm250803	maxence.vilquin@etu.univ-lehavre.fr	Maxence Vilquin	STUDENT	63
176	va253281	alice.volle@etu.univ-lehavre.fr	Alice Volle	STUDENT	64
179	wt251426	tom.werbrouck@etu.univ-lehavre.fr	Tom Werbrouck	STUDENT	62
180	ws252744	seth.willems@etu.univ-lehavre.fr	Seth Willems	STUDENT	62
183	am230241	maeva.akele@etu.univ-lehavre.fr	Maeva Akele	STUDENT	66
181	wt251770	theophile.woerth--goetz@etu.univ-lehavre.fr	Theophile Woerth--goetz	STUDENT	62
158	rt251125	thomas.rousseau@etu.univ-lehavre.fr	Thomas Rousseau	STUDENT	64
184	as222198	simitha.aruldas@etu.univ-lehavre.fr	Simitha Aruldas	STUDENT	66
159	sh250354	hanae.sa@etu.univ-lehavre.fr	Hanae Sa	STUDENT	60
160	sa252570	adam.sabri@etu.univ-lehavre.fr	Adam Sabri	STUDENT	59
166	se252380	eva.szumacher@etu.univ-lehavre.fr	Eva Lolivier	STUDENT	64
207	ea231234	alexandre.elbaz@etu.univ-lehavre.fr	Alexandre Elbaz	STUDENT	68
218	lm231971	morgane.launay@etu.univ-lehavre.fr	Morgane Launay	STUDENT	67
258	cr241689	romane.camara@etu.univ-lehavre.fr	Romane Camara	STUDENT	71
263	cu241982	ulysse.cottineau@etu.univ-lehavre.fr	Ulysse Cottineau	STUDENT	72
268	dd242940	djibril.diallo@etu.univ-lehavre.fr	Djibril Diallo	STUDENT	73
273	fb242636	britney.faha@etu.univ-lehavre.fr	Britney Faha	STUDENT	71
278	jl242158	lilou.jacquet-usureau@etu.univ-lehavre.fr	Lilou Jacquet - usureau	STUDENT	72
283	ly241902	yanis.lambourdiere--couillard@etu.univ-lehavre.fr	Yanis Lambourdiere - - couillard	STUDENT	71
288	ll242257	lisa.lefebvre@etu.univ-lehavre.fr	Lisa Lefebvre	STUDENT	72
293	lp242802	paloma.lequien@etu.univ-lehavre.fr	Paloma Lequien	STUDENT	74
298	mj240527	jules.mary@etu.univ-lehavre.fr	Jules Mary	STUDENT	71
303	ma242510	adele.michel@etu.univ-lehavre.fr	Adele Michel	STUDENT	72
358	millemi	mickael.millet@univ-lehavre.fr	Mickael Millet	DEPT_HEAD	1
362	khaledz	zahraa.khaled@univ-lehavre.fr	Zahraa Khaled	STUDY_DIRECTOR	1
361	montieca	caroline.milcent-montier@univ-lehavre.fr	Caroline Milcent Montier	STUDY_DIRECTOR	1
236	sl232993	lalya.susunaga@etu.univ-lehavre.fr	Lalya Susunaga	GUEST	\N
357	pytels	steeve.pytel@univ-lehavre.fr	Steeve Pytel	PROFESSOR	1
363	tabellth	thierry.tabellion@univ-lehavre.fr	Thierry Tabellion	PROFESSOR	1
364	duc	chaofan.du@univ-lehavre.fr	Chaofan Du	PROFESSOR	1
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

SELECT pg_catalog.setval('public.group_id_seq', 80, true);


--
-- Name: internship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.internship_id_seq', 1, true);


--
-- Name: learningoutcome_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.learningoutcome_id_seq', 123, true);


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

SELECT pg_catalog.setval('public.responsibilitymatrix_id_seq', 56, true);


--
-- Name: rubriccriterion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.rubriccriterion_id_seq', 75, true);


--
-- Name: studentfile_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.studentfile_id_seq', 4, true);


--
-- Name: systemconfig_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.systemconfig_id_seq', 12, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_user
--

SELECT pg_catalog.setval('public.user_id_seq', 364, true);


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
-- Name: learningoutcome learningoutcome_pkey; Type: CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.learningoutcome
    ADD CONSTRAINT learningoutcome_pkey PRIMARY KEY (id);


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
-- Name: ix_activity_code; Type: INDEX; Schema: public; Owner: app_user
--

CREATE INDEX ix_activity_code ON public.activity USING btree (code);


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
-- Name: ix_systemconfig_key; Type: INDEX; Schema: public; Owner: app_user
--

CREATE UNIQUE INDEX ix_systemconfig_key ON public.systemconfig USING btree (key);


--
-- Name: ix_user_ldap_uid; Type: INDEX; Schema: public; Owner: app_user
--

CREATE UNIQUE INDEX ix_user_ldap_uid ON public."user" USING btree (ldap_uid);


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
-- Name: learningoutcome learningoutcome_competency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public.learningoutcome
    ADD CONSTRAINT learningoutcome_competency_id_fkey FOREIGN KEY (competency_id) REFERENCES public.competency(id);


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
-- Name: user user_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: app_user
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: app_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict RnDm5Uz84RkbCucYZiNCDSpjOgbF7WOzsK1VrHf58phh5P6UqnxQ7jcExG9brC8

ALTER TABLE public."user" ADD COLUMN IF NOT EXISTS phone character varying;

-- 🛠 DATABASE PATCHES (Skills Hub v2)
ALTER TABLE public."user" ADD COLUMN IF NOT EXISTS phone character varying;
ALTER TABLE public."internship" ADD COLUMN IF NOT EXISTS company_id INTEGER;
ALTER TABLE public."internship" ADD COLUMN IF NOT EXISTS evaluation_token character varying;
ALTER TABLE public."internship" ADD COLUMN IF NOT EXISTS token_expires_at timestamp without time zone;
ALTER TABLE public."internship" ADD COLUMN IF NOT EXISTS is_finalized BOOLEAN DEFAULT FALSE;
ALTER TABLE public."internship" ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
