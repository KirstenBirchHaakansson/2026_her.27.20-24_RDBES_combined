

library(dplyr)
library(knitr)
library(readxl)

year_to_update <- c(2000:2025)
year_last <- 2024 #The end year of the time series to update
year_new_last <- 2025

# Old data

dat_old <-
  read.csv(paste0(
    "boot/data/data_from_last_year/",
    "wbss_canum_weca_year_1993_",
    year_last,
    ".csv"
  ))

names(dat_old)

# dat_old$wbss_canum_1000 <- dat_old$canum_mill*1000

dat_old_1 <- subset(dat_old,!(year %in% year_to_update))

dat_old_remove <- subset(dat_old, (year %in% year_to_update))



kable(summarise(
  group_by(dat_old, year),
  wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T)
),
caption = "Old time series. CANUM per year in input file")

kable(summarise(
  group_by(dat_old_remove, year),
  wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T)
),
caption = "Old time series. Sum of CANUM to be updated")

# BM
dat_bm <-
  read.csv(paste0(
    "boot/data/data_from_bm/",
    "30_updated_wbss_multi_fleet_area_2000-2024.csv"
  ))
names(dat_bm)

dat_bm_1 <- subset(dat_bm, (year %in% year_to_update))

unique(dat_bm_1$year)

dat_bm_remove <- subset(dat_bm,!(year %in% year_to_update))

unique(dat_bm_remove$year)

# New data

dat_new <-
  read.csv(paste0(
    "data/",
    "31_wbss_multi_fleet_area_",
    year_new_last,
    ".csv"
  ), sep = ",")
names(dat_new)

dat_new_1 <- subset(dat_new, (year %in% year_new_last))

dat_new_remove <- subset(dat_new,!(year %in% year_new_last))


kable(summarise(
  group_by(dat_new, year),
  wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T)
),
caption = "New data. Sum of data in input file")

kable(summarise(
  group_by(dat_new_1, year),
  wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T)
),
caption = "New data. Sum of CANUM to be updated")

# Areas are joined in the Old time series

unique(dat_old_1$area)
unique(dat_bm_1$area)
unique(dat_new_1$area)

dat_new_1$area[dat_new_1$area %in% c("27.3.b.23", "27.3.c.22", "27.3.d.24")] <-
  "27.3.b & 27.3.c & 27.3.d.24"
dat_new_1$area[dat_new_1$area %in% c("27.3.a.20", "27.3.a.21", "27.4.a.e")] <-
  "27.3.a & 27.4.a.e"
dat_bm_1$area[dat_bm_1$area %in% c("27.3.b.23", "27.3.c.22", "27.3.d.24")] <-
  "27.3.b & 27.3.c & 27.3.d.24"
dat_bm_1$area[dat_bm_1$area %in% c("27.3.a.20", "27.3.a.21", "27.4.a.e")] <-
  "27.3.a & 27.4.a.e"


unique(dat_new_1$area)
unique(dat_bm_1$area)

dat_new_1$sop <- dat_new_1$wbss_canum_1000 * (dat_new_1$weca_kg * 1000)
dat_bm_1$sop <- dat_bm_1$wbss_canum_1000 * (dat_bm_1$weca_kg * 1000)

dat_new_sum <-
  summarise(
    group_by(dat_new_1, year, area, wr),
    wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T),
    caton_t = sum(sop, na.rm = T)
  )

dat_new_sum$weca_g <-
  dat_new_sum$caton_t / dat_new_sum$wbss_canum_1000

dat_bm_sum <-
  summarise(
    group_by(dat_bm_1, year, area, wr),
    wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T),
    caton_t = sum(sop, na.rm = T)
  )

dat_bm_sum$weca_g <-
  dat_bm_sum$caton_t / dat_bm_sum$wbss_canum_1000

names(dat_old_1)
names(dat_new_sum)
names(dat_bm_sum)

done <- rbind(dat_old_1, select(dat_new_sum,-caton_t), select(dat_bm_sum,-caton_t))


done$area[done$area %in% c("27.3.b & 27.3.c & 27.3.d.24")] <-
  "27.3.b, 27.3.c, 27.3.d.24"
done$area[done$area %in% c("27.3.a & 27.4.a.e")] <-
  "27.3.a, 27.4.a.e"


kable(summarise(
  group_by(done, year),
  wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T)
),
caption = "New time series")


write.csv(
  done,
  paste0(
    "output/",
    "wbss_canum_weca_year_1993_",
    year_new_last,
    ".csv"
  ),
  row.names = F
)



