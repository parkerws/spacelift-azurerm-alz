"""Templates API Endpoints"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List, Dict, Any

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import User

router = APIRouter()


@router.get("")
async def list_templates(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> List[Dict[str, Any]]:
    """
    List available landing zone templates.

    Templates define pre-configured landing zone architectures.
    """
    # For now, return hardcoded templates
    # In production, these would be stored in database
    templates = [
        {
            "id": "corp-basic",
            "name": "Corporate Basic",
            "description": "Basic corporate landing zone with hub connectivity",
            "landing_zone_type": "corp",
            "features": [
                "VNet with RFC 1918 address space",
                "Connectivity to hub",
                "Network security groups",
                "Route tables with firewall UDR",
            ],
            "estimated_monthly_cost": 150.00,
            "deployment_time_minutes": 15,
        },
        {
            "id": "corp-advanced",
            "name": "Corporate Advanced",
            "description": "Advanced corporate landing zone with additional security",
            "landing_zone_type": "corp",
            "features": [
                "VNet with RFC 1918 address space",
                "Connectivity to hub",
                "Network security groups",
                "Route tables with firewall UDR",
                "Private endpoints",
                "Azure Bastion subnet",
            ],
            "estimated_monthly_cost": 450.00,
            "deployment_time_minutes": 25,
        },
        {
            "id": "online-basic",
            "name": "Online Basic",
            "description": "Basic online landing zone for internet-facing apps",
            "landing_zone_type": "online",
            "features": [
                "VNet with public IP support",
                "Application Gateway subnet",
                "Connectivity to hub",
                "Network security groups",
            ],
            "estimated_monthly_cost": 200.00,
            "deployment_time_minutes": 20,
        },
        {
            "id": "online-advanced",
            "name": "Online Advanced",
            "description": "Advanced online landing zone with WAF and CDN",
            "landing_zone_type": "online",
            "features": [
                "VNet with public IP support",
                "Application Gateway with WAF",
                "Azure Front Door integration",
                "Connectivity to hub",
                "Network security groups",
                "DDoS protection",
            ],
            "estimated_monthly_cost": 800.00,
            "deployment_time_minutes": 30,
        },
        {
            "id": "sap-basic",
            "name": "SAP Basic",
            "description": "Basic SAP landing zone",
            "landing_zone_type": "sap",
            "features": [
                "VNet optimized for SAP workloads",
                "Accelerated networking",
                "Connectivity to hub",
                "Network security groups",
                "Proximity placement groups",
            ],
            "estimated_monthly_cost": 300.00,
            "deployment_time_minutes": 25,
        },
    ]

    return templates


@router.get("/{template_id}")
async def get_template(
    template_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """Get template details"""
    templates = await list_templates(db, current_user)

    template = next((t for t in templates if t["id"] == template_id), None)

    if not template:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Template not found")

    # Add detailed configuration
    template["configuration"] = {
        "subnets": {
            "default": {
                "address_prefix": "10.x.0.0/24",
                "description": "Default subnet for workloads",
            },
            "data": {
                "address_prefix": "10.x.1.0/24",
                "description": "Subnet for database and data services",
            },
        },
        "nsg_rules": [
            {
                "name": "Allow-HTTPS",
                "priority": 100,
                "direction": "Inbound",
                "access": "Allow",
                "protocol": "Tcp",
                "source_port_range": "*",
                "destination_port_range": "443",
            }
        ],
    }

    return template
