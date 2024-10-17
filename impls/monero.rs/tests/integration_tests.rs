use monero_c_rust::{WalletManager, NetworkType, WalletError, WalletResult};
use std::fs;
use std::sync::Arc;
use std::time::Instant;
use tempfile::TempDir;

const TEST_WALLET_NAMES: &[&str] = &[
    "test_wallet",
    "mainnet_wallet",
    "testnet_wallet",
    "stagenet_wallet",
];

/// Helper function to clean up existing wallet files in a temporary directory.
fn check_and_delete_existing_wallets(temp_dir: &TempDir) -> std::io::Result<()> {
    for name in TEST_WALLET_NAMES {
        // Construct absolute paths for wallet files.
        let wallet_file = temp_dir.path().join(name);
        let keys_file = temp_dir.path().join(format!("{}.keys", name));
        let address_file = temp_dir.path().join(format!("{}.address.txt", name)); // Added

        // Delete wallet file if it exists.
        if wallet_file.exists() {
            if let Err(e) = fs::remove_file(&wallet_file) {
                println!("Warning: Failed to delete wallet file {:?}: {}", wallet_file, e);
            } else {
                println!("Deleted existing wallet file: {:?}", wallet_file);
            }
        }

        // Delete keys file if it exists.
        if keys_file.exists() {
            if let Err(e) = fs::remove_file(&keys_file) {
                println!("Warning: Failed to delete keys file {:?}: {}", keys_file, e);
            } else {
                println!("Deleted existing keys file: {:?}", keys_file);
            }
        }

        // Delete address file if it exists.
        if address_file.exists() {
            if let Err(e) = fs::remove_file(&address_file) {
                println!("Warning: Failed to delete address file {:?}: {}", address_file, e);
            } else {
                println!("Deleted existing address file: {:?}", address_file);
            }
        }
    }
    Ok(())
}

/// Sets up the test environment by creating a temporary directory and initializing the WalletManager.
///
/// Returns:
/// - An `Arc` wrapped `WalletManager` instance.
/// - A `TempDir` representing the temporary directory.
fn setup() -> WalletResult<(Arc<WalletManager>, TempDir)> {
    println!("Setting up test environment...");
    let temp_dir = tempfile::tempdir().expect("Failed to create temporary directory");
    check_and_delete_existing_wallets(&temp_dir).expect("Failed to clean up existing wallets");

    println!("Creating WalletManager...");
    let start = Instant::now();
    let manager = WalletManager::new()?;
    println!("WalletManager creation took {:?}", start.elapsed());

    Ok((manager, temp_dir))
}

/// Tears down the test environment by deleting wallet files.
///
/// Args:
/// - `temp_dir`: Reference to the temporary directory.
///
/// Returns:
/// - `Result<(), std::io::Error>` indicating success or failure.
fn teardown(temp_dir: &TempDir) -> std::io::Result<()> {
    println!("Tearing down test environment...");
    check_and_delete_existing_wallets(temp_dir)
}

#[test]
fn test_wallet_manager_creation() {
    println!("Running test_wallet_manager_creation");
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    // Construct the full path for the wallet within temp_dir.
    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet_result = manager.create_wallet(wallet_str, "password123", "English", NetworkType::Mainnet);
    assert!(wallet_result.is_ok(), "WalletManager creation seems to have failed");

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
    println!("Running test_get_seed");
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    // Construct the full path for the wallet within temp_dir.
    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager
        .create_wallet(wallet_str, "password123", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    // Test getting seed without offset.
    println!("Attempting to get seed without offset...");
    let start = Instant::now();
    let result = wallet.get_seed(None);
    println!("get_seed without offset took {:?}", start.elapsed());
    assert!(result.is_ok(), "Failed to get seed: {:?}", result.err());
    assert!(!result.unwrap().is_empty(), "Seed is empty");

    // Test getting seed with an offset.
    println!("Attempting to get seed with offset...");
    let start = Instant::now();
    let result_with_offset = wallet.get_seed(Some("example_offset"));
    println!("get_seed with offset took {:?}", start.elapsed());
    assert!(result_with_offset.is_ok(), "Failed to get seed with offset: {:?}", result_with_offset.err());
    assert!(!result_with_offset.unwrap().is_empty(), "Seed with offset is empty");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_get_address() {
    println!("Running test_get_address");
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    // Construct the full path for the wallet within temp_dir.
    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager
        .create_wallet(wallet_str, "password123", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");
    println!("Attempting to get address...");
    let start = Instant::now();
    let result = wallet.get_address(0, 0);
    println!("get_address took {:?}", start.elapsed());
    assert!(result.is_ok(), "Failed to get address: {:?}", result.err());
    assert!(!result.unwrap().is_empty(), "Address is empty");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_is_deterministic() {
    println!("Running test_is_deterministic");
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    // Construct the full path for the wallet within temp_dir.
    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager
        .create_wallet(wallet_str, "password123", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");
    println!("Checking if wallet is deterministic...");
    let start = Instant::now();
    let result = wallet.is_deterministic();
    println!("is_deterministic check took {:?}", start.elapsed());
    assert!(result.is_ok(), "Failed to check if wallet is deterministic: {:?}", result.err());
    assert!(result.unwrap(), "Wallet should be deterministic");

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_wallet_creation_with_different_networks() {
    println!("Running test_wallet_creation_with_different_networks");
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    // Define wallet names and corresponding network types.
    let wallets = vec![
        ("mainnet_wallet", NetworkType::Mainnet),
        ("testnet_wallet", NetworkType::Testnet),
        ("stagenet_wallet", NetworkType::Stagenet),
    ];

    for (name, net_type) in wallets {
        println!("Creating wallet: {} on network type {:?}", name, net_type);

        // Construct the full path for each wallet within temp_dir.
        let wallet_path = temp_dir.path().join(name);
        let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

        let wallet = manager.create_wallet(wallet_str, "password", "English", net_type);
        assert!(wallet.is_ok(), "Failed to create wallet: {}", name);
    }

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_multiple_address_generation() {
    println!("Running test_multiple_address_generation");
    let (manager, temp_dir) = setup().expect("Failed to set up test environment");

    // Construct the full path for the wallet within temp_dir.
    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().expect("Failed to convert wallet path to string");

    let wallet = manager
        .create_wallet(wallet_str, "password123", "English", NetworkType::Mainnet)
        .expect("Failed to create wallet");

    for i in 0..5 {
        println!("Generating address {}...", i);
        let start = Instant::now();
        let result = wallet.get_address(0, i);
        println!("Address generation took {:?}", start.elapsed());
        assert!(result.is_ok(), "Failed to get address {}: {:?}", i, result.err());
        assert!(!result.unwrap().is_empty(), "Address {} is empty", i);
    }

    teardown(&temp_dir).expect("Failed to clean up after test");
}

#[test]
fn test_wallet_error_display() {
    println!("Running test_wallet_error_display");

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
