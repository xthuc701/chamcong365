import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Request notification permission
    await Permission.notification.request();
    
    // Initialize notification settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showCheckInReminder() async {
    const android = AndroidNotificationDetails(
      'checkin_reminder',
      'Check-in Reminder',
      channelDescription: 'Reminder to check in for work',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notification = NotificationDetails(android: android, iOS: ios);
    
    await _notifications.show(
      0,
      'ChamCong_365',
      'Đừng quên check-in cho ca làm việc của bạn!',
      notification,
      payload: 'checkin_reminder',
    );
  }

  Future<void> showCheckOutReminder() async {
    const android = AndroidNotificationDetails(
      'checkout_reminder',
      'Check-out Reminder',
      channelDescription: 'Reminder to check out from work',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notification = NotificationDetails(android: android, iOS: ios);
    
    await _notifications.show(
      1,
      'ChamCong_365',
      'Đừng quên check-out khi kết thúc ca làm việc!',
      notification,
      payload: 'checkout_reminder',
    );
  }

  // Schedule daily check-in reminder
  Future<void> scheduleDailyCheckInReminder(int hour, int minute) async {
    const android = AndroidNotificationDetails(
      'daily_checkin',
      'Daily Check-in Reminder',
      channelDescription: 'Daily reminder to check in',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notification = NotificationDetails(android: android, iOS: ios);
    
    await _notifications.zonedSchedule(
      2,
      'ChamCong_365',
      'Thời gian check-in đã đến!',
      _nextInstanceOfTime(hour, minute),
      notification,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_checkin',
    );
  }

  // Schedule daily check-out reminder
  Future<void> scheduleDailyCheckOutReminder(int hour, int minute) async {
    const android = AndroidNotificationDetails(
      'daily_checkout',
      'Daily Check-out Reminder',
      channelDescription: 'Daily reminder to check out',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notification = NotificationDetails(android: android, iOS: ios);
    
    await _notifications.zonedSchedule(
      3,
      'ChamCong_365',
      'Thời gian check-out đã đến!',
      _nextInstanceOfTime(hour, minute),
      notification,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_checkout',
    );
  }

  // Helper method to calculate next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
      return tz.TZDateTime.from(scheduledDate, tz.local);
    }
  }

