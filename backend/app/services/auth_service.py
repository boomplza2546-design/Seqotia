import hashlib
import hmac
import os
import secrets
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from models.user import User


class AuthService:
    @staticmethod
    def authenticate(db: Session, email: str, password: str) -> User | None:
        user = db.scalar(select(User).where(User.email == email.lower()))
        if user is None:
            return None

        if not AuthService.verify_password(password, user.password_hash):
            return None

        return user

    @staticmethod
    def create_token(user: User) -> str:
        payload = {
            'sub': str(user.id),
            'email': user.email,
            'exp': datetime.now(timezone.utc) + timedelta(hours=12),
        }
        return jwt.encode(
            payload,
            os.getenv('JWT_SECRET', 'change-this-seqotia-secret'),
            algorithm='HS256',
        )

    @staticmethod
    def hash_password(password: str) -> str:
        salt = secrets.token_hex(16)
        digest = hashlib.pbkdf2_hmac(
            'sha256', password.encode(), salt.encode(), 600_000,
        ).hex()
        return f'pbkdf2_sha256$600000${salt}${digest}'

    @staticmethod
    def verify_password(password: str, encoded: str) -> bool:
        try:
            algorithm, rounds, salt, expected = encoded.split('$')
            if algorithm != 'pbkdf2_sha256':
                return False
            actual = hashlib.pbkdf2_hmac(
                'sha256', password.encode(), salt.encode(), int(rounds),
            ).hex()
            return hmac.compare_digest(actual, expected)
        except (ValueError, TypeError):
            return False

    @staticmethod
    def current_user(token: str, db: Session) -> User:
        try:
            payload = jwt.decode(
                token,
                os.getenv('JWT_SECRET', 'change-this-seqotia-secret'),
                algorithms=['HS256'],
            )
            user_id = int(payload['sub'])
        except (jwt.InvalidTokenError, KeyError, TypeError, ValueError):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='Invalid or expired token',
            )

        user = db.get(User, user_id)
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='User no longer exists',
            )
        return user
