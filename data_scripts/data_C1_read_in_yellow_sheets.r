
# library(sqldf)
library(dplyr)
library(knitr)
library(icesTAF)

mkdir("data")

options("scipen" = 1000, digits = 4)

type <- "v1"

year <- 2024

# File names 2024
dnkFile <- "DC_Annex_HAWG3 her.27.20-24 template_DNK_2024.xlsx"
gerFile <- "2025_DC_Annex_HAWG3 her.27.20-24_2024_GER.xlsx"
polFile <- "DC_Annex_HAWG3 her.27.20-24_PL_rev_MA.xlsx"
sweFile <- "SE_2025 DC HAWG her.27.20-24 YellowSheet_v3.xlsx"
norFile <- "DC_Annex_HAWG3 her.27.20-24_NOR2024_v4.xlsx"


# Read in data ----
## Canum ----

dnk <-
  read_in_canum(
    paste("boot/data/", dnkFile, sep = ""),
    sheets = c(6:22),
    noAgeClasses = 9
  )

ger <-
  read_in_canum(
    paste("boot/data/", gerFile, sep = ""),
    sheets = c(7:23),
    noAgeClasses = 9
  )

pol <-
  read_in_canum(
    paste("boot/data/", polFile, sep = ""),
    sheets = c(8:10),
    noAgeClasses = 9
  )

swe <-
  read_in_canum(
    paste("boot/data/", sweFile, sep = ""),
    sheets = c(6:22),
    noAgeClasses = 9
  )

nor <-
  read_in_canum(
    paste("boot/data/", norFile, sep = ""),
    sheets = c(6),
    noAgeClasses = 9
  )


## Read in samples ----  

dnkS <-
  read_in_samples(
    paste("boot/data/", dnkFile, sep = ""),
    sheets = c(6:22),
    firstLineSamples = 27
  )

gerS <-
  read_in_samples(
    paste("boot/data/", gerFile, sep = ""),
    sheets = c(7:23),
    firstLineSamples = 27
  )

polS <-
  read_in_samples(
    paste("boot/data/", polFile, sep = ""),
    sheets = c(8:10),
    firstLineSamples = 27
  )

sweS <-
  read_in_samples(
    paste("boot/data/", sweFile, sep = ""),
    sheets = c(6:22),
    firstLineSamples = 27
  )

norS <-
  read_in_samples(
    paste("boot/data/", norFile, sep = ""),
    sheets = c(6),
    firstLineSamples = 27
  )


## Read in catch ----

dnkC <-
  read_in_catch(paste("boot/data/", dnkFile, sep = ""),
                sheets = 3,
                noAreas = 29)

gerC <-
  read_in_catch(paste("boot/data/", gerFile, sep = ""),
                sheets = 3,
                noAreas = 29)

polC <-
  read_in_catch(paste("boot/data/", polFile, sep = ""),
                sheets = c(3),
                noAreas = 29)

sweC <-
  read_in_catch(paste("boot/data/", sweFile, sep = ""),
                sheets = c(3),
                noAreas = 29)

norC <-
  read_in_catch(paste("boot/data/", norFile, sep = ""),
                sheets = c(3),
                noAreas = 29)


## Read in landings per square from area_official ----


dnkR <-
  read_in_areaOfficial(
    path = paste("boot/data/", dnkFile, sep = ""),
    sheets = c(23),
    noRectangles = 1182
  )

gerR <-
  read_in_areaOfficial(
    path = paste("boot/data/", gerFile, sep = ""),
    sheets = c(24),
    noRectangles = 1182
  )

polR <-
  read_in_areaOfficial(
    path = paste("boot/data/", polFile, sep = ""),
    sheets = c(11),
    noRectangles = 1182
  )

sweR <-
  read_in_areaOfficial(
    path = paste("boot/data/", sweFile, sep = ""),
    sheets = c(23),
    noRectangles = 1182
  )

norR <-
  read_in_areaOfficial(
    path = paste("boot/data/", norFile, sep = ""),
    sheets = c(7),
    noRectangles = 1183
  )

# Combine and recode ----
## Canum ----


canum <- rbind(dnk, ger, pol, swe, nor)

unique(canum$ctry)

canum$ctry[canum$ctry == "POLAND"] <- "Poland"

unique(canum$sppName)

distinct(canum, ctry, sppName)

canum$sppName <- ifelse(canum$sppName %in% c("Herring (Clupea harengus)", "Herring south of 62N", "Clupea harengus", "HERRING"), "Herring", canum$sppName)

unique(canum$sppName)

unique(canum$year)

unique(canum$area)

canum$area <-
  ifelse(
    canum$area %in% c("SD 20", "IIIaN", "IIIa"),
    "27.3.a.20",
    ifelse(
      canum$area %in% c("SD 21", "IIIaS"),
      "27.3.a.21",
      ifelse(
        canum$area %in% c("SD 22", "BAL22"),
        "27.3.c.22",
        ifelse(
          canum$area %in% c("SD 23", "BAL23"),
          "27.3.b.23",
          ifelse(canum$area %in% c("SD 24", "BAL24"), "27.3.d.24", canum$area)
        )
      )
    )
  )

unique(canum$area)

distinct(canum, area, ctry, fleet)

canum$subFleet <- canum$fleet

canum$fleet[canum$area %in% c("27.3.a.20", "27.3.a.21") &
              canum$subFleet %in% c("passive", "purse seine", "trawl >= 32mm")] <- "C"

canum$fleet[canum$area %in% c("27.3.a.20", "27.3.a.21") &
              canum$subFleet %in% c("trawl < 32mm")] <- "D"

canum$fleet[canum$area %in% c("27.3.c.22", "27.3.b.23", "27.3.d.24")] <- "F"


distinct(canum, ctry, fleet, subFleet, area)

distinct(canum, area, fleet)

unique(canum$wr)

canum$wr <- ifelse(canum$wr %in% c("8.000000", "8"), "8+", canum$wr)

unique(canum$wr)

##Handling units

unique(canum$canum_unit)

unit <- distinct(canum, ctry, canum_unit)

#subset(canum, canum_unit=="(1000)")

canum$canum_1000 <- ifelse(canum$canum_unit == "(millions)", canum$canum*1000, canum$canum)

unique(canum$weca_unit)
weca_unit <- distinct(canum, ctry, weca_unit)
canum$weca_g <-
  ifelse(canum$weca_unit %in% c("(Kg)", "(kg)"),
         canum$weca * 1000,
         canum$weca)

unique(canum$leca_unit)
canum$leca_cm <- ifelse(canum$leca_unit != "(cm)", "", canum$leca)

unique(canum$catch_unit)
canum$catch_t <- ifelse(canum$catch_unit != "(t)", "", canum$catch)

##Add zero's to canum
canum <- subset(canum,!is.na(wr))

year_dummy <- distinct(canum, year)
ctry <- distinct(canum, ctry)
sppName <- distinct(canum, sppName)
fleet <- distinct(canum, fleet, subFleet, area)
wr <- distinct(canum, wr)
quarter <- distinct(canum, quarter)

dummy <-
  sqldf("select * from year_dummy, ctry, sppName, fleet, wr, quarter")

canum0 <-
  canum[, c("year", "ctry", "sppName", "fleet", "subFleet", "area", "wr", "quarter")]
dummy1 <- setdiff(dummy, canum0)

canum1 <- bind_rows(canum, dummy1)

#Replace NA for certain variables

canum1$canum <- ifelse(is.na(canum1$canum), 0, canum1$canum)
canum1$canum_1000 <-
  ifelse(is.na(canum1$canum_1000), 0, canum1$canum_1000)
canum1$catch_t <- ifelse(is.na(canum1$catch_t), 0, canum1$catch_t)

## Sample ----
samp <- rbind(dnkS, gerS, polS, sweS, norS)

unique(samp$noSample)

samp$noSample <- ifelse(is.na(samp$noSample), 0, samp$noSample)
samp$noLength <- ifelse(is.na(samp$noLength), 0, samp$noLength)
samp$noAge <- ifelse(is.na(samp$noAge), 0, samp$noAge)

unique(samp$noSample)

unique(samp$ctry)
samp$ctry[samp$ctry == "POLAND"] <- "Poland"

unique(samp$sppName)

samp$sppName <-
  ifelse(
    samp$sppName %in% c(
      "Herring (Clupea harengus)",
      "Herring south of 62N",
      "Clupea harengus",
      "HERRING"
    ),
    "Herring",
    samp$sppName
  )

unique(samp$sppName)

unique(samp$year)

unique(samp$area)

samp$area <-
  ifelse(
    samp$area %in% c("SD 20", "IIIaN", "IIIa"),
    "27.3.a.20",
    ifelse(
      samp$area %in% c("SD 21", "IIIaS"),
      "27.3.a.21",
      ifelse(
        samp$area %in% c("SD 22", "BAL22"),
        "27.3.c.22",
        ifelse(
          samp$area %in% c("SD 23", "BAL23"),
          "27.3.b.23",
          ifelse(samp$area %in% c("SD 24", "BAL24"), "27.3.d.24", samp$area)
        )
      )
    )
  )

distinct(samp, area, ctry, fleet)

samp$subFleet <- samp$fleet

samp$fleet[samp$area %in% c("27.3.a.20", "27.3.a.21") &
              samp$subFleet %in% c("passive", "purse seine", "trawl >= 32mm")] <- "C"

samp$fleet[samp$area %in% c("27.3.a.20", "27.3.a.21") &
              samp$subFleet %in% c("trawl < 32mm")] <- "D"

samp$fleet[samp$area %in% c("27.3.c.22", "27.3.b.23", "27.3.d.24")] <- "F"


distinct(samp, ctry, fleet, subFleet, area)

distinct(samp, area, fleet)


## Catch ----

catch <- rbind(dnkC, polC, gerC, sweC, norC)

str(catch)

catch$landWt <- as.numeric(catch$landWt)
catch$unallocCatchWt <- as.numeric(catch$unallocCatchWt)
catch$misRepCatchWt <- as.numeric(catch$misRepCatchWt)
catch$disWt <- as.numeric(catch$disWt)

str(catch)

##Check codes in catch

unique(catch$ctry)
catch$ctry[catch$ctry == "POLAND"] <- "Poland"

unique(catch$area)

catch$area <- ifelse(
  catch$area == "3an/Skagerrak",
  "27.3.a.20",
  ifelse(catch$area == "3as/Kattegat", "27.3.a.21", catch$area)
)


catch$area <- ifelse(
  catch$area %in% c("SD 20", "IIIaN"),
  "27.3.a.20",
  ifelse(
    catch$area %in% c("SD 21", "IIIaS"),
    "27.3.a.21",
    ifelse(
      catch$area %in% c("22", "SD 22", "BAL22"),
      "27.3.c.22",
      ifelse(
        catch$area %in% c("23", "SD 23", "BAL23"),
        "27.3.b.23",
        ifelse(
          catch$area %in% c("24", "SD 24", "BAL24"),
          "27.3.d.24",
          catch$area
        )
      )
    )
  )
)
unique(catch$area)

catch[is.na(catch)] <- 0

catch$catch <-
  catch$landWt + catch$unallocCatchWt + catch$misRepCatchWt + catch$disWt


## Rect ----

rect <- rbind(dnkR, polR, gerR, sweR, norR)

str(rect)

unique(rect$ctry)
rect$ctry[rect$ctry == "POLAND"] <- "Poland"

##Check codes in rect

unique(rect$unit)

rect$catch_t <-
  ifelse(rect$unit == "(millions)", rect$landWt * 1000, rect$landWt)

# Merge samples with canum ----

canum2 <- merge(canum1, samp, all.x = T)

canum2$noSample <- ifelse(is.na(canum2$noSample), 0, canum2$noSample)
canum2$noLength <- ifelse(is.na(canum2$noLength), 0, canum2$noLength)
canum2$noAge <- ifelse(is.na(canum2$noAge), 0, canum2$noAge)

# Merge length and samples ----

# length1<-merge(length,samp, all.x=T)
# 
# length1$noSample<-ifelse(is.na(length1$noSample), 0, length1$noSample)
# length1$noLength<-ifelse(is.na(length1$noLength), 0, length1$noLength)
# length1$noAge<-ifelse(is.na(length1$noAge), 0, length1$noAge)

sw <-
  subset(canum2, ctry == "Sweden" &
           area %in% c("27.3.a.20", "27.3.a.21"))
rest <-
  subset(canum2,!(ctry == "Sweden" &
                    area %in% c("27.3.a.20", "27.3.a.21")))

# SOP correction ----



sop <-
  aggregate(((canum_1000 * weca_g) / 1000) ~ ctry + sppName + year + area +
              quarter + fleet + subFleet + catch_t,
            data = canum2,
            FUN = sum
  )

colnames(sop) <-
  c("ctry",
    "sppName",
    "year",
    "area",
    "quarter",
    "fleet",
    "subFleet",
    "catch_t",
    "sop")
sop$sop <- as.numeric(sop$sop)

canum3 <- merge(canum2, sop, all.x = T)
canum3$sopCorr <- (canum3$catch_t / canum3$sop)
canum3$canum_1000 <-
  ifelse(
    canum3$canum_1000 > 0,
    canum3$canum_1000 * (canum3$catch_t / canum3$sop),
    canum3$canum_1000
  )

testSop <-
  aggregate(((canum_1000 * weca_g) / 1000) ~ ctry + sppName + year + area +
              quarter + fleet + subFleet + catch_t,
            data = canum3,
            FUN = sum
  )


kable(arrange(distinct(canum3, ctry, year, fleet, subFleet, area, quarter, sopCorr), -sopCorr), caption = "SOP")



# Output data ----
saveRDS(canum3,
        paste(
          "data/",
          "C1_her2024_canum_without_imputations_", year, ".rds",
          sep = ""
        ))

write.table(
  canum3,
  paste(
    "data/",
    "C1_her2024_canum_without_imputations_", year, ".csv",
    sep = ""
  ),
  sep = ",",
  row.names = F,
  na = ""
)

saveRDS(sw,
        paste(
          "data/",
          "C1_SWE_her2024_fleet_C_D_before_merge_", year, ".rds",
          sep = ""
        ))

write.table(
  sw,
  paste(
    "data/",
    "C1_SWE_her2024_fleet_C_D_before_merge_", year, ".csv",
    sep = ""
  ),
  sep = ",",
  row.names = F,
  na = ""
)

saveRDS(samp, paste("data/", "C1_her2024_samples_", year, ".rds", sep = ""))
write.table(
  samp,
  paste("data/", "C1_her2024_samples_", year, ".csv", sep = ""),
  sep = ",",
  row.names = F,
  na = ""
)

saveRDS(catch, paste("data/", "C1_her2024_catch_", year, ".rds", sep = ""))
write.table(
  catch,
  paste("data/", "C1_her2024_catch_", year, ".csv", sep = ""),
  sep = ",",
  row.names = F,
  na = ""
)


saveRDS(rect, paste("data/", "C1_her2024_rect_", year, ".rds", sep = ""))
write.table(
  rect,
  paste("data/", "C1_her2024_rect_", year, ".csv", sep = ""),
  sep = ",",
  row.names = F,
  na = ""
)


# saveRDS(length1,
#         paste(dataPath, "C1_her2024_length_", year, ".rds", sep = ""))
# write.table(
#   length1,
#   paste(dataPath, "C1_her2024_length_", year, ".csv", sep = ""),
#   sep = ",",
#   row.names = F,
#   na = ""
# )



