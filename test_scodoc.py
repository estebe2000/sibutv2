import requests
import json
import sys
import urllib3

# Désactiver les avertissements SSL
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# === CONFIGURATION ===
SCODOC_URL = "https://scodoc.univ-lehavre.fr"
USERNAME = "pytels"
PASSWORD = "27041978"

def get_token():
    """Authentification et récupération du token JWT"""
    url = f"{SCODOC_URL}/ScoDoc/api/tokens"
    payload = {"username": USERNAME, "password": PASSWORD}
    
    try:
        response = requests.post(url, json=payload, verify=False)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"❌ Erreur d'authentification : {e}")
        sys.exit(1)

def get_headers(token):
    token_str = token if isinstance(token, str) else token.get('token')
    return {"Authorization": f"Bearer {token_str}", "Content-Type": "application/json"}

def list_departments(headers):
    url = f"{SCODOC_URL}/ScoDoc/api/departements_list"
    resp = requests.get(url, headers=headers, verify=False)
    return resp.json()

def list_semesters(headers, dept_id):
    url = f"{SCODOC_URL}/ScoDoc/api/formsemestres_query"
    params = {"dept_id": dept_id} 
    resp = requests.get(url, headers=headers, params=params, verify=False)
    return resp.json()

def list_students(headers, formsemestre_id):
    url = f"{SCODOC_URL}/ScoDoc/api/etudiants"
    params = {"formsemestre_id": formsemestre_id}
    resp = requests.get(url, headers=headers, params=params, verify=False)
    return resp.json()

def main():
    print(f"🔍 Connexion à {SCODOC_URL}...")
    token = get_token()
    print("✅ Authentification réussie.")
    headers = get_headers(token)

    depts = list_departments(headers)
    print(f"\n📂 Départements trouvés : {len(depts)}")
    
    tc_dept = None
    for d in depts:
        name = d.get('acronym', d.get('nom', 'Inconnu'))
        print(f" - {name} (ID: {d.get('id')})")
        if name == 'TC':
            tc_dept = d

    if not tc_dept and depts:
        tc_dept = depts[0]
        print(f"⚠️ Département TC non trouvé par nom. Utilisation de {tc_dept.get('acronym')} par défaut.")

    if tc_dept:
        print(f"\n👉 Exploration du département : {tc_dept.get('acronym')}")
        semesters = list_semesters(headers, tc_dept['id'])
        print(f"📅 Semestres trouvés : {len(semesters)}")
        
        if semesters:
            # On prend le dernier (souvent le plus récent)
            current_semester = semesters[-1] 
            print(f"   Dernier semestre : {current_semester.get('titre')} (ID: {current_semester.get('formsemestre_id')})")
            
            sem_id = current_semester.get('formsemestre_id')
            students = list_students(headers, sem_id)
            print(f"\n🎓 Étudiants inscrits : {len(students)}")
            for s in students[:10]:
                print(f" - {s.get('nom')} {s.get('prenom')} ({s.get('nip')})")
            if len(students) > 10:
                print("   ...")

if __name__ == "__main__":
    main()