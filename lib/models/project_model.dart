import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String teamId;
  final String ownerId;
  final List<String> memberIds;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String color;
  final String icon;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.teamId,
    required this.ownerId,
    this.memberIds = const [],
    this.status = 'active',
    required this.startDate,
    this.endDate,
    this.color = '#1976D2',
    this.icon = 'project',
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      teamId: data['teamId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      status: data['status'] ?? 'active',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate() 
          : null,
      color: data['color'] ?? '#1976D2',
      icon: data['icon'] ?? 'project',
      settings: data['settings'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'teamId': teamId,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'status': status,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'color': color,
      'icon': icon,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? teamId,
    String? ownerId,
    List<String>? memberIds,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? color,
    String? icon,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teamId: teamId ?? this.teamId,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isMember(String userId) {
    return ownerId == userId || memberIds.contains(userId);
  }

  bool isOwner(String userId) {
    return ownerId == userId;
  }
}
