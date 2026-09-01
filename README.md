# brama

Wspólny reverse proxy dla niezależnych aplikacji SZOP i OPOS. Repozytorium jest właścicielem konfiguracji Caddy, publicznych portów 80/443 oraz dwóch izolowanych sieci Docker. Nie zawiera kodu ani danych aplikacji.

## Lokalny smoke obu aplikacji

Domyślny układ katalogów:

```text
GitHub/
├── brama/
├── OPR/      # SZOP
└── opos/
```

Uruchom w PowerShell:

```powershell
.\scripts\dev-up.ps1
```

- SZOP przez bramę: `http://szop.localhost:8080`
- OPOS przez bramę: `http://opos.localhost:8080`
- bezpośrednio: `http://127.0.0.1:8001` i `http://127.0.0.1:8002`

Pozostałe polecenia:

```powershell
.\scripts\dev-status.ps1
.\scripts\dev-smoke.ps1
.\scripts\dev-logs.ps1 -Target szop
.\scripts\dev-logs.ps1 -Target opos
.\scripts\dev-logs.ps1 -Target brama
.\scripts\dev-down.ps1
```

Skrypty nie usuwają katalogów `.dev-data` ani wolumenów Caddy. Jeśli repozytoria nie są katalogami siostrzanymi, ustaw `SZOP_REPO_PATH` i `OPOS_REPO_PATH`.

Smoke test wysyła żądania do `127.0.0.1:8080` z właściwym nagłówkiem `Host`, więc nie zależy od lokalnego DNS. Jeżeli przeglądarka nie rozpoznaje domen `*.localhost`, użyj bezpośrednich portów 8001/8002 albo dodaj obie nazwy do lokalnego pliku `hosts`.

## Produkcja

Instrukcja migracji i rollbacku znajduje się w [DEPLOY.md](DEPLOY.md). Przed startem skopiuj `.env.example` do `.env`, wpisz obie domeny i potwierdź rzeczywiste nazwy istniejących wolumenów Caddy.
