define int_vars
#Set defaults for vars which may be overridden per-package
$(1)_cc=$($($(1)_type)_CC)
$(1)_cxx=$($($(1)_type)_CXX)
$(1)_objc=$($($(1)_type)_OBJC)
$(1)_objcxx=$($($(1)_type)_OBJCXX)
$(1)_ar=$($($(1)_type)_AR)
$(1)_ranlib=$($($(1)_type)_RANLIB)
$(1)_libtool=$($($(1)_type)_LIBTOOL)
$(1)_nm=$($($(1)_type)_NM)
$(1)_cflags=$($($(1)_type)_CFLAGS) $($($(1)_type)_$(release_type)_CFLAGS)
$(1)_cxxflags=$($($(1)_type)_CXXFLAGS) $($($(1)_type)_$(release_type)_CXXFLAGS)
$(1)_arflags=$($($(1)_type)_ARFLAGS) $($($(1)_type)_$(release_type)_ARFLAGS)
$(1)_ldflags=$($($(1)_type)_LDFLAGS) $($($(1)_type)_$(release_type)_LDFLAGS) -L$($($(1)_type)_prefix)/lib
$(1)_cppflags=$($($(1)_type)_CPPFLAGS) $($($(1)_type)_$(release_type)_CPPFLAGS) -I$($($(1)_type)_prefix)/include
$(1)_recipe_hash:=
endef

define int_get_all_dependencies
$(sort $(foreach dep,$(2),$(2) $(call int_get_all_dependencies,$(1),$($(dep)_dependencies))))
endef

define fetch_file_inner
    ( mkdir -p $$($(1)_download_dir) && echo Fetching $(3) from $(2) && \
    $(build_DOWNLOAD) "$$($(1)_download_dir)/$(4).temp" "$(2)/$(3)" && \
    echo "$(5)  $$($(1)_download_dir)/$(4).temp" > $$($(1)_download_dir)/.$(4).hash && \
    $(build_SHA256SUM) -c $$($(1)_download_dir)/.$(4).hash && \
    mv $$($(1)_download_dir)/$(4).temp $$($(1)_source_dir)/$(4) && \
    rm -rf $$($(1)_download_dir) )
endef

define fetch_file
    ( test -f $$($(1)_source_dir)/$(4) || \
    ( $(call fetch_file_inner,$(1),$(FALLBACK_DOWNLOAD_PATH),$(4),$(4),$(5)) || \
      $(call fetch_file_inner,$(1),$(2),$(3),$(4),$(5))))
endef

define int_get_build_recipe_hash
$(eval $(1)_all_file_checksums:=$(shell cd $(BASEDIR) && $(build_SHA256SUM) $(subst $(BASEDIR)/,,$(meta_depends)) packages/$(1).mk $(addprefix patches/$(1)/,$($(1)_patches)) 2>/dev/null | cut -d" " -f1))
$(eval $(1)_recipe_hash:=$(shell echo -n "$($(1)_all_file_checksums)" | $(build_SHA256SUM) | cut -d" " -f1))
endef

define int_get_build_id
$(eval $(1)_dependencies += $($(1)_$(host_arch)_$(host_os)_dependencies) $($(1)_$(host_os)_dependencies))
$(eval $(1)_all_dependencies:=$(call int_get_all_dependencies,$(1),$($($(1)_type)_native_toolchain) $($(1)_dependencies)))
$(foreach dep,$($(1)_all_dependencies),$(eval $(1)_build_id_deps+=$(dep)-$($(dep)_version)-$($(dep)_recipe_hash)))
$(eval $(1)_build_id_long:=$(1)-$($(1)_version)-$($(1)_recipe_hash)-$(release_type) $($(1)_build_id_deps) $($($(1)_type)_id_string))
$(eval $(1)_build_id:=$(shell echo -n "$($(1)_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH)))
$(eval $(1)_build_id_long_legacy:=$(1)-$($(1)_version)-$($(1)_recipe_hash)-$(release_type) $($(1)_build_id_deps) $($($(1)_type)_id_string_legacy))
$(eval $(1)_build_id_legacy:=$(shell echo -n "$($(1)_build_id_long_legacy)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH)))
final_build_id_long+=$($(package)_build_id_long)

#compute package-specific paths
$(1)_build_subdir?=.
$(1)_download_file?=$($(1)_file_name)
$(1)_source_dir:=$(SOURCES_PATH)
$(1)_source:=$$($(1)_source_dir)/$($(1)_file_name)
$(1)_staging_dir=$(base_staging_dir)/$(host)/$(1)/$($(1)_version)-$($(1)_build_id)
$(1)_staging_prefix_dir:=$$($(1)_staging_dir)$($($(1)_type)_prefix)
$(1)_extract_dir:=$(base_build_dir)/$(host)/$(1)/$($(1)_version)-$($(1)_build_id)
$(1)_download_dir:=$(base_download_dir)/$(1)-$($(1)_version)
$(1)_build_dir:=$$($(1)_extract_dir)/$$($(1)_build_subdir)
$(1)_cached_checksum:=$(BASE_CACHE)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz.hash
$(1)_cached_buildinfo:=$(BASE_CACHE)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz.txt
$(1)_patch_dir:=$(base_build_dir)/$(host)/$(1)/$($(1)_version)-$($(1)_build_id)/.patches-$($(1)_build_id)
$(1)_prefixbin:=$($($(1)_type)_prefix)/bin/
$(1)_cached:=$(BASE_CACHE)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz
$(1)_all_sources=$($(1)_file_name) $($(1)_extra_sources)
$(1)_prebuilt_url:=$(PREBUILT_BASE_URL)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz
$(1)_prebuilt_checksum_url:=$(PREBUILT_BASE_URL)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz.hash
$(1)_prebuilt_buildinfo_url:=$(PREBUILT_BASE_URL)/$(host)/$(1)/$(1)-$($(1)_version)-$($(1)_build_id).tar.gz.txt

#stamps
$(1)_fetched=$(SOURCES_PATH)/download-stamps/.stamp_fetched-$(1)-$($(1)_file_name).hash
$(1)_extracted=$$($(1)_extract_dir)/.stamp_extracted
$(1)_preprocessed=$$($(1)_extract_dir)/.stamp_preprocessed
$(1)_cleaned=$$($(1)_extract_dir)/.stamp_cleaned
$(1)_built=$$($(1)_build_dir)/.stamp_built
$(1)_configured=$$($(1)_build_dir)/.stamp_configured
$(1)_staged=$$($(1)_staging_dir)/.stamp_staged
$(1)_postprocessed=$$($(1)_staging_prefix_dir)/.stamp_postprocessed
$(1)_prebuilt_downloaded:=$(BASE_CACHE)/$(host)/$(1)/.stamp_prebuilt_downloaded-$($(1)_build_id)
$(1)_cached_or_prebuilt:=$(BASE_CACHE)/$(host)/$(1)/.stamp_cached_or_prebuilt-$($(1)_build_id)
$(1)_download_path_fixed=$(subst :,\:,$$($(1)_download_path))


#default commands
$(1)_fetch_cmds ?= $(call fetch_file,$(1),$(subst \:,:,$$($(1)_download_path_fixed)),$$($(1)_download_file),$($(1)_file_name),$($(1)_sha256_hash))
$(1)_extract_cmds ?= mkdir -p $$($(1)_extract_dir) && echo "$$($(1)_sha256_hash)  $$($(1)_source)" > $$($(1)_extract_dir)/.$$($(1)_file_name).hash &&  $(build_SHA256SUM) -c $$($(1)_extract_dir)/.$$($(1)_file_name).hash && tar --strip-components=1 -xf $$($(1)_source)
$(1)_preprocess_cmds ?=
$(1)_build_cmds ?=
$(1)_config_cmds ?=
$(1)_stage_cmds ?=
$(1)_set_vars ?=


all_sources+=$$($(1)_fetched)
endef
#$(foreach dep_target,$($(1)_all_dependencies),$(eval $(1)_dependency_targets=$($(dep_target)_cached)))


define int_config_attach_build_config
$(eval $(call $(1)_set_vars,$(1)))
$(1)_cflags+=$($(1)_cflags_$(release_type))
$(1)_cflags+=$($(1)_cflags_$(host_arch)) $($(1)_cflags_$(host_arch)_$(release_type))
$(1)_cflags+=$($(1)_cflags_$(host_os)) $($(1)_cflags_$(host_os)_$(release_type))
$(1)_cflags+=$($(1)_cflags_$(host_arch)_$(host_os)) $($(1)_cflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_cxxflags+=$($(1)_cxxflags_$(release_type))
$(1)_cxxflags+=$($(1)_cxxflags_$(host_arch)) $($(1)_cxxflags_$(host_arch)_$(release_type))
$(1)_cxxflags+=$($(1)_cxxflags_$(host_os)) $($(1)_cxxflags_$(host_os)_$(release_type))
$(1)_cxxflags+=$($(1)_cxxflags_$(host_arch)_$(host_os)) $($(1)_cxxflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_arflags+=$($(1)_arflags_$(release_type))
$(1)_arflags+=$($(1)_arflags_$(host_arch)) $($(1)_arflags_$(host_arch)_$(release_type))
$(1)_arflags+=$($(1)_arflags_$(host_os)) $($(1)_arflags_$(host_os)_$(release_type))
$(1)_arflags+=$($(1)_arflags_$(host_arch)_$(host_os)) $($(1)_arflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_cppflags+=$($(1)_cppflags_$(release_type))
$(1)_cppflags+=$($(1)_cppflags_$(host_arch)) $($(1)_cppflags_$(host_arch)_$(release_type))
$(1)_cppflags+=$($(1)_cppflags_$(host_os)) $($(1)_cppflags_$(host_os)_$(release_type))
$(1)_cppflags+=$($(1)_cppflags_$(host_arch)_$(host_os)) $($(1)_cppflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_ldflags+=$($(1)_ldflags_$(release_type))
$(1)_ldflags+=$($(1)_ldflags_$(host_arch)) $($(1)_ldflags_$(host_arch)_$(release_type))
$(1)_ldflags+=$($(1)_ldflags_$(host_os)) $($(1)_ldflags_$(host_os)_$(release_type))
$(1)_ldflags+=$($(1)_ldflags_$(host_arch)_$(host_os)) $($(1)_ldflags_$(host_arch)_$(host_os)_$(release_type))

$(1)_build_opts+=$$($(1)_build_opts_$(release_type))
$(1)_build_opts+=$$($(1)_build_opts_$(host_arch)) $$($(1)_build_opts_$(host_arch)_$(release_type))
$(1)_build_opts+=$$($(1)_build_opts_$(host_os)) $$($(1)_build_opts_$(host_os)_$(release_type))
$(1)_build_opts+=$$($(1)_build_opts_$(host_arch)_$(host_os)) $$($(1)_build_opts_$(host_arch)_$(host_os)_$(release_type))

$(1)_config_opts+=$$($(1)_config_opts_$(release_type))
$(1)_config_opts+=$$($(1)_config_opts_$(host_arch)) $$($(1)_config_opts_$(host_arch)_$(release_type))
$(1)_config_opts+=$$($(1)_config_opts_$(host_os)) $$($(1)_config_opts_$(host_os)_$(release_type))
$(1)_config_opts+=$$($(1)_config_opts_$(host_arch)_$(host_os)) $$($(1)_config_opts_$(host_arch)_$(host_os)_$(release_type))

$(1)_config_env+=$$($(1)_config_env_$(release_type))
$(1)_config_env+=$($(1)_config_env_$(host_arch)) $($(1)_config_env_$(host_arch)_$(release_type))
$(1)_config_env+=$($(1)_config_env_$(host_os)) $($(1)_config_env_$(host_os)_$(release_type))
$(1)_config_env+=$($(1)_config_env_$(host_arch)_$(host_os)) $($(1)_config_env_$(host_arch)_$(host_os)_$(release_type))

$(1)_build_env+=$$($(1)_build_env_$(release_type))
$(1)_build_env+=$($(1)_build_env_$(host_arch)) $($(1)_build_env_$(host_arch)_$(release_type))
$(1)_build_env+=$($(1)_build_env_$(host_os)) $($(1)_build_env_$(host_os)_$(release_type))
$(1)_build_env+=$($(1)_build_env_$(host_arch)_$(host_os)) $($(1)_build_env_$(host_arch)_$(host_os)_$(release_type))

ifneq ($$($(1)_ar_$(host_arch)),)
$(1)_ar=$$($(1)_ar_$(host_arch))
endif
ifneq ($$($(1)_ar_$(host_os)),)
$(1)_ar=$$($(1)_ar_$(host_os))
endif
ifneq ($$($(1)_ar_$(host_arch)_$(host_os)),)
$(1)_ar=$$($(1)_ar_$(host_arch)_$(host_os))
endif

$(1)_config_env+=PKG_CONFIG_LIBDIR=$($($(1)_type)_prefix)/lib/pkgconfig
$(1)_config_env+=PKG_CONFIG_PATH=$($($(1)_type)_prefix)/share/pkgconfig
$(1)_config_env+=PATH="$(build_prefix)/bin:$(PATH)"
$(1)_build_env+=PATH="$(build_prefix)/bin:$(PATH)"
$(1)_stage_env+=PATH="$(build_prefix)/bin:$(PATH)"
$(1)_autoconf_args=--prefix=$($($(1)_type)_prefix) $$($(1)_config_opts) CC="$$($(1)_cc)" CXX="$$($(1)_cxx)" AR="$$($(1)_ar)"
$(1)_autoconf=./configure --host=$($($(1)_type)_host) --prefix=$($($(1)_type)_prefix) $$($(1)_config_opts) CC="$$($(1)_cc)" CXX="$$($(1)_cxx)" AR="$$($(1)_ar)"

ifeq ($(filter $(1),libusb unbound),)
$(1)_autoconf_args += --disable-dependency-tracking
$(1)_autoconf += --disable-dependency-tracking
endif
ifneq ($($(1)_nm),)
$(1)_autoconf_args += NM="$$($(1)_nm)"
$(1)_autoconf += NM="$$($(1)_nm)"
endif
ifneq ($($(1)_ranlib),)
$(1)_autoconf_args += RANLIB="$$($(1)_ranlib)"
$(1)_autoconf += RANLIB="$$($(1)_ranlib)"
endif
ifneq ($($(1)_ar),)
$(1)_autoconf_args += AR="$$($(1)_ar)"
$(1)_autoconf += AR="$$($(1)_ar)"
endif
ifneq ($($(1)_arflags),)
$(1)_autoconf_args += ARFLAGS="$$($(1)_arflags)"
$(1)_autoconf += ARFLAGS="$$($(1)_arflags)"
endif
ifneq ($($(1)_cflags),)
$(1)_autoconf_args += CFLAGS="$$($(1)_cflags)"
$(1)_autoconf += CFLAGS="$$($(1)_cflags)"
endif
ifneq ($($(1)_cxxflags),)
$(1)_autoconf_args += CXXFLAGS="$$($(1)_cxxflags)"
$(1)_autoconf += CXXFLAGS="$$($(1)_cxxflags)"
endif
ifneq ($($(1)_cppflags),)
$(1)_autoconf_args += CPPFLAGS="$$($(1)_cppflags)"
$(1)_autoconf += CPPFLAGS="$$($(1)_cppflags)"
endif
ifneq ($($(1)_ldflags),)
$(1)_autoconf_args += LDFLAGS="$$($(1)_ldflags)"
$(1)_autoconf += LDFLAGS="$$($(1)_ldflags)"
endif
endef

COMPRESS_CMD := $(shell if command -v pigz >/dev/null 2>&1; then echo "pigz"; else echo "gzip"; fi)

define int_add_cmds
$($(1)_fetched):
	$(AT)echo "=== Fetching $(1) v$($(1)_version) ==="
	$(AT)echo "  Source directory: $($(1)_source_dir)"
	$(AT)echo "  Download file: $($(1)_download_file)"
	$(AT)mkdir -p $$(@D) $(SOURCES_PATH)
	$(AT)rm -f $$@
	$(AT)touch $$@
	$(AT)cd $$(@D); $(call $(1)_fetch_cmds,$(1))
	$(AT)cd $($(1)_source_dir); $(foreach source,$($(1)_all_sources),$(build_SHA256SUM) $(source) >> $$(@);)
	$(AT)echo "  Fetch completed: $$@"
	$(AT)touch $$@
$($(1)_extracted): | $($(1)_fetched)
	$(AT)echo "=== Extracting $(1) v$($(1)_version) ==="
	$(AT)echo "  Build ID: $($(1)_build_id)"
	$(AT)echo "  Extract directory: $($(1)_extract_dir)"
	$(AT)mkdir -p $$(@D)
	$(AT)cd $$(@D); $(call $(1)_extract_cmds,$(1))
	$(AT)echo "  Extract completed: $$@"
	$(AT)touch $$@
$($(1)_preprocessed): | $($(1)_dependencies) $($(1)_extracted)
	$(AT)echo "=== Preprocessing $(1) v$($(1)_version) ==="
	$(AT)echo "  Dependencies: $($(1)_dependencies)"
	$(AT)echo "  Patch directory: $($(1)_patch_dir)"
	$(AT)echo "  Patches: $($(1)_patches)"
	$(AT)mkdir -p $$(@D) $($(1)_patch_dir)
	$(AT)$(foreach patch,$($(1)_patches),cd $(PATCHES_PATH)/$(1); cp $(patch) $($(1)_patch_dir) ;)
	$(AT)cd $$(@D); $(call $(1)_preprocess_cmds, $(1))
	$(AT)echo "  Preprocessing completed: $$@"
	$(AT)touch $$@
$($(1)_configured): | $($(1)_preprocessed)
	$(AT)echo "=== Configuring $(1) v$($(1)_version) ==="
	$(AT)echo "  Build directory: $($(1)_build_dir)"
	$(AT)echo "  Host prefix: $(host_prefix)"
	$(AT)echo "  All dependencies: $($(1)_all_dependencies)"
	$(AT)rm -rf $(host_prefix); mkdir -p $(host_prefix)/lib; cd $(host_prefix); $(foreach package,$($(1)_all_dependencies), tar xf $($(package)_cached); )
	$(AT)mkdir -p $$(@D)
	$(AT)+cd $$(@D); $($(1)_config_env) $(call $(1)_config_cmds, $(1))
	$(AT)echo "  Configuration completed: $$@"
	$(AT)touch $$@
$($(1)_built): | $($(1)_configured)
	$(AT)echo "=== Building $(1) v$($(1)_version) ==="
	$(AT)echo "  Build directory: $($(1)_build_dir)"
	$(AT)echo "  Build environment: $($(1)_build_env)"
	$(AT)mkdir -p $$(@D)
	$(AT)+cd $$(@D); $($(1)_build_env) $(call $(1)_build_cmds, $(1))
	$(AT)echo "  Build completed: $$@"
	$(AT)touch $$@
$($(1)_staged): | $($(1)_built)
	$(AT)echo "=== Staging $(1) v$($(1)_version) ==="
	$(AT)echo "  Staging directory: $($(1)_staging_dir)"
	$(AT)echo "  Staging prefix: $($(1)_staging_prefix_dir)"
	$(AT)mkdir -p $($(1)_staging_dir)/$(host_prefix)
	$(AT)cd $($(1)_build_dir); $($(1)_stage_env) $(call $(1)_stage_cmds, $(1))
	$(AT)echo "  Removing extract directory: $($(1)_extract_dir)"
	$(AT)rm -rf $($(1)_extract_dir)
	$(AT)echo "  Staging completed: $$@"
	$(AT)touch $$@
$($(1)_postprocessed): | $($(1)_staged)
	$(AT)echo "=== Postprocessing $(1) v$($(1)_version) ==="
	$(AT)echo "  Postprocessing directory: $($(1)_staging_prefix_dir)"
	$(AT)cd $($(1)_staging_prefix_dir); $(call $(1)_postprocess_cmds)
	$(AT)echo "  Postprocessing completed: $$@"
	$(AT)touch $$@
$($(1)_prebuilt_downloaded): | $($(1)_dependencies)
	$(AT)echo "=== Attempting to download prebuilt $(1) v$($(1)_version) ==="
	$(AT)echo "  Build ID: $($(1)_build_id)"
	$(AT)echo "  Download URL: $($(1)_prebuilt_url)"
	$(AT)mkdir -p $$(@D)
	$(AT)mkdir -p $(dir $($(1)_cached))
	$(AT)( \
		echo "  Downloading $(1) prebuilt files..." && \
		$(build_DOWNLOAD) "$($(1)_cached).tmp" "$($(1)_prebuilt_url)" && \
		$(build_DOWNLOAD) "$($(1)_cached_checksum).tmp" "$($(1)_prebuilt_checksum_url)" && \
		$(build_DOWNLOAD) "$($(1)_cached_buildinfo).tmp" "$($(1)_prebuilt_buildinfo_url)" && \
		echo "  Verifying checksum..." && \
		cd $(dir $($(1)_cached)) && \
		sed 's/$(notdir $($(1)_cached))/$(notdir $($(1)_cached)).tmp/' "$($(1)_cached_checksum).tmp" > "$($(1)_cached_checksum).tmp.verify" && \
		$(build_SHA256SUM) -c "$($(1)_cached_checksum).tmp.verify" && \
		rm -f "$($(1)_cached_checksum).tmp.verify" && \
		echo "  Moving files to final location..." && \
		mv "$($(1)_cached).tmp" "$($(1)_cached)" && \
		mv "$($(1)_cached_checksum).tmp" "$($(1)_cached_checksum)" && \
		mv "$($(1)_cached_buildinfo).tmp" "$($(1)_cached_buildinfo)" && \
		echo "  Prebuilt download completed: $$@" && \
		touch $$@ \
	) || ( \
		echo "  Download failed for $(1)" && \
		rm -f "$($(1)_cached).tmp" "$($(1)_cached_checksum).tmp" "$($(1)_cached_buildinfo).tmp" && \
		if [ "$(DEPENDS_UNTRUSTED_FAST_BUILDS)" = "forced" ]; then \
			echo "  Error: DEPENDS_UNTRUSTED_FAST_BUILDS=forced but prebuilt download failed" && \
			exit 1; \
		else \
			echo "  Falling back to building from source..." && \
			exit 1; \
		fi \
	)
$($(1)_cached): | $($(1)_dependencies) $($(1)_postprocessed)
	$(AT)echo "=== Caching $(1) v$($(1)_version) ==="
	$(AT)echo "  Build ID: $($(1)_build_id)"
	$(AT)echo "  Cache file: $$@"
	$(AT)echo "  Compression: $(COMPRESS_CMD)"
	$(AT)cd $$($(1)_staging_dir)/$(host_prefix); find . | sort | tar --no-recursion --use-compress-program='$(COMPRESS_CMD)' -cf $$($(1)_staging_dir)/$$(@F) -T -
	$(AT)mkdir -p $$(@D)
	$(AT)mv $$($(1)_staging_dir)/$$(@F) $$(@)
	$(AT)echo "  Removing staging directory: $($(1)_staging_dir)"
	$(AT)rm -rf $($(1)_staging_dir)
	$(AT)echo "  Caching completed: $$@"
$($(1)_cached_checksum): $($(1)_cached)
	$(AT)echo "=== Generating checksum for $(1) v$($(1)_version) ==="
	$(AT)echo "  Checksum file: $$@"
	$(AT)cd $$(@D); $(build_SHA256SUM) $$(<F) > $$(@)
	$(AT)echo "  Checksum completed: $$@"
	$(AT)echo "=== Generating build info for $(1) v$($(1)_version) ==="
	$(AT)echo "  Build info file: $$($(1)_cached_buildinfo)"
	$(AT)echo "# Build Info for $(1) v$($(1)_version)" > $$($(1)_cached_buildinfo)
	$(AT)echo "# Generated on: $$(shell date)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Package: $(1)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Version: $($(1)_version)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Host: $(host)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Release Type: $(release_type)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Build ID (current): $($(1)_build_id)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Build ID (legacy): $($(1)_build_id_legacy)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Build ID String (current): $($(1)_build_id_long)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Build ID String (legacy): $($(1)_build_id_long_legacy)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Dependencies: $($(1)_dependencies)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "All Dependencies: $($(1)_all_dependencies)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Recipe Hash: $($(1)_recipe_hash)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Recipe Files: $($(1)_all_file_checksums)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Toolchain (current): $($($(1)_type)_id_string)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Toolchain (legacy): $($($(1)_type)_id_string_legacy)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Build Tools (current):" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  CC: $$(shell basename $($($(1)_type)_CC) 2>/dev/null || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  CXX: $$(shell basename $($($(1)_type)_CXX) 2>/dev/null || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  AR: $$(shell basename $($($(1)_type)_AR) 2>/dev/null || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  RANLIB: $$(shell basename $($($(1)_type)_RANLIB) 2>/dev/null || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  STRIP: $$(shell basename $($($(1)_type)_STRIP) 2>/dev/null || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Build Tools (legacy versions):" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  CC: $$(shell $($($(1)_type)_CC) --version 2>/dev/null | head -1 || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  CXX: $$(shell $($($(1)_type)_CXX) --version 2>/dev/null | head -1 || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  AR: $$(shell $($($(1)_type)_AR) --version 2>/dev/null | head -1 || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  RANLIB: $$(shell $($($(1)_type)_RANLIB) --version 2>/dev/null | head -1 || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  STRIP: $$(shell $($($(1)_type)_STRIP) --version 2>/dev/null | head -1 || echo "unknown")" >> $$($(1)_cached_buildinfo)
	$(AT)echo "" >> $$($(1)_cached_buildinfo)
	$(AT)echo "Salt Values:" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  BUILD_ID_SALT: $(BUILD_ID_SALT)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  HOST_ID_SALT: $(HOST_ID_SALT)" >> $$($(1)_cached_buildinfo)
	$(AT)echo "  Build info completed: $$($(1)_cached_buildinfo)"

$($(1)_cached_or_prebuilt): 
	$(AT)mkdir -p $$(@D)
	$(AT)if [ "$(DEPENDS_UNTRUSTED_FAST_BUILDS)" = "yes" ]; then \
		echo "=== Trying prebuilt download for $(1) v$($(1)_version) ===" && \
		($(MAKE) -f $(BASEDIR)/Makefile $($(1)_prebuilt_downloaded) && touch $$@) || \
		(echo "  Prebuilt download failed, falling back to building from source..." && \
		$(MAKE) -f $(BASEDIR)/Makefile $($(1)_cached_checksum) && touch $$@); \
	elif [ "$(DEPENDS_UNTRUSTED_FAST_BUILDS)" = "forced" ]; then \
		echo "=== Forced prebuilt download for $(1) v$($(1)_version) ===" && \
		$(MAKE) -f $(BASEDIR)/Makefile $($(1)_prebuilt_downloaded) && touch $$@; \
	else \
		echo "=== Building from source for $(1) v$($(1)_version) ===" && \
		$(MAKE) -f $(BASEDIR)/Makefile $($(1)_cached_checksum) && touch $$@; \
	fi

.PHONY: $(1)
$(1): | $($(1)_cached_or_prebuilt)
.SECONDARY: $($(1)_cached) $($(1)_postprocessed) $($(1)_staged) $($(1)_built) $($(1)_configured) $($(1)_preprocessed) $($(1)_extracted) $($(1)_fetched) $($(1)_cached_buildinfo) $($(1)_prebuilt_downloaded) $($(1)_cached_or_prebuilt)

endef

stages = fetched extracted preprocessed configured built staged postprocessed cached cached_checksum prebuilt_downloaded

define ext_add_stages
$(foreach stage,$(stages),
          $(1)_$(stage): $($(1)_$(stage))
          .PHONY: $(1)_$(stage))
endef

# These functions create the build targets for each package. They must be
# broken down into small steps so that each part is done for all packages
# before moving on to the next step. Otherwise, a package's info
# (build-id for example) would only be available to another package if it
# happened to be computed already.

#set the type for host/build packages.
$(foreach native_package,$(native_packages),$(eval $(native_package)_type=build))
$(foreach package,$(packages),$(eval $(package)_type=$(host_arch)_$(host_os)))

#set overridable defaults
$(foreach package,$(all_packages),$(eval $(call int_vars,$(package))))

#include package files
$(foreach package,$(all_packages),$(eval include packages/$(package).mk))

#compute a hash of all files that comprise this package's build recipe
$(foreach package,$(all_packages),$(eval $(call int_get_build_recipe_hash,$(package))))

#generate a unique id for this package, incorporating its dependencies as well
$(foreach package,$(all_packages),$(eval $(call int_get_build_id,$(package))))

#compute final vars after reading package vars
$(foreach package,$(all_packages),$(eval $(call int_config_attach_build_config,$(package))))

#create build targets
$(foreach package,$(all_packages),$(eval $(call int_add_cmds,$(package))))

#special exception: if a toolchain package exists, all non-native packages depend on it
$(foreach package,$(packages),$(eval $($(package)_unpacked): |$($($(host_arch)_$(host_os)_native_toolchain)_cached) ))
