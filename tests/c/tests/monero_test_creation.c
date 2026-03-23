#include "../src/utils.h"
#include "../../../monero_libwallet2_api_c/src/main/cpp/monero_wallet2_api_c.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int monero_test_creation_legacy() {
    printf("monero_test_creation_legacy: ");
    char* dir = u_mktemp();
    char* path = u_cat(dir, "/wallet_1");
    void* wm_ptr = MONERO_WalletManagerFactory_getWalletManager();
    void* wallet_ptr = MONERO_WalletManager_createWallet(wm_ptr, path, "test", "English", 0);
    int status = MONERO_Wallet_status(wallet_ptr);
    if (status != 0) {
        const char* error = MONERO_Wallet_errorString(wallet_ptr);
        printf("wallet creation failed: %s\n", error);
        exit(1);
    }
    printf("OK\n");
    return 0;
}


int monero_test_creation_polyseed() {
    printf("monero_test_creation_polyseed: ");
    char* dir = u_mktemp();
    char* path = u_cat(dir, "/wallet_1");
    void* wm_ptr = MONERO_WalletManagerFactory_getWalletManager();
    const char* polyseed = MONERO_Wallet_createPolyseed("English");

    void* wallet_ptr = MONERO_WalletManager_createWalletFromPolyseed(
        wm_ptr,
        path,
        "password",
        MONERO_NetworkType_MAINNET,
        polyseed,
        "",
        false,
        0,
        0);
    int status = MONERO_Wallet_status(wallet_ptr);
    if (status != 0) {
        const char* error = MONERO_Wallet_errorString(wallet_ptr);
        printf("wallet creation failed: %s\n", error);
        exit(1);
    }
    printf("OK\n");
    return 0;
}

int monero_test_creation() {
    monero_test_creation_legacy();
    monero_test_creation_polyseed();
    return 0;
}
