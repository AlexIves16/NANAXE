import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../core/firestore_service.dart';
import '../core/local_storage_service.dart';
import '../core/deepseek_service.dart';

// Provider для текущего пользователя (заглушка пока нет auth)
final currentUserIdProvider = Provider<String?>((ref) {
  // TODO: Заменить на реального пользователя из Firebase Auth
  return null; // Пока нет авторизации
});

// Provider для списка всех задач
final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return TasksNotifier(ref);
});

// Provider для задач конкретного проекта
final tasksByProjectProvider =
    Provider.family<AsyncValue<List<TaskModel>>, String>((ref, projectId) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (allTasks) => AsyncValue.data(
        allTasks.where((t) => t.projectId == projectId).toList()),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Provider для задач пользователя
final tasksByUserProvider =
    Provider.family<AsyncValue<List<TaskModel>>, String>((ref, userId) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (allTasks) =>
        AsyncValue.data(allTasks.where((t) => t.assigneeId == userId).toList()),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Stream provider для задач в реальном времени
final tasksStreamProvider =
    StreamProvider.family<List<TaskModel>, String?>((ref, projectId) {
  return firestoreService.watchTasks(projectId);
});

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final Ref ref;
  StreamSubscription? _subscription;

  TasksNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Загрузка задач
  Future<void> _loadTasks() async {
    try {
      // Сначала загружаем из локального хранилища (офлайн режим)
      final localTasks = localStorageService.getTasks();
      state = AsyncValue.data(localTasks);

      // Подписываемся на обновления из Firestore
      final currentUserId = ref.read(currentUserIdProvider);

      _subscription =
          firestoreService.watchTasks(null).listen((remoteTasks) async {
        // Сохраняем локально для офлайн режима
        await localStorageService.syncWithRemote(remoteTasks);

        // Обновляем состояние
        state = AsyncValue.data(remoteTasks);
      }, onError: (error, stackTrace) {
        // Если ошибка Firestore, используем локальные данные
        print('Firestore error: $error');
        final localTasks = localStorageService.getTasks();
        state = AsyncValue.data(localTasks);
      });
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
    String? assigneeId,
  }) async {
    try {
      final currentUserId = ref.read(currentUserIdProvider);

      final task = TaskModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        projectId: projectId,
        parentTaskId: parentTaskId,
        priority: priority,
        dueDate: dueDate,
        estimatedHours: estimatedHours,
        assigneeId: assigneeId ?? currentUserId,
        creatorId: currentUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Сохраняем локально (для офлайн режима)
      await localStorageService.saveTask(task);

      // Сохраняем в Firestore
      try {
        await firestoreService.createTask(task);
      } catch (e) {
        print('Firestore save failed, saved locally only: $e');
      }

      // Обновляем состояние
      final currentTasks = state.value ?? [];
      state = AsyncValue.data([...currentTasks, task]);

      return task;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Обновление задачи
  Future<void> updateTask(
    String taskId, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    String? assigneeId,
    Map<String, dynamic>? aiMetadata,
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
        aiMetadata: aiMetadata ?? oldTask.aiMetadata,
        updatedAt: DateTime.now(),
      );

      // Сохраняем локально
      await localStorageService.saveTask(updatedTask);

      // Сохраняем в Firestore
      try {
        await firestoreService.updateTask(updatedTask);
      } catch (e) {
        print('Firestore update failed, saved locally only: $e');
      }

      // Обновляем состояние
      currentTasks[taskIndex] = updatedTask;
      state = AsyncValue.data(List.from(currentTasks));
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

      // Удаляем из Firestore
      try {
        await firestoreService.deleteTask(taskId);
      } catch (e) {
        print('Firestore delete failed, deleted locally only: $e');
      }

      // Обновляем состояние
      final currentTasks = state.value ?? [];
      currentTasks.removeWhere((t) => t.id == taskId);
      state = AsyncValue.data(List.from(currentTasks));
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

  // AI: Генерация описания
  Future<String> generateDescriptionWithAI({
    required String title,
    String? context,
  }) async {
    return await deepSeekService.generateTaskDescription(
      title: title,
      context: context,
    );
  }

  // Фильтрация задач по статусу
  List<TaskModel> filterByStatus(List<TaskModel> tasks, TaskStatus status) {
    return tasks.where((t) => t.status == status).toList();
  }

  // Фильтрация задач по приоритету
  List<TaskModel> filterByPriority(
      List<TaskModel> tasks, TaskPriority priority) {
    return tasks.where((t) => t.priority == priority).toList();
  }

  // Просроченные задачи
  List<TaskModel> getOverdueTasks(List<TaskModel> tasks) {
    return tasks.where((t) => t.isOverdue).toList();
  }

  // Завершение задачи
  Future<void> completeTask(String taskId) async {
    await updateTask(
      taskId,
      status: TaskStatus.done,
    );
  }

  // Возобновление задачи
  Future<void> reopenTask(String taskId) async {
    await updateTask(
      taskId,
      status: TaskStatus.todo,
    );
  }
}
