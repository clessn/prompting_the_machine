# Packages ----------------------------------------------------------------
library(dplyr)
library(ggplot2)

# Data --------------------------------------------------------------------
data <- readRDS("data/data_after_dict_analysis.rds")


# Wrangling ---------------------------------------------------------------

df_n_chars_by_mp <- data %>% 
  group_by(mp_id, gpt_model, category) %>% 
  summarise(n = sum(issue_used_by_model))

## top categories
df_n_chars_by_mp %>% 
  group_by(category) %>% 
  summarise(ntotal = sum(n)) %>% 
  arrange(-ntotal)


quantiles <- df_n_chars_by_mp %>% 
  group_by(gpt_model, category) %>% 
  ### obtain 25, 50 and 75 centiles of distributions for each group
  summarise(
    Q25 = quantile(n, probs = 0.25, na.rm = TRUE),
    Q50 = quantile(n, probs = 0.50, na.rm = TRUE), # Median
    Q75 = quantile(n, probs = 0.75, na.rm = TRUE)
  ) %>% 
  tidyr::pivot_longer(., cols = starts_with("Q"),
                      names_to = "quantile",
                      values_to = "n")
  

# Graph -------------------------------------------------------------------

quantiles_graph <- quantiles %>% 
  filter(category %in% c("ecn_dev", "social", "environment", "health", "fiscal", "housing")) %>% 
  mutate(n = case_when(
    quantile == "Q25" ~ n - 0.2,
    quantile == "Q50" ~ n - 0.1,
    quantile == "Q75" ~ n
  ),
  category = case_when(
    category == "ecn_dev" ~ "Economic development",
    category == "environment" ~ "Environment",
    category == "fiscal" ~ "Fiscality",
    category == "health" ~ "Health system",
    category == "housing" ~ "Housing",
    category == "social" ~ "Social issues"
  ))

df_n_chars_by_mp %>% 
  filter(category %in% c("ecn_dev", "social", "environment", "health", "fiscal", "housing")) %>%
  mutate(category = case_when(
    category == "ecn_dev" ~ "Economic development",
    category == "environment" ~ "Environment",
    category == "fiscal" ~ "Fiscality",
    category == "health" ~ "Health system",
    category == "housing" ~ "Housing",
    category == "social" ~ "Social issues"
  )) %>% 
  ggplot(aes(x = n, y = gpt_model)) +
  ggridges::geom_density_ridges(aes(group = gpt_model), bandwidth = 0.3,
                                scale = 0.95, color = "black", fill = "grey95",
                                size = 0.1) +
  facet_wrap(~category) +
  geom_segment(x = -0.21, xend = -0.21, y = 0, yend = 5, color = "grey30",
               linewidth = 0.05) +
  geom_segment(data = quantiles_graph, aes(x = n, xend = n,
                                     y = as.numeric(factor(gpt_model)), yend = as.numeric(factor(gpt_model))+0.25,
                                     linetype = quantile),
               linewidth = 0.25) +
  scale_linetype_manual(values = c("Q25" = "dotted", "Q50" = "dashed", "Q75" = "solid")) +
  coord_cartesian(xlim = c(-0.2125, 10.2125)) +
  scale_x_continuous(expand = c(0,0),
                     breaks = 0:10) +
  scale_y_discrete(labels = c("gpt_4turbo" = "gpt-4-0125-preview",
                              "gpt_4" = "gpt-4",
                              "gpt_35" = "gpt-3.5-turbo")) +
  xlab("\nNumber of Characteristics per Category\nAssigned to Each MP") +
  ylab("") +
  clessnverse::theme_clean_light() +
  theme(panel.background = element_rect(fill = NA, color = "black",
                                        linewidth = 0.2),
        axis.title.x = element_text(hjust = 0.5))

ggsave("graphs/graph1.png",
       width = 12, height = 9)
