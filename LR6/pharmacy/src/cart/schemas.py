from datetime import date
from typing import List

from pydantic import BaseModel, ConfigDict, field_validator, EmailStr
from pydantic import Field


class SDeleteProductFromCart(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    product_id: int = Field(..., description="Product id", example=1)


class SAddProductToCart(SDeleteProductFromCart):
    quantity: int = Field(..., description="Product quantity", example=1)


class SResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    id: int = Field(..., description="ID", example=1)


class ProductInfo(BaseModel):
    product_id: int = Field(..., description="ID of the product", example=101)
    product_name: str = Field(..., description="Name of the product", example="Vitamin C")
    quantity: int = Field(..., description="Quantity of the product", example=2)
    price: float = Field(..., description="Price of the product", example=15.50)


class CartInfo(BaseModel):
    cart_id: int = Field(..., description="ID of the cart (client ID)", example=101)
    total_price: float = Field(..., description="Total price of the cart", example=250.50)
    promocode: str | None = Field(None, description="Applied promocode, if any", example="SAVE10")
    discount: float | None = Field(None, description="Discount applied via promocode", example=15.0)
    products: List[ProductInfo] = Field(..., description="List of products in the cart")


class SPromoCode(BaseModel):
    model_config = ConfigDict(from_attributes=True, extra='forbid')
    id: int = Field(..., description="Promo code ID", example=1)
    code: str = Field(..., description="Promo code", example='SAVE10')
    discount: float = Field(..., description="Discount", example=10.0)
    expiration_date: date = Field(..., description="Expiration date", example='2023-12-31T23:59:59')


