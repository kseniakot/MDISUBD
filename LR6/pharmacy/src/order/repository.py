from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from src.utils.base_repository import BaseRepository
from src.models import Order
from src.order.schemas import SProductDetail, SOrderDetail


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

    @classmethod
    async def get_order(cls, session: AsyncSession, order_id: int):
        query = text(f"""SELECT 
                            oi.order_id,
                            client_order.total_price,
                            product.id AS product_id,
                            product.name AS product_name,
                            product.price * (1 - COALESCE(promocode.discount, 0) / 100) AS product_price, 
                            oi.quantity,
                            address.street,
                            address.building,
                            promocode.code AS promocode_name, 
                            promocode.discount AS promocode_discount,
                            pharmacy.id AS pharmacy_id,
                            client_order.status AS status,
                            client_order.order_date AS order_date
                        FROM 
                            orderItem oi
                        JOIN 
                            client_order ON client_order.id = oi.order_id
                        JOIN 
                            product ON product.id = oi.product_id
                        JOIN 
                            pharmacy ON pharmacy.id = client_order.pharmacy_id
                        JOIN 
                            address ON address.id = pharmacy.address_id
                        LEFT JOIN 
                            promocode ON promocode.id = client_order.promocode_id 
                        WHERE 
                            oi.order_id = :order_id;""")

        try:
            result = (await session.execute(query, {"order_id": order_id})).fetchall()
            if not result:
                return None
            return cls._parse_orders(result).pop()

        except SQLAlchemyError as e:
            print(f"Error getting order: {e}")
            return None

    @classmethod
    async def get_all_client_orders(cls, session: AsyncSession, user_id: int | None = None):
        query = text(f"""SELECT * FROM get_order_details(:user_id);""")
        try:
            result = (await session.execute(query, {"user_id": user_id})).fetchall()
            if not result:
                return []
            return cls._parse_orders(result)

        except SQLAlchemyError as e:
            print(f"Error getting orders: {e}")

    @classmethod
    async def get_all_pharmacy_orders(cls, session: AsyncSession, pharmacy_id: int | None = None):

        query = text(f"""SELECT * FROM get_pharmacy_order_details(:pharmacy_id);""")
        try:
            result = (await session.execute(query, {"pharmacy_id": pharmacy_id})).fetchall()
            if not result:
                return []
            return cls._parse_orders(result)

        except SQLAlchemyError as e:
            print(f"Error getting orders: {e}")

    @classmethod
    def _parse_orders(cls, result) -> list[SOrderDetail]:
        orders_dict = {}
        print(result)
        for row in result:
            order_id = row[0]
            print(order_id)

            if order_id not in orders_dict:
                orders_dict[order_id] = SOrderDetail(
                    order_id=order_id,
                    total_price=row[1],
                    pharmacy_id=row[10],
                    street=row[6],
                    building=row[7],
                    promocode_name=row[8],
                    promocode_discount=row[9],
                    status=row[11],
                    order_date=row[12].date(),
                    product=[]
                )

            orders_dict[order_id].product.append(SProductDetail(
                product_id=row[2],
                product_name=row[3],
                product_price=row[4],
                quantity=row[5]
            ))

        return list(orders_dict.values())

    @classmethod
    async def change_order_status(cls, session: AsyncSession, order_data: dict, employee_id: int):
        config_query = text(f"""SELECT set_config('app.employee_id', :employee_id, true);""")
        query = text(f"""call update_order_status(:order_id, :status);""")
        order_data["status"] = order_data["status"].value
        print(order_data, employee_id)
        try:
            await session.execute(config_query, {"employee_id": f"{employee_id}"})
            await session.execute(query, order_data)
            await session.commit()
            return order_data
        except SQLAlchemyError as e:
            print(f"Error changing order status: {e}")
