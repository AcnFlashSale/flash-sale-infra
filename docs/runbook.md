# Development runbook

## Kiểm tra nhanh

```powershell
kubectl get pods,pvc -n flash-sale-infra
kubectl get jobs -n flash-sale-infra
kubectl get events -n flash-sale-infra --sort-by=.metadata.creationTimestamp
```

Pod hợp lệ phải ở trạng thái `Running` và các init job phải `Complete`.

## Xem log

```powershell
kubectl logs -n flash-sale-infra statefulset/postgres
kubectl logs -n flash-sale-infra statefulset/mongodb
kubectl logs -n flash-sale-infra statefulset/kafka
kubectl logs -n flash-sale-infra statefulset/elasticsearch
kubectl logs -n flash-sale-infra deployment/kibana
```

## Truy cập tạm thời từ máy local

```powershell
kubectl port-forward -n flash-sale-infra service/postgres 5432:5432
kubectl port-forward -n flash-sale-infra service/mongodb 27017:27017
kubectl port-forward -n flash-sale-infra service/redis 6379:6379
kubectl port-forward -n flash-sale-infra service/kafka 9092:9092
kubectl port-forward -n flash-sale-infra service/elasticsearch 9200:9200
kubectl port-forward -n flash-sale-infra service/kibana 5601:5601
kubectl port-forward -n flash-sale-infra service/localstack 4566:4566
```

Kafka quảng bá Kubernetes DNS nội bộ nên client chạy ngoài cluster không thể sử dụng ổn định chỉ bằng port-forward. Khi cần local client kết nối Kafka, thêm listener riêng qua VPN/private ingress thay vì expose broker công khai.

## Restart an toàn

```powershell
kubectl rollout restart -n flash-sale-infra statefulset/postgres
kubectl rollout status -n flash-sale-infra statefulset/postgres --timeout=5m
```

Chỉ restart từng stateful workload. Không restart đồng thời tất cả khi đang điều tra lỗi.

## Dung lượng

```powershell
kubectl get pvc -n flash-sale-infra
kubectl exec -n flash-sale-infra postgres-0 -- df -h /var/lib/postgresql/data
kubectl exec -n flash-sale-infra elasticsearch-0 -- df -h /usr/share/elasticsearch/data
```

## Backup development

Trước thay đổi lớn, tạo snapshot disk/VM. Với dữ liệu cần giữ, dùng backup logic (`pg_dump`, `mongodump`) ngoài snapshot volume. Chưa có automated backup trong base này.

## Xóa môi trường

Xóa namespace sẽ xóa workload và có thể xóa luôn PVC tùy storage provisioner. Đây là thao tác phá hủy dữ liệu, vì vậy repo không cung cấp script tự động. Kiểm tra và backup PVC trước khi thực hiện thủ công.

