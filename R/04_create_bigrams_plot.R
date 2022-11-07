library(dplyr)
library(tidytext)

treatise_corpus <- readRDS("./data/treaties_corpus.rds")

treatise_bigrams <-
    treatise_corpus |>
    unnest_tokens(bigram, text, token = "ngrams", n = 2) |>
    filter(!is.na(bigram))

bigrams_separated <-
    treatise_bigrams |>
    separate(bigram, into = c("word1", "word2", sep = " "))

bigrams_filtered <- bigrams_separated |>
    filter(!word1 %in% stop_words$word) |>
    filter(!word2 %in% stop_words$word) |>
    filter(!grepl("article", word1)) |>
    filter(!grepl("[0-9]+", word1)) |>
    filter(!grepl("[0-9]+", word2))
# unite
bigrams_united <- bigrams_filtered |>
    unite(bigram, word1, word2, sep = " ")

bigram_tf_idf <- bigrams_united |>
    count(class, bigram) |>
    bind_tf_idf(bigram, class, n) |>
    select(class, bigram, tf_idf) |>
    group_by(class) |>
    arrange(class, desc(tf_idf)) |>
    slice_head(n = 15)

#factor
bigram_tf_idf$class <- factor(bigram_tf_idf$class,
                                labels = c("Ratified", "Rejected", "Unratified", "Valid"))
# color
library(colorspace)
colors <- qualitative_hcl(4, palette = "dynamic")

bigram_tf_idf |>
    ggplot() +
    aes(tf_idf, fct_reorder(bigram, tf_idf), fill = class) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~class, ncol = 2, scales = "free") +
    scale_fill_manual(values = colors) +
    labs(x = "tf-idf",
         y = NULL,
         title = "Bigram Frequency in US-Indian Treatise (1784 - 1911)",
         caption = "Harvard Dataverse") +
    theme_minimal()
filename <- "./plots/treaties_bigram_tf_idf.png"
ggsave(filename = filename,
       height = 8,
       width = 8,
       units = "in",
       bg = "white")


