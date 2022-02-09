#' Code: check ADRD hospitalization count over time
#' Input: ADRD hospitalization records
#' Output: plot
#' Author: Shuxin Dong
#' First create date: 2021-02-03

## setup ----
rm(list=ls())
gc()

library(fst)
library(data.table)
library(NSAPHutils)

setwd("/nfs/nsaph_ci3/ci3_shd968/ADRDhospitalization/")

## load data----
dir_input_hospital <- "/nfs/home/S/shd968/shared_space/ci3_analysis/data_ADRDhospitalization/ADRDhospitalization_CCWlist/"
ADRDhosp <- NULL
for (i in 2000:2016) {
  adm_ <- read_fst(paste0(dir_input_hospital, "ADRD_", i,".fst"), as.data.table = T)
  ADRDhosp <- rbind(ADRDhosp, adm_)
  print(paste0("finish loading file:", "ADRD_", i,".fst"))
}
rm(adm_)
gc()
ADRDhosp <- unique(ADRDhosp)

## plot ----
par(mfrow=c(1,1))

pdf(paste0(getwd(),"/ADRDtrend.pdf"))
hist(ADRDhosp[,year], main = "ADRD hospitalization count", xlab = "calendar year")
dev.off()

pdf(paste0(getwd(),"/ADRDtrend_uniqueQIDyear.pdf"))
hist(unique(ADRDhosp[,.(QID,year)])[,year], main = "ADRD hospitalization count", xlab = "calendar year")
dev.off()

