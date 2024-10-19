use std::ffi::{CStr, CString};
use std::os::raw::{c_int, c_void};
use std::ptr::NonNull;
use std::sync::Arc;

pub mod bindings;
pub use bindings::WalletStatus_Ok;
pub use bindings::WalletStatus_Error;
pub use bindings::WalletStatus_Critical;

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

#[derive(Debug)]
pub struct Account {
    pub index: u32,
    pub label: String,
    pub balance: u64,
    pub unlocked_balance: u64,
}

#[derive(Debug)]
pub struct GetAccounts {
    pub accounts: Vec<Account>,
}

pub struct Wallet {
    pub ptr: NonNull<c_void>,
    pub manager: Arc<WalletManager>,
    pub is_closed: bool, // New field to track if the wallet is closed
}

pub struct WalletManager {
    ptr: NonNull<c_void>,
}

/// Configuration parameters for initializing a wallet.
#[derive(Debug, Clone)]
pub struct WalletConfig {
    pub daemon_address: String,
    pub upper_transaction_size_limit: u64,
    pub daemon_username: String,
    pub daemon_password: String,
    pub use_ssl: bool,
    pub light_wallet: bool,
    pub proxy_address: String,
}

impl Default for WalletConfig {
    fn default() -> Self {
        WalletConfig {
            daemon_address: "localhost:18081".to_string(),
            upper_transaction_size_limit: 10000, // TODO set sane value.
            daemon_username: "".to_string(),
            daemon_password: "".to_string(),
            use_ssl: false,
            light_wallet: false,
            proxy_address: "".to_string(),
        }
    }
}

pub type BlockHeight = u64;

#[derive(Debug)]
pub struct Refreshed;

/// Represents a destination address and the amount to send.
#[derive(Debug, Clone)]
pub struct Destination {
    /// The recipient's address.
    pub address: String,
    /// The amount to send to the recipient (in atomic units).
    pub amount: u64,
}

/// Represents the result of a transfer operation.
#[derive(Debug)]
pub struct Transfer {
    /// The transaction ID of the transfer.
    pub txid: String,
    /// The transaction key, if requested.
    pub tx_key: Option<String>,
    /// The total amount sent in the transfer.
    pub amount: u64,
    /// The fee associated with the transfer.
    pub fee: u64,
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

    /// Check the status of a wallet to ensure it's in a valid state.
    ///
    /// # Example
    ///
    /// ```rust
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use tempfile::TempDir;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    /// assert!(wallet_result.is_ok(), "Failed to create wallet: {:?}", wallet_result.err());
    /// let wallet = wallet_result.unwrap();
    ///
    /// // Check the status of the wallet, expecting OK
    /// let status_result = manager.get_status(wallet.ptr.as_ptr());
    /// assert!(status_result.is_ok(), "Failed to get status: {:?}", status_result.err());
    /// assert_eq!(status_result.unwrap(), (), "Expected status to be OK");
    ///
    /// // Clean up wallet files.
    /// std::fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// std::fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn get_status(&self, wallet_ptr: *mut c_void) -> WalletResult<()> {
        if wallet_ptr.is_null() {
            return Err(WalletError::NullPointer);  // Ensure NullPointer is returned for null wallet
        }

        unsafe {
            let status = bindings::MONERO_Wallet_status(wallet_ptr);

            if status == bindings::WalletStatus_Ok {
                Ok(())
            } else {
                let error_ptr = bindings::MONERO_Wallet_errorString(wallet_ptr);
                let error_msg = if error_ptr.is_null() {
                    "Unknown error".to_string()
                } else {
                    CStr::from_ptr(error_ptr).to_string_lossy().into_owned()
                };
                Err(WalletError::WalletErrorCode(status, error_msg))
            }
        }
    }

    pub fn throw_if_error(&self, wallet_ptr: *mut c_void) -> WalletResult<()> {
        if wallet_ptr.is_null() {
            return Err(WalletError::NullPointer);
        }

        unsafe {
            let status = bindings::MONERO_Wallet_status(wallet_ptr);
            if status == bindings::WalletStatus_Ok {
                Ok(())
            } else {
                let error_ptr = bindings::MONERO_Wallet_errorString(wallet_ptr);
                let error_msg = if error_ptr.is_null() {
                    "Unknown error".to_string()
                } else {
                    CStr::from_ptr(error_ptr).to_string_lossy().into_owned()
                };
                Err(WalletError::WalletErrorCode(status, error_msg))
            }
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
    /// let wallet = manager.create_wallet("test_wallet", "password", "English", NetworkType::Mainnet);
    /// assert!(wallet.is_ok());
    ///
    /// // Cleanup: remove the wallet file and its corresponding keys file, if they exist.
    /// if Path::new("test_wallet").exists() {
    ///     fs::remove_file("test_wallet").expect("Failed to delete test wallet");
    /// }
    /// if Path::new("test_wallet.keys").exists() {
    ///     fs::remove_file("test_wallet.keys").expect("Failed to delete test wallet keys");
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

            self.throw_if_error(wallet_ptr)?;
            if wallet_ptr.is_null() {
                return Err(WalletError::NullPointer);
            }

            Ok(Wallet {
                ptr: NonNull::new(wallet_ptr).unwrap(),
                manager: Arc::clone(self),
                is_closed: false,
            })
        }
    }

    /// Opens an existing wallet with the provided path, password, and network type.
    ///
    /// # Example
    ///
    /// ```rust
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use tempfile::TempDir;
    /// use std::fs;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    ///
    /// // First, create a wallet to open later.
    /// let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    /// assert!(wallet_result.is_ok(), "Failed to create wallet: {:?}", wallet_result.err());
    /// let wallet = wallet_result.unwrap();
    ///
    /// // Close the wallet by dropping it.
    /// drop(wallet);
    ///
    /// // Now try to open the existing wallet.
    /// let open_result = manager.open_wallet(wallet_str, "password", NetworkType::Mainnet);
    /// assert!(open_result.is_ok(), "Failed to open wallet: {:?}", open_result.err());
    /// let opened_wallet = open_result.unwrap();
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn open_wallet(
        self: &Arc<Self>,
        path: &str,
        password: &str,
        network_type: NetworkType,
    ) -> WalletResult<Wallet> {
        let c_path = CString::new(path).map_err(|_| WalletError::FfiError("Invalid path".to_string()))?;
        let c_password = CString::new(password).map_err(|_| WalletError::FfiError("Invalid password".to_string()))?;

        unsafe {
            let wallet_ptr = bindings::MONERO_WalletManager_openWallet(
                self.ptr.as_ptr(),
                c_path.as_ptr(),
                c_password.as_ptr(),
                network_type.to_c_int(),
            );

            self.throw_if_error(wallet_ptr)?;
            if wallet_ptr.is_null() {
                Err(self.get_status(wallet_ptr).unwrap_err())
            } else {
                // Ensuring that we properly close the wallet when it's no longer needed
                let wallet = Wallet {
                    ptr: NonNull::new(wallet_ptr).unwrap(),
                    manager: Arc::clone(self),
                    is_closed: false,
                };
                Ok(wallet)
            }
        }
    }

    /// Retrieves the current blockchain height.
    ///
    /// This method communicates with the connected daemon to obtain the latest
    /// blockchain height. It returns a `BlockHeight` on success or a `WalletError` on failure.
    ///
    /// # Example
    ///
    /// ```rust
    /// use monero_c_rust::{WalletManager, NetworkType};
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let height = manager.get_height().unwrap();
    /// println!("Current blockchain height: {}", height);
    /// ```
    pub fn get_height(&self) -> WalletResult<BlockHeight> {
        unsafe {
            let height = bindings::MONERO_WalletManager_blockchainHeight(self.ptr.as_ptr());
            // Assuming the FFI call does not set an error, directly return the height.
            // If error handling is required, additional checks should be implemented here.
            Ok(height)
        }
    }
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
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    /// assert!(wallet_result.is_ok(), "Failed to create wallet: {:?}", wallet_result.err());
    /// let wallet = wallet_result.unwrap();
    ///
    /// // Get seed with no offset
    /// let seed = wallet.get_seed(None);
    /// assert!(seed.is_ok(), "Failed to get seed: {:?}", seed.err());
    /// let seed = seed.unwrap();
    /// assert!(!seed.is_empty(), "Seed should not be empty");
    ///
    /// // Get seed with an offset
    /// let seed_with_offset = wallet.get_seed(Some("offset"));
    /// assert!(seed_with_offset.is_ok(), "Failed to get seed with offset: {:?}", seed_with_offset.err());
    /// let seed_with_offset = seed_with_offset.unwrap();
    /// assert!(!seed_with_offset.is_empty(), "Seed with offset should not be empty");
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn get_seed(&self, seed_offset: Option<&str>) -> WalletResult<String> {
        let c_seed_offset = CString::new(seed_offset.unwrap_or(""))
            .map_err(|_| WalletError::FfiError("Invalid seed_offset".to_string()))?;

        unsafe {
            let seed_ptr = bindings::MONERO_Wallet_seed(self.ptr.as_ptr(), c_seed_offset.as_ptr());

            self.throw_if_error()?;
            if seed_ptr.is_null() {
                return Err(self.get_last_error());
            }

            let seed = CStr::from_ptr(seed_ptr).to_string_lossy().into_owned();
            if seed.is_empty() {
                return Err(WalletError::FfiError("Received empty seed".to_string()));
            }

            Ok(seed)
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
    /// let wallet_path = temp_dir.path().join("test_wallet");
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

            self.throw_if_error()?;
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
    /// let wallet_path = temp_dir.path().join("test_wallet");
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

            self.throw_if_error()?;
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

    /// Checks for any errors by inspecting the wallet status and throws an error if found.
    ///
    /// # Returns
    /// - `Ok(())` if no error is found.
    /// - `Err(WalletError)` if an error is encountered.
    pub fn throw_if_error(&self) -> WalletResult<()> {
        let status_result = self.manager.get_status(self.ptr.as_ptr());
        if status_result.is_err() {
            return status_result;  // Return the error if the status is not OK.
        }
        Ok(())
    }

    /// Retrieves the balance and unlocked balance for the given account index.
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::{WalletManager, NetworkType, WalletResult};
    /// use tempfile::TempDir;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let _wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).unwrap();
    ///
    /// let balance = _wallet.get_balance(0);
    /// assert!(balance.is_ok(), "Failed to get balance: {:?}", balance.err());
    ///
    /// // Clean up wallet files.
    /// std::fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// std::fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn get_balance(&self, account_index: u32) -> WalletResult<GetBalance> {
        unsafe {
            let balance = bindings::MONERO_Wallet_balance(self.ptr.as_ptr(), account_index);

            self.throw_if_error()?;
            let unlocked_balance = bindings::MONERO_Wallet_unlockedBalance(self.ptr.as_ptr(), account_index);

            self.throw_if_error()?;
            Ok(GetBalance { balance, unlocked_balance })
        }
    }

    /// Creates a new subaddress account with the given label.
    ///
    /// # Arguments
    ///
    /// * `label` - A string representing the label for the new subaddress account.
    ///
    /// # Returns
    ///
    /// * `WalletResult<()>` - `Ok(())` if the account was successfully created, or a `WalletError` if an error occurred.
    ///
    /// # Example
    ///
    /// ```
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use tempfile::TempDir;
    /// use std::fs;
    ///
    /// // Set up the test environment.
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// // Initialize the wallet manager and create a wallet.
    /// let manager = WalletManager::new().unwrap();
    /// let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    /// assert!(wallet_result.is_ok(), "Failed to create wallet: {:?}", wallet_result.err());
    /// let wallet = wallet_result.unwrap();
    ///
    /// // Create a new account with a label.
    /// let result = wallet.create_account("New Account");
    /// assert!(result.is_ok(), "Failed to create account: {:?}", result.err());
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn create_account(&self, label: &str) -> WalletResult<()> {
        let c_label = CString::new(label).map_err(|_| WalletError::FfiError("Invalid label".to_string()))?;

        unsafe {
            bindings::MONERO_Wallet_addSubaddressAccount(self.ptr.as_ptr(), c_label.as_ptr());
            self.throw_if_error()
        }
    }

    /// Retrieves all accounts associated with the wallet.
    ///
    /// # Example
    ///
    /// ```rust
    /// use monero_c_rust::{WalletManager, NetworkType};
    /// use tempfile::TempDir;
    /// use std::fs;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).expect("Failed to create wallet");
    ///
    /// // Initially, there should be one account (the primary account).
    /// let initial_accounts = wallet.get_accounts().expect("Failed to retrieve accounts");
    /// assert_eq!(initial_accounts.accounts.len(), 1, "Initial account count mismatch");
    /// assert_eq!(initial_accounts.accounts[0].label, "Primary account", "Expected primary account label");
    ///
    /// // Create additional accounts.
    /// wallet.create_account("Account 1").expect("Failed to create account 1");
    /// wallet.create_account("Account 2").expect("Failed to create account 2");
    ///
    /// // Retrieve all accounts again; we should have three now.
    /// let all_accounts = wallet.get_accounts().expect("Failed to retrieve all accounts");
    /// assert_eq!(all_accounts.accounts.len(), 3, "Expected 3 accounts after creation");
    ///
    /// // Verify the labels of the accounts.
    /// assert_eq!(all_accounts.accounts[0].label, "Primary account", "First account should be the primary account");
    /// assert_eq!(all_accounts.accounts[1].label, "Account 1", "Second account should be 'Account 1'");
    /// assert_eq!(all_accounts.accounts[2].label, "Account 2", "Third account should be 'Account 2'");
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn get_accounts(&self) -> WalletResult<GetAccounts> {
        unsafe {
            let accounts_size = bindings::MONERO_Wallet_numSubaddressAccounts(self.ptr.as_ptr());
            self.throw_if_error()?;

            let mut accounts = Vec::new();

            for i in 0..accounts_size as u32 {
                let label_ptr = bindings::MONERO_Wallet_getSubaddressLabel(self.ptr.as_ptr(), i, 0);
                let label = if label_ptr.is_null() {
                    "Unnamed".to_string()
                } else {
                    CStr::from_ptr(label_ptr).to_string_lossy().into_owned()
                };

                let balance = bindings::MONERO_Wallet_balance(self.ptr.as_ptr(), i);
                let unlocked_balance = bindings::MONERO_Wallet_unlockedBalance(self.ptr.as_ptr(), i);

                accounts.push(Account {
                    index: i,
                    label,
                    balance,
                    unlocked_balance,
                });
            }

            Ok(GetAccounts { accounts })
        }
    }

    /// Closes the wallet, releasing any resources associated with it.
    ///
    /// After calling this method, the `Wallet` instance should no longer be used.
    ///
    /// # Returns
    ///
    /// * `WalletResult<()>` - Returns `Ok(())` if the wallet was successfully closed,
    ///   or a `WalletError` if an error occurred during closing.
    ///
    /// # Example
    ///
    /// ```rust
    /// use monero_c_rust::{WalletManager, NetworkType, WalletResult};
    /// use tempfile::TempDir;
    /// use std::fs;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let mut wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).unwrap();
    ///
    /// // Use the wallet for operations...
    ///
    /// // Now close the wallet
    /// let close_result = wallet.close_wallet();
    /// assert!(close_result.is_ok(), "Failed to close wallet: {:?}", close_result.err());
    ///
    /// // Clean up wallet files.
    /// fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    /// fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// ```
    pub fn close_wallet(&mut self) -> WalletResult<()> {
        if self.is_closed {
            return Ok(());
        }
        unsafe {
            let result = bindings::MONERO_WalletManager_closeWallet(
                self.manager.ptr.as_ptr(),
                self.ptr.as_ptr(),
                false, // Don't save the wallet by default.
            );
            if result {
                self.is_closed = true;
                Ok(())
            } else {
                Err(WalletError::FfiError("Failed to close wallet".to_string()))
            }
        }
    }

    /// Initializes the wallet with the provided daemon settings.
    ///
    /// This method must be called after creating or opening a wallet to synchronize it
    /// with the daemon and prepare it for operations like refreshing.
    ///
    /// # Arguments
    ///
    /// * `config` - An `WalletConfig` struct containing daemon settings.
    ///
    /// # Example
    ///
    /// ```rust
    /// use monero_c_rust::{WalletManager, NetworkType, WalletConfig};
    /// use tempfile::TempDir;
    ///
    /// let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    /// let wallet_path = temp_dir.path().join("test_wallet");
    /// let wallet_str = wallet_path.to_str().unwrap();
    ///
    /// let manager = WalletManager::new().unwrap();
    /// let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
    ///     .expect("Failed to create wallet");
    ///
    /// let config = WalletConfig {
    ///     daemon_address: "http://localhost:18081".to_string(),
    ///     upper_transaction_size_limit: 10000,
    ///     daemon_username: "user".to_string(),
    ///     daemon_password: "pass".to_string(),
    ///     use_ssl: false,
    ///     light_wallet: false,
    ///     proxy_address: "".to_string(),
    /// };
    ///
    /// let init_result = wallet.init(config);
    /// assert!(init_result.is_ok(), "Failed to initialize wallet: {:?}", init_result.err());
    /// ```
    pub fn init(&self, config: WalletConfig) -> WalletResult<()> {
        let c_daemon_address = CString::new(config.daemon_address)
            .map_err(|_| WalletError::FfiError("Invalid daemon address".to_string()))?;
        let c_daemon_username = CString::new(config.daemon_username)
            .map_err(|_| WalletError::FfiError("Invalid daemon username".to_string()))?;
        let c_daemon_password = CString::new(config.daemon_password)
            .map_err(|_| WalletError::FfiError("Invalid daemon password".to_string()))?;
        let c_proxy_address = CString::new(config.proxy_address)
            .map_err(|_| WalletError::FfiError("Invalid proxy address".to_string()))?;

        unsafe {
            let result = bindings::MONERO_Wallet_init(
                self.ptr.as_ptr(),
                c_daemon_address.as_ptr(),
                config.upper_transaction_size_limit,
                c_daemon_username.as_ptr(),
                c_daemon_password.as_ptr(),
                config.use_ssl,
                config.light_wallet,
                c_proxy_address.as_ptr(),
            );

            if result {
                Ok(())
            } else {
                // Retrieve the last error from the wallet
                Err(self.get_last_error())
            }
        }
    }

    /// Refreshes the wallet's state by synchronizing it with the blockchain.
    ///
    /// This method communicates with the connected daemon to update the wallet's
    /// balance, transaction history, and other relevant data. It ensures that the
    /// wallet remains up-to-date with the latest blockchain state.
    ///
    /// # Example
    ///
    /// ```rust
    /// use monero_c_rust::{WalletManager, NetworkType, WalletConfig};
    /// use std::fs;
    /// use tempfile::TempDir;
    ///
    /// fn main() {
    ///     // Create a temporary directory for testing purposes.
    ///     let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    ///     let wallet_path = temp_dir.path().join("test_wallet");
    ///     let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");
    ///
    ///     // Initialize the WalletManager.
    ///     let manager = WalletManager::new().expect("Failed to create WalletManager");
    ///
    ///     // Create a new wallet.
    ///     let wallet = manager
    ///         .create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
    ///         .expect("Failed to create wallet");
    ///
    ///     // Define the wallet initialization configuration.
    ///     let config = WalletConfig {
    ///         daemon_address: "http://localhost:18081".to_string(),
    ///         upper_transaction_size_limit: 10000,
    ///         daemon_username: "user".to_string(),
    ///         daemon_password: "pass".to_string(),
    ///         use_ssl: false,
    ///         light_wallet: false,
    ///         proxy_address: "".to_string(),
    ///     };
    ///
    ///     // Initialize the wallet with the specified configuration.
    ///     let init_result = wallet.init(config);
    ///     assert!(init_result.is_ok(), "Failed to initialize wallet: {:?}", init_result.err());
    ///
    ///     // Perform a refresh operation after initialization.
    ///     let refresh_result = wallet.refresh();
    ///     assert!(refresh_result.is_ok(), "Failed to refresh wallet: {:?}", refresh_result.err());
    ///
    ///     // Optionally, you can verify the refresh by checking the blockchain height or other metrics.
    ///     // For example:
    ///     let height = manager.get_height().expect("Failed to get blockchain height");
    ///     println!("Current blockchain height: {}", height);
    ///
    ///     // Clean up wallet files.
    ///     fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    ///     fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");
    /// }
    /// ```
    pub fn refresh(&self) -> WalletResult<Refreshed> {
        unsafe {
            let result = bindings::MONERO_Wallet_refresh(self.ptr.as_ptr());

            if result {
                Ok(Refreshed)
            } else {
                // Retrieve the last error from the wallet
                Err(self.get_last_error())
            }
        }
    }

    /// Initiates a transfer from the wallet to the specified destinations.
    ///
    /// # Arguments
    ///
    /// * `account_index` - The index of the account to send funds from.
    /// * `destinations` - A vector of `Destination` specifying where to send funds and how much.
    /// * `get_tx_key` - A boolean indicating whether to retrieve the transaction key.
    ///
    /// # Returns
    ///
    /// * `WalletResult<Transfer>` - On success, returns a `Transfer` struct containing transaction details.
    ///   On failure, returns a `WalletError`.
    pub fn transfer(&self, account_index: u32, destinations: Vec<Destination>, get_tx_key: bool, sweep_all: bool) -> WalletResult<Transfer> {
        // Define separators
        let separator = ";";
        let separator_c = CString::new(separator).map_err(|_| WalletError::FfiError("Invalid separator".to_string()))?;

        // Concatenate destination addresses and amounts.
        let addresses: Vec<String> = destinations.iter().map(|d| d.address.clone()).collect();
        let address_list = addresses.join(separator);
        let c_address_list = CString::new(address_list).map_err(|_| WalletError::FfiError("Invalid address list".to_string()))?;

        let amounts: Vec<String> = destinations.iter().map(|d| d.amount.to_string()).collect();
        let amount_list = amounts.join(separator);
        let c_amount_list = CString::new(amount_list).map_err(|_| WalletError::FfiError("Invalid amount list".to_string()))?;

        // TODO: Payment IDs.
        let payment_id = CString::new("").map_err(|_| WalletError::FfiError("Invalid payment_id".to_string()))?;
        let mixin_count = 16;

        // Pending transaction priority - default to 0 (Default)
        let pending_tx_priority = bindings::Priority_Default;

        // Subaddress account
        let subaddr_account = account_index;

        // TODO: Preferred inputs.
        let c_preferred_inputs = CString::new("").map_err(|_| WalletError::FfiError("Invalid preferred inputs".to_string()))?;

        // Separator for preferred inputs
        let preferred_inputs_separator = CString::new("").map_err(|_| WalletError::FfiError("Invalid preferred inputs separator".to_string()))?;

        unsafe {
            // Create the transaction with multiple destinations.
            let tx_ptr = bindings::MONERO_Wallet_createTransactionMultDest(
                self.ptr.as_ptr(),
                c_address_list.as_ptr(),
                separator_c.as_ptr(),
                payment_id.as_ptr(),
                sweep_all,
                c_amount_list.as_ptr(),
                separator_c.as_ptr(),
                mixin_count,
                pending_tx_priority,
                subaddr_account,
                c_preferred_inputs.as_ptr(),
                preferred_inputs_separator.as_ptr(),
            );

            // Check for errors.
            let ptr_as_mut_c_void = self.manager.ptr.as_ptr() as *mut c_void;
            self.manager.throw_if_error(ptr_as_mut_c_void)?;
            if tx_ptr.is_null() {
                return Err(WalletError::NullPointer);
            }

            // Get the transaction ID.
            let txid_ptr = bindings::MONERO_PendingTransaction_txid(tx_ptr, separator_c.as_ptr());
            if txid_ptr.is_null() {
                return Err(WalletError::FfiError("Failed to get transaction ID".to_string()));
            }
            let txid = CStr::from_ptr(txid_ptr).to_string_lossy().into_owned();

            // Get the fee.
            let fee = bindings::MONERO_PendingTransaction_fee(tx_ptr);

            // Optionally get the transaction key.
            let tx_key = if get_tx_key {
                let c_txid = CString::new(txid.clone()).map_err(|_| WalletError::FfiError("Invalid txid".to_string()))?;
                let tx_key_ptr = bindings::MONERO_Wallet_getTxKey(self.ptr.as_ptr(), c_txid.as_ptr());
                if tx_key_ptr.is_null() {
                    None
                } else {
                    Some(CStr::from_ptr(tx_key_ptr).to_string_lossy().into_owned())
                }
            } else {
                None
            };

            // Submit the transaction.
            //
            // TODO: Make submission optional.
            let tx_ptr_as_i8 = tx_ptr as *const i8;
            let submit_result = bindings::MONERO_Wallet_submitTransaction(
                self.ptr.as_ptr(),
                tx_ptr_as_i8,
            );
            if !submit_result {
                return Err(WalletError::FfiError("Failed to submit transaction".to_string()));
            }

            Ok(Transfer {
                txid,
                tx_key,
                amount: destinations.iter().map(|d| d.amount).sum(),
                fee,
            })
        }
    }

    // TODO docs.
    pub fn sweep_all(&self, account_index: u32, destination: Destination, get_tx_key: bool) -> WalletResult<Transfer> {
        // Convert the destination address to a CString.
        let c_address = CString::new(destination.address.clone()).map_err(|_| WalletError::FfiError("Invalid address".to_string()))?;

        // Placeholder values for fields not needed in sweep_all.
        let empty_separator = CString::new("").map_err(|_| WalletError::FfiError("Invalid separator".to_string()))?;
        let payment_id = CString::new("").map_err(|_| WalletError::FfiError("Invalid payment_id".to_string()))?;
        let mixin_count = 16;
        let pending_tx_priority = bindings::Priority_Default;
        let c_preferred_inputs = CString::new("").map_err(|_| WalletError::FfiError("Invalid preferred inputs".to_string()))?;
        let preferred_inputs_separator = CString::new("").map_err(|_| WalletError::FfiError("Invalid preferred inputs separator".to_string()))?;

        unsafe {
            // Create the sweep transaction.
            let tx_ptr = bindings::MONERO_Wallet_createTransactionMultDest(
                self.ptr.as_ptr(),
                c_address.as_ptr(),
                empty_separator.as_ptr(),
                payment_id.as_ptr(),
                true, // Sweep all funds.
                empty_separator.as_ptr(),
                empty_separator.as_ptr(),
                mixin_count,
                pending_tx_priority,
                account_index,
                c_preferred_inputs.as_ptr(),
                preferred_inputs_separator.as_ptr(),
            );

            // Check for errors.
            let ptr_as_mut_c_void = self.manager.ptr.as_ptr() as *mut c_void;
            self.manager.throw_if_error(ptr_as_mut_c_void)?;
            if tx_ptr.is_null() {
                return Err(WalletError::NullPointer);
            }

            // Get the transaction ID.
            let txid_ptr = bindings::MONERO_PendingTransaction_txid(tx_ptr, empty_separator.as_ptr());
            if txid_ptr.is_null() {
                return Err(WalletError::FfiError("Failed to get transaction ID".to_string()));
            }
            let txid = CStr::from_ptr(txid_ptr).to_string_lossy().into_owned();

            // Get the fee.
            let fee = bindings::MONERO_PendingTransaction_fee(tx_ptr);

            // Optionally get the transaction key.
            let tx_key = if get_tx_key {
                let c_txid = CString::new(txid.clone()).map_err(|_| WalletError::FfiError("Invalid txid".to_string()))?;
                let tx_key_ptr = bindings::MONERO_Wallet_getTxKey(self.ptr.as_ptr(), c_txid.as_ptr());
                if tx_key_ptr.is_null() {
                    None
                } else {
                    Some(CStr::from_ptr(tx_key_ptr).to_string_lossy().into_owned())
                }
            } else {
                None
            };

            // Submit the transaction.
            //
            // TODO: Make submission optional.
            let tx_ptr_as_i8 = tx_ptr as *const i8;
            let submit_result = bindings::MONERO_Wallet_submitTransaction(
                self.ptr.as_ptr(),
                tx_ptr_as_i8,
            );
            if !submit_result {
                return Err(WalletError::FfiError("Failed to submit sweep transaction".to_string()));
            }

            Ok(Transfer {
                txid,
                tx_key,
                amount: 0, // Since it's sweeping all, amount is not predefined.
                fee,
            })
        }
    }
}

#[derive(Debug)]
pub struct GetBalance {
    pub balance: u64,
    pub unlocked_balance: u64,
}

impl Drop for Wallet {
    fn drop(&mut self) {
        if !self.is_closed {
            let _ = self.close_wallet();
        }
    }
}

#[cfg(test)]
use tempfile::TempDir;
#[cfg(test)]
use std::fs;

#[cfg(test)]
fn check_and_delete_existing_wallets(temp_dir: &TempDir) -> std::io::Result<()> {
    let test_wallet_names = &["test_wallet", "mainnet_wallet", "testnet_wallet", "stagenet_wallet"];

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

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet_result = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet);
    assert!(wallet_result.is_ok(), "WalletManager creation failed");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_wallet_creation() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
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

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    // Create a new wallet.
    let wallet = manager
        .create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    // Test getting seed with no offset (None).
    let result = wallet.get_seed(None);
    assert!(result.is_ok(), "Failed to get seed without offset: {:?}", result.err());
    assert!(!result.unwrap().is_empty(), "Seed without offset is empty");

    // Test getting seed with a specific offset (Some("offset")).
    let result_with_offset = wallet.get_seed(Some("offset"));
    assert!(result_with_offset.is_ok(), "Failed to get seed with offset: {:?}", result_with_offset.err());
    assert!(!result_with_offset.unwrap().is_empty(), "Seed with offset is empty");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_get_address() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
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

    let wallet_path = temp_dir.path().join("test_wallet");
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

    let wallet_path = temp_dir.path().join("test_wallet");
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

#[test]
fn test_wallet_status() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    // Create a wallet to use for status checking
    let wallet = manager
        .create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    // Check the status of the wallet, expecting it to be OK
    let status_result = manager.get_status(wallet.ptr.as_ptr());
    assert!(status_result.is_ok(), "Failed to get status: {:?}", status_result.err());

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_open_wallet() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    // Create a wallet to be opened later
    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    // Drop the wallet so it can be opened later
    drop(wallet);

    // Try to open the wallet
    let open_result = manager.open_wallet(wallet_str, "password", NetworkType::Mainnet);
    assert!(open_result.is_ok(), "Failed to open wallet: {:?}", open_result.err());

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_get_balance() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).unwrap();

    let balance_result = wallet.get_balance(0);
    assert!(balance_result.is_ok(), "Failed to get balance: {:?}", balance_result.err());

    let _balance = balance_result.unwrap();
    // assert!(_balance.balance >= 0, "Balance should be non-negative");
    // assert!(_balance.unlocked_balance >= 0, "Unlocked balance should be non-negative");
    // These assertions are meaningless with the constraints of the type.

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_create_account() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    // Create a wallet.
    let wallet = manager
        .create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    // Create a new account.
    let result = wallet.create_account("Test Account");
    assert!(result.is_ok(), "Failed to create account: {:?}", result.err());

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_get_accounts() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet).expect("Failed to create wallet");

    // Add two accounts for testing
    wallet.create_account("Test Account 1").expect("Failed to create account 1");
    wallet.create_account("Test Account 2").expect("Failed to create account 2");

    // Retrieve all accounts
    let accounts = wallet.get_accounts().expect("Failed to retrieve accounts");
    assert_eq!(accounts.accounts.len(), 3); // Including the primary account

    // Check account names
    assert_eq!(accounts.accounts[0].label, "Primary account");
    assert_eq!(accounts.accounts[1].label, "Test Account 1");
    assert_eq!(accounts.accounts[2].label, "Test Account 2");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_close_wallet() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    // Create a wallet.
    let mut wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    // Close the wallet.
    let close_result = wallet.close_wallet();
    assert!(close_result.is_ok(), "Failed to close wallet: {:?}", close_result.err());

    // Attempt to close the wallet again.
    let close_again_result = wallet.close_wallet();
    assert!(close_again_result.is_ok(), "Failed to close wallet a second time: {:?}", close_again_result.err());

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_height_success() {
        let manager = WalletManager::new().unwrap();
        let height = manager.get_height().unwrap();
        // assert!(height > 0, "Blockchain height should be greater than 0");
        // The test should not assume network connectivity/any syncing progress, so:
        assert!(height == 0, "Blockchain height should be equal to 0");
    }
}

#[test]
fn test_init_success() {
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    // Create a wallet.
    let wallet = manager.create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    // Define initialization configuration.
    let config = WalletConfig {
        daemon_address: "http://localhost:18081".to_string(),
        upper_transaction_size_limit: 10000,
        daemon_username: "user".to_string(),
        daemon_password: "pass".to_string(),
        use_ssl: false,
        light_wallet: false,
        proxy_address: "".to_string(),
    };

    // Initialize the wallet.
    let init_result = wallet.init(config);
    assert!(init_result.is_ok(), "Failed to initialize wallet: {:?}", init_result.err());

    // Clean up wallet files.
    fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_refresh_success() {
    println!("Running test_refresh_success");
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    // Construct the full path for the wallet within temp_dir.
    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    // Create the wallet.
    let wallet = manager
        .create_wallet(wallet_str, "password", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");
    println!("Wallet created successfully.");

    // Define initialization configuration.
    let config = WalletConfig {
        daemon_address: "http://localhost:18081".to_string(),
        upper_transaction_size_limit: 10000,
        daemon_username: "user".to_string(),
        daemon_password: "pass".to_string(),
        use_ssl: false,
        light_wallet: false,
        proxy_address: "".to_string(),
    };

    // Perform the initialization.
    println!("Initializing the wallet...");
    let init_result = wallet.init(config);

    assert!(init_result.is_ok(), "Failed to initialize wallet: {:?}", init_result.err());

    // Perform a refresh operation after initialization.
    println!("Refreshing the wallet...");
    let refresh_result = wallet.refresh();
    assert!(refresh_result.is_ok(), "Failed to refresh wallet: {:?}", refresh_result.err());

    // Clean up wallet files.
    fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");

    teardown(&temp_dir).expect("Failed to clean up after test");
}
