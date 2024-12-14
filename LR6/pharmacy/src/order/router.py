from fastapi import APIRouter, Security
from src.auth.auth import role_required

from src.product.service import ProductService, ProductTypeService
from fastapi import HTTPException, status, Depends, Request
from src.auth.auth import get_password_hash
from src.product.schemas import SProductInfo, SProductCreate, SPurchaseInfo, SStockInfo, SProductType

order_router = APIRouter(prefix="/order", tags=["Manage orders"])