IF OBJECT_ID ('cdm_schema.visit_detail', 'U') IS NOT NULL
  DROP TABLE cdm_schema.visit_detail;

CREATE TABLE cdm_schema.visit_detail (
  visit_detail_id INT,
  person_id INT,
  visit_detail_concept_id INT,
  visit_detail_start_date DATE,
  visit_detail_start_datetime DATETIME,
  visit_detail_end_date DATE,
  visit_detail_end_datetime DATETIME,
  visit_detail_type_concept_id INT,
  provider_id INT,
  care_site_id INT DEFAULT NULL,
  admitted_from_source_concept_id INT DEFAULT 0,
  admitted_from_source_value NVARCHAR(50) DEFAULT NULL,
  discharged_to_concept_id INT DEFAULT 0,
  discharged_to_source_value NVARCHAR(50) DEFAULT NULL,
  preceding_visit_detail_id INT,
  visit_detail_source_value NVARCHAR(50),
  visit_detail_source_concept_id INT DEFAULT 0,
  visit_occurrence_id INT
);
