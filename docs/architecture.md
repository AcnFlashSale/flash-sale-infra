# Kiến trúc development

## Mục tiêu

Môi trường dev phải giảm tải cho máy lập trình viên, giữ cách triển khai gần production và cho phép các service giao tiếp bằng Kubernetes DNS.

```text
Internet / VPN
       |
       v
Kubernetes Ingress (giai đoạn tiếp theo)
       |
       +-- buyer-web
       +-- seller-web
       |
       +-- backend services --------------------------+
                                                       |
                           namespace: flash-sale-infra |
  +------------+  +---------+  +-------+  +---------+ |
  | PostgreSQL |  | MongoDB |  | Redis |  |  Kafka  | |
  +------------+  +---------+  +-------+  +---------+ |
  +---------------+  +--------+  +------------+       |
  | Elasticsearch |  | Kibana |  | LocalStack | <-----+
  +---------------+  +--------+  +------------+
```

## Namespace

| Namespace | Trách nhiệm |
| --- | --- |
| `flash-sale-infra` | Database, cache, broker, search và object storage |
| `flash-sale-dev` | Backend và frontend development workloads |
| `flash-sale-observability` | Metrics, logs và traces trong giai đoạn sau |

## Storage

Mỗi stateful workload có PersistentVolumeClaim riêng. Trên single-node k3s, volume thường nằm trên chính VM, vì vậy Kubernetes restart pod được nhưng không bảo vệ dữ liệu khi VM hoặc disk hỏng.

| Workload | PVC mặc định |
| --- | --- |
| PostgreSQL | 20 GiB |
| MongoDB | 20 GiB |
| Redis | 5 GiB |
| Kafka | 20 GiB |
| Elasticsearch | 30 GiB |
| LocalStack | 10 GiB |

## Network

Infrastructure dùng ClusterIP và chỉ truy cập được từ trong cluster. Application sử dụng các địa chỉ:

```text
postgres.flash-sale-infra.svc.cluster.local:5432
mongodb-0.mongodb.flash-sale-infra.svc.cluster.local:27017
redis.flash-sale-infra.svc.cluster.local:6379
kafka.flash-sale-infra.svc.cluster.local:9092
elasticsearch.flash-sale-infra.svc.cluster.local:9200
localstack.flash-sale-infra.svc.cluster.local:4566
```

Kibana cũng mặc định là ClusterIP và chỉ nên truy cập bằng VPN hoặc `kubectl port-forward`.

## Giới hạn của dev topology

- Single-node và single replica: không có high availability.
- Kafka replication factor bằng 1.
- MongoDB replica set chỉ có một member để hỗ trợ transaction, không cung cấp failover.
- Elasticsearch chạy một node và tắt security.
- MongoDB, Redis, Kafka và Elasticsearch chưa bật authentication vì chúng không được expose ra ngoài cluster.
- LocalStack chỉ mô phỏng S3; production nên dùng object storage thật.

