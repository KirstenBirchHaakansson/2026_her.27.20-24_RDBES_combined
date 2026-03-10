

library(dplyr)
library(sqldf)

options("scipen" = 1000)

year_0 <- 2024


#Read in and recode split proportions from Henrik
#Read-in

split <-
  read.table(
    paste(
      "boot/data/split_data/",
      "cmoe_split_",
      year_0,
      "_SD20SD21_v2.csv",
      sep = ""
    ),
    sep = ",",
    header = T
  )
str(split)

split <- select(split, year, area, quarter, wr, nsas, wbss, n)

unique(split$area)

split$area <- ifelse(split$area == "20", "27.3.a.20", "27.3.a.21")

unique(split$area)

unique(split$wr)

split$wr <- ifelse(split$wr == "8", "8+", split$wr)

#Read in CANUM

canum <-
  readRDS(paste(
    "data/",
    "C5_her2024_canum_with_imputations_",
    year_0,
    ".rds",
    sep = ""
  ))


#Apply split proportions

splitted <- merge(canum, split, all.x = T)

splitted$wbss <-
  ifelse(splitted$area %in% c("27.3.b.23", "27.3.c.22", "27.3.d.24"),
         1,
         splitted$wbss)
splitted$nsas <-
  ifelse(splitted$area %in% c("27.3.b.23", "27.3.c.22", "27.3.d.24"),
         0,
         splitted$nsas)

splitted$nsas_canum_1000 <- splitted$canum_1000 * splitted$nsas

splitted$wbss_canum_1000 <- splitted$canum_1000 * splitted$wbss

splitted <- arrange(splitted, year, quarter, area, ctry, fleet, wr)

splitted$nsas_canum_1000[is.na(splitted$nsas_canum_1000)] <- 0

splitted$wbss_canum_1000[is.na(splitted$wbss_canum_1000)] <- 0


#Output

#WBSS and NSAS
write.table(
  splitted,
  paste("data/", "C6_her2024_canum_wbss_nsas_", year_0, ".csv", sep = ""),
  sep = ",",
  row.names = F
)
saveRDS(splitted,
        paste("data/", "C6_her2024_canum_wbss_nsas_", year_0, ".rds", sep = ""))



