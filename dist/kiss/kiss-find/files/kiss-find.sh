#!/bin/sh -e
# Search for packages across every known repository

VERSION="1"
DB_PATH="$HOME/.cache/kiss-find/db.gz"
UPDATE_URL="https://github.com/jedahan/kiss-find/releases/download/0.1.0/db.gz"

mkdir -p "$(dirname "$DB_PATH")"

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "kiss-find $VERSION"
	echo "$0 <query> :: Search for packages across every known repository"
	echo "$0 -u      :: Update package database"
	exit
elif [ "$1" = "-u" ]; then
	command -v wget && wget -U "kiss-find/$VERSION" "$UPDATE_URL" -O "$DB_PATH"
	echo ":: Update done"
	exit
fi

set -u # was required for the -z check above, can enable now

if [ ! -f "$DB_PATH" ]; then
	echo ":: Please run with '-u' to update"
	exit
fi

zcat "$DB_PATH" | jq --arg query "$@" \
  'to_entries[] | select(.key | ascii_downcase | contains($query | ascii_downcase))'
