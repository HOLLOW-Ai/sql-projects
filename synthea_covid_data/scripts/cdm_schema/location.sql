IF OBJECT_ID ('cdm_schema.location', 'U') IS NOT NULL
  DROP TABLE cdm_schema.location;

CREATE TABLE cdm_schema.location (
  location_id INT IDENTITY(1, 1) NOT NULL, -- Autogen
  address_1 NVARCHAR(50),
  address_2 NVARCHAR(50),
  city NVARCHAR(50),
  "state" NVARCHAR(2),
  county NVARCHAR(20),
  zip NVARCHAR(9),
  location_source_value NVARCHAR(50),
  -- This example doesn't include Latitude and Longitude on the Github page
  latitude DECIMAL(9, 6),
  longitude DECIMAL(9, 6)
);

INSERT INTO cdm_schema.location (
  location_id,
  address_1,
  address_2,
  city,
  state,
  county,
  zip,
  location_source_value,
  latitude,
  longitude
)
SELECT 
  ROW_NUMBER() OVER (ORDER BY P.city, P.state, P.zip), -- location_id
  CAST(NULL AS NVARCHAR), -- address_1
  CAST(NULL AS NVARCHAR), -- address_2
  P.city, -- city
  P.state, -- state
  P.county, -- county
  P.zip, -- zip
  P.zip, -- location_source_value
  P.lat, -- latitude
  P.lon -- longitude
FROM synthea_schema.patients AS P
;
