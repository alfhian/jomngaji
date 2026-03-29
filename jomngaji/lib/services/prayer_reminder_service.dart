import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PrayerReminderService {
  PrayerReminderService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefEnabledKey = 'prayer_reminder_enabled';
  static const String _channelId = 'prayer_reminders';

  static const Map<String, ({int hour, int minute})> _defaultPrayerTimes = {
    'Subuh': (hour: 4, minute: 45),
    'Dzuhur': (hour: 12, minute: 0),
    'Ashar': (hour: 15, minute: 15),
    'Maghrib': (hour: 18, minute: 5),
    'Isya': (hour: 19, minute: 15),
  };

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, value);
  }

  static Future<void> enableDefaultReminders() async {
    await cancelAllReminders();
    await _scheduleDailyDefaultReminders();
    await setEnabled(true);
  }

  static Future<void> disableReminders() async {
    await cancelAllReminders();
    await setEnabled(false);
  }

  static Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  static Future<void> _scheduleDailyDefaultReminders() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Pengingat Waktu Sholat',
        channelDescription: 'Notifikasi pengingat waktu sholat harian',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    var id = 2000;
    for (final entry in _defaultPrayerTimes.entries) {
      final prayerName = entry.key;
      final time = entry.value;
      final next = _nextInstanceOfTime(time.hour, time.minute);

      await _plugin.zonedSchedule(
        id++,
        'Waktunya Sholat $prayerName',
        'Yuk tunaikan sholat $prayerName tepat waktu 🤲',
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
