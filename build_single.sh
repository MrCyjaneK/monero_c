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
        if [[ "$repo" == "wownero" ]];
        then
            export CC=x86_64-linux-android-clang
            export CXX=x86_64-linux-android-clang++
        else
            export CC=x86_64-linux-android21-clang
            export CXX=x86_64-linux-android21-clang++
        fi
    ;;
    "i686-linux-android")
        export PATH="$WDIR/$repo/contrib/depends/${HOST_ABI}/native/bin/:$PATH"
        if [[ "$repo" == "wownero" ]];
        then
            export CC=i686-linux-android-clang
            export CXX=i686-linux-android-clang++
        else
            export CC=i686-linux-android21-clang
            export CXX=i686-linux-android21-clang++
        fi
    ;;
    "aarch64-linux-android")
        export PATH="$WDIR/$repo/contrib/depends/${HOST_ABI}/native/bin/:$PATH"
        if [[ "$repo" == "wownero" ]];
        then
            export CC=aarch64-linux-android-clang
            export CXX=aarch64-linux-android-clang++
        else
            export CC=aarch64-linux-android21-clang
            export CXX=aarch64-linux-android21-clang++
        fi
    ;;
    "arm-linux-androideabi")
        export PATH="$WDIR/$repo/contrib/depends/${HOST_ABI}/native/bin/:$PATH"
        if [[ "$repo" == "wownero" ]];
        then
            export CC=arm-linux-androideabi-clang
            export CXX=arm-linux-androideabi-clang++
        else
            export CC=armv7a-linux-androideabi21-clang
            export CXX=armv7a-linux-androideabi21-clang++
        fi
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
        export CC="clang -stdlib=libc++ -target x86_64-apple-darwin11 -mmacosx-version-min=10.14 --sysroot $WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/bin/x86_64-apple-darwin11-"
        export CXX="clang++ -stdlib=libc++ -target x86_64-apple-darwin11 -mmacosx-version-min=10.14 --sysroot $WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/x86_64-apple-darwin11/native/bin/x86_64-apple-darwin11-"
    ;;
    "aarch64-apple-darwin11")
        export PATH="$WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/bin:$PATH"
        export CC="clang -stdlib=libc++ -target arm64-apple-darwin11 -mmacosx-version-min=10.14 --sysroot $WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/bin/aarch64-apple-darwin11-"
        export CXX="clang++ -stdlib=libc++ -target arm64-apple-darwin11 -mmacosx-version-min=10.14 --sysroot $WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/SDK/ -mlinker-version=609 -B$WDIR/$repo/contrib/depends/aarch64-apple-darwin11/native/bin/aarch64-apple-darwin11-"
    ;;
    "host-apple-darwin"|"x86_64-host-apple-darwin"|"aarch64-host-apple-darwin")
        export CC="clang"
        export CXX="clang++"
    ;;
    "host-apple-ios")
        export IOS_CC="clang -arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
        export IOS_CXX="clang++ -arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
    ;;
    *)
        echo "Unsupported target."
        exit 1
    ;;
esac
pushd $repo/contrib/depends
    case "$HOST_ABI" in
        "x86_64-linux-gnu" | "i686-linux-gnu" | "aarch64-linux-gnu" | "x86_64-linux-android" | "i686-linux-android" | "aarch64-linux-android" | "arm-linux-androideabi" | "i686-w64-mingw32" | "x86_64-w64-mingw32" | "x86_64-apple-darwin11" | "aarch64-apple-darwin11")
            CC=gcc CXX=g++ make HOST="$HOST_ABI" "$NPROC"
        ;;
        "host-apple-darwin" | "x86_64-host-apple-darwin" | "aarch64-host-apple-darwin")
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
            if [[ "$repo" == "wownero" ]];
            then
                WOWNEROSEED_DIR=../../../external/wownero-seed/build/${HOST_ABI}
                rm -rf ${WOWNEROSEED_DIR}
                mkdir -p ${WOWNEROSEED_DIR}
                pushd ${WOWNEROSEED_DIR}
                    pushd ../..
                        git reset --hard
                        patch -p1 < ../wownero-seed-0001-fix-duplicate-symbol-error.patch
                    popd
                    CC="${CC}" CXX="${CXX}" cmake ../..
                    make $NPROC
                popd
            fi
            MACOS_LIBS_DIR="${PWD}/${HOST_ABI}"
            rm -rf ${MACOS_LIBS_DIR}
            mkdir -p ${MACOS_LIBS_DIR}/lib
            if [[ "x$HOMEBREW_PREFIX" == "x" ]];
            then
                export HOMEBREW_PREFIX=/opt/homebrew
                if [[ ! -d "$HOMEBREW_PREFIX" ]];
                then
                    export HOMEBREW_PREFIX=/usr/local
                fi
            fi
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
            if [[ "$repo" == "wownero" ]];
            then
                verbose_copy "${WOWNEROSEED_DIR}/libwownero-seed.a" ${MACOS_LIBS_DIR}/lib/libwownero-seed.a
            fi
            verbose_copy "${HOMEBREW_PREFIX}/lib/libevent.a" ${MACOS_LIBS_DIR}/lib/libevent.a
        ;;
        "host-apple-ios")
            echo "===================================="
            echo "=                                  ="
            echo "=  CHECK README.md IF BUILD FAILS  ="
            echo "=                                  ="
            echo "===================================="
            pwd
            pushd ../../../external/ios
                ./install_missing_headers.sh
                ./build_openssl.sh
                ./build_boost.sh
                ./build_sodium.sh
                ./build_zmq.sh
                ./build_unbound.sh
                if [[ "$repo" == "wownero" ]];
                then
                    ./build_wownero_seed.sh
                fi
            popd
            POLYSEED_DIR=../../../external/polyseed/build/${HOST_ABI}
            rm -rf ${POLYSEED_DIR}
            mkdir -p ${POLYSEED_DIR}
            pushd ${POLYSEED_DIR}
                CC="${IOS_CC}" CXX="${IOS_CXX}" cmake  -DCMAKE_TOOLCHAIN_FILE=../../../ios-cmake/ios.toolchain.cmake -DPLATFORM=OS64 ../..
                make $NPROC
            popd
            if [[ "$repo" == "wownero" ]];
            then
                WOWNEROSEED_DIR=../../../external/wownero-seed/build/${HOST_ABI}
                rm -rf ${WOWNEROSEED_DIR}
                mkdir -p ${WOWNEROSEED_DIR}
                pushd ${WOWNEROSEED_DIR}
                    pushd ../..
                        git reset --hard
                        patch -p1 < ../wownero-seed-0001-fix-duplicate-symbol-error.patch
                    popd
                    CC="${CC}" CXX="${CXX}" cmake -DCMAKE_TOOLCHAIN_FILE=../../../ios-cmake/ios.toolchain.cmake -DPLATFORM=OS64 ../..
                    make $NPROC
                popd
            fi
            IOS_LIBS_DIR="${PWD}/host-apple-ios"
            rm -rf ${IOS_LIBS_DIR}
            mkdir -p ${IOS_LIBS_DIR}/lib
            export IOS_PREFIX="$(realpath "${PWD}/../../../external/ios/build/ios")"
            verbose_copy "${IOS_PREFIX}/lib/libunbound.a" ${IOS_LIBS_DIR}/lib/libunbound.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_chrono.a" ${IOS_LIBS_DIR}/lib/libboost_chrono.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_locale.a" ${IOS_LIBS_DIR}/lib/libboost_locale.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_date_time.a" ${IOS_LIBS_DIR}/lib/libboost_date_time.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_filesystem.a" ${IOS_LIBS_DIR}/lib/libboost_filesystem.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_program_options.a" ${IOS_LIBS_DIR}/lib/libboost_program_options.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_regex.a" ${IOS_LIBS_DIR}/lib/libboost_regex.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_serialization.a" ${IOS_LIBS_DIR}/lib/libboost_serialization.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_system.a" ${IOS_LIBS_DIR}/lib/libboost_system.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_thread.a" ${IOS_LIBS_DIR}/lib/libboost_thread.a
            verbose_copy "${IOS_PREFIX}/lib/libboost_wserialization.a" ${IOS_LIBS_DIR}/lib/libboost_wserialization.a
            verbose_copy "${POLYSEED_DIR}/libpolyseed.a" ${IOS_LIBS_DIR}/lib/libpolyseed.a
            verbose_copy "${IOS_PREFIX}/lib/libssl.a" ${IOS_LIBS_DIR}/lib/libssl.a
            verbose_copy "${IOS_PREFIX}/lib/libcrypto.a" ${IOS_LIBS_DIR}/lib/libcrypto.a
            verbose_copy "${IOS_PREFIX}/lib/libsodium.a" ${IOS_LIBS_DIR}/lib/libsodium.a
            if [[ "$repo" == "wownero" ]];
            then
                verbose_copy "${WOWNEROSEED_DIR}/libwownero-seed.a" ${IOS_LIBS_DIR}/lib/libwownero-seed.a
            fi
            # verbose_copy "${IOS_PREFIX}/lib/libevent.a" ${IOS_LIBS_DIR}/lib/libevent.a
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
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86-64" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=false -D BUILD_TAG="linux-x64" -D CMAKE_SYSTEM_NAME="Linux" ../..
        ;;
        "i686-linux-gnu")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="i686" -D STATIC=ON -D BUILD_64="OFF" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=false -D BUILD_TAG="linux-x86" -D CMAKE_SYSTEM_NAME="Linux" ../..
        ;;
        "aarch64-linux-gnu")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=false -D BUILD_TAG="linux-armv8" -D CMAKE_SYSTEM_NAME="Linux" ../..
        ;;
        "x86_64-linux-android")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SYSTEM_VERSION=1 -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86-64" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-x86_64" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="x86_64" ../..
        ;;
        "i686-linux-android")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SYSTEM_VERSION=1 -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86" -D STATIC=ON -D BUILD_64="OFF" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-x86" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="x86" ../..
        ;;
        "aarch64-linux-android")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SYSTEM_VERSION=1 -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-armv8" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="arm64-v8a" ../..
        ;;
        "arm-linux-androideabi")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SYSTEM_VERSION=1 -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64="OFF" -D CMAKE_BUILD_TYPE=$buildType -D ANDROID=true -D BUILD_TAG="android-armv7" -D CMAKE_SYSTEM_NAME="Android" -D CMAKE_ANDROID_ARCH_ABI="armeabi-v7a" ../..
        ;;
        "x86_64-w64-mingw32")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="win-x64" ../..
        ;;
        "i686-w64-mingw32")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="i686" -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="win-x32" ../..
        ;;
        "x86_64-apple-darwin11")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="mac-x64" ../..
        ;;
        "aarch64-apple-darwin11")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_TOOLCHAIN_FILE=$PWD/../../contrib/depends/${HOST_ABI}/share/toolchain.cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D ARCH="armv8-a" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType -D BUILD_TAG="mac-armv8" ../..
        ;;
        "host-apple-darwin" | "x86_64-host-apple-darwin" | "aarch64-host-apple-darwin")
            env CC="${CC}" CXX="${CXX}" cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=$buildType ../..
        ;;
        "host-apple-ios")
            PREFIX="$(realpath "${PWD}/../../../external/ios/build/ios")"
            # echo $PREFIX
            # exit 1
            env \
                CMAKE_INCLUDE_PATH="${PREFIX}/include" \
                CMAKE_LIBRARY_PATH="${PREFIX}/lib" \
                CC="${IOS_CC}" CXX="${IOS_CXX}" cmake -D IOS=ON -D ARCH=arm64 -D CMAKE_BUILD_DYPE=$buildType -D STATIC=ON -D BUILD_GUI_DEPS=1 -D UNBOUND_INCLUDE_DIR="${PREFIX}/lib" ../..
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
    if [[ "$repo" == "wownero" ]];
    then
        ${HOST_ABI}-ranlib $PWD/$repo/contrib/depends/${HOST_ABI}/lib/libwownero-seed.a
    fi
fi

pushd ${repo}_libwallet2_api_c
    rm -rf build/${HOST_ABI} || true
    mkdir -p build/${HOST_ABI} -p
    pushd build/${HOST_ABI}
        case $HOST_ABI in
            "x86_64-linux-gnu" | "i686-linux-gnu" | "aarch64-linux-gnu" | "i686-w64-mingw32" | "x86_64-w64-mingw32" | "x86_64-apple-darwin11" | "aarch64-apple-darwin11" | "host-apple-darwin" | "x86_64-host-apple-darwin" | "aarch64-host-apple-darwin" | "x86_64-linux-android" | "i686-linux-android" | "aarch64-linux-android" | "arm-linux-androideabi")
                echo $CC
                env CC="${CC}" CXX="${CXX}" cmake -DMONERO_FLAVOR=$repo -DCMAKE_BUILD_TYPE=Debug -DHOST_ABI=${HOST_ABI} ../..
                CC="${CC}" CXX="${CXX}" make $NPROC
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
        APPENDIX="${APPENDIX}dll"
        cp ../../$repo/build/${HOST_ABI}/external/polyseed/libpolyseed.${APPENDIX} ${HOST_ABI}_libpolyseed.${APPENDIX}
        rm ${HOST_ABI}_libpolyseed.${APPENDIX}.xz || true
        xz -e ${HOST_ABI}_libpolyseed.${APPENDIX}
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
    if [[ "$HOST_ABI" == "x86_64-linux-android" || "$HOST_ABI" == "i686-linux-android" || "$HOST_ABI" == "aarch64-linux-android" || "$HOST_ABI" == "arm-linux-androideabi" ]];
    then
        cp ../../monero/contrib/depends/${HOST_ABI}/native/sysroot/usr/lib/${HOST_ABI}/libc++_shared.so ${HOST_ABI}_libc++_shared.so
        rm ${HOST_ABI}_libc++_shared.so.xz || true
        xz -e ${HOST_ABI}_libc++_shared.so
    fi
popd
