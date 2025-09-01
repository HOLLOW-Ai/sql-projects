IF OBJECT_ID ('cdm_schema.condition_occurrence', 'U') IS NOT NULL
  DROP TABLE cdm_schema.condition_occurrence;

CREATE TABLE cdm_schema.condition_occurrence (
  condition_occurrence_id INT, -- Autogen
  person_id INT,
  -- condition_concept_id INT, -- Dont have the Vocab table
  condition_start_date DATE,
  condition_start_datetime DATETIME,
  condition_end_date DATE,
  condition_end_datetime DATETIME,
  condition_type_concept_id INT DEFAULT 32827,
  stop_reason NVARCHAR(20),
  provider_id INT,
  visit_occurrence_id INT,
  visit_detail_id INT,
  condition_source_value NVARCHAR(50),
  -- condition_source_concept_id, -- Dont have Vocab table
  condition_status_source_value NVARCHAR(50),
  condition_status_concept_id INT
);
