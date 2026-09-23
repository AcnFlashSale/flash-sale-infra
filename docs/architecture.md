# Architecture

Hạ tầng development chạy các dependency dùng chung trên Kubernetes.

## Namespaces

| Namespace | Components |
|---|---|
| `flash-sale-data` | PostgreSQL, MongoDB, Redis |
| `flash-sale-platform` | Kafka, LocalStack |
| `flash-sale-observability` | Elasticsearch, Kibana |

## Components

| Component | Workload | Service | Notes |
|---|---|---|---|
| PostgreSQL | StatefulSet | `postgresql` | Single instance |
| MongoDB | StatefulSet | `mongodb` | Replica set `rs0`, 1 member |
| Redis | StatefulSet | `redis` | AOF enabled |
| Kafka | StatefulSet | `kafka` | KRaft, 1 broker/controller |
| Elasticsearch | StatefulSet | `elasticsearch` | Single node |
| Kibana | Deployment | `kibana` | Connects to Elasticsearch |
| LocalStack | StatefulSet | `localstack` | S3-compatible storage |

## Internal endpoints

```text
postgresql.flash-sale-data.svc.cluster.local:5432
mongodb.flash-sale-data.svc.cluster.local:27017
redis.flash-sale-data.svc.cluster.local:6379
kafka.flash-sale-platform.svc.cluster.local:9092
elasticsearch.flash-sale-observability.svc.cluster.local:9200
kibana.flash-sale-observability.svc.cluster.local:5601
localstack.flash-sale-platform.svc.cluster.local:4566
```

## Deployment flow

```text
platform namespaces
        ↓
credentials Secret
        ↓
data + platform services
        ↓
observability services
```

## References

- [MongoDB replication](https://www.mongodb.com/docs/manual/replication/)
- [Kafka KRaft](https://kafka.apache.org/42/operations/kraft/)
- [K3s storage](https://docs.k3s.io/add-ons/storage)
