<?php

$content = file_get_contents("../../monero_libwallet2_api_c/src/main/cpp/wallet2_api_c.h");
$lines = explode("\n", $content);
$exclude = array();
$i = 0;
foreach ($lines as $line) {
    if (!str_starts_with($line, "                                        ")) {
        if (strpos($line, 'MONERO_') == FALSE) {
            continue;
        }
    }
    $i++;
    $line = str_replace("extern ADDAPI ", "", $line);
    $exclude[] = $line;
    // echo "$i: $line\n";
}
$content = implode("\n", $exclude);
// echo $content;
$ffi = FFI::cdef($content, "../../release/monero/x86_64-linux-gnu_libwallet2_api_c.so");

$wmPtr = $ffi->MONERO_WalletManagerFactory_getWalletManager();
$exists = $ffi->MONERO_WalletManager_walletExists($wmPtr, "test_wallet");
if ($exists) {
    $wPtr = $ffi->MONERO_WalletManager_openWallet($wmPtr, "test_wallet", "test_password", 0);
} else {
    $wPtr = $ffi->MONERO_WalletManager_createWallet($wmPtr, "test_wallet", "test_password", "English", 0);
}
$status = $ffi->MONERO_Wallet_status($wPtr);
if ($status != 0) {
    $error = $ffi->MONERO_Wallet_errorString($wPtr);
    echo "Unable to create wallet: $error".PHP_EOL;
    exit(1);
}
echo $ffi->MONERO_Wallet_address($wPtr, 0, 0).PHP_EOL;