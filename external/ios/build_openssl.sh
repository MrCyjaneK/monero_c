#!/bin/bash

set -e

. ./config.sh

OPEN_SSL_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/OpenSSL"

echo "============================ OpenSSL ============================"

echo "Cloning Open SSL from - $OPEN_SSL_URL"

# Check if the directory already exists.
if [ -d "$OPEN_SSL_DIR_PATH" ]; then
    echo "OpenSSL directory already exists."
else
    mkdir -p "$OPEN_SSL_DIR_PATH" || true
    rm -rf "$OPEN_SSL_DIR_PATH"
	cp -r "${MONEROC_DIR}/external/OpenSSL-for-iPhone" "$OPEN_SSL_DIR_PATH"
fi
cd "$OPEN_SSL_DIR_PATH"

./build-libssl.sh --version=1.1.1q --targets="ios-cross-arm64" --deprecated


cp -r "${OPEN_SSL_DIR_PATH}"/include/* "$EXTERNAL_IOS_INCLUDE_DIR/"
cp "${OPEN_SSL_DIR_PATH}"/lib/libcrypto-iOS.a "${EXTERNAL_IOS_LIB_DIR}"/libcrypto.a
cp "${OPEN_SSL_DIR_PATH}"/lib/libssl-iOS.a "${EXTERNAL_IOS_LIB_DIR}"/libssl.a