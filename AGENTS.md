# AGENTS.md

`brama` zawiera wyłącznie wspólną warstwę wejściową SZOP i OPOS.

## Inwarianty

1. Tylko Caddy publikuje porty hosta 80/443.
2. SZOP i OPOS korzystają z osobnych sieci edge; nie łącz ich w jedną sieć.
3. Nie zapisuj `.env`, tokenów DuckDNS, kluczy ani danych aplikacji w repozytorium.
4. Nie przenoś tu kodu biznesowego aplikacji.
5. Przed wdrożeniem uruchom `docker compose config` i `caddy validate`.
6. `docker compose down` nie może usuwać zewnętrznych wolumenów certyfikatów.
