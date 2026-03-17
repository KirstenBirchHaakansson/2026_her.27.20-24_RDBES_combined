
library(dplyr)
library(knitr)

year_last <- 2023
year_to_update <- c(2024) # only works with a single year

# Old data

dat_old <- read.csv(paste0("boot/data/time_series/", "catch_sop_year_fleet_quarter_2004_", year_last, ".csv"))

names(dat_old)

dat_old_1 <- subset(dat_old, !(year %in% year_to_update))

dat_old_remove <- subset(dat_old, (year %in% year_to_update))


kable(summarise(group_by(dat_old, year), catch_1000t = sum(catch_1000t, na.rm = T)),
      caption = "Old time series. Catch per year in input file")

kable(summarise(group_by(dat_old_remove, year), catch_1000t = sum(catch_1000t, na.rm = T)),
      caption = "Old time series. Sum of catch to be updated")

# New data

dat_new <- read.csv(paste0("data/", "C5_her2024_canum_with_imputations_", year_to_update, ".csv"))
names(dat_new)
unique(dat_new$wr)

# catch_t is repeated per wr, so only select a single age

dat_new_1 <- subset(dat_new, (year %in% year_to_update))

dat_new_remove <- subset(dat_new, !(year %in% year_to_update))


kable(summarise(group_by(dat_new, year), catch_1000t = sum((canum_1000*weca_g)/1000000, na.rm = T)),
      caption = "New data. Sum of data in input file")

kable(summarise(group_by(dat_new_1, year), catch_1000t = sum((canum_1000*weca_g)/1000000, na.rm = T)),
      caption = "New data. Sum of catch to be updated")

# Areas are joined in the Old time series

unique(dat_old_1$area)
unique(dat_new_1$area)

dat_new_1$area[dat_new_1$area %in% c("27.3.b.23", "27.3.c.22", "27.3.d.24")] <- "27.3.b & 27.3.c & 27.3.d.24"
dat_new_1$area[dat_new_1$area %in% c("27.3.a.20", "27.3.a.21")] <- "27.3.a"


unique(dat_new_1$area)

dat_new_sum <- summarise(group_by(dat_new_1, year, area, fleet, quarter), catch_1000t = sum((canum_1000*weca_g)/1000000, na.rm = T))


done <- rbind(dat_old_1, dat_new_sum)

done$area[done$area %in% c("27.3.b & 27.3.c & 27.3.d.24")] <- "27.3.b, 27.3.c, 27.3.d.24"

kable(summarise(group_by(done, year), catch_1000t = sum(catch_1000t, na.rm = T)),
                caption = "New time series")


write.csv(done, paste0("output/", "catch_sop_year_fleet_quarter_2004_", year_to_update, ".csv"), row.names = F)


