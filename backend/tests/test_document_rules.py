from datetime import date
from decimal import Decimal
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'app'))

from schemas.structured_documents import (  # noqa: E402
    DocumentMetadata,
    DocumentType,
    LineItem,
    Party,
    StructuredDocumentData,
)
from services.document_rules import DocumentRules  # noqa: E402
from services.template_engine import TemplateEngine  # noqa: E402


class DocumentRulesTest(unittest.TestCase):
    def _purchase_order(self) -> StructuredDocumentData:
        return StructuredDocumentData(
            document_type=DocumentType.purchase_order,
            metadata=DocumentMetadata(
                title='Office furniture',
                document_number='PO-2026-001',
                issue_date=date(2026, 9, 21),
            ),
            company=Party(name='Sequoia Co., Ltd.'),
            supplier=Party(name='ABC Company Limited'),
            line_items=[
                LineItem(
                    description='Office chair',
                    quantity=Decimal('20'),
                    unit_price=Decimal('1250'),
                    discount=Decimal('1000'),
                    tax_rate=Decimal('7'),
                ),
            ],
        )

    def test_calculates_totals_without_ai_input(self) -> None:
        totals = DocumentRules.totals(self._purchase_order())

        self.assertEqual(totals.subtotal, Decimal('25000.00'))
        self.assertEqual(totals.discount, Decimal('1000.00'))
        self.assertEqual(totals.tax, Decimal('1680.00'))
        self.assertEqual(totals.total, Decimal('25680.00'))

    def test_purchase_order_is_export_ready_when_required_fields_exist(self) -> None:
        validation = DocumentRules.validate(self._purchase_order())

        self.assertTrue(validation.valid)
        self.assertEqual(validation.issues, [])

    def test_template_rejects_a_document_type_it_does_not_support(self) -> None:
        report = StructuredDocumentData(document_type=DocumentType.report)

        with self.assertRaises(ValueError):
            TemplateEngine.render('commercial-v1', report)


if __name__ == '__main__':
    unittest.main()
