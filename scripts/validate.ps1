[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$overlay = Join-Path $repoRoot "kubernetes\overlays\dev"

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl was not found in PATH."
}

$rendered = & kubectl kustomize $overlay
if ($LASTEXITCODE -ne 0) {
    throw "Kustomize render failed."
}

if (-not $rendered) {
    throw "Kustomize rendered no resources."
}

$publicService = $rendered | Select-String -Pattern '^\s*type:\s*(NodePort|LoadBalancer)\s*$'
if ($publicService) {
    throw "Dev infrastructure must not expose NodePort or LoadBalancer services."
}

$latestImage = $rendered | Select-String -Pattern '^\s*image:\s*\S+:latest\s*$'
if ($latestImage) {
    throw "Images must use explicit versions, not :latest."
}

$documents = ($rendered | Select-String -Pattern '^---\s*$').Count + 1
Write-Host "Kustomize render passed: $documents Kubernetes resources."

