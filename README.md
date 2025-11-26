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
git clone --recursive https://github.com/Wo0zZ1/url-shortener
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
docker-compose -f ./docker-compose.dev.yaml up -d --build
```

4. **Проверьте статус:**

```bash
docker-compose ps
```

### Доступные endpoints:

- **API Gateway**: http://localhost:3000
- **User Service GraphQL**: http://localhost:3001 (+graphql)
- **Auth Service**: http://localhost:3002
- **Link Service**: http://localhost:3003
- **RabbitMQ Management**: http://localhost:15672

## ☸️ Kubernetes Development

### Развертывание:

**Windows (PowerShell):**

```powershell
cd k8s
kubectl apply -f k8s/namespace.yaml
kubectl apply -d k8s
```
## 🛠️ Разработка

### Структура проекта:

```
.
├── api-gateway/          # REST API Gateway
├── auth-service/         # Authentication Service
├── user-service/         # User Management (+GraphQL)
├── link-service/         # Link Management
├── k8s/                  # Kubernetes manifests
│   ├── api-gateway/
│   ├── auth-service/
│   ├── user-service/
│   ├── link-service/
│   ├── rabbitmq/
│   ├── configmap-common.yaml
│   ├── namespace.yaml
│   └── README.md
├── .github/
│   └── workflows/
│       └── deploy.yaml   # CI/CD Pipeline
└── docker-compose.yml
```

## 🔧 Технологический стек

- **Backend Framework**: NestJS
- **API**: REST + GraphQL
- **Database**: PostgreSQL + Prisma ORM
- **Message Broker**: RabbitMQ
- **Authentication**: JWT (Access + Refresh tokens)
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
```

## 🧪 Тестирование

```bash
# Unit tests
npm run test
```

## 📝 API Documentation

После запуска сервисов:

- **API Gateway Swagger**: http://localhost:3000/docs
- **User Service GraphQL Playground**: http://localhost:3001/graphql