import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const int _dailyAlarmId = 0;
  static const int _dailyNotificationId = 0;
  static const int _breakfastAlarmId = 1;
  static const int _breakfastNotificationId = 1;

  static const String _prefBreakfastScheduled =
      'breakfast_reminder_scheduled_v1';

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

  static Future<FlutterLocalNotificationsPlugin>
  _initPluginForAlarmCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    tz_data.initializeTimeZones();

    final plugin = FlutterLocalNotificationsPlugin();

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

    await plugin.initialize(initializationSettings);
    return plugin;
  }

  // Static function untuk dipanggil oleh alarm manager
  @pragma('vm:entry-point')
  static Future<void> showDailyReminder() async {
    final flutterLocalNotificationsPlugin = await _initPluginForAlarmCallback();

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
      _dailyNotificationId,
      'Pengingat Pengeluaran',
      'jangan lupa catat pengeluaranmu ya sayanggg',
      platformChannelSpecifics,
    );
  }

  // Static function untuk dipanggil oleh alarm manager (1x sarapan)
  @pragma('vm:entry-point')
  static Future<void> showBreakfastReminder() async {
    final flutterLocalNotificationsPlugin = await _initPluginForAlarmCallback();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'breakfast_channel',
          'Breakfast Reminder',
          channelDescription: 'Pengingat sarapan',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      _breakfastNotificationId,
      'Pengingat Sarapan',
      'jangan lupa sarapan sebelum berangkat ya sayang',
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
      await AndroidAlarmManager.cancel(_dailyAlarmId);

      // Set alarm manager untuk setiap hari pukul 8 AM
      await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        _dailyAlarmId,
        showDailyReminder,
        startAt: reminderTime,
        exact: true,
        wakeup: true,
      );

      if (kDebugMode) {
        debugPrint('✅ Reminder set untuk 8 AM setiap hari');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error setting reminder: $e');
      }
    }
  }

  // Pengingat sarapan 1x saja (pada 06:30 berikutnya)
  Future<void> scheduleBreakfastReminderOnceAt630AM() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_prefBreakfastScheduled) == true) return;

      final now = DateTime.now();
      var reminderTime = DateTime(now.year, now.month, now.day, 6, 30, 0);
      if (now.isAfter(reminderTime)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }

      await AndroidAlarmManager.cancel(_breakfastAlarmId);
      final scheduled = await AndroidAlarmManager.oneShotAt(
        reminderTime,
        _breakfastAlarmId,
        showBreakfastReminder,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      if (scheduled) {
        await prefs.setBool(_prefBreakfastScheduled, true);
      } else if (kDebugMode) {
        debugPrint('Breakfast reminder not scheduled (returned false).');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error scheduling breakfast reminder: $e');
      }
    }
  }

  // Cancel reminder
  Future<void> cancelReminder() async {
    try {
      await AndroidAlarmManager.cancel(_dailyAlarmId);
      if (kDebugMode) {
        debugPrint('✅ Reminder dibatalkan');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error canceling reminder: $e');
      }
    }
  }

  Future<void> cancelBreakfastReminder() async {
    try {
      await AndroidAlarmManager.cancel(_breakfastAlarmId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefBreakfastScheduled, false);
    } catch (_) {
      // ignore
    }
  }
}
