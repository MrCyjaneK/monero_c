.NOTPARALLEL:

HOST ?=

PACKAGES = native/cmake,native/python@3.14,native/git,native/_,native/make,native/cmake-toolchain,boost,zeromq,unbound,sodium,openssl,zlib
SIMPLYBS_HASH = 70ca89de2de7a0683b43b8a2cf7d95f925edf85c

all: simplybs $(if $(HOST),sbs-build-$(HOST),)
	@if [ -z "$(HOST)" ]; then \
		echo "ERROR: HOST is not set"; \
		exit 1; \
	fi

.PHONY: simplybs sbs-build-%

simplybs:
	git clone https://github.com/mrcyjanek/simplybs || true
	cd simplybs && git fetch -a
	cd simplybs && git checkout $(SIMPLYBS_HASH) --force
	cd simplybs && git reset --hard

sbs-build-%:
	# cd simplybs && env SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -cleanup
	cd simplybs && env SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -host $* -package $(PACKAGES) -build
	cd simplybs && rm -rf $(PWD)/$*
	cd simplybs && env SIMPLYBS_ENV_DIR=$(PWD)/$* go run . -host $* -package $(PACKAGES) -extract
	env HOST=$* ./gen_toolchain.cmake.sh $*/share/toolchain.cmake
