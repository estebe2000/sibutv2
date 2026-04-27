from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from typing import Any, Dict, List
import requests
import urllib3
import logging

# Désactiver les alertes liées au certificat SSL non vérifié
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Configuration de base
SCODOC_BASE_URL = "https://scodoc.univ-lehavre.fr"
API_BASE_URL = f"{SCODOC_BASE_URL}/ScoDoc/api"
USERNAME = "projet"
PASSWORD = "steeve"

app = FastAPI(title="Relais API ScoDoc", version="1.6.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logger = logging.getLogger("uvicorn.error")
current_token = None

def get_token():
    global current_token
    token_url = f"{API_BASE_URL}/tokens"
    try:
        response = requests.post(token_url, auth=(USERNAME, PASSWORD), verify=False, timeout=30)
        response.raise_for_status()
        current_token = response.json().get("token")
        return current_token
    except Exception as e:
        logger.error(f"Erreur token: {e}")
        return None

def fetch_scodoc_api(endpoint: str, params: dict = None):
    global current_token
    if not current_token: get_token()
    if not current_token: return None
    url = f"{API_BASE_URL}/{endpoint.lstrip('/')}"
    headers = {"Authorization": f"Bearer {current_token}"}
    try:
        res = requests.get(url, headers=headers, params=params, verify=False, timeout=30)
        if res.status_code == 401:
            get_token()
            headers = {"Authorization": f"Bearer {current_token}"}
            res = requests.get(url, headers=headers, params=params, verify=False, timeout=30)
        res.raise_for_status()
        return res.json()
    except Exception as e:
        logger.error(f"Erreur API {endpoint}: {e}")
        return None

def get_but_level(title: str) -> str:
    t = title.lower()
    if "semestre 1" in t or "semestre 2" in t: return "BUT1"
    if "semestre 3" in t or "semestre 4" in t: return "BUT2"
    if "semestre 5" in t or "semestre 6" in t: return "BUT3"
    return None

def get_enriched_hierarchy():
    semestres = fetch_scodoc_api("/departement/TC/formsemestres_courants")
    if not semestres: return {}

    but_structure = {
        "BUT1": {"FI": {}, "FA": {}},
        "BUT2": {"FI": {}, "FA": {}},
        "BUT3": {"FI": {}, "FA": {}}
    }

    # Partitions à ignorer pour éviter de gonfler les effectifs
    IGNORE_PARTITIONS = ["TOUS LES ÉTUDIANTS", "LISTE", "AMPHI", "SANS GROUPE", "DÉFAUT", "ENSEIGNANTS"]

    for sem in semestres:
        fid = sem.get('formsemestre_id')
        title = sem.get('titre_num', '')
        level = get_but_level(title)
        if not level: continue 

        # --- DÉTECTION FI / FA ROBUSTE ---
        f_type = "FI"
        if level != "BUT1":
            prog = fetch_scodoc_api(f"/formsemestre/{fid}/programme")
            if prog and isinstance(prog, dict):
                ressources = prog.get('ressources', [])
                codes = [r.get('module', {}).get('code', '') for r in ressources if r.get('module')]
                # On ne passe en FA que si PLUS DE LA MOITIÉ des modules finissent par A
                a_count = len([c for c in codes if c.endswith('A')])
                if len(codes) > 0 and (a_count / len(codes)) > 0.5:
                    f_type = "FA"
                    logger.info(f"Semestre {fid} ({level}) confirmé en ALTERNANCE ({a_count}/{len(codes)} modules 'A').")

        students_map = {}
        partitions = fetch_scodoc_api(f"/formsemestre/{fid}/partitions")
        if not isinstance(partitions, dict): continue

        for p_id, part in partitions.items():
            p_name = part.get('partition_name', '').upper()
            if any(x in p_name for x in IGNORE_PARTITIONS): continue

            groups = part.get('groups', {})
            for g_id, g in groups.items():
                g_name = g.get('group_name', 'Inconnu')
                etudiants = fetch_scodoc_api(f"/group/{g_id}/etudiants")
                if not etudiants: continue
                
                for s in etudiants:
                    sid = s.get('id')
                    if sid not in students_map:
                        students_map[sid] = {
                            "id": sid, "nom": s.get('nom', '').upper(), "prenom": s.get('prenom', ''),
                            "nip": s.get('code_nip', ''), "email": s.get('email', ''),
                            "td_group": "N/A", "parcours": "N/A", "langue": "N/A", "alerts": []
                        }
                    
                    if "PARCOURS" in p_name: students_map[sid]["parcours"] = g_name
                    elif "LANGUE" in p_name or "LV" in p_name: students_map[sid]["langue"] = g_name
                    elif "GROUPE" in p_name or "TD" in p_name or "TP" in p_name:
                        students_map[sid]["td_group"] = g_name

        for s in students_map.values():
            if s["langue"] == "N/A": s["alerts"].append("❌ Langue manquante")
            if level != "BUT1" and s["parcours"] == "N/A": s["alerts"].append("🚩 Parcours manquant")

            # RANGEMENT : On utilise le Groupe TD (GR.1, Apprentis...) comme clé de regroupement
            # Si pas de TD, on prend le parcours.
            grp = s["td_group"] if s["td_group"] != "N/A" else (s["parcours"] if s["parcours"] != "N/A" else "SANS GROUPE")

            if grp not in but_structure[level][f_type]:
                but_structure[level][f_type][grp] = []
            but_structure[level][f_type][grp].append(s)


    return but_structure

@app.get("/api/hierarchie")
def api_hierarchie(): return get_enriched_hierarchy()

@app.get("/api/ressources")
def api_ressources():
    # On se concentre uniquement sur ce qui est disponible maintenant (S2, S4, S6)
    semestres = fetch_scodoc_api("/departement/TC/formsemestres_courants")
    if not semestres: return []
    
    resources_map = {}
    for sem in semestres:
        fid = sem.get('formsemestre_id')
        prog = fetch_scodoc_api(f"/formsemestre/{fid}/programme")
        if not prog or not isinstance(prog, dict): continue
        
        for r in prog.get('ressources', []):
            mod = r.get('module')
            if not mod: continue
            
            raw_code = mod.get('code')
            if not raw_code: continue
            
            # Normalisation stricte (BTCR101 -> R1.01)
            code = raw_code.replace('BTC', '')
            # Si on a R101, on transforme en R1.01
            if len(code) >= 3 and code[0] in ['R', 'S'] and code[1].isdigit() and '.' not in code:
                code = f"{code[0]}{code[1]}.{code[2:]}"
            
            # On ne garde que les codes bien formés (ex: R1.01)
            if not (len(code) >= 5 and code[0] in ['R', 'S'] and '.' in code):
                continue
            
            resources_map[code] = {
                "code": code,
                "raw_code": raw_code,
                "titre": mod.get('titre'),
                "responsable": r.get('responsable_id')
            }
            
    return list(resources_map.values())

@app.get("/demo", response_class=HTMLResponse)
def demo_view():
    data = get_enriched_hierarchy()
    html_content = """
    <!DOCTYPE html>
    <html lang="fr">
    <head>
        <meta charset="utf-8">
        <title>Audit ScoDoc Final</title>
        <style>
            body { font-family: 'Segoe UI', sans-serif; background: #edf2f7; padding: 20px; }
            .level-card { margin-bottom: 30px; border-radius: 12px; overflow: hidden; background: #fff; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
            .level-title { background: #1a202c; color: white; padding: 15px 25px; margin: 0; }
            .type-container { padding: 20px; border-bottom: 1px solid #e2e8f0; }
            .type-fi { border-left: 10px solid #4299e1; background: #f8fafc; }
            .type-fa { border-left: 10px solid #f6ad55; background: #fffaf0; }
            .type-label { font-weight: 800; text-transform: uppercase; margin-bottom: 15px; display: block; }
            .group-section { margin-bottom: 10px; border: 1px solid #e2e8f0; border-radius: 6px; background: white; }
            .group-header { background: #f7fafc; padding: 8px 15px; font-weight: bold; cursor: pointer; display: flex; justify-content: space-between; }
            table { width: 100%; border-collapse: collapse; font-size: 0.85em; }
            th { text-align: left; padding: 10px; background: #f1f5f9; color: #4a5568; }
            td { padding: 8px 12px; border-bottom: 1px solid #edf2f7; }
            .badge { padding: 2px 8px; border-radius: 12px; font-size: 0.75em; font-weight: bold; }
            .badge-p { background: #c6f6d5; color: #22543d; }
            .badge-l { background: #e9d8fd; color: #553c9a; }
            .alert { color: #e53e3e; font-weight: bold; }
        </style>
    </head>
    <body>
        <h1>🎓 Dispatching ScoDoc (BUT1, 2, 3)</h1>
    """
    for level in ["BUT1", "BUT2", "BUT3"]:
        html_content += f"<div class='level-card'><h2 class='level-title'>{level}</h2>"
        for f_type in ["FI", "FA"]:
            groups = data[level][f_type]
            if not groups: continue
            t_class = "type-fi" if f_type == "FI" else "type-fa"
            label = "Formation Initiale" if f_type == "FI" else "Alternance (Codes 'A')"
            html_content += f"<div class='type-container {t_class}'><span class='type-label'>{label}</span>"
            for grp_name, students in groups.items():
                html_content += f"<details class='group-section' open><summary class='group-header'><span>📦 {grp_name}</span><span>{len(students)} étudiants</span></summary><table>"
                html_content += "<thead><tr><th>NIP</th><th>Nom Prénom</th><th>Parcours</th><th>Langue</th><th>Alertes</th></tr></thead><tbody>"
                for s in sorted(students, key=lambda x: x['nom']):
                    html_content += f"<tr><td>{s['nip']}</td><td><b>{s['nom']}</b> {s['prenom']}</td>"
                    html_content += f"<td><span class='badge badge-p'>{s['parcours']}</span></td><td><span class='badge badge-l'>{s['langue']}</span></td>"
                    html_content += f"<td class='alert'>{' '.join(s['alerts'])}</td></tr>"
                html_content += "</tbody></table></details>"
            html_content += "</div>"
        html_content += "</div>"
    return html_content + "</body></html>"

@app.get("/{path:path}")
def proxy_scodoc(path: str, request: Request):
    if not path or path == "favicon.ico": return {"status": "ok"}
    # Si le path commence par 'api/', on le nettoie car fetch_scodoc_api rajoute déjà /api
    clean_path = path[4:] if path.startswith("api/") else path
    return fetch_scodoc_api(clean_path, params=dict(request.query_params))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
