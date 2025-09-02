IF OBJECT_ID ('cdm_schema.provider', 'U') IS NOT NULL
  DROP TABLE cdm_schema.provider;

CREATE TABLE cdm_schema.provider (
  provider_id INT IDENTITY(1, 1) NOT NULL, -- Autogen
  provider_name NVARCHAR(255),
  npi NVARCHAR(20),
  dea NVARCHAR(20),
  specialty_concept_id INT,
  care_site_id INT,
  year_of_birth INT,
  gender_concept_id INT,
  provider_source_value NVARCHAR(50),
  specialty_source_value NVARCHAR(50),
  specialty_source_concept_id INT,
  gender_source_value NVARCHAR(50),
  gender_source_concept_id INT
);
