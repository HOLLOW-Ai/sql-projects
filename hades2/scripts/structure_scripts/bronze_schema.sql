CREATE DATABASE hades;
USE hades;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

DROP TABLE IF EXISTS bronze.run_log;
CREATE TABLE bronze.run_log (
  night INT,
  world NVARCHAR(15),
  weapon NVARCHAR(25),
  familiar NVARCHAR(10),
  [time] NVARCHAR(20), 
  outcome NVARCHAR(15),
  killed_in NVARCHAR(50),
  slain_by NVARCHAR(20),
  specific_enemy NVARCHAR(50),
  fear INT,
  run_type NVARCHAR(15)
);

CREATE TABLE bronze.keepsake_log (
  night INT,
  keepsake NVARCHAR(50),
  keepsake_num INT
);

CREATE TABLE bronze.weapon_log (
  night INT,
  weapon NVARCHAR(20),
  aspect NVARCHAR(20),
  upgrade NVARCHAR(50)
);

CREATE TABLE bronze.vow_log (
  night INT,
  vow NVARCHAR(20)
);

CREATE TABLE bronze.arcana_log (
  night INT,
  arcana NVARCHAR(50),
  grasp INT
);

CREATE TABLE bronze.boon_log (
  night INT,
  origin NVARCHAR(20),
  name NVARCHAR(20),
  effect NVARCHAR(15),
  boon NVARCHAR(50)
);
