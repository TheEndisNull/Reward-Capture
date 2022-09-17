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
    subject != 'bcrsgmz11l' &
    subject != 'v0w2d2rbra'
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


C1T1_H_diff <- bind_cols(C1T1_H, CNT1_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C1T2_H_diff <- bind_cols(C1T2_H, CNT2_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C1T3_H_diff <- bind_cols(C1T3_H, CNT3_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)
#########################################
C2T1_H_diff <- bind_cols(C2T1_H, CNT1_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C2T2_H_diff <- bind_cols(C2T2_H, CNT2_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C2T3_H_diff <- bind_cols(C2T3_H, CNT3_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)
#########################################
C3T1_H_diff <- bind_cols(C3T1_H, CNT1_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C3T2_H_diff <- bind_cols(C3T2_H, CNT2_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C3T3_H_diff <- bind_cols(C3T3_H, CNT3_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)
#########################################
#########################################
C1T1_L_diff <- bind_cols(C1T1_L, CNT1_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C1T2_L_diff <- bind_cols(C1T2_L, CNT2_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C1T3_L_diff <- bind_cols(C1T3_L, CNT3_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)
#########################################
C2T1_L_diff <- bind_cols(C2T1_L, CNT1_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C2T2_L_diff <- bind_cols(C2T2_L, CNT2_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C2T3_L_diff <- bind_cols(C2T3_L, CNT3_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)
#########################################
C3T1_L_diff <- bind_cols(C3T1_L, CNT1_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C3T2_L_diff <- bind_cols(C3T2_L, CNT2_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)

C3T3_L_diff <- bind_cols(C3T3_L, CNT3_N) %>%
  rename(
    subject = subject...1,
    target = target...7,
    color = color...8,
    reward = reward...9
  ) %>%
  mutate(
    rtDiff = rt...2 - rt...11,
    dprimeDiff = dprime...3 - dprime...12,
    criterionDiff = criterion...4 - criterion...13
  ) %>%
  select(subject,
         target,
         color,
         reward,
         rtDiff,
         dprimeDiff,
         criterionDiff)




longFormData <- bind_rows(
  C1T1_H_diff,
  C1T2_H_diff,
  C1T3_H_diff,
  C2T1_H_diff,
  C2T2_H_diff,
  C2T3_H_diff,
  C3T1_H_diff,
  C3T2_H_diff,
  C3T3_H_diff,
  C1T1_L_diff,
  C1T2_L_diff,
  C1T3_L_diff,
  C2T1_L_diff,
  C2T2_L_diff,
  C2T3_L_diff,
  C3T1_L_diff,
  C3T2_L_diff,
  C3T3_L_diff
)




library(Rmisc)
#Hit Rate====
dprime <-
  summarySEwithin(
    longFormData,
    measurevar = 'dprimeDiff',
    withinvars = c('reward', 'target', 'color'),
    idvar = 'subject'
  ) %>%
  mutate(condition = as.factor(c(replicate(3, "dprimeDiff"))),
         mean = dprimeDiff)

width = .8
dodgeWidth = .85
errWidth = .4
errdodgeWidth = .85
barD <- ggplot(dprime,
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
      c(high = "High-Value Color",
        low = "Low-Value Color",
        none = "Control")
    )
  ) +
  geom_errorbar(
    aes(ymin = mean - se,
        ymax = mean + se),
    width = errWidth,
    position = position_dodge(width = errdodgeWidth),
    colour = "azure4",
    size = 1
  ) +
  
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
  labs(x = '',
       y = expression(paste("Discriminability ",italic("d\'")))) +
  theme_bw() +
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 24),
    axis.title = element_text(size = 32),
    strip.text.x = element_text(size = 24),
    
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  )
barD
###############################
criterion <-
  summarySEwithin(
    longFormData,
    measurevar = 'criterionDiff',
    withinvars = c('reward', 'target', 'color'),
    idvar = 'subject'
  ) %>%
  mutate(mean = criterionDiff)

barC <- ggplot(criterion,
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
  
  #coord_cartesian(ylim = c(-.25, .2)) +
  
  facet_grid(
    ~ reward,
    scales = "free_x",
    space = "free_x",
    switch = "x",
    labeller = as_labeller(
      c(high = "High-Value Color",
        low = "Low-Value Color",
        none = "Control")
    )
  ) +
  geom_errorbar(
    aes(ymin = mean - se,
        ymax = mean + se),
    width = errWidth,
    position = position_dodge(width = errdodgeWidth),
    colour = "azure4",
    size = 1
  ) +
  
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
  
  labs(x = '',
       y = expression(paste("Criterion ",italic("c")))) +
  
  theme_bw() +
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 24),
    axis.title = element_text(size = 32),
    strip.text.x = element_text(size = 24),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  )
barC




