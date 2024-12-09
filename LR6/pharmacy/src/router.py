from datetime import timedelta
from typing import Annotated

import jwt
from jwt import InvalidTokenError
from fastapi import APIRouter, HTTPException, status, Depends, Security

from fastapi.security import OAuth2PasswordRequestForm  # standard FastAPI class for login form (username and password)

from src.utils.config import settings
from src.auth.auth import (
    create_access_token,
    get_password_hash,
    role_required,
    verify_password,
)

from src.schemas import SToken, SClientAuth, SClientCreate
from src.service import ClientService

router_clients = APIRouter(prefix="/users", tags=["Manage users"])


@router_clients.post("/token", response_model=SToken, description="Get access token")
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()]) -> SToken:
    client = await ClientService.get_client_by_email(form_data.username)
    if not client or not verify_password(form_data.password, client.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": client.email},
        user_role=None,
        expires_delta=access_token_expires,
    )
    refresh_token = create_access_token(
        data={"sub": client.email}, expires_delta=timedelta(days=180)
    )

    return SToken(
        access_token=access_token, refresh_token=refresh_token, token_type="bearer"
    )


@router_clients.post("/refresh")
async def refresh_access_token(refresh_token: str):
    try:
        payload = jwt.decode(
            refresh_token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        username = payload.get("sub")
        if not username:
            raise HTTPException(status_code=401, detail="Invalid refresh token")

        client = await ClientService.get_client_by_email(email=username)
        if not client:
            raise HTTPException(status_code=401, detail="User not found")

        access_token = create_access_token(data={"sub": username})

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
        }
    except InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


@router_clients.post("/register", response_model=SClientAuth, description="Register new user")
async def register_user(
    client_data: SClientCreate = Depends(),) -> SClientAuth:
    client = await ClientService.get_client_by_email(email=client_data.email)
    if client:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered",
        )

    hashed_password = get_password_hash(client_data.password)

    new_client_data = client_data.model_dump()
    print(new_client_data)
    new_client_data["password"] = hashed_password
    new_user = await ClientService.add_client(new_client_data)

    return SClientAuth.model_validate(new_user)

'''
@router.get("/all", response_model=list[SUserAuth], description="Get all users")
async def get_all_users(
    security_scopes=Security(role_required, scopes=["admin"])
) -> list[SUserAuth]:
    users = await find_all_users()
    return [SUserAuth.model_validate(user) for user in users]


@router.put("/update/{user_id}", description="Update user", response_model=None)
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