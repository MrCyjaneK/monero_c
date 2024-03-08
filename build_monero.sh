#!/bin/bash
# monero_c build instructions for linux

# linux targets
x86_64-linux-gnu
i686-linux-gnu
aarch64-linux-gnu

# apple
x86_64-apple-darwin11
aarch64-apple-darwin11

# Android
x86_64-linux-android
i686-linux-android
aarch64-linux-android
armv7a-linux-androideabi

# windows
# update-alternatives --set x86_64-w64-mingw32-g++ x86_64-w64-mingw32-g++-posix
# update-alternatives --set x86_64-w64-mingw32-gcc x86_64-w64-mingw32-gcc-posix
x86_64-w64-mingw32
i686-w64-mingw32


    # - image: git.mrcyjanek.net/mrcyjanek/debian:bookworm
    #   platform: linux/amd64
    #   make_steps: depends_host monero_linux_amd64 moneroc_linux_host64
    #   prepare_cmd: echo ok
    #   prepare_cmd_depends: echo ok
    #   triplet: x86_64-linux-gnu
    #   cc: clang
    #   cxx: clang++
    #   host:
    #   boost_toolset: clang