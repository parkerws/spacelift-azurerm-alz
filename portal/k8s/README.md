# Kubernetes Deployment

This directory contains Kubernetes manifests for deploying the Landing Zone Portal.

## Prerequisites

- Kubernetes cluster (AKS, EKS, GKE, or self-managed)
- kubectl configured
- Container images built and pushed to registry

## Deployment Steps

### 1. Create Namespace

```bash
kubectl apply -f namespace.yaml
```

### 2. Deploy Database and Cache

```bash
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
```

Wait for PostgreSQL and Redis to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=postgres -n landing-zone-portal --timeout=300s
kubectl wait --for=condition=ready pod -l app=redis -n landing-zone-portal --timeout=300s
```

### 3. Update Secrets

Edit `backend.yaml` and update the secrets:

```yaml
stringData:
  SECRET_KEY: "your-secure-random-secret-key"
  SPACELIFT_API_KEY_SECRET: "your-spacelift-api-key"
  GITHUB_TOKEN: "your-github-token"
  AZURE_CLIENT_SECRET: "your-azure-client-secret"
```

Or use kubectl to create secrets directly:

```bash
kubectl create secret generic backend-secret \
  --from-literal=SECRET_KEY="your-secret-key" \
  --from-literal=SPACELIFT_API_KEY_SECRET="your-spacelift-key" \
  -n landing-zone-portal
```

### 4. Deploy Backend

```bash
kubectl apply -f backend.yaml
```

### 5. Initialize Database

Run database migrations:

```bash
kubectl exec -it deployment/backend -n landing-zone-portal -- python -m app.db.init_db
```

### 6. Deploy Frontend

```bash
kubectl apply -f frontend.yaml
```

### 7. Configure Ingress (Optional)

If using ingress controller:

1. Update `ingress.yaml` with your domain
2. Apply ingress:

```bash
kubectl apply -f ingress.yaml
```

## Verification

Check all pods are running:

```bash
kubectl get pods -n landing-zone-portal
```

Check services:

```bash
kubectl get svc -n landing-zone-portal
```

Get frontend URL:

```bash
kubectl get svc frontend -n landing-zone-portal -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Scaling

Scale backend:

```bash
kubectl scale deployment backend --replicas=3 -n landing-zone-portal
```

Scale frontend:

```bash
kubectl scale deployment frontend --replicas=3 -n landing-zone-portal
```

## Monitoring

View logs:

```bash
# Backend logs
kubectl logs -f deployment/backend -n landing-zone-portal

# Frontend logs
kubectl logs -f deployment/frontend -n landing-zone-portal
```

## Updating

Update deployment images:

```bash
kubectl set image deployment/backend backend=your-registry/backend:new-tag -n landing-zone-portal
kubectl set image deployment/frontend frontend=your-registry/frontend:new-tag -n landing-zone-portal
```

## Cleanup

Remove all resources:

```bash
kubectl delete namespace landing-zone-portal
```
