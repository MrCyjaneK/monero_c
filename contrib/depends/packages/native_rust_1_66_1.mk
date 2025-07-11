package=native_rust_1_66_1
$(package)_version=1.66.1
$(package)_download_path=https://static.rust-lang.org/dist
$(package)_file_name=rustc-$($(package)_version)-src.tar.gz
$(package)_download_file=$($(package)_file_name)
$(package)_sha256_hash=5b3c933a94c72187705d4ee293198babfdd09442f5937fbd685db3a81f4959ba
$(package)_dependencies=native_rust_1_65_0
$(package)_patches=assembly.h.patch

define $(package)_preprocess_cmds
    cd $($(package)_extract_dir) && \
    patch -p1 < $($(package)_patch_dir)/assembly.h.patch && \
    sed -i '18i#include <cstdint>' src/llvm-project/llvm/include/llvm/Support/Signals.h || true && \
    echo '[build]' > config.toml && \
    echo 'full-bootstrap = true' >> config.toml && \
    echo 'vendor = true' >> config.toml && \
    echo 'extended = true' >> config.toml && \
    echo 'rustc = "$(host_prefix)/native/rust_1_65_0/bin/rustc"' >> config.toml && \
    echo 'cargo = "$(host_prefix)/native/rust_1_65_0/bin/cargo"' >> config.toml && \
    echo '[llvm]' >> config.toml && \
    echo 'ninja = false' >> config.toml && \
    echo 'download-ci-llvm = false' >> config.toml
endef

define $(package)_build_cmds
    python3 ./x.py build --stage 3 -j $(NUM_PROC)
endef

define $(package)_stage_cmds
    mkdir -p $($(package)_staging_prefix_dir)/native/rust_1_66_1/bin && \
    cp -a build/*/stage3/lib $($(package)_staging_prefix_dir)/native/rust_1_66_1 && \
    cp -a build/*/stage3/bin/rustc $($(package)_staging_prefix_dir)/native/rust_1_66_1/bin && \
    cp -a build/*/stage3-tools-bin/cargo $($(package)_staging_prefix_dir)/native/rust_1_66_1/bin
endef

define $(package)_postprocess_cmds
    rm -rf $($(package)_staging_prefix_dir)/share/man
endef