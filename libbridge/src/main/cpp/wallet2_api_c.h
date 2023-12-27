/*
#include <android/log.h>

#define  LOG_TAG    "[NDK]"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGW(...)  __android_log_print(ANDROID_LOG_WARN,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
*/

#ifdef __cplusplus
extern "C"
{
#endif

void* MONERO_WalletManager_createWallet(const char* path, const char* password, const char* language, int networkType);
const char* MONERO_Wallet_errorString(void* wallet_ptr);
int MONERO_Wallet_status(void* wallet_ptr);
int MONERO_DEBUG_sleep(int time);

#ifdef __cplusplus
}
#endif