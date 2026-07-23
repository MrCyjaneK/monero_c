.NOTPARALLEL:

HOST ?=

BOOST_VERSION ?= 1_90_0
PACKAGES = native/_/_,native/libxml2,native/curl,native/libpsl,native/pkgconf,native/rust-toolchain,rust-std,native/protobuf,native/cmake,native/sed,native/python@3.14,native/git,native/_,native/make,native/cmake-toolchain,boost@$(BOOST_VERSION),zeromq,unbound,sodium,openssl,libiconv,zlib,protobuf
SIMPLYBS_HASH = cf71888b95038e65f324cbf0d786b08714f7a2ca

all: simplybs $(if $(HOST),sbs-build-$(HOST),)
	@if [ -z "$(HOST)" ]; then \
		echo "ERROR: HOST is not set"; \
		exit 1; \
	fi

.PHONY: simplybs sbs-build-% sbs-cleanup

sbs-cleanup:
	@rm -rf simplybs/_
	@rm -rf simplybs/_native
	@rm -rf _native
	@rm -rf *-*-*
	@rm -rf simplybs/.buildlib/*_*/work
	@rm -rf simplybs/.buildlib/*_*/staging
	@rm -rf simplybs/.buildlib/source

simplybs:
	git clone https://github.com/mrcyjanek/simplybs || true
	cd simplybs && git fetch -a
	cd simplybs && git checkout $(SIMPLYBS_HASH) --force
	cd simplybs && git reset --hard

sbs-build-%:
	cd simplybs && env SIMPLYBS_NATIVE_ENV_DIR=$(PWD)/_native SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -host $* -package $(PACKAGES) -build
	cd simplybs && rm -rf $(PWD)/$*
	cd simplybs && rm -rf $(PWD)/_native
	cd simplybs && env SIMPLYBS_NATIVE_ENV_DIR=$(PWD)/_native SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -host $* -package $(PACKAGES) -extract
	echo ok
