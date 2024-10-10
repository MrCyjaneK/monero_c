# See https://github.com/MrCyjaneK/monero_c for the most up-to-date build docs,
# this is an example and a starting point for building monero_c for use in Rust
# but it should be automated either using CMake or Cargo (preferred).

# From https://github.com/cypherstack/flutter_libmonero/blob/main/scripts/linux/build_all.sh
# flutter_libmonero/scripts/linux/build_all.sh:

set -x -e

# Build monero_c.
cd "$(dirname "$0")"

if [[ ! "x$(uname)" == "xLinux" ]];
then
    echo "Only Linux hosts can build linux";
    exit 1
fi

#../prepare_moneroc.sh
# See https://github.com/cypherstack/flutter_libmonero/blob/main/scripts/prepare_moneroc.sh
# scripts/prepare_moneroc.sh:

#!/bin/bash

set -x -e

cd "$(dirname "$0")"

# Allow script caller to pass commit hash.
# dirty hack to handle broken monero_c on android. Uses same hash on linux as well to make dev life easier
# CHASH="$1"
# if [ -z "$CHASH" ]; then
#   CHASH="294b593db30e8803586dfd0f47e716ce1200c766"
# fi

# # We should be in monero_c/impls/monero_rust/scripts...
# cd ../../..
# Instead of building the monero_c we already have, let's clone another, "fresher" one (:

#rm -rf build
if [[ ! -d "build" ]];
then
    git clone https://github.com/sneurlax/monero_c build --branch rust
    cd build
else
    cd build
fi
# git checkout "6eb571ea498ed7b854934785f00fabfd0dadf75b" # TODO update.
git checkout rust
git reset --hard
# TODO migrate all git repos to github (or back to the official wow repo, which is spotty).
# git config submodule.libs/wownero.url https://git.cypherstack.com/Cypher_Stack/wownero
# git config submodule.libs/wownero-seed.url https://git.cypherstack.com/Cypher_Stack/wownero-seed
git submodule update --init --force --recursive
./apply_patches.sh monero
#./apply_patches.sh wownero

if [[ ! -f "monero/.patch-applied" ]];
then
    ./apply_patches.sh monero
fi

# if [[ ! -f "wownero/.patch-applied" ]];
# then
#     ./apply_patches.sh wownero
# fi
#  cd ..

echo "monero_c source prepared"

# flutter_libmonero/scripts/linux/build_all.sh cont. ...

pushd ../build
    ./build_single.sh monero x86_64-linux-gnu -j8 # TODO use nproc or similar.
#     ./build_single.sh wownero x86_64-linux-gnu -j8
popd

unxz -f build/release/monero/x86_64-linux-gnu_libwallet2_api_c.so.xz
#unxz -f build/release/wownero/x86_64-linux-gnu_libwallet2_api_c.so.xz
