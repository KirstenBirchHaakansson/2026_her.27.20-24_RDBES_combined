

options("scipen" = 1000, digits = 6)
library(dplyr)
library(tidyr)
library(readxl)

path_model_input <- "./boot/data/download_from_stockassessment_org_multi_fleet/"
path_trans_split <- "./boot/data/updated_split_data/"
path_data <- "./data/"

# Read in model for fleet A
# Model ----
cn <- c()

for (i in c("A", "C", "D", "F")) {
  cn_0 <- read.csv(paste0(path_model_input, "cn_", i, ".dat"),
                   sep = "",
                   header = F)
  year_min <- as.numeric(cn_0[3, 1])
  year_max <- as.numeric(cn_0[3, 2])
  cn_0_dat <- cn_0[c(6:((year_max - year_min) + 6)), c(1:9)]
  names(cn_0_dat) <- c("wr0", "wr1", "wr2", "wr3", "wr4", "wr5", "wr6", "wr7", "wr8+")
  cn_0_dat$year <- c(year_min:year_max)
  cn_0_dat$fleet <- i
  
  cn <- rbind(cn, cn_0_dat)
  
}

cn_t <- tidyr::gather(cn, key = "wr", value = "canum_1000", -year, -fleet)
cn_t$wr <- gsub("wr", "", cn_t$wr)
cn_t$canum_1000 <- as.numeric(cn_t$canum_1000)
cn_t$stock <- "wbss"

cw <- c()

for (i in c("A", "C", "D", "F")) {
  cw_0 <- read.csv(paste0(path_model_input, "cw_", i, ".dat"),
                   sep = "",
                   header = F)
  year_min <- as.numeric(cw_0[3, 1])
  year_max <- as.numeric(cw_0[3, 2])
  cw_0_dat <- cw_0[c(6:((year_max - year_min) + 6)), c(1:9)]
  names(cw_0_dat) <- c("wr0", "wr1", "wr2", "wr3", "wr4", "wr5", "wr6", "wr7", "wr8+")
  cw_0_dat$year <- c(year_min:year_max)
  cw_0_dat$fleet <- i
  
  cw <- rbind(cw, cw_0_dat)
  
}

cw_t <- tidyr::gather(cw, key = "wr", value = "weca_kg", -year, -fleet)
cw_t$wr <- gsub("wr", "", cw_t$wr)
cw_t$weca_kg <- as.numeric(cw_t$weca_kg)
cw_t$weca_g <- cw_t$weca_kg * 1000
cw_t$stock <- "wbss"

model <- full_join(cn_t, cw_t)
model_a <- subset(model, fleet == "A")

# Read-in updated ----
# fleet A -----

canum_a_updated <- c()

for (i in c(2022:2024)) {
  canum_a <-
    read_excel(
      paste(
        path_trans_split,
        "Her21-IVaE_transfer_only_split_",
        i,
        ".xlsx",
        sep = ""
      ),
      sheet = 3
    )
  canum_a_updated <- rbind(canum_a_updated, canum_a)
}


canum_a_updated <- rename(canum_a_updated, wbss_canum_1000 = canum_000)
canum_a_updated$weca_g <- canum_a_updated$weca_kg * 1000
canum_a_updated$fleet <- "A"
canum_a_updated$wr <- ifelse(canum_a_updated$wr %in% c("8", "9"), "8+", canum_a_updated$wr)

unique(canum_a_updated$year)

model_a_minus <- subset(model_a, !(year %in% canum_a_updated$year))

canum_a <- bind_rows(model_a_minus, canum_a_updated)
table(canum_a$year, canum_a$fleet)

# fleet C, D, F ----
canum <-
  read.table(paste(path_data, "updated_canum_wbss_nsas_2000-2024.csv", sep =
                  ""), sep = ",", header = T)
canum$weca_kg <- canum$weca_g / 1000

# Combine ----

canum <- bind_rows(canum, canum_a)

canum$wbss_caton <- canum$wbss_canum_1000 * canum$weca_kg
canum$nsas_caton <- canum$nsas_canum_1000 * canum$weca_kg

canum$wbss_canum_1000[is.na(canum$wbss_canum_1000)] <- 0
canum$wbss_caton[is.na(canum$wbss_caton)] <- 0
canum$nsas_canum_1000[is.na(canum$nsas_canum_1000)] <- 0
canum$nsas_caton[is.na(canum$nsas_caton)] <- 0



#Output per fleet and area
##WBSS


wbssFinal <-
  aggregate(
    cbind(wbss_canum_1000, wbss_caton) ~ year + wr + fleet + area,
    data = canum,
    FUN = sum
  )
wbssFinal$weca_kg <- (wbssFinal$wbss_caton / wbssFinal$wbss_canum_1000)

write.table(
  wbssFinal,
  paste(path_data, "updated_wbss_multi_fleet_area_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)


#Output per fleet
##WBSS

wbssFinal <-
  aggregate(cbind(wbss_canum_1000, wbss_caton) ~ year + wr + fleet,
            data = canum,
            FUN = sum)
wbssFinal$weca_kg <- (wbssFinal$wbss_caton / wbssFinal$wbss_canum_1000)

write.table(
  wbssFinal,
  paste(path_data, "updated_wbss_multi_fleet_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

wbssFinal_t_canum <-
  mutate(spread(
    select(wbssFinal, year, wr, fleet, wbss_canum_1000),
    key = wr,
    value = wbss_canum_1000
  ), value = "wbss_canum_1000")
wbssFinal_t_caton <-
  mutate(spread(
    select(wbssFinal, year, wr, fleet, wbss_caton),
    key = wr,
    value = wbss_caton
  ), value = "wbss_caton")
wbssFinal_t_weca <-
  mutate(spread(
    select(wbssFinal, year, wr, fleet, weca_kg),
    key = wr,
    value = weca_kg
  ), value = "weca_kg")

wbssFinal_t <-
  bind_rows(bind_rows(wbssFinal_t_canum, wbssFinal_t_caton),
            wbssFinal_t_weca)

write.table(
  wbssFinal_t,
  paste(path_data, "updated_wbss_multi_fleet_t_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

#Output per fleet
##WBSS

wbssFinal <-
  aggregate(cbind(wbss_canum_1000, wbss_caton) ~ year + wr,
            data = canum,
            FUN = sum)
wbssFinal$weca_kg <- (wbssFinal$wbss_caton / wbssFinal$wbss_canum_1000)

write.table(
  wbssFinal,
  paste(path_data, "updated_wbss_single_fleet_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

wbssFinal_t_canum <-
  mutate(spread(
    select(wbssFinal, year, wr, wbss_canum_1000),
    key = wr,
    value = wbss_canum_1000
  ), value = "wbss_canum_1000")
wbssFinal_t_caton <-
  mutate(spread(
    select(wbssFinal, year, wr, wbss_caton),
    key = wr,
    value = wbss_caton
  ), value = "wbss_caton")
wbssFinal_t_weca <-
  mutate(spread(
    select(wbssFinal, year, wr, weca_kg),
    key = wr,
    value = weca_kg
  ), value = "weca_kg")

wbssFinal_t <-
  bind_rows(bind_rows(wbssFinal_t_canum, wbssFinal_t_caton),
            wbssFinal_t_weca)

write.table(
  wbssFinal_t,
  paste(path_data, "updated_wbss_single_fleet_t_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

#Output per fleet
##NSAS

nsasFinal <-
  aggregate(
    cbind(nsas_canum_1000, nsas_caton) ~ year + wr + fleet + quarter,
    data = canum,
    FUN = sum
  )
nsasFinal$weca_kg <- (nsasFinal$nsas_caton / nsasFinal$nsas_canum_1000)

write.table(
  subset(nsasFinal, fleet %in% c("C", "D")),
  paste(path_data, "updated_nsas_input_fleet_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

#Output total
##NSAS

nsasFinal <-
  aggregate(cbind(nsas_canum_1000, nsas_caton) ~ year + wr,
            data = canum,
            FUN = sum)
nsasFinal$weca_kg <- (nsasFinal$nsas_caton / nsasFinal$nsas_canum_1000)

write.table(
  subset(nsasFinal),
  paste(path_data, "updated_nsas_input_total_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)


#Output quarter
##NSAS

nsasFinal <-
  aggregate(
    cbind(nsas_canum_1000, nsas_caton) ~ year + wr + quarter,
    data = canum,
    FUN = sum
  )
nsasFinal$weca_kg <- (nsasFinal$nsas_caton / nsasFinal$nsas_canum_1000)

write.table(
  subset(nsasFinal),
  paste(path_data, "updated_nsas_input_quarter_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)



#Output fleet and area
##NSAS


nsasFinal <-
  aggregate(
    cbind(nsas_canum_1000, nsas_caton) ~ year + wr + fleet + area,
    data = canum,
    FUN = sum
  )
nsasFinal$weca_kg <- (nsasFinal$nsas_caton / nsasFinal$nsas_canum_1000)

write.table(
  subset(nsasFinal),
  paste(path_data, "updated_nsas_input_fleet_area_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

#Output per quarter
##WBSS


wbssFinalq <-
  aggregate(
    cbind(wbss_canum_1000, wbss_caton) ~ year + wr + quarter,
    data = canum,
    FUN = sum
  )
wbssFinalq$weca_kg <-
  (wbssFinalq$wbss_caton / wbssFinalq$wbss_canum_1000)

write.table(
  wbssFinalq,
  paste(path_data, "updated_wbss_input_quarter_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

wbssFinalq_t_canum <-
  mutate(spread(
    select(wbssFinalq, year, quarter, wr, wbss_canum_1000),
    key = wr,
    value = wbss_canum_1000
  ), value = "wbss_canum_1000")
wbssFinalq_t_caton <-
  mutate(spread(
    select(wbssFinalq, year, quarter, wr, wbss_caton),
    key = wr,
    value = wbss_caton
  ), value = "wbss_caton")
wbssFinalq_t_weca <-
  mutate(spread(
    select(wbssFinalq, year, quarter, wr, weca_kg),
    key = wr,
    value = weca_kg
  ), value = "weca_kg")

wbssFinalq_t <-
  bind_rows(bind_rows(wbssFinalq_t_canum, wbssFinalq_t_caton),
            wbssFinalq_t_weca)

write.table(
  wbssFinalq_t,
  paste(path_data, "updated_wbss_input_quarter_t_2000-2024.csv", sep = ""),
  sep = ",",
  row.names = F
)

# ```{r, eval = F}
#
# write.table(wbssFinal, paste(path_data,"wbbs_catch_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
#
# ```
#
# #WEST
# ```{r, eval = F}
# wbssWEST<-aggregate(cbind(wbss_canum_1000,caton)~year+wr+quarter, data=wbss, FUN=sum)
# wbssWEST$weca_kg<-(wbssWEST$caton/wbssWEST$wbss_canum_1000)
#
# write.table(wbssWEST, paste(path_data,"wbbs_catch_west_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
# ```
#
# #Cacth WBSS and NSAS
# ```{r, eval = F}
# wbss3<-readRDS(paste(path_data,"3a_splitted_", year, ".rsd", sep=""))
# wbss3a<-subset(wbss3, area %in% c("27.3.a.20","27.3.a.21"))
#
# wbss3a$wbss_caton_t<-wbss3a$wbss_canum_1000*(wbss3a$weca_g/1000)
# wbss3a$nsas_caton_t<-wbss3a$nsas_canum_1000*(wbss3a$weca_g/1000)
#
# prop<-aggregate(cbind(wbss_caton_t,nsas_caton_t)~year+fleet, data=wbss3a, FUN=sum)
# write.table(prop, paste(path_data,"wbbs_nsas_prop_catch_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
# ```
#
# ```{r, eval = F}
#
# wbss3$wbss_caton_t<-wbss3$wbss_canum_1000*(wbss3$weca_g/1000)
# wbss3$nsas_caton_t<-wbss3$nsas_canum_1000*(wbss3$weca_g/1000)
#
# prop<-aggregate(cbind(wbss_caton_t,nsas_caton_t)~year+area+fleet, data=wbss3, FUN=sum)
# write.table(prop, paste(path_data,"wbbs_nsas_prop_catch_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
# ```
