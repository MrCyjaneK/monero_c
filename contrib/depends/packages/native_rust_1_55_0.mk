package=native_rust_1_55_0
$(package)_version=1.55.0
$(package)_download_path=https://static.rust-lang.org/dist
$(package)_file_name=rustc-$($(package)_version)-src.tar.gz
$(package)_download_file=$($(package)_file_name)
$(package)_sha256_hash=b2379ac710f5f876ee3c3e03122fe33098d6765d371cac6c31b1b6fc8e43821e
$(package)_dependencies=native_mrustc
$(package)_patches=assembly.h.patch

define $(package)_preprocess_cmds
    cd $($(package)_extract_dir) && \
    patch -p1 < $($(package)_patch_dir)/assembly.h.patch && \
    echo '[build]' > config.toml && \
    echo 'full-bootstrap = true' >> config.toml && \
    echo 'vendor = true' >> config.toml && \
    echo 'extended = true' >> config.toml && \
    echo 'rustc = "$(host_prefix)/native/rust_1_54_0/bin/rustc"' >> config.toml && \
    echo 'cargo = "$(host_prefix)/native/rust_1_54_0/bin/cargo"' >> config.toml && \
    echo '[llvm]' >> config.toml && \
    echo 'ninja = false' >> config.toml && \
    echo 'download-ci-llvm = false' >> config.toml
endef

define $(package)_build_cmds
    python3 ./x.py build --stage 3 --verbose -j $(NUM_PROC)
endef

define $(package)_stage_cmds
    mkdir -p $($(package)_staging_prefix_dir)/native/rust_1_55_0/bin && \
    cp -a build/*/stage3/lib $($(package)_staging_prefix_dir)/native/rust_1_55_0/ && \
    cp -a build/*/stage3/bin/rustc $($(package)_staging_prefix_dir)/native/rust_1_55_0/bin && \
    cp -a build/*/stage3-tools-bin/cargo $($(package)_staging_prefix_dir)/native/rust_1_55_0/bin
endef
