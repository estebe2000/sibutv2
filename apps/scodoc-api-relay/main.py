from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from typing import Any
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

app = FastAPI(title="Relais API ScoDoc", version="1.5.0")

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
        response = requests.post(token_url, auth=(USERNAME, PASSWORD), verify=False, timeout=10)
        response.raise_for_status()
        current_token = response.json().get("token")
        return current_token
    except Exception as e:
        logger.error(f"Erreur token: {e}")
        return None

def fetch_scodoc_api(endpoint: str, params: dict = None):
    global current_token
    if not current_token: get_token()
    if not current_token: raise HTTPException(status_code=500, detail="Pas de token")

    url = f"{API_BASE_URL}/{endpoint.lstrip('/')}"
    headers = {"Authorization": f"Bearer {current_token}"}
    
    try:
        res = requests.get(url, headers=headers, params=params, verify=False, timeout=15)
        if res.status_code == 401:
            get_token()
            headers = {"Authorization": f"Bearer {current_token}"}
            res = requests.get(url, headers=headers, params=params, verify=False, timeout=15)
        res.raise_for_status()
        return res.json()
    except Exception as e:
        logger.error(f"Erreur API {endpoint}: {e}")
        return []

def get_hierarchy_data():
    """Fonction centrale de récupération des données structurées"""
    semestres = fetch_scodoc_api("/departement/TC/formsemestres_courants")
    if not semestres:
        return []

    hierarchy = []
    for sem in semestres:
        fid = sem.get('formsemestre_id')
        if not fid: continue
        
        sem_data = {
            "id": fid,
            "titre": sem.get('titre_num', f"Semestre {fid}"),
            "debut": sem.get('date_debut'),
            "fin": sem.get('date_fin'),
            "groupes": []
        }
        
        partitions = fetch_scodoc_api(f"/formsemestre/{fid}/partitions")
        if isinstance(partitions, dict):
            for p_id, part in partitions.items():
                p_name = part.get('partition_name', 'Groupe')
                groups = part.get('groups', {})
                for g_id, g in groups.items():
                    students = fetch_scodoc_api(f"/group/{g_id}/etudiants")
                    sem_data["groupes"].append({
                        "id": g_id,
                        "partition": p_name,
                        "nom": g.get('group_name'),
                        "etudiants": students
                    })
        hierarchy.append(sem_data)
    return hierarchy

def get_resources_data():
    """Récupère les modules (ressources) et SAE avec leurs responsables"""
    semestres = fetch_scodoc_api("/departement/TC/formsemestres_courants")
    if not semestres:
        return []

    # Cache local pour les noms de responsables afin d'éviter les appels API redondants
    responsables_cache = {}

    def get_responsable_info(uid):
        if not uid: return "(Inconnu)", ""
        if uid in responsables_cache: return responsables_cache[uid]
        
        logger.info(f"Fetching info for responsable ID: {uid}")
        user_data = fetch_scodoc_api(f"/user/{uid}")
        if isinstance(user_data, dict) and user_data.get('nom'):
            prenom = user_data.get('prenom', '')
            nom = user_data.get('nom', '')
            email = user_data.get('email', '')
            name_fmt = f"{prenom[0]}. {nom}" if prenom else nom
            responsables_cache[uid] = (name_fmt, email)
            return name_fmt, email
        
        responsables_cache[uid] = ("(Inconnu)", "")
        return "(Inconnu)", ""

    all_resources = []
    for sem in semestres:
        fid = sem.get('formsemestre_id')
        if not fid: continue
        
        programme = fetch_scodoc_api(f"/formsemestre/{fid}/programme")
        if not programme or not isinstance(programme, dict): continue

        ressources = programme.get('ressources', [])
        saes = programme.get('saes', [])
        
        items = []
        for r in ressources: 
            r['is_sae'] = False
            items.append(r)
        for s in saes: 
            s['is_sae'] = True
            items.append(s)

        for item in items:
            if not isinstance(item, dict): continue
            
            mod_info = item.get('module', {})
            code = mod_info.get('code') or item.get('code') or "N/A"
            titre = mod_info.get('titre') or item.get('titre') or "Sans titre"
            mod_id = item.get('module_id') or item.get('id')
            
            resp_id = item.get('responsable_id')
            if not resp_id and item.get('ens'):
                resp_id = item.get('ens')[0].get('ens_id')
            
            responsable_name, responsable_email = get_responsable_info(resp_id)
            
            # Log de succès
            if "Bourdon" in responsable_name or "Hoellard" in responsable_name:
                logger.info(f"MATCH SUCCESS: {code} -> {responsable_name}")

            all_resources.append({
                "semestre_id": fid,
                "semestre_titre": sem.get('titre_num'),
                "module_id": mod_id,
                "code": code,
                "titre": titre,
                "coefficient": mod_info.get('coefficient', 1.0),
                "responsable_id": resp_id,
                "responsable_nom": responsable_name,
                "responsable_email": responsable_email,
                "is_sae": item.get('is_sae', False),
                "ue_acronyme": "N/A"
            })
    
    return all_resources

@app.get("/api/ressources")
def api_ressources():
    """Retourne la liste des ressources et SAE avec responsables en JSON"""
    return get_resources_data()

@app.get("/api/hierarchie")
def api_hierarchie():
    """Retourne l'arborescence complète en JSON"""
    return get_hierarchy_data()

@app.get("/demo", response_class=HTMLResponse, tags=["Démo"])
def demo_view():
    """Vue HTML basée sur les mêmes données que l'API JSON"""
    try:
        # 1. Données Hiérarchiques (Étudiants/Groupes)
        data = get_hierarchy_data()
        # 2. Données Ressources (Nouveauté)
        resources = get_resources_data()

        html_content = """
        <!DOCTYPE html>
        <html lang="fr">
        <head>
            <meta charset="utf-8">
            <title>Skills Hub - Audit Scodoc TC</title>
            <style>
                body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f0f2f5; padding: 20px; color: #333; }
                h1, h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
                .section-container { display: flex; gap: 20px; flex-wrap: wrap; }
                .column { flex: 1; min-width: 45%; }
                .card { background: white; border-radius: 8px; margin-bottom: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); overflow: hidden; border: 1px solid #ddd; }
                .card-header { background: #3498db; color: white; padding: 12px 15px; cursor: pointer; font-weight: bold; display: flex; justify-content: space-between; align-items: center; }
                .card-header.sae { background: #27ae60; }
                .card-header.resource { background: #8e44ad; }
                .group-block { margin: 8px 15px; border: 1px solid #eee; border-radius: 4px; background: #fff; }
                .group-header { background: #f8f9fa; padding: 8px 12px; cursor: pointer; display: flex; justify-content: space-between; font-size: 0.9em; }
                table { width: 100%; border-collapse: collapse; font-size: 0.85em; }
                th { text-align: left; padding: 10px; background: #f8f9fa; border-bottom: 2px solid #eee; color: #7f8c8d; }
                td { padding: 8px 10px; border-bottom: 1px solid #eee; }
                .badge { padding: 2px 8px; border-radius: 12px; font-size: 0.75em; font-weight: bold; text-transform: uppercase; }
                .badge-blue { background: #d1e9ff; color: #007bff; }
                .badge-green { background: #d4edda; color: #155724; }
                .resp-info { font-size: 0.9em; color: #2c3e50; font-weight: 600; }
                .resp-email { font-size: 0.8em; color: #7f8c8d; font-weight: normal; }
                summary { list-style: none; outline: none; }
                summary::-webkit-details-marker { display: none; }
            </style>
        </head>
        <body>
            <h1>🎓 Audit des Données Scodoc (Département TC)</h1>
            
            <div class="section-container">
                <!-- COLONNE 1 : ÉTUDIANTS & GROUPES -->
                <div class="column">
                    <h2>👥 Étudiants par Semestre</h2>
                    """
        
        if not data:
            html_content += "<p>Aucun semestre actif trouvé.</p>"
        else:
            for sem in data:
                total_students = sum(len(g['etudiants']) for g in sem['groupes'])
                html_content += f"""
                <details class="card" open>
                    <summary class="card-header">
                        <span>{sem['titre']}</span>
                        <span class="badge badge-blue">{total_students} étudiants</span>
                    </summary>
                    <div style="padding: 10px 0;">
                """
                for g in sem['groupes']:
                    html_content += f"""
                    <details class="group-block">
                        <summary class="group-header">
                            <span><b>{g['partition']}</b> : {g['nom']}</span>
                            <span>{len(g['etudiants'])} pers.</span>
                        </summary>
                        <div style="padding: 5px;">
                            <table>
                                <thead><tr><th>NOM Prénom</th><th>NIP</th><th>Email</th></tr></thead>
                                <tbody>
                    """
                    for s in g['etudiants']:
                        html_content += f"<tr><td><b>{s.get('nom','')}</b> {s.get('prenom','')}</td><td><code>{s.get('code_nip','')}</code></td><td>{s.get('email','')}</td></tr>"
                    html_content += "</tbody></table></div></details>"
                html_content += "</div></details>"

        html_content += """
                </div>

                <!-- COLONNE 2 : RESSOURCES & SAE -->
                <div class="column">
                    <h2>📚 Ressources & SAÉ (Programmes)</h2>
                    """
        
        if not resources:
            html_content += "<p>Aucune ressource ou SAE trouvée dans les programmes courants.</p>"
        else:
            # Grouper par semestre pour la lisibilité
            current_sem = None
            for res in resources:
                if res['semestre_titre'] != current_sem:
                    current_sem = res['semestre_titre']
                    html_content += f"<h3 style='margin-top:20px; color:#7f8c8d;'>{current_sem}</h3>"
                
                header_class = "sae" if res['is_sae'] else "resource"
                type_label = "SAÉ" if res['is_sae'] else "RESSOURCE"
                
                html_content += f"""
                <div class="card">
                    <div class="card-header {header_class}" style="cursor:default;">
                        <span>[{res['code']}] {res['titre']}</span>
                        <span class="badge" style="background:rgba(255,255,255,0.2); color:white;">{type_label}</span>
                    </div>
                    <div style="padding: 12px 15px; display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <div class="resp-info">👤 {res['responsable_nom']}</div>
                            <div class="resp-email">✉️ {res['responsable_email']}</div>
                        </div>
                        <div style="text-align: right; font-size: 0.8em; color: #95a5a6;">
                            UE : {res['ue_acronyme']}<br>
                            Coeff : {res['coefficient']}
                        </div>
                    </div>
                </div>
                """

        html_content += """
                </div>
            </div>
        </body>
        </html>
        """
        return html_content
    except Exception as e:
        logger.error(f"Erreur Demo: {e}")
        return f"<b>Erreur lors de la génération de la vue :</b> {str(e)}"

@app.get("/{path:path}")
def proxy_scodoc(path: str, request: Request):
    if path == "favicon.ico" or path == "": return {"status": "ok"}
    return fetch_scodoc_api(path, params=dict(request.query_params))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
