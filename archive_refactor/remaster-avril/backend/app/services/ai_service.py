import httpx, json, logging, os, asyncio
from typing import List, Dict, Optional
from ragflow_sdk import RAGFlow
from ..core.config import settings

logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        # Configuration RAGFlow
        self.host = "http://172.16.87.140:7080"
        self.api_key = "ragflow-PnNtL5vQ6eikun31ZWUUM5vazn9OHT0CcQGOangrpbk"
        self.common_dataset_id = "4980ac443b0311f1a53bb596be0650c0" # KB BUT TC globale
        self.timeout = 120.0
        # On initialise le SDK RagFlow
        self.rag = RAGFlow(api_key=self.api_key, base_url=self.host)

    async def get_or_create_dataset(self, user_uid: str) -> Optional[str]:
        """Récupère ou crée la base de connaissances (Dataset) de l'utilisateur."""
        name = f"GED_{user_uid}"
        try:
            datasets = self.rag.list_datasets(name=name)
            if datasets:
                return datasets[0].id
            ds = self.rag.create_dataset(name=name)
            return ds.id
        except Exception as e:
            logger.error(f"RAGFlow Dataset error for {user_uid}: {e}")
            return None

    async def get_or_create_chat(self, user_uid: str, dataset_id: str) -> Optional[str]:
        """Récupère ou crée l'assistant (Chat) lié à la KB utilisateur ET à la KB commune."""
        name = f"CHAT_{user_uid}"
        try:
            chats = self.rag.list_chats(name=name)
            if chats:
                # Mise à jour si la KB commune n'est pas liée
                chat = chats[0]
                # Note: On pourrait forcer l'update ici si besoin
                return chat.id
            
            # Configuration équilibrée (Rigueur + Utilité)
            prompt_config = {
                "system": "Vous êtes l'assistant pédagogique expert du BUT TC. "
                          "MISSIONS : "
                          "1. Pour toute question technique ou pédagogique (ex: R1.13, TD3, Marketing) : Basez-vous EXCLUSIVEMENT sur les documents cités. Si un document a pour titre 'R1.13 TD3 Systèmes d'exploitation', alors traitez le R1.13 comme un module de Systèmes d'exploitation. "
                          "2. Pour les calculs simples (3+3), la politesse (bonjour) ou les questions générales : Répondez normalement et cordialement. "
                          "3. Ne confondez JAMAIS les ressources : vérifiez le code (R1.xx) dans les titres des documents avant de répondre. "
                          "4. Citez toujours l'ID du document utilisé pour vos réponses techniques. "
                          "Répondez en français de manière claire et structurée.",
                "empty_response": "Je n'ai pas trouvé d'information précise dans les documents officiels. Pourriez-vous préciser votre demande ?"
            }

            # Création de l'assistant lié aux DEUX Datasets
            chat = self.rag.create_chat(
                name=name, 
                dataset_ids=[dataset_id, self.common_dataset_id],
                prompt_config=prompt_config
            )
            return chat.id
        except Exception as e:
            logger.error(f"RAGFlow Chat error for {user_uid}: {e}")
            return None

    async def get_or_create_session(self, chat_id: str, session_name: str = "Default") -> Optional[str]:
        """Crée une nouvelle session de conversation pour un assistant donné."""
        try:
            # On récupère l'objet Chat par son ID (via list_chats filtré)
            chats = self.rag.list_chats()
            chat = next((c for c in chats if c.id == chat_id), None)
            if not chat:
                return None
            
            # On crée une nouvelle session
            session = chat.create_session(name=session_name)
            return session.id
        except Exception as e:
            logger.error(f"RAGFlow Session error for chat {chat_id}: {e}")
            return None

    async def ask_question(self, chat_id: str, session_id: str, question: str) -> Dict:
        """Pose une question à l'IA en utilisant le RAG et la session de l'utilisateur."""
        try:
            # Récupération des objets via le SDK pour utiliser .ask()
            chats = self.rag.list_chats()
            chat = next((c for c in chats if c.id == chat_id), None)
            if not chat: return {"answer": "Assistant introuvable."}
            
            sessions = chat.list_sessions()
            session = next((s for s in sessions if s.id == session_id), None)
            if not session:
                # Si la session a expiré côté RAGFlow, on en recrée une
                session = chat.create_session(name="Restored Session")
            
            # Appel RAG via SDK
            # On gère le cas où le SDK renvoie un générateur même avec stream=False
            response = session.ask(question, stream=False)
            
            answer = ""
            if hasattr(response, '__iter__') or hasattr(response, '__next__'):
                # C'est un générateur (streaming)
                for chunk in response:
                    if hasattr(chunk, 'content'):
                        answer = chunk.content # Souvent le dernier chunk contient tout ou on concatène
                    elif isinstance(chunk, str):
                        answer += chunk
                    else:
                        # Si c'est un objet message complexe
                        try: answer = chunk.content
                        except: answer = str(chunk)
            elif hasattr(response, 'content'):
                answer = response.content
            else:
                answer = str(response)

            return {"answer": answer, "session_id": session.id}
            
        except Exception as e:
            logger.error(f"RAGFlow Ask error: {e}")
            return {"answer": f"Erreur de communication avec l'IA: {e}"}

    async def upload_document(self, dataset_id: str, content: bytes, filename: str) -> bool:
        """Upload et lance le parsing d'un document dans la KB de l'utilisateur."""
        try:
            datasets = self.rag.list_datasets()
            ds = next((d for d in datasets if d.id == dataset_id), None)
            if not ds: return False
            
            # Upload
            ds.upload_documents([{"display_name": filename, "blob": content}])
            # On attend un peu pour que le doc apparaisse
            await asyncio.sleep(1)
            
            # On récupère le document pour lancer le parsing
            docs = ds.list_documents(keywords=filename)
            if docs:
                ds.async_parse_documents([docs[0].id])
                return True
            return False
        except Exception as e:
            logger.error(f"RAGFlow Upload error: {e}")
            return False

    async def list_documents(self, dataset_id: str) -> List[Dict]:
        """Liste les documents présents dans la KB."""
        try:
            datasets = self.rag.list_datasets()
            ds = next((d for d in datasets if d.id == dataset_id), None)
            if not ds: return []
            
            docs = ds.list_documents(page=1, page_size=100)
            return [{"id": d.id, "name": d.name, "status": d.run} for d in docs]
        except:
            return []

ai_service = AIService()
