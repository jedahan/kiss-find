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
        BRANCH="$(git -C ${PACKAGE%%\/*} branch --show-current || echo unknown)"

        echo "  -> Found package $PACKAGE" >&2

        if [ -L "$PACKAGE/version" ]; then
            # not sure how to handle symlinks in a proper way yet
            VERSION="symlink"
        elif [ -f "$PACKAGE/version" ]; then
            VERSION="$(cat "$PACKAGE/version")"
        else
            VERSION="unknown"
        fi

        if [ -L "$PACKAGE/description" ]; then
            DESCRIPTION="symlink"
        elif [ -f "$PACKAGE/description" ]; then
            DESCRIPTION="$(head -n1 "$PACKAGE/description")"
        else
            DESCRIPTION=" "
        fi

        NAME="$(basename "$PACKAGE")"

        printf '%s,%s,%s,%s,%s,"%s"\n' \
          "$NAME" "$VERSION" "$REPO" "$PPATH" "$BRANCH" "$DESCRIPTION"
    done
}

mkdir -p "build/repos" && cd build/repos
while read -r REPO; do
    FOLDER="$(sanitize_folder_name "$REPO")"
    echo ":: $REPO ($FOLDER)" >&2

    fetch_repo "$REPO" "$FOLDER"
    process_repo "$REPO" "$FOLDER"
done <"${1:-/dev/stdin}"
