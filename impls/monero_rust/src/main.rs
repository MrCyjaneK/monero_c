#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};

const NetworkType_MAINNET: c_int = 0;
// const NetworkType_TESTNET: c_int = 1;
// const NetworkType_STAGENET: c_int = 2;

extern "C" {
    // Get the wallet manager instance.
    pub fn MONERO_WalletManagerFactory_getWalletManager() -> *mut c_void;

    // Create a new wallet.
    pub fn MONERO_WalletManager_createWallet(
        wm_ptr: *mut c_void,
        path: *const c_char,
        password: *const c_char,
        language: *const c_char,
        networkType: c_int,
    ) -> *mut c_void;

    // Retrieve the seed from the wallet.
    pub fn MONERO_Wallet_seed(
        wallet_ptr: *mut c_void,
        seed_offset: *const c_char,
    ) -> *const c_char;

    // Close the wallet.
    pub fn MONERO_WalletManager_closeWallet(
        wm_ptr: *mut c_void,
        wallet_ptr: *mut c_void,
        store: bool,
    ) -> bool;
}

fn main() {
    unsafe {
        // Initialize the Wallet Manager.
        let wm_ptr = MONERO_WalletManagerFactory_getWalletManager();
        if wm_ptr.is_null() {
            eprintln!("Failed to get WalletManager");
            return;
        }

        // Set up parameters for the new wallet.
        let path = CString::new("my_wallet").expect("CString::new failed");
        let password = CString::new("password").expect("CString::new failed");
        let language = CString::new("English").expect("CString::new failed");
        let network_type = NetworkType_MAINNET;

        // Create a new wallet.
        let wallet_ptr = MONERO_WalletManager_createWallet(
            wm_ptr,
            path.as_ptr(),
            password.as_ptr(),
            language.as_ptr(),
            network_type,
        );
        if wallet_ptr.is_null() {
            eprintln!("Failed to create wallet");
            return;
        }

        // Get the seed.
        let seed_offset = CString::new("").expect("CString::new failed");
        let seed_cstr = MONERO_Wallet_seed(wallet_ptr, seed_offset.as_ptr());
        if seed_cstr.is_null() {
            eprintln!("Failed to get seed");
        } else {
            let seed = CStr::from_ptr(seed_cstr).to_string_lossy().into_owned();
            println!("Seed: {}", seed);
        }

        // Close the wallet.
        let result = MONERO_WalletManager_closeWallet(wm_ptr, wallet_ptr, false);
        if !result {
            eprintln!("Failed to close wallet");
        }
    }
}
