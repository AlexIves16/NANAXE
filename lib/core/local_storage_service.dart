import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/alarm_model.dart';
import '../models/mind_map_model.dart';
import '../models/calendar_event_model.dart';

class LocalStorageService {
  static const String _tasksBoxName = 'tasks';
  static const String _alarmsBoxName = 'alarms';
  static const String _mindMapsBoxName = 'mindMaps';
  static const String _eventsBoxName = 'events';
  static const String _settingsBoxName = 'settings';

  late Box<Map> _tasksBox;
  late Box<Map> _alarmsBox;
  late Box<Map> _mindMapsBox;
  late Box<Map> _eventsBox;
  late Box<Object?> _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();

    _tasksBox = await Hive.openBox<Map>(_tasksBoxName);
    _alarmsBox = await Hive.openBox<Map>(_alarmsBoxName);
    _mindMapsBox = await Hive.openBox<Map>(_mindMapsBoxName);
    _eventsBox = await Hive.openBox<Map>(_eventsBoxName);
    _settingsBox = await Hive.openBox<Object?>(_settingsBoxName);
  }

  // Tasks
  Future<void> saveTask(TaskModel task) async {
    await _tasksBox.put(task.id, task.toMap()); // Используем toMap() для Hive
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      await _tasksBox.put(task.id, task.toMap());
    }
  }

  List<TaskModel> getTasks() {
    return _tasksBox.values.map((data) {
      return TaskModel.fromFirestore(
        _createMockDocument(data as Map<String, dynamic>),
      );
    }).toList();
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  // Alarms
  Future<void> saveAlarm(AlarmModel alarm) async {
    await _alarmsBox.put(alarm.id, alarm.toFirestore());
  }

  List<AlarmModel> getAlarms() {
    return _alarmsBox.values.map((data) {
      return AlarmModel.fromFirestore(
        _createMockDocument(data as Map<String, dynamic>),
      );
    }).toList();
  }

  Future<void> deleteAlarm(String alarmId) async {
    await _alarmsBox.delete(alarmId);
  }

  // Mind Maps
  Future<void> saveMindMapNodes(List<MindMapNode> nodes) async {
    for (final node in nodes) {
      await _mindMapsBox.put(node.id, node.toFirestore());
    }
  }

  List<MindMapNode> getMindMapNodes() {
    return _mindMapsBox.values.map((data) {
      return MindMapNode.fromFirestore(
        _createMockDocument(data as Map<String, dynamic>),
      );
    }).toList();
  }

  // Events
  Future<void> saveEvent(CalendarEventModel event) async {
    await _eventsBox.put(event.id, event.toFirestore());
  }

  List<CalendarEventModel> getEvents() {
    return _eventsBox.values.map((data) {
      return CalendarEventModel.fromFirestore(
        _createMockDocument(data as Map<String, dynamic>),
      );
    }).toList();
  }

  // Settings
  Future<void> saveSetting(String key, Object? value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // Clear all local data
  Future<void> clearAll() async {
    await _tasksBox.clear();
    await _alarmsBox.clear();
    await _mindMapsBox.clear();
    await _eventsBox.clear();
    await _settingsBox.clear();
  }

  // Sync with Firebase (merge remote and local)
  Future<void> syncWithRemote(List<TaskModel> remoteTasks) async {
    final localTasks = getTasks();
    final localMap = {for (var t in localTasks) t.id: t};
    final remoteMap = {for (var t in remoteTasks) t.id: t};

    // Merge: remote takes precedence
    final merged = {...localMap, ...remoteMap};

    await _tasksBox.clear();
    for (final task in merged.values) {
      await _tasksBox.put(task.id, task.toFirestore());
    }
  }

  // Helper method to create mock DocumentSnapshot
  dynamic _createMockDocument(Map<String, dynamic> data) {
    // Простая эмуляция для конвертации
    return data;
  }
}

final localStorageService = LocalStorageService();
