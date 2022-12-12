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

data <- read_csv("data/HDDM_data4.csv")
data <- tibble::as_tibble(data)
data$subID <- as.factor(data$subID)

congArr <- c("incongruent", "congruent")
rwdName <- c("Low", "High", "None")

for (i in 1:2) { # reward
    for (j in 1:2) { # congruence
        assign(
            paste0(congArr[j], rwdName[i]),
            bind_cols(
                filter(
                    data,
                    rwdType == i,
                    colMatch == j,
                    tgtPos == 0,
                    correct == TRUE
                ) %>%
                    group_by(subID, .drop = FALSE) %>%
                    summarize(hits = n()) %>%
                    select(subID, hits),
                filter(
                    data,
                    rwdType == i,
                    colMatch == j,
                    tgtPos == 0,
                    correct == FALSE
                ) %>%
                    group_by(subID, .drop = FALSE) %>%
                    summarize(miss = n()) %>%
                    select(miss),
                filter(
                    data,
                    rwdType == i,
                    tgtPos == 1, # For false alarms, colMatch is not required
                    correct == FALSE
                ) %>%
                    group_by(subID, .drop = FALSE) %>%
                    summarize(fAlm = n()) %>%
                    select(fAlm),
                filter(
                    data,
                    rwdType == i,
                    tgtPos == 1,
                    correct == TRUE
                ) %>%
                    group_by(subID, .drop = FALSE) %>%
                    summarize(rejt = n()) %>%
                    select(rejt),
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
                    rwd = as.factor(replicate(n = n(), i)) # rwdArr[i]
                )
        )
    }
}

control <- bind_cols(
    filter(
        data,
        rwdType == 0,
        tgtPos == 0,
        correct == TRUE
    ) %>%
        group_by(subID, .drop = FALSE) %>%
        summarize(hits = n()) %>%
        select(subID, hits),
    filter(
        data,
        rwdType == 0,
        tgtPos == 0,
        correct == FALSE
    ) %>%
        group_by(subID, .drop = FALSE) %>%
        summarize(miss = n()) %>%
        select(miss),
    filter(
        data,
        rwdType == 0,
        tgtPos == 1, # For false alarms, colMatch is not required
        correct == FALSE
    ) %>%
        group_by(subID, .drop = FALSE) %>%
        summarize(fAlm = n()) %>%
        select(fAlm),
    filter(
        data,
        rwdType == 0,
        tgtPos == 1,
        correct == TRUE
    ) %>%
        group_by(subID, .drop = FALSE) %>%
        summarize(rejt = n()) %>%
        select(rejt),
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
        rwd = as.factor(replicate(n = n(), 0))
    )

library(Rmisc) #be sure to unload this when going back
longFormData <- bind_rows(congruentHigh, congruentLow, control)
longFormData <- bind_rows(incongruentHigh, incongruentLow, control)

hit_rate <-
    summarySEwithin(
        longFormData,
        measurevar = "HR",
        withinvars = "rwd",
        idvar = "subID"
    ) %>%
    mutate(
        condition = as.factor(c(replicate(3, "Hit Rate"))),
        mean = HR
    )

false_alarm_rate <-
    summarySEwithin(
        longFormData,
        measurevar = "FA",
        withinvars = "rwd",
        idvar = "subID"
    ) %>%
    mutate(
        condition = as.factor(c(replicate(3, "False Alarm Rate"))),
        mean = FA
    )

width <- .8
dodgeWidth <- .85
errWidth <- .4
errdodgeWidth <- .85

FA_HR_df <- bind_rows(hit_rate, false_alarm_rate) %>%
    select(rwd, mean, sd, se, ci, condition) %>%
    print()

HR_FA_bar <- ggplot(FA_HR_df, aes(
    y = mean,
    x = condition,
    fill = factor(rwd),
)) +
    geom_bar(
        stat = "identity",
        width = width,
        position = position_dodge(width = dodgeWidth),
        color = "black"
    ) +
    geom_errorbar(
        aes(
            ymin = mean - se,
            ymax = mean + se
        ),
        width = errWidth,
        position = position_dodge(width = errdodgeWidth),
        colour = "azure4",
        size = 1
    ) +
    coord_cartesian(ylim = c(.1, .9)) +
    labs(
        y = "Proportion",
        x = "Reward"
    ) +
    scale_fill_manual(
        values = c(
            "2" = "red",
            "1" = "green",
            "0" = "black"
        ),
        name = "Reward Condition",
        labels = c("High", "Low", "None")
    ) +
    theme_bw() +
    theme(
        legend.position = "none",
        axis.text = element_text(size = 24),
        axis.title = element_text(size = 32),
        axis.line = element_line(colour = "black"),
        panel.grid.major.x = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank()
    )
# dprime====
dprime <-
    summarySEwithin(
        longFormData,
        measurevar = "dprime",
        withinvars = "rwd",
        idvar = "subID"
    )

dprime_bar <- ggplot(
    dprime,
    aes(
        y = dprime,
        x = rwd,
        fill = rwd
    )
) +
    geom_bar(
        stat = "identity",
        width = width,
        position = position_dodge(dodgeWidth),
        color = "black"
    ) +
    geom_errorbar(
        aes(
            ymin = dprime - se,
            ymax = dprime + se
        ),
        width = errWidth,
        position = position_dodge(errdodgeWidth),
        colour = "azure4",
        size = 1
    ) +

    coord_cartesian(ylim = c(1.2, 1.6)) +
    # coord_cartesian(ylim = c(1.25, 2.25)) +

    labs(
        y = expression(paste("Discriminability ", italic("d\'"))),
        x = ""
    ) +
    scale_fill_manual(values = c(
        "2" = "red",
        "1" = "green",
        "0" = "black"
    )) +
    scale_x_discrete(labels = c(
        "high" = "High",
        "low" = "Low",
        "none" = "Control"
    )) +
    theme_bw() +
    theme(
        legend.position = "none",
        axis.text = element_text(size = 24),
        axis.title = element_text(size = 32),
        axis.line = element_line(colour = "black"),
        panel.grid.major.x = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank()
    )

# criterion====
criterion <-
    summarySEwithin(
        longFormData,
        measurevar = "criterion",
        withinvars = "rwd",
        idvar = "subID"
    )

criterion_bar <- ggplot(
    criterion,
    aes(
        y = criterion,
        x = interaction(rwd),
        group = rwd,
        fill = rwd
    )
) +
    geom_bar(
        stat = "identity",
        width = width,
        position = position_dodge(dodgeWidth),
        color = "black"
    ) +
     coord_cartesian(ylim = c(-.05, .1)) +

    geom_errorbar(
        aes(
            ymin = criterion - se,
            ymax = criterion + se
        ),
        width = errWidth,
        position = position_dodge(errdodgeWidth),
        colour = "azure4",
        size = 1
    ) +
    labs(
        y = expression(paste("Criterion ", italic("c"))),
        x = ""
    ) +
    scale_fill_manual(values = c(
        "2" = "red",
        "1" = "green",
        "0" = "black"
    )) +
    scale_x_discrete(labels = c(
        "high" = "High",
        "low" = "Low",
        "none" = "Control"
    )) +
    theme_bw() +
    theme(
        legend.position = "none",
        axis.text = element_text(size = 24),
        axis.title = element_text(size = 32),
        axis.line = element_line(colour = "black"),
        panel.grid.major.x = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank()
    )




HR_FA_bar
dprime_bar
criterion_bar


  ggsave(
    criterion_bar,
    filename = "test.png",
    dpi = 300,
    type = "cairo",
    width = 10,
    height = 7.5,
    units = "in"
  )




congruentHigh
incongruentHigh
congruentLow
incongruentLow
control
