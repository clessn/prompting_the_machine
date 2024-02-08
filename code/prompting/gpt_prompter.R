library(openai)
library(dplyr)
library(ggplot2)

data_mps <- readRDS("_SharedFolder_article_vaa_llm_bias/data/data_mps.rds")

library(openai)
library(dplyr)
library(ggplot2)

data_mps <- readRDS("_SharedFolder_article_vaa_llm_bias/data/data_mps.rds")

# List of models you want to prompt
models <- c("gpt-4", "gpt-4-1106-preview")

save_interval <- 100 # Save every 100 iterations you can modify it to your needs

for (model_name in models) {
  
  # Dynamically create column names based on the model name
  char_cols <- paste0(model_name, "_char", 1:10)
  data_mps[char_cols] <- NA  # Initialize new columns for this model

  for (i in 1:nrow(data_mps)) {
    success <- FALSE  # Initialize success flag
    attempts <- 0  # Initialize attempts counter

    while (!success && attempts < 10) {  # Try up to 10 times
      chat_prompt <- create_chat_completion(
        model = model_name,  # Use the current model in the loop
        messages = list(
            list(
              "role" = "system",
              "content" = "You are a political analyst who needs to analyze the characteristics of a politician's policies. You have been asked to provide a JSON output for the characteristics of a politician's policies."),
            list(
              "role" = "user",
              "content" = "Provide a list of 10 key characteristics describing John Doe's policies from party X formatted in JSON."
            ),
            list(
              "role" = "system",
              "content" = "{'Name': 'John Doe', 'Characteristics': ['Pro-environment', 'Supports renewable energy', 'Advocates for education reform', 'Pro-healthcare reform', 'Anti-corruption', 'Economic growth focus', 'Supports tax reform', 'Pro-immigration reform', 'National security emphasis', 'Supports digital privacy']}"
            ),    
            list(
              "role" = "user",
              "content" = paste0("Based on the example provided, now provide a list of 10 key characteristics describing ", paste0(data_mps$position[i]), " ", paste0(data_mps$name[i]), "'s policies formatted in a JSON structure.")
            )
          )
      )

      print(paste(i, "of", nrow(data_mps), ", model: ", model_name, ", attempt ", attempts + 1))

      # Assuming 'output' contains the JSON response from the API
      output <- chat_prompt$choices$message.content

      # Attempt to fix and parse the JSON
      output_fixed <- gsub("([^\\\\])'", "\\1\\\\'", output)  # Escape single quotes not preceded by a backslash
      output_fixed <- gsub("([{,\\s])([a-zA-Z0-9_]+):", "\\1\"\\2\":", output_fixed)  # Ensure keys are properly quoted

      parsed_output <- tryCatch({
        fromJSON(output_fixed)
      }, error = function(e) {
        NULL
      })

      if (!is.null(parsed_output)) {
        characteristics <- parsed_output$Characteristics
        # Assign each characteristic to the corresponding column for the current row
        data_mps[i, char_cols] <- characteristics[1:10]
        success <- TRUE  # Parsing succeeded
      } else {
        message("Failed to parse JSON for row: ", i, " on attempt ", attempts + 1, " using model ", model_name)
        attempts <- attempts + 1  # Increment attempts counter
        if (attempts < 10) {
          Sys.sleep(1)  # Short delay before retrying
        }
      }
    }

    if (!success) {
      # Handle the case where all attempts failed, e.g., assign NA or some default value
      data_mps[i, char_cols] <- NA
      message("All attempts failed for row: ", i, " using model ", model_name)
    }
    print(characteristics)
    # Delay to avoid hitting rate limits
    Sys.sleep(1)

    if (i %% save_interval == 0) {
    saveRDS(data_mps, paste0("_SharedFolder_article_vaa_llm_bias/data/data_mps_checkpoint_", i, ".rds"))
    cat("Data saved at iteration", i, "\n")
  }
}
}
# Save the updated dataframe
saveRDS(data_mps, "_SharedFolder_article_vaa_llm_bias/data/data_mps_updated.rds")