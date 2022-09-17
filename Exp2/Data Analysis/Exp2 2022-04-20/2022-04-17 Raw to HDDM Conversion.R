#collapsed dprime by target and color positions

#setup====
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
lapply(c("tidyverse", "patchwork", "BayesFactor"),
       require,
       character.only = T)

library(readr)
data <- read_csv(
  "merged_file.csv",
  col_types = cols(
    trialNum = col_number(),
    cntBalance = col_skip(),
    correct = col_character(),
    rt = col_double(),
    rwdType = col_number(),
    tgtCol = col_skip(),
    tgtDir = col_skip(),
    tgtPos = col_number(),
    colPos = col_number(),
    colMatch = col_number()
  )
)

data <- tibble::as_tibble(data)
data <- filter(data,
               trialType == "RSVPtest",
               rt > quantile(data$rt, 0.025, na.rm = TRUE)) %>%
  select(subID, rt, correct, rwdType, tgtPos, colPos, colMatch)
data$subID <- as.numeric(factor(data$subID,
                                    levels = unique(data$subID))) - 1
data$correct <- as.integer(as.logical(data$correct))

print(data,n=500)

write.csv(data, file = "HDDM_data.csv", row.names = FALSE)
