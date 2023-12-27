/**
 * Copyright (c) 2017 m2049r
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <inttypes.h>
#include "wallet2_api_c.h"
#include "wallet2_api.h"

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

// void* MONERO_createWalletJ(const char* path, const char* password, const char* language, int networkType);
void* MONERO_createWalletJ(const char* path, const char* password, const char* language, int networkType) {
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

    int status;
    std::string errorString;
    wallet->statusWithErrorString(status, errorString);

    std::cout << status << " - " << errorString << "\n";

    return reinterpret_cast<void*>(wallet);
}

#ifdef __cplusplus
}
#endif
