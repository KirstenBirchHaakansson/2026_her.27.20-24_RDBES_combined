

library(dplyr)
library(knitr)
library(readxl)

year_last <- 2023
year_to_update <- c(2024) # only works with a single year

# Old data

dat_old <-
  read.csv(paste0(
    "boot/data/time_series/",
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

# New data


dat_new <-
  read.csv(paste0(
    "data/",
    "C6_her2024_canum_wbss_nsas_",
    year_to_update,
    ".csv"
  ))
names(dat_new)

wbss4 <- read_excel(
  paste(
    "boot/data/split_data/",
    "Her21-IVaE_transfer_only_split_",
    year_to_update,
    ".xlsx",
    sep = ""
  ),
  sheet = 3
)

wbss4$wr <- ifelse(wbss4$wr %in% c("8", "9"), "8+", wbss4$wr)
names(wbss4)
head(wbss4)

wbss4$wbss_canum_1000 <- wbss4$canum_000
wbss4$weca_g <- wbss4$weca_kg * 1000

dat_new_all <- bind_rows(dat_new, wbss4)

dat_new_all$sop_v2 <- dat_new_all$wbss_canum_1000 * dat_new_all$weca_g

sum(dat_new_all$sop_v2, na.rm = T)

dat_new_1 <- subset(dat_new_all, (year %in% year_to_update))

dat_new_remove <- subset(dat_new_all,!(year %in% year_to_update))


kable(summarise(
  group_by(dat_new_all, year),
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
unique(dat_new_1$area)

dat_new_1$area[dat_new_1$area %in% c("27.3.b.23", "27.3.c.22", "27.3.d.24")] <-
  "27.3.b & 27.3.c & 27.3.d.24"
dat_new_1$area[dat_new_1$area %in% c("27.3.a.20", "27.3.a.21", "27.4.a.e")] <-
  "27.3.a & 27.4.a.e"


unique(dat_new_1$area)

hist(dat_new_1$weca_g)

dat_new_1$sop <- dat_new_1$wbss_canum_1000 * dat_new_1$weca_g

dat_new_sum <-
  summarise(
    group_by(dat_new_1, year, area, wr),
    wbss_canum_1000 = sum(wbss_canum_1000, na.rm = T),
    caton_t = sum(sop, na.rm = T)
  )

dat_new_sum$weca_g <-
  dat_new_sum$caton_t / dat_new_sum$wbss_canum_1000

names(dat_old_1)
names(dat_new_sum)

done <- rbind(dat_old_1, select(dat_new_sum,-caton_t))


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
    year_to_update,
    ".csv"
  ),
  row.names = F
)



