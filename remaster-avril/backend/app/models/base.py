from datetime import datetime
from sqlmodel import Field

# --- MIXINS ---
# Note: Mixins should NOT inherit from SQLModel to avoid MRO issues in SQLModel/Pydantic
class TimestampMixin:
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class AcademicYearMixin:
    academic_year: str = Field(default="2025-2026", index=True)
