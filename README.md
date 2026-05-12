# Project 2: Deploy a Production-Grade 3-Tier Voting App on Amazon EKS

## Overview

This project deploys and evolves a full microservices Voting Application on Amazon EKS through multiple production-focused phases:

### Phase 1 — Kubernetes + NGINX Ingress Controller

* Initial Kubernetes deployment
* Internal service discovery
* Validation environment
* Custom subdomains via Route53
* NGINX ingress routing

### Phase 2 — AWS Load Balancer Controller + Route53 + ACM + CI/CD

* AWS-native Application Load Balancer
* HTTPS with ACM wildcard certificates
* Route53 production DNS
* GitHub Actions automation
* Enterprise-grade ingress

### Phase 3 — PostgreSQL StatefulSet Primary / Replica Architecture

* Stateful PostgreSQL cluster
* Primary + Replica topology
* Streaming replication
* Persistent EBS-backed storage
* Read/write separation
* High availability foundation

---

# Application Components

## Frontend Services

### Vote App

* Python / Flask
* Public voting interface
* Sends votes to Redis

### Result App

* Node.js
* Real-time dashboard
* Reads from PostgreSQL replicas

---

## Backend Services

### Worker

* .NET background processor
* Reads Redis queue
* Writes to PostgreSQL primary

### Redis

* High-speed in-memory message queue

### PostgreSQL

* Primary node for writes
* Replica nodes for reads
* Persistent storage via AWS EBS

---

# Final Architecture

```txt
Users
   ↓
Route53 DNS
   ↓
AWS ALB (HTTPS + ACM)
   ↓
Vote / Result Services
   ↓
Vote → Redis → Worker → PostgreSQL Primary
                          ↓
                    Streaming Replication
                          ↓
               PostgreSQL Replica Nodes
                          ↓
                    Result App Reads
```

---

# Infrastructure Stack

* Amazon EKS
* Kubernetes Deployments
* Kubernetes StatefulSets
* AWS Load Balancer Controller
* Route53
* AWS Certificate Manager (ACM)
* GitHub Actions
* Docker Hub
* AWS EBS CSI Driver
* gp3 StorageClass
* PersistentVolumeClaims
* Kubernetes Secrets
* IAM Roles for Service Accounts (IRSA)

---

# Cluster Information

**Cluster Name:** `spot-eks-lab-lananh`
**AWS Region:** `us-east-1`

---

# Domain Configuration

## Public Endpoints

* `vote.la.ironlabs.online`
* `result.la.ironlabs.online`

## DNS

* Route53 Alias A Records → ALB

---

# HTTPS Security

## AWS Certificate Manager

* Wildcard certificate: `*.la.ironlabs.online`
* Automatic DNS validation
* Automatic renewal
* SSL termination at ALB
* HTTP → HTTPS redirection

---

# Kubernetes Secrets

## Database Credentials

```bash
kubectl create secret generic db-credentials \
  --from-literal=POSTGRES_USER=postgres \
  --from-literal=POSTGRES_PASSWORD=postgres
```

## Replication Credentials

```bash
kubectl create secret generic postgres-replication \
  --from-literal=password=postgres
```

---

# Phase 2: AWS Load Balancer Controller Setup

## Step 1: Download IAM Policy

```bash
curl -o iam_policy.json \
https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

## Step 2: Create IAM Policy

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy-LA \
  --policy-document file://iam_policy.json
```

## Step 3: Create IAM Service Account

```bash
eksctl create iamserviceaccount \
  --cluster=spot-eks-lab-lananh \
  --region us-east-1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy-LA \
  --override-existing-serviceaccounts \
  --approve
```

## Step 4: Install ALB Controller via Helm

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=spot-eks-lab-lananh \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<YOUR_VPC_ID>
```

## Verify:

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

---

# Phase 3: PostgreSQL StatefulSet Deployment

## Features

* `postgres-0` → Primary
* `postgres-1` → Replica
* `postgres-2` → Replica

---

## Stable DNS

* `postgres-0.postgres`
* `postgres-1.postgres`
* `postgres-2.postgres`

---

## Services

* `postgres-primary`
* `postgres-replica`

---

# Install AWS EBS CSI Driver

```bash
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster spot-eks-lab-lananh \
  --region us-east-1 \
  --force
```

---

# StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: postgres-gp3
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  type: gp3
  fsType: ext4
```

---

## Apply:

```bash
kubectl apply -f k8s/postgres-storageclass.yaml
```

---

# Deploy StatefulSet

```bash
kubectl apply -f k8s/postgres-statefulset.yaml
```

---

# Verify:

```bash
kubectl get pods
kubectl get pvc
kubectl get statefulset
```

---

# Verify Replication

## Primary:

```bash
kubectl exec postgres-0 -- psql -U postgres -c "SELECT pg_is_in_recovery();"
```

Expected:

```txt
f
```

---

## Replicas:

```bash
kubectl exec postgres-1 -- psql -U postgres -c "SELECT pg_is_in_recovery();"
kubectl exec postgres-2 -- psql -U postgres -c "SELECT pg_is_in_recovery();"
```

Expected:

```txt
t
```

---

# CI/CD Pipeline

GitHub Actions automates:

* Docker image builds
* Docker Hub pushes
* AWS authentication
* Kubernetes deployments
* Rolling updates
* Immutable image versioning with `${{ github.sha }}`

---

# Required GitHub Secrets

## Docker Hub

* `DOCKER_USERNAME`
* `DOCKER_PASSWORD`

## AWS

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

---

# Common Challenges Solved

## Vote App

* Redis DNS resolution
* REDIS_PORT conflicts
* HTTPS mixed content

---

## Result App

* Incorrect Node.js port
* WebSocket routing
* Replica database routing

---

## PostgreSQL

* PVC immutability
* `lost+found` initialization
* StatefulSet migration
* Replication bootstrapping

---

## AWS

* ALB webhook issues
* IAM policy conflicts
* ACM validation
* Route53 DNS routing

---

# Validation Commands

## Cluster Health

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get pvc
kubectl get statefulset
```

---

## ALB Controller Logs

```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

---

## HTTPS Validation

```bash
curl -I https://vote.la.ironlabs.online
curl -I https://result.la.ironlabs.online
```

---

# Production Best Practices Achieved

* Kubernetes microservices
* AWS-native ingress
* HTTPS by default
* ACM lifecycle management
* Route53 DNS
* Persistent PostgreSQL
* Stateful replication
* Automated CI/CD
* Secure secret management
* IRSA least-privilege model

---

# Future Enhancements

* Horizontal Pod Autoscaler
* Blue/Green deployments
* Monitoring (Prometheus/Grafana)
* CloudWatch logging
* AWS WAF
* ExternalDNS
* RDS migration
* Automated failover

---

# Lessons Learned

* Kubernetes DNS is mission-critical
* ALB is superior for AWS-native production workloads
* ACM simplifies TLS management
* StatefulSets are essential for databases
* Persistent storage requires careful volume planning
* GitHub Actions requires both AWS IAM and Kubernetes RBAC
* IRSA is critical for controller security
* Immutable deployments improve rollback safety

---

# Final Outcome

A full production-grade cloud-native deployment featuring:

* Amazon EKS
* Kubernetes
* AWS ALB
* HTTPS
* Route53
* ACM
* GitHub Actions
* Persistent PostgreSQL
* Stateful replication
* Enterprise-grade DevOps architecture

---

# Author

**Tran Lan Anh**
DevOps / Cloud Engineering Project
Amazon EKS + Kubernetes + AWS ALB + GitHub Actions + PostgreSQL StatefulSet
