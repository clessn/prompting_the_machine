import pandas as pd
import openai
import os
import csv
from dotenv import load_dotenv

load_dotenv(dotenv_path=".env")

openai.api_key = os.environ["OPENAI_API_KEY"]

model_engine = "text-davinci-003"
parameters = {
    "temperature": 1.0,
    "max_tokens": 1000,
    "top_p": 1,
    "frequency_penalty": 0,
    "presence_penalty": 0,
}

input_filename = "data/mp_datasets/mp_dataset.csv"
output_filename = "data/outputs/key_characteristics.csv"

# Read the names from the CSV file
data_mp = pd.read_csv("data/mp_datasets/mp_dataset.csv")
mp_ids = data_mp["mp_id"]
mp_ids = mp_ids.tolist()
names = data_mp["name"]
names = names.tolist()

# Generate and save outputs for each MP name
df_output = pd.DataFrame(columns=["mp_id", "name", "characteristics"])

# Create empty csv

# Code to associate MP to "Canadian" or "Quebecois" MP/MNA in prompt
for i in range(0, len(mp_ids)):
    mp_idi = mp_ids[i]
    namei = names[i]
    df_output.drop(df_output.index, inplace=True)  # Clear the content of df_output

    prompt_template = "Provide a list of 10 key characteristics describing Canada MP [INSERT_NAME]'s policies formatted in a .csv style output, all on the same line. (ex: MP name, Characteristic 1, characteristic 2, characteristic 3, characteristic 4, characteristic 5, characteristic 6, characteristic 7, characteristic 8, characteristic 9, characteristic 10,)"
    prompt = prompt_template.replace("[INSERT_NAME]", namei)

    try:
        response = openai.Completion.create(engine=model_engine, prompt=prompt, **parameters)
        generated_text = response.choices[0].text.strip()

        df_output = pd.concat([df_output, pd.DataFrame({"mp_id": [mp_idi], "name": [namei], "characteristics": [generated_text]})], ignore_index=True)

        # Append DataFrame to CSV starting from row 2
        if i == 0:
            # Write header for the first iteration
            df_output.to_csv(output_filename, mode='a', index=False)
        else:
            # Skip header starting from the second iteration
            df_output.to_csv(output_filename, mode='a', index=False, header=False)

        print(df_output)
    except Exception as e:
        print("oups at mp_id" + mp_idi + "-" + namei)
