# Project 2: Deploy a 3-Tier Voting App on Amazon EKS (Phase 1)

## Overview

This project deploys a complete microservices-based Voting Application onto an Amazon EKS cluster using Kubernetes and GitHub Actions CI/CD.

### Phase 1 Infrastructure:

* Amazon EKS
* Kubernetes Deployments & Services
* NGINX Ingress Controller
* AWS Elastic Load Balancer (ELB)
* Docker Hub image registry
* GitHub Actions automation

The goal is to create a production-like deployment pipeline for a scalable cloud-native application.

---

# Application Components

## Frontend

### Vote App

* Python Flask application
* Accepts user votes
* Sends votes to Redis queue

### Result App

* Node.js application
* Displays live vote results
* Reads processed vote data from PostgreSQL

---

## Backend

### Worker

* .NET background processor
* Consumes votes from Redis
* Persists votes into PostgreSQL

### Redis

* High-speed in-memory message queue

### PostgreSQL

* Persistent relational database

---

# System Architecture

```txt
User → AWS ELB → NGINX Ingress Controller → Vote / Result Services
Vote → Redis
Worker → Redis
Worker → PostgreSQL
Result → PostgreSQL
```

---

# Technologies Used

* Amazon EKS
* Kubernetes
* Docker
* Docker Hub
* GitHub Actions
* Helm
* NGINX Ingress Controller
* Python / Flask
* Node.js
* .NET
* Redis
* PostgreSQL

---

# EKS Cluster Details

**Cluster Name:** `spot-eks-lab-lananh`
**AWS Region:** `us-east-1`

---

# Deployment Process

## 1. Build and Push Docker Images

Each microservice is containerized and pushed to Docker Hub:

* Vote
* Result
* Worker

Images are versioned for CI/CD using commit SHA tags.

---

## 2. Deploy Kubernetes Resources

Kubernetes manifests are used to deploy:

* Namespace
* Secrets
* Redis
* PostgreSQL
* Vote service
* Result service
* Worker service
* Ingress configuration

---

## 3. Install NGINX Ingress Controller

Helm is used to install NGINX Ingress Controller, which provisions an AWS LoadBalancer for external traffic.

---

## 4. Configure DNS Routing

Subdomain-based routing is used for cleaner production architecture:

* `vote.la.ironlabs.online`
* `result.la.ironlabs.online`

This avoids path-rewrite issues and simplifies frontend static asset delivery.

---

# Access URLs

### Vote Application:

`http://vote.la.ironlabs.online`

### Result Application:

`http://result.la.ironlabs.online`

---

# CI/CD Pipeline

GitHub Actions automates deployment on every push to `main`.

## Pipeline Workflow:

1. Checkout source code
2. Authenticate to Docker Hub
3. Build Docker images
4. Push images to Docker Hub
5. Authenticate to AWS
6. Configure Kubernetes access
7. Apply Kubernetes manifests
8. Update deployment images
9. Verify rollout success

---

# Required GitHub Secrets

## Docker Hub:

* `DOCKER_USERNAME`
* `DOCKER_PASSWORD`

## AWS:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

---

# Important Deployment Notes

## Kubernetes DNS

Microservices communicate using Kubernetes internal DNS:

* Redis: `redis.default.svc.cluster.local`
* PostgreSQL: `db.default.svc.cluster.local`

---

## Vote App Fixes

* Explicit Redis hostname
* Explicit Redis port override
* Fixed service environment conflicts

---

## Result App Fixes

* Correct Node.js application port
* Correct Kubernetes targetPort mapping
* Ingress host routing

---

## NGINX Fixes

* Removed stale webhooks
* Reinstalled ingress cleanly
* Configured proper DNS host routing

---

# Validation Commands

## Check pods:

```bash
kubectl get pods
```

## Check services:

```bash
kubectl get svc
```

## Check ingress:

```bash
kubectl get ingress
```

## Check rollout:

```bash
kubectl rollout status deployment/vote
kubectl rollout status deployment/result
kubectl rollout status deployment/worker
```

---

# Troubleshooting

## View pod logs:

```bash
kubectl logs <pod-name>
```

## Test DNS:

```bash
kubectl exec -it <pod-name> -- nslookup redis.default.svc.cluster.local
```

## Verify ingress controller:

```bash
kubectl get svc -n ingress-nginx
```

---

# Security

## Current:

* Kubernetes Secrets
* Dedicated IAM user for GitHub Actions

## Planned Upgrades:

* GitHub OIDC
* AWS ALB Controller
* ACM HTTPS certificates
* Route53 automation
* cert-manager

---

# Phase 2 Roadmap

Planned upgrade from NGINX to AWS ALB:

## Benefits:

* Native AWS Application Load Balancer
* HTTPS with ACM
* Route53 integration
* Better scaling
* AWS WAF support
* More production-grade architecture

---

# Lessons Learned

* Kubernetes service discovery is critical
* DNS configuration can break microservices
* Immutable image tags are best practice
* NGINX simplifies early deployment
* ALB is preferable for advanced production
* GitHub Actions requires both IAM and Kubernetes RBAC permissions
* Subdomain routing is cleaner than path-based routing

---

# Final Success Criteria

This phase is complete when:

* All pods are healthy
* Vote frontend works
* Result frontend works
* Redis processes votes
* Worker writes to PostgreSQL
* Results update correctly
* GitHub Actions deploys automatically
* External traffic routes through NGINX successfully

---

# Author

**Tran Lan Anh**
DevOps / Cloud Engineering Project
Amazon EKS + Kubernetes + GitHub Actions
