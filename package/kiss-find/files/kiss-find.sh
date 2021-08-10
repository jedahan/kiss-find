#!/bin/sh -e
# Search for packages across every known repository

VERSION="2"
DB_PATH="${XDG_CACHE_HOME:-${HOME}/.cache}"/kiss-find/db.csv
UPDATE_URL="https://jedahan.com/kiss-find/db.csv"
UPDATE_MESSAGE=':: Please run `kiss find --update` to download the latest database'
UPDATE_INTERVAL=$((7 * 24 * 60 * 60)) # 7 days
mkdir -p "$(dirname "${DB_PATH}")"

help() {
  echo "kiss-find ${VERSION}"
  echo "$0 <query>         :: Search for packages across every known repository"
  echo "$0 -u, --update    :: Update package database"
  echo "$0 -h, --help      :: Show this help"
  exit
}

log() {
  echo "$@" >&2
}

die() {
  log "$@"
  exit 1
}

update() {
  if command -v curl >/dev/null 2>&1; then
    command curl --location --silent --user-agent "kiss-find/${VERSION}" "${UPDATE_URL}" --output "${DB_PATH}"
  elif command -v wget >/dev/null 2>&1; then
    command wget -U "kiss-find/${VERSION}" "${UPDATE_URL}" -O "${DB_PATH}"
  else
    die 'please install curl or wget to update'
  fi

  log ':: Update done'
  exit
}

case "$1" in
"" | "-h" | "--help") help ;;
"-u" | "--update") update ;;
esac
if [ -f "${DB_PATH}" ] && [ "$(($(date -r "${DB_PATH}" +%s) + UPDATE_INTERVAL))" -lt "$(date +%s)" ]; then log "$UPDATE_MESSAGE"; fi
if [ ! -f "${DB_PATH}" ]; then die "$UPDATE_MESSAGE"; fi

_grep=${KISS_FIND_GREP:-"$(command -v rg || command -v ag || command -v ack || command -v grep)"} || die "no grep found"
results=$("$_grep" "$@" "${DB_PATH}" | sort)
if [ -t 0 ]; then echo "$results"; else echo "$results" | column -t -s','; fi
