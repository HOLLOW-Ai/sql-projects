IF OBJECT_ID ('cdm_schema.drug_exposure', 'U') IS NOT NULL
  DROP TABLE cdm_schema.drug_exposure;

CREATE TABLE cdm_schema.drug_exposure (
  drug_exposure_id INT IDENTITY(1, 1) NOT NULL, -- Autogen
  person_id INT NOT NULL,
  -- drug_concept_id INT, -- No Vocab table
  drug_exposure_start_date DATE,
  drug_exposure_start_datetime DATETIME,
  drug_exposure_end_date DATE,
  drug_exposure_end_datetime DATETIME,
  verbatim_end_date DATE,
  drug_type_concept_id INT NOT NULL,
  stop_reason NVARCHAR(20),
  refills INT,
  quantity DECIMAL FLOAT, -- Dunno if I can input values for this one; I'm not going to guess the # of decimal places needed
  days_supply INT,
  sig NVARCHAR(1000), -- Suggests MAX on the website
  route_concept_id INT,
  lot_number NVARCHAR(50),
  provider_id INT,
  visit_occurrence_id INT,
  visit_detail_id INT,
  drug_source_value NVARCHAR(50),
  drug_source_concept_id INT,
  route_source_value NVARCHAR(50),
  dose_unit_source_value NVARCHAR(50)
);
