from typing import List, Optional
from enum import Enum
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class UserRole(str, Enum):
    SUPER_ADMIN = "SUPER_ADMIN"
    ADMIN = "ADMIN"
    PROF_RESP_PARCOURS = "PROF_RESP_PARCOURS"
    PROF_RESP_SAE = "PROF_RESP_SAE"
    PROFESSOR = "PROFESSOR"
    STUDENT = "STUDENT"
    GUEST = "GUEST"

class Group(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    year: int # 1, 2, or 3
    pathway: str # Nom du parcours (e.g., "Marketing Digital")
    formation_type: str = "FI" # "FI" (Initiale) ou "FA" (Alternance)
    academic_year: str = "2025-2026"
    
    users: List["User"] = Relationship(back_populates="group")

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    ldap_uid: str = Field(unique=True, index=True)
    email: str
    full_name: str
    role: UserRole = Field(default=UserRole.GUEST)
    
    group_id: Optional[int] = Field(default=None, foreign_key="group.id")
    group: Optional[Group] = Relationship(back_populates="users")

class SystemConfig(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    key: str = Field(unique=True, index=True)
    value: str
    category: str # "ldap", "mail", "nextcloud"

# --- RESPONSIBILITY MATRIX ---

class ResponsibilityType(str, Enum):
    OWNER = "OWNER"           # Responsable principal
    INTERVENANT = "INTERVENANT" # Intervenant / Participant
    TUTOR = "TUTOR"           # Tuteur (pour stage/portfolio individuel)

class ResponsibilityEntityType(str, Enum):
    RESOURCE = "RESOURCE"
    ACTIVITY = "ACTIVITY"
    STUDENT = "STUDENT"

class ResponsibilityMatrix(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True) # UID de l'utilisateur (LDAP ou Local)
    entity_type: ResponsibilityEntityType
    entity_id: str # Code de la ressource (ex: R1.01) ou ID de l'activité ou UID de l'étudiant
    role_type: ResponsibilityType = Field(default=ResponsibilityType.INTERVENANT)
    academic_year: str = "2025-2026"

# --- FILE MANAGEMENT ---

class StudentFile(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True)
    filename: str
    nc_path: str # Chemin sur Nextcloud
    entity_type: ResponsibilityEntityType # ACTIVITY ou RESOURCE
    entity_id: str # ID de l'activité ou code ressource
    is_locked: bool = Field(default=False)
    uploaded_at: datetime = Field(default_factory=datetime.now)

# --- CURRICULUM MODELS ---

class ActivityType(str, Enum):
    SAE = "SAE"
    STAGE = "STAGE"
    PROJET = "PROJET"
    PORTFOLIO = "PORTFOLIO"

class ActivityACLink(SQLModel, table=True):
    activity_id: Optional[int] = Field(default=None, foreign_key="activity.id", primary_key=True)
    ac_id: Optional[int] = Field(default=None, foreign_key="learningoutcome.id", primary_key=True)

class ActivityCELink(SQLModel, table=True):
    activity_id: Optional[int] = Field(default=None, foreign_key="activity.id", primary_key=True)
    ce_id: Optional[int] = Field(default=None, foreign_key="essentialcomponent.id", primary_key=True)

class ResourceACLink(SQLModel, table=True):
    resource_id: Optional[int] = Field(default=None, foreign_key="resource.id", primary_key=True)
    ac_id: Optional[int] = Field(default=None, foreign_key="learningoutcome.id", primary_key=True)

class Competency(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True) # e.g., "C1"
    label: str
    description: Optional[str] = None
    situations_pro: Optional[str] = None
    level: int = 1 # 1, 2, or 3 (BUT1, BUT2, BUT3)
    pathway: str = Field(default="Tronc Commun")
    
    essential_components: List["EssentialComponent"] = Relationship(back_populates="competency")
    learning_outcomes: List["LearningOutcome"] = Relationship(back_populates="competency")

class EssentialComponent(SQLModel, table=True):
    """Composantes Essentielles (CE)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str # e.g., "CE1.1"
    label: str
    level: int = 1
    pathway: str = Field(default="Tronc Commun")
    competency_id: int = Field(foreign_key="competency.id")
    
    competency: "Competency" = Relationship(back_populates="essential_components")
    activities: List["Activity"] = Relationship(back_populates="essential_components", link_model=ActivityCELink)

class LearningOutcome(SQLModel, table=True):
    """Apprentissages Critiques (AC)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str # e.g., "AC1.01"
    label: str
    description: Optional[str] = None
    level: int = 1
    pathway: str = Field(default="Tronc Commun")
    competency_id: int = Field(foreign_key="competency.id")
    
    competency: "Competency" = Relationship(back_populates="learning_outcomes")
    activities: List["Activity"] = Relationship(back_populates="learning_outcomes", link_model=ActivityACLink)
    resources: List["Resource"] = Relationship(back_populates="learning_outcomes", link_model=ResourceACLink)

class Resource(SQLModel, table=True):
    """Ressources (R1.01, etc.)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True) # e.g., "R1.01"
    label: str
    description: Optional[str] = None
    content: Optional[str] = None
    hours: Optional[int] = None
    hours_details: Optional[str] = None
    targeted_competencies: Optional[str] = None
    pathway: str = Field(default="Tronc Commun")
    responsible: Optional[str] = Field(default="(inconnu)")
    contributors: Optional[str] = Field(default="(inconnu)")
    
    learning_outcomes: List[LearningOutcome] = Relationship(back_populates="resources", link_model=ResourceACLink)

class Activity(SQLModel, table=True):
    """SAE, Stages, and Projects"""
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True) # e.g., "SAE 1.01", "STAGE 2"
    label: str
    description: Optional[str] = None
    type: ActivityType = Field(default=ActivityType.SAE)
    level: int = 1 # 1, 2, or 3
    semester: int = 1 # 1 to 6
    pathway: str = Field(default="Tronc Commun")
    resources: Optional[str] = None # List of R-codes
    responsible: Optional[str] = Field(default="(inconnu)")
    contributors: Optional[str] = Field(default="(inconnu)")
    
    learning_outcomes: List[LearningOutcome] = Relationship(back_populates="activities", link_model=ActivityACLink)
    essential_components: List[EssentialComponent] = Relationship(back_populates="activities", link_model=ActivityCELink)