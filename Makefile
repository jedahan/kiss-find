.PHONY: clean install install-cli install-db release
XDG_CONFIG_HOME := $(HOME)/.config

all: docs/db.csv docs/core.csv

clean:
	rm -f docs/db.csv docs/core.csv docs/index.html

install: install-cli install-db

install-cli:
	cd dist/kiss/kiss-find && \
	kiss build && \
	kiss install

install-db: docs/db.csv
	install -Dm644 -t $(XDG_CONFIG_HOME)/kiss-find docs/db.csv

docs/core.csv: docs/db.csv
	grep 'https://github.com/kisslinux/repo' docs/db.csv > docs/core.csv

docs/db.csv:
	lib/sync_latest_repos.sh | lib/generate_db.sh > docs/db.csv

release: docs/db.csv docs/core.csv docs/index.html
	git add docs/db.csv docs/core.csv docs/index.html; \
	git commit --message 'update package databases and website'; \
	git push origin HEAD;

txiki.js/build/tjs:
	git clone --recursive https://github.com/saghul/txiki.js --shallow-submodules && make -C txiki.js

docs/index.html: docs/db.csv docs/style.css docs/search.js lib/render.js txiki.js/build/tjs
	txiki.js/build/tjs lib/render.js < docs/db.csv > docs/index.html
