package=curl

$(package)_version=8.17.0
$(package)_download_path=https://curl.se/download
$(package)_file_name=curl-$($(package)_version).tar.gz
$(package)_sha256_hash=e8e74cdeefe5fb78b3ae6e90cd542babf788fa9480029cfcee6fd9ced42b7910

$(package)_dependencies=openssl
$(package)_build_subdir=

define $(package)_set_vars
 $(package)_config_opts=--with-ssl --enable-ipv6 --disable-shared --disable-dynamic-loading --enable-static --without-libpsl --disable-ares --disable-ftp --disable-ldap --disable-laps --disable-rtsp --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smb --disable-smtp --disable-gopher --disable-manual --disable-libcurl-option --enable-http --disable-threaded-resolver --disable-pthreads --disable-verbose --disable-sspi --enable-crypto-auth --disable-ntlm-wb --disable-tls-srp --disable-unix-sockets --disable-cookies --enable-http-auth --enable-doh --disable-mime --enable-dateparse --disable-netrc --with-libidn2 --disable-progress-meter --without-brotli --without-librtmp --disable-versioned-symbols --enable-hidden-symbols --without-zsh-functions-dir --without-fish-functions-dir --without-zstd --without-nghttp2 --without-nghttp3 --without-ngtcp2 --without-quiche
 $(package)_cflags_release=-O3

 ifneq ($(findstring mingw,$(HOST)),)
    $(package)_cflags_release += -DCURL_STATICLIB
 endif
endef

define $(package)_preprocess_cmds
 for p in $($(package)_patches); do \
  patch -p1 < "$($(package)_patch_dir)/$$p"; \
 done
endef

define $(package)_config_cmds
 $($(package)_autoconf)
endef

define $(package)_build_cmds
 $(MAKE)
endef

define $(package)_stage_cmds
 $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef
