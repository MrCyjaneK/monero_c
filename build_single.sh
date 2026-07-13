#!/bin/bash

cd "$(realpath $(dirname $0))"

proccount=1
if [[ "x$(uname)" == "xDarwin" ]];
then
    proccount=$(sysctl -n hw.physicalcpu)
elif [[ "x$(uname)" == "xLinux" ]];
then
    proccount=$(nproc)
fi

function verbose_copy() {
    echo "==> cp $1 $2"
    cp $1 $2
}

set -e
repo=$1
if [[ "x$repo" == "x" ]];
then
    echo "Usage: $0 monero/wownero/zano/beldex $(gcc -dumpmachine) -j$proccount"
    exit 1
fi

if [[ "x$repo" != "xwownero" && "x$repo" != "xmonero" && "x$repo" != "xzano" && "x$repo" != "xbeldex" ]];
then
    echo "Usage: $0 monero/wownero/zano/beldex $(gcc -dumpmachine) -j$proccount"
    echo "Invalid target given"
    exit 1
fi

if [[ ! -d "$repo" ]]
then
    echo "no '$repo' directory found. clone with --recursive or run:"
    echo '$ git submodule init && git submodule update --force';
    exit 1
fi

HOST_ABI="$2"
if [[ "x$HOST_ABI" == "x" ]];
then
    echo "Usage: $0 monero/wownero/beldex $(gcc -dumpmachine) -j$proccount"
    exit 1
fi

NPROC="$3"

if [[ "x$NPROC" == "x" ]];
then
    echo "Usage: $0 monero/wownero/beldex $(gcc -dumpmachine) -j$proccount"
    exit 1
fi
cd $(dirname $0)
WDIR=$PWD
pushd contrib/depends
    sbs_BOOST_VERSION=1_90_0
    if [[ "x$repo" == "xzano" ]];
    then
        sbs_BOOST_VERSION=1_83_0
    fi
    env PATH="$PATH" make "$NPROC" HOST="$HOST_ABI" BOOST_VERSION="${sbs_BOOST_VERSION}"
popd
# source contrib/depends/_native/_source_me
source contrib/depends/$HOST_ABI/_source_me
export PATH="$(pwd)/contrib/depends/_native/bin/:$(pwd)/contrib/depends/$HOST_ABI/native/bin:$PATH"

buildType=Release

for OUTPUT_MODE in SHARED;
do
    pushd ${repo}_libwallet2_api_c
        rm -rf build/${HOST_ABI}_${OUTPUT_MODE} || true
        mkdir -p build/${HOST_ABI}_${OUTPUT_MODE}
        if [[ "$repo" == "zano" ]];
        then
        EXTRA_CMAKE_FLAGS="-DCAKEWALLET=ON"
        fi
        if [[ "$repo" == "beldex" ]];
        then
            EXTRA_CMAKE_FLAGS="-DCAKEWALLET=ON"
            if [[ "${HOST_ABI}" == "x86_64-apple-darwin" || "${HOST_ABI}" == "aarch64-apple-darwin" || "${HOST_ABI}" == "aarch64-apple-ios" || "${HOST_ABI}" == "aarch64-apple-ios-simulator" ]];
                then
                    EXTRA_CMAKE_FLAGS="-DRANDOMX_ENABLE_JIT=OFF -DUSE_LTO=OFF" 
            fi
        fi
        pushd build/${HOST_ABI}_${OUTPUT_MODE}
            cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../../contrib/depends/${HOST_ABI}/share/toolchain.cmake $EXTRA_CMAKE_FLAGS -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} -DOUTPUT_MODE=${OUTPUT_MODE} ../..
            make $NPROC
        popd
    popd
done

mkdir -p release/$(git describe --tags)/${HOST_ABI} 2>/dev/null || true
pushd release/$(git describe --tags)/${HOST_ABI}
    pwd
    mv ../../../${repo}_libwallet2_api_c/build/${HOST_ABI}_*/lib*_wallet2_api_c.* .
popd
