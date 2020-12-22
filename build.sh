#!/bin/sh -e

starttime=$(date -u +"%Y-%m-%dT%H:%M")
lib/sync_latest_repos.sh > ../repo_list
lib/generate_fat_db.sh ../repo_list > ../packages.json
lib/crush_db.py ../packages.json | gzip > kiss-find-"${starttime}".gz

rm packages.json
