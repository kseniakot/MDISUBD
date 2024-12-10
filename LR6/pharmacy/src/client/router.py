from fastapi import APIRouter, Security
from src.auth.auth import role_required
from src.client.schemas import SClientAuth
from src.client.service import ClientService

client_router = APIRouter(prefix="/users", tags=["Manage users"])


@client_router.get("/all", response_model=list[SClientAuth], description="Get all clients")
async def get_all_users(
    security_scopes=Security(role_required, scopes=["admin"])
) -> list[SClientAuth]:
    users = await ClientService.get_all_clients()
    return [SClientAuth.model_validate(user) for user in users]

'''
@client_router.put("/update/{user_id}", description="Update user", response_model=None)
async def update_user(
    user_id: int,
    new_location: SLocationUpdate,
    security_scopes=Security(role_required, scopes=["admin"]),
) -> None:
    await UserService.update_user_location_by_id(
        user_id=user_id, **new_location.model_dump()
    )
    return None
'''