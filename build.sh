#!/bin/sh -e

./generate_fat_db.sh repo_list
./crush_db.py packages.json

gzip crushed.json
mv crushed.json.gz kiss-find.gz

rm packages.json
