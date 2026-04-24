from sqlmodel import SQLModel, Field, Relationship
from typing import List, Optional
from datetime import datetime
from enum import Enum

class UserRole(str, Enum):
    ADMIN = "ADMIN"
    DEPT_HEAD = "DEPT_HEAD"
    STUDY_DIRECTOR = "STUDY_DIRECTOR"
    PROFESSOR = "PROFESSOR"
    PROF_RESP_SAE = "PROF_RESP_SAE"
    ADMIN_STAFF = "ADMIN_STAFF"
    STUDENT = "STUDENT"
    GUEST = "GUEST"

class ActivityType(str, Enum):
    SAE = "SAE"
    STAGE = "STAGE"
    PORTFOLIO = "PORTFOLIO"

class ActivityGroupStudentLink(SQLModel, table=True):
    group_id: Optional[int] = Field(default=None, foreign_key="activitygroup.id", primary_key=True)
    student_uid: str = Field(foreign_key="user.ldap_uid", primary_key=True)

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    ldap_uid: str = Field(unique=True, index=True)
    nip: Optional[str] = Field(default=None, index=True)
    email: str = Field(index=True)
    full_name: str
    phone: Optional[str] = None
    role: UserRole = Field(default=UserRole.GUEST)
    roles_json: str = Field(default='["GUEST"]')
    ragflow_session_id: Optional[str] = None
    ragflow_dataset_id: Optional[str] = None
    ragflow_chat_id: Optional[str] = None
    ai_preprompt_general: Optional[str] = Field(default="Vous êtes un assistant pédagogique expert du BUT TC.")
    ai_preprompt_exercises: Optional[str] = Field(default="Mode EXERCICES : Guidez l'utilisateur.")
    ai_preprompt_course: Optional[str] = Field(default="Mode COURS : Expliquez les concepts.")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    promotion_id: Optional[int] = Field(default=None, foreign_key="promotion.id")
    group_id: Optional[int] = Field(default=None, foreign_key="group.id")
    promotion: Optional["Promotion"] = Relationship(back_populates="users")
    group: Optional["Group"] = Relationship(back_populates="users")

    @property
    def roles_list(self) -> List[str]:
        import json
        try: return json.loads(self.roles_json)
        except: return [self.role.value]

class Promotion(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    year: int
    entry_year: int
    academic_year: str
    groups: List["Group"] = Relationship(back_populates="promotion")
    users: List["User"] = Relationship(back_populates="promotion")

class Group(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    year: int = Field(default=2026)
    academic_year: str = Field(default="2025-2026", index=True)
    pathway: str = Field(default="Tronc Commun")
    formation_type: str = Field(default="FI")
    scodoc_id: Optional[str] = Field(default=None, index=True)
    promotion_id: Optional[int] = Field(default=None, foreign_key="promotion.id")
    matrix_room_id: Optional[str] = None
    
    promotion: Optional[Promotion] = Relationship(back_populates="groups")
    users: List["User"] = Relationship(back_populates="group")

class ACActivityLink(SQLModel, table=True):
    learning_outcome_id: int = Field(foreign_key="learningoutcome.id", primary_key=True)
    activity_id: int = Field(foreign_key="activity.id", primary_key=True)

class ACResourceLink(SQLModel, table=True):
    learning_outcome_id: int = Field(foreign_key="learningoutcome.id", primary_key=True)
    resource_id: int = Field(foreign_key="resource.id", primary_key=True)

class Resource(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True)
    label: str
    pathway: str
    responsible: str = Field(default="(inconnu)")
    responsible_uid: Optional[str] = None
    learning_outcomes: List["LearningOutcome"] = Relationship(back_populates="resources", link_model=ACResourceLink)

class Activity(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True)
    label: str
    type: ActivityType
    level: int
    responsible_id: Optional[int] = Field(default=None, foreign_key="user.id")
    responsible_user: Optional[User] = Relationship()
    activity_groups: List["ActivityGroup"] = Relationship(back_populates="activity")
    learning_outcomes: List["LearningOutcome"] = Relationship(back_populates="activities", link_model=ACActivityLink)
    rubrics: List["EvaluationRubric"] = Relationship(back_populates="activity")

class ActivityGroup(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    activity_id: int = Field(foreign_key="activity.id")
    tutor_id: Optional[int] = Field(default=None, foreign_key="user.id")
    activity: Activity = Relationship(back_populates="activity_groups")
    tutor: Optional[User] = Relationship()
    students: List[User] = Relationship(link_model=ActivityGroupStudentLink)

class Competency(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str
    label: str
    level: int
    pathway: str
    learning_outcomes: List["LearningOutcome"] = Relationship(back_populates="competency")
    essential_components: List["EssentialComponent"] = Relationship(back_populates="competency")

class LearningOutcome(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str
    label: str
    description: Optional[str] = None
    competency_id: int = Field(foreign_key="competency.id")
    competency: Competency = Relationship(back_populates="learning_outcomes")
    activities: List[Activity] = Relationship(back_populates="learning_outcomes", link_model=ACActivityLink)
    resources: List[Resource] = Relationship(back_populates="learning_outcomes", link_model=ACResourceLink)

class EssentialComponent(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str
    label: str
    competency_id: int = Field(foreign_key="competency.id")
    competency: Competency = Relationship(back_populates="essential_components")

class Announcement(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    content: str
    author_uid: str
    matrix_event_id: Optional[str] = None
    matrix_room_id: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.now)

class EvaluationRubric(SQLModel, table=True):
    """La grille d'évaluation liée à une activité (SAÉ, Stage, Portfolio)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    activity_id: int = Field(foreign_key="activity.id", index=True)
    name: str
    created_at: datetime = Field(default_factory=datetime.now)
    
    activity: "Activity" = Relationship(back_populates="rubrics")
    criteria: List["RubricCriterion"] = Relationship(back_populates="rubric")

class RubricCriterion(SQLModel, table=True):
    """Un critère de la grille, basé par défaut sur un Apprentissage Critique (AC)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    rubric_id: int = Field(foreign_key="evaluationrubric.id", index=True)
    learning_outcome_id: Optional[int] = Field(foreign_key="learningoutcome.id")
    label: str
    coefficient: float = Field(default=1.0)
    max_points: float = Field(default=20.0)
    
    rubric: Optional[EvaluationRubric] = Relationship(back_populates="criteria")
    learning_outcome: Optional["LearningOutcome"] = Relationship()
