#!/bin/sh

set -x -e

. ./config.sh

SEED_VERSION=0.3.0
SEED_SRC_DIR="${EXTERNAL_IOS_SOURCE_DIR}/seed"
SEED_URL="https://git.wownero.com/wowlet/wownero-seed.git"
SEED_SHA_HEAD="d3f68be347facfeebbd8f68fd74982c705cb917b"

rm -rf "$SEED_SRC_DIR" > /dev/null

echo "[*] cloning $SEED_URL"
git clone --branch ${SEED_VERSION} ${SEED_URL} ${SEED_SRC_DIR}
cd $SEED_SRC_DIR
git reset --hard $SEED_SHA_HEAD

patch -p1 < ../../../../../wownero-seed-0001-fix-duplicate-symbol-error.patch

BUILD_TYPE=release
PREFIX=${EXTERNAL_IOS_DIR}
DEST_LIB_DIR=${EXTERNAL_IOS_LIB_DIR}/wownero-seed
DEST_INCLUDE_DIR=${EXTERNAL_IOS_INCLUDE_DIR}/wownero-seed

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z $INSTALL_PREFIX ]; then
    INSTALL_PREFIX=${ROOT_DIR}/wownero-seed
fi

for arch in "arm64" #"armv7" "arm64"
do

echo "Building wownero-seed IOS ${arch}"
export CMAKE_INCLUDE_PATH="${PREFIX}/include"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib"

case $arch in
	"armv7"	)
		DEST_LIB=../../lib-armv7;;
	"arm64"	)
		DEST_LIB=../../lib-armv8-a;;
esac

cmake -Bbuild -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_SYSTEM_NAME="iOS" -DCMAKE_OSX_ARCHITECTURES="${arch}" .
make -Cbuild -j$(nproc)
make -Cbuild install

done