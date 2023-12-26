FLAVOUR = monero

all: arm64-v8a x86 x86_64 armeabi-v7a include/wallet2_api.h VERSION 

arm64-v8a: $(FLAVOUR) android64.Dockerfile
	-rm -rf arm64-v8a
	-docker container rm $(FLAVOUR)-android-arm64 -f
	docker build -f android64.Dockerfile -t $(FLAVOUR)-android-arm64 .
	docker create -it --name $(FLAVOUR)-android-arm64 $(FLAVOUR)-android-arm64 bash
	# docker cp $(FLAVOUR)-android-arm64:/opt/android/prefix/lib/. arm64-v8a/
	# docker cp $(FLAVOUR)-android-arm64:/src/build/release/lib/. arm64-v8a/$(FLAVOUR)
	mkdir arm64-v8a
	docker cp $(FLAVOUR)-android-arm64:/opt/android/libbridge/build/libmonerujo.so arm64-v8a/libmonerujo.so
	docker cp $(FLAVOUR)-android-arm64:/opt/android/toolchain/aarch64-linux-android/lib/libc++_shared.so arm64-v8a/libc++_shared.so

include/wallet2_api.h: $(FLAVOUR) include $(FLAVOUR)/src/wallet/api/wallet2_api.h
	cp $(FLAVOUR)/src/wallet/api/wallet2_api.h include/wallet2_api.h

include:
	mkdir include

VERSION:
	echo MONERUJO_$(FLAVOUR) `git -C . branch | grep "^\*" | sed 's/^..//'` with $(FLAVOUR) `git -C $(FLAVOUR) branch | grep "^\*" | sed 's/^..//'` `git -C $(FLAVOUR) rev-parse --short=12 HEAD` > VERSION

clean:
	-rm -rf arm64-v8a
	-rm -rf armeabi-v7a
	-rm -rf x86_64
	-rm -rf x86
	-rm -rf include

distclean: clean
	-docker container rm $(FLAVOUR)-android-arm64 -f
	-docker container rm $(FLAVOUR)-android-arm32 -f
	-docker container rm $(FLAVOUR)-android-x86_64 -f
	-docker container rm $(FLAVOUR)-android-x86 -f
	-docker image rm $(FLAVOUR)-android-arm64 -f
	-docker image rm $(FLAVOUR)-android-arm32 -f
	-docker image rm $(FLAVOUR)-android-x86_64 -f
	-docker image rm $(FLAVOUR)-android-x86 -f

	-rm $(FLAVOUR)

$(FLAVOUR):
	$(error Please ln -s $(FLAVOUR))

.PHONY: all clean distclean VERSION include/wallet2_api.h arm64-v8a
