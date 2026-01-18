import requests
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import os

router = APIRouter()

# Configuration
MISTRAL_API_KEY = "3a218ppqAlBzjegiqPSu3JF0c8krF5fo"
MISTRAL_ENDPOINT = "https://codestral.mistral.ai/v1/chat/completions"
MODEL_NAME = "codestral-latest"

class ChatRequest(BaseModel):
    message: str
    context: str | None = None 

@router.post("/chat")
async def chat_with_codestral(request: ChatRequest):
    """
    Envoie un message à Codestral et retourne la réponse.
    """
    headers = {
        "Authorization": f"Bearer {MISTRAL_API_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

    # Prompt système pour orienter Codestral vers un rôle d'assistant pédagogique
    messages = [
        {"role": "system", "content": "Tu es un assistant pédagogique expert pour le BUT Techniques de Commercialisation. Tu aides les enseignants à créer des cours, des évaluations et à structurer leur pédagogie. Tu es concis, professionnel et constructif."},
        {"role": "user", "content": request.message}
    ]

    payload = {
        "model": MODEL_NAME,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 1000
    }

    try:
        response = requests.post(MISTRAL_ENDPOINT, json=payload, headers=headers)
        response.raise_for_status()
        data = response.json()
        
        # Extraction de la réponse
        bot_reply = data['choices'][0]['message']['content']
        return {"response": bot_reply}

    except requests.exceptions.RequestException as e:
        print(f"Erreur Mistral: {e}")
        try:
            print(f"Detail: {e.response.text}")
        except:
            pass
        raise HTTPException(status_code=500, detail="Erreur de communication avec l'IA")
