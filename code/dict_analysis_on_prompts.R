# Packages -----------------------------------------------------------------
library(dplyr)

# Data --------------------------------------------------------------------
df_prompts <- readRDS("data/data_article_vaa_llm_bias.rds") %>% 
  tidyr::pivot_longer(., cols = starts_with("gpt"),
                      names_to = "char_id",
                      values_to = "char") %>% 
  mutate(gpt_model = case_when(
    grepl("gpt_35", char_id) ~ "gpt_35",
    grepl("gpt_4_c", char_id) ~ "gpt_4",
    grepl("gpt_4_0125", char_id) ~ "gpt_4turbo"
  ),
  doc_id = 1:nrow(.))

# Text Wrangling and Cleaning ---------------------------------------------------------------

stopwords <- c(stopwords::stopwords(),
               "support", "advocate", "promote",
               "pro", "champion", "focus", "proponent",
               "prioritize")
clean_text <- function(text, stopwords) {
  # Mettre le texte en minuscules
  text <- tolower(text)
  # Supprimer les espaces superflus
  text <- tm::stripWhitespace(text)
  # Garder la racine des mots
  text <- textstem::lemmatize_strings(text)
  # Supprimer les stop words
  text <- tm::removeWords(text, stopwords)
  # Supprimer la ponctuation
  text <- tm::removePunctuation(text)
  # Supprimer les nombres
  text <- tm::removeNumbers(text)
  # Supprimer les espaces superflus
  text <- tm::stripWhitespace(text)
  return(text)
}

# Application de la fonction de nettoyage
df_prompts$clean_text <- clean_text(df_prompts$char, stopwords = stopwords)


# Explo of word frequencies --------------------------------------------------------------------

nb_words_by_characteristics <- df_prompts %>%
  tidytext::unnest_tokens(., word, clean_text) %>% 
  group_by(doc_id) %>% 
  summarise(n = n())

word_frequencies <- df_prompts %>%
  tidytext::unnest_tokens(., word, clean_text) %>%
  group_by(word) %>% 
  summarise(freq = n()) %>% 
  tidyr::drop_na()

bigrams_frequencies <- df_prompts %>%
  tidytext::unnest_tokens(., word, clean_text,
                          token = "ngrams", n = 2) %>%
  group_by(word) %>% 
  summarise(freq = n()) %>% 
  tidyr::drop_na()

df_combined_freqs <- rbind(word_frequencies, bigrams_frequencies) %>% 
  tidyr::drop_na()
## df_combined_freqs allows us to categorize most used words
## we need to find the freq threshold after which we attain a saturation point, that is 
### when we attain a point where almost all of our 13950 characteristics have been categorized

### Est-ce que df_prompts$clean_text contient l'un des mots avec une freq > 500?
prompts_categorized <- function(prompts, dict_words){
  matches <- sapply(dict_words, function(pattern) grepl(pattern, prompts))
  result <- apply(matches, 1, any)
  return(sum(result)/length(result))
}

dict_words <- df_combined_freqs$word[df_combined_freqs$freq > 500]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 53% of the prompts with freq > 500
length(dict_words)

dict_words <- df_combined_freqs$word[df_combined_freqs$freq > 100]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 95% of the prompts with freq > 100
length(dict_words)

dict_words <- df_combined_freqs$word[df_combined_freqs$freq > 50]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 98% of the prompts with freq > 50
length(dict_words)

## with bigrams only
dict_words <- bigrams_frequencies$word[bigrams_frequencies$freq > 200]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 26% of the prompts with freq > 200
length(dict_words)

dict_words <- bigrams_frequencies$word[bigrams_frequencies$freq > 100]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 42% of the prompts with freq > 100
length(dict_words)

dict_words <- bigrams_frequencies$word[bigrams_frequencies$freq > 50]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 60% of the prompts with freq > 50
length(dict_words)

dict_words <- bigrams_frequencies$word[bigrams_frequencies$freq > 25]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 72% of the prompts with freq > 25
length(dict_words)

dict_words <- bigrams_frequencies$word[bigrams_frequencies$freq > 10]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 83% of the prompts with freq > 10
length(dict_words)


## freq > 100 with words and bigrams seems to be the best option. But we need to see what happens if we remove
#### frequent single words with not that much meaning like
######  right, development, affordable, reform, small, public, policy, initiative, strong, emphasize,
######  accessibility, change 
dict_words <- df_combined_freqs$word[df_combined_freqs$freq > 100]
dict_words <- dict_words[!(dict_words %in%
                             c("right", "development", "affordable", "reform",
                               "small", "public", "policy", "initiative", "strong", "emphasize",
                               "accessibility", "change"))]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 90% of the prompts with freq > 100
length(dict_words)


dict_words <- df_combined_freqs$word[df_combined_freqs$freq > 50]
dict_words <- dict_words[!(dict_words %in%
                             c("right", "development", "affordable", "reform",
                               "small", "public", "policy", "initiative", "strong", "emphasize",
                               "accessibility", "change"))]
prompts_categorized(df_prompts$clean_text, dict_words) ## we cover 96% of the prompts with freq > 50
length(dict_words)

### save to excel to categorize each word and create dictionary
to_excel_to_create_dictionary <- df_combined_freqs[df_combined_freqs$freq > 100 &
                                                    !(df_combined_freqs$word %in%
                                                        c("right", "development", "affordable", "reform",
                                                          "small", "public", "policy", "initiative", "strong", "emphasize",
                                                          "accessibility", "change")),] %>% 
  arrange(-freq)

writexl::write_xlsx(to_excel_to_create_dictionary, "data/dictionaries/dict.xlsx")

# Load dictionary ---------------------------------------------------------

dict_excel <- readxl::read_excel("data/dictionaries/dict_manual.xlsx") %>% 
  tidyr::drop_na() %>% 
  select(-freq)

dict_list <- list()
for (c in unique(dict_excel$category)) {
  dict_list[[c]] <- dict_excel$word[dict_excel$category == c]
}

dict <- quanteda::dictionary(as.list(dict_list))

# Apply dictionary --------------------------------------------------------

dict_results <- clessnverse::run_dictionary(data = df_prompts,
                                            text = df_prompts$clean_text,
                                            dict = dict) %>% 
  mutate(doc_id = 1:nrow(.))
names(dict_results)[-1] <- paste0("category_", names(dict_results)[-1])

dict_results_long <- dict_results %>% 
  tidyr::pivot_longer(., cols = starts_with("category"),
                      names_to = "category",
                      names_prefix = "category_",
                      values_to = "issue_used_by_model") %>% 
  mutate(issue_used_by_model = ifelse(issue_used_by_model >= 1, 1, 0))

### trim df_prompts to get relevant macrodata about the doc_ids in dict_results_long
df_macro <- df_prompts %>% 
  select(mp_id, name, level, province,
         party, riding_id, riding_name,
         gender, gpt_model, doc_id, clean_text)


### Join them together
df_final <- inner_join(x = df_macro, y = dict_results_long, by = "doc_id")

saveRDS(df_final, "data/data_after_dict_analysis.rds")
