import urllib.request
import json
import time

API_KEY = "458T7VQ-MMWMT2K-QC0CAXF-0Q1GVFM"
BASE_URL = "http://localhost:3001/api/v1"
HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

def ask_question(workspace, question):
    url = f"{BASE_URL}/workspace/{workspace}/chat"
    data = {"message": question, "mode": "chat"}
    req = urllib.request.Request(url, method="POST", headers=HEADERS)
    req.data = json.dumps(data).encode('utf-8')
    try:
        with urllib.request.urlopen(req) as response:
            res = json.loads(response.read().decode('utf-8'))
            return res.get('textResponse', 'Pas de réponse')
    except Exception as e:
        return f"Erreur: {e}"

questions = [
    ("skills-hub", "Qui est Steeve Pytel ? Donne son rôle et ses responsabilités."),
    ("skills-hub", "Qui est Mickaël Millet et quel est son poste ?"),
    ("skills-hub", "Qui est le responsable (OWNER) du cours R1.13 ?"),
    ("skills-hub", "Qui est Caroline Milcent Montier ?"),
    ("skills-hub", "Quels enseignants interviennent sur la SAE 5.MDEE.01 ?"),
    ("skills-hub", "Quel est l'email et l'identifiant LDAP de Steeve Pytel ?"),
    ("skills-hub", "Qui est le tuteur du groupe étudiant 'tc' ?"),
    ("skills-hub", "Qui est responsable de l'activité SAE 1.01 ?"),
    ("skills-hub", "Quelles sont les responsabilités de Thierry Tabellion ?"),
    ("skills-hub", "Qui intervient sur la ressource R2.01 ?"),
    ("dev-space", "Quel est le titre et le volume horaire du cours R1.13 ?"),
    ("dev-space", "Quelles sont les compétences ciblées par la ressource R2.10 ?"),
    ("dev-space", "Quel est le descriptif détaillé de la SAE 4.01 ?"),
    ("dev-space", "Quels sont les mots-clés associés au cours R3.14 ?"),
    ("dev-space", "Propose une idée de TP pour le cours R2.13 (Ressources et culture numériques - 2)."),
    ("dev-space", "Quel est le contenu complet du cours R5.BDMRC.13 (Marketing des services) ?"),
    ("dev-space", "Quelles sont les ressources associées à la SAE 1.03 ?"),
    ("dev-space", "Quels sont les objectifs de la SAE 3.01 ?"),
    ("dev-space", "Décris le contenu du cours R5.SME.12 (Marketing digital de la marque)."),
    ("dev-space", "Que fait-on dans le cours R3.05 (Environnement économique international) ?")
]

print("=== DEBUT DE LA BATTERIE DE TESTS RAG (20 QUESTIONS) ===")
print("")

for i, (workspace, q) in enumerate(questions, 1):
    print(f"[{i}/20] ({workspace}) Question : {q}")
    reponse = ask_question(workspace, q)
    print(f"--> Reponse : {reponse.strip()}")
    print("-" * 80)
    time.sleep(0.5)

print("=== FIN DES TESTS ===")
