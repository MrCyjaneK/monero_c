use std::ffi::{CStr, CString};
use std::os::raw::{c_int, c_void};
use std::ptr::NonNull;
use std::sync::Arc;

mod bindings;

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
}

pub type WalletResult<T> = Result<T, WalletError>;

pub struct WalletManager {
    ptr: NonNull<c_void>,
}

impl WalletManager {
    /// Creates a new `WalletManager` using the statically linked `MONERO_WalletManagerFactory_getWalletManager`.
    pub fn new() -> WalletResult<Arc<Self>> {
        unsafe {
            let ptr = bindings::MONERO_WalletManagerFactory_getWalletManager();
            let ptr = NonNull::new(ptr).ok_or(WalletError::NullPointer)?;
            Ok(Arc::new(WalletManager { ptr }))
        }
    }

    /// Creates a new wallet.
    pub fn create_wallet(
        self: &Arc<Self>,
        path: &str,
        password: &str,
        language: &str,
        network_type: c_int,
    ) -> WalletResult<Wallet> {
        let c_path = CString::new(path).map_err(|_| WalletError::FfiError("Invalid path".to_string()))?;
        let c_password = CString::new(password).map_err(|_| WalletError::FfiError("Invalid password".to_string()))?;
        let c_language = CString::new(language).map_err(|_| WalletError::FfiError("Invalid language".to_string()))?;

        unsafe {
            let wallet_ptr = bindings::MONERO_WalletManager_createWallet(
                self.ptr.as_ptr(),
                c_path.as_ptr(),
                c_password.as_ptr(),
                c_language.as_ptr(),
                network_type,
            );

            NonNull::new(wallet_ptr)
                .map(|ptr| Wallet { ptr, manager: Arc::clone(self) })
                .ok_or(WalletError::NullPointer)
        }
    }
}

pub struct Wallet {
    ptr: NonNull<c_void>,
    manager: Arc<WalletManager>,
}

impl Wallet {
    /// Retrieves the wallet's seed with an optional offset.
    pub fn get_seed(&self, seed_offset: &str) -> WalletResult<String> {
        let c_seed_offset = CString::new(seed_offset)
            .map_err(|_| WalletError::FfiError("Invalid seed_offset".to_string()))?;

        unsafe {
            let seed_ptr = bindings::MONERO_Wallet_seed(self.ptr.as_ptr(), c_seed_offset.as_ptr());
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

    /// Retrieves the wallet's address for the given account and address index.
    pub fn get_address(&self, account_index: u64, address_index: u64) -> WalletResult<String> {
        unsafe {
            let address_ptr = bindings::MONERO_Wallet_address(self.ptr.as_ptr(), account_index, address_index);
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
    pub fn is_deterministic(&self) -> WalletResult<bool> {
        unsafe {
            let result = bindings::MONERO_Wallet_isDeterministic(self.ptr.as_ptr());
            Ok(result)
        }
    }

    /// Retrieves the last error from the wallet.
    pub fn get_last_error(&self) -> WalletError {
        unsafe {
            let error_ptr = bindings::MONERO_Wallet_errorString(self.ptr.as_ptr());
            let status = bindings::MONERO_Wallet_status(self.ptr.as_ptr());

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
            bindings::MONERO_WalletManager_closeWallet(
                self.manager.ptr.as_ptr(),
                self.ptr.as_ptr(),
                false, // Don't save the wallet by default.
            );
        }
    }
}
