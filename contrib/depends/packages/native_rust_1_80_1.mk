package=native_rust_1_80_1
$(package)_version=1.80.1
$(package)_download_path=https://static.rust-lang.org/dist
$(package)_file_name=rustc-$($(package)_version)-src.tar.gz
$(package)_download_file=$($(package)_file_name)
$(package)_sha256_hash=24aed94eff8cea2c7e0ea3bae401f0ea07784105ed6fb457c25fb76dd41b5647
$(package)_dependencies=native_rust_1_79_0

define $(package)_preprocess_cmds
    sed -i '18i#include <cstdint>' src/llvm-project/llvm/include/llvm/Support/Signals.h || true && \
    echo '[build]' > config.toml && \
    echo 'full-bootstrap = true' >> config.toml && \
    echo 'vendor = true' >> config.toml && \
    echo 'extended = true' >> config.toml && \
    echo 'rustc = "$(host_prefix)/native/rust_1_79_0/bin/rustc"' >> config.toml && \
    echo 'cargo = "$(host_prefix)/native/rust_1_79_0/bin/cargo"' >> config.toml && \
    echo '[llvm]' >> config.toml && \
    echo 'ninja = false' >> config.toml && \
    echo 'download-ci-llvm = false' >> config.toml
endef

define $(package)_build_cmds
    python3 ./x.py build --stage 3
endef

define $(package)_stage_cmds
    mkdir -p $($(package)_staging_prefix_dir)/native/rust_1_80_1/bin && \
    cp -a build/*/stage3/lib $($(package)_staging_prefix_dir)/native/rust_1_80_1 && \
    cp -a build/*/stage3/bin/rustc $($(package)_staging_prefix_dir)/native/rust_1_80_1/bin && \
    cp -a build/*/stage3-tools-bin/cargo $($(package)_staging_prefix_dir)/native/rust_1_80_1/bin
endef
