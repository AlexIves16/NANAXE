import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final TaskModel? task;
  final String projectId;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.projectId,
  });

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  int _estimatedHours = 0;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _estimatedHours = widget.task!.estimatedHours;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _generateSubtasksWithAI() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название задачи')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      await ref.read(tasksProvider.notifier).generateSubtasksWithAI(
        title: _titleController.text,
        description: _descriptionController.text,
        projectId: widget.projectId,
        parentTaskId: widget.task?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Подзадачи успешно сгенерированы!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _prioritizeWithAI() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название задачи')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final priority = await ref.read(tasksProvider.notifier).prioritizeTaskWithAI(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
      );

      setState(() {
        _priority = priority;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ AI определил приоритет: ${priority.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.task != null) {
        // Редактирование
        await ref.read(tasksProvider.notifier).updateTask(
          widget.task!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          priority: _priority,
          dueDate: _dueDate,
        );
      } else {
        // Создание
        await ref.read(tasksProvider.notifier).createTask(
          title: _titleController.text,
          description: _descriptionController.text,
          projectId: widget.projectId,
          priority: _priority,
          dueDate: _dueDate,
          estimatedHours: _estimatedHours,
        );
      }

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать задачу' : 'Новая задача'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(),
              tooltip: 'Удалить',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Название
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Описание
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // AI Кнопки
            if (!isEdit) ...[
              _buildAIButton(
                icon: Icons.auto_awesome,
                label: 'AI: Создать подзадачи',
                onPressed: _isGenerating ? null : _generateSubtasksWithAI,
                color: Colors.purple,
              ),
              const SizedBox(height: 8),
              _buildAIButton(
                icon: Icons.priority_high,
                label: 'AI: Определить приоритет',
                onPressed: _isGenerating ? null : _prioritizeWithAI,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
            ],

            // Приоритет
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Приоритет',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      _getPriorityIcon(priority),
                      const SizedBox(width: 8),
                      Text(_getPriorityLabel(priority)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Дедлайн
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Дедлайн'),
              subtitle: Text(_dueDate != null 
                  ? '📅 ${_dueDate!.day}.${_dueDate!.month}.${_dueDate!.year}'
                  : 'Не выбран'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDueDate,
            ),
            const SizedBox(height: 16),

            // Оценка времени
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _estimatedHours.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Оценка (часы)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _estimatedHours = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Кнопка сохранения
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Сохранить' : 'Создать задачу'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color),
      ),
    );
  }

  Widget _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return const Icon(Icons.fire_engine, color: Colors.red);
      case TaskPriority.high:
        return const Icon(Icons.arrow_upward, color: Colors.orange);
      case TaskPriority.medium:
        return const Icon(Icons.remove, color: Colors.blue);
      case TaskPriority.low:
        return const Icon(Icons.arrow_downward, color: Colors.green);
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Срочно';
      case TaskPriority.high:
        return 'Высокий';
      case TaskPriority.medium:
        return 'Средний';
      case TaskPriority.low:
        return 'Низкий';
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(widget.task!.id);
              Navigator.pop(context);
              context.pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
