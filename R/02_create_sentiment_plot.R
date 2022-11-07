library(tidytext)
treaties <- readRDS("./data/treaties_corpus.rds")

#class, treaty, linenumber, word
treaties_tidy <-
    treaties |>
    unnest_tokens(word, text)

#
treaties_sentiment <-
    treaties_tidy |>
    inner_join(get_sentiments("bing")) |>
    count(class, treatise, sentiment) |>
    group_by(class, treatise) |>
    pivot_wider(names_from = "sentiment",
                values_from = n) |>
    mutate(sentiment = positive - negative) |>
    mutate(index = stringr::str_sub(treatise, start = 2, end = -5L)) |>
    mutate(index = stringr::str_remove(index, "^0+")) |>
    mutate(index = as.integer(index))

#factor for labels
treaties_sentiment$class <- factor(treaties_sentiment$class,
                                labels = c("Ratified", "Rejected", "Unratified", "Valid"))
# color
library(colorspace)
colors <- qualitative_hcl(4, palette = "dynamic")

# plot
library(ggplot2)
treaties_sentiment |>
    ggplot() +
    aes(index, sentiment, fill = class) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~class, ncol = 2, scales = "free_x") +
    scale_fill_manual(values = colors) +
    theme_minimal() +
    labs(x = "",
         y = "sentiment score",
         title = "US-Indian Treatise (1784 - 1911) \nTreaty Sentiment Score",
         caption = "Harvard Dataverse")
filename <- "./plots/treaty_sentiment_score.png"
ggsave(filename = filename,
       height = 5,
       width = 8,
       units = "in",
       bg = "white")
