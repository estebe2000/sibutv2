from typing import Optional
from sqlmodel import SQLModel, Field
from .base import TimestampMixin
from .enums import FeedbackType

class UserFeedback(SQLModel, TimestampMixin, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True, foreign_key="user.ldap_uid")
    type: FeedbackType = Field(default=FeedbackType.IDEA)
    title: str
    description: str
    votes: int = Field(default=0)
