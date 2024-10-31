#include <inttypes.h>
#include "wallet2_api_c.h"
#include <unistd.h>
#include <cstring>
#include <thread>
#include "zano_checksum.h"

#ifdef __cplusplus
extern "C"
{
#endif


// namespace plain_wallet
// {
//   typedef int64_t hwallet;
//   std::string init(const std::string& address, const std::string& working_dir, int log_level);
const char* ZANO_PlainWallet_init(const char* address, const char* working_dir, int log_level) {
    std::string str = plain_wallet::init(std::string(address), std::string(working_dir), log_level);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string init(const std::string& ip, const std::string& port, const std::string& working_dir, int log_level);
const char* ZANO_PlainWallet_init2(const char* ip, const char* port, const char* working_dir, int log_level) {
    std::string str = plain_wallet::init(std::string(ip), std::string(port), std::string(working_dir), log_level);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string reset();
const char* ZANO_PlainWallet_reset() {
    std::string str = plain_wallet::reset();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string set_log_level(int log_level);
const char* ZANO_PlainWallet_setLogLevel(int log_level) {
    std::string str = plain_wallet::set_log_level(log_level);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_version();
const char* ZANO_PlainWallet_getVersion() {
    std::string str = plain_wallet::get_version();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_wallet_files();
const char* ZANO_PlainWallet_getWalletFiles() {
    std::string str = plain_wallet::get_wallet_files();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_export_private_info(const std::string& target_dir);
const char* ZANO_PlainWallet_getExportPrivateInfo(const char* target_dir) {
    std::string str = plain_wallet::get_export_private_info(std::string(target_dir));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string delete_wallet(const std::string& file_name);
const char* ZANO_PlainWallet_deleteWallet(const char* file_name) {
    std::string str = plain_wallet::delete_wallet(std::string(file_name));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_address_info(const std::string& addr);
const char* ZANO_PlainWallet_getAddressInfo(const char* addr) {
    std::string str = plain_wallet::get_address_info(std::string(addr));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_appconfig(const std::string& encryption_key);
const char* ZANO_PlainWallet_getAppconfig(const char* encryption_key) {
    std::string str = plain_wallet::get_appconfig(std::string(encryption_key));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string set_appconfig(const std::string& conf_str, const std::string& encryption_key);
const char* ZANO_PlainWallet_setAppconfig(const char* conf_str, const char* encryption_key) {
    std::string str = plain_wallet::set_appconfig(std::string(conf_str), std::string(encryption_key));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string generate_random_key(uint64_t lenght);
const char* ZANO_PlainWallet_generateRandomKey(uint64_t lenght) {
    std::string str = plain_wallet::generate_random_key(lenght);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_logs_buffer();
const char* ZANO_PlainWallet_getLogsBuffer() {
    std::string str = plain_wallet::get_logs_buffer();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string truncate_log();
const char* ZANO_PlainWallet_truncateLog() {
    std::string str = plain_wallet::truncate_log();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_connectivity_status();
const char* ZANO_PlainWallet_getConnectivityStatus() {
    std::string str = plain_wallet::get_connectivity_status();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string open(const std::string& path, const std::string& password);
const char* ZANO_PlainWallet_open(const char* path, const char* password) {
    std::string str = plain_wallet::open(std::string(path), std::string(password));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string restore(const std::string& seed, const std::string& path, const std::string& password, const std::string& seed_password);
const char* ZANO_PlainWallet_restore(const char* seed, const char* path, const char* password, const char* seed_password) {
    std::string str = plain_wallet::restore(std::string(seed), std::string(path), std::string(password), std::string(seed_password));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string generate(const std::string& path, const std::string& password);
const char* ZANO_PlainWallet_generate(const char* path, const char* password) {
    std::string str = plain_wallet::generate(std::string(path), std::string(password));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string get_opened_wallets();  
const char* ZANO_PlainWallet_getOpenWallets() {
    std::string str = plain_wallet::get_opened_wallets();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}

//   std::string get_wallet_status(hwallet h);
const char* ZANO_PlainWallet_getWalletStatus(int64_t h) {
    std::string str = plain_wallet::get_wallet_status(h);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string close_wallet(hwallet h);
const char* ZANO_PlainWallet_closeWallet(int64_t h) {
    std::string str = plain_wallet::close_wallet(h);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string invoke(hwallet h, const std::string& params);
const char* ZANO_PlainWallet_invoke(int64_t h, const char* params) {
    std::string str = plain_wallet::invoke(h, std::string(params));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   //async api
//   std::string async_call(const std::string& method_name, uint64_t instance_id, const std::string& params);
const char* ZANO_PlainWallet_asyncCall(const char* method_name, uint64_t instance_id, const char* params) {
    std::string str = plain_wallet::async_call(std::string(method_name), instance_id, std::string(params));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string try_pull_result(uint64_t);
const char* ZANO_PlainWallet_tryPullResult(uint64_t instance_id) {
    std::string str = plain_wallet::try_pull_result(instance_id);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string sync_call(const std::string& method_name, uint64_t instance_id, const std::string& params);
const char* ZANO_PlainWallet_syncCall(const char* method_name, uint64_t instance_id, const char* params) {
    std::string str = plain_wallet::sync_call(std::string(method_name), instance_id, std::string(params));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   //cake wallet api extension
//   bool is_wallet_exist(const std::string& path);
bool ZANO_PlainWallet_isWalletExist(const char* path) {
    return plain_wallet::is_wallet_exist(std::string(path));
}
//   std::string get_wallet_info(hwallet h);
const char* ZANO_PlainWallet_getWalletInfo(int64_t h) {
    std::string str = plain_wallet::get_wallet_info(h);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   std::string reset_wallet_password(hwallet h, const std::string& password);
const char* ZANO_PlainWallet_resetWalletPassword(int64_t h, const char* password) {
    std::string str = plain_wallet::reset_wallet_password(h, std::string(password));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}
//   uint64_t get_current_tx_fee(uint64_t priority); // 0 (default), 1 (unimportant), 2 (normal), 3 (elevated), 4 (priority)
uint64_t ZANO_PlainWallet_getCurrentTxFee(uint64_t priority) {
    return plain_wallet::get_current_tx_fee(priority);
}
// }

const char* ZANO_checksum_wallet2_api_c_h() {
    return ZANO_wallet2_api_c_h_sha256;
}
const char* ZANO_checksum_wallet2_api_c_cpp() {
    return ZANO_wallet2_api_c_cpp_sha256;
}
const char* ZANO_checksum_wallet2_api_c_exp() {
    return ZANO_wallet2_api_c_exp_sha256;
}

#ifdef __cplusplus
}
#endif
