
// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:monero/src/generated_bindings_zano.g.dart';

export 'src/checksum_monero.dart';

typedef PendingTransaction = Pointer<Void>;

ZanoC? lib;
String libPath = (() {
  if (Platform.isWindows) return 'zano_libwallet2_api_c.dll';
  if (Platform.isMacOS) return 'zano_libwallet2_api_c.dylib';
  if (Platform.isIOS) return 'ZanoWallet.framework/ZanoWallet';
  if (Platform.isAndroid) return 'libzano_libwallet2_api_c.so';
  return 'zano_libwallet2_api_c.so';
})();

Map<String, List<int>> debugCallLength = {};

final defaultSeparatorStr = ";";
final defaultSeparator = defaultSeparatorStr.toNativeUtf8().cast<Char>();
/* we don't call .free here, this comment serves one purpose - so the numbers match :) */

final Stopwatch sw = Stopwatch()..start();

bool printStarts = false;

void Function(String call)? debugStart = (call) {
  try {
    if (printStarts) print("MONERO: $call");
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

// extern ADDAPI const char* ZANO_PlainWallet_init(const char* address, const char* working_dir, int log_level);
String PlainWallet_init(String address, String working_dir, int log_level) {
  debugStart?.call('ZANO_PlainWallet_init');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final address_ = address.toNativeUtf8();
  final working_dir_ = working_dir.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_init(address_.cast(), working_dir_.cast(), log_level);
  calloc.free(address_);
  calloc.free(working_dir_);
  debugEnd?.call('ZANO_PlainWallet_init');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_init');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_init', e);
    debugEnd?.call('ZANO_PlainWallet_init');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_init2(const char* ip, const char* port, const char* working_dir, int log_level);
String PlainWallet_init2(String ip, String port, String working_dir, int log_level) {
  debugStart?.call('ZANO_PlainWallet_init2');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final ip_ = ip.toNativeUtf8();
  final port_ = port.toNativeUtf8();
  final working_dir_ = working_dir.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_init2(ip_.cast(), port_.cast(), working_dir_.cast(), log_level);
  calloc.free(ip_);
  calloc.free(port_);
  calloc.free(working_dir_);
  debugEnd?.call('ZANO_PlainWallet_init2');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_init2');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_init2', e);
    debugEnd?.call('ZANO_PlainWallet_init2');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_reset();
String PlainWallet_reset() {
  debugStart?.call('ZANO_PlainWallet_reset');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_reset();
  debugEnd?.call('ZANO_PlainWallet_reset');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_reset');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_reset', e);
    debugEnd?.call('ZANO_PlainWallet_reset');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_setLogLevel(int log_level);
String PlainWallet_setLogLevel(int log_level) {
  debugStart?.call('ZANO_PlainWallet_setLogLevel');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_setLogLevel(log_level);
  debugEnd?.call('ZANO_PlainWallet_setLogLevel');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_setLogLevel');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_setLogLevel', e);
    debugEnd?.call('ZANO_PlainWallet_setLogLevel');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getVersion();
String PlainWallet_getVersion() {
  debugStart?.call('ZANO_PlainWallet_getVersion');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getVersion();
  debugEnd?.call('ZANO_PlainWallet_getVersion');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getVersion');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getVersion', e);
    debugEnd?.call('ZANO_PlainWallet_getVersion');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getWalletFiles();
String PlainWallet_getWalletFiles() {
  debugStart?.call('ZANO_PlainWallet_getWalletFiles');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getWalletFiles();
  debugEnd?.call('ZANO_PlainWallet_getWalletFiles');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getWalletFiles');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getWalletFiles', e);
    debugEnd?.call('ZANO_PlainWallet_getWalletFiles');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getExportPrivateInfo(const char* target_dir);
String PlainWallet_getExportPrivateInfo(String target_dir) {
  debugStart?.call('ZANO_PlainWallet_getExportPrivateInfo');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final target_dir_ = target_dir.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_getExportPrivateInfo(target_dir_.cast());
  calloc.free(target_dir_);
  debugEnd?.call('ZANO_PlainWallet_getExportPrivateInfo');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getExportPrivateInfo');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getExportPrivateInfo', e);
    debugEnd?.call('ZANO_PlainWallet_getExportPrivateInfo');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_deleteWallet(const char* file_name);
String PlainWallet_deleteWallet(String file_name) {
  debugStart?.call('ZANO_PlainWallet_deleteWallet');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final file_name_ = file_name.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_deleteWallet(file_name_.cast());
  calloc.free(file_name_);
  debugEnd?.call('ZANO_PlainWallet_deleteWallet');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_deleteWallet');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_deleteWallet', e);
    debugEnd?.call('ZANO_PlainWallet_deleteWallet');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getAddressInfo(const char* addr);
String PlainWallet_getAddressInfo(String addr) {
  debugStart?.call('ZANO_PlainWallet_getAddressInfo');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final addr_ = addr.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_getAddressInfo(addr_.cast());
  calloc.free(addr_);
  debugEnd?.call('ZANO_PlainWallet_getAddressInfo');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getAddressInfo');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getAddressInfo', e);
    debugEnd?.call('ZANO_PlainWallet_getAddressInfo');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getAppconfig(const char* encryption_key);
String PlainWallet_getAppconfig(String encryption_key) {
  debugStart?.call('ZANO_PlainWallet_getAppconfig');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final encryption_key_ = encryption_key.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_getAppconfig(encryption_key_.cast());
  calloc.free(encryption_key_);
  debugEnd?.call('ZANO_PlainWallet_getAppconfig');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getAppconfig');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getAppconfig', e);
    debugEnd?.call('ZANO_PlainWallet_getAppconfig');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_setAppconfig(const char* conf_str, const char* encryption_key);
String PlainWallet_setAppconfig(String conf_str, String encryption_key) {
  debugStart?.call('ZANO_PlainWallet_setAppconfig');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final conf_str_ = conf_str.toNativeUtf8();
  final encryption_key_ = encryption_key.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_setAppconfig(conf_str_.cast(), encryption_key_.cast());
  calloc.free(conf_str_);
  calloc.free(encryption_key_);
  debugEnd?.call('ZANO_PlainWallet_setAppconfig');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_setAppconfig');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_setAppconfig', e);
    debugEnd?.call('ZANO_PlainWallet_setAppconfig');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_generateRandomKey(uint64_t lenght);
String PlainWallet_generateRandomKey(int length) {
  debugStart?.call('ZANO_PlainWallet_generateRandomKey');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_generateRandomKey(length);
  debugEnd?.call('ZANO_PlainWallet_generateRandomKey');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_generateRandomKey');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_generateRandomKey', e);
    debugEnd?.call('ZANO_PlainWallet_generateRandomKey');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getLogsBuffer();
String PlainWallet_getLogsBuffer() {
  debugStart?.call('ZANO_PlainWallet_getLogsBuffer');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getLogsBuffer();
  debugEnd?.call('ZANO_PlainWallet_getLogsBuffer');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getLogsBuffer');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getLogsBuffer', e);
    debugEnd?.call('ZANO_PlainWallet_getLogsBuffer');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_truncateLog();
String PlainWallet_truncateLog() {
  debugStart?.call('ZANO_PlainWallet_truncateLog');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_truncateLog();
  debugEnd?.call('ZANO_PlainWallet_truncateLog');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_truncateLog');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_truncateLog', e);
    debugEnd?.call('ZANO_PlainWallet_truncateLog');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getConnectivityStatus();
String PlainWallet_getConnectivityStatus() {
  debugStart?.call('ZANO_PlainWallet_getConnectivityStatus');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getConnectivityStatus();
  debugEnd?.call('ZANO_PlainWallet_getConnectivityStatus');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getConnectivityStatus');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getConnectivityStatus', e);
    debugEnd?.call('ZANO_PlainWallet_getConnectivityStatus');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_open(const char* path, const char* password);
String PlainWallet_open(String path, String password) {
  debugStart?.call('ZANO_PlainWallet_open');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8();
  final password_ = password.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_open(path_.cast(), password_.cast());
  calloc.free(path_);
  calloc.free(password_);
  debugEnd?.call('ZANO_PlainWallet_open');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_open');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_open', e);
    debugEnd?.call('ZANO_PlainWallet_open');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_restore(const char* seed, const char* path, const char* password, const char* seed_password);
String PlainWallet_restore(String seed, String path, String password, String seed_password) {
  debugStart?.call('ZANO_PlainWallet_restore');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final seed_ = seed.toNativeUtf8();
  final path_ = path.toNativeUtf8();
  final password_ = password.toNativeUtf8();
  final seed_password_ = seed_password.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_restore(seed_.cast(), path_.cast(), password_.cast(), seed_password_.cast());
  calloc.free(seed_);
  calloc.free(path_);
  calloc.free(password_);
  calloc.free(seed_password_);
  debugEnd?.call('ZANO_PlainWallet_restore');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_restore');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_restore', e);
    debugEnd?.call('ZANO_PlainWallet_restore');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_generate(const char* path, const char* password);
String PlainWallet_generate(String path, String password) {
  debugStart?.call('ZANO_PlainWallet_generate');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8();
  final password_ = password.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_generate(path_.cast(), password_.cast());
  calloc.free(path_);
  calloc.free(password_);
  debugEnd?.call('ZANO_PlainWallet_generate');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_generate');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_generate', e);
    debugEnd?.call('ZANO_PlainWallet_generate');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getOpenWallets();
String PlainWallet_getOpenWallets() {
  debugStart?.call('ZANO_PlainWallet_getOpenWallets');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getOpenWallets();
  debugEnd?.call('ZANO_PlainWallet_getOpenWallets');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getOpenWallets');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getOpenWallets', e);
    debugEnd?.call('ZANO_PlainWallet_getOpenWallets');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_getWalletStatus(int64_t h);
String PlainWallet_getWalletStatus(int h) {
  debugStart?.call('ZANO_PlainWallet_getWalletStatus');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getWalletStatus(h);
  debugEnd?.call('ZANO_PlainWallet_getWalletStatus');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getWalletStatus');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getWalletStatus', e);
    debugEnd?.call('ZANO_PlainWallet_getWalletStatus');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_closeWallet(int64_t h);
String PlainWallet_closeWallet(int h) {
  debugStart?.call('ZANO_PlainWallet_closeWallet');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_closeWallet(h);
  debugEnd?.call('ZANO_PlainWallet_closeWallet');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_closeWallet');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_closeWallet', e);
    debugEnd?.call('ZANO_PlainWallet_closeWallet');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_invoke(int64_t h, const char* params);
String PlainWallet_invoke(int h, String params) {
  debugStart?.call('ZANO_PlainWallet_invoke');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final params_ = params.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_invoke(h, params_.cast());
  calloc.free(params_);
  debugEnd?.call('ZANO_PlainWallet_invoke');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_invoke');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_invoke', e);
    debugEnd?.call('ZANO_PlainWallet_invoke');
    return "";
  }
}

// extern ADDAPI const char* ZANO_PlainWallet_asyncCall(const char* method_name, uint64_t instance_id, const char* params);
String PlainWallet_asyncCall(String method_name, int h, String params) {
  debugStart?.call('ZANO_PlainWallet_asyncCall');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final params_ = params.toNativeUtf8();
  final method_name_ = method_name.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_asyncCall(method_name_.cast(), h, params_.cast());
  calloc.free(params_);
  calloc.free(method_name_);
  debugEnd?.call('ZANO_PlainWallet_asyncCall');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_asyncCall');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_asyncCall', e);
    debugEnd?.call('ZANO_PlainWallet_asyncCall');
    return "";
  }
}

// extern ADDAPI const char* ZANO_PlainWallet_tryPullResult(uint64_t instance_id);
String PlainWallet_tryPullResult(int instance_id) {
  debugStart?.call('ZANO_PlainWallet_tryPullResult');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_tryPullResult(instance_id);
  debugEnd?.call('ZANO_PlainWallet_tryPullResult');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_tryPullResult');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_tryPullResult', e);
    debugEnd?.call('ZANO_PlainWallet_tryPullResult');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_syncCall(const char* method_name, uint64_t instance_id, const char* params);
String PlainWallet_syncCall(String method_name, int instance_id, String params) {
  debugStart?.call('ZANO_PlainWallet_syncCall');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final method_name_ = method_name.toNativeUtf8();
  final params_ = params.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_syncCall(method_name_.cast(), instance_id, params_.cast());
  calloc.free(method_name_);
  calloc.free(params_);
  debugEnd?.call('ZANO_PlainWallet_syncCall');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_syncCall');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_syncCall', e);
    debugEnd?.call('ZANO_PlainWallet_syncCall');
    return "";
  }
}
// extern ADDAPI bool ZANO_PlainWallet_isWalletExist(const char* path);
bool PlainWallet_isWalletExist(String path) {
  debugStart?.call('ZANO_PlainWallet_isWalletExist');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final path_ = path.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_isWalletExist(path_.cast());
  calloc.free(path_);
  debugEnd?.call('ZANO_PlainWallet_isWalletExist');
  return txid;
}
// extern ADDAPI const char* ZANO_PlainWallet_getWalletInfo(int64_t h);
String PlainWallet_getWalletInfo(int h) {
  debugStart?.call('ZANO_PlainWallet_getWalletInfo');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getWalletInfo(h);
  debugEnd?.call('ZANO_PlainWallet_getWalletInfo');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_getWalletInfo');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_getWalletInfo', e);
    debugEnd?.call('ZANO_PlainWallet_getWalletInfo');
    return "";
  }
}
// extern ADDAPI const char* ZANO_PlainWallet_resetWalletPassword(int64_t h, const char* password);
String PlainWallet_resetWalletPassword(int h, String password) {
  debugStart?.call('ZANO_PlainWallet_resetWalletPassword');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final password_ = password.toNativeUtf8();
  final txid = lib!.ZANO_PlainWallet_resetWalletPassword(h, password_.cast());
  calloc.free(password_);
  debugEnd?.call('ZANO_PlainWallet_resetWalletPassword');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_PlainWallet_resetWalletPassword');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_PlainWallet_resetWalletPassword', e);
    debugEnd?.call('ZANO_PlainWallet_resetWalletPassword');
    return "";
  }
}
// extern ADDAPI uint64_t ZANO_PlainWallet_getCurrentTxFee(uint64_t priority);
int PlainWallet_getCurrentTxFee(int priority) {
  debugStart?.call('ZANO_PlainWallet_getCurrentTxFee');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_PlainWallet_getCurrentTxFee(priority);
  debugEnd?.call('ZANO_PlainWallet_getCurrentTxFee');
  return txid;
}

void ZANO_free(Pointer<Void> wlptr) {
  debugStart?.call('ZANO_free');
  lib ??= ZanoC(DynamicLibrary.open(libPath));

  final s = lib!.ZANO_free(wlptr);
  debugEnd?.call('ZANO_free');
  return s;
}

// extern ADDAPI const char* ZANO_checksum_wallet2_api_c_h();
String checksum_wallet2_api_c_h() {
  debugStart?.call('ZANO_checksum_wallet2_api_c_h');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_checksum_wallet2_api_c_h();
  debugEnd?.call('ZANO_checksum_wallet2_api_c_h');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_checksum_wallet2_api_c_h');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_checksum_wallet2_api_c_h', e);
    debugEnd?.call('ZANO_checksum_wallet2_api_c_h');
    return "";
  }
}
// extern ADDAPI const char* ZANO_checksum_wallet2_api_c_cpp();
String checksum_wallet2_api_c_cpp() {
  debugStart?.call('ZANO_checksum_wallet2_api_c_cpp');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_checksum_wallet2_api_c_cpp();
  debugEnd?.call('ZANO_checksum_wallet2_api_c_cpp');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_checksum_wallet2_api_c_cpp');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_checksum_wallet2_api_c_cpp', e);
    debugEnd?.call('ZANO_checksum_wallet2_api_c_cpp');
    return "";
  }
}
// extern ADDAPI const char* ZANO_checksum_wallet2_api_c_exp();
String checksum_wallet2_api_c_exp() {
  debugStart?.call('ZANO_checksum_wallet2_api_c_exp');
  lib ??= ZanoC(DynamicLibrary.open(libPath));
  final txid = lib!.ZANO_checksum_wallet2_api_c_exp();
  debugEnd?.call('ZANO_checksum_wallet2_api_c_exp');
  try {
    final strPtr = txid.cast<Utf8>();
    final str = strPtr.toDartString();
    ZANO_free(strPtr.cast());
    debugEnd?.call('ZANO_checksum_wallet2_api_c_exp');
    return str;
  } catch (e) {
    errorHandler?.call('ZANO_checksum_wallet2_api_c_exp', e);
    debugEnd?.call('ZANO_checksum_wallet2_api_c_exp');
    return "";
  }
}