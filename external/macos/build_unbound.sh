#!/bin/bash
set -x -e

. config.sh

#### expat

EXPAT_VERSION=R_2_4_8
EXPAT_HASH="3bab6c09bbe8bf42d84b81563ddbcf4cca4be838"
EXPAT_SRC_DIR=${EXTERNAL_MACOS_SOURCE_DIR}/libexpat
rm -rf $EXPAT_SRC_DIR
if [ -d "$EXPAT_SRC_DIR" ]; then
    echo "Unbound directory already exists."
else
    echo "Cloning Unbound from $Unbound_URL"
    mkdir -p ${EXPAT_SRC_DIR} || true
    rm -rf ${EXPAT_SRC_DIR}
	cp -r "${MONEROC_DIR}/external/libexpat" ${EXPAT_SRC_DIR}
fi
cd $EXPAT_SRC_DIR
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
# Check if the directory already exists.
if [ -d "$UNBOUND_DIR_PATH" ]; then
    echo "Unbound directory already exists."
else
    echo "Cloning Unbound from $Unbound_URL"
    mkdir -p ${UNBOUND_DIR_PATH} || true
    rm -rf ${UNBOUND_DIR_PATH}
	cp -r "${MONEROC_DIR}/external/unbound" ${UNBOUND_DIR_PATH}
fi
cd $UNBOUND_DIR_PATH
./configure --prefix="${EXTERNAL_MACOS_DIR}" \
	    --with-ssl="${HOMEBREW_PREFIX}" \
			--with-libexpat="${EXTERNAL_MACOS_DIR}" \
			--enable-static \
			--disable-shared \
			--disable-flto
make
make install
