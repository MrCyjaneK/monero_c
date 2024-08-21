import { exit, platform } from "node:process";
import { moneroChecksum } from "./checksum_monero.ts";
const libPath = () => {
  if (platform == 'win32') return './lib/monero_libwallet2_api_c.dll'
  // ios missing, if you ever happen to run this on iOS
  //  1) seek help
  //  2) return
  //     2.1) if compliant with app store - MoneroWallet.framework/MoneroWallet
  //     2.2) if hacked around 'monero_libwallet2_api_c.dylib'
  if (platform == 'darwin') return './lib/monero_libwallet2_api_c.dylib'
  if (platform == 'android') return './lib/libmonero_libwallet2_api_c.so'
  return './lib/monero_libwallet2_api_c.so'
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
  "MONERO_checksum_wallet2_api_c_h": {
    parameters: [],
    result: "pointer"
  },
  "MONERO_checksum_wallet2_api_c_cpp": {
    parameters: [],
    result: "pointer"
  },
  "MONERO_checksum_wallet2_api_c_exp": {
    parameters: [],
    result: "pointer"
  }
  //#endregion
});

if (import.meta.main) {
  const hashHcpp = new Deno.UnsafePointerView(dylib.symbols.MONERO_checksum_wallet2_api_c_h()!).getCString();
  const hashHts = moneroChecksum.wallet2_api_c_h_sha256;
  const hashCPPcpp = new Deno.UnsafePointerView(dylib.symbols.MONERO_checksum_wallet2_api_c_cpp()!).getCString();
  const hashCPPts = moneroChecksum.wallet2_api_c_cpp_sha256;
  const hashEXPcpp = new Deno.UnsafePointerView(dylib.symbols.MONERO_checksum_wallet2_api_c_exp()!).getCString();
  const hashEXPts = moneroChecksum.wallet2_api_c_exp_sha256;
  let errCode = 0;
  if (hashHcpp == hashHts) {
    console.log("Header file check match")
  } else {
    console.log("ERR: Header file check mismatch")
    errCode++;
  }
  if (hashCPPcpp == hashCPPts) {
    console.log("CPP source file check match")
  } else {
    console.log(`ERR: CPP source file check mismatch ${hashCPPcpp} == ${hashCPPts}`)
    errCode++;
  }
  if (hashEXPcpp == hashEXPts) {
    console.log("EXP file check match")
  } else {
    if (platform != "darwin") {
      console.log("WARN: EXP source file check mismatch")
    } else {
      console.log(`ERR: EXP source file check mismatch ${hashEXPcpp} == ${hashEXPts}`)
    }
    errCode++;
  }
  exit(errCode);
}