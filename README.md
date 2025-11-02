# URL Shortener - Microservices Architecture

Микросервисная архитектура для сервиса сокращения URL на базе NestJS, PostgreSQL, RabbitMQ и GraphQL.

## 🏗️ Архитектура

```
┌─────────────────┐
│   API Gateway   │  ← REST API (Port 3000)
└────────┬────────┘
         │
    ┌────┴─────┬──────────┬──────────┐
    │          │          │          │
    ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐
│  Auth  │ │  User  │ │  Link  │ │ RabbitMQ │
│Service │ │Service │ │Service │ │          │
│  :3002 │ │:3001   │ │:3003   │ │  :5672   │
└───┬────┘ └───┬────┘ └───┬────┘ └──────────┘
    │          │          │
    ▼          ▼          ▼
┌──────────────────────────────┐
│   PostgreSQL (3 databases)   │
│ auth / user / link           │
└──────────────────────────────┘
```

## 📦 Сервисы

| Сервис           | Порт        | Технологии              | Описание                                     |
| ---------------- | ----------- | ----------------------- | -------------------------------------------- |
| **API Gateway**  | 3000        | NestJS, REST            | Точка входа для всех запросов                |
| **Auth Service** | 3002        | NestJS, JWT, Prisma     | Аутентификация и авторизация                 |
| **User Service** | 3001        | NestJS, GraphQL, Prisma | Управление пользователями                    |
| **Link Service** | 3003        | NestJS, Prisma          | Создание и управление короткими ссылками     |
| **RabbitMQ**     | 5672, 15672 | RabbitMQ                | Message broker для межсервисной коммуникации |
| **PostgreSQL**   | 5432        | PostgreSQL 16           | 3 отдельные базы данных                      |

## 🚀 Быстрый старт

### Локальная разработка с Docker Compose

1. **Клонируйте репозиторий:**

```bash
git clone <repository-url>
cd url-shortener-monorepo
```

2. **Создайте .env файлы для каждого сервиса:**

```bash
# Скопируйте .env.example файлы
cp api-gateway/.env.example api-gateway/.env
cp auth-service/.env.example auth-service/.env
cp user-service/.env.example user-service/.env
cp link-service/.env.example link-service/.env
```

3. **Запустите все сервисы:**

```bash
docker-compose up -d
```

4. **Проверьте статус:**

```bash
docker-compose ps
```

### Доступные endpoints:

- **API Gateway**: http://localhost:3000
- **Auth Service**: http://localhost:3002
- **User Service GraphQL**: http://localhost:3001/graphql
- **Link Service**: http://localhost:3003
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)

## ☸️ Kubernetes Development

### Требования:

- kubectl
- Kubernetes кластер (Minikube, K3s, Docker Desktop Kubernetes и т.д.)
- Ingress Controller (опционально)

### Развертывание:

**Windows (PowerShell):**

```powershell
cd k8s
.\deploy.ps1
```

**Linux/Mac (Bash):**

```bash
cd k8s
chmod +x deploy.sh
./deploy.sh
```

### Доступ к сервисам через port-forward:

```bash
# API Gateway
kubectl port-forward -n url-shortener svc/api-gateway 3000:3000

# RabbitMQ Management
kubectl port-forward -n url-shortener svc/rabbitmq 15672:15672

# User Service (GraphQL)
kubectl port-forward -n url-shortener svc/user-service 3001:3001
```

Подробная документация: [k8s/README.md](k8s/README.md)

## 📋 Production Checklist

Перед развертыванием в production обязательно ознакомьтесь с:

- [k8s/PRODUCTION-CHECKLIST.md](k8s/PRODUCTION-CHECKLIST.md)

**Критически важно:**

- ⚠️ Изменить все пароли и секреты
- ⚠️ Настроить TLS сертификаты
- ⚠️ Настроить backup баз данных
- ⚠️ Настроить мониторинг и логирование

## 🛠️ Разработка

### Структура проекта:

```
.
├── api-gateway/          # REST API Gateway
├── auth-service/         # Authentication Service
├── user-service/         # User Management (GraphQL)
├── link-service/         # Link Management
├── k8s/                  # Kubernetes manifests
│   ├── api-gateway/
│   ├── auth-service/
│   ├── user-service/
│   ├── link-service/
│   ├── rabbitmq/
│   ├── configmap-common.yaml
│   ├── namespace.yaml
│   ├── deploy.sh
│   ├── deploy.ps1
│   └── README.md
├── .github/
│   └── workflows/
│       └── deploy.yaml   # CI/CD Pipeline
└── docker-compose.yml
```

### Разработка отдельного сервиса:

```bash
cd auth-service
npm install
npm run start:dev
```

### Миграции базы данных:

```bash
cd auth-service
npx prisma migrate dev --name init
npx prisma generate
```

## 🔧 Технологический стек

- **Backend Framework**: NestJS
- **API**: REST + GraphQL
- **Database**: PostgreSQL 16 + Prisma ORM
- **Message Broker**: RabbitMQ
- **Authentication**: JWT (Access + Refresh tokens)
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions

## 📊 Environment Variables

Каждый сервис требует следующие переменные окружения:

### Общие для всех:

```env
NODE_ENV=production
USER_SERVICE_URL=http://user-service:3001
AUTH_SERVICE_URL=http://auth-service:3002
LINK_SERVICE_URL=http://link-service:3003
RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672
API_GATEWAY_SECRET=your_secret_key
```

### Auth Service:

```env
PORT=3002
DATABASE_URL=postgresql://postgres:password@postgres-auth:5432/url-shortener_auth
JWT_ACCESS_SECRET=your_access_secret
JWT_ACCESS_EXPIRES_IN=5m
JWT_REFRESH_SECRET=your_refresh_secret
JWT_REFRESH_EXPIRES_IN=15m
```

### User Service:

```env
PORT=3001
DATABASE_URL=postgresql://postgres:password@postgres-user:5432/url-shortener_user
```

### Link Service:

```env
PORT=3003
DATABASE_URL=postgresql://postgres:password@postgres-link:5432/url-shortener_link
```

## 🧪 Тестирование

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 📝 API Documentation

После запуска сервисов:

- **API Gateway Swagger**: http://localhost:3000/api
- **User Service GraphQL Playground**: http://localhost:3001/graphql

## 🔐 Аутентификация

Сервис использует JWT токены:

1. **Register/Login** через Auth Service
2. Получить **Access Token** (5 минут) и **Refresh Token** (15 минут)
3. Использовать Access Token в заголовке: `Authorization: Bearer <token>`
4. Обновить токены через `/auth/refresh` endpoint

## 📈 Мониторинг

Рекомендуемые инструменты:

- **Metrics**: Prometheus + Grafana
- **Logs**: ELK Stack или Loki
- **Tracing**: Jaeger
- **Health Checks**: Kubernetes liveness/readiness probes

## 🤝 Contributing

1. Fork проект
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📄 License

[MIT License](LICENSE)

## 👥 Authors

- Wo0zZ1 - Initial work

## 🙏 Acknowledgments

- NestJS documentation
- Prisma documentation
- Kubernetes documentation
