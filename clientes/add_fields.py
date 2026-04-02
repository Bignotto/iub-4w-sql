import json

# Path to your JSON file
json_path = r"c:\\Users\\Thiago\\Projects\\iub-4w-sql\\clientes\\export clientes.json"

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

for item in data:
    item['origem'] = "Base Bignotto"
    item['tag1'] = "IUB"
    item['recompra'] = 20

with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
