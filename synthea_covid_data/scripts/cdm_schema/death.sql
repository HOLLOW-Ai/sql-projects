IF OBJECT_ID ('cdm_schema.death', 'U') IS NOT NULL
  DROP TABLE cdm_schema.death;

CREATE TABLE cdm_schema.death (
  person_id INT NOT NULL,
  death_date DATE NOT NULL,
  death_datetime DATETIME,
  death_type_concept_id INT DEFEAULT 32817,
  -- cause_concept_id INT
  cause_source_value NVARCHAR(50)
  -- cause_source_concept_id
);
