from sqlalchemy import text
from src.utils.database import async_engine


async def get_data():
    async with async_engine.connect() as conn:
        query = text("SELECT * FROM cart")
        res = await conn.execute(query)
        print(f"{res.first()=}")
