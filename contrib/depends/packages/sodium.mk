package=sodium
$(package)_version=1.0.18
$(package)_download_path=https://download.libsodium.org/libsodium/releases/
$(package)_file_name=libsodium-$($(package)_version).tar.gz
$(package)_sha256_hash=6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1
$(package)_patches=disable-glibc-getrandom-getentropy.patch fix-whitespace.patch

define $(package)_set_vars
$(package)_config_env_android=ANDROID_NDK_ROOT="$(host_prefix)/native" PATH="${PATH}:$(host_prefix)/native/bin" CC=clang AR=ar RANLIB=ranlib
$(package)_config_opts=--enable-static --disable-shared --with-pic
$(package)_config_opts+=--prefix=$(host_prefix)
endef

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/disable-glibc-getrandom-getentropy.patch &&\
  patch -p1 < $($(package)_patch_dir)/fix-whitespace.patch &&\
  cp -f $(BASEDIR)/config.guess build-aux/config.guess &&\
  cp -f $(BASEDIR)/config.sub build-aux/config.sub
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) -j1 DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm lib/*.la
endef

