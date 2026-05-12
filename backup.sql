--
-- PostgreSQL database dump
--

\restrict tnhiwVGVWyMqauS6W5PSru6fOzDRrIsBg6EySTPhO46OuvxPfPmxZaDlLiRJdUk

-- Dumped from database version 15.17
-- Dumped by pg_dump version 15.17

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
-- Name: votes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.votes (
    id character varying(255) NOT NULL,
    vote character varying(255) NOT NULL
);


ALTER TABLE public.votes OWNER TO postgres;

--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.votes (id, vote) FROM stdin;
21f9bdd829a2dfc	a
21f9bdd829a2dfc	a
21f9bdd829a2dfc	b
21f9bdd829a2dfc	a
21f9bdd829a2dfc	b
21f9bdd829a2dfc	a
21f9bdd829a2dfc	a
21f9bdd829a2dfc	b
8ec131db0fdee07	a
21f9bdd829a2dfc	b
21f9bdd829a2dfc	a
21f9bdd829a2dfc	b
21f9bdd829a2dfc	b
21f9bdd829a2dfc	a
8ec131db0fdee07	a
8ec131db0fdee07	b
21f9bdd829a2dfc	a
21f9bdd829a2dfc	b
21f9bdd829a2dfc	a
21f9bdd829a2dfc	b
21f9bdd829a2dfc	a
\.


--
-- PostgreSQL database dump complete
--

\unrestrict tnhiwVGVWyMqauS6W5PSru6fOzDRrIsBg6EySTPhO46OuvxPfPmxZaDlLiRJdUk

