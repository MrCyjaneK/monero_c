package=protobuf3
$(package)_version=3.6.1
$(package)_download_path=https://github.com/protocolbuffers/protobuf/releases/download/v$($(package)_version)/
$(package)_file_name=protobuf-cpp-$($(package)_version).tar.gz
$(package)_sha256_hash=b3732e471a9bb7950f090fd0457ebd2536a9ba0891b7f3785919c654fe2a2529
$(package)_cxxflags=-std=c++11

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --prefix=$(build_prefix)
  $(package)_config_opts_linux=--with-pic
endef

define $(package)_preprocess_cmds
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
  $(MAKE) -j$(NUM_CORES) -C src
endef

define $(package)_stage_cmds
  $(MAKE) -j$(NUM_CORES) DESTDIR=$($(package)_staging_dir) -C src install
endef

define $(package)_postprocess_cmds
  rm lib/libprotoc.a || true
endef
