#' Project: airpollution_ADRD
#' Code: extract ADRD hopspitalization info from hospitalization files
#' Input: hospitalization files
#' Output: "ADRD`type`_`year`.fst"
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
setwd("/nfs/home/S/shd968/shared_space/ci3_analysis/ADRDdata/")
dir_hospital <- "/nfs/home/S/shd968/shared_space/ci3_health_data/medicare/gen_admission/1999_2016/targeted_conditions/cache_data/admissions_by_year/"
dir_output <- "/nfs/home/S/shd968/shared_space/ci3_analysis/ADRDdata/data/ADRDhospitalization/"
# dir_output <- "/nfs/home/S/shd968/shared_space/ci3_shd968/dementia/data/ADRDhospitalization_DanList/"

## ICD code info ----
outcomes <- list()
outcomes[["ADRD"]] <- list()
outcomes[["ADRD"]][["icd9"]] <- c("290", # dementia group
                                  children("2900"), # senile dementia, uncomplicatied
                                  children("2901"), # Presenile dementia (brain syndrome w/ presenile dementia)
                                  children("2902"), # Senile dementia with delusional or depressive features
                                  children("2903"), # Senile dementia, w/ delirium
                                  children("2904"), # Vascular dementia
                                  children("2940"), # Amnestic syndrome (Korsakoff’s psychosis or syndrome, nonalcoholic)
                                  children("2941"), # Dementia in conditions classified elsewhere
                                  children("2948"), # Other persistent mental disorders due to conditions classified elsewhere
                                  children("3310"), # Alzheimer’s disease
                                  children("3311"), # Frontotemporal dementia
                                  children("3312"), # Senile degeneration of the brain
                                  children("3317"), # Cerebral degeneration in diseases classified elsewhere
                                  children("797")) # Senility without mention of psychosis)
outcomes[["ADRD"]][["icd10"]] <- c(children("F01"),
                                   children("F02"),
                                   "F0390",
                                   children("G30"),
                                   children("G310"), "G311", "G312",
                                   "R4181")
# outcomes[["ADRD"]][["icd9"]] <- c(children("290"), # Dementias
#                                   children("2941"), # Dementia, classified elsewhere
#                                   children("2942"), # Dementia, unspecified
#                                   children("2948"), # Other persistent mental disorder
#                                   children("2949"), # Unspecified persistent mental disorder
#                                   children("331")) # Alzheimer's disease
# outcomes[["ADRD"]][["icd10"]] <- c(children("F01"), # Vascular dementia
#                                    children("F02"), # Dementia in other diseases
#                                    children("F03"), # Unspecified dementia 
#                                    children("F09"), # MCI
#                                    children("G30"), # Alzheimer's disease
#                                    children("G310"), # Frontotemoral dementia
#                                    children("G311"), # Senile dementia
#                                    "G3183", # Dementia with Lewy bodies
#                                    "G3184") # MCI, so stated

## extract hospitalization info ----
#' clear out old data in case of re-run
file.remove(list.files(dir_output, 
                       pattern = ".fst",
                       full.names = T))
#' sample 
# temp <- read_fst(paste0(dir_hospital, "admissions_2012.fst"))
# head(temp,2)
# QID AGE SEX RACE SSA_STATE_CD SSA_CNTY_CD PROV_NUM ADM_SOURCE ADM_TYPE     ADATE
# 1 A00270022  89   2    1           30          10   300006          1        3 06SEP1996
# 2 A03003851  92   1    1           33          30   330394          7        1 29MAR1998
# DDATE  BENE_DOD DODFLAG ICU_DAY CCI_DAY ICU CCI DIAG1 DIAG2 DIAG3 DIAG4 DIAG5 DIAG6
# 1 19JUN2000 19JUN2000       V       0       0  NA  NA 82120  4928  4280 73301  2859  E888
# 2 10JAN2000 07FEB2001       V       2       0   0  NA 41401  4111  5990 03849   486   496
# DIAG7 DIAG8 DIAG9 DIAG10 diag11 diag12 diag13 diag14 diag15 diag16 diag17 diag18 diag19
# 1                       NA     NA     NA     NA     NA     NA     NA     NA     NA     NA
# 2  2765  5272 29633     NA     NA     NA     NA     NA     NA     NA     NA     NA     NA
# diag20 diag21 diag22 diag23 diag24 diag25 YEAR  LOS Parkinson_pdx Parkinson_pdx2dx_10
# 1     NA     NA     NA     NA     NA     NA 2000 1382             0                   0
# 2     NA     NA     NA     NA     NA     NA 2000  652             0                   0
# Parkinson_pdx2dx_25 Alzheimer_pdx Alzheimer_pdx2dx_10 Alzheimer_pdx2dx_25 Dementia_pdx
# 1                   0             0                   0                   0            0
# 2                   0             0                   0                   0            0
# Dementia_pdx2dx_10 Dementia_pdx2dx_25 CHF_pdx CHF_pdx2dx_10 CHF_pdx2dx_25 AMI_pdx
# 1                  0                  0       0             1             1       0
# 2                  0                  0       0             0             0       0
# AMI_pdx2dx_10 AMI_pdx2dx_25 COPD_pdx COPD_pdx2dx_10 COPD_pdx2dx_25 DM_pdx DM_pdx2dx_10
# 1             0             0        0              1              1      0            0
# 2             0             0        0              1              1      0            0
# DM_pdx2dx_25 Stroke_pdx Stroke_pdx2dx_10 Stroke_pdx2dx_25 CVD_pdx CVD_pdx2dx_10
# 1            0          0                0                0       0             1
# 2            0          0                0                0       1             1
# CVD_pdx2dx_25 CSD_pdx CSD_pdx2dx_10 CSD_pdx2dx_25 Ischemic_stroke_pdx
# 1             1       0             1             1                   0
# 2             1       1             1             1                   0
# Ischemic_stroke_pdx2dx_10 Ischemic_stroke_pdx2dx_25 Hemo_Stroke_pdx Hemo_Stroke_pdx2dx_10
# 1                         0                         0               0                     0
# 2                         0                         0               0                     0
# Hemo_Stroke_pdx2dx_25 zipcode_R Race_gp Sex_gp age_gp Dual
# 1                     0     27830   White Female Age>84    0
# 2                     0     20931   White   Male Age>84    0
# rm(temp)
# gc()

for (year_ in 2000:2016) {
  cat("Loading", year_, "hospitalization file... \n")
  admissions <- read_data(dir_hospital, years = year_,
                          columns = c("QID", "ADATE", "DDATE", "zipcode_R", paste0("DIAG", 1:10)))
  change_columns <- c(paste0("DIAG", 1:10))
  admissions[ ,(change_columns) := lapply(.SD, as.character),# Change class of certain columns
              .SDcols = change_columns]
  admissions[, ADATE := dmy(ADATE)][, DDATE := dmy(DDATE)]
  admissions[, year := year(ADATE)]
  admissions <- admissions[year %in% 2000:2016,]
  
  admissions[, ADRD_primary := 
               DIAG1 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG1 %in% outcomes[["ADRD"]][["icd10"]]]
  admissions[, ADRD_any := 
               DIAG1 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG2 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG3 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG4 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG5 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG6 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG7 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG8 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG9 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG10 %in% outcomes[["ADRD"]][["icd9"]]|
               diag11 %in% outcomes[["ADRD"]][["icd9"]]|
               diag12 %in% outcomes[["ADRD"]][["icd9"]]|
               diag13 %in% outcomes[["ADRD"]][["icd9"]]|
               diag14 %in% outcomes[["ADRD"]][["icd9"]]|
               diag15 %in% outcomes[["ADRD"]][["icd9"]]|
               diag16 %in% outcomes[["ADRD"]][["icd9"]]|
               diag17 %in% outcomes[["ADRD"]][["icd9"]]|
               diag18 %in% outcomes[["ADRD"]][["icd9"]]|
               diag19 %in% outcomes[["ADRD"]][["icd9"]]|
               diag20 %in% outcomes[["ADRD"]][["icd9"]]|
               diag21 %in% outcomes[["ADRD"]][["icd9"]]|
               diag22 %in% outcomes[["ADRD"]][["icd9"]]|
               diag23 %in% outcomes[["ADRD"]][["icd9"]]|
               diag24 %in% outcomes[["ADRD"]][["icd9"]]|
               diag25 %in% outcomes[["ADRD"]][["icd9"]]|
               DIAG1 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG2 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG3 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG4 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG5 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG6 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG7 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG8 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG9 %in% outcomes[["ADRD"]][["icd10"]]|
               DIAG10 %in% outcomes[["ADRD"]][["icd10"]]|
               diag11 %in% outcomes[["ADRD"]][["icd10"]]|
               diag12 %in% outcomes[["ADRD"]][["icd10"]]|
               diag13 %in% outcomes[["ADRD"]][["icd10"]]|
               diag14 %in% outcomes[["ADRD"]][["icd10"]]|
               diag15 %in% outcomes[["ADRD"]][["icd10"]]|
               diag16 %in% outcomes[["ADRD"]][["icd10"]]|
               diag17 %in% outcomes[["ADRD"]][["icd10"]]|
               diag18 %in% outcomes[["ADRD"]][["icd10"]]|
               diag19 %in% outcomes[["ADRD"]][["icd10"]]|
               diag20 %in% outcomes[["ADRD"]][["icd10"]]|
               diag21 %in% outcomes[["ADRD"]][["icd10"]]|
               diag22 %in% outcomes[["ADRD"]][["icd10"]]|
               diag23 %in% outcomes[["ADRD"]][["icd10"]]|
               diag24 %in% outcomes[["ADRD"]][["icd10"]]|
               diag25 %in% outcomes[["ADRD"]][["icd10"]]]
  print(dim(admissions[(ADRD_any),])[1])
  for (type in c("primary", "any")) {
    varname <- paste0("ADRD_", type)
    write_fst(admissions[(get(varname)),], paste0(dir_output, "ADRD", type, "_", year_, ".fst"))
    gc()
  }
}
gc()

##
# outcomeDT <- rbindlist(list(
#   data.table(icd = as.character(outcomes[["ADRD"]][["icd9"]]), ADRD = T),
#   data.table(icd = as.character(outcomes[["ADRD"]][["icd10"]]), ADRD = T)))
# ADRDhosp <- data.table()
# for (year_ in 2000:2016){
#   cat("Loading", year_, "hospitalization file... \n")
#   admissions <- read_fst(paste0(dir_hospital, "admissions_", year_, ".fst"),
#                          c("QID", "ADATE", "DDATE", paste0("DIAG", 1:10), paste0("diag",11:25)),
#                          as.data.table = TRUE)
#   admissions[, ADATE := dmy(ADATE)][, DDATE := dmy(DDATE)]
#   admissions[, year := year(ADATE)]
#   # admissions <- admissions[year == year_]
#   admissions <- melt(admissions, measure.vars = c(paste0("DIAG", 1:10),paste0("diag",11:25)),
#                      variable.name = "DIAG", value.name = "ICD")
#   admissions[, primary := (DIAG == "DIAG1")]
#   admissions <- merge(admissions, outcomeDT,
#                       by.x = "ICD", by.y = "icd", all.x = TRUE)
#   print(admissions[, .N, by = c("primary", "ADRD")])
#   ADRDhosp <- rbindlist(list(ADRDhosp, admissions[(ADRD),]))
#   rm(admissions); gc()
# }