from fastapi import APIRouter, Security
from src.auth.auth import role_required

from src.order.service import OrderService
from fastapi import HTTPException, status, Depends, Request
from src.auth.auth import get_password_hash, validate_token_and_return_id

from src.order.schemas import SCreateOrderResponse
order_router = APIRouter(prefix="/order", tags=["Manage orders"])


@order_router.post("/create/", description="Create new order", response_model=SCreateOrderResponse)
async def create_order(pharmacy_id: int, cart_id: int = Depends(validate_token_and_return_id),
                       security_scopes=Security(role_required, scopes=["client"])):
    order_data = {"cart_id": cart_id, "pharmacy_id": pharmacy_id}
    order = await OrderService.create_order(order_data)
    if not order:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error creating order",
        )
    return SCreateOrderResponse.model_validate(order)
