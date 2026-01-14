import os
import requests
import logging
import io
from requests.auth import HTTPBasicAuth
from webdav4.client import Client
from fastapi import HTTPException

# Setup logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Configuration depuis l'environnement
NC_URL = os.getenv("NEXTCLOUD_URL", "https://nextcloud.educ-ai.fr")
NC_USER = os.getenv("NEXTCLOUD_SERVICE_USER", "hub-service")
NC_PASS = os.getenv("NEXTCLOUD_SERVICE_PASS", "Rangetachambre76*")

# L'URL WebDAV pour Nextcloud
WEBDAV_URL = f"{NC_URL}/remote.php/dav/files/{NC_USER}"

class NextcloudService:
    def __init__(self):
        # On désactive verify=False pour le client WebDAV aussi car on est en environnement dev/local
        # webdav4 passe les kwargs à httpx.Client
        self.client = Client(WEBDAV_URL, auth=(NC_USER, NC_PASS), verify=False)
        self.auth = HTTPBasicAuth(NC_USER, NC_PASS)

    def ensure_student_folder(self, ldap_uid: str):
        """
        S'assure que le dossier /SkillsHub/{ldap_uid} existe et est partagé.
        """
        root_path = "SkillsHub"
        student_path = f"{root_path}/{ldap_uid}"

        try:
            # 1. Créer le dossier racine SkillsHub s'il n'existe pas
            if not self.client.exists(root_path):
                self.client.mkdir(root_path)
            
            # 2. Créer le dossier de l'étudiant s'il n'existe pas
            if not self.client.exists(student_path):
                self.client.mkdir(student_path)
                # 3. Partager le dossier avec l'étudiant en LECTURE SEULE
                self.share_folder_with_student(student_path, ldap_uid)
            
            return student_path
        except Exception as e:
            logger.error(f"Nextcloud Error (Folder creation) for {ldap_uid}: {e}", exc_info=True)
            return None

    def share_folder_with_student(self, path: str, ldap_uid: str):
        """
        Partage un dossier via l'API OCS de Nextcloud.
        Permissions : 1 = Lecture seule.
        """
        share_url = f"{NC_URL}/ocs/v1.php/apps/files_sharing/api/v1/shares"
        payload = {
            "path": path,
            "shareType": 0,       # 0 = Partage utilisateur
            "shareWith": ldap_uid,
            "permissions": 1      # 1 = Read only
        }
        headers = {"OCS-APIRequest": "true"}
        
        try:
            response = requests.post(share_url, data=payload, auth=self.auth, headers=headers, verify=False)
            if response.status_code not in [200, 201]:
                # On log en warning, car le partage peut échouer si l'utilisateur n'existe pas encore dans Nextcloud
                # ou si le partage existe déjà (bien que l'API renvoie souvent 200/400 avec msg spécifique)
                logger.warning(f"Nextcloud Share Warning for {ldap_uid}: {response.text}")
        except Exception as e:
            logger.error(f"Nextcloud Share Error for {ldap_uid}: {e}", exc_info=True)

    def upload_file(self, student_uid: str, filename: str, content: bytes, subfolder: str = ""):
        """
        Upload un fichier dans le dossier de l'étudiant.
        """
        try:
            base_path = self.ensure_student_folder(student_uid)
            if not base_path:
                raise Exception("Could not prepare student storage (ensure_student_folder failed)")
            
            target_path = f"{base_path}/{filename}"
            if subfolder:
                target_path = f"{base_path}/{subfolder}/{filename}"
                # S'assurer que le sous-dossier (ex: l'activité) existe
                subfolder_path = f"{base_path}/{subfolder}"
                if not self.client.exists(subfolder_path):
                    self.client.mkdir(subfolder_path)

            self.client.upload_fileobj(io.BytesIO(content), target_path)
            
            return target_path
        except Exception as e:
            logger.error(f"Upload failed for user {student_uid}: {e}", exc_info=True)
            # On relance l'exception pour que le routeur renvoie une 500 propre
            raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

    def list_files(self, student_uid: str, subfolder: str = ""):
        """
        Liste les fichiers dans le dossier de l'étudiant.
        """
        path = f"SkillsHub/{student_uid}"
        if subfolder:
            path = f"{path}/{subfolder}"
            
        try:
            if not self.client.exists(path):
                return []
            
            items = self.client.ls(path, detail=True)
            # On filtre pour ne renvoyer que les fichiers (pas le dossier lui-même)
            return [
                {
                    "name": item["name"],
                    "size": item["size"],
                    "modified": item["modified"].isoformat() if item["modified"] else None,
                    "is_dir": item["type"] == "directory"
                }
                for item in items if item["name"] != path
            ]
        except Exception as e:
            logger.error(f"Nextcloud List Error for {student_uid}: {e}", exc_info=True)
            return []

# Singleton
nc_service = NextcloudService()
