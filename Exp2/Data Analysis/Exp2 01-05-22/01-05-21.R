#Description

#Setup====
# Package names
packages <- c('tidyverse', 'readr')
# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# Packages loading
invisible(lapply(packages, library, character.only = TRUE))
rm(packages, installed_packages)

data <- read_csv(
  "data/g-9-19-42y.csv",
  col_types = cols(
    cntBalance = col_factor(levels = c("r",
                                       "g")),
    correct = col_logical(),
    rt = col_double(),
    rwdType = col_factor(levels = c("0",
                                    "1", "2")),
    tgtCol = col_skip(),
    tgtDir = col_skip(),
    #tgtPos = col_factor(levels = c("0",
    #                               "1", "2", "3", "4", "5")),
    #colPos = col_factor(levels = c("0",
    #                               "1", "2", "3")),
    ...13 = col_skip()
  ),
  na = "empty"
)

data <- tibble::as_tibble(data)
data <- filter(data,
               trialType == 'RSVPtest',
               subID != 'brk') %>%
  select(subID, correct, rt, rwdType, tgtPos, colPos, colMatch)
data$subID <- as.factor(data$subID)

data

rwdName = c('Low', 'High', 'None')
rwdArr = c(1, 2, 0)

for (i in 1:2) {
  assign(
    paste0('congruent', rwdName[i]),
    bind_cols(
      filter(data,
             rwdType == rwdArr[i],
             tgtPos == colPos,
             correct == T) %>%
        group_by(subID, .drop = F) %>%
        summarize(hits = n()) %>%
        select(subID, hits),
      filter(data,
             rwdType == rwdArr[i],
             tgtPos == colPos,
             correct == F) %>%
        group_by(subID, .drop = F) %>%
        summarize(miss = n(),
                  rt = median(rt)) %>%
        select(miss),
      filter(data,
             rwdType == rwdArr[i],
             tgtPos == 3,
             correct == F) %>%
        group_by(subID, .drop = F) %>%
        summarize(fAlm = n(), #fAlm = false alarm
                  rt = median(rt)) %>%
        select(fAlm),
      filter(data,
             rwdType == rwdArr[i],
             tgtPos == 3,
             correct == T) %>%
        group_by(subID, .drop = F) %>%
        summarize(rejt = n(), #rejt = rejections
                  rt = median(rt)) %>%
        select(rejt)
    ) %>%
      mutate (
        hitSum = hits + miss,
        hitRate = hits / hitSum,
        HR = switch(
          as.character(hitRate),
          '0' = (hits + 0.5) / hitSum,
          '1' = (hits - 0.5) / hitSum,
          hitRate
        ),
        fAlmSum = fAlm + rejt,
        fAlmRate = fAlm / fAlmSum,
        FA = switch(
          as.character(fAlmRate),
          '0' = (fAlm + 0.5) / fAlmSum,
          '1' = (fAlm - 0.5) / fAlmSum,
          fAlmRate
        ),
        dprime = qnorm(HR) - qnorm(FA),
        criterion = -(qnorm(HR) + qnorm(FA)) / 2,
        rwd = as.factor(replicate(n = n(), rwdArr[i]))
      )
  )
}


assign(
  paste0('congruent', rwdName[3]),
  bind_cols(
    filter(data,
           rwdType == rwdArr[3],
           tgtPos != 3,
           correct == T) %>%
      group_by(subID, .drop = F) %>%
      summarize(hits = n()) %>%
      select(subID, hits),
    filter(data,
           rwdType == rwdArr[3],
           tgtPos != 3,
           correct == F) %>%
      group_by(subID, .drop = F) %>%
      summarize(miss = n(),
                rt = median(rt)) %>%
      select(miss),
    filter(data,
           rwdType == rwdArr[3],
           tgtPos == 3,
           correct == F) %>%
      group_by(subID, .drop = F) %>%
      summarize(fAlm = n(), #fAlm = false alarm
                rt = median(rt)) %>%
      select(fAlm),
    filter(data,
           rwdType == rwdArr[3],
           tgtPos == 3,
           correct == T) %>%
      group_by(subID, .drop = F) %>%
      summarize(rejt = n(), #rejt = rejections
                rt = median(rt)) %>%
      select(rejt)
  ) %>%
    mutate (
      hitSum = hits + miss,
      hitRate = hits / hitSum,
      HR = switch(
        as.character(hitRate),
        '0' = (hits + 0.5) / hitSum,
        '1' = (hits - 0.5) / hitSum,
        hitRate
      ),
      fAlmSum = fAlm + rejt,
      fAlmRate = fAlm / fAlmSum,
      FA = switch(
        as.character(fAlmRate),
        '0' = (fAlm + 0.5) / fAlmSum,
        '1' = (fAlm - 0.5) / fAlmSum,
        fAlmRate
      ),
      dprime = qnorm(HR) - qnorm(FA),
      criterion = -(qnorm(HR) + qnorm(FA)) / 2,
      rwd = as.factor(replicate(n = n(), rwdArr[3]))
    )
)

