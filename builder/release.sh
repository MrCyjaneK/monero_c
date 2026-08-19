#!/bin/bash
set -xe

cd $(dirname $0)
cd ..
img=localhost/monero_c:$(git describe --tags)

docker build -t $img -f ./builder/Dockerfile . 2>&1 | cat

docker create --name temp_extract $img /bin/sh -c 'sleep 3000'

docker cp temp_extract:/release ./release/$(git describe --tags)
docker rm temp_extract || true
