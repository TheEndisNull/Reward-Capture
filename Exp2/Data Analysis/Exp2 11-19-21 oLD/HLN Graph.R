#collapsed dprime by target and color positions

#setup====
list.of.packages <- c("tidyverse", "patchwork", "BayesFactor")
new.packages <-
  list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if (length(new.packages))
  install.packages(new.packages)
rm(list.of.packages)
rm(new.packages)
library('tidyverse')
library('Cairo')
CairoWin()

library(readr)
data <- read_csv(
  "merged_file.csv",
  col_types = cols(
    correct = col_logical(),
    rt = col_double(),
    rwdType = col_integer(),
    tgtPos = col_integer(),
    colPos = col_integer(),
    colMatch = col_integer()
  )
)
View(data)

data <- tibble::as_tibble(data)
data <- filter(data,
               trialType == "RSVPtest",
               rt > quantile(data$rt, 0.025, na.rm = TRUE),) %>%
  select(subject, rt, correct, rwdType, tgtPos, colMatc)
data$subject <- as.factor(data$subject)
#levels(data$subject) <- 0:length(levels(data$subject))

rewardIdx = c('high', 'low', 'none')
nameRwd = c('H', 'L', 'N')


for (i in 1:2) {
  assign(
    paste0('TACA_', nameRwd[i]),
    bind_cols(
      filter(
        data,
        rwdType == rewardIdx[i],
        tgtPos == as.character(colorPosition),
        correct == "TRUE"
      ) %>%
        group_by(subject, .drop = F) %>%
        summarize(Hits = n(),
                  rt = median(rt)) %>%
        select(subject, rt, Hits),
      filter(
        data,
        rwdType == rewardIdx[i],
        tgtPos == as.character(colorPosition),
        correct == "FALSE"
      ) %>%
        group_by(subject, .drop = F) %>%
        summarize(Misses = n()) %>%
        select(Misses),
      filter(data,
             rwdType == rewardIdx[i],
             tgtPos == "new",
             correct == "FALSE") %>%
        group_by(subject, .drop = F) %>%
        summarize(False_Alarms = n()) %>%
        select(False_Alarms),
      filter(data,
             rwdType == rewardIdx[i],
             tgtPos == "new",
             correct == "TRUE") %>%
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
        reward = as.factor(replicate(n = n(), rewardIdx[i])),
        target = as.factor(c(replicate(n(
          
        ), "All"))),
        color = as.factor(c(replicate(n(
          
        ), "All")))
      ) %>%
      rename(HR = Corrected_HR,
             FA = Corrected_FA) %>%
      filter(Hits != 0) %>%
      select(subject, rt, dprime, criterion, HR, FA, target, color, reward)
  )
}

assign(
  paste0('TACA_', nameRwd[3]),
  bind_cols(
    filter(data,
           rwdType == rewardIdx[3],
           tgtPos != 'new',
           correct == "TRUE") %>%
      group_by(subject, .drop = F) %>%
      summarize(Hits = n(),
                rt = median(rt)) %>%
      select(subject, rt, Hits),
    filter(data,
           rwdType == rewardIdx[3],
           tgtPos != 'new',
           correct == "FALSE") %>%
      group_by(subject, .drop = F) %>%
      summarize(Misses = n()) %>%
      select(Misses),
    filter(data,
           rwdType == rewardIdx[3],
           tgtPos == "new",
           correct == "FALSE") %>%
      group_by(subject, .drop = F) %>%
      summarize(False_Alarms = n()) %>%
      select(False_Alarms),
    filter(data,
           rwdType == rewardIdx[3],
           tgtPos == "new",
           correct == "TRUE") %>%
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
      reward = as.factor(replicate(n = n(), rewardIdx[3])),
      target = as.factor(c(replicate(n(
        
      ), "All"))),
      color = as.factor(c(replicate(n(
        
      ), "All")))
    ) %>%
    rename(HR = Corrected_HR,
           FA = Corrected_FA) %>%
    filter(Hits != 0) %>%
    select(subject, rt, dprime, criterion, HR, FA, target, color, reward)
)

TACA_H
TACA_L
TACA_N


library(Rmisc)
#Hit Rate====
longFormData <- bind_rows(TACA_H, TACA_L, TACA_N)
hit_rate <-
  summarySEwithin(
    longFormData,
    measurevar = 'HR',
    withinvars = 'reward',
    idvar = 'subject'
  ) %>%
  mutate(condition = as.factor(c(replicate(3, "Hit Rate"))),
         mean = HR)

#new FA analysis====
false_alarm_rate <-
  summarySEwithin(
    longFormData,
    measurevar = 'FA',
    withinvars = 'reward',
    idvar = 'subject'
  ) %>%
  mutate(condition = as.factor(c(replicate(3, "False Alarm Rate"))),
         mean = FA)

width = .8
dodgeWidth = .85
errWidth = .4
errdodgeWidth = .85


FA_HR_df <- bind_rows(hit_rate, false_alarm_rate) %>%
  select(reward, mean, sd, se, ci, condition) %>%
  print()

HR_FA_bar <- ggplot(FA_HR_df, aes(
  y = mean,
  x = condition,
  fill = factor(reward),
)) +
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(width = dodgeWidth),
    color = 'black'
  ) +
  
  geom_errorbar(
    aes(ymin = mean - se,
        ymax = mean + se),
    width = errWidth,
    position = position_dodge(width = errdodgeWidth),
    colour = "azure4",
    size = 1
  ) +
  
  coord_cartesian(ylim = c(.1, .9)) +
  
  labs(y = 'Proportion',
       x = 'Reward') +
  
  scale_fill_manual(
    values = c(high = "red",
               low = "green",
               none = "black"),
    name = 'Reward Condition',
    labels = c('High', 'Low', 'None')
  ) +
  theme_bw() +
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 24),
    axis.title = element_text(size = 32),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  )


#dprime====
dprime <-
  summarySEwithin(
    longFormData,
    measurevar = 'dprime',
    withinvars = 'reward',
    idvar = 'subject'
  )

dprime_bar <- ggplot(dprime,
                     aes(y = dprime,
                         x = reward,
                         fill = reward)) +
  
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(dodgeWidth),
    color = 'black'
  ) +
  
  geom_errorbar(
    aes(ymin = dprime - se,
        ymax = dprime + se),
    width = errWidth,
    position = position_dodge(errdodgeWidth),
    colour = "azure4",
    size = 1
  ) +
  
  coord_cartesian(ylim = c(1.8, 2.2)) +
  #coord_cartesian(ylim = c(1.25, 2.25)) +
  
  
  labs(y = expression(paste("Discriminability ", italic("d\'"))),
       x = '') +
  
  scale_fill_manual(values = c(high = "red",
                               low = "green",
                               none = "black")) +
  
  scale_x_discrete(labels = c(
    "high" = "High",
    "low" = "Low",
    "none" = "Control"
  )) +
  
  
  theme_bw() +
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 24),
    axis.title = element_text(size = 32),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  )

#criterion====
criterion <-
  summarySEwithin(
    longFormData,
    measurevar = 'criterion',
    withinvars = 'reward',
    idvar = 'subject'
  )

criterion_bar <- ggplot(criterion,
                        aes(
                          y = criterion,
                          x = interaction(reward),
                          group = reward,
                          fill = reward
                        )) +
  
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(dodgeWidth),
    color = 'black'
  ) +
  #coord_cartesian(ylim = c(-.25, .2)) +
  
  geom_errorbar(
    aes(ymin = criterion - se,
        ymax = criterion + se),
    width = errWidth,
    position = position_dodge(errdodgeWidth),
    colour = "azure4",
    size = 1
  ) +
  
  labs(y = expression(paste("Criterion ", italic("c"))),
       x = '') +
  
  scale_fill_manual(values = c(high = "red",
                               low = "green",
                               none = "black")) +
  
  scale_x_discrete(labels = c(
    "high" = "High",
    "low" = "Low",
    "none" = "Control"
  )) +
  
  
  theme_bw() +
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 24),
    axis.title = element_text(size = 32),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  )


#RT====

rt <-
  summarySEwithin(
    longFormData,
    measurevar = 'rt',
    withinvars = 'reward',
    idvar = 'subject'
  )

rt_bar <- ggplot(rt,
                 aes(
                   y = rt,
                   x = interaction(reward),
                   group = reward,
                   fill = reward
                 )) +
  
  geom_bar(
    stat = "identity",
    width = width,
    position = position_dodge(dodgeWidth),
    color = 'black'
  ) +
  
  geom_errorbar(
    aes(ymin = rt - se,
        ymax = rt + se),
    width = errWidth,
    position = position_dodge(errdodgeWidth),
    colour = "azure4",
    size = 1
  ) +
  
  coord_cartesian(ylim = c(700, 800)) +
  
  labs(y = 'Response Time (ms)',
       x = 'Reward') +
  
  scale_fill_manual(values = c(high = "red",
                               low = "green",
                               none = "black")) +
  
  scale_x_discrete(labels = c(
    "high" = "High",
    "low" = "Low",
    "none" = "Control"
  )) +
  
  
  theme_bw() +
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 24),
    axis.title = element_text(size = 32),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  )

HR_FA_bar + rt_bar + dprime_bar + criterion_bar




ggsave(
  HR_FA_bar,
  filename = 'Colhr.png',
  dpi = 300,
  type = 'cairo',
  width = 8,
  height = 5,
  units = 'in'
)

ggsave(
  dprime_bar,
  filename = 'Coldprime.png',
  dpi = 300,
  type = 'cairo',
  width = 6,
  height = 5,
  units = 'in'
)

ggsave(
  criterion_bar,
  filename = 'Colcriterion.png',
  dpi = 300,
  type = 'cairo',
  width = 6,
  height = 5,
  units = 'in'
)

ggsave(
  rt_bar,
  filename = 'Colrt.png',
  dpi = 300,
  type = 'cairo',
  width = 7,
  height = 5,
  units = 'in'
)
