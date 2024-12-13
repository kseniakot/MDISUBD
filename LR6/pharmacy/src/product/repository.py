from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from src.utils.base_repository import BaseRepository
from src.models import Product, Manufacturer, ProductType, Description
from src.product.schemas import SPurchaseInfo


class ProductRepository(BaseRepository):
    __tablename__ = "product"

    @classmethod
    async def to_product_object(cls, session, row):
        return Product(
            id=row[0],
            name=row[1],
            product_type=await ProductTypeRepository.find_one_or_none(session, row[4]),
            manufacturer=await ManufacturerRepository.find_one_or_none(session, row[6]),
            description=await DescriptionRepository.find_one_or_none(session, row[2]),
            price=row[3],
            photo=row[5],
            analog_code=row[7]
        )
    @classmethod
    async def to_purchase_info(cls, row):
        return SPurchaseInfo(
                        order_id=row[0],
                        order_date=row[1].isoformat(),
                        product_name=row[2],
                        product_quantity=row[3],
                        street=row[4],
                        building=row[5],
                        client_name=row[6],
                        manufacturer_name=row[7],
                        product_type=row[8]
                    ).model_dump()

    @classmethod
    async def find_all(cls, session: AsyncSession):
        try:
            query = text(r"""SELECT *
                           FROM
                               product p
                           JOIN
                               product_type pt ON p.product_type_id = pt.id
                           JOIN
                               manufacturer m ON p.manufacturer_id = m.id
                           JOIN 
                               description d ON p.description_id = d.id
                           ORDER BY
                               p.name ASC, pt.name ASC, m.name ASC;
                           """)
            rows = (await session.execute(query)).fetchall()
            if rows:
                return [await cls.to_product_object(session, row) for row in rows]
        except SQLAlchemyError as e:
            print(f"Error finding all: {e}")

    @classmethod
    async def find_one_or_none(cls, session: AsyncSession, id: int):
        query = text(f"SELECT * FROM {cls.__tablename__} WHERE id = :id")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id}, fetch_one=True)
            if result:
                return await cls.to_product_object(session, result)
        except SQLAlchemyError as e:
            print(f"Error finding one: {e}")
            return None

    @classmethod
    async def add_one(cls, session: AsyncSession, values: dict):
        row = await super().add_one(session, values)
        if row:
            return await cls.to_product_object(session, row)

    @classmethod
    async def update_one(cls, session: AsyncSession, id: int, values: dict):
        row = await super().update_one(session, id, values)
        if row:
            return await cls.to_product_object(session, row)

    @classmethod
    async def delete_one(cls, session: AsyncSession, id: int):
        row = await super().delete_one(session, id)
        if row:
            return await cls.to_product_object(session, row)

    @classmethod
    async def get_purchase_info(cls, session: AsyncSession, product_id: int | None = None):
        query = text(r"""SELECT 
                                o.id AS order_id,
                                o.order_date,
                                p.name AS product_name,
                                oi.quantity AS product_quantity,
                                street, 
                                building,
                                CONCAT(c.first_name, ' ', c.last_name) AS client_name,
                                m.name AS manufacturer_name,
                                pt.name AS product_type
                            FROM 
                                client_order o
                            JOIN 
                                orderItem oi ON o.id = oi.order_id
                            JOIN 
                                product p ON oi.product_id = p.id
                            JOIN 
                                pharmacy ph ON o.pharmacy_id = ph.id
                            JOIN 
                                client c ON o.client_id = c.id
                            JOIN 
                                manufacturer m ON p.manufacturer_id = m.id
                            JOIN 
                                product_type pt ON p.product_type_id = pt.id
                            JOIN 
                                address a ON ph.address_id = a.id
                            """
                     + ("WHERE p.id = :product_id " if product_id is not None else "")
                     + "ORDER BY o.order_date DESC;")

        try:
            params = {"product_id": product_id} if product_id is not None else {}
            rows = (await session.execute(query, params)).fetchall()

            if rows:
                purchase_info_list = [await cls.to_purchase_info(row) for row in rows]
                return purchase_info_list
        except SQLAlchemyError as e:
            print(f"Error getting purchase info: {e}")
            return []


class ManufacturerRepository(BaseRepository):
    __tablename__ = "manufacturer"

    @classmethod
    async def to_manufacturer_object(cls, session, row):
        return Manufacturer(
            id=row[0],
            name=row[1],
            phone=row[2],
            email=row[3],
            country=row[4]
        )

    @classmethod
    async def find_one_or_none(cls, session: AsyncSession, id: int):
        query = text(f"SELECT * FROM {cls.__tablename__} WHERE id = :id")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id}, fetch_one=True)
            if result:
                return await cls.to_manufacturer_object(session, result)
        except SQLAlchemyError as e:
            print(f"Error finding one: {e}")
            return None


class ProductTypeRepository(BaseRepository):
    __tablename__ = "product_type"

    @classmethod
    async def to_product_type_object(cls, row):
        return ProductType(
            id=row[0],
            name=row[1]
        )

    @classmethod
    async def find_one_or_none(cls, session: AsyncSession, id: int):
        query = text(f"SELECT * FROM {cls.__tablename__} WHERE id = :id")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id}, fetch_one=True)
            if result:
                return await cls.to_product_type_object(result)
        except SQLAlchemyError as e:
            print(f"Error finding one: {e}")
            return None

    @classmethod
    async def find_all(cls, session: AsyncSession):
        query = text(f"SELECT * FROM {cls.__tablename__}")
        try:
            rows = await cls.execute_raw_sql(session, query, fetch_one=False)
            if rows:
                return [await cls.to_product_type_object(row) for row in rows]

        except SQLAlchemyError as e:
            print(f"Error finding all: {e}")
            return None


class DescriptionRepository(BaseRepository):
    __tablename__ = "description"

    @classmethod
    async def to_description_object(cls, row):
        return Description(
            id=row[0],
            name=row[1]
        )

    @classmethod
    async def find_one_or_none(cls, session: AsyncSession, id: int):
        query = text(f"SELECT * FROM {cls.__tablename__} WHERE id = :id")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id}, fetch_one=True)
            if result:
                return await cls.to_description_object(result)
        except SQLAlchemyError as e:
            print(f"Error finding one: {e}")
            return None
