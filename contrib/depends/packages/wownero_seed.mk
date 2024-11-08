package=wownero_seed
$(package)_version=0.3.0
$(package)_download_path=https://github.com/MrCyjaneK/wownero-seed/archive/
$(package)_download_file=d3f68be347facfeebbd8f68fd74982c705cb917b.tar.gz
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=3b59ccde08e0fee204680240af4b270a18a677aa0e6036a3504570193d232406
$(package)_patches=0001-fix-duplicate-symbol-error.patch

define $(package)_preprocess_cmds
    patch -p1 < $($(package)_patch_dir)/0001-fix-duplicate-symbol-error.patch
endef


ifeq ($(host_os),darwin)
    define $(package)_config_cmds
        CC="$($(package)_cc)" CXX="$($(package)_cxx)" cmake -DCMAKE_RANLIB="$($(package)_ranlib)" -DCMAKE_AR="$($(package)_ar)" -DCMAKE_INSTALL_PREFIX="$(host_prefix)" -DCMAKE_POSITION_INDEPENDENT_CODE=ON .
    endef
else
    define $(package)_config_cmds
        CC="$($(package)_cc)" CXX="$($(package)_cxx)" cmake -DCMAKE_INSTALL_PREFIX="$(host_prefix)" -DCMAKE_POSITION_INDEPENDENT_CODE=ON .
    endef
endif

define $(package)_set_vars
  $(package)_build_opts=CC="$($(package)_cc)" CXX="$($(package)_cxx)"
endef


define $(package)_build_cmds
    CC="$($(package)_cc)" CXX="$($(package)_cxx)" $(MAKE) VERBOSE=1
endef

define $(package)_stage_cmds
    CC="$($(package)_cc)" CXX="$($(package)_cxx)" $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef
