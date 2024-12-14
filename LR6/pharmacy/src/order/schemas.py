from pydantic import BaseModel, Field
from typing import Optional


class SProductDetail(BaseModel):
    product_id: int = Field(..., description="ID продукта", example=1)
    product_name: str = Field(..., description="Название продукта", example="Ibuprofen")
    product_price: float = Field(..., description="Цена продукта с учётом скидки", example=90.00)
    quantity: int = Field(..., description="Количество продукта в заказе", example=2)


class SOrderDetail(BaseModel):
    order_id: int = Field(..., description="ID заказа", example=1)
    total_price: float = Field(..., description="Общая стоимость заказа", example=200.00)
    product: SProductDetail = Field(..., description="Информация о продукте")
    street: str = Field(..., description="Улица доставки", example="Main Street")
    building: int = Field(..., description="Номер здания", example=10)
    promocode_name: Optional[str] = Field(None, description="Название промокода, если применён", example="SAVE10")
    promocode_discount: Optional[int] = Field(None, description="Скидка по промокоду в процентах", example=10)


class SCreateOrderResponse(BaseModel):
    order_id: int
