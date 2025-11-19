# Landing Zone Portal - Quick Start Guide

Get the Landing Zone Portal running in 5 minutes using Docker Compose.

## Prerequisites

- Docker and Docker Compose installed
- 8GB RAM minimum
- Ports 3000, 8000, 5432, 6379 available

## Quick Start

### 1. Start all services

From the `portal` directory:

```bash
docker-compose -f docker-compose.full.yml up -d
```

This will start:
- PostgreSQL database (port 5432)
- Redis cache (port 6379)
- FastAPI backend (port 8000)
- React frontend (port 3000)

### 2. Wait for services to be ready

```bash
docker-compose -f docker-compose.full.yml ps
```

All services should show as "healthy" or "running".

### 3. Initialize database

```bash
docker-compose -f docker-compose.full.yml exec backend python -m app.db.init_db
```

This creates the database schema and seed data with demo users.

### 4. Access the portal

Open your browser to: **http://localhost:3000**

## Demo Accounts

Login with one of these accounts:

| Role | Email | Password | Permissions |
|------|-------|----------|-------------|
| Admin | admin@example.com | admin123 | Full access |
| Approver | approver@example.com | approver123 | Approve landing zones |
| User | user@example.com | user123 | Create landing zones |

## What's Next?

1. **Create your first landing zone:**
   - Click "Create Landing Zone"
   - Fill in the wizard
   - Submit for approval

2. **Approve as approver:**
   - Logout and login as approver
   - Go to "Approvals"
   - Approve the request

3. **View deployment:**
   - Check the landing zone status
   - View deployment details

## Configuration

Edit `backend/.env` to configure:
- Deployment platform (Spacelift or GitHub Actions)
- Azure credentials
- API keys

## Logs

View logs:

```bash
# All services
docker-compose -f docker-compose.full.yml logs -f

# Backend only
docker-compose -f docker-compose.full.yml logs -f backend

# Frontend only
docker-compose -f docker-compose.full.yml logs -f frontend
```

## Stop Services

```bash
docker-compose -f docker-compose.full.yml down
```

To remove volumes (database data):

```bash
docker-compose -f docker-compose.full.yml down -v
```

## Troubleshooting

**Build errors or "unable to get image" error:**
If you get build errors, try building explicitly first:
```bash
docker-compose -f docker-compose.full.yml build
docker-compose -f docker-compose.full.yml up -d
```

**Backend won't start:**
- Check PostgreSQL is healthy: `docker-compose -f docker-compose.full.yml ps postgres`
- View logs: `docker-compose -f docker-compose.full.yml logs backend`
- Ensure ports 8000, 5432, 6379 are not in use

**Frontend shows connection error:**
- Ensure backend is running: `curl http://localhost:8000/health`
- Check backend logs for errors
- Verify CORS configuration allows localhost:3000

**Database connection error:**
- Wait for PostgreSQL to be fully ready (30 seconds)
- Check if database is accessible: `docker-compose -f docker-compose.full.yml exec postgres psql -U postgres -c '\l'`
- Restart backend: `docker-compose -f docker-compose.full.yml restart backend`

**Port conflicts:**
If ports are already in use, modify the port mappings in docker-compose.full.yml:
```yaml
ports:
  - "3001:80"  # Change 3000 to 3001
  - "8001:8000"  # Change 8000 to 8001
```

**Complete reset:**
If something goes wrong, reset everything:
```bash
docker-compose -f docker-compose.full.yml down -v
docker-compose -f docker-compose.full.yml build --no-cache
docker-compose -f docker-compose.full.yml up -d
docker-compose -f docker-compose.full.yml exec backend python -m app.db.init_db
```

## Production Deployment

See:
- [Kubernetes Deployment](./k8s/README.md)
- [Full Documentation](./README.md)
