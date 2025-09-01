IF OBJECT_ID ('cdm_schema.cost', 'U') IS NOT NULL
  DROP TABLE cdm_schema.cost;

CREATE TABLE cdm_schema.cost (
  cost_id INT, -- Autogen
  cost_event_id INT,
  cost_domain_id NVARCHAR(20),
  cost_type_concept_id INT,
  currency_concept_id INT,
  total_charge DECIMAL(8, 2),
  total_cost DECIMAL(8, 2),
  total_paid DECIMAL(8, 2),
  paid_by_payer DECIMAL(8, 2),
  paid_by_patient DECIMAL(8, 2),
  paid_patient_copay DECIMAL(8, 2),
  paid_patient_coinsurance DECIMAL(8, 2),
  paid_patient_deductible DECIMAL(8, 2),
  paid_by_primary DECIMAL(8, 2),
  paid_ingredient_cost DECIMAL(8, 2),
  paid_dispensing_fee DECIMAL(8, 2),
  payer_plan_period INT,
  amount_allowed DECIMAL(8, 2),
  revenue_code_concept_id INT,
  revenue_code_source_value NVARCHAR(50),
  drg_concept_id INT,
  drg_source_value NVARCHAR(3)
);
