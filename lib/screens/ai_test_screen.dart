import 'package:flutter/material.dart';
import '../core/deepseek_service.dart';

class AiTestScreen extends StatefulWidget {
  const AiTestScreen({super.key});

  @override
  State<AiTestScreen> createState() => _AiTestScreenState();
}

class _AiTestScreenState extends State<AiTestScreen> {
  final _titleController = TextEditingController(text: 'Создать CRM систему');
  final _descController = TextEditingController(
    text: 'Разработка CRM для управления задачами команды с AI планированием',
  );
  
  bool _isLoading = false;
  String _result = '';

  Future<void> _testGenerateSubtasks() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final subtasks = await deepSeekService.generateSubtasks(
        title: _titleController.text,
        description: _descController.text,
      );

      setState(() {
        _result = '✅ Сгенерировано подзадач: ${subtasks.length}\n\n';
        for (var task in subtasks) {
          _result += '• ${task['title']} (${task['estimatedHours']}ч)\n';
          if (task['description'] != null) {
            _result += '  ${task['description']}\n';
          }
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ Ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPrioritize() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final priority = await deepSeekService.prioritizeTask(
        title: _titleController.text,
        description: _descController.text,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );

      setState(() {
        _result = '✅ Приоритет: ${priority.name}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testMindMap() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final nodes = await deepSeekService.generateMindMap(
        projectName: _titleController.text,
        description: _descController.text,
      );

      setState(() {
        _result = '✅ Сгенерировано узлов mind-карты: ${nodes.length}\n\n';
        for (var node in nodes) {
          final indent = '  ' * (node['level'] as int);
          _result += '$indent• ${node['title']} (уровень ${node['level']})\n';
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ Ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Тест (DeepSeek)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Тесты AI:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGenerateSubtasks,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Генерация подзадач'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testPrioritize,
              icon: const Icon(Icons.priority_high),
              label: const Text('Приоритизация задачи'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testMindMap,
              icon: const Icon(Icons.account_tree),
              label: const Text('Mind-карта проекта'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
