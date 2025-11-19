"""Cost Management API Endpoints"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import User
from app.models.landing_zone import LandingZone
from app.services.landing_zone_service import LandingZoneService

router = APIRouter()


@router.get("/landing-zones/{landing_zone_id}")
async def get_landing_zone_costs(
    landing_zone_id: int,
    start_date: Optional[str] = Query(None, description="Start date (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="End date (YYYY-MM-DD)"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    Get cost information for a landing zone.

    Returns current month costs and historical data if requested.
    """
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if (current_user.role not in ["admin", "approver"] and
        landing_zone.created_by_id != current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")

    # In production, would fetch from Azure Cost Management API
    # For now, return mock data
    current_cost = landing_zone.current_monthly_cost or 0.0
    budget = landing_zone.monthly_budget or 0.0

    budget_usage_percentage = 0
    if budget > 0:
        budget_usage_percentage = (current_cost / budget) * 100

    response = {
        "landing_zone_id": landing_zone_id,
        "landing_zone_name": landing_zone.name,
        "current_month": {
            "cost": current_cost,
            "currency": "USD",
            "budget": budget,
            "budget_usage_percentage": round(budget_usage_percentage, 2),
            "is_over_budget": current_cost > budget if budget > 0 else False,
        },
        "cost_by_service": [
            {"service": "Virtual Network", "cost": current_cost * 0.1},
            {"service": "Network Security Groups", "cost": current_cost * 0.05},
            {"service": "Route Tables", "cost": current_cost * 0.05},
            {"service": "Compute", "cost": current_cost * 0.5},
            {"service": "Storage", "cost": current_cost * 0.2},
            {"service": "Other", "cost": current_cost * 0.1},
        ],
        "daily_costs": [],
    }

    # Generate daily costs for last 30 days
    if start_date and end_date:
        try:
            start = datetime.strptime(start_date, "%Y-%m-%d")
            end = datetime.strptime(end_date, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format")
    else:
        end = datetime.now()
        start = end - timedelta(days=30)

    daily_costs = []
    current = start
    daily_cost = current_cost / 30  # Simple distribution

    while current <= end:
        daily_costs.append({
            "date": current.strftime("%Y-%m-%d"),
            "cost": round(daily_cost, 2),
        })
        current += timedelta(days=1)

    response["daily_costs"] = daily_costs

    return response


@router.get("/summary")
async def get_cost_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    Get cost summary across all landing zones.

    - Regular users see only their landing zones
    - Approvers and admins see all landing zones
    """
    service = LandingZoneService(db)

    filters = {}
    if current_user.role not in ["admin", "approver"]:
        filters["created_by_id"] = current_user.id

    landing_zones = service.list(skip=0, limit=1000, filters=filters)

    total_cost = sum(lz.current_monthly_cost or 0.0 for lz in landing_zones)
    total_budget = sum(lz.monthly_budget or 0.0 for lz in landing_zones)

    over_budget_count = sum(
        1 for lz in landing_zones
        if lz.monthly_budget and lz.current_monthly_cost > lz.monthly_budget
    )

    return {
        "total_landing_zones": len(landing_zones),
        "total_monthly_cost": round(total_cost, 2),
        "total_budget": round(total_budget, 2),
        "over_budget_count": over_budget_count,
        "currency": "USD",
        "landing_zones": [
            {
                "id": lz.id,
                "name": lz.name,
                "cost": lz.current_monthly_cost or 0.0,
                "budget": lz.monthly_budget or 0.0,
                "is_over_budget": (
                    lz.current_monthly_cost > lz.monthly_budget
                    if lz.monthly_budget and lz.current_monthly_cost
                    else False
                ),
            }
            for lz in landing_zones
        ],
    }


@router.get("/forecast")
async def get_cost_forecast(
    days: int = Query(30, ge=1, le=90, description="Days to forecast"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    Get cost forecast for user's landing zones.

    Simple linear projection based on current spending.
    """
    service = LandingZoneService(db)

    filters = {}
    if current_user.role not in ["admin", "approver"]:
        filters["created_by_id"] = current_user.id

    landing_zones = service.list(skip=0, limit=1000, filters=filters)

    total_current_cost = sum(lz.current_monthly_cost or 0.0 for lz in landing_zones)

    # Simple daily rate calculation
    daily_rate = total_current_cost / 30

    # Forecast
    forecast_data = []
    for day in range(1, days + 1):
        date = datetime.now() + timedelta(days=day)
        projected_cost = daily_rate * day

        forecast_data.append({
            "date": date.strftime("%Y-%m-%d"),
            "projected_cost": round(projected_cost, 2),
        })

    projected_total = daily_rate * days

    return {
        "forecast_days": days,
        "current_daily_rate": round(daily_rate, 2),
        "projected_total": round(projected_total, 2),
        "currency": "USD",
        "daily_forecast": forecast_data,
    }
