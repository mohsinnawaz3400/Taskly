
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database.
    tz_data.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
    );

    _initialized = true;
  }

  Future<bool?> requestPermission() async {
    await initialize();

    final androidPermission = await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosPermission = await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidPermission ?? iosPermission;
  }


  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await initialize();

    if (!scheduledAt.isAfter(DateTime.now())) {
      throw ArgumentError(
        'Reminder ka waqt future mein hona chahiye.',
      );
    }

    final localTime = tz.TZDateTime.from(
      scheduledAt,
      tz.local,
    );

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminders',
        'Task reminders',
        channelDescription: 'Scheduled task reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: localTime,
      notificationDetails: notificationDetails,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }



  Future<void> cancelReminder(int id) async {
    await initialize();

    await _plugin.cancel(id: id);
  }

}
