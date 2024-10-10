use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");

    let lib_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap()).join("lib");

    println!("cargo:rustc-link-search=native={}", lib_dir.display());
    println!("cargo:rustc-link-lib=dylib=wallet2_api_c");
    println!("cargo:rustc-link-lib=dylib=stdc++");
    println!("cargo:rustc-link-lib=dylib=hidapi-hidraw");

    println!("cargo:rustc-link-arg-bin=monero_rust=-Wl,-rpath,$ORIGIN/../../lib");
}
