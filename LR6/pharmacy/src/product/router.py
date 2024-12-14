from fastapi import APIRouter, Security
from src.auth.auth import role_required

from src.product.service import ProductService, ProductTypeService
from fastapi import HTTPException, status, Depends, Request
from src.auth.auth import get_password_hash
from src.product.schemas import (SProductInfo, SProductCreate, SPurchaseInfo,
                                 SStockInfo, SProductType, SStatistics, SPriceFilter)

product_router = APIRouter(prefix="/products", tags=["Manage products"])


@product_router.get("/all/", response_model=list[SProductInfo], description="Get all products")
async def get_all_products() -> list[SProductInfo]:
    products = await ProductService.get_products()
    if not products:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Products not found"
        )
    return [SProductInfo.model_validate(product.to_dict()) for product in products]


@product_router.get("/{product_id}", response_model=SProductInfo, description="Get product by id")
async def get_product_by_id(product_id: int) -> SProductInfo:
    product = await ProductService.get_product_by_id(product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return SProductInfo.model_validate(product.to_dict())


@product_router.post("/create/", response_model=SProductInfo, description="Create new product")
async def create_product(product_data: SProductCreate = Depends(),
                         security_scopes=Security(role_required, scopes=["admin"])
                         ) -> SProductInfo:
    product = await ProductService.add_product(product_data.dict())
    if not product:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error creating product",
        )
    return SProductInfo.model_validate(product.to_dict())


@product_router.put("/update/{product_id}", description="Update product", response_model=None)
async def update_product(product_id: int, product: SProductCreate = Depends(),
                         security_scopes=Security(role_required, scopes=["admin"])
                         ) -> SProductInfo:
    updated_product = await ProductService.update_product_by_id(product_id, product.dict())
    if not updated_product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found",
        )
    return SProductInfo.model_validate(updated_product.to_dict())


@product_router.delete("/delete/{product_id}", response_model=SProductInfo, description="Delete product by id")
async def delete_product(product_id: int, security_scopes=Security(role_required, scopes=["admin"])
                         ) -> SProductInfo:
    deleted_product = await ProductService.delete_product_by_id(product_id)
    if not deleted_product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found",
        )
    return SProductInfo.model_validate(deleted_product.to_dict())


@product_router.get("/products/purchases", response_model=list[SPurchaseInfo],
                    description="Get info about products purchases")
async def get_products_purchases(security_scopes=Security(role_required, scopes=["admin"])) -> list[SPurchaseInfo]:
    products = await ProductService.get_purchase_info()
    if not products:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Products not found"
        )
    return [SPurchaseInfo.model_validate(product) for product in products]


@product_router.get("/products/purchases/{product_id}", response_model=list[SPurchaseInfo],
                    description="Get info about products purchases")
async def get_products_purchases(product_id: int,
                                 security_scopes=Security(role_required, scopes=["admin"])) -> list[SPurchaseInfo]:
    products = await ProductService.get_purchase_info(product_id=product_id)
    if not products:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Products not found"
        )
    return [SPurchaseInfo.model_validate(product) for product in products]


@product_router.get("/products/stock/{product_name}", response_model=list[SStockInfo],
                    description="Get stock info")
async def get_stock_info(product_name: str):
    infos = await ProductService.get_stock_info(product_name=product_name.strip())
    if not infos:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return [SStockInfo.model_validate(info) for info in infos]


@product_router.get("/products/stock", response_model=list[SStockInfo],
                    description="Get stock info")
async def get_stock_info(price_filter: SPriceFilter = Depends()):
    infos = await ProductService.get_all_stock_info(price_filter=price_filter.dict())
    if not infos:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return [SStockInfo.model_validate(info) for info in infos]


@product_router.get("/products/product_types", response_model=list[SProductType],
                    description="Get all product types")
async def get_all_product_types() -> list[SProductType]:
    product_types = await ProductTypeService.get_all_product_types()
    if not product_types:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product types not found"
        )
    return [SProductType.model_validate(product_type.to_dict()) for product_type in product_types]


@product_router.get("/products/statistics", response_model=list[SStatistics],
                    description="Get statistics")
async def get_statistics(security_scopes=Security(role_required, scopes=["employee"])) -> list[SStatistics]:
    statistics = await ProductService.get_statistics()
    if not statistics:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Statistics not found"
        )
    return statistics
