.PHONY: clean install install-cli install-db repology
XDG_CONFIG_HOME := $(HOME)/.config
DESTDIR := build
CORE := $(DESTDIR)/core.csv
DB := $(DESTDIR)/db.csv
WEBSITE := $(DESTDIR)/web/index.html
TJS := build/txiki.js/build/tjs

DATABASES := $(DB) $(CORE)

all: $(DATABASES) $(WEBSITE) repology

clean:
	rm -f $(DATABASES) $(WEBSITE)

install: install-cli install-db

install-cli:
	cd package/kiss-find && \
	kiss build && \
	kiss install

install-db: $(DB)
	install -Dm644 -t $(XDG_CONFIG_HOME)/kiss-find $(DB)

$(CORE): $(DB)
	grep 'https://github.com/kisslinux/repo' $(DB) > $(CORE)

$(DB):
	mkdir -p $(DESTDIR); \
	src/db/list_repositories.sh | src/db/build_database.sh > $(DB)

build/txiki.js:
	git clone --recursive https://github.com/saghul/txiki.js --shallow-submodules build/txiki.js

$(TJS): build/txiki.js
	make -C build/txiki.js

build/web/repology:
	mkdir -p build/web/repology

repology: build/web/repology/kiss-linux.json build/web/repology/kiss-community.json

build/web/repology/kiss-linux.json: build/web/repology build/db.csv
	grep 'github.com/kisslinux' build/db.csv \
		| jq --slurp --raw-input --raw-output 'split("\n") | .[0:-1] | map(split(",")) | map({"name": .[0], "version": .[1], "maintainer": .[5]|ltrimstr("\"")|rtrimstr("\"")})' \
		> build/web/repology/kiss-linux.json

build/web/repology/kiss-community.json: build/web/repology build/db.csv
	grep --invert-match 'github.com/kisslinux' build/db.csv \
		| jq --slurp --raw-input --raw-output 'split("\n") | .[0:-1] | map(split(",")) | map({"name": .[0], "version": .[1], "maintainer": .[5]|ltrimstr("\"")|rtrimstr("\""), "description": .[6]|ltrimstr("\"")|rtrimstr("\"") })' \
		> build/web/repology/kiss-community.json

$(WEBSITE): $(DB) src/web/style.css src/web/search.js src/web/sort.js src/web/render.js $(TJS)
	mkdir -p build/web; \
	cp -f build/db.csv build/web/db.csv; \
	$(TJS) src/web/render.js < $(DB) > $(WEBSITE)
