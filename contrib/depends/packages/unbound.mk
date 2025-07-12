package=unbound
$(package)_version=1.23.0
$(package)_download_path=https://www.nlnetlabs.nl/downloads/$(package)/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=959bd5f3875316d7b3f67ee237a56de5565f5b35fc9b5fc3cea6cfe735a03bb8
$(package)_dependencies=openssl expat
$(package)_patches=disable-glibc-reallocarray.patch

# ac_cv_type_pthread_spinlock_t -> disappeared in ndk r28
define $(package)_set_vars
  $(package)_config_opts=--disable-shared --enable-static --without-pyunbound --prefix=$(host_prefix)
  $(package)_config_opts+=--with-libexpat=$(host_prefix) --with-ssl=$(host_prefix) --with-libevent=no
  $(package)_config_opts+=--without-pythonmodule --disable-flto --with-pthreads --with-libunbound-only
  $(package)_config_opts_linux=--with-pic
  $(package)_config_opts_w64=--enable-static-exe --sysconfdir=/etc --prefix=$(host_prefix) --target=$(host_prefix)
  $(package)_config_opts_x86_64_darwin=ac_cv_func_SHA384_Init=yes
  $(package)_config_opts_android=ac_cv_type_pthread_spinlock_t=no
  $(package)_build_opts_mingw32=LDFLAGS="$($(package)_ldflags) -lpthread"
  $(package)_cflags_mingw32+="-D_WIN32_WINNT=0x600"
endef

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/disable-glibc-reallocarray.patch &&\
  autoconf
endef

define $(package)_config_cmds
  $($(package)_autoconf) $($(package)_config_opts) ac_cv_func_getentropy=no
endef

define $(package)_build_cmds
  $(MAKE) -j$(NUM_CORES) $($(package)_build_opts)
endef

define $(package)_stage_cmds
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) install
endef
