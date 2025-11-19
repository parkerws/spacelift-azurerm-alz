"""API v1 Router"""

from fastapi import APIRouter

from app.api.v1.endpoints import (
    landing_zones,
    approvals,
    templates,
    costs,
    deployments,
    auth,
)

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(
    landing_zones.router, prefix="/landing-zones", tags=["Landing Zones"]
)
api_router.include_router(approvals.router, prefix="/approvals", tags=["Approvals"])
api_router.include_router(templates.router, prefix="/templates", tags=["Templates"])
api_router.include_router(costs.router, prefix="/costs", tags=["Cost Management"])
api_router.include_router(
    deployments.router, prefix="/deployments", tags=["Deployments"]
)
