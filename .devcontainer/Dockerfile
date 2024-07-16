FROM debian:bookworm

# Install dependencies

RUN apt update \
    && apt install -y wget build-essential pkg-config autoconf libtool ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 gcc-mingw-w64-i686 g++-mingw-w64-i686 build-essential pkg-config autoconf libtool ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf unzip python-is-python3 build-essential pkg-config autoconf libtool ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gcc-i686-linux-gnu g++-i686-linux-gnu pkg-config autoconf libtool ccache make cmake gcc g++ git curl lbzip2 libtinfo5 gperf python-is-python3 zsh

# Install zsh and configure it

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" \
    -t robbyrussell 

RUN git config --global --add safe.directory '*'