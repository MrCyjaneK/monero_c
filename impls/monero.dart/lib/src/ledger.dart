import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:ledger_flutter/src/ledger.dart';
import 'package:ledger_flutter/src/ledger/ledger_operation.dart';
import 'package:ledger_flutter/src/models/ledger_device.dart';
import 'package:ledger_flutter/src/utils/buffer.dart';
import 'package:monero/monero.dart' as monero;

Timer? _ledgerExchangeTimer;
Uint8List _lastLedgerRequest = Uint8List(0);

void enableLedgerExchange(
    monero.wallet ptr, Ledger ledger, LedgerDevice device) {
  _ledgerExchangeTimer = Timer.periodic(Duration(milliseconds: 1), (_) async {
    final ledgerRequestLength = monero.Wallet_getSendToDeviceLength(ptr);
    final ledgerRequest = monero.Wallet_getSendToDevice(ptr)
        .cast<Uint8>()
        .asTypedList(ledgerRequestLength);
    if (ledgerRequestLength > 0 && _lastLedgerRequest != ledgerRequest) {
      final response = await exchange(ledger, device, ledgerRequest);

      final Pointer<Uint8> result = malloc<Uint8>(response.length);
      result.asTypedList(response.length).addAll(response);
      monero.Wallet_setDeviceReceivedData(
          ptr, result.cast<UnsignedChar>(), response.length);

      monero.Wallet_setDeviceSendData(
          ptr, malloc<Uint8>(0).cast<UnsignedChar>(), 0);
    }
  });
}

void disableLedgerExchange() {
  _ledgerExchangeTimer?.cancel();
}

Future<Uint8List> exchange(
    Ledger ledger, LedgerDevice device, Uint8List data) async {
  return ledger.sendOperation<Uint8List>(
    device,
    ExchangeOperation(
      cla: 0x00,
      ins: 0x00,
      p1: 0x00,
      p2: 0x00,
      inputData: data,
    ),
  );
}

class ExchangeOperation extends LedgerOperation<Uint8List> {
  final int cla;
  final int ins;
  final int p1;
  final int p2;
  final Uint8List inputData;

  ExchangeOperation({
    required this.cla,
    required this.ins,
    required this.p1,
    required this.p2,
    required this.inputData,
  });

  @override
  Future<Uint8List> read(ByteDataReader reader) async =>
      reader.read(reader.remainingLength);

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    writer.write(inputData);

    return [writer.toBytes()];
  }
}
