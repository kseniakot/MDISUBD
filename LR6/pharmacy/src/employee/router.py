from fastapi import APIRouter, Security
from src.auth.auth import role_required
from src.employee.schemas import SEmployeeAuth, SEmployeeCreate
from src.employee.service import EmployeeService
from fastapi import HTTPException, status, Depends, Request
from src.auth.auth import get_password_hash

employee_router = APIRouter(prefix="/users", tags=["Manage users"])


@employee_router.get("/all/employees", response_model=list[SEmployeeAuth], description="Get all employees")
async def get_all_users(
        security_scopes=Security(role_required, scopes=["admin"])
) -> list[SEmployeeAuth]:
    users = await EmployeeService.get_employees()
    return [SEmployeeAuth.model_validate(user.to_auth_dict()) for user in users]


@employee_router.post("/create/employee", response_model=SEmployeeAuth, description="Create new employee")
async def register_user(
        employee_data: SEmployeeCreate = Depends(),
        security_scopes=Security(role_required, scopes=["admin"])) -> SEmployeeAuth:
    employee = await EmployeeService.get_employee_by_email(email=employee_data.email)
    if employee:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered",
        )

    hashed_password = get_password_hash(employee_data.password)

    new_employee_data = employee_data.model_dump()
    new_employee_data["password"] = hashed_password

    new_user = await EmployeeService.add_employee(new_employee_data)

    if not new_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error creating user",
        )
    return SEmployeeAuth.model_validate(new_user.to_auth_dict())