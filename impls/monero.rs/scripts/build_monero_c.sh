#!/bin/bash

set -x -e

# See https://github.com/MrCyjaneK/monero_c for the most up-to-date build docs,
# this is an example and a starting point for building monero_c for use in Rust
# but it should be automated either using CMake or Cargo (preferred).

# Detect architecture.
ARCH=$(uname -m)
OS=$(uname -s)

case $ARCH-$OS in
    x86_64-Linux)
        TARGET_ARCH="x86_64-linux-gnu"
        ;;
    i686-Linux)
        TARGET_ARCH="i686-linux-gnu"
        ;;
    aarch64-Linux)
        TARGET_ARCH="aarch64-linux-gnu"
        ;;
    x86_64-Android)
        TARGET_ARCH="x86_64-linux-android"
        ;;
    i686-Android)
        TARGET_ARCH="i686-linux-android"
        ;;
    aarch64-Android)
        TARGET_ARCH="aarch64-linux-android"
        ;;
    armv7l-Android)
        TARGET_ARCH="arm-linux-androideabi"
        ;;
    i686-Windows)
        TARGET_ARCH="i686-w64-mingw32"
        ;;
    x86_64-Windows)
        TARGET_ARCH="x86_64-w64-mingw32"
        ;;
    x86_64-Darwin)
        TARGET_ARCH="host-apple-darwin"
        ;;
    arm64-Darwin)
        TARGET_ARCH="host-apple-ios"
        ;;
    *)
        echo "Unsupported architecture: $ARCH on OS: $OS"
        exit 1
        ;;
esac

#../prepare_moneroc.sh
# See https://github.com/cypherstack/flutter_libmonero/blob/main/scripts/prepare_moneroc.sh
# flutter_libmonero/scripts/prepare_moneroc.sh:

if [[ ! -d "monero_c" ]];
then
    #rm -rf monero_c
    git clone https://github.com/sneurlax/monero_c --branch rust
fi
cd monero_c
#git checkout "6eb571ea498ed7b854934785f00fabfd0dadf75b"
git reset --hard
#git config submodule.libs/wownero.url https://git.cypherstack.com/Cypher_Stack/wownero
#git config submodule.libs/wownero-seed.url https://git.cypherstack.com/Cypher_Stack/wownero-seed
git submodule update --init --force --recursive
./apply_patches.sh monero
#./apply_patches.sh wownero

if [[ ! -f "monero/.patch-applied" ]];
then
    ./apply_patches.sh monero
fi

#if [[ ! -f "wownero/.patch-applied" ]];
#then
#    ./apply_patches.sh wownero
#fi

# flutter_libmonero/scripts/linux/build_all.sh cont. ...

pushd ../monero_c
    ./build_single.sh monero "$TARGET_ARCH" -j$(nproc)
    #./build_single.sh wownero "$TARGET_ARCH" -j$(nproc)
popd

unxz -f release/monero/${TARGET_ARCH}_libwallet2_api_c.so.xz
#unxz -f release/wownero/${TARGET_ARCH}_libwallet2_api_c.so.xz

# Navigate back to /scripts.
cd ..

# Copy the built .so file to a generic name.
SO_FILE="monero_c/release/monero/${TARGET_ARCH}_libwallet2_api_c.so"
if [[ -f "$SO_FILE" ]]; then
    cp "$SO_FILE" "../lib/libwallet2_api_c.so"
    echo "Copied $SO_FILE to libwallet2_api_c.so"
else
    echo "Error: $SO_FILE not found."
    exit 1
fi
