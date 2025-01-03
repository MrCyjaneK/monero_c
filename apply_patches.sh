#!/bin/bash

cd "$(realpath $(dirname $0))"

repo="$1"

if [[ "x$repo" == "x" ]];
then
    echo "Usage: $0 monero/wownero"
    exit 1
fi

if [[ "x$repo" != "xwownero" && "x$repo" != "xmonero" ]];
then
    echo "Usage: $0 monero/wownero"
    echo "Invalid target given, only monero and wownero are supported targets"
fi

if [[ ! -d "$repo" ]]
then
    echo "no '$repo' directory found. clone with --recursive or run:"
    echo "$ git submodule init && git submodule update --force";
    exit 1
fi

if [[ -f "$repo/.patch-applied" ]];
then
    echo "$repo/.patch-applied file exist. manual investigation recommended."
    exit 0
fi

set -e
cd $repo
git am -3 --whitespace=fix --reject ../patches/$repo/*.patch
if [[ "$repo" == "wownero" ]];
then
    pushd external/randomwow
        git remote set-url origin https://github.com/mrcyjanek/randomwow.git
    popd
fi
if [[ "$repo" == "zano" ]];
then
    pushd contrib/tor-connect
         git remote set-url origin https://github.com/mrcyjanek/tor-connect.git
    popd
fi
git submodule init
git submodule update --init --recursive --force
git am -3 <<EOF
From e56dd6cd0fb1a5e55d3cb08691edf24b26d65299 Mon Sep 17 00:00:00 2001
From: Czarek Nakamoto <cyjan@mrcyjanek.net>
Date: Fri, 20 Dec 2024 09:18:08 +0100
Subject: [PATCH] add .patch-applied

---
 .patch-applied | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 .patch-applied

diff --git a/.patch-applied b/.patch-applied
new file mode 100644
index 000000000..e69de29bb
-- 
2.39.5 (Apple Git-154)
EOF

echo "you are good to go!"
