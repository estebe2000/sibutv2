import httpx, json, logging, os, asyncio
from typing import List, Dict, Optional
from ragflow_sdk import RAGFlow
from ..core.config import settings

logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        self.host = "http://172.16.87.140:7080"
        self.base_url = f"{self.host}/api/v1"
        self.api_key = "ragflow-PnNtL5vQ6eikun31ZWUUM5vazn9OHT0CcQGOangrpbk"
        self.common_dataset_id = "4980ac443b0311f1a53bb596be0650c0"
        self.default_chat_id = "b774d2583b0c11f1a53bb596be0650c0"
        self.timeout = 90.0
        self.rag = RAGFlow(api_key=self.api_key, base_url=self.host)
        self.headers = {"Authorization": f"Bearer {self.api_key}", "Content-Type": "application/json"}

    async def create_chat(self, name: str, dataset_ids: List[str], preprompt: str) -> Optional[str]:
        try:
            chat = self.rag.create_chat(name=name, dataset_ids=dataset_ids)
            return chat.id
        except Exception as e: logger.error(f"create_chat error: {e}"); return None

    async def get_chat_by_name_or_id(self, name: Optional[str] = None, chat_id: Optional[str] = None):
        try:
            if name:
                chats = self.rag.list_chats(name=name)
                if chats: return chats[0]
            if chat_id:
                chats = self.rag.list_chats()
                for c in chats:
                    if c.id == chat_id: return c
        except Exception as e: logger.error(f"get_chat error: {e}"); return None

    async def create_session(self, chat_name: str) -> Optional[str]:
        try:
            chat = await self.get_chat_by_name_or_id(name=chat_name)
            if chat: return chat.create_session().id
            logger.warning(f"Chat name '{chat_name}' not found, falling back to default_chat_id")
            return await self.create_session_by_id(self.default_chat_id)
        except Exception as e: logger.error(f"create_session error: {e}"); return None

    async def create_session_by_id(self, chat_id: str) -> Optional[str]:
        try:
            chat = await self.get_chat_by_name_or_id(chat_id=chat_id)
            if chat:
                session = chat.create_session()
                return session.id
            logger.error(f"Chat ID {chat_id} not found in RAGFlow")
            return None
        except Exception as e:
            logger.error(f"create_session_by_id error for {chat_id}: {e}")
            return None

    async def chat(self, chat_id: str, session_id: str, message: str) -> Dict:
        try:
            url = f"{self.host}/api/v1/chats_openai/{chat_id}/chat/completions"
            payload = {"model": "ragflow", "messages": [{"role": "user", "content": message}], "stream": False}
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                resp = await client.post(url, headers=self.headers, json=payload)
                data = resp.json()
                if "choices" in data: return {"answer": data["choices"][0]["message"]["content"]}
                return {"answer": "Erreur de réponse IA"}
        except Exception as e: return {"answer": f"Erreur comm: {e}"}

    async def get_or_create_dataset(self, user_uid: str, is_temp: bool = False) -> Optional[str]:
        name = f"{'TEMP' if is_temp else 'GED'}_{user_uid}"
        try:
            ds = self.rag.list_datasets(name=name)
            if ds: return ds[0].id
            return self.rag.create_dataset(name=name).id
        except Exception as e: logger.error(f"dataset error: {e}"); return None

    async def list_documents(self, dataset_id: str) -> List[Dict]:
        url = f"{self.base_url}/datasets/{dataset_id}/documents?page=1&page_size=100"
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(url, headers=self.headers)
                return resp.json().get("data", {}).get("docs", [])
        except: return []

    async def upload_document(self, user_uid: str, content: bytes, filename: str) -> Optional[str]:
        try:
            dataset_name = f"GED_{user_uid}"
            ds = self.rag.get_dataset(name=dataset_name)
            ds.upload_documents([{"display_name": filename, "blob": content}])
            await asyncio.sleep(2)
            docs = ds.list_documents(keywords=filename, page=1, page_size=1)
            if docs:
                ds.async_parse_documents([docs[0].id])
                return docs[0].id
        except Exception as e: logger.error(f"upload error: {e}"); return None

ai_service = AIService()
