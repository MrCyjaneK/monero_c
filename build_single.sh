#!/bin/bash

function verbose_copy() {
    echo "==> cp $1 $2"
    cp $1 $2
}

set -e
repo=$1
if [[ "x$repo" == "x" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$(nproc)"
    exit 1
fi

if [[ "x$repo" != "xwownero" && "x$repo" != "xmonero" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$(nproc)"
    echo "Invalid target given, only monero and wownero are supported targets"
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
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$(nproc)"
    exit 1
fi

NPROC="$3"

if [[ "x$NPROC" == "x" ]];
then
    echo "Usage: $0 monero/wownero $(gcc -dumpmachine) -j$(nproc)"
    exit 1
fi
cd $(dirname $0)
WDIR=$PWD
CC=""
CXX=""
case "$HOST_ABI" in
    "x86_64-linux-gnu")
        export CC="${HOST_ABI}-gcc"
        export CXX="${HOST_ABI}-g++"
    ;;
    "i686-linux-gnu")
        export CC="${HOST_ABI}-gcc"
        export CXX="${HOST_ABI}-g++"
    ;;
    "aarch64-linux-gnu")
        export CC="${HOST_ABI}-gcc"
        export CXX="${HOST_ABI}-g++"
    ;;
    "x86_64-linux-android")
        export PATH="$WDIR/$repo/contrib/depends/${HOST_ABI}/native/bin/:$PATH"
        export CC=${HOST_ABI}-clang
        export CXX=${HOST_ABI}-clang++
    ;;
    "i686-linux-android")
        export PATH="$WDIR/$repo/contrib/depends/${HOST_ABI}/native/bin/:$PATH"
        export CC=${HOST_ABI}-clang
        export CXX=${HOST_ABI}-clang++
    ;;
    "aarch64-linux-android")
        export PATH="$WDIR/$repo/contrib/depends/${HOST_ABI}/native/bin/:$PATH"
        export CC=${HOST_ABI}-clang
        export CXX=${HOST_ABI}-clang++
    ;;
    "arm-linux-androideabi")
        export PATH="$WDIR/$repo/contrib/depends/${HOST_ABI}/native/bin/:$PATH"
        export CC=${HOST_ABI}-clang
        export CXX=${HOST_ABI}-clang++
    ;;
    "i686-w64-mingw32")
        update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix
        update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix
        export CC=i686-w64-mingw32-gcc-posix
        export CXX=i686-w64-mingw32-g++-posix
    ;;
    "x86_64-w64-mingw32")
        $SUDO update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix
        $SUDO update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
        export CC=x86_64-w64-mingw32-gcc-posix
        export CXX=x86_64-w64-mingw32-g++-posix
    ;;
    "x86_64-apple-darwin11")
        export PATH="$WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/bin:$PATH"
        export CC="clang -stdlib=libc++ -target x86_64-apple-darwin11 -mmacosx-version-min=10.8 --sysroot $WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/bin/x86_64-apple-darwin11-"
        export CXX="clang++ -stdlib=libc++ -target x86_64-apple-darwin11 -mmacosx-version-min=10.8 --sysroot $WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/bin/x86_64-apple-darwin11-"
    ;;
    "aarch64-apple-darwin11")
        export PATH="$WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/bin:$PATH"
        export CC="clang -stdlib=libc++ -target arm64-apple-darwin11 -mmacosx-version-min=10.8 --sysroot $WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/bin/aarch64-apple-darwin11-"
        export CXX="clang++ -stdlib=libc++ -target arm64-apple-darwin11 -mmacosx-version-min=10.8 --sysroot $WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/bin/aarch64-apple-darwin11-"
    ;;
    "host-apple-darwin")
        export CC="clang"
        export CXX="clang++"
    ;;
esac

if [[ "x$CC" == "x" ]];
then
    echo "No C compiler found for abi: '$HOST_ABI'. Adjust the switch case in $0"
    exit 1
fi

if [[ "x$CXX" == "x" ]];
then
    echo "No C++ compiler found for abi: '$HOST_ABI'. Adjust the switch case in $0"
    exit 1
fi
pushd $repo/contrib/depends
    case "$HOST_ABI" in
        "x86_64-linux-gnu" | "i686-linux-gnu" | "aarch64-linux-gnu" | "x86_64-linux-android" | "i686-linux-android" | "aarch64-linux-android" | "arm-linux-androideabi" | "i686-w64-mingw32" | "x86_64-w64-mingw32" | "x86_64-apple-darwin11" | "aarch64-apple-darwin11")
            CC=gcc CXX=g++ make HOST="$HOST_ABI" "$NPROC"
        ;;
        "host-apple-darwin")
            echo "===================================="
            echo "=                                  ="
            echo "=  CHECK README.md IF BUILD FAILS  ="
            echo "=                                  ="
            echo "===================================="
            echo "WARN: using host dependencies on macos."
            POLYSEED_DIR=../../../external/polyseed/build/${HOST_ABI}
            rm -rf ${POLYSEED_DIR}
            mkdir -p ${POLYSEED_DIR}
            pushd ${POLYSEED_DIR}
                CC="${CC}" CXX="${CXX}" cmake ../..
                make $NPROC
            popd
            MACOS_LIBS_DIR="${PWD}/host-apple-darwin"
            rm -rf ${MACOS_LIBS_DIR}
            mkdir -p ${MACOS_LIBS_DIR}/lib
            export HOMEBREW_PREFIX=/opt/homebrew
            verbose_copy "${HOMEBREW_PREFIX}/lib/libunbound.a" ${MACOS_LIBS_DIR}/lib/libunbound.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_chrono-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_chrono-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_locale-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_locale-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_date_time-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_date_time-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_filesystem-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_filesystem-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_program_options-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_program_options-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_regex-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_regex-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_serialization-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_serialization-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_system-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_system-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_thread-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_thread-mt.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libboost_wserialization-mt.a" ${MACOS_LIBS_DIR}/lib/libboost_wserialization-mt.a
            verbose_copy "${POLYSEED_DIR}/libpolyseed.a" ${MACOS_LIBS_DIR}/lib/libpolyseed.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libssl.a" ${MACOS_LIBS_DIR}/lib/libssl.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libcrypto.a" ${MACOS_LIBS_DIR}/lib/libcrypto.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libsodium.a" ${MACOS_LIBS_DIR}/lib/libsodium.a
            verbose_copy "${HOMEBREW_PREFIX}/lib/libevent.a" ${MACOS_LIBS_DIR}/lib/libevent.a
        ;;
        *)
            echo "Unable to build dependencies for '$HOST_ABI'."
            exit 1
        ;;
    esac
popd

buildType=Debug

rm -rf $repo/build/${HOST_ABI} 2>/dev/null || true
mkdir -p $repo/build/${HOST_ABI}
pushd $repo/build/${HOST_ABI}
    case "$HOST_ABI" in
        "x86_64-linux-gnu")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86-64" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=false -D BUILD_TAG="linux-x64" -D CMAKE_SYSTEM_NAME="Linux" ../..
        ;;
        "i686-linux-gnu")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="i686" -D STATIC=ON -D BUILD_64="OFF" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=false -D BUILD_TAG="linux-x86" -D CMAKE_SYSTEM_NAME="Linux" ../..
        ;;
        "aarch64-linux-gnu")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=false -D BUILD_TAG="linux-armv8" -D CMAKE_SYSTEM_NAME="Linux" ../..
        ;;
        "x86_64-linux-android")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86-64" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-x86_64" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="x86_64" ../..
        ;;
        "i686-linux-android")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86" -D STATIC=ON -D BUILD_64="OFF" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-x86" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="x86" ../..
        ;;
        "aarch64-linux-android")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-armv8" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="arm64-v8a" ../..
        ;;
        "arm-linux-androideabi")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64="OFF" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-armv7" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="armeabi-v7a" ../..
        ;;
        "x86_64-w64-mingw32")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="win-x64" ../..
        ;;
        "i686-w64-mingw32")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="i686" -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="win-x32" ../..
        ;;
        "x86_64-apple-darwin11")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="mac-x64" ../..
        ;;
        "aarch64-apple-darwin11")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="armv8-a" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="mac-armv8" ../..
        ;;
        "host-apple-darwin")
            env CC="${CC}" CXX="${CXX}" cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType ../..
        ;;
        *)
            echo "we don't know how to compile monero for '$HOST_ABI'"
            exit 1
        ;;
    esac
    CC=gcc CXX=g++ make wallet_api $NPROC
popd

# Special treatment for apple
if [[ "${HOST_ABI}" == "x86_64-apple-darwin11" || "${HOST_ABI}" == "aarch64-apple-darwin11" ]];
then
    ${HOST_ABI}-ranlib $PWD/$repo/contrib/depends/${HOST_ABI}/lib/libpolyseed.a
fi

pushd ${repo}_libwallet2_api_c
    rm -rf build/${HOST_ABI} || true
    mkdir -p build/${HOST_ABI} -p
    cd build/${HOST_ABI}
    
    env CC="${CC}" CXX="${CXX}" cmake -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
    CC="${CC}" CXX="${CXX}" make $NPROC
popd

mkdir -p release/$repo 2>/dev/null || true
pushd release/$repo
    APPENDIX=""
    if [[ "${HOST_ABI}" == "x86_64-w64-mingw32" || "${HOST_ABI}" == "i686-w64-mingw32" ]];
    then
        APPENDIX="${APPENDIX}dll"
        cp ../../$repo/build/${HOST_ABI}/external/polyseed/libpolyseed.${APPENDIX} ${HOST_ABI}_libpolyseed.${APPENDIX}
        rm ${HOST_ABI}_libpolyseed.${APPENDIX}.xz || true
        xz -e ${HOST_ABI}_libpolyseed.${APPENDIX}
    elif [[ "${HOST_ABI}" == "x86_64-apple-darwin11" || "${HOST_ABI}" == "aarch64-apple-darwin11" || "${HOST_ABI}" == "host-apple-darwin" ]];
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
        cp /usr/lib/gcc/${HOST_ABI}/8.3-posix/libstdc++-6.dll ${HOST_ABI}_libstdc++-6.dll
        rm ${HOST_ABI}_libstdc++-6.dll.xz || true
        xz -e ${HOST_ABI}_libstdc++-6.dll
        #### 
        cp /usr/lib/gcc/${HOST_ABI}/8.3-posix/libssp-0.dll ${HOST_ABI}_libssp-0.dll
        rm ${HOST_ABI}_libssp-0.dll.xz || true
        xz -e ${HOST_ABI}_libssp-0.dll
    fi
    if [[ "$HOST_ABI" == "x86_64-w64-mingw32" ]];
    then
        cp /usr/lib/gcc/${HOST_ABI}/8.3-posix/libgcc_s_seh-1.dll ${HOST_ABI}_libgcc_s_seh-1.dll
        rm ${HOST_ABI}_libgcc_s_seh-1.dll.xz || true
        xz -e ${HOST_ABI}_libgcc_s_seh-1.dll
    fi
    if [[ "$HOST_ABI" == "i686-w64-mingw32" ]];
    then
        cp /usr/lib/gcc/${HOST_ABI}/8.3-posix/libgcc_s_sjlj-1.dll ${HOST_ABI}_libgcc_s_sjlj-1.dll
        rm ${HOST_ABI}_libgcc_s_sjlj-1.dll.xz || true
        xz -e ${HOST_ABI}_libgcc_s_sjlj-1.dll
    fi
popd