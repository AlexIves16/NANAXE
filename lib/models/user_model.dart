import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  member,
  viewer,
}

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final List<String> teamIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> settings;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.member,
    this.teamIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.settings = const {},
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.member,
      ),
      teamIds: List<String>.from(data['teamIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      settings: data['settings'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'teamIds': teamIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'settings': settings,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    List<String>? teamIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      teamIds: teamIds ?? this.teamIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;
  bool get isViewer => role == UserRole.viewer;
}
