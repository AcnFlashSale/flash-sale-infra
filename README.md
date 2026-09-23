# Flash Sale Infrastructure

Kubernetes manifests cho môi trường development của hệ thống Flash Sale.

## Components

| Component | Version | Namespace | Storage |
|---|---:|---|---|
| PostgreSQL | 16 | `flash-sale-data` | PVC 10Gi |
| MongoDB | 7 | `flash-sale-data` | PVC 10Gi |
| Redis | 7 | `flash-sale-data` | PVC 2Gi |
| Kafka | 3.9 | `flash-sale-platform` | PVC 10Gi |
| Elasticsearch | 8.17 | `flash-sale-observability` | PVC 10Gi |
| Kibana | 8.17 | `flash-sale-observability` | - |
| LocalStack | 4 | `flash-sale-platform` | PVC 5Gi |

## Structure

```text
.
├── kubernetes/
│   ├── base/
│   │   ├── platform/
│   │   └── infra/
│   └── overlays/dev/
├── docs/
└── terraform/
```

## Commands

Install K3s on Ubuntu:

```bash
curl -sfL https://get.k3s.io | sh -
```

Validate and deploy manifests:

```bash
kubectl kustomize kubernetes/overlays/dev >/dev/null
kubectl apply -k kubernetes/base/platform
kubectl apply -k kubernetes/overlays/dev
```

Check status:

```bash
kubectl get pods,pvc -A
```

## Documents

- [Architecture](docs/architecture.md)
- [Application configuration](docs/application-configuration.md)
- [Runbook](docs/runbook.md)

## References

- [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
