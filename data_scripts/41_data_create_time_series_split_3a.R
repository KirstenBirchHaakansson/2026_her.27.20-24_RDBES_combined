
library(dplyr)

options(scipen = 999)

year_start <- 2000
year_end <- 2025


# Read in data ----

old <- read.csv(paste(
  "./boot/data/data_from_bm/",
  "11_updated_split_2000_", year_end - 1, "_SD20SD21.csv",
  sep = ""
), sep = ";")
  
new <- read.csv(paste(
  "./boot/data/split_data/",
  "cmoe_split_", year_end, "_SD20SD21_v2.csv",
  sep = ""
), sep = ",")

names(old)
names(new)  

unique(old$area)
unique(new$area)

unique(old$wr)
unique(new$wr)

new$area[new$area == "20"] <- "27.3.a.20"
new$area[new$area == "21"] <- "27.3.a.21"
new$wr[new$wr == 8] <- "8+"

old$type <- "Updated split. Benchmark 2025"
new$type <- "Created Marts 2026"

split <- bind_rows(old, new)

# Output ----
saveRDS(split,
        paste(
          "data/",
          "C41_her2024_split_3a_", year_start, "_", year_end, ".rds",
          sep = ""
        ))

write.table(
  split,
  paste(
    "data/",
    "C41_her2024_split_3a_", year_start, "_", year_end, ".csv",
    sep = ""
  ),
  sep = ";",
  row.names = F,
  na = ""
)