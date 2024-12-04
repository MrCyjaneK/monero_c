export const moneroSymbols = {
  MONERO_PendingTransaction_status: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_errorString: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_commit: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "bool"] as [
      pendingTx_ptr: "pointer",
      filename: "pointer",
      overwrite: "bool",
    ],
  },
  MONERO_PendingTransaction_commitUR: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      pendingTx_ptr: "pointer",
      max_fragment_length: "i32",
    ],
  },
  MONERO_PendingTransaction_amount: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_dust: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_fee: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_txid: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      pendingTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_PendingTransaction_txCount: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_subaddrAccount: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      pendingTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_PendingTransaction_subaddrIndices: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      pendingTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_PendingTransaction_multisigSignData: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_signMultisigTx: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      pendingTx_ptr: "pointer",
    ],
  },
  MONERO_PendingTransaction_signersKeys: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      pendingTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_PendingTransaction_hex: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      pendingTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_PendingTransaction_txKey: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      pendingTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_status: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      unsignedTx_ptr: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_errorString: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      unsignedTx_ptr: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_amount: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      unsignedTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_fee: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      unsignedTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_mixin: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      unsignedTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_confirmationMessage: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      unsignedTx_ptr: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_paymentId: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      unsignedTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_recipientAddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      unsignedTx_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_minMixinCount: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      unsignedTx_ptr: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_txCount: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      unsignedTx_ptr: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_sign: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      unsignedTx_ptr: "pointer",
      signedFileName: "pointer",
    ],
  },
  MONERO_UnsignedTransaction_signUR: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      unsignedTx_ptr: "pointer",
      max_fragment_length: "i32",
    ],
  },
  MONERO_TransactionInfo_direction: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_isPending: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_isFailed: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_isCoinbase: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_amount: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_fee: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_blockHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_description: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_subaddrIndex: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      txInfo_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_TransactionInfo_subaddrAccount: {
    nonblocking: true,
    result: "u32",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_label: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_confirmations: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_unlockTime: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_hash: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_timestamp: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_paymentId: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_transfers_count: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      txInfo_ptr: "pointer",
    ],
  },
  MONERO_TransactionInfo_transfers_amount: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer", "i32"] as [
      txInfo_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_TransactionInfo_transfers_address: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      txInfo_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_TransactionHistory_count: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      txHistory_ptr: "pointer",
    ],
  },
  MONERO_TransactionHistory_transaction: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      txHistory_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_TransactionHistory_transactionById: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      txHistory_ptr: "pointer",
      id: "pointer",
    ],
  },
  MONERO_TransactionHistory_refresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      txHistory_ptr: "pointer",
    ],
  },
  MONERO_TransactionHistory_setTxNote: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer", "pointer"] as [
      txHistory_ptr: "pointer",
      txid: "pointer",
      note: "pointer",
    ],
  },
  MONERO_AddressBookRow_extra: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      addressBookRow_ptr: "pointer",
    ],
  },
  MONERO_AddressBookRow_getAddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      addressBookRow_ptr: "pointer",
    ],
  },
  MONERO_AddressBookRow_getDescription: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      addressBookRow_ptr: "pointer",
    ],
  },
  MONERO_AddressBookRow_getPaymentId: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      addressBookRow_ptr: "pointer",
    ],
  },
  MONERO_AddressBookRow_getRowId: {
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      addressBookRow_ptr: "pointer",
    ],
  },
  MONERO_AddressBook_getAll_size: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      addressBook_ptr: "pointer",
    ],
  },
  MONERO_AddressBook_getAll_byIndex: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      addressBook_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_AddressBook_addRow: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "pointer", "pointer"] as [
      addressBook_ptr: "pointer",
      dst_addr: "pointer",
      payment_id: "pointer",
      description: "pointer",
    ],
  },
  MONERO_AddressBook_deleteRow: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "usize"] as [
      addressBook_ptr: "pointer",
      rowId: "usize",
    ],
  },
  MONERO_AddressBook_setDescription: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "usize", "pointer"] as [
      addressBook_ptr: "pointer",
      rowId: "usize",
      description: "pointer",
    ],
  },
  MONERO_AddressBook_refresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      addressBook_ptr: "pointer",
    ],
  },
  MONERO_AddressBook_errorString: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      addressBook_ptr: "pointer",
    ],
  },
  MONERO_AddressBook_errorCode: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      addressBook_ptr: "pointer",
    ],
  },
  MONERO_AddressBook_lookupPaymentID: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer", "pointer"] as [
      addressBook_ptr: "pointer",
      payment_id: "pointer",
    ],
  },
  MONERO_CoinsInfo_blockHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_hash: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_internalOutputIndex: {
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_globalOutputIndex: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_spent: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_frozen: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_spentHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_amount: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_rct: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_keyImageKnown: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_pkIndex: {
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_subaddrIndex: {
    nonblocking: true,
    result: "u32",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_subaddrAccount: {
    nonblocking: true,
    result: "u32",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_address: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_addressLabel: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_keyImage: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_unlockTime: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_unlocked: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_pubKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_coinbase: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_CoinsInfo_description: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      coinsInfo_ptr: "pointer",
    ],
  },
  MONERO_Coins_count: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      coins_ptr: "pointer",
    ],
  },
  MONERO_Coins_coin: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      coins_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_Coins_getAll_size: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      coins_ptr: "pointer",
    ],
  },
  MONERO_Coins_getAll_byIndex: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      coins_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_Coins_refresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      coins_ptr: "pointer",
    ],
  },
  MONERO_Coins_setFrozenByPublicKey: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer"] as [
      coins_ptr: "pointer",
      public_key: "pointer",
    ],
  },
  MONERO_Coins_setFrozen: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "i32"] as [
      coins_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_Coins_thaw: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "i32"] as [
      coins_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_Coins_thawByPublicKey: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer"] as [
      coins_ptr: "pointer",
      public_key: "pointer",
    ],
  },
  MONERO_Coins_isTransferUnlocked: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "u64", "u64"] as [
      coins_ptr: "pointer",
      unlockTime: "u64",
      blockHeight: "u64",
    ],
  },
  MONERO_Coins_setDescription: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer", "pointer"] as [
      coins_ptr: "pointer",
      public_key: "pointer",
      description: "pointer",
    ],
  },
  MONERO_SubaddressRow_extra: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressRow_getAddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressRow_getLabel: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressRow_getRowId: {
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      subaddressRow_ptr: "pointer",
    ],
  },
  MONERO_Subaddress_getAll_size: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      subaddress_ptr: "pointer",
    ],
  },
  MONERO_Subaddress_getAll_byIndex: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      subaddress_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_Subaddress_addRow: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32", "pointer"] as [
      subaddress_ptr: "pointer",
      accountIndex: "u32",
      label: "pointer",
    ],
  },
  MONERO_Subaddress_setLabel: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32", "u32", "pointer"] as [
      subaddress_ptr: "pointer",
      accountIndex: "u32",
      addressIndex: "u32",
      label: "pointer",
    ],
  },
  MONERO_Subaddress_refresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32"] as [
      subaddress_ptr: "pointer",
      accountIndex: "u32",
    ],
  },
  MONERO_SubaddressAccountRow_extra: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressAccountRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressAccountRow_getAddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressAccountRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressAccountRow_getLabel: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressAccountRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressAccountRow_getBalance: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressAccountRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressAccountRow_getUnlockedBalance: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      subaddressAccountRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressAccountRow_getRowId: {
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      subaddressAccountRow_ptr: "pointer",
    ],
  },
  MONERO_SubaddressAccount_getAll_size: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      subaddressAccount_ptr: "pointer",
    ],
  },
  MONERO_SubaddressAccount_getAll_byIndex: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      subaddressAccount_ptr: "pointer",
      index: "i32",
    ],
  },
  MONERO_SubaddressAccount_addRow: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer"] as [
      subaddressAccount_ptr: "pointer",
      label: "pointer",
    ],
  },
  MONERO_SubaddressAccount_setLabel: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32", "pointer"] as [
      subaddressAccount_ptr: "pointer",
      accountIndex: "u32",
      label: "pointer",
    ],
  },
  MONERO_SubaddressAccount_refresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      subaddressAccount_ptr: "pointer",
    ],
  },
  MONERO_MultisigState_isMultisig: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      multisigState_ptr: "pointer",
    ],
  },
  MONERO_MultisigState_isReady: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      multisigState_ptr: "pointer",
    ],
  },
  MONERO_MultisigState_threshold: {
    nonblocking: true,
    result: "u32",
    parameters: ["pointer"] as [
      multisigState_ptr: "pointer",
    ],
  },
  MONERO_MultisigState_total: {
    nonblocking: true,
    result: "u32",
    parameters: ["pointer"] as [
      multisigState_ptr: "pointer",
    ],
  },
  MONERO_DeviceProgress_progress: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      deviceProgress_ptr: "pointer",
    ],
  },
  MONERO_DeviceProgress_indeterminate: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      deviceProgress_ptr: "pointer",
    ],
  },
  MONERO_Wallet_seed: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      seed_offset: "pointer",
    ],
  },
  MONERO_Wallet_getSeedLanguage: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setSeedLanguage: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      arg: "pointer",
    ],
  },
  MONERO_Wallet_status: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_errorString: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setPassword: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      password: "pointer",
    ],
  },
  MONERO_Wallet_getPassword: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setDevicePin: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      pin: "pointer",
    ],
  },
  MONERO_Wallet_setDevicePassphrase: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      passphrase: "pointer",
    ],
  },
  MONERO_Wallet_address: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "u64", "u64"] as [
      wallet_ptr: "pointer",
      accountIndex: "u64",
      addressIndex: "u64",
    ],
  },
  MONERO_Wallet_path: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_nettype: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_integratedAddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      payment_id: "pointer",
    ],
  },
  MONERO_Wallet_secretViewKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_publicViewKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_secretSpendKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_publicSpendKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_publicMultisigSignerKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_stop: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_store: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      path: "pointer",
    ],
  },
  MONERO_Wallet_filename: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_keysFilename: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_init: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "u64", "pointer", "pointer", "bool", "bool", "pointer"] as [
      wallet_ptr: "pointer",
      daemon_address: "pointer",
      upper_transaction_size_limit: "u64",
      daemon_username: "pointer",
      daemon_password: "pointer",
      use_ssl: "bool",
      lightWallet: "bool",
      proxy_address: "pointer",
    ],
  },
  MONERO_Wallet_createWatchOnly: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      language: "pointer",
    ],
  },
  MONERO_Wallet_setRefreshFromBlockHeight: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u64"] as [
      wallet_ptr: "pointer",
      refresh_from_block_height: "u64",
    ],
  },
  MONERO_Wallet_getRefreshFromBlockHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setRecoveringFromSeed: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "bool"] as [
      wallet_ptr: "pointer",
      recoveringFromSeed: "bool",
    ],
  },
  MONERO_Wallet_setRecoveringFromDevice: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "bool"] as [
      wallet_ptr: "pointer",
      recoveringFromDevice: "bool",
    ],
  },
  MONERO_Wallet_setSubaddressLookahead: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32", "u32"] as [
      wallet_ptr: "pointer",
      major: "u32",
      minor: "u32",
    ],
  },
  MONERO_Wallet_connectToDaemon: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_connected: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setTrustedDaemon: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "bool"] as [
      wallet_ptr: "pointer",
      arg: "bool",
    ],
  },
  MONERO_Wallet_trustedDaemon: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setProxy: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      address: "pointer",
    ],
  },
  MONERO_Wallet_balance: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer", "u32"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
    ],
  },
  MONERO_Wallet_unlockedBalance: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer", "u32"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
    ],
  },
  MONERO_Wallet_viewOnlyBalance: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer", "u32"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
    ],
  },
  MONERO_Wallet_watchOnly: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_isDeterministic: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_blockChainHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_approximateBlockChainHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_estimateBlockChainHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_daemonBlockChainHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_daemonBlockChainTargetHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_synchronized: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_displayAmount: {
    nonblocking: true,
    result: "pointer",
    parameters: ["u64"] as [
      amount: "u64",
    ],
  },
  MONERO_Wallet_amountFromString: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      amount: "pointer",
    ],
  },
  MONERO_Wallet_amountFromDouble: {
    nonblocking: true,
    result: "u64",
    parameters: ["f64"] as [
      amount: "f64",
    ],
  },
  MONERO_Wallet_genPaymentId: {
    nonblocking: true,
    result: "pointer",
    parameters: [],
  },
  MONERO_Wallet_paymentIdValid: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      paiment_id: "pointer",
    ],
  },
  MONERO_Wallet_addressValid: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "i32"] as [
      str: "pointer",
      nettype: "i32",
    ],
  },
  MONERO_Wallet_keyValid: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "bool", "i32"] as [
      secret_key_string: "pointer",
      address_string: "pointer",
      isViewKey: "bool",
      nettype: "i32",
    ],
  },
  MONERO_Wallet_keyValid_error: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "bool", "i32"] as [
      secret_key_string: "pointer",
      address_string: "pointer",
      isViewKey: "bool",
      nettype: "i32",
    ],
  },
  MONERO_Wallet_paymentIdFromAddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "i32"] as [
      strarg: "pointer",
      nettype: "i32",
    ],
  },
  MONERO_Wallet_maximumAllowedAmount: {
    nonblocking: true,
    result: "u64",
    parameters: [],
  },
  MONERO_Wallet_init3: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer", "pointer", "pointer", "bool"] as [
      wallet_ptr: "pointer",
      argv0: "pointer",
      default_log_base_name: "pointer",
      log_path: "pointer",
      console: "bool",
    ],
  },
  MONERO_Wallet_getPolyseed: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      passphrase: "pointer",
    ],
  },
  MONERO_Wallet_createPolyseed: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      language: "pointer",
    ],
  },
  MONERO_Wallet_startRefresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_pauseRefresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_refresh: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_refreshAsync: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_rescanBlockchain: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_rescanBlockchainAsync: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setAutoRefreshInterval: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "i32"] as [
      wallet_ptr: "pointer",
      millis: "i32",
    ],
  },
  MONERO_Wallet_autoRefreshInterval: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_addSubaddressAccount: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      label: "pointer",
    ],
  },
  MONERO_Wallet_numSubaddressAccounts: {
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_numSubaddresses: {
    nonblocking: true,
    result: "usize",
    parameters: ["pointer", "u32"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
    ],
  },
  MONERO_Wallet_addSubaddress: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32", "pointer"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
      label: "pointer",
    ],
  },
  MONERO_Wallet_getSubaddressLabel: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "u32", "u32"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
      addressIndex: "u32",
    ],
  },
  MONERO_Wallet_setSubaddressLabel: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32", "u32", "pointer"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
      addressIndex: "u32",
      label: "pointer",
    ],
  },
  MONERO_Wallet_multisig: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getMultisigInfo: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_makeMultisig: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "u32"] as [
      wallet_ptr: "pointer",
      info: "pointer",
      info_separator: "pointer",
      threshold: "u32",
    ],
  },
  MONERO_Wallet_exchangeMultisigKeys: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "bool"] as [
      wallet_ptr: "pointer",
      info: "pointer",
      info_separator: "pointer",
      force_update_use_with_caution: "bool",
    ],
  },
  MONERO_Wallet_exportMultisigImages: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_Wallet_importMultisigImages: {
    optional: true,
    nonblocking: true,
    result: "usize",
    parameters: ["pointer", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      info: "pointer",
      info_separator: "pointer",
    ],
  },
  MONERO_Wallet_hasMultisigPartialKeyImages: {
    optional: true,
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_restoreMultisigTransaction: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      signData: "pointer",
    ],
  },
  MONERO_Wallet_createTransactionMultDest: {
    nonblocking: true,
    result: "pointer",
    parameters: [
      "pointer",
      "pointer",
      "pointer",
      "pointer",
      "bool",
      "pointer",
      "pointer",
      "u32",
      "i32",
      "u32",
      "pointer",
      "pointer",
    ] as [
      wallet_ptr: "pointer",
      dst_addr_list: "pointer",
      dst_addr_list_separator: "pointer",
      payment_id: "pointer",
      amount_sweep_all: "bool",
      amount_list: "pointer",
      amount_list_separator: "pointer",
      mixin_count: "u32",
      pendingTransactionPriority: "i32",
      subaddr_account: "u32",
      preferredInputs: "pointer",
      preferredInputs_separator: "pointer",
    ],
  },
  MONERO_Wallet_createTransaction: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "u64", "u32", "i32", "u32", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      dst_addr: "pointer",
      payment_id: "pointer",
      amount: "u64",
      mixin_count: "u32",
      pendingTransactionPriority: "i32",
      subaddr_account: "u32",
      preferredInputs: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_Wallet_loadUnsignedTx: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      fileName: "pointer",
    ],
  },
  MONERO_Wallet_loadUnsignedTxUR: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      input: "pointer",
    ],
  },
  MONERO_Wallet_submitTransaction: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      fileName: "pointer",
    ],
  },
  MONERO_Wallet_submitTransactionUR: {
    optional: true,
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      input: "pointer",
    ],
  },
  MONERO_Wallet_hasUnknownKeyImages: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_exportKeyImages: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "bool"] as [
      wallet_ptr: "pointer",
      filename: "pointer",
      all: "bool",
    ],
  },
  MONERO_Wallet_exportKeyImagesUR: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "usize", "bool"] as [
      wallet_ptr: "pointer",
      max_fragment_length: "usize",
      all: "bool",
    ],
  },
  MONERO_Wallet_importKeyImages: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      filename: "pointer",
    ],
  },
  MONERO_Wallet_importKeyImagesUR: {
    optional: true,
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      input: "pointer",
    ],
  },
  MONERO_Wallet_exportOutputs: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "bool"] as [
      wallet_ptr: "pointer",
      filename: "pointer",
      all: "bool",
    ],
  },
  MONERO_Wallet_exportOutputsUR: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "usize", "bool"] as [
      wallet_ptr: "pointer",
      max_fragment_length: "usize",
      all: "bool",
    ],
  },
  MONERO_Wallet_importOutputs: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      filename: "pointer",
    ],
  },
  MONERO_Wallet_importOutputsUR: {
    optional: true,
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      input: "pointer",
    ],
  },
  MONERO_Wallet_setupBackgroundSync: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "i32", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      background_sync_type: "i32",
      wallet_password: "pointer",
      background_cache_password: "pointer",
    ],
  },
  MONERO_Wallet_getBackgroundSyncType: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_startBackgroundSync: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_stopBackgroundSync: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      wallet_password: "pointer",
    ],
  },
  MONERO_Wallet_isBackgroundSyncing: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_isBackgroundWallet: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_history: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_addressBook: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_coins: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_subaddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_subaddressAccount: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_defaultMixin: {
    nonblocking: true,
    result: "u32",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setDefaultMixin: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u32"] as [
      wallet_ptr: "pointer",
      arg: "u32",
    ],
  },
  MONERO_Wallet_setCacheAttribute: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      key: "pointer",
      val: "pointer",
    ],
  },
  MONERO_Wallet_getCacheAttribute: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      key: "pointer",
    ],
  },
  MONERO_Wallet_setUserNote: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      txid: "pointer",
      note: "pointer",
    ],
  },
  MONERO_Wallet_getUserNote: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      txid: "pointer",
    ],
  },
  MONERO_Wallet_getTxKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer"] as [
      wallet_ptr: "pointer",
      txid: "pointer",
    ],
  },
  MONERO_Wallet_signMessage: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      message: "pointer",
      address: "pointer",
    ],
  },
  MONERO_Wallet_verifySignedMessage: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "pointer", "pointer"] as [
      wallet_ptr: "pointer",
      message: "pointer",
      address: "pointer",
      signature: "pointer",
    ],
  },
  MONERO_Wallet_rescanSpent: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setOffline: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "bool"] as [
      wallet_ptr: "pointer",
      offline: "bool",
    ],
  },
  MONERO_Wallet_isOffline: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_segregatePreForkOutputs: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "bool"] as [
      wallet_ptr: "pointer",
      segregate: "bool",
    ],
  },
  MONERO_Wallet_segregationHeight: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "u64"] as [
      wallet_ptr: "pointer",
      height: "u64",
    ],
  },
  MONERO_Wallet_keyReuseMitigation2: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "bool"] as [
      wallet_ptr: "pointer",
      mitigation: "bool",
    ],
  },
  MONERO_Wallet_lockKeysFile: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_unlockKeysFile: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_isKeysFileLocked: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getDeviceType: {
    nonblocking: true,
    result: "i32",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_coldKeyImageSync: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer", "u64", "u64"] as [
      wallet_ptr: "pointer",
      spent: "u64",
      unspent: "u64",
    ],
  },
  MONERO_Wallet_deviceShowAddress: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "u32", "u32"] as [
      wallet_ptr: "pointer",
      accountIndex: "u32",
      addressIndex: "u32",
    ],
  },
  MONERO_Wallet_reconnectDevice: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getBytesReceived: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getBytesSent: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getStateIsConnected: {
    optional: true,
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getSendToDevice: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getSendToDeviceLength: {
    optional: true,
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getReceivedFromDevice: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getReceivedFromDeviceLength: {
    optional: true,
    nonblocking: true,
    result: "usize",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getWaitsForDeviceSend: {
    optional: true,
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_getWaitsForDeviceReceive: {
    optional: true,
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_Wallet_setDeviceReceivedData: {
    optional: true,
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer", "usize"] as [
      wallet_ptr: "pointer",
      data: "pointer",
      len: "usize",
    ],
  },
  MONERO_Wallet_setDeviceSendData: {
    optional: true,
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer", "usize"] as [
      wallet_ptr: "pointer",
      data: "pointer",
      len: "usize",
    ],
  },
  MONERO_WalletManager_createWallet: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "pointer", "i32"] as [
      wm_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      language: "pointer",
      networkType: "i32",
    ],
  },
  MONERO_WalletManager_openWallet: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "i32"] as [
      wm_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      networkType: "i32",
    ],
  },
  MONERO_WalletManager_recoveryWallet: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "pointer", "i32", "u64", "u64", "pointer"] as [
      wm_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      mnemonic: "pointer",
      networkType: "i32",
      restoreHeight: "u64",
      kdfRounds: "u64",
      seedOffset: "pointer",
    ],
  },
  MONERO_WalletManager_createWalletFromKeys: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "pointer", "i32", "u64", "pointer", "pointer", "pointer", "u64"] as [
      wm_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      language: "pointer",
      nettype: "i32",
      restoreHeight: "u64",
      addressString: "pointer",
      viewKeyString: "pointer",
      spendKeyString: "pointer",
      kdf_rounds: "u64",
    ],
  },
  MONERO_WalletManager_createWalletFromDevice: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "i32", "pointer", "u64", "pointer", "pointer", "pointer", "u64"] as [
      wm_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      nettype: "i32",
      deviceName: "pointer",
      restoreHeight: "u64",
      subaddressLookahead: "pointer",
      viewKeyString: "pointer",
      spendKeyString: "pointer",
      kdf_rounds: "u64",
    ],
  },
  MONERO_WalletManager_createDeterministicWalletFromSpendKey: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "pointer", "i32", "u64", "pointer", "u64"] as [
      wm_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      language: "pointer",
      nettype: "i32",
      restoreHeight: "u64",
      spendKeyString: "pointer",
      kdf_rounds: "u64",
    ],
  },
  MONERO_WalletManager_createWalletFromPolyseed: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer", "i32", "pointer", "pointer", "bool", "u64", "u64"] as [
      wm_ptr: "pointer",
      path: "pointer",
      password: "pointer",
      nettype: "i32",
      mnemonic: "pointer",
      passphrase: "pointer",
      newWallet: "bool",
      restore_height: "u64",
      kdf_rounds: "u64",
    ],
  },
  MONERO_WalletManager_closeWallet: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "bool"] as [
      wm_ptr: "pointer",
      wallet_ptr: "pointer",
      store: "bool",
    ],
  },
  MONERO_WalletManager_walletExists: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wm_ptr: "pointer",
      path: "pointer",
    ],
  },
  MONERO_WalletManager_verifyWalletPassword: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "pointer", "bool", "u64"] as [
      wm_ptr: "pointer",
      keys_file_name: "pointer",
      password: "pointer",
      no_spend_key: "bool",
      kdf_rounds: "u64",
    ],
  },
  MONERO_WalletManager_queryWalletDevice: {
    optional: true,
    nonblocking: true,
    result: "i32",
    parameters: ["pointer", "pointer", "pointer", "u64"] as [
      wm_ptr: "pointer",
      keys_file_name: "pointer",
      password: "pointer",
      kdf_rounds: "u64",
    ],
  },
  MONERO_WalletManager_findWallets: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "pointer"] as [
      wm_ptr: "pointer",
      path: "pointer",
      separator: "pointer",
    ],
  },
  MONERO_WalletManager_errorString: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wm_ptr: "pointer",
    ],
  },
  MONERO_WalletManager_setDaemonAddress: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer", "pointer"] as [
      wm_ptr: "pointer",
      address: "pointer",
    ],
  },
  MONERO_WalletManager_setProxy: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wm_ptr: "pointer",
      address: "pointer",
    ],
  },
  MONERO_WalletManager_blockchainHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wm_ptr: "pointer",
    ],
  },
  MONERO_WalletManager_blockchainTargetHeight: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wm_ptr: "pointer",
    ],
  },
  MONERO_WalletManager_networkDifficulty: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wm_ptr: "pointer",
    ],
  },
  MONERO_WalletManager_miningHashRate: {
    nonblocking: true,
    result: "f64",
    parameters: ["pointer"] as [
      wm_ptr: "pointer",
    ],
  },
  MONERO_WalletManager_blockTarget: {
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      wm_ptr: "pointer",
    ],
  },
  MONERO_WalletManager_isMining: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wm_ptr: "pointer",
    ],
  },
  MONERO_WalletManager_startMining: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer", "u32", "bool", "bool"] as [
      wm_ptr: "pointer",
      address: "pointer",
      threads: "u32",
      backgroundMining: "bool",
      ignoreBattery: "bool",
    ],
  },
  MONERO_WalletManager_stopMining: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer", "pointer"] as [
      wm_ptr: "pointer",
      address: "pointer",
    ],
  },
  MONERO_WalletManager_resolveOpenAlias: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer", "pointer", "bool"] as [
      wm_ptr: "pointer",
      address: "pointer",
      dnssec_valid: "bool",
    ],
  },
  MONERO_WalletManagerFactory_getWalletManager: {
    nonblocking: true,
    result: "pointer",
    parameters: [],
  },
  MONERO_WalletManagerFactory_setLogLevel: {
    nonblocking: true,
    result: "void",
    parameters: ["i32"] as [
      level: "i32",
    ],
  },
  MONERO_WalletManagerFactory_setLogCategories: {
    optional: true,
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      categories: "pointer",
    ],
  },
  MONERO_DEBUG_test0: {
    nonblocking: true,
    result: "void",
    parameters: [],
  },
  MONERO_DEBUG_test1: {
    nonblocking: true,
    result: "bool",
    parameters: ["bool"] as [
      x: "bool",
    ],
  },
  MONERO_DEBUG_test2: {
    nonblocking: true,
    result: "i32",
    parameters: ["i32"] as [
      x: "i32",
    ],
  },
  MONERO_DEBUG_test3: {
    nonblocking: true,
    result: "u64",
    parameters: ["u64"] as [
      x: "u64",
    ],
  },
  MONERO_DEBUG_test4: {
    nonblocking: true,
    result: "pointer",
    parameters: ["u64"] as [
      x: "u64",
    ],
  },
  MONERO_DEBUG_test5: {
    nonblocking: true,
    result: "pointer",
    parameters: [],
  },
  MONERO_DEBUG_test5_std: {
    nonblocking: true,
    result: "pointer",
    parameters: [],
  },
  MONERO_DEBUG_isPointerNull: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_cw_getWalletListener: {
    nonblocking: true,
    result: "pointer",
    parameters: ["pointer"] as [
      wallet_ptr: "pointer",
    ],
  },
  MONERO_cw_WalletListener_resetNeedToRefresh: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      cw_walletListener_ptr: "pointer",
    ],
  },
  MONERO_cw_WalletListener_isNeedToRefresh: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      cw_walletListener_ptr: "pointer",
    ],
  },
  MONERO_cw_WalletListener_isNewTransactionExist: {
    nonblocking: true,
    result: "bool",
    parameters: ["pointer"] as [
      cw_walletListener_ptr: "pointer",
    ],
  },
  MONERO_cw_WalletListener_resetIsNewTransactionExist: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      cw_walletListener_ptr: "pointer",
    ],
  },
  MONERO_cw_WalletListener_height: {
    optional: true,
    nonblocking: true,
    result: "u64",
    parameters: ["pointer"] as [
      cw_walletListener_ptr: "pointer",
    ],
  },
  MONERO_checksum_wallet2_api_c_h: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: [],
  },
  MONERO_checksum_wallet2_api_c_cpp: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: [],
  },
  MONERO_checksum_wallet2_api_c_exp: {
    optional: true,
    nonblocking: true,
    result: "pointer",
    parameters: [],
  },
  MONERO_free: {
    nonblocking: true,
    result: "void",
    parameters: ["pointer"] as [
      ptr: "pointer",
    ],
  },
} as const;

export type MoneroSymbols = typeof moneroSymbols;

type ReplaceMonero<T extends string> = T extends `MONERO${infer Y}` ? `WOWNERO${Y}` : never;
export type WowneroSymbols = { [Key in keyof MoneroSymbols as ReplaceMonero<Key>]: MoneroSymbols[Key] };

export type SymbolName = keyof MoneroSymbols extends `MONERO_${infer SymbolName}` ? SymbolName : never;

export const wowneroSymbols = Object.fromEntries(
  Object.entries(moneroSymbols).map(([key, value]) => [key.replace("MONERO", "WOWNERO"), value]),
) as WowneroSymbols;
