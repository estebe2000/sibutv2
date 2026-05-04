from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship
from .base import AcademicYearMixin
from .enums import ActivityType
from .links import ActivityACLink, ActivityCELink, ActivityGroupStudentLink
from .curriculum import LearningOutcome, EssentialComponent
from .user import User

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
    activity_groups: List["ActivityGroup"] = Relationship(back_populates="activity")

class ActivityGroup(SQLModel, AcademicYearMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    activity_id: int = Field(foreign_key="activity.id")

    activity: Activity = Relationship(back_populates="activity_groups")
    students: List[User] = Relationship(back_populates="activity_groups", link_model=ActivityGroupStudentLink)
