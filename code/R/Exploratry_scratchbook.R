

# Get the libraries we need -----------------------------------------------

#install.packages("sergeant")
#install.packages("tidyverse")
library(sergeant) # Get Apache Drill
library(tidyverse)

# Get a connection to data sources ----------------------------------------

# This is using Apache Drill as an SQL engine.
### from ?src_drill : This is a DBI wrapper around the Drill REST API. TODO username/password support
### The port, 8047, is only accessible from a fixed IP, due to the lack of username/passport support.
db <- src_drill("34.245.113.42") #Connect to already running stand-alone Drill. `Started with drill-embeded on remote server` 
# apache drill (dfs.tmp)> show tables;
# +--------------+-------------------------+
#   | TABLE_SCHEMA |       TABLE_NAME        |
#   +--------------+-------------------------+
#   | dfs.tmp      | v_althingi              |
#   | dfs.tmp      | v_althingislog          |
#   | dfs.tmp      | v_dfs                   |
#   | dfs.tmp      | v_stundin_blad          |
#   | dfs.tmp      | v_pressan               |
#   | dfs.tmp      | v_frettatiminn          |
#   | dfs.tmp      | v_kjarninn              |
#   | dfs.tmp      | v_mbl                   |
#   | dfs.tmp      | v_bbl                   |
#   | dfs.tmp      | v_stundin_serblad       |
#   | dfs.tmp      | v_domstolar             |
#   | dfs.tmp      | v_frettatiminn_bl       |
#   | dfs.tmp      | v_heimur                |
#   | dfs.tmp      | v_bleikt                |
#   | dfs.tmp      | v_eyjan                 |
#   | dfs.tmp      | v_ras1_og_2             |
#   | dfs.tmp      | v_stundin               |
#   | dfs.tmp      | v_dv_is                 |
#   | dfs.tmp      | v_bb                    |
#   | dfs.tmp      | v_fjardarpostur         |
#   | dfs.tmp      | v_andriki               |
#   | dfs.tmp      | v_ruv                   |
#   | dfs.tmp      | v_433                   |
#   | dfs.tmp      | v_fotbolti              |
#   | dfs.tmp      | v_visindavefur          |
#   | dfs.tmp      | v_bylgjan               |
#   | dfs.tmp      | v_baendabladid          |
#   | dfs.tmp      | ordtidni                |
#   | dfs.tmp      | v_bondi                 |
#   | dfs.tmp      | v_visir                 |
#   | dfs.tmp      | v_vf                    |
#   | dfs.tmp      | v_sjonvarpid            |
#   | dfs.tmp      | v_skessuhorn            |
#   | dfs.tmp      | v_textasafn_arnastofnun |
#   | dfs.tmp      | v_morgunbladid          |
#   | dfs.tmp      | v_kjarninn_blad         |
#   | dfs.tmp      | v_stod2                 |
#   | dfs.tmp      | v_jonas                 |
#   | dfs.tmp      | v_wikipedia             |
#   | dfs.tmp      | v_ras2                  |
#   | dfs.tmp      | v_haestirettur          |
#   | dfs.tmp      | v_ras1                  |
#   | dfs.tmp      | v_silfuregils           |
#   +--------------+-------------------------+

# Fetch some data ---------------------------------------------------------

# S3 on the server above is configured as a Drill Source against our S3 bucket: s3a://ordtidni
###  s3a://ordtidni/output/mbl/2012/ contains 1 or more? parquet files.

# Use dfs.tmp;
# create view ordtidni
# as 
# select `dir0` as `source`, 
# `dir1` as `year`, input_file,
# Paragraph,Sentence,word_nmber,Lemma,POS,Word
# from s3.`output/`;

# dfs.tmp.ordtidni is a view, already defined
WordFreq <- tbl(db, "dfs.tmp.ordtidni") 


FirstStats <- WordFreq %>% 
  group_by(source) %>%
  summarise(words = n(), 
            maxYear = max (year),
            minYear = min (year),
            years = n_distinct(year),
            files = n_distinct(input_file)) 

FirstStats %>% show_query()

FirstStats <- FirstStats %>%
  collect() ## This will force an execution and print output


whoFirstStats %>%
  summarise(TotalWords = sum(words)) #1.159.060.419

Althingislog2000 <- tbl(db, "dfs.tmp.`v_althingislog`")  %>%
  filter (year=="2000") %>%
  collect() ## This will run the query and return a DF

Althingislog2017 <- tbl(db, "dfs.tmp.`v_althingislog`")  %>%
  filter (year=="2017") %>%
  collect() ## This will run the query and return a DF

AT2000 <- Althingislog2000 %>%
  filter(str_detect(POS, "^n")) %>% # Only nouns
  group_by(Lemma) %>%
  summarise(Occ = n()) %>%
  top_n(100) %>%
  arrange(desc(Occ)) 

AT2017 <- Althingislog2017 %>%
  filter(str_detect(POS, "^n")) %>% # Only nouns
  group_by(Lemma) %>%
  summarise(Occ = n()) %>%
  top_n(100) %>%
  arrange(desc(Occ)) 

Eyjan2014 <- tbl(db, "dfs.tmp.`eyjan`")  %>%
  filter (year=="2014") %>%
  collect() ## This will run the query and return a DF

EyjanAll <-
  Eyjan2014  %>%
  filter(str_detect(POS, "^n")) %>% # Only nouns
  group_by(Lemma) %>%
  summarise(Occ = n()) %>%
  top_n(30) %>%
  arrange(desc(Occ)) 
  
dbDisconnect(db)
db
