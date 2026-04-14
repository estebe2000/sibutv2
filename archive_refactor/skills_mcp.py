from mcp.server.fastmcp import FastMCP
import psycopg2
import os
import json

# Configuration de la connexion PostgreSQL
DB_HOST = "host.docker.internal"
DB_PORT = "5432"
DB_USER = "app_user"
DB_PASS = "app_password" 
DB_NAME = "skills_db"

# Initialisation du serveur MCP
mcp = FastMCP("SkillsHub-DB")

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASS,
            dbname=DB_NAME
        )
        return conn
    except Exception as e:
        print(f"Erreur connexion DB: {e}")
        return None

@mcp.tool()
def search_resources(query: str, semester: int = None) -> str:
    """
    Cherche des ressources pédagogiques (cours) dans la base de données.
    Args:
        query: Mots-clés pour la recherche (titre ou code).
        semester: (Optionnel) Numéro du semestre (1 à 6).
    """
    conn = get_db_connection()
    if not conn:
        return "Erreur: Impossible de se connecter à la base de données."
    
    try:
        cur = conn.cursor()
        
        # Base query
        sql = "SELECT code, label, description FROM resource WHERE (label ILIKE %s OR code ILIKE %s)"
        params = [f"%{query}%", f"%{query}%"]
        
        # Filtering by semester using code convention R{semester}.%
        if semester:
            sql += " AND code LIKE %s"
            # Pattern: R1.% for sem 1, R2.% for sem 2
            params.append(f"R{semester}.%")
            
        cur.execute(sql, tuple(params))
        results = cur.fetchall()
        
        if not results:
            return "Aucune ressource trouvée pour cette recherche."
            
        response = []
        for r in results:
            response.append({
                "code": r[0],
                "titre": r[1],
                "description_courte": r[2][:100] + "..." if r[2] else "Pas de description"
            })
        return json.dumps(response, ensure_ascii=False)
    except Exception as e:
        return f"Erreur SQL: {e}"
    finally:
        conn.close()

@mcp.tool()
def get_resource_details(code: str) -> str:
    """
    Récupère TOUS les détails d'une ressource (cours) spécifique par son code (ex: R1.01).
    """
    conn = get_db_connection()
    if not conn: return "Erreur connexion DB."
    
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM resource WHERE code = %s", (code,))
        res = cur.fetchone()
        if not res: return f"Ressource {code} introuvable."
        
        col_names = [desc[0] for desc in cur.description]
        resource_data = dict(zip(col_names, res))
        
        return json.dumps(resource_data, ensure_ascii=False, default=str)
    except Exception as e:
        return f"Erreur: {e}"
    finally:
        conn.close()

@mcp.tool()
def get_teacher_details(name_query: str) -> str:
    """
    Trouve un enseignant par son nom et retourne ses infos.
    """
    conn = get_db_connection()
    if not conn: return "Erreur connexion DB."
    
    try:
        cur = conn.cursor()
        cur.execute('SELECT full_name, email, role FROM "user" WHERE full_name ILIKE %s', (f"%{name_query}%",))
        users = cur.fetchall()
        
        if not users: return "Aucun enseignant trouvé."
        
        response = []
        for u in users:
            response.append({"nom": u[0], "email": u[1], "role": u[2]})
            
        return json.dumps(response, ensure_ascii=False)
    except Exception as e:
        return f"Erreur: {e}"
    finally:
        conn.close()

@mcp.tool()
def get_sae_list(semester: int = None) -> str:
    """
    Liste les Situations d'Apprentissage et d'Évaluation (SAÉ).
    Args:
        semester: (Optionnel) Numéro du semestre.
    """
    conn = get_db_connection()
    if not conn: return "Erreur connexion DB."
    
    try:
        cur = conn.cursor()
        sql = "SELECT code, label, description, semester FROM activity"
        params = []
        
        if semester:
            sql += " WHERE semester = %s"
            params.append(semester)
            
        cur.execute(sql, tuple(params))
        results = cur.fetchall()
        
        response = []
        for r in results:
            response.append({
                "code": r[0],
                "titre": r[1],
                "semestre": r[3],
                "description": r[2][:100] + "..." if r[2] else ""
            })
        return json.dumps(response, ensure_ascii=False)
    except Exception as e:
        return f"Erreur: {e}"
    finally:
        conn.close()

if __name__ == "__main__":
    mcp.run()
