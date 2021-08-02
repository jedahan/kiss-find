.PHONY: clean install install-cli install-db release
XDG_CONFIG_HOME := $(HOME)/.config

all: docs/db.csv docs/core.csv

clean:
	rm -f docs/db.csv docs/core.csv docs/static.html

install: install-cli install-db

install-cli:
	cd dist/kiss/kiss-find
	kiss build
	kiss install

install-db: docs/db.csv
	install -Dm644 -t $(XDG_CONFIG_HOME)/kiss-find docs/db.csv

docs/core.csv: docs/db.csv
	grep 'https://github.com/kisslinux/repo' docs/db.csv > docs/core.csv

docs/db.csv:
	lib/sync_latest_repos.sh | lib/generate_db.sh > docs/db.csv

release: docs/db.csv docs/core.csv docs/static.html
	git diff --quiet
	if [ $$? -ne 0 ]; then \
		git add docs/db.csv docs/core.csv docs/static.html; \
		git commit --message 'update package databases'; \
		git push origin HEAD; \
	fi

docs/static.html: docs/db.csv docs/style.css docs/search.js lib/render.js
	tjs lib/render.js < docs/db.csv > docs/static.html
