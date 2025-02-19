# Building Upstream

monero_c contains its own fork of contrib/depends system that is independent of monero, wownero or zano. In order to use said build system one needs to:

```
pushd contrib/depends
env -i \
PATH="$PATH" \
CC=gcc CXX=g++ \
make -j$(nproc) HOST=aarch64-apple-darwin
popd
```

Then, get path to your desired toolchain.cmake

```
TOOLCHAIN_FILE=${PWD}/contrib/depends/aarch64-apple-darwin/share/toolchain.cmake
```
And finally use that as part of cmake invocation, for example to compile monero you can do the following:

```
pushd monero
mkdir -p build/aarch64-apple-darwin
cd $_
cmake \
-DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
-DBUILD_TESTS=ON \
../..
```

From there you can build targets such as wallet_api

```
make wallet_api -j$(nproc)
```