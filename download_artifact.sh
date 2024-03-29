#!/bin/bash
# Usage: ${{ github.workspace }}/download_artifact.sh libsodium "${SODIUM_VERSION}-${{ matrix.host_triplet }}-${SODIUM_HASH}" ${{ github.workspace }}/prefix/lib/libsodium.a
set -e
registry_user=mrcyjanek
cache_name="$1"
cache_key="$2"
path_to_file="$3.xz"
basename="$(basename $path_to_file)"

curl "https://git.mrcyjanek.net/api/packages/mrcyjanek/generic/monero_c/${cache_name}-${cache_key}/${basename}" > /tmp/cache
if [[ "xpackage does not exist" == "x$(head -1 /tmp/cache 2>/dev/null)" ]];
then
    echo "Cache miss '$1' '$2' '$basename'"
    rm /tmp/cache
    exit 0
else
    echo "Cache hit '$1' '$2' '$basename'"
fi

mkdir -p $path_to_file
rm -rf $path_to_file
mv /tmp/cache $path_to_file
unxz $path_to_file || rm $path_to_file

if [[ -f "$3" ]];
then
    touch /tmp/cache_hit_$(echo "$3" | md5sum | awk '{ print $1 }')
fi