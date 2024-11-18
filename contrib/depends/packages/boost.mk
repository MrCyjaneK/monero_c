package=boost
$(package)_version=1_85_0
$(package)_download_path=https://downloads.sourceforge.net/project/boost/boost/1.85.0/
$(package)_file_name=$(package)_$($(package)_version).tar.bz2
$(package)_sha256_hash=7009fe1faa1697476bdc7027703a2badb84e849b7b0baad5086b087b971f8617
$(package)_dependencies=libiconv
$(package)_patches=fix_io_control_hpp.patch static_iconv.patch

define $(package)_set_vars
$(package)_config_opts_release=variant=release
$(package)_config_opts_debug=variant=debug --build-dir=stage/debug
$(package)_config_opts=--layout=system --user-config=user-config.jam
$(package)_config_opts+=threading=multi link=static -sNO_BZIP2=1 -sNO_ZLIB=1
$(package)_config_opts_linux=threadapi=pthread runtime-link=static
$(package)_config_opts_android=threadapi=pthread runtime-link=static target-os=android
$(package)_config_opts_darwin=--toolset=darwin runtime-link=static
$(package)_config_opts_mingw32=binary-format=pe target-os=windows threadapi=win32 runtime-link=static
$(package)_config_opts_x86_64_mingw32=address-model=64
$(package)_config_opts_i686_mingw32=address-model=32
$(package)_config_opts_i686_linux=address-model=32 architecture=x86
$(package)_toolset_$(host_os)=gcc
$(package)_archiver_$(host_os)=$($(package)_ar)
$(package)_toolset_darwin=darwin
$(package)_archiver_darwin=$($(package)_libtool)
$(package)_config_libraries=system,filesystem,thread,timer,date_time,chrono,regex,serialization,atomic,program_options,locale,log
$(package)_cxxflags=-std=c++11
$(package)_cxxflags_linux=-fPIC
$(package)_cxxflags_freebsd=-fPIC
$(package)_cxxflags_android=-fPIC
$(package)_ldflags=-L$(host_prefix)/lib -L$(shell xcrun --sdk macosx --show-sdk-path)/usr/lib
endef

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/static_iconv.patch &&\
  echo "using $(boost_toolset_$(host_os)) : : $($(package)_cxx) : <cxxflags>\"$($(package)_cxxflags) $($(package)_cppflags)\" <linkflags>\"$($(package)_ldflags)\" <archiver>\"$(boost_archiver_$(host_os))\" <arflags>\"$($(package)_arflags)\" <striper>\"$(host_STRIP)\"  <ranlib>\"$(host_RANLIB)\" <rc>\"$(host_WINDRES)\" : ;" > user-config.jam
endef

define $(package)_config_cmds
  ./bootstrap.sh --with-libraries=$(boost_config_libraries)
endef

define $(package)_build_cmds
  ./b2 -d2 -j2 --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) $($(package)_config_opts_release) stage
endef

define $(package)_stage_cmds
  ./b2 -d0 -j4 --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) $($(package)_config_opts_release) install
endef
