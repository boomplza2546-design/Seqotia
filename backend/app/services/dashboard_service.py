from sqlalchemy import func, select
from sqlalchemy.orm import Session

from models.ai_feedback import AIFeedback
from models.document import Document
from models.user import User
from schemas.dashboard import ActivityItem, DashboardSummary


class DashboardService:
    """Build dashboard data from the authenticated user's persisted workspace."""

    @staticmethod
    def build_summary(db: Session, user: User) -> DashboardSummary:
        total_users = db.scalar(select(func.count()).select_from(User)) or 0
        documents = db.scalar(
            select(func.count())
            .select_from(Document)
            .where(Document.owner_id == user.id)
        ) or 0
        ai_jobs = db.scalar(
            select(func.count())
            .select_from(AIFeedback)
            .where(AIFeedback.user_id == user.id)
        ) or 0
        completed_jobs = db.scalar(
            select(func.count())
            .select_from(AIFeedback)
            .where(
                AIFeedback.user_id == user.id,
                AIFeedback.accepted.is_(True),
            )
        ) or 0

        return DashboardSummary(
            user_name=user.name,
            total_users=total_users,
            documents=documents,
            ai_jobs=ai_jobs,
            completed_jobs=completed_jobs,
            activities=[
                ActivityItem(
                    title='AI workspace connected',
                    subtitle=f'{documents} documents ready for analysis',
                    kind='database',
                ),
            ],
        )
