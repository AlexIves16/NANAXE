import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/calendar_event_model.dart';
import '../core/google_calendar_service.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarEventModel> _events = [];
  bool _isLoading = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Загружаем события за месяц
      final timeMin = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final timeMax =
          DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59);

      // TODO: Загрузить из Firestore или Google Calendar
      // Пока используем тестовые данные
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _events = _generateMockEvents();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  List<CalendarEventModel> _generateMockEvents() {
    final now = DateTime.now();
    return [
      CalendarEventModel(
        id: '1',
        title: 'Командная встреча',
        startTime: DateTime(now.year, now.month, now.day, 10, 0),
        endTime: DateTime(now.year, now.month, now.day, 11, 0),
        color: '#2196F3',
        description: 'Еженедельный синк с командой',
        createdBy: 'user1',
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEventModel(
        id: '2',
        title: 'Дедлайн проекта',
        startTime: DateTime(now.year, now.month, now.day + 2, 18, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 19, 0),
        color: '#F44336',
        description: 'Сдача CRM проекта',
        createdBy: 'user1',
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEventModel(
        id: '3',
        title: 'Обед с клиентом',
        startTime: DateTime(now.year, now.month, now.day + 5, 13, 0),
        endTime: DateTime(now.year, now.month, now.day + 5, 14, 0),
        color: '#4CAF50',
        location: 'Ресторан "Москва"',
        createdBy: 'user1',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> _syncWithGoogleCalendar() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // TODO: Реальная синхронизация с Google Calendar
      // await googleCalendarService.getEvents(
      //   timeMin: DateTime(_focusedDay.year, _focusedDay.month, 1),
      //   timeMax: DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59),
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Синхронизация успешна'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка синхронизации: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  List<CalendarEventModel> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.startTime.year == day.year &&
          event.startTime.month == day.month &&
          event.startTime.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : () => _syncWithGoogleCalendar(),
            tooltip: 'Синхронизировать с Google Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEventDialog(),
            tooltip: 'Добавить событие',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    // Обработка изменения формата
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadEvents();
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    holidayTextStyle: const TextStyle(color: Colors.red),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList() {
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет событий на этот день',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showAddEventDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Добавить событие'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return _EventCard(event: event);
      },
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новое событие'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Место',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Начало'),
                        subtitle: Text(_startTime.format(context)),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              _startTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Конец'),
                        subtitle: Text(_endTime.format(context)),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              _endTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите название')),
                  );
                  return;
                }

                // TODO: Сохранить событие
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Событие создано'),
                    backgroundColor: Colors.green,
                  ),
                );

                await _loadEvents();
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _hexToColor(event.color),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (event.location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      event.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            // TODO: Действия с событием
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
            const PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('0xFF$hex'));
    }
    return Colors.blue;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
