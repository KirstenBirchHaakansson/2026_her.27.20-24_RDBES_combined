
# devtools::install_github("fishfollower/SAM/stockassessment", ref="multi")

library(stockassessment)

SAOAssessment <- "WBSS_HAWG_2025"   # = stock name in stockassesssment.org
user <- 278                            # User 2 = Anders; User 3 = Guest (ALWAYS GETS THE LATEST COMMITTED VERSION)

### Read raw data from stockassessment.org
url <-
  paste(
    "https://www.stockassessment.org/datadisk/stockassessment/userdirs/user",
    user,
    "/",
    SAOAssessment,
    "/data/",
    sep = ""
  )

filestoget <- c(
  "cn.dat",
  "cw.dat",
  "dw.dat",
  "lf.dat",
  "lw.dat",
  "mo.dat",
  "nm.dat",
  "pf.dat",
  "pm.dat",
  "sw.dat",
  "survey.dat" , "cn_A.dat", "cn_C.dat", "cn_D.dat", "cn_F.dat", "cw_A.dat", "cw_C.dat", "cw_D.dat", "cw_F.dat"
)  #

lapply(filestoget, function(f)
    download.file(paste(url, f, sep = ""), f))

### Read model from stockassessment.org
url <-
  paste(
    "https://www.stockassessment.org/datadisk/stockassessment/userdirs/user",
    user,
    "/",
    SAOAssessment,
    "/run/",
    sep = ""
  )

filestoget <- c(
  "model.RData"
)  #, "cn_A.dat", "cn_C.dat", "cn_D.dat", "cn_F.dat", "cw_A.dat", "cw_C.dat", "cw_D.dat", "cw_F.dat"


  lapply(filestoget, function(f)
    download.file(paste(url, f, sep = ""), f))

  
# Download png's
  
  SAOAssessment <- "WBSS_HAWG_2025"   # = stock name in stockassesssment.org
  user <- 3                           # User 2 = Anders; User 3 = Guest (ALWAYS GETS THE LATEST COMMITTED VERSION)
  url <-
    paste(
      "https://www.stockassessment.org/datadisk/stockassessment/userdirs/user",
      user,
      "/",
      SAOAssessment,
      "/res/",
      sep = ""
    )
  
  prefix <- "big_xxx-00-00.00.00_"
  suffix <- ".png"
  
  number <- as.character(c(1:30))
  number <- stringr::str_pad(number, 3, "0", side = "left")
  
  paste0(prefix, number, suffix)
  
  filestoget <- paste0(prefix, number, suffix)
  
  lapply(filestoget, function(f)
    download.file(paste(url, f, sep = ""), f, mode = 'wb'))
  