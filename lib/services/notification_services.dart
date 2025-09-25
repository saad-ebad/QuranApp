import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../database_helper/settings_db.dart';

class NotificationService {
  /// 🔧 Initialize notification channels & permissions
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // Default app icon
      [
        NotificationChannel(
          channelKey: 'daily_channel',
          channelName: 'Daily Notifications',
          channelDescription: 'Daily Quran reading reminders',
          importance: NotificationImportance.Max,
          defaultColor: Colors.green,
          ledColor: Colors.white,
          channelShowBadge: true,
        )
      ],
    );

    await requestNotificationPermissions();
  }

  /// 🛑 Ask user for notification permissions if not granted
  static Future<void> requestNotificationPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  /// 📅 Schedule daily reminder at specific time
  static Future<void> scheduleDailyNotification(
      int id, int hour, int minute, String title, String body,
      {bool repeatDaily = true}) async {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint("📅 Scheduling Notification ID: $id at $scheduledDate");

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'daily_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        millisecond: 0,
        repeats: repeatDaily,
        preciseAlarm: true,
      ),
    );
  }

  /// 📌 Schedule default reminders for user (10AM, 3PM, 8PM)
  static Future<void> scheduleUserRemindersFromDB() async {
    final settings = await SettingsDatabase.getSettings();

    if (settings['dailyNotification'] == 1) {
      scheduleDailyNotification(1, 10, 0, "Daily Reading", "Apki Quran reading ka waqt ho gaya hai.");
      scheduleDailyNotification(2, 15, 0, "Daily Reading", "Apki Quran reading ka waqt ho gaya hai.");
      scheduleDailyNotification(3, 20, 0, "Daily Reading", "Apki Quran reading ka waqt ho gaya hai.");
    }

    if (settings['customNotificationTime'] != null) {
      final parts = (settings['customNotificationTime'] as String).split(':');
      scheduleDailyNotification(
        4,
        int.parse(parts[0]),
        int.parse(parts[1]),
        "Daily Quran Reading",
        "Apki Quran reading ka waqt ho gaya hai.",
      );
    }
  }


  /// 🕐 Test notification in 1 minute
  static Future<void> scheduleTestInOneMinute() async {
    final now = DateTime.now();
    final scheduledDate = now.add(const Duration(minutes: 1, seconds: 15));
    debugPrint("⏳ Scheduling test notification for: $scheduledDate");

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100,
        channelKey: 'daily_channel',
        title: "⏰ Scheduled Test",
        body: "Ye notification 1 minute baad aani chahiye",
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledDate,
        preciseAlarm: true,
      ),
    );
  }

  /// 🚀 Fire instant notification (for testing)
  static Future<void> showTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: 'daily_channel',
        title: "Test Notification",
        body: "Please Start Reading Surah Al-Bakra",
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
    );
  }

  static Future<void> pickTimeAndSchedule(BuildContext context, int id) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      // ✅ 1. Save selected custom time to database
      final String formattedTime = "${picked.hour}:${picked.minute}";
      final currentSettings = await SettingsDatabase.getSettings();

      await SettingsDatabase.saveSettings(
        mobileData: currentSettings['mobileDataAllowed'] == 1,
        dailyNotification: currentSettings['dailyNotification'] == 1,
        customTime: formattedTime,
        customReminderEnabled: true, // ✅ since user picked a custom reminder
        selectedTheme: currentSettings['selectedTheme'] ?? 'Light Mode',
      );

      // ✅ 2. Schedule the notification dynamically
      await scheduleDailyNotification(
        id,
        picked.hour,
        picked.minute,
        "Daily Quran Reading",
        "Apki Quran reading ka waqt ho gaya hai.",
        repeatDaily: true, // ✅ Make it daily since user selected a reminder time
      );

      // ✅ 3. Show confirmation to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder set for ${picked.format(context)}")),
      );
    }
  }


  static Future<void> cancelUserReminders() async {
    try {
      await AwesomeNotifications().cancel(1); // Cancel 10AM reminder
      await AwesomeNotifications().cancel(2); // Cancel 3PM reminder
      await AwesomeNotifications().cancel(3); // Cancel 8PM reminder
      debugPrint("🛑 All user reminders cancelled");
    } catch (e) {
      debugPrint("⚠️ Error cancelling reminders: $e");
    }
  }

  static Future<void> reScheduleFromDatabase() async {
    final settings = await SettingsDatabase.getSettings();

    if (settings['dailyNotificationEnabled'] == 1) {
      await scheduleUserRemindersFromDB();
    }

    if (settings['customReminderTime'] != null) {
      final parts = (settings['customReminderTime'] as String).split(':');
      await scheduleDailyNotification(
        4,
        int.parse(parts[0]),
        int.parse(parts[1]),
        "Daily Quran Reading",
        "Apki Quran reading ka waqt ho gaya hai.",
      );
    }
  }
}
