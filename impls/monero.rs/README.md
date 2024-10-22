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
### Build or download `monero_c` library
Build or download the `monero_c` library for your architecture.  Follow the 
upstream docs at https://github.com/MrCyjaneK/monero_c or download the latest 
release from https://github.com/MrCyjaneK/monero_c/releases.  The library can be 
placed in one of several supported locations relative to the binary in use:
- `../../../../release` (as in `monero_c/release`)
- `../../lib` (as in `monero_c/impls/monero_rust/lib`)
- `.` (as in `monero_c/impls/monero_rust/target/debug` or `release`)

and should match your platform as in:
- Android: `libmonero_libwallet2_api_c.so`
- iOS: `MoneroWallet.framework/MoneroWallet`
- Linux: `monero_libwallet2_api_c.so`
- macOS: `monero_libwallet2_api_c.dylib`
- Windows: `monero_libwallet2_api_c.dll`

### Run demo
With the library in a supported location, from `monero_c/impls/monero_rust`:
```
cargo run
```

## Using `monero_rust` in your own crate
Refer to the `example` folder.  Library placement is the same as for the demo. 
