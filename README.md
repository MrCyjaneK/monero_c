# wallet2_api.h (but this time C compatible)

> Wrapper around wallet2_api.h that can be called using C api.

## Contributing

To contribute you can visit git.mrcyjanek.net/mrcyjanek/monero_c and open a PR, alternatively use any other code mirror or send patches directly.

**IMPORTANT** I don't have time to write better README, please check Makefile for build instructions, in general it comes down to:

```bash
$ make download
$ make host_depends
$ make monero_linux_amd64 # or else, depending on your OS/arch
$ make moneroc_linux_amd64 # or else, depending on your OS/arch
```