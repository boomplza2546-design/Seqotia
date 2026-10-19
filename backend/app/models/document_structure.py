from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, JSON, String, func
from sqlalchemy.orm import Mapped, mapped_column

from database import Base


class DocumentStructure(Base):
    """The semantic representation attached to an existing document asset.

    Keeping this in a separate table makes the structured workflow additive: old
    uploads stay readable while new and converted documents get a typed model.
    """

    __tablename__ = 'document_structures'

    id: Mapped[int] = mapped_column(primary_key=True)
    document_id: Mapped[int] = mapped_column(
        ForeignKey('documents.id'), unique=True, index=True,
    )
    document_type: Mapped[str] = mapped_column(String(80), index=True)
    template_id: Mapped[str] = mapped_column(String(80))
    data: Mapped[dict] = mapped_column(JSON)
    version: Mapped[int] = mapped_column(default=1)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(),
    )
