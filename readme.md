# kiss-find

tool for indexing and searching as many kiss repositories as possible.

build and index a new db

    make 

install kiss-find and db

    make install

install kiss-find standalone

    make install-cli
    kiss find -u # update from the prebuilt db

try out kiss-find

    kiss find amf

```json
{
  "key": "amfora",
  "value": [
    {
      "description": "a fancy terminal browser for the gemini protocol",
      "path": "amfora",
      "repo": "https://github.com/jedahan/kiss-repo",
      "version": "1.7.1 1"
    }
  ]
}
{
  "key": "tinyramfs",
  "value": [
    {
      "path": "kernel/tinyramfs",
      "repo": "https://github.com/mmatongo/dm",
      "version": "git 1"
    }
  ]
}
```

# client

You can install kiss-find on kiss with the package in this repo.

    cd dist/kiss/kiss-find
    kiss build && kiss install
    kiss find amf

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
