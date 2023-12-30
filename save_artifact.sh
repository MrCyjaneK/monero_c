#!/bin/bash
# Usage: ${{ github.workspace }}/save_artifact.sh libsodium "${SODIUM_VERSION}-${{ matrix.host_triplet }}-${SODIUM_HASH}" ${{ github.workspace }}/prefix/lib/libsodium.a

registry_user=mrcyjanek
cache_name="$1"
cache_key="$2"
path_to_file_="$3"
xz --extreme --keep $path_to_file_
path_to_file="$3.xz"
basename="$(basename $path_to_file)"
curl --user $registry_user:$PAT_SECRET_PACKAGE \
     --upload-file "$path_to_file" \
     "https://git.mrcyjanek.net/api/packages/mrcyjanek/generic/monero_c/${cache_name}-${cache_key}/${basename}"

rm $path_to_file