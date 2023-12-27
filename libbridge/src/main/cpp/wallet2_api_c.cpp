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

// void* MONERO_WalletManager_createWallet(const char* path, const char* password, const char* language, int networkType)
void* MONERO_WalletManager_createWallet(const char* path, const char* password, const char* language, int networkType) {
    Monero::NetworkType _networkType = static_cast<Monero::NetworkType>(networkType);
    std::cout << "WE GOT OUT\n";
    std::string _path(path);
    std::string _password(password);
    std::string _language(language);
    std::cout << "_path = " << _path << "\n";
    std::cout << "_password = " << _password << "\n";
    std::cout << "_language = " << _language << "\n";

    Monero::Wallet *wallet =
            Monero::WalletManagerFactory::getWalletManager()->createWallet(
                    _path,
                    _password,
                    _language,
                    _networkType);

    return reinterpret_cast<void*>(wallet);
}

// virtual Wallet * recoveryWallet(const std::string &path, const std::string &mnemonic, NetworkType nettype, uint64_t restoreHeight = 0) = 0;

const char* MONERO_Wallet_errorString(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->errorString().c_str();
}

int MONERO_Wallet_status(void* wallet_ptr) {
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->status();
}

int MONERO_DEBUG_sleep(int time) {
    sleep(time);
    return time-1;
}

#ifdef __cplusplus
}
#endif
