#!/bin/bash

set -e

. ./config.sh

MIN_IOS_VERSION=10.0
BOOST_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/Apple-Boost-BuildScript"
BOOST_VERSION=1.84.0
BOOST_LIBS="random regex graph random chrono thread filesystem system date_time locale serialization program_options"

echo "============================ Boost ============================"

# Check if the directory already exists.
if [ -d "$BOOST_DIR_PATH" ]; then
    echo "Boost directory already exists."
else
    echo "Cloning Boost from $BOOST_URL"
    mkdir -p "$BOOST_DIR_PATH" || true
    rm -rf "$BOOST_DIR_PATH" || true
    cp -r "${MONEROC_DIR}/external/Apple-Boost-BuildScript" "$BOOST_DIR_PATH"
fi
cd "$BOOST_DIR_PATH"

./boost.sh -ios \
	--min-ios-version ${MIN_IOS_VERSION} \
	--boost-libs "${BOOST_LIBS}" \
	--boost-version ${BOOST_VERSION} \
	--no-framework

cp -r "${BOOST_DIR_PATH}/build/boost/${BOOST_VERSION}/ios/release/prefix/include/*"  "$EXTERNAL_IOS_INCLUDE_DIR"
cp -r "${BOOST_DIR_PATH}/build/boost/${BOOST_VERSION}/ios/release/prefix/lib/*"  "$EXTERNAL_IOS_LIB_DIR"