# Landing Zone Self-Service Portal

A web-based self-service portal for application teams to request and manage Azure Landing Zones without deep infrastructure knowledge.

## Overview

The portal provides a user-friendly interface for:
- **Requesting new landing zones** (spokes)
- **Viewing existing infrastructure**
- **Monitoring deployment status**
- **Managing costs and budgets**
- **Approving requests** (for platform teams)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Users (App Teams)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   Web Frontend (React)                       │
│  - Landing Zone Request Form                                 │
│  - Dashboard & Status                                        │
│  - Cost Visualization                                        │
│  - Approval Workflow                                         │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS/REST API
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                 API Backend (FastAPI)                        │
│  - Request Processing                                        │
│  - Workflow Engine                                           │
│  - Integration Layer                                         │
│  - Authentication/Authorization                              │
└────────┬───────────────┬───────────────┬────────────────────┘
         │               │               │
         ▼               ▼               ▼
┌────────────────┐ ┌──────────┐ ┌──────────────────┐
│   PostgreSQL   │ │ Spacelift│ │  GitHub Actions  │
│   (Requests)   │ │    API   │ │       API        │
└────────────────┘ └──────────┘ └──────────────────┘
```

## Features

### For Application Teams

1. **Landing Zone Request Wizard**
   - Simple form-based interface
   - Pre-configured templates
   - Cost estimation before submission
   - Real-time validation

2. **Dashboard**
   - View all your landing zones
   - Deployment status
   - Resource inventory
   - Cost tracking

3. **Self-Service Operations**
   - Scale resources
   - Request changes
   - View logs
   - Download configurations

### For Platform Teams

1. **Approval Workflow**
   - Review and approve requests
   - Add comments/requirements
   - Set budgets and limits
   - Bulk operations

2. **Admin Dashboard**
   - System-wide view
   - Capacity planning
   - Cost analytics
   - Audit logs

3. **Policy Management**
   - Configure approval rules
   - Set budget thresholds
   - Define templates
   - Manage quotas

## Technology Stack

### Frontend
- **Framework**: React 18 with TypeScript
- **UI Library**: Material-UI (MUI) v5
- **State Management**: Redux Toolkit
- **API Client**: Axios
- **Charts**: Recharts
- **Forms**: React Hook Form + Yup validation

### Backend
- **Framework**: FastAPI (Python 3.11+)
- **ORM**: SQLAlchemy 2.0
- **Authentication**: Azure AD OAuth2 / GitHub OAuth
- **Task Queue**: Celery with Redis
- **API Docs**: OpenAPI/Swagger (auto-generated)

### Database
- **Primary**: PostgreSQL 15
- **Cache**: Redis 7
- **Migrations**: Alembic

### Infrastructure
- **Container**: Docker
- **Orchestration**: Kubernetes
- **Ingress**: NGINX Ingress Controller
- **TLS**: cert-manager + Let's Encrypt
- **Monitoring**: Prometheus + Grafana

## Quick Start

### Prerequisites

```bash
# Required
- Docker & Docker Compose
- Node.js 18+
- Python 3.11+
- PostgreSQL 15+

# For development
- npm or yarn
- Python virtualenv
```

### Local Development

```bash
# Clone and navigate
cd portal

# Start all services with Docker Compose
docker-compose up -d

# Access the portal
http://localhost:3000

# API documentation
http://localhost:8000/docs
```

### Configuration

Create `.env` file:

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/lzportal

# Authentication
AZURE_AD_CLIENT_ID=your-client-id
AZURE_AD_TENANT_ID=your-tenant-id
AZURE_AD_CLIENT_SECRET=your-secret

# Platform Integration (choose one or both)
SPACELIFT_API_ENDPOINT=https://your-account.app.spacelift.io
SPACELIFT_API_KEY_ID=your-key-id
SPACELIFT_API_KEY_SECRET=your-key-secret

GITHUB_TOKEN=ghp_your_token
GITHUB_ORG=your-org
GITHUB_REPO=spacelift-azurerm-alz

# Azure
AZURE_SUBSCRIPTION_ID=your-sub-id
AZURE_TENANT_ID=your-tenant-id

# Email notifications
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email
SMTP_PASSWORD=your-password

# Cost Management
ENABLE_COST_TRACKING=true
COST_API_ENDPOINT=https://management.azure.com
```

## User Workflows

### 1. Request New Landing Zone (App Team)

```
1. Login → Dashboard
2. Click "Request New Landing Zone"
3. Fill wizard:
   - Basic Info (name, purpose, environment)
   - Network (region, address space)
   - Resources (compute, storage needs)
   - Budget (monthly limit)
4. Review summary
5. Submit request
6. Track approval status
7. Receive notification when deployed
```

### 2. Approve Request (Platform Team)

```
1. Login → Approvals Dashboard
2. See pending requests
3. Review details:
   - Resource requirements
   - Cost estimate
   - Network design
4. Add comments/conditions
5. Approve or reject
6. Monitor deployment
```

### 3. View Landing Zone Status

```
1. Login → My Landing Zones
2. Select landing zone
3. View:
   - Deployment status
   - Resources created
   - Network diagram
   - Cost breakdown
   - Recent changes
```

## API Endpoints

### Landing Zones

```
GET    /api/v1/landing-zones              # List all
POST   /api/v1/landing-zones              # Create request
GET    /api/v1/landing-zones/{id}         # Get details
PATCH  /api/v1/landing-zones/{id}         # Update
DELETE /api/v1/landing-zones/{id}         # Delete request

GET    /api/v1/landing-zones/{id}/status  # Deployment status
GET    /api/v1/landing-zones/{id}/cost    # Cost breakdown
GET    /api/v1/landing-zones/{id}/logs    # Deployment logs
```

### Approvals

```
GET    /api/v1/approvals                  # List pending
POST   /api/v1/approvals/{id}/approve     # Approve
POST   /api/v1/approvals/{id}/reject      # Reject
POST   /api/v1/approvals/{id}/comment     # Add comment
```

### Templates

```
GET    /api/v1/templates                  # List templates
GET    /api/v1/templates/{id}             # Get template
POST   /api/v1/templates                  # Create template (admin)
```

### Cost Management

```
GET    /api/v1/costs/summary              # Overall costs
GET    /api/v1/costs/by-landing-zone      # Cost per LZ
GET    /api/v1/costs/forecast             # Cost forecast
GET    /api/v1/costs/budget-alerts        # Budget alerts
```

## Request Workflow

```mermaid
stateDiagram-v2
    [*] --> Draft: User creates request
    Draft --> Submitted: User submits
    Submitted --> UnderReview: Auto-assigned to approver
    UnderReview --> ChangesRequested: Approver requests changes
    ChangesRequested --> Submitted: User updates request
    UnderReview --> Approved: Approver approves
    UnderReview --> Rejected: Approver rejects
    Approved --> Deploying: Trigger deployment
    Deploying --> Deployed: Deployment succeeds
    Deploying --> Failed: Deployment fails
    Failed --> Deploying: Retry deployment
    Deployed --> [*]
    Rejected --> [*]
```

## Security

### Authentication
- Azure AD OAuth2 for enterprise users
- GitHub OAuth for open-source/smaller teams
- JWT tokens for API access
- Multi-factor authentication support

### Authorization
- Role-Based Access Control (RBAC)
- Roles: User, Approver, Admin
- Row-level security in database
- API rate limiting

### Data Protection
- All data encrypted at rest
- TLS 1.3 for data in transit
- Secrets in Azure Key Vault / HashiCorp Vault
- Audit logging for all operations

## Monitoring & Observability

### Metrics
- Request processing time
- Deployment success rate
- API response times
- Cost per landing zone
- User activity

### Logging
- Structured JSON logs
- Centralized log aggregation
- Request tracing with correlation IDs
- Audit trail for all changes

### Alerts
- Deployment failures
- Budget exceeded
- Approval delays (SLA)
- System health issues

## Deployment

### Kubernetes

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/secrets.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/postgres.yml
kubectl apply -f k8s/redis.yml
kubectl apply -f k8s/backend.yml
kubectl apply -f k8s/frontend.yml
kubectl apply -f k8s/ingress.yml
```

### Docker Compose

```bash
# For development/testing
docker-compose up -d

# Scale workers
docker-compose up -d --scale worker=3
```

### Azure Container Apps

```bash
# Deploy to Azure Container Apps
az containerapp up \
  --name landing-zone-portal \
  --resource-group rg-portal \
  --location eastus \
  --environment portal-env \
  --image ghcr.io/your-org/lz-portal:latest
```

## Integration Guides

### Spacelift Integration

The portal integrates with Spacelift to:
- Create stacks automatically
- Monitor deployment status
- Retrieve outputs
- Trigger runs
- Attach policies

See [Spacelift Integration Guide](./docs/spacelift-integration.md)

### GitHub Actions Integration

The portal integrates with GitHub Actions to:
- Trigger workflow runs
- Monitor workflow status
- Retrieve artifacts
- Manage secrets
- Check approval status

See [GitHub Actions Integration Guide](./docs/github-actions-integration.md)

## Development

### Backend Development

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows

# Install dependencies
pip install -r requirements.txt

# Run database migrations
alembic upgrade head

# Start development server
uvicorn app.main:app --reload --port 8000
```

### Frontend Development

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build
```

### Running Tests

```bash
# Backend tests
cd backend
pytest tests/ -v --cov=app

# Frontend tests
cd frontend
npm test

# E2E tests
npm run test:e2e
```

## Roadmap

### Phase 1 (MVP) ✅
- Landing zone request form
- Basic approval workflow
- Spacelift/GitHub Actions integration
- Simple dashboard

### Phase 2 (Current)
- Cost tracking and visualization
- Advanced approval rules
- Email notifications
- Audit logging

### Phase 3 (Planned)
- Self-service resource scaling
- Cost optimization recommendations
- Terraform drift detection UI
- Slack/Teams integration

### Phase 4 (Future)
- Multi-cloud support (AWS, GCP)
- Advanced analytics
- AI-powered recommendations
- Mobile app

## Screenshots

See [screenshots/](./screenshots/) for UI examples.

## Documentation

- [User Guide](./docs/user-guide.md)
- [Admin Guide](./docs/admin-guide.md)
- [API Reference](./docs/api-reference.md)
- [Development Guide](./docs/development.md)
- [Deployment Guide](./docs/deployment.md)

## Support

- **Issues**: https://github.com/your-org/lz-portal/issues
- **Discussions**: https://github.com/your-org/lz-portal/discussions
- **Email**: platform-team@your-org.com

## License

MIT License - see [LICENSE](../LICENSE) for details.
