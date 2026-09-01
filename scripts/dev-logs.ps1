param(
    [ValidateSet("brama", "szop", "opos")]
    [string]$Target = "brama",
    [int]$Tail = 100
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "dev-common.ps1")

Assert-DevelopmentLayout
Set-BramaDevelopmentEnvironment

if ($Target -eq "brama") {
    Invoke-BramaCompose -ComposeArguments @("logs", "--follow", "--tail", "$Tail")
} else {
    Invoke-AppCompose -App $Target -ComposeArguments @("logs", "--follow", "--tail", "$Tail", "$Target-app")
}
