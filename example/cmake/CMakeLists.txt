cmake_minimum_required(VERSION 3.1...3.29.2)

include(CMakePrintHelpers)

set(MONERO_C_COMMIT 36e61433c78750317ced29f0fc94ad22af16111d)
set(MONERO_C_MIRROR https://git.mrcyjanek.net/mrcyjanek/monero_c)
set(MONERO_C_WOWNERO OFF)
set(MONERO_C_MONERO ON)


cmake_print_variables(MONERO_C_COMMIT)
cmake_print_variables(MONERO_C_MIRROR)
cmake_print_variables(MONERO_C_MONERO)
cmake_print_variables(MONERO_C_WOWNERO)

project(
  monero_c
  VERSION 0.0.0)

if(NOT EXISTS monero_c)
    execute_process(COMMAND git clone https://git.mrcyjanek.net/mrcyjanek/monero_c)
endif()

execute_process(WORKING_DIRECTORY monero_c COMMAND git checkout ${MONERO_C_COMMIT})
execute_process(WORKING_DIRECTORY monero_c COMMAND git submodule update --recursive --force --init)

execute_process(COMMAND rm monero_c/monero/.patch-applied)
execute_process(COMMAND rm monero_c/wownero/.patch-applied)

# apply patches

if (MONERO_C_MONERO)
    execute_process(WORKING_DIRECTORY monero_c COMMAND ./apply_patches.sh monero)
endif()

if (MONERO_C_WOWNERO)
    execute_process(WORKING_DIRECTORY monero_c COMMAND ./apply_patches.sh wownero)
endif()

# actually.. build the software
if (MONERO_C_MONERO)
    add_custom_command(
        COMMAND ./build_single.sh monero host-apple-darwin -j8
        OUTPUT monero_c/release/monero/host-apple-darwin_libwallet2_api_c.dylib.xz
        WORKING_DIRECTORY monero_c
    )

    add_custom_command(
        COMMAND unxz -f monero_c/release/monero/host-apple-darwin_libwallet2_api_c.dylib.xz
        OUTPUT monero_c/release/monero/host-apple-darwin_libwallet2_api_c.dylib
        DEPENDS monero_c/release/monero/host-apple-darwin_libwallet2_api_c.dylib.xz
    )

    add_custom_command(
        COMMAND mv monero_c/release/monero/host-apple-darwin_libwallet2_api_c.dylib monero_host-apple-darwin_libwallet2_api_c.dylib
        OUTPUT host-apple-darwin_monero_libwallet2_api_c.dylib
        DEPENDS monero_c/release/monero/host-apple-darwin_libwallet2_api_c.dylib
    )
endif()

add_custom_target(
    .host-apple-darwin_monero_libwallet2_api_c.dylib ALL
    DEPENDS host-apple-darwin_monero_libwallet2_api_c.dylib
)