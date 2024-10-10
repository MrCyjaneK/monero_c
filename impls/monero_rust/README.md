# `monero_rust`
`monero_c` bindings for Rust.

## Getting started
<!--
### Prerequisites
You may need
```
sudo apt-get install libhidapi-dev
```
-->
1. Build `monero_c`
2. Copy the `monero_c` library to `monero_rust`.
3. Run `monero_rust` example

### Build `monero_c`
Build a monero_c static Library for your architecture.  Follow the upstream docs
at https://github.com/MrCyjaneK/monero_c or for example:
```
./scripts/build_monero_c.sh
```
<!-- TODO add param for arch -->

or manually:
```
git clone https://git.mrcyjanek.net/sneurlax/monero_c --branch rust
cd monero_c
git submodule update --init --recursive
rm -rf monero wownero release # Clean any previous builds.
git submodule update --init --recursive --force
./apply_patches.sh monero
./build_single.sh monero x86_64-linux-gnu -j$(nproc)
```
<!-- TODO add unxz etc -->

### Copy the `monero_c` library to `monero_rust`. 
Copy your `libwallet` library to `monero_c/impls/monero_rust/lib`.
```
cp build/release/monero/x86_64-linux-gnu_libwallet2_api_c.so ../lib
mv ../lib/x86_64-linux-gnu_libwallet2_api_c.so ../lib/libx86_64-linux-gnu_libwallet2_api_c.so
```
<!-- TODO automatically copy and rename using arch param IAW TODO above -->

### Run `monero_rust` example
From `monero_c/impls/monero_rust`:
```
cargo run
```
