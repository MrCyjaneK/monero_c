use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::path::PathBuf;
use std::ptr::NonNull;
use std::sync::Arc;

use libloading::{Library, Symbol};

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

pub mod network {
    use std::os::raw::c_int;
    pub const MAINNET: c_int = 0;
    pub const TESTNET: c_int = 1;
    pub const STAGENET: c_int = 2;
}

#[derive(Debug)]
pub enum WalletError {
    NullPointer,
    FfiError(String),
    WalletErrorCode(c_int, String),
    LibraryLoadError(String),
}

pub type WalletResult<T> = Result<T, WalletError>;

pub struct WalletManager {
    ptr: NonNull<c_void>,
    library: Library,
}

impl WalletManager {
    /// Creates a new `WalletManager`, loading the Monero wallet library (`wallet2_api_c`).
    pub fn new(lib_path: Option<&str>) -> WalletResult<Arc<Self>> {
        let library = Self::load_library(lib_path)?;

        unsafe {
            let func: Symbol<unsafe extern "C" fn() -> *mut c_void> = library
                .get(b"MONERO_WalletManagerFactory_getWalletManager\0")
                .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;

            let ptr = NonNull::new(func()).ok_or(WalletError::NullPointer)?;

            Ok(Arc::new(WalletManager { ptr, library }))
        }
    }

    pub fn create_wallet(
        self: &Arc<Self>,
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
                    manager: Arc::clone(self),
                })
                .ok_or(WalletError::NullPointer)
        }
    }

    fn load_library(lib_path: Option<&str>) -> WalletResult<Library> {
        if let Some(path) = lib_path {
            unsafe { Library::new(path).map_err(|e| WalletError::LibraryLoadError(e.to_string())) }
        } else {
            let exe_path = std::env::current_exe()
                .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;
            let exe_dir = exe_path.parent().ok_or_else(|| {
                WalletError::LibraryLoadError("Failed to get executable directory".to_string())
            })?;

            let candidates = Self::get_library_candidates(exe_dir);

            candidates
                .into_iter()
                .find_map(|path| unsafe { Library::new(&path).ok() })
                .ok_or_else(|| {
                    WalletError::LibraryLoadError(format!(
                        "Failed to load {} from standard paths",
                        LIB_NAME
                    ))
                })
        }
    }

    fn get_library_candidates(exe_dir: &std::path::Path) -> Vec<PathBuf> {
        let mut candidates = Vec::new();

        // Candidate 1: ../../../../release/ relative to the executable.
        if let Some(lib_dir) = exe_dir.ancestors().nth(4) {
            candidates.push(lib_dir.join("release").join(LIB_NAME));
        }

        // Candidate 2: ../../lib/ relative to the executable.
        if let Some(lib_dir) = exe_dir.ancestors().nth(2) {
            candidates.push(lib_dir.join("lib").join(LIB_NAME));
        }

        // Candidate 3: Same directory as the executable.
        candidates.push(exe_dir.join(LIB_NAME));
        // TODO: This should probably be the first candidate for binary
        // distribution purposes; it will likely be the first place the library
        // will be found in a binary distribution.

        // Candidate 4: Standard library paths.
        candidates.push(PathBuf::from(LIB_NAME));

        candidates
    }
}

pub struct Wallet {
    ptr: NonNull<c_void>,
    manager: Arc<WalletManager>,
}

impl Wallet {
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

    pub fn is_deterministic(&self) -> WalletResult<bool> {
        unsafe {
            let func: Symbol<unsafe extern "C" fn(*mut c_void) -> bool> = self
                .manager
                .library
                .get(b"MONERO_Wallet_isDeterministic\0")
                .map_err(|e| WalletError::LibraryLoadError(e.to_string()))?;
            Ok(func(self.ptr.as_ptr()))
        }
    }

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
