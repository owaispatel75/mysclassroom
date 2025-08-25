import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifier {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: android);
    await _plugin.initialize(init);
  }

  static Future<void> showOtp(String otp) async {
    const androidDetails = AndroidNotificationDetails(
      'otp_channel',
      'OTP',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(0, 'Your OTP', 'OTP: $otp', details);
  }
}
