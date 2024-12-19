#include <inttypes.h>
#include "wallet2_api_c.h"
#include <unistd.h>
#include "helpers.hpp"
#include <cstring>
#include <thread>
#include "../../../../wownero/src/wallet/api/wallet2_api.h"
#include "../../../wownero-seed/include/wownero_seed/wownero_seed.hpp"
#include "wownero_checksum.h"

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
// void* WOWNERO_Wallet_createTransaction(void* wallet_ptr, const char* dst_addr, const char* payment_id,     / like std::set I've used splitString functions and introduced a new
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
// const char* WOWNERO_PendingTransaction_errorString(void* pendingTx_ptr) {
//     Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
//     std::string str = pendingTx->errorString(); <------------- get the actual string from the upstream codebase
//     const std::string::size_type size = str.size(); ------------------------------\
//     char *buffer = new char[size + 1];   //we need extra char for NUL             | Copy the string onto a new memory so it won't get freed after the function returns
//     memcpy(buffer, str.c_str(), size + 1);                                        | NOTE: This requires us to call free() after we are done with the text processing
//     return buffer; ______________________________________________________________/
// }
//
//

// PendingTransaction

int WOWNERO_PendingTransaction_status(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->status();
    DEBUG_END()
}
const char* WOWNERO_PendingTransaction_errorString(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::string str = pendingTx->errorString();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
bool WOWNERO_PendingTransaction_commit(void* pendingTx_ptr, const char* filename, bool overwrite) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->commit(std::string(filename), overwrite);
    DEBUG_END()
}
uint64_t WOWNERO_PendingTransaction_amount(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->amount();
    DEBUG_END()
}
uint64_t WOWNERO_PendingTransaction_dust(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->dust();
    DEBUG_END()
}
uint64_t WOWNERO_PendingTransaction_fee(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->fee();
    DEBUG_END()
}
const char* WOWNERO_PendingTransaction_txid(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::string> txid = pendingTx->txid();
    return vectorToString(txid, std::string(separator));
    DEBUG_END()
}
uint64_t WOWNERO_PendingTransaction_txCount(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->txCount();
    DEBUG_END()
}
const char* WOWNERO_PendingTransaction_subaddrAccount(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<uint32_t> subaddrAccount = pendingTx->subaddrAccount();
    return vectorToString(subaddrAccount, std::string(separator));
    DEBUG_END()
}
const char* WOWNERO_PendingTransaction_subaddrIndices(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::set<uint32_t>> subaddrIndices = pendingTx->subaddrIndices();
    return vectorToString(subaddrIndices, std::string(separator));
    DEBUG_END()
}
const char* WOWNERO_PendingTransaction_multisigSignData(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::string str = pendingTx->multisigSignData();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
void WOWNERO_PendingTransaction_signMultisigTx(void* pendingTx_ptr) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    return pendingTx->signMultisigTx();
    DEBUG_END()
}
const char* WOWNERO_PendingTransaction_signersKeys(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::string> txid = pendingTx->signersKeys();
    return vectorToString(txid, std::string(separator));
    DEBUG_END()
}

const char* WOWNERO_PendingTransaction_hex(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::string> txid = pendingTx->hex();
    return vectorToString(txid, std::string(separator));
    DEBUG_END()
}

// const char* WOWNERO_PendingTransaction_txHex(void* pendingTx_ptr, const char* separator) {
//     Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
//     std::vector<std::string> txid = pendingTx->txHex();
//     return vectorToString(txid, std::string(separator));
// }

const char* WOWNERO_PendingTransaction_txKey(void* pendingTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::PendingTransaction *pendingTx = reinterpret_cast<Monero::PendingTransaction*>(pendingTx_ptr);
    std::vector<std::string> txid = pendingTx->txKey();
    return vectorToString(txid, std::string(separator));
    DEBUG_END()
}

// UnsignedTransaction

int WOWNERO_UnsignedTransaction_status(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return unsignedTx->status();
    DEBUG_END()
}
const char* WOWNERO_UnsignedTransaction_errorString(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    std::string str = unsignedTx->errorString();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
const char* WOWNERO_UnsignedTransaction_amount(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->amount(), std::string(separator));
    DEBUG_END()
}
const char* WOWNERO_UnsignedTransaction_fee(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->fee(), std::string(separator));
    DEBUG_END()
}
const char* WOWNERO_UnsignedTransaction_mixin(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->mixin(), std::string(separator));
    DEBUG_END()
}
const char* WOWNERO_UnsignedTransaction_confirmationMessage(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    std::string str = unsignedTx->confirmationMessage();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
const char* WOWNERO_UnsignedTransaction_paymentId(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->paymentId(), std::string(separator));
    DEBUG_END()
}
const char* WOWNERO_UnsignedTransaction_recipientAddress(void* unsignedTx_ptr, const char* separator) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return vectorToString(unsignedTx->recipientAddress(), std::string(separator));
    DEBUG_END()
}
uint64_t WOWNERO_UnsignedTransaction_minMixinCount(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return unsignedTx->minMixinCount();
    DEBUG_END()
}
uint64_t WOWNERO_UnsignedTransaction_txCount(void* unsignedTx_ptr) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return unsignedTx->txCount();
    DEBUG_END()
}
bool WOWNERO_UnsignedTransaction_sign(void* unsignedTx_ptr, const char* signedFileName) {
    DEBUG_START()
    Monero::UnsignedTransaction *unsignedTx = reinterpret_cast<Monero::UnsignedTransaction*>(unsignedTx_ptr);
    return unsignedTx->sign(std::string(signedFileName));
    DEBUG_END()
}

// TransactionInfo
int WOWNERO_TransactionInfo_direction(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->direction();
    DEBUG_END()
}
bool WOWNERO_TransactionInfo_isPending(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isPending();
    DEBUG_END()
}
bool WOWNERO_TransactionInfo_isFailed(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isFailed();
    DEBUG_END()
}
bool WOWNERO_TransactionInfo_isCoinbase(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->isCoinbase();
    DEBUG_END()
}
uint64_t WOWNERO_TransactionInfo_amount(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->amount();
    DEBUG_END()
}
uint64_t WOWNERO_TransactionInfo_fee(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->fee();
    DEBUG_END()
}
uint64_t WOWNERO_TransactionInfo_blockHeight(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->blockHeight();
    DEBUG_END()
}
const char* WOWNERO_TransactionInfo_description(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->description();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
const char* WOWNERO_TransactionInfo_subaddrIndex(void* txInfo_ptr, const char* separator) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::set<uint32_t> subaddrIndex = txInfo->subaddrIndex();
    return vectorToString(subaddrIndex, std::string(separator));
    DEBUG_END()
}
uint32_t WOWNERO_TransactionInfo_subaddrAccount(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->subaddrAccount();
    DEBUG_END()
}
const char* WOWNERO_TransactionInfo_label(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->label();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
uint64_t WOWNERO_TransactionInfo_confirmations(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->confirmations();
    DEBUG_END()
}
uint64_t WOWNERO_TransactionInfo_unlockTime(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->unlockTime();
    DEBUG_END()
}
const char* WOWNERO_TransactionInfo_hash(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->hash();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
uint64_t WOWNERO_TransactionInfo_timestamp(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->timestamp();
    DEBUG_END()
}
const char* WOWNERO_TransactionInfo_paymentId(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->paymentId();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

int WOWNERO_TransactionInfo_transfers_count(void* txInfo_ptr) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->transfers().size();
    DEBUG_END()
}

uint64_t WOWNERO_TransactionInfo_transfers_amount(void* txInfo_ptr, int index) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    return txInfo->transfers()[index].amount;
    DEBUG_END()
}

const char* WOWNERO_TransactionInfo_transfers_address(void* txInfo_ptr, int index) {
    DEBUG_START()
    Monero::TransactionInfo *txInfo = reinterpret_cast<Monero::TransactionInfo*>(txInfo_ptr);
    std::string str = txInfo->transfers()[index].address;
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}




// TransactionHistory
int WOWNERO_TransactionHistory_count(void* txHistory_ptr) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->count();
    DEBUG_END()
}
void* WOWNERO_TransactionHistory_transaction(void* txHistory_ptr, int index) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return reinterpret_cast<void*>(txHistory->transaction(index));
    DEBUG_END()
}
void* WOWNERO_TransactionHistory_transactionById(void* txHistory_ptr, const char* id) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return reinterpret_cast<void*>(txHistory->transaction(std::string(id)));
    DEBUG_END()
}

void WOWNERO_TransactionHistory_refresh(void* txHistory_ptr) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->refresh();
    DEBUG_END()
}
void WOWNERO_TransactionHistory_setTxNote(void* txHistory_ptr, const char* txid, const char* note) {
    DEBUG_START()
    Monero::TransactionHistory *txHistory = reinterpret_cast<Monero::TransactionHistory*>(txHistory_ptr);
    return txHistory->setTxNote(std::string(txid), std::string(note));
    DEBUG_END()
}

// AddressBokRow

//     std::string extra;
const char* WOWNERO_AddressBookRow_extra(void* addressBookRow_ptr) {
    DEBUG_START()
    Monero::AddressBookRow *addressBookRow = reinterpret_cast<Monero::AddressBookRow*>(addressBookRow_ptr);
    std::string str = addressBookRow->extra;
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getAddress() const {return m_address;} 
const char* WOWNERO_AddressBookRow_getAddress(void* addressBookRow_ptr) {
    DEBUG_START()
    Monero::AddressBookRow *addressBookRow = reinterpret_cast<Monero::AddressBookRow*>(addressBookRow_ptr);
    std::string str = addressBookRow->getAddress();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getDescription() const {return m_description;} 
const char* WOWNERO_AddressBookRow_getDescription(void* addressBookRow_ptr) {
    DEBUG_START()
    Monero::AddressBookRow *addressBookRow = reinterpret_cast<Monero::AddressBookRow*>(addressBookRow_ptr);
    std::string str = addressBookRow->getDescription();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getPaymentId() const {return m_paymentId;} 
const char* WOWNERO_AddressBookRow_getPaymentId(void* addressBookRow_ptr) {
    DEBUG_START()
    Monero::AddressBookRow *addressBookRow = reinterpret_cast<Monero::AddressBookRow*>(addressBookRow_ptr);
    std::string str = addressBookRow->getPaymentId();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::size_t getRowId() const {return m_rowId;}
size_t WOWNERO_AddressBookRow_getRowId(void* addressBookRow_ptr) {
    DEBUG_START()
    Monero::AddressBookRow *addressBookRow = reinterpret_cast<Monero::AddressBookRow*>(addressBookRow_ptr);
    return addressBookRow->getRowId();
    DEBUG_END()
}

// AddressBook
//     virtual std::vector<AddressBookRow*> getAll() const = 0;
int WOWNERO_AddressBook_getAll_size(void* addressBook_ptr) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->getAll().size();
    DEBUG_END()
}
void* WOWNERO_AddressBook_getAll_byIndex(void* addressBook_ptr, int index) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->getAll()[index];
    DEBUG_END()
}
//     virtual bool addRow(const std::string &dst_addr , const std::string &payment_id, const std::string &description) = 0;  
bool WOWNERO_AddressBook_addRow(void* addressBook_ptr, const char* dst_addr , const char* payment_id, const char* description) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->addRow(std::string(dst_addr), std::string(payment_id), std::string(description));
    DEBUG_END()
}
//     virtual bool deleteRow(std::size_t rowId) = 0;
bool WOWNERO_AddressBook_deleteRow(void* addressBook_ptr, size_t rowId) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->deleteRow(rowId);
    DEBUG_END()
}
//     virtual bool setDescription(std::size_t index, const std::string &description) = 0;
bool WOWNERO_AddressBook_setDescription(void* addressBook_ptr, size_t rowId, const char* description) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->setDescription(rowId, std::string(description));
    DEBUG_END()
}
//     virtual void refresh() = 0;  
void WOWNERO_AddressBook_refresh(void* addressBook_ptr) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->refresh();
    DEBUG_END()
}
//     virtual std::string errorString() const = 0;
const char* WOWNERO_AddressBook_errorString(void* addressBook_ptr) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    std::string str = addressBook->errorString();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual int errorCode() const = 0;
int WOWNERO_AddressBook_errorCode(void* addressBook_ptr) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->errorCode();
    DEBUG_END()
}
//     virtual int lookupPaymentID(const std::string &payment_id) const = 0;
int WOWNERO_AddressBook_lookupPaymentID(void* addressBook_ptr, const char* payment_id) {
    DEBUG_START()
    Monero::AddressBook *addressBook = reinterpret_cast<Monero::AddressBook*>(addressBook_ptr);
    return addressBook->lookupPaymentID(std::string(payment_id));
    DEBUG_END()
}

// CoinsInfo
uint64_t WOWNERO_CoinsInfo_blockHeight(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->blockHeight();
    DEBUG_END()
}
//     virtual std::string hash() const = 0;
const char* WOWNERO_CoinsInfo_hash(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    std::string str = coinsInfo->hash();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual size_t internalOutputIndex() const = 0;
size_t WOWNERO_CoinsInfo_internalOutputIndex(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->internalOutputIndex();
    DEBUG_END()
}
//     virtual uint64_t globalOutputIndex() const = 0;
uint64_t WOWNERO_CoinsInfo_globalOutputIndex(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->globalOutputIndex();
    DEBUG_END()
}
//     virtual bool spent() const = 0;
bool WOWNERO_CoinsInfo_spent(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->spent();
    DEBUG_END()
}
//     virtual bool frozen() const = 0;
bool WOWNERO_CoinsInfo_frozen(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->frozen();
    DEBUG_END()
}
//     virtual uint64_t spentHeight() const = 0;
uint64_t WOWNERO_CoinsInfo_spentHeight(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->spentHeight();
    DEBUG_END()
}
//     virtual uint64_t amount() const = 0;
uint64_t WOWNERO_CoinsInfo_amount(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->amount();
    DEBUG_END()
}
//     virtual bool rct() const = 0;
bool WOWNERO_CoinsInfo_rct(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->rct();
    DEBUG_END()
}
//     virtual bool keyImageKnown() const = 0;
bool WOWNERO_CoinsInfo_keyImageKnown(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->keyImageKnown();
    DEBUG_END()
}
//     virtual size_t pkIndex() const = 0;
size_t WOWNERO_CoinsInfo_pkIndex(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->pkIndex();
    DEBUG_END()
}
//     virtual uint32_t subaddrIndex() const = 0;
uint32_t WOWNERO_CoinsInfo_subaddrIndex(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->subaddrIndex();
    DEBUG_END()
}
//     virtual uint32_t subaddrAccount() const = 0;
uint32_t WOWNERO_CoinsInfo_subaddrAccount(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->subaddrAccount();
    DEBUG_END()
}
//     virtual std::string address() const = 0;
const char* WOWNERO_CoinsInfo_address(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    std::string str = coinsInfo->address();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual std::string addressLabel() const = 0;
const char* WOWNERO_CoinsInfo_addressLabel(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    std::string str = coinsInfo->addressLabel();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual std::string keyImage() const = 0;
const char* WOWNERO_CoinsInfo_keyImage(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    std::string str = coinsInfo->keyImage();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual uint64_t unlockTime() const = 0;
uint64_t WOWNERO_CoinsInfo_unlockTime(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->unlockTime();
    DEBUG_END()
}
//     virtual bool unlocked() const = 0;
bool WOWNERO_CoinsInfo_unlocked(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->unlocked();
    DEBUG_END()
}
//     virtual std::string pubKey() const = 0;
const char* WOWNERO_CoinsInfo_pubKey(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    std::string str = coinsInfo->pubKey();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual bool coinbase() const = 0;
bool WOWNERO_CoinsInfo_coinbase(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    return coinsInfo->coinbase();
    DEBUG_END()
}
//     virtual std::string description() const = 0;
const char* WOWNERO_CoinsInfo_description(void* coinsInfo_ptr) {
    DEBUG_START()
    Monero::CoinsInfo *coinsInfo = reinterpret_cast<Monero::CoinsInfo*>(coinsInfo_ptr);
    std::string str = coinsInfo->description();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}


// coins

//     virtual ~Coins() = 0;
//     virtual int count() const = 0;
int WOWNERO_Coins_count(void* coins_ptr) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->count();
    DEBUG_END()
}
//     virtual CoinsInfo * coin(int index)  const = 0;
void* WOWNERO_Coins_coin(void* coins_ptr, int index) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->coin(index);
    DEBUG_END()
}

int WOWNERO_Coins_getAll_size(void* coins_ptr)  {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->getAll().size();
    DEBUG_END()
}
void* WOWNERO_Coins_getAll_byIndex(void* coins_ptr, int index) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->getAll()[index];
    DEBUG_END()
}

//     virtual std::vector<CoinsInfo*> getAll() const = 0;
//     virtual void refresh() = 0;
void WOWNERO_Coins_refresh(void* coins_ptr) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->refresh();
    DEBUG_END()
}
//     virtual void setFrozen(std::string public_key) = 0;
void WOWNERO_Coins_setFrozenByPublicKey(void* coins_ptr, const char* public_key) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->setFrozen(std::string(public_key));
    DEBUG_END()
}
//     virtual void setFrozen(int index) = 0;
void WOWNERO_Coins_setFrozen(void* coins_ptr, int index) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->setFrozen(index);
    DEBUG_END()
}
//     virtual void thaw(int index) = 0;
void WOWNERO_Coins_thaw(void* coins_ptr, int index) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->thaw(index);
    DEBUG_END()
}
//     virtual void thaw(std::string public_key) = 0;
void WOWNERO_Coins_thawByPublicKey(void* coins_ptr, const char* public_key) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->thaw(std::string(public_key));
    DEBUG_END()
}
//     virtual bool isTransferUnlocked(uint64_t unlockTime, uint64_t blockHeight) = 0;
bool WOWNERO_Coins_isTransferUnlocked(void* coins_ptr, uint64_t unlockTime, uint64_t blockHeight) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    return coins->isTransferUnlocked(unlockTime, blockHeight);
    DEBUG_END()
}
//    virtual void setDescription(const std::string &public_key, const std::string &description) = 0;
void WOWNERO_Coins_setDescription(void* coins_ptr, const char* public_key, const char* description) {
    DEBUG_START()
    Monero::Coins *coins = reinterpret_cast<Monero::Coins*>(coins_ptr);
    coins->setDescription(std::string(public_key), std::string(description));
    DEBUG_END()
}

// SubaddressRow

//     std::string extra;
const char* WOWNERO_SubaddressRow_extra(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    std::string str = subaddressRow->extra;
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getAddress() const {return m_address;}
const char* WOWNERO_SubaddressRow_getAddress(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    std::string str = subaddressRow->getAddress();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getLabel() const {return m_label;}
const char* WOWNERO_SubaddressRow_getLabel(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    std::string str = subaddressRow->getLabel();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::size_t getRowId() const {return m_rowId;}
size_t WOWNERO_SubaddressRow_getRowId(void* subaddressRow_ptr) {
    DEBUG_START()
    Monero::SubaddressRow *subaddressRow = reinterpret_cast<Monero::SubaddressRow*>(subaddressRow_ptr);
    return subaddressRow->getRowId();
    DEBUG_END()
}

// Subaddress

int WOWNERO_Subaddress_getAll_size(void* subaddress_ptr) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->getAll().size();
    DEBUG_END()
}
void* WOWNERO_Subaddress_getAll_byIndex(void* subaddress_ptr, int index) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->getAll()[index];
    DEBUG_END()
}
//     virtual void addRow(uint32_t accountIndex, const std::string &label) = 0;
void WOWNERO_Subaddress_addRow(void* subaddress_ptr, uint32_t accountIndex, const char* label) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->addRow(accountIndex, std::string(label));
    DEBUG_END()
}
//     virtual void setLabel(uint32_t accountIndex, uint32_t addressIndex, const std::string &label) = 0;
void WOWNERO_Subaddress_setLabel(void* subaddress_ptr, uint32_t accountIndex, uint32_t addressIndex, const char* label) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->setLabel(accountIndex, addressIndex, std::string(label));
    DEBUG_END()
}
//     virtual void refresh(uint32_t accountIndex) = 0;
void WOWNERO_Subaddress_refresh(void* subaddress_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Subaddress *subaddress = reinterpret_cast<Monero::Subaddress*>(subaddress_ptr);
    return subaddress->refresh(accountIndex);
    DEBUG_END()
}

// SubaddressAccountRow

//     std::string extra;
const char* WOWNERO_SubaddressAccountRow_extra(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->extra;
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getAddress() const {return m_address;}
const char* WOWNERO_SubaddressAccountRow_getAddress(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getAddress();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getLabel() const {return m_label;}
const char* WOWNERO_SubaddressAccountRow_getLabel(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getLabel();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getBalance() const {return m_balance;}
const char* WOWNERO_SubaddressAccountRow_getBalance(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getBalance();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::string getUnlockedBalance() const {return m_unlockedBalance;}
const char* WOWNERO_SubaddressAccountRow_getUnlockedBalance(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    std::string str = subaddressAccountRow->getUnlockedBalance();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     std::size_t getRowId() const {return m_rowId;}
size_t WOWNERO_SubaddressAccountRow_getRowId(void* subaddressAccountRow_ptr) {
    DEBUG_START()
    Monero::SubaddressAccountRow *subaddressAccountRow = reinterpret_cast<Monero::SubaddressAccountRow*>(subaddressAccountRow_ptr);
    return subaddressAccountRow->getRowId();
    DEBUG_END()
}

// struct SubaddressAccount
// {
//     virtual ~SubaddressAccount() = 0;
//     virtual std::vector<SubaddressAccountRow*> getAll() const = 0;
int WOWNERO_SubaddressAccount_getAll_size(void* subaddressAccount_ptr) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->getAll().size();
    DEBUG_END()
}
void* WOWNERO_SubaddressAccount_getAll_byIndex(void* subaddressAccount_ptr, int index) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->getAll()[index];
    DEBUG_END()
}
//     virtual void addRow(const std::string &label) = 0;
void WOWNERO_SubaddressAccount_addRow(void* subaddressAccount_ptr, const char* label) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->addRow(std::string(label));
    DEBUG_END()
}
//     virtual void setLabel(uint32_t accountIndex, const std::string &label) = 0;
void WOWNERO_SubaddressAccount_setLabel(void* subaddressAccount_ptr, uint32_t accountIndex, const char* label) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->setLabel(accountIndex, std::string(label));
    DEBUG_END()
}
//     virtual void refresh() = 0;
void WOWNERO_SubaddressAccount_refresh(void* subaddressAccount_ptr) {
    DEBUG_START()
    Monero::SubaddressAccount *subaddress = reinterpret_cast<Monero::SubaddressAccount*>(subaddressAccount_ptr);
    return subaddress->refresh();
    DEBUG_END()
}

// MultisigState

//     bool isMultisig;
bool WOWNERO_MultisigState_isMultisig(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->isMultisig;
    DEBUG_END()
}
//     bool isReady;
bool WOWNERO_MultisigState_isReady(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->isReady;
    DEBUG_END()
}
//     uint32_t threshold;
uint32_t WOWNERO_MultisigState_threshold(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->threshold;
    DEBUG_END()
}
//     uint32_t total;
uint32_t WOWNERO_MultisigState_total(void* multisigState_ptr) {
    DEBUG_START()
    Monero::MultisigState *multisigState = reinterpret_cast<Monero::MultisigState*>(multisigState_ptr);
    return multisigState->total;
    DEBUG_END()
}

// DeviceProgress


//     virtual double progress() const { return m_progress; }
bool WOWNERO_DeviceProgress_progress(void* deviceProgress_ptr) {
    DEBUG_START()
    Monero::DeviceProgress *deviceProgress = reinterpret_cast<Monero::DeviceProgress*>(deviceProgress_ptr);
    return deviceProgress->progress();
    DEBUG_END()
}
//     virtual bool indeterminate() const { return m_indeterminate; }
bool WOWNERO_DeviceProgress_indeterminate(void* deviceProgress_ptr) {
    DEBUG_START()
    Monero::DeviceProgress *deviceProgress = reinterpret_cast<Monero::DeviceProgress*>(deviceProgress_ptr);
    return deviceProgress->indeterminate();
    DEBUG_END()
}

// Wallet

const char* WOWNERO_Wallet_seed(void* wallet_ptr, const char* seed_offset) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->seed(std::string(seed_offset));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_getSeedLanguage(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getSeedLanguage();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

void WOWNERO_Wallet_setSeedLanguage(void* wallet_ptr, const char* arg) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setSeedLanguage(std::string(arg));
    DEBUG_END()
}

int WOWNERO_Wallet_status(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->status();
    DEBUG_END()
}

const char* WOWNERO_Wallet_errorString(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->errorString();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}


bool WOWNERO_Wallet_setPassword(void* wallet_ptr, const char* password) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setPassword(std::string(password));
    DEBUG_END()
}

const char* WOWNERO_Wallet_getPassword(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getPassword();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

bool WOWNERO_Wallet_setDevicePin(void* wallet_ptr, const char* pin) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setDevicePin(std::string(pin));
    DEBUG_END()
}

bool WOWNERO_Wallet_setDevicePassphrase(void* wallet_ptr, const char* passphrase) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setDevicePassphrase(std::string(passphrase));
    DEBUG_END()
}

const char* WOWNERO_Wallet_address(void* wallet_ptr, uint64_t accountIndex, uint64_t addressIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->address(accountIndex, addressIndex);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_path(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->path();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
int WOWNERO_Wallet_nettype(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->nettype();
    DEBUG_END()
}
uint8_t WOWNERO_Wallet_useForkRules(void* wallet_ptr, uint8_t version, int64_t early_blocks) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->useForkRules(version, early_blocks);
    DEBUG_END()
}
const char* WOWNERO_Wallet_integratedAddress(void* wallet_ptr, const char* payment_id) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->integratedAddress(std::string(payment_id));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_secretViewKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->secretViewKey();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_publicViewKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->publicViewKey();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_secretSpendKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->secretSpendKey();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_publicSpendKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->publicSpendKey();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
const char* WOWNERO_Wallet_publicMultisigSignerKey(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->publicMultisigSignerKey();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

void WOWNERO_Wallet_stop(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    wallet->stop();
    DEBUG_END()
}

bool WOWNERO_Wallet_store(void* wallet_ptr, const char* path) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->store(std::string(path));
    DEBUG_END()
}
const char* WOWNERO_Wallet_filename(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->filename();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
const char* WOWNERO_Wallet_keysFilename(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->keysFilename();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

//     virtual bool init(const std::string &daemon_address, uint64_t upper_transaction_size_limit = 0, const std::string &daemon_username = "", const std::string &daemon_password = "", bool use_ssl = false, bool lightWallet = false, const std::string &proxy_address = "") = 0;
bool WOWNERO_Wallet_init(void* wallet_ptr, const char* daemon_address, uint64_t upper_transaction_size_limit, const char* daemon_username, const char* daemon_password, bool use_ssl, bool lightWallet, const char* proxy_address) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->init(std::string(daemon_address), upper_transaction_size_limit, std::string(daemon_username), std::string(daemon_password), use_ssl, lightWallet, std::string(proxy_address));
    DEBUG_END()
}
bool WOWNERO_Wallet_createWatchOnly(void* wallet_ptr, const char* path, const char* password, const char* language) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->createWatchOnly(std::string(path), std::string(password), std::string(language));
    DEBUG_END()
}

void WOWNERO_Wallet_setRefreshFromBlockHeight(void* wallet_ptr, uint64_t refresh_from_block_height) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setRefreshFromBlockHeight(refresh_from_block_height);
    DEBUG_END()
}

uint64_t WOWNERO_Wallet_getRefreshFromBlockHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getRefreshFromBlockHeight();
    DEBUG_END()
}

void WOWNERO_Wallet_setRecoveringFromSeed(void* wallet_ptr, bool recoveringFromSeed) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setRecoveringFromSeed(recoveringFromSeed);
    DEBUG_END()
}
void WOWNERO_Wallet_setRecoveringFromDevice(void* wallet_ptr, bool recoveringFromDevice) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setRecoveringFromDevice(recoveringFromDevice);
    DEBUG_END()
}
void WOWNERO_Wallet_setSubaddressLookahead(void* wallet_ptr, uint32_t major, uint32_t minor) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setSubaddressLookahead(major, minor);
    DEBUG_END()
}

bool WOWNERO_Wallet_connectToDaemon(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->connectToDaemon();
    DEBUG_END()
}
int WOWNERO_Wallet_connected(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->connected();
    DEBUG_END()
}
void WOWNERO_Wallet_setTrustedDaemon(void* wallet_ptr, bool arg) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setTrustedDaemon(arg);
    DEBUG_END()
}
bool WOWNERO_Wallet_trustedDaemon(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->trustedDaemon();
    DEBUG_END()
}
bool WOWNERO_Wallet_setProxy(void* wallet_ptr, const char* address) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setProxy(std::string(address));
    DEBUG_END()
}

uint64_t WOWNERO_Wallet_balance(void* wallet_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->balance(accountIndex);
    DEBUG_END()
}

uint64_t WOWNERO_Wallet_unlockedBalance(void* wallet_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->unlockedBalance(accountIndex);
    DEBUG_END()
}

uint64_t WOWNERO_Wallet_viewOnlyBalance(void* wallet_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->viewOnlyBalance(accountIndex);
    DEBUG_END()
}

// TODO
bool WOWNERO_Wallet_watchOnly(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->watchOnly();
    DEBUG_END()
}
bool WOWNERO_Wallet_isDeterministic(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->isDeterministic();
    DEBUG_END()
}
uint64_t WOWNERO_Wallet_blockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->blockChainHeight();
    DEBUG_END()
}
uint64_t WOWNERO_Wallet_approximateBlockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->approximateBlockChainHeight();
    DEBUG_END()
}
uint64_t WOWNERO_Wallet_estimateBlockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->estimateBlockChainHeight();
    DEBUG_END()
}
uint64_t WOWNERO_Wallet_daemonBlockChainHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->daemonBlockChainHeight();
    DEBUG_END()
}

uint64_t WOWNERO_Wallet_daemonBlockChainTargetHeight(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->daemonBlockChainTargetHeight();
    DEBUG_END()
}
bool WOWNERO_Wallet_synchronized(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->synchronized();
    DEBUG_END()
}

const char* WOWNERO_Wallet_displayAmount(uint64_t amount) {
    DEBUG_START()
    std::string str = Monero::Wallet::displayAmount(amount);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

//     static uint64_t amountFromString(const std::string &amount);
uint64_t WOWNERO_Wallet_amountFromString(const char* amount) {
    DEBUG_START()
    return Monero::Wallet::amountFromString(amount);
    DEBUG_END()
}
//     static uint64_t amountFromDouble(double amount);
uint64_t WOWNERO_Wallet_amountFromDouble(double amount) {
    DEBUG_START()
    return Monero::Wallet::amountFromDouble(amount);
    DEBUG_END()
}
//     static std::string genPaymentId();
const char* WOWNERO_Wallet_genPaymentId() {
    DEBUG_START()
    std::string str = Monero::Wallet::genPaymentId();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     static bool paymentIdValid(const std::string &paiment_id);
bool WOWNERO_Wallet_paymentIdValid(const char* paiment_id) {
    DEBUG_START()
    return Monero::Wallet::paymentIdValid(std::string(paiment_id));
    DEBUG_END()
}
bool WOWNERO_Wallet_addressValid(const char* str, int nettype) {
    DEBUG_START()
    // Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return Monero::Wallet::addressValid(std::string(str), nettype);
    DEBUG_END()
}

bool WOWNERO_Wallet_keyValid(const char* secret_key_string, const char* address_string, bool isViewKey, int nettype) {
    DEBUG_START()
    std::string error;
    return Monero::Wallet::keyValid(std::string(secret_key_string), std::string(address_string), isViewKey, nettype, error);
    DEBUG_END()
}
const char* WOWNERO_Wallet_keyValid_error(const char* secret_key_string, const char* address_string, bool isViewKey, int nettype)  {
    DEBUG_START()
    std::string str;
    Monero::Wallet::keyValid(std::string(secret_key_string), std::string(address_string), isViewKey, nettype, str);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
const char* WOWNERO_Wallet_paymentIdFromAddress(const char* strarg, int nettype) {
    DEBUG_START()
    std::string str = Monero::Wallet::paymentIdFromAddress(std::string(strarg), nettype);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
uint64_t WOWNERO_Wallet_maximumAllowedAmount() {
    DEBUG_START()
    return Monero::Wallet::maximumAllowedAmount();
    DEBUG_END()
}

void WOWNERO_Wallet_init3(void* wallet_ptr, const char* argv0, const char* default_log_base_name, const char* log_path, bool console) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->init(argv0, default_log_base_name, log_path, console);
    DEBUG_END()
}
const char* WOWNERO_Wallet_getPolyseed(void* wallet_ptr, const char* passphrase) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string seed = "";
    std::string _passphrase = std::string(passphrase);
    wallet->getPolyseed(seed, _passphrase);
    std::string str = seed;
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     static bool createPolyseed(std::string &seed_words, std::string &err, const std::string &language = "English");
const char* WOWNERO_Wallet_createPolyseed(const char* language) {
    DEBUG_START()
    std::string seed_words = "";
    std::string err;
    Monero::Wallet::createPolyseed(seed_words, err, std::string(language));
    std::cout << "WOWNERO_Wallet_createPolyseed(language: " << language << "):" << std::endl;
    std::cout << "           err: "  << err << std::endl;
    std::string str = seed_words;
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

void WOWNERO_Wallet_startRefresh(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->startRefresh();
    DEBUG_END()
}
void WOWNERO_Wallet_pauseRefresh(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->pauseRefresh();
    DEBUG_END()
}
bool WOWNERO_Wallet_refresh(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->refresh();
    DEBUG_END()
}
void WOWNERO_Wallet_refreshAsync(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->refreshAsync();
    DEBUG_END()
}
bool WOWNERO_Wallet_rescanBlockchain(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanBlockchain();
    DEBUG_END()
}
void WOWNERO_Wallet_rescanBlockchainAsync(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanBlockchainAsync();
    DEBUG_END()
}
void WOWNERO_Wallet_setAutoRefreshInterval(void* wallet_ptr, int millis) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setAutoRefreshInterval(millis);
    DEBUG_END()
}
int WOWNERO_Wallet_autoRefreshInterval(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->autoRefreshInterval();
    DEBUG_END()
}
void WOWNERO_Wallet_addSubaddressAccount(void* wallet_ptr, const char* label) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->addSubaddressAccount(std::string(label));
    DEBUG_END()
}
size_t WOWNERO_Wallet_numSubaddressAccounts(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->numSubaddressAccounts();
    DEBUG_END()
}
size_t WOWNERO_Wallet_numSubaddresses(void* wallet_ptr, uint32_t accountIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->numSubaddresses(accountIndex);
    DEBUG_END()
}
void WOWNERO_Wallet_addSubaddress(void* wallet_ptr, uint32_t accountIndex, const char* label) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->addSubaddress(accountIndex, std::string(label));
    DEBUG_END()
}
const char* WOWNERO_Wallet_getSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getSubaddressLabel(accountIndex, addressIndex);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

void WOWNERO_Wallet_setSubaddressLabel(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex, const char* label) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setSubaddressLabel(accountIndex, addressIndex, std::string(label));
    DEBUG_END()
}
const char* WOWNERO_Wallet_getMultisigInfo(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getMultisigInfo();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
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

void* WOWNERO_Wallet_createTransactionMultDest(void* wallet_ptr, const char* dst_addr_list, const char* dst_addr_list_separator, const char* payment_id,
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
    std::set<std::string> preferred_inputs = splitString(std::string(preferredInputs), std::string(preferredInputs_separator));

    return wallet->createTransactionMultDest(
        dst_addr, std::string(payment_id),
        optAmount, mixin_count,
        PendingTransaction_Priority_fromInt(pendingTransactionPriority),
        subaddr_account,
        subaddr_indices,
        preferred_inputs
    );
    DEBUG_END()
}

void* WOWNERO_Wallet_createTransaction(void* wallet_ptr, const char* dst_addr, const char* payment_id,
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
    std::set<std::string> preferred_inputs = splitString(std::string(preferredInputs), std::string(separator));
    return wallet->createTransaction(std::string(dst_addr), std::string(payment_id),
                                        optAmount, mixin_count,
                                        PendingTransaction_Priority_fromInt(pendingTransactionPriority),
                                        subaddr_account, subaddr_indices, preferred_inputs);
    DEBUG_END()
}

void* WOWNERO_Wallet_loadUnsignedTx(void* wallet_ptr, const char* fileName) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->loadUnsignedTx(std::string(fileName));
    DEBUG_END()
}
bool WOWNERO_Wallet_submitTransaction(void* wallet_ptr, const char* fileName) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->submitTransaction(std::string(fileName));
    DEBUG_END()
}
bool WOWNERO_Wallet_hasUnknownKeyImages(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->hasUnknownKeyImages();
    DEBUG_END()
}
bool WOWNERO_Wallet_exportKeyImages(void* wallet_ptr, const char* filename, bool all) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->exportKeyImages(std::string(filename), all);
    DEBUG_END()
}
bool WOWNERO_Wallet_importKeyImages(void* wallet_ptr, const char* filename) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->importKeyImages(std::string(filename));
    DEBUG_END()
}
bool WOWNERO_Wallet_exportOutputs(void* wallet_ptr, const char* filename, bool all) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->exportOutputs(std::string(filename), all);
    DEBUG_END()
}
bool WOWNERO_Wallet_importOutputs(void* wallet_ptr, const char* filename) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->importOutputs(std::string(filename));
    DEBUG_END()
}
//     virtual bool setupBackgroundSync(const BackgroundSyncType background_sync_type, const std::string &wallet_password, const optional<std::string> &background_cache_password) = 0;
bool WOWNERO_Wallet_setupBackgroundSync(void* wallet_ptr, int background_sync_type, const char* wallet_password, const char* background_cache_password) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setupBackgroundSync(Monero::Wallet::BackgroundSyncType::BackgroundSync_CustomPassword, std::string(wallet_password), std::string(background_cache_password));
    DEBUG_END()
}
//     virtual BackgroundSyncType getBackgroundSyncType() const = 0;
int WOWNERO_Wallet_getBackgroundSyncType(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getBackgroundSyncType();
    DEBUG_END()
}
//     virtual bool startBackgroundSync() = 0;
bool WOWNERO_Wallet_startBackgroundSync(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->startBackgroundSync();
    DEBUG_END()
}
//     virtual bool stopBackgroundSync(const std::string &wallet_password) = 0;
bool WOWNERO_Wallet_stopBackgroundSync(void* wallet_ptr, const char* wallet_password) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->stopBackgroundSync(std::string(wallet_password));
    DEBUG_END()
}
//     virtual bool isBackgroundSyncing() const = 0;
bool WOWNERO_Wallet_isBackgroundSyncing(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->hasUnknownKeyImages();
    DEBUG_END()
}
//     virtual bool isBackgroundWallet() const = 0;
bool WOWNERO_Wallet_isBackgroundWallet(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->isBackgroundWallet();
    DEBUG_END()
}
void* WOWNERO_Wallet_history(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->history();
    DEBUG_END()
}
void* WOWNERO_Wallet_addressBook(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->addressBook();
    DEBUG_END()
}
//     virtual Coins * coins() = 0;
void* WOWNERO_Wallet_coins(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->coins();
    DEBUG_END()
}
//     virtual Subaddress * subaddress() = 0;
void* WOWNERO_Wallet_subaddress(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->subaddress();
    DEBUG_END()
}
//     virtual SubaddressAccount * subaddressAccount() = 0;
void* WOWNERO_Wallet_subaddressAccount(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->subaddressAccount();
    DEBUG_END()
}
//     virtual uint32_t defaultMixin() const = 0;
uint32_t WOWNERO_Wallet_defaultMixin(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->defaultMixin();
    DEBUG_END()
}
//     virtual void setDefaultMixin(uint32_t arg) = 0;
void WOWNERO_Wallet_setDefaultMixin(void* wallet_ptr, uint32_t arg) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setDefaultMixin(arg);
    DEBUG_END()
}
//     virtual bool setCacheAttribute(const std::string &key, const std::string &val) = 0;
bool WOWNERO_Wallet_setCacheAttribute(void* wallet_ptr, const char* key, const char* val) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setCacheAttribute(std::string(key), std::string(val));
    DEBUG_END()
}
//     virtual std::string getCacheAttribute(const std::string &key) const = 0;
const char* WOWNERO_Wallet_getCacheAttribute(void* wallet_ptr, const char* key) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getCacheAttribute(std::string(key));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual bool setUserNote(const std::string &txid, const std::string &note) = 0;
bool WOWNERO_Wallet_setUserNote(void* wallet_ptr, const char* txid, const char* note) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setUserNote(std::string(txid), std::string(note));
    DEBUG_END()
}
//     virtual std::string getUserNote(const std::string &txid) const = 0;
const char* WOWNERO_Wallet_getUserNote(void* wallet_ptr, const char* txid) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getUserNote(std::string(txid));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_getTxKey(void* wallet_ptr, const char* txid) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->getTxKey(std::string(txid));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

const char* WOWNERO_Wallet_signMessage(void* wallet_ptr, const char* message, const char* address) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = wallet->signMessage(std::string(message), std::string(address));
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

bool WOWNERO_Wallet_verifySignedMessage(void* wallet_ptr, const char* message, const char* address, const char* signature) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    bool v = wallet->verifySignedMessage(std::string(message), std::string(address), std::string(signature));
    return v;
    DEBUG_END()
}

bool WOWNERO_Wallet_rescanSpent(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->rescanSpent();
    DEBUG_END()
}

void WOWNERO_Wallet_setOffline(void* wallet_ptr, bool offline) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->setOffline(offline);
    DEBUG_END()
}
//     virtual bool isOffline() const = 0;
bool WOWNERO_Wallet_isOffline(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->isOffline();
    DEBUG_END()
}

void WOWNERO_Wallet_segregatePreForkOutputs(void* wallet_ptr, bool segregate) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->segregatePreForkOutputs(segregate);
    DEBUG_END()
}
//     virtual void segregationHeight(uint64_t height) = 0;
void WOWNERO_Wallet_segregationHeight(void* wallet_ptr, uint64_t height) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->segregationHeight(height);
    DEBUG_END()
}
//     virtual void keyReuseMitigation2(bool mitigation) = 0;
void WOWNERO_Wallet_keyReuseMitigation2(void* wallet_ptr, bool mitigation) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->keyReuseMitigation2(mitigation);
    DEBUG_END()
}
//     virtual bool lightWalletLogin(bool &isNewWallet) const = 0;
//     virtual bool lightWalletImportWalletRequest(std::string &payment_id, uint64_t &fee, bool &new_request, bool &request_fulfilled, std::string &payment_address, std::string &status) = 0;
//     virtual bool lockKeysFile() = 0;
bool WOWNERO_Wallet_lockKeysFile(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->lockKeysFile();
    DEBUG_END()
}
//     virtual bool unlockKeysFile() = 0;
bool WOWNERO_Wallet_unlockKeysFile(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->unlockKeysFile();
    DEBUG_END()
}
//     virtual bool isKeysFileLocked() = 0;
bool WOWNERO_Wallet_isKeysFileLocked(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->isKeysFileLocked();
    DEBUG_END()
}
//     virtual Device getDeviceType() const = 0;
int WOWNERO_Wallet_getDeviceType(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getDeviceType();
    DEBUG_END()
}
//     virtual uint64_t coldKeyImageSync(uint64_t &spent, uint64_t &unspent) = 0;
uint64_t WOWNERO_Wallet_coldKeyImageSync(void* wallet_ptr, uint64_t spent, uint64_t unspent) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->coldKeyImageSync(spent, unspent);
    DEBUG_END()
}
//     virtual void deviceShowAddress(uint32_t accountIndex, uint32_t addressIndex, const std::string &paymentId) = 0;
const char* WOWNERO_Wallet_deviceShowAddress(void* wallet_ptr, uint32_t accountIndex, uint32_t addressIndex) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    std::string str = "";
    wallet->deviceShowAddress(accountIndex, addressIndex, str);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}
//     virtual bool reconnectDevice() = 0;
bool WOWNERO_Wallet_reconnectDevice(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->reconnectDevice();
    DEBUG_END()
};

uint64_t WOWNERO_Wallet_getBytesReceived(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getBytesReceived();
    DEBUG_END()
}
uint64_t WOWNERO_Wallet_getBytesSent(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wallet->getBytesSent();
    DEBUG_END()
}


void* WOWNERO_WalletManager_createWallet(void* wm_ptr, const char* path, const char* password, const char* language, int networkType) {
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

void* WOWNERO_WalletManager_openWallet(void* wm_ptr, const char* path, const char* password, int networkType) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = wm->openWallet(
                    std::string(path),
                    std::string(password),
                    static_cast<Monero::NetworkType>(networkType));
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}
void* WOWNERO_WalletManager_recoveryWallet(void* wm_ptr, const char* path, const char* password, const char* mnemonic, int networkType, uint64_t restoreHeight, uint64_t kdfRounds, const char* seedOffset) {
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
void* WOWNERO_WalletManager_createWalletFromKeys(void* wm_ptr, const char* path, const char* password, const char* language, int nettype, uint64_t restoreHeight, const char* addressString, const char* viewKeyString, const char* spendKeyString, uint64_t kdf_rounds) {
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

void* WOWNERO_WalletManager_createDeterministicWalletFromSpendKey(void* wm_ptr, const char* path, const char* password,
                                                const char* language, int nettype, uint64_t restoreHeight,
                                                const char* spendKeyString, uint64_t kdf_rounds) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = wm->createDeterministicWalletFromSpendKey(
        std::string(path),
        std::string(password),
        std::string(language),
        static_cast<Monero::NetworkType>(nettype),
        restoreHeight,
        std::string(spendKeyString),
        kdf_rounds
    );
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}

void* WOWNERO_WalletManager_createWalletFromPolyseed(void* wm_ptr, const char* path, const char* password,
                                                int nettype, const char* mnemonic, const char* passphrase,
                                                bool newWallet, uint64_t restore_height, uint64_t kdf_rounds) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->createWalletFromPolyseed(std::string(path),
                                              std::string(password),
                                              static_cast<Monero::NetworkType>(nettype),
                                              std::string(mnemonic),
                                              std::string(passphrase),
                                              newWallet,
                                              restore_height,
                                              kdf_rounds);
    DEBUG_END()
}


bool WOWNERO_WalletManager_closeWallet(void* wm_ptr, void* wallet_ptr, bool store) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    return wm->closeWallet(wallet, store);
    DEBUG_END()
}

bool WOWNERO_WalletManager_walletExists(void* wm_ptr, const char* path) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->walletExists(std::string(path));
    DEBUG_END()
}

//     virtual bool verifyWalletPassword(const std::string &keys_file_name, const std::string &password, bool no_spend_key, uint64_t kdf_rounds = 1) const = 0;
bool WOWNERO_WalletManager_verifyWalletPassword(void* wm_ptr, const char* keys_file_name, const char* password, bool no_spend_key, uint64_t kdf_rounds) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->verifyWalletPassword(std::string(keys_file_name), std::string(password), no_spend_key, kdf_rounds);
    DEBUG_END()
}
//     virtual bool queryWalletDevice(Wallet::Device& device_type, const std::string &keys_file_name, const std::string &password, uint64_t kdf_rounds = 1) const = 0;
// bool WOWNERO_WalletManager_queryWalletDevice(void* wm_ptr, int device_type, const char* keys_file_name, const char* password, uint64_t kdf_rounds) {
//     Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
//     return wm->queryWalletDevice(reinterpret_cast<Monero::Wallet::Device>(device_type), std::string(keys_file_name), std::string(password), kdf_rounds);
// }
//     virtual std::vector<std::string> findWallets(const std::string &path) = 0;
const char* WOWNERO_WalletManager_findWallets(void* wm_ptr, const char* path, const char* separator) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return vectorToString(wm->findWallets(std::string(path)), std::string(separator));
    DEBUG_END()
}


const char* WOWNERO_WalletManager_errorString(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    std::string str = wm->errorString();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

void WOWNERO_WalletManager_setDaemonAddress(void* wm_ptr, const char* address) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->setDaemonAddress(std::string(address));
    DEBUG_END()
}

bool WOWNERO_WalletManager_setProxy(void* wm_ptr, const char* address) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->setProxy(std::string(address));
    DEBUG_END()
}


//     virtual bool connected(uint32_t *version = NULL) = 0;
//     virtual uint64_t blockchainHeight() = 0;
uint64_t WOWNERO_WalletManager_blockchainHeight(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->blockchainHeight();
    DEBUG_END()
}
//     virtual uint64_t blockchainTargetHeight() = 0;
uint64_t WOWNERO_WalletManager_blockchainTargetHeight(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->blockchainTargetHeight();
    DEBUG_END()
}
//     virtual uint64_t networkDifficulty() = 0;
uint64_t WOWNERO_WalletManager_networkDifficulty(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->networkDifficulty();
    DEBUG_END()
}
//     virtual double miningHashRate() = 0;
double WOWNERO_WalletManager_miningHashRate(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->miningHashRate();
    DEBUG_END()
}
//     virtual uint64_t blockTarget() = 0;
uint64_t WOWNERO_WalletManager_blockTarget(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->blockTarget();
    DEBUG_END()
}
//     virtual bool isMining() = 0;
bool WOWNERO_WalletManager_isMining(void* wm_ptr) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->isMining();
    DEBUG_END()
}
//     virtual bool startMining(const std::string &address, uint32_t threads = 1, bool background_mining = false, bool ignore_battery = true) = 0;
bool WOWNERO_WalletManager_startMining(void* wm_ptr, const char* address, uint32_t threads, bool backgroundMining, bool ignoreBattery) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->startMining(std::string(address), threads, backgroundMining, ignoreBattery);
    DEBUG_END()
}
//     virtual bool stopMining() = 0;
bool WOWNERO_WalletManager_stopMining(void* wm_ptr, const char* address) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    return wm->stopMining();
    DEBUG_END()
}
//     virtual std::string resolveOpenAlias(const std::string &address, bool &dnssec_valid) const = 0;
const char* WOWNERO_WalletManager_resolveOpenAlias(void* wm_ptr, const char* address, bool dnssec_valid) {
    DEBUG_START()
    Monero::WalletManager *wm = reinterpret_cast<Monero::WalletManager*>(wm_ptr);
    std::string str = wm->resolveOpenAlias(std::string(address), dnssec_valid);
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
    DEBUG_END()
}

// WalletManagerFactory

void* WOWNERO_WalletManagerFactory_getWalletManager() {
    DEBUG_START()
    Monero::WalletManager *wm = Monero::WalletManagerFactory::getWalletManager();
    return reinterpret_cast<void*>(wm);
    DEBUG_END()
}

void WOWNERO_WalletManagerFactory_setLogLevel(int level) {
    DEBUG_START()
    Monero::WalletManagerFactory::setLogLevel(level);
    DEBUG_END()
}

void WOWNERO_WalletManagerFactory_setLogCategories(const char* categories) {
    DEBUG_START()
    Monero::WalletManagerFactory::setLogCategories(std::string(categories));
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

void WOWNERO_DEBUG_test0() {
    return;
}

bool WOWNERO_DEBUG_test1(bool x) {
    return x;
}

int WOWNERO_DEBUG_test2(int x) {
    return x;
}

uint64_t WOWNERO_DEBUG_test3(uint64_t x) {
    return x;
}

void* WOWNERO_DEBUG_test4(uint64_t x) {
    int y = x;
    return reinterpret_cast<void*>(&y);
}

const char* WOWNERO_DEBUG_test5() {
    const char *text  = "This is a const char* text"; 
    return text;
}

const char* WOWNERO_DEBUG_test5_std() {
    std::string text ("This is a std::string text");
    const char *text2 = "This is a text"; 
    return text2;
}

bool WOWNERO_DEBUG_isPointerNull(void* wallet_ptr) {
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
struct WOWNERO_cw_WalletListener;
struct WOWNERO_cw_WalletListener : Monero::WalletListener
{
    uint64_t m_height;
    bool m_need_to_refresh;
    bool m_new_transaction;

    WOWNERO_cw_WalletListener()
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

    void refreshed(bool success) {};
};

void* WOWNERO_cw_getWalletListener(void* wallet_ptr) {
    DEBUG_START()
    Monero::Wallet *wallet = reinterpret_cast<Monero::Wallet*>(wallet_ptr);
    WOWNERO_cw_WalletListener *listener = new WOWNERO_cw_WalletListener();
    wallet->setListener(listener);
    return reinterpret_cast<void*>(listener);
    DEBUG_END()
}

void WOWNERO_cw_WalletListener_resetNeedToRefresh(void* cw_walletListener_ptr) {
    DEBUG_START()
    WOWNERO_cw_WalletListener *listener = reinterpret_cast<WOWNERO_cw_WalletListener*>(cw_walletListener_ptr);
    listener->cw_resetNeedToRefresh();
    DEBUG_END()
}

bool WOWNERO_cw_WalletListener_isNeedToRefresh(void* cw_walletListener_ptr) {
    DEBUG_START()
    WOWNERO_cw_WalletListener *listener = reinterpret_cast<WOWNERO_cw_WalletListener*>(cw_walletListener_ptr);
    return listener->cw_isNeedToRefresh();
    DEBUG_END()
};

bool WOWNERO_cw_WalletListener_isNewTransactionExist(void* cw_walletListener_ptr) {
    DEBUG_START()
    WOWNERO_cw_WalletListener *listener = reinterpret_cast<WOWNERO_cw_WalletListener*>(cw_walletListener_ptr);
    return listener->cw_isNeedToRefresh();
    DEBUG_END()
};

void WOWNERO_cw_WalletListener_resetIsNewTransactionExist(void* cw_walletListener_ptr) {
    DEBUG_START()
    WOWNERO_cw_WalletListener *listener = reinterpret_cast<WOWNERO_cw_WalletListener*>(cw_walletListener_ptr);
    listener->cw_isNeedToRefresh();
    DEBUG_END()
};

uint64_t WOWNERO_cw_WalletListener_height(void* cw_walletListener_ptr) {
    DEBUG_START()
    WOWNERO_cw_WalletListener *listener = reinterpret_cast<WOWNERO_cw_WalletListener*>(cw_walletListener_ptr);
    return listener->cw_isNeedToRefresh();
    DEBUG_END()
};

// 14-word polyseed compat
// wow was really quick to implement polyseed support (aka wownero-seed), which
// results in this maintenance burden we have to go through.
//
// Code is borrowed from
// https://github.com/cypherstack/flutter_libmonero/blob/2c684cedba6c3d9353c7ea748cadb5a246008027/cw_wownero/ios/Classes/wownero_api.cpp#L240
// this code slightly goes against the way of being simple
void* WOWNERO_deprecated_restore14WordSeed(char *path, char *password, char *seed, int32_t networkType) {
    DEBUG_START()
    Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();
    try {
        Monero::NetworkType _networkType = static_cast<Monero::NetworkType>(networkType);

        // 14 word seeds /*
        wownero_seed wow_seed(seed, "wownero");

        std::stringstream seed_stream;
        seed_stream << wow_seed;
        std::string seed_str = seed_stream.str();

        std::stringstream key_stream;
        key_stream << wow_seed.key();
        std::string spendKey = key_stream.str();

        uint64_t restoreHeight = wow_seed.blockheight();

        Monero::Wallet *wallet = walletManager->createDeterministicWalletFromSpendKey(
            std::string(path),
            std::string(password),
            "English",
            static_cast<Monero::NetworkType>(_networkType),
            (uint64_t)restoreHeight,
            spendKey,
            1);
        wallet->setCacheAttribute("cake.seed", seed_str);
        return reinterpret_cast<void*>(wallet);
    } catch (...) {
        // fallback code so wallet->status() returns at least something.. eh..
        Monero::Wallet *wallet = walletManager->recoveryWallet(
                    "/",
                    "",
                    "invalid mnemonic",
                    static_cast<Monero::NetworkType>(networkType),
                    0,
                    1,
                    "");
        return reinterpret_cast<void*>(wallet);
    }
    DEBUG_END()
}

uint64_t WOWNERO_deprecated_14WordSeedHeight(char *seed) {
    DEBUG_START()
    wownero_seed wow_seed(seed, "wownero");
    return wow_seed.blockheight();
    DEBUG_END()
}

void* WOWNERO_deprecated_create14WordSeed(char *path, char *password, char *language, int32_t networkType) {
    DEBUG_START()
    Monero::NetworkType _networkType = static_cast<Monero::NetworkType>(networkType);
    Monero::WalletManager *walletManager = Monero::WalletManagerFactory::getWalletManager();

    // 14 word seeds /*
    time_t time = std::time(nullptr);
    wownero_seed wow_seed(time, "wownero");

    std::stringstream seed_stream;
    seed_stream << wow_seed;
    std::string seed = seed_stream.str();

    std::stringstream key_stream;
    key_stream << wow_seed.key();
    std::string spendKey = key_stream.str();

    uint64_t restoreHeight = wow_seed.blockheight();

    Monero::Wallet *wallet = walletManager->createDeterministicWalletFromSpendKey(
        std::string(path),
        std::string(password),
        std::string(language),
        static_cast<Monero::NetworkType>(_networkType),
        (uint64_t)restoreHeight,
        spendKey,
        1);
    wallet->setCacheAttribute("cake.seed", seed);
    return reinterpret_cast<void*>(wallet);
    DEBUG_END()
}

const char* WOWNERO_checksum_wallet2_api_c_h() {
    return WOWNERO_wallet2_api_c_h_sha256;
}
const char* WOWNERO_checksum_wallet2_api_c_cpp() {
    return WOWNERO_wallet2_api_c_cpp_sha256;
}
const char* WOWNERO_checksum_wallet2_api_c_exp() {
    return WOWNERO_wallet2_api_c_exp_sha256;
}
// i hate windows

void WOWNERO_free(void* ptr) {
    free(ptr);
}

#ifdef __cplusplus
}
#endif
