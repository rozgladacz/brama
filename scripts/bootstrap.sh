#!/bin/sh
set -eu

ensure_network() {
    if ! docker network inspect "$1" >/dev/null 2>&1; then
        docker network create "$1" >/dev/null
        echo "Utworzono sieć: $1"
    fi
}

ensure_volume() {
    if ! docker volume inspect "$1" >/dev/null 2>&1; then
        docker volume create "$1" >/dev/null
        echo "Utworzono wolumen: $1"
    fi
}

ensure_network "${SZOP_EDGE_NETWORK:-brama-szop}"
ensure_network "${OPOS_EDGE_NETWORK:-brama-opos}"
ensure_volume "${CADDY_DATA_VOLUME:-szop_caddy_data}"
ensure_volume "${CADDY_CONFIG_VOLUME:-szop_caddy_config}"
