import os
import glob
from sqlmodel import Session, select
from app.database import engine
from app.models import Resource, Activity, User, ResponsibilityMatrix

def generate():
    with Session(engine) as session:
        users = session.exec(select(User)).all()
        resps = session.exec(select(ResponsibilityMatrix)).all()
        
        # 1. FICHIER RESSOURCES
        with open('/tmp/RAG_Resources.txt', 'w', encoding='utf-8') as f:
            f.write('=== CATALOGUE DES RESSOURCES (COURS) BUT TC ===

')
            resources = session.exec(select(Resource).order_by(Resource.code)).all()
            for r in resources:
                f.write(f'CODE: {r.code}
TITRE: {r.label}
PARCOURS: {r.pathway}
HORAIRES: {r.hours_details or r.hours}
')
                r_resps = [rm for rm in resps if rm.entity_type.name == 'RESOURCE' and rm.entity_id == r.code]
                names = []
                for rm in r_resps:
                    u = next((u.full_name for u in users if u.ldap_uid == rm.user_id or str(u.id) == rm.user_id), rm.user_id)
                    names.append(u)
                if names: f.write('RESPONSABLES: ' + ", ".join(names) + '
')
                f.write(f'COMPETENCES: {r.targeted_competencies}
DESCRIPTION: {r.description}
CONTENU: {r.content}

---
')

        # 2. FICHIER ACTIVITES
        with open('/tmp/RAG_Activities.txt', 'w', encoding='utf-8') as f:
            f.write('=== CATALOGUE DES SAE ET STAGES BUT TC ===

')
            activities = session.exec(select(Activity).order_by(Activity.code)).all()
            for a in activities:
                f.write(f'CODE: {a.code}
TITRE: {a.label}
TYPE: {a.type}
SEMESTRE: S{a.semester}
')
                a_resps = [rm for rm in resps if rm.entity_type.name == 'ACTIVITY' and rm.entity_id == str(a.id)]
                names = []
                for rm in a_resps:
                    u = next((u.full_name for u in users if u.ldap_uid == rm.user_id or str(u.id) == rm.user_id), rm.user_id)
                    names.append(u)
                if names: f.write('RESPONSABLES: ' + ", ".join(names) + '
')
                f.write(f'DESCRIPTION: {a.description}

---
')

        # 3. FICHIER FICHES LATEX
        with open('/tmp/RAG_Fiches_Pedagogiques.txt', 'w', encoding='utf-8') as f:
            f.write('=== FICHES D AIDE A L ENSEIGNEMENT (DETAILS TECHNIQUES) ===

')
            for filepath in glob.glob('/app/data_source/fiches/**/*.tex', recursive=True):
                try:
                    with open(filepath, 'r', encoding='utf-8') as tf:
                        content = tf.read().replace('\section*{', 'TITRE: ').replace('}', '').replace('	extbf{', '')
                        f.write(f'FICHE: {os.path.basename(filepath)}
{content}

---
')
                except: pass

if __name__ == "__main__":
    generate()
