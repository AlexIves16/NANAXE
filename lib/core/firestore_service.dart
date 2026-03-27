import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/mind_map_model.dart';
import '../models/calendar_event_model.dart';
import '../models/alarm_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === USERS ===
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toFirestore());
  }

  // === PROJECTS ===
  Future<void> createProject(ProjectModel project) async {
    await _db.collection('projects').doc(project.id).set(project.toFirestore());
  }

  Future<List<ProjectModel>> getProjectsByTeam(String teamId) async {
    final snapshot = await _db
        .collection('projects')
        .where('teamId', isEqualTo: teamId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
  }

  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    final snapshot = await _db
        .collection('projects')
        .where('memberIds', arrayContains: userId)
        .get();
    
    return snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
  }

  // === TASKS ===
  Future<void> createTask(TaskModel task) async {
    await _db.collection('tasks').doc(task.id).set(task.toFirestore());
  }

  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    final snapshot = await _db
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  Future<List<TaskModel>> getTasksByAssignee(String assigneeId) async {
    final snapshot = await _db
        .collection('tasks')
        .where('assigneeId', isEqualTo: assigneeId)
        .where('status', whereIn: ['todo', 'inProgress', 'review'])
        .get();
    
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  Future<void> updateTask(TaskModel task) async {
    await _db.collection('tasks').doc(task.id).update(task.toFirestore());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  // Задачи с поддержкой иерархии (для mind-map)
  Future<List<TaskModel>> getTaskHierarchy(String projectId) async {
    final snapshot = await _db
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .get();
    
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  // === MIND MAPS ===
  Future<void> createMindMapNode(MindMapNode node) async {
    await _db.collection('mindmaps').doc(node.projectId).collection('nodes').doc(node.id).set(node.toFirestore());
  }

  Future<List<MindMapNode>> getMindMapNodes(String projectId) async {
    final snapshot = await _db
        .collection('mindmaps')
        .doc(projectId)
        .collection('nodes')
        .orderBy('level')
        .get();
    
    return snapshot.docs.map((doc) => MindMapNode.fromFirestore(doc)).toList();
  }

  Future<void> updateMindMapNode(MindMapNode node) async {
    await _db
        .collection('mindmaps')
        .doc(node.projectId)
        .collection('nodes')
        .doc(node.id)
        .update(node.toFirestore());
  }

  // === CALENDAR EVENTS ===
  Future<void> createEvent(CalendarEventModel event) async {
    await _db.collection('events').doc(event.id).set(event.toFirestore());
  }

  Future<List<CalendarEventModel>> getEventsByDateRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  }) async {
    Query query = _db
        .collection('events')
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    
    if (userId != null) {
      query = query.where('attendeeIds', arrayContains: userId);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => CalendarEventModel.fromFirestore(doc)).toList();
  }

  Future<void> updateEvent(CalendarEventModel event) async {
    await _db.collection('events').doc(event.id).update(event.toFirestore());
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  // === ALARMS ===
  Future<void> createAlarm(AlarmModel alarm) async {
    await _db.collection('alarms').doc(alarm.id).set(alarm.toFirestore());
  }

  Future<List<AlarmModel>> getAlarmsByUser(String userId) async {
    final snapshot = await _db
        .collection('alarms')
        .where('isEnabled', isEqualTo: true)
        .orderBy('dateTime')
        .get();
    
    return snapshot.docs.map((doc) => AlarmModel.fromFirestore(doc)).toList();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    await _db.collection('alarms').doc(alarm.id).update(alarm.toFirestore());
  }

  Future<void> deleteAlarm(String alarmId) async {
    await _db.collection('alarms').doc(alarmId).delete();
  }

  // === BATCH OPERATIONS ===
  Future<void> syncTasks(List<TaskModel> tasks) async {
    final batch = _db.batch();
    
    for (final task in tasks) {
      batch.set(_db.collection('tasks').doc(task.id), task.toFirestore());
    }
    
    await batch.commit();
  }

  // === STREAMS (для реального времени) ===
  Stream<List<TaskModel>> watchTasks(String projectId) {
    return _db
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  Stream<List<CalendarEventModel>> watchEvents(String userId) {
    return _db
        .collection('events')
        .where('attendeeIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CalendarEventModel.fromFirestore(doc)).toList());
  }
}

final firestoreService = FirestoreService();
