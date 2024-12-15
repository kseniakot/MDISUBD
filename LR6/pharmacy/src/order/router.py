from fastapi import APIRouter, Security
from src.auth.auth import role_required

from src.order.service import OrderService
from fastapi import HTTPException, status, Depends, Request
from src.auth.auth import get_password_hash, validate_token_and_return_id

from src.order.schemas import SCreateOrderResponse, SOrderDetail, SChangeOrderStatus

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


@order_router.get("/get/", description="Get order by id", response_model=SOrderDetail)
async def get_order(order_id: int, user_id: int = Depends(validate_token_and_return_id),
                    security_scopes=Security(role_required, scopes=["employee"])):
    order = await OrderService.get_order(order_id)
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found",
        )
    return SOrderDetail.model_validate(order)


@order_router.get("/get_all/", description="Get all orders", response_model=list[SOrderDetail])
async def get_all_orders(user_id: int = Depends(validate_token_and_return_id),
                         security_scopes=Security(role_required, scopes=["client"])):
    orders = await OrderService.get_all_client_orders(user_id)
    if not orders:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Orders not found",
        )
    return orders


@order_router.get("/pharmacy/", description="Get all orders for pharmacy", response_model=list[SOrderDetail])
async def get_all_pharmacy_orders(pharmacy_id: int | None = None,
                                  security_scopes=Security(role_required, scopes=["employee"])):
    orders = await OrderService.get_all_pharmacy_orders(pharmacy_id)
    if not orders:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Orders not found",
        )
    return orders


@order_router.put("/change_status/", description="Change order status", response_model=SChangeOrderStatus)
async def change_order_status(order_data=Depends(SChangeOrderStatus),
                              employee_id: int = Depends(validate_token_and_return_id),
                              security_scopes=Security(role_required, scopes=["employee"])):
    new_order_data = await OrderService.change_order_status(order_data=order_data.model_dump(), employee_id=employee_id)
    if not new_order_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error changing order status",
        )
    return SChangeOrderStatus.model_validate(new_order_data)


@order_router.delete("/delete/", description="Delete order", response_model=SCreateOrderResponse)
async def delete_order(order_id: int, user_id: int = Depends(validate_token_and_return_id),
                       employee_id: int = Depends(validate_token_and_return_id),
                       security_scopes=Security(role_required, scopes=["employee"])):
    try:
        order = await OrderService.delete_order(order_id=order_id, employee_id=employee_id)
        if not order:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Error deleting order",
            )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"error": str(e)},
        )
    return SCreateOrderResponse.model_validate(order)
