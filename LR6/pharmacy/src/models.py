from datetime import date, datetime
from decimal import Decimal
from typing import Optional


class Description:
    def __init__(self, id: int, name: str):
        self.id = id
        self.name = name


class ProductType:
    def __init__(self, id: int, name: str):
        self.id = id
        self.name = name


class Manufacturer:
    def __init__(self, id: int, name: str, phone: Optional[str] = None, email: Optional[str] = None,
                 country: Optional[str] = None):
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.country = country


class Product:
    def __init__(self, id: int, name: str, description_id: Optional[int], price: Decimal,
                 product_type_id: Optional[int], photo: Optional[str], manufacturer_id: Optional[int],
                 analog_code: Optional[int]):
        self.id = id
        self.name = name
        self.description_id = description_id
        self.price = price
        self.product_type_id = product_type_id
        self.photo = photo
        self.manufacturer_id = manufacturer_id
        self.analog_code = analog_code


class Address:
    def __init__(self, id: int, street: str, building: int):
        self.id = id
        self.street = street
        self.building = building


class Pharmacy:
    def __init__(self, id: int, address_id: Optional[int]):
        self.id = id
        self.address_id = address_id


class ProductInstance:
    def __init__(self, id: int, product_id: int, quantity: int, pharmacy_id: int):
        self.id = id
        self.product_id = product_id
        self.quantity = quantity
        self.pharmacy_id = pharmacy_id


class Promocode:
    def __init__(self, id: int, code: str, discount: Decimal):
        self.id = id
        self.code = code
        self.discount = discount


class Client:
    def __init__(self, id: int, first_name: str, last_name: str, date_of_birth: Optional[date], phone: Optional[str],
                 email: str, password: str):
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.date_of_birth = date_of_birth
        self.phone = phone
        self.email = email
        self.password = password


class ClientOrder:
    def __init__(self, id: int, status: str, client_id: int, order_date: datetime, promocode_id: Optional[int],
                 total_price: Optional[Decimal], pharmacy_id: Optional[int]):
        self.id = id
        self.status = status
        self.client_id = client_id
        self.order_date = order_date
        self.promocode_id = promocode_id
        self.total_price = total_price
        self.pharmacy_id = pharmacy_id


class OrderItem:
    def __init__(self, id: int, product_id: int, quantity: int, order_id: int):
        self.id = id
        self.product_id = product_id
        self.quantity = quantity
        self.order_id = order_id


class Review:
    def __init__(self, id: int, client_id: int, rating: int, text: Optional[str], date: datetime):
        self.id = id
        self.client_id = client_id
        self.rating = rating
        self.text = text
        self.date = date


class Cart:
    def __init__(self, client_id: int, total_price: Decimal):
        self.client_id = client_id
        self.total_price = total_price


class CartItem:
    def __init__(self, id: int, product_id: int, quantity: int, cart_id: int):
        self.id = id
        self.product_id = product_id
        self.quantity = quantity
        self.cart_id = cart_id


class Role:
    def __init__(self, id: int, name: str, description: Optional[str] = None):
        self.id = id
        self.name = name
        self.description = description


class Employee:
    def __init__(self, id: int, role_id: int, first_name: str, last_name: str, phone: Optional[str], email: str,
                 date_of_birth: date, password: str):
        self.id = id
        self.role_id = role_id
        self.date_of_birth = date_of_birth
        self.first_name = first_name
        self.last_name = last_name
        self.phone = phone
        self.email = email
        self.password = password


class Action:
    def __init__(self, id: int, name: str, description: Optional[str], table_name: Optional[str]):
        self.id = id
        self.name = name
        self.description = description
        self.table_name = table_name


class Logs:
    def __init__(self, id: int, employee_id: int, action_id: int, action_date: datetime):
        self.id = id
        self.employee_id = employee_id
        self.action_id = action_id
        self.action_date = action_date
