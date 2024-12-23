from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from src.utils.config import settings

'''engine = create_engine(
    url=settings.DATABASE_URL_psycopg,
    echo=False,  # to see the SQL queries in console
    pool_size=5,  # max number of connections in the pool
    max_overflow=10,  # max number of connections that can be created (additional to pool_size)
)'''

async_engine = create_async_engine(
    url=settings.DATABASE_URL_asyncpg,
    echo=False,  # to see the SQL queries in console
    pool_size=5,  # max number of connections in the pool
    max_overflow=10,  # max number of connections that can be created (additional to pool_size)
)

Session = async_sessionmaker(async_engine, expire_on_commit=False)


def connection(method):
    async def wrapper(*args, **kwargs):
        async with Session() as session:
            try:
                return await method(*args, session=session, **kwargs)
            except Exception as e:
                await session.rollback()
                raise e
            finally:
                await session.close()

    return wrapper


'''
async def get_async_session():
    async with async_engine.connect() as conn:
        res = await conn.execute(text("SELECT VERSION()"))
        print(f"{res.all()=}")
        # conn.commit()
'''
# asyncio.run(get_async_session())
