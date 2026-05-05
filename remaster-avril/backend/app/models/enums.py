from enum import Enum

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
