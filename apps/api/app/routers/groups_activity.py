from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from pydantic import BaseModel
from ..database import get_session
from ..models import Activity, ActivityGroup, ActivityGroupStudentLink, User, UserRole, ResponsibilityMatrix, ResponsibilityEntityType, ResponsibilityType
from sqlalchemy.orm import selectinload

router = APIRouter()

class GroupUpdate(BaseModel):
    name: str

@router.get("/{activity_id}/groups")
async def get_activity_groups(activity_id: int, session: Session = Depends(get_session)):
    """Récupère tous les groupes pour une activité avec chargement manuel des membres"""
    statement = select(ActivityGroup).where(ActivityGroup.activity_id == activity_id)
    groups = session.exec(statement).all()
    
    result = []
    for group in groups:
        links = session.exec(select(ActivityGroupStudentLink).where(ActivityGroupStudentLink.group_id == group.id)).all()
        student_uids = [link.student_uid for link in links]
        students = []
        if student_uids:
            students = session.exec(select(User).where(User.ldap_uid.in_(student_uids))).all()
        
        result.append({
            "id": group.id,
            "name": group.name,
            "activity_id": group.activity_id,
            "students": students
        })
    return result

@router.post("/{activity_id}/groups")
async def create_activity_group(activity_id: int, name: str, session: Session = Depends(get_session)):
    activity = session.get(Activity, activity_id)
    if not activity:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    
    group = ActivityGroup(name=name, activity_id=activity_id)
    session.add(group)
    session.commit()
    session.refresh(group)
    return group

@router.patch("/groups/{group_id}")
async def rename_group(group_id: int, update: GroupUpdate, session: Session = Depends(get_session)):
    """Renomme un groupe"""
    group = session.get(ActivityGroup, group_id)
    if not group:
        raise HTTPException(status_code=404, detail="Groupe non trouvé")
    group.name = update.name
    session.add(group)
    session.commit()
    session.refresh(group)
    return group

@router.delete("/groups/{group_id}")
async def delete_group(group_id: int, session: Session = Depends(get_session)):
    """Supprime un groupe et ses liens"""
    group = session.get(ActivityGroup, group_id)
    if not group:
        raise HTTPException(status_code=404, detail="Groupe non trouvé")
    
    # Supprimer les liens d'abord
    links = session.exec(select(ActivityGroupStudentLink).where(ActivityGroupStudentLink.group_id == group_id)).all()
    for link in links:
        session.delete(link)
    
    session.delete(group)
    session.commit()
    return {"message": "Groupe supprimé"}

@router.post("/groups/{group_id}/students/{student_uid}")
async def add_student_to_group(group_id: int, student_uid: str, session: Session = Depends(get_session)):
    group = session.get(ActivityGroup, group_id)
    student = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
    
    if not group or not student:
        raise HTTPException(status_code=404, detail="Groupe ou étudiant non trouvé")
    
    statement = select(ActivityGroupStudentLink).where(
        ActivityGroupStudentLink.group_id == group_id,
        ActivityGroupStudentLink.student_uid == student_uid
    )
    existing = session.exec(statement).first()
    if existing: return {"message": "Déjà présent"}
    
    link = ActivityGroupStudentLink(group_id=group_id, student_uid=student_uid)
    session.add(link)
    session.commit()
    return {"message": "Ajouté"}

@router.delete("/groups/{group_id}/students/{student_uid}")
async def remove_student_from_group(group_id: int, student_uid: str, session: Session = Depends(get_session)):
    """Retire un étudiant d'un groupe"""
    statement = select(ActivityGroupStudentLink).where(
        ActivityGroupStudentLink.group_id == group_id,
        ActivityGroupStudentLink.student_uid == student_uid
    )
    link = session.exec(statement).first()
    if not link:
        raise HTTPException(status_code=404, detail="Lien non trouvé")
    
    session.delete(link)
    session.commit()
    return {"message": "Étudiant retiré"}

@router.post("/students/{student_uid}/tutor/{teacher_uid}")
async def assign_internship_tutor(student_uid: str, teacher_uid: str, session: Session = Depends(get_session)):
    teacher = session.exec(select(User).where(User.ldap_uid == teacher_uid)).first()
    if not teacher or teacher.role not in [UserRole.PROFESSOR, UserRole.ADMIN, UserRole.SUPER_ADMIN]:
        raise HTTPException(status_code=400, detail="Enseignant invalide")

    # Supprimer l'éventuel ancien tuteur
    old_matrix = session.exec(select(ResponsibilityMatrix).where(
        ResponsibilityMatrix.entity_type == ResponsibilityEntityType.STUDENT,
        ResponsibilityMatrix.entity_id == student_uid,
        ResponsibilityMatrix.role_type == ResponsibilityType.TUTOR
    )).all()
    for m in old_matrix: session.delete(m)

    matrix = ResponsibilityMatrix(
        user_id=teacher_uid,
        entity_type=ResponsibilityEntityType.STUDENT,
        entity_id=student_uid,
        role_type=ResponsibilityType.TUTOR
    )
    session.add(matrix)
    session.commit()
    return {"message": "Tuteur assigné"}

@router.get("/teacher/{teacher_uid}/tutored-students")
async def get_tutored_students(teacher_uid: str, session: Session = Depends(get_session)):
    """Liste les étudiants suivis par un enseignant"""
    statement = select(ResponsibilityMatrix).where(
        ResponsibilityMatrix.user_id == teacher_uid,
        ResponsibilityMatrix.entity_type == ResponsibilityEntityType.STUDENT,
        ResponsibilityMatrix.role_type == ResponsibilityType.TUTOR
    )
    matrices = session.exec(statement).all()
    student_uids = [m.entity_id for m in matrices]
    
    if not student_uids: return []
    return session.exec(select(User).where(User.ldap_uid.in_(student_uids))).all()

@router.get("/student/{student_uid}/tutor")
async def get_student_tutor(student_uid: str, session: Session = Depends(get_session)):
    """Récupère l'enseignant tuteur d'un étudiant"""
    statement = select(ResponsibilityMatrix).where(
        ResponsibilityMatrix.entity_id == student_uid,
        ResponsibilityMatrix.entity_type == ResponsibilityEntityType.STUDENT,
        ResponsibilityMatrix.role_type == ResponsibilityType.TUTOR
    )
    matrix = session.exec(statement).first()
    if not matrix: return None
    return session.exec(select(User).where(User.ldap_uid == matrix.user_id)).first()
