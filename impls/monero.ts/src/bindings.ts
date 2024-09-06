let libPath: string;
switch (Deno.build.os) {
  case "darwin":
    libPath = "./lib/monero_libwallet2_api_c.dylib";
    break;
  case "android":
    libPath = "./lib/libmonero_libwallet2_api_c.so";
    break;
  case "windows":
    libPath = "./lib/monero_libwallet2_api_c.dll";
    break;
  default:
    libPath = "./lib/monero_libwallet2_api_c.so";
    break;
}

export const dylib = Deno.dlopen(libPath, {
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
    // void* wm_ptr, const char* path, const char* password, const char* mnemonic,
    // int networkType, uint64_t restoreHeight, uint64_t kdfRounds, const char* seedOffset
    parameters: ["pointer", "pointer", "pointer", "pointer", "i32", "u64", "u64", "pointer"],
    // void*
    result: "pointer",
  },
  "MONERO_WalletManager_blockchainHeight": {
    nonblocking: true,
    // void* wm_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_WalletManager_blockchainTargetHeight": {
    nonblocking: true,
    // void* wm_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_WalletManager_setDaemonAddress": {
    nonblocking: true,
    // void* wm_ptr, const char* address
    parameters: ["pointer", "pointer"],
    // void
    result: "void",
  },
  //#endregion

  //#region Wallet
  "MONERO_Wallet_init": {
    nonblocking: true,
    // void* wallet_ptr, const char* daemon_address, uint64_t upper_transaction_size_limit,
    // const char* daemon_username, const char* daemon_password, bool use_ssl, bool lightWallet,
    // const char* proxy_address
    parameters: ["pointer", "pointer", "u64", "pointer", "pointer", "bool", "bool", "pointer"],
    // bool
    result: "bool",
  },
  "MONERO_Wallet_init3": {
    nonblocking: true,
    // void* wallet_ptr, const char* argv0, const char* default_log_base_name,
    //  const char* log_path, bool console
    parameters: ["pointer", "pointer", "pointer", "pointer", "bool"],
    // void
    result: "void",
  },
  "MONERO_Wallet_setTrustedDaemon": {
    nonblocking: true,
    // void* wallet_ptr, bool arg
    parameters: ["pointer", "bool"],
    // void
    result: "void",
  },
  "MONERO_Wallet_startRefresh": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // void
    result: "void",
  },
  "MONERO_Wallet_refreshAsync": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // void
    result: "void",
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
  "MONERO_Wallet_synchronized": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // bool
    result: "bool",
  },
  "MONERO_Wallet_store": {
    nonblocking: true,
    // void* wallet_ptr, const char* path
    parameters: ["pointer", "pointer"],
    // bool
    result: "bool",
  },
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
  "MONERO_Wallet_unlockedBalance": {
    nonblocking: true,
    // void* wallet_ptr, uint32_t accountIndex
    parameters: ["pointer", "u32"],
    // uint64_t
    result: "u64",
  },
  "MONERO_Wallet_addSubaddressAccount": {
    nonblocking: true,
    // void* wallet_ptr, const char* label
    parameters: ["pointer", "pointer"],
    // void
    result: "void",
  },
  "MONERO_Wallet_numSubaddressAccounts": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // size_t
    result: "usize",
  },
  "MONERO_Wallet_addSubaddress": {
    nonblocking: true,
    // void* wallet_ptr, uint32_t accountIndex, const char* label
    parameters: ["pointer", "u32", "pointer"],
    // void
    result: "void",
  },
  "MONERO_Wallet_numSubaddresses": {
    nonblocking: true,
    // void* wallet_ptr, uint32_t accountIndex
    parameters: ["pointer", "u32"],
    // size_t
    result: "usize",
  },
  "MONERO_Wallet_getSubaddressLabel": {
    nonblocking: true,
    // void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex
    parameters: ["pointer", "u32", "u32"],
    // const char*
    result: "pointer",
  },
  "MONERO_Wallet_setSubaddressLabel": {
    nonblocking: true,
    // void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex, const char* label
    parameters: ["pointer", "u32", "u32", "pointer"],
    // void
    result: "void",
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
  "MONERO_Wallet_history": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // void*
    result: "pointer",
  },
  "MONERO_Wallet_createTransaction": {
    nonblocking: true,
    // void* wallet_ptr, const char* dst_addr, const char* payment_id
    // uint64_t amount, uint32_t mixin_count, int pendingTransactionPriority,
    // uint32_t subaddr_account, const char* preferredInputs, const char* separator
    parameters: ["pointer", "pointer", "pointer", "u64", "u32", "i32", "u32", "pointer", "pointer"],
    // void*
    result: "pointer",
  },
  "MONERO_Wallet_amountFromString": {
    nonblocking: true,
    // const char* amount
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  //#endregion

  //#region TransactionHistory
  "MONERO_TransactionHistory_count": {
    nonblocking: true,
    // void* txHistory_ptr
    parameters: ["pointer"],
    // int
    result: "i32",
  },
  "MONERO_TransactionHistory_transaction": {
    nonblocking: true,
    // void* txHistory_ptr, int index
    parameters: ["pointer", "i32"],
    // void*
    result: "pointer",
  },
  "MONERO_TransactionHistory_transactionById": {
    nonblocking: true,
    // void* txHistory_ptr, const char* id
    parameters: ["pointer", "pointer"],
    // void*
    result: "pointer",
  },
  "MONERO_TransactionHistory_refresh": {
    nonblocking: true,
    // void* txHistory_ptr
    parameters: ["pointer"],
    // void
    result: "void",
  },
  "MONERO_TransactionHistory_setTxNote": {
    nonblocking: true,
    // void* txHistory_ptr, const char* txid, const char* note
    parameters: ["pointer", "pointer", "pointer"],
    // void
    result: "void",
  },
  //#endregion

  //#region TransactionInfo
  "MONERO_TransactionInfo_direction": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // int
    result: "i32",
  },
  "MONERO_TransactionInfo_isPending": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // bool
    result: "bool",
  },
  "MONERO_TransactionInfo_isFailed": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // bool
    result: "bool",
  },
  "MONERO_TransactionInfo_isCoinbase": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // bool
    result: "bool",
  },
  "MONERO_TransactionInfo_amount": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_TransactionInfo_fee": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_TransactionInfo_blockHeight": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_TransactionInfo_description": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_TransactionInfo_subaddrIndex": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_TransactionInfo_subaddrAccount": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // uint32_t
    result: "u32",
  },
  "MONERO_TransactionInfo_label": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_TransactionInfo_confirmations": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_TransactionInfo_unlockTime": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_TransactionInfo_hash": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_TransactionInfo_timestamp": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_TransactionInfo_paymentId": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_TransactionInfo_transfers_count": {
    nonblocking: true,
    // void* txInfo_ptr
    parameters: ["pointer"],
    // int
    result: "i32",
  },
  "MONERO_TransactionInfo_transfers_amount": {
    nonblocking: true,
    // void* txInfo_ptr, int index
    parameters: ["pointer", "i32"],
    // uint64_t
    result: "u64",
  },
  "MONERO_TransactionInfo_transfers_address": {
    nonblocking: true,
    // void* txInfo_ptr, int index
    parameters: ["pointer", "i32"],
    // const char*
    result: "pointer",
  },
  //#endregion

  //#region PendingTransaction
  "MONERO_PendingTransaction_status": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // int
    result: "i32",
  },
  "MONERO_PendingTransaction_errorString": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_PendingTransaction_commit": {
    nonblocking: true,
    // void* pendingTx_ptr, const char* filename, bool overwrite
    parameters: ["pointer", "pointer", "bool"],
    // bool
    result: "bool",
  },
  "MONERO_PendingTransaction_commitUR": {
    nonblocking: true,
    // void* pendingTx_ptr, int max_fragment_length
    parameters: ["pointer", "i32"],
    // const char*
    result: "pointer",
  },
  "MONERO_PendingTransaction_amount": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_PendingTransaction_dust": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_PendingTransaction_fee": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_PendingTransaction_txid": {
    nonblocking: true,
    // void* pendingTx_ptr, const char* separator
    parameters: ["pointer", "pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_PendingTransaction_txCount": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // uint64_t
    result: "u64",
  },
  "MONERO_PendingTransaction_subaddrAccount": {
    nonblocking: true,
    // void* pendingTx_ptr, const char* separator
    parameters: ["pointer", "pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_PendingTransaction_subaddrIndices": {
    nonblocking: true,
    // void* pendingTx_ptr, const char* separator
    parameters: ["pointer", "pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_PendingTransaction_multisigSignData": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_PendingTransaction_signMultisigTx": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // void
    result: "void",
  },
  "MONERO_PendingTransaction_signersKeys": {
    nonblocking: true,
    // void* pendingTx_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_PendingTransaction_hex": {
    nonblocking: true,
    // void* pendingTx_ptr, const char* separator
    parameters: ["pointer", "pointer"],
    // const char*
    result: "pointer",
  },
  //#endregion

  //#region Checksum
  "MONERO_checksum_wallet2_api_c_h": {
    nonblocking: true,
    parameters: [],
    // const char*
    result: "pointer",
  },
  "MONERO_checksum_wallet2_api_c_cpp": {
    nonblocking: true,
    parameters: [],
    // const char*
    result: "pointer",
  },
  "MONERO_checksum_wallet2_api_c_exp": {
    nonblocking: true,
    parameters: [],
    // const char*
    result: "pointer",
  },
  //#endregion
});
