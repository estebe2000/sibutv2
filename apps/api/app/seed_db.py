import json
import os
from sqlmodel import Session, select, create_engine, SQLModel
from .models import Competency, EssentialComponent, LearningOutcome, Activity, ActivityType, Group, Resource

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@localhost:5432/skills_db")
engine = create_engine(DATABASE_URL)

CORE_DESCS = {
    "C1": "Conduire les actions marketing\n\nSituations :\n- en situation de développement d'un produit\n- en situation de développement d'un service\n- en situation de développement d'une activité non marchande",
    "C2": "Vendre une offre commerciale\n\nSituations :\n- en situation de vente en B to C\n- en situation de vente en B to B",
    "C3": "Communiquer l'offre commerciale\n\nSituations :\n- en situation de communication de l'offre en tant qu'annonceur\n- en situation de communication de l'offre en tant qu'agence de communication"
}

def seed():
    # Use relative path from this script's location
    base_dir = os.path.dirname(os.path.abspath(__file__))
    seed_file = os.path.join(base_dir, "data", "referentiel_final.json")
    
    with open(seed_file, "r", encoding='utf-8') as f:
        data = json.load(f)

    SQLModel.metadata.drop_all(engine)
    SQLModel.metadata.create_all(engine)

    with Session(engine) as session:
        prof_group = Group(name="Enseignants", year=0, pathway="Staff", formation_type="N/A")
        session.add(prof_group)

        # 1. Process Competencies
        for comp_data in data.get("competences", []):
            pathway = comp_data.get("parcours", "Tronc Commun")
            c_code = comp_data["code"]

            for level_data in comp_data.get("levels", []):
                level = level_data["niveau"]
                
                # Get description from CORE_DESCS or fallback to extracted
                desc = CORE_DESCS.get(c_code, comp_data.get("full_description", ""))
                
                comp = Competency(
                    code=c_code,
                    label=comp_data["nom"],
                    description=desc,
                    level=level,
                    pathway=pathway
                )
                session.add(comp); session.flush()

                for ce_item in comp_data.get("ce", []):
                    session.add(EssentialComponent(
                        code=ce_item["code"].replace('CEC', 'CE'),
                        label=ce_item["nom"],
                        level=level,
                        pathway=pathway,
                        competency_id=comp.id
                    ))
                
                for ac_item in level_data.get("ac", []):
                    session.add(LearningOutcome(
                        code=ac_item.get("full_code", ac_item["code"]),
                        label=ac_item["nom"],
                        description=ac_item.get("description", ""),
                        level=level,
                        pathway=ac_item.get("parcours", pathway),
                        competency_id=comp.id
                    ))
        
        session.commit()

        # 2. Process Resources
        for res_data in data.get("resources", []):
            res = Resource(
                code=res_data["code"],
                label=res_data["label"],
                description=res_data.get("description", ""),
                content=res_data.get("content", ""),
                hours=res_data.get("hours", 0),
                hours_details=res_data.get("hours_details", ""),
                targeted_competencies=res_data.get("targeted_competencies", ""),
                pathway=res_data.get("pathway", "Tronc Commun")
            )
            session.add(res); session.flush()
            for ac_code in res_data.get("ac_codes", []):
                lo = session.exec(select(LearningOutcome).where(LearningOutcome.code == ac_code)).first()
                if lo: res.learning_outcomes.append(lo)
        
        session.commit()

        # 3. Process Activities
        for act_data in data.get("activities", []):
            if not act_data["nom"] or len(act_data["nom"]) < 3: continue
            act_type = ActivityType.SAE
            if act_data["type"] == "STAGE": act_type = ActivityType.STAGE
            elif act_data["type"] == "PROJET": act_type = ActivityType.PROJET
            elif act_data["type"] == "PORTFOLIO": act_type = ActivityType.PORTFOLIO

            act = Activity(
                code=act_data["code"],
                label=act_data["nom"].split(' . . .')[0],
                description=act_data.get("description", ""),
                type=act_type,
                level=act_data["niveau"],
                semester=act_data.get("semestre", 1), 
                pathway=act_data["pathway"],
                resources=", ".join(act_data.get("resources", [])),
                hours=act_data.get("hours", 0)
            )
            session.add(act); session.flush()
            for ac_code in act_data.get("ac_codes", []):
                # Search for the AC
                lo = session.exec(select(LearningOutcome).where(LearningOutcome.code == ac_code)).first()
                if not lo:
                    # Fallback: search for the base code (first 7 chars e.g., AC24.01)
                    base_ac = ac_code[:7]
                    lo = session.exec(select(LearningOutcome).where(LearningOutcome.code == base_ac)).first()
                
                if lo: 
                    act.learning_outcomes.append(lo)
                else:
                    print(f"Warning: Could not link AC {ac_code} to activity {act.code}")

        session.commit()
    print("Seeding complete with robust descriptions!")

if __name__ == "__main__": seed()