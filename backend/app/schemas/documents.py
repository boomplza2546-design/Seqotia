from datetime import datetime

from pydantic import BaseModel, ConfigDict


class DocumentPublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    filename: str
    content_type: str
    status: str
    created_at: datetime


class PredictionRequest(BaseModel):
    document_id: int
    command: str


class PredictionResponse(BaseModel):
    document_id: int
    intent: str
    confidence: float
    matched_text: str | None
    proposed_text: str | None
    explanation: str


class ApplyChangeRequest(BaseModel):
    matched_text: str
    proposed_text: str


class ApplyChangeResponse(BaseModel):
    document_id: int
    changed: bool
    message: str


class FeedbackRequest(BaseModel):
    document_id: int | None = None
    command: str
    prediction: str
    accepted: bool
    correction: str | None = None


class FeedbackResponse(BaseModel):
    id: int
    message: str