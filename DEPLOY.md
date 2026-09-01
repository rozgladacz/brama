# Wdrożenie bramy SZOP/OPOS

## Założenia

- Docker Compose ma wersję 2.24.4 lub nowszą.
- `/srv/brama`, `/srv/szop` i `/srv/opos` są osobnymi checkoutami lub katalogami wdrożeniowymi.
- Aplikacje nie publikują portów hosta i dołączają odpowiednio do `brama-szop` oraz `brama-opos`.
- Tylko `brama` zajmuje TCP 80/443 i UDP 443.
- Bazy oraz backupy pozostają w `/srv/szop/data` i `/srv/opos/data`.

## Preflight bez zmian na serwerze

```bash
docker compose version
docker compose ls
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}'
docker network ls
docker volume ls
docker stats --no-stream
```

Zapisz wynik, wykonaj spójny backup bazy i zachowaj pliki starej bramy pod stałymi nazwami:

```bash
cd /srv/szop
cp docker-compose.yml docker-compose.pre-brama.yml
cp Caddyfile Caddyfile.pre-brama
cp .env .env.pre-brama
```

Ustal faktyczne nazwy wolumenów dotychczasowego Caddy, zwykle `szop_caddy_data` i `szop_caddy_config`.

## Przygotowanie

```bash
cd /srv/brama
cp .env.example .env
# Uzupełnij SZOP_DOMAIN, OPOS_DOMAIN i nazwy wolumenów.
set -a
. ./.env
set +a
./scripts/bootstrap.sh
docker compose config --quiet
docker compose run --rm --no-deps caddy caddy validate --config /etc/caddy/Caddyfile
```

Obie domeny DuckDNS muszą wcześniej wskazywać publiczny adres serwera. Token DuckDNS pozostaje poza repozytorium.

## Cut-over

1. Uruchom `szop-app` i `opos-app` na ich sieciach edge oraz zaczekaj na zdrowy status.
2. Sprawdź z sieci Dockera odpowiedzi `/auth/login` obu aplikacji.
3. Zatrzymaj wyłącznie stary kontener Caddy należący do stosu SZOP.
4. Natychmiast uruchom bramę:

```bash
cd /srv/brama
docker compose up -d --wait
docker compose ps
```

5. Sprawdź obie domeny, certyfikaty, logowanie, zasoby statyczne i nagłówki bezpieczeństwa.

Nie używaj podczas cut-overu `docker compose down -v`, `docker volume rm` ani `--remove-orphans`.

## Rollback bramy

Jeżeli nowa brama nie przejdzie smoke testu:

```bash
cd /srv/brama
docker compose stop caddy
cd /srv/szop
# Odtwórz plik wskazywany przez zachowaną wersję Compose.
cp Caddyfile.pre-brama Caddyfile
docker compose -f docker-compose.pre-brama.yml up -d caddy
```

Rollback nie dotyka kontenerów aplikacji ani baz. Zewnętrzne wolumeny zachowują certyfikaty.

## Niezależna aktualizacja aplikacji

```bash
cd /srv/opos
docker compose pull opos-app opos-backup
docker compose up -d --wait opos-app opos-backup

cd /srv/szop
docker compose pull szop-app szop-backup
docker compose up -d --wait szop-app szop-backup
```

Aktualizacja aplikacji nie wykonuje `docker compose` w `/srv/brama` ani w katalogu drugiej aplikacji. Na produkcji przypinaj wersję obrazu w `.env`; przed zmianą zapisz poprzedni tag lub digest.

## Diagnostyka

```bash
cd /srv/brama
docker compose ps
docker compose logs --tail 100 caddy
docker network inspect brama-szop
docker network inspect brama-opos
```

Logi dostępu znajdują się w zewnętrznym wolumenie Caddy jako `logs/szop-access.log` i `logs/opos-access.log`.
