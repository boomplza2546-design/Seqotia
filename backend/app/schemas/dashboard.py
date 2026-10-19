from pydantic import BaseModel


class ActivityItem(BaseModel):
    title: str
    subtitle: str
    kind: str


class DashboardSummary(BaseModel):
    user_name: str
    total_users: int
    documents: int
    ai_jobs: int
    completed_jobs: int
    activities: list[ActivityItem]