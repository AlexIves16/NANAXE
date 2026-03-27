import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../core/firestore_service.dart';
import '../core/local_storage_service.dart';
import '../core/deepseek_service.dart';

// Provider для списка всех задач
final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return TasksNotifier();
});

// Provider для задач конкретного проекта
final tasksByProjectProvider = Provider.family<AsyncValue<List<TaskModel>>, String>((ref, projectId) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (allTasks) => AsyncValue.data(allTasks.where((t) => t.projectId == projectId).toList()),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Provider для задач пользователя
final tasksByUserProvider = Provider.family<AsyncValue<List<TaskModel>>, String>((ref, userId) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (allTasks) => AsyncValue.data(allTasks.where((t) => t.assigneeId == userId).toList()),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  TasksNotifier() : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  // Загрузка задач
  Future<void> _loadTasks() async {
    try {
      // Сначала загружаем из локального хранилища
      final localTasks = localStorageService.getTasks();
      state = AsyncValue.data(localTasks);

      // Потом синхронизируем с Firestore
      // TODO: Реализовать когда будет Firebase Auth
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Создание задачи
  Future<TaskModel> createTask({
    required String title,
    String? description,
    required String projectId,
    String? parentTaskId,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    int estimatedHours = 0,
  }) async {
    try {
      final task = TaskModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        projectId: projectId,
        parentTaskId: parentTaskId,
        priority: priority,
        dueDate: dueDate,
        estimatedHours: estimatedHours,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Сохраняем локально
      await localStorageService.saveTask(task);
      
      // Обновляем состояние
      final currentTasks = state.value ?? [];
      state = AsyncValue.data([...currentTasks, task]);

      // TODO: Сохранить в Firestore когда будет авторизация
      // await firestoreService.createTask(task);

      return task;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Обновление задачи
  Future<void> updateTask(String taskId, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    String? assigneeId,
  }) async {
    try {
      final currentTasks = state.value ?? [];
      final taskIndex = currentTasks.indexWhere((t) => t.id == taskId);
      
      if (taskIndex == -1) throw Exception('Task not found');

      final oldTask = currentTasks[taskIndex];
      final updatedTask = oldTask.copyWith(
        title: title ?? oldTask.title,
        description: description ?? oldTask.description,
        status: status ?? oldTask.status,
        priority: priority ?? oldTask.priority,
        dueDate: dueDate ?? oldTask.dueDate,
        assigneeId: assigneeId ?? oldTask.assigneeId,
        updatedAt: DateTime.now(),
      );

      // Сохраняем локально
      await localStorageService.saveTask(updatedTask);

      // Обновляем состояние
      currentTasks[taskIndex] = updatedTask;
      state = AsyncValue.data(List.from(currentTasks));

      // TODO: Обновить в Firestore
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Удаление задачи
  Future<void> deleteTask(String taskId) async {
    try {
      // Удаляем локально
      await localStorageService.deleteTask(taskId);

      // Обновляем состояние
      final currentTasks = state.value ?? [];
      currentTasks.removeWhere((t) => t.id == taskId);
      state = AsyncValue.data(List.from(currentTasks));

      // TODO: Удалить из Firestore
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // AI: Генерация подзадач
  Future<List<TaskModel>> generateSubtasksWithAI({
    required String title,
    required String description,
    required String projectId,
    String? parentTaskId,
  }) async {
    try {
      final subtasksData = await deepSeekService.generateSubtasks(
        title: title,
        description: description,
      );

      final subtasks = <TaskModel>[];
      for (final subtaskData in subtasksData) {
        final subtask = await createTask(
          title: subtaskData['title'] ?? '',
          description: subtaskData['description'],
          projectId: projectId,
          parentTaskId: parentTaskId,
          estimatedHours: subtaskData['estimatedHours'] ?? 0,
        );
        subtasks.add(subtask);
      }

      return subtasks;
    } catch (e, st) {
      rethrow;
    }
  }

  // AI: Приоритизация задачи
  Future<TaskPriority> prioritizeTaskWithAI({
    required String title,
    required String description,
    DateTime? dueDate,
  }) async {
    return await deepSeekService.prioritizeTask(
      title: title,
      description: description,
      dueDate: dueDate,
    );
  }

  // Фильтрация задач по статусу
  List<TaskModel> filterByStatus(List<TaskModel> tasks, TaskStatus status) {
    return tasks.where((t) => t.status == status).toList();
  }

  // Фильтрация задач по приоритету
  List<TaskModel> filterByPriority(List<TaskModel> tasks, TaskPriority priority) {
    return tasks.where((t) => t.priority == priority).toList();
  }

  // Просроченные задачи
  List<TaskModel> getOverdueTasks(List<TaskModel> tasks) {
    return tasks.where((t) => t.isOverdue).toList();
  }
}
