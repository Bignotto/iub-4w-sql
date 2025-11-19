import json
import csv

json_path = r"c:\Users\bigno\Projects\iub-4w-sql\clientes\export clientes.json"
csv_path = r"c:\Users\bigno\Projects\iub-4w-sql\clientes\export clientes.csv"

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Get all possible keys (columns)
all_keys = set()
for item in data:
    all_keys.update(item.keys())
all_keys = list(all_keys)

with open(csv_path, 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=all_keys, delimiter=';')
    writer.writeheader()
    for item in data:
        writer.writerow(item)
