IF OBJECT_ID ('cdm_schema.provider', 'U') IS NOT NULL
  DROP TABLE cdm_schema.provider;

CREATE TABLE cdm_schema.provider (
  provider_id INT NOT NULL, -- Autogen
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

INSERT INTO cdm_schema.provider (
  provider_id,
  provider_name,
  npi,
  dea,
  specialty_concept_id,
  care_site_id,
  year_of_birth,
  gender_concept_id,
  provider_source_value,
  specialty_source_value,
  specialty_source_concept_id,
  gender_source_value,
  gender_source_concept_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) -- provider_id
  , name -- provider_name
  , CAST(NULL AS NVARCHAR(20)) -- npi
  , CAST(NULL AS NVARCHAR(20)) -- dea
  , 38004446 -- specialty_concept_id
  , CAST(NULL AS INT) -- care_site_id
  , CAST(NULL AS INT) -- year_of_birth
  , CASE UPPER(gender))
      WHEN 'M' THEN 8507
      WHEN 'F' THEN 8532
    END -- gender_concept_id
  , id -- provider_source_value
  , specialty -- specialty_source_value
  , 38004446 -- specialty_source_concept_id
  , gender -- gender_source_value
  , CASE UPPER(gender))
      WHEN 'M' THEN 8507
      WHEN 'F' THEN 8532
    END -- gender_source_concept_id
from synthea_schema.providers 
;
