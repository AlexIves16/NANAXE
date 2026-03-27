import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/notification_service.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  bool _taskNotifications = true;
  bool _deadlineReminders = true;
  bool _taskAssigned = true;
  bool _dailySummary = false;
  Time _dailySummaryTime = const Time(9, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Типы уведомлений'),
            subtitle: Text('Настройте какие уведомления показывать'),
          ),
          SwitchListTile(
            title: const Text('Задачи'),
            subtitle: const Text('Уведомления о создании и изменении задач'),
            value: _taskNotifications,
            onChanged: (value) {
              setState(() {
                _taskNotifications = value;
              });
              // TODO: Сохранить в настройки
            },
          ),
          SwitchListTile(
            title: const Text('Напоминания о дедлайнах'),
            subtitle: const Text('За 24 часа и за 1 час до дедлайна'),
            value: _deadlineReminders,
            onChanged: (value) {
              setState(() {
                _deadlineReminders = value;
              });
              // TODO: Сохранить в настройки
            },
          ),
          SwitchListTile(
            title: const Text('Назначение задач'),
            subtitle: const Text('Когда вас назначают исполнителем'),
            value: _taskAssigned,
            onChanged: (value) {
              setState(() {
                _taskAssigned = value;
              });
              // TODO: Сохранить в настройки
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Ежедневная сводка'),
            subtitle: const Text('Краткий отчёт о задачах на день'),
            value: _dailySummary,
            onChanged: (value) {
              setState(() {
                _dailySummary = value;
                if (value) {
                  _scheduleDailySummary();
                }
              });
              // TODO: Сохранить в настройки
            },
          ),
          if (_dailySummary)
            ListTile(
              title: const Text('Время сводки'),
              subtitle: Text('${_dailySummaryTime.hour.toString().padLeft(2, '0')}:${_dailySummaryTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectDailySummaryTime(),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.test_build, color: Colors.blue),
            title: const Text('Тестовое уведомление'),
            subtitle: const Text('Проверьте работу уведомлений'),
            onTap: _showTestNotification,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Уведомления будут приходить даже когда приложение закрыто. Убедитесь, что разрешения на уведомления включены в настройках устройства.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDailySummaryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().copyWith(
          hour: _dailySummaryTime.hour,
          minute: _dailySummaryTime.minute,
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _dailySummaryTime = Time(picked.hour, picked.minute);
      });
      _scheduleDailySummary();
    }
  }

  Future<void> _scheduleDailySummary() async {
    if (_dailySummary) {
      await notificationService.scheduleDailyNotification(
        id: 'daily_summary'.hashCode,
        title: '📊 Ежедневная сводка',
        body: 'Ваши задачи на сегодня',
        scheduledTime: _dailySummaryTime,
      );
    } else {
      await notificationService.cancelNotification('daily_summary'.hashCode);
    }
  }

  Future<void> _showTestNotification() async {
    await notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🔔 Тестовое уведомление',
      body: 'Если вы видите это - уведомления работают!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Уведомление отправлено')),
      );
    }
  }
}
