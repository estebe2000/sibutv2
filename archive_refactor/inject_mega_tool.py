import sqlite3
import datetime
import json
import os

conn = sqlite3.connect('/app/backend/data/webui.db')
cur = conn.cursor()
cur.execute('SELECT id FROM user LIMIT 1')
res = cur.fetchone()
if res:
    user_id = res[0]

    tool_code = (
        '"""
'
        'title: BUT TC Super Assistant
'
        'author: System
'
        'version: 2.0
'
        'description: Suite complete d outils pour interroger la base PostgreSQL sur les professeurs, les cours, les SAE et les competences.
'
        '"""
'
        'import os
'
        'import psycopg2
'
        '
'
        'class Tools:
'
        '    def __init__(self):
'
        '        self.db_host = "host.docker.internal"
'
        '        self.db_user = "app_user"
'
        '        self.db_pass = "app_password"
'
        '        self.db_name = "skills_db"
'
        '
'
        '    def _get_connection(self):
'
        '        try:
'
        '            return psycopg2.connect(
'
        '                host=self.db_host,
'
        '                port="5432",
'
        '                user=self.db_user,
'
        '                password=self.db_pass,
'
        '                dbname=self.db_name
'
        '            )
'
        '        except Exception as e:
'
        '            return None
'
        '
'
        '    def get_course_details(self, code: str) -> str:
'
        '        """
'
        '        Trouve les details complets d un cours ou SAE a partir de son code.
'
        '        :param code: Le code officiel (ex: R1.13)
'
        '        """
'
        '        conn = self._get_connection()
'
        '        if not conn: return "Erreur de base de donnees."
'
        '        try:
'
        '            cur = conn.cursor()
'
        '            cur.execute("SELECT label, description, content, targeted_competencies, hours, pathway FROM resource WHERE code ILIKE %s", (f"%{code}%",))
'
        '            res = cur.fetchone()
'
        '            if res:
'
        '                out = "Ressource " + code.upper() + " : " + str(res[0]) + "
Parcours : " + str(res[5]) + "
Heures : " + str(res[4]) + "
Competences : " + str(res[3]) + "

Description : " + str(res[1]) + "
Contenu : " + str(res[2])
'
        '                cur.close()
'
        '                conn.close()
'
        '                return out
'
        '            
'
        '            cur.execute("SELECT label, description, pathway, semester FROM activity WHERE code ILIKE %s", (f"%{code}%",))
'
        '            act = cur.fetchone()
'
        '            if act:
'
        '                out = "Activite " + code.upper() + " : " + str(act[0]) + "
Semestre : " + str(act[3]) + "
Parcours : " + str(act[2]) + "

Description :
" + str(act[1])
'
        '                cur.close()
'
        '                conn.close()
'
        '                return out
'
        '                
'
        '            cur.close()
'
        '            conn.close()
'
        '            return "Aucun cours ou SAE nomme " + code + " n existe en base."
'
        '        except Exception as e:
'
        '            return "Erreur SQL : " + str(e)
'
        '
'
        '    def get_teacher_details(self, name: str) -> str:
'
        '        """
'
        '        Trouve les informations d un enseignant et son historique de responsabilites.
'
        '        :param name: Le nom, prenom ou identifiant LDAP
'
        '        """
'
        '        conn = self._get_connection()
'
        '        if not conn: return "Erreur de base de donnees."
'
        '        try:
'
        '            cur = conn.cursor()
'
        '            cur.execute("SELECT id, full_name, ldap_uid, email, role FROM "user" WHERE full_name ILIKE %s OR ldap_uid ILIKE %s LIMIT 1", (f"%{name}%", f"%{name}%"))
'
        '            user = cur.fetchone()
'
        '            if not user:
'
        '                cur.close()
'
        '                conn.close()
'
        '                return "Aucun enseignant trouve pour " + name
'
        '                
'
        '            uid, full_name, ldap_uid, email, role = user
'
        '            out = "=== PROFIL ENSEIGNANT : " + str(full_name) + " ===
LDAP : " + str(ldap_uid) + "
Email : " + str(email) + "
Role Systeme : " + str(role) + "

HISTORIQUE DES RESPONSABILITES :
"
'
        '            
'
        '            cur.execute("SELECT role_type, entity_type, entity_id, academic_year FROM responsibilitymatrix WHERE user_id = %s OR user_id = %s", (ldap_uid, str(uid)))
'
        '            resps = cur.fetchall()
'
        '            if not resps:
'
        '                out += "Aucune responsabilite officielle dans la matrice."
'
        '            else:
'
        '                for r in resps:
'
        '                    out += "- " + str(r[0]) + " sur l'entite " + str(r[1]) + " " + str(r[2]) + " (Annee " + str(r[3]) + ")
"
'
        '            
'
        '            cur.close()
'
        '            conn.close()
'
        '            return out
'
        '        except Exception as e:
'
        '            return "Erreur SQL : " + str(e)
'
        '
'
        '    def get_who_is_responsible(self, entity_code: str) -> str:
'
        '        """
'
        '        Trouve qui est le responsable (OWNER) ou l intervenant d un cours, dune SAE ou d un groupe.
'
        '        :param entity_code: Le code exact (ex: R1.13, SAE 4.01)
'
        '        """
'
        '        conn = self._get_connection()
'
        '        if not conn: return "Erreur de base de donnees."
'
        '        try:
'
        '            cur = conn.cursor()
'
        '            cur.execute("SELECT user_id, role_type, academic_year FROM responsibilitymatrix WHERE entity_id ILIKE %s", (f"%{entity_code}%",))
'
        '            resps = cur.fetchall()
'
        '            
'
        '            if not resps:
'
        '                # Fallback to check legacy column
'
        '                cur.execute("SELECT responsible FROM resource WHERE code ILIKE %s", (f"%{entity_code}%",))
'
        '                legacy = cur.fetchone()
'
        '                if legacy and legacy[0]:
'
        '                    cur.close(); conn.close()
'
        '                    return "Le responsable enregistre dans l ancien format est : " + str(legacy[0])
'
        '                cur.close(); conn.close()
'
        '                return "Personne n'est enregistre comme responsable de " + entity_code + " dans la matrice."
'
        '                
'
        '            out = "Equipe responsable pour " + entity_code + " :
"
'
        '            for r in resps:
'
        '                user_id, role_type, year = r
'
        '                cur.execute("SELECT full_name FROM "user" WHERE ldap_uid = %s OR id::text = %s", (user_id, user_id))
'
        '                u = cur.fetchone()
'
        '                name = u[0] if u else user_id
'
        '                out += "- " + str(name) + " a le role de " + str(role_type) + " (Annee " + str(year) + ")
"
'
        '                
'
        '            cur.close()
'
        '            conn.close()
'
        '            return out
'
        '        except Exception as e:
'
        '            return "Erreur SQL : " + str(e)
'
    )
    
    tool_id = 'but_tc_super_assistant'
    name = 'BUT TC Super Assistant'
    meta = json.dumps({'description': 'Suite d outils professionnels pour l'equipe TC (Professeurs, Cours, Responsabilites).'})
    
    specs = json.dumps([
        {
            "name": "get_course_details",
            "description": "Trouve les details complets d un cours ou SAE a partir de son code. Indispensable pour creer des TPs ou resumer un cours.",
            "parameters": {
                "type": "object",
                "properties": {
                    "code": {"type": "string", "description": "Le code officiel (ex: R1.13, SAE 4.01)"}
                },
                "required": ["code"]
            }
        },
        {
            "name": "get_teacher_details",
            "description": "Trouve les informations d un enseignant et tout son historique de responsabilites et ses matieres.",
            "parameters": {
                "type": "object",
                "properties": {
                    "name": {"type": "string", "description": "Le nom, prenom ou identifiant LDAP de l enseignant"}
                },
                "required": ["name"]
            }
        },
        {
            "name": "get_who_is_responsible",
            "description": "Trouve les responsables, les proprietaires (OWNER) ou les intervenants d un cours specifique.",
            "parameters": {
                "type": "object",
                "properties": {
                    "entity_code": {"type": "string", "description": "Le code exact du cours (ex: R1.13, SAE 4.01)"}
                },
                "required": ["entity_code"]
            }
        }
    ])
    
    try:
        now = int(datetime.datetime.now().timestamp())
        # Delete old tool if it exists to clean up UI
        cur.execute("DELETE FROM tool WHERE id = 'course_finder'")
        cur.execute("INSERT OR REPLACE INTO tool (id, name, content, specs, meta, user_id, updated_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
                   (tool_id, name, tool_code, specs, meta, user_id, now, now))
        conn.commit()
        print('Super Tool insere directement dans la base de donnees sqlite avec succes !')
    except Exception as e:
        print(f'Erreur insertion BDD: {e}')
