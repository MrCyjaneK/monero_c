#!/bin/bash
set -e

HOST_ABI="$1"
if [[ "x$HOST_ABI" == "x" ]];
then
    echo "Usage: $0 $(gcc -dumpmachine) -j$(nproc)"
    exit 1
fi

NPROC="$2"

if [[ "x$NPROC" == "x" ]];
then
    echo "Usage: $0 $(gcc -dumpmachine) -j$(nproc)"
    exit 1
fi

CC=""
CXX=""
case "$HOST_ABI" in
    "x86_64-linux-gnu")
        export CC="x86_64-linux-gnu-gcc"
        export CC="x86_64-linux-gnu-g++"
    ;;
    "i686-linux-gnu")
        export CC="i686-linux-gnu-gcc"
        export CXX="i686-linux-gnu-g++"
    ;;
    "aarch64-linux-gnu")
        export CC="aarch64-linux-gnu-gcc"
        export CXX="aarch64-linux-gnu-g++"
    ;;
esac

if [[ "x$CC" == "x" ]];
then
    echo "No C compiler found for abi: '$HOST_ABI'. Adjust the switch case in $0"
    exit 1
fi

if [[ "x$CXX" == "x" ]];
then
    echo "No C++ compiler found for abi: '$HOST_ABI'. Adjust the switch case in $0"
    exit 1
fi

cd $(dirname $0)
pushd monero/contrib/depends
    make HOST="$HOST_ABI" "$NPROC"
popd

rm -rf monero/build/${HOST_ABI} 2>/dev/null || true
mkdir -p monero/build/${HOST_ABI}
pushd monero/build/${HOST_ABI}
    env CC=${CC} CXX=${CXX} cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake ../..
    env CC=${CC} CXX=${CXX} make wallet_api $NPROC
popd
pushd libbridge
    rm -rf build/${HOST_ABI} || true
    mkdir -p build/${HOST_ABI} -p
    cd build/${HOST_ABI}
    
    env CC=${CC} CXX=${CXX} cmake -DHOST_ABI=${HOST_ABI} ../..
    env CC=${CC} CXX=${CXX} make $NPROC
popd

mkdir release 2>/dev/null || true
pushd release
    xz -e ../libbridge/build/${HOST_ABI}/libwallet2_api_c.so
    mv ../libbridge/build/${HOST_ABI}/libwallet2_api_c.so.xz ${HOST_ABI}_libwallet2_api_c.so.xz
popd