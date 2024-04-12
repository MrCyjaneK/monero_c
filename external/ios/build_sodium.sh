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
	git clone $SODIUM_URL $SODIUM_PATH
fi

# Verify if the repository was cloned successfully.
if [ -d "$SODIUM_PATH/.git" ]; then
    echo "Sodium repository cloned successfully."
	cd $SODIUM_PATH
	git checkout 443617d7507498f7477703f0b51cb596d4539262
else
    echo "Failed to clone Sodium repository. Exiting."
    exit 1
fi

./dist-build/apple-xcframework.sh

mv -f -n ${SODIUM_PATH}/libsodium-apple/ios/include/* $EXTERNAL_IOS_INCLUDE_DIR
mv -f -n ${SODIUM_PATH}/libsodium-apple/ios/lib/* $EXTERNAL_IOS_LIB_DIR