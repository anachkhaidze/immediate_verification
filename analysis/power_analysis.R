####March 23 2024
####Ana Chkhaidze
####Immediate sentence-picture verification study with imagery: Power analysis

# Load libraries
library(tidyverse)
library(lmerTest)
library(ggplot2)
library(simr)
library(doParallel)

# Set up parallel processing
numCores <- detectCores() - 1  # Leave one core free
registerDoParallel(cores = numCores)

# Import dataset
df_responses <- read.csv("zv_task_questionnaire_full_preprocessed_exclude_rt_sentences_images.csv")

# Create a subset for experimental trials
df_experimental <- filter(df_responses, trialType == "experimental")

# Fit the mixed-effects model
model <- lmer(rt_img ~ isMatch * vviq_z + (1 | subject) + (1 | trialIndex), data = df_experimental)

# Print summary of the model to get an idea of initial estimates
print(summary(model))

# Set the number of simulations for power analysis
NSIM <- 1000

# Initialize a dataframe to store results
df_power_results <- data.frame()

# Define a range of sample sizes to test
sample_sizes <- seq(from = 60, to = 200, by = 20)

# Ensure df_power_results is initialized outside the loop
df_power_results <- data.frame()

# Define your target power if not already defined
target_power <- 0.95
standard_power <- 0.8

# Dataframe to store data in
df_interactions <- data.frame()

for (ss in sample_sizes) {
  print(ss)
  
  # Extend the model with the new sample size
  m_new <- extend(model, along = "subject", n = ss)
  
  # Extract data for the new model
  df_new <- getData(m_new)
  
  # Fit the linear mixed-effects model
  model_new <- lmer(rt_img ~ isMatch * vviq_z + (1 | subject) + (1 | trialIndex), data = df_new)
  
  # Perform power simulation
  pow_interaction <- powerSim(model_new, test = fcompare(~isMatch + vviq_z), nsim = NSIM)
  
  # Convert summary to dataframe
  df_summ_interaction <- data.frame(summary(pow_interaction))
  df_summ_interaction$N <- ss
  
  print(df_summ_interaction)
  
  # Append results to the main dataframe
  df_interactions <- rbind(df_interactions, df_summ_interaction)
  
  # Check if target power is reached
  if (any(df_summ_interaction$mean >= 0.95)) {
    print(paste("Target power reached at sample size:", ss))
    break
  }

}

df_interactions

# Stop the parallel cluster
stopImplicitCluster()

# write.csv(df_interactions, "power_results.csv")
# df_interactions = read_csv("power_results.csv")

df_interactions %>%
  mutate(power = mean) %>%
  ggplot(aes(x = N,
             y = power)) +
  geom_point(stat = "identity") +
  geom_line() +
  geom_errorbar(aes(ymin = lower, 
                    ymax = upper),
                width=.2,
                position=position_dodge(.9)) +  
  geom_hline(yintercept = target_power, linetype = "dotted") +
  geom_hline(yintercept = standard_power, linetype = "dashed") +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal()
