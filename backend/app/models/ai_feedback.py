from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from database import Base


class AIFeedback(Base):
    __tablename__ = 'ai_feedback'

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey('users.id'), index=True)
    document_id: Mapped[int | None] = mapped_column(
        ForeignKey('documents.id'), nullable=True, index=True,
    )
    command: Mapped[str] = mapped_column(Text)
    prediction: Mapped[str] = mapped_column(Text)
    accepted: Mapped[bool] = mapped_column(Boolean)
    correction: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(),
    )