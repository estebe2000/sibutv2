import os
import sys
import glob

sys.path.append("/app")

from sqlmodel import Session, select
from app.database import engine
from app.models import Resource, Activity
from app.services.anythingllm_service import AnythingLLMService

DOCS_PATH = "/app/data_source/docs"
FICHES_PATH = "/app/data_source/fiches"

def create_dev_space():
    service = AnythingLLMService(workspace_slug="dev-space")
    
    print("Création de l'espace dev-space dans AnythingLLM...")
    try:
        service._delete("/workspace/dev-space")
    except Exception: pass
    
    ws_res = service._post("/workspace/new", data={"name": "dev-space"})
    if ws_res:
        print("Espace dev-space créé.")
        
        update_data = {
            "chatProvider": "ollama",
            "chatModel": "mistral-pedago:latest", 
            "openAiPrompt": "Tu es un ingénieur pédagogique du département TC.",
            "similarityThreshold": 0.25,
            "topN": 5
        }
        service._post("/workspace/dev-space/update", data=update_data)

    print("Préparation de l'ingestion PÉDAGOGIQUE...")
    new_doc_locations = []

    with Session(engine) as session:
        from app.models import ResponsibilityMatrix, User
        resps = session.exec(select(ResponsibilityMatrix)).all()
        users = session.exec(select(User)).all()
        
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        for r in resources:
            r_content = f"=== RESSOURCE (COURS) : {r.code} ===\n"
            r_content += f"Code: {r.code}\n"
            r_content += f"Titre: {r.label}\n"
            if r.pathway: r_content += f"Parcours: {r.pathway}\n"
            if r.hours_details: r_content += f"Volume horaire: {r.hours_details}\n"
            if r.targeted_competencies: r_content += f"Compétences ciblées:\n{r.targeted_competencies}\n"
            
            # Fetch from matrix
            r_resps = [rm for rm in resps if rm.entity_type.name == "RESOURCE" and rm.entity_id == r.code]
            resp_names = []
            for rm in r_resps:
                u = next((u for u in users if u.ldap_uid == rm.user_id or str(u.id) == rm.user_id), None)
                if u: resp_names.append(f"{u.full_name} ({rm.role_type.name})")
            if resp_names: r_content += f"Équipe responsable: {', '.join(resp_names)}\n"
            elif r.responsible: r_content += f"Responsable(s): {r.responsible}\n"
            
            if r.contributors: r_content += f"Contributeurs: {r.contributors}\n"
            if r.description: r_content += f"Description courte:\n{r.description}\n"
            if r.content: r_content += f"Contenu complet:\n{r.content}\n"
            
            loc = service.upload_document_text(r_content, f"Dev_Ressource_{r.code}.txt")
            if loc: new_doc_locations.append(loc)

        activities = session.exec(select(Activity).order_by(Activity.code)).all()
        for a in activities:
            a_content = f"=== ACTIVITÉ ({a.type}) : {a.code} ===\nCode: {a.code}\nTitre: {a.label}\n"
            a_content += f"Semestre: S{a.semester} | Niveau: {a.level} | Parcours: {a.pathway}\n"
            if a.resources: a_content += f"Ressources associées: {a.resources}\n"
            
            a_resps = [rm for rm in resps if rm.entity_type.name == "ACTIVITY" and rm.entity_id == str(a.id)]
            a_resp_names = []
            for rm in a_resps:
                u = next((u for u in users if u.ldap_uid == rm.user_id or str(u.id) == rm.user_id), None)
                if u: a_resp_names.append(f"{u.full_name} ({rm.role_type.name})")
            if a_resp_names: a_content += f"Équipe responsable: {', '.join(a_resp_names)}\n"
            elif a.responsible: a_content += f"Responsable(s): {a.responsible}\n"
            
            if a.contributors: a_content += f"Contributeurs: {a.contributors}\n"
            if a.description: a_content += f"Description détaillée:\n{a.description}\n"
            
            loc = service.upload_document_text(a_content, f"Dev_Activite_{a.code}.txt")
            if loc: new_doc_locations.append(loc)

    if new_doc_locations:
        print(f"Indexation de {len(new_doc_locations)} documents pédagogiques...")
        res = service.update_embeddings(add_locations=new_doc_locations, remove_locations=[])
        print("Terminé !")

if __name__ == "__main__":
    create_dev_space()
