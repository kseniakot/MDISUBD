from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession


class BaseRepository:
    __tablename__ = None

    @classmethod
    async def execute_raw_sql(cls, session: AsyncSession, query: text, params: dict = None, fetch_one: bool = False):

        try:
            result = await session.execute(query, params)
            if fetch_one:
                return result.fetchone()           # returns a tuple
            return result.fetchall()            # returns a list of tuples
        except SQLAlchemyError as e:
            print(f"Error executing query: {e}")
            raise

    @classmethod
    async def add_one(cls, session: AsyncSession, values: dict):
        print(f"values: {values}")
        columns = ", ".join(values.keys())
        placeholders = ", ".join([f":{key}" for key in values.keys()])
        print(f"columns: {columns}", f"placeholders: {placeholders}")
        query = text(f"INSERT INTO {cls.__tablename__} ({columns}) VALUES ({placeholders}) RETURNING *")
        try:
            result = await cls.execute_raw_sql(session, query, values, fetch_one=True)
            print(f"result: {result}")
            await session.commit()
            return result
        except SQLAlchemyError as e:
            print(f"Error adding one: {e}")
            await session.rollback()
            return None

    @classmethod
    async def find_all(cls, session: AsyncSession):
        query = text(f"SELECT * FROM {cls.__tablename__}")
        try:
            result = await cls.execute_raw_sql(session, query, fetch_one=False)
            return result
        except SQLAlchemyError as e:
            print(f"Error finding all: {e}")
            return None

    @classmethod
    async def find_one_or_none(cls, session: AsyncSession, id: int):
        query = text(f"SELECT * FROM {cls.__tablename__} WHERE id = :id")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id}, fetch_one=True)
            return result
        except SQLAlchemyError as e:
            print(f"Error finding one: {e}")
            return None

    @classmethod
    async def update_one(cls, session: AsyncSession, id: int, values: dict):
        columns = ", ".join([f"{key} = :{key}" for key in values.keys()])
        query = text(f"UPDATE {cls.__tablename__} SET {columns} WHERE id = :id RETURNING *")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id, **values}, fetch_one=True)
            await session.commit()
            return result
        except SQLAlchemyError as e:
            print(f"Error updating one: {e}")
            await session.rollback()
            return None

    @classmethod
    async def delete_one(cls, session: AsyncSession, id: int):
        query = text(f"DELETE FROM {cls.__tablename__} WHERE id = :id RETURNING *")
        try:
            result = await cls.execute_raw_sql(session, query, {"id": id}, fetch_one=True)
            await session.commit()
            return result
        except SQLAlchemyError as e:
            print(f"Error deleting one: {e}")
            await session.rollback()
            return None


