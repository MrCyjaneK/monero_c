#!/bin/bash
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
git am ../patches/$repo/*.patch
if [[ "$repo" == "wownero" ]];
then
    pushd external/randomwow
        git remote set-url origin https://github.com/mrcyjanek/randomwow.git
    popd
fi
git submodule init
git submodule update --init --recursive --force
touch .patch-applied
echo "you are good to go!"