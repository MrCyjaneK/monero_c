# Building

Building monero_c comes down to these simple steps:
```bash
$ git clone https://github.com/mrcyjanek/monero_c --recursive
$ ./apply_patches.sh monero # patch the libraries
$ ./build_single x86_64-linux-gnu -j$(nproc)
```

To get detailed information about building please select your host platform (the one that you will use to build the
monero wallet)

- [I'm scared. How can I use prebuilds?](Using-prebuilds.md)
- [Linux](#linux)
- [macOS](#macos)
- [Windows](#windows)

## Supported systems

| Target           | Builder                     | Notes                                                                            |
|------------------|-----------------------------|----------------------------------------------------------------------------------|
| Windows          | Linux, Docker, WSL2         | msys2 builds are not supported, there are hardcoded DLL paths in build_single.sh |
| macOS            | Native, Linux, Docker, WSL2 | Native builds are being widely used, but are not endorsed by me personally.      |
| iOS              | macOS                       |                                                                                  |
| Android          | Linux, Docker, WSL2         |                                                                                  |
| Linux            | Native, Docker, WSL2        |                                                                                  |
| Linux/SailfishOS | Native, Docker              | Required meego toolchain.                                                        | 

All supported systems are built on CI, so for the most up-to-date list of all supported systems, together with proper
dependencies please take a look at [full_check.yml](https://github.com/MrCyjaneK/monero_c/blob/master/.github/workflows/full_check.yaml)
file.

### Linux

Linux builds should be built on as old of a distro as possible - targeting `debian:oldoldstable`, main reason for that
is GLIBC compatibility (or lack of it). For some reason software compiled with newer GLIBC won't work on devices with
older GLIBC, so the solution is to simply build on the oldest possible os (or abandon GLIBC and use musl).

- x86-64-linux-gnu
- i686-linux-gnu - deprecated by monero
- aarch64-linux-gnu

[More details](Linux.md)

#### SailfishOS

Fully supported (except for armv7l devices).

- i686-meego-linux-gnu
- aarch64-meego-linux-gnu

More details: TBD

#### Alpine Linux

Requires dependency removed by upstream - it is preserved in `external/alpine/libexecinfo`. It could easily
be brought back - but since nobody uses it and nobody complained about it missing it kind of never landed in monero_c
after rewrite fully. That being said it should mostly work.

- ~~x86_64-alpine-linux-musl~~
- ~~aarch64-alpine-linux-musl~~

More details: TBD

### Android

Includes bumped NDK version

- x86_64-linux-android
- ~~i686-linux-android~~ - unsupported, fails to build
- aarch64-linux-android
- armv7a-linux-androideabi

[More details](Android.md)

### Windows

Msys2 shell is not supported, docker or WSL2 is requried to build

- i686-w64-mingw32 - deprecated by monero
- x86_64-w64-mingw32
- aarch64-w64-unknown - unsupported.
  Though - if somebody can grab and send me a decent CopilotPC I'll be happy to work on that. As for now using x86_64
  build should be fine (but slower in runtime) solution.

[More details](Windows.md)

### macOS

- x86_64-apple-darwin11
- aarch64-apple-darwin11
- host-apple-darwin
- x86_64-host-apple-darwin - alias for host-apple-darwin
- aarch64-host-apple-darwin alias for host-apple-darwin

[More details](macOS.md)

### iOS
- host-apple-ios - probably will be renamed to `aarch64-apple-ios`