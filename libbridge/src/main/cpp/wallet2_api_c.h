/*
#include <android/log.h>

#define  LOG_TAG    "[NDK]"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGW(...)  __android_log_print(ANDROID_LOG_WARN,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
*/
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C"
{
#endif

int NetworkTypeMAINNET = 0;

// namespace Monero {
// enum NetworkType : uint8_t {
//     MAINNET = 0,
//     TESTNET,
//     STAGENET
// };
//     namespace Utils {
//         bool isAddressLocal(const std::string &hostaddr);
//         void onStartup();
//     }
//     template<typename T>
//     class optional {
//       public:
//         optional(): set(false) {}
//         optional(const T &t): t(t), set(true) {}
//         const T &operator*() const { return t; }
//         T &operator*() { return t; }
//         operator bool() const { return set; }
//       private:
//         T t;
//         bool set;
//     };

// struct PendingTransaction
// {
//     enum Status {
//         Status_Ok,
//         Status_Error,
//         Status_Critical
//     };
//     enum Priority {
//         Priority_Default = 0,
//         Priority_Low = 1,
//         Priority_Medium = 2,
//         Priority_High = 3,
//         Priority_Last
//     };
//     virtual ~PendingTransaction() = 0;
//     virtual int status() const = 0;
int MONERO_PendingTransaction_status(void* pendingTx_ptr);
//     virtual std::string errorString() const = 0;
const char* MONERO_PendingTransaction_errorString(void* pendingTx_ptr);
//     virtual bool commit(const std::string &filename = "", bool overwrite = false) = 0;
bool MONERO_PendingTransaction_commit(void* pendingTx_ptr, const char* filename, bool overwrite);
//     virtual uint64_t amount() const = 0;
uint64_t MONERO_PendingTransaction_amount(void* pendingTx_ptr);
//     virtual uint64_t dust() const = 0;
uint64_t MONERO_PendingTransaction_dust(void* pendingTx_ptr);
//     virtual uint64_t fee() const = 0;
uint64_t MONERO_PendingTransaction_fee(void* pendingTx_ptr);
//     virtual std::vector<std::string> txid() const = 0;
//     virtual uint64_t txCount() const = 0;
uint64_t MONERO_PendingTransaction_txCount(void* pendingTx_ptr);
//     virtual std::vector<uint32_t> subaddrAccount() const = 0;
//     virtual std::vector<std::set<uint32_t>> subaddrIndices() const = 0;
//     virtual std::string multisigSignData() = 0;
//     virtual void signMultisigTx() = 0;
//     virtual std::vector<std::string> signersKeys() const = 0;
// };

// struct UnsignedTransaction
// {
//     enum Status {
//         Status_Ok,
//         Status_Error,
//         Status_Critical
//     };
//     virtual ~UnsignedTransaction() = 0;
//     virtual int status() const = 0;
//     virtual std::string errorString() const = 0;
//     virtual std::vector<uint64_t> amount() const = 0;
//     virtual std::vector<uint64_t>  fee() const = 0;
//     virtual std::vector<uint64_t> mixin() const = 0;
//     virtual std::string confirmationMessage() const = 0;
//     virtual std::vector<std::string> paymentId() const = 0;
//     virtual std::vector<std::string> recipientAddress() const = 0;
//     virtual uint64_t minMixinCount() const = 0;
//     virtual uint64_t txCount() const = 0;
//     virtual bool sign(const std::string &signedFileName) = 0;
// };
// struct TransactionInfo
// {
//     enum Direction {
//         Direction_In,
//         Direction_Out
//     };
//     struct Transfer {
//         Transfer(uint64_t _amount, const std::string &address);
//         const uint64_t amount;
//         const std::string address;
//     };
//     virtual ~TransactionInfo() = 0;
//     virtual int  direction() const = 0;
int MONERO_TransactionInfo_direction(void* txInfo_ptr);
//     virtual bool isPending() const = 0;
bool MONERO_TransactionInfo_isPending(void* txInfo_ptr);
//     virtual bool isFailed() const = 0;
bool MONERO_TransactionInfo_isFailed(void* txInfo_ptr);
//     virtual bool isCoinbase() const = 0;
bool MONERO_TransactionInfo_isCoinbase(void* txInfo_ptr);
//     virtual uint64_t amount() const = 0;
uint64_t MONERO_TransactionInfo_amount(void* txInfo_ptr);
//     virtual uint64_t fee() const = 0;
uint64_t MONERO_TransactionInfo_fee(void* txInfo_ptr);
//     virtual uint64_t blockHeight() const = 0;
uint64_t MONERO_TransactionInfo_blockHeight(void* txInfo_ptr);
//     virtual std::string description() const = 0;
const char* MONERO_TransactionInfo_description(void* txInfo_ptr);
//     virtual std::set<uint32_t> subaddrIndex() const = 0;
//     virtual uint32_t subaddrAccount() const = 0;
uint32_t MONERO_TransactionInfo_subaddrAccount(void* txInfo_ptr);
//     virtual std::string label() const = 0;
const char* MONERO_TransactionInfo_label(void* txInfo_ptr);
//     virtual uint64_t confirmations() const = 0;
uint64_t MONERO_TransactionInfo_confirmations(void* txInfo_ptr);
//     virtual uint64_t unlockTime() const = 0;
uint64_t MONERO_TransactionInfo_unlockTime(void* txInfo_ptr);
//     virtual std::string hash() const = 0;
const char* MONERO_TransactionInfo_hash(void* txInfo_ptr);
//     virtual std::time_t timestamp() const = 0;
uint64_t MONERO_TransactionInfo_timestamp(void* txInfo_ptr);
//     virtual std::string paymentId() const = 0;
const char* MONERO_TransactionInfo_paymentId(void* txInfo_ptr);
//     virtual const std::vector<Transfer> & transfers() const = 0;
// };
// struct TransactionHistory
// {
//     virtual ~TransactionHistory() = 0;
//     virtual int count() const = 0;
int MONERO_TransactionHistory_count(void* txHistory_ptr);
//     virtual TransactionInfo * transaction(int index)  const = 0;
void* MONERO_TransactionHistory_transaction(void* txHistory_ptr, int index);
//     virtual TransactionInfo * transaction(const std::string &id) const = 0;
//     virtual std::vector<TransactionInfo*> getAll() const = 0;
//     virtual void refresh() = 0;
void MONERO_TransactionHistory_refresh(void* txHistory_ptr);
//     virtual void setTxNote(const std::string &txid, const std::string &note) = 0;
void MONERO_TransactionHistory_setTxNote(void* txHistory_ptr, const char* txid, const char* note);
// };
// struct AddressBookRow {
// public:
//     AddressBookRow(std::size_t _rowId, const std::string &_address, const std::string &_paymentId, const std::string &_description):
//         m_rowId(_rowId),
//         m_address(_address),
//         m_paymentId(_paymentId), 
//         m_description(_description) {}
 
// private:
//     std::size_t m_rowId;
//     std::string m_address;
//     std::string m_paymentId;
//     std::string m_description;
// public:
//     std::string extra;
//     std::string getAddress() const {return m_address;} 
//     std::string getDescription() const {return m_description;} 
//     std::string getPaymentId() const {return m_paymentId;} 
//     std::size_t getRowId() const {return m_rowId;}
// };
// struct AddressBook
// {
//     enum ErrorCode {
//         Status_Ok,
//         General_Error,
//         Invalid_Address,
//         Invalid_Payment_Id
//     };
//     virtual ~AddressBook() = 0;
//     virtual std::vector<AddressBookRow*> getAll() const = 0;
//     virtual bool addRow(const std::string &dst_addr , const std::string &payment_id, const std::string &description) = 0;  
//     virtual bool deleteRow(std::size_t rowId) = 0;
//     virtual bool setDescription(std::size_t index, const std::string &description) = 0;
//     virtual void refresh() = 0;  
//     virtual std::string errorString() const = 0;
//     virtual int errorCode() const = 0;
//     virtual int lookupPaymentID(const std::string &payment_id) const = 0;
// };
// struct CoinsInfo
// {
//     virtual ~CoinsInfo() = 0;
//     virtual uint64_t blockHeight() const = 0;
//     virtual std::string hash() const = 0;
//     virtual size_t internalOutputIndex() const = 0;
//     virtual uint64_t globalOutputIndex() const = 0;
//     virtual bool spent() const = 0;
//     virtual bool frozen() const = 0;
//     virtual uint64_t spentHeight() const = 0;
//     virtual uint64_t amount() const = 0;
//     virtual bool rct() const = 0;
//     virtual bool keyImageKnown() const = 0;
//     virtual size_t pkIndex() const = 0;
//     virtual uint32_t subaddrIndex() const = 0;
//     virtual uint32_t subaddrAccount() const = 0;
//     virtual std::string address() const = 0;
//     virtual std::string addressLabel() const = 0;
//     virtual std::string keyImage() const = 0;
//     virtual uint64_t unlockTime() const = 0;
//     virtual bool unlocked() const = 0;
//     virtual std::string pubKey() const = 0;
//     virtual bool coinbase() const = 0;
// };
// struct Coins
// {
//     virtual ~Coins() = 0;
//     virtual int count() const = 0;
//     virtual CoinsInfo * coin(int index)  const = 0;
//     virtual std::vector<CoinsInfo*> getAll() const = 0;
//     virtual void refresh() = 0;
//     virtual void setFrozen(int index) = 0;
//     virtual void thaw(int index) = 0;
//     virtual bool isTransferUnlocked(uint64_t unlockTime, uint64_t blockHeight) = 0;
// };
// struct SubaddressRow {
// public:
//     SubaddressRow(std::size_t _rowId, const std::string &_address, const std::string &_label):
//         m_rowId(_rowId),
//         m_address(_address),
//         m_label(_label) {}
 
// private:
//     std::size_t m_rowId;
//     std::string m_address;
//     std::string m_label;
// public:
//     std::string extra;
//     std::string getAddress() const {return m_address;}
//     std::string getLabel() const {return m_label;}
//     std::size_t getRowId() const {return m_rowId;}
// };

// struct Subaddress
// {
//     virtual ~Subaddress() = 0;
//     virtual std::vector<SubaddressRow*> getAll() const = 0;
//     virtual void addRow(uint32_t accountIndex, const std::string &label) = 0;
//     virtual void setLabel(uint32_t accountIndex, uint32_t addressIndex, const std::string &label) = 0;
//     virtual void refresh(uint32_t accountIndex) = 0;
// };

// struct SubaddressAccountRow {
// public:
//     SubaddressAccountRow(std::size_t _rowId, const std::string &_address, const std::string &_label, const std::string &_balance, const std::string &_unlockedBalance):
//         m_rowId(_rowId),
//         m_address(_address),
//         m_label(_label),
//         m_balance(_balance),
//         m_unlockedBalance(_unlockedBalance) {}

// private:
//     std::size_t m_rowId;
//     std::string m_address;
//     std::string m_label;
//     std::string m_balance;
//     std::string m_unlockedBalance;
// public:
//     std::string extra;
//     std::string getAddress() const {return m_address;}
//     std::string getLabel() const {return m_label;}
//     std::string getBalance() const {return m_balance;}
//     std::string getUnlockedBalance() const {return m_unlockedBalance;}
//     std::size_t getRowId() const {return m_rowId;}
// };

// struct SubaddressAccount
// {
//     virtual ~SubaddressAccount() = 0;
//     virtual std::vector<SubaddressAccountRow*> getAll() const = 0;
//     virtual void addRow(const std::string &label) = 0;
//     virtual void setLabel(uint32_t accountIndex, const std::string &label) = 0;
//     virtual void refresh() = 0;
// };

// struct MultisigState {
//     MultisigState() : isMultisig(false), isReady(false), threshold(0), total(0) {}

//     bool isMultisig;
//     bool isReady;
//     uint32_t threshold;
//     uint32_t total;
// };


// struct DeviceProgress {
//     DeviceProgress(): m_progress(0), m_indeterminate(false) {}
//     DeviceProgress(double progress, bool indeterminate=false): m_progress(progress), m_indeterminate(indeterminate) {}

//     virtual double progress() const { return m_progress; }
//     virtual bool indeterminate() const { return m_indeterminate; }

// protected:
//     double m_progress;
//     bool m_indeterminate;
// };

// struct Wallet;
// struct WalletListener
// {
//     virtual ~WalletListener() = 0;
//     virtual void moneySpent(const std::string &txId, uint64_t amount) = 0;
//     virtual void moneyReceived(const std::string &txId, uint64_t amount) = 0;
//     virtual void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount) = 0;
//     virtual void newBlock(uint64_t height) = 0;
//     virtual void updated() = 0;
//     virtual void refreshed() = 0;
//     virtual void onDeviceButtonRequest(uint64_t code) { (void)code; }
//     virtual void onDeviceButtonPressed() { }
//     virtual optional<std::string> onDevicePinRequest() {
//         throw std::runtime_error("Not supported");
//     }
//     virtual optional<std::string> onDevicePassphraseRequest(bool & on_device) {
//         on_device = true;
//         return optional<std::string>();
//     }
//     virtual void onDeviceProgress(const DeviceProgress & event) { (void)event; };
//     virtual void onSetWallet(Wallet * wallet) { (void)wallet; };
// };
// struct Wallet
// {
//     enum Device {
//         Device_Software = 0,
//         Device_Ledger = 1,
//         Device_Trezor = 2
//     };
//     enum Status {
//         Status_Ok,
//         Status_Error,
//         Status_Critical
//     };
//     enum ConnectionStatus {
//         ConnectionStatus_Disconnected,
//         ConnectionStatus_Connected,
//         ConnectionStatus_WrongVersion
//     };
//     virtual ~Wallet() = 0;
//     virtual std::string seed(const std::string& seed_offset = "") const = 0;
const char* MONERO_Wallet_seed(void* wallet_ptr);
//     virtual std::string getSeedLanguage() const = 0;
//     virtual void setSeedLanguage(const std::string &arg) = 0;
//     virtual int status() const = 0;
int MONERO_Wallet_status(void* wallet_ptr);
//     virtual std::string errorString() const = 0;
const char* MONERO_Wallet_errorString(void* wallet_ptr);
//     virtual void statusWithErrorString(int& status, std::string& errorString) const = 0;
//     virtual bool setPassword(const std::string &password) = 0;
//     virtual const std::string& getPassword() const = 0;
//     virtual bool setDevicePin(const std::string &pin) { (void)pin; return false; };
//     virtual bool setDevicePassphrase(const std::string &passphrase) { (void)passphrase; return false; };
//     virtual std::string address(uint32_t accountIndex = 0, uint32_t addressIndex = 0) const = 0;
const char* MONERO_Wallet_address(void* wallet_ptr, uint64_t accountIndex, uint64_t addressIndex);
//     std::string mainAddress() const { return address(0, 0); }
//     virtual std::string path() const = 0;
//     virtual NetworkType nettype() const = 0;
//     bool mainnet() const { return nettype() == MAINNET; }
//     bool testnet() const { return nettype() == TESTNET; }
//     bool stagenet() const { return nettype() == STAGENET; }
//     virtual void hardForkInfo(uint8_t &version, uint64_t &earliest_height) const = 0;
//     virtual bool useForkRules(uint8_t version, int64_t early_blocks) const = 0;  
//     virtual std::string integratedAddress(const std::string &payment_id) const = 0;
//     virtual std::string secretViewKey() const = 0;
const char* MONERO_Wallet_secretViewKey(void* wallet_ptr);
//     virtual std::string publicViewKey() const = 0;
const char* MONERO_Wallet_publicViewKey(void* wallet_ptr);
//     virtual std::string secretSpendKey() const = 0;
const char* MONERO_Wallet_secretSpendKey(void* wallet_ptr);
//     virtual std::string publicSpendKey() const = 0;
const char* MONERO_Wallet_publicSpendKey(void* wallet_ptr);
//     virtual std::string publicMultisigSignerKey() const = 0;
//     virtual void stop() = 0;
void MONERO_Wallet_stop(void* wallet_ptr);
//     virtual bool store(const std::string &path) = 0;
bool MONERO_Wallet_store(void* wallet_ptr, const char* path);
//     virtual std::string filename() const = 0;
//     virtual std::string keysFilename() const = 0;
//     virtual bool init(const std::string &daemon_address, uint64_t upper_transaction_size_limit = 0, const std::string &daemon_username = "", const std::string &daemon_password = "", bool use_ssl = false, bool lightWallet = false, const std::string &proxy_address = "") = 0;
bool MONERO_Wallet_init(void* wallet_ptr, const char* daemon_address, uint64_t upper_transaction_size_limit, const char* daemon_username, const char* daemon_password, bool use_ssl, bool lightWallet, const char* proxy_address);
//     virtual bool createWatchOnly(const std::string &path, const std::string &password, const std::string &language) const = 0;
//     virtual void setRefreshFromBlockHeight(uint64_t refresh_from_block_height) = 0;
//     virtual uint64_t getRefreshFromBlockHeight() const = 0;
//     virtual void setRecoveringFromSeed(bool recoveringFromSeed) = 0;
//     virtual void setRecoveringFromDevice(bool recoveringFromDevice) = 0;
//     virtual void setSubaddressLookahead(uint32_t major, uint32_t minor) = 0;
//     virtual bool connectToDaemon() = 0;
//     virtual ConnectionStatus connected() const = 0;
//     virtual void setTrustedDaemon(bool arg) = 0;
//     virtual bool trustedDaemon() const = 0;
//     virtual bool setProxy(const std::string &address) = 0;
//     virtual uint64_t balance(uint32_t accountIndex = 0) const = 0;
uint64_t MONERO_Wallet_balance(void* wallet_ptr, uint32_t accountIndex);
//     uint64_t balanceAll() const {
//         uint64_t result = 0;
//         for (uint32_t i = 0; i < numSubaddressAccounts(); ++i)
//             result += balance(i);
//         return result;
//     }
//     virtual uint64_t unlockedBalance(uint32_t accountIndex = 0) const = 0;
uint64_t MONERO_Wallet_unlockedBalance(void* wallet_ptr, uint32_t accountIndex);
//     uint64_t unlockedBalanceAll() const {
//         uint64_t result = 0;
//         for (uint32_t i = 0; i < numSubaddressAccounts(); ++i)
//             result += unlockedBalance(i);
//         return result;
//     }
//     virtual bool watchOnly() const = 0;
bool MONERO_Wallet_watchOnly(void* wallet_ptr);
//     virtual bool isDeterministic() const = 0;
bool MONERO_Wallet_isDeterministic(void* wallet_ptr);
//     virtual uint64_t blockChainHeight() const = 0;
uint64_t MONERO_Wallet_blockChainHeight(void* wallet_ptr);
//     virtual uint64_t approximateBlockChainHeight() const = 0;
uint64_t MONERO_Wallet_approximateBlockChainHeight(void* wallet_ptr);
//     virtual uint64_t estimateBlockChainHeight() const = 0;
uint64_t MONERO_Wallet_estimateBlockChainHeight(void* wallet_ptr);
//     virtual uint64_t daemonBlockChainHeight() const = 0;
uint64_t MONERO_Wallet_daemonBlockChainHeight(void* wallet_ptr);
//     virtual uint64_t daemonBlockChainTargetHeight() const = 0;
uint64_t MONERO_Wallet_daemonBlockChainTargetHeight(void* wallet_ptr);
//     virtual bool synchronized() const = 0;
bool MONERO_Wallet_synchronized(void* wallet_ptr);
//     static std::string displayAmount(uint64_t amount);
const char* MONERO_Wallet_displayAmount(uint64_t amount);
//     static uint64_t amountFromString(const std::string &amount);
//     static uint64_t amountFromDouble(double amount);
//     static std::string genPaymentId();
//     static bool paymentIdValid(const std::string &paiment_id);
//     static bool addressValid(const std::string &str, NetworkType nettype);
bool MONERO_Wallet_addressValid(const char* str, int nettype);
//     static bool addressValid(const std::string &str, bool testnet)          // deprecated
//     {
//         return addressValid(str, testnet ? TESTNET : MAINNET);
//     }
//     static bool keyValid(const std::string &secret_key_string, const std::string &address_string, bool isViewKey, NetworkType nettype, std::string &error);
//     static bool keyValid(const std::string &secret_key_string, const std::string &address_string, bool isViewKey, bool testnet, std::string &error)     // deprecated
//     {
//         return keyValid(secret_key_string, address_string, isViewKey, testnet ? TESTNET : MAINNET, error);
//     }
//     static std::string paymentIdFromAddress(const std::string &str, NetworkType nettype);
//     static std::string paymentIdFromAddress(const std::string &str, bool testnet)       // deprecated
//     {
//         return paymentIdFromAddress(str, testnet ? TESTNET : MAINNET);
//     }
//     static uint64_t maximumAllowedAmount();
//     static void init(const char *argv0, const char *default_log_base_name) { init(argv0, default_log_base_name, "", true); }
//     static void init(const char *argv0, const char *default_log_base_name, const std::string &log_path, bool console);
void MONERO_Wallet_init3(void* wallet_ptr, const char* argv0, const char* default_log_base_name, const char* log_path, bool console);
//     static void debug(const std::string &category, const std::string &str);
//     static void info(const std::string &category, const std::string &str);
//     static void warning(const std::string &category, const std::string &str);
//     static void error(const std::string &category, const std::string &str);
//     virtual void startRefresh() = 0;
void MONERO_Wallet_startRefresh(void* wallet_ptr);
//     virtual void pauseRefresh() = 0;
void MONERO_Wallet_pauseRefresh(void* wallet_ptr);
//     virtual bool refresh() = 0;
bool MONERO_Wallet_refresh(void* wallet_ptr);
//     virtual void refreshAsync() = 0;
void MONERO_Wallet_refreshAsync(void* wallet_ptr);
//     virtual bool rescanBlockchain() = 0;
bool MONERO_Wallet_rescanBlockchain(void* wallet_ptr);
//     virtual void rescanBlockchainAsync() = 0;
void MONERO_Wallet_rescanBlockchainAsync(void* wallet_ptr);
//     virtual void setAutoRefreshInterval(int millis) = 0;
void MONERO_Wallet_setAutoRefreshInterval(void* wallet_ptr, int millis);
//     virtual int autoRefreshInterval() const = 0;
int MONERO_Wallet_autoRefreshInterval(void* wallet_ptr);
//     virtual void addSubaddressAccount(const std::string& label) = 0;
void MONERO_Wallet_addSubaddressAccount(void* wallet_ptr, const char* label);
//     virtual size_t numSubaddressAccounts() const = 0;
size_t MONERO_Wallet_numSubaddressAccounts(void* wallet_ptr);
//     virtual size_t numSubaddresses(uint32_t accountIndex) const = 0;
size_t MONERO_Wallet_numSubaddresses(void* wallet_ptr, uint32_t accountIndex);
//     virtual void addSubaddress(uint32_t accountIndex, const std::string& label) = 0;
void MONERO_Wallet_addSubaddress(void* wallet_ptr, uint32_t accountIndex, const char* label);
//     virtual std::string getSubaddressLabel(uint32_t accountIndex, uint32_t addressIndex) const = 0;
const char* MONERO_Wallet_getSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex);
//     virtual void setSubaddressLabel(uint32_t accountIndex, uint32_t addressIndex, const std::string &label) = 0;
void MONERO_Wallet_setSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex, const char* label);
//     virtual MultisigState multisig() const = 0;
//     virtual std::string getMultisigInfo() const = 0;
//     virtual std::string makeMultisig(const std::vector<std::string>& info, uint32_t threshold) = 0;
//     virtual std::string exchangeMultisigKeys(const std::vector<std::string> &info, const bool force_update_use_with_caution) = 0;
//     virtual bool exportMultisigImages(std::string& images) = 0;
//     virtual size_t importMultisigImages(const std::vector<std::string>& images) = 0;
//     virtual bool hasMultisigPartialKeyImages() const = 0;
//     virtual PendingTransaction*  restoreMultisigTransaction(const std::string& signData) = 0;
//     virtual PendingTransaction * createTransactionMultDest(const std::vector<std::string> &dst_addr, const std::string &payment_id,
//                                                    optional<std::vector<uint64_t>> amount, uint32_t mixin_count,
//                                                    PendingTransaction::Priority = PendingTransaction::Priority_Low,
//                                                    uint32_t subaddr_account = 0,
//                                                    std::set<uint32_t> subaddr_indices = {}) = 0;
//     virtual PendingTransaction * createTransaction(const std::string &dst_addr, const std::string &payment_id,
//                                                    optional<uint64_t> amount, uint32_t mixin_count,
//                                                    PendingTransaction::Priority = PendingTransaction::Priority_Low,
//                                                    uint32_t subaddr_account = 0,
//                                                    std::set<uint32_t> subaddr_indices = {}) = 0;
void* MONERO_Wallet_createTransaction(void* wallet_ptr, const char* dst_addr, const char* payment_id,
                                                    uint64_t amount, uint32_t mixin_count,
                                                    int pendingTransactionPriority,
                                                    uint32_t subaddr_account); // std::nullopt
//     virtual PendingTransaction * createSweepUnmixableTransaction() = 0;
//     virtual UnsignedTransaction * loadUnsignedTx(const std::string &unsigned_filename) = 0;
//     virtual bool submitTransaction(const std::string &fileName) = 0;
bool MONERO_Wallet_submitTransaction(void* wallet_ptr, const char* fileName);
//     virtual void disposeTransaction(PendingTransaction * t) = 0;
//     virtual uint64_t estimateTransactionFee(const std::vector<std::pair<std::string, uint64_t>> &destinations,
//                                             PendingTransaction::Priority priority) const = 0;
//     virtual bool exportKeyImages(const std::string &filename, bool all = false) = 0;
bool MONERO_Wallet_exportKeyImages(void* wallet_ptr, const char* filename, bool all);
//     virtual bool importKeyImages(const std::string &filename) = 0;
bool MONERO_Wallet_importKeyImages(void* wallet_ptr, const char* filename);
//     virtual bool exportOutputs(const std::string &filename, bool all = false) = 0;
bool MONERO_Wallet_exportOutputs(void* wallet_ptr, const char* filename, bool all);
//     virtual bool importOutputs(const std::string &filename) = 0;
bool MONERO_Wallet_importOutputs(void* wallet_ptr, const char* filename);
//     virtual bool scanTransactions(const std::vector<std::string> &txids) = 0;
//     virtual TransactionHistory * history() = 0;
void* MONERO_Wallet_history(void* wallet_ptr);
//     virtual AddressBook * addressBook() = 0;
//     virtual Coins * coins() = 0;
//     virtual Subaddress * subaddress() = 0;
//     virtual SubaddressAccount * subaddressAccount() = 0;
//     virtual void setListener(WalletListener *) = 0;
//     virtual uint32_t defaultMixin() const = 0;
//     virtual void setDefaultMixin(uint32_t arg) = 0;
//     virtual bool setCacheAttribute(const std::string &key, const std::string &val) = 0;
//     virtual std::string getCacheAttribute(const std::string &key) const = 0;
//     virtual bool setUserNote(const std::string &txid, const std::string &note) = 0;
//     virtual std::string getUserNote(const std::string &txid) const = 0;
//     virtual std::string getTxKey(const std::string &txid) const = 0;
//     virtual bool checkTxKey(const std::string &txid, std::string tx_key, const std::string &address, uint64_t &received, bool &in_pool, uint64_t &confirmations) = 0;
//     virtual std::string getTxProof(const std::string &txid, const std::string &address, const std::string &message) const = 0;
//     virtual bool checkTxProof(const std::string &txid, const std::string &address, const std::string &message, const std::string &signature, bool &good, uint64_t &received, bool &in_pool, uint64_t &confirmations) = 0;
//     virtual std::string getSpendProof(const std::string &txid, const std::string &message) const = 0;
//     virtual bool checkSpendProof(const std::string &txid, const std::string &message, const std::string &signature, bool &good) const = 0;
//     virtual std::string getReserveProof(bool all, uint32_t account_index, uint64_t amount, const std::string &message) const = 0;
//     virtual bool checkReserveProof(const std::string &address, const std::string &message, const std::string &signature, bool &good, uint64_t &total, uint64_t &spent) const = 0;
//     virtual std::string signMessage(const std::string &message, const std::string &address = "") = 0;
//     virtual bool verifySignedMessage(const std::string &message, const std::string &addres, const std::string &signature) const = 0;
//     virtual std::string signMultisigParticipant(const std::string &message) const = 0;
//     virtual bool verifyMessageWithPublicKey(const std::string &message, const std::string &publicKey, const std::string &signature) const = 0;
//     virtual bool parse_uri(const std::string &uri, std::string &address, std::string &payment_id, uint64_t &amount, std::string &tx_description, std::string &recipient_name, std::vector<std::string> &unknown_parameters, std::string &error) = 0;
//     virtual std::string make_uri(const std::string &address, const std::string &payment_id, uint64_t amount, const std::string &tx_description, const std::string &recipient_name, std::string &error) const = 0;
//     virtual std::string getDefaultDataDir() const = 0;
//     virtual bool rescanSpent() = 0;
//     virtual void setOffline(bool offline) = 0;
//     virtual bool isOffline() const = 0;
//     virtual bool blackballOutputs(const std::vector<std::string> &outputs, bool add) = 0;
//     virtual bool blackballOutput(const std::string &amount, const std::string &offset) = 0;
//     virtual bool unblackballOutput(const std::string &amount, const std::string &offset) = 0;
//     virtual bool getRing(const std::string &key_image, std::vector<uint64_t> &ring) const = 0;
//     virtual bool getRings(const std::string &txid, std::vector<std::pair<std::string, std::vector<uint64_t>>> &rings) const = 0;
//     virtual bool setRing(const std::string &key_image, const std::vector<uint64_t> &ring, bool relative) = 0;
//     virtual void segregatePreForkOutputs(bool segregate) = 0;
//     virtual void segregationHeight(uint64_t height) = 0;
//     virtual void keyReuseMitigation2(bool mitigation) = 0;
//     virtual bool lightWalletLogin(bool &isNewWallet) const = 0;
//     virtual bool lightWalletImportWalletRequest(std::string &payment_id, uint64_t &fee, bool &new_request, bool &request_fulfilled, std::string &payment_address, std::string &status) = 0;
//     virtual bool lockKeysFile() = 0;
//     virtual bool unlockKeysFile() = 0;
//     virtual bool isKeysFileLocked() = 0;
//     virtual Device getDeviceType() const = 0;
//     virtual uint64_t coldKeyImageSync(uint64_t &spent, uint64_t &unspent) = 0;
//     virtual void deviceShowAddress(uint32_t accountIndex, uint32_t addressIndex, const std::string &paymentId) = 0;
//     virtual bool reconnectDevice() = 0;
//     virtual uint64_t getBytesReceived() = 0;
uint64_t MONERO_Wallet_getBytesReceived(void* wallet_ptr);
//     virtual uint64_t getBytesSent() = 0;
uint64_t MONERO_Wallet_getBytesSent(void* wallet_ptr);
// };

// struct WalletManager
// {
//     virtual Wallet * createWallet(const std::string &path, const std::string &password, const std::string &language, NetworkType nettype, uint64_t kdf_rounds = 1) = 0;
void* MONERO_WalletManager_createWallet(const char* path, const char* password, const char* language, int networkType);
//     Wallet * createWallet(const std::string &path, const std::string &password, const std::string &language, bool testnet = false)      // deprecated
//     {
//         return createWallet(path, password, language, testnet ? TESTNET : MAINNET);
//     }
//     virtual Wallet * openWallet(const std::string &path, const std::string &password, NetworkType nettype, uint64_t kdf_rounds = 1, WalletListener * listener = nullptr) = 0;
void* MONERO_WalletManager_openWallet(const char* path, const char* password, int networkType);
//     Wallet * openWallet(const std::string &path, const std::string &password, bool testnet = false)     // deprecated
//     {
//         return openWallet(path, password, testnet ? TESTNET : MAINNET);
//     }
//     virtual Wallet * recoveryWallet(const std::string &path, const std::string &password, const std::string &mnemonic,
//                                     NetworkType nettype = MAINNET, uint64_t restoreHeight = 0, uint64_t kdf_rounds = 1,
//                                     const std::string &seed_offset = {}) = 0;
void* MONERO_WalletManager_recoveryWallet(const char* path, const char* password, const char* mnemonic, int networkType, uint64_t restoreHeight, uint64_t kdfRounds, const char* seedOffset);
//     Wallet * recoveryWallet(const std::string &path, const std::string &password, const std::string &mnemonic,
//                                     bool testnet = false, uint64_t restoreHeight = 0)           // deprecated
//     {
//         return recoveryWallet(path, password, mnemonic, testnet ? TESTNET : MAINNET, restoreHeight);
//     }
//     virtual Wallet * recoveryWallet(const std::string &path, const std::string &mnemonic, NetworkType nettype, uint64_t restoreHeight = 0) = 0;
//     Wallet * recoveryWallet(const std::string &path, const std::string &mnemonic, bool testnet = false, uint64_t restoreHeight = 0)         // deprecated
//     {
//         return recoveryWallet(path, mnemonic, testnet ? TESTNET : MAINNET, restoreHeight);
//     }
//     virtual Wallet * createWalletFromKeys(const std::string &path,
//                                                     const std::string &password,
//                                                     const std::string &language,
//                                                     NetworkType nettype,
//                                                     uint64_t restoreHeight,
//                                                     const std::string &addressString,
//                                                     const std::string &viewKeyString,
//                                                     const std::string &spendKeyString = "",
//                                                     uint64_t kdf_rounds = 1) = 0;
//     Wallet * createWalletFromKeys(const std::string &path,
//                                   const std::string &password,
//                                   const std::string &language,
//                                   bool testnet,
//                                   uint64_t restoreHeight,
//                                   const std::string &addressString,
//                                   const std::string &viewKeyString,
//                                   const std::string &spendKeyString = "")       // deprecated
//     {
//         return createWalletFromKeys(path, password, language, testnet ? TESTNET : MAINNET, restoreHeight, addressString, viewKeyString, spendKeyString);
//     }
//     virtual Wallet * createWalletFromKeys(const std::string &path, 
//                                                     const std::string &language,
//                                                     NetworkType nettype, 
//                                                     uint64_t restoreHeight,
//                                                     const std::string &addressString,
//                                                     const std::string &viewKeyString,
//                                                     const std::string &spendKeyString = "") = 0;
//     Wallet * createWalletFromKeys(const std::string &path, 
//                                   const std::string &language,
//                                   bool testnet, 
//                                   uint64_t restoreHeight,
//                                   const std::string &addressString,
//                                   const std::string &viewKeyString,
//                                   const std::string &spendKeyString = "")           // deprecated
//     {
//         return createWalletFromKeys(path, language, testnet ? TESTNET : MAINNET, restoreHeight, addressString, viewKeyString, spendKeyString);
//     }
//     virtual Wallet * createWalletFromDevice(const std::string &path,
//                                             const std::string &password,
//                                             NetworkType nettype,
//                                             const std::string &deviceName,
//                                             uint64_t restoreHeight = 0,
//                                             const std::string &subaddressLookahead = "",
//                                             uint64_t kdf_rounds = 1,
//                                             WalletListener * listener = nullptr) = 0;
//     virtual bool closeWallet(Wallet *wallet, bool store = true) = 0;
bool MONERO_WalletManager_closeWallet(void* wallet_ptr, bool store);
//     virtual bool walletExists(const std::string &path) = 0;
bool MONERO_WalletManager_walletExists(void* wallet_ptr, const char* path);
//     virtual bool verifyWalletPassword(const std::string &keys_file_name, const std::string &password, bool no_spend_key, uint64_t kdf_rounds = 1) const = 0;
//     virtual bool queryWalletDevice(Wallet::Device& device_type, const std::string &keys_file_name, const std::string &password, uint64_t kdf_rounds = 1) const = 0;
//     virtual std::vector<std::string> findWallets(const std::string &path) = 0;
//     virtual std::string errorString() const = 0;
const char* MONERO_WalletManager_errorString(void* wallet_ptr);
//     virtual void setDaemonAddress(const std::string &address) = 0;
void MONERO_WalletManager_setDaemonAddress(void* wallet_ptr, const char* address);
//     virtual bool connected(uint32_t *version = NULL) = 0;
//     virtual uint64_t blockchainHeight() = 0;
//     virtual uint64_t blockchainTargetHeight() = 0;
//     virtual uint64_t networkDifficulty() = 0;
//     virtual double miningHashRate() = 0;
//     virtual uint64_t blockTarget() = 0;
//     virtual bool isMining() = 0;
//     virtual bool startMining(const std::string &address, uint32_t threads = 1, bool background_mining = false, bool ignore_battery = true) = 0;
//     virtual bool stopMining() = 0;
//     virtual std::string resolveOpenAlias(const std::string &address, bool &dnssec_valid) const = 0;
//     static std::tuple<bool, std::string, std::string, std::string, std::string> checkUpdates(
//         const std::string &software,
//         std::string subdir,
//         const char *buildtag = nullptr,
//         const char *current_version = nullptr);
//     virtual bool setProxy(const std::string &address) = 0;
// };

// struct WalletManagerFactory
// {
//     enum LogLevel {
//         LogLevel_Silent = -1,
//         LogLevel_0 = 0,
//         LogLevel_1 = 1,
//         LogLevel_2 = 2,
//         LogLevel_3 = 3,
//         LogLevel_4 = 4,
//         LogLevel_Min = LogLevel_Silent,
//         LogLevel_Max = LogLevel_4
//     };
//     static WalletManager * getWalletManager();
//     static void setLogLevel(int level);
//     static void setLogCategories(const std::string &categories);
// };
// }

int MONERO_DEBUG_theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything(int x);

#ifdef __cplusplus
}
#endif