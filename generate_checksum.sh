#!/bin/bash
cd "$(realpath $(dirname $0))"

if [[ "$(uname)" == "Darwin" ]];
then
    function sha256sum() { shasum -a 256 "$@" ; } && export -f sha256sum
fi

for coin in monero wownero;
do
    submodule_hash=$(git ls-tree HEAD ${coin} | xargs | awk '{ print $3 }')
    COIN=$(echo "$coin" | tr a-z A-Z)
    COIN_wallet2_api_c_h_sha256=$(sha256sum ${coin}_libwallet2_api_c/src/main/cpp/wallet2_api_c.h | xargs | awk '{ print $1 }')
    COIN_wallet2_api_c_cpp_sha256=$(sha256sum ${coin}_libwallet2_api_c/src/main/cpp/wallet2_api_c.cpp | xargs | awk '{ print $1 }')-${submodule_hash}
    COIN_wallet2_api_c_exp_sha256=$(sha256sum ${coin}_libwallet2_api_c/${coin}_libwallet2_api_c.exp | xargs | awk '{ print $1 }')

    cat > ${coin}_libwallet2_api_c/src/main/cpp/${coin}_checksum.h << EOF
#ifndef MONEROC_CHECKSUMS
#define MONEROC_CHECKSUMS
const char * ${COIN}_wallet2_api_c_h_sha256 = "${COIN_wallet2_api_c_h_sha256}";
const char * ${COIN}_wallet2_api_c_cpp_sha256 = "${COIN_wallet2_api_c_cpp_sha256}";
const char * ${COIN}_wallet2_api_c_exp_sha256 = "${COIN_wallet2_api_c_exp_sha256}";
#endif
EOF
    cat > impls/monero.dart/lib/src/checksum_${coin}.dart << EOF
// ignore_for_file: constant_identifier_names
const String wallet2_api_c_h_sha256 = "${COIN_wallet2_api_c_h_sha256}";
const String wallet2_api_c_cpp_sha256 = "${COIN_wallet2_api_c_cpp_sha256}";
const String wallet2_api_c_exp_sha256 = "${COIN_wallet2_api_c_exp_sha256}";
EOF
    cat > impls/monero.ts/checksum_${coin}.ts << EOF
export const ${coin}Checksum = {
    wallet2_api_c_h_sha256: "${COIN_wallet2_api_c_h_sha256}",
    wallet2_api_c_cpp_sha256: "${COIN_wallet2_api_c_cpp_sha256}",
    wallet2_api_c_exp_sha256: "${COIN_wallet2_api_c_exp_sha256}",
}
EOF
done

