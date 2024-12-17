#!/bin/bash

set -e

cd "$(realpath $(dirname $0))"

dart run ffigen --config ffigen_wownero.yaml
dart run ffigen --config ffigen_monero.yaml
dart run ffigen --config ffigen_zano.yaml
