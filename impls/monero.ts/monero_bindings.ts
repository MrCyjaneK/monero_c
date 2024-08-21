import { Wallet } from "./wallet.ts";
import { WalletManager } from "./wallet_manager.ts";
import { platform } from 'node:process';

const libPath = () => {
  if (platform == 'win32') return 'monero_libwallet2_api_c.dll'
  // ios missing, if you ever happen to run this on iOS
  //  1) seek help
  //  2) return
  //     2.1) if compliant with app store - MoneroWallet.framework/MoneroWallet
  //     2.2) if hacked around 'monero_libwallet2_api_c.dylib'
  if (platform == 'darwin') return './monero_libwallet2_api_c.dylib'
  if (platform == 'android') return 'libmonero_libwallet2_api_c.so'
  return 'monero_libwallet2_api_c.so'
};

export const dylib = Deno.dlopen(libPath(), {
  "MONERO_WalletManagerFactory_getWalletManager": {
    nonblocking: true,
    parameters: [],
    // void*
    result: "pointer",
  },

  //#region WalletManager
  "MONERO_WalletManager_createWallet": {
    nonblocking: true,
    // void* wm_ptr, const char* path, const char* password, const char* language, int networkType
    parameters: ["pointer", "pointer", "pointer", "pointer", "i32"],
    // void*
    result: "pointer",
  },
  "MONERO_WalletManager_openWallet": {
    nonblocking: true,
    // void* wm_ptr, const char* path, const char* password, int networkType
    "parameters": ["pointer", "pointer", "pointer", "i32"],
    // void*
    result: "pointer",
  },
  "MONERO_WalletManager_recoveryWallet": {
    nonblocking: true,
    // void* wm_ptr, const char* path, const char* password, const char* mnemonic, int networkType, uint64_t restoreHeight, uint64_t kdfRounds, const char* seedOffset
    parameters: ["pointer", "pointer", "pointer", "pointer", "i32", "u64", "u64", "pointer"],
    // void*
    result: "pointer",
  },
  //#endregion

  //#region Wallet
  "MONERO_Wallet_address": {
    nonblocking: true,
    // void* wallet_ptr, uint64_t accountIndex, uint64_t addressIndex
    parameters: ["pointer", "u64", "u64"],
    // char*
    result: "pointer",
  },
  "MONERO_Wallet_balance": {
    nonblocking: true,
    // void* wallet_ptr, uint32_t accountIndex
    parameters: ["pointer", "u32"],
    // uint64_t
    result: "u64",
  },
  "MONERO_Wallet_status": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // int
    result: "i32",
  },
  "MONERO_Wallet_errorString": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // char*
    result: "pointer",
  },
  "MONERO_Wallet_blockChainHeight": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_Wallet_daemonBlockChainHeight": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  //#endregion
});

if (import.meta.main) {
  let option: string | null = null;
  while (option !== "o" && option !== "c") {
    const message = option
      ? "Your option has to be either (c)reate or (o)pen"
      : "Do you want to (c)reate or (o)pen a wallet?";
    option = prompt(message);
  }

  const path = prompt("Wallet path:");
  if (!path) throw "You have to set path";
  const absolutePath = import.meta.resolve(path).replace("file://", "");

  const password = prompt("Password:");
  if (!password) throw "You have to choose password";

  const walletManager = await WalletManager.new();
  const wallet = option === "c"
    ? await Wallet.create(walletManager, absolutePath, password)
    : await Wallet.open(walletManager, absolutePath, password);

  const error = await wallet.error();
  if (error) throw error;

  const address = await wallet.address();

  if (address !== null) {
    console.log("Your address is:", address);
  }
}

if (import.meta.main) {
  let option: string | null = null;
  while (option !== "o" && option !== "c") {
    const message = option
      ? "Your option has to be either (c)reate or (o)pen"
      : "Do you want to (c)reate or (o)pen a wallet?";
    option = prompt(message);
  }

  const path = prompt("Wallet path:");
  if (!path) throw "You have to set path";
  const absolutePath = import.meta.resolve(path).replace("file://", "");

  const password = prompt("Password:");
  if (!password) throw "You have to choose password";

  const walletManager = await WalletManager.new();
  const wallet = option === "c"
    ? await Wallet.create(walletManager, absolutePath, password)
    : await Wallet.open(walletManager, absolutePath, password);

  const error = await wallet.error();
  if (error) throw error;

  const address = await wallet.address();

  if (address !== null) {
    console.log("Your address is:", address);
  }
}

if (import.meta.main) {
  let option: string | null = null;
  while (option !== "o" && option !== "c") {
    const message = option
      ? "Your option has to be either (c)reate or (o)pen"
      : "Do you want to (c)reate or (o)pen a wallet?";
    option = prompt(message);
  }

  const path = prompt("Wallet path:");
  if (!path) throw "You have to set path";
  const absolutePath = import.meta.resolve(path).replace("file://", "");

  const password = prompt("Password:");
  if (!password) throw "You have to choose password";

  const walletManager = await WalletManager.new();
  const wallet = option === "c"
    ? await Wallet.create(walletManager, absolutePath, password)
    : await Wallet.open(walletManager, absolutePath, password);

  const error = await wallet.error();
  if (error) throw error;

  const address = await wallet.address();

  if (address !== null) {
    console.log("Your address is:", address);
  }
}
