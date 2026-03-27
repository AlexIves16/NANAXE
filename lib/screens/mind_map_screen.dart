import 'package:flutter/material.dart';

class MindMapScreen extends StatelessWidget {
  const MindMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind-карта'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit mode - только для админов
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
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
              'Mind-карта проекта',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Создайте структуру задач в виде дерева',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Создать mind-карту'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // AI генерация mind-карты
        },
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}
