import logging

from fastapi import APIRouter, Depends, HTTPException, Response, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from database import get_db
from models.user import User
from schemas.dashboard import DashboardSummary
from services.auth_service import AuthService
from services.dashboard_service import DashboardService


logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/dashboard",
    tags=["dashboard"],
)

bearer = HTTPBearer(
    auto_error=False,
)


# ---------------------------------------------------------------------------
# Authentication dependency
# ---------------------------------------------------------------------------

def current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
    db: Session = Depends(get_db),
) -> User:
    """
    Resolve the authenticated user from the Bearer access token.

    This function is intentionally reusable by every protected endpoint.
    """

    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication scheme.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials.strip()

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user = AuthService.current_user(
            token,
            db,
        )
    except HTTPException:
        raise
    except Exception:
        logger.exception("Unexpected authentication failure.")

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user


# ---------------------------------------------------------------------------
# Dashboard
# ---------------------------------------------------------------------------

@router.get(
    "/summary",
    response_model=DashboardSummary,
    status_code=status.HTTP_200_OK,
)
def summary(
    response: Response,
    user: User = Depends(current_user),
    db: Session = Depends(get_db),
) -> DashboardSummary:
    """
    Return dashboard information for the currently authenticated user.
    """

    # Dashboard data may contain private user information.
    # Prevent browser/proxy caching.
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"

    try:
        return DashboardService.build_summary(
            db,
            user,
        )

    except HTTPException:
        raise

    except Exception:
        logger.exception(
            "Failed to build dashboard summary for user_id=%s",
            user.id,
        )

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Unable to load dashboard.",
        )