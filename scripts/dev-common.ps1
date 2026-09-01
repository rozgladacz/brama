$script:BramaRoot = Split-Path -Parent $PSScriptRoot
$script:WorkspaceRoot = Split-Path -Parent $script:BramaRoot
$script:SzopRoot = if ($env:SZOP_REPO_PATH) { $env:SZOP_REPO_PATH } else { Join-Path $script:WorkspaceRoot "OPR" }
$script:OposRoot = if ($env:OPOS_REPO_PATH) { $env:OPOS_REPO_PATH } else { Join-Path $script:WorkspaceRoot "opos" }

function Assert-LastExitCode {
    param([string]$Description)
    if ($LASTEXITCODE -ne 0) {
        throw "$Description (kod wyjścia: $LASTEXITCODE)."
    }
}

function Assert-DevelopmentLayout {
    foreach ($path in @($script:BramaRoot, $script:SzopRoot, $script:OposRoot)) {
        if (-not (Test-Path -LiteralPath $path -PathType Container)) {
            throw "Nie znaleziono katalogu: $path"
        }
    }
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker CLI nie jest dostępny w PATH."
    }
    & docker compose version | Out-Null
    Assert-LastExitCode "Docker Compose nie jest dostępny"
}

function Set-BramaDevelopmentEnvironment {
    $env:SZOP_DOMAIN = "szop.localhost"
    $env:OPOS_DOMAIN = "opos.localhost"
    $env:SZOP_EDGE_NETWORK = "brama-szop"
    $env:OPOS_EDGE_NETWORK = "brama-opos"
    $env:CADDY_DATA_VOLUME = "brama-caddy-data-dev"
    $env:CADDY_CONFIG_VOLUME = "brama-caddy-config-dev"
    $env:BRAMA_HTTP_BIND = "127.0.0.1:8080"
    $env:BRAMA_HTTPS_BIND = "127.0.0.1:8443"
    $env:BRAMA_CADDYFILE = "./Caddyfile.local"
}

function Ensure-DockerNetwork {
    param([string]$Name)
    & docker network inspect $Name *> $null
    if ($LASTEXITCODE -ne 0) {
        & docker network create $Name | Out-Null
        Assert-LastExitCode "Nie udało się utworzyć sieci $Name"
    }
}

function Ensure-DockerVolume {
    param([string]$Name)
    & docker volume inspect $Name *> $null
    if ($LASTEXITCODE -ne 0) {
        & docker volume create $Name | Out-Null
        Assert-LastExitCode "Nie udało się utworzyć wolumenu $Name"
    }
}

function Invoke-AppCompose {
    param(
        [ValidateSet("szop", "opos")][string]$App,
        [Parameter(ValueFromRemainingArguments = $true)][string[]]$ComposeArguments
    )

    if ($App -eq "szop") {
        $root = $script:SzopRoot
    } else {
        $root = $script:OposRoot
    }
    $files = @(
        "--project-name", $App,
        "-f", (Join-Path $root "docker-compose.yml"),
        "-f", (Join-Path $root "docker-compose.dev.yml")
    )
    & docker compose @files @ComposeArguments
    Assert-LastExitCode "Polecenie Docker Compose dla $App nie powiodło się"
}

function Invoke-BramaCompose {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$ComposeArguments)
    & docker compose `
        --project-directory $script:BramaRoot `
        --project-name brama `
        -f (Join-Path $script:BramaRoot "docker-compose.yml") `
        @ComposeArguments
    Assert-LastExitCode "Polecenie Docker Compose dla brama nie powiodło się"
}
