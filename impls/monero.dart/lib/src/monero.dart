// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:ffi';

import 'package:monero/monero.dart' as monero;
import 'package:monero/src/wallet2.dart';

class Monero implements Wallet2 {
  @override
  Wallet2WalletManagerFactory walletManagerFactory() {
    return MoneroWalletManagerFactory();
  }
  
  @override
  int ffiAddress() => 0;
}

class MoneroAddressBook implements Wallet2AddressBook {
  MoneroAddressBook(this.addressBookPtr);

  final monero.AddressBook addressBookPtr;
  
  @override
  bool addRow({required String dstAddr, required String paymentId, required String description}) {
    return monero.AddressBook_addRow(addressBookPtr, dstAddr: dstAddr, paymentId: paymentId, description: description);
  }
  
  @override
  bool deleteRow({required int rowId}) {
    return monero.AddressBook_deleteRow(addressBookPtr, rowId: rowId);
  }
  
  @override
  int errorCode() {
    return monero.AddressBook_errorCode(addressBookPtr);
  }
  
  @override
  Wallet2AddressBookRow getAll_byIndex(int index) {
    final row = monero.AddressBook_getAll_byIndex(addressBookPtr, index: index);
    return MoneroAddressBookRow(row);
  }
  
  @override
  int getAll_size() {
    return monero.AddressBook_getAll_size(addressBookPtr);
  }
  
  @override
  int lookupPaymentID({required String paymentId}) {
    return monero.AddressBook_lookupPaymentID(addressBookPtr, paymentId: paymentId);
  }
  
  @override
  void refresh() {
    monero.AddressBook_refresh(addressBookPtr);
  }
  
  @override
  bool setDescription({required int rowId, required String description}) {
    return monero.AddressBook_setDescription(addressBookPtr, rowId: rowId, description: description);
  }
  
  @override
  int ffiAddress() => addressBookPtr.address;
}

class MoneroAddressBookRow implements Wallet2AddressBookRow {
  MoneroAddressBookRow(this.addressBookRowPtr);

  final monero.AddressBookRow addressBookRowPtr;
  
  @override
  String extra() {
    return monero.AddressBookRow_extra(addressBookRowPtr);
  }
  
  @override
  String getAddress() {
    return monero.AddressBookRow_getAddress(addressBookRowPtr);
  }
  
  @override
  String getDescription() {
    return monero.AddressBookRow_getDescription(addressBookRowPtr);
  }
  
  @override
  String getPaymentId() {
    return monero.AddressBookRow_getPaymentId(addressBookRowPtr);
  }
  
  @override
  int getRowId() {
    return monero.AddressBookRow_getRowId(addressBookRowPtr);
  }

  @override
  int ffiAddress() => addressBookRowPtr.address;
}

class MoneroCoins implements Wallet2Coins {
  MoneroCoins(this.coinsPtr);

  final monero.Coins coinsPtr;
  
  @override
  Wallet2CoinsInfo coin(int index) {
    final coin = monero.Coins_coin(coinsPtr, index);
    return MoneroCoinsInfo(coin);
  }
  
  @override
  int count() {
    return monero.Coins_count(coinsPtr);
  }
  
  @override
  Wallet2CoinsInfo getAll_byIndex(int index) {
    final coin = monero.Coins_getAll_byIndex(coinsPtr, index);
    return MoneroCoinsInfo(coin);
  }
  
  @override
  int getAll_size() {
    return monero.Coins_getAll_size(coinsPtr);
  }
  
  @override
  bool isTransferUnlocked({required int unlockTime, required int blockHeight}) {
    return monero.Coins_isTransferUnlocked(coinsPtr, unlockTime: unlockTime, blockHeight: blockHeight);
  }
  
  @override
  void refresh() {
    monero.Coins_refresh(coinsPtr);
  }
  
  @override
  void setFrozen({required int index}) {
    monero.Coins_setFrozen(coinsPtr, index: index);
  }
  
  @override
  void setFrozenByPublicKey({required String publicKey}) {
    monero.Coins_setFrozenByPublicKey(coinsPtr, publicKey: publicKey);
  }
  
  @override
  void thaw({required int index}) {
    monero.Coins_thaw(coinsPtr, index: index);
  }
  
  @override
  void thawByPublicKey({required String publicKey}) {
    monero.Coins_thawByPublicKey(coinsPtr, publicKey: publicKey);
  }

  @override
  int ffiAddress() => coinsPtr.address;
}

class MoneroCoinsInfo implements Wallet2CoinsInfo {
  MoneroCoinsInfo(this.coinsInfoPtr);

  final monero.CoinsInfo coinsInfoPtr;
  
  @override
  String address() {
    return monero.CoinsInfo_address(coinsInfoPtr);
  }
  
  @override
  String addressLabel() {
    return monero.CoinsInfo_addressLabel(coinsInfoPtr);
  }
  
  @override
  int amount() {
    return monero.CoinsInfo_amount(coinsInfoPtr);
  }
  
  @override
  int blockHeight() {
    return monero.CoinsInfo_blockHeight(coinsInfoPtr);
  }
  
  @override
  bool coinbase() {
    return monero.CoinsInfo_coinbase(coinsInfoPtr);
  }
  
  @override
  String description() {
    return monero.CoinsInfo_description(coinsInfoPtr);
  }
  
  @override
  bool frozen() {
    return monero.CoinsInfo_frozen(coinsInfoPtr);
  }
  
  @override
  int globalOutputIndex() {
    return monero.CoinsInfo_globalOutputIndex(coinsInfoPtr);
  }
  
  @override
  String hash() {
    return monero.CoinsInfo_hash(coinsInfoPtr);
  }
  
  @override
  int internalOutputIndex() {
    return monero.CoinsInfo_internalOutputIndex(coinsInfoPtr);
  }
  
  @override
  String keyImage() {
    return monero.CoinsInfo_keyImage(coinsInfoPtr);
  }
  
  @override
  bool keyImageKnown() {
    return monero.CoinsInfo_keyImageKnown(coinsInfoPtr);
  }
  
  @override
  int pkIndex() {
    return monero.CoinsInfo_pkIndex(coinsInfoPtr);
  }
  
  @override
  String pubKey() {
    return monero.CoinsInfo_pubKey(coinsInfoPtr);
  }
  
  @override
  bool rct() {
    return monero.CoinsInfo_rct(coinsInfoPtr);
  }
  
  @override
  bool spent() {
    return monero.CoinsInfo_spent(coinsInfoPtr);
  }
  
  @override
  int spentHeight() {
    return monero.CoinsInfo_spentHeight(coinsInfoPtr);
  }
  
  @override
  int subaddrAccount() {
    return monero.CoinsInfo_subaddrAccount(coinsInfoPtr);
  }
  
  @override
  int subaddrIndex() {
    return monero.CoinsInfo_subaddrIndex(coinsInfoPtr);
  }
  
  @override
  int unlockTime() {
    return monero.CoinsInfo_unlockTime(coinsInfoPtr);
  }
  
  @override
  bool unlocked() {
    return monero.CoinsInfo_unlocked(coinsInfoPtr);
  }

  @override
  int ffiAddress() => coinsInfoPtr.address;
}

class MoneroDeviceProgress implements Wallet2DeviceProgress {
  MoneroDeviceProgress(this.deviceProgressPtr);

  final monero.DeviceProgress deviceProgressPtr;
  
  @override
  bool indeterminate() {
    return monero.DeviceProgress_indeterminate(deviceProgressPtr);
  }
  
  @override
  bool progress() {
    return monero.DeviceProgress_progress(deviceProgressPtr);
  }

  @override
  int ffiAddress() => deviceProgressPtr.address;
}

class MoneroWalletListener implements Wallet2WalletListener {
  MoneroWalletListener(this.walletListenerPtr);

  final monero.WalletListener walletListenerPtr;
  
  @override
  int height() {
    return monero.MONERO_cw_WalletListener_height(walletListenerPtr);
  }
  
  @override
  bool isNeedToRefresh() {
    return monero.MONERO_cw_WalletListener_isNeedToRefresh(walletListenerPtr);
  }
  
  @override
  bool isNewTransactionExist() {
    return monero.MONERO_cw_WalletListener_isNewTransactionExist(walletListenerPtr);
  }
  
  @override
  void resetIsNewTransactionExist() {
    monero.MONERO_cw_WalletListener_resetIsNewTransactionExist(walletListenerPtr);
  }
  
  @override
  void resetNeedToRefresh() {
    monero.MONERO_cw_WalletListener_resetNeedToRefresh(walletListenerPtr);
  }

  @override
  int ffiAddress() => walletListenerPtr.address;
}

class MoneroWalletChecksum implements Wallet2Checksum {
  MoneroWalletChecksum();

  @override
  String checksum_wallet2_api_c_cpp() {
    return monero.MONERO_checksum_wallet2_api_c_cpp();
  }
  
  @override
  String checksum_wallet2_api_c_exp() {
    return monero.MONERO_checksum_wallet2_api_c_exp();
  }
  
  @override
  String checksum_wallet2_api_c_h() {
    return monero.MONERO_checksum_wallet2_api_c_h();
  }

  @override
  int ffiAddress() => 0;
}

class MoneroFree implements Wallet2Free {
  MoneroFree();

  @override
  void free(Pointer<Void> ptr) {
    monero.MONERO_free(ptr);
  }

  @override
  int ffiAddress() => 0;
}

class MoneroMultisigState implements Wallet2MultisigState {
  MoneroMultisigState(this.multisigStatePtr);

  final monero.MultisigState multisigStatePtr;
  
  @override
  bool isMultisig(Pointer<Void> ptr) {
    return monero.MultisigState_isMultisig(multisigStatePtr);
  }
  
  @override
  bool isReady(Pointer<Void> ptr) {
    return monero.MultisigState_isReady(multisigStatePtr);
  }
  
  @override
  int threshold(Pointer<Void> ptr) {
    return monero.MultisigState_threshold(multisigStatePtr);
  }
  
  @override
  int total(Pointer<Void> ptr) {
    return monero.MultisigState_total(multisigStatePtr);
  }

  @override
  int ffiAddress() => multisigStatePtr.address;
}

class MoneroPendingTransaction implements Wallet2PendingTransaction {
  MoneroPendingTransaction(this.pendingTransactionPtr);

  final monero.PendingTransaction pendingTransactionPtr;
  
  @override
  int amount() {
    return monero.PendingTransaction_amount(pendingTransactionPtr);
  }
  
  @override
  bool commit({required String filename, required bool overwrite}) {
    return monero.PendingTransaction_commit(pendingTransactionPtr, filename: filename, overwrite: overwrite);
  }
  
  @override
  String commitUR(int max_fragment_length) {
    return monero.PendingTransaction_commitUR(pendingTransactionPtr, max_fragment_length);
  }
  
  @override
  int dust() {
    return monero.PendingTransaction_dust(pendingTransactionPtr);
  }
  
  @override
  String errorString() {
    return monero.PendingTransaction_errorString(pendingTransactionPtr);
  }
  
  @override
  int fee() {
    return monero.PendingTransaction_fee(pendingTransactionPtr);
  }
  
  @override
  String hex(String separator) {
    return monero.PendingTransaction_hex(pendingTransactionPtr, separator);
  }
  
  @override
  String multisigSignData() {
    return monero.PendingTransaction_multisigSignData(pendingTransactionPtr);
  }
  
  @override
  void signMultisigTx() {
    monero.PendingTransaction_signMultisigTx(pendingTransactionPtr);
  }
  
  @override
  String signersKeys(String separator) {
    return monero.PendingTransaction_signersKeys(pendingTransactionPtr, separator);
  }
  
  @override
  int status() {
    return monero.PendingTransaction_status(pendingTransactionPtr);
  }
  
  @override
  String subaddrAccount(String separator) {
    return monero.PendingTransaction_subaddrAccount(pendingTransactionPtr, separator);
  }
  
  @override
  String subaddrIndices(String separator) {
    return monero.PendingTransaction_subaddrIndices(pendingTransactionPtr, separator);
  }
  
  @override
  int txCount() {
    return monero.PendingTransaction_txCount(pendingTransactionPtr);
  }
  
  @override
  String txid(String separator) {
    return monero.PendingTransaction_txid(pendingTransactionPtr, separator);
  }

  @override
  int ffiAddress() => pendingTransactionPtr.address;
}

class MoneroSubaddress implements Wallet2Subaddress {
  MoneroSubaddress(this.subaddressPtr);

  final monero.Subaddress subaddressPtr;
  
  @override
  void addRow({required int accountIndex, required String label}) {
    monero.Subaddress_addRow(subaddressPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  Wallet2SubaddressRow getAll_byIndex(int index) {
    final row = monero.Subaddress_getAll_byIndex(subaddressPtr, index: index);
    return MoneroSubaddressRow(row);
  }
  
  @override
  int getAll_size() {
    return monero.Subaddress_getAll_size(subaddressPtr);
  }
  
  @override
  void refresh({required int accountIndex, required String label}) {
    monero.Subaddress_refresh(subaddressPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  void setLabel({required int accountIndex, required int addressIndex, required String label}) {
    monero.Subaddress_setLabel(subaddressPtr, accountIndex: accountIndex, addressIndex: addressIndex, label: label);
  }

  @override
  int ffiAddress() => subaddressPtr.address;
}

class MoneroSubaddressAccount implements Wallet2SubaddressAccount {
  MoneroSubaddressAccount(this.subaddressAccountPtr);

  final monero.SubaddressAccount subaddressAccountPtr;
  
  @override
  void addRow({required String label}) {
    monero.SubaddressAccount_addRow(subaddressAccountPtr, label: label);
  }
  
  @override
  Wallet2SubaddressAccountRow getAll_byIndex(int index) {
    final row = monero.SubaddressAccount_getAll_byIndex(subaddressAccountPtr, index: index);
    return MoneroSubaddressAccountRow(row);
  }
  
  @override
  int getAll_size() {
    return monero.SubaddressAccount_getAll_size(subaddressAccountPtr);
  }
  
  @override
  void refresh() {
    monero.SubaddressAccount_refresh(subaddressAccountPtr);
  }
  
  @override
  void setLabel({required int accountIndex, required String label}) {
    monero.SubaddressAccount_setLabel(subaddressAccountPtr, accountIndex: accountIndex, label: label);
  }

  @override
  int ffiAddress() => subaddressAccountPtr.address;
}

class MoneroSubaddressAccountRow implements Wallet2SubaddressAccountRow {
  MoneroSubaddressAccountRow(this.subaddressAccountRowPtr);

  final monero.SubaddressAccountRow subaddressAccountRowPtr;
  
  @override
  String extra() {
    return monero.SubaddressAccountRow_extra(subaddressAccountRowPtr);
  }
  
  @override
  String getAddress() {
    return monero.SubaddressAccountRow_getAddress(subaddressAccountRowPtr);
  }
  
  @override
  String getBalance() {
    return monero.SubaddressAccountRow_getBalance(subaddressAccountRowPtr);
  }
  
  @override
  String getLabel() {
    return monero.SubaddressAccountRow_getLabel(subaddressAccountRowPtr);
  }
  
  @override
  int getRowId() {
    return monero.SubaddressAccountRow_getRowId(subaddressAccountRowPtr);
  }
  
  @override
  String getUnlockedBalance() {
    return monero.SubaddressAccountRow_getUnlockedBalance(subaddressAccountRowPtr);
  }

  @override
  int ffiAddress() => subaddressAccountRowPtr.address;
}

class MoneroSubaddressRow implements Wallet2SubaddressRow {
  MoneroSubaddressRow(this.subaddressRowPtr);

  final monero.SubaddressRow subaddressRowPtr;
  
  @override
  String extra() {
    return monero.SubaddressRow_extra(subaddressRowPtr);
  }
  
  @override
  String getAddress() {
    return monero.SubaddressRow_getAddress(subaddressRowPtr);
  }
  
  @override
  String getLabel() {
    return monero.SubaddressRow_getLabel(subaddressRowPtr);
  }
  
  @override
  int getRowId() {
    return monero.SubaddressRow_getRowId(subaddressRowPtr);
  }

  @override
  int ffiAddress() => subaddressRowPtr.address;
}

class MoneroTransactionHistory implements Wallet2TransactionHistory {
  MoneroTransactionHistory(this.transactionHistoryPtr);

  final monero.TransactionHistory transactionHistoryPtr;
  
  @override
  int count() {
    return monero.TransactionHistory_count(transactionHistoryPtr);
  }
  
  @override
  void refresh() {
    monero.TransactionHistory_refresh(transactionHistoryPtr);
  }
  
  @override
  void setTxNote({required String txid, required String note}) {
    monero.TransactionHistory_setTxNote(transactionHistoryPtr, txid: txid, note: note);
  }
  
  @override
  Wallet2TransactionInfo transaction(int index) {
    final tx = monero.TransactionHistory_transaction(transactionHistoryPtr, index: index);
    return MoneroTransactionInfo(tx);
  }
  
  @override
  Wallet2TransactionInfo transactionById(String txid) {
    final tx = monero.TransactionHistory_transactionById(transactionHistoryPtr, txid: txid);
    return MoneroTransactionInfo(tx);
  }

  @override
  int ffiAddress() => transactionHistoryPtr.address;
}

class MoneroTransactionInfo implements Wallet2TransactionInfo {
  MoneroTransactionInfo(this.transactionInfoPtr);

  final monero.TransactionInfo transactionInfoPtr;
  
  @override
  int amount() {
    return monero.TransactionInfo_amount(transactionInfoPtr);
  }
  
  @override
  int blockHeight() {
    return monero.TransactionInfo_blockHeight(transactionInfoPtr);
  }
  
  @override
  int confirmations() {
    return monero.TransactionInfo_confirmations(transactionInfoPtr);
  }
  
  @override
  String description() {
    return monero.TransactionInfo_description(transactionInfoPtr);
  }
  
  @override
  int direction() {
    return monero.TransactionInfo_direction(transactionInfoPtr).index;
  }
  
  @override
  int fee() {
    return monero.TransactionInfo_fee(transactionInfoPtr);
  }
  
  @override
  String hash() {
    return monero.TransactionInfo_hash(transactionInfoPtr);
  }
  
  @override
  bool isCoinbase() {
    return monero.TransactionInfo_isCoinbase(transactionInfoPtr);
  }
  
  @override
  bool isFailed() {
    return monero.TransactionInfo_isFailed(transactionInfoPtr);
  }
  
  @override
  bool isPending() {
    return monero.TransactionInfo_isPending(transactionInfoPtr);
  }
  
  @override
  String label() {
    return monero.TransactionInfo_label(transactionInfoPtr);
  }
  
  @override
  String paymentId() {
    return monero.TransactionInfo_paymentId(transactionInfoPtr);
  }
  
  @override
  int subaddrAccount() {
    return monero.TransactionInfo_subaddrAccount(transactionInfoPtr);
  }
  
  @override
  String subaddrIndex() {
    return monero.TransactionInfo_subaddrIndex(transactionInfoPtr);
  }
  
  @override
  int timestamp() {
    return monero.TransactionInfo_timestamp(transactionInfoPtr);
  }
  
  @override
  String transfers_address(int index) {
    return monero.TransactionInfo_transfers_address(transactionInfoPtr, index);
  }
  
  @override
  int transfers_amount(int index) {
    return monero.TransactionInfo_transfers_amount(transactionInfoPtr, index);
  }
  
  @override
  int transfers_count() {
    return monero.TransactionInfo_transfers_count(transactionInfoPtr);
  }
  
  @override
  int unlockTime() {
    return monero.TransactionInfo_unlockTime(transactionInfoPtr);
  }
  
  @override
  int ffiAddress() => transactionInfoPtr.address;
}

class MoneroUnsignedTransaction implements Wallet2UnsignedTransaction {
  MoneroUnsignedTransaction(this.unsignedTransactionPtr);

  final monero.UnsignedTransaction unsignedTransactionPtr;
  
  @override
  String amount() {
    return monero.UnsignedTransaction_amount(unsignedTransactionPtr);
  }
  
  @override
  String confirmationMessage() {
    return monero.UnsignedTransaction_confirmationMessage(unsignedTransactionPtr);
  }
  
  @override
  String errorString() {
    return monero.UnsignedTransaction_errorString(unsignedTransactionPtr);
  }
  
  @override
  String fee() {
    return monero.UnsignedTransaction_fee(unsignedTransactionPtr);
  }
  
  @override
  int minMixinCount() {
    return monero.UnsignedTransaction_minMixinCount(unsignedTransactionPtr);
  }
  
  @override
  String mixin() {
    return monero.UnsignedTransaction_mixin(unsignedTransactionPtr);
  }
  
  @override
  String paymentId() {
    return monero.UnsignedTransaction_paymentId(unsignedTransactionPtr);
  }
  
  @override
  String recipientAddress() {
    return monero.UnsignedTransaction_recipientAddress(unsignedTransactionPtr);
  }
  
  @override
  bool sign(String signedFileName) {
    return monero.UnsignedTransaction_sign(unsignedTransactionPtr, signedFileName);
  }
  
  @override
  String signUR(int max_fragment_length) {
    return monero.UnsignedTransaction_signUR(unsignedTransactionPtr, max_fragment_length);
  }
  
  @override
  int status() {
    return monero.UnsignedTransaction_status(unsignedTransactionPtr);
  }
  
  @override
  int txCount() {
    return monero.UnsignedTransaction_txCount(unsignedTransactionPtr);
  }
  
  @override
  int ffiAddress() => unsignedTransactionPtr.address;
}

class MoneroWallet implements Wallet2Wallet {
  MoneroWallet(this.walletPtr);

  final monero.wallet walletPtr;
  
  @override
  void addSubaddress({required int accountIndex, String label = ""}) {
    monero.Wallet_addSubaddress(walletPtr, accountIndex: accountIndex, label: label);
  }
  
  @override
  void addSubaddressAccount({String label = ""}) {
    monero.Wallet_addSubaddressAccount(walletPtr, label: label);
  }
  
  @override
  String address({int accountIndex = 0, int addressIndex = 0}) {
    return monero.Wallet_address(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  Wallet2AddressBook addressBook() {
    return MoneroAddressBook(monero.Wallet_addressBook(walletPtr));
  }
  
  @override
  bool addressValid(String address, int networkType) {
    return monero.Wallet_addressValid(address, networkType);
  }
  
  @override
  int amountFromDouble(double amount) {
    return monero.Wallet_amountFromDouble(amount);
  }
  
  @override
  int amountFromString(String amount) {
    return monero.Wallet_amountFromString(amount);
  }
  
  @override
  int approximateBlockChainHeight() {
    return monero.Wallet_approximateBlockChainHeight(walletPtr);
  }
  
  @override
  int autoRefreshInterval() {
    return monero.Wallet_autoRefreshInterval(walletPtr);
  }
  
  @override
  int balance({required int accountIndex}) {
    return monero.Wallet_balance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  int blockChainHeight() {
    return monero.Wallet_blockChainHeight(walletPtr);
  }
  
  @override
  Wallet2Coins coins() {
    return MoneroCoins(monero.Wallet_coins(walletPtr));
  }
  
  @override
  int coldKeyImageSync({required int spent, required int unspent}) {
    return monero.Wallet_coldKeyImageSync(walletPtr, spent: spent, unspent: unspent);
  }
  
  @override
  bool connectToDaemon() {
    return monero.Wallet_connectToDaemon(walletPtr);
  }
  
  @override
  int connected() {
    return monero.Wallet_connected(walletPtr);
  }
  
  @override
  String createPolyseed({String language = "English"}) {
    return monero.Wallet_createPolyseed(language: language);
  }
  
  @override
  Wallet2PendingTransaction createTransaction({required String dst_addr, required String payment_id, required int amount, required int mixin_count, required int pendingTransactionPriority, required int subaddr_account, List<String> preferredInputs = const []}) {
    final transaction = monero.Wallet_createTransaction(walletPtr, dst_addr: dst_addr, payment_id: payment_id, amount: amount, mixin_count: mixin_count, pendingTransactionPriority: pendingTransactionPriority, subaddr_account: subaddr_account, preferredInputs: preferredInputs);
    return MoneroPendingTransaction(transaction);
  }
  
  @override
  Wallet2PendingTransaction createTransactionMultDest({required List<String> dstAddr, String paymentId = "", required bool isSweepAll, required List<int> amounts, required int mixinCount, required int pendingTransactionPriority, required int subaddr_account, List<String> preferredInputs = const []}) {
    final transaction = monero.Wallet_createTransactionMultDest(walletPtr, dstAddr: dstAddr, paymentId: paymentId, isSweepAll: isSweepAll, amounts: amounts, mixinCount: mixinCount, pendingTransactionPriority: pendingTransactionPriority, subaddr_account: subaddr_account, preferredInputs: preferredInputs);
    return MoneroPendingTransaction(transaction);
  }
  
  @override
  bool createWatchOnly({required String path, required String password, required String language}) {
    return monero.Wallet_createWatchOnly(walletPtr, path: path, password: password, language: language);
  }
  
  @override
  int daemonBlockChainHeight() {
    return monero.Wallet_daemonBlockChainHeight(walletPtr);
  }
  
  @override
  int defaultMixin() {
    return monero.Wallet_defaultMixin(walletPtr);
  }
  
  @override
  String deviceShowAddress({required int accountIndex, required int addressIndex}) {
    return monero.Wallet_deviceShowAddress(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  String displayAmount(int amount) {
    return monero.Wallet_displayAmount(amount);
  }
  
  @override
  String errorString() {
    return monero.Wallet_errorString(walletPtr);
  }
  
  @override
  int estimateBlockChainHeight() {
    return monero.Wallet_estimateBlockChainHeight(walletPtr);
  }
  
  @override
  String exchangeMultisigKeys({required List<String> info, required bool force_update_use_with_caution}) {
    return monero.Wallet_exchangeMultisigKeys(walletPtr, info: info, force_update_use_with_caution: force_update_use_with_caution);
  }
  
  @override
  bool exportKeyImages(String filename, {required bool all}) {
    return monero.Wallet_exportKeyImages(walletPtr, filename, all: all);
  }
  
  @override
  String exportKeyImagesUR({int max_fragment_length = 130, bool all = false}) {
    return monero.Wallet_exportKeyImagesUR(walletPtr, max_fragment_length: max_fragment_length, all: all);
  }
  
  @override
  List<String> exportMultisigImages({required List<String> info}) {
    return monero.Wallet_exportMultisigImages(walletPtr, info: info, force_update_use_with_caution: false);
  }
  
  @override
  bool exportOutputs(String filename, {required bool all}) {
    return monero.Wallet_exportOutputs(walletPtr, filename, all: all);
  }
  
  @override
  String exportOutputsUR({int max_fragment_length = 130, bool all = false}) {
    return monero.Wallet_exportOutputsUR(walletPtr, max_fragment_length: max_fragment_length, all: all);
  }
  
  @override
  String filename() {
    return monero.Wallet_filename(walletPtr);
  }
  
  @override
  String genPaymentId() {
    return monero.Wallet_genPaymentId();
  }
  
  @override
  int getBackgroundSyncType() {
    return monero.Wallet_getBackgroundSyncType(walletPtr);
  }
  
  @override
  int getBytesReceived() {
    return monero.Wallet_getBytesReceived(walletPtr);
  }
  
  @override
  int getBytesSent() {
    throw UnimplementedError();
  }
  
  @override
  String getCacheAttribute({required String key}) {
    return monero.Wallet_getCacheAttribute(walletPtr, key: key);
  }
  
  @override
  int getDeviceType() {
    return monero.Wallet_getDeviceType(walletPtr);
  }
  
  @override
  String getMultisigInfo() {
    return monero.Wallet_getMultisigInfo(walletPtr);
  }
  
  @override
  String getPassword() {
    return monero.Wallet_getPassword(walletPtr);
  }
  
  @override
  String getPolyseed({required String passphrase}) {
    return monero.Wallet_getPolyseed(walletPtr, passphrase: passphrase);
  }
  
  @override
  Pointer<UnsignedChar> getReceivedFromDevice() {
    return monero.Wallet_getReceivedFromDevice(walletPtr);
  }
  
  @override
  int getReceivedFromDeviceLength() {
    return monero.Wallet_getReceivedFromDeviceLength(walletPtr);
  }
  
  @override
  int getRefreshFromBlockHeight() {
    return monero.Wallet_getRefreshFromBlockHeight(walletPtr);
  }
  
  @override
  String getSeedLanguage() {
    return monero.Wallet_getSeedLanguage(walletPtr);
  }
  
  @override
  Pointer<UnsignedChar> getSendToDevice() {
    return monero.Wallet_getSendToDevice(walletPtr);
  }
  
  @override
  int getSendToDeviceLength() {
    return monero.Wallet_getSendToDeviceLength(walletPtr);
  }
  
  @override
  bool getStateIsConnected() {
    return monero.Wallet_getStateIsConnected(walletPtr);
  }
  
  @override
  String getSubaddressLabel({required int accountIndex, required int addressIndex}) {
    return monero.Wallet_getSubaddressLabel(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex);
  }
  
  @override
  String getTxKey({required String txid}) {
    return monero.Wallet_getTxKey(walletPtr, txid: txid);
  }
  
  @override
  String getUserNote({required String txid}) {
    return monero.Wallet_getUserNote(walletPtr, txid: txid);
  }
  
  @override
  bool getWaitsForDeviceReceive() {
    return monero.Wallet_getWaitsForDeviceReceive(walletPtr);
  }
  
  @override
  bool getWaitsForDeviceSend() {
    return monero.Wallet_getWaitsForDeviceSend(walletPtr);
  }
  
  @override
  Wallet2WalletListener getWalletListener() {
    final listener = monero.MONERO_cw_getWalletListener(walletPtr);
    return MoneroWalletListener(listener);
  }
  
  @override
  int hasMultisigPartialKeyImages() {
    return monero.Wallet_hasMultisigPartialKeyImages(walletPtr);
  }
  
  @override
  bool hasUnknownKeyImages() {
    return monero.Wallet_hasUnknownKeyImages(walletPtr);
  }
  
  @override
  Wallet2TransactionHistory history() {
    return MoneroTransactionHistory(monero.Wallet_history(walletPtr));
  }
  
  @override
  bool importKeyImages(String filename) {
    return monero.Wallet_importKeyImages(walletPtr, filename);
  }
  
  @override
  bool importKeyImagesUR(String input) {
    return monero.Wallet_importKeyImagesUR(walletPtr, input);
  }
  
  @override
  int importMultisigImages({required List<String> info}) {
    return monero.Wallet_importMultisigImages(walletPtr, info: info);
  }
  
  @override
  bool importOutputs(String filename) {
    return monero.Wallet_importOutputs(walletPtr, filename);
  }
  
  @override
  bool importOutputsUR(String input) {
    return monero.Wallet_importOutputsUR(walletPtr, input);
  }
  
  @override
  bool init({required String daemonAddress, int upperTransacationSizeLimit = 0, String daemonUsername = "", String daemonPassword = "", bool useSsl = false, bool lightWallet = false, String proxyAddress = ""}) {
    return monero.Wallet_init(walletPtr, daemonAddress: daemonAddress, upperTransacationSizeLimit: upperTransacationSizeLimit, daemonUsername: daemonUsername, daemonPassword: daemonPassword, useSsl: useSsl, lightWallet: lightWallet, proxyAddress: proxyAddress);
  }
  
  @override
  void init3({required String argv0, required String defaultLogBaseName, required String logPath, required bool console}) {
    return monero.Wallet_init3(walletPtr, argv0: argv0, defaultLogBaseName: defaultLogBaseName, logPath: logPath, console: console);
  }
  
  @override
  String integratedAddress({required String paymentId}) {
    return monero.Wallet_integratedAddress(walletPtr, paymentId: paymentId);
  }
  
  @override
  bool isBackgroundSyncing() {
    return monero.Wallet_isBackgroundSyncing(walletPtr);
  }
  
  @override
  bool isBackgroundWallet() {
    return monero.Wallet_isBackgroundWallet(walletPtr);
  }
  
  @override
  bool isKeysFileLocked() {
    return monero.Wallet_isKeysFileLocked(walletPtr);
  }
  
  @override
  bool isOffline() {
    return monero.Wallet_isOffline(walletPtr);
  }
  
  @override
  void keyReuseMitigation2({required bool mitigation}) {
    monero.Wallet_keyReuseMitigation2(walletPtr, mitigation: mitigation);
  }
  
  @override
  bool keyValid({required String secret_key_string, required String address_string, required bool isViewKey, required int nettype}) {
    return monero.Wallet_keyValid(secret_key_string: secret_key_string, address_string: address_string, isViewKey: isViewKey, nettype: nettype);
  }
  
  @override
  String keyValid_error({required String secret_key_string, required String address_string, required bool isViewKey, required int nettype}) {
    return monero.Wallet_keyValid_error(secret_key_string: secret_key_string, address_string: address_string, isViewKey: isViewKey, nettype: nettype);
  }
  
  @override
  String keysFilename() {
    return monero.Wallet_keysFilename(walletPtr);
  }
  
  @override
  Wallet2UnsignedTransaction loadUnsignedTx({required String unsigned_filename}) {
    final tx = monero.Wallet_loadUnsignedTx(walletPtr, unsigned_filename: unsigned_filename);
    return MoneroUnsignedTransaction(tx);
  }
  
  @override
  Wallet2UnsignedTransaction loadUnsignedTxUR({required String input}) {
    final tx = monero.Wallet_loadUnsignedTxUR(walletPtr, input: input);
    return MoneroUnsignedTransaction(tx);
  }
  
  @override
  bool lockKeysFile() {
    return monero.Wallet_lockKeysFile(walletPtr);
  }
  
  @override
  String makeMultisig({required List<String> info, required int threshold}) {
    return monero.Wallet_makeMultisig(walletPtr, info: info, threshold: threshold);
  }
  
  @override
  int maximumAllowedAmount() {
    return monero.Wallet_maximumAllowedAmount();
  }
  
  @override
  Wallet2MultisigState multisig() {
    return MoneroMultisigState(monero.Wallet_multisig(walletPtr));
  }
  
  @override
  int nettype() {
    return monero.Wallet_nettype(walletPtr);
  }
  
  @override
  int numSubaddressAccounts() {
    return monero.Wallet_numSubaddressAccounts(walletPtr);
  }
  
  @override
  int numSubaddresses({required int accountIndex}) {
    return monero.Wallet_numSubaddresses(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  String path() {
    return monero.Wallet_path(walletPtr);
  }
  
  @override
  void pauseRefresh() {
    monero.Wallet_pauseRefresh(walletPtr);
  }
  
  @override
  String paymentIdFromAddress({required String strarg, required int nettype}) {
    return monero.Wallet_paymentIdFromAddress(nettype: nettype, strarg: strarg);
  }
  
  @override
  bool paymentIdValid(String paymentId) {
    return monero.Wallet_paymentIdValid(paymentId);
  }
  
  @override
  String publicMultisigSignerKey() {
    return monero.Wallet_publicMultisigSignerKey(walletPtr);
  }
  
  @override
  String publicSpendKey() {
    return monero.Wallet_publicSpendKey(walletPtr);
  }
  
  @override
  String publicViewKey() {
    return monero.Wallet_publicViewKey(walletPtr);
  }
  
  @override
  bool reconnectDevice() {
    return monero.Wallet_reconnectDevice(walletPtr);
  }
  
  @override
  bool refresh() {
    return monero.Wallet_refresh(walletPtr);
  }
  
  @override
  void refreshAsync() {
    monero.Wallet_refreshAsync(walletPtr);
  }
  
  @override
  bool rescanBlockchain() {
    return monero.Wallet_rescanBlockchain(walletPtr);
  }
  
  @override
  void rescanBlockchainAsync() {
    monero.Wallet_rescanBlockchainAsync(walletPtr);
  }
  
  @override
  bool rescanSpent() {
    return monero.Wallet_rescanSpent(walletPtr);
  }
  
  @override
  Wallet2PendingTransaction restoreMultisigTransaction({required String signData}) {
    final tx = monero.Wallet_restoreMultisigTransaction(walletPtr, signData: signData);
    return MoneroPendingTransaction(tx);
  }
  
  @override
  String secretSpendKey() {
    return monero.Wallet_secretSpendKey(walletPtr);
  }
  
  @override
  String secretViewKey() {
    return monero.Wallet_secretViewKey(walletPtr);
  }
  
  @override
  String seed({required String seedOffset}) {
    return monero.Wallet_seed(walletPtr, seedOffset: seedOffset);
  }
  
  @override
  void segregatePreForkOutputs({required bool segregate}) {
    monero.Wallet_segregatePreForkOutputs(walletPtr, segregate: segregate);
  }
  
  @override
  void segregationHeight({required int height}) {
    monero.Wallet_segregationHeight(walletPtr, height: height);
  }
  
  @override
  void setAutoRefreshInterval({required int millis}) {
    monero.Wallet_setAutoRefreshInterval(walletPtr, millis: millis);
  }
  
  @override
  bool setCacheAttribute({required String key, required String value}) {
    return monero.Wallet_setCacheAttribute(walletPtr, key: key, value: value);
  }
  
  @override
  void setDefaultMixin(int arg) {
    monero.Wallet_setDefaultMixin(walletPtr, arg);
  }
  
  @override
  bool setDevicePin({required String passphrase}) {
    return monero.Wallet_setDevicePin(walletPtr, passphrase: passphrase);
  }
  
  @override
  void setDeviceReceivedData(Pointer<UnsignedChar> data, int len) {
    monero.Wallet_setDeviceReceivedData(walletPtr, data, len);
  }
  
  @override
  void setDeviceSendData(Pointer<UnsignedChar> data, int len) {
    monero.Wallet_setDeviceSendData(walletPtr, data, len);
  }
  
  @override
  void setOffline({required bool offline}) {
    monero.Wallet_setOffline(walletPtr, offline: offline);
  }
  
  @override
  bool setPassword({required String password}) {
    return monero.Wallet_setPassword(walletPtr, password: password);
  }
  
  @override
  void setProxy({required String address}) {
    monero.Wallet_setProxy(walletPtr, address: address);
  }
  
  @override
  void setRecoveringFromDevice({required bool recoveringFromDevice}) {
    monero.Wallet_setRecoveringFromDevice(walletPtr, recoveringFromDevice: recoveringFromDevice);
  }
  
  @override
  void setRecoveringFromSeed({required bool recoveringFromSeed}) {
    monero.Wallet_setRecoveringFromSeed(walletPtr, recoveringFromSeed: recoveringFromSeed);
  }
  
  @override
  void setRefreshFromBlockHeight({required int refresh_from_block_height}) {
    monero.Wallet_setRefreshFromBlockHeight(walletPtr, refresh_from_block_height: refresh_from_block_height);
  }
  
  @override
  void setSeedLanguage({required String language}) {
    monero.Wallet_setSeedLanguage(walletPtr, language: language);
  }
  
  @override
  void setSubaddressLabel({required int accountIndex, required int addressIndex, required String label}) {
    monero.Wallet_setSubaddressLabel(walletPtr, accountIndex: accountIndex, addressIndex: addressIndex, label: label);
  }
  
  @override
  void setSubaddressLookahead({required int major, required int minor}) {
    monero.Wallet_setSubaddressLookahead(walletPtr, major: major, minor: minor);
  }
  
  @override
  void setTrustedDaemon({required bool arg}) {
    monero.Wallet_setTrustedDaemon(walletPtr, arg: arg);
  }
  
  @override
  bool setUserNote({required String txid, required String note}) {
    return monero.Wallet_setUserNote(walletPtr, txid: txid, note: note);
  }
  
  @override
  bool setupBackgroundSync({required int backgroundSyncType, required String walletPassword, required String backgroundCachePassword}) {
    return monero.Wallet_setupBackgroundSync(walletPtr, backgroundSyncType: backgroundSyncType, walletPassword: walletPassword, backgroundCachePassword: backgroundCachePassword);
  }
  
  @override
  String signMessage({required String message, required String address}) {
    return monero.Wallet_signMessage(walletPtr, message: message, address: address);
  }
  
  @override
  bool startBackgroundSync() {
    return monero.Wallet_startBackgroundSync(walletPtr);
  }
  
  @override
  void startRefresh() {
    monero.Wallet_startRefresh(walletPtr);
  }
  
  @override
  int status() {
    return monero.Wallet_status(walletPtr);
  }
  
  @override
  void stop() {
    monero.Wallet_stop(walletPtr);
  }
  
  @override
  bool stopBackgroundSync(String walletPassword) {
    return monero.Wallet_stopBackgroundSync(walletPtr, walletPassword);
  }
  
  @override
  bool store({String path = ""}) {
    return monero.Wallet_store(walletPtr, path: path);
  }
  
  @override
  Wallet2Subaddress subaddress() {
    return MoneroSubaddress(monero.Wallet_subaddress(walletPtr));
  }
  
  @override
  Wallet2SubaddressAccount subaddressAccount() {
    return MoneroSubaddressAccount(monero.Wallet_subaddressAccount(walletPtr));
  }
  
  @override
  bool submitTransaction(String filename) {
    return monero.Wallet_submitTransaction(walletPtr, filename);
  }
  
  @override
  bool submitTransactionUR(String input) {
    return monero.Wallet_submitTransactionUR(walletPtr, input);
  }
  
  @override
  bool synchronized() {
    return monero.Wallet_synchronized(walletPtr);
  }
  
  @override
  bool trustedDaemon() {
    return monero.Wallet_trustedDaemon(walletPtr);
  }
  
  @override
  bool unlockKeysFile() {
    return monero.Wallet_unlockKeysFile(walletPtr);
  }
  
  @override
  int unlockedBalance({required int accountIndex}) {
    return monero.Wallet_unlockedBalance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  int useForkRules({required int version, required int earlyBlocks}) {
    return monero.Wallet_useForkRules(walletPtr, version: version, earlyBlocks: earlyBlocks);
  }
  
  @override
  bool verifySignedMessage({required String message, required String address, required String signature}) {
    return monero.Wallet_verifySignedMessage(walletPtr, message: message, address: address, signature: signature);
  }
  
  @override
  int viewOnlyBalance({required int accountIndex}) {
    return monero.Wallet_viewOnlyBalance(walletPtr, accountIndex: accountIndex);
  }
  
  @override
  bool watchOnly() {
    return monero.Wallet_watchOnly(walletPtr);
  }

  @override
  int ffiAddress() => walletPtr.address;
}

class MoneroWalletManager implements Wallet2WalletManager {
  MoneroWalletManager(this.wmPtr);

  final monero.WalletManager wmPtr;
  
  @override
  Future<int> blockTarget() async {
    return monero.WalletManager_blockTarget(wmPtr);
  }
  
  @override
  Future<int> blockchainHeight() async {
    return monero.WalletManager_blockchainHeight(wmPtr);
  }
  
  @override
  Future<int> blockchainTargetHeight() async {
    return monero.WalletManager_blockchainTargetHeight(wmPtr);
  }
  
  @override
  Wallet2Wallet createDeterministicWalletFromSpendKey({required String path, required String password, String language = "English", int networkType = 0, required String spendKeyString, required bool newWallet, required int restoreHeight, int kdfRounds = 1}) {
    final wallet = monero.WalletManager_createDeterministicWalletFromSpendKey(wmPtr, path: path, password: password, language: language, networkType: networkType, spendKeyString: spendKeyString, newWallet: newWallet, restoreHeight: restoreHeight, kdfRounds: kdfRounds);
    return MoneroWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWallet({required String path, required String password, String language = "English", int networkType = 0}) {
    final wallet = monero.WalletManager_createWallet(wmPtr, path: path, password: password, language: language, networkType: networkType);
    return MoneroWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromDevice({required String path, required String password, int networkType = 0, required String deviceName, int restoreHeight = 0, String subaddressLookahead = "", int kdfRounds = 1}) {
    final wallet = monero.WalletManager_createWalletFromDevice(wmPtr, path: path, password: password, deviceName: deviceName, restoreHeight: restoreHeight, subaddressLookahead: subaddressLookahead, kdfRounds: kdfRounds);
    return MoneroWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromKeys({required String path, required String password, String language = "English", int nettype = 1, required int restoreHeight, required String addressString, required String viewKeyString, required String spendKeyString, int kdf_rounds = 1}) {
    final wallet = monero.WalletManager_createWalletFromKeys(wmPtr, path: path, password: password, language: language, nettype: nettype, restoreHeight: restoreHeight, addressString: addressString, viewKeyString: viewKeyString, spendKeyString: spendKeyString);
    return MoneroWallet(wallet);
  }
  
  @override
  Wallet2Wallet createWalletFromPolyseed({required String path, required String password, int networkType = 0, required String mnemonic, required String seedOffset, required bool newWallet, required int restoreHeight, required int kdfRounds}) {
    final wallet = monero.WalletManager_createWalletFromPolyseed(wmPtr, path: path, password: password, networkType: networkType, mnemonic: mnemonic, seedOffset: seedOffset, newWallet: newWallet, restoreHeight: restoreHeight, kdfRounds: kdfRounds);
    return MoneroWallet(wallet);
  }
  
  @override
  String errorString() {
    return monero.WalletManager_errorString(wmPtr);
  }
  
  @override
  List<String> findWallets({required String path}) {
    return monero.WalletManager_findWallets(wmPtr, path: path);
  }
  
  @override
  bool isMining() {
    return monero.WalletManager_isMining(wmPtr);
  }
  
  @override
  double miningHashRate() {
    return monero.WalletManager_miningHashRate(wmPtr);
  }
  
  @override
  int networkDifficulty() {
    return monero.WalletManager_networkDifficulty(wmPtr);
  }
  
  @override
  Wallet2Wallet openWallet({required String path, required String password, int networkType = 0}) {
    final wallet = monero.WalletManager_openWallet(wmPtr, path: path, password: password, networkType: networkType);
    return MoneroWallet(wallet);
  }
  
  @override
  int queryWalletDevice({required String keysFileName, required String password, required int kdfRounds}) {
    return monero.WalletManager_queryWalletDevice(wmPtr, keysFileName: keysFileName, password: password, kdfRounds: kdfRounds);
  }
  
  @override
  Wallet2Wallet recoveryWallet({required String path, required String password, required String mnemonic, int networkType = 0, required int restoreHeight, int kdfRounds = 0, required String seedOffset}) {
    final wallet = monero.WalletManager_recoveryWallet(wmPtr, path: path, password: password, mnemonic: mnemonic, networkType: networkType, restoreHeight: restoreHeight, kdfRounds: kdfRounds, seedOffset: seedOffset);
    return MoneroWallet(wallet);
  }
  
  @override
  String resolveOpenAlias({required String address, required bool dnssecValid}) {
    return monero.WalletManager_resolveOpenAlias(wmPtr, address: address, dnssecValid: dnssecValid);
  }
  
  @override
  void setDaemonAddress(String address) {
    monero.WalletManager_setDaemonAddress(wmPtr, address);
  }
  
  @override
  bool setProxy(String address) {
    return monero.WalletManager_setProxy(wmPtr, address);
  }
  
  @override
  bool startMining({required String address, required int threads, required bool backgroundMining, required bool ignoreBattery}) {
    return monero.WalletManager_startMining(wmPtr, address: address, threads: threads, backgroundMining: backgroundMining, ignoreBattery: ignoreBattery);
  }
  
  @override
  bool stopMining(String address) {
    return monero.WalletManager_stopMining(wmPtr, address);
  }
  
  @override
  bool verifyWalletPassword({required String keysFileName, required String password, required bool noSpendKey, required int kdfRounds}) {
    return monero.WalletManager_verifyWalletPassword(wmPtr, keysFileName: keysFileName, password: password, noSpendKey: noSpendKey, kdfRounds: kdfRounds);
  }
  
  @override
  bool walletExists(String path) {
    return monero.WalletManager_walletExists(wmPtr, path);
  }

  @override
  int ffiAddress() => wmPtr.address;
}

class MoneroWalletManagerFactory implements Wallet2WalletManagerFactory {
  @override
  Wallet2WalletManager getWalletManager() {
    return MoneroWalletManager(monero.WalletManagerFactory_getWalletManager());
  }

  @override
  void setLogCategories(String categories) {
    monero.WalletManagerFactory_setLogCategories(categories);
  }

  @override
  void setLogLevel(int level) {
    monero.WalletManagerFactory_setLogLevel(level);
  }

  @override
  int ffiAddress() => 0;
}
