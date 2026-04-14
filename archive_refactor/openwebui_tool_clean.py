"""
title: Course Information Finder (BUT TC)
author: Assistant
version: 1.0
description: Fetch detailed course or activity information from the BUT TC PostgreSQL database by using their code (e.g., R1.13, SAE 4.01).
"""
import os
import psycopg2

class Tools:
    def __init__(self):
        # Override with env vars if present in webui
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
        """
        Trouve les details complets d'un cours (Ressource) ou d'une activite (SAE) a partir de son code.
        :param code: Le code officiel du cours ou de l'activite (ex: "R1.13", "SAE 4.01", "R2.10").
        :return: Une description textuelle complete de l'element pedagogique.
        """
        conn = self._get_connection()
        if not conn:
            return "Erreur: Impossible de se connecter a la base de donnees PostgreSQL."
        
        try:
            cur = conn.cursor()
            
            # Recherche dans les Ressources (R1.13 etc)
            cur.execute("SELECT label, description, content, targeted_competencies, hours, pathway FROM resource WHERE code ILIKE %s", (f"%{code}%",))
            res = cur.fetchone()
            if res:
                title, desc, content, comp, hours, pathway = res
                out = f"Ressource {code.upper()} : {title}
Parcours : {pathway}
Heures : {hours}
Competences : {comp}

Description : {desc}

Contenu :
{content}"
                cur.close()
                conn.close()
                return out
                
            # Recherche dans les Activites (SAE 4.01 etc)
            cur.execute("SELECT label, description, pathway, semester FROM activity WHERE code ILIKE %s", (f"%{code}%",))
            act = cur.fetchone()
            if act:
                title, desc, pathway, sem = act
                out = f"Activite {code.upper()} : {title}
Semestre : {sem}
Parcours : {pathway}

Description :
{desc}"
                cur.close()
                conn.close()
                return out

            cur.close()
            conn.close()
            return f"Aucune information trouvee en base pour le code {code}."

        except Exception as e:
            return f"Erreur SQL lors de la recherche: {str(e)}"
