from sqlmodel import create_engine, Session
from ..core.config import settings

# Create the database engine
engine = create_engine(settings.DATABASE_URL)

def get_session():
    """Dependency for getting a database session."""
    with Session(engine) as session:
        yield session
