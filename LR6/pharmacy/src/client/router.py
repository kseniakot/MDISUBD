from fastapi import APIRouter, Security
from src.auth.auth import role_required
from src.client.schemas import SClientAuth
from src.client.service import ClientService

client_router = APIRouter(prefix="/users", tags=["Manage users"])


@client_router.get("/all/clients", response_model=list[SClientAuth], description="Get all clients")
async def get_all_users(
    security_scopes=Security(role_required, scopes=["admin"])
) -> list[SClientAuth]:
    users = await ClientService.get_all_clients()
    return [SClientAuth.model_validate(user) for user in users]

