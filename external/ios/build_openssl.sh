#!/bin/bash

set -e

. ./config.sh

OPEN_SSL_URL="https://github.com/x2on/OpenSSL-for-iPhone.git"
OPEN_SSL_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/OpenSSL"

echo "============================ OpenSSL ============================"

echo "Cloning Open SSL from - $OPEN_SSL_URL"

# Check if the directory already exists.
if [ -d "$OPEN_SSL_DIR_PATH" ]; then
    echo "OpenSSL directory already exists."
else
    echo "Cloning OpenSSL from $OPEN_SSL_URL"
	git clone $OPEN_SSL_URL $OPEN_SSL_DIR_PATH
fi

# Verify if the repository was cloned successfully.
if [ -d "$OPEN_SSL_DIR_PATH/.git" ]; then
    echo "OpenSSL repository cloned successfully."
	cd $OPEN_SSL_DIR_PATH
else
    echo "Failed to clone OpenSSL repository. Exiting."
    exit 1
fi

./build-libssl.sh --version=1.1.1q --targets="ios-cross-arm64" --deprecated

mv -f ${OPEN_SSL_DIR_PATH}/include/* $EXTERNAL_IOS_INCLUDE_DIR
mv ${OPEN_SSL_DIR_PATH}/lib/libcrypto-iOS.a ${EXTERNAL_IOS_LIB_DIR}/libcrypto.a
mv ${OPEN_SSL_DIR_PATH}/lib/libssl-iOS.a ${EXTERNAL_IOS_LIB_DIR}/libssl.a