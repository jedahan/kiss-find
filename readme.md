# kiss-find

tool for indexing and searching as many kiss repositories as possible.

# client

You can install kiss-find on kiss with the package in this repo.

    cd dist/kiss/kiss-find
    kiss build && kiss install

# build

This repository contains the tools used to create the kiss-find database.

It requires `git`, `python3` and `jq`.

Optional support for github repo discovery is enabled by being logged in with the github `gh` cli.

Run `make clean; make` to generate a fresh db for kiss-find.

# adding a repository

If your repository is on github, just add the 'kiss-repo' topic and it should be automatically picked up.

If your repository is anywhere else, make a PR to add it to `repo_safelist`.

# removing a repository

If you would not like your repository indexed, send a PR to add it to `repo_blocklist`.

# credits

Created by [@admicos](https://ecmelberk.com), maintained by [@jedahan](https://github.com/jedahan)
