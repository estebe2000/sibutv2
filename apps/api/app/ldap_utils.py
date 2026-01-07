from ldap3 import Server, Connection, ALL
import os

LDAP_URL = os.getenv("LDAP_URL", "ldap://localhost:389")
LDAP_BASE_DN = os.getenv("LDAP_BASE_DN", "dc=univ,dc=fr")

def get_ldap_connection(user_dn=None, password=None):
    server = Server(LDAP_URL, get_info=ALL)
    if user_dn and password:
        return Connection(server, user_dn, password, auto_bind=True)
    else:
        # Default admin bind
        return Connection(server, 'cn=admin,' + LDAP_BASE_DN, 'adminpassword', auto_bind=True)

def verify_credentials(username, password):
    """
    Tries to bind to LDAP with the given username (uid) and password.
    Returns True if successful, False otherwise.
    """
    # 1. Find the user DN first (using admin bind)
    try:
        conn = get_ldap_connection()
        conn.search(LDAP_BASE_DN, f'(uid={username})', attributes=['entryDN'])
        if not conn.entries:
            return False
        user_dn = conn.entries[0].entryDN
        
        # 2. Try to bind with this DN and password
        user_conn = get_ldap_connection(str(user_dn), password)
        user_conn.unbind()
        return True
    except Exception as e:
        print(f"LDAP Auth Error: {e}")
        return False

def get_ldap_users():
    conn = get_ldap_connection()
    # Search for people
    conn.search('ou=people,' + LDAP_BASE_DN, '(objectClass=inetOrgPerson)', attributes=['uid', 'sn', 'givenName', 'mail', 'displayName'])
    
    users = []
    for entry in conn.entries:
        users.append({
            "uid": str(entry.uid),
            "full_name": str(entry.displayName or f"{entry.givenName} {entry.sn}"),
            "email": str(entry.mail)
        })
    return users
