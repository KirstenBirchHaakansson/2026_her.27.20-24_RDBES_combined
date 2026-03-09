
library(dplyr)

year_start <- 2000
year_end <- 2025


# Read in data ----

old <- read.csv(paste(
  "./boot/data/data_from_bm/",
  "10_updated_canum_without_imputations_2000_", year_end - 1, ".csv",
  sep = ""
), sep = ";")
  
new <- readRDS(paste(
  "./data/",
  "C1_her2024_canum_without_imputations_", year_end, ".rds",
  sep = ""
))
  
# Fix fleet and subFleet in old time series ----
# Code from BM - 

# old$subFleet[is.na(old$subFleet)] <- old$fleet[is.na(old$subFleet)]
old$subFleet[old$ctry == "Denmark" &
               old$fleet == "C"] <- "trawl >= 32mm"
#VB: to my knowledge none of these countries has PS or GILL in the area so subFleet could be assigned as for DNK
# Kibi: good point. I will check were samples are coming from in these cases, since they normally don't have any samples
old$subFleet[old$ctry %in% c("Germany",
                             "Lithuania",
                             "Nedtherlands",
                             "Faroe Islands",
                             "Faroe Islands ",
                             "Faroese") &
               old$fleet == "C"] <- NA
old$subFleet[old$ctry %in% c("Germany",
                             "Lithuania",
                             "Nedtherlands",
                             "Faroe Islands",
                             "Faroe Islands ",
                             "Faroese") &
               old$fleet == "D"] <- NA
old$subFleet[old$ctry == "Denmark" &
               old$fleet == "D"] <- "trawl < 32mm"
old$subFleet[old$ctry == "Norway" &
               old$fleet == "C"] <- "purse seine"

old$subFleet[old$subFleet == "Trawl_>=32mm"] <- "trawl >= 32mm"
old$subFleet[old$subFleet == "active >= 32mm"] <- "trawl >= 32mm"
old$subFleet[old$subFleet == "Trawl_<32mm"] <- "trawl < 32mm"
old$subFleet[old$subFleet == "active < 32mm"] <- "trawl < 32mm"
old$subFleet[old$subFleet == "PS"] <- "purse seine"
old$subFleet[old$subFleet == "Passive"] <- "passive"
old$subFleet[old$subFleet == "F - passive"] <- "passive"
old$subFleet[old$subFleet == "F - passive"] <- "passive"
old$subFleet[old$subFleet == "F - active"] <- "trawl >= 32mm" # This may not be correct


old$fleet[old$subFleet == "passive" &
            old$area %in% c("27.3.a.20", "27.3.a.21")] <- "C"
old$fleet[old$subFleet == "purse seine" &
            old$area %in% c("27.3.a.20", "27.3.a.21")] <- "C"
old$fleet[old$subFleet == "trawl >= 32mm" &
            old$area %in% c("27.3.a.20", "27.3.a.21")] <- "C"
old$fleet[old$subFleet == "trawl < 32mm" &
            old$area %in% c("27.3.a.20", "27.3.a.21")] <- "D"
#VB: just for clarity and generality (in case other areas are included)
# Kibi: I agree this should not be needed
## old$fleet[!(old$area %in% c("27.3.a.20", "27.3.a.21"))] <- "F"
old$fleet[old$area %in% c("27.3.b.23","27.3.c.22","27.3.d.24")] <- "F"

unique(old$subFleet)

check_fleets <- arrange(distinct(subset(old, year >= 2021 & catch_t != 0), year, ctry, area, fleet, subFleet), area, fleet, subFleet)

is_na_subFleet <- subset(old, catch_t != 0 & year >= 2021 & is.na(subFleet))

# Combine new and old ----

years_new <- unique(new$year)

old_sub <- subset(old, !(year %in% years_new))

new$year <- as.integer(new$year)

canum <- bind_rows(old, new)

# Output ----
saveRDS(canum,
        paste(
          "data/",
          "C2_her2024_canum_without_imputations_", year_start, "_", year_end, ".rds",
          sep = ""
        ))

write.table(
  canum,
  paste(
    "data/",
    "C2_her2024_canum_without_imputations_", year_start, "_", year_end, ".csv",
    sep = ""
  ),
  sep = ";",
  row.names = F,
  na = ""
)