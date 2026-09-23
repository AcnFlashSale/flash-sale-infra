# Development Runbook

Các lệnh cần dùng khi deploy và kiểm tra hạ tầng development.

## Prerequisites

- Kubernetes cluster có StorageClass mặc định
- `kubectl`
- Kustomize support trong `kubectl`

## Install K3s

```bash
curl -sfL https://get.k3s.io | sh -
```

## Validate

```bash
kubectl kustomize kubernetes/overlays/dev >/dev/null
```

## Deploy

```bash
kubectl apply -k kubernetes/base/platform
kubectl -n flash-sale-infra create secret generic flash-sale-infra-credentials \
  --from-literal=POSTGRES_SUPERUSER_PASSWORD=<password> \
  --from-literal=IDENTITY_DB_PASSWORD=<password> \
  --from-literal=INVENTORY_DB_PASSWORD=<password> \
  --from-literal=FILE_DB_PASSWORD=<password>
kubectl apply -k kubernetes/overlays/dev
```

## Status

```powershell
kubectl get pods,pvc -A
kubectl get statefulset,deployment -A
kubectl get jobs -A
```

## Logs

```powershell
kubectl -n flash-sale-data logs statefulset/postgresql
kubectl -n flash-sale-data logs statefulset/mongodb
kubectl -n flash-sale-platform logs statefulset/kafka
kubectl -n flash-sale-observability logs statefulset/elasticsearch
```

## Local access

```powershell
kubectl -n flash-sale-data port-forward svc/postgresql 5432:5432
kubectl -n flash-sale-data port-forward svc/mongodb 27017:27017
kubectl -n flash-sale-data port-forward svc/redis 6379:6379
kubectl -n flash-sale-platform port-forward svc/kafka 9092:9092
kubectl -n flash-sale-platform port-forward svc/localstack 4566:4566
kubectl -n flash-sale-observability port-forward svc/elasticsearch 9200:9200
kubectl -n flash-sale-observability port-forward svc/kibana 5601:5601
```

## Common issues

| Symptom | Check |
|---|---|
| Pod `Pending` | `kubectl describe pod <pod> -n <namespace>` and PVC/StorageClass |
| `CrashLoopBackOff` | Container logs and Secret values |
| MongoDB job failed | MongoDB pod readiness and replica-set status |
| Kafka not ready | Kafka logs and PVC permissions |
| Elasticsearch restart | Node memory and `vm.max_map_count` |
| Service unreachable | Namespace, Service name and NetworkPolicy |

## Cleanup

Remove workloads but keep PVCs:

```powershell
kubectl delete -k kubernetes/overlays/dev
```

PVC deletion removes development data and must be executed manually.
