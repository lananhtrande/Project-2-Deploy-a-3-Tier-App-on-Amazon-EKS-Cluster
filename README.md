# Project 2: Deploy a 3-Tier Voting App on Amazon EKS (Phase 2)
(Phase 1 is on branch feature/here-using-nginx-ingress-controller)
## Overview

This project deploys a production-grade microservices Voting Application onto Amazon EKS using Kubernetes, GitHub Actions CI/CD, AWS Load Balancer Controller (ALB), Route53, and HTTPS with AWS Certificate Manager (ACM).

Phase 2 upgrades the initial NGINX Ingress deployment to a more cloud-native AWS architecture using Application Load Balancer (ALB) for scalable, secure, and production-ready traffic management.

---

# Phase 2 Architecture

## Infrastructure Stack

* Amazon EKS
* Kubernetes Deployments & Services
* AWS Load Balancer Controller (ALB)
* Route53 DNS
* AWS Certificate Manager (ACM)
* HTTPS/TLS termination at ALB
* Docker Hub image registry
* GitHub Actions CI/CD pipeline

---

# Application Components

## Frontend Services

### Vote App

* Python Flask frontend
* Accepts votes from users
* Sends votes to Redis queue

### Result App

* Node.js frontend
* Displays live vote results
* Reads data from PostgreSQL

---

## Backend Services

### Worker

* .NET background processor
* Consumes Redis votes
* Writes processed data to PostgreSQL

### Redis

* High-performance in-memory queue

### PostgreSQL

* Persistent relational database

---

# System Architecture

```txt
User → Route53 → AWS ALB (HTTPS) → Kubernetes Services
Vote → Redis
Worker → Redis
Worker → PostgreSQL
Result → PostgreSQL
```

---

# Domain Configuration

## Subdomains

* `vote.la.ironlabs.online`
* `result.la.ironlabs.online`

## Route53

DNS records route external traffic to ALB.

### Recommended:

* Alias A Records

### Current:

* Alias A Records

---

# HTTPS Configuration

AWS Certificate Manager (ACM) provides:

* Wildcard certificate for `*.la.ironlabs.online`
* Automatic DNS validation via Route53
* Automatic certificate renewal
* Secure HTTPS termination at ALB

---

# Security Features

## Current:

* HTTPS enforced
* HTTP → HTTPS redirect
* Kubernetes Secrets
* IAM Roles for Service Accounts (IRSA)
* AWS IAM policy for ALB controller

## Future:

* AWS WAF
* Shield Advanced
* GitHub OIDC
* Secrets Manager
* ExternalDNS

---

# Technologies Used

* Amazon EKS
* Kubernetes
* AWS Load Balancer Controller
* Route53
* ACM
* Docker
* Docker Hub
* GitHub Actions
* Helm
* Python / Flask
* Node.js
* .NET
* Redis
* PostgreSQL

---

# Cluster Information

**Cluster Name:** `spot-eks-lab-lananh`
**AWS Region:** `us-east-1`

---

# Deployment Workflow

## Step 1: Build and Push Docker Images

Each microservice is built and pushed to Docker Hub:

* Vote
* Result
* Worker

Images are tagged using Git commit SHA for immutable deployments.

---

## Step 2: Deploy Kubernetes Resources

Kubernetes manifests deploy:

* Namespace
* Secrets
* Redis
* PostgreSQL
* Vote Deployment + Service
* Result Deployment + Service
* Worker Deployment
* ALB Ingress

---

## Step 3: Install AWS Load Balancer Controller

Using Helm and IRSA:

### Includes:

* IAM policy
* IAM role
* Service account
* ALB controller deployment

---

## Step 4: Configure ALB Ingress

ALB handles:

* Host-based routing
* HTTPS listeners
* ACM certificate integration
* SSL redirection
* Health checks

---

## Step 5: Configure Route53

Subdomains point to ALB:

* Vote frontend
* Result frontend

---

## Step 6: Enable HTTPS

ACM wildcard certificate secures both frontends.

---

# Access URLs

### Vote Application:

`https://vote.la.ironlabs.online`

### Result Application:

`https://result.la.ironlabs.online`

---

# CI/CD Pipeline

GitHub Actions automates:

## On push to `main`:

1. Checkout source code
2. Build Docker images
3. Push images to Docker Hub
4. Authenticate to AWS
5. Configure kubectl
6. Update kubeconfig
7. Apply Kubernetes manifests
8. Update deployment images
9. Verify rollout

---

# Required GitHub Secrets

## Docker Hub:

* `DOCKER_USERNAME`
* `DOCKER_PASSWORD`

## AWS:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

---

# Key Infrastructure Fixes

## Vote App

* Fixed Redis service DNS
* Explicit Redis port
* Stable Kubernetes service discovery

---

## Result App

* Corrected Node.js runtime port
* Fixed Kubernetes service targetPort
* Verified WebSocket routing

---

## AWS Load Balancer Controller

* IRSA configured
* Custom IAM policy attached
* ALB listener validation
* HTTPS + redirect working

---

## ACM

* Wildcard certificate configured
* DNS validation completed
* Secure frontend deployment enabled

---

# Validation Commands

## Kubernetes:

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

## Rollout:

```bash
kubectl rollout status deployment/vote
kubectl rollout status deployment/result
kubectl rollout status deployment/worker
```

## HTTPS:

```bash
curl -I http://vote.la.ironlabs.online
curl -I https://vote.la.ironlabs.online
```

---

# Troubleshooting

## Pod Logs:

```bash
kubectl logs <pod-name>
```

## DNS Validation:

```bash
nslookup vote.la.ironlabs.online
```

## ALB Controller Logs:

```bash
kubectl logs deployment/aws-load-balancer-controller -n kube-system
```

## ACM Status:

```bash
aws acm describe-certificate
```

---

# Production Best Practices Implemented

## Achieved:

* HTTPS by default
* ALB native routing
* Immutable Docker image tags
* Automated CI/CD
* Route53 integration
* IRSA security model
* AWS-native certificate lifecycle

---

# Future Enhancements

## Recommended:

* Horizontal Pod Autoscaler (HPA)
* PostgreSQL persistent volumes
* Monitoring (Prometheus/Grafana)
* Logging (CloudWatch)
* WAF integration
* ExternalDNS automation
* Blue/Green deployments
* ArgoCD / GitOps

---

# Lessons Learned

* Kubernetes DNS is critical for microservices
* ALB is superior for AWS-native production workloads
* ACM simplifies HTTPS dramatically
* Route53 + subdomains create cleaner architecture
* GitHub Actions requires both IAM and Kubernetes RBAC
* IRSA is essential for secure AWS controller integration
* Immutable tagging improves deployment reliability

---

# Phase 1 vs Phase 2 Comparison

| Feature         | Phase 1 (NGINX) | Phase 2 (ALB)      |
| --------------- | --------------- | ------------------ |
| Load Balancer   | Classic ELB     | AWS ALB            |
| HTTPS           | Optional/manual | Native ACM         |
| DNS             | Basic           | Route53 integrated |
| Security        | Moderate        | Production-grade   |
| AWS Integration | Limited         | Full               |
| Complexity      | Lower           | Higher             |
| Scalability     | Good            | Excellent          |

---

# Final Success Criteria

Project is complete when:

* All pods healthy
* Vote app operational
* Result app operational
* Vote flow functional end-to-end
* Redis + PostgreSQL stable
* ALB routing correctly
* HTTPS fully operational
* HTTP redirects enforced
* Route53 DNS working
* GitHub Actions deploys automatically

---

# Author

**Tran Lan Anh**
DevOps / Cloud Engineering Project
Amazon EKS + Kubernetes + AWS ALB + GitHub Actions
