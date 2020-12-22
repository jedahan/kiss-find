all: kiss-find.gz

.PHONY: clean

clean:
	rm -f lib/repo_list lib/packages.json kiss-find.gz

lib/repo_list:
	lib/sync_latest_repos.sh > lib/repo_list

lib/packages.json: lib/repo_list
	lib/generate_fat_db.sh lib/repo_list > lib/packages.json

kiss-find.gz: lib/packages.json
	lib/crush_db.py lib/packages.json | gzip > kiss-find.gz
