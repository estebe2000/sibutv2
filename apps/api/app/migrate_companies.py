from sqlmodel import Session, select, create_engine
from models import Internship, Company
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@localhost:5432/skills_db")
engine = create_engine(DATABASE_URL)

def migrate():
    with Session(engine) as session:
        # 1. Create companies from existing internships
        internships = session.exec(select(Internship)).all()
        print(f"Found {len(internships)} internships to process.")
        
        companies_map = {} # name -> Company object
        
        for intern in internships:
            if not intern.company_name:
                continue
                
            name = intern.company_name.strip()
            
            if name not in companies_map:
                # Check if company already exists (idempotency)
                existing_company = session.exec(select(Company).where(Company.name == name)).first()
                if existing_company:
                    companies_map[name] = existing_company
                else:
                    new_company = Company(
                        name=name,
                        address=intern.company_address,
                        phone=intern.company_phone,
                        email=intern.company_email
                    )
                    session.add(new_company)
                    session.flush() # Get ID
                    companies_map[name] = new_company
            
            # 2. Link internship to company
            intern.company_id = companies_map[name].id
            session.add(intern)
            
        session.commit()
        print(f"Migration complete. {len(companies_map)} companies created/linked.")

if __name__ == "__main__":
    migrate()
