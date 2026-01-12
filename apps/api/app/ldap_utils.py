from ldap3 import Server, Connection, ALL
import os

LDAP_URL = os.getenv("LDAP_URL", "ldap://localhost:389")
LDAP_BASE_DN = os.getenv("LDAP_BASE_DN", "dc=univ-lehavre,dc=fr")
LDAP_BIND_DN = os.getenv("LDAP_BIND_DN", "cn=admin," + LDAP_BASE_DN)
LDAP_BIND_PASSWORD = os.getenv("LDAP_BIND_PASSWORD", "Rangetachambre76*")

def get_ldap_connection(user_dn=None, password=None):
    server = Server(LDAP_URL, get_info=ALL)
    if user_dn and password:
        return Connection(server, user_dn, password, auto_bind=True)
    else:
        return Connection(server, LDAP_BIND_DN, LDAP_BIND_PASSWORD, auto_bind=True)

def verify_credentials(username, password):
    """
    Tries to bind to LDAP with the given username (uid) and password.
    Returns True if successful, False otherwise.
    """
    # 1. Find the user DN first (using bind user)
    try:
        conn = get_ldap_connection()
        conn.search(LDAP_BASE_DN, f'(uid={username})')
        if not conn.entries:
            return False
        user_dn = conn.entries[0].entry_dn
        
        # 2. Try to bind with this DN and password
        user_conn = get_ldap_connection(str(user_dn), password)
        user_conn.unbind()
        return True
    except Exception as e:
        print(f"LDAP Auth Error: {e}")
        return False

def get_ldap_users():
    conn = get_ldap_connection()
    # Limite à 50 par défaut pour éviter de saturer l'affichage au chargement
    conn.search('ou=People,' + LDAP_BASE_DN, '(objectClass=inetOrgPerson)', 
                attributes=['uid', 'sn', 'givenName', 'mail', 'displayName'],
                size_limit=50)
    
    users = []
    for entry in conn.entries:
        users.append({
            "uid": str(entry.uid),
            "full_name": str(entry.displayName or f"{entry.givenName} {entry.sn}"),
            "email": str(entry.mail)
        })
    return users

def get_ldap_user_by_filter(search_filter):
    """
    Cherche un utilisateur unique dans le LDAP selon un filtre personnalisé.
    """
    try:
        conn = get_ldap_connection()
        conn.search('ou=People,' + LDAP_BASE_DN, search_filter, attributes=['uid', 'sn', 'givenName', 'mail', 'displayName'])
        if not conn.entries:
            return None
        
        entry = conn.entries[0]
        return {
            "uid": str(entry.uid),
            "full_name": str(entry.displayName or f"{entry.givenName} {entry.sn}"),
            "email": str(entry.mail)
        }
    except Exception as e:
        print(f"LDAP Search Error: {e}")
        return None

def search_ldap_users(query: str, limit: int = 100):
    """
    Recherche des utilisateurs dans le LDAP par UID ou Nom partiel.
    Limite augmentée à 100 pour les recherches explicites.
    """
    try:
        conn = get_ldap_connection()
        # Filtre de recherche : UID ou Nom ou Prénom commençant par la query
        search_filter = f'(|(uid={query}*)(sn={query}*)(givenName={query}*)(displayName={query}*))'
        conn.search('ou=People,' + LDAP_BASE_DN, search_filter, 
                    attributes=['uid', 'sn', 'givenName', 'mail', 'displayName'],
                    size_limit=limit)
        
        users = []
        for entry in conn.entries:
            users.append({
                "uid": str(entry.uid),
                "full_name": str(entry.displayName or f"{entry.givenName} {entry.sn}"),
                "email": str(entry.mail)
            })
        return users
    except Exception as e:
        print(f"LDAP Search Error: {e}")
        return []
