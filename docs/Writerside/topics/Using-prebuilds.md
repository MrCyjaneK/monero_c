# Using prebuilds

Prebuilds are more convenient way of using monero_c in your code (although these builds should **NOT** be used in
production). There are several ways in which you can use prebuilds

## The monero_c way

1. Go to https://github.com/MrCyjaneK/monero_c/releases
2. Click on the release that you are interested in
3. Download release-bundle.zip
4. Unzip it in monero_c directory

That zip file contains all builds that monero_c supports prepared in the exactly same way as you would prepare them if
building on your own. This is the easiest way to get started.

> Keep in mind that release-bundle.zip contains .xz files inside, so if you want to actually use them you need to use
> them you need to unxz them first
> ```bash
> $ unxz -f -k release/*/*.xz
> ```

## The monero_c way (different)

Alternatively you can go to releases tab and grab whatever you need, there are over 40 libraries. Surely one will fit 
your use case.

## The build_moneroc.sh way

This method is used by [xmruw](https://github.com/mrcyjanek/unnamed_monero_wallet) and 
[monero-tui](https://github.com/Im-Beast/monero-tui).

It supports both building and downloading prebuilds and putting them in correct location, [have a look at the code 
yourself](https://github.com/MrCyjaneK/unnamed_monero_wallet/blob/master-rewrite/build_moneroc.sh)

```bash
$ ./build_moneroc.sh
    --prebuild # allow downloads of prebuilds
    --coin # monero/wownero 
    --tag v0.18.3.3-RC45 # which tag to build / download
    --triplet x86_64-linux-android # which triplet to build / download
    --location android/.../jniLibs/x86_64 # where to but the libraries
```

## The cake wallet way

There is a simple script in cake_wallet written in `dart` that runs on all platform (including windows) which downloads
all required libraries for selected platforms in one go. 
[You can take look at it here](https://github.com/cake-tech/cake_wallet/blob/main/tool/download_moneroc_prebuilds.dart)