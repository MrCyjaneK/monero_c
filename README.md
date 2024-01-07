# wallet2_api.h (but this time C compatible)

Wrapper around wallet2_api.h that can be called using C api.

## Contributing

To contribute you can visit git.mrcyjanek.net/mrcyjanek/monero_c and open a PR, alternatively use any other code mirror or send patches directly.

## Building (android)

Builds are provided in the [release tab](https://git.mrcyjanek.net/mrcyjanek/monero_c/releases), built using Gitea Runners. Building locally is possible as well, althought it is rather a heavy task which takes ~2 hours to finish (excluding enviroment setup and some downloads).

Base image for the runner is `git.mrcyjanek.net/mrcyjanek/androidndk:r17c`, which contains preinstalled NDK. `Dockerfile` can be obtained from [mrcyjanek/CIimages](https://git.mrcyjanek.net/mrcyjanek/CIimages/src/branch/master/Dockerfile.androidndk-r17c) repository.

Then to build `.github/workflows/*.yml` files are used.

Local build?

```bash
$ act --pull=false -Pandroidndk-r17c=git.mrcyjanek.net/mrcyjanek/androidndk:r17c
```

For development?

```bash
$ timeout 5 act --pull=false -Pandroidndk-r17c=git.mrcyjanek.net/mrcyjanek/androidndk:r17c # needed to clear cache.
$ act --pull=false -Pandroidndk-r17c=git.mrcyjanek.net/mrcyjanek/androidndk:r17c --reuse
$ docker ps
CONTAINER ID IMAGE .....................................
d0626dcd8c5d git.mrcyjanek.net/mrcyjanek/androidndk:r17c ....
$ docker commit d0626dcd8c5d monero_c:dev
$ docker run --rm -it \
    -v $PWD/libbridge:/opt/wspace/libbridge_up \
    --entrypoint /bin/bash \
    monero_c:dev
[docker] $ export 'PATH=/usr/cmake-3.14.6-Linux-x86_64/bin:/opt/android/toolchain/aarch64-linux-android/bin:/opt/android/toolchain/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
    && cd /opt/wspace/libbridge_up \
    && rm -rf build && mkdir build && cd build \
    && env CC=clang CXX=clang++ cmake -DANDROID_ABI=-arm64-v8a .. \
    && make
# Resulting file will be available in the current directory.
```
