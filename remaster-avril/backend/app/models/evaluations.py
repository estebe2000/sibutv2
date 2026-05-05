from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship
from .base import TimestampMixin

class EvaluationGrid(SQLModel, TimestampMixin, table=True):
    """
    Grille d'évaluation personnalisable par l'enseignant.
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    internship_id: int = Field(foreign_key="internship.id")

    custom_fields_json: str = Field(default="[]") # [{ name, coef }]

    internship: Optional["Internship"] = Relationship()

class EvaluationResult(SQLModel, TimestampMixin, table=True):
    """
    Résultats d'évaluation (Auto, Tuteur, Enseignant).
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    internship_id: int = Field(foreign_key="internship.id")
    evaluator_type: str = Field(description="STUDENT, TUTOR, TEACHER")

    ac_scores_json: str = Field(default="{}") # { ac_code: percentage }
    custom_scores_json: str = Field(default="{}")

    general_comment: Optional[str] = None
    bonus_malus: int = Field(default=0) # Pourcentage global ajusté

    internship: Optional["Internship"] = Relationship()

class VisitReport(SQLModel, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    internship_id: int = Field(foreign_key="internship.id")
    teacher_uid: str = Field(foreign_key="user.ldap_uid")

    visit_date: Optional[str] = None
    comments: str = Field(default="")

    internship: Optional["Internship"] = Relationship()

class MagicLink(SQLModel, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    tutor_email: str = Field(index=True)
    internship_id: int = Field(foreign_key="internship.id")
    token: str = Field(unique=True, index=True)
    is_used: bool = Field(default=False)
