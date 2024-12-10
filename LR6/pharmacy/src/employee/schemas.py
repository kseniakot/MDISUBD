from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, field_validator, EmailStr
from pydantic import Field


class SEmployeeAuth(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    role: str = Field("admin", description="User's role")
    first_name: str = Field("Ivan", max_length=120,
                            description="First name of new user")
    last_name: str = Field("Ivanov", max_length=120,
                           description="Last name of new user")
    phone: str = Field("+375336205338", description="User's phone number")
    email: EmailStr = Field("email@example.com", description="User's email")


