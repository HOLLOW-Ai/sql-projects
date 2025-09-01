IF OBJECT_ID ('cdm_schema.death', 'U') IS NOT NULL
  DROP TABLE cdm_schema.death;

CREATE TABLE cdm_schema.death (
  person_id INT,
  death_date DATE,
  death_datetime DATETIME,
  death_type_concept_id INT DEFEAULT 32817,
  -- cause_concept_id INT
  cause_source_value INT
  -- cause_source_concept_id
);
