package=native_python3
$(package)_version=3.11.13
$(package)_download_path=https://www.python.org/ftp/python/3.11.13
$(package)_file_name=Python-3.11.13.tgz
$(package)_sha256_hash=0f1a22f4dfd34595a29cf69ee7ea73b9eff8b1cc89d7ab29b3ab0ec04179dad8


define $(package)_config_cmds
	./configure --enable-optimizations --prefix=$($(package)_extract_dir)/pybuild
endef

define $(package)_build_cmds
	make -j $(NUM_CORES)
endef

define $(package)_stage_cmds
	make install && \
	mkdir -p $($(package)_staging_prefix_dir)/python && \
	mkdir -p $($(package)_staging_prefix_dir)/bin && \
	cp -r pybuild/* $($(package)_staging_prefix_dir)/python && \
	ln -s ../python/bin/python3 $($(package)_staging_prefix_dir)/bin/python && \
	ln -s ../python/bin/python3 $($(package)_staging_prefix_dir)/bin/python3
endef