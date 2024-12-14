from sqlalchemy.ext.asyncio import AsyncSession

from src.utils.database import connection
from src.order.repository import OrderRepository


class OrderService:
    @staticmethod
    @connection
    async def create_order(order_data: dict, session: AsyncSession):
        order = await OrderRepository.create_order(session, order_data)
        return order


