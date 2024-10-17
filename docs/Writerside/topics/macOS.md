# macOS

Building on linux has been tested on
- `macos-14` (github runner)
- `MacOS 15.0.1 Sequoia` (Native)
- `debian:bookworm` (docker tag)

## Install dependencies

<tabs>
<tab title="Native">
<code-block>
$ # install xcode 15.4 (or current latest)
$ brew install ccache unbound boost@1.76 zmq autoconf automake libtool 
$ brew link boost@1.76
</code-block>
</tab>
<tab title="Native (Rosetta2)">
<code-block>
$ # install xcode 15.4 (or current latest)
$ brew install ccache unbound boost@1.76 zmq autoconf automake libtool 
$ brew link boost@1.76
$ arch -x86_64 brew install ccache unbound boost@1.76 zmq autoconf automake libtool 
$ arch -x86_64 brew link boost@1.76
</code-block>
</tab>
<tab title="Linux">
<code-block>
$ apt update
$ apt install -y build-essential pkg-config autoconf libtool \
      ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf \
      python-is-python3
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
<tab title="Native for x86_64 macOS">
<code-block>
$ ./build_single.sh monero x86_64-host-apple-darwin -j$(nproc)
</code-block>
</tab>
<tab title="Native for aarch64 macOS">
<code-block>
$ ./build_single.sh monero aarch64-host-apple-darwin -j$(nproc)
</code-block>
</tab>
<tab title="Native for x86_64 macOS (Rosseta2)">
<code-block>
$ arch -x86_64 ./build_single.sh monero x86_64-host-apple-darwin -j$(nproc)
</code-block>
</tab>
<tab title="Linux for x86_64 macOS">
<code-block>
$ ./build_single.sh monero x86_64-apple-darwin11 -j$(nproc)
</code-block>
</tab>
<tab title="Linux for aarch64 macOS">
<code-block>
$ ./build_single.sh monero aarch64-apple-darwin-11 -j$(nproc)
</code-block>
</tab>
</tabs>

## Known issues

### Creating fat library

[Check cake_wallet solution](https://github.com/cake-tech/cake_wallet/blob/main/scripts/macos/build_monero_all.sh)