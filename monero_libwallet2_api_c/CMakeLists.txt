cmake_minimum_required(VERSION 3.5)
project(wallet2_api_c)
message(STATUS ABI_INFO = ${HOST_ABI})

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
# set(CMAKE_INTERPROCEDURAL_OPTIMIZATION FALSE)
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-lto")

if(${HOST_ABI} STREQUAL "x86_64-w64-mingw32")
    set(CMAKE_SYSTEM_NAME Windows)
    set(CMAKE_LINKER "x86_64-w64-mingw32-ld")
    set(TARGET "x86_64-w64-mingw32")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -lssp")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -lssp")
elseif(${HOST_ABI} STREQUAL "i686-w64-mingw32")
    set(CMAKE_SYSTEM_NAME Windows)
    set(CMAKE_LINKER "i686-w64-mingw32-ld")
    set(TARGET "i686-w64-mingw32")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -lssp")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -lssp")
elseif(${HOST_ABI} STREQUAL "host-apple-ios" OR
    ${HOST_ABI} STREQUAL "aarch64-apple-ios")
    set(CMAKE_SYSTEM_NAME iOS)
elseif(${HOST_ABI} STREQUAL "host-apple-darwin" OR 
    ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR
    ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin")
    set(CMAKE_SYSTEM_NAME Darwin)
endif()

if (${HOST_ABI} STREQUAL "host-apple-darwin" OR 
    ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR
    ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin")
    EXECUTE_PROCESS( COMMAND uname -m COMMAND tr -d '\n' OUTPUT_VARIABLE ARCHITECTURE )
    if (NOT ${ARCHITECTURE} STREQUAL arm64)
        set(CMAKE_OSX_ARCHITECTURES x86_64)
    endif()
endif()

if(${HOST_ABI} STREQUAL "" OR
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

if (${HOST_ABI} STREQUAL "x86_64-apple-darwin11" OR ${HOST_ABI} STREQUAL "aarch64-apple-darwin11")
  set(EXTRA_LIBS_APPLE "-framework IOKit" "-framework CoreFoundation" "-framework Cocoa" hidapi)
#   set_target_properties(wallet2_api_c PROPERTIES LINK_FLAGS "-Wl,-F/Library/Frameworks")
elseif(${HOST_ABI} STREQUAL "host-apple-darwin" OR
       ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR
       ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin")
  set(EXTRA_LIBS_APPLE "-framework IOKit" "-framework CoreFoundation" "-framework Cocoa" apple_nghttp2)
elseif(${HOST_ABI} STREQUAL "host-apple-ios" OR ${HOST_ABI} STREQUAL "aarch64-apple-ios" OR ${HOST_ABI} STREQUAL "arm64-apple-ios")
  set(EXTRA_LIBS_APPLE "-framework IOKit" "-framework CoreFoundation" iconv )
endif()

if(${HOST_ABI} STREQUAL "x86_64-w64-mingw32" OR ${HOST_ABI} STREQUAL "i686-w64-mingw32")
    target_link_options(wallet2_api_c PRIVATE -static-libgcc -static-libstdc++)
endif()

if(${HOST_ABI} STREQUAL "x86_64-apple-darwin11" OR ${HOST_ABI} STREQUAL "aarch64-apple-darwin11" OR ${HOST_ABI} STREQUAL "host-apple-darwin" OR ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "host-apple-ios" OR ${HOST_ABI} STREQUAL "aarch64-apple-ios")
    set_target_properties(wallet2_api_c PROPERTIES SUFFIX ".dylib")
    
    set_target_properties(wallet2_api_c PROPERTIES NO_SONAME 1)
endif()

if (${MONERO_FLAVOR} STREQUAL "monero")
    target_compile_definitions(wallet2_api_c PRIVATE FLAVOR_MONERO)
    set(BCUR_ENABLED bc-ur)
elseif(${MONERO_FLAVOR} STREQUAL "wownero")
    target_compile_definitions(wallet2_api_c PRIVATE FLAVOR_WOWNERO)
elseif(${MONERO_FLAVOR} STREQUAL "zano")
    target_compile_definitions(wallet2_api_c PRIVATE FLAVOR_ZANO)
endif()

if(NOT ${HOST_ABI} STREQUAL "x86_64-apple-darwin11" AND NOT ${HOST_ABI} STREQUAL "aarch64-apple-darwin11" AND NOT ${HOST_ABI} STREQUAL "aarch64-apple-darwin" AND NOT ${HOST_ABI} STREQUAL "x86_64-apple-darwin" AND NOT ${HOST_ABI} STREQUAL "host-apple-darwin" AND NOT ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" AND NOT ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin" AND NOT ${HOST_ABI} STREQUAL "host-apple-ios" AND NOT ${HOST_ABI} STREQUAL "aarch64-apple-ios")
    set_target_properties(wallet2_api_c PROPERTIES LINK_FLAGS "-Wl,--exclude-libs,ALL")
endif()

if (${MONERO_FLAVOR} STREQUAL "zano")
    include_directories(
        ${CMAKE_SOURCE_DIR}/build/${HOST_ABI}/zano_build/contrib/zlib
    )
endif()

add_subdirectory("${CMAKE_SOURCE_DIR}/../${MONERO_FLAVOR}" ${CMAKE_BINARY_DIR}/${MONERO_FLAVOR}_build EXCLUDE_FROM_ALL)

if(${HOST_ABI} STREQUAL "x86_64-apple-darwin11" OR ${HOST_ABI} STREQUAL "aarch64-apple-darwin11" OR ${HOST_ABI} STREQUAL "x86_64-apple-darwin" OR ${HOST_ABI} STREQUAL "aarch64-apple-darwin" OR ${HOST_ABI} STREQUAL "host-apple-darwin" OR ${HOST_ABI} STREQUAL "x86_64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "aarch64-host-apple-darwin" OR ${HOST_ABI} STREQUAL "host-apple-ios" OR ${HOST_ABI} STREQUAL "aarch64-apple-ios")
    if (${MONERO_FLAVOR} STREQUAL "monero")
        set(EXPORTED_SYMBOLS_FILE ${CMAKE_CURRENT_SOURCE_DIR}/monero_libwallet2_api_c.exp)
    elseif(${MONERO_FLAVOR} STREQUAL "wownero")
        set(EXPORTED_SYMBOLS_FILE ${CMAKE_CURRENT_SOURCE_DIR}/wownero_libwallet2_api_c.exp)
    elseif(${MONERO_FLAVOR} STREQUAL "zano")
        set(EXPORTED_SYMBOLS_FILE ${CMAKE_CURRENT_SOURCE_DIR}/zano_libwallet2_api_c.exp)
    endif()

    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -exported_symbols_list ${EXPORTED_SYMBOLS_FILE}")
    set_target_properties(${TARGET} PROPERTIES LINK_DEPENDS ${EXPORTED_SYMBOLS_FILE})
endif()

if (${MONERO_FLAVOR} STREQUAL "monero")
    set(WALLET_TARGETS wallet_api ${wallet_api_LIB_DEPENDS}) # wallet_api_LIB_DEPENDS
elseif(${MONERO_FLAVOR} STREQUAL "wownero")
    set(WALLET_TARGETS wallet_api ${wallet_api_LIB_DEPENDS}) # wallet_api_LIB_DEPENDS
elseif(${MONERO_FLAVOR} STREQUAL "zano")
    find_package(Boost 1.71 REQUIRED COMPONENTS system filesystem thread timer date_time chrono regex serialization atomic program_options)
    find_package(OpenSSL REQUIRED)
    set(WALLET_TARGETS 
        wallet
        general
        tor-connect
        crypto
        currency_core
        common    
        zlibstatic

        ${Boost_LIBRARIES}
        ${OpenSSL_LIBRARIES})
endif()

if(${MONERO_FLAVOR} STREQUAL "wownero")
    add_subdirectory(wownero-seed EXCLUDE_FROM_ALL)
    set(EXTRA_LIBS_WOWNEROSEED wownero-seed)
endif()

#get_cmake_property(_variableNames VARIABLES)
#list (SORT _variableNames)
#foreach (_variableName ${_variableNames})
#    message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()
#message(SEND_ERROR "${Boost_LIBRARIES}")
#message(SEND_ERROR "${WALLET_TARGETS}
#                        ${EXTRA_LIBS_WOWNEROSEED}
#                        ${EXTRA_LIBS_ANDROID}")

target_link_libraries(  wallet2_api_c

                        ${WALLET_TARGETS}
                        ${EXTRA_LIBS_WOWNEROSEED}
                        ${EXTRA_LIBS_ANDROID}
                       )
