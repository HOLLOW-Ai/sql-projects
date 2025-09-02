IF OBJECT_ID ('cdm_schema.procedure_occurrence', 'U') IS NOT NULL
  DROP TABLE cdm_schema.procedure_occurrence;

CREATE TABLE cdm_schema.procedure_occurrence (
  procedure_occurrence_id INT,
  person_id INT,
  -- procedure_concept_id INT, -- No vocab
  procedure_start_date DATE,
  procedure_start_datetime DATETIME,
  procedure_end_date DATE,
  procedure_end_datetime DATETIME,
  procedure_type_concept_id INT,
  modifier_concept_id INT,
  quantity INT,
  provider_id INT,
  visit_occurrence_id INT,
  visit_detail_id INT,
  procedure_source_value NVARCHAR(50),
  -- procedure_source_concept_id INT,
  modifier_source_value NVARCHAR(50)
);
