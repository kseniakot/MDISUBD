from fastapi import APIRouter, Security
from src.auth.auth import role_required

from src.cart.service import CartService, PromocodeService
from fastapi import HTTPException, status, Depends, Request
from src.auth.auth import validate_token_and_return_id
from src.cart.schemas import SAddProductToCart, SResponse, SDeleteProductFromCart, CartInfo, SPromoCode

cart_router = APIRouter(prefix="/cart", tags=["Manage cart"])


@cart_router.post("/add/", description="Add product to cart")
async def add_product_to_cart(user_id: int = Depends(validate_token_and_return_id),
                              product_data: SAddProductToCart = Depends(),
                              security_scopes=Security(role_required, scopes=["client"])
                              ) -> SResponse:
    response = await CartService.add_product_to_cart(cart_id=user_id, product=product_data.model_dump())
    if not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Error adding product to cart")
    return SResponse.model_validate(response)


@cart_router.post("/remove/", description="Remove product from cart")
async def remove_product_from_cart(user_id: int = Depends(validate_token_and_return_id),
                                   product_data: SDeleteProductFromCart = Depends(),
                                   security_scopes=Security(role_required, scopes=["client"])
                                   ) -> SResponse:
    response = await CartService.remove_product_from_cart(cart_id=user_id, product_id=product_data.product_id)
    if not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Error removing product from cart")
    return SResponse.model_validate(response)


@cart_router.post("/decrease/", description="Decrease product quantity")
async def decrease_product_quantity(user_id: int = Depends(validate_token_and_return_id),
                                    product_data: SDeleteProductFromCart = Depends(),
                                    security_scopes=Security(role_required, scopes=["client"])
                                    ) -> SResponse:
    response = await CartService.decrease_product_quantity(cart_id=user_id, product_id=product_data.product_id)
    if not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Error decreasing product quantity")
    return SResponse.model_validate(response)


@cart_router.get("/get/", description="Get cart")
async def get_cart(user_id: int = Depends(validate_token_and_return_id),
                   security_scopes=Security(role_required, scopes=["client"])
                   ) -> CartInfo:
    response = await CartService.get_cart(cart_id=user_id)
    if not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Error getting cart")
    return response


@cart_router.get("/get/promocodes", description="Get all promocodes")
async def get_all_promocodes() -> list[SPromoCode]:
    response = await PromocodeService.get_all_promocodes()
    if not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Error getting promocodes")
    return response


@cart_router.put("/apply/promocode", description="Apply promocode")
async def apply_promocode(promocode: str, user_id: int = Depends(validate_token_and_return_id),

                          security_scopes=Security(role_required, scopes=["client"])
                          ) -> SResponse:
    response = await CartService.apply_promocode(cart_id=user_id, promocode=promocode)
    if not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Error applying promocode")
    return SResponse.model_validate(response)