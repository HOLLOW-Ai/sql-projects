/*
  This really is just a copy-paste of the SQL initialization code provided by the ETL-Synthea github page, but edited for my personal use case.
  Edited with the conventions I use when writing out SQL stuff.

  I'm not going to bother with the key constraints because I'd rather truncate the table easily, then drop the table completely or remove and re-add the key constraints.
  Also, the COVID Synthea data doesn't include the claims and claims_transactions files, so that has been removed from the original code.
  Going to keep the data types as NVARCHAR and switch out the NUMERIC types for DECIMAL instead. Despite this being a small dataset for a database, I'd rather not inflate the storage size. I'll keep NVARCHAR(255).

  Rename columns appropriately when transforming the data be similar to the standard ODOM CDM format.
*/


-- Allergies
IF OBJECT_ID ('synthea_schema.allergies', 'U') IS NOT NULL
  DROP TABLE synthea_schema.allergies;

CREATE TABLE synthea_schema.allergies (
  "start"      DATE,
  stop         DATE,
  patient      NVARCHAR(255),
  encounter    NVARCHAR(255),
  code         NVARCHAR(255),
  system       NVARCHAR(255),
  description  NVARCHAR(255),
  "type"       NVARCHAR(255),
  category     NVARCHAR(255),
  reaction1    NVARCHAR(255),
  description1 NVARCHAR(255),
  severity1    NVARCHAR(255),
  reaction2    NVARCHAR(255),
  description2 NVARCHAR(255),
  severity2    NVARCHAR(255),
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.careplans (
id            varchar(1000),
"start"         date,
stop          date,
patient       varchar(1000),
encounter     varchar(1000),
code          varchar(100),
description   varchar(255),
reasoncode   varchar(255),
reasondescription   varchar(255)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.conditions (
"start"         date,
stop          date,
patient       varchar(1000),
encounter     varchar(1000),
system      varchar(1000),
code          varchar(100),
description   varchar(255)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.encounters (
id            		varchar(1000),
"start"         		date,
stop							date,
patient       		varchar(1000),
organization   		varchar(1000),
provider			varchar(1000),
payer			varchar(1000),
encounterclass		varchar(1000),
code          		varchar(100),
description   		varchar(255),
base_encounter_cost numeric,
total_claim_cost		numeric,
payer_coverage		numeric,
reasoncode   			varchar(100),
reasondescription varchar(255)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.immunizations (
"date"        date,
patient       varchar(1000),
encounter     varchar(1000),
code          varchar(100),
description   varchar(255),
base_cost	numeric
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.imaging_studies (
id			  varchar(1000),
"date"        date,
patient					varchar(1000),
encounter				varchar(1000),
series_uid			varchar(1000),
bodysite_code			varchar(100),
bodysite_description		varchar(255),
modality_code			varchar(100),
modality_description		varchar(255),
instance_uid			varchar(1000),
SOP_code					varchar(100),
SOP_description			varchar(255),
procedure_code			varchar(255)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.medications (
"start"         date,
stop          date,
patient       varchar(1000),
payer		varchar(1000),
encounter     varchar(1000),
code          varchar(100),
description   varchar(1000),
base_cost	  numeric,
payer_coverage		numeric,
dispenses			int,
totalcost			numeric,
reasoncode   	varchar(100),
reasondescription   varchar(255)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.observations (
"date"         date,
patient       varchar(1000),
encounter     varchar(1000),
category      varchar(1000),
code          varchar(100),
description   varchar(255),
value     		varchar(1000),
units         varchar(100),
"type"		  	varchar(100)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.organizations (
id			  varchar(1000),
"name"	      varchar(1000),
address       varchar(1000),
city		  varchar(100),
state     	  varchar(100),
zip           varchar(100),
lat		numeric,
lon 		numeric,
phone		  varchar(100),
revenue		numeric,
utilization	  varchar(100)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.patients (
id            varchar(1000),
birthdate     date,
deathdate     date,
ssn           varchar(100),
drivers       varchar(100),
passport      varchar(100),
prefix        varchar(100),
first         varchar(100),
middle         varchar(100),
last          varchar(100),
suffix        varchar(100),
maiden        varchar(100),
marital       varchar(100),
race          varchar(100),
ethnicity     varchar(100),
gender        varchar(100),
birthplace    varchar(100),
address       varchar(100),
city					varchar(100),
state					varchar(100),
county		varchar(100),
fips varchar(100),
zip						varchar(100),
lat		numeric,
lon		numeric,
healthcare_expenses	numeric,
healthcare_coverage	numeric,
income int
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.procedures (
"start"         date,
stop          date,
patient       varchar(1000),
encounter     varchar(1000),
system          varchar(100),
code          varchar(100),
description   varchar(255),
base_cost		numeric,
reasoncode	varchar(1000),
reasondescription	varchar(1000)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.providers (
id varchar(1000),
organization varchar(1000),
"name" varchar(100),
gender varchar(100),
speciality varchar(100),
address varchar(255),
city varchar(100),
state varchar(100),
zip varchar(100),
lat numeric,
lon numeric,
encounters int,
"procedures" int
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.devices (
"start"         date,
stop          date,
patient       varchar(1000),
encounter     varchar(1000),
code          varchar(100),
description   varchar(255),
udi           varchar(255)
);



--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.payer_transitions (
 patient           varchar(1000),
  memberid         varchar(1000),
  start_date       date,
  end_date         date,
  payer            varchar(1000),
  secondary_payer  varchar(1000),
  plan_ownership        varchar(1000),
  owner_name       varchar(1000)
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.payers (
  id                       varchar(1000),
  "name"                     varchar(1000),
  ownership                varchar NULL,
  address                  varchar(1000),
  city                     varchar(1000),
  state_headquartered      varchar(1000),
  zip                      varchar(1000),
  phone                    varchar(1000),
  amount_covered           numeric,
  amount_uncovered         numeric,
  revenue                  numeric,
  covered_encounters       numeric,
  uncovered_encounters     numeric,
  covered_medications      numeric,
  uncovered_medications    numeric,
  covered_procedures       numeric,
  uncovered_procedures     numeric,
  covered_immunizations    numeric,
  uncovered_immunizations  numeric,
  unique_customers         numeric,
  qols_avg                 numeric,
  member_months            numeric
);

--HINT DISTRIBUTE_ON_RANDOM
create table @synthea_schema.supplies (
  "date"       date,
  patient      varchar(1000),
  encounter    varchar(1000),
  code         varchar(1000),
  description  varchar(1000),
  quantity     numeric
);
