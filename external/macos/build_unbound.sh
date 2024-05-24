#!/bin/bash
set -x -e

. config.sh

#### add m4 to path
# NOTE: this may not be needed.

HOMEBREW_PREFIX="$(brew config | grep HOMEBREW_PREFIX | awk '{ print $2 }')"
M4_VERSION="$(brew info m4 | head -1 | awk '{ print $4 }')"
export PATH="${HOMEBREW_PREFIX}/Cellar/m4/${M4_VERSION}/bin/:$PATH"

#### expat

EXPAT_VERSION=R_2_4_8
EXPAT_HASH="3bab6c09bbe8bf42d84b81563ddbcf4cca4be838"
EXPAT_SRC_DIR=${EXTERNAL_MACOS_SOURCE_DIR}/libexpat
rm -rf $EXPAT_SRC_DIR
git clone https://github.com/libexpat/libexpat.git -b ${EXPAT_VERSION} ${EXPAT_SRC_DIR}
cd $EXPAT_SRC_DIR
test `git rev-parse HEAD` = ${EXPAT_HASH} || exit 1
cd $EXPAT_SRC_DIR/expat

./buildconf.sh
./configure --enable-static --disable-shared --prefix=${EXTERNAL_MACOS_DIR}
make
make install

#### unbound

UNBOUND_VERSION=release-1.16.2
UNBOUND_HASH="cbed768b8ff9bfcf11089a5f1699b7e5707f1ea5"
UNBOUND_URL="https://www.nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz"
UNBOUND_DIR_PATH="${EXTERNAL_MACOS_SOURCE_DIR}/unbound-1.16.2"

echo "============================ Unbound ============================"
rm -rf ${UNBOUND_DIR_PATH}
git clone https://github.com/NLnetLabs/unbound.git -b ${UNBOUND_VERSION} ${UNBOUND_DIR_PATH}
cd $UNBOUND_DIR_PATH
test `git rev-parse HEAD` = ${UNBOUND_HASH} || exit 1

./configure --prefix="${EXTERNAL_MACOS_DIR}" \
			--with-libexpat="${EXTERNAL_MACOS_DIR}" \
			--enable-static \
			--disable-shared \
			--disable-flto
make
make install