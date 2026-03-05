library;

// Are we memory safe?
// There is a simple way to check that:
// 1) Rewrite everything in rust
// Or, assuming we are sane
// 1) grep -E 'toNative|^String ' lib/beldex.dart | grep -v '^//' | grep -v '^String libPath = ' | wc -l
//    This will print number of all things that produce pointers
// 2) grep .free lib/beldex.dart | grep -v '^//' | wc -l
//    This will print number of all free calls, these numbers should match

// Wrapper around generated_bindings.g.dart - to provide easy access to the
// underlying functions, feel free to not use it at all.

//  _____________ PendingTransaction is just a typedef for Pointer<Void> (which is void* on C side)
// /                   _____________ Wallet class, we didn't specify the BELDEX prefix because we import the beldex.dart code with beldex prefix
// |                  /       _____________ createTransaction function, from the upstream in the class Wallet
// |                  |      /
// PendingTransaction Wallet_createTransaction(wallet ptr, <------------- wallet is a typedef for Pointer<Void>
//     {required String dst_addr,--------------------------------\ All of the parameters that are used in this function
//     required String payment_id,                  _____________/ String - will get casted into const char*
//     required int amount,                        /
//     required int mixin_count,                  /                int - goes as it is
//     required int pendingTransactionPriority,  /
//     required int subaddr_account,            /
//     List<String> preferredInputs = const []}) {                 List<String> - gets joined and passed as 2 separate parameters to be split in the C side____
//   debugStart?.call('BELDEX_Wallet_createTransaction'); <------------- debugStart functions just marks the function as currently being executed, used        |
//   lib ??= BeldexC(DynamicLibrary.open(libPath));                    \_for performance debugging                                                             |
//   \_____________ Load the library in case it is not loaded                                                                                                  |
//   final dst_addr_ = dst_addr.toNativeUtf8().cast<Char>(); -----------------| Cast the strings into Chars so it can be used as a parameter in a function     |
//   final payment_id_ = payment_id.toNativeUtf8().cast<Char>(); -------------| generated via ffigen                                                           |
//   final preferredInputs_ = preferredInputs.join(defaultSeparatorStr).toNativeUtf8().cast<Char>(); <---------------------------------------------------------/
//   final s = lib!.BELDEX_Wallet_createTransaction(-------------|
//     ptr,                                                       |
//     dst_addr_,                                                 |
//     payment_id_,                                               |
//     amount,                                                    |
//     mixin_count,                                               | Call the native function using generated code
//     pendingTransactionPriority,                                |
//     subaddr_account,                                           |
//     preferredInputs_,                                          |
//     defaultSeparator,                                          |
//   );___________________________________________________________/
//   calloc.free(dst_addr_);---------------| Free the memory once we don't need it
//   calloc.free(payment_id_);-------------|
//   debugEnd?.call('BELDEX_Wallet_createTransaction'); <------------- Mark the function as executed
//   return s; <------------- return the value
// }
//
// Extra case is happening when we have a function call that returns const char* as we have to be memory safe
// String PendingTransaction_txid(PendingTransaction ptr, String separator) {
//   debugStart?.call('BELDEX_PendingTransaction_txid');
//   lib ??= BeldexC(DynamicLibrary.open(libPath));
//   final separator_ = separator.toNativeUtf8().cast<Char>();
//   final txid = lib!.BELDEX_PendingTransaction_txid(ptr, separator_);
//   calloc.free(separator_);
//   debugEnd?.call('BELDEX_PendingTransaction_txid');
//   try { <------------- We need to try-catch these calls because they may fail in an unlikely case when we get an invalid UTF-8 string,
//     final strPtr = txid.cast<Utf8>();                                            it is better to throw than to crash main isolate imo.
//     final str = strPtr.toDartString(); <------------- convert the pointer to const char* to dart String
//     BELDEX_free(strPtr.cast()); <------------- free the memory
//     debugEnd?.call('BELDEX_PendingTransaction_txid');
//     return str; <------------- return the value
//   } catch (e) {
//     errorHandler?.call('BELDEX_PendingTransaction_txid', e);
//     debugEnd?.call('BELDEX_PendingTransaction_txid');
//     return ""; <------------- return an empty string in case of an error.
//   }
// }
//

// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:monero/src/generated_bindings_beldex.g.dart';

export 'src/checksum_beldex.dart';

typedef PendingTransaction = Pointer<Void>;

BeldexC? lib;
String libPath = (() {
  if (Platform.isWindows) return 'beldex_libwallet2_api_c.dll';
  if (Platform.isMacOS) return 'beldex_libwallet2_api_c.dylib';
  if (Platform.isIOS) return 'BeldexWallet.framework/BeldexWallet';
  if (Platform.isAndroid) return 'libbeldex_libwallet2_api_c.so';
  return 'beldex_libwallet2_api_c.so';
})();

Map<String, List<int>> debugCallLength = {};

final defaultSeparatorStr = ";";
final defaultSeparator = defaultSeparatorStr.toNativeUtf8().cast<Char>();
/* we don't call .free here, this comment serves one purpose - so the numbers match :) */

final Stopwatch sw = Stopwatch()..start();

bool printStarts = false;

void Function(String call)? debugStart = (call) {
  try {
    if (printStarts) print("BELDEX: $call");
    debugCallLength[call] ??= <int>[];
    debugCallLength[call]!.add(sw.elapsedMicroseconds);
  } catch (e) {}
};
void debugChores() {
  for (var key in debugCallLength.keys) {
    if (debugCallLength[key]!.length > 1000000) {
      final elm =
          debugCallLength[key]!.reduce((value, element) => value + element);
      debugCallLength[key]!.clear();
      debugCallLength["${key}_1M"] ??= <int>[];
      debugCallLength["${key}_1M"]!.add(elm);
    }
  }
}

int debugCount = 0;

void Function(String call)? debugEnd = (call) {
  try {
    final id = debugCallLength[call]!.length - 1;
    if (++debugCount > 1000000) {
      debugCount = 0;
      debugChores();
    }
    debugCallLength[call]![id] =
        sw.elapsedMicroseconds - debugCallLength[call]![id];
  } catch (e) {}
};
void Function(String call, dynamic error)? errorHandler = (call, error) {
  print("$call: $error");
};
@Deprecated("TODO")
int PendingTransaction_status(PendingTransaction ptr) {
  debugStart?.call('BELDEX_PendingTransaction_status');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_PendingTransaction_status(ptr);
  debugEnd?.call('BELDEX_PendingTransaction_status');
  return status;
}

@Deprecated("TODO")
String PendingTransaction_errorString(PendingTransaction ptr) {
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  debugStart?.call('BELDEX_PendingTransaction_errorString');
  try {
    final rPtr = lib!.BELDEX_PendingTransaction_errorString(ptr).cast<Utf8>();
    final str = rPtr.toDartString();
    BELDEX_free(rPtr.cast());
    debugEnd?.call('BELDEX_PendingTransaction_errorString');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_errorString', e);
    debugEnd?.call('BELDEX_PendingTransaction_errorString');
    return "";
  }
}

@Deprecated("TODO")
bool PendingTransaction_commit(PendingTransaction ptr,
    {required String filename, required bool overwrite}) {
  debugStart?.call('BELDEX_PendingTransaction_commit');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final filename_ = filename.toNativeUtf8().cast<Char>();
  final result =
      lib!.BELDEX_PendingTransaction_commit(ptr, filename_, overwrite);
  calloc.free(filename_);
  debugEnd?.call('BELDEX_PendingTransaction_commit');
  return result;
}

@Deprecated("TODO")
String PendingTransaction_commitUR(
    PendingTransaction ptr, int max_fragment_length) {
  debugStart?.call('BELDEX_PendingTransaction_commitUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final txid =
      lib!.BELDEX_PendingTransaction_commitUR(ptr, max_fragment_length);
  debugEnd?.call('BELDEX_PendingTransaction_commitUR');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_PendingTransaction_commitUR');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_commitUR', e);
    debugEnd?.call('BELDEX_PendingTransaction_commitUR');
    return "";
  }
}

@Deprecated("TODO")
int PendingTransaction_amount(PendingTransaction ptr) {
  debugStart?.call('BELDEX_PendingTransaction_amount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final amount = lib!.BELDEX_PendingTransaction_amount(ptr);
  debugEnd?.call('BELDEX_PendingTransaction_amount');
  return amount;
}

@Deprecated("TODO")
int PendingTransaction_dust(PendingTransaction ptr) {
  debugStart?.call('BELDEX_PendingTransaction_dust');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final dust = lib!.BELDEX_PendingTransaction_dust(ptr);
  debugEnd?.call('BELDEX_PendingTransaction_dust');
  return dust;
}

@Deprecated("TODO")
int PendingTransaction_fee(PendingTransaction ptr) {
  debugStart?.call('BELDEX_PendingTransaction_fee');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final fee = lib!.BELDEX_PendingTransaction_fee(ptr);
  debugEnd?.call('BELDEX_PendingTransaction_fee');
  return fee;
}

@Deprecated("TODO")
String PendingTransaction_txid(PendingTransaction ptr, String separator) {
  debugStart?.call('BELDEX_PendingTransaction_txid');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final separator_ = separator.toNativeUtf8().cast<Char>();
  final txid = lib!.BELDEX_PendingTransaction_txid(ptr, separator_);
  calloc.free(separator_);
  debugEnd?.call('BELDEX_PendingTransaction_txid');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_PendingTransaction_txid');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_txid', e);
    debugEnd?.call('BELDEX_PendingTransaction_txid');
    return "";
  }
}

@Deprecated("TODO")
int PendingTransaction_txCount(PendingTransaction ptr) {
  debugStart?.call('BELDEX_PendingTransaction_txCount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final txCount = lib!.BELDEX_PendingTransaction_txCount(ptr);
  debugEnd?.call('BELDEX_PendingTransaction_txCount');
  return txCount;
}

@Deprecated("TODO")
String PendingTransaction_subaddrAccount(
    PendingTransaction ptr, String separator) {
  debugStart?.call('BELDEX_PendingTransaction_subaddrAccount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final separator_ = separator.toNativeUtf8().cast<Char>();
  final txid = lib!.BELDEX_PendingTransaction_subaddrAccount(ptr, separator_);
  calloc.free(separator_);
  debugEnd?.call('BELDEX_PendingTransaction_subaddrAccount');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_PendingTransaction_subaddrAccount');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_subaddrAccount', e);
    debugEnd?.call('BELDEX_PendingTransaction_subaddrAccount');
    return "";
  }
}

@Deprecated("TODO")
String PendingTransaction_subaddrIndices(
    PendingTransaction ptr, String separator) {
  debugStart?.call('BELDEX_PendingTransaction_subaddrIndices');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final separator_ = separator.toNativeUtf8().cast<Char>();
  final txid = lib!.BELDEX_PendingTransaction_subaddrIndices(ptr, separator_);
  calloc.free(separator_);
  debugEnd?.call('BELDEX_PendingTransaction_subaddrIndices');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_PendingTransaction_subaddrIndices');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_subaddrIndices', e);
    debugEnd?.call('BELDEX_PendingTransaction_subaddrIndices');
    return "";
  }
}

@Deprecated("TODO")
String PendingTransaction_multisigSignData(PendingTransaction ptr) {
  debugStart?.call('BELDEX_PendingTransaction_multisigSignData');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final txid = lib!.BELDEX_PendingTransaction_multisigSignData(ptr);
  debugEnd?.call('BELDEX_PendingTransaction_multisigSignData');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_PendingTransaction_multisigSignData');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_multisigSignData', e);
    debugEnd?.call('BELDEX_PendingTransaction_multisigSignData');
    return "";
  }
}

@Deprecated("TODO")
void PendingTransaction_signMultisigTx(PendingTransaction ptr) {
  debugStart?.call('BELDEX_PendingTransaction_signMultisigTx');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_PendingTransaction_signMultisigTx(ptr);
  debugEnd?.call('BELDEX_PendingTransaction_signMultisigTx');
  return ret;
}

@Deprecated("TODO")
String PendingTransaction_signersKeys(
    PendingTransaction ptr, String separator) {
  debugStart?.call('BELDEX_PendingTransaction_signersKeys');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final separator_ = separator.toNativeUtf8().cast<Char>();
  final txid = lib!.BELDEX_PendingTransaction_signersKeys(ptr, separator_);
  calloc.free(separator_);
  debugEnd?.call('BELDEX_PendingTransaction_signersKeys');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    debugEnd?.call('BELDEX_PendingTransaction_signersKeys');
    BELDEX_free(strPtr.cast());
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_signersKeys', e);
    debugEnd?.call('BELDEX_PendingTransaction_signersKeys');
    return "";
  }
}

@Deprecated("TODO")
String PendingTransaction_hex(PendingTransaction ptr, String separator) {
  debugStart?.call('BELDEX_PendingTransaction_hex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final separator_ = separator.toNativeUtf8().cast<Char>();
  final txid = lib!.BELDEX_PendingTransaction_hex(ptr, separator_);
  calloc.free(separator_);
  debugEnd?.call('BELDEX_PendingTransaction_hex');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    debugEnd?.call('BELDEX_PendingTransaction_hex');
    BELDEX_free(strPtr.cast());
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_PendingTransaction_hex', e);
    debugEnd?.call('BELDEX_PendingTransaction_hex');
    return "";
  }
}

// UnsignedTransaction

typedef UnsignedTransaction = Pointer<Void>;

@Deprecated("TODO")
int UnsignedTransaction_status(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_status');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final dust = lib!.BELDEX_UnsignedTransaction_status(ptr);
  debugStart?.call('BELDEX_UnsignedTransaction_status');
  return dust;
}

@Deprecated("TODO")
String UnsignedTransaction_errorString(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_errorString');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final errorString = lib!.BELDEX_UnsignedTransaction_errorString(ptr);
  try {
    final strPtr = errorString.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_errorString');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_errorString', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_errorString');
    return "";
  }
}

@Deprecated("TODO")
String UnsignedTransaction_amount(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_amount');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final errorString =
      lib!.BELDEX_UnsignedTransaction_amount(ptr, defaultSeparator);
  try {
    final strPtr = errorString.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_amount');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_amount', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_amount');
    return "";
  }
}

@Deprecated("TODO")
String UnsignedTransaction_fee(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_fee');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final errorString =
      lib!.BELDEX_UnsignedTransaction_fee(ptr, defaultSeparator);
  try {
    final strPtr = errorString.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_fee');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_fee', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_fee');
    return "";
  }
}

@Deprecated("TODO")
String UnsignedTransaction_mixin(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_mixin');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final errorString =
      lib!.BELDEX_UnsignedTransaction_mixin(ptr, defaultSeparator);
  try {
    final strPtr = errorString.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_mixin');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_mixin', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_mixin');
    return "";
  }
}

@Deprecated("TODO")
String UnsignedTransaction_confirmationMessage(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_confirmationMessage');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final errorString = lib!.BELDEX_UnsignedTransaction_confirmationMessage(ptr);
  try {
    final strPtr = errorString.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_confirmationMessage');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_confirmationMessage', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_confirmationMessage');
    return "";
  }
}

@Deprecated("TODO")
String UnsignedTransaction_paymentId(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_paymentId');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final errorString =
      lib!.BELDEX_UnsignedTransaction_paymentId(ptr, defaultSeparator);
  try {
    final strPtr = errorString.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_paymentId');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_paymentId', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_paymentId');
    return "";
  }
}

@Deprecated("TODO")
String UnsignedTransaction_recipientAddress(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_recipientAddress');

  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final errorString =
      lib!.BELDEX_UnsignedTransaction_recipientAddress(ptr, defaultSeparator);
  try {
    final strPtr = errorString.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_recipientAddress');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_recipientAddress', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_recipientAddress');
    return "";
  }
}

@Deprecated("TODO")
int UnsignedTransaction_minMixinCount(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_minMixinCount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_UnsignedTransaction_minMixinCount(ptr);
  debugEnd?.call('BELDEX_UnsignedTransaction_minMixinCount');
  return v;
}

@Deprecated("TODO")
int UnsignedTransaction_txCount(UnsignedTransaction ptr) {
  debugStart?.call('BELDEX_UnsignedTransaction_txCount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_UnsignedTransaction_txCount(ptr);
  debugEnd?.call('BELDEX_UnsignedTransaction_txCount');
  return v;
}

@Deprecated("TODO")
bool UnsignedTransaction_sign(UnsignedTransaction ptr, String signedFileName) {
  debugStart?.call('BELDEX_UnsignedTransaction_sign');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final signedFileName_ = signedFileName.toNativeUtf8().cast<Char>();
  final v = lib!.BELDEX_UnsignedTransaction_sign(ptr, signedFileName_);
  calloc.free(signedFileName_);
  debugEnd?.call('BELDEX_UnsignedTransaction_sign');
  return v;
}

@Deprecated("TODO")
String UnsignedTransaction_signUR(
    PendingTransaction ptr, int max_fragment_length) {
  debugStart?.call('BELDEX_UnsignedTransaction_signUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final txid = lib!.BELDEX_UnsignedTransaction_signUR(ptr, max_fragment_length);
  debugEnd?.call('BELDEX_UnsignedTransaction_signUR');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_UnsignedTransaction_signUR');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_UnsignedTransaction_signUR', e);
    debugEnd?.call('BELDEX_UnsignedTransaction_signUR');
    return "";
  }
}

// TransactionInfo

typedef TransactionInfo = Pointer<Void>;

enum TransactionInfo_Direction { In, Out }

@Deprecated("TODO")
TransactionInfo_Direction TransactionInfo_direction(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_direction');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final tiDir = TransactionInfo_Direction
      .values[lib!.BELDEX_TransactionInfo_direction(ptr)];
  debugEnd?.call('BELDEX_TransactionInfo_direction');
  return tiDir;
}

@Deprecated("TODO")
bool TransactionInfo_isPending(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_isPending');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final isPending = lib!.BELDEX_TransactionInfo_isPending(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_isPending');

  return isPending;
}

@Deprecated("TODO")
bool TransactionInfo_isFailed(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_isFailed');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final isFailed = lib!.BELDEX_TransactionInfo_isFailed(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_isFailed');
  return isFailed;
}

@Deprecated("TODO")
bool TransactionInfo_isCoinbase(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_isCoinbase');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final isCoinbase = lib!.BELDEX_TransactionInfo_isCoinbase(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_isCoinbase');
  return isCoinbase;
}

@Deprecated("TODO")
int TransactionInfo_amount(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_amount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final amount = lib!.BELDEX_TransactionInfo_amount(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_amount');
  return amount;
}

@Deprecated("TODO")
int TransactionInfo_fee(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_fee');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final fee = lib!.BELDEX_TransactionInfo_fee(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_fee');
  return fee;
}

@Deprecated("TODO")
int TransactionInfo_blockHeight(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_blockHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final blockHeight = lib!.BELDEX_TransactionInfo_blockHeight(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_blockHeight');
  return blockHeight;
}

@Deprecated("TODO")
String TransactionInfo_description(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_description');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_TransactionInfo_description(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_TransactionInfo_description');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_TransactionInfo_description', e);
    return "";
  }
}

@Deprecated("TODO")
String TransactionInfo_subaddrIndex(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_subaddrIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_TransactionInfo_subaddrIndex(ptr, defaultSeparator)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_TransactionInfo_subaddrIndex');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_TransactionInfo_subaddrIndex', e);
    return "";
  }
}

@Deprecated("TODO")
int TransactionInfo_subaddrAccount(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_subaddrAccount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final subaddrAccount = lib!.BELDEX_TransactionInfo_subaddrAccount(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_subaddrAccount');
  return subaddrAccount;
}

@Deprecated("TODO")
String TransactionInfo_label(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_label');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_TransactionInfo_label(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_TransactionInfo_label');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_TransactionInfo_label', e);
    debugEnd?.call('BELDEX_TransactionInfo_label');
    return "";
  }
}

@Deprecated("TODO")
int TransactionInfo_confirmations(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_confirmations');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final confirmations = lib!.BELDEX_TransactionInfo_confirmations(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_confirmations');
  return confirmations;
}

@Deprecated("TODO")
int TransactionInfo_unlockTime(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_unlockTime');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final unlockTime = lib!.BELDEX_TransactionInfo_unlockTime(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_unlockTime');
  return unlockTime;
}

@Deprecated("TODO")
String TransactionInfo_hash(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_hash');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_TransactionInfo_hash(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_TransactionInfo_hash');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_TransactionInfo_hash', e);
    debugEnd?.call('BELDEX_TransactionInfo_hash');
    return "";
  }
}

@Deprecated("TODO")
int TransactionInfo_timestamp(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_timestamp');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final timestamp = lib!.BELDEX_TransactionInfo_timestamp(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_timestamp');
  return timestamp;
}

@Deprecated("TODO")
String TransactionInfo_paymentId(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_paymentId');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_TransactionInfo_paymentId(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_TransactionInfo_paymentId');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_TransactionInfo_paymentId', e);
    debugEnd?.call('BELDEX_TransactionInfo_paymentId');
    return "";
  }
}

@Deprecated("TODO")
int TransactionInfo_transfers_count(TransactionInfo ptr) {
  debugStart?.call('BELDEX_TransactionInfo_transfers_count');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_TransactionInfo_transfers_count(ptr);
  debugEnd?.call('BELDEX_TransactionInfo_transfers_count');
  return v;
}

@Deprecated("TODO")
int TransactionInfo_transfers_amount(TransactionInfo ptr, int index) {
  debugStart?.call('BELDEX_TransactionInfo_transfers_amount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_TransactionInfo_transfers_amount(ptr, index);
  debugEnd?.call('BELDEX_TransactionInfo_transfers_amount');
  return v;
}

@Deprecated("TODO")
String TransactionInfo_transfers_address(TransactionInfo ptr, int index) {
  debugStart?.call('BELDEX_TransactionInfo_transfers_address');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_TransactionInfo_transfers_address(ptr, index).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_TransactionInfo_transfers_address');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_TransactionInfo_transfers_address', e);
    debugEnd?.call('BELDEX_TransactionInfo_transfers_address');
    return "";
  }
}

// TransactionHistory

typedef TransactionHistory = Pointer<Void>;

@Deprecated("TODO")
int TransactionHistory_count(TransactionHistory txHistory_ptr) {
  debugStart?.call('BELDEX_TransactionHistory_count');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final count = lib!.BELDEX_TransactionHistory_count(txHistory_ptr);
  debugEnd?.call('BELDEX_TransactionHistory_count');
  return count;
}

@Deprecated("TODO")
TransactionInfo TransactionHistory_transaction(TransactionHistory txHistory_ptr,
    {required int index}) {
  debugStart?.call('BELDEX_TransactionHistory_transaction');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final transaction =
      lib!.BELDEX_TransactionHistory_transaction(txHistory_ptr, index);
  debugEnd?.call('BELDEX_TransactionHistory_transaction');
  return transaction;
}

@Deprecated("TODO")
TransactionInfo TransactionHistory_transactionById(
    TransactionHistory txHistory_ptr,
    {required String txid}) {
  debugStart?.call('BELDEX_TransactionHistory_transactionById');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final txid_ = txid.toNativeUtf8().cast<Char>();
  final transaction =
      lib!.BELDEX_TransactionHistory_transactionById(txHistory_ptr, txid_);
  calloc.free(txid_);
  debugEnd?.call('BELDEX_TransactionHistory_transactionById');
  return transaction;
}

@Deprecated("TODO")
void TransactionHistory_refresh(TransactionHistory txHistory_ptr) {
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  return lib!.BELDEX_TransactionHistory_refresh(txHistory_ptr);
}

@Deprecated("TODO")
void TransactionHistory_setTxNote(TransactionHistory txHistory_ptr,
    {required String txid, required String note}) {
  debugStart?.call('BELDEX_TransactionHistory_setTxNote');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final txid_ = txid.toNativeUtf8().cast<Char>();
  final note_ = note.toNativeUtf8().cast<Char>();
  final s =
      lib!.BELDEX_TransactionHistory_setTxNote(txHistory_ptr, txid_, note_);
  calloc.free(txid_);
  calloc.free(note_);
  debugEnd?.call('BELDEX_TransactionHistory_setTxNote');
  return s;
}

// AddresBookRow

typedef AddressBookRow = Pointer<Void>;

@Deprecated("TODO")
String AddressBookRow_extra(AddressBookRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_AddressBookRow_extra');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_AddressBookRow_extra(addressBookRow_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_AddressBookRow_extra');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_AddressBookRow_extra', e);
    debugEnd?.call('BELDEX_AddressBookRow_extra');
    return "";
  }
}

@Deprecated("TODO")
String AddressBookRow_getAddress(AddressBookRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_AddressBookRow_getAddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_AddressBookRow_getAddress(addressBookRow_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_AddressBookRow_getAddress');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_AddressBookRow_getAddress', e);
    debugEnd?.call('BELDEX_AddressBookRow_getAddress');
    return "";
  }
}

@Deprecated("TODO")
String AddressBookRow_getDescription(AddressBookRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_AddressBookRow_getDescription');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_AddressBookRow_getDescription(addressBookRow_ptr)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_AddressBookRow_getDescription');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_AddressBookRow_getDescription', e);
    debugEnd?.call('BELDEX_AddressBookRow_getDescription');
    return "";
  }
}

@Deprecated("TODO")
int AddressBookRow_getRowId(AddressBookRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_AddressBookRow_getRowId');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_AddressBookRow_getRowId(addressBookRow_ptr);
  debugEnd?.call('BELDEX_AddressBookRow_getRowId');
  return v;
}

// AddressBook

typedef AddressBook = Pointer<Void>;

@Deprecated("TODO")
int AddressBook_getAll_size(AddressBook addressBook_ptr) {
  debugStart?.call('BELDEX_AddressBook_getAll_size');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_AddressBook_getAll_size(addressBook_ptr);
  debugEnd?.call('BELDEX_AddressBook_getAll_size');
  return v;
}

@Deprecated("TODO")
AddressBookRow AddressBook_getAll_byIndex(AddressBook addressBook_ptr,
    {required int index}) {
  debugStart?.call('BELDEX_AddressBook_getAll_byIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_AddressBook_getAll_byIndex(addressBook_ptr, index);
  debugEnd?.call('BELDEX_AddressBook_getAll_byIndex');
  return v;
}

@Deprecated("TODO")
bool AddressBook_addRow(
  AddressBook addressBook_ptr, {
  required String dstAddr,
  required String paymentId,
  required String description,
}) {
  debugStart?.call('BELDEX_AddressBook_addRow');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final dst_addr_ = dstAddr.toNativeUtf8().cast<Char>();
  final payment_id_ = paymentId.toNativeUtf8().cast<Char>();
  final description_ = description.toNativeUtf8().cast<Char>();
  final v = lib!.BELDEX_AddressBook_addRow(
      addressBook_ptr, dst_addr_, payment_id_, description_);
  calloc.free(dst_addr_);
  calloc.free(payment_id_);
  calloc.free(description_);
  debugEnd?.call('BELDEX_AddressBook_addRow');
  return v;
}

@Deprecated("TODO")
bool AddressBook_deleteRow(AddressBook addressBook_ptr, {required int rowId}) {
  debugStart?.call('BELDEX_AddressBook_deleteRow');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_AddressBook_deleteRow(addressBook_ptr, rowId);
  debugEnd?.call('BELDEX_AddressBook_deleteRow');
  return v;
}

@Deprecated("TODO")
bool AddressBook_setDescription(
  AddressBook addressBook_ptr, {
  required int rowId,
  required String description,
}) {
  debugStart?.call('BELDEX_AddressBook_setDescription');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final description_ = description.toNativeUtf8().cast<Char>();
  final v = lib!
      .BELDEX_AddressBook_setDescription(addressBook_ptr, rowId, description_);
  calloc.free(description_);
  debugEnd?.call('BELDEX_AddressBook_setDescription');
  return v;
}

@Deprecated("TODO")
void AddressBook_refresh(AddressBook addressBook_ptr) {
  debugStart?.call('BELDEX_AddressBook_refresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_AddressBook_refresh(addressBook_ptr);
  debugEnd?.call('BELDEX_AddressBook_refresh');
  return v;
}

@Deprecated("TODO")
int AddressBook_errorCode(AddressBook addressBook_ptr) {
  debugStart?.call('BELDEX_AddressBook_errorCode');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_AddressBook_errorCode(addressBook_ptr);
  debugEnd?.call('BELDEX_AddressBook_errorCode');
  return v;
}

// CoinsInfo
typedef CoinsInfo = Pointer<Void>;

@Deprecated("TODO")
int CoinsInfo_blockHeight(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_blockHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_blockHeight(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_blockHeight');
  return v;
}

@Deprecated("TODO")
String CoinsInfo_hash(CoinsInfo addressBookRow_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_hash');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_CoinsInfo_hash(addressBookRow_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_CoinsInfo_hash');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_CoinsInfo_hash', e);
    debugEnd?.call('BELDEX_CoinsInfo_hash');
    return "";
  }
}

@Deprecated("TODO")
int CoinsInfo_internalOutputIndex(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_internalOutputIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_internalOutputIndex(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_internalOutputIndex');
  return v;
}

@Deprecated("TODO")
int CoinsInfo_globalOutputIndex(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_globalOutputIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_globalOutputIndex(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_globalOutputIndex');
  return v;
}

@Deprecated("TODO")
bool CoinsInfo_spent(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_spent');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_spent(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_spent');
  return v;
}

@Deprecated("TODO")
bool CoinsInfo_frozen(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_frozen');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_frozen(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_frozen');
  return v;
}

@Deprecated("TODO")
int CoinsInfo_spentHeight(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_spentHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_spentHeight(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_spentHeight');
  return v;
}

@Deprecated("TODO")
int CoinsInfo_amount(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_amount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_amount(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_amount');
  return v;
}

@Deprecated("TODO")
bool CoinsInfo_rct(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_rct');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_rct(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_rct');
  return v;
}

@Deprecated("TODO")
bool CoinsInfo_keyImageKnown(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_keyImageKnown');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_keyImageKnown(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_keyImageKnown');
  return v;
}

@Deprecated("TODO")
int CoinsInfo_pkIndex(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_pkIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_pkIndex(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_pkIndex');
  return v;
}

@Deprecated("TODO")
int CoinsInfo_subaddrIndex(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_subaddrIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_subaddrIndex(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_subaddrIndex');
  return v;
}

@Deprecated("TODO")
int CoinsInfo_subaddrAccount(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_subaddrAccount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_subaddrAccount(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_subaddrAccount');
  return v;
}

@Deprecated("TODO")
String CoinsInfo_address(CoinsInfo addressBookRow_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_address');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_CoinsInfo_address(addressBookRow_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_CoinsInfo_address');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_CoinsInfo_address', e);
    debugEnd?.call('BELDEX_CoinsInfo_address');
    return "";
  }
}

@Deprecated("TODO")
String CoinsInfo_addressLabel(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_addressLabel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_CoinsInfo_addressLabel(coinsInfo_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_CoinsInfo_addressLabel');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_CoinsInfo_addressLabel', e);
    debugEnd?.call('BELDEX_CoinsInfo_addressLabel');
    return "";
  }
}

@Deprecated("TODO")
String CoinsInfo_keyImage(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_keyImage');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_CoinsInfo_keyImage(coinsInfo_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_CoinsInfo_keyImage');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_CoinsInfo_keyImage', e);
    debugEnd?.call('BELDEX_CoinsInfo_keyImage');
    return "";
  }
}

@Deprecated("TODO")
int CoinsInfo_unlockTime(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_unlockTime');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_unlockTime(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_unlockTime');
  return v;
}

@Deprecated("TODO")
bool CoinsInfo_unlocked(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_unlocked');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_unlocked(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_unlocked');
  return v;
}

@Deprecated("TODO")
String CoinsInfo_pubKey(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_pubKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_CoinsInfo_pubKey(coinsInfo_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_CoinsInfo_pubKey');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_CoinsInfo_pubKey', e);
    debugEnd?.call('BELDEX_CoinsInfo_pubKey');
    return "";
  }
}

@Deprecated("TODO")
bool CoinsInfo_coinbase(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_coinbase');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_CoinsInfo_coinbase(coinsInfo_ptr);
  debugEnd?.call('BELDEX_CoinsInfo_coinbase');
  return v;
}

@Deprecated("TODO")
String CoinsInfo_description(CoinsInfo coinsInfo_ptr) {
  debugStart?.call('BELDEX_CoinsInfo_description');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_CoinsInfo_description(coinsInfo_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_CoinsInfo_description');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_CoinsInfo_description', e);
    debugEnd?.call('BELDEX_CoinsInfo_description');
    return "";
  }
}

@Deprecated("TODO")
typedef Coins = Pointer<Void>;

@Deprecated("TODO")
int Coins_count(Coins coins_ptr) {
  debugStart?.call('BELDEX_Coins_count');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Coins_count(coins_ptr);
  debugEnd?.call('BELDEX_Coins_count');
  return v;
}

@Deprecated("TODO")
CoinsInfo Coins_coin(Coins coins_ptr, int index) {
  debugStart?.call('BELDEX_Coins_coin');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Coins_coin(coins_ptr, index);
  debugEnd?.call('BELDEX_Coins_coin');
  return v;
}

@Deprecated("TODO")
int Coins_getAll_size(Coins coins_ptr) {
  debugStart?.call('BELDEX_Coins_getAll_size');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Coins_getAll_size(coins_ptr);
  debugEnd?.call('BELDEX_Coins_getAll_size');
  return v;
}

@Deprecated("TODO")
CoinsInfo Coins_getAll_byIndex(Coins coins_ptr, int index) {
  debugStart?.call('BELDEX_Coins_getAll_byIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Coins_getAll_byIndex(coins_ptr, index);
  debugEnd?.call('BELDEX_Coins_getAll_byIndex');
  return v;
}

@Deprecated("TODO")
void Coins_refresh(Coins coins_ptr) {
  debugStart?.call('BELDEX_Coins_refresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Coins_refresh(coins_ptr);
  debugEnd?.call('BELDEX_Coins_refresh');
  return v;
}

@Deprecated("TODO")
void Coins_setFrozenByPublicKey(Coins coins_ptr, {required String publicKey}) {
  debugStart?.call('BELDEX_Coins_setFrozenByPublicKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final publicKey_ = publicKey.toNativeUtf8().cast<Char>();
  final v = lib!.BELDEX_Coins_setFrozenByPublicKey(coins_ptr, publicKey_);
  calloc.free(publicKey_);
  debugEnd?.call('BELDEX_Coins_setFrozenByPublicKey');
  return v;
}

@Deprecated("TODO")
void Coins_setFrozen(Coins coins_ptr, {required int index}) {
  debugStart?.call('BELDEX_Coins_setFrozen');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Coins_setFrozen(coins_ptr, index);
  debugEnd?.call('BELDEX_Coins_setFrozen');
  return v;
}

@Deprecated("TODO")
void Coins_thaw(Coins coins_ptr, {required int index}) {
  debugStart?.call('BELDEX_Coins_thaw');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Coins_thaw(coins_ptr, index);
  debugEnd?.call('BELDEX_Coins_thaw');
  return v;
}

@Deprecated("TODO")
void Coins_thawByPublicKey(Coins coins_ptr, {required String publicKey}) {
  debugStart?.call('BELDEX_Coins_thawByPublicKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final publicKey_ = publicKey.toNativeUtf8().cast<Char>();
  final v = lib!.BELDEX_Coins_thawByPublicKey(coins_ptr, publicKey_);
  calloc.free(publicKey_);
  debugEnd?.call('BELDEX_Coins_thawByPublicKey');
  return v;
}

@Deprecated("TODO")
bool Coins_isTransferUnlocked(
  Coins coins_ptr, {
  required int unlockTime,
  required int blockHeight,
}) {
  debugStart?.call('BELDEX_Coins_isTransferUnlocked');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v =
      lib!.BELDEX_Coins_isTransferUnlocked(coins_ptr, unlockTime, blockHeight);
  debugEnd?.call('BELDEX_Coins_isTransferUnlocked');
  return v;
}

@Deprecated("TODO")
// SubaddressRow

typedef SubaddressRow = Pointer<Void>;

@Deprecated("TODO")
String SubaddressRow_extra(SubaddressRow subaddressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressRow_extra');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_SubaddressRow_extra(subaddressBookRow_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressRow_extra');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressRow_extra', e);
    debugEnd?.call('BELDEX_SubaddressRow_extra');
    return "";
  }
}

@Deprecated("TODO")
String SubaddressRow_getAddress(SubaddressRow subaddressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressRow_getAddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_SubaddressRow_getAddress(subaddressBookRow_ptr)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressRow_getAddress');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressRow_getAddress', e);
    debugEnd?.call('BELDEX_SubaddressRow_getAddress');
    return "";
  }
}

@Deprecated("TODO")
String SubaddressRow_getLabel(SubaddressRow subaddressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressRow_getLabel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_SubaddressRow_getLabel(subaddressBookRow_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressRow_getLabel');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressRow_getLabel', e);
    debugEnd?.call('BELDEX_SubaddressRow_getLabel');
    return "";
  }
}

@Deprecated("TODO")
int SubaddressRow_getRowId(SubaddressRow subaddressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressRow_getRowId');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_SubaddressRow_getRowId(subaddressBookRow_ptr);
  debugEnd?.call('BELDEX_SubaddressRow_getRowId');
  return status;
}

// Subaddress

typedef Subaddress = Pointer<Void>;

@Deprecated("TODO")
int Subaddress_getAll_size(SubaddressRow subaddressBookRow_ptr) {
  debugStart?.call('BELDEX_Subaddress_getAll_size');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_Subaddress_getAll_size(subaddressBookRow_ptr);
  debugEnd?.call('BELDEX_Subaddress_getAll_size');
  return status;
}

@Deprecated("TODO")
SubaddressRow Subaddress_getAll_byIndex(Subaddress subaddressRow_ptr,
    {required int index}) {
  debugStart?.call('BELDEX_Subaddress_getAll_byIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status =
      lib!.BELDEX_Subaddress_getAll_byIndex(subaddressRow_ptr, index);
  debugEnd?.call('BELDEX_Subaddress_getAll_byIndex');
  return status;
}

@Deprecated("TODO")
void Subaddress_addRow(Subaddress ptr,
    {required int accountIndex, required String label}) {
  debugStart?.call('BELDEX_Subaddress_addRow');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final label_ = label.toNativeUtf8().cast<Char>();
  final status = lib!.BELDEX_Subaddress_addRow(ptr, accountIndex, label_);
  calloc.free(label_);
  debugEnd?.call('BELDEX_Subaddress_addRow');
  return status;
}

@Deprecated("TODO")
void Subaddress_setLabel(Subaddress ptr,
    {required int accountIndex,
    required int addressIndex,
    required String label}) {
  debugStart?.call('BELDEX_Subaddress_setLabel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final label_ = label.toNativeUtf8().cast<Char>();
  final status =
      lib!.BELDEX_Subaddress_setLabel(ptr, accountIndex, addressIndex, label_);
  calloc.free(label_);
  debugEnd?.call('BELDEX_Subaddress_setLabel');
  return status;
}

@Deprecated("TODO")
void Subaddress_refresh(Subaddress ptr,
    {required int accountIndex, required String label}) {
  debugStart?.call('BELDEX_Subaddress_refresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final label_ = label.toNativeUtf8().cast<Char>();
  final status = lib!.BELDEX_Subaddress_refresh(ptr, accountIndex);
  calloc.free(label_);
  debugEnd?.call('BELDEX_Subaddress_refresh');
  return status;
}

@Deprecated("TODO")
typedef SubaddressAccountRow = Pointer<Void>;

String SubaddressAccountRow_extra(SubaddressAccountRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressAccountRow_extra');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr =
        lib!.BELDEX_SubaddressAccountRow_extra(addressBookRow_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressAccountRow_extra');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressAccountRow_extra', e);
    debugEnd?.call('BELDEX_SubaddressAccountRow_extra');
    return "";
  }
}

@Deprecated("TODO")
String SubaddressAccountRow_getAddress(
    SubaddressAccountRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressAccountRow_getAddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_SubaddressAccountRow_getAddress(addressBookRow_ptr)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressAccountRow_getAddress');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressAccountRow_getAddress', e);
    debugEnd?.call('BELDEX_SubaddressAccountRow_getAddress');
    return "";
  }
}

@Deprecated("TODO")
String SubaddressAccountRow_getLabel(SubaddressAccountRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressAccountRow_getLabel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_SubaddressAccountRow_getLabel(addressBookRow_ptr)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressAccountRow_getLabel');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressAccountRow_getLabel', e);
    debugEnd?.call('BELDEX_SubaddressAccountRow_getLabel');
    return "";
  }
}

@Deprecated("TODO")
String SubaddressAccountRow_getBalance(
    SubaddressAccountRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressAccountRow_getBalance');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_SubaddressAccountRow_getBalance(addressBookRow_ptr)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressAccountRow_getBalance');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressAccountRow_getBalance', e);
    debugEnd?.call('BELDEX_SubaddressAccountRow_getBalance');
    return "";
  }
}

@Deprecated("TODO")
String SubaddressAccountRow_getUnlockedBalance(
    SubaddressAccountRow addressBookRow_ptr) {
  debugStart?.call('BELDEX_SubaddressAccountRow_getUnlockedBalance');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_SubaddressAccountRow_getUnlockedBalance(addressBookRow_ptr)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_SubaddressAccountRow_getUnlockedBalance');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_SubaddressAccountRow_getUnlockedBalance', e);
    debugEnd?.call('BELDEX_SubaddressAccountRow_getUnlockedBalance');
    return "";
  }
}

@Deprecated("TODO")
int SubaddressAccountRow_getRowId(SubaddressAccountRow ptr) {
  debugStart?.call('BELDEX_SubaddressAccountRow_getRowId');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_SubaddressAccountRow_getRowId(ptr);
  debugEnd?.call('BELDEX_SubaddressAccountRow_getRowId');
  return status;
}

@Deprecated("TODO")
typedef SubaddressAccount = Pointer<Void>;

int SubaddressAccount_getAll_size(SubaddressAccount ptr) {
  debugStart?.call('BELDEX_SubaddressAccount_getAll_size');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_SubaddressAccount_getAll_size(ptr);
  debugEnd?.call('BELDEX_SubaddressAccount_getAll_size');
  return status;
}

@Deprecated("TODO")
SubaddressAccountRow SubaddressAccount_getAll_byIndex(SubaddressAccount ptr,
    {required int index}) {
  debugStart?.call('BELDEX_SubaddressAccount_getAll_byIndex');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_SubaddressAccount_getAll_byIndex(ptr, index);
  debugEnd?.call('BELDEX_SubaddressAccount_getAll_byIndex');
  return status;
}

@Deprecated("TODO")
void SubaddressAccount_addRow(SubaddressAccount ptr, {required String label}) {
  debugStart?.call('BELDEX_SubaddressAccount_addRow');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final label_ = label.toNativeUtf8().cast<Char>();
  final status = lib!.BELDEX_SubaddressAccount_addRow(ptr, label_);
  calloc.free(label_);
  debugEnd?.call('BELDEX_SubaddressAccount_addRow');
  return status;
}

@Deprecated("TODO")
void SubaddressAccount_setLabel(SubaddressAccount ptr,
    {required int accountIndex, required String label}) {
  debugStart?.call('BELDEX_SubaddressAccount_setLabel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final label_ = label.toNativeUtf8().cast<Char>();
  final status =
      lib!.BELDEX_SubaddressAccount_setLabel(ptr, accountIndex, label_);
  calloc.free(label_);
  debugEnd?.call('BELDEX_SubaddressAccount_setLabel');
  return status;
}

@Deprecated("TODO")
void SubaddressAccount_refresh(SubaddressAccount ptr) {
  debugStart?.call('BELDEX_SubaddressAccount_refresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_SubaddressAccount_refresh(ptr);
  debugEnd?.call('BELDEX_SubaddressAccount_refresh');
  return status;
}

@Deprecated("TODO")
// MultisigState

typedef MultisigState = Pointer<Void>;

@Deprecated("TODO")
bool MultisigState_isMultisig(MultisigState ptr) {
  debugStart?.call('BELDEX_MultisigState_isMultisig');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_MultisigState_isMultisig(ptr);
  debugEnd?.call('BELDEX_MultisigState_isMultisig');
  return status;
}

@Deprecated("TODO")
bool MultisigState_isReady(MultisigState ptr) {
  debugStart?.call('BELDEX_MultisigState_isReady');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_MultisigState_isReady(ptr);
  debugEnd?.call('BELDEX_MultisigState_isReady');
  return status;
}

@Deprecated("TODO")
int MultisigState_threshold(MultisigState ptr) {
  debugStart?.call('BELDEX_MultisigState_threshold');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_MultisigState_threshold(ptr);
  debugEnd?.call('BELDEX_MultisigState_threshold');
  return status;
}

@Deprecated("TODO")
int MultisigState_total(MultisigState ptr) {
  debugStart?.call('BELDEX_MultisigState_total');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_MultisigState_total(ptr);
  debugEnd?.call('BELDEX_MultisigState_total');
  return status;
}

@Deprecated("TODO")
// DeviceProgress

typedef DeviceProgress = Pointer<Void>;

@Deprecated("TODO")
bool DeviceProgress_progress(DeviceProgress ptr) {
  debugStart?.call('BELDEX_DeviceProgress_progress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_DeviceProgress_progress(ptr);
  debugEnd?.call('BELDEX_DeviceProgress_progress');
  return status;
}

@Deprecated("TODO")
bool DeviceProgress_indeterminate(DeviceProgress ptr) {
  debugStart?.call('BELDEX_DeviceProgress_indeterminate');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_DeviceProgress_indeterminate(ptr);
  debugEnd?.call('BELDEX_DeviceProgress_indeterminate');
  return status;
}

@Deprecated("TODO")
// Wallet

typedef wallet = Pointer<Void>;

@Deprecated("TODO")
String Wallet_seed(wallet ptr, {required String seedOffset}) {
  debugStart?.call('BELDEX_Wallet_seed');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final seedOffset_ = seedOffset.toNativeUtf8().cast<Char>();
    final strPtr = lib!.BELDEX_Wallet_seed(ptr, seedOffset_).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(seedOffset_);
    debugEnd?.call('BELDEX_Wallet_seed');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_seed', e);
    debugEnd?.call('BELDEX_Wallet_seed');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_getSeedLanguage(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getSeedLanguage');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_getSeedLanguage(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_getSeedLanguage');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getSeedLanguage', e);
    debugEnd?.call('BELDEX_Wallet_getSeedLanguage');
    return "";
  }
}

@Deprecated("TODO")
void Wallet_setSeedLanguage(wallet ptr, {required String language}) {
  debugStart?.call('BELDEX_Wallet_setSeedLanguage');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final language_ = language.toNativeUtf8().cast<Char>();
  final status = lib!.BELDEX_Wallet_setSeedLanguage(ptr, language_);
  calloc.free(language_);
  debugEnd?.call('BELDEX_Wallet_setSeedLanguage');
  return status;
}

@Deprecated("TODO")
int Wallet_status(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_status');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_Wallet_status(ptr);
  debugEnd?.call('BELDEX_Wallet_status');
  return status;
}

@Deprecated("TODO")
String Wallet_errorString(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_errorString');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_errorString(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_errorString');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_errorString', e);
    debugEnd?.call('BELDEX_Wallet_errorString');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_setPassword(wallet ptr, {required String password}) {
  debugStart?.call('BELDEX_Wallet_setPassword');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final password_ = password.toNativeUtf8().cast<Char>();
  final status = lib!.BELDEX_Wallet_setPassword(ptr, password_);
  calloc.free(password_);
  debugEnd?.call('BELDEX_Wallet_setPassword');
  return status;
}

@Deprecated("TODO")
String Wallet_getPassword(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getPassword');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_getPassword(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_getPassword');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getPassword', e);
    debugEnd?.call('BELDEX_Wallet_getPassword');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_setDevicePin(wallet ptr, {required String passphrase}) {
  debugStart?.call('BELDEX_Wallet_setDevicePin');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final passphrase_ = passphrase.toNativeUtf8().cast<Char>();
  final status = lib!.BELDEX_Wallet_setDevicePin(ptr, passphrase_);
  calloc.free(passphrase_);
  debugEnd?.call('BELDEX_Wallet_setDevicePin');
  return status;
}

@Deprecated("TODO")
String Wallet_address(wallet ptr,
    {int accountIndex = 0, int addressIndex = 0}) {
  debugStart?.call('BELDEX_Wallet_address');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_Wallet_address(ptr, accountIndex, addressIndex)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_address');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_address', e);
    debugEnd?.call('BELDEX_Wallet_address');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_path(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_path');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_path(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_path');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_path', e);
    debugEnd?.call('BELDEX_Wallet_path');
    return "";
  }
}

@Deprecated("TODO")
int Wallet_nettype(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_nettype');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_Wallet_nettype(ptr);
  debugEnd?.call('BELDEX_Wallet_nettype');
  return status;
}

@Deprecated("TODO")
int Wallet_useForkRules(
  wallet ptr, {
  required int version,
  required int earlyBlocks,
}) {
  debugStart?.call('BELDEX_Wallet_useForkRules');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_Wallet_useForkRules(ptr, version, earlyBlocks);
  debugEnd?.call('BELDEX_Wallet_useForkRules');
  return status;
}

@Deprecated("TODO")
String Wallet_integratedAddress(wallet ptr, {required String paymentId}) {
  debugStart?.call('BELDEX_Wallet_integratedAddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final paymentId_ = paymentId.toNativeUtf8().cast<Char>();
    final strPtr =
        lib!.BELDEX_Wallet_integratedAddress(ptr, paymentId_).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_integratedAddress');
    calloc.free(paymentId_);
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_integratedAddress', e);
    debugEnd?.call('BELDEX_Wallet_integratedAddress');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_secretViewKey(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_secretViewKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_secretViewKey(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_secretViewKey');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_secretViewKey', e);
    debugEnd?.call('BELDEX_Wallet_secretViewKey');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_publicViewKey(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_publicViewKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_publicViewKey(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_publicViewKey');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_publicViewKey', e);
    debugEnd?.call('BELDEX_Wallet_publicViewKey');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_secretSpendKey(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_secretSpendKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_secretSpendKey(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_secretSpendKey');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_secretSpendKey', e);
    debugEnd?.call('BELDEX_Wallet_secretSpendKey');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_publicSpendKey(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_publicSpendKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_publicSpendKey(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_publicSpendKey');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_publicSpendKey', e);
    debugEnd?.call('BELDEX_Wallet_publicSpendKey');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_publicMultisigSignerKey(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_publicMultisigSignerKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_publicMultisigSignerKey(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_publicMultisigSignerKey');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_publicMultisigSignerKey', e);
    debugEnd?.call('BELDEX_Wallet_publicMultisigSignerKey');
    return "";
  }
}

@Deprecated("TODO")
void Wallet_stop(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_stop');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final stop = lib!.BELDEX_Wallet_stop(ptr);
  debugEnd?.call('BELDEX_Wallet_stop');
  return stop;
}

@Deprecated("TODO")
bool Wallet_store(wallet ptr, {String path = ""}) {
  debugStart?.call('BELDEX_Wallet_store');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_store(ptr, path_);
  calloc.free(path_);
  debugEnd?.call('BELDEX_Wallet_store');
  return s;
}

@Deprecated("TODO")
String Wallet_filename(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_filename');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_filename(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_filename');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_filename', e);
    debugEnd?.call('BELDEX_Wallet_filename');
    return "";
  }
}

String Wallet_keysFilename(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_keysFilename');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_keysFilename(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_keysFilename');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_keysFilename', e);
    debugEnd?.call('BELDEX_Wallet_keysFilename');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_init(
  wallet ptr, {
  required String daemonAddress,
  int upperTransacationSizeLimit = 0,
  String daemonUsername = "",
  String daemonPassword = "",
  bool useSsl = false,
  bool lightWallet = false,
  String proxyAddress = "",
}) {
  debugStart?.call('BELDEX_Wallet_init');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final daemonAddress_ = daemonAddress.toNativeUtf8().cast<Char>();
  final daemonUsername_ = daemonUsername.toNativeUtf8().cast<Char>();
  final daemonPassword_ = daemonPassword.toNativeUtf8().cast<Char>();
  final proxyAddress_ = proxyAddress.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_init(
      ptr,
      daemonAddress_,
      upperTransacationSizeLimit,
      daemonUsername_,
      daemonPassword_,
      useSsl,
      lightWallet,
      proxyAddress_);

  calloc.free(daemonAddress_);
  calloc.free(daemonUsername_);
  calloc.free(daemonPassword_);
  calloc.free(proxyAddress_);
  debugEnd?.call('BELDEX_Wallet_init');
  return s;
}

@Deprecated("TODO")
bool Wallet_createWatchOnly(
  wallet ptr, {
  required String path,
  required String password,
  required String language,
}) {
  debugStart?.call('BELDEX_Wallet_createWatchOnly');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final language_ = language.toNativeUtf8().cast<Char>();
  final getRefreshFromBlockHeight =
      lib!.BELDEX_Wallet_createWatchOnly(ptr, path_, password_, language_);
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(language_);
  debugEnd?.call('BELDEX_Wallet_createWatchOnly');
  return getRefreshFromBlockHeight;
}

@Deprecated("TODO")
void Wallet_setRefreshFromBlockHeight(wallet ptr,
    {required int refresh_from_block_height}) {
  debugStart?.call('BELDEX_Wallet_setRefreshFromBlockHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!
      .BELDEX_Wallet_setRefreshFromBlockHeight(ptr, refresh_from_block_height);
  debugEnd?.call('BELDEX_Wallet_setRefreshFromBlockHeight');
  return status;
}

@Deprecated("TODO")
int Wallet_getRefreshFromBlockHeight(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getRefreshFromBlockHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final getRefreshFromBlockHeight =
      lib!.BELDEX_Wallet_getRefreshFromBlockHeight(ptr);
  debugEnd?.call('BELDEX_Wallet_getRefreshFromBlockHeight');
  return getRefreshFromBlockHeight;
}

@Deprecated("TODO")
void Wallet_setRecoveringFromSeed(wallet ptr,
    {required bool recoveringFromSeed}) {
  debugStart?.call('BELDEX_Wallet_setRecoveringFromSeed');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status =
      lib!.BELDEX_Wallet_setRecoveringFromSeed(ptr, recoveringFromSeed);
  debugEnd?.call('BELDEX_Wallet_setRecoveringFromSeed');
  return status;
}

@Deprecated("TODO")
void Wallet_setRecoveringFromDevice(wallet ptr,
    {required bool recoveringFromDevice}) {
  debugStart?.call('BELDEX_Wallet_setRecoveringFromDevice');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status =
      lib!.BELDEX_Wallet_setRecoveringFromDevice(ptr, recoveringFromDevice);
  debugEnd?.call('BELDEX_Wallet_setRecoveringFromDevice');
  return status;
}

@Deprecated("TODO")
void Wallet_setSubaddressLookahead(wallet ptr,
    {required int major, required int minor}) {
  debugStart?.call('BELDEX_Wallet_setSubaddressLookahead');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_Wallet_setSubaddressLookahead(ptr, major, minor);
  debugEnd?.call('BELDEX_Wallet_setSubaddressLookahead');
  return status;
}

@Deprecated("TODO")
bool Wallet_connectToDaemon(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_connectToDaemon');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final connectToDaemon = lib!.BELDEX_Wallet_connectToDaemon(ptr);
  debugEnd?.call('BELDEX_Wallet_connectToDaemon');
  return connectToDaemon;
}

@Deprecated("TODO")
int Wallet_connected(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_connected');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final connected = lib!.BELDEX_Wallet_connected(ptr);
  debugEnd?.call('BELDEX_Wallet_connected');
  return connected;
}

@Deprecated("TODO")
void Wallet_setTrustedDaemon(wallet ptr, {required bool arg}) {
  debugStart?.call('BELDEX_Wallet_setTrustedDaemon');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_Wallet_setTrustedDaemon(ptr, arg);
  debugEnd?.call('BELDEX_Wallet_setTrustedDaemon');
  return status;
}

@Deprecated("TODO")
bool Wallet_trustedDaemon(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_trustedDaemon');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final status = lib!.BELDEX_Wallet_trustedDaemon(ptr);
  debugEnd?.call('BELDEX_Wallet_trustedDaemon');
  return status;
}

@Deprecated("TODO")
bool Wallet_setProxy(wallet ptr, {required String address}) {
  debugStart?.call('BELDEX_Wallet_setProxy');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final address_ = address.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_setProxy(ptr, address_);
  calloc.free(address_);
  debugEnd?.call('BELDEX_Wallet_setProxy');
  return s;
}

@Deprecated("TODO")
int Wallet_balance(wallet ptr, {required int accountIndex}) {
  debugStart?.call('BELDEX_Wallet_balance');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final balance = lib!.BELDEX_Wallet_balance(ptr, accountIndex);
  debugEnd?.call('BELDEX_Wallet_balance');
  return balance;
}

@Deprecated("TODO")
int Wallet_unlockedBalance(wallet ptr, {required int accountIndex}) {
  debugStart?.call('BELDEX_Wallet_unlockedBalance');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final unlockedBalance = lib!.BELDEX_Wallet_unlockedBalance(ptr, accountIndex);
  debugEnd?.call('BELDEX_Wallet_unlockedBalance');
  return unlockedBalance;
}

@Deprecated("TODO")
int Wallet_viewOnlyBalance(wallet ptr, {required int accountIndex}) {
  debugStart?.call('BELDEX_Wallet_viewOnlyBalance');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final unlockedBalance = lib!.BELDEX_Wallet_viewOnlyBalance(ptr, accountIndex);
  debugEnd?.call('BELDEX_Wallet_viewOnlyBalance');
  return unlockedBalance;
}

@Deprecated("TODO")
bool Wallet_watchOnly(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_watchOnly');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final watchOnly = lib!.BELDEX_Wallet_watchOnly(ptr);
  debugEnd?.call('BELDEX_Wallet_watchOnly');
  return watchOnly;
}

@Deprecated("TODO")
int Wallet_blockChainHeight(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_blockChainHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final blockChainHeight = lib!.BELDEX_Wallet_blockChainHeight(ptr);
  debugEnd?.call('BELDEX_Wallet_blockChainHeight');
  return blockChainHeight;
}

@Deprecated("TODO")
int Wallet_approximateBlockChainHeight(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_approximateBlockChainHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final approximateBlockChainHeight =
      lib!.BELDEX_Wallet_approximateBlockChainHeight(ptr);
  debugEnd?.call('BELDEX_Wallet_approximateBlockChainHeight');
  return approximateBlockChainHeight;
}

@Deprecated("TODO")
int Wallet_estimateBlockChainHeight(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_estimateBlockChainHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final estimateBlockChainHeight =
      lib!.BELDEX_Wallet_estimateBlockChainHeight(ptr);
  debugEnd?.call('BELDEX_Wallet_estimateBlockChainHeight');
  return estimateBlockChainHeight;
}

int Wallet_daemonBlockChainHeight(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_daemonBlockChainHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final daemonBlockChainHeight = lib!.BELDEX_Wallet_daemonBlockChainHeight(ptr);
  debugEnd?.call('BELDEX_Wallet_daemonBlockChainHeight');
  return daemonBlockChainHeight;
}

@Deprecated("TODO")
bool Wallet_synchronized(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_synchronized');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final synchronized = lib!.BELDEX_Wallet_synchronized(ptr);
  debugEnd?.call('BELDEX_Wallet_synchronized');
  return synchronized;
}

@Deprecated("TODO")
String Wallet_displayAmount(int amount) {
  debugStart?.call('BELDEX_Wallet_displayAmount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_displayAmount(amount).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_displayAmount');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_displayAmount', e);
    debugEnd?.call('BELDEX_Wallet_displayAmount');
    return "";
  }
}

@Deprecated("TODO")
int Wallet_amountFromString(String amount) {
  debugStart?.call('BELDEX_Wallet_amountFromString');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final amount_ = amount.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_amountFromString(amount_);
  calloc.free(amount_);
  debugEnd?.call('BELDEX_Wallet_amountFromString');
  return s;
}

@Deprecated("TODO")
int Wallet_amountFromDouble(double amount) {
  debugStart?.call('BELDEX_Wallet_amountFromDouble');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_Wallet_amountFromDouble(amount);
  debugEnd?.call('BELDEX_Wallet_amountFromDouble');
  return s;
}

@Deprecated("TODO")
String Wallet_genPaymentId() {
  debugStart?.call('BELDEX_Wallet_genPaymentId');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_genPaymentId().cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_genPaymentId');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_genPaymentId', e);
    debugEnd?.call('BELDEX_Wallet_genPaymentId');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_paymentIdValid(String paymentId) {
  debugStart?.call('BELDEX_Wallet_paymentIdValid');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final paymentId_ = paymentId.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_paymentIdValid(paymentId_);
  calloc.free(paymentId_);
  debugEnd?.call('BELDEX_Wallet_paymentIdValid');
  return s;
}

@Deprecated("TODO")
bool Wallet_addressValid(String address, int networkType) {
  debugStart?.call('BELDEX_Wallet_addressValid');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final address_ = address.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_addressValid(address_, networkType);
  calloc.free(address_);
  debugEnd?.call('BELDEX_Wallet_addressValid');
  return s;
}

@Deprecated("TODO")
bool Wallet_keyValid(
    {required String secret_key_string,
    required String address_string,
    required bool isViewKey,
    required int nettype}) {
  debugStart?.call('BELDEX_Wallet_keyValid');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final secret_key_string_ = secret_key_string.toNativeUtf8().cast<Char>();
  final address_string_ = address_string.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_keyValid(
      secret_key_string_, address_string_, isViewKey, nettype);
  calloc.free(secret_key_string_);
  calloc.free(address_string_);
  debugEnd?.call('BELDEX_Wallet_keyValid');
  return s;
}

@Deprecated("TODO")
String Wallet_keyValid_error(
    {required String secret_key_string,
    required String address_string,
    required bool isViewKey,
    required int nettype}) {
  debugStart?.call('BELDEX_Wallet_keyValid_error');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final secret_key_string_ = secret_key_string.toNativeUtf8().cast<Char>();
    final address_string_ = address_string.toNativeUtf8().cast<Char>();
    final strPtr = lib!
        .BELDEX_Wallet_keyValid_error(
            secret_key_string_, address_string_, isViewKey, nettype)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(secret_key_string_);
    calloc.free(address_string_);
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_keyValid_error', e);
    debugEnd?.call('BELDEX_Wallet_keyValid_error');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_paymentIdFromAddress(
    {required String strarg, required int nettype}) {
  debugStart?.call('BELDEX_Wallet_paymentIdFromAddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strarg_ = strarg.toNativeUtf8().cast<Char>();
    final strPtr =
        lib!.BELDEX_Wallet_paymentIdFromAddress(strarg_, nettype).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(strarg_);
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_paymentIdFromAddress', e);
    debugEnd?.call('BELDEX_Wallet_paymentIdFromAddress');
    return "";
  }
}

@Deprecated("TODO")
int Wallet_maximumAllowedAmount() {
  debugStart?.call('BELDEX_Wallet_maximumAllowedAmount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_Wallet_maximumAllowedAmount();
  debugEnd?.call('BELDEX_Wallet_maximumAllowedAmount');
  return s;
}

@Deprecated("TODO")
void Wallet_init3(
  wallet ptr, {
  required String argv0,
  required String defaultLogBaseName,
  required String logPath,
  required bool console,
}) {
  debugStart?.call('BELDEX_Wallet_init3');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final argv0_ = argv0.toNativeUtf8().cast<Char>();
  final defaultLogBaseName_ = defaultLogBaseName.toNativeUtf8().cast<Char>();
  final logPath_ = logPath.toNativeUtf8().cast<Char>();
  final s = lib!
      .BELDEX_Wallet_init3(ptr, argv0_, defaultLogBaseName_, logPath_, console);
  calloc.free(argv0_);
  calloc.free(defaultLogBaseName_);
  calloc.free(logPath_);
  debugEnd?.call('BELDEX_Wallet_init3');
  return s;
}

@Deprecated("TODO")
String Wallet_getPolyseed(wallet ptr, {required String passphrase}) {
  debugStart?.call('BELDEX_Wallet_getPolyseed');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final passphrase_ = passphrase.toNativeUtf8().cast<Char>();
    final strPtr =
        lib!.BELDEX_Wallet_getPolyseed(ptr, passphrase_).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(passphrase_);
    debugEnd?.call('BELDEX_Wallet_getPolyseed');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getPolyseed', e);
    debugEnd?.call('BELDEX_Wallet_getPolyseed');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_createPolyseed({
  String language = "English",
}) {
  debugStart?.call('BELDEX_Wallet_createPolyseed');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final language_ = language.toNativeUtf8();
    final strPtr =
        lib!.BELDEX_Wallet_createPolyseed(language_.cast()).cast<Utf8>();
    calloc.free(language_);
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_createPolyseed');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_createPolyseed', e);
    debugEnd?.call('BELDEX_Wallet_createPolyseed');
    return "";
  }
}

@Deprecated("TODO")
void Wallet_startRefresh(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_startRefresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final startRefresh = lib!.BELDEX_Wallet_startRefresh(ptr);
  debugEnd?.call('BELDEX_Wallet_startRefresh');
  return startRefresh;
}

@Deprecated("TODO")
void Wallet_pauseRefresh(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_pauseRefresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final pauseRefresh = lib!.BELDEX_Wallet_pauseRefresh(ptr);
  debugEnd?.call('BELDEX_Wallet_pauseRefresh');
  return pauseRefresh;
}

@Deprecated("TODO")
bool Wallet_refresh(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_refresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final refresh = lib!.BELDEX_Wallet_refresh(ptr);
  debugEnd?.call('BELDEX_Wallet_refresh');
  return refresh;
}

@Deprecated("TODO")
void Wallet_refreshAsync(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_refreshAsync');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final refreshAsync = lib!.BELDEX_Wallet_refreshAsync(ptr);
  debugEnd?.call('BELDEX_Wallet_refreshAsync');
  return refreshAsync;
}

@Deprecated("TODO")
bool Wallet_rescanBlockchain(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_rescanBlockchain');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final rescanBlockchain = lib!.BELDEX_Wallet_rescanBlockchain(ptr);
  debugEnd?.call('BELDEX_Wallet_rescanBlockchain');
  return rescanBlockchain;
}

@Deprecated("TODO")
void Wallet_rescanBlockchainAsync(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_rescanBlockchainAsync');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final rescanBlockchainAsync = lib!.BELDEX_Wallet_rescanBlockchainAsync(ptr);
  debugEnd?.call('BELDEX_Wallet_rescanBlockchainAsync');
  return rescanBlockchainAsync;
}

@Deprecated("TODO")
void Wallet_setAutoRefreshInterval(wallet ptr, {required int millis}) {
  debugStart?.call('BELDEX_Wallet_setAutoRefreshInterval');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final setAutoRefreshInterval =
      lib!.BELDEX_Wallet_setAutoRefreshInterval(ptr, millis);
  debugEnd?.call('BELDEX_Wallet_setAutoRefreshInterval');
  return setAutoRefreshInterval;
}

@Deprecated("TODO")
int Wallet_autoRefreshInterval(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_autoRefreshInterval');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final autoRefreshInterval = lib!.BELDEX_Wallet_autoRefreshInterval(ptr);
  debugEnd?.call('BELDEX_Wallet_autoRefreshInterval');
  return autoRefreshInterval;
}

@Deprecated("TODO")
void Wallet_addSubaddress(wallet ptr,
    {required int accountIndex, String label = ""}) {
  debugStart?.call('BELDEX_Wallet_addSubaddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final label_ = label.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_addSubaddress(ptr, accountIndex, label_);
  calloc.free(label_);
  debugEnd?.call('BELDEX_Wallet_addSubaddress');
  return s;
}

@Deprecated("TODO")
void Wallet_addSubaddressAccount(wallet ptr, {String label = ""}) {
  debugStart?.call('BELDEX_Wallet_addSubaddressAccount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final label_ = label.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_addSubaddressAccount(ptr, label_);
  calloc.free(label_);
  debugEnd?.call('BELDEX_Wallet_addSubaddressAccount');
  return s;
}

@Deprecated("TODO")
int Wallet_numSubaddressAccounts(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_numSubaddressAccounts');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final numSubaddressAccounts = lib!.BELDEX_Wallet_numSubaddressAccounts(ptr);
  debugEnd?.call('BELDEX_Wallet_numSubaddressAccounts');
  return numSubaddressAccounts;
}

@Deprecated("TODO")
int Wallet_numSubaddresses(wallet ptr, {required int accountIndex}) {
  debugStart?.call('BELDEX_Wallet_numSubaddresses');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final numSubaddresses = lib!.BELDEX_Wallet_numSubaddresses(ptr, accountIndex);
  debugEnd?.call('BELDEX_Wallet_numSubaddresses');
  return numSubaddresses;
}

@Deprecated("TODO")
String Wallet_getSubaddressLabel(wallet ptr,
    {required int accountIndex, required int addressIndex}) {
  debugStart?.call('BELDEX_Wallet_getSubaddressLabel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_Wallet_getSubaddressLabel(ptr, accountIndex, addressIndex)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_getSubaddressLabel');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getSubaddressLabel', e);
    debugEnd?.call('BELDEX_Wallet_getSubaddressLabel');
    return "";
  }
}

@Deprecated("TODO")
void Wallet_setSubaddressLabel(wallet ptr,
    {required int accountIndex,
    required int addressIndex,
    required String label}) {
  debugStart?.call('BELDEX_Wallet_setSubaddressLabel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final label_ = label.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_setSubaddressLabel(
      ptr, accountIndex, addressIndex, label_);
  calloc.free(label_);
  debugEnd?.call('BELDEX_Wallet_setSubaddressLabel');
  return s;
}

@Deprecated("TODO")
MultisigState Wallet_multisig(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_multisig');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_Wallet_multisig(ptr);
  debugEnd?.call('BELDEX_Wallet_multisig');
  return s;
}

@Deprecated("TODO")
String Wallet_getMultisigInfo(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getMultisigInfo');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_Wallet_getMultisigInfo(ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_getMultisigInfo');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getMultisigInfo', e);
    debugEnd?.call('BELDEX_Wallet_getMultisigInfo');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_makeMultisig(
  wallet ptr, {
  required List<String> info,
  required int threshold,
}) {
  debugStart?.call('BELDEX_Wallet_makeMultisig');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final infoStr = info.join(defaultSeparatorStr).toNativeUtf8();
    final strPtr = lib!
        .BELDEX_Wallet_makeMultisig(
          ptr,
          infoStr.cast(),
          defaultSeparator.cast(),
          threshold,
        )
        .cast<Utf8>();
    final str = strPtr.toDartString();
    calloc.free(infoStr);
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_makeMultisig');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_makeMultisig', e);
    debugEnd?.call('BELDEX_Wallet_makeMultisig');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_exchangeMultisigKeys(
  wallet ptr, {
  required List<String> info,
  required bool force_update_use_with_caution,
}) {
  debugStart?.call('BELDEX_Wallet_exchangeMultisigKeys');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final infoStr = info.join(defaultSeparatorStr).toNativeUtf8();
    final strPtr = lib!
        .BELDEX_Wallet_exchangeMultisigKeys(
          ptr,
          infoStr.cast(),
          defaultSeparator.cast(),
          force_update_use_with_caution,
        )
        .cast<Utf8>();
    final str = strPtr.toDartString();
    calloc.free(infoStr);
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_exchangeMultisigKeys');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_exchangeMultisigKeys', e);
    debugEnd?.call('BELDEX_Wallet_exchangeMultisigKeys');
    return "";
  }
}

@Deprecated("TODO")
List<String> Wallet_exportMultisigImages(
  wallet ptr, {
  required List<String> info,
  required bool force_update_use_with_caution,
}) {
  debugStart?.call('BELDEX_Wallet_exportMultisigImages');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final infoStr = info.join(defaultSeparatorStr).toNativeUtf8();
    final strPtr = lib!
        .BELDEX_Wallet_exportMultisigImages(
          ptr,
          defaultSeparator.cast(),
        )
        .cast<Utf8>();
    final str = strPtr.toDartString();
    calloc.free(infoStr);
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_exportMultisigImages');
    return str.split(defaultSeparatorStr);
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_exportMultisigImages', e);
    debugEnd?.call('BELDEX_Wallet_exportMultisigImages');
    return [];
  }
}

@Deprecated("TODO")
int Wallet_importMultisigImages(
  wallet ptr, {
  required List<String> info,
}) {
  debugStart?.call('BELDEX_Wallet_importMultisigImages');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final infoStr = info.join(defaultSeparatorStr).toNativeUtf8();
  final ret = lib!.BELDEX_Wallet_importMultisigImages(
    ptr,
    infoStr.cast(),
    defaultSeparator.cast(),
  );
  calloc.free(infoStr);
  debugEnd?.call('BELDEX_Wallet_importMultisigImages');
  return ret;
}

@Deprecated("TODO")
int Wallet_hasMultisigPartialKeyImages(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_hasMultisigPartialKeyImages');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_hasMultisigPartialKeyImages(
    ptr,
  );
  debugEnd?.call('BELDEX_Wallet_hasMultisigPartialKeyImages');
  return ret;
}

@Deprecated("TODO")
PendingTransaction Wallet_restoreMultisigTransaction(
  wallet ptr, {
  required String signData,
}) {
  debugStart?.call('BELDEX_Wallet_restoreMultisigTransaction');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final signData_ = signData.toNativeUtf8();
  final ret = lib!.BELDEX_Wallet_restoreMultisigTransaction(
    ptr,
    signData_.cast(),
  );
  calloc.free(signData_);
  debugEnd?.call('BELDEX_Wallet_restoreMultisigTransaction');
  return ret;
}

@Deprecated("TODO")
PendingTransaction Wallet_createTransactionMultDest(
  wallet wptr, {
  required List<String> dstAddr,
  String paymentId = "",
  required bool isSweepAll,
  required List<int> amounts,
  required int mixinCount,
  required int pendingTransactionPriority,
  required int subaddr_account,
  List<String> preferredInputs = const [],
}) {
  debugStart?.call('BELDEX_Wallet_createTransactionMultDest');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final dst_addr_list = dstAddr.join(defaultSeparatorStr).toNativeUtf8();
  final payment_id = paymentId.toNativeUtf8();
  final amount_list =
      amounts.map((e) => e.toString()).join(defaultSeparatorStr).toNativeUtf8();
  final preferredInputs_ =
      preferredInputs.join(defaultSeparatorStr).toNativeUtf8();
  final ret = lib!.BELDEX_Wallet_createTransactionMultDest(
    wptr,
    dst_addr_list.cast(),
    defaultSeparator,
    payment_id.cast(),
    isSweepAll,
    amount_list.cast(),
    defaultSeparator,
    mixinCount,
    pendingTransactionPriority,
    subaddr_account,
    preferredInputs_.cast(),
    defaultSeparator,
  );
  calloc.free(dst_addr_list);
  calloc.free(payment_id);
  calloc.free(amount_list);
  calloc.free(preferredInputs_);
  debugEnd?.call('BELDEX_Wallet_createTransactionMultDest');
  return ret;
}

@Deprecated("TODO")
PendingTransaction Wallet_createTransaction(wallet ptr,
    {required String dst_addr,
    required String payment_id,
    required int amount,
    required int mixin_count,
    required int pendingTransactionPriority,
    required int subaddr_account,
    List<String> preferredInputs = const []}) {
  debugStart?.call('BELDEX_Wallet_createTransaction');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final dst_addr_ = dst_addr.toNativeUtf8().cast<Char>();
  final payment_id_ = payment_id.toNativeUtf8().cast<Char>();
  final preferredInputs_ =
      preferredInputs.join(defaultSeparatorStr).toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_createTransaction(
    ptr,
    dst_addr_,
    payment_id_,
    amount,
    mixin_count,
    pendingTransactionPriority,
    subaddr_account,
    preferredInputs_,
    defaultSeparator,
  );
  calloc.free(dst_addr_);
  calloc.free(payment_id_);
  calloc.free(preferredInputs_);
  debugEnd?.call('BELDEX_Wallet_createTransaction');
  return s;
}

@Deprecated("TODO")
UnsignedTransaction Wallet_loadUnsignedTx(wallet ptr,
    {required String unsigned_filename}) {
  debugStart?.call('BELDEX_Wallet_loadUnsignedTx');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final unsigned_filename_ = unsigned_filename.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_loadUnsignedTx(ptr, unsigned_filename_);
  calloc.free(unsigned_filename_);
  debugEnd?.call('BELDEX_Wallet_loadUnsignedTx');
  return s;
}

@Deprecated("TODO")
UnsignedTransaction Wallet_loadUnsignedTxUR(wallet ptr,
    {required String input}) {
  debugStart?.call('BELDEX_Wallet_loadUnsignedTxUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final input_ = input.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_loadUnsignedTxUR(ptr, input_);
  calloc.free(input_);
  debugEnd?.call('BELDEX_Wallet_loadUnsignedTxUR');
  return s;
}

@Deprecated("TODO")
bool Wallet_submitTransaction(wallet ptr, String filename) {
  debugStart?.call('BELDEX_Wallet_submitTransaction');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final filename_ = filename.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_submitTransaction(ptr, filename_);
  calloc.free(filename_);
  debugEnd?.call('BELDEX_Wallet_submitTransaction');
  return s;
}

@Deprecated("TODO")
bool Wallet_submitTransactionUR(wallet ptr, String input) {
  debugStart?.call('BELDEX_Wallet_submitTransactionUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final input_ = input.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_submitTransactionUR(ptr, input_);
  calloc.free(input_);
  debugEnd?.call('BELDEX_Wallet_submitTransactionUR');
  return s;
}

@Deprecated("TODO")
bool Wallet_hasUnknownKeyImages(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_hasUnknownKeyImages');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_Wallet_hasUnknownKeyImages(ptr);
  debugEnd?.call('BELDEX_Wallet_hasUnknownKeyImages');
  return s;
}

@Deprecated("TODO")
bool Wallet_exportKeyImages(wallet ptr, String filename, {required bool all}) {
  debugStart?.call('BELDEX_Wallet_exportKeyImages');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final filename_ = filename.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_exportKeyImages(ptr, filename_, all);
  calloc.free(filename_);
  debugEnd?.call('BELDEX_Wallet_exportKeyImages');
  return s;
}

@Deprecated("TODO")
String Wallet_exportKeyImagesUR(
  wallet ptr, {
  int max_fragment_length = 130,
  bool all = false,
}) {
  debugStart?.call('BELDEX_Wallet_exportKeyImagesUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_Wallet_exportKeyImagesUR(ptr, max_fragment_length, all)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_exportKeyImagesUR');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_exportKeyImagesUR', e);
    debugEnd?.call('BELDEX_Wallet_exportKeyImagesUR');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_importKeyImages(wallet ptr, String filename) {
  debugStart?.call('BELDEX_Wallet_importKeyImages');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final filename_ = filename.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_importKeyImages(ptr, filename_);
  calloc.free(filename_);
  debugEnd?.call('BELDEX_Wallet_importKeyImages');
  return s;
}

@Deprecated("TODO")
bool Wallet_importKeyImagesUR(wallet ptr, String input) {
  debugStart?.call('BELDEX_Wallet_importKeyImagesUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final input_ = input.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_importKeyImagesUR(ptr, input_);
  calloc.free(input_);
  debugEnd?.call('BELDEX_Wallet_importKeyImagesUR');
  return s;
}

@Deprecated("TODO")
bool Wallet_exportOutputs(wallet ptr, String filename, {required bool all}) {
  debugStart?.call('BELDEX_Wallet_exportOutputs');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final filename_ = filename.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_exportOutputs(ptr, filename_, all);
  calloc.free(filename_);
  debugEnd?.call('BELDEX_Wallet_exportOutputs');
  return s;
}

@Deprecated("TODO")
String Wallet_exportOutputsUR(
  wallet ptr, {
  int max_fragment_length = 130,
  bool all = false,
}) {
  debugStart?.call('BELDEX_Wallet_exportOutputsUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_Wallet_exportOutputsUR(ptr, max_fragment_length, all)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_exportOutputsUR');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_exportOutputsUR', e);
    debugEnd?.call('BELDEX_Wallet_exportOutputsUR');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_importOutputs(wallet ptr, String filename) {
  debugStart?.call('BELDEX_Wallet_importOutputs');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final filename_ = filename.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_importOutputs(ptr, filename_);
  calloc.free(filename_);
  debugEnd?.call('BELDEX_Wallet_importOutputs');
  return s;
}

@Deprecated("TODO")
bool Wallet_importOutputsUR(wallet ptr, String input) {
  debugStart?.call('BELDEX_Wallet_importOutputsUR');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final input_ = input.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_importOutputsUR(ptr, input_);
  calloc.free(input_);
  debugEnd?.call('BELDEX_Wallet_importOutputsUR');
  return s;
}

@Deprecated("TODO")
bool Wallet_setupBackgroundSync(
  wallet ptr, {
  required int backgroundSyncType,
  required String walletPassword,
  required String backgroundCachePassword,
}) {
  debugStart?.call('BELDEX_Wallet_setupBackgroundSync');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final walletPassword_ = walletPassword.toNativeUtf8().cast<Char>();
  final backgroundCachePassword_ =
      backgroundCachePassword.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_Wallet_setupBackgroundSync(
      ptr, backgroundSyncType, walletPassword_, backgroundCachePassword_);
  calloc.free(walletPassword_);
  calloc.free(backgroundCachePassword_);
  debugEnd?.call('BELDEX_Wallet_setupBackgroundSync');
  return s;
}

@Deprecated("TODO")
int Wallet_getBackgroundSyncType(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getBackgroundSyncType');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_getBackgroundSyncType(ptr);
  debugEnd?.call('BELDEX_Wallet_getBackgroundSyncType');
  return v;
}

@Deprecated("TODO")
bool Wallet_startBackgroundSync(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_startBackgroundSync');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_startBackgroundSync(ptr);
  debugEnd?.call('BELDEX_Wallet_startBackgroundSync');
  return v;
}

@Deprecated("TODO")
bool Wallet_stopBackgroundSync(wallet ptr, String walletPassword) {
  debugStart?.call('BELDEX_Wallet_stopBackgroundSync');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final walletPassword_ = walletPassword.toNativeUtf8().cast<Char>();
  final v = lib!.BELDEX_Wallet_stopBackgroundSync(ptr, walletPassword_);
  calloc.free(walletPassword_);
  debugEnd?.call('BELDEX_Wallet_stopBackgroundSync');
  return v;
}

@Deprecated("TODO")
bool Wallet_isBackgroundSyncing(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_isBackgroundSyncing');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_isBackgroundSyncing(ptr);
  debugEnd?.call('BELDEX_Wallet_isBackgroundSyncing');
  return v;
}

@Deprecated("TODO")
bool Wallet_isBackgroundWallet(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_isBackgroundWallet');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_isBackgroundWallet(ptr);
  debugEnd?.call('BELDEX_Wallet_isBackgroundWallet');
  return v;
}

@Deprecated("TODO")
TransactionHistory Wallet_history(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_history');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final history = lib!.BELDEX_Wallet_history(ptr);
  debugEnd?.call('BELDEX_Wallet_history');
  return history;
}

@Deprecated("TODO")
AddressBook Wallet_addressBook(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_addressBook');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final history = lib!.BELDEX_Wallet_addressBook(ptr);
  debugEnd?.call('BELDEX_Wallet_addressBook');
  return history;
}

@Deprecated("TODO")
AddressBook Wallet_coins(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_coins');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final history = lib!.BELDEX_Wallet_coins(ptr);
  debugEnd?.call('BELDEX_Wallet_coins');
  return history;
}

@Deprecated("TODO")
AddressBook Wallet_subaddress(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_subaddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final history = lib!.BELDEX_Wallet_subaddress(ptr);
  debugEnd?.call('BELDEX_Wallet_subaddress');
  return history;
}

@Deprecated("TODO")
AddressBook Wallet_subaddressAccount(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_subaddressAccount');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final history = lib!.BELDEX_Wallet_subaddressAccount(ptr);
  debugEnd?.call('BELDEX_Wallet_subaddressAccount');
  return history;
}

@Deprecated("TODO")
int Wallet_defaultMixin(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_defaultMixin');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_defaultMixin(ptr);
  debugEnd?.call('BELDEX_Wallet_defaultMixin');
  return v;
}

@Deprecated("TODO")
void Wallet_setDefaultMixin(wallet ptr, int arg) {
  debugStart?.call('BELDEX_Wallet_setDefaultMixin');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_setDefaultMixin(ptr, arg);
  debugEnd?.call('BELDEX_Wallet_setDefaultMixin');
  return v;
}

@Deprecated("TODO")
bool Wallet_setCacheAttribute(wallet ptr,
    {required String key, required String value}) {
  debugStart?.call('BELDEX_Wallet_setCacheAttribute');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final key_ = key.toNativeUtf8().cast<Char>();
  final value_ = value.toNativeUtf8().cast<Char>();
  final v = lib!.BELDEX_Wallet_setCacheAttribute(ptr, key_, value_);
  calloc.free(key_);
  calloc.free(value_);
  debugEnd?.call('BELDEX_Wallet_setCacheAttribute');
  return v;
}

@Deprecated("TODO")
String Wallet_getCacheAttribute(wallet ptr, {required String key}) {
  debugStart?.call('BELDEX_Wallet_getCacheAttribute');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final key_ = key.toNativeUtf8().cast<Char>();
    final strPtr = lib!.BELDEX_Wallet_getCacheAttribute(ptr, key_).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(key_);
    debugEnd?.call('BELDEX_Wallet_getCacheAttribute');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getCacheAttribute', e);
    debugEnd?.call('BELDEX_Wallet_getCacheAttribute');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_setUserNote(wallet ptr,
    {required String txid, required String note}) {
  debugStart?.call('BELDEX_Wallet_setUserNote');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final txid_ = txid.toNativeUtf8().cast<Char>();
  final note_ = note.toNativeUtf8().cast<Char>();
  final v = lib!.BELDEX_Wallet_setUserNote(ptr, txid_, note_);
  calloc.free(txid_);
  calloc.free(note_);
  debugEnd?.call('BELDEX_Wallet_setUserNote');
  return v;
}

@Deprecated("TODO")
String Wallet_getUserNote(wallet ptr, {required String txid}) {
  debugStart?.call('BELDEX_Wallet_getUserNote');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final txid_ = txid.toNativeUtf8().cast<Char>();
    final strPtr = lib!.BELDEX_Wallet_getUserNote(ptr, txid_).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(txid_);
    debugEnd?.call('BELDEX_Wallet_getUserNote');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getUserNote', e);
    debugEnd?.call('BELDEX_Wallet_getUserNote');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_getTxKey(wallet ptr, {required String txid}) {
  debugStart?.call('BELDEX_Wallet_getTxKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final txid_ = txid.toNativeUtf8().cast<Char>();
    final strPtr = lib!.BELDEX_Wallet_getTxKey(ptr, txid_).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(txid_);
    debugEnd?.call('BELDEX_Wallet_getTxKey');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_getTxKey', e);
    debugEnd?.call('BELDEX_Wallet_getTxKey');
    return "";
  }
}

@Deprecated("TODO")
String Wallet_signMessage(
  wallet ptr, {
  required String message,
  required String address,
}) {
  debugStart?.call('BELDEX_Wallet_signMessage');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final message_ = message.toNativeUtf8().cast<Char>();
    final address_ = address.toNativeUtf8().cast<Char>();
    final strPtr =
        lib!.BELDEX_Wallet_signMessage(ptr, message_, address_).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    calloc.free(message_);
    calloc.free(address_);
    debugEnd?.call('BELDEX_Wallet_signMessage');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_signMessage', e);
    debugEnd?.call('BELDEX_Wallet_signMessage');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_verifySignedMessage(
  wallet ptr, {
  required String message,
  required String address,
  required String signature,
}) {
  debugStart?.call('BELDEX_Wallet_verifySignedMessage');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final message_ = message.toNativeUtf8().cast<Char>();
  final address_ = address.toNativeUtf8().cast<Char>();
  final signature_ = signature.toNativeUtf8().cast<Char>();
  final v = lib!
      .BELDEX_Wallet_verifySignedMessage(ptr, message_, address_, signature_);
  calloc.free(message_);
  calloc.free(address_);
  calloc.free(signature_);
  debugEnd?.call('BELDEX_Wallet_verifySignedMessage');
  return v;
}

@Deprecated("TODO")
bool Wallet_rescanSpent(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_rescanSpent');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_rescanSpent(ptr);
  debugEnd?.call('BELDEX_Wallet_rescanSpent');
  return v;
}

@Deprecated("TODO")
void Wallet_setOffline(wallet ptr, {required bool offline}) {
  debugStart?.call('BELDEX_Wallet_setOffline');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final setOffline = lib!.BELDEX_Wallet_setOffline(ptr, offline);
  debugEnd?.call('BELDEX_Wallet_setOffline');
  return setOffline;
}

@Deprecated("TODO")
bool Wallet_isOffline(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_isOffline');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final isOffline = lib!.BELDEX_Wallet_isOffline(ptr);
  debugEnd?.call('BELDEX_Wallet_isOffline');
  return isOffline;
}

@Deprecated("TODO")
void Wallet_segregatePreForkOutputs(wallet ptr, {required bool segregate}) {
  debugStart?.call('BELDEX_Wallet_segregatePreForkOutputs');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_segregatePreForkOutputs(ptr, segregate);
  debugEnd?.call('BELDEX_Wallet_segregatePreForkOutputs');
  return v;
}

@Deprecated("TODO")
void Wallet_segregationHeight(wallet ptr, {required int height}) {
  debugStart?.call('BELDEX_Wallet_segregationHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_segregationHeight(ptr, height);
  debugEnd?.call('BELDEX_Wallet_segregationHeight');
  return v;
}

@Deprecated("TODO")
void Wallet_keyReuseMitigation2(wallet ptr, {required bool mitigation}) {
  debugStart?.call('BELDEX_Wallet_keyReuseMitigation2');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_keyReuseMitigation2(ptr, mitigation);
  debugEnd?.call('BELDEX_Wallet_keyReuseMitigation2');
  return v;
}

@Deprecated("TODO")
bool Wallet_lockKeysFile(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_lockKeysFile');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_lockKeysFile(ptr);
  debugEnd?.call('BELDEX_Wallet_lockKeysFile');
  return v;
}

@Deprecated("TODO")
bool Wallet_unlockKeysFile(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_unlockKeysFile');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_unlockKeysFile(ptr);
  debugEnd?.call('BELDEX_Wallet_unlockKeysFile');
  return v;
}

@Deprecated("TODO")
bool Wallet_isKeysFileLocked(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_isKeysFileLocked');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_isKeysFileLocked(ptr);
  debugEnd?.call('BELDEX_Wallet_isKeysFileLocked');
  return v;
}

@Deprecated("TODO")
int Wallet_getDeviceType(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getDeviceType');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_getDeviceType(ptr);
  debugEnd?.call('BELDEX_Wallet_getDeviceType');
  return v;
}

@Deprecated("TODO")
int Wallet_coldKeyImageSync(wallet ptr,
    {required int spent, required int unspent}) {
  debugStart?.call('BELDEX_Wallet_coldKeyImageSync');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final v = lib!.BELDEX_Wallet_coldKeyImageSync(ptr, spent, unspent);
  debugEnd?.call('BELDEX_Wallet_coldKeyImageSync');
  return v;
}

@Deprecated("TODO")
String Wallet_deviceShowAddress(wallet ptr,
    {required int accountIndex, required int addressIndex}) {
  debugStart?.call('BELDEX_Wallet_deviceShowAddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!
        .BELDEX_Wallet_deviceShowAddress(ptr, accountIndex, addressIndex)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_Wallet_deviceShowAddress');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_Wallet_deviceShowAddress', e);
    debugEnd?.call('BELDEX_Wallet_deviceShowAddress');
    return "";
  }
}

@Deprecated("TODO")
bool Wallet_reconnectDevice(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_reconnectDevice');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_reconnectDevice(ptr);
  debugEnd?.call('BELDEX_Wallet_reconnectDevice');
  return ret;
}

@Deprecated("TODO")
int Wallet_getBytesReceived(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getBytesReceived');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final getBytesReceived = lib!.BELDEX_Wallet_getBytesReceived(ptr);
  debugEnd?.call('BELDEX_Wallet_getBytesReceived');
  return getBytesReceived;
}

@Deprecated("TODO")
int BELDEX_Wallet_getBytesSent(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_getBytesSent');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final getBytesSent = lib!.BELDEX_Wallet_getBytesSent(ptr);
  debugEnd?.call('BELDEX_Wallet_getBytesSent');
  return getBytesSent;
}

@Deprecated("TODO")
bool Wallet_getStateIsConnected() {
  debugStart?.call('BELDEX_Wallet_getStateIsConnected');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_getStateIsConnected();
  debugEnd?.call('BELDEX_Wallet_getStateIsConnected');
  return ret;
}

@Deprecated("TODO")
Pointer<UnsignedChar> Wallet_getSendToDevice() {
  debugStart?.call('BELDEX_Wallet_getSendToDevice');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_getSendToDevice();
  debugEnd?.call('BELDEX_Wallet_getSendToDevice');
  return ret;
}

@Deprecated("TODO")
int Wallet_getSendToDeviceLength() {
  debugStart?.call('BELDEX_Wallet_getSendToDeviceLength');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_getSendToDeviceLength();
  debugEnd?.call('BELDEX_Wallet_getSendToDeviceLength');
  return ret;
}

@Deprecated("TODO")
Pointer<UnsignedChar> Wallet_getReceivedFromDevice() {
  debugStart?.call('BELDEX_Wallet_getReceivedFromDevice');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_getReceivedFromDevice();
  debugEnd?.call('BELDEX_Wallet_getReceivedFromDevice');
  return ret;
}

@Deprecated("TODO")
int Wallet_getReceivedFromDeviceLength() {
  debugStart?.call('BELDEX_Wallet_getReceivedFromDeviceLength');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_getReceivedFromDeviceLength();
  debugEnd?.call('BELDEX_Wallet_getReceivedFromDeviceLength');
  return ret;
}

@Deprecated("TODO")
bool Wallet_getWaitsForDeviceSend() {
  debugStart?.call('BELDEX_Wallet_getWaitsForDeviceSend');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_getWaitsForDeviceSend();
  debugEnd?.call('BELDEX_Wallet_getWaitsForDeviceSend');
  return ret;
}

@Deprecated("TODO")
bool Wallet_getWaitsForDeviceReceive() {
  debugStart?.call('BELDEX_Wallet_getWaitsForDeviceReceive');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_getWaitsForDeviceReceive();
  debugEnd?.call('BELDEX_Wallet_getWaitsForDeviceReceive');
  return ret;
}

@Deprecated("TODO")
void Wallet_setDeviceReceivedData(Pointer<UnsignedChar> data, int len) {
  debugStart?.call('BELDEX_Wallet_setDeviceReceivedData');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_setDeviceReceivedData(data, len);
  debugEnd?.call('BELDEX_Wallet_setDeviceReceivedData');
  return ret;
}

@Deprecated("TODO")
void Wallet_setDeviceSendData(Pointer<UnsignedChar> data, int len) {
  debugStart?.call('BELDEX_Wallet_setDeviceSendData');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_setDeviceSendData(data, len);
  debugEnd?.call('BELDEX_Wallet_setDeviceSendData');
  return ret;
}

@Deprecated("TODO")
void Wallet_setLedgerCallback(Pointer<NativeFunction<Void Function(Pointer<UnsignedChar>, UnsignedInt)>> callback) {
  debugStart?.call('BELDEX_Wallet_setDeviceSendData');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_setLedgerCallback(callback);
  debugEnd?.call('BELDEX_Wallet_setDeviceSendData');
  return ret;
}

@Deprecated("TODO")
String BELDEX_Wallet_serializeCacheToJson(wallet ptr) {
  debugStart?.call('BELDEX_Wallet_serializeCacheToJson');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final ret = lib!.BELDEX_Wallet_serializeCacheToJson(ptr);
  final str = ret.cast<Utf8>().toDartString();
  BELDEX_free(ret.cast());
  debugEnd?.call('BELDEX_Wallet_serializeCacheToJson');
  return str;
}

// WalletManager
@Deprecated("TODO")
typedef WalletManager = Pointer<Void>;

@Deprecated("TODO")
wallet WalletManager_createWallet(
  WalletManager wm_ptr, {
  required String path,
  required String password,
  String language = "English",
  int networkType = 0,
}) {
  debugStart?.call('BELDEX_WalletManager_createWallet');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final language_ = language.toNativeUtf8().cast<Char>();
  final w = lib!.BELDEX_WalletManager_createWallet(
      wm_ptr, path_, password_, language_, networkType);
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(language_);
  debugEnd?.call('BELDEX_WalletManager_createWallet');
  return w;
}

@Deprecated("TODO")
wallet WalletManager_openWallet(
  WalletManager wm_ptr, {
  required String path,
  required String password,
  int networkType = 0,
}) {
  debugStart?.call('BELDEX_WalletManager_openWallet');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final w = lib!
      .BELDEX_WalletManager_openWallet(wm_ptr, path_, password_, networkType);
  calloc.free(path_);
  calloc.free(password_);
  debugEnd?.call('BELDEX_WalletManager_openWallet');
  return w;
}

@Deprecated("TODO")
wallet WalletManager_recoveryWallet(
  WalletManager wm_ptr, {
  required String path,
  required String password,
  required String mnemonic,
  int networkType = 0,
  required int restoreHeight,
  int kdfRounds = 0,
  required String seedOffset,
}) {
  debugStart?.call('BELDEX_WalletManager_recoveryWallet');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final mnemonic_ = mnemonic.toNativeUtf8().cast<Char>();
  final seedOffset_ = seedOffset.toNativeUtf8().cast<Char>();
  final w = lib!.BELDEX_WalletManager_recoveryWallet(wm_ptr, path_, password_,
      mnemonic_, networkType, restoreHeight, kdfRounds, seedOffset_);
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(mnemonic_);
  calloc.free(seedOffset_);
  debugEnd?.call('BELDEX_WalletManager_recoveryWallet');
  return w;
}

@Deprecated("TODO")
wallet WalletManager_createWalletFromKeys(
  WalletManager wm_ptr, {
  required String path,
  required String password,
  String language = "English",
  int nettype = 1,
  required int restoreHeight,
  required String addressString,
  required String viewKeyString,
  required String spendKeyString,
  int kdf_rounds = 1,
}) {
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  debugStart?.call('BELDEX_WalletManager_createWalletFromKeys');

  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final language_ = language.toNativeUtf8().cast<Char>();
  final addressString_ = addressString.toNativeUtf8().cast<Char>();
  final viewKeyString_ = viewKeyString.toNativeUtf8().cast<Char>();
  final spendKeyString_ = spendKeyString.toNativeUtf8().cast<Char>();

  final w = lib!.BELDEX_WalletManager_createWalletFromKeys(
    wm_ptr,
    path_,
    password_,
    language_,
    nettype,
    restoreHeight,
    addressString_,
    viewKeyString_,
    spendKeyString_,
    kdf_rounds,
  );
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(language_);
  calloc.free(addressString_);
  calloc.free(viewKeyString_);
  calloc.free(spendKeyString_);
  debugEnd?.call('BELDEX_WalletManager_createWalletFromKeys');
  return w;
}

@Deprecated("TODO")
wallet WalletManager_createDeterministicWalletFromSpendKey(
  WalletManager wm_ptr, {
  required String path,
  required String password,
  int networkType = 0,
  required String language,
  required String spendKeyString,
  required bool newWallet,
  required int restoreHeight,
  int kdfRounds = 1,
}) {
  debugStart
      ?.call('BELDEX_WalletManager_createDeterministicWalletFromSpendKey');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final language_ = language.toNativeUtf8().cast<Char>();
  final spendKeyString_ = spendKeyString.toNativeUtf8().cast<Char>();
  final w = lib!.BELDEX_WalletManager_createDeterministicWalletFromSpendKey(
      wm_ptr,
      path_,
      password_,
      language_,
      networkType,
      restoreHeight,
      spendKeyString_,
      kdfRounds);
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(language_);
  calloc.free(spendKeyString_);
  debugEnd?.call('BELDEX_WalletManager_createDeterministicWalletFromSpendKey');
  return w;
}

@Deprecated("TODO")
wallet WalletManager_createWalletFromDevice(
  WalletManager wm_ptr, {
  required String path,
  required String password,
  int networkType = 0,
  required String deviceName,
  int restoreHeight = 0,
  String subaddressLookahead = "",
  int kdfRounds = 1,
}) {
  debugStart?.call('BELDEX_WalletManager_createWalletFromDevice');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final deviceName_ = deviceName.toNativeUtf8().cast<Char>();
  final subaddressLookahead_ = subaddressLookahead.toNativeUtf8().cast<Char>();
  final w = lib!.BELDEX_WalletManager_createWalletFromDevice(
      wm_ptr,
      path_,
      password_,
      networkType,
      deviceName_,
      restoreHeight,
      subaddressLookahead_,
      defaultSeparator, // ignore
      defaultSeparator, // ignore
      kdfRounds);
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(deviceName_);
  calloc.free(subaddressLookahead_);
  debugEnd?.call('BELDEX_WalletManager_createWalletFromDevice');
  return w;
}

@Deprecated("TODO")
wallet WalletManager_createWalletFromPolyseed(
  WalletManager wm_ptr, {
  required String path,
  required String password,
  int networkType = 0,
  required String mnemonic,
  required String seedOffset,
  required bool newWallet,
  required int restoreHeight,
  required int kdfRounds,
}) {
  debugStart?.call('BELDEX_WalletManager_createWalletFromPolyseed');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final mnemonic_ = mnemonic.toNativeUtf8().cast<Char>();
  final seedOffset_ = seedOffset.toNativeUtf8().cast<Char>();
  final w = lib!.BELDEX_WalletManager_createWalletFromPolyseed(
      wm_ptr,
      path_,
      password_,
      networkType,
      mnemonic_,
      seedOffset_,
      newWallet,
      restoreHeight,
      kdfRounds);
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(mnemonic_);
  calloc.free(seedOffset_);
  debugEnd?.call('BELDEX_WalletManager_createWalletFromPolyseed');
  return w;
}

@Deprecated("TODO")
bool WalletManager_closeWallet(WalletManager wm_ptr, wallet ptr, bool store) {
  debugStart?.call('BELDEX_WalletManager_closeWallet');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final closeWallet = lib!.BELDEX_WalletManager_closeWallet(wm_ptr, ptr, store);
  debugEnd?.call('BELDEX_WalletManager_closeWallet');
  return closeWallet;
}

@Deprecated("TODO")
bool WalletManager_walletExists(WalletManager wm_ptr, String path) {
  debugStart?.call('BELDEX_WalletManager_walletExists');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_WalletManager_walletExists(wm_ptr, path_);
  calloc.free(path_);
  debugEnd?.call('BELDEX_WalletManager_walletExists');
  return s;
}

@Deprecated("TODO")
bool WalletManager_verifyWalletPassword(
  WalletManager wm_ptr, {
  required String keysFileName,
  required String password,
  required bool noSpendKey,
  required int kdfRounds,
}) {
  debugStart?.call('BELDEX_WalletManager_verifyWalletPassword');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final keysFileName_ = keysFileName.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_WalletManager_verifyWalletPassword(
      wm_ptr, keysFileName_, password_, noSpendKey, kdfRounds);
  calloc.free(keysFileName_);
  calloc.free(password_);
  debugEnd?.call('BELDEX_WalletManager_verifyWalletPassword');
  return s;
}

@Deprecated("TODO")
int WalletManager_queryWalletDevice(
    WalletManager wm_ptr, {
      required String keysFileName,
      required String password,
      required int kdfRounds,
    }) {
  debugStart?.call('BELDEX_WalletManager_queryWalletDevice');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final keysFileName_ = keysFileName.toNativeUtf8().cast<Char>();
  final password_ = password.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_WalletManager_queryWalletDevice(
      wm_ptr, keysFileName_, password_, kdfRounds);
  calloc.free(keysFileName_);
  calloc.free(password_);
  debugEnd?.call('BELDEX_WalletManager_queryWalletDevice');
  return s;
}

@Deprecated("TODO")
List<String> WalletManager_findWallets(WalletManager wm_ptr,
    {required String path}) {
  debugStart?.call('BELDEX_WalletManager_findWallets');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final path_ = path.toNativeUtf8().cast<Char>();
    final strPtr = lib!
        .BELDEX_WalletManager_findWallets(wm_ptr, path_, defaultSeparator)
        .cast<Utf8>();
    final str = strPtr.toDartString();
    calloc.free(path_);
    if (str.isNotEmpty) {
      BELDEX_free(strPtr.cast());
    }
    debugEnd?.call('BELDEX_WalletManager_findWallets');
    return str.split(";");
  } catch (e) {
    errorHandler?.call('BELDEX_WalletManager_findWallets', e);
    debugEnd?.call('BELDEX_WalletManager_findWallets');
    return [];
  }
}

@Deprecated("TODO")
String WalletManager_errorString(WalletManager wm_ptr) {
  debugStart?.call('BELDEX_WalletManager_errorString');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  try {
    final strPtr = lib!.BELDEX_WalletManager_errorString(wm_ptr).cast<Utf8>();
    final str = strPtr.toDartString();
    BELDEX_free(strPtr.cast());
    debugEnd?.call('BELDEX_WalletManager_errorString');
    return str;
  } catch (e) {
    errorHandler?.call('BELDEX_WalletManager_errorString', e);
    debugEnd?.call('BELDEX_WalletManager_errorString');
    return "";
  }
}

@Deprecated("TODO")
void WalletManager_setDaemonAddress(WalletManager wm_ptr, String address) {
  debugStart?.call('BELDEX_WalletManager_setDaemonAddress');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final address_ = address.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_WalletManager_setDaemonAddress(wm_ptr, address_);
  calloc.free(address_);
  debugEnd?.call('BELDEX_WalletManager_setDaemonAddress');
  return s;
}

@Deprecated("TODO")
int WalletManager_blockchainHeight(WalletManager wm_ptr) {
  debugStart?.call('BELDEX_WalletManager_blockchainHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_WalletManager_blockchainHeight(wm_ptr);
  debugEnd?.call('BELDEX_WalletManager_blockchainHeight');
  return s;
}

@Deprecated("TODO")
int WalletManager_blockchainTargetHeight(WalletManager wm_ptr) {
  debugStart?.call('BELDEX_WalletManager_blockchainTargetHeight');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_WalletManager_blockchainTargetHeight(wm_ptr);
  debugEnd?.call('BELDEX_WalletManager_blockchainTargetHeight');
  return s;
}

@Deprecated("TODO")
int WalletManager_networkDifficulty(WalletManager wm_ptr) {
  debugStart?.call('BELDEX_WalletManager_networkDifficulty');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_WalletManager_networkDifficulty(wm_ptr);
  debugEnd?.call('BELDEX_WalletManager_networkDifficulty');
  return s;
}

@Deprecated("TODO")
int WalletManager_blockTarget(WalletManager wm_ptr) {
  debugStart?.call('BELDEX_WalletManager_blockTarget');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_WalletManager_blockTarget(wm_ptr);
  debugEnd?.call('BELDEX_WalletManager_blockTarget');
  return s;
}

@Deprecated("TODO")
bool WalletManager_setProxy(WalletManager wm_ptr, String address) {
  debugStart?.call('BELDEX_WalletManager_setProxy');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final address_ = address.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_WalletManager_setProxy(wm_ptr, address_);
  calloc.free(address_);
  debugEnd?.call('BELDEX_WalletManager_setProxy');
  return s;
}

@Deprecated("TODO")
void WalletManagerFactory_setLogLevel(int level) {
  debugStart?.call('BELDEX_WalletManagerFactory_setLogLevel');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_WalletManagerFactory_setLogLevel(level);
  debugEnd?.call('BELDEX_WalletManagerFactory_setLogLevel');
  return s;
}

@Deprecated("TODO")
void WalletManagerFactory_setLogCategories(String categories) {
  debugStart?.call('BELDEX_WalletManagerFactory_setLogCategories');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final categories_ = categories.toNativeUtf8().cast<Char>();
  final s = lib!.BELDEX_WalletManagerFactory_setLogCategories(categories_);
  calloc.free(categories_);
  debugEnd?.call('BELDEX_WalletManagerFactory_setLogCategories');
  return s;
}

@Deprecated("TODO")
WalletManager WalletManagerFactory_getWalletManager() {
  debugStart?.call('BELDEX_WalletManagerFactory_getWalletManager');
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  final s = lib!.BELDEX_WalletManagerFactory_getWalletManager();
  debugEnd?.call('BELDEX_WalletManagerFactory_getWalletManager');
  return s;
}

// class LogLevel {
//   int get LogLevel_Silent => lib!.LogLevel_Silent;
//   int get LogLevel_0 => lib!.LogLevel_0;
//   int get LogLevel_1 => lib!.LogLevel_1;
//   int get LogLevel_2 => lib!.LogLevel_2;
//   int get LogLevel_3 => lib!.LogLevel_3;
//   int get LogLevel_4 => lib!.LogLevel_4;
//   int get LogLevel_Min => LogLevel_Silent;
//   int get LogLevel_Max => lib!.LogLevel_4;
// }

// class ConnectionStatus {
//   int get Disconnected => lib!.WalletConnectionStatus_Disconnected;
//   int get Connected => lib!.WalletConnectionStatus_Connected;
//   int get WrongVersion => lib!.WalletConnectionStatus_WrongVersion;
// }

// DEBUG

@Deprecated("TODO")
class libOk {
  libOk(
    this.test1,
    this.test2,
    this.test3,
    this.test4,
    this.test5,
    this.test5_std,
  );
  final bool test1;
  final int test2;
  final int test3;
  final Pointer<Void> test4;
  final Pointer<Char> test5;
  String get test5_str {
    try {
      return test5.cast<Utf8>().toDartString();
    } catch (e) {
      return "$e";
    }
  }

  String get test5_str16 {
    try {
      return test5.cast<Utf16>().toDartString();
    } catch (e) {
      return "$e";
    }
  }

  final Pointer<Char> test5_std;
  String get test5_std_str {
    try {
      return test5_std.cast<Utf8>().toDartString();
    } catch (e) {
      return "$e";
    }
  }

  String get test5_std_str16 {
    try {
      return test5_std.cast<Utf16>().toDartString();
    } catch (e) {
      return "$e";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "test1": test1,
      "test2": test2,
      "test3": test3,
      "test4": test4.toString(),
      "test5": test5.toString(),
      "test5_str": test5_str,
      "test5_std": test5_std.toString(),
      "test5_std_str": test5_std_str,
    };
  }
}

@Deprecated("TODO")
libOk isLibOk() {
  lib ??= BeldexC(DynamicLibrary.open(libPath));
  lib!.BELDEX_DEBUG_test0();
  final test1 = lib!.BELDEX_DEBUG_test1(true);
  final test2 = lib!.BELDEX_DEBUG_test2(-1);
  final test3 = lib!.BELDEX_DEBUG_test3(1);
  final test4 = lib!.BELDEX_DEBUG_test4(1);
  final test5 = lib!.BELDEX_DEBUG_test5();
  final test5_std = lib!.BELDEX_DEBUG_test5_std();
  return libOk(test1, test2, test3, test4, test5, test5_std);
}

// cake world

@Deprecated("TODO")
typedef WalletListener = Pointer<Void>;

@Deprecated("TODO")
WalletListener BELDEX_cw_getWalletListener(wallet wptr) {
  debugStart?.call('BELDEX_cw_getWalletListener');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_cw_getWalletListener(wptr);
  debugEnd?.call('BELDEX_cw_getWalletListener');
  return s;
}

void BELDEX_cw_WalletListener_resetNeedToRefresh(WalletListener wlptr) {
  debugStart?.call('BELDEX_cw_WalletListener_resetNeedToRefresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_cw_WalletListener_resetNeedToRefresh(wlptr);
  debugEnd?.call('BELDEX_cw_WalletListener_resetNeedToRefresh');
  return s;
}

@Deprecated("TODO")
bool BELDEX_cw_WalletListener_isNeedToRefresh(WalletListener wlptr) {
  debugStart?.call('BELDEX_cw_WalletListener_isNeedToRefresh');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_cw_WalletListener_isNeedToRefresh(wlptr);
  debugEnd?.call('BELDEX_cw_WalletListener_isNeedToRefresh');
  return s;
}

@Deprecated("TODO")
bool BELDEX_cw_WalletListener_isNewTransactionExist(WalletListener wlptr) {
  debugStart?.call('BELDEX_cw_WalletListener_isNewTransactionExist');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_cw_WalletListener_isNewTransactionExist(wlptr);
  debugEnd?.call('BELDEX_cw_WalletListener_isNewTransactionExist');
  return s;
}

@Deprecated("TODO")
void BELDEX_cw_WalletListener_resetIsNewTransactionExist(WalletListener wlptr) {
  debugStart?.call('BELDEX_cw_WalletListener_resetIsNewTransactionExist');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_cw_WalletListener_resetIsNewTransactionExist(wlptr);
  debugEnd?.call('BELDEX_cw_WalletListener_resetIsNewTransactionExist');
  return s;
}

@Deprecated("TODO")
int BELDEX_cw_WalletListener_height(WalletListener wlptr) {
  debugStart?.call('BELDEX_cw_WalletListener_height');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_cw_WalletListener_height(wlptr);
  debugEnd?.call('BELDEX_cw_WalletListener_height');
  return s;
}

@Deprecated("TODO")
String BELDEX_checksum_wallet2_api_c_h() {
  debugStart?.call('BELDEX_checksum_wallet2_api_c_h');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_checksum_wallet2_api_c_h();
  debugEnd?.call('BELDEX_checksum_wallet2_api_c_h');
  return s.cast<Utf8>().toDartString();
}

@Deprecated("TODO")
String BELDEX_checksum_wallet2_api_c_cpp() {
  debugStart?.call('BELDEX_checksum_wallet2_api_c_cpp');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_checksum_wallet2_api_c_cpp();
  debugEnd?.call('BELDEX_checksum_wallet2_api_c_cpp');
  return s.cast<Utf8>().toDartString();
}

@Deprecated("TODO")
String BELDEX_checksum_wallet2_api_c_exp() {
  debugStart?.call('BELDEX_checksum_wallet2_api_c_exp');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_checksum_wallet2_api_c_exp();
  debugEnd?.call('BELDEX_checksum_wallet2_api_c_exp');
  return s.cast<Utf8>().toDartString();
}

@Deprecated("TODO")
void BELDEX_free(Pointer<Void> wlptr) {
  debugStart?.call('BELDEX_free');
  lib ??= BeldexC(DynamicLibrary.open(libPath));

  final s = lib!.BELDEX_free(wlptr);
  debugEnd?.call('BELDEX_free');
  return s;
}
