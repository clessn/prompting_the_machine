# Packages ----------------------------------------------------------------
library(dplyr)
library(ggplot2)

# Data --------------------------------------------------------------------
data <- readRDS("_SharedFolder_article_vaa_llm_bias/data/data_after_dict_analysis.rds")

# Wrangling ---------------------------------------------------------------

df_prop_party <- data %>% 
  group_by(mp_id, level, gpt_model, party, category) %>% 
  summarise(n = sum(issue_used_by_model)) %>% 
  filter(category %in% c("ecn_dev", "social", "environment", "health", "fiscal", "housing")) %>% 
  mutate(category = case_when(
    category == "ecn_dev" ~ "Economic development",
    category == "environment" ~ "Environment",
    category == "fiscal" ~ "Fiscality",
    category == "health" ~ "Health system",
    category == "housing" ~ "Housing",
    category == "social" ~ "Social issues"
  )) %>% 
  group_by(party, level, gpt_model, category) %>% 
  summarise(nparty = sum(n)) %>% 
  group_by(party, level, gpt_model) %>% 
  mutate(ntotal = sum(nparty),
         prop = nparty / ntotal)



# Function of plot --------------------------------------------------------

graph <- function(data){
  plot <- ggplot(data, aes(x = party, y = prop * 100)) +
    lemon::facet_rep_wrap(~category,
                          repeat.tick.labels = "x") +
    geom_point(aes(color = gpt_model),
               position = position_dodge(width = 0.5)) +
    scale_color_grey(labels = c("gpt_4turbo" = "gpt-4-0125-preview",
                                "gpt_4" = "gpt-4",
                                "gpt_35" = "gpt-3.5-turbo"),
                     start = 0.8, end = 0.2) +
    scale_y_continuous(limits = c(0, 60)) +
    xlab("") +
    ylab("Proportion of Characteristics Related\nto Category by Party (%)\n") +
    clessnverse::theme_clean_light() +
    theme(axis.title.y = element_text(hjust = 0.5))
  return(plot)
}

# Fed ---------------------------------------------------------------------

colors <- c("PLC" = "#D71B1E", "PCC" = "#142E52", "NPD" = "#F58220", "BQ" = "#87CEFA", "PVC" = "#3D9B35")

df_prop_party %>% 
  filter(level == "fed" &
           !(party %in% c("Ind", "PVC"))) %>%
  ggplot(aes(x = gpt_model, y = prop)) +
  facet_grid(rows = vars(party),
             cols = vars(category)) +
  geom_bar(stat = "identity",
           aes(fill = party),
           alpha = 0.75, color = NA) +
  scale_fill_manual(values = colors) +
  clessnverse::theme_clean_light()


df_prop_party %>% 
  filter(level == "fed" &
           !(party %in% c("Ind", "PVC"))) %>%
  mutate(party = factor(party, levels = c("PLC", "PCC", "BQ", "NPD"))) %>% 
  graph(.) +
  scale_x_discrete(labels = c("PLC" = "LPC",
                              "PCC" = "CPC",
                              "BQ" = "BQ",
                              "NPD" = "NDP"),
                   breaks = c("PLC", "PCC", "BQ", "NPD"))
ggsave("_SharedFolder_article_vaa_llm_bias/graphs/graph2_fed.png",
       width = 10, height = 6.5)

# Prov --------------------------------------------------------------------

df_prop_party %>% 
  filter(level == "prov") %>%
  ggplot(aes(x = gpt_model, y = prop)) +
  facet_grid(rows = vars(party),
             cols = vars(category)) +
  geom_bar(stat = "identity",
           aes(fill = party),
           alpha = 0.75, color = NA) +
  scale_fill_manual(values = potgrowth::qc_party_colors) +
  clessnverse::theme_clean_light()

df_prop_party %>% 
  filter(level == "prov") %>%
  mutate(party = factor(party, levels = c("CAQ", "PLQ", "QS", "PQ"))) %>% 
  graph(.) +
  scale_x_discrete(labels = c("CAQ" = "CAQ",
                              "PLQ" = "QLP",
                              "PQ" = "PQ",
                              "QS" = "QS"))
ggsave("_SharedFolder_article_vaa_llm_bias/graphs/graph2_prov.png",
       width = 10, height = 6.5)

