#uncollapsed dprime by target and color positions

#setup====
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
lapply(c("tidyverse", "patchwork", "BayesFactor"),
       require,
       character.only = T)

data <- read_csv(
  "data_4_27.csv",
  col_types = cols(
    rt = col_double(),
    color = col_skip(),
    tgtPosition = col_character(),
    rewardType = col_character(),
    reward = col_skip(),
    colorPosition = col_character(),
    correct = col_factor(levels = c("FALSE", "TRUE", "null"))
  )
)
data <- tibble::as_tibble(data)
data <- filter(
  data,
  trialType == "RSVPtest",
  rt > quantile(data$rt, 0.025, na.rm = TRUE),
  subject != 'eqmlqlfqyt' &
    subject != 'vv89j7ugm9' &
    subject != '7ymfqhmnuy' &
    subject != 'bcrsgmz11l'
) %>%
  select(subject, rt, correct, rewardType, tgtPosition, colorPosition)
data$subject <- as.factor(data$subject)
#levels(data$subject) <- 0:length(levels(data$subject))


nameRwd = c('_H', '_L', '_N')
nameCol = c('C1', 'C2', 'C3', 'CN')
nameTgt = c('T1', 'T2', 'T3')
colIdx = c('1st', '2nd', '3rd', 'none')
tgtIdx = c('1st', '2nd', '3rd')
rwdIdx = c('high', 'low', 'none')

for (k in 1:3) {
  for (j in 1:3) {
    for (i in 1:2) {
      assign(
        paste0(nameCol[j], nameTgt[k], nameRwd[i]),
        bind_cols(
          filter(
            data,
            rewardType == rwdIdx[i],
            tgtPosition == tgtIdx[k],
            colorPosition == colIdx[j],
            correct == 'TRUE'
          ) %>%
            group_by(subject, .drop = F) %>%
            summarize(Hits = n(),
                      rt = median(rt)) %>%
            select(subject, rt, Hits),
          filter(
            data,
            rewardType == rwdIdx[i],
            tgtPosition == tgtIdx[k],
            colorPosition == colIdx[j],
            correct == 'FALSE'
          ) %>%
            group_by(subject, .drop = F) %>%
            summarize(Misses = n()) %>%
            select(Misses),
          filter(
            data,
            rewardType == rwdIdx[i],
            tgtPosition == 'new',
            colorPosition == colIdx[j],
            correct == 'FALSE'
          ) %>%
            group_by(subject, .drop = F) %>%
            summarize(False_Alarms = n()) %>%
            select(False_Alarms),
          filter(
            data,
            rewardType == rwdIdx[i],
            tgtPosition == 'new',
            colorPosition == colIdx[j],
            correct == 'TRUE'
          ) %>%
            group_by(subject, .drop = F) %>%
            summarize(Rejections = n()) %>%
            select(Rejections)
        ) %>%
          mutate(
            H_Sum = Hits + Misses,
            Hit_Rate = Hits / H_Sum,
            Corrected_HR = ifelse(
              Hit_Rate == 1,
              (Hits - 0.5) / H_Sum,
              ifelse(Hit_Rate == 0, (Hits + 0.5) / H_Sum, Hit_Rate)
            ),
            F_Sum = False_Alarms + Rejections,
            False_Alarm_Rate = False_Alarms / F_Sum,
            Corrected_FA = ifelse(
              False_Alarm_Rate == 1,
              (False_Alarms - 0.5) / F_Sum,
              ifelse(
                False_Alarm_Rate == 0,
                (False_Alarms + 0.5) / F_Sum,
                False_Alarm_Rate
              )
            ),
            dprime = qnorm(Corrected_HR) - qnorm(Corrected_FA),
            criterion = -(qnorm(Corrected_HR) + qnorm(Corrected_FA)) / 2,
            target = as.factor(c(replicate(n(
              
            ), tgtIdx[k]))),
            color = as.factor(c(replicate(n(
              
            ), colIdx[j]))),
            reward = as.factor(c(replicate(n(
              
            ), rwdIdx[i]))),
          ) %>%
          rename(HR = Corrected_HR,
                 FA = Corrected_FA) %>%
          filter(Hits != 0) %>%
          select(
            subject,
            rt,
            dprime,
            criterion,
            HR,
            FA,
            target,
            color,
            reward
          )
      )
    }
  }
  assign(
    paste0(nameCol[4], nameTgt[k], nameRwd[3]),
    bind_cols(
      filter(
        data,
        rewardType == rwdIdx[3],
        tgtPosition == tgtIdx[k],
        correct == 'TRUE'
      ) %>%
        group_by(subject, .drop = F) %>%
        summarize(Hits = n(),
                  rt = median(rt)) %>%
        select(subject, rt, Hits),
      filter(
        data,
        rewardType == rwdIdx[3],
        tgtPosition == tgtIdx[k],
        correct == 'FALSE'
      ) %>%
        group_by(subject, .drop = F) %>%
        summarize(Misses = n()) %>%
        select(Misses),
      filter(
        data,
        rewardType == rwdIdx[3],
        tgtPosition == 'new',
        correct == 'FALSE'
      ) %>%
        group_by(subject, .drop = F) %>%
        summarize(False_Alarms = n()) %>%
        select(False_Alarms),
      filter(
        data,
        rewardType == rwdIdx[3],
        tgtPosition == 'new',
        correct == 'TRUE'
      ) %>%
        group_by(subject, .drop = F) %>%
        summarize(Rejections = n()) %>%
        select(Rejections)
    ) %>%
      mutate(
        H_Sum = Hits + Misses,
        Hit_Rate = Hits / H_Sum,
        Corrected_HR = ifelse(
          Hit_Rate == 1,
          (Hits - 0.5) / H_Sum,
          ifelse(Hit_Rate == 0, (Hits + 0.5) / H_Sum, Hit_Rate)
        ),
        F_Sum = False_Alarms + Rejections,
        False_Alarm_Rate = False_Alarms / F_Sum,
        Corrected_FA = ifelse(
          False_Alarm_Rate == 1,
          (False_Alarms - 0.5) / F_Sum,
          ifelse(
            False_Alarm_Rate == 0,
            (False_Alarms + 0.5) / F_Sum,
            False_Alarm_Rate
          )
        ),
        dprime = qnorm(Corrected_HR) - qnorm(Corrected_FA),
        criterion = -(qnorm(Corrected_HR) + qnorm(Corrected_FA)) / 2,
        target = as.factor(c(replicate(n(
          
        ), tgtIdx[k]))),
        color = as.factor(c(replicate(n(
          
        ), colIdx[4]))),
        reward = as.factor(c(replicate(n(
          
        ), rwdIdx[3]))),
      ) %>%
      rename(HR = Corrected_HR,
             FA = Corrected_FA) %>%
      select(subject, rt, dprime, criterion, HR, FA, target, color, reward)
  )
}

#Hit Rate====
hit_rate <- bind_rows(
  C1T1_H,
  C1T2_H,
  C1T3_H,
  C2T1_H,
  C2T2_H,
  C2T3_H,
  C3T1_H,
  C3T2_H,
  C3T3_H,
  C1T1_L,
  C1T2_L,
  C1T3_L,
  C2T1_L,
  C2T2_L,
  C2T3_L,
  C3T1_L,
  C3T2_L,
  C3T3_L,
  CNT1_N,
  CNT2_N,
  CNT3_N
) %>%
  group_by(reward, color, target) %>%
  summarise(
    count = n(),
    mean = mean(HR , na.rm = TRUE),
    se = sd(HR , na.rm = TRUE) / sqrt(n())
  ) %>%
  print(n = 21)

width = .8
dodgeWidth = .85
errWidth = .4
errdodgeWidth = .85

hit_rate_bar <- ggplot(hit_rate,
                       aes(
                         y = mean,
                         x = interaction(color, reward),
                         group = target,
                         fill = factor(
                           ifelse(
                             color == as.character(target) & reward == "high",
                             "High Reward Targets",
                             ifelse(
                               color == as.character(target) & reward == "low",
                               "Low Reward Targets",
                               "Non-color Targets"
                             )
                           )
                         )
                       )) +
  
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(width = dodgeWidth),
    color = 'black'
  ) +
  
  facet_grid(
    ~ reward,
    scales = "free_x",
    space = "free_x",
    switch = "x",
    labeller = as_labeller(
      c(high = "High Reward Color",
        low = "Low Reward Color",
        none = "Control")
    )
  ) +
  geom_errorbar(
    aes(ymin = mean - se,
        ymax = mean + se),
    width = errWidth,
    position = position_dodge(width = errdodgeWidth),
    colour = "azure4"
  ) +
  
  coord_cartesian(ylim = c(.6, .9)) +
  
  scale_fill_manual(
    values = c(
      "High Reward Targets" = "White",
      "Low Reward Targets" = "grey",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(labels = c(
    "1st.high" = "SP1 High",
    "2nd.high" = "SP2 High",
    "3rd.high" = "SP3 High",
    "1st.low" = "SP1 Low",
    "2nd.low" = "SP2 Low",
    "3rd.low" = "SP3 Low",
    "none.none" = "No SP Color"
  )) +
  
  labs(x = 'Reward Condition',
       y = 'Hit Rate',
       tag = 'A') +
  
  theme_classic() +
  theme(
    legend.position = 'none',
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5)
  )

hit_rate_bar

#False Alarm====
#T position can be anything, they all use same FA according to color Pos
false_alarm_rate <- bind_rows(C1T2_H,
                              C2T2_H,
                              C3T2_H,
                              C1T2_L,
                              C2T2_L,
                              C3T2_L,
                              CNT2_N,) %>%
  group_by(reward, color) %>%
  summarise(
    count = n(),
    mean = mean(FA , na.rm = TRUE),
    se = sd(FA , na.rm = TRUE) / sqrt(n())
  ) %>%
  print(n = 21)

false_alarm_bar <- ggplot(false_alarm_rate, aes(y = mean,
                                                x = interaction(color, reward),
                                                grou)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
                position = position_dodge(),
                colour = "orange") +
  coord_cartesian(ylim = c(.17, .27)) +
  labs(fill = "Target Position",
       x = "Color Position X Reward Type",
       y = "False Alarm Rate",
       title = "False Alarm Rate by Color Position") +
  theme(legend.position = "bottom")
false_alarm_bar

#dprime====
dprime <- bind_rows(
  C1T1_H,
  C1T2_H,
  C1T3_H,
  C2T1_H,
  C2T2_H,
  C2T3_H,
  C3T1_H,
  C3T2_H,
  C3T3_H,
  C1T1_L,
  C1T2_L,
  C1T3_L,
  C2T1_L,
  C2T2_L,
  C2T3_L,
  C3T1_L,
  C3T2_L,
  C3T3_L,
  CNT1_N,
  CNT2_N,
  CNT3_N
) %>%
  group_by(reward, color, target) %>%
  summarise(
    count = n(),
    mean = mean(dprime , na.rm = TRUE),
    se = sd(dprime , na.rm = TRUE) / sqrt(n())
  ) %>%
  print(n = 21)

dprime_bar <- ggplot(dprime,
                     aes(
                       y = mean,
                       x = interaction(color, reward),
                       group = target,
                       fill = factor(
                         ifelse(
                           color == as.character(target) & reward == "high",
                           "High Reward Targets",
                           ifelse(
                             color == as.character(target) & reward == "low",
                             "Low Reward Targets",
                             "Non-color Targets"
                           )
                         )
                       )
                     )) +
  
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(width = dodgeWidth),
    color = 'black'
  ) +
  
  facet_grid(
    ~ reward,
    scales = "free_x",
    space = "free_x",
    switch = "x",
    labeller = as_labeller(
      c(high = "High Reward Color",
        low = "Low Reward Color",
        none = "No Reward Color")
    )
  ) +
  geom_errorbar(
    aes(ymin = mean - se,
        ymax = mean + se),
    width = errWidth,
    position = position_dodge(width = errdodgeWidth),
    colour = "azure4"
  ) +
  
  coord_cartesian(ylim = c(1.25, 2.25)) +
  
  scale_fill_manual(
    values = c(
      "High Reward Targets" = "White",
      "Low Reward Targets" = "grey",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(labels = c(
    "1st.high" = "SP1 High",
    "2nd.high" = "SP2 High",
    "3rd.high" = "SP3 High",
    "1st.low" = "SP1 Low",
    "2nd.low" = "SP2 Low",
    "3rd.low" = "SP3 Low",
    "none.none" = "No SP Color"
  )) +
  
  labs(x = 'Reward Condition',
       y = "Detection Sensitivity (d')",
       tag = 'B') +
  
  theme_classic() +
  theme(
    legend.position = 'none',
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5)
  )
dprime_bar

#criterion====
criterion <- bind_rows(
  C1T1_H,
  C1T2_H,
  C1T3_H,
  C2T1_H,
  C2T2_H,
  C2T3_H,
  C3T1_H,
  C3T2_H,
  C3T3_H,
  C1T1_L,
  C1T2_L,
  C1T3_L,
  C2T1_L,
  C2T2_L,
  C2T3_L,
  C3T1_L,
  C3T2_L,
  C3T3_L,
  CNT1_N,
  CNT2_N,
  CNT3_N
) %>%
  group_by(reward, color, target) %>%
  summarise(
    count = n(),
    mean = mean(criterion , na.rm = TRUE),
    se = sd(criterion , na.rm = TRUE) / sqrt(n())
  ) %>%
  print(n = 21)

criterion_bar <- ggplot(criterion,
                        aes(
                          y = mean,
                          x = interaction(color, reward),
                          group = target,
                          fill = factor(
                            ifelse(
                              color == as.character(target) & reward == "high",
                              "High Reward Targets",
                              ifelse(
                                color == as.character(target) & reward == "low",
                                "Low Reward Targets",
                                "Non-color Targets"
                              )
                            )
                          )
                        )) +
  
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(width = dodgeWidth),
    color = 'black'
  ) +
  
  facet_grid(
    ~ reward,
    scales = "free_x",
    space = "free_x",
    switch = "x",
    labeller = as_labeller(
      c(high = "High Reward Color",
        low = "Low Reward Color",
        none = "No Reward Color")
    )
  ) +
  geom_errorbar(
    aes(ymin = mean - se,
        ymax = mean + se),
    width = errWidth,
    position = position_dodge(width = errdodgeWidth),
    colour = "azure4"
  ) +
  
  #coord_cartesian(ylim = c(.6, .9)) +
  
  scale_fill_manual(
    values = c(
      "High Reward Targets" = "White",
      "Low Reward Targets" = "grey",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(labels = c(
    "1st.high" = "SP1 High",
    "2nd.high" = "SP2 High",
    "3rd.high" = "SP3 High",
    "1st.low" = "SP1 Low",
    "2nd.low" = "SP2 Low",
    "3rd.low" = "SP3 Low",
    "none.none" = "No SP Color"
  )) +
  
  labs(x = 'Reward Condition',
       y = 'Response Bias (c)',
       tag = 'C') +
  
  theme_classic() +
  theme(
    legend.position = 'none',
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5)
  )
criterion_bar

#reponse time====
rt_color <- bind_rows(
  C1T1_H,
  C1T2_H,
  C1T3_H,
  C2T1_H,
  C2T2_H,
  C2T3_H,
  C3T1_H,
  C3T2_H,
  C3T3_H,
  C1T1_L,
  C1T2_L,
  C1T3_L,
  C2T1_L,
  C2T2_L,
  C2T3_L,
  C3T1_L,
  C3T2_L,
  C3T3_L,
  CNT1_N,
  CNT2_N,
  CNT3_N
) %>%
  mutate(reward = as.factor(reward)) %>%
  mutate(target = as.factor(target)) %>%
  mutate(color = as.factor(color)) %>%
  select(rt, reward, target, color) %>%
  print() %>%
  group_by(reward, target, color) %>%
  summarise(
    counts = n(),
    mean = mean(rt, na.rm = TRUE),
    se = sd(rt, na.rm = TRUE) / sqrt(n())
  ) %>%
  filter(!is.nan(mean)) %>%
  print(n = 21)

rt_bar <- ggplot(rt_color,
                 aes(
                   y = mean,
                   x = interaction(color, reward),
                   #####edidted rt_color$color
                   group = target,
                   fill = factor(
                     ifelse(
                       color == as.character(target) & reward == "high",
                       "High Reward Targets",
                       ifelse(
                         color == as.character(target) & reward == "low",
                         "Low Reward Targets",
                         "Non-color Targets"
                       )
                     )
                   )
                 )) +
  
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(width = dodgeWidth),
    color = 'black'
  ) +
  
  facet_grid(
    ~ reward,
    scales = "free_x",
    space = "free_x",
    switch = "x",
    labeller = as_labeller(
      c(high = "High Reward Color",
        low = "Low Reward Color",
        none = "No Reward Color")
    )
  ) +
  
  geom_errorbar(
    aes(ymin = mean - se,
        ymax = mean + se),
    width = errWidth,
    position = position_dodge(width = errdodgeWidth),
    colour = "azure4"
  ) +
  
  coord_cartesian(ylim = c(600, 900)) +
  
  scale_fill_manual(
    values = c(
      "High Reward Targets" = "White",
      "Low Reward Targets" = "grey",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(labels = c(
    "1st.high" = "SP1 High",
    "2nd.high" = "SP2 High",
    "3rd.high" = "SP3 High",
    "1st.low" = "SP1 Low",
    "2nd.low" = "SP2 Low",
    "3rd.low" = "SP3 Low",
    "none.none" = "No SP Color"
  )) +
  
  labs(x = 'Reward Condition',
       y = 'Response Time (ms)',
       tag = 'D') +
  
  theme_classic() +
  theme(
    legend.position = 'none',
    text = element_text(
      family = "serif",
      color = 'black',
      size = 14
    ),
    plot.title = element_text(size = 14,
                              hjust = 0.5)
  )
rt_bar

hit_rate_bar / dprime_bar / criterion_bar / rt_bar
