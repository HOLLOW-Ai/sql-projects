# Dataset
The dataset can be downloaded [here](https://projects.propublica.org/datastore/#civilian-complaints-against-new-york-city-police-officers). 

The dataset contains over 12,000 civilian complaints filed against New York City police officers from September 1985 to January 2020. The dataset contains only
complaints about closed cases for police officers who are still on the force as of late June 2020 with at least one substantiated allegation against them. More context can be found in the above link.



## Fields
For this dataset, I changed a few of the field names for better readability. The field information was taken from the data layout sheet included with the dataset download.

- `officer_id`: Unique ID of the officer
- `first_name`: Officer's first name
- `last_name`: Officer's last name
- `command_july_2020`: Officer's command assignment as of July 2020
- `complaint_id`: Unique ID of the complaint
- `month_received`: Month the complaint was received by the CCRB
- `year_received`: Year the complaint was received by the CCRB
- `command_at_incident`: Officer's command assignment at the time of the incident
- `rank_abbrev_incident`: Officer's rank at the time of the incident, abbreviation
- `rank_abbrev_july_2020`: Officer's rank as of July 2020, abbreviation
- `rank_incident`: Officer's rank at the time of the incident
- `rank_july_2020`: Officer's rank as of July 2020
- `officer_ethnicity`: Officer's ethnicity
- `officer_gender`: Officer's gender
- `officer_age_incident`: Officer's age at the time of the incident
- `complainant_ethnicity`: Complainant's ethnicity
- `complainant_gender`: Complainant's gender
- `complainant_age_incident`: Complainant's age at the time of the incident
- `fado_type`: Top-level category of complaint
- `allegation`: Specific category of complaint
- `precinct`: Precinct associated with the complaint
- `contact_reason`: Reason officer made contact with complainant
- `outcome_description`: Outcome of the contact between officer and complainant
- `board_disposition`: Finding by the CCRB

# More Info
For more information or reading, you can visit the below links to find updated data:
- https://www.50-a.org/ (According to the accompanying README file to the dataset, 50-a was a statute that was repealed by the New York State that kept police disciplinary records secret)
- https://www.propublica.org/article/your-questions-about-the-new-york-city-police-complaint-data-answered
- https://www.nyc.gov/site/ccrb/policy/MOS-records.page
- https://data.cityofnewyork.us/browse?Data-Collection_Data-Collection=CCRB+Complaints+Database&sortBy=relevance&page=1&pageSize=20
- https://www.nyclu.org/data/nypd-misconduct-database
