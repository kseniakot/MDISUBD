from sqlalchemy.ext.asyncio import AsyncSession

from src.utils.database import connection
from src.client.repository import ClientRepository


class ClientService:
    @staticmethod
    @connection
    async def add_client(client: dict, session: AsyncSession):
        result = await ClientRepository.add_one(session, client)
        return result

    @staticmethod
    @connection
    async def get_all_clients(session: AsyncSession):
        result = await ClientRepository.find_all(session)
        return result

    @staticmethod
    @connection
    async def get_client_by_id(id: int, session: AsyncSession):
        result = await ClientRepository.find_one_or_none(session, id)
        return result

    @staticmethod
    @connection
    async def get_client_by_email(email: str, session: AsyncSession):
        result = await ClientRepository.find_one_or_none_by_email(session, email)
        return result

    @staticmethod
    @connection
    async def update_client(id: int, user: dict, session: AsyncSession):
        result = await ClientRepository.update_one(session, id, user)
        return result

    @staticmethod
    @connection
    async def delete_client(id: int, session: AsyncSession):
        result = await ClientRepository.delete_one(session, id)
        return result
