from fastapi import APIRouter, Depends
from sqlmodel import Session, select, func
from ..database import get_session
from ..models import User, Group, Activity, Resource, UserRole, PromotionResponsibility
from ..dependencies import require_staff

router = APIRouter(tags=["Statistics"])

@router.get("/summary")
async def get_stats_summary(session: Session = Depends(get_session)):
    # 1. Comptes de base
    total_students = session.exec(select(func.count(User.id)).where(User.role == UserRole.STUDENT)).one()
    total_profs = session.exec(select(func.count(User.id)).where(User.role.in_([UserRole.PROFESSOR, UserRole.STUDY_DIRECTOR, UserRole.DEPT_HEAD]))).one()
    total_groups = session.exec(select(func.count(Group.id)).where(Group.id != 1)).one() # Exclure groupe enseignants
    total_sae = session.exec(select(func.count(Activity.id))).one()

    # 2. Répartition par année (BUT 1, 2, 3)
    years_data = []
    for y in [1, 2, 3]:
        count = session.exec(
            select(func.count(User.id))
            .join(Group)
            .where(User.role == UserRole.STUDENT, Group.year == y)
        ).one()
        years_data.append({"year": f"BUT {y}", "count": count})

    # 3. Répartition par parcours
    pathways = ['BI', 'BDMRC', 'MDEE', 'MMPV', 'SME', 'Tronc Commun']
    pathway_data = []
    for p in pathways:
        count = session.exec(
            select(func.count(User.id))
            .join(Group)
            .where(User.role == UserRole.STUDENT, Group.pathway == p)
        ).one()
        if count > 0:
            pathway_data.append({"name": p, "value": count})

    # 4. Stats Tutorat
    from ..models import ResponsibilityMatrix, ResponsibilityType, ResponsibilityEntityType
    students_with_tutor = session.exec(
        select(func.count(func.distinct(ResponsibilityMatrix.entity_id)))
        .where(ResponsibilityMatrix.entity_type == ResponsibilityEntityType.STUDENT, ResponsibilityMatrix.role_type == ResponsibilityType.TUTOR)
    ).one()

    return {
        "kpis": {
            "students": total_students,
            "professors": total_profs,
            "groups": total_groups,
            "activities": total_sae
        },
        "years_distribution": years_data,
        "pathway_distribution": pathway_data,
        "tutor_ratio": {
            "assigned": students_with_tutor,
            "total": total_students
        }
    }
