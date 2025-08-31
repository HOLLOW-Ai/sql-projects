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
  patient      NVARCHAR(255), -- FK to Patients
  encounter    NVARCHAR(255), -- FK to Encounters
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
  severity2    NVARCHAR(255)
);


-- Care Plans
IF OBJECT_ID ('synthea_schema.careplans', 'U') IS NOT NULL
  DROP TABLE synthea_schema.careplans;

CREATE TABLE synthea_schema.careplans (
  id                  NVARCHAR(255), -- PK
  "start"             DATE,
  stop                DATE,
  patient             NVARCHAR(255), -- FK to Patients
  encounter           NVARCHAR(255), -- FK to Encounters
  code                NVARCHAR(255),
  description         NVARCHAR(255),
  reasoncode          NVARCHAR(255),
  reasondescription   NVARCHAR(255)
);


-- Conditions
IF OBJECT_ID ('synthea_schema.conditions', 'U') IS NOT NULL
  DROP TABLE synthea_schema.conditions;

CREATE TABLE synthea_schema.conditions (
  "start"       DATE,
  stop          DATE,
  patient       NVARCHAR(255), -- FK to Patients
  encounter     NVARCHAR(255), -- FK to Encounters
  system        NVARCHAR(255),
  code          NVARCHAR(255),
  description   NVARCHAR(255)
);


-- Devices
IF OBJECT_ID ('synthea_schema.devices', 'U') IS NOT NULL
  DROP TABLE synthea_schema.devices;

CREATE TABLE synthea_schema.devices (
  "start"       DATE,
  stop          DATE,
  patient       NVARCHAR(255),
  encounter     NVARCHAR(255),
  code          NVARCHAR(255),
  description   NVARCHAR(255),
  udi           NVARCHAR(255)
);


-- Encounters
IF OBJECT_ID ('synthea_schema.encounters', 'U') IS NOT NULL
  DROP TABLE synthea_schema.encounters;

CREATE TABLE synthea_schema.encounters (
  id            		NVARCHAR(255), -- PK
  "start"         		DATETIME, -- This is a UTC Date in the CSV file, changing DATE to DATETIME
  stop							  DATETIME,
  patient       		  NVARCHAR(255), -- FK to Patients
  organization   		  NVARCHAR(255), -- FK to Organization
  provider			      NVARCHAR(255), -- FK to Provider
  payer			          NVARCHAR(255), -- FK to Payer
  encounterclass		  NVARCHAR(255),
  code          		  NVARCHAR(255),
  description   		  NVARCHAR(255),
  base_encounter_cost DECIMAL(10, 2), -- I'm not presuming the precision of the cost to matter much in cents, so I'll be swapping NUMERIC for DECIMAL
  total_claim_cost		DECIMAL(10, 2),
  payer_coverage		  DECIMAL(10, 2),
  reasoncode   			  NVARCHAR(255),
  reasondescription   NVARCHAR(255)
);


-- Imaging Studies
IF OBJECT_ID ('synthea_schema.imaging_studies', 'U') IS NOT NULL
  DROP TABLE synthea_schema.imaging_studies;

CREATE TABLE synthea_schema.imaging_studies (
  id			                NVARCHAR(255), -- Not unique, imaging study can have multiple rows
  "date"                  DATETIME, -- In ISO8601 format
  patient					        NVARCHAR(255), -- FK to Patient
  encounter				        NVARCHAR(255), -- FK to Encounter
  series_uid			        NVARCHAR(255),
  bodysite_code			      NVARCHAR(255),
  bodysite_description		NVARCHAR(255),
  modality_code			      NVARCHAR(255),
  modality_description		NVARCHAR(255),
  instance_uid			      NVARCHAR(255),
  SOP_code					      NVARCHAR(255),
  SOP_description			    NVARCHAR(255),
  procedure_code			    NVARCHAR(255)
);


-- Immunizations
IF OBJECT_ID ('synthea_schema.immunizations', 'U') IS NOT NULL
  DROP TABLE synthea_schema.immunizations;

CREATE TABLE synthea_schema.immunizations (
  "date"        DATETIME, -- In ISO8601 format
  patient       NVARCHAR(255), -- FK to Patient
  encounter     NVARCHAR(255), -- FK to Encounter
  code          NVARCHAR(255),
  description   NVARCHAR(255),
  base_cost	    DECIMAL(10, 2)
);


-- Medications
IF OBJECT_ID ('synthea_schema.medications', 'U') IS NOT NULL
  DROP TABLE synthea_schema.medications;

CREATE TABLE synthea_schema.medications (
  "start"             DATETIME,
  stop                DATETIME,
  patient             NVARCHAR(255), -- FK to Patient
  payer		            NVARCHAR(255), -- FK to Payer
  encounter           NVARCHAR(255), -- FK to Encounter
  code                NVARCHAR(255),
  description         NVARCHAR(255),
  base_cost	          DECIMAL(10, 2),
  payer_coverage		  DECIMAL(10, 2),
  dispenses			      INT,
  totalcost			      DECIMAL(10, 2),
  reasoncode   	      NVARCHAR(255),
  reasondescription   NVARCHAR(255)
);


-- Observations
IF OBJECT_ID ('synthea_schema.observations', 'U') IS NOT NULL
  DROP TABLE synthea_schema.observations;

create table @synthea_schema.observations (
  "date"        DATETIME,
  patient       NVARCHAR(255), -- FK to Patient
  encounter     NVARCHAR(255), -- FK to Encounter
  category      NVARCHAR(255),
  code          NVARCHAR(255),
  description   NVARCHAR(255),
  value     		NVARCHAR(255),
  units         NVARCHAR(255),
  "type"		  	NVARCHAR(255)
);


-- Organizations
IF OBJECT_ID ('synthea_schema.organizations', 'U') IS NOT NULL
  DROP TABLE synthea_schema.organizations;

CREATE TABLE synthea_schema.organizations (
  id			      NVARCHAR(255), -- PK
  "name"	      NVARCHAR(255),
  address       NVARCHAR(255),
  city		      NVARCHAR(255),
  state     	  NVARCHAR(255),
  zip           NVARCHAR(255),
  lat		        DECIMAL(9, 6),
  lon 		      DECIMAL(9, 6),
  phone		      NVARCHAR(50),
  revenue		    DECIMAL(20, 2),
  utilization	  NVARCHAR(255)
);

-- Patients
IF OBJECT_ID ('synthea_schema.patients', 'U') IS NOT NULL
  DROP TABLE synthea_schema.patients;

CREATE TABLE synthea_schema.patients (
  id                  NVARCHAR(255), -- PK
  birthdate           DATE,
  deathdate           DATE,
  ssn                 NVARCHAR(255), -- Remove
  drivers             NVARCHAR(255), -- Remove
  passport            NVARCHAR(255), -- Is this actually in real healthcare data??
  prefix              NVARCHAR(255),
  first               NVARCHAR(255),
  middle              NVARCHAR(255),
  last                NVARCHAR(255),
  suffix              NVARCHAR(255),
  maiden              NVARCHAR(255),
  marital             NVARCHAR(255),
  race                NVARCHAR(255),
  ethnicity           NVARCHAR(255),
  gender              NVARCHAR(255),
  birthplace          NVARCHAR(255),
  address             NVARCHAR(255),
  city					      NVARCHAR(255),
  state					      NVARCHAR(255),
  county		          NVARCHAR(255),
  fips                NVARCHAR(255),
  zip						      NVARCHAR(255),
  lat		              DECIMAL(9, 6),
  lon		              DECIMAL(9, 6),
  healthcare_expenses	DECIMAL(20, 2),
  healthcare_coverage	DECIMAL(20, 2),
  income              INT
);


-- Payers
IF OBJECT_ID ('synthea_schema.payers', 'U') IS NOT NULL
  DROP TABLE synthea_schema.payers;

CREATE TABLE synthea_schema.payers (
  id                       NVARCHAR(255), -- PK
  "name"                   NVARCHAR(255),
  ownership                varchar NULL, -- Curious as to why this is NULL, check the CSV later
  address                  NVARCHAR(255),
  city                     NVARCHAR(255),
  state_headquartered      NVARCHAR(255),
  zip                      NVARCHAR(255),
  phone                    NVARCHAR(255),
  amount_covered           DECIMAL(20, 2),
  amount_uncovered         DECIMAL(20, 2),
  revenue                  DECIMAL(20, 2),
  covered_encounters       INT, -- All of these are classified as NUMERIC, but I'm going to be changing it to INT because presumably, it shouldn't be a decimal
  uncovered_encounters     INT,
  covered_medications      INT,
  uncovered_medications    INT,
  covered_procedures       INT,
  uncovered_procedures     INT,
  covered_immunizations    INT,
  uncovered_immunizations  INT,
  unique_customers         INT,
  qols_avg                 DECIMAL(5, 2), -- Check the CSV later
  member_months            INT -- Check CSV later
);


-- Payer Transitions
-- I honestly imagine I'm not going to be using this table, tbh
IF OBJECT_ID ('synthea_schema.payer_transitions', 'U') IS NOT NULL
  DROP TABLE synthea_schema.payer_transitions;

CREATE TABLE synthea_schema.payer_transitions (
  patient          NVARCHAR(255), -- FK to Patient
  memberid         NVARCHAR(255),
  start_date       DATE,
  end_date         DATE,
  payer            NVARCHAR(255), -- FK to Payers
  secondary_payer  NVARCHAR(255), -- Optional FK to Payers
  plan_ownership   NVARCHAR(255),
  owner_name       NVARCHAR(255)
);


-- Procedures
IF OBJECT_ID ('synthea_schema.procedures', 'U') IS NOT NULL
  DROP TABLE synthea_schema.procedures;

CREATE TABLE synthea_schema.procedures (
  "start"           DATETIME,
  stop              DATETIME,
  patient           NVARCHAR(255), -- FK to Patient
  encounter         NVARCHAR(255), -- FK to Encounter
  system            NVARCHAR(255),
  code              NVARCHAR(255),
  description       NVARCHAR(255),
  base_cost		      DECIMAL(10, 2),
  reasoncode	      NVARCHAR(255),
  reasondescription	NVARCHAR(255)
);


-- Providers
IF OBJECT_ID ('synthea_schema.providers', 'U') IS NOT NULL
  DROP TABLE synthea_schema.providers;

CREATE TABLE synthea_schema.providers (
  id             NVARCHAR(255), -- PK
  organization   NVARCHAR(255), -- FK to Organization
  "name"         NVARCHAR(255),
  gender         NVARCHAR(255),
  speciality     NVARCHAR(255),
  address        NVARCHAR(255),
  city           NVARCHAR(255),
  state          NVARCHAR(255),
  zip            NVARCHAR(255),
  lat            DECIMAL(9, 6),
  lon            DECIMAL(9, 6),
  encounters     INT,
  "procedures"   INT
);


-- Supplies
-- I don't imagine I'll be using this table
IF OBJECT_ID ('synthea_schema.supplies', 'U') IS NOT NULL
  DROP TABLE synthea_schema.supplies;

CREATE TABLE synthea_schema.supplies (
  "date"       DATE,
  patient      NVARCHAR(255), -- FK to Patient
  encounter    NVARCHAR(255), -- FK to Encounter
  code         NVARCHAR(255),
  description  NVARCHAR(255),
  quantity     INT -- I assume this to be a whole number, but check CSV anyway
);
