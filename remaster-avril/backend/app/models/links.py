from typing import Optional
from sqlmodel import SQLModel, Field

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
