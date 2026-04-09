import os
import requests
import fitz  # PyMuPDF
import json
from dotenv import load_dotenv
import time

load_dotenv()

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
CODESTRAL_URL = "https://codestral.mistral.ai/v1/chat/completions"

def extract_text_from_pdf(file_bytes: bytes) -> str:
    doc = fitz.open(stream=file_bytes, filetype="pdf")
    text = ""
    for page in doc:
        text += page.get_text() + "\n"
    return text

def parse_curriculum_chunk(text_chunk: str):
    """
    Analyzes a specific chunk of the PDF.
    """
    prompt = """
    Tu es un extracteur de données pédagogiques ultra-précis pour les référentiels BUT. 
    Analyse ce texte et extrais les informations structurées.
    
    Tu dois différencier les niveaux BUT 1, BUT 2 et BUT 3.
    Note : Le BUT 1 est généralement en "Tronc Commun". Les BUT 2 et 3 sont divisés en parcours (BSMRC, MDEE, MMPC, SME, BI).
    
    Tu dois extraire :
    1. Les Compétences (C1, C2...) avec leur niveau et leur parcours (si spécifié).
    2. Les Composantes Essentielles (CE) liées à chaque compétence et niveau.
    3. Les Apprentissages Critiques (AC) liés à chaque compétence, niveau et parcours.
    4. Les Activités : SAE, STAGES, et PROJETS TUTORES.
    5. Pour chaque Activité, identifie les codes des AC et CE qu'elle mobilise, ainsi que le parcours concerné.

    Structure attendue (JSON uniquement) :
    {
      "competences": [
        {
          "code": "C1",
          "nom": "Libellé",
          "niveau": 1,
          "parcours": "Tronc Commun",
          "ce": [{ "code": "CE1.1", "nom": "Libellé" }],
          "ac": [{ "code": "AC1.1", "nom": "Libellé", "parcours": "Tronc Commun" }]
        }
      ],
      "activities": [
        {
          "code": "SAE 1.01",
          "nom": "Libellé",
          "type": "SAE", 
          "niveau": 1,
          "parcours": "Tronc Commun",
          "semestre": 1,
          "ce_codes": ["CE1.1"],
          "ac_codes": ["AC1.1"]
        }
      ]
    }
    
    IMPORTANT : 
    - Types d'activités valides : "SAE", "STAGE", "PROJET".
    - Ne résume pas les libellés.
    - Si une SAE mobilise des AC/CE, liste bien leurs codes.
    - Retourne UNIQUEMENT le JSON.
    """

    payload = {
        "model": "codestral-latest",
        "messages": [
            {"role": "system", "content": prompt},
            {"role": "user", "content": text_chunk}
        ],
        "temperature": 0
    }

    headers = {
        "Authorization": f"Bearer {MISTRAL_API_KEY}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(CODESTRAL_URL, json=payload, headers=headers)
        response.raise_for_status()
        content = response.json()['choices'][0]['message']['content']
        content = content.replace("```json", "").replace("```", "").strip()
        return json.loads(content)
    except Exception as e:
        print(f"Chunk Error: {e}")
        return {"competences": [], "activities": []}

def parse_full_curriculum(full_text: str):
    """
    Splits the text into chunks and yields progress and final results.
    """
    chunk_size = 15000
    chunks = [full_text[i:i+chunk_size] for i in range(0, len(full_text), chunk_size)]
    
    master_data = {"competences": [], "activities": []}
    total = len(chunks)
    
    yield {"type": "info", "total": total}
    
    for i, chunk in enumerate(chunks):
        yield {"type": "progress", "current": i + 1, "total": total}
        chunk_result = parse_curriculum_chunk(chunk)
        
        # Merge Competences
        for new_comp in chunk_result.get("competences", []):
            existing_comp = next((c for c in master_data["competences"] if c["code"] == new_comp["code"] and c["niveau"] == new_comp.get("niveau")), None)
            
            if existing_comp:
                # Merge CE
                existing_codes_ce = [item["code"] for item in existing_comp["ce"]]
                for item in new_comp.get("ce", []):
                    if item["code"] not in existing_codes_ce:
                        existing_comp["ce"].append(item)
                
                # Merge AC
                existing_codes_ac = [item["code"] for item in existing_comp["ac"]]
                for item in new_comp.get("ac", []):
                    if item["code"] not in existing_codes_ac:
                        existing_comp["ac"].append(item)
            else:
                master_data["competences"].append(new_comp)

        # Merge Activities
        for new_act in chunk_result.get("activities", []):
            existing_act = next((a for a in master_data["activities"] if a["code"] == new_act["code"]), None)
            if existing_act:
                for c in new_act.get("ce_codes", []):
                    if c not in existing_act["ce_codes"]: existing_act["ce_codes"].append(c)
                for c in new_act.get("ac_codes", []):
                    if c not in existing_act["ac_codes"]: existing_act["ac_codes"].append(c)
            else:
                master_data["activities"].append(new_act)
        
        time.sleep(0.2)
        
    yield {"type": "final", "data": master_data}
