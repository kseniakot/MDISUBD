from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, field_validator, EmailStr
from pydantic import Field

import re


class SClientCreate(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    first_name: str = Field("Ivan", max_length=120,
                            description="First name of new user")
    last_name: str = Field("Ivanov",  max_length=120,
                           description="Last name of new user")
    password: str = Field(..., min_length=4, max_length=20, description="Password for new user")

    date_of_birth: date = Field("2004-11-07", description="User's birth date", examples=["YYYY-MM-DD"])
    phone: str = Field("+375336205338", description="User's phone number")
    email: EmailStr = Field("email@example.com", description="User's email")

    @classmethod
    @field_validator("birth_date", mode='before')
    def check_birth_date(cls, value: date):
        if value and value >= datetime.now().date():
            raise ValueError("Birth date must be in the past")
        return value

    @classmethod
    @field_validator("phone", mode='before')
    def check_phone(cls, value: str):
        if re.match(r"^\+375\d{9}$", value) is None:
            raise ValueError("Phone number must be valid and start with +375")
        return value


class SClientAuth(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    first_name: str = Field("Ivan", max_length=120,
                            description="First name of new user")
    last_name: str = Field("Ivanov", max_length=120,
                           description="Last name of new user")

    date_of_birth: date = Field("2004-11-07", description="User's birth date", examples=["YYYY-MM-DD"])
    phone: str = Field("+375336205338", description="User's phone number")
    email: EmailStr = Field("email@example.com", description="User's email")


class SToken(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str


class STokenData(BaseModel):
    username: str | None = None
