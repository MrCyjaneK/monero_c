// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:ffi';

import 'package:monero/wownero.dart' as wownero;
import 'package:monero/src/wallet2.dart';

class Wownero implements Wallet2 {
  @override
  Wallet2WalletManagerFactory walletManagerFactory() {
    return WowneroWalletManagerFactory();
  }

  @override
  int ffiAddress() => 0;
}

class WowneroAddressBook implements Wallet2AddressBook {
  WowneroAddressBook(this.addressBookPtr);

  final wownero.AddressBook addressBookPtr;
  
  @override
  bool addRow({required String dstAddr, required String paymentId, required String description}) {
    return wownero.AddressBook_addRow(addressBookPtr, dstAddr: dstAddr, paymentId: paymentId, description: description);
  }
  
  @override
  bool deleteRow({required int rowId}) {
    return wownero.AddressBook_deleteRow(addressBookPtr, rowId: rowId);
  }
  
  @override
  int errorCode() {
    return wownero.AddressBook_errorCode(addressBookPtr);
  }
  
  @override
  Wallet2AddressBookRow getAll_byIndex(int index) {
    final row = wownero.AddressBook_getAll_byIndex(addressBookPtr, index: index);
    return WowneroAddressBookRow(row);
  }
  
  @override
  int getAll_size() {
    return wownero.AddressBook_getAll_size(addressBookPtr);
  }
  
  @override
  int lookupPaymentID({required String paymentId}) {
    return wownero.AddressBook_lookupPaymentID(addressBookPtr, paymentId: paymentId);
  }
  
  @override
  void refresh() {
    wownero.AddressBook_refresh(addressBookPtr);
  }
  
  @override
  bool setDescription({required int rowId, required String description}) {
    return wownero.AddressBook_setDescription(addressBookPtr, rowId: rowId, description: description);
  }

  @override
  int ffiAddress() => addressBookPtr.address;
}

class WowneroAddressBookRow implements Wallet2AddressBookRow {
  WowneroAddressBookRow(this.addressBookRowPtr);

  final wownero.AddressBookRow addressBookRowPtr;
  
  @override
  String extra() {
    return wownero.AddressBookRow_extra(addressBookRowPtr);
  }
  
  @override
  String getAddress() {
    return wownero.AddressBookRow_getAddress(addressBookRowPtr);
  }
  
  @override
  String getDescription() {
    return wownero.AddressBookRow_getDescription(addressBookRowPtr);
  }
  
  @override
  String getPaymentId() {
    return wownero.AddressBookRow_getPaymentId(addressBookRowPtr);
  }
  
  @override
  int getRowId() {
    return wownero.AddressBookRow_getRowId(addressBookRowPtr);
  }

  @override
  int ffiAddress() => addressBookRowPtr.address;
}

class WowneroCoins implements Wallet2Coins {
  WowneroCoins(this.coinsPtr);

  final wownero.Coins coinsPtr;
  
  @override
  Wallet2CoinsInfo coin(int index) {
    final coin = wownero.Coins_coin(coinsPtr, index);
    return WowneroCoinsInfo(coin);
  }
  
  @override
  int count() {
    return wownero.Coins_count(coinsPtr);
  }
  
  @override
  Wallet2CoinsInfo getAll_byIndex(int index) {
    final coin = wownero.Coins_getAll_byIndex(coinsPtr, index);
    return WowneroCoinsInfo(coin);
  }
  
  @override
  int getAll_size() {
    return wownero.Coins_getAll_size(coinsPtr);
  }
  
  @override
  bool isTransferUnlocked({required int unlockTime, required int blockHeight}) {
    return wownero.Coins_isTransferUnlocked(coinsPtr, unlockTime: unlockTime, blockHeight: blockHeight);
  }
  
  @override
  void refresh() {
    wownero.Coins_refresh(coinsPtr);
  }
  
  @override
  void setFrozen({required int index}) {
    wownero.Coins_setFrozen(coinsPtr, index: index);
  }
  
  @override
  void setFrozenByPublicKey({required String publicKey}) {
    wownero.Coins_setFrozenByPublicKey(coinsPtr, publicKey: publicKey);
  }
  
  @override
  void thaw({required int index}) {
    wownero.Coins_thaw(coinsPtr, index: index);
  }
  
  @override
  void thawByPublicKey({required String publicKey}) {
    wownero.Coins_thawByPublicKey(coinsPtr, publicKey: publicKey);
  }

  @override
  int ffiAddress() => coinsPtr.address;
}

class WowneroCoinsInfo implements Wallet2CoinsInfo {
  WowneroCoinsInfo(this.coinsInfoPtr);

  final wownero.CoinsInfo coinsInfoPtr;
  
  @override
  String address() {
    return wownero.CoinsInfo_address(coinsInfoPtr);
  }
  
  @override
  String addressLabel() {
    return wownero.CoinsInfo_addressLabel(coinsInfoPtr);
  }
  
  @override
  int amount() {
    return wownero.CoinsInfo_amount(coinsInfoPtr);
  }
  
  @override
  int blockHeight() {
    return wownero.CoinsInfo_blockHeight(coinsInfoPtr);
  }
  
  @override
  bool coinbase() {
    return wownero.CoinsInfo_coinbase(coinsInfoPtr);
  }
  
  @override
  String description() {
    return wownero.CoinsInfo_description(coinsInfoPtr);
  }
  
  @override
  bool frozen() {
    return wownero.CoinsInfo_frozen(coinsInfoPtr);
  }
  
  @override
  int globalOutputIndex() {
    return wownero.CoinsInfo_globalOutputIndex(coinsInfoPtr);
  }
  
  @override
  String hash() {
    return wownero.CoinsInfo_hash(coinsInfoPtr);
  }
  
  @override
  int internalOutputIndex() {
    return wownero.CoinsInfo_internalOutputIndex(coinsInfoPtr);
  }
  
  @override
  String keyImage() {
    return wownero.CoinsInfo_keyImage(coinsInfoPtr);
  }
  
  @override
  bool keyImageKnown() {
    return wownero.CoinsInfo_keyImageKnown(coinsInfoPtr);
  }
  
  @override
  int pkIndex() {
    return wownero.CoinsInfo_pkIndex(coinsInfoPtr);
  }
  
  @override
  String pubKey() {
    return wownero.CoinsInfo_pubKey(coinsInfoPtr);
  }
  
  @override
  bool rct() {
    return wownero.CoinsInfo_rct(coinsInfoPtr);
  }
  
  @override
  bool spent() {
    return wownero.CoinsInfo_spent(coinsInfoPtr);
  }
  
  @override
  int spentHeight() {
    return wownero.CoinsInfo_spentHeight(coinsInfoPtr);
  }
  
  @override
  int subaddrAccount() {
    return wownero.CoinsInfo_subaddrAccount(coinsInfoPtr);
  }
  
  @override
  int subaddrIndex() {
    return wownero.CoinsInfo_subaddrIndex(coinsInfoPtr);
  }
  
  @override
  int unlockTime() {
    return wownero.CoinsInfo_unlockTime(coinsInfoPtr);
  }
  
  @override
  bool unlocked() {
    return wownero.CoinsInfo_unlocked(coinsInfoPtr);
  }

  @override
  int ffiAddress() => coinsInfoPtr.address;
}

class WowneroDeviceProgress implements Wallet2DeviceProgress {
  WowneroDeviceProgress(this.deviceProgressPtr);

  final wownero.DeviceProgress deviceProgressPtr;
  
  @override
  bool indeterminate() {
    return wownero.DeviceProgress_indeterminate(deviceProgressPtr);
  }
  
  @override
  bool progress() {
    return wownero.DeviceProgress_progress(deviceProgressPtr);
  }

  @override
  int ffiAddress() => deviceProgressPtr.address;
}

class WowneroWalletListener implements Wallet2WalletListener {
  WowneroWalletListener(this.walletListenerPtr);

  final wownero.WalletListener walletListenerPtr;
  
  @override
  int height() {
    return wownero.WOWNERO_cw_WalletListener_height(walletListenerPtr);
  }
  
  @override
  bool isNeedToRefresh() {
    return wownero.WOWNERO_cw_WalletListener_isNeedToRefresh(walletListenerPtr);
  }
  
  @override
  bool isNewTransactionExist() {
    return wownero.WOWNERO_cw_WalletListener_isNewTransactionExist(walletListenerPtr);
  }
  
  @override
  void resetIsNewTransactionExist() {
    wownero.WOWNERO_cw_WalletListener_resetIsNewTransactionExist(walletListenerPtr);
  }
  
  @override
  void resetNeedToRefresh() {
    wownero.WOWNERO_cw_WalletListener_resetNeedToRefresh(walletListenerPtr);
  }

  @override
  int ffiAddress() => walletListenerPtr.address;
}

class WowneroWalletChecksum implements Wallet2Checksum {
  WowneroWalletChecksum();

  @override
  String checksum_wallet2_api_c_cpp() {
    return wownero.WOWNERO_checksum_wallet2_api_c_cpp();
  }
  
  @override
  String checksum_wallet2_api_c_exp() {
    return wownero.WOWNERO_checksum_wallet2_api_c_exp();
  }
  
  @override
  String checksum_wallet2_api_c_h() {
    return wownero.WOWNERO_checksum_wallet2_api_c_h();
  }

  @override
  int ffiAddress() => 0;
}

class WowneroFree implements Wallet2Free {
  WowneroFree();

  @override
  void free(Pointer<Void> ptr) {
    wownero.WOWNERO_free(ptr);
  }

  @override
  int ffiAddress() => 0;
}

class WowneroMultisigState implements Wallet2MultisigState {
  WowneroMultisigState(this.multisigStatePtr);

  final wownero.MultisigState multisigStatePtr;
  
  @override
  bool isMultisig(Pointer<Void> ptr) {
    return wownero.MultisigState_isMultisig(multisigStatePtr);
  }
  
  @override
  bool isReady(Pointer<Void> ptr) {
    return wownero.MultisigState_isReady(multisigStatePtr);
  }
  
  @override
  int threshold(Pointer<Void> ptr) {
    return wownero.MultisigState_threshold(multisigStatePtr);
  }
  
  @override
  int total(Pointer<Void> ptr) {
    return wownero.MultisigState_total(multisigStatePtr);
  }

  @override
  int ffiAddress() => multisigStatePtr.address;
}

class WowneroPendingTransaction implements Wallet2PendingTransaction {
  WowneroPendingTransaction(this.pendingTransactionPtr);

  final wownero.PendingTransaction pendingTransactionPtr;
  
  @override
  int amount() {
    return wownero.PendingTransaction_amount(pendingTransactionPtr);
  }
  
  @override
  bool commit({required String filename, required bool overwrite}) {
    return wownero.PendingTransaction_commit(pendingTransactionPtr, filename: filename, overwrite: overwrite);
  }
  
  @override
  String commitUR(int max_fragment_length) {
    throw UnimplementedError();
  }
  
  @override
  int dust() {
    return wownero.PendingTransaction_dust(pendingTransactionPtr);
  }
  
  @override
  String errorString() {
    return wownero.PendingTransaction_errorString(pendingTransactionPtr);
  }
  
  @override
  int fee() {
    return wownero.PendingTransaction_fee(pendingTransactionPtr);
  }
  
  @override
  String hex(String separator) {
    return wownero.PendingTransaction_hex(pendingTransactionPtr, separator);
  }
  
  @override
  String multisigSignData() {
    return wownero.PendingTransaction_multisigSignData(pendingTransactionPtr);
  }
  
  @override
  void signMultisigTx() {
    wownero.PendingTransaction_signMultisigTx(pendingTransactionPtr);
  }
  
  @override
  String signersKeys(String separator) {
    return wownero.PendingTransaction_signersKeys(pendingTransactionPtr, separator);
  }
  
  @override
  int status() {
    return wownero.PendingTransaction_status(pendingTransactionPtr);
  }
  
  @override
  String subaddrAccount(String separator) {
    return wownero.PendingTransaction_subaddrAccount(pendingTransactionPtr, separator);
  }
  
  @override
  String subaddrIndices(String separator) {
    return wownero.PendingTransaction_subaddrIndices(pendingTransactionPtr, separator);
  }
  
  @override
  int txCount() {
    return wownero.PendingTransaction_txCount(pendingTransactionPtr);
  }
  
  @override
  String txid(String separator) {
    return wownero.PendingTransaction_txid(pendingTransactionPtr, separator);
  }

  @override
  int ffiAddress() => pendingTransactionPtr.address;
}

class WowneroSubaddress implements Wallet2Subaddress {
  WowneroSubaddress(this.subaddressPtr);

  final wownero.Subaddress subaddressPtr;
  
  @override
  void addRow({required int accountIndex, required String label}) {
    wownero.Subaddress_addRow(subaddressPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  Wallet2SubaddressRow getAll_byIndex(int index) {
    final row = wownero.Subaddress_getAll_byIndex(subaddressPtr, index: index);
    return WowneroSubaddressRow(row);
  }
  
  @override
  int getAll_size() {
    return wownero.Subaddress_getAll_size(subaddressPtr);
  }
  
  @override
  void refresh({required int accountIndex, required String label}) {
    wownero.Subaddress_refresh(subaddressPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  void setLabel({required int accountIndex, required int addressIndex, required String label}) {
    wownero.Subaddress_setLabel(subaddressPtr, accountIndex: accountIndex, addressIndex: addressIndex, label: label);
  }

  @override
  int ffiAddress() => subaddressPtr.address;
}

class WowneroSubaddressAccount implements Wallet2SubaddressAccount {
  WowneroSubaddressAccount(this.subaddressAccountPtr);

  final wownero.SubaddressAccount subaddressAccountPtr;
  
  @override
  void addRow({required String label}) {
    wownero.SubaddressAccount_addRow(subaddressAccountPtr, label: label);
  }
  
  @override
  Wallet2SubaddressAccountRow getAll_byIndex(int index) {
    final row = wownero.SubaddressAccount_getAll_byIndex(subaddressAccountPtr, index: index);
    return WowneroSubaddressAccountRow(row);
  }
  
  @override
  int getAll_size() {
    return wownero.SubaddressAccount_getAll_size(subaddressAccountPtr);
  }
  
  @override
  void refresh() {
    wownero.SubaddressAccount_refresh(subaddressAccountPtr);
  }
  
  @override
  void setLabel({required int accountIndex, required String label}) {
    wownero.SubaddressAccount_setLabel(subaddressAccountPtr, accountIndex: accountIndex, label: label);
  }

  @override
  int ffiAddress() => subaddressAccountPtr.address;
}

class WowneroSubaddressAccountRow implements Wallet2SubaddressAccountRow {
  WowneroSubaddressAccountRow(this.subaddressAccountRowPtr);

  final wownero.SubaddressAccountRow subaddressAccountRowPtr;
  
  @override
  String extra() {
    return wownero.SubaddressAccountRow_extra(subaddressAccountRowPtr);
  }
  
  @override
  String getAddress() {
    return wownero.SubaddressAccountRow_getAddress(subaddressAccountRowPtr);
  }
  
  @override
  String getBalance() {
    return wownero.SubaddressAccountRow_getBalance(subaddressAccountRowPtr);
  }
  
  @override
  String getLabel() {
    return wownero.SubaddressAccountRow_getLabel(subaddressAccountRowPtr);
  }
  
  @override
  int getRowId() {
    return wownero.SubaddressAccountRow_getRowId(subaddressAccountRowPtr);
  }
  
  @override
  String getUnlockedBalance() {
    return wownero.SubaddressAccountRow_getUnlockedBalance(subaddressAccountRowPtr);
  }

  @override
  int ffiAddress() => subaddressAccountRowPtr.address;
}

class WowneroSubaddressRow implements Wallet2SubaddressRow {
  WowneroSubaddressRow(this.subaddressRowPtr);

  final wownero.SubaddressRow subaddressRowPtr;
  
  @override
  String extra() {
    return wownero.SubaddressRow_extra(subaddressRowPtr);
  }
  
  @override
  String getAddress() {
    return wownero.SubaddressRow_getAddress(subaddressRowPtr);
  }
  
  @override
  String getLabel() {
    return wownero.SubaddressRow_getLabel(subaddressRowPtr);
  }
  
  @override
  int getRowId() {
    return wownero.SubaddressRow_getRowId(subaddressRowPtr);
  }

  @override
  int ffiAddress() => subaddressRowPtr.address;
}

class WowneroTransactionHistory implements Wallet2TransactionHistory {
  WowneroTransactionHistory(this.transactionHistoryPtr);

  final wownero.TransactionHistory transactionHistoryPtr;
  
  @override
  int count() {
    return wownero.TransactionHistory_count(transactionHistoryPtr);
  }
  
  @override
  void refresh() {
    wownero.TransactionHistory_refresh(transactionHistoryPtr);
  }
  
  @override
  void setTxNote({required String txid, required String note}) {
    wownero.TransactionHistory_setTxNote(transactionHistoryPtr, txid: txid, note: note);
  }
  
  @override
  Wallet2TransactionInfo transaction(int index) {
    final tx = wownero.TransactionHistory_transaction(transactionHistoryPtr, index: index);
    return WowneroTransactionInfo(tx);
  }
  
  @override
  Wallet2TransactionInfo transactionById(String txid) {
    final tx = wownero.TransactionHistory_transactionById(transactionHistoryPtr, txid: txid);
    return WowneroTransactionInfo(tx);
  }

  @override
  int ffiAddress() => transactionHistoryPtr.address;
}

class WowneroTransactionInfo implements Wallet2TransactionInfo {
  WowneroTransactionInfo(this.transactionInfoPtr);

  final wownero.TransactionInfo transactionInfoPtr;
  
  @override
  int amount() {
    return wownero.TransactionInfo_amount(transactionInfoPtr);
  }
  
  @override
  int blockHeight() {
    return wownero.TransactionInfo_blockHeight(transactionInfoPtr);
  }
  
  @override
  int confirmations() {
    return wownero.TransactionInfo_confirmations(transactionInfoPtr);
  }
  
  @override
  String description() {
    return wownero.TransactionInfo_description(transactionInfoPtr);
  }
  
  @override
  int direction() {
    return wownero.TransactionInfo_direction(transactionInfoPtr).index;
  }
  
  @override
  int fee() {
    return wownero.TransactionInfo_fee(transactionInfoPtr);
  }
  
  @override
  String hash() {
    return wownero.TransactionInfo_hash(transactionInfoPtr);
  }
  
  @override
  bool isCoinbase() {
    return wownero.TransactionInfo_isCoinbase(transactionInfoPtr);
  }
  
  @override
  bool isFailed() {
    return wownero.TransactionInfo_isFailed(transactionInfoPtr);
  }
  
  @override
  bool isPending() {
    return wownero.TransactionInfo_isPending(transactionInfoPtr);
  }
  
  @override
  String label() {
    return wownero.TransactionInfo_label(transactionInfoPtr);
  }
  
  @override
  String paymentId() {
    return wownero.TransactionInfo_paymentId(transactionInfoPtr);
  }
  
  @override
  int subaddrAccount() {
    return wownero.TransactionInfo_subaddrAccount(transactionInfoPtr);
  }
  
  @override
  String subaddrIndex() {
    return wownero.TransactionInfo_subaddrIndex(transactionInfoPtr);
  }
  
  @override
  int timestamp() {
    return wownero.TransactionInfo_timestamp(transactionInfoPtr);
  }
  
  @override
  String transfers_address(int index) {
    return wownero.TransactionInfo_transfers_address(transactionInfoPtr, index);
  }
  
  @override
  int transfers_amount(int index) {
    return wownero.TransactionInfo_transfers_amount(transactionInfoPtr, index);
  }
  
  @override
  int transfers_count() {
    return wownero.TransactionInfo_transfers_count(transactionInfoPtr);
  }
  
  @override
  int unlockTime() {
    return wownero.TransactionInfo_unlockTime(transactionInfoPtr);
  }

  @override
  int ffiAddress() => transactionInfoPtr.address;
}

class WowneroUnsignedTransaction implements Wallet2UnsignedTransaction {
  WowneroUnsignedTransaction(this.unsignedTransactionPtr);

  final wownero.UnsignedTransaction unsignedTransactionPtr;
  
  @override
  String amount() {
    return wownero.UnsignedTransaction_amount(unsignedTransactionPtr);
  }
  
  @override
  String confirmationMessage() {
    return wownero.UnsignedTransaction_confirmationMessage(unsignedTransactionPtr);
  }
  
  @override
  String errorString() {
    return wownero.UnsignedTransaction_errorString(unsignedTransactionPtr);
  }
  
  @override
  String fee() {
    return wownero.UnsignedTransaction_fee(unsignedTransactionPtr);
  }
  
  @override
  int minMixinCount() {
    return wownero.UnsignedTransaction_minMixinCount(unsignedTransactionPtr);
  }
  
  @override
  String mixin() {
    return wownero.UnsignedTransaction_mixin(unsignedTransactionPtr);
  }
  
  @override
  String paymentId() {
    return wownero.UnsignedTransaction_paymentId(unsignedTransactionPtr);
  }
  
  @override
  String recipientAddress() {
    return wownero.UnsignedTransaction_recipientAddress(unsignedTransactionPtr);
  }
  
  @override
  bool sign(String signedFileName) {
    return wownero.UnsignedTransaction_sign(unsignedTransactionPtr, signedFileName);
  }
  
  @override
  String signUR(int max_fragment_length) {
    throw UnimplementedError();
  }
  
  @override
  int status() {
    return wownero.UnsignedTransaction_status(unsignedTransactionPtr);
  }
  
  @override
  int txCount() {
    return wownero.UnsignedTransaction_txCount(unsignedTransactionPtr);
  }
  
  @override
  int ffiAddress() => unsignedTransactionPtr.address;
}

class WowneroWallet implements Wallet2Wallet {
  WowneroWallet(this.walletPtr);

  final wownero.wallet walletPtr;
  
  @override
  void addSubaddress({required int accountIndex, String label = ""}) {
    wownero.Wallet_addSubaddress(walletPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  void addSubaddressAccount({String label = ""}) {
    wownero.Wallet_addSubaddressAccount(walletPtr, label: label);
  }
  
  @override
  String address({int accountIndex = 0, int addressIndex = 0}) {
    return wownero.Wallet_address(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  Wallet2AddressBook addressBook() {
    return WowneroAddressBook(wownero.Wallet_addressBook(walletPtr));
  }
  
  @override
  bool addressValid(String address, int networkType) {
    return wownero.Wallet_addressValid(address, networkType);
  }
  
  @override
  int amountFromDouble(double amount) {
    return wownero.Wallet_amountFromDouble(amount);
  }
  
  @override
  int amountFromString(String amount) {
    return wownero.Wallet_amountFromString(amount);
  }
  
  @override
  int approximateBlockChainHeight() {
    return wownero.Wallet_approximateBlockChainHeight(walletPtr);
  }
  
  @override
  int autoRefreshInterval() {
    return wownero.Wallet_autoRefreshInterval(walletPtr);
  }
  
  @override
  int balance({required int accountIndex}) {
    return wownero.Wallet_balance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  int blockChainHeight() {
    return wownero.Wallet_blockChainHeight(walletPtr);
  }
  
  @override
  Wallet2Coins coins() {
    return WowneroCoins(wownero.Wallet_coins(walletPtr));
  }
  
  @override
  int coldKeyImageSync({required int spent, required int unspent}) {
    return wownero.Wallet_coldKeyImageSync(walletPtr, spent: spent, unspent: unspent);
  }
  
  @override
  bool connectToDaemon() {
    return wownero.Wallet_connectToDaemon(walletPtr);
  }
  
  @override
  int connected() {
    return wownero.Wallet_connected(walletPtr);
  }
  
  @override
  String createPolyseed({String language = "English"}) {
    return wownero.Wallet_createPolyseed(language: language);
  }
  
  @override
  Wallet2PendingTransaction createTransaction({required String dst_addr, required String payment_id, required int amount, required int mixin_count, required int pendingTransactionPriority, required int subaddr_account, List<String> preferredInputs = const []}) {
    final transaction = wownero.Wallet_createTransaction(walletPtr, dst_addr: dst_addr, payment_id: payment_id, amount: amount, mixin_count: mixin_count, pendingTransactionPriority: pendingTransactionPriority, subaddr_account: subaddr_account, preferredInputs: preferredInputs);
    return WowneroPendingTransaction(transaction);
  }
  
  @override
  Wallet2PendingTransaction createTransactionMultDest({required List<String> dstAddr, String paymentId = "", required bool isSweepAll, required List<int> amounts, required int mixinCount, required int pendingTransactionPriority, required int subaddr_account, List<String> preferredInputs = const []}) {
    final transaction = wownero.Wallet_createTransactionMultDest(walletPtr, dstAddr: dstAddr, paymentId: paymentId, isSweepAll: isSweepAll, amounts: amounts, mixinCount: mixinCount, pendingTransactionPriority: pendingTransactionPriority, subaddr_account: subaddr_account, preferredInputs: preferredInputs);
    return WowneroPendingTransaction(transaction);
  }
  
  @override
  bool createWatchOnly({required String path, required String password, required String language}) {
    return wownero.Wallet_createWatchOnly(walletPtr, path: path, password: password, language: language);
  }
  
  @override
  int daemonBlockChainHeight() {
    return wownero.Wallet_daemonBlockChainHeight(walletPtr);
  }
  
  @override
  int defaultMixin() {
    return wownero.Wallet_defaultMixin(walletPtr);
  }
  
  @override
  String deviceShowAddress({required int accountIndex, required int addressIndex}) {
    return wownero.Wallet_deviceShowAddress(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  String displayAmount(int amount) {
    return wownero.Wallet_displayAmount(amount);
  }
  
  @override
  String errorString() {
    return wownero.Wallet_errorString(walletPtr);
  }
  
  @override
  int estimateBlockChainHeight() {
    return wownero.Wallet_estimateBlockChainHeight(walletPtr);
  }
  
  @override
  String exchangeMultisigKeys({required List<String> info, required bool force_update_use_with_caution}) {
    throw UnimplementedError();
  }
  
  @override
  bool exportKeyImages(String filename, {required bool all}) {
    return wownero.Wallet_exportKeyImages(walletPtr, filename, all: all);
  }
  
  @override
  String exportKeyImagesUR({int max_fragment_length = 130, bool all = false}) {
    throw UnimplementedError();
  }
  
  @override
  List<String> exportMultisigImages({required List<String> info}) {
    throw UnimplementedError();
  }
  
  @override
  bool exportOutputs(String filename, {required bool all}) {
    return wownero.Wallet_exportOutputs(walletPtr, filename, all: all);
  }
  
  @override
  String exportOutputsUR({int max_fragment_length = 130, bool all = false}) {
    throw UnimplementedError();
  }
  
  @override
  String filename() {
    return wownero.Wallet_filename(walletPtr);
  }
  
  @override
  String genPaymentId() {
    return wownero.Wallet_genPaymentId();
  }
  
  @override
  int getBackgroundSyncType() {
    return wownero.Wallet_getBackgroundSyncType(walletPtr);
  }
  
  @override
  int getBytesReceived() {
    return wownero.Wallet_getBytesReceived(walletPtr);
  }
  
  @override
  int getBytesSent() {
    throw UnimplementedError();
  }
  
  @override
  String getCacheAttribute({required String key}) {
    return wownero.Wallet_getCacheAttribute(walletPtr, key: key);
  }
  
  @override
  int getDeviceType() {
    return wownero.Wallet_getDeviceType(walletPtr);
  }
  
  @override
  String getMultisigInfo() {
    return wownero.Wallet_getMultisigInfo(walletPtr);
  }
  
  @override
  String getPassword() {
    return wownero.Wallet_getPassword(walletPtr);
  }
  
  @override
  String getPolyseed({required String passphrase}) {
    return wownero.Wallet_getPolyseed(walletPtr, passphrase: passphrase);
  }
  
  @override
  Pointer<UnsignedChar> getReceivedFromDevice() {
    throw UnimplementedError();
  }
  
  @override
  int getReceivedFromDeviceLength() {
    throw UnimplementedError();
  }
  
  @override
  int getRefreshFromBlockHeight() {
    return wownero.Wallet_getRefreshFromBlockHeight(walletPtr);
  }
  
  @override
  String getSeedLanguage() {
    return wownero.Wallet_getSeedLanguage(walletPtr);
  }
  
  @override
  Pointer<UnsignedChar> getSendToDevice() {
    throw UnimplementedError();
  }
  
  @override
  int getSendToDeviceLength() {
    throw UnimplementedError();
  }
  
  @override
  bool getStateIsConnected() {
    throw UnimplementedError();
  }
  
  @override
  String getSubaddressLabel({required int accountIndex, required int addressIndex}) {
    return wownero.Wallet_getSubaddressLabel(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  String getTxKey({required String txid}) {
    return wownero.Wallet_getTxKey(walletPtr, txid: txid);
  }
  
  @override
  String getUserNote({required String txid}) {
    return wownero.Wallet_getUserNote(walletPtr, txid: txid);
  }
  
  @override
  bool getWaitsForDeviceReceive() {
    throw UnimplementedError();
  }
  
  @override
  bool getWaitsForDeviceSend() {
    throw UnimplementedError();
  }
  
  @override
  Wallet2WalletListener getWalletListener() {
    final listener = wownero.WOWNERO_cw_getWalletListener(walletPtr);
    return WowneroWalletListener(listener);
  }
  
  @override
  int hasMultisigPartialKeyImages() {
    throw UnimplementedError();
  }
  
  @override
  bool hasUnknownKeyImages() {
    return wownero.Wallet_hasUnknownKeyImages(walletPtr);
  }
  
  @override
  Wallet2TransactionHistory history() {
    return WowneroTransactionHistory(wownero.Wallet_history(walletPtr));
  }
  
  @override
  bool importKeyImages(String filename) {
    return wownero.Wallet_importKeyImages(walletPtr, filename);
  }
  
  @override
  bool importKeyImagesUR(String input) {
    throw UnimplementedError();
  }
  
  @override
  int importMultisigImages({required List<String> info}) {
    throw UnimplementedError();
  }
  
  @override
  bool importOutputs(String filename) {
    return wownero.Wallet_importOutputs(walletPtr, filename);
  }
  
  @override
  bool importOutputsUR(String input) {
    throw UnimplementedError();
  }
  
  @override
  bool init({required String daemonAddress, int upperTransacationSizeLimit = 0, String daemonUsername = "", String daemonPassword = "", bool useSsl = false, bool lightWallet = false, String proxyAddress = ""}) {
    return wownero.Wallet_init(walletPtr, daemonAddress: daemonAddress, upperTransacationSizeLimit: upperTransacationSizeLimit, daemonUsername: daemonUsername, daemonPassword: daemonPassword, useSsl: useSsl, lightWallet: lightWallet, proxyAddress: proxyAddress);
  }
  
  @override
  void init3({required String argv0, required String defaultLogBaseName, required String logPath, required bool console}) {
    return wownero.Wallet_init3(walletPtr, argv0: argv0, defaultLogBaseName: defaultLogBaseName, logPath: logPath, console: console);
  }
  
  @override
  String integratedAddress({required String paymentId}) {
    return wownero.Wallet_integratedAddress(walletPtr, paymentId: paymentId);
  }
  
  @override
  bool isBackgroundSyncing() {
    return wownero.Wallet_isBackgroundSyncing(walletPtr);
  }
  
  @override
  bool isBackgroundWallet() {
    return wownero.Wallet_isBackgroundWallet(walletPtr);
  }
  
  @override
  bool isKeysFileLocked() {
    return wownero.Wallet_isKeysFileLocked(walletPtr);
  }
  
  @override
  bool isOffline() {
    return wownero.Wallet_isOffline(walletPtr);
  }
  
  @override
  void keyReuseMitigation2({required bool mitigation}) {
    wownero.Wallet_keyReuseMitigation2(walletPtr, mitigation: mitigation);
  }
  
  @override
  bool keyValid({required String secret_key_string, required String address_string, required bool isViewKey, required int nettype}) {
    return wownero.Wallet_keyValid(secret_key_string: secret_key_string, address_string: address_string, isViewKey: isViewKey, nettype: nettype);
  }
  
  @override
  String keyValid_error({required String secret_key_string, required String address_string, required bool isViewKey, required int nettype}) {
    return wownero.Wallet_keyValid_error(secret_key_string: secret_key_string, address_string: address_string, isViewKey: isViewKey, nettype: nettype);
  }
  
  @override
  String keysFilename() {
    return wownero.Wallet_keysFilename(walletPtr);
  }
  
  @override
  Wallet2UnsignedTransaction loadUnsignedTx({required String unsigned_filename}) {
    final tx = wownero.Wallet_loadUnsignedTx(walletPtr, unsigned_filename: unsigned_filename);
    return WowneroUnsignedTransaction(tx);
  }
  
  @override
  Wallet2UnsignedTransaction loadUnsignedTxUR({required String input}) {
    throw UnimplementedError();
  }
  
  @override
  bool lockKeysFile() {
    return wownero.Wallet_lockKeysFile(walletPtr);
  }
  
  @override
  String makeMultisig({required List<String> info, required int threshold}) {
    throw UnimplementedError();
  }
  
  @override
  int maximumAllowedAmount() {
    return wownero.Wallet_maximumAllowedAmount();
  }
  
  @override
  Wallet2MultisigState multisig() {
    throw UnimplementedError();
  }
  
  @override
  int nettype() {
    return wownero.Wallet_nettype(walletPtr);
  }
  
  @override
  int numSubaddressAccounts() {
    return wownero.Wallet_numSubaddressAccounts(walletPtr);
  }
  
  @override
  int numSubaddresses({required int accountIndex}) {
    return wownero.Wallet_numSubaddresses(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  String path() {
    return wownero.Wallet_path(walletPtr);
  }
  
  @override
  void pauseRefresh() {
    wownero.Wallet_pauseRefresh(walletPtr);
  }
  
  @override
  String paymentIdFromAddress({required String strarg, required int nettype}) {
    return wownero.Wallet_paymentIdFromAddress(nettype: nettype, strarg: strarg);
  }
  
  @override
  bool paymentIdValid(String paymentId) {
    return wownero.Wallet_paymentIdValid(paymentId);
  }
  
  @override
  String publicMultisigSignerKey() {
    return wownero.Wallet_publicMultisigSignerKey(walletPtr);
  }
  
  @override
  String publicSpendKey() {
    return wownero.Wallet_publicSpendKey(walletPtr);
  }
  
  @override
  String publicViewKey() {
    return wownero.Wallet_publicViewKey(walletPtr);
  }
  
  @override
  bool reconnectDevice() {
    return wownero.Wallet_reconnectDevice(walletPtr);
  }
  
  @override
  bool refresh() {
    return wownero.Wallet_refresh(walletPtr);
  }
  
  @override
  void refreshAsync() {
    wownero.Wallet_refreshAsync(walletPtr);
  }
  
  @override
  bool rescanBlockchain() {
    return wownero.Wallet_rescanBlockchain(walletPtr);
  }
  
  @override
  void rescanBlockchainAsync() {
    wownero.Wallet_rescanBlockchainAsync(walletPtr);
  }
  
  @override
  bool rescanSpent() {
    return wownero.Wallet_rescanSpent(walletPtr);
  }
  
  @override
  Wallet2PendingTransaction restoreMultisigTransaction({required String signData}) {
    throw UnimplementedError();
  }
  
  @override
  String secretSpendKey() {
    return wownero.Wallet_secretSpendKey(walletPtr);
  }
  
  @override
  String secretViewKey() {
    return wownero.Wallet_secretViewKey(walletPtr);
  }
  
  @override
  String seed({required String seedOffset}) {
    return wownero.Wallet_seed(walletPtr, seedOffset: seedOffset);
  }
  
  @override
  void segregatePreForkOutputs({required bool segregate}) {
    wownero.Wallet_segregatePreForkOutputs(walletPtr, segregate: segregate);
  }
  
  @override
  void segregationHeight({required int height}) {
    wownero.Wallet_segregationHeight(walletPtr, height: height);
  }
  
  @override
  void setAutoRefreshInterval({required int millis}) {
    wownero.Wallet_setAutoRefreshInterval(walletPtr, millis: millis);
  }
  
  @override
  bool setCacheAttribute({required String key, required String value}) {
    return wownero.Wallet_setCacheAttribute(walletPtr, key: key, value: value);
  }
  
  @override
  void setDefaultMixin(int arg) {
    wownero.Wallet_setDefaultMixin(walletPtr, arg);
  }
  
  @override
  bool setDevicePin({required String passphrase}) {
    return wownero.Wallet_setDevicePin(walletPtr, passphrase: passphrase);
  }
  
  @override
  void setDeviceReceivedData(Pointer<UnsignedChar> data, int len) {
    throw UnimplementedError();
  }
  
  @override
  void setDeviceSendData(Pointer<UnsignedChar> data, int len) {
    throw UnimplementedError();
  }
  
  @override
  void setOffline({required bool offline}) {
    wownero.Wallet_setOffline(walletPtr, offline: offline);
  }
  
  @override
  bool setPassword({required String password}) {
    return wownero.Wallet_setPassword(walletPtr, password: password);
  }
  
  @override
  void setProxy({required String address}) {
    wownero.Wallet_setProxy(walletPtr, address: address);
  }
  
  @override
  void setRecoveringFromDevice({required bool recoveringFromDevice}) {
    wownero.Wallet_setRecoveringFromDevice(walletPtr, recoveringFromDevice: recoveringFromDevice);
  }
  
  @override
  void setRecoveringFromSeed({required bool recoveringFromSeed}) {
    wownero.Wallet_setRecoveringFromSeed(walletPtr, recoveringFromSeed: recoveringFromSeed);
  }
  
  @override
  void setRefreshFromBlockHeight({required int refresh_from_block_height}) {
    wownero.Wallet_setRefreshFromBlockHeight(walletPtr, refresh_from_block_height: refresh_from_block_height);
  }
  
  @override
  void setSeedLanguage({required String language}) {
    wownero.Wallet_setSeedLanguage(walletPtr, language: language);
  }
  
  @override
  void setSubaddressLabel({required int accountIndex, required int addressIndex, required String label}) {
    wownero.Wallet_setSubaddressLabel(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex, label: label);
  }
  
  @override
  void setSubaddressLookahead({required int major, required int minor}) {
    wownero.Wallet_setSubaddressLookahead(walletPtr, major: major, minor: minor);
  }
  
  @override
  void setTrustedDaemon({required bool arg}) {
    wownero.Wallet_setTrustedDaemon(walletPtr, arg: arg);
  }
  
  @override
  bool setUserNote({required String txid, required String note}) {
    return wownero.Wallet_setUserNote(walletPtr, txid: txid, note: note);
  }
  
  @override
  bool setupBackgroundSync({required int backgroundSyncType, required String walletPassword, required String backgroundCachePassword}) {
    return wownero.Wallet_setupBackgroundSync(walletPtr, backgroundSyncType: backgroundSyncType, walletPassword: walletPassword, backgroundCachePassword: backgroundCachePassword);
  }
  
  @override
  String signMessage({required String message, required String address}) {
    return wownero.Wallet_signMessage(walletPtr, message: message, address: address);
  }
  
  @override
  bool startBackgroundSync() {
    return wownero.Wallet_startBackgroundSync(walletPtr);
  }
  
  @override
  void startRefresh() {
    wownero.Wallet_startRefresh(walletPtr);
  }
  
  @override
  int status() {
    return wownero.Wallet_status(walletPtr);
  }
  
  @override
  void stop() {
    wownero.Wallet_stop(walletPtr);
  }
  
  @override
  bool stopBackgroundSync(String walletPassword) {
    return wownero.Wallet_stopBackgroundSync(walletPtr, walletPassword);
  }
  
  @override
  bool store({String path = ""}) {
    return wownero.Wallet_store(walletPtr, path: path);
  }
  
  @override
  Wallet2Subaddress subaddress() {
    return WowneroSubaddress(wownero.Wallet_subaddress(walletPtr));
  }
  
  @override
  Wallet2SubaddressAccount subaddressAccount() {
    return WowneroSubaddressAccount(wownero.Wallet_subaddressAccount(walletPtr));
  }
  
  @override
  bool submitTransaction(String filename) {
    return wownero.Wallet_submitTransaction(walletPtr, filename);
  }
  
  @override
  bool submitTransactionUR(String input) {
    throw UnimplementedError();
  }
  
  @override
  bool synchronized() {
    return wownero.Wallet_synchronized(walletPtr);
  }
  
  @override
  bool trustedDaemon() {
    return wownero.Wallet_trustedDaemon(walletPtr);
  }
  
  @override
  bool unlockKeysFile() {
    return wownero.Wallet_unlockKeysFile(walletPtr);
  }
  
  @override
  int unlockedBalance({required int accountIndex}) {
    return wownero.Wallet_unlockedBalance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  int useForkRules({required int version, required int earlyBlocks}) {
    return wownero.Wallet_useForkRules(walletPtr, version: version, earlyBlocks: earlyBlocks);
  }
  
  @override
  bool verifySignedMessage({required String message, required String address, required String signature}) {
    return wownero.Wallet_verifySignedMessage(walletPtr, message: message, address: address, signature: signature);
  }
  
  @override
  int viewOnlyBalance({required int accountIndex}) {
    return wownero.Wallet_viewOnlyBalance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  bool watchOnly() {
    return wownero.Wallet_watchOnly(walletPtr);
  }

  @override
  int ffiAddress() => walletPtr.address;
}

class WowneroWalletManager implements Wallet2WalletManager {
  WowneroWalletManager(this.wmPtr);

  final wownero.WalletManager wmPtr;
  
  @override
  Future<int> blockTarget() async {
    return wownero.WalletManager_blockTarget(wmPtr);
  }
  
  @override
  Future<int> blockchainHeight() async {
    return wownero.WalletManager_blockchainHeight(wmPtr);
  }
  
  @override
  Future<int> blockchainTargetHeight() async {
    return wownero.WalletManager_blockchainTargetHeight(wmPtr);
  }
  
  @override
  Wallet2Wallet createDeterministicWalletFromSpendKey({required String path, required String password, String language = "English", int networkType = 0, required String spendKeyString, required bool newWallet, required int restoreHeight, int kdfRounds = 1}) {
    final wallet = wownero.WalletManager_createDeterministicWalletFromSpendKey(wmPtr, path: path, password: password, language: language, networkType: networkType, spendKeyString: spendKeyString, newWallet: newWallet, restoreHeight: restoreHeight, kdfRounds: kdfRounds);
    return WowneroWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWallet({required String path, required String password, String language = "English", int networkType = 0}) {
    final wallet = wownero.WalletManager_createWallet(wmPtr, path: path, password: password, language: language, networkType: networkType);
    return WowneroWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromDevice({required String path, required String password, int networkType = 0, required String deviceName, int restoreHeight = 0, String subaddressLookahead = "", int kdfRounds = 1}) {
    throw UnimplementedError();
  }
  
  @override
  Wallet2Wallet createWalletFromKeys({required String path, required String password, String language = "English", int nettype = 1, required int restoreHeight, required String addressString, required String viewKeyString, required String spendKeyString, int kdf_rounds = 1}) {
    final wallet = wownero.WalletManager_createWalletFromKeys(wmPtr, path: path, password: password, language: language, nettype: nettype, restoreHeight: restoreHeight, addressString: addressString, viewKeyString: viewKeyString, spendKeyString: spendKeyString);
    return WowneroWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromPolyseed({required String path, required String password, int networkType = 0, required String mnemonic, required String seedOffset, required bool newWallet, required int restoreHeight, required int kdfRounds}) {
    final wallet = wownero.WalletManager_createWalletFromPolyseed(wmPtr, path: path, password: password, networkType: networkType, mnemonic: mnemonic, seedOffset: seedOffset, newWallet: newWallet, restoreHeight: restoreHeight, kdfRounds: kdfRounds);
    return WowneroWallet(wallet);
  }
  
  @override
  String errorString() {
    return wownero.WalletManager_errorString(wmPtr);
  }
  
  @override
  List<String> findWallets({required String path}) {
    return wownero.WalletManager_findWallets(wmPtr, path: path);
  }
  
  @override
  bool isMining() {
    return wownero.WalletManager_isMining(wmPtr);
  }
  
  @override
  double miningHashRate() {
    return wownero.WalletManager_miningHashRate(wmPtr);
  }
  
  @override
  int networkDifficulty() {
    return wownero.WalletManager_networkDifficulty(wmPtr);
  }
  
  @override
  Wallet2Wallet openWallet({required String path, required String password, int networkType = 0}) {
    final wallet = wownero.WalletManager_openWallet(wmPtr, path: path, password: password, networkType: networkType);
    return WowneroWallet(wallet);
  }
  
  @override
  int queryWalletDevice({required String keysFileName, required String password, required int kdfRounds}) {
    throw UnimplementedError();
  }
  
  @override
  Wallet2Wallet recoveryWallet({required String path, required String password, required String mnemonic, int networkType = 0, required int restoreHeight, int kdfRounds = 0, required String seedOffset}) {
    final wallet = wownero.WalletManager_recoveryWallet(wmPtr, path: path, password: password, mnemonic: mnemonic, networkType: networkType, restoreHeight: restoreHeight, kdfRounds: kdfRounds, seedOffset: seedOffset);
    return WowneroWallet(wallet);
  }
  
  @override
  String resolveOpenAlias({required String address, required bool dnssecValid}) {
    return wownero.WalletManager_resolveOpenAlias(wmPtr, address: address, dnssecValid: dnssecValid);
  }
  
  @override
  void setDaemonAddress(String address) {
    wownero.WalletManager_setDaemonAddress(wmPtr, address);
  }
  
  @override
  bool setProxy(String address) {
    return wownero.WalletManager_setProxy(wmPtr, address);
  }
  
  @override
  bool startMining({required String address, required int threads, required bool backgroundMining, required bool ignoreBattery}) {
    return wownero.WalletManager_startMining(wmPtr, address: address, threads: threads, backgroundMining: backgroundMining, ignoreBattery: ignoreBattery);
  }
  
  @override
  bool stopMining(String address) {
    return wownero.WalletManager_stopMining(wmPtr, address);
  }
  
  @override
  bool verifyWalletPassword({required String keysFileName, required String password, required bool noSpendKey, required int kdfRounds}) {
    return wownero.WalletManager_verifyWalletPassword(wmPtr, keysFileName: keysFileName, password: password, noSpendKey: noSpendKey, kdfRounds: kdfRounds);
  }
  
  @override
  bool walletExists(String path) {
    return wownero.WalletManager_walletExists(wmPtr, path);
  }

  @override
  int ffiAddress() => wmPtr.address;
}

class WowneroWalletManagerFactory implements Wallet2WalletManagerFactory {
  @override
  Wallet2WalletManager getWalletManager() {
    return WowneroWalletManager(wownero.WalletManagerFactory_getWalletManager());
  }

  @override
  void setLogCategories(String categories) {
    wownero.WalletManagerFactory_setLogCategories(categories);
  }

  @override
  void setLogLevel(int level) {
    wownero.WalletManagerFactory_setLogLevel(level);
  }

  @override
  int ffiAddress() => 0;
}
