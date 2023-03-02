#!/bin/bash

set -e

VERSION="${1:-1.20.1}"
pushd /tmp

wget https://go.dev/dl/go$VERSION.linux-amd64.tar.gz

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz


popd