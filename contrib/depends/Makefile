.NOTPARALLEL:

HOST ?=

PACKAGES = native/cmake,native/python@3.14,native/git,native/_,native/make,boost,zeromq,zlib,unbound,sodium,openssl
SIMPLYBS_HASH = 9adf984c68dd37da38d4e9aa905610dda54be7a4

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
