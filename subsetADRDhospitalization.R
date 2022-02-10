#' Code: extract AD/ADRD hopspitalization info from general in-patient files
#' Input: hospitalization files
#' Output: "ADRD_`year`.fst"
#' Author: Shuxin Dong
#' First create date: 2021-02-03

## setup ----
rm(list = ls())
gc()

library(data.table)
library(fst)
library(NSAPHutils)
library(lubridate)
library(icd)

setDTthreads(threads = 0)
setwd("/nfs/home/S/shd968/shared_space/ci3_shd968/ADRDhospitalization/")
dir_hospital <- "/nfs/home/S/shd968/shared_space/ci3_health_data/medicare/gen_admission/1999_2016/targeted_conditions/cache_data/admissions_by_year/"

dir_output <- "/nfs/home/S/shd968/shared_space/ci3_analysis/data_ADRDhospitalization/ADRDhospitalization_CCWlist/"

## ICD code info ----
outcomes <- list()
## using lists from CCW: https://www2.ccwdata.org/web/guest/condition-categories
outcomes[["AD"]] <- list(
  "icd9" = c(children("3310")),
  "icd10" = c(children("G300"), children("G301"), children("G308"), children("G309"))
)
outcomes[["ADRD"]] <- list(
  "icd9" = c(children("3310"), children("33111"), children("33119"), children("3312"), children("3317"),
             children("2900"), children("29010"), children("29011"), children("29012"), children("29013"), 
             children("29020"), children("29021"),
             children("2903"), children("29040"), children("29041"), children("29042"), children("29043"), children("2940"),
             children("29410"), children("29411"), children("29420"), children("29421"), children("2948"), children("797")),
  "icd10" = c(children("F0150"), children("F0151"), 
              children("F0280"), children("F0281"), 
              children("F0390"), children("F0391"), 
              children("F04"), 
              children("G138"), 
              children("F05"),
              children("F061"), children("F068"), 
              children("G300"), children("G301"), children("G308"), children("G309"), children("G311"), children("G312"), children("G3101"), children("G3109"),
              children("G94"), children("R4181"), children("R54")))
  
## following is Shuxin's original list based on Taylor and Lidia's paper
# outcomes[["ADRD"]][["icd9"]] <- c("290", # dementia group
#                                   children("2900"), # senile dementia, uncomplicatied
#                                   children("2901"), # Presenile dementia (brain syndrome w/ presenile dementia)
#                                   children("2902"), # Senile dementia with delusional or depressive features
#                                   children("2903"), # Senile dementia, w/ delirium
#                                   children("2904"), # Vascular dementia
#                                   children("2940"), # Amnestic syndrome (Korsakoff’s psychosis or syndrome, nonalcoholic)
#                                   children("2941"), # Dementia in conditions classified elsewhere
#                                   children("2948"), # Other persistent mental disorders due to conditions classified elsewhere
#                                   children("3310"), # Alzheimer’s disease
#                                   children("3311"), # Frontotemporal dementia
#                                   children("3312"), # Senile degeneration of the brain
#                                   children("3317"), # Cerebral degeneration in diseases classified elsewhere
#                                   children("797")) # Senility without mention of psychosis)
# outcomes[["ADRD"]][["icd10"]] <- c(children("F01"),
#                                    children("F02"),
#                                    "F0390",
#                                    children("G30"),
#                                    children("G310"), "G311", "G312",
#                                    "R4181")

adICDs <- c(outcomes[["AD"]][["icd9"]], outcomes[["AD"]][["icd10"]])
adrdICDs <- c(outcomes[["ADRD"]][["icd9"]], outcomes[["ADRD"]][["icd10"]])

## extract hospitalization info ----
## clear out old data in case of re-run
file.remove(list.files(dir_output, 
                       pattern = ".fst",
                       full.names = T))
## test run to check the inpatient data files
# temp <- read_fst(paste0(dir_hospital, "admissions_2001.fst")) # load 2001 hospitalization data
## the varaible contains in the dataset
# [1] "QID"                       "AGE"                       "SEX"                      
# [4] "RACE"                      "SSA_STATE_CD"              "SSA_CNTY_CD"              
# [7] "PROV_NUM"                  "ADM_SOURCE"                "ADM_TYPE"                 
# [10] "ADATE"                     "DDATE"                     "BENE_DOD"                 
# [13] "DODFLAG"                   "ICU_DAY"                   "CCI_DAY"                  
# [16] "ICU"                       "CCI"                       "DIAG1"                    
# [19] "DIAG2"                     "DIAG3"                     "DIAG4"                    
# [22] "DIAG5"                     "DIAG6"                     "DIAG7"                    
# [25] "DIAG8"                     "DIAG9"                     "DIAG10"                   
# [28] "diag11"                    "diag12"                    "diag13"                   
# [31] "diag14"                    "diag15"                    "diag16"                   
# [34] "diag17"                    "diag18"                    "diag19"                   
# [37] "diag20"                    "diag21"                    "diag22"                   
# [40] "diag23"                    "diag24"                    "diag25"                   
# [43] "YEAR"                      "LOS"                       "Parkinson_pdx"            
# [46] "Parkinson_pdx2dx_10"       "Parkinson_pdx2dx_25"       "Alzheimer_pdx"            
# [49] "Alzheimer_pdx2dx_10"       "Alzheimer_pdx2dx_25"       "Dementia_pdx"             
# [52] "Dementia_pdx2dx_10"        "Dementia_pdx2dx_25"        "CHF_pdx"                  
# [55] "CHF_pdx2dx_10"             "CHF_pdx2dx_25"             "AMI_pdx"                  
# [58] "AMI_pdx2dx_10"             "AMI_pdx2dx_25"             "COPD_pdx"                 
# [61] "COPD_pdx2dx_10"            "COPD_pdx2dx_25"            "DM_pdx"                   
# [64] "DM_pdx2dx_10"              "DM_pdx2dx_25"              "Stroke_pdx"               
# [67] "Stroke_pdx2dx_10"          "Stroke_pdx2dx_25"          "CVD_pdx"                  
# [70] "CVD_pdx2dx_10"             "CVD_pdx2dx_25"             "CSD_pdx"                  
# [73] "CSD_pdx2dx_10"             "CSD_pdx2dx_25"             "Ischemic_stroke_pdx"      
# [76] "Ischemic_stroke_pdx2dx_10" "Ischemic_stroke_pdx2dx_25" "Hemo_Stroke_pdx"          
# [79] "Hemo_Stroke_pdx2dx_10"     "Hemo_Stroke_pdx2dx_25"     "zipcode_R"                
# [82] "Race_gp"                   "Sex_gp"                    "age_gp"                   
# [85] "Dual"

# rm(temp);gc()

for (year_ in 2000:2016) {
  cat("Loading", year_, "hospitalization file... \n")
  adm_y <- read_data(dir_hospital, years = year_,
                     columns = c("QID", "ADATE", "DDATE", "zipcode_R", paste0("DIAG", 1:10), "AGE", "Sex_gp", "Race_gp", "SSA_STATE_CD", "SSA_CNTY_CD", "PROV_NUM", "ADM_SOURCE", "ADM_TYPE", "Dual")) # include all the possible information we may use in the future
  diagICD_cols <- paste0("DIAG", 1:10)
  adm_y[ ,(diagICD_cols) := lapply(.SD, as.character), # Change class of diagnosis codes to character
         .SDcols = diagICD_cols]
  
  adm_y[, ADATE := dmy(ADATE)][, DDATE := dmy(DDATE)]
  adm_y[, year := year(ADATE)] # year here denote year of admission
  adm_y <- adm_y[year %in% 2000:2016,] # only include admission year between 2000 and 2016
  adm_y[, AD_primary := DIAG1 %in% adICDs]
  adm_y[, AD_any :=
          DIAG1 %in% adICDs|
          DIAG2 %in% adICDs|
          DIAG3 %in% adICDs|
          DIAG4 %in% adICDs|
          DIAG5 %in% adICDs|
          DIAG6 %in% adICDs|
          DIAG7 %in% adICDs|
          DIAG8 %in% adICDs|
          DIAG9 %in% adICDs|
          DIAG10 %in% adICDs]
  adm_y[, ADRD_primary := DIAG1 %in% adrdICDs]
  adm_y[, ADRD_any :=
          DIAG1 %in% adrdICDs|
          DIAG2 %in% adrdICDs|
          DIAG3 %in% adrdICDs|
          DIAG4 %in% adrdICDs|
          DIAG5 %in% adrdICDs|
          DIAG6 %in% adrdICDs|
          DIAG7 %in% adrdICDs|
          DIAG8 %in% adrdICDs|
          DIAG9 %in% adrdICDs|
          DIAG10 %in% adrdICDs]
  print(dim(adm_y[(ADRD_any),])[1])
  
  write_fst(adm_y[(ADRD_any),], paste0(dir_output, "ADRD_", year_, ".fst"))
  gc()
}
gc()
