import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class DeepSeekService {
  final String? apiKey;
  final String baseUrl = 'https://api.deepseek.com';

  DeepSeekService({this.apiKey});

  // Генерация подзадач из основной задачи
  Future<List<Map<String, dynamic>>> generateSubtasks({
    required String title,
    required String description,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _mockGenerateSubtasks(title, description);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task planning assistant. Break down tasks into logical subtasks. Return ONLY a JSON array.',
            },
            {
              'role': 'user',
              'content': 'Break down this task into 3-7 subtasks:\n\nTitle: $title\nDescription: $description\n\nReturn ONLY a JSON array with format: [{"title": "...", "estimatedHours": 0, "description": "..."}]',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Извлекаем JSON из ответа
        final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final List<dynamic> subtasks = jsonDecode(jsonMatch.group(0)!);
          return subtasks.cast<Map<String, dynamic>>();
        }
      } else {
        print('DeepSeek API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DeepSeek Service Error: $e');
    }

    return _mockGenerateSubtasks(title, description);
  }

  // AI приоритизация задач
  Future<TaskPriority> prioritizeTask({
    required String title,
    required String description,
    DateTime? dueDate,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _mockPrioritizeTask(dueDate);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task prioritization assistant. Determine task priority: low, medium, high, or urgent. Reply with ONE word only.',
            },
            {
              'role': 'user',
              'content': 'What priority should this task have?\n\nTitle: $title\nDescription: $description\nDue: ${dueDate ?? "Not specified"}\n\nReply with ONE word: low, medium, high, or urgent',
            },
          ],
          'temperature': 0.3,
          'max_tokens': 10,
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
      print('DeepSeek Service Error: $e');
    }

    return _mockPrioritizeTask(dueDate);
  }

  // Генерация описания задачи
  Future<String> generateTaskDescription({
    required String title,
    String? context,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return 'Описание для задачи: $title';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a task description writer. Write clear, concise task descriptions in Russian. Keep it under 100 words.',
            },
            {
              'role': 'user',
              'content': 'Write a brief description for this task:\n\nTitle: $title\nContext: ${context ?? "No additional context"}\n\nWrite in Russian.',
            },
          ],
          'temperature': 0.5,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
    } catch (e) {
      print('DeepSeek Service Error: $e');
    }

    return 'Описание для задачи: $title';
  }

  // Умное планирование - распределение задач по времени
  Future<List<Map<String, dynamic>>> smartSchedule({
    required List<TaskModel> tasks,
    required DateTime startDate,
    required DateTime endDate,
    required int availableHoursPerDay,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _mockSchedule(tasks, startDate, endDate, availableHoursPerDay);
    }

    try {
      final tasksJson = tasks.map((t) => {
        'title': t.title,
        'estimatedHours': t.estimatedHours,
        'priority': t.priority.name,
        'dueDate': t.dueDate?.toIso8601String(),
      }).toList();

      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a smart scheduling assistant. Distribute tasks across available days optimally. Return ONLY a JSON array.',
            },
            {
              'role': 'user',
              'content': '''
Schedule these tasks optimally:
${jsonEncode(tasksJson)}

Available hours per day: $availableHoursPerDay
Start date: ${startDate.toIso8601String()}
End date: ${endDate.toIso8601String()}

Return JSON array: [{"taskId": index, "date": "YYYY-MM-DD", "hours": 0}]
''',
            },
          ],
          'temperature': 0.5,
          'max_tokens': 3000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final List<dynamic> schedule = jsonDecode(jsonMatch.group(0)!);
          return schedule.map((s) {
            return {
              'taskId': s['taskId'],
              'date': DateTime.parse(s['date']),
              'hours': s['hours'],
            };
          }).toList();
        }
      }
    } catch (e) {
      print('DeepSeek Service Error: $e');
    }

    return _mockSchedule(tasks, startDate, endDate, availableHoursPerDay);
  }

  // AI анализ проекта - генерация mind-карты
  Future<List<Map<String, dynamic>>> generateMindMap({
    required String projectName,
    required String description,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _mockMindMap(projectName);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a project structure assistant. Create a mind-map structure for projects. Return ONLY a JSON array of nodes.',
            },
            {
              'role': 'user',
              'content': '''
Create a mind-map structure for this project:

Project: $projectName
Description: $description

Return JSON array of nodes with format:
[{"level": 0, "title": "Project Name", "parentId": null}, {"level": 1, "title": "Phase 1", "parentId": 0}, ...]
''',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 3000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final List<dynamic> nodes = jsonDecode(jsonMatch.group(0)!);
          return nodes.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('DeepSeek Service Error: $e');
    }

    return _mockMindMap(projectName);
  }

  // Mock данные для тестирования
  List<Map<String, dynamic>> _mockGenerateSubtasks(String title, String description) {
    return [
      {'title': 'Анализ требований', 'estimatedHours': 2, 'description': 'Изучить требования и документацию'},
      {'title': 'Проектирование', 'estimatedHours': 3, 'description': 'Спроектировать архитектуру решения'},
      {'title': 'Реализация', 'estimatedHours': 8, 'description': 'Написать код'},
      {'title': 'Тестирование', 'estimatedHours': 3, 'description': 'Протестировать функциональность'},
      {'title': 'Документирование', 'estimatedHours': 2, 'description': 'Создать документацию'},
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

  List<Map<String, dynamic>> _mockSchedule(
    List<TaskModel> tasks,
    DateTime startDate,
    DateTime endDate,
    int availableHoursPerDay,
  ) {
    final schedule = <Map<String, dynamic>>[];
    var currentDate = startDate;
    var remainingHours = availableHoursPerDay;

    for (var i = 0; i < tasks.length; i++) {
      if (currentDate.isAfter(endDate)) break;

      final task = tasks[i];
      if (task.estimatedHours <= remainingHours) {
        schedule.add({
          'taskId': i,
          'date': currentDate,
          'hours': task.estimatedHours,
        });
        remainingHours -= task.estimatedHours;
      } else {
        currentDate = currentDate.add(const Duration(days: 1));
        remainingHours = availableHoursPerDay;
        
        if (currentDate.isAfter(endDate)) break;
        
        schedule.add({
          'taskId': i,
          'date': currentDate,
          'hours': task.estimatedHours > remainingHours 
              ? remainingHours 
              : task.estimatedHours,
        });
      }
    }

    return schedule;
  }

  List<Map<String, dynamic>> _mockMindMap(String projectName) {
    return [
      {'level': 0, 'title': projectName, 'parentId': null},
      {'level': 1, 'title': 'Планирование', 'parentId': 0},
      {'level': 1, 'title': 'Разработка', 'parentId': 0},
      {'level': 1, 'title': 'Тестирование', 'parentId': 0},
      {'level': 1, 'title': 'Деплой', 'parentId': 0},
      {'level': 2, 'title': 'Анализ', 'parentId': 1},
      {'level': 2, 'title': 'Дизайн', 'parentId': 1},
      {'level': 2, 'title': 'Frontend', 'parentId': 2},
      {'level': 2, 'title': 'Backend', 'parentId': 2},
      {'level': 2, 'title': 'Unit тесты', 'parentId': 3},
      {'level': 2, 'title': 'E2E тесты', 'parentId': 3},
    ];
  }
}

// Глобальный экземпляр сервиса
final deepSeekService = DeepSeekService(
  // API ключ можно получить на https://platform.deepseek.com
  apiKey: null, // Добавить ключ здесь или через .env
);
