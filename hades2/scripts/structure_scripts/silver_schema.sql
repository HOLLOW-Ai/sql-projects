CREATE TABLE silver.run_log (
  night INT,
  world NVARCHAR(15),
  weapon NVARCHAR(20),
  familiar NVARCHAR(10),
  recorded_time NVARCHAR(15),
  [minutes] INT,
  seconds INT,
  milliseconds INT,
  outcome NVARCHAR(10),
  killed_in NVARCHAR(25),
  cause_of_death NVARCHAR(15),
  specific_cause NVARCHAR(25),
  fear INT,
  run_type NVARCHAR(15)
);

CREATE TABLE silver.keepsake_log (
  night INT,
  keepsake NVARCHAR(25),
  keepsake_num INT
);

CREATE TABLE silver.weapon_log (
  night INT,
  weapon NVARCHAR(20),
  aspect NVARCHAR(15),
  upgrade NVARCHAR(25)
);

CREATE TABLE silver.vow_log (
  night INT,
  vow NVARCHAR(20)
);

CREATE TABLE silver.arcana_log (
  night INT,
  arcana NVARCHAR(25),
  grasp INT
);

CREATE TABLE silver.boon_log (
  night INT,
  origin NVARCHAR(20),
  char_name NVARCHAR(20),
  effect NVARCHAR(15),
  boon NVARCHAR(50)
);
