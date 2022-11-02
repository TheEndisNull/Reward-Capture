startup <- function() {
    packages <- c("tidyverse", "readr")
    # Install packages not yet installed
    installed_packages <- packages %in% rownames(installed.packages())
    if (any(installed_packages == FALSE)) {
        install.packages(packages[!installed_packages])
    }
    # Packages loading
    invisible(lapply(packages, library, character.only = TRUE))
    rm(packages, installed_packages)
}
startup()
rm(startup)

data <- read_csv("data/HDDM_data3.csv")
data <- tibble::as_tibble(data)
data$subID <- as.factor(data$subID)

test <- filter(
    data,
    colMatch == 2,
    rwdType == 1,
    tgtPos == 0,
    correct == TRUE
) %>%
group_by(subID, .drop = FALSE) %>%
summarize(hits = n()) %>%
select(subID, hits)


for (i in 1:2) {
    assign(
        paste0("congruent", rwdName[i]),
        bind_cols(
            filter(
                data,
                rwdType == rwdArr[i],
                tgtPos == rwdArr[i],
                correct == TRUE
            ) %>%
                group_by(subID, .drop = F) %>%
                summarize(hits = n()) %>%
                select(subID, hits),
            filter(
                data,
                rwdType == rwdArr[i],
                tgtPos == rwdArr[i],
                correct == FALSE
            ) %>%
                group_by(subID, .drop = F) %>%
                summarize(
                    miss = n(),
                    rt = median(rt)
                ) %>%
                select(miss),
            filter(
                data,
                rwdType == rwdArr[i],
                tgtPos == 3,
                correct == F
            ) %>%
                group_by(subID, .drop = F) %>%
                summarize(
                    fAlm = n(), # fAlm = false alarm
                    rt = median(rt)
                ) %>%
                select(fAlm),
            filter(
                data,
                rwdType == rwdArr[i],
                tgtPos == 3,
                correct == T
            ) %>%
                group_by(subID, .drop = F) %>%
                summarize(
                    rejt = n(), # rejt = rejections
                    rt = median(rt)
                ) %>%
                select(rejt)
        ) %>%
            mutate(
                hitSum = hits + miss,
                hitRate = hits / hitSum,
                HR = ifelse(
                    hitRate == 1,
                    (hits - 0.5) / hitSum,
                    ifelse(hitRate == 0,
                        (hits + 0.5) / hitSum,
                        hitRate
                    )
                ),
                fAlmSum = fAlm + rejt,
                fAlmRate = fAlm / fAlmSum,
                FA = ifelse(
                    fAlmRate == 1,
                    (fAlm - 0.5) / fAlmSum,
                    ifelse(fAlmRate == 0,
                        (fAlm + 0.5) / fAlmSum,
                        fAlmRate
                    )
                ),
                dprime = qnorm(HR) - qnorm(FA),
                criterion = -(qnorm(HR) + qnorm(FA)) / 2,
                rwd = as.factor(replicate(n = n(), rwdArr[i]))
            )
    )
}
