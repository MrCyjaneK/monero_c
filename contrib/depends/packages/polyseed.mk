package=polyseed
$(package)_version=2.1.0-patch
$(package)_download_path=https://github.com/MrCyjaneK/$(package)/archive/refs/tags/
$(package)_download_file=v$($(package)_version).tar.gz
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=7f5c583a1f48ee6d63174dd1f1485d00b02d76d6df0181bc42c54558502c8443
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
