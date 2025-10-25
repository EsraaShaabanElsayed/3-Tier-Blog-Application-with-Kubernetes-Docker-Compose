![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=flat&logo=go&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)
# 3-Tier Blog Application with Kubernetes & Docker Compose

A production-ready three-tier web application demonstrating containerized microservices architecture with both local development (Docker Compose) and production-like deployment (Kubernetes) capabilities.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Local Deployment (Docker Compose)](#local-deployment-docker-compose)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Accessing the Application](#accessing-the-application)
- [Key Features](#key-features)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Future Improvements](#future-improvements)

---

## 📖 Overview

This project implements a **3-tier blog API system** consisting of:

1. **Backend API (Go)** - Serves REST responses with blog post titles from the database
2. **Database (MySQL 8.0)** - Persistent storage for blog data using StatefulSet
3. **Reverse Proxy (Nginx)** - Exposes the API over HTTPS with SSL/TLS termination

The application supports two deployment modes:
- **Docker Compose**: For local development and testing
- **Kubernetes**: For production-like orchestration with StatefulSets, persistent volumes, and secrets management

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Client Browser                        │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTPS (443)
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Nginx Reverse Proxy                         │
│  - SSL/TLS Termination (Self-signed certificate)        │
│  - HTTP → HTTPS Redirect                                │
│  - NodePort Service (K8s) / Host ports 80/443 (Docker)  │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP (Internal)
                        ▼
┌─────────────────────────────────────────────────────────┐
│                Backend API (Go)                          │
│  - REST API endpoint: GET /                             │
│  - Connects to MySQL using Docker Secrets               │
│  - ClusterIP Service (K8s) / Port 8000                  │
└───────────────────────┬─────────────────────────────────┘
                        │ MySQL Protocol (3306)
                        ▼
┌─────────────────────────────────────────────────────────┐
│              MySQL Database (StatefulSet)                │
│  - Persistent storage via PVC                           │
│  - Headless Service for stable network identity         │
│  - Secrets for password management                      │
│  - Schema: blog table (id, title)                       │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Decisions

- **StatefulSet for Database**: Provides stable pod identity and persistent volume management (changed from Deployment for production readiness)
- **Headless Service**: Enables direct pod-to-pod communication for MySQL StatefulSet
- **Secrets Management**: Database passwords stored securely using Kubernetes Secrets (excluded from version control)
- **Multi-stage Dockerfile**: Optimized Go binary built in separate stage for minimal image size

---

## 🛠️ Technologies Used

| Component | Technology | Version |
|-----------|------------|---------|
| **Backend** | Go | Latest |
| **Database** | MySQL | 8.0 |
| **Reverse Proxy** | Nginx | Latest |
| **Container Runtime** | Docker | 20.10+ |
| **Orchestration** | Kubernetes | 1.34+ |
| **Local K8s** | Kind | Latest |
| **Secrets** | Docker Secrets / K8s Secrets | - |
| **SSL/TLS** | OpenSSL (self-signed) | - |

---

## 📁 Project Structure

```
project/
├── backend/
│   ├── Dockerfile              # Multi-stage build for Go app
│   ├── main.go                 # Backend API logic
│   ├── go.mod                  # Go module dependencies
│   └── go.sum                  # Dependency checksums
│
├── nginx/
│   ├── Dockerfile              # Nginx container with SSL certs
│   ├── nginx.conf              # Reverse proxy configuration
│   ├── generate-ssl.sh         # Script to generate self-signed certificates
│   └── certs/                  # SSL certificates (gitignored)
│       ├── nginx-selfsigned.crt
│       └── nginx-selfsigned.key
│
├── k8s/
│   ├── backend_deployment.yaml     # Backend deployment manifest
│   ├── backend_service.yaml        # Backend ClusterIP service
│   ├── database_statefulset.yaml   # MySQL StatefulSet (was deployment)
│   ├── db-service.yaml             # MySQL headless service
│   ├── db-secret.yaml              # MySQL password secret (gitignored)
│   ├── db-data-pv.yaml             # Persistent Volume for MySQL
│   ├── db-data-pvc.yaml            # Persistent Volume Claim
│   ├── proxy_deployment.yaml       # Nginx deployment
│   └── proxy_nodeport.yaml         # Nginx NodePort service (30080, 30443)
│
├── docker-compose.yaml         # Local development stack
├── db_password.txt             # Database password (gitignored)
├── .gitignore                  # Excludes secrets and certificates
└── README.md                   # This file
```

---

## ✅ Prerequisites

### For Docker Compose:

- Docker Engine 20.10+
- Docker Compose V2 (`docker compose` command)

### For Kubernetes:

- `kubectl` CLI tool
- A Kubernetes cluster (Kind, Minikube, or cloud provider)
- For local testing: Kind installed


## 🚀 Local Deployment (Docker Compose)

### Step 1: Clone the Repository

```bash
git clone <your-repo-url>
cd project
```

### Step 2: Generate SSL Certificates

```bash
cd nginx
chmod +x generate-ssl.sh
./generate-ssl.sh
cd ..
```

This creates self-signed certificates in `nginx/certs/`.

### Step 3: Create Database Password

```bash
echo "your_secure_password" > db_password.txt
```

### Step 4: Configure Local DNS (Optional)

Add to `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows):

```
127.0.0.1    blog-app.com www.blog-app.com
```

### Step 5: Start the Application

```bash
docker compose up -d
```

### Step 6: Verify Containers

```bash
docker ps
```

/home/esraa/Pictures/Screenshots/Screenshot from 2025-10-25 23-42-10.png`

### Step 7: Test the Application

**Via Nginx Proxy (HTTPS):**
```bash
curl -k https://blog-app.com
# or
curl -k https://localhost
```
![alt text](<Screenshot from 2025-10-25 23-17-21.png>)
**Direct Backend Access:**
```bash
curl http://localhost:9080
```
![alt text](<Screenshot from 2025-10-25 23-44-07.png>)

### Step 8: Stop the Application

```bash
docker compose down
```
![alt text](<Screenshot from 2025-10-25 23-45-25.png>)
---

## ☸️ Kubernetes Deployment


### Build and Load Docker Images

```bash
# Build images
docker build -t blog-backend:latest ./backend
docker build -t blog-nginx:latest ./nginx

# Load into minikkube cluster
minikube load docker-image blog-backend:latest --name blog-app
minikube load docker-image blog-nginx:latest --name blog-app
```

### Step 3: Create Database Secret

```bash
kubectl create secret generic db-secret \
  --from-literal=password=your_secure_password
```

**Verify:**
```bash
kubectl get secrets
```

### Step 4: Deploy Database (StatefulSet)

```bash
kubectl apply -f k8s/db-data-pv.yaml
kubectl apply -f k8s/db-data-pvc.yaml
kubectl apply -f k8s/database_statefulset.yaml
kubectl apply -f k8s/db-service.yaml
```

### Step 5: Deploy Backend

```bash
kubectl apply -f k8s/backend_deployment.yaml
kubectl apply -f k8s/backend_service.yaml
```

### Step 6: Deploy Nginx Proxy

```bash
kubectl apply -f k8s/proxy_deployment.yaml
kubectl apply -f k8s/proxy_nodeport.yaml
```

### Step 7: Verify Deployment

```bash
kubectl get all
```
![alt text](<Screenshot from 2025-10-25 22-57-32.png>)
###  Access the Application

**Get Node IP:**
```bash
kubectl get nodes -o wide
/home/esraa/Pictures/Screenshots/Screenshot from 2025-10-25 23-55-12.png
```

**Test via HTTPS:**
```bash
curl -k https://<NODE-IP>:30443
```
![alt text](<Screenshot from 2025-10-25 23-57-34.png>)


---

## Accessing the Application

### Docker Compose:

| Service | URL | Description |
|---------|-----|-------------|
| **Nginx (HTTPS)** | `https://blog-app.com` | Production-like access |
| **Nginx (HTTP)** | `http://blog-app.com` | Redirects to HTTPS |
| **Backend Direct** | `http://localhost:9080` | Bypass proxy for testing |
| **MySQL** | `localhost:3306` | Database access |

### Kubernetes:

| Service | URL | Description |
|---------|-----|-------------|
| **Nginx (HTTPS)** | `https://<NODE-IP>:30443` | NodePort access |
| **Nginx (HTTP)** | `http://<NODE-IP>:30080` | Redirects to HTTPS |

