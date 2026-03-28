import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../models/project_model.dart';

class ProjectsManagementScreen extends ConsumerStatefulWidget {
  const ProjectsManagementScreen({super.key});

  @override
  ConsumerState<ProjectsManagementScreen> createState() =>
      _ProjectsManagementScreenState();
}

class _ProjectsManagementScreenState
    extends ConsumerState<ProjectsManagementScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название проекта')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Пользователь не авторизован');

      final project = ProjectModel(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        teamId: 'default', // TODO: Выбрать команду
        ownerId: user.id,
        memberIds: [user.id],
        startDate: DateTime.now(),
        color: _getRandomColor(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(project.id)
          .set(project.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Проект создан'),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _isCreating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  String _getRandomColor() {
    final colors = [
      '#2196F3',
      '#4CAF50',
      '#FF9800',
      '#E91E63',
      '#9C27B0',
      '#00BCD4'
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Future<void> _deleteProject(String projectId) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Проект удалён')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Проекты'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Создание проекта
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Создать новый проект',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название проекта *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createProject,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Создать проект'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Список проектов
          const Text(
            'Все проекты',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('projects')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Ошибка: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final projects = snapshot.data!.docs;

              if (projects.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.folder_open,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Нет проектов',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final projectData =
                      projects[index].data() as Map<String, dynamic>;
                  final projectId = projects[index].id;
                  final project = ProjectModel.fromFirestore(projects[index]);

                  return _ProjectCard(
                    project: project,
                    onDelete: () => _deleteProject(projectId),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hexToColor(project.color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder, color: Colors.white),
        ),
        title: Text(project.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                project.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${project.memberIds.length} участников',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'edit') {
              // TODO: Редактирование
            } else if (value == 'delete') {
              _showDeleteDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
            const PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        isThreeLine: true,
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить проект?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
