# wallet2_api.h (but this time C compatible)

> Wrapper around wallet2_api.h that can be called using C api.

## Building

TL;DR: 

```bash
$ rm -rf monero wownero release
$ git submodule update --init --recursive --force
$ for coin in monero wownero zano; do ./apply_patches.sh $coin; done
```

Broken? Not working? Need help? https://moneroc.mrcyjanek.net/
