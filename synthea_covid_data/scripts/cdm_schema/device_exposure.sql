IF OBJECT_ID ('cdm_schema.device_exposure', 'U') IS NOT NULL
  DROP TABLE cdm_schema.device_exposure;

CREATE TABLE cdm_schema.device_exposure (
  device_exposure_id INT IDENTITY(1, 1) NOT NULL, -- Autogen
  person_id INT NOT NULL,
  -- device_concept_id INT, -- Dont have the Vocab table
  device_exposure_start_date DATE,
  device_exposure_start_datetime DATETIME,
  device_exposure_end_date DATE,
  device_exposure_end_datetime DATETIME,
  device_type_concept_id INT DEFAULT 32827,
  unique_device_id NVARCHAR(255),
  production_id NVARCHAR(255),
  quantity INT,
  provider_id INT,
  visit_occurrence_id INT,
  visit_detail_id INT,
  device_source_value NVARCHAR(50),
  device_source_concept_id INT
);
