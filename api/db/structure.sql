SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lotteries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lotteries (
    id bigint NOT NULL,
    drawn_on timestamp without time zone,
    winning_numbers jsonb
);


--
-- Name: lotteries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lotteries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lotteries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lotteries_id_seq OWNED BY public.lotteries.id;


--
-- Name: lottery_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lottery_tickets (
    id bigint NOT NULL,
    nickname character varying NOT NULL,
    lottery_id bigint NOT NULL,
    numbers jsonb,
    bit_serialized_numbers bit varying(50)
);


--
-- Name: lottery_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lottery_tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lottery_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lottery_tickets_id_seq OWNED BY public.lottery_tickets.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: lotteries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotteries ALTER COLUMN id SET DEFAULT nextval('public.lotteries_id_seq'::regclass);


--
-- Name: lottery_tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lottery_tickets ALTER COLUMN id SET DEFAULT nextval('public.lottery_tickets_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: lotteries lotteries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotteries
    ADD CONSTRAINT lotteries_pkey PRIMARY KEY (id);


--
-- Name: lottery_tickets lottery_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lottery_tickets
    ADD CONSTRAINT lottery_tickets_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_lottery_tickets_on_lottery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lottery_tickets_on_lottery_id ON public.lottery_tickets USING btree (lottery_id);


--
-- Name: lottery_tickets fk_rails_9074c3a1d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lottery_tickets
    ADD CONSTRAINT fk_rails_9074c3a1d7 FOREIGN KEY (lottery_id) REFERENCES public.lotteries(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190410192517'),
('20190412195503');


