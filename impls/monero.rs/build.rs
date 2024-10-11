use std::env;
use std::path::PathBuf;
use bindgen::EnumVariation;

fn main() {
    let header_path = "../../monero_libwallet2_api_c/src/main/cpp/wallet2_api_c.h";

    println!("cargo:rerun-if-changed={}", header_path);

    // Configure bindgen
    let bindings = bindgen::Builder::default()
        .header(header_path)
        .allowlist_function("MONERO_.*")
        .allowlist_var("MONERO_.*")
        .allowlist_var("NetworkType_.*")
        .allowlist_var("PendingTransactionStatus_.*")
        .allowlist_var("Priority_.*")
        .allowlist_var("UnsignedTransactionStatus_.*")
        .allowlist_var("TransactionInfoDirection_.*")
        .allowlist_var("AddressBookErrorCode.*")
        .allowlist_var("WalletDevice_.*")
        .allowlist_var("WalletStatus_.*")
        .allowlist_var("WalletConnectionStatus_.*")
        .allowlist_var("WalletBackgroundSync_.*")
        .allowlist_var("BackgroundSync_.*")
        .allowlist_var("LogLevel_.*")
        .blocklist_type("__.*")
        .blocklist_type("_.*")
        .blocklist_function("__.*")
        .layout_tests(false)
        .default_enum_style(EnumVariation::Rust {
            non_exhaustive: false,
        })
        .derive_default(false)
        .conservative_inline_namespaces()
        .generate_comments(false)
        .generate()
        .expect("Unable to generate bindings");
    let out_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap())
        .join("src")
        .join("bindings.rs");
    bindings
        .write_to_file(out_path)
        .expect("Couldn't write bindings!");
}
