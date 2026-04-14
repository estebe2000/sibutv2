import os
import sys

sys.path.append("/app")

from sqlmodel import Session, select
from app.database import engine
from app.models import User, ResponsibilityMatrix, Activity
from app.services.anythingllm_service import AnythingLLMService

def update_team():
    service = AnythingLLMService()
    
    with Session(engine) as session:
        equipe_lines = ["=== ANNUAIRE DE L'ÉQUIPE PÉDAGOGIQUE ===\n"]
        users = session.exec(select(User).where(User.role.not_in(["STUDENT", "GUEST"]))).all()
        resps = session.exec(select(ResponsibilityMatrix)).all()
        activities = session.exec(select(Activity)).all()
        
        role_translations = {
            "UserRole.DEPT_HEAD": "Chef de Département TC",
            "UserRole.STUDY_DIRECTOR": "Directeur des Études",
            "UserRole.PROFESSOR": "Enseignant / Professeur",
            "UserRole.ADMIN": "Administrateur Système",
            "DEPT_HEAD": "Chef de Département TC",
            "STUDY_DIRECTOR": "Directeur des Études",
            "PROFESSOR": "Enseignant / Professeur",
            "ADMIN": "Administrateur Système",
        }
        
        for u in users:
            role_str = str(u.role).replace('UserRole.', '')
            readable_role = role_translations.get(role_str, role_str)
            
            equipe_lines.append(f"=== {readable_role.upper()} : {u.full_name} ===")
            equipe_lines.append(f"Fonction principale : {u.full_name} est {readable_role} au sein du département Techniques de Commercialisation (TC).")
            equipe_lines.append(f"Identifiant LDAP: {u.ldap_uid}")
            equipe_lines.append(f"Email: {u.email}")
            
            user_resps = [r for r in resps if r.user_id == u.ldap_uid or r.user_id == str(u.id)]
            if user_resps:
                equipe_lines.append("Historique des Responsabilités :")
                for rm in user_resps:
                    entity_name = rm.entity_id
                    if rm.entity_type.name == "ACTIVITY":
                        act_match = next((a.code for a in activities if str(a.id) == rm.entity_id), rm.entity_id)
                        entity_name = act_match
                    annee_info = f" depuis l'année universitaire {rm.academic_year}" if hasattr(rm, 'academic_year') and rm.academic_year else ""
                    equipe_lines.append(f" - A le rôle de {rm.role_type.name} sur {rm.entity_type.name} {entity_name}{annee_info}")
            else:
                equipe_lines.append("Aucune responsabilité spécifique affectée dans la matrice.")
            equipe_lines.append("\n")

        equipe_content = "\n".join(equipe_lines)
        
        # Mettre en ligne
        loc = service.upload_document_text(equipe_content, "Equipe_Pedagogique.txt")
        if loc:
            old_docs = service.get_workspace_documents()
            docs_to_remove = [d for d in old_docs if "Equipe_Pedagogique" in d]
            res = service.update_embeddings([loc], docs_to_remove)
            print("Mise à jour Fiches Enseignants terminée avec titres précis.")

if __name__ == "__main__":
    update_team()
