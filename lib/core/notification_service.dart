import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Инициализация
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Инициализируем timezone
    tz.initializeTimeZones();

    // Настройки для Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Настройки для iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    // Запрашиваем разрешения
    await _requestPermissions();

    _isInitialized = true;
  }

  // Запрос разрешений
  Future<void> _requestPermissions() async {
    // Android 13+ требует запрос разрешений
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Навигация к задаче
  }

  // Обработка нажатия в фоне
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    print('Background notification tapped: ${response.payload}');
  }

  // Создание канала для уведомлений о задачах
  Future<void> _createTaskChannel() async {
    const channel = AndroidNotificationChannel(
      'tasks_channel',
      'Задачи',
      description: 'Уведомления о задачах и дедлайнах',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Создание канала для будильников
  Future<void> _createAlarmChannel() async {
    const channel = AndroidNotificationChannel(
      'alarms_channel',
      'Будильники',
      description: 'Будильники и напоминания',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Показ немедленного уведомления
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'tasks_channel',
  }) async {
    if (!_isInitialized) await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'tasks_channel',
        'Задачи',
        channelDescription: 'Уведомления о задачах',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Планирование уведомления
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'tasks_channel',
  }) async {
    if (!_isInitialized) await initialize();

    // Не планируем в прошлом
    if (scheduledDate.isBefore(DateTime.now())) {
      scheduledDate = DateTime.now().add(const Duration(minutes: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'tasks_channel',
        'Задачи',
        channelDescription: 'Уведомления о задачах',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Отмена уведомления
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Отмена всех уведомлений
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Уведомление о дедлайне задачи
  Future<void> showTaskDeadlineReminder({
    required String taskTitle,
    required DateTime deadline,
    String? taskId,
  }) async {
    final hoursUntilDeadline = deadline.difference(DateTime.now()).inHours;

    String title;
    String body;

    if (hoursUntilDeadline <= 0) {
      title = '🔴 Дедлайн задачи!';
      body = 'Задача "$taskTitle" должна быть выполнена прямо сейчас!';
    } else if (hoursUntilDeadline <= 1) {
      title = '🟠 Срочно! Дедлайн через час';
      body =
          'Задача "$taskTitle" должна быть выполнена через $hoursUntilDeadline ч';
    } else if (hoursUntilDeadline <= 24) {
      title = '🟡 Напоминание о дедлайне';
      body =
          'Задача "$taskTitle" должна быть выполнена через $hoursUntilDeadline ч';
    } else {
      final days = hoursUntilDeadline ~/ 24;
      title = '🔵 Скоро дедлайн';
      body = 'Задача "$taskTitle" должна быть выполнена через $days дн';
    }

    await showNotification(
      id: taskId.hashCode,
      title: title,
      body: body,
      payload: taskId,
    );
  }

  // Уведомление о новой задаче
  Future<void> showNewTaskNotification({
    required String taskTitle,
    String? taskId,
  }) async {
    await showNotification(
      id: taskId.hashCode,
      title: '📋 Новая задача',
      body: 'Задача "$taskTitle" создана',
      payload: taskId,
    );
  }

  // Уведомление о назначении задачи
  Future<void> showTaskAssignedNotification({
    required String taskTitle,
    required String assignedBy,
    String? taskId,
  }) async {
    await showNotification(
      id: taskId.hashCode,
      title: '🎯 Вам назначена задача',
      body: '$assignedBy назначил вас на задачу "$taskTitle"',
      payload: taskId,
    );
  }

  // Будильник
  Future<void> showAlarmNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'alarms_channel',
        'Будильники',
        channelDescription: 'Будильники и напоминания',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
    );
  }

  // Повторяющееся уведомление (ежедневное)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminders',
        'Ежедневные напоминания',
        channelDescription: 'Ежедневные уведомления',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay scheduledTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}

final notificationService = NotificationService();
