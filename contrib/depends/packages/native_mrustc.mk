package=native_mrustc
$(package)_version=0.11.0
$(package)_download_path=https://github.com/thepowersgang/mrustc/archive
$(package)_download_file=06b87d1af49d2db3bd850fdee8888055dd540dd1.tar.gz
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=d3d3b84a100e71628afecf1125dbaa9bfc54ef9578c4fd81d75dca34c96f2565
$(package)_dependencies=native_ccache

define $(package)_preprocess_cmds
  cd $($(package)_extract_dir) && \
  if [ -f script-overrides/stable-1.54.0-macos/build_std.txt ]; then \
    ARCH=`uname -m | sed 's/arm64/aarch64/'` && \
    sed -i.bak "s/STD_ENV_ARCH=[a-zA-Z0-9_]*/STD_ENV_ARCH=$$$$ARCH/" script-overrides/stable-1.54.0-macos/build_std.txt; \
  fi && \
  if [ -f script-overrides/stable-1.54.0-linux/build_std.txt ]; then \
    ARCH=`uname -m | sed 's/arm64/aarch64/'` && \
    sed -i.bak "s/STD_ENV_ARCH=[a-zA-Z0-9_]*/STD_ENV_ARCH=$$$$ARCH/" script-overrides/stable-1.54.0-linux/build_std.txt; \
  fi && \
  if [ `uname -s` = "Darwin" ]; then \
    echo 'Patching mrustc to work with clang on macOS' && \
    sed -i.bak 's/-fno-tree-sra//g' Makefile && \
    grep -rl -- "-fno-tree-sra" . | xargs sed -i.bak 's/-fno-tree-sra//g'; \
  fi && \
  sed -i.bak 's/^make$$$$/make $$$$@/' build-1.54.0.sh &&\
  echo >> build-1.54.0.sh && \
  echo make -C run_rustc >> build-1.54.0.sh
endef

define $(package)_build_cmds
  cd $($(package)_extract_dir) && \
  $($(package)_build_env) PARLEVEL=$(shell nproc) ./build-1.54.0.sh -j$(shell nproc)
endef

define $(package)_stage_cmds
    mkdir -p $($(package)_staging_prefix_dir)/native/rust_1_54_0/bin && \
    cp -a run_rustc/output-1.54.0/prefix-2/bin/rustc $($(package)_staging_prefix_dir)/native/rust_1_54_0/bin && \
    cp -a run_rustc/output-1.54.0/prefix/bin/cargo $($(package)_staging_prefix_dir)/native/rust_1_54_0/bin && \
    cp -a run_rustc/output-1.54.0/prefix-2/lib $($(package)_staging_prefix_dir)/native/rust_1_54_0/lib
endef
