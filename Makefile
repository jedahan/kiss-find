.PHONY: clean install install-cli install-db release
XDG_CONFIG_HOME := $(HOME)/.config

all: docs/db.csv

clean:
	rm -rf build docs/db.csv

install: install-cli install-db

install-cli:
	cd dist/kiss/kiss-find
	kiss build
	kiss install

install-db: docs/db.csv
	install -Dm644 -t $(XDG_CONFIG_HOME)/kiss-find docs/db.csv

docs/db.csv:
	rm -rf build && mkdir -p build
	lib/sync_latest_repos.sh > build/repo_list
	lib/generate_db.sh build/repo_list > docs/db.csv

release: docs/db.csv
	git add docs/db.csv
	git commit --message 'update pages db'
	git push origin HEAD
