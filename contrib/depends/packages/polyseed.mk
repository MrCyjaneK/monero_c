package=polyseed
$(package)_version=2.0.0-patch
$(package)_download_path=https://github.com/MrCyjaneK/$(package)/archive/refs/tags/
$(package)_download_file=v$($(package)_version).tar.gz
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=28a86b0bc178076ac65dc7d8cc28a79eb546708473efc0e8dce688f1e237ccc2
$(package)_patches=force-static-mingw.patch 0001-disable-soname.patch

define $(package)_preprocess_cmds
    patch -p1 < $($(package)_patch_dir)/force-static-mingw.patch &&\
    patch -p1 < $($(package)_patch_dir)/0001-disable-soname.patch
endef

define $(package)_config_cmds
    CC="$($(package)_cc)" cmake -DCMAKE_INSTALL_PREFIX="$(host_prefix)" .
endef

define $(package)_set_vars
  $(package)_build_opts=CC="$($(package)_cc)"
endef

define $(package)_build_cmds
    CC="$($(package)_cc)" $(MAKE)
endef

define $(package)_stage_cmds
    $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef
