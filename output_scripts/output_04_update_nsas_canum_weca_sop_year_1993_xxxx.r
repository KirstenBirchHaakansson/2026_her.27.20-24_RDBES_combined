
library(dplyr)
library(knitr)
library(readxl)

year_to_update <- c(2000:2025)
year_last <- 2024 #The end year of the time series to update
year_new_last <- 2025

dat_old <- read.csv(paste0("boot/data/data_from_last_year/", "nsas_canum_weca_sop_year_1993_", year_last, ".csv"))

names(dat_old)

# dat_old <- select(dat_old, -nsas_canum_mill)

dat_old_1 <- subset(dat_old, !(year %in% year_to_update))

dat_old_remove <- subset(dat_old, (year %in% year_to_update))


kable(summarise(group_by(dat_old, year), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T)),
      caption = "Old time series. CANUM per year in input file")

kable(summarise(group_by(dat_old_remove, year), nsas_canum_1000= sum(nsas_canum_1000, na.rm = T)),
      caption = "Old time series. Sum of CANUM to be updated")


# BM
dat_bm <-
  read.csv(paste0(
    "boot/data/data_from_bm/",
    "30_updated_nsas_input_fleet_area_2000-2024.csv"
  ))
names(dat_bm)

dat_bm_1 <- subset(dat_bm, (year %in% year_to_update) & area %in% c("27.3.a.20", "27.3.a.21"))

unique(dat_bm_1$year)

dat_bm_remove <- subset(dat_bm,!(year %in% year_to_update))

unique(dat_bm_remove$year)

# New data

dat_new <- read.csv(paste0("data/", "21_C4_her2024_canum_wbss_nsas_", year_new_last, ".csv"), sep = ";")
names(dat_new)

dat_new <- subset(dat_new, area %in% c("27.3.a.20", "27.3.a.21"))


dat_new$sop_v2 <- dat_new$nsas_canum_1000*dat_new$weca_g

sum(dat_new$sop_v2, na.rm = T)

dat_new_1 <- subset(dat_new, (year %in% year_to_update))

dat_new_remove <- subset(dat_new, !(year %in% year_to_update))


kable(summarise(group_by(dat_new, year), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T)),
      caption = "New data. Sum of data in input file")

kable(summarise(group_by(dat_new_1, year), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T)),
      caption = "New data. Sum of CANUM to be updated")


# Areas are joined in the Old time series

unique(dat_old_1$area)
unique(dat_bm_1$area)
unique(dat_new_1$area)

dat_new_1$area[dat_new_1$area %in% c("27.3.a.20", "27.3.a.21")] <- "27.3.a"
dat_bm_1$area[dat_bm_1$area %in% c("27.3.a.20", "27.3.a.21")] <- "27.3.a"

unique(dat_new_1$area)
unique(dat_bm_1$area)

hist(dat_new_1$weca_g)

dat_new_1$sop <- dat_new_1$nsas_canum_1000*dat_new_1$weca_g

dat_new_sum <- summarise(group_by(dat_new_1, year, area, wr), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T),
                         catch_t = sum(sop, na.rm = T))

dat_new_sum$weca_g <- dat_new_sum$catch_t/dat_new_sum$nsas_canum_1000

dat_bm_1$sop <- dat_bm_1$nsas_canum_1000 * (dat_bm_1$weca_kg * 1000)

dat_bm_sum <- summarise(group_by(dat_bm_1, year, area, wr), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T),
                         catch_t = sum(sop, na.rm = T))

dat_bm_sum$weca_g <- dat_bm_sum$catch_t/dat_bm_sum$nsas_canum_1000

names(dat_old_1)
names(dat_new_sum)
names(dat_bm_sum)

done <- rbind(ungroup(dat_old_1), ungroup(dat_new_sum), ungroup(dat_bm_sum))


kable(summarise(group_by(done, year), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T)),
                caption = "New time series")

kable(summarise(group_by(done, year), nsas_canum_1000 = sum(nsas_canum_1000 * weca_g, na.rm = T)),
      caption = "New time series")


write.csv(done, paste0("output/", "nsas_canum_weca_sop_year_1993_", year_new_last, ".csv"), row.names = F)


