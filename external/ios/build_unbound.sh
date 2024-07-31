#!/bin/bash

set -e

. ./config.sh

UNBOUND_VERSION=release-1.16.2
UNBOUND_HASH="cbed768b8ff9bfcf11089a5f1699b7e5707f1ea5"
UNBOUND_URL="https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz"
UNBOUND_GIT_URL="https://github.com/NLnetLabs/unbound.git"
UNBOUND_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/unbound-1.16.2"

echo "============================ Unbound ============================"
rm -rf ${UNBOUND_DIR_PATH}

# Check if the directory already exists.
if [ -d "$UNBOUND_DIR_PATH" ]; then
    echo "Unbound directory already exists."
else
    echo "Cloning Unbound from $Unbound_URL"
	cp -r "${MONEROC_DIR}/external/unbound" ${UNBOUND_DIR_PATH}
fi

# Verify if the repository was cloned successfully.
if [ -d "$UNBOUND_DIR_PATH/.git" ]; then
    echo "Unbound repository cloned successfully."
	cd $UNBOUND_DIR_PATH
	git checkout $UNBOUND_VERSION # Or UNBOUND_HASH.
	test `git rev-parse HEAD` = ${UNBOUND_HASH} || exit 1
else
    echo "Failed to clone Unbound repository. Exiting."
    exit 1
fi

export IOS_SDK=iPhone
export IOS_CPU=arm64
export IOS_PREFIX=$EXTERNAL_IOS_DIR
export AUTOTOOLS_HOST=aarch64-apple-ios
export AUTOTOOLS_BUILD="$(./config.guess)"
source ./contrib/ios/setenv_ios.sh
./contrib/ios/install_tools.sh
./contrib/ios/install_expat.sh
./configure --build="$AUTOTOOLS_BUILD" --host="$AUTOTOOLS_HOST" --prefix="$IOS_PREFIX" --with-ssl="$IOS_PREFIX" --with-libexpat="$IOS_PREFIX"
make -j$(sysctl -n hw.logicalcpu)
make install