import sqlite3
import jwt
import datetime
import urllib.request
import json
import os

try:
    from open_webui.env import WEBUI_SECRET_KEY
    secret = WEBUI_SECRET_KEY
except:
    secret = os.environ.get('WEBUI_SECRET_KEY', 'CHANGEME')

conn = sqlite3.connect('/app/backend/data/webui.db')
cur = conn.cursor()
cur.execute('SELECT id FROM user LIMIT 1')
res = cur.fetchone()
if res:
    user_id = res[0]
    payload = {'id': user_id, 'exp': datetime.datetime.utcnow() + datetime.timedelta(days=365)}
    token = jwt.encode(payload, secret, algorithm='HS256')

    tool_code = """\"\"\"
title: Course Information Finder (BUT TC)
author: Assistant
version: 1.0
description: Fetch detailed course or activity information from the BUT TC PostgreSQL database by using their code (e.g., R1.13, SAE 4.01).
\"\"\"
import os
import psycopg2
from typing import Dict, Any

class Tools:
    def __init__(self):
        self.db_host = os.environ.get("POSTGRES_HOST", "but_tc_db")
        self.db_user = os.environ.get("POSTGRES_USER", "skills_user")
        self.db_pass = os.environ.get("POSTGRES_PASSWORD", "skills_password")
        self.db_name = os.environ.get("POSTGRES_DB", "skills_hub")

    def _get_connection(self):
        try:
            return psycopg2.connect(
                host=self.db_host,
                port="5432",
                user=self.db_user,
                password=self.db_pass,
                dbname=self.db_name
            )
        except Exception as e:
            return None

    def get_course_details(self, code: str) -> str:
        \"\"\"
        Fetch course details.
        :param code: course code.
        \"\"\"
        conn = self._get_connection()
        if not conn:
            return "Erreur: Impossible de se connecter a la base PostgreSQL."
        
        try:
            cur = conn.cursor()
            cur.execute("SELECT label, description, content, targeted_competencies, hours, pathway FROM resource WHERE code ILIKE %s", (f"%{code}%",))
            res = cur.fetchone()
            if res:
                title, desc, content, comp, hours, pathway = res
                out = f"Ressource {code.upper()} : {title}\\nParcours : {pathway}\\nHeures : {hours}\\nCompetences : {comp}\\n\\nDescription : {desc}\\n\\nContenu :\\n{content}"
                cur.close()
                conn.close()
                return out
                
            cur.execute("SELECT label, description, pathway, semester FROM activity WHERE code ILIKE %s", (f"%{code}%",))
            act = cur.fetchone()
            if act:
                title, desc, pathway, sem = act
                out = f"Activite {code.upper()} : {title}\\nSemestre : {sem}\\nParcours : {pathway}\\n\\nDescription :\\n{desc}"
                cur.close()
                conn.close()
                return out

            cur.close()
            conn.close()
            return f"Aucune information trouvée pour {code}."

        except Exception as e:
            return f"Erreur SQL: {str(e)}"
"""
    
    url = 'http://localhost:8080/api/v1/tools/create'
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    data = {
        'id': 'course_finder',
        'name': 'Course Information Finder (BUT TC)',
        'content': tool_code,
        'meta': {'description': 'Fetch detailed course or activity information from the PostgreSQL database'}
    }
    
    req = urllib.request.Request(url, method='POST', headers=headers)
    req.data = json.dumps(data).encode('utf-8')
    try:
        with urllib.request.urlopen(req) as response:
            print(f'Outil cree avec succes !')
    except Exception as e:
        print(f'Erreur API: {e}')
