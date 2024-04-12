
> 0001 to 0004 were created most likely by feather dev, anonero monero repository got nuked and now says that I made the changes, so I am unable to credit the original authors, http://git.anonero5wmhraxqsvzq2ncgptq6gq45qoto6fnkfwughfl4gbt44swad.onion/ANONERO/monero/commits/branch/v0.18.3.3-anonero 


# 0001-polyseed

Polyseed support for wallets [planned in long distant future as a part of walet3 - not getting upstream, no PR available].

Note, only English support is available due to issues with normalization libraries.

> tobtoht: You may also want to reconsider supporting languages other than English: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki#wordlists (this is about BIP39, but because unicode normalization is such a PITA it will become true for Polyseed wallets as well)

Considering the fact that even Feather Wallet doesn't support non-english seeds, it makes sense to go that way.

At least until (if ever) feather wallet supports multi-language polyseed seeds I don't think it is a good idea to support them, especially because of possible issues when targetting different platforms.

# 0002-background-sync

Sourced from: https://github.com/monero-project/monero/pull/8617, no changes except for merge conflicts.

# 0003-airgap

Cool functions for offline transactions

# 0004-coin-control

Coin control patch, I was able to trace it's orgins back to wownero/monerujo.

# 0005-fix-build

Fix cross compilation for linux

# 0006-macos-build-fix

Fixes cross compilation for MacOS targets

# 0007-fix-make-debug-test-target

I had some debugging to do, I don't remember actually why I decided to run the tests, but since it is a fix I've decided to leave it in here just in case.

# 0008-fix-missing-___clear_cache-when-targetting-iOS

https://github.com/tevador/RandomX/pull/294