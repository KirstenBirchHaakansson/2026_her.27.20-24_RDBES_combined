
library(icesTAF)

getwd()
# taf.skeleton()


# draft.data(data.files = "preliminary_catch_statistics",
#            data.scripts = NULL,
#            originator = "ICES",
#            title = "Preliminary catch statistic from ICES",
#            file = T,
#            append = F)



draft.data(data.files = "submitted_data/PL_DC_Annex_HAWG3 her.27.20-24_PL_2026.xlsx",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Poland",
           period = "2025",
           access = "Restricted",
           file = T,
           append = F)


draft.data(data.files = "submitted_data/2026_DC_Annex_HAWG3 her.27.20-24_2025_GER.xlsx",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Germany",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/NO_2026 DC HAWG her.27.20-24 NO.xlsx",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Norway",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/2026 DC HAWG her.27.20-24 NO_v2.xlsx",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Norway. Including a sample from the transfer area",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/DC_Annex_HAWG3 her.27.20-24 template_DNK_2025.xlsx",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Denmark",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/DC_Annex_HAWG3 her.27.20-24 template_DNK_2025_v2.xlsx",
           data.scripts = NULL,
           originator = "Corrected by kibi",
           title = "Forgot to delete old CANUN in area 22",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/SE_2026 DC HAWG her.27.20-24 YellowSheet_v2.xlsx",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Sweden",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/SE_2026 DC HAWG her.27.20-24 YellowSheet_v3.xlsx",
           data.scripts = NULL,
           originator = "Corrected by kibi",
           title = "One of the fleet was wrong in the template",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "data_from_bm",
           data.scripts = NULL,
           originator = "Benchmark",
           title = "Data from benchmark",
           period = "2000-2024",
           access = "Restricted",
           file = T,
           append = T)

# draft.data(data.files = "imputations",
#            data.scripts = NULL,
#            originator = "Manual imputation",
#            title = "Imputations",
#            file = T,
#            append = T)
# 
# draft.data(data.files = "split_data",
#            data.scripts = NULL,
#            originator = "Results needed for the split",
#            title = "Split data",
#            file = T,
#            append = T)
# 
# draft.data(data.files = "time_series",
#            data.scripts = NULL,
#            originator = "Former HAWGs",
#            title = "Time series from last year",
#            file = T,
#            append = T)
# 
# # draft.data(data.files = "data_from_tomas",
# #            data.scripts = NULL,
# #            originator = "Data from Tomas (former SC)",
# #            title = "Data from Tomas",
# #            file = T,
# #            append = T)
# 
# draft.data(data.files = NULL,
#            data.scripts = "download_from_stockassessment_org_single_fleet.R",
#            originator = "stockassessment.org",
#            title = "Single fleet data from stockassessment.org",
#            file = T,
#            append = T)
# 
# draft.data(data.files = NULL,
#            data.scripts = "download_from_stockassessment_org_multi_fleet.R",
#            originator = "stockassessment.org",
#            title = "Multi fleet data from stockassessment.org",
#            file = T,
#            append = T)

# draft.data(data.files = "Herring_TAC_catches_by_area.csv",
#            data.scripts = NULL,
#            originator = "Updated 2024",
#            title = "TAC and catch",
#            file = T,
#            append = T)
# 
# draft.data(data.files = "kibi_notes",
#            data.scripts = NULL,
#            originator = "Kibi",
#            title = "Kibi's notes",
#            file = T,
#            append = T)
# 
# draft.data(data.files = "tac_catchs_table_for_fig",
#            data.scripts = NULL,
#            originator = "Kibi",
#            title = "TAC and catches tables updated with 2024",
#            file = T,
#            append = T)



taf.boot()

# mkdir("data")
# mkdir("output")

# sourceTAF("data") 
# 
# sourceTAF("report") 
# run model_0....
