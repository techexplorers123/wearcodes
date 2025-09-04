import 'dart:convert';
import 'package:flutter/services.dart';

class SyncBridge {
  static const MethodChannel _channel = MethodChannel('wear_sync');
  static const EventChannel _updates = EventChannel('wear_sync/updates');

  /// PHONE → WATCH: send codes via Data Layer
  static Future<void> sendCodes(List<Map<String, String>> codes) async {
    final payload = codes.map((m) => jsonEncode(m)).toList();
    await _channel.invokeMethod('sendCodes', {'codes': payload});
  }

  /// WATCH: listen for background updates (Service emits these)
  static Stream<void> get updates =>
      _updates.receiveBroadcastStream().map((_) => null);
}
