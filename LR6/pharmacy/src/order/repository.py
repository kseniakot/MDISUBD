from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from src.utils.base_repository import BaseRepository
from src.models import Order


class OrderRepository(BaseRepository):

    @classmethod
    async def create_order(cls, session: AsyncSession, order_data: dict):
        query = text(f"""call create_order_from_cart(:cart_id, :pharmacy_id);""")
        order_id_query = text(f"""select id from client_order
                                            where client_id = :cart_id
                                            order by order_date desc
                                            limit 1 ;""")
        try:
            await session.execute(query, order_data)
            await session.commit()
            order_id = (await session.execute(order_id_query, {"cart_id": order_data["cart_id"]})).scalar()
            return {"order_id": order_id}
        except SQLAlchemyError as e:
            print(f"Error adding order: {e}")
