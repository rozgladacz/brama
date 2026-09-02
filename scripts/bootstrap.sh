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

ensure_storage() {
    alias_name=$1
    volume_name=$2
    mount_source=$3

    if [ "$mount_source" = "$alias_name" ]; then
        ensure_volume "$volume_name"
        return
    fi

    case "$mount_source" in
        /*|./*|../*)
            if [ ! -d "$mount_source" ]; then
                echo "Brak katalogu bind Caddy: $mount_source" >&2
                exit 1
            fi
            ;;
        *)
            echo "Nieobsługiwane źródło mountu Caddy: $mount_source" >&2
            echo "Użyj aliasu $alias_name albo ścieżki katalogu." >&2
            exit 1
            ;;
    esac
}

ensure_network "${SZOP_EDGE_NETWORK:-brama-szop}"
ensure_network "${OPOS_EDGE_NETWORK:-brama-opos}"
ensure_storage "caddy_data" "${CADDY_DATA_VOLUME:-szop_caddy_data}" "${CADDY_DATA_MOUNT:-caddy_data}"
ensure_storage "caddy_config" "${CADDY_CONFIG_VOLUME:-szop_caddy_config}" "${CADDY_CONFIG_MOUNT:-caddy_config}"
