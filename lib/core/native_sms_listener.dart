import 'package:flutter/services.dart';
import 'sms_parser.dart';

class NativeSmsListener {
  static const platform = MethodChannel('sms_channel');

  static void startListening(Function(String) onSms) {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onSmsReceived") {
        final sms = call.arguments as String;
        onSms(sms);
      }
    });
  }
}
