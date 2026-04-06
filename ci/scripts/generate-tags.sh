#!/bin/bash

set -e
set -u
set -o pipefail

REPO_DIR="${1:-repo}"
OUTPUT_DIR="${2:-tags}"

sanitize_tag() {
    local value="$1"

    value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
    value="$(printf '%s' "$value" | sed 's/[^a-z0-9._-]/-/g')"
    value="$(printf '%s' "$value" | sed 's/--*/-/g; s/^-//; s/-$//')"

    if [[ -z "$value" ]]; then
        echo "Error: Unable to derive a valid image tag from input" >&2
        exit 1
    fi

    printf '%s\n' "$value"
}

require_repo() {
    if [[ ! -d "$REPO_DIR/.git" ]]; then
        echo "Error: Repository directory not found: $REPO_DIR" >&2
        exit 1
    fi
}

read_branch() {
    if [[ -f "$REPO_DIR/.git/branch" ]]; then
        tr -d '[:space:]' < "$REPO_DIR/.git/branch"
        return
    fi

    git -C "$REPO_DIR" branch --show-current
}

main() {
    local branch
    local sanitized_branch
    local short_sha
    local git_tag
    local sanitized_git_tag
    local tags=()

    require_repo
    mkdir -p "$OUTPUT_DIR"

    branch="$(read_branch)"
    short_sha="$(git -C "$REPO_DIR" rev-parse --short HEAD)"
    git_tag="$(git -C "$REPO_DIR" describe --tags --exact-match HEAD 2>/dev/null || true)"

    sanitized_branch="$(sanitize_tag "$branch")"
    tags+=("$sanitized_branch")
    tags+=("$(sanitize_tag "$short_sha")")

    if [[ -n "$git_tag" ]]; then
        sanitized_git_tag="$(sanitize_tag "$git_tag")"
        tags+=("$sanitized_git_tag")
    fi

    if [[ "$sanitized_branch" == "main" ]]; then
        tags+=("latest")
    fi

    printf '%s\n' "${tags[@]}" | awk '!seen[$0]++' > "$OUTPUT_DIR/all"
    printf '%s\n' "$sanitized_branch" > "$OUTPUT_DIR/branch"
    printf '%s\n' "$short_sha" > "$OUTPUT_DIR/short_sha"

    if [[ -n "$git_tag" ]]; then
        printf '%s\n' "$sanitized_git_tag" > "$OUTPUT_DIR/git_tag"
    fi
}

main "$@"
