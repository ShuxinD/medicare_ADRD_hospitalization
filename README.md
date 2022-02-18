# ADRD Medicare hospitalization data

Main goal is to create the dataset of hospitalization records with ADRD. In the future, we may consider move the ADRD Medicare cohort related codes into this repo.

We decided to use CCW's ICD list to identify ADRD in the first 10 billing codes in Medicare FFS inpatient data.

## why CCW's ICD list instead of others?

We want to have consistent number of hospitalizations with ADRD over 2000-2016. We achieved it only with CCW's list: https://www2.ccwdata.org/web/guest/condition-categories

[ccw-cond-algo-alzdisorders.pdf](https://github.com/ShuxinD/ADRDdata/files/8043131/ccw-cond-algo-alzdisorders.pdf)

The plot with Shuxin's list generated from Lidia's and Taylor's papers:

[ADRDtrend.pdf](https://github.com/ShuxinD/ADRDdata/files/8043029/ADRDtrend.pdf)


## why first 10 billing codes instead of all 25?

The plot with CCW's list but screening for all 25 codes:

[ADRDtrend.pdf](https://github.com/ShuxinD/ADRDdata/files/8043033/ADRDtrend.pdf)

## Data Columns

``` R
> library(fst)
> df <- read_fst("ADRD_2000.fst")
> colnames(df)

[1] "QID"          "ADATE"        "DDATE"        "zipcode_R"    "DIAG1"       
 [6] "DIAG2"        "DIAG3"        "DIAG4"        "DIAG5"        "DIAG6"       
[11] "DIAG7"        "DIAG8"        "DIAG9"        "DIAG10"       "AGE"         
[16] "Sex_gp"       "Race_gp"      "SSA_STATE_CD" "SSA_CNTY_CD"  "PROV_NUM"    
[21] "ADM_SOURCE"   "ADM_TYPE"     "Dual"         "year"         "AD_primary"  
[26] "AD_any"       "ADRD_primary" "ADRD_any"   
```

## Data Dictionary 

| Fieldname | Source |  Description | Role |
| --------- | ------ | ------------ | ---- |
| QID | Medicare | Person's ID | ID |
| ADATE | Medicare | Admission date | Outcome |
| DDATE | Medicare | Discharge date | Outcome |
| zipcode_R | Medicare | Zipcode | Location |
| DIAG 1-10 | Medicare | Billing codes as ICD codes | Outcome |
| AGE | Medicare | Age | Confounder |
| Sex_gp | Medicare | Sex | Confounder |
| Race_gp | Medicare | Race | Confounder |
| SSA_STATE_CD | Medicare | State code | Location |
| SSA_CNTY_CD | Medicare | County code | Location |
| PROV_NUM | Medicare | Hospital ID | Location |
| ADM_SOURCE | Medicare | Admission source | Confounder |
| ADM_TYPE | Medicare | Admission type (1 - Emergency, 2 - Urgent, 3 - Elective) | Confounder |
| Dual | Medicare | Eligible for both Medicare and Medicaid (1 - yes, 0 - otherwise) | Confounder |
| year | R | Year of hospital admission (from 2000 to 2016) | Outcome |
| AD_primary | R | Does the ICD code of Alzheimer's disease appear in the first billing code? (T/F) | Outcome |
| AD_any | R | Does the ICD code of Alzheimer's disease appear in any of the first ten billing codes (DIAG 1-10)? (T/F) | Outcome |
| ADRD_primary | R | Do ADRD ICD codes appear as first diagnosis? (T/F) | Outcome |
| ADRD_any | R | Do ADRD ICD codes appear in any of the first ten billing codes (DIAG 1-10)? (T/F) | Outcome |

|  | List ICD codes to identify AD/ADRD (used as exclusion/inclusion criteria). Ref: [ccw-cond-algo-alzdisorders.pdf](https://github.com/ShuxinD/ADRDdata/files/8043131/ccw-cond-algo-alzdisorders.pdf) |
| ------ | ------------------------------------------------------------------- |
| ICD9   | 3310, 33111, 33119, 3312, 3317, 2900, 29010, 29011, 29012, 29013, 29020, 29021, 2903, 29040, 29041, 29042, 29043, 2940, 29410, 29411, 29420, 29421, 2948, 797 |
| ICD10 | F0150, F0151, F0280, F0281, F0390, F0391, F04, G138, F05, F061, F068, G300, G301, G308, G309, G311, G312, G3101, G3109, G94, R4181, R54 |

## Variable Description 

| | ADM_SOURCE - Admission source |
| - | ------------------ |
| 1 | Physician referral | 
| 2 | Clinic referral    |
| 3 | HMO referral       |
| 4 | Transfer from hospital |
| 5 | Transfer from a SNF |
| 6 | another health care facility |
| 7 | Emergency room |

