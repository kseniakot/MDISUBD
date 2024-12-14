from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from src.utils.base_repository import BaseRepository
from src.models import ProductInstance, Cart
from src.cart.schemas import ProductInfo, CartInfo, SPromoCode


class CartRepository(BaseRepository):

    @classmethod
    async def add_product_to_cart(cls, session: AsyncSession, cart_id: int, product: dict):
        query = text(f"""call add_to_cart(:product_id, :quantity, :cart_id);""")
        try:
            product["cart_id"] = cart_id
            await session.execute(query, product)
            await session.commit()
            return {"id": cart_id}
        except SQLAlchemyError as e:
            print(f"Error adding product to cart: {e}")

    @classmethod
    async def remove_product_from_cart(cls, session: AsyncSession, cart_id: int, product_id: int):
        query = text(f"""call remove_from_cart(:product_id, :cart_id);""")
        try:
            await session.execute(query, {"product_id": product_id, "cart_id": cart_id})
            await session.commit()
            return {"id": cart_id}
        except SQLAlchemyError as e:
            print(f"Error removing product from cart: {e}")

    @classmethod
    async def decrease_product_quantity(cls, session: AsyncSession, cart_id: int, product_id: int):
        query = text(f"""call decrease_product_quantity(:product_id, :cart_id);""")
        try:
            await session.execute(query, {"product_id": product_id, "cart_id": cart_id})
            await session.commit()
            return {"id": cart_id}
        except SQLAlchemyError as e:
            print(f"Error decreasing product quantity: {e}")

    @classmethod
    async def get_cart(cls, session: AsyncSession, cart_id: int):
        query = text(f"""select 
                            cart.client_id as cart_id,
                            total_price,
                            promocode.code as promocode,
                            promocode.discount as discount,
                            p.id as product_id,
                            p.name as product,
                            p.price as price,
                            cartItem.quantity as quantity
                            from cart 
                            left JOIN cartitem on cartItem.cart_id = cart.client_id
                            join product p on p.id = cartItem.product_id
                            left join promocode on promocode.id = cart.promocode_id
                            WHERE cart.client_id = :cart_id;""")
        try:
            cart_rows = await cls.execute_raw_sql(session, query, {"cart_id": cart_id}, fetch_one=False)
            if cart_rows:
                cart = CartInfo(
                    cart_id=cart_rows[0][0],
                    total_price=cart_rows[0][1],
                    promocode=cart_rows[0][2],
                    discount=cart_rows[0][3],
                    products=[]
                )
                for row in cart_rows:
                    product = ProductInfo(
                        product_id=row[4],
                        product_name=row[5],
                        quantity=row[7],
                        price=row[6]
                    )
                    cart.products.append(product)

                return cart
        except SQLAlchemyError as e:
            print(f"Error getting cart: {e}")

    @classmethod
    async def apply_promocode(cls, session: AsyncSession, cart_id: int, promocode: str):
        query = text(f"""call apply_promocode(:cart_id, :promocode);""")
        try:
            await session.execute(query, {"cart_id": cart_id, "promocode": promocode})
            await session.commit()
            return {"id": cart_id}
        except SQLAlchemyError as e:
            print(f"Error applying promocode: {e}")


class PromocodeRepository(BaseRepository):

    @classmethod
    async def get_all_promocodes(cls, session: AsyncSession):

        clean_query = text(f"""call delete_expired_promocodes();""")
        await session.execute(clean_query)
        await session.commit()
        get_query = text(f"""select id, code, discount, expiration_date from promocode;""")
        try:
            promocodes = await cls.execute_raw_sql(session, get_query, fetch_one=False)
            if promocodes:
                promocode_objects = []
                for promocode in promocodes:
                    promocode_object = SPromoCode(
                        id=promocode[0],
                        code=promocode[1],
                        discount=promocode[2],
                        expiration_date=promocode[3]
                    )
                    promocode_objects.append(promocode_object)
                return promocode_objects
        except SQLAlchemyError as e:
            print(f"Error getting promocode: {e}")
