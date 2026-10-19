import os
from pathlib import Path
import sys
import unittest

os.environ['DATABASE_URL'] = 'sqlite:///:memory:'
os.environ['JWT_SECRET'] = 'test-only-secret'
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'app'))

from database import SessionLocal, init_db  # noqa: E402
from models.ai_feedback import AIFeedback  # noqa: E402
from models.document import Document  # noqa: E402
from models.user import User  # noqa: E402
from services.dashboard_service import DashboardService  # noqa: E402


class DashboardServiceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        init_db()

    def setUp(self) -> None:
        self.db = SessionLocal()
        self.user = self.db.query(User).filter_by(email='admin@seqotia.com').one()
        self.db.add(
            Document(
                owner_id=self.user.id,
                filename='brief.txt',
                content_type='text/plain',
                extracted_text='brief',
                source_data=b'brief',
            )
        )
        self.db.flush()
        self.db.add_all([
            AIFeedback(
                user_id=self.user.id,
                command='replace A with B',
                prediction='replace_text',
                accepted=True,
            ),
            AIFeedback(
                user_id=self.user.id,
                command='replace C with D',
                prediction='replace_text',
                accepted=False,
            ),
        ])
        self.db.commit()

    def tearDown(self) -> None:
        self.db.rollback()
        self.db.close()

    def test_summary_uses_persisted_workspace_counts(self) -> None:
        summary = DashboardService.build_summary(self.db, self.user)

        self.assertEqual(summary.total_users, 1)
        self.assertEqual(summary.documents, 1)
        self.assertEqual(summary.ai_jobs, 2)
        self.assertEqual(summary.completed_jobs, 1)
        self.assertIn('1 documents', summary.activities[0].subtitle)


if __name__ == '__main__':
    unittest.main()