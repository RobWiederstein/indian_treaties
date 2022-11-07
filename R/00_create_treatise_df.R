# kernlab::kpca
# url: https://stackoverflow.com/questions/42856838/string-kernels-in-r
library(dplyr)
library(tidyr)
library(ggplot2)
#files
files <- list.files(path = c("./dataverse_files/justdocsACUT",
                             "./dataverse_files/justdocsRCUT",
                             "./dataverse_files/justdocsUCUT",
                             "./dataverse_files/justdocsVCUT"),
                    include.dirs = T,
                    recursive = T,
                    full.names = T)
#read in
dt <- tibble::tibble()
for(i in 1:length(files)){
    corpus <- readLines(files[i])
    corpus <- corpus[corpus != ""]
    corpus_df <- tibble::tibble(line = 1:length(corpus),
                                treatise = basename(files[i]),
                                text = corpus)
    dt <- dplyr::bind_rows(dt, corpus_df)
}
# create class variable
dt1 <-
    dt |>
    mutate(class = substr(treatise, start = 1, stop = 1)) |>
    mutate(class = case_when(
        class == "A" ~ "ACUT",
        class == "R" ~ "RCUT",
        class == "U" ~ "UCUT",
        class == "V" ~ "VCUT"
    )) |>
    select(class, everything())
saveRDS(dt1, "./data/treaties_corpus.rds")
##----------------------------------------------------------------
library(tidytext)
corpus_tidy <-
    dt1 |>
    unnest_tokens(word, text) |>
    dplyr::anti_join(stop_words) |>
    #omit numbers
    filter(!grepl("^[0-9.,_]+", word, perl = T)) |>
    #omit words less than or = 2
    filter(nchar(word) > 2) |>
    #omit word article |>
    filter(!grepl("article", word)) |>
    group_by(class) |>
    count(class, word) |>
    mutate(proportion = n / sum(n)) |>
    ungroup()

saveRDS(corpus_tidy, "./data/treaties_tokenized.rds", ascii = T)

