#!/bin/bash

set -e

VERSION=1.20.1
TMP_DIR=/tmp

function help(){
    cat << help_eof 
Usage: install_go.sh <options> 
Options:
    -v/--version <go version>           (default: $VERSION)
    -t/--tmp_dir <temp dir location>    (default: $TMP_DIR)
help_eof

}

while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--version)
      VERSION="$2"
      shift
      shift
      ;;
    -t|--tmp_dir)
      TMP_DIR="$2"
      shift
      shift
      ;;
    -h|--help)
      help
      exit 0
      ;;
  esac
done

pushd $TMP_DIR

wget https://go.dev/dl/go$VERSION.linux-amd64.tar.gz

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz


popd