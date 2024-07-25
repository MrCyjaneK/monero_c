# wallet2_api.h (but this time C compatible)

> Wrapper around wallet2_api.h that can be called using C api.

[![status-badge](https://ci.mrcyjanek.net/api/badges/5/status.svg?branch=rewrite-wip)](https://ci.mrcyjanek.net/repos/5/branches/rewrite-wip)

## Building

to "clean" everything:

```bash
$ rm -rf monero wownero release
$ git submodule update --init --recursive --force
```

fix ownership (if you build in docker but clone as a local user)

```bash
$ sudo chown $(whoami) . -R
```

patch codebase

```bash
$ ./apply_patches.sh monero
$ ./apply_patches.sh wownero
```

build monero_c

```bash
$ ./build_single.sh monero  x86_64-linux-gnu -j$(nproc)
                    wownero i686-linux-gnu
                            aarch64-linux-gnu
                            x86_64-linux-android
                            i686-linux-android
                            aarch64-linux-android
                            arm-linux-androideabi
                            i686-w64-mingw32
                            x86_64-w64-mingw32
                            host-apple-darwin
                            host-apple-ios
```

While building I aim to compile the code at oldest supported release of debian, using default toolchain to ensure that all linux distributions are able to run monero_c libraries, below I present a supported builders for given targets

|           x            | builder              | notes |
| ---------------------- | -------------------- | ----- |
| x86_64-linux-gnu       | debian:buster        |       |
| i686-linux-gnu         | debian:buster        |       |
| aarch64-linux-gnu      | debian:buster        |       |
| x86_64-linux-android   | debian:buster        |       |
| i686-linux-android     | debian:buster        |       |
| aarch64-linux-android  | debian:buster        |       |
| arm-linux-androideabi  | debian:buster        |       |
| i686-w64-mingw32       | debian:buster        | hardcoded DLL paths in build_single.sh |
| x86_64-w64-mingw32     | debian:buster        |  -"-  |
| x86_64-apple-darwin11  | debian:bookworm      | extra build step: `${HOST_ABI}-ranlib $PWD/$repo/contrib/depends/${HOST_ABI}/lib/libpolyseed.a` |
| aarch64-apple-darwin11 | debian:bookworm      |  -"-  |
| host-apple-darwin      | arm64-apple-darwin23 | dependencies: `brew install unbound boost@1.76 zmq && brew link boost@1.76` |
| host-apple-ios         | arm64-apple-darwin23 |       |

## Design

Functions are as simple as reasonably possible as few steps should be performed to get from the exposed C api to actual wallet2 (or wallet3 in future) api calls.

The only things passed in and out are:

- void
- bool
- int
- uint64_t
- void*
- const char* 

All more complex structures are serialized into `const char*`, take look at MONERO_Wallet_createTransaction which uses `splitString(std::string(preferredInputs), std::string(separator));` to convert string into a std::set, so no implementation will need to worry about that.

Is there more effective way to do that? Probably. Is there more universal way to pass that (JSON, or others?)? Most likely. That being said, I'm against doing that. You can easily join a string in any language, and I like to keep dependency count as low as possible.

As for function naming `${COIN}_namespaceOrClass_functionName` is being used, currently these cryptocurrencies are supported

- monero
- wownero

both using wallet2 api, and both being patched with our secret ingredient(tm) (check patches directory).

Since monero_c aims to be one-fits-all solution for monero wallets, there are some special things inside, like functions prefixed with `DEBUG_*`, these are not quarenteed to stay in the code, and can be changed, the only reason they are in is because I needed some testing early in the development when bringing support for variety of platforms.

If you are a wallet developer and you **really** need this one function that doesn't exist, feel free to let me know I'll be happy to implement that.

Currently there are enterprise resitents in our library: `${COIN}_cw_*` these functions are not guaranteed to stay stable, and are made for cake wallet to implement features that are not used in xmruw nor in stack_wallet (which I need to double-check later?).

## Contributing

To contribute you can visit git.mrcyjanek.net/mrcyjanek/monero_c and open a PR, alternatively use any other code mirror or send patches directly.