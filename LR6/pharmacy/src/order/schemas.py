from datetime import date

from pydantic import BaseModel, Field
from src.utils.sql_enums import StatusEnum


class SProductDetail(BaseModel):
    product_id: int = Field(..., description="ID продукта", example=1)
    product_name: str = Field(..., description="Название продукта", example="Ibuprofen")
    product_price: float = Field(..., description="Цена продукта с учётом скидки", example=90.00)
    quantity: int = Field(..., description="Количество продукта в заказе", example=2)


class SOrderDetail(BaseModel):
    order_id: int = Field(..., description="ID заказа", example=1)
    total_price: float | None = Field(..., description="Общая стоимость заказа", example=200.00)
    product: list[SProductDetail] | None = Field(..., description="Информация о продукте")
    pharmacy_id: int = Field(..., description="ID аптеки", example=1)
    street: str = Field(..., description="Улица доставки", example="Main Street")
    building: int = Field(..., description="Номер здания", example=10)
    promocode_name: str | None = Field(None, description="Название промокода, если применён", example="SAVE10")
    promocode_discount: int | None = Field(None, description="Скидка по промокоду в процентах", example=10)
    status: StatusEnum = Field(..., description="Статус заказа", example="completed")
    order_date: date = Field(..., description="Дата заказа", example="2022-01-01")


class SCreateOrderResponse(BaseModel):
    order_id: int


class SChangeOrderStatus(BaseModel):
    order_id: int = Field(..., description="ID заказа", example=1)
    status: StatusEnum = Field(..., description="Статус заказа", example="completed")
