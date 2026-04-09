import os
import requests
import logging
from typing import Optional, List, Dict

# Configuration
ANYTHING_LLM_API_KEY = os.getenv("ANYTHING_LLM_API_KEY", "458T7VQ-MMWMT2K-QC0CAXF-0Q1GVFM")
# Default to localhost for local dev. Docker should override this via env var.
DEFAULT_URL = "http://localhost:3001/api/v1"
ANYTHING_LLM_URL = os.getenv("ANYTHING_LLM_URL", DEFAULT_URL)

class AnythingLLMService:
    def __init__(self, workspace_slug: str = "skills-hub"):
        self.base_url = ANYTHING_LLM_URL.rstrip('/')
        self.api_key = ANYTHING_LLM_API_KEY
        self.workspace_slug = workspace_slug
        self.headers = {
            "Authorization": f"Bearer {self.api_key}"
        }

    def _get(self, endpoint: str):
        try:
            res = requests.get(f"{self.base_url}{endpoint}", headers=self.headers, timeout=10)
            res.raise_for_status()
            return res.json()
        except Exception as e:
            logging.error(f"AnythingLLM GET {endpoint} failed: {e}")
            return None

    def _post(self, endpoint: str, data: Dict = None, files=None):
        try:
            headers = self.headers.copy()
            if not files:
                headers["Content-Type"] = "application/json"
            
            res = requests.post(f"{self.base_url}{endpoint}", json=data, files=files, headers=headers, timeout=300)
            res.raise_for_status()
            return res.json()
        except Exception as e:
            logging.error(f"AnythingLLM POST {endpoint} failed: {e}")
            try:
                logging.error(f"Response: {res.text}")
            except: pass
            return None

    def _delete(self, endpoint: str, data: Dict = None):
        try:
            headers = self.headers.copy()
            headers["Content-Type"] = "application/json"
            res = requests.delete(f"{self.base_url}{endpoint}", json=data, headers=headers, timeout=10)
            res.raise_for_status()
            if res.text.strip() == "OK":
                return {"success": True}
            return res.json()
        except Exception as e:
            return None

    def upload_document_text(self, content: str, filename: str = "knowledge_base.txt") -> Optional[str]:
        """
        Uploads text content as a file. Returns the document location path if successful.
        """
        files = {'file': (filename, content, 'text/plain')}
        res = self._post("/document/upload", files=files)
        if res and res.get('success'):
            docs = res.get('documents', [])
            if docs:
                return docs[0].get('location')
        return None

    def upload_document_bytes(self, file_content: bytes, filename: str) -> Optional[str]:
        """
        Uploads binary content as a file. Returns the document location path if successful.
        """
        files = {'file': (filename, file_content, 'application/pdf')}
        res = self._post("/document/upload", files=files)
        if res and res.get('success'):
            docs = res.get('documents', [])
            if docs:
                return docs[0].get('location')
        return None

    def update_embeddings(self, add_locations: List[str], remove_locations: List[str] = []):
        """
        Updates the workspace embeddings.
        """
        payload = {
            "adds": add_locations,
            "deletes": remove_locations
        }
        return self._post(f"/workspace/{self.workspace_slug}/update-embeddings", data=payload)

    def get_workspace_documents(self) -> List[str]:
        """
        Returns list of document locations currently in the workspace.
        """
        res = self._get(f"/workspace/{self.workspace_slug}")
        if res and 'workspace' in res:
            ws_list = res['workspace']
            if isinstance(ws_list, list) and len(ws_list) > 0:
                ws = ws_list[0]
                docs = ws.get('documents', [])
                # Return locations. 
                return [d.get('docpath') or d.get('location') for d in docs if d.get('docpath') or d.get('location')]
        return []

    def chat(self, message: str):
        """
        Sends a message to the workspace.
        """
        payload = {
            "message": message,
            "mode": "chat"
        }
        res = self._post(f"/workspace/{self.workspace_slug}/chat", data=payload)
        if res:
            return {
                "response": res.get('textResponse', "Je n'ai pas compris."),
                "sources": res.get('sources', [])
            }
        raise Exception("Failed to communicate with AnythingLLM")
