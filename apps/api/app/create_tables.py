from sqlmodel import SQLModel, create_engine
import os
from models import Company, Internship # Ensure they are imported so SQLModel knows about them

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@db:5432/skills_db")
engine = create_engine(DATABASE_URL)

def create_tables():
    print("Creating tables...")
    SQLModel.metadata.create_all(engine)
    print("Tables created.")

if __name__ == "__main__":
    create_tables()
