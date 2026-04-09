import json
import os
from sqlmodel import Session, select, create_engine, SQLModel
from ..models.models import Competency, EssentialComponent, LearningOutcome, Activity, ActivityType, Resource
from ..core.config import settings

engine = create_engine(settings.DATABASE_URL)

def seed():
    # Path to the shared referentiel
    seed_file = "/app/app/data_source/referentiel_final.json"
    
    if not os.path.exists(seed_file):
        print(f"Error: Seed file not found at {seed_file}")
        return

    with open(seed_file, "r", encoding='utf-8') as f:
        data = json.load(f)

    # Create tables automatically based on SQLModel metadata
    print("[*] Creating database tables...")
    SQLModel.metadata.create_all(engine)

    with Session(engine) as session:
        # 1. Competencies
        print("[*] Seeding Competencies...")
        for comp_data in data.get("competences", []):
            pathway = comp_data.get("parcours", "Tronc Commun")
            c_code = comp_data["code"]

            for level_data in comp_data.get("levels", []):
                level = level_data["niveau"]
                
                # UPSERT
                comp = session.exec(select(Competency).where(Competency.code == c_code, Competency.level == level, Competency.pathway == pathway)).first()
                if not comp:
                    comp = Competency(code=c_code, label=comp_data["nom"], level=level, pathway=pathway)
                
                comp.description = comp_data.get("full_description", "")
                comp.situations_pro = comp_data.get("situations_pro", "")
                session.add(comp); session.flush()

                for ce_item in comp_data.get("ce", []):
                    ce_code = ce_item["code"].replace('CEC', 'CE')
                    ce = session.exec(select(EssentialComponent).where(EssentialComponent.code == ce_code, EssentialComponent.competency_id == comp.id)).first()
                    if not ce:
                        ce = EssentialComponent(code=ce_code, competency_id=comp.id)
                    ce.label = ce_item["nom"]
                    ce.level = level
                    ce.pathway = pathway
                    session.add(ce)
                
                for ac_item in level_data.get("ac", []):
                    ac_code = ac_item.get("full_code", ac_item["code"])
                    lo = session.exec(select(LearningOutcome).where(LearningOutcome.code == ac_code)).first()
                    if not lo:
                        lo = LearningOutcome(code=ac_code, competency_id=comp.id)
                    lo.label = ac_item["nom"]
                    lo.description = ac_item.get("description", "")
                    lo.level = level
                    lo.pathway = ac_item.get("parcours", pathway)
                    session.add(lo)
        
        session.commit()

        # 2. Resources
        print("[*] Seeding Resources...")
        for res_data in data.get("resources", []):
            res_code = res_data["code"]
            res = session.exec(select(Resource).where(Resource.code == res_code)).first()
            if not res:
                res = Resource(code=res_code)
            
            res.label = res_data["label"]
            res.description = res_data.get("description", "")
            res.content = res_data.get("content", "")
            res.hours = res_data.get("hours", 0)
            res.pathway = res_data.get("pathway", "Tronc Commun")
            session.add(res); session.flush()
            
            res.learning_outcomes = []
            for ac_code in res_data.get("ac_codes", []):
                lo = session.exec(select(LearningOutcome).where(LearningOutcome.code == ac_code)).first()
                if lo: res.learning_outcomes.append(lo)
        
        session.commit()

        # 3. Activities
        print("[*] Seeding Activities...")
        for act_data in data.get("activities", []):
            if not act_data["nom"] or len(act_data["nom"]) < 3: continue
            act_code = act_data["code"]
            act = session.exec(select(Activity).where(Activity.code == act_code)).first()
            
            if not act:
                act = Activity(code=act_code)
            
            act_type = ActivityType.SAE
            if act_data["type"] == "STAGE": act_type = ActivityType.STAGE
            elif act_data["type"] == "PROJET": act_type = ActivityType.PROJET
            elif act_data["type"] == "PORTFOLIO": act_type = ActivityType.PORTFOLIO

            act.label = act_data["nom"].split(' . . .')[0]
            act.description = act_data.get("description", "")
            act.type = act_type
            act.level = act_data["niveau"]
            act.semester = act_data.get("semestre", 1)
            act.pathway = act_data["pathway"]
            act.resources = ", ".join(act_data.get("resources", []))
            
            session.add(act); session.flush()
            
            act.learning_outcomes = []
            for ac_code in act_data.get("ac_codes", []):
                lo = session.exec(select(LearningOutcome).where(LearningOutcome.code == ac_code)).first()
                if lo: act.learning_outcomes.append(lo)
        
        session.commit()
    print("[SUCCESS] Remaster Seed Complete!")

if __name__ == "__main__": seed()
