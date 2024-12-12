import re
from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, field_validator, EmailStr
from pydantic import Field
from src.utils.sql_enums import RoleEnum


class SEmployeeAuth(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    id: int = Field(description="User's id", example=1)
    role: RoleEnum = Field("admin", description="User's role")
    first_name: str = Field("Ivan", max_length=120,
                            description="First name of new user")
    last_name: str = Field("Ivanov", max_length=120,
                           description="Last name of new user")
    phone: str = Field("+375336205338", description="User's phone number")
    email: EmailStr = Field("email@example.com", description="User's email")


class SEmployeeCreate(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    role_id: RoleEnum = Field("admin", description="User's role")
    first_name: str = Field("Ivan", max_length=120,
                            description="First name of new user")
    last_name: str = Field("Ivanov", max_length=120,
                           description="Last name of new user")
    password: str = Field(..., min_length=4, max_length=20, description="Password for new user")

    phone: str = Field("+375336205338", description="User's phone number")
    email: EmailStr = Field(..., example="email@example.com", description="User's email")

    @classmethod
    @field_validator("phone", mode='before')
    def check_phone(cls, value: str):
        if re.match(r"^\+375\d{9}$", value) is None:
            raise ValueError("Phone number must be valid and start with +375")
        return value
