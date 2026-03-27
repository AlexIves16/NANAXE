import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _TaskCard(index: index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Новая задача'),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final int index;

  const _TaskCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(index),
          child: Text('${index + 1}'),
        ),
        title: Text('Задача #${index + 1}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Описание задачи...'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'До: ${DateTime.now().add(Duration(days: index)).toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
            const PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getPriorityColor(int index) {
    final colors = [Colors.red, Colors.orange, Colors.blue, Colors.green];
    return colors[index % colors.length];
  }
}
