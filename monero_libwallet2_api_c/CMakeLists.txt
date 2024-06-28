cmake_minimum_required(VERSION 3.4.1)
project(wallet2_api_c)
message(STATUS ABI_INFO  = ${HOST_ABI})

set (CMAKE_CXX_STANDARD 11)

if(${HOST_ABI} STREQUAL "x86_64-w64-mingw32")
    set(CMAKE_SYSTEM_NAME Windows)
    set(CMAKE_LINKER "x86_64-w64-mingw32-ld")
    set(TARGET "x86_64-w64-mingw32")
    # set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
elseif(${HOST_ABI} STREQUAL "i686-w64-mingw32")
    set(CMAKE_SYSTEM_NAME Windows)
    set(CMAKE_LINKER "i686-w64-mingw32-ld")
    set(TARGET "i686-w64-mingw32")
    # set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
elseif(${HOST_ABI} STREQUAL "host-apple-ios")
    set(CMAKE_SYSTEM_NAME iOS)
endif()

if (${HOST_ABI} STREQUAL "host-apple-darwin" OR 
    ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR
    ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin")
    EXECUTE_PROCESS( COMMAND uname -m COMMAND tr -d '\n' OUTPUT_VARIABLE ARCHITECTURE )
    if (NOT ${ARCHITECTURE} STREQUAL arm64)
        set(CMAKE_OSX_ARCHITECTURES x86_64)
    endif()
endif()


add_library( wallet2_api_c
             SHARED
             src/main/cpp/helpers.cpp
             src/main/cpp/wallet2_api_c.cpp )

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

set(MONERO_DIR ${CMAKE_SOURCE_DIR}/../${MONERO_FLAVOR})
set(EXTERNAL_LIBS_DIR ${MONERO_DIR}/contrib/depends/${HOST_ABI})

############
# libsodium
############

add_library(sodium STATIC IMPORTED)
set_target_properties(sodium PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/lib/libsodium.a)

############
# OpenSSL
############

add_library(crypto STATIC IMPORTED)
set_target_properties(crypto PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/lib/libcrypto.a)

add_library(ssl STATIC IMPORTED)
set_target_properties(ssl PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libssl.a)

############
# Boost
############

if(${HOST_ABI} STREQUAL "x86_64-linux-android" OR ${HOST_ABI} STREQUAL "aarch64-linux-android" OR ${HOST_ABI} STREQUAL "armv7a-linux-androideabi" OR ${HOST_ABI} STREQUAL "i686-linux-android")
    set(CMAKE_LINKER ${HOST_ABI}-ld)
    set(BOOST_WTF "-mt-s")
    set(BOOST_WTF_PART "")
elseif(${HOST_ABI} STREQUAL "x86_64-w64-mingw32" OR ${HOST_ABI} STREQUAL "i686-w64-mingw32")
    set(BOOST_WTF "-mt-s")
    set(BOOST_WTF_PART "_win32")
elseif(${HOST_ABI} STREQUAL "host-apple-ios")
    set(BOOST_WTF "")
    set(BOOST_WTF_PART "")
else()
    set(BOOST_WTF "-mt")
    set(BOOST_WTF_PART "")
endif()


add_library(boost_chrono STATIC IMPORTED)
set_target_properties(boost_chrono PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_chrono${BOOST_WTF}.a)

# win extra
add_library(boost_locale STATIC IMPORTED)
set_target_properties(boost_locale PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_locale${BOOST_WTF}.a)
    
# win extra
add_library(iconv-win STATIC IMPORTED)
set_target_properties(iconv-win PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libiconv.a)

add_library(boost_date_time STATIC IMPORTED)
set_target_properties(boost_date_time PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_date_time${BOOST_WTF}.a)

add_library(boost_filesystem STATIC IMPORTED)
set_target_properties(boost_filesystem PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_filesystem${BOOST_WTF}.a)

add_library(boost_program_options STATIC IMPORTED)
set_target_properties(boost_program_options PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_program_options${BOOST_WTF}.a)

add_library(boost_regex STATIC IMPORTED)
set_target_properties(boost_regex PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_regex${BOOST_WTF}.a)

add_library(boost_serialization STATIC IMPORTED)
set_target_properties(boost_serialization PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_serialization${BOOST_WTF}.a)

add_library(boost_system STATIC IMPORTED)
set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_system${BOOST_WTF}.a)

add_library(boost_thread STATIC IMPORTED)
set_target_properties(boost_thread PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_thread${BOOST_WTF_PART}${BOOST_WTF}.a)

add_library(boost_wserialization STATIC IMPORTED)
set_target_properties(boost_wserialization PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libboost_wserialization${BOOST_WTF}.a)

#############
# Polyseed
#############

if(${HOST_ABI} STREQUAL "aarch64-meego-linux-gnu")
    add_library(polyseed STATIC IMPORTED)
    set_target_properties(polyseed PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/lib64/libpolyseed.a)
else()
    add_library(polyseed STATIC IMPORTED)
    set_target_properties(polyseed PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/lib/libpolyseed.a)
endif()

add_library(polyseed-wrapper STATIC IMPORTED)
set_target_properties(polyseed-wrapper PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/polyseed/libpolyseed_wrapper.a)

if(${HOST_ABI} STREQUAL "x86_64-w64-mingw32" OR ${HOST_ABI} STREQUAL "i686-w64-mingw32")
    set(EXTRA_LIBS_POLYSEED polyseed-win)
    add_library(polyseed-win STATIC IMPORTED)
    set_target_properties(polyseed-win PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/external/polyseed/libpolyseed.dll.a)
endif()

#############
# Wownero Seed
#############

if (${MONERO_FLAVOR} STREQUAL "wownero")
    set(EXTRA_LIBS_WOWNEROSEED wownero-seed)
    add_library(wownero-seed STATIC IMPORTED)
    set_target_properties(wownero-seed PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/lib/libwownero-seed.a)
endif()

#############
# Utf8proc
#############

add_library(utf8proc STATIC IMPORTED)
set_target_properties(utf8proc PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/external/utf8proc/libutf8proc.a)

#############
# bc-ur
#############

add_library(bc-ur STATIC IMPORTED)
set_target_properties(bc-ur PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/external/bc-ur/libbc-ur.a)


#############
# Monero
#############

add_library(wallet_api STATIC IMPORTED)
set_target_properties(wallet_api PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/lib/libwallet_api.a)

add_library(wallet STATIC IMPORTED)
set_target_properties(wallet PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/lib/libwallet.a)

add_library(cryptonote_core STATIC IMPORTED)
set_target_properties(cryptonote_core PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/cryptonote_core/libcryptonote_core.a)

add_library(cryptonote_basic STATIC IMPORTED)
set_target_properties(cryptonote_basic PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/cryptonote_basic/libcryptonote_basic.a)

add_library(mnemonics STATIC IMPORTED)
set_target_properties(mnemonics PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/mnemonics/libmnemonics.a)

add_library(common STATIC IMPORTED)
set_target_properties(common PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/common/libcommon.a)

add_library(cncrypto STATIC IMPORTED)
set_target_properties(cncrypto PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/crypto/libcncrypto.a)

add_library(ringct STATIC IMPORTED)
set_target_properties(ringct PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/ringct/libringct.a)

add_library(ringct_basic STATIC IMPORTED)
set_target_properties(ringct_basic PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/ringct/libringct_basic.a)

add_library(blockchain_db STATIC IMPORTED)
set_target_properties(blockchain_db PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/blockchain_db/libblockchain_db.a)

add_library(lmdb STATIC IMPORTED)
set_target_properties(lmdb PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/external/db_drivers/liblmdb/liblmdb.a)

add_library(easylogging STATIC IMPORTED)
set_target_properties(easylogging PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/external/easylogging++/libeasylogging.a)

add_library(unbound STATIC IMPORTED)
set_target_properties(unbound PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libunbound.a)

add_library(epee STATIC IMPORTED)
set_target_properties(epee PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/contrib/epee/src/libepee.a)

add_library(blocks STATIC IMPORTED)
set_target_properties(blocks PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/blocks/libblocks.a)

add_library(checkpoints STATIC IMPORTED)
set_target_properties(checkpoints PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/checkpoints/libcheckpoints.a)

add_library(device STATIC IMPORTED)
set_target_properties(device PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/src/device/libdevice.a)

add_library(device_trezor STATIC IMPORTED)
set_target_properties(device_trezor PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/src/device_trezor/libdevice_trezor.a)

add_library(multisig STATIC IMPORTED)
set_target_properties(multisig PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/multisig/libmultisig.a)

add_library(version STATIC IMPORTED)
set_target_properties(version PROPERTIES IMPORTED_LOCATION
    ${MONERO_DIR}/build/${HOST_ABI}/src/libversion.a)

add_library(net STATIC IMPORTED)
set_target_properties(net PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/src/net/libnet.a)

add_library(hardforks STATIC IMPORTED)
set_target_properties(hardforks PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/src/hardforks/libhardforks.a)

if (${MONERO_FLAVOR} STREQUAL "monero")
    set(RANDOMX_FLAVOR "randomx")
elseif(${MONERO_FLAVOR} STREQUAL "wownero")
    set(RANDOMX_FLAVOR "randomwow")
endif()

add_library(randomx STATIC IMPORTED)
set_target_properties(randomx PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/external/${RANDOMX_FLAVOR}/librandomx.a)

add_library(rpc_base STATIC IMPORTED)
set_target_properties(rpc_base PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/src/rpc/librpc_base.a)

# TODO(mrcyjanek): fix (x86_64 maybe?)
add_library(wallet-crypto STATIC IMPORTED)
set_target_properties(wallet-crypto PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/src/crypto/wallet/libwallet-crypto.a)

add_library(cryptonote_format_utils_basic STATIC IMPORTED)
set_target_properties(cryptonote_format_utils_basic PROPERTIES IMPORTED_LOCATION
        ${MONERO_DIR}/build/${HOST_ABI}/src/cryptonote_basic/libcryptonote_format_utils_basic.a)

add_library(hidapi STATIC IMPORTED)
set_target_properties(hidapi PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/libhidapi.a)

#############
# System
#############

#find_library( log-lib log )

include_directories( ${EXTERNAL_LIBS_DIR}/include )

message(STATUS EXTERNAL_LIBS_DIR :  ${EXTERNAL_LIBS_DIR})

if(${HOST_ABI} STREQUAL "x86_64-linux-gnu" OR
   ${HOST_ABI} STREQUAL "x86_64-apple-darwin11")
    set(EXTRA_LIBS "wallet-crypto")
else()
    set(EXTRA_LIBS "")
endif()

if (${HOST_ABI} STREQUAL "host-apple-darwin" OR
    ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR
    ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin")
    EXECUTE_PROCESS( COMMAND uname -m COMMAND tr -d '\n' OUTPUT_VARIABLE ARCHITECTURE )
    if (NOT ${ARCHITECTURE} STREQUAL arm64)
        set(EXTRA_LIBS "wallet-crypto")
    endif()
endif()

if (${HOST_ABI} STREQUAL "x86_64-apple-darwin11" OR ${HOST_ABI} STREQUAL "aarch64-apple-darwin11")
  set(EXTRA_LIBS_APPLE "-framework IOKit" "-framework CoreFoundation" "-framework Cocoa" hidapi)
#   set_target_properties(wallet2_api_c PROPERTIES LINK_FLAGS "-Wl,-F/Library/Frameworks")
elseif(${HOST_ABI} STREQUAL "host-apple-darwin" OR
       ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR
       ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin")
    set(EXTRA_LIBS_APPLE "-framework IOKit" "-framework CoreFoundation" "-framework Cocoa" apple_nghttp2)
elseif(${HOST_ABI} STREQUAL "host-apple-ios")
  set(EXTRA_LIBS_APPLE "-framework IOKit" "-framework CoreFoundation" iconv )
endif()

if(${HOST_ABI} STREQUAL "x86_64-w64-mingw32" OR ${HOST_ABI} STREQUAL "i686-w64-mingw32")
    set_target_properties(wallet2_api_c PROPERTIES SUFFIX ".dll")
    set(EXTRA_LIBS_WINDOWS ssp wsock32 ws2_32 iconv-win iphlpapi crypt32 hidapi)
    target_link_options(wallet2_api_c PRIVATE -static-libgcc -static-libstdc++)
endif()

if(${HOST_ABI} STREQUAL "x86_64-apple-darwin11" OR ${HOST_ABI} STREQUAL "aarch64-apple-darwin11" OR ${HOST_ABI} STREQUAL "host-apple-darwin" OR ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "host-apple-ios")
    set_target_properties(wallet2_api_c PROPERTIES SUFFIX ".dylib")
    
    set_target_properties(wallet2_api_c PROPERTIES NO_SONAME 1)
endif()

if (${MONERO_FLAVOR} STREQUAL "monero")
    target_compile_definitions(wallet2_api_c PRIVATE FLAVOR_MONERO)
    set(BCUR_ENABLED bc-ur)
elseif(${MONERO_FLAVOR} STREQUAL "wownero")
    target_compile_definitions(wallet2_api_c PRIVATE FLAVOR_WOWNERO)
endif()

if(NOT ${HOST_ABI} STREQUAL "x86_64-apple-darwin11" AND NOT ${HOST_ABI} STREQUAL "aarch64-apple-darwin11" AND NOT ${HOST_ABI} STREQUAL "host-apple-darwin" AND NOT ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" AND NOT ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin" AND NOT  ${HOST_ABI} STREQUAL "host-apple-ios")
    set_target_properties(wallet2_api_c PROPERTIES LINK_FLAGS "-Wl,--exclude-libs,ALL")
endif()

if(${HOST_ABI} STREQUAL "x86_64-apple-darwin11" OR ${HOST_ABI} STREQUAL "aarch64-apple-darwin11" OR ${HOST_ABI} STREQUAL "host-apple-darwin" OR ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "host-apple-ios")
    if (${MONERO_FLAVOR} STREQUAL "monero")
        set(EXPORTED_SYMBOLS_FILE ${CMAKE_CURRENT_SOURCE_DIR}/monero_libwallet2_api_c.exp)
    elseif(${MONERO_FLAVOR} STREQUAL "wownero")
        set(EXPORTED_SYMBOLS_FILE ${CMAKE_CURRENT_SOURCE_DIR}/wownero_libwallet2_api_c.exp)
    endif()

    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -exported_symbols_list ${EXPORTED_SYMBOLS_FILE}")
    set_target_properties(${TARGET} PROPERTIES LINK_DEPENDS ${EXPORTED_SYMBOLS_FILE})
endif()

target_link_libraries(  wallet2_api_c

                        wallet_api
                        wallet
                        cryptonote_core
                        cryptonote_basic
                        cryptonote_format_utils_basic
                        mnemonics
                        ringct
                        ringct_basic
                        net
                        common
                        cncrypto
                        blockchain_db
                        lmdb
                        easylogging
                        unbound
                        epee
                        blocks
                        checkpoints
                        device
                        device_trezor
                        multisig
                        version
                        randomx
                        hardforks
                        rpc_base
                        ${EXTRA_LIBS}

                        boost_chrono
                        boost_locale
                        boost_date_time
                        boost_filesystem
                        boost_program_options
                        boost_regex
                        boost_serialization
                        boost_system
                        boost_thread
                        boost_wserialization

                        polyseed
                        polyseed-wrapper
                        ${EXTRA_LIBS_POLYSEED}
                        ${EXTRA_LIBS_WOWNEROSEED}
                        utf8proc

                        ${BCUR_ENABLED}

                        ssl
                        crypto

                        sodium

                        ${EXTRA_LIBS_WINDOWS}
                        ${EXTRA_LIBS_APPLE}
                        ${EXTRA_LIBS_ANDROID}
                       )
