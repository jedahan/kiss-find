.PHONY: clean db install install-cli install-db
XDG_CONFIG_HOME := $(HOME)/.config

all: build/db

clean:
	rm -rf build/

install-cli:
	cd dist/kiss/kiss-find && \
	kiss build && \
	kiss install

install: install-cli install-db

install-db: build/db
	install -Dm644 -t $(XDG_CONFIG_HOME)/kiss-find build/db

build/db:
	rm -rf build && mkdir -p build
	lib/sync_latest_repos.sh > build/repo_list
	lib/generate_db.sh build/repo_list > build/db
