#!/bin/bash

set -e

. ./config.sh

SODIUM_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libsodium"
SODIUM_URL="https://github.com/jedisct1/libsodium.git"

echo "============================ SODIUM ============================"

echo "Cloning SODIUM from - $SODIUM_URL"

# Check if the directory already exists.
if [ -d "$SODIUM_PATH" ]; then
    echo "Sodium directory already exists."
else
    echo "Cloning Sodium from $SODIUM_URL"
    mkdir -p $SODIUM_PATH || true
	cp -r "${MONEROC_DIR}/external/libsodium" $SODIUM_PATH
fi

../../../../libsodium_apple-ios.sh

mv -f ${SODIUM_PATH}/libsodium-apple/ios/include/* $EXTERNAL_IOS_INCLUDE_DIR
mv -f ${SODIUM_PATH}/libsodium-apple/ios/lib/* $EXTERNAL_IOS_LIB_DIR