library(dplyr)
library(tidytext)
treaties <- readRDS("./data/treaties_corpus.rds")
treaties <-
    treaties |>
    mutate(document = row_number()) |>
    mutate(passage = case_when(
        treaties$class == "ACUT" ~ "pass",
        treaties$class == "VCUT" ~ "pass",
        treaties$class == "RCUT" ~ "fail",
        treaties$class == "UCUT" ~ "fail"
    ))

treaties_tidy <-
    treaties |>
    unnest_tokens(word, text) |>
    anti_join(get_stopwords()) |>
    #omit numbers
    filter(!grepl("^[0-9.,_]+", word, perl = T)) |>
    #omit words less than or = 2
    filter(nchar(word) > 3) |>
    #omit word article |>
    filter(!grepl("article", word)) |>
    filter(!grepl("(Intercept)", word)) |>
    #omit roman numeral
    filter(!grepl("viii", word)) |>
    group_by(word) |>
    filter(n() > 10) |>
    ungroup()

library(rsample)
set.seed(1234)
treaties_split <- treaties %>%
    select(document) %>%
    initial_split()
train_data <- training(treaties_split)
test_data <- testing(treaties_split)

#convert to sparse
sparse_words <- treaties_tidy %>%
    count(document, word) %>%
    inner_join(train_data) %>%
    cast_sparse(document, word, n)
class(sparse_words)
dim(sparse_words)
word_rownames <- as.integer(rownames(sparse_words))

#join
treaties_joined <- tibble(document = word_rownames) %>%
    left_join(treaties %>%
                  select(document, passage))
library(glmnet)
library(doMC)
registerDoMC(cores = 8)
is_valid <- treaties_joined$passage == "pass"
model <- cv.glmnet(sparse_words, is_valid,
                   family = "binomial",
                   parallel = TRUE, keep = TRUE
)
plot(model)
ggsave("./plots/ml_glmnet_binomial_deviance.jpg", height = 4, width = 6, units = "in")

plot(model$glmnet.fit)
ggsave("./plots/ml_glmnet_coef.jpg", height = 4, width = 6, units = "in")

library(broom)

coefs <- model$glmnet.fit %>%
    tidy() %>%
    filter(lambda == model$lambda.1se)
library(ggplot2)
library(forcats)
colors <- colorspace::qualitative_hcl(n = 2, palette = "dynamic")
coefs %>%
    group_by(estimate > 0) %>%
    top_n(15, abs(estimate)) %>%
    ungroup() %>%
    ggplot(aes(fct_reorder(term, estimate), estimate, fill = estimate > 0)) +
    geom_col(alpha = 0.8, show.legend = FALSE) +
    scale_fill_manual(values = colors) +
    coord_flip() +
    labs(
        x = NULL,
        title = "Coefficients that increase/decrease probability the most"
    ) +
    theme_minimal()

ggsave("./plots/ml_glmnet_coef_prob.jpg", height = 4, width = 6, units = "in")

# use the test data
intercept <- coefs %>%
    filter(term == "(Intercept)") %>%
    pull(estimate)

classifications <-
    treaties_tidy %>%
    inner_join(test_data) %>%
    inner_join(coefs, by = c("word" = "term")) %>%
    group_by(document) %>%
    summarize(score = sum(estimate)) %>%
    mutate(probability = plogis(intercept + score))
classifications

library(yardstick)

comment_classes <- classifications %>%
    left_join(treaties %>%
                  select(passage, document), by = "document") %>%
    mutate(passage = as.factor(passage))

comment_classes %>%
    roc_curve(passage, probability) %>%
    ggplot(aes(x = 1 - specificity, y = sensitivity)) +
    geom_line(
        color = "midnightblue",
        size = 1.5
    ) +
    geom_abline(
        lty = 2, alpha = 0.5,
        color = "gray50",
        size = 1.2
    ) +
    labs(
        title = "ROC curve for text classification using regularized regression"
    )
ggsave("./plots/ml_glmnet_roc_curve.jpg", height = 5, width = 5, units = "in")
comment_classes %>%
    roc_auc(passage, probability)

#comment_classes_new <-
    comment_classes %>%
    mutate(
        prediction = case_when(
            probability > 0.5 ~ "fail",
            TRUE ~ "pass"
        ),
        prediction = as.factor(prediction)
    ) |>
    conf_mat(passage, prediction)
