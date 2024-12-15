from sqlalchemy.ext.asyncio import AsyncSession

from src.utils.database import connection
from src.order.repository import OrderRepository


class OrderService:
    @staticmethod
    @connection
    async def create_order(order_data: dict, session: AsyncSession):
        order = await OrderRepository.create_order(session, order_data)
        return order

    @staticmethod
    @connection
    async def get_order(order_id: int, session: AsyncSession):
        order = await OrderRepository.get_order(session, order_id)
        return order

    @staticmethod
    @connection
    async def get_all_client_orders(user_id: int, session: AsyncSession):
        orders = await OrderRepository.get_all_client_orders(session, user_id)
        return orders

    @staticmethod
    @connection
    async def get_all_pharmacy_orders(pharmacy_id: int, session: AsyncSession):
        orders = await OrderRepository.get_all_pharmacy_orders(session, pharmacy_id)
        return orders

    @staticmethod
    @connection
    async def change_order_status(order_data: dict, employee_id: int, session: AsyncSession):
        new_order_data = await OrderRepository.change_order_status(session, order_data, employee_id)
        return new_order_data

