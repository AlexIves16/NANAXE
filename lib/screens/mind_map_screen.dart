import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/graphview.dart';
import '../providers/mindmap_provider.dart';
import '../models/mind_map_model.dart';

class MindMapScreen extends ConsumerStatefulWidget {
  const MindMapScreen({super.key});

  @override
  ConsumerState<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends ConsumerState<MindMapScreen> {
  final Graph graph = Graph();
  final SugiyamaConfiguration config = SugiyamaConfiguration();
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

          return _buildMindMap(mindMapData);
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

  Widget _buildMindMap(MindMapData mindMapData) {
    // Строим граф из узлов
    graph.clear();

    final nodesMap = <String, Node>{};

    // Создаём узлы графа
    for (final node in mindMapData.nodes) {
      final graphNode = Node.Id(node.id);
      nodesMap[node.id] = graphNode;
      graph.addNode(graphNode);
    }

    // Создаём связи
    for (final node in mindMapData.nodes) {
      if (node.parentId != null && nodesMap.containsKey(node.parentId)) {
        graph.addEdge(nodesMap[node.parentId]!, nodesMap[node.id]!);
      }
    }

    // Настройка визуализации
    config.orientation = SugiyamaConfiguration.ORIENTATION_LEFT_RIGHT;
    config.nodeSeparation = 40;
    config.levelSeparation = 60;
    config.backgroundColor = Colors.transparent;

    // Настройка узлов
    config.builder = (Node node) {
      final mindMapNode = mindMapData.nodes.firstWhere(
        (n) => n.id == node.key,
        orElse: () => throw Exception('Node not found'),
      );

      return _buildNodeWidget(mindMapNode);
    };

    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      child: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: SugiyamaAlgorithm(graph, config),
      ),
    );
  }

  Widget _buildNodeWidget(MindMapNode node) {
    return GestureDetector(
      onTap: () => _showNodeOptionsDialog(node),
      onDoubleTap: () => _isEditing ? _showEditNodeDialog(node) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hexToColor(node.color),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconData(node.icon),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    node.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (node.taskId != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📋 Задача',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateWithAI(String projectId) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Показываем диалог для ввода данных проекта
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

  void _showEditNodeDialog(MindMapNode node) {
    final titleController = TextEditingController(text: node.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать узел'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Название',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Обновить узел
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showNodeOptionsDialog(MindMapNode node) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                _showEditNodeDialog(node);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Привязать задачу'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Выбрать задачу
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteNode(node);
              },
            ),
          ],
        ),
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
