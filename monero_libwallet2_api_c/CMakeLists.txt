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

if(${HOST_ABI} STREQUAL "x86_64-linux-android" OR
   ${HOST_ABI} STREQUAL "i686-linux-android" OR
   ${HOST_ABI} STREQUAL "aarch64-linux-android" OR
   ${HOST_ABI} STREQUAL "armv7a-linux-androideabi")
    add_link_options(-stdlib=libc++ -static-libstdc++)
    set(EXTRA_LIBS_ANDROID log)
endif()

add_library( wallet2_api_c
             SHARED
             src/main/cpp/helpers.cpp
             src/main/cpp/wallet2_api_c.cpp )

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

set(MONERO_DIR ${CMAKE_SOURCE_DIR}/../${MONERO_FLAVOR})
set(EXTERNAL_LIBS_DIR ${CMAKE_SOURCE_DIR}/../contrib/depends/${HOST_ABI})

find_package(PkgConfig REQUIRED)

if(MINGW)
  set(WARNINGS "${WARNINGS} -Wno-error=unused-value -Wno-error=unused-but-set-variable")
  set(MINGW_FLAG "${MINGW_FLAG} -DWIN32_LEAN_AND_MEAN")
  set(Boost_THREADAPI win32)
endif()

find_package(Boost REQUIRED COMPONENTS chrono filesystem program_options system thread date_time regex serialization locale)


#############
# Wownero Seed
#############

if (${MONERO_FLAVOR} STREQUAL "wownero")
    set(EXTRA_LIBS_WOWNEROSEED wownero-seed)
    if(${HOST_ABI} STREQUAL "aarch64-meego-linux-gnu")
        add_library(wownero-seed STATIC IMPORTED)
        set_target_properties(wownero-seed PROPERTIES IMPORTED_LOCATION
            ${EXTERNAL_LIBS_DIR}/lib64/libwownero-seed.a)
    else()
        add_library(wownero-seed STATIC IMPORTED)
        set_target_properties(wownero-seed PROPERTIES IMPORTED_LOCATION
            ${EXTERNAL_LIBS_DIR}/lib/libwownero-seed.a)
    endif()
endif()

# add_subdirectory("${CMAKE_SOURCE_DIR}/../external/utf8proc" ${CMAKE_BINARY_DIR}/utf8proc_build)


add_subdirectory("${CMAKE_SOURCE_DIR}/../${MONERO_FLAVOR}" ${CMAKE_BINARY_DIR}/${MONERO_FLAVOR}_build)


#############
# System
#############

#find_library( log-lib log )

include_directories( ${EXTERNAL_LIBS_DIR}/include )

message(STATUS EXTERNAL_LIBS_DIR :  ${EXTERNAL_LIBS_DIR})

if(${HOST_ABI} STREQUAL "x86_64-linux-gnu" OR
   ${HOST_ABI} STREQUAL "x86_64-apple-darwin11" OR
   ${HOST_ABI} STREQUAL "x86_64-linux-android")
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

find_package(OpenSSL REQUIRED)
message(STATUS "Using OpenSSL include dir at ${OPENSSL_INCLUDE_DIR}")
include_directories(${OPENSSL_INCLUDE_DIR})

pkg_check_modules(SODIUM REQUIRED libsodium)
message(STATUS "Using libsodium include dir at ${SODIUM_LIBRARIES}")
get_cmake_property(_variableNames VARIABLES)
#list (SORT _variableNames)
#foreach (_variableName ${_variableNames})
#    message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()
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
                        # unbound
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

                        ${Boost_LIBRARIES}

                        polyseed
                        polyseed_static
                        ${EXTRA_LIBS_POLYSEED}
                        ${EXTRA_LIBS_WOWNEROSEED}

                        bc-ur
                        utf8proc

                        ${SODIUM_LINK_LIBRARIES}
                        ${OPENSSL_LIBRARIES}
                        
                        ${EXTRA_LIBS_WINDOWS}
                        ${EXTRA_LIBS_APPLE}
                        ${EXTRA_LIBS_ANDROID}
                       )