$ErrorActionPreference = "Stop"

$routes = @(
    @{ Name = "SZOP"; HostName = "szop.localhost" },
    @{ Name = "OPOS"; HostName = "opos.localhost" }
)

$client = [System.Net.Http.HttpClient]::new()
try {
    foreach ($route in $routes) {
        $request = [System.Net.Http.HttpRequestMessage]::new(
            [System.Net.Http.HttpMethod]::Get,
            "http://127.0.0.1:8080/auth/login"
        )
        $request.Headers.Host = $route.HostName
        $response = $client.SendAsync($request).GetAwaiter().GetResult()
        try {
            if (-not $response.IsSuccessStatusCode) {
                throw "$($route.Name) zwrócił HTTP $([int]$response.StatusCode)."
            }
            Write-Output "OK $($route.Name): HTTP $([int]$response.StatusCode) przez bramę"
        } finally {
            $response.Dispose()
            $request.Dispose()
        }
    }
} finally {
    $client.Dispose()
}
