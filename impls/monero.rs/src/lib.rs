use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::path::PathBuf;
use std::ptr::NonNull;
use std::sync::Arc;

use libloading::{Library, Symbol};

pub const NETWORK_TYPE_MAINNET: c_int = 0;
pub const NETWORK_TYPE_TESTNET: c_int = 1;
pub const NETWORK_TYPE_STAGENET: c_int = 2;

#[derive(Debug)]
pub enum WalletError {
    NullPointer,
    FfiError(String),
    WalletErrorCode(c_int, String),
    LibraryLoadError(String),
}

pub type WalletResult<T> = Result<T, WalletError>;

/// Manages the loading of the Monero wallet library and provides factory methods to create wallets.
///
/// The `WalletManager` is responsible for loading the Monero C library (`wallet2_api_c`) and
/// provides methods to create and manage `Wallet` instances.
#[derive(Clone)]
pub struct WalletManager {
    ptr: NonNull<c_void>,
    library: Arc<Library>,
}

#[cfg(target_os = "android")]
const LIB_NAME: &str = "libmonero_libwallet2_api_c.so";
#[cfg(target_os = "ios")]
const LIB_NAME: &str = "MoneroWallet.framework/MoneroWallet";
#[cfg(target_os = "linux")]
const LIB_NAME: &str = "monero_libwallet2_api_c.so";
#[cfg(target_os = "macos")]
const LIB_NAME: &str = "monero_libwallet2_api_c.dylib";
#[cfg(target_os = "windows")]
const LIB_NAME: &str = "monero_libwallet2_api_c.dll";

impl WalletManager {
    /// Creates a new `WalletManager`, loading the Monero wallet library.
    ///
    /// If `lib_path` is provided, the library will be loaded from that path.
    /// Otherwise, it attempts to load the library from several default locations.
    ///
    /// # Errors
    ///
    /// Returns `WalletError::LibraryLoadError` if the library cannot be loaded.
    pub fn new(lib_path: Option<&str>) -> WalletResult<Self> {
        let library = if let Some(path) = lib_path {
            // Load the library from the specified path.
            unsafe { Library::new(path).map_err(|e| WalletError::LibraryLoadError(e.to_string()))? }
        } else {
            // Attempt to load the library from multiple candidate paths.
            let exe_path = std::env::current_exe()
                .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;
            let exe_dir = exe_path.parent().ok_or_else(|| {
                WalletError::LibraryLoadError("Failed to get executable directory".to_string())
            })?;

            // Prepare the list of candidate paths.
            let mut candidates: Vec<PathBuf> = Vec::new();

            // Candidate 1: ../../../../release/ relative to the executable.
            if let Some(lib_dir) = exe_dir
                .parent()
                .and_then(|p| p.parent())
                .and_then(|p| p.parent())
                .and_then(|p| p.parent())
            {
                let lib_path = lib_dir.join("release").join(LIB_NAME);
                candidates.push(lib_path);
            }

            // Candidate 2: ../../lib/ relative to the executable.
            if let Some(lib_dir) = exe_dir.parent().and_then(|p| p.parent()) {
                let lib_path = lib_dir.join("lib").join(LIB_NAME);
                candidates.push(lib_path);
            }

            // Candidate 3: library in the same directory as the executable.
            candidates.push(exe_dir.join(LIB_NAME));

            // Candidate 4: Let the library loader search standard library paths.
            candidates.push(PathBuf::from(LIB_NAME));

            // Try to load the library from the candidate paths.
            let mut library = None;
            for candidate in &candidates {
                match unsafe { Library::new(candidate) } {
                    Ok(lib) => {
                        library = Some(lib);
                        break;
                    }
                    Err(err) => {
                        eprintln!(
                            "Failed to load library from {}: {}",
                            candidate.display(),
                            err
                        );
                        continue; // Try next candidate.
                    }
                }
            }

            // If none of the candidates worked, return an error.
            library.ok_or_else(|| {
                WalletError::LibraryLoadError(format!(
                    "Failed to load {} from paths: {:?}",
                    LIB_NAME, candidates
                ))
            })?
        };

        let library = Arc::new(library);

        // Get the wallet manager pointer from the library.
        unsafe {
            let func: Symbol<unsafe extern "C" fn() -> *mut c_void> =
                library
                    .get(b"MONERO_WalletManagerFactory_getWalletManager\0")
                    .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;
            let ptr = func();
            NonNull::new(ptr)
                .map(|nn_ptr| WalletManager { ptr: nn_ptr, library })
                .ok_or(WalletError::NullPointer)
        }
    }

    /// Creates a new `Wallet` using the specified parameters.
    ///
    /// # Errors
    ///
    /// Returns `WalletError::NullPointer` if the wallet creation fails.
    pub fn create_wallet(
        &self,
        path: &str,
        password: &str,
        language: &str,
        network_type: c_int,
    ) -> WalletResult<Wallet> {
        let c_path = CString::new(path)
            .map_err(|_| WalletError::FfiError("Invalid path".to_string()))?;
        let c_password = CString::new(password)
            .map_err(|_| WalletError::FfiError("Invalid password".to_string()))?;
        let c_language = CString::new(language)
            .map_err(|_| WalletError::FfiError("Invalid language".to_string()))?;

        unsafe {
            let func: Symbol<
                unsafe extern "C" fn(
                    *mut c_void,
                    *const c_char,
                    *const c_char,
                    *const c_char,
                    c_int,
                ) -> *mut c_void,
            > = self
                .library
                .get(b"MONERO_WalletManager_createWallet\0")
                .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;
            let wallet_ptr = func(
                self.ptr.as_ptr(),
                c_path.as_ptr(),
                c_password.as_ptr(),
                c_language.as_ptr(),
                network_type,
            );

            NonNull::new(wallet_ptr)
                .map(|ptr| Wallet {
                    ptr,
                    manager: self.clone(),
                })
                .ok_or(WalletError::NullPointer)
        }
    }
}

/// Represents a Monero wallet instance.
///
/// The `Wallet` struct provides methods to interact with a Monero wallet, such as retrieving
/// the seed, getting addresses, and checking if the wallet is deterministic.
pub struct Wallet {
    ptr: NonNull<c_void>,
    manager: WalletManager,
}

impl Wallet {
    /// Retrieves the seed of the wallet.
    ///
    /// # Arguments
    ///
    /// * `seed_offset` - An optional seed offset.
    ///
    /// # Errors
    ///
    /// Returns `WalletError::FfiError` if the seed cannot be retrieved.
    pub fn get_seed(&self, seed_offset: &str) -> WalletResult<String> {
        let c_seed_offset = CString::new(seed_offset)
            .map_err(|_| WalletError::FfiError("Invalid seed_offset".to_string()))?;

        unsafe {
            let func: Symbol<unsafe extern "C" fn(*mut c_void, *const c_char) -> *const c_char> =
                self.manager
                    .library
                    .get(b"MONERO_Wallet_seed\0")
                    .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;
            let seed_ptr = func(self.ptr.as_ptr(), c_seed_offset.as_ptr());

            if seed_ptr.is_null() {
                Err(self.get_last_error())
            } else {
                let seed = CStr::from_ptr(seed_ptr)
                    .to_string_lossy()
                    .into_owned();
                if seed.is_empty() {
                    Err(WalletError::FfiError("Received empty seed".to_string()))
                } else {
                    Ok(seed)
                }
            }
        }
    }

    /// Retrieves the address of the wallet for the given account and address indices.
    ///
    /// # Arguments
    ///
    /// * `account_index` - The account index.
    /// * `address_index` - The address index.
    ///
    /// # Errors
    ///
    /// Returns `WalletError::FfiError` if the address cannot be retrieved.
    pub fn get_address(&self, account_index: u64, address_index: u64) -> WalletResult<String> {
        unsafe {
            let func: Symbol<unsafe extern "C" fn(*mut c_void, u64, u64) -> *const c_char> =
                self.manager
                    .library
                    .get(b"MONERO_Wallet_address\0")
                    .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;
            let address_ptr = func(self.ptr.as_ptr(), account_index, address_index);

            if address_ptr.is_null() {
                Err(self.get_last_error())
            } else {
                let address = CStr::from_ptr(address_ptr)
                    .to_string_lossy()
                    .into_owned();
                Ok(address)
            }
        }
    }

    /// Checks if the wallet is deterministic.
    pub fn is_deterministic(&self) -> bool {
        unsafe {
            let func: Symbol<unsafe extern "C" fn(*mut c_void) -> bool> = self
                .manager
                .library
                .get(b"MONERO_Wallet_isDeterministic\0")
                .expect("Failed to load MONERO_Wallet_isDeterministic");
            func(self.ptr.as_ptr())
        }
    }

    /// Retrieves the last error from the wallet.
    fn get_last_error(&self) -> WalletError {
        unsafe {
            let error_func: Symbol<unsafe extern "C" fn(*mut c_void) -> *const c_char> = self
                .manager
                .library
                .get(b"MONERO_Wallet_errorString\0")
                .expect("Failed to load MONERO_Wallet_errorString");
            let status_func: Symbol<unsafe extern "C" fn(*mut c_void) -> c_int> = self
                .manager
                .library
                .get(b"MONERO_Wallet_status\0")
                .expect("Failed to load MONERO_Wallet_status");

            let error_ptr = error_func(self.ptr.as_ptr());
            let status = status_func(self.ptr.as_ptr());

            let error_msg = if error_ptr.is_null() {
                "Unknown error".to_string()
            } else {
                CStr::from_ptr(error_ptr)
                    .to_string_lossy()
                    .into_owned()
            };

            WalletError::WalletErrorCode(status, error_msg)
        }
    }
}

impl Drop for Wallet {
    fn drop(&mut self) {
        unsafe {
            let func: Symbol<
                unsafe extern "C" fn(*mut c_void, *mut c_void, bool) -> bool,
            > = self
                .manager
                .library
                .get(b"MONERO_WalletManager_closeWallet\0")
                .expect("Failed to load MONERO_WalletManager_closeWallet");
            func(self.manager.ptr.as_ptr(), self.ptr.as_ptr(), false);
        }
    }
}
