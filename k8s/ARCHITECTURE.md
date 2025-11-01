# Architecture Diagram

## System Architecture (Mermaid)

```mermaid
graph TB
    subgraph "External"
        Client[Client Browser/App]
        Internet[Internet]
    end

    subgraph "Kubernetes Cluster - namespace: url-shortener"
        subgraph "Ingress Layer"
            Ingress[Ingress Controller<br/>api-gateway.local]
        end

        subgraph "API Layer"
            Gateway[API Gateway<br/>:3000<br/>REST API]
        end

        subgraph "Service Layer"
            Auth[Auth Service<br/>:3002<br/>JWT Auth]
            User[User Service<br/>:3001<br/>GraphQL]
            Link[Link Service<br/>:3003<br/>Link Management]
        end

        subgraph "Message Queue"
            RabbitMQ[RabbitMQ<br/>:5672, :15672<br/>Message Broker]
        end

        subgraph "Data Layer"
            PG_Auth[(PostgreSQL<br/>postgres-auth<br/>url-shortener_auth)]
            PG_User[(PostgreSQL<br/>postgres-user<br/>url-shortener_user)]
            PG_Link[(PostgreSQL<br/>postgres-link<br/>url-shortener_link)]
        end

        subgraph "Storage"
            PVC_Auth[PVC: postgres-auth-pvc<br/>1Gi]
            PVC_User[PVC: postgres-user-pvc<br/>1Gi]
            PVC_Link[PVC: postgres-link-pvc<br/>1Gi]
        end
    end

    Client --> Ingress
    Ingress --> Gateway
    Internet --> Ingress

    Gateway --> Auth
    Gateway --> User
    Gateway --> Link

    Auth --> RabbitMQ
    User --> RabbitMQ
    Link --> RabbitMQ

    Auth --> PG_Auth
    User --> PG_User
    Link --> PG_Link

    PG_Auth -.-> PVC_Auth
    PG_User -.-> PVC_User
    PG_Link -.-> PVC_Link

    style Gateway fill:#90EE90
    style Auth fill:#87CEEB
    style User fill:#87CEEB
    style Link fill:#87CEEB
    style RabbitMQ fill:#FFA07A
    style PG_Auth fill:#DDA0DD
    style PG_User fill:#DDA0DD
    style PG_Link fill:#DDA0DD
```

## Authentication Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant G as API Gateway
    participant A as Auth Service
    participant DB as PostgreSQL Auth

    C->>G: POST /auth/register
    G->>A: Forward request
    A->>DB: Create user
    DB-->>A: User created
    A->>A: Generate JWT tokens
    A-->>G: Access + Refresh tokens
    G-->>C: Tokens + User data

    Note over C: Store tokens

    C->>G: POST /links (with Access token)
    G->>G: Verify token
    alt Token valid
        G->>Link: Forward request
        Link-->>G: Response
        G-->>C: Success
    else Token expired
        G-->>C: 401 Unauthorized
        C->>G: POST /auth/refresh (with Refresh token)
        G->>A: Refresh request
        A->>DB: Verify refresh token
        DB-->>A: Valid
        A->>A: Generate new tokens
        A-->>G: New tokens
        G-->>C: New Access + Refresh tokens
    end
```

## Link Creation Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant G as API Gateway
    participant L as Link Service
    participant R as RabbitMQ
    participant DB as PostgreSQL Link

    C->>G: POST /links<br/>{originalUrl, customShortCode}
    G->>G: Verify JWT token
    G->>L: Create link request
    L->>L: Generate/Validate short code
    L->>DB: Save link
    DB-->>L: Link created
    L->>R: Publish link.created event
    R-->>L: Acknowledged
    L-->>G: Link data + shortUrl
    G-->>C: Response with short link

    Note over C: Use short link

    C->>G: GET /{shortCode}
    G->>L: Resolve short code
    L->>DB: Find original URL
    DB-->>L: Original URL
    L->>DB: Increment click count
    L->>R: Publish link.clicked event
    L-->>G: Original URL
    G-->>C: 302 Redirect to original URL
```

## Kubernetes Resources

```mermaid
graph LR
    subgraph "Core Resources"
        NS[Namespace:<br/>url-shortener]
        CM[ConfigMap:<br/>common-config]
        SEC1[Secret:<br/>postgres-secret]
        SEC2[Secret:<br/>jwt-secret]
        SEC3[Secret:<br/>api-gateway-secret]
    end

    subgraph "API Gateway"
        GW_DEP[Deployment:<br/>api-gateway<br/>replicas: 2]
        GW_SVC[Service:<br/>api-gateway<br/>:3000]
        GW_ING[Ingress:<br/>api-gateway-ingress]
    end

    subgraph "Auth Service"
        AUTH_DEP[Deployment:<br/>auth-service<br/>replicas: 2]
        AUTH_SVC[Service:<br/>auth-service<br/>:3002]
        AUTH_PG_DEP[Deployment:<br/>postgres-auth<br/>replicas: 1]
        AUTH_PG_SVC[Service:<br/>postgres-auth<br/>:5432]
        AUTH_PVC[PVC:<br/>postgres-auth-pvc]
    end

    subgraph "User Service"
        USER_DEP[Deployment:<br/>user-service<br/>replicas: 2]
        USER_SVC[Service:<br/>user-service<br/>:3001]
        USER_PG_DEP[Deployment:<br/>postgres-user<br/>replicas: 1]
        USER_PG_SVC[Service:<br/>postgres-user<br/>:5432]
        USER_PVC[PVC:<br/>postgres-user-pvc]
    end

    subgraph "Link Service"
        LINK_DEP[Deployment:<br/>link-service<br/>replicas: 2]
        LINK_SVC[Service:<br/>link-service<br/>:3003]
        LINK_PG_DEP[Deployment:<br/>postgres-link<br/>replicas: 1]
        LINK_PG_SVC[Service:<br/>postgres-link<br/>:5432]
        LINK_PVC[PVC:<br/>postgres-link-pvc]
    end

    subgraph "RabbitMQ"
        RMQ_DEP[Deployment:<br/>rabbitmq<br/>replicas: 1]
        RMQ_SVC[Service:<br/>rabbitmq<br/>:5672, :15672]
    end

    NS --> CM
    NS --> SEC1
    NS --> SEC2
    NS --> SEC3

    GW_DEP --> CM
    GW_DEP --> SEC3
    GW_DEP --> GW_SVC
    GW_SVC --> GW_ING

    AUTH_DEP --> CM
    AUTH_DEP --> SEC1
    AUTH_DEP --> SEC2
    AUTH_DEP --> SEC3
    AUTH_DEP --> AUTH_SVC
    AUTH_PG_DEP --> SEC1
    AUTH_PG_DEP --> AUTH_PVC
    AUTH_PG_DEP --> AUTH_PG_SVC

    USER_DEP --> CM
    USER_DEP --> SEC1
    USER_DEP --> SEC3
    USER_DEP --> USER_SVC
    USER_PG_DEP --> SEC1
    USER_PG_DEP --> USER_PVC
    USER_PG_DEP --> USER_PG_SVC

    LINK_DEP --> CM
    LINK_DEP --> SEC1
    LINK_DEP --> SEC3
    LINK_DEP --> LINK_SVC
    LINK_PG_DEP --> SEC1
    LINK_PG_DEP --> LINK_PVC
    LINK_PG_DEP --> LINK_PG_SVC

    RMQ_DEP --> CM
    RMQ_DEP --> RMQ_SVC

    style NS fill:#FFE4B5
    style CM fill:#E0FFFF
    style SEC1 fill:#FFB6C1
    style SEC2 fill:#FFB6C1
    style SEC3 fill:#FFB6C1
```

## CI/CD Pipeline

```mermaid
graph LR
    subgraph "GitHub"
        Push[git push to main]
        GHA[GitHub Actions]
    end

    subgraph "Build Phase"
        Checkout[Checkout Code]
        Login[Login to GHCR]
        Build[Build Docker Images<br/>4 services]
        Push_Images[Push to GHCR]
    end

    subgraph "Deploy Phase"
        Setup[Setup kubectl]
        Config[Configure kubectl<br/>from KUBE_CONFIG_DATA]
        Apply[Apply K8s Manifests]
    end

    subgraph "Kubernetes Cluster"
        NS[Create Namespace]
        ConfigMaps[Apply ConfigMaps/Secrets]
        RMQ[Deploy RabbitMQ]
        DBs[Deploy PostgreSQL DBs]
        Services[Deploy Services]
        Gateway[Deploy API Gateway]
        Status[Check Status]
    end

    Push --> GHA
    GHA --> Checkout
    Checkout --> Login
    Login --> Build
    Build --> Push_Images

    Push_Images --> Setup
    Setup --> Config
    Config --> Apply

    Apply --> NS
    NS --> ConfigMaps
    ConfigMaps --> RMQ
    RMQ --> DBs
    DBs --> Services
    Services --> Gateway
    Gateway --> Status

    style Push fill:#90EE90
    style Build fill:#87CEEB
    style Apply fill:#FFA07A
    style Status fill:#98FB98
```

## Deployment Order

```mermaid
graph TD
    Start[Start Deployment] --> NS[1. Create Namespace]
    NS --> CM[2. Apply ConfigMaps & Secrets]
    CM --> RMQ[3. Deploy RabbitMQ]
    RMQ --> WaitRMQ{Wait for<br/>RabbitMQ Ready}
    WaitRMQ -->|Ready| DBs[4. Deploy PostgreSQL Databases]
    WaitRMQ -->|Not Ready| WaitRMQ
    DBs --> WaitDB{Wait for<br/>All DBs Ready}
    WaitDB -->|Ready| Auth[5. Deploy Auth Service]
    WaitDB -->|Not Ready| WaitDB
    Auth --> User[6. Deploy User Service]
    User --> Link[7. Deploy Link Service]
    Link --> WaitSvc{Wait for<br/>Services Ready}
    WaitSvc -->|Ready| GW[8. Deploy API Gateway]
    WaitSvc -->|Not Ready| WaitSvc
    GW --> Ing[9. Apply Ingress]
    Ing --> Done[Deployment Complete ✓]

    style Start fill:#90EE90
    style Done fill:#98FB98
    style WaitRMQ fill:#FFE4B5
    style WaitDB fill:#FFE4B5
    style WaitSvc fill:#FFE4B5
```

## Network Communication

```mermaid
graph TB
    subgraph "External Network"
        EXT[External Clients<br/>Internet]
    end

    subgraph "Cluster Network - url-shortener namespace"
        ING[Ingress<br/>LoadBalancer/NodePort]

        subgraph "Pod Network"
            GW[api-gateway:3000]
            AUTH[auth-service:3002]
            USER[user-service:3001]
            LINK[link-service:3003]
            RMQ[rabbitmq:5672]
            PG1[(postgres-auth:5432)]
            PG2[(postgres-user:5432)]
            PG3[(postgres-link:5432)]
        end
    end

    EXT -->|HTTP/HTTPS| ING
    ING -->|ClusterIP| GW

    GW -.->|REST| AUTH
    GW -.->|GraphQL| USER
    GW -.->|REST| LINK

    AUTH -->|AMQP| RMQ
    USER -->|AMQP| RMQ
    LINK -->|AMQP| RMQ

    AUTH -->|PostgreSQL Protocol| PG1
    USER -->|PostgreSQL Protocol| PG2
    LINK -->|PostgreSQL Protocol| PG3

    style EXT fill:#FFE4B5
    style ING fill:#90EE90
    style GW fill:#87CEEB
    style AUTH fill:#DDA0DD
    style USER fill:#DDA0DD
    style LINK fill:#DDA0DD
    style RMQ fill:#FFA07A
```

## Data Models Overview

```mermaid
erDiagram
    USER ||--o{ REFRESH_TOKEN : has
    USER ||--o{ LINK : creates
    LINK ||--o{ CLICK_STAT : tracks

    USER {
        uuid id PK
        string email UK
        string username UK
        string password
        datetime createdAt
        datetime updatedAt
    }

    REFRESH_TOKEN {
        uuid id PK
        uuid userId FK
        string token UK
        datetime expiresAt
        datetime createdAt
    }

    LINK {
        uuid id PK
        uuid userId FK
        string originalUrl
        string shortCode UK
        int clicks
        datetime expiresAt
        datetime createdAt
        datetime updatedAt
    }

    CLICK_STAT {
        uuid id PK
        uuid linkId FK
        string ip
        string country
        string city
        datetime clickedAt
    }
```

## Technology Stack

```mermaid
mindmap
  root((URL Shortener))
    Backend
      NestJS Framework
        TypeScript
        Dependency Injection
        Modular Architecture
      REST API
        Express
        Swagger/OpenAPI
      GraphQL
        Apollo Server
        Schema First
    Data Layer
      PostgreSQL 16
        3 Separate Databases
        ACID Transactions
      Prisma ORM
        Type Safety
        Migrations
        Query Builder
    Message Queue
      RabbitMQ
        AMQP Protocol
        Pub/Sub Pattern
        Management UI
    Security
      JWT Tokens
        Access Token 5m
        Refresh Token 15m
      Password Hashing
        bcrypt
      API Gateway Secret
    DevOps
      Docker
        Multi-stage Builds
        Alpine Images
      Kubernetes
        Deployments
        Services
        Ingress
        ConfigMaps
        Secrets
        PVC
      CI/CD
        GitHub Actions
        GHCR
        Auto Deploy
```
