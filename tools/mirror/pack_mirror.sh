#!/bin/bash

set -e

cd "$(dirname "$0")"

MIRROR_DIR="$(pwd)/mirror_work/mirror.git"
PACK_DIR="$(pwd)/mirror_work/pack"

if [ ! -d "$MIRROR_DIR" ]; then
    echo "Error: Mirror repository not found at $MIRROR_DIR"
    exit 1
fi

rm -rf "$PACK_DIR"
mkdir -p "$PACK_DIR"

cp -r "$MIRROR_DIR" "$PACK_DIR/mirror.git"

cd "$PACK_DIR/mirror.git"

echo "Optimizing repository..."
git gc --aggressive --prune=now

git pack-refs --all

rm -rf hooks/* info/* logs/* packed-refs.old

git show-ref > info/refs

git update-server-info

mkdir -p objects

while read -r hash ref; do
    dir=${hash:0:2}
    file=${hash:2}
    mkdir -p "objects/$dir"

    git cat-file -p "$hash" > "objects/$dir/$file"
done < info/refs

rm -rf "$TEMP_REPO"

rm -f config

cd "$PACK_DIR"

echo rsync --delete -raz --progress "$PACK_DIR/mirror.git" "mrcyjanek@static.mrcyjanek.net:/home/mrcyjanek/web/static.mrcyjanek.net/public_html/download_mirror/git/"
echo "Mirror packaged successfully at: $PACK_DIR/mirror.git"