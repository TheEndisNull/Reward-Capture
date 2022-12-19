# collapsed dprime by target and color positions

# setup====
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
lapply(c("tidyverse"),
  require,
  character.only = T
)

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
data <- filter(
  data,
  trialType == "RSVPtest",
  rt > quantile(data$rt, 0.025, na.rm = TRUE)
) %>%
  select(subID, rt, correct, tgtPos, rwdType, colMatch)
data$subID <- as.numeric(factor(data$subID,
  levels = unique(data$subID)
)) - 1
data$correct <- as.integer(as.logical(data$correct))

data <- mutate(data,
tgtPos = ifelse(tgtPos==3, 1, 0),
rt = rt / 1000
)

print(data, n = 500)
write.csv(data, file = "HDDM_data.csv", row.names = FALSE)

matchingHLvN <- filter(data, rwdType==0 & tgtPos==0 | colMatch==2)
write.csv(matchingHLvN, file ="HDDM HL v N Matching.csv", row.names = FALSE)

NonMatchingHLvN <- filter(data, rwdType==0 & tgtPos==0 | colMatch==1 & tgtPos==0)
write.csv(NonMatchingHLvN, file ="HDDM HL v N Non-Matching.csv", row.names = FALSE)

#test was accidentally deleted, be sure to recover it
dataMatching <- filter(test, colMatch==2)
write.csv(dataMatching, file = "HDDM Matching.csv", row.names = FALSE)


dataNonMatching <- filter(test, colMatch==1)
write.csv(dataNonMatching, file = "HDDM Non-Matching.csv", row.names = FALSE)


