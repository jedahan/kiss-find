#!/bin/sh -e

warn() {
  echo "$@" >&2
}

clean() {
  rm -f .include .githublist .fulllist .filter
}
trap clean EXIT INT

current_dir=$(dirname "$0")

clean
grep -v '^[# ].*' "${current_dir}"/../filter | sort -u > .filter
grep -v '^[# ].*' "${current_dir}"/../include | sort -u > .include

command -v gh >/dev/null || warn 'gh commandline not found, please install to discover kiss-repo repositories on github'
gh auth status 2>/dev/null || warn 'gh auth status error, please login with gh auth login'
gh auth status 2>/dev/null && gh api graphql --field query=@"${current_dir}"/get_gh_repos.gql | jq -r ".data.search.edges[].node.url" | sort -u >> .include

comm -23 .include .filter
