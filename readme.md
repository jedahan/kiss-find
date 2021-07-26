# kiss-find

commandline tool for indexing and searching as many kiss repositories as possible

web version up on https://jedahan.com/kiss-find

database updates every 6 hours

![web client](amf.png)

build and index a new db

    make

install kiss-find and db

    make install

try out kiss-find

    $ kiss find amf
    amfora     1.7.2 2  https://github.com/jedahan/kiss-repo      amfora            a fancy terminal browser for the gemini protocol
    amfora     1.8.0 1  https://github.com/aabacchus/kiss-repo    amfora            a fancy terminal browser for the gemini protocol
    bamf       0.5.4 1  https://github.com/eudaldgr/elementaKISS  extra/bamf
    tinyramfs  git 1    https://github.com/mmatongo/dm            kernel/tinyramfs

# client

You can install kiss-find on kiss with the package in this repo.

    make install-cli
    > cd dist/kiss/kiss-find
    > kiss build && kiss install
    kiss find amf

# build

This repository contains the tools used to create the kiss-find database.

It requires `git` and `grep`

Optional support for github repo discovery is enabled by being logged in with the github `gh` cli, and requires `jq`.

Run `make clean; make` to generate a fresh db for kiss-find.

# adding a repository

If your repository is on github, just add the 'kiss-repo' topic and it should be automatically picked up.

If your repository is anywhere else, make a PR to add it to `repo_safelist`.

# removing a repository

If you would not like your repository indexed, send a PR to add it to `repo_blocklist`.

# credits

Created by [@admicos](https://ecmelberk.com), rewritten and maintained by [@jedahan](https://github.com/jedahan)
