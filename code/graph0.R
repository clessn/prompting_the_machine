#### distribution des ~20 enjeux

# Packages ----------------------------------------------------------------
library(dplyr)
library(ggplot2)

# Data --------------------------------------------------------------------
data <- readRDS("data/data_after_dict_analysis.rds")

category_names <- c("culture" = "Culture", 
                    "democracy" = "Democracy", 
                    "ecn_dev" = "Economic\nDevelopment", 
                    "education" = "Education", 
                    "environment" = "Environment", 
                    "firstnations" = "First Nations", 
                    "fiscal" = "Fiscal", 
                    "health" = "Health", 
                    "housing" = "Housing", 
                    "immigration" = "Immigration", 
                    "infrastructure" = "Infrastructure", 
                    "justice" = "Justice", 
                    "military" = "Military", 
                    "rural" = "Rural", 
                    "social" = "Social Issues")

data %>% 
  group_by(category) %>% 
  summarise(n = sum(issue_used_by_model)) %>% 
  ggplot(aes(x = reorder(category, -n), y = n)) +
  geom_col(fill = "grey40", alpha = 0.7, color = NA) +
  clessnverse::theme_clean_light() +
  scale_x_discrete(labels = category_names) +
  xlab("") +
  ylab("Number of Characteristics\n") +
  theme(axis.text.x = element_text(angle = 90, size = 12,
                                   hjust = 1, vjust = 0.5),
        axis.title.y = element_text(hjust = 0.5, size = 15))

ggsave("data/graphs/graph0.png",
       width = 10, height = 6.5)  
