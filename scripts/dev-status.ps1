$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "dev-common.ps1")

Assert-DevelopmentLayout
Set-BramaDevelopmentEnvironment

Write-Output "=== brama ==="
Invoke-BramaCompose -ComposeArguments @("ps")
Write-Output "=== SZOP ==="
Invoke-AppCompose -App szop -ComposeArguments @("ps")
Write-Output "=== OPOS ==="
Invoke-AppCompose -App opos -ComposeArguments @("ps")
