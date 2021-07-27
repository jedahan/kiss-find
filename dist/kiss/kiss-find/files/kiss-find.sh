#!/bin/sh -e
# Search for packages across every known repository

VERSION="2"
DB_PATH="${XDG_CACHE_HOME:-${HOME}/.cache}"/kiss-find/db
UPDATE_URL="https://github.com/jedahan/kiss-find/releases/download/latest/db"
mkdir -p "$(dirname "${DB_PATH}")"

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

update() {
  command -v curl >/dev/null || command -v wget >/dev/null || {
    echo "please install curl or wget to update" >&2 && exit
  }

  if command -v curl >/dev/null 2>&1
  then
    command curl --location --silent --user-agent "kiss-find/${VERSION}" "${UPDATE_URL}" --output "${DB_PATH}" \
  else
    command wget -U "kiss-find/${VERSION}" "${UPDATE_URL}" -O "${DB_PATH}"
  fi

  echo ":: Update done" >&2 && exit
}

[ -f "${DB_PATH}" ] && (( $(date -r ~/.cache/kiss-find/db -v+7d +%s) < $(date +%s) )) && show_update
case "$1" in
  "" | "-h" | "--help")
    show_help; exit ;;
  "-u" | "--update")
    update; exit ;;
esac
[ ! -f "${DB_PATH}" ] && show_update && exit

_grep=${KISS_FIND_GREP:-"$(command -v rg || command -v ag || command -v ack || command -v grep)"} ||
  echo "no grep found" >&2 && exit

results=$("$_grep" "$@" "${DB_PATH}" | sort)
[ -t 1 ] && echo "$results" | column -t -s',' || echo "$results"
