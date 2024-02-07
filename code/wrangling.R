library(dplyr)
library(ggplot2)

data_mps <- readRDS("_SharedFolder_article_vaa_llm_bias/data/data_mps.rds")

split_data <- strsplit(data_mps$gpt_35_chars, ",")

for(i in 1:11) {
  data_mps[[paste0("gpt_35_chars_", i - 1)]] <- sapply(split_data, function(x) ifelse(length(x) >= i, x[i], NA))
}
