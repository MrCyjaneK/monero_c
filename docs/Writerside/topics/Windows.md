# Windows

Building on windows has been tested on
- `debian:bullseye` (docker tag)
- `Ubuntu 22.04 WSL`

## Install dependencies

<tabs>
<tab title="x86_64">
<code-block>
$ apt update
$ apt install -y build-essential pkg-config autoconf libtool \
    ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf \
    gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64
</code-block>
</tab>
<tab title="i686">
<code-block>
$ apt update
$ apt install -y build-essential pkg-config autoconf libtool \
    ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf \
    gcc-mingw-w64-i686 g++-mingw-w64-i686
</code-block>
</tab>
</tabs>

## Prepare source

> If you are running in docker or have not configured git you may need to do the following:
> ```bash
> git config --global --add safe.directory '*'
> git config --global user.email "ci@mrcyjanek.net"
> git config --global user.name "CI mrcyjanek.net"
> ```

```bash
$ git clone https://github.com/mrcyjanek/monero_c --recursive
$ cd monero_c
$ ./apply_patches.sh monero
```

## Building

<tabs>
<tab title="x86_64">
<code-block>
$ ./build_single.sh monero x86_64-w64-mingw32 -j$(nproc)
</code-block>
</tab>
<tab title="i686">
<code-block>
$ ./build_single.sh monero i686-w64-mingw32 -j$(nproc)
</code-block>
</tab>
</tabs>

## Known issues

### Dynamically loaded dependencies

There are some dynamically loaded dependencies which are copied over from the OS package repository. All of them are
available in `release/` directory.