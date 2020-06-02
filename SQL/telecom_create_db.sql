psql create database 
-- DATASET is available at https://mlbootcamp.ru/ru/round/15/sandbox/
-- Please consider this database as trial, so there are no restraints at the tables
-- and no set references among tables.

-- Creating the table of Customers' features and filling it up from CSV

CREATE TABLE subs_features (
SNAP_DATE	text, 
COM_CAT_1	int,
SK_ID		int,
COM_CAT_2	int,
COM_CAT_3	int,
BASE_TYPE	int,
ACT	int,
ARPU_GROUP	int,
COM_CAT_7	int,
COM_CAT_8	int,
DEVICE_TYPE_ID	int,
INTERNET_TYPE_ID	int,
REVENUE	text,
ITC		text,
VAS		text,
RENT_CHANNEL	text,
ROAM		text,
COST		text,
COM_CAT_17		text,
COM_CAT_18		text,
COM_CAT_19		text,
COM_CAT_20		text,
COM_CAT_21		text,
COM_CAT_22		text,
COM_CAT_23		text,
COM_CAT_24		text,
COM_CAT_25		int,
COM_CAT_26		int,
COM_CAT_27		text,
COM_CAT_28		text,
COM_CAT_29		text,
COM_CAT_30		text,
COM_CAT_31		text,
COM_CAT_32		text,
COM_CAT_33		text,
COM_CAT_34		int
);

COPY subs_features FROM '/Users/elenasuslova/Downloads/train/subs_features_train.csv' DELIMITER ';' CSV HEADER ;

alter table subs_features 
alter column snap_date type date using to_date(snap_date, 'DD.MM.YY') :: date , 
alter column revenue type numeric using ('0.' || substring (revenue from 2) ) :: real ,
alter column itc type numeric using ('0.' || substring (itc from 2) ) :: real ,
alter column vas type numeric using ('0.' || substring (vas from 2) ) :: real ,
alter column rent_channel type numeric using ('0.' || substring (rent_channel from 2) ) :: real ,
alter column roam type numeric using ('0.' || substring (roam from 2) ) :: real ,
alter column cost type numeric using ('0.' || substring (cost from 2) ) :: real ,
alter column com_cat_17 type numeric using ('0.' || substring (com_cat_17 from 2) ) :: real ,
alter column com_cat_18 type numeric using ('0.' || substring (com_cat_18 from 2) ) :: real ,
alter column com_cat_19 type numeric using ('0.' || substring (com_cat_19 from 2) ) :: real ,
alter column com_cat_20 type numeric using ('0.' || substring (com_cat_20 from 2) ) :: real ,
alter column com_cat_21 type numeric using ('0.' || substring (com_cat_21 from 2) ) :: real ,
alter column com_cat_22 type numeric using ('0.' || substring (com_cat_22 from 2) ) :: real ,
alter column com_cat_23 type numeric using ('0.' || substring (com_cat_23 from 2) ) :: real ,
alter column com_cat_27 type numeric using ('0.' || substring (com_cat_27 from 2) ) :: real ,
alter column com_cat_28 type numeric using ('0.' || substring (com_cat_28 from 2) ) :: real ,
alter column com_cat_29 type numeric using ('0.' || substring (com_cat_29 from 2) ) :: real ,
alter column com_cat_30 type numeric using ('0.' || substring (com_cat_30 from 2) ) :: real ,
alter column com_cat_31 type numeric using ('0.' || substring (com_cat_31 from 2) ) :: real ,
alter column com_cat_32 type numeric using ('0.' || substring (com_cat_32 from 2) ) :: real ,
alter column com_cat_33 type numeric using ('0.' || substring (com_cat_33 from 2) ) :: real ;


-- Creating the table of Survey data and filling it up from CSV

CREATE TABLE subs_csi (
SK_ID		text,
CSI		int,
CONTACT_DATE	varchar (5)
) ;

COPY subs_csi FROM '/Users/elenasuslova/Downloads/train/subs_csi_train.csv' DELIMITER ';' CSV HEADER ;

alter table subs_csi
alter column CONTACT_DATE type date using (substring(CONTACT_DATE, 4)|| '.' || substring(CONTACT_DATE, 0, 3)|| '.2002') :: date ;


-- Creating the table of Voice consumption and filling it up from CSV

CREATE TABLE subs_bs_voice_session (
SK_ID		text, 
CELL_LAC_ID	text,
VOICE_DUR_MIN	text,
START_TIME		text
) ;

COPY subs_bs_voice_session FROM '/Users/elenasuslova/Downloads/train/subs_bs_voice_session_train.csv' DELIMITER ';' CSV HEADER ;

alter table subs_bs_voice_session alter column VOICE_DUR_MIN type numeric using ('0.' || substring (VOICE_DUR_MIN from 2) ) :: real ;


-- Creating the table of Data sessions anf filling it up from CSV

CREATE TABLE subs_bs_data_session (
SK_ID		text, 
CELL_LAC_ID	text,
DATA_VOL_MB	text,
START_TIME	text
) ;

COPY subs_bs_data_session FROM '/Users/elenasuslova/Downloads/train/subs_bs_data_session_train.csv' DELIMITER ';' CSV HEADER ;

alter table subs_bs_data_session alter column DATA_VOL_MB type numeric using ('0.' || substring (DATA_VOL_MB from 2) ) :: real ;


-- Creating the table of Consumption and filling it up from CSV

CREATE TABLE subs_bs_consumption (
SK_ID		text, 
CELL_LAC_ID	text,
MON			text,
SUM_MINUTES	text,
SUM_DATA_MB	text,
SUM_DATA_MIN text
) ;

COPY subs_bs_consumption FROM '/Users/elenasuslova/Downloads/train/subs_bs_consumption_train.csv' DELIMITER ';' CSV HEADER ;

alter table subs_bs_consumption 
alter column SUM_MINUTES	type numeric using ('0.' || substring (SUM_MINUTES from 2) ) :: real ,
alter column SUM_DATA_MB	type numeric using ('0.' || substring (SUM_DATA_MB from 2) ) :: real ,
alter column SUM_DATA_MIN 	type numeric using ('0.' || substring (SUM_DATA_MIN from 2) ) :: real ;
