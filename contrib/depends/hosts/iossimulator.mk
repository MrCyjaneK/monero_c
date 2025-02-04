IOS_MIN_VERSION=12.0
IOS_SDK=$(shell xcrun --sdk iphonesimulator --show-sdk-path)

ifeq (aarch64, $(host_arch))
CC_target_iossimulator=arm64-apple-ios-simulator
iossimulator_host=arm64-apple-darwin
aarch64_iossimulator_host=arm64-apple-darwin
else
CC_target_iossimulator=x86_64-apple-ios-simulator
iossimulator_host=x86_64-apple-darwin
x86_64_iossimulator_host=x86_64-apple-darwin
endif
iossimulator_CC=$(shell xcrun -f clang) -target $(CC_target_iossimulator) -mios-version-min=$(IOS_MIN_VERSION) --sysroot $(IOS_SDK)
iossimulator_CXX=$(shell xcrun -f clang++) -target $(CC_target_iossimulator) -mios-version-min=$(IOS_MIN_VERSION) --sysroot $(IOS_SDK) -stdlib=libc++ -std=c++14
iossimulator_AR:=$(shell xcrun -f ar)
iossimulator_RANLIB:=$(shell xcrun -f ranlib)
iossimulator_STRIP:=$(shell xcrun -f strip)
iossimulator_LIBTOOL:=$(shell xcrun -f libtool)
iossimulator_OTOOL:=$(shell xcrun -f otool)
iossimulator_NM:=$(shell xcrun -f nm)
iossimulator_INSTALL_NAME_TOOL:=$(shell xcrun -f install_name_tool)
iossimulator_native_toolchain=


iossimulator_CFLAGS=-pipe
iossimulator_CXXFLAGS=$(iossimulator_CFLAGS)