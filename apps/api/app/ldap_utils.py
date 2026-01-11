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
    # Search for people in ou=People (Case sensitive in some LDAP)
    conn.search('ou=People,' + LDAP_BASE_DN, '(objectClass=inetOrgPerson)', attributes=['uid', 'sn', 'givenName', 'mail', 'displayName'])
    
    users = []
    for entry in conn.entries:
        users.append({
            "uid": str(entry.uid),
            "full_name": str(entry.displayName or f"{entry.givenName} {entry.sn}"),
            "email": str(entry.mail)
        })
    return users
