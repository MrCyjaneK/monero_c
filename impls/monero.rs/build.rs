use std::env;
use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");

    let lib_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap()).join("lib");
    let monero_include_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap())
        .join("../../monero_libwallet2_api_c/src/main/cpp/");

    println!("cargo:rustc-link-search=native={}", lib_dir.display());
    println!("cargo:rustc-link-lib=dylib=wallet2_api_c");
    println!("cargo:rustc-link-lib=dylib=stdc++");
    println!("cargo:rustc-link-lib=dylib=hidapi-hidraw");

    println!("cargo:rustc-link-arg-bin=monero_rust=-Wl,-rpath,$ORIGIN/../../lib");

    // Generate Rust bindings.
    let bindings = bindgen::Builder::default()
        .header("../../monero_libwallet2_api_c/src/main/cpp/wallet2_api_c.h")
        .clang_arg(format!("-I{}", monero_include_dir.display()))
        .generate()
        .expect("Unable to generate bindings");
    let out_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap())
        .join("src")
        .join("bindings.rs");
    bindings
        .write_to_file(&out_path)
        .expect("Couldn't write bindings!");
}
