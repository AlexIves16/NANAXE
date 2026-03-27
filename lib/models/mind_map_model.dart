import 'package:cloud_firestore/cloud_firestore.dart';

class MindMapNode {
  final String id;
  final String projectId;
  final String? parentId;
  final int level;
  final String title;
  final String? description;
  final String? taskId; // Link to task
  final String color;
  final String icon;
  final Map<String, dynamic> metadata;
  final double x;
  final double y;
  final DateTime createdAt;
  final DateTime updatedAt;

  MindMapNode({
    required this.id,
    required this.projectId,
    this.parentId,
    required this.level,
    required this.title,
    this.description,
    this.taskId,
    this.color = '#2196F3',
    this.icon = 'folder',
    this.metadata = const {},
    this.x = 0,
    this.y = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MindMapNode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MindMapNode(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      parentId: data['parentId'],
      level: data['level'] ?? 0,
      title: data['title'] ?? '',
      description: data['description'],
      taskId: data['taskId'],
      color: data['color'] ?? '#2196F3',
      icon: data['icon'] ?? 'folder',
      metadata: data['metadata'] ?? {},
      x: (data['x'] ?? 0).toDouble(),
      y: (data['y'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'parentId': parentId,
      'level': level,
      'title': title,
      'description': description,
      'taskId': taskId,
      'color': color,
      'icon': icon,
      'metadata': metadata,
      'x': x,
      'y': y,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MindMapNode copyWith({
    String? id,
    String? projectId,
    String? parentId,
    int? level,
    String? title,
    String? description,
    String? taskId,
    String? color,
    String? icon,
    Map<String, dynamic>? metadata,
    double? x,
    double? y,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MindMapNode(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      taskId: taskId ?? this.taskId,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
      x: x ?? this.x,
      y: y ?? this.y,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MindMapModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String rootNodeId;
  final List<MindMapNode> nodes;
  final Map<String, dynamic> layout;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MindMapModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.rootNodeId,
    required this.nodes,
    required this.layout,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MindMapModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    required List<MindMapNode> nodes,
  }) {
    return MindMapModel(
      id: id,
      projectId: data['projectId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      rootNodeId: data['rootNodeId'] ?? '',
      nodes: nodes,
      layout: data['layout'] ?? {},
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'rootNodeId': rootNodeId,
      'layout': layout,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
