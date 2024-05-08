--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3 (Debian 15.3-0+deb12u1)
-- Dumped by pg_dump version 15.3 (Debian 15.3-0+deb12u1)

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
-- Name: age_group; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.age_group (
    id_age_group integer NOT NULL,
    from_age integer NOT NULL,
    to_age integer NOT NULL
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
-- Name: area; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.area (
    id_area character varying(3) NOT NULL,
    id_doctor integer
);


ALTER TABLE clinic_schema.area OWNER TO postgres;

--
-- Name: contingent; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.contingent (
    id_cont integer NOT NULL,
    name_cont character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.contingent OWNER TO postgres;

--
-- Name: contingent_id_cont_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.contingent ALTER COLUMN id_cont ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.contingent_id_cont_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: department; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.department (
    id_dep integer NOT NULL,
    name_dep character varying(20) NOT NULL,
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
    name_doc_type character varying(20) NOT NULL
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
    state character varying(1)
);


ALTER TABLE clinic_schema.doctor OWNER TO postgres;

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
-- Name: mkb; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.mkb (
    id_mkb character varying(3) NOT NULL,
    ds character varying(180) NOT NULL,
    id_mkb_int integer
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
    name_period character varying(20) NOT NULL,
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
-- Name: reg_group; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.reg_group (
    id_reg_group integer NOT NULL,
    name_reg_group character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.reg_group OWNER TO postgres;

--
-- Name: reg_group_id_reg_group_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.reg_group ALTER COLUMN id_reg_group ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.reg_group_id_reg_group_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: speciality; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.speciality (
    id_spec integer NOT NULL,
    name_spec character varying(20) NOT NULL
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
    otch_doctor character varying(15) NOT NULL
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
-- Name: target_spo; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.target_spo (
    id_target integer NOT NULL,
    name_target character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.target_spo OWNER TO postgres;

--
-- Name: target_spo_id_target_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.target_spo ALTER COLUMN id_target ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.target_spo_id_target_seq
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
-- Name: tmp_otch_list; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.tmp_otch_list (
    id_otch integer NOT NULL,
    str_otch character(15),
    pol character(1)
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
-- Name: visit_type; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.visit_type (
    id_visit_type integer NOT NULL,
    name_visit_type character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.visit_type OWNER TO postgres;

--
-- Name: visit_type_id_visit_type_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.visit_type ALTER COLUMN id_visit_type ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.visit_type_id_visit_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: zab_type; Type: TABLE; Schema: clinic_schema; Owner: postgres
--

CREATE TABLE clinic_schema.zab_type (
    id_zab_type integer NOT NULL,
    name_zab_type character varying(20) NOT NULL
);


ALTER TABLE clinic_schema.zab_type OWNER TO postgres;

--
-- Name: zab_type_id_zab_type_seq; Type: SEQUENCE; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE clinic_schema.zab_type ALTER COLUMN id_zab_type ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME clinic_schema.zab_type_id_zab_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: age_group; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.age_group (id_age_group, from_age, to_age) FROM stdin;
\.


--
-- Data for Name: area; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.area (id_area, id_doctor) FROM stdin;
\.


--
-- Data for Name: contingent; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.contingent (id_cont, name_cont) FROM stdin;
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.department (id_dep, name_dep, type_dep, short_dep) FROM stdin;
\.


--
-- Data for Name: doc_type_list; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.doc_type_list (id_doc_type, name_doc_type) FROM stdin;
\.


--
-- Data for Name: doctor; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.doctor (id_doctor, id_staff, id_dep, id_spec, empl_date, dism_date, state) FROM stdin;
\.


--
-- Data for Name: hospital_list; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.hospital_list (id_hospital, type_hospital) FROM stdin;
\.


--
-- Data for Name: mkb; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.mkb (id_mkb, ds, id_mkb_int) FROM stdin;
J00	Острый назофарингит (насморк)	10
J01	Острый синусит	10
J02	Острый фарингит	10
J03	Острый тонзиллит	10
J04	Острый ларингит и трахеит	10
J05	Острый обструктивный ларингит [круп] и эпиглоттит	10
J06	Острые инфекции верхних дыхательных путей множественной и неуточненной локализации	10
J09	Грипп, вызванный выявленным вирусом зоонозного или пандемического гриппа	10
J10	Грипп, вызванный идентифицированным вирусом сезонного гриппа	10
J11	Грипп, вирус не идентифицирован	10
J12	Вирусная пневмония, не классифицированная в других рубриках	10
J13	Пневмония, вызванная Streptococcus pneumoniae	10
J14	Пневмония, вызванная Haemophilus influenzae [палочкой Афанасьева-Пфейффера]	10
J15	Бактериальная пневмония, не классифицированная в других рубриках	10
J16	Пневмония, вызванная другими инфекционными возбудителями, не классифицированная в других рубриках	10
J17	Пневмония при болезнях, классифицированных в других рубриках	10
J18	Пневмония без уточнения возбудителя	10
J20	Острый бронхит	10
J21	Острый бронхиолит	10
J22	Острая респираторная инфекция нижних дыхательных путей неуточненная	10
J30	Вазомоторный и аллергический ринит	10
J31	Хронический ринит, назофарингит и фарингит	10
J32	Хронический синусит	10
J33	Полип носа	10
J34	Другие болезни носа и носовых синусов	10
J35	Хронические болезни миндалин и аденоидов	10
J36	Перитонзиллярный абсцесс	10
J37	Хронический ларингит и ларинготрахеит	10
J38	Болезни голосовых складок и гортани, не классифицированные в других рубриках	10
J39	Другие болезни верхних дыхательных путей	10
J40	Бронхит, не уточненный как острый или хронический	10
J41	Простой и слизисто-гнойный хронический бронхит	10
J42	Хронический бронхит неуточненный	10
J43	Эмфизема	10
J44	Другая хроническая обструктивная легочная болезнь	10
J45	Астма	10
J46	Астматическое статус [status asthmaticus]	10
J47	Бронхоэктазия	10
J60	Пневмокониоз угольщика	10
J61	Пневмокониоз, вызванный асбестом и другими минеральными веществами	10
J62	Пневмокониоз, вызванный пылью, содержащей кремний	10
J63	Пневмокониоз, вызванный другой неорганической пылью	10
J64	Пневмокониоз неуточненный	10
J65	Пневмокониоз, связанный с туберкулезом	10
J66	Болезнь дыхательных путей, вызванная специфической органической пылью	10
J67	Гиперсенситивный пневмонит, вызванный органической пылью	10
J68	Респираторные состояния, вызванные вдыханием химических веществ, газов, дымов и паров	10
J69	Пневмонит, вызванный твердыми веществами и жидкостями	10
J70	Респираторные состояния, вызванные другими внешними агентами	10
J80	Синдром респираторного расстройства [дистресса] у взрослого	10
J81	Легочный отек	10
J82	Легочная эозинофилия, не классифицированная в других рубриках	10
J84	Другие интерстициальные легочные болезни	10
J85	Абсцесс легкого и средостения	10
J86	Пиоторакс	10
J90	Плевральный выпот, не классифицированный в других рубриках	10
J91	Плевральный выпот при состояниях, классифицированных в других рубриках	10
J92	Плевральная бляшка	10
J93	Пневмоторакс	10
J94	Другие поражения плевры	10
J95	Респираторные нарушения после медицинских процедур, не классифицированные в других рубриках	10
J96	Дыхательная недостаточность, не классифицированная в других рубриках	10
J98	Другие респираторные нарушения	10
J99	Респираторные нарушения при болезнях, классифицированных в других рубриках	10
S00	Поверхностная травма головы	19
S01	Открытая рана головы	19
S02	Перелом черепа и лицевых костей	19
S67	Размозжение запястья и кисти	19
S03	Вывих, растяжение и перенапряжение суставов и связок головы	19
S04	Травма черепных нервов	19
S05	Травма глаза и глазницы	19
S06	Внутричерепная травма	19
S07	Размозжение головы	19
S08	Травматическая ампутация части головы	19
S09	Другие и неуточненные травмы головы	19
S10	Поверхностная травма шеи	19
S11	Открытая рана шеи	19
S12	Перелом шейного отдела позвоночника	19
S13	Вывих, растяжение и перенапряжение капсульно-связочного аппарата на уровне шеи	19
S14	Травма нервов и спинного мозга на уровне шеи	19
S15	Травма кровеносных сосудов на уровне шеи	19
S16	Травма мышц и сухожилий на уровне шеи	19
S17	Размозжение шеи	19
S18	Травматическая ампутация на уровне шеи	19
S19	Другие и неуточненные травмы шеи	19
S20	Поверхностная травма грудной клетки	19
S21	Открытая рана грудной клетки	19
S22	Перелом ребра (ребер), грудины и грудного отдела позвоночника	19
S23	Вывих, растяжение и перенапряжение капсульно-связочного аппарата грудной клетки	19
S24	Травма нервов и спинного мозга в грудном отделе	19
S25	Травма кровеносных сосудов грудного отдела	19
S26	Травма сердца	19
S27	Травма других и неуточненных органов грудной полости	19
S28	Размозжение грудной клетки и травматическая ампутация части грудной клетки	19
S29	Другие и неуточненные травмы грудной клетки	19
S30	Поверхностная травма живота, нижней части спины и таза	19
S31	Открытая рана живота, нижней части спины и таза	19
S32	Перелом пояснично-крестцового отдела позвоночника и костей таза	19
S33	Вывих, растяжение и перенапряжение капсульно-связочного аппарата поясничного отдела позвоночника и таза	19
S34	Травма нервов и поясничного отдела спинного мозга на уровне живота, нижней части спины и таза	19
S35	Травма кровеносных сосудов на уровне живота, нижней части спины и таза	19
S36	Травма органов брюшной полости	19
S37	Травмы мочеполовых и тазовых органов	19
S38	Размозжение и травматическая ампутация части живота, нижней части спины и таза	19
S39	Другие и неуточненные травмы живота, нижней части спины и таза	19
S40	Поверхностная травма плечевого пояса и плеча	19
S41	Открытая рана плечевого пояса и плеча	19
S42	Перелом на уровне плечевого пояса и плеча	19
S43	Вывих, растяжение и перенапряжение капсульно-связочного аппарата плечевого пояса	19
S44	Травма нервов на уровне плечевого пояса и плеча	19
S45	Травма кровеносных сосудов на уровне плечевого пояса и плеча	19
S46	Травма мышцы и сухожилия на уровне плечевого пояса и плеча	19
S47	Размозжение плечевого пояса и плеча	19
S48	Травматическая ампутация плечевого пояса и плеча	19
S49	Другие и неуточненные травмы плечевого пояса и плеча	19
S50	Поверхностная травма предплечья	19
S51	Открытая рана предплечья	19
S52	Перелом костей предплечья	19
S53	Вывих, растяжение и перенапряжение капсульно-связочного аппарата локтевого сустава	19
S54	Травма нервов на уровне предплечья	19
S55	Травма кровеносных сосудов на уровне предплечья	19
S56	Травма мышцы и сухожилия на уровне предплечья	19
S57	Размозжение предплечья	19
S58	Травматическая ампутация предплечья	19
S59	Другие и неуточненные травмы предплечья	19
S60	Поверхностная травма запястья и кисти	19
S61	Открытая рана запястья и кисти	19
S62	Перелом на уровне запястья и кисти	19
S63	Вывих, растяжение и перенапряжение капсульно-связочного аппарата на уровне запястья и кисти	19
S64	Травма нервов на уровне запястья и кисти	19
S65	Травма кровеносных сосудов на уровне запястья и кисти	19
S66	Травма мышцы и сухожилия на уровне запястья и кисти	19
S68	Травматическая ампутация запястья и кисти	19
S69	Другие и неуточненные травмы запястья и кисти	19
S70	Поверхностная травма области тазобедренного сустава и бедра	19
S71	Открытая рана области тазобедренного сустава и бедра	19
S72	Перелом бедренной кости	19
S73	Вывих, растяжение и перенапряжение капсульно-связочного аппарата тазобедренного сустава и тазового пояса	19
S74	Травмы нервов на уровне тазобедренного сустава бедра	19
S75	Травма кровеносных сосудов на уровне тазобедренного сустава и бедра	19
S76	Травма мышцы и сухожилия на уровне тазобедренного сустава и бедра	19
S77	Размозжение области тазобедренного сустава и бедра	19
S78	Травматическая ампутация области тазобедренного сустава и бедра	19
S79	Другие и неуточненные травмы области тазобедренного сустава и бедра	19
S80	Поверхностная травма голени	19
S81	Открытая рана голени	19
S82	Перелом голени, включая голеностопный сустав	19
S83	Вывих, растяжение и перенапряжение капсульно-связочного аппарата коленного сустава	19
S84	Травма нервов на уровне голени	19
S85	Травма кровеносных сосудов на уровне голени	19
S86	Травма мышцы и сухожилия на уровне голени	19
S87	Размозжение голени	19
S88	Травматическая ампутация голени	19
S89	Другие и неуточненные травмы голени	19
S90	Поверхностная травма области голеностопного сустава и стопы	19
S91	Открытая рана области голеностопного сустава и стопы	19
S92	Перелом стопы, исключая перелом голеностопного сустава	19
S93	Вывих, растяжение и перенапряжение капсульно-связочного аппарата голеностопного сустава и стопы	19
S94	Травма нервов на уровне голеностопного сустава и стопы	19
S95	Травма кровеносных сосудов на уровне голеностопного сустава и стопы	19
S96	Травма мышцы и сухожилия на уровне голеностопного сустава и стопы	19
S97	Размозжение голеностопного сустава и стопы	19
S98	Травматическая ампутация на уровне голеностопного сустава и стопы	19
S99	Другие и неуточненные травмы голеностопного сустава и стопы	19
T00	Поверхностные травмы, захватывающие несколько областей тела	19
T01	Открытые раны, захватывающие несколько областей тела	19
T02	Переломы, захватывающие несколько областей тела	19
T03	Вывихи, растяжения и перенапряжение капсульно-связочного аппарата суставов, захватывающие несколько областей тела	19
T04	Размозжения, захватывающие несколько областей тела	19
T05	Травматические ампутации, захватывающие несколько областей тела	19
T06	Другие травмы, охватывающие несколько областей тела, не классифицированные в других рубриках	19
T07	Множественные травмы неуточненные	19
T08	Перелом позвоночника на неуточненном уровне	19
T09	Другие травмы позвоночника и туловища на неуточненном уровне	19
T10	Перелом верхней конечности на неуточненном уровне	19
T11	Другие травмы верхней конечности на неуточненном уровне	19
T12	Перелом нижней конечности на неуточненном уровне	19
T13	Другие травмы нижней конечности на неуточненном уровне	19
T14	Травма неуточненной локализации	19
T20	Термические и химические ожоги головы и шеи	19
T21	Термические и химические ожоги туловища	19
T22	Термические и химические ожоги области плечевого пояса и верхней конечности, исключая запястье и кисть	19
T23	Термические и химические ожоги запястья и кисти	19
T24	Термические и химические ожоги области тазобедренного сустава и нижней конечности, исключая голеностопный сустав и стопу	19
T25	Термические и химические ожоги области голеностопного сустава и стопы	19
T33	Поверхностное отморожение	19
T34	Отморожение с некрозом тканей	19
T35	Отморожение, захватывающее несколько областей тела, и неуточненное отморожение	19
T51	Токсическое действие алкоголя	19
T52	Токсическое действие органических растворителей	19
T53	Токсическое действие галогенпроизводных алифатических и ароматических углеводородов	19
T54	Токсическое действие разъедающих веществ	19
T55	Токсическое действие мыл и детергентов	19
T56	Токсическое действие металлов	19
E01	Болезни щитовидной железы, связанные с йодной недостаточностью, и сходные состояния	4
E66	Ожирение	4
E73	Непереносимость лактозы	4
H10	Конъюнктивит	7
H60	Наружный отит	8
I09	Другие ревматические болезни сердца	9
K29	Гастрит и дуоденит	11
K71	Токсическое поражение печени	11
K80	Желчекаменная болезнь [холелитиаз]	11
M15	Полиартроз	13
N20	Камни почки и мочеточника	14
\.


--
-- Data for Name: mkb_class; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.mkb_class (id_mkb_int, id_mkb_class, ds) FROM stdin;
1	I	Некоторые инфекционные и паразитарные болезни
2	II	Новообразования
3	III	Болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм
4	IV	Болезни эндокринной системы, расстройства питания и нарушения обмена веществ
5	V	Психические расстройства и расстройства поведения
6	VI	Болезни нервной системы
7	VII	Болезни глаза и его придаточного аппарата
8	VIII	Болезни уха и сосцевидного отростка
9	IX	Болезни системы кровообращения
10	X	Болезни органов дыхания
11	XI	Болезни органов пищеварения
12	XII	Болезни кожи и подкожной клетчатки
13	XIII	Болезни костно-мышечной системы и соединительной ткани
14	XIV	Болезни мочеполовой системы
15	XV	Беременность, роды и послеродовой период
16	XVI	Отдельные состояния, возникающие в перинатальном периоде
17	XVII	Врожденные аномалии [пороки развития], деформации и хромосомные нарушения
18	XVIII	Симптомы, признаки и отклонения от нормы, выявленные при клинических и лабораторных исследованиях, не классифицированные в других рубриках
19	XIX	Травмы, отравления и некоторые другие последствия воздействия внешних причин
20	XX	Внешние причины заболеваемости и смертности
21	XXI	Факторы, влияющие на состояние здоровья населения и обращения в учреждения здравоохранения
22	XXII	Коды для особых целей
\.


--
-- Data for Name: period_list; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.period_list (id_period, name_period, begin_period, end_period) FROM stdin;
\.


--
-- Data for Name: reg_group; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.reg_group (id_reg_group, name_reg_group) FROM stdin;
\.


--
-- Data for Name: speciality; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.speciality (id_spec, name_spec) FROM stdin;
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.staff (id_staff, fam_doctor, name_doctor, otch_doctor) FROM stdin;
\.


--
-- Data for Name: street; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.street (id_street, type_street, name_street) FROM stdin;
1	ул.	Авангардная
2	ул.	Автоматики
3	ул.	Авиационная
4	ул.	Автономная
5	ул.	Агатовая
6	ул.	Базальтовая
7	ул.	Берёзовая
8	ул.	Береговая
9	ул.	Верстовая
10	ул.	Вокзальная
11	ул.	Городская
12	ул.	Дальняя
13	ул.	Завокзальная
14	ул.	Зелёная
15	ул.	Испытателей
16	ул.	Карьерная
17	ул.	Кварцевая
18	ул.	Кольцевая
19	ул.	Лесная
20	ул.	Маневровая
21	пер.	Автомобильный
22	пер.	Боковой
23	пер.	Верхний
24	пер.	Выездной
25	пер.	Грузчиков
26	пер.	Дизельный
27	пер.	Жасминовый
28	пер.	Калиновый
29	пер.	Красный
30	пер.	Лучевой
31	туп.	Лунный
32	туп.	Клубный
33	туп.	Медицинский
34	туп.	Новаторов
35	пр.	Каскадный
36	пр.	Майский
37	пр.	Мостовой
38	пр.	Овощной
39	ш.	Обходное
40	ш.	Песчаное
41	ш.	Садовое
42	пл.	1905 года
43	пл.	1 Пятилетки
\.


--
-- Data for Name: target_spo; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.target_spo (id_target, name_target) FROM stdin;
\.


--
-- Data for Name: tmp_fam_list; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.tmp_fam_list (id_fam, str_fam_m, str_fam_f) FROM stdin;
1	Ависов         	Ависова        
2	Адамсов        	Адамсова       
3	Аддисонов      	Аддисонова     
4	Андерсонов     	Андерсонова    
5	Ансвортин      	Ансвортина     
6	Ансуортин      	Ансуортина     
7	Ардернов       	Ардернова      
8	Аслинин        	Аслинина       
9	Ашфордов       	Ашфордова      
10	Байденов       	Байденова      
11	Банин          	Банина         
12	Барклин        	Барклина       
13	Барнсин        	Барнсина       
14	Бассов         	Бассова        
15	Беверлин       	Беверлина      
16	Беллов         	Беллова        
17	Белтонов       	Белтонова      
18	Беннетин       	Беннетина      
19	Бёрнсов        	Бёрнсова       
20	Беррин         	Беррина        
21	Бёртонин       	Бёртонина      
22	Блуин          	Блуина         
23	Блэков         	Блэкова        
24	Богунин        	Богунина       
25	Болдуинов      	Болдуинова     
26	Бомин          	Бомина         
27	Бондин         	Бондина        
28	Бонемов        	Бонемова       
29	Борденов       	Борденова      
30	Браунин        	Браунина       
31	Бридлавин      	Бридлавина     
32	Брэдлин        	Брэдлина       
33	Бушов          	Бушова         
34	Бьюкененов     	Бьюкененова    
35	Бэнксин        	Бэнксина       
36	Ватсонов       	Ватсонова      
37	Вашингтонов    	Вашингтонова   
38	Вильсонов      	Вильсонова     
39	Вудин          	Вудина         
40	Вудвордин      	Вудвордина     
41	Вудров         	Вудрова        
42	Вудсин         	Вудсина        
43	Вульфов        	Вульфова       
44	Гампов         	Гампова        
45	Гарольдин      	Гарольдина     
46	Генрин         	Генрина        
47	Гингричин      	Гингричина     
48	Гленнов        	Гленнова       
49	Грабин         	Грабина        
50	Грейзеров      	Грейзерова     
51	Гринвичин      	Гринвичина     
52	Гринфилдов     	Гринфилдова    
53	Гриффинов      	Гриффинова     
54	Грэнхолмов     	Грэнхолмова    
55	Далласов       	Далласова      
56	Дарвинов       	Дарвинова      
57	Дартин         	Дартина        
58	Девонширов     	Девонширова    
59	Дейлин         	Дейлина        
60	Деппов         	Деппова        
61	Джаддов        	Джаддова       
62	Джейкобсин     	Джейкобсина    
63	Джексонов      	Джексонова     
64	Дженнерин      	Дженнерина     
65	Джиллеттов     	Джиллеттова    
66	Джинсин        	Джинсина       
67	Джонсов        	Джонсова       
68	Джонсонов      	Джонсонова     
69	Дрейков        	Дрейкова       
70	Карриков       	Каррикова      
71	Картеров       	Картерова      
72	Картрайтов     	Картрайтова    
73	Кейганин       	Кейганина      
74	Кейджин        	Кейджина       
75	Кейсин         	Кейсина        
76	Келлин         	Келлина        
77	Кеннин         	Кеннина        
78	Кларков        	Кларкова       
79	Клинтонов      	Клинтонова     
80	Клунин         	Клунина        
81	Колдуэллов     	Колдуэллова    
82	Колинов        	Колинова       
83	Корнуэллов     	Корнуэллова    
84	Кортнин        	Кортнина       
85	Коулин         	Коулина        
86	Крисов         	Крисова        
87	Кристианин     	Кристианина    
88	Кристоферов    	Кристоферова   
89	Кросманов      	Кросманова     
90	Кроулин        	Кроулина       
91	Крузин         	Крузина        
92	Кубриков       	Кубрикова      
93	Кулиджин       	Кулиджина      
94	Лавкрафтов     	Лавкрафтова    
95	Лангин         	Лангина        
96	Ларамин        	Ларамина       
97	Линов          	Линова         
98	Лонгин         	Лонгина        
99	Лорансов       	Лорансова      
100	Лоренсин       	Лоренсина      
101	Лоуренсов      	Лоуренсова     
102	Лэмпардов      	Лэмпардова     
103	Лэнглин        	Лэнглина       
104	Малкольмов     	Малкольмова    
105	Маршаллов      	Маршаллова     
106	Мелодинов      	Мелодинова     
107	Мередитов      	Мередитова     
108	Мерсеров       	Мерсерова      
109	Милнеров       	Милнерова      
110	Мирзов         	Мирзова        
111	Моррисонов     	Моррисонова    
112	Моссов         	Моссова        
113	Моттин         	Моттина        
114	Моэмов         	Моэмова        
115	Мурманов       	Мурманова      
116	Мэдисонов      	Мэдисонова     
117	Мэллорин       	Мэллорина      
118	Мэннингов      	Мэннингова     
119	Мэрионов       	Мэрионова      
120	Найтлин        	Найтлина       
121	Николсонов     	Николсонова    
122	Нотлин         	Нотлина        
123	Ноэльнин       	Ноэльнина      
124	Ньюманов       	Ньюманова      
125	Обрин          	Обрина         
126	Остинов        	Остинова       
127	Палмеров       	Палмерова      
128	Пальмерстонов  	Пальмерстонова 
129	Пауэрин        	Пауэрина       
130	Пауэрсов       	Пауэрсова      
131	Пикфордов      	Пикфордова     
132	Пиннерин       	Пиннерина      
133	Пирсов         	Пирсова        
134	Питерсов       	Питерсова      
135	Питтов         	Питтова        
136	Портманов      	Портманова     
137	Поттеров       	Поттерова      
138	Прайорин       	Прайорина      
139	Праттов        	Праттова       
140	Преслин        	Преслина       
141	Принсов        	Принсова       
142	Прэттов        	Прэттова       
143	Райанов        	Райанова       
144	Рамзайнов      	Рамзайнова     
145	Рамзин         	Рамзина        
146	Рандолфин      	Рандолфина     
147	Редгрейвов     	Редгрейвова    
148	Реднаппов      	Реднаппова     
149	Рейганов       	Рейганова      
150	Рейнольдсов    	Рейнольдсова   
151	Рейсин         	Рейсина        
152	Рендольфов     	Рендольфова    
153	Ривзин         	Ривзина        
154	Ридов          	Ридова         
155	Ридин          	Ридина         
156	Робинсонов     	Робинсонова    
157	Роузин         	Роузина        
158	Рунин          	Рунина         
159	Рэмзин         	Рэмзина        
160	Салливанин     	Салливанина    
\.


--
-- Data for Name: tmp_name_list; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.tmp_name_list (id_name, str_name, pol) FROM stdin;
74	Агнес       	ж
75	Ида         	ж
76	Элис        	ж
77	Энн         	ж
78	Ариэль      	ж
79	Ария        	ж
80	Барбара     	ж
81	Беатрис     	ж
82	Бритни      	ж
83	Бэтти       	ж
84	Валери      	ж
85	Вэнди       	ж
86	Габриэль    	ж
87	Грэйс       	ж
88	Дебра       	ж
89	Джульет     	ж
90	Дженни      	ж
91	Джесси      	ж
92	Джилл       	ж
93	Джина       	ж
94	Джоан       	ж
95	Джоди       	ж
96	Диана       	ж
97	Дороти      	ж
98	Ирэн        	ж
99	Каролин     	ж
100	Карен       	ж
101	Лаура       	ж
102	Маделин     	ж
103	Молли       	ж
104	Абрахам     	м
105	Адам        	м
106	Адриан      	м
107	Альберт     	м
108	Альфред     	м
109	Андерсон    	м
110	Эндрю       	м
111	Энтони      	м
112	Арнольд     	м
113	Артур       	м
114	Эшли        	м
115	Остин       	м
116	Бенджамин   	м
117	Бернард     	м
118	Бриан       	м
119	Кейлиб      	м
120	Кевин       	м
121	Чэд         	м
122	Чарльз      	м
123	Кристиан    	м
124	Кристофер   	м
125	Клиффорд    	м
126	Кори        	м
127	Даррен      	м
128	Дэвид       	м
129	Дэрек       	м
130	Дональд     	м
131	Дуглас      	м
132	Эрл         	м
133	Эдгар       	м
134	Эдмунд      	м
135	Эвард       	м
136	Эдвин       	м
137	Эллиот      	м
138	Эрик        	м
139	Эрнест      	м
140	Феликс      	м
141	Франклин    	м
142	Грант       	м
143	Гарольд     	м
144	Джордж      	м
145	Гарри       	м
146	Джошуа      	м
147	Генри       	м
148	Герберт     	м
149	Хуберт      	м
150	Джек        	м
151	Йен         	м
152	Якоб        	м
153	Джеймс      	м
154	Джаспер     	м
155	Джон        	м
156	Кеннет      	м
157	Лоуренс     	м
158	Лестер      	м
159	Лукас       	м
160	Малкольм    	м
161	Маркус      	м
162	Маршалл     	м
163	Мартин      	м
164	Метью       	м
165	Майкл       	м
166	Нейтен      	м
167	Нил         	м
168	Николас     	м
169	Норман      	м
170	Оливер      	м
171	Оскар       	м
172	Освальд     	м
173	Самуэль     	м
174	Скотт       	м
175	Себастиан   	м
176	Сигмунд     	м
177	Стивен      	м
178	Сильвестр   	м
179	Теренс      	м
180	Томас       	м
181	Тимоти      	м
182	Тобиас      	м
183	Тревис      	м
184	Тристан     	м
185	Тайлер      	м
186	Винсент     	м
187	Вальтер     	м
188	Вейн        	м
189	Вилфред     	м
190	Уильям      	м
191	Винстон     	м
192	Зекери      	м
193	Велентайн   	м
\.


--
-- Data for Name: tmp_otch_list; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.tmp_otch_list (id_otch, str_otch, pol) FROM stdin;
1	Абрахамович    	м
2	Адамович       	м
3	Адрианович     	м
4	Альбертович    	м
5	Альфредович    	м
6	Андерсонович   	м
7	Эндрювич       	м
8	Энтонивич      	м
9	Арнольдович    	м
10	Артурович      	м
11	Эшливич        	м
12	Остинович      	м
13	Бенджаминович  	м
14	Бернардович    	м
15	Брианович      	м
16	Кейлибович     	м
17	Кевинович      	м
18	Чэдович        	м
19	Чарльзович     	м
20	Кристианович   	м
21	Кристоферович  	м
22	Клиффордович   	м
23	Коривич        	м
24	Дарренович     	м
25	Дэвидович      	м
26	Дэрекович      	м
27	Дональдович    	м
28	Дугласович     	м
29	Эрлович        	м
30	Эдгарович      	м
31	Эдмундович     	м
32	Эвардович      	м
33	Эдвинович      	м
34	Эллиотович     	м
35	Эрикович       	м
36	Эрнестович     	м
37	Феликсович     	м
38	Франклинович   	м
39	Грантович      	м
40	Гарольдович    	м
41	Джорджович     	м
42	Гарривич       	м
43	Джошуавич      	м
44	Генривич       	м
45	Гербертович    	м
46	Хубертович     	м
47	Джекович       	м
48	Йенович        	м
49	Якобович       	м
50	Джеймсович     	м
51	Джасперович    	м
52	Джонович       	м
53	Кеннетович     	м
54	Лоуренсович    	м
55	Лестерович     	м
56	Лукасович      	м
57	Малкольмович   	м
58	Маркусович     	м
59	Маршаллович    	м
60	Мартинович     	м
61	Метьювич       	м
62	Майклович      	м
63	Нейтенович     	м
64	Нилович        	м
65	Николасович    	м
66	Норманович     	м
67	Оливерович     	м
68	Оскарович      	м
69	Освальдович    	м
70	Самуэлович     	м
71	Скоттович      	м
72	Себастианович  	м
73	Сигмундович    	м
74	Стивенович     	м
75	Сильвестрович  	м
76	Теренсович     	м
77	Томасович      	м
78	Тимотивич      	м
79	Тобиасович     	м
80	Тревисович     	м
81	Тристанович    	м
82	Тайлерович     	м
83	Винсентович    	м
84	Вальтерович    	м
85	Вейнович       	м
86	Вилфредович    	м
87	Уильямович     	м
88	Винстонович    	м
89	Зекеривич      	м
90	Велентайнович  	м
91	Абрахамовна    	ж
92	Адамовна       	ж
93	Адриановна     	ж
94	Альбертовна    	ж
95	Альфредовна    	ж
96	Андерсоновна   	ж
97	Эндрювна       	ж
98	Энтоновна      	ж
99	Арнольдовна    	ж
100	Артуровна      	ж
101	Эшловна        	ж
102	Остиновна      	ж
103	Бенджаминовна  	ж
104	Бернардовна    	ж
105	Бриановна      	ж
106	Кейлибовна     	ж
107	Кевиновна      	ж
108	Чэдовна        	ж
109	Чарльзовна     	ж
110	Кристиановна   	ж
111	Кристоферовна  	ж
112	Клиффордовна   	ж
113	Коровна        	ж
114	Дарреновна     	ж
115	Дэвидовна      	ж
116	Дэрековна      	ж
117	Дональдовна    	ж
118	Дугласовна     	ж
119	Эрловна        	ж
120	Эдгаровна      	ж
121	Эдмундовна     	ж
122	Эвардовна      	ж
123	Эдвиновна      	ж
124	Эллиотовна     	ж
125	Эриковна       	ж
126	Эрнестовна     	ж
127	Феликсовна     	ж
128	Франклиновна   	ж
129	Грантовна      	ж
130	Гарольдовна    	ж
131	Джорджовна     	ж
132	Гарриовна      	ж
133	Джошуавна      	ж
134	Генриовна      	ж
135	Гербертовна    	ж
136	Хубертовна     	ж
137	Джековна       	ж
138	Йеновна        	ж
139	Якобовна       	ж
140	Джеймсовна     	ж
141	Джасперовна    	ж
142	Джоновна       	ж
143	Кеннетовна     	ж
144	Лоуренсовна    	ж
145	Лестеровна     	ж
146	Лукасовна      	ж
147	Малкольмовна   	ж
148	Маркусовна     	ж
149	Маршалловна    	ж
150	Мартиновна     	ж
151	Метьювна       	ж
152	Майкловна      	ж
153	Нейтеновна     	ж
154	Ниловна        	ж
155	Николасовна    	ж
156	Нормановна     	ж
157	Оливеровна     	ж
158	Оскаровна      	ж
159	Освальдовна    	ж
160	Самуэловна     	ж
161	Скоттовна      	ж
162	Себастиановна  	ж
163	Сигмундовна    	ж
164	Стивеновна     	ж
165	Сильвестровна  	ж
166	Теренсовна     	ж
167	Томасовна      	ж
168	Тимотивна      	ж
169	Тобиасовна     	ж
170	Тревисовна     	ж
171	Тристановна    	ж
172	Тайлеровна     	ж
173	Винсентовна    	ж
174	Вальтеровна    	ж
175	Вейновна       	ж
176	Вилфредовна    	ж
177	Уильямовна     	ж
178	Винстоновна    	ж
179	Зекеривна      	ж
180	Велентайновна  	ж
\.


--
-- Data for Name: visit_type; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.visit_type (id_visit_type, name_visit_type) FROM stdin;
\.


--
-- Data for Name: zab_type; Type: TABLE DATA; Schema: clinic_schema; Owner: postgres
--

COPY clinic_schema.zab_type (id_zab_type, name_zab_type) FROM stdin;
\.


--
-- Name: age_group_id_age_group_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.age_group_id_age_group_seq', 1, false);


--
-- Name: contingent_id_cont_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.contingent_id_cont_seq', 1, false);


--
-- Name: department_id_dep_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.department_id_dep_seq', 1, false);


--
-- Name: doc_type_list_id_doc_type_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.doc_type_list_id_doc_type_seq', 1, false);


--
-- Name: hospital_list_id_hospital_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.hospital_list_id_hospital_seq', 1, false);


--
-- Name: period_list_id_period_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.period_list_id_period_seq', 1, false);


--
-- Name: reg_group_id_reg_group_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.reg_group_id_reg_group_seq', 1, false);


--
-- Name: speciality_id_spec_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.speciality_id_spec_seq', 1, false);


--
-- Name: staff_id_staff_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.staff_id_staff_seq', 1, false);


--
-- Name: street_id_street_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.street_id_street_seq', 43, true);


--
-- Name: target_spo_id_target_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.target_spo_id_target_seq', 1, false);


--
-- Name: tmp_fam_list_id_fam_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.tmp_fam_list_id_fam_seq', 160, true);


--
-- Name: tmp_name_list_id_name_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.tmp_name_list_id_name_seq', 193, true);


--
-- Name: tmp_otch_list_id_otch_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.tmp_otch_list_id_otch_seq', 180, true);


--
-- Name: visit_type_id_visit_type_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.visit_type_id_visit_type_seq', 1, false);


--
-- Name: zab_type_id_zab_type_seq; Type: SEQUENCE SET; Schema: clinic_schema; Owner: postgres
--

SELECT pg_catalog.setval('clinic_schema.zab_type_id_zab_type_seq', 1, false);


--
-- Name: age_group age_group_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.age_group
    ADD CONSTRAINT age_group_pkey PRIMARY KEY (id_age_group);


--
-- Name: area area_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id_area);


--
-- Name: contingent contingent_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.contingent
    ADD CONSTRAINT contingent_pkey PRIMARY KEY (id_cont);


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
-- Name: reg_group reg_group_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.reg_group
    ADD CONSTRAINT reg_group_pkey PRIMARY KEY (id_reg_group);


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
-- Name: target_spo target_spo_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.target_spo
    ADD CONSTRAINT target_spo_pkey PRIMARY KEY (id_target);


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
-- Name: tmp_otch_list tmp_otch_list_pkey; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_otch_list
    ADD CONSTRAINT tmp_otch_list_pkey PRIMARY KEY (id_otch);


--
-- Name: tmp_otch_list tmp_otch_list_str_otch_key; Type: CONSTRAINT; Schema: clinic_schema; Owner: postgres
--

ALTER TABLE ONLY clinic_schema.tmp_otch_list
    ADD CONSTRAINT tmp_otch_list_str_otch_key UNIQUE (str_otch);


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
-- PostgreSQL database dump complete
--

