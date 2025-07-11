package=native_ccache
$(package)_version=4.10.2
$(package)_download_path=https://samba.org/ftp/ccache
$(package)_file_name=ccache-$($(package)_version).tar.gz
$(package)_sha256_hash=108100960bb7e64573ea925af2ee7611701241abb36ce0aae3354528403a7d87
$(package)_dependencies=native_nproc

define $(package)_set_vars
$(package)_config_opts=-DCMAKE_INSTALL_PREFIX="$(host_prefix)/native" -DENABLE_TESTING=OFF
endef

define $(package)_config_cmds
  cmake -S . -B build $($(package)_config_opts)
endef

define $(package)_build_cmds
  $($(package)_build_env) cmake --build build --parallel $(shell nproc)
endef

define $(package)_stage_cmds
  cd build && $(MAKE) -j1 DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm -rf $($(package)_staging_dir)/lib $($(package)_staging_dir)/include
endef
