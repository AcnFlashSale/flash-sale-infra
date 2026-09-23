[CmdletBinding()]
param(
    [string]$PostgresSuperuserPassword = "postgres-dev-change-me",
    [string]$IdentityDatabasePassword = "identity-dev-change-me",
    [string]$InventoryDatabasePassword = "inventory-dev-change-me",
    [string]$FileDatabasePassword = "file-dev-change-me"
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$platformBase = Join-Path $repoRoot "kubernetes\base\platform"
$overlay = Join-Path $repoRoot "kubernetes\overlays\dev"
$namespace = "flash-sale-infra"
$secretName = "flash-sale-infra-credentials"

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl was not found in PATH."
}

Write-Host "Using Kubernetes context:"
& kubectl config current-context
if ($LASTEXITCODE -ne 0) {
    throw "No usable Kubernetes context was found."
}

& kubectl apply -k $platformBase
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create namespaces."
}

& kubectl get secret $secretName -n $namespace *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating development credentials secret."
    & kubectl create secret generic $secretName `
        -n $namespace `
        --from-literal="POSTGRES_SUPERUSER_PASSWORD=$PostgresSuperuserPassword" `
        --from-literal="IDENTITY_DB_PASSWORD=$IdentityDatabasePassword" `
        --from-literal="INVENTORY_DB_PASSWORD=$InventoryDatabasePassword" `
        --from-literal="FILE_DB_PASSWORD=$FileDatabasePassword"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create infrastructure credentials secret."
    }
} else {
    Write-Host "Keeping the existing $secretName secret."
}

& kubectl apply -k $overlay
if ($LASTEXITCODE -ne 0) {
    throw "Failed to apply the development overlay."
}

$statefulSets = @("postgres", "mongodb", "redis", "kafka", "elasticsearch", "localstack")
foreach ($name in $statefulSets) {
    & kubectl rollout status "statefulset/$name" -n $namespace --timeout=10m
    if ($LASTEXITCODE -ne 0) {
        throw "StatefulSet $name did not become ready."
    }
}

& kubectl rollout status deployment/kibana -n $namespace --timeout=10m
if ($LASTEXITCODE -ne 0) {
    throw "Kibana did not become ready."
}

$jobs = @("mongodb-init", "kafka-init", "localstack-init")
foreach ($name in $jobs) {
    & kubectl wait "job/$name" -n $namespace --for=condition=complete --timeout=10m
    if ($LASTEXITCODE -ne 0) {
        throw "Job $name did not complete."
    }
}

Write-Host "Flash Sale development infrastructure is ready."
& kubectl get pods,pvc -n $namespace
