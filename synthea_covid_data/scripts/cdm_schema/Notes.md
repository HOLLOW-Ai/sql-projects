This is all based on the ODOM CDM's github page for ETL-Synthea and their intro to ETL powerpoint presentation I found. I can't seem to find any of their SQL scripts pertaining to vocabularies or metadata to which I can use to build the CDM schema.

I cannot fully build the standardized CDM they have, so I will try my best. I'm unsure if I can correctly map everything to the vocabulary.

The vocabulary needs to be downloaded from [Athena](https://athena.ohdsi.org/search-terms/start). However, an account does need to be created. Considering this is just practice, I'll opt out of doing this since the initial purpose of this project was to practice data cleaning and analysis in SQL, and then visualize results in Power BI. I did not intend to look into ODOM CDM. I did find a [tutorial](https://www.youtube.com/watch?v=FCHxAQOBptE) on how to download the vocabularies. I also did the find the [github](https://github.com/OHDSI/Vocabulary-v5.0/wiki/General-Structure,-Download-and-Use) tutorial page as well.

Essentially, I won't be creating the "Source_Concept" columns or Vocab tables.

Order to build the CDM tables:
1. person
2. observation_period
3. visit_occurrence
4. Other tables because they rely on the visit_occurrence_id

# Reference Links
- https://ohdsi.github.io/TheBookOfOhdsi/CommonDataModel.html#cdm-standardized-tables
- https://ohdsi.github.io/ETL-Synthea/index.html
- https://github.com/OHDSI/ETL-Synthea/tree/main/inst/sql/sql_server/cdm_version/v540
- https://ohdsi.github.io/CommonDataModel/cdm54.html#person
- https://ohdsi.github.io/Themis/death.html


# Person
Tables needed:
- Patients (Synthea)

# Observation Period
Tables needed:
- Patients (Synthea)
- Person (CDM)

# All Visits
This needs to be created because you need it for a column in Visit Occurrence.
This table can be created using the script found in the ETL-Synthea [page](https://github.com/OHDSI/ETL-Synthea/blob/main/inst/sql/sql_server/cdm_version/v540/AllVisitTable.sql).

# AAVI Table
[Link](https://github.com/OHDSI/ETL-Synthea/blob/main/inst/sql/sql_server/cdm_version/v540/AAVITable.sql) found here.

# Final Visit IDs Temp Table
[Link](https://github.com/OHDSI/ETL-Synthea/blob/main/inst/sql/sql_server/cdm_version/v540/final_visit_ids.sql) here. Neeeded for Condition Occurrence

# Visit Occurrence
Tables needed:
- All Visits (CDM)
- Person (CDM)
- Encounters (Synthea)?

# Care Site
Tables needed:
- Organizations (Synthea)

# Condition Occurrence
Tables:
- Conditions (Synthea)

# Cost
Tables:
- Procedures (Syn)
- Immunizations (Syn)
- Medications (Syn)
- Encounters (Syn)
- Person (CDM)

This requires claims and claims transactions, which was not included in Synthea.

# Death
Tables:
- Person (CDM)
- Encounters (SYN)

# Device Exposure
Tables:
- Devices (Synthea)

# Drug Exposure
- Medications (SYN)
- Immunizations (SYN)

# Location
- Patients (SYN)

# Measurement
- Procedures (SYN)
- Observations (SYN)

# Observation
- Allergies (SYN)
- Conditions (SYN)
- Observations (SYN)

# Observation Period
- Encounters (SYN)

# Payer Plan Period
- Payers (SYN)
- Payer Transitions (SYN)

# Procedure Occurrence
- Procedures (SYN)

# Provider
- Providers (SYN)

# Visit Detail
- All Visits
- Encounters
- Final Visit
