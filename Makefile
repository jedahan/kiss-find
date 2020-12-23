.PHONY: clean db install install-cli install-db
XDG_CONFIG_HOME := $(HOME)/.config

all: db

clean:
	rm -f lib/repo_list lib/packages.json kiss-find.gz

db: kiss-find.gz

install-cli:
	cd dist/kiss/kiss-find && \
	kiss build && \
	kiss install

install: install-cli install-db

install-db: kiss-find.gz
	install -Dm644 -t $(XDG_CONFIG_HOME)/kiss-find db.gz

lib/repo_list:
	lib/sync_latest_repos.sh > lib/repo_list

lib/packages.json: lib/repo_list
	lib/generate_fat_db.sh lib/repo_list > lib/packages.json

kiss-find.gz: lib/packages.json
	lib/crush_db.py lib/packages.json | gzip > kiss-find.gz
