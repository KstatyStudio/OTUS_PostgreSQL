--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6 (Ubuntu 15.6-1.pgdg22.04+1)
-- Dumped by pg_dump version 15.6 (Ubuntu 15.6-1.pgdg22.04+1)

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
-- Name: clinic_schema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA clinic_schema;


ALTER SCHEMA clinic_schema OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: address; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.address (
    id_address integer NOT NULL,
    id_area integer,
    id_street integer,
    num_dom integer NOT NULL,
    let_dom character(1),
    korp_dom character(4),
    str_dom character(4)
);


ALTER TABLE clinic_schema.address OWNER TO postgres;

--
-- Name: address_id_address_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.address ALTER COLUMN id_address ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.address_id_address_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: age_group; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.age_group (
    id_age_group integer NOT NULL,
    from_age integer NOT NULL,
    to_age integer NOT NULL,
    name_age_group character(64)
);


ALTER TABLE clinic_schema.age_group OWNER TO postgres;

--
-- Name: age_group_id_age_group_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.age_group ALTER COLUMN id_age_group ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.age_group_id_age_group_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: amb_card; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.amb_card (
    id_card integer NOT NULL,
    fam_patient character(15),
    name_patient character(18),
    otch_patient character(15),
    b_date date,
    pol character(1),
    id_address integer,
    num_kv integer,
    num_tel integer,
    id_cont integer,
    organization character(32),
    "position" character(24),
    ser_polis character(2),
    num_polis integer,
    id_reg_group integer,
    create_date date
);


ALTER TABLE clinic_schema.amb_card OWNER TO postgres;

--
-- Name: amb_card_id_card_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.amb_card ALTER COLUMN id_card ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.amb_card_id_card_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: area; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.area (
    id_area integer NOT NULL,
    id_doctor integer
);


ALTER TABLE clinic_schema.area OWNER TO postgres;

--
-- Name: contingent; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.contingent (
    id_cont integer NOT NULL,
    name_cont character(40) NOT NULL
);


ALTER TABLE clinic_schema.contingent OWNER TO postgres;

--
-- Name: department; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.department (
    id_dep integer NOT NULL,
    name_dep character(30) NOT NULL,
    type_dep boolean DEFAULT false,
    short_dep character varying(7) NOT NULL
);


ALTER TABLE clinic_schema.department OWNER TO postgres;

--
-- Name: department_id_dep_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.department ALTER COLUMN id_dep ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.department_id_dep_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: doc_type_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.doc_type_list (
    id_doc_type integer NOT NULL,
    name_doc_type character(64) NOT NULL
);


ALTER TABLE clinic_schema.doc_type_list OWNER TO postgres;

--
-- Name: doc_type_list_id_doc_type_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.doc_type_list ALTER COLUMN id_doc_type ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.doc_type_list_id_doc_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: doctor; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.doctor (
    id_doctor integer NOT NULL,
    id_staff integer,
    id_dep integer,
    id_spec integer,
    empl_date date,
    dism_date date,
    state boolean
);


ALTER TABLE clinic_schema.doctor OWNER TO postgres;

--
-- Name: doctor_id_doctor_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.doctor ALTER COLUMN id_doctor ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.doctor_id_doctor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hospital_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.hospital_list (
    id_hospital integer NOT NULL,
    type_hospital character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.hospital_list OWNER TO postgres;

--
-- Name: hospital_list_id_hospital_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.hospital_list ALTER COLUMN id_hospital ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.hospital_list_id_hospital_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: l_id_fam; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.l_id_fam (
    floor integer
);


ALTER TABLE clinic_schema.l_id_fam OWNER TO postgres;

--
-- Name: mkb; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.mkb (
    id_mkb character varying(3) NOT NULL,
    ds character varying(180) NOT NULL,
    id_mkb_int integer,
    id_spec integer
);


ALTER TABLE clinic_schema.mkb OWNER TO postgres;

--
-- Name: mkb_class; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.mkb_class (
    id_mkb_int integer NOT NULL,
    id_mkb_class character varying(5) NOT NULL,
    ds character varying(180) NOT NULL
);


ALTER TABLE clinic_schema.mkb_class OWNER TO postgres;

--
-- Name: period_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.period_list (
    id_period integer NOT NULL,
    name_period character(32) NOT NULL,
    begin_period date NOT NULL,
    end_period date
);


ALTER TABLE clinic_schema.period_list OWNER TO postgres;

--
-- Name: period_list_id_period_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.period_list ALTER COLUMN id_period ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.period_list_id_period_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: period_type_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.period_type_list (
    id_period_type integer NOT NULL,
    name_period_type character(32),
    begin_month integer,
    end_month integer
);


ALTER TABLE clinic_schema.period_type_list OWNER TO postgres;

--
-- Name: period_type_list_id_period_type_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.period_type_list ALTER COLUMN id_period_type ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.period_type_list_id_period_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: reg_group; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.reg_group (
    id_reg_group integer NOT NULL,
    name_reg_group character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.reg_group OWNER TO postgres;

--
-- Name: speciality; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.speciality (
    id_spec integer NOT NULL,
    name_spec character varying(20) NOT NULL,
    type_spec boolean
);


ALTER TABLE clinic_schema.speciality OWNER TO postgres;

--
-- Name: speciality_id_spec_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.speciality ALTER COLUMN id_spec ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.speciality_id_spec_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: staff; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.staff (
    id_staff integer NOT NULL,
    fam_doctor character varying(15) NOT NULL,
    name_doctor character varying(15) NOT NULL,
    otch_doctor character varying(15) NOT NULL,
    pol character(1) NOT NULL
);


ALTER TABLE clinic_schema.staff OWNER TO postgres;

--
-- Name: staff_id_staff_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.staff ALTER COLUMN id_staff ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.staff_id_staff_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: street; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.street (
    id_street integer NOT NULL,
    type_street character varying(4) NOT NULL,
    name_street character varying(18) NOT NULL
);


ALTER TABLE clinic_schema.street OWNER TO postgres;

--
-- Name: street_id_street_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.street ALTER COLUMN id_street ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.street_id_street_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: talon; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.talon (
    id_talon integer NOT NULL,
    id_card integer,
    id_target integer,
    type_spo integer,
    spo integer,
    close_date date,
    open_date date
);


ALTER TABLE clinic_schema.talon OWNER TO postgres;

--
-- Name: talon_id_talon_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.talon ALTER COLUMN id_talon ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.talon_id_talon_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: target_spo; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.target_spo (
    id_target integer NOT NULL,
    name_target character varying(64) NOT NULL
);


ALTER TABLE clinic_schema.target_spo OWNER TO postgres;

--
-- Name: tmp_address_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_address_list (
    id_dsa integer NOT NULL,
    id_street integer,
    id_area integer,
    num_dom integer
);


ALTER TABLE clinic_schema.tmp_address_list OWNER TO postgres;

--
-- Name: tmp_address_list_id_dsa_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_address_list ALTER COLUMN id_dsa ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_address_list_id_dsa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_fam_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_fam_list (
    id_fam integer NOT NULL,
    str_fam_m character(15),
    str_fam_f character(15)
);


ALTER TABLE clinic_schema.tmp_fam_list OWNER TO postgres;

--
-- Name: tmp_fam_list_id_fam_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_fam_list ALTER COLUMN id_fam ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_fam_list_id_fam_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_full_name_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_full_name_list (
    id_full integer NOT NULL,
    str_fam character(15),
    str_name character(12),
    str_otch character(15),
    pol character(1)
);


ALTER TABLE clinic_schema.tmp_full_name_list OWNER TO postgres;

--
-- Name: tmp_full_name_list_id_full_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_full_name_list ALTER COLUMN id_full ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_full_name_list_id_full_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_kv_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_kv_list (
    id_kv integer NOT NULL,
    id_address integer,
    id_area integer,
    id_street integer,
    num_dom integer,
    num_kv integer
);


ALTER TABLE clinic_schema.tmp_kv_list OWNER TO postgres;

--
-- Name: tmp_kv_list_id_kv_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_kv_list ALTER COLUMN id_kv ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_kv_list_id_kv_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_mkb; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_mkb (
    id_id integer NOT NULL,
    id_mkb character(3),
    id_spec integer,
    type_spec boolean
);


ALTER TABLE clinic_schema.tmp_mkb OWNER TO postgres;

--
-- Name: tmp_mkb_id_id_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_mkb ALTER COLUMN id_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_mkb_id_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_name_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_name_list (
    id_name integer NOT NULL,
    str_name character(12),
    pol character(1)
);


ALTER TABLE clinic_schema.tmp_name_list OWNER TO postgres;

--
-- Name: tmp_name_list_id_name_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_name_list ALTER COLUMN id_name ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_name_list_id_name_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_organization; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_organization (
    id_org integer NOT NULL,
    name_org character(32)
);


ALTER TABLE clinic_schema.tmp_organization OWNER TO postgres;

--
-- Name: tmp_organization_id_org_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_organization ALTER COLUMN id_org ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_organization_id_org_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_otch_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_otch_list (
    id_otch integer NOT NULL,
    str_otch_m character(15),
    str_otch_f character(15)
);


ALTER TABLE clinic_schema.tmp_otch_list OWNER TO postgres;

--
-- Name: tmp_otch_list_id_otch_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_otch_list ALTER COLUMN id_otch ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_otch_list_id_otch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_position; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_position (
    id_pos integer NOT NULL,
    name_pos character(24)
);


ALTER TABLE clinic_schema.tmp_position OWNER TO postgres;

--
-- Name: tmp_position_id_pos_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_position ALTER COLUMN id_pos ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_position_id_pos_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tmp_street_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_street_list (
    id_sa integer NOT NULL,
    id_street integer,
    min integer,
    max integer,
    id_area integer
);


ALTER TABLE clinic_schema.tmp_street_list OWNER TO postgres;

--
-- Name: tmp_street_list_id_sa_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.tmp_street_list ALTER COLUMN id_sa ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.tmp_street_list_id_sa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: visit; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.visit (
    id_visit integer NOT NULL,
    id_talon integer,
    visit_date date,
    id_visit_type integer,
    id_zab_type integer,
    id_doctor integer,
    id_mkb character(3),
    next_date date
);


ALTER TABLE clinic_schema.visit OWNER TO postgres;

--
-- Name: visit_id_visit_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.visit ALTER COLUMN id_visit ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.visit_id_visit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: visit_type; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.visit_type (
    id_visit_type integer NOT NULL,
    name_visit_type character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.visit_type OWNER TO postgres;

--
-- Name: zab_type; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.zab_type (
    id_zab_type integer NOT NULL,
    name_zab_type character varying(64) NOT NULL
);


ALTER TABLE clinic_schema.zab_type OWNER TO postgres;

--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id_address);


--
-- Name: age_group age_group_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.age_group
    ADD CONSTRAINT age_group_pkey PRIMARY KEY (id_age_group);


--
-- Name: amb_card amb_card_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.amb_card
    ADD CONSTRAINT amb_card_pkey PRIMARY KEY (id_card);


--
-- Name: area area_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id_area);


--
-- Name: contingent contingent_id_cont_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.contingent
    ADD CONSTRAINT contingent_id_cont_key UNIQUE (id_cont);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id_dep);


--
-- Name: doc_type_list doc_type_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.doc_type_list
    ADD CONSTRAINT doc_type_list_pkey PRIMARY KEY (id_doc_type);


--
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (id_doctor);


--
-- Name: hospital_list hospital_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.hospital_list
    ADD CONSTRAINT hospital_list_pkey PRIMARY KEY (id_hospital);


--
-- Name: mkb_class mkb_class_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.mkb_class
    ADD CONSTRAINT mkb_class_pkey PRIMARY KEY (id_mkb_int);


--
-- Name: mkb mkb_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.mkb
    ADD CONSTRAINT mkb_pkey PRIMARY KEY (id_mkb);


--
-- Name: period_list period_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.period_list
    ADD CONSTRAINT period_list_pkey PRIMARY KEY (id_period);


--
-- Name: period_type_list period_type_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.period_type_list
    ADD CONSTRAINT period_type_list_pkey PRIMARY KEY (id_period_type);


--
-- Name: reg_group reg_group_id_reg_group_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.reg_group
    ADD CONSTRAINT reg_group_id_reg_group_key UNIQUE (id_reg_group);


--
-- Name: speciality speciality_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.speciality
    ADD CONSTRAINT speciality_pkey PRIMARY KEY (id_spec);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id_staff);


--
-- Name: street street_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.street
    ADD CONSTRAINT street_pkey PRIMARY KEY (id_street);


--
-- Name: talon talon_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.talon
    ADD CONSTRAINT talon_pkey PRIMARY KEY (id_talon);


--
-- Name: target_spo target_spo_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.target_spo
    ADD CONSTRAINT target_spo_pkey PRIMARY KEY (id_target);


--
-- Name: tmp_address_list tmp_address_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_address_list
    ADD CONSTRAINT tmp_address_list_pkey PRIMARY KEY (id_dsa);


--
-- Name: tmp_fam_list tmp_fam_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_fam_list
    ADD CONSTRAINT tmp_fam_list_pkey PRIMARY KEY (id_fam);


--
-- Name: tmp_fam_list tmp_fam_list_str_fam_f_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_fam_list
    ADD CONSTRAINT tmp_fam_list_str_fam_f_key UNIQUE (str_fam_f);


--
-- Name: tmp_fam_list tmp_fam_list_str_fam_m_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_fam_list
    ADD CONSTRAINT tmp_fam_list_str_fam_m_key UNIQUE (str_fam_m);


--
-- Name: tmp_full_name_list tmp_full_name_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_full_name_list
    ADD CONSTRAINT tmp_full_name_list_pkey PRIMARY KEY (id_full);


--
-- Name: tmp_kv_list tmp_kv_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_kv_list
    ADD CONSTRAINT tmp_kv_list_pkey PRIMARY KEY (id_kv);


--
-- Name: tmp_mkb tmp_mkb_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_mkb
    ADD CONSTRAINT tmp_mkb_pkey PRIMARY KEY (id_id);


--
-- Name: tmp_name_list tmp_name_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_name_list
    ADD CONSTRAINT tmp_name_list_pkey PRIMARY KEY (id_name);


--
-- Name: tmp_name_list tmp_name_list_str_name_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_name_list
    ADD CONSTRAINT tmp_name_list_str_name_key UNIQUE (str_name);


--
-- Name: tmp_organization tmp_organization_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_organization
    ADD CONSTRAINT tmp_organization_pkey PRIMARY KEY (id_org);


--
-- Name: tmp_otch_list tmp_otch_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_otch_list
    ADD CONSTRAINT tmp_otch_list_pkey PRIMARY KEY (id_otch);


--
-- Name: tmp_otch_list tmp_otch_list_str_otch_f_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_otch_list
    ADD CONSTRAINT tmp_otch_list_str_otch_f_key UNIQUE (str_otch_f);


--
-- Name: tmp_otch_list tmp_otch_list_str_otch_m_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_otch_list
    ADD CONSTRAINT tmp_otch_list_str_otch_m_key UNIQUE (str_otch_m);


--
-- Name: tmp_position tmp_position_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_position
    ADD CONSTRAINT tmp_position_pkey PRIMARY KEY (id_pos);


--
-- Name: tmp_street_list tmp_street_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_street_list
    ADD CONSTRAINT tmp_street_list_pkey PRIMARY KEY (id_sa);


--
-- Name: visit visit_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.visit
    ADD CONSTRAINT visit_pkey PRIMARY KEY (id_visit);


--
-- Name: visit_type visit_type_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.visit_type
    ADD CONSTRAINT visit_type_pkey PRIMARY KEY (id_visit_type);


--
-- Name: zab_type zab_type_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.zab_type
    ADD CONSTRAINT zab_type_pkey PRIMARY KEY (id_zab_type);


--
-- Name: address address_id_area_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.address
    ADD CONSTRAINT address_id_area_fkey FOREIGN KEY (id_area) REFERENCES clinic_schema.area(id_area);


--
-- Name: address address_id_street_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.address
    ADD CONSTRAINT address_id_street_fkey FOREIGN KEY (id_street) REFERENCES clinic_schema.street(id_street);


--
-- Name: amb_card amb_card_id_address_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.amb_card
    ADD CONSTRAINT amb_card_id_address_fkey FOREIGN KEY (id_address) REFERENCES clinic_schema.address(id_address);


--
-- Name: amb_card amb_card_id_cont_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.amb_card
    ADD CONSTRAINT amb_card_id_cont_fkey FOREIGN KEY (id_cont) REFERENCES clinic_schema.contingent(id_cont);


--
-- Name: amb_card amb_card_id_reg_group_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.amb_card
    ADD CONSTRAINT amb_card_id_reg_group_fkey FOREIGN KEY (id_reg_group) REFERENCES clinic_schema.reg_group(id_reg_group);


--
-- Name: area area_id_doctor_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.area
    ADD CONSTRAINT area_id_doctor_fkey FOREIGN KEY (id_doctor) REFERENCES clinic_schema.doctor(id_doctor);


--
-- Name: doctor doctor_id_dep_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.doctor
    ADD CONSTRAINT doctor_id_dep_fkey FOREIGN KEY (id_dep) REFERENCES clinic_schema.department(id_dep);


--
-- Name: doctor doctor_id_spec_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.doctor
    ADD CONSTRAINT doctor_id_spec_fkey FOREIGN KEY (id_spec) REFERENCES clinic_schema.speciality(id_spec);


--
-- Name: doctor doctor_id_staff_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.doctor
    ADD CONSTRAINT doctor_id_staff_fkey FOREIGN KEY (id_staff) REFERENCES clinic_schema.staff(id_staff);


--
-- Name: mkb mkb_id_mkb_int_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.mkb
    ADD CONSTRAINT mkb_id_mkb_int_fkey FOREIGN KEY (id_mkb_int) REFERENCES clinic_schema.mkb_class(id_mkb_int);


--
-- Name: mkb mkb_id_spec_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.mkb
    ADD CONSTRAINT mkb_id_spec_fkey FOREIGN KEY (id_spec) REFERENCES clinic_schema.speciality(id_spec);


--
-- Name: talon talon_id_card_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.talon
    ADD CONSTRAINT talon_id_card_fkey FOREIGN KEY (id_card) REFERENCES clinic_schema.amb_card(id_card);


--
-- Name: talon talon_id_target_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.talon
    ADD CONSTRAINT talon_id_target_fkey FOREIGN KEY (id_target) REFERENCES clinic_schema.target_spo(id_target);


--
-- Name: visit visit_id_doctor_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.visit
    ADD CONSTRAINT visit_id_doctor_fkey FOREIGN KEY (id_doctor) REFERENCES clinic_schema.doctor(id_doctor);


--
-- Name: visit visit_id_mkb_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.visit
    ADD CONSTRAINT visit_id_mkb_fkey FOREIGN KEY (id_mkb) REFERENCES clinic_schema.mkb(id_mkb);


--
-- Name: visit visit_id_talon_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.visit
    ADD CONSTRAINT visit_id_talon_fkey FOREIGN KEY (id_talon) REFERENCES clinic_schema.talon(id_talon);


--
-- Name: visit visit_id_visit_type_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.visit
    ADD CONSTRAINT visit_id_visit_type_fkey FOREIGN KEY (id_visit_type) REFERENCES clinic_schema.visit_type(id_visit_type);


--
-- Name: visit visit_id_zab_type_fkey; Type: FK CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.visit
    ADD CONSTRAINT visit_id_zab_type_fkey FOREIGN KEY (id_zab_type) REFERENCES clinic_schema.zab_type(id_zab_type);


--
-- PostgreSQL database dump complete
--

