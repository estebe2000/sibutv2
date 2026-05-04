from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship
from .links import ResourceACLink, ActivityCELink, ActivityACLink

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

    learning_outcomes: List[LearningOutcome] = Relationship(back_populates="resources", link_model=ResourceACLink)
