#include <inttypes.h>
#include "nerva_wallet2_api_c.h"
#include <unistd.h>
#include "helpers.hpp"
#include <cstring>
#include <thread>
#include "../../../../nerva/src/wallet/api/wallet2_api.h"
#include "nerva_checksum.h"

#ifdef __cplusplus
extern "C"
{
#endif


// The code in here consists of simple wrappers, that convert
// more advanced c++ types (and function names) into simple C-compatible
// functions, so these implementations can be easly used from all languages
// that do support C interop (such as dart)
//
//
// Here is the most complex definition that we can find in the current codebase, it even includes
// a if statement - which in general I consider an anti-patter in just wrappers
//
//  _____________ void* because C++ wallet->createTransaction returns a pointer to Monero::PendingTransaction, which we don't want to have exposed in C land
// /      _____________ MONERO prefix just means that this function is using monero codebase, to not cause any symbols collision when using more than one libwallet2_api_c.so in a single program.
// |     /       _____________ Wallet is one of the classes in Monero namespace in the upstream codebase (see the include line above)
// |     |      /       _____________ aaand it is calling createTransaction function.
// |     |      |      /                  _________________________________________________________________________________
// |     |      |      |                 /                                                                                 \ All of these parameters can be found in the upstream
// |     |      |      |                |                                                                     _____________/ function definition, if something was more complex -
// void* NERVA_Wallet_createTransaction(void* wallet_ptr, const char* dst_addr, const char* payment_id,     / like std::set I've used splitString functions and introduced a new
//                                                     uint64_t amount, uint32_t mixin_count,               / parameter - separator, as it is the simplest way to get vector onto
//                                                     int pendingTransactionPriority,                     / C side from more advanced world.
//                                                     uint32_t subaddr_account,                          /
//                                                     const char* preferredInputs, const char* separator) {
//     Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr); <------------ We are converting the void* into Monero::Wallet*
//     Monero::optional<uint64_t> optAmount; <------------- optional by default
//     if (amount != 0) {------------------\ We set this optional parameter only when it isn't zero
//         optAmount = amount;             |
//     }___________________________________/
//     std::set<uint32_t> subaddr_indices = {}; ------------- Default value
//     std::set<std::string> preferred_inputs = splitString(std::string(preferredInputs), std::string(separator)); <------------- We are using helpers.cpp function to split a string into std::set
//     return wallet->createTransaction(std::string(dst_addr), std::string(payment_id),-\ const char * is getting casted onto std::string
//                                         optAmount, mixin_count,        \_____________/
//                                         PendingTransaction_Priority_fromInt(pendingTransactionPriority), <------------- special case for this function to get native type instead of int value.
//                                         subaddr_account, subaddr_indices, preferred_inputs);
// }
//
//
// One case which is not covered here is when we have to return a string
// const char* NERVA_PendingTransaction_errorString(void* pendingTx_ptr) {
//     Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
//     std::string str = pendingTx->errorString(); <------------- get the actual string from the upstream codebase
//     const std::string::size_type size = str.size(); ------------------------------\
//     char *buffer = new char[size + 1];   //we need extra char for NUL             | Copy the string onto a new memory so it won't get freed after the function returns
//     memcpy(buffer, str.c_str(), size + 1);                                        | NOTE: This requires us to call free() after we are done with the text processing
//     return buffer; ______________________________________________________________/
// }
//
//

const int NERVA_NetworkType_MAINNET = 0;
const int NERVA_NetworkType_TESTNET = 1;
const int NERVA_NetworkType_STAGENET = 2;

// PendingTransaction

const int NERVA_PendingTransactionStatus_Ok = 0;
const int NERVA_PendingTransactionStatus_Error = 1;
const int NERVA_PendingTransactionStatus_Critical = 2;
const int NERVA_Priority_Default = 0;
const int NERVA_Priority_Low = 1;
const int NERVA_Priority_Medium = 2;
const int NERVA_Priority_High = 3;
const int NERVA_Priority_Last = 4;

int NERVA_PendingTransaction_status(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->status();
    DEBUG_END()
}
const char* NERVA_PendingTransaction_errorString(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::string str = pendingTx->errorString();
    return strdup(str.c_str());
    DEBUG_END()
}
bool NERVA_PendingTransaction_commit(void* pendingTx_ptr, const char* filename, bool overwrite) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->commit(std::string(filename), overwrite);
    DEBUG_END()
}
const char* NERVA_PendingTransaction_commitUR(void* pendingTx_ptr, int max_fragment_length) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}


const char* NERVA_PendingTransaction_commitTrezor(void* pendingTx_ptr, int tx_index) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

uint64_t NERVA_PendingTransaction_amount(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->amount();
    DEBUG_END()
}
uint64_t NERVA_PendingTransaction_dust(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->dust();
    DEBUG_END()
}
uint64_t NERVA_PendingTransaction_fee(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->fee();
    DEBUG_END()
}
const char* NERVA_PendingTransaction_txid(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::string> txid = pendingTx->txid();
    return vectorToString(txid, std::string(separator));
    DEBUG_END()
}
uint64_t NERVA_PendingTransaction_txCount(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->txCount();
    DEBUG_END()
}
const char* NERVA_PendingTransaction_subaddrAccount(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<uint32_t> subaddrAccount = pendingTx->subaddrAccount();
    return vectorToString(subaddrAccount, std::string(separator));
    DEBUG_END()
}
const char* NERVA_PendingTransaction_subaddrIndices(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::set<uint32_t>> subaddrIndices = pendingTx->subaddrIndices();
    return vectorToString(subaddrIndices, std::string(separator));
    DEBUG_END()
}
const char* NERVA_PendingTransaction_multisigSignData(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::string str = pendingTx->multisigSignData();
    return strdup(str.c_str());
    DEBUG_END()
}
void NERVA_PendingTransaction_signMultisigTx(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->signMultisigTx();
    DEBUG_END()
}
const char* NERVA_PendingTransaction_signersKeys(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::string> txid = pendingTx->signersKeys();
    return vectorToString(txid, std::string(separator));
    DEBUG_END()
}

const char* NERVA_PendingTransaction_hex(void* pendingTx_ptr, const char* separator) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

const char* NERVA_PendingTransaction_txKey(void* pendingTx_ptr, const char* separator) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

// UnsignedTransaction

const int NERVA_UnsignedTransactionStatus_Ok = 0;
const int NERVA_UnsignedTransactionStatus_Error = 1;
const int NERVA_UnsignedTransactionStatus_Critical = 2;

int NERVA_UnsignedTransaction_status(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return unsignedTx->status();
    DEBUG_END()
}
const char* NERVA_UnsignedTransaction_errorString(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    std::string str = unsignedTx->errorString();
    return strdup(str.c_str());
    DEBUG_END()
}
const char* NERVA_UnsignedTransaction_amount(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->amount(), std::string(separator));
    DEBUG_END()
}
const char* NERVA_UnsignedTransaction_fee(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->fee(), std::string(separator));
    DEBUG_END()
}
const char* NERVA_UnsignedTransaction_mixin(void* unsignedTx_ptr, const char* separator) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
const char* NERVA_UnsignedTransaction_confirmationMessage(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    std::string str = unsignedTx->confirmationMessage();
    return strdup(str.c_str());
    DEBUG_END()
}
const char* NERVA_UnsignedTransaction_paymentId(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->paymentId(), std::string(separator));
    DEBUG_END()
}
const char* NERVA_UnsignedTransaction_recipientAddress(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->recipientAddress(), std::string(separator));
    DEBUG_END()
}
uint64_t NERVA_UnsignedTransaction_minMixinCount(void* unsignedTx_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
uint64_t NERVA_UnsignedTransaction_txCount(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return unsignedTx->txCount();
    DEBUG_END()
}
bool NERVA_UnsignedTransaction_sign(void* unsignedTx_ptr, const char* signedFileName) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return unsignedTx->sign(std::string(signedFileName));
    DEBUG_END()
}
const char* NERVA_UnsignedTransaction_signUR(void* unsignedTx_ptr, int max_fragment_length) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

// TransactionInfo

const int NERVA_TransactionInfoDirection_In = 0;
const int NERVA_TransactionInfoDirection_Out = 1;
int NERVA_TransactionInfo_direction(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->direction();
    DEBUG_END()
}
bool NERVA_TransactionInfo_isPending(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isPending();
    DEBUG_END()
}
bool NERVA_TransactionInfo_isFailed(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isFailed();
    DEBUG_END()
}
bool NERVA_TransactionInfo_isCoinbase(void* txInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
uint64_t NERVA_TransactionInfo_amount(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->amount();
    DEBUG_END()
}
uint64_t NERVA_TransactionInfo_fee(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->fee();
    DEBUG_END()
}
uint64_t NERVA_TransactionInfo_blockHeight(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->blockHeight();
    DEBUG_END()
}
const char* NERVA_TransactionInfo_description(void* txInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
const char* NERVA_TransactionInfo_subaddrIndex(void* txInfo_ptr, const char* separator) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::set<uint32_t> subaddrIndex = txInfo->subaddrIndex();
    return vectorToString(subaddrIndex, std::string(separator));
    DEBUG_END()
}
uint32_t NERVA_TransactionInfo_subaddrAccount(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->subaddrAccount();
    DEBUG_END()
}
const char* NERVA_TransactionInfo_label(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->label();
    return strdup(str.c_str());
    DEBUG_END()
}
uint64_t NERVA_TransactionInfo_confirmations(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->confirmations();
    DEBUG_END()
}
uint64_t NERVA_TransactionInfo_unlockTime(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->unlockTime();
    DEBUG_END()
}
const char* NERVA_TransactionInfo_hash(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->hash();
    return strdup(str.c_str());
    DEBUG_END()
}
uint64_t NERVA_TransactionInfo_timestamp(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->timestamp();
    DEBUG_END()
}
const char* NERVA_TransactionInfo_paymentId(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->paymentId();
    return strdup(str.c_str());
    DEBUG_END()
}

int NERVA_TransactionInfo_transfers_count(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->transfers().size();
    DEBUG_END()
}

uint64_t NERVA_TransactionInfo_transfers_amount(void* txInfo_ptr, int index) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->transfers()[index].amount;
    DEBUG_END()
}

const char* NERVA_TransactionInfo_transfers_address(void* txInfo_ptr, int index) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->transfers()[index].address;
    return strdup(str.c_str());
    DEBUG_END()
}




// TransactionHistory
int NERVA_TransactionHistory_count(void* txHistory_ptr) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->count();
    DEBUG_END()
}
void* NERVA_TransactionHistory_transaction(void* txHistory_ptr, int index) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return reinterpret_cast<void*>(txHistory->transaction(index));
    DEBUG_END()
}
void* NERVA_TransactionHistory_transactionById(void* txHistory_ptr, const char* id) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return reinterpret_cast<void*>(txHistory->transaction(std::string(id)));
    DEBUG_END()
}

void NERVA_TransactionHistory_refresh(void* txHistory_ptr) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->refresh();
    DEBUG_END()
}
void NERVA_TransactionHistory_setTxNote(void* txHistory_ptr, const char* txid, const char* note) {
    // stubbed: not supported by Nerva's wallet2_api
}

// AddressBokRow

//     std::string extra;
const char* NERVA_AddressBookRow_extra(void* addressBookRow_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     std::string getAddress() const {return m_address;}
const char* NERVA_AddressBookRow_getAddress(void* addressBookRow_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     std::string getDescription() const {return m_description;}
const char* NERVA_AddressBookRow_getDescription(void* addressBookRow_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     std::string getPaymentId() const {return m_paymentId;}
const char* NERVA_AddressBookRow_getPaymentId(void* addressBookRow_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     std::size_t getRowId() const {return m_rowId;}
size_t NERVA_AddressBookRow_getRowId(void* addressBookRow_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}

// AddressBook

const int NERVA_AddressBookErrorCodeStatus_Ok = 0;
const int NERVA_AddressBookErrorCodeGeneral_Error = 1;
const int NERVA_AddressBookErrorCodeInvalid_Address = 2;
const int NERVA_AddressBookErrorCodeInvalidPaymentId = 3;

//     virtual std::vector<AddressBookRow*> getAll() const = 0;
int NERVA_AddressBook_getAll_size(void* addressBook_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
void* NERVA_AddressBook_getAll_byIndex(void* addressBook_ptr, int index) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}
//     virtual bool addRow(const std::string &dst_addr , const std::string &payment_id, const std::string &description) = 0;
bool NERVA_AddressBook_addRow(void* addressBook_ptr, const char* dst_addr , const char* payment_id, const char* description) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool deleteRow(std::size_t rowId) = 0;
bool NERVA_AddressBook_deleteRow(void* addressBook_ptr, size_t rowId) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool setDescription(std::size_t index, const std::string &description) = 0;
bool NERVA_AddressBook_setDescription(void* addressBook_ptr, size_t rowId, const char* description) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual void refresh() = 0;
void NERVA_AddressBook_refresh(void* addressBook_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual std::string errorString() const = 0;
const char* NERVA_AddressBook_errorString(void* addressBook_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     virtual int errorCode() const = 0;
int NERVA_AddressBook_errorCode(void* addressBook_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual int lookupPaymentID(const std::string &payment_id) const = 0;
int NERVA_AddressBook_lookupPaymentID(void* addressBook_ptr, const char* payment_id) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}

// CoinsInfo
uint64_t NERVA_CoinsInfo_blockHeight(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual std::string hash() const = 0;
const char* NERVA_CoinsInfo_hash(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     virtual size_t internalOutputIndex() const = 0;
size_t NERVA_CoinsInfo_internalOutputIndex(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual uint64_t globalOutputIndex() const = 0;
uint64_t NERVA_CoinsInfo_globalOutputIndex(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual bool spent() const = 0;
bool NERVA_CoinsInfo_spent(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool frozen() const = 0;
bool NERVA_CoinsInfo_frozen(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual uint64_t spentHeight() const = 0;
uint64_t NERVA_CoinsInfo_spentHeight(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual uint64_t amount() const = 0;
uint64_t NERVA_CoinsInfo_amount(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual bool rct() const = 0;
bool NERVA_CoinsInfo_rct(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool keyImageKnown() const = 0;
bool NERVA_CoinsInfo_keyImageKnown(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual size_t pkIndex() const = 0;
size_t NERVA_CoinsInfo_pkIndex(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual uint32_t subaddrIndex() const = 0;
uint32_t NERVA_CoinsInfo_subaddrIndex(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual uint32_t subaddrAccount() const = 0;
uint32_t NERVA_CoinsInfo_subaddrAccount(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual std::string address() const = 0;
const char* NERVA_CoinsInfo_address(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     virtual std::string addressLabel() const = 0;
const char* NERVA_CoinsInfo_addressLabel(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     virtual std::string keyImage() const = 0;
const char* NERVA_CoinsInfo_keyImage(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     virtual uint64_t unlockTime() const = 0;
uint64_t NERVA_CoinsInfo_unlockTime(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual bool unlocked() const = 0;
bool NERVA_CoinsInfo_unlocked(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual std::string pubKey() const = 0;
const char* NERVA_CoinsInfo_pubKey(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     virtual bool coinbase() const = 0;
bool NERVA_CoinsInfo_coinbase(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual std::string description() const = 0;
const char* NERVA_CoinsInfo_description(void* coinsInfo_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}


// coins

//     virtual ~Coins() = 0;
//     virtual int count() const = 0;
int NERVA_Coins_count(void* coins_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual CoinsInfo * coin(int index)  const = 0;
void* NERVA_Coins_coin(void* coins_ptr, int index) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}

int NERVA_Coins_getAll_size(void* coins_ptr)  {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
void* NERVA_Coins_getAll_byIndex(void* coins_ptr, int index) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}

//     virtual std::vector<CoinsInfo*> getAll() const = 0;
//     virtual void refresh() = 0;
void NERVA_Coins_refresh(void* coins_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual void setFrozen(std::string public_key) = 0;
void NERVA_Coins_setFrozenByPublicKey(void* coins_ptr, const char* public_key) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual void setFrozen(int index) = 0;
void NERVA_Coins_setFrozen(void* coins_ptr, int index) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual void thaw(int index) = 0;
void NERVA_Coins_thaw(void* coins_ptr, int index) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual void thaw(std::string public_key) = 0;
void NERVA_Coins_thawByPublicKey(void* coins_ptr, const char* public_key) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual bool isTransferUnlocked(uint64_t unlockTime, uint64_t blockHeight) = 0;
bool NERVA_Coins_isTransferUnlocked(void* coins_ptr, uint64_t unlockTime, uint64_t blockHeight) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//    virtual void setDescription(const std::string &public_key, const std::string &description) = 0;
void NERVA_Coins_setDescription(void* coins_ptr, const char* public_key, const char* description) {
    // stubbed: not supported by Nerva's wallet2_api
}

// SubaddressRow

//     std::string extra;
const char* NERVA_SubaddressRow_extra(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    std::string str = subaddressRow->extra;
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::string getAddress() const {return m_address;}
const char* NERVA_SubaddressRow_getAddress(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    std::string str = subaddressRow->getAddress();
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::string getLabel() const {return m_label;}
const char* NERVA_SubaddressRow_getLabel(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    std::string str = subaddressRow->getLabel();
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::size_t getRowId() const {return m_rowId;}
size_t NERVA_SubaddressRow_getRowId(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    return subaddressRow->getRowId();
    DEBUG_END()
}

// Subaddress

int NERVA_Subaddress_getAll_size(void* subaddress_ptr) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->getAll().size();
    DEBUG_END()
}
void* NERVA_Subaddress_getAll_byIndex(void* subaddress_ptr, int index) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->getAll()[index];
    DEBUG_END()
}
//     virtual void addRow(uint32_t accountIndex, const std::string &label) = 0;
void NERVA_Subaddress_addRow(void* subaddress_ptr, uint32_t accountIndex, const char* label) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->addRow(accountIndex, std::string(label));
    DEBUG_END()
}
//     virtual void setLabel(uint32_t accountIndex, uint32_t addressIndex, const std::string &label) = 0;
void NERVA_Subaddress_setLabel(void* subaddress_ptr, uint32_t accountIndex, uint32_t addressIndex, const char* label) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->setLabel(accountIndex, addressIndex, std::string(label));
    DEBUG_END()
}
//     virtual void refresh(uint32_t accountIndex) = 0;
void NERVA_Subaddress_refresh(void* subaddress_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->refresh(accountIndex);
    DEBUG_END()
}

// SubaddressAccountRow

//     std::string extra;
const char* NERVA_SubaddressAccountRow_extra(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->extra;
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::string getAddress() const {return m_address;}
const char* NERVA_SubaddressAccountRow_getAddress(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getAddress();
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::string getLabel() const {return m_label;}
const char* NERVA_SubaddressAccountRow_getLabel(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getLabel();
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::string getBalance() const {return m_balance;}
const char* NERVA_SubaddressAccountRow_getBalance(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getBalance();
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::string getUnlockedBalance() const {return m_unlockedBalance;}
const char* NERVA_SubaddressAccountRow_getUnlockedBalance(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getUnlockedBalance();
    return strdup(str.c_str());
    DEBUG_END()
}
//     std::size_t getRowId() const {return m_rowId;}
size_t NERVA_SubaddressAccountRow_getRowId(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    return subaddressAccountRow->getRowId();
    DEBUG_END()
}

// struct SubaddressAccount
// {
//     virtual ~SubaddressAccount() = 0;
//     virtual std::vector<SubaddressAccountRow*> getAll() const = 0;
int NERVA_SubaddressAccount_getAll_size(void* subaddressAccount_ptr) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->getAll().size();
    DEBUG_END()
}
void* NERVA_SubaddressAccount_getAll_byIndex(void* subaddressAccount_ptr, int index) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->getAll()[index];
    DEBUG_END()
}
//     virtual void addRow(const std::string &label) = 0;
void NERVA_SubaddressAccount_addRow(void* subaddressAccount_ptr, const char* label) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->addRow(std::string(label));
    DEBUG_END()
}
//     virtual void setLabel(uint32_t accountIndex, const std::string &label) = 0;
void NERVA_SubaddressAccount_setLabel(void* subaddressAccount_ptr, uint32_t accountIndex, const char* label) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->setLabel(accountIndex, std::string(label));
    DEBUG_END()
}
//     virtual void refresh() = 0;
void NERVA_SubaddressAccount_refresh(void* subaddressAccount_ptr) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->refresh();
    DEBUG_END()
}

// MultisigState

//     bool isMultisig;
bool NERVA_MultisigState_isMultisig(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->isMultisig;
    DEBUG_END()
}
//     bool isReady;
bool NERVA_MultisigState_isReady(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->isReady;
    DEBUG_END()
}
//     uint32_t threshold;
uint32_t NERVA_MultisigState_threshold(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->threshold;
    DEBUG_END()
}
//     uint32_t total;
uint32_t NERVA_MultisigState_total(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->total;
    DEBUG_END()
}

// DeviceProgress


//     virtual double progress() const { return m_progress; }
bool NERVA_DeviceProgress_progress(void* deviceProgress_ptr) {
    DEBUG_START()
    Monero::DeviceProgress *deviceProgress = reinterpret_cast<Monero::DeviceProgress*>(deviceProgress_ptr);
    return deviceProgress->progress();
    DEBUG_END()
}
//     virtual bool indeterminate() const { return m_indeterminate; }
bool NERVA_DeviceProgress_indeterminate(void* deviceProgress_ptr) {
    DEBUG_START()
    Monero::DeviceProgress *deviceProgress = reinterpret_cast<Monero::DeviceProgress*>(deviceProgress_ptr);
    return deviceProgress->indeterminate();
    DEBUG_END()
}

const int NERVA_WalletDevice_Software = 0;
const int NERVA_WalletDevice_Ledger = 1;
const int NERVA_WalletDevice_Trezor = 2;
const int NERVA_WalletStatus_Ok = 0;
const int NERVA_WalletStatus_Error = 1;
const int NERVA_WalletStatus_Critical = 2;
const int NERVA_WalletConnectionStatus_Disconnected = 0;
const int NERVA_WalletConnectionStatus_Connected = 1;
const int NERVA_WalletConnectionStatus_WrongVersion = 2;
const int NERVA_WalletBackgroundSync_Off = 0;
const int NERVA_WalletBackgroundSync_ReusePassword = 1;
const int NERVA_WalletBackgroundSync_CustomPassword = 2;

// Wallet

const char* NERVA_Wallet_seed(void* wallet_ptr, const char* seed_offset) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

const char* NERVA_Wallet_getSeedLanguage(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getSeedLanguage();
    return strdup(str.c_str());
    DEBUG_END()
}

void NERVA_Wallet_setSeedLanguage(void* wallet_ptr, const char* arg) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setSeedLanguage(std::string(arg));
    DEBUG_END()
}

int NERVA_Wallet_status(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->status();
    DEBUG_END()
}

const char* NERVA_Wallet_errorString(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->errorString();
    return strdup(str.c_str());
    DEBUG_END()
}


bool NERVA_Wallet_setPassword(void* wallet_ptr, const char* password) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setPassword(std::string(password));
    DEBUG_END()
}

const char* NERVA_Wallet_getPassword(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

bool NERVA_Wallet_setDevicePin(void* wallet_ptr, const char* pin) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setDevicePin(std::string(pin));
    DEBUG_END()
}

bool NERVA_Wallet_setDevicePassphrase(void* wallet_ptr, const char* passphrase) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setDevicePassphrase(std::string(passphrase));
    DEBUG_END()
}

const char* NERVA_Wallet_address(void* wallet_ptr, uint64_t accountIndex, uint64_t addressIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->address(accountIndex, addressIndex);
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_path(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->path();
    return strdup(str.c_str());
    DEBUG_END()
}
int NERVA_Wallet_nettype(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->nettype();
    DEBUG_END()
}
uint8_t NERVA_Wallet_useForkRules(void* wallet_ptr, uint8_t version, int64_t early_blocks) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->useForkRules(version, early_blocks);
    DEBUG_END()
}
const char* NERVA_Wallet_integratedAddress(void* wallet_ptr, const char* payment_id) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->integratedAddress(std::string(payment_id));
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_secretViewKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->secretViewKey();
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_publicViewKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->publicViewKey();
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_secretSpendKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->secretSpendKey();
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_publicSpendKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->publicSpendKey();
    return strdup(str.c_str());
    DEBUG_END()
}
const char* NERVA_Wallet_publicMultisigSignerKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->publicMultisigSignerKey();
    return strdup(str.c_str());
    DEBUG_END()
}

void NERVA_Wallet_stop(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
}

bool NERVA_Wallet_store(void* wallet_ptr, const char* path) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->store(std::string(path));
    DEBUG_END()
}
const char* NERVA_Wallet_filename(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->filename();
    return strdup(str.c_str());
    DEBUG_END()
}
const char* NERVA_Wallet_keysFilename(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->keysFilename();
    return strdup(str.c_str());
    DEBUG_END()
}

//     virtual bool init(const std::string &daemon_address, uint64_t upper_transaction_size_limit = 0, const std::string &daemon_username = "", const std::string &daemon_password = "", bool use_ssl = false, bool lightWallet = false, const std::string &proxy_address = "") = 0;
bool NERVA_Wallet_init(void* wallet_ptr, const char* daemon_address, uint64_t upper_transaction_size_limit, const char* daemon_username, const char* daemon_password, bool use_ssl, bool lightWallet, const char* proxy_address) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
bool NERVA_Wallet_createWatchOnly(void* wallet_ptr, const char* path, const char* password, const char* language) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->createWatchOnly(std::string(path), std::string(password), std::string(language));
    DEBUG_END()
}

void NERVA_Wallet_setRefreshFromBlockHeight(void* wallet_ptr, uint64_t refresh_from_block_height) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setRefreshFromBlockHeight(refresh_from_block_height);
    DEBUG_END()
}

uint64_t NERVA_Wallet_getRefreshFromBlockHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getRefreshFromBlockHeight();
    DEBUG_END()
}

void NERVA_Wallet_setRecoveringFromSeed(void* wallet_ptr, bool recoveringFromSeed) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setRecoveringFromSeed(recoveringFromSeed);
    DEBUG_END()
}
void NERVA_Wallet_setRecoveringFromDevice(void* wallet_ptr, bool recoveringFromDevice) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setRecoveringFromDevice(recoveringFromDevice);
    DEBUG_END()
}
void NERVA_Wallet_setSubaddressLookahead(void* wallet_ptr, uint32_t major, uint32_t minor) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setSubaddressLookahead(major, minor);
    DEBUG_END()
}

bool NERVA_Wallet_connectToDaemon(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->connectToDaemon();
    DEBUG_END()
}
int NERVA_Wallet_connected(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->connected();
    DEBUG_END()
}
void NERVA_Wallet_setTrustedDaemon(void* wallet_ptr, bool arg) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setTrustedDaemon(arg);
    DEBUG_END()
}
bool NERVA_Wallet_trustedDaemon(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->trustedDaemon();
    DEBUG_END()
}
bool NERVA_Wallet_setProxy(void* wallet_ptr, const char* address) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

const int NERVA_LogLevel_Silent = -1;
const int NERVA_LogLevel_0 = 0;
const int NERVA_LogLevel_1 = 1;
const int NERVA_LogLevel_2 = 2;
const int NERVA_LogLevel_3 = 3;
const int NERVA_LogLevel_4 = 4;
const int NERVA_LogLevel_Min = NERVA_LogLevel_Silent;
const int NERVA_LogLevel_Max = NERVA_LogLevel_4;

uint64_t NERVA_Wallet_balance(void* wallet_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->balance(accountIndex);
    DEBUG_END()
}

uint64_t NERVA_Wallet_unlockedBalance(void* wallet_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->unlockedBalance(accountIndex);
    DEBUG_END()
}

uint64_t NERVA_Wallet_viewOnlyBalance(void* wallet_ptr, uint32_t accountIndex) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}

// TODO
bool NERVA_Wallet_watchOnly(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->watchOnly();
    DEBUG_END()
}
bool NERVA_Wallet_isDeterministic(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
uint64_t NERVA_Wallet_blockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->blockChainHeight();
    DEBUG_END()
}
uint64_t NERVA_Wallet_approximateBlockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->approximateBlockChainHeight();
    DEBUG_END()
}
uint64_t NERVA_Wallet_estimateBlockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->estimateBlockChainHeight();
    DEBUG_END()
}
uint64_t NERVA_Wallet_daemonBlockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->daemonBlockChainHeight();
    DEBUG_END()
}

uint64_t NERVA_Wallet_daemonBlockChainTargetHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->daemonBlockChainTargetHeight();
    DEBUG_END()
}
bool NERVA_Wallet_synchronized(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->synchronized();
    DEBUG_END()
}

const char* NERVA_Wallet_displayAmount(uint64_t amount) {
    DEBUG_START()
    std::string str = Monero::Wallet::displayAmount(amount);
    return strdup(str.c_str());
    DEBUG_END()
}

//     static uint64_t amountFromString(const std::string &amount);
uint64_t NERVA_Wallet_amountFromString(const char* amount) {
    DEBUG_START()
    return Monero::Wallet::amountFromString(amount);
    DEBUG_END()
}
//     static uint64_t amountFromDouble(double amount);
uint64_t NERVA_Wallet_amountFromDouble(double amount) {
    DEBUG_START()
    return Monero::Wallet::amountFromDouble(amount);
    DEBUG_END()
}
//     static std::string genPaymentId();
const char* NERVA_Wallet_genPaymentId() {
    DEBUG_START()
    std::string str = Monero::Wallet::genPaymentId();
    return strdup(str.c_str());
    DEBUG_END()
}
//     static bool paymentIdValid(const std::string &paiment_id);
bool NERVA_Wallet_paymentIdValid(const char* paiment_id) {
    DEBUG_START()
    return Monero::Wallet::paymentIdValid(std::string(paiment_id));
    DEBUG_END()
}
bool NERVA_Wallet_addressValid(const char* str, int nettype) {
    DEBUG_START()
    // Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return Monero::Wallet::addressValid(std::string(str), nettype);
    DEBUG_END()
}

bool NERVA_Wallet_keyValid(const char* secret_key_string, const char* address_string, bool isViewKey, int nettype) {
    DEBUG_START()
    std::string error;
    return Monero::Wallet::keyValid(std::string(secret_key_string), std::string(address_string), isViewKey, nettype, error);
    DEBUG_END()
}
const char* NERVA_Wallet_keyValid_error(const char* secret_key_string, const char* address_string, bool isViewKey, int nettype)  {
    DEBUG_START()
    std::string str;
    Monero::Wallet::keyValid(std::string(secret_key_string), std::string(address_string), isViewKey, nettype, str);
    return strdup(str.c_str());
    DEBUG_END()

}
const char* NERVA_Wallet_paymentIdFromAddress(const char* strarg, int nettype) {
    DEBUG_START()
    std::string str = Monero::Wallet::paymentIdFromAddress(std::string(strarg), nettype);
    return strdup(str.c_str());
    DEBUG_END()
}
uint64_t NERVA_Wallet_maximumAllowedAmount() {
    DEBUG_START()
    return Monero::Wallet::maximumAllowedAmount();
    DEBUG_END()
}

void NERVA_Wallet_init3(void* wallet_ptr, const char* argv0, const char* default_log_base_name, const char* log_path, bool console) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->init(argv0, default_log_base_name, log_path, console);
    DEBUG_END()
}
const char* NERVA_Wallet_getPolyseed(void* wallet_ptr, const char* passphrase) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
//     static bool createPolyseed(std::string &seed_words, std::string &err, const std::string &language = "English");
const char* NERVA_Wallet_createPolyseed(const char* language) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

void NERVA_Wallet_startRefresh(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->startRefresh();
    DEBUG_END()
}
void NERVA_Wallet_pauseRefresh(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->pauseRefresh();
    DEBUG_END()
}
bool NERVA_Wallet_refresh(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->refresh();
    DEBUG_END()
}
void NERVA_Wallet_refreshAsync(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->refreshAsync();
    DEBUG_END()
}
bool NERVA_Wallet_rescanBlockchain(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanBlockchain();
    DEBUG_END()
}
void NERVA_Wallet_rescanBlockchainAsync(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanBlockchainAsync();
    DEBUG_END()
}
void NERVA_Wallet_setAutoRefreshInterval(void* wallet_ptr, int millis) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setAutoRefreshInterval(millis);
    DEBUG_END()
}
int NERVA_Wallet_autoRefreshInterval(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->autoRefreshInterval();
    DEBUG_END()
}
void NERVA_Wallet_addSubaddressAccount(void* wallet_ptr, const char* label) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->addSubaddressAccount(std::string(label));
    DEBUG_END()
}
size_t NERVA_Wallet_numSubaddressAccounts(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->numSubaddressAccounts();
    DEBUG_END()
}
size_t NERVA_Wallet_numSubaddresses(void* wallet_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->numSubaddresses(accountIndex);
    DEBUG_END()
}
void NERVA_Wallet_addSubaddress(void* wallet_ptr, uint32_t accountIndex, const char* label) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->addSubaddress(accountIndex, std::string(label));
    DEBUG_END()
}
const char* NERVA_Wallet_getSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getSubaddressLabel(accountIndex, addressIndex);
    return strdup(str.c_str());
    DEBUG_END()
}

void NERVA_Wallet_setSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex, const char* label) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setSubaddressLabel(accountIndex, addressIndex, std::string(label));
    DEBUG_END()
}

void* NERVA_Wallet_multisig(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    Monero::MultisigState *mstate_ptr = new Monero::MultisigState(wallet->multisig());
    return reinterpret_cast<void*>(mstate_ptr);
    DEBUG_END()
}

const char* NERVA_Wallet_getMultisigInfo(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getMultisigInfo();
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_makeMultisig(void* wallet_ptr, const char* info, const char* info_separator, uint32_t threshold) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->makeMultisig(splitStringVector(std::string(info), std::string(info_separator)), threshold);
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_exchangeMultisigKeys(void* wallet_ptr, const char* info, const char* info_separator, bool force_update_use_with_caution) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

const char* NERVA_Wallet_exportMultisigImages(void* wallet_ptr, const char* separator) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str;
    wallet->exportMultisigImages(str);
    return strdup(str.c_str());
    DEBUG_END()
}

size_t NERVA_Wallet_importMultisigImages(void* wallet_ptr, const char* info, const char* info_separator) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->importMultisigImages(splitStringVector(std::string(info), std::string(info_separator)));
    DEBUG_END()
}

size_t NERVA_Wallet_hasMultisigPartialKeyImages(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->hasMultisigPartialKeyImages();
    DEBUG_END()
}

void* NERVA_Wallet_restoreMultisigTransaction(void* wallet_ptr, const char* signData) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return reinterpret_cast<void*>(wallet->restoreMultisigTransaction(std::string(signData)));
    DEBUG_END()
}


Monero::PendingTransaction::Priority PendingTransaction_Priority_fromInt(int value) {
    switch(value) {
        case 0: return Monero::PendingTransaction::Priority::Priority_Default;
        case 1: return Monero::PendingTransaction::Priority::Priority_Low;
        case 2: return Monero::PendingTransaction::Priority::Priority_Medium;
        case 3: return Monero::PendingTransaction::Priority::Priority_High;
        default: return Monero::PendingTransaction::Priority::Priority_Default;
    }
}

void* NERVA_Wallet_createTransactionMultDest(void* wallet_ptr, const char* dst_addr_list, const char* dst_addr_list_separator, const char* payment_id,
                                                bool amount_sweep_all, const char* amount_list, const char* amount_list_separator, uint32_t mixin_count,
                                                int pendingTransactionPriority,
                                                uint32_t subaddr_account,
                                                const char* preferredInputs, const char* preferredInputs_separator) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::vector<std::string> dst_addr = splitStringVector(std::string(dst_addr_list), std::string(dst_addr_list_separator));

    Monero::optional<std::vector<uint64_t>> optAmount;
    if (!amount_sweep_all) {
        optAmount = splitStringUint(std::string(amount_list), std::string(amount_list_separator));;
    }
    std::set<uint32_t> subaddr_indices = {};
    // Nerva's createTransactionMultDest takes no mixin_count/preferred_inputs.
    (void)mixin_count; (void)preferredInputs; (void)preferredInputs_separator;

    return wallet->createTransactionMultDest(
        dst_addr, std::string(payment_id),
        optAmount,
        PendingTransaction_Priority_fromInt(pendingTransactionPriority),
        subaddr_account,
        subaddr_indices
    );
    DEBUG_END()
}

void* NERVA_Wallet_createTransaction(void* wallet_ptr, const char* dst_addr, const char* payment_id,
                                                    uint64_t amount, uint32_t mixin_count,
                                                    int pendingTransactionPriority,
                                                    uint32_t subaddr_account,
                                                    const char* preferredInputs, const char* separator) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    Monero::optional<uint64_t> optAmount;
    if (amount != 0) {
        optAmount = amount;
    }
    std::set<uint32_t> subaddr_indices = {};
    // Nerva's createTransaction takes no mixin_count/preferred_inputs.
    (void)mixin_count; (void)preferredInputs; (void)separator;
    return wallet->createTransaction(std::string(dst_addr), std::string(payment_id),
                                        optAmount,
                                        PendingTransaction_Priority_fromInt(pendingTransactionPriority),
                                        subaddr_account, subaddr_indices);
    DEBUG_END()
}

void* NERVA_Wallet_loadUnsignedTx(void* wallet_ptr, const char* fileName) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->loadUnsignedTx(std::string(fileName));
    DEBUG_END()
}

void* NERVA_Wallet_loadUnsignedTxUR(void* wallet_ptr, const char* input) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}
bool NERVA_Wallet_submitTransaction(void* wallet_ptr, const char* fileName) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->submitTransaction(std::string(fileName));
    DEBUG_END()
}
bool NERVA_Wallet_submitTransactionUR(void* wallet_ptr, const char* input) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
bool NERVA_Wallet_submitTransactionHex(void* wallet_ptr, const char* hex) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
bool NERVA_Wallet_hasUnknownKeyImages(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
bool NERVA_Wallet_exportKeyImages(void* wallet_ptr, const char* filename, bool all) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

const char* NERVA_Wallet_exportKeyImagesUR(void* wallet_ptr, size_t max_fragment_length, bool all) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
bool NERVA_Wallet_importKeyImages(void* wallet_ptr, const char* filename) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->importKeyImages(std::string(filename));
    DEBUG_END()
}
bool NERVA_Wallet_importKeyImagesUR(void* wallet_ptr, const char* input) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
bool NERVA_Wallet_exportOutputs(void* wallet_ptr, const char* filename, bool all) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
const char* NERVA_Wallet_exportOutputsUR(void* wallet_ptr, size_t max_fragment_length, bool all) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}
bool NERVA_Wallet_importOutputs(void* wallet_ptr, const char* filename) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
bool NERVA_Wallet_importOutputsUR(void* wallet_ptr, const char* input) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool setupBackgroundSync(const BackgroundSyncType background_sync_type, const std::string &wallet_password, const optional<std::string> &background_cache_password) = 0;
bool NERVA_Wallet_setupBackgroundSync(void* wallet_ptr, int background_sync_type, const char* wallet_password, const char* background_cache_password) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual BackgroundSyncType getBackgroundSyncType() const = 0;
int NERVA_Wallet_getBackgroundSyncType(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual bool startBackgroundSync() = 0;
bool NERVA_Wallet_startBackgroundSync(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool stopBackgroundSync(const std::string &wallet_password) = 0;
bool NERVA_Wallet_stopBackgroundSync(void* wallet_ptr, const char* wallet_password) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool isBackgroundSyncing() const = 0;
bool NERVA_Wallet_isBackgroundSyncing(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
//     virtual bool isBackgroundWallet() const = 0;
bool NERVA_Wallet_isBackgroundWallet(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}
void* NERVA_Wallet_history(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->history();
    DEBUG_END()
}
void* NERVA_Wallet_addressBook(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}
//     virtual Coins * coins() = 0;
void* NERVA_Wallet_coins(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}
//     virtual Subaddress * subaddress() = 0;
void* NERVA_Wallet_subaddress(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->subaddress();
    DEBUG_END()
}
//     virtual SubaddressAccount * subaddressAccount() = 0;
void* NERVA_Wallet_subaddressAccount(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->subaddressAccount();
    DEBUG_END()
}
//     virtual uint32_t defaultMixin() const = 0;
uint32_t NERVA_Wallet_defaultMixin(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
//     virtual void setDefaultMixin(uint32_t arg) = 0;
void NERVA_Wallet_setDefaultMixin(void* wallet_ptr, uint32_t arg) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual bool setCacheAttribute(const std::string &key, const std::string &val) = 0;
bool NERVA_Wallet_setCacheAttribute(void* wallet_ptr, const char* key, const char* val) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setCacheAttribute(std::string(key), std::string(val));
    DEBUG_END()
}
//     virtual std::string getCacheAttribute(const std::string &key) const = 0;
const char* NERVA_Wallet_getCacheAttribute(void* wallet_ptr, const char* key) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getCacheAttribute(std::string(key));
    return strdup(str.c_str());
    DEBUG_END()
}
//     virtual bool setUserNote(const std::string &txid, const std::string &note) = 0;
bool NERVA_Wallet_setUserNote(void* wallet_ptr, const char* txid, const char* note) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setUserNote(std::string(txid), std::string(note));
    DEBUG_END()
}
//     virtual std::string getUserNote(const std::string &txid) const = 0;
const char* NERVA_Wallet_getUserNote(void* wallet_ptr, const char* txid) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getUserNote(std::string(txid));
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_getTxKey(void* wallet_ptr, const char* txid) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getTxKey(std::string(txid));
    return strdup(str.c_str());
    DEBUG_END()
}

const char* NERVA_Wallet_signMessage(void* wallet_ptr, const char* message, const char* address) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

bool NERVA_Wallet_verifySignedMessage(void* wallet_ptr, const char* message, const char* address, const char* signature) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    bool v = wallet->verifySignedMessage(std::string(message), std::string(address), std::string(signature));
    return v;
    DEBUG_END()
}

bool NERVA_Wallet_rescanSpent(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanSpent();
    DEBUG_END()
}

void NERVA_Wallet_setOffline(void* wallet_ptr, bool offline) {
    // stubbed: not supported by Nerva's wallet2_api
}
//     virtual bool isOffline() const = 0;
bool NERVA_Wallet_isOffline(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

void NERVA_Wallet_segregatePreForkOutputs(void* wallet_ptr, bool segregate) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->segregatePreForkOutputs(segregate);
    DEBUG_END()
}
//     virtual void segregationHeight(uint64_t height) = 0;
void NERVA_Wallet_segregationHeight(void* wallet_ptr, uint64_t height) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->segregationHeight(height);
    DEBUG_END()
}
//     virtual void keyReuseMitigation2(bool mitigation) = 0;
void NERVA_Wallet_keyReuseMitigation2(void* wallet_ptr, bool mitigation) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->keyReuseMitigation2(mitigation);
    DEBUG_END()
}
//     virtual bool lightWalletLogin(bool &isNewWallet) const = 0;
//     virtual bool lightWalletImportWalletRequest(std::string &payment_id, uint64_t &fee, bool &new_request, bool &request_fulfilled, std::string &payment_address, std::string &status) = 0;
//     virtual bool lockKeysFile() = 0;
bool NERVA_Wallet_lockKeysFile(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->lockKeysFile();
    DEBUG_END()
}
//     virtual bool unlockKeysFile() = 0;
bool NERVA_Wallet_unlockKeysFile(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->unlockKeysFile();
    DEBUG_END()
}
//     virtual bool isKeysFileLocked() = 0;
bool NERVA_Wallet_isKeysFileLocked(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->isKeysFileLocked();
    DEBUG_END()
}
//     virtual Device getDeviceType() const = 0;
int NERVA_Wallet_getDeviceType(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getDeviceType();
    DEBUG_END()
}
//     virtual uint64_t coldKeyImageSync(uint64_t &spent, uint64_t &unspent) = 0;
uint64_t NERVA_Wallet_coldKeyImageSync(void* wallet_ptr, uint64_t spent, uint64_t unspent) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->coldKeyImageSync(spent, unspent);
    DEBUG_END()
}
//     virtual void deviceShowAddress(uint32_t accountIndex, uint32_t addressIndex, const std::string &paymentId) = 0;
const char* NERVA_Wallet_deviceShowAddress(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = "";
    wallet->deviceShowAddress(accountIndex, addressIndex, str);
    return strdup(str.c_str());
    DEBUG_END()
}
//     virtual bool reconnectDevice() = 0;
bool NERVA_Wallet_reconnectDevice(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

uint64_t NERVA_Wallet_getBytesReceived(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}
uint64_t NERVA_Wallet_getBytesSent(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}

bool NERVA_Wallet_getStateIsConnected() {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

unsigned char* NERVA_Wallet_getSendToDevice() {
    // stubbed: not supported by Nerva's wallet2_api
    return reinterpret_cast<unsigned char*>(strdup(""));
}

size_t NERVA_Wallet_getSendToDeviceLength() {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}

unsigned char* NERVA_Wallet_getReceivedFromDevice() {
    // stubbed: not supported by Nerva's wallet2_api
    return reinterpret_cast<unsigned char*>(strdup(""));
}

size_t NERVA_Wallet_getReceivedFromDeviceLength() {
    // stubbed: not supported by Nerva's wallet2_api
    return 0;
}

bool NERVA_Wallet_getWaitsForDeviceSend() {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

bool NERVA_Wallet_getWaitsForDeviceReceive() {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

void NERVA_Wallet_setDeviceReceivedData(unsigned char* data, size_t len) {
    // stubbed: not supported by Nerva's wallet2_api
}

void NERVA_Wallet_setDeviceSendData(unsigned char* data, size_t len) {
    // stubbed: not supported by Nerva's wallet2_api
}

void NERVA_Wallet_setLedgerCallback(void (*sendToLedgerDevice)(unsigned char *command, unsigned int cmd_len)) {
    // stubbed: not supported by Nerva's wallet2_api
}

const char* NERVA_Wallet_serializeCacheToJson(void* wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

const char* NERVA_Wallet_exportTrezorTdis(void *wallet_ptr) {
    // stubbed: not supported by Nerva's wallet2_api
    return strdup("");
}

bool NERVA_Wallet_importTrezorEncryptedKeyImagesJson(void *wallet_ptr, const char* json) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}

void* NERVA_WalletManager_createWallet(void* wm_ptr, const char* path, const char* password, const char* language, int networkType) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = wm->createWallet(
                    std::string(path),
                    std::string(password),
                    std::string(language),
                    static_cast<Monero::NetworkType>(networkType));
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}

void* NERVA_WalletManager_openWallet(void* wm_ptr, const char* path, const char* password, int networkType) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = wm->openWallet(
                    std::string(path),
                    std::string(password),
                    static_cast<Monero::NetworkType>(networkType));
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}
void* NERVA_WalletManager_recoveryWallet(void* wm_ptr, const char* path, const char* password, const char* mnemonic, int networkType, uint64_t restoreHeight, uint64_t kdfRounds, const char* seedOffset) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    // (const std::string &path, const std::string &password, const std::string &mnemonic,
    //                                     NetworkType nettype = MAINNET, uint64_t restoreHeight = 0, uint64_t kdf_rounds = 1,
    //                                     const std::string &seed_offset = {})
    Monero::Wallet *wallet = wm->recoveryWallet(
                    std::string(path),
                    std::string(password),
                    std::string(mnemonic),
                    static_cast<Monero::NetworkType>(networkType),
                    restoreHeight,
                    kdfRounds,
                    std::string(seedOffset));
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}
//     virtual Wallet * createWalletFromKeys(const std::string &path,
//                                                     const std::string &password,
//                                                     const std::string &language,
//                                                     NetworkType nettype,
//                                                     uint64_t restoreHeight,
//                                                     const std::string &addressString,
//                                                     const std::string &viewKeyString,
//                                                     const std::string &spendKeyString = "",
//                                                     uint64_t kdf_rounds = 1) = 0;
void* NERVA_WalletManager_createWalletFromKeys(void* wm_ptr, const char* path, const char* password, const char* language, int nettype, uint64_t restoreHeight, const char* addressString, const char* viewKeyString, const char* spendKeyString, uint64_t kdf_rounds) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = wm->createWalletFromKeys(
                    std::string(path),
                    std::string(password),
                    std::string(language),
                    static_cast<Monero::NetworkType>(nettype),
                    restoreHeight,
                    std::string(addressString),
                    std::string(viewKeyString),
                    std::string(spendKeyString));
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}

void* NERVA_WalletManager_createWalletFromDevice(void* wm_ptr, const char* path, const char* password, int nettype, const char* deviceName, uint64_t restoreHeight, const char* subaddressLookahead, const char* viewKeyString, const char* spendKeyString, uint64_t kdf_rounds) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = wm->createWalletFromDevice(std::string(path),
        std::string(password),
        static_cast<Monero::NetworkType>(nettype),
        std::string(deviceName),
        restoreHeight,
        std::string(subaddressLookahead),
        kdf_rounds);
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}

void* NERVA_WalletManager_createDeterministicWalletFromSpendKey(void* wm_ptr, const char* path, const char* password,
                                                const char* language, int nettype, uint64_t restoreHeight,
                                                const char* spendKeyString, uint64_t kdf_rounds) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}

void* NERVA_WalletManager_createWalletFromPolyseed(void* wm_ptr, const char* path, const char* password,
                                                int nettype, const char* mnemonic, const char* passphrase,
                                                bool newWallet, uint64_t restore_height, uint64_t kdf_rounds) {
    // stubbed: not supported by Nerva's wallet2_api
    return nullptr;
}


bool NERVA_WalletManager_closeWallet(void* wm_ptr, void* wallet_ptr, bool store) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wm->closeWallet(wallet, store);
    DEBUG_END()
}

bool NERVA_WalletManager_walletExists(void* wm_ptr, const char* path) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->walletExists(std::string(path));
    DEBUG_END()
}

//     virtual bool verifyWalletPassword(const std::string &keys_file_name, const std::string &password, bool no_spend_key, uint64_t kdf_rounds = 1) const = 0;
bool NERVA_WalletManager_verifyWalletPassword(void* wm_ptr, const char* keys_file_name, const char* password, bool no_spend_key, uint64_t kdf_rounds) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->verifyWalletPassword(std::string(keys_file_name), std::string(password), no_spend_key, kdf_rounds);
    DEBUG_END()
}

//     virtual bool queryWalletDevice(Wallet::Device& device_type, const std::string &keys_file_name, const std::string &password, uint64_t kdf_rounds = 1) const = 0;
int NERVA_WalletManager_queryWalletDevice(void* wm_ptr, const char* keys_file_name, const char* password, uint64_t kdf_rounds) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet::Device device_type;
    wm->queryWalletDevice(device_type, std::string(keys_file_name), std::string(password), kdf_rounds);
    return device_type;
    DEBUG_END()
}

//     virtual std::vector<std::string> findWallets(const std::string &path) = 0;
const char* NERVA_WalletManager_findWallets(void* wm_ptr, const char* path, const char* separator) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return vectorToString(wm->findWallets(std::string(path)), std::string(separator));
    DEBUG_END()
}


const char* NERVA_WalletManager_errorString(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    std::string str = wm->errorString();
    return strdup(str.c_str());
    DEBUG_END()
}

void NERVA_WalletManager_setDaemonAddress(void* wm_ptr, const char* address) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->setDaemonAddress(std::string(address));
    DEBUG_END()
}

bool NERVA_WalletManager_setProxy(void* wm_ptr, const char* address) {
    // stubbed: not supported by Nerva's wallet2_api
    return false;
}


//     virtual bool connected(uint32_t *version = NULL) = 0;
//     virtual uint64_t blockchainHeight() = 0;
uint64_t NERVA_WalletManager_blockchainHeight(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->blockchainHeight();
    DEBUG_END()
}
//     virtual uint64_t blockchainTargetHeight() = 0;
uint64_t NERVA_WalletManager_blockchainTargetHeight(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->blockchainTargetHeight();
    DEBUG_END()
}
//     virtual uint64_t networkDifficulty() = 0;
uint64_t NERVA_WalletManager_networkDifficulty(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->networkDifficulty();
    DEBUG_END()
}
//     virtual double miningHashRate() = 0;
double NERVA_WalletManager_miningHashRate(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->miningHashRate();
    DEBUG_END()
}
//     virtual uint64_t blockTarget() = 0;
uint64_t NERVA_WalletManager_blockTarget(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->blockTarget();
    DEBUG_END()
}
//     virtual bool isMining() = 0;
bool NERVA_WalletManager_isMining(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->isMining();
    DEBUG_END()
}
//     virtual bool startMining(const std::string &address, uint32_t threads = 1, bool background_mining = false, bool ignore_battery = true) = 0;
bool NERVA_WalletManager_startMining(void* wm_ptr, const char* address, uint32_t threads, bool backgroundMining, bool ignoreBattery) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->startMining(std::string(address), threads, backgroundMining, ignoreBattery);
    DEBUG_END()
}
//     virtual bool stopMining() = 0;
bool NERVA_WalletManager_stopMining(void* wm_ptr, const char* address) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->stopMining();
    DEBUG_END()
}
//     virtual std::string resolveOpenAlias(const std::string &address, bool &dnssec_valid) const = 0;
const char* NERVA_WalletManager_resolveOpenAlias(void* wm_ptr, const char* address, bool dnssec_valid) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    std::string str = wm->resolveOpenAlias(std::string(address), dnssec_valid);
    return strdup(str.c_str());
    DEBUG_END()
}

// WalletManagerFactory

void* NERVA_WalletManagerFactory_getWalletManager() {
    DEBUG_START()
    Monero::WalletManager *wm = Monero::WalletManagerFactory::getWalletManager();
    return reinterpret_cast<void*>(wm);
    DEBUG_END()
}

void NERVA_WalletManagerFactory_setLogLevel(int level) {
    DEBUG_START()
    return Monero::WalletManagerFactory::setLogLevel(level);
    DEBUG_END()
}

void NERVA_WalletManagerFactory_setLogCategories(const char* categories) {
    DEBUG_START()
    return Monero::WalletManagerFactory::setLogCategories(std::string(categories));
    DEBUG_END()
}

// DEBUG functions

// As it turns out we need a bit more functions to make sure that the library is working.
// 0) void
// 1) bool
// 2) int
// 3) uint64_t
// 4) void*
// 5) const char*

void NERVA_DEBUG_test0() {
    return;
}

bool NERVA_DEBUG_test1(bool x) {
    return x;
}

int NERVA_DEBUG_test2(int x) {
    return x;
}

uint64_t NERVA_DEBUG_test3(uint64_t x) {
    return x;
}

void* NERVA_DEBUG_test4(uint64_t x) {
    int *y = new int(x);
    return reinterpret_cast<void*>(y);
}

const char* NERVA_DEBUG_test5() {
    const char *text = "This is a const char* text";
    return text;
}

const char* NERVA_DEBUG_test5_std() {
    std::string text("This is a std::string text");
    const char *text2 = "This is a text";
    return text2;
}

bool NERVA_DEBUG_isPointerNull(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return (wallet != NULL);
    DEBUG_END()
}

// cake wallet world
// TODO(mrcyjanek): https://api.dart.dev/stable/3.3.3/dart-ffi/Pointer/fromFunction.html
//                  callback to dart should be possible..? I mean why not? But I need to
//                  wait for other implementation (Go preferably) to see if this approach
//                  will work as expected.
struct NERVA_cw_WalletListener;
struct NERVA_cw_WalletListener : Monero::WalletListener
{
    uint64_t m_height;
    bool m_need_to_refresh;
    bool m_new_transaction;

    NERVA_cw_WalletListener()
    {
        m_height = 0;
        m_need_to_refresh = false;
        m_new_transaction = false;
    }

    void moneySpent(const std::string &txId, uint64_t amount)
    {
        m_new_transaction = true;
    }

    void moneyReceived(const std::string &txId, uint64_t amount)
    {
        m_new_transaction = true;
    }

    void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
    {
        m_new_transaction = true;
    }

    void newBlock(uint64_t height)
    {
        m_height = height;
    }

    void updated()
    {
        m_new_transaction = true;
    }

    void refreshed()
    {
        m_need_to_refresh = true;
    }


    void cw_resetNeedToRefresh()
    {
        m_need_to_refresh = false;
    }

    bool cw_isNeedToRefresh()
    {
        return m_need_to_refresh;
    }

    bool cw_isNewTransactionExist()
    {
        return m_new_transaction;
    }

    void cw_resetIsNewTransactionExist()
    {
        m_new_transaction = false;
    }

    uint64_t cw_height()
    {
        return m_height;
    }
};

void* NERVA_cw_getWalletListener(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    NERVA_cw_WalletListener *listener = new NERVA_cw_WalletListener();
    wallet->setListener(listener);
    return reinterpret_cast<void*>(listener);
    DEBUG_END()
}

void NERVA_cw_WalletListener_resetNeedToRefresh(void* cw_walletListener_ptr) {
    DEBUG_START()
    NERVA_cw_WalletListener *listener = reinterpret_cast<NERVA_cw_WalletListener*>(cw_walletListener_ptr);
    listener->cw_resetNeedToRefresh();
    DEBUG_END()
}

bool NERVA_cw_WalletListener_isNeedToRefresh(void* cw_walletListener_ptr) {
    DEBUG_START()
    NERVA_cw_WalletListener *listener = reinterpret_cast<NERVA_cw_WalletListener*>(cw_walletListener_ptr);
    return listener->cw_isNeedToRefresh();
    DEBUG_END()
};

bool NERVA_cw_WalletListener_isNewTransactionExist(void* cw_walletListener_ptr) {
    DEBUG_START()
    NERVA_cw_WalletListener *listener = reinterpret_cast<NERVA_cw_WalletListener*>(cw_walletListener_ptr);
    return listener->cw_isNewTransactionExist();
    DEBUG_END()
};

void NERVA_cw_WalletListener_resetIsNewTransactionExist(void* cw_walletListener_ptr) {
    DEBUG_START()
    NERVA_cw_WalletListener *listener = reinterpret_cast<NERVA_cw_WalletListener*>(cw_walletListener_ptr);
    listener->cw_resetIsNewTransactionExist();
    DEBUG_END()
};

uint64_t NERVA_cw_WalletListener_height(void* cw_walletListener_ptr) {
    DEBUG_START()
    NERVA_cw_WalletListener *listener = reinterpret_cast<NERVA_cw_WalletListener*>(cw_walletListener_ptr);
    return listener->cw_height();
    DEBUG_END()
};

const char* NERVA_checksum_wallet2_api_c_h() {
    return NERVA_wallet2_api_c_h_sha256;
}
const char* NERVA_checksum_wallet2_api_c_cpp() {
    return NERVA_wallet2_api_c_cpp_sha256;
}
const char* NERVA_checksum_wallet2_api_c_exp() {
    return NERVA_wallet2_api_c_exp_sha256;
}
// i hate windows

void NERVA_free(void* ptr) {
    free(ptr);
}

#ifdef __cplusplus
}
#endif
