import os
import glob
from typing import List
from sqlmodel import Session, select
from ..database import engine
from ..models import Resource, Activity, User, ResponsibilityMatrix, ResponsibilityEntityType

# We will use this file to store the "Context Injection" content
KNOWLEDGE_FILE_PATH = "/app/app/services/knowledge_base.txt"
DOCS_PATH = "/app/data_source/docs"
FICHES_PATH = "/app/data_source/fiches"

def generate_full_knowledge_base():
    """
    Generates a single text file containing all essential information 
    from the Database and Files to be injected into the LLM System Prompt.
    """
    print("Generating Knowledge Base for Context Injection...")
    lines = []
    lines.append("=== BASE DE DONNÉES PÉDAGOGIQUE (OFFICIELLE) ===\n")

    with Session(engine) as session:
        # 1. USERS (Enseignants)
        lines.append("--- ENSEIGNANTS ET RESPONSABLES ---")
        # Exclude students and guests, include everyone else (Admin, Profs, Directors, etc.)
        users = session.exec(select(User).where(User.role.not_in(["STUDENT", "GUEST"]))).all()
        for u in users:
            lines.append(f"Nom: {u.full_name} | UID: {u.ldap_uid} | Email: {u.email} | Rôle: {u.role}")
        lines.append("")

        # 2. RESOURCES (Cours)
        lines.append("--- LISTE DES RESSOURCES (COURS) ---")
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        for r in resources:
            # Format: R1.01 - Titre (Resp: Nom) - Heures: 20h
            lines.append(f"Code: {r.code} | Titre: {r.label}")
            if r.responsible: lines.append(f"  Responsable: {r.responsible}")
            if r.description: lines.append(f"  Description: {r.description[:200]}...") # Truncate description to save tokens
            lines.append("")
        
        # 3. ACTIVITIES (SAE)
        lines.append("--- LISTE DES ACTIVITÉS (SAÉ) ---")
        activities = session.exec(select(Activity).order_by(Activity.code)).all()
        for a in activities:
            lines.append(f"Code: {a.code} | Titre: {a.label} | Semestre: S{a.semester}")
            if a.responsible: lines.append(f"  Responsable: {a.responsible}")
            lines.append("")

        # 4. RESPONSABILITÉS (Matrice)
        lines.append("--- MATRICE DE RESPONSABILITÉS ---")
        resps = session.exec(select(ResponsibilityMatrix)).all()
        for rm in resps:
            lines.append(f"{rm.user_id} est {rm.role_type} sur {rm.entity_type} {rm.entity_id}")
        lines.append("")

    # 5. FILES (Summaries or Titles)
    lines.append("\n=== DOCUMENTS ET FICHES PÉDAGOGIQUES ===\n")
    
    # Scan Fiches (LaTeX) - Just list them or extract titles?
    # Listing them confirms existence.
    lines.append("--- FICHES DISPONIBLES ---")
    for filepath in glob.glob(os.path.join(FICHES_PATH, "**/*.tex"), recursive=True):
        filename = os.path.basename(filepath)
        lines.append(f"Fiche: {filename} (Contenu disponible sur demande précise)")
    
    # Scan Docs (Markdown) - Maybe read headers?
    lines.append("--- DOCUMENTATION ---")
    for filepath in glob.glob(os.path.join(DOCS_PATH, "**/*.md"), recursive=True):
        filename = os.path.basename(filepath)
        lines.append(f"Doc: {filename}")
        # Optionally read first few lines?
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                head = [next(f) for _ in range(5)]
                lines.extend([f"  > {h.strip()}" for h in head if h.strip()])
        except: pass
        lines.append("")

    # Write to file
    content = "\n".join(lines)
    os.makedirs(os.path.dirname(KNOWLEDGE_FILE_PATH), exist_ok=True)
    with open(KNOWLEDGE_FILE_PATH, "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"Knowledge Base generated. Size: {len(content)} chars.")
    return content