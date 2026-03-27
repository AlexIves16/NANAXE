import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? googleEventId;
  final String? taskId;
  final List<String> attendeeIds;
  final List<String> attendeeEmails;
  final String color;
  final String? recurringRuleId;
  final Map<String, dynamic> reminders;
  final String status; // confirmed, tentative, cancelled
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    this.location = '',
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.googleEventId,
    this.taskId,
    this.attendeeIds = const [],
    this.attendeeEmails = const [],
    this.color = '#2196F3',
    this.recurringRuleId,
    this.reminders = const {},
    this.status = 'confirmed',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      location: data['location'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isAllDay: data['isAllDay'] ?? false,
      googleEventId: data['googleEventId'],
      taskId: data['taskId'],
      attendeeIds: List<String>.from(data['attendeeIds'] ?? []),
      attendeeEmails: List<String>.from(data['attendeeEmails'] ?? []),
      color: data['color'] ?? '#2196F3',
      recurringRuleId: data['recurringRuleId'],
      reminders: data['reminders'] ?? {},
      status: data['status'] ?? 'confirmed',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isAllDay': isAllDay,
      'googleEventId': googleEventId,
      'taskId': taskId,
      'attendeeIds': attendeeIds,
      'attendeeEmails': attendeeEmails,
      'color': color,
      'recurringRuleId': recurringRuleId,
      'reminders': reminders,
      'status': status,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? googleEventId,
    String? taskId,
    List<String>? attendeeIds,
    List<String>? attendeeEmails,
    String? color,
    String? recurringRuleId,
    Map<String, dynamic>? reminders,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      googleEventId: googleEventId ?? this.googleEventId,
      taskId: taskId ?? this.taskId,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      attendeeEmails: attendeeEmails ?? this.attendeeEmails,
      color: color ?? this.color,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      reminders: reminders ?? this.reminders,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration get duration => endTime.difference(startTime);
}
