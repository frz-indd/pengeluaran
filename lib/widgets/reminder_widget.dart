import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class ReminderWidget extends StatefulWidget {
  const ReminderWidget({super.key});

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadReminderStatus();
  }

  Future<void> _loadReminderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderEnabled = prefs.getBool('reminder_enabled') ?? true;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', value);

    if (value) {
      await NotificationService().setDailyReminderAt8AM();
    } else {
      await NotificationService().cancelReminder();
    }

    setState(() {
      _reminderEnabled = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '✅ Pengingat diaktifkan (8 pagi setiap hari)'
                : '❌ Pengingat dinonaktifkan',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _reminderEnabled
            ? Colors.blue.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: _reminderEnabled ? Colors.blue : Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _reminderEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _reminderEnabled ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pengingat Pengeluaran',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _reminderEnabled ? 'Setiap hari pukul 8 pagi' : 'Dinonaktifkan',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          Switch(value: _reminderEnabled, onChanged: _toggleReminder),
        ],
      ),
    );
  }
}
