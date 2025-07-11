package=native_nproc
$(package)_version=0.1
$(package)_download_path=https://github.com/MrCyjaneK/nproc/archive/
$(package)_file_name=30acb0de0e18a2b16c277e6db840e5ce389d962d.tar.gz
$(package)_sha256_hash=353715a0799c3d965762b1207646b99503deb57603af779547b06c944ace4bad


define $(package)_stage_cmds
	mkdir -p $($(package)_staging_prefix_dir)/bin && \
	cp nproc.sh $($(package)_staging_prefix_dir)/bin/nproc && \
	chmod +x $($(package)_staging_prefix_dir)/bin/nproc
endef