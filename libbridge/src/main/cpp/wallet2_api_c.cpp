#include <inttypes.h>
#include "wallet2_api_c.h"
#include "wallet2_api.h"
#include <unistd.h>

#ifdef __cplusplus
extern "C"
{
#endif

#include <android/log.h>
#define LOG_TAG "wallet2_api_c"
#define LOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, LOG_TAG,__VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG  , LOG_TAG,__VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO   , LOG_TAG,__VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN   , LOG_TAG,__VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR  , LOG_TAG,__VA_ARGS__)

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C"
{
#endif

// PendingTransaction

int MONERO_PendingTransaction_status(void* pendingTx_ptr) {
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->status();
}
const char* MONERO_PendingTransaction_errorString(void* pendingTx_ptr) {
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->errorString().c_str();
}
bool MONERO_PendingTransaction_commit(void* pendingTx_ptr, const char* filename, bool overwrite) {
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->commit(std::string(filename), overwrite);
}
uint64_t MONERO_PendingTransaction_amount(void* pendingTx_ptr) {
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->amount();
}
uint64_t MONERO_PendingTransaction_dust(void* pendingTx_ptr) {
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->dust();
}
uint64_t MONERO_PendingTransaction_fee(void* pendingTx_ptr) {
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->fee();
}
uint64_t MONERO_PendingTransaction_txCount(void* pendingTx_ptr) {
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->txCount();
}

// TransactionInfo
int MONERO_TransactionInfo_direction(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->direction();
}
bool MONERO_TransactionInfo_isPending(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isPending();
}
bool MONERO_TransactionInfo_isFailed(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isFailed();
}
bool MONERO_TransactionInfo_isCoinbase(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isCoinbase();
}
uint64_t MONERO_TransactionInfo_amount(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->amount();
}
uint64_t MONERO_TransactionInfo_fee(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->fee();
}
uint64_t MONERO_TransactionInfo_blockHeight(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->blockHeight();
}
const char* MONERO_TransactionInfo_description(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->description().c_str();
}
uint32_t MONERO_TransactionInfo_subaddrAccount(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->subaddrAccount();
}
const char* MONERO_TransactionInfo_label(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->label().c_str();
}
uint64_t MONERO_TransactionInfo_confirmations(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->confirmations();
}
uint64_t MONERO_TransactionInfo_unlockTime(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->unlockTime();
}
const char* MONERO_TransactionInfo_hash(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->hash().c_str();
}
uint64_t MONERO_TransactionInfo_timestamp(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->timestamp();
}
const char* MONERO_TransactionInfo_paymentId(void* txInfo_ptr) {
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->paymentId().c_str();
}

// TransactionHistory
int MONERO_TransactionHistory_count(void* txHistory_ptr) {
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->count();
}
void* MONERO_TransactionHistory_transaction(void* txHistory_ptr, int index) {
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return reinterpret_cast<void*>(txHistory->transaction(index));
}
void MONERO_TransactionHistory_refresh(void* txHistory_ptr) {
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->refresh();
}
void MONERO_TransactionHistory_setTxNote(void* txHistory_ptr, const char* txid, const char* note) {
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->setTxNote(std::string(txid), std::string(note));
}

// Wallet


const char* MONERO_Wallet_seed(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->seed().c_str();
}

int MONERO_Wallet_status(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->status();
}

const char* MONERO_Wallet_errorString(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->errorString().c_str();
}

const char* MONERO_Wallet_address(void* wallet_ptr, uint64_t accountIndex, uint64_t addressIndex) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->address(accountIndex, addressIndex).c_str();    
}

const char* MONERO_Wallet_secretViewKey(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->secretViewKey().c_str();
}

const char* MONERO_Wallet_publicViewKey(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->publicViewKey().c_str();
}

const char* MONERO_Wallet_secretSpendKey(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->secretSpendKey().c_str();
}

const char* MONERO_Wallet_publicSpendKey(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->publicSpendKey().c_str();
}

void MONERO_Wallet_stop(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    wallet->stop();
}

bool MONERO_Wallet_store(void* wallet_ptr, const char* path) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->store(std::string(path));
}

//     virtual bool init(const std::string &daemon_address, uint64_t upper_transaction_size_limit = 0, const std::string &daemon_username = "", const std::string &daemon_password = "", bool use_ssl = false, bool lightWallet = false, const std::string &proxy_address = "") = 0;
bool MONERO_Wallet_init(void* wallet_ptr, const char* daemon_address, uint64_t upper_transaction_size_limit, const char* daemon_username, const char* daemon_password, bool use_ssl, bool lightWallet, const char* proxy_address) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->init(std::string(daemon_address), upper_transaction_size_limit, std::string(daemon_username), std::string(daemon_password), use_ssl, lightWallet, std::string(proxy_address));
}

void MONERO_Wallet_setRefreshFromBlockHeight(void* wallet_ptr, uint64_t refresh_from_block_height) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setRefreshFromBlockHeight(refresh_from_block_height);
}

uint64_t MONERO_Wallet_getRefreshFromBlockHeight(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getRefreshFromBlockHeight();
}
bool MONERO_Wallet_connectToDaemon(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->connectToDaemon();
}
int MONERO_Wallet_connected(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->connected();
}
bool MONERO_Wallet_setProxy(void* wallet_ptr, const char* address) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setProxy(std::string(address));
}

uint64_t MONERO_Wallet_balance(void* wallet_ptr, uint32_t accountIndex) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->balance(accountIndex);
}

uint64_t MONERO_Wallet_unlockedBalance(void* wallet_ptr, uint32_t accountIndex) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->unlockedBalance(accountIndex);
}

// TODO
bool MONERO_Wallet_watchOnly(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->watchOnly();
}
bool MONERO_Wallet_isDeterministic(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->isDeterministic();
}
uint64_t MONERO_Wallet_blockChainHeight(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->blockChainHeight();
}
uint64_t MONERO_Wallet_approximateBlockChainHeight(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->approximateBlockChainHeight();
}
uint64_t MONERO_Wallet_estimateBlockChainHeight(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->estimateBlockChainHeight();
}
uint64_t MONERO_Wallet_daemonBlockChainHeight(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->daemonBlockChainHeight();
}
uint64_t MONERO_Wallet_daemonBlockChainTargetHeight(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->daemonBlockChainTargetHeight();
}
bool MONERO_Wallet_synchronized(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->synchronized();
}
const char* MONERO_Wallet_displayAmount(uint64_t amount) {
    // Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return Monero::Wallet::displayAmount(amount).c_str();
}
bool MONERO_Wallet_addressValid(const char* str, int nettype) {
    // Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return Monero::Wallet::addressValid(std::string(str), nettype);
}
void MONERO_Wallet_init3(void* wallet_ptr, const char* argv0, const char* default_log_base_name, const char* log_path, bool console) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->init(argv0, default_log_base_name, log_path, console);
}
void MONERO_Wallet_startRefresh(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->startRefresh();
}
void MONERO_Wallet_pauseRefresh(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->pauseRefresh();
}
bool MONERO_Wallet_refresh(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->refresh();
}
void MONERO_Wallet_refreshAsync(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->refreshAsync();
}
bool MONERO_Wallet_rescanBlockchain(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanBlockchain();
}
void MONERO_Wallet_rescanBlockchainAsync(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanBlockchainAsync();
}
void MONERO_Wallet_setAutoRefreshInterval(void* wallet_ptr, int millis) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setAutoRefreshInterval(millis);
}
int MONERO_Wallet_autoRefreshInterval(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->autoRefreshInterval();
}
void MONERO_Wallet_addSubaddressAccount(void* wallet_ptr, const char* label) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->addSubaddressAccount(std::string(label));
}
size_t MONERO_Wallet_numSubaddressAccounts(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->numSubaddressAccounts();
}
size_t MONERO_Wallet_numSubaddresses(void* wallet_ptr, uint32_t accountIndex) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->numSubaddresses(accountIndex);
}
void MONERO_Wallet_addSubaddress(void* wallet_ptr, uint32_t accountIndex, const char* label) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->addSubaddress(accountIndex, std::string(label));
}
const char* MONERO_Wallet_getSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getSubaddressLabel(accountIndex, addressIndex).c_str();
}

void MONERO_Wallet_setSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex, const char* label) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setSubaddressLabel(accountIndex, addressIndex, std::string(label));
}
void* MONERO_Wallet_createTransaction(void* wallet_ptr, const char* dst_addr, const char* payment_id,
                                                    uint64_t amount, uint32_t mixin_count,
                                                    int pendingTransactionPriority,
                                                    uint32_t subaddr_account) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->createTransaction(std::string(dst_addr), std::string(payment_id),
                                        amount, mixin_count,
                                        Monero::PendingTransaction::Priority_Low,
                                        subaddr_account /*, subaddr_indices */);
}
bool MONERO_Wallet_submitTransaction(void* wallet_ptr, const char* fileName) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->submitTransaction(std::string(fileName));
}
bool MONERO_Wallet_exportKeyImages(void* wallet_ptr, const char* filename, bool all) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->exportKeyImages(std::string(filename), all);
}
bool MONERO_Wallet_importKeyImages(void* wallet_ptr, const char* filename) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->importKeyImages(std::string(filename));
}
bool MONERO_Wallet_exportOutputs(void* wallet_ptr, const char* filename, bool all) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->exportOutputs(std::string(filename), all);
}
bool MONERO_Wallet_importOutputs(void* wallet_ptr, const char* filename) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->importOutputs(std::string(filename));
}
void* MONERO_Wallet_history(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return reinterpret_cast<void*>(wallet->history());
}
//     virtual void setOffline(bool offline) = 0;
void MONERO_Wallet_setOffline(void* wallet_ptr, bool offline) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setOffline(offline);
}
//     virtual bool isOffline() const = 0;
bool MONERO_Wallet_isOffline(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->isOffline();
}

uint64_t MONERO_Wallet_getBytesReceived(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getBytesReceived();
}
uint64_t MONERO_Wallet_getBytesSent(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getBytesSent();
}

void* MONERO_WalletManager_createWallet(const char* path, const char* password, const char* language, int networkType) {
    Monero::Wallet *wallet =
            Monero::WalletManagerFactory::getWalletManager()->createWallet(
                    std::string(path),
                    std::string(password),
                    std::string(language),
                    static_cast<Monero::NetworkType>(networkType));
    return reinterpret_cast<void*>(wallet);
}

void* MONERO_WalletManager_openWallet(const char* path, const char* password, int networkType) {
    Monero::Wallet *wallet =
            Monero::WalletManagerFactory::getWalletManager()->openWallet(
                    std::string(path),
                    std::string(password),
                    static_cast<Monero::NetworkType>(networkType));
    return reinterpret_cast<void*>(wallet);
}
void* MONERO_WalletManager_recoveryWallet(const char* path, const char* password, const char* mnemonic, int networkType, uint64_t restoreHeight, uint64_t kdfRounds, const char* seedOffset) {
    // (const std::string &path, const std::string &password, const std::string &mnemonic,
    //                                     NetworkType nettype = MAINNET, uint64_t restoreHeight = 0, uint64_t kdf_rounds = 1,
    //                                     const std::string &seed_offset = {})
    Monero::Wallet *wallet =
            Monero::WalletManagerFactory::getWalletManager()->recoveryWallet(
                    std::string(path),
                    std::string(password),
                    std::string(mnemonic),
                    static_cast<Monero::NetworkType>(networkType),
                    restoreHeight,
                    kdfRounds,
                    std::string(seedOffset));
    return reinterpret_cast<void*>(wallet);
}

bool MONERO_WalletManager_closeWallet(void* wallet_ptr, bool store) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return Monero::WalletManagerFactory::getWalletManager()->closeWallet(
                    wallet,
                    store);
}

bool MONERO_WalletManager_walletExists(const char* path) {
    return Monero::WalletManagerFactory::getWalletManager()->walletExists(std::string(path));
}
const char* MONERO_WalletManager_errorString() {
    return Monero::WalletManagerFactory::getWalletManager()->errorString().c_str();
}

void MONERO_WalletManager_setDaemonAddress(const char* address) {
    return Monero::WalletManagerFactory::getWalletManager()->setDaemonAddress(std::string(address));
}

bool MONERO_WalletManager_setProxy(const char* address) {
    return Monero::WalletManagerFactory::getWalletManager()->setProxy(std::string(address));
}

// WalletManagerFactory

void MONERO_WalletManagerFactory_setLogLevel(int level) {
    Monero::WalletManagerFactory::setLogLevel(level);
}

// DEBUG functions


// the Answer to the Ultimate Question of Life, the Universe, and Everything.
int MONERO_DEBUG_theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything(int x) {
    return x*42;
}

#ifdef __cplusplus
}
#endif
