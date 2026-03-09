#!/bin/bash

cd $(dirname $0);

outfile="$1";

function usage {
    echo "Usage: HOST=$(gcc -dumpmachine) $0 outfile";
}

if [[ "x$outfile" == "x" ]];
then
    usage
    echo "outfile not specified"
    exit 1;
fi

if [[ "x$HOST" == "x" ]];
then
    usage
    echo "HOST env missing"
    exit 2
fi

outdir=$(dirname $outfile)
if [[ ! -d "$outdir" ]];
then
    usage
    echo "$outdir doesn't exist"
    exit 3
fi

set -x
source $HOST/_source_me

sed -e "s|@HOST@|$TARGET|g" \
    -e "s|@CC@|$CC|g" \
    -e "s|@CXX@|$CXX|g" \
    -e "s|@AR@|$AR|g" \
    -e "s|@RANLIB@|$RANLIB|g" \
    -e "s|@NM@|$NM|g" \
    -e "s|@STRIP@|$STRIP|g" \
    -e "s|@CFLAGS@|$CFLAGS|g" \
    -e "s|@CXXFLAGS@|$CXXFLAGS|g" \
    -e "s|@CPPFLAGS@|$CPPFLAGS|g" \
    -e "s|@LDFLAGS@|$LDFLAGS|g" \
    -e "s|@release_type@|Release|g" \
    -e "s|@build_tests@|OFF|g" \
    -e "s|@cmake_system_name@|$CMAKE_SYSTEM_NAME|g" \
    -e "s|@prefix@|$PREFIX|g" \
    -e "s|@nativeprefix@|$NATIVEPREFIX|g" \
    -e "s|@arch@|$ARCH|g" > $outfile <<EOF
cmake_minimum_required(VERSION 3.13)  # Ensure CMake version supports CMP0077
cmake_policy(SET CMP0077 NEW)         # Ensure 'option' honors normal variables

# Set the system name to one of Android, Darwin, iOS, FreeBSD, Linux, or Windows
SET(CMAKE_SYSTEM_NAME @cmake_system_name@)
SET(CMAKE_SYSTEM_PROCESSOR @arch@)
SET(CMAKE_BUILD_TYPE @release_type@)
SET(CMAKE_CXX_STANDARD 14)
LIST(APPEND CMAKE_PROGRAM_PATH @nativeprefix@/bin)
SET(MANUAL_SUBMODULES true)
OPTION(STATIC "Link libraries statically" ON)
OPTION(TREZOR_DEBUG "Main trezor debugging switch" OFF)
OPTION(BUILD_TESTS "Build tests." OFF)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

SET(STATIC ON)
SET(UNBOUND_STATIC ON)
SET(ARCH "default")

SET(BUILD_TESTS @build_tests@)
SET(TREZOR_DEBUG @build_tests@)

# where is the target environment
SET(CMAKE_FIND_ROOT_PATH @prefix@ /usr)

SET(ENV{PKG_CONFIG_PATH} @prefix@/lib/pkgconfig)

SET(Readline_ROOT_DIR @prefix@)
SET(Readline_INCLUDE_DIR @prefix@/include)
SET(Readline_LIBRARY @prefix@/lib/libreadline.a)
SET(Terminfo_LIBRARY @prefix@/lib/libtinfo.a)

SET(UNBOUND_INCLUDE_DIR @prefix@/include)
SET(UNBOUND_LIBRARIES @prefix@/lib/libunbound.a)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Android")
SET(LIBUNWIND_INCLUDE_DIR @prefix@/include)
SET(LIBUNWIND_LIBRARIES @prefix@/lib/libunwind.a)
SET(LIBUNWIND_LIBRARY_DIRS @prefix@/lib)
if(NOT CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
SET(LIBUSB-1.0_LIBRARY @prefix@/lib/libusb-1.0.a)
SET(LIBUDEV_LIBRARY @prefix@/lib/libudev.a)

SET(Protobuf_FOUND 1)
SET(Protobuf_PROTOC_EXECUTABLE @nativeprefix@/bin/protoc CACHE FILEPATH "Path to the native protoc")
SET(Protobuf_INCLUDE_DIR @prefix@/include CACHE PATH "Protobuf include dir")
SET(Protobuf_INCLUDE_DIRS @prefix@/include CACHE PATH "Protobuf include dir")
SET(Protobuf_LIBRARY @prefix@/lib/libprotobuf.a CACHE FILEPATH "Protobuf library")
endif()

endif()

SET(ZMQ_INCLUDE_PATH @prefix@/include)
SET(ZMQ_LIB @prefix@/lib/libzmq.a)

SET(Boost_IGNORE_SYSTEM_PATH ON)
SET(BOOST_ROOT @prefix@)
SET(BOOST_INCLUDEDIR @prefix@/include)
SET(BOOST_LIBRARYDIR @prefix@/lib)
SET(Boost_IGNORE_SYSTEM_PATHS_DEFAULT OFF)
SET(Boost_NO_SYSTEM_PATHS ON)
SET(Boost_USE_STATIC_LIBS ON)
SET(Boost_USE_STATIC_RUNTIME ON)

SET(OPENSSL_ROOT_DIR @prefix@)
SET(ARCHITECTURE @arch@)

# for libraries and headers in the target directories
set (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER) # Find programs on host
set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY) # Find libs in target
set (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY) # Find includes in target

add_definitions(-DHIDAPI_DUMMY=ON)
set(HIDAPI_DUMMY ON)

# specify the cross compiler to be used. Darwin uses clang provided by the SDK.
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  if(ARCHITECTURE STREQUAL "aarch64")
    SET(CLANG_TARGET "arm64-apple-darwin11")
    SET(CONF_TRIPLE "aarch64-apple-darwin11")
    SET(BUILD_TAG "mac-armv8")
    SET(CMAKE_OSX_ARCHITECTURES "arm64")
    set(ARM ON)
    set(ARM_ID "armv8-a")
  else()
    SET(CLANG_TARGET "x86_64-apple-darwin11")
    SET(CONF_TRIPLE "x86_64-apple-darwin11")
    SET(BUILD_TAG "mac-x64")
    SET(CMAKE_OSX_ARCHITECTURES "x86_64")
  endif()
  SET(_CMAKE_TOOLCHAIN_PREFIX @nativeprefix@/bin/\${CONF_TRIPLE}-)
  SET(CMAKE_C_COMPILER @CC@)
  SET(CMAKE_C_COMPILER_TARGET \${CLANG_TARGET})
  SET(CMAKE_C_FLAGS_INIT -B\${_CMAKE_TOOLCHAIN_PREFIX})
  SET(CMAKE_CXX_COMPILER @CXX@)
  SET(CMAKE_CXX_COMPILER_TARGET \${CLANG_TARGET})
  SET(CMAKE_CXX_FLAGS_INIT -B\${_CMAKE_TOOLCHAIN_PREFIX})
  SET(CMAKE_ASM_COMPILER_TARGET \${CLANG_TARGET})
  SET(CMAKE_ASM-ATT_COMPILER_TARGET \${CLANG_TARGET})
  SET(APPLE True)
  SET(BUILD_64 ON)
  SET(BREW OFF)
  SET(PORT OFF)
  SET(CMAKE_OSX_DEPLOYMENT_TARGET "10.14")
  SET(CMAKE_CXX_STANDARD 14)
  SET(LLVM_ENABLE_PIC OFF)
  SET(LLVM_ENABLE_PIE OFF)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
  add_definitions(-DUSE_DEVICE_TREZOR=OFF)
  SET(ANDROID TRUE)
  if(ARCHITECTURE STREQUAL "armv7a")
    SET(CMAKE_ANDROID_ARCH_ABI "armeabi-v7a")
    SET(CMAKE_SYSTEM_PROCESSOR "armv7-a")
    SET(CMAKE_ANDROID_ARM_MODE ON)
    SET(CMAKE_C_COMPILER_TARGET armv7a-linux-androideabi21)
    SET(CMAKE_CXX_COMPILER_TARGET armv7a-linux-androideabi21)
    SET(_CMAKE_TOOLCHAIN_PREFIX armv7a-linux-androideabi21-)
  elseif(ARCHITECTURE STREQUAL "aarch64")
    SET(CMAKE_ANDROID_ARCH_ABI "arm64-v8a")
    SET(CMAKE_SYSTEM_PROCESSOR "aarch64")
  elseif(ARCHITECTURE STREQUAL "x86_64")
    SET(MONERO_WALLET_CRYPTO_LIBRARY amd64-64-24k)
    SET(CMAKE_ANDROID_ARCH_ABI x86_64)
    SET(CMAKE_SYSTEM_PROCESSOR "x86_64")
  else()
    message(SEND_ERROR Unsupported android architecture)
  endif()
  # SET(CMAKE_ANDROID_STANDALONE_TOOLCHAIN @nativeprefix@)
  SET(_ANDROID_STANDALONE_TOOLCHAIN_API 21)
  SET(__ANDROID_API__ 21)
  SET(CMAKE_SYSTEM_VERSION 1)
  SET(CMAKE_C_COMPILER @CC@)
  SET(CMAKE_CXX_COMPILER @CXX@)
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
  set(USE_DEVICE_TREZOR OFF)
  add_definitions(-DUSE_DEVICE_LEDGER=ON)
  SET(CMAKE_C_COMPILER @CC@)
  SET(CMAKE_CXX_COMPILER @CXX@)
else()
  SET(CMAKE_C_COMPILER @CC@)
  SET(CMAKE_CXX_COMPILER @CXX@)
endif()

if(ARCHITECTURE STREQUAL "arm")
  set(ARCH "armv7-a")
  set(ARM ON)
  set(ARM_ID "armv7-a")
  set(BUILD_64 OFF)
  set(CMAKE_BUILD_TYPE release)
  if(ANDROID)
    set(BUILD_TAG "android-armv7")
  else()
    set(BUILD_TAG "linux-armv7")
  endif()
  set(ARM7)
elseif(ARCHITECTURE STREQUAL "aarch64")
  set(ARCH "armv8-a")
  set(ARM ON)
  set(ARM_ID "armv8-a")
  if(ANDROID)
    set(BUILD_TAG "android-armv8")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(BUILD_TAG "linux-armv8")
  endif()
  set(BUILD_64 ON)
endif()

if(ARCHITECTURE STREQUAL "riscv64")
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(BUILD_TAG "linux-riscv64")
  endif()
  set(ARCH_ID "riscv64")
  set(ARCH "rv64gc")
endif()

if(ARCHITECTURE STREQUAL "i686")
  SET(ARCH_ID "i386")
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(BUILD_TAG "linux-x86")
    SET(LINUX_32 ON)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(BUILD_TAG "win-x32")
  endif()
endif()

if(ARCHITECTURE STREQUAL "x86_64")
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(BUILD_TAG "linux-x64")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    set(BUILD_TAG "freebsd-x64")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(BUILD_TAG "win-x64")
  endif()
  SET(ARCH_ID "x86_64")
endif()

link_directories(@prefix@/lib)
include_directories(@prefix@/include)
if(EXISTS "@prefix@/include/c++/15.2.0")
    include_directories("@prefix@/include/c++/15.2.0")
endif()
include_directories(@prefix@/include/wownero_seed)

add_definitions(-DPOLYSEED_STATIC=ON)
add_definitions(-DMOBILE_WALLET_BUILD)

if (ANDROID OR IOS)
  add_definitions(-DFORCE_USE_HEAP=1)
endif()

#Create a new global cmake flag that indicates building with depends
set (DEPENDS true)

# github.com/mrcyjanek/cmake-toolchain

if(DEFINED ENV{HOST})
  string(TOLOWER "$ENV{HOST}" _host)
  message(STATUS "toolchain: HOST = ${_host}")

  if(_host MATCHES "darwin")
    set(CMAKE_SYSTEM_NAME Darwin)
    if(_host MATCHES "aarch64")
        set(CMAKE_SYSTEM_PROCESSOR arm64)
    endif()
    if(_host MATCHES "x86_64")
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    endif()

  elseif(_host MATCHES "ios")
    set(CMAKE_SYSTEM_NAME iOS)
    if(_host MATCHES "aarch64")
        set(CMAKE_SYSTEM_PROCESSOR arm64)
    endif()
    if(_host MATCHES "x86_64")
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    endif()
    if(_host MATCHES "simulator")
      set(_ios_simulator TRUE)
    endif()

  elseif(_host MATCHES "linux")
    set(CMAKE_SYSTEM_NAME Linux)
    if(_host MATCHES "aarch64")
        set(CMAKE_SYSTEM_PROCESSOR aarch64)
    endif()
    if(_host MATCHES "armv7")
        set(CMAKE_SYSTEM_PROCESSOR armv7)
    endif()
    if(_host MATCHES "x86_64")
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    endif()

  elseif(_host MATCHES "android")
    set(CMAKE_SYSTEM_NAME Android)

    if(_host MATCHES "aarch64")
        set(CMAKE_SYSTEM_PROCESSOR aarch64)
    endif()
    if(_host MATCHES "armv7")
        set(CMAKE_SYSTEM_PROCESSOR armv7)
    endif()
    if(_host MATCHES "x86_64")
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    endif()

    set(CMAKE_ANDROID_STL_TYPE c++_static)
    set(BUILD_SHARED_LIBS OFF)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

  elseif(_host MATCHES "mingw" OR _host MATCHES "w64")
    set(CMAKE_SYSTEM_NAME Windows)
    if(_host MATCHES "x86_64")
        set(CMAKE_SYSTEM_PROCESSOR x86_64)
    endif()
    if(_host MATCHES "i686")
        set(CMAKE_SYSTEM_PROCESSOR i686)
    endif()
  endif()
endif()

function(_set_compiler_from_env LANG ENVNAME CMAKE_COMPILER_VAR CMAKE_FLAGS_VAR)
  if(NOT DEFINED ENV{\${ENVNAME}})
    return()
  endif()

  separate_arguments(_tokens UNIX_COMMAND "\$ENV{\${ENVNAME}}")
  list(LENGTH _tokens _tlen)
  if(_tlen EQUAL 0)
    return()
  endif()

  list(GET _tokens 0 _exe)
  list(REMOVE_AT _tokens 0)   # remaining tokens are flags

  if(NOT IS_ABSOLUTE "\${_exe}")
    find_program(_found_exe "\${_exe}")
    if(_found_exe)
      set(_exe "\${_found_exe}")
    endif()
  endif()

  set(\${CMAKE_COMPILER_VAR} "\${_exe}" CACHE PATH "" FORCE)

  if(_tokens)
    string(REPLACE ";" " " _token_flags "\${_tokens}")
  else()
    set(_token_flags "")
  endif()

  if("\${ENVNAME}" STREQUAL "CC")
    set(_env_flags "\$ENV{CFLAGS}")
  elseif("\${ENVNAME}" STREQUAL "CXX")
    set(_env_flags "\$ENV{CXXFLAGS}")
  else()
    set(_env_flags "")
  endif()

  if(_token_flags AND _env_flags)
    set(_final_flags "\${_token_flags} \${_env_flags}")
  elseif(_token_flags)
    set(_final_flags "\${_token_flags}")
  elseif(_env_flags)
    set(_final_flags "\${_env_flags}")
  else()
    set(_final_flags "")
  endif()

  if(_final_flags)
    set(\${CMAKE_FLAGS_VAR} "\${_final_flags}" CACHE STRING "" FORCE)
  endif()

  message(STATUS "toolchain: \${CMAKE_COMPILER_VAR} = \${_exe}")
  if(_final_flags)
    message(STATUS "toolchain: \${CMAKE_FLAGS_VAR} = \${_final_flags}")
  endif()
endfunction()

_set_compiler_from_env("C" "CC" "CMAKE_C_COMPILER" "CMAKE_C_FLAGS_INIT")
_set_compiler_from_env("CXX" "CXX" "CMAKE_CXX_COMPILER" "CMAKE_CXX_FLAGS_INIT")

if(NOT DEFINED CMAKE_C_FLAGS_INIT AND DEFINED ENV{CFLAGS})
  set(CMAKE_C_FLAGS_INIT "\$ENV{CFLAGS}" CACHE STRING "" FORCE)
  message(STATUS "toolchain: fallback CMAKE_C_FLAGS_INIT = \$ENV{CFLAGS}")
endif()
if(NOT DEFINED CMAKE_CXX_FLAGS_INIT AND DEFINED ENV{CXXFLAGS})
  set(CMAKE_CXX_FLAGS_INIT "\$ENV{CXXFLAGS}" CACHE STRING "" FORCE)
  message(STATUS "toolchain: fallback CMAKE_CXX_FLAGS_INIT = \$ENV{CXXFLAGS}")
endif()

if(DEFINED ENV{LDFLAGS})
  set(CMAKE_EXE_LINKER_FLAGS_INIT "\$ENV{LDFLAGS}" CACHE STRING "" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_INIT "\$ENV{LDFLAGS}" CACHE STRING "" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_INIT "\$ENV{LDFLAGS}" CACHE STRING "" FORCE)
  message(STATUS "toolchain: LDFLAGS = \$ENV{LDFLAGS}")
endif()

foreach(var AR RANLIB STRIP NM INSTALL_NAME_TOOL LIBTOOL OTOOL)
  if(DEFINED ENV{\${var}})
    # some CMake variables are named CMAKE_AR, CMAKE_RANLIB etc.
    set(CMAKE_\${var} "\$ENV{\${var}}" CACHE PATH "" FORCE)
    message(STATUS "toolchain: tool \${var} = \$ENV{\${var}}")
  endif()
endforeach()

if(DEFINED ENV{SDK_PATH})
  set(CMAKE_SYSROOT "\$ENV{SDK_PATH}" CACHE PATH "" FORCE)
  # also set OSX-specific variable (useful for Apple targets)
  set(CMAKE_OSX_SYSROOT "\$ENV{SDK_PATH}" CACHE PATH "" FORCE)
  message(STATUS "toolchain: SDK_PATH -> CMAKE_SYSROOT = \$ENV{SDK_PATH}")
elseif(DEFINED ENV{SYSROOT})
  set(CMAKE_SYSROOT "\$ENV{SYSROOT}" CACHE PATH "" FORCE)
  set(CMAKE_OSX_SYSROOT "\$ENV{SYSROOT}" CACHE PATH "" FORCE)
  message(STATUS "toolchain: SYSROOT -> CMAKE_SYSROOT = \$ENV{SYSROOT}")
else()
  # if this is an iOS simulator/native iOS mapping and no SDK_PATH was set,
  # set the logical name so CMake + Apple toolchain can pick it up if available
  if(_ios_simulator)
    set(CMAKE_OSX_SYSROOT iphonesimulator CACHE STRING "" FORCE)
  elseif(DEFINED _ios_simulator AND NOT _ios_simulator)
    set(CMAKE_OSX_SYSROOT iphoneos CACHE STRING "" FORCE)
  endif()
endif()

if(DEFINED ENV{OSX_MIN_VERSION})
  set(CMAKE_OSX_DEPLOYMENT_TARGET "\$ENV{OSX_MIN_VERSION}" CACHE STRING "" FORCE)
  message(STATUS "toolchain: CMAKE_OSX_DEPLOYMENT_TARGET = \$ENV{OSX_MIN_VERSION}")
endif()

if(DEFINED ENV{PREFIX})
  set(CMAKE_FIND_ROOT_PATH "\$ENV{PREFIX}" CACHE PATH "" FORCE)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  message(STATUS "toolchain: CMAKE_FIND_ROOT_PATH = \$ENV{PREFIX}")
endif()

if(DEFINED ENV{PKG_CONFIG_PATH})
  set(ENV{PKG_CONFIG_PATH} "\$ENV{PKG_CONFIG_PATH}")
  message(STATUS "toolchain: PKG_CONFIG_PATH = \$ENV{PKG_CONFIG_PATH}")
endif()

if(DEFINED CMAKE_C_COMPILER)
else()
  message(WARNING "toolchain: C compiler not set (ENV{CC} missing).")
endif()

if(DEFINED CMAKE_CXX_COMPILER)
else()
  message(WARNING "toolchain: C++ compiler not set (ENV{CXX} missing).")
endif()
EOF
