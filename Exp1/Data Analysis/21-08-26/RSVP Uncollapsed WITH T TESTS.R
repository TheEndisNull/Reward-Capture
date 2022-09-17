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
  !subject %in% c('eqmlqlfqyt',
                 'vv89j7ugm9',
                 '7ymfqhmnuy',
                 'bcrsgmz11l')
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
    position = position_dodge(width = dodgeWidth)
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
      "High Reward Targets" = "red",
      "Low Reward Targets" = "green",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(
    labels = c(
      "1st.high" = "SP1 High",
      "2nd.high" = "SP2 High",
      "3rd.high" = "SP3 High",
      "1st.low" = "SP1 Low",
      "2nd.low" = "SP2 Low",
      "3rd.low" = "SP3 Low",
      "none.none" = "No SP Color"
    )
  ) +
  
  labs(x = 'Reward Condition',
       y = 'Hit Rate') +
  
  theme(
    legend.position = 'none',
    text = element_text(size = 14),
    plot.title = element_blank()
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
                              CNT2_N, ) %>%
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
    position = position_dodge(width = dodgeWidth)
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
      "High Reward Targets" = "red",
      "Low Reward Targets" = "green",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(
    labels = c(
      "1st.high" = "SP1 High",
      "2nd.high" = "SP2 High",
      "3rd.high" = "SP3 High",
      "1st.low" = "SP1 Low",
      "2nd.low" = "SP2 Low",
      "3rd.low" = "SP3 Low",
      "none.none" = "No SP Color"
    )
  ) +
  
  labs(x = 'Reward Condition',
       y = "Detection Sensitivity (d')") +
  
  theme(
    legend.position = 'none',
    text = element_text(size = 14),
    plot.title = element_blank()
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
    position = position_dodge(width = dodgeWidth)
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
      "High Reward Targets" = "red",
      "Low Reward Targets" = "green",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(
    labels = c(
      "1st.high" = "SP1 High",
      "2nd.high" = "SP2 High",
      "3rd.high" = "SP3 High",
      "1st.low" = "SP1 Low",
      "2nd.low" = "SP2 Low",
      "3rd.low" = "SP3 Low",
      "none.none" = "No SP Color"
    )
  ) +
  
  labs(x = 'Reward Condition',
       y = 'Response Bias (c)') +
  
  theme(
    legend.position = 'none',
    text = element_text(size = 14),
    plot.title = element_blank()
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
    position = position_dodge(width = dodgeWidth)
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
      "High Reward Targets" = "red",
      "Low Reward Targets" = "green",
      "Non-color Targets" = "black"
    )
  ) +
  
  scale_x_discrete(
    labels = c(
      "1st.high" = "SP1 High",
      "2nd.high" = "SP2 High",
      "3rd.high" = "SP3 High",
      "1st.low" = "SP1 Low",
      "2nd.low" = "SP2 Low",
      "3rd.low" = "SP3 Low",
      "none.none" = "No SP Color"
    )
  ) +
  
  labs(x = 'Reward Condition',
       y = 'Response Time (ms)') +
  
  theme(
    legend.position = 'none',
    text = element_text(size = 14),
    plot.title = element_blank()
  )
rt_bar
sdfas

#hypotheses testing====
testData <- bind_rows(
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
  select(subject, rt, dprime, criterion, target, color, reward)
table(testData$target, testData$color, testData$reward)

for (i in 1:3) {
  assign(
    paste0(nameTgt[i], 'Anova'),
    filter(
      testData,
      target == tgtIdx[i],
      color == tgtIdx[i] & reward != 'none' |
        reward == 'none'
    )
  )
}

T1Ttest <- filter(T1Anova, reward != 'none')
T2Ttest <- filter(T2Anova, reward != 'none')
T3Ttest <- filter(T3Anova, reward != 'none')

rt3way <- aov(rt ~ target * color * reward, data = testData)

rtbf <- anovaBF(rt ~ target * reward + subject,
                data = testData,
                whichRandom = 'subject')

rtAov1 <-
  aov(rt ~ reward + Error(subject / reward), data = T1Anova)
rtAov2 <-
  aov(rt ~ reward + Error(subject / reward), data = T2Anova)
rtAov3 <-
  aov(rt ~ reward + Error(subject / reward), data = T3Anova)

rtBF1 <- anovaBF(rt ~ reward + subject,
                 data = as.data.frame(T1Anova),
                 whichRandom = 'subject')
rtBF2 <- anovaBF(rt ~ reward + subject,
                 data = as.data.frame(T2Anova),
                 whichRandom = 'subject')
rtBF3 <- anovaBF(rt ~ reward + subject,
                 data = as.data.frame(T3Anova),
                 whichRandom = 'subject')

t.test(rt ~ reward, data = T1Ttest, paired = T)
ttestBF(x = T1Ttest$rt[1:62],
        y = T1Ttest$rt[63:124],
        paired = T)

summary(rt3way)
summary(rtbf)

summary(rtAov1)
summary(rtAov2)
summary(rtAov3)

summary(rtBF1)
summary(rtBF2)
summary(rtBF3)




#====
t.test(T1Anova$rt[1:62],
       T1Anova$rt[63:124],
       data = T1Anova, paired = T)
ttestBF(x = T1Anova$rt[1:62],
        y = T1Anova$rt[63:124],
        paired = T)


t.test(T1Anova$rt[1:62],
       T1Anova$rt[125:186],
       data = T1Anova, paired = T)
ttestBF(x = T1Anova$rt[1:62],
        y = T1Anova$rt[125:186],
        paired = T)
#====
t.test(T2Anova$rt[1:62],
       T2Anova$rt[63:124],
       data = T2Anova, paired = T)
ttestBF(x = T2Anova$rt[1:62],
        y = T2Anova$rt[63:124],
        paired = T)


t.test(T2Anova$rt[1:62],
       T2Anova$rt[125:186],
       data = T2Anova, paired = T)
ttestBF(x = T2Anova$rt[1:62],
        y = T2Anova$rt[125:186],
        paired = T)
#====
t.test(T3Anova$rt[1:62],
       T3Anova$rt[63:124],
       data = T3Anova, paired = T)
ttestBF(x = T3Anova$rt[1:62],
        y = T3Anova$rt[63:124],
        paired = T)


t.test(T3Anova$rt[1:62],
       T3Anova$rt[125:186],
       data = T3Anova, paired = T)
ttestBF(x = T3Anova$rt[1:62],
        y = T3Anova$rt[125:186],
        paired = T)





#dprime====
interaction.plot(testData$target,
                 testData$reward,
                 testData$dprime)
dprime3way <-
  aov(dprime ~ target * color * reward + Error(subject), data = testData)

dprimebf <- anovaBF(dprime ~ target * reward * color + subject,
                    data = testData,
                    whichRandom = 'subject')

dprimeAov1 <-
  aov(dprime ~ reward + Error(subject / reward), data = T1Anova)
dprimeAov2 <-
  aov(dprime ~ reward + Error(subject / reward), data = T2Anova)
dprimeAov3 <-
  aov(dprime ~ reward + Error(subject / reward), data = T3Anova)

dprimeBF1 <- anovaBF(dprime ~ reward + subject,
                     data = as.data.frame(T1Anova),
                     whichRandom = 'subject')
dprimeBF2 <- anovaBF(dprime ~ reward + subject,
                     data = as.data.frame(T2Anova),
                     whichRandom = 'subject')
dprimeBF3 <- anovaBF(dprime ~ reward + subject,
                     data = as.data.frame(T3Anova),
                     whichRandom = 'subject')

t.test(dprime ~ reward, data = T1Ttest, paired = T)
ttestBF(x = T1Ttest$dprime[1:62],
        y = T1Ttest$dprime[63:124],
        paired = T)

summary(dprime3way)
summary(dprimebf)

summary(dprimeAov1)
summary(dprimeAov2)
summary(dprimeAov3)

summary(dprimeBF1)
summary(dprimeBF2)
summary(dprimeBF3)



#====
t.test(T1Anova$dprime[1:62],
       T1Anova$dprime[63:124],
       data = T1Anova,
       paired = T)
ttestBF(x = T1Anova$dprime[1:62],
        y = T1Anova$dprime[63:124],
        paired = T)


t.test(T1Anova$dprime[1:62],
       T1Anova$dprime[125:186],
       data = T1Anova,
       paired = T)
ttestBF(x = T1Anova$dprime[1:62],
        y = T1Anova$dprime[125:186],
        paired = T)
#====
t.test(T2Anova$dprime[1:62],
       T2Anova$dprime[63:124],
       data = T2Anova,
       paired = T)
ttestBF(x = T2Anova$dprime[1:62],
        y = T2Anova$dprime[63:124],
        paired = T)


t.test(T2Anova$dprime[1:62],
       T2Anova$dprime[125:186],
       data = T2Anova,
       paired = T)
ttestBF(x = T2Anova$dprime[1:62],
        y = T2Anova$dprime[125:186],
        paired = T)
#====
t.test(T3Anova$dprime[1:62],
       T3Anova$dprime[63:124],
       data = T3Anova,
       paired = T)
ttestBF(x = T3Anova$dprime[1:62],
        y = T3Anova$dprime[63:124],
        paired = T)


t.test(T3Anova$dprime[1:62],
       T3Anova$dprime[125:186],
       data = T3Anova,
       paired = T)
ttestBF(x = T3Anova$dprime[1:62],
        y = T3Anova$dprime[125:186],
        paired = T)



#criterion====
interaction.plot(testData$target,
                 testData$reward,
                 testData$criterion)
criterion3way <-
  aov(criterion ~ target * color * reward, data = testData)

criterionbf <- anovaBF(criterion ~ target * reward + subject,
                       data = testData,
                       whichRandom = 'subject')

criterionAov1 <-
  aov(criterion ~ reward + Error(subject / reward), data = T1Anova)
criterionAov2 <-
  aov(criterion ~ reward + Error(subject / reward), data = T2Anova)
criterionAov3 <-
  aov(criterion ~ reward + Error(subject / reward), data = T3Anova)

criterionBF1 <- anovaBF(criterion ~ reward + subject,
                        data = as.data.frame(T1Anova),
                        whichRandom = 'subject')
criterionBF2 <- anovaBF(criterion ~ reward + subject,
                        data = as.data.frame(T2Anova),
                        whichRandom = 'subject')
criterionBF3 <- anovaBF(criterion ~ reward + subject,
                        data = as.data.frame(T3Anova),
                        whichRandom = 'subject')

summary(criterion3way)
summary(criterionbf)

summary(criterionAov1)
summary(criterionAov2)
summary(criterionAov3)

summary(criterionBF1)
summary(criterionBF2)
summary(criterionBF3)

#====
t.test(T1Anova$criterion[1:62],
       T1Anova$criterion[63:124],
       data = T1Anova,
       paired = T)
ttestBF(x = T1Anova$criterion[1:62],
        y = T1Anova$criterion[63:124],
        paired = T)


t.test(T1Anova$criterion[1:62],
       T1Anova$criterion[125:186],
       data = T1Anova,
       paired = T)
ttestBF(x = T1Anova$criterion[1:62],
        y = T1Anova$criterion[125:186],
        paired = T)
#====
t.test(T2Anova$criterion[1:62],
       T2Anova$criterion[63:124],
       data = T2Anova,
       paired = T)
ttestBF(x = T2Anova$criterion[1:62],
        y = T2Anova$criterion[63:124],
        paired = T)


t.test(T2Anova$criterion[1:62],
       T2Anova$criterion[125:186],
       data = T2Anova,
       paired = T)
ttestBF(x = T2Anova$criterion[1:62],
        y = T2Anova$criterion[125:186],
        paired = T)
#====
t.test(T3Anova$criterion[1:62],
       T3Anova$criterion[63:124],
       data = T3Anova,
       paired = T)
ttestBF(x = T3Anova$criterion[1:62],
        y = T3Anova$criterion[63:124],
        paired = T)


t.test(T3Anova$criterion[1:62],
       T3Anova$criterion[125:186],
       data = T3Anova,
       paired = T)
ttestBF(x = T3Anova$criterion[1:62],
        y = T3Anova$criterion[125:186],
        paired = T)


t.test(criterion ~ reward, data = T2Ttest, paired = T)
ttestBF(x = T2Ttest$criterion[1:62],
        y = T2Ttest$criterion[63:124],
        paired = T)

t.test(criterion ~ reward, data = T3Ttest, paired = T)
ttestBF(x = T3Ttest$criterion[1:62],
        y = T3Ttest$criterion[63:124],
        paired = T)


















t.test(T1Anova$criterion[1:62],
       T1Anova$criterion[63:124],
       data = T1Anova,
       paired = T)
ttestBF(x = T1Anova$criterion[1:62],
        y = T1Anova$criterion[63:124],
        paired = T)


t.test(T1Anova$criterion[63:124],
       T1Anova$criterion[125:186],
       data = T1Anova,
       paired = T)
ttestBF(x = T1Anova$criterion[1:62],
        y = T1Anova$criterion[125:186],
        paired = T)
#====
t.test(T2Anova$criterion[1:62],
       T2Anova$criterion[63:124],
       data = T2Anova,
       paired = T)
ttestBF(x = T2Anova$criterion[1:62],
        y = T2Anova$criterion[63:124],
        paired = T)


t.test(T2Anova$criterion[63:124],
       T2Anova$criterion[125:186],
       data = T2Anova,
       paired = T)
ttestBF(x = T2Anova$criterion[1:62],
        y = T2Anova$criterion[125:186],
        paired = T)
#====
t.test(T3Anova$criterion[1:62],
       T3Anova$criterion[63:124],
       data = T3Anova,
       paired = T)
ttestBF(x = T3Anova$criterion[1:62],
        y = T3Anova$criterion[63:124],
        paired = T)


t.test(T3Anova$criterion[63:124],
       T3Anova$criterion[125:186],
       data = T3Anova,
       paired = T)
ttestBF(x = T3Anova$criterion[1:62],
        y = T3Anova$criterion[125:186],
        paired = T)


t.test(criterion ~ reward, data = T2Ttest, paired = T)
ttestBF(x = T2Ttest$criterion[1:62],
        y = T2Ttest$criterion[63:124],
        paired = T)

t.test(criterion ~ reward, data = T3Ttest, paired = T)
ttestBF(x = T3Ttest$criterion[1:62],
        y = T3Ttest$criterion[63:124],
        paired = T)

#====





#non-colored targets in colored lists
for (i in 1:2) {
  assign(
    paste0(nameTgt[3], colIdx[i]),
    filter(
      testData,
      target == tgtIdx[3],
      color == tgtIdx[i] & reward != 'none' |
        reward == 'none'
    )
  )
}


C1T3 <-
  aov(dprime ~ reward + Error(subject / reward), data = T31st)
C2T3 <-
  aov(dprime ~ reward + Error(subject / reward), data = T32nd)
summary(C1T3)
summary(C2T3)

C1T3 <-
  aov(criterion ~ reward + Error(subject / reward), data = T31st)
C2T3 <-
  aov(criterion ~ reward + Error(subject / reward), data = T32nd)
summary(C1T3)
summary(C2T3)

C1T3 <- aov(rt ~ reward + Error(subject / reward), data = T31st)
C2T3 <- aov(rt ~ reward + Error(subject / reward), data = T32nd)
summary(C1T3)
summary(C2T3)

#====1st and 3rd
#==== dprime
t.test(T31st$dprime[1:62],
       T31st$dprime[63:124],
       data = T31st,
       paired = T)
ttestBF(x = T31st$dprime[1:62],
        y = T31st$dprime[63:124],
        paired = T)


t.test(T31st$dprime[1:62],
       T31st$dprime[125:186],
       data = T31st,
       paired = T)
ttestBF(x = T31st$dprime[1:62],
        y = T31st$dprime[125:186],
        paired = T)

#==== criterion
t.test(T31st$criterion[1:62],
       T31st$criterion[63:124],
       data = T31st,
       paired = T)
ttestBF(x = T31st$criterion[1:62],
        y = T31st$criterion[63:124],
        paired = T)


t.test(T31st$criterion[1:62],
       T31st$criterion[125:186],
       data = T31st,
       paired = T)
ttestBF(x = T31st$criterion[1:62],
        y = T31st$criterion[125:186],
        paired = T)


#==== response time
t.test(T31st$rt[1:62],
       T31st$rt[63:124],
       data = T31st, paired = T)
ttestBF(x = T31st$rt[1:62],
        y = T31st$rt[63:124],
        paired = T)


t.test(T31st$rt[1:62],
       T31st$rt[125:186],
       data = T31st, paired = T)
ttestBF(x = T31st$rt[1:62],
        y = T31st$rt[125:186],
        paired = T)


#==== 2nd and 3rd
#==== dprime
t.test(T32nd$dprime[1:62],
       T32nd$dprime[63:124],
       data = T32nd,
       paired = T)
ttestBF(x = T32nd$dprime[1:62],
        y = T32nd$dprime[63:124],
        paired = T)


t.test(T32nd$dprime[1:62],
       T32nd$dprime[125:186],
       data = T32nd,
       paired = T)
ttestBF(x = T32nd$dprime[1:62],
        y = T32nd$dprime[125:186],
        paired = T)

#==== criterion
t.test(T32nd$criterion[1:62],
       T32nd$criterion[63:124],
       data = T32nd,
       paired = T)
ttestBF(x = T32nd$criterion[1:62],
        y = T32nd$criterion[63:124],
        paired = T)


t.test(T32nd$criterion[1:62],
       T32nd$criterion[125:186],
       data = T32nd,
       paired = T)
ttestBF(x = T32nd$criterion[1:62],
        y = T32nd$criterion[125:186],
        paired = T)


#==== criterion
t.test(T32nd$rt[1:62],
       T32nd$rt[63:124],
       data = T32nd, paired = T)
ttestBF(x = T32nd$rt[1:62],
        y = T32nd$rt[63:124],
        paired = T)


t.test(T32nd$rt[1:62],
       T32nd$rt[125:186],
       data = T32nd, paired = T)
ttestBF(x = T32nd$rt[1:62],
        y = T32nd$rt[125:186],
        paired = T)

