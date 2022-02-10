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
