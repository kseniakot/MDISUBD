from sqlalchemy.ext.asyncio import AsyncSession

from src.utils.database import connection
from src.employee.repository import EmployeeRepository


class EmployeeService:

    @staticmethod
    @connection
    async def get_employees(session: AsyncSession):
        result = await EmployeeRepository.find_all(session)
        return result

    @staticmethod
    @connection
    async def get_employee_by_email(email: str, session: AsyncSession):
        result = await EmployeeRepository.find_one_or_none_by_email(session, email)
        return result

    @staticmethod
    @connection
    async def add_employee(employee: dict, session: AsyncSession):
        result = await EmployeeRepository.add_one(session, employee)
        return result

    @staticmethod
    @connection
    async def update_employee_by_id(employee_id: int, employee: dict, session: AsyncSession):
        result = await EmployeeRepository.update_one(session, employee_id, employee)
        return result

