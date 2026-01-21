import requests
import os
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from pydantic import BaseModel
from typing import List, Optional
from sqlmodel import Session, select
from ..database import get_session
from ..models import SystemConfig
import fitz  # PyMuPDF

router = APIRouter()

# Configuration par défaut
MISTRAL_ENDPOINT = os.getenv("MISTRAL_ENDPOINT", "https://codestral.mistral.ai/v1/chat/completions")
MODEL_NAME = os.getenv("MISTRAL_MODEL", "codestral-latest")

class MessageItem(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[MessageItem]
    file_context: Optional[str] = None

@router.post("/extract-text")
async def extract_text(file: UploadFile = File(...)):
    """Extrait le texte d'un PDF ou d'un fichier texte."""
    content = ""
    try:
        if file.content_type == "application/pdf":
            pdf_bytes = await file.read()
            doc = fitz.open(stream=pdf_bytes, filetype="pdf")
            for page in doc:
                content += page.get_text()
        else:
            text_bytes = await file.read()
            content = text_bytes.decode("utf-8")
        
        return {"text": content, "filename": file.filename}
    except Exception as e:
        print(f"Erreur extraction: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur lors de l'extraction du texte: {str(e)}")

@router.post("/chat")
async def chat_with_codestral(request: ChatRequest, session: Session = Depends(get_session)):
    # 1. Récupération de la clé API depuis la configuration système
    statement = select(SystemConfig).where(SystemConfig.key == "mistral_api_key")
    config = session.exec(statement).first()
    
    if not config or not config.value:
        raise HTTPException(status_code=400, detail="Clé API Mistral non configurée.")

    api_key = config.value

    # 2. Chargement de la base de connaissance locale
    knowledge_context = ""
    try:
        with open("app/services/knowledge_base.txt", "r") as f:
            knowledge_context = f.read()
    except Exception as e:
        print(f"Base de connaissance non chargée: {e}")

    # 3. Intégration du contexte de fichier si présent
    file_info = f"\n\nCONTEXTE DOCUMENT SUPPLÉMENTAIRE :\n{request.file_context}" if request.file_context else ""

    system_prompt = {
        "role": "system", 
        "content": f"Tu es un assistant pédagogique expert pour le BUT Techniques de Commercialisation (IUT Le Havre). \n\nBASE DE CONNAISSANCES :\n{knowledge_context}{file_info}\n\nINSTRUCTIONS :\n1. Utilise ces données pour répondre précisément.\n2. Pour les mathématiques, utilise EXCLUSIVEMENT \( \) pour l'inline et \[ \] pour les blocs.\n3. Ne répète jamais tes propres délimiteurs.\n4. Sois concis et professionnel."
    }
    
    # Construction du payload pour Mistral en alternant correctement les rôles
    history = []
    for m in request.messages:
        role = 'assistant' if m.role == 'bot' else 'user'
        history.append({"role": role, "content": m.content})
    
    # SÉCURITÉ : Mistral exige que le 1er message soit 'user'
    if history and history[0]['role'] == 'assistant':
        history = history[1:]

    messages_payload = [system_prompt] + history

    payload = {
        "model": MODEL_NAME,
        "messages": messages_payload,
        "temperature": 0,
        "max_tokens": 2000
    }

    try:
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        response = requests.post(MISTRAL_ENDPOINT, json=payload, headers=headers)
        response.raise_for_status()
        data = response.json()
        bot_reply = data['choices'][0]['message']['content']
        
        # Nettoyage anti-bégaiement
        bot_reply = bot_reply.replace('［ ［', '［').replace('］ ］', '］')
        
        return {"response": bot_reply}
    except Exception as e:
        print(f"Erreur Mistral API: {e}")
        raise HTTPException(status_code=500, detail="Erreur de communication avec l'IA")