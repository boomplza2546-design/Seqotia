from decimal import Decimal, ROUND_HALF_UP

from schemas.structured_documents import (
    DocumentTotals,
    DocumentType,
    DocumentValidationResponse,
    StructuredDocumentData,
    ValidationIssue,
)


_MONEY = Decimal('0.01')


class DocumentRules:
    """Deterministic business rules. AI can suggest values, never calculate them."""

    @staticmethod
    def totals(data: StructuredDocumentData) -> DocumentTotals:
        subtotal = Decimal('0')
        discount = Decimal('0')
        tax = Decimal('0')
        for item in data.line_items:
            line_subtotal = item.quantity * item.unit_price
            line_discount = min(item.discount, line_subtotal)
            taxable_amount = line_subtotal - line_discount
            subtotal += line_subtotal
            discount += line_discount
            tax += taxable_amount * item.tax_rate / Decimal('100')
        total = subtotal - discount + tax
        return DocumentTotals(
            subtotal=subtotal.quantize(_MONEY, rounding=ROUND_HALF_UP),
            discount=discount.quantize(_MONEY, rounding=ROUND_HALF_UP),
            tax=tax.quantize(_MONEY, rounding=ROUND_HALF_UP),
            total=total.quantize(_MONEY, rounding=ROUND_HALF_UP),
            currency=data.currency.upper(),
        )

    @classmethod
    def validate(cls, data: StructuredDocumentData) -> DocumentValidationResponse:
        issues: list[ValidationIssue] = []
        metadata = data.metadata
        if not metadata.title:
            issues.append(ValidationIssue(
                field='metadata.title', message='Add a document title.', severity='warning',
            ))
        if not metadata.document_number:
            issues.append(ValidationIssue(
                field='metadata.document_number', message='Add a document number before export.', severity='error',
            ))
        if not metadata.issue_date:
            issues.append(ValidationIssue(
                field='metadata.issue_date', message='Add an issue date before export.', severity='error',
            ))

        commercial_types = {
            DocumentType.purchase_order,
            DocumentType.purchase_request,
            DocumentType.quotation,
            DocumentType.invoice,
            DocumentType.receipt,
            DocumentType.delivery_note,
            DocumentType.payment_request,
        }
        if data.document_type in commercial_types and not data.line_items:
            issues.append(ValidationIssue(
                field='line_items', message='Add at least one line item.', severity='error',
            ))
        if data.document_type == DocumentType.purchase_order:
            if not data.supplier or not data.supplier.name:
                issues.append(ValidationIssue(
                    field='supplier.name', message='Add a supplier for this purchase order.', severity='error',
                ))
            if not data.company or not data.company.name:
                issues.append(ValidationIssue(
                    field='company.name', message='Add your company for this purchase order.', severity='error',
                ))
        for index, item in enumerate(data.line_items):
            if item.quantity <= 0:
                issues.append(ValidationIssue(
                    field=f'line_items.{index}.quantity', message='Quantity must be greater than zero.', severity='error',
                ))
            if item.discount > item.quantity * item.unit_price:
                issues.append(ValidationIssue(
                    field=f'line_items.{index}.discount', message='Discount cannot exceed the line subtotal.', severity='error',
                ))
        return DocumentValidationResponse(
            valid=not any(issue.severity == 'error' for issue in issues),
            issues=issues,
            totals=cls.totals(data),
        )
