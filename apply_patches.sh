#!/bin/bash

cd "$(realpath $(dirname $0))"

repo="$1"

if [[ "x$repo" == "x" ]];
then
    echo "Usage: $0 monero/wownero"
    exit 1
fi

if [[ "x$repo" != "xwownero" && "x$repo" != "xmonero" && "x$repo" != "xnerva" ]];
then
    echo "Usage: $0 monero/wownero/nerva"
    echo "Invalid target given, only monero, wownero and nerva are supported targets"
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
# Apply patches only if any exist for this target (nerva may start with none).
if compgen -G "../patches/$repo/*.patch" > /dev/null;
then
    git am -3 --whitespace=fix --reject ../patches/$repo/*.patch
else
    echo "No patches found for $repo, skipping git am."
fi
if [[ "$repo" == "wownero" ]];
then
    pushd external/randomwow
        git remote set-url origin https://github.com/mrcyjanek/randomwow.git
    popd
fi

git submodule init
git submodule update --init --recursive --force

find . -name "*.S" -o -name "*.s" -type f | while read -r file; do
    if ! grep -q "\.note\.GNU-stack" "$file"; then
        echo "Adding conditional .note.GNU-stack section to: $file"
        echo "" >> "$file"
        echo "#ifdef __linux__" >> "$file"
        echo ".section .note.GNU-stack,\"\",@progbits" >> "$file"
        echo "#endif" >> "$file"
        git add "$file" || true
    fi
done
# Nerva's assembly files may already carry the .note.GNU-stack section (or have
# none), leaving nothing to commit -- tolerate that instead of failing the build.
git commit -m "Add .note.GNU-stack section to assembly files" || true

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
