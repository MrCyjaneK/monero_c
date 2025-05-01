package=native_mrustc
$(package)_version=0.11
$(package)_download_path=https://github.com/thepowersgang/mrustc/archive
$(package)_download_file=b6754f574f8846eb842feba4ccbeeecb10bdfacc.tar.gz
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=4b006089cf770fd31971ac93d690bf485483a4a309460a6ef41fa64cf1f87649
$(package)_dependencies=native_ccache

define $(package)_set_vars
$(package)_config_opts=
$(package)_build_opts=
$(package)_build_env=
endef

define $(package)_preprocess_cmds
  cd $($(package)_extract_dir) && \
  if [ -f script-overrides/stable-1.54.0-macos/build_std.txt ]; then \
    ARCH=`uname -m | sed 's/arm64/aarch64/'` && \
    sed -i.bak "s/STD_ENV_ARCH=[a-zA-Z0-9_]*/STD_ENV_ARCH=$$ARCH/" script-overrides/stable-1.54.0-macos/build_std.txt; \
  fi && \
  if [ `uname -s` = "Darwin" ]; then \
    echo 'Patching mrustc to work with clang on macOS' && \
    sed -i.bak 's/-fno-tree-sra//g' Makefile && \
    grep -rl -- "-fno-tree-sra" . | xargs sed -i.bak 's/-fno-tree-sra//g'; \
  fi
endef

define $(package)_build_cmds
  cd $($(package)_extract_dir) && \
  $($(package)_build_env) PARLEVEL=$(shell nproc) ./build-1.54.0.sh -j$(shell nproc)
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_staging_dir)/native/bin $($(package)_staging_dir)/native/lib && \
  cp bin/mrustc bin/minicargo $($(package)_staging_dir)/native/bin && \
  cp -r output-1.54.0 $($(package)_staging_dir)/native/lib
endef

define $(package)_postprocess_cmds
  rm -rf $($(package)_staging_dir)/native/lib/output-1.54.0/rustc-build
endef 