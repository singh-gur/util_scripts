#!/bin/bash

set -e

VERSION=1.20.1

function help(){
    echo "Usage: install_go.sh -v/--version <version> (default: $VERSION)"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--version)
      VERSION="$2"
      shift
      shift
      ;;
    -h|--help)
      help
      exit 0
      ;;
  esac
done

pushd /tmp

wget https://go.dev/dl/go$VERSION.linux-amd64.tar.gz

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz


popd