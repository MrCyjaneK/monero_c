.NOTPARALLEL:

HOST ?=

PACKAGES = native/cmake,native/python@3.14,native/git,native/_,native/make,native/cmake-toolchain,icu4c,boost@1_90_0,zeromq,unbound,sodium,openssl,libiconv,zlib
SIMPLYBS_HASH = f6eb673d26451799dfc9082761ae5c635b8878a0

all: simplybs $(if $(HOST),sbs-build-$(HOST),)
	@if [ -z "$(HOST)" ]; then \
		echo "ERROR: HOST is not set"; \
		exit 1; \
	fi

.PHONY: simplybs sbs-build-% sbs-cleanup

sbs-cleanup:
	@rm -rf simplybs/_
	@rm -rf simplybs/_native
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
	# cd simplybs && env SIMPLYBS_ENV_NATIVE_DIR=$(PWD)/_native SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -cleanup
	cd simplybs && env SIMPLYBS_NATIVE_ENV_DIR=$(PWD)/_native SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -host $* -package $(PACKAGES) -build
	cd simplybs && rm -rf $(PWD)/$*
	cd simplybs && env SIMPLYBS_NATIVE_ENV_DIR=$(PWD)/_native SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -host $* -package $(PACKAGES) -extract
	env HOST=$* ./gen_toolchain.cmake.sh $*/share/toolchain.cmake
