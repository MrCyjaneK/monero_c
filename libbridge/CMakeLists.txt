cmake_minimum_required(VERSION 3.4.1)
project(wallet2_api_c)
message(STATUS ABI_INFO  = ${ANDROID_ABI})

set (CMAKE_CXX_STANDARD 11)

add_library( wallet2_api_c
             SHARED
             src/main/cpp/helpers.cpp
             src/main/cpp/wallet2_api_c.cpp )

set(EXTERNAL_LIBS_DIR ${CMAKE_SOURCE_DIR}/..)

############
# libsodium
############

add_library(sodium STATIC IMPORTED)
set_target_properties(sodium PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/prefix/lib/libsodium.a)

############
# OpenSSL
############

add_library(crypto STATIC IMPORTED)
set_target_properties(crypto PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/prefix/openssl/lib/libcrypto.a)

add_library(ssl STATIC IMPORTED)
set_target_properties(ssl PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/openssl/lib/libssl.a)

############
# Boost
############

add_library(boost_chrono STATIC IMPORTED)
set_target_properties(boost_chrono PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_chrono.a)

add_library(boost_date_time STATIC IMPORTED)
set_target_properties(boost_date_time PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_date_time.a)

add_library(boost_filesystem STATIC IMPORTED)
set_target_properties(boost_filesystem PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_filesystem.a)

add_library(boost_program_options STATIC IMPORTED)
set_target_properties(boost_program_options PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_program_options.a)

add_library(boost_regex STATIC IMPORTED)
set_target_properties(boost_regex PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_regex.a)

add_library(boost_serialization STATIC IMPORTED)
set_target_properties(boost_serialization PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_serialization.a)

add_library(boost_system STATIC IMPORTED)
set_target_properties(boost_system PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_system.a)

add_library(boost_thread STATIC IMPORTED)
set_target_properties(boost_thread PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_thread.a)

add_library(boost_wserialization STATIC IMPORTED)
set_target_properties(boost_wserialization PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libboost_wserialization.a)

#############
# Polyseed
#############

add_library(polyseed STATIC IMPORTED)
set_target_properties(polyseed PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libpolyseed.a)

add_library(polyseed-wrapper STATIC IMPORTED)
set_target_properties(polyseed-wrapper PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/polyseed/libpolyseed_wrapper.a)

#############
# Utf8proc
#############

add_library(utf8proc STATIC IMPORTED)
set_target_properties(utf8proc PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/prefix/lib/libutf8proc.a)

#############
# Monero
#############

add_library(wallet_api STATIC IMPORTED)
set_target_properties(wallet_api PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/lib/libwallet_api.a)

add_library(wallet STATIC IMPORTED)
set_target_properties(wallet PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/lib/libwallet.a)

add_library(cryptonote_core STATIC IMPORTED)
set_target_properties(cryptonote_core PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/cryptonote_core/libcryptonote_core.a)

add_library(cryptonote_basic STATIC IMPORTED)
set_target_properties(cryptonote_basic PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/cryptonote_basic/libcryptonote_basic.a)

add_library(mnemonics STATIC IMPORTED)
set_target_properties(mnemonics PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/mnemonics/libmnemonics.a)

add_library(common STATIC IMPORTED)
set_target_properties(common PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/common/libcommon.a)

add_library(cncrypto STATIC IMPORTED)
set_target_properties(cncrypto PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/crypto/libcncrypto.a)

add_library(ringct STATIC IMPORTED)
set_target_properties(ringct PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/ringct/libringct.a)

add_library(ringct_basic STATIC IMPORTED)
set_target_properties(ringct_basic PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/ringct/libringct_basic.a)

add_library(blockchain_db STATIC IMPORTED)
set_target_properties(blockchain_db PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/blockchain_db/libblockchain_db.a)

add_library(lmdb STATIC IMPORTED)
set_target_properties(lmdb PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/external/db_drivers/liblmdb/liblmdb.a)

add_library(easylogging STATIC IMPORTED)
set_target_properties(easylogging PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/external/easylogging++/libeasylogging.a)

add_library(unbound STATIC IMPORTED)
set_target_properties(unbound PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/prefix/lib/libunbound.a)

add_library(epee STATIC IMPORTED)
set_target_properties(epee PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/contrib/epee/src/libepee.a)

add_library(blocks STATIC IMPORTED)
set_target_properties(blocks PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/blocks/libblocks.a)

add_library(checkpoints STATIC IMPORTED)
set_target_properties(checkpoints PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/checkpoints/libcheckpoints.a)

add_library(device STATIC IMPORTED)
set_target_properties(device PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/src/device/libdevice.a)

add_library(device_trezor STATIC IMPORTED)
set_target_properties(device_trezor PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/src/device_trezor/libdevice_trezor.a)

add_library(multisig STATIC IMPORTED)
set_target_properties(multisig PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/multisig/libmultisig.a)

add_library(version STATIC IMPORTED)
set_target_properties(version PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/monero/build/release/src/libversion.a)

add_library(net STATIC IMPORTED)
set_target_properties(net PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/src/net/libnet.a)

add_library(hardforks STATIC IMPORTED)
set_target_properties(hardforks PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/src/hardforks/libhardforks.a)

add_library(randomx STATIC IMPORTED)
set_target_properties(randomx PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/external/randomx/librandomx.a)

add_library(rpc_base STATIC IMPORTED)
set_target_properties(rpc_base PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/src/rpc/librpc_base.a)

# TODO(mrcyjanek): fix (x86_64 maybe?)
add_library(wallet-crypto STATIC IMPORTED)
set_target_properties(wallet-crypto PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/src/crypto/wallet/libwallet-crypto.a)

add_library(cryptonote_format_utils_basic STATIC IMPORTED)
set_target_properties(cryptonote_format_utils_basic PROPERTIES IMPORTED_LOCATION
        ${EXTERNAL_LIBS_DIR}/monero/build/release/src/cryptonote_basic/libcryptonote_format_utils_basic.a)

#############
# System
#############

#find_library( log-lib log )

include_directories( ${EXTERNAL_LIBS_DIR}/include )

message(STATUS EXTERNAL_LIBS_DIR :  ${EXTERNAL_LIBS_DIR})

if(${ANDROID_ABI} STREQUAL "x86_64")
    set(EXTRA_LIBS "wallet-crypto")
else()
    set(EXTRA_LIBS "")
endif()

# target_compile_options(wallet2_api_c PRIVATE -static-libstdc++)

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
                        utf8proc

                        ssl
                        crypto

                        sodium
                       )
