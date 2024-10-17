use monero_rust::{network, WalletError, WalletManager};

fn main() -> Result<(), WalletError> {
    let wallet_manager = WalletManager::new(None)?;

    let wallet = wallet_manager.create_wallet(
        "wallet_name",
        "password",
        "English",
        network::MAINNET,
    )?;

    println!("Wallet created successfully.");

    match wallet.get_seed("") {
        Ok(seed) => println!("Seed: {}", seed),
        Err(e) => eprintln!("Failed to get seed: {:?}", e),
    }

    match wallet.get_address(0, 0) {
        Ok(address) => println!("Primary address: {}", address),
        Err(e) => eprintln!("Failed to get address: {:?}", e),
    }

    Ok(())
}
