# `monero_c/impls/monero.rs/example`
Refer to https://github.com/MrCyjaneK/monero_c/blob/master/README.md and 
https://github.com/MrCyjaneK/monero_c/blob/master/impls/monero.rs/README.md for 
the latest documentation.

## `monero_c` library
A `monero_c` library is required to build this example.  Build or download the 
`monero_c` library for your architecture.  Follow the upstream docs at 
https://github.com/MrCyjaneK/monero_c or download the latest release from 
https://github.com/MrCyjaneK/monero_c/releases.  The library should then be 
placed adjacent to the binary: that is, if your binary is in `target/debug` or 
`target/release`, the library should also be in `release` or `debug`, 
respectively.  Its name should also match your platform as in:
- Android: `libmonero_libwallet2_api_c.so`
- iOS: `MoneroWallet.framework/MoneroWallet`
- Linux: `monero_libwallet2_api_c.so`
- macOS: `monero_libwallet2_api_c.dylib`
- Windows: `monero_libwallet2_api_c.dll`

On Linux you must also symlink "libmonero_libwallet2_api_c.so" and 
"libwallet2_api_c.so" to "monero_libwallet2_api_c.so".  Other systems will also 
need similar symlinks or copies.
