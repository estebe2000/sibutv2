from sqlmodel import create_engine, SQLModel, Session
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@localhost:5432/skills_db")

engine = create_engine(DATABASE_URL)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session
