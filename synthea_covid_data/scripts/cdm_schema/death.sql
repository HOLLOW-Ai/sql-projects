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


-- Person needs to be created first
INSERT INTO cdm_schema.death (
    person_id
  , death_date
  , death_datetime
  , death_type_concept_id
  , cause_source_value
)
SELECT
    P.person_id -- person_id
  , E.start  -- death_date
  , E.start  -- death_datetime
  , 32817  -- death_type_concept_id
  , E.reasoncode  -- cause_source_value
FROM cdm_schema.person AS P
INNER JOIN synthea_schema.encounters AS E
  ON P.person_source_value = E.patient
WHERE E.code = '308646001'
;
