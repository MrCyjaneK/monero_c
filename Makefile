include .env
export $(shell sed 's/=.*//' .env)

PREFIX := ${PWD}/prefix

.PHONY: download
download:
	rm -rf monero
	# Monero
	(git clone ${MONERO_GIT_SOURCE} --depth=1 --branch ${MONERO_TAG} monero && cd monero && git submodule init && git submodule update)
	# Boost
	curl -L -o boost_${BOOST_VERSION}.tar.bz2 https://archives.boost.io/release/${BOOST_VERSION_DOT}/source/boost_${BOOST_VERSION}.tar.bz2
	echo "${BOOST_HASH}  boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c
	tar -xf boost_${BOOST_VERSION}.tar.bz2
	rm -f boost_${BOOST_VERSION}.tar.bz2
	# libiconv
	curl -O http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_VERSION}.tar.gz
	echo "${ICONV_HASH}  libiconv-${ICONV_VERSION}.tar.gz" | sha256sum -c
	tar -xzf libiconv-${ICONV_VERSION}.tar.gz
	rm -f libiconv-${ICONV_VERSION}.tar.gz
	# zlib
	curl -O https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
	echo "${ZLIB_HASH}  zlib-${ZLIB_VERSION}.tar.gz" | sha256sum -c
	tar -xzf zlib-${ZLIB_VERSION}.tar.gz
	rm zlib-${ZLIB_VERSION}.tar.gz
	mv zlib-${ZLIB_VERSION} zlib
	openssl
	curl -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
	echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c
	tar -xzf openssl-${OPENSSL_VERSION}.tar.gz
	rm openssl-${OPENSSL_VERSION}.tar.gz
	# libzmq
	git clone https://github.com/zeromq/libzmq.git -b ${ZMQ_VERSION} --depth=1
	(cd libzmq && test `git rev-parse HEAD` = ${ZMQ_HASH}) || exit 1
	# libsodium
	git clone https://github.com/jedisct1/libsodium.git -b ${SODIUM_VERSION} --depth=1
	(cd libsodium && test `git rev-parse HEAD` = ${SODIUM_HASH}) || exit 1
	# libexpat
	git clone https://github.com/libexpat/libexpat.git -b ${LIBEXPAT_VERSION} --depth=1
	(cd libexpat && test `git rev-parse HEAD` = ${LIBEXPAT_HASH}) || exit 1
	# unbound
	git clone https://github.com/NLnetLabs/unbound.git -b ${LIBUNBOUND_VERSION} --depth=1
	(cd unbound && test `git rev-parse HEAD` = ${LIBUNBOUND_HASH}) || exit 1
	# polyseed
	git clone https://github.com/tevador/polyseed.git
	(cd polyseed && git reset --hard ${POLYSEED_HASH}) || exit 1
	# utf8proc
	git clone https://github.com/JuliaStrings/utf8proc -b v2.8.0 --depth=1
	(cd utf8proc && git reset --hard ${UTF8PROC_HASH})


.PHONY: host_depends
host_depends: libiconv_host boost_host zlib_host openssl_host libzmq_host libsodium_host libexpat_host host_copy_libs unbound_host polyseed_host utf8proc_host

.PHONY: host_copy_libs	
host_copy_libs:
	-cp -a ${PREFIX}/lib64/* ${PREFIX}/lib # fix linking issue (openssl?)

.PHONY: libiconv_host
libiconv_host:
	cd libiconv-${ICONV_VERSION} && ./configure --prefix=${PREFIX} --disable-rpath
	cd libiconv-${ICONV_VERSION} && make -j${NPROC}
	cd libiconv-${ICONV_VERSION} && make install

.PHONY: boost_host
boost_host:
	cd boost_${BOOST_VERSION} && ./bootstrap.sh --prefix=${PREFIX}
	cd boost_${BOOST_VERSION} && echo '\n#undef PTHREAD_STACK_MIN\n#define PTHREAD_STACK_MIN 16384\n' | cat - ./boost/thread/pthread/thread_data.hpp > temp && mv temp ./boost/thread/pthread/thread_data.hpp
	cd boost_${BOOST_VERSION} && ./b2 cxxflags=-fPIC cflags=-fPIC --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale --build-dir=linux --stagedir=linux toolset=gcc threading=multi threadapi=pthread -sICONV_PATH=${PREFIX} install -j${NPROC}

.PHONY: zlib_host
zlib_host:
	cd zlib && ./configure --static
	cd zlib && make -j${NPROC}

.PHONY: openssl_host
openssl_host:
	cd openssl-${OPENSSL_VERSION} && ./Configure -static no-shared no-tests --with-zlib-include=${PREFIX}/zlib/include --with-zlib-lib=${PREFIX}/zlib/lib --prefix=${PREFIX} --openssldir=${PREFIX} -fPIC
	cd openssl-${OPENSSL_VERSION} && make -j${NPROC}
	cd openssl-${OPENSSL_VERSION} && make install_sw

.PHONY: libzmq_host
libzmq_host:
	rm -rf libzmq/build || true
	cd libzmq && ./autogen.sh
	cd libzmq && mkdir build
	cd libzmq/build && cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBUILD_SHARED=OFF -DBUILD_TESTS=OFF ..
	cd libzmq/build && make -j${NPROC}
	cd libzmq/build && make install

.PHONY: libsodium_host
libsodium_host:
	cd libsodium && ./autogen.sh 
	cd libsodium && ./configure --prefix=${PREFIX} --enable-static --disable-shared --with-pic
	cd libsodium && make -j${NPROC}
	cd libsodium && make install

.PHONY: libexpat_host
libexpat_host:
	cd libexpat/expat && ./buildconf.sh
	cd libexpat/expat && ./configure --prefix=${PREFIX} --enable-static --disable-shared
	cd libexpat/expat && make -j${NPROC}
	cd libexpat/expat && make install

.PHONY: unbound_host
unbound_host:
	cd unbound && ./configure -with-pic --prefix=${PREFIX} --enable-static --disable-shared --disable-flto --with-libexpat=${PREFIX} --with-ssl=${PREFIX}
	cd unbound && make -j${NPROC}
	cd unbound && make install

.PHONY: polyseed_host
polyseed_host:
	cd polyseed && rm -rf ./CMakeCache.txt ./CMakeFiles/
	cd polyseed && cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} .
	cd polyseed && make -j${NPROC}
	cd polyseed && make install

.PHONY: utf8proc_host
utf8proc_host:
	cd utf8proc && rm -rf build || true
	cd utf8proc && mkdir build
	cd utf8proc/build && rm -rf ../CMakeCache.txt ../CMakeFiles/ || true
	cd utf8proc/build && cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
	cd utf8proc/build && make -j${NPROC}
	cd utf8proc/build && make install

.PHONY: monero_linux_amd64
monero_linux_amd64:
	cd monero \
	&& rm -rf build/release \
	&& mkdir -p build/release \
	&& cd build/release \
	&& env CMAKE_INCLUDE_PATH="${PREFIX}/include" CMAKE_LIBRARY_PATH="${PREFIX}/lib" USE_SINGLE_BUILDDIR=1 cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="x86-64" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=release -D ANDROID=false -D BUILD_TAG="linux-x86_64" -D CMAKE_SYSTEM_NAME="Linux" ../..
	cd monero/build/release && make wallet_api -j${NPROC}


.PHONY: monero_linux_arm64
monero_linux_arm64:
	cd monero \
	&& rm -rf build/release \
	&& mkdir -p build/release \
	&& cd build/release \
	&& env CMAKE_INCLUDE_PATH="${PREFIX}/include" CMAKE_LIBRARY_PATH="${PREFIX}/lib" USE_SINGLE_BUILDDIR=1 cmake -D USE_DEVICE_TREZOR=OFF -D BUILD_GUI_DEPS=1 -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64="ON" -D CMAKE_BUILD_TYPE=release -D ANDROID=false -D BUILD_TAG="linux-armv8a" -D CMAKE_SYSTEM_NAME="Linux" ../..
	cd monero/build/release && make wallet_api -j${NPROC}

.PHONY: moneroc_linux_host64
moneroc_linux_host64:
	rm -rf libbridge/build || true
	mkdir -p libbridge/build
	cd libbridge/build && env CC=gcc CXX=g++ cmake -DANDROID_ABI=linux-x86_64 ..
	cd libbridge/build && make -j${NPROC}
