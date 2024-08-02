#!/bin/bash

set -e

rm -rf build

. ./config.sh

rm -rf "$EXTERNAL_IOS_LIB_DIR"
rm -rf "$EXTERNAL_IOS_INCLUDE_DIR"

./install_missing_headers.sh
./build_openssl.sh
./build_boost.sh
./build_sodium.sh
./build_zmq.sh
./build_unbound.sh

