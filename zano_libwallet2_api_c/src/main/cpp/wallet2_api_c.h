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
#include <unistd.h>
#include "zano_checksum.h"

#ifdef __cplusplus
extern "C"
{
#endif

#ifdef __MINGW32__
    #define ADDAPI __declspec(dllexport)
#else
    #define ADDAPI __attribute__((__visibility__("default")))
#endif


extern ADDAPI const char* ZANO_PlainWallet_init(const char* address, const char* working_dir, int log_level);
extern ADDAPI const char* ZANO_PlainWallet_init2(const char* ip, const char* port, const char* working_dir, int log_level);
extern ADDAPI const char* ZANO_PlainWallet_reset();
extern ADDAPI const char* ZANO_PlainWallet_setLogLevel(int log_level);
extern ADDAPI const char* ZANO_PlainWallet_getVersion();
extern ADDAPI const char* ZANO_PlainWallet_getWalletFiles();
extern ADDAPI const char* ZANO_PlainWallet_getExportPrivateInfo(const char* target_dir);
extern ADDAPI const char* ZANO_PlainWallet_deleteWallet(const char* file_name);
extern ADDAPI const char* ZANO_PlainWallet_getAddressInfo(const char* addr);
extern ADDAPI const char* ZANO_PlainWallet_getAppconfig(const char* encryption_key);
extern ADDAPI const char* ZANO_PlainWallet_setAppconfig(const char* conf_str, const char* encryption_key);
extern ADDAPI const char* ZANO_PlainWallet_generateRandomKey(uint64_t lenght);
extern ADDAPI const char* ZANO_PlainWallet_getLogsBuffer();
extern ADDAPI const char* ZANO_PlainWallet_truncateLog();
extern ADDAPI const char* ZANO_PlainWallet_getConnectivityStatus();
extern ADDAPI const char* ZANO_PlainWallet_open(const char* path, const char* password);
extern ADDAPI const char* ZANO_PlainWallet_restore(const char* seed, const char* path, const char* password, const char* seed_password);
extern ADDAPI const char* ZANO_PlainWallet_generate(const char* path, const char* password);
extern ADDAPI const char* ZANO_PlainWallet_getOpenWallets();
extern ADDAPI const char* ZANO_PlainWallet_getWalletStatus(int64_t h);
extern ADDAPI const char* ZANO_PlainWallet_closeWallet(int64_t h);
extern ADDAPI const char* ZANO_PlainWallet_invoke(int64_t h, const char* params);


extern ADDAPI const char* ZANO_PlainWallet_asyncCall(const char* method_name, uint64_t instance_id, const char* params);
extern ADDAPI const char* ZANO_PlainWallet_tryPullResult(uint64_t instance_id);
extern ADDAPI const char* ZANO_PlainWallet_syncCall(const char* method_name, uint64_t instance_id, const char* params);
extern ADDAPI bool ZANO_PlainWallet_isWalletExist(const char* path);
extern ADDAPI const char* ZANO_PlainWallet_getWalletInfo(int64_t h);
extern ADDAPI const char* ZANO_PlainWallet_resetWalletPassword(int64_t h, const char* password);
extern ADDAPI uint64_t ZANO_PlainWallet_getCurrentTxFee(uint64_t priority);

extern ADDAPI void ZANO_free(void* ptr);

extern ADDAPI const char* ZANO_checksum_wallet2_api_c_h();
extern ADDAPI const char* ZANO_checksum_wallet2_api_c_cpp();
extern ADDAPI const char* ZANO_checksum_wallet2_api_c_exp();

#ifdef __cplusplus
}
#endif
