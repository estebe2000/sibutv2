from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship
from .base import TimestampMixin, AcademicYearMixin
from .enums import UserRole
from .links import ActivityGroupStudentLink

class Group(SQLModel, AcademicYearMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    year: int
    pathway: str
    formation_type: str = "FI"

    users: List["User"] = Relationship(back_populates="group")

class User(SQLModel, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    ldap_uid: str = Field(unique=True, index=True)
    email: str = Field(index=True)
    full_name: str
    phone: Optional[str] = None
    role: UserRole = Field(default=UserRole.GUEST)

    group_id: Optional[int] = Field(default=None, foreign_key="group.id")
    group: Optional[Group] = Relationship(back_populates="users")

    activity_groups: List["ActivityGroup"] = Relationship(back_populates="students", link_model=ActivityGroupStudentLink)
