import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<List<SmsMessage>> getRecentMessages() async {
    bool granted = await requestPermission();
    if (!granted) return [];

    return await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 20,
    );
  }
}
