#######Feb 4 2024
#######Ana Chkhaidze
#######Zwaan replication paper with Imagery: Immediate verification task
#######Outlier removal


# load libraries
suppressMessages(library(tidyverse))


# df_responses <- read.csv("datafile.csv")

### Function to exclude outlier RTs relative by participants
exclude.relative.by.ppt <- function(df, column, nsd) {
  
  # Init excluded column if not there
  if (!("excluded" %in% colnames(df))) {
    df$excluded = FALSE
  }
  
  column <- enquo(column)
  colname <- quo_name(column)
  colname.lo <- paste0("ex.", colname, ".rel.lo")
  colname.hi <- paste0("ex.", colname, ".rel.hi")
  
  df <- df %>%
    group_by(subject) %>%
    mutate(
      col_mean := mean(!!as.name(colname)),
      col_sd := sd(!!as.name(colname)),
      !!colname.lo := (!!as.name(colname) < (col_mean - (nsd * col_sd)) & (!excluded)),
      !!colname.hi := (!!as.name(colname) > (col_mean + (nsd * col_sd)) & (!excluded)),
      excluded = ((excluded | !!as.name(colname.lo)) | !!as.name(colname.hi))
    ) %>%
    select(-col_mean, -col_sd) %>%
    ungroup()
  
  return(df)
}
# # # #
df_exclude_sentRT <- exclude.relative.by.ppt(df_responses, rt_sent, 2.5)
df_exclude_sentRT <- df_exclude_sentRT[!grepl("TRUE", df_exclude_sentRT$excluded),]
df_exclude_imgRT <- exclude.relative.by.ppt(df_exclude_sentRT, rt_img, 2.5)
df_exclude_imgRT <- df_exclude_sentRT[!grepl("TRUE", df_exclude_imgRT$excluded),]

df_exclude_imgRT_test = df_exclude_imgRT %>%
  filter(rt_sent > 300)

# #
# write.csv()

### Load new dataset with excluded RTs and create 3 separate datasets for each condition

### create sub datasets for match, mismatch, fillers, and experimentals
df_responses_excl_sent_rt <- read.csv("datafile.csv")


### log transform and z-score rts
df_responses_excl_sent_rt$rt_img_log = log(df_responses_excl_sent_rt$rt_img)
df_responses_excl_sent_rt$rt_sent_log = log(df_responses_excl_sent_rt$rt_sent)
df_responses_excl_sent_rt$rt_img_z <- (df_responses_excl_sent_rt$rt_img-mean(df_responses_excl_sent_rt$rt_img))/sd(df_responses_excl_sent_rt$rt_img)
df_responses_excl_sent_rt$rt_sent_z <- (df_responses_excl_sent_rt$rt_sent-mean(df_responses_excl_sent_rt$rt_sent))/sd(df_responses_excl_sent_rt$rt_sent)

### Create subset datasets for match, mismatch, and filler
df_match <- filter(df_responses_excl_sent_rt, isMatch=="y")
df_nonMatch <- filter(df_responses_excl_sent_rt, isMatch=="n")
df_filler <- filter(df_responses_excl_sent_rt, trialType=="filler")

### Exclude trials relative by participants and conditions 
df_match_exclude_imgRT <- exclude.relative.by.ppt(df_match, rt_img, 2.5)
df_match_exclude_imgRT <- df_match_exclude_imgRT[!grepl("TRUE", df_match_exclude_imgRT$excluded),]
df_nonMatch_exclude_imgRT <- exclude.relative.by.ppt(df_nonMatch, rt_img, 2.5)
df_nonMatch_exclude_imgRT <- df_nonMatch_exclude_imgRT[!grepl("TRUE", df_nonMatch_exclude_imgRT$excluded),]
df_filler_exclude_imgRT <- exclude.relative.by.ppt(df_filler, rt_img, 2.5)
df_filler_exclude_imgRT <- df_filler_exclude_imgRT[!grepl("TRUE", df_filler_exclude_imgRT$excluded),]

total <- rbind(df_match_exclude_imgRT, df_nonMatch_exclude_imgRT, df_filler_exclude_imgRT)


