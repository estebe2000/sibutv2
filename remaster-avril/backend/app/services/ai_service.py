import httpx
import json
from ..core.config import settings

LOCALAI_URL = "http://172.16.87.140:8080/v1/chat/completions"
DEFAULT_MODEL = "llama-3.2-3b" # Modèle rapide et efficace

async def ask_assistant(prompt: str, context: str = ""):
    """
    Envoie une requête à LocalAI avec le contexte du référentiel.
    """
    system_prompt = f"""Tu es l'Assistant Pédagogique du Skills Hub de l'IUT APC. 
Ton rôle est d'aider les enseignants et les étudiants dans la gestion des compétences du BUT Techniques de Commercialisation.
Utilise les informations suivantes du référentiel pour répondre de manière précise :
{context}
Réponds toujours en français, de manière professionnelle et concise."""

    payload = {
        "model": DEFAULT_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.7
    }

    async with httpx.AsyncClient(timeout=60.0) as client:
        try:
            response = await client.post(LOCALAI_URL, json=payload)
            response.raise_for_status()
            result = response.json()
            return result['choices'][0]['message']['content']
        except Exception as e:
            return f"Erreur de l'assistant IA : {str(e)}"
