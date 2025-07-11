package=native_mrustc
$(package)_version=0.11.0
$(package)_download_path=https://github.com/thepowersgang/mrustc/archive
$(package)_download_file=06b87d1af49d2db3bd850fdee8888055dd540dd1.tar.gz
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=d3d3b84a100e71628afecf1125dbaa9bfc54ef9578c4fd81d75dca34c96f2565
$(package)_dependencies=native_ccache
$(package)_patches=codegen_c.cpp.patch

define $(package)_preprocess_cmds
  cd $($(package)_extract_dir) && \
  patch -p1 < $($(package)_patch_dir)/codegen_c.cpp.patch && \
  if [ -f script-overrides/stable-1.54.0-macos/build_std.txt ]; then \
    ARCH=`uname -m | sed 's/arm64/aarch64/'` && \
    sed -i.bak "s/STD_ENV_ARCH=[a-zA-Z0-9_]*/STD_ENV_ARCH=$$$$ARCH/" script-overrides/stable-1.54.0-macos/build_std.txt; \
  fi && \
  if [ -f script-overrides/stable-1.54.0-linux/build_std.txt ]; then \
    ARCH=`uname -m | sed 's/arm64/aarch64/'` && \
    sed -i.bak "s/STD_ENV_ARCH=[a-zA-Z0-9_]*/STD_ENV_ARCH=$$$$ARCH/" script-overrides/stable-1.54.0-linux/build_std.txt; \
  fi && \
  sed -i.bak 's/^make$$$$/make $$$$@/' build-1.54.0.sh &&\
  sed -i '' 's/^[[:space:]]*RUSTC_TARGET ?= x86_64-apple-darwin/RUSTC_TARGET ?= aarch64-apple-darwin/' run_rustc/Makefile && \
  echo >> build-1.54.0.sh && \
  echo make -C run_rustc >> build-1.54.0.sh
endef

define $(package)_build_cmds
  cd $($(package)_extract_dir) && \
  $($(package)_build_env) PARLEVEL=$(shell nproc) ./build-1.54.0.sh -j$(shell nproc)
endef

# FIXME bad dylib paths embedded in the rustc binary, forcing install_name_tool dark magic
define $(package)_stage_cmds
    mkdir -p $($(package)_staging_prefix_dir)/native/rust_1_54_0/bin && \
    cp -a run_rustc/output-1.54.0/prefix/bin/ $($(package)_staging_prefix_dir)/native/rust_1_54_0/bin && \
    cp -a run_rustc/output-1.54.0/prefix/lib $($(package)_staging_prefix_dir)/native/rust_1_54_0/lib && \
    if [ `uname -s` = "Darwin" ]; then \
    install_name_tool -change $($(package)_extract_dir)/run_rustc/output-1.54.0/build-rustc/aarch64-apple-darwin/release/deps/librustc_driver.dylib @loader_path/../lib/rustlib/aarch64-apple-darwin/lib/librustc_driver.dylib $($(package)_staging_prefix_dir)/native/rust_1_54_0/bin/rustc_binary && \
    install_name_tool -change $($(package)_extract_dir)/run_rustc/output-1.54.0/build-std2/aarch64-apple-darwin/release/deps/libstd.dylib @loader_path/../lib/rustlib/aarch64-apple-darwin/lib/libstd.dylib $($(package)_staging_prefix_dir)/native/rust_1_54_0/bin/rustc_binary && \
    install_name_tool -change $($(package)_extract_dir)/run_rustc/output-1.54.0/build-std2/aarch64-apple-darwin/release/deps/libstd.dylib @loader_path/libstd.dylib $($(package)_staging_prefix_dir)/native/rust_1_54_0/lib/rustlib/aarch64-apple-darwin/lib/librustc_driver.dylib; \
    fi
endef
