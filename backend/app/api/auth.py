
from datetime import datetime, timedelta, timezone
import hashlib
import os
import secrets

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy import update
from sqlalchemy.orm import Session

from database import get_db
from models.password_reset import PasswordReset
from schemas.auth import (
    LoginRequest,
    LoginResponse,
    MessageResponse,
    PasswordResetRequest,
    PasswordResetConfirm,
    RegisterRequest,
    UserPublic,
)
from services.auth_service import AuthService

# Reuse the same authentication dependency used by the rest of the API.
from api.dashboard import current_user
from models.user import User


router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _public_user(user: User) -> UserPublic:
    """
    Convert internal User model -> safe public response.

    Never expose:
    - password hash
    - password reset token
    - refresh token
    - internal security fields
    - other sensitive columns
    """

    return UserPublic(
        id=user.id,
        email=user.email,
        name=user.name,
    )


def _normalize_email(email: str) -> str:
    """
    Normalize email before authentication.

    Passwords are intentionally NOT normalized.
    """

    return email.strip().casefold()


def _token_hash(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def _login_response(user: User) -> LoginResponse:
    return LoginResponse(
        token=AuthService.create_token(user),
        user=_public_user(user),
    )


@router.post(
    '/register',
    response_model=LoginResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    payload: RegisterRequest,
    response: Response,
    db: Session = Depends(get_db),
) -> LoginResponse:
    email = _normalize_email(payload.email)
    name = payload.name.strip()
    password = payload.password

    if not email or not name or len(password) < 8:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail='Name, email, and a password of at least 8 characters are required',
        )

    if db.scalar(select(User).where(User.email == email)) is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail='An account with this email already exists',
        )

    user = User(
        email=email,
        name=name,
        password_hash=AuthService.hash_password(password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    response.headers['Cache-Control'] = 'no-store'
    return _login_response(user)


@router.post(
    '/password-reset/request',
    response_model=MessageResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
def request_password_reset(
    payload: PasswordResetRequest,
    db: Session = Depends(get_db),
) -> MessageResponse:
    email = _normalize_email(payload.email)
    user = db.scalar(select(User).where(User.email == email))

    reset_token = None
    if user is not None:
        raw_token = secrets.token_urlsafe(32)
        reset_token = raw_token
        db.execute(
            update(PasswordReset)
            .where(PasswordReset.user_id == user.id)
            .where(PasswordReset.used_at.is_(None))
            .values(used_at=datetime.now(timezone.utc))
        )
        db.add(
            PasswordReset(
                user_id=user.id,
                token_hash=_token_hash(raw_token),
                expires_at=datetime.now(timezone.utc) + timedelta(minutes=30),
            )
        )
        db.commit()

    # Local development has no mail provider. Returning the token makes the
    # complete reset flow testable; production should deliver it by email.
    return MessageResponse(
        message='If an account exists for that email, a password reset link has been sent.',
        reset_token=reset_token if os.getenv('RESET_DELIVERY_MODE', 'dev') == 'dev' else None,
    )


@router.post(
    '/password-reset/confirm',
    response_model=MessageResponse,
    status_code=status.HTTP_200_OK,
)
def confirm_password_reset(
    payload: PasswordResetConfirm,
    db: Session = Depends(get_db),
) -> MessageResponse:
    if len(payload.password) < 8:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail='Password must be at least 8 characters',
        )

    reset = db.scalar(
        select(PasswordReset).where(
            PasswordReset.token_hash == _token_hash(payload.token),
            PasswordReset.used_at.is_(None),
        )
    )
    now = datetime.now(timezone.utc)
    expires_at = (
        reset.expires_at.replace(tzinfo=timezone.utc)
        if reset is not None and reset.expires_at.tzinfo is None
        else reset.expires_at if reset is not None else None
    )
    if reset is None or expires_at < now:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Invalid or expired reset token')

    user = db.get(User, reset.user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Invalid or expired reset token')

    user.password_hash = AuthService.hash_password(payload.password)
    reset.used_at = now
    db.commit()
    return MessageResponse(message='Your password has been updated. You can sign in now.')


# ---------------------------------------------------------------------------
# Login
# ---------------------------------------------------------------------------

@router.post(
    "/login",
    response_model=LoginResponse,
    status_code=status.HTTP_200_OK,
)
def login(
    payload: LoginRequest,
    response: Response,
    db: Session = Depends(get_db),
) -> LoginResponse:
    """
    Authenticate a user and return an access token.

    Security properties:
    - email is normalized
    - password is passed unchanged
    - invalid credentials always return the same message
    - response is marked as non-cacheable
    """

    email = _normalize_email(payload.email)

    if not email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Never strip/casefold the password.
    password = payload.password

    if not password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user = AuthService.authenticate(
        db,
        email,
        password,
    )

    # Do not distinguish:
    # - user does not exist
    # - wrong password
    #
    # Otherwise attackers can enumerate registered accounts.
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Keep authentication-token creation inside AuthService.
    # The router should not know JWT signing secrets or algorithms.
    token = AuthService.create_token(user)

    # Login responses should never be cached by browsers/proxies.
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"

    return LoginResponse(
        token=token,
        user=_public_user(user),
    )


# ---------------------------------------------------------------------------
# Current user
# ---------------------------------------------------------------------------

@router.get(
    "/me",
    response_model=UserPublic,
    status_code=status.HTTP_200_OK,
)
def get_current_user(
    user: User = Depends(current_user),
) -> UserPublic:
    """
    Return the authenticated user's public profile.

    This endpoint is useful for:
        GET /auth/me

    immediately after application startup / token restoration.
    """

    return _public_user(user)

