IOS_MIN_VERSION=12.0
IOS_SDK=$(shell xcrun --sdk iphoneos --show-sdk-path)

ifeq (aarch64, $(host_arch))
CC_target_ios=arm64-apple-ios
else
CC_target_ios=x86_64-apple-ios
endif

ios_CC=$(shell xcrun -f clang) -target $(CC_target_ios) -mios-version-min=$(IOS_MIN_VERSION) --sysroot $(IOS_SDK)
ios_CXX=$(shell xcrun -f clang++) -target $(CC_target_ios) -mios-version-min=$(IOS_MIN_VERSION) --sysroot $(IOS_SDK) -stdlib=libc++ -std=c++14
ios_AR:=$(shell xcrun -f ar)
ios_RANLIB:=$(shell xcrun -f ranlib)
ios_STRIP:=$(shell xcrun -f strip)
ios_LIBTOOL:=$(shell xcrun -f libtool)
ios_OTOOL:=$(shell xcrun -f otool)
ios_NM:=$(shell xcrun -f nm)
ios_INSTALL_NAME_TOOL:=$(shell xcrun -f install_name_tool)
ios_native_toolchain=


ios_CFLAGS=-pipe
ios_CXXFLAGS=$(ios_CFLAGS)