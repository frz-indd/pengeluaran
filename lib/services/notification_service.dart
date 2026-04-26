import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize local notifications
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Initialize Android Alarm Manager
    await AndroidAlarmManager.initialize();
  }

  // Static function untuk dipanggil oleh alarm manager
  static Future<void> showDailyReminder() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'reminder_channel',
          'Daily Reminder',
          channelDescription: 'Daily reminder untuk mencatat pengeluaran',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Pengingat Pengeluaran',
      'jangan lupa catat pengeluaranmu ya sayanggg',
      platformChannelSpecifics,
    );
  }

  // Fungsi untuk set alarm reminder
  Future<void> setDailyReminderAt8AM() async {
    try {
      // Get current time
      final now = DateTime.now();

      // Set reminder untuk 8 AM
      var reminderTime = DateTime(now.year, now.month, now.day, 8, 0, 0);

      // Jika sudah lewat 8 AM hari ini, set untuk besok
      if (now.isAfter(reminderTime)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }

      // Cancel existing alarms
      await AndroidAlarmManager.cancel(0);

      // Set alarm manager untuk setiap hari pukul 8 AM
      await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        0,
        showDailyReminder,
        startAt: reminderTime,
        exact: true,
        wakeup: true,
      );

      print('✅ Reminder set untuk 8 AM setiap hari');
    } catch (e) {
      print('❌ Error setting reminder: $e');
    }
  }

  // Cancel reminder
  Future<void> cancelReminder() async {
    try {
      await AndroidAlarmManager.cancel(0);
      print('✅ Reminder dibatalkan');
    } catch (e) {
      print('❌ Error canceling reminder: $e');
    }
  }
}
