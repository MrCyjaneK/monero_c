# `monero_rust`
Proof of concept `monero_c` bindings for Rust.

## Getting started
<!--
### Prerequisites
You may need
```
sudo apt-get install libhidapi-dev
```
-->
### Build `monero_c`
Build the monero_c library for your architecture.  Follow the upstream docs at 
https://github.com/MrCyjaneK/monero_c <!-- TODO: use example CMakeLists --> and 
place the library at `monero_c/impls/monero_rust/lib/libwallet2_api_c.so` or use 
the provided script:
```
cd scripts
./build_monero_c.sh
```

or build it manually as in:
```
git clone https://git.mrcyjanek.net/MrCyjaneK/monero_c --branch rust
cd monero_c
git submodule update --init --recursive
rm -rf monero wownero release # Clean any previous builds.
git submodule update --init --recursive --force
./apply_patches.sh monero
./build_single.sh monero x86_64-linux-gnu -j$(nproc)

# Adjust the commands below for your arch.
unxz -f release/monero/x86_64-linux-gnu_libwallet2_api_c.so.xz
mv release/monero/x86_64-linux-gnu_libwallet2_api_c.so ../lib/libwallet2_api_c.so
# The library should be at monero_c/impls/monero_rust/lib/libwallet2_api_c.so.
```

### Run `monero_rust` demo
From `monero_c/impls/monero_rust`:
```
cargo run
```

## Using `monero_rust` in your own crate
Refer to the `example` folder.  `libwallet2_api_c.so` must be in the same 
directory as the binary (*eg.* at `example/target/debug/libwallet2_api_c.so`).
