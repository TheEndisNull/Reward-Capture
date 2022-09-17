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
  "data/merged_file.csv",
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

`%!in%` <- Negate(`%in%`)

data <- tibble::as_tibble(data)
data <- filter(
  data,
  trialType == 'RSVPtest',
  subID %!in%  c('brk', '0tt', 'a0v', 'c90', 'rp9', 'tx3', 'y95', 'yz3'),
  rt > 250 #quantile(data$rt, 0.025, na.rm = TRUE)
) %>%
  select(subID, correct, rt, rwdType, tgtPos, colPos, colMatch)



data$subID <- as.numeric(factor(data$subID,
                                levels = unique(data$subID))) - 1
data$correct <- as.integer(as.logical(data$correct))


onlyMatch <- filter(data,
                    colMatch == 2, #set to !=0 for all color trials, ==2 for only matching
                    tgtPos != 3)

onlyControl <- filter(data,
                      rwdType == 0,
                      tgtPos != 3)
onlyNew <- filter(data,
                  tgtPos == 3)

recombined <- bind_rows(onlyMatch, onlyControl, onlyNew) %>%
  arrange(subID) %>%
  mutate(rt = rt / 1000,
         stim = rwdType)
write.csv(recombined, file = 'HDDMdata.csv')

print(
filter(recombined,
       subID == 1,
       rwdType == 0),
n=60)


group_by(recombined,
         subID) %>%
  filter(rwdType == 0) %>%
  summarise(avgRT = mean(rt),
            VarRT = var(rt),
            pCorr = mean(correct))


#forfastDM model
for (r in 0:2) {
  for (i in 0:6) {
    test <- filter(recombined,
                   subID == i,
                   rwdType == r) %>%
      select(subID, correct, rt, rwdType) %>%
      unite('#subj_idx response rt stim', subID:rwdType, sep = " ")
    write.csv(
      test,
      file = paste0('sub', i, 'rwd', r, '.csv'),
      row.names = F,
      quote = F
    )
  }
}
HDDM

dataf$MY <- paste(dataf$Month, dataf$Year)
