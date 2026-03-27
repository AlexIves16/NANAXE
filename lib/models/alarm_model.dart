import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmModel {
  final String id;
  final String title;
  final String? taskId;
  final String? eventId;
  final DateTime dateTime;
  final bool isRepeating;
  final String repeatPattern; // daily, weekly, monthly, custom
  final List<int> repeatDays; // For custom (e.g., [1, 3, 5] for Mon, Wed, Fri)
  final bool isEnabled;
  final String sound;
  final int snoozeMinutes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlarmModel({
    required this.id,
    required this.title,
    this.taskId,
    this.eventId,
    required this.dateTime,
    this.isRepeating = false,
    this.repeatPattern = 'daily',
    this.repeatDays = const [],
    this.isEnabled = true,
    this.sound = 'default',
    this.snoozeMinutes = 5,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlarmModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlarmModel(
      id: doc.id,
      title: data['title'] ?? '',
      taskId: data['taskId'],
      eventId: data['eventId'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isRepeating: data['isRepeating'] ?? false,
      repeatPattern: data['repeatPattern'] ?? 'daily',
      repeatDays: List<int>.from(data['repeatDays'] ?? []),
      isEnabled: data['isEnabled'] ?? true,
      sound: data['sound'] ?? 'default',
      snoozeMinutes: data['snoozeMinutes'] ?? 5,
      metadata: data['metadata'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'taskId': taskId,
      'eventId': eventId,
      'dateTime': Timestamp.fromDate(dateTime),
      'isRepeating': isRepeating,
      'repeatPattern': repeatPattern,
      'repeatDays': repeatDays,
      'isEnabled': isEnabled,
      'sound': sound,
      'snoozeMinutes': snoozeMinutes,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AlarmModel copyWith({
    String? id,
    String? title,
    String? taskId,
    String? eventId,
    DateTime? dateTime,
    bool? isRepeating,
    String? repeatPattern,
    List<int>? repeatDays,
    bool? isEnabled,
    String? sound,
    int? snoozeMinutes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      taskId: taskId ?? this.taskId,
      eventId: eventId ?? this.eventId,
      dateTime: dateTime ?? this.dateTime,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatPattern: repeatPattern ?? this.repeatPattern,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      sound: sound ?? this.sound,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime get nextOccurrence {
    if (!isRepeating) return dateTime;
    
    final now = DateTime.now();
    if (dateTime.isAfter(now)) return dateTime;
    
    switch (repeatPattern) {
      case 'daily':
        return dateTime.add(const Duration(days: 1));
      case 'weekly':
        return dateTime.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(dateTime.year, dateTime.month + 1, dateTime.day);
      case 'custom':
        // Find next weekday in repeatDays
        var next = dateTime.add(const Duration(days: 1));
        while (!repeatDays.contains(next.weekday)) {
          next = next.add(const Duration(days: 1));
        }
        return DateTime(next.year, next.month, next.day, dateTime.hour, dateTime.minute);
      default:
        return dateTime;
    }
  }
}
