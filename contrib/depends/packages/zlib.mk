package=zlib
$(package)_version=1.3.1
$(package)_download_path=https://github.com/madler/zlib/releases/download/v$($(package)_version)
$(package)_file_name=zlib-$($(package)_version).tar.xz
$(package)_sha256_hash=38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32

# Detect Android
is_android := $(findstring android,$(HOST))
ANDROID_API = 21

define $(package)_set_vars
  $(package)_config_opts = --static --prefix=$(host_prefix)

  ifneq ($(is_android),)
    $(package)_cc     = $(HOST)$(ANDROID_API)-clang
    $(package)_cxx    = $(HOST)$(ANDROID_API)-clang++
    $(package)_ar     = $(HOST)-ar
    $(package)_ranlib = $(HOST)-ranlib
    $(package)_ld     = $(HOST)-ld.lld
    $(package)_cflags = -fPIC -O2
  else
    $(package)_cc     = $(CC)
    $(package)_cxx    = $(CXX)
    $(package)_ar     = $(AR)
    $(package)_ranlib = $(RANLIB)
    $(package)_ld     = $(LD)
    $(package)_cflags = -fPIC -O2
  endif
endef

define $(package)_config_cmds
  CC="$($(package)_cc)" \
  CFLAGS="$($(package)_cflags)" \
  AR="$($(package)_ar)" \
  RANLIB="$($(package)_ranlib)" \
  ./configure $($(package)_config_opts)
endef

define $(package)_build_cmds
  $(MAKE) -j$(NUM_CORES)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef
