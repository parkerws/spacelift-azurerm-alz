"""Deployment Service - Integration with Spacelift and GitHub Actions"""

from typing import Optional, Dict, Any, List
from sqlalchemy.orm import Session
import logging
import httpx
from datetime import datetime

from app.core.config import settings
from app.models.landing_zone import LandingZone, LandingZoneStatus
from app.schemas.landing_zone import LandingZoneStatusResponse

logger = logging.getLogger(__name__)


class DeploymentService:
    """Service for deployment operations"""

    def __init__(self, db: Session):
        self.db = db

    async def trigger_deployment(self, landing_zone: LandingZone) -> Dict[str, Any]:
        """
        Trigger deployment based on configured platform.

        Returns deployment information including ID and URL.
        """
        if settings.DEPLOYMENT_PLATFORM == "spacelift":
            return await self._trigger_spacelift_deployment(landing_zone)
        elif settings.DEPLOYMENT_PLATFORM == "github_actions":
            return await self._trigger_github_actions_deployment(landing_zone)
        else:
            raise ValueError(f"Unknown deployment platform: {settings.DEPLOYMENT_PLATFORM}")

    async def _trigger_spacelift_deployment(
        self, landing_zone: LandingZone
    ) -> Dict[str, Any]:
        """Trigger Spacelift stack deployment"""
        logger.info(f"Triggering Spacelift deployment for: {landing_zone.name}")

        # Spacelift GraphQL API endpoint
        url = f"{settings.SPACELIFT_ENDPOINT}/graphql"

        # GraphQL mutation to trigger run
        mutation = """
        mutation TriggerRun($stack: ID!) {
          runTrigger(stack: $stack) {
            id
            state
          }
        }
        """

        variables = {
            "stack": f"landing-zone-{landing_zone.name}",
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    url,
                    json={"query": mutation, "variables": variables},
                    headers={
                        "Authorization": f"Bearer {settings.SPACELIFT_API_KEY_SECRET}",
                        "Content-Type": "application/json",
                    },
                    timeout=30.0,
                )
                response.raise_for_status()
                data = response.json()

                if "errors" in data:
                    raise Exception(f"Spacelift API error: {data['errors']}")

                run_id = data["data"]["runTrigger"]["id"]
                run_url = f"{settings.SPACELIFT_ENDPOINT}/stack/{landing_zone.name}/run/{run_id}"

                logger.info(f"Spacelift run triggered: {run_id}")

                return {
                    "deployment_id": run_id,
                    "deployment_url": run_url,
                    "deployment_platform": "spacelift",
                }

        except Exception as e:
            logger.error(f"Failed to trigger Spacelift deployment: {e}")
            raise

    async def _trigger_github_actions_deployment(
        self, landing_zone: LandingZone
    ) -> Dict[str, Any]:
        """Trigger GitHub Actions workflow"""
        logger.info(f"Triggering GitHub Actions deployment for: {landing_zone.name}")

        # GitHub Actions workflow dispatch endpoint
        url = (
            f"https://api.github.com/repos/{settings.GITHUB_ORGANIZATION}/"
            f"{settings.GITHUB_REPOSITORY}/actions/workflows/"
            f"spoke-deployment.yml/dispatches"
        )

        payload = {
            "ref": "main",
            "inputs": {
                "landing_zone_name": landing_zone.name,
                "environment": landing_zone.environment,
                "action": "apply",
            },
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    url,
                    json=payload,
                    headers={
                        "Authorization": f"token {settings.GITHUB_TOKEN}",
                        "Accept": "application/vnd.github.v3+json",
                    },
                    timeout=30.0,
                )
                response.raise_for_status()

                # Get latest workflow run
                runs_url = (
                    f"https://api.github.com/repos/{settings.GITHUB_ORGANIZATION}/"
                    f"{settings.GITHUB_REPOSITORY}/actions/runs"
                )

                runs_response = await client.get(
                    runs_url,
                    headers={
                        "Authorization": f"token {settings.GITHUB_TOKEN}",
                        "Accept": "application/vnd.github.v3+json",
                    },
                    timeout=30.0,
                )
                runs_response.raise_for_status()
                runs_data = runs_response.json()

                if runs_data["workflow_runs"]:
                    latest_run = runs_data["workflow_runs"][0]
                    run_id = str(latest_run["id"])
                    run_url = latest_run["html_url"]
                else:
                    run_id = "pending"
                    run_url = f"https://github.com/{settings.GITHUB_ORGANIZATION}/{settings.GITHUB_REPOSITORY}/actions"

                logger.info(f"GitHub Actions workflow triggered: {run_id}")

                return {
                    "deployment_id": run_id,
                    "deployment_url": run_url,
                    "deployment_platform": "github_actions",
                }

        except Exception as e:
            logger.error(f"Failed to trigger GitHub Actions deployment: {e}")
            raise

    async def get_deployment_status(
        self, landing_zone: LandingZone
    ) -> LandingZoneStatusResponse:
        """Get deployment status from platform"""
        if not landing_zone.deployment_id:
            return LandingZoneStatusResponse(
                landing_zone_id=landing_zone.id,
                status=landing_zone.status.value,
            )

        if landing_zone.deployment_platform == "spacelift":
            return await self._get_spacelift_status(landing_zone)
        elif landing_zone.deployment_platform == "github_actions":
            return await self._get_github_actions_status(landing_zone)
        else:
            return LandingZoneStatusResponse(
                landing_zone_id=landing_zone.id,
                status=landing_zone.status.value,
                deployment_id=landing_zone.deployment_id,
                deployment_url=landing_zone.deployment_url,
            )

    async def _get_spacelift_status(
        self, landing_zone: LandingZone
    ) -> LandingZoneStatusResponse:
        """Get Spacelift run status"""
        # Simplified status response
        # In production, would query Spacelift GraphQL API
        return LandingZoneStatusResponse(
            landing_zone_id=landing_zone.id,
            status=landing_zone.status.value,
            deployment_id=landing_zone.deployment_id,
            deployment_url=landing_zone.deployment_url,
            started_at=landing_zone.deployed_at,
        )

    async def _get_github_actions_status(
        self, landing_zone: LandingZone
    ) -> LandingZoneStatusResponse:
        """Get GitHub Actions workflow status"""
        try:
            url = (
                f"https://api.github.com/repos/{settings.GITHUB_ORGANIZATION}/"
                f"{settings.GITHUB_REPOSITORY}/actions/runs/{landing_zone.deployment_id}"
            )

            async with httpx.AsyncClient() as client:
                response = await client.get(
                    url,
                    headers={
                        "Authorization": f"token {settings.GITHUB_TOKEN}",
                        "Accept": "application/vnd.github.v3+json",
                    },
                    timeout=30.0,
                )
                response.raise_for_status()
                data = response.json()

                # Map GitHub status to our status
                gh_status = data["status"]
                gh_conclusion = data.get("conclusion")

                if gh_status == "completed":
                    if gh_conclusion == "success":
                        status = "deployed"
                    else:
                        status = "failed"
                elif gh_status == "in_progress":
                    status = "deploying"
                else:
                    status = landing_zone.status.value

                return LandingZoneStatusResponse(
                    landing_zone_id=landing_zone.id,
                    status=status,
                    deployment_id=landing_zone.deployment_id,
                    deployment_url=landing_zone.deployment_url,
                    started_at=landing_zone.deployed_at,
                )

        except Exception as e:
            logger.error(f"Failed to get GitHub Actions status: {e}")
            return LandingZoneStatusResponse(
                landing_zone_id=landing_zone.id,
                status=landing_zone.status.value,
                deployment_id=landing_zone.deployment_id,
                deployment_url=landing_zone.deployment_url,
                error_message=str(e),
            )

    async def get_deployment_logs(self, landing_zone: LandingZone) -> List[str]:
        """Get deployment logs"""
        if not landing_zone.deployment_id:
            return []

        if landing_zone.deployment_platform == "spacelift":
            return await self._get_spacelift_logs(landing_zone)
        elif landing_zone.deployment_platform == "github_actions":
            return await self._get_github_actions_logs(landing_zone)
        else:
            return []

    async def _get_spacelift_logs(self, landing_zone: LandingZone) -> List[str]:
        """Get Spacelift run logs"""
        # Placeholder - would query Spacelift API
        return ["Spacelift logs not yet implemented"]

    async def _get_github_actions_logs(self, landing_zone: LandingZone) -> List[str]:
        """Get GitHub Actions workflow logs"""
        try:
            url = (
                f"https://api.github.com/repos/{settings.GITHUB_ORGANIZATION}/"
                f"{settings.GITHUB_REPOSITORY}/actions/runs/{landing_zone.deployment_id}/logs"
            )

            async with httpx.AsyncClient() as client:
                response = await client.get(
                    url,
                    headers={
                        "Authorization": f"token {settings.GITHUB_TOKEN}",
                        "Accept": "application/vnd.github.v3+json",
                    },
                    timeout=30.0,
                )

                if response.status_code == 200:
                    # Response is a zip file, would need to extract
                    return ["GitHub Actions logs available at: " + landing_zone.deployment_url]
                else:
                    return ["Logs not available yet"]

        except Exception as e:
            logger.error(f"Failed to get GitHub Actions logs: {e}")
            return [f"Error retrieving logs: {str(e)}"]

    async def retry_deployment(self, landing_zone: LandingZone) -> Dict[str, Any]:
        """Retry failed deployment"""
        logger.info(f"Retrying deployment for: {landing_zone.name}")

        # Reset status
        landing_zone.status = LandingZoneStatus.DEPLOYING
        self.db.commit()

        # Trigger new deployment
        return await self.trigger_deployment(landing_zone)
