from dataclasses import dataclass
from decimal import Decimal

from schemas.structured_documents import DocumentType, StructuredDocumentData, TemplatePublic
from services.document_rules import DocumentRules


@dataclass(frozen=True)
class _Template:
    id: str
    name: str
    supported_types: tuple[DocumentType, ...]
    description: str

    def public(self) -> TemplatePublic:
        return TemplatePublic(
            id=self.id,
            name=self.name,
            supported_types=list(self.supported_types),
            description=self.description,
        )


class TemplateEngine:
    """Maps validated semantic data to a document representation.

    This first renderer intentionally produces a reliable text layout. PDF/DOCX
    adapters consume this output today and can be replaced with richer layout
    adapters without changing document data or business rules.
    """

    _templates = (
        _Template(
            id='commercial-v1',
            name='Commercial document',
            supported_types=(
                DocumentType.purchase_order, DocumentType.purchase_request,
                DocumentType.quotation, DocumentType.invoice, DocumentType.receipt,
                DocumentType.delivery_note, DocumentType.payment_request,
            ),
            description='Line-item document with calculated totals and party details.',
        ),
        _Template(
            id='business-v1',
            name='Business document',
            supported_types=(
                DocumentType.memo, DocumentType.letter, DocumentType.contract,
                DocumentType.proposal, DocumentType.report, DocumentType.meeting_document,
                DocumentType.general_business_document,
            ),
            description='Structured general-business document with metadata and notes.',
        ),
    )

    @classmethod
    def list_templates(cls) -> list[TemplatePublic]:
        return [template.public() for template in cls._templates]

    @classmethod
    def template(cls, template_id: str) -> _Template:
        for template in cls._templates:
            if template.id == template_id:
                return template
        raise ValueError(f'Unknown template: {template_id}')

    @classmethod
    def render(cls, template_id: str, data: StructuredDocumentData) -> str:
        template = cls.template(template_id)
        if data.document_type not in template.supported_types:
            raise ValueError('The selected template does not support this document type.')
        totals = DocumentRules.totals(data)
        metadata = data.metadata
        lines = [
            (metadata.title or data.document_type.value.replace('_', ' ').title()).upper(),
            f'Document No.: {metadata.document_number or "Draft"}',
        ]
        if metadata.issue_date:
            lines.append(f'Date: {metadata.issue_date.isoformat()}')
        if data.company and data.company.name:
            lines.append(f'From: {data.company.name}')
        if data.supplier and data.supplier.name:
            lines.append(f'Supplier: {data.supplier.name}')
        if data.customer and data.customer.name:
            lines.append(f'Customer: {data.customer.name}')
        if data.line_items:
            lines.extend(['', 'ITEMS'])
            for index, item in enumerate(data.line_items, start=1):
                amount = item.quantity * item.unit_price - item.discount
                lines.append(
                    f'{index}. {item.description} | {item.quantity} {item.unit or ""} '
                    f'× {item.unit_price} = {amount.quantize(_MONEY)} {totals.currency}'
                )
            lines.extend([
                f'Subtotal: {totals.subtotal} {totals.currency}',
                f'Discount: {totals.discount} {totals.currency}',
                f'Tax: {totals.tax} {totals.currency}',
                f'Total: {totals.total} {totals.currency}',
            ])
        if data.payment_terms:
            lines.append(f'Payment terms: {data.payment_terms}')
        if data.notes:
            lines.extend(['', data.notes])
        return '\n'.join(lines)


_MONEY = Decimal('0.01')
