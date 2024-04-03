########Feb 4 2024
########Ana Chkhaidze
########Zwaan replication paper with Imagery: Immediate verification task
########Datafile preprocessing and formatting


import numpy as np
import pandas as pd
import hvplot.pandas
import plotly
from nltk.stem import WordNetLemmatizer
from autocorrect import Speller 
from bs4 import BeautifulSoup 
from nltk import word_tokenize
import matplotlib.pyplot as plt
import seaborn as sns
import seaborn as sb
import os
import re
import time
from unidecode import unidecode



# show all cols in dataframe
pd.set_option('display.max_columns', None)




df_responses = pd.read_csv("data_file.csv")


# drop non-trial rows
df_responses = df_responses[df_responses.list.notnull()]
# # remove fixation trials
df_responses = df_responses[df_responses.response_rt.notnull()]

df_responses = df_responses[df_responses['task'].str.contains('task')==False]

# confirm that each participant saw 120 trials (240 rows: 120 pictures, 120 images): row number / 240
length_df_responses = df_responses[df_responses.columns[0]].count()
trial_number_participant = length_df_responses / 120
trial_number_participant


# remove unnecessary columns
df_responses = df_responses.drop(columns=['trial_type', 'internal_node_id', 'survey_code', 'success', 'timeout',
                                         'failed_images', 'failed_audio', 'failed_video', 'trial_index'])


#create separate dataframes for sentences and images
df_responses_sent = df_responses[df_responses['task'].str.contains('response')==False]
df_responses_img = df_responses[df_responses['task'].str.contains('response')==True]


df_responses_sent = df_responses_sent.drop(columns=['response', 'task', 'correct_response', 'hit', 'time_elapsed'])

# rename columns
df_responses_sent = df_responses_sent.rename(columns={"rt": "rt_sent", "list": "list_sent", "trialType": "trialTypeSent",
                                           "isMatch": "isMatchSent"})
df_responses_img = df_responses_img.rename(columns={"rt": "rt_img", "trialIndex": "trialIndexImg", "stimulus": "cue"})


df_responses_img = df_responses_img.reset_index()
df_responses_sent = df_responses_sent.reset_index()


df_responses_img = df_responses_img.drop(columns=['index'])
df_responses_sent = df_responses_sent.drop(columns=['index'])

df = pd.concat([df_responses_img, df_responses_sent], axis=1)

df_final = df.loc[:,~df.columns.duplicated()]


df_final = df_final.drop(columns=['task', 'trialIndexImg', 'list_sent', 'trialTypeSent', 'isMatchSent'])


df_final = df_final.rename(columns={"cue": "image", "stimulus": "sentence"})


df_final = df_final[['subject', 'trialIndex', 'sentence', 'image', 'trialType', 'isMatch', 'rt_sent', 'rt_img',
                    'hit', 'list', 'time_elapsed', 'correct_response', 'response']]


