import urllib.request
import json
import sys

url = "http://localhost:3000/api/chat/completions"
token = "sk-da348dc9-e137-4832-a197-9474ffb4f82d"

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

data = {
    "model": "mistral-pedago:latest",
    "messages": [
        {"role": "user", "content": "Quels sont les détails du cours R1.13 ? Utilise tes outils pour chercher dans la base de données."}
    ],
    # Open-WebUI specific extension to inject the tool we created in the DB
    "tool_ids": ["course_finder", "but_tc_super_assistant"]
}

req = urllib.request.Request(url, method="POST", headers=headers)
req.data = json.dumps(data).encode("utf-8")

try:
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode("utf-8"))
        print(res["choices"][0]["message"]["content"])
except urllib.error.HTTPError as e:
    print(f"Erreur HTTP {e.code}: {e.read().decode('utf-8')}")
except Exception as e:
    print(f"Erreur: {e}")
