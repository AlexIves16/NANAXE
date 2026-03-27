import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class AIService {
  final String? openaiApiKey;
  final String? anthropicApiKey;
  final String? googleAiApiKey;

  AIService({
    this.openaiApiKey,
    this.anthropicApiKey,
    this.googleAiApiKey,
  });

  // Генерация подзадач из основной задачи
  Future<List<Map<String, dynamic>>> generateSubtasks({
    required String title,
    required String description,
  }) async {
    if (openaiApiKey == null) {
      return _mockGenerateSubtasks(title, description);
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task planning assistant. Break down tasks into logical subtasks.',
            },
            {
              'role': 'user',
              'content': 'Break down this task into 3-7 subtasks:\n\nTitle: $title\nDescription: $description\n\nReturn ONLY a JSON array of subtasks with format: [{"title": "...", "estimatedHours": 0}]',
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final List<dynamic> subtasks = jsonDecode(content);
        return subtasks.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('AI Service Error: $e');
    }

    return _mockGenerateSubtasks(title, description);
  }

  // AI приоритизация задач
  Future<TaskPriority> prioritizeTask({
    required String title,
    required String description,
    DateTime? dueDate,
  }) async {
    if (openaiApiKey == null) {
      return _mockPrioritizeTask(dueDate);
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task prioritization assistant. Determine task priority: low, medium, high, or urgent.',
            },
            {
              'role': 'user',
              'content': 'What priority should this task have?\n\nTitle: $title\nDescription: $description\nDue: ${dueDate ?? "Not specified"}\n\nReply with ONE word: low, medium, high, or urgent',
            },
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim().toLowerCase();
        
        switch (content) {
          case 'urgent': return TaskPriority.urgent;
          case 'high': return TaskPriority.high;
          case 'low': return TaskPriority.low;
          default: return TaskPriority.medium;
        }
      }
    } catch (e) {
      print('AI Service Error: $e');
    }

    return _mockPrioritizeTask(dueDate);
  }

  // Умное планирование - распределение задач по времени
  Future<List<Map<String, dynamic>>> smartSchedule({
    required List<TaskModel> tasks,
    required DateTime startDate,
    required DateTime endDate,
    required int availableHoursPerDay,
  }) async {
    // Mock implementation для начала
    final schedule = <Map<String, dynamic>>[];
    var currentDate = startDate;
    var remainingHours = availableHoursPerDay;

    for (final task in tasks) {
      if (currentDate.isAfter(endDate)) break;

      if (task.estimatedHours <= remainingHours) {
        schedule.add({
          'taskId': task.id,
          'date': currentDate,
          'hours': task.estimatedHours,
        });
        remainingHours -= task.estimatedHours;
      } else {
        // Переходим на следующий день
        currentDate = currentDate.add(const Duration(days: 1));
        remainingHours = availableHoursPerDay;
        
        if (currentDate.isAfter(endDate)) break;
        
        schedule.add({
          'taskId': task.id,
          'date': currentDate,
          'hours': task.estimatedHours > remainingHours 
              ? remainingHours 
              : task.estimatedHours,
        });
        remainingHours -= task.estimatedHours > remainingHours 
            ? remainingHours 
            : task.estimatedHours;
      }
    }

    return schedule;
  }

  // Генерация описания задачи
  Future<String> generateTaskDescription({
    required String title,
    String? context,
  }) async {
    if (openaiApiKey == null) {
      return 'Описание для задачи: $title';
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task description writer. Write clear, concise task descriptions.',
            },
            {
              'role': 'user',
              'content': 'Write a brief description for this task:\n\nTitle: $title\nContext: ${context ?? "No additional context"}\n\nKeep it under 100 words.',
            },
          ],
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
    } catch (e) {
      print('AI Service Error: $e');
    }

    return 'Описание для задачи: $title';
  }

  // Mock данные для тестирования
  List<Map<String, dynamic>> _mockGenerateSubtasks(String title, String description) {
    return [
      {'title': 'Анализ требований', 'estimatedHours': 2},
      {'title': 'Проектирование', 'estimatedHours': 3},
      {'title': 'Реализация', 'estimatedHours': 8},
      {'title': 'Тестирование', 'estimatedHours': 3},
      {'title': 'Документирование', 'estimatedHours': 2},
    ];
  }

  TaskPriority _mockPrioritizeTask(DateTime? dueDate) {
    if (dueDate == null) return TaskPriority.medium;
    
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
    
    if (daysUntilDue <= 1) return TaskPriority.urgent;
    if (daysUntilDue <= 3) return TaskPriority.high;
    if (daysUntilDue <= 7) return TaskPriority.medium;
    return TaskPriority.low;
  }
}

final aiService = AIService(
  // API ключи лучше хранить в .env файле или Firebase Remote Config
  openaiApiKey: null, // Добавить ключ здесь или через env
  anthropicApiKey: null,
  googleAiApiKey: null,
);
