#!/bin/bash

cd "$(realpath $(dirname $0))"

proccount=1
if [[ "x$(uname)" == "xDarwin" ]];
then
    proccount=$(sysctl -n hw.physicalcpu)
elif [[ "x$(uname)" == "xLinux" ]];
then
    proccount=$(nproc)
fi

function verbose_copy() {
    echo "==> cp $1 $2"
    cp $1 $2
}

set -e
repo=$1
if [[ "x$repo" == "x" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    exit 1
fi

if [[ "x$repo" != "xwownero" && "x$repo" != "xmonero" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    echo "Invalid target given, only monero and wownero are supported targets"
    exit 1
fi

if [[ ! -d "$repo" ]]
then
    echo "no '$repo' directory found. clone with --recursive or run:"
    echo "$ git submodule init && git submodule update --force";
    exit 1
fi

HOST_ABI="$2"
if [[ "x$HOST_ABI" == "x" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    exit 1
fi

NPROC="$3"

if [[ "x$NPROC" == "x" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$proccount"
    exit 1
fi
cd $(dirname $0)
WDIR=$PWD
pushd contrib/depends
    env -i PATH="$PATH" CC=gcc CXX=g++ make HOST="$HOST_ABI" "$NPROC"
popd

buildType=Debug

pushd ${repo}_libwallet2_api_c
    rm -rf build/${HOST_ABI} || true
    mkdir -p build/${HOST_ABI} -p
    pushd build/${HOST_ABI}
        case $HOST_ABI in
            "x86_64-linux-gnu" | "i686-linux-gnu" | "i686-meego-linux-gnu" | "aarch64-linux-gnu" | "aarch64-meego-linux-gnu" | "i686-w64-mingw32" | "x86_64-w64-mingw32" | "x86_64-apple-darwin11" | "aarch64-apple-darwin11" | "host-apple-darwin" | "x86_64-host-apple-darwin" | "aarch64-host-apple-darwin")
                echo $CC
                env CC="${CC}" CXX="${CXX}" cmake -D Boost_USE_MULTITHREADED=ON -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86-64" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=false -D BUILD_TAG="linux-x64" -D CMAKE_SYSTEM_NAME="Linux" -DCMAKE_TOOLCHAIN_FILE=$PWD/../../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
                CC=gcc CXX=g++ make $NPROC
            ;;
            "x86_64-linux-android")
                echo $CC
                env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -DMONERO_WALLET_CRYPTO_LIBRARY=amd64-64-24k -DHIDAPI_DUMMY=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SYSTEM_VERSION=1 -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86-64" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-x86_64" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="x86_64" -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
                CC=gcc CXX=g++ make $NPROC
            ;;
            "aarch64-linux-android")
                echo $CC
                env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -DHIDAPI_DUMMY=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SYSTEM_VERSION=1 -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-armv8" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="arm64-v8a" -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
                CC=gcc CXX=g++ make $NPROC
            ;;
            "armv7a-linux-androideabi")
                echo $CC
                env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -DHIDAPI_DUMMY=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SYSTEM_VERSION=1 -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64="OFF" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-armv7" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="armeabi-v7a" -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
                CC=gcc CXX=g++ make $NPROC
            ;;
            "host-apple-ios")
                export -n CC CXX
                CC=clang CXX=clang++ cmake -DCMAKE_TOOLCHAIN_FILE=../../../external/ios-cmake/ios.toolchain.cmake -DPLATFORM=OS64 -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
                CC=clang CXX=clang++ make $NPROC
            ;;
            *)
                echo "Unable to build ${repo}_libwallet2_api_c for ${HOST_ABI}"
                exit 1
            ;;
        esac
    popd
popd

mkdir -p release/$repo 2>/dev/null || true
pushd release/$repo
    APPENDIX=""
    if [[ "${HOST_ABI}" == "x86_64-w64-mingw32" || "${HOST_ABI}" == "i686-w64-mingw32" ]];
    then
        echo "TODO: check if it's still needed"
        APPENDIX="${APPENDIX}dll"
        # cp ../../$repo/build/${HOST_ABI}/external/polyseed/libpolyseed.${APPENDIX} ${HOST_ABI}_libpolyseed.${APPENDIX}
        # rm ${HOST_ABI}_libpolyseed.${APPENDIX}.xz || true
        # xz -e ${HOST_ABI}_libpolyseed.${APPENDIX}
    elif [[ "${HOST_ABI}" == "x86_64-apple-darwin11" || "${HOST_ABI}" == "aarch64-apple-darwin11" || "${HOST_ABI}" == "host-apple-darwin" || "${HOST_ABI}" == "x86_64-host-apple-darwin" || "${HOST_ABI}" == "aarch64-host-apple-darwin" || "${HOST_ABI}" == "host-apple-ios" ]];
    then
        APPENDIX="${APPENDIX}dylib"
    else
        APPENDIX="${APPENDIX}so"
    fi
    xz -e ../../${repo}_libwallet2_api_c/build/${HOST_ABI}/libwallet2_api_c.${APPENDIX}
    mv ../../${repo}_libwallet2_api_c/build/${HOST_ABI}/libwallet2_api_c.${APPENDIX}.xz ${HOST_ABI}_libwallet2_api_c.${APPENDIX}.xz
    # Extra libraries
    if [[ "$HOST_ABI" == "x86_64-w64-mingw32" || "$HOST_ABI" == "i686-w64-mingw32" ]];
    then
        cp /usr/${HOST_ABI}/lib/libwinpthread-1.dll ${HOST_ABI}_libwinpthread-1.dll
        rm ${HOST_ABI}_libwinpthread-1.dll.xz || true
        xz -e ${HOST_ABI}_libwinpthread-1.dll
        ####
        cp /usr/lib/gcc/${HOST_ABI}/*-posix/libssp-0.dll ${HOST_ABI}_libssp-0.dll
        rm ${HOST_ABI}_libssp-0.dll.xz || true
        xz -e ${HOST_ABI}_libssp-0.dll
    fi
popd
