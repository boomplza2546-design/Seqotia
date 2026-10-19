from datetime import date, datetime
from decimal import Decimal
from enum import Enum

from pydantic import BaseModel, Field


class DocumentType(str, Enum):
    purchase_order = 'purchase_order'
    purchase_request = 'purchase_request'
    quotation = 'quotation'
    invoice = 'invoice'
    receipt = 'receipt'
    delivery_note = 'delivery_note'
    payment_request = 'payment_request'
    memo = 'memo'
    letter = 'letter'
    contract = 'contract'
    proposal = 'proposal'
    report = 'report'
    meeting_document = 'meeting_document'
    general_business_document = 'general_business_document'


class Address(BaseModel):
    line1: str | None = None
    line2: str | None = None
    district: str | None = None
    province: str | None = None
    postal_code: str | None = None
    country: str | None = None


class Party(BaseModel):
    name: str | None = None
    tax_id: str | None = None
    email: str | None = None
    phone: str | None = None
    address: Address | None = None


class DocumentMetadata(BaseModel):
    title: str | None = None
    document_number: str | None = None
    issue_date: date | None = None
    due_date: date | None = None
    reference_number: str | None = None


class LineItem(BaseModel):
    description: str = Field(min_length=1, max_length=500)
    quantity: Decimal = Field(default=Decimal('1'), ge=0)
    unit: str | None = None
    unit_price: Decimal = Field(default=Decimal('0'), ge=0)
    discount: Decimal = Field(default=Decimal('0'), ge=0)
    tax_rate: Decimal = Field(default=Decimal('0'), ge=0, le=100)


class StructuredDocumentData(BaseModel):
    document_type: DocumentType
    metadata: DocumentMetadata = Field(default_factory=DocumentMetadata)
    company: Party | None = None
    supplier: Party | None = None
    customer: Party | None = None
    line_items: list[LineItem] = Field(default_factory=list)
    currency: str = Field(default='THB', min_length=3, max_length=3)
    payment_terms: str | None = None
    notes: str | None = None


class ValidationIssue(BaseModel):
    field: str
    message: str
    severity: str


class DocumentTotals(BaseModel):
    subtotal: Decimal
    discount: Decimal
    tax: Decimal
    total: Decimal
    currency: str


class DocumentValidationResponse(BaseModel):
    valid: bool
    issues: list[ValidationIssue]
    totals: DocumentTotals


class TemplatePublic(BaseModel):
    id: str
    name: str
    supported_types: list[DocumentType]
    description: str


class StructuredDocumentCreate(BaseModel):
    filename: str = Field(min_length=1, max_length=255)
    template_id: str
    data: StructuredDocumentData


class StructuredDocumentUpdate(BaseModel):
    template_id: str | None = None
    data: StructuredDocumentData


class StructuredDocumentPublic(BaseModel):
    document_id: int
    filename: str
    status: str
    template_id: str
    version: int
    data: StructuredDocumentData
    validation: DocumentValidationResponse
    created_at: datetime
    updated_at: datetime


class DocumentGenerationRequest(BaseModel):
    prompt: str = Field(min_length=3, max_length=4000)


class DocumentGenerationResponse(BaseModel):
    prompt: str
    confidence: float = Field(ge=0, le=1)
    explanation: str
    template_id: str
    data: StructuredDocumentData
    validation: DocumentValidationResponse
