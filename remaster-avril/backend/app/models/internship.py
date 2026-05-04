from typing import List, Optional
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship
from .base import AcademicYearMixin, TimestampMixin

from enum import Enum

class InternshipApplicationStatus(str, Enum):
    DRAFT = "DRAFT"
    SUBMITTED = "SUBMITTED"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"

class Company(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True, unique=True)
    address: Optional[str] = None
    email: Optional[str] = None

    internships: List["Internship"] = Relationship(back_populates="company")

class InternshipApplication(SQLModel, AcademicYearMixin, TimestampMixin, table=True):
    """
    Formulaire préparatoire rempli par l'étudiant avec le tuteur d'entreprise.
    Soumis au directeur d'étude pour validation.
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True, foreign_key="user.ldap_uid")

    proposed_acs_json: str = Field(default="[]") # Liste des AC proposés
    mission_description: str = Field(default="")

    status: str = Field(default=InternshipApplicationStatus.DRAFT)
    director_comment: Optional[str] = None

    student: Optional["User"] = Relationship()

class Internship(SQLModel, AcademicYearMixin, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True, foreign_key="user.ldap_uid")

    # Validation du stage
    application_id: Optional[int] = Field(default=None, foreign_key="internshipapplication.id")
    application: Optional[InternshipApplication] = Relationship()

    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None

    company_id: Optional[int] = Field(default=None, foreign_key="company.id")
    company: Optional[Company] = Relationship(back_populates="internships")

    tutor_name: Optional[str] = None
    tutor_email: Optional[str] = None
    tutor_phone: Optional[str] = None

    teacher_uid: Optional[str] = Field(default=None, foreign_key="user.ldap_uid")
    teacher: Optional["User"] = Relationship()

    matrix_room_id: Optional[str] = None # Canal de discussion Element

    is_finalized: bool = Field(default=False)

class PortfolioPage(SQLModel, AcademicYearMixin, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True, foreign_key="user.ldap_uid")
    title: str
    content_json: str = Field(default="{}")
    year_of_study: int = Field(default=1)
    is_public: bool = Field(default=False)
