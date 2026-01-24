import os
from sqlmodel import Session, select, create_engine
from .models import User, UserRole, Group

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@localhost:5432/skills_db")
engine = create_engine(DATABASE_URL)

def create_test_users():
    with Session(engine) as session:
        # 1. S'assurer que les groupes de base existent
        prof_group = session.exec(select(Group).where(Group.name == "Enseignants")).first()
        if not prof_group:
            prof_group = Group(name="Enseignants", year=0, pathway="Staff", formation_type="N/A")
            session.add(prof_group)
        
        student_group = session.exec(select(Group).where(Group.name == "BUT 1 - Gr A")).first()
        if not student_group:
            student_group = Group(name="BUT 1 - Gr A", year=1, pathway="Tronc Commun", formation_type="FI")
            session.add(student_group)
        
        session.commit()
        session.refresh(prof_group)
        session.refresh(student_group)

        # 2. Liste des utilisateurs à créer
        users_to_create = [
            {"uid": "tata", "name": "Admin Tata", "role": UserRole.SUPER_ADMIN, "group": prof_group.id},
            {"uid": "tbtb", "name": "Directeur Etude Tbtb", "role": UserRole.STUDY_DIRECTOR, "group": prof_group.id},
            {"uid": "tctc", "name": "Enseignant Tctc", "role": UserRole.PROFESSOR, "group": prof_group.id},
            {"uid": "tdtd", "name": "Etudiant Tdtd", "role": UserRole.STUDENT, "group": student_group.id},
        ]

        for u_data in users_to_create:
            existing = session.exec(select(User).where(User.ldap_uid == u_data["uid"])).first()
            if existing:
                print(f"Utilisateur {u_data['uid']} existe déjà. Mise à jour du rôle.")
                existing.role = u_data["role"]
                existing.full_name = u_data["name"]
                session.add(existing)
            else:
                new_user = User(
                    ldap_uid=u_data["uid"],
                    email=f"{u_data['uid']}@univ-test.fr",
                    full_name=u_data["name"],
                    role=u_data["role"],
                    group_id=u_data["group"]
                )
                session.add(new_user)
                print(f"Utilisateur {u_data['uid']} créé.")
        
        session.commit()
    print("Test users creation complete!")

if __name__ == "__main__":
    create_test_users()
