import os
from collections.abc import Generator

from sqlalchemy import create_engine, select
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker


DATABASE_URL = os.getenv(
    'DATABASE_URL',
    'postgresql+psycopg://seqotia:seqotia@localhost:5432/seqotia',
)


class Base(DeclarativeBase):
    pass


from models.user import User
from models.ai_feedback import AIFeedback
from models.document import Document
from models.document_structure import DocumentStructure
from models.password_reset import PasswordReset


engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    Base.metadata.create_all(bind=engine)

    with SessionLocal() as db:
        if db.scalar(select(User).where(User.email == 'admin@seqotia.com')):
            return

        from services.auth_service import AuthService

        db.add(
            User(
                email='admin@seqotia.com',
                password_hash=AuthService.hash_password('admin123'),
                name='Admin User',
            )
        )
        db.commit()
