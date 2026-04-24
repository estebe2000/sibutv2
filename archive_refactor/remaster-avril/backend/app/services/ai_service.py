import httpx
import json
import logging
import os
from typing import List, Dict, Optional
from ragflow_sdk import RAGFlow

logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        self.host = "http://172.16.87.140:7080"
        self.base_url = f"{self.host}/api/v1"
        self.api_key = "ragflow-PnNtL5vQ6eikun31ZWUUM5vazn9OHT0CcQGOangrpbk"
        self.common_dataset_id = "4980ac443b0311f1a53bb596be0650c0"
        self.default_chat_name = "but tc" # Nom pour le SDK
        self.default_chat_id = "b774d2583b0c11f1a53bb596be0650c0"
        self.timeout = 90.0
        
        # Initialisation du SDK
        self.rag = RAGFlow(api_key=self.api_key, base_url=self.host)
        self.headers = {"Authorization": f"Bearer {self.api_key}", "Content-Type": "application/json"}

    async def create_chat(self, name: str, dataset_ids: List[str], preprompt: str) -> Optional[str]:
        """Crée un assistant RAGFlow (Chat) via le SDK."""
        try:
            # Note: Le SDK attend name et dataset_ids
            chat = self.rag.create_chat(name=name, dataset_ids=dataset_ids)
            return chat.id
        except Exception as e:
            logger.error(f"AIService.create_chat error: {str(e)}")
        return None

    async def get_chat_by_name_or_id(self, name: Optional[str] = None, chat_id: Optional[str] = None):
        """Récupère un objet Chat via le SDK."""
        try:
            if name:
                chats = self.rag.list_chats(name=name)
                if chats: return chats[0]
            if chat_id:
                # Si le SDK ne supporte pas get(id=...), on liste tout et on filtre
                chats = self.rag.list_chats()
                for c in chats:
                    if c.id == chat_id: return c
        except Exception as e:
            logger.error(f"AIService.get_chat error: {str(e)}")
        return None

    async def create_session(self, chat_name: str) -> Optional[str]:
        """Crée une nouvelle session de discussion."""
        try:
            chat = await self.get_chat_by_name_or_id(name=chat_name)
            if chat:
                session = chat.create_session()
                return session.id
        except Exception as e:
            logger.error(f"AIService.create_session error: {str(e)}")
        return None

    async def chat(self, chat_id: str, session_id: str, message: str) -> Dict:
        """Envoie un message et récupère la réponse COMPLÈTE via l'API OpenAI-compatible."""
        try:
            # On utilise l'endpoint OpenAI-compatible avec le chat_id spécifique
            # Cet endpoint est plus robuste pour renvoyer le texte complet en un bloc
            url = f"{self.host}/api/v1/chats_openai/{chat_id}/chat/completions"
            
            payload = {
                "model": "ragflow",
                "messages": [{"role": "user", "content": message}],
                "stream": False
            }
            
            print(f"[*] AIService: Asking RAGFlow OpenAI-Compatible (Chat: {chat_id})...")
            
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, headers=self.headers, json=payload)
                response.raise_for_status()
                data = response.json()
                
                # Format OpenAI standard
                if "choices" in data and len(data["choices"]) > 0:
                    return {
                        "answer": data["choices"][0]["message"]["content"],
                        "reference": data.get("reference", []) # RAGFlow ajoute parfois les refs à côté
                    }
                return {"answer": "Erreur lors de la génération de la réponse.", "reference": []}
                    
        except Exception as e:
            logger.error(f"AIService.chat error: {str(e)}")
            return {"answer": f"Erreur de communication : {str(e)}", "reference": []}

    # --- GED ENSEIGNANT ---

    async def get_or_create_dataset(self, user_uid: str, is_temp: bool = False) -> Optional[str]:
        """Récupère ou crée un dataset RAGFlow. is_temp=True pour les fichiers éphémères."""
        prefix = "TEMP" if is_temp else "GED"
        dataset_name = f"{prefix}_{user_uid}"
        try:
            datasets = self.rag.list_datasets(name=dataset_name)
            if datasets:
                return datasets[0].id
            new_ds = self.rag.create_dataset(name=dataset_name)
            return new_ds.id
        except Exception as e:
            logger.error(f"AIService.get_or_create_dataset error: {str(e)}")
        return None

    async def list_documents(self, dataset_id: str) -> List[Dict]:
        url = f"{self.base_url}/datasets/{dataset_id}/documents?page=1&page_size=100"
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(url, headers=self.headers)
                if resp.status_code == 200:
                    return resp.json().get("data", {}).get("docs", [])
        except Exception as e:
            logger.error(f"AIService.list_documents error: {str(e)}")
        return []

    async def upload_document(self, user_uid: str, file_content: bytes, filename: str) -> Optional[str]:
        try:
            dataset_name = f"GED_{user_uid}"
            ds = self.rag.get_dataset(name=dataset_name)
            ds.upload_documents([{"display_name": filename, "blob": file_content}])
            import asyncio
            await asyncio.sleep(2)
            docs = ds.list_documents(keywords=filename, page=1, page_size=1)
            if docs:
                doc_id = docs[0].id
                ds.async_parse_documents([doc_id])
                return doc_id
        except Exception as e:
            logger.error(f"AIService.upload_document error: {str(e)}")
        return None

ai_service = AIService()
