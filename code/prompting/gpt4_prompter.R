library(openai)
library(dplyr)
library(ggplot2)

data_mps <- readRDS("_SharedFolder_article_vaa_llm_bias/data/data_mps.rds")

data_mps$gpt_4_chars <- NA

for (i in 1:nrow(data_mps)) {
        chat_prompt <- create_chat_completion(
            model = "gpt-4",
            messages = list(
                list(
                    "role" = "system",
                    "content" = "You are a helpful assistant"
                ),
                list(
                    "role" = "user",
                    "content" = paste0("Provide a list of 10 key characteristics describing ", paste0(data_mps$position[i])," ", paste0(data_mps$name[i]), "'s policies formatted in a .csv style output, all on the same line. (ex: MP name, Characteristic 1, characteristic 2, characteristic 3, characteristic 4, characteristic 5, characteristic 6, characteristic 7, characteristic 8, characteristic 9, characteristic 10,)")
                )
            )
        )
        print(paste(i, "of", nrow(data_mps)))
        print(chat_prompt$choices$message.content)
        data_mps$gpt_4_chars[i] <- chat_prompt$choices$message.content
        # Delay to avoid hitting rate limits
        Sys.sleep(2)
}

saveRDS(data_mps, "_SharedFolder_article_vaa_llm_bias/data/data_mps.rds")