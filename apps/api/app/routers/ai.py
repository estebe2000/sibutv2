import requests
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter()

# Retour temporaire à la clé en dur pour stabiliser
MISTRAL_API_KEY = "3a218ppqAlBzjegiqPSu3JF0c8krF5fo"
MISTRAL_ENDPOINT = "https://codestral.mistral.ai/v1/chat/completions"
MODEL_NAME = "codestral-latest"

class MessageItem(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[MessageItem]

@router.post("/chat")
async def chat_with_codestral(request: ChatRequest):
    headers = {
        "Authorization": f"Bearer {MISTRAL_API_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

    system_prompt = {"role": "system", "content": "Tu es un assistant pédagogique expert pour le BUT Techniques de Commercialisation. Tu aides les enseignants à créer des cours, des évaluations et à structurer leur pédagogie. Pour les mathématiques, utilise EXCLUSIVEMENT les délimiteurs \( \) pour le texte en ligne et \[ \] pour les blocs centrés. Tu es concis et professionnel."}
    
    messages_payload = [system_prompt] + [m.dict() for m in request.messages]

    payload = {
        "model": MODEL_NAME,
        "messages": messages_payload,
        "temperature": 0.2,
        "max_tokens": 2000
    }

    try:
        response = requests.post(MISTRAL_ENDPOINT, json=payload, headers=headers)
        response.raise_for_status()
        data = response.json()
        bot_reply = data['choices'][0]['message']['content']
        return {"response": bot_reply}
    except Exception as e:
        print(f"Erreur Mistral: {e}")
        raise HTTPException(status_code=500, detail="Erreur de communication avec l'IA")
