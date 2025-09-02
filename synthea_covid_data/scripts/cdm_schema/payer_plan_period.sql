IF OBJECT_ID ('cdm_schema.payer_plan_period', 'U') IS NOT NULL
  DROP TABLE cdm_schema.payer_plan_period;

CREATE TABLE cdm_schema.payer_plan_period (
  payer_plan_period INT NOT NULL, -- Presumably supposed to be patient_id + payer transition start year
  person_id INT NOR NULL,
  payer_plan_period_start_date DATE,
  payer_plan_period_end_date DATE,
  payer_concept_id INT DEFAULT 0,
  payer_source_value NVARCHAR(50),
  payer_source_concept_id INT,
  plan_concept_id INT,
  plan_source_value NVARCHAR(50),
  plan_source_concept_id INT,
  sponsor_concept_id INT,
  sponsor_source_value NVARCHAR(50),
  sponsor_source_concept_id INT,
  family_source_value NVARCHAR(50),
  stop_reason_concept_id INT,
  stop_reason_source_value NVARCHAR(50),
  stop_reason_source_concept_id INT
);
