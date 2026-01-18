import xmlrpc.client
import os
import logging
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import hashlib

# Configuration
ODOO_URL = os.getenv("ODOO_URL", "http://odoo:8069") # Interne Docker
ODOO_MASTER_PASSWORD = os.getenv("ODOO_MASTER_PASSWORD", "Rangetachambre76*")
ODOO_DB_URL = os.getenv("ODOO_DB_URL") # Pour accès SQL direct

logger = logging.getLogger(__name__)

class OdooService:
    def __init__(self):
        self.db_proxy = xmlrpc.client.ServerProxy(f'{ODOO_URL}/xmlrpc/2/db')
        self.common_proxy = xmlrpc.client.ServerProxy(f'{ODOO_URL}/xmlrpc/2/common')
        self.object_proxy = xmlrpc.client.ServerProxy(f'{ODOO_URL}/xmlrpc/2/object')

    def list_databases(self):
        """Liste les bases de données existantes."""
        try:
            return self.db_proxy.list()
        except Exception as e:
            logger.error(f"Erreur lors du listing des bases Odoo: {e}")
            raise e

    def database_exists(self, db_name: str) -> bool:
        dbs = self.list_databases()
        return db_name in dbs

    def duplicate_database(self, original_db_name: str, new_db_name: str):
        logger.info(f"Duplication de {original_db_name} vers {new_db_name}...")
        try:
            self.db_proxy.duplicate_database(
                ODOO_MASTER_PASSWORD,
                original_db_name,
                new_db_name
            )
            logger.info(f"Duplication réussie : {new_db_name}")
            return True
        except Exception as e:
            logger.error(f"Erreur duplication {original_db_name}->{new_db_name}: {e}")
            raise e
            
    def drop_database(self, db_name: str):
        """Supprime DÉFINITIVEMENT une base de données."""
        logger.warning(f"Demande de suppression de la base {db_name}...")
        try:
            self.db_proxy.drop(
                ODOO_MASTER_PASSWORD,
                db_name
            )
            logger.info(f"Base {db_name} supprimée.")
            return True
        except Exception as e:
            logger.error(f"Erreur suppression {db_name}: {e}")
            raise e

    def reset_admin_password(self, db_name: str, new_password: str):
        """
        Réinitialise le mot de passe admin en copiant le hash depuis le master-template.
        Le paramètre new_password est ignoré ici, on remet le mdp du master par défaut.
        """
        if not ODOO_DB_URL:
            logger.error("ODOO_DB_URL non configurée")
            return False
            
        MASTER_DB = "master-template"
        ADMIN_LOGIN = "admin"

        try:
            base_url = ODOO_DB_URL.rsplit('/', 1)[0]
            
            # 1. Récupérer le hash du master
            conn_master = psycopg2.connect(f"{base_url}/{MASTER_DB}")
            cursor_master = conn_master.cursor()
            cursor_master.execute("SELECT password FROM res_users WHERE login = %s", (ADMIN_LOGIN,))
            result = cursor_master.fetchone()
            conn_master.close()
            
            if not result or not result[0]:
                logger.error(f"Impossible de trouver le hash admin sur {MASTER_DB}")
                return False
                
            master_hash = result[0]
            
            # 2. Appliquer le hash sur la cible
            conn_target = psycopg2.connect(f"{base_url}/{db_name}")
            conn_target.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
            cursor_target = conn_target.cursor()
            
            # On update l'user admin (id=2 souvent, ou par login)
            cursor_target.execute("UPDATE res_users SET password = %s WHERE login = %s", (master_hash, ADMIN_LOGIN))
            
            # On force aussi l'invalidation du cache en changeant la colonne write_date
            cursor_target.execute("UPDATE res_users SET write_date = NOW() WHERE login = %s", (ADMIN_LOGIN,))
            
            updated_rows = cursor_target.rowcount
            conn_target.close()
            
            if updated_rows > 0:
                logger.info(f"Mot de passe admin réinitialisé pour {db_name} (copié depuis master)")
                return True
            else:
                logger.warning(f"Utilisateur admin introuvable sur {db_name}")
                return False

        except Exception as e:
            logger.error(f"Erreur SQL Reset Password : {e}")
            return False

    def install_module(self, db_name: str, user_password: str, module_name: str = "website"):
        try:
            uid = self.common_proxy.authenticate(db_name, 'admin', user_password, {})
            if not uid: return False
            models = xmlrpc.client.ServerProxy(f'{ODOO_URL}/xmlrpc/2/object')
            module_ids = models.execute_kw(db_name, uid, user_password, 'ir.module.module', 'search', [[['name', '=', module_name]]])
            if module_ids:
                models.execute_kw(db_name, uid, user_password, 'ir.module.module', 'button_immediate_install', [module_ids])
                return True
            return False
        except Exception:
            return False

odoo_service = OdooService()