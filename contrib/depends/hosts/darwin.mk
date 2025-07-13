OSX_MIN_VERSION=10.15
LD64_VERSION=609
ifeq (aarch64, $(host_arch))
CC_target=arm64-apple-$(host_os)
else
CC_target=$(host)
endif
darwin_CC=clang
darwin_CXX=clang++
darwin_RANLIB=$(host_prefix)/native/bin/$(host)-ranlib
darwin_AR=$(host_prefix)/native/bin/$(host)-ar
darwin_CFLAGS=-pipe -target $(CC_target) -mmacosx-version-min=$(OSX_MIN_VERSION) --sysroot $(host_prefix)/native/SDK/ -mlinker-version=$(LD64_VERSION) -B$(host_prefix)/native/bin/$(host)-
darwin_CXXFLAGS=$(darwin_CFLAGS) -stdlib=libc++
darwin_ARFLAGS=cr

darwin_release_CFLAGS=-O3
darwin_release_CXXFLAGS=$(darwin_release_CFLAGS)

darwin_debug_CFLAGS=-O3
darwin_debug_CXXFLAGS=$(darwin_debug_CFLAGS)

darwin_native_toolchain=native_cctools darwin_sdk
