import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotifHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(init);
      _inited = true;
      if (kDebugMode) debugPrint('[Notif] init ok');
    } catch (e) {
      if (kDebugMode) debugPrint('[Notif] init fail: $e');
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  static Future<void> scheduleHungryReminder() async {
    if (!_inited) await init();
    try {
      await _plugin.cancelAll();
      const android = AndroidNotificationDetails('pet_hungry', 'Pet Lapar', importance: Importance.high, priority: Priority.high);
      const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());
      // 4 jam dari sekarang — simple one-shot; dijadwal ulang tiap resume
      await _plugin.zonedSchedule(
        1,
        'Pet lapar!',
        'Kasih makan biar tidak sedih.',
        tz.TZDateTime.now(tz.local).add(const Duration(hours: 4)),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      if (kDebugMode) debugPrint('[Notif] scheduled +4h');
    } catch (e) {
      if (kDebugMode) debugPrint('[Notif] schedule fail: $e');
    }
  }

  static Future<void> cancelAll() async {
    try { await _plugin.cancelAll(); } catch (_) {}
  }
}
