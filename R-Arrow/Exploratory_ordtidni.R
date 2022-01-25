library(arrow, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)

data_dir <- "/Users/borkur/Downloads/Gigaword/output"

#install_arrow()

#starwars

columns <- c( "source" , "year" ,"input_file", "Paragraph" , "Sentence" , "word_number" ,"Lemma",  "POS",   "Word"    )


GigaWord <- arrow::open_dataset(sources = data_dir,partitioning = c("source" , "year"))
md <- GigaWord$metadata


# result %>% mutate(Month = substring(input_file,1,2), input_file = substring(input_file,4) )%>% filter(Paragraph==1, Sentence==1) 

get_data_gigaword <- function(p_source) {
  l_result <- GigaWord %>% 
    filter (source == p_source) %>%
    collect()  %>%
    mutate(Month = substring(input_file,1,2),  
           input_file = substring(input_file,4)) 
  return(l_result)
}

l_andriki <- get_data_gigaword('andriki')
l_mbl <- get_data_gigaword('mbl')

# source('load_all_subsets.R')
# dfs <- ls(pattern='l_*')
# library(data.table)
# GigaFrame <- rbindlist(mget(ls(pattern = "l_*")), idcol = TRUE)

head(l_morgunbladid)
one_page <- l_morgunbladid %>% filter(input_file == 'G-32-4246662.xml') %>% arrange(Paragraph,Sentence,word_number)
files <- l_morgunbladid %>% group_by(input_file) %>% summarise(n=n(), sentances = max(Sentence), paragraphs = max(Paragraph)) %>% ungroup()
POS <- l_morgunbladid %>% group_by(POS) %>% summarise(n=n()) %>% ungroup()

l_andriki %>% filter (substring(POS,1,1) =='n' ) %>% group_by(Lemma) %>% summarise(n=n()) %>% arrange(desc(n)) %>% head(10)

                                                               