
library(dplyr)
library(knitr)
library(readxl)

year_last <- 2023
year_to_update <- c(2024)

dat_old <- read.csv(paste0("boot/data/time_series/", "nsas_canum_weca_sop_year_1993_", year_last, ".csv"))

names(dat_old)

# dat_old <- select(dat_old, -nsas_canum_mill)

dat_old_1 <- subset(dat_old, !(year %in% year_to_update))

dat_old_remove <- subset(dat_old, (year %in% year_to_update))


kable(summarise(group_by(dat_old, year), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T)),
      caption = "Old time series. CANUM per year in input file")

kable(summarise(group_by(dat_old_remove, year), nsas_canum_1000= sum(nsas_canum_1000, na.rm = T)),
      caption = "Old time series. Sum of CANUM to be updated")

# New data

dat_new <- read.csv(paste0("data/", "C6_her2024_canum_wbss_nsas_", year_to_update, ".csv"))
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
unique(dat_new_1$area)

dat_new_1$area[dat_new_1$area %in% c("27.3.a.20", "27.3.a.21")] <- "27.3.a"

unique(dat_new_1$area)

hist(dat_new_1$weca_g)

dat_new_1$sop <- dat_new_1$nsas_canum_1000*dat_new_1$weca_g

dat_new_sum <- summarise(group_by(dat_new_1, year, area, wr), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T),
                         catch_t = sum(sop, na.rm = T))

dat_new_sum$weca_g <- dat_new_sum$catch_t/dat_new_sum$nsas_canum_1000

names(dat_old_1)
names(dat_new_sum)

done <- rbind(ungroup(dat_old_1), ungroup(dat_new_sum))


kable(summarise(group_by(done, year), nsas_canum_1000 = sum(nsas_canum_1000, na.rm = T)),
                caption = "New time series")


write.csv(done, paste0("output/", "nsas_canum_weca_sop_year_1993_", year_to_update, ".csv"), row.names = F)


