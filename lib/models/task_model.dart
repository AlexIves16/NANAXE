import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus {
  todo,
  inProgress,
  review,
  done,
  archived,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String projectId;
  final String? parentTaskId; // For mind-map hierarchy
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final String? creatorId;
  final List<String> tags;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? completedDate;
  final int estimatedHours;
  final int spentHours;
  final Map<String, dynamic> aiMetadata; // AI-generated suggestions
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.projectId,
    this.parentTaskId,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assigneeId,
    this.creatorId,
    this.tags = const [],
    this.dueDate,
    this.startDate,
    this.completedDate,
    this.estimatedHours = 0,
    this.spentHours = 0,
    this.aiMetadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      projectId: data['projectId'] ?? '',
      parentTaskId: data['parentTaskId'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      assigneeId: data['assigneeId'],
      creatorId: data['creatorId'],
      tags: List<String>.from(data['tags'] ?? []),
      dueDate: data['dueDate'] != null 
          ? (data['dueDate'] as Timestamp).toDate() 
          : null,
      startDate: data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate() 
          : null,
      completedDate: data['completedDate'] != null 
          ? (data['completedDate'] as Timestamp).toDate() 
          : null,
      estimatedHours: data['estimatedHours'] ?? 0,
      spentHours: data['spentHours'] ?? 0,
      aiMetadata: data['aiMetadata'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'projectId': projectId,
      'parentTaskId': parentTaskId,
      'status': status.name,
      'priority': priority.name,
      'assigneeId': assigneeId,
      'creatorId': creatorId,
      'tags': tags,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'completedDate': completedDate != null 
          ? Timestamp.fromDate(completedDate!) 
          : null,
      'estimatedHours': estimatedHours,
      'spentHours': spentHours,
      'aiMetadata': aiMetadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? parentTaskId,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    String? creatorId,
    List<String>? tags,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedDate,
    int? estimatedHours,
    int? spentHours,
    Map<String, dynamic>? aiMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      creatorId: creatorId ?? this.creatorId,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      spentHours: spentHours ?? this.spentHours,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != TaskStatus.done;
  }
}
