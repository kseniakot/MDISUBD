from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession


class BaseRepository:
    model = None

    @classmethod
    async def execute_raw_sql(cls, session: AsyncSession, query: text, params: dict = None):

        try:
            result = await session.execute(query, params)
            return result.fetchall()            # returns a list of tuples
        except SQLAlchemyError as e:
            print(f"Error executing query: {e}")
            raise

    @classmethod
    async def add_one(cls, session: AsyncSession, values: dict):
        columns = ", ".join(values.keys())
        placeholders = ", ".join([f":{key}" for key in values.keys()])
        query = text(f"INSERT INTO {cls.model.__tablename__} ({columns} VALUES ({placeholders}) RETURNING *")
        try:
            result = await cls.execute_raw_sql(session, query, values)
            await session.commit()
            return result
        except SQLAlchemyError as e:
            print(f"Error adding one: {e}")
            await session.rollback()
            return None

    @classmethod
    async def find_all(cls, session: AsyncSession):
        query = text(f"SELECT * FROM {cls.model.__tablename__}")
        try:
            result = await cls.execute_raw_sql(session, query)
            return result
        except SQLAlchemyError as e:
            print(f"Error finding all: {e}")
            return None

    @classmethod
    async def find_one_or_none(cls, session: AsyncSession, id: int):
        query = text(f"SELECT * FROM {cls.model.__tablename__} WHERE id = :id")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id})
            return result
        except SQLAlchemyError as e:
            print(f"Error finding one: {e}")
            return None

    @classmethod
    async def update_one(cls, session: AsyncSession, id: int, values: dict):
        columns = ", ".join([f"{key} = :{key}" for key in values.keys()])
        query = text(f"UPDATE {cls.model.__tablename__} SET {columns} WHERE id = :id RETURNING *")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id, **values})
            await session.commit()
            return result
        except SQLAlchemyError as e:
            print(f"Error updating one: {e}")
            await session.rollback()
            return None

