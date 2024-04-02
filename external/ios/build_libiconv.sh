#!/bin/bash

set -e

. config.sh 

ICONV_DIR_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libiconv"

rm -rf $ICONV_DIR_PATH
mkdir -p $ICONV_DIR_PATH
pushd $ICONV_DIR_PATH
    wget https://ftp.gnu.org/gnu/libiconv/libiconv-1.15.tar.gz -O -| tar xzv
    pushd libiconv-1.15
        
    popd
popd