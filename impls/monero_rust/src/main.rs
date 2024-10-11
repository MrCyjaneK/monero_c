use monero_rust::{
    WalletError, WalletManager, NETWORK_TYPE_MAINNET,
};

fn main() -> Result<(), WalletError> {
    let wallet_manager = WalletManager::new()?;

    let wallet = wallet_manager.create_wallet(
        "wallet",
        "password",
        "English",
        NETWORK_TYPE_MAINNET,
    )?;

    match wallet.get_seed("") {
        Ok(seed) => println!("Seed: {}", seed),
        Err(e) => {
            eprintln!("Failed to get seed: {:?}", e);
            return Err(e);
        }
    }

    let address = wallet.get_address(0, 0)?;
    println!("Wallet Address: {}", address);

    Ok(())
}
