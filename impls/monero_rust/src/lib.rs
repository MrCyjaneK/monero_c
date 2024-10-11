use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::ptr::NonNull;

pub const NETWORK_TYPE_MAINNET: c_int = 0;
pub const NETWORK_TYPE_TESTNET: c_int = 1;
pub const NETWORK_TYPE_STAGENET: c_int = 2;

extern "C" {
    pub fn MONERO_WalletManagerFactory_getWalletManager() -> *mut c_void;
    pub fn MONERO_WalletManager_createWallet(
        wm_ptr: *mut c_void,
        path: *const c_char,
        password: *const c_char,
        language: *const c_char,
        networkType: c_int,
    ) -> *mut c_void;
    pub fn MONERO_Wallet_seed(
        wallet_ptr: *mut c_void,
        seed_offset: *const c_char,
    ) -> *const c_char;
    pub fn MONERO_WalletManager_closeWallet(
        wm_ptr: *mut c_void,
        wallet_ptr: *mut c_void,
        store: bool,
    ) -> bool;
    pub fn MONERO_Wallet_errorString(wallet_ptr: *mut c_void) -> *const c_char;
    pub fn MONERO_Wallet_status(wallet_ptr: *mut c_void) -> c_int;
    pub fn MONERO_Wallet_address(
        wallet_ptr: *mut c_void,
        account_index: u64,
        address_index: u64,
    ) -> *const c_char;
    pub fn MONERO_Wallet_isDeterministic(wallet_ptr: *mut c_void) -> bool;
    pub fn MONERO_WalletManager_walletExists(
        wm_ptr: *mut c_void,
        path: *const c_char,
    ) -> bool;
}

#[derive(Debug)]
pub enum WalletError {
    NullPointer,
    FfiError(String),
    WalletErrorCode(c_int, String),
}

type WalletResult<T> = Result<T, WalletError>;

pub struct WalletManager {
    ptr: NonNull<c_void>,
}

impl WalletManager {
    pub fn new() -> WalletResult<Self> {
        unsafe {
            let ptr = MONERO_WalletManagerFactory_getWalletManager();
            NonNull::new(ptr)
                .map(|nn_ptr| WalletManager { ptr: nn_ptr })
                .ok_or(WalletError::NullPointer)
        }
    }

    pub fn create_wallet(
        &self,
        path: &str,
        password: &str,
        language: &str,
        network_type: c_int,
    ) -> WalletResult<Wallet> {
        let c_path = CString::new(path).expect("CString::new failed");
        let c_password = CString::new(password).expect("CString::new failed");
        let c_language = CString::new(language).expect("CString::new failed");

        unsafe {
            let wallet_ptr = MONERO_WalletManager_createWallet(
                self.ptr.as_ptr(),
                c_path.as_ptr(),
                c_password.as_ptr(),
                c_language.as_ptr(),
                network_type,
            );

            if wallet_ptr.is_null() {
                Err(WalletError::NullPointer)
            } else {
                Ok(Wallet {
                    ptr: NonNull::new_unchecked(wallet_ptr),
                    manager_ptr: self.ptr,
                })
            }
        }
    }
}

pub struct Wallet {
    ptr: NonNull<c_void>,
    manager_ptr: NonNull<c_void>,
}

impl Wallet {
    pub fn get_seed(&self, seed_offset: &str) -> WalletResult<String> {
        let c_seed_offset = CString::new(seed_offset).expect("CString::new failed");

        unsafe {
            let seed_ptr = MONERO_Wallet_seed(self.ptr.as_ptr(), c_seed_offset.as_ptr());

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
            let address_ptr = MONERO_Wallet_address(
                self.ptr.as_ptr(),
                account_index,
                address_index,
            );

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

    pub fn is_deterministic(&self) -> bool {
        unsafe { MONERO_Wallet_isDeterministic(self.ptr.as_ptr()) }
    }

    fn get_last_error(&self) -> WalletError {
        unsafe {
            let error_ptr = MONERO_Wallet_errorString(self.ptr.as_ptr());
            let status = MONERO_Wallet_status(self.ptr.as_ptr());

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
            MONERO_WalletManager_closeWallet(self.manager_ptr.as_ptr(), self.ptr.as_ptr(), false);
        }
    }
}
