package=sqlite3

is_android := $(findstring android,$(HOST))
is_mingw   := $(findstring mingw,$(HOST))
is_ios     := $(findstring apple-ios,$(HOST))

ANDROID_API = 21

ifneq ($(is_ios),)
  $(package)_version=3350500
  $(package)_download_path=https://www.sqlite.org/2021/
  $(package)_file_name=sqlite-autoconf-$($(package)_version).tar.gz
  $(package)_download_file=$($(package)_file_name)
  $(package)_sha256_hash=f52b72a5c319c3e516ed7a92e123139a6e87af08a2dc43d7757724f6132e6db0
else
  $(package)_version=3510100
  $(package)_download_path=https://www.sqlite.org/2025/
  $(package)_file_name=sqlite-autoconf-$($(package)_version).tar.gz
  $(package)_download_file=$($(package)_file_name)
  $(package)_sha256_hash=4f2445cd70479724d32ad015ec7fd37fbb6f6130013bd4bfbc80c32beb42b7e0
endif

define $(package)_set_vars
  $(package)_config_opts = --disable-shared --enable-static
  $(package)_config_opts += --prefix=$(host_prefix)

  ifneq ($(is_android),)
    $(package)_config_opts += --host=$(HOST)
    $(package)_cc      = $(HOST)$(ANDROID_API)-clang
    $(package)_cxx     = $(HOST)$(ANDROID_API)-clang++
    $(package)_ar      = $(HOST)-ar
    $(package)_ranlib  = $(HOST)-ranlib
    $(package)_ld      = $(HOST)-ld.lld
  else ifneq ($(is_mingw),)
    $(package)_cc     = $(HOST)-gcc
    $(package)_ar     = $(HOST)-ar
    $(package)_ranlib = $(HOST)-ranlib
  else ifneq ($(is_ios),)
    $(package)_config_opts += --host=$(HOST)
    $(package)_config_opts += --build=x86_64-apple-darwin
    $(package)_config_opts += --disable-load-extension

    IOS_SDK := $(shell xcrun --sdk iphoneos --show-sdk-path)

    $(package)_cc     = xcrun --sdk iphoneos clang
    $(package)_cxx    = xcrun --sdk iphoneos clang++
    $(package)_ar     = xcrun --sdk iphoneos ar
    $(package)_ranlib = xcrun --sdk iphoneos ranlib

    $(package)_cflags += \
      -target arm64-apple-ios \
      -arch arm64 \
      -isysroot $(IOS_SDK) \
      -miphoneos-version-min=12.0 \
      -fembed-bitcode
  else
    $(package)_cc      = $(CC)
    $(package)_cxx     = $(CXX)
    $(package)_ar      = $(AR)
    $(package)_ranlib  = $(RANLIB)
    $(package)_ld      = $(LD)
  endif

  $(package)_cflags = -fPIC -O2 \
    -DSQLITE_ENABLE_COLUMN_METADATA \
    -DSQLITE_ENABLE_FTS5 \
    -DSQLITE_ENABLE_JSON1 \
    -DSQLITE_ENABLE_RTREE \
    -DSQLITE_THREADSAFE=1 
  $(package)_config_opts += --enable-threadsafe
endef

ifneq ($(is_ios),)
  define $(package)_config_cmds
    CC="$($(package)_cc)" CXX="$($(package)_cxx)" AR="$($(package)_ar)" RANLIB="$($(package)_ranlib)" \
    CFLAGS="$($(package)_cflags) $($(package)_cflags_$(HOST_OS))" CPPFLAGS="$($(package)_cflags)" \
    $($(package)_autoconf) $($(package)_config_opts)
  endef
else
  define $(package)_config_cmds
    CC="$($(package)_cc)" CXX="$($(package)_cxx)" AR="$($(package)_ar)" RANLIB="$($(package)_ranlib)" \
    CFLAGS="$($(package)_cflags) $($(package)_cflags_$(HOST_OS))" \
    $($(package)_autoconf) $($(package)_config_opts)
  endef
endif

ifneq ($(is_ios),)
  define $(package)_build_cmds
    $(MAKE) bin_PROGRAMS= libsqlite3.la
  endef
else
  define $(package)_build_cmds
    $(MAKE) -j$(NUM_CORES)
  endef
endif

ifneq ($(is_ios),)
  define $(package)_stage_cmds
    $(MAKE) DESTDIR=$($(package)_staging_dir) \
      bin_PROGRAMS= \
      install-libLTLIBRARIES install-includeHEADERS
  endef
else
  define $(package)_stage_cmds
    $(MAKE) DESTDIR=$($(package)_staging_dir) install
  endef
endif
