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
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    exit 1
fi

if [[ "x$repo" != "xwownero" && "x$repo" != "xmonero" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    echo "Invalid target given, only monero and wownero are supported targets"
    exit 1
fi

if [[ ! -d "$repo" ]]
then
    echo "no '$repo' directory found. clone with --recursive or run:"
    echo "$ git submodule init && git submodule update --force";
    exit 1
fi

HOST_ABI="$2"
if [[ "x$HOST_ABI" == "x" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    exit 1
fi

NPROC="$3"

if [[ "x$NPROC" == "x" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    exit 1
fi
cd $(dirname $0)
WDIR=$PWD
pushd contrib/depends
    env -i PATH="$PATH" CC=gcc CXX=g++ make "$NPROC" HOST="$HOST_ABI"
popd

buildType=Debug

pushd ${repo}_libwallet2_api_c
    rm -rf build/${HOST_ABI} || true
    mkdir -p build/${HOST_ABI} -p
    pushd build/${HOST_ABI}
        cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -DUSE_DEVICE_TREZOR=OFF -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
        make $NPROC
    popd
popd

mkdir -p release/$repo 2>/dev/null || true
pushd release/$repo
    APPENDIX=""
    if [[ "${HOST_ABI}" == "x86_64-w64-mingw32" || "${HOST_ABI}" == "i686-w64-mingw32" ]];
    then
        echo "TODO: check if it's still needed"
        APPENDIX="${APPENDIX}dll"
        # cp ../../$repo/build/${HOST_ABI}/external/polyseed/libpolyseed.${APPENDIX} ${HOST_ABI}_libpolyseed.${APPENDIX}
        # rm ${HOST_ABI}_libpolyseed.${APPENDIX}.xz || true
        # xz -e ${HOST_ABI}_libpolyseed.${APPENDIX}
    elif [[ "${HOST_ABI}" == "x86_64-apple-darwin11" || "${HOST_ABI}" == "aarch64-apple-darwin11" || "${HOST_ABI}" == "host-apple-darwin" || "${HOST_ABI}" == "x86_64-host-apple-darwin" || "${HOST_ABI}" == "aarch64-apple-darwin"  || "${HOST_ABI}" == "x86_64-apple-darwin" || "${HOST_ABI}" == "host-apple-ios" || "${HOST_ABI}" == "aarch64-apple-ios" ]];
    then
        APPENDIX="${APPENDIX}dylib"
    else
        APPENDIX="${APPENDIX}so"
    fi
    xz -e ../../${repo}_libwallet2_api_c/build/${HOST_ABI}/libwallet2_api_c.${APPENDIX}
    mv ../../${repo}_libwallet2_api_c/build/${HOST_ABI}/libwallet2_api_c.${APPENDIX}.xz ${HOST_ABI}_libwallet2_api_c.${APPENDIX}.xz
    # Extra libraries
    if [[ "$HOST_ABI" == "x86_64-w64-mingw32" || "$HOST_ABI" == "i686-w64-mingw32" ]];
    then
        cp /usr/${HOST_ABI}/lib/libwinpthread-1.dll ${HOST_ABI}_libwinpthread-1.dll
        rm ${HOST_ABI}_libwinpthread-1.dll.xz || true
        xz -e ${HOST_ABI}_libwinpthread-1.dll
        ####
        cp /usr/lib/gcc/${HOST_ABI}/*-posix/libssp-0.dll ${HOST_ABI}_libssp-0.dll
        rm ${HOST_ABI}_libssp-0.dll.xz || true
        xz -e ${HOST_ABI}_libssp-0.dll
    fi
popd
