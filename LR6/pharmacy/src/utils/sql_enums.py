from enum import Enum


class RoleEnum(str, Enum):
    ADMIN = 'admin'
    EMPLOYEE = 'employee'


class CientRoleEnum(str, Enum):
    CLIENT = 'client'


class StatusEnum(str, Enum):
    PENDING = 'pending'
    COMPLETED = 'completed'
    SHIPPED = 'shipped'
    RECEIVED = 'received'
