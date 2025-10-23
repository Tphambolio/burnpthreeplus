"""Authentication token schemas."""
from typing import Optional
from pydantic import BaseModel, UUID4


class Token(BaseModel):
    """JWT token response."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    """JWT token payload."""

    sub: Optional[UUID4] = None
    type: Optional[str] = None
