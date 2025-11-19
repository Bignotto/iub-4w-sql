import json
import re

with open(r'c:/Users/bigno/Projects/iub-4w-sql/clientes/export clientes.json', encoding='utf-8') as f:
    data = json.load(f)

new_data = []
for entry in data:
    if isinstance(entry, dict):
        new_entry = {}
        for k, v in entry.items():
            if isinstance(v, str):
                v = v.strip()
            new_entry[k] = v
        # Process logradouro
        logradouro = new_entry.get('logradouro')
        if logradouro:
            match = re.search(r'^(.*?)(?:,|\s)(\d+)(\D|$)', logradouro)
            if match:
                new_entry['logradouro'] = match.group(1).strip()
                new_entry['numero'] = int(match.group(2))
            else:
                # Try to find number at the end
                match2 = re.search(r'^(.*?)(\d+)$', logradouro)
                if match2:
                    new_entry['logradouro'] = match2.group(1).strip()
                    new_entry['numero'] = int(match2.group(2))
                else:
                    new_entry['logradouro'] = logradouro.strip()
        new_data.append(new_entry)
    elif isinstance(entry, str):
        new_data.append(entry.strip())

with open(r'c:/Users/bigno/Projects/iub-4w-sql/clientes/export clientes.json', 'w', encoding='utf-8') as f:
    json.dump(new_data, f, ensure_ascii=False, indent=2)
