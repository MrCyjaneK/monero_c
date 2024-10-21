use monero_c_rust::{NetworkType, WalletError, WalletManager};
use tempfile::TempDir;

fn main() -> Result<(), WalletError> {
    let manager = WalletManager::new()?;

    let temp_dir = TempDir::new().expect("Failed to create temporary directory");
    let wallet_path = temp_dir.path().join("test_wallet");
    let wallet_str = wallet_path.to_str().unwrap();

    let wallet = manager.restore_polyseed(
        wallet_str.to_string(),
        "password".to_string(),
        "capital chief route liar question fix clutch water outside pave hamster occur always learn license knife".to_string(),
        NetworkType::Mainnet,
        0, // Restore from the beginning of the blockchain.
        1, // Default KDF rounds.
        "".to_string(), // No seed offset.
        true, // Create a new wallet.
    );

    println!("Wallet created successfully.");

    // Print the primary address.
    println!("Primary address: {}", wallet?.get_address(0, 0)?);

    // Clean up the wallet.
    std::fs::remove_file(wallet_str).expect("Failed to delete test wallet");
    std::fs::remove_file(format!("{}.keys", wallet_str)).expect("Failed to delete test wallet keys");

    Ok(())
}
