#!/bin/sh -e

# might not work for non-github repos, fix that
sanitize_folder_name() {
    echo "$1" | cut -d"/" -f4- | sed 's@/@_@'
}

get_path_in_repo() {
    echo "$1" | cut -d"/" -f2-
}

find_packages() {
    find "$1" -name build -type f -exec dirname {} \;
}

fetch_repo() {
    REPO="$1"
    FOLDER="$2"

    if [ -d "$FOLDER" ]; then
        echo "  -> Pulling" >&2

        cd "$FOLDER"
        git pull -f >&2 || true
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

    find_packages "$FOLDER" | while read -r PACKAGE; do
    PPATH="$(get_path_in_repo "$PACKAGE")"

    echo "  -> Found package $PACKAGE" >&2

    if [ -L "$PACKAGE/version" ]; then
        # not sure how to handle symlinks in a proper way yet
        VERSION="symlink"
    elif [ -f "$PACKAGE/version" ]; then
        VERSION="$(cat "$PACKAGE/version")"
    else
	VERSION="unknown"
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
while read -r REPO; do
  cd repos

  FOLDER="$(sanitize_folder_name "$REPO")"
  echo ":: $REPO ($FOLDER)" >&2

  fetch_repo "$REPO" "$FOLDER"
  process_repo "$REPO" "$FOLDER"

  cd ..
done < "$1"
