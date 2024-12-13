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

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name
        }


class Manufacturer:
    def __init__(self, id: int, name: str, phone: str | None, email: str | None,
                 country: str | None):
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.country = country


class Product:
    def __init__(self, id: int, name: str, description: Description, price: Decimal,
                 product_type: ProductType, photo: str | None, manufacturer: Manufacturer,
                 analog_code: int | None):
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.product_type = product_type
        self.photo = photo
        self.manufacturer = manufacturer
        self.analog_code = analog_code

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description.name,
            "price": self.price,
            "product_type": self.product_type.name,
            "photo": self.photo,
            "manufacturer": self.manufacturer.name,
            "analog_code": self.analog_code
        }


class Address:
    def __init__(self, id: int, street: str, building: int):
        self.id = id
        self.street = street
        self.building = building


class Pharmacy:
    def __init__(self, id: int, address: Address):
        self.id = id
        self.address = address


class ProductInstance:
    def __init__(self, id: int, product: Product, quantity: int, pharmacy: Pharmacy):
        self.id = id
        self.product = product
        self.quantity = quantity
        self.pharmacy = pharmacy


class Promocode:
    def __init__(self, id: int, code: str, discount: Decimal):
        self.id = id
        self.code = code
        self.discount = discount


class Client:
    def __init__(self, id: int, first_name: str, last_name: str, date_of_birth: date | None, phone: str | None,
                 email: str, password: str):
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.date_of_birth = date_of_birth
        self.phone = phone
        self.email = email
        self.password = password


class Order:
    def __init__(self, id: int, status: str, client: Client, order_date: datetime, promocode: Promocode,
                 total_price: Decimal | None, pharmacy: Pharmacy):
        self.id = id
        self.status = status
        self.client = client
        self.order_date = order_date
        self.promocode = promocode
        self.total_price = total_price
        self.pharmacy = pharmacy


class OrderItem:
    def __init__(self, id: int, product: Product, quantity: int, order: Order):
        self.id = id
        self.product = product
        self.quantity = quantity
        self.order = order


class Review:
    def __init__(self, id: int, client: Client, rating: int, text: str | None, date: datetime):
        self.id = id
        self.client = client
        self.rating = rating
        self.text = text
        self.date = date


class Cart:
    def __init__(self, client: Client, total_price: Decimal):
        self.client = client
        self.total_price = total_price


class CartItem:
    def __init__(self, id: int, product: Product, quantity: int, cart: Cart):
        self.id = id
        self.product = product
        self.quantity = quantity
        self.cart = cart


class Role:
    def __init__(self, id: int, name: str, description: str | None):
        self.id = id
        self.name = name
        self.description = description


class Employee:
    def __init__(self, id: int, role: Role, first_name: str, last_name: str, phone: str, email: str,
                 password: str):
        self.id = id
        self.role = role
        self.first_name = first_name
        self.last_name = last_name
        self.phone = phone
        self.email = email
        self.password = password

    def to_auth_dict(self):
        return {
            "id": self.id,
            "role": self.role.name,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "phone": self.phone,
            "email": self.email
        }


class Action:
    def __init__(self, id: int, name: str, description: str, table_name: str):
        self.id = id
        self.name = name
        self.description = description
        self.table_name = table_name


class Logs:
    def __init__(self, id: int, employee: Employee, action: Action, action_date: datetime):
        self.id = id
        self.employee = employee
        self.action = action
        self.action_date = action_date
