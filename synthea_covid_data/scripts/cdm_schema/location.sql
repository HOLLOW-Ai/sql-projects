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
