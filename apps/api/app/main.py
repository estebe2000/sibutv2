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
from .routers import auth, users, curriculum, config, files, keycloak_admin, portfolio, odoo, ai, groups_activity, internships, pedagogy, evaluation_builder, stats, public_eval, feedback, companies, applications, setup

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
app.include_router(setup.router)
app.include_router(files.router)
app.include_router(keycloak_admin.router)
app.include_router(portfolio.router, prefix="/portfolio", tags=["Portfolio"])
app.include_router(odoo.router, prefix="/odoo", tags=["Odoo Provisioning"])
app.include_router(groups_activity.router, prefix="/activity-management", tags=["Pedagogical Groups"])
app.include_router(internships.router, prefix="/internships", tags=["Internships"])
app.include_router(pedagogy.router, prefix="/pedagogy", tags=["Pedagogical Team"])
app.include_router(evaluation_builder.router, prefix="/evaluation-builder", tags=["Evaluation Rubrics"])
app.include_router(stats.router, prefix="/stats", tags=["Statistics"])
app.include_router(public_eval.router, prefix="/public-eval", tags=["Public Evaluation"])
app.include_router(ai.router, prefix="/ai", tags=["AI Assistant"])
app.include_router(feedback.router, prefix="/feedback", tags=["User Feedback"])
app.include_router(companies.router, prefix="/companies", tags=["Companies Codex"])
app.include_router(applications.router, prefix="/applications", tags=["Internship Applications"])

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Welcome to BUT TC Skills Hub API"}

@app.get("/import/moodle-data")
def get_moodle_data():
    try:
        with open("../../tmp/parsed_competencies.json", "r", encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail=f"Moodle data file not found: {e}")