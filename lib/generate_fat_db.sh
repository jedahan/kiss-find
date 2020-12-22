#!/bin/bash
set -euo pipefail

# might not work for non-github repos, fix that
sanitize_folder_name() {
    echo "$1" | cut -d"/" -f4- | sed 's@/@_@'
}

get_path_in_repo() {
    echo "$1" | cut -d"/" -f2-
}

# just *hope* no one puts an executable named "build" anywhere other than the package dirs
find_packages() {
    find "$1" -name build -type f -executable -exec dirname {} \;
}

fetch_repo() {
    REPO="$1"
    FOLDER="$2"

    if [ -d "$FOLDER" ]; then
        echo "  -> Pulling" >&2

        cd "$FOLDER"
        git pull -f >&2
        cd ".."
    else
        echo "  -> Cloning" >&2

        git clone "$REPO" "$FOLDER" >&2

        cd "$FOLDER"
        git config user.email "kissfind@mail.invalid" >&2
        git config user.name "kiss-find database" >&2
        cd ".."
    fi
}

process_repo() {
    REPO="$1"
    FOLDER="$2"

    find_packages "$FOLDER" | while read PACKAGE; do
    PPATH="$(get_path_in_repo "$PACKAGE")"

    echo "  -> Found package $PACKAGE" >&2

    if [ -L "$PACKAGE/version" ]; then
        # not sure how to handle symlinks in a proper way yet
        VERSION="symlink"
    else
        VERSION="$(cat "$PACKAGE/version")"
    fi

    if [ -f "$PACKAGE/description" ]; then
        if [ -L "$PACKAGE/description" ]; then
            DESCRIPTION="symlink"
        else
            DESCRIPTION="$(cat "$PACKAGE/description")"
        fi
    else
        DESCRIPTION=""
    fi

    jq -c -n \
        --arg version "$VERSION" \
        --arg package "$(basename "$PACKAGE")" \
        --arg repo "$REPO" \
        --arg path "$PPATH" \
        --arg description "$DESCRIPTION" \
        '{"package":$package,"version":$version,"repo":$repo,"path":$path,"description":$description}'
    done
}

mkdir -p "repos"
cat "$1" | while read REPO; do
  cd repos

  FOLDER="$(sanitize_folder_name "$REPO")"
  echo ":: $REPO ($FOLDER)" >&2

  fetch_repo "$REPO" "$FOLDER"
  process_repo "$REPO" "$FOLDER"

  cd ..
done
