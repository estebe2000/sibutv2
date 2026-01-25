from typing import List, Optional
from enum import Enum
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class UserRole(str, Enum):
    SUPER_ADMIN = "SUPER_ADMIN"
    ADMIN = "ADMIN"
    DEPT_HEAD = "DEPT_HEAD"           # Directeur de département
    ADMIN_STAFF = "ADMIN_STAFF"       # Personnel administratif
    STUDY_DIRECTOR = "STUDY_DIRECTOR" # Directeur d'études (Responsable Promo)
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

# --- ACTIVITY GROUPS (SAÉ) ---

class ActivityGroupStudentLink(SQLModel, table=True):
    """Lien entre un groupe d'activité et un étudiant"""
    group_id: Optional[int] = Field(default=None, foreign_key="activitygroup.id", primary_key=True)
    student_uid: Optional[str] = Field(default=None, foreign_key="user.ldap_uid", primary_key=True)

class ActivityGroup(SQLModel, table=True):
    """Groupe d'étudiants pour une SAÉ spécifique"""
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str # e.g., "Groupe 1", "Les Innovateurs"
    activity_id: int = Field(foreign_key="activity.id")
    academic_year: str = "2025-2026"
    
    activity: "Activity" = Relationship(back_populates="activity_groups")
    students: List["User"] = Relationship(back_populates="activity_groups", link_model=ActivityGroupStudentLink)

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    ldap_uid: str = Field(unique=True, index=True)
    email: str
    full_name: str
    phone: Optional[str] = None
    role: UserRole = Field(default=UserRole.GUEST)
    
    group_id: Optional[int] = Field(default=None, foreign_key="group.id")
    group: Optional[Group] = Relationship(back_populates="users")
    
    # Lien avec les groupes de SAÉ
    activity_groups: List[ActivityGroup] = Relationship(back_populates="students", link_model=ActivityGroupStudentLink)

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

# --- INTERNSHIPS ---

class PromotionResponsibility(SQLModel, table=True):
    """Lien entre un enseignant et une promotion (BUT1, Groupe A, etc.)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    teacher_uid: str = Field(index=True, foreign_key="user.ldap_uid")
    group_id: int = Field(index=True, foreign_key="group.id")
    academic_year: str = "2025-2026"

class Internship(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True, foreign_key="user.ldap_uid")
    academic_year: str = "2025-2026"
    
    # Dates (gérées par le tuteur)
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    
    # Informations Entreprise (gérées par l'étudiant)
    company_name: Optional[str] = None
    company_address: Optional[str] = None
    company_phone: Optional[str] = None
    company_email: Optional[str] = None
    
    # Encadrant Entreprise
    supervisor_name: Optional[str] = None
    supervisor_phone: Optional[str] = None
    supervisor_email: Optional[str] = None

    # Magic Link pour évaluation
    evaluation_token: Optional[str] = Field(default=None, index=True)
    token_expires_at: Optional[datetime] = None
    is_finalized: bool = Field(default=False)
    is_active: bool = Field(default=True)

    visits: List["InternshipVisit"] = Relationship(back_populates="internship")

class VisitType(str, Enum):
    SITE = "SITE"
    PHONE = "PHONE"
    VISIO = "VISIO"

class InternshipVisit(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    internship_id: int = Field(foreign_key="internship.id")
    date: datetime = Field(default_factory=datetime.now)
    type: VisitType = Field(default=VisitType.SITE)
    report_content: Optional[str] = None
    
    internship: Optional["Internship"] = Relationship(back_populates="visits")

class InternshipEvaluation(SQLModel, table=True):
    """Évaluation détaillée d'un stage par critère (Maître de stage, Étudiant ou Tuteur)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    internship_id: int = Field(foreign_key="internship.id")
    evaluator_role: str # "PRO", "STUDENT", "TEACHER"
    criterion_id: int # ID du critère de la grille
    score: float = Field(default=0.0) # 0-100%
    comment: Optional[str] = None
    updated_at: datetime = Field(default_factory=datetime.now)

# --- EVALUATION RUBRICS ---

class EvaluationRubric(SQLModel, table=True):
    """Grille d'évaluation pour une activité"""
    id: Optional[int] = Field(default=None, primary_key=True)
    activity_id: int = Field(index=True, foreign_key="activity.id")
    name: str # e.g., "Soutenance de mi-parcours"
    total_points: float = Field(default=20.0)
    academic_year: str = "2025-2026"
    
    criteria: List["RubricCriterion"] = Relationship(back_populates="rubric")

class RubricCriterion(SQLModel, table=True):
    """Ligne de critère dans une grille"""
    id: Optional[int] = Field(default=None, primary_key=True)
    rubric_id: int = Field(index=True, foreign_key="evaluationrubric.id")
    
    # Références optionnelles au référentiel
    ac_id: Optional[int] = Field(default=None, foreign_key="learningoutcome.id")
    ce_id: Optional[int] = Field(default=None, foreign_key="essentialcomponent.id")
    
    label: str # Intitulé du critère
    description: Optional[str] = None
    weight: float = Field(default=1.0) # Coefficient ou Points direct
    
    rubric: Optional[EvaluationRubric] = Relationship(back_populates="criteria")

class StudentFile(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True)
    filename: str
    nc_path: str 
    entity_type: ResponsibilityEntityType 
    entity_id: str 
    is_locked: bool = Field(default=False)
    academic_year: str = Field(default="2025-2026") # Pour l'historique
    uploaded_at: datetime = Field(default_factory=datetime.now)

class PortfolioPage(SQLModel, table=True):
--
    updated_at: datetime = Field(default_factory=datetime.now)

class StudentPPP(SQLModel, table=True):
    """Projet Personnel et Professionnel (PPP)"""
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(unique=True, index=True, foreign_key="user.ldap_uid")
    content_json: str = Field(default="{}") # Structure Editor.js pour le PPP
    career_goals: Optional[str] = None # Texte court sur les ambitions
    updated_at: datetime = Field(default_factory=datetime.now)

class PortfolioExportConfig(SQLModel, table=True):
    """Configuration personnalisée d'un export de portfolio"""
    id: Optional[int] = Field(default=None, primary_key=True)
    student_uid: str = Field(index=True, foreign_key="user.ldap_uid")
    preamble: Optional[str] = None
    selected_pages: str = Field(default="") # IDs séparés par virgules
    include_internships: bool = Field(default=True)
    include_sae: bool = Field(default=True)
    include_radar: bool = Field(default=True)
    theme_color: str = Field(default="#1971c2")
    created_at: datetime = Field(default_factory=datetime.now)

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
    activity_groups: List[ActivityGroup] = Relationship(back_populates="activity")