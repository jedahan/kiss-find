#!/bin/sh -e
# Search for packages across every known repository

VERSION="1"
DB_PATH="${XDG_CACHE_HOME:-${HOME}/.cache}"/kiss-find/db
UPDATE_URL="https://github.com/jedahan/kiss-find/releases/download/latest/kiss-find"

mkdir -p "$(dirname "${DB_PATH}")"

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "kiss-find ${VERSION}"
  echo "$0 <query> :: Search for packages across every known repository"
  echo "$0 -u      :: Update package database"
  exit
elif [ "$1" = "-u" ]; then
  command -v curl >/dev/null || command -v wget >/dev/null || {
    echo "please install curl or wget to update" >&2 && exit
  }

  command -v curl >/dev/null && \
    command curl --location --silent \
      --user-agent "kiss-find/${VERSION}" \
      "${UPDATE_URL}" \
      --output "${DB_PATH}" || \
    command wget -U "kiss-find/${VERSION}" "${UPDATE_URL}" -O "${DB_PATH}"

  echo ":: Update done" >&2
  exit
fi

set -u # was required for the -z check above, can enable now

if [ ! -f "${DB_PATH}" ]; then
  echo ":: Please run with '-u' to update" >&2
  exit
fi

_grep=${KISS_FIND_GREP:-"$(
  command -v rg ||
  command -v ag ||
  command -v ack ||
  command -v grep
)"} || _grep=grep

if [ -t 1 ]; then
  "$_grep" "$@" "${DB_PATH}" | sort | column -t -s','
else
  "$_grep" "$@" "${DB_PATH}" | sort
fi
