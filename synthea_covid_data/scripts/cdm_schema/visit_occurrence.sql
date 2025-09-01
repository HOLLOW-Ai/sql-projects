IF OBJECT_ID ('cdm_schema.visit_occurrence', 'U') IS NOT NULL
  DROP TABLE cdm_schema.visit_occurrence;

CREATE TABLE cdm_schema.visit_occurrence (
  visit_occurrence_id INT,
  person_id INT,
  visit_concept_id INT,
  visit_start_date DATE,
  visit_start_datetime DATETIME,
  visit_end_date DATE,
  visit_end_datetime DATETIME,
  visit_type_concept_id INT,
  provider_id INT,
  care_site_id INT DEFAULT NULL,
  visit_source_value NVARCHAR(50),
  visit_source_concept_id INT,
  admitted_from_concept_id INT,
  admitted_from_source_value NVARCHAR(50),
  discharge_to_concept_id INT,
  discharge_to_source_value NVARCHAR(50),
  preceding_visit_occurrence_id INT
);
