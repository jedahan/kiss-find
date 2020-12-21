#!/usr/bin/env bash
set -euo pipefail

warn() {
  echo "$@" >&2
}

command -v gh >/dev/null || warn 'gh commandline not found, please install to discover kiss-repo repositories on github'
gh auth status 2>/dev/null || warn 'gh auth status error, please login with gh auth login'
gh auth status 2>/dev/null && github_repos=$(gh api graphql --field query=@get_gh_repos.gql | jq -r ".data.search.edges[].node.url")

allowlist=$(mktemp)
added_repos=$(cat added_repos)
printf '%s\n%s' "$added_repos" "$github_repos" | sort > "$allowlist"

blocklist=$(mktemp)
grep -v '^[# ].*' removed_repos | sort > "$blocklist"
comm -23 "$allowlist" "$blocklist" | grep -v '^#.*' > repo_list
