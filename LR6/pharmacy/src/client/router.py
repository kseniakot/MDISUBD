from fastapi import APIRouter, Security, HTTPException, Depends
from src.auth.auth import role_required
from src.client.schemas import SClientAuth, SClientCreate
from src.client.service import ClientService

client_router = APIRouter(prefix="/users", tags=["Manage users"])


@client_router.get("/all/clients", response_model=list[SClientAuth], description="Get all clients")
async def get_all_clients(
        security_scopes=Security(role_required, scopes=["admin"])
) -> list[SClientAuth]:
    users = await ClientService.get_all_clients()
    if not users:
        raise HTTPException(status_code=404, detail="Clients not found")
    return [SClientAuth.model_validate(user) for user in users]


@client_router.get("/client/{client_id}", response_model=SClientAuth, description="Get client by id")
async def get_client_by_id(
        client_id: int,
        security_scopes=Security(role_required, scopes=["admin"])
) -> SClientAuth:
    user = await ClientService.get_client_by_id(client_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return SClientAuth.model_validate(user)


@client_router.put("/client/{client_id}", response_model=SClientAuth, description="Update client by id")
async def update_client_by_id(
        client_id: int,
        user: SClientCreate = Depends(),
        security_scopes=Security(role_required, scopes=["admin"])
) -> SClientAuth:
    updated_user = await ClientService.update_client(client_id, user.dict())
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return SClientAuth.model_validate(updated_user)


@client_router.delete("/client/{client_id}", response_model=SClientAuth, description="Delete client by id")
async def delete_client_by_id(
        client_id: int,
        security_scopes=Security(role_required, scopes=["admin"])
) -> SClientAuth:
    deleted_user = await ClientService.delete_client(client_id)
    if not deleted_user:
        raise HTTPException(status_code=404, detail="User not found")
    return SClientAuth.model_validate(deleted_user)
