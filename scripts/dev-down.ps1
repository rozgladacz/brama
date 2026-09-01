$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "dev-common.ps1")

Assert-DevelopmentLayout
Set-BramaDevelopmentEnvironment

Invoke-BramaCompose -ComposeArguments @("down")
Invoke-AppCompose -App opos -ComposeArguments @("down")
Invoke-AppCompose -App szop -ComposeArguments @("down")

Write-Output "Kontenery developerskie zatrzymane. Katalogi .dev-data i wolumeny Caddy zachowano."
