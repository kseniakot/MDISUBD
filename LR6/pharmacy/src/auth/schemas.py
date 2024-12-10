from pydantic import BaseModel


class SToken(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str


class STokenData(BaseModel):
    username: str | None = None