from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'app'))

from schemas.structured_documents import DocumentType  # noqa: E402
from services.ai_service import AIService  # noqa: E402


class AIServiceTest(unittest.TestCase):
    def test_purchase_order_prompt_returns_a_reviewable_structured_proposal(self) -> None:
        proposal = AIService.generate_document(
            'Create a purchase order for 20 office chairs from ABC Company.',
        )

        self.assertEqual(proposal.data.document_type, DocumentType.purchase_order)
        self.assertEqual(proposal.template_id, 'commercial-v1')
        self.assertEqual(proposal.data.line_items[0].quantity, 20)
        self.assertEqual(proposal.data.line_items[0].description, 'office chairs')
        self.assertEqual(proposal.data.supplier.name, 'ABC Company')
        self.assertFalse(proposal.validation.valid)
        self.assertTrue(any(
            issue.field == 'metadata.document_number'
            for issue in proposal.validation.issues
        ))


if __name__ == '__main__':
    unittest.main()
