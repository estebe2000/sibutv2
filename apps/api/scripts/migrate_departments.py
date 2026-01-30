from sqlmodel import Session, select, create_engine
from app.models import Department, Pathway, Competency, Resource, Activity, Group, User
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@localhost:5432/skills_db")
engine = create_engine(DATABASE_URL)

def migrate_to_departments():
    with Session(engine) as session:
        # 1. Create Default Department "Techniques de Commercialisation"
        tc_dept = session.exec(select(Department).where(Department.code == "TC")).first()
        if not tc_dept:
            print("Creating TC Department...")
            tc_dept = Department(code="TC", label="Techniques de Commercialisation")
            session.add(tc_dept)
            session.commit()
            session.refresh(tc_dept)

        # 2. Migrate existing Pathways (based on hardcoded values in frontend/seed)
        # Assuming existing pathway strings are: "BDMRC", "BI", "MDEE", "MMPV", "SME", "Tronc Commun"
        known_pathways = ["BDMRC", "BI", "MDEE", "MMPV", "SME", "Tronc Commun"]

        for p_code in known_pathways:
            pathway = session.exec(select(Pathway).where(Pathway.code == p_code, Pathway.department_id == tc_dept.id)).first()
            if not pathway:
                print(f"Creating Pathway {p_code}...")
                pathway = Pathway(code=p_code, label=p_code, department_id=tc_dept.id)
                session.add(pathway)
        session.commit()

        # 3. Associate Existing Data to TC Department
        print("Migrating Resources...")
        resources = session.exec(select(Resource).where(Resource.department_id == None)).all()
        for r in resources:
            r.department_id = tc_dept.id
            session.add(r)

        print("Migrating Activities...")
        activities = session.exec(select(Activity).where(Activity.department_id == None)).all()
        for a in activities:
            a.department_id = tc_dept.id
            session.add(a)

        print("Migrating Competencies...")
        competencies = session.exec(select(Competency).where(Competency.department_id == None)).all()
        for c in competencies:
            c.department_id = tc_dept.id
            session.add(c)

        print("Migrating Groups...")
        groups = session.exec(select(Group).where(Group.department_id == None)).all()
        for g in groups:
            g.department_id = tc_dept.id
            session.add(g)

        print("Migrating Users...")
        users = session.exec(select(User).where(User.department_id == None)).all()
        for u in users:
            u.department_id = tc_dept.id
            session.add(u)

        session.commit()
        print("Migration Complete.")

if __name__ == "__main__":
    migrate_to_departments()
