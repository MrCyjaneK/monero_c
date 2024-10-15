use std::ffi::{CStr, CString};
use std::os::raw::{c_int, c_void};
use std::ptr::NonNull;
use std::sync::Arc;

mod bindings;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NetworkType {
    Mainnet = bindings::NetworkType_MAINNET as isize,
    Testnet = bindings::NetworkType_TESTNET as isize,
    Stagenet = bindings::NetworkType_STAGENET as isize,
}

impl NetworkType {
    pub fn from_c_int(value: c_int) -> Option<Self> {
        match value {
            bindings::NetworkType_MAINNET => Some(NetworkType::Mainnet),
            bindings::NetworkType_TESTNET => Some(NetworkType::Testnet),
            bindings::NetworkType_STAGENET => Some(NetworkType::Stagenet),
            _ => None,
        }
    }

    pub fn to_c_int(self) -> c_int {
        self as c_int
    }
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
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::WalletManager;
    /// let manager = WalletManager::new();
    /// assert!(manager.is_ok());
    /// ```
    pub fn new() -> WalletResult<Arc<Self>> {
        unsafe {
            let ptr = bindings::MONERO_WalletManagerFactory_getWalletManager();
            let ptr = NonNull::new(ptr).ok_or(WalletError::NullPointer)?;
            Ok(Arc::new(WalletManager { ptr }))
        }
    }

    /// Creates a new wallet.
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use std::fs;
    /// use std::path::Path;
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet = manager.create_wallet("wallet_name", "password", "English", NetworkType::Mainnet);
    /// assert!(wallet.is_ok());
    ///
    /// // Cleanup: remove the wallet file and its corresponding keys file, if they exist.
    /// if Path::new("wallet_name").exists() {
    ///     fs::remove_file("wallet_name").expect("Failed to delete test wallet");
    /// }
    /// if Path::new("wallet_name.keys").exists() {
    ///     fs::remove_file("wallet_name.keys").expect("Failed to delete test wallet keys");
    /// }
    /// ```
    pub fn create_wallet(
        self: &Arc<Self>,
        path: &str,
        password: &str,
        language: &str,
        network_type: NetworkType,
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
                network_type.to_c_int(),
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
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use tempfile::TempDir;
    /// use std::fs;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("wallet_name");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    /// assert!(wallet_result.is_ok(), "Failed to create wallet: {:?}", wallet_result.err());
    /// let wallet = wallet_result.unwrap();
    /// let seed = wallet.get_seed("");
    /// assert!(seed.is_ok(), "Failed to get seed: {:?}", seed.err());
    /// let seed = seed.unwrap();
    /// assert!(!seed.is_empty(), "Seed should not be empty");
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
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
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use tempfile::TempDir;
    /// use std::fs;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("wallet_name");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).unwrap();
    /// let address = wallet.get_address(0, 0);
    /// assert!(address.is_ok(), "Failed to get address: {:?}", address.err());
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
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
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use tempfile::TempDir;
    /// use std::fs;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("wallet_name");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    /// assert!(wallet_result.is_ok(), "Failed to create wallet: {:?}", wallet_result.err());
    /// let wallet = wallet_result.unwrap();
    /// let is_deterministic = wallet.is_deterministic();
    /// assert!(is_deterministic.is_ok(), "Failed to check if wallet is deterministic: {:?}", is_deterministic.err());
    /// assert!(is_deterministic.unwrap(), "Wallet should be deterministic");
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn is_deterministic(&self) -> WalletResult<bool> {
        unsafe {
            let result = bindings::MONERO_Wallet_isDeterministic(self.ptr.as_ptr());
            Ok(result)
        }
    }

    /// Retrieves the last error from the wallet.
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::{WalletManager, NetworkType, WalletError};
    /// let manager = WalletManager::new().unwrap();
    /// // Intentionally pass an invalid wallet to force an error.
    /// let invalid_wallet = manager.create_wallet("", "", "", NetworkType::Mainnet);
    /// if let Err(err) = invalid_wallet {
    ///     if let WalletError::WalletErrorCode(_, error_msg) = err {
    ///         // Check that an error message was produced
    ///         assert!(!error_msg.is_empty(), "Error message should not be empty");
    ///     }
    /// }
    /// ```
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

#[cfg(test)]
use tempfile::TempDir;
#[cfg(test)]
use std::fs;

#[cfg(test)]
fn check_and_delete_existing_wallets(temp_dir: &TempDir) -> std::io::Result<()> {
    let test_wallet_names = &["wallet_name", "mainnet_wallet", "testnet_wallet", "stagenet_wallet"];

    for name in test_wallet_names {
        let wallet_file = temp_dir.path().join(name);
        let keys_file = temp_dir.path().join(format!("{}.keys", name));

        if wallet_file.exists() {
            fs::remove_file(&wallet_file)?;
        }
        if keys_file.exists() {
            fs::remove_file(&keys_file)?;
        }
    }
    Ok(())
}

#[cfg(test)]
fn setup() -> WalletResult<(Arc<WalletManager>, TempDir)> {
    let temp_dir = tempfile::tempdir().expect("Failed to create temporary directory");
    check_and_delete_existing_wallets(&temp_dir).expect("Failed to clean up existing wallets");

    let manager = WalletManager::new()?;
    Ok((manager, temp_dir))
}

#[cfg(test)]
fn teardown(temp_dir: &TempDir) -> std::io::Result<()> {
    check_and_delete_existing_wallets(temp_dir)
}

#[test]
fn test_wallet_manager_creation() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("wallet_name");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    assert!(wallet_result.is_ok(), "WalletManager creation failed");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_wallet_creation() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("wallet_name");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    assert!(wallet.is_ok(), "Failed to create wallet");
    let wallet = wallet.unwrap();
    assert!(wallet.is_deterministic().is_ok(), "Wallet creation seems to have failed");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_get_seed() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("wallet_name");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).expect("Failed to create wallet");
    let result = wallet.get_seed("");
    assert!(result.is_ok(), "Failed to get seed: {:?}", result.err());
    assert!(!result.unwrap().is_empty(), "Seed is empty");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_get_address() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("wallet_name");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).expect("Failed to create wallet");
    let result = wallet.get_address(0, 0);
    assert!(result.is_ok(), "Failed to get address: {:?}", result.err());
    assert!(!result.unwrap().is_empty(), "Address is empty");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_is_deterministic() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("wallet_name");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).expect("Failed to create wallet");
    let result = wallet.is_deterministic();
    assert!(result.is_ok(), "Failed to check if wallet is deterministic: {:?}", result.err());
    assert!(result.unwrap(), "Wallet should be deterministic");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_wallet_creation_with_different_networks() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallets = vec![
        ("mainnet_wallet", NetworkType::Mainnet),
        ("testnet_wallet", NetworkType::Testnet),
        ("stagenet_wallet", NetworkType::Stagenet),
    ];

    for (name, net_type) in wallets {
        let wallet_path = temp_dir.path().join(name);
        let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

        let wallet = manager.create_wallet(wallet_str, "password", "English", net_type);
        assert!(wallet.is_ok(), "Failed to create wallet: {}", name);
    }

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_multiple_address_generation() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("wallet_name");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).expect("Failed to create wallet");

    for i in 0..5 {
        let result = wallet.get_address(0, i);
        assert!(result.is_ok(), "Failed to get address {}: {:?}", i, result.err());
        assert!(!result.unwrap().is_empty(), "Address {} is empty", i);
    }

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_wallet_error_display() {
    // Test WalletError::FfiError variant.
    let error = WalletError::FfiError("Test error".to_string());
    match error {
        WalletError::FfiError(msg) => assert_eq!(msg, "Test error"),
        _ => panic!("Expected FfiError variant"),
    }

    // Test WalletError::NullPointer variant.
    let error = WalletError::NullPointer;
    match error {
        WalletError::NullPointer => assert!(true),
        _ => panic!("Expected NullPointer variant"),
    }

    // Test WalletError::WalletErrorCode variant.
    let error = WalletError::WalletErrorCode(2, "Sample wallet error".to_string());
    match error {
        WalletError::WalletErrorCode(code, msg) => {
            assert_eq!(code, 2);
            assert_eq!(msg, "Sample wallet error");
        },
        _ => panic!("Expected WalletErrorCode variant"),
    }
}
