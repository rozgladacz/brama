$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "dev-common.ps1")

Assert-DevelopmentLayout
Set-BramaDevelopmentEnvironment

Ensure-DockerNetwork $env:SZOP_EDGE_NETWORK
Ensure-DockerNetwork $env:OPOS_EDGE_NETWORK
Ensure-DockerVolume $env:CADDY_DATA_VOLUME
Ensure-DockerVolume $env:CADDY_CONFIG_VOLUME

Invoke-AppCompose -App szop -ComposeArguments @("up", "-d", "--build", "--wait", "szop-app")
Invoke-AppCompose -App opos -ComposeArguments @("up", "-d", "--build", "--wait", "opos-app")
Invoke-BramaCompose -ComposeArguments @("up", "-d", "--wait")
& (Join-Path $PSScriptRoot "dev-smoke.ps1")

Write-Output "SZOP: http://szop.localhost:8080"
Write-Output "OPOS: http://opos.localhost:8080"
Write-Output "Dostęp bez bramy: http://127.0.0.1:8001 i http://127.0.0.1:8002"
