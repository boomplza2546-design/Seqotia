from pydantic import BaseModel


class LoginRequest(BaseModel):
    email: str
    password: str


class RegisterRequest(BaseModel):
    email: str
    password: str
    name: str


class PasswordResetRequest(BaseModel):
    email: str


class PasswordResetConfirm(BaseModel):
    token: str
    password: str


class UserPublic(BaseModel):
    id: int
    email: str
    name: str


class LoginResponse(BaseModel):
    token: str
    user: UserPublic


class MessageResponse(BaseModel):
    message: str
    reset_token: str | None = None
