
library(dplyr)

year_start <- 2000
year_end <- 2025


# Read in data ----

old <- read.csv(paste(
  "../boot/data/data_from_bm/",
  "10_updated_canum_without_imputations_2000_2024.csv",
  sep = ""
), sep = ";")
  
new <- readRDS(paste(
  "./data/",
  "C1_her2024_canum_without_imputations_", year_0, ".rds",
  sep = ""
))
  
# Fix fleet and subFleet in old time series
# Code from BM - 

# dat$subFleet[is.na(dat$subFleet)] <- dat$fleet[is.na(dat$subFleet)]
dat$subFleet[dat$ctry == "Denmark" &
               dat$fleet == "C"] <- "trawl >= 32mm"
#VB: to my knowledge none of these countries has PS or GILL in the area so subFleet could be assigned as for DNK
# Kibi: good point. I will check were samples are coming from in these cases, since they normally don't have any samples
dat$subFleet[dat$ctry %in% c("Germany",
                             "Lithuania",
                             "Nedtherlands",
                             "Faroe Islands",
                             "Faroe Islands ",
                             "Faroese") &
               dat$fleet == "C"] <- NA
dat$subFleet[dat$ctry %in% c("Germany",
                             "Lithuania",
                             "Nedtherlands",
                             "Faroe Islands",
                             "Faroe Islands ",
                             "Faroese") &
               dat$fleet == "D"] <- NA
dat$subFleet[dat$ctry == "Denmark" &
               dat$fleet == "D"] <- "trawl < 32mm"
dat$subFleet[dat$ctry == "Norway" &
               dat$fleet == "C"] <- "purse seine"

dat$subFleet[dat$subFleet == "Trawl_>=32mm"] <- "trawl >= 32mm"
dat$subFleet[dat$subFleet == "active >= 32mm"] <- "trawl >= 32mm"
dat$subFleet[dat$subFleet == "Trawl_<32mm"] <- "trawl < 32mm"
dat$subFleet[dat$subFleet == "active < 32mm"] <- "trawl < 32mm"
dat$subFleet[dat$subFleet == "PS"] <- "purse seine"
dat$subFleet[dat$subFleet == "Passive"] <- "passive"
dat$subFleet[dat$subFleet == "F - passive"] <- "passive"
dat$subFleet[dat$subFleet == "F - passive"] <- "passive"
dat$subFleet[dat$subFleet == "F - active"] <- "trawl >= 32mm" # This may not be correct


dat$fleet[dat$subFleet == "passive" &
            dat$area %in% c("27.3.a.20", "27.3.a.21")] <- "C"
dat$fleet[dat$subFleet == "purse seine" &
            dat$area %in% c("27.3.a.20", "27.3.a.21")] <- "C"
dat$fleet[dat$subFleet == "trawl >= 32mm" &
            dat$area %in% c("27.3.a.20", "27.3.a.21")] <- "C"
dat$fleet[dat$subFleet == "trawl < 32mm" &
            dat$area %in% c("27.3.a.20", "27.3.a.21")] <- "D"
#VB: just for clarity and generality (in case other areas are included)
# Kibi: I agree this should not be needed
## dat$fleet[!(dat$area %in% c("27.3.a.20", "27.3.a.21"))] <- "F"
dat$fleet[dat$area %in% c("27.3.b.23","27.3.c.22","27.3.d.24")] <- "F"

unique(dat$subFleet)

check_fleets <- arrange(distinct(dat, ctry, area, fleet, subFleet), area, fleet, subFleet)