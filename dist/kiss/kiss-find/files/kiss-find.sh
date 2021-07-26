#!/bin/sh -e
# Search for packages across every known repository

VERSION="2"
DB_PATH="${XDG_CACHE_HOME:-${HOME}/.cache}"/kiss-find/db
UPDATE_URL="https://github.com/jedahan/kiss-find/releases/download/latest/db"

mkdir -p "$(dirname "${DB_PATH}")"

[ ! -f "${DB_PATH}" ] && show_update && exit
(( $(date -r ~/.cache/kiss-find/db -v+7d +%s) < $(date +%s) )) && show_update

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then show_help; exit; fi
if [ "$1" = "-u" ] || [ "$1" = "--update" ]; then update; exit; fi

update() {
  command -v curl >/dev/null || command -v wget >/dev/null || {
    echo "please install curl or wget to update" >&2 && exit
  }

  command -v curl >/dev/null \
    && command curl --location --silent --user-agent "kiss-find/${VERSION}" "${UPDATE_URL}" --output "${DB_PATH}" \
    || command wget -U "kiss-find/${VERSION}" "${UPDATE_URL}" -O "${DB_PATH}"

  echo ":: Update done" >&2 && exit
}

show_help() {
  echo "kiss-find ${VERSION}"
  echo "$0 <query>         :: Search for packages across every known repository"
  echo "$0 -u, --update    :: Update package database"
  echo "$0 -h, --help      :: Show this help"
  exit
}

show_update() {
  echo ':: Please run `kiss find --update` to download the latest database' >&2
  echo >&2
}

_grep=${KISS_FIND_GREP:-"$(command -v rg || command -v ag || command -v ack || command -v grep)"}
[ -z "$grep" ] && echo "no grep found" >&2 && exit

if [ -t 1 ]; then
  "$_grep" "$@" "${DB_PATH}" | sort | column -t -s','
else
  "$_grep" "$@" "${DB_PATH}" | sort
fi
