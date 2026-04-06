#!/bin/bash

set -e
set -u
set -o pipefail

PIPELINE_NAME="util-scripts"
PIPELINE_FILE="ci/pipeline.yml"
CREDENTIALS_FILE="ci/credentials.yml"

print_info() {
    printf '[INFO] %s\n' "$1"
}

print_error() {
    printf '[ERROR] %s\n' "$1" >&2
}

usage() {
    cat << EOF
Usage: $0 <target-name>

Sets the Concourse pipeline for util_scripts.

Examples:
  $0 deploy
EOF
}

if ! command -v fly >/dev/null 2>&1; then
    print_error "fly CLI is not installed"
    print_info "Install it from https://concourse-ci.org/download.html"
    exit 1
fi

if [[ ! -f "$CREDENTIALS_FILE" ]]; then
    print_error "Credentials file not found: $CREDENTIALS_FILE"
    print_info "Copy ci/credentials.yml.example to ci/credentials.yml and fill in the values"
    exit 1
fi

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

TARGET="$1"

if ! fly -t "$TARGET" status >/dev/null 2>&1; then
    print_error "Target '$TARGET' is not configured or not logged in"
    print_info "Login first with: fly -t $TARGET login -c https://deploy.gsingh.io/"
    exit 1
fi

print_info "Setting pipeline '$PIPELINE_NAME' on target '$TARGET'"

fly -t "$TARGET" set-pipeline \
    -p "$PIPELINE_NAME" \
    -c "$PIPELINE_FILE" \
    -l "$CREDENTIALS_FILE"

print_info "Pipeline set successfully"
print_info "Unpause with: fly -t $TARGET unpause-pipeline -p $PIPELINE_NAME"
print_info "Expose with: fly -t $TARGET expose-pipeline -p $PIPELINE_NAME"
print_info "Pipeline URL: https://deploy.gsingh.io/teams/main/pipelines/$PIPELINE_NAME"
