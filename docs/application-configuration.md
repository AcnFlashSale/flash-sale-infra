# Application Configuration

Biến môi trường để backend kết nối tới hạ tầng trong Kubernetes.

## Shared configuration

```env
POSTGRES_HOST=postgresql.flash-sale-data.svc.cluster.local
POSTGRES_PORT=5432

MONGODB_HOST=mongodb.flash-sale-data.svc.cluster.local
MONGODB_PORT=27017
MONGODB_REPLICA_SET=rs0

REDIS_HOST=redis.flash-sale-data.svc.cluster.local
REDIS_PORT=6379

KAFKA_BROKERS=kafka.flash-sale-platform.svc.cluster.local:9092

ELASTICSEARCH_URL=http://elasticsearch.flash-sale-observability.svc.cluster.local:9200

S3_ENDPOINT=http://localstack.flash-sale-platform.svc.cluster.local:4566
S3_REGION=ap-southeast-1
S3_FORCE_PATH_STYLE=true
```

## PostgreSQL databases

| Service | Database | User |
|---|---|---|
| Auth | `auth_db` | `auth_user` |
| Product | `product_db` | `product_user` |
| Inventory | `inventory_db` | `inventory_user` |
| Order | `order_db` | `order_user` |
| Payment | `payment_db` | `payment_user` |

Password được lấy từ Secret `flash-sale-infra-credentials` trong namespace `flash-sale-data`.

## MongoDB connection

```env
MONGODB_URI=mongodb://mongodb.flash-sale-data.svc.cluster.local:27017/<database>?replicaSet=rs0
```

## Local access

Các hostname nội bộ chỉ dùng được trong cluster. Khi chạy backend ở máy local, dùng `kubectl port-forward` và đổi host thành `localhost`.

Ví dụ:

```powershell
kubectl -n flash-sale-data port-forward svc/postgresql 5432:5432
kubectl -n flash-sale-platform port-forward svc/kafka 9092:9092
```

## Reference

- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
