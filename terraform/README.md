# Terraform

Thư mục này dành cho provisioning VM, firewall, DNS và volume sau khi chọn nhà cung cấp hạ tầng.

Không tạo module cloud giả định trong base ban đầu vì provider, region, network và mô hình DNS chưa được quyết định. Khi chọn provider, cấu trúc đề xuất là:

```text
terraform/
├── modules/
│   ├── network/
│   ├── k3s-node/
│   └── dns/
└── environments/
    ├── dev/
    └── production/
```

Terraform state không được commit vào Git. Production nên dùng remote backend có locking và encryption.

