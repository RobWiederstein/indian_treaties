treaties <- readRDS("./data/treaties_corpus.rds")
#convert to DTM document-term matrix
treaties_dtm <-
    treaties %>%
    unnest_tokens(word, text) %>%
    anti_join(stop_words) |>
    count(class, word) %>%
    cast_dtm(class, word, n)
# compute lda
treaties_lda <-
    LDA(treaties_dtm, k = 4, control = list(seed = 1234))
# convert back to tidy tibble
treaties_topics <- tidy(treaties_lda, matrix = "beta")
# pull top terms
treaties_top_terms <-
    treaties_topics %>%
    group_by(topic) %>%
    slice_max(beta, n = 10) %>%
    ungroup() %>%
    arrange(topic, -beta)
# plot
library(colorspace)
colors <- qualitative_hcl(4, palette = "dynamic")
treaties_top_terms |>
    mutate(term = reorder_within(term, beta, topic)) %>%
    ggplot(aes(beta, term, fill = factor(topic))) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~ topic, scales = "free") +
    scale_fill_manual(values = colors) +
    theme_minimal() +
    scale_y_reordered() +
    labs(title = "Words by Topic in US-Indian Treatise (1784 - 1911)\n LDA Model",
         caption = "Harvard Dataverse")
filename = "./plots/treaty_lda_plot.png"
ggsave(filename = filename,
       height = 8,
       width = 8,
       unit = "in",
       bg = "white")
