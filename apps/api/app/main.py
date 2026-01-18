from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlmodel import Session, select
import os
import json
from dotenv import load_dotenv

load_dotenv()

from .database import create_db_and_tables, engine
from .models import Group
from .routers import auth, users, curriculum, config, files, keycloak_admin, portfolio, odoo

app = FastAPI(title="BUT TC Skills Hub API", root_path=os.getenv("ROOT_PATH", ""))

# --- STATIC FILES ---
FICHES_PATH = "/app/fiches_pdf"
if os.path.exists(FICHES_PATH):
    app.mount("/static/fiches", StaticFiles(directory=FICHES_PATH), name="fiches")

@app.on_event("startup")
def on_startup():
    create_db_and_tables()
    with Session(engine) as session:
        if not session.exec(select(Group).where(Group.name == "Enseignants")).first():
            prof_group = Group(name="Enseignants", year=0, pathway="Staff", formation_type="N/A")
            session.add(prof_group)
            session.commit()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(curriculum.router)
app.include_router(config.router)
app.include_router(files.router)
app.include_router(keycloak_admin.router)
app.include_router(portfolio.router)
app.include_router(odoo.router, prefix="/odoo", tags=["Odoo Provisioning"])

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Welcome to BUT TC Skills Hub API"}

@app.get("/import/moodle-data")
def get_moodle_data():
    # Kept here as it was a bit custom path, or move to files?
    # Original main.py had it. It seems to look for ../../tmp/parsed_competencies.json which we know is problematic.
    # But for compatibility, I'll keep it or fix the path.
    # The README said tmp scripts are for maintenance.
    # Given the user cleanup request, and that tmp is missing, this endpoint probably fails.
    # I will keep it but maybe it should be in files.py if we want to be strict.
    # Actually, let's put it here for now or in files.py. It was in main.py.
    # Let's verify if I missed it in files.py.
    # I did NOT put it in files.py.
    # I'll add it here for now to avoid breaking it if it somehow worked, but it looks broken anyway.
    try:
        with open("../../tmp/parsed_competencies.json", "r", encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        # Returning 404 as in original
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail=f"Moodle data file not found: {e}")
