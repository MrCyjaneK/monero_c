# `monero_c/impls/monero.rs/example`
Refer to the latest documentation at
https://github.com/MrCyjaneK/monero_c/blob/master/README.md and
https://github.com/MrCyjaneK/monero_c/blob/master/impls/monero.rs/README.md for 
the latest documentation.

## `monero_c` library
A `monero_c` library is required to use these bindings.  Build or download the 
`monero_c` library for your architecture.  Follow the upstream docs at 
https://github.com/MrCyjaneK/monero_c or download the latest release from 
https://github.com/MrCyjaneK/monero_c/releases.  The library can be placed in 
one of several supported locations relative to the binary in use:
- `.`
  that is, if your binary is in `target/debug` or `target/release`, the library
  should also be adjacent to the binary in `release` or `debug`, respectively.
  If you're distributing your binary, place the library in the same directory.
- `../../lib`
  so if your binary gets built to `target/profile`, then your library can be 
  in `lib`.
- `../../../../release`
  which is a holdover from the original `monero_c` bindings and may not be
  practical for your project unless it's also structured as a child of the 
  `monero_c` repository.

and should match your platform as in:
- Android: `libmonero_libwallet2_api_c.so`
- iOS: `MoneroWallet.framework/MoneroWallet`
- Linux: `monero_libwallet2_api_c.so`
- macOS: `monero_libwallet2_api_c.dylib`
- Windows: `monero_libwallet2_api_c.dll`
