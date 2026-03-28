import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mindmap_provider.dart';

class MindMapScreen extends ConsumerStatefulWidget {
  const MindMapScreen({super.key});

  @override
  ConsumerState<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends ConsumerState<MindMapScreen> {
  bool _isEditing = false;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final projectId = 'default'; // TODO: Получить текущий проект
    final mindMapState = ref.watch(mindMapProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind-карта'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            tooltip: _isEditing ? 'Готово' : 'Редактировать',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _isGenerating ? null : () => _generateWithAI(projectId),
            tooltip: 'AI Генерация',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddNodeDialog(context, projectId, null),
            tooltip: 'Добавить узел',
          ),
        ],
      ),
      body: mindMapState.when(
        data: (mindMapData) {
          if (mindMapData.nodes.isEmpty) {
            return _buildEmptyState(context, projectId);
          }

          return _buildSimpleMindMap(mindMapData);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(mindMapProvider(projectId)),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: () => _showAddNodeDialog(context, projectId, null),
              icon: const Icon(Icons.add),
              label: const Text('Добавить узел'),
            )
          : null,
    );
  }

  // Простое отображение дерева (замена GraphView)
  Widget _buildSimpleMindMap(MindMapData mindMapData) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mindMapData.nodes.length,
      itemBuilder: (context, index) {
        final node = mindMapData.nodes[index];
        return _buildTreeNodeWidget(node, mindMapData);
      },
    );
  }

  Widget _buildTreeNodeWidget(MindMapNode node, MindMapData mindMapData) {
    final children = mindMapData.getChildren(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: EdgeInsets.only(left: node.level * 20.0),
          decoration: BoxDecoration(
            color: _hexToColor(node.color),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _getIconData(node.icon),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _confirmDeleteNode(node),
                ),
            ],
          ),
        ),
        if (children.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...children.map((child) => _buildTreeNodeWidget(child, mindMapData)),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String projectId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_tree,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Mind-карта пуста',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Создайте структуру проекта',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddNodeDialog(context, projectId, null),
                icon: const Icon(Icons.add),
                label: const Text('Добавить вручную'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed:
                    _isGenerating ? null : () => _generateWithAI(projectId),
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: const Text('AI Генерация'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateWithAI(String projectId) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final projectName = await _showProjectNameDialog();
      if (projectName == null || projectName.isEmpty) return;

      final projectDescription = await _showProjectDescriptionDialog();

      await ref.read(mindMapProvider(projectId).notifier).generateMindMapWithAI(
            projectName: projectName,
            description: projectDescription ?? '',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mind-карта сгенерирована!'),
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

  Future<String?> _showProjectNameDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Название проекта'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Введите название',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Генерировать'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showProjectDescriptionDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Описание проекта'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Описание (опционально)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Пропустить'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Генерировать'),
          ),
        ],
      ),
    );
  }

  void _showAddNodeDialog(
      BuildContext context, String projectId, String? parentId) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить узел'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;

              await ref.read(mindMapProvider(projectId).notifier).addNode(
                    title: titleController.text,
                    parentId: parentId,
                  );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteNode(MindMapNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить узел?'),
        content: const Text('Все дочерние узлы также будут удалены'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Удалить узел
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('0xFF$hex'));
    }
    return Colors.blue;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder':
        return Icons.folder;
      case 'task':
        return Icons.task;
      case 'star':
        return Icons.star;
      case 'flag':
        return Icons.flag;
      default:
        return Icons.circle;
    }
  }
}
