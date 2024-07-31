#!/bin/bash

set -e

. ./config.sh

ZMQ_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libzmq"

echo "============================ ZMQ ============================"

echo "Cloning ZMQ from - $ZMQ_URL"

# Check if the directory already exists.
if [ -d "$ZMQ_PATH" ]; then
    echo "ZeroMQ directory already exists."
else
    echo "Cloning ZeroMQ from $ZeroMQ_URL"
	cp -r "${MONEROC_DIR}/external/libzmq" $ZMQ_PATH
fi

# Verify if the repository was cloned successfully.
if [ -d "$ZMQ_PATH/.git" ]; then
    echo "ZeroMQ repository cloned successfully."
	cd $ZMQ_PATH
else
    echo "Failed to clone ZeroMQ repository. Exiting."
    exit 1
fi

mkdir -p cmake-build
cd cmake-build
cmake ..
make -j$(sysctl -n hw.logicalcpu)


cp ${ZMQ_PATH}/include/* $EXTERNAL_IOS_INCLUDE_DIR
cp ${ZMQ_PATH}/cmake-build/lib/libzmq.a $EXTERNAL_IOS_LIB_DIR