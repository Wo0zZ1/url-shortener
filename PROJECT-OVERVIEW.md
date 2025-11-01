# 📋 Project Overview

## 🎯 URL Shortener Monorepo - Complete Kubernetes Setup

```
┌─────────────────────────────────────────────────────────────┐
│                    URL SHORTENER SYSTEM                     │
│                  Microservices Architecture                 │
└─────────────────────────────────────────────────────────────┘

📦 SERVICES (4)                    🗄️ DATABASES (3)
├── API Gateway       :3000       ├── postgres-auth
├── Auth Service      :3002       ├── postgres-user
├── User Service      :3001       └── postgres-link
└── Link Service      :3003
                                  🐰 MESSAGE QUEUE (1)
🔧 INFRASTRUCTURE                  └── RabbitMQ :5672/:15672
├── Kubernetes Manifests
├── Docker Compose                📚 DOCUMENTATION (8)
└── CI/CD Pipeline                ├── README.md
                                  ├── QUICKSTART.md
                                  ├── CHANGELOG.md
                                  ├── k8s/README.md
                                  ├── k8s/PRODUCTION-CHECKLIST.md
                                  ├── k8s/COMMANDS.md
                                  ├── k8s/API-TESTING.md
                                  └── k8s/ARCHITECTURE.md
```

---

## 📁 Directory Structure

```
url-shortener-monorepo/
│
├── 📄 README.md                           # Main documentation
├── 📄 QUICKSTART.md                       # Quick start guide
├── 📄 CHANGELOG.md                        # Version history
├── 🐳 docker-compose.yml                  # Docker Compose config
│
├── 📂 api-gateway/                        # REST API Gateway (Port 3000)
│   ├── src/
│   ├── Dockerfile
│   └── package.json
│
├── 📂 auth-service/                       # Authentication (Port 3002)
│   ├── src/
│   ├── prisma/
│   ├── Dockerfile
│   └── package.json
│
├── 📂 user-service/                       # User Management (Port 3001)
│   ├── src/
│   ├── prisma/
│   ├── Dockerfile
│   └── package.json
│
├── 📂 link-service/                       # Link Management (Port 3003)
│   ├── src/
│   ├── prisma/
│   ├── Dockerfile
│   └── package.json
│
├── 📂 k8s/                                # ⭐ Kubernetes Configuration
│   │
│   ├── 📄 README.md                       # K8s deployment guide
│   ├── 📄 SUMMARY.md                      # Complete changes overview
│   ├── 📄 PRODUCTION-CHECKLIST.md         # Production checklist
│   ├── 📄 COMMANDS.md                     # Kubectl cheat sheet
│   ├── 📄 API-TESTING.md                  # API testing examples
│   ├── 📄 ARCHITECTURE.md                 # Architecture diagrams
│   │
│   ├── 🔧 deploy.sh                       # Bash deployment
│   ├── 🔧 deploy.ps1                      # PowerShell deployment
│   ├── 🔧 cleanup.sh                      # Bash cleanup
│   ├── 🔧 cleanup.ps1                     # PowerShell cleanup
│   │
│   ├── 📄 namespace.yaml                  # Namespace definition
│   ├── 📄 configmap-common.yaml           # ConfigMaps + Secrets
│   │
│   ├── 📂 rabbitmq/                       # RabbitMQ
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   │
│   ├── 📂 api-gateway/                    # API Gateway K8s
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   │
│   ├── 📂 auth-service/                   # Auth Service K8s
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── postgres.yaml
│   │
│   ├── 📂 user-service/                   # User Service K8s
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── postgres.yaml
│   │
│   └── 📂 link-service/                   # Link Service K8s
│       ├── deployment.yaml
│       ├── service.yaml
│       └── postgres.yaml
│
└── 📂 .github/
    └── workflows/
        └── deploy.yaml                    # CI/CD Pipeline
```

---

## 🚀 Quick Commands Reference

### 🐳 Docker Compose

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f api-gateway

# Rebuild
docker-compose up -d --build
```

### ☸️ Kubernetes

```bash
# Deploy everything (Windows)
cd k8s && .\deploy.ps1

# Deploy everything (Linux/Mac)
cd k8s && ./deploy.sh

# Check status
kubectl get pods -n url-shortener

# Access API Gateway
kubectl port-forward -n url-shortener svc/api-gateway 3000:3000

# View logs
kubectl logs -f -n url-shortener -l app=api-gateway

# Cleanup
cd k8s && .\cleanup.ps1  # or ./cleanup.sh
```

---

## 🔗 Service URLs

### Local Development (Docker Compose)

| Service      | URL                           | Description        |
| ------------ | ----------------------------- | ------------------ |
| API Gateway  | http://localhost:3000         | REST API           |
| Swagger Docs | http://localhost:3000/api     | API Documentation  |
| User Service | http://localhost:3001/graphql | GraphQL Playground |
| RabbitMQ UI  | http://localhost:15672        | Management UI      |

### Kubernetes (with port-forward)

```bash
# API Gateway
kubectl port-forward -n url-shortener svc/api-gateway 3000:3000

# User Service (GraphQL)
kubectl port-forward -n url-shortener svc/user-service 3001:3001

# RabbitMQ Management
kubectl port-forward -n url-shortener svc/rabbitmq 15672:15672
```

---

## 📊 System Overview

### Services Architecture

```
Client Request
     ↓
[Ingress] → api-gateway.local
     ↓
[API Gateway :3000] ← REST API Entry Point
     ↓
     ├─→ [Auth Service :3002] → [postgres-auth]
     │         ↓
     │   [RabbitMQ :5672]
     │         ↓
     ├─→ [User Service :3001] → [postgres-user]
     │         ↓
     │   [RabbitMQ :5672]
     │         ↓
     └─→ [Link Service :3003] → [postgres-link]
               ↓
         [RabbitMQ :5672]
```

### Technology Stack

- **Framework**: NestJS (TypeScript)
- **API**: REST + GraphQL
- **Database**: PostgreSQL 16 + Prisma ORM
- **Message Queue**: RabbitMQ
- **Auth**: JWT (Access + Refresh tokens)
- **Container**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions

---

## 🔐 Default Credentials

⚠️ **Change these in production!**

- **PostgreSQL Password**: `qwerty123`
- **RabbitMQ**: `guest` / `guest`
- **JWT Access Secret**: `qwerty_1`
- **JWT Refresh Secret**: `qwerty_2`
- **API Gateway Secret**: `api_gateway_secret_key`

📝 See [PRODUCTION-CHECKLIST.md](k8s/PRODUCTION-CHECKLIST.md)

---

## 📚 Documentation Quick Links

| Document            | Purpose               | Path                                                       |
| ------------------- | --------------------- | ---------------------------------------------------------- |
| 🏠 **Main README**  | Project overview      | [README.md](README.md)                                     |
| ⚡ **Quick Start**  | Get started fast      | [QUICKSTART.md](QUICKSTART.md)                             |
| 📝 **Changelog**    | Version history       | [CHANGELOG.md](CHANGELOG.md)                               |
| ☸️ **K8s Guide**    | Kubernetes deployment | [k8s/README.md](k8s/README.md)                             |
| ✅ **Production**   | Production checklist  | [k8s/PRODUCTION-CHECKLIST.md](k8s/PRODUCTION-CHECKLIST.md) |
| 🔧 **Commands**     | Kubectl cheat sheet   | [k8s/COMMANDS.md](k8s/COMMANDS.md)                         |
| 🧪 **API Testing**  | API examples          | [k8s/API-TESTING.md](k8s/API-TESTING.md)                   |
| 🏗️ **Architecture** | System diagrams       | [k8s/ARCHITECTURE.md](k8s/ARCHITECTURE.md)                 |

---

## 🎯 Common Tasks

### 1️⃣ First Time Setup

```bash
# Clone
git clone <repo-url>
cd url-shortener-monorepo

# Docker Compose
docker-compose up -d

# OR Kubernetes
cd k8s && ./deploy.sh
```

### 2️⃣ Test API

```bash
# Register
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"Test123!","username":"test"}'

# Create Link
curl -X POST http://localhost:3000/links \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"originalUrl":"https://github.com","customShortCode":"gh"}'

# Use Link
curl -L http://localhost:3000/gh
```

### 3️⃣ View Logs

```bash
# Docker Compose
docker-compose logs -f api-gateway

# Kubernetes
kubectl logs -f -n url-shortener -l app=api-gateway
```

### 4️⃣ Scale Service

```bash
# Kubernetes only
kubectl scale deployment api-gateway -n url-shortener --replicas=5
```

### 5️⃣ Update Service

```bash
# Docker Compose
docker-compose up -d --build api-gateway

# Kubernetes
kubectl set image deployment/api-gateway \
  api-gateway=ghcr.io/wo0zz1/api-gateway:v2 \
  -n url-shortener
```

---

## 🚨 Troubleshooting Quick Fixes

| Problem             | Solution                                                                     |
| ------------------- | ---------------------------------------------------------------------------- |
| Pod not starting    | `kubectl describe pod POD_NAME -n url-shortener`                             |
| Can't connect to DB | Check postgres pod: `kubectl get pods -n url-shortener -l app=postgres-auth` |
| 401 Unauthorized    | Token expired, use `/auth/refresh`                                           |
| Port already in use | Stop conflicting service or change port                                      |
| Image pull error    | Check image name and Docker registry access                                  |

---

## 📈 Resource Usage

**Per Service (defaults):**

- CPU Request: 100m
- CPU Limit: 500m
- Memory Request: 256Mi
- Memory Limit: 1Gi

**Total for 2 replicas each:**

- ~8 pods (services)
- ~3 pods (databases)
- ~1 pod (RabbitMQ)
- **Total: ~12 pods**

**Storage:**

- 3 PVCs × 1Gi = 3Gi

---

## 🎓 Learning Resources

1. **NestJS**: https://docs.nestjs.com
2. **Kubernetes**: https://kubernetes.io/docs
3. **Prisma**: https://www.prisma.io/docs
4. **RabbitMQ**: https://www.rabbitmq.com/documentation.html
5. **GraphQL**: https://graphql.org/learn

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing`
5. Open Pull Request

---

## 📄 License

MIT License - see LICENSE file

---

## 👤 Author

**Wo0zZ1**

- GitHub: [@Wo0zZ1](https://github.com/Wo0zZ1)

---

## ⭐ Star This Repo!

If this project helps you, please give it a ⭐!

---

**Last Updated**: November 1, 2025
**Version**: 2.0.0
