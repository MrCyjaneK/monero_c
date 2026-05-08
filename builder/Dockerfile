FROM golang:1.26.0-bookworm@sha256:c7a82e9e2df2fea5d8cb62a16aa6f796d2b2ed81ccad4ddd2bc9f0d22936c3f2 AS builder_base

WORKDIR /w
RUN apt update \
    && apt install -y git clang llvm gcc g++ sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash user \
    && adduser user sudo \
    && chown user:user /w \
    && chmod 775 /w

USER user

RUN git config --global user.email "monero_c@mrcyjanek.net" \
    && git config --global user.name "MoneroC CI" \
    && git config --global --add safe.directory '*'

FROM builder_base AS contrib_simplybs
COPY contrib/depends /w/contrib/depends
RUN sudo chown -R user:user /w \
    && cd /w/contrib/depends \
    && make simplybs
WORKDIR /w/contrib/depends

RUN make HOST=aarch64-linux-android && make HOST=aarch64-linux-android BOOST_VERSION=1_83_0 && make sbs-cleanup
RUN make HOST=x86_64-linux-android && make HOST=x86_64-linux-android BOOST_VERSION=1_83_0 && make sbs-cleanup
RUN make HOST=armv7a-linux-androideabi && make HOST=armv7a-linux-androideabi BOOST_VERSION=1_83_0 && make sbs-cleanup
RUN make HOST=x86_64-w64-mingw32 && make sbs-cleanup
RUN make HOST=aarch64-linux-gnu && make sbs-cleanup
RUN make HOST=x86_64-linux-gnu && make sbs-cleanup
RUN make HOST=x86_64-apple-darwin && make sbs-cleanup
RUN make HOST=aarch64-apple-darwin && make sbs-cleanup 
RUN make HOST=aarch64-apple-ios && make HOST=aarch64-apple-ios BOOST_VERSION=1_83_0 && make sbs-cleanup
RUN make HOST=aarch64-apple-ios-simulator && make HOST=aarch64-apple-ios-simulator BOOST_VERSION=1_83_0 && make sbs-cleanup

FROM builder_base AS monero_c_base
COPY . /w
RUN sudo chown -R user:user /w
RUN git submodule update --init --force --recursive \
    && for coin in monero wownero zano; do \
        ./apply_patches.sh $coin \
        && count=$(find patches/$coin -maxdepth 1 -name "*.patch" | wc -l) \
        && count=$((count + 2)) \
        && cd $coin && git reset HEAD~$count \
        && cd ..; \
    done

FROM monero_c_base AS monero_c
COPY --from=contrib_simplybs /w/contrib/depends /w/contrib/depends
RUN sudo chown -R user:user /w
RUN ./build_single.sh monero aarch64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano aarch64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero x86_64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano x86_64-linux-android -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero armv7a-linux-androideabi -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero armv7a-linux-androideabi -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano armv7a-linux-androideabi -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero aarch64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero x86_64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-linux-gnu -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero x86_64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero aarch64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-apple-darwin -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero aarch64-apple-ios -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-apple-ios -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano aarch64-apple-ios -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero aarch64-apple-ios-simulator -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero aarch64-apple-ios-simulator -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh zano aarch64-apple-ios-simulator -j$(nproc) && cd contrib/depends && make sbs-cleanup

RUN ./build_single.sh monero x86_64-w64-mingw32 -j$(nproc) && cd contrib/depends && make sbs-cleanup
RUN ./build_single.sh wownero x86_64-w64-mingw32 -j$(nproc) && cd contrib/depends && make sbs-cleanup

FROM alpine AS final
COPY --from=monero_c /w/release/ release/
