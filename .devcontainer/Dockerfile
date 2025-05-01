FROM --platform=linux/amd64 ghcr.io/cirruslabs/flutter:3.29.3
# FROM debian:bookworm
SHELL ["/bin/bash", "-c"]

# Install dependencies

# lintinfo5

SHELL ["/bin/bash", "-c"]

RUN apt update \
    && apt install -y sudo pigz wget build-essential pkg-config autoconf libtool ccache make cmake gcc g++ git curl lbzip2 libtinfo6 gperf unzip python-is-python3 zsh llvm libclang1-18 libc++-18-dev clang zlib1g-dev

# Install architecture-specific packages
RUN if [[ "$(uname -m)" == "x86_64" || "$(uname -m)" == "amd64" ]]; then \
        apt install -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 gcc-mingw-w64-i686 g++-mingw-w64-i686 gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gcc-i686-linux-gnu g++-i686-linux-gnu; \
    elif [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then \
        apt install -y gcc-x86-64-linux-gnu g++-x86-64-linux-gnu gcc-i686-linux-gnu g++-i686-linux-gnu; \
    fi

RUN bash -c 'if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] then rm -rf /opt/android-sdk-linux/platform-tools; fi'


ENV DENO_VERSION=v2.0.3
RUN if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] then export DENO_ARCH=aarch64-unknown-linux-gnu; fi; \
    if [[ "$(uname -m)" == "x86_64" || "$(uname -m)" == "amd64" ]] then export DENO_ARCH=x86_64-unknown-linux-gnu; fi; \
    wget -O /tmp/deno.zip "https://github.com/denoland/deno/releases/download/${DENO_VERSION}/deno-${DENO_ARCH}.zip" && \
    cd /tmp && \
    unzip /tmp/deno.zip && \
    mv deno /usr/local/bin && \
    rm -rf deno deno.zip

RUN apt install -y sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu

USER ubuntu

RUN git config --global --add safe.directory '*'
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" \
    -t robbyrussell 

ENV SUDO=sudo
