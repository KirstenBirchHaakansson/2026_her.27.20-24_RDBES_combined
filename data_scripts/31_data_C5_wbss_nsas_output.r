

options("scipen" = 1000, digits = 6)
library(dplyr)
library(tidyr)
library(readxl)

year_0 <- 2024

#Read-in

canum3 <-
  readRDS(paste("data/", "C6_her2024_canum_wbss_nsas_", year_0, ".rds", sep =
                  ""))
canum3$weca_kg <- canum3$weca_g / 1000

canum4 <-
  read_excel(
    paste(
      "boot/data/split_data/",
      "Her21-IVaE_transfer_only_split_",
      year_0,
      ".xlsx",
      sep = ""
    ),
    sheet = 3
  )

canum4 <- rename(canum4, wbss_canum_1000 = canum_000)
canum4$weca_g <- canum4$weca_kg * 1000
canum4$fleet <- "A"
canum4$wr <- ifelse(canum4$wr %in% c("8", "9"), "8+", canum4$wr)

canum <- bind_rows(canum3, canum4)

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
  paste("data/", "C7_wbss_multi_fleet_area_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_wbss_multi_fleet_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_wbss_multi_fleet_t_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_wbss_single_fleet_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_wbss_single_fleet_t_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_nsas_input_fleet_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_nsas_input_total_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_nsas_input_quarter_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_nsas_input_fleet_area_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_wbss_input_quarter_", year_0, ".csv", sep = ""),
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
  paste("data/", "C7_wbss_input_quarter_t_", year_0, ".csv", sep = ""),
  sep = ",",
  row.names = F
)

# ```{r, eval = F}
#
# write.table(wbssFinal, paste("data/","wbbs_catch_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
#
# ```
#
# #WEST
# ```{r, eval = F}
# wbssWEST<-aggregate(cbind(wbss_canum_1000,caton)~year+wr+quarter, data=wbss, FUN=sum)
# wbssWEST$weca_kg<-(wbssWEST$caton/wbssWEST$wbss_canum_1000)
#
# write.table(wbssWEST, paste("data/","wbbs_catch_west_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
# ```
#
# #Cacth WBSS and NSAS
# ```{r, eval = F}
# wbss3<-readRDS(paste("data/","3a_splitted_", year, ".rsd", sep=""))
# wbss3a<-subset(wbss3, area %in% c("27.3.a.20","27.3.a.21"))
#
# wbss3a$wbss_caton_t<-wbss3a$wbss_canum_1000*(wbss3a$weca_g/1000)
# wbss3a$nsas_caton_t<-wbss3a$nsas_canum_1000*(wbss3a$weca_g/1000)
#
# prop<-aggregate(cbind(wbss_caton_t,nsas_caton_t)~year+fleet, data=wbss3a, FUN=sum)
# write.table(prop, paste("data/","wbbs_nsas_prop_catch_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
# ```
#
# ```{r, eval = F}
#
# wbss3$wbss_caton_t<-wbss3$wbss_canum_1000*(wbss3$weca_g/1000)
# wbss3$nsas_caton_t<-wbss3$nsas_canum_1000*(wbss3$weca_g/1000)
#
# prop<-aggregate(cbind(wbss_caton_t,nsas_caton_t)~year+area+fleet, data=wbss3, FUN=sum)
# write.table(prop, paste("data/","wbbs_nsas_prop_catch_input_model_", year, ".csv", sep=""), sep=",", row.names=F)
# ```
