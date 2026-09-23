# Cấu hình ứng dụng trong Kubernetes

Các giá trị dưới đây ánh xạ backend hiện tại sang Kubernetes service DNS.

## Shared environment

```dotenv
NODE_ENV=development
JWT_ISSUER=http://identity-service.flash-sale-dev.svc.cluster.local:3001
JWT_AUDIENCE=flash-sale-api
IDENTITY_JWKS_URL=http://identity-service.flash-sale-dev.svc.cluster.local:3001/.well-known/jwks.json
INTERNAL_API_KEY=<kubernetes-secret>
KAFKA_BROKERS=kafka.flash-sale-infra.svc.cluster.local:9092
KAFKA_ENABLED=true
REDIS_URL=redis://redis.flash-sale-infra.svc.cluster.local:6379
ELASTICSEARCH_URL=http://elasticsearch.flash-sale-infra.svc.cluster.local:9200
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
```

## Service-specific environment

### Identity

```dotenv
PORT=3001
DATABASE_URL=postgres://identity_app:<password>@postgres.flash-sale-infra.svc.cluster.local:5432/identity
```

JWT private/public key phải được mount từ Kubernetes Secret, không bake vào image.

### Product Catalog

```dotenv
PORT=3002
MONGODB_URI=mongodb://mongodb-0.mongodb.flash-sale-infra.svc.cluster.local:27017/product_catalog?replicaSet=rs0&directConnection=true
FILE_SERVICE_INTERNAL_URL=http://file-service.flash-sale-dev.svc.cluster.local:3005
```

### Search

```dotenv
PORT=3003
INDEX_READ_ALIAS=products_read
INDEX_WRITE_ALIAS=products_write
KAFKA_CONSUMER_GROUP=search-service-v1
```

### Inventory

```dotenv
PORT=3004
DATABASE_URL=postgres://inventory_app:<password>@postgres.flash-sale-infra.svc.cluster.local:5432/inventory
PRODUCT_CATALOG_INTERNAL_URL=http://product-catalog-service.flash-sale-dev.svc.cluster.local:3002
KAFKA_CONSUMER_GROUP=inventory-service-v1
```

### File

```dotenv
PORT=3005
DATABASE_URL=postgres://file_app:<password>@postgres.flash-sale-infra.svc.cluster.local:5432/file
STORAGE_BUCKET=flash-sale-files-dev
STORAGE_REGION=ap-southeast-1
STORAGE_ENDPOINT=http://localstack.flash-sale-infra.svc.cluster.local:4566
STORAGE_FORCE_PATH_STYLE=true
KAFKA_CONSUMER_GROUP=file-service-v1
```

`STORAGE_ENDPOINT` nội bộ không phù hợp làm hostname trong pre-signed URL gửi cho browser. Trước khi tích hợp upload từ frontend, phải expose LocalStack qua HTTPS và cấu hình endpoint/CDN URL theo domain mà browser truy cập được.

## Database users

PostgreSQL init script tạo ba database và ba application user:

- `identity_app` → database `identity`
- `inventory_app` → database `inventory`
- `file_app` → database `file`

Password được đọc từ secret `flash-sale-infra-credentials`. Overlay production phải thay bằng secret manager hoặc External Secrets.

