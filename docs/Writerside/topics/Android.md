# Android

Building on linux has been tested on
- `ubuntu:22.04` (docker tag)

## Install dependencies

```bash
$ apt update
$ apt install -y build-essential pkg-config autoconf libtool \
    ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf \
    unzip python-is-python3
```

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
$ ./build_single.sh monero x86_64-linux-android -j$(nproc)
</code-block>
</tab>
<tab title="aarch64">
<code-block>
$ ./build_single.sh monero aarch64-linux-android -j$(nproc)
</code-block>
</tab>
<tab title="armv7a">
<code-block>
$ ./build_single.sh monero armv7a-linux-androideabi -j$(nproc)
</code-block>
</tab>
</tabs>

## Known issues

None. Open an issue if you find something not working.