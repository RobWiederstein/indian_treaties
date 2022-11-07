library(forcats)
treaties <- readRDS("./data/treaties_tokenized.rds")


treaties_tf_idf <-
    treaties |>
    select(-proportion) |>
    bind_tf_idf(word, class, n)

treaties_tf_idf$class <- factor(treaties_tf_idf$class,
                         labels = c("Ratified", "Rejected", "Unratified", "Valid"))
library(colorspace)
colors <- qualitative_hcl(4, palette = "dynamic")

treaties_tf_idf %>%
    group_by(class) %>%
    slice_max(tf_idf, n = 15) %>%
    ungroup() %>%
    ggplot(aes(tf_idf, fct_reorder(word, tf_idf), fill = class)) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~class, ncol = 2, scales = "free") +
    labs(x = "tf-idf",
         y = NULL,
         title = "Word tf-idf in US-Indian Treatise (1784 - 1911)",
         caption = "Harvard Dataverse") +
    scale_fill_manual(values = colors) +
    theme_minimal()

ggsave("./plots/treaties_tf_idf.png",
       height = 8,
       width = 8,
       units = "in",
       bg = "white")
