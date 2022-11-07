library(ggplot2)
library(scales)
library(tidyr)
##----------------------------------------------------------------
corpus_tidy <- readRDS("./data/treaties_tokenized.rds")
corpus_tidy_wide <-
    corpus_tidy |>
    select(-n) |>
    pivot_wider(names_from = class,
                values_from = proportion)

##----------------------------------------------------------------
corpus_tidy_wide |>
    ggplot() +
    aes(UCUT, VCUT, color = abs(UCUT - VCUT)) +
    geom_abline(color = "gray40", lty = 2) +
    geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
    geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
    scale_x_log10(labels = percent_format()) +
    scale_y_log10(labels = percent_format()) +
    scale_color_gradient(limits = c(0, 0.001),
                         low = "darkslategray4", high = "gray75") +
    #facet_wrap(~class, ncol = 2) +
    theme_minimal() +
    theme(legend.position="none") +
    labs(title = "Word Frequency in US-Indian Treatise (1784 - 1911)",
         x = "Unratified",
         y = "Valid",
         caption = "Harvard Dataverse")
filename = paste0("./plots/valid_vs_unratified.png")
ggsave(filename = filename,
       width = 6,
       height = 6,
       units = "in",
       bg = "white")
##----------------------------------------------------------------
corpus_tidy_wide |>
    ggplot() +
    aes(ACUT, VCUT, color = abs(ACUT - VCUT)) +
    geom_abline(color = "gray40", lty = 2) +
    geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
    geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
    scale_x_log10(labels = percent_format()) +
    scale_y_log10(labels = percent_format()) +
    scale_color_gradient(limits = c(0, 0.001),
                         low = "darkslategray4", high = "gray75") +
    #facet_wrap(~class, ncol = 2) +
    theme_minimal() +
    theme(legend.position="none") +
    labs(title = "Word Frequency in US-Indian Treatise (1784 - 1911)",
         x = "Ratified",
         y = "Valid",
         caption = "Harvard Dataverse")
filename = paste0("./plots/valid_vs_ratified.png")
ggsave(filename = filename,
       width = 6,
       height = 6,
       units = "in",
       bg = "white")
##----------------------------------------------------------------
corpus_tidy_wide |>
    ggplot() +
    aes(RCUT, VCUT, color = abs(RCUT - VCUT)) +
    geom_abline(color = "gray40", lty = 2) +
    geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
    geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
    scale_x_log10(labels = percent_format()) +
    scale_y_log10(labels = percent_format()) +
    scale_color_gradient(limits = c(0, 0.001),
                         low = "darkslategray4", high = "gray75") +
    #facet_wrap(~class, ncol = 2) +
    theme_minimal() +
    theme(legend.position="none") +
    labs(title = "Word Frequency in US-Indian Treatise (1784 - 1911)",
         x = "Rejected",
         y = "Valid",
         caption = "Harvard Dataverse")
filename = paste0("./plots/valid_vs_rejected.png")
ggsave(filename = filename,
       width = 6,
       height = 6,
       units = "in",
       bg = "white")
