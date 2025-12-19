// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:ffi';

import 'package:beldex/beldex.dart' as beldex;
import 'package:beldex/src/wallet2.dart';

class beldex implements Wallet2 {
  @override
  Wallet2WalletManagerFactory walletManagerFactory() {
    return BeldexWalletManagerFactory();
  }
  
  @override
  int ffiAddress() => 0;
}

class BeldexAddressBook implements Wallet2AddressBook {
  BeldexAddressBook(this.addressBookPtr);

  final beldex.AddressBook addressBookPtr;
  
  @override
  bool addRow({required String dstAddr, required String paymentId, required String description}) {
    return beldex.AddressBook_addRow(addressBookPtr, dstAddr: dstAddr, paymentId: paymentId, description: description);
  }
  
  @override
  bool deleteRow({required int rowId}) {
    return beldex.AddressBook_deleteRow(addressBookPtr, rowId: rowId);
  }
  
  @override
  int errorCode() {
    return beldex.AddressBook_errorCode(addressBookPtr);
  }
  
  @override
  Wallet2AddressBookRow getAll_byIndex(int index) {
    final row = beldex.AddressBook_getAll_byIndex(addressBookPtr, index: index);
    return BeldexAddressBookRow(row);
  }
  
  @override
  int getAll_size() {
    return beldex.AddressBook_getAll_size(addressBookPtr);
  }
  
  @override
  int lookupPaymentID({required String paymentId}) {
    return beldex.AddressBook_lookupPaymentID(addressBookPtr, paymentId: paymentId);
  }
  
  @override
  void refresh() {
    beldex.AddressBook_refresh(addressBookPtr);
  }
  
  @override
  bool setDescription({required int rowId, required String description}) {
    return beldex.AddressBook_setDescription(addressBookPtr, rowId: rowId, description: description);
  }
  
  @override
  int ffiAddress() => addressBookPtr.address;
}

class BeldexAddressBookRow implements Wallet2AddressBookRow {
  BeldexAddressBookRow(this.addressBookRowPtr);

  final beldex.AddressBookRow addressBookRowPtr;
  
  @override
  String extra() {
    return beldex.AddressBookRow_extra(addressBookRowPtr);
  }
  
  @override
  String getAddress() {
    return beldex.AddressBookRow_getAddress(addressBookRowPtr);
  }
  
  @override
  String getDescription() {
    return beldex.AddressBookRow_getDescription(addressBookRowPtr);
  }
  
  @override
  String getPaymentId() {
    return beldex.AddressBookRow_getPaymentId(addressBookRowPtr);
  }
  
  @override
  int getRowId() {
    return beldex.AddressBookRow_getRowId(addressBookRowPtr);
  }

  @override
  int ffiAddress() => addressBookRowPtr.address;
}

class BeldexCoins implements Wallet2Coins {
  BeldexCoins(this.coinsPtr);

  final beldex.Coins coinsPtr;
  
  @override
  Wallet2CoinsInfo coin(int index) {
    final coin = beldex.Coins_coin(coinsPtr, index);
    return BeldexCoinsInfo(coin);
  }
  
  @override
  int count() {
    return beldex.Coins_count(coinsPtr);
  }
  
  @override
  Wallet2CoinsInfo getAll_byIndex(int index) {
    final coin = beldex.Coins_getAll_byIndex(coinsPtr, index);
    return BeldexCoinsInfo(coin);
  }
  
  @override
  int getAll_size() {
    return beldex.Coins_getAll_size(coinsPtr);
  }
  
  @override
  bool isTransferUnlocked({required int unlockTime, required int blockHeight}) {
    return beldex.Coins_isTransferUnlocked(coinsPtr, unlockTime: unlockTime, blockHeight: blockHeight);
  }
  
  @override
  void refresh() {
    beldex.Coins_refresh(coinsPtr);
  }
  
  @override
  void setFrozen({required int index}) {
    beldex.Coins_setFrozen(coinsPtr, index: index);
  }
  
  @override
  void setFrozenByPublicKey({required String publicKey}) {
    beldex.Coins_setFrozenByPublicKey(coinsPtr, publicKey: publicKey);
  }
  
  @override
  void thaw({required int index}) {
    beldex.Coins_thaw(coinsPtr, index: index);
  }
  
  @override
  void thawByPublicKey({required String publicKey}) {
    beldex.Coins_thawByPublicKey(coinsPtr, publicKey: publicKey);
  }

  @override
  int ffiAddress() => coinsPtr.address;
}

class BeldexCoinsInfo implements Wallet2CoinsInfo {
  BeldexCoinsInfo(this.coinsInfoPtr);

  final beldex.CoinsInfo coinsInfoPtr;
  
  @override
  String address() {
    return beldex.CoinsInfo_address(coinsInfoPtr);
  }
  
  @override
  String addressLabel() {
    return beldex.CoinsInfo_addressLabel(coinsInfoPtr);
  }
  
  @override
  int amount() {
    return beldex.CoinsInfo_amount(coinsInfoPtr);
  }
  
  @override
  int blockHeight() {
    return beldex.CoinsInfo_blockHeight(coinsInfoPtr);
  }
  
  @override
  bool coinbase() {
    return beldex.CoinsInfo_coinbase(coinsInfoPtr);
  }
  
  @override
  String description() {
    return beldex.CoinsInfo_description(coinsInfoPtr);
  }
  
  @override
  bool frozen() {
    return beldex.CoinsInfo_frozen(coinsInfoPtr);
  }
  
  @override
  int globalOutputIndex() {
    return beldex.CoinsInfo_globalOutputIndex(coinsInfoPtr);
  }
  
  @override
  String hash() {
    return beldex.CoinsInfo_hash(coinsInfoPtr);
  }
  
  @override
  int internalOutputIndex() {
    return beldex.CoinsInfo_internalOutputIndex(coinsInfoPtr);
  }
  
  @override
  String keyImage() {
    return beldex.CoinsInfo_keyImage(coinsInfoPtr);
  }
  
  @override
  bool keyImageKnown() {
    return beldex.CoinsInfo_keyImageKnown(coinsInfoPtr);
  }
  
  @override
  int pkIndex() {
    return beldex.CoinsInfo_pkIndex(coinsInfoPtr);
  }
  
  @override
  String pubKey() {
    return beldex.CoinsInfo_pubKey(coinsInfoPtr);
  }
  
  @override
  bool rct() {
    return beldex.CoinsInfo_rct(coinsInfoPtr);
  }
  
  @override
  bool spent() {
    return beldex.CoinsInfo_spent(coinsInfoPtr);
  }
  
  @override
  int spentHeight() {
    return beldex.CoinsInfo_spentHeight(coinsInfoPtr);
  }
  
  @override
  int subaddrAccount() {
    return beldex.CoinsInfo_subaddrAccount(coinsInfoPtr);
  }
  
  @override
  int subaddrIndex() {
    return beldex.CoinsInfo_subaddrIndex(coinsInfoPtr);
  }
  
  @override
  int unlockTime() {
    return beldex.CoinsInfo_unlockTime(coinsInfoPtr);
  }
  
  @override
  bool unlocked() {
    return beldex.CoinsInfo_unlocked(coinsInfoPtr);
  }

  @override
  int ffiAddress() => coinsInfoPtr.address;
}

class BeldexDeviceProgress implements Wallet2DeviceProgress {
  BeldexDeviceProgress(this.deviceProgressPtr);

  final beldex.DeviceProgress deviceProgressPtr;
  
  @override
  bool indeterminate() {
    return beldex.DeviceProgress_indeterminate(deviceProgressPtr);
  }
  
  @override
  bool progress() {
    return beldex.DeviceProgress_progress(deviceProgressPtr);
  }

  @override
  int ffiAddress() => deviceProgressPtr.address;
}

class BeldexWalletListener implements Wallet2WalletListener {
  BeldexWalletListener(this.walletListenerPtr);

  final beldex.WalletListener walletListenerPtr;
  
  @override
  int height() {
    return beldex.BELDEX_cw_WalletListener_height(walletListenerPtr);
  }
  
  @override
  bool isNeedToRefresh() {
    return beldex.BELDEX_cw_WalletListener_isNeedToRefresh(walletListenerPtr);
  }
  
  @override
  bool isNewTransactionExist() {
    return beldex.BELDEX_cw_WalletListener_isNewTransactionExist(walletListenerPtr);
  }
  
  @override
  void resetIsNewTransactionExist() {
    beldex.BELDEX_cw_WalletListener_resetIsNewTransactionExist(walletListenerPtr);
  }
  
  @override
  void resetNeedToRefresh() {
    beldex.BELDEX_cw_WalletListener_resetNeedToRefresh(walletListenerPtr);
  }

  @override
  int ffiAddress() => walletListenerPtr.address;
}

class BeldexWalletChecksum implements Wallet2Checksum {
  BeldexWalletChecksum();

  @override
  String checksum_wallet2_api_c_cpp() {
    return beldex.BELDEX_checksum_wallet2_api_c_cpp();
  }
  
  @override
  String checksum_wallet2_api_c_exp() {
    return beldex.BELDEX_checksum_wallet2_api_c_exp();
  }
  
  @override
  String checksum_wallet2_api_c_h() {
    return beldex.BELDEX_checksum_wallet2_api_c_h();
  }

  @override
  int ffiAddress() => 0;
}

class BeldexFree implements Wallet2Free {
  BeldexFree();

  @override
  void free(Pointer<Void> ptr) {
    beldex.BELDEX_free(ptr);
  }

  @override
  int ffiAddress() => 0;
}

class BeldexMultisigState implements Wallet2MultisigState {
  BeldexMultisigState(this.multisigStatePtr);

  final beldex.MultisigState multisigStatePtr;
  
  @override
  bool isMultisig(Pointer<Void> ptr) {
    return beldex.MultisigState_isMultisig(multisigStatePtr);
  }
  
  @override
  bool isReady(Pointer<Void> ptr) {
    return beldex.MultisigState_isReady(multisigStatePtr);
  }
  
  @override
  int threshold(Pointer<Void> ptr) {
    return beldex.MultisigState_threshold(multisigStatePtr);
  }
  
  @override
  int total(Pointer<Void> ptr) {
    return beldex.MultisigState_total(multisigStatePtr);
  }

  @override
  int ffiAddress() => multisigStatePtr.address;
}

class BeldexPendingTransaction implements Wallet2PendingTransaction {
  BeldexPendingTransaction(this.pendingTransactionPtr);

  final beldex.PendingTransaction pendingTransactionPtr;
  
  @override
  int amount() {
    return beldex.PendingTransaction_amount(pendingTransactionPtr);
  }
  
  @override
  bool commit({required String filename, required bool overwrite}) {
    return beldex.PendingTransaction_commit(pendingTransactionPtr, filename: filename, overwrite: overwrite);
  }
  
  @override
  String commitUR(int max_fragment_length) {
    return beldex.PendingTransaction_commitUR(pendingTransactionPtr, max_fragment_length);
  }
  
  @override
  int dust() {
    return beldex.PendingTransaction_dust(pendingTransactionPtr);
  }
  
  @override
  String errorString() {
    return beldex.PendingTransaction_errorString(pendingTransactionPtr);
  }
  
  @override
  int fee() {
    return beldex.PendingTransaction_fee(pendingTransactionPtr);
  }
  
  @override
  String hex(String separator) {
    return beldex.PendingTransaction_hex(pendingTransactionPtr, separator);
  }
  
  @override
  String multisigSignData() {
    return beldex.PendingTransaction_multisigSignData(pendingTransactionPtr);
  }
  
  @override
  void signMultisigTx() {
    beldex.PendingTransaction_signMultisigTx(pendingTransactionPtr);
  }
  
  @override
  String signersKeys(String separator) {
    return beldex.PendingTransaction_signersKeys(pendingTransactionPtr, separator);
  }
  
  @override
  int status() {
    return beldex.PendingTransaction_status(pendingTransactionPtr);
  }
  
  @override
  String subaddrAccount(String separator) {
    return beldex.PendingTransaction_subaddrAccount(pendingTransactionPtr, separator);
  }
  
  @override
  String subaddrIndices(String separator) {
    return beldex.PendingTransaction_subaddrIndices(pendingTransactionPtr, separator);
  }
  
  @override
  int txCount() {
    return beldex.PendingTransaction_txCount(pendingTransactionPtr);
  }
  
  @override
  String txid(String separator) {
    return beldex.PendingTransaction_txid(pendingTransactionPtr, separator);
  }

  @override
  int ffiAddress() => pendingTransactionPtr.address;
}

class BeldexSubaddress implements Wallet2Subaddress {
  BeldexSubaddress(this.subaddressPtr);

  final beldex.Subaddress subaddressPtr;
  
  @override
  void addRow({required int accountIndex, required String label}) {
    beldex.Subaddress_addRow(subaddressPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  Wallet2SubaddressRow getAll_byIndex(int index) {
    final row = beldex.Subaddress_getAll_byIndex(subaddressPtr, index: index);
    return BeldexSubaddressRow(row);
  }
  
  @override
  int getAll_size() {
    return beldex.Subaddress_getAll_size(subaddressPtr);
  }
  
  @override
  void refresh({required int accountIndex, required String label}) {
    beldex.Subaddress_refresh(subaddressPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  void setLabel({required int accountIndex, required int addressIndex, required String label}) {
    beldex.Subaddress_setLabel(subaddressPtr, accountIndex: accountIndex, addressIndex: addressIndex, label: label);
  }

  @override
  int ffiAddress() => subaddressPtr.address;
}

class BeldexSubaddressAccount implements Wallet2SubaddressAccount {
  BeldexSubaddressAccount(this.subaddressAccountPtr);

  final beldex.SubaddressAccount subaddressAccountPtr;
  
  @override
  void addRow({required String label}) {
    beldex.SubaddressAccount_addRow(subaddressAccountPtr, label: label);
  }
  
  @override
  Wallet2SubaddressAccountRow getAll_byIndex(int index) {
    final row = beldex.SubaddressAccount_getAll_byIndex(subaddressAccountPtr, index: index);
    return BeldexSubaddressAccountRow(row);
  }
  
  @override
  int getAll_size() {
    return beldex.SubaddressAccount_getAll_size(subaddressAccountPtr);
  }
  
  @override
  void refresh() {
    beldex.SubaddressAccount_refresh(subaddressAccountPtr);
  }
  
  @override
  void setLabel({required int accountIndex, required String label}) {
    beldex.SubaddressAccount_setLabel(subaddressAccountPtr, accountIndex: accountIndex, label: label);
  }

  @override
  int ffiAddress() => subaddressAccountPtr.address;
}

class BeldexSubaddressAccountRow implements Wallet2SubaddressAccountRow {
  BeldexSubaddressAccountRow(this.subaddressAccountRowPtr);

  final beldex.SubaddressAccountRow subaddressAccountRowPtr;
  
  @override
  String extra() {
    return beldex.SubaddressAccountRow_extra(subaddressAccountRowPtr);
  }
  
  @override
  String getAddress() {
    return beldex.SubaddressAccountRow_getAddress(subaddressAccountRowPtr);
  }
  
  @override
  String getBalance() {
    return beldex.SubaddressAccountRow_getBalance(subaddressAccountRowPtr);
  }
  
  @override
  String getLabel() {
    return beldex.SubaddressAccountRow_getLabel(subaddressAccountRowPtr);
  }
  
  @override
  int getRowId() {
    return beldex.SubaddressAccountRow_getRowId(subaddressAccountRowPtr);
  }
  
  @override
  String getUnlockedBalance() {
    return beldex.SubaddressAccountRow_getUnlockedBalance(subaddressAccountRowPtr);
  }

  @override
  int ffiAddress() => subaddressAccountRowPtr.address;
}

class BeldexSubaddressRow implements Wallet2SubaddressRow {
  BeldexSubaddressRow(this.subaddressRowPtr);

  final beldex.SubaddressRow subaddressRowPtr;
  
  @override
  String extra() {
    return beldex.SubaddressRow_extra(subaddressRowPtr);
  }
  
  @override
  String getAddress() {
    return beldex.SubaddressRow_getAddress(subaddressRowPtr);
  }
  
  @override
  String getLabel() {
    return beldex.SubaddressRow_getLabel(subaddressRowPtr);
  }
  
  @override
  int getRowId() {
    return beldex.SubaddressRow_getRowId(subaddressRowPtr);
  }

  @override
  int ffiAddress() => subaddressRowPtr.address;
}

class BeldexTransactionHistory implements Wallet2TransactionHistory {
  BeldexTransactionHistory(this.transactionHistoryPtr);

  final beldex.TransactionHistory transactionHistoryPtr;
  
  @override
  int count() {
    return beldex.TransactionHistory_count(transactionHistoryPtr);
  }
  
  @override
  void refresh() {
    beldex.TransactionHistory_refresh(transactionHistoryPtr);
  }
  
  @override
  void setTxNote({required String txid, required String note}) {
    beldex.TransactionHistory_setTxNote(transactionHistoryPtr, txid: txid, note: note);
  }
  
  @override
  Wallet2TransactionInfo transaction(int index) {
    final tx = beldex.TransactionHistory_transaction(transactionHistoryPtr, index: index);
    return BeldexTransactionInfo(tx);
  }
  
  @override
  Wallet2TransactionInfo transactionById(String txid) {
    final tx = beldex.TransactionHistory_transactionById(transactionHistoryPtr, txid: txid);
    return BeldexTransactionInfo(tx);
  }

  @override
  int ffiAddress() => transactionHistoryPtr.address;
}

class BeldexTransactionInfo implements Wallet2TransactionInfo {
  BeldexTransactionInfo(this.transactionInfoPtr);

  final beldex.TransactionInfo transactionInfoPtr;
  
  @override
  int amount() {
    return beldex.TransactionInfo_amount(transactionInfoPtr);
  }
  
  @override
  int blockHeight() {
    return beldex.TransactionInfo_blockHeight(transactionInfoPtr);
  }
  
  @override
  int confirmations() {
    return beldex.TransactionInfo_confirmations(transactionInfoPtr);
  }
  
  @override
  String description() {
    return beldex.TransactionInfo_description(transactionInfoPtr);
  }
  
  @override
  int direction() {
    return beldex.TransactionInfo_direction(transactionInfoPtr).index;
  }
  
  @override
  int fee() {
    return beldex.TransactionInfo_fee(transactionInfoPtr);
  }
  
  @override
  String hash() {
    return beldex.TransactionInfo_hash(transactionInfoPtr);
  }
  
  @override
  bool isCoinbase() {
    return beldex.TransactionInfo_isCoinbase(transactionInfoPtr);
  }
  
  @override
  bool isFailed() {
    return beldex.TransactionInfo_isFailed(transactionInfoPtr);
  }
  
  @override
  bool isPending() {
    return beldex.TransactionInfo_isPending(transactionInfoPtr);
  }
  
  @override
  String label() {
    return beldex.TransactionInfo_label(transactionInfoPtr);
  }
  
  @override
  String paymentId() {
    return beldex.TransactionInfo_paymentId(transactionInfoPtr);
  }
  
  @override
  int subaddrAccount() {
    return beldex.TransactionInfo_subaddrAccount(transactionInfoPtr);
  }
  
  @override
  String subaddrIndex() {
    return beldex.TransactionInfo_subaddrIndex(transactionInfoPtr);
  }
  
  @override
  int timestamp() {
    return beldex.TransactionInfo_timestamp(transactionInfoPtr);
  }
  
  @override
  String transfers_address(int index) {
    return beldex.TransactionInfo_transfers_address(transactionInfoPtr, index);
  }
  
  @override
  int transfers_amount(int index) {
    return beldex.TransactionInfo_transfers_amount(transactionInfoPtr, index);
  }
  
  @override
  int transfers_count() {
    return beldex.TransactionInfo_transfers_count(transactionInfoPtr);
  }
  
  @override
  int unlockTime() {
    return beldex.TransactionInfo_unlockTime(transactionInfoPtr);
  }
  
  @override
  int ffiAddress() => transactionInfoPtr.address;
}

class BeldexUnsignedTransaction implements Wallet2UnsignedTransaction {
  BeldexUnsignedTransaction(this.unsignedTransactionPtr);

  final beldex.UnsignedTransaction unsignedTransactionPtr;
  
  @override
  String amount() {
    return beldex.UnsignedTransaction_amount(unsignedTransactionPtr);
  }
  
  @override
  String confirmationMessage() {
    return beldex.UnsignedTransaction_confirmationMessage(unsignedTransactionPtr);
  }
  
  @override
  String errorString() {
    return beldex.UnsignedTransaction_errorString(unsignedTransactionPtr);
  }
  
  @override
  String fee() {
    return beldex.UnsignedTransaction_fee(unsignedTransactionPtr);
  }
  
  @override
  int minMixinCount() {
    return beldex.UnsignedTransaction_minMixinCount(unsignedTransactionPtr);
  }
  
  @override
  String mixin() {
    return beldex.UnsignedTransaction_mixin(unsignedTransactionPtr);
  }
  
  @override
  String paymentId() {
    return beldex.UnsignedTransaction_paymentId(unsignedTransactionPtr);
  }
  
  @override
  String recipientAddress() {
    return beldex.UnsignedTransaction_recipientAddress(unsignedTransactionPtr);
  }
  
  @override
  bool sign(String signedFileName) {
    return beldex.UnsignedTransaction_sign(unsignedTransactionPtr, signedFileName);
  }
  
  @override
  String signUR(int max_fragment_length) {
    return beldex.UnsignedTransaction_signUR(unsignedTransactionPtr, max_fragment_length);
  }
  
  @override
  int status() {
    return beldex.UnsignedTransaction_status(unsignedTransactionPtr);
  }
  
  @override
  int txCount() {
    return beldex.UnsignedTransaction_txCount(unsignedTransactionPtr);
  }
  
  @override
  int ffiAddress() => unsignedTransactionPtr.address;
}

class BeldexWallet implements Wallet2Wallet {
  BeldexWallet(this.walletPtr);

  final beldex.Wallet walletPtr;
  
  @override
  void addSubaddress({required int accountIndex, String label = ""}) {
    beldex.Wallet_addSubaddress(walletPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  void addSubaddressAccount({String label = ""}) {
    beldex.Wallet_addSubaddressAccount(walletPtr, label: label);
  }
  
  @override
  String address({int accountIndex = 0, int addressIndex = 0}) {
    return beldex.Wallet_address(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  Wallet2AddressBook addressBook() {
    return BeldexAddressBook(beldex.Wallet_addressBook(walletPtr));
  }
  
  @override
  bool addressValid(String address, int networkType) {
    return beldex.Wallet_addressValid(address, networkType);
  }
  
  @override
  int amountFromDouble(double amount) {
    return beldex.Wallet_amountFromDouble(amount);
  }
  
  @override
  int amountFromString(String amount) {
    return beldex.Wallet_amountFromString(amount);
  }
  
  @override
  int approximateBlockChainHeight() {
    return beldex.Wallet_approximateBlockChainHeight(walletPtr);
  }
  
  @override
  int autoRefreshInterval() {
    return beldex.Wallet_autoRefreshInterval(walletPtr);
  }
  
  @override
  int balance({required int accountIndex}) {
    return beldex.Wallet_balance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  int blockChainHeight() {
    return beldex.Wallet_blockChainHeight(walletPtr);
  }
  
  @override
  Wallet2Coins coins() {
    return BeldexCoins(beldex.Wallet_coins(walletPtr));
  }
  
  @override
  int coldKeyImageSync({required int spent, required int unspent}) {
    return beldex.Wallet_coldKeyImageSync(walletPtr, spent: spent, unspent: unspent);
  }
  
  @override
  bool connectToDaemon() {
    return beldex.Wallet_connectToDaemon(walletPtr);
  }
  
  @override
  int connected() {
    return beldex.Wallet_connected(walletPtr);
  }
  
  @override
  String createPolyseed({String language = "English"}) {
    return beldex.Wallet_createPolyseed(language: language);
  }
  
  @override
  Wallet2PendingTransaction createTransaction({required String dst_addr, required String payment_id, required int amount, required int mixin_count, required int pendingTransactionPriority, required int subaddr_account, List<String> preferredInputs = const []}) {
    final transaction = beldex.Wallet_createTransaction(walletPtr, dst_addr: dst_addr, payment_id: payment_id, amount: amount, mixin_count: mixin_count, pendingTransactionPriority: pendingTransactionPriority, subaddr_account: subaddr_account, preferredInputs: preferredInputs);
    return BeldexPendingTransaction(transaction);
  }
  
  @override
  Wallet2PendingTransaction createTransactionMultDest({required List<String> dstAddr, String paymentId = "", required bool isSweepAll, required List<int> amounts, required int mixinCount, required int pendingTransactionPriority, required int subaddr_account, List<String> preferredInputs = const []}) {
    final transaction = beldex.Wallet_createTransactionMultDest(walletPtr, dstAddr: dstAddr, paymentId: paymentId, isSweepAll: isSweepAll, amounts: amounts, mixinCount: mixinCount, pendingTransactionPriority: pendingTransactionPriority, subaddr_account: subaddr_account, preferredInputs: preferredInputs);
    return BeldexPendingTransaction(transaction);
  }
  
  @override
  bool createWatchOnly({required String path, required String password, required String language}) {
    return beldex.Wallet_createWatchOnly(walletPtr, path: path, password: password, language: language);
  }
  
  @override
  int daemonBlockChainHeight() {
    return beldex.Wallet_daemonBlockChainHeight(walletPtr);
  }
  
  @override
  int defaultMixin() {
    return beldex.Wallet_defaultMixin(walletPtr);
  }
  
  @override
  String deviceShowAddress({required int accountIndex, required int addressIndex}) {
    return beldex.Wallet_deviceShowAddress(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  String displayAmount(int amount) {
    return beldex.Wallet_displayAmount(amount);
  }
  
  @override
  String errorString() {
    return beldex.Wallet_errorString(walletPtr);
  }
  
  @override
  int estimateBlockChainHeight() {
    return beldex.Wallet_estimateBlockChainHeight(walletPtr);
  }
  
  @override
  String exchangeMultisigKeys({required List<String> info, required bool force_update_use_with_caution}) {
    return beldex.Wallet_exchangeMultisigKeys(walletPtr, info: info, force_update_use_with_caution: force_update_use_with_caution);
  }
  
  @override
  bool exportKeyImages(String filename, {required bool all}) {
    return beldex.Wallet_exportKeyImages(walletPtr, filename, all: all);
  }
  
  @override
  String exportKeyImagesUR({int max_fragment_length = 130, bool all = false}) {
    return beldex.Wallet_exportKeyImagesUR(walletPtr, max_fragment_length: max_fragment_length, all: all);
  }
  
  @override
  List<String> exportMultisigImages({required List<String> info}) {
    return beldex.Wallet_exportMultisigImages(walletPtr, info: info, force_update_use_with_caution: false);
  }
  
  @override
  bool exportOutputs(String filename, {required bool all}) {
    return beldex.Wallet_exportOutputs(walletPtr, filename, all: all);
  }
  
  @override
  String exportOutputsUR({int max_fragment_length = 130, bool all = false}) {
    return beldex.Wallet_exportOutputsUR(walletPtr, max_fragment_length: max_fragment_length, all: all);
  }
  
  @override
  String filename() {
    return beldex.Wallet_filename(walletPtr);
  }
  
  @override
  String genPaymentId() {
    return beldex.Wallet_genPaymentId();
  }
  
  @override
  int getBackgroundSyncType() {
    return beldex.Wallet_getBackgroundSyncType(walletPtr);
  }
  
  @override
  int getBytesReceived() {
    return beldex.Wallet_getBytesReceived(walletPtr);
  }
  
  @override
  int getBytesSent() {
    throw UnimplementedError();
  }
  
  @override
  String getCacheAttribute({required String key}) {
    return beldex.Wallet_getCacheAttribute(walletPtr, key: key);
  }
  
  @override
  int getDeviceType() {
    return beldex.Wallet_getDeviceType(walletPtr);
  }
  
  @override
  String getMultisigInfo() {
    return beldex.Wallet_getMultisigInfo(walletPtr);
  }
  
  @override
  String getPassword() {
    return beldex.Wallet_getPassword(walletPtr);
  }
  
  @override
  String getPolyseed({required String passphrase}) {
    return beldex.Wallet_getPolyseed(walletPtr, passphrase: passphrase);
  }
  
  static Pointer<UnsignedChar> getReceivedFromDevice() {
    return beldex.Wallet_getReceivedFromDevice();
  }
  
  static int getReceivedFromDeviceLength() {
    return beldex.Wallet_getReceivedFromDeviceLength();
  }
  
  @override
  int getRefreshFromBlockHeight() {
    return beldex.Wallet_getRefreshFromBlockHeight(walletPtr);
  }
  
  @override
  String getSeedLanguage() {
    return beldex.Wallet_getSeedLanguage(walletPtr);
  }

  static Pointer<UnsignedChar> getSendToDevice() {
    return beldex.Wallet_getSendToDevice();
  }
  
  static int getSendToDeviceLength() {
    return beldex.Wallet_getSendToDeviceLength();
  }
  
  static bool getStateIsConnected() {
    return beldex.Wallet_getStateIsConnected();
  }
  
  @override
  String getSubaddressLabel({required int accountIndex, required int addressIndex}) {
    return beldex.Wallet_getSubaddressLabel(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  String getTxKey({required String txid}) {
    return beldex.Wallet_getTxKey(walletPtr, txid: txid);
  }
  
  @override
  String getUserNote({required String txid}) {
    return beldex.Wallet_getUserNote(walletPtr, txid: txid);
  }
  
  static bool getWaitsForDeviceReceive() {
    return beldex.Wallet_getWaitsForDeviceReceive();
  }
  
  static bool getWaitsForDeviceSend() {
    return beldex.Wallet_getWaitsForDeviceSend();
  }
  
  @override
  Wallet2WalletListener getWalletListener() {
    final listener = beldex.BELDEX_cw_getWalletListener(walletPtr);
    return BeldexWalletListener(listener);
  }
  
  @override
  int hasMultisigPartialKeyImages() {
    return beldex.Wallet_hasMultisigPartialKeyImages(walletPtr);
  }
  
  @override
  bool hasUnknownKeyImages() {
    return beldex.Wallet_hasUnknownKeyImages(walletPtr);
  }
  
  @override
  Wallet2TransactionHistory history() {
    return BeldexTransactionHistory(beldex.Wallet_history(walletPtr));
  }
  
  @override
  bool importKeyImages(String filename) {
    return beldex.Wallet_importKeyImages(walletPtr, filename);
  }
  
  @override
  bool importKeyImagesUR(String input) {
    return beldex.Wallet_importKeyImagesUR(walletPtr, input);
  }
  
  @override
  int importMultisigImages({required List<String> info}) {
    return beldex.Wallet_importMultisigImages(walletPtr, info: info);
  }
  
  @override
  bool importOutputs(String filename) {
    return beldex.Wallet_importOutputs(walletPtr, filename);
  }
  
  @override
  bool importOutputsUR(String input) {
    return beldex.Wallet_importOutputsUR(walletPtr, input);
  }
  
  @override
  bool init({required String daemonAddress, int upperTransacationSizeLimit = 0, String daemonUsername = "", String daemonPassword = "", bool useSsl = false, bool lightWallet = false, String proxyAddress = ""}) {
    return beldex.Wallet_init(walletPtr, daemonAddress: daemonAddress, upperTransacationSizeLimit: upperTransacationSizeLimit, daemonUsername: daemonUsername, daemonPassword: daemonPassword, useSsl: useSsl, lightWallet: lightWallet, proxyAddress: proxyAddress);
  }
  
  @override
  void init3({required String argv0, required String defaultLogBaseName, required String logPath, required bool console}) {
    return beldex.Wallet_init3(walletPtr, argv0: argv0, defaultLogBaseName: defaultLogBaseName, logPath: logPath, console: console);
  }
  
  @override
  String integratedAddress({required String paymentId}) {
    return beldex.Wallet_integratedAddress(walletPtr, paymentId: paymentId);
  }
  
  @override
  bool isBackgroundSyncing() {
    return beldex.Wallet_isBackgroundSyncing(walletPtr);
  }
  
  @override
  bool isBackgroundWallet() {
    return beldex.Wallet_isBackgroundWallet(walletPtr);
  }
  
  @override
  bool isKeysFileLocked() {
    return beldex.Wallet_isKeysFileLocked(walletPtr);
  }
  
  @override
  bool isOffline() {
    return beldex.Wallet_isOffline(walletPtr);
  }
  
  @override
  void keyReuseMitigation2({required bool mitigation}) {
    beldex.Wallet_keyReuseMitigation2(walletPtr, mitigation: mitigation);
  }
  
  @override
  bool keyValid({required String secret_key_string, required String address_string, required bool isViewKey, required int nettype}) {
    return beldex.Wallet_keyValid(secret_key_string: secret_key_string, address_string: address_string, isViewKey: isViewKey, nettype: nettype);
  }
  
  @override
  String keyValid_error({required String secret_key_string, required String address_string, required bool isViewKey, required int nettype}) {
    return beldex.Wallet_keyValid_error(secret_key_string: secret_key_string, address_string: address_string, isViewKey: isViewKey, nettype: nettype);
  }
  
  @override
  String keysFilename() {
    return beldex.Wallet_keysFilename(walletPtr);
  }
  
  @override
  Wallet2UnsignedTransaction loadUnsignedTx({required String unsigned_filename}) {
    final tx = beldex.Wallet_loadUnsignedTx(walletPtr, unsigned_filename: unsigned_filename);
    return BeldexUnsignedTransaction(tx);
  }
  
  @override
  Wallet2UnsignedTransaction loadUnsignedTxUR({required String input}) {
    final tx = beldex.Wallet_loadUnsignedTxUR(walletPtr, input: input);
    return BeldexUnsignedTransaction(tx);
  }
  
  @override
  bool lockKeysFile() {
    return beldex.Wallet_lockKeysFile(walletPtr);
  }
  
  @override
  String makeMultisig({required List<String> info, required int threshold}) {
    return beldex.Wallet_makeMultisig(walletPtr, info: info, threshold: threshold);
  }
  
  @override
  int maximumAllowedAmount() {
    return beldex.Wallet_maximumAllowedAmount();
  }
  
  @override
  Wallet2MultisigState multisig() {
    return BeldexMultisigState(beldex.Wallet_multisig(walletPtr));
  }
  
  @override
  int nettype() {
    return beldex.Wallet_nettype(walletPtr);
  }
  
  @override
  int numSubaddressAccounts() {
    return beldex.Wallet_numSubaddressAccounts(walletPtr);
  }
  
  @override
  int numSubaddresses({required int accountIndex}) {
    return beldex.Wallet_numSubaddresses(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  String path() {
    return beldex.Wallet_path(walletPtr);
  }
  
  @override
  void pauseRefresh() {
    beldex.Wallet_pauseRefresh(walletPtr);
  }
  
  @override
  String paymentIdFromAddress({required String strarg, required int nettype}) {
    return beldex.Wallet_paymentIdFromAddress(nettype: nettype, strarg: strarg);
  }
  
  @override
  bool paymentIdValid(String paymentId) {
    return beldex.Wallet_paymentIdValid(paymentId);
  }
  
  @override
  String publicMultisigSignerKey() {
    return beldex.Wallet_publicMultisigSignerKey(walletPtr);
  }
  
  @override
  String publicSpendKey() {
    return beldex.Wallet_publicSpendKey(walletPtr);
  }
  
  @override
  String publicViewKey() {
    return beldex.Wallet_publicViewKey(walletPtr);
  }
  
  @override
  bool reconnectDevice() {
    return beldex.Wallet_reconnectDevice(walletPtr);
  }
  
  @override
  bool refresh() {
    return beldex.Wallet_refresh(walletPtr);
  }
  
  @override
  void refreshAsync() {
    beldex.Wallet_refreshAsync(walletPtr);
  }
  
  @override
  bool rescanBlockchain() {
    return beldex.Wallet_rescanBlockchain(walletPtr);
  }
  
  @override
  void rescanBlockchainAsync() {
    beldex.Wallet_rescanBlockchainAsync(walletPtr);
  }
  
  @override
  bool rescanSpent() {
    return beldex.Wallet_rescanSpent(walletPtr);
  }
  
  @override
  Wallet2PendingTransaction restoreMultisigTransaction({required String signData}) {
    final tx = beldex.Wallet_restoreMultisigTransaction(walletPtr, signData: signData);
    return BeldexPendingTransaction(tx);
  }
  
  @override
  String secretSpendKey() {
    return beldex.Wallet_secretSpendKey(walletPtr);
  }
  
  @override
  String secretViewKey() {
    return beldex.Wallet_secretViewKey(walletPtr);
  }
  
  @override
  String seed({required String seedOffset}) {
    return beldex.Wallet_seed(walletPtr, seedOffset: seedOffset);
  }
  
  @override
  void segregatePreForkOutputs({required bool segregate}) {
    beldex.Wallet_segregatePreForkOutputs(walletPtr, segregate: segregate);
  }
  
  @override
  void segregationHeight({required int height}) {
    beldex.Wallet_segregationHeight(walletPtr, height: height);
  }
  
  @override
  void setAutoRefreshInterval({required int millis}) {
    beldex.Wallet_setAutoRefreshInterval(walletPtr, millis: millis);
  }
  
  @override
  bool setCacheAttribute({required String key, required String value}) {
    return beldex.Wallet_setCacheAttribute(walletPtr, key: key, value: value);
  }
  
  @override
  void setDefaultMixin(int arg) {
    beldex.Wallet_setDefaultMixin(walletPtr, arg);
  }
  
  @override
  bool setDevicePin({required String passphrase}) {
    return beldex.Wallet_setDevicePin(walletPtr, passphrase: passphrase);
  }
  
  static void setDeviceReceivedData(Pointer<UnsignedChar> data, int len) {
    beldex.Wallet_setDeviceReceivedData(data, len);
  }
  
  static void setDeviceSendData(Pointer<UnsignedChar> data, int len) {
    beldex.Wallet_setDeviceSendData(data, len);
  }

  static void setLedgerCallback(Pointer<NativeFunction<Void Function(Pointer<UnsignedChar>, UnsignedInt)>> callback) {
    beldex.Wallet_setLedgerCallback(callback);
  }
  
  @override
  void setOffline({required bool offline}) {
    beldex.Wallet_setOffline(walletPtr, offline: offline);
  }
  
  @override
  bool setPassword({required String password}) {
    return beldex.Wallet_setPassword(walletPtr, password: password);
  }
  
  @override
  void setProxy({required String address}) {
    beldex.Wallet_setProxy(walletPtr, address: address);
  }
  
  @override
  void setRecoveringFromDevice({required bool recoveringFromDevice}) {
    beldex.Wallet_setRecoveringFromDevice(walletPtr, recoveringFromDevice: recoveringFromDevice);
  }
  
  @override
  void setRecoveringFromSeed({required bool recoveringFromSeed}) {
    beldex.Wallet_setRecoveringFromSeed(walletPtr, recoveringFromSeed: recoveringFromSeed);
  }
  
  @override
  void setRefreshFromBlockHeight({required int refresh_from_block_height}) {
    beldex.Wallet_setRefreshFromBlockHeight(walletPtr, refresh_from_block_height: refresh_from_block_height);
  }
  
  @override
  void setSeedLanguage({required String language}) {
    beldex.Wallet_setSeedLanguage(walletPtr, language: language);
  }
  
  @override
  void setSubaddressLabel({required int accountIndex, required int addressIndex, required String label}) {
    beldex.Wallet_setSubaddressLabel(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex, label: label);
  }
  
  @override
  void setSubaddressLookahead({required int major, required int minor}) {
    beldex.Wallet_setSubaddressLookahead(walletPtr, major: major, minor: minor);
  }
  
  @override
  void setTrustedDaemon({required bool arg}) {
    beldex.Wallet_setTrustedDaemon(walletPtr, arg: arg);
  }
  
  @override
  bool setUserNote({required String txid, required String note}) {
    return beldex.Wallet_setUserNote(walletPtr, txid: txid, note: note);
  }
  
  @override
  bool setupBackgroundSync({required int backgroundSyncType, required String walletPassword, required String backgroundCachePassword}) {
    return beldex.Wallet_setupBackgroundSync(walletPtr, backgroundSyncType: backgroundSyncType, walletPassword: walletPassword, backgroundCachePassword: backgroundCachePassword);
  }
  
  @override
  String signMessage({required String message, required String address}) {
    return beldex.Wallet_signMessage(walletPtr, message: message, address: address);
  }
  
  @override
  bool startBackgroundSync() {
    return beldex.Wallet_startBackgroundSync(walletPtr);
  }
  
  @override
  void startRefresh() {
    beldex.Wallet_startRefresh(walletPtr);
  }
  
  @override
  int status() {
    return beldex.Wallet_status(walletPtr);
  }
  
  @override
  void stop() {
    beldex.Wallet_stop(walletPtr);
  }
  
  @override
  bool stopBackgroundSync(String walletPassword) {
    return beldex.Wallet_stopBackgroundSync(walletPtr, walletPassword);
  }
  
  @override
  bool store({String path = ""}) {
    return beldex.Wallet_store(walletPtr, path: path);
  }
  
  @override
  Wallet2Subaddress subaddress() {
    return BeldexSubaddress(beldex.Wallet_subaddress(walletPtr));
  }
  
  @override
  Wallet2SubaddressAccount subaddressAccount() {
    return BeldexSubaddressAccount(beldex.Wallet_subaddressAccount(walletPtr));
  }
  
  @override
  bool submitTransaction(String filename) {
    return beldex.Wallet_submitTransaction(walletPtr, filename);
  }
  
  @override
  bool submitTransactionUR(String input) {
    return beldex.Wallet_submitTransactionUR(walletPtr, input);
  }
  
  @override
  bool synchronized() {
    return beldex.Wallet_synchronized(walletPtr);
  }
  
  @override
  bool trustedDaemon() {
    return beldex.Wallet_trustedDaemon(walletPtr);
  }
  
  @override
  bool unlockKeysFile() {
    return beldex.Wallet_unlockKeysFile(walletPtr);
  }
  
  @override
  int unlockedBalance({required int accountIndex}) {
    return beldex.Wallet_unlockedBalance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  int useForkRules({required int version, required int earlyBlocks}) {
    return beldex.Wallet_useForkRules(walletPtr, version: version, earlyBlocks: earlyBlocks);
  }
  
  @override
  bool verifySignedMessage({required String message, required String address, required String signature}) {
    return beldex.Wallet_verifySignedMessage(walletPtr, message: message, address: address, signature: signature);
  }
  
  @override
  int viewOnlyBalance({required int accountIndex}) {
    return beldex.Wallet_viewOnlyBalance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  bool watchOnly() {
    return beldex.Wallet_watchOnly(walletPtr);
  }

  @override
  int ffiAddress() => walletPtr.address;
}

class BeldexWalletManager implements Wallet2WalletManager {
  BeldexWalletManager(this.wmPtr);

  final beldex.WalletManager wmPtr;
  
  @override
  Future<int> blockTarget() async {
    return beldex.WalletManager_blockTarget(wmPtr);
  }
  
  @override
  Future<int> blockchainHeight() async {
    return beldex.WalletManager_blockchainHeight(wmPtr);
  }
  
  @override
  Future<int> blockchainTargetHeight() async {
    return beldex.WalletManager_blockchainTargetHeight(wmPtr);
  }
  
  @override
  Wallet2Wallet createDeterministicWalletFromSpendKey({required String path, required String password, String language = "English", int networkType = 0, required String spendKeyString, required bool newWallet, required int restoreHeight, int kdfRounds = 1}) {
    final wallet = beldex.WalletManager_createDeterministicWalletFromSpendKey(wmPtr, path: path, password: password, language: language, networkType: networkType, spendKeyString: spendKeyString, newWallet: newWallet, restoreHeight: restoreHeight, kdfRounds: kdfRounds);
    return BeldexWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWallet({required String path, required String password, String language = "English", int networkType = 0}) {
    final wallet = beldex.WalletManager_createWallet(wmPtr, path: path, password: password, language: language, networkType: networkType);
    return BeldexWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromDevice({required String path, required String password, int networkType = 0, required String deviceName, int restoreHeight = 0, String subaddressLookahead = "", int kdfRounds = 1}) {
    final wallet = beldex.WalletManager_createWalletFromDevice(wmPtr, path: path, password: password, deviceName: deviceName, restoreHeight: restoreHeight, subaddressLookahead: subaddressLookahead, kdfRounds: kdfRounds);
    return BeldexWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromKeys({required String path, required String password, String language = "English", int nettype = 1, required int restoreHeight, required String addressString, required String viewKeyString, required String spendKeyString, int kdf_rounds = 1}) {
    final wallet = beldex.WalletManager_createWalletFromKeys(wmPtr, path: path, password: password, language: language, nettype: nettype, restoreHeight: restoreHeight, addressString: addressString, viewKeyString: viewKeyString, spendKeyString: spendKeyString);
    return BeldexWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromPolyseed({required String path, required String password, int networkType = 0, required String mnemonic, required String seedOffset, required bool newWallet, required int restoreHeight, required int kdfRounds}) {
    final wallet = beldex.WalletManager_createWalletFromPolyseed(wmPtr, path: path, password: password, networkType: networkType, mnemonic: mnemonic, seedOffset: seedOffset, newWallet: newWallet, restoreHeight: restoreHeight, kdfRounds: kdfRounds);
    return BeldexWallet(wallet);
  }
  
  @override
  String errorString() {
    return beldex.WalletManager_errorString(wmPtr);
  }
  
  @override
  List<String> findWallets({required String path}) {
    return beldex.WalletManager_findWallets(wmPtr, path: path);
  }
  
  @override
  bool isMining() {
    return beldex.WalletManager_isMining(wmPtr);
  }
  
  @override
  double miningHashRate() {
    return beldex.WalletManager_miningHashRate(wmPtr);
  }
  
  @override
  int networkDifficulty() {
    return beldex.WalletManager_networkDifficulty(wmPtr);
  }
  
  @override
  Wallet2Wallet openWallet({required String path, required String password, int networkType = 0}) {
    final wallet = beldex.WalletManager_openWallet(wmPtr, path: path, password: password, networkType: networkType);
    return BeldexWallet(wallet);
  }
  
  @override
  int queryWalletDevice({required String keysFileName, required String password, required int kdfRounds}) {
    return beldex.WalletManager_queryWalletDevice(wmPtr, keysFileName: keysFileName, password: password, kdfRounds: kdfRounds);
  }
  
  @override
  Wallet2Wallet recoveryWallet({required String path, required String password, required String mnemonic, int networkType = 0, required int restoreHeight, int kdfRounds = 0, required String seedOffset}) {
    final wallet = beldex.WalletManager_recoveryWallet(wmPtr, path: path, password: password, mnemonic: mnemonic, networkType: networkType, restoreHeight: restoreHeight, kdfRounds: kdfRounds, seedOffset: seedOffset);
    return BeldexWallet(wallet);
  }
  
  @override
  String resolveOpenAlias({required String address, required bool dnssecValid}) {
    return beldex.WalletManager_resolveOpenAlias(wmPtr, address: address, dnssecValid: dnssecValid);
  }
  
  @override
  void setDaemonAddress(String address) {
    beldex.WalletManager_setDaemonAddress(wmPtr, address);
  }
  
  @override
  bool setProxy(String address) {
    return beldex.WalletManager_setProxy(wmPtr, address);
  }
  
  @override
  bool startMining({required String address, required int threads, required bool backgroundMining, required bool ignoreBattery}) {
    return beldex.WalletManager_startMining(wmPtr, address: address, threads: threads, backgroundMining: backgroundMining, ignoreBattery: ignoreBattery);
  }
  
  @override
  bool stopMining(String address) {
    return beldex.WalletManager_stopMining(wmPtr, address);
  }
  
  @override
  bool verifyWalletPassword({required String keysFileName, required String password, required bool noSpendKey, required int kdfRounds}) {
    return beldex.WalletManager_verifyWalletPassword(wmPtr, keysFileName: keysFileName, password: password, noSpendKey: noSpendKey, kdfRounds: kdfRounds);
  }
  
  @override
  bool walletExists(String path) {
    return beldex.WalletManager_walletExists(wmPtr, path);
  }

  @override
  int ffiAddress() => wmPtr.address;
  
  @override
  void closeWallet(Wallet2Wallet wallet, bool store) {
    beldex.WalletManager_closeWallet(wmPtr, Pointer.fromAddress(wallet.ffiAddress()), store);
  }
}

class BeldexWalletManagerFactory implements Wallet2WalletManagerFactory {
  @override
  Wallet2WalletManager getWalletManager() {
    return BeldexWalletManager(beldex.WalletManagerFactory_getWalletManager());
  }

  @override
  void setLogCategories(String categories) {
    beldex.WalletManagerFactory_setLogCategories(categories);
  }

  @override
  void setLogLevel(int level) {
    beldex.WalletManagerFactory_setLogLevel(level);
  }

  @override
  int ffiAddress() => 0;
}
