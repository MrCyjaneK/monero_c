ANDROID_API=21
host_toolchain=nonexistent
ifeq ($(host_arch),armv7a)
host_toolchain=armv7a-linux-androideabi${ANDROID_API}-
endif
ifeq ($(host_arch),x86_64)
host_toolchain=x86_64-linux-android${ANDROID_API}-
endif
ifeq ($(host_arch),i686)
host_toolchain=i686-linux-android${ANDROID_API}-
endif
ifeq ($(host_arch),aarch64)
host_toolchain=aarch64-linux-android${ANDROID_API}-
endif

android_CC=$(host_toolchain)clang
android_CXX=$(host_toolchain)clang++
android_RANLIB=llvm-ranlib
android_AR=llvm-ar

android_CFLAGS=-pipe
android_CXXFLAGS=$(android_CFLAGS)
android_ARFLAGS=crsD

android_release_CFLAGS=-O2
android_release_CXXFLAGS=$(android_release_CFLAGS)

android_debug_CFLAGS=-g -O0
android_debug_CXXFLAGS=$(android_debug_CFLAGS)

android_native_toolchain=android_ndk

