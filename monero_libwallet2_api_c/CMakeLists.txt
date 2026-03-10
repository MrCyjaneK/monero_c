cmake_minimum_required(VERSION 3.5)
project(${MONERO_FLAVOR}_wallet2_api_c)
message(STATUS HOST_ABI = ${HOST_ABI})

set(MD_LIBRARY "")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

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
elseif(${HOST_ABI} MATCHES "-apple-ios")
    set(CMAKE_SYSTEM_NAME iOS)
elseif(${HOST_ABI} MATCHES "-apple-darwin")
    set(CMAKE_SYSTEM_NAME Darwin)
endif()

if(${HOST_ABI} MATCHES "-linux-android")
    add_link_options(-stdlib=libc++ -static-libstdc++)
    set(EXTRA_LIBS_ANDROID log)
endif()


add_library( ${MONERO_FLAVOR}_wallet2_api_c
             ${OUTPUT_MODE}
             src/main/cpp/helpers.cpp
             src/main/cpp/${MONERO_FLAVOR}_wallet2_api_c.cpp
             src/main/cpp/${MONERO_FLAVOR}_checksum.c)

if(${HOST_ABI} MATCHES "-linux-android")
    set_target_properties(${MONERO_FLAVOR}_wallet2_api_c PROPERTIES LINK_FLAGS "-Wl,-z,noexecstack")
endif()

if(${HOST_ABI} MATCHES "-linux-gnu")
    set_target_properties(${MONERO_FLAVOR}_wallet2_api_c PROPERTIES LINK_FLAGS "-Wl,-z,noexecstack")
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

set(MONERO_DIR ${CMAKE_SOURCE_DIR}/../${MONERO_FLAVOR})
set(EXTERNAL_LIBS_DIR ${CMAKE_SOURCE_DIR}/../contrib/depends/${HOST_ABI})

if(${HOST_ABI} STREQUAL "x86_64-w64-mingw32" OR ${HOST_ABI} STREQUAL "i686-w64-mingw32")
    target_link_options(${MONERO_FLAVOR}_wallet2_api_c PRIVATE -static-libgcc -static-libstdc++)
endif()

if (${MONERO_FLAVOR} STREQUAL "monero")
    target_compile_definitions(${MONERO_FLAVOR}_wallet2_api_c PRIVATE FLAVOR_MONERO)
    set(BCUR_ENABLED bc-ur)
elseif(${MONERO_FLAVOR} STREQUAL "wownero")
    target_compile_definitions(${MONERO_FLAVOR}_wallet2_api_c PRIVATE FLAVOR_WOWNERO)
elseif(${MONERO_FLAVOR} STREQUAL "zano")
    target_compile_definitions(${MONERO_FLAVOR}_wallet2_api_c PRIVATE FLAVOR_ZANO)
endif()

if(NOT HOST_ABI MATCHES "-apple-")
    set_target_properties(${MONERO_FLAVOR}_wallet2_api_c PROPERTIES LINK_FLAGS "-Wl,--exclude-libs,ALL")
endif()

if (${MONERO_FLAVOR} STREQUAL "zano")
    include_directories(
        ${CMAKE_SOURCE_DIR}/build/${HOST_ABI}/zano_build/contrib/zlib
    )
endif()

add_subdirectory("${CMAKE_SOURCE_DIR}/../${MONERO_FLAVOR}" ${CMAKE_BINARY_DIR}/${MONERO_FLAVOR}_build EXCLUDE_FROM_ALL)

if(HOST_ABI MATCHES "-apple-")
    set(EXPORTED_SYMBOLS_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${MONERO_FLAVOR}_libwallet2_api_c.exp)

    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -exported_symbols_list ${EXPORTED_SYMBOLS_FILE}")
    set_target_properties(${TARGET} PROPERTIES LINK_DEPENDS ${EXPORTED_SYMBOLS_FILE})
endif()

if (${MONERO_FLAVOR} STREQUAL "monero" OR ${MONERO_FLAVOR} STREQUAL "wownero")
    set(WALLET_TARGETS wallet_api ${wallet_api_LIB_DEPENDS})
elseif(${MONERO_FLAVOR} STREQUAL "zano")
    set(THREADS_PREFER_PTHREAD_FLAG ON)

    set(CMAKE_THREAD_LIBS_INIT "-lpthread")
    set(CMAKE_HAVE_THREADS_LIBRARY 1)
    set(CMAKE_USE_PTHREADS_INIT 1)
    set(Threads_FOUND TRUE)
    find_package(Boost 1.71 REQUIRED COMPONENTS filesystem thread timer date_time chrono regex serialization atomic program_options)
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

if (${HOST_ABI} MATCHES "-w64-mingw32")
    target_link_options(${MONERO_FLAVOR}_wallet2_api_c PRIVATE "-Wl,--section-alignment,16384")
elseif(${HOST_ABI} MATCHES "-linux-")
    target_link_options(${MONERO_FLAVOR}_wallet2_api_c PRIVATE "-Wl,-z,max-page-size=16384")
endif()

if(${HOST_ABI} MATCHES "-apple-")
    set(DUMMY_RT_SRC "${CMAKE_CURRENT_BINARY_DIR}/dummy_rt.c")
    file(WRITE "${DUMMY_RT_SRC}" "/* I have no idea what is adding -lrt in the middle of nowhere. And frankly I don't care at this point */\n")

    add_library(dummy_rt STATIC "${DUMMY_RT_SRC}")

    target_sources(dummy_rt PRIVATE "${DUMMY_RT_SRC}")
    target_compile_definitions(dummy_rt PRIVATE DUMMY_RT_SYMBOL)

    set_target_properties(dummy_rt PROPERTIES
        OUTPUT_NAME "rt"
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    )
endif()

target_link_libraries(  ${MONERO_FLAVOR}_wallet2_api_c

                        ${WALLET_TARGETS}
                        ${EXTRA_LIBS_WOWNEROSEED}
                        ${EXTRA_LIBS_ANDROID}
                        ${EXTRA_LIBS_LINUX}
                       )
