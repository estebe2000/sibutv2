from typing import List, Optional
from enum import Enum
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

# --- MIXINS ---
# Note: Mixins should NOT inherit from SQLModel to avoid MRO issues in SQLModel/Pydantic
class TimestampMixin:
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class AcademicYearMixin:
    academic_year: str = Field(default="2025-2026", index=True)

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

class ResponsibilityType(str, Enum):
    OWNER = "OWNER"
    INTERVENANT = "INTERVENANT"
    TUTOR = "TUTOR"

class ResponsibilityEntityType(str, Enum):
    RESOURCE = "RESOURCE"
    ACTIVITY = "ACTIVITY"
    STUDENT = "STUDENT"
    INTERNSHIP = "INTERNSHIP"
    PPP = "PPP"

class ApplicationStatus(str, Enum):
    APPLIED = "APPLIED"
    INTERVIEW = "INTERVIEW"
    REJECTED = "REJECTED"
    ACCEPTED = "ACCEPTED"

class VisitType(str, Enum):
    SITE = "SITE"
    PHONE = "PHONE"
    VISIO = "VISIO"

class FeedbackType(str, Enum):
    BUG = "BUG"
    IDEA = "IDEA"
    REQUEST = "REQUEST"

# --- LINK MODELS ---

class ActivityGroupStudentLink(SQLModel, table=True):
    group_id: Optional[int] = Field(default=None, foreign_key="activitygroup.id", primary_key=True)
    student_uid: Optional[str] = Field(default=None, foreign_key="user.ldap_uid", primary_key=True)

class ActivityACLink(SQLModel, table=True):
    activity_id: Optional[int] = Field(default=None, foreign_key="activity.id", primary_key=True)
    ac_id: Optional[int] = Field(default=None, foreign_key="learningoutcome.id", primary_key=True)

class ActivityCELink(SQLModel, table=True):
    activity_id: Optional[int] = Field(default=None, foreign_key="activity.id", primary_key=True)
    ce_id: Optional[int] = Field(default=None, foreign_key="essentialcomponent.id", primary_key=True)

class ResourceACLink(SQLModel, table=True):
    resource_id: Optional[int] = Field(default=None, foreign_key="resource.id", primary_key=True)
    ac_id: Optional[int] = Field(default=None, foreign_key="learningoutcome.id", primary_key=True)

# --- CORE MODELS ---

class Promotion(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True) # e.g., "Promo 26"
    entry_year: int # e.g., 2026
    matrix_room_id: Optional[str] = None # ID du salon Matrix de la promo
    
    groups: List["Group"] = Relationship(back_populates="promotion")
    users: List["User"] = Relationship(back_populates="promotion")

class Group(SQLModel, AcademicYearMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    scodoc_id: Optional[str] = Field(default=None, index=True) # Lien technique ScoDoc
    year: int # 1, 2, 3
    pathway: str
    formation_type: str = "FI"
    matrix_room_id: Optional[str] = None # ID du salon Matrix du groupe (ex: #TC1-G1)
    
    promotion_id: Optional[int] = Field(default=None, foreign_key="promotion.id")
    promotion: Optional[Promotion] = Relationship(back_populates="groups")
    
    users: List["User"] = Relationship(back_populates="group")

class User(SQLModel, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    ldap_uid: str = Field(unique=True, index=True)
    nip: Optional[str] = Field(default=None, unique=True, index=True) # Identifiant ScoDoc stable
    email: str = Field(index=True)
    full_name: str
    phone: Optional[str] = None
    role: UserRole = Field(default=UserRole.GUEST) # Rôle principal (legacy/display)
    roles_json: str = Field(default="[\"GUEST\"]") # Liste des rôles en JSON
    
    promotion_id: Optional[int] = Field(default=None, foreign_key="promotion.id")
    promotion: Optional[Promotion] = Relationship(back_populates="users")
    
    group_id: Optional[int] = Field(default=None, foreign_key="group.id")
    group: Optional[Group] = Relationship(back_populates="users")
    
    activity_groups: List["ActivityGroup"] = Relationship(back_populates="students", link_model=ActivityGroupStudentLink)

    @property
    def roles_list(self) -> List[UserRole]:
        import json
        try:
            return [UserRole(r) for r in json.loads(self.roles_json)]
        except:
            return [self.role]

class ActivityGroup(SQLModel, AcademicYearMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    activity_id: int = Field(foreign_key="activity.id")
    
    activity: "Activity" = Relationship(back_populates="activity_groups")
    students: List[User] = Relationship(back_populates="activity_groups", link_model=ActivityGroupStudentLink)

# --- CURRICULUM MODELS ---

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
    pathway: str = Field(default="Tronc Commun")
    competency_id: int = Field(foreign_key="competency.id")
    
    competency: Competency = Relationship(back_populates="essential_components")
    activities: List["Activity"] = Relationship(back_populates="essential_components", link_model=ActivityCELink)

class LearningOutcome(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str
    label: str
    description: Optional[str] = None
    level: int = 1
    pathway: str = Field(default="Tronc Commun")
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
    responsible_uid: Optional[str] = Field(default=None, index=True) # Le vrai UID LDAP
    
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
    
    learning_outcomes: List[LearningOutcome] = Relationship(back_populates="activities", link_model=ActivityACLink)
    essential_components: List[EssentialComponent] = Relationship(back_populates="activities", link_model=ActivityCELink)
    activity_groups: List[ActivityGroup] = Relationship(back_populates="activity")

# --- INTERNSHIP & PORTFOLIO ---

class Company(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True, unique=True)
    address: Optional[str] = None
    email: Optional[str] = None
    
    internships: List["Internship"] = Relationship(back_populates="company")

class Internship(SQLModel, AcademicYearMixin, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True, foreign_key="user.ldap_uid")
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    
    company_id: Optional[int] = Field(default=None, foreign_key="company.id")
    company: Optional[Company] = Relationship(back_populates="internships")
    
    supervisor_name: Optional[str] = None
    supervisor_email: Optional[str] = None
    
    is_finalized: bool = Field(default=False)

class PortfolioPage(SQLModel, AcademicYearMixin, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True, foreign_key="user.ldap_uid")
    title: str
    content_json: str = Field(default="{}")
    year_of_study: int = Field(default=1)
    is_public: bool = Field(default=False)

class UserFeedback(SQLModel, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True, foreign_key="user.ldap_uid")
    type: FeedbackType = Field(default=FeedbackType.IDEA)
    title: str
    description: str
    votes: int = Field(default=0)

class Announcement(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    matrix_event_id: str = Field(index=True)
    matrix_room_id: str
    title: str
    content: str
    author_uid: str
    created_at: datetime = Field(default_factory=datetime.now)
