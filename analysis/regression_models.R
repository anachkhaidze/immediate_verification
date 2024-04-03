#######Feb 4 2024
#######Ana Chkhaidze
#######Zwaan replication paper with Imagery: Immediate verification task
#######Regression models


# load libraries
suppressMessages(library(tidyverse))
suppressMessages(library(lmerTest))

df_responses <- read.csv("datafile.csv")

#create sub dataset with experimental trials only
df_experimental <- filter(df_responses, trialType=="experimental")


#### RQ1: Do language comprehenders represent the implied shape of objects in sentences?
#### Specifically, are they slower when implied shape in a sentence does not match depicted shape in an image? 

model1_full <- lmer(data=df_experimental,
                    rt_img ~ isMatch  + 
                      (1 + subject) +
                      (1 + trialIndex))

model1_reduced <- lmer(data=df_experimental,
                       rt_img ~  
                         (1 + subject) +
                         (1 + trialIndex))

anova(model1_full, model1_reduced)


#### RQ1: Does self-reported vividness of visual imagery predict sentence-picture mismatch effect?
#### Specifically, does the mismatch effect increase as a function of the VVIQ scores? 

model2_full <- lmer(data=df_experimental,
                    rt_img ~ isMatch * vviq_z + 
                      (1 + subject) +
                      (1 + trialIndex))

model2_reduced <- lmer(data=df_experimental,
                       rt_img ~  isMatch +
                         (1 + subject) +
                         (1 + trialIndex))

anova(model2_full, model2_reduced)