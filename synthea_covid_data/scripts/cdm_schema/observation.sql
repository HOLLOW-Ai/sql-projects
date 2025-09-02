IF OBJECT_ID ('cdm_schema.observation', 'U') IS NOT NULL
  DROP TABLE cdm_schema.observation;

CREATE TABLE cdm_schema.observation (
  observation_id INT IDENTITY(1, 1) NOT NULL, -- Autogen
  person_id INT NOT NULL,
  -- observation_concept_id INT,
  observation_date DATE,
  observation_datetime DATETIME,
  observation_type_concept_id INT DEFAULT 38000280,
  value_as_number FLOAT, -- Check later
  value_as_string NVARCHAR(60),
  value_as_concept_id INT DEFAULT 0,
  qualifier_concept_id INT DEFAULT 0,
  unit_concept_id INT DEFAULT 0,
  provider_id INT,
  visit_occurrence_id INT,
  visit_detail_id INT,
  observation_source_value NVARCHAR(50),
  -- observation_source_concept_id INT,
  unit_source_value NVARCHAR(50),
  qualifier_source_value NVARCHAR(50),
  value_source_value NVARCHAR(50),
  observation_event_id INT, -- Or Bigint?
  obs_event_field_concept_id INT
);
