package=zeromq
$(package)_version=4.3.5
$(package)_download_path=https://github.com/zeromq/libzmq/releases/download/v$($(package)_version)/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=6653ef5910f17954861fe72332e68b03ca6e4d9c7160eb3a8de5a5a913bfab43
$(package)_patches=fix_declaration.patch

define $(package)_set_vars
  $(package)_config_opts=--without-documentation --disable-shared --without-libsodium --disable-curve
  $(package)_config_opts_linux=--with-pic
  $(package)_config_opts_freebsd=--with-pic
  $(package)_config_opts_ios=--host=$(host_arch)-apple-darwin
  $(package)_config_opts_iossimulator=--host=$(host_arch)-apple-darwin
  $(package)_cxxflags=-std=c++11
  $(package)_cxxflags_darwin=-std=c++11
  $(package)_cxxflags_ios=-std=c++11
endef

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/fix_declaration.patch
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE) -j$(NUM_CORES) src/libzmq.la
endef

define $(package)_stage_cmds
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) install-pkgconfigDATA VERBOSE=1 &&\
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) install-libLTLIBRARIES VERBOSE=1 &&\
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) install-includeHEADERS VERBOSE=1
endef

define $(package)_postprocess_cmds
  rm -rf bin share &&\
  rm lib/*.la || true
endef

