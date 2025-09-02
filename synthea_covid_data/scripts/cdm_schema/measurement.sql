IF OBJECT_ID ('cdm_schema.measurement', 'U') IS NOT NULL
  DROP TABLE cdm_schema.measurement;

CREATE TABLE cdm_schema.measurement (
  measurement_id INT, -- Autogen
  person_id INT,
  -- measurement_concept_id INT, -- No vocab table
  measurement_date DATE,
  measurement_datetime DATETIME,
  measurement_time NVARCHAR(10),
  measurement_type_concept_id INT,
  operator_concept_id INT,
  value_as_number DECIMAL(5, 2), -- Value to be decided
  value_as_concept_id INT,
  unit_concept_id INT,
  range_low DECIMAL(5, 2),
  range_high DECIMAL(5, 2),
  provider_id INT,
  visit_occurrence_id INT,
  visit_detail_id INT,
  measurement_source_value NVARCHAR(50),
  -- measurement_source_concept_id INT, -- No vocab table
  unit_source_value NVARCHAR(50),
  value_source_value NVARCHAR(50)
);
