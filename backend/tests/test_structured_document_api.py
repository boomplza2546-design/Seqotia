import os
from pathlib import Path
import sys
import unittest


class StructuredDocumentApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        # Route functions use the same application services as HTTP requests.
        # An in-memory database keeps this test independent of Docker and httpx.
        os.environ['DATABASE_URL'] = 'sqlite:///:memory:'
        os.environ['JWT_SECRET'] = 'test-only-secret'
        sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'app'))

        from database import SessionLocal, init_db
        from models.user import User

        init_db()
        cls.db = SessionLocal()
        cls.user = cls.db.query(User).filter_by(email='admin@seqotia.com').one()

    @classmethod
    def tearDownClass(cls) -> None:
        cls.db.close()
        from database import engine
        engine.dispose()

    def test_creates_validates_and_exports_a_structured_purchase_order(self) -> None:
        from api.documents import _export_docx, create_structured_document, validate_document
        from models.document import Document
        from schemas.structured_documents import StructuredDocumentCreate

        created = create_structured_document(StructuredDocumentCreate.model_validate({
            'filename': 'Office chairs PO.docx',
            'template_id': 'commercial-v1',
            'data': {
                'document_type': 'purchase_order',
                'metadata': {
                    'title': 'Office chairs purchase order',
                    'document_number': 'PO-2026-001',
                    'issue_date': '2026-09-21',
                },
                'company': {'name': 'Sequoia Co., Ltd.'},
                'supplier': {'name': 'ABC Company Limited'},
                'line_items': [{
                    'description': 'Office chair',
                    'quantity': '20',
                    'unit': 'each',
                    'unit_price': '1250',
                    'tax_rate': '7',
                }],
                'currency': 'THB',
            },
        }), self.user, self.db)

        self.assertEqual(created.status, 'ready')
        self.assertTrue(created.validation.valid)
        self.assertEqual(str(created.validation.totals.total), '26750.00')

        validation = validate_document(created.document_id, self.user, self.db)
        self.assertTrue(validation.valid)

        document = self.db.get(Document, created.document_id)
        self.assertTrue(
            _export_docx(document).read().startswith(b'PK'),
            'Structured DOCX export should be a real DOCX zip archive.',
        )

    def test_draft_with_required_fields_missing_cannot_export(self) -> None:
        from api.documents import create_structured_document, export_document
        from fastapi import HTTPException
        from schemas.structured_documents import StructuredDocumentCreate

        created = create_structured_document(StructuredDocumentCreate.model_validate({
            'filename': 'Draft PO.docx',
            'template_id': 'commercial-v1',
            'data': {'document_type': 'purchase_order'},
        }), self.user, self.db)
        self.assertEqual(created.status, 'draft')

        with self.assertRaises(HTTPException) as error:
            export_document(created.document_id, 'pdf', self.user, self.db)
        self.assertEqual(error.exception.status_code, 422)


if __name__ == '__main__':
    unittest.main()
