# collapsed dprime by target and color positions

# setup====
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
lapply(c("tidyverse"),
       require,
       character.only = T)

data <- read_csv(
  "data 4-27.csv",
  col_types = cols(
    rt = col_double(),
    color = col_skip(),
    tgtPosition = col_character(),
    rewardType = col_character(),
    reward = col_skip(),
    colorPosition = col_character(),
    correct = col_factor(levels = c("FALSE", "TRUE", "null"))
  )
) %>% rename(
  subj_idx = subject,
  response = correct,
  tgtPos = tgtPosition,
  rwdType = rewardType,
  colPos = colorPosition,
) %>%
  mutate(
    subj_idx = substr(subj_idx, 1, 3),
    rwdType = as.integer(str_replace_all(
      rwdType, c(
        "none" = "0",
        "low" = "1",
        "high" = "2"
      )
    )),
    tgtPos = as.integer(str_replace_all(
      tgtPos,  c(
        "new" = "0",
        "1st" = "1",
        "2nd" = "2",
        "3rd" = "3"
      )
    )),
    colPos = as.integer(str_replace_all(
      colPos,  c(
        "none" = "0",
        "1st" = "1",
        "2nd" = "2",
        "3rd" = "3"
      )
    ))
  ) %>%
  filter(trialType == "RSVPtest",
         rt > quantile(data$rt, 0.025, na.rm = TRUE)) %>%
  select(subj_idx, rt, response, rwdType, tgtPos, colPos)

data <-
  mutate(
    data,
    colMatch = ifelse(
      tgtPos == colPos & rwdType != 0,
      2,
      ifelse(tgtPos != colPos &
               rwdType != 0, 1, 0)
    ),
    rt = rt / 1000
  )

data$subj_idx <- as.numeric(factor(data$subj_idx,
                                   levels = unique(data$subj_idx))) - 1

data$response <- as.integer(data$response) - 1




dataMatching <- filter(data, colMatch == 2)
write.csv(dataMatching, file = "HDDM Matching.csv", row.names = FALSE)


dataNonMatching <- filter(data, colMatch == 1 & tgtPos != 0)
write.csv(dataNonMatching, file = "HDDM Non-Matching.csv", row.names = FALSE)
