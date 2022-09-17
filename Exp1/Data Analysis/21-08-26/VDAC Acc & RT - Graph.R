#Plot accuracy and response time of RSVP Task
#setup====
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library('Cairo')
CairoWin()

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
#  reward blk  N       rt       sd       se        ci     mean trialNum
#1    high   1 62 679.3149 43.20551 5.487105 10.972145 679.3149       50
#2    high   2 62 664.5796 34.43844 4.373686  8.745725 664.5796      100
#3    high   3 62 639.7467 35.79002 4.545337  9.088963 639.7467      150
#4    high   4 62 624.2216 34.40964 4.370029  8.738412 624.2216      200
#5    high   5 62 647.6093 15.48540 1.966647  3.932554 647.6093        0
#6     low   1 62 672.3414 51.07714 6.486803 12.971164 672.3414       50
#7     low   2 62 669.1308 35.54043 4.513639  9.025578 669.1308      100
#8     low   3 62 639.2557 36.85918 4.681120  9.360478 639.2557      150
#9     low   4 62 633.4632 38.49285 4.888597  9.775354 633.4632      200
#10    low   5 62 651.8100 15.77310 2.003186  4.005618 651.8100        0


#reward blk  N  accuracy         sd          se          ci      mean trialNum
#1    high   1 62 0.8577112 0.07637455 0.009699577 0.019395503 0.8577112       50
#2    high   2 62 0.8996811 0.05556629 0.007056926 0.014111196 0.8996811      100
#3    high   3 62 0.9056066 0.05126364 0.006510489 0.013018528 0.9056066      150
#4    high   4 62 0.9293568 0.06765185 0.008591794 0.017180354 0.9293568      200
#5    high   5 62 0.8988418 0.02239892 0.002844665 0.005688259 0.8988418        0
#6     low   1 62 0.8674889 0.07062110 0.008968889 0.017934402 0.8674889       50
#7     low   2 62 0.8968105 0.06756934 0.008581315 0.017159399 0.8968105      100
#8     low   3 62 0.9195011 0.05897678 0.007490058 0.014977297 0.9195011      150
#9     low   4 62 0.9119915 0.05531121 0.007024531 0.014046418 0.9119915      200
#10    low   5 62 0.8992823 0.02299033 0.002919775 0.005838451 0.8992823        0


df <- bind_rows(high1, high2, high3, high4, high5,
                low1, low2, low3, low4, low5) %>%
  group_by(reward, blk) %>%
  summarise(
    accMean = c(
      0.8577112,
      0.8996811,
      0.9056066,
      0.9293568,
      0.8988418,
      0.8674889,
      0.8968105,
      0.9195011,
      0.9119915,
      0.8992823
    ),
    accSE = c(
      0.009699577,
      0.007056926,
      0.006510489,
      0.008591794,
      0.002844665,
      0.008968889,
      0.008581315,
      0.007490058,
      0.007024531,
      0.002919775
    ),
    rtMean = c(
      679.3149,
      664.5796,
      639.7467,
      624.2216,
      647.6093,
      672.3414,
      669.1308,
      639.2557,
      633.4632,
      651.8100
    ),
    rtSE = c(
      5.487105,
      4.373686,
      4.545337,
      4.370029,
      1.966647,
      6.486803,
      4.513639,
      4.681120,
      4.888597,
      2.003186
    ),
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
                width = 10,
                size = 1) +
  
  coord_cartesian(ylim = c(600, 700)) +
  
  labs(y = 'Response Time (ms)',
       x = 'Trial Number'
       ) +
  
  scale_color_manual(
    values = c('High' = "red",
               'Low' = "green"
    ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_bw()+
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 13),
    axis.title = element_text(size = 15),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  ) 
rtByTrial

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
                color = 'azure4',
                size = 1) +
  
  coord_cartesian(ylim = c(600, 700)) +
  
  labs(y = 'Response Time (ms)',
       x = 'Reward Condition'
       ) +
  
  scale_fill_manual(
    values = c('High' = "red",
               'Low' = "green"
    ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_bw()+
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 13),
    axis.title = element_text(size = 15),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
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
                width = 10,
                size = 1) +
  
  coord_cartesian(ylim = c(.8, .95)) +
  
  
  labs(y = 'Accuracy (Proportion Correct)',
       x = 'Trial Number') +
  
  scale_color_manual(
    values = c('High' = "red",
               'Low' = "green"
    ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_bw()+
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 13),
    axis.title = element_text(size = 15),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
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
                color = 'azure4',
                size = 1) +
  
  coord_cartesian(ylim = c(.8, .95)) +
  
  labs(y = 'Accuracy (Proportion Correct)',
       x = 'Reward Condition') +
  
  scale_fill_manual(
    values = c('High' = "red",
               'Low' = "green"
    ),
    name = 'Reward Condition',
    labels = c('High', 'Low')
  ) +
  
  theme_bw()+
  theme(
    legend.position = 'none',
    axis.text = element_text(size = 13),
    axis.title = element_text(size = 15),
    axis.line = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank()
  ) 

(rtByTrial + rtByTotal) / (accByTrial + accByTotal)

ggsave((accByTrial + accByTotal), filename = 'VDACacc.png', dpi = 300, type = 'cairo',
       width = 8, height = 4, units = 'in')

ggsave((rtByTrial + rtByTotal), filename = 'VDACrt.png', dpi = 300, type = 'cairo',
       width = 8, height = 4, units = 'in')

