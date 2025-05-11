package=native_rust_1_68_2
$(package)_version=1.68.2
$(package)_download_path=https://static.rust-lang.org/dist
$(package)_file_name=rustc-$($(package)_version)-src.tar.gz
$(package)_download_file=$($(package)_file_name)
$(package)_sha256_hash=93339c23f7cd4d0c45db58e18b4c6e16d6070f4277aad9d2492d23294bf32e96
$(package)_dependencies=native_rust_1_67_1

define $(package)_preprocess_cmds
    sed -i '18i#include <cstdint>' src/llvm-project/llvm/include/llvm/Support/Signals.h || true && \
    echo '[build]' > config.toml && \
    echo 'full-bootstrap = true' >> config.toml && \
    echo 'vendor = true' >> config.toml && \
    echo 'extended = true' >> config.toml && \
    echo 'rustc = "$(host_prefix)/native/rust_1_67_1/bin/rustc"' >> config.toml && \
    echo 'cargo = "$(host_prefix)/native/rust_1_67_1/bin/cargo"' >> config.toml && \
    echo '[llvm]' >> config.toml && \
    echo 'ninja = false' >> config.toml && \
    echo 'download-ci-llvm = false' >> config.toml
endef

define $(package)_build_cmds
    python3 ./x.py build --stage 3
endef

define $(package)_stage_cmds
    mkdir -p $($(package)_staging_prefix_dir)/native/rust_1_68_2/bin && \
    cp -a build/*/stage3/lib $($(package)_staging_prefix_dir)/native/rust_1_68_2 && \
    cp -a build/*/stage3/bin/rustc $($(package)_staging_prefix_dir)/native/rust_1_68_2/bin && \
    cp -a build/*/stage3-tools-bin/cargo $($(package)_staging_prefix_dir)/native/rust_1_68_2/bin
endef
