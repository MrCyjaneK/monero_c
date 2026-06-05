// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:io';

abstract class Wallet2 {
  Wallet2WalletManagerFactory walletManagerFactory();

  static String get libPath {
    if (Platform.isWindows) return 'unknown_libwallet2_api_c.dll';
    if (Platform.isMacOS) return 'unknown_libwallet2_api_c.dylib';
    if (Platform.isIOS) return 'UnknownWallet.framework/UnknownWallet';
    if (Platform.isAndroid) return 'libunknown_libwallet2_api_c.so';
    return 'unknown_libwallet2_api_c.so';
  }

  static set libPath(String path) {
    throw Exception(
        'libPath is read-only, as isolates cannot be made aware of changes to this variable');
  }

  int ffiAddress();
}

abstract class Wallet2AddressBook {
  int ffiAddress();

  int getAll_size();
  Wallet2AddressBookRow getAll_byIndex(int index);
  bool addRow({
    required String dstAddr,
    required String paymentId,
    required String description,
  });
  bool deleteRow({required int rowId});
  bool setDescription({
    required int rowId,
    required String description,
  });
  void refresh();
  int errorCode();
  int lookupPaymentID({required String paymentId});
}

abstract class Wallet2AddressBookRow {
  int ffiAddress();

  String extra();
  String getAddress();
  String getDescription();
  String getPaymentId();
  int getRowId();
}

abstract class Wallet2Coins {
  int ffiAddress();

  int count();
  Wallet2CoinsInfo coin(int index);
  int getAll_size();
  Wallet2CoinsInfo getAll_byIndex(int index);
  void refresh();
  void setFrozenByPublicKey({required String publicKey});
  void setFrozen({required int index});
  void thaw({required int index});
  void thawByPublicKey({required String publicKey});
  bool isTransferUnlocked({required int unlockTime, required int blockHeight});
}

abstract class Wallet2CoinsInfo {
  int ffiAddress();

  int blockHeight();
  String hash();
  int internalOutputIndex();
  int globalOutputIndex();
  bool spent();
  bool frozen();
  int spentHeight();
  int amount();
  bool rct();
  bool keyImageKnown();
  int pkIndex();
  int subaddrIndex();
  int subaddrAccount();
  String address();
  String addressLabel();
  String keyImage();
  int unlockTime();
  bool unlocked();
  String pubKey();
  bool coinbase();
  String description();
}

abstract class Wallet2DeviceProgress {
  int ffiAddress();

  bool progress();
  bool indeterminate();
}

abstract class Wallet2WalletListener {
  int ffiAddress();

  void resetNeedToRefresh();
  bool isNeedToRefresh();
  bool isNewTransactionExist();
  void resetIsNewTransactionExist();
  int height();
}

abstract class Wallet2Checksum {
  int ffiAddress();

  String checksum_wallet2_api_c_h();
  String checksum_wallet2_api_c_cpp();
  String checksum_wallet2_api_c_exp();
}

abstract class Wallet2Free {
  int ffiAddress();

  void free(Pointer<Void> wlptr);
}

abstract class Wallet2MultisigState {
  int ffiAddress();

  bool isMultisig(Pointer<Void> ptr);
  bool isReady(Pointer<Void> ptr);
  int threshold(Pointer<Void> ptr);
  int total(Pointer<Void> ptr);
}

abstract class Wallet2PendingTransaction {
  int ffiAddress();

  int status();
  String errorString();
  bool commit({required String filename, required bool overwrite});
  String commitUR(int max_fragment_length);
  int amount();
  int dust();
  int fee();
  String txid(String separator);
  int txCount();
  String subaddrAccount(String separator);
  String subaddrIndices(String separator);
  String multisigSignData();
  void signMultisigTx();
  String signersKeys(String separator);
  String hex(String separator);
}

abstract class Wallet2Subaddress {
  int ffiAddress();

  int getAll_size();
  Wallet2SubaddressRow getAll_byIndex(int index);
  void addRow({required int accountIndex, required String label});
  void setLabel(
      {required int accountIndex,
      required int addressIndex,
      required String label});
  void refresh({required int accountIndex, required String label});
}

abstract class Wallet2SubaddressAccount {
  int ffiAddress();

  int getAll_size();
  Wallet2SubaddressAccountRow getAll_byIndex(int index);
  void addRow({required String label});
  void setLabel({required int accountIndex, required String label});
  void refresh();
}

abstract class Wallet2SubaddressAccountRow {
  int ffiAddress();

  String extra();
  String getAddress();
  String getLabel();
  String getBalance();
  String getUnlockedBalance();
  int getRowId();
}

abstract class Wallet2SubaddressRow {
  int ffiAddress();

  String extra();
  String getAddress();
  String getLabel();
  int getRowId();
}

abstract class Wallet2TransactionHistory {
  int ffiAddress();

  int count();
  Wallet2TransactionInfo transaction(int index);
  Wallet2TransactionInfo transactionById(String txid);
  void refresh();
  void setTxNote({required String txid, required String note});
}

abstract class Wallet2TransactionInfo {
  int ffiAddress();

  int direction();
  bool isPending();
  bool isFailed();
  bool isCoinbase();
  int amount();
  int fee();
  int blockHeight();
  String description();
  String subaddrIndex();
  int subaddrAccount();
  String label();
  int confirmations();
  int unlockTime();
  String hash();
  int timestamp();
  String paymentId();
  int transfers_count();
  int transfers_amount(int index);
  String transfers_address(int index);
}

abstract class Wallet2UnsignedTransaction {
  int ffiAddress();

  int status();
  String errorString();
  String amount();
  String fee();
  String mixin();
  String confirmationMessage();
  String paymentId();
  String recipientAddress();
  int minMixinCount();
  int txCount();
  bool sign(String signedFileName);
  String signUR(int max_fragment_length);
}

abstract class Wallet2Wallet {
  int ffiAddress();

  String seed({required String seedOffset});
  String getSeedLanguage();
  void setSeedLanguage({required String language});
  int status();
  String errorString();
  bool setPassword({required String password});
  String getPassword();
  bool setDevicePin({required String passphrase});
  String address({int accountIndex = 0, int addressIndex = 0});
  String path();
  int nettype();
  int useForkRules({
    required int version,
    required int earlyBlocks,
  });
  String integratedAddress({required String paymentId});
  String secretViewKey();
  String publicViewKey();
  String secretSpendKey();
  String publicSpendKey();
  String publicMultisigSignerKey();
  void stop();
  bool store({String path = ""});
  String filename();
  String keysFilename();
  bool init({
    required String daemonAddress,
    int upperTransacationSizeLimit = 0,
    String daemonUsername = "",
    String daemonPassword = "",
    bool useSsl = false,
    bool lightWallet = false,
    String proxyAddress = "",
  });
  bool createWatchOnly({
    required String path,
    required String password,
    required String language,
  });
  void setRefreshFromBlockHeight({required int refresh_from_block_height});
  int getRefreshFromBlockHeight();
  void setRecoveringFromSeed({required bool recoveringFromSeed});
  void setRecoveringFromDevice({required bool recoveringFromDevice});
  void setSubaddressLookahead({required int major, required int minor});
  bool connectToDaemon();
  int connected();
  void setTrustedDaemon({required bool arg});
  bool trustedDaemon();
  void setProxy({required String address});
  int balance({required int accountIndex});
  int unlockedBalance({required int accountIndex});
  int viewOnlyBalance({required int accountIndex});
  bool watchOnly();
  int blockChainHeight();
  int approximateBlockChainHeight();
  int estimateBlockChainHeight();
  int daemonBlockChainHeight();
  bool synchronized();
  String displayAmount(int amount);
  int amountFromString(String amount);
  int amountFromDouble(double amount);
  String genPaymentId();
  bool paymentIdValid(String paymentId);
  bool addressValid(String address, int networkType);
  bool keyValid(
      {required String secret_key_string,
      required String address_string,
      required bool isViewKey,
      required int nettype});
  String keyValid_error(
      {required String secret_key_string,
      required String address_string,
      required bool isViewKey,
      required int nettype});
  String paymentIdFromAddress({required String strarg, required int nettype});
  int maximumAllowedAmount();
  void init3({
    required String argv0,
    required String defaultLogBaseName,
    required String logPath,
    required bool console,
  });
  String getPolyseed({required String passphrase});
  String createPolyseed({
    String language = "English",
  });
  void startRefresh();
  void pauseRefresh();
  bool refresh();
  void refreshAsync();
  bool rescanBlockchain();
  void rescanBlockchainAsync();
  void setAutoRefreshInterval({required int millis});
  int autoRefreshInterval();
  void addSubaddress({required int accountIndex, String label = ""});
  void addSubaddressAccount({String label = ""});
  int numSubaddressAccounts();
  int numSubaddresses({required int accountIndex});
  String getSubaddressLabel(
      {required int accountIndex, required int addressIndex});
  void setSubaddressLabel(
      {required int accountIndex,
      required int addressIndex,
      required String label});
  Wallet2MultisigState multisig();
  String getMultisigInfo();
  String makeMultisig({
    required List<String> info,
    required int threshold,
  });
  String exchangeMultisigKeys({
    required List<String> info,
    required bool force_update_use_with_caution,
  });
  List<String> exportMultisigImages({
    required List<String> info,
  });
  int importMultisigImages({
    required List<String> info,
  });
  int hasMultisigPartialKeyImages();
  Wallet2PendingTransaction restoreMultisigTransaction({
    required String signData,
  });
  Wallet2PendingTransaction createTransactionMultDest({
    required List<String> dstAddr,
    String paymentId = "",
    required bool isSweepAll,
    required List<int> amounts,
    required int mixinCount,
    required int pendingTransactionPriority,
    required int subaddr_account,
    List<String> preferredInputs = const [],
  });
  Wallet2PendingTransaction createTransaction({
    required String dst_addr,
    required String payment_id,
    required int amount,
    required int mixin_count,
    required int pendingTransactionPriority,
    required int subaddr_account,
    List<String> preferredInputs = const [],
  });
  Wallet2UnsignedTransaction loadUnsignedTx(
      {required String unsigned_filename});
  Wallet2UnsignedTransaction loadUnsignedTxUR({required String input});
  bool submitTransaction(String filename);
  bool submitTransactionUR(String input);
  bool submitTransactionHex(String hex);
  bool hasUnknownKeyImages();
  bool exportKeyImages(String filename, {required bool all});
  String exportKeyImagesUR({
    int max_fragment_length = 130,
    bool all = false,
  });
  bool importKeyImages(String filename);
  bool importKeyImagesUR(String input);
  bool exportOutputs(String filename, {required bool all});
  String exportOutputsUR({
    int max_fragment_length = 130,
    bool all = false,
  });
  bool importOutputs(String filename);
  bool importOutputsUR(String input);
  bool setupBackgroundSync({
    required int backgroundSyncType,
    required String walletPassword,
    required String backgroundCachePassword,
  });
  int getBackgroundSyncType();
  bool startBackgroundSync();
  bool stopBackgroundSync(String walletPassword);
  bool isBackgroundSyncing();
  bool isBackgroundWallet();
  Wallet2TransactionHistory history();
  Wallet2AddressBook addressBook();
  Wallet2Coins coins();
  Wallet2Subaddress subaddress();
  Wallet2SubaddressAccount subaddressAccount();
  int defaultMixin();
  void setDefaultMixin(int arg);
  bool setCacheAttribute({required String key, required String value});
  String getCacheAttribute({required String key});
  bool setUserNote({required String txid, required String note});
  String getUserNote({required String txid});
  String getTxKey({required String txid});
  String signMessage({
    required String message,
    required String address,
  });
  bool verifySignedMessage({
    required String message,
    required String address,
    required String signature,
  });
  bool rescanSpent();
  void setOffline({required bool offline});
  bool isOffline();
  void segregatePreForkOutputs({required bool segregate});
  void segregationHeight({required int height});
  void keyReuseMitigation2({required bool mitigation});
  bool lockKeysFile();
  bool unlockKeysFile();
  bool isKeysFileLocked();
  int getDeviceType();
  int coldKeyImageSync({required int spent, required int unspent});
  String deviceShowAddress(
      {required int accountIndex, required int addressIndex});
  bool reconnectDevice();
  int getBytesReceived();
  int getBytesSent();
  Wallet2WalletListener getWalletListener();
}

abstract class Wallet2WalletManager {
  int ffiAddress();

  Wallet2Wallet createWallet({
    required String path,
    required String password,
    String language = "English",
    int networkType = 0,
  });
  Wallet2Wallet openWallet({
    required String path,
    required String password,
    int networkType = 0,
  });
  void closeWallet(Wallet2Wallet wallet, bool store);
  Wallet2Wallet recoveryWallet({
    required String path,
    required String password,
    required String mnemonic,
    int networkType = 0,
    required int restoreHeight,
    int kdfRounds = 0,
    required String seedOffset,
  });
  Wallet2Wallet createWalletFromKeys({
    required String path,
    required String password,
    String language = "English",
    int nettype = 1,
    required int restoreHeight,
    required String addressString,
    required String viewKeyString,
    required String spendKeyString,
    int kdf_rounds = 1,
  });
  Wallet2Wallet createDeterministicWalletFromSpendKey({
    required String path,
    required String password,
    String language = "English",
    int networkType = 0,
    required String spendKeyString,
    required bool newWallet,
    required int restoreHeight,
    int kdfRounds = 1,
  });
  Wallet2Wallet createWalletFromDevice({
    required String path,
    required String password,
    int networkType = 0,
    required String deviceName,
    int restoreHeight = 0,
    String subaddressLookahead = "",
    int kdfRounds = 1,
  });
  Wallet2Wallet createWalletFromPolyseed({
    required String path,
    required String password,
    int networkType = 0,
    required String mnemonic,
    required String seedOffset,
    required bool newWallet,
    required int restoreHeight,
    required int kdfRounds,
  });
  bool walletExists(String path);
  bool verifyWalletPassword({
    required String keysFileName,
    required String password,
    required bool noSpendKey,
    required int kdfRounds,
  });
  int queryWalletDevice({
    required String keysFileName,
    required String password,
    required int kdfRounds,
  });
  List<String> findWallets({required String path});
  String errorString();
  void setDaemonAddress(String address);
  Future<int> blockchainHeight();
  Future<int> blockchainTargetHeight();
  int networkDifficulty();
  double miningHashRate();
  Future<int> blockTarget();
  bool isMining();
  bool startMining({
    required String address,
    required int threads,
    required bool backgroundMining,
    required bool ignoreBattery,
  });
  bool stopMining(String address);
  String resolveOpenAlias({
    required String address,
    required bool dnssecValid,
  });
  bool setProxy(String address);
}

abstract class Wallet2WalletManagerFactory {
  int ffiAddress();

  void setLogLevel(int level);
  void setLogCategories(String categories);
  Wallet2WalletManager getWalletManager();
}
