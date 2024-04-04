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
| host-apple-darwin      | arm64-apple-darwin23 | dependencies: `brew install unbound boost zmq` |
| host-apple-ios         | arm64-apple-darwin23 |       |

Libraries on CI are build using the following docker images:
- git.mrcyjanek.net/mrcyjanek/debian:buster
- git.mrcyjanek.net/mrcyjanek/debian:bookworm

It is entirely possible to use upstream debian:buster / debian:bookworm

## Contributing

To contribute you can visit git.mrcyjanek.net/mrcyjanek/monero_c and open a PR, alternatively use any other code mirror or send patches directly.

**IMPORTANT** I don't have time to write better README, please check `build_single.sh` for build instructions, in general it comes down to running the script.