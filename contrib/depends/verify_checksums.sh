#!/bin/bash
# Script to verify that all SHA256 checksums in native_rust.mk match upstream

set -e

BASE_URL="https://static.rust-lang.org/dist/2023-12-28"
PASS=0
FAIL=0

echo "========================================="
echo "Verifying Rust 1.75.0 SHA256 Checksums"
echo "Against: $BASE_URL"
echo "========================================="
echo ""

# Function to verify a checksum
verify_hash() {
    local file=$1
    local expected=$2
    local label=$3
    
    echo "Checking: $label"
    echo "  File: $file"
    
    # Fetch upstream hash
    local upstream=$(curl -s "$BASE_URL/$file.sha256" | awk '{print $1}')
    
    if [ -z "$upstream" ]; then
        echo "  ❌ ERROR: Could not fetch upstream hash"
        ((FAIL++))
        return 1
    fi
    
    echo "  Expected (in PR): $expected"
    echo "  Upstream (official): $upstream"
    
    if [ "$expected" = "$upstream" ]; then
        echo "  ✅ MATCH"
        ((PASS++))
    else
        echo "  ❌ MISMATCH!"
        ((FAIL++))
    fi
    echo ""
}

# Verify source tarball
verify_hash "rustc-1.75.0-src.tar.xz" \
    "4526f786d673e4859ff2afa0bab2ba13c918b796519a25c1acce06dba9542340" \
    "Rust source (rustc-1.75.0-src.tar.xz)"

# Verify Linux bootstrap
verify_hash "rust-1.75.0-x86_64-unknown-linux-gnu.tar.gz" \
    "473978b6f8ff216389f9e89315211c6b683cf95a966196e7914b46e8cf0d74f6" \
    "Linux x86_64 bootstrap"

# Verify macOS bootstrap
verify_hash "rust-1.75.0-aarch64-apple-darwin.tar.gz" \
    "878ecf81e059507dd2ab256f59629a4fb00171035d2a2f5638cb582d999373b1" \
    "macOS ARM64 bootstrap"

# Verify Android std
verify_hash "rust-std-1.75.0-aarch64-linux-android.tar.gz" \
    "1cd6510dd282de87d9247b09f8f90e533393a83385d99151f9ec7983118d299a" \
    "Android aarch64 std"

# Verify Windows std
verify_hash "rust-std-1.75.0-x86_64-pc-windows-gnu.tar.gz" \
    "6c40c5274c8ab13e1c23c9082bc85772330b6a8ca2407a3253b6430239764602" \
    "Windows x86_64 std"

# Verify macOS ARM64 std
verify_hash "rust-std-1.75.0-aarch64-apple-darwin.tar.gz" \
    "8eedd403d05829369e3dd84c6815f69fb7e5495d3ee3bf2b4b2f04d8591fe639" \
    "macOS ARM64 std"

# Verify macOS x86_64 std
verify_hash "rust-std-1.75.0-x86_64-apple-darwin.tar.gz" \
    "65098155333de2e446df61cdaf12a0c441358b7973f3cb1ba95fd11bda890406" \
    "macOS x86_64 std"

# Verify iOS std
verify_hash "rust-std-1.75.0-aarch64-apple-ios.tar.gz" \
    "0a7d3ecd36b4be381eabeb84d1df2aa2f9dbce01a9c2029aaa3a38d54eea11a8" \
    "iOS aarch64 std"

echo "========================================="
echo "RESULTS:"
echo "  ✅ Passed: $PASS"
echo "  ❌ Failed: $FAIL"
echo "========================================="

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "⚠️  CRITICAL: Some checksums do not match upstream!"
    echo "Do NOT merge until all checksums are verified."
    exit 1
else
    echo ""
    echo "✅ All checksums verified against upstream!"
    echo "Safe to merge."
    exit 0
fi
