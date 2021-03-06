rm (list = ls())
# Load packages
library(tidyverse)
library(haven)
library(plotly)
library(ReIns)

bs <- list()

dist <- list()

dur <- list()

mmets <- list()

pm_conc <- list()

RR_AP_calculations <- list()

RR_PA_calculations <- list()

RR_PA_AP_calculations <- list()

deaths_yll_injuries <- list()

deaths_by_mode <- list()

deaths <- list()

deaths_red <- list()

ylls <- list()

ylls_red <- list()

MEAN_BUS_WALK_TIME <- 5

for (INDEX in 1:5){
  
  # INDEX <- 1
  
  # Generate all scenarios
  source("R/scenarios/accra/scenarios.R")
  
  # rm(list = setdiff(ls(), c("INDEX", "bs", "dist", "dur", "mmets", "MEAN_BUS_WALK_TIME")))
  
  MEAN_BUS_WALK_TIME <- MEAN_BUS_WALK_TIME + 2
  
  # Generate distance and duration matrices
  source("R/scenarios/accra/dist_dur_tbls.R")
  
  # rm(list = setdiff(ls(), c("INDEX", "bs", "dist", "dur", "mmets", "MEAN_BUS_WALK_TIME")))
  
  # Calculate total PA MMET
  source("R/PA/accra/total_mmet.R")
  
  # rm(list = setdiff(ls(), c("INDEX", "bs", "dist", "dur", "mmets", "MEAN_BUS_WALK_TIME")))
  
  # Calculate PM calculations
  source("R/pollution/accra/scenario_pm_calculations.R")
  
  # # Calculate RR 2.5
  source("R/health/accra/gen_ap_rr.R")
  
  # Calculate RR PA
  source("R/health/accra/gen_pa_rr.R")

  # Combine RR for PA and AP for common diseases
  source("R/health/accra/combined_rr_pa_pa.R")
  
  # # Calculate disease burden for injuries
  source("R/injuries/accra/accra_injuries.R")
  # 
  # # Calculate disease burden for AP, PA and Injuries
  source("R/health/accra/health_burden.R")
  
  
}

rm(list = setdiff(ls(), c("INDEX", "bs", "dist", "dur", "mmets", "pm_conc", 
                          "RR_AP_calculations", "RR_PA_calculations",
                          "RR_PA_AP_calculations", "deaths_by_mode",
                          "deaths_yll_injuries", "MEAN_BUS_WALK_TIME"))) 

# 
# trip_distance <- list()
# 
# for (i in 1:5){
#   
#   df <- bs[[i]]
#   
#   df <- filter(df, ! trip_mode %in% c('Short Walking', "99", "Train", "Other", "Unspecified"))
# 
#   trip_distance[[i]] <- df %>% group_by(scenario, trip_mode) %>% summarise(p = sum(trip_distance))
#   
#   
# }



