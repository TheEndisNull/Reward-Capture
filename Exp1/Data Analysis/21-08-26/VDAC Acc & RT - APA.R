#Plot accuracy and response time of RSVP Task
#setup====
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
lapply(c("tidyverse", "patchwork", 'BayesFactor'),
       require,
       character.only = T)

data <- read_csv(
  "data_4_27.csv",
  col_types = cols(
    rt = col_double(),
    color = col_skip(),
    tgtPosition = col_character(),
    rewardType = col_factor(levels = c('low',
                                       'high')),
    reward = col_skip(),
    colorPosition = col_character(),
    correct = col_factor(levels = c("FALSE",
                                    "TRUE", "null"))
  )
)
data <- tibble::as_tibble(data)
data <- filter(
  data,
  trialType == "VDACtest",
  rt > quantile(data$rt, 0.025, na.rm = TRUE),
  subject != 'eqmlqlfqyt' &
    subject != 'vv89j7ugm9' &
    subject != '7ymfqhmnuy' &
    subject != 'bcrsgmz11l'
) %>%
  select(subject, rt, correct, rewardType, trial_index)
data$subject <- as.factor(data$subject)

print(data)

trialLo = c(0  , 204, 360, 516, 0)
trialHi = c(204, 360, 516, 676, 676)
for (j in list('high', 'low')) {
  for (i in 1:5) {
    assign(
      paste0(j, i),
      bind_cols(
        filter(
          data,
          rewardType == j,
          trial_index < trialHi[i] & trial_index > trialLo[i],
          correct == "TRUE"
        ) %>%
          group_by(subject, .drop = F) %>%
          summarize(correct_response = n(),
                    rt = median(rt)),
        filter(
          data,
          rewardType == j,
          trial_index < trialHi[i] & trial_index > trialLo[i],
        ) %>%
          group_by(subject, .drop = F) %>%
          summarize(total = n()) %>%
          select(total) %>%
          mutate(
            reward = as.factor(replicate(n = n(), j)),
            blk = as.factor(replicate(n = n(), i))
          )
      ) %>%
        mutate(accuracy = correct_response / total)
    )
  }
}
df <- bind_rows(high1, high2, high3, high4, high5,
                low1, low2, low3, low4, low5) %>%
  group_by(reward, blk) %>%
  summarise(
    accMean = mean(accuracy),
    accSE = sd(accuracy, na.rm = T) / sqrt(n()),
    rtMean = mean(rt),
    rtSE = sd(rt, na.rm = T) / sqrt(n()),
  ) %>%
  print()

byTrial <- tibble(
  reward = factor(x = c(
    replicate('High', n = 4),
    replicate('Low', n = 4)
  )),
  acc = df$accMean[c(1:4, 6:9)],
  accSE = df$accSE[c(1:4, 6:9)],
  rt = df$rtMean[c(1:4, 6:9)],
  rtSE = df$rtSE[c(1:4, 6:9)],
  trialNum = c(replicate(n = 2, c(50, 100, 150, 200))),
  
)

byTotal <- tibble(
  reward = factor(x = c('High', 'Low')),
  acc = df$accMean[c(5, 10)],
  accSE = df$accSE[c(5, 10)],
  rt = df$rtMean[c(5, 10)],
  rtSE = df$rtSE[c(5, 10)],
)


#graphs====
rtByTrial <-
  ggplot(byTrial,
         aes(y = rt,
             x = trialNum,
             color = reward)) +
  
  geom_line() +
  
  geom_point(size = 3) +
  
  geom_errorbar(aes(ymin = rt - rtSE,
                    ymax = rt + rtSE),
                width = 10) +
  
  coord_cartesian(ylim = c(600, 700)) +
  
  labs(y = 'Response Time (ms)',
       x = 'Trial Number',
       tag = 'A') +
  
  scale_color_manual(
    values = c('High' = "black",
               'Low' = "grey"
               ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_classic() +
  
  theme(
    legend.position = c(.8, .8),
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5),
  )

rtByTotal <- ggplot(byTotal,
                    aes(y = rt,
                        x = reward,
                        fill = reward)) +
  geom_bar(stat = "identity",
           width = .5,
           color = 'black') +
  
  geom_errorbar(aes(ymin = rt - rtSE,
                    ymax = rt + rtSE),
                width = .4,
                color = 'azure4') +
  
  coord_cartesian(ylim = c(600, 700)) +
  
  labs(y = 'Response Time (ms)',
       x = 'Reward Condition',
       tag = 'B') +
  
  scale_fill_manual(
    values = c('High' = "black",
               'Low' = "grey"
               ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_classic() +
  
  theme(
    legend.position = c(.8, .8),
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5),
  )


(rtByTrial + rtByTotal)

accByTrial <- ggplot(byTrial,
                     aes(y = acc,
                         x = trialNum,
                         color = reward)) +
  
  geom_line() +
  
  geom_point(size = 3) +
  
  geom_errorbar(aes(ymin = acc - accSE,
                    ymax = acc + accSE),
                width = 10) +
  
  coord_cartesian(ylim = c(.7, 1)) +
  
  
  labs(y = 'Accuracy (Proportion Correct)',
       x = 'Trial Number',
       tag = 'C') +
  
  scale_color_manual(
    values = c('High' = "black",
               'Low' = "grey"
    ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_classic() +
  
  theme(
    legend.position = c(.8, .3),
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5),
  )

accByTotal <- ggplot(byTotal,
                     aes(y = acc,
                         x = reward,
                         fill = reward)) +
  geom_bar(stat = "identity",
           width = .5,
           color = 'black') +
  
  geom_errorbar(aes(ymin = acc - accSE,
                    ymax = acc + accSE),
                width = .4,
                color = 'azure4') +
  
  coord_cartesian(ylim = c(.7, 1)) +
  
  labs(y = 'Accuracy (Proportion Correct)',
       x = 'Reward Condition',
       tag = 'D') +
  
  scale_fill_manual(
    values = c('High' = "black",
               'Low' = "grey"
    ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_classic() +
  
  theme(
    legend.position = c(.8, .9),
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5),
  )

(rtByTrial + rtByTotal) / (accByTrial + accByTotal)
