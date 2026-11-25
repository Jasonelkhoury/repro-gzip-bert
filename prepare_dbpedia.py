
import os
from datasets import load_dataset

# Destination des données
DATA_DIR = "/workspace/data/DBpedia"
os.makedirs(DATA_DIR, exist_ok=True)

print("=== Downloading DBpedia from Hugging Face ===")

dataset = load_dataset("fancyzhx/dbpedia_14")

for split in ["train", "test"]:
    output_file = os.path.join(DATA_DIR, f"{split}.txt")

    print(f"Generating {output_file} ...")

    with open(output_file, "w", encoding="utf-8") as f:
        for row in dataset[split]:
            # Hugging Face labels: 0 to 13
            label = row["label"] + 1

            # Combine title and content
            text = row["title"] + ". " + row["content"]

            # Keep one example per line
            text = (
                text.replace("\t", " ")
                    .replace("\n", " ")
                    .replace("\r", " ")
            )

            f.write(f"{label}\t{text}\n")

    print(f"{split}: {len(dataset[split])} examples generated")

print("\n=== DBpedia successfully prepared ===")
print(f"Dataset directory: {DATA_DIR}")
print("Classes: 14")
