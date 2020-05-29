#!/bin/sh

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
		echo "  -> Pulling"

		cd "$FOLDER"
		git pull
		cd ".."
	else
		echo "  -> Cloning"

		git clone "$REPO" "$FOLDER"
	fi
}

process_repo() {
	REPO="$1"
	FOLDER="$2"

	find_packages "$FOLDER" | while read PACKAGE; do
		PPATH="$(get_path_in_repo "$PACKAGE")"

		echo "  -> Found package $PACKAGE"
		if [ -L "$PACKAGE/version" ]; then
			# not sure how to handle symlinks in a proper way yet
			VERSION="symlink" 
		else
			VERSION="$(cat "$PACKAGE/version")"
		fi

		jq -c -n \
			--arg version "$VERSION" \
			--arg package "$(basename "$PACKAGE")" \
			--arg repo "$REPO" \
			--arg path "$PPATH" \
			'{"package":$package,"version":$version,"repo":$repo,"path":$path}' \
			>> ../packages.json
	done
}

mkdir -p "repos"
cat "$1" | while read REPO; do
	cd repos

	FOLDER="$(sanitize_folder_name "$REPO")"
	echo ":: $REPO ($FOLDER)"

	fetch_repo "$REPO" "$FOLDER"
	process_repo "$REPO" "$FOLDER"

	cd ..
done
