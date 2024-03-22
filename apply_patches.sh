#!/bin/bash

if [[ ! -d 'monero' ]]
then
    echo "no 'monero' directory found. clone with --recursive or run:"
    echo "$ git submodule init && git submodule update --force";
    exit 1
fi

if [[ -f "monero/.patch-applied" ]];
then
    echo "monero/.patch-applied file exist. manual investigation recommended."
    exit 0
fi

cd monero
git apply ../patches/monero/* --index
git submodule init
git submodule update --force
touch .patch-applied
git add .
git config user.email "you@example.com"
git config user.name "Your Name"
git commit -m 'patch applied' # fatal: path 'external/polyseed' exists on disk, but not in 'HEAD'
echo "you are good to go!"