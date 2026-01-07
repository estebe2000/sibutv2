from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, status
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlmodel import Session, select, create_engine
from .database import create_db_and_tables, get_session, engine
from .models import Group, User, UserRole, SystemConfig, Competency, EssentialComponent, LearningOutcome, Activity, ActivityType, Resource
from .ldap_utils import get_ldap_users, verify_credentials
from .ai_parser import extract_text_from_pdf, parse_full_curriculum
from typing import List
import pandas as pd
import io
import json
import subprocess
from jose import JWTError, jwt
from datetime import datetime, timedelta

# JWT CONFIG
SECRET_KEY = "supersecretkeychangeinprod"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

app = FastAPI(title="BUT TC Skills Hub API")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return username
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@app.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    if form_data.username == "admin" and form_data.password == "adminpassword":
        return {"access_token": create_access_token({"sub": "admin"}), "token_type": "bearer"}
    if verify_credentials(form_data.username, form_data.password):
        if form_data.username != "admin":
             raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")
        return {"access_token": create_access_token({"sub": form_data.username}), "token_type": "bearer"}
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect username or password")

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

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Welcome to BUT TC Skills Hub API"}

# --- GROUPS ---
@app.get("/config", response_model=List[SystemConfig])
def list_config(session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    return session.exec(select(SystemConfig)).all()

@app.post("/config")
def update_config(config_data: List[dict], session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    for item in config_data:
        existing = session.exec(select(SystemConfig).where(SystemConfig.key == item['key'])).first()
        if existing:
            existing.value = item['value']
            existing.category = item.get('category', existing.category)
            session.add(existing)
        else:
            session.add(SystemConfig(**item))
    session.commit()
    return {"status": "success"}

@app.get("/groups", response_model=List[Group])
def list_groups(session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    return session.exec(select(Group)).all()

@app.post("/groups", response_model=Group)
def create_group(group: Group, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    session.add(group); session.commit(); session.refresh(group)
    return group

@app.patch("/groups/{group_id}", response_model=Group)
def update_group(group_id: int, group_data: Group, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Group not found")
    group_data_dict = group_data.model_dump(exclude_unset=True)
    if 'id' in group_data_dict: del group_data_dict['id']
    for key, value in group_data_dict.items(): setattr(group, key, value)
    session.add(group); session.commit(); session.refresh(group)
    return group

@app.delete("/groups/{group_id}")
def delete_group(group_id: int, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Group not found")
    users = session.exec(select(User).where(User.group_id == group_id)).all()
    for user in users:
        user.group_id = None
        user.role = UserRole.GUEST
        session.add(user)
    session.delete(group); session.commit()
    return {"status": "success"}

# --- USERS & DISPATCHING ---
@app.get("/ldap-users")
def list_ldap_raw(current_user: str = Depends(get_current_user)):
    return get_ldap_users()

@app.get("/users", response_model=List[User])
def list_assigned_users(session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    return session.exec(select(User)).all()

@app.post("/users/assign")
def assign_user(user_data: User, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    existing = session.exec(select(User).where(User.ldap_uid == user_data.ldap_uid)).first()
    group = session.get(Group, user_data.group_id) if user_data.group_id else None
    role = user_data.role
    if group and group.name == "Enseignants": role = UserRole.PROFESSOR
    if existing:
        existing.role = role
        existing.group_id = user_data.group_id
        session.add(existing)
    else:
        user_data.role = role
        session.add(user_data)
    session.commit()
    return {"status": "success"}

@app.post("/users/unassign")
def unassign_user(ldap_uid: str, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    user = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
    if user:
        user.group_id = None
        user.role = UserRole.GUEST
        session.add(user); session.commit()
        return {"status": "success"}
    raise HTTPException(status_code=404, detail="User not found")

@app.post("/users/{ldap_uid}/quota")
def set_user_quota(ldap_uid: str, quota: str = "100 GB", session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    subprocess.run(["docker", "exec", "-u", "www-data", "but_tc_nextcloud", "php", "occ", "ldap:check-user", ldap_uid], capture_output=True)
    cmd = ["docker", "exec", "-u", "www-data", "but_tc_nextcloud", "php", "occ", "user:setting", ldap_uid, "files", "quota", quota]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0: raise HTTPException(status_code=500, detail=result.stderr)
    return {"status": "success"}

# --- REFERENTIEL ---

@app.get("/competencies")
def list_competencies(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Competency).options(
        selectinload(Competency.essential_components),
        selectinload(Competency.learning_outcomes)
    )
    comps = session.exec(statement).all()
    result = []
    for c in comps:
        d = c.model_dump()
        d["essential_components"] = [ce.model_dump() for ce in c.essential_components]
        d["learning_outcomes"] = [lo.model_dump() for lo in c.learning_outcomes]
        result.append(d)
    return result

@app.get("/activities")
def list_activities(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Activity).options(
        selectinload(Activity.learning_outcomes),
        selectinload(Activity.essential_components)
    )
    acts = session.exec(statement).all()
    result = []
    for a in acts:
        d = a.model_dump()
        d["learning_outcomes"] = [lo.model_dump() for lo in a.learning_outcomes]
        d["essential_components"] = [ce.model_dump() for ce in a.essential_components]
        result.append(d)
    return result

@app.get("/resources")
def list_resources(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Resource).options(selectinload(Resource.learning_outcomes))
    res = session.exec(statement).all()
    result = []
    for r in res:
        d = r.model_dump()
        d["learning_outcomes"] = [lo.model_dump() for lo in r.learning_outcomes]
        result.append(d)
    return result

@app.get("/resources/{code}")
def get_resource_by_code(code: str, session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    res = session.exec(select(Resource).where(Resource.code == code).options(selectinload(Resource.learning_outcomes))).first()
    if not res: raise HTTPException(status_code=404, detail="Resource not found")
    d = res.model_dump()
    d["learning_outcomes"] = [lo.model_dump() for lo in res.learning_outcomes]
    return d

@app.patch("/competencies/{comp_id}")
def update_competency(comp_id: int, comp_data: dict, session: Session = Depends(get_session)):
    comp = session.get(Competency, comp_id)
    if not comp: raise HTTPException(status_code=404, detail="Competency not found")
    for key, value in comp_data.items():
        if hasattr(comp, key): setattr(comp, key, value)
    session.add(comp); session.commit(); session.refresh(comp)
    return comp

@app.patch("/activities/{act_id}")
def update_activity(act_id: int, act_data: dict, session: Session = Depends(get_session)):
    act = session.get(Activity, act_id)
    if not act: raise HTTPException(status_code=404, detail="Activity not found")
    for key, value in act_data.items():
        if key in ["label", "description", "resources"]:
            setattr(act, key, value)
    session.add(act); session.commit(); session.refresh(act)
    return act

@app.get("/export/curriculum")
def export_curriculum(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    comps = session.exec(select(Competency).options(selectinload(Competency.essential_components), selectinload(Competency.learning_outcomes))).all()
    acts = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes))).all()
    res = session.exec(select(Resource)).all()
    data = {
        "competencies": [
            {**c.model_dump(), 
             "essential_components": [ce.model_dump() for ce in c.essential_components],
             "learning_outcomes": [lo.model_dump() for lo in c.learning_outcomes]} 
            for c in comps
        ],
        "activities": [
            {**a.model_dump(), 
             "learning_outcomes": [lo.code for lo in a.learning_outcomes]} 
            for a in acts
        ],
        "resources": [r.model_dump() for r in res]
    }
    return data

@app.get("/import/moodle-data")
def get_moodle_data():
    try:
        with open("../../tmp/parsed_competencies.json", "r", encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Moodle data file not found: {e}")

@app.get("/referentiel")
def get_referentiel():
    try:
        with open("apps/api/app/data/referentiel.json", "r") as f: return json.load(f)
    except: return {"parcours": ["Tronc Commun", "BSMRC", "MDEE", "MMPC", "SME", "BI"]}

@app.post("/import/students")
async def import_students(file: UploadFile = File(...), session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    contents = await file.read()
    if file.filename.endswith('.csv'): df = pd.read_csv(io.BytesIO(contents))
    else: df = pd.read_excel(io.BytesIO(contents))
    df.columns = [c.lower().strip() for c in df.columns]
    ldap_users = get_ldap_users()
    for _, row in df.iterrows():
        email = str(row.get('mail', row.get('email', ''))).strip()
        group_name = str(row.get('groupes', row.get('promotion', ''))).strip()
        if not email or not group_name: continue
        group = session.exec(select(Group).where(Group.name == group_name)).first()
        if not group:
            group = Group(name=group_name, year=1, pathway=str(row.get('parcours', 'Tronc Commun')))
            session.add(group); session.commit(); session.refresh(group)
        ldap_match = next((u for u in ldap_users if u['email'].lower() == email.lower()), None)
        if ldap_match:
            existing = session.exec(select(User).where(User.ldap_uid == ldap_match['uid'])).first()
            if existing: existing.group_id = group.id; session.add(existing)
            else: session.add(User(ldap_uid=ldap_match['uid'], email=ldap_match['email'], full_name=ldap_match['full_name'], role=UserRole.STUDENT, group_id=group.id))
    session.commit()
    return {"status": "success"}