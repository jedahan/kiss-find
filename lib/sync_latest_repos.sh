#!/usr/bin/env bash
set -euo pipefail

warn() {
  echo "$@" >&2
}

current_dir=$(dirname "$0")

command -v gh >/dev/null || warn 'gh commandline not found, please install to discover kiss-repo repositories on github'
gh auth status 2>/dev/null || warn 'gh auth status error, please login with gh auth login'
gh auth status 2>/dev/null && \
  githublist=$(gh api graphql --field query=@"${current_dir}"/get_gh_repos.gql | jq -r ".data.search.edges[].node.url" | sort)

safelist=$(grep -v '^[# ].*' "${current_dir}"/../repo_safelist | sort)

comm -23 \
  <(printf '%s\n%s' "$safelist" "$githublist" | sort) \
  <(grep -v '^[# ].*' "${current_dir}"/../repo_blocklist | sort)
