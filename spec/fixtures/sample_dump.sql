--
-- PostgreSQL database dump
--

-- Dumped from database version 11.18
-- Dumped by pg_dump version 14.6 (Homebrew)

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

--
-- Name: organizations; Type: TABLE; Schema: public; Owner: luke
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.organizations OWNER TO luke;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: luke
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organizations_id_seq OWNER TO luke;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: luke
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: luke
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying NOT NULL,
    org_id smallint NOT NULL,
    created_at timestamp without time zone,
    birthdate date
);


ALTER TABLE public.users OWNER TO luke;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: luke
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO luke;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: luke
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: luke
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: luke
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: luke
--

COPY public.organizations (id, name, created_at) FROM stdin;
1	Test org	2023-02-04 16:27:51.797666
2	Test org 2	2023-02-04 16:27:55.293966
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: luke
--

COPY public.users (id, name, org_id, created_at, birthdate) FROM stdin;
1	test user 1	1	2023-02-04 16:28:34.391467	1990-01-01
2	test user 2	1	2023-02-04 16:28:44.292242	1989-01-01
3	test user 3	2	2023-02-04 16:28:52.430384	1988-01-01
\.


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: luke
--

SELECT pg_catalog.setval('public.organizations_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: luke
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: luke
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: luke
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_org_idx; Type: INDEX; Schema: public; Owner: luke
--

CREATE INDEX users_org_idx ON public.users USING btree (org_id);


--
-- Name: users fk_users_organizations; Type: FK CONSTRAINT; Schema: public; Owner: luke
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_organizations FOREIGN KEY (org_id) REFERENCES public.organizations(id);


--
-- PostgreSQL database dump complete
--

