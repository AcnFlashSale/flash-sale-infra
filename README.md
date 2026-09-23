# Flash Sale Infrastructure

Infrastructure-as-code cho hệ thống Flash Sale. Phiên bản đầu tiên dựng một môi trường development trên Kubernetes/k3s single-node, chạy toàn bộ stateful infrastructure trong cluster.

Manifest được quản lý bằng Kustomize, có sẵn trong `kubectl`; repo không yêu cầu Helm.

## Phạm vi hiện tại

| Thành phần | Kiểu workload | Service |
| --- | --- | --- |
| PostgreSQL 17 | StatefulSet | `postgres.flash-sale-infra:5432` |
| MongoDB 8 replica set | StatefulSet | `mongodb-0.mongodb.flash-sale-infra:27017` |
| Redis 8 | StatefulSet | `redis.flash-sale-infra:6379` |
| Kafka 4 KRaft | StatefulSet | `kafka.flash-sale-infra:9092` |
| Elasticsearch 9 | StatefulSet | `elasticsearch.flash-sale-infra:9200` |
| Kibana 9 | Deployment | `kibana.flash-sale-infra:5601` |
| LocalStack S3 | StatefulSet | `localstack.flash-sale-infra:4566` |

Đây là topology development, không phải cấu hình HA production. Tất cả stateful components chỉ có một replica và cùng phụ thuộc vào một Kubernetes node.

## Cấu trúc

```text
.
├── docs/
│   ├── architecture.md
│   ├── application-configuration.md
│   └── runbook.md
├── kubernetes/
│   ├── base/
│   │   ├── platform/
│   │   └── infra/
│   └── overlays/
│       └── dev/
├── scripts/
│   ├── bootstrap-dev.ps1
│   └── validate.ps1
└── terraform/
    └── README.md
```

## Yêu cầu

- Một Kubernetes cluster có default StorageClass. k3s mặc định dùng `local-path`.
- `kubectl` đã cấu hình đúng context.
- Tối thiểu 8 vCPU, 16 GB RAM và 100 GB SSD; khuyến nghị 24 GB RAM cho toàn bộ stack.
- PowerShell 7 nếu dùng script đi kèm.

## Khởi tạo development environment

Kiểm tra manifest trước:

```powershell
.\scripts\validate.ps1
```

Hoặc render trực tiếp để review:

```powershell
kubectl kustomize kubernetes/overlays/dev
```

Deploy namespace, secret development và toàn bộ infrastructure:

```powershell
.\scripts\bootstrap-dev.ps1
```

Script tương đương với việc tạo credential secret development rồi chạy:

```powershell
kubectl apply -k kubernetes/overlays/dev
```

Theo dõi trạng thái:

```powershell
kubectl get pods,pvc -n flash-sale-infra
```

Truy cập Kibana tạm thời:

```powershell
kubectl port-forward -n flash-sale-infra service/kibana 5601:5601
```

## Quy ước an toàn

- Không expose database, Redis, Kafka hoặc Elasticsearch bằng `NodePort`/`LoadBalancer`.
- Credentials mặc định trong script chỉ dành cho dev cluster private. Hãy truyền giá trị khác khi cluster có nhiều người dùng.
- Không commit secret thật. File `*.secret.yaml`, thư mục `secrets/` và Terraform state đã được ignore.
- Backup volume trước khi nâng version stateful component.
- Production phải dùng topology HA hoặc managed services; không reuse nguyên overlay `dev`.

## Bước tiếp theo

1. Thêm Dockerfile và CI build image cho backend/frontend.
2. Thêm manifest ứng dụng vào namespace `flash-sale-dev`.
3. Thêm Ingress, DNS và TLS sau khi chọn domain.
4. Thêm observability và GitOps sau khi application images ổn định.
5. Chọn cloud/VPS provider trước khi triển khai Terraform.
