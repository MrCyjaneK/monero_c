FROM --platform=linux/amd64 golang:1.26.0-bookworm AS builder_base
WORKDIR /w
RUN apt update \
    && apt install -y git clang llvm gcc g++ sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash user

USER user

RUN git config --global user.email "monero_c@mrcyjanek.net" \
    && git config --global user.name "MoneroC CI" \
    && git config --global --add safe.directory '*'

FROM builder_base AS contrib_simplybs
COPY contrib/depends /w/contrib/depends
RUN cd /w/contrib/depends \
    && make simplybs \
    && make HOST=aarch64-linux-android \
    && make HOST=aarch64-linux-android BOOST_VERSION=1_83_0 \
    && make HOST=x86_64-linux-android \
    && make HOST=x86_64-linux-android BOOST_VERSION=1_83_0 \
    && make HOST=armv7a-linux-androideabi \
    && make HOST=armv7a-linux-androideabi BOOST_VERSION=1_83_0 \
    && make HOST=aarch64-linux-gnu \
    && make HOST=aarch64-linux-gnu BOOST_VERSION=1_83_0 \
    && make HOST=x86_64-linux-gnu \
    && make HOST=x86_64-apple-darwin \
    && make HOST=x86_64-apple-darwin BOOST_VERSION=1_83_0 \
    && make HOST=aarch64-apple-darwin \
    && make HOST=aarch64-apple-darwin BOOST_VERSION=1_83_0 \
    && make HOST=aarch64-apple-ios \
    && make HOST=aarch64-apple-ios BOOST_VERSION=1_83_0 \
    && make HOST=aarch64-apple-ios-simulator \
    && make HOST=aarch64-apple-ios-simulator BOOST_VERSION=1_83_0 \
    && make sbs-cleanup

FROM builder_base AS monero_c_base
COPY . /w
RUN git submodule update --init --force --recursive \
    && ./apply_patches.sh monero \
    && ./apply_patches.sh wownero \
    && ./apply_patches.sh zano

FROM monero_c_base AS monero_c_aarch64_linux_android
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero aarch64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano aarch64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_x86_64_linux_android
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero x86_64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano x86_64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_armv7a_linux_androideabi
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero armv7a-linux-androideabi -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero armv7a-linux-androideabi -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano armv7a-linux-androideabi -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_aarch64_linux_gnu
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero aarch64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_x86_64_linux_gnu
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero x86_64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_x86_64_apple_darwin
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero x86_64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_aarch64_apple_darwin
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero aarch64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_aarch64_apple_ios
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero aarch64-apple-ios -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-apple-ios -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano aarch64-apple-ios -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_aarch64_apple_ios-simulator
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero aarch64-apple-ios-simulator -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-apple-ios-simulator -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano aarch64-apple-ios-simulator -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM monero_c_base AS monero_c_x86_64-w64-mingw32
COPY --from=builder /w/contrib/depends /w/contrib/depends
RUN ./build_single.sh monero x86_64-w64-mingw32 -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-w64-mingw32 -j$(nproc) && cd contrib/depends && make sbs-cleanup


FROM scratch AS final
COPY --from=monero_c_aarch64_linux_android /w/release/ release/
COPY --from=monero_c_x86_64_linux_android /w/release/ release/
COPY --from=monero_c_armv7a_linux_androideabi /w/release/ release/
COPY --from=monero_c_aarch64_linux_gnu /w/release/ release/
COPY --from=monero_c_x86_64_linux_gnu /w/release/ release/
COPY --from=monero_c_x86_64_apple_darwin /w/release/ release/
COPY --from=monero_c_aarch64_apple_darwin /w/release/ release/
COPY --from=monero_c_aarch64_apple_ios /w/release/ release/
COPY --from=monero_c_aarch64_apple_ios-simulator /w/release/ release/
COPY --from=monero_c_x86_64-w64-mingw32 /w/release/ release/
