package=protobuf
$(package)_version=$(native_$(package)_version)
$(package)_download_path=$(native_$(package)_download_path)
$(package)_file_name=$(native_$(package)_file_name)
$(package)_sha256_hash=$(native_$(package)_sha256_hash)
$(package)_dependencies=native_$(package)
$(package)_cxxflags=-std=c++11
$(package)_patches=visibility.patch

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --with-protoc=$(build_prefix)/bin/protoc
  $(package)_config_opts_linux=--with-pic
  $(package)_ar=$($(package)_ar)
endef

define $(package)_preprocess_cmds
  patch -p0 < $($(package)_patch_dir)/visibility.patch && \
  cp -f $(BASEDIR)/config.guess config.guess &&\
  cp -f $(BASEDIR)/config.sub config.sub &&\
  cp -f $(BASEDIR)/config.guess third_party/googletest/googletest/build-aux/config.guess &&\
  cp -f $(BASEDIR)/config.sub third_party/googletest/googletest/build-aux/config.sub &&\
  cp -f $(BASEDIR)/config.guess third_party/googletest/googlemock/build-aux/config.guess &&\
  cp -f $(BASEDIR)/config.sub third_party/googletest/googlemock/build-aux/config.sub
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE) -j$(NUM_CORES) -C src libprotobuf.la
endef

define $(package)_stage_cmds
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) -C src install-libLTLIBRARIES install-nobase_includeHEADERS &&\
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) install-pkgconfigDATA
endef

define $(package)_postprocess_cmds
  rm lib/libprotoc.a &&\
  rm lib/*.la
endef

