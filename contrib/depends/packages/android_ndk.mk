package=android_ndk
$(package)_version=26d
$(package)_download_path=https://dl.google.com/android/repository/
$(package)_file_name=android-ndk-r$($(package)_version)-linux.zip
$(package)_sha256_hash=eefeafe7ccf177de7cc57158da585e7af119bb7504a63604ad719e4b2a328b54

$(package)_version_apiversion=21

define $(package)_set_vars
$(package)_config_opts_armv7a=--arch arm
$(package)_config_opts_aarch64=--arch arm64
$(package)_config_opts_x86_64=--arch x86_64
$(package)_config_opts_i686=--arch x86
endef

define $(package)_extract_cmds
  echo $($(package)_sha256_hash) $($(1)_source_dir)/$($(package)_file_name) | sha256sum -c &&\
  unzip -q $($(1)_source_dir)/$($(package)_file_name)
endef

# arm-linux-androideabi-ar - openssl workaround

define $(package)_stage_cmds
  mkdir -p $(build_prefix) &&\
  echo $(build_prefix)/toolchain && \
  android-ndk-r$($(package)_version)/build/tools/make_standalone_toolchain.py --api $($(package)_version_apiversion) \
    --install-dir $(build_prefix)/toolchain --stl=libc++ $($(package)_config_opts) &&\
  mv $(build_prefix)/toolchain $($(package)_staging_dir)/$(host_prefix)/native && \
  cp $($(package)_staging_dir)/$(host_prefix)/native/bin/llvm-ar $($(package)_staging_dir)/$(host_prefix)/native/bin/$(host)$($(package)_version_apiversion)-ar &&\
  cp $($(package)_staging_dir)/$(host_prefix)/native/bin/llvm-ar $($(package)_staging_dir)/$(host_prefix)/native/bin/arm-linux-androideabi-ar &&\
  cp $($(package)_staging_dir)/$(host_prefix)/native/bin/llvm-ranlib $($(package)_staging_dir)/$(host_prefix)/native/bin/$(host)$($(package)_version_apiversion)-ranlib &&\
  cp $($(package)_staging_dir)/$(host_prefix)/native/bin/llvm-ranlib $($(package)_staging_dir)/$(host_prefix)/native/bin/arm-linux-androideabi-ranlib &&\
  cp $($(package)_staging_dir)/$(host_prefix)/native/bin/llvm-ar $($(package)_staging_dir)/$(host_prefix)/native/bin/$(host)-ar &&\
  cp $($(package)_staging_dir)/$(host_prefix)/native/bin/llvm-ranlib $($(package)_staging_dir)/$(host_prefix)/native/bin/$(host)-ranlib
endef

