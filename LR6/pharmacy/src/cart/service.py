from sqlalchemy.ext.asyncio import AsyncSession

from src.utils.database import connection
from src.cart.repository import CartRepository, PromocodeRepository


class CartService:
    @staticmethod
    @connection
    async def add_product_to_cart(cart_id: int, product: dict, session: AsyncSession):
        result = await CartRepository.add_product_to_cart(session, cart_id, product)
        return result

    @staticmethod
    @connection
    async def remove_product_from_cart(cart_id: int, product_id: int, session: AsyncSession):
        result = await CartRepository.remove_product_from_cart(session, cart_id, product_id)
        return result

    @staticmethod
    @connection
    async def decrease_product_quantity(cart_id: int, product_id: int, session: AsyncSession):
        result = await CartRepository.decrease_product_quantity(session, cart_id, product_id)
        return result

    @staticmethod
    @connection
    async def get_cart(cart_id: int, session: AsyncSession):
        result = await CartRepository.get_cart(session, cart_id)
        return result

    @staticmethod
    @connection
    async def apply_promocode(cart_id: int, promocode: str, session: AsyncSession):
        result = await CartRepository.apply_promocode(session, cart_id, promocode)
        return result


class PromocodeService:
    @staticmethod
    @connection
    async def get_all_promocodes(session: AsyncSession):
        result = await PromocodeRepository.get_all_promocodes(session)
        return result
