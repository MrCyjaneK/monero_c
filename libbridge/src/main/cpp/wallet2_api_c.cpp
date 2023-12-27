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

void MONERO_Wallet_store(void* wallet_ptr, const char* path) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    wallet->store(std::string(path));
}

uint64_t MONERO_Wallet_balance(void* wallet_ptr, uint32_t accountIndex) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->balance(accountIndex);
}

uint64_t MONERO_Wallet_unlockedBalance(void* wallet_ptr, uint32_t accountIndex) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->unlockedBalance(accountIndex);
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

// DEBUG functions

// the Answer to the Ultimate Question of Life, the Universe, and Everything.
int MONERO_DEBUG_theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything(int x) {
    return x*42;
}

#ifdef __cplusplus
}
#endif
