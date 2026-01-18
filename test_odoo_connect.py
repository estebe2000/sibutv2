import xmlrpc.client
import ssl

# Configuration (depuis l'intérieur du conteneur API vers Odoo)
# Note: Depuis le host (mac), on utiliserait https://odoo.educ-ai.fr
# Mais pour ce test, assumons qu'on l'exécute depuis le conteneur API ou qu'on tape l'URL publique.
# Tapons l'URL publique pour tester "comme un client".

url = 'https://odoo.educ-ai.fr'
db = 'odoo'
username = 'admin'
password = 'admin_password_if_created' 
master_password = 'Rangetachambre76*'

# Le endpoint 'db' gère la création/suppression de bases
# Il n'utilise pas xmlrpc standard pour la création dans toutes les versions, mais essayons le proxy 'db'.
# Sinon, c'est souvent via JSON-RPC sur /jsonrpc.

print(f"Connexion à {url}...")

try:
    # Test simple: Lister les bases via XML-RPC
    # Le endpoint 'db' est exposé sur /xmlrpc/2/db ou juste /xmlrpc/db selon versions
    common = xmlrpc.client.ServerProxy(f'{url}/xmlrpc/2/db')
    dbs = common.list()
    print(f"Bases de données existantes : {dbs}")
    
    # Si ça marche, on est bon pour la suite (création)
    
except Exception as e:
    print(f"Erreur : {e}")
