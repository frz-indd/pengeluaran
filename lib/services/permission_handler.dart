import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();

    if (status.isDenied) {
      print('❌ Notification permission denied');
    } else if (status.isGranted) {
      print('✅ Notification permission granted');
    } else if (status.isPermanentlyDenied) {
      print(
        '⚠️ Notification permission permanently denied, opening app settings',
      );
      openAppSettings();
    }
  }
}
