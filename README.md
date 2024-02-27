
# GPT-Prompted Data Generation and Bias Evaluation Script

This R script is designed for social scientists and researchers interested in generating data using GPT models and evaluating algorithmic biases. The script prompts multiple GPT models with predefined messages and stores their responses for further analysis.

## Getting Started

### Prerequisites

Before you can use this script, you need to have the following installed:
- R (version 3.6.0 or later)
- RStudio (recommended for ease of use)
- The following R packages: `jsonlite`, `httr`, `openai` (for interfacing with the GPT models)

You can install the required R packages using the following commands in R or RStudio:

```r
install.packages("jsonlite")
install.packages("httr")
install.packages("openai")
```

### Setup

1. Clone or download this repository to your local machine.
2. Open the script in RStudio or your preferred R environment.
3. Ensure you have API access to the GPT models you intend to use (e.g., GPT-3.5-turbo, GPT-4). You will need to set up an API key from OpenAI and configure it within the script or as an environment variable. To do so, you can use the `edit_r_environ()` function from `usethis` package. `install.packages("usethis")`, then `usethis::edit_r_environ()`. Here you can put the API key in the following format: `OPENAI_API_KEY=api_key_without_quotation_marks`, save the file than restart R.
   
## Usage

The script is structured to be straightforward and customizable according to your needs. Here's a step-by-step guide on how to use it:

### Load the Data

The script starts by loading your data frame from an RDS file. Ensure your data file is correctly placed in the specified path.

```r
data_mps <- readRDS("data/data_mps.rds")
```

### Configuration

- **Models to Prompt:** Specify the GPT models you want to use. The script will iterate over each model and prompt it with the same message.

    ```r
    models <- c("gpt-3.5-turbo", "gpt-4", "gpt-4-0125-preview")
    ```

- **Prompt Subject:** Define the subject of the prompt (e.g., ideology, policies). This is crucial for extracting the relevant content from the model's output.

    ```r
    prompt_subject <- "characteristics"
    ```

- **Save Interval:** Set the frequency of saving the data frame to avoid data loss during long operations.

    ```r
    save_interval <- 100
    ```

- **Column and Trial Configuration:** Define the number of columns needed to store the output and the number of trials for each prompt.

    ```r
    column_needed <- 10
    number_of_trials <- 10
    ```

### Running the Script

Execute the script by pressing the Run button in RStudio or `ctrl+enter`

The script will loop through each specified model, prompting it and storing the generated content in new columns within your data frame.

### Saving the Data

The updated data frame will be saved automatically at intervals defined by `save_interval` and at the end of the script's execution.

## Customization

Feel free to adjust the script parameters according to your research needs. You can modify the prompt messages, the models used, and other configurations to suit your specific requirements.

## Troubleshooting

- **API Limitations:** Ensure you are aware of the API usage limits for the GPT models you are using to avoid interruptions.
- **Data Frame Structure:** Make sure your data frame is correctly structured and matches the expected format the script operates on.
- **Dependency Issues:** If you encounter issues with package dependencies, try updating your R and the packages to the latest versions.

## Contributing

Your contributions are welcome! If you have suggestions for improving this script or have developed additional features, please feel free to fork the repository, make your changes, and submit a pull request.

## Acknowledgments

- OpenAI for providing access to the GPT models.
- The R community for the comprehensive set of packages that make projects like this possible.

Thank you for using this script. We hope it assists you in your research endeavors!
