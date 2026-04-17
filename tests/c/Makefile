CC ?= gcc
CFLAGS ?= -Wall -Wextra -O2 -Isrc -I../../monero_libwallet2_api_c/src/main/cpp -Itests
LDFLAGS ?=

UNAME_S := $(shell uname -s)

ifeq ($(OS),Windows_NT)
    LIB_EXT := dll
else ifeq ($(UNAME_S),Darwin)
    LIB_EXT := dylib
else
    LIB_EXT := so
endif

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Normalize architecture
ifeq ($(UNAME_M),x86_64)
  ARCH := x86_64
else ifeq ($(UNAME_M),aarch64)
  ARCH := aarch64
else ifeq ($(UNAME_M),arm64)
  ARCH := aarch64
else
  ARCH := $(UNAME_M)
endif

# Normalize OS
ifeq ($(UNAME_S),Darwin)
  OS := apple-darwin
else ifeq ($(UNAME_S),Linux)
  OS := linux-gnu
else
  OS := unknown-$(shell echo $(UNAME_S) | tr A-Z a-z)
endif

HOST_ABI := $(ARCH)-$(OS)

LIB_DIR ?= ../../release/$(shell git describe --tags)/$(HOST_ABI)

SRC_DIRS ?= src tests
SRCS := $(wildcard $(addsuffix /*.c,$(SRC_DIRS)))
OBJS := $(SRCS:.c=.o)
TARGET = test_wallet2_api_c

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ -L$(LIB_DIR) -lmonero_wallet2_api_c -Wl,-rpath,$(LIB_DIR) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
