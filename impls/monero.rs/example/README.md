# `monero_c/impls/monero.rs/example`
Refer to the latest documentation at
https://github.com/MrCyjaneK/monero_c/blob/master/README.md and
https://github.com/MrCyjaneK/monero_c/blob/master/impls/monero.rs/README.md for 
the latest documentation.

## `monero_c` library
A `monero_c` library is required to use these bindings.  Build or download the 
`monero_c` library for your architecture.  Follow the upstream docs at 
https://github.com/MrCyjaneK/monero_c or download the latest release from 
https://github.com/MrCyjaneK/monero_c/releases.  The library should then be 
placed adjacent to the binary: that is, if your binary is in `target/debug` or 
`target/release`, the library should also be in `release` or `debug`, 
respectively.  Its name should match your platform as in:
- Android: `libmonero_libwallet2_api_c.so`
- iOS: `MoneroWallet.framework/MoneroWallet`
- Linux: `monero_libwallet2_api_c.so`
- macOS: `monero_libwallet2_api_c.dylib`
- Windows: `monero_libwallet2_api_c.dll`

Also symlink "libmonero_libwallet2_api_c.so" and "libwallet2_api_c.so" to "monero_libwallet2_api_c.so".  TODO: Test symlinking requirements on all non-Linux platforms.
