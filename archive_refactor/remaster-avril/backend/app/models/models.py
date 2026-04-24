from typing import List, Optional
from enum import Enum
from datetime import datetime
import json
from sqlmodel import Session, select, create_engine, func, SQLModel, Field, Relationship

# --- MIXINS ---
class TimestampMixin:
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class AcademicYearMixin:
    academic_year: str = Field(default="2025-2026")

# --- ENUMS ---
class UserRole(str, Enum):
    SUPER_ADMIN = "SUPER_ADMIN"
    ADMIN = "ADMIN"
    DEPT_HEAD = "DEPT_HEAD"
    ADMIN_STAFF = "ADMIN_STAFF"
    STUDY_DIRECTOR = "STUDY_DIRECTOR"
    PROF_RESP_SAE = "PROF_RESP_SAE"
    PROFESSOR = "PROFESSOR"
    STUDENT = "STUDENT"
    GUEST = "GUEST"

class ActivityType(str, Enum):
    SAE = "SAE"
    STAGE = "STAGE"
    PROJET = "PROJET"
    PORTFOLIO = "PORTFOLIO"

class FeedbackType(str, Enum):
    BUG = "BUG"
    IDEA = "IDEA"
    QUESTION = "QUESTION"

# --- CORE MODELS ---

class Promotion(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True) # e.g. "TC1", "TC2", "TC3"
    entry_year: int # Année d'entrée (ex: 2025)
    year: Optional[int] = None # Niveau BUT (1, 2, 3)
    academic_year: str = Field(default="2025-2026")
    
    users: List["User"] = Relationship(back_populates="promotion")
    groups: List["Group"] = Relationship(back_populates="promotion")

class Group(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True) # e.g. "G1", "G2"
    pathway: str = Field(default="Tronc Commun")
    
    promotion_id: Optional[int] = Field(default=None, foreign_key="promotion.id")
    promotion: Optional[Promotion] = Relationship(back_populates="groups")
    users: List["User"] = Relationship(back_populates="group")

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    ldap_uid: str = Field(unique=True, index=True)
    email: str = Field(index=True)
    full_name: str
    phone: Optional[str] = None
    
    role: UserRole = Field(default=UserRole.GUEST)
    roles_json: str = Field(default="[\"GUEST\"]")

    # AI Assistant Customization & Memory
    ragflow_session_id: Optional[str] = Field(default=None, index=True)
    ragflow_dataset_id: Optional[str] = Field(default=None, index=True)
    ragflow_chat_id: Optional[str] = Field(default=None, index=True)
    ai_preprompt: Optional[str] = Field(default="Vous êtes un assistant pédagogique expert du BUT TC. Répondez de manière structurée et professionnelle.")
    ai_preprompt_general: Optional[str] = Field(default="Vous êtes un assistant pédagogique expert du BUT TC. Répondez de manière structurée et professionnelle.")
    ai_preprompt_exercises: Optional[str] = Field(default="Mode EXERCICES : Guidez l'utilisateur sans donner la réponse brute. Posez des questions pour l'aider à réfléchir.")
    ai_preprompt_course: Optional[str] = Field(default="Mode COURS : Expliquez les concepts avec pédagogie, exemples et analogies.")
    
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    
    promotion_id: Optional[int] = Field(default=None, foreign_key="promotion.id")
    promotion: Optional[Promotion] = Relationship(back_populates="users")
    
    group_id: Optional[int] = Field(default=None, foreign_key="group.id")
    group: Optional[Group] = Relationship(back_populates="users")

    # Lien avec les groupes d'activités (SAE/Stage)
    # On définit explicitement le lien inverse
    activity_groups: List["ActivityGroup"] = Relationship(back_populates="students", link_model=None) # Link model defined below

    @property
    def roles_list(self) -> List[str]:
        try: return json.loads(self.roles_json)
        except: return [self.role.value]

# --- REFERENTIEL MODELS ---

class ActivityACLink(SQLModel, table=True):
    activity_id: Optional[int] = Field(default=None, foreign_key="activity.id", primary_key=True)
    ac_id: Optional[int] = Field(default=None, foreign_key="learningoutcome.id", primary_key=True)

class ActivityCELink(SQLModel, table=True):
    activity_id: Optional[int] = Field(default=None, foreign_key="activity.id", primary_key=True)
    ce_id: Optional[int] = Field(default=None, foreign_key="essentialcomponent.id", primary_key=True)

class ResourceACLink(SQLModel, table=True):
    resource_id: Optional[int] = Field(default=None, foreign_key="resource.id", primary_key=True)
    ac_id: Optional[int] = Field(default=None, foreign_key="learningoutcome.id", primary_key=True)

class ActivityGroupStudentLink(SQLModel, table=True):
    group_id: Optional[int] = Field(default=None, foreign_key="activitygroup.id", primary_key=True)
    student_uid: Optional[str] = Field(default=None, foreign_key="user.ldap_uid", primary_key=True)

class Competency(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True)
    label: str
    description: Optional[str] = None
    situations_pro: Optional[str] = None
    level: int = 1
    pathway: str = Field(default="Tronc Commun")
    
    essential_components: List["EssentialComponent"] = Relationship(back_populates="competency")
    learning_outcomes: List["LearningOutcome"] = Relationship(back_populates="competency")

class EssentialComponent(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str
    label: str
    level: int = 1
    competency_id: int = Field(foreign_key="competency.id")
    competency: Competency = Relationship(back_populates="essential_components")
    activities: List["Activity"] = Relationship(back_populates="essential_components", link_model=ActivityCELink)

class LearningOutcome(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str
    label: str
    description: Optional[str] = None
    level: int = 1
    competency_id: int = Field(foreign_key="competency.id")
    competency: Competency = Relationship(back_populates="learning_outcomes")
    activities: List["Activity"] = Relationship(back_populates="learning_outcomes", link_model=ActivityACLink)
    resources: List["Resource"] = Relationship(back_populates="learning_outcomes", link_model=ResourceACLink)

class Resource(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True)
    label: str
    description: Optional[str] = None
    content: Optional[str] = None
    hours: Optional[int] = None
    hours_details: Optional[str] = None
    pathway: str = Field(default="Tronc Commun")
    responsible: Optional[str] = Field(default="(inconnu)")
    responsible_uid: Optional[str] = Field(default=None, index=True)
    contributors: Optional[str] = Field(default="(inconnu)")
    
    learning_outcomes: List[LearningOutcome] = Relationship(back_populates="resources", link_model=ResourceACLink)

class Activity(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True)
    label: str
    description: Optional[str] = None
    type: ActivityType = Field(default=ActivityType.SAE)
    level: int = 1
    semester: int = 1
    pathway: str = Field(default="Tronc Commun")
    resources: Optional[str] = None
    responsible: Optional[str] = Field(default="(inconnu)")
    contributors: Optional[str] = Field(default="(inconnu)")
    
    # Responsable Global (Lien objet réel)
    responsible_id: Optional[int] = Field(default=None, foreign_key="user.id")
    responsible_user: Optional[User] = Relationship(sa_relationship_kwargs={"foreign_keys": "[Activity.responsible_id]"})

    learning_outcomes: List[LearningOutcome] = Relationship(back_populates="activities", link_model=ActivityACLink)
    essential_components: List[EssentialComponent] = Relationship(back_populates="activities", link_model=ActivityCELink)
    activity_groups: List["ActivityGroup"] = Relationship(back_populates="activity")

class ActivityGroup(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str 
    activity_id: int = Field(foreign_key="activity.id")
    academic_year: str = Field(default="2025-2026")
    
    # Enseignant référent / Tuteur (Lien objet réel)
    tutor_id: Optional[int] = Field(default=None, foreign_key="user.id")
    tutor: Optional[User] = Relationship(sa_relationship_kwargs={"foreign_keys": "[ActivityGroup.tutor_id]"})
    
    activity: Activity = Relationship(back_populates="activity_groups")
    students: List[User] = Relationship(back_populates="activity_groups", link_model=ActivityGroupStudentLink)

# Correctif de la relation User.activity_groups
User.activity_groups = Relationship(back_populates="students", link_model=ActivityGroupStudentLink)

# --- GRADES & EVALUATION ---

class ActivityGroupGrade(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    group_id: int = Field(foreign_key="activitygroup.id")
    activity_id: int = Field(foreign_key="activity.id")
    grade: float = Field(default=0.0)
    comment: Optional[str] = None
    updated_at: datetime = Field(default_factory=datetime.now)

# --- OTHER MODELS ---

class Announcement(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    matrix_event_id: str = Field(index=True)
    matrix_room_id: str
    title: str
    content: str
    author_uid: str
    created_at: datetime = Field(default_factory=datetime.now)
